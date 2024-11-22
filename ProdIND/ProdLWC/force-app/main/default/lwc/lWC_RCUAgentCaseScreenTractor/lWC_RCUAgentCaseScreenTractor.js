import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';

import saveCaseDataToBackend from '@salesforce/apex/RCUCaseController.saveCaseDataToBackend';
import getRCUCaseDetails from '@salesforce/apex/RCUCaseController.getRCUCaseDetails';
import getSamplingReasonPicklist from '@salesforce/apex/RCUCaseController.getSamplingReasonPicklist';
import isAllDocumentsScreened from '@salesforce/apex/RCUCaseController.isAllDocumentsScreened';
import isResiDocumentUploaded from '@salesforce/apex/RCUCaseController.isResiDocumentUploaded';
import allDocumentSubmitted from '@salesforce/apex/RCUCaseController.allDocumentSubmitted';

import Case from '@salesforce/schema/Case';
import CaseId from '@salesforce/schema/Case.Id';
import Overall_RCU_Agency_Verification_Status from '@salesforce/schema/Case.Overall_RCU_Agency_Verification_Status__c';
import Overall_RCU_Agency_Verification_Remarks from '@salesforce/schema/Case.Overall_RCU_Agency_Verification_Remarks__c';
import Overall_RCU_Agency_Sampling_Reason from '@salesforce/schema/Case.Overall_RCU_Agency_Sampling_Reason__c';

import login from '@salesforce/apex/LightningLoginFormController.login';
import isCommunity from '@salesforce/apex/LwcLOSLoanApplicationCntrl.isCommunity';
import { NavigationMixin } from 'lightning/navigation';

