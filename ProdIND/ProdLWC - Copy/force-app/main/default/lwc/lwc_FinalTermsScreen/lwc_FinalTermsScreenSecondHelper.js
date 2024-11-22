import tractorOfferEngineCallout from '@salesforce/apex/IntegrationEngine.tractorOfferEngine'; //SFTRAC-121
import saveInstallmentScheduleTractor from '@salesforce/apex/InstallmentScheduleController.saveInstallmentScheduleTractor';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import OfferengineMinLoanAmount from '@salesforce/schema/Final_Term__c.OfferengineMinLoanAmount__c'; //SFTRAC-126
import OfferengineMaxLoanAmount from '@salesforce/schema/Final_Term__c.OfferengineMaxLoanAmount__c'; //SFTRAC-126
import Loan_Amount from '@salesforce/schema/Final_Term__c.Loan_Amount__c'; //SFTRAC-126
import OfferengineMinTenure from '@salesforce/schema/Final_Term__c.OfferengineMinTenure__c'; //SFTRAC-126
import OfferengineMaxTenure from '@salesforce/schema/Final_Term__c.OfferengineMaxTenure__c'; //SFTRAC-126
import Tenure from '@salesforce/schema/Final_Term__c.Tenure__c'; //SFTRAC-126
import EMI_Amount from '@salesforce/schema/Final_Term__c.EMI_Amount__c'; //SFTRAC-126
import Required_CRM_IRR from '@salesforce/schema/Final_Term__c.Required_CRM_IRR__c'; //SFTRAC-126
import CRM_IRR from '@salesforce/schema/Final_Term__c.CRM_IRR__c'; //SFTRAC-126
import Net_IRR from '@salesforce/schema/Final_Term__c.Net_IRR__c'; //SFTRAC-126
import Gross_IRR from '@salesforce/schema/Final_Term__c.Gross_IRR__c'; //SFTRAC-126
import Bank_IRR from '@salesforce/schema/Final_Term__c.Bank_IRR__c'; //SFTRAC-126
import Offer_Agreement_Amount from '@salesforce/schema/Final_Term__c.Offer_Agreement_Amount__c'; //SFTRAC-126
import final_ID_FIELD from '@salesforce/schema/Final_Term__c.Id';
import isGotoNextScreen from '@salesforce/apex/FinalTermscontroller.isGotoNextScreen'; //SFTRAC-126
import getFinalTermSuccessApis from '@salesforce/apex/FinalTermscontroller.getFinalTermSuccessApis';//SFTRAC-126
import FinalTermsSubmitted from '@salesforce/schema/Final_Term__c.L1_Final_Terms_Submitted__c';//SFTRAC-126
import L_TWO_FINAL_TERMS_SUBMITTED from '@salesforce/schema/Final_Term__c.L2_Final_Terms_Submitted__c';//SFTRAC-126
import RetryExhausted from '@salesforce/label/c.Retry_Exhausted';
import checkRetryExhausted from '@salesforce/apex/FinalTermscontroller.checkRetryExhausted';
import retryCountIncrease from '@salesforce/apex/FinalTermscontroller.retryCountIncrease';
import { updateRecord } from 'lightning/uiRecordApi';
import x1stPVEMIDueDate from "@salesforce/label/c.x1stPVEMIDueDate"; // CISP-16789
import x1stPVEMIDueDatev2 from "@salesforce/label/c.x1stPVEMIDueDatev2"; // CISP-16789
import getFinalTermDetails from '@salesforce/apex/FinalTermscontroller.getFinalTermDetails';//CISP-4785 Moved from lwc_FinalTermsScreen js
import TwoWheeler from '@salesforce/label/c.TwoWheeler';//CISP-4785
import PassengerVehicles from '@salesforce/label/c.PassengerVehicles';//CISP-4785
import FinalTerms from '@salesforce/label/c.FinalTerms';//CISP-4785
import x21EMIDueDate from "@salesforce/label/c.x21EMIDueDate";
import x1stTWEMIDueDate from "@salesforce/label/c.x1stTWEMIDueDate";
import No_of_Installment from '@salesforce/schema/Final_Term__c.No_of_Installment__c';
import * as helper from './lwc_FinalTermsScreenHelper';
import FivePercentageOfAmount from '@salesforce/label/c.FivePercentageOfAmount';
import tenPercentageOfAmount from '@salesforce/label/c.tenPercentageOfAmount';
import noPayout from '@salesforce/label/c.noPayout';
// import checkFoirEligibility from '@salesforce/apex/FinalTermscontroller.checkFoirEligibility';  
//SFTRAC -126
import isNavigate from '@salesforce/schema/Final_Term__c.isNavigate__c';
export async function handleTFOfferEngineCalloutHelper(ref){
    try{
      let result = await tractorOfferEngineCallout({ loanAppId: ref.recordid, vehicleId: ref.vehicleId,screenName : 'Final Terms'});
            const parsedResponse = JSON.parse(result);
            const offerEngineResponse = parsedResponse?.application?.offerEngineDetails?.offerEngineDecision;
            const FinalTermFields = {};
            FinalTermFields[final_ID_FIELD.fieldApiName]=ref.finalTermId;
            
            FinalTermFields[OfferengineMinLoanAmount.fieldApiName] = offerEngineResponse !== undefined && offerEngineResponse.minLoanAmt != 'NaN' ?  offerEngineResponse.minLoanAmt : '';
            FinalTermFields[OfferengineMaxLoanAmount.fieldApiName] = offerEngineResponse !== undefined && offerEngineResponse.maxLoanAmt != 'NaN' ?  offerEngineResponse.maxLoanAmt : '';
            FinalTermFields[Loan_Amount.fieldApiName] = offerEngineResponse !== undefined && offerEngineResponse.displayLoanAmt != 'NaN' ?  offerEngineResponse.displayLoanAmt.toString() : '';
            FinalTermFields[OfferengineMinTenure.fieldApiName] = offerEngineResponse !== undefined && offerEngineResponse.minTenure != 'NaN' ?  offerEngineResponse.minTenure : '';
            FinalTermFields[OfferengineMaxTenure.fieldApiName] = offerEngineResponse !== undefined && offerEngineResponse.maxTenure != 'NaN' ?  offerEngineResponse.maxTenure : '';
            FinalTermFields[Tenure.fieldApiName] = offerEngineResponse !== undefined && offerEngineResponse.displayTenure != 'NaN' ?  offerEngineResponse.displayTenure.toString() : '';
            FinalTermFields[EMI_Amount.fieldApiName] = offerEngineResponse !== undefined && offerEngineResponse.displayEMI != 'NaN' ?  offerEngineResponse.displayEMI : '';
            FinalTermFields[Required_CRM_IRR.fieldApiName] = offerEngineResponse !== undefined && offerEngineResponse.displayCrmIrr != 'NaN' ?  offerEngineResponse.displayCrmIrr.toString() : '';
            FinalTermFields[Net_IRR.fieldApiName] = offerEngineResponse !== undefined && offerEngineResponse.netIrr != 'NaN' ?  offerEngineResponse.netIrr : '';
            FinalTermFields[Gross_IRR.fieldApiName] = offerEngineResponse !== undefined && offerEngineResponse.grossIrr != 'NaN' ?  offerEngineResponse.grossIrr : '';
            FinalTermFields[Bank_IRR.fieldApiName] = offerEngineResponse !== undefined && offerEngineResponse.bankCrmIrr != 'NaN' ?  offerEngineResponse.bankCrmIrr.toString() : '';
            FinalTermFields[Offer_Agreement_Amount.fieldApiName] = offerEngineResponse !== undefined && offerEngineResponse.agreementAmount != 'NaN' ?  offerEngineResponse.agreementAmount : '';
            FinalTermFields[No_of_Installment.fieldApiName] = offerEngineResponse !== undefined && offerEngineResponse.noOfInstallments != 'NaN' ?  offerEngineResponse.noOfInstallments : '';
            if(ref.currentStage !== ref.label.CreditProcessing){
                FinalTermFields[FinalTermsSubmitted.fieldApiName] = true;
                FinalTermFields[isNavigate.fieldApiName] = false;
                FinalTermFields[L_TWO_FINAL_TERMS_SUBMITTED.fieldApiName] = true;
            }

            if(offerEngineResponse && offerEngineResponse.amortizationSchedule){
                let result = await saveInstallmentScheduleTractor({ loanId: ref.recordid, response: JSON.stringify(offerEngineResponse.amortizationSchedule), installmentType: ref.installmentTypeValue, vehicleId: ref.vehicleId});
                if(result){
                    let res = await ref.updateRecordDetails(FinalTermFields);
                    if(res){
                        ref.showToast('Success', 'Offer Engine API Completed', 'Success');
                        ref.disabledCheckEligibility = true;
                        ref.iconButtonCaptureUpload = true;
                        //await retryApiCall(ref); //Commented for SFTRAC-918 removed Retry count logic
                        await checkAllFinalTermApiSuccess(ref); //SFTRAC-918
                        ref.disableEverything(); //SFTRAC-795
                    }else{
                        ref.retryPopUp=true;
                        ref.isSpinnerMoving=false;
                        ref.apiMessage='Please Kindly Retry Offer Engine Api is Failed';
                        ref.disabledCheckEligibility = false;
                        //await retryApiCall(ref); //Commented for SFTRAC-918 removed Retry count logic
                    }
                }
            }else{
                const evt = new ShowToastEvent({
                    title: 'Error',
                    message: "Something went wrong!",
                    variant: 'error',
                });
                ref.dispatchEvent(evt);
                ref.isSpinnerMoving = false;
            }
    }catch(error){
        ref.retryPopUp=true;
        ref.isSpinnerMoving=false;
        ref.apiMessage='Please Kindly Retry Offer Engine Api is Failed';
        ref.disabledCheckEligibility = false;
        //await retryApiCall(ref); //Commented for SFTRAC-918 removed Retry count logic
    }
}

