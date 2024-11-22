import WOULD_YOU_LIKE_TO_OPEN_A_BANK_ACCOUNT from '@salesforce/schema/Applicant__c.Would_you_like_to_open_a_bank_account__c';
import NOMINEE_AVAILABLE_FIELD from '@salesforce/schema/Applicant__c.Nominee_available__c';
import NOMINEE_NAME_FIELD from '@salesforce/schema/Applicant__c.Nominee_name__c';
import NOMINEE_DOB_FIELD from '@salesforce/schema/Applicant__c.Nominee_DOB__c';
import NOMINEE_ADDRESS_FIELD from '@salesforce/schema/Applicant__c.Nominee_address__c';
import NOMINEE_PINCODE_FIELD from '@salesforce/schema/Applicant__c.Nominee_pin_code__c';
import NOMINEE_CITY_FIELD from '@salesforce/schema/Applicant__c.Nominee_City__c';
import NOMINEE_STATE_FIELD from '@salesforce/schema/Applicant__c.Nominee_State__c';
import NOMINEE_RELATIONSHIP_FIELD from '@salesforce/schema/Applicant__c.Nominee_Relationship__c';
import  REPAYMENT_WILL_BE_DONE_BY from '@salesforce/schema/Applicant__c.Repayment_Will_Be_Done_By__c';
import  WHO_WILL_REPAY_THE_LOAN from '@salesforce/schema/Applicant__c.Who_will_repay_the_loan__c';
import APP_ID_FIELD from '@salesforce/schema/Applicant__c.Id';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import accessLoanApplication from '@salesforce/apex/LwcLOSLoanApplicationCntrl.accessLoanApplication';
import CASA_APPLICANT from '@salesforce/schema/CASA_Bank_Form__c.Applicant__c';
import CASA_OPENED_FOR from '@salesforce/schema/CASA_Bank_Form__c.Saving_Account_opened_for__c';
import CASA_LOAN_APPID from '@salesforce/schema/CASA_Bank_Form__c.Loan_Application__c';
import CASA_NOMINEE_ADDRESS_FIELD from '@salesforce/schema/CASA_Bank_Form__c.Nominee_address__c';
import CASA_NOMINEE_AVAILABLE_FIELD from '@salesforce/schema/CASA_Bank_Form__c.Nominee_available__c';
import CASA_NOMINEE_CITY_FIELD from '@salesforce/schema/CASA_Bank_Form__c.Nominee_City__c';
import CASA_NOMINEE_DOB_FIELD from '@salesforce/schema/CASA_Bank_Form__c.Nominee_DOB__c';
import CASA_NOMINEE_NAME_FIELD from '@salesforce/schema/CASA_Bank_Form__c.Nominee_name__c';
import CASA_NOMINEE_PINCODE_FIELD from '@salesforce/schema/CASA_Bank_Form__c.Nominee_Pin_Code__c';
import CASA_NOMINEE_STATE_FIELD from '@salesforce/schema/CASA_Bank_Form__c.Geo_State_Master__c';
import CASA_NOMINEE_FINACLE_CITY_FIELD from '@salesforce/schema/CASA_Bank_Form__c.Finacle_City__c';
import CASA_NOMINEE_RELATIONSHIP_FIELD from '@salesforce/schema/CASA_Bank_Form__c.Relationship_with_borrower__c';
import getState from '@salesforce/apex/IND_TeleverificationDetails.getState';// Added By Prashant STRAC-96
import Borrower from '@salesforce/label/c.Borrower';
import getProfile from '@salesforce/apex/Ind_IncomeDetailsCtrl.getProfile';
import crosscoreAPICallout from '@salesforce/apex/IntegrationEngine.doCrosscore';
import getHunterResponse from '@salesforce/apex/LwcLOSLoanApplicationCntrl.getHunterResponse';
import { createRecord,updateRecord } from "lightning/uiRecordApi";
import oppId from '@salesforce/schema/Opportunity.Id';
import isNewApplicant from '@salesforce/apex/Ind_Demographic.isNewApplicant';
import checkUploadDocument from '@salesforce/apex/LwcLOSLoanApplicationCntrl.checkUploadDocument';
import FORM_FACTOR from '@salesforce/client/formFactor';
import doGenerateTokenAPI from  '@salesforce/apex/IntegrationEngine.doGenerateTokenAPI'; //SFTRAC-724
import cRIFFAPICall from  '@salesforce/apex/IntegrationEngine.cRIFFAPICall'; //SFTRAC-724
import getApplicantMap from  '@salesforce/apex/Ind_Demographic.getApplicantMap'; 
import CoBorrower from '@salesforce/label/c.CoBorrower';
import doPincodeBasedSearchCallout from '@salesforce/apexContinuation/IntegrationEngine.doPincodeBasedSearchCallout';//SFTRAC-1178
import doBREscoreCardCallout from '@salesforce/apexContinuation/IntegrationEngine.doBREscoreCardCallout';
import Scorecard_Decision__c from '@salesforce/schema/Applicant__c.Scorecard_Decision__c';
import ScoreCard_Description__c from '@salesforce/schema/Applicant__c.ScoreCard_Description__c';
import getRiskBandStatusValue from '@salesforce/apex/Ind_Demographic.getRiskBandStatusValue';
import checkRetryExhausted from '@salesforce/apex/Ind_Demographic.checkRetryExhausted';
import getDemographicDetails from '@salesforce/apex/Ind_Demographic.getDemographicDetails';
import OPP_JOURNEY_STATUS from '@salesforce/schema/Opportunity.Journey_Status__c';
import OPP_ID_FIELD from '@salesforce/schema/Opportunity.Id';
import JOURNEY_STOP_REASON from '@salesforce/schema/Opportunity.Journey_Stop_Reason__c';
import JOURNEY_STOP_SCENARIO_FOUND from '@salesforce/schema/Opportunity.JourneyStopScenarioFound__c';
import checkAllApplicantPhoneNo from '@salesforce/apex/Ind_Demographic.checkAllApplicantPhoneNo'; //SFTRAC-2219 changes

export function handleNomineeFieldValueChangeHelper(ref,evt){
    if(evt.target.dataset.id == 'nomineeName'){
        ref.nomineeName = evt.target.value;
    }
    else if(evt.target.dataset.id == 'nomineeDOB'){
        ref.nomineeDob = evt.target.value;
    }
    else if(evt.target.dataset.id == 'nomineeAddress'){
        ref.nomineeAddress = evt.target.value;
    }
    else if(evt.target.dataset.id == 'nomineePinCode'){
        ref.nomineePincode = evt.target.value;
    }
    else if(evt.target.dataset.id == 'nomineeCity'){
        ref.nomineeCity = evt.target.value;
    }
    else if(evt.target.dataset.id == 'nomineeState'){
        ref.nomineeState = evt.target.value;
    }
    else if(evt.target.dataset.id == 'nomineeRelationshipBorrower'){

        ref.nomineeRelationship = evt.detail.value;
    }
    console.log('ref.nomineeName-->'+ref.nomineeName+'ref.nomineeDob-->'+ref.nomineeDob+'ref.nomineeAddress-->'+ref.nomineeAddress+'ref.nomineePincode-->'+ref.nomineePincode+'ref.nomineeCity-->'+ref.nomineeCity+'ref.nomineeState-->'+ref.nomineeState+'ref.nomineeRelationship-->'+ref.nomineeRelationship);
}

