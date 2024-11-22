import getIES from '@salesforce/apex/FinalTermscontroller.checkIES';   
import LightningConfirm from 'lightning/confirm';//CISP-4784
import updateJourneyStop from '@salesforce/apex/customerDedupeRevisedClass.updateJourneyStop'; //CISP-4459
import dsmNameData from '@salesforce/apex/FinalTermscontroller.dsmNameData';//CISP-8307
import nonDsmNameData from '@salesforce/apex/FinalTermscontroller.nonDsmNameData';//CISP-8307
import detailsSaved from '@salesforce/label/c.detailsSaved';
import SuccessMessage from '@salesforce/label/c.SuccessMessage';
import Mandatory_fields_are_not_entered from '@salesforce/label/c.Mandatory_fields_are_not_entered';
import requiredFields from '@salesforce/label/c.requiredFields';
import ReadOnlyLeadAccess from '@salesforce/label/c.ReadOnlyLeadAccess';
import maxPercentage from '@salesforce/label/c.maxPercentage';
import makecodeM from '@salesforce/label/c.makecodeM';
import nonD2CdocumentationchargesValidation from '@salesforce/label/c.nonD2CdocumentationchargesValidation';//CISP-4785
import nonD2CserviceChargesValidation from '@salesforce/label/c.nonD2CserviceChargesValidation';//CISP-4785
import getApplicationDetails from '@salesforce/apex/FinalTermscontroller.getApplicationDetails';
import getRepaymentModePickListValue from '@salesforce/apex/FinalTermscontroller.getRepaymentModePickListValue';
import dedupeSubmitByCMU from '@salesforce/apex/Ind_CustomerDedupCtrl.dedupeSubmitByCMU';//CISP-10782
import getRecordDetails from '@salesforce/apex/IND_LWC_ExposureAnalysis.getRecordDetails';//CISP-10782
import { ShowToastEvent } from 'lightning/platformShowToastEvent';//CISP-4785
import calculateMedianPayouts from '@salesforce/apex/Utilities.calculateMedianPayouts';//CISP-4785
import getOpportunityDetailsForUPD from '@salesforce/apex/FinalTermscontroller.getOpportunityDetailsForUPD'; //CISP-6283
import getFinalTermRecord from '@salesforce/apex/FinalTermscontroller.getFinalTermRecord'; // SFTRAC-54 starts
import checkAssetVerificationStatus from '@salesforce/apex/LWCLOSAssetVerificationCntrl.checkAssetVerificationStatus'; // SFTRAC-54 starts
import checkAssetVerificationStatusFinalTerm from '@salesforce/apex/LWCLOSAssetVerificationCntrl.checkAssetVerificationStatusFinalTerm'; // SFTRAC-1636 starts
import isAllFICasesSubmitted from '@salesforce/apex/FinalTermscontroller.isAllFICasesSubmitted';
import rtoValidation from '@salesforce/apex/FinalTermscontroller.rtoValidation';
import callCheckSchemeEligibility from '@salesforce/apex/FinalTermscontroller.checkSchemeEligibility';
import validateAgreementAmount from '@salesforce/apex/FinalTermscontroller.validateAgreementAmount';
import getCustomerCodeStatus from '@salesforce/apex/FinalTermscontroller.getCustomerCodeStatus';
//labels
import validValue from '@salesforce/label/c.validValue';
import serviceChargesValidation from '@salesforce/label/c.serviceChargesValidation';
import documentationValidation from '@salesforce/label/c.documentationValidation';
import documentationchargesValidation from '@salesforce/label/c.documentationchargesValidation';
import lessThanEqual from '@salesforce/label/c.lessThanEqual';
import FivePercentageOfAmount from '@salesforce/label/c.FivePercentageOfAmount';
import tenPercentageOfAmount from '@salesforce/label/c.tenPercentageOfAmount';
import DsmError from '@salesforce/label/c.DsmError';
import dealerDiscountValidation from '@salesforce/label/c.dealerDiscountValidation';
import dealerDiscount from '@salesforce/label/c.dealerDiscount';
import validVehicleNo from '@salesforce/label/c.validVehicleNo';
import vehicleRegistration from '@salesforce/label/c.vehicleRegistration';
import InvalidVehicleReg from '@salesforce/label/c.InvalidVehicleReg';
import ValidVehicleReg from '@salesforce/label/c.ValidVehicleReg';
import noPayout from '@salesforce/label/c.noPayout';
import invalidScheme from '@salesforce/label/c.invalidScheme';

// import added

import updateFinalTermBenCode from '@salesforce/apex/IND_VehicleInspectionRCLimitDetails.updateFinalTermBenCode';
import final_ID_FIELD from '@salesforce/schema/Final_Term__c.Id';
import Scheme_Bank_offers from '@salesforce/schema/Final_Term__c.Scheme_Bank_offers__c';
import Service_charges from '@salesforce/schema/Final_Term__c.Service_charges__c';
import Documentation_charges from '@salesforce/schema/Final_Term__c.Documentation_charges__c';
import Stamping_charges from '@salesforce/schema/Final_Term__c.Stamping_charges__c';
import Due_date_shift_charges from '@salesforce/schema/Final_Term__c.Due_date_shift_charges__c';
import ECS_verification_by from '@salesforce/schema/Final_Term__c.ECS_verification_by__c';
import Verification_charges from '@salesforce/schema/Final_Term__c.Verification_charges__c';
import Delinquency_Fund from '@salesforce/schema/Final_Term__c.Delinquency_Fund__c';
import Deliquency_Fund_type from '@salesforce/schema/Final_Term__c.Deliquency_Fund_type__c';
import RTO_prefix from '@salesforce/schema/Final_Term__c.RTO_prefix__c';
import Trade_certificate from '@salesforce/schema/Final_Term__c.Trade_certificate__c';
import Dlr_Exp_Reimburse_Amt from '@salesforce/schema/Final_Term__c.Dlr_Exp_Reimburse_Amt__c';
import Dlr_Exp_Reimburse_Type from '@salesforce/schema/Final_Term__c.Dlr_Exp_Reimburse_Type__c';
import Dealer_incentive_amount_main_dealer from '@salesforce/schema/Final_Term__c.Dealer_incentive_amount_main_dealer__c';
import Dealer_incentive_amount_sub_dealer from '@salesforce/schema/Final_Term__c.Dealer_incentive_amount_sub_dealer__c';
import Dealer_Disc_to_Customer from '@salesforce/schema/Final_Term__c.Dealer_Disc_to_Customer__c';
import Gift_through_dealer_amount from '@salesforce/schema/Final_Term__c.Gift_through_dealer_amount__c';
import Mfr_incentive from '@salesforce/schema/Final_Term__c.Mfr_incentive__c';
import DSM_IncentiveOne from '@salesforce/schema/Final_Term__c.DSM_Incentive1__c';
import DSM_NameOne from '@salesforce/schema/Final_Term__c.DSM_Name1__c';
import DSM_IncentiveTwo from '@salesforce/schema/Final_Term__c.DSM_Incentive2__c';
import DSM_NameTwo from '@salesforce/schema/Final_Term__c.DSM_Name2__c';
import Non_Dlr_DSM_IncentiveOne from '@salesforce/schema/Final_Term__c.Non_Dlr_DSM_Incentive1__c';
import Non_Dlr_DSM_NameOne from '@salesforce/schema/Final_Term__c.Non_Dlr_DSM_Name1__c';
import Non_Dlr_DSM_IncentiveTwo from '@salesforce/schema/Final_Term__c.Non_Dlr_DSM_Incentive2__c';
import Non_Dlr_DSM_NameTwo from '@salesforce/schema/Final_Term__c.Non_Dlr_DSM_Name2__c';
import Refered_By from '@salesforce/schema/Final_Term__c.Refered_By__c';
import Rreferrer_Incentive from '@salesforce/schema/Final_Term__c.Rreferrer_Incentive__c';
import Referrer_Name from '@salesforce/schema/Final_Term__c.Referrer_Name__c';
import Branch from '@salesforce/schema/Final_Term__c.Branch__c';
import Emp_No from '@salesforce/schema/Final_Term__c.Emp_No__c';
import Emp_Name from '@salesforce/schema/Final_Term__c.Emp_Name__c';
import Deal_No from '@salesforce/schema/Final_Term__c.Deal_No__c';
import Provisional_Channel_Cost from '@salesforce/schema/Final_Term__c.Provisional_Channel_Cost__c';
import DSA_pay from '@salesforce/schema/Final_Term__c.DSA_pay__c';
import RCU_Retention_Charges from '@salesforce/schema/Final_Term__c.RCU_Retention_Charges__c';
import Repayment_mode from '@salesforce/schema/Final_Term__c.Repayment_mode__c';
import Advance_EMI from '@salesforce/schema/Final_Term__c.Advance_EMI__c';
import Holiday_period from '@salesforce/schema/Final_Term__c.Holiday_period__c';
import Installment_Type from '@salesforce/schema/Final_Term__c.Installment_Type__c';
import Funding_For_Chassis from '@salesforce/schema/Final_Term__c.Funding_for_Chassis__c';
import Funding_For_Body from '@salesforce/schema/Final_Term__c.Funding_for_Body__c';
import serviceChargeAndDocChargeSum from '@salesforce/label/c.Valid_sum_of_Service_Charge_and_Documentation_charge';//CISP-4785
import IsPayOutSubmitRequired from '@salesforce/schema/Final_Term__c.Is_Change_Pay_In_Pay_Out_Submit_Required__c';
import Dlr_Exp_Reimbursement_percent from '@salesforce/schema/Final_Term__c.Dlr_Exp_Reimbursement_percent__c';
import schemeId from '@salesforce/schema/Final_Term__c.Schemes__c';
import RC_limit_enabled_DSA from '@salesforce/schema/Final_Term__c.RC_limit_enabled_DSA__c';//CISP-8762
import VehicleDetail from '@salesforce/schema/Final_Term__c.Vehicle_Detail__c';//sftrac-84
import InstallmentFrequencyType from '@salesforce/schema/Final_Term__c.Installment_Frequency__c';//sftrac-84
import BUSINESS_EXECUTIVE from '@salesforce/schema/Final_Term__c.Business_Executive__c';//sftrac-84
import doSchemeValidationCallout from '@salesforce/apexContinuation/IntegrationEngine.doSchemeValidationCallout'; //SFTRAC-469
import combinedBRECallout from '@salesforce/apex/IntegrationEngine.combinedBRE'; //SFTRAC-121
import LtvEngine_Ltv from '@salesforce/schema/Final_Term__c.LtvEngine_Ltv__c'; //SFTRAC-121
import PricingEngine_thresholdNetrr from '@salesforce/schema/Final_Term__c.PricingEngine_thresholdNetrr__c'; //SFTRAC-121
import Installment_To_Income_Ratio from '@salesforce/schema/Final_Term__c.Installment_To_Income_Ratio__c'; //SFTRAC-121
import Fi_Score_Band from '@salesforce/schema/Final_Term__c.Fi_Score_Band__c'; //SFTRAC-121
import Fi_Score from '@salesforce/schema/Final_Term__c.Fi_Score__c';
import CashFlowPerAnnum from '@salesforce/schema/Final_Term__c.CashFlowPerAnnum__c'; //SFTRAC-121
export const customLabels = {detailsSaved: detailsSaved,SuccessMessage: SuccessMessage,Mandatory_fields_are_not_entered: Mandatory_fields_are_not_entered,requiredFields: requiredFields,ReadOnlyLeadAccess: ReadOnlyLeadAccess,maxPercentage: maxPercentage,makecodeM: makecodeM}
import * as helper from './lwc_FinalTermsScreenSecondHelper';
import FIRST_EMI_DATE from '@salesforce/schema/Final_Term__c.First_EMI_Date__c';//CISP-16789
import SECOND_EMI_DATE from '@salesforce/schema/Final_Term__c.Second_EMI_Date__c';//CISP-16789
import Loan_Deal_Date from '@salesforce/schema/Final_Term__c.Loan_Deal_Date__c';
import X1st_EMI_Date from '@salesforce/schema/Final_Term__c.First_EMI_Date__c';
import X2nd_EMI_Date from '@salesforce/schema/Final_Term__c.Second_EMI_Date__c';
import No_of_Installment from '@salesforce/schema/Final_Term__c.No_of_Installment__c';
import Journey_Status from '@salesforce/schema/Opportunity.Journey_Status__c';
import Journey_Stop_Reason from '@salesforce/schema/Opportunity.Journey_Stop_Reason__c';
import Net_Income from '@salesforce/schema/Final_Term__c.Net_Income__c'; //SFTRAC-126
import OPP_ID_FIELD from '@salesforce/schema/Opportunity.Id';
import isNavigate from '@salesforce/schema/Final_Term__c.isNavigate__c'; //SFTRAC-792
import FinalTermsSubmitted from '@salesforce/schema/Final_Term__c.L1_Final_Terms_Submitted__c';
import IS_CHANGE_PAYIN_PAYOUT_COMPLETED from '@salesforce/schema/Final_Term__c.Is_Change_PayIn_PayOut_Completed__c';
import CRM_IRR from '@salesforce/schema/Final_Term__c.CRM_IRR__c';
import Change_Pay_IN_OUT from '@salesforce/schema/Final_Term__c.Is_Change_Pay_In_Out_Editable__c'; 
import TwoWheeler from '@salesforce/label/c.TwoWheeler';
export async function repaymentModePickListValueHelper(thisVar){
    let result = await getRepaymentModePickListValue({'loanApplicationId' : thisVar.recordid});
    let pickListValues = [];
    let keys = Object.keys(result);
    keys.forEach((key) => {
        pickListValues.push({'label' : result[key] , 'value' : key});
    });        
    thisVar.repaymentModeOptions = pickListValues;    
    thisVar.repaymentModeOptionsBk = pickListValues;
}
export async function getApplicationDetailsHelper(thisVar){
    await getApplicationDetails({ loanApplicationId: thisVar.recordid })
    .then(response => {
        if(response == 'twNew'){thisVar.twNew=true;thisVar.teNewrequire=false;thisVar.rtoRequired=false;thisVar.dueDateRequired=true;thisVar.twRefinance=false;thisVar.disabledDealerDiscounttoCustomer=false;
        }else if(response == 'twRefinance'){  thisVar.twRefinance=true;thisVar.twRefinancerequire=false;thisVar.twNew=false;thisVar.disabledDealerIncentiveAmountMainDealer=true;thisVar.disabledDealerDiscounttoCustomer=true;thisVar.disabledDealerIncentiveAmountSubDealer = true;thisVar.disabledGiftThroughDealerAmount = true;thisVar.disabledReferrerIncentive = true;thisVar.disabledReferrerName = true;
        }else if(response == 'passengerUpd'){thisVar.twNew=false;thisVar.twRefinance=false;thisVar.teNewrequire=true;thisVar.rtoRequired=true;thisVar.dueDateRequired=true;thisVar.twRefinancerequire=true;thisVar.disabledMfrExpReimburseAmt=true;thisVar.disabledMfrExpReimbursePercentage=true;thisVar.disabledMfrExpReimburseType=true;thisVar.disabledDealerDiscounttoCustomer=true;
        }else{thisVar.twNew=false;thisVar.twRefinance=false;thisVar.teNewrequire=true;if(response=='tractor'){thisVar.rtoRequired=false;thisVar.dueDateRequired=false}else{thisVar.rtoRequired=true;thisVar.dueDateRequired=true}thisVar.twRefinancerequire=true;thisVar.disabledMfrExpReimburseAmt=true;thisVar.disabledMfrExpReimbursePercentage=true;thisVar.disabledMfrExpReimburseType=true;thisVar.disabledDealerDiscounttoCustomer=true;}
        if(response == 'twRefinance ' || response == 'twNew'){thisVar.disabledecsVerificationChargeBy = true;thisVar.disabledecsVerificationCharge=true;thisVar.disableddelinquencyFund=true;thisVar.disableddelinquencyFundType = true;thisVar.disableNonDsmName1 = true;thisVar.disablednonDlrDsmIncentiveOne = true;thisVar.disableNonDsmName2 = true;thisVar.disablednonDlrDsmIncentiveTwo = true;thisVar.disabledExpReimburseAmountValue = true;thisVar.disabledDealerExpReimbursePercentage = true;thisVar.disabledDealerExpReimburseType = true;thisVar.disabledMfrExpReimburseAmt = true;thisVar.disabledMfrExpReimbursePercentage = true;thisVar.disabledMfrExpReimburseType = true;
        }})
       await  getOpportunityDetailsForUPD({ loanApplicationId: thisVar.recordid })
      .then(result => {
        if(result == 'passengerUpdUEB'){
            thisVar.disabledDealerIncentiveAmountMainDealer = false;
            thisVar.disabledGiftThroughDealerAmount = false;
        }
      })
      .catch(error => {});
}
export async function getRecordDetailsHelper(thisVar){
await getRecordDetails({oppId : thisVar.recordid}).then((response) => {thisVar.applicantsList = response;if(thisVar.applicantsList.length == 0){dedupeSubmitByCMU({ oppId: thisVar.recordid }).then(result => {thisVar.isCustomerDedupeSubmit=result;}).catch(error => {});}}).catch((error) => {thisVar.showToast("Error", error.body.message, 'Error');}); }

