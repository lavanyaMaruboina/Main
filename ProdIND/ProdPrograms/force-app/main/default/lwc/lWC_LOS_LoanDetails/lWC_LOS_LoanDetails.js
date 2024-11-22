// Screen created By : Raj Gupta 
// Screen Name: 'LWC_LOS_LoanDetails'
// Description : All the loan details will capture here.
// created on: 10 DEC 2021

//import apex class and others 
import { LightningElement, track, api, wire } from 'lwc';
import { getRecord, updateRecord } from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { loadStyle } from 'lightning/platformResourceLoader';
import LightningCardCSS from '@salesforce/resourceUrl/loanApplication';

import checkRetryExhausted from '@salesforce/apex/IND_LWC_LoanDetailsCntrl.checkRetryExhausted';
import fetchLoanDetails from '@salesforce/apex/IND_LWC_LoanDetailsCntrl.fetchLoanDetails';
import calculatePrices from '@salesforce/apex/IND_LWC_LoanDetailsCntrl.calculatePrices';
import isCommunity from '@salesforce/apex/LwcLOSLoanApplicationCntrl.isCommunity';
import vehicleDetails from '@salesforce/apex/IND_LWC_LoanDetailsCntrl.getVehicleDetails';
import doCarwalePricesCallout from '@salesforce/apexContinuation/IntegrationEngine.doCarwalePricesCallout';
import updateApplicantSubStage from '@salesforce/apex/IND_LWC_LoanDetailsCntrl.updateApplicantSubStage';
import getLoanApplicationHistory from '@salesforce/apex/LwcLOSLoanApplicationCntrl.getLoanApplicationHistory';
import saveVehicleDetailsForTractor from '@salesforce/apex/IND_LWC_LoanDetailsCntrl.saveVehicleDetailsForTractor';

//custom Labels
import Regex_NumberOnly from '@salesforce/label/c.Regex_NumberOnly';
import Regex_DecimalNo from '@salesforce/label/c.Regex_DecimalNo';
import RequiredTenured2w from '@salesforce/label/c.RequiredTenured2w';
import RequiredLoanAmountMsg from '@salesforce/label/c.RequiredLoanAmountMsg';
import RequiredTenuredPv from '@salesforce/label/c.RequiredTenuredPv';
import DiscountMsg from '@salesforce/label/c.DiscountMsg';
import DiscountMsgPv from '@salesforce/label/c.DiscountMsgPv';
import RateOfInterestMsg from '@salesforce/label/c.RateOfInterestMsg';
import GstMsg from '@salesforce/label/c.GstMsg';
import eligibleTenureMsg from '@salesforce/label/c.eligibleTenureMsg';
import EligibleTenure from '@salesforce/label/c.EligibleTenure';
import eligibleLoanAmountmsg from '@salesforce/label/c.eligibleLoanAmount';
import PassengerVehicles from '@salesforce/label/c.PassengerVehicles';
import TwoWheeler from '@salesforce/label/c.TwoWheeler';
import Tractor from '@salesforce/label/c.Tractor';
import RetryExhausted from '@salesforce/label/c.Retry_Exhausted';
import discountNegativemsg from '@salesforce/label/c.discountNegativemsg';
import RequiredLoanAmountField from '@salesforce/label/c.Required_Loan_Amount';
import MaximumAvailableTenureField from '@salesforce/label/c.Maximum_Available_Tenure';
import RequiredTenureField from '@salesforce/label/c.Required_Tenure';
import RequiredROIField from '@salesforce/label/c.Required_ROI';
import FundingBasedOnField from '@salesforce/label/c.Funding_Based_on';
import FundedNonFundedField from '@salesforce/label/c.Funded_Non_Funded';
import YrInsurancePremiumField from '@salesforce/label/c.yr_Insurance_Premium';
import MotorInsurancePremiumField from '@salesforce/label/c.Motor_Insurance_Premium';
import BasicPriceField from '@salesforce/label/c.Basic_Price';
import GSTAmountField from '@salesforce/label/c.GST_Amount';
import DiscountOnBasicPriceField from '@salesforce/label/c.Discount_on_Basic_Price';
import ExShowroomPriceField from '@salesforce/label/c.Ex_showroom_price';
import InvoicePrice from '@salesforce/label/c.Invoice_Price';
import OtherChargesField from '@salesforce/label/c.Other_charges';
import KindlyRetryField from '@salesforce/label/c.Kindly_Retry';
import GetPriceDetailsField from '@salesforce/label/c.Get_Price_Details';
import ExShowroomPriceCarwaleField from '@salesforce/label/c.Ex_showroom_price_carwale';
import RTORoadTaxField from '@salesforce/label/c.RTO_Road_Tax';
import OnRoadPriceField from '@salesforce/label/c.On_Road_price';
import costOfBody from '@salesforce/label/c.costOfBody';
import costOfChassis from '@salesforce/label/c.costOfChassis';
import OnRoadPriceCarwaleField from '@salesforce/label/c.On_Road_price_carwale';
import SubmitField from '@salesforce/label/c.Submit';
import SaveAndExitField from '@salesforce/label/c.Save_and_Exit';
import UIM from '@salesforce/label/c.UIM';
import usedLabel from '@salesforce/label/c.used';
import newLabel from '@salesforce/label/c.new';
import RefinanceLabel from '@salesforce/label/c.Refinance';
import validValue from '@salesforce/label/c.validValue';
import detailsSaved from '@salesforce/label/c.detailsSaved';
import SuccessMessage from '@salesforce/label/c.SuccessMessage';
import Error_ContactAdmin from '@salesforce/label/c.Error_ContactAdmin'
import Please_fill_all_the_mandatory_fields from '@salesforce/label/c.Please_fill_all_the_mandatory_fields'

//fields are imported here
import OPP_ID_FIELD from '@salesforce/schema/Opportunity.Id';
import IS_LOAN_DETAILS_SUBMITTED_FIELD from '@salesforce/schema/Opportunity.Is_Loan_Details_Submitted__c';
import STAGENAME from '@salesforce/schema/Opportunity.StageName';
import LAST_STAGE_NAME from '@salesforce/schema/Opportunity.LastStageName__c';
import Required_Loan_amount from '@salesforce/schema/Opportunity.Required_Loan_amount__c';
import LOAN_AMOUNT from '@salesforce/schema/Opportunity.Loan_amount__c';
import Required_Tenure from '@salesforce/schema/Opportunity.Required_Tenure__c';
import Required_ROI from '@salesforce/schema/Opportunity.Required_ROI__c';
import Funding_on_Ex_Showroom from '@salesforce/schema/Opportunity.Funding_on_Ex_Showroom__c';
import fundingOnORP from '@salesforce/schema/Opportunity.Funding_on_ORP__c';
import custInterestedInInsurance from '@salesforce/schema/Opportunity.Is_customer_interested_in_a_motor_insura__c';
import Funded from '@salesforce/schema/Opportunity.Funded__c';
import Non_Funded from '@salesforce/schema/Opportunity.Non_Funded__c';
import Insurance_Premium from '@salesforce/schema/Opportunity.X1st_yr_Insurance_Premium__c';
import Motor_Insurance_Premium from '@salesforce/schema/Opportunity.Motor_Insurance_Premium__c';
import Basic_Price from '@salesforce/schema/Opportunity.Basic_Price__c';
import GST_Amount from '@salesforce/schema/Opportunity.GST_Amount__c';
import Discount_on_Basic_Price from '@salesforce/schema/Opportunity.Discount_on_Basic_Price__c';
import Ex_showroom_price from '@salesforce/schema/Opportunity.Ex_showroom_price__c';
import Ex_showroom_price_carwale from '@salesforce/schema/Opportunity.Ex_showroom_price_carwale__c';
import RTO_Road_Tax from '@salesforce/schema/Opportunity.RTO_Road_Tax__c';
import RTO_Road_Tax_New__c from '@salesforce/schema/Opportunity.RTO_Road_Tax_New__c';
import Other_charges from '@salesforce/schema/Opportunity.Other_charges__c';
import On_Road_price from '@salesforce/schema/Opportunity.On_Road_price__c';
import On_Road_price_carwale from '@salesforce/schema/Opportunity.On_Road_price_carwale__c';
import Final_Price from '@salesforce/schema/Opportunity.Final_Price__c';
import accessLoanApplication from '@salesforce/apex/LwcLOSLoanApplicationCntrl.accessLoanApplication';
import Loanamount10000 from '@salesforce/label/c.Loanamount10000';
import LoanAmount50000 from '@salesforce/label/c.LoanAmount50000';
import ReadOnlyLeadAccess from '@salesforce/label/c.ReadOnlyLeadAccess';
import RTO_Road_Tax_Error from '@salesforce/label/c.RTO_Road_Tax_Error';
import getLoanApplicationReadOnlySettings from '@salesforce/apex/LwcLOSLoanApplicationCntrl.getLoanApplicationReadOnlySettings';//Ola integration changes//
import roiMasterForImputedIRR from '@salesforce/apex/IND_OfferScreenController.roiMasterForImputedIRR';
import roiMasterTractor from '@salesforce/apex/IND_OfferScreenController.roiMasterTractor';
import getCurrentOppRecord from '@salesforce/apex/IND_RevokeController.getCurrentOppRecord';
import getPurchaseprice from '@salesforce/apex/IND_OfferScreenController.getPurchaseprice'; //SFTRAC-1299
export default class LWC_LOS_LoanDetails extends NavigationMixin(LightningElement) {
    isTWNew;
    rtoRoaTaxVal = 0;
    @api isRevokedLoanApplication;
    @api recordid;
    @api currentStage;
    @api exShowroomPriceCarwaledetail;
    @api basicPricedetail;
    @api discountOnBasicPriceDetail;
    @api gstAmountdetail;
    @api insurancePremiumDeatil;
    @api otherChargesDetail;
    @api rtoRoadTaxDetail;
    @api flagtocheckFundingdetail;
    @api flagtocheckCsddetail;
    @track currentStep;
    @track parentLeadRevoked = false;

    @track productSegment; //CISP-15787
    eScooter = false; //CISP-15787
    @api checkleadaccess;//coming from tabloanApplication
    coBorrowerId;
    isLoanDetailsSubmited = false;
    displayGetPricefields = true;
    isUsedOrRefinanceVehicleTypeFlag = false;
    displayMaximumAvailableTenure = false;
    disableRequiredLoanAmount = true;
    disableFundingBasedOnExShowroom = false;
    disableMotorInsurance;
    disabledExShowroom = false;
    disabledExShowPrice = true;
    disabledSubmit = true;
    disabledOrp;
    disableGetPrice = false;
    disabledMaximumAvailableTenure = false;
    isSpinnerMoving = false;
    flagtocheckSubmitBUttonClick = false;
    showNewLoanDetailsFields = false;
    newLoanDetailsFields = false;
    @track isEnableNext = false;
    csd = false;
    retryPopUp = false;
    displayFundingBasedOn = true;
    fundingOnExShowroom = false;
    orp = false;
    iconAPISuccess = false;
    iconAPIFailed = false;
    showIsThisCsdfields = false;
    showGetGrid = true;
    manufacturerYearMonth;
    finalPrice;
    productTypeDetail;
    vehicleSubCategoryDetail;
    vehicleTypeDetail;
    insuranceExpiring;
    funded;
    nonFunded;
    
    @track requiredRoi = '';
    checkMotorInsurance;
    onRoadPrice = 0;
    otherCharges = 0;
    percentageofGst;
    gstPercentageValue;
    percentageofDiscount;
    flagtocheckFunding;
    eligibleLoanAmount;
    eligibleTenure;
    vehicleAge;
    maxRoi;
    minRoi;
    fundingExShowRoomDetail;
    fundingOrpDetail;
    isCustomerInterestedInMotorinsura;
    @track currentStageName;
    @track lastStage;
    //Api parameters 
    vehicleTypeNo;
    cityCode = '';
    variantCode;
    leadId = '';
    isAPIFailed = false;
    retryCount = 0

    @track maxRoiTractor = 0;
    @track minRoiTractor = 0;
    @track maxTenureTractor = 0;
    @track minTenureTractor = 0;
    isNonIndividual=false;

    //Carwale Pricing fields
    @track gstAmount = 0;
    @track basicPrice = 0;
    @track discountOnBasicPrice = 0;
    @track exShowroomPricecarwale = 0;
    @track firstYrInsurancePremium = 0;
    @track motorInsurancePremium = 0;
    @track exShowroomPrice = 0;
    @track rtoRoadTax = 0;
    @track onRoadPricecarwale = 0;

    @track requiredTenureValue;
    @track requiredLoanAmount;
    @track maximumAvailableTenure;
    @track requiredTenureOptionsList;

    @track checkFunded;
    @track checkNoFunded;
    @track disabledFunded;
    @track disabledNonFunded;