export function helperValidate(ref) {
    let status = true;
    let fatherNameInput = ref.template.querySelector('lightning-input[data-id=fatherId]');
    let motherNameInput = ref.template.querySelector('lightning-input[data-id=motherId]');
    let emailInput = ref.template.querySelector('lightning-input[data-id=EmailId]');

    let repayLoanInput;

    if (ref.tabData === Borrower) {
        repayLoanInput = ref.template.querySelector('lightning-combobox[data-id=repayLoan]');
    }

    let preffereAddInput = ref.template.querySelector('lightning-combobox[data-id=preferedAddress]');
    let familyMemeberInput = ref.template.querySelector('lightning-combobox[data-id=familyMember]');
    let residenceCountryInput = ref.template.querySelector('lightning-combobox[data-id=residenceCountry]');
    let maritalInput = ref.template.querySelector('lightning-combobox[data-id=maritalStatus]');
    let communicationInput = ref.template.querySelector('lightning-combobox[data-id=communicationId]');
    let qualificationInput = ref.template.querySelector('lightning-combobox[data-id=customerQuali]');

    let relationshipValueInput;

    if (ref.tabData === CoBorrower) {
        relationshipValueInput = ref.template.querySelector('lightning-combobox[data-id=relationWithBorrower]');
    }

    if (!preffereAddInput.value || !familyMemeberInput.value || !residenceCountryInput.value || (ref.tabData === Borrower && !repayLoanInput.value) || !maritalInput.value || !fatherNameInput.value || !motherNameInput.value || !communicationInput.value || !qualificationInput.value || !emailInput.value || (ref.tabData === CoBorrower && !relationshipValueInput.value)) {
        return false;
    }
    return status;
}

export function captureCustomerimageHelper(ref) {
    if (ref.isCancel == false) {
        if(FORM_FACTOR !== 'Large'){
            ref.uploadDisable = false; //ind-2116
            checkUploadDocument({ applicantId: ref.applicantId, docType: ref.uploadDocumentType }).then(result => {
                if(result){
                    ref.kycDeleteHandler(ref.currentAddressFileId, false, true, result);
                }else{
                    ref.showToastMessage(ref.errorTitle, 'Requested document is not present in system.', ref.errorVariant);
                }
            });   
        }else{
            ref.kycDeleteHandler(ref.currentAddressFileId, false, true, ref.documentToDelete);
        }    
        
        if(ref.typeOfAddress === 'CurrentAddress'){
            ref.fetchDocumentCurrentAddress = false;
            ref.captureCurrentAddressFlag = false;
            ref.currentAddressDisable = false;
            ref.currentResidentId = '';
        } else if(ref.typeOfAddress === 'PermanentAddress'){
            ref.fetchDocumentPermanentAddress= false;
            ref.capturePermanentAddressFlag = false;
            ref.permanentAddressDisable = false;
            ref.permanentResidentId= '';
        }
    }

    if(ref.captureCurrentAddressFlag){
        ref.captureCurrentAddressFlag = false;
    }

    if(ref.capturePermanentAddressFlag){
        ref.capturePermanentAddressFlag = false;
    }

    ref.modalPopUpCaptureImage = false;
}

export function handleChange(ref, evt) {
    let name = evt.currentTarget.dataset.id;
    switch (name) {
        case 'salutation':
            ref.demogarphicDataFields.Salutation__c = evt.currentTarget.value;
            break;
        case 'gender':
            ref.demogarphicDataFields.Gender__c = evt.currentTarget.value;
            break;
        case 'category':
            ref.demogarphicDataFields.Category__c = evt.currentTarget.value;
            break;
        case 'employerType':
            ref.demogarphicDataFields.Employer_Type__c = evt.currentTarget.value;
            break;
        case 'dateOfBirth':
            ref.demogarphicDataFields.Date_of_Birth__c = evt.currentTarget.value;
            let currentDate = new Date();
            let dateToCompare = new Date(ref.demogarphicDataFields.Date_of_Birth__c);
            let inputref = ref.template.querySelector('lightning-input[data-id=dateOfBirth]');
            if (dateToCompare > currentDate) {
                inputref.setCustomValidity('Please select valid date');
            } else {
                inputref.setCustomValidity('');
            }
            inputref.reportValidity();
            break;
        case 'isCustomerNRI':
            ref.demogarphicDataFields.Is_Customer_NRI__c = evt.currentTarget.checked;
            break;
        case 'workPermitNo':
            ref.demogarphicDataFields.Work_Permit_No__c = evt.currentTarget.value;
            break;
        case 'permitValidity':
            ref.demogarphicDataFields.Permit_Validity__c = evt.currentTarget.value;
            break;
        case 'workVisaDetails':
            ref.demogarphicDataFields.Work_Visa_Details__c = evt.currentTarget.value;
            break;
        case 'EntityIdentifier':
            ref.demogarphicDataFields.LegalEntityIdentifier__c = evt.currentTarget.value;
            break;
        case 'relationshipWithEntity':
            ref.demogarphicDataFields.Relationship_with_borrower__c = evt.currentTarget.value;
            break;    
        default:
            break;
    }
}

export function saveNomineeDetailsHelper(ref){
    ref.isLoading = true;
    if(ref.openNewBankAccount === true){
        if(checkNomineeDetailValidity(ref)){
            console.log('updateApplicantDetails->'+ref.repayByApplicantId);
            let casaObj = {};
            casaObj[CASA_APPLICANT.fieldApiName] = ref.repayByApplicantId;
            casaObj[CASA_LOAN_APPID.fieldApiName] = ref.recordid;
            casaObj[CASA_OPENED_FOR.fieldApiName] = ref.selectedApplicantType;
            casaObj[CASA_NOMINEE_AVAILABLE_FIELD.fieldApiName] = true;
            casaObj[CASA_NOMINEE_NAME_FIELD.fieldApiName] = ref.nomineeName;
            casaObj[CASA_NOMINEE_DOB_FIELD.fieldApiName] = ref.nomineeDob;
            casaObj[CASA_NOMINEE_ADDRESS_FIELD.fieldApiName] = ref.nomineeAddress;
            casaObj[CASA_NOMINEE_PINCODE_FIELD.fieldApiName] = ref.nomineePincode;
            casaObj[CASA_NOMINEE_CITY_FIELD.fieldApiName] = ref.nomineeCity;
            casaObj[CASA_NOMINEE_FINACLE_CITY_FIELD.fieldApiName] = ref.nomineeCityId;
            casaObj[CASA_NOMINEE_STATE_FIELD.fieldApiName] = ref.nomineeStateId;
            casaObj[CASA_NOMINEE_RELATIONSHIP_FIELD.fieldApiName] = ref.nomineeRelationship;
            if(ref.isNomineeDetailSaved == false){
                ref.isNomineeDetailSaved = true;
                createRecord({ apiName: 'CASA_Bank_Form__c', fields: casaObj }).then(()=>{
                    ref.showToastMessage('Record Created','CASA Created Successfully','success');
                    updateApplicantDetails(ref);
                }).catch(error =>{
                    ref.isNomineeDetailSaved = false;
                    console.log('Error '+JSON.stringify(error));
                    ref.isLoading = false;
                })
            }
        }
    }
}

export function updateApplicantDetails(ref){
    console.log('updateRecordDetails');
    const applicantsFields = {};
    applicantsFields[APP_ID_FIELD.fieldApiName] = ref.repayByApplicantId;
    applicantsFields[WOULD_YOU_LIKE_TO_OPEN_A_BANK_ACCOUNT.fieldApiName] = ref.openNewBankAccount;
    applicantsFields[NOMINEE_AVAILABLE_FIELD.fieldApiName] = true;
    applicantsFields[NOMINEE_NAME_FIELD.fieldApiName] = ref.nomineeName;
    applicantsFields[NOMINEE_DOB_FIELD.fieldApiName] = ref.nomineeDob;
    applicantsFields[NOMINEE_ADDRESS_FIELD.fieldApiName] = ref.nomineeAddress;
    applicantsFields[NOMINEE_PINCODE_FIELD.fieldApiName] = ref.nomineePincode;
    applicantsFields[NOMINEE_CITY_FIELD.fieldApiName] = ref.nomineeCity;
    applicantsFields[NOMINEE_STATE_FIELD.fieldApiName] = ref.nomineeState;
    applicantsFields[NOMINEE_RELATIONSHIP_FIELD.fieldApiName] = ref.nomineeRelationship;
        ref.updateRecordDetails(applicantsFields).then(() => {
            ref.showToastMessage('Data Updated','Nominee detail saved successfully','success');
            let updateApplicant ={};
            updateApplicant[APP_ID_FIELD.fieldApiName] = ref.applicantId;
            updateApplicant[REPAYMENT_WILL_BE_DONE_BY.fieldApiName] = ref.repayLoanValue;
            updateApplicant[WHO_WILL_REPAY_THE_LOAN.fieldApiName] = ref.selectedApplicantType;
            ref.updateRecordDetails(updateApplicant);   
            ref.isLoading = false;
        }).catch((error) => { 
            console.log('Inside Catch'+error);
            ref.isLoading = false;
        });
}

