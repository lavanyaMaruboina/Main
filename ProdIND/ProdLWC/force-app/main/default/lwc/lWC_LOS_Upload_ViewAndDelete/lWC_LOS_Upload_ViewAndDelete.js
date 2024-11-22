import { LightningElement,api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { deleteRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getProfileName from '@salesforce/apex/GenericUploadController.getProfileName';
import getContentVersion from '@salesforce/apex/GenericUploadController.getContentVersion';
import officeFrontView from '@salesforce/label/c.Office_Front_View';
import residentFrontView from '@salesforce/label/c.Residence_Front_View';
export default class LWC_LOS_Upload_ViewAndDelete extends NavigationMixin(LightningElement) {
    iscommunityuser;isPreview = false;converId;height = 32;
    @api documentName;
    @api listOfDocument; // use the format to pass data = {fileName:'', contentDocumentId : '', documentRecordId: ''}
    @api documentRecordId;
    @api  leadId;
    showTable = false;
    showLoading = false;
    showDone = true;
    dataList = [];
     columns = [
        { label: 'File Name', fieldName: 'fileName', wrapText : true,
            cellAttributes: { 
                iconName: { fieldName: 'icon' }, iconPosition: 'left' 
            }
        },
        { label: 'Preview', type:  'button', typeAttributes: { 
                label: 'Preview',  name: 'Preview',  variant: 'brand-outline',
                iconName: 'utility:preview', iconPosition: 'right'
            } 
        },
        { label: 'Delete', type:  'button', typeAttributes: { 
                label: 'Delete',   name: 'Delete',   variant: 'destructive',iconName: 'standard:record_delete', 
                iconPosition: 'right' 
            } 
        } 
    ];

    get acceptedFormats() {
        if(this.documentName == officeFrontView || this.documentName == residentFrontView){
            return ['.png','.jpeg'];
        }else{
            return ['.pdf', '.png','.jpeg'];
        }
    }
    
    connectedCallback() {

        console.log(this.documentName);
        console.log(this.documentRecordId);

        if(this.listOfDocument == null) {
                this.listOfDocument = [];
                this.dataList = this.listOfDocument;
                
        } else {
            this.dataList = this.listOfDocument;
            this.showTable = true;
        }
        getProfileName({ loanApplicationId: this.leadId })
        .then(result => {
            console.log('Result in generic upload ', result);
            if(result){
                this.iscommunityuser = result;
            }
        })
        .catch(error => {
            console.error('Error:', error);
        });
    }

    handleRowAction(event){

        const actionName = event.detail.action.name;
        const row = event.detail.row;
        switch (actionName) {
            case 'Preview':
                this.previewFile(row);
                break;
            case 'Delete':
                this.handleDeleteFiles(row);
                break;
            default:
        }

    }

    handleUploadFinished(event) {
console.log(JSON.stringify(event.detail.files));
       let fileRecords = [];
        if(event.detail.files.length > 0) {
           
            for(let index =0 ;index < event.detail.files.length ; index++) {
                    let fileData = {};
                    fileData['fileName'] = event.detail.files[index].name;
                    fileData['contentDocumentId'] = event.detail.files[index].documentId;
                    fileData['documentRecordId'] = this.documentRecordId;
                    fileRecords.push(fileData);
            }
        }
console.log('the file record' + JSON.stringify(fileRecords));
        if(fileRecords.length > 0) {
            console.log('enter');
            let finalList = this.dataList.concat(fileRecords);
            console.log('dikat');
            this.dataList = finalList;
        } 
        console.log('the dataList Value' + this.dataList);
        if(!this.showTable) {
            this.showTable = true;
        }
        this.showDone = false;
    }
    hideModalBox(){
        this.isPreview = false;
    }
    previewFile(file) {
        if(this.iscommunityuser == true){
            getContentVersion({ conDocId: file.contentDocumentId })
              .then(result => {
                console.log('Result', result); this.converId = result[0].Id;
                this.isPreview = true;
              })
              .catch(error => {
                console.error('Error:', error);
            });
        }else{
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'filePreview'
            },
            state : {
                selectedRecordId: file.contentDocumentId
            }
        });
     }
    }

    /*previewFile(file) {
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'filePreview'
            },
            state : {
                selectedRecordId: file.contentDocumentId
            }
        });
    }*/

    closeModel() {
            this.dispatchEvent(new CustomEvent('closemodel'));
            console.log('event is dispatch');
    }

    closeModelDone() {
        this.dispatchEvent(new CustomEvent('uploadsuccess'));
            console.log('event is dispatch');
    }

    handleDeleteFiles(file) {
        this.showLoading = true;
        deleteRecord(file.contentDocumentId)
        .then(() => {
            this.showLoading = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Record deleted successfully',
                    variant: 'success'
                })
            );
            // To delete the record from UI
            if(this.dataList.length > 0) {
                let finalDocAfterDelete = [];
            for(let opp of this.dataList){
                
                if(opp.contentDocumentId != file.contentDocumentId){
                    finalDocAfterDelete.push(opp);
                }
            }
            this.dataList = finalDocAfterDelete;
        }
            if(this.dataList.length == 0 ) {
                this.showTable = false;
                this.showDone = true;
            } else {
                this.dataList = this.dataList;
            }
           
        })
        .catch(error => {
            this.showLoading = false;
            console.log(error);
        });
    }
}