    @track isEnableUploadViewDoc = true;
    @track showFileUploadAndView = false;
    //Ola integration changes
    @track leadSource;
    fameSubsidy;
    performanceUpgrade
    isLeadSourceOla = false;
    disabledFirstYrInsurancePremium = false;
    readOnlyFieldList = [];
    isTractor;
    offerEngineORPHero;//CISH-77
    //Ola Integration changes
    label = {
        validValue,
        SaveAndExitField,
        SubmitField,
        OnRoadPriceCarwaleField,
        OnRoadPriceField,
        RTORoadTaxField,
        ExShowroomPriceCarwaleField,
        GetPriceDetailsField,
        KindlyRetryField,
        OtherChargesField,
        ExShowroomPriceField,
        InvoicePrice,
        DiscountOnBasicPriceField,
        GSTAmountField,
        BasicPriceField,
        MotorInsurancePremiumField,
        YrInsurancePremiumField,
        FundedNonFundedField,
        FundingBasedOnField,
        RequiredROIField,
        RequiredTenureField,
        MaximumAvailableTenureField,
        RequiredLoanAmountField,
        Regex_NumberOnly,
        Regex_DecimalNo,
        RequiredTenured2w,
        RequiredLoanAmountMsg,
        RequiredTenuredPv,
        DiscountMsg,
        DiscountMsgPv,
        RateOfInterestMsg,
        GstMsg,
        eligibleTenureMsg,
        EligibleTenure,
        eligibleLoanAmountmsg,
        discountNegativemsg,
        LoanAmount50000,
        Loanamount10000,
        Error_ContactAdmin,
        Please_fill_all_the_mandatory_fields,
        costOfBody,
        costOfChassis
    };
    disableRequiredROIField = false; //Enhancement for INDI-4682 

    // CISP-2346
    @track isCarWaleApiFailed = false;
    @track isPassengerVehicle = false;
    @track isRtoRoadTaxFieldEnable = false;
    @track tractorVehicleList = [];
    @track vehiclePurchaseprice;
    isRtoRoadTaxFieldEnableFunction() {
        if (this.isTWNew || (this.isCarWaleApiFailed && this.isPassengerVehicle)) {
            this.isRtoRoadTaxFieldEnable = true;
        } else {
            this.isRtoRoadTaxFieldEnable = false;
        }
        console.log('isCarWaleApiFailed', this.isCarWaleApiFailed);
        console.log('isRtoRoadTaxFieldEnable ', this.isRtoRoadTaxFieldEnable);
    }
    // CISP-2346

    handleInput(event) {
        let index = event.currentTarget.dataset.index;
        let name = event.currentTarget.name;

        switch (name) {
            case 'costOfBody':
                this.tractorVehicleList[index].costOfBody = event.currentTarget.value;
                break;
            case 'costOfChassis':
                this.tractorVehicleList[index].costOfChassis = event.currentTarget.value;
                break;                    
            default:
                break;
        }
    }

    //CISP-15702 Start
    @wire(getRecord, { recordId: '$recordid', fields: ['Opportunity.UploadAndViewDocDisable__c']})
    wireOpportunityRec;
    get isUploadViewDisabled(){
        return this.wireOpportunityRec.data ? this.wireOpportunityRec.data.fields.UploadAndViewDocDisable__c.value : false;
    }
    //CISP-15702 End
    
