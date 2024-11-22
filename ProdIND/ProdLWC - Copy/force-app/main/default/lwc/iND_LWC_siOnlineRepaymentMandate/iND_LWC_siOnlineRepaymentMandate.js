import { LightningElement, api, wire } from "lwc"; 
import getSIUrl from "@salesforce/apex/IND_SI_Controller.getSIUrl";
import doSIStatusAsyncCallout from "@salesforce/apex/IntegrationEngine.doSIStatusAsyncCallout"
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import URL_FIELD from "@salesforce/schema/Repayments__c.URL__c";
import { getRecord, updateRecord } from "lightning/uiRecordApi";
import { getObjectInfo, getPicklistValues } from "lightning/uiObjectInfoApi";
import REPAYMENTS_OBJECT from "@salesforce/schema/Repayments__c";
import ID_FIELD from "@salesforce/schema/Repayments__c.Id";
import APPLICANT_NAME_FIELD from "@salesforce/schema/Applicant__c.Name";
import APPLICANT_BANK_ACCOUNT_FIELD from "@salesforce/schema/Applicant__c.Would_you_like_to_open_a_bank_account__c";
import CUSTOMER_CODE_FIELD from "@salesforce/schema/Applicant__c.Customer_Code__c";
import doSmsGatewayCallout from "@salesforce/apexContinuation/IntegrationEngine.doSmsGatewayCallout";
import RETRIGGER_TIME from "@salesforce/label/c.SI_Retrigger_SMS_Time";
import SI_ATTEMPTS from "@salesforce/label/c.Initiate_SI_Attempts";
import SMS_ATTEMPTS from "@salesforce/label/c.SI_Sms_Retry_Limit";
import checkRetryExhausted from "@salesforce/apex/ENACHController.checkRetryExhausted";
import retryCountIncrease from "@salesforce/apex/ENACHController.retryCountIncrease";
import RETRY_ERROR_MSG from "@salesforce/label/c.Retry_Limit_Exhausted";
import SI_CAPTURED_FIELD from "@salesforce/schema/Repayments__c.SI_Repayment_Captured_correctly__c";
import SI_REPAYMENT_REMARKS_FIELD from "@salesforce/schema/Repayments__c.SI_Repayment_CVO_Remarks__c";
import SI_DETAILS_UNAVAILABLE_FIELD from "@salesforce/schema/Repayments__c.SI_Details_Unavailable_At_Present__c";
import SI_POST_SANCTION_REMARKS_FIELD from "@salesforce/schema/Repayments__c.SI_Post_Sanction_Remarks__c";
import SI_STATUS from "@salesforce/schema/Repayments__c.SI_Status__c";
import STAGE_FIELD from "@salesforce/schema/Opportunity.StageName";
import DEALNUMBER_FIELD from "@salesforce/schema/Opportunity.Deal_Number__c";
import MESSAGE_FIELD from "@salesforce/schema/Repayments__c.Message__c";
import updateLoanTransaction from "@salesforce/apex/RepaymentScreenController.updateLoanTransaction";
import isCheckReadOnly from "@salesforce/apex/RepaymentScreenController.isCheckReadOnly";
import PRE_DISBURSEMENT_CHECK from "@salesforce/label/c.Pre_Disbursement_Check";
import POST_SANCTION_CHECKS_AND_DOCUMENTATION	 from "@salesforce/label/c.Post_Sanction_Checks_and_Documentation";
import LOAN_STAGE_ADDITIONAL_DOCUMENTS from "@salesforce/label/c.Loan_Stage_Additional_Documents";
import generateReferenceNo from "@salesforce/apex/Utilities.generateReferenceNo";
export default class IND_LWC_siOnlineRepaymentMandate extends LightningElement {
  @api recordId; //Loan Application Id
  @api applicantId;
  @api repaymentId;
  @api currentStep;
  url;
  isSendLinkDisabled = false;
  isDisableInitiateSIBtn = false;
  customerName;
  timeLeft = RETRIGGER_TIME;
  showTimer = false;
  showSpinner = false;
  isSIRetryExhausted = false;
  isSMSRetryExhausted = false;
  wouldApplLikeToOpenAcc = false;
  siUnavailablePicklistSelected;
  siPostSanctionRemarks;
  siCapturedPicklistSelected;
  siOnlineCVORemarks;
  disableSubmitWhenNoAcc = false;
  siStatus;
  disableOnlineCVORemarks=false;
  disableSICapturedCorrectly=false;
  stageName;
  disableLinkButton=false;
  disableSIButton=false;
  disableSIDetailsUnav=false;
  disbaleSIPostSanctionRem=false;
  siMessage;
  customercode;
  dealnumber;
  refIdnumber;

