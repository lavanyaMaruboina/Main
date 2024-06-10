// HarvestRecordForm.js
import { LightningElement, track } from 'lwc';
//import createHarvest from '@salesforce/apex/ContactController.createHarvest';

export default class HarvestRecordForm extends LightningElement {
    @track contactId; 

     contactId;
    handleSuccess(event) {
        this.contactId = event.detail.id;
    }

     handleContactChange1(event) {
        this.contactId = event.detail.value[0];
        console.log('Contact Id >>>>>', this.contactId);
    }

    resetForm() {
        this.name = '';
        this.stocking = '';
        this.cumfeed = '';
        this.lastweek = '';
    }
}