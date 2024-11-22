import { api, LightningElement, track } from 'lwc';
import loadSelectedSchemeData from '@salesforce/apex/IND_OfferScreenController.loadSelectedSchemeData';
import loadOfferScreenData from '@salesforce/apex/IND_OfferScreenController.loadOfferScreenData';
import getOfferScreenData from '@salesforce/apex/IND_OfferScreenController.getOfferScreenData';
import getPurchaseprice from '@salesforce/apex/IND_OfferScreenController.getPurchaseprice'; //SFTRAC-901
import { updateRecord } from 'lightning/uiRecordApi';
import tractorOfferEngineCallout from '@salesforce/apex/IntegrationEngine.tractorOfferEngine'; //SFTRAC-126
import updateRetryCount from '@salesforce/apex/IND_OfferScreenController.updateRetryCount';
import { loadStyle } from 'lightning/platformResourceLoader';
import LightningCardCSS from '@salesforce/resourceUrl/loanApplication';

import Refinance from '@salesforce/label/c.Refinance';
import OPP_ID_FIELD from '@salesforce/schema/Opportunity.Id';
import STAGENAME from '@salesforce/schema/Opportunity.StageName';
import LASTSTAGENAME from '@salesforce/schema/Opportunity.LastStageName__c';
import final_ID_FIELD from '@salesforce/schema/Final_Term__c.Id';
import Loan_Amount from '@salesforce/schema/Final_Term__c.Loan_Amount__c';
import Advance_EMI from '@salesforce/schema/Final_Term__c.Advance_EMI__c';
import L1_Offer_Screen_Submitted from '@salesforce/schema/Final_Term__c.L1_Offer_Screen_Submitted__c';
import Holiday_period from '@salesforce/schema/Final_Term__c.Holiday_period__c';
import Net_IRR from '@salesforce/schema/Final_Term__c.Net_IRR__c';
import OfferengineMaxTenure from '@salesforce/schema/Final_Term__c.OfferengineMaxTenure__c';
import OfferengineMinTenure from '@salesforce/schema/Final_Term__c.OfferengineMinTenure__c';
import OfferengineMinLoanAmount from '@salesforce/schema/Final_Term__c.OfferengineMinLoanAmount__c';
import OfferengineMaxLoanAmount from '@salesforce/schema/Final_Term__c.OfferengineMaxLoanAmount__c';
import Gross_IRR from '@salesforce/schema/Final_Term__c.Gross_IRR__c';
import Required_CRM_IRR from '@salesforce/schema/Final_Term__c.Required_CRM_IRR__c';
import Derived_CRM_IRR from '@salesforce/schema/Final_Term__c.Derived_CRM_IRR__c'; //SFTRAC-2301
import Tenure from '@salesforce/schema/Final_Term__c.Tenure__c';
import EMI_Amount from '@salesforce/schema/Final_Term__c.EMI_Amount__c';
import getVechicleDetails from '@salesforce/apex/IND_OfferScreenController.getVechicleDetails';
import isNavigate from '@salesforce/schema/Final_Term__c.isNavigate__c';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import changePayinAndPayout from '@salesforce/label/c.changePayinAndPayout'
import enterEMIDays from '@salesforce/label/c.enterEMIDays'
import changeTenure from '@salesforce/label/c.changeTenure';
import changeMoratoriumDay from '@salesforce/label/c.changeMoratoriumDay';
import loanTenureChange from '@salesforce/label/c.loanTenureChange';
import loanAdvanceChanged from '@salesforce/label/c.loanAdvanceChanged';
import loanDayChanged from '@salesforce/label/c.loanDayChanged';
import loanCrm from '@salesforce/label/c.loanCrm';
import crmChanged from '@salesforce/label/c.crmChanged';
import crmIrrNotNeg from '@salesforce/label/c.crmIrrNotNeg';
import loanNotChanged from '@salesforce/label/c.loanNotChanged';
import loanamtmissing from '@salesforce/label/c.loanamtmissing';
import changeCheckEligibility from '@salesforce/label/c.changeCheckEligibility';
import ReadOnlyLeadAccess from '@salesforce/label/c.ReadOnlyLeadAccess';
import submitWarning from '@salesforce/label/c.submitWarning';
import updateJourneyStop from '@salesforce/apex/customerDedupeRevisedClass.updateJourneyStop'; 
import checkL1OfferScreenSubmitted from '@salesforce/apex/IND_OfferScreenController.checkL1OfferScreenSubmitted'; 
import gradedRepaymentSchedule from '@salesforce/apex/EMI_CalculatorController.gradedRepaymentSchedule';
import getStructedEMI from '@salesforce/apex/IND_OfferScreenController.getStructedEMI'; 
import Bank_IRR from '@salesforce/schema/Final_Term__c.Bank_IRR__c'; //SFTRAC-126
import Offer_Agreement_Amount from '@salesforce/schema/Final_Term__c.Offer_Agreement_Amount__c'; //SFTRAC-126
import Change_Pay_IN_OUT from '@salesforce/schema/Final_Term__c.Is_Change_Pay_In_Out_Editable__c'; //SFTRAC-585
import FinalTermsSubmitted from '@salesforce/schema/Final_Term__c.L1_Final_Terms_Submitted__c';
import emiRepaymentSchedule from '@salesforce/apex/IND_OfferScreenController.emiRepaymentSchedule'; 
import roiMasterTractor from '@salesforce/apex/IND_OfferScreenController.roiMasterTractor';
import RateOfInterestMsg from '@salesforce/label/c.RateOfInterestMsg';
import Vehicle_Change_Pay_IN_OUT from '@salesforce/schema/Vehicle_Detail__c.Change_Pay_IN_Pay_OUT__c'; 
import VehicleId from '@salesforce/schema/Vehicle_Detail__c.Id'; 
import updateChangePayinouts from '@salesforce/apex/IND_OfferScreenController.updateChangePayinouts';
import isPayInPayOutCompleted from '@salesforce/apex/IND_OfferScreenController.isPayInPayOutCompleted';
export default class Lwc_TF_OfferScreen_Child extends LightningElement{