export function handleSchemeSelection(ref) {
    try {
        if(ref.productTypeDetail.toLowerCase()===TwoWheeler.toLowerCase()){
            ref.repaymentModeOptions = ref.repaymentModeOptionsBk;
            // ref.repaymentModeValue = '';
            ref.schemeData.forEach(item => {
                if(item.value == ref.schemeOptionsValue && item.repaymentDetails){
                    let newRepayOptions = [];
                    let selectedRepaymentDetails = item.repaymentDetails ? item.repaymentDetails.split(';') : null;
                    console.log(selectedRepaymentDetails,'selectedRepaymentDetails');
                    if(selectedRepaymentDetails && selectedRepaymentDetails.length >0 && ref.repaymentModeOptions.length > 0){
                        ref.repaymentModeOptions.forEach(key => {
                            selectedRepaymentDetails.forEach(key1 =>{
                                if(key.value == key1){
                                    newRepayOptions.push(key);
                                }
                            })
                        })    
                    }
                    console.log(newRepayOptions,'newRepayOptions');
                    ref.repaymentModeOptions = newRepayOptions;
                }
            })    
            // ref.repaymentModeValue = ref.repaymentModeOptions.length == 1 ? ref.repaymentModeOptions[0].value : '';
        }
        for (let index = 0; index < ref.schemeData.length; index++) {
            let values = JSON.stringify(ref.schemeData[index].value);
            let val = values;
            let schemeOptionsValues = '"' + ref.schemeOptionsValue + '"';
            if (val === schemeOptionsValues) {
                ref.ids = JSON.stringify(ref.schemeData[index].id);
                ref.ids = ref.ids.replaceAll('"', '');
            }
        }
        const schemeCmp = ref.template.querySelector(".scheme");
        /* Added Case-Insensitive comparison with schemeOptionsValue for OLA Leads - OLA-209 Bug fix*/
        if (ref.leadSource == 'OLA' && ((ref.isExistingCustomer && ref.schemeOptionsValue.toLowerCase() !== 'ola ec') || (!ref.isExistingCustomer && ref.schemeOptionsValue.toLowerCase() !== 'ola nc'))) {
            schemeCmp.setCustomValidity('Invalid scheme value');
            schemeCmp.reportValidity();
        } else if (ref.leadSource == 'OLA') {
            schemeCmp.setCustomValidity('');
            schemeCmp.reportValidity();
        }
        if (ref.leadSource != 'OLA') {
            callCheckSchemeEligibility({
                'schemeId': ref.ids,
                'loanApplicationId': ref.recordid,
                'vehicleId': ref.vehicleId
            }).then(response => {
                try {
                    ref.isSpinnerMoving = true;
                    let result = JSON.parse(response);
                    if (result && result.status === true) {
                        ref.documentationChargesValue = null;
                        ref.serviceChargesValue = null;
                        ref.stampingChargesValue = null;
                        ref.dueDateShiftChargesValue = null;
                        ref.ecsValue = null;
                        ref.verificationChargesValue = null;
                        ref.delinquencyFundValue = null;
                        ref.delinquencyFundTypeValue = null;
                        ref.rtoPrefixValue = null;
                        ref.dealerExpReimburseAmountValue = null;
                        ref.dealerExpReimbursePercentageValue = null;
                        ref.dealerExpReimburseTypeValue = null;
                        ref.mfrExpReimburseAmtValue = null;
                        ref.mfrExpReimbursePercentageValue = null;
                        ref.mfrExpReimburseTypeValue = null;
                        ref.dealerIncentiveAmountMainValue = null;
                        ref.dealerMainPercentageValue = null;
                        ref.dealerIncentiveAmountSubValue = null;
                        ref.dealerSubPercentageValue = null;
                        ref.dealerDiscounttoCustomerValue = null;
                        ref.giftThroughDealerAmountValue = null;
                        ref.giftThroughDealerPercentageValue = null;
                        ref.dsmNameOneValue = null;
                        ref.dsmIncentiveOneValue = null;
                        ref.dsmOnePercentageValue = null;
                        ref.dsmNameTwoValue = null;
                        ref.dsmIncentiveTwoValue = null;
                        ref.dsmTwoPercentageValue = null;
                        ref.referredbyValue = null;
                        ref.referrerIncentiveValue = null;
                        ref.referrerNameValue = null;
                        ref.branchValue = null;
                        ref.empNoValue = null;
                        ref.empNameValue = null;
                        ref.dealNoValue = null;
                        ref.provisionalChannelCostValue = null;
                        ref.dsaPayValue = null;
                        ref.rcuRetentionChargesValue = null;
                        ref.advanceEmiValue = null;
                        ref.monitoriumDaysValue = null;
                        ref.payoutCapValue = null;
                        let schemeRec = result.schemeRecord;
                        let loanAmount = parseInt(ref.requiredLoanAmount, 10);
                        if (ref.productTypeDetail.toLowerCase() === 'Passenger Vehicles'.toLowerCase()) {
                            validateSelectedScheme(ref);
                            if (checkInput(result.docCharge)) {
                                ref.documentationChargesValue = roundOff(result.docCharge);
                                ref.checkDocumentationCharges();
                            } else if (checkInput(schemeRec.Doc_Charges_p__c)) {
                                ref.documentationChargesValue = roundOff(((schemeRec.Doc_Charges_p__c * loanAmount) / 100)).toFixed(2);
                            }
                            if (checkInput(result.serviceCharge)) {
                                ref.serviceChargesValue = roundOff(result.serviceCharge);
                                ref.checkServiceCharges();
                            } else if (checkInput(schemeRec.Service_Charges_p__c)) {
                                ref.serviceChargesValue = roundOff(((schemeRec.Service_Charges_p__c * loanAmount) / 100).toFixed(2));
                            }
                        } else if (ref.productTypeDetail.toLowerCase() === 'Two Wheeler'.toLowerCase() || ref.productTypeDetail === 'Tractor') {
                            ref.modifyingDataacctoScheme(schemeRec, loanAmount);
                        }
                        Promise.resolve().then(() => {
                            let serviceChInpt = ref.template.querySelector('lightning-input[data-id=serChar]');
                            let docChargesInput = ref.template.querySelector('lightning-input[data-id=DocChar]');
                            serviceChInpt.reportValidity();
                            docChargesInput.reportValidity();
                        });
                        ref.isSpinnerMoving = false;
                        ref.flagToCheckInValidScheme = false;
                    } else {
                        ref.flagToCheckInValidScheme = true;
                        ref.toastMsg(invalidScheme);
                        ref.isSpinnerMoving = false;
                    }
                } catch (error) {}
            }).catch(error => {
                if (error?.body?.message == 'Disconnected or Canceled') {
                    ref.toastMsg('No Internet. Please check your network.');
                } else {
                    ref.toastMsg('Something went wrong.');
                }
                ref.schemeOptionsValue = null;
            });
        }
    } catch (error) {}
}
// Pay In functions
export function serviceCharges(ref) {
    try {
        if(ref.isTractor){return helper.serviceChargesHandler(ref);}else{
        let checkServiceChargesValue = parseInt(ref.serviceChargesValue, 10) % ref.serviceChargesValueValid;
        let elem = ref.template.querySelector('lightning-input[data-id=serChar]');
        let checkServiceChargesValueMax = (ref.serviceChargesValueMaxValid * parseInt(ref.requiredLoanAmount, 10)) / 100;
        let checkServiceChargesValueMin = (ref.serviceChargesValueMinValid * parseInt(ref.requiredLoanAmount, 10)) / 100;
        let isValBreach = false;
        //CISP-3785 start
        let gstValue = parseInt(ref.serviceChargesValue, 10) * 18.0 / 118;
        gstValue = Math.round(gstValue * 100) / 100;
        let docAmount = parseInt(ref.serviceChargesValue, 10) - gstValue;
        //CISP-3785 end
        elem.setCustomValidity("");
        //CISP-4785 No min value in service charges
        if (ref.nonD2cDsaTW && ref.productTypeDetail.toLowerCase() === 'Two Wheeler'.toLowerCase() && checkInput(ref.serviceChargesValue) && (parseInt(ref.serviceChargesValue, 10) > parseInt(checkServiceChargesValueMax, 10))) {
            isValBreach= true;
            elem.setCustomValidity(nonD2CserviceChargesValidation);
            elem.reportValidity();
        }else if (!ref.nonD2cDsaTW && ref.productTypeDetail.toLowerCase() === 'Two Wheeler'.toLowerCase() && checkInput(ref.serviceChargesValue) && (parseInt(ref.serviceChargesValue, 10) < parseInt(checkServiceChargesValueMin, 10) || parseInt(ref.serviceChargesValue, 10) > parseInt(checkServiceChargesValueMax, 10))) {
            isValBreach= true;
            elem.setCustomValidity(serviceChargesValidation);
            elem.reportValidity();
        } else if (ref.productTypeDetail.toLowerCase() === 'Passenger Vehicles'.toLowerCase() && checkInput(ref.serviceChargesValue) && parseInt(docAmount, 10) > parseInt(checkServiceChargesValueMax, 10)) {
            isValBreach = true;
            elem.setCustomValidity('Document value - ' + docAmount + ', GST value - ' + gstValue + ' Document value should be within 3% of finance amount. Please enter service charges (incl. GST) within the range');
            elem.reportValidity();
        } else if (checkServiceChargesValue !== 0) {
            isValBreach = true;
            elem.setCustomValidity('Please enter service charges in multiples of 5');
            elem.reportValidity();
        }
        if (ref.serviceChargesValue < 0) {
            isValBreach = true;
            elem.setCustomValidity(validValue);
            elem.reportValidity();
        }
        return isValBreach;
        }
    } catch (error) {}
}
export function documentationCharges(ref) {
    try {
        if(ref.isTractor){return helper.documentationChargesHandler(ref);}else{
        let isValBreach = false;
        let elem = ref.template.querySelector('lightning-input[data-id=DocChar]');
        let checkDocChargesValue = parseInt(ref.documentationChargesValue, 10) % 5;
        elem.setCustomValidity("");
        //CISP-3785 start
        let gstValue = parseInt(ref.documentationChargesValue, 10) * 18.0 / 118;
        gstValue = Math.round(gstValue * 100) / 100;
        let docAmount = parseInt(ref.documentationChargesValue, 10) - gstValue;
        //CISP-3785 end
        if (ref.productTypeDetail.toLowerCase() === 'Passenger Vehicles'.toLowerCase() && (ref.vehicleTypeDetail.toLowerCase() === 'used'.toLowerCase() || ref.vehicleTypeDetail.toLowerCase() === 'Refinance'.toLowerCase() || ref.vehicleTypeDetail.toLowerCase() === 'new'.toLowerCase())) {
            let docChargesValuePv = (ref.documentChargesPercentageValid * parseInt(ref.requiredLoanAmount, 10)) / 100;
            //CISP-3785
            if (docAmount > parseInt(docChargesValuePv, 10)) {
                isValBreach = true;
                elem.setCustomValidity('Document value - ' + docAmount + ', GST value -' + gstValue + ' ' + documentationValidation);
                elem.reportValidity();
            }
            //CISP-3785
            else if (checkDocChargesValue !== 0) {
                isValBreach = true;
                elem.setCustomValidity('Please enter documentation charges in multiples of 5');
                elem.reportValidity();
            }
        }
        if (ref.productTypeDetail.toLowerCase() === 'Two Wheeler'.toLowerCase() && (ref.vehicleTypeDetail.toLowerCase() === 'used'.toLowerCase() || ref.vehicleTypeDetail.toLowerCase() === 'Refinance'.toLowerCase() || ref.vehicleTypeDetail.toLowerCase() === 'new'.toLowerCase())) {
            let checkDocChargesValueMax = (ref.documentChargesPercentageValid * parseInt(ref.requiredLoanAmount, 10)) / 100;
            let checkDocChargesValueMin = (ref.documentChargesMinPercValid * parseInt(ref.requiredLoanAmount, 10)) / 100;

            if(ref.nonD2cDsaTW && checkInput(ref.documentationChargesValue) && parseInt(ref.documentationChargesValue, 10) > parseInt(checkDocChargesValueMax, 10)) {
                isValBreach= true;
                elem.setCustomValidity(nonD2CdocumentationchargesValidation);
                elem.reportValidity();
            }else if (!ref.nonD2cDsaTW && checkInput(ref.documentationChargesValue) && parseInt(ref.documentationChargesValue, 10) < parseInt(checkDocChargesValueMin, 10) || parseInt(ref.documentationChargesValue, 10) > parseInt(checkDocChargesValueMax, 10)) {
                isValBreach= true;
                elem.setCustomValidity(documentationchargesValidation);
                elem.reportValidity();
            }
            if (checkDocChargesValue !== 0) {
                    isValBreach= true;
                    elem.setCustomValidity('Please enter documentation charges in multiples of 5');
                    elem.reportValidity();
                }
            // }
        }
        if (ref.documentationChargesValue < 0) {
            isValBreach = true;
            elem.setCustomValidity(validValue);
            elem.reportValidity();
        }
        return isValBreach;
        }
    } catch (error) {}
}
export function stampingCharges(ref) {
    try {
        let elem = ref.template.querySelector('lightning-input[data-id=stamChar]');
        elem.setCustomValidity("");
        if (ref.stampingChargesValue < ref.stampingChargesValid) {
            elem.setCustomValidity(lessThanEqual + ref.stampingChargesValid);
            elem.reportValidity();
        }
        if (ref.stampingChargesValue < 0) {
            elem.setCustomValidity(validValue);
            elem.reportValidity();
        }
    } catch (error) {}
}
export function dueDateShiftCharges(ref) {
    try {
        let elem = ref.template.querySelector('lightning-input[data-id=dueDateChar]');
        elem.setCustomValidity("");
        if (ref.dueDateShiftChargesValue < 0) {
            elem.setCustomValidity(validValue);
            elem.reportValidity();
        }
    } catch (error) {}
}
export function verificationCharges(ref) {
    try {
        let elem = ref.template.querySelector('lightning-input[data-id=veriChar]');
        elem.setCustomValidity("");
        if (ref.verificationChargesValue < 0) {
            elem.setCustomValidity(validValue);
            elem.reportValidity();
        }
    } catch (error) {}
}
export function delinquencyFund(ref) {
    try {
        let elem = ref.template.querySelector('lightning-input[data-id=deliFund]');
        elem.setCustomValidity("");
        if (ref.delinquencyFundValue < 0) {
            elem.setCustomValidity(validValue);
            elem.reportValidity();
        }
    } catch (error) {}
}
export function rtoPrefixFunction(ref) {
    try {
        if(!ref.rtoPrefixValue && ref.isTractor){
            let elem = ref.template.querySelector('lightning-input[data-id=rtoPre]');
            elem.setCustomValidity('');
            elem.reportValidity();
            return;
        }
        let rtoAlnu = ref.rtoPrefixValue.substring(0, 4);
        rtoValidation({
            loanApplicationId: ref.recordid,
            rtoAlnu: rtoAlnu
        }).then(result => {
            let response = JSON.parse(result);
            let elem = ref.template.querySelector('lightning-input[data-id=rtoPre]');
            elem.setCustomValidity('');
            if (response.message === ValidVehicleReg || response.message === InvalidVehicleReg) {
                ref.showToast("warning", validVehicleNo, 'warning');
                return;
            }
            if (response.message === 'InValid Vehicle Registration Number') {
                elem.setCustomValidity(vehicleRegistration);
                elem.reportValidity();
            }
        }).catch(error => {
            ('Error:', error);
        });
    } catch (error) {}
}
// Pay Out Functions
export function dealerExpReimburseAmount(ref) {
    try {
        let elem = ref.template.querySelector('lightning-input[data-id=dealExpReimburseAmt]');
        let element = ref.template.querySelector('lightning-input[data-id=dealExpReimburseper]');
        let checkDealerExpReimburseAmount = (ref.dealerExpReimburseValid * parseInt(ref.requiredLoanAmount, 10)) / 100;
        elem.setCustomValidity("");
        element.setCustomValidity("");
        if (ref.dealerExpReimburseAmountValue && (ref.dealerExpReimburseAmountValue > parseInt(checkDealerExpReimburseAmount, 10))) {
            elem.setCustomValidity(tenPercentageOfAmount);
        }
        if (ref.dealerExpReimburseAmountValue < 0) {
            elem.setCustomValidity(validValue);
            elem.reportValidity();
            element.reportValidity();
        }
    } catch (error) {}
}
export function dealerExpReimbursePercentage(ref) {
    try {
        let elem = ref.template.querySelector('lightning-input[data-id=dealExpReimburseper]');
        let element = ref.template.querySelector('lightning-input[data-id=dealExpReimburseAmt]');
        elem.setCustomValidity("");
        element.setCustomValidity("");
        if (ref.dealerExpReimbursePercentageValue > ref.dealerExpReimbursePercentValid) {
            elem.setCustomValidity(tenPercentageOfAmount);
        }
        if (ref.dealerExpReimbursePercentageValue < 0) {
            elem.setCustomValidity(validValue);
            elem.reportValidity();
            element.reportValidity();
        }
    } catch (error) {}
}
export function mfrExpReimbursePercentage(ref) {
    try {
        let elem = ref.template.querySelector('lightning-input[data-id=mfrExpReimper]');
        let element = ref.template.querySelector('lightning-input[data-id=mfrExpReimAmt]');
        element.setCustomValidity("");
        elem.setCustomValidity("");
        if (ref.mfrExpReimbursePercentageValue > ref.mfrExpReimbursePercentValid) {
            elem.setCustomValidity(tenPercentageOfAmount);
            elem.reportValidity();
        }
        if (ref.mfrExpReimbursePercentageValue < 0) {
            elem.setCustomValidity(validValue);
            elem.reportValidity();
            element.reportValidity();
        }
    } catch (error) {}
}
export function mfrExpReimburseAmtFn(ref) {
    try {
        let elem = ref.template.querySelector('lightning-input[data-id=mfrExpReimAmt]');
        let element = ref.template.querySelector('lightning-input[data-id=mfrExpReimper]');
        let checkMfrExpReimburseAmt = (ref.mfrExpReimburseAmtValid * parseInt(ref.requiredLoanAmount, 10)) / 100;
        elem.setCustomValidity("");
        element.setCustomValidity("");
        if (ref.mfrExpReimburseAmtValue && (ref.mfrExpReimburseAmtValue > parseInt(checkMfrExpReimburseAmt, 10))) {
            elem.setCustomValidity(tenPercentageOfAmount);
            elem.reportValidity();
        }
        if (ref.mfrExpReimburseAmtValue < 0) {
            elem.setCustomValidity(validValue);
            elem.reportValidity();
            element.reportValidity();
        }
    } catch (error) {}
}
export function dealerIncentiveAmountMain(ref) {
    try {
        helper.dealerIncentiveAmountMainHandler(ref);
    } catch (error) {}
}
export function dealerIncentiveAmountSub(ref) {
    try {
        let elem = ref.template.querySelector('lightning-input[data-id=dealInceAmtSub]');
        if (ref.productTypeDetail.toLowerCase() === 'Two Wheeler'.toLowerCase() && (ref.vehicleTypeDetail.toLowerCase() === 'new'.toLowerCase())) {
            let checkDealerIncentiveAmountSubH = (ref.dealerIncentiveAmountSubDealerValid * parseInt(ref.requiredLoanAmount, 10)) / 100;
            elem.setCustomValidity("");
            if (ref.dealerIncentiveAmountSubValue && (ref.dealerIncentiveAmountSubValue > parseInt(checkDealerIncentiveAmountSubH, 10))) {
                elem.setCustomValidity(FivePercentageOfAmount);
                elem.reportValidity();
            }
        } else if (ref.productTypeDetail.toLowerCase() === 'Passenger Vehicles'.toLowerCase() && (ref.vehicleTypeDetail.toLowerCase() === 'new'.toLowerCase())) {
            let checkDealerIncentiveAmountSubC = (ref.dealerIncentiveAmountSubDealerValid * parseInt(ref.requiredLoanAmount, 10)) / 100;
            elem.setCustomValidity("");
            if (ref.dealerIncentiveAmountSubValue && (ref.dealerIncentiveAmountSubValue > parseInt(checkDealerIncentiveAmountSubC, 10))) {
                elem.setCustomValidity(tenPercentageOfAmount);
                elem.reportValidity();
            }
        } else if (ref.productTypeDetail.toLowerCase() === 'Two Wheeler'.toLowerCase() && (ref.vehicleTypeDetail.toLowerCase() === 'Refinance'.toLowerCase() || ref.vehicleTypeDetail.toLowerCase() === 'used'.toLowerCase())) {
            elem.setCustomValidity("");
            if (ref.dealerIncentiveAmountSubValue >= 1) {
                elem.setCustomValidity(noPayout);
                elem.reportValidity();
            }
        }
        if (ref.dealerIncentiveAmountSubValue < 0) {
            elem.setCustomValidity(validValue);
            elem.reportValidity();
        }
    } catch (error) {}
}
export function dealerDiscounttoCustomer(ref) {
    try {
        let elem = ref.template.querySelector('lightning-input[data-id=dealDiscCust]');
        elem.setCustomValidity("");
        let checkDealerDiscounttoCustomer;
        if (ref.productTypeDetail.toLowerCase() === 'Passenger Vehicles'.toLowerCase() && (ref.vehicleTypeDetail.toLowerCase() === 'new'.toLowerCase())) {
            if (ref.fundingOnExShowroom === true) {
                checkDealerDiscounttoCustomer = (ref.dealerDiscounttoCustomerValid * parseInt(ref.exShowroom, 10)) / 100;
            }
            if (ref.fundingOnORP === true) {
                checkDealerDiscounttoCustomer = (ref.dealerDiscounttoCustomerValid * parseInt(ref.ORP, 10)) / 100;
            }
            if (ref.dealerDiscounttoCustomerValue && (ref.dealerDiscounttoCustomerValue > parseInt(checkDealerDiscounttoCustomer, 10))) {
                elem.setCustomValidity(dealerDiscountValidation);
                elem.reportValidity();
            }
        } else if ((ref.productTypeDetail.toLowerCase() === 'Passenger Vehicles'.toLowerCase() || ref.productTypeDetail.toLowerCase() === 'Two Wheeler'.toLowerCase()) && (ref.vehicleSubCategoryDetail && ref.vehicleSubCategoryDetail.toLowerCase() === 'UPD'.toLowerCase())) {
            checkDealerDiscounttoCustomer = (ref.dealerDiscounttoCustomerValid * parseInt(ref.requiredLoanAmount, 10)) / 100;
            if (ref.dealerDiscounttoCustomerValue && (ref.dealerDiscounttoCustomerValue > parseInt(checkDealerDiscounttoCustomer, 10))) {
                elem.setCustomValidity(maxPercentage);
                elem.reportValidity();
            }
        } else if(!ref.isTractor){
            if (ref.fundingOnExShowroom === true) {
                checkDealerDiscounttoCustomer = (ref.dealerDiscounttoCustomerValid * parseInt(ref.exShowroom, 10)) / 100;
            }
            if (ref.fundingOnORP === true) {
                checkDealerDiscounttoCustomer = (ref.dealerDiscounttoCustomerValid * parseInt(ref.ORP, 10)) / 100;
            }
            if (ref.dealerDiscounttoCustomerValue && (ref.dealerDiscounttoCustomerValue > parseInt(checkDealerDiscounttoCustomer, 10))) {
                elem.setCustomValidity(dealerDiscount);
                elem.reportValidity();
            }
        }else if (ref.productTypeDetail.toLowerCase() === 'Tractor'.toLowerCase()) {
            let checkDealerDiscounttoCustomer = (ref.dealerDiscounttoCustomerValid * parseInt(ref.requiredLoanAmount, 10)) / 100;
            elem.setCustomValidity("");
            if (ref.dealerDiscounttoCustomerValue && (ref.dealerDiscounttoCustomerValue > parseInt(checkDealerDiscounttoCustomer, 10))) {
                elem.setCustomValidity(`Max ${ref.dealerDiscounttoCustomerValid}% on Finance amount`);
                elem.reportValidity();
            }
        }
        if (ref.dealerDiscounttoCustomerValue < 0) {
            elem.setCustomValidity(validValue);
            elem.reportValidity();
        }
    } catch (error) {}
}
export function giftThroughDealerAmount(ref) {
    try {
        let elem = ref.template.querySelector('lightning-input[data-id=giftDealAmt]');
        elem.setCustomValidity("");
        if (ref.productTypeDetail.toLowerCase() === 'Two Wheeler'.toLowerCase() && (ref.vehicleTypeDetail.toLowerCase() === 'new'.toLowerCase())) {
            let checkGiftThroughDealerAmountH = (ref.giftThroughDealerAmountValid * parseInt(ref.requiredLoanAmount, 10)) / 100;
            elem.setCustomValidity("");
            if (ref.giftThroughDealerAmountValue && (ref.giftThroughDealerAmountValue > parseInt(checkGiftThroughDealerAmountH, 10))) {
                elem.setCustomValidity(FivePercentageOfAmount);
                elem.reportValidity();
            }
        } else if (ref.productTypeDetail.toLowerCase() === 'Passenger Vehicles'.toLowerCase()) {
            let checkGiftThroughDealerAmountC = (ref.giftThroughDealerAmountValid * parseInt(ref.requiredLoanAmount, 10)) / 100;
            elem.setCustomValidity("");
            if (ref.giftThroughDealerAmountValue && (ref.giftThroughDealerAmountValue > parseInt(checkGiftThroughDealerAmountC, 10))) {
                elem.setCustomValidity(tenPercentageOfAmount);
                elem.reportValidity();
            }
        } else if (ref.productTypeDetail.toLowerCase() === 'Two Wheeler'.toLowerCase() && (ref.vehicleTypeDetail.toLowerCase() === 'Refinance'.toLowerCase() || ref.vehicleTypeDetail.toLowerCase() === 'used'.toLowerCase())) {
            elem.setCustomValidity("");
            if (ref.giftThroughDealerAmountValue >= 1) {
                elem.setCustomValidity(noPayout);
                elem.reportValidity();
            }
        }else if (ref.productTypeDetail.toLowerCase() === 'Tractor'.toLowerCase()) {
            let checkGiftThroughDealerAmountT = (ref.giftThroughDealerAmountValid * parseInt(ref.requiredLoanAmount, 10)) / 100;
            elem.setCustomValidity("");
            if (ref.giftThroughDealerAmountValue && (ref.giftThroughDealerAmountValue > parseInt(checkGiftThroughDealerAmountT, 10))) {
                elem.setCustomValidity(`Max ${ref.giftThroughDealerAmountValid}% on Finance amount`);
                elem.reportValidity();
            }
        }
        if (ref.giftThroughDealerAmountValue < 0) {
            elem.setCustomValidity(validValue);
            elem.reportValidity();
        }
    } catch (error) {}
}
export function dsmNameOne(ref) {
    try {
        let elem = ref.template.querySelector('.dsmName1');
        elem.setCustomValidity('');
        if (ref.dsmNameOneValue && ref.dsmNameTwoValue && ref.dsmNameOneValue === ref.dsmNameTwoValue) {
            elem.setCustomValidity(DsmError);
        }
        elem.reportValidity();
    } catch (error) {}
}
export function dsmIncentiveOne(ref) {
    try {
        helper.dsmIncentiveOneHandler(ref);
    } catch (error) {}
}
export function dsmNameTwo(ref) {
    try {
        let elem = ref.template.querySelector('.dsmName2');
        elem.setCustomValidity('');
        if (ref.dsmNameOneValue && ref.dsmNameTwoValue && ref.dsmNameOneValue === ref.dsmNameTwoValue) {
            elem.setCustomValidity(DsmError);
        }
        elem.reportValidity();
    } catch (error) {}
}
export function dsmIncentiveTwo(ref) {
    try {
        helper.dsmIncentiveTwoHandler(ref);
    } catch (error) {}
}
export function referrerIncentive(ref) {
    try {
        helper.referrerIncentiveHandler(ref);
    } catch (error) {}
}
export function provisionalChannelCost(ref) {
    try {
        let elem = ref.template.querySelector('lightning-input[data-id=proChnCost]');
        let checkProvisionalChannelCost;
        if (ref.currentStage !== 'Credit Processing') {
            if (ref.productTypeDetail.toLowerCase() === 'Two Wheeler'.toLowerCase() && (ref.vehicleTypeDetail.toLowerCase() === 'new'.toLowerCase())) {
                if (ref.requiredTenureDetails > 12) {
                    checkProvisionalChannelCost = (ref.provisionalChannelCostValid * (parseInt(ref.requiredLoanAmount, 10) / 100) + ref.provisionalChannelCostMinValid);
                    ref.provisionalChannelCostValue = (Math.round(checkProvisionalChannelCost));
                    ref.disabledProvisionalChannelCost = true;
                } else {
                    checkProvisionalChannelCost = (ref.provisionalChannelCostTwoValid * (parseInt(ref.requiredLoanAmount, 10) / 100) + ref.provisionalChannelCostMaxValid);
                    ref.provisionalChannelCostValue = (Math.round(checkProvisionalChannelCost));
                    ref.disabledProvisionalChannelCost = true;
                }
            } else if (ref.productTypeDetail.toLowerCase() === 'Two Wheeler'.toLowerCase() && (ref.vehicleTypeDetail.toLowerCase() === 'Refinance'.toLowerCase() || ref.vehicleTypeDetail.toLowerCase() === 'used'.toLowerCase())) {
                checkProvisionalChannelCost = ((ref.provisionalChannelCostValid * parseInt(ref.requiredLoanAmount, 10) / 100) + ref.provisionalChannelCostMaxValid);
                ref.provisionalChannelCostValue = (Math.round(checkProvisionalChannelCost));
                ref.disabledProvisionalChannelCost = true;
            }
        } else {
            if (ref.productTypeDetail.toLowerCase() === 'Two Wheeler'.toLowerCase() && (ref.vehicleTypeDetail.toLowerCase() === 'new'.toLowerCase())) {
                if (offerEngineTenure > 12) {
                    checkProvisionalChannelCost = (ref.provisionalChannelCostValid * (parseInt(ref.offerEngineLoanAmount, 10) / 100) + ref.provisionalChannelCostMinValid);
                    checkProvisionalChannelCost = (Math.round(checkProvisionalChannelCost));
                    elem.setCustomValidity("");
                    if (ref.provisionalChannelCostValue != checkProvisionalChannelCost) {
                        elem.setCustomValidity('Enter value Equals to ' + checkProvisionalChannelCost);
                        elem.reportValidity();
                    } else {
                        ref.provisionalChannelCostValue = null;
                        ref.disabledProvisionalChannelCost = true;
                    }
                } else {
                    checkProvisionalChannelCost = (ref.provisionalChannelCostTwoValid * (parseInt(ref.offerEngineLoanAmount, 10) / 100) + ref.provisionalChannelCostMaxValid);
                    checkProvisionalChannelCost = (Math.round(checkProvisionalChannelCost));
                    elem.setCustomValidity("");
                    if (ref.provisionalChannelCostValue != checkProvisionalChannelCost) {
                        elem.setCustomValidity('Enter value Equals to ' + checkProvisionalChannelCost);
                        elem.reportValidity();
                    } else {
                        ref.provisionalChannelCostValue = null;
                        ref.disabledProvisionalChannelCost = true;
                    }
                }
            } else if (ref.productTypeDetail.toLowerCase() === 'Two Wheeler'.toLowerCase() && (ref.vehicleTypeDetail.toLowerCase() === 'Refinance'.toLowerCase() || ref.vehicleTypeDetail.toLowerCase() === 'used'.toLowerCase())) {
                checkProvisionalChannelCost = ((ref.provisionalChannelCostValid * parseInt(ref.offerEngineLoanAmount, 10) / 100) + ref.provisionalChannelCostMaxValid);
                checkProvisionalChannelCost = (Math.round(checkProvisionalChannelCost));
                elem.setCustomValidity("");
                if (ref.provisionalChannelCostValue != checkProvisionalChannelCost) {
                    elem.setCustomValidity('Enter value Equals to ' + checkProvisionalChannelCost);
                    elem.reportValidity();
                } else {
                    ref.provisionalChannelCostValue = null;
                    ref.disabledProvisionalChannelCost = true;
                }
            }
        }
    } catch (error) {}
}
export function dsaPay(ref) {
    try {
        if (ref.displayDsaRcu) {
            let elem = ref.template.querySelector('lightning-input[data-id=dsapay]');
            elem.setCustomValidity("");
            if (ref.referrerIncentiveValue < 0) {
                elem.setCustomValidity(validValue);
                elem.reportValidity();
            }
        }
    } catch (error) {}
}
export function rcuRetentionCharges(ref) {
    try {
        if (ref.displayDsaRcu) {
            let elem = ref.template.querySelector('lightning-input[data-id=rcuRet]');
            elem.setCustomValidity("");
            if (ref.referrerIncentiveValue < 0) {
                elem.setCustomValidity(validValue);
                elem.reportValidity();
            }
        }
    } catch (error) {}
}

