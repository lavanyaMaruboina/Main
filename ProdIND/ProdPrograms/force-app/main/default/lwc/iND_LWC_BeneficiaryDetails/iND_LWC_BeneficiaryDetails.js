import { LightningElement, track, api, wire } from 'lwc';
import * as helper from './iND_LWC_BeneficiaryDetailsHelper';
import { NavigationMixin } from 'lightning/navigation';
import { loadStyle } from "lightning/platformResourceLoader";
import { updateRecord } from 'lightning/uiRecordApi';
import Beneficiary_Details from '@salesforce/label/c.Beneficiary_Details'; 
import DuplicateDealNumber from '@salesforce/label/c.DuplicateDealNumber';
import CustomerNotFound from '@salesforce/label/c.CustomerNotFound';
import Disbursement from '@salesforce/label/c.Disbursement';
import Adjustment from '@salesforce/label/c.Adjustment';
import ACH_SI_only_for_Physical_ACH_SI from '@salesforce/label/c.ACH_SI_only_for_Physical_ACH_SI';
import AccountNoAlreadyExistMsg from '@salesforce/label/c.AccountNoAlreadyExistMsg';
import Seller_Bank_Details from '@salesforce/label/c.Seller_Bank_Details';
import handleBeneficiaryDetailsSubmit from '@salesforce/apex/LoanDisbursementController.handleBeneficiaryDetailsSubmit';
import CalculateDealerPayment from '@salesforce/apex/LoanDisbursementController.calculateDealerPayment';
import getBeneficiaryDetails from '@salesforce/apex/LoanDisbursementController.getBeneficiaryDetails';
import GetSellerBankDetails from '@salesforce/apex/LoanDisbursementController.getSellerBankDetails';
import getUploadedDocuments from '@salesforce/apex/LoanDisbursementController.getUploadedDocuments';
import getBenifRecord from '@salesforce/apex/LoanDisbursementController.getBenifRecord';
import isCasaConsentReceived from '@salesforce/apex/LoanDisbursementController.isCasaConsentReceived';
import mandotoryDetailsNotProvide from '@salesforce/label/c.Mandotory_details_are_not_given_Please_provide';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import doCustomerNameSearchCallout from '@salesforce/apexContinuation/IntegrationEngine.doCustomerNameSearchCallout';
import doPactLmsCallout from '@salesforce/apex/IntegrationEngine.doPactLmsCallout';
import doDMSUploadCallout from '@salesforce/apexContinuation/IntegrationEngine.doDMSUploadCallout';
import doSmsCallout from '@salesforce/apex/IntegrationEngine.doSmsGatewayAPI';
import UserPreferencesRecordHomeSectionCollapseWTShown from '@salesforce/schema/User.UserPreferencesRecordHomeSectionCollapseWTShown';
import LightningCardApplyCSS from "@salesforce/resourceUrl/loanApplication";
import isAcctNumberPresentInBenMaster from '@salesforce/apex/LoanDisbursementController.isAcctNumberPresentInBenMaster';
import DealerPaymentError from '@salesforce/label/c.Dealer_Payment_Error';
import DealerPaymentErrorV2 from '@salesforce/label/c.Dealer_Payment_Error_V2';
import DealerPaymentErrorV3 from '@salesforce/label/c.Dealer_Payment_Error_V3';
import APPLICANT_ID from '@salesforce/schema/Applicant__c.Id';
import Borrower from '@salesforce/label/c.Borrower';
import CoBorrower from '@salesforce/label/c.CoBorrower';
import CASA_FORM_SMS_SENT from '@salesforce/schema/Applicant__c.CASA_Form_SMS_Sent__c';
import APPLICANT_CASAConsentOTP from '@salesforce/schema/Applicant__c.CASA_Consent_OTP__c';
import Consent_Sent_Successfully from '@salesforce/label/c.Consent_Sent_Successfully';
import GETCUSTOMERBTNMANDATORYERROR from '@salesforce/label/c.GetCustomerBtnMandatoryError';
import isPaymentRequestGenerated from '@salesforce/apex/LoanDisbursementController.isPaymentRequestGenerated';
//Modified for D2C by Rohan
import { getRecord } from 'lightning/uiRecordApi';
import OPP_LEAD_SORCE from '@salesforce/schema/Opportunity.LeadSource';
//End of D2C Code
import isPACTLMSIntegrationLogGenerated from '@salesforce/apex/LoanDisbursementController.isPACTLMSIntegrationLogGenerated';
import fetchLoanDetails from '@salesforce/apex/IND_LWC_LoanDetailsCntrl.fetchLoanDetails';//Ola integration changes
import isTVRCaseCompleted from '@salesforce/apex/LoanDisbursementController.isTVRCaseCompleted';
import IsTVRPassed from '@salesforce/label/c.IsTVRGenerated';
import isRevokedLead from '@salesforce/apex/LoanDisbursementController.isRevokedLead';
import getFICaseListRecord from '@salesforce/apex/LoanDisbursementController.getFICaseListRecord';//SFTRAC-163
import updateCaseFIRecords from '@salesforce/apex/LoanDisbursementController.updateCaseFIRecords';//SFTRAC-163
import getCamRecord from '@salesforce/apex/LoanDisbursementController.getCamRecord';//SFTRAC-163
import updateCaseAVRecords from '@salesforce/apex/LWCLOSAssetVerificationCntrl.updateCaseAVRecords';
import doRCLimitCheckCalloutForDSAOrDealer from '@salesforce/apexContinuation/IntegrationEngine.doRCLimitCheckCalloutForDSAOrDealer';//CISP-8762
import saveRCLimitResponseDetails from '@salesforce/apex/IND_VehicleInspectionRCLimitDetails.saveRCLimitResponseDetails';//CISP-8762
import savecontinueWithRCLimitvalue from '@salesforce/apex/IND_VehicleInspectionRCLimitDetails.savecontinueWithRCLimitvalue';//CISP-8762
import saveRCLimitResponseDetailsForDSA from '@salesforce/apex/IND_VehicleInspectionRCLimitDetails.saveRCLimitResponseDetailsForDSA';//CISP-8762
import savecontinueWithRCLimitvalueForDSA from '@salesforce/apex/IND_VehicleInspectionRCLimitDetails.savecontinueWithRCLimitvalueForDSA';//CISP-8762
import dsaPaymentDisbaling from '@salesforce/apex/LoanDisbursementController.dsaPaymentDisbaling';//CISP-13118
import CAM_ID from '@salesforce/schema/CAM__c.Id';
import CAM_APPROVAL_DATE from '@salesforce/schema/CAM__c.CAM_Approval_Date__c';
import Action_Taken from '@salesforce/schema/CAM__c.Action_Taken__c';
import Proposal_Status from '@salesforce/schema/CAM__c.Proposal_Status__c';
import Is_CAM_Reopen from '@salesforce/schema/CAM__c.Is_CAM_Reopen__c';
import isChildLeadClosed from '@salesforce/apex/LoanDisbursementController.isChildLeadClosed';//SFTRAC-172
import checkCIBILFetchDate from '@salesforce/apex/LoanDisbursementController.checkCIBILFetchDate';
export default class IND_LWC_BeneficiaryDetails extends NavigationMixin(LightningElement) {
    @api dealId  = '';
    isDealerEnabled = false;isDSAEnabled = false;
    financeAmountForRcLimit = 0 ; @track isLoading = false; @track isPVUsedRefinanceDealer = false; @track isPVUsedRefinanceDSA = false;@track rcLimitDealerName; @track vehicleRecordId;noOfProposalsAvailable;availableDisbursalAmount;noOfDaysRCPending;continueWithRCLimit;@track finalTermRecordId;noOfProposalsAvailableForDSA;availableDisbursalAmountForDSA;noOfDaysRCPendingForDSA;continueWithRCLimitForDSA; @track showBodyChassisInfo = false;//CISP-8762
    @track isReadOnlyDealer ; @track isReadOnlyDSA;//CISP-8762
    @api recordid;
    @api disbursementrecordid;
    @api applicantid;
    @api loanapplicantdetails;
    @api disablefields;
    //   CISP-4770 - START 
    @api frompostsanction = false;
      // CISP-4770 - END 
    //Ola Integration changes 
    @track leadSource;
    finalCRMIRR;isTWRefinace = false;requiredLoanAmount;finaltermRec;serviceCharges;
    dealerPaymentLabel = 'Dealer Payment';
    label = {
        Beneficiary_Details,
        Disbursement,
        Adjustment,
        ACH_SI_only_for_Physical_ACH_SI,
        Seller_Bank_Details,
        DuplicateDealNumber,
        CustomerNotFound,
        mandotoryDetailsNotProvide,
        Consent_Sent_Successfully
    };

    @track isCustomNameFieldDisable = true;
    @track isEnableUploadViewDoc = true;
    @track isSpinnerMoving = false;
    @track phyMandateDispToKarapakkam;
    @track bankName;
    @track accountNumber;
    @track bankBranchName;
    @track bankBranchPincode;
    @track bankBranchIFSCCode;
    @track dealerPayment;
    @track dsaName;
    @track paymentToDSA = false;
    @track paymentToBuilder = false;
    @track paymentToDealer = false;

    get disableDealer() {
        return this.paymentToBuilder;
    }
    get disableBuilder() {
        return this.paymentToDealer;
    } 

    @track diableCoborrower =false; //CISP-3550
    @track disablepaymenttocoborrowe =true; //CISP-3550
    @track isSellerSectionEnabled = false;  
    @track coborrowerName;
    @track paymentToCoborrower = false;
    @track adjustmentDetails = [];
    @track adjDealNumber1;
    @track customerName1;
    @track adjAmount1 = 0;
    @track adjDealNumber2;
    @track customerName2;
    @track adjAmount2 = 0;
    @track adjDealNumber3;
    @track customerName3;
    @track adjAmount3 = 0;
    @track adjDealNumber4;
    @track customerName4;
    @track adjAmount4 = 0;
    @track adjDealNumber5;
    @track customerName5;
    @track adjAmount5 = 0;
    @track adjDealNumber6;
    @track customerName6;
    @track adjAmount6 = 0;
    @track adjDealNumber7;
    @track customerName7;
    @track adjAmount7 = 0;
    @track adjDealNumber8;
    @track customerName8;
    @track adjAmount8 = 0;
    @track totalAdjAmount;
    //CISP-2629-START
    @track customerCode1 = '';
    @track customerCode2 = '';
    @track customerCode3 = '';
    @track customerCode4 = '';
    @track customerCode5 = '';
    @track customerCode6 = '';
    @track customerCode7 = '';
    @track customerCode8 = '';
    //CISP-2629-END
    @track disableAdjustmentFields = false;

    @track beneficiaryName1 = '';
    @track beneficiaryAmount1 = 0;
    @track beneficiaryAccNo1 = '';
    @track beneficiaryName2 = '';
    @track beneficiaryAmount2 = 0;
    @track beneficiaryAccNo2 = '';
    @track beneficiaryName3 = '';
    @track beneficiaryAmount3 = 0;
    @track beneficiaryAccNo3 = '';
    @track beneficiaryName4 = '';
    @track beneficiaryAmount4 = 0;
    @track beneficiaryAccNo4 = '';
    @track totalBeneficiaryAmount;

    @track isbeneficiaryAccNo1Disabled = false;
    @track isbeneficiaryAccNo2Disabled = false;
    @track isbeneficiaryAccNo3Disabled = false;
    @track isbeneficiaryAccNo4Disabled = false;

    @track balanceTransferAmountInRs;


    borrowerconsentRecived;
    coborrowerconsentRecived;


    @track beneficiaryDocumentId;
    @track dataResult;
    @track modalPopUpPassbook = false;
    @track modalPopUpAccountStatement = false;
    @track modalPopUpCancelledCheque = false;
    @track disableDSA = false;  
    @track loanAppVehicleSubCategory = '';
    @track isUsedVehicle = false;
    @track isNewVehicle = false;
    @track isUsedVehicleOnly = false;

    @track beneficiary1NameOptions = [];
    @track paymentOrgFrom;
    @track beneficiary2NameOptions = [];
    @track beneficiary3NameOptions = [];
    @track beneficiary4NameOptions = [];

    // @track isDisableBeneficiaryName1 = false;
    // @track isDisableBeneficiaryName2 = false;
    // @track isDisableBeneficiaryName3 = false;
    // @track isDisableBeneficiaryName4 = false;

    @track isDisableBeneficiaryAmount1 = false;
    @track isDisableBeneficiaryAmount2 = false;
    @track isDisableBeneficiaryAmount3 = false;
    @track isDisableBeneficiaryAmount4 = false;

    @track sellerBankDetails;
    @track isSellerBankFieldDisabled = false;
    @track balanceTransfer;

