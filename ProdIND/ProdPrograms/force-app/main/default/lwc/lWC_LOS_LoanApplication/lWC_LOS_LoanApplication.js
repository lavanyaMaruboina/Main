import { LightningElement, track, wire, api } from 'lwc'; 
import { MessageContext } from 'lightning/messageService';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import userId from '@salesforce/user/Id';
import UserNameFld from '@salesforce/schema/User.Name';
import userEmailFld from '@salesforce/schema/User.Email';
import otpExpireTimeOut from '@salesforce/apex/LwcLOSLoanApplicationCntrl.otpExpireTimeOut';
import doSmsCallout from '@salesforce/apex/LwcLOSLoanApplicationCntrl.doSmsGatewayCallout';//CISP-2787
import ExceptionMessage from '@salesforce/label/c.ExceptionMessage';
import doDocAuthCreateApplicantCallout from '@salesforce/apexContinuation/IntegrationEngine.doDocAuthCreateApplicantCallout';
import doImageUploadCallout from '@salesforce/apexContinuation/IntegrationEngine.doImageUploadCallout';
import doTextMatchCallout from '@salesforce/apexContinuation/IntegrationEngine.doTextMatchCallout';
import sendConsentSMS from '@salesforce/apex/LwcLOSLoanApplicationCntrl.sendConsentSMS';
import poaTagging from '@salesforce/apex/LWC_LOS_HomePage_Cntrl.poaTagging';
import otpConsentCheck from '@salesforce/apex/LwcLOSLoanApplicationCntrl.otpConsentCheck';
import isCommunity from '@salesforce/apex/LwcLOSLoanApplicationCntrl.isCommunity';
import checkDocFromApp from '@salesforce/apex/LwcLOSLoanApplicationCntrl.checkDocFromApp';
import FORM_FACTOR from '@salesforce/client/formFactor';
import { NavigationMixin } from 'lightning/navigation';
import { loadStyle } from 'lightning/platformResourceLoader';
import LightningCardCSS from '@salesforce/resourceUrl/loanApplication';
import selfieUpload from '@salesforce/apex/LwcLOSLoanApplicationCntrl.selfieUpload';
import cibilTextMatch from '@salesforce/apex/LwcLOSLoanApplicationCntrl.cibilTextMatch';
import cibilTextMatchSaveResponse from '@salesforce/apex/LwcLOSLoanApplicationCntrl.cibilTextMatchSaveResponse';
import isFirstCoborrower from '@salesforce/apex/LwcLOSLoanApplicationCntrl.isFirstCoborrower';
import updateCustomerImageFileTitle from '@salesforce/apex/LwcLOSLoanApplicationCntrl.updateCustomerImageFileTitle';
import validateContactNumber from '@salesforce/apex/Utilities.validateContactNumber';
import lastNameError from '@salesforce/label/c.Last_Name_Error';
import RegEx_Alphabets_Only from '@salesforce/label/c.RegEx_Alphabets_Only';
import RegEx_Last_Name from '@salesforce/label/c.RegEx_Last_Name';
import Aadhaar from '@salesforce/label/c.Aadhaar';
import Pan from '@salesforce/label/c.Pan';
import DrivingLicence from '@salesforce/label/c.DrivingLicence';
import VoterID from '@salesforce/label/c.VoterID';
import Passport from '@salesforce/label/c.PassportDetails';
import RegEx_Number from '@salesforce/label/c.RegEx_Number';
import Mobile_Number_Error_Msg from '@salesforce/label/c.Mobile_Number_Error_Msg';
import Permnt_Same_as_Current from '@salesforce/label/c.Permnt_Same_as_Current';
import permanentAddressOptionsMsg from '@salesforce/label/c.permanentAddressOptionsMsg';
import CurrentAddressOptionsMsg from '@salesforce/label/c.CurrentAddressOptionsMsg';
import getCurrentOppRecord from '@salesforce/apex/LwcLOSLoanApplicationCntrl.getCurrentOppRecord';
import { getRecord, updateRecord } from 'lightning/uiRecordApi';
import Vehicle_New from '@salesforce/label/c.Vehicle_New';
import Vehicle_Old from '@salesforce/label/c.Vehicle_Old';
import docCustomerImage from '@salesforce/apex/LwcLOSLoanApplicationCntrl.docCustomerImage';
import updateConsentStatus from '@salesforce/apex/StoreDateTimeForConcent.updateConsentStatus';
import NumberOfProducts from '@salesforce/label/c.NumberOfProducts';
import EntityType from '@salesforce/label/c.EntityType';
import ApplicationType from '@salesforce/label/c.ApplicationType';
import Amountmessage from '@salesforce/label/c.Amountmessage';
import Borrower from '@salesforce/label/c.Borrower';
import ReadOnlyLeadAccess from '@salesforce/label/c.ReadOnlyLeadAccess';
import CoBorrower from '@salesforce/label/c.CoBorrower';
import Guarantor from '@salesforce/label/c.Guarantor';
import Tractor from '@salesforce/label/c.Tractor';
import PanCards from '@salesforce/label/c.PanCards';
import AadhaarCard from '@salesforce/label/c.AadhaarCard';
import CIN_CERT from '@salesforce/label/c.CIN_Cert';
import GST_CERT from '@salesforce/label/c.GST_Cert';
import DrivingLicences from '@salesforce/label/c.DrivingLicences';
import CustomerImageDocumentType from '@salesforce/label/c.CustomerImageDocumentType';
import PassportCard from '@salesforce/label/c.PassportCard';
import VoterIdCard from '@salesforce/label/c.VoterIdCard';
import Form60DocumentType from '@salesforce/label/c.Form60DocumentType';
import currentUserId from '@salesforce/label/c.currentUserId';
import currentUserName from '@salesforce/label/c.currentUserName';
import currentUserEmailid from '@salesforce/label/c.currentUserEmailid';
import mode from '@salesforce/label/c.mode';
import currentApplicantid from '@salesforce/label/c.currentApplicantid';
import userDetails from '@salesforce/label/c.userDetails';
import captureCurrentResidentialAddress from '@salesforce/label/c.captureCurrentResidentialAddress';
import capturePermanentResidentialAddress from '@salesforce/label/c.capturePermanentResidentialAddress';
import capturePANOrOtherKyc from '@salesforce/label/c.capturePANOrOtherKyc';
import captureDedupe from '@salesforce/label/c.captureDedupe';
import vehicleDedupes from '@salesforce/label/c.vehicleDedupes';
import DeclaredIncomeRequiredLoanAmount from '@salesforce/label/c.DeclaredIncomeRequiredLoanAmount';
import bankAccountCheck from '@salesforce/label/c.bankAccountCheck';
import gattingAndScreening from '@salesforce/label/c.gattingAndScreening';
import imageuploaded from '@salesforce/label/c.imageuploaded';
import restartJourneyHome from '@salesforce/label/c.restartJourneyHome';
import provideConsentUploadImage from '@salesforce/label/c.provideConsentUploadImage';
import detailsSaved from '@salesforce/label/c.detailsSaved';
import uploadatleastOneDocument from '@salesforce/label/c.uploadatleastOneDocument';
import updateAtleast2documents from '@salesforce/label/c.updateAtleast2documents';
import updatePanForm60document from '@salesforce/label/c.updatePanForm60document';
import RetrySelfe from '@salesforce/label/c.RetrySelfe';
import selectVehicleType from '@salesforce/label/c.selectVehicleType';
import selectVehicleNumber from '@salesforce/label/c.selectVehicleNumber';
import vehicleDedupeDetailsSaved from '@salesforce/label/c.vehicleDedupeDetailsSaved';
import verifyVehicleDedupe from '@salesforce/label/c.verifyVehicleDedupe';
import verifyVehicleDedupeBeforeNextScreen from '@salesforce/label/c.verifyVehicleDedupeBeforeNextScreen';
import eitherBorrowerCoborrowerIncomeSourceAvail from '@salesforce/label/c.eitherBorrowerCoborrowerIncomeSourceAvail';
import loanDetailsSavedSuccessfully from '@salesforce/label/c.loanDetailsSavedSuccessfully';
import coBorrowerAdditionMandatory from '@salesforce/label/c.coBorrowerAdditionMandatory';//CISP-2500 Modified custom label value.
import enterIncomeLoanAmount from '@salesforce/label/c.enterIncomeLoanAmount';
import coborrowerRequireAccount from '@salesforce/label/c.coborrowerRequireAccount';
import bankDetailsSavedSuccessfully from '@salesforce/label/c.bankDetailsSavedSuccessfully';
import sorryCannotPreviewForm60Document from '@salesforce/label/c.sorryCannotPreviewForm60Document';
import otpSentSuccessfully from '@salesforce/label/c.otpSentSuccessfully';
import coborrowesNeedsTohaveBankAccount from '@salesforce/label/c.coborrowesNeedsTohaveBankAccount';
import journeyNotProceed from '@salesforce/label/c.journeyNotProceed';
import journeyNotProceedGuarantor from '@salesforce/label/c.journeyNotProceedGuarantor';
import CoborrowerRequireAccountOpenNewaccount from '@salesforce/label/c.CoborrowerRequireAccountOpenNewaccount';
import consentInitialisationRequired from '@salesforce/label/c.consentInitialisationRequired';
import exhaustedAttempts from '@salesforce/label/c.exhaustedAttempts';
import noRegisteredWhatsAppBanking from '@salesforce/label/c.noRegisteredWhatsAppBanking';
import captureImageRequired from '@salesforce/label/c.captureImageRequired';
import kycDetailsUploaded from '@salesforce/label/c.kycDetailsUploaded';
import accountcheckdetailsMsg from '@salesforce/label/c.accountcheckdetailsMsg';
import ProvideKYContinue from '@salesforce/label/c.Please_provide_KYC_to_continue';
import allSectionsClosed from '@salesforce/label/c.All_sections_are_closed';
import FailResponseApi from '@salesforce/label/c.FailResponseApi';
import completeField from '@salesforce/label/c.completeField';
import incomeAmountMandatory from '@salesforce/label/c.incomeAmountMandatory';
import openNewBankAccountMsg from '@salesforce/label/c.openNewBankAccountMsg';
import bankAccountMandotory from '@salesforce/label/c.bankAccountMandotory';
import enterLoanAmount from '@salesforce/label/c.enterLoanAmount';
import validationMsgNoalreadyReg from '@salesforce/label/c.validationMsgNoalreadyReg';
import otpSend from'@salesforce/label/c.otpSend';
import LeadDetails from '@salesforce/label/c.LeadDetails';
import AgentBranchName from '@salesforce/label/c.AgentBranchName';
import ProductType from '@salesforce/label/c.ProductType';
import LeadNumber from '@salesforce/label/c.LeadNumber';
import CustomerFirstName from '@salesforce/label/c.CustomerFirstName';
import CustomerLastName from '@salesforce/label/c.CustomerLastName';
import CustomerPhoneNumber from '@salesforce/label/c.CustomerPhoneNumber';
import WhatsAppNumber from '@salesforce/label/c.WhatsAppNumber';
import EntityName from '@salesforce/label/c.EntityName';
import EntityTypeNonInd from '@salesforce/label/c.EntityTypeNonInd';
import EntityCode from '@salesforce/label/c.EntityCode';
import EntityCategory from '@salesforce/label/c.EntityCategory';
import Profile from '@salesforce/label/c.profile_Non_Ind';
import ContactPersonName from '@salesforce/label/c.ContactPersonName';
import LeadSource from '@salesforce/label/c.LeadSource';
import ClassofActivity from '@salesforce/label/c.ClassofActivity';
import LoanTypeNonInd from '@salesforce/label/c.LoanTypeNonInd';
import EvaluationType from '@salesforce/label/c.EvaluationType';
import MajorIndustry from '@salesforce/label/c.MajorIndustry';
import MinorIndustry from '@salesforce/label/c.MinorIndustry';
import OPP_ID_FIELD from '@salesforce/schema/Opportunity.Id';
import AGENT_BL_CODE_FIELD from '@salesforce/schema/Opportunity.Agent_BL_code__c';
import CUSTOMER_TYPE_FIELD from '@salesforce/schema/Opportunity.Customer_Type__c';
import LOAN_APPLICATION_TYPE_FIELD from '@salesforce/schema/Opportunity.Application_Type__c';
import PRODUCT_TYPE_FIELD from '@salesforce/schema/Opportunity.Product_Type__c';
import ENTITY_TYPE_FIELD from '@salesforce/schema/Opportunity.Entity_Type__c';
import ENTITY_NAME_FIELD from '@salesforce/schema/Opportunity.Entity_Name__c';
import PROFILE_FIELD from '@salesforce/schema/Opportunity.Profile__c';
import CONTACT_PERSON_FIELD from '@salesforce/schema/Opportunity.Contact_Person_Name__c';
import ENTITY_CATEGORY_FIELD from '@salesforce/schema/Opportunity.Entity_Category__c';
import LEAD_SOURCE_FIELD from '@salesforce/schema/Opportunity.Lead_Source_Non_Ind__c';
import CLASS_OF_ACTIVITY_FIELD from '@salesforce/schema/Opportunity.Class_of_Activity__c';
import LOAN_TYPE_FIELD from '@salesforce/schema/Opportunity.Loan_Type__c';
import EVALUATION_TYPE_FIELD from '@salesforce/schema/Opportunity.Evaluation_Type__c';
import MAJORINDUSTRY_TYPE_FIELD from '@salesforce/schema/Opportunity.Major_Industry__c';
import MINORINDUSTRY_TYPE_FIELD from '@salesforce/schema/Opportunity.Minor_Industry__c';
import LEAD_NUMBER_FIELD from '@salesforce/schema/Opportunity.Lead_number__c';
import APPLICANT_NAME_FIELD from '@salesforce/schema/Opportunity.Applicant_Name__c';
import accessLoanApplication from '@salesforce/apex/LwcLOSLoanApplicationCntrl.accessLoanApplication';//CISP: 2692
import OPP_JOURNEY_STATUS from '@salesforce/schema/Opportunity.Journey_Status__c';
import Selfie_Upload__c from '@salesforce/schema/Opportunity.Selfie_Upload__c';
import APP_ID_FIELD from '@salesforce/schema/Applicant__c.Id';
import OPP_ACCOUNT from '@salesforce/schema/Opportunity.AccountId';
import OPP_VEHICLETYPE from '@salesforce/schema/Opportunity.Vehicle_Type__c';//CISP-3239
import APPLICANT_SUBSTAGE from '@salesforce/schema/Applicant__c.Journey_Stage__c'
import APPLICANT_OBJECT from '@salesforce/schema/Applicant__c';
import ACCOUNT_APPLICANT_TYPE_FIELD from '@salesforce/schema/Applicant__c.Applicant_Type__c';
import CUSTOMER_NAME_FIELD from '@salesforce/schema/Applicant__c.Name';//Applicant Fields
import CUSTOMER_FIRST_NAME_FIELD from '@salesforce/schema/Applicant__c.Customer_First_Name__c';
import CUSTOMER_LAST_NAME_FIELD from '@salesforce/schema/Applicant__c.Customer_Last_Name__c';
import CUSTOMER_PHONE_NUMBER_FIELD from '@salesforce/schema/Applicant__c.Contact_number__c';
import CUSTOMER_WHATSAPP_NUMBER_FIELD from '@salesforce/schema/Applicant__c.Whatsapp_number__c';
import REGISTER_FOR_WHATSAPP_BANKING_FIELD from '@salesforce/schema/Applicant__c.Register_for_WhatsApp_Banking__c';
import OPPORTUNITY_APPLICANT_LOOKUP_FIELD from '@salesforce/schema/Applicant__c.Opportunity__c';
import CURRENT_SAME_AS_PERMANENT from '@salesforce/schema/Applicant__c.Current_Same_As_Permanent__c';
import CURRENT_ADDRESS_NOT_PRESENT from '@salesforce/schema/Applicant__c.Current_Address_Not_Present__c';
import IS_ADDRESS_DECLARATION from '@salesforce/schema/Applicant__c.Is_Address_Declaration__c';//CISP-2701
import PERMANENT_ADDRESS_NOT_PRESENT from '@salesforce/schema/Applicant__c.Permanent_Address_Not_Present__c';
import DocAuth_Application_Id from '@salesforce/schema/Applicant__c.DocAuth_Application_Id__c';
import LITERACY_FIELD from '@salesforce/schema/Applicant__c.Literacy__c'; //SFTRAC-33
import ISPRIMARY from '@salesforce/schema/Applicant__c.IsPrimary__c';