export function installmentsFrequency(ref,onLoad,evt) {
    try {
        ref.installmentFrequencyValue = evt?.target?.value ? evt?.target?.value : ref.installmentFrequencyValue; //SFTRAC-1795 moved to helper
        if (ref.productTypeDetail === 'Tractor') {
            if(ref.installmentFrequencyValue === 'Monthly'){
                ref.advanceEmiDisabled = false;
            }else{
                ref.advanceEmiDisabled = true;
                ref.advanceEmiValue = false;
                let advanceEMiInput=ref.template.querySelector('lightning-input[data-id=advanceEMIid]');
                if(advanceEMiInput){advanceEMiInput.checked = ref.advanceEmiValue}
                let elem=ref.template.querySelector('.monDay');
                if(elem){
                    elem.setCustomValidity("");
                    elem.reportValidity();
                    elem.disabled = false
                    elem.value = '';
                }
                ref.monitoriumDaysDisabled = false;
                if(onLoad != false){ref.monitoriumDaysValue='0';}
            }
            let elem = ref.template.querySelector('.freqInst');
            elem?.setCustomValidity("");
            if (ref.schemeInsFrequency && !ref.schemeInsFrequency.includes(ref.installmentFrequencyValue)) {
                elem.setCustomValidity('Please select any other Installment Frequency');
                elem.reportValidity();
            }else if(ref.installmentFrequencyValue.toUpperCase() != ref.repaymentFrequency?.toUpperCase() && onLoad != false){//SFTRAC-1795
                //elem.setCustomValidity('You have changed the Installment Frequency of the asset as compared to FI data. Please inform the customer regarding the change.');
                //elem.reportValidity();
                const evt = new ShowToastEvent({
                    title: 'Warning',
                    message: 'You have changed the Installment Frequency of the asset as compared to FI data. Please inform the customer regarding the change',
                    variant: 'warning',mode: 'dismissible'});
                    ref.dispatchEvent(evt);
            }//SFTRAC-1795
            helper.handleLoanDateCalHelper(ref);
            const monitoriumDaysList = [];
            if(ref.installmentFrequencyValue === 'Monthly'){
                monitoriumDaysList.push(
                    { label: '0', value: '0' },
                    { label: '30', value: '30' }
                );
            }else if(ref.installmentFrequencyValue === 'bi-monthly'){
                monitoriumDaysList.push(
                    { label: '30', value: '30' },
                    { label: '60', value: '60' }
                );
            }else if(ref.installmentFrequencyValue === 'Quarterly'){
                monitoriumDaysList.push(
                    { label: '30', value: '30' },
                    { label: '60', value: '60' },
                    { label: '90', value: '90' }
                );
            }else if(ref.installmentFrequencyValue === 'Half yearly'){
                monitoriumDaysList.push(
                    { label: '30', value: '30' },
                    { label: '60', value: '60' },
                    { label: '90', value: '90' },
                    { label: '120', value: '120' },
                    { label: '150', value: '150' },
                    { label: '180', value: '180' }
                );
            }
            ref.monitoriumDaysOption = monitoriumDaysList;
        }
    } catch (error) {}
}

