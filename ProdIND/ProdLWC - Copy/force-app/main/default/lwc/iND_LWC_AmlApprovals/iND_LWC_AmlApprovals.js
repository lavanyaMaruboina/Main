import { LightningElement, track, wire, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getAMLApprovals from '@salesforce/apex/AmlCheckData.getAMLApprovals';


export default class IND_LWC_AmlApprovals extends LightningElement {

    //fields = [ CA_Decision__c, CH_Decision__c, CMU_Decision__c ];
    @track amlapprovals = [];
    //async 
    connectedCallback() {
        getAMLApprovals({})
            .then(response => {
                console.debug(response);
                if (response) {
                    this.amlapprovals = response
                    for (let aml of this.amlapprovals) {
                        aml.camScreenURL = location.origin + '/apex/IBLCAMPage?id=' +
                            aml.camId + '&c_loanappid=' + aml.applicationId;
                    }
                }
            })
            .catch(error => {
                this.tryCatchError = error;
                console.debug(this.tryCatchError);
            });
    }
}