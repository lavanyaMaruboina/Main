import { LightningElement, api } from 'lwc';

export default class Customalert extends LightningElement {
    @api message;

    handleOk() {
        this.dispatchEvent(new CustomEvent('close'));
    }

    handleClone() {
        this.dispatchEvent(new CustomEvent('clone'));
    }

    handleClose() {
        this.dispatchEvent(new CustomEvent('close'));
    }
}