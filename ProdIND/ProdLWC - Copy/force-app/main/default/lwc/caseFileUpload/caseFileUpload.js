import { LightningElement,api,track } from 'lwc';
import fetchFiles from '@salesforce/apex/Fileuploadcttrl.fetchFiles';
import { NavigationMixin } from 'lightning/navigation';
import deleteFile from '@salesforce/apex/Fileuploadcttrl.deleteFile';
export default class CaseFileUpload extends NavigationMixin(LightningElement) {
    @api recordId;
    @track lstAllFiles;
    @track error;
    get acceptedFormats() {
        return ['.pdf','.png','.jpg'];
    }
 
    handleUploadFinished(event) {
        this.connectedCallback();
    }
 
    connectedCallback() {
        console.log('in connect call : ',);
       this.fetchFilesData();

    }
    fetchFilesData(){
        fetchFiles({recordId:this.recordId})
        .then(result=>{
            console.log('result : ',result);
            this.lstAllFiles = result; 
            this.error = undefined;
        }).catch(error=>{
            this.lstAllFiles = undefined; 
            this.error = error;
        })
    }
    previewFile(event){
        let conDocId = event.target.value;
        console.log('OUTPUT conDocId: ',conDocId);
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'filePreview'
            },
            state: {
                selectedRecordId: conDocId
            }
        });
    }
    deleteRow(event){
        console.log('event.target : ',event.target);
        let deleteRow = event.target.value;
        console.log('OUTPUT deleteRow: ',deleteRow);
        deleteFile({ recordId:deleteRow })
          .then(result => {
            console.log('Result', result);
            this.fetchFilesData();
          })
          .catch(error => {
            console.error('Error:', error);
        });
    }
}