import LOAN_OBJECT from '@salesforce/schema/Opportunity';
import { getObjectInfo } from 'lightning/uiObjectInfoApi'; //SFTRAC-33
import { getPicklistValues } from "lightning/uiObjectInfoApi"; //SFTRAC-33
import AADHAAR_LOGO from '@salesforce/resourceUrl/AadharCard';
import PASSPORT_LOGO from '@salesforce/resourceUrl/Passport';
import VOTERID_LOGO from '@salesforce/resourceUrl/VoterID';
import GST_LOGO from '@salesforce/resourceUrl/GST';
import CIN_LOGO from '@salesforce/resourceUrl/CIN';
import DL_LOGO from '@salesforce/resourceUrl/DrivingLicense';
import PAN_LOGO from '@salesforce/resourceUrl/PANCard';
import DOC_ID_FIELD from '@salesforce/schema/Documents__c.Id';
import CURRENT_RESIDENTIAL_ADDRESS_PROOF from '@salesforce/schema/Documents__c.Current_Residential_Address_Proof__c';
import PERMANENT_RESIDENTIAL_ADDRESS_PROOF from '@salesforce/schema/Documents__c.Permanent_Residential_Address_Proof__c';
import ADDRESS_TYPE from '@salesforce/schema/Documents__c.Addresss_Type__c';
import kycDelete from '@salesforce/apex/LwcLOSLoanApplicationCntrl.kycContentDocDelete';
import getResendTime from '@salesforce/apex/LwcLOSLoanApplicationCntrl.getResendTime';
import getAccountTeamMembers from '@salesforce/apex/LwcLOSLoanApplicationCntrl.findAccountTeamMembers';
import createPersonAccWithCustCodeAssignment from '@salesforce/apex/LwcLOSLoanApplicationCntrl.createPersonAccWithCustCodeAssignment';
import deleteEmptyKycDoc from '@salesforce/apex/LwcLOSLoanApplicationCntrl.deleteEmptyKycDoc';
import fetchCdocumentId from '@salesforce/apex/LwcLOSLoanApplicationCntrl.fetchCdocumentId';
import upsertRecords from '@salesforce/apex/LwcLOSLoanApplicationCntrl.upsertRecords';//CISP-2457 /CISP-2506
import getLoanApplicationReadOnlySettings from '@salesforce/apex/LwcLOSLoanApplicationCntrl.getLoanApplicationReadOnlySettings';//Ola integration changes
import getCustomerDedupeData from '@salesforce/apex/LwcLOSLoanApplicationCntrl.getCustomerDedupeData';//CISP-5266
import getAadharDetails from '@salesforce/apex/LwcLOSLoanApplicationCntrl.getAadharDetails'; //CISP-20674
import updateJourneyStop from '@salesforce/apex/customerDedupeRevisedClass.updateJourneyStop'; //CISP-4459
import {customLabels}  from './lWC_LOS_LoanApplicationHelper';
import * as helper from './lWC_LOS_LoanApplicationHelper';
import OPP_TopUpLoan from '@salesforce/schema/Opportunity.isTopUpLoan__c';//SFTRAC-172
import checkRetryExhausted from '@salesforce/apex/LwcLOSGattingAndScreeningCntrl.checkRetryExhausted'; //SFTRAC-536
import Retry_Exhausted from '@salesforce/label/c.Retry_Exhausted';//SFTRAC-536
import SuccessMessage from '@salesforce/label/c.SuccessMessage';//SFTRAC-536
import BENEFICIAL_OWNER_CATEGORY from '@salesforce/schema/Applicant__c.Beneficial_Owner_Category__c';//SFTRAC-78
import RELATIONSHIP_WITH_ENTITY from '@salesforce/schema/Applicant__c.Relationship_with_Entity__c';//SFTRAC-78
import RELATIONSHIP_TYPE from '@salesforce/schema/Applicant__c.Relationship_Type__c';//SFTRAC-78
import SHAREHOLDER_PERCENT from '@salesforce/schema/Applicant__c.ShareHolding__c';
import POA_HOLDER from '@salesforce/schema/Applicant__c.POA_Holder__c';//SFTRAC-78
import getBLCodesInActive from '@salesforce/apex/LwcLOSLoanApplicationCntrl.getBLCodesInActive';


export default class LWC_LOS_LoanApplication extends NavigationMixin(LightningElement) {
    disableAeps = true;aepsValue;@api currentTabId;currentJourneyStage;
    labelCustom = customLabels;isModalOpenForIncome=false;leadSource = ''; // MSIL Api changes
    @track vehicleTypeval;agentBLCodeOptionsvalues;//CISP-3293
    @track literacyFieldOptionValue; //SFTRAC-33
    @track selectedLiteracyFieldOptionValue= ''; //SFTRAC-33
    @track profileOptions = [];
    @track applicationTypeVal = 'Tractor'; @track disableApplicationType = false; @track disableEntityType = false;//SFTRAC-60
    get vehicleTypeOptions() {let options = [ { label: 'Used', value: 'Used' }, { label: 'Refinance', value: 'Refinance' },];
        if (this.leadSource !== 'DSA') { options = [{ label: 'New', value: 'New' }, ...options]; }return options;}
    get entityOptions() {let options = [ { label: 'Individual', value: 'Individual' }, { label: 'Non-Individual', value: 'Non-Individual' }];return options;}
    get applicationTypeOptions() {let allowedTypes = ['new']; let options = allowedTypes.includes(this.vehicleTypeval.toLowerCase()) ? [{label: 'Tractor', value: 'Tractor'}, {label: 'Build Body and Chassis Funding', value: 'Build Body and Chassis Funding'}] : [{label: 'Tractor', value: 'Tractor'}]; return options;}
    @api creditval;@api checkleadaccess;@api currentApplicantStage;currentUserId = userId;currentUserName;currentUserEmailId;error; @api gstDocId = null; @api cinDocId = null;@track gstButton = false; @track cinButton = false;kycSuccessDoneFlag = false;@api form60DocId = null;@api aadharDocId = null;@api voterIdDocId = null;@api panDocId = null; @api drivingLicenseDocId = null; @api passportDocId = null;
    documentRecordIdFromScanComp;
    @track aadharButton = false;@track passportButton = false; @track voterIdButton = false;@track drivingLicenseButton = false; @api currentDocId;@api currentFieldStirng;
    @wire(getRecord, { recordId: userId, fields: [UserNameFld, userEmailFld] })
    userDetails({ error, data }) {if (data) {this.currentUserName = data.fields.Name.value;this.currentUserEmailId = data.fields.Email.value;} else if (error) { this.error = error; }}
    aadhaarLogoURL = AADHAAR_LOGO;passportLogoURL = PASSPORT_LOGO;voteridLogoURL = VOTERID_LOGO;dlLogoURL = DL_LOGO;panCardLogoURL = PAN_LOGO;gstLogoUrl = GST_LOGO;cinLogoUrl = CIN_LOGO; accountId;applicantId = '';counter_current_kyc = 0;@track readonly = false;counter_permanent_kyc = 0;counter_pan_kyc = 0;@api currentStage;@track isEnableNextval;@api isCoborrowerExist;@api recordid;@api isborrowerincomeavailable;@api currentOppRecordId;@track loanApplicationComponent = false;@api currenttab;@api currentApplicationId;@api tabCount;@track recordFields;@track agentBLCodeLabel;@track isLoading;@api documentRecordId=null;@track currentOppRecord;@track leadNumber;@track documentToDelete;@track isStepOne = false;@track isStepTwo = false;@track isStepThree = false;@track isStepFour = false;@track isStepFive = false;@track isStepSix = false;@track isStepSeven = false;@track isStepEight = false;@track isStepNine = false;@track currentApplicantDetails;@track disableIncomeSourceAvailable = false;lastNameValue = '';firstNameValue = '';phoneNoValue = '';whatsAppNumberValue = '';agentBLCodeValue;@track productType; numberOfProducts; @track entityType; declaredIncome = '';loanAmount = '';vehicleType = '';vehicleSubCategoryType = '';parentDealNumber = '';registerationNumberFormatValue = '';customerCodeValue = '';vehicleRegistrationNumberValue = '';nocNumberValue = '';kycType = "";section1 = false;section2 = false;whatsAppSection = false;phoneSection = false;section4 = false;verifyChecked = false;vehicleVerified = false;verifyButton = false;vehicleType;isPresentAddressFlag = false;@track addressProofUploadScreenFlag = false;isWhatsAppNumberAccessible = false;disableSamePhoneCheckBox = true;showCopiedWhatsAppNumber = false;modalPopUpCaptureImage = false;disableRegisterOnlineWhatsApp = true;registerWhatsAppValue = false;checked = false;isDisabledDeclaredIncome = true;doYouHaveBankAccount = false;doYouHaveBankAccountWithIBL = false;openNewBankAccount = false;isCoBorrowerReq = false;isDisabledLoanAmount = false;showLoanAmount = true;disabledOpenBankAcc = true;disabledBankAccWithIBL = false;parentloanStagename;
    @track createApplicationDisable = false;
    disabledBankAcc = false;//Ola Integration changes
    @track isTopUpShow = false;@track isTopUpChecked = false;@track isDisabledTopUp = false;
    disableCurrentAddress = false;disablePermanentAddress = false; disableCurrentPermntSameAddr = true;typeFromScan;
    captureImageWeb = true;captureImageApi = false;@track imageAttempt=0;@track currentStageName;@track lastStage;@track showJourneyRestartMsg = false;@track isBorrowerEarning = false;@track kycDocumentName;lstProductType = [];map1 = new Map(); agenBlCodeMap=new Map();countfortoggle = 0;pidver__c;fType;env__c;fCount__c;format__c;str_wadh__c;timeout__c;wadhType__c;isTwoWheeler=false;isTractor = false;leadSource;isNewCustomer=false;aadhaarSourceOTPBio = false;boolprevRec=true;//DSAMODIFYEXISTING
    @api label = {Tractor,NumberOfProducts,EntityType,ApplicationType,journeyNotProceedGuarantor,LeadDetails,AgentBranchName,ProductType,LeadNumber,CustomerFirstName,CustomerLastName,CustomerPhoneNumber,WhatsAppNumber,otpSend,validationMsgNoalreadyReg,enterLoanAmount,bankAccountMandotory,openNewBankAccountMsg,incomeAmountMandatory,completeField,FailResponseApi,allSectionsClosed,accountcheckdetailsMsg,ProvideKYContinue,kycDetailsUploaded,captureImageRequired,noRegisteredWhatsAppBanking,exhaustedAttempts,consentInitialisationRequired,CoborrowerRequireAccountOpenNewaccount,coborrowesNeedsTohaveBankAccount,otpSentSuccessfully,sorryCannotPreviewForm60Document,bankDetailsSavedSuccessfully,
        // coBorrowerAddMandatory,//CISP-2500
        coborrowerRequireAccount,journeyNotProceed,enterIncomeLoanAmount,loanDetailsSavedSuccessfully,coBorrowerAdditionMandatory,eitherBorrowerCoborrowerIncomeSourceAvail,verifyVehicleDedupeBeforeNextScreen,verifyVehicleDedupe,vehicleDedupeDetailsSaved,selectVehicleNumber,selectVehicleType,updatePanForm60document,updateAtleast2documents,uploadatleastOneDocument,imageuploaded,detailsSaved,provideConsentUploadImage,restartJourneyHome,captureCurrentResidentialAddress,capturePermanentResidentialAddress,DeclaredIncomeRequiredLoanAmount,vehicleDedupes,userDetails,captureDedupe,bankAccountCheck,capturePANOrOtherKyc,gattingAndScreening,lastNameError,RegEx_Alphabets_Only,RegEx_Last_Name,RegEx_Number,Mobile_Number_Error_Msg,Vehicle_New,Vehicle_Old,Borrower,CoBorrower,Aadhaar,Pan,DrivingLicence,VoterID,Passport,CurrentAddressOptionsMsg,permanentAddressOptionsMsg,
        Permnt_Same_as_Current,PanCards,AadhaarCard,DrivingLicences,CustomerImageDocumentType,PassportCard,VoterIdCard,Form60DocumentType,currentUserId,currentUserName,currentUserEmailid,currentApplicantid,mode,ExceptionMessage,RetrySelfe,Guarantor,GST_CERT,CIN_CERT,EntityName,EntityTypeNonInd,EntityCode,EntityCategory,ContactPersonName,LeadSource,ClassofActivity,LoanTypeNonInd,EvaluationType,MajorIndustry,MinorIndustry,Profile,Retry_Exhausted, SuccessMessage //SFTRAC-536 
    };
    beneficialOwnerCategory;relationshipWithEntity;relationshipType;relationshipWithEntityOptions;relationshipTypeOptions;poaHolder;shareHolderPercent;totalSHPercent;beneficialOwnerCategoryOptions;relationshipTypeOption;inActiveBLCodes;
    get profileDisabled() {
        return (this.profileOptions && this.profileOptions.length == 0) || this.readonly;
    }
    get customerFullName(){return this.firstNameValue + ' ' + this.lastNameValue}//CISP-2967
    @wire(MessageContext)
    context
    get isDisableAGBLCode(){return this.disableAGBLCode || this.leadSource == 'D2C';}
    /*SFTRAC-33*/
    @wire(getObjectInfo, { objectApiName: LOAN_OBJECT }) loanInfo;

    get disableEntityTypeVal() {return this.currenttab !== 'Borrower' || this.disableEntityType ;}
    get disableApplicationTypeVal() {return  this.currenttab !== 'Borrower' || this.disableApplicationType;}
    get getDisabledTopUp() {return  this.currenttab !== 'Borrower' || this.isDisabledTopUp;}
    @track loan;
    get entityCategoryOptions() {
        return [
            {label : 'SEP' , value : 'SEP'},
            {label : 'SENP' , value : 'SENP'}
        ];
    }