export function installmentsType(ref,evt) {
    try {
        ref.installmentTypeValue = evt.target.value; //SFTRAC-1795
        if (ref.productTypeDetail === 'Tractor') {
            let elem = ref.template.querySelector('.Install');
            elem.setCustomValidity("");
            if (ref.schemeInsTypes && !ref.schemeInsTypes.includes(ref.installmentTypeValue)) {
                elem.setCustomValidity('Please select any other Installment Type');
                elem.reportValidity();
            }else if(ref.installmentTypeValue.toUpperCase() != ref.installMentType?.toUpperCase()){//SFTRAC-1795
                //elem.setCustomValidity('You have changed the Installment Type of the asset as compared to FI data. Please inform the customer regarding the change.');
                //elem.reportValidity();
                const evt = new ShowToastEvent({
                    title: 'Warning',
                    message: 'You have changed the Installment Type of the asset as compared to FI data. Please inform the customer regarding the change',
                    variant: 'warning',mode: 'dismissible'});
                    ref.dispatchEvent(evt);
            }//SFTRAC-1795
        }
    } catch (error) {}
}
export function payinCap(ref) {
    try {
        let sumofPayin = (checkInput(ref.serviceChargesValue) ? parseInt(ref.serviceChargesValue) : 0) + (checkInput(ref.documentationChargesValue) ? parseInt(ref.documentationChargesValue) : 0) + (checkInput(ref.stampingChargesValue) ? parseInt(ref.stampingChargesValue) : 0) + (checkInput(ref.dueDateShiftChargesValue) ? parseInt(ref.dueDateShiftChargesValue) : 0) + (checkInput(ref.verificationChargesValue) ? parseInt(ref.verificationChargesValue) : 0) + (checkInput(ref.tradeCertificateValue) ? parseInt(ref.tradeCertificateValue) : 0);
        if (((ref.payinMax * ref.requiredLoanAmount) / 100) < sumofPayin) {
            return true;
        }
    } catch (error) {
        console.error(error);
    }
}
export function payoutCap(ref) {
    try {
        if(ref.isTractor){
            let sumofPayout = (checkInput(ref.dealerIncentiveAmountMainValue) ? parseInt(ref.dealerIncentiveAmountMainValue) : 0) + (checkInput(ref.dealerDiscounttoCustomerValue) ? parseInt(ref.dealerDiscounttoCustomerValue) : 0) + (checkInput(ref.giftThroughDealerAmountValue) ? parseInt(ref.giftThroughDealerAmountValue) : 0) + (checkInput(ref.dsmIncentiveOneValue) ? parseInt(ref.dsmIncentiveOneValue) : 0) + (checkInput(ref.dsmIncentiveTwoValue) ? parseInt(ref.dsmIncentiveTwoValue) : 0) + (checkInput(ref.referrerIncentiveValue) ? parseInt(ref.referrerIncentiveValue) : 0);
            if (((ref.payoutMax * ref.requiredLoanAmount) / 100) < sumofPayout) {
                return true;
            }
        }else{
        let sumofPayout = (checkInput(ref.dealerIncentiveAmountMainValue) ? parseInt(ref.dealerIncentiveAmountMainValue) : 0) + (checkInput(ref.dealerIncentiveAmountSubValue) ? parseInt(ref.dealerIncentiveAmountSubValue) : 0) + (checkInput(ref.giftThroughDealerAmountValue) ? parseInt(ref.giftThroughDealerAmountValue) : 0) + (checkInput(ref.dsmIncentiveOneValue) ? parseInt(ref.dsmIncentiveOneValue) : 0) + (checkInput(ref.dsmIncentiveTwoValue) ? parseInt(ref.dsmIncentiveTwoValue) : 0) + (ref.nonD2cDsaTW && checkInput(ref.manufacturerIncentiveValue) ? parseInt(ref.manufacturerIncentiveValue) : 0);
        if (((ref.payoutCapValue * ref.requiredLoanAmount) / 100) < sumofPayout) {
            return true;
        }
        }
    } catch (error) {}
}
//CISP-124
export function calculateProvisionAmt(ref,totalFundedPremium, offerLoanAmount, requireLoanAmount, offerTenure, requireTenure, productType, vehicleType, provisionalChannelCostValid, provisionalChannelCostMinValid, provisionalChannelCostTwoValid, provisionalChannelCostMaxValid) {
    try {
        let loanAmount = offerLoanAmount ? offerLoanAmount : requireLoanAmount;
        let finalLoanAmount = parseInt(loanAmount) + parseInt(totalFundedPremium);
        let tenure = offerTenure ? offerTenure : requireTenure;
        let returnObj = {};
        if (productType.toLowerCase() === 'Two Wheeler'.toLowerCase() && (vehicleType.toLowerCase() === 'new'.toLowerCase())) {
            if (tenure >= 12) {
                let checkProvisionalChannelCost = (provisionalChannelCostValid * (parseInt(finalLoanAmount, 10) / 100) + provisionalChannelCostMinValid);
                checkProvisionalChannelCost = (Math.round(checkProvisionalChannelCost));
                returnObj.provisionalChannelCostValue = checkProvisionalChannelCost;
                returnObj.disabledProvisionalChannelCost = true;
            } else {
                let checkProvisionalChannelCost = (provisionalChannelCostTwoValid * (parseInt(finalLoanAmount, 10) / 100) + provisionalChannelCostMaxValid);
                checkProvisionalChannelCost = (Math.round(checkProvisionalChannelCost));
                returnObj.provisionalChannelCostValue = checkProvisionalChannelCost;
                returnObj.disabledProvisionalChannelCost = true;
            }
        } else if (productType.toLowerCase() === 'Two Wheeler'.toLowerCase() && (vehicleType.toLowerCase() === 'Refinance'.toLowerCase() || vehicleType.toLowerCase() === 'used'.toLowerCase())) {
            let checkProvisionalChannelCost = ((provisionalChannelCostValid * parseInt(finalLoanAmount, 10) / 100) + provisionalChannelCostMaxValid);
            checkProvisionalChannelCost = (Math.round(checkProvisionalChannelCost));
            returnObj.provisionalChannelCostValue = checkProvisionalChannelCost;
            returnObj.disabledProvisionalChannelCost = true;
        }else  if (productType == 'Tractor') {
            if (ref.vehicleSubType == 'Tractor' || ref.vehicleSubType == 'Implement') {
                returnObj.provisionalChannelCostValue = 2000;
            } else if (ref.vehicleSubType == 'Harvester') {
                returnObj.provisionalChannelCostValue = 10000;
            }
            returnObj.disabledProvisionalChannelCost = true;
        }// sftrac-84
        return returnObj;
    } catch (error) {}
}
//CISP-124

export function checkInput(inputParam){//CISP-2685
    if(inputParam!==null && inputParam!==undefined && inputParam!=='' && inputParam!==NaN && !Number.isNaN(inputParam)){//CISP-4785 Added contition to check for NaN
        return true;
    } else {
        return false;
    }
} //CISP-2685

