import { LightningElement, api } from "lwc";
 
export default class Dsa_iblModal extends LightningElement {
    @api header;
    @api message;

    handleConfirm() {
        this.dispatchEvent(new CustomEvent("confirm"));
    }

    handleCancel() {
        this.dispatchEvent(new CustomEvent("cancel"));
    }
}