    async connectedCallback() {

        var tenuredList = new Array();

        await getCurrentOppRecord({'loanApplicationId' : this.recordid}).then(result=>{
            if(result && result.length > 0 && result[0].Parent_Loan_Application__r?.Is_Revoked__c == true){
                this.parentLeadRevoked = true;
            }
        }).catch(error=>{});

        await fetchLoanDetails({ opportunityId: this.recordid }).then(result => {
            console.log('Fetch Loan Details:: ', JSON.stringify(result));

            this.productTypeDetail = result?.loanApplicationDetails[0]?.Product_Type__c;
            this.isTractor = this.productTypeDetail.toLowerCase() === Tractor.toLowerCase();
            this.vehicleTypeDetail = result?.loanApplicationDetails[0]?.Vehicle_Type__c;
            this.requiredLoanAmount = result?.loanApplicationDetails[0]?.Loan_amount__c;
            this.leadSource = result?.loanApplicationDetails[0]?.LeadSource;//Ola Integration changes
            this.offerEngineORPHero = result?.loanApplicationDetails[0]?.Final_Terms__r != null ? result?.loanApplicationDetails[0]?.Final_Terms__r[0]?.Offerengine_On_Road_Price__c : null;//CISH-77
            this.gstPercentageValue = result?.gstPercentage;

            if (this.isTractor) {
                roiMasterTractor({'loanApplicationId' : this.recordid}).then((roiResult)=>{
                    if(roiResult){
                        this.maxRoiTractor = roiResult.CRM_IRR_MAX;
                        this.minRoiTractor = roiResult.CRM_IRR_MIN;
                        this.maxTenureTractor = roiResult.TENURE_MAX;
                        this.minTenureTractor = roiResult.TENURE_MIN;
                        this.isNonIndividual = roiResult.isNonIndividual;
                    }else{
                        this.showToastMessageModeBased('Missing ROI Master Details', this.label.Error_ContactAdmin, 'error', 'sticky');
                        this.maxRoiTractor = 0;
                        this.minRoiTractor = 0;
                        this.maxTenureTractor = 0;
                        this.minTenureTractor = 0;
                        this.isNonIndividual = true;
                    }
                }).catch((error)=>console.log("Error in", "roiMasterTractor", error));
                let vehicleDetails = result?.loanApplicationDetails[0]?.Vehicle_Details__r;
                let LoanAppRecord = result?.loanApplicationDetails[0];
                this.currentStageName = result?.loanApplicationDetails[0]?.StageName;
                this.lastStage = result?.loanApplicationDetails[0]?.LastStageName__c;

                let objList = [];
                let i = 1;
                vehicleDetails.forEach((element) => {
                    let obj = new Object();
                    obj.sectionLabel = element.Make__c + ' ' + element.Model__c + ' ' + element.Variant__c;
                    obj.sectionName = i;
                    obj.recordId = element.Id;
                    obj.vehicleSubType = element.Vehicle_SubType__c;
                    obj.isLoanDetailsSubmited = LoanAppRecord.Is_Loan_Details_Submitted__c;
                    obj.requiredLoanAmount = element.Loan_Amount__c;
                    obj.requiredLoanAmountId = 'requiredLoanAmount' + i;
                    obj.requiredTenure = element.Required_Tenure__c;
                    obj.requiredTenureId = 'requiredTenure' + i;
                    obj.requiredCRMIRRTW = element.Required_CRM_IRR__c;
                    obj.fundingInvoiceAmount = true;
                    obj.funded = element.Funded__c;
                    obj.nonFunded = element.Non_Funded__c;
                    obj.firstYrInsurancePremium = element.X1st_yr_Insurance_Premium__c;
                    obj.isCustomerInterested = element.Is_Customer_Interested_in_MotorInsurance__c;
                    obj.gstAmount = element.GST_Amount__c;
                    obj.gstAmountId = 'gstAmount' + i;
                    obj.invoicePrice = element.Invoice_Price__c;
                    obj.basicPrice = element.Basic_Price__c;
                    obj.vehicleTypeDetail = element.Vehicle_type__c;
                    obj.manufacturerYearMonth = element.Manufacturer_Year_Month__c;
                    obj.firstYearInsuranceRequired = obj.isCustomerInterested && obj.nonFunded ? true : false;
                    obj.costOfBody = element.Cost_of_the_body__c;
                    obj.costOfChassis = element.Cost_of_the_Chassis__c;
                    obj.showCostInfo = false;
                    obj.showBasicPrice = true;
                    if (this.vehicleTypeDetail === 'New' && LoanAppRecord.Application_Type__c === 'Build Body and Chassis Funding') {
                        obj.showCostInfo = true;
                    }
                    if (obj.vehicleTypeDetail === 'Used' || obj.vehicleTypeDetail === 'Refinance') {
                        //obj.newLoanDetailsFields = false;
                        obj.showBasicPrice = false;
                        let tenuredList = [];
                        for (let i = 6; i <= 60; i += 6) {
                            tenuredList.push({
                                label: parseInt(i, 10),
                                value: parseInt(i, 10)
                            });
                        }
                        obj.requiredTenureOptionsList = tenuredList;
                        if (obj.manufacturerYearMonth) {
                            let currentTime = new Date();
                            let monthAndYear = obj.manufacturerYearMonth?.split('-');
                            let year = currentTime.getFullYear();
                            let month = currentTime.getMonth();
                            let age = Math.abs(year - monthAndYear[0]);
                            let ageofVehicles = Math.abs((age * 12 - (monthAndYear[1])));
                            obj.vehicleAge = Math.abs(ageofVehicles + month);
                        }

                    } else {
                        //obj.newLoanDetailsFields = true;
                        let tenuredList = [];
                        for (let i = 6; i <= 84; i += 6) {
                            tenuredList.push({
                                label: parseInt(i, 10),
                                value: parseInt(i, 10)
                            });
                        }
                        obj.requiredTenureOptionsList = tenuredList;
                    }

                    obj.disableRequiredLoanAmount = obj.isLoanDetailsSubmited;
                    obj.disableRequiredTenure = obj.isLoanDetailsSubmited;
                    obj.disableRequiredROIField = obj.isLoanDetailsSubmited;
                    obj.disabledFunded = obj.isLoanDetailsSubmited ? true : obj.nonFunded;
                    obj.disabledNonFunded = obj.isLoanDetailsSubmited ? true : obj.funded;
                    obj.disabledFirstYrInsurancePremium = obj.isLoanDetailsSubmited;
                    //SFTRAC-910 Starts
                    console.log('++++++isCustomerInterested '+obj.isCustomerInterested);
                    console.log('++++++obj.funded '+obj.funded+' this.nonFunded '+obj.nonFunded);
                    console.log('++++++disabledFunded1 '+obj.disabledFunded+' this.disabledNonFunded '+obj.disabledNonFunded);
                    if(obj.isCustomerInterested == true){
                        obj.disabledFunded = false;
                        obj.disabledNonFunded = false;
                    }else{
                        obj.disabledFunded = true;
                        obj.disabledNonFunded = true;
                    }//SFTRAC-910 Ends
                    objList.push(obj);
                    i++;
                });
                this.tractorVehicleList = objList;
                if(this.currentStageName === 'Loan Details' && this.lastStage === 'Loan Details'){
                    this.disabledSubmit = false;
                }
            } else {
                this.isLoanDetailsSubmited = result?.loanApplicationDetails[0]?.Is_Loan_Details_Submitted__c;
                this.leadId = result?.loanApplicationDetails[0]?.Name;

                this.fundingExShowRoomDetail = result?.loanApplicationDetails[0]?.Funding_on_Ex_Showroom__c;
                this.fundingOrpDetail = result?.loanApplicationDetails[0]?.Funding_on_ORP__c;

                this.isCustomerInterestedInMotorinsura = result?.loanApplicationDetails[0]?.Is_customer_interested_in_a_motor_insura__c;
                this.currentStageName = result?.loanApplicationDetails[0]?.StageName;
                this.lastStage = result?.loanApplicationDetails[0]?.LastStageName__c;
                this.rtoRoaTaxVal = result?.loanApplicationDetails[0]?.RTO_Road_Tax_New__c;
                this.leadSource = result?.loanApplicationDetails[0]?.LeadSource;//Ola Integration changes
                this.fameSubsidy = result?.loanApplicationDetails[0]?.FAME_Subsidy__c;//Ola Integration changes
                this.performanceUpgrade = result?.loanApplicationDetails[0]?.Performance_Upgrade__c;//Ola Integration changes
                let requiredCRMIRRTW = result?.crmIRRTW;
                let leadsource = result?.loanApplicationDetails[0]?.LeadSource;
                
                if (this.productTypeDetail == 'Two Wheeler' && this.vehicleTypeDetail == 'New') {
                    console.log('when product type two wheeler and new  : ',);
                    this.isTWNew = true;
                } else {
                    this.isTWNew = false;
                }

                if (this.productTypeDetail != 'Tractor') {
                    //Retry Count check
                    if (result?.retryCountDetails) {
                        this.isAPIFailed = result?.retryCountDetails[0]?.IsAPIFailed__c;
                        this.retryCount = result?.retryCountDetails[0]?.Count__c;
                    } else {
                        this.isAPIFailed = false;
                        this.retryCount = 0;
                    }

                    if (this.isAPIFailed === true && this.retryCount >= 3) {
                        this.iconAPIFailed = true;
                        if(this.currentStageName === 'Loan Details' && this.lastStage === 'Loan Details'){
                            this.disableGetPrice = true;
                            this.disabledSubmit = false;
                        }
                        this.isCarWaleApiFailed = true;// CISP-2346
                    } else if (this.isAPIFailed === false && this.retryCount >= 3) {
                        this.iconAPISuccess = true;
                        if(this.currentStageName === 'Loan Details' && this.lastStage === 'Loan Details'){
                            this.disableGetPrice = true;
                            this.disabledSubmit = false;
                        }
                        this.isCarWaleApiFailed = false;// CISP-2346
                    }
                    if(this.currentStageName === 'Loan Details' && this.lastStage === 'Loan Details'){
                        this.disableGetPrice = false;
                    }
                    // CISP-2346
                    if(this.productTypeDetail == PassengerVehicles){
                        this.isPassengerVehicle = true;
                    }
                    this.isRtoRoadTaxFieldEnableFunction();
                }
                // CISP-2346

                this.updateFetchedDetails(result);

                //Disable Record Input if record is Submited
                if (this.isLoanDetailsSubmited) {
                    this.disableRecordInput('lightning-input');
                    this.disableRecordInput('lightning-combobox');
                    this.disableGetPrice = true;
                    this.disabledSubmit = true;
                }

                //Other Inputs for Processing
                this.gstPercentageValue = result?.gstPercentage;
                this.cityCode = result?.citycode;
                this.variantCode = result?.variantcode;
                console.log('isLoanDetailsSubmited:: ', this.isLoanDetailsSubmited);
                console.log('Vehicle Tpye:: ', this.vehicleTypeDetail);
                console.log('Prod:: ', this.fundingExShowRoomDetail);
                console.log('GST Id:: ', this.fundingOrpDetail);
                console.log('City Code:: ', this.cityCode);
                console.log('Variant Code:: ', this.variantCode);
                console.log('isAPIFailed:: ', this.isAPIFailed);
                console.log('Retry Count:: ', this.retryCount);
                if (this.vehicleTypeDetail === 'Used' || this.vehicleTypeDetail === 'Refinance') {
                    console.log('City Covcvcvde:: ', this.vehicleTypeDetail);
                    this.newLoanDetailsFields = false;
                    this.displayMaximumAvailableTenure = true;
                    //this.displayFundingBasedOn = true;
                    this.motorInsurancePremiumTemp = true;
                    this.displayGetPricefields = false;
                    this.showNewLoanDetailsFields = false;
                    this.orp = false;
                    this.showIsThisCsdfields = false;
                } else if (this.vehicleTypeDetail === 'New') {
                    console.log('City new:: ', this.vehicleTypeDetail);
                    this.displayMaximumAvailableTenure = false;
                    this.newLoanDetailsFields = true;
                    this.displayFundingBasedOn = true;
                    this.motorInsurancePremiumTemp = false;
                    this.showNewLoanDetailsFields = true;

                    if (this.fundingOrpDetail === true) {
                        this.orp = true;
                    } else {
                        this.orp = false;
                    }
                    this.displayGetPricefields = true;
                    this.showIsThisCsdfields = true;
                }

                if (this.fundingExShowRoomDetail === true) {
                    console.log('ex showroom:: ', this.fundingExShowRoomDetail);
                    this.disabledOrp = true;
                    this.disableFundingBasedOnExShowroom = false;
                    this.disabledNonFunded = true;
                    let orpInput = this.template.querySelector('lightning-input[data-id=orp]');
                    orpInput.checked = false;
                } else if (this.fundingOrpDetail === true) {
                    console.log('ORP om:: ', this.isCustomerInterestedInMotorinsura);
                    let orpInput = this.template.querySelector('lightning-input[data-id=orp]');
                    orpInput.checked = true;
                    this.disabledOrp = false;
                    this.disableFundingBasedOnExShowroom = true;
                    this.disabledFunded = true;
                }

                if (this.productTypeDetail == 'Two Wheeler' && this.leadSource != 'OLA' && this.leadSource != 'Hero'){//Ola integration changes. UAT bug.
                    this.disableMotorInsurance = true; //cisp-4298 disabled motor insurance for two wheeler
                    this.disabledFunded = true;
                    this.disabledNonFunded = true;
                    this.disableFundingBasedOnExShowroom = true; //cisp-6667
                    this.disabledOrp = true;
                    this.orp = true;
                    this.requiredRoi = 22; //Enhancement for INDI-4682 
                    
                    if (leadsource && leadsource == 'D2C') {
                        this.requiredRoi = requiredCRMIRRTW;//D2C
                    }

                    this.disableRequiredROIField = true; //Enhancement for INDI-4682 
                }
                if (this.cityCode === undefined && this.currentStage != 'Credit Processing') {
                    this.showToastMessageModeBased('Missing City Details', this.label.Error_ContactAdmin, 'error', 'sticky');
                }


                if (this.productTypeDetail != 'Tractor' && this.variantCode === undefined && this.currentStage != 'Credit Processing') {
                    let selectedVariant = result?.loanApplicationDetails[0].Vehicle_Details__r[0]?.Variant__c;

                    if (selectedVariant === undefined && this.currentStage != 'Credit Processing') {
                        this.showToastMessageModeBased('Missing Varaint Details', this.label.Error_ContactAdmin, 'error', 'sticky');
                    }
                    this.showToastMessageModeBased('Missing Variant Code for ' + selectedVariant, this.label.Error_ContactAdmin, 'error', 'sticky');
                }

                //ROI Masters
                if (this.productTypeDetail == 'Two Wheeler') {
                    this.maxRoi = result?.maxValue;
                    this.minRoi = result?.minValue;
                    if (this.maxRoi === undefined || this.minRoi === undefined) {
                        this.showToastMessageModeBased('Missing ROI Master Details', this.label.Error_ContactAdmin, 'error', 'sticky');
                        this.maxRoi = 0;
                        this.minRoi = 0;
                    }
                    console.log('Max ROI:: ', this.maxRoi);
                    console.log('Min ROI:: ', this.minRoi);
                }

                //Process Used Vehicle Type Details
                if (this.vehicleTypeDetail == 'Used' || this.vehicleTypeDetail == RefinanceLabel) {
                    //Get Used Vehicle Details
                    this.manufacturerYearMonth = result?.loanApplicationDetails[0]?.Vehicle_Details__r[0].Manufacturer_Year_Month__c;
                    this.eligibleLoanAmount = result?.loanApplicationDetails[0]?.Vehicle_Details__r[0].Eligible_Loan_Amount__c;
                    this.eligibleTenure = result?.loanApplicationDetails[0]?.Vehicle_Details__r[0].Eligible_Tenure__c;
                    this.insuranceExpiring = result?.loanApplicationDetails[0]?.Vehicle_Details__r[0].Insurance_expiring_within_60_days__c;

                    //Madatory Vehicle Sub-Category Check
                    this.vehicleSubCategoryDetail = result?.loanApplicationDetails[0]?.Vehicle_Sub_Category__c;
                    if (this.vehicleSubCategoryDetail === undefined) {
                        this.showToastMessageModeBased('Missing Vehicle Sub-Category Details', this.label.Error_ContactAdmin, 'error', 'sticky');
                        return;
                    }

                    //If Vehicle Type is Used and Sub Category is UIM then Keep the field Enabled
                    if (this.vehicleSubCategoryDetail === UIM) {
                        this.disableRequiredLoanAmount = false;
                    }
                    //Age if vehicle Calculations1
                    let currentTime = new Date();
                    let monthAndYear = this.manufacturerYearMonth.split('-');
                    let year = currentTime.getFullYear();
                    let month = currentTime.getMonth();
                    let ageofVehicles = 0;
                    if(monthAndYear.length > 0 && monthAndYear[0].length == 4){
                        let age = Math.abs(year - monthAndYear[0]);
                        ageofVehicles= Math.abs((age * 12 - (monthAndYear[1])));
                    }
                    else if(monthAndYear.length > 0){
                        let age = Math.abs(year - monthAndYear[1]);
                        ageofVehicles= Math.abs((age * 12 - (monthAndYear[0])));
                    }
                    this.vehicleAge = Math.abs(ageofVehicles + month);
                }

                //Used or Refinance Vehicle Type
                if (this.vehicleTypeDetail.toLowerCase() === usedLabel.toLowerCase() || this.vehicleTypeDetail.toLowerCase() === RefinanceLabel.toLowerCase()) {
                    this.isUsedOrRefinanceVehicleTypeFlag = true;
                    this.showGetGrid = false;
                    this.disabledSubmit = false;
                    //In Insurance Expiring then Hide Funding Based on Option
                    if (this.insuranceExpiring === false) {
                        this.displayFundingBasedOn = false;
                        this.template.querySelector('lightning-input[data-id=custInterestedInInsuranceId]').checked = false;
                        this.disableMotorInsurance = true;
                        this.handlefundedNonFunded();
                        this.template.querySelector('lightning-input[data-id=fundedId]').checked = false;
                        if (this.leadSource != 'D2C') {
                            this.template.querySelector('lightning-input[data-id=nonFundedId]').checked = true;
                        }
                        this.disabledFunded = true;
                        this.disabledNonFunded = true;
                    } else {
                        this.displayFundingBasedOn = false;
                        this.disableMotorInsurance = false;
                        let motorInsuranceInput = this.template.querySelector('lightning-input[data-id=custInterestedInInsuranceId]');
                        this.checkMotorInsurance = motorInsuranceInput.checked;
                        if (this.checkMotorInsurance === false) {
                            this.template.querySelector('lightning-input[data-id=fundedId]').checked = false;
                            if (this.leadSource != 'D2C') {
                                this.template.querySelector('lightning-input[data-id=nonFundedId]').checked = true;
                            }
                            this.disabledFunded = true;
                            this.disabledNonFunded = true;
                        } else {
                            if (this.leadSource != 'D2C') {
                                this.template.querySelector('lightning-input[data-id=fundedId]').checked = false;
                                this.template.querySelector('lightning-input[data-id=nonFundedId]').checked = false;
                                this.disabledFunded = false;
                                this.disabledNonFunded = false;
                            }
                        }
                    }
                } else {
                    //New Vehicle Type
                    this.displayFundingBasedOn = true;
                    this.isUsedOrRefinanceVehicleTypeFlag = false;
                }

                if (this.vehicleTypeDetail.toLowerCase() === usedLabel.toLowerCase() || this.vehicleTypeDetail.toLowerCase() === RefinanceLabel.toLowerCase()) {
                    this.displayMaximumAvailableTenure = true;
                    if (this.vehicleSubCategoryDetail !== UIM) {
                        if (this.productTypeDetail === PassengerVehicles) {
                            this.maximumAvailableTenure = (15 * 12) - this.vehicleAge; // CISP-4102 -changed 12 years to 15 years
                            this.disabledMaximumAvailableTenure = true;
                        } else {
                            this.maximumAvailableTenure = (5 * 12) - this.vehicleAge;
                            this.disabledMaximumAvailableTenure = true;
                        }
                    } else {
                        this.maximumAvailableTenure = this.eligibleTenure;
                        this.disabledMaximumAvailableTenure = true;
                    }
                }
            }
            //CISP-4225 changes
            if (this.productTypeDetail.toLowerCase() === PassengerVehicles.toLowerCase()) {
                if(this.vehicleTypeDetail.toLowerCase() === usedLabel.toLowerCase() || this.vehicleTypeDetail.toLowerCase() === RefinanceLabel.toLowerCase()){
                    for (let i = 6; i <= 84; i++) {
                        tenuredList.push({
                            label: parseInt(i, 10),
                            value: parseInt(i, 10)
                        });
                    }
                }else if(this.vehicleTypeDetail.toLowerCase() === newLabel.toLowerCase()){
                    for (let i = 6; i <= 96; i++) {
                        tenuredList.push({
                            label: parseInt(i, 10),
                            value: parseInt(i, 10)
                        });
                    }
                }
                this.requiredTenureOptionsList = tenuredList;
            } else if (this.productTypeDetail.toLowerCase() === TwoWheeler.toLowerCase() && (this.vehicleTypeDetail.toLowerCase() === usedLabel.toLowerCase() || this.vehicleTypeDetail.toLowerCase() === newLabel.toLowerCase())) {
                if(this.requiredLoanAmount > 90000){//CISP-20773
                    for (let i = 6; i <= 48; i += 6) { 
                        tenuredList.push({
                            label: parseInt(i, 10),
                            value: parseInt(i, 10)
                        });
                }
            }else{
                for (let i = 6; i <= 36; i += 6) { //CISP-2782 - changed i increment value to 6
                    tenuredList.push({
                        label: parseInt(i, 10),
                        value: parseInt(i, 10)
                    });
                }
            }
                this.requiredTenureOptionsList = tenuredList;
            }
            // else if (this.productTypeDetail.toLowerCase() === PassengerVehicles.toLowerCase() && this.vehicleTypeDetail.toLowerCase() === RefinanceLabel.toLowerCase()) {
            //     for (let i = 12; i <= 36; i += 6) {
            //         tenuredList.push({
            //             label: parseInt(i, 10),
            //             value: parseInt(i, 10)
            //         });

            //     }
            //     this.requiredTenureOptionsList = tenuredList;
            //}
            else if (this.productTypeDetail.toLowerCase() === TwoWheeler.toLowerCase() && this.vehicleTypeDetail.toLowerCase() === RefinanceLabel.toLowerCase()) {
                for (let i = 6; i <= 36; i += 6) { //CISP-2782 - changed i initialization to 6 from 12
                    tenuredList.push({
                        label: parseInt(i, 10),
                        value: parseInt(i, 10)
                    });
                }

                tenuredList.push({
                    label: parseInt(48, 10),
                    value: parseInt(48, 10)
                });
                this.requiredTenureOptionsList = tenuredList;
            }

            if (this.productTypeDetail != 'Tractor') {
                this.calculateCarwalePrices(false);
            }
        }).catch(error => {
            console.log("Error in Getting Loan Details:: ", error);
            this.showToastMessage('Error', this.label.Error_ContactAdmin, 'error');
        });

        await vehicleDetails({oppId: this.recordid})
        .then((response) => {
            console.log('vehicleDetails::',response);
            this.productSegment = response.Product_Segment__c;
            if(this.productSegment != null && this.productSegment != '' && this.productSegment.toLowerCase() ==='ESCOOTER'.toLowerCase()){
                this.eScooter = true;
            }
        })
        .catch((error) => {
            const evt = new ShowToastEvent({
                title: 'Error',
                message: error.body.message,
                variant: 'Error',
            });
            this.dispatchEvent(evt);
        });

        //Ola integration changes
        await getLoanApplicationReadOnlySettings({ leadSource: this.leadSource })
            .then(data => {
                let fieldList = []; if (data) { fieldList = data.Input_Labels__c.split(';'); }
                this.readOnlyFieldList = fieldList;

                if (fieldList.length > 0) {
                    this.isLeadSourceOla = this.leadSource == 'OLA' ? true : false;
                    this.disableRequiredLoanAmount = fieldList.includes('Required Loan Amount') ? true : this.disableRequiredLoanAmount;
                    this.disableRequiredTenure = fieldList.includes('Required Tenure') ? true : this.disableRequiredTenure;
                    this.disableRequiredROIField = fieldList.includes('CRM IRR') ? true : this.disableRequiredROIField;
                    this.disableFundingBasedOnExShowroom = fieldList.includes('Funding based on') ? true : this.disableFundingBasedOnExShowroom;
                    this.disabledOrp = fieldList.includes('Funding based on') ? true : this.disabledOrp;
                    this.disableMotorInsurance = fieldList.includes('Is customer interested in motor insurance') ? true : this.disableMotorInsurance;
                    this.disabledFunded = fieldList.includes('Funded') ? true : this.disabledFunded;
                    this.disabledNonFunded = fieldList.includes('Funded') ? true : this.disabledNonFunded;
                    this.disabledOrp = fieldList.includes('ORP') ? true : this.disabledOrp;
                    this.disableMotorInsurance = fieldList.includes('Motor Insurance') ? true : this.disableMotorInsurance;
                    this.disabledSubmit = false;
                    this.isRtoRoadTaxFieldEnable = true;

                    if (this.template.querySelector('lightning-input[data-id=rtoRoaTaxVal]')) {
                        this.template.querySelector('lightning-input[data-id=rtoRoaTaxVal]').disabled = true;//OLA-127
                    }
                    this.disableGetPrice = true;

                    this.fundingOnExShowroom = false;
                    this.orp = true;
                }
            }).catch(error => {
                this.isLoading = false;
            });
        //Ola Integration changes
        if (this.isRtoRoadTaxFieldEnable) {//CISP-2346
            this.calculateORP();
        } else if (this.iconAPISuccess) {//CISP-4730
            this.calculateORPCarWale();
        }

        if (!this.isTractor) {
            let elem = this.template.querySelector('lightning-input[data-id=reqLoan]');
            elem.setCustomValidity("");
            if (this.productTypeDetail.toLowerCase() === TwoWheeler.toLowerCase()) {
                if (this.requiredLoanAmount && (this.requiredLoanAmount < parseInt(Loanamount10000, 10) || this.requiredLoanAmount > parseInt(this.eligibleLoanAmount, 10))) {
                    elem.setCustomValidity(this.label.eligibleLoanAmountmsg);
                }
            } else if (this.productTypeDetail.toLowerCase() === PassengerVehicles.toLowerCase()) {
                if (this.requiredLoanAmount && (this.requiredLoanAmount < parseInt(LoanAmount50000, 10) || this.requiredLoanAmount > parseInt(this.eligibleLoanAmount, 10))) {
                    elem.setCustomValidity(this.label.eligibleLoanAmountmsg);
                }
            } else if (this.productTypeDetail.toLowerCase() === Tractor.toLowerCase()) {
                if (this.requiredLoanAmount && (this.requiredLoanAmount < parseInt(LoanAmount50000, 10) || this.requiredLoanAmount > parseInt(this.eligibleLoanAmount, 10))) {
                    elem.setCustomValidity(this.label.eligibleLoanAmountmsg);
                }
            }
            elem.reportValidity();
        }


        this.callAccessLoanApplication();//m4
        //Hero CISH-2
        let fieldList = this.readOnlyFieldList;
        if(this.leadSource=='Hero' && this.readOnlyFieldList.length>0){
            //this.disabledFirstYrInsurancePremium = true;
            this.template.querySelector('lightning-input[data-id=InsPrem]').disabled = fieldList.includes('1st year insurance premium')? true :false;
            this.template.querySelector('lightning-input[data-id=fundedId]').checked = true;
            this.template.querySelector('lightning-input[data-id=nonFundedId]').checked = false;
            this.template.querySelector('lightning-input[data-id=otherchar]').disabled = fieldList.includes('Other charges')? true :false;
            this.template.querySelector('lightning-input[data-id=exshowpriceTWNew]').disabled = fieldList.includes('Ex-showroom price')? true :false;
        }
        //Hero CISH-2
    }