    @wire(getPicklistValues, { recordTypeId: '$loanInfo.data.defaultRecordTypeId', fieldApiName: PROFILE_FIELD })
    profileOption({data, error}){
        if(data){
            this.profileOptions = data?.values;
        }
        else if (error) {}
    }
    @wire(getPicklistValues, { recordTypeId: '$loanInfo.data.defaultRecordTypeId', fieldApiName: ENTITY_TYPE_FIELD }) entityTypeOptions;
    @wire(getPicklistValues, { recordTypeId: '$loanInfo.data.defaultRecordTypeId', fieldApiName: LEAD_SOURCE_FIELD }) leadSourceOptions;
    @wire(getPicklistValues, { recordTypeId: '$loanInfo.data.defaultRecordTypeId', fieldApiName: CLASS_OF_ACTIVITY_FIELD }) classOfActivityOptions;
    @wire(getPicklistValues, { recordTypeId: '$loanInfo.data.defaultRecordTypeId', fieldApiName: LOAN_TYPE_FIELD }) loanTypeOptions;
    @wire(getPicklistValues, { recordTypeId: '$loanInfo.data.defaultRecordTypeId', fieldApiName: EVALUATION_TYPE_FIELD }) evalutionTypeOptions;
    @wire(getPicklistValues, { recordTypeId: '$loanInfo.data.defaultRecordTypeId', fieldApiName: MAJORINDUSTRY_TYPE_FIELD }) majorIndustryOptions;
    /*SFTRAC-33*/
    @wire(getRecord, { recordId: '$applicantId', fields: [LITERACY_FIELD] })
    applicantRecord({data, error}){
        if(data){
            console.log('data');
            console.log(data.fields.Literacy__c.value);
            this.selectedLiteracyFieldOptionValue = data.fields.Literacy__c.value;
        }
        else if (error) {
            console.log(error);
        }
    }
    get isNonIndividualBorrower() {return this.currenttab === 'Borrower' && this.entityType == 'Non-Individual'}
    get isNonIndividualBeneficiary() {return this.currenttab === 'Beneficiary' && this.entityType == 'Non-Individual'}
    get isIndividual() {return this.entityType == 'Individual'}
    get getEntityType(){return (this.currenttab !== 'Borrower' && this.entityType == 'Non-Individual') ? 'Individual' : this.entityType}
    get customerImageDisableVal() {return this.isNonIndividualBorrower ? true : this.customerImageDisable;}//SFTRAC-536
    get imageUploadDisableVal() {return this.isNonIndividualBorrower ? true : this.imageUploadDisable;}//SFTRAC-536
    get isWhatsAppNumberRequired() {return !this.isNonIndividualBorrower;}//SFTRAC-536
    get showCIN() { return ['11', '12'].includes(this.loan.Entity_Code__c); }
    get aepsOptions() {return [{label: 'No, I do not want to enable AePS (Cash Withdrawal/Purchase/Funds-transfer) *$ Debit Transaction services for my Savings/Current Account with the Bank',value: 'No'
}, {label: 'Yes, I hereby confirm that I want to avail AePS (Cash Withdrawal/Purchase/Funds-transfer) Debit Transaction Services for my Savings/Current Account with the Bank.',value: 'Yes'}];}
async handleAepsChange(event) {helper.handleAepsChange(this, event);}
    async connectedCallback() {
        this.isLoading = true; 
        await getCurrentOppRecord({ loanApplicationId: this.recordid })
            .then(response => {
                let result = JSON.parse(response);
                this.isTopUpChecked = result.oppRecord?.isTopUpLoan__c;//SFTRAC-172
                if(result?.oppRecord?.Is_Revoked__c){this.isRevoked = true;}//CISP-2413
                this.loan = result.oppRecord;
                this.leadSource = result.oppRecord.LeadSource == null ? '' : result.oppRecord.LeadSource; // MSIL Api changes (CISP-136 -- Added null check - 07-10-2022)
                this.currentOppRecordId = result.oppRecord.Id;this.currentOppOwnerId = result.oppRecord.OwnerId;this.currentOppRecord = result.oppRecord;this.leadNumber = result.oppRecord.Lead_number__c;this.agentBLCodeValue = result.oppRecord.AccountId;this.disableAGBLCode = result.oppRecord.AccountId ? true : false;this.productType = result.oppRecord.Product_Type__c=='Two Wheeler' ? 'TW' : result.oppRecord.Product_Type__c=='Passenger Vehicles' ? 'PV' : result.oppRecord.Product_Type__c=='Tractor' ? 'Tractor' : '';this.isTwoWheeler = result.oppRecord.Product_Type__c=='Two Wheeler' ? true : false; this.isTractor = result.oppRecord.Product_Type__c=='Tractor' ? true : false; this.entityType = result.oppRecord.Customer_Type__c; this.numberOfProducts = result.oppRecord.Number_of_Products__c; this.applicationTypeVal = result.oppRecord.Application_Type__c ? result.oppRecord.Application_Type__c : this.applicationTypeVal ;
                this.vehicleTypeval = result.oppRecord.Vehicle_Type__c;//CISP-3293
                this.isTopUpShow = this.vehicleTypeval == 'Used' && this.isTractor ? true : false;//SFTRAC-172
                this.parentloanStagename = result.oppRecord?.Parent_Loan_Application__r?.StageName ? result.oppRecord?.Parent_Loan_Application__r?.StageName : '';//CISP-12675 
                this.disableVehicle =result.oppRecord.Vehicle_Type__c ? true : false;//CISP-3293
                var blValues = {agentBL:this.agentBLCodeValue, proType:this.productType};//CISP-3009
                const evnt = new CustomEvent('checkagentbranchcode', { detail: blValues}); this.dispatchEvent(evnt);//CISP-3009
                this.vehicleVerified = result.oppRecord.Vehicle_Verified__c;this.vehicleType = result.oppRecord.Vehicle_Type__c;this.loanAmount = result.oppRecord.Loan_amount__c;this.verifyChecked=result.oppRecord.Vehicle_Verified__c;this.currentStageName = result.oppRecord.StageName;this.lastStage = result.oppRecord.LastStageName__c;
                //DSAMODIFYEXISTING - START	
                if(this.leadSource === 'DSA' && this.parentloanStagename == 'Journey Restart'){if (this.currenttab === 'Borrower') {this.disableFirsttName = false;this.disableLastName = false;this.disablePhoneNumber = false;this.disableSamePhoneCheckBox = false;this.isWhatsAppNumberAccessible = false;}}else if(this.leadSource === 'DSA'){//CISP-12675
                    if (this.currenttab === 'Borrower') {
                        this.disableFirsttName = true; this.disableLastName = true; this.disablePhoneNumber = true; this.disableSamePhoneCheckBox = true; this.isWhatsAppNumberAccessible = true;}this.isDisabledDeclaredIncome = false; }
                //DSAMODIFYEXISTING - END
                if(this.currentStageName === 'Journey Restart') {this.showJourneyRestartMsg=true;
                } else {this.showJourneyRestartMsg = false;
                if (result.applicantsList !== undefined && result.applicantsList !== null && result.applicantsList.length > 0) {
                    if(this.currentTabId === "NIL" || this.currentTabId === "G-NIL" || this.currentTabId === "B-NIL" || this.currentTabId === undefined || this.currentTabId===""){
                        this.currentStep = this.label.userDetails;
                    } else {
                        const filteredList = result.applicantsList.filter(item => item.applicantId === this.currentTabId);
                        const currentApplicant = filteredList[0];
                        this.applicantId = currentApplicant.applicantId;
                        if (currentApplicant.createApplicationCountExhausted) { //SFTRAC-536
                            this.createApplicationCross = true;
                            this.createApplicationDisable = true;
                        }
                        if(currentApplicant.isCreateApplication){
                            this.iconButtonCreateApplication = true;
                            this.createApplicationDisable = true;
                        }
                        deleteEmptyKycDoc({ applicantId: currentApplicant.applicantId })
                        .then(response => {console.log('deleteEmptyKycDoc response',response)})
                        .catch(error=> {console.log('deleteEmptyKycDoc error',error)});
                        this.aepsValue=currentApplicant.aepsValue;
                        this.firstNameValue = currentApplicant.customerFirstName;this.lastNameValue = currentApplicant.customerLastName;this.phoneNoValue = currentApplicant.customerContactNumber;this.whatsAppNumberValue = currentApplicant.customerWhatsappNumber;this.registerWhatsAppValue = currentApplicant.registeredWhatsappBanking;this.currentJourneyStage = currentApplicant.currentJourneyStage; this.currentStep = currentApplicant.currentJourneyStage;this.checked = currentApplicant.isIncomeSourceAvailable;this.declaredIncome = currentApplicant.declaredIncomeSource;this.doYouHaveBankAccount = currentApplicant.haveBankAccount;this.doYouHaveBankAccountWithIBL = currentApplicant.isBankAccountWithIBL;this.openNewBankAccount = currentApplicant.wantToOpenBankAccount;this.currentPermanentcheckBoxValue = currentApplicant.isCurrentPermanentSameAddr;this.checkBoxValue = currentApplicant.isCurrentAddressNotPresent;this.checkBoxValuePermanent = currentApplicant.isPermanentAddressNotPresent;this.imageAttempt = currentApplicant.customerImageAttempt;this.isBorrowerEarning = result.isBorrowerEarning;
                        if(this.isTractor && this.leadSource === 'TAFE'){helper.disableFieldTAFE(this);}//SFTRAC-1849
                        if(this.isTractor && this.entityType == 'Non-Individual'){ //SFTRAC-78
                            this.beneficialOwnerCategory = currentApplicant.beneficialOwnerCategory;this.relationshipWithEntity = currentApplicant.relationshipWithEntity;this.relationshipType = currentApplicant.relationshipType;this.poaHolder = currentApplicant.poaHolder;this.shareHolderPercent = currentApplicant.shareholderPercent;}
                        if(currentApplicant.FrontUploadComplete){this.disableImage();}
                        if(currentApplicant.consentInitiated){
                            if(this.leadSource !== 'DSA')this.disableAll();
                        } else {
                            if (this.whatsAppNumberValue != '' && this.whatsAppNumberValue != null ) {
                                this.disableRegisterOnlineWhatsApp = false;
                                }
                            if(this.phoneNoValue != '' && this.phoneNoValue != null){
                                this.disableSamePhoneCheckBox=false;
                            }
                        }
                        if (this.currentPermanentcheckBoxValue && this.currentStep === this.label.capturePermanentResidentialAddress ) {this.currentStep = this.label.capturePANOrOtherKyc;this.isStepTwo = false;this.isStepFour = true;}
                        if (currentApplicant.isConsentRecieved) {this.consentDisable = true;this.iconButton = true;this.changecolor();
                            if(this.leadSource === 'DSA' && this.currentStep == 'User Details'){this.disableAGBLCode = false;this.disableVehicle = false;//CISP-3293//CISP-18963
                                }
                        }
                        if (currentApplicant.isCustomerImagePresent) {this.iconButtonCaptureImage = true;this.iconButtonCaptureUpload = true;this.documentRecordId = currentApplicant.customerImageDocId;this.customerImageDisable=true;
                            fetchCdocumentId({ documentId: this.documentRecordId })
                            .then(result => { const obj = JSON.parse(result);this.documentToDelete = obj.backContentDocumentId;}
                            ) .catch(error => {})
                         }
                        //if (currentApplicant.isImageUpload) {this.iconButtonCaptureUpload = true; this.imageUploadRedCross = false;}
                        if (currentApplicant.applicantType === this.label.CoBorrower || (currentApplicant.applicantType !== this.label.Borrower && this.isTractor)) {this.showLoanAmount = false;}
                        if (currentApplicant.isAadhaarPresent) {this.aadharButton = true;this.aadharDocId = currentApplicant.aadharDocId;this.counter_pan_kyc++;
                            if (currentApplicant.isAadhaarCurrent) {this.disableAadharButton01 = false;this.disablePassportButton01 = true;this.disableVoterIdButton01 = true;this.disableDLButton01 = true;this.counter_current_kyc = 1;this.checkBoxValue = false;this.disableCurrentAddress = true;this.disableCurrentPermntSameAddr = false;
                            } else if (currentApplicant.isAadhaarPermanent) {this.disableAadharButton02 = false;this.disablePassportButton02 = true;this.disableVoterIdButton02 = true;this.disableDLButton02 = true;this.counter_permanent_kyc = 1;this.checkBoxValuePermanent = false;this.disablePermanentAddress = true;}}
                        if (currentApplicant.isPanPresent) {this.panButton = true;this.panDocId = currentApplicant.panDocId;this.typeFromScan = currentApplicant.PANType;this.counter_pan_kyc++;}
                        if (currentApplicant.isGstPresent) {
                            this.gstButton = true;this.gstDocId = currentApplicant.gstDocId; this.counter_pan_kyc++;
                        }
                        if (currentApplicant.isCinPresent) {
                            this.cinButton = true;this.cinDocId = currentApplicant.cinDocId;this.counter_pan_kyc++;
                        }
                        if (currentApplicant.isForm60Present) {this.panButton = true;this.form60DocId = currentApplicant.form60DocId;this.typeFromScan = currentApplicant.Form60Type;this.counter_pan_kyc++;}
                        if (currentApplicant.isPassportPresent) {
                            this.passportButton = true; this.passportDocId = currentApplicant.passportDocId;this.counter_pan_kyc++;
                            if (currentApplicant.isPassportCurrent){this.disableAadharButton01=true;this.disablePassportButton01=false;this.disableVoterIdButton01=true;this.disableDLButton01=true;this.counter_current_kyc=1;this.checkBoxValue=false;this.disableCurrentAddress=true;this.disableCurrentPermntSameAddr=false;
                              } else if (currentApplicant.isPassportPermanent){this.disableAadharButton02=true;this.disablePassportButton02=false;this.disableVoterIdButton02=true;this.disableDLButton02=true;this.counter_permanent_kyc=1;this.checkBoxValuePermanent=false;this.disablePermanentAddress=true;}
                        }
                        if (currentApplicant.isVoterIdPresent) {
                            this.voterIdButton = true; this.voterIdDocId = currentApplicant.voterIdDocId;this.counter_pan_kyc++;
                            if (currentApplicant.isVoterIdCurrent) {this.disableAadharButton01 = true; this.disablePassportButton01 = true;this.disableVoterIdButton01 = false;this.disableDLButton01 = true; this.counter_current_kyc = 1;this.checkBoxValue = false;this.disableCurrentAddress = true;this.disableCurrentPermntSameAddr = false;
                              } else if (currentApplicant.isVoterIdPermanent) { this.disableAadharButton02 = true;this.disablePassportButton02 = true;this.disableVoterIdButton02 = false;this.disableDLButton02 = true; this.counter_permanent_kyc = 1; this.checkBoxValuePermanent = false; this.disablePermanentAddress = true;
                             }
                        }
                        if (currentApplicant.isDLPresent) {
                            this.drivingLicenseButton = true;this.drivingLicenseDocId = currentApplicant.dlDocId;this.counter_pan_kyc++;
                            if (currentApplicant.isDLCurrent) {this.disableAadharButton01 = true;this.disablePassportButton01 = true;this.disableVoterIdButton01 = true;this.disableDLButton01 = false;this.counter_current_kyc = 1;this.checkBoxValue = false;this.disableCurrentAddress = true;this.disableCurrentPermntSameAddr = false;
                            } else if (currentApplicant.isDLPermanent) {this.disableAadharButton02 = true;this.disablePassportButton02 = true;this.disableVoterIdButton02 = true;this.disableDLButton02 = false;this.counter_permanent_kyc = 1;this.checkBoxValuePermanent = false;this.disablePermanentAddress = true;}
                        }
                        if (currentApplicant.isCurrentAddressNotPresent ) {this.disableAadharButton01 = true;this.disablePassportButton01 = true;this.disableVoterIdButton01 = true;this.disableDLButton01 = true;}
                        if (currentApplicant.isPermanentAddressNotPresent) { this.disableAadharButton02 = true; this.disablePassportButton02 = true;  this.disableVoterIdButton02 = true; this.disableDLButton02 = true; this.disableCurrentPermntSameAddr = true;
                        } 
                        if(currentApplicant.SelfieRetryAttempts>=3){  this.imageUploadRedCross = true; this.iconButtonCaptureUpload=false;this.imageUploadDisable=true; this.customerImageDisable=true;
                        }
                        if (this.checkBoxValue && this.checkBoxValuePermanent && !this.aadharButton && !this.passportButton && !this.voterIdButton && !this.drivingLicenseButton) {this.handleNo();}
                    }if(this.currentApplicantStage && this.currentStep != this.currentApplicantStage){this.currentStep = this.currentApplicantStage}
                } else {this.currentStep = this.label.userDetails;}
                if (this.currentStep === this.label.userDetails) {this.isStepOne = true;}
                 else if (this.currentStep === this.label.captureCurrentResidentialAddress) {this.isStepTwo = true;
                } else if (this.currentStep == this.label.capturePermanentResidentialAddress) {if(this.checkBoxValue){this.isStepThreeV2 = true;}else{this.isStepThree = true;}}
                 else if (this.currentStep === this.label.capturePANOrOtherKyc) {this.isStepFour = true;}
                  else if (this.currentStep === this.label.captureDedupe){this.isStepFive = true;}
                   else if (this.currentStep === this.label.vehicleDedupes) {this.isStepSix = true;}
                    else if (this.currentStep === this.label.DeclaredIncomeRequiredLoanAmount) {
                    this.isStepSeven = true;
                } else if (this.currentStep === this.label.bankAccountCheck) {
                    this.isStepEight = true; this.disableIncomeSourceAvailable=true; this.isDisabledDeclaredIncome=true; this.isDisabledLoanAmount=true;
                } else if (this.currentStep === this.label.gattingAndScreening) {
                    this.isStepNine = true;
                }
            }this.isLoading = false;
            }).catch(error => { this.isLoading = false; });
            //Ola integration changes start
            await getLoanApplicationReadOnlySettings({leadSource:this.leadSource})
            .then(data => {let fieldList = [];if(data){fieldList=data.Input_Labels__c.split(';');}               
                if(fieldList.length>0){this.disableFirsttName = fieldList.includes('Customer First Name')? true :this.disableFirsttName;this.disableLastName = fieldList.includes('Customer Last Name')? true :this.disableLastName;this.disablePhoneNumber = fieldList.includes('Customer Phone Number')? true :this.disablePhoneNumber;this.disableAGBLCode = fieldList.includes('Agent Branch Name')? true :this.disableAGBLCode;this.checked = true;this.disableIncomeSourceAvailable = fieldList.includes('Income Source Available')? true :this.disableIncomeSourceAvailable;this.isDisabledLoanAmount = fieldList.includes('Loan Amount')? true :this.isDisabledLoanAmount;this.disabledBankAcc = fieldList.includes('Do you have a bank account')? true :this.disabledBankAcc;this.disabledBankAccWithIBL = fieldList.includes('Do you have bank account with IBL')? true :this.disabledBankAccWithIBL;this.disabledOpenBankAcc = fieldList.includes('Would you like to open a bank account with IBL')? true :this.disabledOpenBankAcc;let toggle2Input = this.template.querySelector('lightning-input[data-id=toggle2]');toggle2Input.unchecked = false;toggle2Input.checked = true;this.isDisabledDeclaredIncome = false;}}).catch(error => { this.isLoading = false; });//Ola Integration changes ends
                
        this.handleLoad();if(this.isTractor){helper.handleBeneOptions(this);}if(this.isTractor && this.entityType == 'Non-Individual'){helper.handleBeneShareholderPercent(this);} this.callAccessLoanApplication();//CISP:2692
         if(((this.productType == 'Passenger Vehicles') || (this.productType == 'PV')) && (this.whatsAppNumberValue == null || this.whatsAppNumberValue == '')){this.template.querySelector('[data-id="registerWhatsAppId"]').checked = true;this.registerWhatsAppValue = true;};//CISP-15132
        if(this.leadSource === 'Hero'){this.isDisabledDeclaredIncome = false;this.disabledBankAcc = false;};//Hero CISH-5 
    }callCustomerDedupeData(){//CISP-5266
    getCustomerDedupeData({loanId: this.recordid, ApplicantId: this.applicantId}).then(res=>{this.isNewCustomer=res.IND_isNewCustomer__c;if(this.aadhaarSourceOTPBio == true){this.disabledOpenBankAcc = !this.isNewCustomer;}else{this.disabledOpenBankAcc = true;}})}
    callAadharDetails(){getAadharDetails({loanId: this.recordid,ApplicantId: this.applicantId}).then(res => {this.aadhaarSourceOTPBio = res;if(this.aadhaarSourceOTPBio == true){this.disabledOpenBankAcc = !this.isNewCustomer;}else{this.disabledOpenBankAcc = true;}})}//CISP-20674
    get acceptedFormats() {return ['.jpg', '.jpeg'];} //CISP-2764
    get isBorrowerTab() {return this.currenttab === this.label.Borrower;}
    isCancel = true;
    isDone = true;
    handleUploadFinished(event) {this.documentToDelete = event.detail.files[0].documentId;this.isCancel = false;this.isDone = false;this.successToast('Uploaded',this.label.imageuploaded,'success');this.doneflagCustomerImage = true;updateCustomerImageFileTitle({'documentId' : this.documentRecordId, 'contentDocumentData':this.documentToDelete});}
    updateSelfieUpload(selfieUploadValue){const oppFields = {};oppFields[OPP_ID_FIELD.fieldApiName] = this.applicantId;oppFields[Selfie_Upload__c.fieldApiName] = selfieUploadValue;this.updateRecordDetails(oppFields);}
    handleOnStepClick(event) {this.currentStep = event.target.value;}
    handleOnfinish(event) { helper.onfinishHandler(this); }
    get isEnableNext() {return this.currentStep !== this.label.gattingAndScreening;}
    get isEnablePrev() {return this.currentStep !== this.label.userDetails;}
    get disableNextBtn() {return this.currentStageName !== 'Loan Initiation';}
    handleYes() {
        this.template.querySelector('lightning-input[data-id=permanentAddress]').checked = false;
        this.selectedValueCurrentAdd = false;
        this.checkBoxValuePermanent = false;
        this.successToast(this.label.ProvideKYContinue,null,'error');
        this.journeyPopUP = false;
        this.disableAadharButton02 = false;
        this.disablePassportButton02 = false;
        this.disableVoterIdButton02 = false;
        this.disableDLButton02 = false;}
    disableNext = false;
    disablePrev = false;
    //CISP-4459 start
    journeyStopScenarioFound(){updateJourneyStop({ leadNo: this.recordid }).then(result => {}).catch(error => {});}//CISP-4459
    handleNo() {this.successToast('Journey Stoped!',this.label.restartJourneyHome,'error');this.disableNext = true;this.disablePrev = true;this.journeyPopUP = false;this.disableVoterIdButton02 = true;this.disableDLButton02 = true;this.disablePassportButton02 = true;this.disableAadharButton02 = true;this.disablePermanentAddress=true; this.journeyStopScenarioFound()}//CISP-4459
    async callCibilTextMatchAPI(){
        await cibilTextMatch({applicantId:this.applicantId}).then(result =>{
            const res=JSON.parse(result);
            let applicantFirstName;
            let applicantLastName;
            for( let i=0;i<res.docList.length;i++){
                if( !res.docList[i].Proof_of_Identity_POI__c && res.destName!=='') {
                    applicantFirstName = res.docList[i].First_Name__c;
                    applicantLastName = res.docList[i].Last_Name__c
                    const textMatch = {
                        'loanApplicationId':this.recordid,
                        'leadId':res.leadId,
                        'applicantFirstName':applicantFirstName,
                        'applicantMiddleName': '',
                        'applicantLastName':applicantLastName,
                        'destinationNames':res.destName }
                    doTextMatchCallout({textMatch : JSON.stringify(textMatch)}).then(result=>{
                        const parseResp=JSON.parse(result);
                        const matchScore =  parseResp.ResponseData.Fields.Applicants.Applicant.Services.Service[0].Operations.Operation[0].Data.Response.RawResponse.MatchService.Source[0].NameMatch;
                        cibilTextMatchSaveResponse({documentId:res.docList[i].Id,matchScore:matchScore});
                    })} }
        })
    }
    journeyPopUP = false;isStepThreeV2=false;
    async handleNext() {
        helper.handleNext(this);
    }
    shareHolderHandler(){
        helper.shareHolderHelper(this);
    }
    dedupnextstepaction() {
        if (this.currenttab == this.label.Borrower) {
            this.currentStep = this.label.vehicleDedupes;
        } else if (this.currenttab == this.label.CoBorrower || (this.currenttab !== this.label.Borrower && this.isTractor)) {
            this.showLoanAmount = false;
            this.currentStep = this.label.DeclaredIncomeRequiredLoanAmount;
        }
    }
    callAccessLoanApplication(){  //CISP: 2692
        accessLoanApplication({ loanId: this.recordid , stage: 'Loan Initiation'}).then(response => {
            if(!response){ this.disableEverything();
            if(this.checkleadaccess){//if lead is accessible but user from different profile is viewing that                  
                    const evt = new ShowToastEvent({
                        title: ReadOnlyLeadAccess,
                        variant: 'warning',
                        mode: 'sticky' });
                    this.dispatchEvent(evt);
                    this.disableEverything();}}}).catch(error => {    });
    }
    async nextBtnActionFromDedupScreen(event) {
        //Validate if Next or Previous Allowed using Event Flag
        if (event.detail.journeystop) {
            this.disableNext = true;
            this.disablePrev = true;
            return;
        }
        if (event.detail.autonext === false) { return;}
        const applicantsFields = {};
        if (!this.currenttab || this.currenttab == this.label.Borrower) {
            applicantsFields[APP_ID_FIELD.fieldApiName] = this.applicantId;
            applicantsFields[APPLICANT_SUBSTAGE.fieldApiName] = this.label.vehicleDedupes;
            await this.updateRecordDetails(applicantsFields);
            this.currentStep = this.label.vehicleDedupes;
            this.isStepFive = false;
            this.isStepSix = true;
        } else if (this.currenttab == this.label.CoBorrower || (this.currenttab !== this.label.Borrower && this.isTractor)) {
            applicantsFields[APP_ID_FIELD.fieldApiName] = this.applicantId;
            applicantsFields[APPLICANT_SUBSTAGE.fieldApiName] = this.label.DeclaredIncomeRequiredLoanAmount;
            await this.updateRecordDetails(applicantsFields);
            this.showLoanAmount = false;this.currentStep = this.label.DeclaredIncomeRequiredLoanAmount;this.isStepFive = false;this.isStepSeven = true;
        }
        createPersonAccWithCustCodeAssignment({applicantId: this.applicantId}).then(response => {
            if(response.status === 'error'){
                this.successToast(response.message,'','error');
            }
        }).catch(error => { });
    }
    async updateRecordDetails(fields) {
        //CISP-2378//CISP-2465
        if((this.tabcounter < 0 || this.currentApplicantStage) && fields[APPLICANT_SUBSTAGE.fieldApiName]){
            delete fields[APPLICANT_SUBSTAGE.fieldApiName];
        }
        //CISP-2378//CISP-2465
        const recordInput = { fields };
        await updateRecord(recordInput)
        .then((result) => {}).catch(error => {this.successToast('Error',error?.body?.error,'error');throw 'Something went wrong!'});
    }//CISP-2457 /CISP-2506
    @track _clearretrycount;
    @api set clearretrycount(value){this._clearretrycount = value;if(this._clearretrycount && !this.isNonIndividualBorrower){this.isEnableNextval=false;}} get clearretrycount(){return this._clearretrycount}
    async upsertRecordDetails(objectApiName, fields) {
        let objId;
        await upsertRecords({ apiName: objectApiName, fields: JSON.stringify(fields),loanApplicationId:this.recordid })
            .then(obj => {objId = obj; if(this.currenttab == this.label.CoBorrower){this.dispatchEvent(new CustomEvent('increaseretrycount'));}})//CISP-2457 /CISP-2506
            .catch(error => {});
        return objId;
    }
    handlePrev() {
        if(this.tabcounter <= 0){this.tabcounter--;}//CISP-2378//CISP-2465
        if (this.currentStep === this.label.captureCurrentResidentialAddress) {this.currentStep = this.label.userDetails;this.isStepOne = true;this.isStepTwo = false;this.customerImageDisable=true;this.imageUploadDisable=true;
        }else if (this.currentStep == this.label.capturePermanentResidentialAddress) {this.currentStep = this.label.captureCurrentResidentialAddress;if(this.checkBoxValue){this.isStepThreeV2=false;}else{this.isStepThree = false;}this.isStepTwo = true;
        }else if (this.currentStep === this.label.capturePANOrOtherKyc) {
            if(this.isTractor && this.isNonIndividualBorrower){ 
                console.log('prev----'); this.currentStep = this.label.userDetails;
                this.isStepFour = false;
                this.isStepTwo = false;
                this.isStepOne=true;}
                else{
                    this.currentStep = this.label.capturePermanentResidentialAddress;this.isStepFour = false;
                    if(this.checkBoxValue ){
                        this.isStepThreeV2=true;}
                        else{
                            this.isStepThree = true;}
                if (this.currentPermanentcheckBoxValue) 
                this.currentStep = this.label.captureCurrentResidentialAddress;
                    if(this.checkBoxValue ){
                        this.isStepThreeV2=false;}
                        else{
                            this.isStepThree = false;}
                            this.isStepTwo = true;}
        } else if (this.currentStep === this.label.captureDedupe) {this.currentStep = this.label.capturePANOrOtherKyc;this.isStepFive = false;this.isStepFour = true;
        }else if (this.currentStep === this.label.vehicleDedupes) {this.currentStep = this.label.captureDedupe;this.isStepSix = false;this.isStepFive = true;
        }else if (this.currentStep === this.label.DeclaredIncomeRequiredLoanAmount) {
            if (!this.currenttab || this.currenttab == this.label.Borrower) {this.currentStep = this.label.vehicleDedupes;this.isStepSix = true;this.isStepSeven = false;
            } else if (this.currenttab !== this.label.Borrower) {this.currentStep = this.label.captureDedupe;this.isStepFive = true;this.isStepSeven = false;}
        }else if (this.currentStep === this.label.bankAccountCheck) {
            if (this.currenttab === this.label.CoBorrower || (this.currenttab !== this.label.Borrower && this.isTractor)) {this.showLoanAmount = false;}this.currentStep = this.label.DeclaredIncomeRequiredLoanAmount;this.isStepSeven = true;this.isStepEight = false;
        }else if (this.currentStep === this.label.gattingAndScreening) {
            if (this.currenttab === this.label.CoBorrower || (this.currenttab !== this.label.Borrower && this.isTractor)) {this.showLoanAmount = false;}this.currentStep = this.label.bankAccountCheck;this.isStepEight = true;this.isStepNine = false;this.disableAeps=true;if(this.productType == 'Tractor'){this.disabledLiteracyField = true;}}}
    @track agentBLCodeOptions;
    @track disableAGBLCode = false;
    @track disableVehicle = false;//CISP-3293
    @track objUser = {};
     handleLoad() { 
         getAccountTeamMembers({uid : userId}).then(result => {
                let lstOption = [];
                for(let i=0 ; i<result.length; i++){
                  var rec =  result[i].Account;
                  lstOption.push({value: rec.Id,label: rec.Name });
                  this.map1.set(rec.Id,rec.Type);this.agenBlCodeMap.set(rec.Id,rec.BranchBLCode__c);
                }
                   this.agentBLCodeOptions = lstOption; this.agentBLCodeOptionsvalues = lstOption;//CISP-3293
            }).catch(error => {this.error = error;});
       }
    iconButtonCaptureImage = false;
    captureImageDone() {
        this.updateSelfieUpload(false);
        this.updatedocApplication(null);
        this.docAuthApiPositiveResponse=false;this.isimageApiPositiveResponse=false;
        if(FORM_FACTOR == 'Large'){ 
        this.deleteImage(this.documentRecordId, true, false, this.documentToDelete);
        }
        this.modalPopUpCaptureImage = false;
        if (this.doneflagCustomerImage ) {
                checkDocFromApp({ applicantId:  this.applicantId, docType: this.label.CustomerImageDocumentType })
                .then(result => {
                    if (result != null) {
                        this.documentRecordId=result;this.iconButtonCaptureImage = true;//For green tick after customer image
                        this.successToast('captured successfully','','success');
                        fetchCdocumentId({ documentId: this.documentRecordId })
                        .then(result => { 
                            const obj = JSON.parse(result);
                            this.documentToDelete = obj.backContentDocumentId;}
                        ) .catch(error => {   })
                    } else {
                        this.successToast('Upload Customer Image','','warning');
                        return null;
                    }                    
                }) .catch(error => {
                    this.isSpinnerMoving=false;
                    this.successToast(error.body.message,'','warning');
                });
           // }
            //this.iconButtonCaptureUpload = false;this.imageUploadRedCross = false;
        }else { this.iconButtonCaptureImage = false; }
    }
    isRevoked = false;//CISP-2413//CISP-2384
    tabcounter = 0;////CISP-2378//CISP-2465
    async renderedCallback() {
        if(this.isRevoked  || this.currentStage === 'Credit Processing' || (this.currentStageName !== 'Loan Initiation' && this.lastStage !== 'Loan Initiation')){//CISP-519
          await this.disableEverything();//JS size issue - CISP-2413 - START
            if(this.aadharButton){if(this.template.querySelector('.aadharbtn')){this.template.querySelector('.aadharbtn').disabled = false;}}
            if(this.passportButton){if(this.template.querySelector('.passportbtn')){this.template.querySelector('.passportbtn').disabled = false;}}
            if(this.voterIdButton){if(this.template.querySelector('.voteridbtn')){this.template.querySelector('.voteridbtn').disabled = false;}}
            if(this.drivingLicenseButton){if(this.template.querySelector('.driverbtn')){this.template.querySelector('.driverbtn').disabled = false;}}
            if(this.aadharButton){if(this.template.querySelector('.aadhar')){this.template.querySelector('.aadhar').disabled = false;}}
            if(this.passportButton){if(this.template.querySelector('.passport')){this.template.querySelector('.passport').disabled = false;}}
            if(this.voterIdButton){if(this.template.querySelector('.voter')){this.template.querySelector('.voter').disabled = false;}}
            if(this.drivingLicenseButton){if(this.template.querySelector('.driver')){this.template.querySelector('.driver').disabled = false;}}
            if(this.panButton){if(this.template.querySelector('.pan')){this.template.querySelector('.pan').disabled = false;}}
            if(this.gstButton){if(this.template.querySelector('.gst')){this.template.querySelector('.gst').disabled = false;}}
            if(this.cinButton){if(this.template.querySelector('.cin')){this.template.querySelector('.cin').disabled = false;}}
            if(this.template.querySelector('.prev')){this.template.querySelector('.prev').disabled = false;}if(this.template.querySelector('.next')){this.template.querySelector('.next').disabled = false;}//JS size issue - CISP-2413 - END
        }
        if(this.leadSource=='OLA' && this.currentStageName == 'Loan Initiation' && this.template.querySelector('lightning-input[data-id=incomeDec]')){//OLA-43
            this.template.querySelector('lightning-input[data-id=incomeDec]').disabled = false;}
        if(this.currentStageName === 'Loan Initiation' && this.isStepEight && this.boolprevRec){this.callAadharDetails();this.callCustomerDedupeData();this.boolprevRec=false;}
        loadStyle(this, LightningCardCSS);
        if(this.doYouHaveBankAccount && this.currentStep===this.label.bankAccountCheck && this.leadSource != 'OLA'){//OLA-71
            this.template.querySelector('lightning-input.haveBankAcct').checked = this.doYouHaveBankAccount;
            this.disabledBankAccWithIBL = false;
        } else if (!this.doYouHaveBankAccount && this.template.querySelector('lightning-input.haveBankAcct')) {
            this.disabledBankAccWithIBL = true; this.doYouHaveBankAccount = false;
            this.template.querySelector('lightning-input.haveBankAcct').checked = this.doYouHaveBankAccount;
        }
        if (this.doYouHaveBankAccountWithIBL && this.template.querySelector('lightning-input.withIBLBankAccount')) {
            this.template.querySelector('lightning-input.withIBLBankAccount').checked = this.doYouHaveBankAccountWithIBL;
            this.disabledOpenBankAcc = true;
            this.openNewBankAccount = false;
            if (!this.isTractor && this.template.querySelector('lightning-input.openBankAcct')) {
                this.template.querySelector('lightning-input.openBankAcct').checked = false;
            }
        }//CISP-2542-START
        if(this.isTractor && this.isNonIndividualBorrower && this.template.querySelector('lightning-input.haveBankAcct')){
            this.disabledBankAcc = true;
            this.doYouHaveBankAccount = true;
            this.template.querySelector('lightning-input.haveBankAcct').checked = true;
            this.template.querySelector('lightning-input.haveBankAcct').disabled = true;
        }
        if(this.checked){let incomeEle = this.template.querySelector('.incomSourceToggle'); if(incomeEle){incomeEle.checked=true;}}//CISP-2542-END
        if (!this.isTractor && this.openNewBankAccount && this.template.querySelector('lightning-input.openBankAcct')) {this.template.querySelector('lightning-input.openBankAcct').checked = this.openNewBankAccount;}
        if (this.agentBLCodeOptions !== undefined && this.agentBLCodeOptions.length == 1) {this.agentBLCodeValue = this.agentBLCodeOptions[0].value;this.disableAGBLCode = this.leadSource !== 'DSA';/*true; DSAMOD*/ ;if(this.map1.get(this.agentBLCodeValue)){this.productType = this.map1.get(this.agentBLCodeValue);} this.isTopUpShow = this.vehicleTypeval == 'Used' && this.isTractor ? true : false;}
        if(this.agentBLCodeValue !== undefined && this.agenBlCodeMap.size>0){this.agentBLCodeLabel=this.agenBlCodeMap.get(this.agentBLCodeValue);}
        if (this.checkBoxValue && this.template.querySelector('lightning-input.notCurrent')) {this.template.querySelector('lightning-input.notCurrent').checked = this.checkBoxValue;}
        if (this.currentPermanentcheckBoxValue && this.template.querySelector('lightning-input.sameAdd')) {this.template.querySelector('lightning-input.sameAdd').checked = this.currentPermanentcheckBoxValue;}
        if (this.checkBoxValuePermanent && this.template.querySelector('lightning-input.notPermanent')) {this.template.querySelector('lightning-input.notPermanent').checked = this.checkBoxValuePermanent;}
        
        if (this.phoneNoValue !== undefined && this.phoneNoValue !== "" && this.phoneNoValue !== null && this.template.querySelector('[data-id="samePhoneCheckBox"]') && this.phoneNoValue === this.whatsAppNumberValue) {this.template.querySelector('[data-id="samePhoneCheckBox"]').checked = true;}
        if (this.registerWhatsAppValue && this.template.querySelector('[data-id="registerWhatsAppId"]')) {this.template.querySelector('[data-id="registerWhatsAppId"]').checked = true;}
        if (this.disablePermanentAddress && this.isStepThree) {this.disableCurrentPermntSameAddr = true;}
        if (this.renderedDoYouHaveBankAccount) {this.template.querySelector('lightning-input.haveBankAcct').checked = false;} 
        this.isTwoWheeler = this.productType=='TW' ? true : false;
        this.isTractor = this.productType=='Tractor' ? true : false;
        //CISP-2390 - JS Size issue - END.
        if(this.isRevoked){//CISP-2384
            await this.disableEverything().then(result=>{ this.template.querySelectorAll(`button[data-id="preNextbtn"`).forEach(element=>{element.disabled = false;})})//CISP-2382
            const evt = new ShowToastEvent({title: 'This Loan Application is Revoked',variant: 'warning',mode: 'sticky'});this.dispatchEvent(evt);//CISP-2390
        }
     if(this.tabcounter < 0){this.template.querySelectorAll('lightning-input').forEach(input=>{input.disabled=true;})}
    }
    handleSectionToggle(event) {
        const openSections = event.detail.openSections;
        if (openSections.length === 0) {
            this.activeSectionsMessage = this.label.allSectionsClosed;
        } else {
            this.activeSectionsMessage = 'Open sections: ' + openSections.join(', ');
        }
    }
    validityCheck(query) {
        return [...this.template.querySelectorAll(query)].reduce((validSoFar, inputField) => {
            inputField.reportValidity();
            return validSoFar && inputField.checkValidity();
        }, true);
    }
    refreshHandler(){this.addressProofUploadScreenFlag = false;this.loanApplicationComponent; setTimeout(() => {this.addressProofUploadScreenFlag = true;},);}//CISP-2967
    changeValue(event) {
        this.addressProofUploadScreenFlag = false;this.loanApplicationComponent = false;this.documentRecordIdFromScanComp = event.detail;
    }
    kycDoneSuccess(event) {
        this.disableImage();
        this.typeFromScan = event.detail;
        if (this.typeFromScan == this.label.AadhaarCard) {this.aadharDocId = this.documentRecordIdFromScanComp;
        }else if (this.typeFromScan == this.label.VoterIdCard) {this.voterIdDocId = this.documentRecordIdFromScanComp;
        }else if (this.typeFromScan == this.label.PanCards) {this.panDocId = this.documentRecordIdFromScanComp;
        }else if (this.typeFromScan == this.label.DrivingLicences) {this.drivingLicenseDocId = this.documentRecordIdFromScanComp;
        }else if (this.typeFromScan == this.label.PassportCard) {this.passportDocId = this.documentRecordIdFromScanComp;
        }else if (this.typeFromScan == this.label.Form60DocumentType) {this.form60DocId = this.documentRecordIdFromScanComp;
        }else if (this.typeFromScan == this.label.GST_CERT) {this.gstDocId = this.documentRecordIdFromScanComp;
        }else if (this.typeFromScan == this.label.CIN_CERT) {this.cinDocId = this.documentRecordIdFromScanComp;}
        this.kycSuccessDoneFlag = true;this.disableCurrentAddress = true;this.disableCurrentPermntSameAddr = false;
        if (this.kycType == this.label.AadhaarCard) {
            if (this.currentStep === this.label.captureCurrentResidentialAddress) {
                this.disableAadharButton01 = false;this.disablePassportButton01 = true; this.disableVoterIdButton01 = true; this.disableDLButton01 = true;this.aadharButton = true;this.counter_current_kyc++;this.counter_pan_kyc++;
                const docFields = {};docFields[DOC_ID_FIELD.fieldApiName] = this.aadharDocId;
                docFields[CURRENT_RESIDENTIAL_ADDRESS_PROOF.fieldApiName] = true;
                docFields[ADDRESS_TYPE.fieldApiName] = 'Current Residential Address';
                this.updateRecordDetails(docFields);
            }
            if (this.currentStep === this.label.capturePermanentResidentialAddress && (this.disableAadharButton01 == true || this.selectedValueCurrentAdd == true ||  this.isStepThreeV2)) {//CISP-2831
                this.disablePermanentAddress = true;this.disableAadharButton02 = false;this.aadharButton = true;this.counter_permanent_kyc++;this.counter_pan_kyc++;
                if (this.selectedValueCurrentAdd == true) {this.disablePassportButton02 = true;this.disableVoterIdButton02 = true;this.disableDLButton02 = true;
                } else {this.disablePassportButton02 = this.disablePassportButton01;this.disableVoterIdButton02 = this.disableVoterIdButton01;this.disableDLButton02 = this.disableDLButton01;
                }
                const docFields = {};
                docFields[DOC_ID_FIELD.fieldApiName] = this.aadharDocId;
                docFields[PERMANENT_RESIDENTIAL_ADDRESS_PROOF.fieldApiName] = true;
                docFields[ADDRESS_TYPE.fieldApiName] = 'Permanent Residential Address';
                this.updateRecordDetails(docFields);
            }
            if (this.currentStep === this.label.capturePANOrOtherKyc && this.aadharButton == false) {
                this.aadharButton = true;
                this.counter_pan_kyc++;
            }
        } else if (this.kycType == this.label.VoterIdCard) {
            if (this.currentStep === this.label.captureCurrentResidentialAddress) {
                this.disablePassportButton01 = true; this.disableAadharButton01 = true;this.disableDLButton01 = true; this.disableVoterIdButton01 = false; this.voterIdButton = true;this.counter_current_kyc++;this.counter_pan_kyc++;
                const docFields = {};
                docFields[DOC_ID_FIELD.fieldApiName] = this.voterIdDocId;
                docFields[CURRENT_RESIDENTIAL_ADDRESS_PROOF.fieldApiName] = true;
                docFields[ADDRESS_TYPE.fieldApiName] = 'Current Residential Address';
                this.updateRecordDetails(docFields);
            }
            if (this.currentStep === this.label.capturePermanentResidentialAddress && (this.disableVoterIdButton01 == true || this.selectedValueCurrentAdd == true)) {
                this.disablePermanentAddress = true; this.disableVoterIdButton02 = false;this.voterIdButton = true; this.counter_permanent_kyc++; this.counter_pan_kyc++;
                if (this.selectedValueCurrentAdd == true) {
                    this.disablePassportButton02 = true; this.disableAadharButton02 = true;this.disableDLButton02 = true;
                } else {
                    this.disablePassportButton02 = this.disablePassportButton01;this.disableAadharButton02 = this.disableAadharButton01;this.disableDLButton02 = this.disableDLButton01;
                }
                const docFields = {};
                docFields[DOC_ID_FIELD.fieldApiName] = this.voterIdDocId;
                docFields[PERMANENT_RESIDENTIAL_ADDRESS_PROOF.fieldApiName] = true;
                docFields[ADDRESS_TYPE.fieldApiName] = 'Permanent Residential Address';
                this.updateRecordDetails(docFields);
            }
            if (this.currentStep === this.label.capturePANOrOtherKyc && this.voterIdButton == false) {
                this.voterIdButton = true;
                this.counter_pan_kyc++;
            }
        }else if (this.kycType == this.label.DrivingLicences) {
            if (this.currentStep === this.label.captureCurrentResidentialAddress) {
                this.disablePassportButton01 = true;this.disableVoterIdButton01 = true;this.disableAadharButton01 = true;this.disableDLButton01 = false;this.drivingLicenseButton = true;this.counter_current_kyc++;this.counter_pan_kyc++;
                const docFields = {};
                docFields[DOC_ID_FIELD.fieldApiName] = this.drivingLicenseDocId;
                docFields[CURRENT_RESIDENTIAL_ADDRESS_PROOF.fieldApiName] = true;
                docFields[ADDRESS_TYPE.fieldApiName] = 'Current Residential Address';
                this.updateRecordDetails(docFields);
            }
            if (this.currentStep === this.label.capturePermanentResidentialAddress && (this.disableDLButton01 == true || this.selectedValueCurrentAdd == true)) {
                this.disablePermanentAddress = true;this.disableDLButton02 = false;this.drivingLicenseButton = true; this.counter_permanent_kyc++; this.counter_pan_kyc++;
                if (this.selectedValueCurrentAdd == true) { this.disablePassportButton02 = true;this.disableVoterIdButton02 = true;this.disableAadharButton02 = true; 
                }else {
                    this.disablePassportButton02 = this.disablePassportButton01;this.disableVoterIdButton02 = this.disableVoterIdButton01;this.disableAadharButton02 = this.disableAadharButton01;  
                }
                const docFields = {};
                docFields[DOC_ID_FIELD.fieldApiName] = this.drivingLicenseDocId;
                docFields[PERMANENT_RESIDENTIAL_ADDRESS_PROOF.fieldApiName] = true;
                docFields[ADDRESS_TYPE.fieldApiName] = 'Permanent Residential Address';
                this.updateRecordDetails(docFields);
            }
            if (this.currentStep === this.label.capturePANOrOtherKyc && this.drivingLicenseButton == false) {
                this.drivingLicenseButton = true;
                this.counter_pan_kyc++;
            }
        }else if (this.kycType == this.label.PassportCard) {
            if (this.currentStep === this.label.captureCurrentResidentialAddress) { this.disableAadharButton01 = true; this.disableVoterIdButton01 = true; this.disableDLButton01 = true;this.disablePassportButton01 = false;this.passportButton = true;this.counter_current_kyc++;this.counter_pan_kyc++;
                const docFields = {};
                docFields[DOC_ID_FIELD.fieldApiName] = this.passportDocId;
                docFields[CURRENT_RESIDENTIAL_ADDRESS_PROOF.fieldApiName] = true;
                docFields[ADDRESS_TYPE.fieldApiName] = 'Current Residential Address';
                this.updateRecordDetails(docFields);
            }
            if (this.currentStep === this.label.capturePermanentResidentialAddress && (this.disablePassportButton01 == true || this.selectedValueCurrentAdd == true)) {
                this.disablePermanentAddress = true;this.disablePassportButton02 = false;this.passportButton = true;this.counter_permanent_kyc++;this.counter_pan_kyc++;
                if (this.selectedValueCurrentAdd == true) {this.disableDLButton02 = true;this.disableVoterIdButton02 = true;this.disableAadharButton02 = true;
                } else {this.disableDLButton02 = this.disableDLButton01;this.disableAadharButton02 = this.disableAadharButton01;this.disableVoterIdButton02 = this.disableVoterIdButton01;}
                const docFields = {};
                docFields[DOC_ID_FIELD.fieldApiName] = this.passportDocId;
                docFields[PERMANENT_RESIDENTIAL_ADDRESS_PROOF.fieldApiName] = true;
                docFields[ADDRESS_TYPE.fieldApiName] = 'Permanent Residential Address';
                this.updateRecordDetails(docFields);
            }
            if (this.currentStep === this.label.capturePANOrOtherKyc && this.passportButton == false) {this.passportButton = true;this.counter_pan_kyc++;}
        } else if (this.kycType == this.label.PanCards) {if (this.currentStep === this.label.capturePANOrOtherKyc) {this.panButton = true;}this.counter_pan_kyc++;//IND-1660
        } else if (this.kycType == this.label.GST_CERT) {if (this.currentStep === this.label.capturePANOrOtherKyc) {this.gstButton = true;}this.counter_pan_kyc++;
        } else if (this.kycType == this.label.CIN_CERT) {if (this.currentStep === this.label.capturePANOrOtherKyc) {this.cinButton = true;}this.counter_pan_kyc++;
        }
    }
    updateApplicantName(event){this.connectedCallback();}
    panKYCUpload() {
        if (this.typeFromScan == this.label.Form60DocumentType || this.form60DocId != null) {
            this.loanApplicationComponent = true;this.kycType = this.label.Form60DocumentType;this.addressProofUploadScreenFlag = true; this.currentDocId = this.form60DocId; this.currentFieldStirng = Form60;
            //this.successToast(this.label.sorryCannotPreviewForm60Document,'','warning');
        } else {
            this.loanApplicationComponent = true; this.kycType = this.label.PanCards; this.addressProofUploadScreenFlag = true; this.currentDocId = this.panDocId;this.currentFieldStirng = this.label.Pan;
        }
    }
    adharKYCUpload() {
        this.loanApplicationComponent = true; this.kycType = this.label.AadhaarCard; this.addressProofUploadScreenFlag = true;this.currentDocId = this.aadharDocId; this.currentFieldStirng = this.label.Aadhaar;
    }
    voterIdKYCUpload() {this.loanApplicationComponent = true;this.kycType = this.label.VoterIdCard;this.addressProofUploadScreenFlag = true;this.currentDocId = this.voterIdDocId; this.currentFieldStirng = this.label.VoterID;this.kycDocumentName = 'Voter ID'}
    handleUpload(event) {
        let name = event.currentTarget.dataset.id;
        this.loanApplicationComponent = true; this.kycType = (name == 'GST CERTIFICATE' ? this.label.GST_CERT : this.label.CIN_CERT) ; this.addressProofUploadScreenFlag = true;this.currentDocId = (name == 'GST CERTIFICATE' ? this.gstDocId : this.cinDocId); this.currentFieldStirng = (name == 'GST CERTIFICATE' ? 'GST_No__c' : 'CIN_No__c');this.kycDocumentName = this.kycType;
    }
    dLKYCUpload() {
        this.loanApplicationComponent = true;this.kycType = this.label.DrivingLicences;this.addressProofUploadScreenFlag = true;this.currentDocId = this.drivingLicenseDocId; this.currentFieldStirng = this.label.DrivingLicence;
    }
    passportKYCUpload() {
        this.loanApplicationComponent = true; this.kycType = this.label.PassportCard;this.addressProofUploadScreenFlag = true;this.currentDocId = this.passportDocId;this.currentFieldStirng = this.label.Passport;
    }
    value = [];
    agentBLCodeHandler(event) {    
        let agentBLCodeInput = this.template.querySelector('.agentCss');
        if(this.vehicleTypeval){
        if(this.map1.get(agentBLCodeInput.value)){this.productType = this.map1.get(agentBLCodeInput.value);}this.agentBLCodeValue = agentBLCodeInput.value;agentBLCodeInput.reportValidity();  
        this.agentBLCodeLabel=this.agenBlCodeMap.get(agentBLCodeInput.value);  //CISP: 2861 this is to send the branch code value in tab loan aaplication 
        var blValues = {agentBL:agentBLCodeInput.value, proType:this.productType};//CISP-3009
        const evnt = new CustomEvent('checkagentbranchcode', { detail: blValues});//CISP-3009
        if((this.productType == 'Passenger Vehicles')|| (this.productType == 'PV')){this.template.querySelector('[data-id="registerWhatsAppId"]').checked = true;this.registerWhatsAppValue = true;};//CISP-15132  
        if(this.productType == 'Tractor' && this.vehicleTypeval == 'Used'){this.isTopUpShow = true;}else{this.isTopUpShow = false;}
        this.dispatchEvent(evnt);
        this.updateOpportunity();
    } else{
        agentBLCodeInput.setCustomValidity("Please select Vehicle Type First");
        agentBLCodeInput.reportValidity(); 
    }
    }
    handleInputChange(event) {  
        helper.handleInputChange(this, event);
    }
    //CISP-3293
    handleVehicleTypeChange(event){
        try{
        let agentBLCodeInput = this.template.querySelector('.agentCss'); //CISP-4698 START
        if(agentBLCodeInput.value){
            agentBLCodeInput.setCustomValidity("");
            agentBLCodeInput.reportValidity(); //CISP-4698 END
            agentBLCodeInput.value = '';this.agentBLCodeValue = '';//CISP-14464
        }
        
        let vehcleval = this.template.querySelector('.vehicleCss');//vehicleCss
        this.vehicleTypeval = vehcleval.value;
        vehcleval.reportValidity(); 
        console.log(vehcleval.validity.valid,'vehcleval.validity.valid');
        if(vehcleval.validity.valid){
            helper.blCodeHide(this);
                }

        if(this.vehicleTypeval != 'Used'){this.isTopUpShow = false; this.isTopUpChecked = false;}else if(this.vehicleTypeval=='Used' && this.productType =='Tractor'){this.isTopUpShow = true;}
    }
    catch(error){
        console.error('error-->'+error);
    }
    }
    beneficialOwnerCategoryHandler(event){ //SFTRAC-78
        let beneficialOCInput = event.target.value;
        this.beneficialOwnerCategory = beneficialOCInput;
    }
    relationshipWithEntityHandler(event){//SFTRAC-78
        let relwithEntityInput = event.target.value;
        this.relationshipWithEntity = relwithEntityInput;
        let a1 = ['BUSINESS ENTITY REGISTERED IN INDIA','RESIDENT INDIAN INDIVIDUAL','BUSINESS ENTITY REGISTERED OUTSIDE INDIA','FOREIGN / NON RESIDENT INDIVIDUAL'];
        let a2 = ['BUSINESS ENTITY REGISTERED IN INDIA','BUSINESS ENTITY REGISTERED OUTSIDE INDIA'];
        let a3 = ['RESIDENT INDIAN INDIVIDUAL','FOREIGN / NON RESIDENT INDIVIDUAL'];
        let relationshipTypeList = []
        relationshipTypeList = this.relationshipTypeOption;
        if(this.relationshipWithEntity == '10' || this.relationshipWithEntity == '30' || this.relationshipWithEntity == '60'){
            this.relationshipTypeOptions = relationshipTypeList.filter((name) => a1.includes(name.label));
        } else if (this.relationshipWithEntity == '11' || this.relationshipWithEntity == '12'){
            this.relationshipTypeOptions = relationshipTypeList.filter((name) => a2.includes(name.label));
        } else {
            this.relationshipTypeOptions = relationshipTypeList.filter((name) => a3.includes(name.label));
        }
    }
    relationshipTypeHandler(event){//SFTRAC-78
        let relTypeInput = event.target.value;
        this.relationshipType = relTypeInput;
    }
    poaChangeHandler(event){//SFTRAC-78
        this.poaHolder = event.target.checked;
    }
    firstNameHandler() {
        let firstNameInput = this.template.querySelector('lightning-input[data-id=firstNameId]');
        let firstNameValue = firstNameInput.value;
        this.firstNameValue = firstNameValue;
        if (firstNameValue.length > 26) {
            firstNameInput.setCustomValidity(this.label.lastNameError);
        } else {
            firstNameInput.setCustomValidity(""); // clear previous value
        }
        firstNameInput.reportValidity();
    }
    lastNameHandler() {
        let lastNameInput = this.template.querySelector('lightning-input[data-id=lastNameId]');
        let lastNameValue = lastNameInput.value;this.lastNameValue = lastNameValue;
        if(lastNameValue.length > 26){lastNameInput.setCustomValidity(this.label.lastNameError);
        }else{lastNameInput.setCustomValidity(""); // clear previous value
        }lastNameInput.reportValidity();
    }
    @track showAadhaarLinkedModal = false;
    PhoneNumberHandler() {
        let phoneNoInput = this.template.querySelector('lightning-input[data-id=phoneNumberId]');
        let phoneNoValue = phoneNoInput.value;this.phoneNoValue = phoneNoValue;//Valid
        if (phoneNoInput.validity.valid == true) {this.showAadhaarLinkedModal = true;this.disableSamePhoneCheckBox = false;this.isWhatsAppNumberAccessible = false;this.validateExistingNumber(phoneNoInput);
        } else { 
            if(this.productType != 'PV'){ 
            this.template.querySelector('lightning-input[data-id=registerWhatsAppId]').checked = false;
            this.registerWhatsAppValue = false;
            }//CISP-15132
            let sameNoCBInput = this.template.querySelector('lightning-input[data-id=samePhoneCheckBox]');
            this.isWhatsAppNumberAccessible = false;this.showCopiedWhatsAppNumber = false; this.whatsAppNumberValue = null;
            sameNoCBInput.checked = false;
            this.disableSamePhoneCheckBox = true; this.disableRegisterOnlineWhatsApp = true;
            let whatsAppNumberInput = this.template.querySelector('lightning-input[data-id=whatsAppNumberId]');
            phoneNoInput.setCustomValidity("");
        }
        phoneNoInput.reportValidity();
    }
    handleAadhaarLinkedNo(){
        this.showAadhaarLinkedModal = false;
        this.consentDisable = true;
        this.successToast('Mobile Number','Please enter Mobile Number that is linked to Aadhaar','error');
    }
    handleAadhaarLinkedYes(){
        this.showAadhaarLinkedModal = false;
        this.consentDisable = false;
    }
    whatsappNumberHandler() {
        let whatsAppNumberInput;
        if (this.showCopiedWhatsAppNumber) {
            whatsAppNumberInput = this.template.querySelector('lightning-input[data-id=checkedWhatsAppNumberId]');
        } else {
            whatsAppNumberInput = this.template.querySelector('lightning-input[data-id=whatsAppNumberId]');
        }
        let whatsAppNumValue = whatsAppNumberInput.value;
        this.whatsAppNumberValue = whatsAppNumValue;
        if (this.whatsAppNumberValue != this.phoneNoValue) {
            this.template.querySelector('lightning-input[data-id=samePhoneCheckBox]').checked = false;
        } else {
            this.template.querySelector('lightning-input[data-id=samePhoneCheckBox]').checked = true;
        }
        if (whatsAppNumValue.length == 10) {//Validate Existing Number
            this.validateExistingNumber(whatsAppNumberInput);
            this.disableRegisterOnlineWhatsApp = true;
        } else {
            whatsAppNumberInput.setCustomValidity("");
        }
        whatsAppNumberInput.reportValidity();
        let registerWhatsAppNoId = this.template.querySelector('lightning-input[data-id=registerWhatsAppId]');
        if (whatsAppNumberInput.validity.valid == true) {
            if (this.whatsAppNumberValue == '') {
                this.disableRegisterOnlineWhatsApp = true;registerWhatsAppNoId.checked = false;
            } else {
                this.disableRegisterOnlineWhatsApp = false;
            }
        } else {
            this.disableRegisterOnlineWhatsApp = true;registerWhatsAppNoId.checked = false;
        }
    }
    sameNoHandler(event) {
        let checkBoxValue = event.target.checked;this.showCopiedWhatsAppNumber = checkBoxValue;
        if (checkBoxValue) {
            let whatsAppNumberInput = this.template.querySelector('lightning-input[data-id=whatsAppNumberId]');this.whatsAppNumberValue = this.phoneNoValue;this.isWhatsAppNumberAccessible = true;
            whatsAppNumberInput.reportValidity();
            this.disableRegisterOnlineWhatsApp = false;
        } else {
            this.isWhatsAppNumberAccessible = false;this.whatsAppNumberValue = null;this.disableRegisterOnlineWhatsApp = true;
            this.template.querySelector('lightning-input[data-id=registerWhatsAppId]').checked = false;
            this.registerWhatsAppValue = false;
        }
    }
    validateExistingNumber(phoneNoInput) {
        validateContactNumber({ contactNumber: phoneNoInput.value }).then(result => {
            this.response = result;
            if (this.response == true) {
                phoneNoInput.setCustomValidity(this.label.validationMsgNoalreadyReg);
                if (phoneNoInput.name == 'phoneNo') {
                    this.disableSamePhoneCheckBox = true;
                } else if (phoneNoInput.name == 'whatsAppNo') {
                    this.disableRegisterOnlineWhatsApp = true;
                }
            } else {
                phoneNoInput.setCustomValidity("");
            }
            phoneNoInput.reportValidity();
        }).catch(error => {this.error = error;});
    }
    whatsAppNumValidityCheck() {
        let whatsAppNumberInput;
        if (this.showCopiedWhatsAppNumber) {
            whatsAppNumberInput = this.template.querySelector('lightning-input[data-id=checkedWhatsAppNumberId]');
        } else {
            whatsAppNumberInput = this.template.querySelector('lightning-input[data-id=whatsAppNumberId]');
        }
        if (whatsAppNumberInput != null) {
            whatsAppNumberInput.setCustomValidity("");
            whatsAppNumberInput.reportValidity();
        }
    }
    createApplicationCross = false;
    createApplicationCounter = 0;
    modalPopUpToggleFlag = false;consentCount = 0;disableBOC =false;disableRelEntity = false; disableRelationshipType = false;disablesharePercent = false;disablePOAHolder = false; disableFirsttName = false;disableLastName = false;disablePhoneNumber = false;
    async handleConsent() {this.consentDisable = true;this.isLoading = true;
        this.consentCount = this.consentCount + 1;
        let whatsAppNumberInput;
        if (this.whatsAppNumberValue != '' || this.whatsAppNumberValue != null) {
            if (this.showCopiedWhatsAppNumber) {whatsAppNumberInput = this.template.querySelector('lightning-input[data-id=checkedWhatsAppNumberId]');} else {whatsAppNumberInput = this.template.querySelector('lightning-input[data-id=whatsAppNumberId]');}
            if (whatsAppNumberInput != null) {whatsAppNumberInput.reportValidity();}
        }
        let inputFieldsValid = this.validityCheck('lightning-input');
        let comboBoxValid = this.validityCheck('lightning-combobox');
        if (inputFieldsValid && comboBoxValid ) {
            await this.postOTPVerificationHandler();//will save after validation
        }this.consentDisable = false;this.isLoading = false;//CISP-2665-JS-END
    }

