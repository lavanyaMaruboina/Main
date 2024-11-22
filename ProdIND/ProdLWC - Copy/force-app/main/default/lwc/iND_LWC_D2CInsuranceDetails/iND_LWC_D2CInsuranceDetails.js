import { LightningElement, track, api } from 'lwc';
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
import CreditProcessing from '@salesforce/label/c.Credit_Processing';
// END 
import Gross_IRR from '@salesforce/schema/Final_Term__c.Gross_IRR__c';
import final_ID_FIELD from '@salesforce/schema/Final_Term__c.Id';
import EMI_Amount from '@salesforce/schema/Final_Term__c.EMI_Amount__c';
import CRM_IRR from '@salesforce/schema/Final_Term__c.CRM_IRR__c';
import Net_IRR from '@salesforce/schema/Final_Term__c.Net_IRR__c';
import isNavigate from '@salesforce/schema/Final_Term__c.isNavigate__c';

import OPP_ID_FIELD from '@salesforce/schema/Opportunity.Id';
import STAGENAME from '@salesforce/schema/Opportunity.StageName';
import SUB_STAGE_NAME from '@salesforce/schema/Opportunity.Sub_Stage__c';
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
import checkInsuranseExpWith60Days from '@salesforce/apex/IND_InsuranceDetailsLWC_controller.checkInsuranseExpWith60Days';
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
import doVehicleValuationCallout from '@salesforce/apex/D2C_IntegrationEngine.doVehicleValuationCallout';

import {NavigationMixin} from 'lightning/navigation';

export default class IND_LWC_D2CInsuranceDetails extends NavigationMixin(LightningElement) {
    @api recordId;
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
    @track urlId;

    @track healthInsurancePlanComboboxDisabled;
    @track comboPlanComboboxDisabled;
    @track gpaPlanComboboxDisabled;

    @track isHealthInsuranceAmountFieldDisabled;
    @track isGPAInsuranceAmountFieldDisabled;
    @track isComboInsuranceAmountFieldDisabled;
    @track isMotorInsuranceAmountFieldDisabled;

