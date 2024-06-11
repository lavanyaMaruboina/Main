import { api, LightningElement, wire, track } from 'lwc';
import { getRecord, updateRecord, getFieldValue } from 'lightning/uiRecordApi';
import handleCTICall from '@salesforce/apex/CTIServiceConsumer.handleCTICall';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';


export default class callUsingCTIComp extends LightningElement {

    @api recordId;
    @api objectApiName;
    callUsingCTI(event) {
        console.log('Inside callCTI ');
        handleCTICall({ recordID: this.recordId })
            .then(resp => {
                console.log('Before :::response received as it is ::::', resp.isSaved+':::::'+resp.message);                            
                if (resp.isSaved == 'Y') {
                    console.log('Inside Y');
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'Connection Established.',
                            variant: 'success'
                        })
                    )
                } else if (resp.isSaved == 'N') {
                    console.log('Inside N');
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error Connecting.',
                            message: 'Connection Not Established --'+resp.message,
                            variant: 'error'
                        })
                    )
                }
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
            });
    }
}