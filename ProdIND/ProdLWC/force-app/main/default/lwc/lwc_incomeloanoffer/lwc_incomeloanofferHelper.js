import loadOfferScreenData from '@salesforce/apex/IND_OfferScreenController.loadOfferScreenData';
import roiMaster from '@salesforce/apex/IND_OfferScreenController.roiMaster';//CISP-2702

import rerunontenure from '@salesforce/label/c.rerunontenure';
import Refinance from '@salesforce/label/c.Refinance';
import roiMasterTractor from '@salesforce/apex/IND_OfferScreenController.roiMasterTractor';
import RateOfInterestMsg from '@salesforce/label/c.RateOfInterestMsg'
import rerunloanCrm from '@salesforce/label/c.rerunloanCrm';
import reruncrmChanged from '@salesforce/label/c.reruncrmChanged';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import final_ID_FIELD from '@salesforce/schema/Final_Term__c.Id';
import Required_CRM_IRR from '@salesforce/schema/Final_Term__c.Required_CRM_IRR__c';
import { updateRecord } from 'lightning/uiRecordApi';

import Loan_Amount from '@salesforce/schema/Final_Term__c.Loan_Amount__c';
import OfferengineMaxTenure from '@salesforce/schema/Final_Term__c.OfferengineMaxTenure__c';
import OfferengineMinTenure from '@salesforce/schema/Final_Term__c.OfferengineMinTenure__c';
import OfferengineMinLoanAmount from '@salesforce/schema/Final_Term__c.OfferengineMinLoanAmount__c';
import OfferengineMaxLoanAmount from '@salesforce/schema/Final_Term__c.OfferengineMaxLoanAmount__c';
import Gross_IRR from '@salesforce/schema/Final_Term__c.Gross_IRR__c';
import Tenure from '@salesforce/schema/Final_Term__c.Tenure__c';
import EMI_Amount from '@salesforce/schema/Final_Term__c.EMI_Amount__c';
import Net_IRR from '@salesforce/schema/Final_Term__c.Net_IRR__c';
import Bank_IRR from '@salesforce/schema/Final_Term__c.Bank_IRR__c'; //SFTRAC-126
import Offer_Agreement_Amount from '@salesforce/schema/Final_Term__c.Offer_Agreement_Amount__c'; //SFTRAC-126
import tractorOfferEngineCallout from '@salesforce/apex/IntegrationEngine.tractorOfferEngine'; //SFTRAC-126
import ChangeVariantOfferCalled from '@salesforce/schema/Final_Term__c.ChangeVariantOfferCalled__c'; //SFTRAC-1526
import x1stPVEMIDueDate from "@salesforce/label/c.x1stPVEMIDueDate"; // CISP-16789
import x1stPVEMIDueDatev2 from "@salesforce/label/c.x1stPVEMIDueDatev2"; // CISP-16789
import x21EMIDueDate from "@salesforce/label/c.x21EMIDueDate";
import x1stTWEMIDueDate from "@salesforce/label/c.x1stTWEMIDueDate";
import First_EMI_Date from '@salesforce/schema/Final_Term__c.First_EMI_Date__c';
import Second_EMI_Date from '@salesforce/schema/Final_Term__c.Second_EMI_Date__c';
import saveInstallmentSchedule from '@salesforce/apex/InstallmentScheduleController.saveInstallmentSchedule';

export function fetchROIMaster(ref){
    roiMasterTractor({'loanApplicationId' : ref.recordId}).then((result)=>{
        if(result){
            ref.maxcrmtf = result.CRM_IRR_MAX;
            ref.mincrmtf = result.CRM_IRR_MIN;
            ref.minGROSSIRR = result.GROSS_IRR_MIN;
            ref.maxGROSSIRR = result.GROSS_IRR_MAX;
            ref.isNonIndividual = result.isNonIndividual;
        }
    }).catch((error)=>console.log("Error in", "roiMasterTractor", error));
}

