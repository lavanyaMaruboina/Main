import { api, LightningElement, track, wire } from 'lwc';
import userId from '@salesforce/user/Id';
import frontUpload from '@salesforce/apex/LwcLOSLoanApplicationCntrl.frontUpload';
import backUpload from '@salesforce/apex/LwcLOSLoanApplicationCntrl.backUpload';
import checkDocFromApp from '@salesforce/apex/LwcLOSLoanApplicationCntrl.checkDocFromApp';
import getStateMasterData from '@salesforce/apex/Utilities.getStateMasterData';
import getCityStateMaster from '@salesforce/apex/Utilities.getCityStateMaster2';
import getDistrictsByState from '@salesforce/apex/Utilities.getDistrictsByState';
import kycDelete from '@salesforce/apex/LwcLOSLoanApplicationCntrl.kycContentDocDelete';
import getBiometricMetadata from '@salesforce/apex/LwcLOSLoanApplicationCntrl.getBiometricMetadata';
import fetchCdocumentId from '@salesforce/apex/LwcLOSLoanApplicationCntrl.fetchCdocumentId';
import getPidBlockStatus from '@salesforce/apex/LwcLOSLoanApplicationCntrl.getPidBlockStatus';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import FORM_FACTOR from '@salesforce/client/formFactor';
import { NavigationMixin } from 'lightning/navigation';
import { loadStyle } from 'lightning/platformResourceLoader';
import LightningCardCSS from '@salesforce/resourceUrl/loanApplication';
import kycSaveData from '@salesforce/apex/LwcLOSLoanApplicationCntrl.kycSaveData';
import updateApplicantName from '@salesforce/apex/LwcLOSLoanApplicationCntrl.updateApplicantName';
import kycDeletedocument from '@salesforce/apex/LwcLOSLoanApplicationCntrl.kycDelete';
import aadharOCR from '@salesforce/apex/LwcLOSLoanApplicationCntrl.aadharOCR';
import ocrOnFrontUpload from '@salesforce/apex/LwcLOSLoanApplicationCntrl.ocrOnFrontUpload';
import goldenSourcePass from '@salesforce/apex/LwcLOSLoanApplicationCntrl.goldenSourcePass';
import goldenSource from '@salesforce/apex/LwcLOSLoanApplicationCntrl.goldenSource';
import docCustomerImage from '@salesforce/apex/LwcLOSLoanApplicationCntrl.docCustomerImage';
import setAadharSource from '@salesforce/apex/LwcLOSLoanApplicationCntrl.setAadharSource';
import deletePIDBlock from '@salesforce/apex/LwcLOSLoanApplicationCntrl.deletePIDBlock';
import storedMaskedKYCDoc from '@salesforce/apex/LwcLOSLoanApplicationCntrl.storedMaskedKYCDoc';
import contentDocumentPresentOrNot from '@salesforce/apex/LwcLOSLoanApplicationCntrl.contentDocumentPresentOrNot';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getRecord, updateRecord,getFieldValue } from 'lightning/uiRecordApi';
import saveImagetoSF from '@salesforce/apex/IntegrationUtilities.saveImagetoSF';
import doPANCallout from '@salesforce/apexContinuation/IntegrationEngine.doPANCallout';
import doOCRfuCallout from '@salesforce/apexContinuation/IntegrationEngine.doCibilOcrFrontUploadCallout';
import doOCRbuCallout from '@salesforce/apexContinuation/IntegrationEngine.doCibilOcrBackUploadCallout';
import doImageUploadCallout from '@salesforce/apexContinuation/IntegrationEngine.doImageUploadCallout';
import doDocAuthReportAsyncCallout from '@salesforce/apex/IntegrationEngine.doDocAuthReportAsyncCallout';
import doSelfieReportAsyncCallout from '@salesforce/apex/IntegrationEngine.doSelfieReportAsyncCallout';
import doUidaiBiometricCallout from '@salesforce/apexContinuation/IntegrationEngine.doUidaiBiometricCallout';
import getDocAsyncResponse from '@salesforce/apex/LwcLOSLoanApplicationCntrl.getDocAsyncResponse';
import tagPOIforKycDoc from '@salesforce/apex/LwcLOSLoanApplicationCntrl.tagPOIforKycDoc';
import getKycDocumentCount from '@salesforce/apex/LwcLOSLoanApplicationCntrl.getKycDocumentCount';
import doAadhaarVaultAPICallout from '@salesforce/apexContinuation/IntegrationEngine.doAadhaarVaultAPICallout';
import getEncryptedData from '@salesforce/apex/LwcLOSLoanApplicationCntrl.getEncryptedData';
import getStateCityMaster from "@salesforce/apex/IND_DSAController.getStateCityMaster";
import resendAadharBiometric from '@salesforce/apex/LwcLOSLoanApplicationCntrl.resendAadharBiometric';
import updateLoanApplicationReject from '@salesforce/apex/LwcLOSLoanApplicationCntrl.updateLoanApplicationReject';
import DemoAuthAPI from '@salesforce/apexContinuation/IntegrationEngine_Helper.DemoAuthAPI'; 
import {checkIfPanNoIsSame,updatePanDetailsAfterCancelButton,afterBioMetricFailure,manaulSelection,biometricOTPSelectAndUploadChange,customResource,customLabels,stateCity,City,cityCheckMaster,UserNameFld,userEmailFld,Gender__c,Age__c,KYC_State__c,KYC_City__c,KYC_District__c,Salutation__c,DL_Type__c,Documents__c,First_Name__c,Last_Name__c,Father_Name__c,KYC_DOB__c,Address__c,KYC_Pin_Code__c,Proof_of_Address_POA__c,Mobile_number__c,Proof_of_Identity_POI__c,Aadhaar_Enrollment_Number__c,PAN_acknowledgement_number__c,Estimated_annual_income__c,Amount_of_transaction__c,Date_of_transaction__c,Number_of_persons_involved_in_the_transa__c,APP_ID_FIELD,AADHAR_NO_FIELD,DOC_ID_FIELD,DOCUMENT_NAME,ageValidation,APPLICANT_TYPE,PRODUCT_TYPE,DocumentType,IsActive,BMDSensorNo  } from './lWC_LOS_ScanAndUploadHelper';
import * as helper from './lWC_LOS_ScanAndUploadHelper';
export default class LWC_LOS_ScanAndUpload extends NavigationMixin(LightningElement)
{ permanentCityValue; maxPermanentState; minPermanentState; permanentDistrictValue;isAadhar = false; customResource = customResource; label = customLabels;panAutoApproved = false;//CISP-3938
    disabledIsPhotocopy=true; @api istwowheeler; @api productType;frontFileUploaderDisable = false;@track isimageApiPositiveResponse = false; @track recaptureFrontKYCPopup = false;
    @track kycIssuanceDate = null;isForm60= false;currentUserId = userId;currentUserName;currentUserEmailId;error;bmdSensorNo;@api isNonIndividualBorrower;//SFTRAC-535
    @track frontUploadExhaustedFlag = false;@track backUploadExhaustedFlag = false;
    documentRecordId = null;
    AppType;ProdType; errorMessageForPanVerification;//CISP-12758
    @track templateUploadAadharApp = false;
    @wire(getRecord, { recordId: userId, fields: [UserNameFld, userEmailFld, BMDSensorNo] })
    userDetails({ error, data }) {if (data) {this.currentUserName = data.fields.Name.value; this.currentUserEmailId = data.fields.Email.value;this.bmdSensorNo = data.fields.BMD_Sensor_No__c.value} else if (error) {this.error = error;}}
    @wire(getObjectInfo, { objectApiName: Documents__c })
    objectInfo;
    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: DL_Type__c })
    stageValues;
    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: Gender__c })
    genderValues;
    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: Salutation__c })
    salutationValues;onInssuranceDate = new Date();issueDate;aadhaarVaultNo;nsdlResponse = '';aadhaarSeedingStatus = '';//cisp-3938
    @track salutValues=[];stateCityMaster; isekyc=false;poiAndPoaRemoving = true;NSDLPANStatus = '';nsdlPanName = '';nsdlNameMatchPer;
    get panPattern() {//SFTRAC-535
        return (this.isNonIndividualBorrower && this.entitytype != 'Proprietorship') ? this.label.Pan_Pattern_NonIndividual : this.label.Pan_Pattern;
    }
    get isPanCard() {
        return this.type == this.label.PanCards;
    }
    @api get salutationVal(){
        this.salutValues=[];
        if(this.kycGender== 'MALE' || this.formGender=='MALE' ){
            this.salutValues.push({ label: 'Mr.', value: 'Mr.' });return this.salutValues;  }
        else if(this.kycGender== 'FEMALE' || this.formGender=='FEMALE' ){
            this.salutValues.push( { label: 'Mrs.', value: 'Mrs.' },{ label: 'Ms.', value: 'Ms.' });return this.salutValues;}
        else if(this.kycGender== 'TRANSGENDER' || this.formGender=='TRANSGENDER' ){
            this.salutValues.push({ label: 'Mr.', value: 'Mr.' },{ label: 'Mrs.', value: 'Mrs.' },{ label: 'Ms.', value: 'Ms.' });return this.salutValues;}//CISP-19811
        else{return this.salutationValues.data.values;}}
    changeIssueDate(event) {
        this.kycIssuanceDate = event.target.value;
        var today = new Date();
        var inputCmp = this.template.querySelector('lightning-input[data-id=kycIssuaceDateId]');
        var differenceInDays = (today.getTime() - (new Date(this.kycIssuanceDate)).getTime()) / (1000 * 3600 * 24);
        var diffWithDOB = ((new Date(this.kycDOB)).getTime() - (new Date(this.kycIssuanceDate)).getTime()) / (1000 * 3600 * 24);
        if (differenceInDays < 0) {inputCmp.setCustomValidity('Date should be less than current date');} else if (diffWithDOB > 0 || diffWithDOB == 0) {inputCmp.setCustomValidity('Date should be greater than DOB');}else{inputCmp.setCustomValidity(''); } }
    @api isStepThreeV2;@track _isStepFour; @track allowPdf = false;
    @api set isStepFour(value){this._isStepFour = value;}
    get isStepFour(){return this._isStepFour;}
    @api type;  @api currentapplicationid;  @track templateFrontBackUpload = true;  @track templateUploadAadhar = false;  @track templateUploadMsg = false; @track templateBackUploadMsg = false;@track templateAadharUploadMsg = false;
    @api leadSource;//Ola
    @api entitytype;
    @api istractor;
    @api isindividual;
    get encryptedToken() {}
    get showDocAuth() {
        return ![this.label.GST_CERT, this.label.CIN_CERT].includes(this.type);
    }
    get templateBackUploadVal() {
        return this.isNonIndividualBorrower ? false : this.templateBackUploadPopUp;
    }
    get acceptedFormats() {return this.allowPdf == false ?  ['.jpg','.jpeg'] : ['.pdf'] ;} 
    mockOCRData;openKYCFields = false;openVoterId = false;
    frontBackDocAuthUploadButtons = false; cancelButton = true; isSpinnerMoving = false; message = ''; kycName = ''; kycGender = ''; kycAadharEnrollment = '';kycAddress1 = ''; kycAddress2 = '';
    kycDistrict ='';kycCity = ''; kycState = ''; kycPinCode = ''; kycDOB = ''; firstName = ''; lastName = ''; kycNo = ''; kycAge = '';kycGstNo = ''; kycCinNo = '';
    @track modalPopUpUpload = false;
    captureCustomerImageClose() {this.modalPopUpUpload = false;}
    @track doneflagAadharImage = false;
    handleCancelPopupButton() {
        this.modalPopUpUpload = false;
        if (this.frontdocumentToDelete == null && FORM_FACTOR != 'Large') {this.donefrontflagCustomerImage = false;}
        if (this.backdocumentToDelete == null && FORM_FACTOR != 'Large') {this.donebackflagCustomerImage = false;}
        this.doneflagAadharImage = false;this.templateAadharUploadMsg = false;this.disableBackFileUpload = false;this.showAlternateKYCPopup = false;
 }
    @wire(getRecord, { recordId: '$currentapplicationid', fields: [APPLICANT_TYPE,PRODUCT_TYPE] })
    Appdata({ error, data }) {if (data) {this.AppType= data.fields.Applicant_Type__c.value; this.ProdType= getFieldValue(data, PRODUCT_TYPE); this.handlePanRadioOptionsSet();}}
    handlePanRadioOptionsSet() {
        if (this.entitytype === 'Proprietorship' && this.AppType === 'Beneficiary'){this.panRadioOptions = [{ 'label': this.label.PanCards, 'value': this.label.PanCards }];}  
    }
    handlekycPanNo(event) { this.kycPanNo = event.target.value;this.changeEvent();}
    handleKYCPanNoChange(event){checkIfPanNoIsSame(this.kycPanNo,this.currentapplicationid,this.currentoppid,this)}//CISP-14823
    handlekycDob(event) {
        if(!this.isNonIndividualBorrower){this.kycDOB = event.target.value;var ageInMilliseconds = new Date() - new Date(this.kycDOB);
        if (Math.floor(ageInMilliseconds / 1000 / 60 / 60 / 24 / 365) > 0) {this.kycAge = Math.floor(ageInMilliseconds / 1000 / 60 / 60 / 24 / 365);this.ageCheck();}this.dateValidation();this.changeEvent();}else if(this.isNonIndividualBorrower){
            let inputField = this.template.querySelector('[data-id="kycDobId"]');
            const selectedDate = event.detail.value;
            const currentDate = new Date().toISOString().split('T')[0];
            if (selectedDate > currentDate) {
                inputField?.setCustomValidity("Incorporation date cannot be a future date.");
            } else {
                this.kycDOB = selectedDate;
                inputField?.setCustomValidity("");
            }
            inputField?.reportValidity();
        }
    }
    dateValidation(){
        var inputCmpdob = this.template.querySelector('lightning-input[data-id=kycDobId]');
        if (inputCmpdob) {
        if (new Date(this.kycDOB) < new Date(this.minAge)) {inputCmpdob.setCustomValidity('Maximum age should be atmost 80 years');} else if (new Date(this.kycDOB) > new Date(this.maxAge)) {inputCmpdob.setCustomValidity('Minimum age should be atleast 18 years');}else{inputCmpdob.setCustomValidity(''); } }}
    handleDLType(event) {this.kycDLType = event.target.value;}
    minAge;maxAge;
    @api adhaaridfromloan = null; @api formidfromloan = null; @api panidfromloan = null;@api voeridfromloan = null;@api dlidfromloan = null;@api passportidfromloan = null;
    showDetailsComponent = false;@api fieldsliststring;@api currentdocumentid; @api kycdocname;isSpinnerMoving = false; @api currentoppid;numOfKycDocIsPresent = 0;
    connectedCallback() {
        if(this.type == this.label.AadhaarCard){this.isAadhar = true;this.selectedAadharOption = 'Biometric/OTP';this.disableBioOTPScanUplaod = true;this.disableManualEnterScan = true; this.scanManualRadioOptions = 'ManuallyEnter';manaulSelection(this);biometricOTPSelectAndUploadChange(this)}else{this.selectedAadharOption = 'Scan and Upload';this.disableBioOTPScanUplaod = false;this.disableManualEnterScan = false;}
         getStateCityMaster()
         .then((data) => {
             this.stateCityMaster = data;});//Ola
        if(this.leadSource=='OLA' || this.leadSource=='Hero' || this.isNonIndividualBorrower){this.panRadioOptions = [{ 'label': this.label.PanCards, 'value': this.label.PanCards },];} else {
            this.panRadioOptions = [{ 'label': this.label.PanCards, 'value': this.label.PanCards },{ 'label': this.label.Form60DocumentType, 'value': this.label.Form60DocumentType },];}
        //Ola
        getKycDocumentCount({applicantId : this.currentapplicationid}).then(result=>{this.numOfKycDocIsPresent = result;}).catch(error=>{  });
        getBiometricMetadata().then(result => {
                for(const [key, value] of Object.entries(result)) {}
                this.pidver__c = result.pidver__c;this.fType = result.fType__c;this.env__c = result.env__c;this.fCount__c = result.fCount__c;this.format__c = result.format__c;
                this.str_wadh__c = result.str_wadh__c; this.timeout__c = result.timeout__c; this.wadhType__c = result.wadhType__c;
            })
        if (this.currentdocumentid != null) {
            this.isSpinnerMoving = true;this.showDetailsComponent = true;this.scanAndUploadComponent = true;this.isSpinnerMoving = false;
            if(this.isNonIndividualBorrower && this.type===this.label.PanCards){
                let fieldList = [];
                this.fieldsliststring.split(',').forEach(element=>{
                    if(element != KYC_DOB__c.fieldApiName && element != Gender__c.fieldApiName && element != Salutation__c.fieldApiName){
                        fieldList.push(element);
                    }
                });
                this.fieldList = fieldList;
            }else{
                this.fieldList = this.fieldsliststring.split(',');
            }
        }
        this.handlePickListChange();
        this.callOCRMockData();
        this.minExpiryDate = new Date();
        var dateObj = new Date();
        var dd = dateObj.getDate();
        var mm = dateObj.getMonth() + 1;
        var yyyy = dateObj.getFullYear();
        if (dd == 29 && mm == 2) {this.minAge = (yyyy - 80) + '-' + mm + '-' + dd;this.maxAge = (yyyy - 18) + '-' + mm + '-' + '28';}else{this.minAge = (yyyy - 80) + '-' + mm + '-' + dd;this.maxAge = (yyyy - 18) + '-' + mm + '-' + dd;}
        if(this.isStepThreeV2){
            this.disableUploadButtonAll = true; }  }
    renderedCallback() {loadStyle(this, LightningCardCSS);}
    handleviewSection() {
        getDocDetails({ docId: this.documentRecordId, documentType: this.type })
            .then(result => {
                this.selectedRowId = row.Id;let jsonResult = result.document;let editableFieldAPINames = result.editableFields;
                let nonEditFields = [];
                let uiEditableFields = [];
                for(const [key] of Object.entries(jsonResult)) {if (key != 'Id' && key != 'Rejection_Fields__c') {nonEditFields.push(key)}}
                for(let j = 0; j < editableFieldAPINames.length; j++) {
                    for(let step = 0; step < nonEditFields.length; step++) {
                        if (editableFieldAPINames[j].toUpperCase().trim()===nonEditFields[step].toUpperCase().trim()) {
                            uiEditableFields.push(nonEditFields[step]);
                            nonEditFields.splice([step], 1);}} }
                this.nonEditableFields = nonEditFields;
                this.editableFields = uiEditableFields;
            }).catch(error => {this.error=error;})}
    callOCRMockData() {
        ocrOnFrontUpload().then(OcrResult => {
            this.mockOCRData = JSON.parse(OcrResult); })}
    validateText() {var regexp = /^([^0-9]*)$/;}
    ShowPAN = false;showAaadhar = false;showDL = false;showPassport = false;showVoterId = false;panFlag = true;form60Flag = false;ScanAndUploadFlag = true;bioMatricFlag = false;recordId;@api recordid;disableFrontButton = false;disableBackButton = false;buttonStyle = 'brand';BackButtonStyle = 'brand';clickedButtonLabel;aadharDLVoterid = false;dLVoteridPassport = false;dlPassport = false;allFields = false;biometricCapture = false;pidver__c;fType;env__c;fCount__c;format__c; str_wadh__c;timeout__c;wadhType__c; @track showGst = false; @track showCin = false;
    handlePickListChange() {
        if (this.type===this.label.PanCards) {this.ShowPAN = true;if(!this.showDetailsComponent)if(!this.isNonIndividualBorrower && this.entitytype !== 'Proprietorship'){this.successToast('Information','Please ensure PAN is linked to Aadhaar, else upload Form 60.','Info');}else if (!this.isNonIndividualBorrower && this.entitytype == 'Proprietorship'){this.successToast('Information', 'Please ensure PAN is linked to Aadhaar.', 'Info');}}//CISP-3938
        if (this.type===this.label.AadhaarCard) {this.showAaadhar = true;this.aadharDLVoterid = true;this.isSuccessGoldenSOurce = false;if (this.selectedAadharOption != 'Scan and Upload') {this.disabledKYCNo = true;this.disabledKYCName = true;this.disabledKYCAddress1 = true;this.disabledKYCAddress2 = true;this.disabledKYCPinCode = true;this.disabledKYCCity = true;this.disabledKYCState = true;this.disabledKYCDOB = true;this.disabledFirstName = true;this.disabledLastName = true;this.disabledGender = true;this.disabledSalutation = true;this.disabledAdharEnrollmentNumber = true;this.captureApp = false;}}
        if (this.type===this.label.DrivingLicences) {this.showDL = true;this.aadharDLVoterid = true;this.dLVoteridPassport = true;this.dlPassport = true;}
        if (this.type===this.label.PassportCard) {this.showPassport = true;this.dLVoteridPassport = true;this.dlPassport = true;this.isSuccessGoldenSOurce = false;}
        if (this.type===this.label.VoterIdCard) {this.showVoterId = true;this.aadharDLVoterid = true;this.dLVoteridPassport = true;this.isSuccessGoldenSOurce = false;}
        if (this.type===this.label.GST_CERT) {this.showGst = true; this.allowPdf = true; this.aadharDLVoterid = false;this.dLVoteridPassport = false;this.isSuccessGoldenSOurce = false;}
        if (this.type===this.label.CIN_CERT) {this.showCin = true; this.allowPdf = true; this.aadharDLVoterid = false;this.dLVoteridPassport = false;this.isSuccessGoldenSOurce = false;}
    }
    @track cssFrontUploadButton = 'indusPrimaryButton slds-button slds-button_brand slds-align_absolute-center';buttonClicked;disableUploadButton = true;frontUploadButton = false;openVoterId = false;openKYCFields = false;@track templateExPanFields = true;frontUploadRedCross = false;backUploadRedCross = false;
    async frontuploadApi() {
        this.isSpinnerMoving = true;
        await doOCRfuCallout({ documentId: this.documentRecordId, contentDocumentId: this.frontdocumentToDelete, loanAppId: this.currentoppid }).then(response => {
                this.disableAadharBackButton = false;
                const obj = JSON.parse(response);const status = obj.ResponseData.Fields.Applicants.Applicant.Services.Service[0].Status;
                if (status == 'Pass') {
                    var responseData = obj.ResponseData.Fields.Applicants.Applicant.Services.Service[0].Operations.Operation[0].Data.Response.RawResponse;
                    const parsedRespData = JSON.parse(responseData);
                    if (this.type===this.label.AadhaarCard || this.type===this.label.VoterIdCard || this.type===this.label.PassportCard) {this.kycGender = parsedRespData.result[0].details.gender.value; this.setSalutationVal();}
                    if (this.type===this.label.AadhaarCard) {
                        this.kycName = parsedRespData.result[0].details.name.value;var apiResFirstName = "";var apiResLastName = "";
                        if (this.kycName.split(" ").length > 1) {
                            apiResLastName = this.kycName.substring(this.kycName.lastIndexOf(" ") + 1);
                            apiResFirstName = this.kycName.substring(0, this.kycName.lastIndexOf(' '));
                        }else{apiResFirstName = this.kycName;}
                        this.firstName = apiResFirstName;this.lastName = apiResLastName;
                        this.kycDOB = parsedRespData.result[0].details.dob.value.split("/").reverse().join("-");
                        this.kycNo = parsedRespData.result[0].details.aadhaar.value;
                        this.aadhaarNumber = parsedRespData.result[0].details.aadhaar.value;
                        let base64ImageResp = parsedRespData.result[0].details.base64Image;
                        storedMaskedKYCDoc({base64Imag : base64ImageResp , documentId : this.documentRecordId,docSide : 'Front',contentDocumentId:this.frontdocumentToDelete }).then(response => {
                        }).catch(error => {});
                    } else if (this.type===this.label.VoterIdCard) {
                        this.kycName = parsedRespData.result[0].details.name.value;var apiResFirstName = "";var apiResLastName = "";
                        if (this.kycName.split(" ").length > 1) {
                            apiResLastName = this.kycName.substring(this.kycName.lastIndexOf(" ") + 1);
                            apiResFirstName = this.kycName.substring(0, this.kycName.lastIndexOf(' '));
                        }else{ apiResFirstName = this.kycName;}
                        this.firstName = apiResFirstName;this.lastName = apiResLastName;this.kycNo = parsedRespData.result[0].details.voterid.value;
                        this.kycDOB = parsedRespData.result[0].details.dob.value.split("/").reverse().join("-");
                    } if (this.type===this.label.PassportCard) {
                        this.firstName = parsedRespData.result[0].details.given_name.value;this.lastName = parsedRespData.result[0].details.surname.value;
                        this.kycName = this.firstName + ' ' + this.lastName;this.kycPassportNo = parsedRespData.result[0].details.passport_num.value;
                        this.kycDOB = parsedRespData.result[0].details.dob.value.split("/").reverse().join("-");
                        this.kycIssuanceDate = parsedRespData.result[0].details.doi.value.split("/").reverse().join("-");
                        this.kycExpiryDate = parsedRespData.result[0].details.doe.value.split("/").reverse().join("-");
                    }
                    if (this.type===this.label.PanCards) {
                        if (this.isNonIndividualBorrower) {this.disableDocAuthButton=true;}
                        this.kycName = parsedRespData.result[0].details.name.value;var apiResFirstName = "";var apiResLastName = "";
                        if (this.kycName.split(" ").length > 1) {
                            apiResFirstName = this.kycName.substring(0, this.kycName.lastIndexOf(' '));
                            apiResLastName = this.kycName.substring(this.kycName.lastIndexOf(' ') + 1);
                        }else{apiResFirstName = this.kycName;}
                        this.firstName = apiResFirstName;this.lastName = apiResLastName;
                        this.kycDOB = parsedRespData.result[0].details.date.value.split("/").reverse().join("-");
                        this.kycPanNo = parsedRespData.result[0].details.pan_no.value;
                        checkIfPanNoIsSame(this.kycPanNo,this.currentapplicationid,this.currentoppid,this);//CISP-5264
                    }
                    if (this.type===this.label.DrivingLicences) {
                        this.kycNo = parsedRespData.result[0].details.dl_num.value.replaceAll(/[^a-zA-Z0-9]/g, ''); //SFTRAC-1784
                        this.kycAddress1 = parsedRespData.result[0].details.address.line1;this.kycAddress2 = parsedRespData.result[0].details.address.line2;
                        this.currentAddressData.KYC_State__c = parsedRespData.result[0].details.address.state.toUpperCase();
                        this.currentAddressData.KYC_Pin_Code__c = parsedRespData.result[0].details.address.pin;
                        this.currentAddressData.KYC_City__c = parsedRespData.result[0].details.address?.city?.toUpperCase();
                        this.stateMaster(parsedRespData.result[0].details.address.state.toUpperCase(), parsedRespData.result[0].details.address.city.toUpperCase());
                        this.kycName = parsedRespData.result[0].details.name.value;var apiResFirstName = "";var apiResLastName = "";
                        if (this.kycName.split(" ").length > 1) {
                            apiResFirstName = this.kycName.substring(0, this.kycName.lastIndexOf(' '));
                            apiResLastName = this.kycName.substring(this.kycName.lastIndexOf(' ') + 1);
                        }else{apiResFirstName = this.kycName;}
                        this.firstName = apiResFirstName;this.lastName = apiResLastName;this.kycName = this.firstName + ' ' + this.lastName;
                        let kycDOBVal = parsedRespData.result[0].details.dob.value;let kycIssuanceDateVal = parsedRespData.result[0].details.doi.value;
                        let kycExpiryDateVal = parsedRespData.result[0].details.doe.value;
                        if(kycDOBVal.includes("-")){this.kycDOB = kycDOBVal.split("-").reverse().join("-");}else{this.kycDOB = kycDOBVal.split("/").reverse().join("-");}
                        if(kycIssuanceDateVal.includes("-")){this.kycIssuanceDate = kycIssuanceDateVal.split("-").reverse().join("-");}else{this.kycIssuanceDate = kycIssuanceDateVal.split("/").reverse().join("-");}
                        if(kycExpiryDateVal.includes("-")){this.kycExpiryDate = kycExpiryDateVal.split("-").reverse().join("-");}else{this.kycExpiryDate = kycExpiryDateVal.split("/").reverse().join("-");}
                    }
                    this.successToast('Front OCR successful', '', 'success');this.frontUploadButton = true;this.frontUploadRedCross = false;this.isSpinnerMoving = false;;
                }else if (status == 'Fail') {this.disableAadharBackButton = true;this.isSpinnerMoving = false;this.failResponseFrontKyc();}
            }).catch(error => {
                this.disableAadharBackButton = true;this.kycGender =null;this.setSalutationVal();this.isSpinnerMoving = false;this.frontUploadButton = false;this.hanldeKindlyRetryMsg = true;}).finally(() => {this.isSpinnerMoving = false;}) }
    handleFrontUpload() {
        if (this.frontdocumentToDelete == null) {this.successToast('Upload front Kyc to proceed', '', 'error');return null;
        }else{
            this.imageType = 'Front';
            this.isSpinnerMoving = true;
            if (this.type==='PAN') {
                this.templateExPanFields = false;
            }else{this.templateExPanFields = true
            }
            this.disableUploadButton = false;
            frontUpload({ leadApplicationId: this.documentRecordId, kycType: this.type, documentSide: 'Front' }).then(result => {
                const obj = JSON.parse(result);
                this.isSpinnerMoving = false;
                if (obj.status==='false' && obj.message===this.label.FrontUploadResponseMessage) {this.isSpinnerMoving = false; this.disableAadharFrontButton = true;this.frontUploadExhaustedFlag = true;this.disableAadharBackButton = false; this.frontFileUploaderDisable = true;
                    this.successToast(obj.message, '', 'error');
                    if (!this.frontUploadButton) {
                        this.frontUploadRedCross = true; } } else{
                    if (this.type===this.label.GST_CERT || this.type===this.label.CIN_CERT ) {
                                this.frontUploadButton = true;this.frontUploadRedCross = false;
                            } else if (!this.isimageApiPositiveResponse) {
                                this.frontuploadApi(); //this.handleimageUploadApi(); CISP-23118
                    }else{
                        this.frontuploadApi();  }
                    this.frontUploadExhaustedFlag = false;
                    this.disableAadharFrontButton = false;}
            }).catch(error => {
                    this.isSpinnerMoving = false;
            });  } }  
    onFocusKYCNumber(event) {
        if (this.type===this.label.AadhaarCard) { event.target.value = this.kycAadharNumber;} }
    onBlurKYCNumber(event) {
        if (this.type===this.label.AadhaarCard) {
            this.kycAadharNumber = this.template.querySelector('lightning-input[data-id=kycNoId]').value;this.aadhaarNumber = this.kycAadharNumber;var temp = this.kycAadharNumber;
            var aadharRegex = /^[0-9]{1}[0-9]{11}$/;
            if (aadharRegex.test(temp)) {
                this.template.querySelector('lightning-input[data-id=kycNoId]').setCustomValidity("");event.target.value = temp.replace(/\d(?=\d{4})/g, "*");}} }
    onChangeKYCNumber(flag) {
        let kycNoElement = this.template.querySelector('lightning-input[data-id=kycNoId]');
        if(kycNoElement){
            let kycNo = kycNoElement.value;
            if(this.type === this.label.AadhaarCard && flag === true){ kycNo = this.aadhaarNumber;}if(this.selectedAadharOption != 'Biometric/OTP'){this.addressLine2validation();this.addressLine1validation();}if(this.selectedAadharOption != 'Biometric/OTP'){this.addressLine2validation();this.addressLine1validation();}
            var kycNoRegex = /[!@#$%^&*()_+\-=\[\]{};':"\\|,.<>\/?]+/;
            if(kycNoRegex.test(kycNo)){kycNoElement.setCustomValidity("Please enter without special characters.");this.allFieldsPopulated=false;return;
            }else{ this.template.querySelector('lightning-input[data-id=kycNoId]').setCustomValidity("");}
        }
        if (this.type===this.label.AadhaarCard) {
            if(flag === true){ this.kycAadharNumber = this.aadhaarNumber; } else { this.kycAadharNumber = this.template.querySelector('lightning-input[data-id=kycNoId]').value;}
            var temp = this.kycAadharNumber;
            var aadharRegex = /^[0-9]{1}[0-9]{11}$/;
            if (aadharRegex.test(temp)) {
                this.template.querySelector('lightning-input[data-id=kycNoId]').setCustomValidity("");
                this.kycNo=this.kycAadharNumber;
            }else{
                this.template.querySelector('lightning-input[data-id=kycNoId]').setCustomValidity("Not a valid Aadhar Number");this.allFieldsPopulated=false;}
        } else if (this.type===this.label.DrivingLicences) {
            let dlNo = this.template.querySelector('lightning-input[data-id=kycNoId]').value;
            var dlRegex = /^[A-Z0-9]{9,20}$/;
            if (dlRegex.test(dlNo)) {
                this.template.querySelector('lightning-input[data-id=kycNoId]').setCustomValidity("");
                this.kycNo=dlNo;}else{
                this.template.querySelector('lightning-input[data-id=kycNoId]').setCustomValidity("Not a valid DL Number");this.allFieldsPopulated=false;}
        } else if (this.type == this.label.VoterIdCard) {
            let voterIdNo = this.template.querySelector('lightning-input[data-id=kycNoId]').value;
            var voteridRegex = /^[A-Z0-9]+$/;
            if (voteridRegex.test(voterIdNo)) {
                this.template.querySelector('lightning-input[data-id=kycNoId]').setCustomValidity("");
                this.kycNo = voterIdNo;
            }else{
                this.template.querySelector('lightning-input[data-id=kycNoId]').setCustomValidity("Not a valid Voter Id Number");
                this.allFieldsPopulated=false;}}
    }
    captureUploadClose() {this.modalPopUpUpload = false}
    kycAadharNumber = null;disableDocAuthButton = true;backUploadButton = false;doneDisable = false;
    backuploadApi() {
        this.isSpinnerMoving = true;
        doOCRbuCallout({ documentId: this.documentRecordId, contentDocumentId: this.backdocumentToDelete, loanAppId: this.currentoppid })
            .then(response => {
                const obj = JSON.parse(response);
                const status = obj.ResponseData.Fields.Applicants.Applicant.Services.Service[0].Status;
                if (status == 'Pass') {
                    this.backUploadRedCross = false;
                    var responseData = obj.ResponseData.Fields.Applicants.Applicant.Services.Service[0].Operations.Operation[0].Data.Response.RawResponse;
                    const parsedRespData = JSON.parse(responseData);
                    if (this.type===this.label.AadhaarCard && parsedRespData.result[0].details.aadhaar===undefined) {throwError;
                    } else if (this.type===this.label.VoterIdCard && parsedRespData.result[0].details.voterid===undefined) {
                        throwError;} else if (this.type===this.label.DrivingLicences && parsedRespData.result[0].details.dl_num===undefined) {throwError;}
                    else if (this.type===this.label.PassportCard) {this.kycPassportFileNo = parsedRespData.result[0].details.file_num.value;}
                    this.kycAddress1 = parsedRespData.result[0].details.address.line1;
                    this.kycAddress2 = parsedRespData.result[0].details.address.line2;
                    
                    //CISP-7909 Populate address line 2 with address line 1 if address line 2 is blank for aadhaar
                    if (this.type === this.label.AadhaarCard && (this.kycAddress2 === "" || this.kycAddress2 === null || this.kycAddress2 === undefined)) {
                        this.kycAddress2 = this.kycAddress1;
                    }
                    
                    this.currentAddressData.KYC_State__c = parsedRespData.result[0].details.address.state.toUpperCase();this.currentAddressData.KYC_City__c = parsedRespData.result[0].details?.address?.city?.toUpperCase();this.stateMaster(parsedRespData.result[0].details.address.state.toUpperCase(), parsedRespData.result[0].details.address.city.toUpperCase());this.currentAddressData.KYC_Pin_Code__c = parsedRespData.result[0].details.address.pin;this.isSpinnerMoving = false;
                    this.backUploadButton = true;this.successToast('Back OCR successful', '', 'success');
                    let base64ImageResp = parsedRespData.result[0].details.base64Image;
                    storedMaskedKYCDoc({base64Imag : base64ImageResp , documentId : this.documentRecordId,docSide : 'Back',contentDocumentId:this.backdocumentToDelete }).then(response => {
                    }).catch(error => {});
                }
                else if (status == 'Fail') {
                    this.isSpinnerMoving = false;
                    this.failResponseBackKyc();
                }
                this.isSpinnerMoving = false;
            }).catch(error => {
                this.isSpinnerMoving = false; this.kycAddress1 = ''; this.kycAddress2 = ''; this.hanldeKindlyRetryMsg = true;this.backUploadButton = false;
            }).finally(() => {this.isSpinnerMoving = false;});
    }
    handleBackUpload() {
        if (this.backdocumentToDelete == null) {this.successToast('Upload back Kyc to proceed', '', 'error');}
        else if (!this.frontUploadButton && !this.frontUploadRedCross) {this.successToast('Complete front upload process.', '', 'error');}
        else{
            this.isSpinnerMoving = true; this.cancelButton = false; this.allFields = true;this.disableAadharFrontButton = true;this.doneDisable = false; this.imageType = 'Back';
            backUpload({ leadApplicationId: this.documentRecordId, kycType: this.type, documentSide: 'Back' })
                .then(result => {
                    const obj = JSON.parse(result);
                    this.isSpinnerMoving = false;
                    if (obj.status==='false') {
                        this.disableBackFileUpload = true;this.isSpinnerMoving = false;this.disableAadharBackButton = true; this.disableUploadButtonAll = true; this.backUploadExhaustedFlag = true;this.successToast('error', this.label.BackUploadExhausted, 'error');
                        if (!this.backUploadButton) {
                            this.backUploadRedCross = true;
                        }
                    }else{
                        this.isSpinnerMoving = false;
                        this.backUploadExhaustedFlag = false;
                        if (this.type===this.label.AadhaarCard) {
                            this.kycAadharNumber = this.kycNo;
                            var temp = this.kycAadharNumber;
                            if(this.istractor){
                                if(temp){this.template.querySelector('lightning-input[data-id=kycNoId]').value = temp.replace(/\d(?=\d{4})/g, "*");}
                            }else{
                                this.template.querySelector('lightning-input[data-id=kycNoId]').value = temp.replace(/\d(?=\d{4})/g, "*");
                            }
                        }
                        if (!this.isBackImageApiPositiveResponse && (this.isimageApiPositiveResponse || this.istractor)) {
                            this.backuploadApi(); //this.handleimageUploadApi(); CISP-23118
                        }else{
                            this.backuploadApi(); }}
                }).catch(error => {this.isSpinnerMoving = false;}); }}
    get options() {return [{ label: this.label.PanCards, value: this.label.PanCards },{ label: this.label.Form60DocumentType, value: 'Form60' },];}
    handleBorrower(event) {if (event.detail.value==='initalValue') {}else{}}
    handleSalutationChange(event) {this.kycSalutation = event.target.value;this.changeEvent();}
    setSalutationVal(){if(this.kycGender=='MALE'){this.salutationCheck='Mr.';} else if(this.kycGender=='FEMALE'){this.salutationCheck='Ms.';}else if(this.kycGender=='TRANSGENDER'){this.kycSalutation;//CISP-19811
}
}
    handleGenderChange(event) {
        this.kycGender = event.target.value;
        this.setSalutationVal();
        this.changeEvent();}
    handleCoBorrower(event) {}
    aadharFormOption = 'Scan and Upload';
    @track templateScanManuallyOptions = false;@track templateAadharNumberField = false;@track templateSubmitButton = false;@track templateBiometricOTPOptions = false;@track modalPopUpToggleFlag = false;@track disableOCRButton = false;@track disableAadharField = true;@track disableSubmitButton = true;@track disableUploadButtonAll = false;@api PopupOTPForSubmit = false;@track templateUploadButton = true;@track selectedAadharOption;@track disableManualEnterScan = false; @track disableManualEnterScan = false;@track disableBioOtpOptions = false;
    get aadharBiometicOTP() {
        let aadharBiometicList = [];aadharBiometicList.push({ label: 'Biometric/OTP', value: 'Biometric/OTP' });
        if(!this.isStepThreeV2){aadharBiometicList.push({ label: 'Scan and Upload', value: 'Scan and Upload' });}return aadharBiometicList;}
    get wayOfCapturingAadhar() {
        let wayToCaptureList = [];wayToCaptureList.push({ label: 'Manually Enter', value: 'ManuallyEnter' });
        if(!this.isStepThreeV2){wayToCaptureList.push({ label: 'Scan Aadhar', value: 'ScanAadhar' });} return wayToCaptureList;}
    get wayOfSelectingBiometricOtp() {
        let wayToBiometricOtp = [];wayToBiometricOtp.push({ label: 'Biometric', value: 'Biometric' });
        if(!this.isStepThreeV2){wayToBiometricOtp.push({ label: 'OTP', value: 'OTP' });} return wayToBiometricOtp;}
    biometricOTPSelectAndUpload(event) {
        this.aadharEntered = this.kycNo;
        this.selectedAadharOption = event.target.value;
        if (this.selectedAadharOption==='Biometric/OTP') {
            this.aadharFormOption = 'Biometric/OTP'; this.ScanAndUploadFlag = true;this.templateScanManuallyOptions = true;this.disableOCRButton = true;
            this.disableUploadButtonAll = true; } else if (this.selectedAadharOption==='Scan and Upload') {
            this.aadharFormOption = 'Scan and Upload';
            this.ScanAndUploadFlag = true;this.disableOCRButton = false;this.templateScanManuallyOptions = false;this.disableUploadButtonAll = false;this.templateAadharNumberField = false;this.templateOCRButton = false;this.templateUploadAadhar = false; this.templateFrontBackUpload = true;this.templateBiometricOTPOptions = false;this.templateSubmitButton = false;this.templateUploadButton = true;
            if (FORM_FACTOR != 'Large') { this.captureApp = true;  }  } }
    scanManualRadioOptions = '';
    changeOCRSection() {
        const selectedValue = this.template.querySelectorAll('lightning-radio-group');
        this.scanManualRadioOptions = selectedValue[1].value;
        if (selectedValue[1].value == 'ScanAadhar') {
            this.templateBiometricOTPOptions = false;this.templateSubmitButton = false;this.templateAadharNumberField = false;this.disableAadharField = false;this.templateUploadButton = true;this.templateFrontBackUpload = false;this.disableUploadButtonAll = false; this.templateUploadAadhar = true;this.allFields = false;this.captureApp = false;
            if (FORM_FACTOR != 'Large') {
                this.templateUploadAadharApp = true; }else{
                this.templateUploadAadharButtons = true;
                this.disableOCRButton = false;}
        } else if (selectedValue[1].value == 'ManuallyEnter') {
            this.templateAadharNumberField = true;
            this.disableAadharField = false;this.disableOCRButton = true;this.disableUploadButtonAll = true; this.templateUploadButton = false;this.templateOCRButton = false; this.allFields = false;
            if (this.aadharEntered != null) {  this.templateBiometricOTPOptions = true; }} }
    @api aadharEntered;
    validateAadhar(event) {
        this.templateSubmitButton = true;
        var regexp = /^[0-9]{1}[0-9]{11}$/;
        var aadharvalue = event.target.value;
        this.aadharEntered = event.target.value;
        const aadharComp = this.template.querySelector('[data-id="aadharNumber"]');
        if ((aadharvalue.length == 12 && regexp.test(aadharvalue)) || this.aadharEntered==='') {
            this.templateBiometricOTPOptions = true;
            if(this.ProdType == 'Two Wheeler' || FORM_FACTOR != 'Large'){
                if(this.bmdSensorNo == null && this.isStepThreeV2){this.successToast('Error' ,'Since Customer / applicant does not have proof in Current Residential address, e-KYC through Biometric is mandatory. Please inform User to map a BMD, withdraw this loan application and create a new application, once BMD is mapped', 'error');this.cancelYes()}
                if(this.bmdSensorNo != null || this.bmdSensorNo != undefined || this.isStepThreeV2){this.disableBioOtpOptions = true; this.finalValue = 'Biometric'
                }else{this.disableBioOtpOptions = true; this.finalValue = 'OTP'} 
                if (this.finalValue == 'Biometric' || this.finalValue == 'OTP') {if (FORM_FACTOR != 'Large' || this.finalValue == 'OTP') { this.disableSubmitButton = false;}else{ this.disableSubmitButton = true;}}
            }
            this.aadhaarValtoStore = aadharvalue;aadharComp.setCustomValidity(""); }else{ this.templateBiometricOTPOptions = false;aadharComp.setCustomValidity("Not a valid Aadhar Number");}aadharComp.reportValidity();}
    showAadharNo(event) {if (this.scanManualRadioOptions == 'ScanAadhar') { this.aadharEntered = this.aadhaarValtoStore; }event.target.value = this.aadharEntered;}
    blurAadharNo(event) {var temp = event.target.value;this.aadhaarValtoStore = temp;if (temp.length == 12) { event.target.value = temp.replace(/\d(?=\d{4})/g, "*");}}
    @track hanldeKindlyRetryMsg = false;@track kindlyRecaptureAadharPopup = false;@track OCRExhaustRedCross = false;
    handleOCRClick() {
        this.disableManualEnterScan = true;this.disableBioOTPScanUplaod = true;
        aadharOCR({currentDocId: this.documentRecordId}).then(result=>{
            if(result){ this.callOCRApi();
            }else{this.disableOCRButton = true;this.disableManualEnterScan = false;this.disableBioOTPScanUplaod = false;this.OCRExhaustRedCross = true;this.successToast('', 'Aadhar OCR attempts are exhausted. Please opt for any other mode', 'error');
            }
        }).catch(error => {this.successToast('Error in Aadhar OCR',error, 'error');})
    }
    callOCRApi(){
        this.isSpinnerMoving = true;
        doOCRfuCallout({ documentId: this.documentRecordId, contentDocumentId: this.frontdocumentToDelete, loanAppId: this.currentoppid }).then(response => {
            this.isSpinnerMoving = false;
            const obj = JSON.parse(response);
            var responseData = obj.ResponseData.Fields.Applicants.Applicant.Services.Service[0].Operations.Operation[0].Data.Response.RawResponse;
            const parsedRespData = JSON.parse(responseData);
            let aadharKycNo = parsedRespData.result[0].details.aadhaar.value;
            this.aadhaarValtoStore = parsedRespData.result[0].details.aadhaar.value;
            if (obj.ResponseData.Fields.Applicants.Applicant.Services.Service[0].Status == 'Pass' && parsedRespData.result[0].type==='aadhaar_front_bottom' && aadharKycNo !== '' && aadharKycNo !== null && aadharKycNo !== undefined) {
                this.kycNo = parsedRespData.result[0].details.aadhaar.value;
                this.successToast('Success', 'Aadhar OCR successful', 'success');
                this.disableAadharField = false;
                this.aadharEntered = this.kycNo.replace(/\d(?=\d{4})/g, "*");
                if (this.aadharEntered != null) {this.templateOCRButton = false;this.templateBiometricOTPOptions = true;this.templateSubmitButton = true;this.templateAadharNumberField = true;this.deleteImage(this.documentRecordId, false, true, this.frontdocumentToDelete,false);}
            } else if (obj.ResponseData.Fields.Applicants.Applicant.Services.Service[0].Status == 'Fail') {this.isSpinnerMoving = false;this.imageType = 'Aadhaar';this.templateAadharUploadMsg = false;this.disableUploadButtonAll = false;this.disableOCRButton = true;this.templateUploadMsg = false;this.deleteImage(this.documentRecordId, false, true, this.frontdocumentToDelete,false);this.recaptureFrontKYCPopup = true;
            }else{this.isSpinnerMoving = false;this.kindlyRecaptureAadharPopup = true;this.templateAadharUploadMsg = false;this.disableUploadButtonAll = false;this.disableOCRButton = true;this.templateUploadMsg = false;this.deleteImage(this.documentRecordId, false, true, this.frontdocumentToDelete,false); }
        }).catch(error => {this.isSpinnerMoving = false;this.kindlyRecaptureAadharPopup = true;this.templateAadharUploadMsg = false;this.disableUploadButtonAll = false;this.disableOCRButton = true;this.templateUploadMsg = false;this.deleteImage(this.documentRecordId, false, true, this.frontdocumentToDelete,false);});
    }handleKindlyretryOkButton() {this.hanldeKindlyRetryMsg = false;}
    handleRecatureAadharPopup() {this.kindlyRecaptureAadharPopup = false;}finalValue = '';selectedVal;
    changeBiometricOtp() {
        this.selectedVal = this.template.querySelectorAll('lightning-radio-group'); const aadharComp = this.template.querySelector('[data-id="aadharNumber"]');
        this.finalValue = this.selectedVal[2].value;  this.templateSubmitButton = true;
        if (this.selectedVal[2].value == 'Biometric' || this.selectedVal[2].value == 'OTP') {
            if (FORM_FACTOR != 'Large' || this.selectedVal[2].value == 'OTP') {this.disableSubmitButton = false;}else{this.disableSubmitButton = true;} }
    }
    modalPopUpToggleFlag = false;@track aadharPopupValue;
    submitOtp() {
        this.aadharPopupValue = this.aadhaarValtoStore;
        if (this.scanManualRadioOptions == 'ScanAadhar' && this.finalValue == 'Biometric') {
            this.modalPopUpToggleFlag = false;  this.disableSubmitButton = true; this.cancelButton = false; this.disableBioOTPScanUplaod = true; this.disableManualEnterScan = true;this.disableBioOtpOptions = true;this.disableAadharField = true;
            if (FORM_FACTOR != 'Large') {this.disableSubmitButton = false; this.modalPopUpToggleFlag = true; }
        }else if (this.scanManualRadioOptions == 'ScanAadhar' && this.finalValue == 'OTP') {this.aadharEntered = this.aadhaarValtoStore.replace(/\d(?=\d{4})/g, "*");this.modalPopUpToggleFlag = true;this.PopupOTPForSubmit = false;this.disableAadharField = true;
        }else if (this.scanManualRadioOptions == 'ManuallyEnter') {this.modalPopUpToggleFlag = true;this.disableAadharField = true;}}
    closeModal() {this.modalPopUpToggleFlag = false;this.disableSubmitButton = true;this.cancelButton = false;this.allFields = true;this.disableBioOTPScanUplaod = true;this.disableManualEnterScan = true;this.disableBioOtpOptions = true;this.disabledKYCNo = true;this.disabledKYCName = true;this.disabledKYCAddress1 = true;this.disabledKYCAddress2 = true;this.disabledKYCPinCode = true;this.disabledKYCCity = this.isekyc ? false: true;this.disabledKYCState = true;this.disabledKYCDOB = true;this.disabledFirstName = true;this.disabledLastName = true;this.disabledGender = true;this.disabledSalutation = false;this.disabledAdharEnrollmentNumber = true;this.doneDisable = false;}@track getBiometricDetails = false;correctAadharYes() {this.disableBioOTPScanUplaod = true;this.disableManualEnterScan = true;this.disableSubmitButton = true;this.disabledKYCNo = true;this.disabledKYCName = true;this.disabledKYCAddress1 = true;this.disabledKYCAddress2 = true;this.disabledKYCPinCode = true;this.disabledKYCCity = true;this.disabledKYCState = true;this.disabledKYCDOB = true;this.disabledFirstName = true;this.disabledLastName = true;this.disabledGender = true;this.disabledSalutation = false;this.disabledAdharEnrollmentNumber = true;this.cancelButton = false;this.doneDisable = false;this.disableBioOtpOptions = true;this.disableAadharField = true;if(this.scanManualRadioOptions !== 'ScanAadhar'){docCustomerImage({ docType: this.type, applicantId: this.currentapplicationid, loanApplicationId: this.currentoppid }).then(result => {this.documentRecordId = result;}).catch(error => {this.error = error;});}
        if (this.finalValue == 'Biometric') {
            const applicantsFields = {};applicantsFields[APP_ID_FIELD.fieldApiName] = this.currentapplicationid;applicantsFields[AADHAR_NO_FIELD.fieldApiName] = this.aadhaarValtoStore;this.updateRecordDetails(applicantsFields);
            if (FORM_FACTOR != 'Large') {this.biometricCapture = true;this.getBiometricDetails = true;}
            this.modalPopUpToggleFlag = false;this.cancelButton = true;
        }else if (this.finalValue == 'OTP') {this.modalPopUpToggleFlag = false;this.PopupOTPForSubmit = true;this.allFields = false;}
    }
    async updateRecordDetails(fields) {const recordInput = { fields };await updateRecord(recordInput).then(result => {}).catch(error => {console.log(error)});}
    handlebiometricCapture() {
        this[NavigationMixin.Navigate]({
            type: "standard__webPage",
            attributes: {
                url: 'ibl://indusindbank.com/integratorInfo?' + this.label.currentApplicantid + '=' + this.currentapplicationid + '&' + this.label.currentUserId + '=' + this.currentUserId + '&' + this.label.currentUserEmailid + '=' + this.currentUserEmailId + '&' + this.label.currentUserName + '=' + this.currentUserName + '&' + this.label.mode + '=' + 'Biometric' + '&fType=' + this.fType + '&fCount=' + this.fCount__c + '&env=' + this.env__c + '&format=' + this.format__c + '&pidver=' + this.pidver__c + '&strwadh=' + this.str_wadh__c + '&timeout=' + this.timeout__c + '&wadhType=' + this.wadhType__c
            }});}
    handleGetBiometricDetails() {
        getPidBlockStatus({ applicantId: this.currentapplicationid })
        .then(result => {
            if (result) {
                resendAadharBiometric({ docRecordId: this.documentRecordId })
                  .then(resultcount => {
                    console.log('Result resendAadharBiometric', resultcount);
                    if(resultcount <= 2){
                        let randomNumber = Math.random();
                        doUidaiBiometricCallout({ applicantId: this.currentapplicationid, loanAppId: this.currentoppid, randomNo:randomNumber})
                            .then(result => {
                                this.isSpinnerMoving = false;
                                const obj = JSON.parse(result);
                                const objJSON = JSON.parse(obj);
                                if (objJSON.kycResponse.TransactionInfo.ResponseMsg==='Approved') {
                                    this.kycNo = objJSON.kycResponse.UidData.uid.replace(/\d(?=\d{4})/g, "*");this.aadhaarNumber = objJSON.kycResponse.UidData.uid;
                                    this.kycName = objJSON.kycResponse.UidData.name;
                                    var apiResFirstName = "";
                                    var apiResLastName = "";
                                    let fullName = objJSON.kycResponse.UidData.name;
                                    if (this.kycName.split(" ").length > 1) {
                                        apiResLastName = fullName.substring(fullName.lastIndexOf(" ") + 1);
                                        apiResFirstName = fullName.substring(0, fullName.lastIndexOf(' '));
                                    }else{
                                        apiResFirstName = this.kycName;
                                    }
                                    this.firstName = apiResFirstName;
                                    this.lastName = apiResLastName;
                                    this.kycDOB = objJSON.kycResponse.UidData.dob.split("-").reverse().join("-");
                                    let house = objJSON.kycResponse.UidData.house == 'null' ? '' : objJSON.kycResponse.UidData.house;
                                    let lm = objJSON.kycResponse.UidData.lm == 'null' ? '' : objJSON.kycResponse.UidData.lm;
                                    this.kycAddress1 = house + ' ' + lm;
                                    let street = objJSON.kycResponse.UidData.street == 'null' ? '' : objJSON.kycResponse.UidData.street;
                                    let loc = objJSON.kycResponse.UidData.loc == 'null' ? '' : objJSON.kycResponse.UidData.loc;
                                    let vtc = objJSON.kycResponse.UidData.vtc == 'null' ? '' : objJSON.kycResponse.UidData.vtc;
                                    this.kycAddress2 = street + ' ' + loc + ' ' + vtc;
                                    //CISP-7909 Populate address line 2 with address line 1 if address line 2 is blank for aadhaar
                                    if (this.type === this.label.AadhaarCard && (this.kycAddress2 === "" || this.kycAddress2 === null || this.kycAddress2 === undefined)) { this.kycAddress2 = this.kycAddress1;}
                                    this.currentAddressData.KYC_Pin_Code__c = objJSON.kycResponse.UidData.pc;
                                    this.currentAddressData.KYC_State__c =cityCheckMaster(this.stateCityMaster,objJSON.kycResponse.UidData?.dist?.toUpperCase(),objJSON.kycResponse.UidData.state.toUpperCase())? objJSON.kycResponse.UidData.state.toUpperCase(): null;
                                    this.currentAddressData.KYC_City__c =cityCheckMaster(this.stateCityMaster,objJSON.kycResponse.UidData?.dist?.toUpperCase(),objJSON.kycResponse.UidData.state.toUpperCase())? objJSON.kycResponse.UidData?.dist?.toUpperCase(): null;
                                    if (objJSON.kycResponse.UidData.gender==='F') {this.kycGender ='FEMALE';this.kycSalutation='Ms.';
                                    } else if (objJSON.kycResponse.UidData.gender==='M') {this.kycGender ='MALE';this.kycSalutation='Mr.';}
                                    else if (objJSON.kycResponse.UidData.gender==='TG') {this.kycGender ='TRANSGENDER';this.kycSalutation;}let base64Imag = '';let tknNumber = '';
                                    if(objJSON.kycResponse.UidData.Pht){base64Imag = objJSON.kycResponse.UidData.Pht;}
                                    if(objJSON.kycResponse.UidData.tkn){tknNumber = objJSON.kycResponse.UidData.tkn;}this.aadhaarVaultNo=tknNumber;
                                    this.setSalutationVal();
                                    if(!this.currentAddressData.KYC_City__c && this.currentAddressData.KYC_Pin_Code__c){this.cityValue =City(this.stateCityMaster,this.currentAddressData.KYC_Pin_Code__c);this.isekyc=true;this.disabledKYCCity=false;this.StateMasterDistrict(this.currentAddressData.KYC_State__c);}else{this.stateMaster(objJSON.kycResponse.UidData.state.toUpperCase(), objJSON.kycResponse.UidData.dist.toUpperCase());}
                                    this.disabledSalutation=false;
                                    saveImagetoSF({'base64Imag': base64Imag,'documentId':this.documentRecordId, 'tknNo':tknNumber});
                                    this.templateExPanFields = true;this.allFields = true;this.cancelButton = false;
                                }else{if(!this.isStepThreeV2 && resultcount > 2){this.finalValue == 'OTP';this.successToast('Error', 'Attempt  to  do  e-KYC  through  Biometric  for  this  applicant  is unsuccessful. Please initiate e-KYC through OTP method', 'error');afterBioMetricFailure(this);}else{this.successToast('Error', objJSON.kycResponse.TransactionInfo.ResponseMsg, 'error');}this.templateExPanFields = false;this.allFields = false;this.cancelButton = true;}
                            }).catch(error => {if(!this.isStepThreeV2 && resultcount > 2){this.finalValue == 'OTP';this.successToast('Error', 'Attempt  to  do  e-KYC  through  Biometric  for  this  applicant  is unsuccessful. Please initiate e-KYC through OTP method', 'error');afterBioMetricFailure(this);}else{this.successToast('Error', 'Capturing Biometric details failed. Please retry', 'error');}this.isSpinnerMoving = false;});
                    }else{if(!this.isStepThreeV2 && resultcount > 2){this.finalValue == 'OTP';this.successToast('Error', 'Attempt  to  do  e-KYC  through  Biometric  for  this  applicant  is unsuccessful. Please initiate e-KYC through OTP method', 'error');afterBioMetricFailure(this);}else{this.successToast('Error', 'Please capture Biometric again', 'error');}this.templateExPanFields = false;this.allFields = false;this.cancelButton = true;}
                  })
                  .catch(error => {
                    console.error('Error:', error);
                });}else{this.successToast('Error', 'Please capture Biometric again', 'error');}}).catch(error => {});
    }
    wrongAadharNo() {this.modalPopUpToggleFlag = false; this.templateBiometricOTPOptions = true; this.templateSubmitButton = true;this.disableAadharField = false;this.disableSubmitButton = false;this.disableBioOtpOptions = false; this.cancelButton = true;this.PopupOTPForSubmit = false;if(this.ProdType == 'Two Wheeler' || FORM_FACTOR != 'Large'){this.disableBioOtpOptions = true}}
    aadharOtpRetryExhaust() {
        if(this.ProdType == 'Two Wheeler' || FORM_FACTOR != 'Large'){this.modalPopUpToggleFlag = false;biometricOTPSelectAndUploadChange(this)
        }else{this.modalPopUpToggleFlag = false;this.templateBiometricOTPOptions = true;this.templateSubmitButton = true;this.disableAadharField = true;this.disableSubmitButton = true;this.disableBioOtpOptions = true;this.cancelButton = true;}
    }
    selectedPanForm = this.label.PanCards;@track panRadioOptions = [];//Ola
    panRadioOptions = [
        { 'label': this.label.PanCards, 'value': this.label.PanCards },{ 'label': this.label.Form60DocumentType, 'value': this.label.Form60DocumentType },];
    selectedPanOption = '';doneButton = false;
    handlePanChange(event) {
        this.selectedPanOption = event.target.value;
        if (this.selectedPanOption===this.label.Form60DocumentType) {
            this.successToast('Information','If exposure (incl. current loan amount) is >=10 Lakhs, PAN is mandatory.','Info');
            this.selectedPanForm = this.label.Form60DocumentType;this.kycdocname=this.label.Form60DocumentType;
            this.panFlag = false;this.form60Flag = true;this.type = this.label.Form60DocumentType;
        //CISP-6470
            if(this.kycdocname == this.label.Form60DocumentType){this.poiAndPoaRemoving = false;}//CISP-6470
        } else if (this.selectedPanOption===this.label.PanCards) {if(!this.isNonIndividualBorrower){this.successToast('Information','Please ensure PAN is linked to Aadhaar, else upload Form 60.','Info');}this.selectedPanForm = this.label.PanCards;this.kycdocname=this.label.PanCards; this.panFlag = true; this.form60Flag = false; this.type = this.label.PanCards; this.doneButton = false;}
        if(this.selectedPanOption===this.label.Form60DocumentType && (parseInt(this.numOfKycDocIsPresent) == 1 || parseInt(this.numOfKycDocIsPresent) == 0)){
            this.successToast('User has uploaded only 1 KYC along with Form 60, this proposal is not eligible for e-agreement. Please upload 1 more KYC if e-agreement is required.','','warning');}}
    @track disabledDocumentType = false;@track disabledKYCNo = false;@track disabledKYCName = false;@track disabledKYCAddress1 = false;@track disabledKYCAddress2 = false;@track disabledKYCPinCode = false;@track disabledKYCCity = false;@track disabledKYCState = false;@track disabledKYCDOB = false;@track disabledPanNo = false;
    @track disabledFirstName = false;@track disabledLastName = false;@track disabledGender = false;@track disabledSalutation = false;@track disabledDLType = false;  @track disabledGstNo = false;  @track disabledCinNo = false;
    @track disabledKYCIssuanceceDate = false;@track disabledKYCExpiryDate = false;@track disabledAge = false;@track disabledPassportFileNo = false;
    @track disabledPassportNo = false;@track disabledAdharEnrollmentNumber = false;@track disableAadharFrontButton = false;
    @track disableAadharBackButton = true; @track disabledGoldenSource = false;@track disablePANBackButton = true;@track disablePassportBackButton = true;
    @track disableVoterBackButton = true; @track disableDLBackButton = true;@track goldenSourceDisable = false; @track isSuccessGoldenSOurce = true;
    @track scanAndUploadComponent = false;@track fieldValueFlag = false;
    openCancelPopUP = false; 
    handleCancel() { this.openCancelPopUP = true; this.addressProofUploadScreenFlag = false;this.showAlternateKYCPopup = false; }
    closepopup() { this.openCancelPopUP = false;}
    kycDeleteFields() {
        this.template.querySelectorAll("lightning-input").forEach(item => {
            let fieldValue = item.value;  let fieldLabel = item.label;
            if (fieldValue != this.label.PassportCard && fieldValue != this.label.DrivingLicences &&
                fieldValue != this.label.AadhaarCard && fieldValue != this.label.PanCards && fieldValue != this.label.Form60DocumentType && fieldValue != this.label.VoterIdCard) {
                item.value = ""; } });
                if(this.type != this.label.PanCards){kycDeletedocument({ loanApplicationId: this.documentRecordId })
                .then(result => { }).catch(error => {this.error=error; });  }else if((this.aadhaarSeedingStatus != '' || this.aadhaarSeedingStatus != null || this.nsdlResponse != null || this.nsdlResponse != '')&& (this.type == this.label.PanCards)){updatePanDetailsAfterCancelButton(this)}}    
    handleonChange(event) {
        let name = event.currentTarget.dataset.id;
        if (name == 'gstNoId') { this.kycGstNo = event.currentTarget.value;} 
        else if (name == 'cinNoId') { 
            this.kycCinNo = event.currentTarget.value; 
            let year = parseInt(this.kycCinNo.substring(8, 12));
            let current_year = new Date().getFullYear();
            let ref = this.template.querySelector('lightning-input[data-id=cinNoId]');
            if (!(year > 1900 && year <= current_year)) {
                ref.setCustomValidity('Please enter valid CIN Number');
            } else {
                ref.setCustomValidity('');
            }
            ref.reportValidity();
        } 
    }
    changeEvent() {
        let firstNameInput = this.template.querySelector('lightning-input[data-id=firstNameId]');
        let firstNameValue = firstNameInput.value.trim();
        this.firstNameValue = firstNameValue;
        if (((firstNameValue.length > 26 || firstNameValue.length == 0) && !this.isNonIndividualBorrower) || (firstNameValue.length > 40 && this.isNonIndividualBorrower)) {firstNameInput.setCustomValidity(this.label.lastNameError); }else{firstNameInput.setCustomValidity("");}

        let lastNameInput = this.template.querySelector('lightning-input[data-id=lastNameId]'); let lastNameValue = lastNameInput.value.trim(); this.lastNameValue = lastNameValue;
        if (((lastNameValue.length > 26 || lastNameValue.length == 0) && !this.isNonIndividualBorrower) || (lastNameValue.length > 40 && this.isNonIndividualBorrower)) { 
            lastNameInput.setCustomValidity(this.label.lastNameError);}else{lastNameInput.setCustomValidity("");}
        
        let kycNameInput = this.template.querySelector('lightning-input[data-id=kycNameId]');
        let kycNameValue = kycNameInput.value;this.kycNameValue = lastNameValue;
        if ((kycNameValue.length > 26 && !this.isNonIndividualBorrower) || (kycNameValue.length > 80 && this.isNonIndividualBorrower)) {
            firstNameInput.setCustomValidity(this.label.lastNameError);lastNameInput.setCustomValidity(this.label.lastNameError);
            }else{if(firstNameValue.length == 0){firstNameInput.setCustomValidity(this.label.lastNameError)}else{firstNameInput.setCustomValidity("");}if(lastNameValue.length == 0){lastNameInput.setCustomValidity(this.label.lastNameError);}else{lastNameInput.setCustomValidity("");}}
            firstNameInput.reportValidity();lastNameInput.reportValidity();
        kycNameInput.reportValidity();
        if (this.value == this.label.AadhaarCard) {
            checkAdhaarVerification({ applicantId: this.currentapplicationid }).then(result => {
                this.aadharOtpBiometricVerification = result;}).catch(error => {this.error = error;}); } }
                @track DistictOption;@track Form60State;
    form60FieldsValues={};ChangeEventForm60(event) 
{let form60Fields = this.form60FieldsValues;
let firstNameInput = this.template.querySelector('lightning-input[data-id=firstNameIdForm60]').value;let Gender=  this.template.querySelector("[data-id='formgenderId']").value;let State=  this.template.querySelector("[data-id='formStateId']").value; this.Form60State=State;let CityForm= this.template.querySelector("[data-id='formCityDataId']").value;let DistrictValue= this.template.querySelector("[data-id='formDistrictID']").value;
if(State!=null || this.Form60State !=null){this.stateMaster(State.toUpperCase(), null); this.StateMasterDistrict(this.Form60State.toUpperCase());}
let AgeInput = this.template.querySelector('lightning-input[data-id=formageId]');
if(AgeInput.value<18 || AgeInput.value>80){AgeInput.setCustomValidity(' Age should be between 18 to 80')}else{AgeInput.setCustomValidity('')};
let surNameInput = this.template.querySelector('lightning-input[data-id=SurnameIdForm60]').value;let FatherNameInput=this.template.querySelector('lightning-input[data-id=FathernameForm60]').value; let DateOfBirthInput=this.template.querySelector('lightning-input[data-id=DateOfBirthId]').value;let AddressInput=this.template.querySelector('lightning-input[data-id=addressForm60Id]').value;let PincodeInput = this.template.querySelector('lightning-input[data-id=PincodeId]').value;
let MobileNumberInput = this.template.querySelector('lightning-input[data-id=MobileNumberId]').value; let PANEnInput = this.template.querySelector('lightning-input[data-id=PANFormId]').value;let estimateIncome = this.template.querySelector('lightning-input[data-id=AnnualIncomeId]').value;let AmountoftraIncome = this.template.querySelector('lightning-input[data-id=AmountofTransaction]').value;let DateoftraIncome = this.template.querySelector('lightning-input[data-id=dateofTransaction]').value;let nofoperson= this.template.querySelector('lightning-input[data-id=numberofofTransaction]').value;
form60Fields[First_Name__c.fieldApiName] = firstNameInput;form60Fields[Last_Name__c.fieldApiName] = surNameInput; form60Fields[Father_Name__c.fieldApiName]= FatherNameInput; form60Fields[KYC_DOB__c.fieldApiName]= DateOfBirthInput; form60Fields[Address__c.fieldApiName]= AddressInput;
form60Fields[KYC_Pin_Code__c.fieldApiName]=PincodeInput;form60Fields[Mobile_number__c.fieldApiName]=MobileNumberInput;form60Fields[Proof_of_Address_POA__c.fieldApiName]=event.target.checked;form60Fields[Proof_of_Identity_POI__c.fieldApiName]=event.target.checked;form60Fields[PAN_acknowledgement_number__c.fieldApiName]=PANEnInput;form60Fields[Estimated_annual_income__c.fieldApiName]=estimateIncome; form60Fields[Amount_of_transaction__c.fieldApiName]=AmountoftraIncome;
form60Fields[Date_of_transaction__c.fieldApiName]=DateoftraIncome;form60Fields[Number_of_persons_involved_in_the_transa__c.fieldApiName]=nofoperson;form60Fields[DOCUMENT_NAME.fieldApiName]=this.label.Form60DocumentType;form60Fields[DocumentType.fieldApiName]=this.label.Form60DocumentType;form60Fields[IsActive.fieldApiName]=true;form60Fields[Gender__c.fieldApiName] = Gender;form60Fields[Age__c.fieldApiName] = AgeInput.value; form60Fields[KYC_State__c.fieldApiName] = State; form60Fields[KYC_City__c.fieldApiName] = CityForm; form60Fields[KYC_District__c.fieldApiName] = DistrictValue; 
    this.form60FieldsValues=form60Fields;}
    handleKycAge(event){ this.kycAge=event.target.value; this.ageCheck();}
    ageCheck(){
        if(this.type == this.label.VoterIdCard){ var inputCmpdob = this.template.querySelector('lightning-input[data-id=ageId]');
            if (this.kycAge > 80) {inputCmpdob.setCustomValidity('Maximum age should be atmost 80 years');} else if (this.kycAge < 18) { inputCmpdob.setCustomValidity('Minimum age should be atleast 18 years');}else{ inputCmpdob.setCustomValidity('');} }}
    addressCheck(element,addressValue,minLength,addressLine){
        var address1Regex = /^(?=.{10,40}$)(^([A-Za-z0-9-_.,:;#\/']+[A-Za-z0-9-_.,:;#\/' ]*$)\2?(?!\2))+$/;
        var address2Regex = /^(?=.{3,40}$)(^([A-Za-z0-9-_.,:;#\/']+[A-Za-z0-9-_.,:;#\/' ]*$)\2?(?!\2))+$/;
        if (addressValue.length < minLength && addressLine==1) {element.disabled = false; 
            element.setCustomValidity(this.label.AddressValidation3);this.allFieldsPopulated=false; 
        } else if (addressValue.length < minLength && addressLine==2) {element.disabled = false; 
            element.setCustomValidity(this.label.AddressValidation1);this.allFieldsPopulated=false; 
        } else if (addressValue.length > 40) {element.disabled = false; 
            element.setCustomValidity(this.label.AddressValidation2);this.allFieldsPopulated=false; 
        } else if((!address1Regex.test(addressValue) && addressLine==1) || (!address2Regex.test(addressValue) && addressLine==2)){element.disabled = false; 
            element.setCustomValidity(this.label.AddressnotValid);this.allFieldsPopulated=false; 
        } else {
            element.setCustomValidity("");}element.reportValidity();}
    addressLine1validation() {let address1 = this.template.querySelector('lightning-input[data-id=addline1Id]'); this.addressCheck(address1,address1.value,10,1);}
    addressLine2validation() { let address2 = this.template.querySelector('lightning-input[data-id=addline2Id]');this.addressCheck(address2,address2.value,3,2); }
    allFieldsPopulated = false; flagForExpiry = false;@track minExpiryDate = new Date();
    validationhandle() {
        this.isSpinnerMoving = true;
        if (this.type == this.label.DrivingLicences || this.type == this.label.PassportCard || this.type == this.label.VoterIdCard) {
            if(!this.isNonIndividualBorrower){this.ageCheck();}
            var today = new Date();
            if ((new Date(this.kycIssuanceDate)) > today) {
                var inputCmp = this.template.querySelector('lightning-input[data-id=kycIssuaceDateId]');
                inputCmp.setCustomValidity('Date should be less than current date'); }   }
        var ageInMilliseconds = new Date() - new Date(this.kycDOB);
        if (Math.floor(ageInMilliseconds / 1000 / 60 / 60 / 24 / 365) > 0) {
            this.kycAge = Math.floor(ageInMilliseconds / 1000 / 60 / 60 / 24 / 365);}
            if(!this.isNonIndividualBorrower){this.dateValidation();}
        var differenceInDays = -1;
        if (this.type == this.label.DrivingLicences || this.type == this.label.PassportCard) {
            this.kycExpiryDate = this.template.querySelector('lightning-input[data-id=expiryDateId]').value;
            var today = new Date();
            today.setDate(today.getDate() + 30);
            this.minExpiryDate = today;
            differenceInDays = (today.getTime() - (new Date(this.kycExpiryDate)).getTime()) / (1000 * 3600 * 24);
            if(differenceInDays <= 30 && differenceInDays > 0 || (new Date(this.kycExpiryDate)) < today) { 
                this.showAlternateKYCPopup = true;this.flagForExpiry = true; }else{this.flagForExpiry = false;} }
        const fields = this.template.querySelectorAll("lightning-input");
        const comboboxfield1 = this.template.querySelectorAll("lightning-combobox");
        const isInputsCorrect = [...this.template.querySelectorAll('lightning-input')]
            .reduce((validSoFar, inputField) => {
                inputField.reportValidity();
                return validSoFar && inputField.checkValidity();}, true);
        if (isInputsCorrect && this.flagForExpiry == false) {
            this.allInputValid = true;this.allFieldsPopulated = true;}else{this.allFieldsPopulated = false;
            this.successToast('Check Fields again', '' , 'warning');}
        this.allFieldsPopulated = false;
        const comboboxfield = [...this.template.querySelectorAll("lightning-combobox")]
            .reduce((validSoFar, inputField) => {
                inputField.reportValidity();
                return validSoFar && inputField.checkValidity();}, true);
        if (comboboxfield && isInputsCorrect && this.flagForExpiry == false) {
            this.allFieldsPopulated = true;}
        else{
            this.allFieldsPopulated = false;
            this.successToast('Check Fields again', '', 'warning');} this.isSpinnerMoving = false; }
    scanAndUploadComponent = false; loanApplicationFlag = false; kycData; kycName;@track firstName;@track lastName;kycGender;kycNo;kycDLType;
    @track showAlternateKYCPopup = false;
    async handleDone() {try{if((this.selectedAadharOption == 'Scan and Upload' && this.type === this.label.AadhaarCard) || (this.type !== this.label.AadhaarCard)){
        let response = await contentDocumentPresentOrNot({'docId' : this.documentRecordId,'aadhaarSource' : this.selectedAadharOption}); if(!response){this.successToast('Please click on cancel and re-upload the document again.', '', 'error');return;}}
        if(this.selectedAadharOption == 'Biometric/OTP'){if(await ageValidation(this.kycDOB, this.AppType,this.ProdType)){this.cancelYes();}}
        this.isSpinnerMoving = true;let iscallOtherMethod = false;
        if(this.template.querySelector('lightning-input[data-id=KycPinCodeDataId]')) {await this.validateKYCPinCode();}
        if (this.selectedAadharOption != 'Biometric/OTP' && ![ this.label.Form60DocumentType ,this.label.PanCards ,this.label.GST_CERT, this.label.CIN_CERT].includes(this.type) && (this.backdocumentToDelete == null || (!this.backUploadButton && !this.backUploadRedCross && !this.disableAadharBackButton))) {this.successToast('Complete back upload process.', '', 'error');this.isSpinnerMoving = false;return;}
        else if (this.selectedAadharOption != 'Biometric/OTP' && this.type != this.label.Form60DocumentType && this.type != this.label.GST_CERT && this.type != this.label.CIN_CERT && this.type != this.label.PanCards && (this.frontdocumentToDelete == null || (!this.frontUploadButton && !this.frontUploadRedCross && !this.disableAadharFrontButton))) {this.successToast('Complete front upload process.', '', 'error');this.isSpinnerMoving = false;return;
        }else if(![this.label.Form60DocumentType].includes(this.type)){await this.validationhandle();await this.onChangeKYCNumber(true);if(this.allFieldsPopulated){this.isSpinnerMoving = true;}}
        if(this.selectedAadharOption == 'Scan and Upload' && this.type===this.label.AadhaarCard){if(this.allFieldsPopulated==true && this.disableDocAuthButton == true){let result = await doAadhaarVaultAPICallout({'leadId': this.currentoppid , 'AadhaarNo': this.aadhaarNumber, 'applicantId' : this.currentapplicationid});if(result){var obj = JSON.parse(result);this.aadhaarVaultNo = obj.response.content[0].UID_Token_No;iscallOtherMethod=true;}else{iscallOtherMethod = false;}}
        // else if(!this.disableDocAuthButton){this.successToast('Doc Auth required', '', 'error');isSpinnerMoving=false;return;} CISP-22905
        else{this.isSpinnerMoving=false;return;}}else{ iscallOtherMethod = true;}
        if(iscallOtherMethod == true){ 
        if (this.type == this.label.Form60DocumentType) {
        let AllForm60fi =  this.template.querySelector('lightning-input[data-id=firstNameIdForm60]');let AllForm60fa =  this.template.querySelector('lightning-input[data-id=FathernameForm60]');let AllForm60SA =  this.template.querySelector('lightning-input[data-id=SurnameIdForm60]');let AllForm60da =  this.template.querySelector('lightning-input[data-id=DateOfBirthId]');let AllForm60AA =  this.template.querySelector('lightning-input[data-id=addressForm60Id]');let AllForm60PN =  this.template.querySelector('lightning-input[data-id=PincodeId]');let AllForm60MN =  this.template.querySelector('lightning-input[data-id=MobileNumberId]');let AllForm60AAdh = this.template.querySelector('lightning-input[data-id=AdharformId]');let AllForm60PAN = this.template.querySelector('lightning-input[data-id=PANFormId]');let AllForm60EST= this.template.querySelector('lightning-input[data-id=AnnualIncomeId]');let AllForm60AMTT= this.template.querySelector('lightning-input[data-id=AmountofTransaction]');let AllForm60DATT= this.template.querySelector('lightning-input[data-id=dateofTransaction]');let AllForm60NOFT= this.template.querySelector('lightning-input[data-id=numberofofTransaction]');
        if(!AllForm60NOFT.checkValidity()||!AllForm60DATT.checkValidity()||!AllForm60AMTT.checkValidity()||!AllForm60EST.checkValidity()||!AllForm60fi.checkValidity () ||!AllForm60SA.checkValidity() ||!AllForm60fa.checkValidity()|| !AllForm60da.checkValidity()|| !AllForm60AA.checkValidity() || !AllForm60PN.checkValidity()|| !AllForm60MN.checkValidity()|| !AllForm60AAdh.checkValidity() || !AllForm60PAN.checkValidity()){AllForm60NOFT.reportValidity();AllForm60DATT.reportValidity();AllForm60AMTT.reportValidity(); AllForm60EST.reportValidity();AllForm60fi.reportValidity(); AllForm60SA.reportValidity();AllForm60fa.reportValidity();AllForm60da.reportValidity();AllForm60AA.reportValidity(); AllForm60PN.reportValidity(); AllForm60MN.reportValidity(); AllForm60AAdh.reportValidity(); AllForm60PAN.reportValidity();this.isSpinnerMoving=false;const evt = new ShowToastEvent({title: "warning",  message: 'Please fill the Mandatory fields',  variant: 'warning' });
            this.dispatchEvent(evt);return;}
        if(AllForm60AAdh.value!=null){
        getEncryptedData({data:AllForm60AAdh.value}).then( resp => { const fields =this.form60FieldsValues; fields[Aadhaar_Enrollment_Number__c.fieldApiName]=resp; fields[DOC_ID_FIELD.fieldApiName] = this.documentRecordId ;const recordInput = { fields };updateRecord(recordInput).then(result => {this.dispatchEvent(new CustomEvent('close', { detail: this.documentRecordId }));this.dispatchEvent(new CustomEvent('kycdonesuccess', { detail: this.type }));if(this.isStepFour){let result = this.updateApplicantName(this.currentapplicationid);if(result){this.dispatchEvent(new CustomEvent('updateapplicantname',{detail: result}));}else{this.successToast('Error' , this.label.ExceptionMessage, 'error');}}this.isSpinnerMoving = false;
        }).catch( e => { this.successToast('Error' , this.label.ExceptionMessage, 'error');this.isSpinnerMoving = false;});}).catch(error=>{this.successToast('Error' , this.label.ExceptionMessage, 'error');this.isSpinnerMoving = false;})}}
        if (this.allFieldsPopulated && (this.goldenSourceDisable || (([this.label.AadhaarCard, this.label.PassportCard, this.label.VoterIdCard, this.label.GST_CERT, this.label.CIN_CERT].includes(this.type))
            && this.disableDocAuthButton))) {
            if ( ![this.label.PanCards, this.label.GST_CERT, this.label.CIN_CERT].includes(this.type)) {
                this.kycAddress1 = this.template.querySelector('lightning-input[data-id=addline1Id]').value; this.kycAddress2 = this.template.querySelector('lightning-input[data-id=addline2Id]').value;this.kycCity = this.template.querySelector('lightning-combobox[data-id=kycCityDataId]').value;this.kycState = this.template.querySelector('lightning-combobox[data-id=kycStateDataId]').value;this.kycPinCode = this.template.querySelector('lightning-input[data-id=KycPinCodeDataId]').value;this.kycIssuanceDate = null;   
            }
            if (![this.label.GST_CERT, this.label.CIN_CERT].includes(this.type)) {
            this.kycName = this.template.querySelector('lightning-input[data-id=kycNameId]').value;this.kycDOB = this.template.querySelector('lightning-input[data-id=kycDobId]').value; this.firstName = this.template.querySelector('lightning-input[data-id=firstNameId]').value;this.lastName = this.template.querySelector('lightning-input[data-id=lastNameId]').value;this.kycGender = this.template.querySelector('lightning-combobox[data-id=genderId]')?.value;this.kycSalutation = this.template.querySelector('lightning-combobox[data-id=salutationId]')?.value;this.setSalutationVal();}
            if (this.type == this.label.DrivingLicences || this.type == this.label.VoterIdCard) {
                this.kycNo = this.template.querySelector('lightning-input[data-id=kycNoId]').value;
            }
            if (this.type == this.label.AadhaarCard) {
                this.kycAadharEnrollment = this.template.querySelector('lightning-input[data-id=aadharEnrollmentId]').value; }
            if (this.type == this.label.DrivingLicences || this.type == this.label.VoterIdCard || this.type == this.label.PassportCard) {
                this.kycIssuanceDate = this.template.querySelector('lightning-input[data-id=kycIssuaceDateId]').value;}
            if (this.type == this.label.DrivingLicences || this.type == this.label.PassportCard) {
                this.kycExpiryDate = this.template.querySelector('lightning-input[data-id=expiryDateId]').value; }
            if (this.type == this.label.PanCards) {
                this.kycPanNo = this.template.querySelector('lightning-input[data-id=panNoId]').value;}
            if (this.type == this.label.VoterIdCard) {
                var ageInMilliseconds = new Date() - new Date(this.kycDOB);
                this.kycAge = Math.floor(ageInMilliseconds / 1000 / 60 / 60 / 24 / 365);}
            if (this.type == this.label.PassportCard) {
                this.kycPassportFileNo = this.template.querySelector('lightning-input[data-id=passportFileNoId]').value;
                this.kycPassportNo = this.template.querySelector('lightning-input[data-id=passportNoId]').value;}
            if (this.type == this.label.DrivingLicences || this.type == this.label.PassportCard) {
                var today = new Date();
                today.setDate(today.getDate() + 30);
                var differenceInDays = ((today / (1000 * 60 * 60 * 24)) % 1890) - (((new Date(this.kycExpiryDate)) / (1000 * 60 * 60 * 24)) % 1890);
                if (differenceInDays <= 31 && differenceInDays > 0) {}}
            if (this.selectedAadharOption == 'Scan and Upload') {this.aadharSource = 'Scan and Upload'; } else if (this.finalValue == 'Biometric') {this.aadharSource = this.finalValue;} else if (this.finalValue == 'OTP') {this.aadharSource = this.finalValue;
            } else if (this.scanManualRadioOptions==='ScanAadhar') {this.aadharSource = this.scanManualRadioOptions;}
            this.kycData = {isPhotocopy: this.isPhotocopy,aadharSource: this.aadharSource,documentName: this.kycdocname,documentKycNo: this.selectedAadharOption == 'Scan and Upload' ? this.kycNo : this.aadhaarNumber,documentKycName: this.kycName, documentKYCAddressLine1: this.ProdType == 'Two Wheeler' ? this.kycAddress1.replace(/[^\x00-\x7F]/g, '') : this.kycAddress1,documentKYCAddressLine2: this.ProdType == 'Two Wheeler' ? this.kycAddress2.replace(/[^\x00-\x7F]/g, '') : this.kycAddress2,documentKycPinCode: this.kycPinCode,documentKycCity: this.ProdType == 'Two Wheeler' ? this.kycCity.replace(/[^\x00-\x7F]/g, '') : this.kycCity,documentKycDistrict: this.kycDistrict,documentKycState: this.ProdType == 'Two Wheeler' ? this.kycState.replace(/[^\x00-\x7F]/g, '') : this.kycState,documentKycDob: this.kycDOB==="" ? null : this.kycDOB,documentAadhaarEnrollmentNumber: this.kycAadharEnrollment==="" ? null : this.kycAadharEnrollment,documentFirstName: this.firstName,documentLastName: this.lastName,documentGender: this.kycGender,documentSalutation: this.kycSalutation,documentPanNo: this.kycPanNo,documentAge: this.kycAge==="" ? null : this.kycAge,documentKycIssuanceDate: this.kycIssuanceDate==="" ? null : this.kycIssuanceDate,documentKycExpiryDate: this.kycExpiryDate==="" ? null : this.kycExpiryDate,documentDLType: this.kycDLType==="" ? null : this.kycDLType,documentPassportFileNo: this.kycPassportFileNo,documentPassportNo: this.kycPassportNo, documentGstNo : this.kycGstNo, documentCinNo : this.kycCinNo,aadhaarVaultToken:this.aadhaarVaultNo,nsdlResponse : this.nsdlResponse,aadharSeedingStatus:this.aadhaarSeedingStatus, panApproved : this.panAutoApproved,nsdlStatus :this.NSDLPANStatus,nsdlPanName : this.nsdlPanName,nsdlNameMatchPer : this.nsdlNameMatchPer
            };if(this.type==this.label.AadhaarCard && !this.aadhaarVaultNo){this.successToast('Error!','Aadhar Vault token not captured. Please retry.','error');return;}
            await kycSaveData({ docType: this.type, kycData: JSON.stringify(this.kycData), applicantId: this.currentapplicationid, docId: this.documentRecordId }).then(result => {if (result == true) {if(this.entitytype == 'Proprietorship' && ![this.label.GST_CERT, this.label.CIN_CERT].includes(this.type) && this.kycName?.toUpperCase() != this.customerName?.toUpperCase()){this.confirmationModal = true; this.showTimer(); }else{this.yesPopUPHandler();}}this.isSpinnerMoving = false;this.dispatchEvent(new CustomEvent('sendingcurrentstep'));}).catch(error => {this.isSpinnerMoving = false;this.successToast('Error in save data', error.body.message, 'error');});
        }else if (this.type != this.label.AadhaarCard && this.type != this.label.Form60DocumentType && !this.goldenSourceDisable && this.type !== this.label.VoterIdCard && this.type !== this.label.PassportCard && this.type !== this.label.CIN_CERT && this.type !== this.label.GST_CERT) {this.successToast('Error', 'GoldenSource Required', 'error');this.isSpinnerMoving = false;}
        // else if ((!this.docAuthButtonButton && !this.backUploadRedCross && !this.frontUploadRedCross) && !this.disableDocAuthButton && this.type != this.label.Form60DocumentType && this.type !== this.label.CIN_CERT && this.type !== this.label.GST_CERT || (!this.disableDocAuthButton && (this.frontUploadRedCross || this.backUploadRedCross))){this.successToast('Doc Auth required', '', 'error');this.isSpinnerMoving = false;} CISP-22905
    }else{this.successToast('Aadhar Vault Api Got Failed. Please retry', '', 'error');this.isSpinnerMoving = false;}}catch(error){this.successToast(error?.body?.message, '', 'error');this.isSpinnerMoving = false;}}@track timervalue = 6;@track intervalId;@track yesLabel;
    showTimer(){var parentThis = this;parentThis.yesLabel = 'Yes';parentThis.intervalId = setInterval(function () {parentThis.yesLabel = `Yes ${parentThis.timervalue}`; parentThis.timervalue--;if(parentThis.timervalue <= 0){parentThis.yesLabel = `Yes`; parentThis.yesDisabled = false; clearInterval(parentThis.intervalId);}}, 1000);}
    async yesPopUPHandler(){
        this.yesDisabled = true;
        this.poiTagging();
        this.successToast('Uploaded successfully!', 'Details are stored successfully', 'success');
        if (this.type === this.label.AadhaarCard) {
            this.isSpinnerMoving = true;
            try {
                const result = await DemoAuthAPI({ 
                    'applicantId': this.currentapplicationid, 
                    'documentId': this.documentRecordId,
                    'loanApplicationId': this.currentoppid 
                });
                if (result === 'Success') {
                    this.successToast('Demo Auth API Success', '', 'success');
                } else if (result === 'Rejected') {this.successToast('Demo Auth API Rejected', '', 'error');this.noPopUPHandler();this.demoAuthRejectHandler(); return;}
                else if (result === 'Error' || result === '') {
                    this.successToast('Demo Auth API Failed.', '', 'error');  
                    this.noPopUPHandler();
                    return;
                }
                
            } catch (error) {
                this.successToast('Demo Auth API Failed.', '', 'error'); 
                this.noPopUPHandler();
                return;
            } finally {
                this.isSpinnerMoving = false;
            }
        }
        this.dispatchEvent(new CustomEvent('close', { detail: this.documentRecordId }));this.dispatchEvent(new CustomEvent('kycdonesuccess', { detail: this.type }));
    try {if(this.isStepFour){let result1 = await this.updateApplicantName(this.currentapplicationid);if(result1){this.dispatchEvent(new CustomEvent('updateapplicantname',{detail: result1}));}else{this.successToast('Error' , this.label.ExceptionMessage, 'error');}}} catch (error) {}this.confirmationModal = false;this.yesDisabled = false;}
    async demoAuthRejectHandler() {await updateLoanApplicationReject({loanApplicationId: this.currentoppid}).then(result => {}).catch(error => {console.log('error updating the loan application' + error);});this.dispatchEvent(new CustomEvent('refresh'));window.location.reload();}
    async noPopUPHandler(){ this.confirmationModal = false; await this.kycDeleteFields(); this.dispatchEvent(new CustomEvent('refresh'));}
    @api customerName;@track confirmationModal = false;@track yesDisabled = true;
    async updateApplicantName(currentapplicantid){let result = await updateApplicantName({applicantId:currentapplicantid});return result;}
    @api addressProofUploadScreenFlag;
    cancelYes() {this.dispatchEvent(new CustomEvent('close'));this.kycDeleteFields();this.showAlternateKYCPopup = false;this.closepopup();if (this.type == this.label.AadhaarCard) {deletePIDBlock({ applicantId: this.currentapplicationid }).then(result => { }).catch(error => { });} }
    goBackHandler() {this.dispatchEvent(new CustomEvent('close'));this.closepopup();}docAuthButtonButton = false;
    performDocAuth() {
        if (this.type != this.label.PanCards && (this.backdocumentToDelete == null || (!this.backUploadButton && !this.backUploadRedCross && !this.disableAadharBackButton))) {this.successToast('Complete back upload process.', '', 'error');return null;
        }else if ((this.frontdocumentToDelete == null && this.type == this.label.PanCards) || (!this.frontUploadButton && !this.frontUploadRedCross && !this.disableAadharFrontButton)) {this.successToast('Complete front upload process.', '', 'error');return null;
        }else{this.docAuthButtonButton = true;if (this.docAuthButtonButton == true) {this.disableDocAuthButton = true;this.disableAadharFrontButton = true;this.disableAadharBackButton = true;this.disableUploadButtonAll = true;this.asyncDocAuthCall();}}}
    asyncDocAuthCall() {
        this.isSpinnerMoving = true;
        doDocAuthReportAsyncCallout({ applicantId: this.currentapplicationid, documentId: this.documentRecordId, loanApplicationId: this.currentoppid })
            .then(result => {
                let response = JSON.parse(result);this.isSpinnerMoving = false;
                getDocAsyncResponse({ documentId: this.documentRecordId })
                    .then(result => {
                        this.isSpinnerMoving = false; this.isLoading = false;
                    }).catch(error => { this.isSpinnerMoving = false; this.isLoading = false; });
            }).catch(error => {this.isSpinnerMoving = false;});
        doSelfieReportAsyncCallout({ applicantId: this.currentapplicationid, documentId: this.documentRecordId, loanApplicationId: this.currentoppid })
            .then(result => {this.isSpinnerMoving = false;})
            .catch(error => {this.isSpinnerMoving = false;});}
    goldenSourceDisableButton = false;golenSourceRedCross = false;
    async handlegoldenSourcePass() {
        if (this.type != this.label.PanCards && (this.backdocumentToDelete == null || (!this.backUploadButton && !this.backUploadRedCross && !this.disableAadharBackButton))) {
            this.successToast('Complete back upload process.', '', 'error');return null;
        }else if ((this.frontdocumentToDelete == null && this.type == this.label.PanCards) || (!this.frontUploadButton && !this.frontUploadRedCross && !this.disableAadharFrontButton)) {
            this.successToast('Complete front upload process.', '', 'error');return null;
        }else{
            if (this.docAuthButtonButton || (this.frontUploadRedCross || this.backUploadRedCross) || this.disableDocAuthButton) {
                if (this.type == this.label.PanCards && this.istractor){
                    let notValid = helper.validatePanNumber(this);
                    let panNoElement = this.template.querySelector('lightning-input[data-id=panNoId]');
                    if(notValid){panNoElement.setCustomValidity('PAN number is not valid!');
                    this.successToast('Warning', 'PAN number is not valid!', 'warning'); return true;}else{
                        panNoElement.setCustomValidity('');
                    }
                }
                this.validationhandle();this.onChangeKYCNumber(true);if(this.allFieldsPopulated == false) { this.successToast('Check Fields again', '' , 'warning'); return null;}
                if (this.allFieldsPopulated == true) { goldenSource({ currentDocId: this.documentRecordId }).then(result => {result = JSON.parse(result);if (result.responseFlag===true) {this.isSpinnerMoving = true;if (this.type == this.label.PanCards) {this.panApiRequest(); } else if (this.type == this.label.DrivingLicences) {this.dlApiRequest();} else if (this.type == this.label.PassportCard) {this.passportApiRequest(); } else if (this.type == this.label.VoterIdCard) {this.voterIdApiRequest();}
                            } else if (result.responseFlag===false) {
                                if (this.type == this.label.PanCards && result?.responseObj?.AadhaarSeedingStatus__c != null) {this.doneDisable = true;this.disabledPanNo = true;}
                                if(this.type == this.label.PanCards && this.nsdlPanName != 'Y' && this.nsdlPanName != '' && result?.responseObj?.AadhaarSeedingStatus__c == 'Y'){this.doneDisable = false;this.handleGoldenSourceSuccess();}//CISP-21957
                                this.golenSourceRedCross = true; this.goldenSourceDisableButton = false;this.goldenSourceDisable = true;let msg;
                                if(this.errorMessageForPanVerification){msg = this.errorMessageForPanVerification + ' And Number of Attempts are Exhausted'}else{msg = 'Number of Attempts are Exhausted'}
                                this.successToast('Error', msg, 'error');  }   }).catch(error => {this.error = error;}); }
            }
            // else{this.successToast('Doc Auth required', '', 'error');} CISP-22905
          } }
    handleGoldenSourceSuccess() {
        this.disabledKYCName = true;this.disabledKYCAddress1 = true; this.disabledKYCAddress2 = true; this.disabledKYCPinCode = true; this.disabledKYCCity = true;this.disabledKYCState = true;this.disabledKYCDOB = true;this.disabledFirstName = true;  this.disabledLastName = true; this.disabledGender = true;this.disabledSalutation = true;this.disabledDLType = true;this.disabledKYCIssuanceceDate = true;this.disabledKYCExpiryDate = true;this.disabledAge = true;this.disabledPassportFileNo = true;this.disabledPassportNo = true; this.disabledKYCNo = true; this.disabledKYCName = true;this.disabledPanNo = true; this.goldenSourceDisable = true;
        goldenSourcePass({ documentId: this.documentRecordId });
        this.goldenSourceDisableButton = true;
        this.golenSourceRedCross = false;this.disableAadharFrontButton = true; this.disableAadharBackButton = true; this.disableDocAuthButton = true; }
    @api documentRecordId;isPhotocopy = false;
    handlerIsPhotocopy(event) {this.isPhotocopy = event.target.checked;}
    @track templateBackUploadPopUp = true;@track backUploadApp = true;@track captureApp = false;
    handleUpload() {
        this.modalPopUpUpload = true;
        if (FORM_FACTOR=='Large') {
                if (this.type==this.label.PanCards || this.type==this.label.Form60DocumentType || this.type == this.label.GST_CERT || this.type == this.label.CIN_CERT) {
                    this.templateBackUploadPopUp = false;
                    }
                    if (this.documentRecordId==null){
                        docCustomerImage({ docType: this.type, applicantId: this.currentapplicationid, loanApplicationId: this.currentoppid })
                    .then(result => {
                        this.documentRecordId = result;
                    }).catch(error => {});}
            this.modalPopUpCaptureImage = true;
        }else{
            this.templateFrontBackUpload = false;
            this.captureApp = true;if(this.type == this.label.GST_CERT || this.type == this.label.CIN_CERT){this.backUploadApp=false;this.templateBackUploadPopUp = false;}
            if (this.type == this.label.PanCards || this.type == this.label.Form60DocumentType) {
                this.backUploadApp = false;this.templateBackUploadPopUp = false;} else if (this.type===this.label.AadhaarCard && this.scanManualRadioOptions==='ScanAadhar' && this.selectedAadharOption !== 'Scan and Upload') {
                this.captureApp = false;this.templateUploadAadharApp = true; } }}
    documentSide;
    captureFrontApp() {
        this.documentSide='Front';this.imageType='Front';this.isimageApiPositiveResponse=false;
        this.captureCustomerImageApp();
        if(this.frontdocumentToDelete!=null){this.deleteImage(this.documentRecordId, false, true, this.frontdocumentToDelete);} }
    captureBackApp() {
        this.documentSide = 'Back';
        this.isBackImageApiPositiveResponse = false;
        this.captureCustomerImageApp();
        if(this.backdocumentToDelete!=null){
            this.deleteImage(this.documentRecordId, false, true, this.backdocumentToDelete);  }}
    captureCustomerImageApp() {
        this[NavigationMixin.Navigate]({
            type: "standard__webPage",
            attributes: {url: 'ibl://indusindbank.com/integratorInfo?' + this.label.currentApplicantid + '=' + this.currentapplicationid + '&' + this.label.currentUserId + '=' + this.currentUserId + '&' + this.label.mode + '=' + this.type + '&' + this.label.currentUserName + '=' + this.currentUserName + '&' + this.label.currentUserEmailid + '=' + this.currentUserEmailId + '&documentSide=' + this.documentSide
            }}); }
    doneflagCustomerImage = false;donefrontflagCustomerImage = false; donebackflagCustomerImage = false;imageType;disableBackFileUpload = false;
    isCancel = true;isDone = true;frontdocumentToDelete;backdocumentToDelete;doneDisable1=true;
    @track uploadedDoneOtherDevice=false; @track uploadedFailOtherDevice=false;
    uploadDoneConditions() {helper.uploadDoneConditions(this);}
    uploadDone() {
        if (!this.frontUploadExhaustedFlag && this.templateUploadMsg) {
            this.frontUploadRedCross=false; }
        if (!this.backUploadExhaustedFlag && this.templateBackUploadMsg) {
            this.backUploadRedCross=false; }
        if (FORM_FACTOR != 'Large') {
            this.isSpinnerMoving=true;
            if (this.type == this.label.AadhaarCard && this.scanManualRadioOptions==='ScanAadhar') {
                this.doneflagAadharImage=true;
                if (this.type===this.label.AadhaarCard && this.scanManualRadioOptions==='ScanAadhar') {
                    setAadharSource({ applicantId: this.currentapplicationid, docType: this.type }).then(result => {
                        if (result != null) {
                            this.documentRecordId = result;this.callCheckDocforDevice(); }
                    }).catch(error => { }); }
            }else{
                this.callCheckDocforDevice(); }}else{
            this.isSpinnerMoving = false;
            this.uploadDoneConditions();} }
    callCheckDocforDevice() {
        checkDocFromApp({ applicantId: this.currentapplicationid, docType: this.type }).then(result => {
            if (result != null) {
                this.isSpinnerMoving = false; this.documentRecordId = result; this.donefrontflagCustomerImage = true;
                if (this.type != this.label.PanCards && this.type != this.label.Form60DocumentType && this.scanManualRadioOptions != 'ScanAadhar') {
                    this.donebackflagCustomerImage = true;
                }
                if (this.type===this.label.AadhaarCard && this.scanManualRadioOptions==='ScanAadhar') {
                    this.getDocIdForDevice('false');}else{this.getDocIdForDevice('fromDone'); }
                this.uploadedDoneOtherDevice = true;
                this.uploadDoneConditions();}else{
                if (this.type == this.label.PanCards) {this.toastTitle = 'Upload PAN Card'} else if (this.type == this.label.Form60DocumentType) {this.toastTitle = 'Upload Form 60 Document'} else if (this.type == this.label.AadhaarCard && this.scanManualRadioOptions==='ScanAadhar') {this.toastTitle = 'Upload Aadhaar Document'}else{this.toastTitle='Upload both sides of ' + this.type }
                this.successToast(this.toastTitle, '', 'warning');this.uploadedFailOtherDevice=true;  this.isSpinnerMoving=false; }
        }).catch(error => {
            this.isSpinnerMoving=false;
            if(error.body.message){this.successToast(error.body.message, '', 'error');} else {this.successToast(error, 'Error', 'error');}  }); }
    @api customerimageid;isBackImageApiPositiveResponse=false;
    async handleimageUploadApi(){
        this.isSpinnerMoving=true;
        await doImageUploadCallout({ documentId: this.documentRecordId, imageType: this.imageType, loanAppId: this.currentoppid }).then(result => {
            let obj=JSON.parse(result);
            const status=obj.ResponseData.Fields.Applicants.Applicant.Services.Service[0].Status;
            if(status=='Pass'){
                if (this.type===this.label.PanCards && !this.isNonIndividualBorrower) {this.disableDocAuthButton=true;}
                this.isimageApiPositiveResponse=true;
                this.isSpinnerMoving=false;
                if (FORM_FACTOR!='Large') {
                    this.getDocIdForDevice(status);}else{
                    if (this.imageType=='Front') {this.frontuploadApi();this.successToast('Front image upload ' + status, 'Processing OCR', 'success');}else{this.isBackImageApiPositiveResponse = true;if(!this.isNonIndividualBorrower){this.disableDocAuthButton = true;}this.backuploadApi();this.successToast('Back image upload ' + status, 'Processing OCR', 'success'); }}
            }else if (status==='Fail') {
                this.disableDocAuthButton = true; this.isSpinnerMoving = false;
                if(this.imageType == 'Front') { this.failResponseFrontKyc();this.isimageApiPositiveResponse = false;
                }else{this.isBackImageApiPositiveResponse = false;this.failResponseBackKyc();} }
        }).catch(error => {
            this.disableDocAuthButton = true;  this.isSpinnerMoving = false; this.hanldeKindlyRetryMsg = true; this.error = error;
            if (this.imageType == 'Front') {this.isimageApiPositiveResponse = false; this.frontUploadButton = false;}else{ this.isBackImageApiPositiveResponse = false; this.backUploadButton = false; }  }); }
    updateFrontBackCheckbox(status, type){
        const docFields={};
        docFields[DOC_ID_FIELD.fieldApiName] = this.documentRecordId;
        if(type == 'Front'){
            docFields['is_Front_Upload_Completed__c'] = status; }else{
            docFields['is_Back_Upload_Completed__c'] = status;
        }
        this.updateRecordDetails(docFields);}
    getDocIdForDevice(status) {
        fetchCdocumentId({ documentId: this.documentRecordId })
            .then(result => {
                this.isSpinnerMoving = false;
                const obj = JSON.parse(result);
                if (status == 'fromDone') {
                    this.frontdocumentToDelete = obj.frontContentDocumentId;
                    if (this.scanManualRadioOptions != 'ScanAadhar' && this.type != this.label.PanCards && this.type != this.label.Form60DocumentType) {
                        this.backdocumentToDelete = obj.backContentDocumentId; } }
                else if (this.imageType == 'Front') {
                    if (this.type===this.label.PanCards && !this.isNonIndividualBorrower) {this.disableDocAuthButton = true; }
                    this.frontdocumentToDelete = obj.frontContentDocumentId;
                    if (obj.frontContentDocumentId != null && this.scanManualRadioOptions != 'ScanAadhar') {
                        this.frontuploadApi();
                        this.successToast('Front image upload ' + status, 'Processing OCR', 'success'); } }else{this.backdocumentToDelete = obj.backContentDocumentId;
                    this.isBackImageApiPositiveResponse = true;if(!this.isNonIndividualBorrower){this.disableDocAuthButton = true;}this.backuploadApi();
                    this.successToast('Back image upload ' + status, 'Processing OCR', 'success');}
            }).catch(error => {
                this.isSpinnerMoving = false;
                if (error.body.message) { this.successToast('Error', error.body.message, 'error'); } else { this.successToast('Please contact System Administrator','', 'error');}   });}
    panApiRequest() {
        this.firstName = this.template.querySelector('lightning-input[data-id=firstNameId]').value;
        this.lastName = this.template.querySelector('lightning-input[data-id=lastNameId]').value;
        let kycPanDetails = {
            'applicantId': this.currentapplicationid,
            'panNumber': this.kycPanNo,
            'firstName': this.firstName,
            'lastName': this.lastName,
            'loanApplicationId': this.currentoppid  };
        doPANCallout({
            'kycPanDetailRequest': JSON.stringify(kycPanDetails)
        }).then(result => {
            this.isSpinnerMoving = false;
            const obj = JSON.parse(result);
            if (obj.response.content[0].NSDLPANStatus == 'E') {
                /*var fullName = obj.response.content[0].Name.toUpperCase();
                let salutationsList = this.label.Salutations_List.split('@;');
                var salutValue = fullName.substring(0, fullName.indexOf(' '));
                const index = salutationsList.findIndex(salutation => salutation===salutValue);
                if (index !== -1) {
                    fullName = fullName.substring(fullName.indexOf(' ') + 1);  }
                var apiResFirstName = "";
                var apiResLastName = "";
                if (fullName.split(" ").length > 1) {
                    apiResLastName = fullName.substring(fullName.lastIndexOf(" ") + 1);
                    apiResFirstName = fullName.substring(0, fullName.lastIndexOf(' '));
                }else{
                    apiResFirstName = fullName; }
                this.kycName = fullName == '' ? this.kycName : fullName;
                this.firstName = apiResFirstName == '' ? this.firstName : apiResFirstName;
                this.lastName = apiResLastName == '' ? this.lastName : apiResLastName;*/
                this.nsdlPanName = obj.response.content[0].Name;
                this.NSDLPANStatus = obj.response.content[0].NSDLPANStatus;
                this.nsdlNameMatchPer = obj.response.content[0].IDNSDLNameMatch;
                this.nsdlResponse = obj.response.content[0].NSDLPANStatusDesc;if(!this.isNonIndividualBorrower || this.entitytype == 'Proprietorship'){this.aadhaarSeedingStatus = obj.response.content[0].NSDLAadhaarSeedingStatus;}
                if(obj.response.content[0].NSDLAadhaarSeedingStatus != 'Y' && (!this.isNonIndividualBorrower || this.entitytype == 'Proprietorship')){this.doneDisable = true;this.successToast('Error', 'PAN is not linked to Aadhaar. Please re-upload PAN once PAN is linked to Aadhaar or upload Form 60', 'error');this.errorMessageForPanVerification = 'PAN is not linked to Aadhaar. Please re-upload PAN once PAN is linked to Aadhaar or upload Form 60'; }else{
                    if(obj.response.content[0].Name != 'Y'){this.doneDisable = true;this.successToast('Error', 'The name entered does not match as per the name registered in NSDL. Please re-try.', 'error');}else{this.doneDisable = false;
                this.handleGoldenSourceSuccess();this.panAutoApproved = parseInt(obj.response.content[0].IDNSDLNameMatch) > parseInt(this.label.PanApprovedValue) ? true : false;
                this.successToast(obj.response.content[0].NSDLReturnCdDesc, obj.response.content[0].NSDLPANStatusDesc, 'success');}}
            } else if (obj.response.content[0].NSDLPANStatus == 'F' || 'X' || 'D' || 'N' || 'EA' || 'EC' || 'ED' || 'EI' || 'EL' || 'EM' || 'EP' || 'ES' || 'EU') {this.doneDisable = true; this.nsdlResponse = obj.response.content[0].NSDLPANStatusDesc;if(!this.isNonIndividualBorrower || this.entitytype == 'Proprietorship'){this.aadhaarSeedingStatus = obj.response.content[0].NSDLAadhaarSeedingStatus;}
                let errmsg = obj.response.content[0].NSDLPANStatusDesc != null ? obj.response.content[0].NSDLPANStatusDesc : 'Invalid';
                this.successToast('Error', errmsg + ' please upload a valid PAN in order to proceed', 'error');}
        }).catch(error => {
            this.isSpinnerMoving = false;
            this.hanldeKindlyRetryMsg = true; });}
    dlApiRequest() {helper.dlApiRequestHelper(this);}
    voterIdApiRequest() {helper.voterIdApiRequestHelper(this);}
    passportApiRequest() {helper.passportApiRequestHelper(this);}
    aadhaarNumber;handleRecaptureFrontPopup() {this.recaptureFrontKYCPopup = false;}
    aadharVerifyOtp(event) {
        const obj = JSON.parse(event.detail);
        if(obj.kycResponse.UidData.tkn){ this.aadhaarVaultNo = obj.kycResponse.UidData.tkn; }
        this.kycNo = obj.kycResponse.UidData.uid.replace(/\d(?=\d{4})/g, "*");this.aadhaarNumber = obj.kycResponse.UidData.uid;
        this.kycName = obj.kycResponse.UidData.name;
        var apiResFirstName = "";
        var apiResLastName = "";
        let fullName = obj.kycResponse.UidData.name;
        if (this.kycName.split(" ").length > 1) {
            apiResLastName = fullName.substring(fullName.lastIndexOf(" ") + 1);
            apiResFirstName = fullName.substring(0, fullName.lastIndexOf(' '));
        }else{apiResFirstName = this.kycName;}
        this.firstName = apiResFirstName;
        this.lastName = apiResLastName;
        this.kycDOB = obj.kycResponse.UidData.dob.split("-").reverse().join("-");
        let house = obj.kycResponse.UidData.house == 'null' ? '' : obj.kycResponse.UidData.house;
        let lm = obj.kycResponse.UidData.lm == 'null' ? '' : obj.kycResponse.UidData.lm;
        this.kycAddress1 = house + ' ' + lm;
        let street = obj.kycResponse.UidData.street == 'null' ? '' : obj.kycResponse.UidData.street;
        let loc = obj.kycResponse.UidData.loc == 'null' ? '' : obj.kycResponse.UidData.loc;
        let vtc = obj.kycResponse.UidData.vtc == 'null' ? '' : obj.kycResponse.UidData.vtc;
        this.kycAddress2 = street + ' ' + loc + ' ' + vtc;
        //CISP-7909 Populate address line 2 with address line 1 if address line 2 is blank for aadhaar
        if (this.type === this.label.AadhaarCard && (this.kycAddress2 === "" || this.kycAddress2 === null || this.kycAddress2 === undefined)) {this.kycAddress2 = this.kycAddress1;}
        this.currentAddressData.KYC_Pin_Code__c = obj.kycResponse.UidData.pc;
        this.currentAddressData.KYC_State__c =cityCheckMaster(this.stateCityMaster,obj.kycResponse.UidData.dist.toUpperCase(),obj.kycResponse.UidData.state.toUpperCase())? obj.kycResponse.UidData.state.toUpperCase(): null;
        this.currentAddressData.KYC_City__c =cityCheckMaster(this.stateCityMaster,obj.kycResponse.UidData.dist.toUpperCase(),obj.kycResponse.UidData.state.toUpperCase())? obj.kycResponse.UidData.dist.toUpperCase(): null;
        if (obj.kycResponse.UidData.gender==='F') {this.kycGender ='FEMALE';this.kycSalutation='Ms.';
        } else if (obj.kycResponse.UidData.gender==='M') {this.kycGender ='MALE';this.kycSalutation='Mr.';}
        else if (obj.kycResponse.UidData.gender==='TG') {this.kycGender ='TRANSGENDER';this.kycSalutation;}
        this.setSalutationVal();
        if(!this.currentAddressData.KYC_City__c && this.currentAddressData.KYC_Pin_Code__c){this.cityValue =City(this.stateCityMaster,this.currentAddressData.KYC_Pin_Code__c);this.isekyc=true;this.StateMasterDistrict(this.currentAddressData.KYC_State__c);}
        else{this.stateMaster(obj.kycResponse.UidData.state.toUpperCase(),this.currentAddressData.KYC_City__c);}
        this.closeModal();
        this.templateExPanFields = true;this.disableOCRButton = true;
  }
    deleteImage(documentRecordId, isDone, isCancel, contentDocumentData) {
        kycDelete({ documentId: documentRecordId, isDone: isDone, isCancel: isCancel, contentDocumentData: contentDocumentData }).then(result => {
            this.isCancel = true; this.isDone = true;
        }).catch(error => { this.isCancel = true; this.isDone = true; this.isLoading = false;this.error = error; }); }
    successToast(toastTitle, message, variant) {
        const evt = new ShowToastEvent({
            title: toastTitle,
            message: message,
            variant: variant, });
        this.dispatchEvent(evt); }
    failResponseFrontKyc() {
        this.donefrontflagCustomerImage = false;this.templateUploadMsg = false; this.deleteImage(this.documentRecordId, false, true, this.frontdocumentToDelete);  this.recaptureFrontKYCPopup = true; this.disableUploadButtonAll = false; this.frontUploadButton = false; this.frontdocumentToDelete = null;}
    failResponseBackKyc() {
        this.recaptureFrontKYCPopup = true;this.donebackflagCustomerImage = false;this.templateBackUploadMsg = false; this.backUploadButton = false;this.deleteImage(this.documentRecordId, false, true, this.backdocumentToDelete);this.backdocumentToDelete = null;}
    @track cityValue;currentAddressData = {};@track allStateData;
    validateKYCPinCode(){
        for(let index = 0; index < this.allStateData.length; index++) { if (this.allStateData[index].value == this.currentAddressData.KYC_State__c) { this.minCurrentState = this.allStateData[index].stateMinValue; this.maxCurrentState = this.allStateData[index].stateMaxValue;}  }
        let KycPinCodeDataIdInput = this.template.querySelector('lightning-input[data-id=KycPinCodeDataId]');
        if (this.currentAddressData.KYC_State__c) {KycPinCodeDataIdInput.disabled = false;this.validatePincode(); }else{KycPinCodeDataIdInput.disabled = true;}
        this.stateMaster(this.currentAddressData.KYC_State__c, null); 
    }
    handleBarrowerAddressState(event) {this.currentAddressData.KYC_State__c = event.target.value;this.validateKYCPinCode();}
    handleBarrowerAddressCity(event) {
    this.currentAddressData.KYC_City__c = event.target.value;
    if(this.isekyc===true){ this.template.querySelector('lightning-combobox[data-id=kycStateDataId]').value =stateCity(this.stateCityMaster,event.target.value,this.currentAddressData.KYC_Pin_Code__c);this.StateMasterDistrict(this.template.querySelector('lightning-combobox[data-id=kycStateDataId]').value)}
    else{this.validateKYCPinCode();}}
    @wire(getStateMasterData) wiredStateMaster({ error, data }) {
        if (data) {
            let finalArrayTopush = [];
            if (data.length > 0) {
                for(let index = 0; index < data.length; index++) {
                    let stateValue = {};stateValue.label = data[index].Name;stateValue.value = data[index].Name;stateValue.id = data[index].Id;stateValue.stateMinValue = data[index].Pincode__c;
    stateValue.stateMaxValue = data[index].Pincode_Starting_Max__c;
                    finalArrayTopush.push(stateValue);}  }
            this.allStateData = finalArrayTopush;
        } if (error) {
            this.errorData = JSON.stringify(error);
            this.isError = true; }  }
    handleBarrowerAddressPin(event) {this.currentAddressData.KYC_Pin_Code__c = event.target.value;this.validateKYCPinCode(); }
    handleaadharDistrictChange(event) {this.kycDistrict = event.target.value;}
    validatePincode() {
        if (this.currentAddressData.KYC_Pin_Code__c && this.currentAddressData.KYC_Pin_Code__c.length >= 2) {
            if (parseInt(this.currentAddressData.KYC_Pin_Code__c.substring(0, 2)) < this.minCurrentState || parseInt(this.currentAddressData.KYC_Pin_Code__c.substring(0, 2)) > this.maxCurrentState) {
                let KycPinCodeDataIdInput = this.template.querySelector('lightning-input[data-id=KycPinCodeDataId]');
                KycPinCodeDataIdInput.setCustomValidity("Invalid pin code");
                KycPinCodeDataIdInput.reportValidity();
            }else{
                let KycPinCodeDataIdInput = this.template.querySelector('lightning-input[data-id=KycPinCodeDataId]');
                KycPinCodeDataIdInput.setCustomValidity(""); }} }
    stateMaster(state, city) {
        getCityStateMaster({ stateName: state }).then(response => {
            let cityData = [];
            if (response && response.length > 0) {
                for(let index = 0; index < response.length; index++) {
                    let cityObject = {};cityObject.label = response[index].Name;cityObject.value = response[index].Name;cityObject.id = response[index].Id;cityData.push(cityObject);
                    if (index == (response.length - 1) && city != null) {
                        this.currentAddressData.KYC_City__c = city; }}}
            this.cityValue = cityData;
            this.isLoading = false;
        }).catch(error => {
            this.isLoading = false;});this.StateMasterDistrict(state);}
            StateMasterDistrict(state)
            {getDistrictsByState({ stateName:state }).then(response => {let cityData = [];
                    if (response && response.length > 0) { for (let index = 0; index < response.length; index++) {let cityObject = {};cityObject.label = response[index].Name;
                     cityObject.value = response[index].Name; cityObject.id = response[index].Id;cityData.push(cityObject); }}
                    this.DistictOption = cityData;this.isLoading = false;
                }).catch(error => {this.isLoading = false;})}
    onFrontfileupload(){
        if(this.frontdocumentToDelete!=null && this.frontFileUploaderDisable == false){
            this.deleteImage(this.documentRecordId, false, true, this.frontdocumentToDelete,false);this.templateUploadMsg = false; this.donefrontflagCustomerImage = false;this.templateFrontUpload = true; this.frontdocumentToDelete = null;
            this.disableAadharFrontButton = false;this.frontUploadButton = false; this.frontUploadRedCross = false; 
        } } 
    onBackfileupload(){
        if(this.backdocumentToDelete!=null && this.disableBackFileUpload == false){
            this.deleteImage(this.documentRecordId, false, true, this.backdocumentToDelete,false);this.templateBackUploadMsg=false; this.templateBackUpload = true;this.donebackflagCustomerImage = false; this.backdocumentToDelete = null}
            this.disableAadharBackButton = false;this.backUploadButton = false; this.backUploadRedCross = false;}  
    handleBacktUploadFinished(event) {
        this.backdocumentToDelete = event.detail.files[0].documentId;this.isCancel=false;this.isDone=false;this.donebackflagCustomerImage=true;this.templateBackUploadMsg=true;
        this.isBackImageApiPositiveResponse=false; }
    handleFrontUploadFinished(event) {
        this.frontdocumentToDelete = event.detail.files[0].documentId; this.isCancel = false; this.isDone = false; this.donefrontflagCustomerImage = true; this.templateUploadMsg = true;this.isimageApiPositiveResponse=false; }
    handleAadharUploadFinished(event) {
        this.frontdocumentToDelete=event.detail.files[0].documentId;this.isCancel=false; this.isDone=false; this.templateAadharUploadMsg=true;this.doneflagAadharImage=true;}
    poiTagging(){tagPOIforKycDoc({ applicantId: this.currentapplicationid }).then(result => {}).catch(error => {}); }
    handleChange(event){let label = event.target.label;
        switch( label ) {
            case 'KYC Address Line1': this.kycAddress1 = event.target.value; helper.handleBarrowerParmaAddress1(this); break;
            case 'KYC Address Line2': this.kycAddress2 = event.target.value; helper.handleBarrowerParmaAddress2(this); break;
            case 'GST State': this.kycState = event.target.value; helper.handleBarrowerParmaAddressState(this); break;
            case 'GST City': this.kycCity = event.target.value; helper.handleBarrowerParmaAddressCity(this); break;
            case 'GST KYC Pin Code': this.kycPinCode = event.target.value; helper.handleBarrowerParmaAddressPin(this); break;
            case 'GST District': this.kycDistrict = event.target.value; helper.handleBarrowerParmaAddressDistrict(this); break;
        } 
    }
}