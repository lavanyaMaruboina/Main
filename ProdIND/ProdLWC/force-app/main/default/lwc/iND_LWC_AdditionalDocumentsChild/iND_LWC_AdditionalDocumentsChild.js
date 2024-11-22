import { LightningElement, api,track,wire } from 'lwc';
import Remark from "@salesforce/schema/Opportunity.IND_Remark__c";
import Not_Provided_Documents from "@salesforce/schema/Opportunity.IND_Not_Provided_Documents__c";
import OPP_ID_FIELD from "@salesforce/schema/Opportunity.Id";
import { updateRecord, getRecord } from "lightning/uiRecordApi";
import Dealnumber_ID_FIELD from "@salesforce/schema/Deal_Number__c.Id";
import DealRemark from "@salesforce/schema/Deal_Number__c.IND_Remark__c";
import DealNot_Provided_Documents from "@salesforce/schema/Deal_Number__c.Not_Provided_Documents__c";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getAdditionalData from '@salesforce/apex/AdditionalDocumentsClass.getAdditionalData';
export default class IND_LWC_AdditionalDocumentsChild extends LightningElement {
    docOptions =  [{ label: 'Yes', value: 'Yes' },{ label: 'No', value: 'No' }];

    @api recordId;
    remark;
    @api dealId;
    notProvidedDoc;
    notProvidedocdisabled = false;
    remarkdisabled =false;
    isSubmitDisabled= false;

    @wire(getRecord, { recordId: '$recordId', fields: [Not_Provided_Documents, Remark]})
    LoanApp({ error, data }) {
     if (data) {
            this.remark = data.fields.IND_Remark__c.value;
            this.notProvidedDoc = data.fields.IND_Not_Provided_Documents__c.value;
        }
    }
connectedCallback(){
     getAdditionalData({ loanApplicationId: this.recordId , dealId: this.dealId }).then(result => {
        let data = JSON.parse(result);
             if(data.additionalPreHistory){
                this.disableAll(data.additionalPreHistory);
             }
             if(this.productType == 'Tractor' && data.dealDetail[0]){
                this.remark = data.dealDetail[0].IND_Remark__c ? data.dealDetail[0].IND_Remark__c : '';
                this.notProvidedDoc = data.dealDetail[0].Not_Provided_Documents__c ? data.dealDetail[0].Not_Provided_Documents__c : '';
             }
     });
}

    handleInputFieldChange(event){
        if(event.target.name == 'Not Provided Documents'){
            this.notProvidedDoc=event.target.value;
        }
        if(event.target.name == 'IND_Remark'){
            this.remark=event.target.value;
        }
    }

    disableAll(val) {
        this.notProvidedocdisabled = val;
        this.remarkdisabled = val;
        this.isSubmitDisabled = val;
    }
    
    handleSubmit(){
        const LoanApplication = {};
        const Dealnumber = {};
        if(this.remark && this.notProvidedDoc && this.productType == 'Tractor'){
            Dealnumber[Dealnumber_ID_FIELD.fieldApiName] = this.dealId;
            Dealnumber[DealRemark.fieldApiName] = this.remark;
            Dealnumber[DealNot_Provided_Documents.fieldApiName] = this.notProvidedDoc;
            this.updateRecordDetails(Dealnumber);
            this.disableAll(true);
        }
        else if(this.remark && this.notProvidedDoc){
            LoanApplication[OPP_ID_FIELD.fieldApiName] = this.recordId;
            LoanApplication[Remark.fieldApiName] = this.remark;
            LoanApplication[Not_Provided_Documents.fieldApiName] = this.notProvidedDoc;
            this.updateRecordDetails(LoanApplication);
            this.disableAll(true);
        }
        else{
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Please enter the field details',
                    variant: 'error',
                }),
            );
        }
    }
    async updateRecordDetails(fields) {
        const recordInput = { fields };
        await updateRecord(recordInput)
            .then(() => {
                const disableSubmit = new CustomEvent('disablesubmit',{detail: false});
        this.dispatchEvent(disableSubmit);
                console.log("record update success", JSON.stringify(fields)); //keeping for reference
            })
            .catch((error) => {
                console.log("error in record update =>",JSON.stringify(error));
            });
    }
}