//D2C Changes Swapnil
export function getParsedJSOND2C(parsedJSON) {
    let obj = {};
    obj.EMI = parsedJSON?.application?.offerEngineDetails?.offerEngineDecision?.displayEMI;
    obj.Tenure = parsedJSON?.application?.offerEngineDetails?.offerEngineDecision?.displayTenure;
    obj.Tenure = obj.Tenure != null ? obj.Tenure.toString() : '';
    obj.Loan_Amt = parsedJSON?.application?.offerEngineDetails?.offerEngineDecision?.displayLoanAmt;
    obj.CRM_IRR = parsedJSON?.application?.offerEngineDetails?.offerEngineDecision?.displayCrmIrr;
    obj.CRM_IRR = obj.CRM_IRR != null ? obj.CRM_IRR.toString() : '';
    obj.Max_Tenure_Slider = parsedJSON?.application?.offerEngineDetails?.offerEngineDecision?.maxTenureSlider;
    obj.Min_Tenure_Slider = parsedJSON?.application?.offerEngineDetails?.offerEngineDecision?.minTenureSlider;
    obj.Min_Loan_Amt_Slider = parsedJSON?.application?.offerEngineDetails?.offerEngineDecision?.minLoanAmtSlider;
    obj.Max_Loan_Amt_Slider = parsedJSON?.application?.offerEngineDetails?.offerEngineDecision?.maxLoanAmtSlider;
    obj.Imputed_IRR_Offered = parsedJSON?.application?.offerEngineDetails?.offerEngineDecision?.displayImputedIrr;
    obj.Net_IRR_Offered = parsedJSON?.application?.offerEngineDetails?.offerEngineDecision?.netIrr;
    obj.Gross_IRR_Offered = parsedJSON?.application?.offerEngineDetails?.offerEngineDecision?.grossIrr;
    obj.Stop_Journey_Flag = parsedJSON?.application?.offerEngineDetails?.offerEngineDecision?.stopJourneyFlag;
    obj.Stop_Journey_Flag = obj.Stop_Journey_Flag ? 'True' : 'False'; //D2C change - Rahul
    obj.NetPayIns = parsedJSON?.application?.offerEngineDetails?.offerEngineDecision?.netPayIns?.toString();
    obj.NetPayOuts = parsedJSON?.application?.offerEngineDetails?.offerEngineDecision?.netPayOuts?.toString();
    obj.TableCode = parsedJSON?.application?.tableCode;
    obj.Interest_VersionNo = parsedJSON?.application?.interestVersionNo;
    obj.DR_PenalInterest = parsedJSON?.application?.drPenalInterest?.toString();
    obj.mclrRate = parsedJSON?.application?.loanDetails?.mclrRate?.toString(); 
    obj.serviceCharges = parsedJSON?.application?.offerEngineDetails?.payins?.serviceCharges?.toString();
    obj.docCharges = parsedJSON?.application?.offerEngineDetails?.payins?.docCharges?.toString();
    obj.provisionCost = parsedJSON?.application?.offerEngineDetails?.payouts?.provisionCost?.toString();
    obj.mfrIncentiveAmt = parsedJSON?.application?.offerEngineDetails?.payouts?.mfrIncentiveAmt?.toString();
    obj.dlrIncentiveAmtMain = parsedJSON?.application?.offerEngineDetails?.payouts?.dlrIncentiveAmtMain?.toString();     
    obj.loanDealDate = parsedJSON?.application?.offerEngineDetails?.loanDealDate;     
    obj.agreementAmount = parsedJSON?.application?.offerEngineDetails?.offerEngineDecision?.agreementAmount;     
    obj.amortizationSchedule = parsedJSON?.application?.offerEngineDetails?.offerEngineDecision?.amortizationSchedule;     
    return obj; 
}

export function roundOff(inputParam) {
    if (inputParam === null || inputParam === undefined || inputParam === '' || inputParam === NaN) {
        return 0;
    } else {
        return Math.round(inputParam);
    }
}
export const getIESresponse = (recordId) => {
    return getIES({
        'loanApplicationId': recordId
    }).then((result) => {
        if (result && result === true) {
            return true;
        } else {
            return false;
        }
    }).catch((error) => {});
}
//CISP-4784
   async function confirmModal(messages,variants,labels,themes){
        return await LightningConfirm.open({
        message: messages,
        variant: variants,
        label: labels,
        theme: themes
    });
}
//CISP-4784
    export async function handleChangesubDealer(value, thistemplate){
       if(value >=0 && value <=9){
      const result= await confirmModal('Are you sure the Dealer Incentive amount entered is correct?','headerless','Confirm','white');
      if(result){
       thistemplate.querySelector('lightning-input[data-id=dealInceAmtSub]').disabled=true;
       thistemplate.querySelector('lightning-input[data-id=dealInceSubPer]').disabled=true;
    }
    }
}
 //CISP-4459 start
 export function journeyStopScenarioFound(recordid){
    updateJourneyStop({ leadNo: recordid })
    .then(result => {}).catch(error => {});
}//CISP-4459
//OLA-171 start
export function scorecardvalue(thistemplate) {
    thistemplate.querySelector('.scheme').disabled=false;
    thistemplate.querySelector('.repaymo').disabled=false;//OLA-30
    thistemplate.querySelector('.checkEli').disabled=false;//OLA-32
}
//OLA-171 end
//CISH-02
export function scorecardvalueHero(thistemplate) {
    thistemplate.querySelector('.scheme').disabled=true;
    thistemplate.querySelector('.repaymo').disabled=false;
    thistemplate.querySelector('.checkEli').disabled=false;
}//CISH-02

//CISP-8307 start
export const dsmNameDatahelper = (recordid,vehicleId,ref) => {
    return dsmNameData({ loanApplicationId: recordid, vehicleId: vehicleId}).then(response => 
        {
            let dsmData = []; 
            if(ref.isTractor){dsmData.push({label : '--None--', value : '', id : ''})}
            if(response){
                for (var key in response){
                    let dsmDataListObj={};
                    dsmDataListObj.label=response[key];
                    dsmDataListObj.value=response[key];
                    dsmDataListObj.id=key;
                    dsmData.push(dsmDataListObj);
                }}
                return dsmData;
    }).catch(error => {return null})
}

    export const nonDsmNameDatahelper = (recordid,vehicleId,ref) => {
        return nonDsmNameData({ loanApplicationId: recordid, vehicleId: vehicleId}).then(response => 
            {
                let nonDsmData=[];
                if(ref.isTractor){nonDsmData.push({label : '--None--', value : '', id : ''})}
                if(response){
                    for (var key in response){
                        let nonDsmDataListObj={};
                        nonDsmDataListObj.label=response[key];
                        nonDsmDataListObj.value=response[key];
                        nonDsmDataListObj.id=key;
                        nonDsmData.push(nonDsmDataListObj);
                    }}
                    return nonDsmData;
                }).catch(error => {return null})
}
//CISP-8307 end

//CISP-4785 get median pay-out values
export async function getMedianPayout(thisVar) {
    let result = await calculateMedianPayouts({'loanApplicationId' : thisVar.recordid});
    let keys = Object.keys(result);
    keys.forEach((key) => {
        if(key == 'mainDlrIncentivePercentMedian'){
            thisVar.mainDlrIncentivePercentMedian = result[key];
        } else if(key == 'subDlrIncentivePercentMedian'){
            thisVar.subDlrIncentivePercentMedian = result[key];
        } else if(key == 'dsmIncentive1PercentMedian'){
            thisVar.dsmIncentive1PercentMedian = result[key];
        } else if(key == 'dsmIncentive2PercentMedian'){
            thisVar.dsmIncentive2PercentMedian = result[key];
        }
    });
}

//CISP-4785 show warning toast on higher % or lower % of pay-out fields
export async function showPayoutWarning(thisVar, variant) {
    if (variant != null || variant != undefined) {
        let msg = '';
        if (variant == 'higher') {
            msg = 'For this field, you have chosen to enter higher%. Do you still wish to proceed?'
        } else if (variant == 'lower') {
            msg = 'For this field, you have chosen to enter Lower %. Do you still wish to proceed?';
        } else if (variant == 'zero') {
            msg = 'For this field, you have not entered any %. Do you still wish to proceed?';
        }
        if (thisVar.fromVfPage) {
            alert(msg);
        } else {
            const evt = new ShowToastEvent({
                title: 'Warning',
                message: msg,
                variant: 'warning',
                mode: 'dismissible'
            });
            thisVar.dispatchEvent(evt);
        }
    }
}

//CISP-4785 Show confirmation modal popup amount is less then 10
export async function verifyAmountLessthan10(thisVar) {
    thisVar.showErrModal = false;
    thisVar.modalErrFlds = [];

    let invalidFieldsArr = [];

    if (thisVar.dealerExpReimburseAmountValue < 10 && thisVar.dealerExpReimburseAmountValue !== null && thisVar.dealerExpReimburseAmountValue !== undefined && thisVar.dealerExpReimburseAmountValue !== '' && thisVar.dealerExpReimburseAmountValue !== NaN) {
        invalidFieldsArr.push('Dealer Exp Reimburse Amount');
    }
    if (thisVar.mfrExpReimburseAmtValue < 10 && thisVar.mfrExpReimburseAmtValue !== null && thisVar.mfrExpReimburseAmtValue !== undefined && thisVar.mfrExpReimburseAmtValue !== '' && thisVar.mfrExpReimburseAmtValue !== NaN) {
        invalidFieldsArr.push('Mfr Exp Reimburse Amt');
    }
    if (thisVar.dealerIncentiveAmountMainValue < 10 && thisVar.dealerIncentiveAmountMainValue !== null && thisVar.dealerIncentiveAmountMainValue !== undefined && thisVar.dealerIncentiveAmountMainValue !== '' && thisVar.dealerIncentiveAmountMainValue !== NaN) {
        invalidFieldsArr.push('Dealer Incentive Amount Main Dealer');
    }
    if (thisVar.dealerIncentiveAmountSubValue < 10 && thisVar.dealerIncentiveAmountSubValue !== null && thisVar.dealerIncentiveAmountSubValue !== undefined && thisVar.dealerIncentiveAmountSubValue !== '' && thisVar.dealerIncentiveAmountSubValue !== NaN) {
        invalidFieldsArr.push('Dealer Incentive Amount Sub Dealer');
    }
    if (thisVar.giftThroughDealerAmountValue < 10 && thisVar.giftThroughDealerAmountValue !== null && thisVar.giftThroughDealerAmountValue !== undefined && thisVar.giftThroughDealerAmountValue !== '' && thisVar.giftThroughDealerAmountValue !== NaN) {
        invalidFieldsArr.push('Gift Through Dealer Amount');
    }
    if (thisVar.dsmIncentiveOneValue < 10 && thisVar.dsmIncentiveOneValue !== null && thisVar.dsmIncentiveOneValue !== undefined && thisVar.dsmIncentiveOneValue !== '' && thisVar.dsmIncentiveOneValue !== NaN) {
        invalidFieldsArr.push('DSM Incentive1');
    }
    if (thisVar.dsmIncentiveTwoValue < 10 && thisVar.dsmIncentiveTwoValue !== null && thisVar.dsmIncentiveTwoValue !== undefined && thisVar.dsmIncentiveTwoValue !== '' && thisVar.dsmIncentiveTwoValue !== NaN) {
        invalidFieldsArr.push('DSM Incentive2');
    }

    thisVar.modalErrFlds = invalidFieldsArr;
    
    if(invalidFieldsArr.length > 0) {
        thisVar.showErrModal = true;
        return false;
    } else {
        return true;
    }
}

//CISP-4785 Function to recalcualte payout fields and stampting charges based on the revised Finance amount
export async function recalculatePayoutValues(thisVar) {
    if(thisVar.fromVfPage && checkInput(thisVar.previousLoanAmount) && thisVar.offerScreenLoanAmount != thisVar.previousLoanAmount) {
        let totalPremium = checkInput(thisVar.totalFundedPremium) ? thisVar.totalFundedPremium : 0;
        let oldFinanceAmount = parseInt(thisVar.previousLoanAmount, 10) + totalPremium;
        let newFinanceAmount = parseInt(thisVar.offerScreenLoanAmount, 10) + totalPremium;

        thisVar.dealerExpReimburseAmountValue = checkInput(thisVar.dealerExpReimburseAmountValue) ? ((parseInt(thisVar.dealerExpReimburseAmountValue,10) / oldFinanceAmount) * newFinanceAmount).toFixed() : 0;
        thisVar.phdealerExpReimburseAmountValue = checkInput(thisVar.phdealerExpReimburseAmountValue) ? ((parseInt(thisVar.phdealerExpReimburseAmountValue,10) / oldFinanceAmount) * newFinanceAmount).toFixed() : 0;
        thisVar.dealerExpReimbursePercentageValue = ((thisVar.dealerExpReimburseAmountValue/ newFinanceAmount) * 100).toFixed(2);
        thisVar.phdealerExpReimbursePercentageValue = thisVar.dealerExpReimbursePercentageValue;

        thisVar.mfrExpReimburseAmtValue = checkInput(thisVar.mfrExpReimburseAmtValue) ? ((parseInt(thisVar.mfrExpReimburseAmtValue,10) / oldFinanceAmount) * newFinanceAmount).toFixed() : 0;
        thisVar.phmfrExpReimburseAmtValue = checkInput(thisVar.phmfrExpReimburseAmtValue) ? ((parseInt(thisVar.phmfrExpReimburseAmtValue,10) / oldFinanceAmount) * newFinanceAmount).toFixed() : 0;
        thisVar.mfrExpReimbursePercentageValue = ((thisVar.mfrExpReimburseAmtValue/ newFinanceAmount) * 100).toFixed(2);
        thisVar.phdealerExpReimbursePercentageValue = thisVar.mfrExpReimbursePercentageValue;

        thisVar.dealerIncentiveAmountMainValue = checkInput(thisVar.dealerIncentiveAmountMainValue) ? ((parseInt(thisVar.dealerIncentiveAmountMainValue,10) / oldFinanceAmount) * newFinanceAmount).toFixed() : 0;
        thisVar.phdealerIncentiveAmountMainValue = checkInput(thisVar.phdealerIncentiveAmountMainValue) ? ((parseInt(thisVar.phdealerIncentiveAmountMainValue,10) / oldFinanceAmount) * newFinanceAmount).toFixed() : 0;
        thisVar.dealerMainPercentageValue = ((thisVar.dealerIncentiveAmountMainValue/ newFinanceAmount) * 100).toFixed(2);

        thisVar.dealerIncentiveAmountSubValue = checkInput(thisVar.dealerIncentiveAmountSubValue) ? ((parseInt(thisVar.dealerIncentiveAmountSubValue,10) / oldFinanceAmount) * newFinanceAmount).toFixed() : 0;
        thisVar.phdealerIncentiveAmountSubValue = checkInput(thisVar.phdealerIncentiveAmountSubValue) ? ((parseInt(thisVar.phdealerIncentiveAmountSubValue,10) / oldFinanceAmount) * newFinanceAmount).toFixed() : 0;
        thisVar.dealerSubPercentageValue = ((thisVar.dealerIncentiveAmountSubValue/ newFinanceAmount) * 100).toFixed(2);

        thisVar.giftThroughDealerAmountValue = checkInput(thisVar.giftThroughDealerAmountValue) ? ((parseInt(thisVar.giftThroughDealerAmountValue,10) / oldFinanceAmount) * newFinanceAmount).toFixed() : 0;
        thisVar.phgiftThroughDealerAmountValue = checkInput(thisVar.phgiftThroughDealerAmountValue) ? ((parseInt(thisVar.phgiftThroughDealerAmountValue,10) / oldFinanceAmount) * newFinanceAmount).toFixed() : 0;
        thisVar.giftThroughDealerPercentageValue = ((thisVar.giftThroughDealerAmountValue/ newFinanceAmount) * 100).toFixed(2);

        thisVar.dsmIncentiveOneValue = checkInput(thisVar.dsmIncentiveOneValue) ? ((parseInt(thisVar.dsmIncentiveOneValue,10) / oldFinanceAmount) * newFinanceAmount).toFixed() : 0;
        thisVar.phdsmIncentiveOneValue = checkInput(thisVar.phdsmIncentiveOneValue) ? ((parseInt(thisVar.phdsmIncentiveOneValue,10) / oldFinanceAmount) * newFinanceAmount).toFixed() : 0;
        thisVar.dsmOnePercentageValue = ((thisVar.dsmIncentiveOneValue/ newFinanceAmount) * 100).toFixed(2);

        thisVar.dsmIncentiveTwoValue = checkInput(thisVar.dsmIncentiveTwoValue) ? ((parseInt(thisVar.dsmIncentiveTwoValue,10) / oldFinanceAmount) * newFinanceAmount).toFixed() : 0;
        thisVar.phdsmIncentiveTwoValue = checkInput(thisVar.phdsmIncentiveTwoValue) ? ((parseInt(thisVar.phdsmIncentiveTwoValue,10) / oldFinanceAmount) * newFinanceAmount).toFixed() : 0;
        thisVar.dsmTwoPercentageValue = ((thisVar.dsmIncentiveTwoValue/ newFinanceAmount) * 100).toFixed(2);

        thisVar.referrerIncentiveValue = checkInput(thisVar.referrerIncentiveValue) ? ((parseInt(thisVar.referrerIncentiveValue,10) / oldFinanceAmount) * newFinanceAmount).toFixed() : 0;
        thisVar.phreferrerIncentiveValue = checkInput(thisVar.phreferrerIncentiveValue) ? ((parseInt(thisVar.phreferrerIncentiveValue,10) / oldFinanceAmount) * newFinanceAmount).toFixed() : 0;

        thisVar.dsaPayValue = checkInput(thisVar.dsaPayValue) ? ((parseInt(thisVar.dsaPayValue,10) / oldFinanceAmount) * newFinanceAmount).toFixed() : 0;
    }
}

