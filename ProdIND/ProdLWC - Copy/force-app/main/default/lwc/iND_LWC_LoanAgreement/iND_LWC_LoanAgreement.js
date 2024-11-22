import { LightningElement, track, api, wire } from "lwc";
import {
  createRecord,
  updateRecord,
  getRecordNotifyChange,
} from "lightning/uiRecordApi"; 
import USER_ID from '@salesforce/user/Id';
import isPreDisbursementLASubmitted from "@salesforce/apex/LoanAgreementController.isPreDisbursementLASubmitted";
import isPostSanctionLASubmitted from "@salesforce/apex/LoanAgreementController.isPostSanctionLASubmitted";
import updateLoanTransacionHistoryToSubmitted from "@salesforce/apex/LoanAgreementController.updateLoanTransacionHistoryToSubmitted";
import updateLoanTransacionToSubmitted from "@salesforce/apex/LoanAgreementController.updateLoanTransacionToSubmitted";
import getAgreementBookletDetails from "@salesforce/apex/LoanAgreementController.getAgreementBookletDetails";
import currentUserProfile from "@salesforce/apex/LoanAgreementController.currentUserProfile";
import getLoanEAgreementDetails from "@salesforce/apex/loanEAgreementController.getLoanEAgreementDetails";
import getLoanAgreement from "@salesforce/apex/LoanAgreementController.getLoanAgreement";
import getAgreementCopyDocumentData from "@salesforce/apex/LoanAgreementController.getDocumentData";
import getGeoGraphicalState from "@salesforce/apex/LoanAgreementController.getGeoGraphicalState";
import getTaxInvoiceDate from "@salesforce/apex/LoanAgreementController.getTaxInvoiceDate";
import getAdvancedEMI from "@salesforce/apex/LoanAgreementController.getAdvancedEMI";
import getApplicantDetails from "@salesforce/apex/loanEAgreementController.getApplicant";
import getStampingDetails from "@salesforce/apex/LoanAgreementController.getStampingDetails";
import insertAdditionalStampings from "@salesforce/apex/LoanAgreementController.insertAdditionalStampings";
import getNeslRetries from "@salesforce/apex/loanEAgreementController.getMaxTryCount";
import getSubmittedCheck from "@salesforce/apex/loanEAgreementController.getSubmittedCheck";
import doAgreementBookletCallout from "@salesforce/apexContinuation/IntegrationEngine.doAgreementBookletCallout";
import doStampingDetailsCallout from "@salesforce/apexContinuation/IntegrationEngine.doStampingDetailsCallout";
import getLoanAppDetails from "@salesforce/apex/LoanAgreementController.getLoanApplication"; //140
import getTVRDetails from "@salesforce/apex/LoanAgreementController.getTVRDetails"; //140
// import doRegistrationJourneyCallout from "@salesforce/apexContinuation/IntegrationEngine.doRegistrationJourneyCallout";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import LoanAgreement_OBJECT from "@salesforce/schema/Loan_Agreement__c";
import { refreshApex } from "@salesforce/apex";
import ID_FIELD from "@salesforce/schema/Loan_Agreement__c.Id";
import LoanA_FIELD from "@salesforce/schema/Loan_Agreement__c.Loan_Application__c";
import ReqStampingCharges_FIELD from "@salesforce/schema/Loan_Agreement__c.Required_Loan_Agreement_Stamping_Charges__c";
import BorrowerCount_FIELD from "@salesforce/schema/Loan_Agreement__c.BorrowerNesLCallCount__c";
import CoborrowerCount_FIELD from "@salesforce/schema/Loan_Agreement__c.CoBorrowerNeslCallCount__c";
import AgreementType_FIELD from "@salesforce/schema/Loan_Agreement__c.Agreement_Type__c";
import { getObjectInfo } from "lightning/uiObjectInfoApi";
import { getPicklistValues } from "lightning/uiObjectInfoApi";
import STAMP_OBJECT from "@salesforce/schema/Stamp_Detail__c";
import STAMP_LOCATION_TYPE_FIELD from "@salesforce/schema/Stamp_Detail__c.Stamp_Location_Type__c";
import STAMP_TOWARDS_FIELD from "@salesforce/schema/Stamp_Detail__c.Stamp_Towards__c";
import { NavigationMixin } from "lightning/navigation";
import Cannot_Continue_with_EAgreement from "@salesforce/label/c.Cannot_Continue_with_EAgreement";
import Borrower_Agreement_Booklet_Received_Successfully from "@salesforce/label/c.Borrower_Agreement_Booklet_Received_Successfully";
import Co_Borrower_E_Agreement_Response_Received_Successfully from "@salesforce/label/c.Co_Borrower_E_Agreement_Response_Received_Successfully";
import Not_Eligible_for_EAgreement_Process from "@salesforce/label/c.Not_Eligible_for_EAgreement_Process";
import Application_is_eligible_for_e_agreement from "@salesforce/label/c.Application_is_eligible_for_e_agreement";
import x1stPVEMIDueDate from "@salesforce/label/c.x1stPVEMIDueDate";
import x1stTWEMIDueDate from "@salesforce/label/c.x1stTWEMIDueDate";
import x21EMIDueDate from "@salesforce/label/c.x21EMIDueDate";
import x1stPVEMIDueDatev2 from "@salesforce/label/c.x1stPVEMIDueDatev2";
import Borrower_E_Agreement_Response_Received_Successfully from "@salesforce/label/c.Borrower_E_Agreement_Response_Received_Successfully";
import Cannot_Proceed_Further from "@salesforce/label/c.Cannot_Proceed_Further";
import Thank_you from "@salesforce/label/c.Thank_you";
import Stamps_successfully_created from "@salesforce/label/c.Stamps_successfully_created";
import NoInvoiceFound from "@salesforce/label/c.NoInvoiceFound";
import NoGeoStateCodeFound from "@salesforce/label/c.NoGeoStateCodeFound";
import deal_Number from "@salesforce/label/c.deal_Number";
import IsIHMReceiptGenerated from "@salesforce/label/c.IsInvoiceGenerated";
import isRequiredStageCompleted from "@salesforce/apex/LoanAgreementController.isRequiredStageCompleted";
import getAPIsCalloutResponse from "@salesforce/apex/LoanAgreementController.getAPIsCalloutResponse";
import checkApiCalloutStatus from "@salesforce/apex/LoanAgreementController.checkApiCalloutStatus";
import isEAgreementAPIsSuccess from "@salesforce/apex/LoanAgreementController.isEAgreementAPIsSuccess";//CISP-2487
import validateScannedDocs from "@salesforce/apex/LoanAgreementController.validateScannedDocs";
import isEmiDatesCapturedInBackend from "@salesforce/apex/LoanAgreementController.isEmiDatesCapturedInBackend";//CISP-2420 AND CISP-2418

// import eAgreementValidate from '@salesforce/apex/loanEAgreementController.eAgreementValidate';// Gaurav Changes
import NeslEAgreementConfirmMsg from "@salesforce/label/c.NeslEAgreementConfirmMsg"; // Gaurav : Changes
import getInitiateAgreementDisable from "@salesforce/apex/loanEAgreementController.getInitiateAgreementDisable"; // Gaurav Changes
import checkRetryExhausted from "@salesforce/apex/loanEAgreementController.checkRetryExhausted"; // Gaurav Changes
import updateLoanAppHistory from "@salesforce/apex/loanEAgreementController.updateLoanAppHistory"; // Gaurav Changes
import NeSLEAgreementApiErrorMsg from "@salesforce/label/c.NeSLEAgreementApiErrorMsg"; // Gaurav Changes
import NeSLEAgreementSelfThankYouMsg from "@salesforce/label/c.NeSLEAgreementSelfThankYouMsg"; // Gaurav Changes
import NESL_EAgreementRetryCount from "@salesforce/label/c.NESL_EAgreementRetryCount"; // Gaurav Changes
import Borrower from "@salesforce/label/c.Borrower"; // Gaurav Changes
import CoBorrower from "@salesforce/label/c.CoBorrower"; // Gaurav Changes
import AgreementSigningPending from "@salesforce/label/c.AgreementSigningPending"; // Gaurav Changes
import AgreementSignedSuccessfully from "@salesforce/label/c.AgreementSignedSuccessfully"; // Gaurav Changes
import NoDataFound from "@salesforce/label/c.NoDataFound"; // Gaurav Changes
import retryCountIncrease from "@salesforce/apex/loanEAgreementController.retryCountIncrease"; // Gaurav Changes
import doInitiateNESLCallout from "@salesforce/apexContinuation/IntegrationEngine.doInitiateNESLCallout"; // Gaurav Changes
import doNeSLAgreementStatusCallout from "@salesforce/apexContinuation/IntegrationEngine.doNeSLAgreementStatusCallout"; // Gaurav Changes
import deleteLoanAgreementDetails from "@salesforce/apex/LoanAgreementController.deleteLoanAgreementDetails";
import Add_POA_SD_Agreement_signed_for_co_borro__c from "@salesforce/schema/Loan_Agreement__c.Add_POA_SD_Agreement_signed_for_co_borro__c"; // Gaurav Changes	
import Add_POA_SD_Agreement_signed_for_borrower__c from "@salesforce/schema/Loan_Agreement__c.Add_POA_SD_Agreement_signed_for_borrower__c"; // Gaurav Changes
// Agent_BL_code__c
import IsAgreementEligibleMandatory from '@salesforce/label/c.IsAgreementEligibleMandatory';
import IsEAgreementEligibleMandatory from '@salesforce/label/c.IsEAgreementEligibleMandatory';
import Borrower_Agreement_Booklet_Not_Found from '@salesforce/label/c.Borrower_Agreement_Booklet_Not_Found';
import Stamping_Details_Error_Msg from '@salesforce/label/c.Stamping_Details_Error_Msg';
import Stamping_And_LoanAgremment_Save_Error from '@salesforce/label/c.Stamping_And_LoanAgremment_Save_Error';
import IsTVRPassed from '@salesforce/label/c.IsTVRGenerated';
import tvrStatusFailed from '@salesforce/label/c.tvrStatusFailed';
import submittedFlagFailed from '@salesforce/label/c.submittedFlagFailed';
import EAgreementWarningMsg from '@salesforce/label/c.EAgreementWarningMsg';
import APPLICANT_ID from '@salesforce/schema/Applicant__c.Id';
import CASA_FORM_SMS_SENT from '@salesforce/schema/Applicant__c.CASA_Form_SMS_Sent__c';
import APPLICANT_CASAConsentOTP from '@salesforce/schema/Applicant__c.CASA_Consent_OTP__c';
import Consent_Sent_Successfully from '@salesforce/label/c.Consent_Sent_Successfully';
import doSmsCallout from '@salesforce/apex/IntegrationEngine.doSmsGatewayAPI';
import APP_ID_FIELD from '@salesforce/schema/Applicant__c.Id';//CISP-2487
import IS_NESL_API_SUCCEED from '@salesforce/schema/Applicant__c.Is_Nesl_API_Succeed__c';//CISP-2487
//Modified for D2C by Rohan
import { getRecord } from 'lightning/uiRecordApi';
import OPP_LEAD_SORCE from '@salesforce/schema/Opportunity.LeadSource';
//End of D2C Code

import getVehicleID from "@salesforce/apex/LoanAgreementController.getVehicleID";
import getFinalTermObjectAsPerVehicle from '@salesforce/apex/FinalTermscontroller.getFinalTermObjectAsPerVehicle';
import { deleteRecord } from 'lightning/uiRecordApi';
import getRecentEMIdetails from '@salesforce/apex/InstallmentScheduleController.getRecentEMIdetails';

