import { LightningElement, api } from 'lwc';
import LightningModal from "lightning/modal";

export default class ModalComponent extends LightningElement {
    @api selectedRecords;

    handleCloseModal() {
        // Close the modal
        const closeModalEvent = new CustomEvent('closemodal');
        this.dispatchEvent(closeModalEvent);
    }
}