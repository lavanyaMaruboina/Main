/**
 * Created by nagen on 08-01-2022.
 */
import { api, LightningElement, track } from 'lwc';
import loadSelectedSchemeData from '@salesforce/apex/IND_OfferScreenController.loadSelectedSchemeData';
import loadOfferScreenData from '@salesforce/apex/IND_OfferScreenController.loadOfferScreenData';
import getOfferScreenData from '@salesforce/apex/IND_OfferScreenController.getOfferScreenData';
import roiMasterForImputedIRR from '@salesforce/apex/IND_OfferScreenController.roiMasterForImputedIRR'; //CISP-5450
import roiMaster from '@salesforce/apex/IND_OfferScreenController.roiMaster';
import { updateRecord } from 'lightning/uiRecordApi';
import doOfferEngineCallout from '@salesforce/apexContinuation/IntegrationEngine.doOfferEngineCallout';
import checkRetryExhausted from '@salesforce/apex/IND_OfferScreenController.checkRetryExhausted';
import retryCountIncrease from '@salesforce/apex/IND_OfferScreenController.retryCountIncrease';
import isCommunity from '@salesforce/apex/LwcLOSLoanApplicationCntrl.isCommunity';
import updateRetryCount from '@salesforce/apex/IND_OfferScreenController.updateRetryCount';
import { loadStyle } from 'lightning/platformResourceLoader';
import FORM_FACTOR from '@salesforce/client/formFactor';
import LightningCardCSS from '@salesforce/resourceUrl/loanApplication';

//Custom Fields 
import RetryExhausted from '@salesforce/label/c.Retry_Exhausted';
import externalRefinance from '@salesforce/label/c.externalRefinance';
import InternalRefinance from '@salesforce/label/c.InternalRefinance';
import Refinance from '@salesforce/label/c.Refinance';

//fields of Offer Screen
import OPP_ID_FIELD from '@salesforce/schema/Opportunity.Id';
import STAGENAME from '@salesforce/schema/Opportunity.StageName';
import LASTSTAGENAME from '@salesforce/schema/Opportunity.LastStageName__c';
import opportunityId from '@salesforce/schema/Opportunity.Id';
import Journey_Status from '@salesforce/schema/Opportunity.Journey_Status__c';
import final_ID_FIELD from '@salesforce/schema/Final_Term__c.Id';
import Loan_Amount from '@salesforce/schema/Final_Term__c.Loan_Amount__c';
import Advance_EMI from '@salesforce/schema/Final_Term__c.Advance_EMI__c';
import Holiday_period from '@salesforce/schema/Final_Term__c.Holiday_period__c';
import Inputted_IRR from '@salesforce/schema/Final_Term__c.Inputted_IRR__c';
import Net_IRR from '@salesforce/schema/Final_Term__c.Net_IRR__c';
import OfferengineMaxTenure from '@salesforce/schema/Final_Term__c.OfferengineMaxTenure__c';
import OfferengineMinTenure from '@salesforce/schema/Final_Term__c.OfferengineMinTenure__c';
import OfferengineStopJourneyFlag from '@salesforce/schema/Final_Term__c.Offerengine_StopJourney_Flag__c';
import OfferengineMinLoanAmount from '@salesforce/schema/Final_Term__c.OfferengineMinLoanAmount__c';
import OfferengineMaxLoanAmount from '@salesforce/schema/Final_Term__c.OfferengineMaxLoanAmount__c';
import Gross_IRR from '@salesforce/schema/Final_Term__c.Gross_IRR__c';
import IsOfferEngineApiFailed from '@salesforce/schema/Final_Term__c.IsOfferEngineApiFailed__c';
import CRM_IRR from '@salesforce/schema/Final_Term__c.CRM_IRR__c';
import Required_CRM_IRR from '@salesforce/schema/Final_Term__c.Required_CRM_IRR__c';
import IsRequiredCRMIRRChanged from '@salesforce/schema/Final_Term__c.IsRequiredCRMIRRChanged__c';
import Tenure from '@salesforce/schema/Final_Term__c.Tenure__c';
import EMI_Amount from '@salesforce/schema/Final_Term__c.EMI_Amount__c';
import getVechicleDetails from '@salesforce/apex/IND_OfferScreenController.getVechicleDetails';
import isNavigate from '@salesforce/schema/Final_Term__c.isNavigate__c';
import Provisional_Channel_Cost from '@salesforce/schema/Final_Term__c.Provisional_Channel_Cost__c';//CISP-124
//import createFIRecord from '@salesforce/apex/FinalTermscontroller.createFIRecord';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import clickSubmitButton from '@salesforce/label/c.clickSubmitButton'
import changePayinAndPayout from '@salesforce/label/c.changePayinAndPayout'
import enterEMIDays from '@salesforce/label/c.enterEMIDays'
import changeTenure from '@salesforce/label/c.changeTenure';
import changeMoratoriumDay from '@salesforce/label/c.changeMoratoriumDay';
import loanTenureChange from '@salesforce/label/c.loanTenureChange';
import loanAdvanceChanged from '@salesforce/label/c.loanAdvanceChanged';
import loanDayChanged from '@salesforce/label/c.loanDayChanged';
import loanCrm from '@salesforce/label/c.loanCrm';
import crmChanged from '@salesforce/label/c.crmChanged';
import crmLessThan from '@salesforce/label/c.crmLessThan';
import crmIrrNotNeg from '@salesforce/label/c.crmIrrNotNeg';
import loanNotChanged from '@salesforce/label/c.loanNotChanged';
import nothingChanged from '@salesforce/label/c.nothingChanged';
import crmmaxchange from '@salesforce/label/c.crmmaxchange';
import crmminchange from '@salesforce/label/c.crmminchange';
import loanamtmissing from '@salesforce/label/c.loanamtmissing';
import changeCheckEligibility from '@salesforce/label/c.changeCheckEligibility';
import ReadOnlyLeadAccess from '@salesforce/label/c.ReadOnlyLeadAccess';
import submitWarning from '@salesforce/label/c.submitWarning';
import getFinalTermFieldDetails from '@salesforce/apex/FinalTermscontroller.getFinalTermFieldValidationDetails';//CISP-124
import getLoanApplicationReadOnlySettings from '@salesforce/apex/LwcLOSLoanApplicationCntrl.getLoanApplicationReadOnlySettings';//Ola integration changes
import updateJourneyStop from '@salesforce/apex/customerDedupeRevisedClass.updateJourneyStop'; //CISP-4459
import getDocumentsToCheckPan from '@salesforce/apex/IND_LWC_LoanDetailsCntrl.getDocumentsToCheckPan'; //CISP-3938
import Table_Code from '@salesforce/schema/Final_Term__c.Table_Code__c';//CISP-16547 
import DR_Penal_Interest from '@salesforce/schema/Final_Term__c.DR_Penal_Interest__c';//CISP-16547
import Interest_Version_No from '@salesforce/schema/Final_Term__c.Interest_Version_No__c';//CISP-16547 
import mclrRate from '@salesforce/schema/Final_Term__c.mclrRate__c';//CISP-16547 
import Net_Pay_Ins from '@salesforce/schema/Final_Term__c.Net_Pay_Ins__c';//CISH-36
import Net_Pay_Outs from '@salesforce/schema/Final_Term__c.Net_Pay_Outs__c';//CISH-36
import service_charge from '@salesforce/schema/Final_Term__c.Service_charges__c';//CISH-36
import Mfr_incentive from '@salesforce/schema/Final_Term__c.Mfr_incentive__c';//CISH-36
import Dealer_incentive_amount_main_dealer from '@salesforce/schema/Final_Term__c.Dealer_incentive_amount_main_dealer__c';//CISH-36
import doc_charge from '@salesforce/schema/Final_Term__c.Documentation_charges__c';//CISH-36
import doD2COfferEngineCallout from '@salesforce/apexContinuation/D2C_IntegrationEngine.doD2COfferEngineCallout';//CISH-36  
export default class LwcOfferScreen extends NavigationMixin(LightningElement) {
    oppTotalExposureAmt; fundedPremiumValue;documentCheckdata;//CISP-3938
    @track crmIRR;@track requiredCRMIRR;@track minLoanAmount;@track minTenure;@track maxLoanAmount;@track maxTenure;@track emi;@track loanAmount;@track tenure;@track loanTimeoutId;@track tenureTimeoutId;@track loanSliderDisabled = false;@track tenureSliderDisabled = false;@track isTenureChanged = false;@track isRecordId;@track requiredCRMIRRPopup = false;@track isTenureEligibleCheck = false;@track isloanAmountCheck = false;@track isChangePayInOutButtonDisable = false;//CISP-2643
    @track currentStageName;@track lastStage;
    isSpinnerMoving = false;
    advanceEMi;
    advanceEmis;
    orp;
    totalFundedPremium=0;
    requiredCrmIrr;
    loanAmountFinal;
    monitoriumDaysDisabled = false;
    monitoriumDaysValue;
    monitoriumDaysValueFinal;
    priceingEngineNetIrr;
    advanceEmiDisabled = false;
    manufacturerYearMonth;
    vehicleAge;
    emiFinal;  //CISP-2361
    flagEmiChange = false;
    handleEmiFlagChange = false;//CISP-2643
    moratoriumDays;
    //Flags
    eligiblityButtonClicked = false;flagtoUpdate = false;flagLoanAmountChange = false;flagRequiredCrrIrrOnlyChanged = false;
    flagTenureChange = false;flagRequiredCrrIrrChange = false; flagAdvanceEmiChange = false;flagMonitoriumDays = false;tenureFinal;flagApiFail = false;
    /* showCustomerCode =false;
    showOfferScreen = true;
    showFinalTerm = false; */
    @track mincrm;@track maxcrm;@track EligibleLoanAmt;@track EligibleTenure;@track productSegment;//CISP-13665
    @track vechSubCategory = '';@track vehicleType;@track productType;@track getTenureValue;@api recordid;@api checkleadaccess;//coming from tabloanApplication
    // @track applicantId = 'a0U71000000ATTlEAO';
    @track handleTenureChangebln = false;@track isProductTypePV = false;@track numberOfInstallmentValue = '';@track netIRRValue = '';@track grossIRRValue = '';selectedSchemeId;schemeValid=false;
    @track disabledEmiAmount=true;//CISP-2505
    fromRendercallback=false;//CISP-2505
    //CISP-124
    provisionAmount = 0;provisionalChannelCostMinValid = 0;provisionalChannelCostMaxValid = 0;provisionalChannelCostTwoValid = 0;provisionalChannelCostValid = 0;
    //CISP-124
    oppRecord;//CISP-2522
    vehRecord;//CISP-2522
    disableCheckEligibility=false;//CISP-2643
    disableSubmit=false;//CISP-2643
    leadSource;//Ola Integration changes
    disableCancel;//Hero CISH-13
    isOfferengineApiFail = false;//CISH-36
    isSmallDevice = false;
    //connected callback code
    async connectedCallback() {
        if(FORM_FACTOR !== 'Large'){
            this.isSmallDevice = true;
        }
        var monitoriumDaysList = new Array()
        this.disabledCrmIrr = true;
        this.disabledEmiAmount = true;

            await getVechicleDetails({ loanApplicationId: this.recordid })
            .then(result => {
                this.currentStageName = result.Loan_Application__r.StageName,
                this.lastStage = result.Loan_Application__r.LastStageName__c,
                this.EligibleTenure = result.Eligible_Tenure__c;
                this.productSegment = result.Product_Segment__c;
                this.EligibleLoanAmt = result.Eligible_Loan_Amount__c;
                this.oppTotalExposureAmt = result.Loan_Application__r.Total_Exposures_Amount__c;
                this.fundedPremiumValue = result.Loan_Application__r.Total_Funded_Premium__c;
                if (result.Loan_Application__r.Vehicle_Sub_Category__c) {
                    this.vechSubCategory = result.Loan_Application__r.Vehicle_Sub_Category__c;
                }
                if(this.vechSubCategory.toLowerCase() === 'UIM'.toLowerCase()){
                    this.maxLoanAmount = result.Eligible_Loan_Amount__c;
                    this.maxTenure = result.Eligible_Tenure__c;
                }
                this.vehicleType = result.Loan_Application__r.Vehicle_Type__c;
                this.manufacturerYearMonth = result.Manufacturer_Year_Month__c;
                this.productType = result.Loan_Application__r.Product_Type__c;
                this.leadSource = result.Loan_Application__r.LeadSource;//Ola Integration changes
                //Pick list value for monitorium Days. 
                monitoriumDaysList.push({ label: '0', value: '0' });
                monitoriumDaysList.push({ label: '30', value: '30' })
                this.monitoriumDaysOption = monitoriumDaysList;
                //age if vehicle Calculated here.
                let monthAndYear
                if (result.Manufacturer_Year_Month__c) {
                    monthAndYear = this.manufacturerYearMonth.split('-');
                    let currentTime = new Date();
                    let year = currentTime.getFullYear();
                    let month = currentTime.getMonth();
                    let ageval = Math.abs(year - monthAndYear[0]) * 12;
                    let age = ageval + Math.abs(month - monthAndYear[1]);
                  //  let age = Math.abs(year - monthAndYear[0]);
                    this.vehicleAge = age;
                }
                if(this.productType == 'Passenger Vehicles'){
                    this.isProductTypePV = true;
                }
                this.loadoffer();
            
            })
            .catch(error => {console.log('Error in getVechicleDetails ',error)});
            //CISP-124
            await getFinalTermFieldDetails({ opportunityId: this.recordid })
               .then(result => {
                   console.log('result --> ', result);
                   if(result){
                       const finalTermData=result.finalTermVal[0];
                       if(finalTermData){
                       this.provisionalChannelCostValid=finalTermData.ProvisionalChannelCost__c;
                       this.provisionalChannelCostTwoValid=finalTermData.ProvisionalChannelCostTwo__c;
                       this.provisionalChannelCostMaxValid=finalTermData.ProvisionalChannelCostMax__c;
                       this.provisionalChannelCostMinValid=finalTermData.ProvisionalChannelCostMin__c;
                       this.calculateProvisionAmt(this.loanAmount, this.tenure);
                       }
                   }
               });
               //CISP-13665
               if(this.productType.toLowerCase() === 'Two Wheeler'.toLowerCase() && this.productSegment && this.productSegment==='ESCOOTER'){
                this.minLoanAmount = 25000;
            }
            //CISP-13665
               //CISP-124
               //Ola integration changes
               await getLoanApplicationReadOnlySettings({leadSource:this.leadSource})
               .then(data => {
                   let fieldList = [];if(data){fieldList=data.Input_Labels__c.split(';');}

                   
                   console.log(fieldList);
                   if(fieldList.length>0){
                       this.loanSliderDisabled = fieldList.includes('Loan Amount')? true :this.loanSliderDisabled;
                       this.disabledLoanAmount = fieldList.includes('Loan Amount')? true :this.disabledLoanAmount;
                       this.tenureSliderDisabled = fieldList.includes('Tenure')? true :this.tenureSliderDisabled;
                       this.disabledTenure = fieldList.includes('Tenure')? true :this.disabledTenure;
                       this.disabledCrmIrr = fieldList.includes('CRM IRR')? true :this.disabledCrmIrr;
                       this.disabledRequiredCrmIrr = fieldList.includes('Required CRM IRR')? true :this.disabledRequiredCrmIrr;
                       this.advanceEmiDisabled = fieldList.includes('Advance EMI')? true :this.advanceEmiDisabled;
                       this.disabledEmiAmount = fieldList.includes('EMI Amount')? true :this.disabledEmiAmount;
                       this.isChangePayInOutButtonDisable = fieldList.includes('Change Pay In/Pay Outs')? true :this.isChangePayInOutButtonDisable;
                       this.disableCheckEligibility = fieldList.includes('Check Eligibility')? true :this.disableCheckEligibility;
                       this.monitoriumDaysDisabled = true;
                   }
               }).catch(error => { });
               //Ola Integration changes

            console.log('this.checkleadaccess ',this.checkleadaccess);
            if(this.checkleadaccess){//if lead is accessible but user from different profile is viewing that
                const evt = new ShowToastEvent({
                    title: ReadOnlyLeadAccess,
                    variant: 'warning',
                    mode: 'sticky'
                });
                this.dispatchEvent(evt);
                this.disableEverything();
            }
            if (this.productType.toLowerCase() === 'Two Wheeler'.toLowerCase() && this.leadSource !='Hero') {//Enhancement for INDI-4682 && CISH-100
               if (this.checkleadaccess===false) {//Start CISP-2505
                   this.disabledEmiAmount=false;
                }//End CISP-2505
                this.disabledCrmIrr=true;
                this.disabledRequiredCrmIrr=true;
                roiMaster({loanApplicationId : this.recordid,productType : this.productType,tenure : parseInt(this.tenure,10),vehicleCategory : this.vehicleType})
                .then(result => {
                    let parsedData = JSON.parse(result);
                    if(parsedData.mincrm != null && parsedData.maxcrm != null){
                        this.mincrm = parsedData.mincrm;
                        this.maxcrm = parsedData.maxcrm;
                    }});
            }
             else{
                roiMasterForImputedIRR({loanApplicationId : this.recordid,productType : this.productType,tenure : parseInt(this.tenure,10),vehicleCategory : this.vehicleType,queryBased:'CRM_IRR'})
                .then(result => {
                    let parsedData = JSON.parse(result);
                    if(parsedData.mincrm != null && parsedData.maxcrm != null){
                        this.mincrm = parsedData.mincrm;
                        this.maxcrm = parsedData.maxcrm;
                    }});
             }
             getDocumentsToCheckPan({ loanApplicationId: this.recordid })
               .then(result => {
                console.log('Result', result);
                    this.documentCheckdata = JSON.parse(result);
               })
               .catch(error => {
                 console.error('Error:', error);
             });
             if(this.leadSource=='Hero'){//Hero CISH-13
                this.disableCancel = true;
                this.template.querySelector('lightning-input[data-id=emi]').disabled = true;
                this.template.querySelector('.changePayInPayOut').disabled = true;
                this.template.querySelector('.checkEligibility').disabled = false;
                this.loanSliderDisabled = false;
                this.disabledLoanAmount = false;
                this.tenureSliderDisabled = false;
                this.disabledTenure = false;
             }//Hero CISH-13
    }