//CISP-4785 Added validations on the selected scheme record
export async function validateSelectedScheme(thisVar) {
    let selectedScheme = thisVar.schemeOptionsValue ? thisVar.schemeOptionsValue.toLowerCase() : null;
    let isSelectedSchemeValid = true;
    if (thisVar.productTypeDetail.toLowerCase() === 'Passenger Vehicles'.toLowerCase()) {
        if (thisVar.manufacturerCodeList) {//CISP-20395
            const manufacturerCodes = thisVar.manufacturerCodeList.map(item => item.Manufacturer__r.Manufacturer_code__c);
            console.log('list of manufacturer Codes '+manufacturerCodes);
            // If both 'U00' and 'U01' are present then no error
            if (manufacturerCodes.includes('U00') && manufacturerCodes.includes('U01')) {
                console.log('Contains both U00 and U01');
            }
            // If 'U01' is present then give error on selecting 'NO Scheme'
            else if (manufacturerCodes.includes('U01') && selectedScheme != null && selectedScheme.includes('no scheme')) {
                console.log('contains only U01');
                isSelectedSchemeValid = false;
                thisVar.toastMsg(invalidScheme);
            }
            // If 'U00' is present then give error on selecting other than 'NO Scheme'
            else if (manufacturerCodes.includes('U00') && selectedScheme != null && !selectedScheme.includes('no scheme')) {
                console.log('contains only U00');
                isSelectedSchemeValid = false;
                thisVar.toastMsg(invalidScheme);
            }
            // If none is present then give error on selecting other than 'NO Scheme'
            else if (!manufacturerCodes.includes('U00') && !manufacturerCodes.includes('U01') && !selectedScheme.includes('no scheme')) {
                console.log('Neither U00 nor U01 is present');
                isSelectedSchemeValid = false;
                thisVar.toastMsg(invalidScheme);
            }
        }
         //CISP-20647
         else{
            console.log('list thisVar.manufacturerCodeList in else part');
            if(selectedScheme != null && !selectedScheme.includes('no scheme')){
                isSelectedSchemeValid = false;
                thisVar.toastMsg(invalidScheme);
            }
        }//CISP-20647
    }
    if(selectedScheme && selectedScheme.includes('tw no scheme nc')) {
        if(!thisVar.isNewCustomer && thisVar.isExistingCustomer == true) {
            isSelectedSchemeValid = false;
            thisVar.showToast("Error", 'CMU has marked the Customer Code as existing and valid. Hence, please change the Scheme', 'error');
        }
    }
    if(thisVar.currentStage === 'Credit Processing' && thisVar.isCustomerDedupeSubmit != true && thisVar.nonD2cDsaTW) {
        isSelectedSchemeValid = false;
        thisVar.showToast("Error", 'Information: Dedupe validation by CMU is in progress. Hence you cannot proceed', 'error');
    }
    return isSelectedSchemeValid;
}
    //CISP-8307 end

    // SFTRAC-54 starts
    export async function handleCheckEligibilityButtonHelper(thisVar){
        if(thisVar.isTractor && thisVar.showFundingInfo == true && thisVar.loanAmtForCal != 0){
            if((parseFloat(thisVar.fundingForBody) + parseFloat(thisVar.fundingForChassis)) != parseFloat(thisVar.loanAmtForCal)){
                thisVar.toastMsg('Please change the funding body or chassis amount to equal of Finance amount = '+ thisVar.loanAmtForCal);
                return null;
            }
        }//SFTRAC-1602
        //SFTRAC-1795 start
        if(thisVar.installmentTypeValue.toUpperCase() != thisVar.installMentType?.toUpperCase() && thisVar.isTractor){
            const evt = new ShowToastEvent({
                title: 'Warning',
                message: 'You have changed the Installment Type of the asset as compared to FI data. Please inform the customer regarding the change',
                variant: 'warning',mode: 'dismissible'});
                thisVar.dispatchEvent(evt);
        }//SFTRAC-1795 end
        if (thisVar.isTractor &&  thisVar.vehicleTypeDetail == 'New'  && thisVar.vehicleDelivered == 'Yes') {
            let result1 = await checkAssetVerificationStatusFinalTerm({
                'loanApplicationId': thisVar.recordid, vehicleId : thisVar.vehicleId
            });    
            result1 = result1.trim();
                if (result1 == 'Asset Verification Completed') {
                    thisVar.finalTermId = await getFinalTermRecord({ 'loanApplicationId': thisVar.recordid, vehicleId: thisVar.vehicleId });
                    thisVar.disabledCheckEligibility = true; 
                    await handleSubmit(thisVar);
                    setTimeout(() => { thisVar.disabledCheckEligibility = false; }, 3000);
                } else {
                    thisVar.toastMsg('Asset Verification is not completed. Please complete it before checking eligibility.');
                }
        } else {
            thisVar.disabledCheckEligibility=true;thisVar.finalTermId = await getFinalTermRecord({'loanApplicationId':thisVar.recordid, vehicleId: thisVar.vehicleId});await handleSubmit(thisVar);setTimeout(() => {thisVar.disabledCheckEligibility=false;}, 6000);
        }
    } // SFTRAC-54 end
export async function handleOptionsRelatedListsHelper(ref){
    let referredbyOptions = [
        { label: 'Bank branch referral', value: 'Bank branch referral' },
        { label: 'CFD ref.', value: 'CFD ref.' },
        { label: 'Direct sourcing', value: 'Direct sourcing' },
        { label: 'Existing Customer Referral', value: 'Existing Customer Referral' }];
    let refOption = [
        { label: 'Ref. ref.', value: 'Ref. ref.' },
        { label: 'Source Dealer', value: 'Source Dealer' },
        { label: 'Walk in Customer', value: 'Walk in Customer' }
    ];
    let tailOptions = [ 
        { label: 'Source Dealer', value: 'Source Dealer' },
        { label: 'Walk in Customer', value: 'Walk in Customer' }
    ];

    if (ref.forTwoWheeler && !ref.leadSource) {
        referredbyOptions.push.apply(referredbyOptions, tailOptions);
        ref.hideReferrerFields = true;
    } else {
        referredbyOptions.push.apply(referredbyOptions, refOption);
        ref.hideReferrerFields = false;
    }
    ref.referredbyOption = referredbyOptions;
    const ecsOptions = [
        { label: 'Bank', value: 'Bank' },
        { label: 'Customer', value: 'Customer' }
    ];
    ref.ecsOption = ecsOptions;
    const installmentTypes = [
        { label: 'Equated', value: 'Equated' },
        { label: 'Structured', value: 'Structured' }
    ];
    ref.installmentTypeOption = installmentTypes;
    const installmentFrequencies = [
        { label: 'Monthly', value: 'Monthly' },
        //{ label: 'bi-monthly', value: 'bi-monthly' },
        { label: 'Quarterly', value: 'Quarterly' },
        { label: 'Half yearly', value: 'Half yearly' },
        //{ label: 'Structured', value: 'Structured' }
    ];
    ref.installmentFrequency = installmentFrequencies;
    const dealerExpReimburseTypeList = [
        { label: 'Separate', value: 'Separate' }
    ];
    ref.dealerExpReimburseTypeOption = dealerExpReimburseTypeList;
    ref.mfrExpReimburseTypeOption = dealerExpReimburseTypeList;
    ref.delinquencyFundTypeOption = dealerExpReimburseTypeList;
    // sftrac-84
    const monitoriumDaysList = [];
    if (ref.isTractor) {
    } else {
        monitoriumDaysList.push(
            { label: '0', value: '0' },
            { label: '30', value: '30' }
        );
        ref.monitoriumDaysOption = monitoriumDaysList;
    }
}

