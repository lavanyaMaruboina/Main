import { LightningElement, wire, api, track } from 'lwc'; 
import { getRecord, updateRecord } from 'lightning/uiRecordApi';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import LightningCardCSS from '@salesforce/resourceUrl/loanApplication';
import { loadStyle } from 'lightning/platformResourceLoader';
import userId from '@salesforce/user/Id';
import Applicant__c from '@salesforce/schema/Applicant__c';
import IS_ADDITIONAL_DETAILS_SUBMITTED from '@salesforce/schema/Applicant__c.Is_Additional_Details_Submitted__c';//CISP-3224
import Documents__c from '@salesforce/schema/Documents__c';
import { NavigationMixin } from 'lightning/navigation';
import Customer_Qualification__c from '@salesforce/schema/Applicant__c.Customer_Qualification__c';
import Profile__c from '@salesforce/schema/Applicant__c.Profile__c';
import of_family_members_residing_with_you__c from '@salesforce/schema/Applicant__c.of_family_members_residing_with_you__c';
import Preferred_address_for_communication__c from '@salesforce/schema/Applicant__c.Preferred_address_for_communication__c';
import Residence_country__c from '@salesforce/schema/Applicant__c.Residence_country__c';
import Marital_status__c from '@salesforce/schema/Applicant__c.Marital_status__c';
import Religion__c from '@salesforce/schema/Applicant__c.Religion__c';
import Caste__c from '@salesforce/schema/Applicant__c.Caste__c';
import Communication_language__c from '@salesforce/schema/Applicant__c.Communication_language__c';
import Relationship_with_borrower__c from '@salesforce/schema/Applicant__c.Relationship_with_borrower__c';
import Salutation__c from '@salesforce/schema/Applicant__c.Salutation__c';  
import Gender__c from '@salesforce/schema/Applicant__c.Gender__c';
import Category__c from '@salesforce/schema/Applicant__c.Category__c';
import Employer_Type__c from '@salesforce/schema/Applicant__c.Employer_Type__c';
import emailId1 from '@salesforce/schema/Applicant__c.Email_Id_1__c';
import emailId2 from '@salesforce/schema/Applicant__c.Email_Id_2__c';
import emailId3 from '@salesforce/schema/Applicant__c.Email_Id_3__c';
import emailIdField from '@salesforce/schema/Applicant__c.Email_Id__c';
import emailId1Status from '@salesforce/schema/Applicant__c.Email_Id_1_Status__c';
import emailId2Status from '@salesforce/schema/Applicant__c.Email_Id_2_Status__c';
import emailId3Status from '@salesforce/schema/Applicant__c.Email_Id_3_Status__c';
import UserNameFld from '@salesforce/schema/User.Name';
import userEmailFld from '@salesforce/schema/User.Email';
import STAGE_NAME_FIELD from '@salesforce/schema/Opportunity.StageName';
import LAST_STAGE_NAME_FIELD from '@salesforce/schema/Opportunity.LastStageName__c';
import OPP_ID_FIELD from '@salesforce/schema/Opportunity.Id';
import APP_ID_FIELD from '@salesforce/schema/Applicant__c.Id';
import FORM_FACTOR from '@salesforce/client/formFactor';
import isOpenBankAccountWithIBL from '@salesforce/apex/Ind_Demographic.isOpenBankAccountWithIBL'; // Added By Prashant STRAC-96
import saveAdditionalDetails from '@salesforce/apex/Ind_Demographic.saveAdditionalDetails';
import getAdditionalDetailsSubmittedValue from '@salesforce/apex/Ind_Demographic.getAdditionalDetailsSubmittedValue';
import getDemographicDetails from '@salesforce/apex/Ind_Demographic.getDemographicDetails';
import getAllApplicantList from '@salesforce/apex/Ind_Demographic.getAllApplicantList';
import getApplicantDetailWhoWillRepayTheLaon from '@salesforce/apex/Ind_Demographic.getApplicantDetailWhoWillRepayTheLaon'; // Added By Prashant STRAC-96
import getApplicantDetails from '@salesforce/apex/Ind_Demographic.getApplicantDetails';
import getAddress from '@salesforce/apex/Ind_CustomerAdditionalDetailsCtrl.getAddress';
import saveDocumentData from '@salesforce/apex/Ind_CustomerAdditionalDetailsCtrl.saveDocumentData';
import getUploadDocument from '@salesforce/apex/Ind_CustomerAdditionalDetailsCtrl.getUploadDocument';
import getStateMasterData from '@salesforce/apex/Utilities.getStateMasterData';
import getCityStateMaster from '@salesforce/apex/Utilities.getCityStateMaster';
import getCityStateMaster2 from '@salesforce/apex/Utilities.getCityStateMaster2';
import getDistrictsByState from '@salesforce/apex/Utilities.getDistrictsByState';
import getTalukaByDistrictAndState from '@salesforce/apex/Utilities.getTalukaByDistrictAndState';
import emailVerifyPass from '@salesforce/apex/IND_EmailCheckController.emailVerifyPass';
import emailBlackListed from '@salesforce/apex/IND_EmailCheckController.emailBlackListed';
import getFailEmailValue from '@salesforce/apex/IND_EmailCheckController.getFailEmailValue';
import doEMAILCHECKCallout from '@salesforce/apexContinuation/IntegrationEngine.doEMAILCHECKCallout';
import getReferenceCustomerOfApplicant from '@salesforce/apex/IND_LWC_ReferenceCustomer.getReferenceCustomerOfApplicant';
import doPincodeBasedSearchCallout from '@salesforce/apexContinuation/IntegrationEngine.doPincodeBasedSearchCallout';
import verifyCMU from '@salesforce/apex/LwcLOSLoanApplicationCntrl.verifyCMU';
import kycDelete from '@salesforce/apex/Ind_CustomerAdditionalDetailsCtrl.kycDelete';
import isCommunity from '@salesforce/apex/LwcLOSLoanApplicationCntrl.isCommunity';
import checkUploadDocument from '@salesforce/apex/LwcLOSLoanApplicationCntrl.checkUploadDocument';
import RegEx_Number from '@salesforce/label/c.RegEx_Number';
import Mobile_Number_Error_Msg from '@salesforce/label/c.Mobile_Number_Error_Msg';
import RegEx_Last_Name from '@salesforce/label/c.RegEx_Last_Name';
import Address_Pattern from '@salesforce/label/c.Address_Pattern';
import Ivalid_Email_Error_Message from '@salesforce/label/c.emailIdError';//CISP-18736
import NameError from '@salesforce/label/c.Name_Error';
import Pin_code_Pattern from '@salesforce/label/c.Pin_code_Pattern';
import AddressValidation1 from '@salesforce/label/c.AddressValidation1';
import AddressValidation2 from '@salesforce/label/c.AddressValidation2';
import AddressValidation3 from '@salesforce/label/c.AddressValidation3';
import RegEx_Alphabets_Only from '@salesforce/label/c.RegEx_Alphabets_Only';
import lastNameError from '@salesforce/label/c.Last_Name_Error';
import KycAddress1Pattern from '@salesforce/label/c.KycAddress1Pattern';
import KycAddress2Pattern from '@salesforce/label/c.KycAddress2Pattern';
import Borrower from '@salesforce/label/c.Borrower';
import CoBorrower from '@salesforce/label/c.CoBorrower';
import Guarantor from '@salesforce/label/c.Guarantor';
import No_Applicant_Found from '@salesforce/label/c.No_Applicant_Found';
import Current_Residential_Address from '@salesforce/label/c.Current_Residential_Address';
import Perment_Residential_Address from '@salesforce/label/c.Perment_Residential_Address';
import Demographic_Details from '@salesforce/label/c.Demographic_Details';
import KYC_Pin_Code_ErrorMessage from '@salesforce/label/c.KYC_Pin_Code_ErrorMessage';
import KYC_Address_ErrorMessage from '@salesforce/label/c.KYC_Address_ErrorMessage';
import IndusInd_Home from '@salesforce/label/c.IndusInd_Home';
import Please_provide_All_details from '@salesforce/label/c.Please_provide_All_details';
import All_Details_Stored_Sucessfully from '@salesforce/label/c.All_Details_Stored_Sucessfully';
import Please_Verify_Your_Email from '@salesforce/label/c.Please_Verify_Your_Email';
import completeField from '@salesforce/label/c.completeField';
import Email_Invalid from '@salesforce/label/c.Email_Invalid';
import Email_Attempts_are_exhausted from '@salesforce/label/c.Email_Attempts_are_exhausted';
import Email_Verification_Done from '@salesforce/label/c.Email_Verification_Done';
import Invalid_Email_Please_Re_enter_new_Email from '@salesforce/label/c.Invalid_Email_Please_Re_enter_new_Email';
import Please_Re_enter_Email_Id from '@salesforce/label/c.Please_Re_enter_Email_Id';
import Kindly_Retry from '@salesforce/label/c.Kindly_Retry';
import fetchDocument from '@salesforce/apex/Ind_CustomerAdditionalDetailsCtrl.fetchDocument';
import getLoanApplicationHistory from '@salesforce/apex/LwcLOSLoanApplicationCntrl.getLoanApplicationHistory';
import accessLoanApplication from '@salesforce/apex/LwcLOSLoanApplicationCntrl.accessLoanApplication';
import ReadOnlyLeadAccess from '@salesforce/label/c.ReadOnlyLeadAccess';
import SuccessMessage from '@salesforce/label/c.SuccessMessage';
import Retry_Exhausted from '@salesforce/label/c.Retry_Exhausted';
import FailureMessage from '@salesforce/label/c.FailureMessage';
import Score_Card_Passed from '@salesforce/label/c.Score_Card_Passed';
import Score_Card_failed_Please_Re_Trigger from '@salesforce/label/c.Score_Card_failed_Please_Re_Trigger';
import getRiskBandStatusValue from '@salesforce/apex/Ind_Demographic.getRiskBandStatusValue';
import getLoanApplicationReadOnlySettings from '@salesforce/apex/LwcLOSLoanApplicationCntrl.getLoanApplicationReadOnlySettings';//Ola integration changes
import * as helper from './currentResidentialAddressHelper';
import getApplicant from "@salesforce/apex/Ind_Demographic.getApplicant";
const referenceCustomersColumns =[
    {label : 'Customer Name', fieldName : 'Name'} ,
    {label : 'Address', fieldName : 'Address'},
    {label : 'Customer Since', fieldName : 'Maker_Date'},
    {label : 'Mobile Number', fieldName : 'Phone'},
    {label : 'Product', fieldName : 'Product'},
    {label : 'Exposure', fieldName : 'Exposure'}
];
import doGenerateTokenAPI from  '@salesforce/apex/IntegrationEngine.doGenerateTokenAPI'; //SFTRAC-724
import documentValidation from '@salesforce/apex/Ind_Demographic.documentValidation';
import DOCUMENT_NUMBER from '@salesforce/schema/Documents__c.Document_Number__c';
import DOC_ID_FIELD from '@salesforce/schema/Documents__c.Id';

