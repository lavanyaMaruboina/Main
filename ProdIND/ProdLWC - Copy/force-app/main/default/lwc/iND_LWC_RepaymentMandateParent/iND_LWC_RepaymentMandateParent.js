import { api, LightningElement, track, wire } from "lwc";
import getAuthorizationMode from "@salesforce/apex/RepaymentScreenController.getAuthorizationMode";
import getRepaymentToBeDoneBy from "@salesforce/apex/RepaymentScreenController.getRepaymentToBeDoneBy";
import getLoanAmount from "@salesforce/apex/RepaymentScreenController.getLoanAmount";
import getFinalTermRecord from "@salesforce/apex/RepaymentScreenController.getFinalTermRecord";
import getlstEMIDueDate from "@salesforce/apex/RepaymentScreenController.getlstEMIDueDate";
import AUTO_PAY_LIMIT_NUMBER from "@salesforce/label/c.Auto_Pay_Limit_Number";
import createRepaymentRecord from "@salesforce/apex/RepaymentScreenController.createRepaymentRecord";
import doPennyDropAPICallout from "@salesforce/apex/IntegrationEngine.doPennyDropAPICallout"; 
import EXCEPTIONMESSAGE from '@salesforce/label/c.ExceptionMessage';
import repayment_Id from "@salesforce/schema/Repayments__c.Id";
import Repayment_to_be_done_by__c from "@salesforce/schema/Repayments__c.Repayment_to_be_done_by__c";
import Bank_Master__c from "@salesforce/schema/Repayments__c.Bank_Master__c";
import Authorization_mode_available__c from "@salesforce/schema/Repayments__c.Authorization_mode_available__c";
import Is_Netbanking_available_with_customer__c from "@salesforce/schema/Repayments__c.Is_Netbanking_available_with_customer__c";
import Is_debit_card_available_with_customer__c from "@salesforce/schema/Repayments__c.Is_debit_card_available_with_customer__c";
import Repayment_Method__c from "@salesforce/schema/Repayments__c.Repayment_Method__c";
import Loan_Amount__c from "@salesforce/schema/Repayments__c.Loan_Amount__c";
import Loan_Application__c from "@salesforce/schema/Repayments__c.Loan_Application__c";
import EMI_Amount__c from "@salesforce/schema/Repayments__c.EMI_Amount__c";
import Created_Date__c from "@salesforce/schema/Repayments__c.Created_Date__c";
import End_Date__c from "@salesforce/schema/Repayments__c.End_Date__c";
import Until_Cancelled__c from "@salesforce/schema/Repayments__c.Until_Cancelled__c";
import lst_EMI_Due_Date__c from "@salesforce/schema/Repayments__c.lst_EMI_Due_Date__c";
import Frequency__c from "@salesforce/schema/Repayments__c.Frequency__c";
import IFSC_Code__c from "@salesforce/schema/Repayments__c.IFSC_Code__c";
import Account_Number__c from "@salesforce/schema/Repayments__c.Account_Number__c";
import Remarks__c from "@salesforce/schema/Repayments__c.Remarks__c";
import Repayments_Captured_Correctly__c from "@salesforce/schema/Repayments__c.Repayments_Captured_Correctly__c";
import Repayment_Method_Retry_Count__c from "@salesforce/schema/Repayments__c.Repayment_Method_Retry_Count__c";
import RepaymentsRecordType from "@salesforce/schema/Repayments__c.RecordTypeId";
import { getObjectInfo, getPicklistValues } from "lightning/uiObjectInfoApi";
import REPAYMENTS_OBJECT from "@salesforce/schema/Repayments__c";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import ENACH_NETBANKING_DEBIT_ERROR from "@salesforce/label/c.ENACH_Netbanking_Debit_error";
import ENACH_Option_For_Indusind_Bank_Error from "@salesforce/label/c.ENACH_Option_For_Indusind_Bank_Error";
import SI_Option_For_Different_Bank_Error from "@salesforce/label/c.SI_Option_For_Different_Bank_Error";
import isLoanAgreementSubmitted from "@salesforce/apex/RepaymentScreenController.isLoanAgreementSubmitted";
import unsubmitLoanTransaction from "@salesforce/apex/RepaymentScreenController.unsubmitLoanTransaction";////CISP-1223
import submitLoanTransaction from "@salesforce/apex/RepaymentScreenController.submitLoanTransaction";
import getAllPennyDropValidations from "@salesforce/apex/RepaymentScreenController.getAllPennyDropValidations";