  get isLinkDisabled(){
      return this.isSendLinkDisabled || this.disableLinkButton;
  }

  get isInitiateSIButtonDisabled(){
      return this.isDisableInitiateSIBtn || this.isSIRetryExhausted || this.disableSIButton;
  }
  async connectedCallback() {
    await isCheckReadOnly({loanApplicationId : this.recordId}).then(result=>{
      this.isReadOnly = result.isCheckReadOnly;
      this.stageName = result.stageName;
    });
    await checkRetryExhausted({ loanApplicationId: this.recordId, serviceName: SI_ATTEMPTS })
      .then((result) => {
        if (result != null) {
          this.isSIRetryExhausted = result;
          if (this.isSIRetryExhausted) {
            if(!this.isReadOnly && this.stageName == POST_SANCTION_CHECKS_AND_DOCUMENTATION){this.sendUpdateToParent({ isScreenEditable: true });}
          }
        }
        console.log("checkRetryExhausted SI" + this.isSIRetryExhausted);
      })
      .catch((error) => {
        this.error = error;
        console.log("Error in SI checkRetryExhausted connectedCallback Function ::" + error);
      });

    await checkRetryExhausted({ loanApplicationId: this.recordId, serviceName: SMS_ATTEMPTS })
      .then((result) => {
        if (result != null) {
          this.isSMSRetryExhausted = result;
          if (this.isSMSRetryExhausted) {
            this.isSendLinkDisabled = true;
            if(!this.isReadOnly && this.stageName == POST_SANCTION_CHECKS_AND_DOCUMENTATION){this.sendUpdateToParent({ isScreenEditable: true });}
          }
        }
      })
      .catch((error) => {
        this.error = error;
        console.log("Error in sms checkRetryExhausted connectedCallback Function ::" + error);
      });
  }
  isReadOnly = false;
  renderedCallback(){
    if(!this.isReadOnly){
      isCheckReadOnly({loanApplicationId : this.recordId}).then(result=>{
        this.isReadOnly = result.isCheckReadOnly;
        this.stageName = result.stageName;
        if(this.isReadOnly){
          this.disableOnlineCVORemarks = true;
          this.disableSICapturedCorrectly = true;
          this.disableSubmitWhenNoAcc = true;
          this.disableSIButton = true;
          this.isDisableInitiateSIBtn = true;
          this.isSendLinkDisabled = true;
          this.disableLinkButton = true;
        }

        if(this.currentStep == 'post-sanction' && this.stageName == PRE_DISBURSEMENT_CHECK){
          this.disableOnlineCVORemarks = true;
          this.disableSICapturedCorrectly = true;
          this.disableSubmitWhenNoAcc = true;
        }else if(this.currentStep == 'post-sanction' && this.stageName == LOAN_STAGE_ADDITIONAL_DOCUMENTS){
          this.disableOnlineCVORemarks = true;
          this.disableSICapturedCorrectly = true;
          this.disableSubmitWhenNoAcc = true;
        }else if(this.currentStep == 'pre-disbursement' && this.stageName == LOAN_STAGE_ADDITIONAL_DOCUMENTS){
          this.disableOnlineCVORemarks = true;
          this.disableSICapturedCorrectly = true;
          this.disableSubmitWhenNoAcc = true;
        }

      });
    }
  }
  @wire(getRecord,{recordId: "$recordId",fields :[STAGE_FIELD,DEALNUMBER_FIELD]})
  wiredLoan({data,error}){
      if(data){
        this.stageName= data?.fields?.StageName?.value;  
        if(data?.fields?.StageName?.value===POST_SANCTION_CHECKS_AND_DOCUMENTATION){
            // this.disableSubmitWhenNoAcc=true;
            this.disableOnlineCVORemarks=true;
            this.disableSICapturedCorrectly=true;
        }else if(data?.fields?.StageName?.value===PRE_DISBURSEMENT_CHECK){
            // this.disableSubmitWhenNoAcc=false;
            // this.disableOnlineCVORemarks=false;
            // this.disableSICapturedCorrectly=false;
            this.disableSIButton=true;
            this.isDisableInitiateSIBtn=true;
            this.disableLinkButton=true;
            this.disableSIDetailsUnav=true;
            this.disbaleSIPostSanctionRem=true;
        }
        this.dealnumber = data?.fields?.Deal_Number__c?.value;

      }else if(error){
        console.log(' wiredLoan error '+error);
      }
  }
  @wire(getRecord, { recordId: "$repaymentId", fields: [MESSAGE_FIELD,URL_FIELD, SI_CAPTURED_FIELD, SI_REPAYMENT_REMARKS_FIELD, SI_DETAILS_UNAVAILABLE_FIELD, SI_POST_SANCTION_REMARKS_FIELD, SI_STATUS] })
  wiredRepayments({ data, error }) {
    console.log('Test --> ', data?.fields?.SI_Status__c?.value);
    if (data) {
      if (data?.fields?.URL__c?.value && !this.isSMSRetryExhausted) {
        this.url = data?.fields?.URL__c?.value;
        this.isSendLinkDisabled = false;
      } else {
        this.isSendLinkDisabled = true;
      }
      this.siUnavailablePicklistSelected = data?.fields?.SI_Details_Unavailable_At_Present__c?.value;
      this.siPostSanctionRemarks = data?.fields?.SI_Post_Sanction_Remarks__c?.value;
      this.siCapturedPicklistSelected = data?.fields?.SI_Repayment_Captured_correctly__c?.value;
      this.siOnlineCVORemarks = data?.fields?.SI_Repayment_CVO_Remarks__c?.value;
      this.siStatus = data?.fields?.SI_Status__c?.value;
      this.siMessage = data?.fields?.Message__c?.value;
      if (data?.fields?.SI_Status__c?.value !== "SUCCESS") {
        this.disableSubmitWhenNoAcc = true; // User able to submit only when success
      }
      if (data?.fields?.SI_Status__c?.value == "In Progress") {
          this.disableSIButton = true;
      }
      if (data?.fields?.SI_Status__c?.value == "SUCCESS") {
        this.isSendLinkDisabled = true;
        this.isDisableInitiateSIBtn = true;
      }
      this.isReadOnly = false;
    } else if (error) {
      console.log(error);
    }
  }