export function requiredCRMIRRHandler(ref,oldRequiredCRMIRR){
    let requiredRoiInput = ref.template.querySelector('lightning-input[data-id=reqRoi]');
    if(ref.isNonIndividual != true && ref.mincrmtf != null && ref.maxcrmtf != null && requiredRoiInput){
        requiredRoiInput.setCustomValidity("");
        if (ref.requiredCRMIRR < parseFloat(ref.mincrmtf) || ref.requiredCRMIRR > parseFloat(ref.maxcrmtf)) {
            requiredRoiInput.setCustomValidity(RateOfInterestMsg);
        }
        requiredRoiInput.reportValidity();
        if (ref.requiredCRMIRR <= ref.maxcrmtf && ref.requiredCRMIRR >= ref.mincrmtf) {
            if (ref.requiredCrmIrr !== oldRequiredCRMIRR) {
                ref.flagRequiredCrrIrrChange = true;
            }
            if (ref.flagRequiredCrrIrrChange && !ref.flagLoanAmountChange && !ref.flagTenureChange && !ref.flagAdvanceEmiChange && !ref.flagMonitoriumDays) {
                ref.flagRequiredCrrIrrOnlyChanged = true;
            }
            if (ref.flagLoanAmountChange == true && ref.flagRequiredCrrIrrChange == true) {
                const event = new ShowToastEvent({
                    title: 'Warning',
                    message: rerunloanCrm,
                    variant: 'warning',
                });
                ref.dispatchEvent(event);
            }else if (ref.flagRequiredCrrIrrChange == true) {
                const event = new ShowToastEvent({
                    title: 'Warning',
                    message: reruncrmChanged,
                    variant: 'Warning',
                });
                ref.dispatchEvent(event);
            }
            let ev = new CustomEvent('parentmethod');ref.disableReRunButton = false;
            ref.dispatchEvent(ev);
        }
    } else if(requiredRoiInput){
        if (ref.requiredCrmIrr !== oldRequiredCRMIRR) {
            ref.flagRequiredCrrIrrChange = true;
        }
        if (ref.flagRequiredCrrIrrChange && !ref.flagLoanAmountChange && !ref.flagTenureChange && !ref.flagAdvanceEmiChange && !ref.flagMonitoriumDays) {
            ref.flagRequiredCrrIrrOnlyChanged = true;
        }
        if (ref.flagLoanAmountChange == true && ref.flagRequiredCrrIrrChange == true) {
            const event = new ShowToastEvent({
                title: 'Warning',
                message: rerunloanCrm,
                variant: 'warning',
            });
            ref.dispatchEvent(event);
            let ev = new CustomEvent('parentmethod');ref.disableReRunButton = false;
            ref.dispatchEvent(ev);
        }else if (ref.flagRequiredCrrIrrChange == true) {
            const event = new ShowToastEvent({
                title: 'Warning',
                message: reruncrmChanged,
                variant: 'Warning',
            });
            ref.dispatchEvent(event);
            let ev = new CustomEvent('parentmethod');ref.disableReRunButton = false;
            ref.dispatchEvent(ev);
        }
    }
}

export function validateRquiredCRMIRR(ref){
    let requiredRoiInput = ref.template.querySelector('lightning-input[data-id=reqRoi]');
    if(ref.isNonIndividual != true && ref.mincrmtf != null && ref.maxcrmtf != null && (ref.requiredCRMIRR < parseFloat(ref.mincrmtf) || ref.requiredCRMIRR > parseFloat(ref.maxcrmtf)) && requiredRoiInput){
        requiredRoiInput.setCustomValidity(RateOfInterestMsg);
        requiredRoiInput.reportValidity();
        ref.toastMsg('Required CRM IRR is not as per norms Min '+ ref.mincrmtf +' and Max '+ ref.maxcrmtf + '.');
        return false;
    }
    requiredRoiInput?.setCustomValidity("");
    requiredRoiInput?.reportValidity();
    return true;
}

export function validateLoanAmount(ref) {
    if (!ref.loanAmount || (ref.loanAmount && (parseInt(ref.loanAmount) == 0 || parseInt(ref.loanAmount) < 0))) { 
        const event = new ShowToastEvent({ 
            title: 'Warning', 
            message: 'Loan Amount is mandatory. Please enter valid Loan Amount value.', 
            variant: 'Warning', 
        }); 
        ref.dispatchEvent(event); 
        ref.loanAmount = ''; 
        return true; 
    }
}