import doTextMatchCalloutForPennyDrop from '@salesforce/apexContinuation/IntegrationEngine.doTextMatchCallout';
import isCheckReadOnly from "@salesforce/apex/RepaymentScreenController.isCheckReadOnly";
// import IIB_ACCOUNT_ERROR from "@salesforce/label/c.Applicant_Or_Co_Applicant_Willing_To_Open_Acc_Error";
import LOAN_AGREEMENT_SCREEN_ERROR from "@salesforce/label/c.LoanAgreScrSubmitError";
import ACCOUNT_FORMAT_ERROR from "@salesforce/label/c.AccountFormatError";
import UpdateToastMsg from "@salesforce/label/c.UpdateToastMsg";
import Mandatory_fields_are_not_entered from "@salesforce/label/c.Mandatory_fields_are_not_entered";
import { updateRecord, getRecord, getFieldValue } from "lightning/uiRecordApi";
import getRepaymentModePickListValue from '@salesforce/apex/FinalTermscontroller.getRepaymentModePickListValue';
import USER_ID from '@salesforce/user/Id';
import USER_MAKER_ID from "@salesforce/schema/User.Maker_Id__c";
import Tractor from '@salesforce/label/c.Tractor';
import DEAL_NUMBER from "@salesforce/schema/Deal_Number__c.Deal_Number__c";
import runningInstance from "@salesforce/apex/RepaymentScreenController.runningInstance";
import UATPennyDropBeneficiary from "@salesforce/label/c.UATPennyDropBeneficiary";
import Name_Match_Percentage__c from "@salesforce/schema/Repayments__c.Name_Match_Percentage__c";
import checkPennyDropApiAttempts from '@salesforce/apex/RepaymentScreenController.checkPennyDropApiAttempts';
import isPennyDropApiExhausted from '@salesforce/apex/RepaymentScreenController.isPennyDropApiExhausted';
import Retry_Exhausted from '@salesforce/label/c.Retry_Exhausted';
import SuccessMessage from '@salesforce/label/c.SuccessMessage';
import updateRetryPennyDropAttempts from '@salesforce/apex/RepaymentScreenController.updateRetryPennyDropAttempts';
import createBankAndChequeDoc from '@salesforce/apex/RepaymentScreenController.createBankAndChequeDoc';
import getBankAndChequeDocForRepayment from '@salesforce/apex/RepaymentScreenController.getBankAndChequeDocForRepayment';
import getDocumentFiles from '@salesforce/apex/IHMPageController.getDocumentFiles';
import { NavigationMixin } from 'lightning/navigation';
import getContentVersion from '@salesforce/apex/SecurityMandate.getContentVersion';
export default class IND_LWC_RepaymentMandateParent extends NavigationMixin(LightningElement)  {
  @track label = {
    Retry_Exhausted,
    SuccessMessage,
  }
  @api dealId = null;matchScore;@track enablePennyDrop = false;@track ispennyDropShow = false;isPreview = false;@track disableCaptureBankImage = false;
  @track showChequePreview = false; @track showBankPreview = false;documentValues;isCommunityUser = false;converId;height = 32;@track isPostSanction = false; @track disableChequeImage = false;
  tenure;
  @api currentStep;
  @track stageName;
  @track yesNoOption;
  @track repaymentMethodOption;
  @track untilCancelledFlag = false;
  @track untilCancelled = "No";
  @track eNachFlag = false;
  @track achFlag = false;
  @track siFlag = false;
  @track repaymentMethod;
  @track accordionActiveSection = "";
  @track initialRepaymentOptions;
  // @track noOption = "";
  @api recordId; //Opportunity Id
  @api applicantId;
  @track repaymentDoneBy;
  @track loanAmount;
  @track emiAmount;
  @track lstEMIDueDate;
  @track autoPayLimitAmount;
  frequency = 'Monthly';
  // @track frequencyOptions;
  @track startDate;
  @track endDate;
  @track bank;
  @track bankId;
  @track records;
  @track autoPayLimitAmount;
  @track checkRepaymentDetailsField = "";
  @track isNetBankingAvailable = "No";
  @track isDebitCardAvailable = "No";
  @api repaymentRecordId; //repaymentRecordId
  @track authorizationModeAvailable;
  @track ifscCode;
  @track accountNumber;
  @track remarks;
  @track repaymentMethodChangeCount = 0;
  @track repaymentMethodValueChanged;
  @track applicantEmail;
  @track applicantPhone;
  @track customerCode;
  @track productType;
  @track isSpinnerMoving = false;
  isDisabled = false;
  eNachStatus;
  isSubmitDisabled = false;
  siDefaultMethod = 'SI Online';
  isApplWillingToOpenAcc = false;
  isLoanAgrSubmitted = true;
  comboboxValue;
  isPVorTW = false;
  leadSource; //D2C Swapnil
  // iibAccError = IIB_ACCOUNT_ERROR;
  loanAgreementScreenError = LOAN_AGREEMENT_SCREEN_ERROR;
  @api isInputChanged = false;
  @api isInvokedFromFinalOffer = false;
  @track pennyDropValidation = [];
  @track isSandbox;
  get isEndDateDisabled() {
    return this.isDisabled;
  }

  @wire(getObjectInfo, { objectApiName: REPAYMENTS_OBJECT })
  objectInfo;

  @wire(getRecord, { recordId: USER_ID, fields: [USER_MAKER_ID] })
  userData;

  // Get user Id from the current context
  get makerId() {
      return this.userData.data ? this.userData.data.fields.Maker_Id__c.value : null;
  }
  // @wire(getPicklistValues, { recordTypeId: "$objectInfo.data.defaultRecordTypeId", fieldApiName: Frequency__c })
  // frequencyOptions;


  @wire(getRecord, { recordId: '$dealId', fields: [DEAL_NUMBER] })
  DealData;

  get dealNumber(){
    return this.DealData.data ? this.DealData.data?.fields?.Deal_Number__c?.value : null;
  }
  get repaymentScreenVisible() {
    return this.isLoanAgrSubmitted;
  }
  get isTW(){
    return this.productType === 'Two Wheeler';
    }