  @wire(getRecord, { recordId: "$applicantId", fields: [APPLICANT_NAME_FIELD, APPLICANT_BANK_ACCOUNT_FIELD,CUSTOMER_CODE_FIELD ]})
  wiredApplicant({ data, error }) {
    if (data) {
      if (data?.fields?.Name?.value) {
        this.customerName = data?.fields?.Name?.value;
        this.customercode = data?.fields?.Customer_Code__c?.value;
        //this.wouldApplLikeToOpenAcc = data?.fields?.Would_you_like_to_open_a_bank_account__c?.value;//Descoped
      }
    } else if (error) {
      console.log(error);
    }
  }

  @wire(getObjectInfo, { objectApiName: REPAYMENTS_OBJECT })
  objectInfo;

  @wire(getPicklistValues, { recordTypeId: "$objectInfo.data.defaultRecordTypeId", fieldApiName: SI_CAPTURED_FIELD })
  siCapturedPicklist;

  @wire(getPicklistValues, { recordTypeId: "$objectInfo.data.defaultRecordTypeId", fieldApiName: SI_DETAILS_UNAVAILABLE_FIELD })
  siUnavailablePicklist;
  async handleInitiateSI() {
    console.log("In" + JSON.stringify({ loanId: this.recordId, applicantId: this.applicantId, repaymentId: this.repaymentId }));

    try {
      this.showSpinner = true;
      let isRetryExhausted = await checkRetryExhausted({ loanApplicationId: this.recordId, serviceName: SI_ATTEMPTS });
      if (!isRetryExhausted) {
        this.isSendLinkDisabled = false;
        this.disableSIButton = true;
        this.isDisableInitiateSIBtn = true;
        this.siStatus = "In Progress";
        await retryCountIncrease({ loanApplicationId: this.recordId, serviceName: SI_ATTEMPTS });
      } else {
        this.sendUpdateToParent({ isScreenEditable: true });
        this.isSIRetryExhausted = true;
        this.showToast("Error", RETRY_ERROR_MSG, "error");
      }
      this.showSpinner = false;
    } catch (e) {
      this.showSpinner = false;
      this.showToast("Error", e?.body?.message, "error");
      console.log(JSON.stringify(e));
    }
  }
  async sendSMS() {
    try {
      let isRetryExhausted = await checkRetryExhausted({ loanApplicationId: this.recordId, serviceName: SMS_ATTEMPTS });
      this.showSpinner = true;
      if (!isRetryExhausted) {
        this.refIdnumber = await generateReferenceNo({ loanId: this.recordId });
        if(this.refIdnumber){
          let getURLResp = await getSIUrl({ loanId: this.recordId, applicantId: this.applicantId, repaymentId: this.repaymentId, refId : this.refIdnumber });
          if (getURLResp) {
            this.url = getURLResp;            
            let smsRequestString = {
              applicantId: this.applicantId,
              loanApplicationId: this.recordId,
              flag: "SI_Online",
              url: encodeURIComponent(this.url),
              name: this.customerName
            };
            console.log(JSON.stringify(smsRequestString));
            let smsResp = await doSmsGatewayCallout({ smsRequestString: JSON.stringify(smsRequestString) });
            if (smsResp) {
              const fields = {};
              fields[ID_FIELD.fieldApiName] = this.repaymentId;
              fields[URL_FIELD.fieldApiName] = this.url;
              fields[SI_STATUS.fieldApiName] = "In Progress";
              await this.updateRecordDetails(fields);
              this.siStatus = "In Progress";
    
              this.showToast("Success", "SMS Sent Successfully", "success");
              await retryCountIncrease({ loanApplicationId: this.recordId, serviceName: SMS_ATTEMPTS });
              console.log("Success");
              this.isSendLinkDisabled = true;
              this.isDisableInitiateSIBtn = true;
              this.showTimer = true;
              this.startCountDown();
              let reqwrap = {};
              reqwrap.customerCode = this.customercode;
              reqwrap.dealNumber = this.dealnumber;
              reqwrap.RefId = this.refIdnumber;
              doSIStatusAsyncCallout({statusCheckString : JSON.stringify(reqwrap),loanApplicationId : this.recordId}).
              then(result => {
                console.log('SI PE Success');
              }).catch(error => {
                console.log('SI PE error');
              })
            }
          }
        }
      } else {
        this.sendUpdateToParent({ isScreenEditable: true });
        this.isSendLinkDisabled = true;
        this.showToast("Error", RETRY_ERROR_MSG, "error");
      }
      this.showSpinner = false;
    } catch (e) {
      this.showSpinner = false;
      this.showToast("Error", e?.body?.message, "error");
    }
  }
  showToast(title, message, variant) {
    const event = new ShowToastEvent({
      title: title,
      message: message,
      variant: variant
    });
    this.dispatchEvent(event);
  }

