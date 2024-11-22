/**
 * Created by nagen on 08-01-2022.
 */
import { api, LightningElement, track } from 'lwc';
import getOfferScreenData from '@salesforce/apex/IND_OfferScreenController.getOfferScreenData';
import { updateRecord } from 'lightning/uiRecordApi';
import doOfferEngineCallout from '@salesforce/apexContinuation/IntegrationEngine.doOfferEngineCallout';
import doD2COfferEngineCallout from '@salesforce/apexContinuation/D2C_IntegrationEngine.doD2COfferEngineCallout';
import { loadStyle } from 'lightning/platformResourceLoader';
import LightningCardCSS from '@salesforce/resourceUrl/loanApplication';
import createFinalTermRecord from '@salesforce/apex/FinalTermscontroller.createFinalTermRecord';
import Provisional_Channel_Cost from '@salesforce/schema/Final_Term__c.Provisional_Channel_Cost__c';//CISP-124
import service_charge from '@salesforce/schema/Final_Term__c.Service_charges__c';//D2C Change
import doc_charge from '@salesforce/schema/Final_Term__c.Documentation_charges__c';//D2C Change
import Mfr_incentive from '@salesforce/schema/Final_Term__c.Mfr_incentive__c';//D2C Change
import Dealer_incentive_amount_main_dealer from '@salesforce/schema/Final_Term__c.Dealer_incentive_amount_main_dealer__c';//D2C Change
import FORM_FACTOR from '@salesforce/client/formFactor';
//Custom Fields 
import Refinance from '@salesforce/label/c.Refinance';
//fields of Offer Screen
import final_ID_FIELD from '@salesforce/schema/Final_Term__c.Id';
import Loan_Amount from '@salesforce/schema/Final_Term__c.Loan_Amount__c';
import Advance_EMI from '@salesforce/schema/Final_Term__c.Advance_EMI__c';
import Holiday_period from '@salesforce/schema/Final_Term__c.Holiday_period__c';
import Inputted_IRR from '@salesforce/schema/Final_Term__c.Inputted_IRR__c';
import Net_IRR from '@salesforce/schema/Final_Term__c.Net_IRR__c';
import Net_IRR_DECIMAL from '@salesforce/schema/Final_Term__c.Net_IRR_Decimal__c';
import OfferengineMaxTenure from '@salesforce/schema/Final_Term__c.OfferengineMaxTenure__c';
import OfferengineMinTenure from '@salesforce/schema/Final_Term__c.OfferengineMinTenure__c';
import OfferengineStopJourneyFlag from '@salesforce/schema/Final_Term__c.Offerengine_StopJourney_Flag__c';
import OfferengineMinLoanAmount from '@salesforce/schema/Final_Term__c.OfferengineMinLoanAmount__c';
import OfferengineMaxLoanAmount from '@salesforce/schema/Final_Term__c.OfferengineMaxLoanAmount__c';
import Gross_IRR from '@salesforce/schema/Final_Term__c.Gross_IRR__c';
import CRM_IRR from '@salesforce/schema/Final_Term__c.CRM_IRR__c';
import Required_CRM_IRR from '@salesforce/schema/Final_Term__c.Required_CRM_IRR__c';
import Tenure from '@salesforce/schema/Final_Term__c.Tenure__c';
import EMI_Amount from '@salesforce/schema/Final_Term__c.EMI_Amount__c';

import getVechicleDetails from '@salesforce/apex/IND_OfferScreenController.getVechicleDetails';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import rerunonloan from '@salesforce/label/c.rerunonloan'
import rerunontenure from '@salesforce/label/c.rerunontenure';
import rerunMoratorium from '@salesforce/label/c.rerunMoratorium';
import rerunAdvanceChanged from '@salesforce/label/c.rerunAdvanceChanged';
import rerunloanDayChanged from '@salesforce/label/c.rerunloanDayChanged';
import rerunloanCrm from '@salesforce/label/c.rerunloanCrm';
import reruncrmChanged from '@salesforce/label/c.reruncrmChanged';
import crmLessThan from '@salesforce/label/c.crmLessThan';
import crmIrrNotNeg from '@salesforce/label/c.crmIrrNotNeg';
import crmmaxchange from '@salesforce/label/c.crmmaxchange';
import crmminchange from '@salesforce/label/c.crmminchange';
import rerunCheckEligibility from '@salesforce/label/c.rerunCheckEligibility';
import getFinalTermFieldDetails from '@salesforce/apex/FinalTermscontroller.getFinalTermFieldValidationDetails';//CISP-124
import Net_Pay_Ins from '@salesforce/schema/Final_Term__c.Net_Pay_Ins__c';
import Net_Pay_Outs from '@salesforce/schema/Final_Term__c.Net_Pay_Outs__c';
import fetchLoanDetails from '@salesforce/apex/IND_LWC_LoanDetailsCntrl.fetchLoanDetails';//Ola integration changes
import updateJourneyStop from '@salesforce/apex/customerDedupeRevisedClass.updateJourneyStop'; //CISP-4459
import roiMasterForImputedIRR from '@salesforce/apex/IND_OfferScreenController.roiMasterForImputedIRR';//CISP-5450
import getDocumentsToCheckPan from '@salesforce/apex/IND_LWC_LoanDetailsCntrl.getDocumentsToCheckPan';
import Table_Code from '@salesforce/schema/Final_Term__c.Table_Code__c';//CISP-16547 
import DR_Penal_Interest from '@salesforce/schema/Final_Term__c.DR_Penal_Interest__c';//CISP-16547
import Interest_Version_No from '@salesforce/schema/Final_Term__c.Interest_Version_No__c';//CISP-16547
import mclrRate from '@salesforce/schema/Final_Term__c.mclrRate__c';//CISP-16547 
import Loan_Deal_Date from '@salesforce/schema/Final_Term__c.Loan_Deal_Date__c';
import OE_Agreement_Amount from '@salesforce/schema/Final_Term__c.Offer_Agreement_Amount__c'; 
import * as helper from './lwc_incomeloanofferHelper';
import getPurchaseprice from '@salesforce/apex/IND_OfferScreenController.getPurchaseprice'; //SFTRAC-901
export default class LwcOfferScreen extends NavigationMixin(LightningElement) {
    documentCheckdata;oppTotalExposureAmt = 0;fundedPremiumValue = 0;existingBorrowerExposureAmount = 0;existingCoBorrowerExposureAmount=0; 
    existingOtherExposureAmount =0;bankExposureAmount=0;//CISP-18978 
    @track crmIRR;@track maxcrmtf;@track mincrmtf; @track maxGROSSIRR;@track minGROSSIRR; isNonIndividual=false;@track isProductTypePVT = false;
    @api recordId;@api appId;@api offerengineparent;@api index;@track applicantId;@track requiredCRMIRR;@track minLoanAmount;@track minTenure;@track maxLoanAmount;@track maxTenure;@track emi;@track loanAmount;@track tenure;@track loanTimeoutId;@track tenureTimeoutId;@track loanSliderDisabled = false;@track tenureSliderDisabled = false;@track isLoanAmountChanged = false;@track isTenureChanged = false;@track isRecordId;@track requiredCRMIRRPopup = false;@track isTenureEligibleCheck = false;@track isloanAmountCheck = false;@api substage;@track substageTractor = false;@track notgreaterthanmax=true;@track leadSource;
    //@track isChangePayInOutButtonDisable = false;
    @track productSegment;//CISP-13665
    @track vehiclePurchaseprice;isSpinnerMoving = false;advanceEMi;advanceEmis;requiredCrmIrr;loanAmountFinal;monitoriumDaysDisabled = false;monitoriumDaysValue;monitoriumDaysValueFinal;priceingEngineNetIrr;advanceEmiDisabled = false;
    manufacturerYearMonth;vehicleAge;currentscreen;
    leadSource; //D2C Swapnil
    //Flags
    eligiblityButtonClicked = false;flagtoUpdate = false;flagLoanAmountChange = false;flagRequiredCrrIrrOnlyChanged = false;flagTenureChange = false;flagRequiredCrrIrrChange = false;flagAdvanceEmiChange = false;flagMonitoriumDays = false;tenureFinal;
    orp;//CISP-2459
    totalFundedPremium=0;
    flagApiFail = false;@track mincrm;@track maxcrm;@track EligibleLoanAmt;@track EligibleTenure;@track vechSubCategory = '';@track vehicleType;@track productType;@track getTenureValue;@track handleTenureChangebln = false;@track isProductTypePV = false;@track numberOfInstallmentValue = '';@track netIRRValue = '';@track grossIRRValue = '';emiFinal;  //CISP-2379
    flagEmiChange = false;
    @track disabledEmiAmount = true;//CISP-2505
    //CISP-124
    provisionAmount = 0;
    provisionalChannelCostMinValid = 0;provisionalChannelCostMaxValid = 0;provisionalChannelCostTwoValid = 0;provisionalChannelCostValid = 0;
    oppRecord;vehRecord;handleEmiFlagChange=false;
    @api isRevokedLoanApplication;isSmallDevice = false;@api 
    set updatedORPAmount(value){ if(value){   this.orp = parseInt(value); }}
    get updatedORPAmount(){ return this.orp;}
    @api vehicleId;@track dealId;@track accordionName = "Offer Screen";
    isD2C=false;
    isProductTypeTW=false;
    @track rerunOEDisable = true;@track iconButtonengine = false;@track isTractor =  false;@track installmentType = '';@track structuredInstallment = false;@track incomeScreen = true;@track installmentFrequency;@api
    validateORPAmount(){
        if (this.productType?.toLowerCase() === 'Two Wheeler'.toLowerCase() && ((this.vehicleType?.toLowerCase() === 'New'.toLowerCase() && this.oppRecord?.Funding_on_ORP__c == true && this.orp!=null && ((parseFloat(this.loanAmount) + parseFloat(this.totalFundedPremium)) > parseFloat(this.orp))) || (this.loanAmount == null || this.loanAmount == '' || this.loanAmount == undefined))) {
            const event = new ShowToastEvent({
                title: 'Warning',
                message: 'Loan amount is out of bounds. Please enter value less than On Road Price '+this.orp,
                variant: 'Warning',
             });
             this.dispatchEvent(event);  this.loanAmount = '';  return false;
        }
        return true;
    }
    //CISP-5450 start
    @api
    async validateNetIRRAmount(){
        let isvalid = true;
        console.log('validateNetIRRAmount',this.productType?.toLowerCase() === 'Passenger Vehicles'.toLowerCase());
        if (this.productType?.toLowerCase() === 'Passenger Vehicles'.toLowerCase()) {
            await roiMasterForImputedIRR({ loanApplicationId : this.recordId,productType : this.productType,tenure : parseInt(this.tenure,10),vehicleCategory : this.vehicleType,queryBased:'NET_IRR' })
            .then(result => {
              console.log('Result roiMasterForImputedIRR', result);
              let parsedData = JSON.parse(result);let minNetIrr = parsedData.mincrm;let maxNetIrr = parsedData.maxcrm;
              console.log('minNetIrr',minNetIrr);console.log('maxNetIrr',maxNetIrr);
              if(this.netIRRValue!=null && minNetIrr!=null && maxNetIrr!=null && ((parseFloat(this.netIRRValue) < parseFloat(minNetIrr)) || (parseFloat(this.netIRRValue) > parseFloat(maxNetIrr)))){//Start INDI-4682 // CISP-2702
                  const event = new ShowToastEvent({
                      title: 'Error',
                      message: 'Net IRR is not as per norms Min ' + minNetIrr + 'and Max '+ maxNetIrr + ' . Please make the relevant changes by editing other loan terms.',
                      variant: 'Error',
                  });
                  this.dispatchEvent(event);
                  isvalid = false;
              }
            })
            .catch(error => {
              console.error('Error:', error);
          });
        }
        return isvalid; 
    }
    @api
    async validateCRMIRRAmount(){
        let isvalid = true;
        console.log('validateCRMIRRAmount',this.productType?.toLowerCase() === 'Passenger Vehicles'.toLowerCase());
        if (this.productType?.toLowerCase() === 'Passenger Vehicles'.toLowerCase()) {
            let requiredRoiInput = this.template.querySelector('lightning-input[data-id=reqRoi]'); //CISP-5450
              if (this.requiredCRMIRR < parseFloat(this.mincrm) || this.requiredCRMIRR > parseFloat(this.maxcrm)) {
                requiredRoiInput.setCustomValidity('CRM IRR is not as per norms Min ' + this.mincrm + ' and Max ' + this.maxcrm);
                requiredRoiInput.reportValidity();
                isvalid = false;
           } 
        }
        return isvalid; 
    }//CISP-19529
    get isAdvanceEmiDisabled(){ //D2C Change
        return this.advanceEmiDisabled || this.leadSource == 'D2C';}

    get isMonitoriumDaysDisabled(){ //D2C Change
        return this.monitoriumDaysDisabled || this.leadSource == 'D2C' || this.leadSource == 'Hero';//CISH-04
    }