export function nomineeCitylookupHandlerHelper(ref,event){
    const index = event.detail?.index;
        console.log('call apex'+event.detail.selectedValueName);
        ref.nomineeCity = event.detail.selectedValueName;
        ref.nomineeCityId = event.detail.selectedValueId;
    //apex call to get state of selcted city
    getState({FinacalCityCode : event.detail.selectedValueName})
        .then((resp)=>{
            console.log('resp ',resp);
            const result = JSON.parse(resp);
            ref.nomineeState = result.Name;
            ref.nomineeStateId = result.Id;
        }
    )
    .catch((error)=>{
        console.error('in catch',error)} );
    
}

export function nomineeCityClearvaluelookupHandlerHelper(ref){
    // empty the nominee city
    ref.nomineeCity = '';
    ref.nomineeCityId = '';
    // empty the nominee city
    ref.nomineeState = '';
    ref.nomineeStateId = '';
}

export function showToastMessage(ref, title, message, variant) {
    if (title) {
        ref.dispatchEvent(new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        }));
    } else {
        ref.dispatchEvent(new ShowToastEvent({
            message: message,
            variant: variant,
        }));
    }
}

export function showToastMessageModeBased(ref, title, message, variant, mode) {
    if (title) {
        ref.dispatchEvent(new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: mode,
        }));
    } else {
        ref.dispatchEvent(new ShowToastEvent({
            message: message,
            variant: variant,
            mode: mode,
        }));
    }
}


export function checkNomineeDetailValidity(ref){
    try {
        let nomineeName = ref.template.querySelector('lightning-input[data-id="nomineeName"]');
        let nomineeDOB = ref.template.querySelector('lightning-input[data-id="nomineeDOB"]');
        let nomineeAddress = ref.template.querySelector('lightning-input[data-id="nomineeAddress"]');
        let nomineePinCode = ref.template.querySelector('lightning-input[data-id="nomineePinCode"]');
        let nomineeState = ref.template.querySelector('lightning-input[data-id="nomineeState"]');
        let nomineeRelationshipBorrower = ref.template.querySelector('lightning-combobox[data-id="nomineeRelationshipBorrower"]');

        nomineeName.reportValidity();
        nomineeDOB.reportValidity();
        nomineeAddress.reportValidity();
        nomineePinCode.reportValidity();
        nomineeState.reportValidity();
        nomineeRelationshipBorrower.reportValidity();

        if(!ref.nomineeCity){
            const toastevt = new ShowToastEvent({title: 'Please fill nominee city!',variant: 'error', mode:'dismiss'});ref.dispatchEvent(toastevt);
            ref.isLoading = false;
            return false;
        }
        if(nomineeName.validity.valid == true && nomineeDOB.validity.valid == true && nomineeAddress.validity.valid == true && nomineePinCode.validity.valid == true 
        && nomineeState.validity.valid == true && nomineeRelationshipBorrower.validity.valid == true){
            return true;
        }
        else{
        const evt = new ShowToastEvent({title: 'Fill all nominee details!',variant: 'error', mode:'dismiss'});ref.dispatchEvent(evt);
        ref.isLoading = false;
        return false;
        }
    } catch (error) {
        console.log('error->'+error);
        ref.isLoading = false;
        return false;
    }
}

export function validateBorrowerInputs(ref){
    if (ref.tabData === Borrower) {
        let repayLoanInput = ref.template.querySelector('lightning-combobox[data-id=repayLoan]');

        if(repayLoanInput !== null){
            repayLoanInput.reportValidity();

            if(!repayLoanInput.value){
                ref.showToastMessage('', 'Fill all the demographic details', 'warning');
                ref.isLoading = false;
                ref.disableSubmitButton = false;//CISP-2897
                return true;
            }
        }
        if(ref.isWhoWillRepayTheLoanChanged && ref.openNewBankAccount && ref.isTractor){
            if(!checkNomineeDetailValidity(ref)){
                ref.isLoading = false;
                ref.disableSubmitButton = false;
                return true;
            }
            if(!ref.isNomineeDetailSaved && !ref.disableAllNomineeAndRepayField){
                ref.showToastMessage('', 'Please save the nominee details!', 'warning');
                ref.isLoading = false;
                ref.disableSubmitButton = false;
                return true;
            }
        }
        if (ref.emptyFieldCheck('.referenceField1') || ref.isTractor) {
            if (!ref.validityCheck('.referenceField1')) {
                ref.showToastMessage('','Fill all the Reference Field 1 details', 'warning');
                ref.isLoading = false;
                ref.disableSubmitButton = false;
                return true;
            }else{
                [...ref.template.querySelectorAll('.referenceField1')].forEach(inputField => {
                    inputField.required = false;
                    inputField.setCustomValidity("");
                    inputField.reportValidity();
                });
            }
        }else{
            [...ref.template.querySelectorAll('.referenceField1')].forEach(inputField => {
                inputField.required = false;
                inputField.setCustomValidity("");
                inputField.reportValidity();
            });
        }
        if (ref.emptyFieldCheck('.referenceField2') || ref.isTractor) {
            if (!ref.validityCheck('.referenceField2')) {
                ref.showToastMessage('','Fill all the Reference Field 2 details', 'warning');
                ref.isLoading = false;
                ref.disableSubmitButton = false;
                return true;
            }else{
                [...ref.template.querySelectorAll('.referenceField2')].forEach(inputField => {
                    inputField.required = false;
                    inputField.setCustomValidity("");
                    inputField.reportValidity();
                });
            }
        }else{
            [...ref.template.querySelectorAll('.referenceField2')].forEach(inputField => {
                inputField.required = false;
                inputField.setCustomValidity("");
                inputField.reportValidity();
            });
        }
    }
    return false;
}