export async function handleSubmit(ref) {
    try {
        let schemeInput=ref.template.querySelector('.scheme');
        let ServiceChargesInput=ref.template.querySelector('lightning-input[data-id=serChar]');
        let documentationChargesInput=ref.template.querySelector('lightning-input[data-id=DocChar]');
        let rtoPrefixInput=ref.template.querySelector('lightning-input[data-id=rtoPre]');
        let stampingChargesInput=ref.template.querySelector('lightning-input[data-id=stamChar]');
        let dueDateShiftChargesInput=ref.template.querySelector('lightning-input[data-id=dueDateChar]');
        let ecsVerificationChargesInput=ref.template.querySelector('.ecsVerifi');
        let verificationChargesInput=ref.template.querySelector('lightning-input[data-id=veriChar]');
        let delinquencyFundInput=ref.template.querySelector('lightning-input[data-id=deliFund]');
        let delinquencyFundTypeInput=ref.template.querySelector('.deliFundType');
        let tradeCertificateInput=ref.template.querySelector('lightning-input[data-id=tradeCerti]');
        let dealerExpReimburseAmountInput=ref.template.querySelector('lightning-input[data-id=dealExpReimburseAmt]');
        let dealerExpReimbursePercentageInput=ref.template.querySelector('lightning-input[data-id=dealExpReimburseper]');
        let dealerExpReimburseTypeInput=ref.template.querySelector('.dealerExpReimType');
        let dealerIncentiveAmountMainInput=ref.template.querySelector('lightning-input[data-id=dealInceAmtMain]');
        let dealerIncentiveAmountSubInput=ref.template.querySelector('lightning-input[data-id=dealInceAmtSub]');
        let dealerDiscountToCustomerInput=ref.template.querySelector('lightning-input[data-id=dealDiscCust]');
        let giftThroughDealerAmountInput=ref.template.querySelector('lightning-input[data-id=giftDealAmt]');
        let dsmIncentiveOneInput=ref.template.querySelector('lightning-input[data-id=dsmIncent]');
        let dsmNameOneInput=ref.template.querySelector('.dsmName1');
        let dsmIncentiveTwoInput=ref.template.querySelector('lightning-input[data-id=dsmInce]');
        let dsmNameTwoInput=ref.template.querySelector('.dsmName2');
        let nonDlrDsmIncentiveOneInput=ref.template.querySelector('lightning-input[data-id=nondlrDsmIncen1]');
        let nonDlrDsmNameOneInput=ref.template.querySelector('.nondlrdsmName1');
        let nonDlrDsmIncentiveTwoInput=ref.template.querySelector('lightning-input[data-id=dlrdsmIncen2]');
        let nonDlrDsmNameTwoInput=ref.template.querySelector('.dlrdsmName2');
        let referredByInput=ref.template.querySelector('.refby');
        let referrerIncentiveInput=ref.template.querySelector('lightning-input[data-id=refInc]');
        let referrerNameInput=ref.template.querySelector('lightning-input[data-id=refName]');
        let referrerNameComboInput=ref.template.querySelector('.reffName');
        let branchInput=ref.template.querySelector('lightning-input[data-id=branch]');
        let empNoInput=ref.template.querySelector('lightning-input[data-id=empNo]');
        let empNameInput=ref.template.querySelector('lightning-input[data-id=empName]');
        let dealNoInput=ref.template.querySelector('lightning-input[data-id=dealNo]');
        let provisionalChannelCostInput=ref.template.querySelector('lightning-input[data-id=proChnCost]');
        let dsaPayInput=ref.template.querySelector('lightning-input[data-id=dsapay]');
        let rcuRetentionChargesInput=ref.template.querySelector('lightning-input[data-id=rcuRet]');
        let repaymentModeInput=ref.template.querySelector('.repaymo');
        let installmentTypeInput=ref.template.querySelector('.Install');
        let freqInput=ref.template.querySelector('.freqInst');
        let monitoriumDaysInput=ref.template.querySelector('.monDay');
        let mfrExpReimAmtInput=ref.template.querySelector('lightning-input[data-id=mfrExpReimAmt]');
        let mfrExpReimperInput=ref.template.querySelector('lightning-input[data-id=mfrExpReimper]');
        let mfrExpReiTypeInput=ref.template.querySelector('lightning-combobox[data-id=mfrExpReiType]');
        let firstEMIDateInput=ref.template.querySelector('.firstEMIDate');

        if(ref.forTwoWheeler===true){referrerNameInput?.reportValidity();verificationChargesInput?.reportValidity();ecsVerificationChargesInput?.reportValidity();delinquencyFundTypeInput?.reportValidity();delinquencyFundInput?.reportValidity();dealerExpReimburseAmountInput?.reportValidity();dealerExpReimbursePercentageInput?.reportValidity();dealerExpReimburseTypeInput?.reportValidity();dealerIncentiveAmountSubInput?.reportValidity();nonDlrDsmIncentiveOneInput?.reportValidity();nonDlrDsmNameOneInput?.reportValidity();nonDlrDsmIncentiveTwoInput?.reportValidity();nonDlrDsmNameTwoInput?.reportValidity();if(rcuRetentionChargesInput){rcuRetentionChargesInput?.reportValidity();}}else if(ref.isNotTractor){referrerNameComboInput?.reportValidity();mfrExpReimAmtInput?.reportValidity() ; mfrExpReimperInput?.reportValidity(); mfrExpReiTypeInput?.reportValidity();if(ref.leadSource != 'D2C'){firstEMIDateInput?.reportValidity();}}
        /*CISP-3359*/ if(ref.forTwoWheeler===true && ref.leadSource !== 'D2C' && ref.leadSource !== 'Hero'){/*CISP-4785 Start*/if(ref.nonD2cDsaTW){if((parseInt(ref.serviceChargesValue)+parseInt(ref.documentationChargesValue))<parseInt(serviceChargeAndDocChargeSum,10)){ref.showToast("warning",'Sum of Both Service Charge and Documentation charge should not be less than '+serviceChargeAndDocChargeSum,'warning');ref.disabledDocumentationCharges=false;ref.disabledServiceCharges=false;ref.minchargeVal=true;}else{ref.minchargeVal=false;}}else{/*CISP-4785 End*/if((parseInt(ref.serviceChargesValue)+parseInt(ref.documentationChargesValue))<1400 && ref.leadSource != 'Hero'){ref.showToast("warning",'Sum of Both Service Charge and Documentation charge should not be less than 1400','warning');ref.disabledDocumentationCharges=false;ref.disabledServiceCharges=false;ref.minchargeVal=true;}else{ref.minchargeVal=false;}}}
        schemeInput?.reportValidity();ServiceChargesInput?.reportValidity();
        documentationChargesInput.reportValidity();if(ref.isNotTractor){rtoPrefixInput?.reportValidity();}
        stampingChargesInput?.reportValidity();dueDateShiftChargesInput?.reportValidity();tradeCertificateInput?.reportValidity();
        repaymentModeInput?.reportValidity();installmentTypeInput?.reportValidity();monitoriumDaysInput?.reportValidity();if(ref.isTractor){freqInput?.reportValidity();}
        if(ref.isNotRefianceTractor){if(dsaPayInput){dsaPayInput?.reportValidity();}dealerIncentiveAmountMainInput?.reportValidity();giftThroughDealerAmountInput?.reportValidity();dsmNameOneInput?.reportValidity();dsmIncentiveOneInput?.reportValidity();dsmNameTwoInput?.reportValidity();dsmIncentiveTwoInput?.reportValidity();referredByInput?.reportValidity();referrerIncentiveInput?.reportValidity();branchInput?.reportValidity();empNoInput?.reportValidity();empNameInput?.reportValidity();dealNoInput?.reportValidity();if(!ref.forTwoWheeler){provisionalChannelCostInput?.reportValidity();}dealerDiscountToCustomerInput?.reportValidity();}
        let checkPayOut = false;
        if(ref.payoutCapValue && ref.forTwoWheeler===true ){//CISP-2398 //CISP-3790V1
           let payoutVar = payoutCap(ref)//CISP-4785 Added this in parameter
            if(payoutVar){ checkPayOut = true;
                /*CISP-4785*/if(ref.nonD2cDsaTW){ref.showToast("Error", 'Total pay-out percentage exceeds the maximum permissible limit. Please modify the pay-outs', 'error');}else{ref.showToast("warning", 'Payout cap of '+ String(ref.payoutCapValue) +'% exceeded. Please modify the Payout fields', 'warning');}
                ref.disabledDealerIncentiveAmountMainDealer=false;ref.disabledDealerIncentiveAmountSubDealer=ref.isSubDealer?false:true;ref.disabledGiftThroughDealerAmount=false;ref.disabledDsmIncentiveOne=ref.dsmNameOneValue?false:true;ref.disabledsmOnePercentage=ref.dsmNameOneValue?false:true;ref.disabledDsmIncentiveTwo=ref.dsmNameTwoValue?false:true;ref.disableDsmTwoPercentage=ref.dsmNameTwoValue?false:true;}}/*CISP-13993*/ 
                if (ref.payoutMax && ref.isTractor === true && ref.isNotRefianceTractor) {
                    if (payoutCap(ref)) {
                        checkPayOut = true;
                        ref.showToast("warning", `Payout cap of ${ref.payoutMax}% exceeded. Please modify the Payout fields`, 'warning');
                        ref.disabledDealerIncentiveAmountMainDealer = false;
                        ref.productTypeDetail == 'Passenger Vehicles' ? ref.vehicleSubCategoryDetail == 'UPD' ? ref.disabledDealerDiscounttoCustomer = true : ref.disabledDealerDiscounttoCustomer = false : ref.disabledDealerDiscounttoCustomer = false;
                        ref.disabledGiftThroughDealerAmount = false;
                        ref.disabledDsmIncentiveOne = false;
                        ref.disabledDsmIncentiveTwo = false;
                        ref.disabledReferrerIncentive = false;
                    }
                }
                if (ref.payinMax && ref.isTractor === true) {
                    if (payinCap(ref)) {
                        checkPayOut = true;
                        ref.showToast("warning", `Payin cap of ${ref.payinMax}% exceeded. Please modify the Payin fields`, 'warning');
                        ref.disabledServiceCharges = false;
                        ref.disabledDocumentationCharges = false;
                        ref.disableStampingCharges = false;
                        ref.disabledueDateShiftCharges = false;
                        ref.disabledecsVerificationCharge = false;
                    }
                }        
                if(ref.flagToCheckInValidScheme===false){ref.isSubmit=true;if(ref.leadSource!='OLA' && ref.isNotTractor){ref.checkServiceCharges();ref.checkDocumentationCharges();}//OLA-32
                if(!checkPayOut && !ref.serVal && !ref.docVal){
                if(ref.forTwoWheeler===true && (ref.vehicleTypeDetail?.toLowerCase()!= 'Refinance'.toLowerCase() && ref.isTWRefinance == false)  && (ref.monitoriumDaysValue !== '0' || (ref.monitoriumDaysValue=== '0' && ref.advanceEmiValue === true)) && (schemeInput?.validity?.valid===true || ref.fromVfPage) && ServiceChargesInput.validity.valid===true && documentationChargesInput.validity.valid===true && stampingChargesInput.validity.valid===true && dueDateShiftChargesInput.validity.valid===true && ecsVerificationChargesInput?.validity?.valid===true && verificationChargesInput?.validity?.valid===true && delinquencyFundInput?.validity?.valid===true && delinquencyFundTypeInput?.validity?.valid===true && rtoPrefixInput?.validity?.valid===true && tradeCertificateInput?.validity?.valid===true && dealerExpReimburseAmountInput?.validity?.valid===true && dealerExpReimbursePercentageInput?.validity?.valid===true && dealerExpReimburseTypeInput?.validity?.valid===true &&
                dealerIncentiveAmountMainInput?.validity?.valid===true && dealerIncentiveAmountSubInput?.validity?.valid===true && dealerDiscountToCustomerInput?.validity?.valid===true && giftThroughDealerAmountInput?.validity?.valid===true && dsmIncentiveOneInput?.validity?.valid===true && dsmNameOneInput?.validity?.valid===true && dsmIncentiveTwoInput?.validity?.valid===true && dsmNameTwoInput?.validity?.valid===true && nonDlrDsmIncentiveOneInput?.validity?.valid===true && nonDlrDsmNameOneInput?.validity?.valid===true && nonDlrDsmIncentiveTwoInput?.validity?.valid===true && nonDlrDsmNameTwoInput?.validity?.valid===true && referredByInput?.validity?.valid===true && (referrerIncentiveInput?.validity?.valid===true || ref.hideReferrerFields) && (referrerNameInput?.validity?.valid===true || ref.hideReferrerFields) && repaymentModeInput?.validity?.valid===true && installmentTypeInput?.validity?.valid===true && monitoriumDaysInput?.validity?.valid===true && ((ref.leadSource == 'D2C') || (ref.leadSource != 'D2C' && firstEMIDateInput?.validity?.valid===true))){
                if(ref.vehicleTypeDetail?.toLowerCase()==='used'.toLowerCase() || ref.vehicleTypeDetail?.toLowerCase()==='Refinance'.toLowerCase()){//CISP-2386
                    if(dsaPayInput.validity.valid===true && rcuRetentionChargesInput.validity.valid===true){if(!ref.minchargeVal){ref.handleCreateFinalTermRecord();}}}else{if(!ref.minchargeVal){ref.handleCreateFinalTermRecord();}}
            }else if(ref.forTwoWheeler===true && (ref.vehicleTypeDetail?.toLowerCase()== 'Refinance'.toLowerCase() && ref.isTWRefinance == true) && (ref.monitoriumDaysValue !== '0' || (ref.monitoriumDaysValue=== '0' && ref.advanceEmiValue === true)) && (schemeInput?.validity?.valid===true || ref.fromVfPage) && ServiceChargesInput.validity.valid===true && documentationChargesInput.validity.valid===true && stampingChargesInput.validity.valid===true && dueDateShiftChargesInput.validity.valid===true  && rtoPrefixInput.validity.valid===true && tradeCertificateInput.validity.valid===true 
            && repaymentModeInput?.validity.valid===true && monitoriumDaysInput?.validity.valid===true ){
            if(!ref.minchargeVal){ref.handleCreateFinalTermRecord();}
            }
            else if(ref.forTwoWheeler===false && ref.isNotTractor && (ref.monitoriumDaysValue !== '0' || (ref.monitoriumDaysValue=== '0' && ref.advanceEmiValue === true)) && schemeInput.validity.valid===true && ServiceChargesInput.validity.valid===true && documentationChargesInput.validity.valid===true && dealerIncentiveAmountMainInput.validity.valid===true && giftThroughDealerAmountInput.validity.valid===true && dealerDiscountToCustomerInput.validity.valid===true &&
            stampingChargesInput.validity.valid===true && dueDateShiftChargesInput.validity.valid===true && rtoPrefixInput.validity.valid===true && tradeCertificateInput.validity.valid===true && dsmIncentiveOneInput.validity.valid===true &&
            dsmNameOneInput.validity.valid===true && dsmIncentiveTwoInput.validity.valid===true && dsmNameTwoInput.validity.valid===true && referredByInput.validity.valid===true &&
            referrerIncentiveInput.validity.valid===true && referrerNameComboInput.validity.valid===true && provisionalChannelCostInput.validity.valid===true && repaymentModeInput.validity.valid===true &&
            installmentTypeInput.validity.valid===true && monitoriumDaysInput.validity.valid===true && mfrExpReimAmtInput.validity.valid===true && mfrExpReimperInput.validity.valid===true && mfrExpReiTypeInput.validity.valid===true && ((ref.leadSource == 'D2C') || (ref.leadSource != 'D2C' && firstEMIDateInput.validity.valid===true))){
            if(ref.vehicleTypeDetail?.toLowerCase()==='used'.toLowerCase() || ref.vehicleTypeDetail?.toLowerCase()==='Refinance'.toLowerCase()){//CISP-2386
                if(dsaPayInput.validity.valid===true){//CISP-3359
                if(!ref.minchargeVal){ ref.handleCreateFinalTermRecord();}}}else{if(!ref.minchargeVal){ref.handleCreateFinalTermRecord();}}//else tractor added //sftrac-84
        }else if(ref.isTractor && ((ref.monitoriumDaysValue && ref.monitoriumDaysValue !== '0') || ((!ref.monitoriumDaysValue || ref.monitoriumDaysValue === '0') && ref.advanceEmiValue === true)) && schemeInput.validity.valid === true && ServiceChargesInput.validity.valid === true && documentationChargesInput.validity.valid === true &&
        stampingChargesInput.validity.valid === true && dueDateShiftChargesInput.validity.valid === true && rtoPrefixInput.validity.valid === true && tradeCertificateInput.validity.valid === true && repaymentModeInput.validity.valid === true &&installmentTypeInput.validity.valid === true && monitoriumDaysInput.validity.valid === true && freqInput.validity.valid === true && ((ref.isRefinance) || (ref.isTopUpLoan) || (!ref.isRefinance && dealerIncentiveAmountMainInput.validity.valid === true && giftThroughDealerAmountInput.validity.valid === true  && dsmIncentiveOneInput.validity.valid === true && dsmNameOneInput.validity.valid === true && dsmIncentiveTwoInput.validity.valid === true && dsmNameTwoInput.validity.valid === true && referredByInput.validity.valid === true && referrerIncentiveInput.validity.valid === true && referrerNameComboInput.validity.valid === true && provisionalChannelCostInput.validity.valid === true && dealerDiscountToCustomerInput.validity.valid === true))){  
            if (!ref.minchargeVal) {
                ref.handleCreateFinalTermRecord();
            }
        }else if((ref.monitoriumDaysValue === '0' || !ref.monitoriumDaysValue) && ref.isTractor){
            let advanceEMiInput=ref.template.querySelector('lightning-input[data-id=advanceEMIid]');advanceEMiInput?.setCustomValidity(""); 
            let monitoriumDays=ref.template.querySelector('lightning-combobox[data-id=monitoriumDaysID]');monitoriumDays?.setCustomValidity(""); 
            if(!advanceEMiInput.checked){advanceEMiInput.setCustomValidity('Please Select Advance Emi');if(monitoriumDays){monitoriumDays.setCustomValidity('Please Select Moratorium Days.');}}advanceEMiInput.reportValidity();monitoriumDays.reportValidity();ref.toastMsg(ref.labelCustom.Mandatory_fields_are_not_entered);
        }else{if(ref.monitoriumDaysValue==='0'){let advanceEMiInput=ref.template.querySelector('lightning-input[data-id=advanceEMIid]'); if(!advanceEMiInput.checked){advanceEMiInput.setCustomValidity("");advanceEMiInput.setCustomValidity('Please Select Advance Emi');advanceEMiInput.reportValidity();}}else{ref.toastMsg(ref.labelCustom.Mandatory_fields_are_not_entered);}ref.flagToCheckValidity=false;}}
        }else{ref.toastMsg(invalidScheme);}}catch(error){}
}

