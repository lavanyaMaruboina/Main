/**
 * @description       : 
 * @author            : Kruthi Nadig
 * @group             : 
 * @last modified on  : 02-03-2023
 * @last modified by  : Kruthi Nadig
**/
import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import getRelatedFileByRecordId from "@salesforce/apex/GenericUploadController.getRelatedFileByRecordId";
import JSPDF from '@salesforce/resourceUrl/JSPDF';
import previewURL from '@salesforce/label/c.PreviewUrl';
import internalpreviewurl from '@salesforce/label/c.Internalpreviewurl';

import getProfileName from '@salesforce/apex/GenericUploadController.getProfileName';

export default class PreviewFile extends LightningElement {


    @api contentversionid;
    @api fileId;
    @api heightInRem = 40;
    blobPdf;
    src = previewURL; ///resource/pdfjs/pdfjs/web/viewer.html?file=
    blbUrl = '';
    blobPdfFinal;
    base64dataFinal = '';
    @track hex = '';
    @track pdfdata;
    plainTxt;
    internal = false;
    



    connectedCallback() {

        getProfileName({ loanApplicationId: "" })
          .then(result => {
            console.log('Result in document upload ', result);
                this.internal = !result;
                if(this.internal) {
                    this.src = internalpreviewurl;
                } else {
                    this.src = previewURL;
                }
                Promise.all([
                    loadScript(this, JSPDF), this.callDoinIt()
        
                ]).catch(error => {
                    this.showToastMessage('Error loading Preview Libraries', "Error", 'Error');
                    console.log('ERROR', error);
                });
            
          })
          .catch(error => {
            console.error('Error:', error);
        });
        //   this.callDoinIt();
    }


    callDoinIt() {
        getRelatedFileByRecordId({ contentVersionId: this.contentversionid })
            .then(data => {
                if (data) {
                   this.plainTxt = atob(data);
                    console.log('data', data);
                    this.blobPdf = new Blob([this.base64ToArrayBuffer(data)], { type: 'image/jpeg' }); //blob data for img
                    //  this.blobPdf = new Blob([this.base64ToArrayBuffer(data)], {type: 'application/pdf'}); //blob data for pdf
                    this.getFileType(this.blobPdf);
                } else if (error) {
                    this.showToastMessage('Error', 'An Error occur while fetching the file. No File found', 'Error');
                }
            })
            .catch(error => {
                console.log('Error in loadApplicantFields: ' + JSON.stringify(error));
            })
    }

    getFileType(blobFile) {
        const getblob = blobFile.slice(0, 4);
        const filereader = new FileReader()

        filereader.onload = f => {
            if (filereader.readyState === FileReader.DONE) {
                const uint = new Uint8Array(filereader.result);
                let bytes = [];
                uint.forEach((byte) => {
                    bytes.push(byte.toString(16));
                });
                const hexStr = bytes.join('').toUpperCase();
                this.hex = hexStr;
                this.callMain();
            }
        }
        filereader.readAsArrayBuffer(getblob);

    }

    callMain() {
        console.log('hex type', this.hex);
        var mimeType = this.getMimetype(this.hex);
        console.log('hex', this.getMimetype(this.hex));
        if (mimeType == 'application/pdf') {
            //this.showToastMessage('info','Please wait for 4-5 Seconds. PDF is rendering!!!', 'info');
            this.pdfToView();
        } else if (mimeType == 'text/plain') {
            this.blobToView();
        }
        else if (mimeType == 'Unknown filetype') {
            this.showToastMessage('Error', 'An Error occur while fetching the file. File extension not supported', 'Error');
        }
        else {
            this.blobToView();
        }
    }



    pdfToView() {
        var blobUrl = URL.createObjectURL(this.blobPdf);
        console.log('blobUrl : ' + blobUrl);
            this.src =  window.location.origin + this.src + encodeURIComponent(blobUrl);
        console.log('src : ' + src);
       // window.open('https://'+window.location.hostname+'/KotakInternalVlos'+this.src, '_blank');
    }

    textFileToView() {
        var blob = new Blob(this.blobPdf, { type: "text/plain;charset=utf-8" });
        var blobUrl = URL.createObjectURL(this.blob);
       // var file = new File([blob], "name.txt");
        this.src = window.location.origin + this.src + encodeURIComponent(blobUrl);
    }

    blobToView() {
        const { jsPDF } = window.jspdf;
        //var doc = new jsPDF(); 
        const doc = new jsPDF('p', 'pt', 'a4');
        var reader = new FileReader();
        reader.onload = f => {
            var base64data = reader.result;
            //doc.text(5, 5, this.plainTxt);
            //doc.addPage('a4', 'p');
            //doc.text(20, 20, this.plainTxt);
             doc.addImage(base64data, 'JPEG', 100, 160, 400, 276);
            this.src = location.origin + this.src + encodeURIComponent(doc.output('bloburl'));
           // window.open('https://'+window.location.hostname+'/KotakInternalVlos'+this.src, '_blank');
        }
        reader.readAsDataURL(this.blobPdf);
    }

    getMimetype(signature) {
        switch (signature) {
            case '89504E47':
                return 'image/png'
            case '47494638':
                return 'image/gif'
            case '25504446':
                return 'application/pdf'
            case 'FFD8FFDB':
            case 'FFD8FFE0':
                return 'image/jpeg'
            case '504B0304':
                return 'application/zip'
            case '564C4F53':
                return 'text/plain';//text/plain
            case 'FFD8FFE1':
                return 'image/jpeg'
            default:
                return 'Unknown filetype'
        }
    }

    base64ToArrayBuffer(base64) {
        console.log('called', base64);
        var binary_string = window.atob(base64);
        var len = binary_string.length;
        var bytes = new Uint8Array(len);
        for (var i = 0; i < len; i++) {
            bytes[i] = binary_string.charCodeAt(i);
        }
        console.log(bytes.buffer);
        return bytes.buffer;
    }

    get pdfHeight() {
        return 'height: ' + this.heightInRem + 'rem';
    }



    showToastMessage(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant
            })
        );
    }

}