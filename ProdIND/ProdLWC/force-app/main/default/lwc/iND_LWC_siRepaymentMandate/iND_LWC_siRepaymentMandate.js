import {LightningElement, wire , track,api} from 'lwc';
import {updateRecord} from 'lightning/uiRecordApi';
import RECORD_TYPE_FIELD from "@salesforce/schema/Repayments__c.RecordTypeId";
import ID_FIELD from "@salesforce/schema/Repayments__c.Id";
import REPAYMENTS_OBJECT from "@salesforce/schema/Repayments__c";
import {getObjectInfo} from "lightning/uiObjectInfoApi";
import isCheckReadOnly from '@salesforce/apex/RepaymentScreenController.isCheckReadOnly';
//Modified for D2C by Rohan
import { getRecord } from 'lightning/uiRecordApi';
import OPP_LEAD_SORCE from '@salesforce/schema/Opportunity.LeadSource';
//End of D2C Code
export default class IND_LWC_siRepaymentMandate extends LightningElement {
    @api currentStep;
    @track initiationOption;
    @track accordionActiveSection = '';
    @track initiationMethod;
    @track onlineFlag = false;
    @track offlineFlag = false;
    @api siMethod;
    @api repaymentId;
    @api recordId;
    @api applicantId;
    boolSubmitDisbaleD2C=false; //D2C modification 
    isDisabledInitiateMethod;
    
    @wire(getObjectInfo, { objectApiName: REPAYMENTS_OBJECT })
    objectInfo;

    //Added for D2C
    @wire(getRecord, { recordId: '$recordId', fields: [OPP_LEAD_SORCE] })
    opportunity({ error, data }) {
        if (data) {
            this.boolSubmitDisbaleD2C = data.fields.LeadSource.value === 'D2C' ? true : false;
            console.log('this.boolSubmitDisbaleD2C -->'+this.boolSubmitDisbaleD2C);
            var initiationOptionList = new Array();
            if(this.boolSubmitDisbaleD2C===true){
                console.log('here in true');
                initiationOptionList.push({ label: 'SI Online', value: 'SI Online' });
            }
            else{
                console.log('here in false');
                initiationOptionList.push({ label: 'SI Online', value: 'SI Online' });
                initiationOptionList.push({ label: 'SI Offline', value: 'SI Offline' });
            }
            this.initiationOption = initiationOptionList;
            this.initiationMethod=this.siMethod;//Set from parent, on load
            if (this.initiationMethod === 'SI Online') {
                this.onlineFlag = true;
                this.offlineFlag = false;
                this.accordionActiveSection = "online";
            }
            if (this.initiationMethod === 'SI Offline') {
                this.offlineFlag = true;
                this.onlineFlag = false;
                this.accordionActiveSection = "offline";
            }
        } else if (error) {
            console.log('error-->' + JSON.stringify(error));
        }
    }
    //end of D2C code

    //@track recordId;
    connectedCallback() {
        var initiationOptionList = new Array();
        initiationOptionList.push({ label: 'SI Online', value: 'SI Online' });
        initiationOptionList.push({ label: 'SI Offline', value: 'SI Offline' });
        this.initiationOption = initiationOptionList;
        this.initiationMethod=this.siMethod;//Set from parent, on load
        if (this.initiationMethod === 'SI Online') {
            this.onlineFlag = true;
            this.offlineFlag = false;
            this.accordionActiveSection = "online";
        }
        if (this.initiationMethod === 'SI Offline') {
            this.offlineFlag = true;
            this.onlineFlag = false;
            this.accordionActiveSection = "offline";
        }
        //console.log('-->'+this.recordId);
        isCheckReadOnly({loanApplicationId : this.recordId}).then(result=>{
            this.isDisabledInitiateMethod = result.isCheckReadOnly;
            if( result.stageName == 'Pre Disbursement Check'){
                this.isDisabledInitiateMethod = true;
            }
            if(this.currentStep == 'post-sanction' && result.stageName == 'Pre Disbursement Check'){
              this.isDisabledInitiateMethod = true;
            }
        }).catch(error=>{
          console.error('error 161 ',error);
        });
        if(this.isRevokedLoanApplication){this.disableEverything();}//CISP-2735
    }
    renderedCallback(){
      if(this.isRevokedLoanApplication){this.disableEverything();}//CISP-2735
    }
    disableEverything(){
        let allElements = this.template.querySelectorAll('*');
        allElements.forEach(element =>
            element.disabled = true
        );
    }
    @api isRevokedLoanApplication;//CISP-2735
    //CISP-2735-END

    handleInputFieldChange() {

    }
    async handleInitiationChange(event) {
        try{
            this.initiationMethod = event.target.value;
            await this.updateRecordDetails();
            if (this.initiationMethod === 'SI Online') {
                this.onlineFlag = true;
                this.offlineFlag = false;
                this.accordionActiveSection = "online";
            }
            if (this.initiationMethod === 'SI Offline') {
                this.offlineFlag = true;
                this.onlineFlag = false;
                this.accordionActiveSection = "offline";
            }
        }catch(e){
            console.log(e);
        }
        //this.updateRecordDetails();
    }
    updateRecordDetails() {
        const fields = {};
        fields[ID_FIELD.fieldApiName] = this.repaymentId;
        fields[RECORD_TYPE_FIELD.fieldApiName] = this.getRecordTypeId(this.initiationMethod);
        const recordInput={fields};
        return updateRecord(recordInput);
    }
    getRecordTypeId(recordTypeName) {
        let recordtypeinfo = this.objectInfo.data.recordTypeInfos;
        let recordTypeId;
        for (let eachRecordtype in this.objectInfo.data.recordTypeInfos) {
          if (recordtypeinfo[eachRecordtype].name === recordTypeName) {
            recordTypeId = recordtypeinfo[eachRecordtype].recordTypeId;
            break;
          }
        }
        return recordTypeId;
      }

      disableInitiationEventHandler(event) {
        this.isDisabledInitiateMethod = true;
      }
}