import { LightningElement, api } from 'lwc';

export default class DayplanModal extends LightningElement {
    
   // @api accountId;

    connectedCallback() {
        console.log('selectedaccountId in the modal:', this.accountId);
    }
    
    handleSuccess() {
        // Opportunity creation success logic
        this.dispatchEvent(new CustomEvent('close'));
    }

    handleCancel() {
        // Handle cancel event, if needed
        this.dispatchEvent(new CustomEvent('close'));
    }
}