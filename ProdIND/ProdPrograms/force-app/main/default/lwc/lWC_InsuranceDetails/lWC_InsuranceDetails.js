import { LightningElement, track, api,wire } from 'lwc'; 
import { loadStyle } from 'lightning/platformResourceLoader';
import LightningCardCSS from '@salesforce/resourceUrl/loanApplication';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import stpverify from '@salesforce/apex/IND_LWC_StpChecksCntrl.stpChecks';
import createFinalTermRecord from '@salesforce/apex/FinalTermscontroller.createFinalTermRecord';
import getmotorvalue from '@salesforce/apex/IND_InsuranceDetailsLWC_controller.getmotorfromopp';
import stpupdate from '@salesforce/apex/IND_LWC_StpChecksCntrl.stpVerify';
//import getInsurancePremium from '@salesforce/apex/IND_InsuranceDetailsLWC_controller.getInsurancePremium';
import getFundingAvailibility from '@salesforce/apex/IND_InsuranceDetailsLWC_controller.getFundingAvailibility';
import sendInsuranceConsent from '@salesforce/apex/IND_InsuranceDetailsLWC_controller.sendInsuranceConsent';
import submitInsuranceDetails from '@salesforce/apex/IND_InsuranceDetailsLWC_controller.submitInsuranceDetails';
import getProductTypeFromOpp from '@salesforce/apex/IND_InsuranceDetailsLWC_controller.getProductTypeFromOpp';
import getApplicantId from '@salesforce/apex/IND_InsuranceDetailsLWC_controller.getApplicantId';
import ResendSMS from '@salesforce/apexContinuation/FinalTermscontroller.ResendSMS';
import updateInsuranceConsentReceived from '@salesforce/apex/IND_InsuranceDetailsLWC_controller.updateInsuranceConsentReceived';
import getInsuranceConsentCheckboxValue from '@salesforce/apex/IND_InsuranceDetailsLWC_controller.getInsuranceConsentCheckboxValue';
import checkRetryExhausted from '@salesforce/apex/IND_InsuranceDetailsLWC_controller.checkRetryExhausted';
import { updateRecord } from 'lightning/uiRecordApi';
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
//CREATED BY mohammad_shahkomeni
import doFicoDeviationCallout from '@salesforce/apexContinuation/IntegrationEngine.doFicoDeviationCallout';
//import updateDeviationDetails from '@salesforce/apex/IND_InsuranceDetailsLWC_controller.updateDeviationDetails';
import doOfferEngineCallout from '@salesforce/apexContinuation/IntegrationEngine.doOfferEngineCallout';
import doD2COfferEngineCallout from '@salesforce/apexContinuation/D2C_IntegrationEngine.doD2COfferEngineCallout';//Hero CISH-02 && CISH-15
import CreditProcessing from '@salesforce/label/c.Credit_Processing';
// END 
import Gross_IRR from '@salesforce/schema/Final_Term__c.Gross_IRR__c';
import final_ID_FIELD from '@salesforce/schema/Final_Term__c.Id';
import EMI_Amount from '@salesforce/schema/Final_Term__c.EMI_Amount__c';
import CRM_IRR from '@salesforce/schema/Final_Term__c.CRM_IRR__c';
import Net_IRR from '@salesforce/schema/Final_Term__c.Net_IRR__c';
import Net_IRR_DECIMAL from '@salesforce/schema/Final_Term__c.Net_IRR_Decimal__c';
import isNavigate from '@salesforce/schema/Final_Term__c.isNavigate__c';
import Inputted_IRR from '@salesforce/schema/Final_Term__c.Inputted_IRR__c';//CISP-2533

import OPP_ID_FIELD from '@salesforce/schema/Opportunity.Id';
import STAGENAME from '@salesforce/schema/Opportunity.StageName';
import LASTSTAGENAME from '@salesforce/schema/Opportunity.LastStageName__c';
import Submitted_Tabs from '@salesforce/schema/Opportunity.Submitted_Tabs__c';
import fetchOppourtunityData from '@salesforce/apex/IND_InsuranceDetailsLWC_controller.fetchOppourtunityData';

//Custom Labels
import Tractor from '@salesforce/label/c.Tractor';
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

//Custom Labels
import COMBO_GPA_OR_HEALTH_LABEL from '@salesforce/label/c.COMBO_GPA_OR_HEALTH';
import FICO_Deviation_ERROR_LABEL from '@salesforce/label/c.FICO_Deviation_ERROR';
import GPA_OR_COMBO_LABEL from '@salesforce/label/c.GPA_OR_COMBO';
import NOT_OPTED_INSURANCE_MSG_LABEL from '@salesforce/label/c.NOT_OPTED_INSURANCE_MSG';
import Offer_Engine_Error from '@salesforce/label/c.Offer_Engine_Error';
import Sanction_Status_Message_LABEL from '@salesforce/label/c.Sanction_Status_Message';
//Applicant consent fields.
import APPLICATION_FORM_SMS_SENT from '@salesforce/schema/Applicant__c.Application_Form_SMS_Sent__c';
import APPLICANT_ID from '@salesforce/schema/Applicant__c.Id';
import INSURANCE_CONSENT_SENT from '@salesforce/schema/Applicant__c.Insurance_consent_sent_on__c';
import APPLICANT_InsuranceConsentOTP from '@salesforce/schema/Applicant__c.Insurance_Consent_OTP__c';
import APPLICANT_ApplicationConsentOTP from '@salesforce/schema/Applicant__c.Application_Consent_OTP__c';
import accessLoanApplication from '@salesforce/apex/LwcLOSLoanApplicationCntrl.accessLoanApplication';
import ReadOnlyLeadAccess from '@salesforce/label/c.ReadOnlyLeadAccess';
import getFinalTermData from '@salesforce/apex/IND_OfferScreenController.loadOfferScreenData';//CISP-2408
import getLoanApplicationReadOnlySettings from '@salesforce/apex/LwcLOSLoanApplicationCntrl.getLoanApplicationReadOnlySettings';//Ola integration changes
import fetchDataFromApplicatntObj from '@salesforce/apex/IND_InsuranceDetailsLWC_controller.fetchDataFromApplicatntObj';//CISP-3194
import getDocumentsToCheckPan from '@salesforce/apex/IND_LWC_LoanDetailsCntrl.getDocumentsToCheckPan';//CISP-3938
import {NavigationMixin} from 'lightning/navigation';
import Table_Code from '@salesforce/schema/Final_Term__c.Table_Code__c';//CISP-16547
import DR_Penal_Interest from '@salesforce/schema/Final_Term__c.DR_Penal_Interest__c';//CISP-16547
import Interest_Version_No from '@salesforce/schema/Final_Term__c.Interest_Version_No__c';//CISP-16547
import mclrRate from '@salesforce/schema/Final_Term__c.mclrRate__c';//CISP-16547 
import deleteExistingPlans from '@salesforce/apex/IND_InsuranceDetailsLWC_controller.deleteExistingPlans';//CISP-18978
import getFinalTermLoanAmount from '@salesforce/apex/IND_InsuranceDetailsLWC_controller.getFinalTermLoanAmount';//CISP-18978 
/*Sftrac 87 */
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import Applicant_OBJ from '@salesforce/schema/Applicant__c';
import RelationshipType from '@salesforce/schema/Applicant__c.Nominee_Relationship__c';
import {getRecord} from 'lightning/uiRecordApi';
import getBorrowerDocument from '@salesforce/apex/IND_InsuranceDetailsLWC_controller.getBorrowerDocument';

