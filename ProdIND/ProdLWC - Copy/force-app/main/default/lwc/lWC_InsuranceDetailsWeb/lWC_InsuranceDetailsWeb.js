import { LightningElement, track, api, wire } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import LightningCardCSS from '@salesforce/resourceUrl/loanApplication';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import getFinalTermData from '@salesforce/apex/IND_OfferScreenController.loadOfferScreenData';//CISP-2408
import createFinalTermRecord from '@salesforce/apex/FinalTermscontroller.createFinalTermRecord';
import doOfferEngineCallout from '@salesforce/apexContinuation/IntegrationEngine.doOfferEngineCallout';
import doD2COfferEngineCallout from '@salesforce/apexContinuation/D2C_IntegrationEngine.doD2COfferEngineCallout';
//import getInsurancePremium from '@salesforce/apex/IND_InsuranceDetailsLWC_controller.getInsurancePremium';
import getFundingAvailibility from '@salesforce/apex/IND_InsuranceDetailsLWC_controller.getFundingAvailibility';
import sendInsuranceConsent from '@salesforce/apex/IND_InsuranceDetailsLWC_controller.sendInsuranceConsent';
import submitInsuranceDetails from '@salesforce/apex/IND_InsuranceDetailsLWC_controller.submitInsuranceDetails';
import getProductTypeFromOpp from '@salesforce/apex/IND_InsuranceDetailsLWC_controller.getProductTypeFromOpp';
import getApplicantId from '@salesforce/apex/IND_InsuranceDetailsLWC_controller.getApplicantId';
import updateInsuranceConsentReceived from '@salesforce/apex/IND_InsuranceDetailsLWC_controller.updateInsuranceConsentReceived';
import getInsuranceConsentCheckboxValue from '@salesforce/apex/IND_InsuranceDetailsLWC_controller.getInsuranceConsentCheckboxValue';
import checkRetryExhausted from '@salesforce/apex/IND_InsuranceDetailsLWC_controller.checkRetryExhausted';
import { updateRecord,getRecord } from 'lightning/uiRecordApi';
import Borrower from '@salesforce/label/c.Borrower';
import CoBorrower from '@salesforce/label/c.CoBorrower';
import indusIndHome from '@salesforce/label/c.IndusInd_Home';
import SuccessMessage from '@salesforce/label/c.SuccessMessage';
import FailureMessage from '@salesforce/label/c.FailureMessage';
import Give_CoBorrower_Consent_First from '@salesforce/label/c.Give_CoBorrower_Consent_First';
import Customer_Not_Eligible_For_Plan from '@salesforce/label/c.Customer_Not_Eligible_For_Plan';
import Give_Consent_First from '@salesforce/label/c.Give_Consent_First';
import Consent_Already_Received from '@salesforce/label/c.Consent_Already_Received';
import Consent_Sent_Successfully from '@salesforce/label/c.Consent_Sent_Successfully';
import CoborrowerConsentNotReceived from '@salesforce/label/c.CoborrowerConsentNotReceived';
//CREATED BY ANJI REDDY (35 to 42)
import doInsuranceRecommendationCallout from '@salesforce/apexContinuation/IntegrationEngine.doInsuranceRecommendationCallout';
import callInuranceRecAPI from '@salesforce/apex/IND_InsuranceDetailsLWC_controller.callInuranceRecAPI';
import doInsurancePremiumCallout from '@salesforce/apexContinuation/IntegrationEngine.doInsurancePremiumCallout';
import doSmsCallout from '@salesforce/apexContinuation/IntegrationEngine.doSmsGatewayCallout';
import getMotorInsurancePreimum from '@salesforce/apex/IND_InsuranceDetailsLWC_controller.getMotorInsurancePreimum';
import getMotorInsuranceFromLoanDetails from '@salesforce/apex/IND_InsuranceDetailsLWC_controller.getMotorInsuranceFromLoanDetails';
import getInsuranceDetailsFromMaster from '@salesforce/apex/IND_InsuranceDetailsLWC_controller.getInsuranceDetailsFromMaster';
import existInsuranceDetailsMethod from '@salesforce/apex/IND_InsuranceDetailsLWC_controller.existInsuranceDetailsMethod';
//import updateDeviationDetails from '@salesforce/apex/IND_InsuranceDetailsLWC_controller.updateDeviationDetails';
import CreditProcessing from '@salesforce/label/c.Credit_Processing';

//Custom Labels
import PassengerVehicles from '@salesforce/label/c.PassengerVehicles';
import TwoWheeler from '@salesforce/label/c.TwoWheeler';
import detailsSaved from '@salesforce/label/c.detailsSaved';
//custom Labels Created By Nandini
import COMBO from '@salesforce/label/c.COMBO';
import HEALTH from '@salesforce/label/c.HEALTH';
import GPA from '@salesforce/label/c.GPA';
import MOTOR from '@salesforce/label/c.MOTOR';
import Retry_Exhausted from '@salesforce/label/c.Retry_Exhausted';

import getCurrentSubStage from '@salesforce/apex/IND_InsuranceDetailsLWC_controller.getCurrentSubStage';
import isCommunity from '@salesforce/apex/LwcLOSLoanApplicationCntrl.isCommunity';
import getLoanApplicationHistory from '@salesforce/apex/LwcLOSLoanApplicationCntrl.getLoanApplicationHistory';

import Gross_IRR from '@salesforce/schema/Final_Term__c.Gross_IRR__c';
import final_ID_FIELD from '@salesforce/schema/Final_Term__c.Id';
import EMI_Amount from '@salesforce/schema/Final_Term__c.EMI_Amount__c';
import CRM_IRR from '@salesforce/schema/Final_Term__c.CRM_IRR__c';
import Net_IRR from '@salesforce/schema/Final_Term__c.Net_IRR__c';
import Net_IRR_DECIMAL from '@salesforce/schema/Final_Term__c.Net_IRR_Decimal__c';
import isNavigate from '@salesforce/schema/Final_Term__c.isNavigate__c';
import Inputted_IRR from '@salesforce/schema/Final_Term__c.Inputted_IRR__c';//CISP-2533
import OPP_ID_FIELD from '@salesforce/schema/Opportunity.Id';
import Submitted_Tabs from '@salesforce/schema/Opportunity.Submitted_Tabs__c';
import Insurance_business_done_by from '@salesforce/schema/Opportunity.Insurance_business_done_by__c';

//Custom Labels
import COMBO_GPA_OR_HEALTH_LABEL from '@salesforce/label/c.COMBO_GPA_OR_HEALTH';
import GPA_OR_COMBO_LABEL from '@salesforce/label/c.GPA_OR_COMBO';
import NOT_OPTED_INSURANCE_MSG_LABEL from '@salesforce/label/c.NOT_OPTED_INSURANCE_MSG';
//Applicant consent fields.
import APPLICATION_FORM_SMS_SENT from '@salesforce/schema/Applicant__c.Application_Form_SMS_Sent__c';
import APPLICANT_ID from '@salesforce/schema/Applicant__c.Id';
import INSURANCE_CONSENT_SENT from '@salesforce/schema/Applicant__c.Insurance_consent_sent_on__c';
import APPLICANT_InsuranceConsentOTP from '@salesforce/schema/Applicant__c.Insurance_Consent_OTP__c';
import deleteExistingPlans from '@salesforce/apex/IND_InsuranceDetailsLWC_controller.deleteExistingPlans';
import fetchOppourtunityData from '@salesforce/apex/IND_InsuranceDetailsLWC_controller.fetchOppourtunityData';
import {NavigationMixin} from 'lightning/navigation';
import ReadOnlyLeadAccess from '@salesforce/label/c.ReadOnlyLeadAccess';
import Table_Code from '@salesforce/schema/Final_Term__c.Table_Code__c';//CISP-16547
import DR_Penal_Interest from '@salesforce/schema/Final_Term__c.DR_Penal_Interest__c';//CISP-16547
import Interest_Version_No from '@salesforce/schema/Final_Term__c.Interest_Version_No__c';//CISP-16547
import mclrRate from '@salesforce/schema/Final_Term__c.mclrRate__c';//CISP-16547
import fetchDataFromApplicatntObj from '@salesforce/apex/IND_InsuranceDetailsLWC_controller.fetchDataFromApplicatntObj';
import getFinalTermLoanAmount from '@salesforce/apex/IND_InsuranceDetailsLWC_controller.getFinalTermLoanAmount';//CISP_18978 
const fixedInsPlan = [MOTOR, 'LI_EMI', 'TATA_EMI', 'LI'];
const PlanforCoborrower = ['FLEXI',COMBO, 'GPA', 'LI'];
import getDocumentsToCheckPan from '@salesforce/apex/IND_LWC_LoanDetailsCntrl.getDocumentsToCheckPan';//CISP-3938
import userId from '@salesforce/user/Id';
import UserNameFIELD from '@salesforce/schema/User.Name';
import EmployeeNumber from '@salesforce/schema/User.EmployeeNumber';
import Message_Offer_Engine_Failure from '@salesforce/label/c.Message_Offer_Engine_Failure'; //CISP-19428
import Message_Offer_Engine_Success from '@salesforce/label/c.Message_Offer_Engine_Success'; //CISP-19428

export default class LWC_InsuranceDetailsWeb extends NavigationMixin(LightningElement) {
    oppTotalExposureAmt = 0;oppLoanAmount = 0;existingBorrowerExposureAmount = 0;existingCoBorrowerExposureAmount=0;
    existingOtherExposureAmount =0;bankExposureAmount=0; 
    @api recordId;
    @api checkleadaccess;//coming from tabloanApplication
    @api creditval;
    @api responseReApisatus;
    @api callMsterRecords;
    @api activetab;
    @api tablength;
    @track label = {
        Borrower,
        CoBorrower,
        indusIndHome,
        SuccessMessage,
        Give_CoBorrower_Consent_First,
        Customer_Not_Eligible_For_Plan,
        Give_Consent_First,
        Consent_Already_Received,
        Consent_Sent_Successfully,
        TwoWheeler,
        PassengerVehicles,
        detailsSaved,
        CoborrowerConsentNotReceived,
        CreditProcessing,
        COMBO,
        HEALTH,
        GPA,
        MOTOR,
        Retry_Exhausted,
        FailureMessage
    };

    @track fundingTypeValue;
    @track fundingTypeValueForHealthInsurancePlans;
    @track fundingTypeValueForGPAPlans;
    @track fundingTypeValueForComboPlans;
    @track fundingTypeValueForMotorPlans;
    @track isEnableNext = false; //sri
    @track planTypeValue;
    @track tryCatchError;
    @track finalTermId;

    @api applicantId;

    @api productType;

    @api showUpload;
    @api showDocView;
    @api isVehicleDoc;
    @api isAllDocType;
    @track uploadViewDocFlag = false;
    @track isSpinnerMoving = false;
    @track isSecondSpinnerMoving = false;
    @track SpinnerMoving = false; 

    @track healthInsurancePlanList;
    @track gpaPlanList;
    @track comboPlanList;
    @track motorPlanList;

    @track isHealthInsuranceChecked = false;
    @track isGPAChecked = false;
    @track isComboChecked = false;
    @track isMotorChecked = false;

    @track isConsentButtonDisabled = false;
    @track isConsentReceived = false;

    @track isHealthInsuranceDisabled = true;
    @track isGPADisabled = true;
    @track isComboDisabled = true;
    @track isMotorDisabled = true;

    @track disableMotorInsuranceSection = false;

    @track selectedProduct;
    @track selectedPlan;

    @track selectedHealthInsurancePlan;
    @track selectedGPAInsurancePlan;
    @track selectedComboInsurancePlan;
    @track selectedMotorInsurancePlan;

    @track healthInsuranceAmountValue;
    @track gpaInsuranceAmountValue;
    @track comboInsuranceAmountValue;
    @track motorInsuranceAmountValue;

    @api activeTab;

