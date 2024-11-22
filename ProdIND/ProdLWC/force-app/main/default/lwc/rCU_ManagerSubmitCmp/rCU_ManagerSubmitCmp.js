import { LightningElement,api,track,wire } from 'lwc';
import { CloseActionScreenEvent } from "lightning/actions";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import updateCaseStatus from '@salesforce/apex/RCUCaseController.updateCaseStatus'; 

import CASE_ID from "@salesforce/schema/Case.Id";
import CASE_STATUS from '@salesforce/schema/Case.Status';
import {updateRecord } from 'lightning/uiRecordApi';

import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import STATUS_FIELD from "@salesforce/schema/Case.Status";
import Overall_RCU_Verification_Status from "@salesforce/schema/Case.Overall_RCU_Verification_Status__c";

const fields =  [STATUS_FIELD, Overall_RCU_Verification_Status];

export default class RCU_ManagerSubmitCmp extends LightningElement {

    @api objectApiName = 'Case';
    @track isSpining =false;
    @api recordId;

    @track isDisabledRCUSampling = true;

    @wire(getRecord, { recordId: "$recordId", fields })
    case;

    get status() {
        return getFieldValue(this.case.data, STATUS_FIELD);
    }

    connectedCallback(){
        let response = getFieldValue(this.case.data, Overall_RCU_Verification_Status);
        if(response = 'Negative'){
            this.isDisabledRCUSampling = false;
        }
    }

   async handleSuccess(event){
        event.preventDefault();
        const fields = {};
        fields[CASE_ID.fieldApiName] = this.recordId;
        await updateCaseStatus({recordId: this.recordId}).then(result =>{
            if(result == 'RCU Case approval sent to SCM/NCM'){
                this.dispatchEvent(
                    new ShowToastEvent({
                    title: "Success",
                    message: "RCU Case approval sent to SCM/NCM successfully!",
                    variant: "success"
                   })
                );    
            }
            else if(result == 'reject'){
                fields[CASE_STATUS.fieldApiName] = 'Rejected';
                let recordInput ={fields};
                updateRecord(recordInput).then(()=>{
                    this.dispatchEvent(
                        new ShowToastEvent({
                        title: "Success",
                        message: "Record Successfully updated!",
                        variant: "success"
                        })
                    );
                });
            }
            else if(result == 'success'){
                fields[CASE_STATUS.fieldApiName] = 'Closed';
                let recordInput ={fields};
                updateRecord(recordInput).then(()=>{
                    this.dispatchEvent(
                        new ShowToastEvent({
                        title: "Success",
                        message: "Record Successfully updated!",
                        variant: "success"
                        })
                    );
                });
            }
            else if(result == 'No Child Case Exist'){
                    if(this.status != 'Resolved'){
                        this.dispatchEvent(
                        new ShowToastEvent({
                        title: "Error",
                        message: "Case Status is Pending Approval! You cannot submit this case.",
                        variant: "Error"
                        })
                    );
                }
            else{
                this.dispatchEvent(
                    new ShowToastEvent({
                      title: "Info",
                      message: "Reject or Accept the child Cases first",
                      variant: "info"
                    })
                 );
                }
            }
        }).catch(error =>{
            this.isSpining=false;
            this.dispatchEvent(
                new ShowToastEvent({
                  title: "error",
                  message: error.body.message,
                  variant: "error"
                })
            );
        });
        this.isSpining=false;
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    async handleClick(event){
        this.isSpining= true;
        let element = this.template.querySelector(`lightning-input-field[data-name="Overall_RCU_Sampling_Reason__c"]`);
        let eleRCUStatus = this.template.querySelector(`lightning-input-field[data-name="Overall_RCU_Verification_Status__c"]`); 
        let eleRCURemarks = this.template.querySelector(`lightning-input-field[data-name="Overall_RCU_Verification_Remarks__c"]`); 

        if(eleRCUStatus && !eleRCUStatus.value){
            this.validationCheck("Overall RCU Verification Status field is mandatory!");
            this.isSpining = false;
                return;
        }
        if(eleRCURemarks && !eleRCURemarks.value){
                this.validationCheck("Overall RCU Verification Remarks field is mandatory!")
                this.isSpining = false;
                return;
        }
        if(!this.isDisabledRCUSampling && element && !element.value){
            this.validationCheck("Overall RCU Sampling Reason field is mandatory!")
            this.isSpining = false;
            return;
        }else{
            const fields = {};
            await this.template.querySelectorAll(`lightning-input-field`).forEach((input) => {
                if(input.fieldName == 'Overall_RCU_Sampling_Reason__c' && !this.isDisabledRCUSampling){
                    fields[input.fieldName] = input.value;
                }else{
                    fields[input.fieldName] = input.value;
                }
            });
            this.template.querySelector("lightning-record-edit-form").submit(fields);
        }
    }
    validationCheck(validationMsg){
        this.dispatchEvent(new ShowToastEvent({title: "Warning",message: validationMsg,variant: "warning"}));
    }
    inputHandler(event){
        if(event.target.fieldName == 'Overall_RCU_Verification_Status__c' && event.target.value == 'Negative'){
            this.isDisabledRCUSampling = false;
        }else if(event.target.fieldName == 'Overall_RCU_Verification_Status__c' && event.target.value != 'Negative'){
            this.isDisabledRCUSampling = true;
        }
    }
}