export function handleSalFun(thisvar,ref) {
    let isSalariedSelected = thisvar.template.querySelector('[data-id="salaried"]');
    isSalariedSelected.checked = ref;
    let isSelfEmployedSelected = thisvar.template.querySelector('[data-id="selfEmployed"]');
    isSelfEmployedSelected.checked = false;thisvar.profile = '';thisvar.profileId = '';
    // CISP-2752-START
    if(isSalariedSelected?.checked){isSelfEmployedSelected.disabled = true;isSelfEmployedSelected?.reportValidity();isSalariedSelected?.reportValidity();
    }else{isSelfEmployedSelected.disabled = false}
    // CISP-2752-END
    if (isSalariedSelected.checked) {
        thisvar.ischeckBoxDisabled = true;
        thisvar.isSalaried = true;
        thisvar.isSelfEmployed = false;
        thisvar.isShowSaleriedNonSalired = true;
        thisvar.isprofileSelected = true;
        if(thisvar.isTractor){
            processProfileDropdown('SENP',thisvar);
        }else {
            processProfileDropdown('SAL',thisvar);
        }
        
    } else if (!isSalariedSelected.checked) {thisvar.profile='';thisvar.bsrOccupation='';thisvar.isprofileSelected = false;
        thisvar.isShowSaleriedNonSalired = false;
        thisvar.isSalaried = false;
        thisvar.isSelfEmployed = false;
        processProfileDropdown('SAL',thisvar);
    }
    return false;
}
export function processProfileDropdown(categoryData,thisvar) {
    thisvar.isLoading = true;
    let profileArray = [];
    getProfile({ category: categoryData }).then(response => {
            if (response && response.length > 0) {
                for (let index = 0; index < response.length; index++) {
                    if(thisvar.isTractor && response[index].Name == 'AGRICULTURIST') {
                        thisvar.profile = response[index].Name;
                        thisvar.profileId = response[index].Id;
                    }
                    let profileData = {};
                    profileData.value = response[index].Name;
                    profileData.label = response[index].Name;
                    profileData.id = response[index].Id;
                    profileData.code = response[index].Code__c;
                    profileData.category = response[index].Category__c;
                    profileArray.push(profileData);
                }
                thisvar.profileValuesData = profileArray;
            }thisvar.isLoading = false;
        }).catch(error => { thisvar.isLoading = false; });
}
export function handleSelfFun(thisvar,ref){
    let isSelfEmployedSelected = thisvar.template.querySelector('[data-id="selfEmployed"]');
    isSelfEmployedSelected.checked = ref;
    let isSalariedSelected = thisvar.template.querySelector('[data-id="salaried"]');
    isSalariedSelected.checked = false;thisvar.profile = '';thisvar.profileId = '';
    //CISP-2752-START
    if(isSelfEmployedSelected?.checked){isSalariedSelected.disabled = true;isSelfEmployedSelected?.reportValidity();isSalariedSelected?.reportValidity();
    }else{isSalariedSelected.disabled = false;}
    // CISP-2752-END
    if (isSelfEmployedSelected.checked) {
        thisvar.ischeckBoxDisabled = false ; thisvar.isprofileSelected = true; thisvar.isSalaried = false;thisvar.isSelfEmployed = true;thisvar.isShowSaleriedNonSalired = true;processProfileDropdown('SEP/SENP',thisvar);
    } else if (!isSelfEmployedSelected.checked) {thisvar.profile='';thisvar.bsrOccupation='';
        thisvar.isShowSaleriedNonSalired = false;
        thisvar.isSalaried = false;
        thisvar.isSelfEmployed = false;
        thisvar.profileValuesData = [];thisvar.isprofileSelected = false;
    }
}

export async function crossCoreHelper(thisvar){
    let isAPISuccess = true;
    // let isMatchFound = false;
    // let beneficiaryIdList =[];
    // try{
    //     let applicantMapResponse = await getApplicantMap({ 'loanApplicationId': thisvar.recordid});
    //     if(applicantMapResponse){
    //         beneficiaryIdList = applicantMapResponse.beneficiaryId;
    //     }
    //     let hunterResponse = await getHunterResponse({'loanApplicationId' : thisvar.recordid});
    //     if(hunterResponse && hunterResponse.isHunterResponseOk === 'OK'){
    //         isAPISuccess = true;
    //     }else if(hunterResponse && hunterResponse?.isHunterMatchResponse == 'Match'){
    //         thisvar.showToastMessage('Success!', 'Match found. Decisioning is pending!', 'warning');
    //         isAPISuccess = true;
    //     }else if(hunterResponse && hunterResponse?.isHunterMatchResponse == 'No Match'){
    //         thisvar.showToastMessage('Success!', 'Crosscore API is successfully invoked. There is not match found!', 'success');
    //         isAPISuccess = true;
    //     }else{
    //         if(!thisvar.isNonIndividual){
    //             let result = await crosscoreAPICallout({'loanApplicationId' : thisvar.recordid ,'beneficiaryId': beneficiaryIdList,'batchIndex':''});
    //             if(result){
    //                 const response = JSON.parse(result);
    //                 if(response && response?.clientResponsePayload?.decisionElements?.length > 0 && response?.clientResponsePayload?.decisionElements[0] && response?.clientResponsePayload?.decisionElements[0].otherData?.response?.errorWarnings?.errors?.errorCount == 0){
    //                     if(response && response?.clientResponsePayload?.decisionElements?.length > 0 && response?.clientResponsePayload?.decisionElements[0] && response?.clientResponsePayload?.decisionElements[0].otherData?.response?.matchSummary?.matches > 0){
    //                         thisvar.showToastMessage('Warning!', 'Match found. Decisioning is pending!', 'warning');
    //                         const fields = {};
    //                         fields[oppId.fieldApiName] = thisvar.recordid;
    //                         fields['Hunter_Match_Status__c'] = 'Match';
    //                         const recordInput = { fields };
    //                         await updateRecord(recordInput);
    //                         isAPISuccess = true;
    //                     }else if(response && response?.clientResponsePayload?.decisionElements?.length > 0 && response?.clientResponsePayload?.decisionElements[0] && response?.clientResponsePayload?.decisionElements[0].otherData?.response?.matchSummary?.matches == 0){
    //                         thisvar.showToastMessage('Success!', 'Crosscore API is successfully invoked. There is not match found!', 'success');
    //                         const fields = {};
    //                         fields[oppId.fieldApiName] = thisvar.recordid;
    //                         fields['Hunter_Match_Status__c'] = 'No Match';
    //                         const recordInput = { fields };
    //                         await updateRecord(recordInput);
    //                         isAPISuccess = true;
    //                     }
    //                 } else {
    //                     thisvar.showToastMessage('Error!', 'Crosscore API callout has failed.', 'error');
    //                     isAPISuccess = true;
    //                 }
    //             }else {
    //                 thisvar.showToastMessage('Error!', 'Crosscore API callout has failed.' ,'error');
    //                 isAPISuccess = true;
    //             }
    //         }else{
    //             let batch = 3;
    //             let counter = 0
    //             for (let i = 0; i < beneficiaryIdList.length; i += batch) {
    //                 let batchOfIds =[];
    //                 batchOfIds = beneficiaryIdList.slice(i, i + batch);
    //                 let batchIndex = counter + 1;
    //                 counter ++;
    //                 let result = await crosscoreAPICallout({ 'loanApplicationId': thisvar.recordid, 'beneficiaryId': batchOfIds ,'batchIndex': batchIndex.toString()});
    //                 if (result) {
    //                     const response = JSON.parse(result);
    //                     if (response && response?.clientResponsePayload?.decisionElements?.length > 0 && response?.clientResponsePayload?.decisionElements[0] && response?.clientResponsePayload?.decisionElements[0].otherData?.response?.errorWarnings?.errors?.errorCount == 0) {
    //                         if (response && response?.clientResponsePayload?.decisionElements?.length > 0 && response?.clientResponsePayload?.decisionElements[0] && response?.clientResponsePayload?.decisionElements[0].otherData?.response?.matchSummary?.matches > 0) {
    //                             isMatchFound = true;
    //                             isAPISuccess = true;
    //                         } else if (response && response?.clientResponsePayload?.decisionElements?.length > 0 && response?.clientResponsePayload?.decisionElements[0] && response?.clientResponsePayload?.decisionElements[0].otherData?.response?.matchSummary?.matches == 0) {
    //                             isAPISuccess = true;
    //                         }
    //                     } else {
    //                         isAPISuccess = true;
    //                     }
    //                 } else {
    //                     isAPISuccess = true;
    //                 }
    //             }
    //             if(isMatchFound){
    //                 const fields = {};
    //                 fields[oppId.fieldApiName] = thisvar.recordid;
    //                 fields['Hunter_Match_Status__c'] = 'Match';
    //                 const recordInput = { fields };
    //                 await updateRecord(recordInput);
    //             }else{
    //                 const fields = {};
    //                 fields[oppId.fieldApiName] = thisvar.recordid;
    //                 fields['Hunter_Match_Status__c'] = 'No Match';
    //                 const recordInput = { fields };
    //                 await updateRecord(recordInput);
    //             }
    //             if(isAPISuccess){
    //                 thisvar.showToastMessage('Success!', 'Crosscore API is successfully invoked. There is not match found!', 'success');
    //             }else{
    //                 thisvar.showToastMessage('Error!', 'Crosscore API callout has failed.', 'error');
    //             }
    //         }
    //     }
    // }catch(error){
    //     thisvar.showToastMessage('Error!', 'Something went wrong!' ,'error');
    //     isAPISuccess = true;
    // }
    return isAPISuccess;
}