    @track fundedPremiumValue = 0;
    @track totalInsurancePayable;
    @track ltvWithInsurance;
    @track ltvWithoutInsurance;
    @track proposalLtv;
    @track urlId;

    @track healthInsurancePlanComboboxDisabled = true;
    @track comboPlanComboboxDisabled;
    @track gpaPlanComboboxDisabled;

    @track isHealthInsuranceAmountFieldDisabled = true;
    @track isGPAInsuranceAmountFieldDisabled = true;
    @track isComboInsuranceAmountFieldDisabled = true;
    @track isMotorInsuranceAmountFieldDisabled = true;

    @track isSubmitButtonDisabled;
    @track showSubmitButton;

    @track showPopup;
    @track showPopupForAmount;

    @track popupCheckbox;
    @track popupCheckboxChecked;
    @api currentStage;
    @api subStage;
    @track editPlanFlag = false;
    @track isView = true;

    @api insuranceDetailsApi;

    @track defaultHealthPlan = null;
    @track defaultHealthAmount;
    @track defaultHealthFundType;

    @track defaultComboPlan = null;
    @track defaultComboAmount;
    @track defaultComboFundType;

    @track defaultGPAPlan = null;
    @track defaultGPAAmount;
    @track defaultGPAFundType;

    @track helathInuDisabled;
    @track combofunDisabled;
    @track gapfunDisabled;
    @track motorfunDisab = true;
    
    @api iconButton = false;
    @api issmscalloutsborrower = 1;
    @api issmscalloutscoborrower = 1;
    @api fundisabled = false;

    @track consentRequired = false;
    @track isMotorSelectedInL1 = false;
    @track isHealthSelectedInL1 = false;
    @track isComboSelectedInL1 = false;
    @track isGPASelectedInL1 = false;
    @track offerEngineFlag = false;
    @track planChangedD2Ctw = false; // CISP-7000
    emi;// CISP-2408
    leadSource;//D2C Change
    fundingAvailabilityClicked; //D2C Change
    offerEngineEMIChanged =false;//CISP-19428
    get healthInsurancePlanOptions() {
        return this.healthInsurancePlanList;
    }

    get gpaPlanOptions() {
        return this.gpaPlanList;
    }

    get comboPlanOptions() {
        return this.comboPlanList;
    }

    get motorPlanOptions() {
        return this.motorPlanList;
    }

    get isPassengerVehiclesAndBlankLeadSource() {
        return (this.isPassengerVehicles && this.leadSource != 'D2C');
    }

    isPassengerVehicles=false;//Start CISP-3194
    disableComputePremium=false;
    motorfunDisab = true;
    isComboPlanrequired=false;
    isGPAPlanrequired=false;
    isLIEMIDisabled=true;
    isLIEMIChecked=false;
    lIEMIPlanComboboxDisabled=true;
    isLIEMIAmountFieldDisabled=true;
    fundingTypeValueForLIEMIPlans=false;
    lIEMIDisabled=true;
    isFlexiInsuranceDisabled=true;
    isFlexiInsuranceChecked=false;
    isFlexiplanRequired=false;
    flexiInsurancePlanComboboxDisabled=true;
    isFlexiInsuranceAmountFieldDisabled=true;
    fundingTypeValueForFlexiInsurancePlans=false;
    FlexiInuDisabled=true;
    isTATAEMIDisabled=true;
    isTATAEMIChecked=false;
    tATAEMIPlanComboboxDisabled=true;
    isTATAEMIAmountFieldDisabled=true;
    fundingTypeValueForTATAEMIPlans=false;
    tATAEMIDisabled=true;
    lIEMIPlanList;
    isPlanChangedObj = {isPlanChange:false,isComputePremiumClicked:false,isFundToggel:false,isPLanCheckChange:false,isAmountChange:false,isAvailabilityButtonClicked:false,isconsentButtonClicked:false};
    get lIEMIPlanOptions() {
        return this.lIEMIPlanList;
    }
    selectedLIEMIPlan;
    lIEMIAmountValue;
    flexiPlanList;
    isLIEMIPlanRequired=false;
    get flexiInsurancePlanOptions() {
        return this.flexiPlanList;
    }
    selectedFlexiInsurancePlan;
    flexiInsuranceAmountValue;
    tATAEMIPlanList;
    get tATAEMIPlanOptions() {
        return this.tATAEMIPlanList;
    }
    selectedTATAEMIPlan;
    tATAEMIAmountValue;
    isFlexiSelectedInL1 = false;
    defaultFlexiPlan = null;
    defaultFlexiAmount;
    defaultFlexiFundType = false;
    isLIEMISelectedInL1 = false;
    defaultLIEMIPlan = null;
    defaultLIEMIAmount;
    defaultLIEMIFundType = false;
    isTATAEMISelectedInL1 = false;
    defaultTATAEMIPlan = null;
    defaultTATAEMIAmount;
    defaultTATAEMIFundType = false;
    haveNoDataforTW = false;
    haveNoDataforPV = false;
    existingInsDetailList = [];
    @track insuranceDetailsList = []; //D2C Change
    isComputePremiumAPIRun = false;
    comboLIPremium = 0;
    comboEMIPremium = 0;
    eMIPassedinAPI = 0;//End CISP-3194
    submittedTabs;
    expiringWithin60Days //CFDI-1164
    applicantAge;
    applicantHeight;
    applicantWeight;
    disabledHeightAndWeight=true;
    bmiValue;
    isInsuranceSeletedInLOne=false;
    showheightAndWeight = false;

    @track currentUserName;
@track userEmployeeNumber;
 
    @wire(getRecord, { recordId: userId, fields: [UserNameFIELD,EmployeeNumber ]}) 
    currentUserInfo({error, data}) {
        if (data) {
            this.currentUserName = data.fields.Name.value;
            this.userEmployeeNumber = data.fields.EmployeeNumber.value;
        } else if (error) {
            this.error = error ;
        }
    }
    //API2 RESPONSE "FAIL" FOR INSURANCE PERIMUM 
    async getPreimumfromMaster(Ins_Product, Plan_Code) {
        await getMotorInsurancePreimum({
            Ins_Product: Ins_Product,
            Plan_Code: Plan_Code
        }).then(result => {
            if (result == null) {
                this.isComputePremiumAPIRun = true;
                this.isPlanChangedObj.isComputePremiumClicked = true;
                let tempinsuranceDetailsList = this.insuranceDetailsList;
                this.insuranceDetailsList = [];
                tempinsuranceDetailsList.forEach(element => {
                    if (element.isPlanChecked) {
                        element.isAmountFieldDisabled = false;
                    }
                    this.insuranceDetailsList.push(element);
                });
            } else {
                this.isComputePremiumAPIRun = true;
                this.isPlanChangedObj.isComputePremiumClicked = true;
                let tempinsuranceDetailsList = this.insuranceDetailsList;
                this.insuranceDetailsList = [];
                tempinsuranceDetailsList.forEach(element => {
                    if (element.isPlanChecked && element.insProductName === Ins_Product.toUpperCase()) {
                        element.insAmount = result.Premium;
                    }
                    this.insuranceDetailsList.push(element);
                });
            }
            console.log('Perimum comes form Master' + result);
        }).catch(error => {
            console.log('error in getMotorInsurancePreimum =>',error);
        });
    }

    get loanAmountPlusFundedPremium(){ //CISP-19428
        if(this.loanAmount && this.fundedPremiumValue){
          return  parseFloat(this.loanAmount) + this.fundedPremiumValue;
        }else if(this.loanAmount){
            return  parseFloat(this.loanAmount);
        }else if(this.fundedPremiumValue){
           return this.fundedPremiumValue;
        }else{
          return '';
        }   
    }

    isloanAmountAndFundedChanged = false; //CISP-19428
    //method to get API insurance premium response
    async getAPIInsuPerimumResponse(applicantId, Ins_Product) {
        this.isSecondSpinnerMoving = true;
        await doInsurancePremiumCallout({
            applicantId: applicantId,
            Ins_Product: JSON.stringify(Ins_Product),
            Plan_Code: 'Plan',
            loanAppId: this.recordId
        }).then(result => {
            console.log("line 285 ==> ", result);
            let getResponse = JSON.parse(result);
            console.log('status flag of 2nd api', getResponse.Status_Flag);
            // console.log('API2...' + JSON.stringify(getResponse));

            if (getResponse.Status_Flag == 'Failure') {
                this.getPreimumfromMaster(Ins_Product[0].Ins_Product, Ins_Product[0].Plan_Code);
            } else {
                for (let i = 0; i < getResponse.Premium_Details.length; i++) {
                    const product = getResponse.Premium_Details[i];
                    let tempinsuranceDetailsList = this.insuranceDetailsList;
                    this.insuranceDetailsList = [];
                    for (let i = 0; i < tempinsuranceDetailsList.length; i++) {
                        const element = tempinsuranceDetailsList[i];
                        if (element.isPlanChecked && ((element.insProductName === product.Ins_Product.toUpperCase()) || (this.isPassengerVehicles && element.insProductName == 'LI_EMI' && product.Ins_Product == 'COMBO'))) {
                            element.insAmount = product.Premium ? product.Premium : 0;
                            if (element.insProductName ==='LI_EMI' || element.insProductName ==='TATA_EMI') {
                                this.comboLIPremium = product.Combo_LI_Premium ? product.Combo_LI_Premium : 0;
                                this.comboEMIPremium = product.Combo_EMI_Premium ? product.Combo_EMI_Premium : 0;
                                this.eMIPassedinAPI = this.emi;
                            }
                        }
                        this.insuranceDetailsList.push(element);
                    }
                    this.isComputePremiumAPIRun = true;
                    this.isPlanChangedObj.isComputePremiumClicked = true;
                }
                //CISP-19428
                if (this.isPassengerVehiclesAndBlankLeadSource) {
                    this.previousLoanAmount = this.loanAmountPlusFundedPremium;
                    this.isComputePremiumAPIRun = true;
                    this.offerEngineEMIChanged = false;
                    let fundedAmountChanged = false;
                    let latestFundedPremium = 0;
                    if (this.insuranceDetailsList.length > 0) {
                        this.insuranceDetailsList.forEach(element => {
                            if(element.isPlanChecked && element.isFundedChecked && element.insAmount){
                                latestFundedPremium =  parseFloat(latestFundedPremium) + parseFloat(element.insAmount);
                                fundedAmountChanged = true;
                            }
                        });
                        if(fundedAmountChanged && parseFloat(latestFundedPremium) != parseFloat(this.fundedPremiumValue)){
                            this.isFundedchanged = true;
                            this.isloanAmountAndFundedChanged = true;
                            this.fundedPremiumValue = latestFundedPremium;
                        }
                        if(this.isFundedchanged || (this.loanAmountPlusFundedPremium && this.previousLoanAmount && (parseFloat(this.loanAmountPlusFundedPremium) > parseFloat(this.previousLoanAmount)))){
                            this.isRerunOfferAPIRun = false;
                            this.isSecondSpinnerMoving = false;
                            this.showToastMessage('Error','Offer Loan Amount Changed. Please Rerun Offer Engine first','error');
                            return;
                        }else{
                            this.isFundedchanged =false;
                            this.fundisabled=false;
                            this.showToastMessage('Success','Insurance Premium API ran successfully. Please click on Funding Availability button','success');
                        }
                    }
                }
                //CISP-19428
            }
            // console.log('result of 2nd api=>', result);
            this.isSecondSpinnerMoving = false;
        }).catch(error => {
            console.log('ERROR... API2' + JSON.stringify(error));
            this.getPreimumfromMaster(Ins_Product[0].Ins_Product, Ins_Product[0].Plan_Code);
            this.isSecondSpinnerMoving = false;
        });
    }

    /*STEP:1
     If there is no record returned from the "Insurance details" object for the current loan application
     or if there is no consent received, call the API – API1(Insurance Recommendation API). 
     */

