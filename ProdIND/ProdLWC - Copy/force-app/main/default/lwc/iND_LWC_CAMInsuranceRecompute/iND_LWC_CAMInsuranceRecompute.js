import { LightningElement, track, api } from 'lwc'; 
import { loadStyle } from 'lightning/platformResourceLoader';
import LightningCardCSS from '@salesforce/resourceUrl/loanApplication';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getFundingAvailibility from '@salesforce/apex/IND_InsuranceDetailsLWC_controller.getFundingAvailibility';
import sendInsuranceConsent from '@salesforce/apex/IND_InsuranceDetailsLWC_controller.sendInsuranceConsent';
import submitInsuranceDetails from '@salesforce/apex/IND_InsuranceDetailsLWC_controller.submitInsuranceDetails';
import getApplicantId from '@salesforce/apex/IND_InsuranceDetailsLWC_controller.getApplicantId';
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
import Message_Offer_Engine_Success from '@salesforce/label/c.Message_Offer_Engine_Success';
import Message_Offer_Engine_Failure from '@salesforce/label/c.Message_Offer_Engine_Failure';

import doInsuranceRecommendationCallout from '@salesforce/apexContinuation/IntegrationEngine.doInsuranceRecommendationCallout';
import callInuranceRecAPI from '@salesforce/apex/IND_InsuranceDetailsLWC_controller.callInuranceRecAPI';
import doInsurancePremiumCallout from '@salesforce/apexContinuation/IntegrationEngine.doInsurancePremiumCallout';
import doSmsCallout from '@salesforce/apexContinuation/IntegrationEngine.doSmsGatewayCallout';
import getMotorInsurancePreimum from '@salesforce/apex/IND_InsuranceDetailsLWC_controller.getMotorInsurancePreimum';
import getMotorInsuranceFromLoanDetails from '@salesforce/apex/IND_InsuranceDetailsLWC_controller.getMotorInsuranceFromLoanDetails';
import getInsuranceDetailsFromMaster from '@salesforce/apex/IND_InsuranceDetailsLWC_controller.getInsuranceDetailsFromMaster';
import existInsuranceDetailsMethod from '@salesforce/apex/IND_InsuranceDetailsLWC_controller.existInsuranceDetailsMethod';

import doOfferEngineCallout from '@salesforce/apexContinuation/IntegrationEngine.doOfferEngineCallout';
import CreditProcessing from '@salesforce/label/c.Credit_Processing';

import Gross_IRR from '@salesforce/schema/Final_Term__c.Gross_IRR__c';
import final_ID_FIELD from '@salesforce/schema/Final_Term__c.Id';
import EMI_Amount from '@salesforce/schema/Final_Term__c.EMI_Amount__c';
import CRM_IRR from '@salesforce/schema/Final_Term__c.CRM_IRR__c';
import Net_IRR from '@salesforce/schema/Final_Term__c.Net_IRR__c';

import OPP_ID_FIELD from '@salesforce/schema/Opportunity.Id';
import Submitted_Tabs from '@salesforce/schema/Opportunity.Submitted_Tabs__c';
import fetchOppourtunityData from '@salesforce/apex/IND_InsuranceDetailsLWC_controller.fetchOppourtunityData';

//Custom Labels
import PassengerVehicles from '@salesforce/label/c.PassengerVehicles';
import TwoWheeler from '@salesforce/label/c.TwoWheeler';
import detailsSaved from '@salesforce/label/c.detailsSaved';
import COMBO from '@salesforce/label/c.COMBO';
import HEALTH from '@salesforce/label/c.HEALTH';
import GPA from '@salesforce/label/c.GPA';
import MOTOR from '@salesforce/label/c.MOTOR';
import Retry_Exhausted from '@salesforce/label/c.Retry_Exhausted';