export async function handleSave(ref) {
    let referrerName='';
    try{
    if(ref.forTwoWheeler===false && ref.referrerNameValue && ref.referrerNameOptions.length>0){//DSA changes
        if(ref.dsaReferrer===true){referrerName=ref.DSAName;}else{referrerName =await ref.referrerNameOptions.find(opt => opt.value === ref.referrerNameValue).label;}}
    ref.flagToCheckValidity=true;
    const FinalTermFields={};
    FinalTermFields[final_ID_FIELD.fieldApiName]=ref.finalTermId;
    FinalTermFields[Scheme_Bank_offers.fieldApiName]=ref.schemeOptionsValue;
    FinalTermFields[RC_limit_enabled_DSA.fieldApiName] = ref.isRcLimitChecked;//CISP-8762
    if(checkInput(ref.serviceChargesValue)){FinalTermFields[Service_charges.fieldApiName]=ref.serviceChargesValue.toString();}
    if(checkInput(ref.documentationChargesValue)){FinalTermFields[Documentation_charges.fieldApiName]=ref.documentationChargesValue.toString();}
    if(checkInput(ref.stampingChargesValue)){let stamChargTemp =   ref.stampingChargesValue.toString();FinalTermFields[Stamping_charges.fieldApiName]= stamChargTemp == 'NaN' ? '' : stamChargTemp;}
    if(checkInput(ref.dueDateShiftChargesValue)){FinalTermFields[Due_date_shift_charges.fieldApiName]=String(ref.dueDateShiftChargesValue);}//Start CISP-126
    if(checkInput(ref.ecsValue)){FinalTermFields[ECS_verification_by.fieldApiName]=ref.ecsValue;}
    if(checkInput(ref.verificationChargesValue)){FinalTermFields[Verification_charges.fieldApiName]=String(ref.verificationChargesValue);}
    if(checkInput(ref.delinquencyFundValue)){FinalTermFields[Delinquency_Fund.fieldApiName]=String(ref.delinquencyFundValue);}
    if(checkInput(ref.delinquencyFundTypeValue)){FinalTermFields[Deliquency_Fund_type.fieldApiName]=ref.delinquencyFundTypeValue;}
    if(checkInput(ref.rtoPrefixValue)){FinalTermFields[RTO_prefix.fieldApiName]=ref.rtoPrefixValue;}
    if(checkInput(ref.tradeCertificateValue)){FinalTermFields[Trade_certificate.fieldApiName]=ref.tradeCertificateValue.toString();}
    if(checkInput(ref.dealerExpReimburseAmountValue)){FinalTermFields[Dlr_Exp_Reimburse_Amt.fieldApiName]=ref.dealerExpReimburseAmountValue.toString();}
    if(checkInput(ref.dealerExpReimburseTypeValue)){FinalTermFields[Dlr_Exp_Reimburse_Type.fieldApiName]=ref.dealerExpReimburseTypeValue;}
    if(checkInput(ref.dealerIncentiveAmountMainValue)){FinalTermFields[Dealer_incentive_amount_main_dealer.fieldApiName]=String(ref.dealerIncentiveAmountMainValue);}
    if(checkInput(ref.dealerIncentiveAmountSubValue)){FinalTermFields[Dealer_incentive_amount_sub_dealer.fieldApiName]=String(ref.dealerIncentiveAmountSubValue);}
    if(checkInput(ref.dealerDiscounttoCustomerValue)){FinalTermFields[Dealer_Disc_to_Customer.fieldApiName]=String(ref.dealerDiscounttoCustomerValue);}
    if(checkInput(ref.giftThroughDealerAmountValue)){FinalTermFields[Gift_through_dealer_amount.fieldApiName]=String(ref.giftThroughDealerAmountValue);}
    if(checkInput(ref.manufacturerIncentiveValue)){FinalTermFields[Mfr_incentive.fieldApiName]=ref.manufacturerIncentiveValue.toString();}
    if(checkInput(ref.dsmIncentiveOneValue)){FinalTermFields[DSM_IncentiveOne.fieldApiName]=ref.dsmIncentiveOneValue.toString();}
    if(checkInput(ref.dsmNameOneValue)){FinalTermFields[DSM_NameOne.fieldApiName]=ref.dsmNameOneValue;}
    if(checkInput(ref.dsmIncentiveTwoValue)){FinalTermFields[DSM_IncentiveTwo.fieldApiName]=ref.dsmIncentiveTwoValue.toString();}
    if(checkInput(ref.dsmNameTwoValue)){FinalTermFields[DSM_NameTwo.fieldApiName]=ref.dsmNameTwoValue;}
    if(checkInput(ref.nonDlrDsmIncentiveOneValue)){FinalTermFields[Non_Dlr_DSM_IncentiveOne.fieldApiName]=ref.nonDlrDsmIncentiveOneValue.toString();}
    if(checkInput(ref.nonDlrDsmNameOneValue)){FinalTermFields[Non_Dlr_DSM_NameOne.fieldApiName]=ref.nonDlrDsmNameOneValue;}
    if(checkInput(ref.nonDlrDsmIncentiveTwoValue)){FinalTermFields[Non_Dlr_DSM_IncentiveTwo.fieldApiName]=ref.nonDlrDsmIncentiveTwoValue.toString();}
    if(checkInput(ref.nonDlrDsmNameTwoValue)){FinalTermFields[Non_Dlr_DSM_NameTwo.fieldApiName]=ref.nonDlrDsmNameTwoValue;}
    if(checkInput(ref.referredbyValue)){FinalTermFields[Refered_By.fieldApiName]=ref.referredbyValue;}
    if(checkInput(ref.dealerExpReimbursePercentageValue)){FinalTermFields[Dlr_Exp_Reimbursement_percent.fieldApiName]=String(ref.dealerExpReimbursePercentageValue);}
    if(checkInput(ref.referrerIncentiveValue)){FinalTermFields[Rreferrer_Incentive.fieldApiName]=String(ref.referrerIncentiveValue);}
    if(ref.forTwoWheeler===true && checkInput(ref.referrerNameValue)){FinalTermFields[Referrer_Name.fieldApiName]=ref.referrerNameValue;}
    if(checkInput(ref.branchValue)){FinalTermFields[Branch.fieldApiName]=ref.branchValue.toString();}
    if(checkInput(ref.empNoValue)){FinalTermFields[Emp_No.fieldApiName]=ref.empNoValue.toString();}
    if(checkInput(ref.empNameValue)){FinalTermFields[Emp_Name.fieldApiName]=ref.empNameValue.toString();}
    if(checkInput(ref.dealNoValue)){FinalTermFields[Deal_No.fieldApiName]=ref.dealNoValue;}
    if(checkInput(ref.provisionalChannelCostValue)){FinalTermFields[Provisional_Channel_Cost.fieldApiName]=ref.provisionalChannelCostValue.toString();}
    if(checkInput(ref.dsaPayValue)){FinalTermFields[DSA_pay.fieldApiName]=String(ref.dsaPayValue);}
    if(checkInput(ref.rcuRetentionChargesValue)){FinalTermFields[RCU_Retention_Charges.fieldApiName]=String(ref.rcuRetentionChargesValue);}
    if(checkInput(ref.firstemidate)){FinalTermFields[FIRST_EMI_DATE.fieldApiName]=ref.firstemidate;}
    if(checkInput(ref.secondemidate)){FinalTermFields[SECOND_EMI_DATE.fieldApiName]=ref.secondemidate;}
    if(ref.fromVfPage){FinalTermFields[IsPayOutSubmitRequired.fieldApiName]=false;}
    FinalTermFields[Repayment_mode.fieldApiName]=ref.repaymentModeValue;// End CISP-126
    FinalTermFields[Advance_EMI.fieldApiName]=ref.advanceEMi;
    if(checkInput(ref.monitoriumDaysValue)){FinalTermFields[Holiday_period.fieldApiName]=ref.monitoriumDaysValue.toString();}
    else { FinalTermFields[Holiday_period.fieldApiName]='0'; }
    FinalTermFields[Installment_Type.fieldApiName]=ref.installmentTypeValue;if(ref.productTypeDetail.toLowerCase() === 'Two Wheeler'.toLowerCase() || ref.isTractor) // Added Tractor check to assign schemeId in final term
    {FinalTermFields[schemeId.fieldApiName]=ref.ids;}
    if(ref.isTractor){
        if (checkInput(ref.oppOwnerId)) {FinalTermFields[BUSINESS_EXECUTIVE.fieldApiName] = String(ref.oppOwnerId);}FinalTermFields[VehicleDetail.fieldApiName]=ref.vehicleId;
        FinalTermFields[Loan_Deal_Date.fieldApiName] = ref.loanDealDate;
        FinalTermFields[X1st_EMI_Date.fieldApiName] = ref.firstEMIDate;
        FinalTermFields[X2nd_EMI_Date.fieldApiName] = ref.secondEMIDate;
        FinalTermFields[Change_Pay_IN_OUT.fieldApiName] = false;
        if(ref.requiredCrmIRR && ref.customerType == 'Non-Individual' && ref.currentStageName == 'Final Terms'){
            FinalTermFields[CRM_IRR.fieldApiName] = ref.requiredCrmIRR;
        }
        FinalTermFields[InstallmentFrequencyType.fieldApiName]=ref.installmentFrequencyValue;if(ref.fundingForBody){FinalTermFields[Funding_For_Body.fieldApiName]=ref.fundingForBody;}if(ref.fundingForChassis){FinalTermFields[Funding_For_Chassis.fieldApiName]=ref.fundingForChassis;}
    }
    let result = await ref.updateRecordDetails(FinalTermFields);

    if(ref.isTractor){let response = await isAllFICasesSubmitted({'loanApplicationId': ref.recordid});if(!response){ref.showToast("warning", 'FI cases approval Pending!', 'warning');ref.isSpinnerMoving = false;return;}}
    
    let checkAgreementAmount = await validateAgreementAmount({finalTermId : ref.finalTermId});
    if(ref.isTractor && result && (ref.vehicleTypeDetail.toLowerCase() === 'used'.toLowerCase() || ref.vehicleTypeDetail.toLowerCase() === 'Refinance'.toLowerCase()) && checkAgreementAmount && ref.isNotTractor){
        ref.isSpinnerMoving = false;
        ref.showToast('Error', 'Agreement Amount should not be greater than min of - RSV, Insurance declared value, Valuation price', 'Error');
        return;
    }
    else if(result){ref.showToast(ref.labelCustom.SuccessMessage, ref.labelCustom.detailsSaved, 'success');if(ref.leadSource == 'D2C')ref.disableStampingCharges = true;if(ref.forTwoWheeler===false){await updateFinalTermBenCode({ loanApplicationId: ref.recordid, benCode:ref.referrerNameValue,bencodeName:referrerName }).then({});}
    if(ref.isTractor){ // SFTRAC-469 Handle Scheme Callout- Start
        ref.isSpinnerMoving = true;/*SFTRAC-792 isNavigateValue condition*/ if (ref.isNavigateValue == false) { const result = await handleSchemeValidationCallout(ref); if (result === 'ERROR') { ref.isSpinnerMoving = false; return; } }else{ ref.disabledCheckEligibility = true; const FinalTermFields = {}; FinalTermFields[final_ID_FIELD.fieldApiName]=ref.finalTermId; FinalTermFields[isNavigate.fieldApiName]=false;FinalTermFields[FinalTermsSubmitted.fieldApiName] = true; FinalTermFields[IS_CHANGE_PAYIN_PAYOUT_COMPLETED.fieldApiName] = true;let res = await ref.updateRecordDetails(FinalTermFields); if(res){ ref.moveToOfferScreen(); } ref.isSpinnerMoving = false; }}
    // SFTRAC-469 Handle Scheme Callout End
    if(!ref.fromVfPage && ref.isNotTractor){await ref.handleSubCheckEligibilityButton();//sftrac-84-start
    if(ref.isTractor && ref.currentStage !='Credit Processing' && ref.ltvEngineValue && ref.pricingEnginethresholdNetIrrValue && ref.isFiWaiverApiSuccessValue && ref.loanAmtValue){ref.disableEverything()};//sftrac-84-end
    if((ref.leadSource=='OLA' || ref.leadSource=='Hero') && ref.currentStage!==ref.label.CreditProcessing && ref.subStage!='Final Terms'){ref.moveToOfferScreen();}}else{ref.dispatchEvent(new CustomEvent('closemodal'));}/*CISP-4785 && Hero CISH-12*/ref.isSpinnerMoving=false;}else{ref.isSpinnerMoving=false;ref.showToast('Error', 'Data not Saved', 'Error');}}catch(error){}
}

 // SFTRAC-469 Handle Scheme Callout- Start
 export async function handleSchemeValidationCallout(ref) {
    await doSchemeValidationCallout({loanApplicationId: ref.recordid,vehicleId: ref.vehicleId}).then(response => {
        try {if(typeof response === 'string' && response.trim().startsWith('{'))
        {const parsedResponse = JSON.parse(response);
            const schemeValidationErrors = parsedResponse?.application?.loanDetails?.schemeValidationErrorMessage;if (schemeValidationErrors && schemeValidationErrors.length > 0) {const concatenatedErrors = schemeValidationErrors.join(', ');ref.showToast('Error', `Scheme is Not validated, Please change scheme:\n${concatenatedErrors}`, 'Error');return 'ERROR';} else {ref.showToast('Success', 'Scheme is validated', 'Success');ref.disabledCheckEligibility = true;if(ref.customerType == 'Non-Individual'){helper.handleTFOfferEngineCalloutHelper(ref);}else{handleCombinedBRECalloutHelper(ref);}}}if(response=='No'){if(ref.customerType == 'Non-Individual'){helper.handleTFOfferEngineCalloutHelper(ref);}else{handleCombinedBRECalloutHelper(ref);}}if(response =='Error'){ref.showToast('Error', `Error in Scheme Validation Callout`, 'Error');return 'ERROR';}}catch{ref.showToast('Warning', 'Scheme is Not validated, Please change scheme', 'warning');return 'ERROR';}}).catch(error=>{ref.showToast('Warning', error, 'warning');})}
//SFTRAC -121
export async function handleCombinedBRECalloutHelper(ref){
    try{
    let result = await combinedBRECallout({ loanAppId: ref.recordid, vehicleId: ref.vehicleId});ref.disabledCheckEligibility = true;//SFTRAC-1369
    const parsedResponse = JSON.parse(result);const combineBREResponse = parsedResponse?.application?.assetDetails?.assetLoanDetails;const viabilityResponse = parsedResponse?.application?.applicantDetails;let installRes = 0;
    let breNetIncome = 0;
    let cashFlowperAnnumValue = 0;
    viabilityResponse.forEach(item => {
        if (item.applicantType == 'Borrower') {
            installRes = item.applicantDecision?.installmentToIncomeRatio;
            breNetIncome = item.applicantDecision?.netIncome;
            cashFlowperAnnumValue = item.applicantDecision?.freeCashFlowPerAnnum;
        }
    });const fIscore = combineBREResponse ? combineBREResponse.fiScore : ''; let scoreBand = '';if (fIscore >= 175) {scoreBand = 'R1';} else if (fIscore >= 137 && fIscore < 175) {scoreBand = 'R2';} else if (fIscore >= 117 && fIscore < 137) {scoreBand = 'R3';} else if (fIscore >= 82 && fIscore < 117) {scoreBand = 'R4';} else {scoreBand = 'R5';}if ((breNetIncome != null && breNetIncome != 'NaN' && breNetIncome < 0) || (combineBREResponse !== undefined && combineBREResponse[0].riskBand != 'NaN' && combineBREResponse[0].riskBand == 'R5') || (installRes != null && installRes != 'NaN' && (installRes*100) > 90)) { const oppFields = {}; oppFields[OPP_ID_FIELD.fieldApiName] = ref.recordid; oppFields[Journey_Status.fieldApiName] = 'Stop'; oppFields[Journey_Stop_Reason.fieldApiName] = 'Eligibility norms not met as per FI, and Income Criteria';/*Change the Error label SFTRAC-1943*//*const recordInput = { fields: oppFields }; updateRecordDetails(recordInput).then(() => {});*/ ref.updateRecordDetails(oppFields); journeyStopScenarioFound(ref.recordid); ref.showToast('Error', 'Eligibility norms not met as per FI, and Income Criteria', 'Error'); } else { console.log("breNetIncome is Positive"); const FinalTermFields = {}; FinalTermFields[final_ID_FIELD.fieldApiName] = ref.finalTermId; FinalTermFields[LtvEngine_Ltv.fieldApiName] = combineBREResponse !== undefined && combineBREResponse[0].ltv != 'NaN' ? combineBREResponse[0].ltv : ''; FinalTermFields[PricingEngine_thresholdNetrr.fieldApiName] = combineBREResponse !== undefined && combineBREResponse[0].irr != 'NaN' ? combineBREResponse[0].irr : '';FinalTermFields[CRM_IRR.fieldApiName] = combineBREResponse !== undefined && combineBREResponse[0].irr != 'NaN' ?  combineBREResponse[0].irr : '';FinalTermFields[Net_Income.fieldApiName] = breNetIncome != null && breNetIncome != 'NaN' ? breNetIncome : ''; FinalTermFields[Fi_Score_Band.fieldApiName] = combineBREResponse !== undefined && combineBREResponse[0].riskBand != 'NaN' ? combineBREResponse[0].riskBand : ''; FinalTermFields[Fi_Score.fieldApiName] = combineBREResponse && combineBREResponse.length > 0 && combineBREResponse[0].fiScore != 'NaN' ? combineBREResponse[0].fiScore + '' : ''; FinalTermFields[Installment_To_Income_Ratio.fieldApiName] = installRes != null && installRes != 'NaN' ? installRes : '';FinalTermFields[CashFlowPerAnnum.fieldApiName]= cashFlowperAnnumValue != null && cashFlowperAnnumValue != 'NaN' ? cashFlowperAnnumValue : ''; let res = await ref.updateRecordDetails(FinalTermFields); if (res) { ref.showToast('Success', 'Combine BRE completed', 'Success'); if (combineBREResponse !== undefined) { if (combineBREResponse[0].ltv == null) { ref.showToast('Warning', 'LTV Engine response not present!', 'Warning'); } if (combineBREResponse[0].irr == null) { ref.showToast('Warning', 'Price Engine response not present!', 'Warning'); } } if (installRes == null) { ref.showToast('Warning', 'Viability information not present!', 'Warning'); } helper.handleTFOfferEngineCalloutHelper(ref); } }
    }catch(error){ref.retryPopUp=true;ref.isSpinnerMoving=false;ref.apiMessage='Please Kindly Retry Combined BRE Engine Api is Failed';ref.disabledCheckEligibility = true;//await helper.retryApiCall(ref); //Commented for SFTRAC-918 removed Retry count logic
    }
}
export async function getCustomerCodeStatusHelper(ref){
    await getCustomerCodeStatus({ loanAppId: ref.recordid }).then((response)=>{if(response && response.length > 0) {ref.isNewCustomer = response[0].IND_isNewCustomer__c;}});
}