export default class LWC_RCUAgentCaseScreenTractor extends NavigationMixin(LightningElement) {
    @track disableRCUAVS = false;
    @wire(getObjectInfo, { objectApiName: Case }) objectInfo;

    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: Overall_RCU_Agency_Verification_Status })
    async wiredObjectStatusInfo ({ error, data }) {
        if (error) {
            console.log('error-');
            const evt = new ShowToastEvent({
                title: 'Error',
                message: 'Error in fetching Documents details!',
                variant: 'error', 
            });
            this.dispatchEvent(evt);
        } else if (data) {
            let result = await isAllDocumentsScreened({'caseId' : this.recordId});
            let overAllRCUStatusOptions = [];
            overAllRCUStatusOptions = await data.values.filter(object => {
                    console.log('object.value-->'+object.value);
                    if (object.value !== 'Pending Approval' && object.value != 'Screened' && !result){
                        return object;
                    }else if(object.value == 'Screened' && result){
                        this.statusValue = 'Screened';
                        this.disableRCUAVS = true;
                        this.isRCUAgencySamplingRes = false;
                        return object;
                    }
            });
            console.log('overAllRCUStatusOptions-->'+overAllRCUStatusOptions);
            this.overAllRCUStatusOptionsList = overAllRCUStatusOptions;
        }
    }

    get overAllRCUStatusOptions() {
        return this.overAllRCUStatusOptionsList;
    }

    @track overAllRCUStatusOptionsList = [];
    @api recordId;
    @track statusValue = '';
    @track remarksValue = '';
    @track samplingReasonValue =[];
    @track disabledEveryThing = false;
    @track isShowSubmitButton = true;
    @track samplingReasonRequired = false;
    @track samplingReasonOption = [];
    @track isRCUAgencySamplingRes = false;
    renderedCallback(){
        if(this.disabledEveryThing){
            let allElements = this.template.querySelectorAll('*');
            allElements.forEach(element => element.disabled = true);
        }
    }

    async connectedCallback(){
        let result = await isAllDocumentsScreened({'caseId' : this.recordId});
        if(result){
            this.statusValue = 'Screened';
            this.disableRCUAVS = true;
            this.isRCUAgencySamplingRes = false;
            if(this.overAllRCUStatusOptionsList.length == 0){
                this.overAllRCUStatusOptionsList.push({label : 'Screened', value : 'Screened'});
            }
        }
        await getRCUCaseDetails({'recordId' : this.recordId}).then(result =>{
            if(result){
                if(result?.Status != 'In Progress' && result?.Owner?.Profile?.Name == 'IBL TF RCU Agent'){
                    this.disabledEveryThing = true;
                }
                if(!this.statusValue){
                    this.statusValue = result.Overall_RCU_Agency_Verification_Status__c ? result.Overall_RCU_Agency_Verification_Status__c : '';
                }
                if(this.statusValue == 'Negative' || this.statusValue == 'Non-clear Profile' || this.statusValue=='Non-clear Document' || this.statusValue == 'Failed'){
                    this.isRCUAgencySamplingRes = true;
                }
                if(this.statusValue == 'Screened'){
                    this.disableRCUAVS = true;
                    this.isRCUAgencySamplingRes = false;
                }
                this.remarksValue = result.Overall_RCU_Agency_Verification_Remarks__c ? result.Overall_RCU_Agency_Verification_Remarks__c : '';
            }
        }).catch(error => {
            const evt = new ShowToastEvent({
                title: 'Error',
                message: 'Error getting while fething the RCU Case data!',
                variant: 'error', 
            });
            this.dispatchEvent(evt);
        });

        await getSamplingReasonPicklist().then(res =>{
            if(res) {
                let picklistValue = Object.keys(res);
                let tempList = [];
    
                picklistValue.forEach(each=>{
                    tempList.push({value: each, label: res[each]})
                });
    
                this.samplingReasonOption = tempList;
            }
        })
    }

    handleChange(event) {
        if(event.target.name == 'RCUAgentStatus'){
            this.statusValue = event.target.value; 
           if(this.statusValue == 'Negative' || this.statusValue == 'Non-clear Profile' || this.statusValue=='Non-clear Document' || this.statusValue == 'Failed'){
                 this.isRCUAgencySamplingRes = true;
                  this.samplingReasonRequired = false;
                 if(this.statusValue == 'Negative'){
                      this.samplingReasonRequired = true;
                 }
            }
            else{
                this.samplingReasonRequired = false;
                this.isRCUAgencySamplingRes = false;
            }
        }
        if(event.target.name == 'RCUAgentRemarks'){
            this.remarksValue = event.target.value;
        }
        if(event.target.name == 'RCUAgentSamplingReason'){
            this.samplingReasonValue = event.target.value;
            console.log('samplingReasonValue '+this.samplingReasonValue);
        }

    }

    get selected() {
        return this.samplingReasonValue.length ? this.samplingReasonValue : 'none';
    }

    async saveData() {
        if(this.statusValue != 'Clear' && this.statusValue != 'Screened'){
            let samplingReason = this.template.querySelector('lightning-dual-listbox[data-id="samplingReason"]');
            samplingReason?.reportValidity();

            if(samplingReason?.validity?.valid == false){
                const evt = new ShowToastEvent({
                    title: 'Warning',
                    message: 'Please enter all mandatory fields!',
                    variant: 'warning', 
                });
               this.dispatchEvent(evt);
               return;
            }
        }
        if(!this.statusValue || !this.remarksValue){
            const evt = new ShowToastEvent({
                title: 'Warning',
                message: 'Please enter all mandatory fields!',
                variant: 'warning', 
            });
            this.dispatchEvent(evt);
            return;
        }
        let res = await allDocumentSubmitted({'caseId' : this.recordId});
        if(!res){
            const evt = new ShowToastEvent({
                title: 'Warning',
                message: 'Please select Verification Status for all Documents',
                variant: 'warning', 
            });
           this.dispatchEvent(evt);
           return;
        }
        let result = await isResiDocumentUploaded({'caseId' : this.recordId});
        if(!result){
            const evt = new ShowToastEvent({
                title: 'Warning',
                message: 'Resi profile document not submitted',
                variant: 'warning', 
            });
           this.dispatchEvent(evt);
           return;
        }
        let caseData = {};
        caseData[CaseId.fieldApiName]= this.recordId;
        caseData[Overall_RCU_Agency_Verification_Status.fieldApiName] = this.statusValue;
        caseData[Overall_RCU_Agency_Verification_Remarks.fieldApiName] = this.remarksValue;
        if(this.statusValue != 'Clear'){
             caseData[Overall_RCU_Agency_Sampling_Reason.fieldApiName] = this.samplingReasonValue.join(';');
        }

        console.log('caseData '+JSON.stringify(caseData));

        saveCaseDataToBackend({ 'recordId' : this.recordId, 'caseData' : JSON.stringify(caseData)})
            .then(result => {

                console.log(' result '+result);
                if(result != 'Case Submitted Successfully!'){
                    const evt = new ShowToastEvent({
                        title: 'Warning',
                        message: result,
                        variant: 'warning', 
                    });
                    this.dispatchEvent(evt);
                }else if(result == 'Case Submitted Successfully!'){
                    const evt = new ShowToastEvent({
                        title: 'SUCESS!',
                        message: result,
                        variant: 'success', 
                    });
                    this.dispatchEvent(evt);
                    this.disabledEveryThing = true;
                    this.renderedCallback();
                    this.navigateToHomePage();
                }
            }).catch(error => {
                console.log('Error '+JSON.stringify(error));
                const evt = new ShowToastEvent({
                    title: 'error',
                    message: error.body.message,
                    variant: 'error', 
                });
                this.dispatchEvent(evt);
            });
    }
    navigateToHomePage() {
        isCommunity()
            .then(response => {
                if (response) {
                    this[NavigationMixin.Navigate]({
                        type: 'standard__namedPage',
                        attributes: {
                            pageName: 'home'
                        },
                    });
                } else {
                    this[NavigationMixin.Navigate]({
                        type: 'standard__navItemPage',
                        attributes: {
                            apiName: 'Home'
                        }
                    });
                }
            })
            .catch(error => {
            });

    }
}