import { LightningElement, track, api, wire } from "lwc";
import createOtherDocument from "@salesforce/apex/RepaymentScreenController.createOtherDocument";
import validateSIDocs from "@salesforce/apex/IND_SI_Controller.validateSIDocs";
import { getRecord, updateRecord, getFieldValue } from "lightning/uiRecordApi";
import BANK_NAME_FIELD from "@salesforce/schema/Repayments__c.Bank_Master__r.Name";
import IFSC_CODE from "@salesforce/schema/Repayments__c.IFSC_Code__c";
import ACC_NUM from "@salesforce/schema/Repayments__c.Account_Number__c";
import ID_FIELD from "@salesforce/schema/Repayments__c.Id";
import MICR_CODE_FIELD from "@salesforce/schema/Repayments__c.MICR_Code__c";
import ACC_HOLDER_FIELD from "@salesforce/schema/Repayments__c.Name_of_the_A_c_holder__c";
import SI_SIGNED from "@salesforce/schema/Repayments__c.SI_Signed__c";
import SI_FORM_LEGIBLE from "@salesforce/schema/Repayments__c.Is_SI_form_Legible__c";
import SI_FORM_FILLED_CORRECT from "@salesforce/schema/Repayments__c.SI_Form_filled_correctly__c";
import SI_FORM_LEGIBLE_REMARKS from "@salesforce/schema/Repayments__c.SI_Form_Legibility_Remarks__c";
import SI_FORM_FILLED_CORRECT_REMARKS from "@salesforce/schema/Repayments__c.SI_Form_Filled_Correctly_Remarks__c";
import SI_CAPTURED_FIELD from "@salesforce/schema/Repayments__c.SI_Repayment_Captured_correctly__c";
import SI_REPAYMENT_CVO_REMARKS_FIELD from "@salesforce/schema/Repayments__c.SI_Repayment_CVO_Remarks__c";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import STAGE_FIELD from "@salesforce/schema/Opportunity.StageName";
import updateLoanTransaction from "@salesforce/apex/RepaymentScreenController.updateLoanTransaction";
import isCheckReadOnly from "@salesforce/apex/RepaymentScreenController.isCheckReadOnly";
import documentRecordId from "@salesforce/apex/RepaymentScreenController.documentRecordId";
import getVehicleId from "@salesforce/apex/RepaymentScreenController.getVehicleId";
export default class IND_LWC_siOfflineRepaymentMandate extends LightningElement {
  @api currentStep;
  @track yesNoOption;
  @track noOption = "No";
  @track uploadViewDocFlag;
  viewDocFlag;
  @track showUpload = true;
  @track showPhotoCopy;
  @track showDocView;
  @track isVehicleDoc;
  @track docType = "SI Form";
  @track isLoading;
  @track documentRecordId;
  title = "Upload SI Form";
  @api recordId; //Loan Application Id
  @api applicantId;
  @api repaymentId;
  ifscCode;
  accNum;
  repaymentRecord;
  disablePreDisField = true;
  signedSIField = false;
  micrCodeField;
  nameOfAcHolderField;
  stageName;
  isCheckReadOnly;
  disablePostSanctionField = false;
  siFormLegibleField;
  legibilityRemarksField;
  siFormFilledCorrectlyField;
  siFormFilledCorrectRemarks;
  siOfflineCVORemarks;
  siRepaymentCapturedCorrectly;

  isStagePostSanction;
  isStagePreDis;
  isStageNamePost;
  isStagePredisbursement;
  @track isDisabledSubmitBtn;

  @wire(getRecord, { recordId: "$repaymentId", fields: [SI_REPAYMENT_CVO_REMARKS_FIELD, SI_CAPTURED_FIELD, SI_FORM_FILLED_CORRECT_REMARKS, SI_FORM_FILLED_CORRECT, SI_FORM_LEGIBLE_REMARKS, SI_FORM_LEGIBLE, BANK_NAME_FIELD, IFSC_CODE, ACC_NUM, SI_SIGNED, MICR_CODE_FIELD, ACC_HOLDER_FIELD] })
  wiredRepayments({ data, error }) {
    if (data) {
      this.repaymentRecord = data;
      this.ifscCode = data?.fields?.IFSC_Code__c?.value;
      this.accNum = data?.fields?.Account_Number__c?.value;
      this.signedSIField = data?.fields?.SI_Signed__c?.value === "Yes" ? true : false;
      this.micrCodeField = data?.fields?.MICR_Code__c?.value;
      this.nameOfAcHolderField = data?.fields?.Name_of_the_A_c_holder__c?.value;
      this.siFormLegibleField = data?.fields?.Is_SI_form_Legible__c?.value;
      this.legibilityRemarksField = data?.fields?.SI_Form_Legibility_Remarks__c?.value;
      this.siFormFilledCorrectlyField = data?.fields?.SI_Form_filled_correctly__c?.value;
      this.siFormFilledCorrectRemarks = data?.fields?.SI_Form_Filled_Correctly_Remarks__c?.value;
      this.siRepaymentCapturedCorrectly = data?.fields?.SI_Repayment_Captured_correctly__c?.value;
      this.siOfflineCVORemarks = data?.fields?.SI_Repayment_CVO_Remarks__c?.value;
    } else if (error) {
      console.log(error);
    }
  }

