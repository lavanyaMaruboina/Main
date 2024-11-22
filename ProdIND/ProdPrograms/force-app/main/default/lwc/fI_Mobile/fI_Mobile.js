import { LightningElement,track,api } from 'lwc';
import getUserRole from '@salesforce/apex/OfficeFiClass.getUserRole';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class FI_Mobile extends LightningElement {
    //Boolean tracked variable to indicate if modal is open or not default value is false as modal is closed when page is loaded 
    @track isModalOpen = false;
    @api recordId;
    @track isVisible = true;

     async connectedCallback(){
        console.log('record Id in connect callback', this.recordId);
        getUserRole({caseId: this.recordId
        }
        ).then(result => {
            // return record.Name;
            console.log("Inside then", result );
            if(result == false){
                this.isVisible = false;
            }else{
                this.isVisible = true;
            }
            console.log("this.isVisible", this.isVisible );

        }).catch(error => {
            console.log('error::',error);
            const evt = new ShowToastEvent({
                title: Error,
                message: 'Something went wrong, please contact your admin!',
                variant: 'error',
                mode: 'sticky'
            });
            this.dispatchEvent(evt);
        });
    }

    openModal() {
        // to open modal set isModalOpen tarck value as true
        this.isModalOpen = true;
    }
    closeModal() {
        // to close modal set isModalOpen tarck value as false
        this.isModalOpen = false;
    }
    submitDetails() {
        // to close modal set isModalOpen tarck value as false
        //Add your code to call apex method or do some processing
        this.isModalOpen = false;
    }
}