    consentfirstTime=false;consentfirstTimeFlag=true;
    handleOtpPopup() {
        if (this.modalPopUpToggleFlag == false && this.applicantId != "") {
            this.disableAll();this.modalPopUpToggleFlag = true;//To open otp pop-up
            updateConsentStatus({ applicantId: this.applicantId }).then(result => {
                this.template.querySelector('c-l-W-C_-L-O-S_-O-T-P').showResendTimer();if(this.consentfirstTimeFlag || result){this.consentfirstTime=true;} else{this.consentfirstTime=false;}this.gettimeout();
            }).catch(error => {  });
        }
    }
    gettimeout(){
        otpExpireTimeOut({applicantId:this.currentapplicationid}) .then(result =>{
            if(result || this.consentfirstTime){
                sendConsentSMS({ applicantId: this.applicantId }) .then(result => {this.response = result;this.doSmsApiCall();}) .catch(error => { this.error = error;});
            }else{this.successToast(this.label.otpSend,'','warning');}
        }) .catch(error=>{})
    }
    doSmsApiCall() {
        let smsRequestString= {
            'loanApplicationId': this.recordid ,
            'flag':'OTP',
            'applicantId' : this.applicantId
        };    
        doSmsCallout({ smsRequestString: JSON.stringify(smsRequestString), loanId:this.recordid}).then(result => {
                if (result == 'SUCCESS') {
                    this.successToast(this.label.otpSentSuccessfully,'','success');
                } else {
                    this.successToast(this.label.FailResponseApi,'','warning');
                }
            }).catch(error => {this.successToast(this.label.ExceptionMessage,'','warning');})
    }
    async postOTPVerificationHandler() {
        try {
            if(this.currentTabId == 'NIL' || this.currentTabId == 'G-NIL' || this.currentTabId == 'B-NIL' || this.currentTabId == '' || this.currentTabId == undefined){
                this.applicantId == '';
            }else{
                this.applicantId = this.currentTabId;
            }
            if (this.applicantId == '' || this.applicantId == undefined) {//Updating opportunity record
                if (this.currenttab === this.label.Borrower) {await this.updateOpportunity();} //Updating Applicant record
                const applicantsFields = {};
                if(this.isTractor && (this.currenttab === this.label.CoBorrower || this.currenttab === 'Beneficiary')){ 
                    let isPrimary = await isFirstCoborrower({ loanApplicationId: this.currentOppRecordId, applicantType:this.currenttab});
                    if(isPrimary){
                        applicantsFields[ISPRIMARY.fieldApiName] = true;
                    }
                }
                if(this.isNonIndividualBorrower && this.isTractor){this.firstNameValue = "";this.lastNameValue = "";if (this.loan.Entity_Name__c.split(" ").length > 1) {this.lastNameValue = this.loan.Entity_Name__c.substring(this.loan.Entity_Name__c.lastIndexOf(" ") + 1);this.firstNameValue = this.loan.Entity_Name__c.substring(0, this.loan.Entity_Name__c.lastIndexOf(' '));}else{this.firstNameValue = this.loan.Entity_Name__c;}applicantsFields[CUSTOMER_NAME_FIELD.fieldApiName] = this.loan.Entity_Name__c;applicantsFields[CUSTOMER_FIRST_NAME_FIELD.fieldApiName] = this.firstNameValue;applicantsFields[CUSTOMER_LAST_NAME_FIELD.fieldApiName] = this.lastNameValue;}else{
                applicantsFields[CUSTOMER_NAME_FIELD.fieldApiName] = this.firstNameValue + ' ' + this.lastNameValue;applicantsFields[CUSTOMER_FIRST_NAME_FIELD.fieldApiName] = this.firstNameValue;applicantsFields[CUSTOMER_LAST_NAME_FIELD.fieldApiName] = this.lastNameValue;}applicantsFields[CUSTOMER_PHONE_NUMBER_FIELD.fieldApiName] = this.phoneNoValue;applicantsFields[CUSTOMER_WHATSAPP_NUMBER_FIELD.fieldApiName] = this.whatsAppNumberValue;applicantsFields[REGISTER_FOR_WHATSAPP_BANKING_FIELD.fieldApiName] = this.registerWhatsAppValue;applicantsFields[OPPORTUNITY_APPLICANT_LOOKUP_FIELD.fieldApiName] = this.currentOppRecordId;applicantsFields[ACCOUNT_APPLICANT_TYPE_FIELD.fieldApiName] = this.currenttab;applicantsFields[APPLICANT_SUBSTAGE.fieldApiName] = this.currentStep;
                if(this.isTractor && this.entityType == 'Non-Individual'){ //SFTRAC-78
                    applicantsFields[BENEFICIAL_OWNER_CATEGORY.fieldApiName] = this.beneficialOwnerCategory;
                    applicantsFields[RELATIONSHIP_WITH_ENTITY.fieldApiName] = this.relationshipWithEntity;
                    applicantsFields[RELATIONSHIP_TYPE.fieldApiName] = this.relationshipType;
                    applicantsFields[POA_HOLDER.fieldApiName] = this.poaHolder;applicantsFields[SHAREHOLDER_PERCENT.fieldApiName] = this.shareHolderPercent;}    
                if(this.isTractor && this.loan.Profile__c){
                    applicantsFields['Profile__c'] = this.loan.Profile__c;
                }
                if(this.isTractor){ applicantsFields['Entity__c'] = this.getEntityType;}
                this.applicantId = await this.upsertRecordDetails(APPLICANT_OBJECT.objectApiName, applicantsFields);
                this.currentTabId = this.applicantId;       
                const newApplicantEvent = new CustomEvent("newapplicantevent", {detail: {applicantId: this.applicantId, applicantType: this.currenttab}});
                this.dispatchEvent(newApplicantEvent);
                if (!this.homePageFlag) {this.handleOtpPopup();if(!this.isTractor){this.handleConsent();}}this.consentDisable = false;this.isLoading = false;
            } else {
                await this.updateOpportunity();//IND1557
                const applicantsFields = {};
                if(this.isTractor && this.entityType == 'Non-Individual'){ //SFTRAC-78
                    applicantsFields[BENEFICIAL_OWNER_CATEGORY.fieldApiName] = this.beneficialOwnerCategory;
                    applicantsFields[RELATIONSHIP_WITH_ENTITY.fieldApiName] = this.relationshipWithEntity;
                    applicantsFields[RELATIONSHIP_TYPE.fieldApiName] = this.relationshipType;
                    applicantsFields[POA_HOLDER.fieldApiName] = this.poaHolder;applicantsFields[SHAREHOLDER_PERCENT.fieldApiName] = this.shareHolderPercent;}    
                if(this.isTractor && this.loan.Profile__c){
                    applicantsFields['Profile__c'] = this.loan.Profile__c;
                }
                if(this.isTractor){ applicantsFields['Entity__c'] = this.getEntityType;}
                if(this.isNonIndividualBorrower && this.isTractor){this.firstNameValue = "";this.lastNameValue = "";if (this.loan.Entity_Name__c.split(" ").length > 1) {this.lastNameValue = this.loan.Entity_Name__c.substring(this.loan.Entity_Name__c.lastIndexOf(" ") + 1);this.firstNameValue = this.loan.Entity_Name__c.substring(0, this.loan.Entity_Name__c.lastIndexOf(' '));}else{this.firstNameValue = this.loan.Entity_Name__c;}applicantsFields[CUSTOMER_NAME_FIELD.fieldApiName] = this.loan.Entity_Name__c;applicantsFields[CUSTOMER_FIRST_NAME_FIELD.fieldApiName] = this.firstNameValue;applicantsFields[CUSTOMER_LAST_NAME_FIELD.fieldApiName] = this.lastNameValue;}else{
                applicantsFields[APP_ID_FIELD.fieldApiName] = this.applicantId;applicantsFields[CUSTOMER_NAME_FIELD.fieldApiName] = this.firstNameValue + ' ' + this.lastNameValue;}applicantsFields[CUSTOMER_FIRST_NAME_FIELD.fieldApiName] = this.firstNameValue;applicantsFields[CUSTOMER_LAST_NAME_FIELD.fieldApiName] = this.lastNameValue;applicantsFields[CUSTOMER_PHONE_NUMBER_FIELD.fieldApiName] = this.phoneNoValue;applicantsFields[CUSTOMER_WHATSAPP_NUMBER_FIELD.fieldApiName] = this.whatsAppNumberValue;applicantsFields[REGISTER_FOR_WHATSAPP_BANKING_FIELD.fieldApiName] = this.registerWhatsAppValue;applicantsFields[ACCOUNT_APPLICANT_TYPE_FIELD.fieldApiName] = this.currenttab;applicantsFields[APPLICANT_SUBSTAGE.fieldApiName] = this.currentStep;let applicantId = await this.upsertRecordDetails(APPLICANT_OBJECT.objectApiName, applicantsFields);
                if (!this.homePageFlag == true) {this.handleOtpPopup();}this.consentDisable = false;this.isLoading = false;
            }
        } catch (error) { this.consentDisable = false;this.isLoading = false;} 
          finally { this.consentDisable = false;this.isLoading = false;}
    }
    incomeSourceHandler(event) {
        this.checked = event.target.checked;
        if (this.checked) {
            this.isDisabledDeclaredIncome = false;
        } else {
            this.isDisabledDeclaredIncome = true;this.declaredIncome = '';
            Promise.resolve().then(() => {
                let cmpIncomeDec = this.template.querySelector('lightning-input[data-id=incomeDec]');
                cmpIncomeDec.reportValidity();
            });
        }
    }
    bankAccountHandler(event) {
        this.doYouHaveBankAccount = event.target.checked;
        if (!this.doYouHaveBankAccount ) {
            if (this.currenttab === this.label.Borrower) {
                if(this.isTractor){this.doYouHaveBankAccountWithIBL = false;}
                this.template.querySelector('lightning-input.withIBLBankAccount').checked = false;
                this.disabledBankAccWithIBL = true; //It will disabled toggle of bankAcc with IBL
                //this.disabledOpenBankAcc =this.isNewCustomer? false: true; //It will disabled toggle of do you have bank account
                if(this.aadhaarSourceOTPBio && this.isNewCustomer){this.disabledOpenBankAcc = false;}else{this.disabledOpenBankAcc = true;}
                if(this.leadSource === 'Hero'){this.successToast('Please check any one of the above','','warning'); return;}else if(!this.isTractor){this.successToast(this.label.coBorrowerAdditionMandatory,'','warning');}//CISH-37
            }else if (this.currenttab !== this.label.Borrower) {
                this.disabledBankAccWithIBL = true; //It will disabled toggle of bankAcc with IBL
                //this.disabledOpenBankAcc = this.isNewCustomer? false: true; //It will disabled toggle of do you have bank account
                if(this.aadhaarSourceOTPBio && this.isNewCustomer){this.disabledOpenBankAcc = false;}else{this.disabledOpenBankAcc = true;}
                this.template.querySelector('lightning-input.withIBLBankAccount').checked = false;
                this.successToast(`${this.currenttab} needs to have Bank Account`,'','warning');
            }
        } else if (this.doYouHaveBankAccount) {
            //when User has bank Account both toggle will enable
            this.disabledBankAccWithIBL = false;
            //this.disabledOpenBankAcc = this.isNewCustomer? false: true;
            if(this.aadhaarSourceOTPBio && this.isNewCustomer){this.disabledOpenBankAcc = false;}else{this.disabledOpenBankAcc = true;}
        }
    }
    accountWithIBLHandler(event) {
        this.doYouHaveBankAccountWithIBL = event.target.checked;
        if (this.doYouHaveBankAccountWithIBL) {
            this.disabledOpenBankAcc = true;
        if(!this.isTractor){
            this.template.querySelector('lightning-input.openBankAcct').checked = false;this.aepsValue=null;this.disableAeps=true;
        }
            
        } else {
            //this.disabledOpenBankAcc = this.isNewCustomer? false: true;;
            if(this.aadhaarSourceOTPBio && this.isNewCustomer){this.disabledOpenBankAcc = false;}else{this.disabledOpenBankAcc = true;}
        }
    }
    renderedDoYouHaveBankAccount = false;
    openBankAccountHandler(event) {
        helper.openBankAccountHandlerhelper(this,event);
    }
    handlePicklistValueChange(event){
        this.selectedLiteracyFieldOptionValue = event.target.value
    }
            //CISP-1196 - Enable next button
     handleEnableNextButton() {this.isEnableNextval = true; }// Modified (13-10-2022)
     handleEnableNextForDedupe() {if(this.currentStageName === 'Loan Initiation' && this.lastStage === 'Loan Initiation'){this.template.querySelectorAll(`button[data-name="nextBtn"`).forEach(element=>{element.disabled = false;});}}
     handleDisableNext() {this.template.querySelectorAll(`button[data-name="nextBtn"`).forEach(element=>{element.disabled = true;});}//CISP:142
    handleCoBorrower() {
        helper.handleCoworkerHelper(this);
    }
    handleGuarantor(){
        helper.handleGuarantor(this);
    }
    handleBeneficiary(){
        this.dispatchEvent(new CustomEvent('changetobeneficiary'));
    }
    doneflagCustomerImage = false;
    documentSide;
    captureCustomerImage() {
        this.documentSide='Selfie';
        if (this.iconButton == false) {
            this.successToast(this.label.consentInitialisationRequired,'','error');
            return null;
        }
        let agentBLCodeInput = this.template.querySelector('.agentCss');
        agentBLCodeInput.reportValidity();
       if(agentBLCodeInput.validity.valid == true) {
        if(this.leadSource==='DSA'){this.disableAGBLCode=true; this.disableVehicle=true;}//CISP-3293
        this.doneflagCustomerImage = false;
        if (FORM_FACTOR == 'Large') {
            this.modalPopUpCaptureImage = true;
            if (this.imageAttempt === 0 && this.documentRecordId==null) {
                docCustomerImage({ docType: 'Customer Image', applicantId: this.applicantId, loanApplicationId: this.currentOppRecordId })
                    .then(result => {
                        this.documentRecordId = result;
                    }).catch(error => { this.error = error;});
                    this.imageAttempt=this.imageAttempt+1;
            } 
        }
        else{
            this.modalPopUpCaptureImage = true; this.captureImageWeb = false;this.captureImageApi = true;
        }
    }
    }
    deleteImage(documentRecordId, isDone, isCancel, contentDocumentData) {
        kycDelete({ documentId: documentRecordId, isDone: isDone, isCancel: isCancel, contentDocumentData: contentDocumentData }) //apex method call
            .then(result => {this.isCancel = true;this.isDone = true;}) .catch(error => {this.isCancel = true;this.isDone = true;this.isLoading = false;this.error = error;
            });}captureCustomerImageClose() {this.iconButtonCaptureImage = false;
        if (this.isCancel == false) {this.deleteImage(this.documentRecordId, false, true, this.documentToDelete);}this.modalPopUpCaptureImage = false;}