    //Fetched details when Loan Details are saved
    updateFetchedDetails(result) {
        console.log('Loading Data:: ', result);
        //Section 1
        this.requiredLoanAmount = result?.loanApplicationDetails[0]?.Loan_amount__c;
        this.requiredTenureValue = result?.loanApplicationDetails[0]?.Required_Tenure__c;
        if (this.productTypeDetail.toLowerCase() !== TwoWheeler.toLowerCase() || this.leadSource==='OLA' || this.leadSource === 'Hero') { //Enhancement for INDI-4682 //OLA-15 && CISH-09
            this.requiredRoi = result?.loanApplicationDetails[0]?.Required_ROI__c;
        }

        //Section 2
        this.fundingOnExShowroom = result?.loanApplicationDetails[0]?.Funding_on_Ex_Showroom__c;
        this.fundingOnORP = result?.loanApplicationDetails[0]?.Funding_on_ORP__c;
        this.custInterestedInInsurance = result?.loanApplicationDetails[0]?.Is_customer_interested_in_a_motor_insura__c;
        this.funded = result?.loanApplicationDetails[0]?.Funded__c;
        this.nonFunded = result?.loanApplicationDetails[0]?.Non_Funded__c;

        //Section 3
        this.firstYrInsurancePremium = result?.loanApplicationDetails[0]?.X1st_yr_Insurance_Premium__c;
        this.motorInsurancePremium = result?.loanApplicationDetails[0]?.Motor_Insurance_Premium__c;
        this.basicPrice = result?.loanApplicationDetails[0]?.Basic_Price__c;
        this.gstAmount = result?.loanApplicationDetails[0]?.GST_Amount__c;
        this.discountOnBasicPrice = result?.loanApplicationDetails[0]?.Discount_on_Basic_Price__c;
        this.exShowroomPrice = result?.loanApplicationDetails[0]?.Ex_showroom_price__c
        this.otherCharges = result?.loanApplicationDetails[0]?.Other_charges__c;

        if (this.productTypeDetail != 'Tractor') {
            //Section 4
            this.exShowroomPricecarwale = result?.loanApplicationDetails[0]?.Ex_showroom_price_carwale__c;
            if (this.productTypeDetail == PassengerVehicles && this.isCarWaleApiFailed == false) {//CISP-6540
                this.rtoRoadTax = result?.loanApplicationDetails[0]?.RTO_Road_Tax_New__c;
            } else {
                this.rtoRoadTax = result?.loanApplicationDetails[0]?.RTO_Road_Tax__c;
            }
            this.onRoadPrice = result?.loanApplicationDetails[0]?.On_Road_price__c;
            this.onRoadPricecarwale = result?.loanApplicationDetails[0]?.On_Road_price_carwale__c;
        }


        //this.exShowroomPricecarwale = parseInt(result.Ex_showroom_price_carwale__c,10);
        //Picklist Options Update
        if (this.requiredTenureValue && this.isLoanDetailsSubmited) {
            this.requiredTenureOptionsList = [{ label: this.requiredTenureValue, value: this.requiredTenureValue }];
        }

        //CheckBox Update
        if (this.vehicleTypeDetail.toLowerCase() === usedLabel.toLowerCase() || this.vehicleTypeDetail.toLowerCase() === RefinanceLabel.toLowerCase()) {
            //this.displayFundingBasedOn = false;
        } else {
            //Update Funding Based on in a case of New Vehicle Type only
            if (this.fundingOnExShowroom) {
                this.displayFundingBasedOn = true;
                let fundingBasedOnExShowrromInput = this.template.querySelector('lightning-input[data-id=fundingBasedOnExShowroomId]');
                if (fundingBasedOnExShowrromInput) {
                    fundingBasedOnExShowrromInput.checked = true;
                }
                this.disabledOrp = true;
            }

            if (this.fundingOnORP) {
                this.displayFundingBasedOn = true;
                let orpInput = this.template.querySelector('lightning-input[data-id=orp]');
                if (orpInput) {
                    orpInput.checked = true;
                }
                this.disableFundingBasedOnExShowroom = true;
            }
        }

        if (this.custInterestedInInsurance) {
            let motorInsuranceInput = this.template.querySelector('lightning-input[data-id=custInterestedInInsuranceId]');
            if (motorInsuranceInput) {
                motorInsuranceInput.checked = true;
            }
        }

        if (this.funded) {
            let fundedInput = this.template.querySelector('lightning-input[data-id=fundedId]');
            if (fundedInput) {
                fundedInput.checked = true;
            }
            this.disabledNonFunded = true;
        }

        if (this.nonFunded) {
            let nonfundedInput = this.template.querySelector('lightning-input[data-id=nonFundedId]');
            if (nonfundedInput) {
                nonfundedInput.checked = true;
            }
            this.disabledFunded = true;
        }

        //Convert field into Int format
        if (this.requiredLoanAmount) {
            this.requiredLoanAmount = parseInt(this.requiredLoanAmount, 10);
        }

        //Undefined Check         
        if (this.firstYrInsurancePremium === undefined) {
            this.firstYrInsurancePremium = 0;
        }
        if (this.motorInsurancePremium === undefined) {
            this.motorInsurancePremium = 0;
        }
        if (this.basicPrice === undefined) {
            this.basicPrice = 0;
        }
        if (this.gstAmount === undefined) {
            this.gstAmount = 0;
        }
        if (this.discountOnBasicPrice === undefined) {
            this.discountOnBasicPrice = 0;
        }
        if (this.exShowroomPrice === undefined) {
            this.exShowroomPrice = 0;
        }
        if (this.otherCharges === undefined) {
            this.otherCharges = 0;
        }
        if (this.exShowroomPricecarwale === undefined) {
            this.exShowroomPricecarwale = 0;
        }
        if (this.rtoRoadTax === undefined) {
            this.rtoRoadTax = 0;
        }
        if (this.onRoadPrice === undefined) {
            this.onRoadPrice = 0;
        }
        if (this.onRoadPricecarwale === undefined) {
            this.onRoadPricecarwale = 0;
        }

    }

    disableRecordInput(query) {
        this.template.querySelectorAll(query).forEach(item => {
            item.disabled = true;
        });
    }


    handleRTOChange(event) {
        let rtoRoaTaxVal = event.target.value; //CISP-6540 start  
        if (this.productTypeDetail == PassengerVehicles) {
            this.rtoRoaTaxVal = rtoRoaTaxVal;
            const loanDetailsFields = {};
        loanDetailsFields[OPP_ID_FIELD.fieldApiName] = this.recordid;
        loanDetailsFields[RTO_Road_Tax_New__c.fieldApiName] = this.rtoRoaTaxVal;
        this.updateRecordDetails(loanDetailsFields);
             if(this.isRtoRoadTaxFieldEnable){
                 this.calculateORP();
                }else if(this.iconAPISuccess){//CISP-4730
               this.calculateORPCarWale();
         } ////CISP-6540 end
    } else{
        this.rtoRoaTaxVal = rtoRoaTaxVal;
        if(this.isRtoRoadTaxFieldEnable){//CISP-2346
            this.calculateORP();
            this.calculateORPCarWale();
        }
    }
}
    //CISP-6540
    handleRTOChangeCar(event){
        let rtoRoadTax = event.target.value;   
        this.rtoRoadTax = rtoRoadTax;
        const loanDetailsFields = {};
        loanDetailsFields[OPP_ID_FIELD.fieldApiName] = this.recordid;
        loanDetailsFields[RTO_Road_Tax_New__c.fieldApiName] = this.rtoRoadTax;
        this.updateRecordDetails(loanDetailsFields);
        if (this.isRtoRoadTaxFieldEnable) {
            this.calculateORP();
            this.calculateORPCarWale();
        }
    }
    //CISP-6540

    // CISP-2346-START
    // handleCarWaleRTOChange(event){
    //     let rtoRoaTaxVal = event.target.value;
    //     this.rtoRoadTax = rtoRoaTaxVal;
    //     const carwalefields = {};
    //     carwalefields[carwaleID.fieldApiName] = this.recordId;
    //     carwalefields[RTO_Road_Tax_Carwale.fieldApiName] = this.rtoRoadTax;
    //     this.updateRecordDetails(carwalefields);
    //     if(this.isRtoRoadTaxFieldEnable){
    //         this.calculateORP();
    //         this.calculateORPCarWale();
    //     }
    // }
    // CISP-2346-END