    @track isVehicleDoc = true;
    @track isAllDocType = false;
    @track showUpload = true;
    @track showPhotoCopy = false;
    @track docType;
    @track uploadFileFlag = false;
    @track uploadDocFlag;
    @track uploadViewFileFlag = false;
    @track docList;
    @track documentRecordId;
    @track ihmRecoveryAmount = 0;
    @track financeAmount = 0;
    @track ihmPaidToDealer = 0;
    @track loanAppVehicleType = '';
    @track loanAppProductType = ''
    disableReTriggerPR = true;
    source ='';
    tVRCaseCheck = false;
    disabledSubmit = false;
    isRevokedLead;
    whoWillRepayLoan;
    disabledUploadBranchApproval = false;//CISP-14380
    paymentToDsaPhase;//CISP-16182
    isModalOpen = false;
    caseList;
    fIList;
    isCaseFI = false;
    isTractor = false;
    isCibilPulled = false;
    isCamApproval =false;
    isReapprovalOfCam = false;
    camRecId;
    isBorrowerCibilSucess = true;
    isCoBorrowerCibilSucess = true;
    borrowerCibiRecord;
    coBorrowerCibilRecord;
    borrowerId;
    coBorrowerId;
    coBorrowerCibilList;
    isFieldInvsNotCompleted = false;
    isCamApprovalNotCompleted = false;
    isAssetVerFailed = false;
    assetVerFailedList;
    isAssetVerExceeded = false;
    modalHeader;
       //CISP-20786
   showemidropdown = true;sfAmortSchedule=[];offerAPIAmortSchedule=[];isTriggerDeviationSuccess = false;isTriggerDeviationBtnClicked = false;isISModalOpen = false; isInsSubmitted = false;invoiceTaxDate;paymentMadeOnValue;firstEMIdueDate;secEMIdueDate;crmIRR;grossIRR;netIRR;inputedIRR;emiValue;isOfferEngineSuccess=false;crmIRR;netIRR;grossIRR;emiValue;imputedIRR;isInstallmentScBtnShown=true;disableViewDeviations = false;isMultipleClicked = false;valuesPassedToChild={};isPv;isTw;maxcrm;mincrm;minImputedCrm;maxImputedCrm;isIRRValidate=true;maxgross;mingross;productSegment;emidatelist=[];isIrrComparisionDesaibled = true;irrSanctionObj;irrOfferEngineObj;irrComBtnClicked = false;isDisabledTriggerIRR = true;fistEmiAPIValue;secondEmiAPIValue;finaltermRec;isPaymentMadeDisabled = false;offerEngineRes;isPaymentEMIChanged = false;isOfferEngineClicked = false;firstDueDate;secondDueDate;loanDealDate;isPaymentMadeOnInvalid = false;previousEngineData;newEngineData;leadSource;showRevokeModal = false;showUserSelectionLookupOnRevoke = false;isD2C=false;revokeData = {};showUserSelectionLookupOnRevoke = false;benName;benCode;isUserSelected = false;selectedUserId;selectedUserName;ph1TWRevokeErr;isRevokedDisabled = true;camNetImputtedIRR;isOfferEngineDisabled = false; installmentTypeValue; //CISP-20786
 //Added for D2C
 @wire(getRecord, { recordId: '$recordid', fields: [OPP_LEAD_SORCE] })
 opportunity({ error, data }) {
   if (data) {
    console.log('d@c--'+data.fields.LeadSource.value);
     this.source=data.fields.LeadSource.value;
     this.disabledSMSResnd= this.source==='D2C'? true:false;
     console.log('this.source--'+this.source);
   } else if (error) {
      console.log('error-->'+JSON.stringify(error));
   }
 }

 get disableMandate () {
    return (this.source==='D2C') || this.disablefields;
 }
//end of D2C code

