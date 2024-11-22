import { LightningElement,wire } from 'lwc';
import { subscribe, MessageContext } from 'lightning/messageService';
import COUNT_UPDATED_CHANNEL from '@salesforce/messageChannel/Count_Updated__c';
export default class LWC_LOS_AddressProofUpload extends LightningElement {


    //to close the  pop up
    addpopup = false;
    closepopup() {
        this.addpopup = true;
        this.dispatchEvent(new CustomEvent('changeflagvalue'));//Custom event to chang flag value
    }

    value="";

    @wire(MessageContext)
    messageContext;
    subscribeToMessageChannel() {
        this.subscription = subscribe(
        this.messageContext,
        COUNT_UPDATED_CHANNEL,
        (message) => this.handleMessage(message)
        );
    }
    handleMessage(message) {
        this.priorCount = this.counter;
    if(message.operator == 'send') {
            this.docType = message.constant;
        } 
    }
    connectedCallback() {
        this.subscribeToMessageChannel();
    }

    getApplicantName(){

    }

    getDocumentType(){

    }

    AddressProofUpload(){
        

    }
}