import loadOfferScreenData from '@salesforce/apex/IND_OfferScreenController.loadOfferScreenData';
export function loadoffer(ref) {
    let randomNumber = Math.random();
    loadOfferScreenData({ loanApplicationId: ref.recordid ,randomvar: randomNumber})
        .then((data) => {
            let parsedData = JSON.parse(data);
            if(parsedData.stopJourneyFlag != true)
            {
            ref.oppRecord = parsedData.oppRecord;//CISP-2522
            ref.vehRecord = parsedData.vehRecord;//CISP-2522
            ref.selectedSchemeId = parsedData.schemeId;
            ref.loanAmount = parsedData.loanAmount;
            ref.loanAmountFinal = parsedData.loanAmount;
            ref.maxLoanAmount = parsedData.maxLoanAmtSlider;
            ref.minLoanAmount = parsedData.minLoanAmtSlider;
            ref.maxTenure = parsedData.maxTenureSlider;
            ref.minTenure = parsedData.minTenureSlider;
            ref.tenure = parsedData.tenure;
            ref.tenureFinal = parsedData.tenure;
            ref.emi = parsedData.emi;
            ref.emiFinal = parsedData.emi;//CISP-2361
            ref.orp = parsedData.orp;
            ref.totalFundedPremium=parsedData.totalFundedPremium;
            ref.crmIRR = parsedData.crmIRR;
            ref.requiredCRMIRR = parsedData.requriedCRMIRR;
            ref.requiredCrmIrr = parsedData.requriedCRMIRR;
            ref.installmentTypeValue = parsedData.installmentType;
            if (ref.productType.toLowerCase() === 'Two Wheeler'.toLowerCase()) {//Enhancement for INDI-4682
                ref.requiredCRMIRR=ref.crmIRR;
                ref.requiredCrmIrr=ref.crmIRR;
            }
            ref.isRecordId = parsedData.getrecordId;
            ref.advanceEMi = parsedData.advanceEmi;
            ref.advanceEmis = parsedData.advanceEmi;
            ref.monitoriumDaysValue = parsedData.monitoriumDays;
            ref.monitoriumDaysValueFinal = parsedData.monitoriumDays;
            ref.priceingEngineNetIrr = parsedData.priceingEngineNetIrr;
            if(ref.vechSubCategory.toLowerCase() === 'UIM'.toLowerCase()){
                ref.maxLoanAmount = ref.EligibleLoanAmt;
                ref.maxTenure = ref.EligibleTenure;
            }
            if (ref.advanceEMi === true) {
                ref.template.querySelector('lightning-input[data-id=advanceEMIid]').checked = true;
                ref.monitoriumDaysDisabled = true;
                ref.monitoriumDaysValue = null;
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
                ref.disableInsSchedule= true;
                if(ref.loanAmount != null && ref.tenure != null)
                {
                    ref.flagtoUpdate = true;
                }
                ref.getOfferScreenDatas();
            
                
            }
            ref.handleSliderRanges();

            ref.moratoriumDays = parsedData.monitoriumDays;
            let tenureValue = parsedData.tenure ? parsedData.tenure : ref.tenure;
            ref.netIRRValue = parsedData.netIRR;
            ref.grossIRRValue = parsedData.grossIRR;
            ref.calculateNumberOfInstallments(ref.moratoriumDays, tenureValue);
            if(ref.productType.toLowerCase() === 'Two Wheeler'.toLowerCase() && ref.selectedSchemeId){
                ref.selectedSchemeRecord();
            }
        }
        else{
            ref.toastMsg('Journey Stoped');
                        let allElements = ref.template.querySelectorAll('*');
                        allElements.forEach(element =>
                        element.disabled=true
                        );
                        ref.isSpinnerMoving = false;
                        ref.template.querySelector('.cancel').disabled=false;
        }
        })
        .catch((error) => { console.log('error in loadOfferScreenData ',error);})
}