    get acceptedFormats() {
        return ['.pdf', '.png', '.jpg'];
    }
    async connectedCallback() {
        await getCamRecord({'loanApplicationId':this.recordid}).then(result =>{
            if(result){
                this.camRecId = result;
            }
        });
        await isRevokedLead({'loanApplicationId':this.recordid}).then(result=>{
            if(result){ this.isRevokedLead = true; }
        });
        await fetchLoanDetails({ opportunityId: this.recordid, dealId: this.dealId }).then(result => {
            if(result?.loanApplicationDetails){this.leadSource = result?.loanApplicationDetails[0]?.LeadSource;}
        }).catch(error =>{});
        let data = await getBeneficiaryDetails({ parentLoanAppId: this.recordid, 'dealId' : this.dealId })

            this.dataResult = data;
            console.log('this.getDataResult', this.dataResult);

            for (let index = 1; index <= 8; index++) {
                this.adjustmentDetails.push({ id: index, adjAmountDataId: 'adjAmount' + index + 'Field', adjDealNumberDataId: 'adjDealNumber' + index + 'Field', customerNameDataId: 'customerName' + index + 'Field', dealNo: '', customerName: '', adjustedAmount: '', notFound: false, processed: false, customerCode:'' });//CISP-2629 -Added customerCode attribute
            }

            if (this.dataResult) {
                let result = JSON.parse(JSON.stringify(this.dataResult));
                console.debug('in success', result);

                await helper.onLoadHelper(this,result);/** CISP-20786 moved to helper*/


                if(result.loanAppVehicleType.includes('Used')){
                    this.isUsedVehicleOnly = true;
                }
                if (result.loanAppVehicleType.includes('Used') || result.loanAppVehicleType.includes('Refinance')) {
                    this.isUsedVehicle = true;
                    this.isNewVehicle = false;
                } else {
                    this.isUsedVehicle = false;
                    this.isNewVehicle = true;
                }
                if(result.loanAppVehicleType.includes('Used') || result.loanAppVehicleType.includes('Refinance') && result.loanAppProductType.includes('Passenger Vehicles')){
                    this.dealerPaymentLabel = 'Disbursement Amount';
                    }//CISP-8762 start
                if((result.loanAppVehicleType.includes('Used') || result.loanAppVehicleType.includes('Refinance')) && result.loanAppProductType.includes('Passenger Vehicles') && result.rcLimitEnabledDealer == true){
                    this.isPVUsedRefinanceDealer = true;
                }
                if((result.loanAppVehicleType.includes('Used') || result.loanAppVehicleType.includes('Refinance')) && result.loanAppProductType.includes('Passenger Vehicles') && result.rcLimitEnabledDSA == true){
                    this.isPVUsedRefinanceDSA = true;this.disableDSA = true;//CISP-11212
                }//CISP-8762 end
                console.log('OUTPUT continueWithRCLimitForDSA : ',this.continueWithRCLimitForDSA);
                CalculateDealerPayment({ loanAppId: this.recordid, vehicleType: result.loanAppVehicleType, 'dealId' : this.dealId }).then(response => {
                    console.log('CalculateDealerPayment response ', response);
                    if(this.disablefields){
                        this.dealerPayment = result.dealerPayment;
                    }else{
                        this.dealerPayment = response;
                    }
                }).catch(error => {
                    this.tryCatchError = error;
                    console.debug(this.tryCatchError);
                });
                this.phyMandateDispToKarapakkam = result.phyMandateDispToKarapakkam;
                this.disbursementrecordid = result.loanDisbursementDetailId;
                this.dealershipNature = result.dealershipNature;
                this.whoWillRepayLoan = result.whoWillRepayLoan;
                if (this.isNewVehicle) {
                    console.log('isNewVehicle');
                    this.isDisableBeneficiaryAmount1 = true;
                    this.isbeneficiaryAccNo1Disabled = true;
                    this.isbeneficiaryAccNo2Disabled = true;
                    this.isDisableBeneficiaryAmount2 = true;
                    this.isbeneficiaryAccNo3Disabled = true;
                    this.isDisableBeneficiaryAmount3 = true;
                    this.isbeneficiaryAccNo4Disabled = true;
                    this.isDisableBeneficiaryAmount4 = true;

                    this.primaryApplicantId = result.primaryApplicantId;
                    console.log('primaryApplicantWillingnessforAccOpening', result.primaryApplicantWillingnessforAccOpening);
                    this.primaryApplicantWillingnessforAccOpening = result.primaryApplicantWillingnessforAccOpening;
                    this.secondaryApplicantId = result.secondaryApplicantId;
                    this.secondaryApplicantWillingnessforAccOpening = result.secondaryApplicantWillingnessforAccOpening;
                    console.log('secondaryApplicantWillingnessforAccOpening', result.secondaryApplicantWillingnessforAccOpening);
                    if ((this.secondaryApplicantWillingnessforAccOpening && this.secondaryApplicantWillingnessforAccOpening != '' && this.secondaryApplicantWillingnessforAccOpening != undefined) && 
                        (!result.coborrowerconsentRecived) && this.whoWillRepayLoan == 'Co-borrower'){
                        console.log('inside 1 iff');
                        this.disabledSubmit = true;
                        this.disabledSMSResnd = false;
                    }
                    else if((this.primaryApplicantWillingnessforAccOpening && this.primaryApplicantWillingnessforAccOpening != '' && this.primaryApplicantWillingnessforAccOpening != undefined) &&
                        (!result.borrowerconsentRecived ) && this.whoWillRepayLoan == 'Borrower'){
                        console.log('inside 2 iff');
                        this.disabledSubmit = true;
                        this.disabledSMSResnd = false;
                    }else if (result.borrowerconsentRecived || result.coborrowerconsentRecived) {
                        console.log('inside 1 else iff');
                        this.disabledSMSResnd = true;
                        this.disabledSubmit = false;
                    }else if(!this.primaryApplicantWillingnessforAccOpening &&  !this.secondaryApplicantWillingnessforAccOpening){
                        console.log('inside 2 else iff');
                        this.disabledSMSResnd = true;
                        this.disabledSubmit = false;
                    }
                    console.log('this.borrowerconsentRecived=>', result.borrowerconsentRecived + ' ' + 'this.coborrowerconsentRecived', result.coborrowerconsentRecived);

                    this.borrowerconsentRecived =  result.borrowerconsentRecived
                    this.coborrowerconsentRecived = result.coborrowerconsentRecived;

                    console.log('this.disabledSMSResnd=>', this.disabledSMSResnd + ' ' + 'this.disabledSubmit', this.disabledSubmit);

                    this.beneficiaryName1 = result.paymentToBeMade; //Invoice_Details__c.Payment_to_be_made__c
                    // this.beneficiaryAccNo1 = 23456345;
                    this.beneficiaryAmount1 = (result.invoiceAmountInclDiscount == undefined ? 0 : result.invoiceAmountInclDiscount) - (result.totalIHMPaidToDealer == undefined ? 0 : result.totalIHMPaidToDealer); //Invoice_Details__c.Invoice_Amount_incl_discounts__c - IHM__c.Total_IHM_paid_to_dealer_A__c
                    // this.phyMandateDispToKarapakkam = result.phyMandateDispToKarapakkam;
                    // this.dealerPayment = result.dealerPayment;
                    if(this.leadSource=='OLA'){
                        this.beneficiaryName1 = result.beneficiaryName1;
                        this.beneficiaryName2 = result.beneficiaryName2;
                        this.beneficiaryAccNo1 = result.beneficiaryAccNo1;//OLA-107
                        this.beneficiaryAccNo2 = result.beneficiaryAccNo2;//OLA-107 
                        this.beneficiaryAmount1 = result.beneficiaryAmount1;
                        this.beneficiaryAmount2 = result.beneficiaryAmount2;   
                    }

                    this.paymentToBuilder = result.paymentToBuilder;
                    this.paymentToDealer = result.paymentToDealer;

                    this.calculateTotalBeneficiaryAmount();
                } else {
                    this.dealerName = result.dealerName;
                    this.finalTermReferrerName = result.finalTermReferrerName;
                    this.loanDisbursementDetailsVehicleSoldBy = result.loanDisbursementDetailsVehicleSoldBy;
                    this.primaryApplicantName = result.primaryApplicantName;
                    this.primaryApplicantId = result.primaryApplicantId;
                    console.log('primaryApplicantWillingnessforAccOpening', result.primaryApplicantWillingnessforAccOpening);
                    this.primaryApplicantWillingnessforAccOpening = result.primaryApplicantWillingnessforAccOpening;
                    this.secondaryApplicantName = result.secondaryApplicantName;
                    this.secondaryApplicantId = result.secondaryApplicantId;
                    this.secondaryApplicantWillingnessforAccOpening = result.secondaryApplicantWillingnessforAccOpening;
                    console.log('secondaryApplicantWillingnessforAccOpening', result.secondaryApplicantWillingnessforAccOpening);
                    if ((this.secondaryApplicantWillingnessforAccOpening && this.secondaryApplicantWillingnessforAccOpening != '' && this.secondaryApplicantWillingnessforAccOpening != undefined) && 
                        (!result.coborrowerconsentRecived) && this.whoWillRepayLoan == 'Co-borrower'){
                        console.log('inside 1 iff');
                        this.disabledSubmit = true;
                        this.disabledSMSResnd = false;
                    }
                    else if((this.primaryApplicantWillingnessforAccOpening && this.primaryApplicantWillingnessforAccOpening != '' && this.primaryApplicantWillingnessforAccOpening != undefined) &&
                        (!result.borrowerconsentRecived ) && this.whoWillRepayLoan == 'Borrower'){
                        console.log('inside 2 iff');
                        this.disabledSubmit = true;
                        this.disabledSMSResnd = false;
                    }else if (result.borrowerconsentRecived || result.coborrowerconsentRecived) {
                        console.log('inside 1 else iff');
                        this.disabledSMSResnd = true;
                        this.disabledSubmit = false;
                    }else if(!this.primaryApplicantWillingnessforAccOpening &&  !this.secondaryApplicantWillingnessforAccOpening){
                        console.log('inside 2 else iff');
                        this.disabledSMSResnd = true;
                        this.disabledSubmit = false;
                    }
                    console.log('this.borrowerconsentRecived=>', result.borrowerconsentRecived + ' ' + 'this.coborrowerconsentRecived', result.coborrowerconsentRecived);
                    console.log('this.disabledSMSResnd=>', this.disabledSMSResnd + ' ' + 'this.disabledSubmit', this.disabledSubmit);

                    this.borrowerconsentRecived =  result.borrowerconsentRecived
                    this.coborrowerconsentRecived = result.coborrowerconsentRecived;

                    this.balanceTransfer = result.balanceTransferAmountInRs;

                    this.dsaName = result.dsaName;
                     console.log('The DS code name ',result.dsaName)
                    if(result.dsaName == undefined ) //CISP-3550
                    { this.disableDSA=true;}
                    this.paymentToDSA = result.paymentToDSA
                    

                   this.coborrowerName = result.coborrowerName; //CISP-3550
                   if( result.secondaryApplicantName!= undefined) // start CISP-3550
                    {
                          this.diableCoborrower=true;
                          this.disablepaymenttocoborrowe =false;
                        this.coborrowerName = result.secondaryApplicantName;
                    }
                    else{
                        this.disablepaymenttocoborrowe= true;
                        this.diableCoborrower=true;
                    }//end CISP-3550
                    this.paymentToCoborrower = result.paymentToCoborrower;
                    // this.phyMandateDispToKarapakkam = result.phyMandateDispToKarapakkam;
                    // this.dealerPayment = result.dealerPayment;
                    if(!this.isPVUsedRefinanceDSA){//CISP-11212
                    this.disableDSA = (result.paymentOriginatedFrom && result.paymentOriginatedFrom.toLowerCase() === 'ta');}

                    if(result.dsaName == undefined ) //  CISP-3550
                    { this.disableDSA=true;}

                    this.paymentOrgFrom = result.paymentOriginatedFrom;
                    if(this.paymentOrgFrom == 'TA' && this.isTractor)    {
                        this.disablepaymenttocoborrowe= true;
                    }
                    let adjList = []

                    this.adjDealNumber1 = result.adjDealNumber1;
                    this.customerName1 = result.customerName1;
                    this.customerCode1 = result.customerCode1;//CISP-2629
                    this.adjAmount1 = result.adjAmount1 ? result.adjAmount1 : 0;
                    if (this.adjDealNumber1) {
                        let adjDetails = {}
                        adjDetails.index = 1;
                        adjDetails.dealNo = this.adjDealNumber1;
                        adjDetails.custName = this.customerName1;
                        adjDetails.amount = this.adjAmount1;
                        adjDetails.custCode = this.customerCode1;//CISP-2629
                        adjList.push(adjDetails);
                    }

                    this.adjDealNumber2 = result.adjDealNumber2;
                    this.customerName2 = result.customerName2;
                    this.customerCode2 = result.customerCode2;//CISP-2629
                    this.adjAmount2 = result.adjAmount2 ? result.adjAmount2 : 0;
                    if (this.adjDealNumber2) {
                        let adjDetails = {}
                        adjDetails.index = 2;
                        adjDetails.dealNo = this.adjDealNumber2;
                        adjDetails.custName = this.customerName2;
                        adjDetails.amount = this.adjAmount2;
                        adjDetails.custCode = this.customerCode2;//CISP-2629
                        adjList.push(adjDetails);
                    }

                    this.adjDealNumber3 = result.adjDealNumber3;
                    this.customerName3 = result.customerName3;
                    this.customerCode3 = result.customerCode3;//CISP-2629
                    this.adjAmount3 = result.adjAmount3 ? result.adjAmount3 : 0;
                    if (this.adjDealNumber3) {
                        let adjDetails = {}
                        adjDetails.index = 3;
                        adjDetails.dealNo = this.adjDealNumber3;
                        adjDetails.custName = this.customerName3;
                        adjDetails.amount = this.adjAmount3;
                        adjDetails.custCode = this.customerCode3;//CISP-2629
                        adjList.push(adjDetails);
                    }

                    this.adjDealNumber4 = result.adjDealNumber4;
                    this.customerName4 = result.customerName4;
                    this.customerCode4 = result.customerCode4;//CISP-2629
                    this.adjAmount4 = result.adjAmount4 ? result.adjAmount4 : 0;
                    if (this.adjDealNumber4) {
                        let adjDetails = {}
                        adjDetails.index = 4;
                        adjDetails.dealNo = this.adjDealNumber4;
                        adjDetails.custName = this.customerName4;
                        adjDetails.amount = this.adjAmount4;
                        adjDetails.custCode = this.customerCode4;//CISP-2629
                        adjList.push(adjDetails);
                    }

                    this.adjDealNumber5 = result.adjDealNumber5;
                    this.customerName5 = result.customerName5;
                    this.customerCode5 = result.customerCode5;//CISP-2629
                    this.adjAmount5 = result.adjAmount5 ? result.adjAmount5 : 0;
                    if (this.adjDealNumber5) {
                        let adjDetails = {}
                        adjDetails.index = 5;
                        adjDetails.dealNo = this.adjDealNumber5;
                        adjDetails.custName = this.customerName5;
                        adjDetails.amount = this.adjAmount5;
                        adjDetails.custCode = this.customerCode5;//CISP-2629
                        adjList.push(adjDetails);
                    }

                    this.adjDealNumber6 = result.adjDealNumber6;
                    this.customerName6 = result.customerName6;
                    this.customerCode6 = result.customerCode6;//CISP-2629
                    this.adjAmount6 = result.adjAmount6 ? result.adjAmount6 : 0;
                    if (this.adjDealNumber6) {
                        let adjDetails = {}
                        adjDetails.index = 6;
                        adjDetails.dealNo = this.adjDealNumber6;
                        adjDetails.custName = this.customerName6;
                        adjDetails.amount = this.adjAmount6;
                        adjDetails.custCode = this.customerCode6;//CISP-2629
                        adjList.push(adjDetails);
                    }

                    this.adjDealNumber7 = result.adjDealNumber7;
                    this.customerName7 = result.customerName7;
                    this.customerCode7 = result.customerCode7;//CISP-2629
                    this.adjAmount7 = result.adjAmount7 ? result.adjAmount7 : 0;
                    if (this.adjDealNumber7) {
                        let adjDetails = {}
                        adjDetails.index = 7;
                        adjDetails.dealNo = this.adjDealNumber7;
                        adjDetails.custName = this.customerName7;
                        adjDetails.amount = this.adjAmount7;
                        adjDetails.custCode = this.customerCode7;//CISP-2629
                        adjList.push(adjDetails);
                    }

                    this.adjDealNumber8 = result.adjDealNumber8;
                    this.customerName8 = result.customerName8;
                    this.customerCode8 = result.customerCode8;//CISP-2629
                    this.adjAmount8 = result.adjAmount8 ? result.adjAmount8 : 0;
                    if (this.adjDealNumber8) {
                        let adjDetails = {}
                        adjDetails.index = 8;
                        adjDetails.dealNo = this.adjDealNumber8;
                        adjDetails.custName = this.customerName8;
                        adjDetails.amount = this.adjAmount8;
                        adjDetails.custCode = this.customerCode8;//CISP-2629
                        adjList.push(adjDetails);
                    }

                    for (let adj of adjList) {
                        for (let detail of this.adjustmentDetails) {
                            if (detail.id == adj.index) {
                                detail.dealNo = adj.dealNo;
                                detail.customerName = adj.custName;
                                detail.adjustedAmount = adj.amount
                                detail.customerCode = adj.custCode;//CISP-2629
                            }
                        }
                    }
                    console.debug(this.adjustmentDetails);
                    this.totalAdjAmount = result.totalAdjAmount;
                    this.benefiId = result.beneficiaryId1;
                    //this.isDisabled = result.benefiDisabled;
                    this.beneficiaryName2 = result.beneficiaryName2;
                    this.beneficiaryName3 = result.beneficiaryName3;
                    this.beneficiaryName4 = result.beneficiaryName4;
                    this.beneficiaryAmount1 = result.beneficiaryAmount1;
                    this.beneficiaryAmount2 = result.beneficiaryAmount2;
                    this.beneficiaryAmount3 = result.beneficiaryAmount3;
                    this.beneficiaryAmount4 = result.beneficiaryAmount4;
                    this.beneficiaryAccNo1 = result.beneficiaryAccNo1;
                    this.beneficiaryAccNo2 = result.beneficiaryAccNo2;
                    this.beneficiaryAccNo3 = result.beneficiaryAccNo3;
                    this.beneficiaryAccNo4 = result.beneficiaryAccNo4;
                    this.totalBeneficiaryAmount = result.totalBeneficiaryAmount;
                    this.balanceTransferAmountInRs = result.balanceTransferAmountInRs;
                    this.loanAppVehicleSubCategory = result.loanAppVehicleSubCategory;
                    this.bankName = result.bankName;
                    this.accountNumber = result.accountNumber;
                    this.bankBranchIFSCCode = result.bankIFSCcode;
                    this.bankBranchName = result.bankBranchName;
                    this.bankBranchPincode = result.bankBranchPincode;
                    this.totalBeneficiaryAmount = this.balanceTransferAmountInRs;
                    if (this.loanAppVehicleSubCategory && this.loanAppVehicleSubCategory != '') {
                        if (this.loanAppVehicleSubCategory.toUpperCase() === 'UOB' || this.loanAppVehicleSubCategory.toUpperCase() === 'UPB') {
                            // this.beneficiaryAmount1 = this.balanceTransfer;
                            this.isDisableBeneficiaryAmount1 = true;
                        }
                        this.getBeneficiaryName1Options(this.loanAppVehicleSubCategory);
                    }

                    if (this.isUsedVehicle) {
                        GetSellerBankDetails({ loanAppId: this.recordid })
                            .then(response => {
                                console.debug(response);
                                if (response) {
                                    this.sellerBankDetails = response;
                                    this.bankName = this.sellerBankDetails.Seller_Bank_name__r.Name;
                                    this.accountNumber = this.sellerBankDetails.Seller_Account_number__c;
                                    this.bankBranchIFSCCode = this.sellerBankDetails.IFSC_code_Seller__c;
                                    this.isSellerBankFieldDisabled = true;
                                } else {
                                    this.isSellerBankFieldDisabled = false;
                                }
                            })
                            .catch(error => {
                                this.tryCatchError = error;
                                this.errorInCatch();
                            });
                    }
                    if (this.benefiId != null && this.benefiId != '' && this.benefiId != undefined) {
                        getBenifRecord({ recordId: this.benefiId }).then(record => {
                            console.log('record', record);
                            this.beneficiaryName1 = record.length > 0 ? record[0].Name +'|'+ record[0].Ben_code__c : '';//CISP-9172
                            this.benefiCode = record.length > 0 ? record[0].Ben_code__c : '';
                        }).catch(error => {
                            console.log(error);
                        });
                    }
                    this.calculateTotalBeneficiaryAmount();
                }
                //added for D2C
                if(this.source==='D2C'){
                    this.disabledSMSResnd=true;
                }


            }
        await getUploadedDocuments({ loanApplicationId: this.recordid })
            .then(response => {
                console.debug(response);
                this.docList = response;

            })
            .catch(error => {
                console.error(error);
            });
        if (this.loanapplicantdetails) {
            this.applicantid = this.loanapplicantdetails[0].Id;
        }
        await isPACTLMSIntegrationLogGenerated({ loanApplicationId: this.recordid, dealId : this.dealId })
        .then(response => {
            console.log('response pact ==> ', response);
            if (response===false) {
                this.disableReTriggerPR = response;
            }
        })
        .catch(error => {
            console.error(error);
        });
        isTVRCaseCompleted({loanApplicationId: this.recordid})
        .then(response => {
            this.tVRCaseCheck = response;
        })
        .catch(error => {
            console.error(error);
        });
        //CISP-13118 start
        await dsaPaymentDisbaling({ loanAppId: this.recordid })
        .then(response => {
            console.log('response pact ==> ', response);
            if (response=== true) {
                this.disableDSA = response;
                this.paymentToDsaPhase = true;//CISP-16182
            }
            if(response=== false){
                this.disableDSA = response;
                this.paymentToDsaPhase = false;//CISP-16182
            }
        })
        .catch(error => {
            console.error(error);
        });
        //CISP-13118 end
        
        isPaymentRequestGenerated({ loanApplicationId: this.recordid, 'dealId' : this.dealId})
          .then(result => {
            console.log('Result', result);
            this.isReadOnlyDSA = result; this.isReadOnlyDealer = result;this.disabledUploadBranchApproval = result;
            this.isTFOfferEngineDisabled = result; //this.isTFPaymentMadeDisabled = result; /*SFTRAC-1896*/
            if(result == false) {
                const today = new Date();
                this.tfloanDealDate = helper.formatDate(today); helper.handleLoanDateCalHelper(this)
            } /*SFTRAC-2262*/
          })
          .catch(error => {
            console.error('Error:', error);
        });//CISP-14380 end
        await checkCIBILFetchDate({loanApplicationId:this.recordid,dealId:this.dealId}).then(result =>{if(result){helper.disableEverything(this)}}).catch(error =>{console.log('error getInvoiceRecord',error)});//SFTRAC-2277
    }
    renderedCallback() {
        // CISP-4770
        if(this.frompostsanction)
            this.disabledSMSResnd =false;
        // CISP-4770
        loadStyle(this, LightningCardApplyCSS);
        if (this.disablefields) {
            // this.isDisableBeneficiaryName1 = true;
            // this.isDisableBeneficiaryName2 = true;
            // this.isDisableBeneficiaryName3 = true;
            // this.isDisableBeneficiaryName4 = true;

            this.isDisableBeneficiaryAmount1 = true;
            this.isDisableBeneficiaryAmount2 = true;
            this.isDisableBeneficiaryAmount3 = true;
            this.isDisableBeneficiaryAmount4 = true;

            this.isbeneficiaryAccNo1Disabled = true;
            this.isbeneficiaryAccNo2Disabled = true;
            this.isbeneficiaryAccNo3Disabled = true;
            this.isbeneficiaryAccNo4Disabled = true;

            this.disableAdjustmentFields = true;
            let inputFields = this.template.querySelectorAll('.slds-form-element__control');
            if (this.disablefields) {
                for (let input of inputFields) {
                    input.disabled = true;
                }
            }
            this.isSellerBankFieldDisabled = true;
            this.isDisabled = true;
        }
        if(this.isUsedVehicleOnly && !this.disablefields){
            if(this.loanAppVehicleSubCategory.toUpperCase() == 'UOM'){
                console.log('I am in if of Pyament to DSA UOM ')
                this.template.querySelectorAll('.required')
                .forEach(input => {
                    if(input.name == 'beneficiaryAccNo1Field' && !this.paymentToDSA){
                        input.disabled = false;
                        input.required = true;
                    }else if(input.name == 'beneficiaryAccNo1Field' && this.paymentToDSA){
                        
                        console.log('I am in if of Pyament to DSA')
                        this.beneficiaryAccNo1 ='';
                        input.disabled = true;
                        input.required = false;
                    }else if(input.name == 'beneficiaryAmount1Field'){
                        input.disabled = false;
                        input.required = true;
                    }else if(input.name == 'beneficiaryAccNo2Field'){
                        input.disabled = false;
                        input.required = true;
                    }else if(input.name == 'beneficiaryAmount2Field'){
                        input.disabled = false;
                        input.required = true;
                    }
                });
            }else if(this.loanAppVehicleSubCategory.toUpperCase() == 'UOB'){
                this.template.querySelectorAll('.required')
                .forEach(input => {
                    if(input.name == 'beneficiaryAccNo1Field'){
                        input.disabled = false;
                        input.required = true;
                    }else if(input.name == 'beneficiaryAmount1Field'){
                        input.disabled = true;
                        input.required = false;
                    }else if((input.name == 'beneficiaryAmount2Field' || input.name == 'beneficiaryAccNo2Field') && !this.paymentToDSA){
                        input.disabled = false;
                        input.required = true;
                    }else if(input.name == 'beneficiaryAccNo2Field' && this.paymentToDSA){
                        input.disabled = true;
                        input.required = false;
                    }else if(input.name == 'beneficiaryAmount2Field' && this.paymentToDSA){
                        input.disabled = false;
                        input.required = true;
                    }else if(input.name == 'beneficiaryAmount3Field' || input.name == 'beneficiaryAccNo3Field'){
                        input.disabled = false;
                        input.required = true;
                    }
                });
            }else if(this.loanAppVehicleSubCategory.toUpperCase() == 'UPB'){
                this.template.querySelectorAll('.required')
                .forEach(input => {
                    if(input.name == 'beneficiaryAmount1Field'){
                        input.disabled = true;
                        input.required = false;
                    }else if(input.name == 'beneficiaryAccNo1Field'){
                        input.disabled = false;
                        input.required = true;
                    }else if(input.name == 'beneficiaryAmount2Field' && this.paymentToDSA){
                        input.disabled = false;
                        input.required = true;
                    }else if(input.name == 'beneficiaryAccNo2Field' && this.paymentToDSA){
                        input.disabled = true;
                        input.required = false;
                    }else if((input.name == 'beneficiaryAmount2Field' || input.name == 'beneficiaryAccNo2Field') && !this.paymentToDSA){
                        input.disabled = false;
                        input.required = true;
                    }
                });
            }else if(this.loanAppVehicleSubCategory.toUpperCase() == 'UPD' || this.loanAppVehicleSubCategory.toUpperCase() == 'UEB'){
                this.template.querySelectorAll('.required')
                .forEach(input => {
                    console.log('input.name ', input.name);
                    if(input.name == 'beneficiaryAccNo1Field'){
                        input.disabled = true;
                        input.required = false;
                    }else if(input.name == 'beneficiaryAmount1Field'){
                        input.disabled = false;
                        input.required = true;
                    }
                });
            }else if(this.loanAppVehicleSubCategory.toUpperCase() == 'URV' || this.loanAppVehicleSubCategory.toUpperCase() == 'UPO'){
                this.template.querySelectorAll('.required')
                .forEach(input => {
                    if((input.name == 'beneficiaryAmount1Field' || input.name == 'beneficiaryAccNo1Field') && !this.paymentToDSA){
                        input.disabled = false;
                        input.required = false;
                    }else if(input.name == 'beneficiaryAccNo1Field' && this.paymentToDSA){
                        input.disabled = true;
                        input.required = false;
                    }else if(input.name == 'beneficiaryAmount1Field' && this.paymentToDSA){
                        input.disabled = false;
                        input.required = true;
                    }
                });
            }else if(this.loanAppVehicleSubCategory.toUpperCase() == 'RLN' || this.loanAppVehicleSubCategory.toUpperCase() == 'RLY' || this.loanAppVehicleSubCategory.toUpperCase() == 'UIM'){
                this.template.querySelectorAll('.required')
                .forEach(input => {
                    if((input.name == 'beneficiaryAmount1Field' || input.name == 'beneficiaryAccNo1Field')){
                        input.disabled = false;
                        input.required = true;
                    }
                });
            }
        }
        if(this.isRevokedLead){
            this.template.querySelectorAll('*').forEach(element=>{
                element.disabled = true;
            });
        }
    }
    changeUploadFile(event) {

    }

