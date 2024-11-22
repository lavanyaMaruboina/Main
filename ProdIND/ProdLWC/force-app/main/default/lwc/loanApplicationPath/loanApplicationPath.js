import { LightningElement, api, wire } from "lwc";
import { getRecord } from "lightning/uiRecordApi";
import STAGE_FIELD from "@salesforce/schema/Opportunity.StageName";
import LEADSOURCE_FIELD from "@salesforce/schema/Opportunity.LeadSource";//D2C Swapnil
import ISPREAPROVED_FIELD from "@salesforce/schema/Opportunity.Is_Pre_Approved__c";//D2C Aman
import { ShowToastEvent } from "lightning/platformShowToastEvent";

export default class LoanApplicationPath extends LightningElement {
  @api recordId;
  @api currentStep;
  isPathHidden = false;
  leadSource = '';//D2C Swapnil
  stage;
  isPA;

  //D2C Swapnil
  get showPrePostInitialStep(){
    
    return (this.leadSource === 'D2C' && this.isPA === false) ;
  }
  get showPreapprovedStep(){
     return this.isPA;
  }

  @wire(getRecord, { recordId: "$recordId", fields: [STAGE_FIELD, LEADSOURCE_FIELD,ISPREAPROVED_FIELD] })
  wiredLoan({ data, error }) {
    if (data) {
      console.log(JSON.stringify(data))
      this.leadSource = data?.fields?.LeadSource?.value;//D2C Swapnil
      this.isPA = data?.fields?.Is_Pre_Approved__c?.value;//D2C Aman
      if (data?.fields?.StageName?.value === "Post Sanction Checks and Documentation") {
        this.currentStep = "post-sanction";
        this.stage='post-sanction';
      } else if (data?.fields?.StageName?.value === "Pre Disbursement Check") {
        this.currentStep = "pre-disbursement";
        this.stage='pre-disbursement';
      } else if (data?.fields?.StageName?.value === "Credit Processing") {
        this.currentStep = "credit-verification";
        this.stage='credit-verification';
      } else if(data?.fields?.StageName?.value === "Disbursement Request Preparation"){
        this.currentStep = "payment-requests";
        this.stage='payment-requests';
      } else {
        this.isPathHidden = true;
      }
    } else if (error) {
      console.log(" wiredLoan error " + error);
    }
  }

  handleStageChange(event) {
    const step = event.target.value;
    if (this.isStepValid(step)) {
      if (step === "credit-verification") {
        this.currentStep = "credit-verification";
        this.updateStep("credit-verification");
      } else if (step === "post-sanction") {
        this.currentStep = "post-sanction";
        this.updateStep("post-sanction");
      } else if (step === "pre-disbursement") {
        this.currentStep = "pre-disbursement";
        this.updateStep("pre-disbursement");
      }else if (step === "payment-requests") {
        this.currentStep = "payment-requests";
        this.updateStep("payment-requests");
      }//START D2C Changes Swapnil
      else if (step === "pre-initial-offer"){
        this.currentStep = step;
        this.updateStep(step);
      }else if (step === "post-initial-offer"){
        this.currentStep = step;
        this.updateStep(step);
      }
      //END D2C Changes Swapnil
      //START D2C Changes Aman
      else if (step === "pre-approved-offer"){
        this.currentStep = step;
        this.updateStep(step);
      }
      ////END D2C Changes Aman
    }
  }

  isStepValid(stepToNavigate) {
    let stepValid = true;
    if (this.stage === "credit-verification" && (stepToNavigate === "post-sanction" || stepToNavigate === "pre-disbursement" || stepToNavigate === "payment-requests")) {
      stepValid = false;
      this.showToast('Error','Cannot move to forward screen','error');
    } else if (this.stage === "post-sanction" && (stepToNavigate === "pre-disbursement" || stepToNavigate === "payment-requests")) {
      stepValid = false;
      this.showToast('Error','Cannot move to forward screen','error');
    } else if (this.stage === "pre-disbursement" && stepToNavigate === "payment-requests") {
      stepValid = false;
      this.showToast('Error','Cannot move to forward screen','error');
    }
    return stepValid;
  }

  updateStep(step) {
    const stepUpdate = new CustomEvent("updatestep", { detail: step });
    this.dispatchEvent(stepUpdate);
  }

  showToast(title, message, variant) {
    const event = new ShowToastEvent({
      title: title,
      message: message,
      variant: variant
    });
    this.dispatchEvent(event);
  }
}