export async function  retryApiCall(ref) {
    if(ref.currentStage !== ref.label.CreditProcessing){
    await retryCountIncrease({ loanApplicationId: ref.recordid,vehicleId:ref.vehicleId,api: false }).then(()=>{
        checkRetryExhausted({ loanApplicationId: ref.recordid,vehicleId:ref.vehicleId }).then(res=>{
            let response = JSON.parse(res);
            if(response.message===RetryExhausted){
                const fields = {};
                fields[final_ID_FIELD.fieldApiName]=ref.finalTermId;
                fields[FinalTermsSubmitted.fieldApiName] = true;
                fields[isNavigate.fieldApiName] = false;
                const recordInput={ fields };
                ref.showToast("Error", response.message, 'error');ref.imageUploadRedCross=true;ref.iconButtonCaptureUpload=false;ref.disabledCheckEligibility = true;
                updateRecord(recordInput).then(() => {
                    getFinalTermSuccessApis({loanApplicationId: ref.recordid,isRetryExhausted: true}).then((result) => {
                        console.log('rs' + result);
                        if (result) {
                            ref.moveToOfferScreen();
                        }
                    }).catch((error) => {
                        console.error(error);
                    });
                }).catch(error => {ref.showToast("Error", 'Data not Saved', 'error');});
            }else{
                getFinalTermSuccessApis({loanApplicationId: ref.recordid,isRetryExhausted: false}).then((result) => {
                    console.log('rs' + result);
                    if (result) {
                        ref.moveToOfferScreen();
                    }else{
                        ref.disabledCheckEligibility = ref.iconButtonCaptureUpload;
                    }
                }).catch((error) => {
                    console.error(error);
                });
            }
        }).catch(error=>{
            console.log(error);
        });
    })
    }else{
        await isGotoNextScreen({loanApplicationId: ref.recordid}).then((result) => {
            console.log('r' + result);
            if (result) {
                ref.template.querySelector('.checkEli').disabled = true;
                ref.dispatchEvent(new CustomEvent('finaltermsevent', { detail: FinalTerms}));
            }
        }).catch((error) => {
            console.error(error);
        });
    }
}

export function finalTermValidationHandler(ref, result) {
    if (result && result.tfFinalTermValidation && result.tfFinalTermValidation.length > 0) {
        for (let index = 0; index < result.tfFinalTermValidation.length; index++) {
            const element = result.tfFinalTermValidation[index];
            if (element.Type__c == 'DocumentCharges') {
                ref.docMaxPercentage = element.Max_RMC__c ? element.Max_RMC__c : 0;
                ref.docMinPercentage = element.Min_RCM__c ? element.Min_RCM__c : 0;
                ref.docMaxAmount = element.Max_Amount__c ? element.Max_Amount__c : 0;
            } else if (element.Type__c == 'ServiceCharges') {
                ref.serMinPercentage = element.Min_RCM__c ? element.Min_RCM__c : 0;
                ref.serMaxPercentage = element.Max_RMC__c ? element.Max_RMC__c : 0;
            } else if (element.Type__c == 'PayIns') {
                ref.payinMax = element.Max_RMC__c ? element.Max_RMC__c : 0;
            } else if (element.Type__c == 'PayOuts') {
                ref.payoutMax = element.Max_RMC__c ? element.Max_RMC__c : 0;
            }
        }
    }
}