export function renderedCallbackHandler(ref) {
    if(ref.productType && ref.productType != 'Tractor'){
    if (ref.isProductTypePV===false) {//Start CISP-2646
        if (ref.handleEmiFlagChange===true && ref.flagLoanAmountChange===false && ref.flagTenureChange===false && ref.flagRequiredCrrIrrOnlyChanged===false && ref.flagRequiredCrrIrrChange===false && ref.flagAdvanceEmiChange===false && ref.flagMonitoriumDays===false && ref.eligiblityButtonClicked === false) {
            let ev = new CustomEvent('emiamountchange');
            ref.dispatchEvent(ev);
        } 
        else if (ref.handleEmiFlagChange===true && (ref.flagLoanAmountChange===true || ref.flagTenureChange===true || ref.flagRequiredCrrIrrOnlyChanged===true || ref.flagRequiredCrrIrrChange===true || ref.flagAdvanceEmiChange===true || ref.flagMonitoriumDays===true || ref.eligiblityButtonClicked === true)) {
            let ev = new CustomEvent('parentmethodaccepts');
            ref.dispatchEvent(ev);
        }
        else if(ref.handleEmiFlagChange===false && ref.flagLoanAmountChange===false && ref.flagTenureChange===false && ref.flagRequiredCrrIrrOnlyChanged===false && ref.flagRequiredCrrIrrChange===false && ref.flagAdvanceEmiChange===false && ref.flagMonitoriumDays===false && ref.eligiblityButtonClicked === false){
            if(ref.isCibilCalledInLtwo){
                let ev = new CustomEvent('emiamountchange');
                ref.dispatchEvent(ev);
            }else if(ref.productType != 'Tractor'){console.log('+++++IN offer renderedCallbackHandler isCibilCalledInLtwo Helper ');
                let ev = new CustomEvent('emiamountsame');
                ref.dispatchEvent(ev);
            }
            if(ref.emi == null){
                ref.dispatchEvent(new CustomEvent('enablererunbtn'))
            }
        }
        if(((Number(ref.tenure) %6 != 0) || (ref.tenure === 0 || ref.tenure === '0' || ref.tenure === '' || ref.tenure === null || ref.tenure === undefined))) {
            let ev = new CustomEvent('notvalidtenure');
            ref.dispatchEvent(ev);
        }else if(ref.tenure && (Number(ref.tenure) %6 === 0)){
            let ev = new CustomEvent('validtenure');
            ref.dispatchEvent(ev);
        }
    }//End CISP-2646
    else{
        let ev = new CustomEvent('validtenure');
        ref.dispatchEvent(ev);
    }
    }
}
export function validationHelper(ref) {
    if ((ref.vehicleType.toLowerCase() === 'Refinance'.toLowerCase() || ref.vehicleType.toLowerCase() === 'Used'.toLowerCase()) && ref.vehRecord.Base_Prices__c!=null && ((parseFloat(ref.loanAmount)) > parseFloat(ref.vehRecord.Base_Prices__c))) {//CISP-7754
        const event = new ShowToastEvent({
            title: 'Error',
            message: 'Loan amount is out of bounds. Please enter value less than Base Price ',
            variant: 'error',
        });
        ref.dispatchEvent(event); 
    return true;  
}
if (ref.vehicleType.toLowerCase() === 'New'.toLowerCase() && ref.oppRecord.Funding_on_Ex_Showroom__c == true && ref.oppRecord.Ex_showroom_price__c!=null && ((parseFloat(ref.loanAmount)) > parseFloat(ref.oppRecord.Ex_showroom_price__c))) {//CISP-2347
    const event = new ShowToastEvent({
        title: 'Warning',
        message: 'Loan amount is out of bounds. Please enter value less than Ex Showroom Price '+ref.oppRecord.Ex_showroom_price__c,
        variant: 'Warning',
     });
     ref.dispatchEvent(event);
     return true;
}else if (ref.vehicleType.toLowerCase() === 'New'.toLowerCase() && ref.oppRecord.Funding_on_ORP__c == true && ref.orp!=null && ((parseFloat(ref.loanAmount)) > parseFloat(ref.orp))) {//CISP-2347
    const event = new ShowToastEvent({
        title: 'Warning',
        message: 'Loan amount is out of bounds. Please enter value less than On Road Price '+ref.orp,
        variant: 'Warning',
     });
     ref.dispatchEvent(event);
     return true;
}
return false;
}
export function loadoffer(ref) {
    loadOfferScreenData({ loanApplicationId: ref.recordId , vehicleId : ref.vehicleId })
    .then((data) => {
            let parsedData = JSON.parse(data);
            console.log('parsedData___'+JSON.stringify(parsedData));
            if (parsedData.stopJourneyFlag != true) {
                ref.oppRecord = parsedData.oppRecord;//CISP-2522
                ref.vehRecord = parsedData.vehRecord;//CISP-2522
                if(ref.productType == 'Tractor'){
                    ref.loanAmount = (Number(parsedData.loanAmount)).toString();
                }else{
                    ref.loanAmount = (Number(parsedData.loanAmount) + Number(parsedData.totalFundedPremium)).toString();
                }
                ref.loanAmountFinal = (Number(parsedData.loanAmount) + Number(parsedData.totalFundedPremium)).toString();
                ref.totalFundedPremium = parsedData.totalFundedPremium;
                ref.orp = parsedData.orp;//CISP-2459
                //ref.maxLoanAmount = parsedData.maxLoanAmtSlider;
                ref.maxLoanAmount = (Number(parsedData.maxLoanAmtSlider) + Number(parsedData.totalFundedPremium)).toString(); // Added for CISP-12784 
                // ref.minLoanAmount = parsedData.minLoanAmtSlider;
                console.log('min ',ref.minLoanAmount);
                ref.maxTenure = parsedData.maxTenureSlider;
                ref.minLoanAmount = parsedData.minLoanAmtSlider;
                ref.minTenure = parsedData.minTenureSlider;
                ref.tenure = parsedData.tenure;
                ref.tenureFinal = parsedData.tenure;
                ref.emi = parsedData.emi;
                ref.emiFinal = parsedData.emi;//CISP-2379
                ref.mincrm = parsedData.mincrm;
                ref.maxcrm = parsedData.maxcrm;
                ref.crmIRR = parsedData.crmIRR;
                ref.requiredCRMIRR = parsedData.requriedCRMIRR;
                ref.requiredCrmIrr = parsedData.requriedCRMIRR;
                ref.isRecordId = parsedData.getrecordId;
                if(parsedData.firstEMIDate){
                    let firstdate = new Date(parsedData.firstEMIDate);
                    firstdate = new Date(firstdate.getFullYear(),firstdate.getMonth(),firstdate.getDate());
                    ref.emidate = firstdate.toString();
                }
                ref.x2EmiDate = parsedData.secondEMIDate;
                 // Added by Abhishek
                if(ref.isCibilCalledInLtwo){
                 const offer = new CustomEvent('isrerunoffer', {
                    detail: {
                        IsRerunOfferEngine: parsedData.IsRerunOfferEngine
                    }
                });
                ref.dispatchEvent(offer);
                }
                //End of Added by Abhishek
                ref.advanceEMi = parsedData.advanceEmi;
                ref.advanceEmis = parsedData.advanceEmi;
                ref.monitoriumDaysValue = parsedData.monitoriumDays;
                if(ref.leadSource == 'D2C'){ //D2C Change Raman
                    ref.monitoriumDaysValue = '30';
                    ref.loanAmount = Number(parsedData.loanAmount);
                }    
                ref.monitoriumDaysValueFinal = parsedData.monitoriumDays;
                ref.priceingEngineNetIrr = parsedData.priceingEngineNetIrr;
                //if (ref.productType.toLowerCase() === 'Two Wheeler'.toLowerCase()) {//Enhancement for INDI-4682 
                    roiMaster({loanApplicationId : ref.recordId,productType : ref.productType,tenure : parseInt(ref.tenure,10),vehicleCategory : ref.vehicleType})//Start CISP-2702
                    .then(result => {
                        let parsedData = JSON.parse(result);
                        if(parsedData.mincrm != null && parsedData.maxcrm != null){
                            ref.mincrm = parsedData.mincrm;
                            ref.maxcrm = parsedData.maxcrm;
                    }});//End CISP-2702
                //}
                if (ref.vechSubCategory.toLowerCase() === 'UIM'.toLowerCase() && ref.productType != 'Tractor') {
                    ref.maxLoanAmount = ref.EligibleLoanAmt;
                    ref.maxTenure = ref.EligibleTenure;
                }
                if (ref.advanceEMi === true) {
                    ref.template.querySelector('lightning-input[data-id=advanceEMIid]').checked = true;
                    ref.monitoriumDaysDisabled = true;
                    ref.monitoriumDaysValue = null;
                    ref.advanceEmiDisabled = ref.productType == 'Tractor' ? true : false;
                }
                if (ref.monitoriumDaysValue != null) {
                    ref.advanceEmiDisabled = true;
                }
                if (ref.emi == null) {
                    ref.disabledLoanAmount = true;
                    ref.disabledTenure = true;
                    ref.disabledCrmIrr = true;
                    ref.disabledRequiredCrmIrr = true;
                    ref.disabledEmiAmount = true;
                    ref.advanceEmiDisabled = true;
                    ref.monitoriumDaysDisabled = true;
                    ref.flagApiFail = true;
                    if (ref.loanAmount != null && ref.tenure != null) {
                        ref.flagtoUpdate = true;
                    }
                    ref.getOfferScreenDatas();
                    ref.dispatchEvent(new CustomEvent('enablererunbtn'))


                }
                if(!ref.isTractor){ref.handleSliderRanges();}

                let moratoriumDays = parsedData.monitoriumDays;
                let tenureValue = parsedData.tenure;
                ref.netIRRValue = parsedData.netIRR;
                ref.grossIRRValue = parsedData.grossIRR;
                if(ref.isTractor){
                    ref.numberOfInstallmentValue = parsedData.totalInstallment;
                } else{
                    ref.calculateNumberOfInstallments(moratoriumDays, tenureValue);
                }

            }
            else {
                ref.toastMsg('Journey Stoped');
                let allElements = ref.template.querySelectorAll('*');
                allElements.forEach(element =>
                    element.disabled = true
                );
                ref.isSpinnerMoving = false;
                ref.template.querySelector('.cancel').disabled = false;
            }
        })
        .catch((error) => { console.log('error in loadOfferScreenData ', error); })
}