    finalTermReferrerName;
    dealerName;
    loanDisbursementDetailsVehicleSoldBy;
    primaryApplicantName;
    secondaryApplicantName;
    get getDisabledCoborrowerFields() {
        let disabledValue;
        if (this.disablefields) {
            disabledValue = true;
        } else {
            disabledValue = !this.disablefields && this.secondaryApplicantName == undefined;
        }
        console.log('disabledValue ', disabledValue);
        return disabledValue;
    }

    @track phyMandateDispToKarapakkamOptions = [
        { label: 'Yes', value: 'Yes' },
        { label: 'No', value: 'No' },
    ];

    handleUploadViewDoc() {
        this.showUpload = true;
        this.showDocView = true;
        this.isVehicleDoc = false;
        this.isAllDocType = true;
        this.uploadViewDocFlag = true;
    }
    calculateTotalAdjAmount() {
        let sum = 0;
        for (let adj of this.adjustmentDetails) {
            sum += adj.adjustedAmount;
        }
        this.totalAdjAmount = sum;
    }
    handleAdjustmentInputFieldChange(event) {
        const field = event.target.dataset.id;
        const fieldName = event.target.name;
        const key = event.target.dataset.key;
        for (let adj of this.adjustmentDetails) {
            if (fieldName.includes('adjDealNumber') && adj.id == key) {
                adj.dealNo = this.template.querySelector('lightning-input[data-id=' + field + ']').value;
                event.target.setCustomValidity('');
                event.target.reportValidity();
                for (let adj of this.adjustmentDetails) {
                    if (adj.id == key) {
                        adj.notFound = false;
                    }
                }
            } else if (fieldName.includes('adjAmount') && adj.id == key) {
                adj.adjustedAmount = parseInt(this.template.querySelector('lightning-input[data-id=' + field + ']').value);
                console.debug(adj);
                this.calculateTotalAdjAmount();
            } else if (fieldName.includes('customerName') && adj.id == key) {
                adj.customerName = this.template.querySelector('lightning-input[data-id=' + field + ']').value;
            }
        }
    }



    calculateTotalBeneficiaryAmount() {
        // if (this.loanAppVehicleSubCategory.toUpperCase() === 'UOB' || this.loanAppVehicleSubCategory.toUpperCase() === 'UPB') {
        //     return;
        // }
        let sum = 0;
        if (this.beneficiaryAmount1) {
            sum += parseFloat(this.beneficiaryAmount1);
        }
        if (this.beneficiaryAmount2) {
            sum += parseFloat(this.beneficiaryAmount2);
        }
        if (this.beneficiaryAmount3) {
            sum += parseFloat(this.beneficiaryAmount3);
        }
        if (this.beneficiaryAmount4) {
            sum += parseFloat(this.beneficiaryAmount4);
        }
        console.debug(sum);
        this.totalBeneficiaryAmount = sum;
        console.debug(sum);
    }

    @track _totalBeneficiaryAmount;
    get totalBeneficiaryAmount() {
        return this._totalBeneficiaryAmount;
    }
    set totalBeneficiaryAmount(value) {
        this._totalBeneficiaryAmount = value;
    }



    handleBeneficiaryInputFieldChange(event) {
        const field = event.target.name;
        console.debug('field', field);
        console.debug(this.beneficiaryName1);
        try {
            if (field.includes('beneficiaryName1Field')) {
                this.beneficiaryName1 = event.target.value;
                if (!this.loanapplicantdetails) {
                    for (let applicant of this.loanapplicantdetails) {
                        if (applicant.Applicant_Type__c.includes(this.beneficiaryName1)) {
                            this.beneficiaryAccNo1 = applicant.Bank_Account_No__c;
                        }
                    }
                }

                this.isbeneficiaryAccNo1Disabled = (!(this.beneficiaryName1 && (this.beneficiaryName1 === 'Borrower' || this.beneficiaryName1 === 'Co-borrower')));
            } else if (field.includes('beneficiaryName2Field')) {
                this.beneficiaryName2 = event.target.value;
                if (!this.loanapplicantdetails) {
                    for (let applicant of this.loanapplicantdetails) {
                        if (applicant.Applicant_Type__c.includes(this.beneficiaryName2)) {
                            this.beneficiaryAccNo2 = applicant.Bank_Account_No__c;
                        }
                    }
                }
                this.isbeneficiaryAccNo2Disabled = (!(this.beneficiaryName2 && (this.beneficiaryName2 === 'Borrower' || this.beneficiaryName2 === 'Co-borrower')));
            } else if (field.includes('beneficiaryName3Field')) {
                this.beneficiaryName3 = event.target.value;
                if (!this.loanapplicantdetails) {
                    for (let applicant of this.loanapplicantdetails) {
                        if (applicant.Applicant_Type__c.includes(this.beneficiaryName3)) {
                            this.beneficiaryAccNo3 = applicant.Bank_Account_No__c;
                        }
                    }
                }
                this.isbeneficiaryAccNo3Disabled = (!(this.beneficiaryName3 && (this.beneficiaryName3 === 'Borrower' || this.beneficiaryName3 === 'Co-borrower')));
            } else if (field.includes('beneficiaryName4Field')) {
                this.beneficiaryName4 = event.target.value;
                if (!this.loanapplicantdetails) {
                    for (let applicant of this.loanapplicantdetails) {
                        if (applicant.Applicant_Type__c.includes(this.beneficiaryName4)) {
                            this.beneficiaryAccNo4 = applicant.Bank_Account_No__c;
                        }
                    }
                }
                this.isbeneficiaryAccNo4Disabled = (!(this.beneficiaryName4 && (this.beneficiaryName4 === 'Borrower' || this.beneficiaryName4 === 'Co-borrower')));
            } else if (field.includes('beneficiaryAmount1Field')) {
                this.beneficiaryAmount1 = parseFloat(event.target.value);
                this.calculateTotalBeneficiaryAmount();
            } else if (field.includes('beneficiaryAmount2Field')) {
                this.beneficiaryAmount2 = parseFloat(event.target.value);
                this.calculateTotalBeneficiaryAmount();
            } else if (field.includes('beneficiaryAmount3Field')) {
                this.beneficiaryAmount3 = parseFloat(event.target.value);
                this.calculateTotalBeneficiaryAmount();
            } else if (field.includes('beneficiaryAmount4Field')) {
                this.beneficiaryAmount4 = parseFloat(event.target.value);
                this.calculateTotalBeneficiaryAmount();
            } else if (field.includes('beneficiaryAccNo1Field')) {
                this.beneficiaryAccNo1 = event.target.value;
            } else if (field.includes('beneficiaryAccNo2Field')) {
                this.beneficiaryAccNo2 = event.target.value;
            } else if (field.includes('beneficiaryAccNo3Field')) {
                this.beneficiaryAccNo3 = event.target.value;
            } else if (field.includes('beneficiaryAccNo4Field')) {
                this.beneficiaryAccNo4 = event.target.value;
            }
        } catch (error) {
            console.debug(error);
        }
    }

    handleInputFieldChange(event) {
        console.log('Payment to DSA is', event.target.checked);
        const field = event.target.name;
        if(event.target.checked) //CISP: 3550 Start
        { console.log('I am in 1st if ')

                this.beneficiaryAccNo2='';      
        } //CISP: 3550 End 
        console.debug('field', field);
        if (field === 'dsaNameField') {
            this.dsaName = event.target.value;
        } else if (field === 'paymentToDSAField') {
            this.paymentToDSA = event.target.checked;
            if (this.loanAppVehicleSubCategory && this.loanAppVehicleSubCategory != '') {
                this.getBeneficiaryName1Options(this.loanAppVehicleSubCategory);
            }
        } else if (field === 'coborrowerNameField') {
            this.coborrowerName = event.target.value;
        } else if (field === 'paymentToCoborrowerField') {
            this.paymentToCoborrower = event.target.checked;
            this.getBeneficiaryName1Options(this.loanAppVehicleSubCategory);
        } else if (field === 'phyMandateDispToKarapakkamField') {
            this.phyMandateDispToKarapakkam = event.target.value;
        } else if (field === 'bankNameField') {
            this.bankName = event.target.value;
        } else if (field === 'accoundNumberField') {
            this.accountNumber = event.target.value;
        } else if (field === 'bankBranchNameField') {
            this.bankBranchName = event.target.value;
        } else if (field === 'bankBranchPincodeField') {
            this.bankBranchPincode = event.target.value;
        } else if (field === 'dealerPaymentField') {
            this.dealerPayment = event.target.value;
        } else if (field === 'bankifsccodeField') {
            this.bankBranchIFSCCode = event.target.value;
        } else if (field === 'paymentToBuilderField') {
            this.paymentToBuilder = event.target.checked;
        } else if (field === 'paymentToDealerField') {
            this.paymentToDealer = event.target.checked;
        }
        }//CISP-8762
    async getDocumentIdForDealerAndDSA(docType){
        this.uploadViewFileFlag = false;
        await getUploadedDocuments({ loanApplicationId: this.recordid })
            .then(response => {
                console.debug(response);
                this.docList = response;
                this.docList.filter(item => {
                    if (item.Document_Type__c === docType){
                        this.documentRecordId = item.Id;
                        this.uploadViewFileFlag = true;
                        return null;
                    }
                });
            })
            .catch(error => {
                console.error(error);
            });

    }
    getDocumentId(docType) {
        this.docList.filter(item => {
            if (item.Document_Type__c.toUpperCase() === docType)
                return item.Id;
        });
    }

