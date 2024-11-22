import { LightningElement, api, wire } from 'lwc';

import { updateRecord } from 'lightning/uiRecordApi';
import OPP_ID_FIELD from '@salesforce/schema/Opportunity.Id';
import SUBSTAGENAME from '@salesforce/schema/Opportunity.Sub_Stage__c';
export default class NextButtonFinalTerms extends LightningElement {
    @api recordId;


    moveToNextSubstage(){
        const oppFields={};
        oppFields[OPP_ID_FIELD.fieldApiName]=this.recordId;
        oppFields[SUBSTAGENAME.fieldApiName]='Insurance';
        const recordInput={ fields: oppFields };
        updateRecord(recordInput)
            .then(() => {window.location.reload(); });
    }
}