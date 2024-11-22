import { LightningElement, wire, track, api } from 'lwc';
import { NavigationMixin } from "lightning/navigation";
import uploadDocument from '@salesforce/apex/IND_DSAController.uploadDocumentCntrl';
import getContentversion from '@salesforce/apex/IND_DSAController.getContentVersion';
import deleteContentDocument from '@salesforce/apex/IND_DSAController.deleteContentDocument';
import getDocumentRecords from '@salesforce/apex/IND_DSAController.getDcoumentRecords';
import Id from '@salesforce/user/Id';
import DSACommunityUrl from '@salesforce/label/c.IND_DSA_Community_URL';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

// Static object to display on table along with dynamic class property 
const docType = [
    {
        name: "Foreclosure Letter",
        className: "slds-hide"
    },
    {
        name: "Form 29",
        className: "slds-hide"
    },
    {
        name: "Form 30",
        className: "slds-hide"
    },
    {
        name: "Update RC Document(Original)",
        className: 'slds-hide'
    },
    {
        name: "Insurance Document Upload(Original)",
        className: 'slds-hide'
    },
    {
        name: "Buyer-Seller Agreement",
        className: "slds-hide"
    }

];
//Defining constants
const commType = "comm__namedPage";
const pageName = "disbursedleads__c";
const loanintr = 6;
const applicantcol1intr = 12;
const applicantcol2intr = 30;
const uploadMessage='Are you sure you want to change the document? Your previous document will be removed';
const deleteMessage='Are you sure you want to delete the document?';

export default class IND_post_sanction_document extends NavigationMixin(LightningElement) {
    url = window.location.href;
    loanApplicationid = this.url.substring(this.url.lastIndexOf('Oppid=') + loanintr);
    applicantid = this.url.substring(this.url.lastIndexOf('applicantid=') + applicantcol1intr, this.url.lastIndexOf('applicantid=') + applicantcol2intr);
    documentRecordId;
    docType = docType;
    selectedDocType;
    records = [];
    preview = false;
    docImage;
    docRecords = '';
    userId = Id;
    countClickBtn=0;
    communityPartnersURL = DSACommunityUrl
    uploadMessage=uploadMessage;
    deleteMessage=deleteMessage;

    get acceptedFormats() {
        return ['.jpg', '.png', '.jpeg', '.docx', '.pdf'];
    }
    connectedCallback() {
        this.showDocumentStatus();
    }
    showDocumentStatus() {
        getDocumentRecords({ loanApplication: this.loanApplicationid, applicant: this.applicantid })
            .then(result => {
                //To show the upload message below upload button
                const showUploadResult = this.docType.map((row) => {
                    let classname = row.className;
                    let fieldname = row.name;
                    if (result.includes(row.name)) {
                        classname = 'slds';
                    } else {
                        classname = 'slds-hide';
                    }
                    return {
                        name: fieldname, className: classname,
                    }
                });
                this.docType = showUploadResult;
            }).catch(error => {

            });
    }
    //function to retur from post sanction to disbursed lead
    handleReturn(event) {
        this[NavigationMixin.Navigate]({
            type: commType,
            attributes: {
                name: pageName
            }
        });
    }
    handleClick(event) {
        this.selectedDocType = event.target.dataset.targetId;
        this.countClickBtn++;
        console.log(this.countClickBtn%2==0);
        if(this.countClickBtn%2==0 && event.target.dataset.name==='slds'){
        if (confirm(this.uploadMessage) == true) {
            console.log('true');
          } else {
            console.log('false');
            event.preventDefault();
          }
    }
    }
    handleDrop(event){
   /* console.log('inside drop');
    confirm('sure2??');
    event.preventDefault();
    window.location.reload();
    */
        
    }
    handleUploadFinished(event) {
        const uploadedFiles = event.detail.files;
        uploadDocument({ docType: this.selectedDocType, loanApplication: this.loanApplicationid, applicant: this.applicantid, active: true, contentDocId: uploadedFiles[0].documentId, userId: this.userId })
            .then(result => {
                if (result === 'success') {
                    this.showToast('Upload Document', 'success', 'Document Uploaded Successfully');
                    this.showDocumentStatus();
                }
                else if (result === 'Not Authorized') {
                    this.showToast('Upload Document', 'Warning', 'Not Authorized to Upload Document');
                }
            }
            ).catch(error => {
                this.showToast('upload document', 'error', 'Something Went Wrong');
            });
    }
    showfile(event) {
        getContentversion({ loanApplication: this.loanApplicationid, applicant: this.applicantid, DocType: event.target.dataset.targetId })
            .then(result => {
                if (result != null) {
                    let fileType = result[0].FileType;
                    console.log('url : ', this.communityPartnersURL + '/sfc/servlet.shepherd/version/renditionDownload?rendition=ORIGINAL_'+fileType+'&versionId=' + result[0].Id);
                    this.docImage = this.communityPartnersURL + '/sfc/servlet.shepherd/version/renditionDownload?rendition=ORIGINAL_'+fileType+'&versionId=' + result[0].Id;
                    this[NavigationMixin.Navigate]({
                        type: 'standard__webPage',
                        attributes: {
                            url: this.communityPartnersURL + '/sfc/servlet.shepherd/version/renditionDownload?rendition=THUMB720BY480&versionId=' + result[0].Id
                        }
                    }, false);
                    this.preview = true;

                }
                else {
                    this.showToast('Show Document', 'Warning', 'No Data to Show');
                }
            })
            .catch(error => {
                this.showToast('Upload Document', 'error', 'Something Went Wrong');
                console.error('Error:', error.message);
            });
    }
    deleteFile(event) {
        if(event.target.dataset.name==='slds'){
            if (confirm(this.deleteMessage) == true) {
                deleteContentDocument({ loanApplication: this.loanApplicationid, applicant: this.applicantid, DocType: event.target.dataset.targetId, userId: this.userId })
            .then(result => {
                if (result === 'Deleted') {
                    this.showToast('Delete Document', 'error', 'Document Deleted Successfully');
                    this.showDocumentStatus();
                }
                else if (result === 'no data') {
                    this.showToast('Delete Document', 'Warning', 'No Data to delete');
                }
                else if (result === 'Not Authorized') {
                    this.showToast('Delete Document', 'Warning', 'Not Authorized to Delete');
                }
            })
            .catch(error => {
                this.showToast('upload document', 'error', 'Something Went Wrong');
                console.error('Error:', error);
            });
              } 
        }
        else{
            this.showToast('Delete Document', 'Warning', 'No Data to delete');
          }
        
    }
    showToast(title, variant, message) {
        const event = new ShowToastEvent({
            title: title,
            variant: variant,
            message: message,
        });
        this.dispatchEvent(event);
    }
    handleModal() {
        this.preview = false;
    }
}