export function serviceChargesHandler(ref) {
    let isValBreach = false;
    let checkServiceChargesValue = parseInt(ref.serviceChargesValue, 10) % 5;
    let elem = ref.template.querySelector('lightning-input[data-id=serChar]');
    let checkServiceChargesValueMax = (ref.serMaxPercentage * parseInt(ref.requiredLoanAmount, 10)) / 100;
    let checkServiceChargesValueMin = (ref.serMinPercentage * parseInt(ref.requiredLoanAmount, 10)) / 100;
    elem.setCustomValidity("");
    if ((parseInt(ref.serviceChargesValue, 10) < parseInt(checkServiceChargesValueMin, 10)) || (parseInt(ref.serviceChargesValue, 10) > parseInt(checkServiceChargesValueMax, 10))) {
        isValBreach = true;
        elem.setCustomValidity('Please enter a value between 0 to 4 of the percentage of the Finance Amount');
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

export async function documentationChargesHandler(ref) {
    let isValBreach = false;
    let elem = ref.template.querySelector('lightning-input[data-id=DocChar]');
    let checkDocChargesValue = parseInt(ref.documentationChargesValue, 10) % 5;
    elem.setCustomValidity("");
    let docChargesValueMaxPer = (ref.docMaxPercentage * parseInt(ref.requiredLoanAmount, 10)) / 100;
    let docChargesValueMinPer = (ref.docMinPercentage * parseInt(ref.requiredLoanAmount, 10)) / 100;

    if ((parseInt(ref.documentationChargesValue) > parseInt(docChargesValueMaxPer, 10)) || (parseInt(ref.documentationChargesValue) < parseInt(docChargesValueMinPer, 10))) {
        isValBreach = true;
        elem.setCustomValidity('Please enter a value between 0 to 1.5 of the percentage of the Finance Amount');
        elem.reportValidity();
    }
    if (parseInt(ref.documentationChargesValue) > parseInt(ref.docMaxAmount, 10)) {
        isValBreach = true;
        elem.setCustomValidity(`Please enter the documentaion charge less than the ${ref.docMaxAmount}`);
        elem.reportValidity();
    }
    else if (checkDocChargesValue !== 0) {
        isValBreach = true;
        elem.setCustomValidity('Please enter documentation charges in multiples of 5');
        elem.reportValidity();
    }
    if (ref.documentationChargesValue < 0) {
        isValBreach = true;
        elem.setCustomValidity(validValue);
        elem.reportValidity();
    }
    return isValBreach;
}

export async function dealerIncentiveAmountMainHandler(ref) {
    let elem = ref.template.querySelector('lightning-input[data-id=dealInceAmtMain]');
    if (ref.productTypeDetail.toLowerCase() === 'Two Wheeler'.toLowerCase() && (ref.vehicleTypeDetail.toLowerCase() === 'new'.toLowerCase())) {

        let checkDealerIncentiveAmountMainH = (ref.dealerIncentiveAmountMainDealerValid * parseInt(ref.requiredLoanAmount, 10)) / 100;
        elem.setCustomValidity("");
        if (ref.dealerIncentiveAmountMainValue && (ref.dealerIncentiveAmountMainValue > parseInt(checkDealerIncentiveAmountMainH, 10))) {
            elem.setCustomValidity(FivePercentageOfAmount);
            elem.reportValidity();
        }
    } else if (ref.productTypeDetail.toLowerCase() === 'Passenger Vehicles'.toLowerCase()) {
        let checkDealerIncentiveAmountMainC = (ref.dealerIncentiveAmountMainDealerValid * parseInt(ref.requiredLoanAmount, 10)) / 100;
        elem.setCustomValidity("");
        if (ref.dealerIncentiveAmountMainValue && (ref.dealerIncentiveAmountMainValue > parseInt(checkDealerIncentiveAmountMainC, 10))) {
            elem.setCustomValidity(tenPercentageOfAmount);
            elem.reportValidity();

        }
    } else if (ref.productTypeDetail.toLowerCase() === 'Two Wheeler'.toLowerCase() && (ref.vehicleTypeDetail.toLowerCase() === 'Refinance'.toLowerCase() || ref.vehicleTypeDetail.toLowerCase() === 'used'.toLowerCase())) {

        elem.setCustomValidity("");
        if (ref.dealerIncentiveAmountMainValue >= 1) {
            elem.setCustomValidity(noPayout);
            elem.reportValidity();

        }
    } else if (ref.productTypeDetail.toLowerCase() === 'Tractor'.toLowerCase()) {
        let checkDealerIncentiveAmountMainT = (ref.dealerIncentiveAmountMainDealerValid * parseInt(ref.requiredLoanAmount, 10)) / 100;
        elem.setCustomValidity("");
        if (ref.dealerIncentiveAmountMainValue && (ref.dealerIncentiveAmountMainValue > parseInt(checkDealerIncentiveAmountMainT, 10))) {
            elem.setCustomValidity(`Max ${ref.dealerIncentiveAmountMainDealerValid}% on Finance amount`);
            elem.reportValidity();

        }
    }
    if (ref.dealerIncentiveAmountMainValue < 0) {
        elem.setCustomValidity(validValue);
        elem.reportValidity();
    }
}

export async function dsmIncentiveOneHandler(ref) {
    let elem = ref.template.querySelector('lightning-input[data-id=dsmIncent]');
    elem.reportValidity();
    if (ref.productTypeDetail.toLowerCase() === 'Two Wheeler'.toLowerCase() && (ref.vehicleTypeDetail.toLowerCase() === 'new'.toLowerCase())) {
        let checkdsmIncentiveOneH = (ref.dsmIncentiveOneValid * parseInt(ref.requiredLoanAmount, 10)) / 100;
        elem.setCustomValidity("");
        if (ref.dsmIncentiveOneValue && (ref.dsmIncentiveOneValue > parseInt(checkdsmIncentiveOneH, 10))) {
            elem.setCustomValidity(FivePercentageOfAmount);
            elem.reportValidity();
        }
    } else if (ref.productTypeDetail.toLowerCase() === 'Passenger Vehicles'.toLowerCase()) {
        let checkdsmIncentiveOneC = (ref.dsmIncentiveOneValid * parseInt(ref.requiredLoanAmount, 10)) / 100;
        elem.setCustomValidity("");
        if (ref.dsmIncentiveOneValue && (ref.dsmIncentiveOneValue > parseInt(checkdsmIncentiveOneC, 10))) {
            elem.setCustomValidity(tenPercentageOfAmount);
            elem.reportValidity();
        }
    } else if (ref.productTypeDetail.toLowerCase() === 'Two Wheeler'.toLowerCase() && (ref.vehicleTypeDetail.toLowerCase() === 'Refinance'.toLowerCase() || ref.vehicleTypeDetail.toLowerCase() === 'used'.toLowerCase())) {
        elem.setCustomValidity("");
        if (ref.dsmIncentiveOneValue >= 1 || ref.dsmIncentiveOneValue < 0) {
            elem.setCustomValidity(noPayout);
            elem.reportValidity();
        }
    } else if (ref.productTypeDetail.toLowerCase() === 'Tractor'.toLowerCase()) {
        let checkdsmIncentiveOneT = (ref.dsmIncentiveOneValid * parseInt(ref.requiredLoanAmount, 10)) / 100;
        elem.setCustomValidity("");
        if (ref.dsmIncentiveOneValue && (ref.dsmIncentiveOneValue > parseInt(checkdsmIncentiveOneT, 10))) {
            elem.setCustomValidity(`Max ${ref.dsmIncentiveOneValid}% on Finance amount`);
            elem.reportValidity();
        }
    }
    if (ref.dsmIncentiveOneValue < 0) {
        elem.setCustomValidity(validValue);
        elem.reportValidity();
    }
    elem.reportValidity();
}

export async function dsmIncentiveTwoHandler(ref) {
    let elem = ref.template.querySelector('lightning-input[data-id=dsmInce]');
    elem.setCustomValidity("");
    if (ref.productTypeDetail.toLowerCase() === 'Two Wheeler'.toLowerCase() && (ref.vehicleTypeDetail.toLowerCase() === 'new'.toLowerCase())) {
        let checkDsmIncentiveTwoH = (ref.dsmIncentiveTwoValid * parseInt(ref.requiredLoanAmount, 10)) / 100;
        elem.setCustomValidity("");
        if (ref.dsmIncentiveTwoValue && (ref.dsmIncentiveTwoValue > parseInt(checkDsmIncentiveTwoH, 10))) {
            elem.setCustomValidity(FivePercentageOfAmount);
        }
        elem.reportValidity();
    } else if (ref.productTypeDetail.toLowerCase() === 'Passenger Vehicles'.toLowerCase()) {
        let checkDsmIncentiveTwoC = (ref.dsmIncentiveTwoValid * parseInt(ref.requiredLoanAmount, 10)) / 100;
        elem.setCustomValidity("");
        if (ref.dsmIncentiveTwoValue && (ref.dsmIncentiveTwoValue > parseInt(checkDsmIncentiveTwoC, 10))) {
            elem.setCustomValidity(tenPercentageOfAmount);
        }
        elem.reportValidity();
    } else if (ref.productTypeDetail.toLowerCase() === 'Two Wheeler'.toLowerCase() && (ref.vehicleTypeDetail.toLowerCase() === 'Refinance'.toLowerCase() || ref.vehicleTypeDetail.toLowerCase() === 'used'.toLowerCase())) {
        elem.setCustomValidity("");
        if (ref.dsmIncentiveTwoValue >= 1) {
            elem.setCustomValidity(noPayout);
            elem.reportValidity();
        }
    } else if (ref.productTypeDetail.toLowerCase() === 'Tractor'.toLowerCase()) {
        let checkDsmIncentiveTwoT = (ref.dsmIncentiveTwoValid * parseInt(ref.requiredLoanAmount, 10)) / 100;
        elem.setCustomValidity("");
        if (ref.dsmIncentiveTwoValue && (ref.dsmIncentiveTwoValue > parseInt(checkDsmIncentiveTwoT, 10))) {
            elem.setCustomValidity(`Max ${ref.dsmIncentiveTwoValid}% on Finance amount`);
        }
        elem.reportValidity();
    }
    if (ref.dsmIncentiveTwoValue < 0) {
        elem.setCustomValidity(validValue);
        elem.reportValidity();
    }
    elem.reportValidity();
}

export async function referrerIncentiveHandler(ref) {
    let elem = ref.template.querySelector('lightning-input[data-id=refInc]');
    if (ref.productTypeDetail.toLowerCase() === 'Two Wheeler'.toLowerCase() && (ref.vehicleTypeDetail.toLowerCase() === 'new'.toLowerCase())) {
        let checkreferrerIncentive = (ref.referrerIncentiveValid * parseInt(ref.requiredLoanAmount, 10)) / 100;
        elem.setCustomValidity("");
        if (ref.referrerIncentiveValue && (ref.referrerIncentiveValue > parseInt(checkreferrerIncentive, 10))) {
            elem.setCustomValidity(FivePercentageOfAmount);
            elem.reportValidity();
        }
    } else if (ref.productTypeDetail.toLowerCase() === 'Passenger Vehicles'.toLowerCase()) {
        let checkreferrerIncentive = (ref.referrerIncentiveValid * parseInt(ref.requiredLoanAmount, 10)) / 100;
        elem.setCustomValidity("");
        if (ref.referrerIncentiveValue && (ref.referrerIncentiveValue > parseInt(checkreferrerIncentive, 10))) {
            elem.setCustomValidity(tenPercentageOfAmount);
            elem.reportValidity();
        }
    } else if (ref.productTypeDetail.toLowerCase() === 'Two Wheeler'.toLowerCase() && (ref.vehicleTypeDetail.toLowerCase() === 'Refinance'.toLowerCase() || ref.vehicleTypeDetail.toLowerCase() === 'used'.toLowerCase())) {
        elem.setCustomValidity("");
        if (ref.referrerIncentiveValue >= 1 || ref.referrerIncentiveValue < 0) {
            elem.setCustomValidity(noPayout);
            elem.reportValidity();
        }
    } else if (ref.productTypeDetail.toLowerCase() === 'Tractor'.toLowerCase()) {
        let checkreferrerIncentive = (ref.referrerIncentiveValid * parseInt(ref.requiredLoanAmount, 10)) / 100;
        elem.setCustomValidity("");
        if (ref.referrerIncentiveValue && (ref.referrerIncentiveValue > parseInt(checkreferrerIncentive, 10))) {
            elem.setCustomValidity(`Max ${ref.referrerIncentiveValid}% on Finance amount`);
            elem.reportValidity();
        }
    }
    if (ref.referrerIncentiveValue < 0) {
        elem.setCustomValidity(validValue);
        elem.reportValidity();
    }
}
// CISP - 16789
export async function getEmiDateList(ref){    
    let x1stEMIDate1;
    let x2ndEMIDate1;
    let datelist = [];
    ref.emidatelist = [];
    let effectiveDealDate1 = new Date();
    if(ref.monitoriumDaysValue && (ref.monitoriumDaysValue == '30' || ref.monitoriumDaysValue == 30)){
        x1stEMIDate1 = new Date(
          (effectiveDealDate1.getFullYear()),
          (effectiveDealDate1.getMonth() + 1),
        );
        x2ndEMIDate1 = new Date(
          (x1stEMIDate1.getFullYear()),
          (x1stEMIDate1.getMonth() + 1),
        );
    }else{
        x1stEMIDate1 = effectiveDealDate1;
        x2ndEMIDate1 = new Date(
          (x1stEMIDate1.getFullYear()),
          (x1stEMIDate1.getMonth() + 1),
        );
    }
    if (ref.advanceEmiValue) {
        if (ref.productTypeDetail && ref.productTypeDetail.includes("Two Wheeler")) {
          if (parseInt(effectiveDealDate1.getDate()) > 0 && parseInt(effectiveDealDate1.getDate()) <= 15) {
            x1stEMIDate1 = new Date(
              x1stEMIDate1.getFullYear(),
              x1stEMIDate1.getMonth(),
              x1stEMIDate1.getDate()
            );
            x2ndEMIDate1 = new Date(
              x2ndEMIDate1.getFullYear(),
              x2ndEMIDate1.getMonth(),
              parseInt(x1stTWEMIDueDate)
            );
          } else {
            x1stEMIDate1 = new Date(
              x1stEMIDate1.getFullYear(),
              x1stEMIDate1.getMonth(),
              x1stEMIDate1.getDate()
            );
            x2ndEMIDate1 = new Date(
              x2ndEMIDate1.getFullYear(),
              x2ndEMIDate1.getMonth(),
              parseInt(x21EMIDueDate)
            );
          }
          datelist.push({ label: x1stEMIDate1.getDate()+'-'+(x1stEMIDate1.getMonth()+1)+'-'+x1stEMIDate1.getFullYear(), value: x1stEMIDate1.toString()});
          ref.emidatelist = datelist;
          ref.emidate = x1stEMIDate1.toString();
          ref.x2EmiDate = x2ndEMIDate1.getDate()+'-'+(x2ndEMIDate1.getMonth()+1)+'-'+x2ndEMIDate1.getFullYear();
          ref.firstemidate = x1stEMIDate1.getFullYear() + "-" + (x1stEMIDate1.getMonth() + 1) + "-" + x1stEMIDate1.getDate();
          ref.secondemidate = x2ndEMIDate1.getFullYear() + "-" + (x2ndEMIDate1.getMonth() + 1) + "-" + x2ndEMIDate1.getDate();
          console.log('ref.emidatelist',ref.emidatelist,ref.firstemidate,ref.secondemidate, ref.x2EmiDate,ref.emidate);
        } else if (ref.productTypeDetail && ref.productTypeDetail.includes('Passenger Vehicles')) {
          if (parseInt(effectiveDealDate1.getDate()) > 0 && parseInt(effectiveDealDate1.getDate()) < 15) {
            x2ndEMIDate1 = new Date(
              x2ndEMIDate1.getFullYear(),
              x2ndEMIDate1.getMonth(),
              parseInt(x1stPVEMIDueDate)
            );
          } else {
            x2ndEMIDate1 = new Date(
              x2ndEMIDate1.getFullYear(),
              x2ndEMIDate1.getMonth(),
              parseInt(x1stPVEMIDueDatev2)
            );
          }
          datelist.push({ label: x1stEMIDate1.getDate()+'-'+(x1stEMIDate1.getMonth()+1)+'-'+x1stEMIDate1.getFullYear(), value: x1stEMIDate1.toString()});
          ref.emidatelist = datelist;
          ref.emidate = x1stEMIDate1.toString();
          ref.x2EmiDate = x2ndEMIDate1.getDate()+'-'+(x2ndEMIDate1.getMonth()+1)+'-'+x2ndEMIDate1.getFullYear();
          ref.firstemidate = x1stEMIDate1.getFullYear() + "-" + (x1stEMIDate1.getMonth() + 1) + "-" + x1stEMIDate1.getDate();
          ref.secondemidate = x2ndEMIDate1.getFullYear() + "-" + (x2ndEMIDate1.getMonth() + 1) + "-" + x2ndEMIDate1.getDate();
          console.log('ref.emidatelist',ref.emidatelist,ref.firstemidate,ref.secondemidate, ref.x2EmiDate,ref.emidate);
        }
    } else {
        if (ref.productTypeDetail && ref.productTypeDetail.includes('Two Wheeler')) {
            if (parseInt(effectiveDealDate1.getDate()) > 0 && parseInt(effectiveDealDate1.getDate()) <= 15) {
                x1stEMIDate1 = new Date(
                x1stEMIDate1.getFullYear(),
                x1stEMIDate1.getMonth(),
                parseInt(x1stTWEMIDueDate)
                );
                x2ndEMIDate1 = new Date(
                x2ndEMIDate1.getFullYear(),
                x2ndEMIDate1.getMonth(),
                parseInt(x1stTWEMIDueDate)
                );
            } else {
                x1stEMIDate1 = new Date(
                x1stEMIDate1.getFullYear(),
                x1stEMIDate1.getMonth(),
                parseInt(x21EMIDueDate)
                );
                x2ndEMIDate1 = new Date(
                x2ndEMIDate1.getFullYear(),
                x2ndEMIDate1.getMonth(),
                parseInt(x21EMIDueDate)
                );
            }
            datelist.push({ label: x1stEMIDate1.getDate()+'-'+(x1stEMIDate1.getMonth()+1)+'-'+x1stEMIDate1.getFullYear(), value: x1stEMIDate1.toString()});
            ref.emidatelist = datelist;
            ref.emidate = x1stEMIDate1.toString();
            ref.x2EmiDate = x2ndEMIDate1.getDate()+'-'+(x2ndEMIDate1.getMonth()+1)+'-'+x2ndEMIDate1.getFullYear();
            ref.firstemidate = x1stEMIDate1.getFullYear() + "-" + (x1stEMIDate1.getMonth() + 1) + "-" + x1stEMIDate1.getDate();
            ref.secondemidate = x2ndEMIDate1.getFullYear() + "-" + (x2ndEMIDate1.getMonth() + 1) + "-" + x2ndEMIDate1.getDate();
            console.log('ref.emidatelist',ref.emidatelist,ref.firstemidate,ref.secondemidate, ref.x2EmiDate,ref.emidate);
        } else if (ref.productTypeDetail && ref.productTypeDetail.includes("Passenger Vehicles")) {
            // ref.x2EmiDate = '';
            // ref.secondemidate = '';
            let x1stEMIDate2 = new Date();
            let x2ndEMIDate2 = new Date(
                (x1stEMIDate2.getFullYear()),
                (x1stEMIDate2.getMonth() + 1),
            );
            if(parseInt(x1stEMIDate2.getDate()) >= parseInt(x1stPVEMIDueDate) && parseInt(x1stEMIDate2.getDate()) < parseInt(x1stPVEMIDueDatev2)){
                let firstdate = new Date(
                x1stEMIDate2.getFullYear(),
                x1stEMIDate2.getMonth(),
                parseInt(x1stPVEMIDueDatev2)
                );
                datelist.push({ label: firstdate.getDate()+'-'+(firstdate.getMonth()+1)+'-'+firstdate.getFullYear(), value: firstdate.toString() });
                let secdate = new Date(
                x2ndEMIDate2.getFullYear(),
                x2ndEMIDate2.getMonth(),
                parseInt(x1stPVEMIDueDate)
                );
                datelist.push({ label: secdate.getDate()+'-'+(secdate.getMonth()+1)+'-'+secdate.getFullYear(), value: secdate.toString()});
                let thirddate = new Date(
                x2ndEMIDate2.getFullYear(),
                x2ndEMIDate2.getMonth(),
                parseInt(x1stPVEMIDueDatev2)
                );
                datelist.push({ label: thirddate.getDate()+'-'+(thirddate.getMonth()+1)+'-'+thirddate.getFullYear(), value: thirddate.toString()});
            } else {
                let firstdateNew = new Date(
                x1stEMIDate2.getFullYear(),
                x1stEMIDate2.getMonth() + 1,
                parseInt(x1stPVEMIDueDate)
                );
                datelist.push({label: firstdateNew.getDate()+'-'+(firstdateNew.getMonth()+1)+'-'+firstdateNew.getFullYear(), value: firstdateNew.toString()});
                let secdateNew = new Date(
                x2ndEMIDate2.getFullYear(),
                x2ndEMIDate2.getMonth(),
                parseInt(x1stPVEMIDueDatev2)
                );
                datelist.push({label: secdateNew.getDate()+'-'+(secdateNew.getMonth()+1)+'-'+secdateNew.getFullYear(), value: secdateNew.toString()});
                let thirddateNew = new Date(
                x2ndEMIDate2.getFullYear(),
                x2ndEMIDate2.getMonth() + 1,
                parseInt(x1stPVEMIDueDate)
                );
                datelist.push({label: thirddateNew.getDate()+'-'+(thirddateNew.getMonth()+1)+'-'+thirddateNew.getFullYear(), value: thirddateNew.toString()});
            }
            ref.emidatelist = datelist;
        }
    }
}
export function handleEmiChangeHelper(thisVar,event){
    try {
        if(event.target.name == 'firstEMI'){
            let firstemi = new Date(event.target.value);
            thisVar.emidate = event.target.value;
            thisVar.firstemidate = firstemi.getFullYear() + "-" + (firstemi.getMonth() + 1) + "-" + firstemi.getDate();
            let secemi = new Date(
              firstemi.getFullYear(),
              (firstemi.getMonth() + 1),
              firstemi.getDate()
            );
            thisVar.secondemidate = secemi.getFullYear() + "-" + (secemi.getMonth() + 1) + "-" + secemi.getDate();
            thisVar.template
            .querySelectorAll("lightning-input")
            .forEach((input) => {
              if (input.name == "secondEMI") {
                thisVar.x2EmiDate = input.value = secemi.getDate() + "-" + (secemi.getMonth() + 1) + "-" + secemi.getFullYear();
              } 
            });
          }
    } catch (error) {
        console.error(error);
    }
}
//CISP-4785 Moved from lwc_FinalTermsScreen js
export async function callGetFinalTermDetails(thisVar) {
    await getFinalTermDetails({
            opportunityId: thisVar.recordid,
            finalTermId : thisVar.finalTermId
        })
        .then(response => {
            /*CISP-4785 Start*/
            thisVar.isCustomerDedupeSubmit = response.oppRecord?.Is_Customer_Dedupe_Submit__c; /*CISP-4785 End*/
            thisVar.foirCheckinFT = response.oppRecord?.FOIR_Check_At_FinalTerms__c;
            thisVar.dsaReferrer = response.oppRecord?.LeadSource === 'DSA' ? true : false;
            thisVar.dsaReferrerval = response.finalTermDetailLst ? response.finalTermDetailLst[0]?.Referrer_Name__c : '';
            thisVar.DSAName = response.finalTermDetailLst ? response.finalTermDetailLst[0]?.Referrer_Name__c : '';
            thisVar.productTypeDetail = response.oppRecord.Product_Type__c;
            thisVar.currentStageName = response.stage;
            thisVar.leadSource = response.oppRecord.LeadSource;thisVar.customerType = response.oppRecord.Customer_Type__c;
            if (thisVar.leadSource == 'D2C') {
                thisVar.isD2C = true;
            }else{
                thisVar.isNotD2C = true;
            }
            if ((thisVar.leadSource == 'Hero') || (thisVar.leadSource == 'OLA')) {//CISH-04
                thisVar.isHero = true;
            }
            thisVar.lastStage = response.lastStage;
            thisVar.basicPrice = response.basicPrice;
            thisVar.exShowroom = response.oppRecord?.Ex_showroom_price__c;
            thisVar.ORP = response.oppRecord?.On_Road_price__c;
            thisVar.totalFundedPremium = response.totalFundedPremium;
            thisVar.invoiceAmt = response.invoiceAmt;
            thisVar.fundingOnORP = response.fundingOnORP;
            thisVar.fundingOnExShowroom = response.fundingOnExShowroom;
            /*CISP-4785*/
            if (thisVar.forTwoWheeler && !thisVar.isD2C && !thisVar.dsaReferrer && !thisVar.isHero) {
                thisVar.nonD2cDsaTW = true;
                thisVar.showOrHideStyle = 'display:none';
                if (thisVar.currentStageName !== 'Credit Processing') {
                    thisVar.disableAllPayoutFields = true;
                }
            }
            if (response && response.finalTermDetailLst && response.finalTermDetailLst[0]) {
                const finalTermData = response.finalTermDetailLst[0];
                thisVar.finalTermDataD2C = finalTermData;
                thisVar.currentStage = finalTermData.Loan_Application__r.StageName;
                thisVar.changePayInOutEditable = finalTermData.Is_Change_Pay_In_Out_Editable__c;
                if(finalTermData?.Vehicle_Detail__r?.Dealer_Sub_dealer_name__c){
                    thisVar.dealerSubDealer = finalTermData.Vehicle_Detail__r.Dealer_Sub_dealer_name__c;
                }    
                if (thisVar.currentStage === 'Credit Processing' || (finalTermData.Offerengine_StopJourney_Flag__c == true && thisVar.productTypeDetail.toLowerCase() !== PassengerVehicles.toLowerCase())) {
                    if (thisVar.activetab !== FinalTerms) {
                        thisVar.disableEverything();
                        if (finalTermData.Offerengine_StopJourney_Flag__c == true && thisVar.productTypeDetail.toLowerCase() !== PassengerVehicles.toLowerCase()) {
                            thisVar.toastMsg('Journey Stoped');
                        }
                    }
                }
                thisVar.schemeOptionsValue = finalTermData.Scheme_Bank_offers__c;
                thisVar.isRcLimitChecked = finalTermData.RC_limit_enabled_DSA__c;
                if(thisVar.productTypeDetail =='Tractor' && thisVar.currentStage != 'Final Terms' && thisVar.schemeOptionsValue){
                    let data = []; data.push({label:thisVar.schemeOptionsValue,value:thisVar.schemeOptionsValue});console.log('data--',data);
                    thisVar.schemeOptions = data;
                    console.log('scheme data --',thisVar.schemeOptions);
                }
                if(finalTermData.First_EMI_Date__c){
                    let firstdate = new Date(finalTermData.First_EMI_Date__c);
                    firstdate = new Date(firstdate.getFullYear(),firstdate.getMonth(),firstdate.getDate());
                    thisVar.emidatelist.push({label:firstdate.getDate()+'-'+(firstdate.getMonth()+1)+'-'+firstdate.getFullYear(), value: firstdate.toString()});
                    thisVar.emidate = firstdate.toString();
                    thisVar.firstemidate = finalTermData.First_EMI_Date__c;
                }
                if(finalTermData.Second_EMI_Date__c){
                    let secondDate = new Date(finalTermData.Second_EMI_Date__c);
                    secondDate = new Date(secondDate.getFullYear(),secondDate.getMonth(),secondDate.getDate());
                    thisVar.x2EmiDate = secondDate.getDate() + "-" + (secondDate.getMonth() + 1) + "-" + secondDate.getFullYear();
                    thisVar.secondemidate = finalTermData.Second_EMI_Date__c;
                }
                thisVar.offerAgreementAmountValue = finalTermData.Offer_Agreement_Amount__c;
                thisVar.serviceChargesValue = finalTermData.Service_charges__c;
                thisVar.finaltermServiceCharge = finalTermData.Service_charges__c;
                thisVar.documentationChargesValue = finalTermData.Documentation_charges__c;
                thisVar.finaltermDocumentCharge = finalTermData.Documentation_charges__c;
                thisVar.stampingChargesValue = parseInt(finalTermData.Stamping_charges__c, 10);
                /*CISP-4785 Start*/
                if (!thisVar.nonD2cDsaTW || response.subStage !== FinalTerms || thisVar.activetab !== FinalTerms) {
                    if(thisVar.currentStage === 'Credit Processing' && thisVar.productTypeDetail.toLowerCase() !== PassengerVehicles.toLowerCase() && thisVar.leadSource != 'D2C'){//CISP-6058
                        thisVar.disabledServiceCharges = finalTermData.Service_charges__c ? true : thisVar.disabledServiceCharges;
                        thisVar.disabledDocumentationCharges = finalTermData.Documentation_charges__c ? true : thisVar.disabledDocumentationCharges;
                    }
                }/*CISP-4785 End*/
                thisVar.dueDateShiftChargesValue = finalTermData.Due_date_shift_charges__c;
                thisVar.ecsValue = finalTermData.ECS_verification_by__c;
                thisVar.verificationChargesValue = finalTermData.Verification_charges__c;
                thisVar.delinquencyFundValue = finalTermData.Delinquency_Fund__c;
                thisVar.delinquencyFundTypeValue = finalTermData.Deliquency_Fund_type__c;
                thisVar.tradeCertificateValue = finalTermData.Trade_certificate__c;
                thisVar.dealerExpReimburseAmountValue = finalTermData.Dlr_Exp_Reimburse_Amt__c;
                thisVar.dealerExpReimburseTypeValue = finalTermData.Dlr_Exp_Reimburse_Type__c;
                thisVar.mfrExpReimburseAmtValue = finalTermData.Mfr_Exp_Reimburse_Amt__c;
                thisVar.mfrExpReimburseTypeValue = finalTermData.Mfr_Exp_Reimburse_Type__c;
                thisVar.dealerIncentiveAmountMainValue = finalTermData.Dealer_incentive_amount_main_dealer__c;
                thisVar.dealerIncentiveAmountSubValue = finalTermData.Dealer_incentive_amount_sub_dealer__c;
                thisVar.dealerDiscounttoCustomerValue = finalTermData.Dealer_Disc_to_Customer__c;
                thisVar.giftThroughDealerAmountValue = finalTermData.Gift_through_dealer_amount__c;
                thisVar.manufacturerIncentiveValue = finalTermData.Mfr_incentive__c;
                thisVar.dsmIncentiveOneValue = finalTermData.DSM_Incentive1__c;
                thisVar.dsmNameOneValue = finalTermData.DSM_Name1__c;
                thisVar.dsmNameTwoValue = finalTermData.DSM_Name2__c;
                thisVar.dsmIncentiveTwoValue = finalTermData.DSM_Incentive2__c;
                thisVar.nonDlrDsmIncentiveOneValue = finalTermData.Non_Dlr_DSM_Incentive1__c;
                thisVar.nonDlrDsmIncentiveTwoValue = finalTermData.Non_Dlr_DSM_Incentive2__c;
                thisVar.nonDlrDsmNameTwoValue = finalTermData.Non_Dlr_DSM_Name2__c;
                thisVar.nonDlrDsmNameOneValue = finalTermData.Non_Dlr_DSM_Name1__c;
                thisVar.referredbyValue = finalTermData.Refered_By__c;
                thisVar.referrerIncentiveValue = finalTermData.Rreferrer_Incentive__c;
                if(thisVar.forTwoWheeler===false && thisVar.referrerNameOptions.length>0 ){//DSA changes //CISP-22388
                    if(thisVar.dsaReferrer===false){thisVar.referrerNameValue = thisVar.referrerNameOptions.find(opt => opt.label === finalTermData.Referrer_Name__c)?.value;}}
                //thisVar.referrerNameValue = finalTermData.Referrer_Name__c;
                if(thisVar.isPVUsedAndRefinance == true){
                    let referrerName = thisVar.referrerNameOptions.find(opt => opt.value === thisVar.referrerNameValue)?.label; //CISP-22388
                    try{if(referrerName){let splitBenCode = referrerName.split('|'); let benCode = splitBenCode[1];
                    console.log('OUTPUT benCode: ',benCode);thisVar.checkRCLimitEnable(benCode.trim());}
                        }catch(error){console.log('error_ref__'+error);}
                }

                if(thisVar.isTractor && thisVar.referrerNameValue && thisVar.referrerNameOptions.length>0){thisVar.referrerNameValue=thisVar.referrerNameOptions.find(opt => opt.label === thisVar.referrerNameValue)?.value;}

                thisVar.provisionalChannelCostValue = finalTermData.Provisional_Channel_Cost__c;
                thisVar.provisionalChannelCostValueOla = finalTermData.Provisional_Channel_Cost__c; //OLA-21
                thisVar.mfrIncentiveHero = finalTermData.Mfr_incentive__c;
                thisVar.dsaPayValue = finalTermData.DSA_pay__c;
                thisVar.rcuRetentionChargesValue = finalTermData.RCU_Retention_Charges__c;
                thisVar.repaymentModeValue = finalTermData.Repayment_mode__c;
                thisVar.branchValue = finalTermData.Branch__c;
                thisVar.empNameValue = finalTermData.Emp_Name__c;
                thisVar.empNoValue = finalTermData.Emp_No__c;
                thisVar.rtoPrefixValue = finalTermData.RTO_prefix__c;
                thisVar.isNavigateValue = finalTermData.isNavigate__c;
                thisVar.previousLoanAmount = finalTermData.Previous_Loan_Amount__c;//CISP-4785
                thisVar.offerScreenLoanAmount = finalTermData.Loan_Amount__c;
                thisVar.monitoriumDaysValue = finalTermData.Holiday_period__c.toString();
                thisVar.finaltermSchemeId = finalTermData.Schemes__c;
                thisVar.leadSource = finalTermData.Loan_Application__r.LeadSource;
                if (finalTermData.OfferengineMaxLoanAmount__c != undefined) {
                    thisVar.maxAmount = finalTermData.OfferengineMaxLoanAmount__c;
                } else {
                    thisVar.maxAmount = 0;
                }
                if (finalTermData.Advance_EMI__c === true) {
                    thisVar.advanceEmiValue = true;
                    thisVar.advanceEMi = true;
                    thisVar.monitoriumDaysDisabled = true;
                    thisVar.advanceEmiDisabled = false;
                    thisVar.monitoriumDaysValue = '0';
                    //thisVar.advanceEmiDisabled = false;
                } else {
                    thisVar.advanceEmiValue = false;
                    thisVar.advanceEMi = false;
                    thisVar.advanceEmiDisabled = true;
                    thisVar.monitoriumDaysDisabled = false;
                }

                if (finalTermData.Holiday_period__c !== undefined || finalTermData.Holiday_period__c == '0') {
                    thisVar.advanceEmiDisabled = false;
                }
                thisVar.installmentTypeValue = finalTermData.Installment_Type__c;
                thisVar.agreementAmountValue = finalTermData.Agreement_Amount__c;
                thisVar.emiValue = thisVar.isTractor ? finalTermData.EMI_Amount__c ? parseInt(finalTermData.EMI_Amount__c) : '' : finalTermData.EMI_Amount__c;
                thisVar.inputtedIrrValue = finalTermData.Inputted_IRR__c;
                thisVar.netIrrValue = finalTermData.Net_IRR__c;
                thisVar.grossIRRValue = finalTermData.Gross_IRR__c;
                thisVar.bankIrrValue = finalTermData.Bank_IRR__c;
                thisVar.mfrExpReimbursePercentageValue = finalTermData.Mfr_Exp_Reimburse_percent__c;

                thisVar.dealerExpReimbursePercentageValue = finalTermData.Dlr_Exp_Reimbursement_percent__c;
                thisVar.referredby(finalTermData.Refered_By__c);

                thisVar.isFinaltermSubmit = finalTermData.L1_Final_Terms_Submitted__c;
                if (thisVar.isTractor) {
                    thisVar.installmentFrequencyValue = finalTermData.Installment_Frequency__c;
                    helper.installmentsFrequency(thisVar,false,'');
                    thisVar.fundingForBody = finalTermData?.Funding_for_Body__c ? finalTermData?.Funding_for_Body__c : '';
                    thisVar.fundingForChassis = finalTermData?.Funding_for_Chassis__c ? finalTermData?.Funding_for_Chassis__c : '';
                    if(thisVar.currentStage !== 'Final Terms'){thisVar.disabledFundingBody = true;thisVar.disabledFundingChassis=true;thisVar.installFreqDisabled = true;}
                    thisVar.loanDealDate = finalTermData.Loan_Deal_Date__c;
                    thisVar.firstEMIDate = finalTermData.First_EMI_Date__c;
                    thisVar.secondEMIDate = finalTermData.Second_EMI_Date__c;
                }
                if (thisVar.twRefinance) {
                    thisVar.disabledDsaPay = true;
                    thisVar.disabledDealNo = true;
                    thisVar.disabledEmpName = true;
                    thisVar.disabledEmpNo = true;
                    thisVar.disabledReferrerIncentive = true;
                    thisVar.disabledBranch = true;
                    thisVar.disabledReferrerName = true;
                }
                thisVar.phdealerExpReimburseAmountValue = thisVar.dealerExpReimburseAmountValue;
                thisVar.phserviceChargesValue = thisVar.serviceChargesValue;
                thisVar.phdocumentationChargesValue = thisVar.documentationChargesValue;
                thisVar.phdealerIncentiveAmountSubValue = thisVar.dealerIncentiveAmountSubValue;
                thisVar.phdealerIncentiveAmountMainValue = thisVar.dealerIncentiveAmountMainValue;
                thisVar.phdealerDiscounttoCustomerValue = thisVar.dealerDiscounttoCustomerValue;
                thisVar.phdsmIncentiveOneValue = thisVar.dsmIncentiveOneValue;
                thisVar.phnonDlrDsmIncentiveOneValue = thisVar.nonDlrDsmIncentiveOneValue;
                thisVar.phnonDlrDsmIncentiveTwoValue = thisVar.nonDlrDsmIncentiveTwoValue;
                thisVar.phdsmIncentiveTwoValue = thisVar.dsmIncentiveTwoValue;
                thisVar.phgiftThroughDealerAmountValue = thisVar.giftThroughDealerAmountValue;
                thisVar.phmfrExpReimburseAmtValue = thisVar.mfrExpReimburseAmtValue;
                thisVar.phprovisionalChannelCostValue = thisVar.provisionalChannelCostValue;
                thisVar.phreferrerIncentiveValue = thisVar.referrerIncentiveValue;
                thisVar.phdealerExpReimbursePercentageValue = thisVar.dealerExpReimbursePercentageValue;
                thisVar.phmfrExpReimbursePercentageValue = thisVar.mfrExpReimbursePercentageValue;
                if (thisVar.currentStage === 'Credit Processing') {
                    thisVar.offerEngineTenure = response.finalTermDetailLst[0].Tenure__c;
                    thisVar.offerEngineLoanAmount = response.finalTermDetailLst[0].Loan_Amount__c;
                    /*CISP-4785 Start*/
                    if (!thisVar.nonD2cDsaTW || response.subStage !== FinalTerms || thisVar.activetab !== FinalTerms) {
                        if(!thisVar.fromVfPage){
                        if(thisVar.productTypeDetail.toLowerCase() !== PassengerVehicles.toLowerCase() || thisVar.checkleadaccess || thisVar.leadSource == 'D2C') {   //CISP-6058
                            thisVar.disableEverything();}
                        thisVar.disabledrepay = true;
                        thisVar.disabledDealNo = true;
                        thisVar.disabledEmpName = true;
                        thisVar.disabledEmpNo = true;
                        thisVar.disabledReferrerIncentive = true;
                        thisVar.disabledReferrerName = true;
                        thisVar.disabledBranch = true;
                        thisVar.disabledReferrerName = true;
                        }
                    }/*CISP-4785 End*/
                    thisVar.subStage = response.subStage;
                    if ((response.subStage === FinalTerms || thisVar.fromVfPage) && thisVar.activetab === FinalTerms) {//CISP-4785
                        thisVar.finanaceAmountFlag = true;
                        thisVar.financeAmount = response.financeAmount;
                        thisVar.template.querySelector('.checkEli').disabled = false;
                        if (thisVar.productTypeDetail.toLowerCase() !== TwoWheeler.toLowerCase()) {
                            if (thisVar.twRefinance) {
                                thisVar.validationFlag = false;
                            }
                            if (response.serviceChargeFlag && thisVar.validationFlag && !thisVar.isD2C) {
                                thisVar.serviceChargesValue = null;
                                thisVar.popFlag = true;
                                thisVar.disabledServiceCharges = false;
                                if(thisVar.isTractor){
                                    if(thisVar.template.querySelector('lightning-input[data-id=serChar]')){
                                        thisVar.template.querySelector('lightning-input[data-id=serChar]').disabled = false;
                                    }
                                }
                            }
                            if (response.documentChargeFlag && thisVar.validationFlag && !thisVar.isD2C) {
                                thisVar.documentationChargesValue = null;
                                thisVar.popFlag = true;
                                thisVar.disabledDocumentationCharges = false;
                                if(thisVar.isTractor){
                                    if(thisVar.template.querySelector('lightning-input[data-id=DocChar]')){
                                        thisVar.template.querySelector('lightning-input[data-id=DocChar]').disabled = false;
                                    }
                                }
                            }
                            if (response.dealerExpReimburseFlag && thisVar.validationFlag) {
                                thisVar.disabledExpReimburseAmountValue = false;
                                thisVar.dealerExpReimburseAmountValue = null;
                                thisVar.template.querySelector('.checkEli').disabled = false;
                                thisVar.popFlag = true;
                            } else {
                                thisVar.disabledExpReimburseAmountValue = true;
                            }
                            if (response.dealerIncentiveAmountSubDealerFlag && thisVar.validationFlag) {
                                thisVar.disabledDealerIncentiveAmountSubDealer = false;
                                thisVar.dealerIncentiveAmountSubValue = null;
                                thisVar.template.querySelector('.checkEli').disabled = false;
                                thisVar.popFlag = true;
                            } else {
                                thisVar.disabledDealerIncentiveAmountSubDealer = true;
                            }
                            if (response.dealerIncentiveAmountMainDealerFlag && thisVar.validationFlag) {
                                thisVar.disabledDealerIncentiveAmountMainDealer = false;
                                thisVar.dealerIncentiveAmountMainValue = null;
                                thisVar.template.querySelector('.checkEli').disabled = false;
                                thisVar.popFlag = true;
                            } else {
                                thisVar.disabledDealerIncentiveAmountMainDealer = true;
                            }
                            if (response.dealerDiscounttoCustomerFlag && thisVar.validationFlag) {
                                response.finalTermDetailLst ? response.finalTermDetailLst[0].Loan_Application__r.Product_Type__c == 'Passenger Vehicles' ? response.finalTermDetailLst[0].Loan_Application__r.Vehicle_Sub_Category__c == 'UPD' ? thisVar.disabledDealerDiscounttoCustomer = true : thisVar.disabledDealerDiscounttoCustomer = false : thisVar.disabledDealerDiscounttoCustomer = false : thisVar.disabledDealerDiscounttoCustomer = false;
                                thisVar.dealerDiscounttoCustomerValue = null;
                                thisVar.template.querySelector('.checkEli').disabled = false;
                                thisVar.popFlag = true;
                            } else {
                                thisVar.disabledDealerDiscounttoCustomer = true;
                            }
                            if (response.dsmIncentiveOneFlag && thisVar.validationFlag) {
                                thisVar.disabledDsmIncentiveOne = false;
                                thisVar.dsmIncentiveOneValue = null;
                                thisVar.template.querySelector('.checkEli').disabled = false;
                                thisVar.popFlag = true;
                            } else {
                                thisVar.disabledDsmIncentiveOne = true;
                            }
                            if (response.nonDlrDsmIncentiveOneFlag && thisVar.validationFlag) {
                                thisVar.disablednonDlrDsmIncentiveOne = false;
                                thisVar.nonDlrDsmIncentiveOneValue = null;
                                thisVar.template.querySelector('.checkEli').disabled = false;
                                thisVar.popFlag = true;
                            } else {
                                thisVar.disablednonDlrDsmIncentiveOne = true;
                            }
                            if (response.nonDlrDsmIncentiveTwoFlag && thisVar.validationFlag) {
                                thisVar.disablednonDlrDsmIncentiveTwo = false;
                                thisVar.nonDlrDsmIncentiveTwoValue = null;
                                thisVar.template.querySelector('.checkEli').disabled = false;
                                thisVar.popFlag = true;
                            } else {
                                thisVar.disablednonDlrDsmIncentiveTwo = true;
                            }
                            if (response.dsmIncentiveTwoFlag && thisVar.validationFlag) {
                                thisVar.disabledDsmIncentiveTwo = false;
                                thisVar.dsmIncentiveTwoValue = null;
                                thisVar.template.querySelector('.checkEli').disabled = false;
                                thisVar.popFlag = true;
                            } else {
                                thisVar.disabledDsmIncentiveTwo = true;
                            }
                            if (response.giftThroughDealerAmountFlag && thisVar.validationFlag) {
                                thisVar.disabledGiftThroughDealerAmount = false;
                                thisVar.giftThroughDealerAmountValue = null;
                                thisVar.template.querySelector('.checkEli').disabled = false;
                                thisVar.popFlag = true;
                            } else {
                                thisVar.disabledGiftThroughDealerAmount = true;
                            }
                            if (response.mfrExpReimburseAmtFlag && thisVar.validationFlag) {
                                thisVar.disabledMfrExpReimburseAmt = false;
                                thisVar.mfrExpReimburseAmtValue = null;
                                thisVar.template.querySelector('.checkEli').disabled = false;
                                thisVar.popFlag = true;
                            } else {
                                thisVar.disabledMfrExpReimburseAmt = true;
                            }
                            if (response.provisionalChannelCostFlag && thisVar.validationFlag) {
                                thisVar.disabledProvisionalChannelCost = false;
                                thisVar.provisionalChannelCostValue = null;
                                thisVar.template.querySelector('.checkEli').disabled = false;
                                thisVar.popFlag = true;
                            } else {
                                thisVar.disabledProvisionalChannelCost = true;
                            }
                            if (response.reffererIncentiveFlag && thisVar.validationFlag) {
                                thisVar.disabledReferrerIncentive = false;
                                thisVar.referrerIncentiveValue = null;
                                thisVar.template.querySelector('.checkEli').disabled = false;
                                thisVar.popFlag = true;
                            } else {
                                thisVar.disabledReferrerIncentive = true;
                            }
                            if (response.dlrExpReimbursementPercentageFlag && thisVar.validationFlag) {
                                thisVar.disabledDealerExpReimbursePercentage = false;
                                thisVar.dealerExpReimbursePercentageValue = null;
                                thisVar.template.querySelector('.checkEli').disabled = false;
                                thisVar.popFlag = true;
                            } else {
                                thisVar.disabledDealerExpReimbursePercentage = true;
                            }
                            if (response.mfrExpReimbursementPercentageFlag && thisVar.validationFlag) {
                                thisVar.disabledMfrExpReimbursePercentage = false;
                                thisVar.mfrExpReimbursePercentageValue = null;
                                thisVar.template.querySelector('.checkEli').disabled = false;
                                thisVar.popFlag = true;
                            } else {
                                thisVar.disabledMfrExpReimbursePercentage = true;
                            }
                            if (thisVar.popFlag) {
                                thisVar.showToast("Error", thisVar.labelCustom.requiredFields, 'error');
                            }
                        }
                        if (thisVar.popFlag && thisVar.productTypeDetail == PassengerVehicles) {
                            thisVar.disabledProvisionalChannelCost = true;
                        }
                        if(thisVar.currentStage === 'Credit Processing' && thisVar.subStage=='Final Terms' && thisVar.isTractor){
                            thisVar.disabledecsVerificationCharge = true;
                            thisVar.disaibleInstalmentSchedule = true;
                            thisVar.disableInstallmentType = true;
                        }
                        //CISP-6058
                        if(thisVar.currentStage === 'Credit Processing' && thisVar.subStage=='Final Terms' && thisVar.productTypeDetail.toLowerCase() == PassengerVehicles.toLowerCase() && !thisVar.checkleadaccess && thisVar.leadSource != 'D2C'){
                            thisVar.disabledDealerIncentiveAmountMainDealer = false;
                            response.finalTermDetailLst ? response.finalTermDetailLst[0].Loan_Application__r.Product_Type__c == 'Passenger Vehicles' ? response.finalTermDetailLst[0].Loan_Application__r.Vehicle_Sub_Category__c == 'UPD' ? thisVar.disabledDealerDiscounttoCustomer = true : thisVar.disabledDealerDiscounttoCustomer = false : thisVar.disabledDealerDiscounttoCustomer = false : thisVar.disabledDealerDiscounttoCustomer = false;
                            thisVar.disabledGiftThroughDealerAmount = false;
                            thisVar.disabledReferrerIncentive = true;
                            thisVar.disabledReferrerName = true;
                            thisVar.disabledBranch = true;
                            thisVar.disabledEmpNo = true;
                            thisVar.disabledEmpName = true;
                            thisVar.disabledDealNo = true;
                            thisVar.disabledProvisionalChannelCost = false;
                            thisVar.disabledDsaPay = true;
                            thisVar.disabledrepay = false;thisVar.advanceEmiDisabled = false;thisVar.monitoriumDaysDisabled = false;
                            thisVar.referredby(thisVar.referredbyValue);
                            thisVar.template.querySelector('.next').disabled = true;
                        }if(thisVar.currentStage === 'Credit Processing' && thisVar.subStage !='Final Terms' && thisVar.productTypeDetail.toLowerCase() == PassengerVehicles.toLowerCase()){
                            thisVar.disableEverything();
                        }
                        if((thisVar.currentStage != 'Credit Processing' || thisVar.subStage != 'Final Terms') && thisVar.isTractor){
                            thisVar.disableEverything();
                            thisVar.disableInstallmentType = true;
                        }
                        //CISP-6058
                    } else {
                        thisVar.disableEverything();
                        if(thisVar.isTractor){
                            thisVar.disableInstallmentType = true;
                        }
                    }
                }
            }else if(thisVar.isTractor){
                thisVar.referredby('');
            }
        }).catch(error => {});
}

export async function handleLoanDateCalHelper(ref){
    ref.loanDealDate = new Date().toISOString().split('T')[0];
    const X1stDate = new Date(ref.loanDealDate);
    if(ref.advanceEMi == false || ref.advanceEmiValue == false){
        const monthsToAdd = ref.monitoriumDaysValue ? parseInt(ref.monitoriumDaysValue)/30 : 0;
        ref.firstEMIDate = new Date(X1stDate.getFullYear(),(X1stDate.getMonth() + monthsToAdd),);
        const targetFirstDate =  X1stDate.getDate() <= 15 ? 7 : 15;
        let firstEMI = new Date(ref.firstEMIDate.getFullYear() , (ref.firstEMIDate.getMonth()) , parseInt(targetFirstDate))
        ref.firstEMIDate = firstEMI.getFullYear() + '-' + ('0' + (firstEMI.getMonth() + 1)).slice(-2) + '-' +  ('0' + firstEMI.getDate()).slice(-2);
    }else{
        ref.firstEMIDate = ref.loanDealDate;
    }

    ref.secondEMIDate = new Date(ref.firstEMIDate);
    if (ref.installmentFrequencyValue === 'Monthly') {
        ref.secondEMIDate = new Date(ref.secondEMIDate.getFullYear(),(ref.secondEMIDate.getMonth() + 1),);
        const targetSecondDate =  X1stDate.getDate() <= 15 ? 7 : 15;
        let seccondEMI = new Date(ref.secondEMIDate.getFullYear() , (ref.secondEMIDate.getMonth()) , parseInt(targetSecondDate))
        ref.secondEMIDate = seccondEMI.getFullYear() + '-' + ('0' + (seccondEMI.getMonth() + 1)).slice(-2) + '-' + ('0' + seccondEMI.getDate()).slice(-2);   
    } else if (ref.installmentFrequencyValue === 'bi-monthly') {
        ref.secondEMIDate = new Date(ref.secondEMIDate.getFullYear(),(ref.secondEMIDate.getMonth() + 2),);
        const targetSecondDate =  X1stDate.getDate() <= 15 ? 7 : 15;
        let seccondEMI = new Date(ref.secondEMIDate.getFullYear() , (ref.secondEMIDate.getMonth()) , parseInt(targetSecondDate))
        ref.secondEMIDate = seccondEMI.getFullYear() + '-' + ('0' + (seccondEMI.getMonth() + 1)).slice(-2) + '-' + ('0' + seccondEMI.getDate()).slice(-2);  
    } else if (ref.installmentFrequencyValue === 'Quarterly') {
        ref.secondEMIDate = new Date(ref.secondEMIDate.getFullYear(),(ref.secondEMIDate.getMonth() + 3),);
        const targetSecondDate =  X1stDate.getDate() <= 15 ? 7 : 15;
        let seccondEMI = new Date(ref.secondEMIDate.getFullYear() , (ref.secondEMIDate.getMonth()) , parseInt(targetSecondDate))
        ref.secondEMIDate = seccondEMI.getFullYear() + '-' + ('0' + (seccondEMI.getMonth() + 1)).slice(-2) + '-' + ('0' + seccondEMI.getDate()).slice(-2);  
    } else if (ref.installmentFrequencyValue === 'Half yearly') {
        ref.secondEMIDate = new Date(ref.secondEMIDate.getFullYear(),(ref.secondEMIDate.getMonth() + 6),);
        const targetSecondDate =  X1stDate.getDate() <= 15 ? 7 : 15;
        let seccondEMI = new Date(ref.secondEMIDate.getFullYear() , (ref.secondEMIDate.getMonth()) , parseInt(targetSecondDate))
        ref.secondEMIDate = seccondEMI.getFullYear() + '-' + ('0' + (seccondEMI.getMonth() + 1)).slice(-2) + '-' + ('0' + seccondEMI.getDate()).slice(-2);
    }
}
//SFTRAC-909
export async function checkPurchaseprice(ref) {
    console.log('+++++ ref ' + ref.isTractor);
    console.log('+++++ vehicleTypeDetail ' + ref.vehicleTypeDetail+ ' ++Loan12 '+ref.loanAmountDetail+'+++++ ref.vehiclePurchaseprice ' + ref.vehiclePurchaseprice );
    const newMaxLoanAmount = (0.95 * ref.vehiclePurchaseprice);
    const usedRefMaxLoanAmount = (0.90 * ref.vehiclePurchaseprice);
    console.log('+++++ NEW cal ' + newMaxLoanAmount + ' USED Cal ' + usedRefMaxLoanAmount);
    if ((parseInt(ref.loanAmountDetail, 10) > newMaxLoanAmount) && ref.vehicleTypeDetail == 'New') {
        console.log('+++++ ref.vehiclePurchaseprice ' + ref.vehiclePurchaseprice + '+++++ 95% ' + newMaxLoanAmount);
        ref.showToast('Error', 'Loan amount cannot exceed 95% of the vehicle purchase price', 'Error');
        ref.isvehiclePurchasepriceCheck = true;
    } else if (parseInt(ref.loanAmountDetail, 10) > usedRefMaxLoanAmount && (ref.vehicleTypeDetail == 'Used' || ref.vehicleTypeDetail == 'Refinance')) {
        console.log('+++++ ref.vehiclePurchaseprice ' + ref.vehiclePurchaseprice + '+++++ 90% ' + usedRefMaxLoanAmount);
        ref.showToast('Error', 'Loan amount cannot exceed 90% of the vehicle purchase price', 'Error');
        ref.isvehiclePurchasepriceCheck = true;
    }else{
        ref.isvehiclePurchasepriceCheck = false;
    }
}

//SFTRAC-918
export async function checkAllFinalTermApiSuccess(ref) {
    getFinalTermSuccessApis({loanApplicationId: ref.recordid,isRetryExhausted: false}).then((result) => {
        console.log('rs' + result);
        if (result) {
            ref.moveToOfferScreen();
        }else{
            ref.disabledCheckEligibility = ref.iconButtonCaptureUpload;
        }
    }).catch((error) => {
        console.error(error);
    });
}

export async function checkFoirJourneyStop(ref){
    let foirCheck = true;
    foirCheck = await checkFoirEligibility({loanAppId: ref.recordid}).then((result) => {
        console.log('foir check result__'+result);
        if(result === 'Journey Stop') {
            console.log('foir check inside');
            ref.showToast('Error', 'FOIR is greater than 80%, hence journey has been stopped for this lead.', 'Error');
            ref.toastMsg('Journey Stoped');
            ref.disabledCheckEligibility=true;
            ref.disaibleInstalmentSchedule=true;
            ref.disableEverything(); 
            ref.isSpinnerMoving=false;
            return false;
        }
        if(result === 'Journey Restart'){
            console.log('foir check inside else');
            ref.showToast('Error', 'FOIR is greater than 70%, hence journey has been restarted for this lead.', 'Error');
            ref.toastMsg('Journey Restarted');
            ref.disabledCheckEligibility=true;
            ref.disaibleInstalmentSchedule=true;
            ref.disableEverything(); 
            ref.isSpinnerMoving=false;
            return false;
        }
        return true;
    }).catch((error) => {
        console.error(error);
        ref.isSpinnerMoving=false;
        return true;
    });

    return foirCheck;
}