    calculateORP() {
        console.log('Exshowroom + RTO road tax + 1st year insurance premium + other charges: ',);
        let exshowpriceTWNew = this.exShowroomPrice ? this.exShowroomPrice : 0;// CISP-2346
        exshowpriceTWNew = exshowpriceTWNew ? exshowpriceTWNew : 0;
        let InsPrem = this.firstYrInsurancePremium;// CISP-2346
        InsPrem = InsPrem?InsPrem:0;
        this.rtoRoaTaxVal = this.rtoRoaTaxVal?this.rtoRoaTaxVal:0;
        this.otherCharges = this.otherCharges?this.otherCharges:0;
        console.log('exshowpriceTWNew : ',exshowpriceTWNew);
        console.log('InsPrem : ',InsPrem);
        console.log('rtoRoaTaxVal : ',this.rtoRoaTaxVal);
        console.log('otherCharges : ',this.otherCharges);
        if(this.leadSource!='OLA' && this.leadSource!='Hero'){this.onRoadPrice = parseFloat(exshowpriceTWNew) + parseFloat(this.rtoRoaTaxVal) + parseFloat(InsPrem) + parseFloat(this.otherCharges);}//OLA-82 CISH-09
        console.log('this.onRoadPrice : ',this.onRoadPrice);
    }
    calculateORPCarWale() {
        console.log('Exshowroom + RTO Road tax carwale + 1st year insurance premium + other charges : ',);
        let exshowpriceTWNew = this.exShowroomPricecarwale ? this.exShowroomPricecarwale : 0;// CISP-2346
        exshowpriceTWNew = exshowpriceTWNew ? exshowpriceTWNew : 0;
        let InsPrem = this.firstYrInsurancePremium;// CISP-2346
        InsPrem = InsPrem ? InsPrem : 0;
        this.rtoRoadTax = this.rtoRoadTax ? this.rtoRoadTax : 0;
        this.otherCharges = this.otherCharges ? this.otherCharges : 0;
        this.onRoadPricecarwale = parseFloat(exshowpriceTWNew) + parseFloat(this.rtoRoadTax) + parseFloat(InsPrem) + parseFloat(this.otherCharges);
    }
    handleExshowPriceChange(event) {
        if (this.isTractor) {
            let index = event.currentTarget.dataset.index;
            this.tractorVehicleList[index].invoicePrice = event.currentTarget.value;
            if(this.vehicleTypeDetail == 'New'){this.checkLoanAmount(index);}
        } else {
            //this.disabledSubmit = false;
            let exshowpriceTWNew = this.template.querySelector('lightning-input[data-id=exshowpriceTWNew]').value;
            exshowpriceTWNew = exshowpriceTWNew ? exshowpriceTWNew : 0;
            this.exShowroomPrice = exshowpriceTWNew ? exshowpriceTWNew : 0;
            console.log('exshowpriceTWNew--- : ', exshowpriceTWNew);
            if (exshowpriceTWNew && this.eScooter) {
                this.basicPrice = (parseFloat(exshowpriceTWNew) / 1.05263).toFixed(0);
                this.gstAmount = parseFloat(exshowpriceTWNew) - parseFloat(this.basicPrice);
            }else if (exshowpriceTWNew) {
                this.basicPrice = (parseFloat(exshowpriceTWNew)/1.28).toFixed(0);
                this.gstAmount = parseFloat(exshowpriceTWNew) -  parseFloat(this.basicPrice);
            } else {
                this.basicPrice = 0;
                this.gstAmount = 0;

            }
            this.calculateORP();
            this.calculateORPCarWale();
            console.log('this.basicPrice : ', this.basicPrice);
        }

    }

    //Get price Detail Button handler 
    handleGetPriceDetails() {
        this.isSpinnerMoving = true;

        checkRetryExhausted({ loanApplicationId: this.recordid }).then(result => {
            let response = JSON.parse(result);
            console.log('Retry Response:: ', response);

            if (response.message === RetryExhausted) {
                this.isSpinnerMoving = false;
                this.showToastMessage('Error', response.message, 'Error');

                this.iconAPIFailed = true;
                this.disableGetPrice = true;
                this.disabledSubmit = false;
                this.isCarWaleApiFailed = true;//CISP-2346
                this.isRtoRoadTaxFieldEnableFunction();//CISP-2346

                this.calculateAllValues(false);
            } else {
                //API Inputs
                if (this.productTypeDetail === PassengerVehicles) {
                    this.vehicleTypeNo = '1';
                } else {
                    this.vehicleTypeNo = '2';
                }

                let carDetails = {
                    'vehicleType': this.vehicleTypeNo,
                    'CityId': this.cityCode,
                    'VariantCode': this.variantCode,
                    'leadId': this.leadId,
                    'loanApplicationId': this.recordid
                };
                console.log('Car Details:: ', carDetails);
                //Carwale API
                //CISP-654 added product type 
                doCarwalePricesCallout({ 'CarwalePrices': JSON.stringify(carDetails), productType: this.productTypeDetail }).then(result => {
                    const obj = JSON.parse(result);
                    console.log('carwale API response :: ', obj);
                    if (this.productTypeDetail === PassengerVehicles) {
                        if (obj.response.status === 'Failure') {
                            this.isSpinnerMoving = false;
                            this.displayGetPricefields = true;
                            this.retryPopUp = true;
                        } else if (obj.response.status === 'SUCCESS') {
                            this.isSpinnerMoving = false;
                            this.showToastMessage(SuccessMessage, obj.response.status, 'success');

                            this.displayGetPricefields = true;
                            this.disabledOnRoadPriceCarwale = true;
                            this.disableGetPrice = true;
                            this.iconAPIFailed = false;
                            this.isCarWaleApiFailed = false;//CISP-2346
                            this.isRtoRoadTaxFieldEnableFunction();//CISP-2346
                            this.iconAPISuccess = true;
                            this.disabledSubmit = false;
                            let pricesList = obj?.response?.content[0]?.pricesList;
                            for (let i = 0; i < pricesList.length; i++) {
                                if (pricesList[i].name === 'RTO') {
                                    this.rtoRoadTax = pricesList[i].value;//CISP-2346
                                } else if (pricesList[i].name === 'Ex-showroom' || pricesList[i].name === 'Ex-Showroom Price') {
                                    this.exShowroomPricecarwale = pricesList[i].value;
                                } else if (pricesList[i].name === 'Insurance (Comprehensive)' || pricesList[i].name === 'Insurance') {
                                    this.onRoadPricecarwale = pricesList[i].value;
                                }
                            }
                            const loanDetailsFields = {};
                            loanDetailsFields[OPP_ID_FIELD.fieldApiName] = this.recordid;
                            loanDetailsFields[RTO_Road_Tax.fieldApiName] = this.rtoRoadTax;
                            this.updateRecordDetails(loanDetailsFields);
                            this.calculateAllValues(true);
                        } else {
                            this.isSpinnerMoving = false;
                            this.retryPopUp = true;
                        }
                    } else {
                        if (obj) {
                            this.isSpinnerMoving = false;
                            this.showToastMessage(SuccessMessage, 'Success', 'success');
                            this.displayGetPricefields = true;
                            this.disabledOnRoadPriceCarwale = true;
                            this.disableGetPrice = true;
                            this.iconAPIFailed = false;
                            this.isCarWaleApiFailed = false;//CISP-2346
                            this.isRtoRoadTaxFieldEnableFunction();//CISP-2346
                            this.iconAPISuccess = true;
                            this.disabledSubmit = false;
                            this.rtoRoadTax = obj?.rto?.value;//CISP-2346
                            const loanDetailsFields = {};
                            loanDetailsFields[OPP_ID_FIELD.fieldApiName] = this.recordid;
                            loanDetailsFields[RTO_Road_Tax.fieldApiName] = this.rtoRoadTax;
                            this.updateRecordDetails(loanDetailsFields);
                            this.exShowroomPricecarwale = obj?.exShowroom?.value;
                            this.onRoadPricecarwale = obj?.insuranceComprehensive?.value;
                            this.calculateAllValues(true);
                        } else {
                            this.isSpinnerMoving = false;
                            this.retryPopUp = true;
                        }
                    }
                    //CISP-654
                }).catch(error => {
                    this.isSpinnerMoving = false;
                    this.retryPopUp = true;
                    console.log(error);
                });
            }
        }).catch(error => {
            console.log("Error in fetching retry count:: ", error);
        });
    }

    //handle Required Tenured
    onRequiredTenuredChange(event) {

        if (this.isTractor) {
            let index = event.currentTarget.dataset.index;
            this.tractorVehicleList[index].requiredTenure = parseInt(event.currentTarget.value, 10);
            let vehicleSubType = this.tractorVehicleList[index].vehicleSubType;
            let tenureToAge = this.tractorVehicleList[index].requiredTenure
            let tenureId = this.tractorVehicleList[index].requiredTenureId;
            let elem = this.template.querySelector(`lightning-combobox[data-id="${tenureId}"]`);
            elem.setCustomValidity("");
            if (this.isNonIndividual != true && vehicleSubType == 'Implement' && (tenureToAge > 36 || tenureToAge < this.minTenureTractor)) {
                elem.setCustomValidity('Tenure is not in the range');
            }else if(this.isNonIndividual != true && tenureToAge > this.maxTenureTractor || tenureToAge < this.minTenureTractor){
                elem.setCustomValidity('Tenure is not in the range');
            }
            elem.reportValidity();
        } else {
            if (this.productTypeDetail.toLowerCase() === PassengerVehicles.toLowerCase()) {
                this.requiredRoi = '';
                let requiredRoiInput = this.template.querySelector('lightning-input[data-id=reqRoi]');
                requiredRoiInput.setCustomValidity("");
                requiredRoiInput.reportValidity();
            }
            this.requiredTenureValue = parseInt(event.target.value, 10);


            let elem = this.template.querySelector('.reqten');
            if (this.vehicleSubCategoryDetail !== UIM) {
                if (this.productTypeDetail === PassengerVehicles) {
                    elem.setCustomValidity("");
                    if ((parseInt(this.requiredTenureValue, 10) + parseInt(this.vehicleAge, 10)) > 180) { // CISP-4102 - changed 144 to 180
                        elem.setCustomValidity(this.label.RequiredTenuredPv);
                    }
                    elem.reportValidity();

                }
                else {
                    elem.setCustomValidity("");
                    if ((parseInt(this.requiredTenureValue, 10) + parseInt(this.vehicleAge, 10)) > 60) {
                        elem.setCustomValidity(this.label.RequiredTenured2w);
                    }
                    elem.reportValidity();
                }
            }
            else {
                elem.setCustomValidity("");
                if ((parseInt(this.requiredTenureValue, 10) > this.eligibleTenure)) {
                    elem.setCustomValidity(this.label.eligibleTenureMsg);
                }
                elem.reportValidity();
            }
        }

    }

    //handle Basic price
    handlebasicPrice(event) {
        if (this.isTractor) {
            let index = event.currentTarget.dataset.index;
            this.tractorVehicleList[index].basicPrice = event.currentTarget.value;
        } else {
            let basicPriceInput = this.template.querySelector('lightning-input[data-id=basicPrice]');
            let basicPricevalue = basicPriceInput.value;
            this.basicPrice = basicPricevalue;
        }

    }

    //handle Other Charges
    handleOtherCharges() {
        let otherChargeInput = this.template.querySelector('lightning-input[data-id=otherchar]');
        let otherChargeValue = otherChargeInput.value;
        this.otherCharges = otherChargeValue;
        if (this.isRtoRoadTaxFieldEnable) {//CISP-2346
            this.calculateORP();
        } else if (this.iconAPISuccess) {//CISP-4730
            this.calculateORPCarWale();
        }
    }
    //handle CSD
    handleCsd() {
        let csdInput = this.template.querySelector('lightning-input[data-id=idCsd]');
        this.csd = csdInput.checked;
    }
    //handle ONRoadPrice
    handleOnRoadPrice() {
        let onroadPriceInput = this.template.querySelector('lightning-input[data-id=onRoaPric]');
        let onRoadPricevalue = onroadPriceInput.value;
        this.onRoadPrice = onRoadPricevalue;
    }


    //handle DiscountOnBasicPrice
    handlediscountOnBasicPrice() {
        let discountBasicPriceInput = this.template.querySelector('lightning-input[data-id=disAmount]');
        let discountBasicPriceValue = discountBasicPriceInput.value;
        this.discountOnBasicPrice = discountBasicPriceValue;
        let elem = this.template.querySelector('lightning-input[data-id=disAmount]');
        if (this.productTypeDetail === PassengerVehicles) {
            this.percentageofDiscount = (40 * parseInt(this.requiredLoanAmount, 10)) / 100;
            elem.setCustomValidity("");
            if (this.discountOnBasicPrice && (this.discountOnBasicPrice > parseInt(this.percentageofDiscount, 10))) {
                elem.setCustomValidity(this.label.DiscountMsgPv);
            }
            elem.reportValidity();
            if (this.discountOnBasicPrice && (this.discountOnBasicPrice < parseInt(0, 10))) {
                elem.setCustomValidity(this.label.discountNegativemsg);
            }
            elem.reportValidity();
        }
        else {
            this.percentageofDiscount = (15 * parseInt(this.requiredLoanAmount, 10)) / 100;
            elem.setCustomValidity("");
            if (this.discountOnBasicPrice && (this.discountOnBasicPrice > parseInt(this.percentageofDiscount, 10))) {
                elem.setCustomValidity(this.label.DiscountMsg);
            }
            elem.reportValidity();
            if (this.discountOnBasicPrice && (this.discountOnBasicPrice < parseInt(0, 10))) {
                elem.setCustomValidity(this.label.discountNegativemsg);
            }
            elem.reportValidity();
        }

    }