    @track crmIRR;
    @track requiredCRMIRR;
    @track minLoanAmount;
    @track minTenure;
    @track maxLoanAmount;
    @track maxTenure;
    @track emi;
    @track loanAmount;
    @track tenure;
    @track loanTimeoutId;
    @track tenureTimeoutId;
    @track loanSliderDisabled = false;
    @track tenureSliderDisabled = false;
    @track isTenureChanged = false;
    @track isRecordId;
    @track requiredCRMIRRPopup = false;
    @track isTenureEligibleCheck = false;
    @track isloanAmountCheck = false;
    @track isChangePayInOutButtonDisable = false;
    @track currentStageName;
    @track lastStage;

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
    emiFinal;
    flagEmiChange = false;
    handleEmiFlagChange = false;
    eligiblityButtonClicked = false;
    flagtoUpdate = false;
    flagLoanAmountChange = false;
    flagRequiredCrrIrrOnlyChanged = false;
    flagTenureChange = false;
    flagRequiredCrrIrrChange = false;
    flagAdvanceEmiChange = false;
    flagMonitoriumDays = false;
    tenureFinal;
    @track mincrm;
    @track maxcrm;
    @track minGROSSIRR;
    @track maxGROSSIRR;
    @track isNonIndividual=false;;
    @track EligibleLoanAmt;
    @track EligibleTenure;
    @track productSegment;
    @track vechSubCategory = '';
    @track vehicleType;
    @track productType;
    @track getTenureValue;
    @api recordid;
    @api checkleadaccess;
    @api vehicleRecordId;    
    @api isRevokedLoanApplication;  
    @api loanAmountObj;  
    @api borrowerPAN;  
    
    @track handleTenureChangebln = false;
    @track numberOfInstallmentValue = '';
    @track netIRRValue = '';
    @track grossIRRValue = '';
    selectedSchemeId;
    schemeValid=false;
    @track disabledEmiAmount=true;
    fromRendercallback=false;
    provisionAmount = 0;
    provisionalChannelCostMinValid = 0;
    provisionalChannelCostMaxValid = 0;
    provisionalChannelCostTwoValid = 0;
    provisionalChannelCostValid = 0;
    oppRecord;
    vehRecord;
    disableCheckEligibility=false;
    disableSubmit=false;
    disabledLoanAmount=false;
    totalPrinciple;
    cashFlows = [];
    totalMonthlyPayment;
    totalPaybleEMI;
    showEquated;
    installmentType;
    installmentFrequency;
    isStructured;
    dealId;
    itemList= [];
    frequency;
    data;
    IRR;
    emiValue;
    firstEMI;
    secondEMI;
    dealDate;
    @track vehiclePurchaseprice;
    isL1OfferScreenSubmitted = false;
    @api vehicleIntallmentType = '';//SFTRAC-2283
    async connectedCallback() {
        await roiMasterTractor({'loanApplicationId' : this.recordid}).then((result)=>{
            if(result){
                this.maxcrm = result.CRM_IRR_MAX;
                this.mincrm = result.CRM_IRR_MIN;
                this.minGROSSIRR = result.GROSS_IRR_MIN;
                this.maxGROSSIRR = result.GROSS_IRR_MAX;
                this.isNonIndividual = result.isNonIndividual;
            }
        }).catch((error)=>console.log("Error in", "roiMasterTractor", error));
        let response = await checkL1OfferScreenSubmitted({'loanApplicationId' : this.recordid, 'vehicleId' : this.vehicleRecordId});
        if(response && response.length > 0){
            this.isRecordId = response[0].Id;
            this.isL1OfferScreenSubmitted = response[0].L1_Offer_Screen_Submitted__c;
            this.numberOfInstallmentValue = response[0].No_of_Installment__c;
            this.monitoriumDaysValue = response[0].Holiday_period__c;
            if(this.isL1OfferScreenSubmitted){
                this.disableEverything();
            }
            if(response[0].Vehicle_Detail__r.Vehicle_type__c){
                this.vehicleType = response[0].Vehicle_Detail__r.Vehicle_type__c;
            }
            if(response[0].Vehicle_Detail__r.Vehicle_SubCategory__c){
                this.vechSubCategory = response[0].Vehicle_Detail__r.Vehicle_SubCategory__c;
            }
            if(response[0].Loan_Application__r.Product_Type__c){
                this.productType = response[0].Loan_Application__r.Product_Type__c;
            }
        }
        var monitoriumDaysList = new Array()
        this.disabledEmiAmount = true;

            await getVechicleDetails({ loanApplicationId: this.recordid, 'vehicleId' : this.vehicleRecordId })
            .then(result => {
                this.currentStageName = result.Loan_Application__r.StageName,
                this.lastStage = result.Loan_Application__r.LastStageName__c,
                this.EligibleTenure = result.Eligible_Tenure__c;
                this.productSegment = result.Product_Segment__c;
                this.EligibleLoanAmt = result.Eligible_Loan_Amount__c;
                this.dealId = result.Deal_Number__c; //SFTRAC-585
                if (result.Loan_Application__r.Vehicle_Sub_Category__c) {
                    this.vechSubCategory = result.Loan_Application__r.Vehicle_Sub_Category__c;
                }
                if(this.vechSubCategory.toLowerCase() === 'UIM'.toLowerCase() && this.productType != 'Tractor'){
                    this.maxLoanAmount = result.Eligible_Loan_Amount__c;
                    this.maxTenure = result.Eligible_Tenure__c;
                }
                this.vehicleType = result.Loan_Application__r.Vehicle_Type__c;
                this.manufacturerYearMonth = result.Manufacturer_Year_Month__c;
                this.productType = result.Loan_Application__r.Product_Type__c;
                //Pick list value for monitorium Days. 
                monitoriumDaysList.push({ label: '0', value: '0' });
                monitoriumDaysList.push({ label: '30', value: '30' });
                monitoriumDaysList.push({ label: '60', value: '60' });
                monitoriumDaysList.push({ label: '90', value: '90' });
                monitoriumDaysList.push({ label: '120', value: '120' });
                monitoriumDaysList.push({ label: '150', value: '150' });
                monitoriumDaysList.push({ label: '180', value: '180' });
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
                    let allElements = this.template.querySelectorAll('*');
                    allElements.forEach(element =>
                        element.label && (element.label =='Tenure' || element.label == 'Tenure Amount' || element.label == 'EMI Amount' || element.label == 'No of Instalments' || element.label == 'Monitorium Days' || element.label == 'CRM IRR' )?element.disabled = true:element.disabled = false 
                     );
                this.loadoffer();  
            })
            .catch(error => {console.log('Error in getVechicleDetails ',error)});
            await updateChangePayinouts({loanApplicationId: this.recordid});
            if(this.checkleadaccess){//if lead is accessible but user from different profile is viewing that
                const evt = new ShowToastEvent({
                    title: ReadOnlyLeadAccess,
                    variant: 'warning',
                    mode: 'sticky'
                });
                this.dispatchEvent(evt);
                this.disableEverything();
            }
            //SFTRAC-901
           let getResponse = await getPurchaseprice({ loanApplicationId: this.recordid, 'vehicleId' : this.vehicleRecordId });
           this.vehiclePurchaseprice = parseInt(getResponse, 10);
            this.disableCheckEligibility = true; //SFTRAC-996
            this.isChangePayInOutButtonDisable = true; //SFTRAC-996
    }