export async function willingValidation(ref){
    let result = await isNewApplicant({'applicantId' : ref.repayLoanValue})
    let ele = ref.template.querySelector('[data-id="toggle3"]');
    if(ele && !ele.checked && result){
        ref.showToastMessage('Repayer does not have a bank account. Please select Would you like to open a bank account with IBL?','','Warning');
        ref.isLoading = false;
        ref.disableSubmitButton = false;
        return false;
    }
    return true;
}

export function loadDocTypeHelper(ref){
    let docTypeOptionsList = [];
        if(ref.isNotNonIndividualTractorBorrower){
        docTypeOptionsList = [{ label: "Electricity Bill (within 3 months)",value: "Electronic Bill"},{label:"Water Bill",value:"Water Bill"},{label:"Govt letter of accommodation allotment",value:"Govt letter of accommodation allotment"},{label:"Govt pension payment order",value:"Govt pension payment order"},{label:"Property or municipal tax receipt",value:"Property or municipal tax receipt"},{label:"Gas bill",value:"Gas bill"},{label:"Post paid mobile bill",value:"Post paid mobile bill"},{label:"Telephone bill",value:"Telephone bill"}];} else{
       // docTypeOptionsList = [{ label: "PARTNERSHIP DEED",value: "PARTNERSHIP DEED"},{label:"PARTNERSHIP REGISTRATION CERT",value:"PARTNERSHIP REGISTRATION CERT"},{label:"MEMORANDUM OF ASSOCIATION",value:"MEMORANDUM OF ASSOCIATION"},{label:"ARTICLES OF ASSOCIATION",value:"ARTICLES OF ASSOCIATION"},{label:"CERTIFICATE OF COMMENCEMENT OF BUSINESS",value:"CERTIFICATE OF COMMENCEMENT OF BUSINESS"},{label:"CERTIFICATE OF INCORPORATION",value:"CERTIFICATE OF INCORPORATION"},{label:"TRUST DEED",value:"TRUST DEED"},{label:"SHOPS & ESTABLISHMENT CERTIFICATE",value:"SHOPS & ESTABLISHMENT CERTIFICATE"},{label:"UDYAM REGISTRATION CERTIFICATE",value:"UDYAM REGISTRATION CERTIFICATE"},{label:"SALES TAX REGISTRATION CERTIFICATE",value:"SALES TAX REGISTRATION CERTIFICATE"},{label:"MSME REGISTRATION CERTIFICATE",value:"MSME REGISTRATION CERTIFICATE"},{label:"UDYOG AADHAAR REG CERTIFICATE",value:"UDYOG AADHAAR REG CERTIFICATE"},{label:"Utility bill in the name of company",value:"Utility bill in the name of company"}];
       docTypeOptionsList = [{label:"MSME REGISTRATION CERTIFICATE",value:"MSME REGISTRATION CERTIFICATE"},{label:"UDYAM REGISTRATION CERTIFICATE",value:"UDYAM REGISTRATION CERTIFICATE"},{label:"REGISTRATION CERTIFICATE (ANY)",value:"REGISTRATION CERTIFICATE - OTHERS"},{label:"SHOPS AND ESTABLISHMENT CERTIFICATE",value:"SHOPS AND ESTABLISHMENT CERTIFICATE"},{label:"TAX/SERVICE TAX/PROFESSIONAL TAX AUTH",value:"TAX/SERVICE TAX/PROFESSIONAL TAX AUTH"},{label:"FACTORY REGISTRATION CERTIFICATE",value:"FACTORY REGISTRATION CERTIFICATE"},{label:"CERTIFICATE ISSUED BY STATE/CENTRAL/LOCAL AUTHORITIES",value:"CERTIFICATE ISSUED BY STATE/CENTRAL/LOCAL AUTHORITIES"},{label:"TRADE LICENCE",value:"TRADE LICENCE"},{label:"IMPORT AND EXPORT CERTIFICATE",value:"IMPORT AND EXPORT CERTIFICATE"}] 
        if(!ref.isGSTUploaded){
            docTypeOptionsList.push({label:"GST CERTIFICATE",value:"GST CERTIFICATE"});
        }
        }
        if(ref.currentdocumentType === null || ref.currentdocumentType === undefined || ref.currentdocumentType === '') {if(ref.isNonIndividual){docTypeOptionsList.push({label:"Utility bill in the name of company",value:"Utility bill in the name of company"});
        ref.currentDocTypeOptionsList = docTypeOptionsList;
    } else{ref.currentDocTypeOptionsList = docTypeOptionsList;}}
        if(ref.permanentDocumentType === null || ref.permanentDocumentType === undefined || ref.permanentDocumentType === '') {ref.permanentDocTypeOptionsList = docTypeOptionsList;}
}

export function resiCumOfficeHandler(event,ref){
    if (!ref.validityCheck('.permanentAddress') || !ref.perTalukaValue || !ref.perTalukaId) {
        ref.showToastMessage('Warning', 'Fill all the details', 'warning');
        ref.isResiCumOfficeAddress = false;
        let resiCumOfficeEle = ref.template.querySelector('lightning-input[data-id=resiCumOfficeAddId]');
        if(resiCumOfficeEle){resiCumOfficeEle.checked=false;}
        return;
    }
    if(ref.currentTractorFieldDisable == true){
        ref.showToastMessage('Warning', 'Current address already submitted!', 'warning');
        ref.isResiCumOfficeAddress = false;
        let resiCumOfficeEle = ref.template.querySelector('lightning-input[data-id=resiCumOfficeAddId]');
        if(resiCumOfficeEle){resiCumOfficeEle.checked=false;}
        return;
    }
    ref.isResiCumOfficeAddress = event.currentTarget.checked;
    if (event.currentTarget.checked) {  
        let documentTypes = [];
        ref.permanentDocTypeOptionsList.forEach(node=>{
            documentTypes.push({label: node.label, value: node.value}); 
        });
        documentTypes.push({label:ref.permanentDocumentType, value:ref.permanentDocumentType});
        ref.currentDocTypeOptionsList = documentTypes;
        ref.talukaValue = ref.permanentTalukaValue;
        ref.districtValue = ref.permanentDistrictValue;
        ref.cityValue  = ref.permanentCityValue;
        ref.currentAddressData.KYC_Address_Line_1__c = ref.permanentAddressData.KYC_Address_Line_1__c;
        ref.currentAddressData.KYC_Address_Line_2__c = ref.permanentAddressData.KYC_Address_Line_2__c;
        ref.currentAddressData.KYC_State__c = ref.permanentAddressData.KYC_State__c;
        ref.currentAddressData.KYC_District__c = ref.permanentAddressData.KYC_District__c;
        ref.currentAddressData.KYC_City__c = ref.permanentAddressData.KYC_City__c;
        ref.currentAddressData.KYC_Pin_Code__c = ref.permanentAddressData.KYC_Pin_Code__c;
        ref.currentVillage = ref.permanentVillageData;
        ref.currentTalukaData = ref.permanentTaluka;
        ref.currentlandmarkData = ref.permanentLandmark;
        ref.currentdocumentType = ref.permanentDocumentType;
        ref.disableCurrentAddressTractor = true;
        ref.currentAddressDisable = true;
        ref.disableCurrentAddressProof = true;
        ref.stateCityDistrictDisable = true;
        ref.curTalukaValue = ref.perTalukaValue;
        ref.curTalukaId = ref.perTalukaId;
        ref.isTalukaCurValueSelected = true;
    }else{
        let documentTypes = [];
        ref.permanentDocTypeOptionsList.forEach(node=>{
            ref.currentDocTypeOptionsList.forEach(ele=>{
                if(ele.value != node.value){
                    documentTypes.push(ele);
                }
            })
        });
        ref.currentDocTypeOptionsList = documentTypes;
        ref.talukaValue = [];
        ref.districtValue = [];
        ref.cityValue  = [];
        ref.currentAddressData.KYC_Address_Line_1__c = '';
        ref.currentAddressData.KYC_Address_Line_2__c = '';
        ref.currentAddressData.KYC_State__c = '';
        ref.currentAddressData.KYC_District__c = '';
        ref.currentAddressData.KYC_City__c = '';
        ref.currentAddressData.KYC_Pin_Code__c = '';
        ref.currentVillage = '';
        ref.currentTalukaData = '';
        ref.currentlandmarkData = '';
        ref.currentdocumentType = '';
        ref.disableCurrentAddressTractor = false;
        ref.currentAddressDisable = false;
        ref.disableCurrentAddressProof = false;
        ref.stateCityDistrictDisable = false;
        ref.curTalukaValue = '';
        ref.curTalukaId = '';
        ref.isTalukaCurValueSelected = false;
    }
}