  @wire(getRecord, { recordId: "$recordId", fields: [STAGE_FIELD] })
  wiredLoan({ data, error }) {
    if (data) {
      this.stageName = data?.fields?.StageName?.value;
      if (data?.fields?.StageName?.value === "Post Sanction Checks and Documentation") {
        //
      } else if (data?.fields?.StageName?.value === "Pre Disbursement Check") {
        // this.disablePreDisField = false;
        // this.disablePostSanctionField = true;
      }
    } else if (error) {
      console.log(" wiredLoan error " + error);
    }
  }

  get bankName() {
    return getFieldValue(this.repaymentRecord, BANK_NAME_FIELD);
  }
  @track vehiclerecordid;
  async connectedCallback() {
    let vehicleId = await getVehicleId({'loanApplicationId' : this.recordId, 'dealId' : this.dealId});
    if(vehicleId){
      this.vehiclerecordid = vehicleId;
    }
    var yesNoOptionList = new Array();
    yesNoOptionList.push({ label: "Yes", value: "Yes" });
    yesNoOptionList.push({ label: "No", value: "No" });
    this.yesNoOption = yesNoOptionList;
    isCheckReadOnly({loanApplicationId : this.recordId}).then(result=>{
        this.stageName = result.stageName;
        this.isCheckReadOnly = result.isCheckReadOnly;
        this.isDisabledSubmitBtn = result.isCheckReadOnly;
        if (this.stageName === "Post Sanction Checks and Documentation") {
          this.disablePostSanctionField = this.isCheckReadOnly;
          this.disablePreDisField = true;
          this.isStagePreDis=false;
          this.isStageNamePost=true;
          this.isStagePostSanction = result.isCheckReadOnly == true ? false : true;
          this.isStagePredisbursement = false;
        }else if(this.stageName == 'Pre Disbursement Check'){
          this.disablePostSanctionField = true;
          this.disablePreDisField = this.isCheckReadOnly;
          this.isStageNamePost=false;
          this.isStagePreDis=true;
          this.isStagePostSanction = false;
          this.isStagePredisbursement = true;
        }
        if(this.currentStep == 'post-sanction' && this.stageName == 'Pre Disbursement Check'){
          this.disablePreDisField = true;
          this.disablePostSanctionField = true;
          this.isStagePostSanction = false;
          this.isStagePredisbursement = false;
          this.isDisabledSubmitBtn = true;
        } else if(this.currentStep == 'post-sanction' && this.stageName == 'Disbursement Request Preparation'){
          this.disablePreDisField = true;
          this.disablePostSanctionField = true;
          this.isStagePostSanction = false;
          this.isStagePredisbursement = false;
          this.isStagePreDis = false;
          this.isStageNamePost = true;
          this.isDisabledSubmitBtn = true;
        }else if(this.currentStep == 'pre-disbursement' && this.stageName == 'Disbursement Request Preparation'){
          this.disablePreDisField = true;
          this.disablePostSanctionField = true;
          this.isStagePostSanction = false;
          this.isStagePredisbursement = true;
          this.isStageNamePost = false;
          this.isStagePreDis = true;
          this.isDisabledSubmitBtn = true;
        }
    }).catch(error=>{
      console.error('error 161 ',error);
    });
  }

  handleInputFieldChange(event) {
    const fieldName = event.target.name;
    if (fieldName === "signedSIField") {
      this.signedSIField = event.target.checked;
    }
    if (fieldName === "micrCodeField") {
      this.micrCodeField = event.target.value;
    }
    if (fieldName === "nameOfAcHolderField") {
      this.nameOfAcHolderField = event.target.value;
    }
    if (fieldName === "siFormLegibleField") {
      this.siFormLegibleField = event.target.value;
    }
    if (fieldName === "legibilityRemarksField") {
      this.legibilityRemarksField = event.target.value;
    }
    if (fieldName === "siFormFilledCorrectlyField") {
      this.siFormFilledCorrectlyField = event.target.value;
    }
    if (fieldName === "siFormFilledCorrectRemarks") {
      this.siFormFilledCorrectRemarks = event.target.value;
    }
    if (fieldName === "siRepaymentCapturedCorrectly") {
      this.siRepaymentCapturedCorrectly = event.target.value;
    }
    if (fieldName === "siOfflineCVORemarks") {
      this.siOfflineCVORemarks = event.target.value;
    }
  }