import deleteExistingPlans from '@salesforce/apex/IND_InsuranceDetailsLWC_controller.deleteExistingPlans';
//Custom Labels
import COMBO_GPA_OR_HEALTH_LABEL from '@salesforce/label/c.COMBO_GPA_OR_HEALTH';
import FICO_Deviation_ERROR_LABEL from '@salesforce/label/c.FICO_Deviation_ERROR';
import NOT_OPTED_INSURANCE_MSG_LABEL from '@salesforce/label/c.NOT_OPTED_INSURANCE_MSG';
import Sanction_Status_Message_LABEL from '@salesforce/label/c.Sanction_Status_Message';
//Applicant consent fields.
import APPLICATION_FORM_SMS_SENT from '@salesforce/schema/Applicant__c.Application_Form_SMS_Sent__c';
import APPLICANT_ID from '@salesforce/schema/Applicant__c.Id';
import INSURANCE_CONSENT_SENT from '@salesforce/schema/Applicant__c.Insurance_consent_sent_on__c';
import APPLICANT_InsuranceConsentOTP from '@salesforce/schema/Applicant__c.Insurance_Consent_OTP__c';
import APPLICANT_ApplicationConsentOTP from '@salesforce/schema/Applicant__c.Application_Consent_OTP__c';
import accessLoanApplication from '@salesforce/apex/LwcLOSLoanApplicationCntrl.accessLoanApplication';
import ReadOnlyLeadAccess from '@salesforce/label/c.ReadOnlyLeadAccess';
import getFinalTermData from '@salesforce/apex/IND_OfferScreenController.loadOfferScreenData';
import fetchDataFromApplicatntObj from '@salesforce/apex/IND_InsuranceDetailsLWC_controller.fetchDataFromApplicatntObj';
import Table_Code from '@salesforce/schema/Final_Term__c.Table_Code__c';//CISP-16547 
import DR_Penal_Interest from '@salesforce/schema/Final_Term__c.DR_Penal_Interest__c';//CISP-16547
import Interest_Version_No from '@salesforce/schema/Final_Term__c.Interest_Version_No__c';//CISP-16547
import mclrRate from '@salesforce/schema/Final_Term__c.mclrRate__c';//CISP-16547   
import {NavigationMixin} from 'lightning/navigation';
import Loan_Deal_Date from '@salesforce/schema/Final_Term__c.Loan_Deal_Date__c';
import OE_Agreement_Amount from '@salesforce/schema/Final_Term__c.Offer_Agreement_Amount__c';
import saveInstallmentSchedule from '@salesforce/apex/InstallmentScheduleController.saveInstallmentSchedule';
const fixedInsPlan = [MOTOR, 'LI_EMI', 'TATA_EMI', 'LI'];
const PlanforCoborrower = ['FLEXI',COMBO, 'GPA', 'LI'];