export function permanentHandler(event,ref){
    if(event.target.value && ref.currentdocumentType && event.target.value == ref.currentdocumentType && !ref.isNotNonIndividualTractorBorrower){
        ref.showToastMessage('', `Office address type can't be same as current address `, 'warning');
        ref.permanentDocumentType = '';
        return;
    }
    ref.permanentDocumentType = event.target.value;
    ref.uploadDocumentType = ref.permanentDocumentType;
    ref.permanentAddressData.uploadDocumentType = event.target.value;
    if (ref.permanentDocumentType) {
        ref.permanentDocTypeOptions.forEach((obj) => {
            if (obj.value === ref.permanentDocumentType) {
                ref.otherKYCDocName = obj.label;
            }
        });
    }
}
export function currentHandler(event,ref){
    if(event.target.value && ref.permanentDocumentType && event.target.value == ref.permanentDocumentType && !ref.isNotNonIndividualTractorBorrower){
        ref.showToastMessage('', `Current address type can't be same as office address `, 'warning');
        ref.currentdocumentType = '';
        return;
    }
    ref.currentdocumentType = event.target.value;
    ref.uploadDocumentType = ref.currentdocumentType;
    ref.currentAddressData.uploadDocumentType = event.target.value;
    if (ref.currentdocumentType) {
        ref.currentDocTypeOptions.forEach((obj) => {
            if (obj.value === ref.currentdocumentType) {
                ref.otherKYCDocName = obj.label;
            }
        });
    }
}
//SFTRAC-724
export function handlePropriorBusinessEntityType(ref){
    if(!ref.isNotNonIndividualTractorBorrower){
        if(ref.nonIndividualEntityType == 'Business Entities Created by Statute' || ref.nonIndividualEntityType == 'Proprietorship'){
            ref.isPropriorBusinessEntityType = true;
            ref.isGetCRIFFButton = ref.criffInitiated == true ? false : true;
            ref.isDisableGetCRIFFButton = ref.criffInitiated;                       
            ref.isDisableViewCRIFFButton = ref.cRIFFURL == undefined || ref.cRIFFURL == '' ? true: false;
        }else{
            ref.isPropriorBusinessEntityType = false;
            ref.isDisableGetCRIFFButton = true;
            
        }
    }
}

//SFTRAC-724
export function handlegetCRIFFReport(ref){
    ref.isSpinnerMoving = true;
    cRIFFAPICall({loanAppId: ref.recordid, applicantId: ref.applicantId}).then(result =>{
        ref.isSpinnerMoving = false;
        if(result =='Success'){
            const evt = new ShowToastEvent({title: 'Success',message: 'CRIF report request initiation has been submitted.', variant: 'Success',});ref.dispatchEvent(evt); 
            ref.isGetCRIFFButton = false;
            ref.isDisableViewCRIFFButton = true;
            ref.isDisableGetCRIFFButton = true;
        }else if (result =='Error' || result == ''){
            const evt = new ShowToastEvent({title: 'Error',message: 'CRIF report request initiation not submitted, Check with Admin', variant: 'Error',});ref.dispatchEvent(evt); 
            ref.isGetCRIFFButton = true;
            ref.isDisableViewCRIFFButton = false;
            ref.isDisableGetCRIFFButton = false;
        }
        }).catch(error => {
            console.log(' cRIFFAPICall error:- ' + error.body.message);
            ref.isSpinnerMoving = false;
            ref.isGetCRIFFButton = true;
            ref.isDisableViewCRIFFButton = false;
            ref.isDisableGetCRIFFButton = false;
            const evt = new ShowToastEvent({title: 'Error',message: error.body.message, variant: 'error',});ref.dispatchEvent(evt);       
        });

}

export function onChangeHandlerHelper(event,ref){
    if (event.target.dataset.id == 'CurrentVillageDataId') {
        ref.currentVillage = event.target.value;
    } else if (event.target.dataset.id == 'kycTalukaDataId') {
        ref.currentTalukaData = event.target.value;
    } else if (event.target.dataset.id == 'LandmarkDataId') {
        ref.currentlandmarkData = event.target.value;
    } else if (event.target.dataset.id == 'PermanentVillageDataId') {
        ref.permanentVillageData = event.target.value;
    } else if (event.target.dataset.id == 'ParmanentTalukaDataId') {
        ref.permanentTaluka = event.target.value;
    } else if (event.target.dataset.id == 'parmanentLandmarkDataId') {
        ref.permanentLandmark = event.target.value;
    }
}