  handleUploadSIForm() {
    console.log("Inside");
    this.isLoading = true;
    createOtherDocument({ docType: this.docType, applicantId: this.applicantId, loanApplicationId: this.recordId, repaymetId: this.repaymentId,'vehicleId': this.vehiclerecordid })
      .then((result) => {
        console.log("Upload SI FORM", result);
        this.documentRecordId = result;
        this.isLoading = false;
        this.showUpload = true;
        this.showPhotoCopy = false;
        this.showDocView = false;
        this.isVehicleDoc = true;
        this.isAllDocType = false;
        this.uploadViewDocFlag = true;
      })
      .catch((error) => {
        console.log("Upload SI FORM", error);
        this.isLoading = false;
      });
  }
  changeflagvalue() {
    this.uploadViewDocFlag = false;
    this.viewDocFlag = false;
  }
  handleViewSIForm() {
    this.isLoading = true;
    documentRecordId({ loanApplicationId: this.recordId, docType: this.docType,'dealId' : this.dealId})
      .then((result) => {
        console.log("View SI FORM", result);
        this.documentRecordId = result;
        this.isLoading = false;
        this.showPhotoCopy = false;
        this.isVehicleDoc = true;
        this.viewDocFlag = true;
        this.showUpload = true;
        this.showDocView = true;
        this.isAllDocType = false;
      }).catch((error) => {
        console.log("View SI FORM", error);
        this.isLoading = false;
      });
  }

  async submitPostSanction() {
    const allValid = [...this.template.querySelectorAll(".postSanctionFields")].reduce((validSoFar, inputCmp) => {
      inputCmp.reportValidity();
      return validSoFar && inputCmp.checkValidity();
    }, true);
    let isAllDocAvailable = await validateSIDocs({ loanApplicationId: this.recordId });
    if (!isAllDocAvailable) {
      this.showToast("Error", "Please Upload SI Form", "error");
      return;
    }
    let isSISigned = this.signedSIField;
    if (!isSISigned) {
      this.showToast("Error", "SI is not signed", "error");
      return;
    }
    if(!allValid){
      this.showToast("Error", "Please fill all the mandatory fields", "error");
      return;
    }
    if (allValid && isAllDocAvailable && isSISigned) {
      const fields = {};
      fields[ID_FIELD.fieldApiName] = this.repaymentId;
      fields[SI_SIGNED.fieldApiName] = this.signedSIField == true ? "Yes" : "No";
      fields[MICR_CODE_FIELD.fieldApiName] = this.micrCodeField;
      fields[ACC_HOLDER_FIELD.fieldApiName] = this.nameOfAcHolderField;
      console.log("before~~" + JSON.stringify(fields));
      try {
        await this.updateRecordDetails(fields);
        await updateLoanTransaction({loanApplicationId:this.recordId,module:'Post Sanction Checks and Documentation'}).then(result=>{
          this.isStagePostSanction = false;
          this.isDisabledSubmitBtn = true;
          this.disablePostSanctionField = true;
          this.dispatchEvent(new CustomEvent("disableinitiation"));
        }).catch(error=>{
          console.error('error 161 ',error);
        });
        this.showToast("Success", " ", "success");
      } catch (error) {
        this.showToast("Error", error?.body?.message, "error");
      }
    }
  }

  async submitPreDisbursement() {
    const allValid = [...this.template.querySelectorAll(".preDisburseFields")].reduce((validSoFar, inputCmp) => {
      inputCmp.reportValidity();
      return validSoFar && inputCmp.checkValidity();
    }, true);
    if (allValid) {
      const fields = {};
      fields[ID_FIELD.fieldApiName] = this.repaymentId;
      fields[SI_FORM_LEGIBLE.fieldApiName] = this.siFormLegibleField;
      fields[SI_FORM_LEGIBLE_REMARKS.fieldApiName] = this.legibilityRemarksField;
      fields[SI_FORM_FILLED_CORRECT.fieldApiName] = this.siFormFilledCorrectlyField;
      fields[SI_FORM_FILLED_CORRECT_REMARKS.fieldApiName] = this.siFormFilledCorrectRemarks;
      fields[SI_CAPTURED_FIELD.fieldApiName] = this.siRepaymentCapturedCorrectly;
      fields[SI_REPAYMENT_CVO_REMARKS_FIELD.fieldApiName] = this.siOfflineCVORemarks;
      console.log("before~~" + JSON.stringify(fields));
      try {
        await this.updateRecordDetails(fields);
        await updateLoanTransaction({loanApplicationId:this.recordId,module:'Pre Disbursement Check'}).then(result=>{
          this.disablePreDisField = true;
          this.isDisabledSubmitBtn = true;
          // this.isStagePredisbursement = false;
        }).catch(error=>{
          console.error('error 243 ',error);
        });
        this.showToast("Success", " ", "success");
      } catch (error) {
        this.showToast("Error", error?.body?.message, "error");
      }
    }
  }

  updateRecordDetails(fields) {
    const recordInput = { fields };
    return updateRecord(recordInput);
  }
  showToast(title, message, variant) {
    const event = new ShowToastEvent({
      title: title,
      message: message,
      variant: variant
    });
    this.dispatchEvent(event);
  }

  docUploadSuccessfully(event) {
    try{
      console.log("docUploadSuccessfully ", event);
    }catch(error){
      console.error('docUploadSuccessfully error',error);
    }
  }
}