const Applicant_Fields = [
    'Applicant__c.Nominee_name__c',
    'Applicant__c.Nominee_DOB__c',
    'Applicant__c.Nominee_Relationship__c',
    'Applicant__c.Nominee_address__c',
    'Applicant__c.IsPrimary__c'
];
/*Sftrac 87 Close*/

const fixedInsPlan = [MOTOR, 'LI_EMI', 'TATA_EMI', 'LI'];
const PlanforCoborrower = ['FLEXI',COMBO, 'GPA', 'LI'];

export default class LWC_InsuranceDetails extends NavigationMixin(LightningElement) {
    oppLoanAmount; oppTotalExposureAmt = 0;existingBorrowerExposureAmount = 0;existingCoBorrowerExposureAmount=0; 
    existingOtherExposureAmount =0;bankExposureAmount=0;//CISP-3938 
    @api recordId;
    @api creditval;
    @api responseReApisatus;
    @api callMsterRecords;
    @api activetab;
    @api tablength;
    @track currentStageName;
    @track lastStage;
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

    
    @api checkleadaccess;//coming from tabloanApplication
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
    @track isSpinnerMoving = false;
    @track isSecondSpinnerMoving = false;
    @track SpinnerMoving = false; 
    @track showFileUploadAndView = false;

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

    @track isHealthInsuranceDisabled = false;
    @track isGPADisabled = false;
    @track isComboDisabled = false;
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

    @track fundedPremiumValue;
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

    @track defaultHealthPlan;
    @track defaultHealthAmount;
    @track defaultHealthFundType;

    @track defaultComboPlan;
    @track defaultComboAmount;
    @track defaultComboFundType;

    @track defaultGPAPlan;
    @track defaultGPAAmount;
    @track defaultGPAFundType;
    leadSource;//Ola integration changes//D2C Change
    isNonIndividual = false;//SFTRAC-308
    entityType; //SFTRAC-308
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

    /* Sftrac-87 */
    get nomineeLabel(){
        return this.activeTab === this.label.Borrower ? 'Nominee Details - Borrower' : this.activeTab === this.label.CoBorrower ? 'Nominee Details - Co Borrower' : '';
    }

    get isTractorWithNomineeSection() {
        if (this.productType === 'Tractor' && this.showNomineeSection) {
            if (this.activeTab === this.label.Borrower && this.calculateAge(this.kycDobBorrower) < 55) {
                return true;
            } else if (this.activeTab === this.label.CoBorrower && this.isPrimary && this.calculateAge(this.kycDobBorrower) > 55) {
                return true;
            }
        }
        return false;
    }

    calculateAge(dateString) {
        const dob = new Date(dateString);
        const currentDate = new Date();
        let age = currentDate.getFullYear() - dob.getFullYear();
    
        if (
            currentDate.getMonth() < dob.getMonth() ||
            (currentDate.getMonth() === dob.getMonth() && currentDate.getDate() < dob.getDate())
        ) {
            age--;
        }
    
        return age;
    }

    activeSections = ['NomineeDetails'];
    borrowerName;
    borrowerDOB;
    borrowerRelationship;
    borrowerAddress;
    borrowerRelationshipOption=[];
    kycDobBorrower;
    @wire(getObjectInfo, { objectApiName: Applicant_OBJ })
    applicantObj;

    @wire(getPicklistValues, { recordTypeId: '$applicantObj.data.defaultRecordTypeId', fieldApiName: RelationshipType })
    relationshipTypeValues({ data, error }) {
        if (data) {
            data.values.forEach(val => {
                this.borrowerRelationshipOption = [...this.borrowerRelationshipOption, { value: val.value, label: val.label }];
            });
        }
        else if (error) {
            this.processErrorMessage('error',error,'error');
        }
    }

    wireRunsOnlyOnce;
    applicantData
    @track inputWrapper = {};
    showNomineeSection;
    isPrimary;
    @wire(getRecord, { recordId: '$applicantId', fields: Applicant_Fields })
    async wiredApplicantData({ error, data }) { 
        if (data && !this.wireRunsOnlyOnce) {
            this.wireRunsOnlyOnce = true;
            this.applicantData = data;
            this.inputWrapperPopulator();
            this.showNomineeSection = true;
            //console.log('this.applicantData'+JSON.stringify(this.applicantData));
        }
        else if (error) {
            console.log('error Applicant Field ', error);
            if (error.body.message) {
                this.dispatchEvent(
                    new ShowToastEvent({title: 'Error!', message: error.body.message, variant: error})
                );
            } else {
                this.dispatchEvent(
                    new ShowToastEvent({title: 'Error!', message: error.body.message, variant: error})
                );
            }
        }
    }

    @wire(getBorrowerDocument,{opportunityId: '$recordId'})
     wiredBorrowerDocument({error,data}){
        if (data){
            this.kycDobBorrower = data.KYC_DOB__c;
            console.log('age-'+this.calculateAge(this.kycDobBorrower));
        }
        else if (error) {
            console.log('error Document Field ', error);
            if (error.body.message) {
                this.dispatchEvent(
                    new ShowToastEvent({title: 'Error!', message: error.body.message, variant: error})
                );
            } else {
                this.dispatchEvent(
                    new ShowToastEvent({title: 'Error!', message: error.body.message, variant: error})
                );
            }
        }

    }
    inputWrapperPopulator(){
        this.inputWrapper['borrowerName'] = { label: 'Borrower Name', value: this.applicantData.fields.Nominee_name__c.value };
        this.inputWrapper['borrowerDOB'] = { label: 'Borrower Dob', value: this.applicantData.fields.Nominee_DOB__c.value };
        this.inputWrapper['borrowerRelationship'] = { label: 'Borrower Relationship', value: this.applicantData.fields.Nominee_Relationship__c.value };
        this.inputWrapper['borrowerAddress'] = { label: 'Borrower Address', value: this.applicantData.fields.Nominee_address__c.value };
        this.isPrimary = this.applicantData.fields.IsPrimary__c.value;

    }