export default class iND_LWC_LoanAgreement extends NavigationMixin(
  LightningElement
) {

  columns = [
    { label: 'Applicant Name', fieldName: 'Name' ,type: 'text'},
    { label: 'Is Co-Borrower having an Aadhaar card ?', fieldName: 'Is_customer_having_an_Aadhar_Card__c', type :'boolean' },
    { label: 'Is Co-Borrower No linked to Aadhar ?', fieldName: 'Is_customer_s_Mob_No_linked_to_Aadhar__c', type :'boolean'  },
    { label: 'Is Co-Borrowers Aadhar Mob No in Use ?', fieldName: 'Is_customer_using_Aadhar_Linked_Mob_No__c', type :'boolean'  },
];
  applicantData = [];
  @api dealId = '';
  @api currentStep;
  @api oppId;
  @track _readonly;
  @api 
  set readonly(value){
    this._readonly = value;
  }
  get readonly(){
    return this._readonly;
  }

  @track _submitButtonDisabled;
  get submitButtonDisabled() {
    return this._submitButtonDisabled;
  }

  @track _saveButtonDisabled;
  get saveButtonDisabled() {
    return this._saveButtonDisabled;
  }

  @track _uploadBookletBtnDisabled;
  get uploadBookletBtnDisabled() {
    return this._uploadBookletBtnDisabled;
  }

  @track _loanAgreementId;
  @track isAPIsuccess = false;
  get loanAgreementId() {
    return this._loanAgreementId;
  }
  set loanAgreementId(value) {
    this._loanAgreementId = value;
  }

  @track showSpinner = true;
  showApplDetails;
  total = 0;
  @track finalAgreementSubmit = false;
  @track listOfStamps = [];
  @track totalAmount = 0;
  @track showExistingLASD = true;
  @track showExistingPOASD = true;
  //@track showAddlSDLA = false;
  @track showAddlSDPOA = true;
  @track showAddlLASD = false;
  @track showAddlPOASD = true;
  @track modalMessage;
  @track disableRemarks = false;
  @track hasError = false;
  @track geoStateName;
  showPOASDPhysicalAgreement = true;
  showFetchBookletSpinner;
  isEAgreementType;
  showSaveSpinner;
  showModal;
  showemidropdown = false;

  loanAgreementData;
  disableInitiateAgreement;
  disableInitiateCoBorrowerAgreement = true;
  initiateMethodoptionlist;
  disableinitiateMethod = true;
  initateMethodValue;
  neslMaxRetryCount;
  coborrowerId;
  borrowerId;
  borrowerwillingness;
  coborrowerwillingness;
  borrowerSMSsend;
  coborrowerSMSsend;

  isSubmittedcheck;
  disableCheckstatus = true;
  disableSubmit = true;

  showConfirmModal; // Gaurav Changes
  confirmModalMessage = NeslEAgreementConfirmMsg; // Gaurav changes
  initiateAgreementBtnDisable; // Gaurav : Changes
  currentAgreementBookletNumber; // Gaurav : Changes
  agreementBookletNumber; // Gaurav : Changes
  isSpinnerVisible = false; // Gaurav : Changes
  currentStageName; // Gaurav : Changes
  saveBtnDisable = false;
  documentBtnDisable = false;
  disableCVOFields = false;
  stampingDetailsCalloutResponse = false;
  fetchAgreementBookletCalloutResponse = false;
  @track agentBLCode;
  @track invoiceDate;
  @track agreementDate;
  @track tentativePaymentDate;
  @track sanctionDate;
  @track disableDealDateBasedOn = false;
  @track dealDateBasedOn;
  @track productType;
  @api recordId;
  @track disableGetBookletButton = false;
  @track additionalStampings = [];
  @track stampLocationTypes = [];
  @track stampTowards = [];
  @track totalAdditionalStampDone = 0;
  @track totalExistingStampDone = 0;
  @track geoStateCode;
  @track financeAmount;
  @track agreementType = "";
  @wire(getObjectInfo, { objectApiName: STAMP_OBJECT })
  stampMetadata;

  @track showUpload;
  @track showPhotoCopy;
  @track showDocView;
  @track isVehicleDoc;
  @track isAllDocType;
  @track uploadViewDocFlag;
  @track uploadScannedBookletFlag = false;
  @track docType = 'Agreement Copy'
  @track stampingChargesCollected;
  @track totalStampingDone;
  @track agreeementDoc;
  @track docLabel = "Upload Scanned Booklet";
  @track title = "Upload Scanned Booklet"
  @track stampingDetails;
  @track stampingDetailsCalled = 0;
  @track additionalSDAdded = false;
  @track requiredStampingChanges = 0;
  @track isPSLASubmitted = false;
  @track isPDLASubmitted = true;
  @track isPhysicalAgreement = false;
  @track isSubmitButtonVisible = true;
  @track isGetAPIsCalloutResponseRender= true;
  @track activeSections = ['Existing Loan Agreement Stamp Duty'];
  @track emidatelist = [];
  @track emidate;
  @track firstemidate;
  @track isTractor;
  emidisable = false;
  IsAdvanceEMI = false;
  monitoriumDaysValue;
  firstEMIDate;
  secondEMIDate;
  isEligibleForEAgreement;//CISP-133
  source=''; //Added for D2C
 //Added for D2C
 @wire(getRecord, { recordId: '$oppId', fields: [OPP_LEAD_SORCE] })
 opportunity({ error, data }) {
   if (data) {
     this.source=data.fields.LeadSource.value;
   } else if (error) {
      console.log('error-->'+JSON.stringify(error));
   }
 }
//end of D2C code
  whoWillRepayLoan;

  @wire(getPicklistValues, {
    recordTypeId: "$stampMetadata.data.defaultRecordTypeId",
    fieldApiName: STAMP_LOCATION_TYPE_FIELD,
  })
  fetchPicklist1({ error, data }) {
    if (data !== undefined) {
      console.debug(data.values);
      this.stampLocationTypes = data.values;
    } else if (error) {
      console.debug(error);
    }
  }

  stampTypesOptions = [
    { label: "FRANKING", value: "FST" },
    { label: "ELECTRONIC STAMPING", value: "EST" },
    { label: "NON JUDICIAL STAMP PAPER", value: "NST" },
    { label: "ADHESIE STAMPS", value: "AST" },
    { label: "SHCIL PHYSICAL E-STAMP", value: "SHCIL" },
  ];

  async renderedCallback() {
    try {
      if (!this.hasError) {
        await getGeoGraphicalState({
          loanApplicationId: this.oppId,
        })
          .then((response) => {
            if (response) {
              if (response.includes(NoGeoStateCodeFound)) {
                this.hasError = true;
                this.errorMessage = response;
              } else {
                this.geoStateCode = response.split('_')[1];
                this.geoStateName = response.split('_')[0];
                this.template
                  .querySelectorAll("lightning-input-field")
                  .forEach((input) => {
                    if (input.fieldName == "Geo_State_Code__c") {
                      input.value = this.geoStateName;
                    }
                  });
              }
            } else {
              this.hasError = true;
              this.errorMessage = response;
              this.showToast(
                "Error!",
                NoGeoStateCodeFound,
                "error",
                "dismissable"
              );
            }
  
          })
          .catch((error) => {
            console.debug("error:", error);
          });
          
        if (this.stampingDetailsCalled < 2) {
          await getStampingDetails({
            loanAgrementId: this.loanAgreementId,
            loanAppId: this.oppId,
          })
            .then((response) => {
              if (response) {
                this.stampingDetailsCalled += 1;
                console.debug('response 264 ', JSON.stringify(response));
                this.stampingDetails = response;
                for (let res of response.existingStamping) {
                  if (res.Type__c.includes("Loan Agreement")) {
                    this.template
                      .querySelectorAll("lightning-input-field")
                      .forEach((input) => {
                        if (input.fieldName == "Existing_LA_Stamp_S_No__c") {
                          input.value = res.Stamp_S_No__c;
                        } else if (input.fieldName == "Existing_LA_Stamp_On__c") {
                          input.value = res.Stamp_Date__c;
                        } else if (
                          input.fieldName == "Existing_LA_Stamped_For__c"
                        ) {
                          input.value = res.Stamp_For__c;
                        } else if (
                          input.fieldName == "Existing_LA_Stamped_Towards__c"
                        ) {
                          input.value = res.Stamp_Towards__c;
                        } else if (
                          input.fieldName == "Existing_LA_Stamp_Location_Type__c"
                        ) {
                          input.value = res.Stamp_Location_Type__c;
                        } else if (input.fieldName == "Existing_LA_Stamp_Type__c") {
                          input.value = res.Stamp_Type__c;
                        } else if (
                          input.fieldName == "Existing_LA_Stamp_Value__c"
                        ) {
                          input.value = res.Stamp_Value__c;
                          this.totalExistingStampDone = res.Stamp_Value__c == undefined ? 0 : res.Stamp_Value__c;
                        }
                      });
                  }
                }
  
                this.totalStampingDone = 0;
                this.totalStampingDone =
                  this.totalExistingStampDone + this.totalAdditionalStampDone;
                this.calculateValue();
                if (this.totalExistingStampDone == this.requiredStampingChanges) {
                  if(this.template.querySelector(`lightning-input-field[data-name=Loan_Agreement_Stamping_Met__c]`)){
                    this.template.querySelector(`lightning-input-field[data-name=Loan_Agreement_Stamping_Met__c]`).value = true;
                  }
                  if (this.documentRecordId) {
                    this.disableSubmit = false;
                  }
                }
  
                if (
                  response.additionalStamping &&
                  response.additionalStamping.length > 0
                ) {
                  this.listOfStamps = response.additionalStamping;
                  if (this.listOfStamps) {
                    this.showAddlLASD = true;
                  }
                  console.debug(this.listOfStamps);
                }
              }
            })
            .catch((error) => {
              console.debug("error 351 :", error);
            });
        }
        if (this.readonly) {
          this.template
              .querySelectorAll(".addStamp")
              .forEach((input) => {
                input.disabled = true;
              });
          this.template
            .querySelectorAll("lightning-input-field")
            .forEach((input) => {
              input.disabled = true;
              if (!this.isPDLASubmitted && !this.disableCVOFields) {
                if (input.fieldName == "Is_Physical_Agreement_Eligible__c" || input.fieldName == "Remarks__c" || input.fieldName == "Is_1st_EMI_due_date_correctly_captured__c" ||
                input.fieldName == "Add_POA_SD_Remarks__c" || input.fieldName == "Add_POA_SD_Loan_agreement_accepted_by_CV__c"|| input.fieldName == "Is_Stamp_Duty_as_per_norms__c") {
                  input.disabled = false;
                }
              }
            });
            this.emidisable = true;
            this.template
            .querySelectorAll("lightning-button")
            .forEach((input) => {
              if(parseInt(input.dataset.section) == 2){
                input.disabled = true;
              }
              if(parseInt(input.dataset.accord) == 7 && this.isEAgreementType){
                input.disabled = true;
              }
            });
            
            if(!this.disableRemarks && this._submitButtonDisabled){
              await isPreDisbursementLASubmitted({
                oppId: this.oppId,
                dealId: this.dealId
              })
                .then((response) => {
                  if (response.isSubmitted && response.currentBackEndStage == 'Pre Disbursement Check') {
                    this.isPDLASubmitted = true;
                    this.disableSubmit = true;
                    this.disableRemarks = true;
                    this._submitButtonDisabled = true;
                  }else if(!response.isSubmitted && response.currentBackEndStage == 'Pre Disbursement Check'){
                    this.isPDLASubmitted = false;
                    this.disableSubmit = false;
                    // this.disableRemarks = false;
                    this._saveButtonDisabled = false;
                    this._submitButtonDisabled = true;
                  }
                })
                .catch((error) => {
                  console.debug(error);
                });
            }
        } else {
          if (this.isPSLASubmitted) {
            this.template
              .querySelectorAll("lightning-input-field")
              .forEach((input) => {
                input.disabled = true;
              });
            this.template
              .querySelectorAll(".addStamp")
              .forEach((input) => {
                input.disabled = true;
              });
            this.template
              .querySelectorAll("lightning-button")
              .forEach((input) => {
                if (parseInt(input.dataset.accord) == 7) {
                  input.disabled = false;
                }
                if(parseInt(input.dataset.accord) == 1){
                  input.disabled = true;
                }
                if(this.isEAgreementType && parseInt(input.dataset.accord) == 7){
                  input.disabled = true;
                }
              });
              this.emidisable = true;
              this._submitButtonDisabled = this.isPSLASubmitted ? true : false;
          }else{
            await this.getAdvancedEMIController(); //INDI-4365
          }
        }
        this.template.querySelectorAll("lightning-input-field").forEach((input) => {
          if(input.fieldName == "Agreement_Type__c"){
            if(input.value == 'e-agreement'){
              this.isEAgreementType = true;
              this.isPhysicalAgreement = false;
            }else{
              this.isPhysicalAgreement = true;
              this.isEAgreementType = false;
            }
          }
          if (input.fieldName == "Invoice_Date__c") {
            input.value = this.invoiceDate;
          // } else if (input.fieldName == "AgreementDate__c") {
          //   if (!input.value) {
          //     let agreementDate = new Date();
          //     this.agreementDate = agreementDate.toLocaleDateString("en-CA");
          //     input.value = this.agreementDate;
          //   }
          } else if (input.fieldName == "Finance_Amount__c") {
            input.value = this.financeAmount;
          } else if (
            input.fieldName == "Is_Additional_Loan_Agreement_Stamp_Duty__c"
          ) {
            input.checked = this.additionalSDAdded;
            // } else if (
            //   input.fieldName == "Required_Loan_Agreement_Stamping_Charges__c"
            // ) {
            //   input.value = this.requiredStampingChanges;
          } else if (input.fieldName == "E_Agreement_Supported_In_State__c") {
            if (this.isEAgreementType) {
              input.value = "Yes";
            } else if (this.agreementType == '') {
              input.value = "";
            }
            else if(this.isPhysicalAgreement) {
              input.value = "No";
            }
          } else if (input.fieldName == "Effective_Deal_Date__c") {
            if (input.value == null) {
              input.value = this.sanctionDate;
            }
          }
        });
        if(this.readonly || this.isPSLASubmitted){
          this.showemidropdown = false;//
          this.template.querySelectorAll(`lightning-button[data-name="additional-btn"]`).forEach((input) => {
            input.disabled = true;
          });
        }
        if(this.isRevokedLoanApplication){this.disableEverything();}//CISP-2735
      }
    } catch (error) {
      console.error('renderedCallback ', error);
    }
  }
  @track vehiclerecordid;
  @api isRevokedLoanApplication;//CISP-2735
  async connectedCallback() {
    await getRecentEMIdetails({loanId:this.oppId}).then((data)=>{
      if(data && data.length>0){
         this.disableInsSchedule = false;
      }else{
         this.disableInsSchedule = true;
      }
   }).catch((error) => { console.log('error in getRecentEMIdetails ',error);});
    await getLoanAppDetails({
      loanAppId: this.oppId
    }).then((response) => {
      console.log('loanDetail-',response);
      if(response.Product_Type__c){
        this.isTractor = response.Product_Type__c == 'Tractor' ? true : false;
        console.log('isTractor--',this.isTractor);
      }
    }).catch((error) => {
      console.log('err-loanDetail',error);
    });
    if(this.isTractor){
      let response = await getVehicleID({'loanApplicationId' : this.oppId , 'dealId' : this.dealId});
      this.vehiclerecordid = response;
    }
  
      getTVRDetails({
        loanAppId: this.oppId
      }).then((response) => {
        console.log('TVR Details1-->',response);
        this.applicantData = response.map(item => ({
          id: item.Id,
          Name: item.Applicant__r.Name,
          Is_customer_using_Aadhar_Linked_Mob_No__c: item.Is_customer_using_Aadhar_Linked_Mob_No__c,
          Is_customer_s_Mob_No_linked_to_Aadhar__c: item.Is_customer_s_Mob_No_linked_to_Aadhar__c,
          Is_customer_having_an_Aadhar_Card__c: item.Is_customer_having_an_Aadhar_Card__c, 
      }));  
      }).catch((error) => {
        console.log('err-TVRDetails',error);
      });
      
      await getFinalTermObjectAsPerVehicle({ 'loanApplicationId': this.oppId, vehicleId: this.vehiclerecordid }).then((response) => {
        if (response) {
          this.installmentFrequency = response.Installment_Frequency__c;
        }
      }
      ).catch((error) => {
      });
   
    await getAgreementCopyDocumentData({
      loanApplicationId: this.oppId,
      dealId: this.dealId
    })
      .then((response) => {
        if (response) {
          this.agreeementDoc = response;
          this.documentRecordId = this.agreeementDoc[0].Id;

          if (this.documentRecordId) {
            this.disableSubmit = false;
          }
        }
      })
      .catch((error) => {
        this.showSpinner = false;
        console.debug(error);
      });
    // this.showSpinner = true;
    this.disableSubmit = true; // Gaurav : Changes
    isRequiredStageCompleted({
      oppId: this.oppId,
      dealId: this.dealId
    })
      .then((response) => {
        if (response == submittedFlagFailed && this.currentStep == 'post-sanction') {
          this.hasError = true;
          this.errorMessage = IsIHMReceiptGenerated;
        }
        else if (response == tvrStatusFailed && this.currentStep == 'post-sanction') {
          this.hasError = true;
          this.errorMessage = IsTVRPassed;
        }
      })
      .catch((error) => {
        this.showSpinner = false;
        console.error(error);
      });
    if (!this.hasError) {
      await getLoanAgreement({
        oppId: this.oppId,
        dealId: this.dealId
      })
        .then((result) => {
          if (result) {
            //CISP-133
            this.isEligibleForEAgreement = result.isEligibleForEAgreement;
            console.log('isEligibleForEAgreement ', this.isEligibleForEAgreement);
            //CISP-133
            refreshApex(this.loanAgreementData);
            let response = result.loanAgreement;
            this.financeAmount = result.financeAmount;
            this.loanAgreementId = response.Id;
            this.agentBLCode = response.Loan_Application__r.Agent_BL_code__c;
            this.sanctionDate = response.Loan_Application__r.Sanction_Date__c;
            this.productType = response.Loan_Application__r.Product_Type__c;
            this.additionalSDAdded =
              response.Is_Additional_Loan_Agreement_Stamp_Duty__c;
              
            let firstdate = new Date(response.Ist_EMI_Due_Date__c);
            firstdate = new Date(firstdate.getFullYear(),firstdate.getMonth(),firstdate.getDate());
            this.firstdateTest = firstdate.toString();
            this.emidatelist.push({label:firstdate.getDate()+'-'+(firstdate.getMonth()+1)+'-'+firstdate.getFullYear(), value: firstdate.toString()});
            this.emidate = firstdate.toString();
            //
           
            if (response.Is_Additional_Loan_Agreement_Stamp_Duty__c) {
              this.showAddlSDLA = true;
            }
            this.isEAgreementType = response
              ? response.Agreement_Type__c
                ? response.Agreement_Type__c.toLowerCase() == "e-agreement"
                  ? true
                  : false
                : false
              : false;
            if (this.isEAgreementType == false) {
              this.isPhysicalAgreement = true;
            } 

            if (response.Agreement_Booklet_Num__c) {
              this.agreementBookletNumber = response.Agreement_Booklet_Num__c;
            }
            if (response.Total_Value_to_be_Stamped__c) {
              this.requiredStampingChanges =
                response.Total_Value_to_be_Stamped__c;
            }
            this.currentStageName = response.Loan_Application__r.StageName;
            currentUserProfile({
              userId: USER_ID,
            }).then((result) => {
              if (
                response.Loan_Application__c
                  ? response.Loan_Application__r.StageName ==
                  "Pre Disbursement Check"
                  : false
              ) {
                this.readonly = true;
                this.disableRemarks = false;
                if ((!result?.includes('CVO') && !result?.includes('Admin') && !this.isTractor) || (!result?.includes('IBL TF Payment Executive') && !result?.includes('IBL TF Internal Payment Executive') && !result?.includes('Admin') && this.isTractor)) {
                  this.isSubmitButtonVisible = false;
                }
              } else {
                this.disableRemarks = true;
              }
              if ((response?.Loan_Application__c ? response?.Loan_Application__r?.StageName == "Post Sanction Checks and Documentation" : false) && this.isTractor && !result?.includes('CVO') && !result?.includes('Admin')) {
                console.log('isSubmitButtonVisible ', this.isSubmitButtonVisible);
                this.isSubmitButtonVisible = false;
              }
            })
            .catch((error) => {
              this.showSpinner = false;
              console.debug(error);
            });
            console.debug(this.readonly);
            if (this.readonly) {
              console.debug(this.disableRemarks);
              this.docLabel = "View Scanned Booklet";
              this.title = "View Scanned Booklet";
            }

            //CISP-2448
            if(response.Add_POA_SD_Initiation_method__c){
              this.disableInitiateAgreement = false;
              if(this.hasCoBorrower){
                this.disableInitiateCoBorrowerAgreement = false;
              }
              this.disableCheckstatus = false;
            }
            //CISP-2448

            if (this.currentStep === 'post-sanction' && this.currentStageName == "Pre Disbursement Check") {
              this.isSubmitButtonVisible = false;
              this.disableSubmit = false;
              this.disableRemarks = true;
              this.disableCVOFields = true;
              this.disableGetBookletButton = true;
              this.saveBtnDisable = true;
              this.documentBtnDisable = true;
              this.docLabel = 'Upload Scanned Booklet';
              this.title = 'Upload Scanned Booklet';
       //       this.emiDisabled = true;
              this.disableDealDateBasedOn = true;
              this.disableinitiateMethod = true;
              this.readonly = true;
              //CISP-2448
              this.disableCheckstatus = true;
              this.disableInitiateAgreement = true;
              this.disableInitiateCoBorrowerAgreement = true;
              // CISP-2448
            }
            if (this.currentStep === 'post-sanction' && this.currentStageName == "Disbursement Request Preparation") {
              this.isSubmitButtonVisible = false;
              this.disableSubmit = false;
              this.disableRemarks = true;
              this.disableCVOFields = true;
              this.disableGetBookletButton = true;
              this.saveBtnDisable = true;
              this.documentBtnDisable = true;
              this.docLabel = 'Upload Scanned Booklet';
              this.title = 'Upload Scanned Booklet';
      //        this.emiDisabled = true;
              this.disableDealDateBasedOn = true;
              this.disableinitiateMethod = true;
              this.readonly = true;
              //CISP-2448
              this.disableCheckstatus = true;
              this.disableInitiateAgreement = true;
              this.disableInitiateCoBorrowerAgreement = true;
              // CISP-2448
            }
            if (this.currentStep === 'pre-disbursement' && this.currentStageName == "Disbursement Request Preparation") {
              this.isSubmitButtonVisible = false;
              this.disableSubmit = false;
              this.disableRemarks = true;
              this.disableCVOFields = true;
              this.disableGetBookletButton = true;
              this.saveBtnDisable = true;
              this.documentBtnDisable = true;
              this.docLabel = 'View Scanned Booklet';
              this.title = 'View Scanned Booklet';
      //        this.emiDisabled = true;
              this.disableDealDateBasedOn = true;
              this.disableinitiateMethod = true;
              this.readonly = true;
              // CISP-2448
              this.disableCheckstatus = true;
              this.disableInitiateAgreement = true;
              this.disableInitiateCoBorrowerAgreement = true;
              // CISP-2448
            }
            if (this.currentStep === 'pre-disbursement' && this.currentStageName == "Pre Disbursement Check") {
              this.disableGetBookletButton = true;
              // CISP-2448
              this.disableCheckstatus = true;
              this.disableInitiateAgreement = true;
              this.disableInitiateCoBorrowerAgreement = true;
              // CISP-2448
            }
          } 
        })
        .catch((error) => {
          console.debug(error);
        });

      this.initRows();

      getTaxInvoiceDate({
        loanAppId: this.oppId,
        dealId: this.dealId
      })
        .then((response) => {
          console.debug("getTaxInvoiceDate", response);
          if (response) {
            if (response.includes(NoInvoiceFound)) {
            } else {
              this.invoiceDate = response;
            }
          }

        })
        .catch((error) => {
          this.showSpinner = false;
          console.debug(error);
        });

        await checkApiCalloutStatus({loanApplicationId : this.oppId ,loanAgreementId : this.loanAgreementId, dealId: this.dealId}).then(response => {
          console.debug('checkApiCalloutStatus 1234', response);
          this.apiStatusWrapper = response;
          if(response.agreementType){
            this._saveButtonDisabled = false;
            this._uploadBookletBtnDisabled = true;
            this._submitButtonDisabled = true;
          }else{
            this._saveButtonDisabled = true;
            this._uploadBookletBtnDisabled = true;
            this._submitButtonDisabled = true;
          }

          if(this.isEAgreementType){
            this._uploadBookletBtnDisabled = true;
            if(this.apiStatusWrapper.agreementDate != null && this.apiStatusWrapper.agreementDate != '' && this.apiStatusWrapper.agreementDate != undefined){
              this._saveButtonDisabled = true;
              this.disableinitiateMethod = false;
            }else if(response.agreementType){
              this._saveButtonDisabled = false;
            }
            if(this.apiStatusWrapper.isCoBorrowerApiSuccess && this.apiStatusWrapper.isBorrowerApiSuccess){
              this._saveButtonDisabled = true;
              this._submitButtonDisabled = false;
              this.disableinitiateMethod = true;
    }
          }else if(this.isPhysicalAgreement){
            validateScannedDocs({loanApplicationId : this.oppId, dealId: this.dealId}).then(result => {
              if(result){
                this.documentPresent = true;
                this._submitButtonDisabled = false;
              }else{
                this.documentPresent = false;
              }

              if(this.apiStatusWrapper.agreementDate != null && this.apiStatusWrapper.agreementDate != '' && this.apiStatusWrapper.agreementDate != undefined && this.apiStatusWrapper.agreementType){
                this._saveButtonDisabled = true;
                this._uploadBookletBtnDisabled = false;
              }

              if(this.apiStatusWrapper.agreementType == ''){
                this._saveButtonDisabled = true;
                this._uploadBookletBtnDisabled = true;
                this._submitButtonDisabled = true;
                this.disableRemarks = true;
              }

            }).catch(error => {
              console.error('validateScannedDocs ',error);
            });
          }

          
        }).catch(error => {
          console.error('checkApiCalloutStatus ',error);
        });

        //CISP-2487
        await isEAgreementAPIsSuccess({oppId: this.oppId}).then(result=>{
          if(result){
            if(result.borrowerAPIsSuccessed){
              this.disableinitiateMethod = true;
              this.disableInitiateAgreement = true;
            }
            if(result.coBorrowerAPIsSuccessed){
              this.disableinitiateMethod = true;
              this.disableInitiateAgreement = true;
              this.disableInitiateCoBorrowerAgreement = true;
            }
          }
        });
        //CISP-2487
    }
        await isPostSanctionLASubmitted({
          oppId: this.oppId,
          dealId: this.dealId
        })
          .then((response) => {
            this.showSpinner = false;
            if (response) {
              console.debug('isPostSanctionLASubmitted', response);
              this.isPSLASubmitted = true;
              this._submitButtonDisabled = true;
              this.docLabel = "View Scanned Booklet";
              this.title = "View Scanned Booklet";
            }
          })
          .catch((error) => {
            this.showSpinner = false;
            console.debug(error);
          });
          
    
    if(this.isRevokedLoanApplication){this.disableEverything();}//CISP-2735
  }
  disableEverything(){
    let allElements = this.template.querySelectorAll('*');
    allElements.forEach(element =>
        element.disabled = true
    );
  }//CISP-2735-END

  //START - INDI-4365
  async getAdvancedEMIController(){
    try {
      await getAdvancedEMI({
        loanAppId: this.oppId,
        dealId: this.dealId
      })
        .then((response) => {
          this.monitoriumDaysValue = response.Holiday_period__c;
          try {
            let today = new Date();
            if (response.Advance_EMI__c || response == null) {
              this.IsAdvanceEMI = true;
              if (this.agreementDate) {
                today = new Date(this.agreementDate);
              }
  
              let x1stEMIDate1;
              let x2ndEMIDate1;
              if (
                this.productType &&
                this.productType.includes("Two Wheeler")
              ) {
                let effectiveDealDateElement1 = this.template.querySelector(`lightning-input-field[data-name="Effective_Deal_Date__c"]`)
                let effectiveDealDate1;
                if(effectiveDealDateElement1?.value){
                  effectiveDealDate1 = new Date(effectiveDealDateElement1.value);
                }else{
                  effectiveDealDate1 = new Date(this.sanctionDate);
                }
                x1stEMIDate1 = effectiveDealDate1;
                x2ndEMIDate1 = new Date(
                  (x1stEMIDate1.getFullYear()),
                  (x1stEMIDate1.getMonth() + 1),
                );
                if (parseInt(effectiveDealDate1.getDate()) > 0 && parseInt(effectiveDealDate1.getDate()) <= 15) {
                  x2ndEMIDate1 = new Date(
                    x2ndEMIDate1.getFullYear(),
                    x2ndEMIDate1.getMonth(),
                    parseInt(x1stTWEMIDueDate)
                  );
                } else {
                  x2ndEMIDate1 = new Date(
                    x2ndEMIDate1.getFullYear(),
                    x2ndEMIDate1.getMonth(),
                    parseInt(x21EMIDueDate)
                  );
                }
              } else if (
                this.productType &&
                this.productType.includes("Passenger Vehicles")
              ) {
                x1stEMIDate1 = new Date(this.sanctionDate);
                x2ndEMIDate1 = new Date(
                  (x1stEMIDate1.getFullYear()),
                  (x1stEMIDate1.getMonth() + 1),
                );
                if (parseInt(x1stEMIDate1.getDate()) > 0 && parseInt(x1stEMIDate1.getDate()) < 15) {
                  x2ndEMIDate1 = new Date(
                    x2ndEMIDate1.getFullYear(),
                    x2ndEMIDate1.getMonth(),
                    parseInt(x1stPVEMIDueDate)
                  );
                } else {
                  x2ndEMIDate1 = new Date(
                    x2ndEMIDate1.getFullYear(),
                    x2ndEMIDate1.getMonth(),
                    parseInt(x1stPVEMIDueDatev2)
                  );
                }
              } else if ( this.isTractor){
                 this.handleLoanEMIDate();
                 x1stEMIDate1 = new Date(this.firstEMIDate);
                 x2ndEMIDate1 = new Date(this.secondEMIDate);
              }
              // setTimeout(() => {
                this.template
                .querySelectorAll("lightning-input-field")
                .forEach((input) => {
                  if (input.fieldName == "Ist_EMI_Due_Date__c") {
                    input.value = x1stEMIDate1.getFullYear() + "-" + (x1stEMIDate1.getMonth() + 1) + "-" + x1stEMIDate1.getDate();                    
                  } else if (input.fieldName == "X2nd_EMI_Due_Date__c") {
                    input.value = x2ndEMIDate1.getFullYear() + "-" + (x2ndEMIDate1.getMonth() + 1) + "-" + x2ndEMIDate1.getDate();      
                  } else if (input.fieldName == "AgreementDate__c") {
                    this.agreementDate = today.getFullYear() + "-" + (today.getMonth() + 1) + "-" + today.getDate();
                    input.value = this.agreementDate;
                  } else if (
                    input.fieldName ==
                    "Is_1st_EMI_due_date_correctly_captured__c"
                  ) {
                    // console.debug(input);
                    input.checked = true;
                  }
                });
              // }, 3000);
            } else {
              let x1stEMIDate2 = new Date(
                (today.getFullYear()),
                (today.getMonth() + 1)
              );
              let x2ndEMIDate2 = new Date(
                (x1stEMIDate2.getFullYear()),
                (x1stEMIDate2.getMonth() + 1),
              );
              if (
                this.productType &&
                this.productType.includes("Two Wheeler")
              ) {
                let effectiveDealDateElement2 = this.template.querySelector(`lightning-input-field[data-name="Effective_Deal_Date__c"]`)
                let effectiveDealDate2;
                if(effectiveDealDateElement2?.value){
                  effectiveDealDate2 = new Date(effectiveDealDateElement2.value);
                }else{
                  effectiveDealDate2 = new Date(this.sanctionDate);
                }
                console.log('effectiveDealDate2' ,effectiveDealDate2);
                if (parseInt(effectiveDealDate2.getDate()) > 0 && parseInt(effectiveDealDate2.getDate()) <= 15) {
                  x1stEMIDate2 = new Date(
                    x1stEMIDate2.getFullYear(),
                    x1stEMIDate2.getMonth(),
                    parseInt(x1stTWEMIDueDate)
                  );
                  x2ndEMIDate2 = new Date(
                    x2ndEMIDate2.getFullYear(),
                    x2ndEMIDate2.getMonth(),
                    parseInt(x1stTWEMIDueDate)
                  );
                } else {
                  x1stEMIDate2 = new Date(
                    x1stEMIDate2.getFullYear(),
                    x1stEMIDate2.getMonth(),
                    parseInt(x21EMIDueDate)
                  );
                  x2ndEMIDate2 = new Date(
                    x2ndEMIDate2.getFullYear(),
                    x2ndEMIDate2.getMonth(),
                    parseInt(x21EMIDueDate)
                  );
                }
              } else if (
                this.productType &&
                this.productType.includes("Passenger Vehicles")
              ) {
                this.showemidropdown = true;
                let datelist = [];
                //if(this.emidatelist.length == 0){
                  
                //console.log('emilist..'+datelist);
               
                x1stEMIDate2 = new Date();
                x2ndEMIDate2 = new Date(
                  (x1stEMIDate2.getFullYear()),
                  (x1stEMIDate2.getMonth() + 1),
                );
                if(parseInt(x1stEMIDate2.getDate()) >= parseInt(x1stPVEMIDueDate) && parseInt(x1stEMIDate2.getDate()) < parseInt(x1stPVEMIDueDatev2)){
                  let firstdate = new Date(
                    x1stEMIDate2.getFullYear(),
                    x1stEMIDate2.getMonth(),
                    parseInt(x1stPVEMIDueDatev2)
                  );
                  datelist.push({ label: firstdate.getDate()+'-'+(firstdate.getMonth()+1)+'-'+firstdate.getFullYear(), value: firstdate.toString() });
                  let secdate = new Date(
                    x2ndEMIDate2.getFullYear(),
                    x2ndEMIDate2.getMonth(),
                    parseInt(x1stPVEMIDueDate)
                  );
                  datelist.push({ label: secdate.getDate()+'-'+(secdate.getMonth()+1)+'-'+secdate.getFullYear(), value: secdate.toString()});
                  let thirddate = new Date(
                    x2ndEMIDate2.getFullYear(),
                    x2ndEMIDate2.getMonth(),
                    parseInt(x1stPVEMIDueDatev2)
                  );
                  datelist.push({ label: thirddate.getDate()+'-'+(thirddate.getMonth()+1)+'-'+thirddate.getFullYear(), value: thirddate.toString()});
                } else {
                  let firstdateNew = new Date(
                    x1stEMIDate2.getFullYear(),
                    x1stEMIDate2.getMonth() + 1,
                    parseInt(x1stPVEMIDueDate)
                  );
                  datelist.push({label: firstdateNew.getDate()+'-'+(firstdateNew.getMonth()+1)+'-'+firstdateNew.getFullYear(), value: firstdateNew.toString()});
                  let secdateNew = new Date(
                    x2ndEMIDate2.getFullYear(),
                    x2ndEMIDate2.getMonth(),
                    parseInt(x1stPVEMIDueDatev2)
                  );
                  datelist.push({label: secdateNew.getDate()+'-'+(secdateNew.getMonth()+1)+'-'+secdateNew.getFullYear(), value: secdateNew.toString()});
                  //CISP-2420 AND CISP-2418 Replace thirddate with thirddateNew  - START
                  let thirddateNew = new Date(
                    x2ndEMIDate2.getFullYear(),
                    x2ndEMIDate2.getMonth() + 1,
                    parseInt(x1stPVEMIDueDate)
                  );
                  datelist.push({label: thirddateNew.getDate()+'-'+(thirddateNew.getMonth()+1)+'-'+thirddateNew.getFullYear(), value: thirddateNew.toString()});
                  //CISP-2420 AND CISP-2418 - END
                }
               this.emidatelist = datelist;
              } else if (this.isTractor){
              this.handleLoanEMIDate();
              x1stEMIDate2 = new Date(this.firstEMIDate);
              x2ndEMIDate2 = new Date(this.secondEMIDate);
               
             }
              // setTimeout(() => {
                this.template
                .querySelectorAll("lightning-input-field")
                .forEach((input) => {
                  if (input.fieldName == "Ist_EMI_Due_Date__c" && (this.productType.includes("Two Wheeler") || this.isTractor)) {
                    input.value = x1stEMIDate2.getFullYear() + "-" + (x1stEMIDate2.getMonth() + 1) + "-" + x1stEMIDate2.getDate();
                  } else if (input.fieldName == "X2nd_EMI_Due_Date__c" && ( this.productType.includes("Two Wheeler") || this.isTractor)) {
                    input.value = x2ndEMIDate2.getFullYear() + "-" + (x2ndEMIDate2.getMonth() + 1) + "-" + x2ndEMIDate2.getDate();
                  } else if (input.fieldName == "AgreementDate__c") {
                    this.agreementDate = today.getFullYear() + "-" + (today.getMonth() + 1) + "-" + today.getDate();
                    input.value = this.agreementDate;
                  }
                });
              // }, 3000);
            }
          } catch (err) { 
            // console.debug(err); 
          }
        })
        .catch((error) => {
          this.showSpinner = false;
          // console.debug(error);
        });
    } catch (error) {
      console.log('getAdvancedEMIController error ', error);
    }
  }
  //END - INDI-4365

  handleLoanEMIDate(){
    let loanDealDate = new Date().toISOString().split('T')[0];
    const X1stDate = new Date(loanDealDate);
    if(this.IsAdvanceEMI == false){
      const monthsToAdd = this.monitoriumDaysValue ? parseInt(this.monitoriumDaysValue)/30 : 0;
      this.firstEMIDate = new Date(X1stDate.getFullYear(),(X1stDate.getMonth() + monthsToAdd),);
      const targetFirstDate =  X1stDate.getDate() <= 15 ? 7 : 15;
      let firstEMI = new Date(this.firstEMIDate.getFullYear() , (this.firstEMIDate.getMonth()) , parseInt(targetFirstDate))
      this.firstEMIDate = firstEMI.getFullYear() + '-' + (firstEMI.getMonth() + 1)  + '-' +  firstEMI.getDate();
    }else{
        this.firstEMIDate = loanDealDate;
    }
    this.secondEMIDate = new Date(this.firstEMIDate);
    if (this.installmentFrequency === 'Monthly') {
        this.secondEMIDate = new Date(this.secondEMIDate.getFullYear(),(this.secondEMIDate.getMonth() + 1),);
        const targetSecondDate =  X1stDate.getDate() <= 15 ? 7 : 15;
        let seccondEMI = new Date(this.secondEMIDate.getFullYear() , (this.secondEMIDate.getMonth()) , parseInt(targetSecondDate))
        this.secondEMIDate = seccondEMI.getFullYear() + '-' + (seccondEMI.getMonth() + 1) + '-' + seccondEMI.getDate();    
    } else if (this.installmentFrequency === 'bi-monthly') {
        this.secondEMIDate = new Date(this.secondEMIDate.getFullYear(),(this.secondEMIDate.getMonth() + 2),);
        const targetSecondDate =  X1stDate.getDate() <= 15 ? 7 : 15;
        let seccondEMI = new Date(this.secondEMIDate.getFullYear() , (this.secondEMIDate.getMonth()) , parseInt(targetSecondDate))
        this.secondEMIDate = seccondEMI.getFullYear() + '-' + (seccondEMI.getMonth() + 1)  + '-' + seccondEMI.getDate();    
    } else if (this.installmentFrequency === 'Quarterly') {
        this.secondEMIDate = new Date(this.secondEMIDate.getFullYear(),(this.secondEMIDate.getMonth() + 3),);
        const targetSecondDate =  X1stDate.getDate() <= 15 ? 7 : 15;
        let seccondEMI = new Date(this.secondEMIDate.getFullYear() , (this.secondEMIDate.getMonth()) , parseInt(targetSecondDate))
        this.secondEMIDate = seccondEMI.getFullYear() + '-' + (seccondEMI.getMonth() + 1)  + '-' + seccondEMI.getDate();    
    } else if (this.installmentFrequency === 'Half yearly') {
        this.secondEMIDate = new Date(this.secondEMIDate.getFullYear(),(this.secondEMIDate.getMonth() + 6),);
        const targetSecondDate =  X1stDate.getDate() <= 15 ? 7 : 15;
        let seccondEMI = new Date(this.secondEMIDate.getFullYear() , (this.secondEMIDate.getMonth()) , parseInt(targetSecondDate))
        this.secondEMIDate = seccondEMI.getFullYear() + '-' + (seccondEMI.getMonth() + 1) + '-' + seccondEMI.getDate();
    }
  }
  @track apiStatusWrapper;
  @track documentPresent = false;
  isEligibleForEAgreementHandler(event) {//CISP-2484
    try {
      // CISP-2688-START
      let borrowerElement = this.template.querySelector(`lightning-input-field[data-id="Borrower_Has_Aadharcard__c"]`);
      let borrowerHasBorrowerValue;
      if(borrowerElement){
        borrowerHasBorrowerValue = borrowerElement.value;
      }
      // CISP-2688-END
      //CISP-133/CISP-2622-START
      if(this.template.querySelector(`lightning-input-field[data-name="Agreement_Type__c"]`) && (!this.readonly || !this.isPSLASubmitted)){//CISP-2608
        if(this.template.querySelector(`lightning-input-field[data-name="Agreement_Type__c"]`).value == 'e-agreement' && (!this.isEligibleForEAgreement || !borrowerHasBorrowerValue)){//CISP-2688
          this.showToast('','User is not eligible for e-agreement.','error','dismissable');
          this.isEAgreementType = false;
          this.isPhysicalAgreement = true;
          this.agreementType = 'Physical agreement';
          this.template.querySelector(`lightning-input-field[data-name="Agreement_Type__c"]`).value = this.agreementType;
          return;
        }
      }
      //CISP-133/CISP-2622-END
      let eAgreementSet = [];
      this.template.querySelectorAll("lightning-input-field").forEach((input) => {
        console.debug(input.dataset.section);
        console.debug(event.target.dataset.section);
        if (
          parseInt(input.dataset.section) == parseInt(event.target.dataset.section) &&
          parseInt(input.dataset.accord) == parseInt(event.target.dataset.accord)
        ) {
          console.debug(input.dataset.section);
          eAgreementSet.push(input.value);
        }
      });
      console.debug(eAgreementSet);
      if (eAgreementSet.length > 0) {
        if (!eAgreementSet[1] || eAgreementSet[1].toLowerCase() == "no") {
          this.showToast("Error !", Not_Eligible_for_EAgreement_Process, "error");
        } else if (
          eAgreementSet[1] &&
          eAgreementSet[2] &&
          eAgreementSet[3] &&
          eAgreementSet[4] &&
          ((eAgreementSet[5] && this.hasCoBorrower) || !this.hasCoBorrower)
        ) {
          this.showToast(
            "Success !",
            Application_is_eligible_for_e_agreement,
            "success"
          );
        } else if (
          eAgreementSet[1] &&
          (!eAgreementSet[2] ||
            !eAgreementSet[3] ||
            !eAgreementSet[4] ||
            !((eAgreementSet[5] && this.hasCoBorrower) || !this.hasCoBorrower))
        ) {
          this.showToast("Error !", Cannot_Continue_with_EAgreement, "error");
        }
      }
    } catch (err) {
      console.error(err);
    }
  }
  @wire(getNeslRetries)
  getMaxRetry({ error, data }) {
    if (data) {
      this.neslMaxRetryCount = data;
    } else if (error) {
      console.error("Error--getMaxRetry--" + JSON.stringify(error));
    }
  }

  @wire(getSubmittedCheck, { loanAppId: "$oppId", dealId: "$dealId" })
  getSubmittedCheck({ error, data }) {
    if (data) {
      this.isSubmittedcheck = data;
    } else if (error) {
      console.error("Error--getSubmittedCheck--" + JSON.stringify(error));
    }
  }

  @wire(getInitiateAgreementDisable, { loanAppId: "$oppId", dealId: "$dealId" })
  getInitiateAgreementDisable({ error, data }) {
    if (data) {
      this.initiateAgreementBtnDisable = data;
    } else if (error) {
      console.error("Error--getInitiateAgreementDisable--" + JSON.stringify(error));
    }
  }

  @wire(getLoanEAgreementDetails, { loanAppId: "$oppId", dealId: "$dealId" }) //'$recordId'
  getLoanEAgreement(value) {
    this.loanAgreementData = value;
    const { data, error } = value;
    this.agreementBookletNumber = '';
    this.currentAgreementBookletNumber = '';
    if (data) {
      this.agreementBookletNumber = data.Agreement_Booklet_Num__c == undefined ? '' : data.Agreement_Booklet_Num__c; // Gaurav : Changes
      this.currentAgreementBookletNumber = data.Agreement_Booklet_Num__c == undefined ? '' : data.Agreement_Booklet_Num__c; // Gaurav : Changes
      if (data.Agreement_Type__c == "Physical agreement") {
        this.disableInitiateAgreement = true;
        this.disableInitiateCoBorrowerAgreement = true;
        this.disableinitiateMethod = true;
        this.disableCheckstatus = true;
      } else if (data.Agreement_Type__c == "e-agreement") {
        this.disableInitiateAgreement = true;
        this.disableInitiateCoBorrowerAgreement = true;
        this.disableCheckstatus = true;
        // this.disableinitiateMethod = false;
        this.initateMethodValue = data.Add_POA_SD_Initiation_method__c
      }
    }
  }

  @wire(getApplicantDetails, { loanAppId: "$oppId" })
  getApplicantDetails({ error, data }) {
    if (data) {
      data.forEach((x) => {
        if (x.Applicant_Type__c == "Co-borrower") {
          //this.disableInitiateCoBorrowerAgreement = true;
          this.hasCoBorrower = true;
          this.coborrowerId = x.Id;
          this.coborrowerwillingness=x.Would_you_like_to_open_a_bank_account__c;
          this.coborrowerSMSsend = x.CASA_Consent_OTP__c;
          if(x.Who_will_repay_the_loan__c){
            this.whoWillRepayLoan = x.Who_will_repay_the_loan__c;
          }
          console.log('x applicant ',x);
          console.log('this.coborrowerSMSsend',this.coborrowerSMSsend);
        } else if (x.Applicant_Type__c == "Borrower") {
          this.hasBorrower = true;
          this.borrowerId = x.Id;
          this.borrowerwillingness=x.Would_you_like_to_open_a_bank_account__c;
          this.borrowerSMSsend = x.CASA_Consent_OTP__c;
          if(x.Who_will_repay_the_loan__c){
            this.whoWillRepayLoan = x.Who_will_repay_the_loan__c;
          }
          console.log('x applicant ',x);
          console.log('this.borrowerSMSsend',this.borrowerSMSsend);
        }
      });
    } else if (error) {
      console.error("Error--getApplicantDetails--> ", JSON.stringify(error));
    }
  }

  handleInitiateMethodChange(event) {
    let initateMethodVal = event.detail.value;
    this.initateMethodValue = initateMethodVal;
    this.disableSubmit = true;
    this.disableInitiateCoBorrowerAgreement = true;
    this.disableCheckstatus = true;
    if (initateMethodVal.length == 0) {
      this.disableInitiateAgreement = true;
    } else {
      this.disableInitiateAgreement =
        this.initiateAgreementBtnDisable == true ? true : false;
    }
  }

  handleInitiateAgreementClick(event) {
    let checkRetryExhaustedFlag = false;
    this.isSpinnerVisible = true;
    // CISP-2448
    const fields = {};
    this.template.querySelectorAll(`lightning-input-field[data-accord="8"]`).forEach((input) => {
      if(input.fieldName == 'Add_POA_SD_Initiation_method__c'){
        fields[input.fieldName] = input.value;
      }
    });
    this.template.querySelector("lightning-record-edit-form").submit(fields);
    // CISP-2448
    checkRetryExhausted({
      loanApplicationId: this.oppId,
      serviceName: NESL_EAgreementRetryCount,
      applicantId: this.borrowerId,
      applicantType: Borrower,
      currentStageName: this.currentStageName,
    })
      .then((result) => {
        checkRetryExhaustedFlag = result;
        if (checkRetryExhaustedFlag) {
          this.disableInitiateAgreement = true;
          this.disableInitiateCoBorrowerAgreement = true;
          const fields = {};

          fields[ID_FIELD.fieldApiName] = this.loanAgreementId;
          fields[AgreementType_FIELD.fieldApiName] = "Physical agreement";
          const recordInput = {
            fields: fields,
          };
          this.isSpinnerVisible = false;
          updateRecord(recordInput)
            .then(() => {
              refreshApex(this.loanAgreementData);
              this.isEAgreementType = false;
            })
            .catch((error) => {
              console.error(
                "record update fail in borrower maxtry catch",
                JSON.stringify(fields)
              );
            });
        }
        if (this.initateMethodValue == "Face to Face") {
          doInitiateNESLCallout({
            applicantId: this.borrowerId,
            loanAppId: this.oppId,
            initiationMethod: this.initateMethodValue,
            dealId: this.dealId
          })
            .then((result) => {
              this.isSpinnerVisible = false;
              const response = JSON.parse(result);

              if (response.response.status == "SUCCESS" && response?.response?.content[0]?.ResURL) {
                this.disableInitiateCoBorrowerAgreement =
                  this.hasCoBorrower == true ? false : true;
                this.disableCheckstatus = this.hasCoBorrower == true ? true : false;
                // this.disableSubmit = this.hasCoBorrower == true ? true : false;

                //CISP-2487
                const fields = {};

                fields[APP_ID_FIELD.fieldApiName] = this.borrowerId;
                fields[IS_NESL_API_SUCCEED.fieldApiName] = true;
                const recordInput = {
                  fields: fields,
                };
                updateRecord(recordInput);
                this.disableInitiateAgreement = true;
                this.disableinitiateMethod = true;
                //CISP-2487
                window.open(response.response.content[0].ResURL, "_blank");
              } else {

                this.showToast(
                  "",
                  `${NeSLEAgreementApiErrorMsg}`,
                  "error",
                  "sticky"
                );

                retryCountIncrease({
                  loanApplicationId: this.oppId,
                  serviceName: NESL_EAgreementRetryCount,
                  applicantId: this.borrowerId,
                  applicantType: Borrower,
                  currentStageName: this.currentStageName,
                })
                  .then((result) => {
                    if (result == true) {
                      refreshApex(this.loanAgreementData);
                    }
                  })
                  .catch((error) => {
                    console.error("error --> " + error);
                  });
              }
            })
            .catch((error) => {
              this.isSpinnerVisible = false;
              this.showToast(
                "",
                `${error.body.message}`,
                "error",
                "sticky"
              );
            });
        } else if (this.initateMethodValue == "Self") {
          doInitiateNESLCallout({
            applicantId: this.borrowerId,
            loanAppId: this.oppId,
            initiationMethod: this.initateMethodValue,
            dealId: this.dealId
          })
            .then((result) => {
              const response = JSON.parse(result);
              this.isSpinnerVisible = false;
              if (response.response.status == "SUCCESS" && response?.response?.content[0]?.ResURL) {
                this.disableCheckstatus = false;
                //    this.disableSubmit = false;
                const event = new ShowToastEvent({
                  title: `${NeSLEAgreementSelfThankYouMsg}`,
                  message: "",
                  variant: "success",
                  mode: "dismissable",
                });
                this.dispatchEvent(event);
                //CISP-2487
                const fields = {};

                fields[APP_ID_FIELD.fieldApiName] = this.borrowerId;
                fields[IS_NESL_API_SUCCEED.fieldApiName] = true;
                const recordInput = {
                  fields: fields,
                };
                updateRecord(recordInput);
                this.disableInitiateAgreement = true;
                this.disableinitiateMethod = true;
                //CISP-2487
                window.open(response.response.content[0].ResURL, "_blank");
              } else {
                this.showToast(
                  "",
                  `${NeSLEAgreementApiErrorMsg}`,
                  "error",
                  "dismissable"
                );

                retryCountIncrease({
                  loanApplicationId: this.oppId,
                  serviceName: NESL_EAgreementRetryCount,
                  applicantId: this.borrowerId,
                  applicantType: Borrower,
                  currentStageName: this.currentStageName,
                })
                  .then((result) => {
                    if (result == true) {
                      refreshApex(this.loanAgreementData);
                    }
                  })
                  .catch((error) => {
                    console.error("error --> " + error);
                  });
              }
            })
            .catch((error) => {
              console.error("error --> ", error);
              this.showToast(
                "",
                `${error.body.message}`,
                "error",
                "dismissable"
              );
              this.isSpinnerVisible = false;
            });
        }
      })
      .catch((error) => {
        console.error(error);
        this.isSpinnerVisible = false;
      });
  }

  handleInitiateCoBorrowerAgreementClick(event) {
    let checkRetryExhaustedFlag = false;
    this.isSpinnerVisible = true;
    checkRetryExhausted({
      loanApplicationId: this.oppId,
      serviceName: NESL_EAgreementRetryCount,
      applicantId: this.coborrowerId,
      applicantType: CoBorrower,
      currentStageName: this.currentStageName,
    })
      .then((result) => {
        checkRetryExhaustedFlag = result;
        if (checkRetryExhaustedFlag) {
          this.disableInitiateAgreement = true;
          this.disableInitiateCoBorrowerAgreement = true;
          const fields = {};

          this.isSpinnerVisible = false;

          fields[ID_FIELD.fieldApiName] = this.loanAgreementId;
          fields[AgreementType_FIELD.fieldApiName] = "Physical agreement";
          const recordInput = {
            fields: fields,
          };
          updateRecord(recordInput)
            .then(() => {
              refreshApex(this.loanAgreementData);
              this.isEAgreementType = false;
            })
            .catch((error) => {
              console.error(
                "record update fail in coborrower maxtry catch",
                JSON.stringify(fields)
              );
            });
        } else {
          if (this.initateMethodValue == "Face to Face") {
            doInitiateNESLCallout({
              applicantId: this.coborrowerId,
              loanAppId: this.oppId,
              initiationMethod: this.initateMethodValue,
              dealId: this.dealId
            })
              .then((result) => {
                const response = JSON.parse(result);

                if (response.response.status == "SUCCESS" && response?.response?.content[0]?.ResURL) {
                  this.disableCheckstatus = false;
                  window.open(response.response.content[0].ResURL, "_blank");
                  //CISP-2487
                  const fields = {};

                  fields[APP_ID_FIELD.fieldApiName] = this.coborrowerId;
                  fields[IS_NESL_API_SUCCEED.fieldApiName] = true;
                  const recordInput = {
                    fields: fields,
                  };
                  updateRecord(recordInput);
                  this.disableInitiateCoBorrowerAgreement = true;
                  //CISP-2487
                  this.isSpinnerVisible = false;
                } else {
                  this.showToast(
                    "",
                    `${NeSLEAgreementApiErrorMsg}`,
                    "error",
                    "dismissable"
                  );
                  this.isSpinnerVisible = false;
                  retryCountIncrease({
                    loanApplicationId: this.oppId,
                    serviceName: NESL_EAgreementRetryCount,
                    applicantId: this.coborrowerId,
                    applicantType: CoBorrower,
                    currentStageName: this.currentStageName,
                  })
                    .then((result) => {
                      if (result == true) {
                        refreshApex(this.loanAgreementData);
                      }
                    })
                    .catch((error) => {
                      console.error("error --> " + error);
                    });
                }
              })
              .catch((error) => {
                this.showToast(
                  "",
                  `${error.body.message}`,
                  "error",
                  "dismissable"
                );
                this.isSpinnerVisible = false;
              });
          }
        }
      })
      .catch((error) => {
        console.error(error);
        this.isSpinnerVisible = false;
      });
  }

  handleCheckStatusClick(event) {
    doNeSLAgreementStatusCallout({
      applicantId: this.borrowerId,
      loanAppId: this.oppId,
    })
      .then((result) => {
        const response = JSON.parse(result);

        this.disableSubmit = false;

        if (response.response.status == "SUCCESS") {
          if (
            response.response.content[0].Status_Code == "1" &&
            response.response.content[0].Esign_Link != null
          ) {
            this.showToast(
              "",
              AgreementSigningPending,
              "warning",
              "dismissable"
            );
          } else if (response.response.content[0].Status_Code == "S002") {
            let fields = {};
            fields["Id"] = this.loanAgreementId;
            fields[Add_POA_SD_Agreement_signed_for_borrower__c.fieldApiName] = true;
            fields[Add_POA_SD_Agreement_signed_for_co_borro__c.fieldApiName] = true;
            const recordInput = { fields };
            updateRecord(recordInput).then(() => {
              this.showToast(
                "",
                AgreementSignedSuccessfully,
                "success",
                "dismissable"
              );
              this._submitButtonDisabled = false;
            });
          }
        } else if (response.response.status == "FAILED") {
          this.showToast("", NoDataFound, "failed", "dismissable");
        }
      })
      .catch((error) => {
        console.error("Check Status Error->", error);
        this.showToast("", NoDataFound, "failed", "dismissable");//CISP-2487
      });
  }

  handleChange(event) {
    try{
      let section = parseInt(event.target.dataset.section);
      let accord = parseInt(event.target.dataset.accord);
      if (accord == 1) {
        switch (section) {
          case 1:
            this.template
              .querySelectorAll("lightning-input-field")
              .forEach((input) => {
                if (input.fieldName == "Agreement_Booklet_Num__c") {
                  if (
                    this.currentAgreementBookletNumber != '' &&
                    this.currentAgreementBookletNumber != input.value
                  ) {
                    this.showConfirmModal = true;
                    this.currentAgreementBookletNumber = input.value;
                  }
                }
              });
            break;
          case 2:
            break;
            var eAgreementSet = [];

            break;
          case 4:
            this.showExistingLASD = true;
            this.showExistingPOASD = true;
            break;
        }
      }
      if (accord == 3) {
        switch (section) {
          case 1:
            // if(this.showAddlSDLA){
            //     this.showAddlSDLA = false;
            // }else{
            //     this.showAddlSDLA = true;
            // }
            break;
        }
      }
      if (accord == 4) {
        switch (section) {
          case 1:
            //this.showAddlSDPOA = true;
            break;
        }
      }
      if (accord == 5) {
        switch (section) {
          case 1:
            if (event.target.value == true) {
              this.showAddlLASD = true;
            } else {
              this.showAddlLASD = false;
            }
            console.debug(this.showAddlLASD);
            break;
        }
      }
      if (accord == 6) {
        switch (section) {
          case 1:
            //this.showAddlPOASD = true;
            break;
        }
      }
      if (accord == 7) {
        switch (section) {
          case 1:
            if (this.readonly || this.isPSLASubmitted) {
              if (this.documentRecordId) {
                this.uploadScannedBookletFlag = true;
                this.showUpload = false;
                this.showPhotoCopy = false;
                this.showDocView = true;
                this.isVehicleDoc = false;
                this.isAllDocType = false;
                this.docLabel = 'View Scanned Booklet';
                this.title = 'View Scanned Booklet';
              } else {
                const evt = new ShowToastEvent({
                  title: "Document not found",
                  message: "This type of document not uploded yet.",
                  variant: "info",
                });
                this.dispatchEvent(evt);
              }
            } else {
              this.showUpload = true;
              this.showPhotoCopy = false;
              this.showDocView = true;
              this.isVehicleDoc = true;
              this.isAllDocType = false;
              this.uploadScannedBookletFlag = true;
              this.docLabel = 'Upload Scanned Booklet';
              this.title = 'Upload Scanned Booklet';
            }
            break;
        }
      }
    }catch(error){
      console.error('handleChange ', error);
    }
  }

  showConfirmationBox(event) {
    try {
      let effectiveDealDate;
      let toDate = new Date();
      var dateBefor30Days = new Date();
      dateBefor30Days.setDate(toDate.getDate() - 30);
      this.template
        .querySelectorAll("lightning-input-field")
        .forEach((input) => {
          if (input.fieldName == "Effective_Deal_Date__c") {
            console.debug(input.value);
            effectiveDealDate = new Date(input.value);
          }
        });
      console.debug(effectiveDealDate);
      console.debug(toDate);
      console.debug(dateBefor30Days);
      console.debug(new Date(this.sanctionDate));

      if (
        effectiveDealDate?.getTime() > toDate?.getTime() ||
        dateBefor30Days?.getTime() > effectiveDealDate?.getTime() ||
        effectiveDealDate?.getTime() < new Date(this.sanctionDate)?.getTime()
      ) {
        this.modalMessage =
          "Effective Deal Date should be within 30 days of current date or should be before or equal Sanction Date";
      } else {
        this.modalMessage =
          "1st EMI due date cannot be changed once submitted. Please press Okay to continue or Cancel to check and recapture the same.";
      }
      this.showModal = true;
    } catch (err) {
      console.debug(err);
    }
  }

  hideModal() {
    this.showModal = false;
    this.showFetchBookletSpinner = false;
    this.disableInitiateAgreement = true;
    this.disableInitiateCoBorrowerAgreement = true;
    this.disableinitiateMethod = true;
    this.disableCheckstatus = true;
  }

  //Gaurav
  hideConfirmModal() {
    this.showModal = false;
    this.showConfirmModal = false; // Confirm modal toggle ... Signing of e-agreement
    this.showFetchBookletSpinner = false; //
    this.template.querySelector(
      `lightning-input-field[data-name="Agreement_Booklet_Num__c"]`
    ).value = this.agreementBookletNumber;
    this.currentAgreementBookletNumber = this.agreementBookletNumber;
  }

  handleFieldChange(event) {
    try {
      console.debug('handleFieldChange ',event.target.fieldName);
      let effectiveDealDate = "";
      if (event.target.fieldName.includes("Invoice_Date__c")) {
        this.invoiceDate = event.target.value;
        if (this.dealDateBasedOn && this.dealDateBasedOn.includes('Invoice Date')) {
          effectiveDealDate = this.invoiceDate;
        }
      } else if (event.target.fieldName.includes("Tentative_Payment_Date__c")) {
        this.tentativePaymentDate = event.target.value;
        if (this.dealDateBasedOn && this.dealDateBasedOn.includes('Tentative Payment Date')) {
          effectiveDealDate = this.tentativePaymentDate;
        }
      } else if (event.target.fieldName.includes("Deal_Date_Based_On__c")) {
        this.dealDateBasedOn = event.target.value;
        if(this.dealDateBasedOn){
          if (event.target.value.includes("Invoice Date")) {
            effectiveDealDate = this.invoiceDate;
          } else if (event.target.value.includes("Sanction Date")) {
            effectiveDealDate = this.sanctionDate ? this.sanctionDate : null;
          } else if (event.target.value.includes("Tentative Payment Date")) {
            effectiveDealDate = this.tentativePaymentDate;
          }
        }
      }
      this.template
      .querySelectorAll("lightning-input-field")
      .forEach((input) => {
        if (input.fieldName == "Effective_Deal_Date__c") {
          if (effectiveDealDate) {
            input.value = effectiveDealDate;
            this.getAdvancedEMIController(); //INDI-4365
          }
        } 
      });
    } catch (error) {
      console.error('handleFieldChange ', error);
    }    
  }

  handleemichange(event) {
    if(event.target.name == 'firstEMI'){
      let firstemi = new Date(event.target.value);
      this.firstemidate = firstemi.getFullYear() + "-" + (firstemi.getMonth() + 1) + "-" + firstemi.getDate();
      let secemi = new Date(
        firstemi.getFullYear(),
        (firstemi.getMonth() + 1),
        firstemi.getDate()
      );
      this.template
      .querySelectorAll("lightning-input-field")
      .forEach((input) => {
        if (input.fieldName == "X2nd_EMI_Due_Date__c") {
          input.value = secemi.getFullYear() + "-" + (secemi.getMonth() + 1) + "-" + secemi.getDate();
        } 
      });
    }
  }

  getLABookletDetails(event) {
    this.handleSave(false);
    var bookletdetails = {};
    var havingNullValue;
    this.currentAgreementBookletNumber = this.template.querySelector(
      `lightning-input-field[data-name="Agreement_Booklet_Num__c"]`
    ).value; // Gaurav : Changes
    this.template.querySelectorAll("lightning-input-field").forEach((input) => {
      if (input.fieldName == "Agreement_Booklet_Num__c") {
        console.debug(input.value);
        bookletdetails[input.fieldName] = input.value;
        if (input.value == null || input.value == "") {
          havingNullValue = true;
        }
      }
    });
    if (havingNullValue) {
      this.showToast("Error!", Cannot_Proceed_Further, "error", "dismissable");
      return;
    }
    this.showFetchBookletSpinner = true;
    this.doStampingDetailsCallout(bookletdetails.Agreement_Booklet_Num__c);
  }

  async doAgreementBookletCalloutMethod(agreementBookletNumber) {
    try {
      console.debug(agreementBookletNumber);
      await doAgreementBookletCallout({
        agreementBookletNo: agreementBookletNumber,
        applicantId: this.borrowerId,
        loanAppId: this.oppId,
        dealId: this.dealId,
      })
        .then((result) => {
          let response = JSON.parse(result).response;
          if (response.status == "SUCCESS") {
            this.fetchAgreementBookletCalloutResponse = true;
          }
        if (response) {
          this.fetchAgreementBookletDetail(
            result,
            this.loanAgreementId,
            agreementBookletNumber
          );
          this.template
            .querySelectorAll("lightning-input-field")
            .forEach((input) => {
              if (response && response.content && response.content.length > 0) {
                for (let con of response.content) {
                  if (con.Stamp_Towards == "AGREEMENT") {
                    console.debug(con.Stamp_Value);
                    this.totalExistingStampDone = parseInt(con.Stamp_Value);
                    if (input.fieldName == "Existing_LA_Stamp_S_No__c") {
                      input.value = con.Stamp_S_No;
                    } else if (input.fieldName == "Existing_LA_Stamp_On__c") {
                      input.value = con.Stamp_On;
                    } else if (
                      input.fieldName == "Existing_LA_Stamped_For__c"
                    ) {
                      input.value = con.Stamped_For;
                    } else if (
                      input.fieldName == "Existing_LA_Stamped_Towards__c"
                    ) {
                      input.value = con.Stamp_Towards;
                    } else if (input.fieldName == "Existing_LA_Stamp_Type__c") {
                      input.value = con.Stamp_Type;
                    } else if (
                      input.fieldName == "Existing_LA_Stamp_Value__c"
                    ) {
                      input.value = con.Stamp_Value;
                    }
                  }
                }
              }
            });
          console.debug(this.totalExistingStampDone);
          console.debug(this.requiredStampingChanges);
          this.totalStampingDone =
            this.totalExistingStampDone + this.totalAdditionalStampDone;
          if (this.totalStampingDone == this.requiredStampingChanges) {
            console.debug(
              this.template.querySelector(
                `lightning-input-field[data-name=Loan_Agreement_Stamping_Met__c]`
              )
            );
            this.template.querySelector(
              `lightning-input-field[data-name=Loan_Agreement_Stamping_Met__c]`
            ).checked = true;
          }
          this.showToast(
            "Success!",
            Borrower_Agreement_Booklet_Received_Successfully,
            "success",
            "dismissable"
          );
          if (
            this.documentRecordId &&
            this.totalStampingDone <= this.requiredStampingChanges
          ) {
            this.disableSubmit = false;
          }
        } else {
          this.showToast(
            "Error!",
            Borrower_Agreement_Booklet_Not_Found,
            "error",
            "dismissable"
          );
        }
      })
      .catch((error) => {
        this.showToast(
          "Error!",
          Borrower_Agreement_Booklet_Not_Found,
          "error",
          "dismissable"
        );
        console.error("error: 1601", error);
        this.showFetchBookletSpinner = false;
      });
    } catch (error) {
      console.error('doAgreementBookletCalloutMethod ', error);
    }
      
  }

  fetchAgreementBookletDetail(response, loanAgreementId, bookletNumber) {
    try {
      
    console.debug(bookletNumber);
    getAgreementBookletDetails({
      responseStr: response,
      loanAgrementId: loanAgreementId,
      loanAppId: this.oppId,
      bookletNumber: bookletNumber,
      dealId: this.dealId
    })
      .then((response) => {
        if (response) {
          console.debug(response);
          this.loanAgreementId = response.Id;
          this.showFetchBookletSpinner = false;
          this.template
            .querySelectorAll("lightning-input-field")
            .forEach((input) => {
              if (input.dataset.accord == "1" && input.dataset.section == "2") {
                for (let key in response) {
                  if (input.fieldName == key) {
                    console.debug(key);
                    input.value = response[key];
                  }
                }
              }
            });
          this.showApplDetails = true;
        }
      })
      .catch((error) => {
        console.error("error:", error);
        this.showToast("Error!", Stamping_And_LoanAgremment_Save_Error, "error", "dismissable");
        this.showFetchBookletSpinner = false;
      });
    } catch (error) {
      console.error('fetchAgreementBookletDetail ', error);
    }
  }
  doStampingDetailsCallout(agreementBookletNumber) {
    try {
    doStampingDetailsCallout({
      applicantId: "",
      loanAppId: this.oppId,
      geoStateCode: this.geoStateCode,
      dealId: this.dealId
    })
      .then((response) => {
        if (response) {
           let stampingDetails = JSON.parse(response).response;
            if (stampingDetails.status == 'SUCCESS') {
              this.stampingDetailsCalloutResponse = true;
            }
          if (
            stampingDetails
              ? stampingDetails.content.length > 0
                ? stampingDetails.content[0].Dt_Stamping_Agree_Master
                  .length > 0
                : false
              : false
          ) {
            this.requiredStampingChanges = 0;
            for (let res of stampingDetails.content[0]
              .Dt_Stamping_Agree_Master) {
              if (res.Document_Type == "AGREEMENT") {
                console.debug(res.StampDuty_Amount);
                this.requiredStampingChanges += parseFloat(
                  res.StampDuty_Amount
                );
                if (
                  res.NESL_ESigning_Applicable_Flag.toLowerCase() == "y" &&
                  res.NESL_EStamp_Applicable_Flag.toLowerCase() == "y" &&
                  res.NESL_Digital_EStamp_Required_Flag.toLowerCase() == "y" &&
                  res.NESL_ESigning_Manual_Override_Flag.toLowerCase() == "n"
                ) {
                  this.agreementType = "e-agreement";
                  this.isEAgreementType = true;
                  this.isPhysicalAgreement = false;
                  this.template.querySelector(`lightning-input-field[data-name="E_Agreement_Supported_In_State__c"]`).value = 'Yes';
                } else {
                  this.agreementType = "Physical agreement";
                  this.isPhysicalAgreement = true;
                  this.isEAgreementType = false;
                  this.template.querySelector(`lightning-input-field[data-name="E_Agreement_Supported_In_State__c"]`).value = 'No';
                }

              }
            }
            const fields = {};
            this.template.querySelector(
              `lightning-input-field[data-name=Agreement_Type__c]`
            ).value = this.agreementType;
            fields[ID_FIELD.fieldApiName] = this.loanAgreementId;
            fields[AgreementType_FIELD.fieldApiName] = this.agreementType;
            fields[ReqStampingCharges_FIELD.fieldApiName] =
              this.requiredStampingChanges;
            const recordInput = {
              fields: fields,
            };
            this.isSpinnerVisible = false;
            updateRecord(recordInput)
              .then(() => {
                refreshApex(this.loanAgreementData);
                this._saveButtonDisabled = false;
                this.template.querySelectorAll(`lightning-input-field[data-section="3"]`).forEach((input) => {
                  if (input.fieldName == 'Tentative_Payment_Date__c' || input.fieldName == 'Due_Date_Pattern__c' || input.fieldName == 'Deal_Date_Based_On__c') {
                    input.disabled = false;
                  }
                });
                this.isPhysicalAgreement = this.agreementType == "Physical agreement" ? true : false;
                this.isEAgreementType = this.agreementType == "e-agreement" ? true : false;
              })
              .catch((error) => {
                console.error(
                  "record update fail in borrower maxtry catch",
                  JSON.stringify(fields)
                );
              });
          }
          console.debug(this.requiredStampingChanges);
          this.doAgreementBookletCalloutMethod(agreementBookletNumber);
        } else {
          this.showToast(
            "Error!",
            Stamping_Details_Error_Msg,
            "error",
            "dismissable"
          );
        }
      })
      .catch((error) => {
        console.error("error 1787:", error);
        this.showFetchBookletSpinner = false;
        this.showToast(
          "Error!",
          Stamping_Details_Error_Msg,
          "error",
          "dismissable"
        );
      });
    } catch (error) {
      console.error('doStampingDetailsCallout ', error);
    }
  }

  handleConfirmSave(event) {
    try {
      this.agreementBookletNumber = this.currentAgreementBookletNumber;
      this.disableGetBookletButton = false;
      this.showConfirmModal = false;
      deleteLoanAgreementDetails({ loanApplication: this.oppId, currentAgreementBookletNumber: this.currentAgreementBookletNumber, dealId: this.dealId }).then((result) => {
        if (!result.includes('error')) {
          this.loanAgreementId = result;
          this.documentPresent = false;
          this.removeAllRows(this.listOfStamps);
          this.showAddlLASD = false;
          // this.emiDisabled = false;
          this.isEAgreementType = '';
          this.isPhysicalAgreement = '';
          this.template.querySelector(`lightning-input-field[data-name="Is_Additional_Loan_Agreement_Stamp_Duty__c"]`).value = false;
          this.template.querySelector(`lightning-input-field[data-name="Geo_State_Code__c"]`).value = this.geoStateName;
          this.template.querySelector(`lightning-input-field[data-name="E_Agreement_Supported_In_State__c"]`).value = '';
          this.template.querySelector(`lightning-input-field[data-name="Loan_Agreement_Stamping_Met__c"]`).value = false;
          this.template.querySelector(`lightning-input-field[data-name="Agreement_Type__c"]`).value = '';
          this.template.querySelectorAll(`lightning-input-field[data-name="CheckBox"]`).forEach(element => {
            element.value = false;
          });
          this.template.querySelectorAll(`lightning-input-field[data-name="Date"]`).forEach(element => {
            element.value = '';
          });
          this.template.querySelectorAll(`lightning-input-field[data-name="PickList"]`).forEach(element => {
            element.value = '';
          });
          this.template.querySelectorAll(`lightning-input-field[data-name="Text"]`).forEach(element => {
            element.value = '';
          });
          this._saveButtonDisabled = true;
          this._uploadBookletBtnDisabled = true;
          this._submitButtonDisabled = true;
          this.disableinitiateMethod = true;
        }
      }).catch((error) => {
        console.error('deleteLoanAgreementDetails ', error);
      });
    } catch (error) {
      console.error('handleConfirmSave ',error);
    }
  }

  handleSave(event) {
    try {
      this.showSaveSpinner = true;
      this.showModal = false;
      const fields = {};
      this.template
        .querySelectorAll("lightning-input-field")
        .forEach((input) => {
          // INDI-4365/CISP-111-START
          console.log('readonly ', this.readonly);
            if (this.readonly) {
              if(input.fieldName == 'Is_1st_EMI_due_date_correctly_captured__c'){
                fields[input.fieldName] = input.value;
              }
            }else{
              if (this.finalAgreementSubmit || event) {
                if (parseInt(input.dataset.accord) <= 7) {
                  //CISP-2420 AND CISP-2418 - START
                  if(event){
                    fields[input.fieldName] = input.value;
                  }else if(!event && input.fieldName != 'AgreementDate__c'){
                    fields[input.fieldName] = input.value;
                  }
                  //CISP-2420 AND CISP-2418
                }
              }
              if (parseInt(input.dataset.accord) <= 6) {
                //CISP-2420 AND CISP-2418 - START
                if(event){
                  fields[input.fieldName] = input.value;
                }else if(!event && input.fieldName != 'AgreementDate__c'){
                  fields[input.fieldName] = input.value;
                }
                //CISP-2420 AND CISP-2418 - END
              }
            }
          });
          // INDI-4365/CISP-111-END 
      if(fields["Ist_EMI_Due_Date__c"] == undefined && !this.readonly) {
        fields["Ist_EMI_Due_Date__c"]=this.firstemidate;
      }
      this.stampingDetailsCalled = 0;
      console.debug('fields ', fields);
      this.template.querySelector("lightning-record-edit-form").submit(fields);
      refreshApex(this.loanAgreementData);
      if(event){
        // this.emiDisabled = true;
        if(!this.readonly){
          this.disableinitiateMethod = false;
          this.disableInitiateAgreement = this.initateMethodValue != undefined ? this.initateMethodValue.length > 0 ? false : true : true;
        }
        this._saveButtonDisabled = true;
        if(this.isPhysicalAgreement){
          this._uploadBookletBtnDisabled = false;
          this._submitButtonDisabled = this.documentPresent ? false : true;
        }
        this.template.querySelectorAll(`lightning-input-field[data-section="3"]`).forEach((input) => {
          if (input.fieldName == 'Tentative_Payment_Date__c' || input.fieldName == 'Due_Date_Pattern__c' || input.fieldName == 'Deal_Date_Based_On__c') {
            input.disabled = true;
          }
        });
        this.emidisable = true;
        if(!this.isPDLASubmitted && !this.disableCVOFields){
          this._saveButtonDisabled = true;
          this._submitButtonDisabled = false;
        }
      }
      this.showSaveSpinner = false;
    } catch (err) {
      console.debug(err);
    }
  }

  handleSuccess(event) {
    event.preventDefault();
    this.showSaveSpinner = false;
  }

  handleError(event) {
    try {
      event.preventDefault();
      this.showSaveSpinner = false;
    } catch (error) {
      // this.showToast("Error", "Something went wrong!", "error");
      console.error('handleError ', error);
    }
  }

  showToast(title, message, variant, mode) {
    const event = new ShowToastEvent({
      title: title,
      message: message,
      variant: variant,
      mode: mode,
    });
    this.dispatchEvent(event);
  }
  initRows() {
    let listOfStamps = [];
    this.createRow(listOfStamps);
    this.listOfStamps = listOfStamps;
  }
  createRow(listOfStamps) {
    let stampDetail = {};
    console.debug(this.loanAgreementId);
    if (listOfStamps && listOfStamps.length > 0) {
      stampDetail.Stamp_S_No__c =
        parseInt(listOfStamps[this.listOfStamps.length - 1].Stamp_S_No__c) + 1;
    } else {
      stampDetail.Stamp_S_No__c = 1;
    }
    stampDetail.Loan_Agreement__c = this.loanAgreementId;
    stampDetail.Stamp_Towards__c = "AGREEMENT";
    stampDetail.Type__c = "Additional LA";
    stampDetail.Stamp_Date__c = null;
    stampDetail.Stamp_Location_Type__c = "";
    stampDetail.Stamp_For__c = null;
    stampDetail.Stamp_Type__c = null;
    stampDetail.Stamp_Value__c = null;
    let _listOfStamps = [];
    _listOfStamps.push(stampDetail);
    listOfStamps.push(stampDetail);
  }

  addNewRow() {
    let _listOfStamps = this.listOfStamps;
    this.createRow(_listOfStamps);
    this.listOfStamps = [];
    this.listOfStamps = _listOfStamps;

  }
  get hasStampingDetails() {
    if(this.stampingDetails?.additionalStampList?.length > 0){
      return true;
    }else{
      return false;
    }
  }

  removeRow(event) {
    let toBeDeletedRowIndex = event.target.name;

    let listOfStamps = [];
    for (let i = 0; i < this.listOfStamps.length; i++) {
      let tempRecord = Object.assign({}, this.listOfStamps[i]); //cloning object
      if (tempRecord.Stamp_S_No__c !== toBeDeletedRowIndex) {
        listOfStamps.push(tempRecord);
      }
      else if(tempRecord.Stamp_S_No__c == toBeDeletedRowIndex && tempRecord?.Id != null){
        deleteRecord(tempRecord.Id);
      }
    }

    for (let i = 0; i < listOfStamps.length; i++) {
      listOfStamps[i].Stamp_S_No__c = i + 1;
    }

    this.listOfStamps = listOfStamps;
    if (this.listOfStamps.length === 0) {
      this.createRow(this.listOfStamps);
    }
    this.calculateValue();
  }

  removeAllRows(listOfStamps) {
    listOfStamps = [];
    this.createRow(listOfStamps);
    this.listOfStamps = listOfStamps;
    this.calculateValue();
  }

  calculateValue() {
    try {
      this.totalAdditionalStampDone = 0;
      console.debug(this.listOfStamps);
      if (this.listOfStamps && this.listOfStamps.length > 0) {
        for (let stamp of this.listOfStamps) {
          if (stamp.Stamp_Value__c) {
            this.totalAdditionalStampDone += stamp.Stamp_Value__c ? parseInt(stamp.Stamp_Value__c) : 0;
          }
        }
      }
      console.debug(this.totalAdditionalStampDone);
      this.totalStampingDone =
        this.totalAdditionalStampDone + this.totalExistingStampDone;
      this.template.querySelector(
        `lightning-input-field[data-name="Total_Loan_Agreement_Stamping__c"]`
      ).value = this.totalStampingDone;
      
      setTimeout(() => {
        if(parseInt(this.template.querySelector(`lightning-input-field[data-name="Total_Loan_Agreement_Stamping__c"]`).value) == 0 && 
        parseInt(this.template.querySelector(`lightning-input-field[data-label="Existing_LA_Stamp_Value__c"]`).value) == 0){
          this.template.querySelector(`lightning-input-field[data-name="Total_Loan_Agreement_Stamping__c"]`).value = this.template.querySelector(`lightning-input-field[data-name="Total_Value_to_be_Stamped__c"]`).value;
        }
      }, 1000);
    
      this.template.querySelector(
        `lightning-input-field[data-name=Total_Additional_LA_Stamping__c]`
      ).value = this.totalAdditionalStampDone;
      if (this.totalStampingDone == this.requiredStampingChanges) {
        this.template.querySelector(
          `lightning-input-field[data-name=Loan_Agreement_Stamping_Met__c]`
        ).checked = true;
      } else {
        this.template.querySelector(
          `lightning-input-field[data-name=Loan_Agreement_Stamping_Met__c]`
        ).checked = false;
      }
      if (
        this.documentRecordId &&
        this.totalStampingDone <= this.requiredStampingChanges
      ) {
        this.disableSubmit = false;
      }
        
    } catch (error) {
      console.error('calculateValue ', error);
    }
  }

  handleInputChange(event) {
    let index = event.target.dataset.id;
    let fieldName = event.target.name;
    let value = event.target.value;

    for (let i = 0; i < this.listOfStamps.length; i++) {
      if (this.listOfStamps[i].Stamp_S_No__c === parseInt(index)) {
        this.listOfStamps[i][fieldName] = value;
        if (fieldName.includes("Stamp_Value__c")) {
          this.calculateValue();
        }
        this.listOfStamps[i]["Loan_Agreement__c"] = this.loanAgreementId;
        this.listOfStamps[i]["Stamp_Towards__c"] = "AGREEMENT";
        this.listOfStamps[i]["Type__c"] = "Additional LA";
      }
    }
    console.debug(this.listOfStamps);
  }
  submitAdditionalStamps() {
    insertAdditionalStampings({
      JSONResponse: JSON.stringify(this.listOfStamps),
      agreementId: this.loanAgreementId
    })
      .then((data) => {
        this.showToast(
          "Success",
          Stamps_successfully_created,
          "success",
          "dismissable"
        );
        this.finalAgreementSubmit = true;
        this.handleSave(false);
      })
      .catch((error) => {
        console.error(error);
      });
  }
  async changeUploadBooklet(event) {
    this.uploadScannedBookletFlag = false;
    
    if(event?.detail?.DocumentId){
      this.documentRecordId = event.detail.DocumentId;
    }

    let result = await validateScannedDocs({loanApplicationId : this.oppId, dealId: this.dealId});
    if(result &&  this.isPhysicalAgreement){
      this._submitButtonDisabled = false;
    }else if(!result &&  this.isPhysicalAgreement){
      this._submitButtonDisabled = true;
    }
    
    if (
      event.detail &&
      !(this.totalExistingStampDone <= this.totalStampingDone)
    ) {
      this.disableSubmit = false;
    }
  }
  docUploadSuccessfully(event) {
    if(event?.detail && this.isPhysicalAgreement){
      this._submitButtonDisabled = false;
    }
  }
  async handleSubmitClick() {//CISP-2420 AND CISP-2418
    try{
      if(this.currentStageName == 'Post Sanction Checks and Documentation'  && this.source !=='D2C'){
      if (this.whoWillRepayLoan && this.whoWillRepayLoan == 'Borrower' && this.borrowerwillingness && (this.borrowerSMSsend== ' ' || this.borrowerSMSsend== null || this.borrowerSMSsend == undefined)) {
        this.applicantId = this.borrowerId;
        console.log('applicant id=> inside if ', this.applicantId);
        this.casaformSMS(this.applicantId,'CASA');
      }
      else if(this.whoWillRepayLoan && this.whoWillRepayLoan == 'Co-borrower' && this.coborrowerwillingness && (this.coborrowerSMSsend== ' ' || this.coborrowerSMSsend== null || this.coborrowerSMSsend == undefined)) {
        this.applicantId = this.coborrowerId;
        console.log('applicant id=> inside else ', this.applicantId);
        this.casaformSMS(this.applicantId,'CASA');
      }
      }
      if (this.readonly) {
        const fields = {};
        var isValid = true;
        fields[ID_FIELD.fieldApiName] = this.loanAgreementId;
        this.template
          .querySelectorAll("lightning-input-field")
          .forEach((input) => {
            if (input.disabled == false) {
              if (input.fieldName == "Is_Physical_Agreement_Eligible__c" && (input.value == '' || input.value == null
                || input.value == undefined)) {
                isValid = false;
                const evt = new ShowToastEvent({
                  title: "Error",
                  message: IsAgreementEligibleMandatory,
                  variant: 'error'
                });
                this.dispatchEvent(evt);
              }
              if (input.fieldName == "Add_POA_SD_Loan_agreement_accepted_by_CV__c" && (!input.value)) {
                isValid = false;
                const evt = new ShowToastEvent({
                  title: "Error",
                  message: IsEAgreementEligibleMandatory,
                  variant: 'error'
                });
                this.dispatchEvent(evt);
              }
              if (input.fieldName == "Is_Stamp_Duty_as_per_norms__c" && (input.value == '' || input.value == null
                || input.value == undefined)) {
                isValid = false;
                const evt = new ShowToastEvent({
                  title: "Error",
                  message: 'Is_Stamp_Duty_as_per_norms__c? is a mandatory field.',
                  variant: 'error'
                });
                this.dispatchEvent(evt);
              }
              if (
                input.fieldName == "Is_Physical_Agreement_Eligible__c" ||
                input.fieldName == "Remarks__c" || 
                input.fieldName == "Add_POA_SD_Loan_agreement_accepted_by_CV__c" ||
                input.fieldName == "Add_POA_SD_Remarks__c" ||
                input.fieldName == "Is_Stamp_Duty_as_per_norms__c"
              ) {
                fields[input.fieldName] = input.value;
              }
            }
          });
        const recordInput = { fields };
        if (isValid) {
          updateRecord(recordInput)
            .then(() => { })
            .catch((error) => {
              console.error('updateRecord ',error);
            });
          updateLoanTransacionHistoryToSubmitted({
            oppId: this.oppId,
            dealId: this.dealId
          })
            .then((data) => {
              if (data) {
                this.showToast(
                  "Success",
                  "Pre-Disbursement Loan Agreement is submitted",
                  "success",
                  "dismissable"
                );
              }
              this.disableInitiateAgreement = true;
              this.disableInitiateCoBorrowerAgreement = true;
              this.disableinitiateMethod = true;
              this.disableCheckstatus = true;
              this.disableSubmit = true;
              this._submitButtonDisabled = true;
            })
            .catch((error) => {
              console.error('error --> ',error);
            });
        }
      } else {
        //CISP-2420 AND CISP-2418 - START
        let result = await isEmiDatesCapturedInBackend({loanApplicationId: this.oppId, dealId: this.dealId});
        if(!result){
          this.showToast(
            "",
            'Please fill the first EMI and second EMI due dates.',
            "warning",
            "dismissable"
          );
          return;
        }
        //CISP-2420 AND CISP-2418 - END
        let agreementType = this.template.querySelector(`lightning-input-field[data-name="Agreement_Type__c"]`).value;
          let initiationMethod = this.template.querySelector(`lightning-input-field[data-name="Add_POA_SD_Initiation_method__c"]`) == null ? '' : this.template.querySelector(`lightning-input-field[data-name="Add_POA_SD_Initiation_method__c"]`).value;
        if((initiationMethod == '' || initiationMethod == null) && agreementType == 'e-agreement'){
          this.showToast(
            "",
            EAgreementWarningMsg,
            "warning",
            "dismissable"
          );
          return;
        }else{
          if (this.isEAgreementType && agreementType == 'e-agreement') {
            let fields = {};
            this.template.querySelectorAll(`lightning-input-field[data-accord="8"]`).forEach((input) => {
              fields[input.fieldName] = input.value;
            });
            this.template.querySelector("lightning-record-edit-form").submit(fields);
          }
        }
        if (this.stampingChargesCollected > this.totalStampingDone) {
          this.showToast(
            "Error!",
            "Stamping charges collected are more than total stamping done on the agreement. Please add " +
            this.stampingChargesCollected -
            this.totalStampingDone +
            " stamps to continue",
            "error",
            "dismissable"
          );
          this.disableInitiateAgreement = true;
          this.disableInitiateCoBorrowerAgreement = true;
          this.disableinitiateMethod = true;
          this.disableCheckstatus = true;
        } else {
          //this.showModal = true;
          this.finalAgreementSubmit = true;
          this.handleSave(false);
          updateLoanTransacionToSubmitted({
            oppId: this.oppId,
            dealId: this.dealId
          })
            .then((data) => {
              if (data) {
                this.showToast(
                  "Success",
                  "Post-Sanction Loan Agreement is submitted",
                  "success",
                  "dismissable"
                );
                this.isPSLASubmitted = true;
                //Added for IND-3527
                this.disableSubmit = true;
                this.disableGetBookletButton = true;
                this.isPhysicalAgreement = true;
                this.template.querySelector("lightning-button[data-id=savebtnId]").disabled = true;
                // End of IND-3527
                this.template.querySelector(`lightning-input-field[data-name="Agreement_Booklet_Num__c"]`).disabled = true;

                this.disableInitiateAgreement = true;
                this.disableInitiateCoBorrowerAgreement = true;
                this.disableinitiateMethod = true;
                this.disableCheckstatus = true;
                this.documentBtnDisable = true;

                this._saveButtonDisabled = true;
                this._submitButtonDisabled = true;
                this._uploadBookletBtnDisabled = true;
              }
            })
            .catch((error) => {
              console.error(error);
            });
        }
      }
    }catch(error){
      console.error(error);
    }
  }

  async casaformSMS(applicantId, flag) {
    console.log('type of message' + flag);
    console.log('Applicant record Id :' + applicantId);
    let otpValue;
    //Updating the applicant record with consent fields
    const tDatetime = new Date().toISOString();
    const fields = {};
    fields[APPLICANT_ID.fieldApiName] = applicantId;

    if (flag == 'CASA') {
        let applicationRanNum = Math.floor(Math.random() * 10000);
        otpValue = applicationRanNum;
        this.borrowerSMSsend = otpValue;
        this.coborrowerSMSsend = otpValue;
        console.log('this.borrowerSMSsend',this.borrowerSMSsend+' '+'this.coborrowerSMSsend',this.coborrowerSMSsend);
        fields[CASA_FORM_SMS_SENT.fieldApiName] = tDatetime;
        fields[APPLICANT_CASAConsentOTP.fieldApiName] = String(applicationRanNum);
    }
    const recordInput = { fields };
    await updateRecord(recordInput)
        .then(() => {
            console.log('Applicant record updated', recordInput);
            let smsRequestString = {
                'applicantId': applicantId,
                'loanApplicationId': this.oppId,
                'flag': flag,
                'otpForInsConsent': otpValue
            };

            console.log('smsRequestString :', smsRequestString);
            doSmsCallout({ //await
                smsRequestString: JSON.stringify(smsRequestString)
            })
                .then(smsresult => {
                    if (smsresult == 'SUCCESS') {
                        console.log('sms result => ', smsresult);
                        var getsms = parseInt(this.issmscalloutsborrower);

                        var getsmsco = parseInt(this.issmscalloutscoborrower);

                        const event = new ShowToastEvent({
                            title: 'Success',
                            message: Consent_Sent_Successfully,
                            variant: 'success',
                        });
                        this.dispatchEvent(event);

                        this.iconButton = true;
                        this.isConsentButtonDisabled = true;
                    }
                })
                .catch(error => {
                    this.error = error;
                    console.log('Consent ERROR' + JSON.stringify(error));
                });
        })
        .catch((error) => {
            this.error = error;
            console.log('Applicant record failed to update', recordInput);
        })
}
}