    //handle GST Amount
    handlegstAmount(event) {
        if (this.isTractor) {
            let index = event.currentTarget.dataset.index;
            this.tractorVehicleList[index].gstAmount = event.currentTarget.value;
            let gstAmount = this.tractorVehicleList[index].gstAmount;
            let basicPrice = this.tractorVehicleList[index].basicPrice;
            let gstAmountId = this.tractorVehicleList[index].gstAmountId;
            let elem = this.template.querySelector(`lightning-input[data-id="${gstAmountId}"]`);
            this.percentageofGst = (this.gstPercentageValue * parseInt(basicPrice, 10)) / 100;
            elem.setCustomValidity("");
            if (gstAmount && gstAmount != 0 && (gstAmount < parseInt(this.percentageofGst, 10) || gstAmount > parseInt(basicPrice, 10))) {//CISP-3149
                elem.setCustomValidity(this.label.GstMsg);
            }
            elem.reportValidity();
        } else {
            let gstAmountInput = this.template.querySelector('lightning-input[data-id=gstAmount]');
            let gstAmountValue = gstAmountInput.value;
            this.gstAmount = gstAmountValue;
            let elem = this.template.querySelector('lightning-input[data-id=gstAmount]');
            this.percentageofGst = (this.gstPercentageValue * parseInt(this.basicPrice, 10)) / 100;
            elem.setCustomValidity("");
            if (this.gstAmount && this.gstAmount != 0 && (this.gstAmount < parseInt(this.percentageofGst, 10) || this.gstAmount > parseInt(this.basicPrice, 10))) {//CISP-3149
                elem.setCustomValidity(this.label.GstMsg);
            }
            elem.reportValidity();
        }

    }

    //handle MotorInsurancePremium
    handleMotorInsurancePremium() {
        let motorInsurancePremiuInput = this.template.querySelector('lightning-input[data-id=motInsPrem]');
        let motorInsurancePremiumValue = motorInsurancePremiuInput.value;
        this.motorInsurancePremium = motorInsurancePremiumValue;

    }
    handlefundedNonFunded() {
        this.disabledFunded = true;
        this.disabledNonFunded = true;
        this.checkNoFunded = true;
        this.template.querySelector('lightning-input[data-id=fundedId]').checked = false;
    }

    //handle InsurancePremium
    handleInsurancePremium(event) {
        if (this.isTractor) {
            let index = event.currentTarget.dataset.index;
            this.tractorVehicleList[index].firstYrInsurancePremium = event.currentTarget.value;
        } else {
            let insurancePremiumInput = this.template.querySelector('lightning-input[data-id=InsPrem]');
            let insurancePremiumValue = insurancePremiumInput.value;
            this.firstYrInsurancePremium = insurancePremiumValue;
            if (this.isRtoRoadTaxFieldEnable) {//CISP-2346
                this.calculateORP();
            } else if (this.iconAPISuccess) {//CISP-4730
                this.calculateORPCarWale();
            }
        }

    }

    //handle Required Roi
    handleRequiredRoi(event) {

        let requiredRoiInput = this.template.querySelector('lightning-input[data-id=reqRoi]');
        let tenure;
        let index;
        if (this.isTractor) {
            index = event.currentTarget.dataset.index;
            tenure = this.tractorVehicleList[index].requiredTenure;
        } else {
            tenure = this.requiredTenureValue;
        }

        if (tenure == null || tenure == undefined || tenure == '') {
            this.showToastMessage('', 'Please select tenure first', 'error');
            requiredRoiInput.value = '';
            return;
        } else {
            if (requiredRoiInput) {

                if (this.isTractor) {

                    this.tractorVehicleList[index].requiredCRMIRRTW = event.currentTarget.value ? parseFloat(event.currentTarget.value, 10) : null;
                    requiredRoiInput.setCustomValidity("");
                    if (this.isNonIndividual != true && this.tractorVehicleList[index].requiredCRMIRRTW < parseFloat(this.minRoiTractor) || this.tractorVehicleList[index].requiredCRMIRRTW > parseFloat(this.maxRoiTractor)) {
                        requiredRoiInput.setCustomValidity(this.label.RateOfInterestMsg);
                    }
                    requiredRoiInput.reportValidity();
                } else {
                    let requiredRoiValue = requiredRoiInput.value;
                    this.requiredRoi = requiredRoiValue;

                    requiredRoiInput.setCustomValidity("");
                    if (this.productTypeDetail.toLowerCase() === PassengerVehicles.toLowerCase()) {
                        roiMasterForImputedIRR({ loanApplicationId: this.recordid, productType: this.productTypeDetail, tenure: this.requiredTenureValue, vehicleCategory: this.vehicleTypeDetail, queryBased: 'CRM_IRR' })
                            .then(result => {
                                let parsedData = JSON.parse(result);
                                if (parsedData.mincrm != null && parsedData.maxcrm != null) {
                                    this.minRoi = parsedData.mincrm;
                                    this.maxRoi = parsedData.maxcrm;
                                    if (this.requiredLoanAmount && (this.requiredRoi < parseFloat(this.minRoi) || this.requiredRoi > parseFloat(this.maxRoi))) {
                                        requiredRoiInput.setCustomValidity('CRM IRR is not as per norms Min ' + this.minRoi + ' and Max ' + this.maxRoi);//CISP-5450
                                        requiredRoiInput.reportValidity();
                                    }
                                }
                            })
                            .catch(error => {
                                console.error('Error:', error);
                            });

                    } else {
                        if (this.requiredLoanAmount && (this.requiredRoi < parseFloat(this.minRoi) || this.requiredRoi > parseFloat(this.maxRoi))) {
                            requiredRoiInput.setCustomValidity(this.label.RateOfInterestMsg);
                        }
                        requiredRoiInput.reportValidity();
                    }
                }

                requiredRoiInput.reportValidity();
            }
        }
    }

    //handle Funded
    handleFunded(event) {

        if (this.isTractor) {
            let index = event.currentTarget.dataset.index;
            this.tractorVehicleList[index].funded = event.currentTarget.checked;
            if (this.tractorVehicleList[index].funded === true) {
                this.tractorVehicleList[index].disabledNonFunded = true;
            } else {
                this.tractorVehicleList[index].disabledNonFunded = false;
            }
        } else {
            this.funded = event.target.checked;
            if (this.funded === true) {
                this.disabledNonFunded = true;
            } else {
                this.disabledNonFunded = false;
            }
        }


    }

    //handle NONFunded
    handleNonFunded(event) {
        if (this.isTractor) {
            let index = event.currentTarget.dataset.index;
            this.tractorVehicleList[index].nonFunded = event.currentTarget.checked;
            this.tractorVehicleList[index].firstYearInsuranceRequired = this.tractorVehicleList[index].nonFunded && this.tractorVehicleList[index].isCustomerInterested;
            if (this.tractorVehicleList[index].nonFunded === true) {
                this.tractorVehicleList[index].disabledFunded = true;
            } else {
                this.tractorVehicleList[index].disabledFunded = false;
            }
        } else {
            this.nonFunded = event.target.checked;
            if (this.nonFunded === true) {
                this.disabledFunded = true;
            }
            else {
                this.disabledFunded = false;
            }
        }
    }

    //handle Required loan amount
    async handleRequiredLoan(event) {

        if (this.isTractor) {
            let index = event.currentTarget.dataset.index;
            this.tractorVehicleList[index].requiredLoanAmount = event.currentTarget.value;

            let sumOfLoanAmount = 0;
            this.tractorVehicleList.forEach((element) => {
                sumOfLoanAmount += parseInt(element.requiredLoanAmount ? element.requiredLoanAmount : 0);
            });
            let loanAmountId = this.tractorVehicleList[index].requiredLoanAmountId;
            let elem = this.template.querySelector(`lightning-input[data-id="${loanAmountId}"]`);
            elem.setCustomValidity("");
            this.checkLoanAmount(index);

            if (sumOfLoanAmount > this.requiredLoanAmount && this.parentLeadRevoked == false) {
                elem.setCustomValidity('Vehicle Loan Amount Cannot be greater than Loan Application\'s Loan Amount');
            }
            elem.reportValidity();
        } else {
            // Query the required loan amount input
            let requiredLoanAmountInput = this.template.querySelector('lightning-input[data-id=reqLoan]');

            // Store its value in the component
            this.requiredLoanAmount = requiredLoanAmountInput.value;

            // Reset the custom validity message
            requiredLoanAmountInput.setCustomValidity("");

            // Convert product types to lowercase for case-insensitive comparison
            const productTypeDetailLower = this.productTypeDetail.toLowerCase();
            const twoWheelerLower = TwoWheeler.toLowerCase();
            const passengerVehiclesLower = PassengerVehicles.toLowerCase();

            // Parse loan amounts as integers for numerical comparison
            const loanAmount10000Int = parseInt(Loanamount10000, 10);
            const loanAmount50000Int = parseInt(LoanAmount50000, 10);
            const eligibleLoanAmountInt = parseInt(this.eligibleLoanAmount, 10);

            // Validate the required loan amount based on the product type
            if (productTypeDetailLower === twoWheelerLower && (this.requiredLoanAmount < loanAmount10000Int || this.requiredLoanAmount > eligibleLoanAmountInt)) {
                requiredLoanAmountInput.setCustomValidity(this.label.eligibleLoanAmountmsg);
            } else if (productTypeDetailLower === passengerVehiclesLower && this.requiredLoanAmount < loanAmount50000Int) {
                requiredLoanAmountInput.setCustomValidity(this.label.eligibleLoanAmountmsg);
            }

            // Check the validity and display any error messages if necessary
            requiredLoanAmountInput.reportValidity();
        }

    }

    //handle Onroad price
    handleOrp(event) {
        this.orp = event.target.checked;
        console.log('orp checked => ', this.orp);
        if (this.orp === true) {
            this.flagtocheckFunding = true;
            this.template.querySelector('lightning-input[data-id=fundingBasedOnExShowroomId]').disabled = true;
            this.template.querySelector('lightning-input[data-id=fundedId]').checked = true;
            this.template.querySelector('lightning-input[data-id=nonFundedId]').checked = false;
            this.disabledFunded = true;
            this.disabledNonFunded = true;
        } else {
            this.template.querySelector('lightning-input[data-id=fundingBasedOnExShowroomId]').disabled = false;
            this.template.querySelector('lightning-input[data-id=custInterestedInInsuranceId]').checked = false;
            this.template.querySelector('lightning-input[data-id=fundedId]').checked = false;
            this.template.querySelector('lightning-input[data-id=nonFundedId]').checked = false;
            this.disabledFunded = false;
            this.disabledNonFunded = false;
        }
        // CISP-2346
        if (this.isRtoRoadTaxFieldEnable) {
            this.otherCharges = 0;
            this.calculateORP();
            this.calculateORPCarWale();
        }
        // CISP-2346
    }

    //handle Ex-showroom
    handleExshowroom() {
        let exShowroomInput = this.template.querySelector('lightning-input[data-id=fundingBasedOnExShowroomId]');
        this.fundingOnExShowroom = exShowroomInput.checked;
        console.log('ex showroom checked => ', this.fundingOnExShowroom);
        if (this.fundingOnExShowroom === true) {
            this.flagtocheckFunding = false;
            this.disabledOrp = true;
            this.template.querySelector('lightning-input[data-id=fundedId]').checked = false;
            this.template.querySelector('lightning-input[data-id=nonFundedId]').checked = true;
            this.disabledFunded = true;
            this.disabledNonFunded = true;
        } else {
            this.disabledOrp = false;
            this.template.querySelector('lightning-input[data-id=custInterestedInInsuranceId]').checked = false;
            this.template.querySelector('lightning-input[data-id=fundedId]').checked = false;
            this.template.querySelector('lightning-input[data-id=nonFundedId]').checked = false;
            this.disabledFunded = false;
            this.disabledNonFunded = false;
        }
    }