  updateRecordDetails(fields) {
    //const fields = {};
    const recordInput = { fields };
    return updateRecord(recordInput);
  }
  handleInputChange(event) {
    const fieldName = event.target.name;
    if (fieldName === "siUnavailablePicklist") {
      this.siUnavailablePicklistSelected = event.target.value;
    }
    if (fieldName === "siPostSanctionRemarks") {
      this.siPostSanctionRemarks = event.target.value;
    }
    if (fieldName === "siCapturedPicklist") {
      this.siCapturedPicklistSelected = event.target.value;
    }
    if (fieldName === "siOnlineCVORemarks") {
      this.siOnlineCVORemarks = event.target.value;
    }
  }

  async handleSubmitWhenOpenAcc() {
    console.log("Submit");
    try {
      this.showSpinner = true;
      const fields = {};
      fields[ID_FIELD.fieldApiName] = this.repaymentId;
      fields[SI_CAPTURED_FIELD.fieldApiName] = this.siCapturedPicklistSelected;
      fields[SI_REPAYMENT_REMARKS_FIELD.fieldApiName] = this.siOnlineCVORemarks;
      fields[SI_DETAILS_UNAVAILABLE_FIELD.fieldApiName] = this.siUnavailablePicklistSelected;
      fields[SI_POST_SANCTION_REMARKS_FIELD.fieldApiName] = this.siPostSanctionRemarks;
      console.log("~~" + JSON.stringify(fields));
      await this.updateRecordDetails(fields);
      await updateLoanTransaction({loanApplicationId:this.recordId,module:'Pre Disbursement Check'});
      this.showSpinner = false;
      this.showToast("Success", " ", "success");
    } catch (e) {
      this.showSpinner = false;
      this.showToast("Error", e?.body?.message, "error");
    }
  }

