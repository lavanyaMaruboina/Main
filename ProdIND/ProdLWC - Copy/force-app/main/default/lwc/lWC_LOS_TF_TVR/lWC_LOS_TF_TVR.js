import { LightningElement, track,wire,api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';	
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';

import getFieldsValue from '@salesforce/apex/lWC_LOS_TF_TVRController.getFieldsValue';
import getAssetList from '@salesforce/apex/lWC_LOS_TF_TVRController.getAssetList';
import getCoApplicantList from '@salesforce/apex/lWC_LOS_TF_TVRController.getCoApplicantList';
import getResidenceAddress from '@salesforce/apex/lWC_LOS_TF_TVRController.getResidenceAddress';
import saveTVR from '@salesforce/apex/lWC_LOS_TF_TVRController.saveTVR';

import TELEVERIFICATION_OBJECT from '@salesforce/schema/TeleVerification__c';
import APP_NO_VERIFICATION_FIELD from '@salesforce/schema/TeleVerification__c.Application_No_Verification__c';
import TVR_STATUS_FIELD from '@salesforce/schema/TeleVerification__c.TVR_Status__c';

import ASSET_DETAIL_VER_FIELD from '@salesforce/schema/TeleVerification__c.Asset_Details_Verification__c';
import COAPPLICANT_VER_FIELD from '@salesforce/schema/TeleVerification__c.CoApplicant_Verification__c';
import CUSTOMER_CURRENT_ADDRESS_VER_FIELD from '@salesforce/schema/TeleVerification__c.Customer_Current_Address_Verification__c';
import CUSTOMER_PERMANENT_ADDRESS_VER_FIELD from '@salesforce/schema/TeleVerification__c.Customer_Permanent_Address_Verification__c';
import TVR_STATUS_VER_FIELD from '@salesforce/schema/TeleVerification__c.TVR_Status__c';
import TVR_OBSERVATION_VER_FIELD from '@salesforce/schema/TeleVerification__c.TVR_Observation__c';
import MARGIN_MONEY_PAID_BY_VER_FIELD from '@salesforce/schema/TeleVerification__c.Margin_Money_Paid_by_Verification__c';
import MARGIN_MONEY_PAID_VER_FIELD from '@salesforce/schema/TeleVerification__c.Margin_Money_Paid_Verification__c';
const field = [MARGIN_MONEY_PAID_VER_FIELD, MARGIN_MONEY_PAID_BY_VER_FIELD, TVR_OBSERVATION_VER_FIELD, ASSET_DETAIL_VER_FIELD, COAPPLICANT_VER_FIELD, CUSTOMER_CURRENT_ADDRESS_VER_FIELD, CUSTOMER_PERMANENT_ADDRESS_VER_FIELD, TVR_STATUS_VER_FIELD];

export default class LWC_LOS_TF_TVR extends LightningElement {

    noCoApplicantMessage = "Co-Applicant are not available for this Applicant.";
    noAssetDetailsMessage = "Assets are not available for this Applicant.";

    @api recordId;

    @track isSpinner;

    @track permanentFilterList = [];
    @track currentFilterList = [];
    @track filterList = [];
    @track verificationList = [];
    @track assetDetailsLst = [];
    @track applicantLst = [];
    @track tvrStatusLst = [];

    assetTableHead = ['Make','Model','Invoice Price','Loan Amount','Tenure','CRM IRR','Installment Frequency','EMI Amount'];
    applicantTableHead = ['Name','Type','Relation'];


    
    @track picklistOptions = [];
    
    value = 'inProgress';

    connectedCallback(){
        this.isSpinner = false;
    }

    get isCoApplicantAvailable(){
        if(this.applicantLst.length > 0){
            return true;
        }

        return false;
    }

    get isAssetsAvailable(){
        if(this.assetDetailsLst.length > 0){
            return true;
        }

        return false;
    }

    Asset_Details_Verification_Value = '';
    CoApplicant_Verification_Value = '';
    Customer_Current_Address_Verification_Value = '';
    Customer_Permanent_Address_Verification_Value = '';
    Margin_Money_Paid_Verification_Value = '';
    Margin_Money_Paid_by_Verification_Value = '';
    TVR_Observation_Value = '';
    TVR_Status_Value = '';

    @wire(getRecord, {recordId:'$recordId',fields : field})
    fieldPopulated({data,error}){
        if (data) {
            console.log('AUTO Pupulated values '+JSON.stringify(data.fields.Asset_Details_Verification__c.value));
            this.Asset_Details_Verification_Value = data.fields.Asset_Details_Verification__c.value;
            this.CoApplicant_Verification_Value = data.fields.CoApplicant_Verification__c.value;
            this.Customer_Current_Address_Verification_Value = data.fields.Customer_Current_Address_Verification__c.value;
            this.Customer_Permanent_Address_Verification_Value = data.fields.Customer_Permanent_Address_Verification__c.value;
            this.Margin_Money_Paid_Verification_Value = data.fields.Margin_Money_Paid_Verification__c.value;
            this.Margin_Money_Paid_by_Verification_Value = data.fields.Margin_Money_Paid_by_Verification__c.value;
            this.TVR_Observation_Value = data.fields.TVR_Observation__c.value;
            this.TVR_Status_Value = data.fields.TVR_Status__c.value;
        }
        else if (error) {
            this.processErrorMessage(error);
        }   
    }

    renderedCallback(){
        if(!(this.TVR_Status_Value === '' || this.TVR_Status_Value === null || this.TVR_Status_Value === undefined)){
            this.disableALLInput();
        }
    }

    disableALLInput(){
        let inputFields = [...this.template.querySelectorAll('lightning-combobox')];
        inputFields = [...inputFields,...this.template.querySelectorAll('lightning-input')];
        inputFields = [...inputFields,...this.template.querySelectorAll('lightning-button')];
        
        inputFields.forEach(ele=>{
            ele.disabled = true; 
        });
    }

    @wire(getResidenceAddress, {tvrId: '$recordId', addressType: 'current'})
    currentResidenceDetails({ data, error }) {
        if (data) {
            console.log('currentResidenceDetails received >> '+JSON.stringify(data));
            this.currentFilterList = data;
        }
        else if (error) {
            this.processErrorMessage(error);
        }
    }

    @wire(getResidenceAddress, {tvrId: '$recordId', addressType: 'permanent'})
    permanentResidenceDetails({ data, error }) {
        if (data) {
            console.log('permanentResidenceDetails received >> '+JSON.stringify(data));
            this.permanentFilterList = data;
        }
        else if (error) {
            this.processErrorMessage(error);
        }
    }

    @wire(getFieldsValue, {tvrId: '$recordId'})
    fieldValues({ data, error }) {
        if (data) {
            console.log('Field wrapper received >> '+JSON.stringify(data));
            this.filterList = data;
            console.log('Field wrapper received >> '+JSON.stringify(this.filterList));
        }
        else if (error) {
            this.processErrorMessage(error);
        }
    }

    @wire(getAssetList, {tvrId: '$recordId'})
    assetDetails({ data, error }) {
        if (data) {
            console.log('Asset Details received >> '+JSON.stringify(data));
            this.assetDetailsLst = data;
        }
        else if (error) {
            this.processErrorMessage(error);
        }
    }

    @wire(getCoApplicantList, {tvrId: '$recordId'})
    coApplicantDetails({ data, error }) {
        if (data) {
            console.log('Field wrapper received >> '+JSON.stringify(data));
            this.applicantLst = data;
        }
        else if (error) {
            this.processErrorMessage(error);
        }
    }

    @wire(getObjectInfo, { objectApiName: TELEVERIFICATION_OBJECT })
    teleVerificationinfo;

    @wire(getPicklistValues, { recordTypeId: '$teleVerificationinfo.data.defaultRecordTypeId', fieldApiName: TVR_STATUS_FIELD })
    tvrStatusValues({ data, error }) {
        if (data) {
            data.values.forEach(val => {
                this.tvrStatusLst = [...this.tvrStatusLst, { value: val.value, label: val.label }];
            });
        }
        else if (error) {
            this.processErrorMessage(error);
        }
    }

    @wire(getPicklistValues, { recordTypeId: '$teleVerificationinfo.data.defaultRecordTypeId', fieldApiName: APP_NO_VERIFICATION_FIELD })
    picklistValues({ data, error }) {
        if (data) {
            data.values.forEach(val => {
                this.picklistOptions = [...this.picklistOptions, { value: val.value, label: val.label }];
            });
        }
        else if (error) {
            this.processErrorMessage(error);
        }
    }

    handleChange(event) {
        console.log('handleChangeValue : '+event.target.value);
        console.log('handleChangeName : '+event.currentTarget.dataset.name);
        let dataName = event.currentTarget.dataset.name;
        let dataValue = event.target.value;
        let present = this.verificationList.reduce((valid,current)=>{
            if(current.name == dataName){
                valid = true;   
            }
            return valid;
        },false);

        if(present){
            this.verificationList.forEach( curr => {
                if(curr.name == dataName){
                    curr.value = dataValue;
                }
            });
        }else{
            this.verificationList = [...this.verificationList,{ value: dataValue, name: dataName }];
        }
        console.log('VERIFICATION LIST >>> '+JSON.stringify(this.verificationList));
    }
    
    isInputValid() {
        let inputFields = [...this.template.querySelectorAll('lightning-combobox')];
        inputFields = [...inputFields,...this.template.querySelectorAll('lightning-input')];
        
        let valid = inputFields.reduce((validSoFar, inputField) => {
            if (!inputField.checkValidity()){
                inputField.reportValidity();
            }
            return validSoFar && inputField.checkValidity();
        }, true);

        return valid;
    }

    handleSubmit(event){

        if(!this.isInputValid()){
            return;
        }
        
        this.isSpinner = true;

        saveTVR({tvrList: this.verificationList , tvrId: this.recordId}).then(result => {
            console.log('Save Response : '+JSON.stringify(result));
            this.showToastMessage('success', 'Details Saved Successfully!!', 'Success');
            this.disableALLInput();
            this.isSpinner = false;
        }).catch(error => {
            this.processErrorMessage(error);
            this.isSpinner = false;
        });
    }

    processErrorMessage(message) {
        let errorMsg = '';
        if (message) {
            if (message.body) {
                if (Array.isArray(message.body)) {
                    errorMsg = message.body.map(e => e.message).join(', ');
                } else if (typeof message.body.message === 'string') {
                    errorMsg = message.body.message;
                }
            }
            else {
                errorMsg = message;
            }
        }
        this.showToastMessage('error', errorMsg, 'Error!');
    }

    showToastMessage(variant, message, title) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant
            })
        );
    }
}