    get isDisabledRequiredCrmIrr(){ //D2C Change
        return this.disabledRequiredCrmIrr || this.leadSource == 'D2C'; }
    async connectedCallback() {////CISP-124
        if(FORM_FACTOR !== 'Large'){
            this.isSmallDevice = true;
        }
        var monitoriumDaysList = new Array()
        this.disabledCrmIrr = true; this.disabledEmiAmount = true;
        await fetchLoanDetails({ opportunityId: this.recordId }).then(result => {
            this.leadSource = result?.loanApplicationDetails[0]?.LeadSource;
            this.isD2C = this.leadSource === 'D2C';
            this.substageTractor = result?.loanApplicationDetails[0]?.Sub_Stage__c != 'Income' ? true : false;
        });
        ////CISP-124
        await getVechicleDetails({ loanApplicationId: this.recordId, vehicleId : this.vehicleId})
            .then(result => {
                this.EligibleTenure = result.Eligible_Tenure__c;this.EligibleLoanAmt = result.Eligible_Loan_Amount__c;this.leadSource = result.Loan_Application__r.LeadSource;
                this.isD2C = this.leadSource === 'D2C';
                this.dealId = result.Deal_Number__c;
                this.oppTotalExposureAmt = result.Loan_Application__r.Total_Exposures_Amount__c ? result.Loan_Application__r.Total_Exposures_Amount__c : 0; 
                this.fundedPremiumValue = result.Loan_Application__r.Total_Funded_Premium__c ? result.Loan_Application__r.Total_Funded_Premium__c : 0; 
                this.existingBorrowerExposureAmount = result.Loan_Application__r.Existing_Borrowers_Exposure_Amt__c ? result.Loan_Application__r.Existing_Borrowers_Exposure_Amt__c : 0;  
                this.existingCoBorrowerExposureAmount = result.Loan_Application__r.Existing_Co_Borrowers_Exposure_Amt__c ? result.Loan_Application__r.Existing_Co_Borrowers_Exposure_Amt__c : 0; 
                this.existingOtherExposureAmount = result.Loan_Application__r.Existing_Others_Exposure_Amt__c ? result.Loan_Application__r.Existing_Others_Exposure_Amt__c : 0; 
                this.bankExposureAmount = result.Loan_Application__r.Total_Bank_Exposure__c ? result.Loan_Application__r.Total_Bank_Exposure__c : 0; 
                if (result.Loan_Application__r.Vehicle_Sub_Category__c) {
                    this.vechSubCategory = result.Loan_Application__r.Vehicle_Sub_Category__c;
                }
                if (this.vechSubCategory.toLowerCase() === 'UIM'.toLowerCase() && this.productType != 'Tractor') {
                    this.maxLoanAmount = result.Eligible_Loan_Amount__c;
                    this.maxTenure = result.Eligible_Tenure__c;
                }
                this.vehicleType = result.Loan_Application__r.Vehicle_Type__c;
                this.manufacturerYearMonth = result.Manufacturer_Year_Month__c;
                this.productType = result.Loan_Application__r.Product_Type__c;
                monitoriumDaysList.push({ label: '0', value: '0' });monitoriumDaysList.push({ label: '30', value: '30' });monitoriumDaysList.push({ label: '60', value: '60' });monitoriumDaysList.push({ label: '90', value: '90' });monitoriumDaysList.push({ label: '120', value: '120' });monitoriumDaysList.push({ label: '150', value: '150' });monitoriumDaysList.push({ label: '180', value: '180' });
                this.monitoriumDaysOption = monitoriumDaysList;
                let monthAndYear
                if (result.Manufacturer_Year_Month__c) {
                    monthAndYear = this.manufacturerYearMonth.split('-');let currentTime = new Date();let year = currentTime.getFullYear();let month = currentTime.getMonth();let ageval = Math.abs(year - monthAndYear[0]) * 12;let age = ageval + Math.abs(month - monthAndYear[1]);this.vehicleAge = age;
                }
                if(this.productType == 'Passenger Vehicles'){
                    this.isProductTypePV = true;this.isProductTypePVT=true;
                }
                if(this.productType == 'Tractor'){
                    this.isProductTypePVT = true;helper.fetchROIMaster(this);
                    this.accordionName += ' - '+result.Variant__c;this.isTractor = true;this.disabledTenure = true;this.monitoriumDaysDisabled = true;this.tenureSliderDisabled = true;this.disabledLoanAmount = true;this.loanSliderDisabled = true;this.disabledRequiredCrmIrr = true;
                }
                helper.loadoffer(this);
                if (this.productType.toLowerCase() === 'Two Wheeler'.toLowerCase()) {//Enhancement for INDI-4682 
                    this.isProductTypeTW =true;
                    if (this.substage===false) {//STart CISP-2505
                        if(this.leadSource != 'D2C' && this.leadSource != 'Hero') {
                            this.disabledEmiAmount=false;
                        }
                    }//End CISP-2505
                    this.disabledCrmIrr=true;
                }
                helper.getEmiDateList(this);
            })
            .catch(error => { console.log('Error in getVechicleDetails ', error) });
            //CISP-124
            await getFinalTermFieldDetails({ opportunityId: this.recordId , vehicleId : this.vehicleId })
                .then(result => {
                    console.log('result --> ', result);
                    if(result){
                        let finalTermData=result.finalTermVal[0];
                        let finalTermResult = result.finalTermDetailLst[0];
                        if(finalTermResult){
                            this.installmentType = finalTermResult.Installment_Type__c;
                            this.installmentFrequency = finalTermResult.Installment_Frequency__c;
                            this.structuredInstallment = this.installmentType == 'Structured' ? true: false;
                            let loanAmount = finalTermResult?.Loan_Amount__c == null ? 0 : finalTermResult?.Loan_Amount__c;
                            let firstInsValue = finalTermResult?.Loan_Application__r?.Total_Funded_Premium__c == null ? 0 : finalTermResult?.Loan_Application__r?.Total_Funded_Premium__c;
                            if(!this.isTractor){
                                if(!this.leadSource || this.leadSource !== 'D2C'){ // D2C Change
                                    this.loanAmount = (Number(loanAmount) + Number(firstInsValue)).toString();
                                }else{
                                    this.loanAmount = Number(loanAmount);
                                }
                                this.loanAmount = (Number(loanAmount) + Number(firstInsValue)).toString();
                            }                            
                            this.tenure = finalTermResult?.Tenure__c == null ? 0 : finalTermResult?.Tenure__c;
                        }
                        this.provisionalChannelCostValid=finalTermData.ProvisionalChannelCost__c;this.provisionalChannelCostTwoValid=finalTermData.ProvisionalChannelCostTwo__c;this.provisionalChannelCostMaxValid=finalTermData.ProvisionalChannelCostMax__c;this.provisionalChannelCostMinValid=finalTermData.ProvisionalChannelCostMin__c;this.calculateProvisionAmt(this.loanAmount, this.tenure);
                    }
                }).catch(error=>{
                    console.log(error);
                });

                //CISP-13665
                if(this.productType.toLowerCase() === 'Two Wheeler'.toLowerCase() && this.productSegment && this.productSegment==='ESCOOTER'){
                    this.minLoanAmount = 25000;}//CISP-13665
                //CISP-124
                if(this.leadSource=='OLA'){ this.disableEverything();}//Ola Integration changes
                if(this.isRevokedLoanApplication){this.disableEverything();}//CISP-2735
                 /*CISP-7438 Start*/
                 if(this.leadSource == 'D2C' && this.isProductTypePV){
                    this.minLoanAmount = 75000;
                    console.log('Lead Source D2C')
                    if(this.vehicleType == 'Used' ||  this.vehicleType == 'Refinance'){
                        this.maxTenure = 60;
                    }else if(this.vehicleType == 'New'){
                        this.maxTenure = 84;
                    }
                    console.log('this.vehicleType+> '+this.vehicleType)
                }
                /*CISP-7438 End*/
                await getDocumentsToCheckPan({ loanApplicationId: this.recordId })
            .then(result => {
                console.log('Result', result);
                    this.documentCheckdata = JSON.parse(result);
            })
            .catch(error => {
                console.error('Error:', error);
            });
            //SFTRAC-901
            if(this.isTractor){
                let getResponse = await getPurchaseprice({ loanApplicationId: this.recordId, 'vehicleId' : this.vehicleId });this.vehiclePurchaseprice = parseInt(getResponse, 10);
            }
    }
    calculateNumberOfInstallments(moratoriumDays, tenureValue){ // INDI-4652
        let moratorium = (moratoriumDays == null || moratoriumDays == undefined || moratoriumDays == '') ? 0 : moratoriumDays;
        let tenure = (tenureValue == null || tenureValue == undefined || tenureValue == '') ? 1 : tenureValue;
        this.numberOfInstallmentValue = parseInt(moratorium) == 0 ? tenure : parseInt(moratorium) == 30 ? (parseInt(tenure) - 1) : '';
        if(this.leadSource=='OLA'){this.numberOfInstallmentValue = parseInt(tenure)};//OLA-139
    }
   @api disableEverything(){
        let allElements = this.template.querySelectorAll('*');
        allElements.forEach(element =>
         element.disabled = true
           );
           this.disabledRequiredCrmIrr = true;

      }
    handleSliderRanges() {
        if (this.tenureFinal < this.minTenure || this.tenureFinal > this.maxTenure) {
            this.tenureSliderDisabled = true;
        }
        else if(this.isTractor == false){
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
        getOfferScreenData({ loanApplicationId: this.recordId })
            .then(response => {
                let result = JSON.parse(response);this.loanAmount = result.loanAmount;this.tenure = result.tenure;this.maxTenure = result.tenure;this.crmIRR = result.roi;this.requiredCRMIRR = result.roi;this.minTenure = 0;
                //this.minLoanAmount = '';
                this.maxLoanAmount = result.loanAmount;
                this.emi = null;
                this.loanSliderDisabled = true;
                this.tenureSliderDisabled = true;
                if (!this.flagtoUpdate) {
                    const FinalTermFields = {};
                    FinalTermFields[final_ID_FIELD.fieldApiName] = this.isRecordId;FinalTermFields[EMI_Amount.fieldApiName] = null;
                    
                    FinalTermFields[Tenure.fieldApiName] = result.tenure.toString();FinalTermFields[Loan_Amount.fieldApiName] = result.loanAmount.toString();FinalTermFields[CRM_IRR.fieldApiName] = result.roi;FinalTermFields[Required_CRM_IRR.fieldApiName] = result.roi.toString();
                    //CISP-124
                    if(this.provisionAmount){
                        FinalTermFields[Provisional_Channel_Cost.fieldApiName] = this.provisionAmount.toString();
                     }
                     //CISP-124
                    this.updateRecordDetails(FinalTermFields);
                }
            })
            .catch(error => { console.log('Error in getOfferScreenData ', error); });
    }
    toastMsg(message) {
        const evt = new ShowToastEvent({
            title: "Error",
            message: message,
            variant: 'error',
        }); this.dispatchEvent(evt);
    }
    handleTenureChangeValidation(event) {
        this.tenure = event.target.value;
        if (this.isProductTypePV===false) {//Start CISP-2646            
            if (this.tenureFinal !== event.target.value) {
                this.flagTenureChange = true;
            }
            else {
                this.flagTenureChange = false;
            }
        }//End CISP-2646
        this.calculateNumberOfInstallments(this.monitoriumDaysValue, this.tenure);
        //CISP-124
        this.calculateProvisionAmt(this.loanAmount, this.tenure);
    }
    handleSDTenureChange(event) {
        this.tenure = event.target.value;
        if (this.isProductTypePV===false) {//Start CISP-2646            
            if (this.tenureFinal !== event.target.value) {
                this.flagTenureChange = true;
            }
            else {
                this.flagTenureChange = false;
            }
        }//End CISP-2646
        this.calculateNumberOfInstallments(this.monitoriumDaysValue, this.tenure);
        //CISP-124
        this.calculateProvisionAmt(this.loanAmount, this.tenure);
        this.handleTenureChange(event);
    }
    async handleTenureChange(event) {
        this.tenure = event.target.value;
        const tn = event.target.value;
        if(this.leadSource == 'D2C' && this.isProductTypePV){
            console.log('D2C PV Used or Refinance> '+this.tenure)
            if((this.vehicleType == 'Used' ||  this.vehicleType == 'Refinance') && this.tenure > 60){
                const event = new ShowToastEvent({
                    title: 'Warning',
                    message: 'Tenure cannot be more than 60 for D2C',
                    variant: 'Warning',
                });
                this.dispatchEvent(event);
                return;
            }else if(this.vehicleType == 'New' && this.tenure > 96){ //CISP-19205 Change of tenure value
                const event = new ShowToastEvent({
                    title: 'Warning',
                    message: 'Tenure cannot be more than 96 for D2C',
                    variant: 'Warning',
                });
                this.dispatchEvent(event);
                this.tenure = '';
                return;
            }else if(this.tenure < this.minTenure){
                const event = new ShowToastEvent({
                    title: 'Warning',
                    message: 'Loan Tenure cannot be less than '+this.minTenure+' for D2C.',
                    variant: 'Warning',
                });
                this.tenure = '';
                this.dispatchEvent(event);
                return;
            }else if(Number(this.tenure)%6 != 0){
                this.tenure = '';
                const event = new ShowToastEvent({
                title: 'Warning',
                message: 'You have entered an incorrect value. Please enter value multiple of 6 for D2C',
                variant: 'Warning',
            });
            this.tenure = '';
            this.dispatchEvent(event);
            return;
            }
        }
        /* CISP-7438 End */
        console.log('Running ahead')
        if (this.tenureFinal !== event.target.value) {
            this.flagTenureChange = true;
            this.flagRequiredCrrIrrOnlyChanged = false;
        }
        else {  this.flagTenureChange = false;}
        this.tenure = event.target.value;
        let elem = this.template.querySelector('lightning-input[data-id=tenure]');
        elem.setCustomValidity("");
        if(this.productType.toLowerCase() === 'Two Wheeler'.toLowerCase() && Number(this.tenure)%6 != 0 && this.leadSource !== 'D2C'){
            this.tenure = '';
            const event = new ShowToastEvent({
                title: 'Warning',
                message: 'You have entered an incorrect value. Please enter value multiple of 6',
                variant: 'Warning',
            });
            this.dispatchEvent(event);
         }
        else if (this.vechSubCategory.toLowerCase() !== 'UIM'.toLowerCase() && (this.vehicleType.toLowerCase() === 'Used'.toLowerCase() || this.vehicleType.toLowerCase() === Refinance.toLowerCase())) {
            if (this.productType.toLowerCase() === 'Passenger Vehicles'.toLowerCase()) {
                let tenureval=this.tenure;
                let totalValue = parseInt(tenureval, 10) + parseInt(this.vehicleAge, 10);
                if (totalValue > 180) // total value is converted into years // CISP-4102 - Previous value -> 144, New value -> 180
                {
                    this.flagTenureChange = false;
                    elem.setCustomValidity('Tenure Value + Age of Vehicle should be less than 15 years');
                }
                if ((Number(this.tenure) > 60 || Number(this.tenure) < 12)) {
                    this.tenure = '';
                    this.flagTenureChange = false;
                    const event = new ShowToastEvent({
                        title: 'Warning',
                        message: 'Tenure Value is out of bounds.Please enter value between 12 and 60',
                        variant: 'Warning',
                    });
                    this.dispatchEvent(event);
                }
                elem.reportValidity();
                if (this.flagLoanAmountChange == true && this.flagTenureChange == true) {
                    let ev = new CustomEvent('parentmethod');this.disableReRunButton = false;
                    this.dispatchEvent(ev);
                    const event = new ShowToastEvent({
                        title: 'Warning',
                        message: rerunontenure,
                        variant: 'warning',
                    });
                    this.dispatchEvent(event);
                }
                else if (this.flagTenureChange == true) {
                    let ev = new CustomEvent('parentmethod');this.disableReRunButton = false;
                    this.dispatchEvent(ev);
                    const eve = new ShowToastEvent({
                        title: 'Warning',
                        message: rerunontenure,
                        variant: 'Warning',
                    });
                    this.dispatchEvent(eve);
                }
            }
            if (this.productType.toLowerCase() === 'Two Wheeler'.toLowerCase()) {
                let tenureval=this.tenure;
                let totalValue = parseInt(tenureval, 10) + this.vehicleAge;
                if (totalValue > 60 && this.leadSource !== 'D2C')
                {
                    this.flagTenureChange = false;
                    elem.setCustomValidity('Tenure Value + Age of Vehicle should be less than 5 years ');
                }
                if (this.vehicleType.toLowerCase() === Refinance.toLowerCase() && (Number(this.tenure) > 48 || Number(this.tenure) < 12) && this.leadSource !== 'D2C') {
                    this.tenure = '';
                    this.flagTenureChange = false;
                    const event = new ShowToastEvent({
                        title: 'Warning',
                        message: 'Tenure Value is out of bounds.Please enter value between 12 and 48',
                        variant: 'Warning',
                    });
                    this.dispatchEvent(event);
                }
                if (this.vehicleType.toLowerCase() === 'Used'.toLowerCase() && (Number(this.tenure) > 36 || Number(this.tenure) < 6) && this.leadSource !== 'D2C') {
                    this.tenure = '';
                    this.flagTenureChange = false;
                    const event = new ShowToastEvent({
                        title: 'Warning',
                        message: 'Tenure Value is out of bounds.Please enter value between 6 and 36',
                        variant: 'Warning',
                    });
                    this.dispatchEvent(event);
                }
                if(this.leadSource === 'D2C' && (Number(this.tenure) < this.minTenure)){
                    this.tenure = '';
                    this.flagTenureChange = false;
                    const event = new ShowToastEvent({
                        title: 'Warning',
                        message: `Tenure cannot be lesser than ${this.minTenure} for TW`,
                        variant: 'Warning',
                    });
                    this.dispatchEvent(event);
                }
                if(this.leadSource === 'D2C' && (Number(this.tenure) > this.maxTenure)){
                    this.tenure = '';
                    this.flagTenureChange = false;
                    const event = new ShowToastEvent({
                        title: 'Warning',
                        message: `Tenure cannot be more than ${this.maxTenure} for TW`,
                        variant: 'Warning',
                    });
                    this.dispatchEvent(event);
                }
                elem.reportValidity();
                if (this.flagLoanAmountChange == true && this.flagTenureChange == true) {
                    let ev = new CustomEvent('parentmethod');this.disableReRunButton = false;
                    this.dispatchEvent(ev);
                    const event = new ShowToastEvent({
                        title: 'Warning',
                        message: rerunontenure,
                        variant: 'warning',
                    });
                    this.dispatchEvent(event);
                }
                else if (this.flagTenureChange == true) {
                    let ev = new CustomEvent('parentmethod');this.disableReRunButton = false;
                    this.dispatchEvent(ev);
                    const eve = new ShowToastEvent({
                        title: 'Warning',
                        message: rerunontenure,
                        variant: 'Warning',
                    });
                    this.dispatchEvent(eve);
                }
            }

        }
        else if (this.vechSubCategory.toLowerCase() === 'UIM'.toLowerCase() && (this.vehicleType.toLowerCase() === 'Used'.toLowerCase() || this.vehicleType.toLowerCase() === Refinance.toLowerCase())) {
            if ((this.leadSource !== 'D2C' &&this.productType.toLowerCase()) === 'Two Wheeler'.toLowerCase() || this.productType.toLowerCase() === 'Passenger Vehicles'.toLowerCase()) {
                if (event.target.value > this.EligibleTenure) {
                    this.flagTenureChange = false;
                    elem.setCustomValidity('Tenure Value should be less than eligible tenure');
                }
                elem.reportValidity();
            }
            if (this.productType.toLowerCase() === 'Passenger Vehicles'.toLowerCase()) {
                if ((Number(this.tenure) > 60 || Number(this.tenure) < 12)) {
                    this.tenure = '';
                    this.flagTenureChange = false;
                    const event = new ShowToastEvent({
                        title: 'Warning',
                        message: 'Tenure Value is out of bounds.Please enter value between 12 and 60',
                        variant: 'Warning',
                    });
                    this.dispatchEvent(event);
                }
                elem.reportValidity();
            }
            if (this.productType.toLowerCase() === 'Two Wheeler'.toLowerCase() && this.leadSource !== 'D2C') {
                if (this.vehicleType.toLowerCase() === 'Used'.toLowerCase() && (Number(this.tenure) > 36 || Number(this.tenure) < 6)) {
                    this.tenure = '';
                    this.flagTenureChange = false;
                    const event = new ShowToastEvent({
                        title: 'Warning',
                        message: 'Tenure Value is out of bounds.Please enter value between 6 and 36',
                        variant: 'Warning',
                    });
                    this.dispatchEvent(event);
                }
                elem.reportValidity();

            }
            if(this.leadSource === 'D2C' && (Number(this.tenure) < this.minTenure)){
                this.tenure = '';
                this.flagTenureChange = false;
                const event = new ShowToastEvent({
                    title: 'Warning',
                    message: `Tenure cannot be lesser than ${this.minTenure} for TW`,
                    variant: 'Warning',
                });
                this.dispatchEvent(event);
            }
            if(this.leadSource === 'D2C' && (Number(this.tenure) > this.maxTenure)){
                this.tenure = '';
                this.flagTenureChange = false;
                const event = new ShowToastEvent({
                    title: 'Warning',
                    message: `Tenure cannot be more than ${this.maxTenure} for TW`,
                    variant: 'Warning',
                });
                this.dispatchEvent(event);
            }
            if (this.flagLoanAmountChange == true && this.flagTenureChange == true) {
                let ev = new CustomEvent('parentmethod');this.disableReRunButton = false;
                this.dispatchEvent(ev);
                const event = new ShowToastEvent({
                    title: 'Warning',
                    message: rerunontenure,
                    variant: 'warning',
                });
                this.dispatchEvent(event);
            }
            else if (this.flagTenureChange == true) {
                let ev = new CustomEvent('parentmethod');this.disableReRunButton = false;
                this.dispatchEvent(ev);
                const eve = new ShowToastEvent({
                    title: 'Warning',
                    message: rerunontenure,
                    variant: 'Warning',
                });
                this.dispatchEvent(eve);
            }
            await helper.getTractorCheckHelper(this);
        }
        else if (this.vechSubCategory.toLowerCase() !== 'UIM'.toLowerCase() && (this.vehicleType.toLowerCase() === 'New'.toLowerCase())) {
            if (this.productType.toLowerCase() === 'Passenger Vehicles'.toLowerCase()) {
                if (Number(this.tenure) > 96 || Number(this.tenure) < 12) {
                    this.tenure = '';
                    this.flagTenureChange = false;
                    const event = new ShowToastEvent({
                        title: 'Warning',
                        message: 'Tenure Value is out of bounds.Please enter value between 12 and 96',
                        variant: 'Warning',
                    });
                    this.dispatchEvent(event);
                }
                elem.reportValidity();
            }
            if (this.productType.toLowerCase() === 'Two Wheeler'.toLowerCase() && this.leadSource !== 'D2C') {

                if ((Number(this.tenure) > 36 || Number(this.tenure) < 6) && this.loanAmount < 90000) {//CISP-20773
                    console.log('here', this.productType.toLowerCase());
                    this.tenure = '';
                    this.flagTenureChange = false;
                    const event = new ShowToastEvent({
                        title: 'Warning',
                        message: 'Loan amount is lessthan INR 90,000 hence please enter tenure between 6 to 36 only',
                        variant: 'Warning',
                    });
                    this.dispatchEvent(event);
                }
                elem.reportValidity();
            }
            if(this.leadSource === 'D2C' && (Number(this.tenure) < this.minTenure) && this.productType.toLowerCase() === 'Two Wheeler'.toLowerCase()){ // Addition of TW check, raised bug as part of CISP-19205
                this.tenure = '';
                this.flagTenureChange = false;
                const event = new ShowToastEvent({
                    title: 'Warning',
                    message: `Tenure cannot be lesser than ${this.minTenure} for TW`,
                    variant: 'Warning',
                });
                this.dispatchEvent(event);
            }
            if(this.leadSource === 'D2C' && (Number(this.tenure) > this.maxTenure) && this.productType.toLowerCase() === 'Two Wheeler'.toLowerCase()){ // Addition of TW check, raised bug as part of CISP-19205
                this.tenure = '';
                this.flagTenureChange = false;
                const event = new ShowToastEvent({
                    title: 'Warning',
                    message: `Tenure cannot be more than ${this.maxTenure} for TW`,
                    variant: 'Warning',
                });
                this.dispatchEvent(event);
            }
            await helper.uimUsedTractorCheckHelper(this);
            if (this.flagLoanAmountChange == true && this.flagTenureChange == true) {
                let ev = new CustomEvent('parentmethod');this.disableReRunButton = false;
                this.dispatchEvent(ev);
                const event = new ShowToastEvent({
                    title: 'Warning',
                    message: rerunontenure,
                    variant: 'warning',
                });
                this.dispatchEvent(event);
            }
            else if (this.flagTenureChange == true) {
                let ev = new CustomEvent('parentmethod');this.disableReRunButton = false;
                this.dispatchEvent(ev);
                const eve = new ShowToastEvent({
                    title: 'Warning',
                    message: rerunontenure,
                    variant: 'Warning',
                });
                this.dispatchEvent(eve);
            }
        }
        else if (this.vechSubCategory.toLowerCase() === 'UIM'.toLowerCase() && (this.vehicleType.toLowerCase() === 'NEW'.toLowerCase())) {
            if ((this.leadSource !== 'D2C' &&this.productType.toLowerCase()) === 'Two Wheeler'.toLowerCase() || this.productType.toLowerCase() === 'Passenger Vehicles'.toLowerCase()) {
                if (this.productType.toLowerCase() === 'Passenger Vehicles'.toLowerCase()) {
                    if (Number(this.tenure) > 96 || Number(this.tenure) < 12) {
                        this.tenure = '';
                        this.flagTenureChange = false;
                        const event = new ShowToastEvent({
                            title: 'Warning',
                            message: 'Tenure Value is out of bounds.Please enter value between 12 and 96',
                            variant: 'Warning',
                        });
                        this.dispatchEvent(event);
                    }
                    elem.reportValidity();
                }
                if (this.leadSource !== 'D2C' && this.productType.toLowerCase() === 'Two Wheeler'.toLowerCase()) {
                    if ((Number(this.tenure) > 36 || Number(this.tenure) < 6) & this.loanAmount > 90000) {//CISP-20773
                        this.tenure = '';
                        this.flagTenureChange = false;
                        const event = new ShowToastEvent({
                            title: 'Warning',
                            message: 'Tenure Value is out of bounds.Please enter value between 6 and 48',
                            variant: 'Warning',
                        });
                        this.dispatchEvent(event);
                    }
                    elem.reportValidity();
                }
                await helper.notUimNewTractor(this);
                if(this.leadSource === 'D2C' && (Number(this.tenure) < this.minTenure) && this.productType.toLowerCase() === 'Two Wheeler'.toLowerCase()){ // Addition of TW check, raised bug as part of CISP-19205
                    this.tenure = '';
                    this.flagTenureChange = false;
                    const event = new ShowToastEvent({
                        title: 'Warning',
                        message: `Tenure cannot be lesser than ${this.minTenure} for TW`,
                        variant: 'Warning',
                    });
                    this.dispatchEvent(event);
                }
                if(this.leadSource === 'D2C' && (Number(this.tenure) > this.maxTenure) && this.productType.toLowerCase() === 'Two Wheeler'.toLowerCase()){ // Addition of TW check, raised bug as part of CISP-19205
                    this.tenure = '';
                    this.flagTenureChange = false;
                    const event = new ShowToastEvent({
                        title: 'Warning',
                        message: `Tenure cannot be more than ${this.maxTenure} for TW`,
                        variant: 'Warning',
                    });
                    this.dispatchEvent(event);
                }
            }
            if (this.flagLoanAmountChange == true && this.flagTenureChange == true) {
                let ev = new CustomEvent('parentmethod');this.disableReRunButton = false;
                this.dispatchEvent(ev);
                const event = new ShowToastEvent({
                    title: 'Warning',
                    message: rerunontenure,
                    variant: 'warning',
                });
                this.dispatchEvent(event);
            }
            else if (this.flagTenureChange == true) {
                let ev = new CustomEvent('parentmethod');this.disableReRunButton = false;
                this.dispatchEvent(ev);
                const eve = new ShowToastEvent({
                    title: 'Warning',
                    message: rerunontenure,
                    variant: 'Warning',
                });
                this.dispatchEvent(eve);
            }
        }
        else if (this.leadSource !== 'D2C' && this.productType.toLowerCase() === 'Two Wheeler'.toLowerCase() && this.vehicleType.toLowerCase() === 'New'.toLowerCase() && (Number(this.tenure) > 36 || Number(this.tenure) < 6) && this.loanAmount < 90000) { 
            this.tenure = '';
            const event = new ShowToastEvent({
                title: 'Warning',
                message: 'Loan amount is lessthan INR 90,000 hence please enter tenure between 6 to 36 only',
                variant: 'Warning',
            });
            this.dispatchEvent(event);
        }else if(this.leadSource === 'D2C' && this.productType.toLowerCase() === 'Two Wheeler'.toLowerCase() && this.vehicleType.toLowerCase() === 'New'.toLowerCase() && (Number(this.tenure) > 36 || Number(this.tenure) < 6)){
            if(this.leadSource === 'D2C' && (Number(this.tenure) < this.minTenure)){
                this.tenure = '';
                this.flagTenureChange = false;
                const event = new ShowToastEvent({
                    title: 'Warning',
                    message: `Tenure cannot be lesser than ${this.minTenure} for TW`,
                    variant: 'Warning',
                });
                this.dispatchEvent(event);
            }
            if(this.leadSource === 'D2C' && (Number(this.tenure) > this.maxTenure)){
                this.tenure = '';
                this.flagTenureChange = false;
                const event = new ShowToastEvent({
                    title: 'Warning',
                    message: `Tenure cannot be more than ${this.maxTenure} for TW`,
                    variant: 'Warning',
                });
                this.dispatchEvent(event);
            }
        }
        else {
            if (this.flagLoanAmountChange == true && this.flagTenureChange == true) {
                let ev = new CustomEvent('parentmethod');this.disableReRunButton = false;
                this.dispatchEvent(ev);
                const event = new ShowToastEvent({
                    title: 'Warning',
                    message: rerunontenure,
                    variant: 'warning',
                });
                this.dispatchEvent(event);
            }
            else if (this.flagTenureChange == true) {
                let ev = new CustomEvent('parentmethod');this.disableReRunButton = false;
                this.dispatchEvent(ev);
                const eve = new ShowToastEvent({
                    title: 'Warning',
                    message: rerunontenure,
                    variant: 'Warning',
                });
                this.dispatchEvent(eve);
            }
        }

        if (tn < this.minTenure || tn > this.maxTenure) {
            this.tenureSliderDisabled = true;
        }
        else if(this.isTractor == false){
            this.tenureSliderDisabled = false;
        }
    }
    async handleLoanSliderAmount(event) {
        /* CISP-7438 START*/
        this.loanAmount = event.target.value;
        if(this.leadSource == 'D2C' && this.isProductTypePV){
            if(this.loanAmount > this.maxLoanAmount){
                const event = new ShowToastEvent({
                    title: 'Warning',
                    message: 'Loan amount cannot be more than ' +this.maxLoanAmount+ ' for D2C',
                    variant: 'warning',
                });
                this.dispatchEvent(event);
                this.loanAmount = '';
                return;
            }else if(this.loanAmount < 75000){
                console.log('this.loanAmount > 75000)')
                const event = new ShowToastEvent({
                    title: 'Warning',
                    message: 'Loan Amount cannot be less than 75000 for D2C',
                    variant: 'warning',
                });
                this.dispatchEvent(event);
                this.loanAmount = '';
                return;
            }
            this.loanSliderDisabled = false;
            
        } 
        /* CISP-7438 END*/
        let elem = this.template.querySelector('lightning-input[data-id=LoanAmt]');
        elem.setCustomValidity("");
        this.loanAmount = event.target.value;
        if (this.vechSubCategory.toLowerCase() === 'UIM'.toLowerCase() && (this.productType.toLowerCase() === 'Passenger Vehicles'.toLowerCase() || this.productType.toLowerCase() === 'Two Wheeler'.toLowerCase())) {
            if (event.target.value > this.EligibleLoanAmt) {
                elem.setCustomValidity('Loan Amount value should be less than or equal to Eligibility Amount');
            }
            elem.reportValidity();
        }
        if (this.productType.toLowerCase() === 'Passenger Vehicles'.toLowerCase()) {
            if (event.target.value > 200000000 || event.target.value < 50000) {
                const event = new ShowToastEvent({
                    title: 'Warning',
                    message: 'Loan amount is out of bounds. Please enter value between 50k to 20cr',
                    variant: 'Warning',
                });
                this.dispatchEvent(event);
                this.loanAmount = '';
            }// Start CISP-2522
            if (this.vehicleType.toLowerCase() === 'New'.toLowerCase() && this.oppRecord.Funding_on_Ex_Showroom__c == true && this.oppRecord.Ex_showroom_price__c!=null && ((parseFloat(event.target.value)) > parseFloat(this.oppRecord.Ex_showroom_price__c))) {//CISP-2347
                const event = new ShowToastEvent({
                    title: 'Warning',
                    message: 'Loan amount is out of bounds. Please enter value less than Ex Showroom Price '+this.oppRecord.Ex_showroom_price__c,
                    variant: 'Warning',
                 });
                 this.dispatchEvent(event);
                 this.loanAmount = '';
            }else if (this.vehicleType.toLowerCase() === 'New'.toLowerCase() && this.oppRecord.Funding_on_ORP__c == true && this.orp!=null && ((parseFloat(event.target.value)) > parseFloat(this.orp))) {//CISP-2347
                const event = new ShowToastEvent({
                    title: 'Warning',
                    message: 'Loan amount is out of bounds. Please enter value less than On Road Price '+this.orp,
                    variant: 'Warning',
                 });
                 this.dispatchEvent(event);
                 this.loanAmount = '';
            }else if ((this.vehicleType.toLowerCase() === 'Refinance'.toLowerCase() || this.vehicleType.toLowerCase() === 'Used'.toLowerCase()) && this.vehRecord.Base_Prices__c!=null && ((parseFloat(event.target.value) + parseFloat(this.totalFundedPremium)) > parseFloat(this.vehRecord.Base_Prices__c))) {//CISP-2347
                const event = new ShowToastEvent({
                    title: 'Warning',
                    message: 'Loan amount is out of bounds. Please enter value less than Base Price '+this.vehRecord.Base_Prices__c,
                    variant: 'Warning',
                 });
                 this.dispatchEvent(event);
                 this.loanAmount = '';
            }//End CISP-2522
        }

        if (this.leadSource !== 'D2C' && this.productType.toLowerCase() === 'Two Wheeler'.toLowerCase()) {
            if(this.productSegment != null && this.productSegment != '' && this.productSegment === 'ESCOOTER'){
                if (event.target.value > 150000 || event.target.value < 25000) {//CISP-13665
                    const event = new ShowToastEvent({
                        title: 'Warning',
                        message: 'Loan amount is out of bounds. Please enter value between 25k to 1.5L',
                        variant: 'Warning',
                    });
                    this.dispatchEvent(event);
                    this.loanAmount = '';
                }
            }else{
            if (event.target.value > 160000 || event.target.value < 20000) {//CISP-4023
                const event = new ShowToastEvent({
                    title: 'Warning',
                    message: 'Loan amount is out of bounds. Please enter value between 20k to 1.6L',
                    variant: 'Warning',
                });
                this.dispatchEvent(event);
                this.loanAmount = '';
            }
            }
            if(this.orp!=null && ((parseFloat(event.target.value) + parseFloat(this.totalFundedPremium)) > parseFloat(this.orp)))//Start CISP-2459 //CISP-2702
            {
                const event = new ShowToastEvent({
                    title: 'Warning',
                    message: 'Loan amount is out of bounds. Please enter value less than On Road Price '+this.orp,
                    variant: 'Warning',
                });
                this.dispatchEvent(event);
                this.loanAmount = '';
            }//End CISP-2459
        }
        if (this.leadSource === 'D2C' && this.productType.toLowerCase() === 'Two Wheeler'.toLowerCase()) {
            if (event.target.value < this.minLoanAmount) {
                const event = new ShowToastEvent({
                    title: 'Warning',
                    message: `Loan amount cannot be less than ${this.minLoanAmount} for TW`,
                    variant: 'Warning',
                });
                this.dispatchEvent(event);
                this.loanAmount = '';
                let ev = new CustomEvent('parentmhd');
                this.dispatchEvent(ev);
                this.disableReRunButton = true;
                return;
            }
        
            if(event.target.value > this.maxLoanAmount)
            {
                const event = new ShowToastEvent({
                    title: 'Warning',
                    message: `Loan amount cannot be more than ${this.maxLoanAmount} for TW`,
                    variant: 'Warning',
                });
                this.dispatchEvent(event);this.loanAmount = '';let ev = new CustomEvent('parentmhd');this.dispatchEvent(ev);this.disableReRunButton = true;return;
            }
        }
        if (parseFloat(this.loanAmountFinal) !== parseFloat(event.target.value)) {//CISP-2646
            this.flagLoanAmountChange = true;
            this.flagRequiredCrrIrrOnlyChanged = false;
            const event = new ShowToastEvent({
                title: 'Warning',
                message: rerunonloan,
                variant: 'warning',
            });
            this.dispatchEvent(event);
            let ev = new CustomEvent('parentmethod');this.disableReRunButton = false;//CISP-2646
            this.dispatchEvent(ev);//CISP-2646
            //this.isChangePayInOutButtonDisable = true;
        }
        else {
            this.flagLoanAmountChange = false;
            console.log('this.flagLoanAmountChange = ', this.flagLoanAmountChange);
        }
        if (parseInt(this.loanAmount,10) < this.minLoanAmount || parseInt(this.loanAmount,10)  > this.maxLoanAmount) {
            this.loanSliderDisabled = true;
        }
        else {
            this.loanSliderDisabled = false;
        }
        if(event.target.value > this.maxLoanAmount){
            this.notgreaterthanmax=false;
        }
        if(this.productType.toLowerCase() === 'Tractor'.toLowerCase()){
            let getResponse = await getPurchaseprice({ loanApplicationId: this.recordId, 'vehicleId' : this.vehicleId });
            this.vehiclePurchaseprice = parseInt(getResponse, 10);
            helper.enteredLoanAmountCheck(this);
        } 
    }
    handleSDLoanSliderAmountChange(event) {
        this.loanAmount = event.target.value;
        if (!this.isProductTypePV) {//Start CISP-2646
            if (parseFloat(this.loanAmountFinal) !== parseFloat(event.target.value) && this.leadSource != 'D2C') {
                this.flagLoanAmountChange = true;
            }
            else if(this.leadSource != 'D2C'){
                this.flagLoanAmountChange = false;
            } 
        }//End CISP-2646
        //CISP-124
        this.calculateProvisionAmt(this.loanAmount, this.tenure);
        this.handleLoanSliderAmount(event);
    }
    handleLoanSliderAmountChange(event) {
        this.loanAmount = event.target.value;
        if (this.isProductTypePV===false) {//Start CISP-2646
            if (parseFloat(this.loanAmountFinal) !== parseFloat(event.target.value) && this.leadSource != 'D2C') {
                this.flagLoanAmountChange = true;
            }
            else if(this.leadSource != 'D2C'){
                this.flagLoanAmountChange = false;
            } 
        }//End CISP-2646
        //CISP-124
        this.calculateProvisionAmt(this.loanAmount, this.tenure);
        let ev = new CustomEvent('parentmethodaccept');
        this.dispatchEvent(ev);
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
            const event = new ShowToastEvent({
                title: 'Warning',
                message: rerunAdvanceChanged,
                variant: 'warning',
            });
            this.dispatchEvent(event);
        }
        else if (this.flagAdvanceEmiChange) {
            const event = new ShowToastEvent({
                title: 'Error',
                message: rerunCheckEligibility,
                variant: 'Error',
            });
            this.dispatchEvent(event);
        }
        if (this.advanceEMi == true) {
            let ev = new CustomEvent('parentmethod');this.disableReRunButton = false;
            this.dispatchEvent(ev);
            let elem = this.template.querySelector('.monDay');
            elem.setCustomValidity("");elem.reportValidity();this.monitoriumDaysDisabled = true;this.monitoriumDaysValue = 0;
        }
        else {
            let ev = new CustomEvent('parentmhd');this.dispatchEvent(ev);this.disableReRunButton = true;let elem = this.template.querySelector('.monDay');elem.setCustomValidity("");elem.setCustomValidity('Enter MonitoriumDays Value');elem.reportValidity();this.monitoriumDaysDisabled = false;
        }
    }
    @api async callcreateFinalTermRecord() {
        if(this.isTractor){let valid = await helper.validateRquiredCRMIRR(this);if(!valid){return;}}
        console.log('check inside');
        if(helper.validateLoanAmount(this)){return;}
        this.isLoading = true;
        if(!this.tenure && this.leadSource === 'D2C'){
            const event = new ShowToastEvent({
                title: 'Warning',
                message: 'Tenure is mandatory. Please enter valid tenure value.',
                variant: 'warning',
            });
            this.dispatchEvent(event);
            this.isLoading = false;
            return;
        }
        createFinalTermRecord({ loanApplicationId: this.recordId , vehicleId : this.vehicleId})
            .then(responses => {
                const obj = JSON.parse(responses);
                console.log('obj.finalTermId  ', obj.finalTermId);
                this.finalTermId = obj.finalTermId;
                this.submitclick = false;
                if (this.isProductTypePV===false) {//Start CISP-2646            
                    this.eligiblityButtonClicked=true;
                }
                if(this.isD2C){
                    if(!this.emidate){
                        const event = new ShowToastEvent({
                            title: 'Warning',
                            message: 'Select 1st EMI due date',
                            variant: 'warning'
                        });
                        this.dispatchEvent(event);
                        return;
                    }else{helper.saveEMIdueDates(this);}}
                if(this.productType == 'Tractor'){
                    this.handleTFOfferEngineCalloutHelper();
                }else{
                    this.calldoOfferEngineCallout();
                } 
            })
            .catch(error => {
                const event = new ShowToastEvent({
                    title: 'Error',
                    variant: 'error',
                  //  message: error.body.message,
                });
                this.dispatchEvent(event);
                this.isLoading = false;
                console.log('error. ', error);
            });
    }
    handleMonitoriumDays(event) {
        let ev = new CustomEvent('parentmethod');this.disableReRunButton = false;
        this.dispatchEvent(ev);
        let elem = this.template.querySelector('.monDay');
        elem.setCustomValidity("");
        elem.reportValidity();
        if (parseFloat(this.monitoriumDaysValueFinal) !== parseFloat(event.target.value)) {//CISP-2646
            this.flagMonitoriumDays = true;
            this.flagRequiredCrrIrrOnlyChanged = false;
        }else{
            this.flagMonitoriumDays = false;//CISP-2646
        }
        if (this.flagLoanAmountChange == true && this.flagMonitoriumDays == true) {
            const event = new ShowToastEvent({
                title: 'Warning',
                message: rerunloanDayChanged,
                variant: 'warning',
            });
            this.dispatchEvent(event);
        }
        else if (this.flagMonitoriumDays == true) {
            this.flagMonitoriumDays = true;
            const event = new ShowToastEvent({
                title: 'ERROR',
                message: rerunMoratorium,
                variant: 'Error',
            });
            this.dispatchEvent(event);
        }
        this.monitoriumDaysValue = event.target.value;
        this.advanceEmiDisabled = true;
        if (this.monitoriumDaysValue === '0') {
            let ev = new CustomEvent('parentmhd');
            this.dispatchEvent(ev);this.disableReRunButton = true;this.advanceEMi = false;this.advanceEmiDisabled = false;
            
        }
        else {
            let elem = this.template.querySelector('lightning-input[data-id=advanceEMIid]');
            this.advanceEMi = false;elem.setCustomValidity("");elem.reportValidity();
        }

        this.calculateNumberOfInstallments(this.monitoriumDaysValue, this.tenure);
    }
    async updateRecordDetails(fields) {
        const recordInput = { fields };
        await updateRecord(recordInput)
            .then(() => {
                this.isSpinnerMoving = false;
                const event = new ShowToastEvent({
                    title: 'Record Updated',
                    variant: 'Success',
                });
                this.dispatchEvent(event);
                console.log('after update', recordInput);
                return true;
            })
            .catch(error => {
                this.isSpinnerMoving = false;
                console.log('Error in update', error);
            });
    }
    handleRequiredCRMIRRChange(event) {
        let requiredRoiInput = this.template.querySelector('lightning-input[data-id=reqRoi]'); //CISP-5450
        let oldRequiredCRMIRR = this.requiredCRMIRR;
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
        else if(!this.isTractor){
            roiMasterForImputedIRR({loanApplicationId : this.recordId,productType : this.productType,tenure : parseInt(this.tenure,10),vehicleCategory : this.vehicleType,queryBased:'CRM_IRR'})
              .then(result => {
                let parsedData = JSON.parse(result);
                 if(parsedData.mincrm != null && parsedData.maxcrm != null){
                     this.mincrm = parsedData.mincrm;
                     this.maxcrm = parsedData.maxcrm;
                        if(this.productType == 'Passenger Vehicles'){ //CISP-5450
                            if (this.requiredCRMIRR < parseFloat(this.mincrm) || this.requiredCRMIRR > parseFloat(this.maxcrm)) {
                                requiredRoiInput.setCustomValidity('CRM IRR is not as per norms Min ' + this.mincrm + ' and Max ' + this.maxcrm);//CISP-5450
                                let ev = new CustomEvent('parentmhdafterirrval');
                                this.dispatchEvent(ev);
                           } 
                            else{
                                requiredRoiInput.setCustomValidity("");
                                if(this.requiredCRMIRR != this.crmIRR){ 
                                       this.flagRequiredCrrIrrChange = true;
                                    if (this.flagRequiredCrrIrrChange && !this.flagLoanAmountChange && !this.flagTenureChange && !this.flagAdvanceEmiChange && !this.flagMonitoriumDays) {
                                        this.flagRequiredCrrIrrOnlyChanged = true;
                                    }
                                    let ev = new CustomEvent('parentmethod');
                                    this.dispatchEvent(ev);
                                }
                            }
                                requiredRoiInput.reportValidity();
                            
                            return null;
                         }
                        if (this.requiredCRMIRR <= this.maxcrm && this.requiredCRMIRR >= this.mincrm && this.requiredCRMIRR <= this.crmIRR) {
                            if (this.requiredCrmIrr !== event.target.value) {
                                this.flagRequiredCrrIrrChange = true;
                            }
                            if (this.flagRequiredCrrIrrChange && !this.flagLoanAmountChange && !this.flagTenureChange && !this.flagAdvanceEmiChange && !this.flagMonitoriumDays) {
                                this.flagRequiredCrrIrrOnlyChanged = true;
                            }
                            if (this.flagLoanAmountChange == true && this.flagRequiredCrrIrrChange == true) {
                                const event = new ShowToastEvent({
                                    title: 'Warning',
                                    message: rerunloanCrm,
                                    variant: 'warning',
                                });
                                this.dispatchEvent(event);
                            }
                            else if (this.flagRequiredCrrIrrChange == true) {
                                const event = new ShowToastEvent({
                                    title: 'Warning',
                                    message: reruncrmChanged,
                                    variant: 'Warning',
                                });
                                this.dispatchEvent(event);
                            }
                            let ev = new CustomEvent('parentmethod');this.disableReRunButton = false;
                            this.dispatchEvent(ev);
                        } else if (this.requiredCRMIRR <= this.maxcrm) {
                            const event = new ShowToastEvent({
                                title: 'Warning',
                                message: crmmaxchange + this.maxcrm,
                                variant: 'Warning',
                            });
                            this.dispatchEvent(event);
                        } else if (this.requiredCRMIRR >= this.mincrm) {
                            this.requiredCRMIRR = this.mincrm;
                            this.template.querySelector('.reqCrmIrr').value = this.mincrm;
                            const event = new ShowToastEvent({
                                title: 'Warning',
                                message: crmminchange + this.mincrm,
                                variant: 'Warning',
                            });
                            this.dispatchEvent(event);
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
                            let ev = new CustomEvent('parentmhd');
                                this.dispatchEvent(ev);this.disableReRunButton = true;
                        }
                    } else {
                        if (this.requiredCRMIRR <= this.crmIRR) {
                            if (this.requiredCrmIrr !== event.target.value) {
                                this.flagRequiredCrrIrrChange = true;
                            }
                            if (this.flagRequiredCrrIrrChange && !this.flagLoanAmountChange && !this.flagTenureChange && !this.flagAdvanceEmiChange && !this.flagMonitoriumDays) {
                                this.flagRequiredCrrIrrOnlyChanged = true;
                            }
                            if (this.flagLoanAmountChange == true && this.flagRequiredCrrIrrChange == true) {
                                const event = new ShowToastEvent({
                                    title: 'Warning',
                                    message: rerunloanCrm,
                                    variant: 'warning',
                                });
                                this.dispatchEvent(event);
                                let ev = new CustomEvent('parentmethod');this.disableReRunButton = false;
                                this.dispatchEvent(ev);
                            }
                            else if (this.flagRequiredCrrIrrChange == true) {
                                const event = new ShowToastEvent({
                                    title: 'Warning',
                                    message: reruncrmChanged,
                                    variant: 'Warning',
                                });
                                this.dispatchEvent(event);
                                let ev = new CustomEvent('parentmethod');this.disableReRunButton = false;
                                this.dispatchEvent(ev);
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
                            let ev = new CustomEvent('parentmhd');
                            this.dispatchEvent(ev);
                            this.disableReRunButton = true;
                        }
                    }
              })
              .catch(error => {
                console.error('Error:', error);
            });
        }else if(this.isTractor){helper.requiredCRMIRRHandler(this,oldRequiredCRMIRR);}
    }
    get requiredCRMIRRValue() {
        return this.requiredCRMIRR;
    }
    handlePopupOk() {
        this.requiredCRMIRRPopup = false;
    }
    navigateToFinalTermPage() {
        this[NavigationMixin.Navigate]({
            type: 'standard__navItemPage',
            attributes: {
                apiName: 'Final_Term'
            }
        });
    }
    //rendered callback
    renderedCallback() {
        if(this.substage || (this.substageTractor == true && this.isTractor)){
            this.disableEverything();
        }
        if(this.isRevokedLoanApplication){this.disableEverything();}
        helper.renderedCallbackHandler(this);
        
        loadStyle(this, LightningCardCSS);
    }
    @api async calldoOfferEngineCalloutoffer(finaltermsid) {// CISP-124 OR CISP-2655
        await this.calculateProvisionAmt(this.loanAmount, this.tenure);// CISP-124 OR CISP-2655
        console.log(finaltermsid);
        this.finalTermId = finaltermsid;
        let offerEngineRequestString = {
            'loanApplicationId': this.recordId,
            'currentScreen': this.flagRequiredCrrIrrOnlyChanged == true ? 'Offer screen changed' : 'Offer',
            'thresholdNetIRR': this.priceingEngineNetIrr,
            'crmIrrChanged': this.requiredCRMIRR,
            'loanAmountChanged': (Number(this.loanAmount) - Number(this.totalFundedPremium)).toString(),
            'tenureChanged': this.tenure,
            'advanceEmiFlag': this.advanceEMi == false ? 'No' : 'Yes',
            'provisionAmount' : this.provisionAmount.toString(),//CISP-124
            'offerEMI': this.emi?this.emi.toString():'', // CISP-2359
        };

        //START D2C Changes Swapnil
        let offerEngineMethod = doOfferEngineCallout;
        let offerEngineParams = { offerEngineRequestString: JSON.stringify(offerEngineRequestString) };
        if(this.leadSource === 'D2C' || this.leadSource === 'Hero'){//CISH-04
            offerEngineMethod = doD2COfferEngineCallout;
            offerEngineParams = {loanId: this.recordId, applicantId: null};
        }
        //END D2C Changes Swapnil

        offerEngineMethod(offerEngineParams)
            .then(result => {
                const obj = (this.leadSource === 'D2C' || this.leadSource === 'Hero')  ? this.getParsedJSOND2C(JSON.parse(result)) : JSON.parse(result);
                //this.retryCount();
                console.log('doOfferEngineCallout result', obj);
                this.isSpinnerMoving = true;
                const FinalTermFields = {};
                FinalTermFields[final_ID_FIELD.fieldApiName] = this.isRecordId;
                FinalTermFields[EMI_Amount.fieldApiName] = obj.EMI != null ? obj.EMI : this.emi;
                FinalTermFields[Tenure.fieldApiName] = obj.Tenure != null ? obj.Tenure.toString() : this.tenure;//D2C Swapnil added toString() as field is text field
                FinalTermFields[Loan_Amount.fieldApiName] = obj.Loan_Amt != null ? (parseFloat(obj.Loan_Amt) - this.totalFundedPremium).toString()  : this.loanAmount;
                if(obj.Loan_Amt == null){FinalTermFields[Loan_Amount.fieldApiName] = (this.loanAmount - this.totalFundedPremium).toString();}
                FinalTermFields[CRM_IRR.fieldApiName] = obj.CRM_IRR != null ? obj.CRM_IRR : this.requiredCRMIRR;
                FinalTermFields[Required_CRM_IRR.fieldApiName] = obj.CRM_IRR != null ? obj.CRM_IRR.toString() : this.requiredCRMIRR;//D2C Swapnil added toString() as field is text field
                if (obj.Max_Tenure_Slider != null) {
                    FinalTermFields[OfferengineMaxTenure.fieldApiName] = obj.Max_Tenure_Slider;
                }
                if (obj.Min_Tenure_Slider != null) {
                    FinalTermFields[OfferengineMinTenure.fieldApiName] = obj.Min_Tenure_Slider;
                }
                if (obj.Min_Loan_Amt_Slider != null) {
                    FinalTermFields[OfferengineMinLoanAmount.fieldApiName] = obj.Min_Loan_Amt_Slider;
                }
                if (obj.Max_Loan_Amt_Slider != null) {
                    FinalTermFields[OfferengineMaxLoanAmount.fieldApiName] = obj.Max_Loan_Amt_Slider;
                }
                if (obj.Imputed_IRR_Offered != null) { FinalTermFields[Inputted_IRR.fieldApiName] = parseFloat(obj.Imputed_IRR_Offered); }
                if (obj.Net_IRR_Offered != null) { FinalTermFields[Net_IRR.fieldApiName] = parseFloat(obj.Net_IRR_Offered); FinalTermFields[Net_IRR_DECIMAL.fieldApiName] = parseFloat(obj.Net_IRR_Offered); }
                if (obj.Gross_IRR_Offered != null) { FinalTermFields[Gross_IRR.fieldApiName] = parseFloat(obj.Gross_IRR_Offered); }
                if(this.leadSource == 'D2C'){
                    if(obj.NetPayIns != null && this.leadSource === 'D2C'){
                        FinalTermFields[Net_Pay_Ins.fieldApiName]=obj.NetPayIns;
                    }
                    if(obj.NetPayOuts != null && this.leadSource === 'D2C'){
                        FinalTermFields[Net_Pay_Outs.fieldApiName]=obj.NetPayOuts;
                    }
                    if(obj.Loan_Amt != null){
                        FinalTermFields[Loan_Amount.fieldApiName] = obj.Loan_Amt.toString();;
                    }else{
                        FinalTermFields[Loan_Amount.fieldApiName] = this.loanAmount.toString();;
                    }   
                }
                if(!this.isTractor){
                    if(obj.loanDealDate){FinalTermFields[Loan_Deal_Date.fieldApiName] = obj.loanDealDate;}
                    if(obj.agreementAmount){FinalTermFields[OE_Agreement_Amount.fieldApiName] = obj.agreementAmount;}
                    helper.saveAmortDetails(this,obj,this.recordId);}
                if (obj.Stop_Journey_Flag === "True" && this.productType.toLowerCase() !== 'Passenger Vehicles'.toLowerCase()) {//CISP-2331
                    FinalTermFields[OfferengineStopJourneyFlag.fieldApiName] = true;
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
                 if(this.leadSource === 'D2C') {
                    FinalTermFields[service_charge.fieldApiName] = obj.service_charge;FinalTermFields[Provisional_Channel_Cost.fieldApiName] = obj.provisionCost;FinalTermFields[Mfr_incentive.fieldApiName] = obj.mfrIncentive;FinalTermFields[Dealer_incentive_amount_main_dealer.fieldApiName] = obj.dealerIncentiveMain;FinalTermFields[doc_charge.fieldApiName] = obj.docCharges;
                }
                if(this.leadSource != 'Hero'){
                    if(obj.TableCode){FinalTermFields[Table_Code.fieldApiName] = obj.TableCode;}
                    if(obj.Interest_VersionNo){FinalTermFields[Interest_Version_No.fieldApiName] = obj.Interest_VersionNo;}
                    if(obj.DR_PenalInterest){FinalTermFields[DR_Penal_Interest.fieldApiName] = obj.DR_PenalInterest;}if(obj.mclrRate){FinalTermFields[mclrRate.fieldApiName] = obj.mclrRate;} 
                }
                 //CISP-124
                this.updateRecordDetails(FinalTermFields);
                //window.location.reload();
                this.loanAmount = obj.Loan_Amt != null ? obj.Loan_Amt : this.loanAmount;this.loanAmountFinal = obj.Loan_Amt != null ? obj.Loan_Amt : this.loanAmount;this.tenure = obj.Tenure != null ? obj.Tenure : this.tenure;this.tenureFinal = obj.Tenure != null ? obj.Tenure : this.tenure;this.crmIRR = obj.CRM_IRR != null ? obj.CRM_IRR : this.crmIRR;this.emi = obj.EMI != null ? obj.EMI : this.emi;this.requiredCRMIRR = obj.CRM_IRR != null ? obj.CRM_IRR : this.requiredCRMIRR;this.maxLoanAmount = obj.Max_Loan_Amt_Slider != null ? obj.Max_Loan_Amt_Slider : this.maxLoanAmount;this.minLoanAmount = obj.Min_Loan_Amt_Slider != null ? obj.Min_Loan_Amt_Slider : this.minLoanAmount;this.maxTenure = obj.Max_Tenure_Slider != null ? obj.Max_Tenure_Slider : this.maxTenure;this.minTenure = obj.Min_Tenure_Slider != null ? obj.Min_Tenure_Slider : this.minTenure;
                //INDI-4652 - START 10-6-2022
                this.calculateNumberOfInstallments(this.monitoriumDaysValue, this.tenure);
                this.netIRRValue = obj.Net_IRR_Offered != null ? obj.Net_IRR_Offered : this.netIRRValue;
                this.grossIRRValue = obj.Gross_IRR_Offered != null ? obj.Gross_IRR_Offered : this.grossIRRValue;
                //INDI-4652 - END 10-6-2022
                let isPanValid = this.getDocumentsToCheckPanValid();
                if(!isPanValid){return null;}
                if (obj.Stop_Journey_Flag === "True" && this.productType.toLowerCase() !== 'Passenger Vehicles'.toLowerCase()) {//CISP-2331
                    this.toastMsg('Journey Stoped');
                    let allElements = this.template.querySelectorAll('*');
                    allElements.forEach(element =>
                        element.disabled = true
                    );
                    this.isSpinnerMoving = false;
                    this.template.querySelector('.cancel').disabled = false;this.journeyStopScenarioFound();
                }
                else{
                    this.showToast('Success','Offer Engine Successful','Success');
                    this.flagLoanAmountChange = false;this.flagTenureChange = false;this.flagAdvanceEmiChange = false;this.flagMonitoriumDays = false;this.flagRequiredCrrIrrChange = false;this.isSpinnerMoving = false;this.disabledLoanAmount = false;this.loanSliderDisabled = false;this.tenureSliderDisabled = false;this.disabledTenure = false;this.disabledRequiredCrmIrr = false;this.advanceEmiDisabled = false;this.monitoriumDaysDisabled = false;this.advanceEmis = this.advanceEMi;this.requiredCrmIrr = this.requiredCRMIRR;this.tenureFinal = this.tenure;this.loanAmountFinal = this.loanAmount;this.monitoriumDaysValueFinal = this.monitoriumDaysValue;this.rerunOEDisable = true;
                    if(obj.CRM_IRR > 90 && this.isTractor){
                        this.showToast('Error','The loan journey will be ended since, it does not meet the IIR requirements, please withdraw the loan Application','error');
                    }
                    if(this.offerengineparent){
                    let ev = new CustomEvent('parentmethodaccepts');
                    this.dispatchEvent(ev);}
                }
            })
            .catch(error => {
                console.log(error);
                this.showToast('Error','Offer Engine Failed','error');
                let ev = new CustomEvent('failedOfferEngine',{detail:true});//CISP-60
                this.dispatchEvent(ev);//CISP-60
                this.isSpinnerMoving = false;
            });
    }
    async calldoOfferEngineCallout() {// CISP-124 OR CISP-2655
        await helper.emiDateCalculation(this);
        await helper.saveEMIdueDates(this);
        await this.calculateProvisionAmt(this.loanAmount, this.tenure);// CISP-124 OR CISP-2655
        console.log('thresholdNetIRR', this.priceingEngineNetIrr);console.log('crmIrrChanged', this.requiredCRMIRR);console.log('loanAmountChanged', this.loanAmount);console.log('tenureChanged', this.tenure);console.log('this.advanceEMi ', this.advanceEMi);
        if(this.notgreaterthanmax){
            let offerEngineRequestString = {
                'loanApplicationId': this.recordId,
                'currentScreen': this.flagRequiredCrrIrrOnlyChanged == true ? 'Offer screen changed' : 'Offer',
                'thresholdNetIRR': this.priceingEngineNetIrr,
                'crmIrrChanged': this.requiredCRMIRR,
                'loanAmountChanged': (Number(this.loanAmount) - Number(this.totalFundedPremium)).toString(),
                'tenureChanged': this.tenure,
                'advanceEmiFlag': this.advanceEMi == false ? 'No' : 'Yes',
                'offerEMI': this.emi?this.emi.toString():'', //CISP-2379
                'provisionAmount' : this.provisionAmount.toString(),//CISP-124
            };
            
            //START D2C Changes Swapnil
            let offerEngineMethod = doOfferEngineCallout;
            let offerEngineParams = { offerEngineRequestString: JSON.stringify(offerEngineRequestString) };
            if(this.leadSource === 'D2C' || this.leadSource === 'Hero'){//CISH-04
                let sliderAmount =Number(this.loanAmount).toString();
                offerEngineMethod = doD2COfferEngineCallout;
                offerEngineParams = {loanId: this.recordId, applicantId: null, fromScreen:'sliderScreen',sliderTenure: this.tenure, sliderLoanAmount:sliderAmount};
            }
            //END D2C Changes Swapnil

            offerEngineMethod(offerEngineParams)
            .then(result => {
                if(!this.emi || this.emi == null){this.disabledLoanAmount = false;this.loanSliderDisabled = false;this.disabledTenure = false;this.tenureSliderDisabled = false;this.disabledRequiredCrmIrr = false;if(!this.monitoriumDaysValue || parseInt(this.monitoriumDaysValue) == 0){this.advanceEmiDisabled = false;}else{this.monitoriumDaysDisabled= false;}if(this.productType.toLowerCase() === 'Two Wheeler'.toLowerCase()){this.disabledEmiAmount= false;}}
                const obj = (this.leadSource === 'D2C' || this.leadSource === 'Hero')  ? this.getParsedJSOND2C(JSON.parse(result)) : JSON.parse(result);
                //this.retryCount();
                console.log('doOfferEngineCallout result', obj);
                this.isSpinnerMoving = true;
                const FinalTermFields = {};
                FinalTermFields[final_ID_FIELD.fieldApiName] = this.isRecordId;
                FinalTermFields[EMI_Amount.fieldApiName] = obj.EMI != null ? obj.EMI : this.emi;
                FinalTermFields[Tenure.fieldApiName] = obj.Tenure != null ? obj.Tenure.toString() : this.tenure;//D2C Swapnil added toString() as field is text field
                FinalTermFields[Loan_Amount.fieldApiName] = obj.Loan_Amt != null ? (parseFloat(obj.Loan_Amt) - this.totalFundedPremium).toString() : this.loanAmount;
                if(obj.Loan_Amt == null){FinalTermFields[Loan_Amount.fieldApiName] = (this.loanAmount - this.totalFundedPremium).toString();}
                FinalTermFields[CRM_IRR.fieldApiName] = obj.CRM_IRR != null ? obj.CRM_IRR : this.requiredCRMIRR;
                FinalTermFields[Required_CRM_IRR.fieldApiName] = obj.CRM_IRR != null ? obj.CRM_IRR.toString() : this.requiredCRMIRR;//D2C Swapnil added toString() as field is text field
                if (obj.Max_Tenure_Slider != null) {
                    FinalTermFields[OfferengineMaxTenure.fieldApiName] = obj.Max_Tenure_Slider;
                }
                if (obj.Min_Tenure_Slider != null) {
                    FinalTermFields[OfferengineMinTenure.fieldApiName] = obj.Min_Tenure_Slider;
                }
                if (obj.Min_Loan_Amt_Slider != null) {
                    FinalTermFields[OfferengineMinLoanAmount.fieldApiName] = obj.Min_Loan_Amt_Slider;
                }
                if (obj.Max_Loan_Amt_Slider != null) {
                    FinalTermFields[OfferengineMaxLoanAmount.fieldApiName] = obj.Max_Loan_Amt_Slider;
                }
                if (obj.Imputed_IRR_Offered != null) { FinalTermFields[Inputted_IRR.fieldApiName] = parseFloat(obj.Imputed_IRR_Offered); }
                if (obj.Net_IRR_Offered != null) { FinalTermFields[Net_IRR.fieldApiName] = parseFloat(obj.Net_IRR_Offered); FinalTermFields[Net_IRR_DECIMAL.fieldApiName] = parseFloat(obj.Net_IRR_Offered); }
                if (obj.Gross_IRR_Offered != null) { FinalTermFields[Gross_IRR.fieldApiName] = parseFloat(obj.Gross_IRR_Offered); }
                if (obj.Stop_Journey_Flag === "True" && this.productType.toLowerCase() !== 'Passenger Vehicles'.toLowerCase()) {//CISP-2331
                    FinalTermFields[OfferengineStopJourneyFlag.fieldApiName] = true;
                }
                FinalTermFields[Advance_EMI.fieldApiName] = this.advanceEMi;
                if (this.monitoriumDaysValue != null) {
                    FinalTermFields[Holiday_period.fieldApiName] = this.monitoriumDaysValue.toString();
                }
                else { FinalTermFields[Holiday_period.fieldApiName] = '0'; }
                if(this.leadSource == 'D2C'){
                    if(obj.NetPayIns != null && this.leadSource === 'D2C'){
                        FinalTermFields[Net_Pay_Ins.fieldApiName]=obj.NetPayIns;
                    }
                    if(obj.NetPayOuts != null && this.leadSource === 'D2C'){
                        FinalTermFields[Net_Pay_Outs.fieldApiName]=obj.NetPayOuts;
                    }
                    if(obj.Loan_Amt != null){
                        FinalTermFields[Loan_Amount.fieldApiName] = obj.Loan_Amt.toString();;
                    }else{
                        FinalTermFields[Loan_Amount.fieldApiName] = this.loanAmount.toString();;
                    } 
                }
                if(!this.isTractor){
                    if(obj.loanDealDate){FinalTermFields[Loan_Deal_Date.fieldApiName] = obj.loanDealDate;}
                    if(obj.agreementAmount){FinalTermFields[OE_Agreement_Amount.fieldApiName] = obj.agreementAmount;}
                    helper.saveAmortDetails(this,obj,this.recordId);}
                if(this.leadSource != 'Hero'){
                    if(obj.TableCode){FinalTermFields[Table_Code.fieldApiName] = obj.TableCode;}
                    if(obj.Interest_VersionNo){FinalTermFields[Interest_Version_No.fieldApiName] = obj.Interest_VersionNo;}
                    if(obj.DR_PenalInterest){FinalTermFields[DR_Penal_Interest.fieldApiName] = obj.DR_PenalInterest;}
                    if(obj.mclrRate){FinalTermFields[mclrRate.fieldApiName] = obj.mclrRate;} 
                }
                //CISP-124
                if(this.provisionAmount){
                    FinalTermFields[Provisional_Channel_Cost.fieldApiName] = this.provisionAmount.toString();
                 }
                 if(this.leadSource === 'D2C') {
                    FinalTermFields[service_charge.fieldApiName] = obj.service_charge;
                    FinalTermFields[Provisional_Channel_Cost.fieldApiName] = obj.provisionCost;
                    FinalTermFields[Mfr_incentive.fieldApiName] = obj.mfrIncentive;
                    FinalTermFields[Dealer_incentive_amount_main_dealer.fieldApiName] = obj.dealerIncentiveMain;
                    FinalTermFields[doc_charge.fieldApiName] = obj.docCharges;
                }
                if(this.leadSource != 'Hero'){
                    if(obj.TableCode){FinalTermFields[Table_Code.fieldApiName] = obj.TableCode;}
                    if(obj.Interest_VersionNo){FinalTermFields[Interest_Version_No.fieldApiName] = obj.Interest_VersionNo;}
                    if(obj.DR_PenalInterest){FinalTermFields[DR_Penal_Interest.fieldApiName] = obj.DR_PenalInterest;}
                    if(obj.mclrRate){FinalTermFields[mclrRate.fieldApiName] = obj.mclrRate;}
                }
                 //CISP-124
                this.updateRecordDetails(FinalTermFields);
                //window.location.reload();
                this.loanAmount = obj.Loan_Amt != null ? obj.Loan_Amt : this.loanAmount;this.loanAmountFinal = obj.Loan_Amt != null ? obj.Loan_Amt : this.loanAmount;this.tenure = obj.Tenure != null ? obj.Tenure : this.tenure;this.tenureFinal = obj.Tenure != null ? obj.Tenure : this.tenure;this.crmIRR = obj.CRM_IRR != null ? obj.CRM_IRR : this.crmIRR;this.emi = obj.EMI != null ? obj.EMI : this.emi;this.requiredCRMIRR = obj.CRM_IRR != null ? obj.CRM_IRR : this.requiredCRMIRR;this.maxLoanAmount = obj.Max_Loan_Amt_Slider != null ? obj.Max_Loan_Amt_Slider : this.maxLoanAmount;this.minLoanAmount = obj.Min_Loan_Amt_Slider != null ? obj.Min_Loan_Amt_Slider : this.minLoanAmount;this.maxTenure = obj.Max_Tenure_Slider != null ? obj.Max_Tenure_Slider : this.maxTenure;this.minTenure = obj.Min_Tenure_Slider != null ? obj.Min_Tenure_Slider : this.minTenure;this.flagRequiredCrrIrrOnlyChanged == false;
                //INDI-4652 - START 10-6-2022
                this.calculateNumberOfInstallments(this.monitoriumDaysValue, this.tenure);
                this.netIRRValue = obj.Net_IRR_Offered != null ? obj.Net_IRR_Offered : this.netIRRValue;
                this.grossIRRValue = obj.Gross_IRR_Offered != null ? obj.Gross_IRR_Offered : this.grossIRRValue;
                //INDI-4652 - END 10-6-2022
                if (obj.Stop_Journey_Flag === "True" && this.productType.toLowerCase() !== 'Passenger Vehicles'.toLowerCase()) {//CISP-2331
                    this.toastMsg('Journey Stoped');
                    let allElements = this.template.querySelectorAll('*');
                    allElements.forEach(element =>
                        element.disabled = true
                    );
                    this.isSpinnerMoving = false;
                    this.template.querySelector('.cancel').disabled = false;this.journeyStopScenarioFound();
                }
                else{
                    this.showToast('Success','Offer Engine Successful','Success');
                    this.flagLoanAmountChange = false;this.flagTenureChange = false;this.flagAdvanceEmiChange = false;this.flagMonitoriumDays = false;this.flagRequiredCrrIrrChange = false;this.isSpinnerMoving = false;this.advanceEmis = this.advanceEMi;this.requiredCrmIrr = this.requiredCRMIRR;this.tenureFinal = this.tenure;this.loanAmountFinal = this.loanAmount;this.monitoriumDaysValueFinal = this.monitoriumDaysValue;this.rerunOEDisable = true;
                    if(obj.CRM_IRR > 90 && this.isTractor){
                        this.showToast('Error','The loan journey will be ended since, it does not meet the IIR requirements, please withdraw the loan Application','error');
                    }
                }
                let ev = new CustomEvent('parentmhd');
                this.dispatchEvent(ev);
                this.disableReRunButton = true;
            })
            .catch(error => {
                this.showToast('Error','Offer Engine Failed','error');
                this.isSpinnerMoving = false;
            });
        }else{
            await this.calculateProvisionAmt(this.loanAmount, this.tenure);// CISP-124 OR CISP-2655
            let offerEngineRequestString = {
                'loanApplicationId': this.recordId,
                'currentScreen': 'Offer screen changed',
                'thresholdNetIRR': this.priceingEngineNetIrr,
                'crmIrrChanged': this.requiredCRMIRR,
                'loanAmountChanged': (Number(this.loanAmount) - Number(this.totalFundedPremium)).toString(),
                'tenureChanged': this.tenure,
                'advanceEmiFlag': this.advanceEMi == false ? 'No' : 'Yes',
                'provisionAmount' : this.provisionAmount.toString(),//CISP-124
                'offerEMI': this.emi?this.emi.toString():'', // CISP-2359
            };

            //START D2C Changes Swapnil
            let offerEngineMethod = doOfferEngineCallout;
            let offerEngineParams = { offerEngineRequestString: JSON.stringify(offerEngineRequestString) };
            if(this.leadSource === 'D2C'){
                let sliderAmount =Number(this.loanAmount).toString();
                offerEngineMethod = doD2COfferEngineCallout;
                offerEngineParams = {loanId: this.recordId, applicantId: null, fromScreen:'sliderScreen',sliderTenure: this.tenure, sliderLoanAmount:sliderAmount};
            }
            //END D2C Changes Swapnil

            offerEngineMethod(offerEngineParams)
            .then(result => {
                const obj = this.leadSource === 'D2C' ? this.getParsedJSOND2C(JSON.parse(result)) : JSON.parse(result);
                //this.retryCount();
                console.log('doOfferEngineCallout result', obj);
                this.isSpinnerMoving = true;
                const FinalTermFields = {};
                FinalTermFields[final_ID_FIELD.fieldApiName] = this.isRecordId;
                FinalTermFields[EMI_Amount.fieldApiName] = obj.EMI != null ? obj.EMI : this.emi;
                FinalTermFields[Tenure.fieldApiName] = obj.Tenure != null ? obj.Tenure.toString() : this.tenure;
                FinalTermFields[Loan_Amount.fieldApiName] = obj.Loan_Amt != null ? (parseFloat(obj.Loan_Amt) - this.totalFundedPremium).toString() : this.loanAmount;
                if(obj.Loan_Amt == null){FinalTermFields[Loan_Amount.fieldApiName] = (this.loanAmount - this.totalFundedPremium).toString();}
                FinalTermFields[CRM_IRR.fieldApiName] = obj.CRM_IRR != null ? obj.CRM_IRR : this.requiredCRMIRR;
                FinalTermFields[Required_CRM_IRR.fieldApiName] = obj.CRM_IRR != null ? obj.CRM_IRR.toString() : this.requiredCRMIRR;//D2C Swapnil added toString() as field is text field
                if (obj.Max_Tenure_Slider != null) {
                    FinalTermFields[OfferengineMaxTenure.fieldApiName] = obj.Max_Tenure_Slider;
                }
                if (obj.Min_Tenure_Slider != null) {
                    FinalTermFields[OfferengineMinTenure.fieldApiName] = obj.Min_Tenure_Slider;
                }
                if (obj.Min_Loan_Amt_Slider != null) {
                    FinalTermFields[OfferengineMinLoanAmount.fieldApiName] = obj.Min_Loan_Amt_Slider;
                }
                if (obj.Max_Loan_Amt_Slider != null) {
                    FinalTermFields[OfferengineMaxLoanAmount.fieldApiName] = obj.Max_Loan_Amt_Slider;
                }
                if (obj.Imputed_IRR_Offered != null) { FinalTermFields[Inputted_IRR.fieldApiName] = parseFloat(obj.Imputed_IRR_Offered); }
                if (obj.Net_IRR_Offered != null) { FinalTermFields[Net_IRR.fieldApiName] = parseFloat(obj.Net_IRR_Offered); FinalTermFields[Net_IRR_DECIMAL.fieldApiName] = parseFloat(obj.Net_IRR_Offered); }
                if (obj.Gross_IRR_Offered != null) { FinalTermFields[Gross_IRR.fieldApiName] = parseFloat(obj.Gross_IRR_Offered); }
                if (obj.Stop_Journey_Flag === "True" && this.productType.toLowerCase() !== 'Passenger Vehicles'.toLowerCase()) {//CISP-2331
                    FinalTermFields[OfferengineStopJourneyFlag.fieldApiName] = true;
                }
                FinalTermFields[Advance_EMI.fieldApiName] = this.advanceEMi;
                if (this.monitoriumDaysValue != null) {
                    FinalTermFields[Holiday_period.fieldApiName] = this.monitoriumDaysValue.toString();
                }
                else { FinalTermFields[Holiday_period.fieldApiName] = '0'; }
                if(this.leadSource == 'D2C'){
                    if(obj.NetPayIns != null && this.leadSource === 'D2C'){
                        FinalTermFields[Net_Pay_Ins.fieldApiName]=obj.NetPayIns;
                    }
                    if(obj.NetPayOuts != null && this.leadSource === 'D2C'){
                        FinalTermFields[Net_Pay_Outs.fieldApiName]=obj.NetPayOuts;
                    }
                    if(obj.Loan_Amt != null){
                        FinalTermFields[Loan_Amount.fieldApiName] = obj.Loan_Amt.toString();;
                    }else{
                        FinalTermFields[Loan_Amount.fieldApiName] = this.loanAmount.toString();;
                    }
                    if(this.leadSource != 'Hero'){
                        if(obj.TableCode){FinalTermFields[Table_Code.fieldApiName] = obj.TableCode;}
                        if(obj.Interest_VersionNo){FinalTermFields[Interest_Version_No.fieldApiName] = obj.Interest_VersionNo;}
                        if(obj.DR_PenalInterest){FinalTermFields[DR_Penal_Interest.fieldApiName] = obj.DR_PenalInterest;}
                        if(obj.mclrRate){FinalTermFields[mclrRate.fieldApiName] = obj.mclrRate;} 
                    }    
                    
                }
                if(!this.isTractor){
                    if(obj.loanDealDate){FinalTermFields[Loan_Deal_Date.fieldApiName] = obj.loanDealDate;}
                    if(obj.agreementAmount){FinalTermFields[OE_Agreement_Amount.fieldApiName] = obj.agreementAmount;}
                    helper.saveAmortDetails(this,obj,this.recordId);}
                //CISP-124
                if(this.provisionAmount){
                    FinalTermFields[Provisional_Channel_Cost.fieldApiName] = this.provisionAmount.toString();
                 }

                 if(this.leadSource === 'D2C') {
                    FinalTermFields[service_charge.fieldApiName] = obj.service_charge;
                    FinalTermFields[Provisional_Channel_Cost.fieldApiName] = obj.provisionCost;
                    FinalTermFields[Mfr_incentive.fieldApiName] = obj.mfrIncentive;
                    FinalTermFields[Dealer_incentive_amount_main_dealer.fieldApiName] = obj.dealerIncentiveMain;
                    FinalTermFields[doc_charge.fieldApiName] = obj.docCharges;
                 }
                    if(this.leadSource != 'Hero'){
                        if(obj.TableCode){FinalTermFields[Table_Code.fieldApiName] = obj.TableCode;}
                        if(obj.Interest_VersionNo){FinalTermFields[Interest_Version_No.fieldApiName] = obj.Interest_VersionNo;}
                        if(obj.DR_PenalInterest){FinalTermFields[DR_Penal_Interest.fieldApiName] = obj.DR_PenalInterest;}
                        if(obj.mclrRate){FinalTermFields[mclrRate.fieldApiName] = obj.mclrRate;}     
                }
                 //CISP-124
                this.updateRecordDetails(FinalTermFields);
                //window.location.reload();
                this.loanAmount = obj.Loan_Amt != null ? obj.Loan_Amt : this.loanAmount;this.loanAmountFinal = obj.Loan_Amt != null ? obj.Loan_Amt : this.loanAmount;this.tenure = obj.Tenure != null ? obj.Tenure : this.tenure;this.tenureFinal = obj.Tenure != null ? obj.Tenure : this.tenure;this.crmIRR = obj.CRM_IRR != null ? obj.CRM_IRR : this.crmIRR;this.emi = obj.EMI != null ? obj.EMI : this.emi;this.requiredCRMIRR = obj.CRM_IRR != null ? obj.CRM_IRR : this.requiredCRMIRR;this.maxLoanAmount = obj.Max_Loan_Amt_Slider != null ? obj.Max_Loan_Amt_Slider : this.maxLoanAmount;this.minLoanAmount = obj.Min_Loan_Amt_Slider != null ? obj.Min_Loan_Amt_Slider : this.minLoanAmount;this.maxTenure = obj.Max_Tenure_Slider != null ? obj.Max_Tenure_Slider : this.maxTenure;this.minTenure = obj.Min_Tenure_Slider != null ? obj.Min_Tenure_Slider : this.minTenure;
                //INDI-4652 - START 10-6-2022
                this.calculateNumberOfInstallments(this.monitoriumDaysValue, this.tenure);
                this.netIRRValue = obj.Net_IRR_Offered != null ? obj.Net_IRR_Offered : this.netIRRValue;
                this.grossIRRValue = obj.Gross_IRR_Offered != null ? obj.Gross_IRR_Offered : this.grossIRRValue;
                //INDI-4652 - END 10-6-2022

                if (obj.Stop_Journey_Flag === "True" && this.productType.toLowerCase() !== 'Passenger Vehicles'.toLowerCase()) {//CISP-2331
                    this.toastMsg('Journey Stoped');
                    let allElements = this.template.querySelectorAll('*');
                    allElements.forEach(element =>
                        element.disabled = true
                    );
                    this.isSpinnerMoving = false;
                    this.template.querySelector('.cancel').disabled = false;this.journeyStopScenarioFound();
                }
                else{
                    this.showToast('Success','Offer Engine Successful','Success');this.flagLoanAmountChange = false;this.flagTenureChange = false;this.flagAdvanceEmiChange = false;this.flagMonitoriumDays = false;this.flagRequiredCrrIrrChange = false;this.isSpinnerMoving = false;this.notgreaterthanmax = true;//CISP-2880
                    this.advanceEmis = this.advanceEMi;this.requiredCrmIrr = this.requiredCRMIRR;this.tenureFinal = this.tenure;this.loanAmountFinal = this.loanAmount;this.monitoriumDaysValueFinal = this.monitoriumDaysValue;this.rerunOEDisable = true;
                    if(obj.CRM_IRR > 90 && this.isTractor){
                        this.showToast('Error','The loan journey will be ended since, it does not meet the IIR requirements, please withdraw the loan Application','error');
                    }
                }
                //Disabling the rerun offer engine button.
                let ev = new CustomEvent('parentmhd');
                this.dispatchEvent(ev);
                this.disableReRunButton = true;
            })
            .catch(error => {
                this.showToast('Error','Offer Engine Failed','error');
                this.isSpinnerMoving = false;
            });
        }
    }
    //TF offer Engine API callout SFTRAC-126
   @api async handleTFOfferEngineCalloutHelper(loanAmount){
        await helper.runOfferEngineHandler(this,loanAmount);
    }
    @api handlehandleAccordionLabel(accordionLabelChange){
        this.accordionName = 'Offer Screen - '+accordionLabelChange;
    }
    //D2C Changes Swapnil
    getParsedJSOND2C(parsedJSON){
        let obj = {};
        obj.EMI = parsedJSON?.application?.offerEngineDetails?.offerEngineDecision?.displayEMI;obj.Tenure = parsedJSON?.application?.offerEngineDetails?.offerEngineDecision?.displayTenure;obj.Loan_Amt = parsedJSON?.application?.offerEngineDetails?.offerEngineDecision?.displayLoanAmt;obj.CRM_IRR = parsedJSON?.application?.offerEngineDetails?.offerEngineDecision?.displayCrmIrr;obj.Max_Tenure_Slider = parsedJSON?.application?.offerEngineDetails?.offerEngineDecision?.maxTenureSlider;obj.Min_Tenure_Slider = parsedJSON?.application?.offerEngineDetails?.offerEngineDecision?.minTenureSlider;obj.Min_Loan_Amt_Slider = parsedJSON?.application?.offerEngineDetails?.offerEngineDecision?.minLoanAmtSlider;obj.Max_Loan_Amt_Slider = parsedJSON?.application?.offerEngineDetails?.offerEngineDecision?.maxLoanAmtSlider;obj.Imputed_IRR_Offered = parsedJSON?.application?.offerEngineDetails?.offerEngineDecision?.displayImputedIrr;obj.Net_IRR_Offered = parsedJSON?.application?.offerEngineDetails?.offerEngineDecision?.netIrr;obj.Gross_IRR_Offered = parsedJSON?.application?.offerEngineDetails?.offerEngineDecision?.grossIrr;obj.Stop_Journey_Flag = parsedJSON?.application?.offerEngineDetails?.offerEngineDecision?.stopJourneyFlag;obj.Stop_Journey_Flag = obj.Stop_Journey_Flag ? 'True' : 'False';//D2C change - Rahul
        obj.NetPayIns = parsedJSON?.application?.offerEngineDetails?.offerEngineDecision?.netPayIns?.toString();obj.NetPayOuts = parsedJSON?.application?.offerEngineDetails?.offerEngineDecision?.netPayOuts?.toString();
        obj.TableCode = parsedJSON?.application?.tableCode;obj.Interest_VersionNo = parsedJSON?.application?.interestVersionNo;obj.DR_PenalInterest = parsedJSON?.application?.drPenalInterest?.toString();obj.mclrRate = parsedJSON?.application?.loanDetails?.mclrRate?.toString();obj.service_charge = parsedJSON?.application?.offerEngineDetails?.payins?.serviceCharges?.toString();// change - add service charge
        obj.provisionCost = parsedJSON?.application?.offerEngineDetails?.payouts?.provisionCost?.toString();// change - add provisionCost
        obj.dealerIncentiveMain = parsedJSON?.application?.offerEngineDetails?.payouts?.dlrIncentiveAmtMain?.toString();// change - add dlrIncentiveAmtMain
        obj.mfrIncentive = parsedJSON?.application?.offerEngineDetails?.payouts?.mfrIncentiveAmt?.toString();// change - add mfrIncentiveAmt
        obj.docCharges = parsedJSON?.application?.offerEngineDetails?.payins?.docCharges?.toString();// change - add doc charge
        return obj;
    }
    @api validateEmiAndMD(){
        let advanceEMiInput = this.template.querySelector('lightning-input[data-id=advanceEMIid]');
        let moratoriumDays = this.template.querySelector('.monDay');
        if((!this.advanceEMi && (this.monitoriumDaysValue == '0' || this.monitoriumDaysValue == ' ' || this.monitoriumDaysValue == null))){
            advanceEMiInput.setCustomValidity("");
            this.advanceEmiDisabled = false;
            advanceEMiInput.setCustomValidity('Enter advance EMI Value');
            advanceEMiInput.reportValidity();
            return false;
        }
        return true;
    }
     //CISP-16686 start
   @api validateLoanamountTw(){
    if ((Number(this.tenure) > 36 || Number(this.tenure) < 6) && parseFloat(this.loanAmount) < 90000) {//CISP-20773
                      console.log('here', this.productType.toLowerCase());
                      this.tenure = '';
                      const event = new ShowToastEvent({
                          title: 'Warning',
                          message: 'Loan amount is lessthan INR 90,000 hence please enter tenure between 6 to 36 only',
                          variant: 'Warning',
                      });
                      this.dispatchEvent(event);
                      return true;
                  }
                  if ((Number(this.tenure) > 48 || Number(this.tenure) < 6) && parseFloat(this.loanAmount) > 90000) {
                    console.log('here', this.productType.toLowerCase());
                    this.tenure = '';
                    const event = new ShowToastEvent({
                        title: 'Warning',
                        message: 'Tenure Value is out of bounds.Please enter value between 6 and 48',
                          variant: 'Warning',
                      });
                      this.dispatchEvent(event);
                      return true;
                  }
              if(this.productSegment!=null && this.productSegment!='' && this.productSegment === 'ESCOOTER'){
                 if (parseFloat(this.loanAmount) > 150000 || parseFloat(this.loanAmount) < 25000) {
                     const event = new ShowToastEvent({
                         title: 'Warning',
                         message: 'Loan amount is out of bounds. Please enter value between 25k to 1.5L',
                         variant: 'Warning',
                     });
                     this.dispatchEvent(event);
                     return true;
                 }
              }else{
                 if (parseFloat(this.loanAmount) > 160000 || parseFloat(this.loanAmount) < 20000) {
                     const event = new ShowToastEvent({
                         title: 'Warning',
                         message: 'Loan amount is out of bounds. Please enter value between 20k to 1.6L',
                         variant: 'Warning',
                     });
                     this.dispatchEvent(event);
                     return true;
                 }
              }
     return false;
}//CISP-16686 end
    @api validateCRMIRR(){//Start CISP-2702
        console.log('response3',this.crmIRR,this.mincrm,this.maxcrm);
        if(this.productType.toLowerCase() === 'Two Wheeler'.toLowerCase() && this.crmIRR!=null && this.mincrm!=null && this.maxcrm!=null && ((parseFloat(this.crmIRR) < parseFloat(this.mincrm)) || (parseFloat(this.crmIRR) > parseFloat(this.maxcrm)))){
            return true;
        }
        return false;
    }//End CISP-2702
      
    @api async validateLoanamount(){//CISP-7754 start
        return await helper.validationHelper(this);
       return false;
   }//CISP-7754 end
    @api validateCallType()
    {
        if(this.minLoanAmount != undefined && this.minLoanAmount !=null && this.minLoanAmount > 0)
        {return true;
        }
        return false;
    }
    @api disabledOfferScreen()
    {
        this.disabledLoanAmount = true;this.loanSliderDisabled = true; this.tenureSliderDisabled = true; this.disabledTenure = true; this.disabledRequiredCrmIrr = true; this.advanceEmiDisabled = true;  this.monitoriumDaysDisabled = true; this.disabledEmiAmount = true;//CISP-2505
    }
    @api enabledOfferScreen(){//Start CISP-2702
        console.log('response4321');
        this.disabledLoanAmount = false;
        this.loanSliderDisabled = false;
        if(this.isTractor == false){
            this.tenureSliderDisabled = false;this.disabledTenure = false;this.monitoriumDaysDisabled = false;this.disabledEmiAmount = false;
        }
        this.disabledRequiredCrmIrr = true;this.advanceEmiDisabled = true;
    }//End CISP-2702
        @api async calldoOfferEngineCalloutVarient(loan) {
        this.loanAmount = parseInt(loan,10);
        console.log('loanAmount ', this.loanAmount);
        await this.calculateProvisionAmt(this.loanAmount, this.tenure);
        // CISP-124 OR CISP-2655-END
        let offerEngineRequestString = {
            'loanApplicationId': this.recordId,
            'currentScreen': 'Offer',//CISP-2346/CISP-2556        
            'thresholdNetIRR': null,
            'crmIrrChanged': this.requiredCRMIRR,
            'loanAmountChanged': (Number(loan) - Number(this.totalFundedPremium)).toString(),
            'tenureChanged': this.tenure,
            'advanceEmiFlag': this.advanceEMi == false ? 'No' : 'Yes',
            'provisionAmount' : this.provisionAmount.toString(),//CISP-124
            'offerEMI': this.emi?this.emi.toString():'', // CISP-2359
        };
        //START D2C Changes Raman
        let offerEngineMethod = doOfferEngineCallout;
        let offerEngineParams = { offerEngineRequestString: JSON.stringify(offerEngineRequestString) };
        if(this.leadSource === 'D2C' || this.leadSource === 'Hero'){//CISH-04
            offerEngineMethod = doD2COfferEngineCallout;
            offerEngineParams = {loanId: this.recordId, applicantId: null};
        }
        //END D2C Changes Raman
        offerEngineMethod(offerEngineParams)
            .then(result => {
                const obj = (this.leadSource === 'D2C' || this.leadSource === 'Hero')  ? this.getParsedJSOND2C(JSON.parse(result)) : JSON.parse(result);
                //this.retryCount();
                console.log('doOfferEngineCallout result', obj);
                this.isSpinnerMoving = true;
                const FinalTermFields = {};
                FinalTermFields[final_ID_FIELD.fieldApiName] = this.isRecordId;
                FinalTermFields[EMI_Amount.fieldApiName] = obj.EMI != null ? obj.EMI : this.emi;
                FinalTermFields[Tenure.fieldApiName] = obj.Tenure != null ? obj.Tenure.toString() : this.tenure;//D2C Swapnil added toString() as field is text field
                FinalTermFields[Loan_Amount.fieldApiName] = obj.Loan_Amt != null ? (parseFloat(obj.Loan_Amt) - this.totalFundedPremium).toString()  : this.loanAmount;
                if(obj.Loan_Amt == null){FinalTermFields[Loan_Amount.fieldApiName] = (this.loanAmount - this.totalFundedPremium).toString();}
                FinalTermFields[CRM_IRR.fieldApiName] = obj.CRM_IRR != null ? obj.CRM_IRR : this.requiredCRMIRR;
                FinalTermFields[Required_CRM_IRR.fieldApiName] = obj.CRM_IRR != null ? obj.CRM_IRR.toString() : this.requiredCRMIRR;//D2C Swapnil added toString() as field is text field
                if (obj.Max_Tenure_Slider != null) {
                    FinalTermFields[OfferengineMaxTenure.fieldApiName] = obj.Max_Tenure_Slider;
                }
                if (obj.Min_Tenure_Slider != null) {
                    FinalTermFields[OfferengineMinTenure.fieldApiName] = obj.Min_Tenure_Slider;
                }
                if (obj.Min_Loan_Amt_Slider != null) {
                    FinalTermFields[OfferengineMinLoanAmount.fieldApiName] = obj.Min_Loan_Amt_Slider;
                }
                if (obj.Max_Loan_Amt_Slider != null) {
                    FinalTermFields[OfferengineMaxLoanAmount.fieldApiName] = obj.Max_Loan_Amt_Slider;
                }
                if (obj.Imputed_IRR_Offered != null) { FinalTermFields[Inputted_IRR.fieldApiName] = parseFloat(obj.Imputed_IRR_Offered); }
                if (obj.Net_IRR_Offered != null) { FinalTermFields[Net_IRR.fieldApiName] = parseFloat(obj.Net_IRR_Offered); FinalTermFields[Net_IRR_DECIMAL.fieldApiName] = parseFloat(obj.Net_IRR_Offered); }
                if (obj.Gross_IRR_Offered != null) { FinalTermFields[Gross_IRR.fieldApiName] = parseFloat(obj.Gross_IRR_Offered); }
                if (obj.Stop_Journey_Flag === "True" && this.productType.toLowerCase() !== 'Passenger Vehicles'.toLowerCase()) {//CISP-2331
                    FinalTermFields[OfferengineStopJourneyFlag.fieldApiName] = true;
                }
                FinalTermFields[Advance_EMI.fieldApiName] = this.advanceEMi;
                if (this.monitoriumDaysValue != null) {
                    FinalTermFields[Holiday_period.fieldApiName] = this.monitoriumDaysValue.toString();
                }
                else { FinalTermFields[Holiday_period.fieldApiName] = '0'; }
                if(this.leadSource == 'D2C'){
                    if(obj.NetPayIns != null && this.leadSource === 'D2C'){
                        FinalTermFields[Net_Pay_Ins.fieldApiName]=obj.NetPayIns;
                    }
                    if(obj.NetPayOuts != null && this.leadSource === 'D2C'){
                        FinalTermFields[Net_Pay_Outs.fieldApiName]=obj.NetPayOuts;
                    }
                    if(obj.Loan_Amt != null){
                        FinalTermFields[Loan_Amount.fieldApiName] = obj.Loan_Amt.toString();;
                    }else{
                        FinalTermFields[Loan_Amount.fieldApiName] = this.loanAmount.toString();;
                    }
                    
                }
                if(this.leadSource != 'Hero'){
                    if(obj.TableCode){FinalTermFields[Table_Code.fieldApiName] = obj.TableCode;}
                    if(obj.Interest_VersionNo){FinalTermFields[Interest_Version_No.fieldApiName] = obj.Interest_VersionNo;}
                    if(obj.DR_PenalInterest){FinalTermFields[DR_Penal_Interest.fieldApiName] = obj.DR_PenalInterest;}
                    if(obj.mclrRate){FinalTermFields[mclrRate.fieldApiName] = obj.mclrRate;} 
                }
                //CISP-124
                if(this.provisionAmount){
                    FinalTermFields[Provisional_Channel_Cost.fieldApiName] = this.provisionAmount.toString();
                 }
                 if(this.leadSource === 'D2C') {//D2C changes
                    FinalTermFields[service_charge.fieldApiName] = obj.service_charge;FinalTermFields[Provisional_Channel_Cost.fieldApiName] = obj.provisionCost;FinalTermFields[Mfr_incentive.fieldApiName] = obj.mfrIncentive;FinalTermFields[Dealer_incentive_amount_main_dealer.fieldApiName] = obj.dealerIncentiveMain;FinalTermFields[doc_charge.fieldApiName] = obj.docCharges;
                }
                 //CISP-124
                this.updateRecordDetails(FinalTermFields);
                //window.location.reload();
                this.loanAmount = obj.Loan_Amt != null ? obj.Loan_Amt : this.loanAmount;this.loanAmountFinal = obj.Loan_Amt != null ? obj.Loan_Amt : this.loanAmount;
                this.tenure = obj.Tenure != null ? obj.Tenure : this.tenure;this.tenureFinal = obj.Tenure != null ? obj.Tenure : this.tenure;this.crmIRR = obj.CRM_IRR != null ? obj.CRM_IRR : this.crmIRR;this.emi = obj.EMI != null ? obj.EMI : this.emi;this.requiredCRMIRR = obj.CRM_IRR != null ? obj.CRM_IRR : this.requiredCRMIRR;this.maxLoanAmount = obj.Max_Loan_Amt_Slider != null ? obj.Max_Loan_Amt_Slider : this.maxLoanAmount;this.minLoanAmount = obj.Min_Loan_Amt_Slider != null ? obj.Min_Loan_Amt_Slider : this.minLoanAmount;this.maxTenure = obj.Max_Tenure_Slider != null ? obj.Max_Tenure_Slider : this.maxTenure;this.minTenure = obj.Min_Tenure_Slider != null ? obj.Min_Tenure_Slider : this.minTenure;
                //INDI-4652 - START 10-6-2022
                this.calculateNumberOfInstallments(this.monitoriumDaysValue, this.tenure);
                this.netIRRValue = obj.Net_IRR_Offered != null ? obj.Net_IRR_Offered : this.netIRRValue;
                this.grossIRRValue = obj.Gross_IRR_Offered != null ? obj.Gross_IRR_Offered : this.grossIRRValue;
                //INDI-4652 - END 10-6-2022
                if (obj.Stop_Journey_Flag === "True" && this.productType.toLowerCase() !== 'Passenger Vehicles'.toLowerCase()) {//CISP-2331
                    this.toastMsg('Journey Stoped');
                    let allElements = this.template.querySelectorAll('*');
                    allElements.forEach(element =>
                        element.disabled = true
                    );
                    this.isSpinnerMoving = false;this.template.querySelector('.cancel').disabled = false;this.journeyStopScenarioFound();
                }
                else{
                    const evt = new ShowToastEvent({
                        title: "Success",
                        message: "Offer Engine Successful",
                        variant: 'Success',
                    });
                    this.dispatchEvent(evt);
                    this.flagLoanAmountChange = false; this.flagTenureChange = false;this.flagAdvanceEmiChange = false; this.flagMonitoriumDays = false; this.flagRequiredCrrIrrChange = false;  this.isSpinnerMoving = false; this.disabledLoanAmount = false;  this.loanSliderDisabled = false; this.tenureSliderDisabled = false; this.disabledTenure = false;  this.disabledRequiredCrmIrr = false;  this.advanceEmiDisabled = false;   this.monitoriumDaysDisabled = false; this.advanceEmis = this.advanceEMi;this.requiredCrmIrr = this.requiredCRMIRR;  this.tenureFinal = this.tenure; this.loanAmountFinal = this.loanAmount;   this.monitoriumDaysValueFinal = this.monitoriumDaysValue; 
                    if(obj.CRM_IRR > 90 && this.isTractor){
                        this.showToast('Error','The loan journey will be ended since, it does not meet the IIR requirements, please withdraw the loan Application','error');
                    }
                    let ev = new CustomEvent('parentmethodaccepts');
                    this.dispatchEvent(ev);
                }
            })
            .catch(error => {
                console.log(error);
                this.showToast('Error','Offer Engine Failed','error');
                this.isSpinnerMoving = false;
            });
     }
     //CISP-4459 start
    journeyStopScenarioFound(){
        updateJourneyStop({ leadNo: this.recordId })
        .then(result => {
            console.log('Result', result);
        })
        .catch(error => {
            console.error('Error:', error);
        });
    }//CISP-4459
     handleEmiChange(event){ //Start CISP-2379
        try {
            if (parseFloat(this.emiFinal) !== parseFloat(event.target.value)) {
                this.flagEmiChange = true;
                this.handleEmiFlagChange = true;//CISP-2646
                this.eligiblityButtonClicked = false;//CISP-2646
            }
            else {
                this.flagEmiChange = false;
                this.handleEmiFlagChange = false;//CISP-2646
            }
            this.emi = event.target.value;
            let ev = new CustomEvent('parentmethod');this.disableReRunButton = false;
            this.dispatchEvent(ev);
            let elem = this.template.querySelector('lightning-input[data-id=emi]');
            if(this.flagEmiChange){
                const event = new ShowToastEvent({
                    title: 'Warning',
                    message: 'EMI Amount is changed kindly click on Re-Run offer',
                    variant: 'Warning',
                });
                this.dispatchEvent(event);
            }            
        } catch (error) {
            console.error(error);
        }
    } //End CISP-2379
    //CISP-124
    calculateProvisionAmt(loanAmount, tenure) {
        try {
            let provisionalChannelCostValue = '';
            if(this.productType.toLowerCase()==='Two Wheeler'.toLowerCase() && (this.vehicleType.toLowerCase()==='new'.toLowerCase())){
                if(tenure >= 12){
                    let checkProvisionalChannelCost=(this.provisionalChannelCostValid * (parseInt(loanAmount, 10) / 100) + this.provisionalChannelCostMinValid);
                    checkProvisionalChannelCost=(Math.round(checkProvisionalChannelCost));provisionalChannelCostValue=checkProvisionalChannelCost;
                }else{
                    let checkProvisionalChannelCost=(this.provisionalChannelCostTwoValid * (parseInt(loanAmount, 10) / 100) + this.provisionalChannelCostMaxValid);
                    checkProvisionalChannelCost=(Math.round(checkProvisionalChannelCost));provisionalChannelCostValue=checkProvisionalChannelCost;
                }
            }
            else if(this.productType.toLowerCase()==='Two Wheeler'.toLowerCase() && (this.vehicleType.toLowerCase()==='Refinance'.toLowerCase() || this.vehicleType.toLowerCase()==='used'.toLowerCase())){
                let checkProvisionalChannelCost=((this.provisionalChannelCostValid * parseInt(loanAmount, 10) / 100) + this.provisionalChannelCostMaxValid);
                checkProvisionalChannelCost=(Math.round(checkProvisionalChannelCost));provisionalChannelCostValue=checkProvisionalChannelCost;
            }
            console.log('provisionalChannelCostValue ', provisionalChannelCostValue);this.provisionAmount = provisionalChannelCostValue;
        } catch (error) {
            console.error(error);
        }
    }
    //CISP-124
    @api
    async getDocumentsToCheckPanValid(){
        let totalamount = 0;
        totalamount = parseInt(this.loanAmount) + parseInt(this.fundedPremiumValue) + parseInt(this.existingBorrowerExposureAmount) + parseInt(this.existingCoBorrowerExposureAmount) + parseInt(this.existingOtherExposureAmount) + parseInt(this.bankExposureAmount); 
        console.log('OUTPUT totalamount: ',totalamount); 
        if((parseInt(totalamount) >= 1000000) && (this.documentCheckdata?.borrowerPanAvailable == false || this.documentCheckdata?.coborrowerPanAvailable == false ) && this.leadSource != 'D2C'){
            this.toastMsg('Exposure (Incl. loan amount) is >= INR 10 Lakhs, hence, PAN is mandatory. Please withdraw this lead and create a new lead with PAN or change the Loan amount');
            return false;
        }
        return true;
    }
    showToast(title, message, variant){
        const evt = new ShowToastEvent({title: title, message: message, variant: variant,});
        this.dispatchEvent(evt);
    }
    disableReRunButton = true;
    reRunButton = false;
    async handle_offer_Text_Click(){
        this.reRunButton = true;
        await this.callcreateFinalTermRecord();
    }
    handleEmiDueDateChange(event){helper.handleEmiChangeHelper(this, event);}
    }