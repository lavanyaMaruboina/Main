/**
 * Enhancement CISP-131
 * Developer Name : Rajat Jaiswal
 */
import { LightningElement, api,track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getFinalTermDetails from '@salesforce/apex/FinalTermscontroller.getFinalTermDetails';
import getFinalTermsRecord from '@salesforce/apex/ExternalCAMDataController.getFinalTermsRecord';
import getApplicantId from '@salesforce/apex/ExternalCAMDataController.getApplicantId';     // CISP-12521 - Offer engine call type = PayinPayout
import getFinalTermFieldDetails from '@salesforce/apex/FinalTermscontroller.getFinalTermFieldValidationDetails';
import rtoValidation from '@salesforce/apex/FinalTermscontroller.rtoValidation';
import dsmNameData from '@salesforce/apex/FinalTermscontroller.dsmNameData';
import reffnamedata from '@salesforce/apex/IND_VehicleInspectionRCLimitDetails.reffnamedata';//CISP-2522
import { updateRecord } from 'lightning/uiRecordApi';
import final_ID_FIELD from '@salesforce/schema/Final_Term__c.Id';
import Service_charges from '@salesforce/schema/Final_Term__c.Service_charges__c';
import Documentation_charges from '@salesforce/schema/Final_Term__c.Documentation_charges__c';
import Stamping_charges from '@salesforce/schema/Final_Term__c.Stamping_charges__c';
import Due_date_shift_charges from '@salesforce/schema/Final_Term__c.Due_date_shift_charges__c';
import RTO_prefix from '@salesforce/schema/Final_Term__c.RTO_prefix__c';
import Trade_certificate from '@salesforce/schema/Final_Term__c.Trade_certificate__c';
import Dealer_incentive_amount_main_dealer from '@salesforce/schema/Final_Term__c.Dealer_incentive_amount_main_dealer__c';
import Dealer_Disc_to_Customer from '@salesforce/schema/Final_Term__c.Dealer_Disc_to_Customer__c';
import Gift_through_dealer_amount from '@salesforce/schema/Final_Term__c.Gift_through_dealer_amount__c';
import DSM_IncentiveOne from '@salesforce/schema/Final_Term__c.DSM_Incentive1__c';
import DSM_NameOne from '@salesforce/schema/Final_Term__c.DSM_Name1__c';
import DSM_IncentiveTwo from '@salesforce/schema/Final_Term__c.DSM_Incentive2__c';
import DSM_NameTwo from '@salesforce/schema/Final_Term__c.DSM_Name2__c';
import Refered_By from '@salesforce/schema/Final_Term__c.Refered_By__c';
import Rreferrer_Incentive from '@salesforce/schema/Final_Term__c.Rreferrer_Incentive__c';
import Referrer_Name from '@salesforce/schema/Final_Term__c.Referrer_Name__c';
import Branch from '@salesforce/schema/Final_Term__c.Branch__c';
import Emp_No from '@salesforce/schema/Final_Term__c.Emp_No__c';
import Emp_Name from '@salesforce/schema/Final_Term__c.Emp_Name__c';
import Deal_No from '@salesforce/schema/Final_Term__c.Deal_No__c';
import Provisional_Channel_Cost from '@salesforce/schema/Final_Term__c.Provisional_Channel_Cost__c';
import DSA_pay from '@salesforce/schema/Final_Term__c.DSA_pay__c';
import Is_Loan_Amount_Change_From_CAM from '@salesforce/schema/Final_Term__c.Is_Loan_Amount_Change_From_CAM__c';
import doD2COfferEngineCallout from '@salesforce/apexContinuation/D2C_IntegrationEngine.doD2COfferEngineCallout'; // CISP-12521 - Offer engine call type = PayinPayout

import serviceChargeAndDocChargeSum from '@salesforce/label/c.Valid_sum_of_Service_Charge_and_Documentation_charge';//CISP-4785
import PassengerVehicles from '@salesforce/label/c.PassengerVehicles';
import TwoWheeler from '@salesforce/label/c.TwoWheeler';
import detailsSaved from '@salesforce/label/c.detailsSaved';
import SuccessMessage from '@salesforce/label/c.SuccessMessage';
import KindlyRetryField from '@salesforce/label/c.Kindly_Retry';
import Mandatory_fields_are_not_entered from '@salesforce/label/c.Mandatory_fields_are_not_entered';
import CreditProcessing from '@salesforce/label/c.Credit_Processing';
import Final_Terms from '@salesforce/label/c.Final_Terms';
import FivePercentageOfAmount from '@salesforce/label/c.FivePercentageOfAmount';
import tenPercentageOfAmount from '@salesforce/label/c.tenPercentageOfAmount';
import noPayout from '@salesforce/label/c.noPayout';
import onePointFivePer from '@salesforce/label/c.onePointFivePer';
import lessThanEqual from '@salesforce/label/c.lessThanEqual';
import threePercentageOfAmount from '@salesforce/label/c.threePercentageOfAmount';
import multipleOfFive from '@salesforce/label/c.multipleOfFive';
import validVehicleNo from '@salesforce/label/c.validVehicleNo';
import requiredFields from '@salesforce/label/c.requiredFields';
import dealerDiscountValidation from '@salesforce/label/c.dealerDiscountValidation';
import maxPercentage from '@salesforce/label/c.maxPercentage';
import FinalTerms from '@salesforce/label/c.FinalTerms';
import DsmError from '@salesforce/label/c.DsmError';
import vehicleRegistration from '@salesforce/label/c.vehicleRegistration';
import InvalidVehicleReg from '@salesforce/label/c.InvalidVehicleReg';
import ValidVehicleReg from '@salesforce/label/c.ValidVehicleReg';
import RegEx_Alphabets_Only from '@salesforce/label/c.RegEx_Alphabets_Only';
import documentationValidation from '@salesforce/label/c.documentationValidation';
import documentationchargesValidation from '@salesforce/label/c.documentationchargesValidation';
import nonD2CdocumentationchargesValidation from '@salesforce/label/c.nonD2CdocumentationchargesValidation';//CISP-4785
import serviceChargesValidation from '@salesforce/label/c.serviceChargesValidation';
import nonD2CserviceChargesValidation from '@salesforce/label/c.nonD2CserviceChargesValidation';//CISP-4785
import rtoPrefix from '@salesforce/label/c.rtoPrefix';
import validValue from '@salesforce/label/c.validValue';

export default class IND_LWC_ChangePayinPayoutCAM extends LightningElement {
    label = {
        rtoPrefix,
        KindlyRetryField,
        CreditProcessing,
        Final_Terms,
        RegEx_Alphabets_Only,
        validValue
    }
    isClickedOnSubmitBtn = false;
    serviceChargesValue;
    documentationChargesValue;
    stampingChargesValue;
    dueDateShiftChargesValue;
    rtoPrefixValue;
    tradeCertificateValue;

    mfrExpReimburseAmtValue;
    mfrExpReimbursePercentageValue;
    mfrExpReimburseTypeValue;
    dealerIncentiveAmountMainValue;
    dealerDiscounttoCustomerValue;
    giftThroughDealerAmountValue;
    dsmNameOneValue;
    dsmIncentiveOneValue;
    dsmNameTwoValue;
    dsmIncentiveTwoValue;
    referredbyValue;
    referrerIncentiveValue;
    referrerNameValue;
    branchValue;
    empNoValue;
    empNameValue;
    dealNoValue;
    provisionalChannelCostValue;
    dsaPayValue;

    phserviceChargesValue;
    phdocumentationChargesValue;
    phmfrExpReimburseAmtValue;
    phmfrExpReimbursePercentageValue;
    phdsmIncentiveOneValue;
    phdsmIncentiveTwoValue;
    phreferrerIncentiveValue;
    phprovisionalChannelCostValue;
    phgiftThroughDealerAmountValue
    phdealerDiscounttoCustomerValue
    phdealerIncentiveAmountMainValue

    teNewrequire=true;
    displayDsaRcu=true;

    mfrExpReimburseTypeOption;
    referredbyOption;
    dsmNameOneOption;
    dsmNameTwoOption;

    documentChargesFinAmountValid;
    documentChargesPercentageValid;
    dsmIncentiveOneValid;
    dsmIncentiveTwoValid;
    dealerIncentiveAmountMainDealerValid;
    dealerDiscounttoCustomerValid;
    giftThroughDealerAmountValid;
    mfrExpReimburseAmtValid;
    provisionalChannelCostValid;
    provisionalChannelCostMaxValid;
    provisionalChannelCostMinValid;
    provisionalChannelCostTwoValid;
    provisionalChannelCostSValid;
    serviceChargesValueValid;
    serviceChargesValueMaxValid;
    serviceChargesValueMinValid;
    stampingChargesValid;
    documentChargesMinAmountValid;
    mfrExpReimbursePercentValid;
    rerIncentiveValid;
    requiredTenureDetails;
    openFinalTermCompForTW = false; //CISP-4785

    disabledServiceCharges=false;
    disabledDocumentationCharges=false;
    disableStampingCharges=false;
    disabledueDateShiftCharges=false;
    twRefinance=false;
    twNew=false;
    disabledMfrExpReimburseAmt=true;
    disabledMfrExpReimbursePercentage=true;
    disabledMfrExpReimburseType=true;
    disabledDealerIncentiveAmountMainDealer=false;
    disabledDealerDiscounttoCustomer=false;
    disabledGiftThroughDealerAmount=false;
    disableDsmName1=false;
    disableDsmName2=false;
    disabledDsmIncentiveOne=true;
    disabledDsmIncentiveTwo=true;
    disabledReferrerIncentive=false;
    disabledReferrerName=false;
    disabledBranch=false;
    disabledEmpNo=false;
    disabledEmpName=false;
    disabledDealNo=false;
    disabledProvisionalChannelCost=false;
    disabledDsaPay=false;
    disablePayinPayout=false;
    disablesubmit=true;

    @api fromVfPage=false;
    productTypeDetail;
    vehicleTypeDetail;
    vehicleSubCategoryDetail;
    requiredLoanAmount;
    invoiceAmt;
    fundingOnExShowroom;
    fundingOnORP;
    basicPrice;
    recordid;
    @api leadSource; //CISP-10091
    @api productType; //CISP-10091
    @api finalTermId;
    @api vehicleId;
    @api showPayinPayoutModel=false;
    @api finalTermData;
    fromfinaltermDSM1=false;//CISP-2507
    fromfinaltermDSM2=false;//CISP-2507
    currentSubStage='';
    referrerNameOptions=[];//CISP-2522
    @track dsmNameOneOptionList=[];
    @track dsmNameTwoOptionList=[];
    minchargeVal=false;
    ORP;//CISP-3785
    exShowroom;//CISP-3785
    // @api toast;
    // throwError='';
    connectedCallback(){
        console.log('finalTermId',this.finalTermId);
        if (this.finalTermId) {
            getFinalTermsRecord({ finalTermId: this.finalTermId })
            .then(result => {
                if (result) {
                    this.finalTermData=result[0];
                    /*CISP-4785 Start*/
                    this.recordid = this.finalTermData?.Loan_Application__c;
                    if(this.finalTermData?.Loan_Application__r?.LeadSource != 'D2C' && this.finalTermData?.Loan_Application__r?.LeadSource != 'DSA' && this.finalTermData?.Loan_Application__r?.Product_Type__c.toLowerCase() === TwoWheeler.toLowerCase()) {
                        this.openFinalTermCompForTW = true;
                        this.showPayinPayoutModel =true;
                    } else{
                        this.openFinalTermCompForTW = false;
                    }
                    if (this.fromVfPage && !this.openFinalTermCompForTW) {/*CISP-4785 End*/
                        this.openModal(null, null, null); /*Added Params to comply with CISP-12521 */
                    }
                }
            }).catch(error=>{
                console.error('error in getFinalTermsRecord', error);
            });
        }
    }
    @api openModal(loanId,leadSource,productType){
        console.log('LoanId: '+loanId);
        console.log('leadSource> '+leadSource);
        console.log('productType> '+productType);
        /*CISP-12521 - Adding offer engine call type : payin_payout START*/
        if(leadSource && leadSource == 'D2C' && productType && productType.toLowerCase() === 'Passenger Vehicles'.toLowerCase()){
            console.log('true!')
            getApplicantId({ loanAppId: loanId })
            .then(result => {
                console.log('getApplicantId result> '+JSON.stringify(result));
                let offerEngineParams = {loanId: loanId, applicantId: result, fromScreen:'payin_payout',sliderLoanAmount: null, sliderTenure : null, incomePerMonth : null};
                doD2COfferEngineCallout(offerEngineParams).then(callresult => {
                    // Process response and set variables
                    const parsedJSON = JSON.parse(callresult);
                    let serviceCharges = parsedJSON?.application?.offerEngineDetails?.payins?.serviceCharges;
                    let docCharges = parsedJSON?.application?.offerEngineDetails?.payins?.docCharges;
                    let dlrIncentiveAmtMain = parsedJSON?.application?.offerEngineDetails?.payouts?.dlrIncentiveAmtMain;
                    console.log('serviceCharges> '+serviceCharges);
                    console.log('docCharges> '+docCharges);
                    console.log('dlrIncentiveAmtMain> '+dlrIncentiveAmtMain);

                    if(serviceCharges != null){
                        console.log('serviceCharges> ');
                        this.serviceChargesValue = serviceCharges;
                    }
                    if(docCharges != null){
                        console.log('docCharges> ');
                        this.documentationChargesValue = docCharges;
                    }
                    if(dlrIncentiveAmtMain != null){
                        console.log('dlrIncentiveAmtMain> ');
                        this.dealerIncentiveAmountMainValue = dlrIncentiveAmtMain;
                    }
                });
            });
        }
        /*CISP-12521 - Adding offer engine call type : payin_payout END*/
            this.showPayinPayoutModel =true;
            this.handlePayInPayOut();
    }
    cancelPayinPayoutModel() {
        if (this.fromVfPage) {
            self.close();
        }else{
            this.showPayinPayoutModel = false;
        }
        // let ServiceChargesInput=this.template.querySelector('lightning-input[data-id=serChar]');
        // let documentationChargesInput=this.template.querySelector('lightning-input[data-id=DocChar]');
        // let rtoPrefixInput=this.template.querySelector('lightning-input[data-id=rtoPre]');
        // let stampingChargesInput=this.template.querySelector('lightning-input[data-id=stamChar]');
        // let dueDateShiftChargesInput=this.template.querySelector('lightning-input[data-id=dueDateChar]');
        // let tradeCertificateInput=this.template.querySelector('lightning-input[data-id=tradeCerti]');
        // //let MfrExpReimburseAmt=this.template.querySelector('lightning-input[data-id=mfrExpReimAmt]');//let MfrExpReimbursePercentageInput=this.template.querySelector('lightning-input[data-id=mfrExpReimper]');//let MfrExpReimburseTypeInput=this.template.querySelector('.mfrExpReiType');
        // let dealerIncentiveAmountMainInput=this.template.querySelector('lightning-input[data-id=dealInceAmtMain]');
        // let dealerDiscountToCustomerInput=this.template.querySelector('lightning-input[data-id=dealDiscCust]');
        // let giftThroughDealerAmountInput=this.template.querySelector('lightning-input[data-id=giftDealAmt]');
        // let dsmIncentiveOneInput=this.template.querySelector('lightning-input[data-id=dsmIncent]');
        // let dsmNameOneInput=this.template.querySelector('.dsmName1');
        // let dsmIncentiveTwoInput=this.template.querySelector('lightning-input[data-id=dsmInce]');
        // let dsmNameTwoInput=this.template.querySelector('.dsmName2');
        // let referredByInput=this.template.querySelector('.refby');
        // let referrerIncentiveInput=this.template.querySelector('lightning-input[data-id=refInc]');
        // let referrerNameInput=this.template.querySelector('.refName');//CISP-2522
        // let branchInput=this.template.querySelector('lightning-input[data-id=branch]');
        // let empNoInput=this.template.querySelector('lightning-input[data-id=empNo]');
        // let empNameInput=this.template.querySelector('lightning-input[data-id=empName]');
        // let dealNoInput=this.template.querySelector('lightning-input[data-id=dealNo]');
        // let provisionalChannelCostInput=this.template.querySelector('lightning-input[data-id=proChnCost]');
        // let dsaPayInput=this.template.querySelector('lightning-input[data-id=dsapay]');

        // ServiceChargesInput.reportValidity();
        // documentationChargesInput.reportValidity();
        // rtoPrefixInput.reportValidity();
        // stampingChargesInput.reportValidity();
        // dueDateShiftChargesInput.reportValidity();
        // tradeCertificateInput.reportValidity();
        // dealerIncentiveAmountMainInput.reportValidity();
        // dealerDiscountToCustomerInput.reportValidity();
        // giftThroughDealerAmountInput.reportValidity();
        // dsmIncentiveOneInput.reportValidity();
        // dsmNameOneInput.reportValidity();
        // dsmIncentiveTwoInput.reportValidity();
        // dsmNameTwoInput.reportValidity();
        // referredByInput.reportValidity();
        // referrerIncentiveInput.reportValidity();
        // referrerNameInput.reportValidity();
        // branchInput.reportValidity();
        // empNoInput.reportValidity();
        // empNameInput.reportValidity();
        // dealNoInput.reportValidity();
        // provisionalChannelCostInput.reportValidity();
        // if(dsaPayInput){dsaPayInput.reportValidity();}

        // if(ServiceChargesInput.validity.valid===true && documentationChargesInput.validity.valid===true &&
        //     stampingChargesInput.validity.valid===true && dueDateShiftChargesInput.validity.valid===true && 
        //     rtoPrefixInput.validity.valid===true && tradeCertificateInput.validity.valid===true && 
        //     dealerIncentiveAmountMainInput.validity.valid===true && dealerDiscountToCustomerInput.validity.valid===true && 
        //     giftThroughDealerAmountInput.validity.valid===true && dsmIncentiveOneInput.validity.valid===true &&
        //     dsmNameOneInput.validity.valid===true && dsmIncentiveTwoInput.validity.valid===true && dsmNameTwoInput.validity.valid===true && 
        //     referredByInput.validity.valid===true && referrerIncentiveInput.validity.valid===true && referrerNameInput.validity.valid===true && 
        //     provisionalChannelCostInput.validity.valid===true){
        //         const selectEvent = new CustomEvent('mycustomevent', {
        //             detail: true
        //         });
        //        this.dispatchEvent(selectEvent);
        // }else{
        //     const selectEvent = new CustomEvent('mycustomevent', {
        //         detail: false
        //     });
        //    this.dispatchEvent(selectEvent);
        // }
    }
    handlePayInPayOut(){
        try {
                if(this.finalTermData){
                    let finalTermRec = this.finalTermData;
                    this.finalTermId = finalTermRec.Id;
                    this.recordid=finalTermRec.Loan_Application__c;
                    getFinalTermFieldDetails({ opportunityId: this.recordid , vehicleId : this.vehicleId})
                    .then(result => {
                        getFinalTermDetails({ opportunityId: this.recordid })
                    .then(response => {
                        if (response) {
                            this.invoiceAmt=response.invoiceAmt;
                            this.fundingOnExShowroom=response.fundingOnExShowroom;
                            this.fundingOnORP=response.fundingOnORP;
                            this.basicPrice=response.basicPrice;
                            this.currentSubStage=response.oppRecord.Sub_Stage__c;
                            if(this.currentSubStage && this.currentSubStage.toLowerCase()!=='CAM and Approval Log'.toLowerCase()){
                                this.disableEverything();
                            } 
                        }
                    }).catch(error=>{
                        console.error('getFinalTermDetails',error);
                    });
                    const finalTermData=result.finalTermVal[0];
                    this.productTypeDetail=result.productTypestr;
                    this.vehicleSubCategoryDetail=result.vehicleSubCategoryStr;
                    this.vehicleTypeDetail=result.vehicleTypeStr;
                    this.requiredTenureDetails=result.requiredTenure;
                    this.serviceChargesValueValid=finalTermData.serviceChargesValue__c;
                    this.serviceChargesValueMaxValid=finalTermData.serviceChargesValueMax__c;
                    this.serviceChargesValueMinValid=finalTermData.serviceChargesValueMin__c;
                    this.dsmIncentiveOneValid=finalTermData.DsmIncentiveOne__c;
                    this.dsmIncentiveTwoValid=finalTermData.DsmIncentiveTwo__c;
                    this.mfrExpReimburseAmtValid=finalTermData.MfrExpReimburseAmt__c;
                    this.dealerIncentiveAmountMainDealerValid=finalTermData.DealerIncentiveAmountMainDealer__c;
                    this.dealerDiscounttoCustomerValid=finalTermData.DealerDiscounttoCustomer__c;
                    this.giftThroughDealerAmountValid=finalTermData.GiftThroughDealerAmount__c;
                    this.provisionalChannelCostValid=finalTermData.ProvisionalChannelCost__c;
                    this.provisionalChannelCostTwoValid=finalTermData.ProvisionalChannelCostTwo__c;
                    this.provisionalChannelCostMaxValid=finalTermData.ProvisionalChannelCostMax__c;
                    this.provisionalChannelCostMinValid=finalTermData.ProvisionalChannelCostMin__c;
                    this.stampingChargesValid=finalTermData.StampingCharges__c;
                    this.documentChargesFinAmountValid=finalTermData.documentChargesFinAmount__c;
                    this.documentChargesPercentageValid=finalTermData.DocumentchargesPercentage__c;
                    this.documentChargesMinAmountValid=finalTermData.documentChargesMinAmount__c;
                    this.mfrExpReimbursePercentValid=finalTermData.MfrExpReimbursePercent__c;
                    this.referrerIncentiveValid=finalTermData.Referrer_Incentive_for_referrer__c;
                    this.requiredLoanAmount=parseInt(result.loanAmt, 10);
                    this.ORP=parseInt(result.ORP, 10);//CISP-3785
                    this.exShowroom=parseInt(result.exShowroom, 10);//CISP-3785
                    if(this.vehicleTypeDetail.toLowerCase()==='New'.toLowerCase()){
                        this.displayDsaRcu=false;
                    }
                    if(this.productTypeDetail.toLowerCase() === 'Passenger Vehicles'.toLowerCase()){ 
                        
                        if(this.vehicleTypeDetail.toLowerCase()==='New'.toLowerCase() || (this.vehicleSubCategoryDetail != null && this.vehicleSubCategoryDetail !='' && this.vehicleSubCategoryDetail.toLowerCase() === 'UPD'.toLowerCase())){  
                            this.disabledDealerDiscounttoCustomer = false; 
                            
                        }
                    else{
                        this.disabledDealerDiscounttoCustomer = true;
                    } 
                    if(this.vehicleTypeDetail.toLowerCase()==='New'.toLowerCase() || (this.vehicleSubCategoryDetail != null && this.vehicleSubCategoryDetail !='' && (this.vehicleSubCategoryDetail.toLowerCase() === 'UPD'.toLowerCase() || this.vehicleSubCategoryDetail.toLowerCase() === 'UEB'.toLowerCase()))){
                        this.disabledDealerIncentiveAmountMainDealer = false;
                        this.disabledGiftThroughDealerAmount = false;
                    }else{
                        this.disabledDealerIncentiveAmountMainDealer = true;
                        this.disabledGiftThroughDealerAmount = true;
                    }
                    }else{ 
                        this.disabledDealerDiscounttoCustomer = true; 
                    }
                    
                    this.productTypeDetail=finalTermRec.Loan_Application__r.Product_Type__c;
                    this.offerScreenLoanAmount=finalTermRec.Loan_Amount__c;
                    this.totalFundedPremium = finalTermRec.Loan_Application__r.Total_Funded_Premium__c;
                    this.requiredLoanAmount=parseInt(this.offerScreenLoanAmount) + this.totalFundedPremium;
                    setTimeout(() => {
                    if (finalTermRec.Service_charges__c && this.serviceChargesValue == null){ // added null check for CISP-12521
                        this.serviceChargesValue=finalTermRec.Service_charges__c;
                        this.serviceCharges(true);   
                    } else{
                        this.disablesubmit =false;
                    }
                    if (finalTermRec.Documentation_charges__c && this.documentationChargesValue == null ) { // added null check for CISP-12521
                        this.documentationChargesValue=finalTermRec.Documentation_charges__c;
                        this.documentationCharges(true);
                    } else{
                        this.disablesubmit =false;
                    }
                    if (finalTermRec.Stamping_charges__c) {
                        this.stampingChargesValue=parseInt(finalTermRec.Stamping_charges__c, 10);
                        this.stampingCharges(true);
                    } else{
                        this.disablesubmit =false;
                    }
                    if (finalTermRec.Due_date_shift_charges__c) {
                        this.dueDateShiftChargesValue=finalTermRec.Due_date_shift_charges__c;
                        this.dueDateShiftCharges(true);
                    } else{
                        this.disablesubmit =false;
                    }
                    if (finalTermRec.RTO_prefix__c) {
                        this.rtoPrefixValue=finalTermRec.RTO_prefix__c; 
                        this.rtoValidationFunction(true);
                    } else{
                        this.disablesubmit =false;
                    }
                    if (finalTermRec.Trade_certificate__c) {
                        this.tradeCertificateValue=finalTermRec.Trade_certificate__c;
                    } else{
                        this.disablesubmit =false;
                    }
                    if (finalTermRec.Mfr_Exp_Reimburse_Amt__c) {
                        this.mfrExpReimburseAmtValue=finalTermRec.Mfr_Exp_Reimburse_Amt__c;
                        this.mfrExpReimburseAmtFn(true);
                        this.mfrExpReimbursePercentage(true);
                    }
                    this.mfrExpReimburseTypeValue=finalTermRec.Mfr_Exp_Reimburse_Type__c;
                    if (finalTermRec.Dealer_incentive_amount_main_dealer__c && this.dealerIncentiveAmountMainValue == null) {   // added null check for CISP-12521
                        this.dealerIncentiveAmountMainValue=finalTermRec.Dealer_incentive_amount_main_dealer__c;
                        this.dealerIncentiveAmountMain(true);
                    }else{
                        this.disablesubmit =false;
                    }
                    if (finalTermRec.Dealer_Disc_to_Customer__c) {
                        this.dealerDiscounttoCustomerValue=finalTermRec.Dealer_Disc_to_Customer__c;
                        this.dealerDiscounttoCustomer(true);
                    }else{
                        this.disablesubmit =false;
                    }
                    if (finalTermRec.Gift_through_dealer_amount__c) {
                        this.giftThroughDealerAmountValue=finalTermRec.Gift_through_dealer_amount__c;
                        this.giftThroughDealerAmount(true);
                    }else{
                        this.disablesubmit =false;
                    }
                    if (finalTermRec.DSM_Name1__c) {
                        this.dsmNameOneValue=finalTermRec.DSM_Name1__c;
                        this.fromfinaltermDSM1=true; // CISP-2507
                        this.dsmNameOne(true);
                    }
                    if (finalTermRec.DSM_Incentive1__c) {
                        this.dsmIncentiveOneValue=finalTermRec.DSM_Incentive1__c;
                        this.dsmIncentiveOne(true);
                    }
                    if (finalTermRec.DSM_Name2__c) {
                        this.dsmNameTwoValue=finalTermRec.DSM_Name2__c;
                        this.fromfinaltermDSM2=true;// CISP-2507
                        this.dsmNameTwo(true);
                    } 
                    if (finalTermRec.DSM_Incentive2__c) {
                        this.dsmIncentiveTwoValue=finalTermRec.DSM_Incentive2__c;
                        this.dsmIncentiveTwo(true);
                    }
                    if (finalTermRec.Refered_By__c) {
                        this.referredbyValue=finalTermRec.Refered_By__c;
                        this.twRefinance=true;
                        this.disabledDsaPay=true;this.disabledDealNo=true;this.disabledEmpName=true;this.disabledEmpNo=true;this.disabledReferrerIncentive=true;this.disabledBranch=true;this.disabledReferrerName=true;
                    }else{
                        this.referredby(false);
                        this.disablesubmit =false;
                    }
                    if (finalTermRec.Rreferrer_Incentive__c) {
                        this.referrerIncentiveValue=finalTermRec.Rreferrer_Incentive__c;
                        this.referrerIncentive(true);
                    }
                    if (finalTermRec.Provisional_Channel_Cost__c) {
                        this.provisionalChannelCostValue=finalTermRec.Provisional_Channel_Cost__c;
                        let pccObj = this.provisionalChannelCost(true);
                        this.provisionalChannelCostValue = pccObj.pccValue ? pccObj.pccValue : this.provisionalChannelCostValue; 
                        this.disabledProvisionalChannelCost = pccObj.disabledPCC ? pccObj.disabledPCC : this.disabledProvisionalChannelCost;
                        if(this.productTypeDetail.toLowerCase() === 'Passenger Vehicles'.toLowerCase()){
                            this.disabledProvisionalChannelCost = true;
                        }
                    } else{
                        this.disablesubmit =false;
                    }
                    if (finalTermRec.DSA_pay__c && this.displayDsaRcu) {
                        this.dsaPayValue=finalTermRec.DSA_pay__c;
                        this.dsaPay(true);
                    } else if(this.displayDsaRcu && this.disabledDsaPay===false){
                        this.disablesubmit =false;
                    }
                    }, 1000);
                    this.referrerNameValue=finalTermRec.Referrer_Name__c;
                    this.branchValue=finalTermRec.Branch__c;
                    this.empNameValue=finalTermRec.Emp_Name__c;
                    this.empNoValue=finalTermRec.Emp_No__c;
                
                    var referredbyList=new Array();
                    referredbyList.push({ label: 'Bank branch referral', value: 'Bank branch referral' });
                    referredbyList.push({ label: 'CFD ref.', value: 'CFD ref.' });
                    referredbyList.push({ label: 'Direct sourcing', value: 'Direct sourcing' });
                    referredbyList.push({ label: 'Existing Customer Referral', value: 'Existing Customer Referral' });
                    referredbyList.push({ label: 'Ref. ref.', value: 'Ref. ref.' });
                    referredbyList.push({ label: 'Source Dealer', value: 'Source Dealer' });
                    referredbyList.push({ label: 'Walk in Customer', value: 'Walk in Customer' });
                    this.referredbyOption=referredbyList;

                    var mfrExpReimburseTypeOption=new Array();
                    mfrExpReimburseTypeOption.push({ label: 'Separate', value: 'Separate' });
                    this.mfrExpReimburseTypeOption=mfrExpReimburseTypeOption;

                    dsmNameData({ loanApplicationId: this.recordid })
                    .then(response => {
                        if(response){
                            let dsmData=[];
                            for (var key in response){
                                let dsmDataListObj={};
                                dsmDataListObj.label=response[key];
                                dsmDataListObj.value=response[key];
                                dsmDataListObj.id=key;
                                dsmData.push(dsmDataListObj);
                            }
                    this.dsmNameOneOption=dsmData;
                    this.dsmNameTwoOption=dsmData;
                        if(this.dsmNameOneOption && this.dsmNameOneOption.length>0 && this.fromfinaltermDSM1===false){//CISP-2507
                            this.disableDsmName1=false;
                            this.dsmNameOneOptionList = this.dsmNameOneOption;
                        }else{this.disableDsmName1=true;}
                        if(this.dsmNameTwoOption && this.dsmNameTwoOption.length > 1 && this.fromfinaltermDSM2===false){//CISP-2507
                            this.disableDsmName2=false;
                            this.dsmNameTwoOptionList = this.dsmNameTwoOption;
                        }else{this.disableDsmName2=true;}
                    }});
                    reffnamedata({ loanApplicationId: this.recordid }).then(result => {//Start CISP-2522
                        let options = []; for (let key in result) { options.push({ label: result[key], value: key }); }
                        this.referrerNameOptions = JSON.parse(JSON.stringify(options));
                        if(this.referrerNameValue && this.referrerNameOptions.length>0){
                            this.referrerNameValue=this.referrerNameOptions.find(opt => opt.label === this.referrerNameValue).value;
                        }
                    });//End CISP-2522
                });
    }
        } catch (error) {
            console.error('error in pay in payout', error);
        }
    }
    submitPayinPayout(){
        try {
            if(this.leadSource == 'D2C'){
                const FinalTermFields={};
                FinalTermFields[final_ID_FIELD.fieldApiName]=this.finalTermId;
                FinalTermFields[Is_Loan_Amount_Change_From_CAM.fieldApiName] = false;
                if(this.updateRecordDetails(FinalTermFields)){
                    this.showToast(SuccessMessage, detailsSaved, 'success');
                    this.disablePayinPayout= true;
                    this.isClickedOnSubmitBtn = true;
                    const selectEvent = new CustomEvent('mycustomevent', {
                        detail: true
                    });
                   this.dispatchEvent(selectEvent);
                }else{this.showToast('Error', 'Data not Saved', 'Error');}
            }else{
            let ServiceChargesInput=this.template.querySelector('lightning-input[data-id=serChar]');
            let documentationChargesInput=this.template.querySelector('lightning-input[data-id=DocChar]');
            let rtoPrefixInput=this.template.querySelector('lightning-input[data-id=rtoPre]');
            let stampingChargesInput=this.template.querySelector('lightning-input[data-id=stamChar]');
            let dueDateShiftChargesInput=this.template.querySelector('lightning-input[data-id=dueDateChar]');
            let tradeCertificateInput=this.template.querySelector('lightning-input[data-id=tradeCerti]');
            //let MfrExpReimburseAmt=this.template.querySelector('lightning-input[data-id=mfrExpReimAmt]');//let MfrExpReimbursePercentageInput=this.template.querySelector('lightning-input[data-id=mfrExpReimper]');//let MfrExpReimburseTypeInput=this.template.querySelector('.mfrExpReiType');
            let dealerIncentiveAmountMainInput=this.template.querySelector('lightning-input[data-id=dealInceAmtMain]');
            let dealerDiscountToCustomerInput=this.template.querySelector('lightning-input[data-id=dealDiscCust]');
            let giftThroughDealerAmountInput=this.template.querySelector('lightning-input[data-id=giftDealAmt]');
            let dsmIncentiveOneInput=this.template.querySelector('lightning-input[data-id=dsmIncent]');
            let dsmNameOneInput=this.template.querySelector('.dsmName1');
            let dsmIncentiveTwoInput=this.template.querySelector('lightning-input[data-id=dsmInce]');
            let dsmNameTwoInput=this.template.querySelector('.dsmName2');
            let referredByInput=this.template.querySelector('.refby');
            let referrerIncentiveInput=this.template.querySelector('lightning-input[data-id=refInc]');
            let referrerNameInput=this.template.querySelector('.refName');//CISP-2522
            let branchInput=this.template.querySelector('lightning-input[data-id=branch]');
            let empNoInput=this.template.querySelector('lightning-input[data-id=empNo]');
            let empNameInput=this.template.querySelector('lightning-input[data-id=empName]');
            let dealNoInput=this.template.querySelector('lightning-input[data-id=dealNo]');
            let provisionalChannelCostInput=this.template.querySelector('lightning-input[data-id=proChnCost]');
            let dsaPayInput=this.template.querySelector('lightning-input[data-id=dsapay]');

            ServiceChargesInput.reportValidity();
            documentationChargesInput.reportValidity();
            rtoPrefixInput.reportValidity();
            stampingChargesInput.reportValidity();
            dueDateShiftChargesInput.reportValidity();
            tradeCertificateInput.reportValidity();
            dealerIncentiveAmountMainInput.reportValidity();
            dealerDiscountToCustomerInput.reportValidity();
            giftThroughDealerAmountInput.reportValidity();
            dsmIncentiveOneInput.reportValidity();
            dsmNameOneInput.reportValidity();
            dsmIncentiveTwoInput.reportValidity();
            dsmNameTwoInput.reportValidity();
            referredByInput.reportValidity();
            referrerIncentiveInput.reportValidity();
            referrerNameInput.reportValidity();
            branchInput.reportValidity();
            empNoInput.reportValidity();
            empNameInput.reportValidity();
            dealNoInput.reportValidity();
            provisionalChannelCostInput.reportValidity();
            if(dsaPayInput){dsaPayInput.reportValidity();}
            //CISP-4785 Replaced hardcoded value with custom label
            if(this.leadSource != 'D2C' && this.leadSource != 'DSA' && this.productType.toLowerCase() == 'Two Wheeler'.toLowerCase()) {
                if((parseInt(this.serviceChargesValue, 10) + parseInt(this.documentationChargesValue, 10)) < parseInt(serviceChargeAndDocChargeSum, 10)) {
                    this.showToast("warning", 'Sum of Both Service Charge and Documentation charge should not be less than ' + serviceChargeAndDocChargeSum, 'warning');
                    this.disabledDocumentationCharges = false;
                    this.disabledServiceCharges = false;
                    this.minchargeVal = true;
                }else {
                    this.minchargeVal = false;
                }
            } else{
                if((parseInt(this.serviceChargesValue, 10) + parseInt(this.documentationChargesValue, 10))<1400){//CISP-10189 changed 1200 to 1400
                    this.showToast("warning",'Sum of Both Service Charge and Documentation charge should not be less than 1400','warning');
                    this.disabledDocumentationCharges=false;this.disabledServiceCharges=false;this.minchargeVal=true;}else{this.minchargeVal=false;}
            }
            if(!this.minchargeVal && ServiceChargesInput.validity.valid===true && documentationChargesInput.validity.valid===true &&
                stampingChargesInput.validity.valid===true && dueDateShiftChargesInput.validity.valid===true && 
                rtoPrefixInput.validity.valid===true && tradeCertificateInput.validity.valid===true && 
                dealerIncentiveAmountMainInput.validity.valid===true && dealerDiscountToCustomerInput.validity.valid===true && 
                giftThroughDealerAmountInput.validity.valid===true && dsmIncentiveOneInput.validity.valid===true &&
                dsmNameOneInput.validity.valid===true && dsmIncentiveTwoInput.validity.valid===true && dsmNameTwoInput.validity.valid===true && 
                referredByInput.validity.valid===true && referrerIncentiveInput.validity.valid===true && referrerNameInput.validity.valid===true && 
                provisionalChannelCostInput.validity.valid===true){
                if(this.vehicleTypeDetail.toLowerCase()!=='New'.toLowerCase()){
                    if(dsaPayInput.validity.valid===true){
                        if(!this.minchargeVal){this.handleSave();}
                    }
                }else{
                    if(!this.minchargeVal){this.handleSave();}
                    }
            }else{
                this.showToast('Error', Mandatory_fields_are_not_entered, 'Error');
            }}

        }catch(error){console.error('from submitPayinPayout',error);}
    }

    handleSave(){
        try {
            if(this.referrerNameValue && this.referrerNameOptions.length>0){//CISP-2522
                this.referrerNameValue=this.referrerNameOptions.find(opt => opt.value === this.referrerNameValue).label;}//CISP-2522
            this.flagToCheckValidity=true;
            const FinalTermFields={};
            FinalTermFields[final_ID_FIELD.fieldApiName]=this.finalTermId;
            if(this.serviceChargesValue){FinalTermFields[Service_charges.fieldApiName]=this.serviceChargesValue.toString();}
            if(this.documentationChargesValue){FinalTermFields[Documentation_charges.fieldApiName]=this.documentationChargesValue.toString();}
            if(this.stampingChargesValue){FinalTermFields[Stamping_charges.fieldApiName]=this.stampingChargesValue.toString();}
            if(this.dueDateShiftChargesValue){FinalTermFields[Due_date_shift_charges.fieldApiName]=String(this.dueDateShiftChargesValue);}
            if(this.rtoPrefixValue){FinalTermFields[RTO_prefix.fieldApiName]=this.rtoPrefixValue;}
            if(this.tradeCertificateValue){FinalTermFields[Trade_certificate.fieldApiName]=this.tradeCertificateValue.toString();}
            //if(this.mfrExpReimburseAmtValue){FinalTermFields[Mfr_Exp_Reimburse_Amt.fieldApiName]=this.mfrExpReimburseAmtValue.toString();}
            //FinalTermFields[Mfr_Exp_Reimburse_Type.fieldApiName]=this.mfrExpReimburseTypeValue;
            //FinalTermFields[Mfr_Exp_Reimburse_percent.fieldApiName]=this.mfrExpReimbursePercentageValue;
            if(this.dealerIncentiveAmountMainValue){FinalTermFields[Dealer_incentive_amount_main_dealer.fieldApiName]=String(this.dealerIncentiveAmountMainValue);}
            if(this.dealerDiscounttoCustomerValue){FinalTermFields[Dealer_Disc_to_Customer.fieldApiName]=String(this.dealerDiscounttoCustomerValue);}
            if(this.giftThroughDealerAmountValue){FinalTermFields[Gift_through_dealer_amount.fieldApiName]=String(this.giftThroughDealerAmountValue);}        
            if(this.dsmIncentiveOneValue){FinalTermFields[DSM_IncentiveOne.fieldApiName]=this.dsmIncentiveOneValue.toString();}
            if(this.dsmNameOneValue){FinalTermFields[DSM_NameOne.fieldApiName]=this.dsmNameOneValue;}
            if(this.dsmIncentiveTwoValue){FinalTermFields[DSM_IncentiveTwo.fieldApiName]=this.dsmIncentiveTwoValue.toString();}
            if(this.dsmNameTwoValue){FinalTermFields[DSM_NameTwo.fieldApiName]=this.dsmNameTwoValue;}
            if(this.referredbyValue){FinalTermFields[Refered_By.fieldApiName]=this.referredbyValue;}
            if(this.referrerIncentiveValue){FinalTermFields[Rreferrer_Incentive.fieldApiName]=String(this.referrerIncentiveValue);}
            if(this.referrerNameValue){FinalTermFields[Referrer_Name.fieldApiName]=this.referrerNameValue;}
            if(this.branchValue){FinalTermFields[Branch.fieldApiName]=this.branchValue.toString();}
            if(this.empNoValue){FinalTermFields[Emp_No.fieldApiName]=this.empNoValue.toString();}
            if(this.empNameValue){FinalTermFields[Emp_Name.fieldApiName]=this.empNameValue.toString();}
            if(this.dealNoValue){FinalTermFields[Deal_No.fieldApiName]=this.dealNoValue;}
            if(this.provisionalChannelCostValue){FinalTermFields[Provisional_Channel_Cost.fieldApiName]=this.provisionalChannelCostValue.toString();}
            if(this.dsaPayValue){FinalTermFields[DSA_pay.fieldApiName]=String(this.dsaPayValue);}
            if(this.updateRecordDetails(FinalTermFields)){
                this.showToast(SuccessMessage, detailsSaved, 'success');
                this.disablePayinPayout= true;
                this.isClickedOnSubmitBtn = true;
                const selectEvent = new CustomEvent('mycustomevent', {
                    detail: true
                });
               this.dispatchEvent(selectEvent);
                // setTimeout(() => {
                //     window.location.reload();
                // }, 1000);
                // this.throwError=detailsSaved;
                // this.handleSubCheckEligibilityButton();
            }else{this.showToast('Error', 'Data not Saved', 'Error');
        } 
        } catch (error) {
            console.error('from handle save',error);
        }
    }
    async updateRecordDetails(fields){
        try {
            const recordInput={ fields };
            await updateRecord(recordInput)
                .then(() => {
                    return true;
                }).catch(error => {
                    console.error('error : ',error);
                    this.showToast("Error", 'Data not Saved', 'error');
                    // this.throwError='Data not Saved';
                });
        } catch (error) {
            console.error('from updateRecordDetails',error);
        }
    }
    
    renderedCallback(){
        /* CISP-10091 Start*/
        if(this.leadSource === 'D2C' && (this.productType.toLowerCase() === 'Passenger Vehicles'.toLowerCase() || this.productType.toLowerCase() == 'Two Wheeler'.toLowerCase())){
            this.disableEverything();
        }
        /* CISP-10091 End*/
        if((this.currentSubStage && this.currentSubStage.toLowerCase()!=='CAM and Approval Log'.toLowerCase()) || this.fromVfPage){
            this.disableEverything();
        }
    }
    disableEverything(){
        let allElements=this.template.querySelectorAll('*');
        allElements.forEach(element =>{
            element.disabled=true;
         });
        let closebtn=this.template.querySelectorAll('.closebtn');
        closebtn.forEach(element =>{
            element.disabled=false;
         });
        if(this.leadSource === 'D2C' && !this.isClickedOnSubmitBtn){
            let submitbtn=this.template.querySelectorAll('.submitbtn');
            submitbtn.forEach(element =>{
                element.disabled=false;
            });
        }
    }

    //Pay In event handler
    handleServiceCharges(event) {
        this.serviceChargesValue = event.target.value;
        this.serviceCharges(false);
    }
    handleDocumentationCharges(event) {
        this.documentationChargesValue = event.target.value;
        this.documentationCharges(false);
    }
    handleStampingCharges(event) {
        this.stampingChargesValue = event.target.value;
        this.stampingCharges(false);
    }
    handleDueDateShiftCharges(event) {
        this.dueDateShiftChargesValue = event.target.value;
        this.dueDateShiftCharges(false);
    }
    handleRTOPrefix(event) {
        this.rtoPrefixValue = event.target.value;
        this.rtoValidationFunction(false);
    }
    rtoValidationFunction(forDisablefield) {
        if(this.rtoPrefixValue){
            this.rtoAlnu = this.rtoPrefixValue.substring(0, 4);
             rtoValidation({ loanApplicationId: this.recordid, rtoAlnu: this.rtoAlnu })
                .then(result => {
                    let response = JSON.parse(result);
                    let validVehicleNoToast = this.rtoPrefixFunction(forDisablefield, response);
                    if (validVehicleNoToast) {
                        this.showToast("warning", validVehicleNo, 'warning');
                    }
                 });
        }
    }
    handleTradeCertificate(event){this.tradeCertificateValue=event.target.value;}

    //Pay Out event handler
    handleMfrExpReimburseAmt(event){
        this.mfrExpReimburseAmtValue=event.target.value;
        this.mfrExpReimbursePercentageValue=(100 - ((parseInt(this.requiredLoanAmount, 10) - this.mfrExpReimburseAmtValue) / parseInt(this.requiredLoanAmount, 10) * 100)).toFixed(2);
        this.mfrExpReimburseAmtFn(false);}
    handleMfrExpReimbursePercentage(event) {
        this.mfrExpReimbursePercentageValue = event.target.value;
        this.mfrExpReimburseAmtValue = (this.mfrExpReimbursePercentageValue * parseInt(this.requiredLoanAmount, 10)) / 100;
        this.mfrExpReimbursePercentage(false);
    }
    handleMfrExpReimburseType(event){this.mfrExpReimburseTypeValue=event.target.value;}
    handleDsmNameOne(event) {
        this.dsmNameOneValue = event.target.value;
        this.dsmIncentiveOneValue = null; //CISP-2507
        this.disabledDsmIncentiveOne = false; //CISP-2507
        this.dsmNameOne(false);
    }
    handleDealerIncentiveAmountMainDealer(event) {
        this.dealerIncentiveAmountMainValue = event.target.value;
        this.dealerIncentiveAmountMain(false);
    }
    handleDealerDiscounttoCustomer(event) {
        this.dealerDiscounttoCustomerValue = event.target.value;
        this.dealerDiscounttoCustomer(false);
    }
    handleGiftThroughDealerAmount(event) {
        this.giftThroughDealerAmountValue = event.target.value;
        this.giftThroughDealerAmount(false);
    }
    handleDsmIncentiveOne(event) {
        this.dsmIncentiveOneValue = event.target.value;
        this.dsmIncentiveOne(false);
    }
    handleDsmNameTwo(event) {
        this.dsmNameTwoValue=event.target.value;
        this.dsmIncentiveTwoValue=null; //CISP-2507
        this.disabledDsmIncentiveTwo=false; //CISP-2507
        this.dsmNameTwo(false);
    }  
    handleDsmIncentiveTwo(event) {
        this.dsmIncentiveTwoValue = event.target.value;
        this.dsmIncentiveTwo(false);
    }
    handleReferredby(event){
        this.referredbyValue=event.target.value;
        this.referredby(this.referredbyValue);}
    referredby(referredbyValue){
        if(referredbyValue==='Bank branch referral'){
            this.dsaPayValue='';this.disabledDsaPay=true;this.disabledBranch=false;this.disabledEmpName=false;this.disabledEmpNo=false;this.disabledReferrerName=true;this.referrerNameValue='';this.disabledReferrerIncentive=true;this.referrerIncentiveValue='';this.disabledDealNo=true;this.dealNoValue='';
        }else if(this.referredbyValue==='CFD ref.'){
            this.dsaPayValue='';this.disabledDsaPay=true;this.disabledBranch=false;this.disabledEmpName=false;this.disabledEmpNo=false;this.disabledReferrerName=true;this.referrerNameValue='';this.disabledReferrerIncentive=true;this.referrerIncentiveValue='';this.disabledDealNo=true;this.dealNoValue='';
        } else if(this.referredbyValue==='Existing Customer Referral'){
            this.dsaPayValue='';this.disabledDsaPay=true;this.disabledDealNo=false;this.disabledBranch=true;this.branchValue='';this.disabledEmpName=true;this.empNameValue='';this.disabledEmpNo=true;this.empNoValue='';this.disabledReferrerName=true;this.referrerNameValue='';this.disabledReferrerIncentive=true;this.referrerIncentiveValue='';
        } else if(this.referredbyValue==='Ref. ref.'){
            this.disabledDsaPay=true;this.disabledReferrerIncentive=false;this.disabledBranch=true;this.branchValue='';this.disabledEmpName=true;this.empNameValue='';this.disabledEmpNo=true;this.empNoValue='';this.disabledReferrerName=false;this.disabledDealNo=true;this.dealNoValue='';
        }else{
            this.dsaPayValue='';this.disabledDsaPay=true;this.disabledDealNo=true;this.dealNoValue='';this.disabledEmpName=true;this.empNameValue='';this.disabledEmpNo=true;this.empNoValue='';this.disabledReferrerIncentive=true;this.referrerIncentiveValue='';this.disabledBranch=true;this.branchValue='';this.disabledReferrerName=true;this.referrerNameValue='';}
    }
    handlereferrerIncentive(event){
        this.referrerIncentiveValue=event.target.value;
        this.referrerIncentive(false);
    }
    handleReferrerName(event){this.referrerNameValue = event.target.value;}
    handleBranch(event){this.branchValue=event.target.value;}
    handleEmpNo(event){this.empNoValue=event.target.value;}
    handleEmpName(event){this.empNameValue=event.target.value;}
    handleDealNo(event){this.dealNoValue=event.target.value;}
    handleProvisionalChannelCost(event){
        this.provisionalChannelCostValue = event.target.value;
        let pccObj = this.provisionalChannelCost(false);
        this.provisionalChannelCostValue = pccObj.pccValue ? pccObj.pccValue : this.provisionalChannelCostValue; 
        this.disabledProvisionalChannelCost = pccObj.disabledPCC ? pccObj.disabledPCC : this.disabledProvisionalChannelCost; 
    }
    handleDSAPay(event) {
        this.dsaPayValue = event.target.value;
        this.dsaPay(false);
    }
    
    // Pay In functions
    serviceCharges(forDisablefield) {
        try {
            let disablefield =true;
            let checkServiceChargesValue = parseInt(this.serviceChargesValue, 10) % this.serviceChargesValueValid;
            let elem = this.template.querySelector('lightning-input[data-id=serChar]');
            let checkServiceChargesValueMax = (this.serviceChargesValueMaxValid * parseInt(this.requiredLoanAmount, 10)) / 100;
            let checkServiceChargesValueMin = (this.serviceChargesValueMinValid * parseInt(this.requiredLoanAmount, 10)) / 100;
            //CISP-3785 start
            let gstValue =  parseInt(this.serviceChargesValue, 10)*18.0/118;
            gstValue = Math.round(gstValue * 100) / 100;
             let docAmount = parseInt(this.serviceChargesValue, 10) - gstValue;
             //CISP-3785 end
            elem.setCustomValidity("");
            //CISP-4785 No min value in service charges
            if(this.leadSource != 'D2C' && this.leadSource != 'DSA') {
                if (this.productTypeDetail.toLowerCase() === TwoWheeler.toLowerCase() && this.serviceChargesValue && (parseInt(this.serviceChargesValue, 10) > parseInt(checkServiceChargesValueMax, 10))) {
                    disablefield =false;
                    elem.setCustomValidity(nonD2CserviceChargesValidation);
                    elem.reportValidity();
                }
            }else {
                if (this.productTypeDetail.toLowerCase() === TwoWheeler.toLowerCase() && this.serviceChargesValue && (parseInt(this.serviceChargesValue, 10) < parseInt(checkServiceChargesValueMin, 10) || parseInt(this.serviceChargesValue, 10) > parseInt(checkServiceChargesValueMax, 10))) {
                    disablefield =false;
                    elem.setCustomValidity(serviceChargesValidation);
                    elem.reportValidity();
                }
            }
            if (this.productTypeDetail.toLowerCase() === PassengerVehicles.toLowerCase() && this.serviceChargesValue && parseInt(docAmount, 10) > parseInt(checkServiceChargesValueMax, 10)) {
                disablefield =false;
                elem.setCustomValidity('Document value - '+docAmount+', GST value - '+gstValue+' Document value should be within 3% of finance amount. Please enter service charges (incl. GST) within the range');
                elem.reportValidity();
            }else if (checkServiceChargesValue !== 0) {
                disablefield =false;
                elem.setCustomValidity('Please enter service charges in multiples of 5');
                elem.reportValidity();
            }
            if (this.serviceChargesValue < 0) {
                disablefield =false;
                elem.setCustomValidity(validValue);
                elem.reportValidity();
            }
            if(this.disablesubmit){
                this.disablesubmit =disablefield;
            }
            
            if(forDisablefield){
                if (this.productTypeDetail.toLowerCase() !== TwoWheeler.toLowerCase()) {
                    this.disabledServiceCharges=false;
                }else{
                    this.disabledServiceCharges=disablefield;
                }
                if(!disablefield){
                    this.phserviceChargesValue = this.serviceChargesValue;
                    this.serviceChargesValue = null;
                    this.disabledServiceCharges = false;
                }else{
                    this.disabledServiceCharges=true;
                }
            }
            // this.disablePayinPayout=this.disablesubmit;
        } catch (error) {
            console.error(error);
        }
    }
        documentationCharges(forDisablefield) {
        try {
            let disablefield =true;
            let elem = this.template.querySelector('lightning-input[data-id=DocChar]');
             //CISP-3785 start
             let checkDocChargesValue = parseInt(this.documentationChargesValue, 10) % 5;
             let gstValue =  parseInt(this.documentationChargesValue, 10)*18.0/118;
             gstValue = Math.round(gstValue * 100) / 100;
              let docAmount = parseInt(this.documentationChargesValue, 10) - gstValue;
              //CISP-3785 end
            elem.setCustomValidity("");
            if (this.productTypeDetail.toLowerCase() === PassengerVehicles.toLowerCase() && (this.vehicleTypeDetail.toLowerCase() === 'used'.toLowerCase() || this.vehicleTypeDetail.toLowerCase() === 'Refinance'.toLowerCase() || this.vehicleTypeDetail.toLowerCase() === 'new'.toLowerCase())) {
                let docChargesValuePv = (this.documentChargesPercentageValid * parseInt(this.requiredLoanAmount, 10)) / 100;
                    if ( parseInt(docAmount, 10) > parseInt(docChargesValuePv, 10)) {
                        disablefield =false;
                        elem.setCustomValidity('Document value - '+docAmount+', GST value -'+gstValue+' '+documentationValidation);
                        elem.reportValidity();
                    }
                     //CISP-3785
                else if (checkDocChargesValue !== 0) {
                    disablefield =false;
                    elem.setCustomValidity('Please enter documentation charges in multiples of 5');
                    elem.reportValidity();
                }
            }
            if (this.productTypeDetail.toLowerCase() === TwoWheeler.toLowerCase() && (this.vehicleTypeDetail.toLowerCase() === 'used'.toLowerCase() || this.vehicleTypeDetail.toLowerCase() === 'Refinance'.toLowerCase() || this.vehicleTypeDetail.toLowerCase() === 'new'.toLowerCase())) {
                let docChargesValueTw = (this.documentChargesPercentageValid * parseInt(this.requiredLoanAmount, 10)) / 100;
                if (this.requiredLoanAmount < this.documentChargesFinAmountValid) {
                    if (parseInt(this.documentationChargesValue, 10) !== parseInt(docChargesValueTw, 10)) {
                        disablefield =false;
                        elem.setCustomValidity(threePercentageOfAmount + ' ' + parseInt(docChargesValueTw, 10).toString());
                        elem.reportValidity();
                    }
                } else {
                    //CISP-4785 No min value in documentation charges
                    if(this.leadSource != 'D2C' && this.leadSource != 'DSA') {
                        if (parseInt(this.documentationChargesValue, 10) > parseInt(docChargesValueTw, 10)) {
                            disablefield =false;
                            elem.setCustomValidity(nonD2CdocumentationchargesValidation);
                            elem.reportValidity();
                        }
                    } else {
                        if (parseInt(this.documentationChargesValue, 10) < this.documentChargesMinAmountValid || parseInt(this.documentationChargesValue, 10) > parseInt(docChargesValueTw, 10)) {
                            disablefield =false;
                            elem.setCustomValidity(documentationchargesValidation);
                            elem.reportValidity();
                        }
                    }
                }
            }
            if (this.documentationChargesValue < 0) {
                disablefield =false;
                elem.setCustomValidity(validValue);
                elem.reportValidity();
            }
            if(this.disablesubmit){
                this.disablesubmit =disablefield;
            }
            if(forDisablefield){
                this.disabledDocumentationCharges=disablefield;
                if(!disablefield){
                    this.phdocumentationChargesValue = this.documentationChargesValue;
                    this.documentationChargesValue = null;
                }
            }
            // this.disablePayinPayout=this.disablesubmit;
        } catch (error) {
            console.error(error);
        }
        }
    stampingCharges(forDisablefield) {
    try {
        let disablefield =true;
        let elem = this.template.querySelector('lightning-input[data-id=stamChar]');
        elem.setCustomValidity("");
        if (this.stampingChargesValue < this.stampingChargesValid) {
            disablefield =false;
            elem.setCustomValidity(lessThanEqual + this.stampingChargesValid);
            elem.reportValidity();
        }
        if (this.stampingChargesValue < 0) {
            disablefield =false;
            elem.setCustomValidity(validValue);
            elem.reportValidity();
        }
        if(this.disablesubmit){
            this.disablesubmit =disablefield;
        }
        if(forDisablefield){
            this.disableStampingCharges=disablefield;
        }
        // this.disablePayinPayout=this.disablesubmit;
    } catch (error) {
        console.error(error);
    }
}
    dueDateShiftCharges(forDisablefield) {
    try {
        let disablefield =true;
        let elem = this.template.querySelector('lightning-input[data-id=dueDateChar]');
        elem.setCustomValidity("");
        if (this.dueDateShiftChargesValue < 0) {
            disablefield =false;
            elem.setCustomValidity(validValue);
            elem.reportValidity();
        }
        if(this.disablesubmit){
            this.disablesubmit =disablefield;
        }
        if(forDisablefield){
            this.disabledueDateShiftCharges=disablefield;
        }
        // this.disablePayinPayout=this.disablesubmit;
    } catch (error) {
        console.error(error);
    }
}
    rtoPrefixFunction(forDisablefield, response) {
    try {
        let disablefield =true;
        let elem = this.template.querySelector('lightning-input[data-id=rtoPre]');
        elem.setCustomValidity('');
        if (response.message === ValidVehicleReg || response.message === InvalidVehicleReg) {
            disablefield =false;
            return validVehicleNo;
        }
        if(response.message==='InValid Vehicle Registration Number'){
            disablefield =false;
            elem.setCustomValidity(vehicleRegistration);
            elem.reportValidity();
        }
        if(this.disablesubmit){
            this.disablesubmit =disablefield;
        }
        if(forDisablefield){
            this.twNew=disablefield;
        }
        // this.disablePayinPayout=this.disablesubmit;
    } catch (error) {
        console.error(error);
    }
}

// Pay Out Functions
mfrExpReimburseAmtFn(forDisablefield) {
    try {
        let disablefield =true;
        let elem = this.template.querySelector('lightning-input[data-id=mfrExpReimAmt]');
        let element = this.template.querySelector('lightning-input[data-id=mfrExpReimper]');
        let checkMfrExpReimburseAmt = (this.mfrExpReimburseAmtValid * parseInt(this.requiredLoanAmount, 10)) / 100;
        elem.setCustomValidity("");
        element.setCustomValidity("");
        if (this.mfrExpReimburseAmtValue && (this.mfrExpReimburseAmtValue > parseInt(checkMfrExpReimburseAmt, 10))) {
            disablefield =false;
            elem.setCustomValidity(tenPercentageOfAmount);
            elem.reportValidity();
        }
        if (this.mfrExpReimburseAmtValue < 0) {
            disablefield =false;
            elem.setCustomValidity(validValue);
            elem.reportValidity();
            element.reportValidity();
        }
        if(this.disablesubmit){
            this.disablesubmit =disablefield;
        }
        if(forDisablefield){
            this.disabledMfrExpReimburseAmt=disablefield;
        }
        // this.disablePayinPayout=this.disablesubmit;
    } catch (error) {
        console.error(error);
    }
}
mfrExpReimbursePercentage(forDisablefield) {
    try {
        let disablefield =true;
        let elem = this.template.querySelector('lightning-input[data-id=mfrExpReimper]');
        let element = this.template.querySelector('lightning-input[data-id=mfrExpReimAmt]');
        element.setCustomValidity("");
        elem.setCustomValidity("");
        if (this.mfrExpReimbursePercentageValue > this.mfrExpReimbursePercentValid) {
            disablefield =false;
            elem.setCustomValidity(tenPercentageOfAmount);
            elem.reportValidity();
        }
        if (this.mfrExpReimbursePercentageValue < 0) {
            disablefield =false;
            elem.setCustomValidity(validValue);
            elem.reportValidity();
            element.reportValidity();
        }
        if(this.disablesubmit){
            this.disablesubmit =disablefield;
        }
        if(forDisablefield){
            this.disabledMfrExpReimbursePercentage=disablefield;
        }
        // this.disablePayinPayout=this.disablesubmit;
    } catch (error) {
        console.error(error);
    }
}
dealerIncentiveAmountMain(forDisablefield) {
    try {
        let disablefield =true;
        let elem = this.template.querySelector('lightning-input[data-id=dealInceAmtMain]');
        if (this.productTypeDetail.toLowerCase() === 'Two Wheeler'.toLowerCase() && (this.vehicleTypeDetail.toLowerCase() === 'new'.toLowerCase())) {

            let checkDealerIncentiveAmountMainH = (this.dealerIncentiveAmountMainDealerValid * parseInt(this.requiredLoanAmount, 10)) / 100;
            elem.setCustomValidity("");
            if (this.dealerIncentiveAmountMainValue && (this.dealerIncentiveAmountMainValue > parseInt(checkDealerIncentiveAmountMainH, 10))) {
                disablefield =false;
                elem.setCustomValidity(FivePercentageOfAmount);
                elem.reportValidity();
            }
        } else if (this.productTypeDetail.toLowerCase() === 'Passenger Vehicles'.toLowerCase()) {
            let checkDealerIncentiveAmountMainC = (this.dealerIncentiveAmountMainDealerValid * parseInt(this.requiredLoanAmount, 10)) / 100;
            elem.setCustomValidity("");
            if (this.dealerIncentiveAmountMainValue && (this.dealerIncentiveAmountMainValue > parseInt(checkDealerIncentiveAmountMainC, 10))) {
                disablefield =false;
                elem.setCustomValidity(tenPercentageOfAmount);
                elem.reportValidity();

            }
        } else if (this.productTypeDetail.toLowerCase() === 'Two Wheeler'.toLowerCase() && (this.vehicleTypeDetail.toLowerCase() === 'Refinance'.toLowerCase() || this.vehicleTypeDetail.toLowerCase() === 'used'.toLowerCase())) {
            elem.setCustomValidity("");
            if (this.dealerIncentiveAmountMainValue >= 1) {
                disablefield =false;
                elem.setCustomValidity(noPayout);
                elem.reportValidity();
            }
        }
        if (this.dealerIncentiveAmountMainValue < 0) {
            disablefield =false;
            elem.setCustomValidity(validValue);
            elem.reportValidity();
        }
        if(this.disablesubmit){
            this.disablesubmit =disablefield;
        }
        if(forDisablefield){
            this.disabledDealerIncentiveAmountMainDealer=disablefield;
            if(!disablefield){
                this.phdealerIncentiveAmountMainValue = this.dealerIncentiveAmountMainValue;
                this.dealerIncentiveAmountMainValue = null;
            }
        }
        // this.disablePayinPayout=this.disablesubmit;
    } catch (error) {
        console.error(error);
    }
}
dealerDiscounttoCustomer(forDisablefield)  {
    try {
        let disablefield =true;
        let checkDealerDiscounttoCustomer;
        let elem = this.template.querySelector('lightning-input[data-id=dealDiscCust]');
        elem.setCustomValidity("");
        if (this.productTypeDetail.toLowerCase() === 'Passenger Vehicles'.toLowerCase() && (this.vehicleTypeDetail.toLowerCase() === 'new'.toLowerCase())) {
            if (this.fundingOnExShowroom === true) {
                checkDealerDiscounttoCustomer = (this.dealerDiscounttoCustomerValid * parseInt(this.exShowroom, 10)) / 100;
            }
            if (this.fundingOnORP === true) {
                checkDealerDiscounttoCustomer = (this.dealerDiscounttoCustomerValid * parseInt(this.ORP, 10)) / 100;
            }
            if (this.dealerDiscounttoCustomerValue && (this.dealerDiscounttoCustomerValue > parseInt(checkDealerDiscounttoCustomer, 10))) {
                disablefield =false;
                elem.setCustomValidity(dealerDiscountValidation);
                elem.reportValidity();
            }
        } else if ((this.productTypeDetail.toLowerCase() === 'Passenger Vehicles'.toLowerCase() || this.productTypeDetail.toLowerCase() === 'Two Wheeler'.toLowerCase()) && (this.vehicleSubCategoryDetail && this.vehicleSubCategoryDetail.toLowerCase() === 'UPD'.toLowerCase())) {
            checkDealerDiscounttoCustomer = (this.dealerDiscounttoCustomerValid * parseInt(this.requiredLoanAmount, 10)) / 100;
            if (this.dealerDiscounttoCustomerValue && (this.dealerDiscounttoCustomerValue > parseInt(checkDealerDiscounttoCustomer, 10))) {
                disablefield =false;
                elem.setCustomValidity(maxPercentage);
                elem.reportValidity();
            }
        } else {
            if (this.fundingOnExShowroom === true) {
                checkDealerDiscounttoCustomer = (this.dealerDiscounttoCustomerValid * parseInt(this.exShowroom, 10)) / 100;
            }
            if (this.fundingOnORP === true) {
                checkDealerDiscounttoCustomer = (this.dealerDiscounttoCustomerValid * parseInt(this.ORP, 10)) / 100;
            }
            if (this.dealerDiscounttoCustomerValue && (this.dealerDiscounttoCustomerValue > parseInt(checkDealerDiscounttoCustomer, 10))) {
                disablefield =false;
                elem.setCustomValidity(dealerDiscount);
                elem.reportValidity();
            }
        }
        if (this.dealerDiscounttoCustomerValue < 0) {
            disablefield =false;
            elem.setCustomValidity(validValue);
            elem.reportValidity();
        }
        if(this.disablesubmit){
            this.disablesubmit =disablefield;
        }
        if(forDisablefield){
           this.disabledDealerDiscounttoCustomer=disablefield;
           if(!disablefield){
               this.phdealerDiscounttoCustomerValue = this.dealerDiscounttoCustomerValue;
               this.dealerDiscounttoCustomerValue = null;
           }
        }
        // this.disablePayinPayout=this.disablesubmit;
    } catch (error) {
        console.error(error);
    }
}
giftThroughDealerAmount(forDisablefield) {
    try {
        let disablefield =true;
        let elem = this.template.querySelector('lightning-input[data-id=giftDealAmt]');
        if (this.productTypeDetail.toLowerCase() === 'Two Wheeler'.toLowerCase() && (this.vehicleTypeDetail.toLowerCase() === 'new'.toLowerCase())) {
            let checkGiftThroughDealerAmountH = (this.giftThroughDealerAmountValid * parseInt(this.requiredLoanAmount, 10)) / 100;
            elem.setCustomValidity("");
            if (this.giftThroughDealerAmountValue && (this.giftThroughDealerAmountValue > parseInt(checkGiftThroughDealerAmountH, 10))) {
                disablefield =false;
                elem.setCustomValidity(FivePercentageOfAmount);
                elem.reportValidity();
            }
        } else if (this.productTypeDetail.toLowerCase() === 'Passenger Vehicles'.toLowerCase()) {
            let checkGiftThroughDealerAmountC = (this.giftThroughDealerAmountValid * parseInt(this.requiredLoanAmount, 10)) / 100;
            elem.setCustomValidity("");
            if (this.giftThroughDealerAmountValue && (this.giftThroughDealerAmountValue > parseInt(checkGiftThroughDealerAmountC, 10))) {
                disablefield =false;
                elem.setCustomValidity(tenPercentageOfAmount);
                elem.reportValidity();
            }
        } else if (this.productTypeDetail.toLowerCase() === 'Two Wheeler'.toLowerCase() && (this.vehicleTypeDetail.toLowerCase() === 'Refinance'.toLowerCase() || this.vehicleTypeDetail.toLowerCase() === 'used'.toLowerCase())) {
            elem.setCustomValidity("");
            if (this.giftThroughDealerAmountValue >= 1) {
                disablefield =false;
                elem.setCustomValidity(noPayout);
                elem.reportValidity();
            }
        }
        if (this.giftThroughDealerAmountValue < 0) {
            disablefield =false;
            elem.setCustomValidity(validValue);
            elem.reportValidity();
        }
        if(this.disablesubmit){
            this.disablesubmit =disablefield;
        }
        if(forDisablefield){
            this.disabledGiftThroughDealerAmount=disablefield;
            if(!disablefield){
                this.phgiftThroughDealerAmountValue = this.giftThroughDealerAmountValue;
                this.giftThroughDealerAmountValue = null;
            }
        }
        // this.disablePayinPayout=this.disablesubmit;
    } catch (error) {
        console.error(error);
    }
}
dsmNameOne(forDisablefield) {
    try {
        let disablefield =true;
        let elem = this.template.querySelector('.dsmName1');
        elem.setCustomValidity('');
        if (this.dsmNameOneValue && this.dsmNameTwoValue && this.dsmNameOneValue === this.dsmNameTwoValue) {
            disablefield =false;
            elem.setCustomValidity(DsmError);
            elem.reportValidity();
        }
        if(this.disablesubmit){
            this.disablesubmit =disablefield;
        }
        if(forDisablefield){
            this.disableDsmName1=disablefield;
        }
        // this.disablePayinPayout=this.disablesubmit;
    } catch (error) {
        console.error(error);
    }
}
dsmIncentiveOne(forDisablefield) {
    try {
        let disablefield =true;
        let elem = this.template.querySelector('lightning-input[data-id=dsmIncent]');
        if (this.productTypeDetail.toLowerCase() === TwoWheeler.toLowerCase() && (this.vehicleTypeDetail.toLowerCase() === 'new'.toLowerCase())) {
            let checkdsmIncentiveOneH = (this.dsmIncentiveOneValid * parseInt(this.requiredLoanAmount, 10)) / 100;
            elem.setCustomValidity("");
            if (this.dsmIncentiveOneValue && (this.dsmIncentiveOneValue > parseInt(checkdsmIncentiveOneH, 10))) {
                disablefield =false;
                elem.setCustomValidity(FivePercentageOfAmount);
                elem.reportValidity();
            }
        } else if (this.productTypeDetail.toLowerCase() === PassengerVehicles.toLowerCase()) {
            let checkdsmIncentiveOneC = (this.dsmIncentiveOneValid * parseInt(this.requiredLoanAmount, 10)) / 100;
            elem.setCustomValidity("");
            if (this.dsmIncentiveOneValue && (this.dsmIncentiveOneValue > parseInt(checkdsmIncentiveOneC, 10))) {
                disablefield =false;
                elem.setCustomValidity(tenPercentageOfAmount);
                elem.reportValidity();
            }
        } else if (this.productTypeDetail.toLowerCase() === TwoWheeler.toLowerCase() && (this.vehicleTypeDetail.toLowerCase() === 'Refinance'.toLowerCase() || this.vehicleTypeDetail.toLowerCase() === 'used'.toLowerCase())) {
            elem.setCustomValidity("");
            if (this.dsmIncentiveOneValue >= 1 || this.dsmIncentiveOneValue < 0) {
                disablefield =false;
                elem.setCustomValidity(noPayout);
                elem.reportValidity();
            }
        }
        if (this.dsmIncentiveOneValue < 0) {
            disablefield =false;
            elem.setCustomValidity(validValue);
            elem.reportValidity();
        }
        if(this.disablesubmit){
            this.disablesubmit =disablefield;
        }
        if(forDisablefield){
            this.disabledDsmIncentiveOne=disablefield;
            if(!disablefield){
                this.phdsmIncentiveOneValue = this.dsmIncentiveOneValue;
                this.dsmIncentiveOneValue = null;
            }
        }
        // this.disablePayinPayout=this.disablesubmit;
    } catch (error) {
        console.error(error);
    }
}
dsmNameTwo(forDisablefield) {
    try {
        let disablefield =true;
        let elem = this.template.querySelector('.dsmName2');
        elem.setCustomValidity('');
        if (this.dsmNameOneValue && this.dsmNameTwoValue && this.dsmNameOneValue === this.dsmNameTwoValue) {
            disablefield =false;
            elem.setCustomValidity(DsmError);
            elem.reportValidity();
        }
        if(this.disablesubmit){
            this.disablesubmit =disablefield;
        }
        if(forDisablefield){
            this.disableDsmName2=disablefield;
        }
        // this.disablePayinPayout=this.disablesubmit;
    } catch (error) {
        console.error(error);
    }
}
dsmIncentiveTwo(forDisablefield) {
    try {
        let disablefield =true;
        let elem = this.template.querySelector('lightning-input[data-id=dsmInce]');
        if (this.productTypeDetail.toLowerCase() === TwoWheeler.toLowerCase() && (this.vehicleTypeDetail.toLowerCase() === 'new'.toLowerCase())) {
            let checkDsmIncentiveTwoH = (this.dsmIncentiveTwoValid * parseInt(this.requiredLoanAmount, 10)) / 100;
            elem.setCustomValidity("");
            if (this.dsmIncentiveTwoValue && (this.dsmIncentiveTwoValue > parseInt(checkDsmIncentiveTwoH, 10))) {
                disablefield =false;
                elem.setCustomValidity(FivePercentageOfAmount);
                elem.reportValidity();
            }
        } else if (this.productTypeDetail.toLowerCase() === PassengerVehicles.toLowerCase()) {
            let checkDsmIncentiveTwoC = (this.dsmIncentiveTwoValid * parseInt(this.requiredLoanAmount, 10)) / 100;
            elem.setCustomValidity("");
            if (this.dsmIncentiveTwoValue && (this.dsmIncentiveTwoValue > parseInt(checkDsmIncentiveTwoC, 10))) {
                disablefield =false;
                elem.setCustomValidity(tenPercentageOfAmount);
                elem.reportValidity();
            }
        } else if (this.productTypeDetail.toLowerCase() === TwoWheeler.toLowerCase() && (this.vehicleTypeDetail.toLowerCase() === 'Refinance'.toLowerCase() || this.vehicleTypeDetail.toLowerCase() === 'used'.toLowerCase())) {
            elem.setCustomValidity("");
            if (this.dsmIncentiveTwoValue >= 1) {
                disablefield =false;
                elem.setCustomValidity(noPayout);
                elem.reportValidity();
            }
        }
        if (this.dsmIncentiveTwoValue < 0) {
            disablefield =false;
            elem.setCustomValidity(validValue);
            elem.reportValidity();
        }
        if(this.disablesubmit){
            this.disablesubmit =disablefield;
        }
        if(forDisablefield){
            this.disabledDsmIncentiveTwo=disablefield;
            if(!disablefield){
                this.phdsmIncentiveTwoValue = this.dsmIncentiveTwoValue;
                this.dsmIncentiveTwoValue = null;
            }
        }
        // this.disablePayinPayout=this.disablesubmit;
    } catch (error) {
        console.error(error);
    }
}
referrerIncentive(forDisablefield) {
    try {
        let disablefield =true;
        let elem = this.template.querySelector('lightning-input[data-id=refInc]');
        if (this.productTypeDetail.toLowerCase() === TwoWheeler.toLowerCase() && (this.vehicleTypeDetail.toLowerCase() === 'new'.toLowerCase())) {
            let checkreferrerIncentive = (this.referrerIncentiveValid * parseInt(this.requiredLoanAmount, 10)) / 100;
            elem.setCustomValidity("");
            if (this.referrerIncentiveValue && (this.referrerIncentiveValue > parseInt(checkreferrerIncentive, 10))) {
                disablefield =false;
                elem.setCustomValidity(FivePercentageOfAmount);
                elem.reportValidity();
            }
        } else if (this.productTypeDetail.toLowerCase() === PassengerVehicles.toLowerCase()) {
            let checkreferrerIncentive = (this.referrerIncentiveValid * parseInt(this.requiredLoanAmount, 10)) / 100;
            elem.setCustomValidity("");
            if (this.referrerIncentiveValue && (this.referrerIncentiveValue > parseInt(checkreferrerIncentive, 10))) {
                disablefield =false;
                elem.setCustomValidity(tenPercentageOfAmount);
                elem.reportValidity();
            }
        } else if (this.productTypeDetail.toLowerCase() === TwoWheeler.toLowerCase() && (this.vehicleTypeDetail.toLowerCase() === 'Refinance'.toLowerCase() || this.vehicleTypeDetail.toLowerCase() === 'used'.toLowerCase())) {
            elem.setCustomValidity("");
            if (this.referrerIncentiveValue >= 1 || this.referrerIncentiveValue < 0) {
                disablefield =false;
                elem.setCustomValidity(noPayout);
                elem.reportValidity();
            }
        }
        if (this.referrerIncentiveValue < 0) {
            disablefield =false;
            elem.setCustomValidity(validValue);
            elem.reportValidity();
        }
        if(this.disablesubmit){
            this.disablesubmit =disablefield;
        }
        if(forDisablefield){
            this.disabledReferrerIncentive=disablefield;
            if(!disablefield){
                this.phreferrerIncentiveValue = this.referrerIncentiveValue;
                this.referrerIncentiveValue = null;
            }
        }
        // this.disablePayinPayout=this.disablesubmit;
    } catch (error) {
        console.error(error);
    }
}
provisionalChannelCost(forDisablefield) {
    try {
        let disablefield =true;
        let provChannelObj = {};
        if (this.currentStage !== 'Credit Processing') {
            let elem = this.template.querySelector('lightning-input[data-id=proChnCost]');
            if (this.productTypeDetail.toLowerCase() === TwoWheeler.toLowerCase() && (this.vehicleTypeDetail.toLowerCase() === 'new'.toLowerCase())) {
                if (this.requiredTenureDetails > 12) {
                    let checkProvisionalChannelCost = (this.provisionalChannelCostValid * (parseInt(this.requiredLoanAmount, 10) / 100) + this.provisionalChannelCostMinValid);
                    checkProvisionalChannelCost = (Math.round(checkProvisionalChannelCost));
                    provChannelObj.pccValue = checkProvisionalChannelCost;
                    provChannelObj.disabledPCC = true;

                } else {
                    let checkProvisionalChannelCost = (this.provisionalChannelCostTwoValid * (parseInt(this.requiredLoanAmount, 10) / 100) + this.provisionalChannelCostMaxValid);
                    checkProvisionalChannelCost = (Math.round(checkProvisionalChannelCost));
                    provChannelObj.pccValue = checkProvisionalChannelCost;
                    provChannelObj.disabledPCC = true;
                }
            } else if (this.productTypeDetail.toLowerCase() === TwoWheeler.toLowerCase() && (this.vehicleTypeDetail.toLowerCase() === 'Refinance'.toLowerCase() || this.vehicleTypeDetail.toLowerCase() === 'used'.toLowerCase())) {
                let checkProvisionalChannelCost = ((this.provisionalChannelCostValid * parseInt(this.requiredLoanAmount, 10) / 100) + this.provisionalChannelCostMaxValid);
                checkProvisionalChannelCost = (Math.round(checkProvisionalChannelCost));
                provChannelObj.pccValue = checkProvisionalChannelCost;
                provChannelObj.disabledPCC = true;
            }
        } else {
            let elem = this.template.querySelector('lightning-input[data-id=proChnCost]');
            if (this.productTypeDetail.toLowerCase() === TwoWheeler.toLowerCase() && (this.vehicleTypeDetail.toLowerCase() === 'new'.toLowerCase())) {
                if (this.offerEngineTenure > 12) {
                    let checkProvisionalChannelCost = (this.provisionalChannelCostValid * (parseInt(this.offerEngineLoanAmount, 10) / 100) + this.provisionalChannelCostMinValid);
                    checkProvisionalChannelCost = (Math.round(checkProvisionalChannelCost));
                    elem.setCustomValidity("");
                    if (this.provisionalChannelCostValue != checkProvisionalChannelCost) {
                        disablefield =false;
                        elem.setCustomValidity('Enter value Equals to ' + checkProvisionalChannelCost);
                        elem.reportValidity();
                    } else {
                        provChannelObj.pccValue = null;
                        provChannelObj.disabledPCC = true;
                    }
                } else {
                    let checkProvisionalChannelCost = (this.provisionalChannelCostTwoValid * (parseInt(this.offerEngineLoanAmount, 10) / 100) + this.provisionalChannelCostMaxValid);
                    checkProvisionalChannelCost = (Math.round(checkProvisionalChannelCost));
                    elem.setCustomValidity("");
                    if (this.provisionalChannelCostValue != checkProvisionalChannelCost) {
                        disablefield =false;
                        elem.setCustomValidity('Enter value Equals to ' + checkProvisionalChannelCost);
                        elem.reportValidity();
                    } else {
                        provChannelObj.pccValue = null;
                        provChannelObj.disabledPCC = true;
                    }
                }
            } else if (this.productTypeDetail.toLowerCase() === TwoWheeler.toLowerCase() && (this.vehicleTypeDetail.toLowerCase() === 'Refinance'.toLowerCase() || this.vehicleTypeDetail.toLowerCase() === 'used'.toLowerCase())) {
                let checkProvisionalChannelCost = ((this.provisionalChannelCostValid * parseInt(this.offerEngineLoanAmount, 10) / 100) + this.provisionalChannelCostMaxValid);
                checkProvisionalChannelCost = (Math.round(checkProvisionalChannelCost));
                elem.setCustomValidity("");
                if (this.provisionalChannelCostValue != checkProvisionalChannelCost) {
                    disablefield =false;
                    elem.setCustomValidity('Enter value Equals to ' + checkProvisionalChannelCost);
                    elem.reportValidity();
                } else {
                    provChannelObj.pccValue = null;
                    provChannelObj.disabledPCC = true;
                }
            }
        }
        if(this.disablesubmit){
            this.disablesubmit =disablefield;
        }
        if(forDisablefield){
            this.disabledProvisionalChannelCost=disablefield;
            if(this.productTypeDetail.toLowerCase() === 'Passenger Vehicles'.toLowerCase()){
                this.disabledProvisionalChannelCost = true;
            }
        }
        // this.disablePayinPayout=this.disablesubmit;
        return provChannelObj;
    } catch (error) {
        console.error(error);
    }
}
dsaPay(forDisablefield) {
    try {
        if (this.displayDsaRcu && this.disabledDsaPay===false) {
            let disablefield =true;
            let elem = this.template.querySelector('lightning-input[data-id=dsapay]');
            elem.setCustomValidity("");
            if (this.referrerIncentiveValue < 0) {
                disablefield =false;
                elem.setCustomValidity(validValue);
                elem.reportValidity();
            }
            if(this.disablesubmit){
                this.disablesubmit =disablefield;
            }
            if(forDisablefield){
                this.disabledDsaPay=disablefield;
            }
            // this.disablePayinPayout=this.disablesubmit;
        }
    } catch (error) {
        console.error(error);
    }
}
showToast(title, message, variant){
    const evt = new ShowToastEvent({
       title: title,
        message: message,
        variant: variant,});
    this.dispatchEvent(evt);}
}