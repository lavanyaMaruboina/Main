import { api, LightningElement, track,wire } from "lwc";
import createOtherDocument from "@salesforce/apex/RepaymentScreenController.createOtherDocument";
import validateACHDocs from "@salesforce/apex/RepaymentScreenController.validateACHDocs";
//import submitACH from "@salesforce/apex/ENACHController.submitENACH";
import SB_Or_CAis_ticked_appropriately__c from "@salesforce/schema/Repayments__c.SB_Or_CAis_ticked_appropriately__c";
import Correct_bank_name_is_filled__c from "@salesforce/schema/Repayments__c.Correct_bank_name_is_filled__c";
import CFD_9_digit_loan_no_is_filled_correctly__c from "@salesforce/schema/Repayments__c.CFD_9_digit_loan_no_is_filled_correctly__c";
import Fill_Email_ID__c from "@salesforce/schema/Repayments__c.Fill_Email_ID__c";
import Name_of_A_c_holder_is_filled_in_CAPITAL__c from "@salesforce/schema/Repayments__c.Name_of_A_c_holder_is_filled_in_CAPITAL__c";
import Confirm_that_all_Mandate_details_are_cor__c from "@salesforce/schema/Repayments__c.Confirm_that_all_Mandate_details_are_cor__c";
import Bank_Account_No_is_correct_and_complete__c from "@salesforce/schema/Repayments__c.Bank_Account_No_is_correct_and_complete__c";
import Correct_IFSC_code_is_filled__c from "@salesforce/schema/Repayments__c.Correct_IFSC_code_is_filled__c";
import Correct_EMI_frequency_is_ticked__c from "@salesforce/schema/Repayments__c.Correct_EMI_frequency_is_ticked__c";
import Customer_code_in_Reference_Il__c from "@salesforce/schema/Repayments__c.Customer_code_in_Reference_Il__c";
import Correct_deal_date_or_PACT_PR_date_is_fil__c from "@salesforce/schema/Repayments__c.Correct_deal_date_or_PACT_PR_date_is_fil__c";
import Bank_A_c_holder_has_signed_the_ACH_Manda__c from "@salesforce/schema/Repayments__c.Bank_A_c_holder_has_signed_the_ACH_Manda__c";
import ACH_Form_filled_correctly__c from "@salesforce/schema/Repayments__c.ACH_Form_filled_correctly__c";
import Leftside_Create_Modify_ticked__c from "@salesforce/schema/Repayments__c.Leftside_Create_Modify_ticked__c";
import Correct_MICR_code_is_filled__c from "@salesforce/schema/Repayments__c.Correct_MICR_code_is_filled__c";
import Debit_optn_type_to_be_ticked_as_Max_Amnt__c from "@salesforce/schema/Repayments__c.Debit_optn_type_to_be_ticked_as_Max_Amnt__c";
import Correct_mobile_or_landline_no_is_filled__c from "@salesforce/schema/Repayments__c.Correct_mobile_or_landline_no_is_filled__c";
import Correct_Last_EMl_date_2_months_is_fill__c from "@salesforce/schema/Repayments__c.Correct_Last_EMl_date_2_months_is_fill__c";
import Copy_of_bank_P_B_and_or_specimen_cheque__c from "@salesforce/schema/Repayments__c.Copy_of_bank_P_B_and_or_specimen_cheque__c";
import EMl_Amt_Is_filled_correctly__c from "@salesforce/schema/Repayments__c.EMl_Amt_Is_filled_correctly__c";
import Is_ACH_Mandate_legible__c from "@salesforce/schema/Repayments__c.Is_ACH_Mandate_legible__c";
import Is_Cancelled_Cheque_legible__c from "@salesforce/schema/Repayments__c.Is_Cancelled_Cheque_legible__c";
import ACH_Form_Remarks__c from "@salesforce/schema/Repayments__c.ACH_Form_Remarks__c";
import Cancelled_Cheque_Remarks__c from "@salesforce/schema/Repayments__c.Cancelled_Cheque_Remarks__c";
import ACH_Mandate_Remarks__c from "@salesforce/schema/Repayments__c.ACH_Mandate_Remarks__c";
import repayment_Id from "@salesforce/schema/Repayments__c.Id";
import { updateRecord,getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import STAGE_FIELD from "@salesforce/schema/Opportunity.StageName";
import updateLoanTransaction from "@salesforce/apex/RepaymentScreenController.updateLoanTransaction";
import isCheckReadOnly from "@salesforce/apex/RepaymentScreenController.isCheckReadOnly";
import documentRecordId from "@salesforce/apex/RepaymentScreenController.documentRecordId";
import getVehicleId from "@salesforce/apex/RepaymentScreenController.getVehicleId";

import AchChequeAvailable from "@salesforce/label/c.AchChequeAvailable";
import AchChequeNotAvailable from "@salesforce/label/c.AchChequeNotAvailable";
import AchBothMandatoryToastMsg from "@salesforce/label/c.AchBothMandatoryToastMsg";
import AchMandateAvailable from "@salesforce/label/c.AchMandateAvailable";
import ChequeMandatoryToastMsg from "@salesforce/label/c.ChequeMandatoryToastMsg";
import ChequeMandateAvailable from "@salesforce/label/c.ChequeMandateAvailable";
import AchMandateMandatoryToastMsg from "@salesforce/label/c.AchMandateMandatoryToastMsg";

export default class IND_LWC_achRepaymentMandate extends LightningElement {
  @api currentStep;
  @track yesNoOption;
  @track noOption = "No";
  @api recordId;
  @api applicantId;
  @api dealId;
  @track uploadViewDocFlag;
  @track viewDocFlag;
  @track showUpload;
  @track showPhotoCopy;
  @track showDocView;
  @track isVehicleDoc;
  @track docType;
  @track isLoading = false;
  @track documentRecordId;
  @api repaymentid;
  sbOrCaTickedField = 'No';
  bankAccNoIsCorrectField = 'No';
  leftCreateModifyTickedField = 'No';
  correctBankNameField = 'No';
  correctIFSCCodeField = 'No';
  correctMICRField = 'No';
  emiAmntCorrectField = 'No';
  correctEMIFrequencyField = 'No';
  debitOptnTypeMaxAmntField = 'No';
  cfdFilledCorrectField = 'No';
  customedCodeField = 'No';
  correctMobileNoField = 'No';
  fillEmailField = 'No';
  correctDealDateField = 'No';
  correctLastEmiDateField = 'No';
  nameOfAcHolderField = 'No';
  achMandateSignedField = 'No';
  copySpecimenChequeField = 'No';
  confirmMandateDetailsField = 'No';
  achFilledCorrectlyField;
  isAchMandateLegibleField;
  isCancelledChequeLegibleField;
  isPostReadOnly = false;
  achFormRemarksField;
  cancelledChequeremarksField;
  achMandateRemarks;
  disabledACHsubmit=false;
  isLegibilityAndRemarksDisabled=false;//disabled during post sanction, enabled during pre disbursement
  isPreDisbursementSubmitDisabled=true;//disabled during post sanction, enabled during pre disbursement
  stageName;
  isReadOnly=false;
  title = 'Upload Documents';
  @track isPreDis;
  @track isPostSanct;

  @wire(getRecord, { recordId: "$recordId", fields: [STAGE_FIELD] })
  wiredLoan({ data, error }) {
    if (data) {
      this.stageName = data?.fields?.StageName?.value;
      if (data?.fields?.StageName?.value === "Post Sanction Checks and Documentation") {
        //
      } else if (data?.fields?.StageName?.value === "Pre Disbursement Check") {
        // this.isLegibilityAndRemarksDisabled=false;
        // this.isPreDisbursementSubmitDisabled=false;
      }
    } else if (error) {
      console.log(" wiredLoan error " + error);
    }
  }

  @wire(getRecord, { recordId: '$repaymentid', fields: [ ACH_Mandate_Remarks__c,Cancelled_Cheque_Remarks__c,ACH_Form_Remarks__c,Is_Cancelled_Cheque_legible__c,Is_ACH_Mandate_legible__c,SB_Or_CAis_ticked_appropriately__c , Correct_bank_name_is_filled__c , CFD_9_digit_loan_no_is_filled_correctly__c, Fill_Email_ID__c,Fill_Email_ID__c, Name_of_A_c_holder_is_filled_in_CAPITAL__c, Confirm_that_all_Mandate_details_are_cor__c, Bank_Account_No_is_correct_and_complete__c, Correct_IFSC_code_is_filled__c, Correct_EMI_frequency_is_ticked__c, Customer_code_in_Reference_Il__c, Correct_deal_date_or_PACT_PR_date_is_fil__c, Bank_A_c_holder_has_signed_the_ACH_Manda__c , ACH_Form_filled_correctly__c, Leftside_Create_Modify_ticked__c, Correct_MICR_code_is_filled__c, Debit_optn_type_to_be_ticked_as_Max_Amnt__c, Correct_mobile_or_landline_no_is_filled__c, Correct_Last_EMl_date_2_months_is_fill__c, Copy_of_bank_P_B_and_or_specimen_cheque__c, EMl_Amt_Is_filled_correctly__c]})
  wiredRepayment({data,error}){
    if(data){
      if(data?.fields?.EMl_Amt_Is_filled_correctly__c?.value==='Yes'){ //ACH submitted, screen read only
        // this.disabledACHsubmit=true; //CISP-1223
        let allInputElements = this.template.querySelectorAll(".mandatory");
        for (let elem of allInputElements) {
          if (elem) {
            elem.disabled = true;
          }
        }
      }
      if(data?.fields?.SB_Or_CAis_ticked_appropriately__c?.value){ // If value is available,set it, otherwise default to 'No'
        this.sbOrCaTickedField   = data?.fields?.SB_Or_CAis_ticked_appropriately__c?.value;
        this.correctBankNameField   = data?.fields?.Correct_bank_name_is_filled__c?.value;
        this.cfdFilledCorrectField = data?.fields?.CFD_9_digit_loan_no_is_filled_correctly__c?.value;
        this.fillEmailField    = data?.fields?.Fill_Email_ID__c?.value;
        this.nameOfAcHolderField    = data?.fields?.Name_of_A_c_holder_is_filled_in_CAPITAL__c?.value;
        this.confirmMandateDetailsField   = data?.fields?.Confirm_that_all_Mandate_details_are_cor__c?.value;
        this.bankAccNoIsCorrectField   = data?.fields?.Bank_Account_No_is_correct_and_complete__c?.value;
        this.correctIFSCCodeField   = data?.fields?.Correct_IFSC_code_is_filled__c?.value;
        this.correctEMIFrequencyField   = data?.fields?.Correct_EMI_frequency_is_ticked__c?.value;
        this.customedCodeField   = data?.fields?.Customer_code_in_Reference_Il__c?.value;
        this.correctDealDateField   = data?.fields?.Correct_deal_date_or_PACT_PR_date_is_fil__c?.value;
        this.achMandateSignedField   = data?.fields?.Bank_A_c_holder_has_signed_the_ACH_Manda__c?.value;
        this.achFilledCorrectlyField   = data?.fields?.ACH_Form_filled_correctly__c?.value ?  data?.fields?.ACH_Form_filled_correctly__c?.value : '';
        this.leftCreateModifyTickedField   = data?.fields?.Leftside_Create_Modify_ticked__c?.value;
        this.correctMICRField   = data?.fields?.Correct_MICR_code_is_filled__c?.value;
        this.debitOptnTypeMaxAmntField  =data?.fields?.Debit_optn_type_to_be_ticked_as_Max_Amnt__c?.value;
        this.emiAmntCorrectField  = data?.fields?.EMl_Amt_Is_filled_correctly__c?.value;
        this.copySpecimenChequeField  = data?.fields?.Copy_of_bank_P_B_and_or_specimen_cheque__c?.value;
        this.correctLastEmiDateField  = data?.fields?.Correct_Last_EMl_date_2_months_is_fill__c?.value;
        this.correctMobileNoField   = data?.fields?.Correct_mobile_or_landline_no_is_filled__c?.value;
        this.isAchMandateLegibleField = data?.fields?.Is_ACH_Mandate_legible__c?.value ? data?.fields?.Is_ACH_Mandate_legible__c?.value : '';
        this.isCancelledChequeLegibleField = data?.fields?.Is_Cancelled_Cheque_legible__c?.value ?  data?.fields?.Is_Cancelled_Cheque_legible__c?.value : '';
        this.achMandateRemarks=data?.fields?.ACH_Mandate_Remarks__c?.value;
        this.cancelledChequeremarksField=data?.fields?.Cancelled_Cheque_Remarks__c?.value;
        this.achFormRemarksField=data?.fields?.ACH_Form_Remarks__c?.value;
      }
    }else if(error){
      console.log('Repayment record error'+error);
    }
  }

  @track vehiclerecordid;
  async connectedCallback() {
    let vehicleId = await getVehicleId({'loanApplicationId' : this.recordId, 'dealId' : this.dealId});
    if(vehicleId){
      this.vehiclerecordid = vehicleId;
    }
    console.log("connectedCallback ", this.currentStep , ' ',this.stageName);
    var yesNoOptionList = new Array();
    yesNoOptionList.push({ label: "Yes", value: "Yes" });
    yesNoOptionList.push({ label: "No", value: "No" });
    this.yesNoOption = yesNoOptionList;
    isCheckReadOnly({loanApplicationId : this.recordId, dealId:this.dealId}).then(result=>{
      console.log('isCheckReadOnly',result);
        this.isReadOnly=result.isCheckReadOnly;
        this.stageName = result.stageName;
        console.log('isReadOnly --> ',this.isReadOnly);
        console.log('isReadOnly --> ',this.stageName);
        //CISP-1223
        console.log('isReadOnly --> ',result.isAchScreenSubmitted);
        if(result.isCheckReadOnly && result.isAchScreenSubmitted){
          console.log('inside if condition');
          this.isReadOnly = true;
          this.isPostReadOnly = true;
        }else{
          console.log('inside else');
          this.isReadOnly = false;
          this.isPostReadOnly = false;
        }
        //CISP-1223
        if(this.stageName == 'Pre Disbursement Check'){
          this.isPreDisbursementSubmitDisabled=false;
          this.isPreDis = true;
          this.isPostSanct = false;
        }else if(this.stageName == 'Post Sanction Checks and Documentation'){
          this.isPreDis = false;
          this.isPostSanct = true;
          this.disabledACHsubmit = false; 
          this.isReadOnly = true;
        }
        if(this.currentStep == 'post-sanction' && this.stageName == 'Pre Disbursement Check'){
          this.isReadOnly=true;
          this.isPostReadOnly = true;
          this.disabledACHsubmit = false; 
          this.isPreDisbursementSubmitDisabled=true;
        }
        if(this.currentStep == 'post-sanction' && this.stageName == 'Disbursement Request Preparation'){
          this.isReadOnly=true;
          this.disabledACHsubmit = false;
          this.isPostReadOnly  = true;
          this.isPreDisbursementSubmitDisabled=true;
          this.isPreDis = false;
          this.isPostSanct = true;
        }
        if(this.currentStep == 'pre-disbursement' && this.stageName == 'Disbursement Request Preparation'){
          this.isReadOnly=true;
          this.disabledACHsubmit = true;
          this.isPostReadOnly = true;
          this.isPreDisbursementSubmitDisabled=false;
          this.isPreDis = true;
          this.isPostSanct = false;
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

  handleUploadACHMandate() {
    this.isLoading = true;
    createOtherDocument({ docType: "ACH Mandate Form", applicantId: this.applicantId, loanApplicationId: this.recordId, repaymetId:this.repaymentid, 'vehicleId': this.vehiclerecordid})
      .then((result) => {
        console.log("Upload ACH Mandate", result);
        this.title = "Upload ACH Mandate";
        this.documentRecordId = result;
        this.isLoading = false;
        this.showUpload = true;
        this.showPhotoCopy = false;
        this.showDocView = false;
        this.isVehicleDoc = true;
        this.docType = "ACH Mandate Form";
        this.uploadViewDocFlag = true;
      })
      .catch((error) => {
        console.log("Upload ACH Mandate Error", error);
        this.isLoading = false;
      });
    
  }

  handleUploadCancelledCheque() {
    this.isLoading = true;
    createOtherDocument({ docType: "Cancelled Cheque", applicantId: this.applicantId, loanApplicationId: this.recordId , repaymetId:this.repaymentid, 'vehicleId': this.vehiclerecordid})
      .then((result) => {
        console.log("Upload Cancelled Cheque", result);
        this.title = "Upload Cancelled Cheque";
        this.documentRecordId = result;
        this.isLoading = false;
        this.showUpload = true;
        this.showPhotoCopy = false;
        this.showDocView = false;
        this.isVehicleDoc = true;
        this.docType = "Cancelled Cheque";
        this.uploadViewDocFlag = true;
      })
      .catch((error) => {
        console.log("Upload Cancelled Cheque", error);
        this.isLoading = false;
      });
  }
  changeflagvalue() {
    this.uploadViewDocFlag = false;
    this.viewDocFlag = false;
  }
  handleViewDocHandler(event){
    try {
      let btnName = event.currentTarget.dataset.name;
      if(btnName == 'ACHMandate'){
          documentRecordId({loanApplicationId:this.recordId,docType : 'ACH Mandate Form','dealId' : this.dealId}).then(result=>{
            console.log('documentRecordId',result);
            this.title = "View ACH Mandate Form";
            this.documentRecordId = result;
            this.isLoading = false;
            this.showPhotoCopy = false;
            this.showDocView = true;
            this.docType = "ACH Mandate Form";          
            this.showUpload = true;
            this.isAllDocType = false;
            this.viewDocFlag = true;
            this.isVehicleDoc = true;
          }).catch(error=>{
            console.error('error',error);
          });
      }
      if(btnName == 'CancelledCheque'){
        documentRecordId({loanApplicationId:this.recordId,docType : 'Cancelled Cheque','dealId' : this.dealId}).then(result=>{
          console.log('documentRecordId',result);
          this.title = "View Cancelled Cheque";
          this.documentRecordId = result;
          this.isLoading = false;
          this.showPhotoCopy = false;
          this.showDocView = true;
          this.docType = "Cancelled Cheque";          
          this.showUpload = true;
          this.isAllDocType = false;
          this.viewDocFlag = true;
          this.isVehicleDoc = true;
        }).catch(error=>{
          console.error('error',error);
        });
      }
    } catch (error) {
      console.log("Error in handleViewDocHandler", error);
    }
  }

  async handleSubmitACH() {
    try {
      let isValid = true;
      let allInputElements = this.template.querySelectorAll(".mandatory");
      for (let elem of allInputElements) {
        if (elem && elem.value === "No") {
          isValid = false;
          break;
        }
      }
      if (isValid) {
        let isAllDocsAvailable = await validateACHDocs({ loanApplicationId: this.recordId });
        if(isAllDocsAvailable === AchChequeAvailable){
            console.log('All good to proceed');
            let payload=this.createPayload();
            this.updateRecordDetails(payload);
            //await submitACH({loanApplicationId:this.recordId});
            await updateLoanTransaction({loanApplicationId:this.recordId,module:'Post Sanction Checks and Documentation', dealId:this.dealId});
            this.isReadOnly = true;
            this.isPostReadOnly = true;
        }else if (isAllDocsAvailable === AchChequeNotAvailable){
          this.showToast('',AchBothMandatoryToastMsg,'error');
        }else if( isAllDocsAvailable === AchMandateAvailable){
          this.showToast('',ChequeMandatoryToastMsg,'error');
        }else if (isAllDocsAvailable === ChequeMandateAvailable){
          this.showToast('',AchMandateMandatoryToastMsg,'error');
        }
      } else {
        this.showToast("Error", "All ACH checklist items should be Yes to proceed", "error");
      }
    } catch (e) {
      console.log("error in handleSubmitACH" + e);
    }
  }

  showToast(title, message, variant) {
    const event = new ShowToastEvent({ title: title, message: message, variant: variant });
    this.dispatchEvent(event);
  }


  createPayload(){
    const RepaymentFields = {};
    RepaymentFields[repayment_Id.fieldApiName] = this.repaymentid;
    RepaymentFields[SB_Or_CAis_ticked_appropriately__c.fieldApiName] = this.sbOrCaTickedField;
    RepaymentFields[Correct_bank_name_is_filled__c.fieldApiName] = this.correctBankNameField;
    RepaymentFields[CFD_9_digit_loan_no_is_filled_correctly__c.fieldApiName] = this.cfdFilledCorrectField;
    RepaymentFields[Fill_Email_ID__c.fieldApiName] = this.fillEmailField;
    RepaymentFields[Name_of_A_c_holder_is_filled_in_CAPITAL__c.fieldApiName] = this.nameOfAcHolderField;
    RepaymentFields[Confirm_that_all_Mandate_details_are_cor__c.fieldApiName] = this.confirmMandateDetailsField;
    RepaymentFields[Bank_Account_No_is_correct_and_complete__c.fieldApiName] = this.bankAccNoIsCorrectField;
    RepaymentFields[Correct_IFSC_code_is_filled__c.fieldApiName] = this.correctIFSCCodeField;
    RepaymentFields[Correct_EMI_frequency_is_ticked__c.fieldApiName] = this.correctEMIFrequencyField;
    RepaymentFields[Customer_code_in_Reference_Il__c.fieldApiName] = this.customedCodeField;
    RepaymentFields[Correct_deal_date_or_PACT_PR_date_is_fil__c.fieldApiName] = this.correctDealDateField;
    RepaymentFields[Bank_A_c_holder_has_signed_the_ACH_Manda__c.fieldApiName] = this.achMandateSignedField;
    //RepaymentFields[ACH_Form_filled_correctly__c.fieldApiName] = this.achFilledCorrectlyField;
    RepaymentFields[Leftside_Create_Modify_ticked__c.fieldApiName] = this.leftCreateModifyTickedField;
    RepaymentFields[Correct_MICR_code_is_filled__c.fieldApiName] = this.correctMICRField;
    RepaymentFields[Debit_optn_type_to_be_ticked_as_Max_Amnt__c.fieldApiName] = this.debitOptnTypeMaxAmntField;
    RepaymentFields[EMl_Amt_Is_filled_correctly__c.fieldApiName] = this.emiAmntCorrectField;
    RepaymentFields[Copy_of_bank_P_B_and_or_specimen_cheque__c.fieldApiName] = this.copySpecimenChequeField;
    RepaymentFields[Correct_Last_EMl_date_2_months_is_fill__c.fieldApiName] = this.correctLastEmiDateField;
    RepaymentFields[Correct_mobile_or_landline_no_is_filled__c.fieldApiName] = this.correctMobileNoField;
    return RepaymentFields;
  }

  handleInputFieldChange(event) {
    const fieldName = event.target.name;

    if (fieldName === "sbOrCaTickedField") {
      this.sbOrCaTickedField = event.target.value;
    }
    if (fieldName === "bankAccNoIsCorrectField") {
      this.bankAccNoIsCorrectField = event.target.value;
    }
    if (fieldName === "leftCreateModifyTickedField") {
      this.leftCreateModifyTickedField = event.target.value;
    }
    if (fieldName === "correctBankNameField") {
      this.correctBankNameField = event.target.value;
    }
    if (fieldName === "correctIFSCCodeField") {
      this.correctIFSCCodeField = event.target.value;
    }
    if (fieldName === "correctMICRField") {
      this.correctMICRField = event.target.value;
    }
    if (fieldName === "emiAmntCorrectField") {
      this.emiAmntCorrectField = event.target.value;
    }
    if (fieldName === "correctEMIFrequencyField") {
      this.correctEMIFrequencyField = event.target.value;
    }
    if (fieldName === "debitOptnTypeMaxAmntField") {
      this.debitOptnTypeMaxAmntField = event.target.value;
    }
    if (fieldName === "cfdFilledCorrectField") {
      this.cfdFilledCorrectField = event.target.value;
    }
    if (fieldName === "customedCodeField") {
      this.customedCodeField = event.target.value;
    }
    if (fieldName === "correctMobileNoField") {
      this.correctMobileNoField = event.target.value;
    }
    if (fieldName === "fillEmailField") {
      this.fillEmailField = event.target.value;
    }
    if (fieldName === "correctDealDateField") {
      this.correctDealDateField = event.target.value;
    }
    if (fieldName === "correctLastEmiDateField") {
      this.correctLastEmiDateField = event.target.value;
    }
    if (fieldName === "nameOfAcHolderField") {
      this.nameOfAcHolderField = event.target.value;
    }
    if (fieldName === "achMandateSignedField") {
      this.achMandateSignedField = event.target.value;
    }
    if (fieldName === "copySpecimenChequeField") {
      this.copySpecimenChequeField = event.target.value;
    }
    if (fieldName === "confirmMandateDetailsField") {
      this.confirmMandateDetailsField = event.target.value;
    }
    if (fieldName === "achFilledCorrectlyField") {
      this.achFilledCorrectlyField = event.target.value;
    }
    if(fieldName==='isAchMandateLegibleField'){
      this.isAchMandateLegibleField=event.target.value;
    }
    if(fieldName==='isCancelledChequeLegibleField'){
      this.isCancelledChequeLegibleField=event.target.value;
    }
   
  }
  handleRemarksChange(event){
    const fieldName = event.target.name;

    if(fieldName==='cancelledChequeremarksField'){
      this.cancelledChequeremarksField=event.target.value;
    }
    if(fieldName==='achMandateRemarks'){
      this.achMandateRemarks=event.target.value;
    }
    if(fieldName==='achFormRemarksField'){
      this.achFormRemarksField=event.target.value;
    }
  }
  updateRecordDetails(fields) {
      const recordInput = { fields };
      console.log('before update ', recordInput);
      updateRecord(recordInput)
          .then(() => {
              this.showToast('Success',' ','success');
          })
          .catch(error => {
              console.log('record update error', error);
          });
  }
  handlePreDisbursementACH(){
    let isValid=true;
    if(this.isAchMandateLegibleField==='No' && !this.achMandateRemarks){
      this.showToast('Error','ACH Mandate Remarks is mandatory','error');
      isValid=false;
    }else if(this.isCancelledChequeLegibleField==='No' && !this.cancelledChequeremarksField){
      this.showToast('Error','Cancelled Cheque Remarks is mandatory','error');
      isValid=false;
    }else if(this.achFilledCorrectlyField==='No' && !this.achFormRemarksField){
      this.showToast('Error','ACH Form Remarks is mandatory','error');
      isValid=false;
    }
    if(isValid){
      const RepaymentFields = {};
      RepaymentFields[repayment_Id.fieldApiName] = this.repaymentid;
      RepaymentFields[ACH_Form_filled_correctly__c.fieldApiName] = this.achFilledCorrectlyField;
      RepaymentFields[ACH_Form_Remarks__c.fieldApiName] = this.achFormRemarksField;
      RepaymentFields[Cancelled_Cheque_Remarks__c.fieldApiName] = this.cancelledChequeremarksField;
      RepaymentFields[ACH_Mandate_Remarks__c.fieldApiName] = this.achMandateRemarks;
      RepaymentFields[Is_ACH_Mandate_legible__c.fieldApiName] = this.isAchMandateLegibleField;
      RepaymentFields[Is_Cancelled_Cheque_legible__c.fieldApiName] = this.isCancelledChequeLegibleField;
      this.updateRecordDetails(RepaymentFields);
      updateLoanTransaction({loanApplicationId:this.recordId,module:'Pre Disbursement Check', dealId:this.dealId})
      .then(()=>{
        this.isReadOnly = true;
        this.isPostReadOnly = true;
      }).catch((err)=>{
        console.log("handlePreDisbursementACH error"+err);
      })
    }
  }

  docUploadSuccessfully(event) {
    try{
      console.log('docUploadSuccessfully', event);
    }catch(err){
      console.log("docUploadSuccessfully error ", err);
    }
  }
}