    //method to fetch Recommened Premium response
    async getAPIRecoPreimumResponse(result) {
        console.log('result.applicationNo --> ', result.applicationNo);
        var recapi = {
            "loanApplicationId": this.recordId,
            "applicationNo": result.applicationNo,
            "vehicleId": result.vehicleId,
            "Borrower_Type": result.Borrower_Type,
            "age": result.age,
            "gender": result.gender,
            "Product": result.product,
            "Vehicle_Category": result.Vehicle_Category,
            "Variant": result.Variant,
            "Fin_Amount": result.Fin_Amount,
            "Balance_Available": result.Balance_Available,
            "Tenure": result.tenure,
            "Agreement_Value": result.Agreement_Value,
            "Motor_Expiry_Date": result.Motor_Expiry_Date, //still mapping is not clear so hard coding for testing purpose
            "Motor_Premium": result.Motor_Premium
        }
        console.log('recapi ===>', recapi);
        //call the API – API1(Insurance Recommendation API). 
        await doInsuranceRecommendationCallout({
            insuranceRecommendationString: JSON.stringify(recapi)
        }).then(results => {
            //  console.log("line 302", results);
            this.responseReApisatus = JSON.parse(results).Status_Flag;
            console.log('response of doInsuranceRecommendationCallout =>',this.responseReApisatus);
            //If response from API1 is not received
            if (this.responseReApisatus == 'Success') {
                //console.log('result of first api=>', results);
                this.init(results);
            } else {
                checkRetryExhausted({
                    loanApplicationId: this.recordId, attemptFor: 'Insurance Recommendation API', applicantId: this.applicantId
                }).then(response => {
                    console.log('response of checkRetryExhausted =>',response);
                    if(response === SuccessMessage && this.leadSource != 'OLA'){//OLA-70
                        this.callAPIRecomMethod();
                    }
                    else if(response === this.label.Retry_Exhausted || response === this.label.FailureMessage){
                        /*STEP 2:
                        If response from API1 is not received even after configu}).catch(error => {console.error('error in getFinalTermData => ', error);});red number of tries then system should 
                        fetch insurance products and plans from the insurance master.*/
                        this.callInuranceMasterRecords();
                    }else{
                        this.callInuranceMasterRecords();
                    }
                }).catch(error => {
                    console.log('error in checkRetryExhausted =>',error);
                })
            }
        }).catch(error => {
            this.responseReApisatus = 'Error';
            //console.log('Error.... Insurance API 1' + JSON.stringify(error));
            this.dispatchEvent(ShowToastEvent({
                title: "Requried",
                message: error.body.message,
                variant: 'Error',
            }));

            checkRetryExhausted({
                loanApplicationId: this.recordId, attemptFor: 'Insurance Recommendation API', applicantId: this.applicantId
            }).then(response => {
                console.log('response of checkRetryExhausted =>',response);
                if(response === SuccessMessage && this.leadSource !='OLA'){//OLA-70
                    this.callAPIRecomMethod();
                }
                else if(response === this.label.Retry_Exhausted || response === this.label.FailureMessage){
                    /*STEP 2:
                    If response from API1 is not received even after configured number of tries then system should 
                    fetch insurance products and plans from the insurance master.*/
                    this.callInuranceMasterRecords();
                }else{
                    this.callInuranceMasterRecords();
                }
            }).catch(error => {
                console.log('error in checkRetryExhausted =>',error);
            })
        });
    }


    //Fetch insurance products and plans from the insurance master
    async callInuranceMasterRecords() {
        await getInsuranceDetailsFromMaster({
            recordId : this.recordId,
        }).then(result => {
            this.callMsterRecords = result;
            this.init(this.callMsterRecords);
        }).catch(error => {
            console.log(JSON.stringify(error));
        });
    }

    async onloadexistInsuranceDetails() {
        let height;
        let weight;
        let bmi;
        await fetchDataFromApplicatntObj({ loanAppID: this.recordId, appType : this.activeTab })
            .then(response => {
                if (response) {
                    this.applicantId = response.Id;
                    height = response.Height__c ? response.Height__c:null;
                    weight = response.Weight__c ? response.Weight__c:null;
                    bmi = response.BMI__c ? response.BMI__c:null;
                }
            });

        /*On page load,Query the Insurance Details object for the current loan application record.
         If there is a record which means 
         User had already submitted the insurance details and consent is received 
         and is revisiting the page. Pull the relevant details and render on the page and make the page read only*/
        await existInsuranceDetailsMethod({
            loanAppID: this.recordId,
            applicantId: this.applicantId
        }).then(result => {this.isSpinnerMoving = true;
            if (result.length > 0) {
                this.isInsuranceSeletedInLOne = true;
                result.forEach(getInsProdObj => {
                    this.currentStage = getInsProdObj.Stage;
                    this.totalInsurancePayable = getInsProdObj.totalInsurancePayable;
                    this.ltvWithInsurance = getInsProdObj.ltvWithInsurance;
                    this.ltvWithoutInsurance = getInsProdObj.ltvWithoutInsurance;
                    this.fundedPremiumValue = getInsProdObj.premiumFunded;
                    if(getInsProdObj.Ins_Product.toUpperCase() === 'LI_EMI'){
                        this.applicantHeight = height;
                        this.applicantWeight = weight;
                        this.bmiValue = bmi;
                        this.disabledHeightAndWeight = false;
                    }
                    this.existingInsDetailList.push({
                        insProductName : getInsProdObj.Ins_Product.toUpperCase(),
                        isPlanChecked : true,
                        isPlanCheckDisabled : true,
                        insPlanCode : getInsProdObj.Plan_Code,
                        insPlanOptions: [{
                            label: getInsProdObj.Plan_Name,
                            value: getInsProdObj.Plan_Code,
                            insAmount : getInsProdObj.Premium
                        }],
                        isPlanCodeDisabled : true, 
                        insAmount : getInsProdObj.Premium,
                        isAmountFieldDisabled : true,
                        isFundedChecked : getInsProdObj.Disable_Funding == 'Y' ? true : false,
                        isFundedDisabled : true
                    });
                });
                console.log('this.insuranceDetailsList123',this.existingInsDetailList);
            }
            if (this.currentStage === this.label.CreditProcessing && this.subStage === 'Insurance') {
                if(this.tablength == 2 && this.activeTab === this.label.Borrower && this.submittedTabs!= null && this.submittedTabs.includes('L2 - Borrower Insurance')){
                    if (this.existingInsDetailList.length > 0) {
                        this.insuranceDetailsList = this.existingInsDetailList;
                        this.iconButton = true;
                    }else{
                        this.iconButton = false;
                        this.haveNoDataforPV = this.isPassengerVehicles;
                        this.haveNoDataforTW = !this.isPassengerVehicles;
                    }
                    this.disabledHeightAndWeight = true;
                    this.isSpinnerMoving = false;
                    let allElements = this.template.querySelectorAll('*');
                    allElements.forEach(element =>
                        element.disabled = true
                    );
                    const evn = new CustomEvent('coborrower');
                    this.dispatchEvent(evn);
                }else{
                    this.iconButton = false;
                    getFinalTermData({ loanApplicationId: this.recordId,randomvar: '' })
                    .then((data) => {
                        if (data) {
                            let parsedData = JSON.parse(data);
                            this.emi = parsedData.emi ? parsedData.emi : '';
                        }
                    }).catch(error => {console.error('error in getFinalTermData => ', error);});
                    // if(this.leadSource!='OLA'){
                        this.callAPIRecomMethod();//OLA-70
                        //   }
                }
            }else{
                if (this.existingInsDetailList.length > 0) {
                    this.insuranceDetailsList = this.existingInsDetailList;
                    this.iconButton = true;
                }else{
                    this.iconButton = false;
                    this.haveNoDataforPV = this.isPassengerVehicles;
                    this.haveNoDataforTW = !this.isPassengerVehicles;
                }
                this.disabledHeightAndWeight = true;
                this.isSpinnerMoving = false;
            }
        }).catch(error => {
            this.isSpinnerMoving = false;
            console.log('error in existInsuranceDetailsMethod =>', error);
        });
    }

    //calling Recommended API method
    async callAPIRecomMethod() {
        await callInuranceRecAPI({
            appType: this.activeTab,
            loanAppID: this.recordId
        }).then(result => {
            console.log('REcomananded API response ', result);
            //call the method...
            if(result.age){
                this.applicantAge = parseInt(result.age,10);
            }
            if(this.leadSource !='OLA'){//OLA-70   
            this.expiringWithin60Days = result.expiringWithin60Days; // D2C Change //CFDI-1164
            this.getAPIRecoPreimumResponse(result);
        }else{
            this.isSpinnerMoving = false;
             }//OLA-70
        }).catch(error => {
            console.log('error in callInuranceRecAPI =>',error);
            checkRetryExhausted({
                loanApplicationId: this.recordId, attemptFor: 'Insurance Recommendation API', applicantId: this.applicantId
            }).then(response => {
                console.log('response of checkRetryExhausted =>',response);
                if(response === SuccessMessage && this.leadSource!='OLA'){//OLA-70
                    this.callAPIRecomMethod();
                }
                else if(response === this.label.Retry_Exhausted || response === this.label.FailureMessage){
                    this.isSpinnerMoving = false;
                    this.callInuranceMasterRecords();
                }else{
                    this.isSpinnerMoving = false;
                    this.callInuranceMasterRecords();
                }
            }).catch(error => {
                console.log('error in checkRetryExhausted =>',error);
            })
        });
    }

    async fetchSubStage() {
        const currentSubStage = await getCurrentSubStage({ opportunityId: this.recordId })
        this.subStage = currentSubStage;
        console.log('line 555 stage and substage=> ', this.currentStage, this.subStage);

        // if (this.currentStage === this.label.CreditProcessing && this.subStage === 'Insurance') {
            await this.onloadexistInsuranceDetails();
        // }
    }
    isD2CLead;
    @api isRevokedLoanApplication;//CISP-2735
    //totalFundedPremium; //CISP-19428
    loanAmount;//CISP-19428
    async connectedCallback() {
        this.isSpinnerMoving = true; 
        console.log("recordId ---> ", this.recordId, 'current stage = >', this.currentStage, 'subStage=>', this.subStage);
        
        await getProductTypeFromOpp({ recordId: this.recordId })
        .then(result => {
            this.productType = result[0].Product_Type__c;
            this.leadSource =  result[0].LeadSource;//D2C change
            this.isD2CLead = result[0].LeadSource == 'D2C' ? true : false;
            this.submittedTabs = result[0].Submitted_Tabs__c;
            this.oppTotalExposureAmt = result[0].Total_Exposures_Amount__c ? result[0].Total_Exposures_Amount__c : 0; 
            this.existingBorrowerExposureAmount = result[0].Existing_Borrowers_Exposure_Amt__c ? result[0].Existing_Borrowers_Exposure_Amt__c :0;  
            this.existingCoBorrowerExposureAmount = result[0].Existing_Co_Borrowers_Exposure_Amt__c ? result[0].Existing_Co_Borrowers_Exposure_Amt__c :0 ;  
            this.existingOtherExposureAmount = result[0].Existing_Others_Exposure_Amt__c ? result[0].Existing_Others_Exposure_Amt__c : 0;  
            this.bankExposureAmount = result[0].Total_Bank_Exposure__c ? result[0].Total_Bank_Exposure__c : 0;  
            if (this.productType === this.label.PassengerVehicles) {
                this.isPassengerVehicles=true;
            }
            this.showheightAndWeight = (this.leadSource != 'D2C' && this.isPassengerVehicles);
        });
        await getFinalTermLoanAmount({ recordId: this.recordId }) 
          .then(result => { 
            console.log('Result', result);this.oppLoanAmount = result[0].Loan_Amount__c;  
            this.loanAmount = result[0].Loan_Amount__c;//CISP-19428
            this.emi = result[0].EMI_Amount__c;//CISP-19428
            this.finalTermId = result[0].Id;//CISP-19428
            if (this.activeTab == 'Borrower') {
                this.fundedPremiumValue =result[0].Loan_Application__r.Total_Funded_Premium__c;//CISP-19428
            }
          })
          .catch(error => {
            console.error('Error:', error);
        }); 
        await this.fetchSubStage();
        //await this.onloadexistInsuranceDetails();
        this.isConsentButtonDisabled = true;
        //this.isSubmitButtonDisabled = true;
        this.showSubmitButton = true;
        this.popupCheckboxChecked = true;
        
        if(this.checkleadaccess){//if lead is accessible but user from different profile is viewing that
            const evt = new ShowToastEvent({
                title: ReadOnlyLeadAccess,
                variant: 'warning',
                mode: 'sticky'
            });
            this.dispatchEvent(evt);
            console.log('from tab loan');
            this.disableEverything();
        }
        if(this.isRevokedLoanApplication){this.disableEverything();}//CISP-2735
        /*CISP-7000 Start */
        if(this.leadSource === 'D2C' && this.productType === 'Two Wheeler'){
            this.isSubmitButtonDisabled = true;
        }
        /*CISP-7000 End */
    }
    disableEverything(){
        let allElements = this.template.querySelectorAll('*');
        allElements.forEach(element =>
        element.disabled = true
        );

    }

