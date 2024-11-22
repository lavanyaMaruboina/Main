import { LightningElement, track, api,wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { loadStyle } from 'lightning/platformResourceLoader';
import LightningCardCSS from '@salesforce/resourceUrl/loanApplication';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import stpverify from '@salesforce/apex/IND_LWC_StpChecksCntrl.stpChecks';
import stpupdate from '@salesforce/apex/IND_LWC_StpChecksCntrl.stpVerify';
import getFundingAvailibility from '@salesforce/apex/IND_InsuranceDetailsLWC_controller.getFundingAvailibility';
import submitTFInsuranceDetails from '@salesforce/apex/IND_InsuranceDetailsLWC_controller.submitTFInsuranceDetails';
import finalSubmitTFInsuranceDetails from '@salesforce/apex/IND_InsuranceDetailsLWC_controller.finalSubmitTFInsuranceDetails';
import fetchApplicants from '@salesforce/apex/IND_InsuranceDetailsLWC_controller.fetchApplicants';
import fetchInsurance from '@salesforce/apex/IND_InsuranceDetailsLWC_controller.fetchInsurance';
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
import doInsuranceRecommendationCallout from '@salesforce/apexContinuation/IntegrationEngine.doInsuranceRecommendationCallout';
import tractorOfferEngineCallout from '@salesforce/apex/IntegrationEngine.tractorOfferEngine'; //SFTRAC-126
import ChangeVariantOfferCalled from '@salesforce/schema/Final_Term__c.ChangeVariantOfferCalled__c'; //SFTRAC-1526
import callInuranceRecAPI from '@salesforce/apex/IND_InsuranceDetailsLWC_controller.callInuranceRecAPI';
import doInsurancePremiumCallout from '@salesforce/apexContinuation/IntegrationEngine.doInsurancePremiumCallout';
import doSmsCallout from '@salesforce/apexContinuation/IntegrationEngine.doSmsGatewayCallout';
import getMotorInsurancePreimum from '@salesforce/apex/IND_InsuranceDetailsLWC_controller.getMotorInsurancePreimum';
import getMotorInsuranceFromLoanDetailsTf from '@salesforce/apex/IND_InsuranceDetailsLWC_controller.getMotorInsuranceFromLoanDetailsTf';
import existTFInsuranceDetailsMethod from '@salesforce/apex/IND_InsuranceDetailsLWC_controller.existTFInsuranceDetailsMethod';
import CreditProcessing from '@salesforce/label/c.Credit_Processing';
// END 
import Gross_IRR from '@salesforce/schema/Final_Term__c.Gross_IRR__c';
import final_ID_FIELD from '@salesforce/schema/Final_Term__c.Id';
import EMI_Amount from '@salesforce/schema/Final_Term__c.EMI_Amount__c';
import Net_IRR from '@salesforce/schema/Final_Term__c.Net_IRR__c';
import fetchOppourtunityData from '@salesforce/apex/IND_InsuranceDetailsLWC_controller.fetchOppourtunityData';
import deleteExistingPlansTf from '@salesforce/apex/IND_InsuranceDetailsLWC_controller.deleteExistingPlansTf';
import isL1InsuranceChanged from '@salesforce/apex/IND_InsuranceDetailsLWC_controller.isL1InsuranceChanged';

//Custom Labels
import detailsSaved from '@salesforce/label/c.detailsSaved';
//custom Labels Created By Nandini
import COMBO from '@salesforce/label/c.COMBO';
import HEALTH from '@salesforce/label/c.HEALTH';
import GPA from '@salesforce/label/c.GPA';
import MOTOR from '@salesforce/label/c.MOTOR';
import Retry_Exhausted from '@salesforce/label/c.Retry_Exhausted';

import isL1L2InsuranceSubmitted from '@salesforce/apex/IND_InsuranceDetailsLWC_controller.isL1L2InsuranceSubmitted';
import isCommunity from '@salesforce/apex/LwcLOSLoanApplicationCntrl.isCommunity';
import getLoanApplicationHistory from '@salesforce/apex/LwcLOSLoanApplicationCntrl.getLoanApplicationHistory';

//Custom Labels
import NOT_OPTED_INSURANCE_MSG_LABEL from '@salesforce/label/c.NOT_OPTED_INSURANCE_MSG';
import Sanction_Status_Message_LABEL from '@salesforce/label/c.Sanction_Status_Message';
//Applicant consent fields.
import APPLICANT_ID from '@salesforce/schema/Applicant__c.Id';
import APPLICATION_FORM_SMS_SENT from '@salesforce/schema/Applicant__c.Application_Form_SMS_Sent__c';
import APPLICANT_ApplicationConsentOTP from '@salesforce/schema/Applicant__c.Application_Consent_OTP__c';
import INSURANCE_CONSENT_SENT from '@salesforce/schema/Applicant__c.Insurance_Consent_OTP_Time__c';
import APPLICANT_INSURANCECONSENTOTP from '@salesforce/schema/Applicant__c.Insurance_Consent_OTP__c';
import accessLoanApplication from '@salesforce/apex/LwcLOSLoanApplicationCntrl.accessLoanApplication';
import getFinalTermData from '@salesforce/apex/IND_OfferScreenController.loadOfferScreenData';//CISP-2408
import {NavigationMixin} from 'lightning/navigation';
/*Sftrac 87 */
import {getRecord} from 'lightning/uiRecordApi';
import getBorrowerDocument from '@salesforce/apex/IND_InsuranceDetailsLWC_controller.getBorrowerDocument';

import OfferengineMinLoanAmount from '@salesforce/schema/Final_Term__c.OfferengineMinLoanAmount__c'; //SFTRAC-126
import OfferengineMaxLoanAmount from '@salesforce/schema/Final_Term__c.OfferengineMaxLoanAmount__c'; //SFTRAC-126
import Loan_Amount from '@salesforce/schema/Final_Term__c.Loan_Amount__c'; //SFTRAC-126
import OfferengineMinTenure from '@salesforce/schema/Final_Term__c.OfferengineMinTenure__c'; //SFTRAC-126
import OfferengineMaxTenure from '@salesforce/schema/Final_Term__c.OfferengineMaxTenure__c'; //SFTRAC-126
import Tenure from '@salesforce/schema/Final_Term__c.Tenure__c'; //SFTRAC-126
import Required_CRM_IRR from '@salesforce/schema/Final_Term__c.Required_CRM_IRR__c'; //SFTRAC-126
import Derived_CRM_IRR from '@salesforce/schema/Final_Term__c.Derived_CRM_IRR__c'; //SFTRAC-2301
import Bank_IRR from '@salesforce/schema/Final_Term__c.Bank_IRR__c'; //SFTRAC-126
import Offer_Agreement_Amount from '@salesforce/schema/Final_Term__c.Offer_Agreement_Amount__c'; //SFTRAC-126
import structuredFirstCall from '@salesforce/schema/Final_Term__c.Structured_L1_Call__c'; //SFTRAC-126
import emiRepaymentSchedule from '@salesforce/apex/IND_OfferScreenController.emiRepaymentSchedule'; 
import L1_Finance_Amount from '@salesforce/schema/Final_Term__c.L1_Finance_Amount__c'; 
import L1_Required_CRM_IRR from '@salesforce/schema/Final_Term__c.L1_Required_CRM_IRR__c'; 
import L1_Offer_Engine_Completed from '@salesforce/schema/Final_Term__c.L1_Offer_Engine_Completed__c'; 
import L1_Structured_Records_Submitted from '@salesforce/schema/Final_Term__c.L1_Structured_Records_Submitted__c'; 
import getPurchaseprice from '@salesforce/apex/IND_OfferScreenController.getPurchaseprice';  //SFTRAC-909
import calculateMonthlyEMI from '@salesforce/apex/StruturedEMICal.calculateMonthlyEMI';
import gradedRepaymentSchedule from '@salesforce/apex/EMI_CalculatorController.gradedRepaymentSchedule';
import deleteStructeredEMIRec from '@salesforce/apex/IND_InsuranceDetailsLWC_controller.deleteStructeredEMIRec'; //SFTRAC-1453

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

export default class LWC_TF_InsuranceDetails_Child extends NavigationMixin(LightningElement) {
    @api assetId;
    @api isRevokedLoanApplication;
    @api isCalledFromL1;
    @api isCalledFromL2;
    @track _isdisabled;
    @api set isdisabled(value){
        this._isdisabled = value;
    }
    get isdisabled(){
        return this._isdisabled;
    }
    _index;
    @api set index(value){
        this._index = value;
    }
    get index(){
        return this._index;
    }
    @track showNomineeSection;
    @track changedSomething = false;
    @track offerEngineMandatory = false;
    @api recordId;
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

    @track finalTermId;

    @api tabApplicantId;
    @track applicantId;
    @track _loadInsuranceSection;
    set loadInsuranceSection(value){
        this._loadInsuranceSection = value;
    }
    get loadInsuranceSection(){
        return this._loadInsuranceSection;
    }
    @track disableNomineeDetails = false;
    @track showBeneficiary = false;
    @track beneficiaryId;
    @track beneficiaryOptions = []; 

    @api productType;

    @api showUpload;
    @api showDocView;
    @api isVehicleDoc;
    @api isAllDocType;
    @track isSpinnerMoving = false;
    @track SpinnerMoving = false; 
    @track showFileUploadAndView = false;
    @track selectedProduct;
    @track selectedPlan;

    @api activeApplicantTab;
    @track activeTab;

    @track fundedPremiumValue;
    @track totalInsurancePayable;
    @track ltvWithInsurance;
    @track ltvWithoutInsurance;

    @track isSubmitButtonDisabled = true;
    isOfferEngineDisabled;

    @track showPopup;
    @track showPopupForAmount;

    @track popupCheckbox;
    @track popupCheckboxChecked;
    @api currentStage;
    isEnableNext = false;
    @api subStage;

    @track insuranceDetailsApi = [];
    leadSource;
    isNonIndividual = false;//SFTRAC-308
    customerType; //SFTRAC-308
    structuredL1 = false;
    showAmort;
    isStructured;
    isEnableStrTable = false;
    isStructuredDisabled;
    loanAgreementAmt;
    showStrButton = false;
    requiredCRMIRR;
    finalLoanAmount;
    showEquated = false;
    showCallOffer = false;
    isl1OfferEngineCompleted = false;
    isl1StructuredRecordsCreated = false;
    offerEngineFlag = false;
    firstEMI;
    secondEMI;
    cashFlows = [];
    showheightAndWeight = false;
    applicantHeight;
    applicantWeight;
    disabledHeightAndWeight=true;
    bmiValue;
    showheightAndWeight = false;
    disableComputePremium=false;

    /* Sftrac-87 */
    get nomineeLabel(){
        return this.activeTab === this.label.Borrower ? 'Nominee Details - Borrower' : this.activeTab !== this.label.Borrower ? `Nominee Details - ${this.activeTab}` : '';
    }

    get isTractorWithNomineeSection() {
        if (!this.isNonIndividual && this.showNomineeSection) {
            if (this.activeTab === this.label.Borrower && this.calculateAge(this.kycDobBorrower) < 55) {
                return true;
            } else if (this.activeTab !== this.label.Borrower && this.isPrimary && this.calculateAge(this.kycDobBorrower) > 55) {
                return true;
            }
        }else if(this.isNonIndividual && this.showNomineeSection){
            return true;
        }
        return false;
    }

    //SFTRAC-176 start
    get isTractor(){
        if (this.productType === 'Tractor')
            return true;
        return false;
    }
    //SFTRAC-176 end

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
    @api refreshNomineeDetails(){
        this.wireRunsOnlyOnce = false;
        refreshApex(this.applicantData);
    } 
    borrowerRelationshipOption = [{label: 'Father', value: 'FATHER'},{label: 'Mother', value: 'MOTHER'},{label: 'Son', value: 'SON'},{label: 'Daughter', value: 'DAUGHTER'},{label: 'Brother', value: 'BROTHER'},{label: 'Sister', value: 'SISTER'},{label: 'Husband', value: 'HUSBAND'},{label: 'Wife', value: 'WIFE'}]
    kycDobBorrower;

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
            this.showNomineeSection = true;;
        }
        else if (error) {}
    }

    @wire(getBorrowerDocument,{opportunityId: '$recordId'})
     wiredBorrowerDocument({error,data}){
        if (data){
            this.kycDobBorrower = data.KYC_DOB__c;
        }
        else if (error) {}

    }
    inputWrapperPopulator(){
        this.inputWrapper['borrowerName'] = { label: 'Borrower Name', value: this.applicantData.fields.Nominee_name__c.value };
        this.inputWrapper['borrowerDOB'] = { label: 'Borrower Dob', value: this.applicantData.fields.Nominee_DOB__c.value };
        this.inputWrapper['borrowerRelationship'] = { label: 'Borrower Relationship', value: this.applicantData.fields.Nominee_Relationship__c.value };
        this.inputWrapper['borrowerAddress'] = { label: 'Borrower Address', value: this.applicantData.fields.Nominee_address__c.value };
        this.isPrimary = this.applicantData.fields.IsPrimary__c.value;
        if(this.applicantData?.fields?.Nominee_name__c?.value && this.applicantData?.fields?.Nominee_DOB__c?.value && this.applicantData?.fields?.Nominee_Relationship__c?.value && this.applicantData?.fields?.Nominee_address__c?.value){
            this.disableNomineeDetails = true;
        }

    }

    handleInputFieldChange(event){
        this.inputWrapper[event.target.name].value = event.target.value;
        if(event.target.name == 'borrowerDOB'){
            var dateObj = new Date();
            var dd = dateObj.getDate();
            var mm = dateObj.getMonth() + 1;
            var yyyy = dateObj.getFullYear();
            var minDate = new Date(yyyy - 80, mm - 1, dd);
            var maxDate = new Date(yyyy - 18, mm - 1, dd);
    
            if (dd == 29 && mm == 2) {maxDate.setDate(28);}
            var minAge = minDate.toISOString().slice(0, 10);
            var maxAge = maxDate.toISOString().slice(0, 10);

            let inputField = this.template.querySelector(`[data-id=${event.currentTarget.dataset.id}]`);
            if (inputField) {
            let selectedDate = new Date(inputField.value).toISOString().slice(0, 10);
                if (selectedDate < minAge) {
                        inputField.setCustomValidity('Maximum age should be at most 80 years');
                        inputField.reportValidity();
                        return;
                } else if (selectedDate > maxAge) {
                        inputField.setCustomValidity('Minimum age should be at least 18 years');
                        inputField.reportValidity();
                        return;
                } else {
                        inputField.setCustomValidity('');
                        inputField.reportValidity();
                }
            }
        }
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
    @api issmscalloutsborrower = 1;
    @api issmscalloutscoborrower = 1;
    @api fundisabled = false;
    emi = 0;
    
    @track existingInsDetailList = [];
    @track insuranceDetailsList = [];
    isComputePremiumAPIRun = true;
    comboLIPremium = 0;
    comboEMIPremium = 0;
    eMIPassedinAPI = 0;
    isEnableBeneficiaryNext = false;
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
        this.SpinnerMoving = true;
        await doInsurancePremiumCallout({
            applicantId: applicantId,
            Ins_Product: JSON.stringify(Ins_Product),
            Plan_Code: 'Plan',
            loanAppId: this.recordId,
            assetId: this.assetId
        }).then(result => {
            console.log("line 285 ==> ", result);
            var getResponse = JSON.parse(result);
            console.log('status flag of 2nd api', getResponse.Status_Flag);
            // console.log('API2...' + JSON.stringify(getResponse));

            if (getResponse.Status_Flag == 'Failure') {
                if(Ins_Product && Ins_Product.length > 0){
                    this.getPreimumfromMaster(Ins_Product[0].Ins_Product, Ins_Product[0].Plan_Code);
                }
            } else if(getResponse && getResponse.Premium_Details && getResponse.Premium_Details.length > 0){
                console.log('FROM API2... Amount' + getResponse.Premium_Details);
                for (let i = 0; i < getResponse.Premium_Details.length; i++) {
                    const product = getResponse.Premium_Details[i];
                    let tempinsuranceDetailsList = this.insuranceDetailsList;
                    this.insuranceDetailsList = [];
                    for (let i = 0; i < tempinsuranceDetailsList.length; i++) {
                        const element = tempinsuranceDetailsList[i];
                        if (element.isPlanChecked && element.insProductName === product.Ins_Product.toUpperCase()) {
                            element.insAmount = product.Premium ? product.Premium : 0;
                            if (element.insProductName ==='LI_EMI' || element.insProductName ==='TATA_EMI' || element.insProductName == 'COMBO' || element.insProductName == 'LI_SHUBH' || element.insProductName == 'LI' || element.insProductName == 'HEALTH') {
                                this.comboLIPremium = product.Combo_LI_Premium ? product.Combo_LI_Premium : 0;
                                this.comboEMIPremium = product.Combo_EMI_Premium ? product.Combo_EMI_Premium : 0;
                                if (element.insProductName ==='LI_EMI' || element.selectedPlan === 'LI_EMI'){
                                    this.eMIPassedinAPI = this.emi;
                                }
                            }
                        }
                        this.insuranceDetailsList.push(element);
                    }
                }
                this.isComputePremiumAPIRun = true;
            }
            // console.log('result of 2nd api=>', result);
            this.SpinnerMoving = false;
        }).catch(error => {
            console.log('ERROR... API2' + JSON.stringify(error));
            if(Ins_Product && Ins_Product.length > 0){
                this.getPreimumfromMaster(Ins_Product[0].Ins_Product, Ins_Product[0].Plan_Code);
            }
            this.SpinnerMoving = false;
        });
        this.SpinnerMoving = false;
    }
    async getAPIRecoPreimumResponse(result) {
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
            "Motor_Expiry_Date": result.Motor_Expiry_Date,
            "Motor_Premium": result.Motor_Premium,
            "Periodicity": result.Periodicity //SFTRAC-629
        }
        this.isSpinnerMoving = true;
        await doInsuranceRecommendationCallout({
            insuranceRecommendationString: JSON.stringify(recapi)
        }).then(results => {
            this.isSpinnerMoving = false;
            this.insuranceDetailsApi = JSON.parse(results).Ins_Product;
            this.getIns_ProdutcsMthod();
        }).catch(error => {
            this.isSpinnerMoving = false;
            this.dispatchEvent(ShowToastEvent({
                title: "Recommendation API failed",
                message: error?.body?.message,
                variant: 'error',
            }));
            this.getIns_ProdutcsMthod();
        });
        this.isSpinnerMoving = false;
    }

    @track insuranceSubmitted = false;
    @track insuranceSubmittedL2 = false;
    async onloadexistInsuranceDetails() {
        let result = await isL1L2InsuranceSubmitted({'assetId' : this.assetId });
        if(result){
            this.insuranceSubmitted = result.L1_Insurance_Submitted__c == true ? true : false;
            this.insuranceSubmittedL2 = result.L2_Insurance_Submitted__c == true ? true : false;
        }
        await existTFInsuranceDetailsMethod({
            loanAppID: this.recordId,
            applicantId: this.applicantId,
            assetId: this.assetId
        }).then(result => {
            if (result.length > 0) {
                result.forEach(getInsProdObj => {
                    console.log('getInsProdObj -- > ', getInsProdObj);
                    this.currentStageName = getInsProdObj.Stage;
                    this.subStage = getInsProdObj.Sub_Stage;
                    this.totalInsurancePayable = getInsProdObj.totalInsurancePayable;
                    this.ltvWithInsurance = getInsProdObj.ltvWithInsurance;
                    this.ltvWithoutInsurance = getInsProdObj.ltvWithoutInsurance;
                    this.fundedPremiumValue = getInsProdObj.premiumFunded;
                    if(getInsProdObj.Ins_Product?.toUpperCase() === 'LI' || getInsProdObj.Plan_Code?.toUpperCase() == 'LI_EMI'){
                        this.applicantHeight = getInsProdObj.height ? parseFloat(getInsProdObj.height) : null;
                        this.applicantWeight = getInsProdObj.weight ? parseFloat(getInsProdObj.weight) : null;
                        this.bmiValue = getInsProdObj.bmi  ? parseFloat(getInsProdObj.bmi) : null;
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
                if(this.insuranceSubmitted == true){
                    if (this.existingInsDetailList.length > 0) {
                        this.insuranceDetailsList = this.existingInsDetailList;
                        
                    }
                    this.disabledHeightAndWeight = true;
                    console.log('insuranceDetailsList --> ', this.insuranceDetailsList);
                    this.disableEverything();
                }else{
                    this.callAPIRecomMethod();
                }
            }else if(this.currentStageName === this.label.CreditProcessing && this.subStage === 'Insurance'){ 
                if(this.insuranceSubmittedL2 == true){               
                    if (this.existingInsDetailList.length > 0) {
                        this.insuranceDetailsList = this.existingInsDetailList;
                        
                    }
                    this.disabledHeightAndWeight = true;
                    this.disableEverything();
                }else if(this.existingInsDetailList && this.existingInsDetailList.length > 0){
                    this.callAPIRecomMethod();
                }else if(this.insuranceSubmitted == true){
                    this.insuranceSubmitted = result;
                    this.callAPIRecomMethod();
                }else{
                    this.callAPIRecomMethod();
                    this.disableEverything();
                }
            }else{
                if (this.existingInsDetailList.length > 0) {
                    this.insuranceDetailsList = this.existingInsDetailList;
                    
                }
                this.disabledHeightAndWeight = true;
                this.disableEverything();
            }
        }).catch(error => {
        });
    }

    disableEverything(){
        let allElements = this.template.querySelectorAll('*');
        allElements.forEach(element =>
            element.disabled = true
        );
    }

    handleEvent(event){
        this.isOfferEngineDisabled = event.detail;
        const FinalTermsFields = {};
        FinalTermsFields[final_ID_FIELD.fieldApiName]=this.finalTermId;
        FinalTermsFields[L1_Structured_Records_Submitted.fieldApiName]=true;
        this.updateRecordDetails(FinalTermsFields);

    }
    //calling Recommended API method
    async callAPIRecomMethod() {
        await callInuranceRecAPI({
            appType: this.activeTab,
            loanAppID: this.recordId,
            assetId: this.assetId,
            applicantId: this.applicantId
        }).then(result => {
            this.getAPIRecoPreimumResponse(result);
        }).catch(error => {
            this.dispatchEvent(ShowToastEvent({
                title: "Recommendation API failed!",
                message: error?.body?.message,
                variant: 'error',
            }));
            this.getIns_ProdutcsMthod();
        });
    }
    vehicleTypeDetail;
    async connectedCallback() {
        this.SpinnerMoving = true;////CISP-519
        if(this.isCalledFromL2){
            this.offerEngineMandatory = await isL1InsuranceChanged({'vehicleId' : this.assetId});
        }
        await fetchOppourtunityData({ loanApplicantionId: this.recordId })
        .then(result => {
            this.currentStageName = result[0].StageName;
            this.lastStage =  result[0].LastStageName__c;
            this.subStage =  result[0].Sub_Stage__c;
            this.leadSource =  result[0].LeadSource;// D2C changes
            this.productType = result[0].Product_Type__c;
            this.vehicleTypeDetail = result[0].Vehicle_Type__c;
            //SFTRAC-308 starts
            this.customerType = result[0].Customer_Type__c;
            if(this.customerType =='Non-Individual' && this.productType == 'Tractor'){
                let benficaryOptions = []
                if(result[0].Applicants__r && result[0].Applicants__r.length > 0){
                    const element = result[0].Applicants__r[0];
                    if(element.IsPrimary__c){
                        benficaryOptions.push({label : element.Name , value : element.Id})
                    }
                }
                this.beneficiaryOptions = benficaryOptions;
                if(this.beneficiaryOptions && this.beneficiaryOptions.length > 0){
                    this.beneficiaryId = this.beneficiaryOptions[0].value;
                    this.applicantId = this.beneficiaryId;
                }
                this.isNonIndividual = true;
            }
            console.log('this.isNonIndividual ',this.isNonIndividual);
            if(this.isNonIndividual && this.isCalledFromL2){
                this.isEnableBeneficiaryNext = true;
                if (this.template.querySelector('.ninext')) { this.template.querySelector('.ninext').disabled = false; }
            }
            if(this.isNonIndividual){
                this.showBeneficiary = true;
                this.activeTab = 'Beneficiary';
                if(this.beneficiaryId){
                    this.beneficiaryeHandler(true);
                }
            }else{
                this.activeTab = this.activeApplicantTab;
                this.applicantId = this.tabApplicantId;
                this.loadInsuranceSection = true;
                refreshApex(this.applicantData);
                this.onloadexistInsuranceDetails();
            }
            this.showheightAndWeight = (this.leadSource != 'D2C' && this.isTractor);
            this.SpinnerMoving = false;////CISP-519
        })
        .catch(error => {});           
        
        this.popupCheckboxChecked = true;
        await getFinalTermData({ loanApplicationId: this.recordId,vehicleId: this.assetId })
            .then((data) => {
                if (data) {
                    console.log('data-----'+JSON.stringify(data));
                    let parsedData = JSON.parse(data);
                    this.installmentType = parsedData.installmentType;
                    this.structuredL1 = parsedData.structuredL1Call;
                    this.loanAgreementAmt = parsedData.loanAgreementAmount;
                    this.isl1OfferEngineCompleted = parsedData.isL1OfferEngineCompleted;
                    this.isl1StructuredRecordsCreated = parsedData.isL1StructuredRecordsCreated;
                    this.finalLoanAmount = Number(parsedData.loanAmount) + Number(parsedData.totalFundedPremium);
                    this.requiredCRMIRR = parsedData.requriedCRMIRR;
                    this.dealDate = parsedData.dealDate;
                    this.tenure = parsedData.tenure;
                    this.firstEMI = parsedData.firstEMI; 
                    this.secondEMI = parsedData.secondEMI;
                    this.advanceEMI = parsedData.advanceEmi;
                    if(this.structuredL1 == true && this.isCalledFromL1){
                        this.isEnableStrTable = true;
                        this.isStructuredDisabled = true;
                    }
                    if(this.installmentType == 'Structured' && this.isCalledFromL1){
                        this.showStrButton = true;
                        this.isOfferEngineDisabled = true;
                        if(this.isl1StructuredRecordsCreated && !this.isl1OfferEngineCompleted){
                            this.isOfferEngineDisabled = false;
                        }
                    }
                    if(this.isCalledFromL1){
                        this.showCallOffer = true;
                    }
                    if(this.isCalledFromL2){
                    this.finalLoanAmount = Number(parsedData.loanAmount) + Number(parsedData.totalFundedPremium);
                    this.requiredCRMIRR = parsedData.requriedCRMIRR;
                    this.ChangeVariantOfferCalled = parsedData.isChangeVariantOfferCalled //SFTRAC-1526
                    }
                    this.installmentFrequency = parsedData.installmentFrequency;
                    switch (this.installmentFrequency){
                        case 'Monthly':
                            this.frequency = 1;
                            break;
                        case 'bi-monthly':
                            this.frequency = 2;
                            break;
                        case 'Quarterly':
                            this.frequency = 3;
                            break;
                        case 'Half yearly':
                            this.frequency = 6; 
                            break;
                        default:
                            this.frequency = 1;
                            break;           
                    }
                
                    if(this.isTractor){
                        this.finalTermId = parsedData.getrecordId;
                    }
                    if(this.installmentType == 'Structured'){
                        this.isStructured = true;
                    }
                    if(!this.insuranceSubmitted && this.isl1OfferEngineCompleted && this.isCalledFromL1){
                        this.isSubmitButtonDisabled = false;
                    }else if(this.isCalledFromL2 && !this.insuranceSubmittedL2){                        
                        this.isSubmitButtonDisabled = false;
                    }
                   this.emi = parsedData.emi ? parseFloat(parsedData.emi) : 0;
                }
            })
            .catch(error => {
                console.log('error in getFinalTermData => ', error);
            }); 
                    if(this.isCalledFromL1 && this.isl1OfferEngineCompleted && this.installmentType == 'Equated'){ 
                        this.isOfferEngineDisabled = true;
                        /*this.finalLoanAmount = Number(parsedData.loanAmount) + Number(parsedData.totalFundedPremium);
                        this.requiredCRMIRR = parsedData.requriedCRMIRR;
                        this.dealDate = parsedData.dealDate;
                        this.tenure = parsedData.tenure;
                        this.firstEMI = parsedData.firstEMI; 
                        this.secondEMI = parsedData.secondEMI;
                        this.advanceEMI = parsedData.advanceEmi; */
                        emiRepaymentSchedule({principal:this.finalLoanAmount,irr:this.requiredCRMIRR,loanDate:this.dealDate,increment:this.tenure,frequency:this.frequency,repaymentDate:this.firstEMI,secondEMI:this.secondEMI,advanceEMI: this.advanceEMI}).then((result) => {
                            this.totalPaybleEMI = result;
                            this.showEquated = true;
                            this.SpinnerMoving = false;
                        })
                        .catch((error) => {
                            this.SpinnerMoving = false;
                        });
                }
                if(this.isCalledFromL1 && this.isl1OfferEngineCompleted && this.installmentType == 'Structured'){ 
                    this.isOfferEngineDisabled = true;
                    /*this.finalLoanAmount = Number(parsedData.loanAmount) + Number(parsedData.totalFundedPremium);
                    this.requiredCRMIRR = parsedData.requriedCRMIRR;
                    getOfferResponse({loanApplicationId:this.recordId,vehicleId:this.assetId}).then((result)=> {console.log('rst----'+JSON.stringify(result));
                    if(result.contentVersion == true){
                        this.plainText = atob(result.response);
                    }else{
                        this.plainText = result.response;
                    }
                        const parsedResponse = JSON.parse(this.plainText);
                        let amortSch = parsedResponse?.application?.offerEngineDetails?.offerEngineDecision?.amortizationSchedule;
                        this.totalPaybleEMI = amortSch;
                        this.showAmort = true;                        
                    }
                    ); */
                    await calculateMonthlyEMI({loanApplicationId:this.recordId,vehicleID:this.assetId}).then((result)=>{
                        this.cashFlows = result;
                    });
                    await gradedRepaymentSchedule({cashFlows:this.cashFlows,principal:this.finalLoanAmount,irr:this.requiredCRMIRR,loanDate:this.dealDate,increment:this.tenure,day:0,frequency:this.frequency,repaymentDate:this.firstEMI,secondEMI:this.secondEMI}).then((result)=>{
                        this.totalPaybleEMI = result;
                        this.showEquated = true;
                        this.SpinnerMoving = false;
                    }).catch((error) => {
                        this.SpinnerMoving = false;
                    });
            
                    
        this.callAccessLoanApplication();
        if(this.isdisabled){
            this.disableEverything();
            this.SpinnerMoving = false;
        }
        if(this.isTractor){
            let getResponse = await getPurchaseprice({ loanApplicationId: this.recordId, 'vehicleId' : this.assetId });
            this.vehiclePurchaseprice = parseInt(getResponse, 10);
        }      
    }
    }
    callAccessLoanApplication(){
        accessLoanApplication({ loanId: this.recordId , stage: 'Insurance Details'}).then(response => {
            if(!response){ 
                this.disableEverything();
            }
          }).catch(error => {
          });
    }

    @track motorIns = {};
    async getIns_ProdutcsMthod() {
        let motorIns = {}; 
        let addInsuranceDetailsList = [];
        await getMotorInsuranceFromLoanDetailsTf({
            loanAppID: this.recordId,
            vehicleId: this.assetId
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
                    isAmountFieldDisabled : true,
                    insAmount : result?.Premium!=null?result?.Premium:0,
                    isFundedChecked : result.Funding_Option == 'Y' ? true : false,
                    isFundedDisabled : true
                };
                this.motorIns = {...motorIns};
                motorIns.insAmount = 0;
                motorIns.isFundedChecked = false;
            }
        }).catch(error => {});
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
                }else{
                    addInsuranceDetailsList.push({
                        insProductName : getObj.Ins_Product,
                        isPlanChecked : false,
                        isPlanCheckDisabled : (this.activeTab !== this.label.Borrower && this.activeTab !== 'Beneficiary') && !PlanforCoborrower.includes(getObj.Ins_Product) ? true : false,
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
        if(addInsuranceDetailsList.length >= 0 && !addInsuranceDetailsList.find(opt => opt.insProductName === MOTOR)){
            if(JSON.stringify(motorIns) !== '{}'){
                addInsuranceDetailsList.push(motorIns);
            }
        }
        if(this.existingInsDetailList.length > 0){
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
                        element.isFundedDisabled = false;
                        if(element.insProductName == MOTOR){
                            element.isAmountFieldDisabled = false;
                            this.motorIns.isFundedChecked = ele.isFundedChecked;
                            this.motorIns.insAmount = ele.insAmount;
                        }
                    }
                });
            addInsuranceDetailsList.push(element);
            });
        }
        this.insuranceDetailsList = addInsuranceDetailsList;
            
        this.isSpinnerMoving = false;
    }
    async handleStructuredEMI(){
        this.SpinnerMoving = true;
        if(this.insuranceDetailsList && this.insuranceDetailsList.length > 0 && this.insuranceDetailsList.find(opt => opt.isPlanChecked === true) && this.changedSomething){
            const event = new ShowToastEvent({
                title: 'Error',
                message: 'You have changed something. Please Click on funding availability!',
                variant: 'error',
            });
            this.dispatchEvent(event);
            this.isSpinnerMoving = false;
            this.SpinnerMoving = false;
            return;
        }
        if (this.insuranceDetailsList && this.insuranceDetailsList.length > 0 && !this.insuranceDetailsList.find(opt => opt.isPlanChecked === true)) {
            this.fundedPremiumValue = null;
            this.totalInsurancePayable = null;
            this.ltvWithInsurance = null;
            this.ltvWithoutInsurance = null;
            await deleteExistingPlansTf({'loanApplicationId':this.recordId,'vehicleId' : this.assetId,'isCalledFromL2':this.isCalledFromL2});
            if(this.isCalledFromL2){
                this.offerEngineMandatory = true;
            }
        }
        if(((parseInt(this.ltvWithInsurance) > 95) || (parseInt(this.ltvWithoutInsurance) > 90))  ){
                
            const evt = new ShowToastEvent({
                title: "Error",
                message: 'LTV With Insurance can not be more than 95% and without Inurance can not be more than 90%',
                variant: 'Error',
            });
            this.dispatchEvent(evt);
            this.isSpinnerMoving = false;
            this.SpinnerMoving = false;
            return;
        } else {
            let isvehiclePurchasepriceCheck = await this.checkPurchaseprice();
            if(isvehiclePurchasepriceCheck){
                this.isSpinnerMoving = false;
                this.SpinnerMoving = false;
                return;
            }
        }
        let data = await getFinalTermData({ loanApplicationId: this.recordId, vehicleId: this.assetId });
        if (data) {
            let parsedData = JSON.parse(data);
            this.totalFundedPremium = Number(parsedData.totalFundedPremium);
        }
       let result = await this.handleTFOfferEngineCalloutHelper(false); 
       if(!result){this.SpinnerMoving = false;return;}
        console.log('loan agreement amount----'+this.loanAgreementAmt);
        if(this.loanAgreementAmt != '' && this.loanAgreementAmt != undefined && this.loanAgreementAmt != null){
        this.isEnableStrTable = true;
        this.isStructuredDisabled = true;
       // this.isOfferEngineDisabled = false;
        }
        this.SpinnerMoving = false
    }
    //methos for handling plan when user changes the plan.
    handlePlanChange(event) {
        this.changedSomething = true;
        let selectedInsPlan = event.target.name;
        let insPlanvalue = event.target.value;
        let tempinsuranceDetailsList = this.insuranceDetailsList;
        this.insuranceDetailsList = [];
        for (let i = 0; i < tempinsuranceDetailsList.length; i++) {
            const element = tempinsuranceDetailsList[i];
            if (element.insProductName === selectedInsPlan) {
                element.insPlanCode = insPlanvalue;
                element.insAmount = element.insPlanOptions.find(opt => opt.value === insPlanvalue).insAmount ? element.insPlanOptions.find(opt => opt.value === insPlanvalue).insAmount : 0;
                if(element.insProductName == 'LI' || element.insPlanCode == 'LI_EMI'){
                    this.disabledHeightAndWeight = false;
                    this.applicantHeight = '';
                    this.applicantWeight = '';
                    this.bmiValue = '';
                }else{
                    this.disabledHeightAndWeight = true;
                    this.applicantHeight = '';
                    this.applicantWeight = '';
                    this.bmiValue = '';
                }
            }
            this.insuranceDetailsList.push(element);
        }
        
        
        this.isComputePremiumAPIRun = false;
    }

    // SFTRAC-176 Start
    handleStakeHolder(event) {
        let selectedInsPlan = event.currentTarget.dataset.name;
        let insStakeHolderValue = event.target.value;
        let tempinsuranceDetailsList = this.insuranceDetailsList;
        this.insuranceDetailsList = [];
        for (let i = 0; i < tempinsuranceDetailsList.length; i++) {
            let element = tempinsuranceDetailsList[i];
            if (element.insProductName === selectedInsPlan) {
                element.insStakeHolder = insStakeHolderValue;
            }
            this.insuranceDetailsList.push(element);
        }
    }
    hanldeAmountValueChange(event) {
        this.changedSomething = true;
        this.isComputePremiumAPIRun = false;
        this.popupCheckbox = false;
        this.showPopupForAmount = true;
        this.popupCheckboxChecked = true;
        let selectedPlanName = event.target.name;
        let enteredAmount = event.target.value;
        this.insuranceDetailsList.find(opt => opt.insProductName === selectedPlanName).insAmount = enteredAmount;
    }

    //Handler for is funded toggle change.
    handleIsFundedToggle(event) {
        this.changedSomething = true;
        this.isComputePremiumAPIRun = false;
        
        let selectedPlanName = event.target.name;
        let insFundedChecked = event.target.checked;
        this.insuranceDetailsList.find(opt => opt.insProductName === selectedPlanName).isFundedChecked = insFundedChecked;
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
        this.SpinnerMoving = true;
        let selectedInsPlanNameList =[];
        if (this.insuranceDetailsList.length > 0) {
            this.insuranceDetailsList.forEach(element => {
                if(element.isPlanChecked){
                    if(element.insPlanCode == 'LI_EMI'){
                        selectedInsPlanNameList.push(element.insPlanCode);
                    }else{
                        selectedInsPlanNameList.push(element.insProductName);
                    }
                }
            });
        }
        if (this.insuranceDetailsList.length > 0 && !this.insuranceDetailsList.find(opt => opt.isPlanChecked === true)) {
            
            const event = new ShowToastEvent({
                title: 'Info',
                message: NOT_OPTED_INSURANCE_MSG_LABEL,
                variant: 'info',
            });
            this.dispatchEvent(event);
            this.SpinnerMoving = false;
            return;
        }
        else if(!this.isComputePremiumAPIRun){
            
            const event = new ShowToastEvent({
                title: 'Error',
                message: 'You have changed something. Please Compute Premium first!',
                variant: 'error',
            });
            this.dispatchEvent(event);
            this.SpinnerMoving = false;
            return;
        }
        else if(this.leadSource != 'D2C' && this.insuranceDetailsList.length > 0 && selectedInsPlanNameList.length > 0 && (selectedInsPlanNameList.includes('LI') || selectedInsPlanNameList.includes('LI_EMI')) && (!this.applicantHeight || !this.applicantWeight)){
            const event = new ShowToastEvent({
                title: 'Error',
                message:'You have choose LI/LI_EMI so please enter Height and Weight',
                variant: 'error',
            });
            this.dispatchEvent(event);
            this.SpinnerMoving = false;
            return;            
        }
        else if(this.leadSource != 'D2C' && this.insuranceDetailsList.length > 0 && selectedInsPlanNameList.length > 0 && (selectedInsPlanNameList.includes('LI') || selectedInsPlanNameList.includes('LI_EMI')) && this.applicantHeight && this.applicantWeight && this.bmiValue && (this.bmiValue <18 || this.bmiValue >30)){
            const event = new ShowToastEvent({
                title: 'Error',
                message: 'User is not eligible for LI/LI_EMI product. Please choose any other product',
                variant: 'error',
            });
            this.dispatchEvent(event);
            this.SpinnerMoving = false;
            return;
        }
        else if(!this.changedSomething){
            const event = new ShowToastEvent({
                title: 'Error',
                message: 'You have\'t changed anything. Please click on submit button to submit this screen!',
                variant: 'error',
            });
            this.dispatchEvent(event);
            this.SpinnerMoving = false;
            return;
        }
        else {
            const selectedInsuranceDetails = {
                loanApplicationId: this.recordId,
                assetId: this.assetId,
                insProductDetails : []
            };
            for (let i = 0; i < this.insuranceDetailsList.length; i++) {
                const element = this.insuranceDetailsList[i];
                if (element.isPlanChecked) {
                    const selectedPlanObj = {
                        selectedProduct: element.insProductName,
                        selectedPlan: element.insPlanCode,
                        isFunded: element.isFundedChecked,
                        assetId: this.assetId,
                        premium : element.insAmount == '' ? 0 : element.insAmount ? parseFloat(element.insAmount) : 0,
                        comboLIPremium : (element.insProductName ==='LI_EMI' || element.insProductName ==='TATA_EMI' || element.insProductName == 'COMBO' || element.insProductName == 'LI_SHUBH' || element.insProductName == 'LI' || element.insProductName == 'HEALTH') ? parseFloat(this.comboLIPremium) : 0,
                        comboEMIPremium : (element.insProductName ==='LI_EMI' || element.insProductName ==='TATA_EMI' || element.insProductName == 'COMBO' || element.insProductName == 'LI_SHUBH' || element.insProductName == 'LI' || element.insProductName == 'HEALTH') ? parseFloat(this.comboEMIPremium) : 0,
                        eMIPassedinAPI : (element.insProductName ==='LI_EMI' || element.insPlanCode === 'LI_EMI') ? this.eMIPassedinAPI ? parseFloat(this.eMIPassedinAPI) : 0 : 0,
                    };
                    selectedInsuranceDetails.insProductDetails.push(selectedPlanObj);
                }
            }
            console.log(selectedInsuranceDetails);
            this.fundedPremiumValue = null;
            this.totalInsurancePayable = null;
            this.ltvWithInsurance = null;
            this.ltvWithoutInsurance = null;

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
                        //Enabling the submit button.
                        //this.isSubmitButtonDisabled = false;
                        //this.isOfferEngineDisabled = false;

                        this.handleConcentCall('fundingAvailability').then(result=>{
                            if(result){
                                this.changedSomething = false;
                                if(this.isCalledFromL2){
                                    this.offerEngineMandatory = true;
                                }
                                this.SpinnerMoving = false;
                            }
                        }).catch(error=>{});
                        
                    } else if (!response.responseStatus) {
                        this.showPopup = true;
                        this.fundedPremiumValue = response.totalPremiumFunded;
                        this.SpinnerMoving = false;
                        
                    } else {
                        this.showPopup = false;
                        this.fundedPremiumValue = response.totalPremiumFunded;
                       // this.isSubmitButtonDisabled = false;
                       // this.isOfferEngineDisabled = false;
                       this.SpinnerMoving = false;                        
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
                    this.SpinnerMoving = false;
                });
        }
    }
    
    insuranceMap = new Map();
    finalInsuranceData;

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
    async sendInsuranceConsentcall(appid, flag) {
        try{

            let otpValue;
            const tDatetime = new Date().toISOString();
            let fields = {};
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
                fields[APPLICANT_INSURANCECONSENTOTP.fieldApiName] = String(insRandNum);
            }
    
            const recordInput = { fields };
            let res = await updateRecord(recordInput)
            if(res){
                let smsRequestString = {
                    'applicantId': appid,
                    'loanApplicationId': this.recordId,
                    'flag': flag,
                    'otpForInsConsent': otpValue
                };
    
                let smsresult =  await doSmsCallout({
                    smsRequestString: JSON.stringify(smsRequestString)
                });
                if (smsresult == 'SUCCESS') {
                    const event = new ShowToastEvent({
                        title: 'Success',
                        message: this.label.Consent_Sent_Successfully,
                        variant: 'success',
                    });
                    this.dispatchEvent(event);
                    
                    
                }
            }
        }catch(error){
            if(flag == 'INC'){
                
                
                const evt = new ShowToastEvent({
                    title: "Error",
                    message: 'Something went wrong!',
                    variant: 'error',
                });
                this.dispatchEvent(evt);
            }
        }
    }
   /* handlebeneficiaryNext(){
        const oppFields = {};
        oppFields[OPP_ID_FIELD.fieldApiName]=this.recordId;
        oppFields[SUB_STAGE_FIELD.fieldApiName]= 'Risk Summary';
        this.updateRecordDetails(oppFields);
        window.location.reload();
    } */


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

    async handleOfferEngine() {
        this.SpinnerMoving = true;
        //SFTRAC-172 start
        if(this.productType === 'Tractor'){
            if (this.insuranceDetailsList && this.insuranceDetailsList.length > 0 && !this.insuranceDetailsList.find(opt => opt.isPlanChecked === true)) {
                this.fundedPremiumValue = null;
                this.totalInsurancePayable = null;
                this.ltvWithInsurance = null;
                this.ltvWithoutInsurance = null;
                await deleteExistingPlansTf({'loanApplicationId':this.recordId,'vehicleId' : this.assetId,'isCalledFromL2':this.isCalledFromL2});
                if(this.isCalledFromL2){
                    this.offerEngineMandatory = true;
                }
            }
            if((parseInt(this.ltvWithInsurance) > 95) || (parseInt(this.ltvWithoutInsurance) > 90)){
                const evt = new ShowToastEvent({
                    title: "Error",
                    message: 'LTV With Insurance can not be more than 95% and without Inurance can not be more than 90%',
                    variant: 'Error',
                });
                this.dispatchEvent(evt);
                this.SpinnerMoving = false;
                return;
            }else{
                if(this.insuranceDetailsList && this.insuranceDetailsList.length > 0 && this.insuranceDetailsList.find(opt => opt.isPlanChecked === true) && this.changedSomething){
                    const event = new ShowToastEvent({
                        title: 'Error',
                        message: 'You have changed something. Please Click on funding availability!',
                        variant: 'error',
                    });
                    this.dispatchEvent(event);
                    this.SpinnerMoving = false;
                    return;
                }
                    //this.isOfferEngineDisabled = true;
                   // this.isSubmitButtonDisabled = false;
                    let isvehiclePurchasepriceCheck = await this.checkPurchaseprice();
                    if (isvehiclePurchasepriceCheck == false) {
                        let result = await this.handleTFOfferEngineCalloutHelper(true); // Update to call TF offer Engine API SFTRAC-126
                        if(!result){this.SpinnerMoving = false;return;}
                        if(this.offerEngineFlag){
                    await getFinalTermData({ loanApplicationId: this.recordId,vehicleId: this.assetId }).then((data) => {
                    if (data) {
                    let parsedData = JSON.parse(data);
                   this.finalLoanAmount = Number(parsedData.loanAmount) + Number(parsedData.totalFundedPremium);
                    this.dealDate = parsedData.dealDate;
                    this.tenure = parsedData.tenure;
                    this.installmentType = parsedData.installmentType;
                    this.installmentFrequency = parsedData.installmentFrequency;
                    this.firstEMI = parsedData.firstEMI; 
                    this.secondEMI = parsedData.secondEMI; 
                    this.advanceEMI = parsedData.advanceEmi;
                    this.crmIRR = parsedData.crmIRR;
                    this.requiredCRMIRR = parsedData.requriedCRMIRR;
                    switch (this.installmentFrequency){
                        case 'Monthly':
                            this.frequency = 1;
                            break;
                        case 'bi-monthly':
                            this.frequency = 2;
                            break;
                        case 'Quarterly':
                            this.frequency = 3;
                            break;
                        case 'Half yearly':
                            this.frequency = 6; 
                            break;
                        default:
                            this.frequency = 1;
                            break;           
                    }
                    if(this.installmentType == 'Equated'){  
                        emiRepaymentSchedule({principal:this.finalLoanAmount,irr:this.requiredCRMIRR,loanDate:this.dealDate,increment:this.tenure,frequency:this.frequency,repaymentDate:this.firstEMI,secondEMI:this.secondEMI,advanceEMI: this.advanceEMI}).then((result) => {
                            this.totalPaybleEMI = result;
                            this.showEquated = true;
                            this.SpinnerMoving = false;
                        })
                        .catch((error) => {
                            this.SpinnerMoving = false;
                        });
                    }
                    this.SpinnerMoving = false;
                    
                    }}).catch(error => {
                    this.SpinnerMoving = false;
                            });}
                    }else{
                        this.SpinnerMoving = false;
                    }
                }
        }
    }
    
    async handleSubmit(){
        try{
            this.SpinnerMoving = true;
            if(this.productType === 'Tractor'){
                if(this.insuranceDetailsList && this.insuranceDetailsList.length > 0 && this.insuranceDetailsList.find(opt => opt.isPlanChecked === true)){
                    let nomineeElements = this.template.querySelectorAll('[data-name=borrowerFields]');
                    if(nomineeElements && nomineeElements.length > 0){
                        let valid = await [
                            ...nomineeElements
                        ].reduce((validSoFar, inputField) => {
                            if (!inputField.checkValidity()){
                                inputField.reportValidity();
                            }
                            return validSoFar && inputField.checkValidity();
                        },true);
                        if(!valid){
                            const evt = new ShowToastEvent({
                                title: "Error",
                                message: 'Please fill nominee details!',
                                variant: 'error',
                            });
                            this.dispatchEvent(evt);
                            this.SpinnerMoving = false;
                            return;
                        }
                    }
                }
                if(this.insuranceDetailsList && this.insuranceDetailsList.length > 0 && this.insuranceDetailsList.find(opt => opt.isPlanChecked === true) && (parseInt(this.ltvWithInsurance) > 95) || (parseInt(this.ltvWithoutInsurance) > 90)){
                    const evt = new ShowToastEvent({
                        title: "Error",
                        message: 'LTV With Insurance can not be more than 95% and without Inurance can not be more than 90%',
                        variant: 'Error',
                    });
                    this.dispatchEvent(evt);
                    this.SpinnerMoving = false;
                    return;
                }else if(this.insuranceDetailsList && this.insuranceDetailsList.length > 0 && this.insuranceDetailsList.find(opt => opt.isPlanChecked === true) && this.changedSomething){
                    const event = new ShowToastEvent({
                        title: 'Error',
                        message: 'You have changed something. Please Click on funding availability!',
                        variant: 'error',
                    });
                    this.dispatchEvent(event);
                    this.SpinnerMoving = false;
                    return;
                }else if(this.insuranceDetailsList && this.insuranceDetailsList.length > 0 && this.insuranceDetailsList.find(opt => opt.isPlanChecked === true) && (!this.ltvWithInsurance || !this.ltvWithoutInsurance)){
                    const event = new ShowToastEvent({
                        title: 'Error',
                        message: 'Please Click on funding availability!',
                        variant: 'error',
                    });
                    this.dispatchEvent(event);
                    this.SpinnerMoving = false;
                    return;
                }else{
                    if(!this.isOfferEngineDisabled && this.isCalledFromL1){
                        const evt = new ShowToastEvent({
                            title: "Warning",
                            message: 'Please click on call offer engine button first.',
                            variant: 'warning',
                        });
                        this.dispatchEvent(evt);
                        this.SpinnerMoving = false;
                        return;
                    }else {

                        if(this.isCalledFromL2){
                            this.offerEngineMandatory = await isL1InsuranceChanged({'vehicleId' : this.assetId});
                        }
                        if (this.insuranceDetailsList && this.insuranceDetailsList.length > 0 && !this.insuranceDetailsList.find(opt => opt.isPlanChecked === true)) {
                            this.fundedPremiumValue = null;
                            this.totalInsurancePayable = null;
                            this.ltvWithInsurance = null;
                            this.ltvWithoutInsurance = null;
                            await deleteExistingPlansTf({'loanApplicationId':this.recordId,'vehicleId' : this.assetId,'isCalledFromL2':this.isCalledFromL2});
                            if(this.isCalledFromL2){
                                this.offerEngineMandatory = true;
                            }
                        }

                        if(this.isCalledFromL2 && this.ChangeVariantOfferCalled){   //SFTRAC-1526 Starts
                            this.offerEngineMandatory = true;
                        }//SFTRAC-1526 Ends

                        if(this.offerEngineMandatory){
                            let data = await getFinalTermData({ loanApplicationId: this.recordId, vehicleId: this.assetId });
                            if (data) {
                                let parsedData = JSON.parse(data);
                                this.totalFundedPremium = Number(parsedData.totalFundedPremium);
                            }
                            let result = await this.handleTFOfferEngineCalloutHelper(true);
                            if(!result){
                                this.SpinnerMoving = false; 
                                return;
                            }else{
                                this.offerEngineMandatory = false;
                            }
                        }

                        
                        const fields = {};
                        fields['Id'] = this.applicantId;
                        fields['Nominee_name__c'] = this.inputWrapper['borrowerName'].value;
                        fields['Nominee_DOB__c'] = this.inputWrapper['borrowerDOB'].value;
                        fields['Nominee_Relationship__c'] = this.inputWrapper['borrowerRelationship'].value;
                        fields['Nominee_address__c'] = this.inputWrapper['borrowerAddress'].value;

                        const recordInput = {
                            fields
                        };
                        updateRecord(recordInput).then(() => {}).catch((error) => {});
                        const saveDetails = {
                            loanApplicationId: this.recordId,
                            journeyOfLead: this.isCalledFromL1 == 'true' ? 'L1' : this.isCalledFromL2 == 'true' ? 'L2' : '',
                            applicantId: this.applicantId,
                            ltvWithInsurance: this.ltvWithInsurance,
                            ltvWithoutInsurance: this.ltvWithoutInsurance,
                            totalInsurancePayable: this.totalInsurancePayable,
                            assetId: this.assetId,
                            applicantType: this.activeTab,
                            premiumFunded: this.fundedPremiumValue,
                        }

                        let applicantList = await fetchApplicants({'loanApplicationId' : this.recordId});
                        let insuranceList = await fetchInsurance({'loanApplicationId' : this.recordId});

                        let result = await finalSubmitTFInsuranceDetails({
                            payload: JSON.stringify(saveDetails)
                        });
                        if (result === this.label.SuccessMessage || result == 'Submitted' || result == 'Final Submit') {
                            if(this.isCalledFromL1){
                            const FinalTermsFields = {};
                            FinalTermsFields[final_ID_FIELD.fieldApiName]=this.finalTermId;
                            if(this.finalLoanAmount){
                                FinalTermsFields[L1_Finance_Amount.fieldApiName]=this.finalLoanAmount + '';
                            }
                            if(this.requiredCRMIRR){
                                FinalTermsFields[L1_Required_CRM_IRR.fieldApiName] = this.requiredCRMIRR;
                            }
                            await this.updateRecordDetails(FinalTermsFields);
                            }
                            if(result === 'Final Submit' && insuranceList && insuranceList.length > 0){
                                await this.sendInsuranceConsentcall(insuranceList[0].Applicant__c, 'INC');
                            }
                            if(result === 'Final Submit' && applicantList && applicantList.length > 0){
                                for (let index = 0; index < applicantList.length; index++) {
                                    await this.sendInsuranceConsentcall(applicantList[index].Id, 'LAS');
                                }
                            }
                            const evt = new ShowToastEvent({
                                title: 'Success',
                                message: this.label.detailsSaved,
                                variant: 'Success',
                            });
                            this.dispatchEvent(evt);
                            let allElements = this.template.querySelectorAll('*');
                            allElements.forEach(element =>element.disabled = true);
                            this.isSubmitButtonDisabled = true;
                            window.location.reload();
                        }else{
                            const evt = new ShowToastEvent({
                                title: "Error",
                                message: 'Something went wrong!',
                                variant: 'error',
                            });
                            this.dispatchEvent(evt);
                            this.SpinnerMoving = false;
                            this.isSubmitButtonDisabled = false;
                        }
                    }
                }
            }
        }catch(error){
            const evt = new ShowToastEvent({
                title: "Error",
                message: 'Something went wrong!',
                variant: 'error',
            });
            this.dispatchEvent(evt);
            this.SpinnerMoving = false;
            this.isSubmitButtonDisabled = false;
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
            await this.handleConcentCall('home');
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

    // handleActive(event) {
    //     this.activeTab = event.target.value;
    // }

    renderedCallback() {
        loadStyle(this, LightningCardCSS);
        if ((this.currentStageName && this.lastStage && this.isCalledFromL1 && this.currentStageName !== 'Insurance Details' && this.lastStage !== 'Insurance Details' && this.isCalledFromL1 == "true") || (this.currentStageName && this.subStage && this.isCalledFromL2 && this.currentStageName !== this.label.CreditProcessing && this.subStage !== 'Insurance' && this.isCalledFromL2 == "true") || this.isdisabled) {
            this.disableEverything();
            console.log('disableEverything');
            this.isSpinnerMoving = false;
            this.SpinnerMoving = false;
        }
        if(this.disableNomineeDetails == true){
            this.template.querySelectorAll('[data-name="borrowerFields"]').forEach(element => {
                element.disabled = true;
            });
        }
        if (this.currentStage === this.label.CreditProcessing) {
            let allElements = this.template.querySelectorAll('*');
            allElements.forEach(element =>
                element.disabled = true
            );
            this.isEnableNext = true;
            if (this.template.querySelector('.next')) { this.template.querySelector('.next').disabled = false; }
        }
        if(this.isNonIndividual && this.isCalledFromL2){
            this.isEnableBeneficiaryNext = true;
            if (this.template.querySelector('.ninext')) { this.template.querySelector('.ninext').disabled = false; }
        }
        if(this.isRevokedLoanApplication){this.disableEverything();}
        if(this.isCalledFromL1){
            if(this.isl1OfferEngineCompleted){
                this.template.querySelectorAll(".disableInsFields").forEach(element => {
                    element.disabled = true;
                });
            }
        }
    }

    //Sri
    handleOnfinish(event) {
        const evnts = new CustomEvent('customcodevaleve', { detail: event });
        this.dispatchEvent(evnts);
    }

    //TF offer Engine API callout SFTRAC-126
    async handleTFOfferEngineCalloutHelper(calculate){
        let valid = false;
        try{
        console.log('++++TF Offer Engine Api method handleTFOfferEngineCalloutHelper ');
        let result = await tractorOfferEngineCallout({ loanAppId: this.recordId, vehicleId: this.assetId,screenName : 'Insurance Details'});
                const parsedResponse = JSON.parse(result);
                let amortSch = parsedResponse?.application?.offerEngineDetails?.offerEngineDecision?.amortizationSchedule;
                const offerEngineResponse = parsedResponse?.application?.offerEngineDetails?.offerEngineDecision;
                
                if(offerEngineResponse.stopJourneyFlag == true && this.installmentType == 'Structured'){
                    const evt = new ShowToastEvent({ title: "Error", message: 'API responed to stop journey, please update EMI again', variant: 'error' });
                    this.dispatchEvent(evt);
                    deleteStructeredEMIRec({ vehicleRecId: this.assetId, loanAppId: this.recordId })
                    .then(result => {
                        console.log('+++++result ',result);
                    })
                    .catch(error => {
                        this.showToast('Error', error.body.message, 'error');
                    });
                    setTimeout(() => {
                        window.location.reload();
                    },2000);
                    
                }else{//SFTRAC-1453 ends
                    const FinalTermFields = {};console.log('+++++this.finalTermId'+this.finalTermId);
                FinalTermFields[final_ID_FIELD.fieldApiName]=this.finalTermId;
                
                FinalTermFields[OfferengineMinLoanAmount.fieldApiName] = offerEngineResponse !== undefined ?  offerEngineResponse.minLoanAmt : '';
                FinalTermFields[OfferengineMaxLoanAmount.fieldApiName] = offerEngineResponse !== undefined ?  offerEngineResponse.maxLoanAmt : '';
                //FinalTermFields[Loan_Amount.fieldApiName] = offerEngineResponse !== undefined ?  offerEngineResponse.displayLoanAmt.toString() : '';
                FinalTermFields[Loan_Amount.fieldApiName] = offerEngineResponse !== undefined ?  (parseFloat(offerEngineResponse.displayLoanAmt) - this.totalFundedPremium).toString() : '';
                FinalTermFields[OfferengineMinTenure.fieldApiName] = offerEngineResponse !== undefined ?  offerEngineResponse.minTenure : '';
                FinalTermFields[OfferengineMaxTenure.fieldApiName] = offerEngineResponse !== undefined ?  offerEngineResponse.maxTenure : '';
                FinalTermFields[Tenure.fieldApiName] = offerEngineResponse !== undefined ?  offerEngineResponse.displayTenure.toString() : '';
                FinalTermFields[EMI_Amount.fieldApiName] = offerEngineResponse !== undefined ?  offerEngineResponse.displayEMI : '';
                this.emi = (offerEngineResponse && offerEngineResponse.displayEMI) ?  parseFloat(offerEngineResponse.displayEMI) : 0;
                //SFTRAC-2301 Start
                if(this.installmentType == 'Structured'){
                    FinalTermFields[Derived_CRM_IRR.fieldApiName] = offerEngineResponse !== undefined ?  offerEngineResponse.displayCrmIrr.toString() : '';
                }else{
                //SFTRAC-2301 End
                    FinalTermFields[Required_CRM_IRR.fieldApiName] = offerEngineResponse !== undefined ?  offerEngineResponse.displayCrmIrr.toString() : '';
                }
                FinalTermFields[Net_IRR.fieldApiName] = offerEngineResponse !== undefined ?  offerEngineResponse.netIrr : '';
                FinalTermFields[Gross_IRR.fieldApiName] = offerEngineResponse !== undefined ?  offerEngineResponse.grossIrr : '';
                FinalTermFields[Bank_IRR.fieldApiName] = offerEngineResponse !== undefined ?  offerEngineResponse.bankCrmIrr.toString() : '';
                FinalTermFields[Offer_Agreement_Amount.fieldApiName] = offerEngineResponse !== undefined ?  offerEngineResponse.agreementAmount : '';
                if(this.isCalledFromL2 && this.ChangeVariantOfferCalled){//SFTRAC-1526
                    FinalTermFields[ChangeVariantOfferCalled.fieldApiName] = false;//SFTRAC-1526
                }//SFTRAC-1526
                //FinalTermFields[L1_Offer_Engine_Completed.fieldApiName] = true;
                //FinalTermFields[structuredFirstCall.fieldApiName] = true;
                this.loanAgreementAmt = offerEngineResponse !== undefined ?  offerEngineResponse.agreementAmount : '';
                console.log('loan Agreement Amt-----+'+this.loanAgreementAmt);
                this.offerEngineFlag = true;
                if(this.isCalledFromL1){
                    if(!calculate && this.installmentType == 'Structured'){
                        FinalTermFields[structuredFirstCall.fieldApiName] = true;
                    }
                    if((calculate && this.installmentType == 'Structured') || this.installmentType == 'Equated'){
                        FinalTermFields[L1_Offer_Engine_Completed.fieldApiName] = true;
                        this.isSubmitButtonDisabled = false;
                    }
                }
                this.updateRecordDetail(FinalTermFields);
                const evt = new ShowToastEvent({
                    title: 'Success',
                    message: "Offer Engine API Success",
                    variant: 'Success',
                });
                this.dispatchEvent(evt);
                this.isOfferEngineDisabled = true;
                this.template.querySelectorAll(".disableInsFields").forEach(element => {
                    element.disabled = true;
                });
                valid = true;
                //this.isSubmitButtonDisabled = false;
              /*  if(!calculate && this.installmentType == 'Structured'){
                FinalTermFields[structuredFirstCall.fieldApiName] = true;
                } */
                if(calculate && this.installmentType == 'Structured'){
                this.totalPaybleEMI = amortSch;
                this.showAmort = true;
                    }
            }
        }catch(error){
            console.log('Error in Offer Engine API.', error);
                const evt = new ShowToastEvent({
                    title: 'Error',
                    message: "Offer Engine API Failed",
                    variant: 'error',
                });
                this.dispatchEvent(evt);
                valid = false;
        }
        return valid;
    }

    updateRecordDetail(fields) {
        const recordInput = { fields };
        console.log('before update ', recordInput);
        updateRecord(recordInput)
            .then(() => {
            })
            .catch(error => {
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

    async handleConcentCall(calledfrom) {
        try{
            const saveDetails = {
                loanApplicationId: this.recordId,
                applicantId: this.applicantId,
                ltvWithInsurance: this.ltvWithInsurance,
                ltvWithoutInsurance: this.ltvWithoutInsurance,
                totalInsurancePayable: this.totalInsurancePayable,
                assetId: this.assetId,
                applicantType: this.activeTab,
                premiumFunded: this.fundedPremiumValue,
                insProductDetails : [],
                height: null,
                weight: null,
                bmi: null,
                isCalledFromL2: (calledfrom == 'fundingAvailability' && this.isCalledFromL2) ? true  : false, // to set the flag when call
            }
        if (this.insuranceDetailsList.length > 0 && this.insuranceDetailsList.find(opt => opt.isPlanChecked === true)) {
            let insProductDetails = [];
            for (let i = 0; i < this.insuranceDetailsList.length; i++) {
                const element = this.insuranceDetailsList[i];
                if (element.isPlanChecked) {
                    const selectedPlanObj={
                        selectedProduct: element.insProductName,
                        selectedPlan: element.insPlanCode,
                        isFunded: element.isFundedChecked,
                        assetId: this.assetId,
                        premium : element.insAmount == '' ? 0 : element.insAmount ? parseFloat(element.insAmount) : 0,
                        comboLIPremium : (element.insProductName ==='LI_EMI' || element.insProductName ==='TATA_EMI' || element.insProductName == 'COMBO' || element.insProductName == 'LI_SHUBH' || element.insProductName == 'LI' || element.insProductName == 'HEALTH') ? parseFloat(this.comboLIPremium) : 0,
                        comboEMIPremium : (element.insProductName ==='LI_EMI' || element.insProductName ==='TATA_EMI' || element.insProductName == 'COMBO' || element.insProductName == 'LI_SHUBH' || element.insProductName == 'LI' || element.insProductName == 'HEALTH') ? parseFloat(this.comboEMIPremium) : 0,
                        eMIPassedinAPI : (element.insProductName ==='LI_EMI' || element.insPlanCode === 'LI_EMI') ? this.eMIPassedinAPI ? parseFloat(this.eMIPassedinAPI) : 0 : 0,
                    };
                    saveDetails.insProductDetails.push(selectedPlanObj);
                    if((element.insProductName ==='LI' || element.insPlanCode === 'LI_EMI') && this.applicantHeight && this.applicantWeight && this.bmiValue){
                        saveDetails.height = this.applicantHeight;
                        saveDetails.weight = this.applicantWeight;
                        saveDetails.bmi = this.bmiValue;
                    }                
                }
            }
            

            let result = await submitTFInsuranceDetails({
                payload: JSON.stringify(saveDetails)
            });
            if(result){
                return true;
            }
        }else{
            return true;
        }
        }catch(error){
            const evt = new ShowToastEvent({
                title: "Error",
                message: error?.body?.message,
                variant: 'error',
            });
            this.dispatchEvent(evt);
            this.SpinnerMoving = false;
        }
    return false;
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
            }
            else if (this.insuranceDetailsList.length > 0 && selectedInsPlanNameList.length > 0 && selectedInsPlanNameList.includes('LI_EMI') && selectedInsPlanNameList.includes('TATA_EMI')) {
                const event = new ShowToastEvent({
                    title: 'Error',
                    message: 'Please select either TATA EMI or LI EMI',
                    variant: 'error',
                });
                this.dispatchEvent(event);
            }
            else if (this.insuranceDetailsList.length > 0 && selectedInsPlanNameList.length > 0 && selectedInsPlanNameList.includes(COMBO) && (selectedInsPlanNameList.includes(GPA) || (selectedInsPlanNameList.includes('LI') || selectedInsPlanNameList.includes('HEALTH')))) {
                const event = new ShowToastEvent({
                title: 'Error',
                message: 'Please select either COMBO OR (GPA OR LI OR HEALTH)',
                variant: 'error',
                });
                this.dispatchEvent(event);
            }//SFTRAC-1422 Starts
            else if (this.productType === 'Tractor' && this.insuranceDetailsList.length > 0 && selectedInsPlanNameList.length == 1 && selectedInsPlanNameList.includes(MOTOR)) {
                this.isComputePremiumAPIRun = true;
                this.fundisabled =false;
                const event = new ShowToastEvent({
                    title: 'Insurance Premium API callout not required',
                    message: 'You have selected Motor Insurance only so click on Funding Availability!!!',
                    variant: 'warning',
                });
                this.dispatchEvent(event);
                return;
            }//SFTRAC-1422 Ends
            else if(this.isComputePremiumAPIRun){
            
                const event = new ShowToastEvent({
                    title: 'Error',
                    message: 'You have\'t changed anything. Please Click on funding availability button!',
                    variant: 'error',
                });
                this.dispatchEvent(event);
                this.SpinnerMoving = false;
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
                                Premium : element.insProductName === MOTOR ? String(Math.round(element.insAmount ? element.insAmount : 0)) : (element.insProductName ==='LI_EMI' || element.insPlanCode === 'LI_EMI') ? String(Math.round(this.emi ? this.emi : 0)): 0,
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
                }
            }  
        } catch (error) {
            console.error(error);
        }               
    }

    planCheckChangeHandler(event){
        this.changedSomething = true;
        let selectedPlanName = event.target.label;
        let insplanChecked = event.target.checked;
        let tempinsuranceDetailsList = this.insuranceDetailsList;
        this.insuranceDetailsList = [];
        for (let i = 0; i < tempinsuranceDetailsList.length; i++) {
            const element = tempinsuranceDetailsList[i];
            if (selectedPlanName === element.insProductName) {
                if (insplanChecked) {
                    element.isPlanChecked = true;
                    element.isFundedDisabled = false;
                    element.isAmountFieldDisabled = (element.insProductName === MOTOR) ? false : true;
                    element.isPlanCodeDisabled = fixedInsPlan.includes(element.insProductName) ? true : false;
                    if(element.insProductName === MOTOR){
                        element.insAmount = this.motorIns?.insAmount;
                        element.isFundedChecked = this.motorIns?.isFundedChecked;
                    }
                    this.disabledHeightAndWeight = (selectedPlanName == 'LI' || element.insPlanCode == 'LI_EMI') ? false : this.disabledHeightAndWeight; 
                }else{
                    element.isPlanChecked = false;
                    element.isFundedChecked = false;
                    element.isFundedDisabled = true;
                    element.isAmountFieldDisabled = true;
                    element.insPlanCode = fixedInsPlan.includes(element.insProductName) ? element.insPlanCode : '';
                    element.insAmount = 0;
                    element.isPlanCodeDisabled = true;
                    if(selectedPlanName == 'LI' || element.insPlanCode == 'LI_EMI'){
                        this.disabledHeightAndWeight = true;
                        this.applicantHeight = '';
                        this.applicantWeight = '';
                        this.bmiValue = '';
                    }
                }
                
            }
            this.insuranceDetailsList.push(element);
        }
        
        this.isComputePremiumAPIRun = false;
    }

    async beneficiaryeHandler(event){
        this.loadInsuranceSection = true;
        if(event?.target?.value){
            this.beneficiaryId =  event.target.value;
        }
        this.applicantId = this.beneficiaryId;
        this.wireRunsOnlyOnce = false;
        await refreshApex(this.applicantData);
        await this.onloadexistInsuranceDetails();
        this.SpinnerMoving = false;
    }

    @track vehiclePurchaseprice; //SFTRAC-909
    @track totalFundedPremium = 0; //SFTRAC-909
    //SFTRAC-909
    async checkPurchaseprice() {
        let isvehiclePurchasepriceCheck = false;
            let data = await getFinalTermData({ loanApplicationId: this.recordId, vehicleId: this.assetId });
                if (data) {
                    let parsedData = JSON.parse(data);
                    this.loanAmountDetail = Number(parsedData.loanAmount) + Number(parsedData.totalFundedPremium);
                    this.totalFundedPremium = Number(parsedData.totalFundedPremium);
                    let totalFPflag = this.totalFundedPremium != null && this.totalFundedPremium != 0;
                    const newMaxLoanAmount = (0.95 * this.vehiclePurchaseprice);
                    const usedRefMaxLoanAmount = (0.90 * this.vehiclePurchaseprice);
                    if ((parseInt(this.loanAmountDetail, 10) > newMaxLoanAmount) && this.vehicleTypeDetail == 'New') {
                        const evt = new ShowToastEvent({ title: "Error", message: 'Loan amount cannot exceed 95% of the vehicle purchase price', variant: 'error' });
                        this.dispatchEvent(evt);
                        isvehiclePurchasepriceCheck = true;
                    } else if ((totalFPflag == true) && parseInt(this.loanAmountDetail, 10) > usedRefMaxLoanAmount && (this.vehicleTypeDetail == 'Used' || this.vehicleTypeDetail == 'Refinance')) {
                        const evt = new ShowToastEvent({ title: "Error", message: 'Loan amount cannot exceed 90% of the vehicle purchase price', variant: 'error' });
                        this.dispatchEvent(evt);
                        isvehiclePurchasepriceCheck = true;
                    } else if ((totalFPflag == false) && parseInt(this.loanAmountDetail, 10) > newMaxLoanAmount && (this.vehicleTypeDetail == 'Used' || this.vehicleTypeDetail == 'Refinance')){
                        const evt = new ShowToastEvent({ title: "Error", message: 'Loan amount cannot exceed 95% of the vehicle purchase price', variant: 'error' });
                        this.dispatchEvent(evt);
                        isvehiclePurchasepriceCheck = true;
                    } else {
                        isvehiclePurchasepriceCheck = false;
                    }
                }
                return isvehiclePurchasepriceCheck;
            }
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
                if((this.isStructuredDisabled == true && this.isOfferEngineDisabled == true && this.installmentType == 'Structured' && this.isCalledFromL1) || (this.isOfferEngineDisabled == true  &&this.installmentType == 'Equated' && this.isCalledFromL1) || (this.isCalledFromL2)){
                    this.isSubmitButtonDisabled = false;
                }
                this.isComputePremiumAPIRun = false;
                this.changedSomething = true;
            }
}