    //handle MotorInsurance
    handleMotorInsurance(event) {
        this.checkMotorInsurance = event.target.checked;
        if (this.isTractor) {
            let index = event.currentTarget.dataset.index;
            this.tractorVehicleList[index].isCustomerInterested = event.currentTarget.checked;
            this.tractorVehicleList[index].firstYearInsuranceRequired = this.tractorVehicleList[index].nonFunded && this.tractorVehicleList[index].isCustomerInterested;
            //SFTRAC-910 Starts
            console.log('++++++isCustomerInterested '+this.tractorVehicleList[index].isCustomerInterested+' this.checkMotorInsurance '+this.checkMotorInsurance);
            console.log('++++++disabledFunded2 '+this.tractorVehicleList[index].disabledFunded+' this.disabledNonFunded '+this.tractorVehicleList[index].disabledFunded);
            if(this.tractorVehicleList[index].isCustomerInterested == true){
                this.tractorVehicleList[index].disabledFunded = false;
                this.tractorVehicleList[index].disabledNonFunded = false;
            }else{
                this.tractorVehicleList[index].disabledFunded = true;
                this.tractorVehicleList[index].disabledNonFunded = true;
            }
            console.log('++++++disabledFunded3 '+this.tractorVehicleList[index].disabledFunded+' this.disabledNonFunded '+this.tractorVehicleList[index].disabledFunded);
            //SFTRAC-910 ends
        } else {
            console.log('Check:: ', this.isUsedOrRefinanceVehicleTypeFlag);

            //newLabel
            if (this.isUsedOrRefinanceVehicleTypeFlag === false) {
                if (this.fundingOnExShowroom === true) {
                    if (this.checkMotorInsurance === true) {
                        this.template.querySelector('lightning-input[data-id=nonFundedId]').checked = false;
                        this.disabledFunded = false;
                        this.disabledNonFunded = false;
                    } else {
                        this.template.querySelector('lightning-input[data-id=fundedId]').checked = false;
                        this.template.querySelector('lightning-input[data-id=nonFundedId]').checked = true;
                        this.disabledFunded = true;
                        this.disabledNonFunded = true;
                    }
                }

                if (this.orp === true) {
                    if (this.checkMotorInsurance === true) {
                        this.template.querySelector('lightning-input[data-id=fundedId]').checked = true;
                        this.template.querySelector('lightning-input[data-id=nonFundedId]').checked = false;
                        this.disabledFunded = true;
                        this.disabledNonFunded = true;
                    } else {
                        this.template.querySelector('lightning-input[data-id=custInterestedInInsuranceId]').checked = false;
                        this.template.querySelector('lightning-input[data-id=fundedId]').checked = true;
                        this.template.querySelector('lightning-input[data-id=nonFundedId]').checked = false;
                        this.disabledFunded = true;
                        this.disabledNonFunded = true;
                    }
                }
            } else {
                //Used or Refinance
                if (this.insuranceExpiring === false) {

                    //this.displayFundingBasedOn = false;
                    this.template.querySelector('lightning-input[data-id=custInterestedInInsuranceId]').checked = false;
                    this.disableMotorInsurance = true;
                    this.handlefundedNonFunded();
                    this.template.querySelector('lightning-input[data-id=fundedId]').checked = false;
                    this.template.querySelector('lightning-input[data-id=nonFundedId]').checked = true;
                    this.disabledFunded = true;
                    this.disabledNonFunded = true;
                } else {
                    //this.displayFundingBasedOn = false;
                    this.disableMotorInsurance = false;
                    //this.template.querySelector('lightning-input[data-id=custInterestedInInsuranceId]').checked = false;
                    if (this.checkMotorInsurance === false) {
                        this.handlefundedNonFunded();
                    } else {
                        this.template.querySelector('lightning-input[data-id=nonFundedId]').checked = false;
                        this.disabledFunded = false;
                        this.disabledNonFunded = false;
                    }
                }
            }
        }


    }

    calculateCarwalePrices() {

        this.calculateAllValues(false);
    }

    //handle retry popup
    handleRetry() {
        this.retryPopUp = false;
    }

    //rendered callback
    renderedCallback() {
        loadStyle(this, LightningCardCSS);
        if (this.currentStageName === 'Credit Processing' || this.currentStageName === 'Loan Initiation' || this.currentStageName === 'Additional Details' || this.currentStageName === 'Asset Details'|| this.currentStageName === 'Vehicle Valuation' || this.currentStageName === 'Vehicle Insurance' || (this.currentStageName !== 'Loan Details' && this.lastStage !== 'Loan Details' && this.lastStage != undefined && this.currentStageName != undefined)) {//CISP-519
            this.disableEverything();
            if (this.currentStage === 'Credit Processing') {
                this.isEnableNext = true;
                if (this.template.querySelector('.next')) { this.template.querySelector('.next').disabled = false; }
            }
        }

        let fieldList = this.readOnlyFieldList;
        if (this.leadSource == 'OLA' && this.readOnlyFieldList.length > 0) {
            //this.disabledFirstYrInsurancePremium = true;
            this.template.querySelector('lightning-input[data-id=InsPrem]').disabled = fieldList.includes('1st year insurance premium') ? true : false;
            this.template.querySelector('lightning-input[data-id=fundedId]').checked = true;
            this.template.querySelector('lightning-input[data-id=nonFundedId]').checked = false;
            this.template.querySelector('lightning-input[data-id=otherchar]').disabled = fieldList.includes('Other charges') ? true : false;
            this.template.querySelector('lightning-input[data-id=exshowpriceTWNew]').disabled = fieldList.includes('Ex-showroom price') ? true : false;
        }
        if(this.isRevokedLoanApplication){this.disableEverything();}
    }

    async updateRecordDetails(fields) {
        let updateStatus = false;
        const recordInput = { fields };

        console.log('Update Record Inputs:: ', JSON.stringify(fields));
        await updateRecord(recordInput).then(() => {
            updateStatus = true;
        }).catch(error => {
            console.log('updateRecordDetails - error', error);
        });
        return updateStatus;
    }

    async handleSaveAndExit() {
        let requiredLoanAmountInput = this.template.querySelector('lightning-input[data-id=reqLoan]');
        let requiredLoanAmounts = requiredLoanAmountInput.value;
        this.requiredLoanAmount = requiredLoanAmounts;
        let motorInsuranceInput = this.template.querySelector('lightning-input[data-id=custInterestedInInsuranceId]');
        this.checkMotorInsurance = motorInsuranceInput.checked;
        let fundedInput = this.template.querySelector('lightning-input[data-id=fundedId]');
        this.funded = fundedInput.checked;
        let nofundedInput = this.template.querySelector('lightning-input[data-id=nonFundedId]');
        this.nonFunded = nofundedInput.checked;

        const loanDetailsFields = {};
        loanDetailsFields[OPP_ID_FIELD.fieldApiName] = this.recordid;
        loanDetailsFields[Required_Loan_amount.fieldApiName] = this.requiredLoanAmount;
        loanDetailsFields[Required_Tenure.fieldApiName] = this.requiredTenureValue;
        loanDetailsFields[Required_ROI.fieldApiName] = this.requiredRoi;
        loanDetailsFields[Funding_on_Ex_Showroom.fieldApiName] = this.fundingOnExShowroom;
        loanDetailsFields[fundingOnORP.fieldApiName] = this.orp;
        loanDetailsFields[custInterestedInInsurance.fieldApiName] = this.checkMotorInsurance;
        loanDetailsFields[Funded.fieldApiName] = this.funded;
        loanDetailsFields[Non_Funded.fieldApiName] = this.nonFunded;
        loanDetailsFields[Insurance_Premium.fieldApiName] = this.firstYrInsurancePremium;
        loanDetailsFields[Motor_Insurance_Premium.fieldApiName] = this.motorInsurancePremium;
        loanDetailsFields[Basic_Price.fieldApiName] = this.basicPrice;
        loanDetailsFields[GST_Amount.fieldApiName] = (this.gstAmount != null && this.gstAmount != undefined && this.gstAmount != '') ? Math.ceil(this.gstAmount) : this.gstAmount;
        loanDetailsFields[Discount_on_Basic_Price.fieldApiName] = this.discountOnBasicPrice;
        loanDetailsFields[Ex_showroom_price.fieldApiName] = this.exShowroomPrice;
        loanDetailsFields[Ex_showroom_price_carwale.fieldApiName] = this.exShowroomPricecarwale;
        if (this.productTypeDetail == PassengerVehicles && this.isCarWaleApiFailed == false) {
            loanDetailsFields[RTO_Road_Tax_New__c.fieldApiName] = this.rtoRoadTax;//this.rtoRoadTax
        } else {
            loanDetailsFields[RTO_Road_Tax_New__c.fieldApiName] = this.rtoRoaTaxVal;
        }//CISP-6540
        loanDetailsFields[Other_charges.fieldApiName] = this.otherCharges;
        loanDetailsFields[On_Road_price.fieldApiName] = this.onRoadPrice;
        loanDetailsFields[On_Road_price_carwale.fieldApiName] = this.onRoadPricecarwale;
        loanDetailsFields[Final_Price.fieldApiName] = this.finalPrice;
        this.updateRecordDetails(loanDetailsFields);
        const evt = new ShowToastEvent({
            title: SuccessMessage,
            message: detailsSaved,
            variant: 'success',
        });
        this.dispatchEvent(evt);
    }