  async handleSubmitWhenNoAcc() {
    try {
      if(this.stageName == PRE_DISBURSEMENT_CHECK){
        this.showSpinner = true;
        const fields = {};
        fields[ID_FIELD.fieldApiName] = this.repaymentId;
        fields[SI_CAPTURED_FIELD.fieldApiName] = this.siCapturedPicklistSelected;
        fields[SI_REPAYMENT_REMARKS_FIELD.fieldApiName] = this.siOnlineCVORemarks;
        console.log("~~" + JSON.stringify(fields));
        await this.updateRecordDetails(fields);
        await updateLoanTransaction({loanApplicationId:this.recordId,module : PRE_DISBURSEMENT_CHECK});
        this.showSpinner = false;
        this.showToast("Success", " ", "success");
      }else if(this.stageName == POST_SANCTION_CHECKS_AND_DOCUMENTATION){
        this.showSpinner = true;
        await updateLoanTransaction({loanApplicationId:this.recordId,module : POST_SANCTION_CHECKS_AND_DOCUMENTATION});
        this.showSpinner = false;
        this.showToast("Success", " ", "success");
      }
    } catch (e) {
      this.showSpinner = false;
      this.showToast("Error", e?.body?.message, "error");
    }
  }

  sendUpdateToParent(fields) {
    const selectedEvent = new CustomEvent("sichange", { detail: fields, bubbles: true, composed: true });
    console.log("event dispatched");
    this.dispatchEvent(selectedEvent);
  }
  startCountDown() {
    let timerId = setInterval(() => {
      if (this.timeLeft == 0) {
        clearTimeout(timerId);
        this.showTimer = false;
        this.isSendLinkDisabled = false;
        this.timeLeft = RETRIGGER_TIME; //Reset timer
      } else {
        this.timeLeft--;
      }
    }, 1000);
  }
}