    async loadoffer() {
        console.log('vehicleRecordId -- > ', this.vehicleRecordId);
        loadOfferScreenData({ loanApplicationId: this.recordid ,vehicleId: this.vehicleRecordId})
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
                this.isRecordId = parsedData.getrecordId;
                this.advanceEMi = parsedData.advanceEmi;
                this.advanceEmis = parsedData.advanceEmi;
                this.monitoriumDaysValue = parsedData.monitoriumDays;
                this.monitoriumDaysValueFinal = parsedData.monitoriumDays;
                this.priceingEngineNetIrr = parsedData.priceingEngineNetIrr;
                this.installmentType = parsedData.installmentType;
                this.installmentFrequency = parsedData.installmentFrequency;
                this.firstEMI = parsedData.firstEMI;
                this.secondEMI = parsedData.secondEMI;
                this.dealDate = parsedData.dealDate;
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
                if(this.vechSubCategory.toLowerCase() === 'UIM'.toLowerCase() && this.productType != 'Tractor'){
                    this.maxLoanAmount = this.EligibleLoanAmt;
                    this.maxTenure = this.EligibleTenure;
                }
                if (this.advanceEMi === true) {
                    this.template.querySelector('lightning-input[data-id=advanceEMIid]').checked = true;
                    this.monitoriumDaysDisabled = true;
                    this.monitoriumDaysValue = '0';
                }
                if (this.monitoriumDaysValue != null) {
                    this.advanceEmiDisabled = true;
                }
                if (this.emi == null) {
                    this.disabledLoanAmount = true;
                    this.disabledTenure = true;
                    this.disabledRequiredCrmIrr = true;
                    this.disabledEmiAmount = true;
                    this.advanceEmiDisabled = true;
                    this.monitoriumDaysDisabled = true;
                    if(this.loanAmount != null && this.tenure != null)
                    {
                        this.flagtoUpdate = true;
                    }
                    this.getOfferScreenDatas();
                
                    
                }
                this.handleSliderRanges();
                if(this.selectedSchemeId){
                    this.selectedSchemeRecord();
                }
                let moratoriumDays = parsedData.monitoriumDays;
                let tenureValue = parsedData.tenure;
                this.netIRRValue = parsedData.netIRR;
                this.grossIRRValue = parsedData.grossIRR;
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
                this.loanAmount = result.loanAmount;
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
                if(!this.flagtoUpdate){
                const FinalTermFields = {};
                FinalTermFields[final_ID_FIELD.fieldApiName] = this.isRecordId;
                FinalTermFields[EMI_Amount.fieldApiName] = null;
                FinalTermFields[Tenure.fieldApiName] = result.tenure.toString();
                FinalTermFields[Loan_Amount.fieldApiName] = result.loanAmount.toString();
                FinalTermFields[Required_CRM_IRR.fieldApiName] = result.roi.toString();
                this.updateRecordDetails(FinalTermFields);
                }
            })
            .catch(error => { console.log('Error in getOfferScreenData ',error);});
    }

    toastMsg(message){
        const evt = new ShowToastEvent({
            title: "Error",
            message: message,
            variant: 'error',
        });
        this.dispatchEvent(evt);
    }

    //Submit Button handler
    async handleButtonClick(event) {
        let totalSumLoanAmount = 0;
        for (const key in this.loanAmountObj) {
            if (Object.hasOwnProperty.call(this.loanAmountObj, key)) {
                totalSumLoanAmount += this.loanAmountObj[key];
            }
        }
        if(totalSumLoanAmount > 1000000 && !this.borrowerPAN){
            this.showToastWarning('Total Loan amount of all assets is >=10 Lakhs; hence, PAN is mandatory. Please revoke this lead and create a new lead by uploading PAN or change the Loan amount');
            return;
        }
        let requiredRoiInput = this.template.querySelector('lightning-input[data-id=reqRoi]');
        requiredRoiInput?.setCustomValidity('');
        if(this.isNonIndividual != true && this.mincrm && this.maxcrm && (this.requiredCRMIRR < this.mincrm || this.requiredCRMIRR > this.maxcrm)){
            requiredRoiInput?.setCustomValidity(RateOfInterestMsg);
            requiredRoiInput?.reportValidity();
            this.toastMsg('Required CRM IRR is not as per norms Min '+ this.mincrm +' and Max '+ this.maxcrm + '.');
            this.disableSubmit = false; //SFTRAC-996
            return;
        }
        let schemeValid = await this.selectedSchemeRecord();
        if(schemeValid){
        if ((this.vehicleType?.toLowerCase() === 'Refinance'.toLowerCase() || this.vehicleType?.toLowerCase() === 'Used'.toLowerCase()) && this.vehRecord.Base_Prices__c!=null && (parseFloat(this.loanAmount) + parseFloat(this.totalFundedPremium)) > parseFloat(this.vehRecord.Base_Prices__c)) {//CISP-7754 
            const event = new ShowToastEvent({
                title: 'Warning',
                message: 'Loan amount is out of bounds. Please enter value less than Base Price '+ this.vehRecord.Base_Prices__c,
                variant: 'Warning',
             });
             this.dispatchEvent(event);
             this.disableSubmit = false; //SFTRAC-996
             return;
            }

        else if (this.flagLoanAmountChange && (parseInt(this.loanAmount,10) < this.minLoanAmount || parseInt(this.loanAmount,10) > this.maxLoanAmount) && (this.flagTenureChange || this.flagAdvanceEmiChange || this.flagRequiredCrrIrrChange || this.flagMonitoriumDays || this.flagEmiChange)) {
            this.handleSubSubmit();
        }
        else if (this.flagLoanAmountChange && parseInt(this.loanAmount,10)) {
            const eve = new ShowToastEvent({
                title: 'ERROR',
                message: 'Loan amount is changed kindly click on Check Eligibilty',
                variant: 'Error',
            });
            this.dispatchEvent(eve);
            this.disableSubmit = false; //SFTRAC-996
            return;
        }
        else if(this.loanAmount == null || this.loanAmount == undefined || this.loanAmount == ''){
            const event = new ShowToastEvent({
                title: 'Error',
                message: loanamtmissing,
                variant: 'Error',
            });
            this.dispatchEvent(event);
            this.disableSubmit = false; //SFTRAC-996
            return;
        }
        else{
            this.handleSubSubmit();
        } 
    }
    }
    handleSubSubmit()
    {
        this.flagLoanAmountChange = false;
        this.flagTenureChange = false;
        this.flagRequiredCrrIrrChange = false;
        this.flagAdvanceEmiChange = false;
        this.flagMonitoriumDays = false;

        const FinalTermFields = {};
        FinalTermFields[final_ID_FIELD.fieldApiName] = this.isRecordId;
        FinalTermFields[EMI_Amount.fieldApiName] = this.emi;
        FinalTermFields[Tenure.fieldApiName] = this.tenure.toString();
        FinalTermFields[Loan_Amount.fieldApiName] = this.loanAmount.toString();
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
        let response = this.updateRecordDetails(FinalTermFields);
        
        if(response){
            const evt = new ShowToastEvent({
                title: 'success',
                message: "Details Saved",
                variant: 'Success',
            });
            this.dispatchEvent(evt);
        }
        this.handleTFOfferEngineCalloutHelper();
    }
    async handlechangePay() {
        let requiredRoiInput = this.template.querySelector('lightning-input[data-id=reqRoi]');
        requiredRoiInput?.setCustomValidity('');
        if(this.isNonIndividual != true && this.mincrm && this.maxcrm && (this.requiredCRMIRR < this.mincrm || this.requiredCRMIRR > this.maxcrm)){
            requiredRoiInput?.setCustomValidity(RateOfInterestMsg);
            requiredRoiInput?.reportValidity();
            this.toastMsg('Required CRM IRR is not as per norms Min '+ this.mincrm +' and Max '+ this.maxcrm + '.');
            return;
        }
        let isPayInPayOutCompletedVar = await isPayInPayOutCompleted({finalTermId : this.isRecordId});
        if(this.loanAmount==null || this.loanAmount.toString()==''){
            const missingloan = new ShowToastEvent({
                title: 'ERROR',
                message: loanamtmissing,
                variant: 'Error',
            });
            this.dispatchEvent(missingloan);
           
        }
        
        else if (this.flagLoanAmountChange || !isPayInPayOutCompletedVar) {
            const FinalTermFields = {};
            //saving all the change fields.
            FinalTermFields[final_ID_FIELD.fieldApiName] = this.isRecordId;
            FinalTermFields[Loan_Amount.fieldApiName] = this.loanAmount.toString();
            FinalTermFields[Tenure.fieldApiName] = this.tenure.toString();
            FinalTermFields[Required_CRM_IRR.fieldApiName] = this.requiredCRMIRR.toString();
            FinalTermFields[isNavigate.fieldApiName] = true;
            FinalTermFields[FinalTermsSubmitted.fieldApiName] = false
            FinalTermFields[Advance_EMI.fieldApiName] = this.advanceEMi;
            FinalTermFields[EMI_Amount.fieldApiName] = this.emi;//CISP-2881
            FinalTermFields[Change_Pay_IN_OUT.fieldApiName] = true; 
            if (this.monitoriumDaysValue != null) {
            FinalTermFields[Holiday_period.fieldApiName] = this.monitoriumDaysValue.toString();
            }
            else { FinalTermFields[Holiday_period.fieldApiName] = '0'; }
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
                            this.dispatchEvent(new CustomEvent('submitnavigation', { detail: 'Final Terms',bubbles: true, composed: true}));
                        }).catch(error => { })
                }).catch(error => { })
            updateRetryCount({ loanApplicationId: this.recordid })
                .then(result => { }).catch(error => {console.log('error in updateretry ',error) })

                const vehicleDetailsFields = {};
                vehicleDetailsFields[VehicleId.fieldApiName] = this.vehicleRecordId;
                vehicleDetailsFields[Vehicle_Change_Pay_IN_OUT.fieldApiName] = true;
                this.updateRecordDetails(vehicleDetailsFields)
                .then(result => {
                    }).catch(error => { })
        }
    }

    handleTenureChangeValidation(event)
    {
        this.tenure = event.target.value;
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
        if (this.vechSubCategory.toLowerCase() === 'UIM'.toLowerCase() && (this.vehicleType.toLowerCase() === 'Used'.toLowerCase() || this.vehicleType.toLowerCase() === Refinance.toLowerCase())) {
           if (this.flagLoanAmountChange == true && this.flagTenureChange == true) {
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
            if (this.flagLoanAmountChange == true && this.flagTenureChange == true) {
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
            if (this.flagLoanAmountChange == true && this.flagTenureChange == true) {
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
        else {
           if (this.flagLoanAmountChange == true && this.flagTenureChange == true) {
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

    handleLoanSliderAmount(event)
    {
        let elem = this.template.querySelector('lightning-input[data-id=LoanAmt]');
        elem.setCustomValidity("");
      
        this.loanAmount = parseInt(event.target.value);
        this.dispatchEvent(new CustomEvent('loanamountchanged', {detail : {'loanAmount' : this.loanAmount,'vehicleId' : this.vehicleRecordId}}));
        if (this.vechSubCategory.toLowerCase() === 'UIM'.toLowerCase()) {
            if (event.target.value > this.EligibleLoanAmt) {
                elem.setCustomValidity('Loan Amount value should be less than or equal to Eligibility Amount');
            }
            elem.reportValidity();
        }
        if (parseInt(this.loanAmountFinal,10) !== parseInt(this.loanAmount)) {
            this.flagLoanAmountChange = true;
        }
        else {
            this.flagLoanAmountChange = false;
        }
 
         if (parseInt(this.loanAmountFinal) !== parseInt(this.loanAmount)) {
            this.flagRequiredCrrIrrOnlyChanged = false;
            const event = new ShowToastEvent({
                title: 'Warning',
                message: 'Loan amount is changed kindly click on Check Eligibilty',
                variant: 'warning',
            });
            this.dispatchEvent(event);
            //this.isChangePayInOutButtonDisable = true;
        }
        
        if(parseInt(this.loanAmount,10) >= this.minLoanAmount){  
            this.disableCheckEligibility = false;
        }else{
            const event = new ShowToastEvent({
                title: 'Error',
                message: 'Entered Loan Amount is less than minimum range Amount',
                variant: 'Error',
            });
            this.dispatchEvent(event);
            this.disableCheckEligibility = true;
        }
        
        const newMaxLoanAmount = (0.95 * this.vehiclePurchaseprice);
        const usedRefMaxLoanAmount = (0.90 * this.vehiclePurchaseprice);
        if ( (parseInt(this.loanAmount,10) > newMaxLoanAmount) && this.vehicleType == 'New') {
            const event = new ShowToastEvent({
                title: 'Error',
                message: 'Loan amount cannot exceed 95% of the vehicle purchase price',
                variant: 'Error',
            });
            this.dispatchEvent(event);
            this.disableCheckEligibility = true;
        }else if (parseInt(this.loanAmount,10) > usedRefMaxLoanAmount && (this.vehicleType == 'Used' || this.vehicleType == 'Refinance')) {
            const event = new ShowToastEvent({
                title: 'Error',
                message: 'Loan amount cannot exceed 90% of the vehicle purchase price',
                variant: 'Error',
            });
            this.dispatchEvent(event);
            this.disableCheckEligibility = true;
        }
        
        if (parseInt(this.loanAmount,10) < parseInt(this.minLoanAmount) || parseInt(this.loanAmount,10) > parseInt(this.maxLoanAmount)) {
            this.loanSliderDisabled = true;
        }
        else {
            this.loanSliderDisabled = false;
        }
        
    }
    loanAmtChanged = false;
    handleLoanSliderAmountChange(event) {
        this.loanAmount = event.target.value;
        console.log('Event-->' + event.target.value);
        console.log('Amount in Event-->' + this.loanAmount);
        //this.disableCheckEligibility = false; //SFTRAC-996
        this.isChangePayInOutButtonDisable = true; //SFTRAC-996
        this.disableSubmit = true; //SFTRAC-996
        this.loanAmtChanged = true;
         
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
    requiredIRRchanged = false;

    handleRequiredCRMIRROnchange(event)
    {
        let requiredRoiInput = this.template.querySelector('lightning-input[data-id=reqRoi]');
        requiredRoiInput?.setCustomValidity('');
        let oldRequiredCRMIRR = this.requiredCRMIRR;
        this.requiredCRMIRR = event.target.value;
        if(this.isNonIndividual != true && this.mincrm && this.maxcrm && (this.requiredCRMIRR < this.mincrm || this.requiredCRMIRR > this.maxcrm)){
            requiredRoiInput?.setCustomValidity(RateOfInterestMsg); 
        }
        if (this.requiredCRMIRR != oldRequiredCRMIRR) {
        this.flagRequiredCrrIrrChange = true;
        this.requiredIRRchanged = true;
        }
        else{
            this.flagRequiredCrrIrrChange = false;
            this.requiredIRRchanged = false;
        }
        requiredRoiInput?.reportValidity(); 
        this.disableCheckEligibility = false; //SFTRAC-996
        this.isChangePayInOutButtonDisable = true; //SFTRAC-996
        this.disableSubmit = true; //SFTRAC-996
    }

    handleRequiredCRMIRRChange(event) {
        let requiredRoiInput = this.template.querySelector('lightning-input[data-id=reqRoi]');
        requiredRoiInput?.setCustomValidity('');    
        let oldRequiredCRM = this.requiredCRMIRR;
        this.requiredCRMIRR = event.target.value;
        if ((this.requiredCRMIRR) < 0) {
            this.requiredCRMIRR = '';
            const event = new ShowToastEvent({
                title: 'Warning',
                message: crmIrrNotNeg,
                variant: 'Warning',
            });
            requiredRoiInput?.setCustomValidity(crmIrrNotNeg); 
            this.dispatchEvent(event);
        }else {
            if(this.isNonIndividual != true && this.mincrm && this.maxcrm && this.requiredCRMIRR >= this.mincrm && this.requiredCRMIRR <= this.maxcrm){
                if (this.requiredCRMIRR != oldRequiredCRM) {
                    this.flagRequiredCrrIrrChange = true;
                }
                if (this.flagRequiredCrrIrrChange && !this.flagLoanAmountChange && !this.flagTenureChange && !this.flagAdvanceEmiChange && !this.flagMonitoriumDays) {
                    this.flagRequiredCrrIrrOnlyChanged = true;
                }
            }else if(this.isNonIndividual != true){
                requiredRoiInput?.setCustomValidity(RateOfInterestMsg);
            }
        }
        requiredRoiInput?.reportValidity(); 
    }

    get requiredCRMIRRValue(){
        return this.requiredCRMIRR;
    }


    handlePopupOk() {
        this.requiredCRMIRRPopup = false;
    }

    handleCheckEligibility() {
        let requiredRoiInput = this.template.querySelector('lightning-input[data-id=reqRoi]');
        requiredRoiInput?.setCustomValidity('');
        if(this.isNonIndividual != true && this.mincrm && this.maxcrm && (this.requiredCRMIRR < this.mincrm || this.requiredCRMIRR > this.maxcrm)){
            requiredRoiInput?.setCustomValidity(RateOfInterestMsg);
            requiredRoiInput?.reportValidity();
            this.toastMsg('Required CRM IRR is not as per norms Min '+ this.mincrm +' and Max '+ this.maxcrm + '.');
            return;
        }
        if(this.flagRequiredCrrIrrChange){
            this.flagRequiredCrrIrrChange = false;
        }
        if (this.flagLoanAmountChange && (parseInt(this.loanAmount,10) < this.minLoanAmount || parseInt(this.loanAmount,10) > this.maxLoanAmount) && (this.flagTenureChange || this.flagAdvanceEmiChange || this.flagRequiredCrrIrrChange || this.flagMonitoriumDays)) { //SFTRAC-585
           console.log('else if');
            const eve = new ShowToastEvent({
                title: 'ERROR',
                message: submitWarning,
                variant: 'Error',
            });
            this.dispatchEvent(eve);
        }
        /*else if(!this.flagLoanAmountChange){ //SFTRAC-585
            const event = new ShowToastEvent({
                title: 'Warning',
                message: 'Loan Amount is not changed',
                variant: 'Warning'
            });
            this.dispatchEvent(event);
        } */
        else {
            this.eligiblityButtonClicked = true;
            this.isSpinnerMoving = true;
            this.computeEMI();
            if(this.requiredIRRchanged == true && this.loanAmtChanged == false){
                this.isChangePayInOutButtonDisable = true; //SFTRAC-996 
                this.disableCheckEligibility = true; //SFTRAC-996 
                this.disableSubmit = false; //SFTRAC-996 
            }else{
                if(this.flagLoanAmountChange == false){
                    this.isChangePayInOutButtonDisable = false; //SFTRAC-996 
                    this.disableCheckEligibility = true; //SFTRAC-996 
                    this.disableSubmit = false; //SFTRAC-996  
                }else{
                    this.isChangePayInOutButtonDisable = false; //SFTRAC-996 
                    this.disableCheckEligibility = true; //SFTRAC-996 
                    this.disableSubmit = true; //SFTRAC-996  
                    //this.requiredIRRchanged == false;//SFTRAC-996 
                }    
            }               
                     
        }
    }
    computeEMI(){ //SFTRAC-585
        emiRepaymentSchedule({principal:this.loanAmount,irr:this.requiredCRMIRR,loanDate:this.dealDate,increment:this.tenure,frequency:this.frequency,repaymentDate:this.firstEMI,secondEMI:this.secondEMI,advanceEMI: this.advanceEMi}).then((result) => {
            this.data = result;
            this.totalPaybleEMI = result;
            this.showEquated = true;
            //this.IRR = parseFloat(JSON.stringify(this.data[0].irr));
            this.emi = this.data[1].instalmentAmount;
            //this.requiredCRMIRR = this.IRR;
            this.error = undefined;
                    this.isSpinnerMoving = false;
            const eve = new ShowToastEvent({
                title: 'SUCCESS',
                message: 'EMI Amount is successfully updated',
                variant: 'Success',
            });
            this.dispatchEvent(eve);
        })
        .catch((error) => {
            this.error = error;
                this.isSpinnerMoving = false;
        });

    }
    computeCRRStructured(){ //SFTRAC-585
        getStructedEMI({loanAppId:this.recordid, vehicleId: this.vehicleRecordId}).then(result=>{console.log('result------'+JSON.stringify(result));
        if(result!=null && result.length>0){
            this.itemList = [];
        for(let n = 0; n < result.length; n++){
            var newItem = [{ id: n ,fromMonth:result[n].From_Month__c,toMonth:result[n].To_Month__c,installments:result[n].Number_of_Installments__c,emi:result[n].EMI_Amount__c,sfId:result[n].Id}];
            this.itemList = this.itemList.concat(newItem);
        }}
        this.cashFlows = [];
        const tempList = JSON.parse(JSON.stringify(this.itemList));
        for (let i = 0; i < tempList.length; i++) {
        for (let index = Number(tempList[i].fromMonth); index <= Number(tempList[i].toMonth); index++) {     
            this.cashFlows.push(Number(tempList[i].emi));
        }
        }
              const currentDate = new Date();
               let repaymentDate = new Date();
               repaymentDate.setDate(repaymentDate.getDate() + Number(this.monitoriumDaysValue));
               gradedRepaymentSchedule({cashFlows:this.cashFlows,principal:this.loanAmount,irr:this.requiredCRMIRR,loanDate:currentDate,increment:Number(this.tenure),day:0,frequency:this.frequency,repaymentDate:repaymentDate}).then((result)=>{
                if (result?.length >0) {
                    this.crmIRR = result[0].irr;
                    const evt = new ShowToastEvent({
                        title: "Success",
                        message: "CRM IRR Updated Successfully",
                        variant: 'Success',
                    });
                    this.dispatchEvent(evt);
                    this.isSpinnerMoving = false;
                }
           }).catch((error)=>{
            this.isSpinnerMoving = false;
              console.error(error);
           });
        console.log('this.itemList in connected callback: ',JSON.stringify(this.cashFlows));
}).catch(error=>{
    this.isSpinnerMoving = false;
})
    }
        renderedCallback() {
            loadStyle(this, LightningCardCSS);
            if (this.currentStageName==='Loan Initiation' || this.currentStageName==='Additional Details' || this.currentStageName==='Asset Details' || this.currentStageName==='Vehicle Valuation' || this.currentStageName==='Vehicle Insurance' || this.currentStageName==='Loan Details' || this.currentStageName==='Income Details' || this.currentStageName==='Final Terms'|| (this.currentStageName!=='Offer Screen' && this.lastStage !== 'Offer Screen' && this.lastStage != undefined && this.currentStageName != undefined)) {//CISP-519
               this.fromRendercallback = true;//CISP-2505
               this.disableEverything();
            }
            //this.disableEverything();
                /*if (this.handleEmiFlagChange===true && this.flagLoanAmountChange===false && this.flagTenureChange===false && this.flagRequiredCrrIrrOnlyChanged===false && this.flagRequiredCrrIrrChange===false && this.flagAdvanceEmiChange===false && this.flagMonitoriumDays===false && this.eligiblityButtonClicked === false) {
                    this.disableSubmit= true;
                    this.isChangePayInOutButtonDisable=true;
                    this.disableCheckEligibility=false;
                } else {
                    this.disableSubmit= false;
                    if (this.handleEmiFlagChange===true && this.flagLoanAmountChange===false && this.flagTenureChange===false && this.flagRequiredCrrIrrOnlyChanged===false && this.flagRequiredCrrIrrChange===false && this.flagAdvanceEmiChange===false && this.flagMonitoriumDays===false && this.eligiblityButtonClicked === true) {
                    this.isChangePayInOutButtonDisable=true;this.disableCheckEligibility=true;}else{this.isChangePayInOutButtonDisable=false;this.disableCheckEligibility=false;}
                }*/
            if(this.isL1OfferScreenSubmitted){
                this.disableEverything();
            }
            if(this.isRevokedLoanApplication){this.disableEverything();}
        }

        //TF offer Engine API callout SFTRAC-126
        async handleTFOfferEngineCalloutHelper(){
            this.isSpinnerMoving = true;
            this.requiredIRRchanged == false;//SFTRAC-996
            console.log('++++TF Offer Engine Api method handleTFOfferEngineCalloutHelper '+ this.recordid+' vehicle '+this.vehicleRecordId);
            try{
            let  obj = {'loanAmount': this.loanAmount,'crmIrrRequested':this.requiredCRMIRR};
            let isPayInPayOutCompletedVar = await isPayInPayOutCompleted({finalTermId : this.isRecordId});
            await tractorOfferEngineCallout({ loanAppId: this.recordid, vehicleId: this.vehicleRecordId,screenName : 'Offer Screen',requestWrapperStr: JSON.stringify(obj)}).then(
                result => {
                    const parsedResponse = JSON.parse(result);
                    console.log('++++Offer Engine Api parsedResponse'+parsedResponse);
                    console.log('++++Offer Engine Api2- ',parsedResponse?.application?.offerEngineDetails?.offerEngineDecision);
                    const offerEngineResponse = parsedResponse?.application?.offerEngineDetails?.offerEngineDecision;

                    if(this.isNonIndividual != true && (parseFloat(offerEngineResponse.displayCrmIrr) > parseFloat(this.maxcrm) || parseFloat(offerEngineResponse.displayCrmIrr) < parseFloat(this.mincrm))){
                        this.showToastWarning(`CRM IRR is not as per norms Min ${this.mincrm} and Max ${this.maxcrm}.`);
                        this.isSpinnerMoving = false;
                        return;
                    }else if(this.isNonIndividual != true && (parseFloat(offerEngineResponse.grossIrr) > parseFloat(this.maxGROSSIRR) || parseFloat(offerEngineResponse.grossIrr) < parseFloat(this.minGROSSIRR))){
                        this.showToastWarning(`Gross IRR is not as per norms Min ${this.minGROSSIRR} and Max ${this.maxGROSSIRR}.`);
                        this.isSpinnerMoving = false;
                        return;
                    }

                    this.loanAmount = offerEngineResponse && offerEngineResponse.displayLoanAmt ?  parseInt(offerEngineResponse.displayLoanAmt) : '';
                    this.requiredCRMIRR = offerEngineResponse && offerEngineResponse.displayCrmIrr ?  offerEngineResponse.displayCrmIrr : '';
                    this.emi = offerEngineResponse && offerEngineResponse.displayEMI ?  parseInt(offerEngineResponse.displayEMI) : '';
                    this.maxLoanAmount = offerEngineResponse && offerEngineResponse.maxLoanAmt ?  parseInt(offerEngineResponse.maxLoanAmt) : '';
                    this.minLoanAmount = offerEngineResponse && offerEngineResponse.minLoanAmt ?  parseInt(offerEngineResponse.minLoanAmt) : '';

                    const FinalTermFields = {};
                    FinalTermFields[final_ID_FIELD.fieldApiName]=this.isRecordId;
                    
                    FinalTermFields[OfferengineMinLoanAmount.fieldApiName] = offerEngineResponse !== undefined ?  offerEngineResponse.minLoanAmt : '';
                    FinalTermFields[OfferengineMaxLoanAmount.fieldApiName] = offerEngineResponse !== undefined ?  offerEngineResponse.maxLoanAmt : '';
                    FinalTermFields[Loan_Amount.fieldApiName] = offerEngineResponse !== undefined ?  offerEngineResponse.displayLoanAmt.toString() : '';
                    FinalTermFields[OfferengineMinTenure.fieldApiName] = offerEngineResponse !== undefined ?  offerEngineResponse.minTenure : '';
                    FinalTermFields[OfferengineMaxTenure.fieldApiName] = offerEngineResponse !== undefined ?  offerEngineResponse.maxTenure : '';
                    FinalTermFields[Tenure.fieldApiName] = offerEngineResponse !== undefined ?  offerEngineResponse.displayTenure.toString() : '';
                    FinalTermFields[EMI_Amount.fieldApiName] = offerEngineResponse !== undefined ?  offerEngineResponse.displayEMI : '';
                    //SFTRAC-2283 Start
                    if(this.vehicleIntallmentType == 'Structured'){//SFTRAC-2362
                        FinalTermFields[Derived_CRM_IRR.fieldApiName] = offerEngineResponse !== undefined ?  offerEngineResponse.displayCrmIrr.toString() : ''; //SFTRAC-2301
                    }
                    else{
                    //SFTRAC-2283 End
                        FinalTermFields[Required_CRM_IRR.fieldApiName] = offerEngineResponse !== undefined ?  offerEngineResponse.displayCrmIrr.toString() : '';
                    }
                    FinalTermFields[Derived_CRM_IRR.fieldApiName] = offerEngineResponse !== undefined ?  offerEngineResponse.displayCrmIrr.toString() : '';
                    //Derived CRM IRR //SFTRAC-2301
                    FinalTermFields[Net_IRR.fieldApiName] = offerEngineResponse !== undefined ?  offerEngineResponse.netIrr : '';
                    FinalTermFields[Gross_IRR.fieldApiName] = offerEngineResponse !== undefined ?  offerEngineResponse.grossIrr : '';
                    FinalTermFields[Bank_IRR.fieldApiName] = offerEngineResponse !== undefined ?  offerEngineResponse.bankCrmIrr.toString() : '';
                    FinalTermFields[Offer_Agreement_Amount.fieldApiName] = offerEngineResponse !== undefined ?  offerEngineResponse.agreementAmount : '';

                    if(isPayInPayOutCompletedVar){
                        FinalTermFields[L1_Offer_Screen_Submitted.fieldApiName] = true;
                    }
        
                    console.log('++++Offer Engine Api FinalTermFields'+FinalTermFields);
                    
                    let res = this.updateRecordDetails(FinalTermFields);
                    if(res){
                        const evt = new ShowToastEvent({
                            title: 'Success',
                            message: "Offer Engine API Success",
                            variant: 'Success',
                        });
                        this.dispatchEvent(evt);
                        if(isPayInPayOutCompletedVar){
                            this.disableEverything();
                        }else{
                            const evt = new ShowToastEvent({
                                title: 'Warning',
                                message: "Kindly click on Change Payin And Payout button as it's mandatory!",
                                variant: 'warning',
                            });
                            this.dispatchEvent(evt);
                            this.isChangePayInOutButtonDisable = false;
                        }
                    }
                    this.isSpinnerMoving = false;
                })
                .catch(error => {
                    console.log('Error in Offer Engine API.', error);
                    const evt = new ShowToastEvent({
                        title: 'Error',
                        message: "Offer Engine API Failed",
                        variant: 'error',
                    });
                    this.dispatchEvent(evt);
                    this.isSpinnerMoving = false;
                });
            }catch(error){
                console.log('Error in Offer Engine API.', error);
                    const evt = new ShowToastEvent({
                        title: 'Error',
                        message: "Something went wrong!",
                        variant: 'error',
                    });
                    this.dispatchEvent(evt);
                    this.isSpinnerMoving = false;
                    this.disableSubmit = false; //SFTRAC-996
            }
        }

        showToastWarning(info) {
            const evt = new ShowToastEvent({
                title: "Warning",
                message: info,
                variant: "warning"
            });
            this.dispatchEvent(evt);
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
            allElements.forEach(element =>element.disabled = true);
        }

        async selectedSchemeRecord(){
            let checkSchemeValid = true;
            await loadSelectedSchemeData({ selectedSchemeId: this.selectedSchemeId })
            .then(result => {
                if (result) {
                    try {
                        if (result.Min_Loan_Amount_Not_Applicable__c===false && result.Loan_Amount_Min__c && result.Loan_Amount_Min__c> this.loanAmount) {
                            this.toastMsg('Finance Amount entered is below Scheme Min. Loan amount');
                            checkSchemeValid = false;
                        }
                        if (result.Max_Loan_amount_Not_Applicable__c===false && result.Loan_amount_Max__c && result.Loan_amount_Max__c < this.loanAmount) {
                            this.toastMsg('Finance Amount entered is above Scheme Max. Loan amount');
                            checkSchemeValid = false;
                        }
                        if (result.Min_Tenure_Not_Applicable__c===false && result.Tenure_Min_in_months__c && result.Tenure_Min_in_months__c > this.tenure) {
                            this.toastMsg('Tenure entered is below Scheme Min. Tenure');
                            checkSchemeValid = false;
                        }
                        if (result.Max_Tenure_Not_Applicable__c===false && result.Tenure_Max_in_months__c && result.Tenure_Max_in_months__c < this.tenure) {
                            this.toastMsg('Tenure entered is above Scheme Max. Tenure');
                            checkSchemeValid = false;
                        }
                    } catch (error) {
                        console.error('Error 11==> ',error);
                    }
                }
            }).catch(error=>{
                console.error('Error in loadSelectedSchemeData==> ',error);
            });
            return checkSchemeValid;
        }
    }