    calculateNumberOfInstallments(moratoriumDays, tenureValue){// INDI-4652
        let moratorium = (moratoriumDays == null || moratoriumDays == undefined || moratoriumDays == '') ? 0 : moratoriumDays;
        this.numberOfInstallmentValue = parseInt(moratorium) == 0 ? tenureValue : parseInt(moratorium) == 30 ? (parseInt(tenureValue) - 1) : '';
         if(this.leadSource=='OLA'){this.numberOfInstallmentValue = parseInt(tenureValue)};//OLA-139
    }

    async loadoffer() {
        let randomNumber = Math.random();
        loadOfferScreenData({ loanApplicationId: this.recordid ,randomvar: randomNumber})
            .then((data) => {
                let parsedData = JSON.parse(data);
                if(parsedData.stopJourneyFlag != true)
                {
                this.oppRecord = parsedData.oppRecord;//CISP-2522
                this.vehRecord = parsedData.vehRecord;//CISP-2522
                this.selectedSchemeId = parsedData.schemeId;
                this.loanAmount = parsedData.loanAmount;
                this.loanAmountFinal = parsedData.loanAmount;
                this.maxLoanAmount = parsedData.maxLoanAmtSlider;
                this.minLoanAmount = parsedData.minLoanAmtSlider;
                this.maxTenure = parsedData.maxTenureSlider;
                this.minTenure = parsedData.minTenureSlider;
                this.tenure = parsedData.tenure;
                this.tenureFinal = parsedData.tenure;
                this.emi = parsedData.emi;
                this.emiFinal = parsedData.emi;//CISP-2361
                this.orp = parsedData.orp;
                this.totalFundedPremium=parsedData.totalFundedPremium;
                this.crmIRR = parsedData.crmIRR;
                this.requiredCRMIRR = parsedData.requriedCRMIRR;
                this.requiredCrmIrr = parsedData.requriedCRMIRR;
                if (this.productType.toLowerCase() === 'Two Wheeler'.toLowerCase()) {//Enhancement for INDI-4682
                    this.requiredCRMIRR=this.crmIRR;
                    this.requiredCrmIrr=this.crmIRR;
                }
                this.isRecordId = parsedData.getrecordId;
                this.advanceEMi = parsedData.advanceEmi;
                this.advanceEmis = parsedData.advanceEmi;
                this.monitoriumDaysValue = parsedData.monitoriumDays;
                this.monitoriumDaysValueFinal = parsedData.monitoriumDays;
                this.priceingEngineNetIrr = parsedData.priceingEngineNetIrr;
                if(this.vechSubCategory.toLowerCase() === 'UIM'.toLowerCase()){
                    this.maxLoanAmount = this.EligibleLoanAmt;
                    this.maxTenure = this.EligibleTenure;
                }
                if (this.advanceEMi === true) {
                    this.template.querySelector('lightning-input[data-id=advanceEMIid]').checked = true;
                    this.monitoriumDaysDisabled = true;
                    this.monitoriumDaysValue = null;
                }
                if (this.monitoriumDaysValue != null) {
                    this.advanceEmiDisabled = true;
                }
                if (this.emi == null) {
                    this.disabledLoanAmount = true;
                    this.disabledTenure = true;
                    this.disabledCrmIrr = true;
                    this.disabledRequiredCrmIrr = true;
                    this.disabledEmiAmount = true;
                    this.advanceEmiDisabled = true;
                    this.monitoriumDaysDisabled = true;
                    this.flagApiFail = true;
                    if(this.loanAmount != null && this.tenure != null)
                    {
                        this.flagtoUpdate = true;
                    }
                    this.getOfferScreenDatas();
                
                    
                }
                this.handleSliderRanges();

                this.moratoriumDays = parsedData.monitoriumDays;
                let tenureValue = parsedData.tenure ? parsedData.tenure : this.tenure;
                this.netIRRValue = parsedData.netIRR;
                this.grossIRRValue = parsedData.grossIRR;
                this.calculateNumberOfInstallments(this.moratoriumDays, tenureValue);
                if(this.productType.toLowerCase() === 'Two Wheeler'.toLowerCase() && this.selectedSchemeId){
                    this.selectedSchemeRecord();
                }
            }
            else{
                this.toastMsg('Journey Stoped');
                            let allElements = this.template.querySelectorAll('*');
                            allElements.forEach(element =>
                            element.disabled=true
                            );
                            this.isSpinnerMoving = false;
                            this.template.querySelector('.cancel').disabled=false;
            }
            })
            .catch((error) => { console.log('error in loadOfferScreenData ',error);})
    }
    handleSliderRanges() {
        if (this.tenureFinal < this.minTenure || this.tenureFinal > this.maxTenure) {
            this.tenureSliderDisabled = true;
        }
        else {
            this.tenureSliderDisabled = false;
        }
        if (this.loanAmountFinal < this.minLoanAmount || this.loanAmountFinal > this.maxLoanAmount) {
            this.loanSliderDisabled = true;
        }
        else {
            this.loanSliderDisabled = false;
        }
    }

    getOfferScreenDatas() {
        getOfferScreenData({ loanApplicationId: this.recordid })
            .then(response => {
                let result = JSON.parse(response);
                if(!this.loanAmount){this.loanAmount = result.loanAmount;}
                this.tenure = result.tenure;
                this.maxTenure = result.tenure;
                this.crmIRR = result.roi;
                this.requiredCRMIRR = result.roi;
                this.minTenure = 0;
                //this.minLoanAmount = '';
                this.maxLoanAmount = result.loanAmount;
                this.emi = null;
                this.loanSliderDisabled = true;
                this.tenureSliderDisabled = true;
                this.calculateNumberOfInstallments(this.moratoriumDays, this.tenure);
                if(this.productType.toLowerCase() === 'Passenger Vehicles'.toLowerCase() && (this.flagApiFail || this.isOfferengineApiFail)){
                    let isLoanAmountUpdated= false;
                    if (this.vehicleType.toLowerCase() === 'New'.toLowerCase() && this.oppRecord.Funding_on_Ex_Showroom__c && this.oppRecord.Ex_showroom_price__c && ((parseFloat(this.loanAmount) + parseFloat(this.totalFundedPremium)) > parseFloat(this.oppRecord.Ex_showroom_price__c))) {
                        isLoanAmountUpdated = true;
                        this.loanAmount = this.oppRecord.Ex_showroom_price__c;
                    }else if (this.vehicleType.toLowerCase() === 'New'.toLowerCase() && this.oppRecord.Funding_on_ORP__c && this.orp && ((parseFloat(this.loanAmount) + parseFloat(this.totalFundedPremium)) > parseFloat(this.orp))) {
                        isLoanAmountUpdated = true;
                        this.loanAmount = this.orp;
                    }else if ((this.vehicleType.toLowerCase() === 'Refinance'.toLowerCase() || this.vehicleType.toLowerCase() === 'Used'.toLowerCase()) && this.vehRecord.Base_Prices__c && ((parseFloat(this.loanAmount) + parseFloat(this.totalFundedPremium)) > parseFloat(this.vehRecord.Base_Prices__c))) {
                        isLoanAmountUpdated = true;
                        this.loanAmount = this.vehRecord.Base_Prices__c;
                    }
                    if (isLoanAmountUpdated){
                        const event = new ShowToastEvent({
                            title: 'Warning',
                            message: 'Loan amount is changed to '+ this.loanAmount +'. Please continue and change the loan amount in Income screen if required',
                            variant: 'warning',
                        });
                        this.dispatchEvent(event);
                     }
                 }
                if(!this.flagtoUpdate){
                const FinalTermFields = {};
                FinalTermFields[final_ID_FIELD.fieldApiName] = this.isRecordId;
                FinalTermFields[EMI_Amount.fieldApiName] = null;
                FinalTermFields[Tenure.fieldApiName] = result.tenure.toString();
                FinalTermFields[Loan_Amount.fieldApiName] = result.loanAmount.toString();
                FinalTermFields[CRM_IRR.fieldApiName] = result.roi;
                FinalTermFields[Required_CRM_IRR.fieldApiName] = result.roi.toString();
                //CISP-124
                if(this.provisionAmount){
                   FinalTermFields[Provisional_Channel_Cost.fieldApiName] = this.provisionAmount.toString();
                }
                //CISP-124
                this.updateRecordDetails(FinalTermFields);
                }
            })
            .catch(error => { console.log('Error in getOfferScreenData ',error);});
    }

    handleCancel() {
        this.navigateToHomePage();
    }