export async function getTractorCheckHelper(thisVar) {

    if (thisVar.productType === 'Tractor') {
        let elem = thisVar.template.querySelector('lightning-input[data-id=tenure]');

        let tenureval=thisVar.tenure;
        let totalValue = parseInt(tenureval, 10) + thisVar.vehicleAge;
        if (totalValue > 60 ) //total value is converted into years 
        {
            thisVar.flagTenureChange = false;
            elem.setCustomValidity('Tenure Value + Age of Vehicle should be less than 5 years ');
        }
        if (thisVar.vehicleType.toLowerCase() === Refinance.toLowerCase() && (Number(thisVar.tenure) > 48 || Number(thisVar.tenure) < 12)) {
            thisVar.tenure = '';
            thisVar.flagTenureChange = false;
            thisVar.showToast('Warning', 'Tenure Value is out of bounds.Please enter value between 12 and 48', 'Warning');

        }
        if (thisVar.vehicleType.toLowerCase() === 'Used'.toLowerCase() && (Number(thisVar.tenure) > 36 || Number(thisVar.tenure) < 6)) {
            thisVar.tenure = '';
            thisVar.flagTenureChange = false;
            
            thisVar.showToast('Warning', 'Tenure Value is out of bounds.Please enter value between 6 and 36', 'Warning');

        }
        elem.reportValidity();
        if (thisVar.flagLoanAmountChange == true && thisVar.flagTenureChange == true) {
            let ev = new CustomEvent('parentmethod');
            thisVar.dispatchEvent(ev);
            thisVar.showToast('Warning', rerunontenure, 'Warning');

        }
        else if (thisVar.flagTenureChange == true) {
            let ev = new CustomEvent('parentmethod');
            thisVar.dispatchEvent(ev);
            thisVar.showToast('Warning', rerunontenure, 'Warning');

        }

    thisVar.rerunOEDisable = false;
    }
}