    //Navigation from loan details to home page
    navigateToHomePage() {
        console.log('entered in NavigateToHomePage');
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
    //Sri
    handleOnfinish(event) {
        console.log('entered');
        const evnts = new CustomEvent('incomevaleve', { detail: event });
        this.dispatchEvent(evnts);
        //this.template.querySelector('c-i-N-D_-L-W-C_-View-Application-Data').submit(event);
    }

    showToastMessage(title, message, variant) {
        if (title) {
            this.dispatchEvent(new ShowToastEvent({
                title: title,
                message: message,
                variant: variant,
            }));
        } else {
            this.dispatchEvent(new ShowToastEvent({
                message: message,
                variant: variant,
            }));
        }
    }

    showToastMessageModeBased(title, message, variant, mode) {
        if (title) {
            this.dispatchEvent(new ShowToastEvent({
                title: title,
                message: message,
                variant: variant,
                mode: mode,
            }));
        } else {
            this.dispatchEvent(new ShowToastEvent({
                message: message,
                variant: variant,
                mode: mode,
            }));
        }
    }

    //handle Home
    async handleHome() {
        console.log('entered in HandleHome');
        await this.handleSaveAndExit();
        this.navigateToHomePage();
    }

    validityCheck(query) {
        return [...this.template.querySelectorAll(query)].reduce((validSoFar, inputField) => {
            inputField.reportValidity();
            return validSoFar && inputField.checkValidity();
        }, true);
    }

    //submit handler sub part 
    async handleSubmit() {
        if (this.isTractor) {
            this.isSpinnerMoving = true;
            let inputFieldsValid = this.validityCheck('lightning-input');
            let comboBoxValid = this.validityCheck('lightning-combobox');
            if (!inputFieldsValid || !comboBoxValid) {
                this.isSpinnerMoving = false;
                this.showToastMessage(this.label.Please_fill_all_the_mandatory_fields, null, 'warning');
                return;
            }
            const loanDetailsFields = {};
            loanDetailsFields[OPP_ID_FIELD.fieldApiName] = this.recordid;
            loanDetailsFields[STAGENAME.fieldApiName] = 'Income Details';
            if(this.parentLeadRevoked == true){
                let sumOfLoanAmount = 0;
                if(this.tractorVehicleList && this.tractorVehicleList.length > 0){
                    for (let index = 0; index < this.tractorVehicleList.length; index++) {
                        const element = this.tractorVehicleList[index];
                        sumOfLoanAmount += parseInt(element.requiredLoanAmount ? element.requiredLoanAmount : 0);
                    }
                }
                if(sumOfLoanAmount > 0){
                    loanDetailsFields[LOAN_AMOUNT.fieldApiName] = sumOfLoanAmount + '';
                }
            }
            loanDetailsFields[LAST_STAGE_NAME.fieldApiName] = 'Income Details';
            loanDetailsFields[IS_LOAN_DETAILS_SUBMITTED_FIELD.fieldApiName] = true;

            updateApplicantSubStage({ loanApplicationId: this.recordid }).then(response => {

                if (response) {
                    saveVehicleDetailsForTractor({ vehicleListString: JSON.stringify(this.tractorVehicleList) }).then(result => {
                        if (result) {
                            this.updateRecordDetails(loanDetailsFields).then(result => {
                                if (result) {
                                    this.showToastMessage(SuccessMessage, detailsSaved, 'success');
                                    this.callLoanApplicationHistory('Income Details');
                                } else {
                                    this.isSpinnerMoving = false;
                                    this.showToastMessage('', 'Error in saving the details', 'error');
                                }
                            }).catch(error => {
                                this.isSpinnerMoving = false;
                                this.showToastMessage('', 'Error in saving the details', 'error');
                            });
                        } else {
                            this.isSpinnerMoving = false;
                            this.showToastMessage('', 'Error in saving the details', 'error');
                        }
                    }).catch(error => {
                        this.isSpinnerMoving = false;
                        this.showToastMessage('', 'Error in saving the details', 'error');
                    });

                } else {
                    this.isSpinnerMoving = false;
                    this.showToastMessage('', 'Error in saving the details', 'error');
                }
            }).catch(error => {
                this.isSpinnerMoving = false;
                this.showToastMessage(SuccessMessage, detailsSaved, 'success');
            });
        } else {
            let detail = {
                basicPricedetail: this.basicPrice,
                gstAmountdetail: this.gstAmount,
                discountOnBasicPriceDetail: this.discountOnBasicPrice,
                exShowroomPriceCarwaledetail: this.exShowroomPricecarwale,
                flagtocheckFundingdetail: this.flagtocheckFunding,
                flagtocheckCsddetail: this.csd,
                insurancePremiumDeatil: this.firstYrInsurancePremium,
                otherChargesDetail: this.otherCharges,
                rtoRoadTaxDetail: this.isRtoRoadTaxFieldEnable ? this.rtoRoaTaxVal : this.rtoRoadTax,
                rtoRoaTaxVal: this.rtoRoaTaxVal,
            };

            let result = await calculatePrices({ detail: JSON.stringify(detail) });
            let response = JSON.parse(result);
            if (parseInt(this.exShowroomPrice) != parseInt(response.exShowroomPriceOne)) {
                this.showToastMessage("Ex showroom price is not matching with the calculated value", null, 'warning');
                return;
            }
            if (parseInt(this.onRoadPrice) != parseInt(response.onRoadPriceOne) && (this.leadSource !='OLA' && this.leadSource !='Hero')) {//CISH-77
                this.showToastMessage("On road price is not matching with the calculated value", null, 'warning');
                return;
            }
            this.isSpinnerMoving = true;
            if (this.rtoRoaTaxVal <= 0 && this.template.querySelector('lightning-input[data-id=rtoRoaTaxVal]')) {
                this.isSpinnerMoving = false;
                this.showToastMessage(RTO_Road_Tax_Error, null, 'warning');
                return;
            }
            if((this.leadSource =='Hero' || this.leadSource =='OLA') && (this.onRoadPrice != this.offerEngineORPHero)){//CISH-77
                this.isSpinnerMoving = false;
                this.showToastMessage("ORP Mismatch - “iblORP” and “onroadPrice” are different, kindly rectify", null, 'warning');
                return;
            }//CISH-77
            //this.validateSubmit();
            let fundingBasedExShowroom = this.template.querySelector('lightning-input[data-id=fundingBasedOnExShowroomId]');
            let fundingBasedOrp = this.template.querySelector('lightning-input[data-id=orp]');
            if (this.vehicleTypeDetail === 'New' && fundingBasedExShowroom && fundingBasedOrp && !fundingBasedExShowroom.checked && !fundingBasedOrp.checked) {
                this.isSpinnerMoving = false;
                this.showToastMessage(this.label.Please_fill_all_the_mandatory_fields, null, 'warning');
                return;
            }
            if (this.vehicleTypeDetail === 'New' && this.exShowroomPrice == 0) {
                this.isSpinnerMoving = false;
                this.showToastMessage('Exshowroom price is 0. Please check.', null, 'warning');
                return;
            }
            if (!this.validityCheck('lightning-input') || !this.validityCheck('lightning-combobox')) {
                this.isSpinnerMoving = false;
                this.showToastMessage(this.label.Please_fill_all_the_mandatory_fields, null, 'warning');
                return;
            }
            if (this.requiredLoanAmount && (this.requiredRoi < parseFloat(this.minRoi) || this.requiredRoi > parseFloat(this.maxRoi))) {
                this.isSpinnerMoving = false;
                this.showToastMessage('CRM IRR is not as per norms Min ' + this.minRoi + ' and Max ' + this.maxRoi, null, 'warning');
                return;
            }
            //check Loan Amount validations for UIM subcategory 
            if (!this.disableRequiredLoanAmount) {
                this.isSpinnerMoving = false;
                let requiredLoanAmountInput = this.template.querySelector('lightning-input[data-id=reqLoan]');
                let requiredLoanAmounts = requiredLoanAmountInput.value;
                this.requiredLoanAmount = requiredLoanAmounts;
                let elem = this.template.querySelector('lightning-input[data-id=reqLoan]');
                elem.setCustomValidity("");
                // if (this.requiredLoanAmount && (this.requiredLoanAmount < parseInt(0, 10) || this.requiredLoanAmount > parseInt(this.eligibleLoanAmount, 10))) {
                //     elem.setCustomValidity(this.label.eligibleLoanAmountmsg);
                //     return;
                // }
                if (this.productTypeDetail.toLowerCase() === TwoWheeler.toLowerCase()) {
                    if (this.requiredLoanAmount && (this.requiredLoanAmount < parseInt(Loanamount10000, 10) || this.requiredLoanAmount > parseInt(this.eligibleLoanAmount, 10))) {
                        elem.setCustomValidity(this.label.eligibleLoanAmountmsg);
                    }
                } else if (this.productTypeDetail.toLowerCase() === PassengerVehicles.toLowerCase()) {
                    if (this.requiredLoanAmount && (this.requiredLoanAmount < parseInt(LoanAmount50000, 10) || this.requiredLoanAmount > parseInt(this.eligibleLoanAmount, 10))) {
                        elem.setCustomValidity(this.label.eligibleLoanAmountmsg);
                    }
                }
                elem.reportValidity();
            }

            let requiredLoanAmountInput = this.template.querySelector('lightning-input[data-id=reqLoan]');
            let requiredLoanAmounts = requiredLoanAmountInput.value;
            this.requiredLoanAmount = requiredLoanAmounts;
            let motorInsuranceInput = this.template.querySelector('lightning-input[data-id=custInterestedInInsuranceId]');
            let fundedInput = this.template.querySelector('lightning-input[data-id=fundedId]');
            let nofundedInput = this.template.querySelector('lightning-input[data-id=nonFundedId]');
            this.funded = fundedInput.checked;
            this.checkMotorInsurance = motorInsuranceInput.checked;
            this.nonFunded = nofundedInput.checked;

            const loanDetailsFields = {};
            loanDetailsFields[OPP_ID_FIELD.fieldApiName] = this.recordid;
            loanDetailsFields[Required_Loan_amount.fieldApiName] = this.requiredLoanAmount;
            loanDetailsFields[Required_Tenure.fieldApiName] = this.requiredTenureValue;
            loanDetailsFields[Required_ROI.fieldApiName] = this.requiredRoi;
            loanDetailsFields[Funding_on_Ex_Showroom.fieldApiName] = this.fundingOnExShowroom;
            loanDetailsFields[fundingOnORP.fieldApiName] = this.orp;
            loanDetailsFields[custInterestedInInsurance.fieldApiName] = this.checkMotorInsurance;
            loanDetailsFields[Funded.fieldApiName] = this.funded;
            loanDetailsFields[Non_Funded.fieldApiName] = this.nonFunded;
            loanDetailsFields[Insurance_Premium.fieldApiName] = this.firstYrInsurancePremium;
            loanDetailsFields[Motor_Insurance_Premium.fieldApiName] = this.motorInsurancePremium;
            loanDetailsFields[Basic_Price.fieldApiName] = this.basicPrice;
            loanDetailsFields[GST_Amount.fieldApiName] = (this.gstAmount != null && this.gstAmount != undefined && this.gstAmount != '') ? Math.ceil(this.gstAmount) : this.gstAmount;
            loanDetailsFields[Discount_on_Basic_Price.fieldApiName] = this.discountOnBasicPrice;
            loanDetailsFields[Ex_showroom_price.fieldApiName] = this.exShowroomPrice;

            if (this.exShowroomPricecarwale <= 0) {
                loanDetailsFields[Ex_showroom_price_carwale.fieldApiName] = 0;
            } else {
                loanDetailsFields[Ex_showroom_price_carwale.fieldApiName] = this.exShowroomPricecarwale;
            }

            if (this.onRoadPricecarwale <= 0) {
                loanDetailsFields[On_Road_price_carwale.fieldApiName] = 0;
            } else {
                loanDetailsFields[On_Road_price_carwale.fieldApiName] = this.onRoadPricecarwale;
            }

            if(this.productTypeDetail == PassengerVehicles && this.isCarWaleApiFailed == false){
                loanDetailsFields[RTO_Road_Tax_New__c.fieldApiName] = this.rtoRoadTax;//this.rtoRoadTax
            }else{
                loanDetailsFields[RTO_Road_Tax_New__c.fieldApiName] = this.rtoRoaTaxVal;
            }//CISP-6540
            loanDetailsFields[Other_charges.fieldApiName] = this.otherCharges;
            loanDetailsFields[On_Road_price.fieldApiName] = this.onRoadPrice;
            loanDetailsFields[Final_Price.fieldApiName] = this.finalPrice;
            loanDetailsFields[STAGENAME.fieldApiName] = 'Income Details';
            loanDetailsFields[LAST_STAGE_NAME.fieldApiName] = 'Income Details';
            loanDetailsFields[IS_LOAN_DETAILS_SUBMITTED_FIELD.fieldApiName] = true;
            updateApplicantSubStage({ loanApplicationId: this.recordid }).then(response => {

                if (response) {
                    this.updateRecordDetails(loanDetailsFields).then(result => {
                        if (result) {
                            this.showToastMessage(SuccessMessage, detailsSaved, 'success');
                            this.callLoanApplicationHistory('Income Details');
                        } else {
                            this.isSpinnerMoving = false;
                            this.showToastMessage('', 'Error in saving the details', 'error');
                        }
                    }).catch(error => {
                        this.isSpinnerMoving = false;
                        this.showToastMessage('', 'Error in saving the details', 'error');
                    });

                } else {
                    this.isSpinnerMoving = false;
                    this.showToastMessage('', 'Error in saving the details', 'error');
                }
            }).catch(error => {
                this.isSpinnerMoving = false;
                this.showToastMessage(SuccessMessage, detailsSaved, 'success');
            });
        }


    }

    async callLoanApplicationHistory(nextStage) {
        this.isSpinnerMoving = true;
        await getLoanApplicationHistory({ loanId: this.recordid, stage: 'Loan Details', nextStage: nextStage }).then(response => {
            this.isSpinnerMoving = false;
            console.log('getLoanApplicationHistory Response:: ', response);
            if (response) {
                this.navigateToHomePage();
            } else {
                this.dispatchEvent(new CustomEvent('submitnavigation', { detail: nextStage }));
            }
        }).catch(error => {
            this.isSpinnerMoving = false;
            console.log('Error in getLoanApplicationHistory:: ', error);
        });
    }


    callAccessLoanApplication() {
        accessLoanApplication({ loanId: this.recordid, stage: 'Loan Details' }).then(response => {
            console.log('accessLoanApplication Response:: ', response);
            if (!response) {
                this.disableEverything();
                if (this.checkleadaccess) {//if lead is accessible but user from different profile is viewing that
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

    async calculateAllValues(fromApi) {
        this.isSpinnerMoving = true;
        if (this.basicPrice === '' || this.gstAmount === '' || this.discountOnBasicPrice === '' || this.exShowroomPricecarwale === '' || this.firstYrInsurancePremium === '' || this.otherCharges === '' || this.rtoRoaTaxVal === '') {//CISP-2346
            console.log('Blocking calculations');
            this.isSpinnerMoving = false;
            this.showToastMessage('Please fill all the fields.', null, 'error');
            return;
        } else {
            let detail = {
                basicPricedetail: this.basicPrice,
                gstAmountdetail: this.gstAmount,
                discountOnBasicPriceDetail: this.discountOnBasicPrice,
                exShowroomPriceCarwaledetail: this.exShowroomPricecarwale,
                flagtocheckFundingdetail: this.flagtocheckFunding,
                flagtocheckCsddetail: this.csd,
                insurancePremiumDeatil: this.firstYrInsurancePremium,
                otherChargesDetail: this.otherCharges,
                rtoRoadTaxDetail: this.isRtoRoadTaxFieldEnable ? this.rtoRoaTaxVal : this.rtoRoadTax,
                rtoRoaTaxVal: this.rtoRoaTaxVal,//CISP-2346
            };

            await calculatePrices({ detail: JSON.stringify(detail) }).then(result => {
                let response = JSON.parse(result);
                console.log('response calculatePrices', response);
                // if(!this.isRtoRoadTaxFieldEnable){//CISP-2346 //CISP-2716
                if(this.leadSource!='OLA' && this.leadSource!='Hero'){//OLA-82//CISH-09
                    this.exShowroomPrice = response.exShowroomPriceOne;
                }
                // }//CISP-2716
                if (fromApi) {
                    this.exShowroomPricecarwale = response.exShowroomPriceTwo;
                    this.onRoadPricecarwale = response.onRoadPriceTwo;
                }
                if(this.leadSource!='OLA' && this.leadSource!='Hero'){//CISP-2346//OLA-82//CISH-09
                    this.onRoadPrice = response.onRoadPriceOne;
                }
                this.finalPrice = response.finalPrice; //Calculation Only
                this.isSpinnerMoving = false;
            }).catch(error => {
                this.isSpinnerMoving = false;
                this.showToastMessage('Disconnected or Canceled', null, 'error');
                console.log("Error in calculating Carwale Prices:: ", error);
            });
        }
    }

    viewUploadViewFloater() {
        this.showFileUploadAndView = true;
    }
    closeUploadViewFloater(event) {
        this.showFileUploadAndView = false;
    }

    disableEverything() {
        let allElements = this.template.querySelectorAll('*');
        allElements.forEach(element =>
            element.disabled = true
        );
    }

    async checkLoanAmount(indexValue){

        let getResponse = await getPurchaseprice({ loanApplicationId: this.recordid, 'vehicleId' : this.tractorVehicleList[indexValue].recordId });
        this.vehiclePurchaseprice = parseInt(getResponse, 10);
        if(this.vehicleTypeDetail == 'New' && this.vehiclePurchaseprice != this.tractorVehicleList[indexValue].invoicePrice && this.vehiclePurchaseprice > parseInt(this.tractorVehicleList[indexValue].invoicePrice)){
            this.vehiclePurchaseprice = parseInt(this.tractorVehicleList[indexValue].invoicePrice);
        }
        const newMaxLoanAmount = (0.95 * this.vehiclePurchaseprice);
        const usedRefMaxLoanAmount = (0.90 * this.vehiclePurchaseprice);
        let loanAmountId = this.tractorVehicleList[indexValue].requiredLoanAmountId;
        let elem = this.template.querySelector(`lightning-input[data-id="${loanAmountId}"]`);
        elem.setCustomValidity("");
        if ((parseInt(this.tractorVehicleList[indexValue].requiredLoanAmount) > newMaxLoanAmount) && this.vehicleTypeDetail == 'New') {console.log('IN NEW');
            this.showToastMessage('Error', 'Loan amount cannot exceed 95% of the vehicle purchase price', 'error');
            elem.setCustomValidity('Loan amount cannot exceed 95% of the vehicle purchase price');
        }else if (parseInt(this.tractorVehicleList[indexValue].requiredLoanAmount) > usedRefMaxLoanAmount && (this.vehicleTypeDetail == 'Used' || this.vehicleTypeDetail == 'Refinance')) {console.log('IN UR');
            this.showToastMessage('Error', 'Loan amount cannot exceed 90% of the vehicle purchase price', 'error');
            elem.setCustomValidity('Loan amount cannot exceed 90% of the vehicle purchase price');
        }
        elem.reportValidity();
    }
}