    async getIns_ProdutcsMthod() {
        console.log('INS_PROTUTS 391=>...' + JSON.stringify(this.insuranceDetailsApi));
        // const arr = [HEALTH, GPA, COMBO, MOTOR, 'LI_EMI', 'FLEXI', 'TATA_EMI'];        
        let motorIns = {};
        let addInsuranceDetailsList = [];
        if(this.activeTab === this.label.Borrower){
            await getMotorInsuranceFromLoanDetails({
                loanAppID: this.recordId
            }).then(result => {
                if (result != null) {
                    motorIns = {
                        insProductName : result.Ins_Product,
                        isPlanChecked : false,
                        isPlanCheckDisabled : false,
                        insPlanCode : result.Plan_Code,
                        insPlanOptions: [{
                            label: result.Plan_Name,
                            value: result.Plan_Code,
                            insAmount : result.Premium
                        }],
                        isPlanCodeDisabled : true,
                        insAmount : result.Premium,
                        isAmountFieldDisabled : true,
                        isFundedChecked : result.Funding_Option == 'Y' ? true : false,
                        isFundedDisabled : true
                    };
                }
            }).catch(error => {
                console.log('MOTOR LOAN DETAILS BUG...' + error);
            });
        }       
        this.insuranceDetailsApi.forEach(getObj => {
            if (getObj.Ins_Product !== MOTOR) {
                if(addInsuranceDetailsList.length > 0 && addInsuranceDetailsList.find(opt => opt.insProductName === getObj.Ins_Product)){
                    let tempinsuranceDetailsList = addInsuranceDetailsList;
                    addInsuranceDetailsList = [];
                    tempinsuranceDetailsList.forEach(element => {
                        if(element.insProductName === getObj.Ins_Product){
                            element.insPlanOptions.push({
                                label: getObj.Plan_Name,
                                value: getObj.Plan_Code,
                                insAmount : getObj.Premium
                            });
                        }
                        addInsuranceDetailsList.push(element);
                    });
                }else {
                    addInsuranceDetailsList.push({
                        insProductName : getObj.Ins_Product,
                        isPlanChecked : false,
                        isPlanCheckDisabled : (this.activeTab == this.label.CoBorrower && !PlanforCoborrower.includes(getObj.Ins_Product)) || ((getObj.Ins_Product == 'LI_EMI' || getObj.Ins_Product == 'TATA_EMI') && this.isOfferEngineApiFailed) || ((this.applicantAge && (this.applicantAge<18 || this.applicantAge>65)) && getObj.Ins_Product == 'TATA_EMI') || ((this.applicantAge &&(this.applicantAge<18 || this.applicantAge>60)) && getObj.Ins_Product == 'LI_EMI') || ((this.applicantAge && (this.applicantAge<18 || this.applicantAge>55)) && getObj.Ins_Product == 'FLEXI') ? true : false,
                        insPlanCode : fixedInsPlan.includes(getObj.Ins_Product) ? getObj.Plan_Code : '',
                        insPlanOptions: [{
                            label: getObj.Plan_Name,
                            value: getObj.Plan_Code,
                            insAmount : getObj.Premium
                        }],
                        isPlanCodeDisabled : true,
                        insAmount : 0,
                        isAmountFieldDisabled : true,
                        isFundedChecked : false,
                        isFundedDisabled : true
                    });
                }
            }
        });
        if(this.existingInsDetailList.length > 0){
            this.iconButton = true;
            let tempinsuranceDetailsList = addInsuranceDetailsList;
            addInsuranceDetailsList = [];
            tempinsuranceDetailsList.forEach(element => {
                this.existingInsDetailList.forEach(ele => {
                    if(element.insProductName === ele.insProductName){
                        element.isPlanChecked = true;
                        element.isPlanCheckDisabled = false;
                        element.insPlanCode = ele.insPlanCode;
                        element.isPlanCodeDisabled = fixedInsPlan.includes(element.insProductName) ? true : false; 
                        element.insAmount = ele.insAmount;
                        element.isFundedChecked = ele.isFundedChecked;
                        element.isFundedDisabled = this.activeTab == this.label.CoBorrower ? true : false;
                    }
                });
                addInsuranceDetailsList.push(element);
            });
            if (this.activeTab === this.label.Borrower && this.existingInsDetailList.length > 0 && this.existingInsDetailList.find(opt => opt.insProductName === MOTOR)) {
                this.existingInsDetailList.forEach(getObj => {
                    if (getObj.insProductName === MOTOR && !addInsuranceDetailsList.find(opt => opt.insProductName === MOTOR)) {
                        getObj.isPlanCheckDisabled = false;
                        getObj.isFundedDisabled = false;
                        if(this.leadSource === 'D2C' && this.expiringWithin60Days == true){//CFDI-1164
                            getObj.isPlanCheckDisabled = true;
                            getObj.isFundedDisabled = true;
                        }
                        addInsuranceDetailsList.push(getObj);
                    }
                });
            }
        }
        if(this.activeTab === this.label.Borrower && addInsuranceDetailsList.length > 0 && !addInsuranceDetailsList.find(opt => opt.insProductName === MOTOR)){
            if(JSON.stringify(motorIns) !== '{}'){
                addInsuranceDetailsList.push(motorIns);
            }
        }
        this.insuranceDetailsList = addInsuranceDetailsList;
        console.log('this.insuranceDetailsList', this.insuranceDetailsList);
        this.isSpinnerMoving = false;
    }

    async init(responseReApi) {
        try {
            const currentApplicantId = await getApplicantId({
                opportunityId: this.recordId,
                applicantType: this.activeTab,
            })
            this.applicantId = currentApplicantId;

            /*If response from API1 is not received even after configured number of tries then system should
             fetch insurance products and plans from the insurance master. */
            if (this.responseReApisatus == 'Success') {

                //call the API – API1(Insurance Recommendation API). and success response assign data to the "insuranceDetailsApi" variable.
                this.insuranceDetailsApi = JSON.parse(responseReApi).Ins_Product;
            } else {
                // if there is no response from the API1(Insurance Recommendation API), 
                //fetching from master and Assign Data to the "insuranceDetailsApi" variable
                this.insuranceDetailsApi = responseReApi;
                console.log('Master.......' + responseReApi);
            }
            this.getIns_ProdutcsMthod();

        } catch (error) {
            console.log("Error in loadInsuranceDetails => ", error);
        }
    }

    //methos for handling plan when user changes the plan.
    handlePlanChange(event) {
        /*CISP-7000 Start */
        if(this.leadSource === 'D2C' && this.productType === 'Two Wheeler'){
            this.isSubmitButtonDisabled = true;
            this.planChangedD2Ctw = true;
        }
        /*CISP-7000 End */
        let selectedInsPlan = event.target.name;
        let insPlanvalue = event.target.value;
        let tempinsuranceDetailsList = this.insuranceDetailsList;
        this.isInsuranceSeletedInLOne = false; 
        this.insuranceDetailsList = [];
        for (let i = 0; i < tempinsuranceDetailsList.length; i++) {
            const element = tempinsuranceDetailsList[i];
            if (element.insProductName === selectedInsPlan) {
                element.insPlanCode = insPlanvalue;
                element.insAmount = element.insPlanOptions.find(opt => opt.value === insPlanvalue).insAmount;
            }
            this.insuranceDetailsList.push(element);
        }
        this.isConsentButtonDisabled = true;
        this.iconButton = false;
        this.isComputePremiumAPIRun = false;
        this.isPlanChangedObj.isPlanChange = true;
        this.consentFlagRequiredMethod();
        this.calculateFundedPremium();//CISP-19428
    }

    //CISP-19428
    calculateFundedPremium(){
        try {
            let latestFundedPremium = 0;
            let fundedAmountChanged = false;
            if (this.insuranceDetailsList.length > 0) {
                this.insuranceDetailsList.forEach(element => {
                    if(element.isPlanChecked && element.isFundedChecked && element.insAmount){
                        latestFundedPremium =  parseFloat(latestFundedPremium) + parseFloat(element.insAmount);
                        fundedAmountChanged = true;
                    }
                });
                if(fundedAmountChanged && parseFloat(latestFundedPremium) != parseFloat(this.fundedPremiumValue)){
                    this.isFundedchanged = true;
                    this.isloanAmountAndFundedChanged =true;
                    this.fundedPremiumValue = latestFundedPremium;
                }
                if (this.insuranceDetailsList.find(opt => opt.isPlanChecked === true) && !this.insuranceDetailsList.find(opt => opt.isFundedChecked === true)) {
                    this.isFundedchanged = true;
                    this.isloanAmountAndFundedChanged =true;
                    this.fundedPremiumValue = 0;
                }
                if (!this.insuranceDetailsList.find(opt => opt.isPlanChecked === true)) {
                    this.isFundedchanged = true;
                    this.isloanAmountAndFundedChanged =true;
                    this.fundedPremiumValue = 0;
                }
            }  
        } catch (error) {
            console.log(error);
        }
        
    }
 

    //Handler for amount input field change.
    hanldeAmountValueChange(event) {
        this.iconButton = false;
        this.popupCheckbox = false;
        this.showPopupForAmount = true;
        this.popupCheckboxChecked = true;
        this.isInsuranceSeletedInLOne = false;
        this.isPlanChangedObj.isAmountChange = true;
        let selectedPlanName = event.target.name;
        let enteredAmount = event.target.value;
        this.insuranceDetailsList.find(opt => opt.insProductName === selectedPlanName).insAmount = enteredAmount;
        this.consentFlagRequiredMethod();
    }

    //Handler for is funded toggle change.
    handleIsFundedToggle(event) {
        /*CISP-7000 Start */
        if(this.leadSource === 'D2C' && this.productType === 'Two Wheeler'){
            this.isSubmitButtonDisabled = true;
            this.planChangedD2Ctw = true;
        }
        /*CISP-7000 End */
        this.isComputePremiumAPIRun = false;
        this.isFundedchanged = true;//cisp-19428
        this.iconButton = false;
        this.isInsuranceSeletedInLOne = false;
        let selectedPlanName = event.target.name;
        let insFundedChecked = event.target.checked;
        this.isPlanChangedObj.isFundToggel = insFundedChecked;
        this.insuranceDetailsList.find(opt => opt.insProductName === selectedPlanName).isFundedChecked = insFundedChecked;
        this.consentFlagRequiredMethod();
        this.calculateFundedPremium();//CISP-19428
    }


    //Handler for amount value change popup
    hanldeAmountPopupCheckbox(event) {
        this.popupCheckbox = event.target.checked;
        if (this.popupCheckbox) {
            this.popupCheckboxChecked = false;
        } else {
            this.popupCheckboxChecked = true;
        }
    }

    //Handler for submit button of amount change popup.
    handlePopupSubmit() {
        this.showPopupForAmount = false;
    }

