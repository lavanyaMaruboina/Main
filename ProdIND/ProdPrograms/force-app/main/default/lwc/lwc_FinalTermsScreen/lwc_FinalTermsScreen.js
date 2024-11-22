import { LightningElement, wire, track, api } from 'lwc';    
import { getIESresponse,calculateProvisionAmt,checkInput,roundOff,handleChangesubDealer,journeyStopScenarioFound,scorecardvalue,dsmNameDatahelper,nonDsmNameDatahelper, getParsedJSOND2C,customLabels,getApplicationDetailsHelper,repaymentModePickListValueHelper,getRecordDetailsHelper,verifyAmountLessthan10,getMedianPayout,showPayoutWarning,validateSelectedScheme,recalculatePayoutValues,scorecardvalueHero,handleOptionsRelatedListsHelper} from './lwc_FinalTermsScreenHelper';
import * as helper from './lwc_FinalTermsScreenHelper';
import * as helperTwo from './lwc_FinalTermsScreenSecondHelper';
import getFinalTermFieldDetails from '@salesforce/apex/FinalTermscontroller.getFinalTermFieldValidationDetails';
import loadSchemeData from '@salesforce/apex/FinalTermscontroller.loadSchemeData';
import callCheckSchemeEligibility from '@salesforce/apex/FinalTermscontroller.checkSchemeEligibility';
import getApiOutput from '@salesforce/apex/FinalTermscontroller.getApiOutput';
import TradeCertificateValidation from '@salesforce/apex/customerDedupeRevisedClass.TradeCertificateValidation';
import createFinalTermRecord from '@salesforce/apex/FinalTermscontroller.createFinalTermRecord';
import fetchProductType from '@salesforce/apex/FinalTermscontroller.fetchProductType';
import checkRetryExhausted from '@salesforce/apex/FinalTermscontroller.checkRetryExhausted';
import retryCountIncrease from '@salesforce/apex/FinalTermscontroller.retryCountIncrease';
import getFinalTermRecord from '@salesforce/apex/FinalTermscontroller.getFinalTermRecord';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import OPP_ID_FIELD from '@salesforce/schema/Opportunity.Id';
import STAGENAME from '@salesforce/schema/Opportunity.StageName';
import LASTSTAGENAME from '@salesforce/schema/Opportunity.LastStageName__c';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getRecord,updateRecord } from 'lightning/uiRecordApi';
import Final_Term__c from '@salesforce/schema/Final_Term__c';
import isCommunity from '@salesforce/apex/LwcLOSLoanApplicationCntrl.isCommunity';
import Journey_Status from '@salesforce/schema/Opportunity.Journey_Status__c';
import Journey_Stop_Reason from '@salesforce/schema/Opportunity.Journey_Stop_Reason__c'
import final_ID_FIELD from '@salesforce/schema/Final_Term__c.Id';
import OfferengineMaxTenure from '@salesforce/schema/Final_Term__c.OfferengineMaxTenure__c';
import OfferengineMinTenure from '@salesforce/schema/Final_Term__c.OfferengineMinTenure__c';
import OfferengineStopJourneyFlag from '@salesforce/schema/Final_Term__c.Offerengine_StopJourney_Flag__c';
import OfferengineMinLoanAmount from '@salesforce/schema/Final_Term__c.OfferengineMinLoanAmount__c';
import OfferengineMaxLoanAmount from '@salesforce/schema/Final_Term__c.OfferengineMaxLoanAmount__c';
import fiWiver_currentAddress from '@salesforce/schema/Final_Term__c.FIwaiver_currentAddress__c';
import fiWaiver_offAddress from '@salesforce/schema/Final_Term__c.FIwaiver_offAddress__c';
import FIwaiver_presentAddress from '@salesforce/schema/Final_Term__c.FIwaiver_presentAddress__c';
import fiWiver_co_currentAddress from '@salesforce/schema/Final_Term__c.FIwaiver_co_currentAddress__c';
import fiWaiver_co_offAddress from '@salesforce/schema/Final_Term__c.FIwaiver_co_offAddress__c';
import FIwaiver_co_presentAddress from '@salesforce/schema/Final_Term__c.FIwaiver_co_presentAddress__c';
import IsFiWaiverApiSucces from '@salesforce/schema/Final_Term__c.IsFiWaiverApiSucces__c';
import LtvEngine_Ltv from '@salesforce/schema/Final_Term__c.LtvEngine_Ltv__c';
import PricingEngine_thresholdNetrr from '@salesforce/schema/Final_Term__c.PricingEngine_thresholdNetrr__c';
import Net_Pay_Ins from '@salesforce/schema/Final_Term__c.Net_Pay_Ins__c';
import Net_Pay_Outs from '@salesforce/schema/Final_Term__c.Net_Pay_Outs__c';
import EMI_Amount from '@salesforce/schema/Final_Term__c.EMI_Amount__c';
import Tenure from '@salesforce/schema/Final_Term__c.Tenure__c';
import Loan_Amount from '@salesforce/schema/Final_Term__c.Loan_Amount__c';
import CRM_IRR from '@salesforce/schema/Final_Term__c.CRM_IRR__c';
import Required_CRM_IRR from '@salesforce/schema/Final_Term__c.Required_CRM_IRR__c';
import doD2COfferEngineCallout from '@salesforce/apexContinuation/D2C_IntegrationEngine.doD2COfferEngineCallout';
import Repayment_mode from '@salesforce/schema/Final_Term__c.Repayment_mode__c';
import Inputted_IRR from '@salesforce/schema/Final_Term__c.Inputted_IRR__c';
import Net_IRR from '@salesforce/schema/Final_Term__c.Net_IRR__c';
import Net_IRR_DECIMAL from '@salesforce/schema/Final_Term__c.Net_IRR_Decimal__c';
import Gross_IRR from '@salesforce/schema/Final_Term__c.Gross_IRR__c';
import isNavigate from '@salesforce/schema/Final_Term__c.isNavigate__c';
import customer_code from '@salesforce/schema/Applicant__c.Customer_Code__c';
import PassengerVehicles from '@salesforce/label/c.PassengerVehicles';
import TwoWheeler from '@salesforce/label/c.TwoWheeler';
import KindlyRetryField from '@salesforce/label/c.Kindly_Retry';
import RetryExhausted from '@salesforce/label/c.Retry_Exhausted';
import CreditProcessing from '@salesforce/label/c.Credit_Processing';
import Final_Terms from '@salesforce/label/c.Final_Terms';
import FivePercentageOfAmount from '@salesforce/label/c.FivePercentageOfAmount';
import tenPercentageOfAmount from '@salesforce/label/c.tenPercentageOfAmount';
import noPayout from '@salesforce/label/c.noPayout';
import FinalTerms from '@salesforce/label/c.FinalTerms';
import nonDlrDsmError from '@salesforce/label/c.nonDlrDsmError';
import RegEx_Alphabets_Only from '@salesforce/label/c.RegEx_Alphabets_Only';
import monitoriumDays from '@salesforce/label/c.monitoriumDays';
import rtoPrefix from '@salesforce/label/c.rtoPrefix';
import doOfferEngineCallout from '@salesforce/apexContinuation/IntegrationEngine.doOfferEngineCallout';
import doCSRVahanFIwaiverCallout from '@salesforce/apexContinuation/IntegrationEngine.doCSRVahanFIwaiverCallout';
import doLTVEngineCallout from '@salesforce/apexContinuation/IntegrationEngine.doLTVEngineCallout';
import doPricingEngineCallout from '@salesforce/apexContinuation/IntegrationEngine.doPricingEngineCallout';
import validValue from '@salesforce/label/c.validValue';
import getLoanApplicationHistory from '@salesforce/apex/LwcLOSLoanApplicationCntrl.getLoanApplicationHistory';
import accessLoanApplication from '@salesforce/apex/LwcLOSLoanApplicationCntrl.accessLoanApplication';
import reffnamedata from '@salesforce/apex/IND_VehicleInspectionRCLimitDetails.reffnamedata';
import getLoanApplicationReadOnlySettings from '@salesforce/apex/LwcLOSLoanApplicationCntrl.getLoanApplicationReadOnlySettings';
import getbenefitioryDetails from '@salesforce/apex/FinalTermscontroller.getbenefitioryDetails';//CISP-4784
import checkRCLimitBasedOnBencode from '@salesforce/apex/IND_AssetDetailsCntrl.checkRCLimitBasedOnBencode';//CISP-8762
import RC_limit_enabled_DSA from '@salesforce/schema/Final_Term__c.RC_limit_enabled_DSA__c';//CISP-8762
import IsOfferEngineApiFailed from '@salesforce/schema/Final_Term__c.IsOfferEngineApiFailed__c';
import Table_Code from '@salesforce/schema/Final_Term__c.Table_Code__c';//CISP-16547 
import DR_Penal_Interest from '@salesforce/schema/Final_Term__c.DR_Penal_Interest__c';//CISP-16547
import Interest_Version_No from '@salesforce/schema/Final_Term__c.Interest_Version_No__c';//CISP-16547
import mclrRate from '@salesforce/schema/Final_Term__c.mclrRate__c';//CISP-16547  
import Service_charges from '@salesforce/schema/Final_Term__c.Service_charges__c';
import Provisional_Channel_Cost from '@salesforce/schema/Final_Term__c.Provisional_Channel_Cost__c';
import Mfr_incentive from '@salesforce/schema/Final_Term__c.Mfr_incentive__c';
import Dealer_incentive_amount_main_dealer from '@salesforce/schema/Final_Term__c.Dealer_incentive_amount_main_dealer__c';
import Documentation_charges from '@salesforce/schema/Final_Term__c.Documentation_charges__c';
import Loan_Deal_Date from '@salesforce/schema/Final_Term__c.Loan_Deal_Date__c';
import First_EMI_Date from '@salesforce/schema/Final_Term__c.First_EMI_Date__c';
import Second_EMI_Date from '@salesforce/schema/Final_Term__c.Second_EMI_Date__c';
import OE_Agreement_Amount from '@salesforce/schema/Final_Term__c.Offer_Agreement_Amount__c';
import saveInstallmentSchedule from '@salesforce/apex/InstallmentScheduleController.saveInstallmentSchedule';
// import resetFinalTermEMI from '@salesforce/apex/FinalTermscontroller.resetFinalTermEMI';
import getRecentEMIdetails from '@salesforce/apex/InstallmentScheduleController.getRecentEMIdetails';
import roiMasterForGrossIRR from '@salesforce/apex/IND_OfferScreenController.roiMasterForGrossIRR';//CISP-20504
import getPurchaseprice from '@salesforce/apex/IND_OfferScreenController.getPurchaseprice'; //SFTRAC-909
export default class Lwc_FinalTermsScreen extends NavigationMixin(LightningElement){
    isFoirStop=true;foirCheckFT=false;loanAmtForCal = 0;isTWRefinance=false;manufacturerCodeList;serMaxPercentage=0;serMinPercentage=0;docMaxAmount=0;docMinPercentage=0;docMaxPercentage=0;docMaxPercentage=0;payinMax=0;payoutMax=0;dealerSubDealer;
    labelCustom = customLabels;disabledDocumentationCharges= false;disabledServiceCharges = false;//CISP-6058
    hideReferrerFields=false;isReferrerNameRequired=false;/*CISP-3143*/isSubDealer=true;/*CISP-13993*/isCustomerDedupeSubmit=false;disableAllPayoutFields=false;nonD2cDsaTW=false;showErrModal=false;modalErrFlds=[]; buttonLabel='Check Eligibility';showOrHideStyle='';//CISP-4785
    mainDlrIncentivePercentMedian;subDlrIncentivePercentMedian;dsmIncentive1PercentMedian;dsmIncentive2PercentMedian;@api fromVfPage;previousLoanAmount;timeOut=null;//CISP-4785
    @track isPVUsedAndRefinance = false;@track isRcLimitChecked = false;@api vehicleSubType;@api vehicleId;isFinaltermSubmit=false;
    @api checkleadaccess;@track monitoriumDaysDisabled=false;@track mfrExpReimbursePercentageValue;@track dealerExpReimbursePercentageValue;@track ecsOption;@track ecsValue;@track referredbyValue;@track serviceChargesValue;@track retryPopUp=false;@track isSpinnerMoving=false;@track schemeOptions;@track isEnableNext=false;@track disabledCheckEligibility=false;@track finalTermId;@track offerEngineFlag=false;@track uploadViewDocFlag=false;@track showfieldvalue=true;@track showFileUploadAndView=false;@api recordid;@api applicantId;@api activetab;@api showUpload;@api showDocView;@api isVehicleDoc;@api isAllDocType;@api currentStage;@api apiMessage;@track twNew=false;@track twRefinance=false;@track validationFlag=true;@track popFlag=false;@track mapData=new Array();@track currentStageName;@track lastStage;disaibleInstalmentSchedule=false;
    disabledReferrerName=false;advanceEmiDisabled=false;disabledDealNo=true;disabledEmpName=true;disabledEmpNo=true;disabledrepay=false;imageUploadRedCross=false;iconButtonCaptureUpload=false;disabledBranch=true;disabledDsaPay=false;disabledRcu=false;disabledManufacturerIncentive=false;disabledProvisionalChannelCost=false;displayDsaRcu=false;minchargeVal=false;scorecardvalue;disabledDealerDiscounttoCustomer=true;disabledDealerIncentiveAmountMainDealer = true;disabledGiftThroughDealerAmount = true; repaymentModeOptionsBk;
    @track phdealerExpReimburseAmountValue=0;@track phserviceChargesValue=0;@track phdocumentationChargesValue=0;@track phdealerIncentiveAmountSubValue=0;@track phdealerIncentiveAmountMainValue=0;@track phdealerDiscounttoCustomerValue=0;@track phdsmIncentiveOneValue=0;@track phnonDlrDsmIncentiveOneValue=0;@track phnonDlrDsmIncentiveTwoValue=0;@track phdsmIncentiveTwoValue=0;@track phgiftThroughDealerAmountValue=0;@track phmfrExpReimburseAmtValue=0;@track phprovisionalChannelCostValue=0;@track phreferrerIncentiveValue=0;@track phdealerExpReimbursePercentageValue=0;@track phmfrExpReimbursePercentageValue=0;@track provisionalChannelCostValueTemp;loanAmountDetail;requiredTenureDetails;requiredLoanAmount;productTypeDetail;vehicleSubCategoryDetail;requiredCrmIRR;vehicleTypeDetail;vehicleDelivered;makeCode;offerEngineLoanAmount;offerEngineTenure;documentChargesFinAmountValid;documentChargesPercentageValid;dealerDiscounttoCustomerValdealerExpReimburseValid;dealerIncentiveAmountMainDealerValdealerIncentiveAmountSubDealerValid;dsmIncentiveOneValid;dsmIncentiveTwoValgiftThroughDealerAmountValid;mfrExpReimburseAmtValid;ManufacturerIncentiveValnonDlrDsmIncentiveOneValid;nonDlrDsmIncentiveTwoValid;provisionalChannelCostValprovisionalChannelCostMaxValid;provisionalChannelCostMinValprovisionalChannelCostTwoValid;provisionalChannelCostSValid;serviceChargesValueValserviceChargesValueMaxValid;serviceChargesValueMinValid;stampingChargesValdocumentChargesMinAmountValid;dealerExpReimbursePercentValid;mfrExpReimbursePercentValreferrerIncentiveValid;documentChargesMinPercValid;
    advanceEmiValue;advanceEMi=false;temp;schemeOptionsValue;checkMfrExpReimburseAmt;checkDealerExpReimburseAmouncheckDealerDiscounttoCustomer;checkNonDlrDsmIncentiveOncheckdealerExpReimbursePercentageValue;checkmfrExpReimbursePercentageValue;subStagfundingOnORP;fundingOnExShowroom;basicPrice;invoiceAmt;totalFundedPremium = 0 ;rtoAlnu;@track dsmNameOneOption;dsmNameTwoOption;monitoriumDaysValue='0';value='';maxAmount;currentscreen;documentationChargesValue;rtoPrefixValue;stampingChargesValue;nonDlrDsmNameOneValue;nonDlrDsmNameTwoValue;empNameValue=0;dealerExpReimburseTypeValue;dealNoValue;dsaPayValue;installmentTypeValue='Equated';repaymentModeValue;dueDateShiftChargesValue;verificationChargesValue;referrerIncentiveValue;delinquencyFundValue;delinquencyFundTypeValue;referrerNameValue;grossIRRValue;dsmNameOneValue;agreementAmountValueemiValue;tradeCertificateValue=0;mfrExpReimburseTypeValue;manufacturerIncentiveValue;rcuRetentionChargesValue;netIrrValue;bankIrrValue;inputtedIrrValue;empNoValue=0;fundingForBody;fundingForChassis;@track showFundingInfo = false;customerType; @track loanDealDate; @track firstEMIDate; @track secondEMIDate;
    presentAddress = '';currentAddress = '';offAddress = '';coPresentAddress = '';coCurrentAddress = '';coOffAddress = '';@track isTopUpLoan = false;isUsed = false;OEMDealer;mingross;maxgross;productSegment;//CISP-20504
    @track isD2C = false;@track finalTermDataD2C;dsmNameTwoValue;ltv;thresholdNetIRR;dsmIncentiveTwoValue=0;branchValue;dealerIncentiveAmountMainValue;dealerExpReimburseAmountValue;dsmIncentiveOneValue=0;disabledDsmIncentiveTwo=true;disabledDsmIncentiveOne=true;disablednonDlrDsmIncentiveOne=true;disablednonDlrDsmIncentiveTwo=true;dealerIncentiveAmountSubValue;dealerDiscounttoCustomerValue;giftThroughDealerAmountValue;nonDlrDsmIncentiveOneValue=0;nonDlrDsmIncentiveTwoValue=0;mfrExpReimburseAmtValue;nonDlrDsmIncentiveTwoschemeData;flagToCheckValidity=false;flagToCheckInValidScheme=false;isNavigateValue=false;offerScreenLoanAmount;ids;@track nonDlrDsmNameOneOption;nonDlrDsmNameTwoOption;
    isFiWaiverApiSuccessValue;ltvEngineValue;pricingEnginethresholdNetIrrValue;loanAmtValue;fiwaiverPresentAddressValue;finanaceAmountFlag = false;financeAmount = 0;disableDsmName1 = false;disableDsmName2 = false;disableNonDsmName1 = false;disableNonDsmName2 = false;disableStampingCharges;disabledueDateShiftCharges;
    label = {rtoPrefix,KindlyRetryField,CreditProcessing,Final_Terms,RegEx_Alphabets_Only,validValue}
    dealerMainPercentageValue;dealerSubPercentageValue;giftThroughDealerPercentageValue;mfrIncentivePercentageValue;dsmOnePercentageValue;dsmTwoPercentageValue;payoutCapValue;disableDealerMainPercentage=false;disableDealerSubPercentage=false;disableGiftThroughDealerPercentage=false;disableMfrIncentivePercentage=false;disabledsmOnePercentage=false;disableDsmTwoPercentage=false;fromScheme=false;DsmInc1fromScheme=false;DsmInc2fromScheme=false;forTwoWheeler=false;finaltermSchemeId;serVal=false;docVal=false;disableTradeCertificate=true;haveHeroMIValue=false;  dsaReferrerval; dsaReferrer=false;DSAName;finaltermServiceCharge;
    finaltermDocumentCharge;@track referrerNameOptions = [];@track leadSource;disableInstallmentType = false;@track provisionalChannelCostValueOla;@track mfrIncentiveHero;olaNextVisible = false;exShowroom;ORP;disabledDealerIncentiveAmountSubDealer;isRefinance=false;repaymentFrequency;installMentType;//SFTRAC-1795 added repaymentFrequency and installMentType
    isExistingCustomer=false;@track applicantsList;installmentFrequency;installmentFrequencyValue;@api numberOfVehicles;//sftrac-84-nofv
    oppOwnerId;isPv;schemeInsTypes;schemeInsFrequency;changePayInOutEditable;firstemidate;emidate;x2EmiDate;isModalOpen=false;secondemidate;isInsSubmitted=false;isNotD2C=false;enableInsSchedule=false;@track emidatelist=[];emidisable=false;isNewCustomer = false;//CISP-21214
    @wire(getRecord, { recordId: '$applicantId', fields: [customer_code] })applicantData({data,error}){if(data){this.isExistingCustomer = data.fields.Customer_Code__c.value!=null ? true : false;}}
    @wire(getObjectInfo, { objectApiName: Final_Term__c }) objectInfo;
    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: Repayment_mode }) repaymentModeOption;
    handleMfrExpReimburseType(event){this.mfrExpReimburseTypeValue=event.target.value;}
    handleUploadViewDoc(){this.showUpload=true;this.showDocView=true;this.isVehicleDoc=false;this.isAllDocType=true;this.uploadViewDocFlag=true;}
    changeflagvalue() { this.uploadViewDocFlag = false; }
    /*CISP-4785*/hideErrModal(){this.showErrModal=false;}handleYesChoice(){this.showErrModal=false;this.handleCheckEligibilityButton();}
    handleDelinquencyFundType(event) {this.delinquencyFundTypeValue = event.target.value;}
    handleRCURetentionCharges(event) {this.rcuRetentionChargesValue = event.target.value;helper.rcuRetentionCharges(this);}
    handleBankIRR(event) { this.bankIrrValue = event.target.value; }
    handleNonDlrDsmNameTwo(event) {this.disablednonDlrDsmIncentiveTwo = false;this.nonDlrDsmIncentiveTwoValue = null;this.nonDlrDsmNameTwoValue = event.target.value;let elem = this.template.querySelector('.dlrdsmName2');elem.setCustomValidity('');if (this.nonDlrDsmNameOneValue === this.nonDlrDsmNameTwoValue) {elem.setCustomValidity(nonDlrDsmError);}elem.reportValidity();}
    handleDealerExpReimbursePercentage(event) {this.dealerExpReimbursePercentageValue = event.target.value;this.dealerExpReimburseAmountValue = roundOff((this.dealerExpReimbursePercentageValue * parseInt(this.requiredLoanAmount, 10)) / 100);helper.dealerExpReimbursePercentage(this);}
    handleMfrExpReimbursePercentage(event) {this.mfrExpReimbursePercentageValue = event.target.value;this.mfrExpReimburseAmtValue = roundOff((this.mfrExpReimbursePercentageValue * parseInt(this.requiredLoanAmount, 10)) / 100);helper.mfrExpReimbursePercentage(this);}
    handleEmpNo(event){this.empNoValue=event.target.value;}
    handleEmpName(event){this.empNameValue=event.target.value;}
    handleDealerExpReimburseType(event){this.dealerExpReimburseTypeValue=event.target.value;}
    handleDealNo(event){this.dealNoValue=event.target.value;}
    handleRepaymentMode(event){this.repaymentModeValue=event.target.value;}
    handleInputtedIRR(event){this.inputtedIrrValue=event.target.value;}
    handleNetIRR(event){this.netIrrValue=event.target.value;}
    handlereferrerIncentive(event){this.referrerIncentiveValue=roundOff(event.target.value);helper.referrerIncentive(this);}
    handleRTOPrefix(event) {this.rtoPrefixValue = event.target.value;helper.rtoPrefixFunction(this);}
    handleInstallmentType(event) {/*this.installmentTypeValue = event.target.value;*/helper.installmentsType(this,event);}  //SFTRAC-1795 added event and moved logic to helper
    handleFundingForChassis(event) { this.fundingForChassis = event.target.value; }
    handleFundingForBody(event) { this.fundingForBody = event.target.value; }
    handleDsmNameTwo(event) {this.dsmNameTwoValue=event.target.value;if(this.DsmInc2fromScheme===false){this.dsmIncentiveTwoValue=null;if(!this.dsmNameTwoValue && this.isTractor){this.dsmIncentiveTwoValue=0;this.phdsmIncentiveTwoValue=0;this.disabledDsmIncentiveTwo=true;}else{this.disabledDsmIncentiveTwo=false;}this.disableDsmTwoPercentage=false;}helper.dsmNameTwo(this);}
    handleDSAPay(event) {this.dsaPayValue = event.target.value;helper.dsaPay(this);}
    handleEcsVerification(event) {this.ecsValue = event.target.value;}
    async handleReferrerName(event) {this.referrerNameValue = event.target.value;
    if(this.isPVUsedAndRefinance == true){let referrerName =await this.referrerNameOptions.find(opt => opt.value === this.referrerNameValue).label;
        let splitBenCode = referrerName.split('|'); let benCode = splitBenCode[1];console.log('OUTPUT benCode: ',benCode);this.checkRCLimitEnable(benCode.trim());}
    }//CISP-8762
    checkRCLimitEnable(benCode){
        checkRCLimitBasedOnBencode({ benCodeValue : benCode }).then(result => {this.isRcLimitChecked = result;}).catch(error => { console.error('Error:', error);});
    }
    handleDsmNameOne(event) {this.dsmNameOneValue = event.target.value;if(this.DsmInc1fromScheme===false){this.dsmIncentiveOneValue = null;if(!this.dsmNameOneValue && this.isTractor){this.dsmIncentiveOneValue=0;this.phdsmIncentiveOneValue=0;this.disabledDsmIncentiveOne=true;}else{this.disabledDsmIncentiveOne = false;}this.disabledsmOnePercentage=false;}helper.dsmNameOne(this);}
    handleBranch(event){this.branchValue=event.target.value;}

    handleVerificationCharges(event) {this.verificationChargesValue = event.target.value;helper.verificationCharges(this);}

    handleDelinquencyFund(event) {this.delinquencyFundValue = event.target.value;helper.delinquencyFund(this);}
    handleNonDlrDsmNameOne(event){this.disablednonDlrDsmIncentiveOne=false;this.nonDlrDsmIncentiveOneValue=null;this.nonDlrDsmNameOneValue=event.target.value;
        let elem=this.template.querySelector('.dlrdsmName2');elem.setCustomValidity('');if(this.nonDlrDsmNameOneValue===this.nonDlrDsmNameTwoValue){elem.setCustomValidity(nonDlrDsmError);}elem.reportValidity();}
    handleTradeCertificate(event){this.tradeCertificateValue=event.target.value;}
    handleInstallmentFrequency(event){/*this.installmentFrequencyValue =event.target.value;*/helper.installmentsFrequency(this,true,event);}//SFTRAC-1795 added event and moved logic to helper
    handleReferredby(event){if(this.isTractor && this.isUsed && this.dealerSubDealer && event.target.value == 'Ref. ref.'){event.target.value = null;this.referredbyValue = event.target.value;this.toastMsg('Ref. ref. is not applicable as dealer is already selected.');this.referredby(this.referredbyValue);}else{this.referredbyValue=event.target.value;this.referredby(this.referredbyValue);}}

    referredby(referredbyValue){this.isReferrerNameRequired = false;if(referredbyValue==='Bank branch referral'){this.dsaPayValue='';this.disabledDsaPay=true;this.disabledBranch=false;this.disabledEmpName=false;this.disabledEmpNo=false;this.disabledReferrerName=true;this.referrerNameValue='';this.disabledReferrerIncentive=true;this.referrerIncentiveValue='';this.disabledDealNo=true;this.dealNoValue='';this.isRcLimitChecked=false;}else if(this.referredbyValue==='CFD ref.'){this.dsaPayValue='';this.disabledDsaPay=true;this.disabledBranch=false;this.disabledEmpName=false;this.disabledEmpNo=false;this.disabledReferrerName=true;this.referrerNameValue='';this.disabledReferrerIncentive=true;this.referrerIncentiveValue='';this.disabledDealNo=true;this.dealNoValue='';this.isRcLimitChecked=false;} else if(this.referredbyValue==='Existing Customer Referral'){this.dsaPayValue='';this.disabledDsaPay=true;this.disabledDealNo=false;this.disabledBranch=true;this.branchValue='';this.disabledEmpName=true;this.empNameValue='';this.disabledEmpNo=true;this.empNoValue='';this.disabledReferrerName=true;this.referrerNameValue='';this.disabledReferrerIncentive=true;this.referrerIncentiveValue='';this.isRcLimitChecked=false;} else if(this.referredbyValue==='Ref. ref.'){this.isReferrerNameRequired = true;this.disabledDsaPay=true;this.disabledReferrerIncentive=false;this.disabledBranch=true;this.branchValue='';this.disabledEmpName=true;this.empNameValue='';this.disabledEmpNo=true;this.empNoValue='';this.disabledReferrerName=false;this.disabledDealNo=true;this.dealNoValue='';this.isRcLimitChecked=false;
            //DSA Changes
    if(this.productTypeDetail.toLowerCase() === 'Passenger Vehicles'.toLowerCase()){    if(this.referrerNameValue && this.referrerNameOptions.length>0){
        let referrerNameVal=this.referrerNameOptions.find(opt => opt.label === this.referrerNameValue).value; if(referrerNameVal){let splitBenCode = referrerNameVal.split('|'); let benCode = splitBenCode[1];console.log(benCode,'benCode22');this.checkRCLimitEnable(benCode.trim())};
       }
    }
}else{this.dsaPayValue='';this.disabledDsaPay=true;this.disabledDealNo=true;this.dealNoValue='';this.disabledEmpName=true;this.empNameValue='';this.disabledEmpNo=true;this.empNoValue='';this.disabledReferrerIncentive=true;this.referrerIncentiveValue='';this.disabledBranch=true;this.branchValue='';this.disabledReferrerName=true;this.referrerNameValue='';this.isRcLimitChecked=false;}
}
    handleMonitoriumDays(event){let elem=this.template.querySelector('.monDay');elem.setCustomValidity("");elem.reportValidity();this.monitoriumDaysValue=event.target.value;this.advanceEmiDisabled=true;if(this.monitoriumDaysValue==='0'){let advanceEMiInput=this.template.querySelector('lightning-input[data-id=advanceEMIid]');this.advanceEMi=true;advanceEMiInput.checked=true;this.advanceEmiDisabled=false;this.advanceEmiValue=true;}if((this.monitoriumDaysValue === '30' && this.isNotTractor) || (this.monitoriumDaysValue === '30' && this.isTractor && this.installmentFrequencyValue == 'Monthly')){this.advanceEmiDisabled = false;this.advanceEmiValue = false;this.advanceEMi = false;}if(this.isTractor && this.installmentFrequencyValue != 'Monthly'){this.advanceEmiValue = false;this.advanceEMi = false;}if(this.isNotD2C && this.isNotTractor){helperTwo.getEmiDateList(this);}helperTwo.handleLoanDateCalHelper(this);}
    handleDocumentationCharges(event) {this.isSubmit=false;this.documentationChargesValue = roundOff(event.target.value);this.checkDocumentationCharges();}
    handleStampingCharges(event) {this.stampingChargesValue = event.target.value;helper.stampingCharges(this);}
    handleDueDateShiftCharges(event) {this.dueDateShiftChargesValue = event.target.value;helper.dueDateShiftCharges(this);}
    handleServiceCharges(event) {this.isSubmit=false;this.serviceChargesValue = roundOff(event.target.value);this.checkServiceCharges();}
    handleDealerExpReimburseAmount(event) {this.dealerExpReimburseAmountValue = roundOff(event.target.value);this.dealerExpReimbursePercentageValue = (100 - ((parseInt(this.requiredLoanAmount, 10) - this.dealerExpReimburseAmountValue) / parseInt(this.requiredLoanAmount, 10) * 100)).toFixed(2);helper.dealerExpReimburseAmount(this);}
    handleDealerIncentiveAmountSubDealer(event) {this.dealerIncentiveAmountSubValue = roundOff(event.target.value);this.dealerSubPercentageValue = ((this.dealerIncentiveAmountSubValue / this.requiredLoanAmount)*100).toFixed(2);helper.dealerIncentiveAmountSub(this);/*CISP-4785 Start*/(event.target).addEventListener('keyup', this.debounce( () => {if(this.dealerSubPercentageValue == 0 && this.nonD2cDsaTW){showPayoutWarning(this,'zero');}else if(this.dealerSubPercentageValue < this.subDlrIncentivePercentMedian && this.nonD2cDsaTW){showPayoutWarning(this,'lower');}else if(this.dealerSubPercentageValue > this.subDlrIncentivePercentMedian && this.nonD2cDsaTW){showPayoutWarning(this,'higher');}},1000));/*CISP-4785 End*/}handleRetry(){this.retryPopUp=false;}
    handleDealerIncentiveAmountMainDealer(event) {this.dealerIncentiveAmountMainValue = roundOff(event.target.value);this.dealerMainPercentageValue = ((this.dealerIncentiveAmountMainValue / this.requiredLoanAmount)*100).toFixed(2);helper.dealerIncentiveAmountMain(this);/*CISP-4785 Start*/(event.target).addEventListener('keyup', this.debounce( () => {if(this.dealerMainPercentageValue == 0 && this.nonD2cDsaTW){showPayoutWarning(this,'zero');} else if(this.dealerMainPercentageValue < this.mainDlrIncentivePercentMedian && this.nonD2cDsaTW){showPayoutWarning(this,'lower');}else if(this.dealerMainPercentageValue > this.mainDlrIncentivePercentMedian && this.nonD2cDsaTW){showPayoutWarning(this,'higher');}},1000));/*CISP-4785 End*/}
    handleDealerDiscounttoCustomer(event) {this.dealerDiscounttoCustomerValue = roundOff(event.target.value);helper.dealerDiscounttoCustomer(this);}
    handleDsmIncentiveOne(event) {this.dsmIncentiveOneValue = roundOff(event.target.value);this.dsmOnePercentageValue=((this.dsmIncentiveOneValue / this.requiredLoanAmount)*100).toFixed(2);helper.dsmIncentiveOne(this);/*CISP-4785 Start*/(event.target).addEventListener('keyup', this.debounce( () => {if(this.dsmOnePercentageValue == 0 && this.nonD2cDsaTW){showPayoutWarning(this,'zero');} else if(this.dsmOnePercentageValue < this.dsmIncentive1PercentMedian && this.nonD2cDsaTW){showPayoutWarning(this,'lower');} else if(this.dsmOnePercentageValue > this.dsmIncentive1PercentMedian && this.nonD2cDsaTW){showPayoutWarning(this,'higher');}},1000));/*CISP-4785 End*/}handleSaveAndExit(){this.navigateToHomePage();}
    callLoanApplicationHistory(nextStage){getLoanApplicationHistory({ loanId: this.recordid, stage: 'Final Terms', nextStage: nextStage }).then(response => {if(response){this.navigateToHomePage(); }else{ this.dispatchEvent(new CustomEvent('submitnavigation', { detail: nextStage })); } });}
    callAccessLoanApplication(){accessLoanApplication({ loanId: this.recordid, stage: 'Final Terms' }).then(response => {if(!response && !this.fromVfPage){this.disableEverything();if(this.checkleadaccess){const evt=new ShowToastEvent({title: this.labelCustom.ReadOnlyLeadAccess,variant: 'warning',mode: 'sticky'});this.dispatchEvent(evt);this.disableEverything();}}});}

    moveToOfferScreen(){
        let nextStage='Offer Screen';const oppFields={};oppFields[OPP_ID_FIELD.fieldApiName]=this.recordid;oppFields[STAGENAME.fieldApiName]=nextStage;oppFields[LASTSTAGENAME.fieldApiName]=nextStage;this.updateRecordDetails(oppFields);if(this.updateRecordDetails(oppFields)){this.callLoanApplicationHistory(nextStage);}
    }
    handlesubdealer(event){
        handleChangesubDealer(roundOff(event.target.value),this.template); 
    }
    // CISP-19438 Start
    callResetFinalTermEMI(){
        resetFinalTermEMI({
            loanApplicationId: this.recordid
        })
          .then((result) => {
            console.log('EMI Set to NULL');
          })
          .catch((error) => {
            console.log('Error in resetFinalTermEMI method');
          });
    }
    // CISP-19438 End
    async handleSubCheckEligibilityButton()
    {
        if(this.flagToCheckValidity===true && this.leadSource!='OLA'){
            if(this.currentStage===this.label.CreditProcessing){this.calldoOfferEngineCallout();
            }else{
                checkRetryExhausted({ loanApplicationId: this.recordid,vehicleId:this.vehicleId })
                    .then(result => {let response=JSON.parse(result);
                        if(response.message===RetryExhausted){this.isSpinnerMoving=false;
                            //this.callResetFinalTermEMI();
                            this.showToast("Error", response.message, 'error');this.imageUploadRedCross=true;this.iconButtonCaptureUpload=false;this.moveToOfferScreen();
                        }else{this.retryCount(false);
                            if(this.flagToCheckValidity===true){
                                getApiOutput({ opportunityId: this.recordid })
                                    .then(result => {
                                        this.isFiWaiverApiSuccessValue=result.isFiWaiverApiSuccess;
                                        this.isNavigateValue=result.navigation;
                                        this.ltvEngineValue=result.ltvEngine;
                                        this.pricingEnginethresholdNetIrrValue=result.pricingEnginethresholdNetIrr;
                                        this.loanAmtValue=result.loanAmt;
                                        this.fiwaiverPresentAddressValue=result.fiwaiverPresentAddress;
                                        this.thresholdNetIRR=result.pricingEnginethresholdNetIrr;
                                        if(this.isNavigateValue){this.calldoOfferEngineCallout();}else{
                                            if(this.ltvEngineValue != null && this.pricingEnginethresholdNetIrrValue != null && this.loanAmtValue != null && this.fiwaiverPresentAddressValue != null && this.leadSource != 'Hero'){let nextStage='Offer Screen';   
                                            this.calldoOfferEngineCallout(); //CISP-7798
                                            const oppFields={};
                                            oppFields[OPP_ID_FIELD.fieldApiName]=this.recordid;
                                            oppFields[STAGENAME.fieldApiName]=nextStage;
                                            oppFields[LASTSTAGENAME.fieldApiName]=nextStage;
                                            this.updateRecordDetails(oppFields);
                                            // this.callLoanApplicationHistory(nextStage);
                                            this.isSpinnerMoving=true;}
                                        if(!this.isTractor && this.isFiWaiverApiSuccessValue == false){
                                            let fiWaiverString={'loanApplicationId': this.recordid};
                                            doCSRVahanFIwaiverCallout({ fiWaiverString: JSON.stringify(fiWaiverString) })
                                                .then(results => {
                                                    const obj=JSON.parse(results);
                                                    if(obj.fiBorrower !== undefined && obj.fiBorrower !== null){
                                                        this.presentAddress=obj.fiBorrower.Perm_Resi_Addresss_Fi;
                                                        this.currentAddress=obj.fiBorrower.Curr_Resi_Addresss_Fi;
                                                        this.offAddress=obj.fiBorrower.Off_Addresss_Fi;
                                                        this.fiwaiverPresentAddressValue=obj.fiBorrower.Perm_Resi_Addresss_Fi;}
                                                    if(obj.fiCoBorrower !== undefined && obj.fiCoBorrower !== null){
                                                        this.coPresentAddress=obj.fiCoBorrower.Perm_Resi_Addresss_Fi;
                                                        this.coCurrentAddress=obj.fiCoBorrower.Curr_Resi_Addresss_Fi;
                                                        this.coOffAddress=obj.fiCoBorrower.Off_Addresss_Fi;}
                                                    const FinalTermFields={};
                                                    FinalTermFields[final_ID_FIELD.fieldApiName]=this.finalTermId != null ? this.finalTermId : '';
                                                    FinalTermFields[fiWiver_currentAddress.fieldApiName]=this.currentAddress != null ? this.currentAddress : '';FinalTermFields[RC_limit_enabled_DSA.fieldApiName] = this.isRcLimitChecked != null ? this.isRcLimitChecked : '';
                                                    FinalTermFields[fiWaiver_offAddress.fieldApiName]=this.offAddress != null ? this.offAddress : '';
                                                    FinalTermFields[FIwaiver_presentAddress.fieldApiName]=this.presentAddress != null ? this.presentAddress : '';
                                                    FinalTermFields[fiWiver_co_currentAddress.fieldApiName]=this.coCurrentAddress != null ? this.coCurrentAddress : '';
                                                    FinalTermFields[fiWaiver_co_offAddress.fieldApiName]=this.coOffAddress != null ? this.coOffAddress : '';
                                                    FinalTermFields[FIwaiver_co_presentAddress.fieldApiName]=this.coPresentAddress != null ? this.coPresentAddress : '';
                                                    FinalTermFields[IsFiWaiverApiSucces.fieldApiName]=true;
                                                    this.updateRecordDetailssync(FinalTermFields);//CISP-4856
                                                    if(this.ltvEngineValue != null && this.pricingEnginethresholdNetIrrValue != null && this.loanAmtValue != null && this.fiwaiverPresentAddressValue != null){
                                                        let nextStage='Offer Screen';
                                                        this.callLoanApplicationHistory(nextStage);}
                                                        if(this.ltvEngineValue == null){this.callDoLtvEngineCallout(); }
                                                        if(this.pricingEnginethresholdNetIrrValue == null){ this.calldoPricingEngineCallout(); }
                                                        if(this.ltvEngineValue != null && this.pricingEnginethresholdNetIrrValue != null && this.loanAmtValue == null){
                                                            this.calldoOfferEngineCallout();}
                                                }).catch(error => {
                                                    this.retryPopUp=true;this.isSpinnerMoving=false;
                                                    this.apiMessage='Please Kindly Retry Vahan Api is Failed';
                                                    this.retryCount(true);});}
                                    }});}}
                    });
            }}}

    /*CISP-4785*/async verifyEligibility(){console.log('payoutCapValue: '+this.payoutCapValue);if(this.nonD2cDsaTW){if(await validateSelectedScheme(this)){if(await verifyAmountLessthan10(this)){this.handleCheckEligibilityButton();}}}else if (this.productTypeDetail.toLowerCase() === 'Passenger Vehicles'.toLowerCase()) {console.log('inside PV ');if (await validateSelectedScheme(this)) {this.handleCheckEligibilityButton();}}else{this.handleCheckEligibilityButton();}}
    async handleCheckEligibilityButton() {if(this.enableInsSchedule && this.isNotD2C && this.isNotTractor && !this.isInsSubmitted){this.showToast('Warning', 'Submit Installment Schedule first', 'warning'); return;}else{await helper.handleCheckEligibilityButtonHelper(this);}} // SFTRAC-54
    retryCount(isAPIFailed){retryCountIncrease({ loanApplicationId: this.recordid,vehicleId:this.vehicleId,api: isAPIFailed }).then({});}
    async callDoLtvEngineCallout(){await doLTVEngineCallout({ loanAppId: this.recordid,vehicleId:this.vehicleId }).then(result => {const obj=JSON.parse(result);this.ltv=obj.LTV;this.ltvEngineValue=obj.LTV;const FinalTermFields={};FinalTermFields[final_ID_FIELD.fieldApiName]=this.finalTermId;FinalTermFields[LtvEngine_Ltv.fieldApiName]=this.ltv;this.updateRecordDetails(FinalTermFields);if(this.updateRecordDetails(FinalTermFields)){if(this.ltvEngineValue != null && this.pricingEnginethresholdNetIrrValue != null && this.loanAmtValue == null){ this.calldoOfferEngineCallout(); }}}).catch(error => {this.retryPopUp=true;this.isSpinnerMoving=false;this.apiMessage='Please Kindly Retry Ltv Engine Api is Failed';this.retryCount(true);});
    }
    async calldoPricingEngineCallout(){
        await doPricingEngineCallout({ loanAppId: this.recordid })
            .then(result => {
                const obj=JSON.parse(result);
                this.thresholdNetIRR=obj.Threshold_Net_IRR;
                this.pricingEnginethresholdNetIrrValue=obj.Threshold_Net_IRR;
                const FinalTermFields={};
                FinalTermFields[final_ID_FIELD.fieldApiName]=this.finalTermId;
                FinalTermFields[PricingEngine_thresholdNetrr.fieldApiName]=this.thresholdNetIRR;
                this.updateRecordDetails(FinalTermFields);
                let updateResult=this.updateRecordDetails(FinalTermFields);
                if(updateResult){
                    if(this.ltvEngineValue != null && this.pricingEnginethresholdNetIrrValue != null && this.loanAmtValue == null){ this.calldoOfferEngineCallout(); }
                }
            }).catch(error => {
                this.retryPopUp=true;
                this.isSpinnerMoving=false;
                this.apiMessage='Please Kindly Retry Pricing Engine Api is Failed';
                this.retryCount(true);
            });
    }
    async calldoOfferEngineCallout(){
        this.maxAmount = this.maxAmount == undefined ? 0 : this.maxAmount;
        if(this.maxAmount == 0){
            this.currentscreen=this.maxAmount < parseInt(this.requiredLoanAmount, 10) ? 'Final terms':'Final Offer'
        }
        else{
            this.currentscreen=this.maxAmount >= parseInt(this.requiredLoanAmount, 10) ? 'Final terms':'Final Offer'
            }
        let offerEngineRequestString={
            'loanApplicationId': this.recordid,
            'currentScreen': this.currentscreen,
            'thresholdNetIRR': this.thresholdNetIRR,
            'crmIrrChanged': null,
            'loanAmountChanged': null,
            'tenureChanged': null,
            'advanceEmiFlag': null,
            'offerEMI': this.emiValue?this.emiValue.toString():'',
        };
        let offerEngineMethod = doOfferEngineCallout;
        let offerEngineParams = { offerEngineRequestString: JSON.stringify(offerEngineRequestString) };
        if(this.leadSource === 'D2C' || this.leadSource === 'Hero'){//CISH-04
            this.isD2C = true;
            offerEngineMethod = doD2COfferEngineCallout;
            offerEngineParams = {loanId: this.recordid, applicantId: null, fromScreen:'finalTerms'};
        }   
        await offerEngineMethod(offerEngineParams)
            .then(result => {
                const obj = (this.leadSource === 'D2C' || this.leadSource === 'Hero') ? getParsedJSOND2C(JSON.parse(result)) : JSON.parse(result);const FinalTermFields={};FinalTermFields[final_ID_FIELD.fieldApiName]=this.finalTermId;
                if(obj.EMI!=null){FinalTermFields[EMI_Amount.fieldApiName]=obj.EMI;}if(obj.Tenure!=null){FinalTermFields[Tenure.fieldApiName]=obj.Tenure;}if(obj.Loan_Amt!=null){if(this.leadSource==='D2C' || this.leadSource === 'Hero'){FinalTermFields[Loan_Amount.fieldApiName]=(parseInt(obj.Loan_Amt,10)).toString();}else{FinalTermFields[Loan_Amount.fieldApiName]=(parseInt(obj.Loan_Amt,10) - parseInt(this.totalFundedPremium,10)).toString();}}if(obj.CRM_IRR!=null){FinalTermFields[CRM_IRR.fieldApiName]=obj.CRM_IRR}if(obj.CRM_IRR!=null){FinalTermFields[Required_CRM_IRR.fieldApiName]=obj.CRM_IRR;}if(obj.Max_Tenure_Slider!=null){FinalTermFields[OfferengineMaxTenure.fieldApiName]=obj.Max_Tenure_Slider;}if(obj.Min_Tenure_Slider!=null){FinalTermFields[OfferengineMinTenure.fieldApiName]=obj.Min_Tenure_Slider;}if(obj.Min_Loan_Amt_Slider!=null){FinalTermFields[OfferengineMinLoanAmount.fieldApiName]=obj.Min_Loan_Amt_Slider;}if(obj.Max_Loan_Amt_Slider!=null){FinalTermFields[OfferengineMaxLoanAmount.fieldApiName]=obj.Max_Loan_Amt_Slider;}if(obj.Imputed_IRR_Offered != null){ FinalTermFields[Inputted_IRR.fieldApiName]=parseFloat(obj.Imputed_IRR_Offered);}if(obj.Net_IRR_Offered != null){ FinalTermFields[Net_IRR.fieldApiName]=parseFloat(obj.Net_IRR_Offered); FinalTermFields[Net_IRR_DECIMAL.fieldApiName]=parseFloat(obj.Net_IRR_Offered); }if(obj.Gross_IRR_Offered != null){ FinalTermFields[Gross_IRR.fieldApiName]=parseFloat(obj.Gross_IRR_Offered); }if(obj.NetPayIns != null && (this.leadSource === 'D2C' || this.leadSource === 'Hero')){FinalTermFields[Net_Pay_Ins.fieldApiName]=obj.NetPayIns;}if(obj.NetPayOuts != null && (this.leadSource === 'D2C' || this.leadSource === 'Hero')){FinalTermFields[Net_Pay_Outs.fieldApiName]=obj.NetPayOuts;}if(this.leadSource != 'Hero'){if(obj.TableCode){FinalTermFields[Table_Code.fieldApiName] = obj.TableCode;}if(obj.Interest_VersionNo){FinalTermFields[Interest_Version_No.fieldApiName] = obj.Interest_VersionNo;} if(obj.DR_PenalInterest){FinalTermFields[DR_Penal_Interest.fieldApiName] = obj.DR_PenalInterest;} if(obj.mclrRate){FinalTermFields[mclrRate.fieldApiName] = obj.mclrRate;}}if(this.leadSource === 'Hero'){ FinalTermFields[Service_charges.fieldApiName] = obj.servicecharges;FinalTermFields[Provisional_Channel_Cost.fieldApiName] = obj.provisionCost;FinalTermFields[Mfr_incentive.fieldApiName] = obj.mfrIncentive;FinalTermFields[Dealer_incentive_amount_main_dealer.fieldApiName] = obj.dealerIncentiveMain;FinalTermFields[Documentation_charges.fieldApiName] = obj.docCharges;}//CISH-48
                try {
                    if(this.isNotTractor){
                        if(obj.loanDealDate){console.log(obj.loanDealDate,' ',new Date(obj.loanDealDate));
                            FinalTermFields[Loan_Deal_Date.fieldApiName] = obj.loanDealDate;}
                        if(obj.agreementAmount){FinalTermFields[OE_Agreement_Amount.fieldApiName] = obj.agreementAmount;}
                        if(obj.amortizationSchedule){
                            saveInstallmentSchedule({ loanId: this.recordid, response: JSON.stringify(obj.amortizationSchedule), installmentType: this.installmentTypeValue}).then(result => {}).catch(error => {});
                        }
                    } 
                } catch (error) {
                    console.error(error);
                }
                 
                if(obj.Stop_Journey_Flag==="True" && this.productTypeDetail.toLowerCase() !== PassengerVehicles.toLowerCase()){
                    FinalTermFields[OfferengineStopJourneyFlag.fieldApiName]=true;
                    const oppFields={};
                    oppFields[OPP_ID_FIELD.fieldApiName]=this.recordid;
                    oppFields[Journey_Status.fieldApiName]='Stop';
                    oppFields[Journey_Stop_Reason.fieldApiName]='Offer Engine API returned response as journey stop';
                    const recordInput={ fields: oppFields };
                    updateRecord(recordInput)
                        .then(() => { });journeyStopScenarioFound(this.recordid);//CISP-4588
                }FinalTermFields[isNavigate.fieldApiName]=false;FinalTermFields[RC_limit_enabled_DSA.fieldApiName] = this.isRcLimitChecked;FinalTermFields[IsOfferEngineApiFailed.fieldApiName]=false;
                 if(this.productTypeDetail?.toLowerCase() == 'Two Wheeler'.toLowerCase()  && obj.Gross_IRR_Offered!=null && this.mingross!=null && this.maxgross!=null && ((parseFloat(obj.Gross_IRR_Offered) < parseFloat(this.mingross)) || (parseFloat(obj.Gross_IRR_Offered) > parseFloat(this.maxgross)))){//CISP-20504
                        const event = new ShowToastEvent({
                            title: 'Error',
                            message: 'Gross IRR is not within the permissible range. Please change Pay in.',
                            variant: 'Error',
                        });
                        this.dispatchEvent(event);
                        return;
                      }//CISP-20504
                this.offerEngineFlag=true;
                this.updateRecordDetails(FinalTermFields);
                setTimeout(() => {
                    this.offerScreenMove();                    
                }, 500);

                })
            .catch(error => {
                this.isSpinnerMoving=false;this.toastMsg(error);const FinalTermFields={};FinalTermFields[final_ID_FIELD.fieldApiName]=this.finalTermId;FinalTermFields[IsOfferEngineApiFailed.fieldApiName]=true; 
                this.updateRecordDetails(FinalTermFields);this.retryPopUp=true;this.apiMessage='Please Kindly Retry Offer Engine Api is Failed';
                this.retryCount(true);});this.isSpinnerMoving=false;
    }
    offerScreenMove(){
        if(this.currentStage !== this.label.CreditProcessing){
            if(this.productTypeDetail.toLowerCase()===TwoWheeler.toLowerCase()){
                console.log('test');
                // let nextStage='Offer Screen';
                this.moveToOfferScreen()
            }
            else if(obj.Stop_Journey_Flag == 'False' || this.productTypeDetail.toLowerCase() === PassengerVehicles.toLowerCase()){
                let nextStage='Offer Screen';const oppFields={}; oppFields[OPP_ID_FIELD.fieldApiName]=this.recordid;oppFields[STAGENAME.fieldApiName]=nextStage;oppFields[LASTSTAGENAME.fieldApiName]=nextStage;this.updateRecordDetails(oppFields);
                if(this.updateRecordDetails(oppFields)){
                    if(this.fiwaiverPresentAddressValue != undefined){this.isSpinnerMoving=false;this.iconButtonCaptureUpload=true;this.imageUploadRedCross=false;this.isSpinnerMoving=false;this.callLoanApplicationHistory(nextStage);}
                    this.isSpinnerMoving=false;
                }
            }else{this.toastMsg('Journey Stoped');this.disableEverything(); this.isSpinnerMoving=false;journeyStopScenarioFound(this.recordid); //CISP-4459
        }
        }else{
            this.isEnableNext=true;this.template.querySelector('.checkEli').disabled=true; let next=this.template.querySelector('.next');
            if(next){next.disabled=false;}this.disabledServiceCharges=true;this.disabledExpReimburseAmountValue=true;this.disabledDealerIncentiveAmountSubDealer=true;this.disabledDealerIncentiveAmountMainDealer=true;this.disabledDealerDiscounttoCustomer=true;this.disabledDsmIncentiveOne=true;this.disablednonDlrDsmIncentiveOne=true;this.disablednonDlrDsmIncentiveTwo=true;this.disabledDsmIncentiveTwo=true;this.disabledGiftThroughDealerAmount=true;this.disabledMfrExpReimburseAmt=true;this.disabledReferrerIncentive=true;this.isSpinnerMoving=false;
            this.dispatchEvent(new CustomEvent('finaltermsevent', { detail: FinalTerms }));
        }
    }
    async updateRecordDetails(fields){let result = false; const recordInput={ fields };await updateRecord(recordInput).then(() => {result = true;}).catch(error => {console.log(error,'final screen error');this.showToast("Error", 'Data not Saved', 'error');result = false;});return result;}
    //CISP-4856
     updateRecordDetailssync(fields){let result = false; const recordInput={ fields }; updateRecord(recordInput).then(() => {result = true;}).catch(error => {this.showToast("Error", 'Data not Saved', 'error');result = false;});return result;}

    handleDealerMainPercentage(event){this.dealerMainPercentageValue=event.target.value;this.dealerIncentiveAmountMainValue = roundOff((this.dealerMainPercentageValue * this.requiredLoanAmount)/100);/*CISP-4785 Start*/(event.target).addEventListener('keyup', this.debounce( () => {if(this.dealerMainPercentageValue == 0 && this.nonD2cDsaTW){showPayoutWarning(this,'zero');} else if(this.dealerMainPercentageValue < this.mainDlrIncentivePercentMedian && this.nonD2cDsaTW){showPayoutWarning(this,'lower');} else if(this.dealerMainPercentageValue > this.mainDlrIncentivePercentMedian && this.nonD2cDsaTW){showPayoutWarning(this,'higher');}},1000));/*CISP-4785 End*/}
    handleDealerSubPercentage(event){this.dealerSubPercentageValue=event.target.value;this.dealerIncentiveAmountSubValue = roundOff((this.dealerSubPercentageValue * this.requiredLoanAmount)/100);/*CISP-4785 Start*/(event.target).addEventListener('keyup', this.debounce( () => {if(this.dealerSubPercentageValue == 0 && this.nonD2cDsaTW){showPayoutWarning(this,'zero');} else if(this.dealerSubPercentageValue < this.subDlrIncentivePercentMedian && this.nonD2cDsaTW){showPayoutWarning(this,'lower');} else if(this.dealerSubPercentageValue > this.subDlrIncentivePercentMedian && this.nonD2cDsaTW){showPayoutWarning(this,'higher');}},1000));/*CISP-4785 End*/}
    handleGiftThroughDealerPercentage(event){this.giftThroughDealerPercentageValue=event.target.value;this.giftThroughDealerAmountValue = roundOff((this.giftThroughDealerPercentageValue * this.requiredLoanAmount)/100);}
    handlemanufacturerIncentive(event){this.manufacturerIncentiveValue=roundOff(event.target.value);this.mfrIncentivePercentageValue = ((this.manufacturerIncentiveValue / this.requiredLoanAmount)*100).toFixed(2);}
    handleMfrIncentivePercentage(event){this.mfrIncentivePercentageValue=event.target.value;this.manufacturerIncentiveValue = roundOff((this.mfrIncentivePercentageValue * this.requiredLoanAmount)/100);}
    handleDsmOnePercentage(event){this.dsmOnePercentageValue=event.target.value;this.dsmIncentiveOneValue = roundOff((this.dsmOnePercentageValue * this.requiredLoanAmount)/100);/*CISP-4785 Start*/(event.target).addEventListener('keyup', this.debounce( () => {if(this.dsmOnePercentageValue == 0 && this.nonD2cDsaTW){showPayoutWarning(this,'zero');} else if(this.dsmOnePercentageValue < this.dsmIncentive1PercentMedian && this.nonD2cDsaTW){showPayoutWarning(this,'lower');} else if(this.dsmOnePercentageValue > this.dsmIncentive1PercentMedian && this.nonD2cDsaTW){showPayoutWarning(this,'higher');}}, 1000));/*CISP-4785 End*/}
    handleDsmTwoPercentage(event){this.dsmTwoPercentageValue=event.target.value;this.dsmIncentiveTwoValue=roundOff((this.dsmTwoPercentageValue * this.requiredLoanAmount)/100);/*CISP-4785 Start*/(event.target).addEventListener('keyup', this.debounce( () => {if(this.dsmTwoPercentageValue == 0 && this.nonD2cDsaTW){showPayoutWarning(this,'zero');} else if(this.dsmTwoPercentageValue < this.dsmIncentive2PercentMedian && this.nonD2cDsaTW){showPayoutWarning(this,'lower');} else if(this.dsmTwoPercentageValue > this.dsmIncentive2PercentMedian && this.nonD2cDsaTW){showPayoutWarning(this,'higher');}},1000));/*CISP-4785 End*/}

    handleScheme(event){this.schemeOptionsValue = event.target.value;helper.handleSchemeSelection(this);}
    handleNonDlrDsmIncentiveOne(event){
        let elem=this.template.querySelector('lightning-input[data-id=nondlrDsmIncen1]');
        this.nonDlrDsmIncentiveOneValue=event.target.value;
        if(this.productTypeDetail.toLowerCase()===TwoWheeler.toLowerCase() && (this.vehicleTypeDetail.toLowerCase()==='new'.toLowerCase())){let checkNonDlrDsmIncentiveOneH=(this.nonDlrDsmIncentiveOneValid * parseInt(this.requiredLoanAmount, 10)) / 100;elem.setCustomValidity("");if(this.nonDlrDsmIncentiveOneValue && (this.nonDlrDsmIncentiveOneValue > parseInt(checkNonDlrDsmIncentiveOneH, 10))){elem.setCustomValidity(FivePercentageOfAmount);}elem.reportValidity();
        }else if(this.productTypeDetail.toLowerCase()===PassengerVehicles.toLowerCase() && (this.vehicleTypeDetail.toLowerCase()==='new'.toLowerCase())){let checkNonDlrDsmIncentiveOneC=(this.nonDlrDsmIncentiveOneValid * parseInt(this.requiredLoanAmount, 10)) / 100;elem.setCustomValidity("");if(this.nonDlrDsmIncentiveOneValue && (this.nonDlrDsmIncentiveOneValue > parseInt(checkNonDlrDsmIncentiveOneC, 10))){elem.setCustomValidity(tenPercentageOfAmount);}elem.reportValidity();
        } else if(this.productTypeDetail.toLowerCase()===TwoWheeler.toLowerCase() && (this.vehicleTypeDetail.toLowerCase()==='Refinance'.toLowerCase() || this.vehicleTypeDetail.toLowerCase()==='used'.toLowerCase())){elem.setCustomValidity("");if(this.nonDlrDsmIncentiveOneValue >= 1){elem.setCustomValidity(noPayout);}elem.reportValidity();
        }if(this.nonDlrDsmIncentiveOneValue < 0){elem.setCustomValidity(validValue);}elem.reportValidity();}
    async handleCreateFinalTermRecord(){this.isSpinnerMoving=true;if(this.finalTermId){helper.handleSave(this);}else { await createFinalTermRecord({ loanApplicationId: this.recordid,vehicleId:this.vehicleId}).then(responses => { const obj=JSON.parse(responses); this.finalTermId=obj.finalTermId; helper.handleSave(this);}).catch(error=>{this.isSpinnerMoving=false;});}}

    handleNonDlrDsmIncentiveTwo(event){
        let elem=this.template.querySelector('lightning-input[data-id=dlrdsmIncen2]');
        this.nonDlrDsmIncentiveTwoValue=event.target.value;
        if(this.productTypeDetail.toLowerCase()===TwoWheeler.toLowerCase() && (this.vehicleTypeDetail.toLowerCase()==='new'.toLowerCase())){let CheckNonDlrDsmIncentiveTwoH=(this.nonDlrDsmIncentiveTwoValid * parseInt(this.requiredLoanAmount, 10)) / 100;elem.setCustomValidity("");
            if(this.nonDlrDsmIncentiveTwoValue && (this.nonDlrDsmIncentiveTwoValue > parseInt(CheckNonDlrDsmIncentiveTwoH, 10))){elem.setCustomValidity(FivePercentageOfAmount);}elem.reportValidity();} else if(this.productTypeDetail.toLowerCase()===PassengerVehicles.toLowerCase() && (this.vehicleTypeDetail.toLowerCase()==='new'.toLowerCase())){let CheckNonDlrDsmIncentiveTwoC=(this.nonDlrDsmIncentiveTwoValid * parseInt(this.requiredLoanAmount, 10)) / 100;elem.setCustomValidity("");if(this.nonDlrDsmIncentiveTwoValue && (this.nonDlrDsmIncentiveTwoValue > parseInt(CheckNonDlrDsmIncentiveTwoC, 10))){elem.setCustomValidity(tenPercentageOfAmount);}elem.reportValidity();} else if(this.productTypeDetail.toLowerCase()===TwoWheeler.toLowerCase() && (this.vehicleTypeDetail.toLowerCase()==='Refinance'.toLowerCase() || this.vehicleTypeDetail.toLowerCase()==='used'.toLowerCase())){elem.setCustomValidity("");if(this.nonDlrDsmIncentiveTwoValue >= 1){elem.setCustomValidity(noPayout);}elem.reportValidity();}if(this.nonDlrDsmIncentiveTwoValue < 0){elem.setCustomValidity(validValue);}elem.reportValidity();}

    handleDsmIncentiveTwo(event) {this.dsmIncentiveTwoValue = roundOff(event.target.value);this.dsmTwoPercentageValue = ((this.dsmIncentiveTwoValue / this.requiredLoanAmount)*100).toFixed(2);helper.dsmIncentiveTwo(this);/*CISP-4785 Start*/(event.target).addEventListener('keyup', this.debounce( () => {if(this.dsmTwoPercentageValue == 0 && this.nonD2cDsaTW){showPayoutWarning(this,'zero');} else if(this.dsmTwoPercentageValue < this.dsmIncentive2PercentMedian && this.nonD2cDsaTW){showPayoutWarning(this,'lower');} else if(this.dsmTwoPercentageValue > this.dsmIncentive2PercentMedian && this.nonD2cDsaTW){showPayoutWarning(this,'higher');}}, 1000));/*CISP-4785 End*/}

    handleGiftThroughDealerAmount(event) {this.giftThroughDealerAmountValue = roundOff(event.target.value);this.giftThroughDealerPercentageValue = ((this.giftThroughDealerAmountValue / this.requiredLoanAmount)*100).toFixed(2);helper.giftThroughDealerAmount(this);}
    handleMfrExpReimburseAmt(event){this.mfrExpReimburseAmtValue=roundOff(event.target.value);this.mfrExpReimbursePercentageValue=(100 - ((parseInt(this.requiredLoanAmount, 10) - this.mfrExpReimburseAmtValue) / parseInt(this.requiredLoanAmount, 10) * 100)).toFixed(2);helper.mfrExpReimburseAmtFn(this);}
    handleAdvanceEmi() {let advanceEMiInput = this.template.querySelector('lightning-input[data-id=advanceEMIid]'); advanceEMiInput.setCustomValidity("");advanceEMiInput.reportValidity();this.advanceEMi=advanceEMiInput.checked;if(this.advanceEMi===true){let elem=this.template.querySelector('.monDay');elem.setCustomValidity("");elem.reportValidity();this.advanceEmiValue=true;this.monitoriumDaysDisabled=true;this.monitoriumDaysValue='0';}else{this.monitoriumDaysValue = '30';this.monitoriumDaysDisabled=false;this.advanceEmiValue=false;}if(this.isNotD2C && this.isNotTractor){helperTwo.getEmiDateList(this);}helperTwo.handleLoanDateCalHelper(this);}
    handleProvisionalChannelCost(event) {this.provisionalChannelCostValue = event.target.value;helper.provisionalChannelCost(this);} 
    get options(){return [{label: 'Equated', value: 'Equated'},{label: 'Structured', value: 'Structured'}];}
    isRendered = false;
    async renderedCallback(){
        if(!this.dsmIncentiveOneValue && this.isTractor){
            let dsmIncentiveOneInput=this.template.querySelector('lightning-input[data-id=dsmIncent]');if(dsmIncentiveOneInput){dsmIncentiveOneInput.setCustomValidity('');dsmIncentiveOneInput.reportValidity();}
        }
        if(!this.dsmIncentiveTwoValue && this.isTractor){
            let dsmIncentiveTwoInput=this.template.querySelector('lightning-input[data-id=dsmInce]');if(dsmIncentiveTwoInput){dsmIncentiveTwoInput.setCustomValidity('');dsmIncentiveTwoInput.reportValidity();}
        }
        if(this.finaltermServiceCharge  && this.finaltermDocumentCharge && this.template.querySelector('lightning-input[data-id=serChar]').disabled && this.template.querySelector('lightning-input[data-id=DocChar]').disabled){
        this.serviceChargesValue= this.finaltermServiceCharge;this.documentationChargesValue= this.finaltermDocumentCharge;}
        if(this.productTypeDetail===PassengerVehicles){this.showfieldvalue=false;}
        if (this.currentStageName==='Loan Initiation' || this.currentStageName==='Additional Details' ||  this.currentStageName==='Asset Details' || this.currentStageName==='Vehicle Valuation' || this.currentStageName==='Vehicle Insurance' || this.currentStageName==='Loan Details' || this.currentStageName==='Income Details' || (this.currentStageName!=='Final Terms' && this.lastStage !== 'Final Terms' && this.lastStage != undefined && this.currentStageName != undefined && this.subStage != undefined && this.subStage!= FinalTerms && !this.fromVfPage)) {
            this.disableEverything();}
        if(this.currentStage==='Credit Processing'){if(this.subStage && this.subStage!= FinalTerms && !this.fromVfPage/*CISP-4785*/){this.iconButtonCaptureUpload=true;this.disableEverything();}if(this.subStage != FinalTerms){this.isEnableNext=true;if(this.template.querySelector('.next')){this.template.querySelector('.next').disabled=false;}}else{this.template.querySelector('.checkEli').disabled=false;}
        }let okbtn=this.template.querySelector('.okbtn');
        if(okbtn){okbtn.disabled=false;}if(this.isRevokedLoanApplication){this.disableEverything();}if(this.popFlag){this.template.querySelector('.checkEli').disabled=false;}if(!this.isRendered && (this.isNavigateValue || this.popFlag)){await this.template.querySelectorAll('lightning-input').forEach(elem=>{elem.setCustomValidity("");elem.reportValidity();});};
        if (this.leadSource=='OLA' && this.currentStage=='Credit Processing' && this.subStage=='Final Terms'){ 
            this.disableEverything();this.olaNextVisible = true;this.isEnableNext=false;this.template.querySelector('.checkEli').disabled=true;//OLA-39
        }if(this.leadSource == 'D2C'){this.isD2C = true;this.advanceEmiDisabled = true;this.monitoriumDaysDisabled=true;this.advanceEmiValue=false;this.monitoriumDaysValue='30';}
        if ((this.isTractor && this.isFinaltermSubmit && this.currentStage != 'Credit Processing') || (this.currentStage == 'Credit Processing' && this.subStage == 'View Application Details') || (this.currentStage == 'Credit Processing' && this.activetab == 'View Application Details') ) {this.disableEverything();this.template.querySelector('.checkEli').disabled = true;let next=this.template.querySelector('.next');if(next){next.disabled = false};
		};
        //if(this.currentStage==='Credit Processing' && this.leadSource != 'D2C' && this.productTypeDetail===PassengerVehicles && this.template.querySelector('.next').disabled == false){this.template.querySelector('.checkEli').disabled=true;}//CISP-22585
        if(this.isTractor && this.changePayInOutEditable) { //SFTRAC-585
            let allElements=this.template.querySelectorAll('*');
            allElements.forEach(element =>{
                if(element.label && (element.label ==='payin' || element.label ==='payout' )){element.disabled=false;}
             });
             this.template.querySelector('.checkEli').disabled = false;
        }
        if(!this.fromVfPage && this.currentStage && (this.currentStage==='Credit Processing' || this.currentStage==='Post Sanction Checks and Documentation' || this.currentStage=='Pre Disbursement Check' || this.currentStage ==='Disbursement Request Preparation') && this.activetab !== 'View Application Details'){this.enableInsSchedule=true;if(this.isNotD2C && this.isNotTractor){let ele = this.template.querySelector('.insSchedule');if(ele){ele.disabled = false;}}}
        if(this.disableInstallmentType && this.isTractor){let elem = this.template.querySelector('.Install');if(elem){elem.disabled=true;}}
        if(this.currentStage==='Credit Processing' && this.productTypeDetail === 'Tractor'){this.disabledCheckEligibility =  true;this.template.querySelector('.checkEli').disabled=true;}
        if(this.isRevokedLoanApplication){this.disableEverything();}
        if(!this.isFoirStop){console.log('rendered foir');}
    }

    handleOnfinish(event){const evnts=new CustomEvent('insurancevaleve', { detail: event });this.dispatchEvent(evnts);}
    //CISP-15702 Start
    @wire(getRecord, { recordId: '$recordid', fields: ['Opportunity.UploadAndViewDocDisable__c']})
    wireOpportunityRec;
    get isUploadViewDisabled(){
        return this.wireOpportunityRec.data ? this.wireOpportunityRec.data.fields.UploadAndViewDocDisable__c.value : false;
    }
    //CISP-15702 End
    async connectedCallback(){
        try {this.isSpinnerMoving = true;this.finalTermId = await getFinalTermRecord({'loanApplicationId':this.recordid,vehicleId: this.vehicleId});
        if(this.forTwoWheeler===false){reffnamedata({ loanApplicationId: this.recordid }).then(result => {
            let options = []; for (let key in result) { options.push({ label: result[key], value: key }); }
            this.referrerNameOptions = options/*JSON.parse(JSON.stringify(options))*/;
            if(this.forTwoWheeler===false && this.referrerNameValue && this.referrerNameOptions.length>0){this.referrerNameValue=this.referrerNameOptions.find(opt => opt.label === this.referrerNameValue).value;}
        });}
        await getRecentEMIdetails({loanId:this.recordid}).then((data)=>{if(data && data.length>0){this.disaibleInstalmentSchedule = false;}else{this.disaibleInstalmentSchedule = true;}}).catch((error) => { console.log('error in getRecentEMIdetails ',error);});
        await fetchProductType({ loanAppId: this.recordid })
            .then(response => {if(response && response[0].Applicants__r.length > 0){ this.isExistingCustomer = (response[0].Applicants__r[0].Customer_Code__c != null) ? true :false; }
                if(response && response[0].Product_Type__c.toLowerCase() === TwoWheeler.toLowerCase()){this.forTwoWheeler=true;this.emidisable=true;}else if(response && response[0].Vehicle_Type__c != 'New' && response[0].Product_Type__c.toLowerCase() == PassengerVehicles.toLowerCase() && (response[0].LeadSource != 'OLA' && response[0].LeadSource != 'D2C')){this.isPVUsedAndRefinance = true;}
                this.isTopUpLoan = response[0].isTopUpLoan__c;
            });
        if(this.forTwoWheeler && this.currentStage==='Credit Processing'){await getRecordDetailsHelper(this);}
        this.getApplicationDetailsFunction();
        await getMedianPayout(this);
        await helperTwo.callGetFinalTermDetails(this);
        await helperTwo.getEmiDateList(this);
        await handleOptionsRelatedListsHelper(this);//RAJAT ADDED
        await helper.getCustomerCodeStatusHelper(this);//CISP-21214
        await repaymentModePickListValueHelper(this);
        /*CISP-4785*/if(this.nonD2cDsaTW){await validateSelectedScheme(this);}
        this.callAccessLoanApplication(); 
        await getFinalTermFieldDetails({ opportunityId: this.recordid, 'vehicleId':this.vehicleId})
            .then(result => {
                if(result.dealerSubDealer){
                    this.dealerSubDealer = result.dealerSubDealer;
                }
                this.manufacturerCodeList = result.manufacturerCodeList;//CISP-20395
                this.OEMDealer = result.OEMDealer;
                this.productTypeDetail=result.productTypestr;
                this.productSegment=result.productSegment;//CISP-20504
                const finalTermData=result.finalTermVal[0];
                this.scorecardvalue = result.scorecard;
                //SFTRAC-1795 starts
                if(result.repaymentFrequency){this.repaymentFrequency = result.repaymentFrequency;}
                if(result.installMentType){this.installMentType = result.installMentType;}//SFTRAC-1795 end
                if(result.scorecard == true){this.disableEverything();this.toastMsg('Journey Stopped');}
                this.vehicleSubCategoryDetail=result.vehicleSubCategoryStr;this.vehicleDelivered = result.vehicleDeliveredStr;this.requiredCrmIRR=result.requiredCrmIRR;
                this.vehicleTypeDetail=result?.vehicleTypeStr;
                this.isRefinance = this.vehicleTypeDetail?.toLowerCase()==='refinance';
                if(this.leadSource != 'D2C' && this.leadSource != 'OLA' && this.leadSource != 'Hero' && this.isRefinance && this.productTypeDetail == 'Two Wheeler'){this.isTWRefinance = true}
                this.isUsed = this.vehicleTypeDetail.toLowerCase() === 'used';
                if (this.productTypeDetail.toLowerCase() === 'Tractor'.toLowerCase() && result.applicationType.toLowerCase() === 'Build Body and Chassis Funding'.toLowerCase() && this.vehicleTypeDetail.toLowerCase() === 'New'.toLowerCase()) { this.showFundingInfo = true; }
                if(this.productTypeDetail.toLowerCase() === 'Tractor'.toLowerCase()){helperTwo.finalTermValidationHandler(this,result)}
                if(this.vehicleTypeDetail.toLowerCase()==='Refinance'.toLowerCase() || this.vehicleTypeDetail.toLowerCase()==='used'.toLowerCase()){
                    this.displayDsaRcu=true;
                    this.disabledDsaPay=true;
                    if(this.currentStage==='Credit Processing'){this.disabledRcu=true;this.disabledDsaPay=true;}
                }
                this.makeCode=result.vechicalDetailLst && result.vechicalDetailLst.length > 0 ? result.vechicalDetailLst[0].Make__c : null;
                this.requiredTenureDetails=result.requiredTenure;this.serviceChargesValueValid=finalTermData.serviceChargesValue__c;this.serviceChargesValueMaxValid=finalTermData.serviceChargesValueMax__c;this.serviceChargesValueMinValid=finalTermData.serviceChargesValueMin__c;this.dealerExpReimburseValid=finalTermData.DealerExpReimburse__c;this.dealerIncentiveAmountSubDealerValid=finalTermData.DealerIncentiveAmountSubDealer__c;this.dealerIncentiveAmountMainDealerValid=finalTermData.DealerIncentiveAmountMainDealer__c;this.dealerDiscounttoCustomerValid=finalTermData.DealerDiscounttoCustomer__c;this.dsmIncentiveOneValid=finalTermData.DsmIncentiveOne__c;this.dsmIncentiveTwoValid=finalTermData.DsmIncentiveTwo__c;this.nonDlrDsmIncentiveOneValid=finalTermData.NonDlrDsmIncentiveOne__c;this.nonDlrDsmIncentiveTwoValid=finalTermData.NonDlrDsmIncentiveTwo__c;this.giftThroughDealerAmountValid=finalTermData.GiftThroughDealerAmount__c;this.mfrExpReimburseAmtValid=finalTermData.MfrExpReimburseAmt__c;this.provisionalChannelCostValid=finalTermData.ProvisionalChannelCost__c;this.provisionalChannelCostTwoValid=finalTermData.ProvisionalChannelCostTwo__c;this.provisionalChannelCostMaxValid=finalTermData.ProvisionalChannelCostMax__c;this.provisionalChannelCostMinValid=finalTermData.ProvisionalChannelCostMin__c;this.stampingChargesValid=finalTermData.StampingCharges__c;this.documentChargesFinAmountValid=finalTermData.documentChargesFinAmount__c;this.documentChargesPercentageValid=finalTermData.DocumentchargesPercentage__c;this.documentChargesMinPercValid=finalTermData.DocumentChargesMinPercentage__c;this.ManufacturerIncentiveValid=finalTermData.ManufacturerIncentive__c;this.documentChargesMinAmountValid=finalTermData.documentChargesMinAmount__c;this.mfrExpReimbursePercentValid=finalTermData.MfrExpReimbursePercent__c;this.dealerExpReimbursePercentValid=finalTermData.DealerExpReimbursePercent__c;this.referrerIncentiveValid=finalTermData.Referrer_Incentive_for_referrer__c;this.requiredLoanAmount=parseInt(result.loanAmt, 10);this.loanAmtForCal = result.loanAmt;
                //CISP-124
                let returnedObj  = calculateProvisionAmt(this,this.totalFundedPremium,result.finalTermDetailLst[0]?.Loan_Amount__c,this.requiredLoanAmount,result.finalTermDetailLst[0]?.Tenure__c,this.requiredTenureDetails,this.productTypeDetail,this.vehicleTypeDetail,this.provisionalChannelCostValid,this.provisionalChannelCostMinValid,this.provisionalChannelCostTwoValid,this.provisionalChannelCostMaxValid);
                if(Object.keys(returnedObj).length != 0 && this.leadSource!='OLA'  && !this.isD2C && this.leadSource!='Hero' ){this.provisionalChannelCostValue=returnedObj.provisionalChannelCostValue;this.disabledProvisionalChannelCost=returnedObj.disabledProvisionalChannelCost;this.provisionalChannelCostValueTemp = this.provisionalChannelCostValue;}//OLA-21
                //CISP-124
                if(this.isNavigateValue && this.productTypeDetail==PassengerVehicles){this.disabledProvisionalChannelCost=true;}if(this.makeCode===this.labelCustom.makecodeM.toLowerCase()){
                    this.manufacturerIncentiveValue=roundOff((this.ManufacturerIncentiveValid * parseInt(this.requiredLoanAmount, 10)) / 100);this.disabledManufacturerIncentive=true;
                }else if(this.leadSource!='Hero') {this.manufacturerIncentiveValue=0;this.disabledManufacturerIncentive=true;
                }this.loanAmountDetail=parseInt(result.loanAmt, 10);
                if(!this.isNavigateValue){this.requiredLoanAmount=this.loanAmountDetail;}else{if(!this.isTractor){this.requiredLoanAmount=this.offerScreenLoanAmount;}if(this.productTypeDetail.toLowerCase()!==TwoWheeler.toLowerCase()){this.serviceChargesValue='';this.disabledServiceCharges=false;this.documentationChargesValue='';this.disabledDocumentationCharges=false;this.dealerExpReimburseAmountValue='';this.mfrExpReimburseAmtValue='';this.dealerIncentiveAmountMainValue='';this.dealerIncentiveAmountSubValue='';this.dsmIncentiveOneValue='';this.dsmIncentiveTwoValue='';this.nonDlrDsmIncentiveOneValue='';this.nonDlrDsmIncentiveTwoValue='';this.manufacturerIncentiveValue='';this.referrerIncentiveValue='';this.provisionalChannelCostValue='';this.giftThroughDealerAmountValue='';this.dealerDiscounttoCustomerValue='';this.mfrExpReimbursePercentageValue='';this.dealerExpReimbursePercentageValue='';if(this.isNotTractor){this.disabledDsmIncentiveOne=false;this.disabledDsmIncentiveTwo=false;}else if(this.isTractor){if(this.dsmNameOneValue){this.disabledDsmIncentiveOne=false;}if(this.dsmNameTwoValue){this.disabledDsmIncentiveTwo=false;}this.disabledDealerIncentiveAmountMainDealer=false;this.disabledGiftThroughDealerAmount=false;this.disabledDealerDiscounttoCustomer=false;}
                    this.showToast("warning", this.labelCustom.requiredFields, 'warning');}} //INDI-4705
                    if(this.offerScreenLoanAmount && !this.isTractor){this.requiredLoanAmount=parseInt(this.offerScreenLoanAmount) + this.totalFundedPremium;}
                    if(this.requiredLoanAmount && this.productTypeDetail.toLowerCase()===TwoWheeler.toLowerCase()){
                        this.dealerMainPercentageValue=checkInput(this.dealerIncentiveAmountMainValue)?((this.dealerIncentiveAmountMainValue / this.requiredLoanAmount)*100).toFixed(2):null;
                        this.dealerSubPercentageValue=checkInput(this.dealerIncentiveAmountSubValue)?((this.dealerIncentiveAmountSubValue / this.requiredLoanAmount)*100).toFixed(2):null;
                        this.giftThroughDealerPercentageValue=checkInput(this.giftThroughDealerAmountValue)?((this.giftThroughDealerAmountValue / this.requiredLoanAmount)*100).toFixed(2):null;
                        this.mfrIncentivePercentageValue=checkInput(this.manufacturerIncentiveValue)?((this.manufacturerIncentiveValue / this.requiredLoanAmount)*100).toFixed(2):null;
                        this.dsmOnePercentageValue=checkInput(this.dsmIncentiveOneValue)?((this.dsmIncentiveOneValue / this.requiredLoanAmount)*100).toFixed(2):null;
                        this.dsmTwoPercentageValue=checkInput(this.dsmIncentiveTwoValue)?((this.dsmIncentiveTwoValue / this.requiredLoanAmount)*100).toFixed(2):null;
                        this.disableDealerMainPercentage=true;this.disableDealerSubPercentage=true;this.disableGiftThroughDealerPercentage=true;this.disableMfrIncentivePercentage=true;this.disabledsmOnePercentage=true;this.disableDsmTwoPercentage=true;       
                    }
                    if(this.finaltermSchemeId && this.requiredLoanAmount && this.productTypeDetail.toLowerCase()===TwoWheeler.toLowerCase()){
                        callCheckSchemeEligibility({ schemeId: this.finaltermSchemeId, loanApplicationId: this.recordid })
                        .then(response => {
                            let result = JSON.parse(response);console.log('response',response);
                            let schemeRec = result.schemeRecord; if(schemeRec){let currentStage= this.currentStage!=='Credit Processing' ? true : false;
                            let loanAmount=parseInt(this.requiredLoanAmount, 10);if(checkInput(schemeRec.Payout_Cap__c)){this.payoutCapValue=schemeRec.Payout_Cap__c;}
                            /*CISP-4785 Start*/
                            if(this.nonD2cDsaTW){
                                this.modifyingDataacctoScheme(schemeRec, loanAmount);
                            }else {
                                this.updateFieldbasedOnLoanAmt(schemeRec, loanAmount, currentStage);
                            }/*CISP-4785 End*/}
                        });
                    }
                // if(result.manufactureIncentive!=null){this.manufacturerIncentiveValue=roundOff(result.manufactureIncentive);this.mfrIncentivePercentageValue=checkInput(this.manufacturerIncentiveValue)?((this.manufacturerIncentiveValue / this.requiredLoanAmount)*100).toFixed(2):null;this.disableMfrIncentivePercentage=true;this.haveHeroMIValue=true;}
                });
        if(this.currentStage === 'Credit Processing' && this.subStage==='Final Terms' && this.isNotTractor){
            try{
                this.isFoirStop = await helperTwo.checkFoirJourneyStop(this);console.log('isFoirStop___await__'+this.isFoirStop);
             } catch (error) {
                this.isFoirStop = false;
                console.log('isFoirStop___aerrorwait__'+this.isFoirStop);
             }
            console.log('isFoirStop__'+this.isFoirStop);
        }
        await loadSchemeData({ loanApplicationId: this.recordid,vehicleId:this.vehicleId})
            .then(response => {let hasSelectedScheme=false;this.schemeData=[];let haveNoScheme=false;
                for (let index=0; index < response.length; index++){
                let schemeListObj={};if(response[index].Name.toLowerCase().includes('no scheme') && !haveNoScheme && !this.forTwoWheeler) {schemeListObj.label='No Scheme';schemeListObj.value=response[index].Name;schemeListObj.id=response[index].Id;haveNoScheme=true;}
                else if(this.forTwoWheeler || !response[index].Name.toLowerCase().includes('no scheme')){schemeListObj.label=response[index].Name;schemeListObj.value=response[index].Name;schemeListObj.id=response[index].Id;schemeListObj.repaymentDetails=response[index].Repayment_Mode__c}                    
                if(JSON.stringify(schemeListObj) !== '{}'){this.schemeData.push(schemeListObj);if(!this.schemeOptionsValue || this.schemeOptionsValue == schemeListObj.value){hasSelectedScheme = true;}}}
                this.schemeOptions=this.schemeData;if(!hasSelectedScheme){this.schemeOptions.push({label:this.schemeOptionsValue,value:this.schemeOptionsValue})}
            });
            this.dsmNameOneOption = this.dsmNameTwoOption = await dsmNameDatahelper(this.recordid,this.vehicleId,this);this.nonDlrDsmNameOneOption = this.nonDlrDsmNameTwoOption = await nonDsmNameDatahelper(this.recordid,this.vehicleId,this);//8307
        await TradeCertificateValidation({ loanApplicationId: this.recordid }).then(result => {if(result >= 0 && this.vehicleTypeDetail?.toLowerCase()==='new'){this.tradeCertificateValue=parseInt(result, 10);}});
        //Ola integration changes
        await getLoanApplicationReadOnlySettings({leadSource:this.leadSource})
        .then(data => {let fieldList = [];if(data){fieldList=data.Input_Labels__c.split(';');}if(fieldList.length>0){this.disabledServiceCharges = fieldList.includes('Service charges')? true :this.disabledServiceCharges;this.disabledDocumentationCharges = fieldList.includes('Documentation charges')? true :this.disabledDocumentationCharges;this.disableStampingCharges = fieldList.includes('Stamping charges')? true :this.disableStampingCharges;this.twRefinance = fieldList.includes('Referred By')? true :this.twRefinance;this.disabledReferrerIncentive = fieldList.includes('Referrer incentive')? true :this.disabledReferrerIncentive;this.disabledReferrerName = fieldList.includes('Referrer name')? true :this.disabledReferrerName;this.disabledCheckEligibility = false;this.provisionalChannelCostValue = this.provisionalChannelCostValueOla;/**OLA-21**/;this.flagToCheckValidity = false;//OLA-40
            }
        }).catch(error => { });
        //Ola Integration changes
        if(this.leadSource=='OLA' && this.currentStage=='Final Terms'){
            this.disableEverything();
            scorecardvalue(this.template);
        }
        if(this.leadSource=='Hero' && this.currentStage=='Final Terms'){this.disableEverything();scorecardvalueHero(this.template);this.disableStampingCharges = false;this.stampingChargesValue = null;this.manufacturerIncentiveValue = this.mfrIncentiveHero;this.provisionalChannelCostValue = this.provisionalChannelCostValueOla;}//Hero CISH-02 && CISH-48
        if(this.finanaceAmountFlag){this.requiredLoanAmount=this.financeAmount;
            this.finanaceAmountFlag = false;}
        // let IES = await getIESresponse(this.recordid);
        //  if(IES && IES != false){ this.disabledrepay = true; this.repaymentModeValue = 'S' }
        } catch (error) {} 
        if(this.isRevokedLoanApplication){this.disableEverything()}
        this.isRendered=true;if(this.isD2C){if(this.currentStage==='Credit Processing' && this.subStage==='Final Terms'){this.disableStampingCharges = false;this.disabledScheme = false;this.template.querySelector('lightning-input[data-id=stamChar]').disabled=false;}this.manufacturerIncentiveValue = this.finalTermDataD2C.Mfr_incentive__c;}//CISH-04
        /*CISP-4785*/if(this.fromVfPage){await recalculatePayoutValues(this);}
        this.isSpinnerMoving = false;
        if(this.isTractor){let getResponse = await getPurchaseprice({ loanApplicationId: this.recordid, 'vehicleId' : this.vehicleId });this.vehiclePurchaseprice = parseInt(getResponse, 10); console.log('+++++vehiclePurchaseprice1 ' + this.vehiclePurchaseprice + ' ++Loan '+this.loanAmountDetail);} //SFTRAC-909
        getbenefitioryDetails({loanApplicationId: this.recordid}).then((res)=>{console.log(res);if(!(res[0]?.Dealership_Nature__c=='SDR' ||res[0]?.Dealership_Nature__c=='SSP')){this.disabledDealerIncentiveAmountSubDealer=true;this.disableDealerSubPercentage=true;this.isSubDealer=false;/*CISP-13993*/}}).catch(err=>console.error(err));
        //CISP-20504
        roiMasterForGrossIRR({loanApplicationId : this.recordid,productType : this.productTypeDetail,productSegment:this.productSegment,vehicleCategory : this.vehicleTypeDetail})    
        .then(result =>{let parsedData = JSON.parse(result);if(parsedData.mingross != null && parsedData.maxgross != null){this.mingross = parsedData.mingross;this.maxgross = parsedData.maxgross;}});
        //CISP-20504
    }
    get isInstallmentTypeDisabled(){return this.isD2C || this.nonD2cDsaTW;}//CISP-14142
    get isDSMNameOneDisabled() {if(this.nonD2cDsaTW){return ((this.currentStage=='Credit Processing' && this.subStage=='Final Terms')?false:(this.dsmNameOneValue && this.isNotTractor)) || (!this.dsmNameOneOptionList?.length > 0);}else{return (this.dsmNameOneValue && this.isNotTractor) || this.isD2C}}//CISP-13412
    get isDSMNameTwoDisabled() {if(this.nonD2cDsaTW){return ((this.currentStage=='Credit Processing' && this.subStage=='Final Terms')?false:(this.dsmNameTwoValue && this.isNotTractor)) || (!this.dsmNameTwoOptionList?.length > 0);}else{return (this.dsmNameTwoValue && this.isNotTractor) || this.isD2C}}//CISP-13412
    @api isRevokedLoanApplication;
    get dsmNameOneOptionList(){if(this.dsmNameOneOption && this.dsmNameOneOption.length>0){if((this.fromScheme && this.dsmNameOneValue) || this.dsmNameOneValue && this.iconButtonCaptureUpload){this.disableDsmName1=true;}else{this.disableDsmName1=false;}return this.dsmNameOneOption;}else{this.disableDsmName1=true;}} 
    get dsmNameTwoOptionList(){if(this.dsmNameTwoOption && this.dsmNameTwoOption.length > 1){if((this.fromScheme && this.dsmNameTwoValue) || this.dsmNameTwoValue && this.iconButtonCaptureUpload){this.disableDsmName2=true;}else{this.disableDsmName2=false;}return this.dsmNameTwoOption;}else{this.disableDsmName2=true;}} 
    get nonDsmNameOneOptionList(){if(this.nonDlrDsmNameOneOption && this.nonDlrDsmNameOneOption.length>0){this.disableNonDsmName1=false;return this.nonDlrDsmNameOneOption;}else{this.disableNonDsmName1=true;}}
    get nonDsmNameTwoOptionList(){if(this.nonDlrDsmNameTwoOption && this.nonDlrDsmNameTwoOption.length > 1){this.disableNonDsmName2=false;return this.nonDlrDsmNameTwoOption;}else{this.disableNonDsmName2=true;}}
    get dsaReferrerNameRequired() { return this.dsaReferrer || this.isReferrerNameRequired;}
    navigateToHomePage(){isCommunity().then(response => {if(response){this[NavigationMixin.Navigate]({type: 'standard__namedPage',attributes: {pageName: 'home'},});}else{this[NavigationMixin.Navigate]({type: 'standard__navItemPage',attributes: {apiName: 'Home'}});}})}


    toastMsg(message){this.showToast('Error', message, 'Error');}
    viewUploadViewFloater(){ this.showFileUploadAndView=true; }
    closeUploadViewFloater(event){ this.showFileUploadAndView=false; }
    disableEverything(){
        let allElements=this.template.querySelectorAll('*');
        allElements.forEach(element =>{element.disabled=true;
            if(element.label && element.label ==='Installment Type' && this.currentStage==='Credit Processing' && this.activetab===FinalTerms && this.disabledCheckEligibility===false && this.productTypeDetail?.toLowerCase() !== 'Two Wheeler'.toLowerCase() && !this.isD2C){element.disabled=false;}//CISP-2386
         });
    }
    async getApplicationDetailsFunction() {await getApplicationDetailsHelper(this);}
    showToast(title, message, variant){const evt = new ShowToastEvent({title: title, message: message, variant: variant,});this.dispatchEvent(evt);}
    modifyingDataacctoScheme(schemeRec, loanAmount){ //INDI-4705
        if(schemeRec){
            this.disableddelinquencyFundType=true;this.disabledDealerExpReimburseType=true;this.disabledMfrExpReimburseAmt=true;this.disabledMfrExpReimbursePercentage=true;this.disabledMfrExpReimburseType=true;this.DsmInc1fromScheme=false;this.DsmInc2fromScheme=false;//this.advanceEMi=false;
            if(checkInput(schemeRec.Stamping_Charges__c)){this.stampingChargesValue=schemeRec.Stamping_Charges__c;this.disableStampingCharges=true;}else{this.disableStampingCharges=false;}
            if(schemeRec.ECS_verification_Not_Applicable__c==true){this.ecsValue=null;this.disabledecsVerificationChargeBy=true;
            }else{if(checkInput(schemeRec.ECS_verification_by_Bank_customer__c)){this.ecsValue=schemeRec.ECS_verification_by_Bank_customer__c;this.disabledecsVerificationChargeBy=true;}else{this.disabledecsVerificationChargeBy=false;}}
            if(checkInput(schemeRec.Verification_charges__c)){this.verificationChargesValue=schemeRec.Verification_charges__c;this.disabledecsVerificationCharge=true;}else{this.disabledecsVerificationCharge=false;}
            if(checkInput(schemeRec.Delinquency_Fund__c)){this.delinquencyFundValue=schemeRec.Delinquency_Fund__c;this.disableddelinquencyFund=true;}else{this.disableddelinquencyFund=false;}
            if(checkInput(schemeRec.Deliquency_Fund_type__c)){this.delinquencyFundTypeValue=schemeRec.Deliquency_Fund_type__c;}
            if(checkInput(schemeRec.RTO_Prefix__c)){this.rtoPrefixValue=schemeRec.RTO_Prefix__c;this.twNew=true;}else{if(this.vehicleTypeDetail.toLowerCase() !== 'new'.toLowerCase()){this.twNew=false;}}
            if(checkInput(schemeRec.Dlr_Exp_Reimburse_Amt__c)){this.dealerExpReimburseAmountValue=schemeRec.Dlr_Exp_Reimburse_Amt__c;this.disabledExpReimburseAmountValue=true;}else{this.disabledExpReimburseAmountValue=false;}
            if(checkInput(schemeRec.Dlr_Exp_Reimbursement__c)){this.dealerExpReimbursePercentageValue=schemeRec.Dlr_Exp_Reimbursement__c;this.disabledDealerExpReimbursePercentage=true;}else{this.disabledDealerExpReimbursePercentage=false;}
            if(checkInput(schemeRec.Dlr_Exp_Reimburse_Type__c)){this.dealerExpReimburseTypeValue=schemeRec.Dlr_Exp_Reimburse_Type__c;}
            if(checkInput(schemeRec.Mfr_Exp_Reimburse_Amt__c)){this.mfrExpReimburseAmtValue=schemeRec.Mfr_Exp_Reimburse_Amt__c;}
            if(checkInput(schemeRec.Mfr_Exp_Reimburse__c)){this.mfrExpReimbursePercentageValue=schemeRec.Mfr_Exp_Reimburse__c;}
            if(checkInput(schemeRec.Mfr_Exp_Reimburse_Type__c)){this.mfrExpReimburseTypeValue=schemeRec.Mfr_Exp_Reimburse_Type__c;}
            if(checkInput(schemeRec.Dealer_discount_to_Customer__c)){this.dealerDiscounttoCustomerValue=roundOff(schemeRec.Dealer_discount_to_Customer__c);this.disabledDealerDiscounttoCustomer=true;}else{this.productTypeDetail == 'Passenger Vehicles' ? this.vehicleSubCategoryDetail == 'UPD' ? this.disabledDealerDiscounttoCustomer = true : this.disabledDealerDiscounttoCustomer = false : this.disabledDealerDiscounttoCustomer = false;}if(checkInput(schemeRec.DSM_Name1__c)){this.dsmNameOneValue=schemeRec.DSM_Name1__c;this.disableDsmName1=true;this.fromScheme=true;}else{this.disableDsmName1=false;}if(checkInput(schemeRec.DSM_Name2__c)){this.dsmNameTwoValue=schemeRec.DSM_Name2__c;this.disableDsmName2=true;this.fromScheme=true;}else{this.disableDsmName2=false;}if(checkInput(schemeRec.Referred_By__c)){this.referredbyValue = schemeRec.Referred_By__c;this.twRefinance=true;}else{this.twRefinance = false;}if(checkInput(schemeRec.Referrer_Incetive__c)){this.referrerIncentiveValue=roundOff(schemeRec.Referrer_Incetive__c);this.disabledReferrerIncentive=true;}else{this.disabledReferrerIncentive=false;}if(checkInput(schemeRec.Referrer_Name__c)){this.referrerNameValue=schemeRec.Referrer_Name__c;this.disabledReferrerName=true;}else{this.disabledReferrerName=false;}if(checkInput(schemeRec.Branch__c)){this.branchValue=schemeRec.Branch__c;this.disabledBranch=true;}else{this.disabledBranch=false;}if(checkInput(schemeRec.Emp_No__c)){this.empNoValue=schemeRec.Emp_No__c;this.disabledEmpNo=true;}else{this.disabledEmpNo=false;}if(checkInput(schemeRec.Emp_Name__c)){this.empNameValue=schemeRec.Emp_Name__c;this.disabledEmpName=true;}else{this.disabledEmpName=false;}if(checkInput(schemeRec.Deal_no__c)){this.dealNoValue=schemeRec.Deal_no__c;this.disabledDealNo=true;}else{this.disabledDealNo=false;}if(checkInput(schemeRec.Provision_Channel_Cost__c)){this.provisionalChannelCostValue=schemeRec.Provision_Channel_Cost__c;this.disabledProvisionalChannelCost=true;}else if(checkInput(this.provisionalChannelCostValueTemp)){this.disabledProvisionalChannelCost=true;this.provisionalChannelCostValue = this.provisionalChannelCostValueTemp;}else{this.disabledProvisionalChannelCost=false;}
            if(checkInput(schemeRec.DSA_Pay__c)){this.dsaPayValue=schemeRec.DSA_Pay__c;this.disabledDsaPay=true;}else{this.disabledDsaPay=false;}
            if(checkInput(schemeRec.RCU_Retention_Charges__c)){this.rcuRetentionChargesValue=schemeRec.RCU_Retention_Charges__c;this.disabledRcu=true;}else{this.disabledRcu=false;}
            //if(schemeRec.Advance_EMI__c === true){this.advanceEmiValue=true;this.advanceEMi=true;this.monitoriumDaysValue='0';helperTwo.getEmiDateList(this);}else{this.monitoriumDaysValue='30';helperTwo.getEmiDateList(this);}//CISP-22168 (commented because we are using scheme Advance emi instead of Final term)
            if(checkInput(schemeRec.Payout_Cap__c)){this.payoutCapValue=schemeRec.Payout_Cap__c;}
            let currentStage= this.currentStage!=='Credit Processing' ? true : false;
            /*CISP-4785 Start*/
            if(this.nonD2cDsaTW) {
                this.updateFieldbasedOnLoanAmt(schemeRec, loanAmount, true);
            } else{
                this.updateFieldbasedOnLoanAmt(schemeRec, loanAmount, currentStage);
            }/*CISP-4785 End*/
        }
    }

    updateFieldbasedOnLoanAmt(schemeRec, loanAmount,currentStage){if(schemeRec){
        if(schemeRec.Installment_Type__c){this.schemeInsTypes = schemeRec.Installment_Type__c;}
        if(schemeRec.Installment_Frequency__c){this.schemeInsFrequency = schemeRec.Installment_Frequency__c;}
        if(checkInput(schemeRec.Due_Date_Shift_Charges__c)){this.dueDateShiftChargesValue=schemeRec.Due_Date_Shift_Charges__c;this.disabledueDateShiftCharges=true;}else{this.disabledueDateShiftCharges=false;}
        if(checkInput(schemeRec.DocCharges__c)){this.documentationChargesValue=roundOff(schemeRec.DocCharges__c);this.disabledDocumentationCharges=true;}else if(checkInput(schemeRec.Doc_Charges_p__c)){this.documentationChargesValue=roundOff(((schemeRec.Doc_Charges_p__c*loanAmount)/100)).toFixed(2);this.disabledDocumentationCharges=true;}else{if(currentStage){this.disabledDocumentationCharges=false;}}
        if(checkInput(schemeRec.ServiceCharges__c)){roundOff(this.serviceChargesValue=schemeRec.ServiceCharges__c);this.disabledServiceCharges=true;}else if(checkInput(schemeRec.Service_Charges_p__c)){this.serviceChargesValue=roundOff(((schemeRec.Service_Charges_p__c*loanAmount)/100)).toFixed(2);this.disabledServiceCharges=true;}else{if(currentStage){this.disabledServiceCharges=false;}}
        /*CISP-4785*/if(this.nonD2cDsaTW){if(checkInput(schemeRec.Delinquency_Fund__c)){this.delinquencyFundValue = schemeRec.Delinquency_Fund__c;this.disableddelinquencyFund = true;}else{this.disableddelinquencyFund = false;}}
        if(checkInput(schemeRec.Dealer_incentive_amount_main_dealer__c)){this.dealerIncentiveAmountMainValue=roundOff(schemeRec.Dealer_incentive_amount_main_dealer__c);this.disabledDealerIncentiveAmountMainDealer=true;}else if(checkInput(schemeRec.Dealer_incentive_amount_main_dealer_p__c)){this.dealerIncentiveAmountMainValue=roundOff(((schemeRec.Dealer_incentive_amount_main_dealer_p__c * loanAmount)/100));this.disabledDealerIncentiveAmountMainDealer = true;}else{if(currentStage){this.disabledDealerIncentiveAmountMainDealer = false;}}
        if(checkInput(schemeRec.Dealer_incentive_amount_main_dealer_p__c)){this.dealerMainPercentageValue=(schemeRec.Dealer_incentive_amount_main_dealer_p__c).toFixed(2);this.disableDealerMainPercentage=true;}else if(checkInput(schemeRec.Dealer_incentive_amount_main_dealer__c) && loanAmount){this.dealerMainPercentageValue=((schemeRec.Dealer_incentive_amount_main_dealer__c / loanAmount)*100).toFixed(2);this.disableDealerMainPercentage=true;}else{if(currentStage){this.disableDealerMainPercentage=false;}}
        if(checkInput(schemeRec.Dealer_incentive_amount_sub_dealer__c)){this.dealerIncentiveAmountSubValue=roundOff(schemeRec.Dealer_incentive_amount_sub_dealer__c);this.disabledDealerIncentiveAmountSubDealer=true;}else if(checkInput(schemeRec.Dealer_incentive_amount_sub_dealer_p__c)){this.dealerIncentiveAmountSubValue = roundOff(((schemeRec.Dealer_incentive_amount_sub_dealer_p__c * loanAmount)/100));this.disabledDealerIncentiveAmountSubDealer = true;} else{/*CISP-4785 Start*/if(currentStage &&!this.nonD2cDsaTW)/*CISP-4785 End*/{this.disabledDealerIncentiveAmountSubDealer = false;}}
        if(checkInput(schemeRec.Dealer_incentive_amount_sub_dealer_p__c)){this.dealerSubPercentageValue=(schemeRec.Dealer_incentive_amount_sub_dealer_p__c).toFixed(2);this.disableDealerSubPercentage=true;}else if(checkInput(schemeRec.Dealer_incentive_amount_sub_dealer__c) && loanAmount){this.dealerSubPercentageValue=((schemeRec.Dealer_incentive_amount_sub_dealer__c / loanAmount)*100).toFixed(2);this.disableDealerSubPercentage=true;}else{if(currentStage){this.disableDealerSubPercentage=false;}}
        if(checkInput(schemeRec.Gift_through_dealer_amount__c)){this.giftThroughDealerAmountValue=roundOff(schemeRec.Gift_through_dealer_amount__c);this.disabledGiftThroughDealerAmount=true;}else if(checkInput(schemeRec.Gift_through_dealer_amount_p__c)){this.giftThroughDealerAmountValue=roundOff(((schemeRec.Gift_through_dealer_amount_p__c * loanAmount)/100));this.disabledGiftThroughDealerAmount=true;}else{if(currentStage){this.disabledGiftThroughDealerAmount=false;}}
        if(checkInput(schemeRec.Gift_through_dealer_amount_p__c)){this.giftThroughDealerPercentageValue=(schemeRec.Gift_through_dealer_amount_p__c).toFixed(2);this.disableGiftThroughDealerPercentage=true;}else if(checkInput(schemeRec.Gift_through_dealer_amount__c) && loanAmount){this.giftThroughDealerPercentageValue = ((schemeRec.Gift_through_dealer_amount__c / loanAmount)*100).toFixed(2);this.disableGiftThroughDealerPercentage=true;}else{if(currentStage){this.disableGiftThroughDealerPercentage=false;}}
        if(!this.haveHeroMIValue){if(checkInput(schemeRec.Mfr_incentive__c)){this.manufacturerIncentiveValue=roundOff(schemeRec.Mfr_incentive__c);this.disabledManufacturerIncentive=true;}else if(checkInput(schemeRec.Mfr_incentive_p__c)){this.manufacturerIncentiveValue = roundOff(((schemeRec.Mfr_incentive_p__c * loanAmount)/100));this.disabledManufacturerIncentive=true;}else{if(currentStage){this.disabledManufacturerIncentive=false;}}}
        if(!this.haveHeroMIValue){if(checkInput(schemeRec.Mfr_incentive_p__c)){this.mfrIncentivePercentageValue=(schemeRec.Mfr_incentive_p__c).toFixed(2);this.disableMfrIncentivePercentage=true;}else if(checkInput(schemeRec.Mfr_incentive__c) && loanAmount){this.mfrIncentivePercentageValue=((schemeRec.Mfr_incentive__c / loanAmount)*100).toFixed(2);this.disableMfrIncentivePercentage=true;}else{if(currentStage){this.disableMfrIncentivePercentage=false;}}}
        if(checkInput(schemeRec.DSM_Incentive1__c)){this.dsmIncentiveOneValue=roundOff(schemeRec.DSM_Incentive1__c);this.disabledDsmIncentiveOne=true;this.DsmInc1fromScheme=true;}else if(checkInput(schemeRec.DSM_Incentive1_p__c)){this.dsmIncentiveOneValue = roundOff(((schemeRec.DSM_Incentive1_p__c * loanAmount)/100));this.disabledDsmIncentiveOne=true;this.DsmInc1fromScheme=true;}else{if(currentStage && this.isNotTractor){/*CISP-4785 Start*/if((this.forTwoWheeler&&this.dsmNameOneValue)||!this.nonD2cDsaTW){/*CISP-4785 End*/this.disabledDsmIncentiveOne=false;}}}
        if(checkInput(schemeRec.DSM_Incentive1_p__c)){this.dsmOnePercentageValue=(schemeRec.DSM_Incentive1_p__c).toFixed(2);this.disabledsmOnePercentage=true;}else if(checkInput(schemeRec.DSM_Incentive1__c) && loanAmount){this.dsmOnePercentageValue=((schemeRec.DSM_Incentive1__c / loanAmount)*100).toFixed(2);this.disabledsmOnePercentage=true;}else{if(currentStage){/*CISP-4785 Start*/if((this.forTwoWheeler&&this.dsmNameOneValue)||!this.nonD2cDsaTW){/*CISP-4785 End*/this.disabledsmOnePercentage=false;}}}
        if(checkInput(schemeRec.DSM_Incentive2__c)){this.dsmIncentiveTwoValue=roundOff(schemeRec.DSM_Incentive2__c);this.disabledDsmIncentiveTwo=true;this.DsmInc2fromScheme=true;}else if(checkInput(schemeRec.DSM_Incentive2_p__c)){this.dsmIncentiveTwoValue=roundOff(((schemeRec.DSM_Incentive2_p__c * loanAmount)/100));this.disabledDsmIncentiveTwo=true;this.DsmInc2fromScheme=true;}else{if(currentStage && this.isNotTractor){/*CISP-4785 Start*/if((this.forTwoWheeler&&this.dsmNameTwoValue)||!this.nonD2cDsaTW){/*CISP-4785 End*/this.disabledDsmIncentiveTwo=false;}}}
        if(checkInput(schemeRec.DSM_Incentive2_p__c)){this.dsmTwoPercentageValue=(schemeRec.DSM_Incentive2_p__c).toFixed(2);this.disableDsmTwoPercentage=true;}else if(checkInput(schemeRec.DSM_Incentive2__c) && loanAmount){this.dsmTwoPercentageValue = ((schemeRec.DSM_Incentive2__c / loanAmount)*100).toFixed(2);this.disableDsmTwoPercentage=true;}else{if(currentStage){/*CISP-4785 Start*/if((this.forTwoWheeler&&this.dsmNameTwoValue)||!this.nonD2cDsaTW){/*CISP-4785 End*/this.disableDsmTwoPercentage=false;}}}
    }}/*CISP-4785 Start*/
    checkDocumentationCharges(){if(!this.isD2C && !this.fromVfPage && this.leadSource !== 'Hero') {let isValBreach = helper.documentationCharges(this);if(isValBreach && this.isSubmit){this.showToast("warning", 'Please re-check amounts mentioned under Service charges / Doc charges', 'warning');this.disabledDocumentationCharges=false;this.disabledServiceCharges=false;this.docVal=true;}else{this.docVal=false;}}}//CISH-04
    checkServiceCharges(){if(!this.isD2C && !this.fromVfPage && this.leadSource !== 'Hero') {let isValBreach = helper.serviceCharges(this);/*CISP-4785 End*/if(isValBreach && this.isSubmit){this.showToast("warning", 'Please re-check amounts mentioned under Service charges / Doc charges', 'warning');this.disabledDocumentationCharges=false;this.disabledServiceCharges=false;this.serVal=true;}else{this.serVal=false;}}//CISH-04
}
debounce(callback, wait) {

    return (...args) => {
        clearTimeout(this.timeOut);
        this.timeOut = setTimeout(function () { callback.apply(this, args); }, wait);
    };
  }
  get isTractor(){return this.productTypeDetail == 'Tractor';}get isNotTractor(){return this.productTypeDetail != 'Tractor';} //sftrac-84
  get isNotRefianceTractor(){return !((this.isTractor && this.isRefinance) || (this.isTractor && this.isUsed && this.isTopUpLoan) || (this.productTypeDetail == 'Two Wheeler' && this.isTWRefinance));} //updated SFTRAC-172
  handleEmiChange(event){helperTwo.handleEmiChangeHelper(this,event);}
  handleInstallmentSchedule(){this.isModalOpen=true;}handleCloseModal(){this.isModalOpen=false;}
  handleInsSubmit(){this.isModalOpen=false;this.isInsSubmitted = true;}
}