//SFTRAC-1178
export async function handlePincodeBasedSearchCallout(ref){
    let valid = false;
    let pincode = ref.currentAddressData.KYC_Pin_Code__c;
    // Retry logic for up to 3 times
    if (ref.retryCountForPincodeBaseSearch < 3) {
        if (pincode && pincode.length == 6) {
            try{
                let result = await doPincodeBasedSearchCallout({
                    pincode: pincode,
                    loanAppId: ref.recordid,
                    applicantId: ref.applicantId
                });
                    if (result == 'SUCCESS') {
                        ref.showToastMessage('Success', 'Customer Reference Successfully Created', 'success');
                        ref.referenceCustomerAvailable = true;
                        valid = true;
                    } else {
                        ref.retryCountForPincodeBaseSearch++;
                        ref.showToastMessage('Error', result, 'error');
                        if (ref.retryCountForPincodeBaseSearch >= 3){
                            valid = true;
                        }
                    }
            }catch(error){
                ref.showToastMessage('Error', error.body.message, 'error');
                ref.retryCountForPincodeBaseSearch++;
                if (ref.retryCountForPincodeBaseSearch >= 3){
                    valid = true;
                }
            }
        } else {
            ref.retryCountForPincodeBaseSearch++;
            ref.showToastMessage('Info', 'Pincode is either incorrect or not present', 'info');
            valid = false;
        }   
    }else{
        valid = true;
    }
    return valid;
}
export async function getDemographicDetailss(ref){
    await getDemographicDetails({ opportunityId: ref.recordid, applicantType: ref.tabData, 'applicantId' : ref.currentTabId }).then(response => {
        if (response) {
            ref.demogarphicDataFields = response.applicantRecord;
            ref.Addressvalue = ref.demogarphicDataFields?.Preferred_address_for_communication__c;
            ref.familyMemberValue = ref.demogarphicDataFields?.of_family_members_residing_with_you__c;
            ref.countryValue = ref.demogarphicDataFields?.Residence_country__c;
            ref.relationshipValue = ref.demogarphicDataFields?.Relationship_with_borrower__c;
            ref.maritalStatusValue = ref.demogarphicDataFields?.Marital_status__c;
            ref.spouseNameValue = ref.demogarphicDataFields?.Spouse_Name__c;
            ref.fatherNameValue = ref.demogarphicDataFields?.Father_s_name__c;
            ref.repaymentWillBeDoneBy = ref.demogarphicDataFields?.Repayment_Will_Be_Done_By__c;
            ref.motherNameValue = ref.demogarphicDataFields?.Mother_s_name__c;
            ref.communicationValue = ref.demogarphicDataFields?.Communication_language__c;
            ref.qualificationValue = ref.demogarphicDataFields?.Customer_Qualification__c;
            ref.emailValue = ref.demogarphicDataFields?.Email_Id__c;
            ref.contactNumber = ref.demogarphicDataFields?.Contact_number__c;
            ref.incomeSource = ref.demogarphicDataFields?.Income_source_available__c;
            ref.isAdditionalDetailsSubmitted = ref.demogarphicDataFields?.Is_Additional_Details_Submitted__c;
            if(ref.isAdditionalDetailsSubmitted && !ref.isTractor){
                ref.disableSubmitButton=true;
                ref.disableNext=false;
                ref.disableRiskBand=false;
            }
            ref.leadSource = ref.demogarphicDataFields?.Opportunity__r.LeadSource;//Ola Integration changes
            ref.oppStageName = ref.demogarphicDataFields?.Opportunity__r.StageName;;//CISH-65
            if(ref.oppStageName === 'Additional Details' && !ref.isTractor){
                ref.isEnableNext = true;
            }
            ref.religionValue = ref.demogarphicDataFields?.Religion__c;
            ref.casteValue = ref.demogarphicDataFields?.Caste__c;
            ref.profileValue = ref.demogarphicDataFields?.Profile__c;
            if(ref.isTractor){
                ref.isSelfEmployed = ref.demogarphicDataFields?.Salaried_Self_employed__c == 'Self employed' ? true : false;
                ref.isSalaried = ref.demogarphicDataFields?.Salaried_Self_employed__c == 'Salaried' ? true : false;
                ref.isShowSaleriedNonSalired = true;
                ref.bsrOccupation = '95012';
            }
            ref.doYouHaveBankAccountWithIBL = ref.demogarphicDataFields?.Do_you_have_a_bank_account_with_IBL__c;
            ref.coborrowerResideWithBorrower = ref.demogarphicDataFields?.Co_Borrower_Reside_with_borrower__c;
            if (ref.tabData === Borrower) {
                ref.repayLoanValue = ref.isTractor ? ref.demogarphicDataFields?.Repayment_Will_Be_Done_By__c: ref.demogarphicDataFields?.Who_will_repay_the_loan__c;
                ref.selectedApplicantType = ref.demogarphicDataFields?.Who_will_repay_the_loan__c;
                ref.nameRef1Value = ref.demogarphicDataFields?.Name_Ref_1__c;
                ref.relationRef1Value = ref.demogarphicDataFields?.Relationship_with_Borrower_Ref_1__c;
                ref.addressLine1Ref1Value = ref.demogarphicDataFields?.Address_Line_1_Ref_1__c;
                ref.addressLine2Ref1Value = ref.demogarphicDataFields?.Address_Line_2_Ref_1__c;
                ref.stateRef1Value = ref.demogarphicDataFields?.State_Ref_1__c;
                ref.districtRef1Value = ref.demogarphicDataFields?.District_Ref_1__c;
                ref.cityRef1Value = ref.demogarphicDataFields?.City_Ref_1__c;
                ref.pincodeRef1Value = ref.demogarphicDataFields?.Pincode_Ref_1__c;
                ref.phoneNumberRef1Value = ref.demogarphicDataFields?.Phone_Number_Ref_1__c;
                ref.nameRef2Value = ref.demogarphicDataFields?.Name_Ref_2__c;
                ref.relationRef2Value = ref.demogarphicDataFields?.Relationship_with_Borrower_Ref_2__c;
                ref.addressLine1Ref2Value = ref.demogarphicDataFields?.Address_Line_1_Ref_2__c;
                ref.addressLine2Ref2Value = ref.demogarphicDataFields?.Address_Line_2_Ref_2__c;
                ref.stateRef2Value = ref.demogarphicDataFields?.State_Ref_2__c;
                ref.districtRef2Value = ref.demogarphicDataFields?.District_Ref_2__c;
                ref.cityRef2Value = ref.demogarphicDataFields?.City_Ref_2__c;
                ref.pincodeRef2Value = ref.demogarphicDataFields?.Pincode_Ref_2__c;
                ref.phoneNumberRef2Value = ref.demogarphicDataFields?.Phone_Number_Ref_2__c;
                ref.feedbackRef2Value = ref.demogarphicDataFields ?.Feedback_Ref_2__c;
                ref.feedbackRef1Value = ref.demogarphicDataFields ?.Feedback_Ref_1__c;
            }
            if(ref.demogarphicDataFields.Is_Email_Valid__c){
                ref.isEmailVerified = true;
                ref.isEmailVerifiedTick = true;
                ref.isEmailVerifiedCross = false;
                ref.isEmailVerifiedDisabled = true;
                ref.demographiEmailFieldsDisable = true;
            } else if (ref.demogarphicDataFields.Email_Fail_Count__c >= 3) {
                ref.isEmailVerified = true;
                ref.isEmailVerifiedCross = true;
                ref.isEmailVerifiedTick = false;
                ref.isEmailVerifiedDisabled = true;
                ref.demographiEmailFieldsDisable = true;
            }
            if(ref.isAdditionalDetailsSubmitted && (ref.oppStageName !== 'Additional Details' || ref.isTractor)){
                ref.demographiFieldsDisable = true;
                ref.submitGreenTickButton = true;
                if(ref.oppStageName !== 'Additional Details'){
                    ref.disableSubmitButton = true;
                }
                ref.disableRiskBand = false
                if(ref.isTractorFinance){
                   ref.demographiEmailFieldsDisable = true;
                   ref.disableMaritalStatus = true;
                   ref.demographiSpouseieldsDisable = true;
                }
            }
        } else {
            if (response != null && response.applicantRecord) {
                ref.incomeSource = response.applicantRecord.Income_source_available__c;
            }
        }
    }).catch(error => {
        ref.isLoading = false;
        ref.showToastMessage('','Error in Demographic details', 'error');
    });
}
export async function callBREScoreCardAPI(ref,evt){
    let applicantId;
        if(ref.riskBand){
            ref.template.querySelector("c-view-risk-band").openModal();
            ref.isLoading = false;
        }else if(ref.oppStageName === 'Additional Details'){
            ref.isLoading=true;
            if(ref.tabData === 'Borrower'){
                applicantId=ref.currentTabId;
            }else{
                applicantId=ref.currentTabId;
            }
        console.log('applicantId__'+applicantId);
        await checkRetryExhausted({
            loanApplicationId: ref.recordid, attemptFor: 'Risk Band', applicantId: applicantId
        }).then(response => {
            if (response === ref.label.FailureMessage){
                const toastevt = new ShowToastEvent({title: 'Kindly Retry',variant: 'error', mode:'dismiss'});ref.dispatchEvent(toastevt);
                ref.isLoading = false;
            } else if (response === ref.label.Retry_Exhausted){
                const toastevt = new ShowToastEvent({title: 'Retry Exhausted, Please click Next button',variant: 'error', mode:'dismiss'});ref.dispatchEvent(toastevt);
                ref.isLoading = false;
            }else if (response === ref.label.SuccessMessage){
                 doBREscoreCardCallout({'applicantId' :applicantId, 'loanAppId' : ref.recordid})
                .then(result=>{
                    ref.isLoading = false; console.log('done 1'); const response = JSON.parse(result); const applicantsFields = {}; applicantsFields[APP_ID_FIELD.fieldApiName] = applicantId; applicantsFields[ScoreCard_Description__c.fieldApiName] = response.BRE_Decision_Desc; applicantsFields[Scorecard_Decision__c.fieldApiName] = response.BRE_Decision; ref.riskBand = response.BRE_Decision;ref.template.querySelector("c-view-risk-band").openModal(); ref.updateRecordDetails(applicantsFields, false); 
                    const toastevt = new ShowToastEvent({title: ref.label.Score_Card_Passed,variant: 'success', mode:'dismiss'});ref.dispatchEvent(toastevt);
                    if(response.BRE_Decision.toLowerCase() === 'Red'.toLowerCase() && ref.productType !== 'Passenger Vehicles'){
                        if(ref.tabData === 'Borrower'){
                            const oppFields ={};
                            oppFields[OPP_ID_FIELD.fieldApiName] = ref.recordid;
                            oppFields[OPP_JOURNEY_STATUS.fieldApiName] = 'STOP';
                            ref.cardMsg = 'The Score Card decision of the Borrower ('+ref.borrowerName+') is Red. Hence Journey cannot proceed.';
                            oppFields[JOURNEY_STOP_REASON.fieldApiName] = ref.cardMsg;
                            oppFields[JOURNEY_STOP_SCENARIO_FOUND.fieldApiName] = true;
                            ref.showCardMsg = true;
                            ref.updateRecordDetails(oppFields,false);
                            const myEvent=new CustomEvent('showcardmsg',{
                                detail: {value:ref.cardMsg}
                            });
                            ref.dispatchEvent(myEvent);
                        }else{
                            const oppFields ={};
                            oppFields[OPP_ID_FIELD.fieldApiName] = ref.recordid;
                            oppFields[OPP_JOURNEY_STATUS.fieldApiName] = 'STOP';
                            ref.cardMsg = 'The Score Card decision of the Co-Borrower ('+ref.coBorrowerName+') is Red; hence, journey has stopped. Please withdraw this Lead and create a new lead with only Borrower or by adding a different Co-Borrower';
                            oppFields[JOURNEY_STOP_REASON.fieldApiName] = ref.cardMsg;
                            oppFields[JOURNEY_STOP_SCENARIO_FOUND.fieldApiName] = true;
                            ref.showCardMsg = true;
                            ref.updateRecordDetails(oppFields,false);
                            const myEvent=new CustomEvent('showcardmsg',{
                                detail: {value:ref.cardMsg}
                            });
                            ref.dispatchEvent(myEvent);
                        }
                    }
                })
                .catch(error => {
                    ref.showToastMessage(ref.label.Score_Card_failed_Please_Re_Trigger,'','error');console.log('error in Scorecard API', error);ref.isLoading = false;ref.retryPopUp = true;
                });
            }
        }).catch(error => {
            const evt = new ShowToastEvent({
                title: 'Kindly Retry',
                variant: 'error',
            });
            ref.dispatchEvent(evt);
            ref.isLoading = false;
        });
        }
}
export async function nomineeCitylookupHandlerForCur(ref,evt){
    ref.curFinaclCity = evt.detail.selectedValueName;
    ref.curFinaclCityId = evt.detail.selectedValueId;
    if (ref.sameDocPresent) {
        ref.isPermanentValueSelected = true;
        ref.perFinaclCity = evt.detail.selectedValueName
    }
}