    //Handler for Funding Check Availability.
    async handleFundingAvailability() {
        let selectedInsPlanNameList =[];
        if (this.insuranceDetailsList.length > 0) {
            this.insuranceDetailsList.forEach(element => {
                if(element.isPlanChecked){
                    selectedInsPlanNameList.push(element.insProductName);
                }
            });
        }
        if (this.insuranceDetailsList.length > 0 && !this.insuranceDetailsList.find(opt => opt.isPlanChecked === true)) {
            this.isConsentButtonDisabled = true;
            if(this.leadSource === 'D2C'){
                this.fundingAvailabilityClicked = true;
            }
            const event = new ShowToastEvent({
                title: 'Info',
                message: NOT_OPTED_INSURANCE_MSG_LABEL,
                variant: 'info',
            });
            this.dispatchEvent(event);
            return;
        }
        else if (this.isPassengerVehicles && selectedInsPlanNameList.length > 0 && selectedInsPlanNameList.includes('LI_EMI') && selectedInsPlanNameList.includes('TATA_EMI')) {
            this.isConsentButtonDisabled = true;
            const event = new ShowToastEvent({
                title: 'Error',
                message: 'Please select either TATA EMI or LI EMI',
                variant: 'error',
            });
            this.dispatchEvent(event);
            return;
        }else if(this.isPassengerVehicles && this.leadSource != 'D2C' && this.insuranceDetailsList.length > 0 && selectedInsPlanNameList.length > 0 && selectedInsPlanNameList.includes('LI_EMI') && (!this.applicantHeight || !this.applicantWeight)){
            const event = new ShowToastEvent({
                title: 'Error',
                message:'You have choose LI_EMI so please enter height and weight',
                variant: 'error',
            });
            this.dispatchEvent(event);
            return;            
        }else if(this.isPassengerVehicles && this.leadSource != 'D2C' && this.insuranceDetailsList.length > 0 && selectedInsPlanNameList.length > 0 && selectedInsPlanNameList.includes('LI_EMI') && (this.applicantHeight && this.applicantWeight) && this.bmiValue && (this.bmiValue <18 || this.bmiValue >30)){
            const event = new ShowToastEvent({
                title: 'Error',
                message: 'User is not eligible for COMBO(LI_EMI) product. Please choose any other product',
                variant: 'error',
            });
            this.dispatchEvent(event);
            return;            
        }
        else if (!this.isPassengerVehicles && this.insuranceDetailsList.length > 0 && selectedInsPlanNameList.length > 0 && selectedInsPlanNameList.includes(COMBO) && (selectedInsPlanNameList.includes(GPA) || (selectedInsPlanNameList.includes('LI') || selectedInsPlanNameList.includes('HEALTH')))) {
            this.isConsentButtonDisabled = true;
            const event = new ShowToastEvent({
                title: 'Error',
                message: COMBO_GPA_OR_HEALTH_LABEL,
                variant: 'error',
            });
            this.dispatchEvent(event);
            return;
        }
        else if(!this.isPlanChangedObj.isComputePremiumClicked && !this.isPlanChangedObj.isPlanChange && !this.isPlanChangedObj.isFundToggel && !this.isPlanChangedObj.isPLanCheckChange && !this.isPlanChangedObj.isAmountChange){
            this.isConsentButtonDisabled = true;
            const event = new ShowToastEvent({
                title: 'Error',
                message: 'Please Compute Premium first!',
                variant: 'error',
            });
            this.dispatchEvent(event);
            return;
        }
        else if(this.isPassengerVehiclesAndBlankLeadSource && (!this.isRerunOfferAPIRun || this.isFundedchanged || (this.loanAmountPlusFundedPremium && this.previousLoanAmount && (parseFloat(this.loanAmountPlusFundedPremium) > parseFloat(this.previousLoanAmount))))){
            this.showToastMessage('Error','Please Rerun Offer Engine first','error');
            return;
        } //CISP-19428
        else if(!this.isComputePremiumAPIRun){
            this.isConsentButtonDisabled = true;
            const event = new ShowToastEvent({
                title: 'Error',
                message: 'You have changed something. Please Compute Premium first!',
                variant: 'error',
            });
            this.dispatchEvent(event);
            return;
        }
        else if(this.offerEngineEMIChanged){
            this.isConsentButtonDisabled = true;
            const event = new ShowToastEvent({
                title: 'Error',
                message: 'Offer Engine EMI changed. Please Compute Premium first!',
                variant: 'error',
            });
            this.dispatchEvent(event);
            return;
        } else {
            const selectedInsuranceDetails = {
                loanApplicationId: this.recordId,
                insProductDetails : []
            };
            for (let i = 0; i < this.insuranceDetailsList.length; i++) {
                const element = this.insuranceDetailsList[i];
                if (element.isPlanChecked) {
                    const selectedPlanObj = {
                        selectedProduct: element.insProductName,
                        selectedPlan: element.insPlanCode,
                        isFunded: element.isFundedChecked,
                        premium : element.insAmount,
                        comboLIPremium : element.insProductName ==='LI_EMI' ? parseFloat(this.comboLIPremium) : 0,
                        comboEMIPremium : element.insProductName ==='LI_EMI' ? parseFloat(this.comboEMIPremium) : 0,
                        eMIPassedinAPI : element.insProductName ==='LI_EMI' || element.insProductName ==='TATA_EMI' ? parseFloat(this.eMIPassedinAPI) : 0,
                    };
                    selectedInsuranceDetails.insProductDetails.push(selectedPlanObj);
                }
            }
            console.log(selectedInsuranceDetails);

            this.fundedPremiumValue = null;
            this.totalInsurancePayable = null;
            this.ltvWithInsurance = null;
            this.ltvWithoutInsurance = null;
            this.proposalLtv = null;

            await getFundingAvailibility({
                payload: JSON.stringify(selectedInsuranceDetails)
            })
                .then(result => {
                    if(this.leadSource === 'D2C'){
                        this.fundingAvailabilityClicked = true;
                    }
                    const response = JSON.parse(result);
                    //   console.log('get Funding Response=>...' + JSON.stringify(response));
                    if (response.responseStatus) {
                        //   console.log('funding response => ', response);
                        this.fundedPremiumValue = response.totalPremiumFunded;
                        this.totalInsurancePayable = response.totalInsurancePayable;
                        this.ltvWithInsurance = response.ltvWithInsurance;
                        this.ltvWithoutInsurance = response.ltvWithoutInsurance;
                        this.proposalLtv = response.proposalLtv;
                        //Enabling the submit button.
                        this.isPlanChangedObj.isAvailabilityButtonClicked = true;
                        this.isSubmitButtonDisabled = false;
                        this.isConsentButtonDisabled = false;
                        /* CISP-7000 */
                        if(this.leadSource === 'D2C' && this.productType === 'Two Wheeler'){
                            console.log('this.planChangedD2Ctw? '+this.planChangedD2Ctw)
                            if(!this.planChangedD2Ctw){
                                console.log('IF 1')
                                this.isConsentButtonDisabled = true;
                                this.isSubmitButtonDisabled = false;
                            }else{
                                console.log('IF 2')
                                this.isConsentButtonDisabled = false;
                                this.isSubmitButtonDisabled = true;
                            }
                        }
                        /* CISP-7000 */
                    } else if (!response.responseStatus) {
                        this.showPopup = true;
                        this.fundedPremiumValue = response.totalPremiumFunded;
                        this.isConsentButtonDisabled = true;
                    } else {
                        this.showPopup = false;
                        this.fundedPremiumValue = response.totalPremiumFunded;
                        this.isSubmitButtonDisabled = false;
                        this.isConsentButtonDisabled = false;
                    }
                })
                .catch(error => {
                    this.error = error;
                    console.log('error in funding availability==>', this.error);
                    const event = new ShowToastEvent({
                        title: 'Error',
                        message: error.body.message,
                        variant: 'error',
                    });
                    this.dispatchEvent(event);
                });
        }
    }

    //To show the percentage with ltv with insurance field 
    get ltvWithInsurancePercentage() {
        if (this.ltvWithInsurance) {
            return this.ltvWithInsurance + '%';
        }
    }

    //To show the percentage with ltv without insurance field 
    get ltvWithoutInsurancePercentage() {
        if (this.ltvWithoutInsurance) {
            return this.ltvWithoutInsurance + '%'
        }
    }

    //Handler for closing the popup.
    handleClosePopup() {
        this.showPopup = false;
    }

    consentFlagRequiredMethod(){
        this.consentRequired = true;
    }