    handleInputFieldChange(event){
        this.inputWrapper[event.target.name].value = event.target.value;
    }
    processErrorMessage(title,message,variant) {
        let errorMsg = '';
        if (message) {
            if (message.body) {
                if (Array.isArray(message.body)) {
                    errorMsg = message.body.map(e => e.message).join(', ');
                } else if (typeof message.body.message === 'string') {
                    errorMsg = message.body.message;
                }
            }
            else {
                errorMsg = message;
            }
        }
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant
            })
        );
    }
    /* Sftrac-87 Close */
    @api helathInuDisabled;
    @api combofunDisabled;
    @api gapfunDisabled;
    @api iconButton = false;
    @api issmscalloutsborrower = 1;
    @api issmscalloutscoborrower = 1;
    @api fundisabled = false;
    emi;// CISP-2408
    isPassengerVehicles=false;//start CISP-3194
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
    isFlexiInsuranceDisabled=false;
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
    haveNoDataforTW = false;
    haveNoDataforPV = false;
    existingInsDetailList = [];
    insuranceDetailsList = [];
    isComputePremiumAPIRun = false;
    comboLIPremium = 0;
    comboEMIPremium = 0;
    eMIPassedinAPI = 0;//End CISP-3194
    submittedTabs;
    isOfferEngineApiFailed=false;
    applicantAge;
    applicantHeight;
    applicantWeight;
    disabledHeightAndWeight=true;
    bmiValue;
    showheightAndWeight = false;
    
    
    //API2 RESPONSE "FAIL" FOR INSURANCE PERIMUM 
    async getPreimumfromMaster(Ins_Product, Plan_Code) {
        await getMotorInsurancePreimum({
            Ins_Product: Ins_Product,
            Plan_Code: Plan_Code
        }).then(result => {
            if (result == null) {
                this.isComputePremiumAPIRun = true;
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
        });
    }
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
            var getResponse = JSON.parse(result);
            console.log('status flag of 2nd api', getResponse.Status_Flag);
            // console.log('API2...' + JSON.stringify(getResponse));

            if (getResponse.Status_Flag == 'Failure') {
                this.getPreimumfromMaster(Ins_Product[0].Ins_Product, Ins_Product[0].Plan_Code);
            } else {
                console.log('FROM API2... Amount' + getResponse.Premium_Details);
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
                }
                this.isComputePremiumAPIRun = true;
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
        console.log('result.applicationNo --> ', result);
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
                    if(response === SuccessMessage){
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
            }
        }).catch(error => {
            this.responseReApisatus = 'Error';
            console.log('Error.... Insurance API 1' , error);
            this.dispatchEvent(ShowToastEvent({
                title: "Requried",
                message: error.body.message,
                variant: 'Error',
            }));

            checkRetryExhausted({
                loanApplicationId: this.recordId, attemptFor: 'Insurance Recommendation API', applicantId: this.applicantId
            }).then(response => {
                console.log('response of checkRetryExhausted =>',response);
                if(response === SuccessMessage){
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
                    this.submittedTabs = response.Opportunity__r.Submitted_Tabs__c;
                    height = response.Height__c ? response.Height__c:null;
                    weight = response.Weight__c ? response.Weight__c:null;
                    bmi = response.BMI__c ? response.BMI__c:null;
                }
            });
        if(this.productType != Tractor){
            const currentApplicantId = await getApplicantId({
                opportunityId: this.recordId,
                applicantType: this.activeTab,
            })
            this.applicantId = currentApplicantId;
        }

        // const currentSubStage = await getCurrentSubStage({ opportunityId: this.recordId })
        // this.subStage = currentSubStage;
        /*On page load,Query the Insurance Details object for the current loan application record.
         If there is a record which means 
         User had already submitted the insurance details and consent is received 
         and is revisiting the page. Pull the relevant details and render on the page and make the page read only*/
        await existInsuranceDetailsMethod({
            loanAppID: this.recordId,
            applicantId: this.applicantId
        }).then(result => {
            if (result.length > 0) {
                this.fundisabled = true;
                result.forEach(getInsProdObj => {
                    this.currentStage = getInsProdObj.Stage;
                    this.subStage = getInsProdObj.Sub_Stage;
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
            }
            if (this.currentStageName === 'Insurance Details') {
                if(this.tablength == 2 && this.activeTab === this.label.Borrower && this.submittedTabs!= null && this.submittedTabs.includes('L1 - Borrower Insurance')){
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
                            this.isOfferEngineApiFailed = parsedData.IsOfferEngineApiFailed;
                            if(this.isOfferEngineApiFailed || !this.emi){
                                  this.dispatchEvent(new ShowToastEvent({
                                      title: 'Error',
                                      message: 'Selection of LI_EMI and TATA_EMI product is disabled as offer engine has failed. Please choose these insurance products in web journey.',
                                      variant: 'error'
                                  }));
                            }
                        }
                    }).catch(error => {console.error('error in getFinalTermData => ', error);});
                    if(this.leadSource!='OLA'){
                        this.callAPIRecomMethod();//OLA-60
                    } else{this.isSpinnerMoving = false;} //OLA-67

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
            console.error('error in existInsuranceDetailsMethod =>', error);
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
            this.getAPIRecoPreimumResponse(result);
        }).catch(error => {
            console.log('error in callInuranceRecAPI =>',error);
            checkRetryExhausted({
                loanApplicationId: this.recordId, attemptFor: 'Insurance Recommendation API', applicantId: this.applicantId
            }).then(response => {
                console.log('response of checkRetryExhausted =>',response);
                if(response === SuccessMessage){
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
        this.subStage = currentSubStage.Sub_Stage__c;
        console.log('line 555 stage and substage=> ', this.subStage);
        if (this.currentStage === this.label.CreditProcessing && this.subStage === 'Insurance' && this.leadSource!='OLA') {//OLA-60 
            console.log('call integration log method');
            this.onloadexistInsuranceDetails();
            this.callAPIRecomMethod();
        } else {
            this.isSpinnerMoving= true;
            this.onloadexistInsuranceDetails();
        }
    }
    //CISP-15702 Start
    @wire(getRecord, { recordId: '$recordId', fields: ['Opportunity.UploadAndViewDocDisable__c']})
    wireOpportunityRec;
    get isUploadViewDisabled(){
        return this.wireOpportunityRec.data ? this.wireOpportunityRec.data.fields.UploadAndViewDocDisable__c.value : false;
    }
    //CISP-15702 End
    async connectedCallback() {
        this.SpinnerMoving = true;////CISP-519
        await fetchOppourtunityData({ loanApplicantionId: this.recordId })
        .then(result => {
            this.currentStageName = result[0].StageName;
            this.lastStage =  result[0].LastStageName__c;
            this.leadSource =  result[0].LeadSource;// D2C changes
            this.productType = result[0].Product_Type__c;
            //SFTRAC-308 starts
            this.entityType = result[0].Entity_Type__c;
            if(this.entityType =='Non-Individual' && this.productType == 'Tractor'){
                this.isNonIndividual = true;
            }
            console.log('this.isNonIndividual ',this.isNonIndividual);
            //SFTRAC-308 ends
            this.submittedTabs = result[0].Submitted_Tabs__c;
            this.oppLoanAmount = result[0].Loan_amount__c;
            this.oppTotalExposureAmt = result[0].Total_Exposures_Amount__c;
            this.oppTotalExposureAmt = result[0].Total_Exposures_Amount__c ? result[0].Total_Exposures_Amount__c : 0; 
            this.existingBorrowerExposureAmount = result[0].Existing_Borrowers_Exposure_Amt__c ? result[0].Existing_Borrowers_Exposure_Amt__c :0;
            this.existingCoBorrowerExposureAmount = result[0].Existing_Co_Borrowers_Exposure_Amt__c ? result[0].Existing_Co_Borrowers_Exposure_Amt__c :0 ; 
            this.existingOtherExposureAmount = result[0].Existing_Others_Exposure_Amt__c ? result[0].Existing_Others_Exposure_Amt__c : 0; 
            this.bankExposureAmount = result[0].Total_Bank_Exposure__c ? result[0].Total_Bank_Exposure__c : 0; 
            if (this.productType === this.label.PassengerVehicles) {//Start CISP-3194
                this.isPassengerVehicles=true;
            }//End CISP-3194
            this.showheightAndWeight = (this.leadSource != 'D2C' && this.isPassengerVehicles);
            this.SpinnerMoving = false;////CISP-519
        })
        .catch(error => {
            console.log('fetchOppourtunityData error : ' + error);
        });           
        await getFinalTermLoanAmount({ recordId: this.recordId }) 
          .then(result => {
            console.log('Result', result);this.oppLoanAmount = result[0].Loan_Amount__c ? result[0].Loan_Amount__c : 0;
          })
          .catch(error => {
            console.error('Error:', error);
        }); 
        await this.fetchSubStage();
        //Ola integration changes
        await getLoanApplicationReadOnlySettings({leadSource:this.leadSource})
        .then(data => {
            let fieldList = [];if(data){fieldList=data.Input_Labels__c.split(';');}

            
            console.log(fieldList);
            if(fieldList.length>0 && this.leadSource != 'Hero'){
                if(fieldList.includes('Insurance details')){
                    this.isComboDisabled=true;//OLA-57
                    this.disableEverything();
                    this.template.querySelector('[data-id=submitButton]').disabled = false;
                }
            }
        }).catch(error => { 
        });
        //Ola Integration changes
        //await this.onloadexistInsuranceDetails();
        this.isConsentButtonDisabled = true;
        //this.isSubmitButtonDisabled = true;
        this.showSubmitButton = true;
        this.popupCheckboxChecked = true;
        await getDocumentsToCheckPan({ loanApplicationId: this.recordId })
          .then(result => {
            console.log('Result', result);
            this.documentData = JSON.parse(result);
          })
          .catch(error => {
            console.error('Error:', error);
        });
        this.callAccessLoanApplication();
    }


    callAccessLoanApplication(){
        accessLoanApplication({ loanId: this.recordId , stage: 'Insurance Details'}).then(response => {
            console.log('accessLoanApplication Response:: ', response);
            if(!response){ 
                this.disableEverything();
                console.log('here 2');
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
            }
          }).catch(error => {
              console.log('Error in accessLoanApplication:: ', error);
          });
    }

    async getIns_ProdutcsMthod() {
        let motorIns = {}; 
        let addInsuranceDetailsList = [];
        /*b.For Motor insurance plans will not be part of API1 
        response and plan field will not be applicable on UI for motor insurance.
        In API1 response premium amount for motor insurance will be equal to the 
        ‘1st year motor insurance’ premium amount (for new vehicle)
        or Motor Insurance Premium (for used vehicle) which was shared as input to API1*/
        if(this.activeTab === this.label.Borrower){
            await getMotorInsuranceFromLoanDetails({
                loanAppID: this.recordId
            }).then(result => {
                if (result != null) {
                    motorIns = {
                        insProductName : result.Ins_Product,
                        isPlanChecked : true,
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
                        isFundedDisabled : false
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
                        isPlanCheckDisabled : (this.activeTab == this.label.CoBorrower && !PlanforCoborrower.includes(getObj.Ins_Product)) || ((getObj.Ins_Product == 'LI_EMI' || getObj.Ins_Product == 'TATA_EMI') && (this.isOfferEngineApiFailed || !this.emi)) || ((this.applicantAge && (this.applicantAge<18 || this.applicantAge>65)) && getObj.Ins_Product == 'TATA_EMI') || ((this.applicantAge &&(this.applicantAge<18 || this.applicantAge>60)) && getObj.Ins_Product == 'LI_EMI') || ((this.applicantAge && (this.applicantAge<18 || this.applicantAge>55)) && getObj.Ins_Product == 'FLEXI') ? true : false,
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
            
        this.isSpinnerMoving = false;
        console.log('this.insuranceDetailsList',this.insuranceDetailsList);
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
        let selectedInsPlan = event.target.name;
        let insPlanvalue = event.target.value;
        let tempinsuranceDetailsList = this.insuranceDetailsList;
        this.insuranceDetailsList = [];
        for (let i = 0; i < tempinsuranceDetailsList.length; i++) {
            const element = tempinsuranceDetailsList[i];
            if (element.insProductName === selectedInsPlan) {
                element.insPlanCode = insPlanvalue;
                element.insAmount = element.insPlanOptions.find(opt => opt.value === insPlanvalue).insAmount;
            }
            this.insuranceDetailsList.push(element);
        }
        this.disableComputePremium = false;
        this.fundisabled = false;
        this.iconButton = false;
        this.isSubmitButtonDisabled = false;
        this.isComputePremiumAPIRun = false;
    }

    //Handler for amount input field change.
    hanldeAmountValueChange(event) {
        this.popupCheckbox = false;
        this.showPopupForAmount = true;
        this.popupCheckboxChecked = true;
        let selectedPlanName = event.target.name;
        let enteredAmount = event.target.value;
        this.insuranceDetailsList.find(opt => opt.insProductName === selectedPlanName).insAmount = enteredAmount;
        this.disableComputePremium = false;
        this.fundisabled = false;
        this.iconButton = false;
        this.isSubmitButtonDisabled = false;
    }

    //Handler for is funded toggle change.
    handleIsFundedToggle(event) {
        let selectedPlanName = event.target.name;
        let insFundedChecked = event.target.checked;
        this.insuranceDetailsList.find(opt => opt.insProductName === selectedPlanName).isFundedChecked = insFundedChecked;
        this.disableComputePremium = false;
        this.fundisabled = false;
        this.iconButton = false;
        this.isSubmitButtonDisabled = false;
        this.isComputePremiumAPIRun = false;
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
            const event = new ShowToastEvent({
                title: 'Info',
                message: NOT_OPTED_INSURANCE_MSG_LABEL,
                variant: 'info',
            });
            this.dispatchEvent(event);
            return;
        }
        else if (this.isPassengerVehicles && this.insuranceDetailsList.length > 0 && selectedInsPlanNameList.length > 0 && selectedInsPlanNameList.includes('LI_EMI') && selectedInsPlanNameList.includes('TATA_EMI')) {
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
                message:'You have choose LI_EMI so please enter Height and Weight',
                variant: 'error',
            });
            this.dispatchEvent(event);
            return;            
        }else if(this.isPassengerVehicles && this.leadSource != 'D2C' && this.insuranceDetailsList.length > 0 && selectedInsPlanNameList.length > 0 && selectedInsPlanNameList.includes('LI_EMI') && this.applicantHeight && this.applicantWeight && this.bmiValue && (this.bmiValue <18 || this.bmiValue >30)){
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
        else {
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
                    const response = JSON.parse(result);
                    //   console.log('get Funding Response=>...' + JSON.stringify(response));
                    console.log('funding response => ', response);
                    if (response.responseStatus) {
                        console.log('funding response => ', response);
                        this.fundedPremiumValue = response.totalPremiumFunded;
                        this.totalInsurancePayable = response.totalInsurancePayable;
                        this.ltvWithInsurance = response.ltvWithInsurance;
                        this.ltvWithoutInsurance = response.ltvWithoutInsurance;
                        this.proposalLtv = response.proposalLtv;
                        //Enabling the submit button.
                        this.isSubmitButtonDisabled = false;
                        this.isConsentButtonDisabled = false;
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

    //SMS callout method- this method will make a call to Integration class. 
    //Update the SMS consent fields in Applicant 
    async sendInsuranceConsentcall(appid, InsData, flag) {
        console.log('type of message' + flag);
        console.log('Applicant record Id :' + appid);

        let otpValue;
        //Updating the applicant record with consent fields
        const tDatetime = new Date().toISOString();
        const fields = {};
        fields[APPLICANT_ID.fieldApiName] = appid;

        if (flag == 'LAS') {
            let applicationRanNum = Math.floor(Math.random() * 10000);
            otpValue = applicationRanNum;
            fields[APPLICATION_FORM_SMS_SENT.fieldApiName] = tDatetime;
            fields[APPLICANT_ApplicationConsentOTP.fieldApiName] = String(applicationRanNum);
        }
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

                        var getsmsco = parseInt(this.issmscalloutscoborrower);

                        const event = new ShowToastEvent({
                            title: 'Success',
                            message: this.label.Consent_Sent_Successfully,
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
                message:'You have choose LI_EMI so please enter Height and Weight',
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
            // this.iconButton = false;
            this.isConsentButtonDisabled = false;
            this.issmscallouts = 1;
        }
        console.log('calling sendInsuranceConsent 1198 ');
        await sendInsuranceConsent({
            loanapplicationId: this.recordId,
            appType: this.activeTab
        }).then(result => {
            this.iconButton = true;
            this.isConsentButtonDisabled = true;
            console.log("this.issmscalloutscoborrower ", this.issmscalloutscoborrower);
            console.log("this.issmscalloutsborrower ", this.issmscalloutsborrower);
            if ((this.activeTab == this.label.Borrower && parseInt(this.issmscalloutsborrower) == 2) || (parseInt(this.issmscalloutscoborrower) == 2 && this.activeTab == this.label.CoBorrower)) {
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

    handleSms(){
        // sms code 
        ResendSMS({ loanId: this.recordId })
        .then(result => {
            if (result != null || result != undefined || result.length != 0) {
                for (var i = 0; i < result.length; i++) {
                    let smsRequestString = {
                        'applicantId': result[i].Id,
                        'loanApplicationId': this.recordId,
                        'flag': 'LAS',
                    };
                    doSmsCallout({
                        smsRequestString: JSON.stringify(smsRequestString)
                    }).then(smsresult => {
                        if (smsresult == 'SUCCESS') {
                            console.log('sms result => ', smsresult);
                        }
                    }).catch(error => {
                        this.error = error;
                        console.log('ERROR 1305', error);
                    });
                }
            }
        })
        .catch(error => {
            console.log('error 1311', error);
        });
    }

    //method for submitting the selected insurance product and plan.
    async handleSubmit() {
        //SFTRAC-172 start
        if(this.productType === 'Tractor'){
            if((parseInt(this.ltvWithInsurance) > 95) || (parseInt(this.ltvWithoutInsurance) > 90)){
                const evt = new ShowToastEvent({
                    title: "Error",
                    message: 'LTV With Insurance can not be more than 95% and without Inurance can not be more than 90%',
                    variant: 'Error',
                });
                this.dispatchEvent(evt);
                return;
            }
        }//SFTRAC-172 end
        let totalamount = 0;
        totalamount = parseInt(this.oppLoanAmount) + parseInt(this.fundedPremiumValue) + parseInt(this.existingBorrowerExposureAmount) + parseInt(this.existingCoBorrowerExposureAmount) + parseInt(this.existingOtherExposureAmount) + parseInt(this.bankExposureAmount);
        console.log('OUTPUT totalamount: ',totalamount);
        await fetchOppourtunityData({ loanApplicantionId: this.recordId }).then(result => {this.submittedTabs = result[0].Submitted_Tabs__c; console.log('result', result); });
        console.log('Inside handleSubmit method', this.submittedTabs, this.activeTab);
        if (this.insuranceDetailsList.length > 0 && !this.insuranceDetailsList.find(opt => opt.isPlanChecked === true) && (this.activeTab =='Co-borrower' && (this.submittedTabs == null || (this.submittedTabs!= null && !this.submittedTabs.includes('L1 - Borrower Insurance'))))) {
            console.log('From 111',this.submittedTabs);
            const evt = new ShowToastEvent({
                title: "Error",
                message: 'Borrower Insurance Details are not submitted!!!',
                variant: 'Error',
            });
            this.dispatchEvent(evt);
            return;
        }
        else if ((this.insuranceDetailsList.length > 0 && !this.insuranceDetailsList.find(opt => opt.isPlanChecked === true) && ((this.activeTab =='Borrower') || (this.activeTab =='Co-borrower' && this.submittedTabs!= null && this.submittedTabs.includes('L1 - Borrower Insurance')))) || this.leadSource=='OLA') {//OLA-67
            console.log('all are unselected in L1 journey');
            deleteExistingPlans({applicantId : this.applicantId ,loanApplicationId:this.recordId })
            .then(result=>{console.log('result of deleteExistingPlans =>', result);
            }).catch(error => {console.log('Error in deleteExistingPlans =>',error);
            });
            if (this.tablength == 2 && this.activeTab == this.label.Borrower) {
                const oppFields = {};
                oppFields[OPP_ID_FIELD.fieldApiName] = this.recordId;
                oppFields[Submitted_Tabs.fieldApiName] = this.submittedTabs!= null ? this.submittedTabs +';L1 - Borrower Insurance' : 'L1 - Borrower Insurance';
                await this.updateRecordDetails(oppFields);
                let allElements = this.template.querySelectorAll('*');
                allElements.forEach(element =>
                element.disabled = true
                );
                const evn = new CustomEvent('coborrower');
                this.dispatchEvent(evn);
            }else{
                /*Sftrac 87 start*/
                if(this.productType === 'Tractor'){
                const fields = {};
                fields['Id'] = this.applicantId;
                fields['Nominee_name__c'] = this.inputWrapper['borrowerName'].value;
                fields['Nominee_DOB__c'] = this.inputWrapper['borrowerDOB'].value;
                fields['Nominee_Relationship__c'] = this.inputWrapper['borrowerRelationship'].value;
                fields['Nominee_address__c'] = this.inputWrapper['borrowerAddress'].value;

                const recordInput = {
                    fields
                };
                updateRecord(recordInput)
                    .then(() => {
                        this.isSpinnerMoving = false;
                        this.dispatchEvent(
                            new ShowToastEvent({title: 'Success!', message: 'Nominee Detail Saved', variant: 'success'})
                        );
                    })
                    .catch((error) => {
                        console.log('Error while save' + JSON.stringify(error));
                        this.isSpinnerMoving = false;
                        if (error.body.message) {
                            this.dispatchEvent(
                                new ShowToastEvent({title: 'Error!', message:  error.body.message, variant: 'error'})
                            );
                        } else {
                            this.dispatchEvent(
                                new ShowToastEvent({title: 'Error!', message:  'Currently server is down, Please contact System Administrator', variant: 'error'})
                            );
                        }
                    });
                    /*Sftrac 87 Close*/
                }
                // console.log('this.inputWrapper'+JSON.stringify(this.inputWrapper));
                const oppFields = {};
                oppFields[OPP_ID_FIELD.fieldApiName] = this.recordId;
                oppFields[STAGENAME.fieldApiName] = 'Final Offer';
                oppFields[LASTSTAGENAME.fieldApiName] = 'Final Offer';
                if (this.activeTab =='Borrower') {
                    oppFields[Submitted_Tabs.fieldApiName] = this.submittedTabs!= null ? this.submittedTabs +';L1 - Borrower Insurance' : 'L1 - Borrower Insurance';
                } else if (this.activeTab =='Co-borrower') {
                    oppFields[Submitted_Tabs.fieldApiName] =  this.submittedTabs!= null ? this.submittedTabs + ';L1 - Coborrower Insurance' : 'L1 - Coborrower Insurance';
                }
                await this.updateRecordDetails(oppFields);
                console.log('Active tab :'+this.activeTab);
                await this.calldoOfferEngineCallout();
                if(this.leadSource!='OLA'){
                    await this.doFicoDeviationCallout();
                } else if(this.leadSource=='OLA'){
                    this.handleSms();
                 }
            }
        }
        else if ((this.insuranceDetailsList.length > 0 && this.insuranceDetailsList.find(opt => opt.isPlanChecked === true)) && !this.iconButton) {
            const evt = new ShowToastEvent({
                title: "Consent Required",
                message: this.label.Give_Consent_First,
                variant: 'Error',
            });
            this.dispatchEvent(evt);
            return;
        } 
        else if(this.activeTab =='Borrower' && parseInt(totalamount) >= 1000000 && this.documentData?.borrowerPanAvailable == false && this.leadSource != 'D2C'){
            const evt = new ShowToastEvent({title: "Error",message: 'Exposure (Incl. loan amount) is >=10 Lakhs, hence, PAN is mandatory. Please withdraw this lead and create a new lead with PAN',variant: 'Error',});this.dispatchEvent(evt);
            return;
        }else if(this.activeTab =='Co-borrower' && parseInt(totalamount) >= 1000000 && this.documentData?.coborrowerPanAvailable == false && this.leadSource != 'D2C'){
            const evt = new ShowToastEvent({title: "Error",message: 'Exposure (Incl. loan amount) is >=10 Lakhs, hence, PAN is mandatory. Please withdraw this lead and create a new lead with PAN',variant: 'Error',});this.dispatchEvent(evt);
            return;
        }//CISP-18978 changes

        else if ((this.insuranceDetailsList.length > 0 && this.insuranceDetailsList.find(opt => opt.isPlanChecked === true)) && this.iconButton) {
            if (this.tablength == 2 && this.activeTab == this.label.Borrower) {
                const oppFields = {};
                oppFields[OPP_ID_FIELD.fieldApiName] = this.recordId;
                oppFields[Submitted_Tabs.fieldApiName] = this.submittedTabs!= null ? this.submittedTabs +';L1 - Borrower Insurance' : 'L1 - Borrower Insurance';
                await this.updateRecordDetails(oppFields);
                let allElements = this.template.querySelectorAll('*');
                allElements.forEach(element =>
                    element.disabled = true
                );
                const evn = new CustomEvent('coborrower');
                this.dispatchEvent(evn);
            } else if(this.tablength == 2 && this.activeTab =='Co-borrower' && (this.submittedTabs== null || (this.submittedTabs!= null && !this.submittedTabs.includes('L1 - Borrower Insurance')))){
                console.log('From 222');
                const evt = new ShowToastEvent({
                    title: "Error",
                    message: 'Borrower Insurance Details are not submitted!!!',
                    variant: 'Error',
                });
                this.dispatchEvent(evt);
                return;
            }else {
                const saveDetails = {
                    loanApplicationId: this.recordId,
                    nextStage: 'Final Offer',
                    applicantId: this.applicantId,
                    ltvWithInsurance: this.ltvWithInsurance,
                    ltvWithoutInsurance: this.ltvWithoutInsurance,
                    totalInsurancePayable: this.totalInsurancePayable,
                    proposalLtv: this.proposalLtv,
                    applicantType: this.activeTab,
                    premiumFunded: this.fundedPremiumValue,
                    submittedTabs: this.activeTab == 'Borrower' ? (this.submittedTabs!= null ? this.submittedTabs +';L1 - Borrower Insurance' : 'L1 - Borrower Insurance') : this.activeTab =='Co-borrower' ? (this.submittedTabs!= null ? this.submittedTabs + ';L1 - Coborrower Insurance' : 'L1 - Coborrower Insurance') : '' 
                }

                //await this.doFicoDeviationCallout();
                console.log('saveDetails :: 1265', saveDetails);
                await submitInsuranceDetails({
                    payload: JSON.stringify(saveDetails)
                })
                    .then(result => {
                        console.log(' Line no 1270 => applicatnt ID', this.applicantId);
                        if (result === this.label.SuccessMessage) {
                            console.log(' Line no 1272 => success');
                            //this.sendInsuranceConsentcall(this.applicantId, 'JSON.stringify(getFinalInsData)', 'LAS');//CISP-3041

                            const evt = new ShowToastEvent({
                                title: 'Success',
                                message: this.label.detailsSaved,
                                variant: 'Success',
                            });
                            this.dispatchEvent(evt);
                            // sms code 
                            ResendSMS({ loanId: this.recordId })
                                .then(result => {
                                    console.log('sms sending details' + JSON.stringify(result));

                                    if (result != null || result != undefined || result.length != 0) {
                                        for (var i = 0; i < result.length; i++) {
                                            // if (this.activeTab == result[i].Applicant_Type__c) {//CISP-3041
                                                // result[i].id;//CISP-3041
                                                //alert('Id is'+result[i].Id + 'Name is'+result[i].Name);
                                                let smsRequestString = {
                                                    'applicantId': result[i].Id,  // appid need to send?
                                                    'loanApplicationId': this.recordId,      // this.recordId,
                                                    'flag': 'LAS',
                                                };
                                                doSmsCallout({
                                                    smsRequestString: JSON.stringify(smsRequestString)
                                                })
                                                    .then(smsresult => {
                                                        // alert('Callout success'+JSON.stringify(smsresult))
                                                        if (smsresult == 'SUCCESS') {
                                                            console.log('sms result => ', smsresult);
                                                        }
                                                    })
                                                    .catch(error => {
                                                        this.error = error;
                                                        // alert('error'+JSON.stringify(error))
                                                        console.log('ERROR 1305', error);
                                                    });
                                            // }//CISP-3041
                                        }
                                    }
                                })
                                .catch(error => {
                                    console.log('error 1311', error);
                                });
                            console.log('Active tab :' + this.activeTab);
                            if (this.activeTab == 'Borrower') {
                                this.calldoOfferEngineCallout();
                                this.doFicoDeviationCallout();
                            } else if (this.activeTab == 'Co-borrower') {
                                this.calldoOfferEngineCallout();
                                this.doFicoDeviationCallout()
                            }
                            //this.calldoOfferEngineCallout();
                            //this.doFicoDeviationCallout();
                            this.isSubmitButtonDisabled = true;
                            console.log("this.currentStage-->" + this.currentStage, ' substage ==> ', this.subStage);
                        } else if (result === this.label.CoborrowerConsentNotReceived && this.activeTab === this.label.Borrower) {
                            const evt = new ShowToastEvent({
                                title: "Warning",
                                message: this.label.Give_CoBorrower_Consent_First,
                                variant: 'warning',
                            });
                            this.dispatchEvent(evt);
                        }
                    })
                    .catch(error => {
                        this.error = error;
                        const evt = new ShowToastEvent({
                            title: "Error",
                            message: error.body.message,
                            variant: 'error',
                        });
                        this.dispatchEvent(evt);
                    });
                }
            }
        else {
            //added for testing purpose...can be removed.
            const evt = new ShowToastEvent({
                title: "Error",
                message: 'Something went wrong.',
                variant: 'error',
            });
            this.dispatchEvent(evt);
        }
    
    }

    //method to handle STP verification
    handleStpverify() {
        stpverify({ opportunityId: this.recordId })
            .then(result => {
                const evt = new ShowToastEvent({ title: "Success", message: Sanction_Status_Message_LABEL, variant: 'Success' });
                this.dispatchEvent(evt);
            }).catch(error => {
                const evt = new ShowToastEvent({ title: "STP Error", message: error, variant: 'error' });
                this.dispatchEvent(evt);
            })

    }

    //method to Handle STP updation
    handleStpupdate() {
        stpupdate({ opportunityId: this.recordId })
            .then(result => {
                const evt = new ShowToastEvent({ title: "Success", message: Sanction_Status_Message_LABEL, variant: 'Success' });
                this.dispatchEvent(evt);
            }).catch(error => {
                const evt = new ShowToastEvent({ title: "STP Error", message: error, variant: 'error' });
                this.dispatchEvent(evt);
            })
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
        if (this.currentStageName==='Loan Initiation' || this.currentStageName==='Additional Details' || this.currentStageName==='Asset Details' || this.currentStageName==='Vehicle Valuation' || this.currentStageName==='Vehicle Insurance' || this.currentStageName==='Loan Details' || this.currentStageName==='Income Details' || this.currentStageName==='Final Terms'|| this.currentStageName==='Offer Screen' || this.currentStageName==='Customer Code Addition' || (this.currentStageName!=='Insurance Details' && this.lastStage !== 'Insurance Details' && this.lastStage != undefined && this.currentStageName != undefined)) {////CISP-519
            this.disableEverything();
            console.log('disableEverything');
        }
    }

    //Sri
    handleOnfinish(event) {
        const evnts = new CustomEvent('customcodevaleve', { detail: event });
        this.dispatchEvent(evnts);
    }

    //method to call offerEngine api on click of submit button
    async calldoOfferEngineCallout() {
        await createFinalTermRecord({ loanApplicationId: this.recordId })
            .then(responses => {
                const obj = JSON.parse(responses);
                this.finalTermId = obj.finalTermId;
                console.log('this.finalTermId -->', this.finalTermId);
                this.isSpinnerMoving = false;
            })
            .catch(error => {
                console.log('error in createFinalTermRecord => ', error);
            });
        await getFinalTermData({ loanApplicationId: this.recordId,randomvar: '' })//Start CISP-2408
            .then((data) => {
                if (data) {
                    let parsedData = JSON.parse(data);
                    this.emi = parsedData.emi ? parsedData.emi : '';
                }
            })
            .catch(error => {
                console.log('error in getFinalTermData => ', error);
            });//End CISP-2408
        let offerEngineRequestString = {
            'loanApplicationId': this.recordId,
            'currentScreen': 'Final Offer',
            'offerEMI': this.emi?this.emi.toString():'', // CISP-2408
        };
        console.log('response  ', JSON.stringify(offerEngineRequestString));
        let offerEngineMethod = doOfferEngineCallout;
        let offerEngineParams = { offerEngineRequestString: JSON.stringify(offerEngineRequestString) };
        if(this.leadSource === 'Hero'){//Hero CISH-02
            offerEngineMethod = doD2COfferEngineCallout;
            offerEngineParams = {loanId: this.recordId, applicantId: null, fromScreen:'insurance'};
        }
        await offerEngineMethod(offerEngineParams)

            .then(result => {
                const obj = (this.leadSource === 'Hero')  ? this.getParsedJSOND2C(JSON.parse(result)) : JSON.parse(result);
                console.log('Final Term', this.finalTermId);
                console.log('doOfferEngineCallout data ', obj);
                this.isSpinnerMoving = false;
                this.iconButtonCaptureUpload = true;
                this.imageUploadRedCross = false;
                const FinalTermFields = {};
                FinalTermFields[final_ID_FIELD.fieldApiName] = this.finalTermId;
                if(this.leadSource!='OLA'){FinalTermFields[EMI_Amount.fieldApiName] = obj.EMI;}
                if (obj.CRM_IRR != null) {
                    FinalTermFields[CRM_IRR.fieldApiName] = obj.CRM_IRR;
                }
                //CISP-2533
                if(this.leadSource !== 'Hero'){
                if(obj.Imputed_IRR_Offered != null) { 
                    FinalTermFields[Inputted_IRR.fieldApiName] = parseFloat(obj.Imputed_IRR_Offered);
                }
                // CISP-2533
                FinalTermFields[Gross_IRR.fieldApiName] = obj.Gross_IRR_Offered;
                FinalTermFields[Net_IRR.fieldApiName] = obj.Net_IRR_Offered;
                FinalTermFields[Net_IRR_DECIMAL.fieldApiName] = obj.Net_IRR_Offered;//CISP-20429
            }
            if(this.leadSource != 'Hero'){
                if(obj.TableCode){FinalTermFields[Table_Code.fieldApiName] = obj.TableCode;}
                if(obj.Interest_VersionNo){FinalTermFields[Interest_Version_No.fieldApiName] = obj.Interest_VersionNo;}
                if(obj.DR_PenalInterest){FinalTermFields[DR_Penal_Interest.fieldApiName] = obj.DR_PenalInterest;}
                if(obj.mclrRate){FinalTermFields[mclrRate.fieldApiName] = obj.mclrRate;} 
            }
                FinalTermFields[isNavigate.fieldApiName] = false;
                this.offerEngineFlag = true;
                this.updateRecordDetail(FinalTermFields);
            })
            .catch(error => {
                console.log('Error in Offer Engine API.', error);
                const evt = new ShowToastEvent({
                    title: 'Error',
                    message: "Offer Engine API Failed",
                    variant: 'error',
                });
                this.dispatchEvent(evt);
                this.navigateToNextStage();
            });
    }

    updateRecordDetail(fields) {
        const recordInput = { fields };
        console.log('before update ', recordInput);
        updateRecord(recordInput)
            .then(() => {
                console.log('inside update');
                this.navigateToNextStage();
            })
            .catch(error => {
                console.log('record update error', error);
                this.navigateToNextStage();
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

    //method for handling deviations and running deviation API on CLick of submit button.
    async doFicoDeviationCallout() {
        console.log('doFicoDeviation Callout is happening');
        await doFicoDeviationCallout({
            flag: 'NSTP',  //sri Integration changes
            loanAppId: this.recordId
        }).then(result => {
            console.log('deviation result :', result);
            if (result) {
				this.handleStpverify();
               
            }
        }).catch(error => {
            console.log("Error in Fico Deviatiion API => ", error);
            this.handleStpverify();
            const evt = new ShowToastEvent({
                title: 'Error',
                message: FICO_Deviation_ERROR_LABEL,
                variant: 'error',
            });
            this.dispatchEvent(evt);
        });
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
                        this.disabledHeightAndWeight = true;
                        console.log(' Line no 1779 => success');
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

    viewUploadViewFloater(){
        this.showFileUploadAndView = true;
    }
    closeUploadViewFloater(event){
        this.showFileUploadAndView = false;
    }

    disableEverything(){
        let allElements = this.template.querySelectorAll('*');
        allElements.forEach(element =>
            element.disabled = true
        );
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
            }
            else if (this.isPassengerVehicles && this.insuranceDetailsList.length > 0 && selectedInsPlanNameList.length > 0 && selectedInsPlanNameList.includes('LI_EMI') && selectedInsPlanNameList.includes('TATA_EMI')) {
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
        //CISP-9010-START
        if(this.productType == 'Two Wheeler' && event.target.checked)
        {
            let isOneProductSelected = false;
            this.insuranceDetailsList.forEach(element => {
                if (element.isPlanChecked) {
                    isOneProductSelected = true;
                }
            });
            if(isOneProductSelected)
            {
            event.target.isPlanChecked = false;
            event.target.checked = false;
            const newEvent = new ShowToastEvent({
                title: 'Warning',
                message: 'Only one insurance product is allowed for Two Wheeler',
                variant: 'warning',
                });
            this.dispatchEvent(newEvent);
            return;
            }
        }//CISP-9010-END
        let selectedPlanName = event.target.label;
        let insplanChecked = event.target.checked;
        let tempinsuranceDetailsList = this.insuranceDetailsList;
        this.insuranceDetailsList = [];
        for (let i = 0; i < tempinsuranceDetailsList.length; i++) {
            const element = tempinsuranceDetailsList[i];
            if (selectedPlanName === element.insProductName) {
                if (insplanChecked) {
                    element.isPlanChecked = true;
                    element.isFundedDisabled = this.activeTab == this.label.CoBorrower ? true : false;//CISP-7464
                    if(this.leadSource == 'D2C'){
                        element.isPlanCodeDisabled = false;
                    }else{
                    element.isPlanCodeDisabled = fixedInsPlan.includes(element.insProductName) ? true : false;
                    }
                    this.disabledHeightAndWeight = selectedPlanName == 'LI_EMI' ? false : this.disabledHeightAndWeight; 
                }else{
                    element.isPlanChecked = false;
                    if(this.leadSource == 'D2C'){
                        element.isFundedChecked = false;
                    }else{
                    element.isFundedChecked = false;//CISP-7464
                    }
                    element.isFundedDisabled = true;
                    element.insPlanCode = (fixedInsPlan.includes(element.insProductName) && this.leadSource != 'D2C') ? element.insPlanCode : '';//CISP-7464
                    element.insAmount = (element.insProductName === MOTOR && this.leadSource != 'D2C') ? element.insAmount : 0;//CISP-7464
                    element.isPlanCodeDisabled = true;
                    if(selectedPlanName == 'LI_EMI'){
                        this.disabledHeightAndWeight = true;
                        this.applicantHeight = '';
                        this.applicantWeight = '';
                    }
                }
            }
            this.insuranceDetailsList.push(element);
        }
        this.disableComputePremium = false;
        this.fundisabled = false;
        this.iconButton = false;
        this.isSubmitButtonDisabled = false;
        this.isComputePremiumAPIRun = false;
        if(!this.isPassengerVehicles && this.leadSource != 'D2C'){
            this.disableComputePremium = false;
            this.fundisabled = false;
            this.isConsentButtonDisabled = false;
        }
    }
     // Hero CISH-15 start
     getParsedJSOND2C(parsedJSON){
        let obj = {};
        obj.EMI = parsedJSON?.application?.offerEngineDetails?.offerEngineDecision?.displayEMI;
        obj.Tenure = parsedJSON?.application?.offerEngineDetails?.offerEngineDecision?.displayTenure;
        obj.Loan_Amt = parsedJSON?.application?.offerEngineDetails?.offerEngineDecision?.displayLoanAmt;
        obj.CRM_IRR = parsedJSON?.application?.offerEngineDetails?.offerEngineDecision?.displayCrmIrr;
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
        obj.NetPayOuts = parsedJSON?.application?.offerEngineDetails?.offerEngineDecision?.netPayOuts?.toString();
        return obj;
    }  // Hero CISH-15 end
    handleHeightAndWeight(event){
        if(event.target.name == 'height'){
            this.applicantHeight = event.target.value;
        }
        if(event.target.name == 'weight'){
            this.applicantWeight = event.target.value;
        }
        if(this.applicantHeight && this.applicantWeight){
            this.bmiValue = (parseFloat(this.applicantWeight) / ((parseFloat(this.applicantHeight) * parseFloat(this.applicantHeight)) / 10000)).toFixed(2);
        }
        this.disableComputePremium = false;
        this.fundisabled = false;
        this.iconButton = false;
        this.isSubmitButtonDisabled = false;
        this.isComputePremiumAPIRun = false;
    }
}