export async function nomineeCitylookupHandlerForPer(ref,evt){
    ref.perFinaclCity = evt.detail.selectedValueName;
    ref.perFinaclCityId = evt.detail.selectedValueId;
    if (ref.sameDocPresent) {
        ref.isCurCitySelected = true;
        ref.curFinaclCity = evt.detail.selectedValueName
    }
}

export async function fatherHandlerHelper(ref,evt){
    try {
        ref.fatherNameValue = evt.target.value;
        let fatherNameInput = ref.template.querySelector('lightning-input[data-id=fatherId]');
        if (ref.fatherNameValue.length > 26) {
            fatherNameInput.setCustomValidity(ref.label.lastNameError);
        } else {
            fatherNameInput.setCustomValidity("");
        }
        fatherNameInput.reportValidity();
    } catch (error) {
    }
}
export async function callAccessLoanApplicationHelper(ref){
    accessLoanApplication({ loanId: ref.recordid , stage: 'Additional Details'}).then(response => {
        if(!response ){ 
            ref.disableEverything();
            if(ref.checkleadaccess){
                const evt = new ShowToastEvent({
                    title: ReadOnlyLeadAccess,
                    variant: 'warning',
                    mode: 'sticky'
                });
                ref.dispatchEvent(evt);
                ref.disableEverything();
            }
        }
      }).catch(error => {
      });

}
/*SFTRAC-1660 Start*/
export async function talukalookupHandlerForCurHelper(ref,evt){
    console.log('++++++talukalookupHandlerForCur State '+ref.stateValue+' T '+ref.curTalukaValue);
    ref.curTalukaValue = evt.detail.selectedValueName;
    ref.curTalukaId = evt.detail.selectedValueId;
    if (ref.sameDocPresent) {
        ref.isTalukaPerValueSelected = true;
        ref.perTalukaValue = evt.detail.selectedValueName
    }
}

export async function talukaClearvaluelookupHandlerForCurHelper(ref,evt){
    console.log('++++++talukaClearvaluelookupHandlerForCurHelper');
    ref.curTalukaValue = ''; 
    ref.curTalukaId = '';
    if(ref.sameDocPresent){
        ref.isTalukaPerValueSelected = false;
        ref.perTalukaValue ='' 
    }
}

export async function talukalookupHandlerForPerHelper(ref,evt){
    console.log('++++++talukalookupHandlerForPerHelper State '+ref.stateValue+' T '+ref.curTalukaValue);
    ref.perTalukaValue = evt.detail.selectedValueName;
    ref.perTalukaId = evt.detail.selectedValueId;
    if (ref.sameDocPresent) {
        ref.isTalukaCurValueSelected = true;
        ref.curTalukaValue = evt.detail.selectedValueName
    }
}

export async function talukaClearvaluelookupHandlerForPerHelper(ref,evt){
    console.log('++++++talukaClearvaluelookupHandlerForPerHelper');
    ref.perTalukaValue = ''; 
    ref.perTalukaId = '';
    if(ref.sameDocPresent){
        ref.isTalukaCurValueSelected = false;
        ref.curTalukaValue ='' 
    }
}
/*SFTRAC-1660 End*/
//SFTRAC-1660 Start
export async function currentAddressLineValidation(ref){
    if (!ref.validityCheck('.currentAddress')) { ref.showToastMessage('', 'Fill all the details', 'warning');  return true;}
    return false;
}
export async function permanentAddressLineValidation(ref){
    if (!ref.validityCheck('.permanentAddress')) { ref.showToastMessage('', 'Fill all the details', 'warning');  return true; }
    return false;
}
//SFTRAC-1660 End
export async function helperValidatePhoneNumber1(ref){
    await checkAllApplicantPhoneNo({ loanAppId:ref.recordid})
    .then(result => {
        if(result.length > 0){
            let itemVal=result.filter(item => (item.hasOwnProperty('Contact_number__c') && item.Contact_number__c == ref.phoneNumberRef1Value));
            console.log('in data save ***',itemVal);
            if(itemVal.length >0){
                ref.showToastMessage('', 'This phone number is already associated with a ' + itemVal[0].Applicant_Type__c, 'error');
                ref.phoneNumberRef1Value = null;
            } 
        }
    }).catch(error =>{})
    if(ref.phoneNumberRef1Value != null && ref.phoneNumberRef2Value != null && ref.phoneNumberRef1Value == ref.phoneNumberRef2Value){
        ref.showToastMessage('', 'This phone number is already associated with a Reference', 'error');
        ref.phoneNumberRef1Value = null;
    }
}
export async function helperValidatePhoneNumber2(ref){
    await checkAllApplicantPhoneNo({ loanAppId:ref.recordid})
    .then(result => {
        if(result.length > 0){
            let itemVal=result.filter(item => (item.hasOwnProperty('Contact_number__c') && item.Contact_number__c == ref.phoneNumberRef2Value));
            console.log('in data save ***',itemVal);
            if(itemVal.length >0){
                ref.showToastMessage('', 'This phone number is already associated with a ' + itemVal[0].Applicant_Type__c, 'error');
                ref.phoneNumberRef2Value = null;
            } 
        }
    }).catch(error =>{})
    if(ref.phoneNumberRef1Value != null && ref.phoneNumberRef2Value != null && ref.phoneNumberRef1Value == ref.phoneNumberRef2Value){
        ref.showToastMessage('', 'This phone number is already associated with a Reference', 'error');
        ref.phoneNumberRef2Value = null;
    }
}