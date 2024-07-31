import { LightningElement } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class SampleComponent extends LightningElement {
    handleSuccess(event) {
        const evt = new ShowToastEvent({
            title: "Record Created",
            message: "Record ID: " + event.detail.id,
            variant: "success",
        });
        this.dispatchEvent(evt);
    }
}