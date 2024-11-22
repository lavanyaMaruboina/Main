import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import checkOtherCoBorrowerClosed from '@salesforce/apex/LwcLOSLoanApplicationCntrl.checkOtherCoBorrowerClosed';
import checkOtherBeneficaryClosed from '@salesforce/apex/LwcLOSLoanApplicationCntrl.checkOtherBeneficaryClosed';

export async function toCoborrower(ref) {
    let noOfCoBorrowerAllowed = ref.isNonIndividualLead ? 2 : parseInt(ref.label.TF_No_Of_CoBorrower);
    if(findTabCount(ref.tabList,ref.label.CoBorrower) > 0 && ref.productType != 'Tractor'){
        console.log('You Cant not add more than one co-borrower ::', ref.tabList.length);
        const evt = new ShowToastEvent({
            title: 'Error',
            message: 'Addition of multilple co-borrower is not allowed.',
            variant: 'error',
        });
        ref.dispatchEvent(evt);
        return;//CISP-2384
    }else if(findTabCount(ref.tabList,ref.label.CoBorrower) >= noOfCoBorrowerAllowed && ref.productType === 'Tractor'){
        console.log('You Cant not add more than mentioned limit co-borrower ::', ref.tabList.length);
        const evt = new ShowToastEvent({
            title: 'Error',
            message: 'Addition of more than '+noOfCoBorrowerAllowed+' co-borrower is not allowed.',
            variant: 'error',
        });
        ref.dispatchEvent(evt);
        return;
    }else{
        if(ref.productType === 'Tractor'){
            let checkDB = true;
            ref.tabList.forEach(ele => {
                if(ele.applicantId==="NIL"){
                    newAdditionWarning(ref);
                    checkDB = false;
                    return;
                }
            });
            if(checkDB){
                ref.isLoading = true;
                await checkOtherCoBorrowerClosed({ loanApplicationId: ref.recordId }).then(response => {
                    console.log('checkOtherCoBorrowerClosed Response received : '+response);
                    if(response === true){
                        ref.tabList.push({"applicantType":ref.label.CoBorrower, "applicantId": "NIL"});
                        ref.activeTab = ref.label.CoBorrower;
                        ref.activeTabId = "NIL";
                        ref.isLoading = false;
                        navigateToNewTab(ref);
                        
                    }else{
                        ref.isLoading = false;
                        newAdditionWarning(ref);
                        return;
                    }
                }).catch(error => {
                    ref.isLoading = false;
                });
            }
        }else{
            ref.tabList.push({"applicantType":ref.label.CoBorrower, "applicantId": "NIL"});
            ref.activeTab = ref.label.CoBorrower;
            ref.activeTabId = "NIL";
            ref.isLoading = false;
            navigateToNewTab(ref);
        }
    }

    ref.tabListCount = ref.tabList.length; //IND-2373
    
}

function navigateToNewTab(ref){
    //CISP-2384 - START
    setTimeout(() => {
        ref.template.querySelector(`lightning-tabset[data-id="applicantTabSet"]`).activeTabValue = "NIL";
    }, 1000);
    //CISP-2384 - END
}

function newAdditionWarning(ref){
    const evt = new ShowToastEvent({
        title: 'Warning',
        message: 'Completion of previous Co-borrower is mandatory before adding new one.',
        variant: 'warning',
    });
    ref.dispatchEvent(evt);
}

export function toGuarantor(ref){
    console.log('Ref Tab List'+ JSON.stringify(ref.tabList));
    if (findTabCount(ref.tabList,ref.label.Guarantor) == 0) {
        ref.tabList.push({"applicantType":ref.label.Guarantor, "applicantId": "G-NIL"});
        ref.activeTab = ref.label.Guarantor;
        ref.activeTabId = "G-NIL";
        console.log('toGuarantor :: ',ref.tabList.length,' ref.activeTab :: ',ref.activeTab);
    } else if (findTabCount(ref.tabList,ref.label.Guarantor) > 0) {
        console.log('You Cant not add more than one guarantor ::', ref.tabList.length);
        const evt = new ShowToastEvent({
            title: 'Error',
            message: 'Addition of multilple guarantor is not allowed.',
            variant: 'error',
        });
        ref.dispatchEvent(evt);
        return;
    }
    ref.tabListCount = ref.tabList.length; //IND-2373
    //CISP-2384 - START
    setTimeout(() => {
        ref.template.querySelector(`lightning-tabset[data-id="applicantTabSet"]`).activeTabValue = "G-NIL";
    }, 1000);
    //CISP-2384 - END
}

export async function toBeneficiary(ref){
    try{
        ref.isLoading = true;
        let allBeneficaryJourneyCompleted = true;
        for (let index = 0; index < ref.tabList.length; index++) {
            if(ref.tabList[index].activeTabId === "B-NIL"){
                allBeneficaryJourneyCompleted = false;
                break;
            }
        }
        let result = await checkOtherBeneficaryClosed({ loanApplicationId: ref.recordId });
        if(!result || !allBeneficaryJourneyCompleted){
            const evt = new ShowToastEvent({
                title: 'Warning',
                message: 'Completion of previous Beneficiary is mandatory before adding new one.',
                variant: 'warning',
            });
            ref.dispatchEvent(evt);
            ref.isLoading = false;
            return;
        }
        console.log('Ref Tab List'+ JSON.stringify(ref.tabList));
        if (findTabCount(ref.tabList,ref.label.Beneficiary) < 9) {
            ref.tabList.push({"applicantType":ref.label.Beneficiary, "applicantId": "B-NIL"});
            ref.activeTab = ref.label.Beneficiary;
            ref.activeTabId = "B-NIL";
            ref.isLoading = false;
        } else if (findTabCount(ref.tabList,ref.label.Beneficiary) >= 9) {
            console.log('You cannot not add more than nine beneficiaries ::', ref.tabList.length);
            const evt = new ShowToastEvent({
                title: 'Error',
                message: 'Addition of more than 9 Beneficiaries are not allowed.',
                variant: 'error',
            });
            ref.dispatchEvent(evt);
            ref.isLoading = false;
            return;
        }
        ref.tabListCount = ref.tabList.length;
        setTimeout(() => {
            ref.template.querySelector(`lightning-tabset[data-id="applicantTabSet"]`).activeTabValue = "B-NIL";
        }, 1000);
    }catch(error){
        ref.isLoading = false;
    }
}

export function findTabCount(lst,x){
    let count = 0;
    lst.forEach(element => {
        if(element.applicantType === x){
            count++;
        }
    });
    return count;
}

export function toModifyTabList(ref,event){
    console.log('Captured New Applicant: '+JSON.stringify(event.detail));
    let applicantId = event.detail.applicantId;
    let applicantType = event.detail.applicantType;
    ref.tabList.forEach(ele =>{
        if((ele.applicantType == applicantType) && (ele.applicantId == 'NIL' || ele.applicantId == 'G-NIL' || ele.applicantId == 'B-NIL')){
            ele.applicantId = applicantId;
        }
    });
}