    handlePassbook(event) {
        if (this.disablefields) {
            this.uploadViewFileFlag = true
        } else {
            this.uploadFileFlag = true;
        }
        this.uploadDocFlag = true;
        this.docType = 'Seller Passbook';
        this.documentRecordId = this.getDocumentId(event.targer.dataset.doctype);
    }
    //CISP-8762
    async uploadBranchForDSA(event){
        this.documentRecordId = '';
        await this.getDocumentIdForDealerAndDSA(event.target.dataset.doctype);
        if (this.disablefields) {
            this.uploadViewFileFlag = true
        }
        if(this.documentRecordId == '' || this.documentRecordId == undefined || this.documentRecordId == null){
            this.uploadFileFlag = true;
        }
        this.uploadDocFlag = true;
        this.docType = 'Branch In-charge Approval Email For DSA';
        
    }
    async uploadBranchForDealer(event){
        this.documentRecordId = '';
        await this.getDocumentIdForDealerAndDSA(event.target.dataset.doctype);
        if (this.disablefields) {
            this.uploadViewFileFlag = true
        } if(this.documentRecordId == '' || this.documentRecordId == undefined || this.documentRecordId == null){
            this.uploadFileFlag = true;
        }
        this.uploadDocFlag = true;
        this.docType = 'Branch In-charge Approval Email';
    }//CISP-8762 end

    handleAccountStatement(event) {
        if (this.disablefields) {
            this.uploadViewFileFlag = true
        } else {
            this.uploadFileFlag = true;
        }
        this.uploadDocFlag = true;
        this.docType = 'Seller Bank Statement';
        this.documentRecordId = this.getDocumentId(event.targer.dataset.doctype);
    }

    handleCancelledCheque(event) {
        if (this.disablefields) {
            this.uploadViewFileFlag = true
        } else {
            this.uploadFileFlag = true;
        }
        this.uploadDocFlag = true;
        this.docType = 'Seller Cancel Cheque';
        this.documentRecordId = this.getDocumentId(event.targer.dataset.doctype);
    }
    closeUpload(event) {
        this.uploadDocFlag = false;
        this.uploadFileFlag = false;
    }

    isSubmitClick;
    
    async handleSubmit(event) {
        if(!this.isTractor){
            let res = true;
            console.log('not tractor submit');
            res = await helper.submitValidationChecks(this);
            if(!res){return;}
        }
        if(!this.isTractor){
            this.callPaymentRequest();
        }

        //SFTRAC-2291 Start
        if(this.isTractor){
            if(this.isAllowPACTAPI){
                this.callPaymentRequest();
            }else{
                this.showToastMessage('Error', 'Offer Engine API is not Completed', 'Error');
            }    
        }
        //SFTRAC-2291 End
    }
    async callPaymentRequest() {        
        //SFTRAC-163-START
        if(this.isTractor){
            await getFICaseListRecord({loanApplicationId: this.recordid,dealId:this.dealId}).then(result=>{
                console.log('## result: ' + JSON.stringify(result));
                this.caseList = result?.caseList;
                this.assetVerFailedList = result?.assetVerFailedList;
                this.isFieldInvsNotCompleted =result?.isFieldInvsNotCompleted;
                this.isCamApprovalNotCompleted = result?.isCamApprovalNotCompleted;
                this.isAssetVerFailed = result?.isAssetVerFailed;
                if(this.caseList?.length > 0){
                  this.isCaseFI = true;
                }else{
                    this.isCaseFI = false;
                }
                if(this.assetVerFailedList?.length > 0){
                    this.isAssetVerExceeded = true;
                }else{
                    this.isAssetVerExceeded = false;
                }
                this.fIList = result?.fieldInvsList;
                this.isCamApproval = result?.isCamSucess;
                this.applicantCibilRecordList = result?.cbrWrapperList;
                if(this.applicantCibilRecordList.length > 0) {
                    this.isCibilPulled = true;
                }else{
                    this.isCibilPulled = false;
                }
             }).catch(error =>{
                 console.error(error);
             });
             //SFTRAC-172 start
             let result1 = await isChildLeadClosed({'loanApplicationId':this.recordid});
                if(result1){
                    this.dispatchEvent(new ShowToastEvent({
                        title: "Warning",
                        message: 'Child lead not closed yet.',
                        variant: 'warning'
                    }));
                    return;
                }//SFTRAC-172 end
        }
        console.log('## applicantCibilRecordList',this.applicantCibilRecordList);
        console.log('## 3 results :',this.isCaseFI,this.isBorrowerCibilSucess,this.isCoBorrowerCibilSucess,this.isCamApproval);
        // this.isCaseFI = false;
        // this.isCamApproval = false;
        // this.isCibilPulled = true;
       if(this.isCaseFI){
         this.modalHeader ='FI Case';
       }else if(this.isAssetVerExceeded){
        this.modalHeader ='Asset Verification'
       }else if(this.isCibilPulled){
         this.modalHeader ='CIBIL';
       }else if(this.isCamApproval){
        this.modalHeader = 'CAM'
       }
       if(this.isTractor && this.isFieldInvsNotCompleted){
            this.showToastMessage('FI case not completed','FI case not completed yet. Please complete FI case!');
       }/*else if(this.isTractor && this.isAssetVerFailed){
        this.showToastMessage('Asset not verified','Asset not verified. Please verify asset first!');
      }*/else if(this.isTractor && this.isCamApprovalNotCompleted){
            this.showToastMessage('CAM not Approved','CAM not Approved. Please complete CAM Approval first!');
      }else if(this.isTractor && (this.isCaseFI || this.isAssetVerExceeded || this.isCibilPulled || this.isCamApproval)) {
          this.isModalOpen = true;
       }else{
        this.disableDSA=true; //CISP-3550
        this.disablepaymenttocoborrowe= true; //CISP-3550
        this.diableCoborrower=true; //CISP-3550
        console.log('Submit..');
        if (this.disabledSubmit && !this.frompostsanction) {
            const evt = new ShowToastEvent({
                title: "Warning",
                message: 'CASA Consent Not Accepted By Customer',
                variant: 'warning'
            });
            this.dispatchEvent(evt);
            return;
        } else if(this.loanAppProductType && this.loanAppProductType.includes('Passenger Vehicles') && !this.tVRCaseCheck && !this.frompostsanction){
            const evt = new ShowToastEvent({
                title: "Warning",
                message: IsTVRPassed,
                variant: 'warning'
            });
            this.dispatchEvent(evt);
            return;
        } else {
            //this.disabledSubmit = true;//CISP-11493
            if((this.loanAppProductType.includes('Tractor') || this.loanAppProductType.includes('Passenger Vehicles'))){
                for (let adj of this.adjustmentDetails) {
                    if(adj.dealNo && (!adj.processed || !adj.customerName || adj.notFound)){
                        const evt = new ShowToastEvent({
                            title: "Error",
                            message: GETCUSTOMERBTNMANDATORYERROR,
                            variant: 'error'
                        });
                        this.dispatchEvent(evt);
                        this.disabledSubmit = false;
                        return;
                    }else if(adj.adjustedAmount && (!adj.dealNo ||!adj.processed || !adj.customerName || adj.notFound)){
                        const evt = new ShowToastEvent({
                            title: "Warning",
                            message: 'Please enter deal number / remove adjustment amount.',
                            variant: 'warning'
                        });
                        this.dispatchEvent(evt);
                        this.disabledSubmit = false;
                        return;
                    }
                }
            }
            if(!this.isReadOnlyDealer && this.isPVUsedRefinanceDealer && !this.frompostsanction){
                this.isReadOnlyDealer = false;
                this.isDealerEnabled = true;
                this.dispatchEvent(new ShowToastEvent({
                    title: "Warning",
                    message: 'RC limit check for Dealer is not clear. Please click on Check RC Limit Parameters for Dealer',
                    variant: 'warning'
                }));
                return;
            }
            if(!this.isReadOnlyDSA && this.isPVUsedRefinanceDSA && !this.frompostsanction){
                this.isReadOnlyDSA = false;
                this.isDSAEnabled = true;
                this.dispatchEvent(new ShowToastEvent({
                    title: "Warning",
                    message: 'RC limit check for DSA is not clear. Please click on Check RC Limit Parameters for DSA',
                    variant: 'warning'
                }));
                return;
            }
            let allInputs = this.template.querySelectorAll('.slds-form-element__control');
            console.log('allInputs:', allInputs);
            let isAllValid = false;
            let acctNoFieldName = ['beneficiaryAccNo1Field', 'beneficiaryAccNo2Field', 'beneficiaryAccNo3Field', 'beneficiaryAccNo4Field'];
            let acctNoFieldNameValid = [];
            if (this.beneficiaryAccNo1) {
                acctNoFieldNameValid.push(await isAcctNumberPresentInBenMaster({ acctNoToCheck: this.beneficiaryAccNo1 }));
            }
            if (this.beneficiaryAccNo2) {
                acctNoFieldNameValid.push(await isAcctNumberPresentInBenMaster({ acctNoToCheck: this.beneficiaryAccNo2 }));
            }
            if (this.beneficiaryAccNo3) {
                acctNoFieldNameValid.push(await isAcctNumberPresentInBenMaster({ acctNoToCheck: this.beneficiaryAccNo3 }));
            }
            if (this.beneficiaryAccNo4) {
                acctNoFieldNameValid.push(await isAcctNumberPresentInBenMaster({ acctNoToCheck: this.beneficiaryAccNo4 }));
            }
            for (let input of allInputs) {
                //seller bank details should not be mandatory for New Vehicle
                if (this.isNewVehicle && (input.name === 'bankNameField' || input.name === 'accoundNumberField'
                    || input.name === 'bankBranchNameField' || input.name === 'bankBranchPincodeField'
                    || input.name === 'bankifsccodeField')) {
                    continue;
                }
                if (acctNoFieldNameValid.includes(true) && acctNoFieldName.includes(input.name)) {
                    console.log('input.name', input.name);
                    const evt = new ShowToastEvent({
                        title: "Error",
                        message: AccountNoAlreadyExistMsg,
                        variant: 'error'
                    });
                    this.dispatchEvent(evt);
                    this.disabledSubmit = false.
                    return;
                }
                if (input.validity.valid) {
                    isAllValid = true;
                } else {
                    isAllValid = false;
                    input.reportValidity();
                    input.focus();
                    break;
                }
            }
             //CISP-4206
            // console.log('beneficiaryAccNoLenght =',this.beneficiaryAccNo1.length);            
            if((this.beneficiaryAccNo1? this.beneficiaryAccNo1.length > 25 ? true : false :false)|| 
                  (this.beneficiaryAccNo2? this.beneficiaryAccNo2.length > 25 ? true : false :false)||
                  (this.beneficiaryAccNo3? this.beneficiaryAccNo3.length > 25 ? true : false :false)||
                  (this.beneficiaryAccNo4? this.beneficiaryAccNo4.length > 25 ? true : false :false)){                
                      const evt = new ShowToastEvent({  
                    title: "Error",
                    message: 'The Benficiary Account Number length should be less than or equal to 25  Only',
                    variant: 'error'
                    });
                    this.dispatchEvent(evt);
                    this.disabledSubmit = false;
                    return;
                } 
                if(this.accountNumber ? this.accountNumber.length > 25 ? true : false :false){
                              const evt = new ShowToastEvent({
                                  title: "Error",
                                  message: 'The A/c No. length should be less than or equal to 25 Only',
                                  variant: 'error'
                                  });
                                  this.dispatchEvent(evt);
                                  this.disabledSubmit = false;
                                  return;
                                  }
                             //CISP-4206      
            if((this.loanAppVehicleType.includes('Used') || this.loanAppVehicleType.includes('Refinance')) && 
            (this.loanAppProductType.includes('Tractor') || this.loanAppProductType.includes('Passenger Vehicles')) && this.loanAppVehicleSubCategory.toUpperCase() == 'UPD'){
            if((parseInt(this.financeAmount == undefined ? 0 : this.financeAmount) - 
                parseInt(this.totalAdjAmount == undefined ? 0 : this.totalAdjAmount) - 
                parseInt(this.ihmRecoveryAmount == undefined ? 0 : this.ihmRecoveryAmount) -
                parseInt(this.ihmPaidToDealer == undefined ? 0 : this.ihmPaidToDealer)) != this.totalBeneficiaryAmount) {
                const evt = new ShowToastEvent({
                    title: "Error",
                    message: DealerPaymentErrorV3,
                    variant: 'error'
                });
                this.dispatchEvent(evt);
                this.disabledSubmit = false;
                return;
            }
        }else if((this.loanAppVehicleType.includes('Used') || this.loanAppVehicleType.includes('Refinance')) && 
            (this.loanAppProductType.includes('Tractor') || this.loanAppProductType.includes('Passenger Vehicles'))){
            if((parseInt(this.totalBeneficiaryAmount == undefined ? 0 : this.totalBeneficiaryAmount) + 
                parseInt(this.totalAdjAmount == undefined ? 0 : this.totalAdjAmount) + 
                parseInt(this.ihmRecoveryAmount == undefined ? 0 : this.ihmRecoveryAmount)) != this.dealerPayment) {
                const evt = new ShowToastEvent({
                    title: "Error",
                    message: DealerPaymentErrorV2,
                    variant: 'error'
                });
                this.dispatchEvent(evt);
                this.disabledSubmit = false;
                return;
            }
        } else if((parseInt(this.totalBeneficiaryAmount == undefined ? 0 : this.totalBeneficiaryAmount) + parseInt(this.totalAdjAmount == undefined ? 0 : this.totalAdjAmount)) != this.dealerPayment) {
            const evt = new ShowToastEvent({
                title: "Error",
                message: DealerPaymentError,
                variant: 'error'
            });
            this.dispatchEvent(evt);
            this.disabledSubmit = false;
            return;
        }
        console.debug(' this.recordid', this.recordid);
        console.debug(' disbursment id', this.disbursementrecordid);
        let inputData = {};
        if (this.recordid) {
            inputData.loanDisbursementDetailId = this.disbursementrecordid;
        }
        inputData.dsaName = this.dsaName ? this.dsaName : '';
        inputData.paymentToDSA = this.paymentToDSA;
        inputData.paymentToBuilder = this.paymentToBuilder;
        inputData.paymentToDealer = this.paymentToDealer;
        inputData.coborrowerName = this.coborrowerName ? this.coborrowerName : '';
        inputData.paymentToCoborrower = this.paymentToCoborrower;
        inputData.phyMandateDispToKarapakkam = this.phyMandateDispToKarapakkam;
        inputData.bankName = this.bankName;
        inputData.accountNumber = this.accountNumber ? this.accountNumber : '';
        inputData.bankBranchName = this.bankBranchName;
        inputData.bankBranchPincode = this.bankBranchPincode;
        inputData.bankIFSCcode = this.bankBranchIFSCCode;
        inputData.dealerPayment = this.dealerPayment;
        inputData.parentLoanAppId = this.recordid;
        inputData.benifcode = this.benefiCode;
        for (let adj of this.adjustmentDetails) {
            switch (adj.id) {
                case 1:
                    inputData.adjDealNumber1 = adj.dealNo;
                    inputData.customerName1 = adj.customerName;
                    inputData.customerCode1 = adj.customerCode;//CISP-2629
                    inputData.adjAmount1 = adj.adjustedAmount == '' ? 0 : parseFloat(adj.adjustedAmount);
                    break;
                case 2:
                    inputData.adjDealNumber2 = adj.dealNo;
                    inputData.customerName2 = adj.customerName;
                    inputData.customerCode2 = adj.customerCode;//CISP-2629
                    inputData.adjAmount2 = adj.adjustedAmount == '' ? 0 : parseFloat(adj.adjustedAmount);
                    break;
                case 3:
                    inputData.adjDealNumber3 = adj.dealNo;
                    inputData.customerName3 = adj.customerName;
                    inputData.customerCode3 = adj.customerCode;//CISP-2629
                    inputData.adjAmount3 = adj.adjustedAmount == '' ? 0 : parseFloat(adj.adjustedAmount);
                    break;
                case 4:
                    inputData.adjDealNumber4 = adj.dealNo;
                    inputData.customerName4 = adj.customerName;
                    inputData.customerCode4 = adj.customerCode;//CISP-2629
                    inputData.adjAmount4 = adj.adjustedAmount == '' ? 0 : parseFloat(adj.adjustedAmount);
                    break;
                case 5:
                    inputData.adjDealNumber5 = adj.dealNo;
                    inputData.customerName5 = adj.customerName;
                    inputData.customerCode5 = adj.customerCode;//CISP-2629
                    inputData.adjAmount5 = adj.adjustedAmount == '' ? 0 : parseFloat(adj.adjustedAmount);
                    break;
                case 6:
                    inputData.adjDealNumber6 = adj.dealNo;
                    inputData.customerName6 = adj.customerName;
                    inputData.customerCode6 = adj.customerCode;//CISP-2629
                    inputData.adjAmount6 = adj.adjustedAmount == '' ? 0 : parseFloat(adj.adjustedAmount);
                    break;
                case 7:
                    inputData.adjDealNumber7 = adj.dealNo;
                    inputData.customerName7 = adj.customerName;
                    inputData.customerCode7 = adj.customerCode;//CISP-2629
                    inputData.adjAmount7 = adj.adjustedAmount == '' ? 0 : parseFloat(adj.adjustedAmount);
                    break;
                case 8:
                    inputData.adjDealNumber8 = adj.dealNo;
                    inputData.customerName8 = adj.customerName;
                    inputData.customerCode8 = adj.customerCode;//CISP-2629
                    inputData.adjAmount8 = adj.adjustedAmount == '' ? 0 : parseFloat(adj.adjustedAmount);
                    break;
                    deafult:
                    break;
            }
        }
            inputData.totalAdjAmount = this.totalAdjAmount;

            inputData.benefiCode = this.benefiCode ? this.benefiCode : '';

            inputData.beneficiaryName1 = this.beneficiaryName1 ? this.beneficiaryName1 : '';
            inputData.beneficiaryName2 = this.beneficiaryName2 ? this.beneficiaryName2 : '';
            inputData.beneficiaryName3 = this.beneficiaryName3 ? this.beneficiaryName3 : '';
            inputData.beneficiaryName4 = this.beneficiaryName4 ? this.beneficiaryName4 : '';
            inputData.beneficiaryAmount1 = this.beneficiaryAmount1 ? parseFloat(this.beneficiaryAmount1) : 0;
            inputData.beneficiaryAmount2 = this.beneficiaryAmount2 ? parseFloat(this.beneficiaryAmount2) : 0;
            inputData.beneficiaryAmount3 = this.beneficiaryAmount3 ? parseFloat(this.beneficiaryAmount3) : 0;
            inputData.beneficiaryAmount4 = this.beneficiaryAmount4 ? parseFloat(this.beneficiaryAmount4) : 0;
            inputData.beneficiaryAccNo1 = this.beneficiaryAccNo1 ? this.beneficiaryAccNo1 : '';
            inputData.beneficiaryAccNo2 = this.beneficiaryAccNo2 ? this.beneficiaryAccNo2 : '';
            inputData.beneficiaryAccNo3 = this.beneficiaryAccNo3 ? this.beneficiaryAccNo3 : '';
            inputData.beneficiaryAccNo4 = this.beneficiaryAccNo4 ? this.beneficiaryAccNo4 : '';
            inputData.totalBeneficiaryAmount = this.totalBeneficiaryAmount;
            inputData.loanAppVehicleSubCategory = this.loanAppVehicleSubCategory;
            inputData.isNewVehicle = this.isNewVehicle;
            inputData.dealershipNature = this.dealershipNature;
            console.debug(inputData);
            console.debug(isAllValid);
            if (isAllValid) {
                await handleBeneficiaryDetailsSubmit({
                    inputData: JSON.stringify(inputData)
                }).then(result => {
                    console.debug('result --', result);
                    this.disbursementrecordid = result;
                    this.showSuccess('Success!', 'Beneficiary Details has submitted successfully.');
                    this.disablefields = true;
                    this.disabledSubmit = true;
                    this.disabledSMSResnd = true;

                    if (this.disablefields) {
                        // this.isDisableBeneficiaryName1 = true;
                        // this.isDisableBeneficiaryName2 = true;
                        // this.isDisableBeneficiaryName3 = true;
                        // this.isDisableBeneficiaryName4 = true;

                        this.isDisableBeneficiaryAmount1 = true;
                        this.isDisableBeneficiaryAmount2 = true;
                        this.isDisableBeneficiaryAmount3 = true;
                        this.isDisableBeneficiaryAmount4 = true;

                        this.isbeneficiaryAccNo1Disabled = true;
                        this.isbeneficiaryAccNo2Disabled = true;
                        this.isbeneficiaryAccNo3Disabled = true;
                        this.isbeneficiaryAccNo4Disabled = true;

                        this.disableAdjustmentFields = true;
                        let inputFields = this.template.querySelectorAll('.slds-form-element__control');
                        if (this.disablefields) {
                            for (let input of inputFields) {
                                input.disabled = true;
                            }
                        }
                        this.isSellerBankFieldDisabled = true;

                    }
                    //make callout to API to Payment request
                    this.isSubmitClick = true;
                    //  CISP-4770 - START 
                    if(!this.frompostsanction){
                        this.callPaymentRequestGeneration();
                    }else{
                        this.navigateToNextTab();
                    }
                     // CISP-4770 - END 
                    //refreshApex(this.dataResult);
                }).catch(error => {
                    console.debug('print error ', error);
                    this.showError('Error!', error.message);
                    this.disabledSubmit = false;
                    return;
                });
            } else {
                const evt = new ShowToastEvent({
                    title: "Error",
                    message: this.label.mandotoryDetailsNotProvide,
                    variant: 'error'
                });
                this.dispatchEvent(evt);
                this.disabledSubmit = false;
                return;
            }
        }
      }
    }