    captureCustomerImageApp() {
        this[NavigationMixin.Navigate]({
            type: "standard__webPage",
            attributes: {
                url: 'ibl://indusindbank.com/integratorInfo?' + this.label.currentApplicantid + '=' + this.applicantId + '&' + this.label.currentUserId + '=' + this.currentUserId + '&' + this.label.mode + '=' + this.label.CustomerImageDocumentType + '&' + this.label.currentUserName + '=' + this.currentUserName + '&' + this.label.currentUserEmailid + '=' + this.currentUserEmailId + '&documentSide=' + this.documentSide
            }
        });
        this.isCancel = false; this.isDone = false;this.doneflagCustomerImage=true;
    }handleRefresh() {if (this.consentCount == 0) {this.successToast('Click on consent','','error');} else {otpConsentCheck({ applicantId: this.applicantId }) .then(result => {this.otprefreshresult = result;if (result == true) {this.changecolor();}}) .catch(error => {this.error = error;});}}
    checkWhatsappNumber(event) {this.registerWhatsAppValue = event.target.checked;if (this.registerWhatsAppValue) {this.successToast(this.label.noRegisteredWhatsAppBanking,'','success');}}
    @track homePageFlag = false;   
    handleHome() {
        this.homePageFlag = true;
        if (this.currentStep == this.label.userDetails) {
            let firstNameInput = this.template.querySelector('lightning-input[data-id=firstNameId]');
            let lastNameInput = this.template.querySelector('lightning-input[data-id=lastNameId]');
            let phoneNoInput = this.template.querySelector('lightning-input[data-id=phoneNumberId]');
            let agentBLCodeInput = this.template.querySelector('.agentCss');
            let whatsAppNumberInput;
            if (this.whatsAppNumberValue != '' || this.whatsAppNumberValue != null) {if (this.showCopiedWhatsAppNumber) {whatsAppNumberInput = this.template.querySelector('lightning-input[data-id=checkedWhatsAppNumberId]');
                } else {whatsAppNumberInput = this.template.querySelector('lightning-input[data-id=whatsAppNumberId]');}if (whatsAppNumberInput != null) {whatsAppNumberInput.reportValidity();}
            }firstNameInput.reportValidity();lastNameInput.reportValidity();phoneNoInput.reportValidity();agentBLCodeInput.reportValidity();
            if ((firstNameInput.validity.valid == true && lastNameInput.validity.valid == true&& phoneNoInput.validity.valid == true && agentBLCodeInput.validity.valid == true && whatsAppNumberInput.validity.valid == true)
                || (this.currentStep != 'User Details')) {this.handleSubmit();this.loanApplicationComponent = true;this.navigateToHomePage();}else if (firstNameInput.validity.valid != true || lastNameInput.validity.valid != true || phoneNoInput.validity.valid != true || agentBLCodeInput.validity.valid != true || whatsAppNumberInput.validity.valid != true) {                this.successToast('Mandotory details are not given.Please provide','','error');this.homePageFlag = false;return null;}
        }else if (this.currentStep != this.label.userDetails) {if (this.currentStep !== this.label.captureDedupe) {this.handleNext();}this.loanApplicationComponent = true;this.navigateToHomePage();}}
    navigateToHomePage() {
        isCommunity()
        .then(response => {if(response){
                this[NavigationMixin.Navigate]({type: 'standard__namedPage',attributes: {pageName: 'home'}, });} else {this[NavigationMixin.Navigate]({type: 'standard__navItemPage',attributes: {apiName: 'Home'} }); }}) .catch(error => { });   }
    nextFlagForFirstStep = false;consentDisable = false;isConsentRecieved=false;
    handleSubmit() {this.postOTPVerificationHandler();this.successToast('Details Saved','','success');}modalPopUpCaptureImage = false;
    ImageLoad() {this.modalPopUpCaptureImage = true;}closeModal() {this.modalPopUpCaptureImage = false;}
    @api modalPopUpToggleFlag = false;iconButton = false;customerImageDisable = false;
    changeValuePopup() {this.modalPopUpToggleFlag = false;this.isConsentRecieved=false;this.consentfirstTimeFlag=true;}changecolor() {this.iconButton = true;this.consentDisable = true;this.disableAll();this.isConsentRecieved=true;this.modalPopUpToggleFlag = false;}
    disableAll(){this.isDisabledTopUp=true;this.disableRegisterOnlineWhatsApp = true; this.disableRelEntity = true; this.disableBOC = true; this.disableRelationshipType = true;this.disablesharePercent = true;this.disablePOAHolder = true; this.disableFirsttName = true;this.disableLastName = true;if(this.currenttab==this.label.CoBorrower && this.productType=='TW' && !this.isConsentRecieved){this.disablePhoneNumber=false}else{this.disablePhoneNumber = true;}this.disableSamePhoneCheckBox = true;this.isWhatsAppNumberAccessible = true;this.disableAGBLCode = true; this.disableVehicle= true; /*CISP-3293*/if (this.iconButtonCaptureImage) { this.customerImageDisable = true; } this.disableEntityType = true; this.disableApplicationType = true; this.readonly = true;}
    // Start : Pop-UP on Image Upload Button
    popUpFlagDesktop = false;
    closeModal() {this.popUpFlagDesktop = false}
    handleCreateApplication() { //SFTRAC-536
        this.isLoading = true;
        checkRetryExhausted({
            loanApplicationId: this.recordid, attemptFor: 'Create Application Attempts', applicantId: this.applicantId, moduleName: 'Lead Details'
        })
        .then(response => {
            if (response === this.label.FailureMessage) {
                this.isLoading = false;
            } else if (response === this.label.Retry_Exhausted) {
                //If response is false and retry attempts are also exhausted,show toast message and disable the Bureau Pull button.
                this.createApplicationCross = true;
                this.createApplicationDisable = true;
                const evt = new ShowToastEvent({
                    title: 'Error',
                    message: response,
                    variant: 'error',
                });
                this.dispatchEvent(evt);
                this.isLoading = false;
            } else if (response === this.label.SuccessMessage) {
                console.log("createApplication API Integration : Start", this.applicantId, '', this.recordId);
                this.callCreateApplicationApi();
            }
        })
        .catch(error => {
            this.isLoading = false;
        });
    } 
    iconButtonCaptureUpload = false;docTypeforSelfie = 'Selfie';applicationIdfromDocAuth;flagforcreateApllicationId = true;imageUploadRedCross=false;
    handleimageUploadApi() {this.isLoading = true;
        doImageUploadCallout({ documentId: this.documentRecordId, imageType: this.docTypeforSelfie,loanAppId: this.recordid })
            .then(result => {
                let obj = JSON.parse(result);this.isLoading = false;const status=obj.ResponseData.Fields.Applicants.Applicant.Services.Service[0].Status;
                if (status == 'Pass') {this.updateSelfieUpload(true);this.isimageApiPositiveResponse=true;this.toastTitle='Image Upload '+status;this.successToast(this.toastTitle,null,'success');this.iconButtonCaptureUpload = true;
                }  else if (status === 'Fail') {this.updateSelfieUpload(false);this.successToast('Recapture Image','','warning');this.deleteImage(this.documentRecordId,false , true, this.documentToDelete,false);this.iconButtonCaptureImage=false;//to let the user recapture cust. image again
                    this.isimageApiPositiveResponse=false;this.customerImageDisable=false;
                }}).catch(error => {this.updateSelfieUpload(false);      this.isLoading = false;this.imageApiNoResponse=true;this.imageNoResponseCall();});}
    @track delaytime;imageUploadDisable=false;imageNoResponseCall(){
        this.successToast(this.label.RetrySelfe,'','warning');
        this.imageUploadDisable=true;
        getResendTime() .then(result => {this.delaytime=result;setTimeout(() => {this.imageUploadDisable = false;}, this.delaytime);//enable resent after timeout
        }) .catch(error => { this.error = error;});}
    handleSelfieUpload(){
        if (!this.iconButtonCaptureImage) {this.successToast(this.label.captureImageRequired,'','error');return null;}if (this.iconButtonCaptureImage == true) {selfieUpload({ applicantId: this.applicantId }).then(result => {let response = JSON.parse(result);if (response.status === 'false') {this.successToast('Error',response.message,'error');this.imageUploadRedCross=true;this.iconButtonCaptureUpload=false;this.imageUploadDisable=true;this.customerImageDisable=true;} else {if(!this.docAuthApiPositiveResponse){this.callCreateApplicationApi();} else {this.handleimageUploadApi();}}}).catch(error => {});
  }if (FORM_FACTOR == 'Large') {this.popUpFlagDesktop = true;this.section4 = true;}  }
    docAuthApiPositiveResponse=false;docAuthApiNoResponse=false;isimageApiPositiveResponse=false;imageApiNoResponse=false;
    callCreateApplicationApi() {//CISP-23118 for below lines commented.
        // this.isLoading = true;let text = null;
        // doDocAuthCreateApplicantCallout({ applicantId: this.applicantId,loanAppId: this.recordid }).then(result => {
        // const response = JSON.parse(result);
        // const status=response.ResponseData.Fields.Applicants.Applicant.Services.Service[0].Status;if (status == 'Pass') { 
        if (this.isNonIndividualBorrower) { 
            this.iconButtonCreateApplication = true; 
            this.createApplicationDisable = true; 
        } 
    // this.applicationIdfromDocAuth = response.ResponseData.ResponseInfo.ApplicationId;
    // text = this.applicationIdfromDocAuth.toString();
    // this.updatedocApplication(text);
    this.flagforcreateApllicationId = true;
    this.isLoading = false;
    this.toastTitle="Image captured successfully, will be validated by CMU";this.successToast(this.toastTitle,null,'success');
    this.docAuthApiPositiveResponse=true;
    this.createApplicationDisable = true;
    this.iconButtonCaptureUpload = true;
    this.imageUploadDisable = true;
    //if(!this.isNonIndividualBorrower){this.isLoading=true;setTimeout(() => {this.isLoading=false;this.handleimageUploadApi();}, 10000);}} else{this.isLoading = false;this.successToast('Warning',status + ' Response','warning');}}) .catch(error => {this.docAuthApiNoResponse=true;this.isLoading = false;this.successToast('Kindly Retry','','warning');}); 
 }
    updatedocApplication(text){const applicantsFields = {};applicantsFields[APP_ID_FIELD.fieldApiName] = this.applicantId;applicantsFields[DocAuth_Application_Id.fieldApiName] = text;this.updateRecordDetails(applicantsFields);}
    uploadKYCFiles() {this.toastTitle='Success';this.message=this.label.kycDetailsUploaded;this.successToast(this.toastTitle,this.message,'success');}
    //Added By Naga Puppala start
    incomeSrcValue = '';declaredIncome = '';loanAmount = '';
    validateIncomeField(event) {if (event.keyCode === 69 || event.keyCode == 75 || event.keyCode == 66 || event.keyCode == 84 || event.keyCode == 190) {event.preventDefault();}const value = event.target.value;if (value && (!/^[0-9]+$/.test(value) || event.keyCode == 0)) {this.declaredIncome = value.replace(/\D/g, ''); }}
    validateInput(event) {let declaredIncome = event.target.value;this.declaredIncome = declaredIncome;let elem = this.template.querySelector(".incomeDec");elem.setCustomValidity("");if (declaredIncome && ((declaredIncome < parseInt(this.labelCustom.Income5000) && !this.isTractor) || ((declaredIncome > parseInt(this.labelCustom.Income5000000)) && this.entityType == 'Individual' && this.isTractor))){elem.setCustomValidity(this.labelCustom.Incomemessage);}elem.reportValidity();}
    validateLoanAmountField(event) {if (event.keyCode === 69 || event.keyCode === 77 || event.keyCode == 75 || event.keyCode == 66 || event.keyCode == 84) {event.preventDefault();}}
    validateLoanAmt(event) {let loanAmount = event.target.value;this.loanAmount = loanAmount;let elem = this.template.querySelector(".loanAmt");elem.setCustomValidity("");if (this.productType == 'TW') {if (loanAmount && (loanAmount < parseInt(this.labelCustom.Loanamount10000) || loanAmount > parseInt(this.labelCustom.Loanamount175000))) {elem.setCustomValidity(Amountmessage);}} else {if (loanAmount && (loanAmount < parseInt(this.labelCustom.LoanAmount50000) || loanAmount > parseInt(this.labelCustom.LoanAmount200000000))) {elem.setCustomValidity(Amountmessage);}}elem.reportValidity();}//CISP-2701 - START (JS)
    disableAadharButton01 = false;disablePassportButton01 = false;disableVoterIdButton01 = false;disableDLButton01 = false;nextFlagForSecondStep = false;selectedValueCurrentAdd = false;checkBoxValue = false;
    currentAddressHandler(event) {this.checkBoxValue = event.target.checked;this.selectedValueCurrentAdd = event.target.checked;if (this.checkBoxValue) {this.nextFlagForSecondStep = true;this.disableAadharButton01 = true;this.disablePassportButton01 = true;this.disableVoterIdButton01 = true;this.disableDLButton01 = true;} else {this.disableAadharButton01 = false;this.disablePassportButton01 = false;this.disableVoterIdButton01 = false;this.disableDLButton01 = false;}const applicantsFields = {};applicantsFields[APP_ID_FIELD.fieldApiName] = this.applicantId;applicantsFields[CURRENT_ADDRESS_NOT_PRESENT.fieldApiName] = this.checkBoxValue;applicantsFields[IS_ADDRESS_DECLARATION.fieldApiName]=this.checkBoxValue;this.updateRecordDetails(applicantsFields)
    }currentPermanentcheckBoxValue;
    permanentCurrentAddressCheckbox(event) {this.currentPermanentcheckBoxValue = event.target.checked;const applicantsFields = {};applicantsFields[APP_ID_FIELD.fieldApiName] = this.applicantId;applicantsFields[CURRENT_SAME_AS_PERMANENT.fieldApiName] = this.currentPermanentcheckBoxValue;this.updateRecordDetails(applicantsFields);
    }
    nextFlagForThirdStep = false;selectedValuePermanentAdd = false;disableAadharButton02 = false;disablePassportButton02 = false;disableVoterIdButton02 = false;disableDLButton02 = false;
    permanentAddressHandler(event) {this.checkBoxValuePermanent = event.target.checked;const applicantsFields = {};applicantsFields[APP_ID_FIELD.fieldApiName] = this.applicantId;applicantsFields[PERMANENT_ADDRESS_NOT_PRESENT.fieldApiName] = this.checkBoxValuePermanent;this.updateRecordDetails(applicantsFields);if (this.checkBoxValuePermanent) {this.nextFlagForThirdStep = true;this.selectedValuePermanentAdd = true;this.disableAadharButton02 = true;this.disablePassportButton02 = true;this.disableVoterIdButton02 = true;this.disableDLButton02 = true;this.disableCurrentPermntSameAddr = true;} else {this.nextFlagForThirdStep = false;this.disableAadharButton02 = false;this.disablePassportButton02 = false;this.disableVoterIdButton02 = false;this.disableDLButton02 = false;this.selectedValuePermanentAdd = false;this.disableCurrentPermntSameAddr = true;}}
    verifyVehicleStatus(event) {this.verifyChecked = event.detail;}
    verifyButtonStatus(event) {this.verifyButton = event.detail;}
    vehicleVerifiedStatus(event) {this.vehicleVerified = event.detail;}
    vehicleSelectedType(event) {this.vehicleType = event.detail;}
    handleEligibility() {this.disablePrev = true;this.disableNext = true;}
    handleScreen(event) {const screenEvent = new CustomEvent("addscreendata", {detail: event.detail});this.dispatchEvent(screenEvent);}
    successToast(toastTitle,message,variant){if(message==null) { message=''; }const evt = new ShowToastEvent({title: toastTitle,message: message,variant: variant,});this.dispatchEvent(evt);}
    disableImage(){this.customerImageDisable=true;this.imageUploadDisable=true;}
    async updateOpportunity(){const oppFields = {};oppFields[OPP_ID_FIELD.fieldApiName] = this.currentOppRecordId;oppFields[AGENT_BL_CODE_FIELD.fieldApiName] = this.agentBLCodeLabel; if(this.isTractor){oppFields[CUSTOMER_TYPE_FIELD.fieldApiName] = this.entityType; oppFields[LOAN_APPLICATION_TYPE_FIELD.fieldApiName] = this.applicationTypeVal;} oppFields[PRODUCT_TYPE_FIELD.fieldApiName] = this.productType == 'TW' ? 'Two Wheeler' : this.productType == 'PV' ? 'Passenger Vehicles' : 'Tractor';oppFields[OPP_ACCOUNT.fieldApiName] = this.agentBLCodeValue;oppFields[LEAD_NUMBER_FIELD.fieldApiName] = this.leadNumber.data; 
    if(this.isTractor){oppFields[ENTITY_NAME_FIELD.fieldApiName] = this.loan.Entity_Name__c;oppFields[ENTITY_TYPE_FIELD.fieldApiName] = this.loan.Entity_Type__c;oppFields[ENTITY_CATEGORY_FIELD.fieldApiName] = this.loan.Entity_Category__c;oppFields[CONTACT_PERSON_FIELD.fieldApiName] = this.loan.Contact_Person_Name__c;oppFields[LEAD_SOURCE_FIELD.fieldApiName] = this.loan.Lead_Source_Non_Ind__c;oppFields[CLASS_OF_ACTIVITY_FIELD.fieldApiName] = this.loan.Class_of_Activity__c;oppFields[LOAN_TYPE_FIELD.fieldApiName] = this.loan.Loan_Type__c;oppFields[EVALUATION_TYPE_FIELD.fieldApiName] = this.loan.Evaluation_Type__c;oppFields[MAJORINDUSTRY_TYPE_FIELD.fieldApiName] = this.loan.Major_Industry__c;oppFields[MINORINDUSTRY_TYPE_FIELD.fieldApiName] = this.loan.Minor_Industry__c; oppFields[PROFILE_FIELD.fieldApiName] = this.loan.Profile__c;oppFields[OPP_TopUpLoan.fieldApiName] = this.isTopUpChecked;}
    if(this.currenttab == this.label.Borrower){oppFields[APPLICANT_NAME_FIELD.fieldApiName] = this.firstNameValue + ' ' + this.lastNameValue;}oppFields[OPP_ACCOUNT.fieldApiName] = this.agentBLCodeValue; oppFields[OPP_VEHICLETYPE.fieldApiName] = this.vehicleTypeval;/*CISP-3293 */  await this.updateRecordDetails(oppFields);}//CISP-2701 - END (JS)
    async goToCaptureDedupe(){if(this.currentStageName === 'Loan Initiation' && this.lastStage === 'Loan Initiation' && !this.isNonIndividualBorrower) {await poaTagging({ applicantId: this.applicantId });this.callCibilTextMatchAPI();}this.currentStep = this.label.captureDedupe;this.isStepFour = false;this.isStepFive = true;const applicantsFields = {};applicantsFields[APP_ID_FIELD.fieldApiName] = this.applicantId;applicantsFields[APPLICANT_SUBSTAGE.fieldApiName] = this.label.captureDedupe;this.updateRecordDetails(applicantsFields);}
    async disableEverything(){let allElements = this.template.querySelectorAll('*');allElements.forEach(element =>element.disabled = true);}// this.isEnableNextval=true;//CISP-2664
    olaIncomeValidation(){if(this.leadSource=='OLA' && this.declaredIncome<100000 && this.declaredIncome>0){this.isModalOpenForIncome=true;}}
    stopJourney(){
        const oppFields = {};oppFields[OPP_ID_FIELD.fieldApiName] = this.recordid;oppFields[OPP_JOURNEY_STATUS.fieldApiName] = 'Stop';this.updateRecordDetails(oppFields);
        this.successToast('Journey Stoped!','','error');this.disableNext = true;this.disablePrev = true;this.isModalOpenForIncome=false;}//OLA-163
    clearIncomedata(){this.declaredIncome=null;this.isModalOpenForIncome=false;}
    topupChangeHandler(event){this.isTopUpChecked = event.target.checked;}
}