    toastMsg(message){
        const evt = new ShowToastEvent({
            title: "Error",
            message: message,
            variant: 'error',
        });
        this.dispatchEvent(evt);
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

    //Submit Button handler
    async handleButtonClick(event) {
        if(this.selectedSchemeId && this.schemeValid===true){ this.selectedSchemeRecord();} else {
        if (!this.advanceEMi && (this.monitoriumDaysValue == '0' || this.monitoriumDaysValue == ' ' ||this.monitoriumDaysValue == null ) ) {
            let elem = this.template.querySelector('lightning-input[data-id=advanceEMIid]');
            elem.setCustomValidity("");
            elem.setCustomValidity('Enter advance EMI Value');
            elem.reportValidity();
            const event = new ShowToastEvent({
                title: 'Warning',
                message: enterEMIDays,
                variant: 'Warning'
            });
            this.dispatchEvent(event);
        }else if ((!this.flagApiFail && !this.isOfferengineApiFail) && (this.vehicleType.toLowerCase() === 'Refinance'.toLowerCase() || this.vehicleType.toLowerCase() === 'Used'.toLowerCase()) && this.vehRecord.Base_Prices__c!=null && (parseFloat(this.loanAmount)) > parseFloat(this.vehRecord.Base_Prices__c)) {//CISP-7754 
            const event = new ShowToastEvent({
                title: 'Warning',
                message: 'Loan amount is out of bounds. Please enter value less than Base Price '+ this.vehRecord.Base_Prices__c,
                variant: 'Warning',
             });
             this.dispatchEvent(event); 
             return; 
            }//CISP-7754

         else if (this.productType.toLowerCase() === 'Two Wheeler'.toLowerCase() && ((Number(this.tenure) %6 != 0) || (this.tenure === 0 || this.tenure === '0' || this.tenure === '' || this.tenure === null || this.tenure === undefined))) {
            this.toastMsg('Tenure is required. Please enter value multiple of 6');
         }
        else if (this.productType.toLowerCase() === 'Two Wheeler'.toLowerCase() && this.flagLoanAmountChange && (parseFloat(this.loanAmount) < parseFloat(this.minLoanAmount) || parseFloat(this.loanAmount) > parseFloat(this.maxLoanAmount)) && (!this.flagTenureChange && !this.flagAdvanceEmiChange && !this.flagRequiredCrrIrrChange && !this.flagMonitoriumDays && !this.flagEmiChange)){//Start CISP-2881
           this.handleSubSubmit();
        }
        else if (this.productType.toLowerCase() === 'Two Wheeler'.toLowerCase() && this.flagLoanAmountChange && (parseFloat(this.loanAmount) < parseFloat(this.minLoanAmount) || parseFloat(this.loanAmount) > parseFloat(this.maxLoanAmount)) && (this.flagTenureChange || this.flagAdvanceEmiChange || this.flagRequiredCrrIrrChange || this.flagMonitoriumDays || this.flagEmiChange)){
           const event = new ShowToastEvent({
               title: 'Warning',
               message: 'Loan amount is changed kindly click on Check Eligibility Button',
               variant: 'warning',
           });
           this.dispatchEvent(event);
        }
        else if(this.productType.toLowerCase() !== 'Two Wheeler'.toLowerCase() && this.flagRequiredCrrIrrChange){
            const event = new ShowToastEvent({
                title: 'Warning',
                message: 'CRM IRR is changed kindly click on Check Eligibility Button',
                variant: 'warning',
            });
            this.dispatchEvent(event);
         }else if ((!this.flagApiFail && !this.isOfferengineApiFail) && this.productType.toLowerCase() !== 'Two Wheeler'.toLowerCase() && this.vehicleType.toLowerCase() === 'New'.toLowerCase() && this.oppRecord.Funding_on_Ex_Showroom__c == true && this.oppRecord.Ex_showroom_price__c!=null && ((parseFloat(this.loanAmount)) > parseFloat(this.oppRecord.Ex_showroom_price__c))) {
            const event = new ShowToastEvent({
                title: 'Warning',
                message: 'Loan amount is out of bounds. Please enter value less than Ex Showroom Price '+this.oppRecord.Ex_showroom_price__c,
                variant: 'Warning',
            });
            this.dispatchEvent(event); 
            return;
        }else if ((!this.flagApiFail && !this.isOfferengineApiFail) && this.productType.toLowerCase() !== 'Two Wheeler'.toLowerCase() && this.vehicleType.toLowerCase() === 'New'.toLowerCase() && this.oppRecord.Funding_on_ORP__c == true && this.orp!=null && ((parseFloat(this.loanAmount)) > parseFloat(this.orp))) { 
            const event = new ShowToastEvent({
                title: 'Warning',
                message: 'Loan amount is out of bounds. Please enter value less than On Road Price '+this.orp,
                variant: 'Warning',
             });
             this.dispatchEvent(event); 
             return;
        }
        else if (this.productType.toLowerCase() !== 'Two Wheeler'.toLowerCase() && this.flagLoanAmountChange && (parseInt(this.loanAmount,10) < this.minLoanAmount || parseInt(this.loanAmount,10) > this.maxLoanAmount) && (this.flagTenureChange || this.flagAdvanceEmiChange || this.flagRequiredCrrIrrChange || this.flagMonitoriumDays || this.flagEmiChange)) {//End CISP-2881
           this.handleSubSubmit();
        }
        else if (this.flagLoanAmountChange && parseInt(this.loanAmount,10) > this.minLoanAmount && parseInt(this.loanAmount,10) < this.maxLoanAmount && this.leadSource!='Hero') {
            const eve = new ShowToastEvent({
                title: 'ERROR',
                message: changePayinAndPayout,
                variant: 'Error',
            });
            this.dispatchEvent(eve);
        }
        else if (this.flagTenureChange && !this.eligiblityButtonClicked) {
            const tenure = new ShowToastEvent({
                title: 'ERROR',
                message: changeTenure,
                variant: 'Error',
            });
            this.dispatchEvent(tenure);

        }
        else if (this.flagAdvanceEmiChange && !this.eligiblityButtonClicked) {
            const emi = new ShowToastEvent({
                title: 'ERROR',
                message: changeCheckEligibility,
                variant: 'Error',
            });
            this.dispatchEvent(emi);
        }
        else if (this.flagRequiredCrrIrrChange == true && !this.eligiblityButtonClicked) {
            const event = new ShowToastEvent({
                title: 'Warning',
                message: crmChanged,
                variant: 'Warning',
            });
            this.dispatchEvent(event);
        }
        else if (this.flagMonitoriumDays && !this.eligiblityButtonClicked) {
            const monitorium = new ShowToastEvent({
                title: 'ERROR',
                message: changeMoratoriumDay,
                variant: 'Error',
            });
            this.dispatchEvent(monitorium);
        }
        //CISP-115 - START
        else if(this.loanAmount == null || this.loanAmount == undefined || this.loanAmount == ''){
            const event = new ShowToastEvent({
                title: 'Error',
                message: loanamtmissing,
                variant: 'Error',
            });
            this.dispatchEvent(event);
            return;
        }else if(this.isOfferengineApiFail == true && this.leadSource == 'Hero'){
            const event = new ShowToastEvent({
                title: 'Warning',
                message: 'Please click on Check Eligibility Button',
                variant: 'Warning',
            });
            this.dispatchEvent(event);
            return;
         } else if(this.leadSource =='Hero' && this.eligiblityButtonClicked == false){
                const event = new ShowToastEvent({
                    title: 'Warning',
                    message: 'kindly click on Check Eligibility Button',
                variant: 'Warning',
            });
            this.dispatchEvent(event);
            return;

        }
        //CISP-115 - END
        else if(this.crmIRR!=null && this.mincrm!=null && this.maxcrm!=null && ((parseFloat(this.crmIRR) < parseFloat(this.mincrm)) || (parseFloat(this.crmIRR) > parseFloat(this.maxcrm)))){//Start INDI-4682 // CISP-2702
           const event = new ShowToastEvent({
               title: 'Error',
               message: 'CRM IRR is not within permissible range. Please change Loan amount / EMI / Tenure to proceed',
               variant: 'Error',
           });
           this.dispatchEvent(event);
           return;
       }//End INDI-4682
       else if(this.flagEmiChange && !this.eligiblityButtonClicked){//Start CISP-2361 OR CISP-2644
           const event = new ShowToastEvent({
               title: 'Warning',
               message: 'EMI Amount is changed kindly click on Check Eligibility Button',
               variant: 'Warning',
           });
           this.dispatchEvent(event);
        }//End CISP-2361
        else if(this.productType.toLowerCase() !== 'Two Wheeler'.toLowerCase() && this.requiredCRMIRR!=null && this.mincrm!=null && this.maxcrm!=null && ((parseFloat(this.requiredCRMIRR) < parseFloat(this.mincrm)) || (parseFloat(this.requiredCRMIRR) > parseFloat(this.maxcrm)))){
            const event = new ShowToastEvent({
                title: 'Error',
                message: 'CRM IRR is not as per norms Min ' + this.mincrm + 'and Max '+ this.maxcrm + ' . Please change the required CRM IRR value.',
                variant: 'Error',
            });
            this.dispatchEvent(event);return;
        }
        else if(this.productType.toLowerCase() !== 'Two Wheeler'.toLowerCase()){
            await roiMasterForImputedIRR({ loanApplicationId : this.recordid,productType : this.productType,tenure : parseInt(this.tenure,10),vehicleCategory : this.vehicleType, queryBased: 'NET_IRR' })
            .then(result => {
              console.log('Result', result);
              let parsedData = JSON.parse(result);
              let minNetIrr = parsedData.mincrm;
              let maxNetIrr = parsedData.maxcrm;
              if(this.netIRRValue!=null && minNetIrr!=null && maxNetIrr!=null && ((parseFloat(this.netIRRValue) < parseFloat(minNetIrr)) || (parseFloat(this.netIRRValue) > parseFloat(maxNetIrr)))){//Start INDI-4682 // CISP-2702
                  const event = new ShowToastEvent({
                      title: 'Error',
                      message: 'Net IRR is not as per norms Min ' + minNetIrr + 'and Max '+ maxNetIrr + ' . Please make the relevant changes by editing other loan terms.',
                      variant: 'Error',
                        });
                        this.dispatchEvent(event);
                        return;        
              }else{
                this.handleSubSubmit();
              }
            })
            .catch(error => {
              console.error('Error:', error);
          });
        }else if ((this.productType.toLowerCase() === 'Two Wheeler'.toLowerCase()) && this.leadSource != 'D2C') {//CISP-16686 start
            if ((Number(this.tenure) > 36 || Number(this.tenure) < 6) && parseFloat(this.loanAmount) < 90000) {//CISP-20773 
                console.log('here', this.productType.toLowerCase());
                this.tenure = '';
                const event = new ShowToastEvent({
                    title: 'Warning',
                    message: 'Loan amount is lessthan INR 90,000 hence please enter tenure between 6 to 36 only', 
                    variant: 'Warning',
                });
                this.dispatchEvent(event);
                return;
            }else if((Number(this.tenure) > 48 || Number(this.tenure) < 6) && parseFloat(this.loanAmount) > 90000){
                this.tenure = '';
                const event = new ShowToastEvent({
                    title: 'Warning',
                    message: 'Tenure Value is out of bounds.Please enter value between 6 and 48',
                    variant: 'Warning',
                });
                this.dispatchEvent(event);
                return;
            }
            if(this.productSegment!=null && this.productSegment!='' && this.productSegment === 'ESCOOTER'){
               if (parseFloat(this.loanAmount) > 150000 || parseFloat(this.loanAmount) < 25000) {
                   const event = new ShowToastEvent({
                       title: 'Warning',
                       message: 'Loan amount is out of bounds. Please enter value between 25k to 1.6fL',
                       variant: 'Warning',
                   });
                   this.dispatchEvent(event);
                   return;
               }
               this.handleSubSubmit();
            }else{
               if (parseFloat(this.loanAmount) > 160000 || parseFloat(this.loanAmount) < 20000) {
                   const event = new ShowToastEvent({
                       title: 'Warning',
                       message: 'Loan amount is out of bounds. Please enter value between 20k to 1.6L',
                       variant: 'Warning',
                   });
                   this.dispatchEvent(event);
                   return;
               }
               this.handleSubSubmit();
            }
            this.handleSubSubmit();//CISP-16686 end
   } else {
            /* if (this.minLoanAmount == null || this.loanSliderDisabled) {
                const opportunityFields = {};
                opportunityFields[opportunityId.fieldApiName] = this.recordid;
                opportunityFields[Journey_Status.fieldApiName] = 'Non STP';
                this.updateRecordDetails(opportunityFields);
            } */

            this.handleSubSubmit();
        }
    }
    }
    async handleSubSubmit()
    {
        let isvalidForSubmit = await this.getDocumentsToCheckPanValid();
        if(isvalidForSubmit){
            if(this.productType.toLowerCase() === 'Passenger Vehicles'.toLowerCase() && (this.flagApiFail || this.isOfferengineApiFail)){
                let isLoanAmountUpdated= false;
                if (this.vehicleType.toLowerCase() === 'New'.toLowerCase() && this.oppRecord.Funding_on_Ex_Showroom__c && this.oppRecord.Ex_showroom_price__c && ((parseFloat(this.loanAmount) + parseFloat(this.totalFundedPremium)) > parseFloat(this.oppRecord.Ex_showroom_price__c))) {
                    isLoanAmountUpdated = true;
                    this.loanAmount = this.oppRecord.Ex_showroom_price__c;
                }else if (this.vehicleType.toLowerCase() === 'New'.toLowerCase() && this.oppRecord.Funding_on_ORP__c && this.orp && ((parseFloat(this.loanAmount) + parseFloat(this.totalFundedPremium)) > parseFloat(this.orp))) {
                    isLoanAmountUpdated = true;
                    this.loanAmount = this.orp;
                }else if ((this.vehicleType.toLowerCase() === 'Refinance'.toLowerCase() || this.vehicleType.toLowerCase() === 'Used'.toLowerCase()) && this.vehRecord.Base_Prices__c && ((parseFloat(this.loanAmount) + parseFloat(this.totalFundedPremium)) > parseFloat(this.vehRecord.Base_Prices__c))) {
                    isLoanAmountUpdated = true;
                    this.loanAmount = this.vehRecord.Base_Prices__c;
                }
                // if (isLoanAmountUpdated){
                //     const event = new ShowToastEvent({
                //         title: 'Warning',
                //         message: 'Loan amount is changed to '+ this.loanAmount +'. Please continue and change the loan amount in Income screen if required',
                //         variant: 'warning',
                //     });
                //     this.dispatchEvent(event);
                //  }
            }
        this.flagLoanAmountChange = false;
        this.flagTenureChange = false;
        this.flagRequiredCrrIrrChange = false;
        this.flagAdvanceEmiChange = false;
        this.flagMonitoriumDays = false;

        const evt = new ShowToastEvent({
            title: 'success',
            message: "Details Saved",
            variant: 'Success',
        });
        this.dispatchEvent(evt);
        let nextStage = 'Customer Code Addition';
        const FinalTermFields = {};
        FinalTermFields[final_ID_FIELD.fieldApiName] = this.isRecordId;
        FinalTermFields[EMI_Amount.fieldApiName] = this.emi;
        FinalTermFields[Tenure.fieldApiName] = this.tenure.toString();
        FinalTermFields[Loan_Amount.fieldApiName] = this.loanAmount.toString();
        FinalTermFields[CRM_IRR.fieldApiName] = this.requiredCRMIRR;
        FinalTermFields[Required_CRM_IRR.fieldApiName] = this.requiredCRMIRR.toString();
        FinalTermFields[OfferengineMaxTenure.fieldApiName] =  this.maxTenure;
        FinalTermFields[OfferengineMinTenure.fieldApiName] = this.minTenure;
        FinalTermFields[OfferengineMinLoanAmount.fieldApiName] = this.minLoanAmount;
        FinalTermFields[OfferengineMaxLoanAmount.fieldApiName] = this.maxLoanAmount;
        FinalTermFields[Advance_EMI.fieldApiName] = this.advanceEMi;
        if (this.monitoriumDaysValue != null && this.monitoriumDaysValue != undefined) {
            FinalTermFields[Holiday_period.fieldApiName] = this.monitoriumDaysValue.toString();
        }
        else { FinalTermFields[Holiday_period.fieldApiName] = '0'; }
        //CISP-124
        if(this.provisionAmount && this.leadSource!='OLA'){//OLA-21
           FinalTermFields[Provisional_Channel_Cost.fieldApiName] = this.provisionAmount.toString();
        }
        //CISP-124
        this.updateRecordDetails(FinalTermFields);
        const oppFields = {};
        oppFields[OPP_ID_FIELD.fieldApiName] = this.recordid;
        oppFields[STAGENAME.fieldApiName] = nextStage;
        oppFields[LASTSTAGENAME.fieldApiName]=nextStage;
        this.updateRecordDetails(oppFields);
        console.log('before navigation ');
        this.dispatchEvent(new CustomEvent('submitnavigation', { detail: 'Customer Code Addition', bubbles: true, composed: true }));

        //Yugandhar - Initiate FI - Start
        }
    }
    handlechangePay() {
        if (this.flagApiFail) {
            const event = new ShowToastEvent({
                title: 'Warning',
                message: clickSubmitButton,
                variant: 'Warning'
            });
            this.dispatchEvent(event);
         }else if (this.productType.toLowerCase() === 'Two Wheeler'.toLowerCase() && ((Number(this.tenure) %6 != 0) || (this.tenure === 0 || this.tenure === '0' || this.tenure === '' || this.tenure === null || this.tenure === undefined))) {
            this.toastMsg('Tenure is required. Please enter value multiple of 6');
        }
        else if (!this.advanceEMi && (this.monitoriumDaysValue == '0' || this.monitoriumDaysValue == ' ' ||this.monitoriumDaysValue == null ) ) {
            let elem = this.template.querySelector('lightning-input[data-id=advanceEMIid]');
            elem.setCustomValidity("");
            elem.setCustomValidity('Enter advance EMI Value');
            elem.reportValidity();
            const event = new ShowToastEvent({
                title: 'Warning',
                message: enterEMIDays,
                variant: 'Warning'
            });
            this.dispatchEvent(event);
        }
        else  if (this.flagLoanAmountChange && parseInt(this.loanAmount,10) < this.minLoanAmount || parseInt(this.loanAmount,10) > this.maxLoanAmount) {
            const sub = new ShowToastEvent({
                title: 'ERROR',
                message: submitWarning,
                variant: 'Error',
            });
            this.dispatchEvent(sub);
        }
        else if (!this.flagLoanAmountChange) {
            console.log('this.flagLoanAmountChange 1 ',this.flagLoanAmountChange);
            const tenure = new ShowToastEvent({
                title: 'Warning',
                message: loanNotChanged,
                variant: 'Warning'
            });
            this.dispatchEvent(tenure);
        }
        else if (this.flagTenureChange && !this.flagLoanAmountChange) {
            console.log('this.flagLoanAmountChange ',this.flagLoanAmountChange);
            const tenure = new ShowToastEvent({
                title: 'ERROR',
                message: changeTenure,
                variant: 'Error',
            });
            this.dispatchEvent(tenure);

        }
        else if (this.flagAdvanceEmiChange && !this.flagLoanAmountChange) {
            const emi = new ShowToastEvent({
                title: 'ERROR',
                message: changeCheckEligibility,
                variant: 'Error',
            });
            this.dispatchEvent(emi);
        }
        else if (this.flagMonitoriumDays && !this.flagLoanAmountChange) {
            const monitorium = new ShowToastEvent({
                title: 'ERROR',
                message: changeMoratoriumDay,
                variant: 'Error',
            });
            this.dispatchEvent(monitorium);
        }else if(this.loanAmount==null || this.loanAmount.toString()==''){
            const missingloan = new ShowToastEvent({
                title: 'ERROR',
                message: loanamtmissing,
                variant: 'Error',
            });
            this.dispatchEvent(missingloan);
           
        }
        
        else if (this.flagLoanAmountChange) {
            const FinalTermFields = {};
            //saving all the change fields.
            FinalTermFields[final_ID_FIELD.fieldApiName] = this.isRecordId;
            FinalTermFields[Loan_Amount.fieldApiName] = this.loanAmount.toString();
            FinalTermFields[Tenure.fieldApiName] = this.tenure.toString();
            FinalTermFields[Required_CRM_IRR.fieldApiName] = this.requiredCRMIRR.toString();
            FinalTermFields[isNavigate.fieldApiName] = true;
            FinalTermFields[Advance_EMI.fieldApiName] = this.advanceEMi;
            FinalTermFields[EMI_Amount.fieldApiName] = this.emi;//CISP-2881
            if (this.monitoriumDaysValue != null) {
            FinalTermFields[Holiday_period.fieldApiName] = this.monitoriumDaysValue.toString();
            }
            else { FinalTermFields[Holiday_period.fieldApiName] = '0'; }//CISP-2905
            //CISP-124
            if(this.provisionAmount){
               FinalTermFields[Provisional_Channel_Cost.fieldApiName] = this.provisionAmount.toString();
            }
            //CISP-124
            this.updateRecordDetails(FinalTermFields)
                .then(result => {
                    console.log('Inside update record 398');
                    const oppFields = {};
                    let nextStage = 'Final Terms';
                    oppFields[OPP_ID_FIELD.fieldApiName] = this.recordid;
                    oppFields[STAGENAME.fieldApiName] = nextStage;
                    oppFields[LASTSTAGENAME.fieldApiName]=nextStage;
                    this.updateRecordDetails(oppFields)
                        .then(result => {
                            const evt = new ShowToastEvent({
                                title: 'success',
                                message: "Details Saved",
                                variant: 'Success',
                            });
                            this.dispatchEvent(evt);
                            this.dispatchEvent(new CustomEvent('submitnavigation', { detail: 'Final Terms' }));
                        }).catch(error => { })
                }).catch(error => { })
            updateRetryCount({ loanApplicationId: this.recordid })
                .then(result => { }).catch(error => {console.log('error in updateretry ',error) })

        }
    }

    handleTenureChangeValidation(event)
    {
        this.tenure = event.target.value;
        this.calculateNumberOfInstallments(this.monitoriumDaysValue, this.tenure);
        //CISP-124
        this.calculateProvisionAmt(this.loanAmount, this.tenure);
    }
    handleSDTenureChange(event){
        this.tenure = event.target.value;
        this.calculateNumberOfInstallments(this.monitoriumDaysValue, this.tenure);
        this.calculateProvisionAmt(this.loanAmount, this.tenure);
        this.handleTenureChange(event);
    }
    handleTenureChange(event) {
        if (this.tenureFinal !== event.target.value) {
            this.flagTenureChange = true;
            this.flagRequiredCrrIrrOnlyChanged = false;
        }
        else {
            this.flagTenureChange = false;
        }
        this.tenure = event.target.value;
        let elem = this.template.querySelector('lightning-input[data-id=tenure]');
        elem.setCustomValidity("");
        if(this.leadSource =='Hero' && ((this.tenure <  this.minTenure) || (this.tenure > this.maxTenure))) {//CISH-52 start 
            const event = new ShowToastEvent({
            title: 'Warning',
            message: 'Tenure Value is out of bounds. Please enter valid value',
            variant: 'Warning',
         });
         this.dispatchEvent(event);
         this.tenure = '';
         if(elem){
            elem.value = this.tenure;
         }
     }//CISH-52 end
        if(this.productType.toLowerCase() === 'Two Wheeler'.toLowerCase() && Number(this.tenure)%6 != 0){
           this.tenure = '';
           const event = new ShowToastEvent({
               title: 'Warning',
               message: 'You have entered an incorrect value. Please enter value multiple of 6',
               variant: 'Warning',
           });
           this.dispatchEvent(event);
        }
        else if (this.vechSubCategory.toLowerCase() !== 'UIM'.toLowerCase() && (this.vehicleType.toLowerCase() === 'Used'.toLowerCase() || this.vehicleType.toLowerCase() ===Refinance.toLowerCase())) {
            if (this.productType.toLowerCase() === 'Passenger Vehicles'.toLowerCase()) {
                let tenureval=this.tenure;
                console.log('this.vehicleAge ',this.vehicleAge);
                let totalValue = parseInt(tenureval, 10) + parseInt(this.vehicleAge, 10);
                 if (totalValue > 180) // total value is converted into years // CISP-4102 Previous value -> 144, new value -> 180
                {
                    elem.setCustomValidity('Tenure Value + Age of Vehicle should be less than 15 years'); // CISP-4102 changed 12 years to 15 years
                }

                if ((this.vehicleType.toLowerCase() === 'Used'.toLowerCase() || this.vehicleType.toLowerCase() === 'Refinance'.toLowerCase()) && (Number(this.tenure) > 60 || Number(this.tenure) < 12)) {
                    this.tenure = '';
                    const event = new ShowToastEvent({
                        title: 'Warning',
                        message: 'Tenure Value is out of bounds.Please enter value between 12 and 60',
                        variant: 'Warning',
                    });
                    this.dispatchEvent(event);
                } 
                // if (this.vehicleType.toLowerCase() === 'Refinance'.toLowerCase() && (Number(this.tenure) > 36 || Number(this.tenure) < 12)) {
                //     this.tenure = '';
                //     const event = new ShowToastEvent({
                //         title: 'Warning',
                //         message: 'Tenure Value is out of bounds.Please enter value between 12 and 36',
                //         variant: 'Warning',
                //     });
                //     this.dispatchEvent(event);
                // } 
                elem.reportValidity();
                 if (this.flagLoanAmountChange == true && this.flagTenureChange == true && this.leadSource !='Hero') {
                    if(parseInt(this.loanAmount,10) > this.minLoanAmount && parseInt(this.loanAmount,10) < this.maxLoanAmount){  
                    const event = new ShowToastEvent({
                        title: 'Warning',
                        message: loanTenureChange,
                        variant: 'warning',
                    });
                    this.dispatchEvent(event);
                }
                else{  const eve = new ShowToastEvent({
                    title: 'ERROR',
                    message: submitWarning,
                    variant: 'Error',
                });
                this.dispatchEvent(eve);
                }
                } 
                 else if (this.flagTenureChange == true) {
                    const eve = new ShowToastEvent({
                        title: 'Warning',
                        message: changeTenure,
                        variant: 'Warning',
                    });
                    this.dispatchEvent(eve);
                    this.eligiblityButtonClicked = false;
                } 
            }
            if (this.productType.toLowerCase() === 'Two Wheeler'.toLowerCase()) {
                let tenureval=this.tenure;
                let totalValue = parseInt(tenureval, 10) + this.vehicleAge;
                if (totalValue > 60) //total value is converted into years 
                {
                    elem.setCustomValidity('Tenure Value + Age of Vehicle should be less than 5 years ');
                }
                if (this.vehicleType.toLowerCase() === Refinance.toLowerCase() && (Number(this.tenure) > 48 || Number(this.tenure) < 12)) {
                    this.tenure = '';
                    const event = new ShowToastEvent({
                        title: 'Warning',
                        message: 'Tenure Value is out of bounds.Please enter value between 12 and 48',
                        variant: 'Warning',
                    });
                    this.dispatchEvent(event);
                } 
                if (this.vehicleType.toLowerCase() === 'Used'.toLowerCase() && (Number(this.tenure) > 36 || Number(this.tenure) < 6)) {
                    this.tenure = '';
                    const event = new ShowToastEvent({
                        title: 'Warning',
                        message: 'Tenure Value is out of bounds.Please enter value between 6 and 36',
                        variant: 'Warning',
                    });
                    this.dispatchEvent(event);
                } 
                elem.reportValidity();
               if (this.flagLoanAmountChange == true && this.flagTenureChange == true && this.leadSource !='Hero') {
                if(parseInt(this.loanAmount,10) > this.minLoanAmount && parseInt(this.loanAmount,10) < this.maxLoanAmount){  
                    const event = new ShowToastEvent({
                        title: 'Warning',
                        message: loanTenureChange,
                        variant: 'warning',
                    });
                    this.dispatchEvent(event);
                }
                else{  const eve = new ShowToastEvent({
                    title: 'ERROR',
                    message: submitWarning,
                    variant: 'Error',
                });
                this.dispatchEvent(eve);
                }
                }
                 else if (this.flagTenureChange == true) {
                    const eve = new ShowToastEvent({
                        title: 'Warning',
                        message: changeTenure,
                        variant: 'Warning',
                    });
                    this.dispatchEvent(eve);
                    this.eligiblityButtonClicked = false;
                }
            }

        }
        else if (this.vechSubCategory.toLowerCase() === 'UIM'.toLowerCase() && (this.vehicleType.toLowerCase() === 'Used'.toLowerCase() || this.vehicleType.toLowerCase() === Refinance.toLowerCase())) {
            if (this.productType.toLowerCase() === 'Two Wheeler'.toLowerCase() || this.productType.toLowerCase() === 'Passenger Vehicles'.toLowerCase()) {
                if (event.target.value > this.EligibleTenure) {

                    elem.setCustomValidity('Tenure Value should be less than eligible tenure');
                }
                elem.reportValidity();
            }
             if (this.productType.toLowerCase() === 'Passenger Vehicles'.toLowerCase()) {
                if ((Number(this.tenure) > 60 || Number(this.tenure) < 12)) {
                    this.tenure = '';
                    const event = new ShowToastEvent({
                        title: 'Warning',
                        message: 'Tenure Value is out of bounds.Please enter value between 12 and 60',
                        variant: 'Warning',
                    });
                    this.dispatchEvent(event);
                }
                elem.reportValidity();
            }
            if (this.productType.toLowerCase() === 'Two Wheeler'.toLowerCase()) {
                if (this.vehicleType.toLowerCase() === 'Used'.toLowerCase() && (Number(this.tenure) > 36 || Number(this.tenure) < 6)) {
                    this.tenure = '';
                    const event = new ShowToastEvent({
                        title: 'Warning',
                        message: 'Tenure Value is out of bounds.Please enter value between 6 and 36',
                        variant: 'Warning',
                    });
                    this.dispatchEvent(event);
                }
                elem.reportValidity();

            } 
           if (this.flagLoanAmountChange == true && this.flagTenureChange == true && this.leadSource !='Hero') {
            if(parseInt(this.loanAmount,10) > this.minLoanAmount && parseInt(this.loanAmount,10) < this.maxLoanAmount){  
                const event = new ShowToastEvent({
                    title: 'Warning',
                    message: loanTenureChange,
                    variant: 'warning',
                });
                this.dispatchEvent(event);
            }
            else{  const eve = new ShowToastEvent({
                title: 'ERROR',
                message: submitWarning,
                variant: 'Error',
            });
            this.dispatchEvent(eve);
            }
            }
             else if (this.flagTenureChange == true) {
                const eve = new ShowToastEvent({
                    title: 'Warning',
                    message: changeTenure,
                    variant: 'Warning',
                });
                this.dispatchEvent(eve);
                this.eligiblityButtonClicked = false;
            }
        }
        else if (this.vechSubCategory.toLowerCase() !== 'UIM'.toLowerCase() && (this.vehicleType.toLowerCase() === 'New'.toLowerCase())) {
             if (this.productType.toLowerCase() === 'Passenger Vehicles'.toLowerCase()) {
                if (Number(this.tenure) > 96 || Number(this.tenure) < 12) {
                    this.tenure = '';
                    const event = new ShowToastEvent({
                        title: 'Warning',
                        message: 'Tenure Value is out of bounds.Please enter value between 12 and 96',
                        variant: 'Warning',
                    });
                    this.dispatchEvent(event);
                }
                elem.reportValidity();
            }

            if (this.productType.toLowerCase() === 'Two Wheeler'.toLowerCase()) {

                if ((Number(this.tenure) > 36 || Number(this.tenure) < 6) && parseInt(this.loanAmount,10) < 90000) {//CISP-20773
                    console.log('here', this.productType.toLowerCase());
                    this.tenure = '';
                    const event = new ShowToastEvent({
                        title: 'Warning',
                        message: 'Loan amount is lessthan INR 90,000 hence please enter tenure between 6 to 36 only',
                        variant: 'Warning',
                    });
                    this.dispatchEvent(event);
                }
                elem.reportValidity();

            }

            if (this.flagLoanAmountChange == true && this.flagTenureChange == true && this.leadSource !='Hero') {
                if(parseInt(this.loanAmount,10) > this.minLoanAmount && parseInt(this.loanAmount,10) < this.maxLoanAmount){  
                    const event = new ShowToastEvent({
                        title: 'Warning',
                        message: loanTenureChange,
                        variant: 'warning',
                    });
                    this.dispatchEvent(event);
                }
                else{  const eve = new ShowToastEvent({
                    title: 'ERROR',
                    message: submitWarning,
                    variant: 'Error',
                });
                this.dispatchEvent(eve);
                }
            }
            else if (this.flagTenureChange == true ) {
                const eve = new ShowToastEvent({
                    title: 'Warning',
                    message: changeTenure,
                    variant: 'Warning',
                });
                this.dispatchEvent(eve);
                this.eligiblityButtonClicked = false;
            }
        }
        else if (this.vechSubCategory.toLowerCase() === 'UIM'.toLowerCase() && (this.vehicleType.toLowerCase() === 'NEW'.toLowerCase())) {
            if (this.productType.toLowerCase() === 'Two Wheeler'.toLowerCase() || this.productType.toLowerCase() === 'Passenger Vehicles'.toLowerCase()) {
                 if (this.productType.toLowerCase() === 'Passenger Vehicles'.toLowerCase()) {
                    if (Number(this.tenure) > 96 || Number(this.tenure) < 12) {
                        this.tenure = '';
                        const event = new ShowToastEvent({
                            title: 'Warning',
                            message: 'Tenure Value is out of bounds.Please enter value between 12 and 96',
                            variant: 'Warning',
                        });
                        this.dispatchEvent(event);
                    }
                    elem.reportValidity();
                }
                if (this.productType.toLowerCase() === 'Two Wheeler'.toLowerCase()) {
                    if ((Number(this.tenure) > 48 || Number(this.tenure) < 6) && parseInt(this.loanAmount,10) > 90000) {//CISP-20773
                        this.tenure = '';
                        const event = new ShowToastEvent({
                            title: 'Warning',
                            message: 'Tenure Value is out of bounds.Please enter value between 6 and 48',
                            variant: 'Warning',
                        });
                        this.dispatchEvent(event);
                    }
                    elem.reportValidity();

                } 
            }
            if (this.flagLoanAmountChange == true && this.flagTenureChange == true && this.leadSource !='Hero') {
                if(parseInt(this.loanAmount,10) > this.minLoanAmount && parseInt(this.loanAmount,10) < this.maxLoanAmount){  
                    const event = new ShowToastEvent({
                        title: 'Warning',
                        message: loanTenureChange,
                        variant: 'warning',
                    });
                    this.dispatchEvent(event);
                }
                else{  const eve = new ShowToastEvent({
                    title: 'ERROR',
                    message: submitWarning,
                    variant: 'Error',
                });
                this.dispatchEvent(eve);
                }
            }
            else if (this.flagTenureChange == true) {
                const eve = new ShowToastEvent({
                    title: 'Warning',
                    message: changeTenure,
                    variant: 'Warning',
                });
                this.dispatchEvent(eve);
                this.eligiblityButtonClicked = false;
            }
        }
        else if (this.productType.toLowerCase() === 'Two Wheeler'.toLowerCase() && this.vehicleType.toLowerCase() === 'New'.toLowerCase() && (Number(this.tenure) > 36 || Number(this.tenure) < 6) && this.leadSource !='Hero'  && parseInt(this.loanAmount,10) < 90000) { 
               this.tenure = '';
               const event = new ShowToastEvent({
                   title: 'Warning',
                   message: 'Loan amount is lessthan INR 90,000 hence please enter tenure between 6 to 36 only',
                   variant: 'Warning',
               });
               this.dispatchEvent(event);
           }
        else {
           if (this.flagLoanAmountChange == true && this.flagTenureChange == true && this.leadSource !='Hero') {
            if(parseInt(this.loanAmount,10) > this.minLoanAmount && parseInt(this.loanAmount,10) < this.maxLoanAmount){  
                const event = new ShowToastEvent({
                    title: 'Warning',
                    message: loanTenureChange,
                    variant: 'warning',
                });
                this.dispatchEvent(event);
            }
            else{  const eve = new ShowToastEvent({
                title: 'ERROR',
                message: submitWarning,
                variant: 'Error',
            });
            this.dispatchEvent(eve);
            }
            }
             else if (this.flagTenureChange == true) {
                const eve = new ShowToastEvent({
                    title: 'Warning',
                    message: changeTenure,
                    variant: 'Warning',
                });
                this.dispatchEvent(eve);
                this.eligiblityButtonClicked = false;
            }
        }

        if (event.target.value < this.minTenure || event.target.value > this.maxTenure) {
            this.tenureSliderDisabled = true;
        }
        else {
            this.tenureSliderDisabled = false;
        }
    }

   handleEmiChange(event){//Start CISP-2361
       try {
           if (parseFloat(this.emiFinal) !== parseFloat(event.target.value)) {
               this.flagEmiChange = true;
               this.handleEmiFlagChange = true;//CISP-2643
               this.eligiblityButtonClicked = false;//CISP-2643
               
           }
           else {
               this.flagEmiChange = false;
               this.handleEmiFlagChange = false;//CISP-2643
           }
           this.emi = event.target.value;
           let elem = this.template.querySelector('lightning-input[data-id=emi]');
           if(this.flagEmiChange){
               const event = new ShowToastEvent({
                   title: 'Warning',
                   message: 'EMI Amount is changed kindly click on Check Eligibility Button',
                   variant: 'Warning',
               });
               this.dispatchEvent(event);
           }            
       } catch (error) {
           console.error(error);
       }
   }//End CISP-2361

   async handleLoanSliderAmount(event)
    {
        let elem = this.template.querySelector('lightning-input[data-id=LoanAmt]');
        elem.setCustomValidity("");
      
        this.loanAmount = event.target.value;
        let isvalidForSubmit = await this.getDocumentsToCheckPanValid();
         if(!isvalidForSubmit){
            return null;
         }
        if(this.leadSource =='Hero' && ((this.loanAmount < this.minLoanAmount) || (this.loanAmount > this.maxLoanAmount))) {//CISH-52 start 
            const event = new ShowToastEvent({
            title: 'Warning',
            message: 'Please Enter Loan valid Loan Amount',
            variant: 'Warning',
         });
         this.dispatchEvent(event);
         this.loanAmount = '';
         if(elem){
            elem.value = this.loanAmount;
         }
     }//CISH-52 end
     if(this.leadSource =='Hero' && parseFloat(this.loanAmountFinal) !== parseFloat(this.loanAmount)) {//CISH-52 start
        const event = new ShowToastEvent({
        title: 'Warning',
        message: 'Loan amount is changed kindly click on Check Eligibility Button',
        variant: 'Warning',
     });
     this.dispatchEvent(event);
 }//CISH-52 end
        if (this.vechSubCategory.toLowerCase() === 'UIM'.toLowerCase() && (this.productType.toLowerCase() === 'Passenger Vehicles'.toLowerCase() || this.productType.toLowerCase() === 'Two Wheeler'.toLowerCase())) {
            if (this.loanAmount > this.EligibleLoanAmt) {
                elem.setCustomValidity('Loan Amount value should be less than or equal to Eligibility Amount');
            }
            elem.reportValidity();
        }
        if (this.productType.toLowerCase() === 'Passenger Vehicles'.toLowerCase()) { 
            if (this.loanAmount > 200000000 || this.loanAmount < 50000) {
                const event = new ShowToastEvent({
                    title: 'Warning',
                    message: 'Loan amount is out of bounds. Please enter value between 50k to 20cr',
                    variant: 'Warning',
                });
                this.dispatchEvent(event);
                this.loanAmount = '';
                //CISP-2775
                if(elem){
                   elem.value = this.loanAmount;
                }
                //CISP-2775
            }// Start CISP-2522
            if (this.vehicleType.toLowerCase() === 'New'.toLowerCase() && this.oppRecord.Funding_on_Ex_Showroom__c == true && this.oppRecord.Ex_showroom_price__c!=null && ((parseFloat(this.loanAmount)) > parseFloat(this.oppRecord.Ex_showroom_price__c))) {//CISP-2804 change check !=null //CISP-2347  
               const event = new ShowToastEvent({
                   title: 'Warning',
                   message: 'Loan amount is out of bounds. Please enter value less than Ex Showroom Price '+this.oppRecord.Ex_showroom_price__c,
                   variant: 'Warning',
                });
                this.dispatchEvent(event);
                this.loanAmount = '';
                //CISP-2775
                if(elem){
                   elem.value = this.loanAmount;
                }
                //CISP-2775
           }else if (this.vehicleType.toLowerCase() === 'New'.toLowerCase() && this.oppRecord.Funding_on_ORP__c == true && this.orp!=null && ((parseFloat(this.loanAmount)) > parseFloat(this.orp))) {//CISP-2804 change check !=null //CISP-2347 
               const event = new ShowToastEvent({
                   title: 'Warning',
                   message: 'Loan amount is out of bounds. Please enter value less than On Road Price '+this.orp,
                   variant: 'Warning',
                });
                this.dispatchEvent(event);
                this.loanAmount = '';
                //CISP-2775
                if(elem){
                   elem.value = this.loanAmount;
                }
                //CISP-2775
           }else if ((this.vehicleType.toLowerCase() === 'Refinance'.toLowerCase() || this.vehicleType.toLowerCase() === 'Used'.toLowerCase()) && this.vehRecord.Base_Prices__c!=null && (parseFloat(this.loanAmount)) > parseFloat(this.vehRecord.Base_Prices__c)) {//CISP-2804 change check !=null //CISP-2347
            const event = new ShowToastEvent({
                title: 'Warning',
                message: 'Loan amount is out of bounds. Please enter value less than Base Price '+ this.vehRecord.Base_Prices__c,
                variant: 'Warning',
             });
             this.dispatchEvent(event);
             this.loanAmount = '';
             //CISP-2775
             if(elem){
                elem.value = this.loanAmount;
                }
                //CISP-2775
           }//End CISP-2522
           if (parseFloat(this.loanAmountFinal) !== parseFloat(this.loanAmount) && (parseFloat(this.loanAmount) < parseFloat(this.minLoanAmount) || parseFloat(this.loanAmount) > parseFloat(this.maxLoanAmount))){//Start CISP-2881  
               this.flagRequiredCrrIrrOnlyChanged = false;
               const event = new ShowToastEvent({
                   title: 'Warning',
                   message: clickSubmitButton,
                   variant: 'warning',
               });
               this.dispatchEvent(event);
           }//End CISP-2881
        }

        if (this.productType.toLowerCase() === 'Two Wheeler'.toLowerCase()) {
            if(this.productSegment!=null && this.productSegment!='' && this.productSegment === 'ESCOOTER'){
                if (parseFloat(this.loanAmount) > 150000 || parseFloat(this.loanAmount) < 25000) {//CISP-13665
                    const event = new ShowToastEvent({
                        title: 'Warning',
                        message: 'Loan amount is out of bounds. Please enter value between 25k to 1.5L',
                        variant: 'Warning',
                    });
                    this.dispatchEvent(event);
                    this.loanAmount = '';
                    
                    if(elem){
                       elem.value = this.loanAmount;
                    } 
                }
             }else{
                if (parseFloat(this.loanAmount) > 160000 || parseFloat(this.loanAmount) < 20000) {//CISP-4023
                const event = new ShowToastEvent({
                    title: 'Warning',
                    message: 'Loan amount is out of bounds. Please enter value between 20k to 1.6L',
                    variant: 'Warning',
                });
                this.dispatchEvent(event);
                this.loanAmount = '';
                //CISP-2775
                if(elem){
                   elem.value = this.loanAmount;
                }
                //CISP-2775
            }
            }
            
             if(this.orp!=null && ((parseFloat(this.loanAmount) + parseFloat(this.totalFundedPremium)) > this.orp)) {//Start CISP-2459
                const event = new ShowToastEvent({//CISP-2804 change check !=null
               title: 'Warning',
               message: 'Loan amount is out of bounds. Please enter value less than On Road Price '+this.orp,
               variant: 'Warning',
            });
            this.dispatchEvent(event);
            this.loanAmount = '';
            //CISP-2775
            if(elem){
               elem.value = this.loanAmount;
            }
            //CISP-2775
        }
        if (parseFloat(this.loanAmountFinal) !== parseFloat(this.loanAmount) && (parseFloat(this.loanAmount) < parseFloat(this.minLoanAmount) || parseFloat(this.loanAmount) > parseFloat(this.maxLoanAmount)) && (!this.flagTenureChange && !this.flagAdvanceEmiChange || !this.flagRequiredCrrIrrChange && !this.flagMonitoriumDays && !this.flagEmiChange)){//Startr CISP-2881 
           const event = new ShowToastEvent({
               title: 'Warning',
               message: clickSubmitButton,
               variant: 'warning',
           });
           this.dispatchEvent(event);
        }
        else if (parseFloat(this.loanAmountFinal) !== parseFloat(this.loanAmount) && (parseFloat(this.loanAmount) < parseFloat(this.minLoanAmount) || parseFloat(this.loanAmount) > parseFloat(this.maxLoanAmount)) && (!this.flagTenureChange && !this.flagAdvanceEmiChange && !this.flagRequiredCrrIrrChange && !this.flagMonitoriumDays && !this.flagEmiChange)){
           const event = new ShowToastEvent({
               title: 'Warning',
               message: 'Loan amount is changed kindly click on Check Eligibility Button',
               variant: 'warning',
           });
           this.dispatchEvent(event);
        }//End CISP-2881
        } 
        /*
        if(this.vehicleType.toLowerCase() === 'New'.toLowerCase() && event.target.value > this.orp) 
        {
            const event = new ShowToastEvent({
                title: 'Warning',
                message: 'Loan amount is out of bounds. Please enter value less than On Road Price '+this.orp, 
                variant: 'Warning',
            });
            this.dispatchEvent(event);
            this.loanAmount = '';
        }*/
        //End CISP-2459
        if (parseInt(this.loanAmountFinal,10) !== this.loanAmount ) {
            this.flagLoanAmountChange = true;
        }//CISP-2775
        else {
            this.flagLoanAmountChange = false;
        }
         if (this.loanAmountFinal !== this.loanAmount && this.loanAmount >= this.minLoanAmount && this.loanAmount <= this.maxLoanAmount && this.leadSource !='Hero') {//CISP-2804 change check to include min and max value (=)
            this.flagRequiredCrrIrrOnlyChanged = false;
            const event = new ShowToastEvent({
                title: 'Warning',
                message: changePayinAndPayout,
                variant: 'warning',
            });
            this.dispatchEvent(event);
            //this.isChangePayInOutButtonDisable = true;
        }
        
        if (parseInt(this.loanAmount,10) < this.minLoanAmount || parseInt(this.loanAmount,10) > this.maxLoanAmount) {
            this.loanSliderDisabled = true;
        }
        else {
            this.loanSliderDisabled = false;
        }
        
    }

    handleLoanSliderAmountChange(event) {
        this.loanAmount = event.target.value;
        console.log('Event-->' + event.target.value);
        console.log('Amount in Event-->' + this.loanAmount);
        //CISP-124
        this.calculateProvisionAmt(this.loanAmount, this.tenure);
    }
    handleSDLoanSliderAmountChange(event) {
        this.loanAmount = event.target.value;
        console.log('Event-->' + event.target.value);
        console.log('Amount in Event-->' + this.loanAmount);
        this.calculateProvisionAmt(this.loanAmount, this.tenure);
        this.handleLoanSliderAmount(event);
     }
    handleAdvanceEmi() {
        let advanceEMiInput = this.template.querySelector('lightning-input[data-id=advanceEMIid]');
        advanceEMiInput.setCustomValidity("");
        advanceEMiInput.reportValidity();   
        this.advanceEMi = advanceEMiInput.checked;
        if (this.advanceEmis != this.advanceEMi) {
            this.flagAdvanceEmiChange = true;
            this.flagRequiredCrrIrrOnlyChanged = false;
        }
        if (this.flagLoanAmountChange == true && this.flagAdvanceEmiChange == true) {
            if(parseInt(this.loanAmount,10) > this.minLoanAmount && parseInt(this.loanAmount,10) < this.maxLoanAmount){    
            const event = new ShowToastEvent({
                title: 'Warning',
                message: loanAdvanceChanged,
                variant: 'warning',
            });
            this.dispatchEvent(event);
        }
        else{  const eve = new ShowToastEvent({
            title: 'ERROR',
            message: submitWarning,
            variant: 'Error',
        });
        this.dispatchEvent(eve);
        }
        }
        else if(this.flagAdvanceEmiChange){
            const event = new ShowToastEvent({
                title: 'Error',
                message: changeCheckEligibility,
                variant: 'Error',
            });
            this.dispatchEvent(event);
            this.eligiblityButtonClicked = false;
        }
        if (this.advanceEMi == true) {
            let elem = this.template.querySelector('.monDay');
            elem.setCustomValidity("");
            elem.reportValidity();
            this.monitoriumDaysDisabled = true;
            this.monitoriumDaysValue = 0;
        }
        else {
            let elem = this.template.querySelector('.monDay');
            elem.setCustomValidity("");
            elem.setCustomValidity('Enter MonitoriumDays Value');
            elem.reportValidity();
            this.monitoriumDaysDisabled = false;
        }
    }

    handleMonitoriumDays(event) {
        let elem = this.template.querySelector('.monDay');
        elem.setCustomValidity("");
        elem.reportValidity();
        if (this.monitoriumDaysValueFinal !== event.target.value) {
            this.flagMonitoriumDays = true;
            this.flagRequiredCrrIrrOnlyChanged = false;
        }else{this.flagMonitoriumDays = false;}//CISP-2643
        if (this.flagLoanAmountChange == true && this.flagMonitoriumDays == true) {
            if(parseInt(this.loanAmount,10) > this.minLoanAmount && parseInt(this.loanAmount,10) < this.maxLoanAmount){ 
            const event = new ShowToastEvent({
                title: 'Warning',
                message: loanDayChanged,
                variant: 'warning',
            });
            this.dispatchEvent(event);
        }
        else{  const eve = new ShowToastEvent({
            title: 'ERROR',
            message: submitWarning,
            variant: 'Error',
        });
        this.dispatchEvent(eve);
        }
        }
        else if (this.flagMonitoriumDays == true) {
            this.flagMonitoriumDays = true;
            const event = new ShowToastEvent({
                title: 'ERROR',
                message: changeMoratoriumDay,
                variant: 'Error',
            });
            this.dispatchEvent(event);
            this.eligiblityButtonClicked = false;
        }
        this.monitoriumDaysValue = event.target.value;
        this.advanceEmiDisabled = true;
        if (this.monitoriumDaysValue === '0') {
            this.advanceEMi = false;
            this.advanceEmiDisabled = false;
        }
        else{
            let elem = this.template.querySelector('lightning-input[data-id=advanceEMIid]');
            this.advanceEMi = false;
            elem.setCustomValidity("");
            elem.reportValidity();
        }

        this.calculateNumberOfInstallments(this.monitoriumDaysValue, this.tenure);
    }

    async updateRecordDetails(fields) {
        const recordInput = { fields };
        await updateRecord(recordInput)
            .then(() => {
                console.log('after update', recordInput);
                return true;
            })
            .catch(error => {console.log('Error in update', error); });
    }

    handleRequiredCRMIRROnchange(event)
    {
        this.requiredCRMIRR = event.target.value;
        if (this.requiredCrmIrr != this.requiredCRMIRR) {
        this.flagRequiredCrrIrrChange = true;
        }
        else{
            this.flagRequiredCrrIrrChange = false;
        }
    }

    handleRequiredCRMIRRChange(event) {
        let requiredRoiInput = this.template.querySelector('lightning-input[data-id=reqRoi]'); //CISP-5450
        console.log('Changes required ');
        const FinalTermFields = {};
        FinalTermFields[final_ID_FIELD.fieldApiName] = this.isRecordId;
        FinalTermFields[IsRequiredCRMIRRChanged.fieldApiName] = this.requiredCrmIrr !== event.target.value ? true : false;
        this.updateRecordDetails(FinalTermFields);
        // let getrequiredCRM = event.target.value;
        this.requiredCRMIRR = event.target.value;
        if ((this.requiredCRMIRR) < 0) {
            this.requiredCRMIRR = '';
            const event = new ShowToastEvent({
                title: 'Warning',
                message: crmIrrNotNeg,
                variant: 'Warning',
            });
            this.dispatchEvent(event);
        }
        else {
 
            roiMasterForImputedIRR({loanApplicationId : this.recordid,productType : this.productType,tenure : parseInt(this.tenure,10),vehicleCategory : this.vehicleType ,queryBased:'CRM_IRR'})
            .then(result => {
                let parsedData = JSON.parse(result);
                if(parsedData.mincrm != null && parsedData.maxcrm != null){
                    this.mincrm = parsedData.mincrm;
                    this.maxcrm = parsedData.maxcrm;
                    if(this.productType == 'Passenger Vehicles'){ //CISP-5450
                        if (this.requiredCRMIRR < parseFloat(this.mincrm) || this.requiredCRMIRR > parseFloat(this.maxcrm)) {
                            requiredRoiInput.setCustomValidity('CRM IRR is not as per norms Min ' + this.mincrm + ' and Max ' + this.maxcrm);//CISP-5450
                       } 
                        else{
                            requiredRoiInput.setCustomValidity("");
                        }
                            requiredRoiInput.reportValidity();
                        if(this.flagRequiredCrrIrrChange == true){
                            this.eligiblityButtonClicked = false;
                        }
                        return null;
                     }

                    if (parseFloat(this.requiredCRMIRR <= parseFloat(this.maxcrm) && parseFloat(this.requiredCRMIRR) >= this.mincrm && this.requiredCRMIRR) <= parseFloat(this.mincrm)) { 
                        if (this.requiredCrmIrr != this.requiredCRMIRR) {
                            this.flagRequiredCrrIrrChange = true;
                        }
                        if (this.flagRequiredCrrIrrChange && !this.flagLoanAmountChange && !this.flagTenureChange && !this.flagAdvanceEmiChange && !this.flagMonitoriumDays) {
                            this.flagRequiredCrrIrrOnlyChanged = true;
                        }
                       if (this.flagLoanAmountChange == true && this.flagRequiredCrrIrrChange == true) {
                        if(parseInt(this.loanAmount,10) > this.minLoanAmount && parseInt(this.loanAmount,10) < this.maxLoanAmount){ 
                        const event = new ShowToastEvent({
                                title: 'Warning',
                                message: loanCrm,
                                variant: 'warning',
                            });
                            this.dispatchEvent(event);
                        }
                        else{  const eve = new ShowToastEvent({
                            title: 'ERROR',
                            message: submitWarning,
                            variant: 'Error',
                        });
                        this.dispatchEvent(eve);
                        }
                        }
                        else if (this.flagRequiredCrrIrrChange == true) {
                            const event = new ShowToastEvent({
                                title: 'Warning',
                                message: crmChanged,
                                variant: 'Warning',
                            });
                            this.dispatchEvent(event);
                            this.eligiblityButtonClicked = false;
                        }
                    }else if(this.requiredCRMIRR >= this.maxcrm && this.productType != 'Passenger Vehicles'){
                        this.requiredCRMIRR = this.crmIRR;
                        const event = new ShowToastEvent({
                            title: 'Warning',
                            message: crmmaxchange+ this.maxcrm,
                            variant: 'Warning',
                        });
                        this.dispatchEvent(event);
                    }else if( this.requiredCRMIRR <= this.mincrm && this.productType != 'Passenger Vehicles'){
                        this.requiredCRMIRR = this.mincrm;
                        //this.template.querySelector('.reqCrmIrr').value = this.mincrm;
                        const event = new ShowToastEvent({
                            title: 'Warning',
                            message: crmminchange+this.mincrm.toString(),
                            variant: 'Warning'
                        });
                        this.dispatchEvent(event);
                    }else {
                        this.requiredCRMIRR = this.crmIRR;
                        this.template.querySelector('.reqCrmIrr').value = this.crmIRR;
                        const event = new ShowToastEvent({
                            title: 'ERROR',
                            message: crmLessThan,
                            variant: 'Error',
                            mode: 'dismissable'
                        });
                        this.dispatchEvent(event);
                    }
                }else{
                    if (this.requiredCRMIRR <= this.crmIRR) {
                        // this.requiredCRMIRR = event.target.value;
                        if (this.requiredCrmIrr !== this.requiredCRMIRR ) {
                            this.flagRequiredCrrIrrChange = true;
                        }
                        if (this.flagRequiredCrrIrrChange && !this.flagLoanAmountChange && !this.flagTenureChange && !this.flagAdvanceEmiChange && !this.flagMonitoriumDays) {
                            this.flagRequiredCrrIrrOnlyChanged = true;
                        }
                        if (this.flagLoanAmountChange == true && this.flagRequiredCrrIrrChange == true) {
                            const event = new ShowToastEvent({
                                title: 'Warning',
                                message: loanCrm,
                                variant: 'warning',
                            });
                            this.dispatchEvent(event);
                        }
                        else if (this.flagRequiredCrrIrrChange == true) {
                            const event = new ShowToastEvent({
                                title: 'Warning',
                                message: crmChanged,
                                variant: 'Warning',
                            });
                            this.dispatchEvent(event);
                            this.eligiblityButtonClicked = false;
                        }
                    } else {
                        this.requiredCRMIRR = this.crmIRR;
                        this.template.querySelector('.reqCrmIrr').value = this.crmIRR;
                        const event = new ShowToastEvent({
                            title: 'ERROR',
                            message: crmLessThan,
                            variant: 'Error',
                            mode: 'dismissable'
                        });
                        this.dispatchEvent(event);
                    }
                }
            })
            .catch(error => { console.log('Error in roi ',error);});
        }
    }

    get requiredCRMIRRValue(){
        return this.requiredCRMIRR;
    }


    handlePopupOk() {
        this.requiredCRMIRRPopup = false;
    }

    handleCheckEligibility() {
        console.log('this.advanceEMi=>', this.advanceEMi + ' ' + 'this.monitoriumDaysValue', this.monitoriumDaysValue);

        if (this.flagApiFail) {
            const event = new ShowToastEvent({
                title: 'Warning',
                message: clickSubmitButton,
                variant: 'Warning'
            });
            this.dispatchEvent(event);
         }else if (this.productType.toLowerCase() === 'Two Wheeler'.toLowerCase() && ((Number(this.tenure) %6 != 0) || (this.tenure === 0 || this.tenure === '0' || this.tenure === '' || this.tenure === null || this.tenure === undefined))) {
            this.toastMsg('Tenure is required. Please enter value multiple of 6');
        }
         else if (this.productType.toLowerCase() === 'Two Wheeler'.toLowerCase() && this.flagLoanAmountChange && (parseFloat(this.loanAmount) < parseFloat(this.minLoanAmount) || parseFloat(this.loanAmount) > parseFloat(this.maxLoanAmount)) && (!this.flagTenureChange && !this.flagAdvanceEmiChange && !this.flagRequiredCrrIrrChange && !this.flagMonitoriumDays && !this.flagEmiChange)){//Start CISP-2881
           const eve = new ShowToastEvent({
               title: 'ERROR',
               message: submitWarning,
               variant: 'Error',
           });
           this.dispatchEvent(eve);
        }
        else if (this.productType.toLowerCase() !== 'Two Wheeler'.toLowerCase() && this.flagLoanAmountChange && (parseInt(this.loanAmount,10) < this.minLoanAmount || parseInt(this.loanAmount,10) > this.maxLoanAmount) && (!this.flagTenureChange && !this.flagAdvanceEmiChange  && !this.flagRequiredCrrIrrChange  && !this.flagMonitoriumDays && !this.flagEmiChange)){//CISP-12397 Start CISP-2775 //End CISP-2881 
            const eve = new ShowToastEvent({
                title: 'ERROR',
                message: submitWarning,
                variant: 'Error',
            });
            this.dispatchEvent(eve);
        }// Start CISP-2804 
         else if (this.productType.toLowerCase() !== 'Two Wheeler'.toLowerCase() && this.vehicleType.toLowerCase() === 'New'.toLowerCase() && this.oppRecord.Funding_on_Ex_Showroom__c == true && this.oppRecord.Ex_showroom_price__c!=null && this.loanAmount!=null && ((parseFloat(this.loanAmount)) > parseFloat(this.oppRecord.Ex_showroom_price__c))) { 
            const event = new ShowToastEvent({
                title: 'Warning',
                message: 'Loan amount is out of bounds. Please enter value less than Ex Showroom Price '+this.oppRecord.Ex_showroom_price__c,
                variant: 'Warning',
            });
            this.dispatchEvent(event);
            return;
        }else if (this.productType.toLowerCase() !== 'Two Wheeler'.toLowerCase() && this.vehicleType.toLowerCase() === 'New'.toLowerCase() && this.oppRecord.Funding_on_ORP__c == true && this.orp!=null && this.loanAmount!=null && ((parseFloat(this.loanAmount)) > parseFloat(this.orp))) {
            const event = new ShowToastEvent({
                title: 'Warning',
                message: 'Loan amount is out of bounds. Please enter value less than On Road Price '+this.orp,
                variant: 'Warning',
            });
            this.dispatchEvent(event);
        }else if (this.productType.toLowerCase() !== 'Two Wheeler'.toLowerCase() && (this.vehicleType.toLowerCase() === 'Refinance'.toLowerCase() || this.vehicleType.toLowerCase() === 'Used'.toLowerCase()) && this.vehRecord.Base_Prices__c!=null && this.loanAmount!=null && (parseFloat(this.loanAmount)) > parseFloat(this.vehRecord.Base_Prices__c)) {
            const event = new ShowToastEvent({
                title: 'Warning',
                message: 'Loan amount is out of bounds. Please enter value less than Base Price '+ this.vehRecord.Base_Prices__c,
                variant: 'Warning',
            });
            this.dispatchEvent(event);
        }//End CISP-2804
        else if (this.flagLoanAmountChange && parseInt(this.loanAmount,10) > this.minLoanAmount && parseInt(this.loanAmount,10) < this.maxLoanAmount && this.leadSource !='Hero') {//Start CISP-2905 //CISP-4283 
           const eve = new ShowToastEvent({
               title: 'ERROR',
               message: changePayinAndPayout,
               variant: 'Error',
           });
           this.dispatchEvent(eve);
       }//End CISP-2905
       //  else if(this.flagLoanAmountChange) { // Commented this existing validation regarding this ticket CISP-2881
       //      const eve = new ShowToastEvent({
       //          title: 'ERROR',
       //          message: changePayinAndPayout,
       //          variant: 'Error',
       //      });
       //      this.dispatchEvent(eve);
       //  } 

        else if (!this.advanceEMi && (this.monitoriumDaysValue == '0' || this.monitoriumDaysValue == ' ' ||this.monitoriumDaysValue == null )) {
            let elem = this.template.querySelector('lightning-input[data-id=advanceEMIid]');
            elem.setCustomValidity("");
            elem.setCustomValidity('Enter advance EMI Value');
            elem.reportValidity();
            const event = new ShowToastEvent({
                title: 'Warning',
                message: enterEMIDays,
                variant: 'Warning'
            });
            this.dispatchEvent(event);
        }
        else if (!this.flagTenureChange && !this.flagAdvanceEmiChange && !this.flagMonitoriumDays && !this.flagRequiredCrrIrrChange && !this.flagEmiChange && this.leadSource !='Hero') {// CISP-2361
            const event = new ShowToastEvent({
                title: 'Warning',
                message: nothingChanged,
                variant: 'Warning'
            });
            this.dispatchEvent(event);
         }else if(this.productType.toLowerCase() !== 'Two Wheeler'.toLowerCase() && this.requiredCRMIRR!=null && this.mincrm!=null && this.maxcrm!=null && ((parseFloat(this.requiredCRMIRR) < parseFloat(this.mincrm)) || (parseFloat(this.requiredCRMIRR) > parseFloat(this.maxcrm)))){
            const event = new ShowToastEvent({
                title: 'Error',
                message: 'CRM IRR is not as per norms Min ' + this.mincrm + 'and Max '+ this.maxcrm + ' . Please change the required CRM IRR value.',
                variant: 'Error',
            });
            this.dispatchEvent(event);
        }
        else {
            this.eligiblityButtonClicked = true;
            this.isSpinnerMoving = true;
            this.calldoOfferEngineCallout();
            /*   checkRetryExhausted({ loanApplicationId: this.recordid })
                  .then(result => {
                      let response = JSON.parse(result);
                      if (response.message === RetryExhausted) {
                          const evt = new ShowToastEvent({
                              title: "Error",
                              message: response.message,
                              variant: 'error',
                          });
                          this.dispatchEvent(evt);
                          this.isSpinnerMoving = false;
                      }
                      else {
                          
  
                      }
                  })
                  .catch(error => {
                      this.isSpinnerMoving = false;
                  });
          } */
        }
    }

        /*  retryCount() {
             retryCountIncrease({ loanApplicationId: this.recordid })
                 .then(responses => {})
                 .catch(error => {
                     this.isSpinnerMoving = false;
                 });
         } */

        //rendered callback
        renderedCallback() {
            loadStyle(this, LightningCardCSS);
            if (this.currentStageName==='Loan Initiation' || this.currentStageName==='Additional Details' || this.currentStageName==='Asset Details' || this.currentStageName==='Vehicle Valuation' || this.currentStageName==='Vehicle Insurance' || this.currentStageName==='Loan Details' || this.currentStageName==='Income Details' || this.currentStageName==='Final Terms'|| (this.currentStageName!=='Offer Screen' && this.lastStage !== 'Offer Screen' && this.lastStage != undefined && this.currentStageName != undefined)) {//CISP-519
               this.fromRendercallback = true;//CISP-2505
               this.disableEverything();
            }
            //this.disableEverything();
            if (this.isProductTypePV===false) {//Start CISP-2643
                if (this.handleEmiFlagChange===true && this.flagLoanAmountChange===false && this.flagTenureChange===false && this.flagRequiredCrrIrrOnlyChanged===false && this.flagRequiredCrrIrrChange===false && this.flagAdvanceEmiChange===false && this.flagMonitoriumDays===false && this.eligiblityButtonClicked === false) {
                    this.disableSubmit= true;
                    this.isChangePayInOutButtonDisable=true;
                    this.disableCheckEligibility=false;
                } else {
                    this.disableSubmit= false;
                    if (this.handleEmiFlagChange===true && this.flagLoanAmountChange===false && this.flagTenureChange===false && this.flagRequiredCrrIrrOnlyChanged===false && this.flagRequiredCrrIrrChange===false && this.flagAdvanceEmiChange===false && this.flagMonitoriumDays===false && this.eligiblityButtonClicked === true) {
                    this.isChangePayInOutButtonDisable=true;this.disableCheckEligibility=true;}else{this.isChangePayInOutButtonDisable=false;this.disableCheckEligibility=false;}
                }
            }//End CISP-2643

            //Ola integration changes
            if(this.leadSource=='OLA'){//Hero CISH-13
               this.template.querySelector('lightning-input[data-id=emi]').disabled = true;//OLA-19
               this.template.querySelector('.changePayInPayOut').disabled = true;//OLA-16
               this.template.querySelector('.checkEligibility').disabled = true;//OLA-16
            }
        }  
        async calldoOfferEngineCallout() {//CISP-2851
           await this.calculateProvisionAmt(this.loanAmount, this.tenure);//CISP-2851
            console.log('thresholdNetIRR', this.priceingEngineNetIrr);
            console.log('crmIrrChanged', this.requiredCRMIRR);
            console.log('loanAmountChanged', this.loanAmount);
            console.log('tenureChanged', this.tenure);
            console.log('this.advanceEMi ',this.advanceEMi);
            let offerEngineRequestString = {
                'loanApplicationId': this.recordid,
                'currentScreen': this.flagRequiredCrrIrrOnlyChanged == true ? 'Offer screen changed' : 'Offer',
                'thresholdNetIRR': this.priceingEngineNetIrr,
                'crmIrrChanged': this.requiredCRMIRR,
                'loanAmountChanged': this.loanAmount,//CISP-2881
                'tenureChanged': this.tenure,
                'advanceEmiFlag' : this.advanceEMi == false ? 'No' : 'Yes',
                'offerEMI': this.emi?this.emi.toString():'', // INDI-4682
                'provisionAmount' : this.provisionAmount.toString(),//CISP-124
            };
             //Hero Change start
             let offerEngineMethod = doOfferEngineCallout;
             let offerEngineParams = { offerEngineRequestString: JSON.stringify(offerEngineRequestString) };
             if(this.leadSource === 'Hero'){//CISH-04
                 let sliderAmount =Number(this.loanAmount).toString();
                 offerEngineMethod = doD2COfferEngineCallout;
                 offerEngineParams = {loanId: this.recordid, applicantId: null, fromScreen:'sliderScreen',sliderTenure: this.tenure, sliderLoanAmount:sliderAmount};
             }
             //Hero Change end

             offerEngineMethod(offerEngineParams)
                .then(result => {
                    console.log('doOfferEngineCallout result');
                    const obj = (this.leadSource === 'Hero') ? this.getParsedJSOND2C(JSON.parse(result)) : JSON.parse(result);
                    //this.retryCount();
                    console.log('doOfferEngineCallout result',obj);
                    this.isSpinnerMoving = false;
                    const FinalTermFields = {};
                    FinalTermFields[final_ID_FIELD.fieldApiName] = this.isRecordId;
                    FinalTermFields[EMI_Amount.fieldApiName] = obj.EMI != null ? obj.EMI : this.emi;
                    FinalTermFields[Tenure.fieldApiName] = obj.Tenure != null ? obj.Tenure : this.tenure.toString();
                    FinalTermFields[Loan_Amount.fieldApiName] = obj.Loan_Amt != null ? (parseFloat(obj.Loan_Amt) - this.totalFundedPremium).toString() : this.loanAmount.toString();
                    FinalTermFields[CRM_IRR.fieldApiName] = obj.CRM_IRR != null ? obj.CRM_IRR : this.requiredCRMIRR;
                    FinalTermFields[Required_CRM_IRR.fieldApiName] = obj.CRM_IRR != null ? obj.CRM_IRR : this.requiredCRMIRR.toString();
                    if(obj.Max_Tenure_Slider != null)
                    {FinalTermFields[OfferengineMaxTenure.fieldApiName] =obj.Max_Tenure_Slider ;
                    }
                    if(obj.Min_Tenure_Slider != null)
                    {FinalTermFields[OfferengineMinTenure.fieldApiName] = obj.Min_Tenure_Slider;
                    }
                    if(obj.Min_Loan_Amt_Slider != null)
                    {FinalTermFields[OfferengineMinLoanAmount.fieldApiName] =obj.Min_Loan_Amt_Slider;
                    }
                    if(obj.Max_Loan_Amt_Slider != null)
                    {FinalTermFields[OfferengineMaxLoanAmount.fieldApiName] =obj.Max_Loan_Amt_Slider; ;
                    }
                    if(obj.Imputed_IRR_Offered != null)
                    { FinalTermFields[Inputted_IRR.fieldApiName] = parseFloat(obj.Imputed_IRR_Offered);}
                    if(obj.Net_IRR_Offered != null)
                    {FinalTermFields[Net_IRR.fieldApiName] = parseFloat(obj.Net_IRR_Offered);}
                    if(obj.Gross_IRR_Offered != null)
                    {FinalTermFields[Gross_IRR.fieldApiName] = parseFloat(obj.Gross_IRR_Offered);}
                     if(obj.Stop_Journey_Flag === "True" && this.productType !== 'Passenger Vehicles'){//CISP-2804
                    FinalTermFields[OfferengineStopJourneyFlag.fieldApiName]=true;
                    }
                    FinalTermFields[Advance_EMI.fieldApiName] = this.advanceEMi;
                    if (this.monitoriumDaysValue != null) {
                        FinalTermFields[Holiday_period.fieldApiName] = this.monitoriumDaysValue.toString();
                    }
                    else { FinalTermFields[Holiday_period.fieldApiName] = '0'; }

                    //CISP-124
                    if(this.provisionAmount){
                       FinalTermFields[Provisional_Channel_Cost.fieldApiName] = this.provisionAmount.toString();
                    }
                    //CISP-124
                    FinalTermFields[IsOfferEngineApiFailed.fieldApiName] = false;
                    if(this.leadSource == 'Hero'){
                        if(obj.NetPayIns != null && this.leadSource === 'Hero'){
                            FinalTermFields[Net_Pay_Ins.fieldApiName]=obj.NetPayIns;
                        }
                        if(obj.NetPayOuts != null && this.leadSource === 'Hero'){
                            FinalTermFields[Net_Pay_Outs.fieldApiName]=obj.NetPayOuts;
                        }
                        if(obj.Loan_Amt != null){
                            FinalTermFields[Loan_Amount.fieldApiName] = obj.Loan_Amt.toString();
                        }else{
                            FinalTermFields[Loan_Amount.fieldApiName] = this.loanAmount.toString();
                        }
                        
                    }
                    if(this.leadSource === 'Hero') {
                        FinalTermFields[service_charge.fieldApiName] = obj.serviceCharges;
                        FinalTermFields[Provisional_Channel_Cost.fieldApiName] = obj.provisionCost;
                        FinalTermFields[Mfr_incentive.fieldApiName] = obj.mfrIncentiveAmt;
                        FinalTermFields[Dealer_incentive_amount_main_dealer.fieldApiName] = obj.dealerIncentiveAmtMain;
                        FinalTermFields[doc_charge.fieldApiName] = obj.docCharges;
                    }
                    if(this.leadSource != 'D2C' && this.leadSource != 'Hero'){
                        if(obj.TableCode){FinalTermFields[Table_Code.fieldApiName] = obj.TableCode;}
                        if(obj.Interest_VersionNo){FinalTermFields[Interest_Version_No.fieldApiName] = obj.Interest_VersionNo;}
                        if(obj.DR_PenalInterest){FinalTermFields[DR_Penal_Interest.fieldApiName] = obj.DR_PenalInterest;}
                        if(obj.mclrRate){FinalTermFields[mclrRate.fieldApiName] = obj.mclrRate;}
                    }
                    this.updateRecordDetails(FinalTermFields);
                    //window.location.reload();
                    this.loanAmount = obj.Loan_Amt != null ? obj.Loan_Amt : this.loanAmount;
                    this.loanAmountFinal = obj.Loan_Amt != null ? obj.Loan_Amt : this.loanAmount;
                    this.tenure = obj.Tenure != null ? obj.Tenure : this.tenure;
                    this.tenureFinal = obj.Tenure != null ? obj.Tenure : this.tenure;
                    this.crmIRR = obj.CRM_IRR != null ? obj.CRM_IRR : this.crmIRR;
                    this.emi = obj.EMI != null ? obj.EMI : this.emi;
                    this.requiredCRMIRR = obj.CRM_IRR != null ? obj.CRM_IRR : this.requiredCRMIRR;
                    this.maxLoanAmount = obj.Max_Loan_Amt_Slider != null ? obj.Max_Loan_Amt_Slider : this.maxLoanAmount;
                    this.minLoanAmount = obj.Min_Loan_Amt_Slider != null ? obj.Min_Loan_Amt_Slider : this.minLoanAmount;
                    this.maxTenure = obj.Max_Tenure_Slider != null ? obj.Max_Tenure_Slider : this.maxTenure;
                    this.minTenure = obj.Min_Tenure_Slider != null ? obj.Min_Tenure_Slider : this.minTenure;
                     if(obj.Stop_Journey_Flag === "True" && this.productType !== 'Passenger Vehicles')
                     {//CISP-2804
                        this.toastMsg('Journey Stoped');
                            let allElements = this.template.querySelectorAll('*');
                            allElements.forEach(element =>
                            element.disabled=true
                            );
                            this.isSpinnerMoving = false;
                            this.template.querySelector('.cancel').disabled=false;this.journeyStopScenarioFound();
                    }
                    else{
                        const evt = new ShowToastEvent({
                            title: "Success",
                            message: "Offer Engine Successful",
                            variant: 'Success',
                        });
                        this.dispatchEvent(evt);
                        this.flagLoanAmountChange = false;
                        this.flagTenureChange = false;
                        this.flagAdvanceEmiChange = false;
                        this.flagMonitoriumDays = false;
                        this.flagRequiredCrrIrrChange = false;
                        this.flagEmiChange = false;//CISP-2643
                        this.isSpinnerMoving = false;
                        this.advanceEmis = this.advanceEMi;
                        this.requiredCrmIrr = this.requiredCRMIRR;
                        this.tenureFinal = this.tenure;
                        this.loanAmountFinal = this.loanAmount;
                        this.monitoriumDaysValueFinal = this.monitoriumDaysValue;
                    }
                    this.calculateNumberOfInstallments(this.monitoriumDaysValue, this.tenure);
                    this.netIRRValue = obj.Net_IRR_Offered != null ? obj.Net_IRR_Offered : this.netIRRValue;
                    this.grossIRRValue = obj.Gross_IRR_Offered != null ? obj.Gross_IRR_Offered : this.grossIRRValue;
                    this.getDocumentsToCheckPanValid(); //CISP-3938
                })
                .catch(error => {
                    const evt = new ShowToastEvent({
                        title: "Error",
                        message: error.body.message,
                        variant: 'error',
                    });
                    this.dispatchEvent(evt);
                    this.isSpinnerMoving = false;
                    this.isOfferengineApiFail = true;//CISH-36
                    const FinalTermFields = {};
                    FinalTermFields[final_ID_FIELD.fieldApiName] = this.isRecordId;
                    FinalTermFields[IsOfferEngineApiFailed.fieldApiName] = true;
                    this.updateRecordDetails(FinalTermFields);
            //          const FinalTermFields = {};
            //  //saving all the change fields.
            //  FinalTermFields[final_ID_FIELD.fieldApiName] = this.isRecordId;
            //  FinalTermFields[Loan_Amount.fieldApiName] = this.loanAmount.toString();
            //  FinalTermFields[Tenure.fieldApiName] = this.tenure.toString();
            //  FinalTermFields[Required_CRM_IRR.fieldApiName] = this.requiredCRMIRR.toString();
            //  FinalTermFields[Advance_EMI.fieldApiName] = this.advanceEMi;
            //  if (this.monitoriumDaysValue != null) {
            //  FinalTermFields[Holiday_period.fieldApiName] = this.monitoriumDaysValue.toString();
            //  }
            //  else { FinalTermFields[Holiday_period.fieldApiName] = '0'; }
            //  //CISP-124
            //  if(this.provisionAmount){
            //     FinalTermFields[Provisional_Channel_Cost.fieldApiName] = this.provisionAmount.toString();
            //  }
            //  //CISP-124
            //  this.updateRecordDetails(FinalTermFields);
                });
        }

        //CISP-4459 start
        journeyStopScenarioFound(){
            updateJourneyStop({ leadNo: this.recordid })
            .then(result => {
                console.log('Result', result);
            })
            .catch(error => {
                console.error('Error:', error);
            });
        }//CISP-4459
        
        disableEverything(){
            let allElements = this.template.querySelectorAll('*');
            allElements.forEach(element =>
               element.label && element.label =='EMI Amount' && this.productType?.toLowerCase() === 'Two Wheeler'.toLowerCase()  && this.checkleadaccess===false && !this.fromRendercallback ?element.disabled = false:element.disabled = true //CISP-2505-- //CISP-519 Added safe operator.
            );
        }
        //Hero Changes 
    getParsedJSOND2C(parsedJSON){
        let obj = {};
        obj.EMI = parsedJSON?.application?.offerEngineDetails?.offerEngineDecision?.displayEMI;
        obj.Tenure = parsedJSON?.application?.offerEngineDetails?.offerEngineDecision?.displayTenure?.toString();
        obj.Loan_Amt = parsedJSON?.application?.offerEngineDetails?.offerEngineDecision?.displayLoanAmt;
        obj.CRM_IRR = parsedJSON?.application?.offerEngineDetails?.offerEngineDecision?.displayCrmIrr?.toString();
        obj.Max_Tenure_Slider = parsedJSON?.application?.offerEngineDetails?.offerEngineDecision?.maxTenureSlider;
        obj.Min_Tenure_Slider = parsedJSON?.application?.offerEngineDetails?.offerEngineDecision?.minTenureSlider;
        obj.Min_Loan_Amt_Slider = parsedJSON?.application?.offerEngineDetails?.offerEngineDecision?.minLoanAmtSlider;
        obj.Max_Loan_Amt_Slider = parsedJSON?.application?.offerEngineDetails?.offerEngineDecision?.maxLoanAmtSlider;
        obj.Imputed_IRR_Offered = parsedJSON?.application?.offerEngineDetails?.offerEngineDecision?.displayImputedIrr;
        obj.Net_IRR_Offered = parsedJSON?.application?.offerEngineDetails?.offerEngineDecision?.netIrr;
        obj.Gross_IRR_Offered = parsedJSON?.application?.offerEngineDetails?.offerEngineDecision?.grossIrr;
        obj.Stop_Journey_Flag = parsedJSON?.application?.offerEngineDetails?.offerEngineDecision?.stopJourneyFlag;
        obj.Stop_Journey_Flag = obj.Stop_Journey_Flag ? 'True' : 'False';
        obj.NetPayIns = parsedJSON?.application?.offerEngineDetails?.offerEngineDecision?.netPayIns?.toString();
        obj.NetPayOuts = parsedJSON?.application?.offerEngineDetails?.offerEngineDecision?.netPayOuts?.toString();
        obj.serviceCharges = parsedJSON?.application?.offerEngineDetails?.payins?.serviceCharges?.toString();
        obj.docCharges = parsedJSON?.application?.offerEngineDetails?.payins?.docCharges?.toString();
        obj.provisionCost = parsedJSON?.application?.offerEngineDetails?.payouts?.provisionCost?.toString();
        obj.mfrIncentiveAmt = parsedJSON?.application?.offerEngineDetails?.payouts?.mfrIncentiveAmt?.toString();
        obj.dlrIncentiveAmtMain = parsedJSON?.application?.offerEngineDetails?.payouts?.dlrIncentiveAmtMain?.toString();
        return obj;
    }
        selectedSchemeRecord(){
            this.schemeValid = false;
            loadSelectedSchemeData({ selectedSchemeId: this.selectedSchemeId })
            .then(result => {
                if (result) {
                    try {
                        if (result.Min_Loan_Amount_Not_Applicable__c===false && result.Loan_Amount_Min__c && result.Loan_Amount_Min__c> this.loanAmount) {
                            this.toastMsg('Finance Amount entered is below Scheme Min. Loan amount');
                            this.schemeValid = true;
                        }
                        if (result.Max_Loan_amount_Not_Applicable__c===false && result.Loan_amount_Max__c && result.Loan_amount_Max__c < this.loanAmount) {
                            this.toastMsg('Finance Amount entered is above Scheme Max. Loan amount');
                            this.schemeValid = true;
                        }
                        if (result.Min_Tenure_Not_Applicable__c===false && result.Tenure_Min_in_months__c && result.Tenure_Min_in_months__c > this.tenure) {
                            this.toastMsg('Tenure entered is below Scheme Min. Tenure');
                            this.schemeValid = true;
                        }
                        if (result.Max_Tenure_Not_Applicable__c===false && result.Tenure_Max_in_months__c && result.Tenure_Max_in_months__c < this.tenure) {
                            this.toastMsg('Tenure entered is above Scheme Max. Tenure');
                            this.schemeValid = true;
                        }
                    } catch (error) {
                        console.error('Error 11==> ',error);
                    }
                }
            }).catch(error=>{
                console.error('Error in loadSelectedSchemeData==> ',error);
            });
        }

        //CISP-124
       async calculateProvisionAmt(loanAmount, tenure) {//CISP-2851
           try {
               let provisionalChannelCostValue = '';
               if(this.productType.toLowerCase()==='Two Wheeler'.toLowerCase() && (this.vehicleType.toLowerCase()==='new'.toLowerCase()) && this.leadSource != 'Hero'){//CISH-48
                   if(tenure >= 12){
                       let checkProvisionalChannelCost=(this.provisionalChannelCostValid * (parseInt(loanAmount, 10) / 100) + this.provisionalChannelCostMinValid);
                       checkProvisionalChannelCost=(Math.round(checkProvisionalChannelCost));
                       provisionalChannelCostValue=checkProvisionalChannelCost;
                   }else{
                       let checkProvisionalChannelCost=(this.provisionalChannelCostTwoValid * (parseInt(loanAmount, 10) / 100) + this.provisionalChannelCostMaxValid);
                       checkProvisionalChannelCost=(Math.round(checkProvisionalChannelCost));
                       provisionalChannelCostValue=checkProvisionalChannelCost;
                   }
               }
               else if(this.productType.toLowerCase()==='Two Wheeler'.toLowerCase() && (this.vehicleType.toLowerCase()==='Refinance'.toLowerCase() || this.vehicleType.toLowerCase()==='used'.toLowerCase())){
                   let checkProvisionalChannelCost=((this.provisionalChannelCostValid * parseInt(loanAmount, 10) / 100) + this.provisionalChannelCostMaxValid);
                   checkProvisionalChannelCost=(Math.round(checkProvisionalChannelCost));
                   provisionalChannelCostValue=checkProvisionalChannelCost;
               }
               console.log('provisionalChannelCostValue ', provisionalChannelCostValue);
               this.provisionAmount = provisionalChannelCostValue;
           } catch (error) {
               console.error(error);
           }
       }
       //CISP-124
       async getDocumentsToCheckPanValid(){
            let totalamount = 0;
            if(this.oppTotalExposureAmt){totalamount = parseInt(this.oppTotalExposureAmt)}
            else{totalamount = parseInt(this.fundedPremiumValue) + parseInt(this.loanAmount)}

            if((parseInt(totalamount) >= 1000000) && (this.documentCheckdata?.borrowerPanAvailable == false || this.documentCheckdata?.coborrowerPanAvailable == false ) && this.leadSource != 'D2C'){
                this.toastMsg('Exposure (Incl. loan amount) is >=10 Lakhs, hence, PAN is mandatory. Please withdraw this lead and create a new lead with PAN or change the Loan amount');
                return false;
            }
            return true;
        }
    }