export async function uimUsedTractorCheckHelper(thisVar){
    if (thisVar.productType === 'Tractor') {
        let elem = thisVar.template.querySelector('lightning-input[data-id=tenure]');

        if (thisVar.vehicleType.toLowerCase() === 'Used'.toLowerCase() && (Number(thisVar.tenure) > 36 || Number(thisVar.tenure) < 6)) {
            thisVar.tenure = '';
            thisVar.flagTenureChange = false;
            thisVar.showToast('Warning', 'Tenure Value is out of bounds.Please enter value between 6 and 36', 'Warning');
        }
        elem.reportValidity();

        thisVar.rerunOEDisable = false;
    }
}

export async function notUimNewTractor(thisVar){
    if (thisVar.productType === 'Tractor') {
        let elem = thisVar.template.querySelector('lightning-input[data-id=tenure]');

        if (Number(thisVar.tenure) > 36 || Number(thisVar.tenure) < 6) {
            thisVar.tenure = '';
            thisVar.flagTenureChange = false;
            thisVar.showToast('Warning', 'Tenure Value is out of bounds.Please enter value between 6 and 36', 'Warning');
        }
        elem.reportValidity();
        thisVar.rerunOEDisable = false;

    }
}
export async function runOfferEngineHandler(ref,loanAmount){

    let  obj = {'loanAmount': loanAmount!=undefined ? loanAmount : (Number(ref.loanAmount) + Number(ref.totalFundedPremium)),'crmIrrRequested':ref.requiredCRMIRR};console.log('++++JSON.stringify(obj) '+JSON.stringify(obj));
    await tractorOfferEngineCallout({ loanAppId: ref.recordId, vehicleId: ref.vehicleId,screenName : ref.reRunButton == true ? 'Income Offer' : 'Income Change',requestWrapperStr: JSON.stringify(obj)}).then(
        result => {
            const parsedResponse = JSON.parse(result);
            const offerEngineResponse = parsedResponse?.application?.offerEngineDetails?.offerEngineDecision;
            const FinalTermFields = {};
            FinalTermFields[final_ID_FIELD.fieldApiName]=ref.isRecordId;

            if(ref.isNonIndividual != true && (parseFloat(offerEngineResponse.displayCrmIrr) > parseFloat(ref.maxcrmtf) || parseFloat(offerEngineResponse.displayCrmIrr) < parseFloat(ref.mincrmtf))){
                ref.showToast('Warning',`CRM IRR is not as per norms Min ${ref.mincrmtf} and Max ${ref.maxcrmtf}.`,'warning');
                ref.isSpinnerMoving = false;
                return;
            }else if(ref.isNonIndividual != true && (parseFloat(offerEngineResponse.grossIrr) > parseFloat(ref.maxGROSSIRR) || parseFloat(offerEngineResponse.grossIrr) < parseFloat(ref.minGROSSIRR))){
                ref.showToast('Warning',`Gross IRR is not as per norms Min ${ref.minGROSSIRR} and Max ${ref.maxGROSSIRR}.`,'warning');
                ref.isSpinnerMoving = false;
                return;
            }

            ref.loanAmount = offerEngineResponse && offerEngineResponse.displayLoanAmt ?  parseInt(offerEngineResponse.displayLoanAmt) : '';
            ref.requiredCRMIRR = offerEngineResponse && offerEngineResponse.displayCrmIrr ?  offerEngineResponse.displayCrmIrr : '';
            ref.emi = offerEngineResponse && offerEngineResponse.displayEMI ?  parseInt(offerEngineResponse.displayEMI) : '';
            ref.maxLoanAmount = offerEngineResponse && offerEngineResponse.maxLoanAmt ?  parseInt(offerEngineResponse.maxLoanAmt) : '';
            ref.minLoanAmount = offerEngineResponse && offerEngineResponse.minLoanAmt ?  parseInt(offerEngineResponse.minLoanAmt) : '';
            
            FinalTermFields[OfferengineMinLoanAmount.fieldApiName] = offerEngineResponse !== undefined ?  offerEngineResponse.minLoanAmt : '';
            FinalTermFields[OfferengineMaxLoanAmount.fieldApiName] = offerEngineResponse !== undefined ?  offerEngineResponse.maxLoanAmt : '';
            if(ref.reRunButton == true){
                FinalTermFields[Loan_Amount.fieldApiName] = offerEngineResponse !== undefined ?  (parseFloat(offerEngineResponse.displayLoanAmt) - ref.totalFundedPremium).toString() : '';
                FinalTermFields[ChangeVariantOfferCalled.fieldApiName] = false;//SFTRAC-1526
            }else{
                FinalTermFields[Loan_Amount.fieldApiName] = offerEngineResponse !== undefined ?  (parseFloat(offerEngineResponse.displayLoanAmt)).toString() : '';
                FinalTermFields[ChangeVariantOfferCalled.fieldApiName] = true;//SFTRAC-1526
            }
            FinalTermFields[OfferengineMinTenure.fieldApiName] = offerEngineResponse !== undefined ?  offerEngineResponse.minTenure : '';
            FinalTermFields[OfferengineMaxTenure.fieldApiName] = offerEngineResponse !== undefined ?  offerEngineResponse.maxTenure : '';
            FinalTermFields[Tenure.fieldApiName] = offerEngineResponse !== undefined ?  offerEngineResponse.displayTenure.toString() : '';
            FinalTermFields[EMI_Amount.fieldApiName] = offerEngineResponse !== undefined ?  offerEngineResponse.displayEMI : '';
            FinalTermFields[Required_CRM_IRR.fieldApiName] = offerEngineResponse !== undefined ?  offerEngineResponse.displayCrmIrr.toString() : '';
            FinalTermFields[Net_IRR.fieldApiName] = offerEngineResponse !== undefined ?  offerEngineResponse.netIrr : '';
            FinalTermFields[Gross_IRR.fieldApiName] = offerEngineResponse !== undefined ?  offerEngineResponse.grossIrr : '';
            FinalTermFields[Bank_IRR.fieldApiName] = offerEngineResponse !== undefined ?  offerEngineResponse.bankCrmIrr.toString() : '';
            FinalTermFields[Offer_Agreement_Amount.fieldApiName] = offerEngineResponse !== undefined ?  offerEngineResponse.agreementAmount : '';                

            const fields = FinalTermFields;
            const recordInput = { fields };
            updateRecord(recordInput).then(()=>{
                ref.showToast('Success','Record updated!','success');    
            }).catch(error=>{
                ref.showToast('Error','Record updated failed!','error');
            })
            ref.showToast('Success','Offer Engine API Success','success');
            ref.isSpinnerMoving = false;
            ref.disableReRunButton = true;
            let ev = new CustomEvent('parentmhd');
            ref.dispatchEvent(ev);
            let acceptBtn = new CustomEvent('parentmethodaccepts');
            ref.dispatchEvent(acceptBtn);
            let saveVarientDetail = new CustomEvent('savevarient',{detail : {index : ref.index}});
            ref.dispatchEvent(saveVarientDetail);
            ref.disabledLoanAmount = false;
            ref.loanSliderDisabled = false;
            ref.disabledRequiredCrmIrr = false;
            ref.reRunButton = false;
        })
        .catch(error => {
            console.log('Error in Offer Engine API.', error);
            const evt = new ShowToastEvent({
                title: 'Error',
                message: "Offer Engine API Failed",
                variant: 'error',
            });
            ref.dispatchEvent(evt);
            ref.isSpinnerMoving = false;
        });
}
export async function enteredLoanAmountCheck(thisVar) {
    if(thisVar.isTractor){
        if(parseInt(thisVar.loanAmount,10) >= thisVar.minLoanAmount){
            thisVar.disableReRunButton = false;
        }else{
            const event = new ShowToastEvent({
                title: 'Error',
                message: 'Entered Loan Amount is less than minimum range Amount',
                variant: 'Error',
            });
            thisVar.dispatchEvent(event);
        }
        let totalFPflag = thisVar.totalFundedPremium != null && thisVar.totalFundedPremium != 0;
        const newMaxLoanAmount = (0.95 * thisVar.vehiclePurchaseprice);
        const usedRefMaxLoanAmount = (0.90 * thisVar.vehiclePurchaseprice);
        if ( (parseInt(thisVar.loanAmount,10) > newMaxLoanAmount) && thisVar.vehicleType == 'New') {
            const event = new ShowToastEvent({
                title: 'Error',
                message: 'Loan amount cannot exceed 95% of the vehicle purchase price',
                variant: 'Error',
            });
            thisVar.dispatchEvent(event);
            thisVar.disableReRunButton = true;
        }else if ((totalFPflag == true) && parseInt(thisVar.loanAmount,10) > usedRefMaxLoanAmount && (thisVar.vehicleType == 'Used' || thisVar.vehicleType == 'Refinance')) {
            const event = new ShowToastEvent({
                title: 'Error',
                message: 'Loan amount cannot exceed 90% of the vehicle purchase price',
                variant: 'Error',
            });
            thisVar.dispatchEvent(event);
            thisVar.disableReRunButton = true;
        }else if ((totalFPflag == false) && parseInt(thisVar.loanAmount,10) > newMaxLoanAmount && (thisVar.vehicleType == 'Used' || thisVar.vehicleType == 'Refinance')) {
            const event = new ShowToastEvent({
                title: 'Error',
                message: 'Loan amount cannot exceed 95% of the vehicle purchase price',
                variant: 'Error',
            });
            thisVar.dispatchEvent(event);
            thisVar.disableReRunButton = true;
        }
    }
}
export function getEmiDateList(ref){
    if(ref.isProductTypeTW){
        let datelist = [];
        let x1stEMIDate1;
        let x2ndEMIDate1;
        let effectiveDealDate1 = new Date();
        x1stEMIDate1 = effectiveDealDate1;
        x2ndEMIDate1 = new Date(
          (x1stEMIDate1.getFullYear()),
          (x1stEMIDate1.getMonth() + 1),
        );
        if (parseInt(effectiveDealDate1.getDate()) > 0 && parseInt(effectiveDealDate1.getDate()) <= 15) {
          x2ndEMIDate1 = new Date(
            x2ndEMIDate1.getFullYear(),
            x2ndEMIDate1.getMonth(),
            parseInt(x1stTWEMIDueDate)
          );
        } else {
          x2ndEMIDate1 = new Date(
            x2ndEMIDate1.getFullYear(),
            x2ndEMIDate1.getMonth(),
            parseInt(x21EMIDueDate)
          );
        }
        datelist.push({ label: x1stEMIDate1.getDate()+'-'+(x1stEMIDate1.getMonth()+1)+'-'+x1stEMIDate1.getFullYear(), value: x1stEMIDate1.toString()});
    }
    if(!ref.isProductTypeTW){
    let datelist = [];
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
export function handleEmiChangeHelper(thisVar,event){
    try {
        if(event.target.name == 'firstEMI'){
            let firstemi = new Date(event.target.value);
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
                input.value = secemi.getFullYear() + "-" + (secemi.getMonth() + 1) + "-" + secemi.getDate();
              } 
            });
          }
    } catch (error) {
        console.error(error);
    }
}
    export async function saveEMIdueDates(ref){
        const FinalTermFields = {};
        FinalTermFields[final_ID_FIELD.fieldApiName] = ref.isRecordId;
        if(ref.productType == 'Two Wheeler'){
            FinalTermFields[First_EMI_Date.fieldApiName] = ref.firstemidate;
            FinalTermFields[Second_EMI_Date.fieldApiName] = ref.secondemidate;    
        } else {
            FinalTermFields[First_EMI_Date.fieldApiName] = ref.emidate;
            FinalTermFields[Second_EMI_Date.fieldApiName] = ref.secondemidate;    
        }
        await ref.updateRecordDetails(FinalTermFields);
    }
    export function saveAmortDetails(ref,obj,loanId){
        console.log(ref.recordid,'ref.recordid',obj,'obj',loanId,'loanId')
        if(obj.amortizationSchedule){
            saveInstallmentSchedule({ loanId: loanId, response: JSON.stringify(obj.amortizationSchedule), installmentType: ref.installmentType}).then(result => {console.log(result,'res instal');}).catch(error =>{console.log(error,'error instal ');});
        }
    }
    export function emiDateCalculation(ref){
        if(ref.advanceEMi){
            if(ref.productType == 'Two Wheeler'){
                let x1stEMIDate1;
                let x2ndEMIDate1;
              let x1stEMIDate2;
              x1stEMIDate2 = new Date();
              let x2ndEMIDate2 = new Date(
                (x1stEMIDate2.getFullYear()),
                (x1stEMIDate2.getMonth() + 1),
              );
              if (parseInt(x1stEMIDate2.getDate()) > 0 && parseInt(x1stEMIDate2.getDate()) <= 15) {
                x2ndEMIDate2 = new Date(
                  x2ndEMIDate2.getFullYear(),
                  x2ndEMIDate2.getMonth(),
                  parseInt(x1stTWEMIDueDate)
                );
              } else {
                x2ndEMIDate2 = new Date(
                  x2ndEMIDate2.getFullYear(),
                  x2ndEMIDate2.getMonth(),
                  parseInt(x21EMIDueDate)
                );
              }
              let firstEmiVal = x1stEMIDate2.getFullYear() + "-" + (x1stEMIDate2.getMonth() + 1) + "-" + x1stEMIDate2.getDate();
              let secondEmiVal = x2ndEMIDate2.getFullYear() + "-" + (x2ndEMIDate2.getMonth() + 1) + "-" + x2ndEMIDate2.getDate();
              
              ref.firstemidate = firstEmiVal;
              ref.secondemidate = secondEmiVal;
            }
        }
        else {
            if(ref.productType == 'Two Wheeler'){
                let x1stEMIDate1;
                let x2ndEMIDate1;
              let x1stEMIDate2;
              x1stEMIDate2 = new Date();
              let x2ndEMIDate2 = new Date(
                (x1stEMIDate2.getFullYear()),
                (x1stEMIDate2.getMonth() + 1),
              );
              if (parseInt(x1stEMIDate2.getDate()) > 0 && parseInt(x1stEMIDate2.getDate()) <= 15) {
                x1stEMIDate2 = new Date(
                  x1stEMIDate2.getFullYear(),
                  x1stEMIDate2.getMonth() + 1,
                  parseInt(x1stTWEMIDueDate)
                );
                x2ndEMIDate2 = new Date(
                  x2ndEMIDate2.getFullYear(),
                  x2ndEMIDate2.getMonth() + 1,
                  parseInt(x1stTWEMIDueDate)
                );
              } else {
                x1stEMIDate2 = new Date(
                  x1stEMIDate2.getFullYear(),
                  x1stEMIDate2.getMonth() + 1,
                  parseInt(x21EMIDueDate)
                );
                x2ndEMIDate2 = new Date(
                  x2ndEMIDate2.getFullYear(),
                  x2ndEMIDate2.getMonth() + 1,
                  parseInt(x21EMIDueDate)
                );
              }
              let firstEmiVal = x1stEMIDate2.getFullYear() + "-" + (x1stEMIDate2.getMonth() + 1) + "-" + x1stEMIDate2.getDate();
              let secondEmiVal = x2ndEMIDate2.getFullYear() + "-" + (x2ndEMIDate2.getMonth() + 1) + "-" + x2ndEMIDate2.getDate();
              
              ref.firstemidate = firstEmiVal;
              ref.secondemidate = secondEmiVal;
              console.log(ref.firstemidate,'ref.firstemidate');
              console.log(ref.secondemidate,'ref.secondemidate');
        }
    }
}