  @track isWouldYouLikeBankAccount;
  @api isRevokedLoanApplication;//CISP-2735
  async connectedCallback() {
    this.checkSubmitDisable = false;//CISP-4600
    await runningInstance({}).then(result=>{
      if(result){ this.isSandbox = result;}
    }).catch(error=>{console.log(error);});
    let result = await getRepaymentModePickListValue({'loanApplicationId' : this.recordId});
    let pickListValues = [];
    let keys = Object.keys(result);

    await keys.forEach((key) => {
        pickListValues.push({'label' : result[key] , 'value' : key});
    });
    this.repaymentMethodOption = pickListValues;
      await getRepaymentToBeDoneBy({ loanApplicationId: this.recordId })
      .then((result) => {
        if (result != null) {
          this.leadSource = result?.leadSource;//D2C Swapnil
          console.log('result test ', result);
          this.repaymentDoneBy = result.repaymentDoneBy;
          this.isApplWillingToOpenAcc = result.isApplWillingToOpenAcc;
          this.isWouldYouLikeBankAccount = result.isWouldYouLikeBankAccount;
          this.applicantId = result.applicantId;
          this.applicantEmail = result.applicantEmail;
          this.applicantPhone = result.applicantPhone;
          this.customerCode = result.customerCode;
          this.productType = result.productType;
          this.stageName = result.stageName;
          if(!this.leadSource && (this.productType == 'Passenger Vehicles' || this.productType == 'Two Wheeler' || this.productType == 'Tractor') && (this.stageName == 'Post Sanction Checks and Documentation' || this.stageName =='Final Offer')){
            this.enablePennyDrop = false; this.ispennyDropShow = true;this.isPostSanction = true;
          }else if (!this.leadSource && (this.productType == 'Passenger Vehicles' || this.productType == 'Two Wheeler' || this.productType == 'Tractor') && this.stageName === 'Pre Disbursement Check'){
            this.enablePennyDrop = true;this.ispennyDropShow = true;
          }else{
            this.enablePennyDrop = true;
          }
          if(this.productType == 'Passenger Vehicles' || this.productType == 'Two Wheeler'){
            this.isPVorTW = true;
          }
          // var repaymentMethodList = new Array();
          // if(this.productType == Tractor){
          //   let pickListValues = [];
          //   let keys = Object.keys(repaymentOptionsTractor);

          //   keys.forEach((key) => {
          //       pickListValues.push({'label' : repaymentOptionsTractor[key] , 'value' : key});
          //   });
          //   this.repaymentMethodOption = pickListValues;
          // }else{
          //   //D2C Swapnil removed ACH value for D2C
          //   if(this.leadSource !== 'D2C'){
          //     repaymentMethodList.push({ label: "ACH", value: "A" });
          //   }
          //   if(this.isWouldYouLikeBankAccount){
          //     repaymentMethodList.push({ label: "IES", value: "S" }); //CISP: 3579
          //     this.repaymentMethod = 'S';
          //     this.isDisabled = true;
          //   }
          //   if(!this.isApplWillingToOpenAcc){
          //     repaymentMethodList.push({ label: "e-NACH", value: "N" });
          //     repaymentMethodList.push({ label: "SI", value: "I" });
          //   }
          //   this.repaymentMethodOption = repaymentMethodList;
          // }
          getFinalTermRecord({ loanApplicationId: this.recordId, dealId: this.dealId })
          .then((result) => {
            if (result != null) {
              console.log('OUTPUT getFinalTermRecord: ',result);
              if(this.productType==Tractor && result.Installment_Frequency__c){
                this.frequency=result.Installment_Frequency__c;
              }
              this.tenure = result.Tenure__c;
              let holidayPeriod = result.Holiday_period__c;
              if(holidayPeriod == 30 && this.leadSource!='OLA'){//OLA-139
                this.tenure = (parseFloat(this.tenure) -1) + 3;
              }else{
                this.tenure = parseFloat(this.tenure) + 3
              }
              console.log('final tenure' ,  this.tenure);
              console.log('emiAmount1' + result.EMI_Amount__c);
              this.emiAmount = result.EMI_Amount__c;
              console.log('emiAmount2' + this.emiAmount);
              let repaymentMode = result.Repayment_mode__c;

              //if invoked from Final Offer then repayment method is disabled so displaying the value present in Final Terms
              if(this.isTW){
                if(this.isInvokedFromFinalOffer){
                  this.repaymentMethod = repaymentMode;
                }
              }

              //CISP-4181 Remove other values apart from ACH in repaymentMethodOptions if the repayment mode is e-NACH
              if(repaymentMode == 'N') {
                let valuesToKeep = ['A','N'];
                this.repaymentMethodOption = this.repaymentMethodOption.filter(item => valuesToKeep.includes(item.value));
              }
              if(this.productType == Tractor){
                for (var i = 0; i < this.repaymentMethodOption.length; i++) {
                  if (this.repaymentMethodOption[i].value === repaymentMode) {
                    this.repaymentMethod = repaymentMode;
                    console.log("Repayment value--->Success");
                    }
                  }
              }else{
                for (var i = 0; i < this.repaymentMethodOption.length; i++) {
                  if (this.repaymentMethodOption[i].value === repaymentMode) {
                    this.repaymentMethod = repaymentMode;
                    console.log("Repayment value--->Success");
                  }
                }
             }
              this.autoPayLimitAmount = AUTO_PAY_LIMIT_NUMBER * this.emiAmount;
            }
          })
          .catch((error) => {
            this.error = error;
            console.log("Error in getFinalTermRecord connectedCallback Function ::" + error);
          });
        }
      })
      .catch((error) => {
        this.error = error;
        console.log("Error in getRepaymentToBeDoneBy connectedCallback Function ::" + error);
      });

    isLoanAgreementSubmitted({ loanApplicationId: this.recordId, dealId: this.dealId }).then(result => {
      this.isLoanAgrSubmitted = result;
      console.log('Check --> ', this.isLoanAgrSubmitted, ' ', this.isApplWillingToOpenAcc);
    }).catch(error => {
      console.error('error in isLoanAgreementSubmitted ', error);
    });

    var yesNoOptionList = new Array();
    yesNoOptionList.push({ label: "Yes", value: "Yes" });
    yesNoOptionList.push({ label: "No", value: "No" });
    this.yesNoOption = yesNoOptionList;
    this.initialRepaymentOptions = [...this.repaymentMethodOption];
    var today = new Date();

    this.startDate = today.getFullYear() + "-" + (today.getMonth() + 1) + "-" + today.getDate();

    getLoanAmount({ loanApplicationId: this.recordId, dealId: this.dealId })
      .then((result) => {
        if (result != null) {
          let loanAmt = (result.Loan_Amount__c == null || result.Loan_Amount__c == undefined) ? 0 : result.Loan_Amount__c;
          let totalPreminumFundAmt = (result.Loan_Application__r.Total_Funded_Premium__c == null || result.Loan_Application__r.Total_Funded_Premium__c == undefined) ? 0 : result.Loan_Application__r.Total_Funded_Premium__c;
          this.loanAmount = parseFloat(loanAmt) + parseFloat(totalPreminumFundAmt);
        }
      })
      .catch((error) => {
        this.error = error;
        console.log("Error in getLoanAmount connectedCallback Function ::" + error);
      });

    getlstEMIDueDate({ loanApplicationId: this.recordId, dealId: this.dealId })
      .then((result) => {
        if (result != null) {
          console.log("Inside getlstEMIDueDate function in connectedcallback");
          this.lstEMIDueDate = result.Ist_EMI_Due_Date__c;
        }
      })
      .catch((error) => {
        this.error = error;
        console.log("Error in getlstEMIDueDate connectedCallback Function ::" + error);
      });

    this.handlecreateRepaymentRecord(null);
    if(this.isRevokedLoanApplication){this.disableEverything();}//CISP-2735
    getBankAndChequeDocForRepayment({loanApplicationId :this.recordId,dealId: this.dealId}).then(data =>{
      console.log('data from document',data);
      this.documentValues = data;
      if(Object.keys(data).length > 0){
        if(data['Cheques SPDC']){this.showChequePreview = true; this.disableChequeImage = true;}
        if(data['Customer Bank Statement']){this.showBankPreview = true; this.disableCaptureBankImage = true;}
        if(data['isCommunityUser']){this.isCommunityUser = data['isCommunityUser']}
      }
    }).catch(error =>{})//SFTRAC-1901
    isPennyDropApiExhausted({loanApplicationId : this.recordId,dealId :this.dealId }).then(data =>{
      if(data == this.label.Retry_Exhausted){
        this.enablePennyDrop = true;
      }
    }).catch(error=>{});
    getAllPennyDropValidations().then(res =>{
      console.log(res,'res from pennydrop');
      if(res.length > 0){
        let newArray = [];
        res.forEach(item => {
          if(item.Status_Description__c !=null){
            newArray.push(item.Status_Description__c);
          }
        })
        this.pennyDropValidation = newArray;
      }
    }).catch(err => {
      console.log(err,'err from pennydrop');
    });
  }
  renderedCallback(){
    if(this.isRevokedLoanApplication){this.disableEverything();}//CISP-2735
    if(this.stageName == 'Post Sanction Checks and Documentation' && this.repaymentMethod == 'S'){
      this.ispennyDropShow = false;this.enablePennyDrop = true;
      this.template.querySelector('lightning-input[data-id="ifscCodeId"]').disabled = true;
      this.template.querySelector('lightning-input[data-id="accountNumberId"]').disabled = true;
      if(this.isPVorTW){
        this.template.querySelector('lightning-input[data-id="accountName"]').disabled = true;
      }
    }else{
      this.template.querySelector('lightning-input[data-id="ifscCodeId"]').disabled = false;
      this.template.querySelector('lightning-input[data-id="accountNumberId"]').disabled = false;
      if(this.isPVorTW){
        this.template.querySelector('lightning-input[data-id="accountName"]').disabled = false;
      }
    }
  }
  disableEverything(){
      let allElements = this.template.querySelectorAll('*');
      allElements.forEach(element => {
        element.disabled = true;
        //CISP-4181 Do not disable back button on when called from final offer screen
        if(element.name == 'Back') {
          element.disabled = false;
        }
      });
  }//CISP-2735-END