export default class IND_LWC_CAMInsuranceRecompute extends NavigationMixin(LightningElement) {
    @api recordId;
    @api responseReApisatus;
    @api callMsterRecords;
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
    @track isConsentButtonDisabled = false;
    @track selectedProduct;
    @track selectedPlan;
    @api activeTab;
    @track fundedPremiumValue;
    @track totalInsurancePayable;
    @track ltvWithInsurance;
    @track ltvWithoutInsurance;
    @track proposalLtv;
    @track isSubmitButtonDisabled;
    @track showPopup;
    @track showPopupForAmount;
    @track popupCheckbox;
    @track popupCheckboxChecked;
    @api currentStage;
    @api subStage;
    @api insuranceDetailsApi;
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
    haveNoInsData = false;
    existingInsDetailList = [];
    insuranceDetailsList = [];
    isComputePremiumAPIRun = false;
    comboLIPremium = 0;
    comboEMIPremium = 0;
    eMIPassedinAPI = 0;//End CISP-3194
    submittedTabs;
    @api fromcamlog = false;
    @api fromcampage = false;
    isRerunOfferAPIRun = false;
    loanAmount;
    applicantAge;
    applicantHeight;
    applicantWeight;
    disabledHeightAndWeight=true;
    bmiValue;
    showheightAndWeight = false;
    approvingAuthorityLoanAmount;
    offerEngineEMIChanged =false;
    previousLoanAmount;
    isFundingAvailiblityClick = false;//CISP-15727
    totalfundedPremium;
    isFundedchanged = false;
    disableMotorInsuranceSection = false;
    isloanAmountAndFundedChanged = false;
    installmentTypeValue;
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
        getFinalTermData({ loanApplicationId: this.recordId,randomvar: '' })
        .then((data) => {
            if (data) {
                let parsedData = JSON.parse(data);
                this.emi = parsedData.emi ? parsedData.emi : '';
                this.finalTermId = parsedData.getrecordId ? parsedData.getrecordId : '';
                this.loanAmount = parsedData.loanAmount ? parsedData.loanAmount :'';
                this.approvingAuthorityLoanAmount = parsedData.approvingAuthorityLoanAmount ? parsedData.approvingAuthorityLoanAmount :'';
                this.totalfundedPremium = parsedData.totalFundedPremium;
                this.installmentTypeValue = parsedData.installmentType;
            }
        }).catch(error => {console.error('error in getFinalTermData => ', error);});
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
            if ((this.currentStage === this.label.CreditProcessing && this.subStage === 'CAM and Approval Log') && this.fromcamlog) {
                if(this.tablength == 2 && this.activeTab === this.label.Borrower && this.submittedTabs!= null && this.submittedTabs.includes('Borrower Insurance Recompute')){
                    if (this.existingInsDetailList.length > 0) {
                        this.insuranceDetailsList = this.existingInsDetailList;
                        this.iconButton = true;
                    }else{
                        this.iconButton = false;
                        this.haveNoInsData = true;
                    }
                    this.disabledHeightAndWeight = true;
                    this.isSpinnerMoving = false;
                    let allElements = this.template.querySelectorAll('*');
                    allElements.forEach(element =>
                        element.disabled = true
                    );
                    const evn = new CustomEvent('coborrower');
                    this.dispatchEvent(evn);
                }else if(this.activeTab === this.label.Borrower && this.submittedTabs!= null && this.submittedTabs.includes('Borrower Insurance Recompute') || this.activeTab === this.label.CoBorrower && this.submittedTabs!= null && this.submittedTabs.includes('Coborrower Insurance Recompute')){
                    if (this.existingInsDetailList.length > 0) {
                        this.insuranceDetailsList = this.existingInsDetailList;
                        this.iconButton = true;
                    }else{
                        this.iconButton = false;
                        this.haveNoInsData = true;
                    }
                    this.disabledHeightAndWeight = true;
                    let allElements = this.template.querySelectorAll('*');
                    allElements.forEach(element =>
                        element.disabled = true
                    );
                    this.isSpinnerMoving = false;
                }else{
                    this.iconButton = false;
                    this.callAPIRecomMethod();
                }
            }else{
                if (this.existingInsDetailList.length > 0) {
                    this.insuranceDetailsList = this.existingInsDetailList;
                    this.iconButton = true;
                }else{
                    this.iconButton = false;
                    this.haveNoInsData = true;
                }
                this.disabledHeightAndWeight = true;
                let allElements = this.template.querySelectorAll('*');
                allElements.forEach(element =>
                    element.disabled = true
                );
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

    async connectedCallback() {
        this.SpinnerMoving = true;
        await fetchOppourtunityData({ loanApplicantionId: this.recordId })
        .then(result => {
            this.currentStageName = result[0].StageName;
            this.currentStage = result[0].StageName;
            this.lastStage = result[0].LastStageName__c;
            this.leadSource =  result[0].LeadSource;
            this.subStage = result[0].Sub_Stage__c;
            this.productType = result[0].Product_Type__c;
            this.submittedTabs = result[0].Submitted_Tabs__c;
            console.log('this.submittedTabs ',this.submittedTabs);
            if (this.productType === this.label.PassengerVehicles) {
                this.isPassengerVehicles=true;
            }
            this.showheightAndWeight = (this.leadSource != 'D2C' && this.isPassengerVehicles);
            this.SpinnerMoving = false;
        })
        .catch(error => {
            console.log('fetchOppourtunityData error : ' + error);
        });           
        this.isSpinnerMoving = true;
        await this.onloadexistInsuranceDetails();
        this.isConsentButtonDisabled = true;
        //this.isSubmitButtonDisabled = true;
        this.popupCheckboxChecked = true;
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
        this.isConsentButtonDisabled = true;
        this.iconButton = false;
        this.fundisabled = true;
        this.isComputePremiumAPIRun = false;
        this.disableComputePremium = false;
        this.isSubmitButtonDisabled = false;
    }

    //Handler for amount input field change.
    hanldeAmountValueChange(event) {
        this.fundisabled = true;
        this.isConsentButtonDisabled = true;
        this.iconButton = false;
        this.popupCheckbox = false;
        this.showPopupForAmount = true;
        this.popupCheckboxChecked = true;
        this.disableComputePremium = false;
        this.isSubmitButtonDisabled = false;
        this.isComputePremiumAPIRun = false;
        let selectedPlanName = event.target.name;
        let enteredAmount = event.target.value;
        this.insuranceDetailsList.find(opt => opt.insProductName === selectedPlanName).insAmount = enteredAmount;
    }

    //Handler for is funded toggle change.
    handleIsFundedToggle(event) {
        this.fundisabled = true;
        this.isConsentButtonDisabled = true;
        this.isFundedchanged = true;
        this.isloanAmountAndFundedChanged =true;
        this.isComputePremiumAPIRun = false;
        this.iconButton = false;
        this.disableComputePremium = false;
        this.isSubmitButtonDisabled = false;
        let selectedPlanName = event.target.name;
        let insFundedChecked = event.target.checked;
        this.insuranceDetailsList.find(opt => opt.insProductName === selectedPlanName).isFundedChecked = insFundedChecked;
        this.calculateFundedPremium();
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
        }else if (this.isPassengerVehicles && this.insuranceDetailsList.length > 0 && selectedInsPlanNameList.length > 0 && selectedInsPlanNameList.includes('LI_EMI') && selectedInsPlanNameList.includes('TATA_EMI')) {
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
        }else if (!this.isPassengerVehicles && this.insuranceDetailsList.length > 0 && selectedInsPlanNameList.length > 0 && selectedInsPlanNameList.includes(COMBO) && (selectedInsPlanNameList.includes(GPA) || (selectedInsPlanNameList.includes('LI') || selectedInsPlanNameList.includes('HEALTH')))) {
            this.isConsentButtonDisabled = true;
            const event = new ShowToastEvent({
                title: 'Error',
                message: COMBO_GPA_OR_HEALTH_LABEL,
                variant: 'error',
            });
            this.dispatchEvent(event);
            return;
        }
        else if(!this.isRerunOfferAPIRun || this.isFundedchanged || (this.loanAmountPlusFundedPremium && this.previousLoanAmount && (parseFloat(this.loanAmountPlusFundedPremium) > parseFloat(this.previousLoanAmount)))){
            this.showToastMessage('Error','Please Rerun Offer Engine first','error');
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
        else if(this.offerEngineEMIChanged){
            this.isConsentButtonDisabled = true;
            const event = new ShowToastEvent({
                title: 'Error',
                message: 'Offer Engine EMI changed. Please Compute Premium first!',
                variant: 'error',
            });
            this.dispatchEvent(event);
            return;
        }
        else if(this.loanAmountPlusFundedPremium && this.approvingAuthorityLoanAmount && (parseFloat(this.loanAmountPlusFundedPremium) > parseFloat(this.approvingAuthorityLoanAmount))){
            this.showToastMessage('Error','Latest loan amount is greater than from Approving Authority Agreed Loan Amount. Kindly change the Insurance Plan','error');
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
                    this.isFundingAvailiblityClick = true;//CISP-15727
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
                        this.iconButton =false;
                        if(this.loanAmountPlusFundedPremium && this.approvingAuthorityLoanAmount && (parseFloat(this.loanAmountPlusFundedPremium) > parseFloat(this.approvingAuthorityLoanAmount))){
                            this.isRerunOfferAPIRun = false;
                            this.showToastMessage('Error','Please Rerun Offer Engine first','error');
                            return;
                        }else{
                            const event = new ShowToastEvent({
                                title: 'Success',
                                message: 'Funding availability validation is successful. Please click on consent button',
                                variant: 'success',
                            });
                            this.dispatchEvent(event);
                        }
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

    get loanAmountPlusFundedPremium(){
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
        if (this.insuranceDetailsList.length > 0 && !this.insuranceDetailsList.find(opt => opt.isPlanChecked === true)) {
            this.showToastMessage('Error',NOT_OPTED_INSURANCE_MSG_LABEL,'error');
            return;
        }
        else if(!this.isRerunOfferAPIRun || this.isFundedchanged){
            this.showToastMessage('Error','Please Rerun Offer Engine first','error');
            return;
        }
        else if(this.insuranceDetailsList.length > 0 && this.insuranceDetailsList.find(opt => opt.isPlanChecked === true) && !this.isComputePremiumAPIRun){
            this.isConsentButtonDisabled = true;
            const event = new ShowToastEvent({
                title: 'Error',
                message: 'You have changed something. Please Compute Premium first!',
                variant: 'error',
            });
            this.dispatchEvent(event);
            return;
        }
        else if(this.insuranceDetailsList.length > 0 && this.insuranceDetailsList.find(opt => opt.isPlanChecked === true) && !this.isFundingAvailiblityClick){
            this.showToastMessage('Error','Please click funding availiblity first','error');
            return;
        }
        else if(this.isPassengerVehicles && this.leadSource != 'D2C' && this.insuranceDetailsList.length > 0 && selectedInsPlanNameList.length > 0 && selectedInsPlanNameList.includes('LI_EMI') && (!this.applicantHeight || !this.applicantWeight)){
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
    }

    //method for submitting the selected insurance product and plan.
    async handleSubmit() {
        //CISP-15727
        if(!this.isRerunOfferAPIRun || this.isFundedchanged){
            this.showToastMessage('Error','Please Rerun Offer Engine first','error');
            return;
        } else if(this.insuranceDetailsList.length > 0 && this.insuranceDetailsList.find(opt => opt.isPlanChecked === true) && !this.isComputePremiumAPIRun){
            this.isConsentButtonDisabled = true;
            const event = new ShowToastEvent({
                title: 'Error',
                message: 'You have changed something. Please Compute Premium first!',
                variant: 'error',
            });
            this.dispatchEvent(event);
            return;
        }else if(this.insuranceDetailsList.length > 0 && this.insuranceDetailsList.find(opt => opt.isPlanChecked === true) && !this.isFundingAvailiblityClick){
            this.showToastMessage('Error','Please click funding availiblity first','error');
            return;
        }//CISP-15727
        await fetchOppourtunityData({ loanApplicantionId: this.recordId }).then(result => {this.submittedTabs = result[0].Submitted_Tabs__c; console.log('result', result); });
        console.log('Inside handleSubmit method', this.submittedTabs, this.activeTab);
        if (this.insuranceDetailsList.length > 0 && !this.insuranceDetailsList.find(opt => opt.isPlanChecked === true) && (this.activeTab =='Co-borrower' && (this.submittedTabs == null || (this.submittedTabs!= null && !this.submittedTabs.includes('Borrower Insurance Recompute'))))) {
            console.log('From 111',this.submittedTabs);
            const evt = new ShowToastEvent({
                title: "Error",
                message: 'Borrower Insurance Details are not submitted!!!',
                variant: 'Error',
            });
            this.dispatchEvent(evt);
            return;
        }
        else if (this.insuranceDetailsList.length > 0 && !this.insuranceDetailsList.find(opt => opt.isPlanChecked === true) && ((this.activeTab =='Borrower') || (this.activeTab =='Co-borrower' && this.submittedTabs!= null && this.submittedTabs.includes('Borrower Insurance Recompute')))) {
            console.log('all are unselected in L1 journey');
            deleteExistingPlans({applicantId : this.applicantId ,loanApplicationId:this.recordId })
            .then(result=>{
                this.totalInsurancePayable = '';
                this.ltvWithInsurance = '';
                this.ltvWithoutInsurance = '';
                if (this.tablength == 2 && this.activeTab == this.label.Borrower) {
                    const oppFields = {};
                    oppFields[OPP_ID_FIELD.fieldApiName] = this.recordId;
                    oppFields[Submitted_Tabs.fieldApiName] = this.submittedTabs!= null && !this.submittedTabs.includes('Borrower Insurance Recompute') ? this.submittedTabs +';Borrower Insurance Recompute' : 'Borrower Insurance Recompute';
                    this.updateRecordDetails(oppFields);
                    let allElements = this.template.querySelectorAll('*');
                    allElements.forEach(element =>
                    element.disabled = true
                    );
                    const evn = new CustomEvent('coborrower');
                    this.dispatchEvent(evn);
                }else{
                    const oppFields = {};
                    oppFields[OPP_ID_FIELD.fieldApiName] = this.recordId;
                    if (this.activeTab =='Borrower') {
                        oppFields[Submitted_Tabs.fieldApiName] = this.submittedTabs!= null && !this.submittedTabs.includes('Borrower Insurance Recompute') ? this.submittedTabs +';Borrower Insurance Recompute' : 'Borrower Insurance Recompute';
                    } else if (this.activeTab =='Co-borrower') {
                        oppFields[Submitted_Tabs.fieldApiName] =  this.submittedTabs!= null && !this.submittedTabs.includes('Coborrower Insurance Recompute') ? this.submittedTabs + ';Coborrower Insurance Recompute' : 'Coborrower Insurance Recompute';
                    }
                    this.updateRecordDetails(oppFields);
                    console.log('Active tab :'+this.activeTab);
                    this.navigateToNextStage();
                }
                });
            
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
        else if ((this.insuranceDetailsList.length > 0 && this.insuranceDetailsList.find(opt => opt.isPlanChecked === true)) && this.iconButton) {
            if (this.tablength == 2 && this.activeTab == this.label.Borrower) {
                const oppFields = {};
                oppFields[OPP_ID_FIELD.fieldApiName] = this.recordId;
                oppFields[Submitted_Tabs.fieldApiName] = this.submittedTabs!= null && !this.submittedTabs.includes('Borrower Insurance Recompute') ? this.submittedTabs +';Borrower Insurance Recompute' : 'Borrower Insurance Recompute';
                this.updateRecordDetails(oppFields);
                let allElements = this.template.querySelectorAll('*');
                allElements.forEach(element =>
                    element.disabled = true
                );
                const evn = new CustomEvent('coborrower');
                this.dispatchEvent(evn);
            } else if(this.tablength == 2 && this.activeTab =='Co-borrower' && (this.submittedTabs== null || (this.submittedTabs!= null && !this.submittedTabs.includes('Borrower Insurance Recompute')))){
                console.log('From 222');
                const evt = new ShowToastEvent({
                    title: "Error",
                    message: 'Borrower Insurance Details are not submitted!!!',
                    variant: 'Error',
                });
                this.dispatchEvent(evt);
                return;
            }else {
                const oppFields = {};
                oppFields[OPP_ID_FIELD.fieldApiName] = this.recordId;
                if (this.activeTab =='Borrower') {
                    oppFields[Submitted_Tabs.fieldApiName] = this.submittedTabs!= null && !this.submittedTabs.includes('Borrower Insurance Recompute') ? this.submittedTabs +';Borrower Insurance Recompute' : 'Borrower Insurance Recompute';
                } else if (this.activeTab =='Co-borrower') {
                    oppFields[Submitted_Tabs.fieldApiName] =  this.submittedTabs!= null && !this.submittedTabs.includes('Coborrower Insurance Recompute') ? this.submittedTabs + ';Coborrower Insurance Recompute' : 'Coborrower Insurance Recompute';
                }
                this.updateRecordDetails(oppFields);
                console.log('Active tab :'+this.activeTab);
                const evt = new ShowToastEvent({
                    title: 'Success',
                    message: this.label.detailsSaved,
                    variant: 'Success',
                });
                this.dispatchEvent(evt);
                this.isSubmitButtonDisabled = true;
                this.navigateToNextStage();
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


    handleActive(event) {
        this.activeTab = event.target.value;
    }
    //sri
    renderedCallback() {
        loadStyle(this, LightningCardCSS);
        if(this.activeTab == this.label.CoBorrower){
            this.disableMotorInsuranceSection = true;
        }
        if(this.fromcampage){
            this.disableEverything();
        }
    }

    //Sri
    handleOnfinish(event) {
        const evnts = new CustomEvent('customcodevaleve', { detail: event });
        this.dispatchEvent(evnts);
    }

    navigateToNextStage() {
        if (this.currentStage === this.label.CreditProcessing && this.subStage === 'CAM and Approval Log') {
            if(this.tablength == 2 && this.activeTab == this.label.Borrower){
                const evn = new CustomEvent('coborrower');
                this.dispatchEvent(evn);
            }else{
                this.dispatchEvent(new CustomEvent('submit'));
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
                        this.disabledHeightAndWeight = true;
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
                this.showToastMessage('Error',NOT_OPTED_INSURANCE_MSG_LABEL,'error');
                return;
            }
            else if(!this.isRerunOfferAPIRun || this.isFundedchanged){
                this.showToastMessage('Error','Please Rerun Offer Engine first','error');
                return;
            }
            else if (this.isPassengerVehicles && this.insuranceDetailsList.length > 0 && selectedInsPlanNameList.length > 0 && selectedInsPlanNameList.includes('LI_EMI') && selectedInsPlanNameList.includes('TATA_EMI')) {
                this.showToastMessage('Error','Please select either TATA EMI or LI EMI','error');
                return;
            }
            else if (!this.isPassengerVehicles && this.insuranceDetailsList.length > 0 && selectedInsPlanNameList.length > 0 && selectedInsPlanNameList.includes(COMBO) && (selectedInsPlanNameList.includes(GPA) || (selectedInsPlanNameList.includes('LI') || selectedInsPlanNameList.includes('HEALTH')))) {
                this.showToastMessage('Error',COMBO_GPA_OR_HEALTH_LABEL,'error');
                return;
            }
            else if(this.isPassengerVehicles && this.insuranceDetailsList.length > 0 && selectedInsPlanNameList.length == 1 && selectedInsPlanNameList.includes(MOTOR)){
                this.isComputePremiumAPIRun = true;
                this.offerEngineEMIChanged = false;
                this.fundisabled = false;
                this.showToastMessage('Insurance Premium API callout not required','You have selected Motor Insurance only so click on Funding Availability!!!','Success');
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
                    this.showToastMessage('Error','Please select Plan for selected Insurance Product!','error');
                    return;
                }
            }  
        } catch (error) {
            console.error(error);
        }               
    }

    planCheckChangeHandler(event){
        let selectedPlanName = event.target.name;
        let insplanChecked = event.target.checked;
        let tempinsuranceDetailsList = this.insuranceDetailsList;
        this.insuranceDetailsList = [];
        for (let i = 0; i < tempinsuranceDetailsList.length; i++) {
            const element = tempinsuranceDetailsList[i];
            if (selectedPlanName === element.insProductName) {
                if (insplanChecked) {
                    element.isPlanChecked = true;
                    element.isFundedDisabled = this.activeTab == this.label.CoBorrower ? true : false;
                    element.isPlanCodeDisabled = fixedInsPlan.includes(element.insProductName) ? true : false;
                    this.disabledHeightAndWeight = selectedPlanName == 'LI_EMI' ? false : this.disabledHeightAndWeight; 
                }else{
                    element.isPlanChecked = false;
                    element.isFundedChecked = false;
                    element.isFundedDisabled = true;
                    element.insPlanCode = fixedInsPlan.includes(element.insProductName) ? element.insPlanCode : '';
                    element.insAmount = element.insProductName === MOTOR ? element.insAmount : 0;
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
        this.iconButton = false;
        this.fundisabled = true;
        this.isConsentButtonDisabled = true;
        this.iconButton = false;
        this.isComputePremiumAPIRun = false;
        this.disableComputePremium = false;
        this.calculateFundedPremium();
    }

    handleRerunOffer(){
        this.SpinnerMoving = true;
        let offerEngineRequestString = {
            'loanApplicationId': this.recordId,
            'currentScreen': 'Final Offer',
            'thresholdNetIRR': null,
            'crmIrrChanged': null,
            'loanAmountChanged': this.activeTab =='Borrower' ? (this.isloanAmountAndFundedChanged && this.loanAmountPlusFundedPremium ? this.loanAmountPlusFundedPremium.toString() : (parseFloat(this.loanAmount) + parseFloat(this.totalfundedPremium)).toString()) : null,
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
                    if(this.productType != 'Tractor'){
                        if(obj.loanDealDate){FinalTermFields[Loan_Deal_Date.fieldApiName] = obj.loanDealDate;}
                        if(obj.agreementAmount){FinalTermFields[OE_Agreement_Amount.fieldApiName] = obj.agreementAmount;}
                        if(obj.amortizationSchedule){
                            saveInstallmentSchedule({ loanId: this.recordId, response: JSON.stringify(obj.amortizationSchedule), installmentType: this.installmentTypeValue}).then(result => {}).catch(error => {});
                        }
                    }
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

    showToastMessage(title,message,variant){
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
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
        this.iconButton = false;
        this.fundisabled = true;
        this.isConsentButtonDisabled = true;
        this.isSubmitButtonDisabled = false;
        this.isComputePremiumAPIRun = false;
    }

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
}