    async handlesmsClick() {
        try{
            this.isSpinnerMoving = true;
            let result = await isCasaConsentReceived({'parentLoanAppId' : this.recordid});
            if(result){
                let response = JSON.parse(JSON.stringify(result));
                this.borrowerconsentRecived = response.borrowerconsentRecived;
                this.coborrowerconsentRecived = response.coborrowerconsentRecived
            }
            if(this.disabledSMSResnd == false && (this.primaryApplicantWillingnessforAccOpening == true || this.secondaryApplicantWillingnessforAccOpening == true) && (this.borrowerconsentRecived == false || this.coborrowerconsentRecived == false)){
                if(this.primaryApplicantWillingnessforAccOpening == true && this.borrowerconsentRecived == false && this.whoWillRepayLoan && this.whoWillRepayLoan == 'Borrower'){
                    this.casaformSMS(this.primaryApplicantId, 'CASA');
                }
                if(this.secondaryApplicantWillingnessforAccOpening == true && this.coborrowerconsentRecived == false && this.whoWillRepayLoan && this.whoWillRepayLoan == 'Co-borrower'){
                    this.casaformSMS(this.secondaryApplicantId, 'CASA');
                }
                //this.disabledSubmit = false;
                this.disabledSMSResnd = true;
                this.isSpinnerMoving = false;
            }
            else{
                const event = new ShowToastEvent({
                    title: 'Warning',
                    message: 'Consent Already sent',
                    variant: 'warning',
                });
                this.dispatchEvent(event);
                this.isSpinnerMoving = false;
            }
        }catch(error){
            const event = new ShowToastEvent({
                title: 'Error',
                message: error?.body?.message,
                variant: 'Error',
            });
            this.dispatchEvent(event);
            this.isSpinnerMoving= false;
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
            fields[CASA_FORM_SMS_SENT.fieldApiName] = tDatetime;
            fields[APPLICANT_CASAConsentOTP.fieldApiName] = String(applicationRanNum);
        }

        const recordInput = { fields };
        await updateRecord(recordInput)
            .then(() => {
                console.log('Applicant record updated', recordInput);
                let smsRequestString = {
                    'applicantId': applicantId,
                    'loanApplicationId': this.recordid,
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
                                message: this.label.Consent_Sent_Successfully,
                                variant: 'success',
                            });
                            this.dispatchEvent(event);

                            this.renderedCallback();
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
    showSuccess(title, message) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: 'success',
        });
        this.dispatchEvent(evt);
    }

    showError(title, errorMessage) {
        const evt = new ShowToastEvent({
            title: title,
            message: errorMessage,
            variant: 'error',
        });
        this.dispatchEvent(evt);
    }

    handleClear(event) {
        const index = event.target.dataset.id;
        var adjName = this.template.querySelector('lightning-input[data-id=adjDealNumber' + index + 'Field]');
        adjName.setCustomValidity("");
        for (let adj of this.adjustmentDetails) {
            if (adj.id == index) {
                adj.dealNo = '';
                adj.customerName = '';
                adj.adjustedAmount = '';
                adj.notFound = false;
                adj.processed = false;
            }
        }
    }

    handleGetCustomerName(event) {
        const index = event.target.dataset.id;

        console.debug(index);
        var adjName = this.template.querySelector('lightning-input[data-id=adjDealNumber' + index + 'Field]');
        adjName.setCustomValidity("");
        console.debug(adjName);
        for (let adj of this.adjustmentDetails) {
            if (adj.processed) {
                console.debug(adj.id == index);
                if (adjName.value.includes(adj.dealNo)) {
                    if (adj.id == index) {
                        adj.dealNo = adjName.value;
                        adj.customerName = '';
                        adj.notFound = false;
                    } else {
                        adjName.setCustomValidity(this.label.DuplicateDealNumber);
                        adjName.reportValidity();
                    }
                }
            }
        }
        if (adjName.validity.valid) {
            //show the spinner
            this.isSpinnerMoving = true;
            let requestObject = {
                customerCode : '',
                dealNumber :  adjName.value, // INDI-4701
                loanApplicationId : this.recordid,
            }
            doCustomerNameSearchCallout({ customerNameSearchString: JSON.stringify(requestObject), loanAppId: this.recordid })
                .then(response => {
                    var responseBody = JSON.parse(response);
                    console.debug(responseBody);
                    var status = responseBody.response.status;
                    if (status.includes('SUCCESS')) {
                        var ownername = responseBody.response.content[0].Customer_Name;
                        var ownercode = responseBody.response.content[0].Customer_Code;//CISP-2629
                        console.debug(ownername);
                        for (var adj of this.adjustmentDetails) {
                            if (adj.id == index) {
                                adj.customerName = ownername;
                                adj.customerCode = ownercode;//CISP-2629
                                if (ownername) {
                                    adj.notFound = false;
                                } else {
                                    adj.notFound = true;
                                    adjName.setCustomValidity(this.label.CustomerNotFound);
                                    adjName.reportValidity();
                                }
                                adj.processed = true;
                            }
                        }
                        //hide the spinner
                        this.isSpinnerMoving = false;
                    }
                })
                .catch(error => {
                    //hide the spinner
                    this.isSpinnerMoving = false;
                    this.tryCatchError = error;
                    console.debug(error);
                    this.errorInCatch();
                });
        }

    }

    getBeneficiaryName1Options(vehicleSubCategory) {
        console.debug(vehicleSubCategory);
        // 1 - Borrower, 2 - Co-borrower; 3 - Dealer; 4 - DSA; 5 - Seller; 6 – Bank
        switch (vehicleSubCategory.toUpperCase()) {
            case 'UOM':
                // this.beneficiary1NameOptions = [
                //     { label: 'DSA', value: 'DSA' }
                // ];
                if (!this.paymentToDSA) {
                    this.isSellerSectionEnabled = true;
                    // this.beneficiary1NameOptions.push({ label: 'Seller', value: 'Seller' });
                    this.beneficiaryName1 = this.loanDisbursementDetailsVehicleSoldBy;
                } else {
                    this.isSellerSectionEnabled = false;
                    this.beneficiaryName1 = this.finalTermReferrerName;
                }
                // this.beneficiary2NameOptions = [
                //     { label: 'Borrower', value: 'Borrower' }
                // ];
                if (this.paymentToCoborrower) {
                    // this.beneficiary2NameOptions.push({ label: 'Co-borrower', value: 'Co-borrower' });
                    this.beneficiaryName2 = this.secondaryApplicantName;
                } else {
                    this.beneficiaryName2 = this.primaryApplicantName;
                }
                break;
            case 'UOB':
                // this.beneficiary1NameOptions = [
                //     { label: 'Bank', value: 'Bank' }
                // ];
                // this.beneficiaryName1 = 'Bank';
                this.beneficiaryAmount1 = this.balanceTransfer;
                this.amount1Disabled = true;
                // this.beneficiary2NameOptions = [
                //     { label: 'DSA', value: 'DSA' }
                // ];
                if (!this.paymentToDSA) {
                    this.isSellerSectionEnabled = true;
                    // this.beneficiary2NameOptions.push({ label: 'Seller', value: 'Seller' });
                    this.beneficiaryName2 = this.loanDisbursementDetailsVehicleSoldBy;
                } else {
                    this.isSellerSectionEnabled = false;
                    this.beneficiaryName2 = this.finalTermReferrerName;
                }
                // this.beneficiary3NameOptions = [
                //     { label: 'Borrower', value: 'Borrower' }
                // ];
                if (this.paymentToCoborrower) {
                    // this.beneficiary3NameOptions.push({ label: 'Co-borrower', value: 'Co-borrower' });
                    this.beneficiaryName3 = this.secondaryApplicantName;
                } else {
                    this.beneficiaryName3 = this.primaryApplicantName;
                }
                break;
            case 'UPD':
                // this.beneficiary1NameOptions = [
                //     { label: 'Dealer', value: 'Dealer' }
                // ];
                if(this.isTractor){
                    if (!this.paymentToDSA) {
                        this.beneficiaryName1 = this.dealerName;
                    }else{
                        this.beneficiaryName1 = this.finalTermReferrerName;
                    }
                }else{
                    this.beneficiaryName1 = this.dealerName;
                }
                break;
            case 'URS':
                break;
            case 'URV':
                // this.beneficiary1NameOptions = [
                //     { label: 'DSA', value: 'DSA' }
                // ];
                this.beneficiaryName1 = this.finalTermReferrerName;
                if (!this.paymentToDSA) {
                    // this.beneficiary1NameOptions.push({ label: 'Borrower', value: 'Borrower' });
                    if (this.paymentToCoborrower) {
                        // this.beneficiary1NameOptions.push({ label: 'Co-borrower', value: 'Co-borrower' });
                        this.beneficiaryName1 = this.secondaryApplicantName;
                    } else {
                        this.beneficiaryName1 = this.primaryApplicantName;
                    }
                }
                break;
            case 'UEB':
                // this.beneficiary1NameOptions = [
                //     { label: 'Dealer', value: 'Dealer' }
                // ];
                if(this.isTractor){
                    if (!this.paymentToCoborrower) {
                        // this.beneficiary1NameOptions.push({ label: 'Borrower', value: 'Borrower' });
                        this.beneficiaryName1 = this.primaryApplicantName;
                    } else {
                        this.beneficiaryName1 = this.secondaryApplicantName;
                    }
                }else{
                    this.beneficiaryName1 = this.dealerName;
                }

                break;
            case 'UPB':
                // this.beneficiary1NameOptions = [
                //     { label: 'Bank', value: 'Bank' }
                // ];
                // this.beneficiaryName1 = 'Bank';
                this.beneficiaryAmount1 = this.balanceTransfer;
                this.amount1Disabled = true;
                // this.beneficiary2NameOptions = [
                //     { label: 'DSA', value: 'DSA' }
                // ];
                this.beneficiaryName2 = this.finalTermReferrerName;
                if (!this.paymentToDSA) {
                    // this.beneficiary2NameOptions.push({ label: 'Borrower', value: 'Borrower' });
                    if (this.paymentToCoborrower) {
                        // this.beneficiary2NameOptions.push({ label: 'Co-borrower', value: 'Co-borrower' });
                        this.beneficiaryName2 = this.secondaryApplicantName;
                    } else {
                        this.beneficiaryName2 = this.primaryApplicantName;
                    }
                }
                break;
            case 'UPO':
                // this.beneficiary1NameOptions = [
                //     { label: 'DSA', value: 'DSA' }
                // ];
                this.beneficiaryName1 = this.finalTermReferrerName;
                if (!this.paymentToDSA) {
                    // this.beneficiary1NameOptions.push({ label: 'Borrower', value: 'Borrower' });
                    if (this.paymentToCoborrower) {
                        // this.beneficiary1NameOptions.push({ label: 'Co-borrower', value: 'Co-borrower' });
                        this.beneficiaryName1 = this.secondaryApplicantName;
                    } else {
                        this.beneficiaryName1 = this.primaryApplicantName;
                    }
                }
                break;
            case 'UIM':
                // this.beneficiary1NameOptions = [
                //     { label: 'Borrower', value: 'Borrower' }
                // ];
                this.beneficiaryName1 = this.primaryApplicantName;
                break;
            case 'RLY':
                // this.beneficiary1NameOptions = [
                //     { label: 'Co-borrower', value: 'Co-borrower' }
                // ];
                if (!this.paymentToCoborrower) {
                    // this.beneficiary1NameOptions.push({ label: 'Borrower', value: 'Borrower' });
                    this.beneficiaryName1 = this.primaryApplicantName;
                } else {
                    this.beneficiaryName1 = this.secondaryApplicantName;
                }

                break;
            case 'RLN':
                // this.beneficiary1NameOptions = [
                //     { label: 'Co-borrower', value: 'Co-borrower' }
                // ];
                if (!this.paymentToCoborrower) {
                    // this.beneficiary1NameOptions.push({ label: 'Borrower', value: 'Borrower' });
                    this.beneficiaryName1 = this.primaryApplicantName;
                } else {
                    this.beneficiaryName1 = this.secondaryApplicantName;
                }
                break;
            // default:
            // this.isDisableBeneficiaryName1 = true;
            // this.isDisableBeneficiaryName2 = true;
            // this.isDisableBeneficiaryName3 = true;
            // this.isDisableBeneficiaryName4 = true;
        }

        // if (this.beneficiary1NameOptions && this.beneficiary1NameOptions.length == 0) {
        //     this.isDisableBeneficiaryName1 = true;
        //     this.isbeneficiaryAccNo1Disabled = true;
        //     this.isDisableBeneficiaryAmount1 = true;
        // }
        if (this.beneficiaryName1 == null || this.beneficiaryName1 == '' || this.beneficiaryName1 == undefined) {
            this.isDisableBeneficiaryName1 = true;
            this.isbeneficiaryAccNo1Disabled = true;
            this.isDisableBeneficiaryAmount1 = true;
        }
        // if (this.beneficiary2NameOptions && this.beneficiary2NameOptions.length == 0) {
        //     this.isDisableBeneficiaryName2 = true;
        //     this.isbeneficiaryAccNo2Disabled = true;
        //     this.isDisableBeneficiaryAmount2 = true;
        // }
        if (this.beneficiaryName2 == null || this.beneficiaryName2 == '' || this.beneficiaryName2 == undefined) {
            this.isDisableBeneficiaryName2 = true;
            this.isbeneficiaryAccNo2Disabled = true;
            this.isDisableBeneficiaryAmount2 = true;
        }
        // if (this.beneficiary3NameOptions && this.beneficiary3NameOptions.length == 0) {
        //     this.isDisableBeneficiaryName3 = true;
        //     this.isbeneficiaryAccNo3Disabled = true;
        //     this.isDisableBeneficiaryAmount3 = true;
        // }
        if (this.beneficiaryName3 == null || this.beneficiaryName3 == '' || this.beneficiaryName3 == undefined) {
            this.isDisableBeneficiaryName3 = true;
            this.isbeneficiaryAccNo3Disabled = true;
            this.isDisableBeneficiaryAmount3 = true;
        }
        // if (this.beneficiary4NameOptions && this.beneficiary4NameOptions.length == 0) {
        //     this.isDisableBeneficiaryName4 = true;
        //     this.isbeneficiaryAccNo4Disabled = true;
        //     this.isDisableBeneficiaryAmount4 = true;
        // }
        if (this.beneficiaryName4 == null || this.beneficiaryName4 == '' || this.beneficiaryName4 == undefined) {
            this.isDisableBeneficiaryName4 = true;
            this.isbeneficiaryAccNo4Disabled = true;
            this.isDisableBeneficiaryAmount4 = true;
        }
    }

    get showBankCustomLookup1() {
        return this.loanAppVehicleSubCategory == 'UOB' || this.loanAppVehicleSubCategory == 'UPB' ? true : false;
    }

    searchField = 'Name';
    benefiId = '';
    benefiCode = '';
    isDisabled = false;
    @track dealershipNature;
    selectedBankHandler(event) {
        try {
            this.benefiId = event.detail.selectedValueId;
            getBenifRecord({ recordId: this.benefiId }).then(record => {
                console.log('record', record);
                this.beneficiaryName1 = record.length > 0 ? record[0].Name +'|'+ record[0].Ben_code__c : '';//CISP-9172
                this.benefiCode = record.length > 0 ? record[0].Ben_code__c : '';
            }).catch(error => {
                console.log(error);
            });
        } catch (e) {
            console.log('error 1142 ', e);
        }
    }

    clearBankHandler(event) {
        try {
            this.benefiId = event.detail.selectedValueId;
            this.template.querySelector('c-I-N-D_-L-W-C_-Custom_-Lookup').setFilterTerm('EFN');
        } catch (e) {
            console.log('error 1151 ', e);
        }
    }

    navigateToNextTab() {
        this.dispatchEvent(
            new CustomEvent('successfullysubmitted')
        );
    }

    async callPaymentRequestGeneration() {
        //Call Payment Request API
        //let isDealerEnabled = false;//CISP-8762
        //let isDSAEnabled = false;//CISP-8762
        let result = await isRevokedLead({'loanApplicationId':this.recordid}); 
        if(result){ 
            this.isRevokedLead = true;
            this.dispatchEvent(new ShowToastEvent({
                title: "Warning",
                message: 'This Loan Application is already Revoked',
                variant: 'warning'
            }));
            return;
        }//CISP-8762 start
        //CISP-8762end
        if(!this.isRevokedLead){
        await isPaymentRequestGenerated({ loanApplicationId: this.recordid, dealId: this.dealId})
        .then(response => {
            if (response === false) {
                doPactLmsCallout({ loanAppId: this.recordid, dealId:this.dealId })
                .then(response => {
                    this.isSpinnerMoving = false;
                    window.location.reload();
                })
                .catch(error => {
                    this.isSpinnerMoving = false;
                    this.tryCatchError = error;
                    console.log(JSON.stringify(error));
                    this.errorInCatch();
                });
            }else{
                const evt = new ShowToastEvent({
                    title: "Error",
                    message: 'The payment request is already generated.',
                    variant: 'Error',
                });
                this.dispatchEvent(evt);
            }
        })
        .catch(error => {
            console.error(error);
        });
        await this.navigateToNextTab();
        } 
    }
    callDMSDocumentUpload() {
        //Call DMS Document upload API
        doDMSUploadCallout({ applicantId: this.recordid })
            .then(response => {
                this.isSpinnerMoving = false;
                alert(JSON.stringify(response));
            })
            .catch(error => {
                this.isSpinnerMoving = false;
                this.tryCatchError = error;
                alert(JSON.stringify(error));
                this.errorInCatch();
            });
    }
    errorInCatch() {
        const evt = new ShowToastEvent({
            title: "Error",
            message: this.tryCatchError.body,
            variant: 'Error',
        });
        this.dispatchEvent(evt);
    }

    async handleRetriggerPR (){
        this.disableReTriggerPR=true;
        await isPACTLMSIntegrationLogGenerated({ loanApplicationId: this.recordid,dealId : this.dealId })
        .then(response => {
            console.log('response pact ==> ', response);
            if (response === false) {
                this.callPaymentRequestGeneration();
            }else{
                const evt = new ShowToastEvent({
                    title: "Error",
                    message: 'The payment request is already generated.',
                    variant: 'Error',
                });
                this.dispatchEvent(evt);
            }
        });
    }
    //CISP-8762 start
    oncheckRCLimitButtonForDSA(){
        this.isLoading = true;
        this.disablefields = false;//CISP-11245
        doRCLimitCheckCalloutForDSAOrDealer({applicantId: this.applicantid, loanAppId : this.recordid,callType : 'DSA', dealId: this.dealId})
          .then(result => {
            console.log('Result', result);
            this.isLoading = false;
            if(result != null){
            const obj = JSON.parse(result);
                    console.log('objobj : ',obj);
                    if(obj.response.status == 'SUCCESS'){
                        saveRCLimitResponseDetailsForDSA({loanApplicationId : this.recordid, finalTermID : this.finalTermRecordId, response : JSON.stringify(obj.response.content[0])})
                            .then(result => {
                                console.log('Result in saveRCLimitResponseDetails Function ::' , result);
                            })
                            .catch(error => {
                                this.error = error;
                                console.log('Error in saveRCLimitResponseDetails Function ::', error);
                            })
                        const event = new ShowToastEvent({
                            title: 'Success',
                            message: 'Received successful response',
                            variant: 'success',
                        });
                        this.dispatchEvent(event);
                        this.noOfProposalsAvailableForDSA = obj.response.content[0].No_Of_Proposals_Available;
                        this.availableDisbursalAmountForDSA = obj.response.content[0].Available_Disbursal_Amount;
                        console.log('No of proposals available ::' + this.noOfProposalsAvailableForDSA);
                        console.log('Available Disbursal Amount ::' + this.availableDisbursalAmountForDSA);
                        if(obj.response.content[0].Pending_Flag == 'Y'){
                            this.noOfDaysRCPendingForDSA = true;
                        }else{
                            this.noOfDaysRCPendingForDSA = false;
                        }
                        if(obj.response.content[0].Payment_To_DSA_Flag == 'Y' &&  this.paymentToDsaPhase == false){//CISP-16182
                            this.disableDSA = false;//disable payment to DSA option if flag comes as 'Y'
                        }
                        console.log('this.noOfProposalsAvailable >=1 ::' + (this.noOfProposalsAvailableForDSA >=1));
                        console.log('this.availableDisbursalAmount >= this.financeAmountForRcLimit ::' + (this.availableDisbursalAmountForDSA >= this.financeAmountForRcLimit));
                        console.log('this.noOfDaysRCPendingForDSA == true ::' + (this.noOfDaysRCPendingForDSA == true));
                        if(obj.response.content[0].RC_Limit_Cleared_Flag == 'Y'){
                            this.continueWithRCLimitForDSA = true;
                            if(!this.frompostsanction){this.isReadOnlyDSA = true;}
                        }else
                            this.continueWithRCLimitForDSA = false;
                        //this.continueWithRCLimit = true;
                        console.log('this.continueWithRCLimitForDSA ::' + this.continueWithRCLimitForDSA);
                        savecontinueWithRCLimitvalueForDSA({loanApplicationId : this.recordid, finalTermID : this.finalTermRecordId, continueWithRCLimit : this.continueWithRCLimitForDSA})
                            .then(result => {
                                console.log('Result in savecontinueWithRCLimitvalue Function ::' + result);
                            })
                            .catch(error => {
                                this.error = error;
                                console.log('Error in savecontinueWithRCLimitvalue Function ::'+ error.message);
                            })
                        }
                    else{;
                        const event = new ShowToastEvent({
                            title: 'Error',
                            message: 'Received some error in response.Please Check and try again.',
                            variant: 'error',
                        });
                        this.dispatchEvent(event);
                    }
                }
                 
          })
          .catch(error => {
            this.isLoading = false;
            console.error('Error:', error);
            const event = new ShowToastEvent({
                title: 'Error',
                message: error.body.message,
                variant: 'error',
            });
            this.dispatchEvent(event);
        });
    }
    oncheckRCLimitButtonForDealer(event){
        this.disablefields = false;//CISP-11245
        //eval("$A.get('event.force:refreshView').fire();");
        console.log('Inside oncheckRCLimitButton function in LWC' );
        this.disableRCLimitCheckButton = true;
        this.isLoading = true;
        doRCLimitCheckCalloutForDSAOrDealer({applicantId: this.applicantid, loanAppId : this.recordid,callType : 'Dealer'})
             .then(result => {
                console.log('In Then Promise');
                this.disableRCLimitCheckButton = false;
                this.isLoading = false;
                // this.dispatchEvent(event);
                 if(result!=null){
                    console.log('Result in RCLimitCheck API ::' + JSON.stringify(JSON.parse(result)));
                    const obj = JSON.parse(result);
                    console.log('objobj : ',obj);
                    //responseExpected ='{"response":{"status":"SUCCESS","respDesc":"Check RC Limit","content":[{"No_Of_Proposals_Available":"1","Available_Disbursal_Amount":"10000.00","Pending_Flag":"Y","Payment_To_DSA_Flag":"N"}]}}';
                    if(obj.response.status == 'SUCCESS'){
                        saveRCLimitResponseDetails({loanApplicationId : this.recordid, vehicleRecordId : this.vehicleRecordId, response : JSON.stringify(obj.response.content[0])})
                            .then(result => {
                                console.log('Result in saveRCLimitResponseDetails Function ::' , result);
                            })
                            .catch(error => {
                                this.error = error;
                                console.log('Error in saveRCLimitResponseDetails Function ::', error);
                            })
                        const event = new ShowToastEvent({
                            title: 'Success',
                            message: 'Received successful response',
                            variant: 'success',
                        });
                        this.dispatchEvent(event);
                        this.noOfProposalsAvailable = obj.response.content[0].No_Of_Proposals_Available;
                        this.availableDisbursalAmount = obj.response.content[0].Available_Disbursal_Amount;
                        console.log('No of proposals available ::' + this.noOfProposalsAvailable);
                        console.log('Available Disbursal Amount ::' + this.availableDisbursalAmount);
                        if(obj.response.content[0].Pending_Flag == 'Y'){
                            this.noOfDaysRCPending = true;
                        }else{
                            this.noOfDaysRCPending = false;
                        }
                        console.log('this.noOfProposalsAvailable >=1 ::' + (this.noOfProposalsAvailable >=1));
                        console.log('this.availableDisbursalAmount >= this.financeAmountForRcLimit ::' + (this.availableDisbursalAmount >= this.financeAmountForRcLimit));
                        console.log('this.noOfDaysRCPending == true ::' + (this.noOfDaysRCPending == true));
                        if(obj.response.content[0].RC_Limit_Cleared_Flag == 'Y'){
                            this.continueWithRCLimit = true;
                            if(!this.frompostsanction){this.isReadOnlyDealer = true;}
                        }else
                            this.continueWithRCLimit = false;
                        console.log('this.continueWithRCLimit ::' + this.continueWithRCLimit);
                        savecontinueWithRCLimitvalue({loanApplicationId : this.recordid, vehicleRecordId : this.vehicleRecordId, continueWithRCLimit : this.continueWithRCLimit})
                            .then(result => {
                                console.log('Result in savecontinueWithRCLimitvalue Function ::' + result);
                            })
                            .catch(error => {
                                this.error = error;
                                console.log('Error in savecontinueWithRCLimitvalue Function ::'+ error.message);
                            })
                        }
                    else{;
                        const event = new ShowToastEvent({
                            title: 'Error',
                            message: 'Received some error in response.Please Check and try again.',
                            variant: 'error',
                        });
                        this.dispatchEvent(event);
                    }
                 }

             })
             .catch(error => {
                this.disableRCLimitCheckButton = false;
                this.isLoading = false;
                 console.log('error in do rc limit callout => ' , error );
                 const event = new ShowToastEvent({
                    title: 'Error',
                    message: error.body.message,
                    variant: 'error',
                });
                this.dispatchEvent(event);
             })
    }
    closeModal() {
        this.isModalOpen = false;
        this.isReapprovalOfCam = false;
    }
    async updateCaseAndFI(){
        try{
            const result = await updateCaseFIRecords({caseList: this.caseList,fieldInvsList: this.fIList,loanApplicationId: this.recordid});
            console.log('##result', result);
            if (result === 'success') {
                console.log('2##result', result);
                return true;
            }else if(result === 'Opportunity Team member is not found'){
                return 'Opportunity Team member is not found';
            }
            console.log('3##result', result);
            return false;
        }catch(error){
            console.error(error);
            return false;
        }
    }
    showToastMessage(title,message,variant){
        const event = new ShowToastEvent({
            title: title,
            message:message,
            variant: variant,
        });
        this.dispatchEvent(event);
    }
    async updateRecordDetails(fields) {
        try{
            const recordInput = { fields };
            let result = await updateRecord(recordInput);
            this.isSpinnerMoving=false;
            console.log('record update success', JSON.stringify(fields));
            if(result){
                return true;
            }
            return false;
        }catch(error){
            this.isSpinnerMoving=false;
            const evt = new ShowToastEvent({
                title: "Error",
                message: error,
                variant: 'Error',
            });
            this.dispatchEvent(evt);
            console.log('error in record update =>', error);
            return false;
        };
    }
    showToast(info, vari) {
        const event = new ShowToastEvent({
            title: 'Message',
            message: info,
            variant: vari,
            mode: 'pester'
        });
        this.dispatchEvent(event);
    }
    async selectedNavHandler(event){
        let isSendEmail = event.detail;
        this.isModalOpen = false;
        this.isReapprovalOfCam = false;
        if(isSendEmail){
            let camFields ={};
            camFields[CAM_ID.fieldApiName] = this.camRecId;
            camFields[CAM_APPROVAL_DATE.fieldApiName] = null;
            camFields[Proposal_Status.fieldApiName] = null;
            camFields[Action_Taken.fieldApiName] = false;
            camFields[Is_CAM_Reopen.fieldApiName] = true;
            let result = await this.updateRecordDetails(camFields);
            console.log('## result cam ',result);
            if(result){
                this.showToastMessage('success','Cam Approval date updated successfully','success');
            }
        }else{
            this.showToastMessage('error','Error while submit for approval','error');
        }
    }
    async updateAssetVerification(){
        console.log('## sucessfully updated asset verification');
        this.isModalOpen = false;
        try{
             let result = await updateCaseAVRecords({loanApplicationId:this.recordid, dealId : this.dealId});
             console.log('## asset ver',result);
                this.showToastMessage('success','Asset verification created successfully !','success');
                window.location.reload();
        }catch(error){
            this.showToastMessage('error','Error while updating asset','error');
        }
    }
    async handleChange(event){
        helper.handleChangeHelper(event,this); // Moved to helper.js//SFTRAC-2189
    }
        //CISP-20786 STARTS
        handlePaymentInputChange(event) {
            this.isPaymentEMIChanged = true;
            this.isOfferEngineClicked = false;
            helper.handlePaymentInputHelper(event,this);
        }
        //SFTRAC-1896 Start
        finaltermTFRec;tfloanDealDate;tffirstEMIdueDate;tfsecEMIdueDate; isTFPaymentMadeDisabled= false; isTFOfferEngineDisabled = false; isTFOfferEngineClicked = false;isTFPaymentMadeOnInvalid = false; @track totalFundedPremium = 0; //SFTRAC-2291
        isModalOpenForTractor = false; isTFInstallmentDisabled = true; tfCRMIRR;tfGrossRR;tfNetRR; tfmincrm; tfmaxcrm; minGROSSIRR; maxGROSSIRR;    showInstallmentModel = true; isStructured =  false; isIRRBreached = false; isAllowPACTAPI = false/*SFTRAC-2291*/
        //handleTFPaymentInputChange(event) {this.isOfferEngineClicked = false; helper.handleLoanDateCalHelper(event,this);} //Commented for SFTRAC-2262
        handleTFOfferEngine(){helper.handleTFOfferEngineCalloutHelper(this);}
        handleTFInstallment(){this.isModalOpenForTractor = true;}
        closeModal(){this.isModalOpenForTractor = false;this.isModalOpen = false;this.isReapprovalOfCam = false;}
        //SFTRAC-1896 End
        handleFirstEMICahngeHandler(event){
            this.isPaymentEMIChanged = true;
            this.isOfferEngineClicked = false;
            let firstEmiChanged = event.target.value;helper.calculateSecEmi(firstEmiChanged,this);
        }
        get isNotTractor(){return !this.isTractor;}
        handleInstallmentSchedule(){this.isISModalOpen = true;}
        handleCloseModal(){this.isISModalOpen=false;}
        handleInsSubmit(){this.isISModalOpen=false;this.isInsSubmitted = true;}
        handleOfferEngine(){helper.handleOfferEngineCalloutHelper(this);}
        // async handleTriggerIRRDev(){await helper.generateDeviations(this);}
        handleRevoke(){helper.handleRevokeHelper(this);}
        closeRevokeModal() {this.showRevokeModal = false;}
        handleRevokeConfirm(){helper.handleRevokeConfirmHelper(this);}
        handleUserSelection(event){helper.handleUserSelectionHelper(event,this);}
        clearUserSelection(event){helper.clearUserSelectionHelper(event,this);}
        triggerDeviationsClick(){helper.triggerDeviationsClickHelper(this);}
        //CISP-20786 ENDS
    
}