  handleInputFieldChange(event) {
    this.isInputChanged = true;
    const fieldName = event.target.name;

    if (fieldName == "checkRepaymentDetailsField") {
      this.checkRepaymentDetailsField = event.target.value;
    }
    if (fieldName == "isNetbankingAvailableField") {
      this.isNetBankingAvailable = event.target.value;
    }
    if (fieldName == "isDebitCardAvailableField") {
      this.isDebitCardAvailable = event.target.value;
    }
    if (fieldName == "endDateField") {
      this.endDate = event.target.value;
    }
    if (fieldName == "ifscCodeField") {
      this.ifscCode = event.target.value;
    }
    if (fieldName == "remarksField") {
      this.remarks = event.target.value;
    }
    if (fieldName === "frequencyField") {
      this.frequency = event.target.value;
    }

  }

  handleAccountOnFocusout(event) {
    this.isInputChanged = true;
    var fieldName = event.target.name;
    var accountNumber = event.target.value;
    var regularExpression = new RegExp('^[0-9]*$');
    console.log('handleAccountOnFocusout ', fieldName, ' ', accountNumber);
    if (fieldName == "accountNumberField") {
      if (!regularExpression.test(accountNumber) && accountNumber != '') {
        this.showToast(ACCOUNT_FORMAT_ERROR, 'Warning');
        return;
      }
      this.accountNumber = accountNumber;
    }
  }

  handleUntilCancelledChange(event) {
    this.untilCancelled = event.target.value;
    if (this.untilCancelled === "Yes") {
      this.untilCancelledFlag = true;
    }
    if (this.untilCancelled === "No") {
      this.untilCancelledFlag = false;
    }
    this.repaymentMethodOption = [...this.initialRepaymentOptions];
    //if(this.bank == 'INDUSIND BANK LTD' && this.isPVorTW == true){  
    //  console.log('indusbank selected');
    //  let valuesToRemove = ['N'];
     // this.repaymentMethodOption = this.repaymentMethodOption.filter(item => !valuesToRemove.includes(item.value));
   // }
  }
  selectedStateHandler(event) {
    this.bankId = event.detail.selectedValueId;
    this.bank = event.detail.selectedValueName;
    this.records = event.detail.records;
   getAuthorizationMode({ bankName: this.bank })
      .then((result) => {
        this.authorizationModeAvailable = result;
      })
      .catch((err) => {
        console.log('getAuthorizationMode Error' + err);
      });
      this.repaymentMethodOption = [...this.initialRepaymentOptions];
      if(this.bank == 'INDUSIND BANK LTD' && this.isPVorTW == true){  
        console.log('indusbank selected');
        let valuesToRemove = ['N'];
        this.repaymentMethodOption = this.repaymentMethodOption.filter(item => !valuesToRemove.includes(item.value));
      }
    }
  get authorizationModeAvailableOptions()
  {
    if (typeof this.authorizationModeAvailable === 'string') 
    {
      let splittedValues = this.authorizationModeAvailable.split(';');
      let newOption = splittedValues.map( (element) =>{
        return { label: `${element}`, value: `${element}`};
      });

      return newOption;
      }
    else {
      console.log('authorizationModeAvailable is undefined');
    }
  }