export default class CurrentResidentialAddress extends NavigationMixin(LightningElement) {
    get getCurrentTractorFieldDisable(){
        return this.currentTractorFieldDisable || this.disableCurrentAddressTractor;
    }
    emailValue = ''; unverified_Invalid_Email = false; @track isOlaHeroLead = false; @track isLandmarkDisplay = false; @api currentTabId; @track currentVillage; @track currentlandmarkData; @track currentTalukaData; @track permanentVillageData; @track permanentTaluka; @track permanentLandmark; @track isCurrentAddressSameAsPermanent; @api recordid; @api appicantId; @api tabData; @api creditval; @api currentStage; @track allStateData; @track cityValue; @track districtValue; disableRiskBand=true; riskBand; borrowerName; coBorrowerName; @api showCardMsg; @api cardMsg; disableNext = true; currentUserId = userId; currentUserName; currentUserEmailId; otherDocRecordTypeId; error; demogarphicData; errorMessage = ''; productType; entityType; leadSource; emailMandate = true; @track currentDocTypeOptionsList = []; @track permanentDocTypeOptionsList = []; @track currentdocumentType; @track permanentDocumentType; @track uploadDocumentType; @track whoWillRepayLoan = []; @track permanentCityValue; @track permanentDistrictValue; @track permanentTalukaValue; @track talukaValue; @track preferredAddressForCommunicationPicklist; @track otherKYCDocName; preferredAddressForCommunicationValue; @track isEnableUploadViewDoc = true; @track showFileUploadAndView = false; forRelationshipTab = false; whoWillRepayTheLoan = true; @track isEnableNext = false; @track saveExitFlag = false; @track disbaleWhoWillRepayTheLoan = false; currentAddressUploadButton = true; disableSubmitButton = false; submitGreenTickButton = false; demographiFieldsDisable = false; demographiEmailFieldsDisable = false; demographiSpouseieldsDisable = false; @track isEmailVerifiedDisabled = false; oppStageName; modalPopUpCaptureImage = false; largeFactorUpload = false; smallFactorUpload = false; @track currentAddressDisable = false; @track currentTractorFieldDisable = false; @track disableCurrentAddressTractor = false;@track parmanentTractorFieldDisable = false; disableCurrentAddressProof = false; captureCurrentAddressFlag = false; capturePermanentAddressFlag = false; @track permanentAddressDisable = false; disablePermanentAddressProof = false; noApplicantFound = false; isError = false; isCancel = true; isDone = true; documentToDelete = null; isLoading = false; @track isAdditionalDetailsSubmitted = false; isEmailVerified = false; @track isEmailVerifiedCross = false; @track isEmailVerifiedTick = false; @api allApplicantList = []; @track isRefCustomerAvailable = false; @track referenceCustomerRecords =[]; @track referenceCustomersColumns =referenceCustomersColumns; isCurrentAddressPresent = false; currentAddressData = {}; permanentAddressData = {}; @track demogarphicDataFields = {}; errorTitle = 'error'; errorVariant = 'error'; successTitle = 'Success'; successVariant = 'success'; religionValue; casteValue; coborrowerResideWithBorrower = false; spouseNameValue; fatherNameValue; repaymentWillBeDoneBy; motherNameValue; currentAddressFileId; incomeSource = false; applicantNumber; @track applicantId; familyMemberValue; @track countryValue = 'India'; relationshipValue; repayLoanValue; maritalStatusValue; communicationValue; qualificationValue; Addressvalue; contactNumber; minCurrentState; maxCurrentState; minPermanentState; maxPermanentState; currentResidentId; permanentResidentId; typeOfAddress=null; fetchDocumentCurrentAddress = false; fetchDocumentPermanentAddress = false; @api checkleadaccess; requiredSpouseValue = false; leadSource; disableMaritalStatus = false; nameRef1Value; relationRef1Value; addressLine1Ref1Value; doYouHaveBankAccountWithIBL = false; addressLine2Ref1Value; stateRef1Value; districtRef1Value; cityRef1Value; pincodeRef1Value; phoneNumberRef1Value; nameRef2Value; relationRef2Value; addressLine1Ref2Value; addressLine2Ref2Value; stateRef2Value; districtRef2Value; cityRef2Value; pincodeRef2Value; phoneNumberRef2Value; isPermanentAddressNotPresent = false; @api isTractor = false; @track referenceCustomerAvailable = false; @track retryCountForPincodeBaseSearch =0; @track capturePermanentAddLabel = 'Capture ' + ( this.isNotNonIndividualTractorBorrower ? 'Permanent' : 'Office') + ' Address'; @track isNewCustomer = false; @track disabledOpenBankAcc = true; openNewBankAccount=false; isOpenNomineeDetialSection = false; nomineeName = ''; nomineeAvailable = ''; nomineeAddress = ''; nomineeCity=''; nomineePincode = ''; nomineeState = ''; nomineeDob = ''; nomineeRelationship = ''; nomineeCityId; nomineeStateId; isNomineeDetailSaved = false; repayByApplicantId; disableAllNomineeAndRepayField = false; repayLoanLabel = ''; wouldYouLikeToOpenBankAccount = false; isNonIndividual = false; selectedApplicantType; isWhoWillRepayTheLoanChanged=false; isNomineeCitySelected=false; true; isCustomerNRIVal = false;
    relationshipOptions = [{label: 'Father', value: 'FATHER'},{label: 'Mother', value: 'MOTHER'},{label: 'Son', value: 'SON'},{label: 'Daughter', value: 'DAUGHTER'},{label: 'Friend', value: 'Friend'},{label: 'Brother', value: 'BROTHER'},{label: 'Sister', value: 'SISTER'},{label: 'Husband', value: 'HUSBAND'},{label: 'Wife', value: 'WIFE'}];
    label = {SuccessMessage,Retry_Exhausted,FailureMessage,Score_Card_Passed,Score_Card_failed_Please_Re_Trigger,RegEx_Number,Mobile_Number_Error_Msg,NameError,RegEx_Last_Name,Borrower,CoBorrower,Guarantor,Pin_code_Pattern,Address_Pattern,Current_Residential_Address,Perment_Residential_Address,Demographic_Details,KYC_Address_ErrorMessage,KYC_Pin_Code_ErrorMessage,No_Applicant_Found,IndusInd_Home,Please_provide_All_details,RegEx_Alphabets_Only,lastNameError,KycAddress1Pattern,KycAddress2Pattern,AddressValidation1,AddressValidation2,AddressValidation3
    }
    docTypeOptions = []; beneadd1; beneadd2; benestate; benedistrict; benecity; benepincode; nonIndividualEntityType; isPropriorBusinessEntityType = false; isGetCRIFFButton = true; isDisableViewCRIFFButton = false; isDisableGetCRIFFButton = false; cRIFFURL; reportURL; criffInitiated = false; isSpinnerMoving = false; borrowerId; entityCategory;
    @wire(getObjectInfo, { objectApiName: Applicant__c }) objectInfo;
    @wire(getObjectInfo, { objectApiName: Documents__c }) wiredObjectInfo({ error, data }) {
        if (error) {
            this.showToastMessage('', 'Error in fetching Documents details', 'error');
        } else if (data) {
            const rtis = data.recordTypeInfos;
            this.otherDocRecordTypeId = Object.keys(rtis).find(rti => rtis[rti].name === 'Other Documents');
        }
    }
    @wire(getApplicant, {loanAppId: "$recordid"})
      getApplicantDetails({error,data}){
        if (data) {
          data.forEach((x) => {
            if (x.Applicant_Type__c == "Co-borrower") {
              this.coBorrowerName = x.Name;
            } else if (x.Applicant_Type__c == "Borrower") {
              this.borrowerName = x.Name;
            }});}else if (error) {
          console.error("Error--getApplicantDetails--> ", JSON.stringify(error));
        }}
    @wire(getRecord, { recordId: userId, fields: [UserNameFld, userEmailFld] })userDetails({ error, data }) {
        if (data) {
            this.currentUserName = data.fields.Name.value;
            this.currentUserEmailId = data.fields.Email.value;
        } else if (error) {
            this.error = error;
        }
    }
    handleProfileNameChange(event){this.profileValue = event.detail.value;}
    optionsPicklist(option){let picklistValues=[];for (let index = 0; index < this.preferredAddressForCommunicationValue.data.values.length; index++) {let Valuesitem = {};if(this.preferredAddressForCommunicationValue.data.values[index].value!=option){Valuesitem.label = this.preferredAddressForCommunicationValue.data.values[index].value;Valuesitem.value=this.preferredAddressForCommunicationValue.data.values[index].value;Valuesitem.id=[index];picklistValues.push(Valuesitem);}}this.preferredAddressForCommunicationPicklist=picklistValues; 
    }
    get relationshipWithEntityRequried() {return this.tabData == 'Benificiary';}
    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: Profile__c }) profileOption;
    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: Preferred_address_for_communication__c }) preferredAddressForCommunicationValue;
    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: Customer_Qualification__c }) customerQualificationValue;
    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: of_family_members_residing_with_you__c }) numOfFamilyResiding;
    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: Residence_country__c }) residenceCountry;
    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: Marital_status__c }) maritalStatus;
    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: Religion__c }) religionStatus;
    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: Caste__c }) casteStatus;
    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: Communication_language__c }) communicationLanguage;
    @track relationshipWithBorrower;
    @track relationWithCBGOptions;
    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: Salutation__c }) salutationVal;
    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: Gender__c }) genderVal;
    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: Category__c }) CategoryVal;
    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: Employer_Type__c }) employerTypeVal;
    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: Relationship_with_borrower__c }) wiredDetails({ data, error }) {
        if (error) {
        } else if (data) {
            this.relationWithCBGOptions = [];this.relationshipWithBorrower = [];
            let arr = data.values;
            let borrowerCode = ["MOTHER", "BROTHER", "SISTER","SON","Neighbour","Friend","Broker","Business Associate"];
            let CBGCodes = ["EMPLOYEE","ASSOCIATION FOR PROFIT","PROPRIETORSHIP","PROPRIETRIX","30","DIRECTOR","TRUST","OTHERS","TP EMPLOYEE","TP EMPLOYER","TP SUBORDINATE","MANAGING PARTNER","MANAGING DIRECTOR","ASSOCIATION",'Business Associate'];
            let  filteredNames = arr.filter((name) => !borrowerCode.includes(name.value));
            let CBGNames = arr.filter((name) => CBGCodes.includes(name.value));
            this.relationWithCBGOptions = CBGNames;
            this.relationshipWithBorrower = filteredNames;
        }
    };
    @wire(getStateMasterData) wiredStateMaster({ error, data }) {
        if (data) {
            let finalArrayTopush = [];
            if (data.length > 0) {
                for (let index = 0; index < data.length; index++) {
                    let stateValue = { label: data[index].Name, value: data[index].Name, id: data[index].Id, stateMinValue: data[index].Pincode__c, stateMaxValue: data[index].Pincode_Starting_Max__c };
                    finalArrayTopush.push(stateValue);                    
                }
            }
            this.allStateData = finalArrayTopush;
        } if (error) {
            this.showToastMessage('', 'Error in fetching State details', 'error');
        }
    }
    // SFTRAC - 25 // Start
    @wire(getReferenceCustomerOfApplicant, { applicantId: '$applicantId', refered: false })
    wiredReferenceCustomers({ error, data }) {
        if (data && data.length>0) {
            this.referenceCustomerAvailable = true;
        }
        else if(error){
        }
    }
    @wire(getReferenceCustomerOfApplicant, { applicantId: '$applicantId', refered: true })
    wiredReferenceCustomerRecord({ error, data }) {
        if (data) {
            let tempRecords = [];
            data.forEach(record =>{
               	
            })
            this.referenceCustomerRecords = tempRecords;
            this.isRefCustomerAvailable = true;
        }
    }
    get isTractorIndividual (){return this.productType == 'Tractor' && this.entityType == 'Individual'}
    // SFTRAC - 25 // End

    get isNotNonIndividualTractorBorrower() {return !(this.productType == 'Tractor' && this.entityType == 'Non-Individual' && this.tabData == 'Borrower');
    }
    get isofficeAddressOpen(){return (this.isprofileSelected && this.productType != 'Tractor') || (!this.isNotNonIndividualTractorBorrower && this.isprofileSelected)}
    get isNonIndividualCBG(){return (this.tabData == CoBorrower || this.tabData == Guarantor) && this.entityType == 'Non-Individual' && this.productType == 'Tractor'}
    get getPerminantResiLabel() {return !this.isNotNonIndividualTractorBorrower ? 'Office Address' : this.label.Perment_Residential_Address;
    }
    get checkNonIndividual() { return (this.productType == 'Tractor' && this.entityType == 'Non-Individual' && this.tabData != 'Borrower') ? true : false }
    get currentDocTypeOptions() { return this.currentDocTypeOptionsList;}
    get getCaptureCurrentBtn() {
        if (this.isTractorFinance) {if (this.currentTractorFieldDisable || this.disableCurrentAddressTractor) { return true; }return false; } else {  return this.currentAddressDisable;}
    }
    get isNonIndividual() { return (this.productType == 'Tractor' && this.entityType == 'Non-Individual') ? true : false }
    get isNonIndividualBeneficiary() { return (this.productType == 'Tractor' && this.entityType == 'Non-Individual' && this.tabData == 'Beneficiary') ? true : false }
    get getIncomeSource(){ return (this.isNonIndividual ? true : this.incomeSource)}
    get getCaptureParmanentBtn() {if (this.isTractorFinance) {if (this.parmanentTractorFieldDisable) { return true; }return false;} else {return this.permanentAddressDisable;}}
    get isRequiredField() {return this.demogarphicDataFields.Is_Customer_NRI__c;}
    get permanentDocTypeOptions() { return this.permanentDocTypeOptionsList; }
    isAddressDeclaration = false;//CISP-2701
    saveCurrentAddress = false;//CISP-3088
    capturebutton = 'Capture Current Address';//CISP-3088
    showCoborrowerReside;
    @track isGSTUploaded = false;@track isResiCumOfficeAddress = false;feedbackRef2Value;feedbackRef1Value;
    //CISP-15702 Start
    @wire(getRecord, { recordId: '$recordid', fields: ['Opportunity.UploadAndViewDocDisable__c']})
    wireOpportunityRec;
    get isUploadViewDisabled(){
        return this.wireOpportunityRec.data ? this.wireOpportunityRec.data.fields.UploadAndViewDocDisable__c.value : false;
    }
    //CISP-15702 End
    async connectedCallback() {
        await getAllApplicantList({ recordId: this.recordid }).then(response => {
            if(response && response.length > 0){
                if(response?.[0].Opportunity__r.Product_Type__c !== 'Tractor'){
                    let optionForWhoWillRepayTheLoanListPV = [{label: 'Borrower', value: 'Borrower'}, {label: 'Co-borrower', value: 'Co-borrower'}];
                    this.whoWillRepayLoan = optionForWhoWillRepayTheLoanListPV;
                }
                else{
                    let optionForWhoWillRepayTheLoanList = [];
                    response.forEach(applicant =>{
                        if(applicant.Applicant_Type__c != 'Guarantor' && ((applicant.Do_you_have_a_bank_account__c == true) || (applicant.Customer_Dedupe_Response__r && applicant.Customer_Dedupe_Response__r[0].IND_isNewCustomer__c == true))){
                            let optionForWhoWillRepayTheLoan = {};
                            optionForWhoWillRepayTheLoan.label = applicant.Applicant_Type__c + '(' + applicant.Name + ')';
                            optionForWhoWillRepayTheLoan.value = applicant.Id;
                            optionForWhoWillRepayTheLoanList.push(optionForWhoWillRepayTheLoan);
                        }
                        if(applicant.Applicant_Type__c == 'Borrower' && response?.[0].Opportunity__r.Customer_Type__c == 'Non-Individual'){
                            this.cRIFFURL = applicant.CRIFF_Report_URL__c != undefined ? applicant.CRIFF_Report_URL__c : '';
                            this.borrowerId = applicant.Id;
                            this.entityCategory = response?.[0].Opportunity__r.Entity_Type__c;
                        }
                    });
                    if( response?.[0].Opportunity__r.Customer_Type__c == 'Non-Individual'){
                        this.whoWillRepayLoan = optionForWhoWillRepayTheLoanList.filter((item) => item.label.includes('Borrower'));
                        this.nonIndividualEntityType = response?.[0].Opportunity__r?.Entity_Type__c;//SFTRAC-724
                        this.criffInitiated = response?.[0].Opportunity__r?.CRIFF_Report_Initiated__c;//SFTRAC-724
                    }else{
                        this.whoWillRepayLoan = optionForWhoWillRepayTheLoanList;
                    }
                }
            }
        }).catch(error => {
            this.isLoading = false;this.showToastMessage('','Error in Applicant details', 'error');
        });
        if (this.tabData === CoBorrower || this.tabData === 'Guarantor' || this.tabData === 'Beneficiary') {
            this.forRelationshipTab = true;
            this.whoWillRepayTheLoan = false;
        }
        if (this.tabData === CoBorrower) {
            this.showCoborrowerReside = true;
        }
        this.issuccessEmailCheck = false;

        await getAddress({ opportunityId: this.recordid, applicantType: this.tabData, 'applicantId' : this.currentTabId }).then(response => {
            this.productType = response.productType; //CISP-2781
            this.isTractor = this.productType.toLowerCase() === 'Tractor'.toLowerCase() ? true : false;
            if (this.tabData === CoBorrower && this.isTractor) {
                this.showCoborrowerReside = true;
            }
            this.leadSource = response.leadSource; //D2C Change
            this.emailMandate = response.productType === 'Two Wheeler' || response.productType.toLowerCase() === 'Tractor'.toLowerCase()? false : true; //CISP-2781 , SFTRAC-33
            this.isCurrentAddressSameAsPermanent = response.isCurrentSameAsPermanent;
            this.entityType = response.entityType;
            if(this.entityType == 'Non-Individual' && this.isTractor == true){
                this.isNonIndividual = true;
            }
            if (this.emailMandate) {
                this.template.querySelector('lightning-input[data-id=EmailId]').className = 'demographicDetails';
            }
            if(this.emailMandate === false) {
                this.isEmailVerifiedDisabled = true; //CISP-2827
            }
            if (response.isApplicantPresent) {
                if (response.Application_number__c) {
                    this.applicantNumber = response.Application_number__c;
                }
                if (response.applicantId) {
                    this.applicantId = response.applicantId;
                }
                //CISP-2757-START
                if(response?.name){
                    this.name = response.name;
                }
                //CISP-10087 Start
                if(response?.isPermanentAddressNotPresent) {
                    this.isPermanentAddressNotPresent = response.isPermanentAddressNotPresent;
                }//CISP-10087 END
                //CISP-2757-END
                if(response != null && response?.isGSTUploaded){this.isGSTUploaded=true;}
                if(response != null && response?.residenceCumOffice){this.isResiCumOfficeAddress=true;}
                if (response != null && response.currentAddress) {
                    this.currentAddressData = response.currentAddress;
                    this.currentVillage = response.currentAddress?.Village__c;
                    this.curTalukaValue = response.currentAddress?.Taluka__c;this.curTalukaId = response.currentAddress?.Taluka_Id__c; this.isTalukaCurValueSelected = this.curTalukaValue ? true : false; //SFTRAC-1660
                    this.currentlandmarkData = response.currentAddress?.Landmark__c;
                    if (this.currentVillage && this.curTalukaValue && this.currentlandmarkData) {
                        this.currentTractorFieldDisable = true;
                    }
                    if(!this.name){this.name = response.name;}//CISP-3052
                    this.currentdocumentType = response.currentAddressDocumentType;//CISP-3052
                    this.isAddressDeclaration = response.isAddressDeclaration;//CISP-2701
                    this.isLandmarkDisplay = response.isCurrentAddressNotPresent;this.isCurrentAddressPresent = response.isCurrentAddressPresent; //SFTRAC-454
                    if (this.currentdocumentType) {
                        this.currentDocTypeOptionsList = [{ label: this.currentdocumentType, value: this.currentdocumentType }];//CISP-3052
                        this.disableCurrentAddressProof = true;
                    } else {
                        if(this.leadSource != 'D2C'){//D2C Change
                            this.showToastMessageModeBased('Missing Current Address Document Type', 'Kindly Validate KYC Documents', 'error', 'sticky');
                        }
                    }
                    if(this.isAddressDeclaration){this.fetchDocumentCurrentAddress = true; this.capturebutton = 'Save Current Address';}//CISP-3088
                    if (response.currentAddress.KYC_State__c) {this.curStateValue = response.currentAddress.KYC_State__c; //SFTRAC-1660
                        this.isLoading = true;
                        if(response.currentAddress.KYC_City__c){
                            if(this.leadSource == 'D2C') {
                                this.currentAddressData.KYC_District__c = this.currentAddressData.KYC_District__c.toUpperCase();
                        
                            } else {
                                this.currentAddressData.KYC_District__c = this.productType == 'Tractor' ? this.currentAddressData.KYC_District__c.toUpperCase() : this.currentAddressData.KYC_City__c.toUpperCase();
                            }
                            this.currentAddressData.KYC_City__c = this.currentAddressData.KYC_City__c.toUpperCase();
                        }
                        this.currentAddressData.KYC_State__c = this.currentAddressData?.KYC_State__c.toUpperCase();
                        if(this.leadSource == 'D2C' || this.isTractor){
                            getCityStateMaster2({ stateName: this.currentAddressData.KYC_State__c }).then(response => {
                                let cityData = [];
                                if (response && response.length > 0) {
                                    for (let index = 0; index < response.length; index++) {
                                        let cityObject = {}; cityObject.label = response[index].Name; cityObject.value = response[index].Name; cityObject.id = response[index].Id; cityData.push(cityObject);
                                    }
                                }
                                this.cityValue = cityData;
                                this.isLoading = false;
                            }).catch(error => {});
                        } else {
                            getCityStateMaster({ stateName: this.currentAddressData.KYC_State__c }).then(response => {
                                let cityData = [];
                                if (response && response.length > 0) {
                                    for (let index = 0; index < response.length; index++) {
                                        let cityObject = {}; cityObject.label = response[index].Name; cityObject.value = response[index].Name; cityObject.id = response[index].Id; cityData.push(cityObject);
                                    }
                                }
                                this.cityValue = cityData;
                                this.isLoading = false;
                            }).catch(error => {});
                        }
                        this.isLoading = true;
                        getDistrictsByState({ stateName: this.currentAddressData.KYC_State__c }).then(response => {
                            let cityData = [];
                            if (response && response.length > 0) {
                                for (let index = 0; index < response.length; index++) {
                                    let cityObject = {}; cityObject.label = response[index].Name; cityObject.value = response[index].Name; cityObject.id = response[index].Id; cityData.push(cityObject);
                                }
                            }
                            this.districtValue = cityData;
                            this.isLoading = false;
                        }).catch(error => {this.isLoading = false;});
                        if(response.currentAddress.KYC_State__c && response.currentAddress.KYC_District__c){
                            //this.getTaluka(response.currentAddress.KYC_State__c , response.currentAddress.KYC_District__c,'CurrentAddress'); 
                            this.getTaluka(response.currentAddress.KYC_State__c,'CurrentAddress');
                        }
                        if (this.isAddressDeclaration) { this.currentAddressDisable = true; this.saveCurrentAddress = true; }//CISP-3052//CISP-3088
                    }
                    this.currentResidentId= response.currentAddress.Id;
                    this.checkDocument(response.currentAddress.Id,true);
                }
                if (response != null && response.permanentAddress) {   
                    this.permanentAddressData = response.permanentAddress; this.permanentVillageData = response.permanentAddress?.Village__c; this.perTalukaValue = response.permanentAddress?.Taluka__c;this.perTalukaId = response.permanentAddress?.Taluka_Id__c; this.isTalukaPerValueSelected = this.perTalukaValue ? true : false; //SFTRAC-1660 
                    this.permanentLandmark = response.permanentAddress?.Landmark__c;
                    if ((this.permanentVillageData && this.perTalukaValue && this.permanentLandmark) || this.isCurrentAddressSameAsPermanent) {
                        this.parmanentTractorFieldDisable = true;
                    }
                    this.permanentDocumentType = response.permanentAddressDocumentType;
                    if (this.permanentDocumentType) {
                        this.permanentDocTypeOptionsList = [{ label: this.permanentDocumentType, value: this.permanentDocumentType }];
                    } else {
                        if(this.leadSource != 'D2C'){//D2C Change
                            this.showToastMessageModeBased('Missing ' + ( this.isNotNonIndividualTractorBorrower ? 'Permanent' : 'Office') + ' Address Document Type', 'Kindly Validate KYC Documents', 'error', 'sticky');
                        }    
                    }
                    if (response.permanentAddress.KYC_State__c) { this.perStateValue = response.permanentAddress.KYC_State__c; //SFTRAC-1660  
                        if(response.permanentAddress.KYC_City__c){
                            if(this.leadSource == 'D2C') {
                                this.permanentAddressData.KYC_District__c = this.permanentAddressData.KYC_District__c.toUpperCase();
                            } else {
                                this.permanentAddressData.KYC_District__c = this.productType == 'Tractor' ? this.permanentAddressData.KYC_District__c.toUpperCase() : this.permanentAddressData.KYC_City__c.toUpperCase();
                            }
                            this.permanentAddressData.KYC_City__c = this.permanentAddressData.KYC_City__c.toUpperCase();
                        }
                        this.permanentAddressData.KYC_State__c = this.permanentAddressData.KYC_State__c.toUpperCase();
                        this.isLoading = true;
                        if(this.leadSource == 'D2C' || this.isTractor){
                            getCityStateMaster2({ stateName: response.permanentAddress.KYC_State__c }).then(response => {
                                let cityData = [];
                                if (response && response.length > 0) {
                                    for (let index = 0; index < response.length; index++) {
                                        let cityObject = {}; cityObject.label = response[index].Name; cityObject.value = response[index].Name; cityObject.id = response[index].Id; cityData.push(cityObject);
                                    }
                                }
                                this.permanentCityValue = cityData;
                                this.isLoading = false;
                            }).catch(error => {});
                        } else {
                            getCityStateMaster({ stateName: response.permanentAddress.KYC_State__c }).then(response => {
                                let cityData = [];
                                if (response && response.length > 0) {
                                    for (let index = 0; index < response.length; index++) {
                                        let cityObject = {}; cityObject.label = response[index].Name; cityObject.value = response[index].Name; cityObject.id = response[index].Id; cityData.push(cityObject);
                                    }
                                }
                                this.permanentCityValue = cityData;
                                this.isLoading = false;
                            }).catch(error => {});
                        }
                        this.isLoading = true;
                        getDistrictsByState({ stateName: this.permanentAddressData.KYC_State__c }).then(response => {
                            let cityData = [];
                            if (response && response.length > 0) {
                                for (let index = 0; index < response.length; index++) {
                                    let cityObject = {}; cityObject.label = response[index].Name; cityObject.value = response[index].Name; cityObject.id = response[index].Id; cityData.push(cityObject);
                                }
                            }
                            this.permanentDistrictValue = cityData;
                            this.isLoading = false;
                        }).catch(error => {
                            this.isLoading = false;
                        });
                        if(response.permanentAddress.KYC_State__c && response.permanentAddress.KYC_District__c){
                            //this.getTaluka(response.permanentAddress.KYC_State__c , response.permanentAddress.KYC_District__c,'PermanentAddress'); 
                            this.getTaluka(response.permanentAddress.KYC_State__c,'PermanentAddress');
                        }
                    }
                    this.permanentResidentId= response.permanentAddress.Id;
                    this.checkDocument(response.permanentAddress.Id,false);
                }
            } else {
                this.noApplicantFound = true;
            }
        }).catch(error => {
            this.isLoading = false;
            this.showToastMessage('', 'Error in fetching Address details', 'error');
        });
        if(this.isTractorFinance){this.capturebutton = 'Save Current Address';}
        if(this.isTractorFinance){this.capturePermanentAddLabel = 'Save ' + ( this.isNotNonIndividualTractorBorrower ? 'Permanent' : 'Office') + ' Address';}
        helper.loadDocTypeHelper(this);
        await helper.getDemographicDetailss(this);
        await getLoanApplicationReadOnlySettings({leadSource:this.leadSource})
        .then(data => {
            let fieldList = [];if(data){fieldList=data.Input_Labels__c.split(';');}
            if ((this.maritalStatusValue === 'MARR' || this.maritalStatusValue === 'Married') && this.oppStageName === 'Additional Details'){
                this.requiredSpouseValue = true;
                this.demographiSpouseieldsDisable = false;
            } else {
                this.requiredSpouseValue = false;
                this.demographiSpouseieldsDisable = true;
            }
            //OLA-35 end
            if(fieldList.length>0){
                this.disableMaritalStatus = fieldList.includes('Marital Status')? true :this.demographiFieldsDisable;
                this.isEmailVerifiedDisabled = false;//OLA-28
            }
        }).catch(error => { 
            this.isLoading = false;
        });
        //Ola Integration changes
        if(this.tabData === Borrower && this.isAdditionalDetailsSubmitted && this.repayLoanValue){
            this.disbaleWhoWillRepayTheLoan = true;
        if(this.isTractor && this.repaymentWillBeDoneBy){
                this.disableAllNomineeAndRepayField = true;
            }
        }else if (this.tabData === Borrower) {
            await this.getWhoWillRepay();
        }
        this.callAccessLoanApplication();
        if(this.isTractor && this.tabData === Borrower){
            if(this.repayLoanValue){
                let filteredList= this.whoWillRepayLoan.filter(element=>{return element.value == this.repayLoanValue});
                this.repayLoanLabel = filteredList.length > 0 ? filteredList[0].label : '';
                this.selectedApplicantType = this.repayLoanLabel?.split("(")[0];
                this.disabledOpenBankAcc = this.isAdditionalDetailsSubmitted ? this.isAdditionalDetailsSubmitted : await isOpenBankAccountWithIBL({applicantId: this.repayLoanValue});
            }
            if(this.repaymentWillBeDoneBy){
                if(this.isNonIndividual == false){ this.wouldYouLikeToOpenBankAccount = true; } this.disableAllNomineeAndRepayField = true; this.disabledOpenBankAcc = true; this.disbaleWhoWillRepayTheLoan = true; if(this.isNonIndividual){ this.disabledOpenBankAcc = true; this.disbaleWhoWillRepayTheLoan = true; }
                await getApplicantDetailWhoWillRepayTheLaon({applicantId: this.repaymentWillBeDoneBy}).then(applicant=>{
                    if(applicant !== null){
                        this.openNewBankAccount = applicant.Would_you_like_to_open_a_bank_account__c;this.isOpenNomineeDetialSection =applicant.Would_you_like_to_open_a_bank_account__c;
                        this.nomineeAvailable = applicant.Nominee_available__c;this.nomineeName = applicant.Nominee_name__c; this.nomineeAddress = applicant.Nominee_address__c; this.isNomineeCitySelected = this.nomineeCity? true:false; this.nomineeCity = applicant.Nominee_City__c;  this.nomineePincode = applicant.Nominee_pin_code__c; this.nomineeState = applicant.Nominee_State__c; this.nomineeDob = applicant.Nominee_DOB__c;this.nomineeRelationship=applicant.Nominee_Relationship__c;
                    }
                }).catch(error => { 
                    this.isLoading = false;
                });
            }
        }
        this.countryValue = 'India';
        if(this.isTractorFinance){this.PreferredAddressPicklist();}
        if(!this.isNotNonIndividualTractorBorrower){helper.handlePropriorBusinessEntityType(this);}
    }
    get isTractorFinance() {
        return this.productType == "Tractor";
    }
    async getWhoWillRepay() {
        if(this.productType !== 'Tractor'){
        await getApplicantDetails({ opportunityId: this.recordid }).then(resp => {            
            if (resp && resp.length === 1) {
                if (resp[0].Income_source_available__c === true) {
                    this.repayLoanValue = 'Borrower';
                    this.disbaleWhoWillRepayTheLoan = true;
                } else {
                    this.repayLoanValue = 'Borrower';//CISP-2625
                    this.disbaleWhoWillRepayTheLoan = true;//CISP-2625
                    this.showToastMessage('Income source is not available for Borrower.', 'Warning', 'warning');//CISP-2625
                }
            }
            else if(resp && resp.length > 1) {//CISP-23393 Start
                let isBorrowerRepay = true;
                let isCoBorrowerRepay = true;
                for (let index = 0; index < resp.length; index++) {
                    if (resp[index].Applicant_Type__c == 'Borrower' && resp[index].Do_you_have_a_bank_account__c == false && resp[index].Do_you_have_a_bank_account_with_IBL__c == false && resp[index].Would_you_like_to_open_a_bank_account__c == false) {
                        isBorrowerRepay = false;
                    } else if (resp[index].Applicant_Type__c == 'Co-borrower' && resp[index].Do_you_have_a_bank_account__c == false && resp[index].Do_you_have_a_bank_account_with_IBL__c == false && resp[index].Would_you_like_to_open_a_bank_account__c == false) {
                        isCoBorrowerRepay = false;
                    }
                }
                if (isBorrowerRepay && isCoBorrowerRepay) {
                    this.disbaleWhoWillRepayTheLoan = false;
                } else if (isBorrowerRepay) {
                    this.repayLoanValue = 'Borrower';
                    this.disbaleWhoWillRepayTheLoan = true;
                } else if (isCoBorrowerRepay) {
                    this.repayLoanValue = 'Co-borrower';
                    this.disbaleWhoWillRepayTheLoan = true;
                }
            } //CISP-23393 End
        }).catch(error => {
            this.showToastMessage('', 'Error in fetching Applicant Details', 'error');
        });
        }
    }
    onChangeHandler(event) {
        helper.onChangeHandlerHelper(event,this);
    }
    handleclickResiCumOffice(event) {
        helper.resiCumOfficeHandler(event,this);
    }
    selectedStateHandler(event) {
        this.stateId = event.detail.selectedValueId; this.state = event.detail.selectedValueName; this.records = event.detail.records;
    }
    selectedCityHandler(event) {
        this.cityId = event.detail.selectedValueId;
        this.city = event.detail.selectedValueName;
        this.records = event.detail.records;
    }
    spouseHandler(event) {
        this.spouseNameValue = event.target.value; let spouseNameInput = this.template.querySelector('lightning-input[data-id=spouseId]'); let spouseNameValue = spouseNameInput.value; if (this.spouseNameValue.length > 26) { spouseNameInput.setCustomValidity(this.label.lastNameError); } else { spouseNameInput.setCustomValidity(""); } this.spouseNameValue = spouseNameValue; if (this.spouseNameValue === 'Single') { this.demographiSpouseieldsDisable = true; } spouseNameInput.reportValidity();
    }
    fatherHandler(event) {
        helper.fatherHandlerHelper(this,event);
    }
    motherHandler(event) {
        this.motherNameValue = event.target.value;
        let motherNameInput = this.template.querySelector('lightning-input[data-id=motherId]');
        if (this.motherNameValue.length > 26) {
            motherNameInput.setCustomValidity(this.label.lastNameError);
        } else {
            motherNameInput.setCustomValidity("");
        }
        motherNameInput.reportValidity();
    }
    religionHandler(event) {
        this.religionValue = event.target.value;
    }
    casteHandler(event) {
        this.casteValue = event.target.value;
    }
    // sftrac-94
    handleCoborrowerResideWithBorrower(event){
        this.coborrowerResideWithBorrower = event.target.checked;
    }
    validityCheck(query) {
        return [...this.template.querySelectorAll(query)].reduce((validSoFar, inputField) => {
            inputField.reportValidity();
            return validSoFar && inputField.checkValidity();
        }, true);
    }
    emptyFieldCheck(query) {
        let notEmpty = false;
        [...this.template.querySelectorAll(query)].forEach(inputField => {
            if (inputField.value && inputField.value.trim() !== '') {
                notEmpty = true;
            }
        });
        return notEmpty;
    }
    currentDocumentTypeHandler(event) {
        helper.currentHandler(event,this);
    }
    permanentDocumentTypeHandler(event) {
        helper.permanentHandler(event,this);
    }
    nameHandler(event){
        let inputLabel = event.target.label;
        let kycNameInput;
        if (inputLabel && inputLabel == 'NameRef1') {
            this.nameRef1Value = event.target.value;
            kycNameInput = this.template.querySelector('lightning-input[data-id=nameRef1Id]');
        }else if(inputLabel && inputLabel == 'NameRef2'){
            this.nameRef2Value = event.target.value;
            kycNameInput = this.template.querySelector('lightning-input[data-id=nameRef2Id]');
        }else{
            this.name = event.target.value;
            kycNameInput = this.template.querySelector('lightning-input[data-id=nameDataId]');
        }
        let name = kycNameInput.value;
        if (name.length > 26) {
            kycNameInput.setCustomValidity(this.label.lastNameError);
        } else {
            kycNameInput.setCustomValidity("");
        }
        kycNameInput.reportValidity();
    }
    handleBarrowerAddress(event) {
        let inputLabel = event.target.label;
        let address1;
        if (inputLabel && inputLabel == 'addressLine1Ref1') {
            this.addressLine1Ref1Value = event.target.value;
            address1 = this.template.querySelector('lightning-input[data-id=addressLine1Ref1Id]');
        }else if(inputLabel && inputLabel == 'addressLine1Ref2'){
            this.addressLine1Ref2Value = event.target.value;
            address1 = this.template.querySelector('lightning-input[data-id=addressLine1Ref2Id]');
        }else{
            this.currentAddressData.KYC_Address_Line_1__c = event.target.value;
            address1 = this.template.querySelector('lightning-input[data-id=kycAddressOneDataId]');
        }
        let addressL1 = address1.value;
        if (addressL1.length < 10) {
            address1.setCustomValidity(AddressValidation3);
        } else if (addressL1.length > 40) {
            address1.setCustomValidity(AddressValidation2);
        } else {
            address1.setCustomValidity("");
        }
        address1.reportValidity();
    }
    handleBarrowerAddress2(event) {
        let inputLabel = event.target.label;
        let address2;
        if (inputLabel && inputLabel == 'addressLine2Ref1') {
            this.addressLine2Ref1Value = event.target.value;
            address2 = this.template.querySelector('lightning-input[data-id=addressLine2Ref1Id]');
        }else if(inputLabel && inputLabel == 'addressLine2Ref2'){
            this.addressLine2Ref2Value = event.target.value;
            address2 = this.template.querySelector('lightning-input[data-id=addressLine2Ref2Id]');
        }else{
            this.currentAddressData.KYC_Address_Line_2__c = event.target.value;
            address2 = this.template.querySelector('lightning-input[data-id=kycAdressTwoDataId]');
        }
        let addressL2 = address2.value;
        if (addressL2.length < 3) {
            address2.setCustomValidity(AddressValidation1);
        } else if (addressL2.length > 40) {
            address2.setCustomValidity(AddressValidation2);
        } else {
            address2.setCustomValidity("");
        }
        address2.reportValidity();
    }
    handleBarrowerFeedbackValue(event){
        let inputLabel = event.target.label;
        if (inputLabel && inputLabel == 'feedbackRef1') {
            this.feedbackRef1Value = event.target.value;
        }else if (inputLabel && inputLabel == 'feedbackRef2') {
            this.feedbackRef2Value = event.target.value;
        }
    }
    handleBarrowerAddressPin(event) {
        let inputLabel = event.target.label;
        let pinCodeValue;
        let KycPinCodeDataIdInput;
        if (inputLabel && inputLabel == 'pinCodeRef1') {
            this.pincodeRef1Value = event.target.value;
            pinCodeValue = event.target.value;
            KycPinCodeDataIdInput = this.template.querySelector('lightning-input[data-id=pinCodeRef1Id]');
        }else if(inputLabel && inputLabel == 'pinCodeRef2'){
            this.pincodeRef2Value = event.target.value;
            pinCodeValue = event.target.value;
            KycPinCodeDataIdInput = this.template.querySelector('lightning-input[data-id=pinCodeRef2Id]');
        }else{
            this.currentAddressData.KYC_Pin_Code__c = event.target.value;
            pinCodeValue = event.target.value;
            KycPinCodeDataIdInput = this.template.querySelector('lightning-input[data-id=KycPinCodeDataId]');
        }
        if (pinCodeValue && pinCodeValue.length >= 2) {
            if (parseInt(pinCodeValue.substring(0, 2)) < this.minCurrentState || parseInt(pinCodeValue.substring(0, 2)) > this.maxCurrentState) {
                KycPinCodeDataIdInput.setCustomValidity("Invalid pin code");
            } else {
                KycPinCodeDataIdInput.setCustomValidity("");
            }
            KycPinCodeDataIdInput.reportValidity();
        }
    }
    handleBarrowerAddressCity(event) {
        let inputLabel = event.target.label;
        if (inputLabel && inputLabel == 'cityRef1') {
            this.cityRef1Value = event.target.value;
        }else if(inputLabel && inputLabel == 'cityRef2'){
            this.cityRef2Value = event.target.value;
        }else{
            this.currentAddressData.KYC_City__c = event.target.value;
        }
    }
    handleBarrowerAddressDistrict(event) {
        let inputLabel = event.target.label;
        let stateValue;
        let districtValue;
        if (inputLabel && inputLabel == 'districtRef1') {
            this.districtRef1Value = event.target.value;
        }else if(inputLabel && inputLabel == 'districtRef2'){
            this.districtRef2Value = event.target.value;
        }else{
            this.currentAddressData.KYC_District__c = event.target.value;
            districtValue = event.target.value;
            stateValue = this.template.querySelector('lightning-combobox[data-id=kycStateDataId]').value;
            //this.isLoading = true;     
        }
    }
    handleBarrowerAddressState(event) {
        let inputLabel = event.target.label;   let stateValue; let fromStateRef1 = false; let fromStateRef2 = false;
        if (inputLabel && inputLabel == 'StateRef1') {this.stateRef1Value = event.target.value;stateValue = event.target.value;fromStateRef1 = true;if(this.isTractor){this.districtRef1Value='';this.cityRef1Value='';this.pincodeRef1Value=''}
        }else if(inputLabel && inputLabel == 'StateRef2'){this.stateRef2Value = event.target.value;stateValue = event.target.value;fromStateRef2 = true;if(this.isTractor){this.districtRef2Value='';this.cityRef2Value='';this.pincodeRef2Value=''}
        }else{this.currentAddressData.KYC_State__c = event.target.value;if(this.leadSource != 'D2C' && !this.isTractor){this.currentAddressData.KYC_City__c = null;this.currentAddressData.KYC_District__c = null }stateValue = event.target.value;}
        for (let index = 0; index < this.allStateData.length; index++) {
            if (this.allStateData[index].value == stateValue) {this.minCurrentState = this.allStateData[index].stateMinValue;this.maxCurrentState = this.allStateData[index].stateMaxValue;}}
        let KycPinCodeDataIdInput;
        if (fromStateRef1) {
            KycPinCodeDataIdInput = this.template.querySelector('lightning-input[data-id=pinCodeRef1Id]');
        }else if(fromStateRef2){
            KycPinCodeDataIdInput = this.template.querySelector('lightning-input[data-id=pinCodeRef2Id]');
        }else{
            KycPinCodeDataIdInput = this.template.querySelector('lightning-input[data-id=KycPinCodeDataId]');
        }this.curStateValue = stateValue; //SFTRAC-1660
        if (stateValue) {
            KycPinCodeDataIdInput.disabled = false;
        } else {
            KycPinCodeDataIdInput.disabled = true;
        }
        this.isLoading = true;
        getCityStateMaster({ stateName: stateValue }).then(response => {
            let cityData = [];
            if (response && response.length > 0) {
                for (let index = 0; index < response.length; index++) {
                    let cityObject = {};
                    cityObject.label = response[index].Name;
                    cityObject.value = response[index].Name;
                    cityObject.id = response[index].Id;
                    cityData.push(cityObject);
                }
            }
            this.cityValue = cityData;
            this.isLoading = false;
        }).catch(error => {
            this.showToastMessage('', 'Error in fetching State', 'error');
            this.isLoading = false;
        });
        this.isLoading = true;
        getDistrictsByState({ stateName: stateValue }).then(response => {
            let cityData = [];
            if (response && response.length > 0) {
                for (let index = 0; index < response.length; index++) {
                    let cityObject = {};
                    cityObject.label = response[index].Name;
                    cityObject.value = response[index].Name;
                    cityObject.id = response[index].Id;
                    cityData.push(cityObject);
                }
            }
            this.districtValue = cityData;
            this.isLoading = false;
        }).catch(error => {
            this.isLoading = false;
        });
        this.getTaluka(stateValue,'CurrentAddress');    //SFTRAC-1660 Added 
    }
    handleBarrowerParmaAddress1(event) {
        this.permanentAddressData.KYC_Address_Line_1__c = event.target.value;
        let address1 = this.template.querySelector('lightning-input[data-id=kycAddressOneDataPId]');
        let addressL1 = address1.value;
        if (addressL1.length < 10) {
            address1.setCustomValidity(AddressValidation3);
        } else if (addressL1.length > 40) {
            address1.setCustomValidity(AddressValidation2);
        } else {
            address1.setCustomValidity("");
        }
        address1.reportValidity();
    }
    handleBarrowerParmaAddress2(event) {
        this.permanentAddressData.KYC_Address_Line_2__c = event.target.value;
        let address2 = this.template.querySelector('lightning-input[data-id=kycAdressTwoDataPId]');
        let addressL2 = address2.value;
        
        if (addressL2.length < 3) {
            address2.setCustomValidity(AddressValidation1);
        } else if (addressL2.length > 40) {
            address2.setCustomValidity(AddressValidation2);
        } else {
            address2.setCustomValidity("");
        }
        address2.reportValidity();
    }
    handleBarrowerParmaAddressPin(event) {
        this.permanentAddressData.KYC_Pin_Code__c = event.target.value;
        
        if (this.permanentAddressData.KYC_Pin_Code__c && this.permanentAddressData.KYC_Pin_Code__c.length >= 2) {
            if (parseInt(this.permanentAddressData.KYC_Pin_Code__c.substring(0, 2)) < this.minPermanentState || parseInt(this.permanentAddressData.KYC_Pin_Code__c.substring(0, 2)) > this.maxPermanentState) {
                let KycPinCodeDataIdInput = this.template.querySelector('lightning-input[data-id=KycPinCodeDataPId]');
                KycPinCodeDataIdInput.setCustomValidity("Invalid pin code");
                KycPinCodeDataIdInput.reportValidity();
            } else {
                let KycPinCodeDataIdInput = this.template.querySelector('lightning-input[data-id=KycPinCodeDataPId]');
                KycPinCodeDataIdInput.setCustomValidity("");
            }
        }
    }
    handleBarrowerParmaAddressCity(event) {
        this.permanentAddressData.KYC_City__c = event.target.value;
    }
    handleBarrowerParmaAddressDistrict(event) {
            this.permanentAddressData.KYC_District__c = event.target.value;
            this.districtValue = event.target.value;
            this.stateValue = this.template.querySelector('lightning-combobox[data-id=kycStateDataPId]').value;
            //this.isLoading = true;
           }
    handleBarrowerParmaAddressState(event) {
        this.permanentAddressData.KYC_State__c = event.target.value;
        for (let index = 0; index < this.allStateData.length; index++) {
            if (this.allStateData[index].value == this.permanentAddressData.KYC_State__c) {
                this.minPermanentState = this.allStateData[index].stateMinValue;
                this.maxPermanentState = this.allStateData[index].stateMaxValue;
            }
        }this.perStateValue = this.permanentAddressData.KYC_State__c; //SFTRAC-1660
        this.isLoading = true;
        getCityStateMaster({ stateName: this.permanentAddressData.KYC_State__c }).then(response => {
            let cityData = [];
            if (response && response.length > 0) {
                for (let index = 0; index < response.length; index++) {
                    let cityObject = {};
                    cityObject.label = response[index].Name;
                    cityObject.value = response[index].Name;
                    cityObject.id = response[index].Id;
                    cityData.push(cityObject);
                }
            }
            this.permanentCityValue = cityData;
            this.isLoading = false;
        }).catch(error => {
            this.showToastMessage('', 'Error in getting City Details', 'error');
        });
        this.isLoading = true;
        getDistrictsByState({ stateName: this.permanentAddressData.KYC_State__c }).then(response => {
            let cityData = [];
            if (response && response.length > 0) {
                for (let index = 0; index < response.length; index++) {
                    let cityObject = {};
                    cityObject.label = response[index].Name;
                    cityObject.value = response[index].Name;
                    cityObject.id = response[index].Id;
                    cityData.push(cityObject);
                }
            }
            this.permanentDistrictValue = cityData;
            this.isLoading = false;
        }).catch(error => {
            this.isLoading = false;
            this.showToastMessage('', 'Error in getting District Details', 'error');
        });
        this.getTaluka(this.permanentAddressData.KYC_State__c,'PermanentAddress'); //SFTRAC-1660 added
    }
    async captureCurrentAddress() {//CISP-3052
        let result = await helper.currentAddressLineValidation(this);
        if(result){ return;}
        this.typeOfAddress = 'CurrentAddress';
        if (FORM_FACTOR === 'Large') {
            if (this.currentAddressDisable == true) {
                this.updateCurrentPermanentAddress();
            } else {
            this.saveCurrent(true);
            }
        } else {
            if (this.currentAddressDisable == true) {
                this.updateCurrentPermanentAddress();
            }else if (this.isAddressDeclaration) { //SFTRAC-454
                this.saveCurrent(true);
            } else {
                this.modalPopUpCaptureImage = true; //ind-2116
                this.smallFactorUpload = true; //ind-2116
            }//CISP-3052
        }
    }
    async capturePermanentAddress() {
        let result = await helper.permanentAddressLineValidation(this);
        if(result){ return;}
        this.typeOfAddress = 'PermanentAddress';
        //this.savePermanent(true); //ind-2116
        if (FORM_FACTOR === 'Large') {
            if (this.permanentAddressDisable == true) {
                this.updateCurrentPermanentAddress();
            } else {
            this.savePermanent(true);
            }
        } else {
            if (this.permanentAddressDisable == true) {
                this.updateCurrentPermanentAddress();
            } else {
            this.modalPopUpCaptureImage = true; //ind-2116
            this.smallFactorUpload = true; //ind-2116
            }
        }
    }
    updateCurrentPermanentAddress() {
        const CRAddressfields = {};
        const PRAddressfields = {};
        if (this.currentAddressData) {
            CRAddressfields['Id'] = this.currentAddressData.Id;
            CRAddressfields['Village__c'] = this.currentVillage;
            CRAddressfields['Landmark__c'] = this.currentlandmarkData;
            CRAddressfields['Taluka__c'] = this.curTalukaValue;CRAddressfields['Taluka_Id__c'] = this.curTalukaId; //SFTRAC-1660
            CRAddressfields['Current_Residential_Address_Proof__c'] = true;
        }
        if (this.permanentAddressData) {
            PRAddressfields['Id'] = this.permanentAddressData.Id;
            PRAddressfields['Village__c'] = this.permanentVillageData;
            PRAddressfields['Landmark__c'] = this.permanentLandmark;
            PRAddressfields['Taluka__c'] = this.perTalukaValue;PRAddressfields['Taluka_Id__c'] = this.perTalukaId;  //SFTRAC-1660
            PRAddressfields['Permanent_Residential_Address_Proof__c'] = true;
            const applicantFields = {};
            applicantFields['Id'] = this.applicantId;
            applicantFields['Is_this_current_residence_cum_office__c'] = this.isResiCumOfficeAddress;
            if(this.isResiCumOfficeAddress == true){
                this.currentTractorFieldDisable = true;
                this.fetchDocumentCurrentAddress = true;
                PRAddressfields['Current_Residential_Address_Proof__c'] = true;
            }
            this.updateRecordDetails(applicantFields);
        }
        if (this.typeOfAddress == 'CurrentAddress')
            this.updateRecordDetails(CRAddressfields);
        else
            this.updateRecordDetails(PRAddressfields);

    }
    addressHandler(event) {
        //CISP-10087 Start
        if(this.isPermanentAddressNotPresent && event.target.value == 'Permanent Address') {
            this.template.querySelector('lightning-combobox[data-id=preferedAddress]').value = undefined;
            this.showToastMessage(this.errorTitle, 'Permanent address cannot be selected as communication address', this.errorVariant);
        } else { //CISP-10087 End
            this.Addressvalue = event.target.value;
        }
        if(this.Addressvalue == 'Office Address'){if(this.tabData !== Borrower && this.isTractor){this.isBeneOffice = true;}}
        else{this.isBeneOffice = false;}
    }
    PreferredAddressPicklist(){
        if(!this.incomeSource || (this.isTractor && this.isTractorIndividual)){
            this.optionsPicklist('Office Address');
        } else if((this.isTractor && this.isNonIndividual && this.tabData === 'Borrower')){
            this.optionsPicklist('Permanent Address');
        } else{
            this.preferredAddressForCommunicationPicklist  = this.preferredAddressForCommunicationValue.data.values;
        }
    }
    familyMemeberHandler(event) {
        this.familyMemberValue = event.target.value;
    }
    countryHandler(event) {
        this.countryValue = event.target.value;
    }
    //Added for SFTRAC-82 by Prashant Dixit
    openBankAccountHandler(event){
        this.openNewBankAccount = event == false ? false : event.target.checked;
        this.isOpenNomineeDetialSection = this.openNewBankAccount;
        if (this.template.querySelector('lightning-input.openBankAcct')) {
            this.template.querySelector('lightning-input.openBankAcct').checked = this.openNewBankAccount;
        }
    }
    repayLoanHandler(event) {
        this.repayLoanValue = event.target.value;
if(this.isTractor){
            this.isOpenBankAccountWithIBLfunction();
            if(this.isNonIndividual == false){ //SFTRAC - 308
                this.wouldYouLikeToOpenBankAccount = true;
            }
            this.isWhoWillRepayTheLoanChanged = true;
            this.repayByApplicantId = this.repayLoanValue;
            this.repayLoanLabel = this.whoWillRepayLoan.filter(element=>{return element.value == this.repayLoanValue})[0].label;
            this.selectedApplicantType = this.repayLoanLabel?.split("(")[0];
        }
    }
    async isOpenBankAccountWithIBLfunction(){
        this.disabledOpenBankAcc =  await isOpenBankAccountWithIBL({applicantId: this.repayLoanValue});
        this.openBankAccountHandler(false);
    }
    handleNomineeFieldValueChange(event){
        helper.handleNomineeFieldValueChangeHelper(this, event);
    }
    saveNomineeDetails(){
        helper.saveNomineeDetailsHelper(this);
    }
    maritalStatusHandler(event) {
        this.maritalStatusValue = event.target.value;
        this.spouseNameValue='';
        if (this.maritalStatusValue === 'MARR' || this.maritalStatusValue === 'Married') {//Start CISP-2759
            this.requiredSpouseValue = true;
            this.demographiSpouseieldsDisable = false;
        } else {
            this.requiredSpouseValue = false;
            this.demographiSpouseieldsDisable = true;
        }//End CISP-2759
    }
    communicationLangHandler(event) {
        this.communicationValue = event.target.value;
    }
    handleQualificationType(event) {
        this.qualificationValue = event.target.value;
    }
    handleRelationshipType(event) {
        let inputLabel = event.target.label;
        if (inputLabel && inputLabel == 'relationRef1') {
            this.relationRef1Value = event.target.value;
        }else if(inputLabel && inputLabel == 'relationRef2'){
            this.relationRef2Value = event.target.value;
        }else{
            this.relationshipValue = event.target.value;
        }
    }
    validateInputsFields() {
        return helper.helperValidate(this);
    }
    async updateRecordDetails(fields) {
        const recordInput = { fields };
        await updateRecord(recordInput).then(() => {
            if (this.isTractorFinance) {
                if (this.typeOfAddress == 'CurrentAddress') {
                    this.currentTractorFieldDisable = true;
                }
                else if (this.typeOfAddress == 'PermanentAddress') {
                    this.parmanentTractorFieldDisable = true;
                }
                if(this.isNomineeDetailSaved){
                    this.disableAllNomineeAndRepayField = true;
                    this.disabledOpenBankAcc = true;
                    this.disbaleWhoWillRepayTheLoan = true;
                }
            }

        }).catch(error => {});
    }
    renderedCallback() {
        loadStyle(this, LightningCardCSS);
        if (this.currentStage === 'Credit Processing') {
            this.disableEverything();
            this.isEnableNext = true;
            this.disableNext = false;
            if (this.template.querySelector('.next')) {
                this.template.querySelector('.next').disabled = false;
            }
        }
                if(this.isTractor && this.tabData === Borrower && this.repaymentWillBeDoneBy){
            this.isOpenNomineeDetialSection =this.openNewBankAccount;
            if (this.template.querySelector('lightning-input.openBankAcct')) {
                this.template.querySelector('lightning-input.openBankAcct').checked = this.openNewBankAccount;
            }
        }
    }
    handleCustomValidationEmailIdBorrower(event) {
        this.emailValue = event.target.value;
        let emailInput = this.template.querySelector('lightning-input[data-id=EmailId]');
        let emailValue = emailInput.value;
        this.emailValue = emailValue;
        let EmailId = this.template.querySelector("[data-id='EmailId']");
        let EmailIdvalue = EmailId.value;
            if((EmailIdvalue === '' || EmailIdvalue === null) && !this.isTractor)
            {//CISP-18736
              this.isEmailVerifiedDisabled = true;
              this.unverified_Invalid_Email = false;
              EmailId.setCustomValidity(completeField);
            }
          else
          {
            this.isEmailVerifiedDisabled = false;
            const validateEmailId = (email) => {
                return String(email).toLowerCase().match(/^([\w-\.]+)@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.)|(([\w-]+\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})(\]?)$/);//CISP-18736
            };
            if (validateEmailId(EmailId.value) == null) {
                EmailId.setCustomValidity(Email_Invalid);
                this.unverified_Invalid_Email = true;//CISP-18736
            } else {
                EmailId.setCustomValidity("");
                EmailId.reportValidity();
                this.unverified_Invalid_Email = false;
                this.emailValue = EmailIdvalue;
                return true;
            }
        }EmailId.reportValidity();}
    handleFailEmailAttempts(emaildToStore, emailStatus) {
        getFailEmailValue({ applicantId: this.applicantId }).then(result => {
            const appFields = {};
            appFields[APP_ID_FIELD.fieldApiName] = this.applicantId;
            if (result >= 3) {
                appFields[emailId3.fieldApiName] = emaildToStore;
                appFields[emailId3Status.fieldApiName] = emailStatus;
                this.showToastMessage(this.errorTitle, Email_Attempts_are_exhausted, this.errorVariant);
                if(!this.isEmailVerifiedTick){
                    this.isEmailVerifiedCross = true;

                }
                this.isEmailVerified = true;
                this.isEmailVerifiedDisabled = true;
                this.demographiEmailFieldsDisable = true;
            } else if (result == 1) {
                appFields[emailId1.fieldApiName] = emaildToStore;
                appFields[emailId1Status.fieldApiName] = emailStatus;
            } else if (result == 2) {
                appFields[emailId2.fieldApiName] = emaildToStore;
                appFields[emailId2Status.fieldApiName] = emailStatus; 
            }

             if(emailStatus === 'Valid'){
                appFields[emailIdField.fieldApiName] = emaildToStore;
             }

            this.updateRecordDetails(appFields);
            this.isLoading = false;
        }).catch(error => {
            this.isLoading = false;
        }).finally(()=>{
            this.isLoading = false;
        });
    }
    validateEmail() {
        if(this.unverified_Invalid_Email)
        {
            this.showToastMessage(this.errorTitle, Ivalid_Email_Error_Message, this.errorVariant);
            return;
        }//CISP-18736
        this.isLoading = true;
        let kycEmailDetails = {
            leadId: this.recordid,
            loanApplicationId: this.recordid,
            email: this.emailValue
        };
       if (this.emailValue) {
            doEMAILCHECKCallout({emailVerifyRequest: JSON.stringify(kycEmailDetails)}).then(result => {
                const obj = JSON.parse(result);
                if (JSON.parse(obj.ResponseData.Fields.Applicants.Applicant.Services.Service[0].Operations.Operation[0].Data.Response.DSEmailVerificationData.Response.Data.RawResponse).email_validation.status === 'valid') {
                    this.showToastMessage(this.successTitle, Email_Verification_Done, this.successVariant);
                    this.isEmailVerifiedTick = true;
                    this.isEmailVerifiedCross = false;
                    this.isEmailVerifiedDisabled = true;
                    this.demographiEmailFieldsDisable = true;
                    emailVerifyPass({ applicantId: this.applicantId });
                    this.isEmailVerifiedDisabled = true;
                    this.isEmailVerified = true;
                    this.handleFailEmailAttempts(this.emailValue, 'Valid');
                } else if (JSON.parse(obj.ResponseData.Fields.Applicants.Applicant.Services.Service[0].Operations.Operation[0].Data.Response.DSEmailVerificationData.Response.Data.RawResponse).email_validation.status === 'invalid') {
                    this.showToastMessage(this.errorTitle, Invalid_Email_Please_Re_enter_new_Email, this.errorVariant);
                    this.handleFailEmailAttempts(this.emailValue, 'Invalid');
                    this.emailValue = '';
                    // this.isLoading = false;
                    // this.emailValue = event.target.value = null;
                } else if (JSON.parse(obj.ResponseData.Fields.Applicants.Applicant.Services.Service[0].Operations.Operation[0].Data.Response.DSEmailVerificationData.Response.Data.RawResponse).email_validation.status === 'unverifiable') {
                    this.showToastMessage(this.errorTitle, Please_Re_enter_Email_Id, this.errorVariant);
                    this.handleFailEmailAttempts(this.emailValue, 'Unverifiable');
                    this.emailValue = '';
                    emailBlackListed({ applicantId: this.applicantId });
                } else {
                    this.showToastMessage(this.errorTitle, 'Email Id is Blacklisted - ' +Kindly_Retry, this.errorVariant);
                    this.handleFailEmailAttempts(this.emailValue, 'Blacklisted');
                    this.emailValue = '';
                }
            }).catch(error => {
                this.handleFailEmailAttempts(this.emailValue, 'Unverifiable');
                this.showToastMessage(this.errorTitle, Kindly_Retry, this.errorVariant);
                this.emailValue = '';
                console.log('doEMAILCHECKCallout - Error::', error);
            }).finally(()=>{
                this.isLoading = false;
            })
        } else {
            this.isLoading = false;
            this.showToastMessage(this.errorTitle, 'Please enter Email Id', this.errorVariant);
        }
    }
    kycDeleteHandler(currentAddressFileId, isDone, isCancel, contentDocumentData) { 
        kycDelete({ documentId: currentAddressFileId, isDone: isDone, isCancel: isCancel, contentDocumentData: contentDocumentData }).then(result => {
            this.isCancel = true;
            this.isDone = true;
        }).catch(error => {
            this.isCancel = true;
            this.isDone = true;
            this.isLoading = false;
        });
    }
    captureCustomerImageClose() {
        helper.captureCustomerimageHelper(this);
    }
    async captureImageDone() {
        this.modalPopUpCaptureImage = false;    
        if (FORM_FACTOR != 'Large') {
            await getUploadDocument({ applicantId: this.applicantId,docType: this.uploadDocumentType }).then(response => {
                if(this.typeOfAddress=='CurrentAddress'){
                    this.currentResidentId = response;
                    this.saveCurrent(true);
                } else if(this.typeOfAddress=='PermanentAddress'){
                    this.permanentResidentId = response;
                    this.savePermanent(true);
                }
            }).catch(error => {
                console.log('getDistrictsByState - Error::', error);
            });

            await checkUploadDocument({ applicantId: this.applicantId, docType: this.uploadDocumentType }).then(result => {
                if(result){
                    if(this.captureCurrentAddressFlag){
                        this.currentValidity = true;
                        this.captureCurrentAddressFlag = true;
                        this.fetchDocumentCurrentAddress = true;
                        this.documentUploaded(result); 
                        this.documentId = result;
                        this.documentToDelete = result;
                    }   

                    if(this.capturePermanentAddressFlag){
                        this.capturePermanentAddressFlag = true;
                        this.fetchDocumentPermanentAddress = true;
                        this.permanentValidy = true;
                        this.documentUploaded(result); 
                        this.documentId = result;
                        this.documentToDelete = result;  
                    }
                    this.showToastMessage(this.successTitle, All_Details_Stored_Sucessfully, this.successVariant);
                }
                else{
                    this.kycDeleteHandler(this.documentId, false, true, this.documentToDelete);
                    this.showToastMessage('Error', 'Please Upload Document Again', 'error');
                }
            }).catch(error => {
                console.log('getUploadDocument - Error::', error);
            });
        }else {
            this.documentUploaded(this.documentToDelete);
            this.showToastMessage(this.successTitle, All_Details_Stored_Sucessfully, this.successVariant);
        }  
    }
    documentNumber;
    isFileuploaded = false;
    handleDocNumber(event) {
        this.documentNumber = event.detail.value;
        const fields = {};
        fields[DOCUMENT_NUMBER.fieldApiName] = this.documentNumber; 
        fields[DOC_ID_FIELD.fieldApiName] = this.currentAddressFileId;
        var objRecordInput = {fields};
        updateRecord(objRecordInput).then(response => {
            console.debug(response);
        }).catch(error => {
            console.error('Error: ' +JSON.stringify(error));
        });
        if(this.isFileuploaded && this.documentNumber){
            this.isDone = false;
        }else{
            this.isDone = true;
        }
        
    }
    callCheckUploadDocument(){
        checkUploadDocument({ applicantId: this.applicantId, docType: this.uploadDocumentType }).then(result => {
            if(result){
                if(this.captureCurrentAddressFlag){
                    this.currentValidity = true;
                    this.captureCurrentAddressFlag = true;
                    this.fetchDocumentCurrentAddress = true;
                    this.documentUploaded(result);
                    this.documentId = result;
                    this.documentToDelete = result;
                    this.currentTractorFieldDisable = true;
                }
                if(this.capturePermanentAddressFlag){
                    this.capturePermanentAddressFlag = true;
                    this.fetchDocumentPermanentAddress = true;
                    this.permanentValidy = true;
                    this.documentUploaded(result);
                    this.documentId = result;
                    this.documentToDelete = result;
                    this.parmanentTractorFieldDisable = true;
                    if(this.isResiCumOfficeAddress == true){
                        this.currentTractorFieldDisable = true;
                        this.fetchDocumentCurrentAddress = true;
                    }
                }
                this.showToastMessage(this.successTitle, All_Details_Stored_Sucessfully, this.successVariant);
            } else {
                this.kycDeleteHandler(this.documentId, false, true, this.documentToDelete);
                this.showToastMessage('Error', 'Please Upload Document Again', 'error');
                this.uploadDisable = false;//ind-2116
            }
        }).catch(error => {
        });
    }
    showToastMessage(title, message, variant) {
        helper.showToastMessage(this, title, message, variant);
    }
    
    showToastMessageModeBased(title, message, variant, mode) {
        helper.showToastMessageModeBased(this, title, message, variant, mode);
    }
    
    handleUploadFinished(event) {
        this.documentToDelete = event.detail.files[0].documentId
        this.isCancel = false;
        this.isFileuploaded = true;
        if(this.isNonIndividual && !this.documentNumber){
            this.isDone = true;
            this.showToastMessage('Error', 'Please Enter Document Number', this.errorVariant);
        }else{
            this.isDone = false;
        }
        

        this.showToastMessage('Uploaded', this.label.imageuploaded, 'success');
        if(this.currentValidity && this.typeOfAddress=='CurrentAddress') {
            this.fetchDocumentCurrentAddress = true;
            this.currentAddressDisable = true;
            this.currentTractorFieldDisable = true;
            this.currentAddressData.isUploadSuccessful = false;
        } else if (this.permanentValidy && this.typeOfAddress=='PermanentAddress') {
            this.fetchDocumentPermanentAddress = true;
            this.permanentAddressDisable = true;
            this.parmanentTractorFieldDisable = true;
            this.permanentAddressData.isUploadSuccessful = false;
        }
    }
    closeErrorModel() {
        this.isError = false;
    }
    getDemographicData() {
        let demographicData = {
            applicantId: this.applicantId,
            spouseName: this.spouseNameValue,
            fatherName: this.fatherNameValue,
            motherName: this.motherNameValue,
            preferredAddressForCommunication: this.Addressvalue,
            ofFamilyMembersResidingWithYou: this.familyMemberValue,
            residenceCountry: (this.countryValue == null || this.countryValue == '' || this.countryValue == undefined) ? 'India' : this.countryValue,
            whoWillPayTheLoan: this.repayLoanValue,
            maritalStatus: this.maritalStatusValue,
            communicationLang: this.communicationValue,
            customerQualification: this.qualificationValue,
            emailId: this.emailValue,
            relationshipWithBorrower: this.relationshipValue
        };
        return demographicData;
    }
    handleHome() {
        this.saveExitFlag = true;
        this.saveAdditionalDetails('Home').then(result => {
            if(result){
                this.showToastMessage(this.successTitle, All_Details_Stored_Sucessfully, this.successVariant);         
                this.disbaleWhoWillRepayTheLoan = true;
               this.goToHome();
            } else {
                this.showToastMessage(this.errorTitle, 'Error in Saving Details', this.errorVariant);
            }
        }).catch(error => {
        });
        if(!this.currentAddressDisable){
            this.saveCurrent(false);
        }
        if(!this.permanentAddressDisable){
            this.savePermanent(false);
        }
    }
    goToHome(){
        isCommunity().then(response => {
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
        }).catch(error => {
        });
    }
    async validateSubmit() {
        let validationStatus = {'allowedSave': true,'allowedSubmit': true};
        await getAdditionalDetailsSubmittedValue({ opportunityId: this.recordid}).then(applicantRecordDetails => {
            for(let i=0 ; i<applicantRecordDetails.length; i++){
                if( this.tabData === 'Borrower' && ( applicantRecordDetails[i].Applicant_Type__c === 'Co-borrower' ||  applicantRecordDetails[i].Applicant_Type__c === 'Guarantor' ) && applicantRecordDetails[i].Is_Additional_Details_Submitted__c === false){
                    this.showToastMessage('', applicantRecordDetails[i].Applicant_Type__c === 'Co-borrower'?'Submit Co-Borrower details to Proceed further':'Submit Guarantor details to Proceed further', 'info');
                    validationStatus.allowedSave = true;
                    validationStatus.allowedSubmit = false;
                    break;
                } else if(this.tabData === 'Co-borrower' && (applicantRecordDetails[i].Applicant_Type__c === 'Borrower' || applicantRecordDetails[i].Applicant_Type__c === 'Guarantor') && applicantRecordDetails[i].Is_Additional_Details_Submitted__c === false){
                    this.showToastMessage('', applicantRecordDetails[i].Applicant_Type__c === 'Borrower'?'Submit Borrower details first':'Submit Guarantor details to Proceed further', 'info');
                    validationStatus.allowedSave = true;
                    validationStatus.allowedSubmit = false;
                    break;
                } else if(this.tabData === 'Guarantor' && (applicantRecordDetails[i].Applicant_Type__c === 'Borrower' || applicantRecordDetails[i].Applicant_Type__c === 'Co-borrower') && applicantRecordDetails[i].Is_Additional_Details_Submitted__c === false){
                    this.showToastMessage('', applicantRecordDetails[i].Applicant_Type__c === 'Borrower'?'Submit Borrower details first':'Submit Co-borrower details first', 'info');
                    validationStatus.allowedSave = true;
                    validationStatus.allowedSubmit = false;
                    break;
                } else if(this.tabData !== 'Beneficiary' && applicantRecordDetails[i].Applicant_Type__c === 'Beneficiary' && applicantRecordDetails[i].Is_Additional_Details_Submitted__c === false){
                    this.showToastMessage('', 'Submit All Beneficiary details first', 'info');
                    validationStatus.allowedSave = true;
                    validationStatus.allowedSubmit = false;
                    break;
                } else if(this.isTractor && applicantRecordDetails[i].Id !== this.currentTabId && applicantRecordDetails[i].Is_Additional_Details_Submitted__c === false){
                    this.showToastMessage('', `Submit ${applicantRecordDetails[i].Applicant_Type__c}  details first!`, 'info');
                    validationStatus.allowedSave = true;
                    validationStatus.allowedSubmit = false;
                    break;
                }
            }
        }).catch(error => { 
            validationStatus.allowedSave = false;
            validationStatus.allowedSubmit = false;
            return validationStatus;
        });
        return validationStatus;
    }
    async navigateToNextModuleTF(allowedSubmit){//CISP-3224-START
        try{
            let response = await this.callLoanApplicationHistory('Asset Details');
            let result = true;
            if(this.isTractor && allowedSubmit){
                result = await helper.crossCoreHelper(this);
            }
            if (result){
                const fields = {};fields[OPP_ID_FIELD.fieldApiName] = this.applicantId;fields[IS_ADDITIONAL_DETAILS_SUBMITTED.fieldApiName] = true;
                const recordInput = {
                    fields
                };
                updateRecord(recordInput).then(result => {});
            }
            if (allowedSubmit && result){
                try{
                    let cmuIsCreated = false;
                    try{
                        cmuIsCreated = await this.callCMU();
                     } catch (error) {
                        cmuIsCreated = false;
                     }
                    if (cmuIsCreated && !response){
                        const fields = {};
                fields[OPP_ID_FIELD.fieldApiName] = this.recordid;
                fields[STAGE_NAME_FIELD.fieldApiName] = 'Asset Details';
                fields[LAST_STAGE_NAME_FIELD.fieldApiName] = 'Asset Details';
                const recordInput = { fields };
                updateRecord(recordInput).then(() => {
                    //CISP-2897
                    this.isLoading = false;
                    this.disableSubmitButton = true;//CISP-3224
                    this.dispatchEvent(new CustomEvent('submitnavigation', { detail: 'Asset Details' }));//CISP-3224
                    // CISP-3224-END
                }).catch(error => {
                    //CISP-2897
                    this.isLoading = false;
                    this.disableSubmitButton = false;
                });//CISP-3224-START
                    }else if(!cmuIsCreated && !response){
                        this.showToastMessage('', 'CMU case is not created.', 'warning');
                        this.isLoading = false;
                        this.disableSubmitButton = false;
                    }else{
                        this.isLoading = false;
                        this.disableSubmitButton = true;
                    }
                }catch (error) {
                 this.isLoading = false;
                 this.disableSubmitButton = false;
                 this.showToastMessage(this.errorTitle, 'Error in navigating to Next Module', this.errorVariant); // CISP-2897
             }
            }else {
                //this.showToastMessage('', 'CMU case is not created.', 'warning');
                this.isLoading = false;
                this.disableSubmitButton = false;
            }
        } catch (error) {
            this.isLoading = false;
            this.disableSubmitButton = false;
            console.error('Unexpected error:', error);
        }
    }
    async navigateToNextModule(){
        try{
            let response = await this.callLoanApplicationHistory('Asset Details');
            let validityResult = await this.validateRiskBand();
            console.log('validityResult___' + JSON.stringify(validityResult));
            if (validityResult.checkriskband){
                let cmuIsCreated = false;
                            try {
                                cmuIsCreated = await this.callCMU();
                            } catch (error) {
                                cmuIsCreated = false;this.isLoading = false;
                            }
                        if (cmuIsCreated && !response) { //CISP-3224-END
                            const fields = {};
                            fields[OPP_ID_FIELD.fieldApiName] = this.recordid;fields[STAGE_NAME_FIELD.fieldApiName] = 'Asset Details';fields[LAST_STAGE_NAME_FIELD.fieldApiName] = 'Asset Details';
                            const recordInput = {
                                fields
                            };
                            updateRecord(recordInput).then(() => {
                                //CISP-2897
                                this.isLoading = false;this.disableNext=true;this.oppStageName = 'Asset Details';
                                this.dispatchEvent(new CustomEvent('submitnavigation', {
                                    detail: 'Asset Details'
                                }));
                            }).catch(error => {
                                //CISP-2897
                                this.isLoading = false;this.disableNext=false;
                            }); //CISP-3224-START
                        } else if (!cmuIsCreated && !response) {
                            this.showToastMessage('', 'CMU case is not created.', 'warning');
                            this.isLoading = false;this.disableNext=false;
                        } else { this.isLoading = false;this.disableNext=false;}
            }else {
                this.showToastMessage('', 'Please click Get Risk Band for Applicants and then click Next button to proceed further', 'info');this.isLoading = false;this.disableNext=false;
            }
        }catch (error) {
            this.isLoading = false;this.disableNext=false;
            console.error('Unexpected error:', error);
        }
    }
    async validateRiskBand(){
        let validationStatus = {
            'checkriskband': true
        };
        await getRiskBandStatusValue({
            opportunityId: this.recordid
        }).then(applicantRecordDetails => {
            console.log('applicantRecordDetails___'+JSON.stringify(applicantRecordDetails));
            for (let i = 0; i < applicantRecordDetails.applicantList.length; i++) {
                let scoreCardDecision = applicantRecordDetails.applicantList[i]?.Scorecard_Decision__c;
                if (this.tabData == 'Borrower' && (applicantRecordDetails.applicantList[i]?.Applicant_Type__c=== 'Co-borrower' || applicantRecordDetails.applicantList[i]?.Applicant_Type__c === 'Guarantor') && ((scoreCardDecision==undefined || scoreCardDecision=='' || scoreCardDecision==null) && applicantRecordDetails.coBorrowerRiskBandCount.toLowerCase()=='Safe'.toLowerCase())){
                    validationStatus.checkriskband = false;
                    break;
                } else if ((this.tabData == 'Co-borrower' || this.tabData === 'Guarantor') && (applicantRecordDetails.applicantList[i]?.Applicant_Type__c=== 'Borrower') && ((scoreCardDecision==undefined || scoreCardDecision=='' || scoreCardDecision==null) && applicantRecordDetails.borrowerRiskBandCount.toLowerCase() == 'Safe'.toLowerCase())){
                    validationStatus.checkriskband = false;
                    break;
                }else if(this.tabData == 'Borrower' && (applicantRecordDetails.applicantList[i]?.Applicant_Type__c=== 'Borrower') && ((scoreCardDecision==undefined || scoreCardDecision=='' || scoreCardDecision==null) && applicantRecordDetails.borrowerRiskBandCount.toLowerCase() == 'Safe'.toLowerCase())){
                    validationStatus.checkriskband = false;
                    break;
                }
                else if((this.tabData == 'Co-borrower' || this.tabData === 'Guarantor') && (applicantRecordDetails.applicantList[i]?.Applicant_Type__c=== 'Co-borrower' || applicantRecordDetails.applicantList[i]?.Applicant_Type__c === 'Guarantor') && ((scoreCardDecision==undefined || scoreCardDecision=='' || scoreCardDecision==null) && applicantRecordDetails.coBorrowerRiskBandCount.toLowerCase() == 'Safe'.toLowerCase())){
                    validationStatus.checkriskband = false;
                    break;
                }
            }
        }).catch(error => {
            validationStatus.checkriskband = false;
            return validationStatus;
        });
        return validationStatus;
    }

    async callCMU(){
        let cmuIsCreated=false;
        await verifyCMU({
            applicationID: this.recordid
        }).then(() => {
            cmuIsCreated = true;
        }).catch(error => {
            cmuIsCreated = false;
            this.isLoading=false;
        });
        return cmuIsCreated;
    }
    
    callBREScoreCardAPI(event) {helper.callBREScoreCardAPI(this,event);}

    async callLoanApplicationHistory(nextStage){
        let response = await getLoanApplicationHistory({ loanId: this.recordid, stage: 'Additional Details',nextStage: nextStage});
        if(response){ this.goToHome(); }
        return response;//CISP-3224-END
    }
    callAccessLoanApplication(){
        helper.callAccessLoanApplicationHelper(this);
    }
    async saveAdditionalDetails(scope) {
        let isDetailsSaved = false;
        this.demogarphicData = {
           applicantId: this.applicantId, spouseName: this.spouseNameValue, fatherName: this.fatherNameValue, motherName: this.motherNameValue, preferredAddressForCommunication: this.Addressvalue, ofFamilyMembersResidingWithYou: this.familyMemberValue, residenceCountry: this.countryValue, whoWillPayTheLoan: this.isTractor? this.selectedApplicantType:this.repayLoanValue, repaymentWillBeDoneBy: this.isTractor? this.repayLoanValue:'', maritalStatus: this.maritalStatusValue, communicationLang: this.communicationValue, customerQualification: this.qualificationValue, emailId: this.emailValue, relationshipWithBorrower: this.relationshipValue, SubmitSuccessfullCheckbox: false, nameRef1: this.nameRef1Value, relationshipWithBorrowerRef1: this.relationRef1Value, addressLine1Ref1: this.addressLine1Ref1Value, addressLine2Ref1: this.addressLine2Ref1Value, stateRef1: this.stateRef1Value, districtRef1: this.districtRef1Value, cityRef1: this.cityRef1Value, pincodeRef1: this.pincodeRef1Value, phoneNumberRef1: this.phoneNumberRef1Value, nameRef2: this.nameRef2Value, relationshipWithBorrowerRef2: this.relationRef2Value, addressLine1Ref2: this.addressLine1Ref2Value, addressLine2Ref2: this.addressLine2Ref2Value, StateRef2: this.stateRef2Value, DistrictRef2: this.districtRef2Value, CityRef2: this.cityRef2Value, pincodeRef2: this.pincodeRef2Value, phoneNumberRef2: this.phoneNumberRef2Value, religion: this.religionValue, caste: this.casteValue, coborrowerResideBorrower : this.coborrowerResideWithBorrower, salutation: this.demogarphicDataFields.Salutation__c, gender: this.demogarphicDataFields.Gender__c , category: this.demogarphicDataFields.Category__c , employerType: this.demogarphicDataFields.Employer_Type__c , dateOfBirth: this.demogarphicDataFields.Date_of_Birth__c , isCustomerNRI: this.demogarphicDataFields.Is_Customer_NRI__c ? this.demogarphicDataFields.Is_Customer_NRI__c : false, workPermitNo: this.demogarphicDataFields.Work_Permit_No__c , permitvalidity: this.demogarphicDataFields.Permit_Validity__c , workVisaDetails: this.demogarphicDataFields.Work_Visa_Details__c , legalEntityIdentifier: this.demogarphicDataFields.LegalEntityIdentifier__c, categoryType: this.isSalaried ? 'Salaried' : this.isSelfEmployed ? 'Self employed' : '', beneadd1: this.checkNonIndividual ? this.beneadd1 : null, beneadd2: this.checkNonIndividual ? this.beneadd2 : null, benestate: this.checkNonIndividual ? this.benestate : null, benedistrict: this.checkNonIndividual ? this.benedistrict : null, benecity: this.checkNonIndividual ? this.benecity : null, benepincode: this.checkNonIndividual ? this.benepincode : null,feedbackRef1 : this.feedbackRef1Value, feedbackRef2 : this.feedbackRef2Value
        };
        await saveAdditionalDetails({ demoGraphicDataString: JSON.stringify(this.demogarphicData) }).then(result => {
            if(result){
                this.showToastMessage(this.successTitle, All_Details_Stored_Sucessfully, this.successVariant);
                this.disbaleWhoWillRepayTheLoan = true;
                isDetailsSaved = true;
            } else {
                this.showToastMessage('', 'Error in Saving Details', 'warning');
            }
        }).catch(error => {
        })


        if(this.isTractor && !this.isNotNonIndividualTractorBorrower){
            let errormsg = await documentValidation({borrowerId:this.borrowerId,entityType:this.entityCategory,resicumoffice:this.isResiCumOfficeAddress});if(errormsg != null){this.showToastMessage('Documents Not Uploaded!!',errormsg, 'warning', 'sticky');isDetailsSaved = 'false';}
        }

        return isDetailsSaved;
    }
    nomineeCitylookupHandler(event){
        helper.nomineeCitylookupHandlerHelper(this,event);
    }
    nomineeCityClearvaluelookupHandler(event){
        helper.nomineeCityClearvaluelookupHandlerHelper(this);
    }
    async handleSubmit() {
        try {
            this.isLoading = true;
            this.disableSubmitButton = true;//CISP-2897

            if (this.currentStage === 'Credit Processing') {
                const nextStage = new CustomEvent('submit');
                this.dispatchEvent(nextStage);
                this.isLoading = false;
                this.disableSubmitButton = false;//CISP-2897
                return;
            }
       
            if (!this.validityCheck('.currentAddress')) {
                this.showToastMessage('','Fill all the Current Address details', 'warning');
                this.isLoading = false;
                this.disableSubmitButton = false;//CISP-2897
                return;
            }

            if (!this.validityCheck('.permanentAddress')) {
                this.showToastMessage('', 'Fill all the ' + ( this.isNotNonIndividualTractorBorrower ? 'Permanent' : 'Office') + ' Address details', 'warning');
                this.isLoading = false;
                this.disableSubmitButton = false;//CISP-2897
                return;
            }
            if(this.profile == 'NON RESIDENT_NRI & NRE'){
                    this.showToastMessage('','Sorry, you are not allowed to select this profile. Please select any other profile to proceed with the Journey', 'warning');this.isLoading = false;this.disableSubmitButton = false;//CISP-22625
                return;
            }
        
            if(!this.fetchDocumentCurrentAddress && !this.isAddressDeclaration){//CISP-2701
                this.showToastMessage('', 'Current Address Document Upload is Pending', 'warning');
                this.isLoading = false;
                this.disableSubmitButton = false;//CISP-2897
                return;
            }
            // CISP-3088-START
            if((!this.saveCurrentAddress && this.isAddressDeclaration ) || (this.isTractorFinance && !this.currentTractorFieldDisable)){//CISP-2701
                this.showToastMessage('', 'Please save current address details.', 'warning');
                this.isLoading = false;
                this.disableSubmitButton = false;//CISP-2897
                return;
            }
            // CISP-3088-END
            if(!this.fetchDocumentPermanentAddress && !this.isPermanentAddressNotPresent){
                this.showToastMessage('', ( this.isNotNonIndividualTractorBorrower ? 'Permanent' : 'Office') + ' Address Document Upload is Pending', 'warning');
                this.isLoading = false;
                this.disableSubmitButton = false;//CISP-2897
                return;
            }
            if (!this.validityCheck('.demographicDetails')) {
                this.showToastMessage('', 'Fill all the demographic details', 'warning');
                this.isLoading = false;
                this.disableSubmitButton = false;//CISP-2897
                return;
            }
            if(this.isTractor){ //SFTRAC-675
            if (!this.validityCheck('.referenceField1')) {
                this.showToastMessage('', 'Fill all the reference details', 'warning');
                this.isLoading = false;
                this.disableSubmitButton = false;//CISP-2897
                return;
            }
            if (!this.validityCheck('.referenceField2')) {
                this.showToastMessage('', 'Fill all the reference details', 'warning');
                this.isLoading = false;
                this.disableSubmitButton = false;//CISP-2897
                return;
            }
            }
            if (this.tabData === Borrower) {
                let result = helper.validateBorrowerInputs(this);
                if(result){return;}
            }
            if (this.tabData === CoBorrower) {
                let relationshipValueInput = this.template.querySelector('lightning-combobox[data-id=relationWithBorrower]');
                if(relationshipValueInput !== null){
                    relationshipValueInput.reportValidity();
                    if(!relationshipValueInput.value){
                        this.showToastMessage('', 'Fill all the demographic details', 'warning');
                        this.isLoading = false;
                        this.disableSubmitButton = false;//CISP-2897
                        return;
                    }
                }
            }
            if (this.tabData === Guarantor) {
                let relationshipValueInput = this.template.querySelector('lightning-combobox[data-id=relationWithBorrower]');
                if(relationshipValueInput !== null){
                    relationshipValueInput.reportValidity();
                    if(!relationshipValueInput.value){
                        this.showToastMessage('', 'Fill all the demographic details', 'warning');
                        this.isLoading = false;
                        this.disableSubmitButton = false;//CISP-2897
                        return;
                    }
                }
            }
            if (this.maritalStatusValue === 'MARR' && !this.spouseNameValue) {
                this.showToastMessage(this.errorTitle, 'Spouse Name is Mandatory', this.errorVariant);
                this.isLoading = false;
                this.disableSubmitButton = false;//CISP-2897
                return;
            }
            if (!this.isEmailVerified && (this.productType ==='Passenger Vehicles' || this.leadSource == 'OLA' || this.leadSource == 'Hero' || (this.emailValue != '' && this.emailValue != undefined))) { //CISP-2781 && OLA-180 && CISH-33
                this.showToastMessage(this.errorTitle, Please_Verify_Your_Email, this.errorVariant); this.isLoading = false;  this.disableSubmitButton = false;//CISP-2897
                return;
            }
            if(!this.isEmailVerified && (this.emailValue != '' && this.emailValue != undefined) && this.demographiEmailFieldsDisable == false)
            {
                this.showToastMessage(this.errorTitle, Please_Verify_Your_Email, this.errorVariant); this.isLoading = false;  this.disableSubmitButton = false;
                return;
            } // CISP-18736

            if(this.countryValue == null || this.countryValue == undefined || this.countryValue == ''){
                this.showToastMessage('', 'Fill all the demographic details', 'warning');
                this.isLoading = false;
                this.disableSubmitButton = false;
                return;
            }
            if(!this.referenceCustomerAvailable && this.productType == 'Tractor'){let res = await this.doPincodeBaseSearch(); if(!res){this.isLoading = false; this.disableSubmitButton = false;return;}}
            if(this.isTractor && !this.isNonIndividual){let result = await helper.willingValidation(this);if(!result){return}}
            await this.validateSubmit().then(validaityResult => {
                if(validaityResult.allowedSave){
                    this.saveAdditionalDetails('Submit').then(result => {
                        if(result && result === 'false'){
                            this.isLoading = false;
                            this.disableSubmitButton = false;
                        }else if(result){
                            this.showToastMessage(this.successTitle, All_Details_Stored_Sucessfully, this.successVariant); this.disableSubmitButton = true; this.disabledOpenBankAcc = true; this.submitGreenTickButton = true; this.demographiFieldsDisable = true; this.disbaleWhoWillRepayTheLoan = true;
                            if(this.isTractorFinance){this.navigateToNextModuleTF(validaityResult.allowedSubmit);this.demographiEmailFieldsDisable = true;this.disableMaritalStatus = true;this.demographiSpouseieldsDisable = true;}
                            if (!this.isTractorFinance) {
                                const fields = {};
                                fields[OPP_ID_FIELD.fieldApiName] = this.applicantId;
                                fields[IS_ADDITIONAL_DETAILS_SUBMITTED.fieldApiName] = true;
                                const recordInput = {
                                    fields
                                };
                                updateRecord(recordInput).then(result => {
                                    this.disableRiskBand = false;
                                    this.disableSubmitButton = true;
                                    this.disableNext = false;
                                }).catch(error =>{
                                    this.isLoading=false;this.disableSubmitButton = false;
                                });}
                        } else {
                            //CISP-2897
                            this.isLoading = false;
                            this.disableSubmitButton = false;
                            this.showToastMessage(this.errorTitle, 'Error in Saving Details', this.errorVariant);
                        }
                    }).catch(error => {
                        //CISP-2897
                        this.isLoading = false;
                        this.disableSubmitButton = false;
                        console.log('saveAdditionalDetails - Error:: ', error);
                    });
                }else{
                    //CISP-2897
                    this.isLoading = false;
                    this.disableSubmitButton = false;
                }
            }).catch(error => {
                //CISP-2897
                this.isLoading = false;
                this.disableSubmitButton = false;
                console.log('validateSubmit - Error:: ', error);
                this.showToastMessage(this.errorTitle, 'Error in navigating to Next Module', this.errorVariant);
            });
        } catch (error) {
            this.isLoading = false;
            this.disableSubmitButton = false;//CISP-2897
            console.log("Error - handleSubmit ::", error);
        }
    }
    documentUploaded(doc) {
        if (doc != null) {
            if (this.captureCurrentAddressFlag) {
                console.log('documentUploaded current ');
                this.fetchDocumentCurrentAddress = true; this.disableCurrentAddressProof = true; this.currentAddressDisable = true; this.currentValidity = true; this.isLoading = false;
            }
            if (this.capturePermanentAddressFlag) {
                console.log('documentUploaded permanent ');
                this.fetchDocumentPermanentAddress = true; this.permanentValidy = true; this.disablePermanentAddressProof = true; this.permanentAddressDisable = true; if(this.isResiCumOfficeAddress == true){ this.currentTractorFieldDisable = true; this.fetchDocumentCurrentAddress = true; } this.isLoading = false;
            }
        }
    }
    savePermanent(captureImage){
        if (this.permanentAddressData && Object.keys(this.permanentAddressData).length > 0) {console.log('savePermanent',this.isNotNonIndividualTractorBorrower);
            let permanentAddress = {
                id: this.permanentResidentId ? this.permanentResidentId : '', loanId: this.recordid, documentType: this.permanentDocumentType, name:this.permanentDocumentType, address1: this.permanentAddressData.KYC_Address_Line_1__c, address2: this.permanentAddressData.KYC_Address_Line_2__c, pincode: this.permanentAddressData.KYC_Pin_Code__c, city: this.permanentAddressData.KYC_City__c, district: this.permanentAddressData.KYC_District__c, state: this.permanentAddressData.KYC_State__c, isDisabled: this.permanentAddressData.isDisabled ? this.permanentAddressData.isDisabled : false, isCurrentAddress: false, village: this.permanentVillageData, landmark: this.permanentLandmark, residenceCumOffice : this.isResiCumOfficeAddress, poaFlag : this.isNotNonIndividualTractorBorrower == false ? true : false,talukaValue: this.perTalukaValue, talukaId: this.perTalukaId
            }
            saveDocumentData({ addressData: JSON.stringify(permanentAddress), applicantId: this.applicantId }).then(result => {
                this.currentAddressFileId = result;this.permanentResidentId = result;this.permanentValidy = true;
                if(captureImage){
                    this.uploadDocumentType = this.permanentDocumentType;this.capturePermanentAddressFlag = true;this.uploadDisable = false;
                    if (FORM_FACTOR === 'Large') {
                        this.largeFactorUpload = true;this.modalPopUpCaptureImage = true;//2116
                    } else {
                        this.smallFactorUpload = true;this.modalPopUpCaptureImage = false;//2116
                        this.callCheckUploadDocument();
                    }
                }
            }).catch(error => {});
        }
    }
    saveCurrent(captureImage){
        if (this.currentAddressData && Object.keys(this.currentAddressData).length > 0) {
          let currentAddress = {
            id: this.currentResidentId ? this.currentResidentId : '', loanId: this.recordid, documentType: this.currentdocumentType, name: this.currentdocumentType, address1: this.currentAddressData.KYC_Address_Line_1__c, address2: this.currentAddressData.KYC_Address_Line_2__c, pincode: this.currentAddressData.KYC_Pin_Code__c, city: this.currentAddressData.KYC_City__c, district: this.currentAddressData.KYC_District__c, state: this.currentAddressData.KYC_State__c, isDisabled: (this.isTractor && this.isCurrentAddressPresent) ? false : this.currentAddressData.isDisabled ? this.currentAddressData.isDisabled : false, isCurrentAddress: true, village: this.currentVillage, landmark: this.currentlandmarkData, poaFlag: this.isNotNonIndividualTractorBorrower == false ? true : false, talukaValue: this.curTalukaValue, talukaId: this.curTalukaId
            }
            saveDocumentData({addressData: JSON.stringify(currentAddress), applicantId: this.applicantId}).then(result => {
                this.currentAddressFileId = result; this.currentResidentId = result; this.currentValidity = true; this.uploadDisable = false;
                if(captureImage){
                    this.uploadDocumentType = this.currentdocumentType;
                    this.captureCurrentAddressFlag = true;
                    if(this.isAddressDeclaration){
                        this.saveCurrentAddress = true;//CISP-3088
                        this.modalPopUpCaptureImage = false;
                        this.currentAddressDisable = true;
                        this.showToastMessage(this.successTitle, All_Details_Stored_Sucessfully, this.successVariant);
                    }else{if (FORM_FACTOR === 'Large') {this.modalPopUpCaptureImage = true;this.largeFactorUpload = true;} else {this.smallFactorUpload = true;this.callCheckUploadDocument();}}}}).catch(error => {});}}
    openIntegratorApp(){this.isDone = false;this.isCancel= false;this.uploadDisable = true;this[NavigationMixin.Navigate]({type: "standard__webPage",attributes: {url: 'ibl://indusindbank.com/integratorInfo?' + 'leadId' + '=' + this.applicantId + '&' + 'userid' + '=' + this.currentUserId + '&' + 'mode' + '=' + this.uploadDocumentType + '&' + '	username' + '=' + this.currentUserName + '&' + 'useremailid' + '=' + this.currentUserEmailId + '&documentSide=' + 'Front' + '&loanApplicationId=' +  this.recordid + '&documentRecordTypeId=' +  this.otherDocRecordTypeId}});}
    checkDocument(documentId,currentType){fetchDocument({ documentId:  documentId}).then(response => {if(response){if(currentType){this.fetchDocumentCurrentAddress = true;this.currentAddressData.isDisabled = true;this.currentAddressDisable = true;this.disableCurrentAddressProof = true;this.currentValidity = true;} else {this.fetchDocumentPermanentAddress = true;this.permanentAddressData.isDisabled = true;this.permanentAddressDisable = true;this.disablePermanentAddressProof = true;this.permanentValidy = true;}}}).catch(error => {return false;});}
    async handleOnfinish(event) {if(this.currentStage === 'Credit Processing'){const evnt = new CustomEvent('assetdetailseve', { detail: event });this.dispatchEvent(evnt);}
    if(this.oppStageName === 'Additional Details' && !this.isTractorFinance){
        this.disableNext=true;this.isLoading = true;await this.validateSubmit().then(validaityResult => {
            this.isLoading = false;
            if (validaityResult.allowedSubmit){
                this.isLoading=true;
                this.navigateToNextModule();
            }else{this.disableNext=false;}
        }).catch(error => {
            this.isLoading = false;this.disableNext=false;
            this.showToastMessage(this.errorTitle, 'Error in navigating to Next Module', this.errorVariant); //CISP-2897
        });
    }
}
    viewUploadViewFloater(){this.showFileUploadAndView = true;}
    closeUploadViewFloater(event){this.showFileUploadAndView = false;this.connectedCallback();}
    disableEverything(){let allElements = this.template.querySelectorAll('*');allElements.forEach(element => element.disabled = true);}
    PhoneNumberHandler(event) {let inputLabel = event.target.label;if (inputLabel && inputLabel == 'phoneNumberRef1') {this.phoneNumberRef1Value = event.target.value;helper.helperValidatePhoneNumber1(this);}else if(inputLabel && inputLabel == 'phoneNumberRef2'){this.phoneNumberRef2Value = event.target.value;helper.helperValidatePhoneNumber2(this);}}
    getTaluka(stateValue , districtValue,AddressType){getTalukaByDistrictAndState({ stateName: stateValue , districtName: districtValue}).then(response => {let talukaData = [];if (response && response.length > 0) {for (let index = 0; index < response.length; index++) {let talukaObject = {};talukaObject.label = response[index].Name;talukaObject.value = response[index].Name;talukaObject.id = response[index].Id;talukaData.push(talukaObject);}}if(AddressType =='PermanentAddress'){this.permanentTalukaValue = talukaData;}else{this.talukaValue = talukaData;}this.isLoading = false;}).catch(error => {this.showToastMessage('', 'Error in fetching State', 'error');this.isLoading = false;});}
    async doPincodeBaseSearch(){return await helper.handlePincodeBasedSearchCallout(this);}//SFTRAC-1178
    incomeId = '';cumCheckbox = false; employerName;profileId; isSalaried = false;isSelfEmployed = false;isShowSaleriedNonSalired = false;  @track profileValuesData;profile;isProfileSep =false;bsrOccupation;isTalukaCurValueSelected = false; curTalukaValue;curTalukaId; curStateValue; perStateValue; isTalukaPerValueSelected = false; perTalukaValue;perTalukaId; //SFTRAC-1660
    handleSalaried(event) {helper.handleSalFun(this,event.target.checked);}
    handleSelfEmployed(event){helper.handleSelfFun(this,event.target.checked);}
    handleInputFieldChange(event){const field = event.target.name;helper.handleProfileFun(this,field,event.target.value);}
    handleCurrentCumCheckbox(event) {this.cumCheckbox = event.detail;}
    businessName(event){this.employerName = event.target.value;}
    handlebeneadd1(event){this.beneadd1 = event.detail;}
    handlebeneadd2(event){this.beneadd2 = event.detail;}
    handlebenestate(event){this.benestate = event.detail;}
    handlebenedistrict(event){this.benedistrict = event.detail;}
    handlebenecity(event){this.benecity = event.detail;}
    handlebenepincode(event){this.benepincode = event.detail;}
    handleOnchange(event) {helper.handleChange(this, event);}
    getCRIFFReport(){helper.handlegetCRIFFReport(this);}
    viewCRIFFReport(){doGenerateTokenAPI().then(resp=>{this.reportURL = this.cRIFFURL+'&SessionId='+resp;this[NavigationMixin.Navigate]({ type:'standard__webPage',attributes:{ url: this.reportURL}})}).catch(error=>{});}
    talukalookupHandlerForCur(event){ helper.talukalookupHandlerForCurHelper(this,event); }  //SFTRAC-1660
    talukaClearvaluelookupHandlerForCur(event){helper.talukaClearvaluelookupHandlerForCurHelper(this,event);} //SFTRAC-1660
    talukalookupHandlerForPer(event){ helper.talukalookupHandlerForPerHelper(this,event); }  //SFTRAC-1660
    talukaClearvaluelookupHandlerForPer(event){helper.talukaClearvaluelookupHandlerForPerHelper(this,event);} //SFTRAC-1660
}