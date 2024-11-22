import { LightningElement, track, api,wire } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import LightningCardCSS from '@salesforce/resourceUrl/loanApplication';
import getApplicantId from '@salesforce/apex/IND_InsuranceDetailsLWC_controller.getApplicantId';
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

import existInsuranceDetailsMethod from '@salesforce/apex/IND_InsuranceDetailsLWC_controller.existInsuranceDetailsMethod';
//CREATED BY mohammad_shahkomeni
//import updateDeviationDetails from '@salesforce/apex/IND_InsuranceDetailsLWC_controller.updateDeviationDetails';
import CreditProcessing from '@salesforce/label/c.Credit_Processing';


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

import {NavigationMixin} from 'lightning/navigation';
import getProductTypeFromOpp from '@salesforce/apex/IND_InsuranceDetailsLWC_controller.getProductTypeFromOpp';
import fetchDataFromApplicatntObj from '@salesforce/apex/IND_InsuranceDetailsLWC_controller.fetchDataFromApplicatntObj';

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

export default class IND_LWC_ViewApplicationInsuranceDetails extends NavigationMixin(LightningElement) {
    @api recordId;
    @api creditval;
    @api responseReApisatus;
    @api callMsterRecords;
    @api activetab;
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
    @track isMotorDisabled = false;

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

    @track healthInsurancePlanComboboxDisabled;
    @track comboPlanComboboxDisabled;
    @track gpaPlanComboboxDisabled;

    @track isHealthInsuranceAmountFieldDisabled;
    @track isGPAInsuranceAmountFieldDisabled;
    @track isComboInsuranceAmountFieldDisabled;
    @track isMotorInsuranceAmountFieldDisabled;

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

    @api helathInuDisabled;
    @api combofunDisabled;
    @api gapfunDisabled;
    @api iconButton = false;
    @api issmscalloutsborrower = 1;
    @api issmscalloutscoborrower = 1;
    @api fundisabled = false;
    isPassengerVehicles=false;
    disableComputePremium=true;
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
    insuranceDetailsList = [];
    haveNoDataforTW =false;
    haveNoDataforPV = false;
    applicantHeight;
    applicantWeight;
    bmiValue;
    showheightAndWeight = false;

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
        await existInsuranceDetailsMethod({
            loanAppID: this.recordId,
            applicantId: this.applicantId
        }).then(result => {
            if (result.length > 0) {
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
                    }
                    this.insuranceDetailsList.push({
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
                this.iconButton = true;  
            }
            else{
                this.iconButton = false;
                this.haveNoDataforPV = this.isPassengerVehicles;
                this.haveNoDataforTW = !this.isPassengerVehicles;
            }
        }).catch(error => {
            console.error('error in existInsuranceDetailsMethod =>', error);
        });
    }
isD2CLead;
    async connectedCallback() {
        await getProductTypeFromOpp({ recordId: this.recordId })
        .then(result => {
            this.productType = result[0].Product_Type__c;
            if (this.productType === this.label.PassengerVehicles) {
                this.isPassengerVehicles=true;
            }
            this.isD2CLead = result[0].LeadSource == 'D2C' ? true : false;
            this.showheightAndWeight = (!this.isD2CLead && this.isPassengerVehicles);
        });
        await this.onloadexistInsuranceDetails();
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

    //sri
    renderedCallback() {
        loadStyle(this, LightningCardCSS);
        if (this.activeTab === this.label.CoBorrower) {
            this.disableMotorInsuranceSection = true;
        }
        if (this.activeTab === this.label.Borrower) {
            this.disableMotorInsuranceSection = false;
        }
        if (this.currentStage === this.label.CreditProcessing && this.activetab === 'View Application Details') {
            let allElements = this.template.querySelectorAll('*');
            allElements.forEach(element =>
                element.disabled = true
            );
            this.isEnableNext = true;
            if (this.template.querySelector('.next')) { this.template.querySelector('.next').disabled = false; }
        }
    }

    //Sri
    handleOnfinish(event) {
        const evnts = new CustomEvent('customcodevaleve', { detail: event });
        this.dispatchEvent(evnts);
    }

}