  handleChange(event)
  {
      this.comboboxValue = event.target.value;
      console.log('comboboxValue is: ',this.comboboxValue);
  }
  //SFTRAC-1901 start
  handlePennyDropApiCall(){
    if(!this.accountNumber) return this.showToast('Account No is Missing', "error", 'Error');
    if(!this.ifscCode) return this.showToast('IFSC Code is Missing', "error", 'Error');
    if(this.repaymentMethod == 'A' && this.bank == 'INDUSIND BANK LTD') return this.showToast('INDUSIND BANK LTD is not applicable for ACH or e-Nach', "error", 'Error');
    if(this.repaymentMethod == 'N' && this.bank == 'INDUSIND BANK LTD') return this.showToast('INDUSIND BANK LTD is not applicable for ACH or e-Nach', "error", 'Error');
    if(this.repaymentMethod == 'I' && this.bank != 'INDUSIND BANK LTD') return this.showToast('Please select INDUSIND BANK LTD only to proceed further', "error", 'Error');
    if(this.repaymentMethod == 'S' && this.bank != 'INDUSIND BANK LTD') return this.showToast('Please select INDUSIND BANK LTD only to proceed further', "error", 'Error');
    this.isSpinnerMoving = true;
    checkPennyDropApiAttempts({loanApplicationId : this.recordId,dealId :this.dealId }).then(data =>{
      console.log('data--',data);
      if(data == this.label.SuccessMessage){
        this.pennyDropAPICalloutTractor().then(pennyDropResponse =>{

          if(pennyDropResponse){

            if(pennyDropResponse.status == 'SUCCESS'){
              if(pennyDropResponse?.content[0]?.StatusCode == 'R000'){
                this.showToast('PennyDrop Callout Succeed', "success", 'Success');
                this.callTextMatchApi(pennyDropResponse?.content[0]?.BeneficiaryName);
                this.enablePennyDrop = true;
                this.isSpinnerMoving = false;
              }
              else{
                console.log('in first else');
                if(this.pennyDropValidation.includes(pennyDropResponse?.content[0]?.StatusDesc)){
                this.showToast(pennyDropResponse?.content[0]?.StatusDesc, "error", 'Error');
                this.isSpinnerMoving = false;
                this.updateRetryAttempts();
                }
                else {
                  this.isSpinnerMoving = false;
                  this.enablePennyDrop = true;
                  this.showToast(pennyDropResponse?.content[0]?.StatusDesc, "info", 'Information');
                }
              }

            }
            else if(pennyDropResponse.status == 'FAILED'){
              console.log('in second  else');
                this.showToast('PennyDrop Callout Failed', "error", 'Error');
                this.isSpinnerMoving = false;
                this.updateRetryAttempts();
            }
            else{
              if(pennyDropResponse.errorMessage != null){
                console.log('in third else');
                this.showToast(pennyDropResponse.errorMessage, "error", 'Error');
                this.isSpinnerMoving = false;
                this.updateRetryAttempts();
              }
            }
          }
          else{
            console.log('in forth else');
            this.showToast('No response found. Please retry', "error", 'Error');
            this.isSpinnerMoving = false;
            //this.updateRetryAttempts();
            return;
          }
        })
      }else if(data == this.label.Retry_Exhausted){
        console.log('in retry attempts exhausted');
        this.enablePennyDrop = true;
        this.isSpinnerMoving = false;
        this.showToast(this.label.Retry_Exhausted, 'error', '');
      }
    }).catch(error =>{})
  }
  handleCaptureBankImage(){
    this.docType='Customer Bank Statement';
    this.title = 'Upload Bank Statement'
    this.uploadDocument();
  }
  isAllDocType;ContentDocumentId;uploadViewDocFlag;documentRecordId;docType;title;showUpload;showPhotoCopy;showDocView;isVehicleDoc;
  hideModalBox() {
    this.isPreview = false;
  }
  handleViewDocument(event) {
    let data = event.target.value;
    let contentDocId = this.documentValues[data];
    getDocumentFiles({ contentDocId: contentDocId,loanId : this.recordId }).then(result => {
      if (result != null) {
        let conDocId = result;
        if(this.isCommunityUser == true){
          getContentVersion({ conDocId: conDocId })
            .then(result => {
              this.converId = result[0].Id;
              this.isPreview = true;
            })
            .catch(error => {
              console.error('Error:', error);
          });
        }else{
          this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
              pageName: 'filePreview'
            },
            state: {
              selectedRecordId: result
            }
          });
        }
      }
    })
  }
  
  docUploadSuccessfully(event){
    console.log('OUTPUT docUploadSuccessfully: ',);
    this.ContentDocumentId = event.detail;
  }
  changeFlagValue(event) {
    this.uploadViewDocFlag = false;
    if(event.detail != undefined) {
        console.log('uploadresponse..'+JSON.stringify(event.detail));
        var docIdObj = event.detail;
        this.documentRecordId = docIdObj.DocumentId;
        if(this.docType == 'Customer Bank Statement'){this.disableCaptureBankImage = true;}
        if(this.docType == 'Cheques SPDC'){this.disableChequeImage = true;}
    }
}
  uploadDocument(){
    createBankAndChequeDoc({ docType: this.docType, loanApplicationId: this.recordId,dealId :this.dealId ,applicantId: this.applicantId }).then(result => {
      this.documentRecordId = result;
      this.showUpload = true;
      this.showDocView = false;
      this.isVehicleDoc = true;
      this.isAllDocType = false;
      this.uploadViewDocFlag = true;
      this.showPhotoCopy = false;
  }).catch(error => {
      console.log('Create Other Document:: ', error);
  });
  }
  handleCaptureChequeImage(){
    this.docType='Cheques SPDC';
    this.title = 'Upload Cheque';
    this.uploadDocument();
  }
  updateRetryAttempts(){
    updateRetryPennyDropAttempts({loanApplicationId : this.recordId,dealId :this.dealId }).then(data =>{
    }).catch(error =>{
      console.log('error in updateRetryPennyDropAttempts',error);
    })
  }//SFTRAC-1901 end
  @api
  handleSubmitRepaymentDetails() {
    if(this.repaymentMethod == 'A' && this.bank == 'INDUSIND BANK LTD') return this.showToast('INDUSIND BANK LTD is not applicable for ACH or e-Nach', "error", 'Error');
    if(this.repaymentMethod == 'N' && this.bank == 'INDUSIND BANK LTD') return this.showToast('INDUSIND BANK LTD is not applicable for ACH or e-Nach', "error", 'Error');
    if(this.repaymentMethod == 'I' && this.bank != 'INDUSIND BANK LTD') return this.showToast('Please select INDUSIND BANK LTD only to proceed further', "error", 'Error');
    if(this.repaymentMethod == 'S' && this.bank != 'INDUSIND BANK LTD') return this.showToast('Please select INDUSIND BANK LTD only to proceed further', "error", 'Error');

    this.isSpinnerMoving = true;
    const allValid = [...this.template.querySelectorAll("lightning-input")].reduce((validSoFar, inputCmp) => {
      inputCmp.reportValidity();
      return validSoFar && inputCmp.checkValidity();
    }, true);

    if (!this.bankId && !this.isWouldYouLikeBankAccount) {
      let lookupElem = this.template.querySelector("c-I-N-D_-L-W-C_-Custom_-Lookup");
      lookupElem.inputClass = "slds-has-error";
      lookupElem.showHide = "slds-show";
      this.isSpinnerMoving = false;
      return;
    }

    if (this.repaymentMethod === "N" && this.isNetBankingAvailable === "No" && this.isDebitCardAvailable === "No") {
      this.showToast(ENACH_NETBANKING_DEBIT_ERROR, "error"); 
      this.isSpinnerMoving = false;
      return;
    }
    if ((this.repaymentMethod === "I" || this.repaymentMethod === "S") && this.bank !== 'INDUSIND BANK LTD') {
      let msg = this.repaymentMethod === "I" ? SI_Option_For_Different_Bank_Error : 'IES option is only available for INDUSIND BANK LTD';//SFTRAC-1901
      this.showToast(msg, "error");
      this.isSpinnerMoving = false;
      return;
    }
    if (this.repaymentMethod === "N" && this.bank == 'INDUSIND BANK LTD' && this.isTW) {
      this.showToast(ENACH_Option_For_Indusind_Bank_Error, "error");
      this.isSpinnerMoving = false;
      return;
    }
     if (this.endDate == null && !this.isWouldYouLikeBankAccount) {
      this.showToast(Mandatory_fields_are_not_entered, 'warning');
      this.isSpinnerMoving = false;
      return;
     }
     if(this.endDate != null && this.startDate !=  null){
      var today = new Date();
      console.log('OUTPUT this.startDat: ',today);
      let dateObj = new Date(today.setMonth(today.getMonth()+ parseInt(this.tenure)));
      console.log('dateObj : ',dateObj);
      let endDateObj = new Date(this.endDate);
      console.log('endDateObj : ',endDateObj);
      if(endDateObj < dateObj){
        let message = 'Please select End Date greater than ' + this.tenure + ' months from the Start Date';
        this.showToast(message, 'error', 'Error');
        this.isSpinnerMoving = false;
        return;
      }
    }
    //SFTRAC-1901 start
    if(this.enablePennyDrop == false){
     let message = 'Please Initiate Penny Drop api';
       this.showToast(message, 'error', 'Error');
       this.isSpinnerMoving = false;
       return;
    }
    if(this.ispennyDropShow && ( this.disableCaptureBankImage  == false &&  this.disableChequeImage == false)){
     let message = 'Please upload either a Cheque, a Bank statement, or both';
       this.showToast(message, 'error', 'Error');
       this.isSpinnerMoving = false;
       return;
    }
    this.createRepaymentRecordHandler();//SFTRAC-1901 end
    //  if (this.isWouldYouLikeBankAccount) { 
      /*if(this.productType == Tractor && this.stageName == 'Post Sanction Checks and Documentation' && this.repaymentMethod != 'S') {
      
        this.pennyDropAPICalloutTractor().then(pennyDropResponse =>{

          if(pennyDropResponse){

            if(pennyDropResponse.status == 'SUCCESS'){

              if(pennyDropResponse?.content[0]?.StatusCode == 'R000'){
                this.showToast('PennyDrop Callout Succeed', "success", 'Success');
                this.callTextMatchApi(pennyDropResponse?.content[0]?.BeneficiaryName);
              }
              else{
                this.showToast(pennyDropResponse?.content[0]?.StatusDesc, "error", 'Error In PennyDrop Callout');
                this.isSpinnerMoving = false;
              }

            }
            else if(pennyDropResponse.status == 'FAILED'){
                this.showToast('PennyDrop Callout Failed', "error", 'Error');
                this.isSpinnerMoving = false;
            }
            else{
              if(pennyDropResponse.errorMessage != null){
                this.showToast(pennyDropResponse.errorMessage, "error", 'Error');
                this.isSpinnerMoving = false;
              }
            }
          }
          else{
            this.isSpinnerMoving = false;
            return;
          }
        })
      } else{
        this.createRepaymentRecordHandler();
      }*/
    // } else {
    //   this.showToast("Please select Yes, if you have checked the above repayment details", 'error', 'Error');
    //   this.isSpinnerMoving = false;
    // }
  }

  async pennyDropAPICalloutTractor(){
    let pennyDropbody;
    if(this.isSandbox){
       pennyDropbody = {BeneficiaryName : UATPennyDropBeneficiary, CreditAccountNumber : this.accountNumber, BeneficiaryBankIFSCCode : this.ifscCode, BeneficiaryMobileNumber : this.applicantPhone, EmailID : this.applicantEmail, CustomerCode : this.customerCode, DealNo : this.dealNumber, MakerId : this.makerId};
    }else{
       pennyDropbody = {BeneficiaryName : this.repaymentDoneBy, CreditAccountNumber : this.accountNumber, BeneficiaryBankIFSCCode : this.ifscCode, BeneficiaryMobileNumber : this.applicantPhone, EmailID : this.applicantEmail, CustomerCode : this.customerCode, DealNo : this.dealNumber, MakerId : this.makerId};
    }
      try{
     
        let pennyDropResponse = await doPennyDropAPICallout({requestBody : JSON.stringify(pennyDropbody), loanAppId: this.recordId});
        
          console.log(' doPennyDropAPICallout response '+JSON.stringify(pennyDropResponse));

          if(!pennyDropResponse){
            this.showToast('No response found. Please re-try', "error", 'Error');
            return null;
          } else{
            return pennyDropResponse;
        }
      }catch(error){
        this.showToast('No response found. Please re-try', "error", 'Error');
        return null;
      }

  }

  async createRepaymentRecordHandler(){
    await createRepaymentRecord({ loanApplicationId: this.recordId, data: this.createPayload(), dealId: this.dealId }).then((result) => {
    if (result != null) {
      this.repaymentRecordId = result.Id;
      const allValid = [...this.template.querySelectorAll("lightning-input")].reduce((validSoFar, inputCmp) => {
        inputCmp.reportValidity();
        return validSoFar && inputCmp.checkValidity();
      }, true);
      if (allValid) {
        this.isDisabled = true;
        this.isSubmitDisabled = true;
        this.disableCaptureBankImage = true;
        this.disableChequeImage = true;
        this.enablePennyDrop = true;
        //CISP-4181 Update value of Do_you_want_to_initiate_e_NACH__c field in final term record
        const evt = new CustomEvent('updatefinaltermrecord');
        this.dispatchEvent(evt);

        if(this.repaymentMethod === "S"){
          submitLoanTransaction({loanApplicationId:this.recordId,module:'Post Sanction Checks and Documentation', dealId: this.dealId}).then(result=>{
            this.showToast(UpdateToastMsg, 'success', 'Success');
            this.isSpinnerMoving = false;

          }).catch(error=>{
            this.showToast(EXCEPTIONMESSAGE, "error", 'Error');
            this.isSpinnerMoving = false;

          });
        }else{
          unsubmitLoanTransaction({loanApplicationId:this.recordId,module:'Post Sanction Checks and Documentation', dealId: this.dealId});//CISP-1223
          this.showToast(UpdateToastMsg, 'success','Success');
          if (this.repaymentMethod === "N") {
            this.eNachFlag = true;
            this.achFlag = false;
            this.siFlag = false;
            this.accordionActiveSection = "e-Nach";
          }
          if (this.repaymentMethod === "A") {
            this.achFlag = true;
            this.eNachFlag = false;
            this.siFlag = false;
            this.accordionActiveSection = "ach";
          }
          if (this.repaymentMethod === "I") {
            this.siFlag = true;
            this.eNachFlag = false;
            this.achFlag = false;
            this.accordionActiveSection = "si";
          }
          if(this.repaymentMethodValueChanged){
            this.repaymentMethodChangeCount++;
            const fields = {};
            fields[repayment_Id.fieldApiName] = this.repaymentRecordId;
            fields[Repayment_Method_Retry_Count__c.fieldApiName] = this.repaymentMethodChangeCount;
            const recordInput = { fields };
            
            updateRecord(recordInput)
            .then(() => {
              this.repaymentMethodValueChanged = false;
              if(this.repaymentMethodChangeCount <= 2 && !this.isWouldYouLikeBankAccount){
                if(this.template.querySelector(`lightning-combobox[data-id="repaymentMethodId"]`)){
                  this.template.querySelector(`lightning-combobox[data-id="repaymentMethodId"]`).disabled = false;
                }
              }
            });
          }

          this.isSpinnerMoving = false;

        }
      } else {
        this.showToast(Mandatory_fields_are_not_entered, 'warning');
        this.isSpinnerMoving = false;

        }
    }
    })
    .catch((error) => {
      this.showToast(error, "error", 'Error');
      this.isSpinnerMoving = false;

      });
  }
  
  async callTextMatchApi(beneficiaryName){  
    let textMatch;
    if(this.isSandbox){
       textMatch = { 'loanApplicationId':this.recordId, 'leadId':'', 'applicantFirstName':UATPennyDropBeneficiary, 'applicantMiddleName': '', 'applicantLastName':'', 'destinationNames':beneficiaryName };
    }else{
     textMatch = { 'loanApplicationId':this.recordId, 'leadId':'', 'applicantFirstName':this.repaymentDoneBy, 'applicantMiddleName': '', 'applicantLastName':'', 'destinationNames': beneficiaryName};
    }
        await doTextMatchCalloutForPennyDrop({textMatch : JSON.stringify(textMatch)}).then(result=>{
          console.log('text match response :' +result);

          if(result){
            const parseResp=JSON.parse(result); 
            const matchScore =  parseResp.ResponseData.Fields.Applicants.Applicant.Services.Service[0].Operations.Operation[0].Data.Response.RawResponse.MatchService.Source[0].NameMatch;
            console.log('Applicant Name match Precentage : '+matchScore );
            this.matchScore = matchScore;
          
            /*if(matchScore){
              if(matchScore >= 75){
                this.createRepaymentRecordHandler();
              }
              else{
                this.showToast('The Bank account number entered does not belong to the person who is repaying the loan. Please change the account number', "error", 'Error');
                this.isSpinnerMoving = false;
              }
            }
            else{
              this.showToast('Something went wrong. Text Match Score is Null', "error", 'Error');
              this.isSpinnerMoving = false;
            }*/ //SFTRAC-1901 No need to check match percentage.
        
          }
          else{
            this.showToast('Response not found, please retry!', "error", 'Error');
          }

        }).catch(error =>{
          console.log('Get error in text match :'+JSON.stringify(error));
          this.showToast('Text Match API Failed', "error", 'Error');
          this.isSpinnerMoving = false;
        })
  }

  handleSubmitPreRepaymentDetails(){
    if(this.checkRepaymentDetailsField === 'Yes'){
    submitLoanTransaction({loanApplicationId:this.recordId,module:'Pre Disbursement Check', dealId: this.dealId}).then(result=>{
      this.isDisabled = true;
      this.isSubmitDisabled = true;
      this.isPreDisabled = true;
      this.updateRepaymentForCVO();
      // this.showToast(UpdateToastMsg, 'success');
    }).catch(error=>{
      this.showToast(EXCEPTIONMESSAGE, "error", 'Error');
    });
  } else if(this.checkRepaymentDetailsField === 'No') {
    submitLoanTransaction({loanApplicationId:this.recordId,module:'Pre Disbursement Check', dealId: this.dealId}).then(result=>{
      console.log('Update Loan App History Successfully');
        this.isDisabled = true;
        this.isSubmitDisabled = true;
        this.isPreDisabled = true;  
        this.updateRepaymentForCVO();
        // this.showToast(UpdateToastMsg, 'success');
    }).catch((error) => {
      console.error('error -- >', error);
    });
    }
    else {
        this.showToast("Please select Yes, if you have checked the above repayment details or Select No to move previous steps", 'error', 'Error');
        this.isSpinnerMoving = false;
      }
  }
  //This function is used to update the repayment captured correctly and remarks field - CISP-20178
  updateRepaymentForCVO(){
    let fields = {};
    fields.Repayments_Captured_Correctly__c = this.checkRepaymentDetailsField;
    fields.Remarks__c = this.remarks;
    fields.Id = this.repaymentRecordId;
    const recordInput = { fields };
      updateRecord(recordInput)
      .then(res => {
        console.log(res,'svo updated res');
        this.showToast(UpdateToastMsg, 'success');
      }).catch(error =>{
        console.log(error,'err for cvo updating')
      })
  }

  handleRepaymentChange(event) {
    this.repaymentMethod = event.target.value;
    this.repaymentMethodValueChanged = true;
    this.isDisabled = false;
    this.isSubmitDisabled = false;
    console.log("Repayment Method", this.repaymentMethod);
    if (this.repaymentMethod === "N") { 
      this.eNachFlag = false;
      this.achFlag = false;
      this.siFlag = false;
      this.accordionActiveSection = "e-Nach";
    }
    if (this.repaymentMethod === "A") {
      this.achFlag = false;
      this.eNachFlag = false;
      this.siFlag = false;
      this.accordionActiveSection = "ach";
    }
    if (this.repaymentMethod === "I") {
      this.siFlag = false;
      this.eNachFlag = false;
      this.achFlag = false;
      this.accordionActiveSection = "si";
    }
    if(this.stageName == 'Post Sanction Checks and Documentation' && this.repaymentMethod == 'S'){
      this.ispennyDropShow = false;this.enablePennyDrop = true;
      this.template.querySelector('lightning-input[data-id="ifscCodeId"]').disabled = true;
      this.template.querySelector('lightning-input[data-id="accountNumberId"]').disabled = true;
      if(this.isPVorTW){
        this.template.querySelector('lightning-input[data-id="accountName"]').disabled = true;
      }
    }else{
      this.template.querySelector('lightning-input[data-id="ifscCodeId"]').disabled = false;
      this.template.querySelector('lightning-input[data-id="accountNumberId"]').disabled = false;
      if(this.isPVorTW){
        this.template.querySelector('lightning-input[data-id="accountName"]').disabled = false;
      }
    }
    
  }

  showToast(info, vari, titl) {
    const event = new ShowToastEvent({
      title: titl,
      message: info,
      variant: vari
    });
    this.dispatchEvent(event);
  }
  isPreDisabled = true;
  isBackEndFrontEndStageSame = true;
  async handlecreateRepaymentRecord(data) {
    await createRepaymentRecord({ loanApplicationId: this.recordId, data: data, dealId : this.dealId})
      .then((result) => {
        if (result != null) {
          console.log('repayment record' + JSON.stringify(result));
          this.repaymentRecordId = result.Id;
          this.stageName = result.Loan_Application__r.StageName;
          this.isNetBankingAvailable = result.Is_Netbanking_available_with_customer__c;
          this.isDebitCardAvailable = result.Is_debit_card_available_with_customer__c;
          this.repaymentMethod = result.Repayment_Method__c != undefined ? result.Repayment_Method__c.toUpperCase() : '';
          this.untilCancelled = result.Until_Cancelled__c;
          this.endDate = result.End_Date__c;
          this.startDate = result.Created_Date__c;
          this.frequency = result.Frequency__c;
          this.bankId = result.Bank_Master__c;
          this.ifscCode = result.IFSC_Code__c;
          this.accountNumber = result.Account_Number__c;
          this.remarks = result.Remarks__c;
          this.bank = result.Bank_Master__r?.Name;
          this.comboboxValue= result.Authorization_mode_available__c;
          this.authorizationModeAvailable = result.Authorization_mode_available__c;
          this.checkRepaymentDetailsField = result.Repayments_Captured_Correctly__c;
          
          if(this.stageName == 'Post Sanction Checks and Documentation' && this.repaymentMethod == 'S'){
            this.ispennyDropShow = false;this.enablePennyDrop = true;
          }
          this.eNachStatus = result.E_NACH_API_Status__c;
          if (this.eNachStatus === 'In Progress' || this.eNachStatus === 'SUCCESS' || this.eNachStatus === 'Response is awaited') {//CFDI-1152
            this.eNachFlag = true;
            this.achFlag = false;
            this.siFlag = false;
            this.accordionActiveSection = "e-Nach";
            this.isDisabled = true;
            this.isSubmitDisabled = true;
          }
          if (this.eNachStatus === 'FAILED') {
            this.eNachFlag = true;
            this.achFlag = false;
            this.siFlag = false;
            this.accordionActiveSection = "e-Nach";
            this.isDisabled = false;
            this.isSubmitDisabled = false;
          }
          if (result?.RecordType?.DeveloperName === 'ACH') {
            this.achFlag = true;
            this.eNachFlag = false;
            this.siFlag = false;
            this.accordionActiveSection = "ach";
            if (result.SB_Or_CAis_ticked_appropriately__c === 'Yes') { //ACH submitted, freeze screen
              this.isSubmitDisabled = true;
              this.isDisabled = true;
            }
          }
          if (result?.RecordType?.DeveloperName === 'SI_Online') {
            this.siDefaultMethod = 'SI Online';
            this.siFlag = true;
            this.eNachFlag = false;
            this.achFlag = false;
            this.accordionActiveSection = "si";
            this.isSubmitDisabled = true;
            this.isDisabled = true;
          }
          if (result?.RecordType?.DeveloperName === 'SI_Offline') {
            this.siDefaultMethod = 'SI Offline';
            this.siFlag = true;
            this.eNachFlag = false;
            this.achFlag = false;
            this.accordionActiveSection = "si";
            this.isSubmitDisabled = true;
            this.isDisabled = true;
          }
          if (result?.Is_Cancelled_Cheque_legible__c === "No" || result?.ACH_Form_filled_correctly__c === "No" ||
            result?.Is_SI_form_Legible__c === "No" || result?.SI_Form_filled_correctly__c === "No") {
            this.isSubmitDisabled = false;
            this.isDisabled = false;
          }
          if(this.checkRepaymentDetailsField == 'No'){
            this.isDisabled = false;
            this.isSubmitDisabled = false;
          }
          if(this.currentStep === 'pre-disbursement' && this.stageName === 'Pre Disbursement Check'){
            this.isSubmitDisabled = true;
            this.isDisabled = true;
            this.isBackEndFrontEndStageSame = false;
            // if(this.isWouldYouLikeBankAccount){
              this.isPreDisabled = false;
            // }
          }
          if(this.isWouldYouLikeBankAccount){
            isCheckReadOnly({loanApplicationId : this.recordId, dealId: this.dealId}).then(result=>{
                console.log('result Test t ', result);
                if(result.isCheckReadOnly){
                  this.isPreDisabled=true;
                  this.isSubmitDisabled = true;
                }
              });
          }
          if(this.currentStep === 'post-sanction' && this.stageName === 'Pre Disbursement Check'){
            this.isSubmitDisabled = true;
            this.isDisabled = true;
            this.isBackEndFrontEndStageSame = false;
            this.isPreDisabled=true;
          }
          if(this.currentStep == 'post-sanction' && this.stageName == 'Disbursement Request Preparation'){
            this.isSubmitDisabled = true;
            this.isDisabled = true;
            this.isBackEndFrontEndStageSame = false;
            this.isPreDisabled=true;
          }
          if(this.currentStep == 'pre-disbursement' && this.stageName == 'Disbursement Request Preparation'){
            this.isSubmitDisabled = true;
            this.isDisabled = true;
            this.isBackEndFrontEndStageSame = false;
            this.isPreDisabled=true;
          }
          if(this.isBackEndFrontEndStageSame){
            this.repaymentMethodRetryCount(result.Repayment_Method_Retry_Count__c);
          }
        }else if(result == null){
          this.repaymentMethodRetryCount(0);
        }
      })
      .catch((error) => {
        console.log("error data ", error);
      });
  }

  repaymentMethodRetryCount(repaymentMethodRetryCount){
    this.repaymentMethodChangeCount = repaymentMethodRetryCount;
    this.repaymentMethodValueChanged = this.repaymentMethodChangeCount == 0 ? true : false;

    if(this.repaymentMethodChangeCount <= 2 && this.repaymentMethodChangeCount >= 0 && !this.isWouldYouLikeBankAccount){
      setTimeout(() => {
        if(this.template.querySelector(`lightning-combobox[data-id="repaymentMethodId"]`)){
          this.template.querySelector(`lightning-combobox[data-id="repaymentMethodId"]`).disabled = false;
        }
      }, 1000);
    }
  }

  createPayload() {
    const RepaymentFields = {};
    RepaymentFields[repayment_Id.fieldApiName] = this.repaymentRecordId;
    RepaymentFields[Bank_Master__c.fieldApiName] = this.bankId;
    RepaymentFields[Authorization_mode_available__c.fieldApiName] = this.comboboxValue;
    RepaymentFields[Is_Netbanking_available_with_customer__c.fieldApiName] = this.isNetBankingAvailable;
    RepaymentFields[Repayment_to_be_done_by__c.fieldApiName] = this.repaymentDoneBy;
    RepaymentFields[Is_debit_card_available_with_customer__c.fieldApiName] = this.isDebitCardAvailable;
    RepaymentFields[Repayment_Method__c.fieldApiName] = this.repaymentMethod;
    RepaymentFields[Loan_Amount__c.fieldApiName] = this.loanAmount;
    RepaymentFields[EMI_Amount__c.fieldApiName] = this.emiAmount;
    RepaymentFields[Created_Date__c.fieldApiName] = this.startDate;
    RepaymentFields[End_Date__c.fieldApiName] = this.endDate;
    RepaymentFields[Until_Cancelled__c.fieldApiName] = this.untilCancelled;
    RepaymentFields[lst_EMI_Due_Date__c.fieldApiName] = this.lstEMIDueDate;
    RepaymentFields[Frequency__c.fieldApiName] = this.frequency;
    RepaymentFields[IFSC_Code__c.fieldApiName] = this.ifscCode;
    RepaymentFields[Account_Number__c.fieldApiName] = this.accountNumber;
    RepaymentFields[Remarks__c.fieldApiName] = this.remarks;
    RepaymentFields[Repayments_Captured_Correctly__c.fieldApiName] = this.checkRepaymentDetailsField;
    RepaymentFields[Repayment_Method_Retry_Count__c.fieldApiName] = this.repaymentMethodChangeCount;
    RepaymentFields[Name_Match_Percentage__c.fieldApiName] = this.matchScore;
    if (!this.repaymentRecordId) {
      // only if insert
      RepaymentFields[Loan_Application__c.fieldApiName] = this.recordId; // field not writeable
    }
    RepaymentFields[RepaymentsRecordType.fieldApiName] = this.repaymentMethod === 'I' ? this.getRecordTypeId(this.siDefaultMethod) : this.getRecordTypeId(this.recordTypeHandler(this.repaymentMethod));//SI online is default when SI is selected
    console.log('RepaymentFields ', RepaymentFields);
    return RepaymentFields;
  }

  recordTypeHandler(repaymentMethod){
    return repaymentMethod == 'A' ? 'ACH' : repaymentMethod == 'N' ? 'E-NACH' : '';
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

  eNachHandler(params) {
    if (params.detail.isScreenEditable) {
      this.isDisabled = false;
      this.isSubmitDisabled = false;
      this.repaymentMethodOption = this.repaymentMethodOption.filter(elem => elem.label !== 'N');//remove E-NACH option
    }
  }
  siChangeHandler(params) {
    if (params.detail.isScreenEditable) {
      this.isDisabled = false;
      this.isSubmitDisabled = false;
    }
  }

  //CISP-4181 Function to go back to the final offer page
  openFinalOfferPage() {
    const evt = new CustomEvent('openfinalofferpage', {
      detail: {
        repaymentRecordId : this.repaymentRecordId
      }
    });
    this.dispatchEvent(evt);
  }

  handleGotoFinalOfferPage() {
    this.openFinalOfferPage();
  }
}