    @track isSubmitButtonDisabled = true;
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
        return [{label : "TATA AIG MOTOR", value : "MOTOR-TATA"},{label : "CHOLA MS MOTOR", value : "MOTOR_CHOLA"}];
    }

    @api helathInuDisabled;
    @api combofunDisabled;
    @api gapfunDisabled;
    @api iconButton = false;
    @api issmscalloutsborrower = 1;
    @api issmscalloutscoborrower = 1;
    @api fundisabled = false;

    //API2 RESPONSE "FAIL" FOR INSURANCE PERIMUM 
    async getPreimumfromMaster(Ins_Product, Plan_Code) {
        await getMotorInsurancePreimum({
            Ins_Product: Ins_Product,
            Plan_Code: Plan_Code
        }).then(result => {
            if (result == null) {
                switch (Ins_Product) {
                    case GPA:
                        this.isGPAInsuranceAmountFieldDisabled = false;
                        break;
                    case HEALTH:
                        this.isHealthInsuranceAmountFieldDisabled = false;
                        break;
                    case COMBO:
                        this.isComboInsuranceAmountFieldDisabled = false;
                        break;
                }
            } else {
                switch (Ins_Product) {
                    case GPA:
                        this.gpaInsuranceAmountValue = result;
                        this.isGPAInsuranceAmountFieldDisabled = true;
                        break;
                    case HEALTH:
                        this.healthInsuranceAmountValue = result;
                        this.isHealthInsuranceAmountFieldDisabled = true;
                        break;
                    case COMBO:
                        this.comboInsuranceAmountValue = result;
                        this.isComboInsuranceAmountFieldDisabled = true;
                        break;
                }
            }
            console.log('Perimum comes form Master' + result);
        }).catch(error => {

        });
    }
    //method to get API insurance premium response
    async getAPIInsuPerimumResponse(applicantId, Ins_Product, Plan_Code) {
        this.isSecondSpinnerMoving = true;
        await doInsurancePremiumCallout({
            applicantId: applicantId,
            Ins_Product: Ins_Product,
            Plan_Code: Plan_Code,
            loanAppId: this.recordId
        }).then(result => {
            console.log("line 285 ==> ", result);
            var getResponse = JSON.parse(result);
            console.log('status flag of 2nd api', getResponse.Status_Flag);
            // console.log('API2...' + JSON.stringify(getResponse));

            if (getResponse.Status_Flag == 'Failure') {
                this.getPreimumfromMaster(Ins_Product, Plan_Code);
            } else {
                console.log('FROM API2... Amount' + getResponse.Premium);
                switch (Ins_Product) {
                    case GPA:
                        this.gpaInsuranceAmountValue = getResponse.Premium;
                        this.isGPAInsuranceAmountFieldDisabled = true;
                        break;
                    case HEALTH:
                        this.healthInsuranceAmountValue = getResponse.Premium;
                        this.isHealthInsuranceAmountFieldDisabled = true;
                        break;
                    case COMBO:
                        this.comboInsuranceAmountValue = getResponse.Premium;
                        this.isComboInsuranceAmountFieldDisabled = true;
                        break;
                }
            }
            // console.log('result of 2nd api=>', result);
            this.isSecondSpinnerMoving = false;
        }).catch(error => {
            console.log('ERROR... API2' + JSON.stringify(error));
            this.getPreimumfromMaster(Ins_Product, Plan_Code);
            this.isSecondSpinnerMoving = false;
        });
    }


    async onloadexistInsuranceDetails() {
        const currentApplicantId = await getApplicantId({
            opportunityId: this.recordId,
            applicantType: "Borrower",
        })
        this.applicantId = currentApplicantId;

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
                this.insuranceDetailsApi = result;
                console.log('res ', result);
                this.fundisabled = true;
                this.iconButton = true;

                //this.getIns_ProdutcsMthod();
                for (var i = 0; i < this.insuranceDetailsApi.length; i++) {
                    var getInsProdObj = this.insuranceDetailsApi[i];
                    this.currentStage = getInsProdObj.Stage;
                    this.subStage = getInsProdObj.Sub_Stage;

                    if (getInsProdObj.Ins_Product != null) {
                        getInsProdObj.Ins_Product = getInsProdObj.Ins_Product.toUpperCase();
                    }


                    if (getInsProdObj.Ins_Product == MOTOR) {
                        //this.motorPlanList.length = 1;
                        this.motorInsuranceAmountValue = getInsProdObj.Premium;
                        this.fundingTypeValueForMotorPlans = getInsProdObj.Disable_Funding == 'Y' ? true : false;
                        this.selectedMotorInsurancePlan = getInsProdObj.Plan_Name;
                        //this.motorfunDisab = true;
                        this.isMotorChecked = true;
                        if (this.currentStage === this.label.CreditProcessing && this.subStage === 'Insurance') {
                            this.motorfunDisab = false;
                            this.isMotorChecked = false;
                            this.isMotorDisabled = false;
                        } else {
                            //this.motorfunDisab = true;
                            this.isMotorChecked = true;
                            //this.isMotorDisabled = true;
                        }
                    }
                }
                
                // if(this.currentStage === 'Insurance Details'){
                //     if (this.motorInsuranceAmountValue == null) {
                //         this.isMotorDisabled = true;
                //         this.motorfunDisab = true;
                //     }
                // }
                this.isSpinnerMoving = false;
            }else{
                this.isMotorChecked = false;
                this.isMotorInsuranceAmountFieldDisabled = true;
                this.motorfunDisab = true;
                this.motorInsurancePlanComboboxDisabled = true;
            }
            if(this.subStage !== 'Insurance Details'){
                this.disableEverything();
            }
        }).catch(error => {
            this.isSpinnerMoving = false;
            console.log('error in existInsuranceDetailsMethod =>', error);
        });
        
    }


    async fetchSubStage() {
        const currentSubStage = await getCurrentSubStage({ opportunityId: this.recordId })
        this.subStage = currentSubStage;
        if(this.subStage !== 'Insurance Details'){
            this.disableEverything();
        }
        this.onloadexistInsuranceDetails();
    }

    isInsuranceExpWith60Days;
    async connectedCallback() {
        console.log("recordId ---> ", this.recordId, 'current stage = >', this.currentStage, 'subStage=>', this.subStage);
        let response = await checkInsuranseExpWith60Days({'loanApplicationId' : this.recordId});
        this.isInsuranceExpWith60Days = response;
        if(response == true){
            this.isSubmitButtonDisabled = true;
        }else{
            this.isSubmitButtonDisabled = false;
        }
        
        await this.fetchSubStage();
        this.showSubmitButton = true;
        this.popupCheckboxChecked = true;
        this.isMotorInsuranceAmountFieldDisabled = false;
    }
    

    //for funding Type  change in products funded or non-funded.
    handleFundingTypeChange(event) {
        const field = event.detail.name;
        if (field === 'motorInsurance') {
            this.fundingTypeValueForMotorPlans = event.target.value;
        }
    }

    //methos for handling plan when user changes the plan.
    handlePlanChange(event) {
        const field = event.target.name;
        console.log('field in plan change= >', field)
        //If the applicant is coborrower than funded/non-funded radio button will be disabled & unchecked
        //Disabling radio-button logic is written in renderdCallback & here is the unchecked logic for coborrower. 
        if (field === 'Motor Insurance Plan') {
            this.iconButton = false;
            this.selectedProduct = MOTOR;
            this.selectedPlan = event.target.value;
            this.selectedMotorInsurancePlan = event.target.value;
            // this.motorPlanList.forEach((element => {
            //     if (element.value === this.selectedPlan && this.activeTab === this.label.Borrower) {
            //         if (element.isFunded === 'Y') {
            //             this.fundingTypeValueForMotorPlans = true;
            //         } else {
            //             this.fundingTypeValueForMotorPlans = false;
            //         }
            //     }
            // }))
        }
        this.isConsentButtonDisabled = true;
        this.iconButton = false;
        if(this.isInsuranceExpWith60Days == true){
            this.InsuranceChangeHandler();
        }
    }
    
    InsuranceChangeHandler(){
        if(this.isMotorChecked == true && this.selectedMotorInsurancePlan && this.motorInsuranceAmountValue){
            this.isSubmitButtonDisabled = false;
        }else{
            this.isSubmitButtonDisabled = true;
        }
    }

    //To enable/disable the consent button.
    // consentButtonEnableDisable() {
    //     if (this.isHealthInsuranceChecked || this.isGPAChecked || this.isComboChecked || this.isMotorChecked) {
    //         this.isConsentButtonDisabled = false;
    //     } else {
    //         this.isConsentButtonDisabled = true;
    //     }
    // }

    


    //Motor Insurance Checkbox Handler
    motorChangeHandler(event) {
        this.iconButton = false;
        this.editPlanFlag = true;
        this.isMotorChecked = event.target.checked;
        //If the insurance product is selected, enable the plan dropdown combobox.
        if (this.isMotorChecked) {
            this.isMotorInsuranceAmountFieldDisabled = false;
            this.motorInsurancePlanComboboxDisabled = false;
            this.motorfunDisab = false;
        } else {
            this.isMotorInsuranceAmountFieldDisabled = true;
            this.motorfunDisab = true;
            this.motorInsurancePlanComboboxDisabled = true;
        }
        if(this.isInsuranceExpWith60Days == true){
            this.InsuranceChangeHandler();
        }
    }

    //Handler for amount input field change.
    hanldeAmountValueChange(event) {
        this.iconButton = false;
        let amountField = event.target.name;

        
        if (amountField === 'motorAmount') {
            this.motorInsuranceAmountValue = event.target.value;
            this.totalInsurancePayable = this.motorInsuranceAmountValue;
        }
        if(this.isInsuranceExpWith60Days == true){
            this.InsuranceChangeHandler();
        }

        const enteredValue = parseFloat(this.motorInsuranceAmountValue);

        if (isNaN(enteredValue) || enteredValue < 0) {
            const evt = new ShowToastEvent({
                title: "Warning",
                message: 'Please enter a valid premium amount!',
                variant: 'warning',
            });
            this.dispatchEvent(evt);
            return;
        }
    }

    //Handler for is funded toggle change.
    handleIsFundedToggle(event) {
        this.iconButton = false;
        let toggleField = event.target.name;
        if (toggleField === 'motorInsurance') {
            this.fundingTypeValueForMotorPlans = event.target.checked;
            if(event.target.checked){
                this.fundedPremiumValue = this.totalInsurancePayable;
            }else{
                this.fundedPremiumValue = 0;
            }
        }
        if(this.isInsuranceExpWith60Days == true){
            this.InsuranceChangeHandler();
        }
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
        let productType;
        await getProductTypeFromOpp({ recordId: this.recordId })
        .then(result => {
            console.log('result[0]' + JSON.stringify(result));
            productType = result[0].Product_Type__c;
        })
        .catch(error =>{
            console.log('error in getProductTypeFromOpp => ' , error);
        })

        if ((productType === this.label.TwoWheeler) && ((this.isComboChecked == true) &&
            (this.isGPAChecked == true || this.isHealthInsuranceChecked == true))) {
            console.log('in handleFundingAvailability  TW1');
            const event = new ShowToastEvent({
                title: 'Error',
                message: COMBO_GPA_OR_HEALTH_LABEL,
                variant: 'error',
            });
            this.dispatchEvent(event);
        } else if ((productType === this.label.PassengerVehicles) && ((this.isGPAChecked == true) && (this.isComboChecked == true))) {
            console.log('in handleFundingAvailability  PV1');
            const event = new ShowToastEvent({
                title: 'Error',
                message: GPA_OR_COMBO_LABEL,
                variant: 'error',
            });
            this.dispatchEvent(event);
        }
        else {
            console.log('in handleFundingAvailability  else');
            //JS Object for Selected Insurance Details 
            console.log('this.recordId====>', this.recordId);
            const selectedInsuranceDetails = {
                loanApplicationId: this.recordId,
            };

            if (this.isHealthInsuranceChecked) {
                const healthInsurance = {
                    selectedProduct: HEALTH,
                    selectedPlan: this.selectedHealthInsurancePlan,
                    isFunded: this.fundingTypeValueForHealthInsurancePlans,
                    premium: this.healthInsuranceAmountValue
                };
                selectedInsuranceDetails['healthInsurance'] = healthInsurance;
            }
            if (this.isGPAChecked) {
                const gpaInsurance = {
                    selectedProduct: GPA,
                    selectedPlan: this.selectedGPAInsurancePlan,
                    isFunded: this.fundingTypeValueForGPAPlans,
                    premium: this.gpaInsuranceAmountValue
                };
                selectedInsuranceDetails['gpaInsurance'] = gpaInsurance;
            }
            if (this.isComboChecked) {
                const comboInsurance = {
                    selectedProduct: COMBO,
                    selectedPlan: this.selectedComboInsurancePlan,
                    isFunded: this.fundingTypeValueForComboPlans,
                    premium: this.comboInsuranceAmountValue
                };
                selectedInsuranceDetails['comboInsurance'] = comboInsurance;
            }
            if (this.isMotorChecked) {
                const motorInsurance = {
                    selectedProduct: MOTOR,
                    selectedPlan: '',
                    isFunded: this.fundingTypeValueForMotorPlans,
                    premium: this.motorInsuranceAmountValue
                };
                selectedInsuranceDetails['motorInsurance'] = motorInsurance;
            }

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
                    } else if (!response.responseStatus && (this.isHealthInsuranceChecked || this.isGPAChecked || this.isComboChecked)) {
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

            if (!this.isHealthInsuranceChecked && !this.isGPAChecked && !this.isComboChecked && !this.isMotorChecked) {
                this.isConsentButtonDisabled = true;
                const event = new ShowToastEvent({
                    message: NOT_OPTED_INSURANCE_MSG_LABEL,
                    variant: 'info',
                });
                this.dispatchEvent(event);
            }
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
        var getFinalInsData = [];
        var index = 0

        if (this.isMotorChecked) {
            getFinalInsData.push({
                rowNo: ++index,
                Name: MOTOR,
                Amount: this.motorInsuranceAmountValue
            });
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
            this.error = error;
        });
        // }

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

    //method for submitting the selected insurance product and plan.
    async handleSubmit() {
        if (!this.isMotorChecked) {
            const oppFields = {};
            oppFields[OPP_ID_FIELD.fieldApiName] = this.recordId;
            oppFields[STAGENAME.fieldApiName] = 'Loan Initiation';
            oppFields[SUB_STAGE_NAME.fieldApiName] = 'User Details';
            this.updateRecordDetails(oppFields);
            this.isSubmitButtonDisabled = true;
            console.log('Active tab :'+this.activeTab);
        }else if (this.isMotorChecked) {
            const saveDetails = {
                loanApplicationId: this.recordId,
                nextStage: 'Loan Initiation',
                applicantId: this.applicantId,
                totalInsurancePayable: this.totalInsurancePayable,
                applicantType: "Borrower",
                premiumFunded: this.fundedPremiumValue
            }

            if (this.isMotorChecked) {
                const enteredValue = parseFloat(this.motorInsuranceAmountValue);

                if (isNaN(enteredValue) || enteredValue < 0) {
                    const evt = new ShowToastEvent({
                        title: "Warning",
                        message: 'Please enter a valid premium amount!',
                        variant: 'warning',
                    });
                    this.dispatchEvent(evt);
                    return;
                }
                if(this.isInsuranceExpWith60Days == true){
                    if(!this.selectedMotorInsurancePlan && !this.motorInsuranceAmountValue){
                        const evt = new ShowToastEvent({
                            title: "Warning",
                            message: 'Please fill all required fields!',
                            variant: 'warning',
                        });
                        this.dispatchEvent(evt);
                        return;
                    }
                }
                const motorInsurance = {
                    selectedProduct: MOTOR,
                    selectedPlan: this.selectedMotorInsurancePlan,
                    isFunded: this.fundingTypeValueForMotorPlans,
                    premium: this.motorInsuranceAmountValue
                    
                };
                saveDetails.insProductDetails = [];
                saveDetails.insProductDetails.push(motorInsurance);
            }

            //await this.doFicoDeviationCallout();
            console.log('saveDetails :: 1265', saveDetails);
            await submitInsuranceDetails({
                payload: JSON.stringify(saveDetails)
            })
            .then(result => {
                if (result === this.label.SuccessMessage) {
                    const oppFields2 = {};
                    oppFields2[OPP_ID_FIELD.fieldApiName] = this.recordId;
                    oppFields2[STAGENAME.fieldApiName] = 'Loan Initiation';
                    oppFields2[SUB_STAGE_NAME.fieldApiName] = 'User Details';
                    this.updateRecordDetails(oppFields2);
                    this.isSubmitButtonDisabled = true;
                    this.disableEverything();
                    doVehicleValuationCallout({loanAppId : this.recordId, screen : 'insurance'})
                    .then(result=>{
                        this.dispatchEvent(new CustomEvent('submitnavigation', { detail: 'Post Initial Offer' }));
                    }).
                    catch(error=>{
                        this.dispatchEvent(new CustomEvent('submitnavigation', { detail: 'Post Initial Offer' }));
                    });
                    
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


    async handleHome() {
        if ((this.isHealthInsuranceChecked || this.isGPAChecked || this.isComboChecked || this.isMotorChecked) && !this.isSubmitButtonDisabled) {
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
            this.isMotorChecked = false;
            //this.showSubmitButton = false;
            this.template.querySelectorAll('.isFundedCheckbox')
                .forEach((element) => {
                    element.disabled = true;
                    // element.value = false;
                });
        }
        if (this.activeTab === this.label.Borrower) {
            //this.showSubmitButton = true;
            this.disableMotorInsuranceSection = false;
        }
        // console.log('inside rendercallback ', this.currentStage, ' ', this.subStage)
        if (this.currentStage === this.label.CreditProcessing && this.subStage == 'View Application Details') {
            this.disableEverything();
            this.isEnableNext = true;
            if (this.template.querySelector('.next')) { this.template.querySelector('.next').disabled = false; }

        }
        if (this.motorPlanList && this.motorPlanList.length === 0) {
            this.isMotorDisabled = true;
        }
        if (this.editPlanFlag && this.currentStage === this.label.CreditProcessing) {
            //  console.log('line1336==>' + this.editPlanFlag);
            this.editPlanFlag = false;
            this.fundisabled = false;
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

    async updateRecordDetails(fields) {
        const recordInput = { fields };
        console.log('before update ', recordInput);
        updateRecord(recordInput)
            .then(() => {
                console.log('record  is updated successfully');
            })
            .catch(error => {
                console.log('record update error', error);
            });
    }

    async handleConcentCall() {
        if ((this.isHealthInsuranceChecked || this.isGPAChecked || this.isComboChecked || this.isMotorChecked) && this.iconButton) {
            const saveDetails = {
                loanApplicationId: this.recordId,
                nextStage: 'Insurance Details',
                applicantId: this.applicantId,
                ltvWithInsurance: this.ltvWithInsurance,
                ltvWithoutInsurance: this.ltvWithoutInsurance,
                totalInsurancePayable: this.totalInsurancePayable,
                proposalLtv: this.proposalLtv,
                applicantType: this.activeTab,
                premiumFunded: this.fundedPremiumValue
            }

            if (this.isMotorChecked) {
                const motorInsurance = {
                    selectedProduct: MOTOR,
                    selectedPlan: this.selectedMotorInsurancePlan,
                    isFunded: this.fundingTypeValueForMotorPlans,
                    premium: this.motorInsuranceAmountValue
                };
                saveDetails['motorInsurance'] = motorInsurance;
            }


            console.log('saving details :: 1772', saveDetails);
            await submitInsuranceDetails({
                payload: JSON.stringify(saveDetails)
            })
                .then(result => {
                    console.log(' Line no 1777 => applicatnt ID', this.applicantId);
                    if (result === this.label.SuccessMessage) {
                        console.log(' Line no 1779 => success');
                        const evt = new ShowToastEvent({
                            title: 'Success',
                            message: this.label.detailsSaved,
                            variant: 'Success',
                        });
                        this.dispatchEvent(evt);
                    }
                })
                .catch(error => {
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

    disableEverything(){
        let allElements = this.template.querySelectorAll('*');
        allElements.forEach(element =>
            element.disabled = true
        );
    }
}