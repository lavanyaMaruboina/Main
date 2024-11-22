import { LightningElement,api, track } from 'lwc';

export default class IND_FI_Mobile extends LightningElement {
    @api recordId;
    @track showModal = false;

    openModal(){
        this.showModal = true;
    }

    closeModal(){
        this.showModal = false;
    }
}