    //SMS callout method- this method will make a call to Integration class. 
    //Update the SMS consent fields in Applicant 
    async sendInsuranceConsentcall(appid, InsData, flag) {
        console.log('type of message' + flag + '  Applicant record Id :' + appid);

        let otpValue;
        //Updating the applicant record with consent fields
        const tDatetime = new Date().toISOString();
        const fields = {};
        fields[APPLICANT_ID.fieldApiName] = appid;

        if (flag == 'INC') {
            let insRandNum = Math.floor(Math.random() * 10000);
            otpValue = insRandNum;
            fields[INSURANCE_CONSENT_SENT.fieldApiName] = tDatetime;
            fields[APPLICANT_InsuranceConsentOTP.fieldApiName] = String(insRandNum);
        }

        const recordInput = { fields };
        await updateRecord(recordInput)
            .then(() => {
                console.log('Applicant record updated', recordInput);
                let smsRequestString = {
                    'applicantId': appid,
                    'loanApplicationId': this.recordId,
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
                            //this.issmscalloutsborrower = ++getsms;    
                            var getsmsco = parseInt(this.issmscalloutscoborrower);
                            // this.issmscalloutscoborrower = ++getsmsco;
                            const event = new ShowToastEvent({
                                title: 'Success',
                                message: this.label.Consent_Sent_Successfully,
                                variant: 'success',
                            });
                            this.dispatchEvent(event);
                            /*CISP-7000 Start */
                            if(this.leadSource === 'D2C' && this.productType === 'Two Wheeler'){
                                this.isSubmitButtonDisabled = false;
                            }
                            /*CISP-7000 End */
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

    //for sensing insurance consent on click of consent button
    async handleInsuranceConsent() {
        let selectedInsPlanNameList =[];
        if (this.insuranceDetailsList.length > 0) {
            this.insuranceDetailsList.forEach(element => {
                if(element.isPlanChecked){
                    selectedInsPlanNameList.push(element.insProductName);
                }
            });
        }
        if(this.isPassengerVehicles && this.leadSource != 'D2C' && this.insuranceDetailsList.length > 0 && selectedInsPlanNameList.length > 0 && selectedInsPlanNameList.includes('LI_EMI') && (!this.applicantHeight || !this.applicantWeight)){
            const event = new ShowToastEvent({
                title: 'Error',
                message:'You have choose LI_EMI so please enter height and weight',
                variant: 'error',
            });
            this.dispatchEvent(event);
            return;
        }else if(this.isPassengerVehicles && this.leadSource != 'D2C' && this.insuranceDetailsList.length > 0 && selectedInsPlanNameList.length > 0 && selectedInsPlanNameList.includes('LI_EMI') && (this.applicantHeight && this.applicantWeight) && this.bmiValue && (this.bmiValue <18 || this.bmiValue >30)){
            const event = new ShowToastEvent({
                title: 'Error',
                message: 'User is not eligible for COMBO(LI_EMI) product. Please choose any other product',
                variant: 'error',
            });
            this.dispatchEvent(event);
            return;
        }else{
            this.SpinnerMoving = true;
            var getFinalInsData = [];
            var index = 0;
            for (let i = 0; i < this.insuranceDetailsList.length; i++) {
                const element = this.insuranceDetailsList[i];
                if (element.isPlanChecked) {
                    const selectedInsPlan ={
                        rowNo: ++index,
                        Name: element.insProductName,
                        Amount: element.insAmount
                    }
                    getFinalInsData.push(selectedInsPlan);
                }
            }
    
            if (this.activeTab == this.label.Borrower) {
                this.iconButton = false;
                this.isConsentButtonDisabled = false;
            } else {
                this.isConsentButtonDisabled = false;
                this.issmscallouts = 1;
            }
            console.log('calling sendInsuranceConsent 1198 ');
            await sendInsuranceConsent({
                loanapplicationId: this.recordId,
                appType: this.activeTab
            }).then(result => {
                this.iconButton = true;
                this.consentRequired = false;
                this.isConsentButtonDisabled = true;
                console.log("this.issmscalloutscoborrower ", this.issmscalloutscoborrower);
                console.log("this.issmscalloutsborrower ", this.issmscalloutsborrower);
                if ((this.activeTab == this.label.Borrower && parseInt(this.issmscalloutsborrower) == 2) ||
                    (parseInt(this.issmscalloutscoborrower) == 2 && this.activeTab == this.label.CoBorrower)) {
                    const event = new ShowToastEvent({
                        title: 'Error',
                        message: this.label.Consent_Already_Received,
                        variant: 'error',
                    });
                    this.dispatchEvent(event);
                } else {
                    if (result) {
                        console.log(' 1219 --->', result);
                        this.sendInsuranceConsentcall(result, JSON.stringify(getFinalInsData), 'INC');
                    }
                }
            }).catch(error => {
                this.SpinnerMoving = false;
                this.error = error;
            });
            this.handleConcentCall();
        }
    }


    callLoanApplicationHistory(nextStage) {
        getLoanApplicationHistory({ loanId: this.recordId, stage: 'Insurance Details', nextStage: nextStage }).then(response => {
            console.log('getLoanApplicationHistory Response:: ', response);
            if (response) {
                this.navigateToHomePage();
            } else {
                this.dispatchEvent(new CustomEvent('submitnavigation', { detail: nextStage }));
            }
        }).catch(error => {
            console.log('Error in getLoanApplicationHistory:: ', error);
        });
    }
    
    async callAPImethodsOnSubmit(){
        
        await getFinalTermData({ loanApplicationId: this.recordId,randomvar: '' })//Start CISP-2408
        .then((data) => {
            if (data) {
                let parsedData = JSON.parse(data);
                this.finalTermId = parsedData.getrecordId ? parsedData.getrecordId : '';
                this.emi = parsedData.emi ? parsedData.emi : '';
                if (this.finalTermId && this.emi){
                    let offerEngineRequestString = {
                        'loanApplicationId': this.recordId,
                        'currentScreen': 'Final Offer',
                        'loanAmountChanged':  this.activeTab === this.label.Borrower ? (parseFloat(this.loanAmount) + parseFloat(this.fundedPremiumValue)).toString() : null,
                        'offerEMI': this.emi?this.emi.toString():'', // CISP-2408
                    };
                    console.log('response  ', JSON.stringify(offerEngineRequestString));

                    //START D2C Changes Raman
                    let offerEngineMethod = doOfferEngineCallout;
                    let offerEngineParams = { offerEngineRequestString: JSON.stringify(offerEngineRequestString) };
                    if(this.leadSource === 'D2C' || this.leadSource === 'Hero'){//CISH-04
                        offerEngineMethod = doD2COfferEngineCallout;
                        offerEngineParams = {loanId: this.recordId, applicantId: null, fromScreen:'insurance'};
                    }
                    //END D2C Changes Raman
                    if(this.leadSource!='OLA'){
                        offerEngineMethod(offerEngineParams)
                        .then(result => {
                            const obj = (this.leadSource === 'D2C' || this.leadSource === 'Hero') ? this.getParsedJSOND2C(JSON.parse(result)) : JSON.parse(result);
                            console.log('Final Term', this.finalTermId);
                            console.log('doOfferEngineCallout data ', obj);
                            if (obj != null && obj.status != 'FAILED') {
                                const FinalTermFields = {};
                                FinalTermFields[final_ID_FIELD.fieldApiName] = this.finalTermId;
                                FinalTermFields[EMI_Amount.fieldApiName] = obj.EMI;
                                if (obj.CRM_IRR != null) {
                                    FinalTermFields[CRM_IRR.fieldApiName] = obj.CRM_IRR;
                                }
                                if(this.leadSource != 'Hero'){
                                if(!this.leadSource || this.leadSource !== 'D2C' || this.leadSource !== 'Hero'){  
                                    //CISP-2533
                                    if(obj.Imputed_IRR_Offered != null) { 
                                        FinalTermFields[Inputted_IRR.fieldApiName] = parseFloat(obj.Imputed_IRR_Offered);
                                    }
                                    // CISP-2533
                                    FinalTermFields[Gross_IRR.fieldApiName] = obj.Gross_IRR_Offered;
                                    FinalTermFields[Net_IRR.fieldApiName] = obj.Net_IRR_Offered;
                                    FinalTermFields[Net_IRR_DECIMAL.fieldApiName] = obj.Net_IRR_Offered;
                                }
                            }
                                if(this.leadSource != 'Hero'){
                                    if(obj.TableCode){FinalTermFields[Table_Code.fieldApiName] = obj.TableCode;}
                                    if(obj.Interest_VersionNo){FinalTermFields[Interest_Version_No.fieldApiName] = obj.Interest_VersionNo;}
                                    if(obj.DR_PenalInterest){FinalTermFields[DR_Penal_Interest.fieldApiName] = obj.DR_PenalInterest;}
                                    if(obj.mclrRate){FinalTermFields[mclrRate.fieldApiName] = obj.mclrRate;} 
                            }
                                FinalTermFields[isNavigate.fieldApiName] = false;
                                this.updateRecordDetail(FinalTermFields);
                                this.offerEngineFlag = true;   
                                this.navigateToNextStageHandler();         
                            }else{ 
                                const evt = new ShowToastEvent({
                                    title: 'Error',
                                    message: "Offer Engine API Failed",
                                    variant: 'error',
                                });
                                this.dispatchEvent(evt); 
                                this.isSecondSpinnerMoving=false; 
                                this.isSubmitButtonDisabled = false; 
                            }
                        })
                        .catch(error => {
                            this.SpinnerMoving = false;
                            console.log('Error in Offer Engine API.', error);
                            const evt = new ShowToastEvent({
                                title: 'Error',
                                message: "Offer Engine API Failed",
                                variant: 'error',
                            });
                            this.dispatchEvent(evt);
                            this.isSecondSpinnerMoving=false; 
                            this.isSubmitButtonDisabled = false; 
                        });
                    } else {
                        this.offerEngineFlag=true 
                        this.navigateToNextStageHandler(); 
                    }//OLA-99
                }

            }
        })
        .catch(error => {
            console.log('error in getFinalTermData => ', error);
        });//End CISP-2408
    }
    navigateToNextStageHandler(){
        if(this.offerEngineFlag){
            const oppFields = {};
            oppFields[OPP_ID_FIELD.fieldApiName] = this.recordId;
            if (this.activeTab =='Borrower') {
                oppFields[Submitted_Tabs.fieldApiName] = this.submittedTabs!= null ? this.submittedTabs +';L2 - Borrower Insurance' : 'L2 - Borrower Insurance';
            } else if (this.activeTab =='Co-borrower') {
                oppFields[Submitted_Tabs.fieldApiName] =  this.submittedTabs!= null ? this.submittedTabs + ';L2 - Coborrower Insurance' : 'L2 - Coborrower Insurance';
            }
            if (this.isPassengerVehicles) {                
                oppFields[Insurance_business_done_by.fieldApiName] = this.userEmployeeNumber;
            }
            this.updateRecordDetails(oppFields);
            this.SpinnerMoving = false;
            let allElements = this.template.querySelectorAll('*');
            allElements.forEach(element =>
                element.disabled = true
            );
            this.isSecondSpinnerMoving=false;
            this.isSubmitButtonDisabled = true;
            this.dispatchEvent(new CustomEvent('insurance', { detail: 'Insurance' }));
        }else{
            this.SpinnerMoving = false;
            this.isSecondSpinnerMoving=false;
            this.isSubmitButtonDisabled = false;
        }
    } 
    //method for submitting the selected insurance product and plan.
    async handleSubmit() {
        if (this.isPassengerVehiclesAndBlankLeadSource) {
            if (!this.isRerunOfferAPIRun || this.isFundedchanged ) {
                this.showToastMessage("Rerun offer engine is Required!", "Please click on Rerun Offer Engine button First.","Error");
                return;
            } else if ( this.insuranceDetailsList.length > 0 && this.insuranceDetailsList.find(opt => opt.isPlanChecked === true) && !this.isComputePremiumAPIRun) {
                this.isConsentButtonDisabled = true;
                this.showToastMessage("Error", "You have changed something. Please click on Rerun Offer Engine first!","Error");
                return;
            } else if ( this.insuranceDetailsList.length > 0 && this.insuranceDetailsList.find(opt => opt.isPlanChecked === true) && !this.isPlanChangedObj.isAvailabilityButtonClicked) {
                this.showToastMessage("Error", "Please click on Funding Availability button First.","Error");
                return;
            }//CISP-19428
        }
        
        this.isSecondSpinnerMoving=true;
        this.isSubmitButtonDisabled = true; 
        if(this.leadSource === 'D2C' && !this.fundingAvailabilityClicked){

            let evt = new ShowToastEvent({
                title: "Funding Availability is Required",
                message: "Please click on Funding Availability first.",
                variant: 'Error',
            });
            this.dispatchEvent(evt);
            this.isSecondSpinnerMoving=false;
            this.isSubmitButtonDisabled = false;
            return;
        }
        let isvalidForSubmit = true;//CISP-3938
        await getDocumentsToCheckPan({ loanApplicationId: this.recordId })
          .then(result => {
            console.log('Result', result);
            let data = JSON.parse(result);
            let totalamount = 0;
            totalamount = parseInt(this.oppLoanAmount) + parseInt(this.fundedPremiumValue) + parseInt(this.existingBorrowerExposureAmount) + parseInt(this.existingCoBorrowerExposureAmount) + parseInt(this.existingOtherExposureAmount) + parseInt(this.bankExposureAmount); 
            console.log('OUTPUT totalamount: ',totalamount); 
            if(this.activeTab =='Borrower'){
                if(parseInt(totalamount) >= 1000000 && data?.borrowerPanAvailable == false && this.leadSource != 'D2C'){ 
                    const evt = new ShowToastEvent({title: "Error",message: 'Exposure  (Incl.  loan  amount)  is  >=  INR  10  Lakhs,  hence,  PAN  is mandatory.  Please  withdraw  this  lead  and  create  a  new  lead  with  PAN  or  change  the  Loan  amount  by revoking the application',variant: 'Error',});this.dispatchEvent(evt);isvalidForSubmit = false; 
                }
            }
            if(this.activeTab =='Co-borrower'){
                if(parseInt(totalamount) >= 1000000 && data?.coborrowerPanAvailable == false && this.leadSource != 'D2C'){ 
                    const evt = new ShowToastEvent({title: "Error",message: 'Exposure  (Incl.  loan  amount)  is  >=  INR  10  Lakhs,  hence,  PAN  is mandatory.  Please  withdraw  this  lead  and  create  a  new  lead  with  PAN  or  change  the  Loan  amount  by revoking the application',variant: 'Error',});this.dispatchEvent(evt);isvalidForSubmit = false; 
                }
            }
          })
          .catch(error => {
            console.error('Error:', error);
        });
        if(isvalidForSubmit){
        await fetchOppourtunityData({ loanApplicantionId: this.recordId }).then(result => {this.submittedTabs = result[0].Submitted_Tabs__c; console.log('result', result); });
        if(this.isPassengerVehicles && this.isInsuranceSeletedInLOne && this.insuranceDetailsList.length > 0 && !this.isPlanChangedObj.isconsentButtonClicked && !this.isPlanChangedObj.isAvailabilityButtonClicked){
            this.isSecondSpinnerMoving=false;
            this.isSubmitButtonDisabled = false;
            const evt = new ShowToastEvent({
                title: "Error",
                message: 'Click Compute Premium button and Funding Availability button first',
                variant: 'Error',
            });
            this.dispatchEvent(evt);
            return; 
        }else if(this.isPassengerVehicles && this.isInsuranceSeletedInLOne && this.insuranceDetailsList.length > 0 && !this.isPlanChangedObj.isconsentButtonClicked && this.isPlanChangedObj.isAvailabilityButtonClicked){
            this.isSecondSpinnerMoving=false;
            this.isSubmitButtonDisabled = false;
            let evt = new ShowToastEvent({
                title: "Consent Required",
                message: this.label.Give_Consent_First,
                variant: 'Error',
            });
            this.dispatchEvent(evt);
            return;
        }else if (this.insuranceDetailsList.length > 0 && !this.insuranceDetailsList.find(opt => opt.isPlanChecked === true) && (this.activeTab =='Co-borrower' && (this.submittedTabs == null || (this.submittedTabs!= null && !this.submittedTabs.includes('L2 - Borrower Insurance'))))) {
            console.log('From 111',this.submittedTabs);
            const evt = new ShowToastEvent({
                title: "Error",
                message: 'Borrower Insurance Details are not submitted!!!',
                variant: 'Error',
            });
            this.dispatchEvent(evt);
            this.isSecondSpinnerMoving=false;
            this.isSubmitButtonDisabled = false;
            return;
        }
        else if (this.insuranceDetailsList.length > 0 && !this.insuranceDetailsList.find(opt => opt.isPlanChecked === true)  && ((this.activeTab =='Borrower') || (this.activeTab =='Co-borrower' && this.submittedTabs!= null && this.submittedTabs.includes('L2 - Borrower Insurance')))) {
           // this.SpinnerMoving = true;
            deleteExistingPlans({applicantId : this.applicantId ,loanApplicationId:this.recordId })
            .then(result=>{
                console.log('result of deleteExistingPlans =>', result);
                const event = new ShowToastEvent({
                    message: NOT_OPTED_INSURANCE_MSG_LABEL,
                    variant: 'info',
                });
                this.dispatchEvent(event);
                this.isSecondSpinnerMoving = true;
                this.navigateFurther();
            }).catch(error => {
                this.isSecondSpinnerMoving=false;
                this.isSubmitButtonDisabled = false;
                console.log('Error in deleteExistingPlans =>',error);
            });
            }
        else if(this.tablength == 2 && this.activeTab =='Co-borrower' && (this.submittedTabs == null || (this.submittedTabs!= null && !this.submittedTabs.includes('L2 - Borrower Insurance')))){
            const evt = new ShowToastEvent({
                title: "Error",
                message: 'Borrower Insurance Details are not submitted!!!',
                variant: 'Error',
            });
            this.dispatchEvent(evt);
            this.isSecondSpinnerMoving=false;
            this.isSubmitButtonDisabled = false;
            return;
        }
        else if (this.consentRequired) {
            if(!this.iconButton){
                let evt = new ShowToastEvent({
                    title: "Consent Required",
                    message: this.label.Give_Consent_First,
                    variant: 'Error',
                });
                this.dispatchEvent(evt);
                this.isSecondSpinnerMoving=false;
                this.isSubmitButtonDisabled = false;
                return;
            }else{
                this.isSecondSpinnerMoving = true;
                this.isSubmitButtonDisabled = true;
                this.navigateFurther();
            }
        }else if(!this.consentRequired) {
            this.isSecondSpinnerMoving = true;
            this.isSubmitButtonDisabled = true;
            this.navigateFurther();

        }
    }
    }

    //D2C Changes Raman
    getParsedJSOND2C(parsedJSON){
        let obj = {};
        obj.EMI = parsedJSON?.application?.offerEngineDetails?.offerEngineDecision?.displayEMI;
        obj.Tenure = parsedJSON?.application?.offerEngineDetails?.offerEngineDecision?.displayTenure;
        obj.Loan_Amt = parsedJSON?.application?.offerEngineDetails?.offerEngineDecision?.displayLoanAmt;
        obj.CRM_IRR = parsedJSON?.application?.offerEngineDetails?.offerEngineDecision?.displayCrmIrr.toString();
        obj.Max_Tenure_Slider = parsedJSON?.application?.offerEngineDetails?.offerEngineDecision?.maxTenureSlider;
        obj.Min_Tenure_Slider = parsedJSON?.application?.offerEngineDetails?.offerEngineDecision?.minTenureSlider;
        obj.Min_Loan_Amt_Slider = parsedJSON?.application?.offerEngineDetails?.offerEngineDecision?.minLoanAmtSlider;
        obj.Max_Loan_Amt_Slider = parsedJSON?.application?.offerEngineDetails?.offerEngineDecision?.maxLoanAmtSlider;
        obj.Imputed_IRR_Offered = parsedJSON?.application?.offerEngineDetails?.offerEngineDecision?.displayImputedIrr;
        obj.Net_IRR_Offered = parsedJSON?.application?.offerEngineDetails?.offerEngineDecision?.netIrr;
        obj.Gross_IRR_Offered = parsedJSON?.application?.offerEngineDetails?.offerEngineDecision?.grossIrr;
        obj.Stop_Journey_Flag = parsedJSON?.application?.offerEngineDetails?.offerEngineDecision?.stopJourneyFlag;
        obj.Stop_Journey_Flag = obj.Stop_Journey_Flag ? 'True' : 'False';//D2C change - Rahul
        obj.NetPayIns = parsedJSON?.application?.offerEngineDetails?.offerEngineDecision?.netPayIns?.toString();
        obj.NetPayOuts = parsedJSON?.application?.offerEngineDetails?.offerEngineDecision?.netPayOuts.toString();
        obj.TableCode = parsedJSON?.application?.tableCode;
        obj.Interest_VersionNo = parsedJSON?.application?.interestVersionNo;
        obj.DR_PenalInterest = parsedJSON?.application?.drPenalInterest?.toString();
        obj.mclrRate = parsedJSON?.application?.loanDetails?.mclrRate?.toString();
        return obj;
    }

    async navigateFurther(){
        if(this.tablength == 2 && this.activeTab == this.label.Borrower){
            const oppFields = {};
            oppFields[OPP_ID_FIELD.fieldApiName] = this.recordId;
            oppFields[Submitted_Tabs.fieldApiName] = this.submittedTabs!= null ? this.submittedTabs +';L2 - Borrower Insurance' : 'L2 - Borrower Insurance';
            await this.updateRecordDetails(oppFields);
            let allElements = this.template.querySelectorAll('*');
            allElements.forEach(element =>
                element.disabled = true
            );
            this.isSecondSpinnerMoving=false;
            this.isSubmitButtonDisabled = true;

            const evn = new CustomEvent('coborrower');
            this.dispatchEvent(evn);
        }else{
            await this.callAPImethodsOnSubmit();
            
    }
}

    async handleHome() {
        if ((this.insuranceDetailsList.length > 0 && this.insuranceDetailsList.find(opt => opt.isPlanChecked === true)) && !this.isSubmitButtonDisabled) {
            await this.handleConcentCall();
            await this.navigateToHomePage();
        } else {
            this.navigateToHomePage();
        }
    }

    navigateToHomePage() {
        isCommunity()
            .then(response => {
                if (response) {
                    this[NavigationMixin.Navigate]({
                        type: 'standard__namedPage',
                        attributes: {
                            pageName: 'home'
                        },
                    });
                } else {
                    this[NavigationMixin.Navigate]({
                        type: 'standard__navItemPage',
                        attributes: {
                            apiName: 'Home'
                        }
                    });
                }
            })
            .catch(error => {
            });
    }

    handleUploadViewDoc() {
        this.showUpload = true;
        this.showDocView = true;
        this.isVehicleDoc = false;
        this.isAllDocType = true;
        this.uploadViewDocFlag = true;
    }

    changeflagvalue() {
        this.uploadViewDocFlag = false;
    }

    handleActive(event) {
        this.activeTab = event.target.value;
    }

    //sri
    renderedCallback() {
        loadStyle(this, LightningCardCSS);
        if (this.activeTab === this.label.CoBorrower) {
            this.disableMotorInsuranceSection = true;
        }
        if (this.activeTab === this.label.Borrower) {
            this.disableMotorInsuranceSection = false;
        }
        console.log('inside rendercallback ', this.currentStage, ' ', this.subStage);
        if (this.subStage && this.subStage !== 'Insurance') {
            let allElements = this.template.querySelectorAll('*');
            allElements.forEach(element =>
                element.disabled = true
            );
        }
        if (this.editPlanFlag && this.currentStage === this.label.CreditProcessing) {
            this.editPlanFlag = false;
            this.fundisabled = false;
        }
        if(this.isRevokedLoanApplication){this.disableEverything();}//CISP-2735
        if(this.leadSource=='OLA'  &&  this.leadSource != 'Hero'){//CISH-04
            this.template.querySelector('[data-id="idhandleFundingAvailability"]').disabled=true;//OLA-109
            this.template.querySelector('[data-id="idhandleComputePremium"]').disabled=true;//OLA-109
            }   
                 }

    //Sri
    handleOnfinish(event) {
        const evnts = new CustomEvent('customcodevaleve', { detail: event });
        this.dispatchEvent(evnts);
    }

    updateRecordDetail(fields) {
        const recordInput = { fields };
        console.log('before update ', recordInput);
        updateRecord(recordInput)
            .then(() => {
                console.log('inside update');
                //this.navigateToNextStage();
            })
            .catch(error => {
                console.log('record update error', error);
                //this.navigateToNextStage();
            });
    }

    navigateToNextStage() {
        if (this.currentStage === this.label.CreditProcessing && this.subStage === 'Insurance') {
            if(this.tablength == 2 && this.activeTab == this.label.Borrower){
                const evn = new CustomEvent('coborrower');
                this.dispatchEvent(evn);
            }else{
                this.dispatchEvent(new CustomEvent('insurance', { detail: 'Insurance' }));
            }
        }
        else if (this.currentStage === this.label.CreditProcessing) {
            this.dispatchEvent(new CustomEvent('submit'));
        } else {
            if(this.tablength == 2 && this.activeTab == this.label.Borrower){
                const evn = new CustomEvent('coborrower');
                this.dispatchEvent(evn);
            }else{
                this.callLoanApplicationHistory('Final Offer');
            }
        }
    }

    async updateRecordDetails(fields) {
        const recordInput = { fields };
        console.log('before update ', recordInput);
        await updateRecord(recordInput)
            .then(() => {
                console.log('record  is updated successfully');
            })
            .catch(error => {
                console.log('record update error', error);
            });
    }

    async handleConcentCall() {
        if (this.insuranceDetailsList.length > 0 && this.insuranceDetailsList.find(opt => opt.isPlanChecked === true) && this.iconButton) {
            const saveDetails = {
                loanApplicationId: this.recordId,
                nextStage: 'Insurance Details',
                applicantId: this.applicantId,
                ltvWithInsurance: this.ltvWithInsurance,
                ltvWithoutInsurance: this.ltvWithoutInsurance,
                totalInsurancePayable: this.totalInsurancePayable,
                proposalLtv: this.proposalLtv,
                applicantType: this.activeTab,
                premiumFunded: this.fundedPremiumValue,
                insProductDetails : [],
                height: null,
                weight: null,
                bmi: null
            };
            for (let i = 0; i < this.insuranceDetailsList.length; i++) {
                const element = this.insuranceDetailsList[i];
                if (element.isPlanChecked) {
                    const selectedInsPlan ={
                        selectedProduct : element.insProductName,
                        selectedPlan : element.insPlanCode,
                        isFunded : element.isFundedChecked,
                        premium : element.insAmount,
                        comboLIPremium : element.insProductName ==='LI_EMI' ? parseFloat(this.comboLIPremium) : 0,
                        comboEMIPremium : element.insProductName ==='LI_EMI' ? parseFloat(this.comboEMIPremium) : 0,
                        eMIPassedinAPI : element.insProductName ==='LI_EMI' || element.insProductName ==='TATA_EMI' ? parseFloat(this.eMIPassedinAPI) : 0,
                    };
                    saveDetails.insProductDetails.push(selectedInsPlan);
                    if(element.insProductName ==='LI_EMI' && this.applicantHeight && this.applicantWeight && this.bmiValue){
                        saveDetails.height = this.applicantHeight;
                        saveDetails.weight = this.applicantWeight;
                        saveDetails.bmi = this.bmiValue;
                    }
                }
            }
            console.log('saveDetails',saveDetails);

            await getInsuranceConsentCheckboxValue({
                loanapplicationId: this.recordId,
                appType: this.activeTab
            }).then(result => {
                console.log('success 1777' + JSON.stringify(result));
                if (result.Insurance_Consent_Received__c == true) {
                    updateInsuranceConsentReceived({
                        loanapplicationId: this.recordId,
                        appType: this.activeTab,
                        checked: false
                    }).then(result => {
                        console.log('success 1784' + JSON.stringify(result));
                    }).catch(error => {
                        this.error = error;
                        console.log('error 1787' + JSON.stringify(error));
                    });
                }
            }).catch(error => {
                this.SpinnerMoving = false;
                this.error = error;
                console.log('error 1795' + JSON.stringify(error));
            });

            console.log('saving details :: 1772', saveDetails);
            await submitInsuranceDetails({
                payload: JSON.stringify(saveDetails)
            })
                .then(result => {
                    console.log(' Line no 1777 => applicatnt ID', this.applicantId);
                    if (result === this.label.SuccessMessage) {
                        console.log(' Line no 1779 => success');
                        ///this.sendInsuranceConsentcall(this.applicantId, 'JSON.stringify(getFinalInsData)', 'LAS');
                        this.disabledHeightAndWeight = true;
                        this.isPlanChangedObj.isconsentButtonClicked = true;
                        const evt = new ShowToastEvent({
                            title: 'Success',
                            message: this.label.detailsSaved,
                            variant: 'Success',
                        });
                        this.dispatchEvent(evt);
                        this.SpinnerMoving = false;
                    }
                })
                .catch(error => {
                    this.SpinnerMoving = false;
                    this.error = error;
                    console.log(' error 1827' + JSON.stringify(error));
                    const evt = new ShowToastEvent({
                        title: "Error",
                        message: error.body.message,
                        variant: 'error',
                    });
                    this.dispatchEvent(evt);
                });

        }
    }

    handleComputePremium(){
        try {
            let selectedInsPlanNameList =[];
            if (this.insuranceDetailsList.length > 0) {
                this.insuranceDetailsList.forEach(element => {
                    if(element.isPlanChecked){
                        selectedInsPlanNameList.push(element.insProductName);
                    }
                });
            }
            if (this.insuranceDetailsList.length > 0 && !this.insuranceDetailsList.find(opt => opt.isPlanChecked === true)) {
                const event = new ShowToastEvent({
                    title: 'Error',
                    message: NOT_OPTED_INSURANCE_MSG_LABEL,
                    variant: 'error',
                });
                this.dispatchEvent(event);
                return;
            } else if (this.isPassengerVehiclesAndBlankLeadSource && !this.isRerunOfferAPIRun) {  //CISP-19428
                this.showToastMessage("Error", "Please click on Rerun Offer Engine button First.","Error");
                return;
            }
            else if (this.isPassengerVehicles && selectedInsPlanNameList.length > 0 && selectedInsPlanNameList.includes('LI_EMI') && selectedInsPlanNameList.includes('TATA_EMI')) {
                const event = new ShowToastEvent({
                    title: 'Error',
                    message: 'Please select either TATA EMI or LI EMI',
                    variant: 'error',
                });
                this.dispatchEvent(event);
                return;
            }
            else if (!this.isPassengerVehicles && this.insuranceDetailsList.length > 0 && selectedInsPlanNameList.length > 0 && selectedInsPlanNameList.includes(COMBO) && (selectedInsPlanNameList.includes(GPA) || (selectedInsPlanNameList.includes('LI') || selectedInsPlanNameList.includes('HEALTH')))) {
                const event = new ShowToastEvent({
                title: 'Error',
                message: COMBO_GPA_OR_HEALTH_LABEL,
                variant: 'error',
                });
                this.dispatchEvent(event);
                return;
            }else if (this.isPassengerVehicles && this.insuranceDetailsList.length > 0 && selectedInsPlanNameList.length == 1 && selectedInsPlanNameList.includes(MOTOR)) {
                this.isComputePremiumAPIRun = true;
                this.isPlanChangedObj.isComputePremiumClicked = true;
                this.fundisabled =false;
                const event = new ShowToastEvent({
                    title: 'Insurance Premium API callout not required',
                    message: 'You have selected Motor Insurance only so click on Funding Availability!!!',
                    variant: 'Success',
                });
                this.dispatchEvent(event);
                return;
            }
            else{
                let selectedInsPlanList =[];
                let stopPremiumAPI =false;
                for (let i = 0; i < this.insuranceDetailsList.length; i++) {
                    const element = this.insuranceDetailsList[i];
                    if (element.isPlanChecked) {
                        if (element.insPlanCode) {
                            const selectedInsPlan ={
                                Ins_Product : element.insProductName,
                                Opt_YN : 'Y',
                                Plan_Code : fixedInsPlan.includes(element.insProductName) ? '' : element.insPlanCode,
                                Premium : element.insProductName === MOTOR ? String(Math.round(element.insAmount)) : element.insProductName === 'LI_EMI' || element.insProductName === 'TATA_EMI' ? String(Math.round(this.emi)): 0,
                                Fund_YN : element.isFundedChecked ? 'Y': 'N'
                            }
                            selectedInsPlanList.push(selectedInsPlan);
                        } else {
                            stopPremiumAPI = true;
                            break;
                        }
                    }
                }
                console.log('selectedInsPlanList', selectedInsPlanList);
                if(!stopPremiumAPI){
                    this.getAPIInsuPerimumResponse(this.applicantId, selectedInsPlanList);
                }else{
                    const event = new ShowToastEvent({
                        title: 'Error',
                        message: 'Please select Plan for selected Insurance Product!',
                        variant: 'error',
                        });
                    this.dispatchEvent(event);
                    return;
                }
            }  
        } catch (error) {
            console.error(error);
        }
    }

    planCheckChangeHandler(event){
        let selectedPlanName = event.target.label;
        let insplanChecked = event.target.checked;
        this.isInsuranceSeletedInLOne = false;
        if(selectedPlanName == 'LI_EMI' && insplanChecked){
            this.disabledHeightAndWeight = false;
        }else if(selectedPlanName == 'LI_EMI' && !insplanChecked){
            this.disabledHeightAndWeight = true;
             this.applicantHeight = '';
             this.applicantWeight = '';
        }
        let tempinsuranceDetailsList = this.insuranceDetailsList;
        this.insuranceDetailsList = [];
        for (let i = 0; i < tempinsuranceDetailsList.length; i++) {
            const element = tempinsuranceDetailsList[i];
            if (selectedPlanName === element.insProductName) {
                if (insplanChecked) {
                    element.isPlanChecked = true;
                    element.isFundedDisabled = this.activeTab == this.label.CoBorrower ? true : false;
                    element.isPlanCodeDisabled = fixedInsPlan.includes(element.insProductName) ? true : false;
                }else{
                    element.isPlanChecked = false;
                    element.isFundedChecked = false;
                    element.isFundedDisabled = true;
                    element.insPlanCode = fixedInsPlan.includes(element.insProductName) ? element.insPlanCode : '';
                    element.insAmount = element.insProductName === MOTOR ? element.insAmount : 0;
                    element.isPlanCodeDisabled = true;
                }
            }
            this.insuranceDetailsList.push(element);
        }
        this.consentFlagRequiredMethod();
        this.iconButton = false;
        this.editPlanFlag = true;
        this.isComputePremiumAPIRun = false;
        this.isPlanChangedObj.isPLanCheckChange = true;
    }
    handleheightAndweight(event){
        if(event.target.name == "height"){
            this.applicantHeight = event.target.value;
        }
        if(event.target.name == "weight"){
            this.applicantWeight = event.target.value;
        }
        if(this.applicantHeight && this.applicantWeight){
            this.bmiValue = (parseFloat(this.applicantWeight) / ((parseFloat(this.applicantHeight) * parseFloat(this.applicantHeight)) / 10000)).toFixed(2);
        }
    }

    //CISP-19428
    isRerunOfferAPIRun = false;
    isFundedchanged = false;


    showToastMessage(title,message,variant){
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }

    handleRerunOffer(){
        this.SpinnerMoving = true;
        let offerEngineRequestString = {
            'loanApplicationId': this.recordId,
            'currentScreen': 'Final Offer',
            'thresholdNetIRR': null,
            'crmIrrChanged': null,
            'loanAmountChanged':  this.activeTab === this.label.Borrower ? (parseFloat(this.loanAmount) + parseFloat(this.fundedPremiumValue)).toString() : null,
            'tenureChanged': null,
            'advanceEmiFlag': null,
            'offerEMI': this.emi?this.emi.toString():'',
        };
        doOfferEngineCallout({
            offerEngineRequestString: JSON.stringify(offerEngineRequestString)
        })
        .then(result => {
            const obj = JSON.parse(result);
            if (obj != null && obj.status != 'FAILED') {
                this.showToastMessage('Success',Message_Offer_Engine_Success,'success');
                if (this.finalTermId) {
                    const FinalTermFields = {};
                    FinalTermFields[final_ID_FIELD.fieldApiName] = this.finalTermId;
                    if (obj.EMI) {
                        FinalTermFields[EMI_Amount.fieldApiName] = obj.EMI;
                        if(this.emi && parseFloat(this.emi) != parseFloat(obj.EMI)){
                            this.offerEngineEMIChanged = true;
                            if(this.insuranceDetailsList.length > 0 && this.insuranceDetailsList.find(opt => opt.isPlanChecked === true)){
                                this.isComputePremiumAPIRun = false;
                                const event = new ShowToastEvent({
                                    title: 'Error',
                                    message: 'Offer EMI Amount changed. Please Compute Premium first!',
                                    variant: 'error',
                                });
                                this.dispatchEvent(event);
                            }
                        }else{
                            this.offerEngineEMIChanged = false;
                        }
                        this.emi = obj.EMI;
                    }
                    if (obj.Final_CRM_IRR) {
                        FinalTermFields[CRM_IRR.fieldApiName] = obj.Final_CRM_IRR;
                    }
                    if (obj.Final_Gross_IRR) {
                        FinalTermFields[Gross_IRR.fieldApiName] = obj.Final_Gross_IRR;
                    }
                    if (this.productType === 'Two Wheeler' && obj.Final_Net_IRR) {
                        FinalTermFields[Net_IRR.fieldApiName] = obj.Final_Net_IRR;
                    }
                    if (obj.TableCode) {FinalTermFields[Table_Code.fieldApiName] = obj.TableCode;}
                    if(obj.Interest_VersionNo){FinalTermFields[Interest_Version_No.fieldApiName] = obj.Interest_VersionNo;}
                    if(obj.DR_PenalInterest){FinalTermFields[DR_Penal_Interest.fieldApiName] = obj.DR_PenalInterest;} 
                    if(obj.mclrRate){FinalTermFields[mclrRate.fieldApiName] = obj.mclrRate;} 
                    this.updateRecordDetails(FinalTermFields);
                    this.isRerunOfferAPIRun = true;
                    this.isFundedchanged = false;
                    this.SpinnerMoving = false;
                }
            } else {
                this.showToastMessage('Error',Message_Offer_Engine_Failure,'error');
                this.isRerunOfferAPIRun = false;
                this.SpinnerMoving = false;
            }            
        }).catch(error => {
            console.error('error in Offer Engine', error);
            this.isRerunOfferAPIRun = false;
            this.SpinnerMoving = false;
            this.showToastMessage('Error',Message_Offer_Engine_Failure,'error');
        });
    }
}