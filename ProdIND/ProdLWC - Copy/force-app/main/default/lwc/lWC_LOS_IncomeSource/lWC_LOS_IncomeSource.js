import { LightningElement, wire, api, track } from 'lwc';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { loadStyle } from 'lightning/platformResourceLoader';
import LightningCardApplyCSS from '@salesforce/resourceUrl/loanApplication';
import fillAllRequiredFields from '@salesforce/label/c.Please_fill_all_the_mandatory_fields';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import createOtherDocument from '@salesforce/apex/LwcLOSLoanApplicationCntrl.createOtherDocument';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import saveIncomeDetails from '@salesforce/apex/Ind_IncomeDetailsCtrl.saveIncomeDetails';
import getAPIEligibility from '@salesforce/apex/Ind_IncomeDetailsCtrl.getAPIEligibility';
import updateAPICounterAndAccesibility from '@salesforce/apex/Ind_IncomeDetailsCtrl.updateAPICounterAndAccesibility';
import INCOME_DETAIL_OBJECT from '@salesforce/schema/Income_Details__c';
import PROFILE_FIELD from '@salesforce/schema/Income_Details__c.Profile__c';
import SMS_TO_BE_TRIGGER_FIELD from '@salesforce/schema/Income_Details__c.SMS_to_be_triggered_to__c';//CISP:2973
import RegEx_Number from '@salesforce/label/c.RegEx_Number';
  
import BSR_OCCUPATION_FIELD from '@salesforce/schema/Income_Details__c.BSR_Occupation__c';
import CURRENT_YEARS_FIELD from '@salesforce/schema/Income_Details__c.Current_Years_in_employment_business__c';
import TOTAL_YEARS_FIELD from '@salesforce/schema/Income_Details__c.Total_Years_in_employment_business__c';
import AREA_OF_REGISTRATION_FIELD from '@salesforce/schema/Income_Details__c.Area_Of_Registration__c';
import DOCUMENT_TYPES_FIELD from '@salesforce/schema/Income_Details__c.Document_Type__c';
import Online_via_link from '@salesforce/label/c.Online_via_link';
import Scan_using_device from '@salesforce/label/c.Scan_using_device';
import Upload_online_via_link from '@salesforce/label/c.Upload_online_via_link';
import salaried from '@salesforce/label/c.salaried';
import SelfEmployed from '@salesforce/label/c.SelfEmployed';
import Regex_NumberOnly from '@salesforce/label/c.Regex_NumberOnly';
import doGSTOnlineCallout from '@salesforce/apexContinuation/IntegrationEngine.doGSTOnlineCallout';
import doITROnlineCallout from '@salesforce/apexContinuation/IntegrationEngine.doITROnlineCallout';
import doMembershipCallout from '@salesforce/apexContinuation/IntegrationEngine.doMembershipCallout';
import doPerfiosGenerateLinkCallout from '@salesforce/apexContinuation/IntegrationEngine.doPerfiosGenerateLinkCallout';
import getAssessmentYear from '@salesforce/apex/Ind_IncomeDetailsCtrl.getAssessmentYear';
import getProfile from '@salesforce/apex/Ind_IncomeDetailsCtrl.getProfile';
import { updateRecord } from 'lightning/uiRecordApi';
import INCOME_DETAIL_ID_FIELD from '@salesforce/schema/Income_Details__c.Id';
import INCOME_ASSESMENT_DONE from '@salesforce/schema/Income_Details__c.Income_Assesment_Done__c';
import CTR_FIELD from '@salesforce/schema/Income_Details__c.Client_Transaction_Id__c';
import PERFIOS_ID_FIELD from '@salesforce/schema/Income_Details__c.Perfios_Transaction_Id__c';
import UploadedToPerfios_FIELD from '@salesforce/schema/Income_Details__c.Document_uploaded_to_Perfios__c';
import ReportInitiated_FIELD from '@salesforce/schema/Income_Details__c.Document_report_generation_initiated__c';
import doITRTransactionStatusAsyncCallout from '@salesforce/apex/IntegrationEngine.doITRTransactionStatusAsyncCallout';
import doGSTTransactionStatusAsyncCallout from '@salesforce/apex/IntegrationEngine.doGSTTransactionStatusAsyncCallout';
import doBSTransactionStatusAsyncCallout from '@salesforce/apex/IntegrationEngine.doBSTransactionStatusAsyncCallout';
import doScanUploadInitiate from '@salesforce/apex/IntegrationEngine.doScanUploadInitiate';
import doScanUploadReportGeneration from '@salesforce/apex/IntegrationEngine.doScanUploadReportGeneration';
import doITRScanUploadInitiate from '@salesforce/apex/IntegrationEngine.doITRScanUploadInitiate';
import doITRScanUploadCompleteTransaction from '@salesforce/apex/IntegrationEngine.doITRScanUploadCompleteTransaction';
import checkBankIncomeDetails from '@salesforce/apex/Ind_IncomeDetailsCtrl.checkBankIncomeDetails';
import Incomemessage from '@salesforce/label/c.Incomemessage';
import Income5000 from '@salesforce/label/c.Income5000';
import BankAccountNumberRegex from '@salesforce/label/c.BankAccountNumberRegex';
import Income5000000 from '@salesforce/label/c.Income5000000';
import incomeAmountMandatory from '@salesforce/label/c.incomeAmountMandatory';
import fetchDocument from '@salesforce/apex/Ind_IncomeDetailsCtrl.fetchDocument';
import getContentDocumentId from '@salesforce/apex/Ind_IncomeDetailsCtrl.getContentDocumentId';
import FORM_FACTOR from '@salesforce/client/formFactor';
import accessLoanApplication from '@salesforce/apex/LwcLOSLoanApplicationCntrl.accessLoanApplication';
import ReadOnlyLeadAccess from '@salesforce/label/c.ReadOnlyLeadAccess';
import PerfiosEmailTitle from '@salesforce/label/c.PerfiosEmailTitle';
import PerfiosEmail from '@salesforce/label/c.Perfios_Email';
import doEmailServiceCallout from '@salesforce/apexContinuation/IntegrationEngine.doEmailServiceCallout';
import checkAPISatus from '@salesforce/apex/Ind_IncomeDetailsCtrl.checkAPISatus';//CISP-3559
export default class LWC_LOS_IncomeSource extends LightningElement {
    label = {fillAllRequiredFields,incomeAmountMandatory,Regex_NumberOnly,Incomemessage,BankAccountNumberRegex,PerfiosEmailTitle,PerfiosEmail}
    @api checkleadaccess;//coming from tabloanApplication
    @api recordId
    @api currentStage;
    @api currentStageName;
    @api isDeleteDisable;
    @api isDeleteButton;
    @api get checkValidate(){ 
        if(!this.validityCheck('lightning-input') || !this.validityCheck('lightning-combobox')){this.showToast(this.label.fillAllRequiredFields,'', 'warning');return false;
        }else if((this.doFileITRChecked || this.isIncomeCreditedTobank || this.doFileGSTChecked || this.onlineLinkChecked || this.onlineUploadLinkChecked || this.scanDeviceChecked) && (!this.incomeAssessmentDone || !this.disableIncomeAnalysis) && !this.isTwoWheeler){
        if ((this.isIncomeCreditedTobank && !this.bankStatementSuccessTick && this.scanDeviceChecked) || (this.doFileITRChecked && !this.checkITRButton && this.scanDeviceChecked)) {this.showToast('', 'Capture document first.', 'warning');return false;
        }else if(!this.incomeAssessmentDone){this.showToast('', 'Complete Income Assesment first.', 'warning');return false;
        }else if(!this.disableIncomeAnalysis){this.showToast('', 'Complete Income Analysis first.', 'warning');return false;
        }else{return true;}
        }else if(this.showRegisterationOptions && (this.mciChecked || this.icaiChecked || this.icwaiChecked) && !this.isICWAIMDisable && !this.isICAIDisable && !this.isMCIDdisabled){this.showToast('', 'Complete registration process.', 'warning');return false;
        }else if(!this.isTwoWheeler){return true;
        }else{return this.checkValidit}
    }
    @api checkValidit = false;
    @api applicantId;
    @api currentOppRecordId;
    @api incomeDetail = {};
    @api isPan;
    @api isBank;
    @api isIblBank;
    @api isTwoWheeler;
    @api profileType;
    @api documentRecordId = null;
    @api contentDocumentId;
    @api leadNumber;
    @api emailId;
    @api firstName;
    @track profileValuesData;
    @track assessmentYearsValues = [];
    @track clientTransactionId;
    @track url;
    @track bankStatementSuccessTick = false;
    perfiosTransactionId = null;
    showIncomeOptions = false;
    showFileType = true;
    showURN = false;
    showIncomeCreditBankCheck = false;
    showLinkSection = false;
    showIncomeAssesment = false;
    showCaptureITR = false;
    showITR = false;
    showGST = false;
    showIncomeAnalysis = false;
    showCaptureBankStatement = false;
    showCheckRegiateration = false;
    isURNDisabled = false;
    isRegMCIDisabled = false;
    doFileITRChecked = false;
    doFileGSTChecked = false;
    tryCatchError = '';
    disableOnlineLink = false;
    disableUploadOnlineViaLink = false;
    disableScanDevice = false;
    isSalaried = false;
    isSelfEmployed = false;_uploadViewDocFlag =false;
    set uploadViewDocFlag(value){this._uploadViewDocFlag=value;}
    get uploadViewDocFlag(){return this._uploadViewDocFlag;}
    showRegisterationOptions = false;
    showURNField = false;
    documentrecordidfromparent;
    showUpload;
    showDocView;
    isAllDocType;
    isVehicleDoc;
    bsrOccupation;
    gstMethod;
    scanDeviceChecked;
    showPasswordStatement;
    onlineUploadLinkChecked;
    onlineLinkChecked;
    bank;
    value = '';
    disableResend = true;
    disableBS = false;
    isIncomeDetailDisable;
    isDoYouFileITRDisabled = false;
    isMCIDdisabled = false;
    isICAIDisable = false;
    isICWAIMDisable = false;
    isShowSaleriedNonSalired = false;
    showItrTemplate = false;
    showGstTemplate = false;
    showAreaOfReg = false;
    showYearOfReg = false;
    mciChecked = false;
    icaiChecked = false;
    icwaiChecked = false;
    isOnlineViaLink;
    employerName;
    currentYearsEmployment;
    SMSTobeTriggered;//CISP:2973
    isOnlineViaLinkChecked= false;
    ExecutiveMobileNo;
    isSMSTobeTriggered =false;
    isExeNose = false;
    isExecutive = false;
    totalYearsEmploymnet;
    isIncomeCreditedToBankAccount;
    isIncomeCreditedTobank = false;
    profile;
    Income_Source_Status__c;
    incomeIncSource;
    uniqueRegNumber;
    areaOfRegisteration;
    assesmentYear=null;
    documentType=null;
    fromMonth;
    toMonth;
    passwdForPdf;
    gstNumber;
    showScanAndDevice;
    isUploadOnlineViaLink;
    isScanDeviceChecked;
    incomeMethod;
    itrMethod;
    incomeSourceId = null;
    realdate;
    gstType;
    incomeSourceStatus;
    itrType;
    bankName;
    accountNum;
    isProfileSep = false;
    isLoading = false;
    profileId = null;
    fromDateDisabled = true;
    toDateDisabled = false;
    isCheckRegButtonDisable = false;
    isIncomeAssesmentButtonDisable = false;
    captureITRDisabled = false;
    checkRegButton = false;
    @track checkITRButton = false;
    isAreaOfRegDisabled = false;
    isYearOfRegDisabled = false;
    isBankSelected = false;
    isCustomLookupFieldDisabled = false;
    pageReloaded = false;
    transactionId;
    bankId = null;
    incomeAssessmentDone = false;
    disableIncomeAnalysis = true;
    uploadedDocument = null;
    showSave = false;
    disableSave = false;
    checkSaveButton = false;
    // D2C chagne - Raman R S
    lookupInputDisabled = false;
    leadSource;
    // EO D2C chagne
    checkAssessment = false;
    saveFlag = false;
    height = 32;//CISP-3144
    @api leadSource;//Ola integration changes

    @api productType = '';
    @track isTractor = false;

    @wire(getObjectInfo, { objectApiName: INCOME_DETAIL_OBJECT })
    incomeDetailMetaData;
    @wire(getPicklistValues,{ recordTypeId: '$incomeDetailMetaData.data.defaultRecordTypeId', fieldApiName: PROFILE_FIELD }
    )profileValues;
    @wire(getPicklistValues,
        { recordTypeId: '$incomeDetailMetaData.data.defaultRecordTypeId', fieldApiName: BSR_OCCUPATION_FIELD }
    )bsrValues;
    @wire(getPicklistValues,
        { recordTypeId: '$incomeDetailMetaData.data.defaultRecordTypeId', fieldApiName: CURRENT_YEARS_FIELD }
    )currentYearsValues;
    //CISP: 2973
    @wire(getPicklistValues,
        { recordTypeId: '$incomeDetailMetaData.data.defaultRecordTypeId', fieldApiName:SMS_TO_BE_TRIGGER_FIELD }
    )SMSNeedToTrigger;
    @wire(getPicklistValues,
        { recordTypeId: '$incomeDetailMetaData.data.defaultRecordTypeId', fieldApiName: TOTAL_YEARS_FIELD }
    )totalYearsValues;
    @wire(getPicklistValues,
        { recordTypeId: '$incomeDetailMetaData.data.defaultRecordTypeId', fieldApiName: AREA_OF_REGISTRATION_FIELD }
    )areaOfRegValues;
    @wire(getObjectInfo, { objectApiName: INCOME_DETAIL_OBJECT })documentMetaData;
    @wire(getPicklistValues,
        { recordTypeId: '$documentMetaData.data.defaultRecordTypeId', fieldApiName: DOCUMENT_TYPES_FIELD })
    documentTypesValues;
    @wire(getAssessmentYear)
    getAssessmentYear({ error, data }) {
        if (data) {
            this.l_All_Types = data;
            let options = [];
            for (var key in data) { options.push({ label: data[key], value: data[key] }); }
            this.assessmentYearsValues = options;
        } else if (error) {}
    }
    renderedCallback() {
        // CISP-2752-START
        if(this.isSelfEmployed){ let isSalariedSelected = this.template.querySelector('[data-id="salaried"]'); if(isSalariedSelected){ isSalariedSelected.disabled = true; } }
        if(this.isSalaried){ let isSelfEmployedSelected = this.template.querySelector('[data-id="selfEmployed"]'); if(isSelfEmployedSelected){ isSelfEmployedSelected.disabled = true; } }
        // CISP-2752-END
        if (this.currentStageName === 'Credit Processing' || this.currentStageName != 'Income Details' || this.currentStage != 'Income Details') { this.disableEverything(); }loadStyle(this, LightningCardApplyCSS);
        //Ola Integration changes
        if(this.leadSource=='OLA' || this.leadSource=='Hero'){
            this.template.querySelector('[data-id="salaried"]').disabled = true;
            this.template.querySelector('[data-id="selfEmployed"]').disabled = true;
            let profileTemp = this.template.querySelector('[data-id="profile"]')
            if(profileTemp!=null)
                profileTemp.disabled = true;
                this.bsrOccupation = '95012';//OLA=55 
                this.isIncomeCreditedTobank = true;//OLA-56

        }
    }
    connectedCallback() {
        if(this.productType == 'Tractor'){this.isTractor = true;}
       if (this.incomeDetail.isFromDatabase) {
             this.incomeSourceId = this.incomeDetail.Id;
            this.isDeleteDisable = true;
            this.incomeIncSource = this.incomeDetail.Income__c != 0 ? this.incomeDetail.Income__c : 0;
            if (this.incomeDetail.Name_of_Recipient_Banks__r != null) {
                this.bankName = this.incomeDetail.Name_of_Recipient_Banks__r.Name;
            }
            this.isSalaried = this.incomeDetail.Is_Salaried__c == true ? this.incomeDetail.Is_Salaried__c : false;
            this.isSelfEmployed = this.incomeDetail.Is_Self_Employed__c != null ? this.incomeDetail.Is_Self_Employed__c : false;
            if(this.isTwoWheeler){
                if(this.isSalaried){
                    this.isShowSaleriedNonSalired= true;
                    this.showURN= false;
                    this.showURNField= false;
                    this.showAreaOfReg= false;
                    this.showYearOfReg=false;
                    this.showIncomeCreditBankCheck=false;
                    this.showCheckRegiateration=false;
                    this.showItrTemplate=false;
                    this.showGstTemplate=false;
                    this.showIncomeOptions=false;
                    this.showScanAndDevice=false;
                    this.showITR=false;
                    this.showDocType=false;
                    this.showLinkSection=false;
                    this.showPasswordStatement=false;
                    this.showGST=false;
                    this.showCaptureITR=false;
                    this.showCaptureBankStatement=false;
                    this.showIncomeAssesment=false;
                    this.showSave=true;
                    if(this.incomeDetail.Income_Assesment_Done__c){ this.disableSave = true; }
                    this.showResend=false;
                    this.showIncomeAnalysis=false;
                } else if(this.isSelfEmployed){ this.isShowSaleriedNonSalired= true;this.showIncomeCreditBankCheck = false;this.showIncomeOptions = true;} }
            if(this.incomeDetail.Income_Assesment_Done__c){this.incomeAssessmentDone=true;this.checkAssessment=true;}//CISP-3065
            this.mciChecked = this.incomeDetail.Is_MCI__c;
            this.icaiChecked = this.incomeDetail.Is_ICAI__c;
            this.icwaiChecked = this.incomeDetail.Is_ICWAI__c;
            this.showScanAndDevice = true;
            if (this.bankName) {this.isBankSelected = true;this.isCustomLookupFieldDisabled = true;}
            if (this.incomeDetail.Profile__r != null) {
                this.profile = this.incomeDetail.Profile__r.Name;
                let profileArray = [];
                profileArray.push({ label: this.profile, value: this.profile });
                this.profileValuesData = profileArray;
                if (this.isSelfEmployed) {this.pageReloaded = true;this.processProfileDropdown('SEP/SENP');}
                let profileValue = this.getProfileId(this.profile).profileCategory;
                this.profileId = this.getProfileId(this.profile).profileId;
            }let ex = { 'target': { 'checked': false } }
            if (this.isSelfEmployed) {
                this.processProfileDropdown('SEP/SENP');
                if (this.profile == 'ENGINEER' || this.profile == 'DOCTOR' || this.profile == 'ADVOCATE' || this.profile == 'TAX CONSULTANT') { this.showURN = true; this.showRegisterationOptions = true;
                } else { this.showCheckRegiateration = false; this.mciChecked = false;this.icaiChecked = false;this.icwaiChecked = false;}
                if (this.mciChecked) {this.showURNField = true;this.showAreaOfReg = true;ex.target.checked = true;this.handleMCI(ex);
                } else if (this.icaiChecked) {this.showAreaOfReg = false;this.showYearOfReg = true;this.showURNField = true;ex.target.checked = true;this.handleICAI(ex);
                } else if (this.icwaiChecked) {this.showYearOfReg = true;ex.target.checked = true;this.handleICWAI(ex);}
                this.uniqueRegNumber = this.incomeDetail.Unique_Registration_Number__c;
                if (this.uniqueRegNumber) {this.regAnyFollowing = true;ex.target.checked = true;this.handleRegistered(ex);this.showIncomeCreditBankCheck = false;
                }this.areaOfRegisteration = this.incomeDetail.Area_Of_Registration__c;
            } else if (this.isSalaried && !this.isTwoWheeler) {
                this.showIncomeCreditBankCheck = true;
                this.isIncomeCreditedTobank = this.incomeDetail.Is_Income_Credited_In_Bank_Account__c;
                if (this.isIncomeCreditedTobank == null || this.isIncomeCreditedTobank == true ) {this.isIncomeCreditedTobank = true;this.showItrTemplate = false;this.doFileITRChecked = false;this.showIncomeOptions = true;
                }
                this.processProfileDropdown('SAL');}
            this.accountNum = this.incomeDetail.Bank_Account_Number__c;
            this.yearOfRegisteration = this.incomeDetail.Year_of_Registeration__c;
            this.employerName = this.incomeDetail.Employer_Business_Name__c != null ? this.incomeDetail.Employer_Business_Name__c : '';
            this.SMSTobeTriggered = this.incomeDetail.SMS_to_be_triggered_to__c	 !=null?this.incomeDetail.SMS_to_be_triggered_to__c	:'';//CISP:2973
           
            this.currentYearsEmployment = this.incomeDetail.Current_Years_in_employment_business__c;
            this.totalYearsEmploymnet = this.incomeDetail.Total_Years_in_employment_business__c;
            this.bsrOccupation = '95012';
            this.bsrOccupation = this.incomeDetail.BSR_Occupation__c != null ? this.incomeDetail.BSR_Occupation__c : '';
            this.fromMonth = this.incomeDetail.From_Month__c != null ? this.incomeDetail.From_Month__c : '';
            this.toMonth = this.incomeDetail.To_Month__c != null ? this.incomeDetail.To_Month__c : '';
            if (this.toMonth) { this.toDateDisabled = true; }
            this.passwdForPdf = this.incomeDetail.Password_for_pdf_protected_statement__c != null ? this.incomeDetail.Password_for_pdf_protected_statement__c : '';
            this.assesmentYear = this.incomeDetail.Assessment_Year__c != null ? this.incomeDetail.Assessment_Year__c : '';
            this.documentType = this.incomeDetail.Document_Type__c != null ? this.incomeDetail.Document_Type__c : '';
            this.gstNumber = this.incomeDetail.GST_No__c != null ? this.incomeDetail.GST_No__c : '';
            this.doFileITRChecked = this.incomeDetail.Do_You_File_ITR__c != null ? this.incomeDetail.Do_You_File_ITR__c : false;
            if (this.doFileITRChecked) { this.showItrTemplate = true; } else{this.showItrTemplate = true;this.doFileITRChecked = false;this.showGstTemplate = true;}
            this.doFileGSTChecked = this.incomeDetail.Do_You_File_GST__c != null ? this.incomeDetail.Do_You_File_GST__c : false;
            if (this.doFileGSTChecked) {this.showGstTemplate = true;this.showScanAndDevice = false;this.showItrTemplate = true;this.doFileITRChecked = false;}
            this.gstMethod = this.incomeDetail.Capture_GST_Method__c != null ? this.incomeDetail.Capture_GST_Method__c : false;
            if (this.incomeDetail.Income_Assesment_Done__c) {
                this.isURNDisabled = true;this.isYearOfRegDisabled = true;this.isAreaOfRegDisabled = true;this.isIncomeDetailDisable = true;this.isBankSelected = true;  
                this.isSMSTobeTriggered=true;//CISP:2978
                if(this.incomeDetail.Executive_Mobile_No__c!=null) //CISP:2978
                {
                this.ExecutiveMobileNo =this.incomeDetail.Executive_Mobile_No__c; //CISP:2973
                console.log('Iam in connected call back  and ex no value is ', this.ExecutiveMobileNo)
                 this.isExecutive= true;
                 this.isExeNose =true;
                }
                // if(this.incomeDetail.Capture_Income_Method__c==='Scan using device' && this.incomeDetail.Perfios_Transaction_Id__c === undefined){this.isIncomeAssesmentButtonDisable=false;
                // }else{this.isIncomeAssesmentButtonDisable=true;this.checkAssessment=true;
                // }
                // if(this.incomeDetail.Document_report_generation_initiated__c){this.disableIncomeAnalysis= true;}
                this.isDoYouFileITRDisabled = true;
                this.captureITRDisabled = true;
                this.isCheckRegButtonDisable = true;
                this.isMCIDdisabled = true;
                this.isICAIDisable = true;
                this.isICWAIMDisable = true;
                this.checkValidit = true;
                if (this.isIncomeCreditedTobank && !this.isTwoWheeler) {
                    this.showIncomeCreditBankCheck = true;
                }
                this.checkRegButton = true;this.isURNDisabled = true;
            }
            if (this.incomeDetail.Is_Salaried__c || this.incomeDetail.Is_Self_Employed__c) {
                this.isShowSaleriedNonSalired = true;
            }
            if (this.doFileGSTChecked && this.gstMethod && this.gstMethod == 'Online via link' && this.isTwoWheeler===false) {
                this.showIncomeOptions = true;
                this.onlineLinkChecked = true;
                this.showLinkSection = true;
                this.showGST = true;
                if(this.isTwoWheeler){
                    this.showIncomeAssesment = false;
                    this.showSave = true ;
                    this.showResend = false;
                } else if(!this.isTwoWheeler){
                    this.showSave = false ;
                    this.showIncomeAssesment = true;
                    this.showResend = true;
                }
            } else if (this.doFileGSTChecked && this.gstMethod && this.gstMethod === 'Upload online via link' && this.isTwoWheeler===false) {
                this.showIncomeOptions = true;
                this.onlineUploadLinkChecked = true;
                this.showLinkSection = true;
                if(this.isTwoWheeler){
                    this.showIncomeAssesment = false;
                    this.showSave = true ;
                    this.showResend = false;
                } else if(!this.isTwoWheeler){
                    this.showSave = false ;
                    this.showIncomeAssesment = true;
                    this.showResend = true;
                }
                this.showGST = true;
            } else if (this.doFileGSTChecked && this.gstMethod && this.gstMethod === 'Scan using device' && this.isTwoWheeler===false) {
                this.showLinkSection = true;
                if (this.isSelfEmployed) {
                    this.scanDeviceChecked = false;
                    this.showScanAndDevice = false;
                } else {
                    this.scanDeviceChecked = true;
                    this.showScanAndDevice = true;
                }
            }
            this.incomeMethod = this.incomeDetail.Capture_Income_Method__c != null ? this.incomeDetail.Capture_Income_Method__c : '';
            if (this.isIncomeCreditedTobank && this.incomeMethod == 'Online via link' && this.isTwoWheeler===false) {
                this.showIncomeOptions = true;
                this.onlineLinkChecked = true;
                this.showLinkSection = true;
                    if(this.isTwoWheeler){
                        this.showIncomeAssesment = false;
                        this.showSave = true ;
                        this.showResend = false;
                    } else if(!this.isTwoWheeler){
                        this.showSave = false ;
                    this.showIncomeAssesment = true;
                    this.showResend = true;
                }
            } else if (this.isIncomeCreditedTobank && this.incomeMethod === 'Upload online via link' && this.isTwoWheeler===false) {
                this.onlineUploadLinkChecked = true;
                this.showIncomeOptions = true;
                this.showLinkSection = true;
                if(this.isTwoWheeler){
                    this.showIncomeAssesment = false;
                    this.showSave = true ;
                    this.showResend = false;
                } else if(!this.isTwoWheeler){
                    this.showSave = false ;
                    this.showIncomeAssesment = true;
                    this.showResend = true;
                }
                this.showPasswordStatement = true;
            } else if (this.isIncomeCreditedTobank && this.incomeMethod === 'Scan using device' && this.isTwoWheeler===false) {
                this.scanDeviceChecked = true;
                this.showIncomeOptions = true;
                this.showLinkSection = true;
                this.showCaptureBankStatement = true;
                if(this.isTwoWheeler){
                    this.showIncomeAssesment = false;
                    this.showSave = true ;
                    this.showResend = false;
                } else if(!this.isTwoWheeler){
                    this.showSave = false ;
                    this.showIncomeAssesment = true;
                    this.showResend = true;
                    this.showIncomeAnalysis = true;
                }this.documentType = 'Customer Bank Statement';
                this.checkDocPresent('Customer Bank Statement', true,false);
            }
            this.itrMethod = this.incomeDetail.Capture_ITR_Method__c != null ? this.incomeDetail.Capture_ITR_Method__c : '';
            if (this.doFileITRChecked && this.itrMethod && this.itrMethod === 'Online via link' && this.isTwoWheeler===false) {
                this.showIncomeOptions = true;
                this.onlineLinkChecked = true;
                this.showITR = true;
                if(this.isTwoWheeler){
                    this.showIncomeAssesment = false;
                    this.showSave = true ;
                    this.showResend = false;
                } else if(!this.isTwoWheeler){
                    this.showSave = false ;
                    this.showIncomeAssesment = true;
                    this.showResend = true;
                }
            } else if (this.doFileITRChecked && this.itrMethod && this.itrMethod === 'Upload online via link' && this.isTwoWheeler===false) {
                this.onlineUploadLinkChecked = true;
                this.showIncomeOptions = true;
                this.showITR = true;
                this.showDocType = true;
                if(this.isTwoWheeler){
                    this.showIncomeAssesment = false;
                    this.showSave = true ;
                    this.showResend = false;
                } else if(!this.isTwoWheeler){
                    this.showSave = false ;
                    this.showIncomeAssesment = true;
                    this.showResend = true;
                }
            } else if (this.doFileITRChecked && this.itrMethod && this.itrMethod === 'Scan using device' && this.isTwoWheeler===false) {
                this.scanDeviceChecked = true;
                this.showIncomeOptions = true;
                this.showITR = true;
                this.showDocType = true;
                this.showCaptureITR = true;
                if(this.isTwoWheeler){
                    this.showIncomeAssesment = false;
                    this.showSave = true ;
                    this.showResend = false;
                } else if(!this.isTwoWheeler){
                    this.showSave = false ;
                    this.showIncomeAssesment = true;
                    this.showResend = true;
                    this.showIncomeAnalysis = true;
                }this.documentType = 'Customer Bank Statement';
                this.checkDocPresent(this.documentType, true,false);
            }
            this.incomeSourceStatus=this.incomeDetail.Income_Source_Status__c;
            if (this.incomeSourceStatus != null && this.incomeDetail.Income_Assesment_Done__c) {
                this.disableAll();this.disableEverything();
                this.isCheckRegButtonDisable = true;this.checkRegButton = true;this.isURNDisabled = true;this.isAreaOfRegDisabled = true;this.isYearOfRegDisabled = true;this.isMCIDdisabled=true;this.isICAIDisable=true;this.isICWAIMDisable=true;
            }
        } else {this.incomedetail = this.incomeDetail;}
        if (!this.isPan) {this.isDoYouFileITRDisabled = true;}
        this.callAccessLoanApplication();
    }
//M4
callAccessLoanApplication(){
    accessLoanApplication({ loanId: this.currentOppRecordId , stage: 'Income Details'}).then(response => {
        if(!response){ 
            this.disableEverything();
            if(this.checkleadaccess){
                const evt = new ShowToastEvent({
                    title: ReadOnlyLeadAccess,
                    variant: 'warning',
                    mode: 'sticky'
                });
                this.dispatchEvent(evt);
                this.disableEverything();
            }
        }
      }).catch(error => { });
}//M4
    handleSalaried(event) {
        let isSalariedSelected = this.template.querySelector('[data-id="salaried"]');
        isSalariedSelected.checked = event.target.checked;
        let isSelfEmployedSelected = this.template.querySelector('[data-id="selfEmployed"]');
        isSelfEmployedSelected.checked = false;this.profile = '';this.profileId = '';
        // CISP-2752-START
        if(isSalariedSelected?.checked){isSelfEmployedSelected.disabled = true;isSelfEmployedSelected?.reportValidity();isSalariedSelected?.reportValidity();
        }else{isSelfEmployedSelected.disabled = false}
        // CISP-2752-END
        if (isSalariedSelected.checked) {
            this.isSalaried = true;
            this.isSelfEmployed = false;
            this.isShowSaleriedNonSalired = true;
            if(this.isTwoWheeler){this.showIncomeCreditBankCheck = false;this.showIncomeOptions = false;this.showScanAndDevice = false;this.showSave = true;
            }else if(!this.isTwoWheeler){this.showIncomeCreditBankCheck = true;this.showIncomeOptions = true;this.showScanAndDevice = true;this.showCaptureBankStatement = false;this.showSave = false;
            }
            this.isIncomeCreditedTobank = true;this.showItrTemplate = false;this.showGstTemplate = false;this.doFileGSTChecked = false;this.gstNumber = '';this.showGST = false;this.passwdForPdf = '';this.showPasswordStatement = false;this.toMonth = '';this.fromMonth = '';this.showLinkSection = false;this.documentType = '';this.showDocType = false;this.assesmentYear = '';this.showITR = false;this.scanDeviceChecked = false;this.onlineUploadLinkChecked = false;this.onlineLinkChecked = false;this.areaOfRegisteration = '';this.uniqueRegNumber = '';this.regAnyFollowing = false;this.showRegisterationOptions = false;this.showURN = false;this.showCheckRegiateration = false;this.showIncomeAssesment = false;this.showCaptureITR = false;this.showIncomeAnalysis = false;this.isProfileSep = false;this.doFileITRChecked = false;
            
            if(this.isTractor){
                this.processProfileDropdown('SENP');
            }else {
                this.processProfileDropdown('SAL');
            }
            
            this.showResend=false;
        } else if (!isSalariedSelected.checked) {this.employerName='';this.currentYearsEmployment='';this.totalYearsEmploymnet='';this.profile='';this.bsrOccupation='';
            this.isShowSaleriedNonSalired = false;
            this.isSalaried = false;
            this.isSelfEmployed = false;
            if(!this.isTwoWheeler){this.showScanAndDevice = false;this.isIncomeCreditedTobank = false;this.showIncomeCreditBankCheck = false;this.doFileITRChecked = false;this.doFileGSTChecked = false;this.showItrTemplate = false;this.showGstTemplate = false;
                // let isUploadOnline = this.template.querySelector('[data-id="uploadOnlineLink"]');
                // isUploadOnline.checked = false;
                // let isScanDevice = this.template.querySelector('[data-id="scanDevice"]');
                // isScanDevice.checked = false;
                // let isOnlineLink = this.template.querySelector('[data-id="onlineLink"]');
                // isOnlineLink.checked = false;
                this.showIncomeOptions = false;this.gstNumber = '';this.showGST = false;this.passwdForPdf = '';this.showPasswordStatement = false;this.toMonth = '';this.fromMonth = '';this.showLinkSection = false;this.documentType = '';this.showDocType = false;this.assesmentYear = '';this.showITR = false;this.scanDeviceChecked = false;this.onlineUploadLinkChecked = false;this.onlineLinkChecked = false;this.areaOfRegisteration = '';this.uniqueRegNumber = '';this.regAnyFollowing = false;this.showRegisterationOptions = false;this.showURN = false;this.showCheckRegiateration = false;this.showIncomeAssesment = false;this.showSave = false;this.showCaptureBankStatement = false;this.showIncomeAnalysis = false;
            }
            this.isProfileSep = false;this.processProfileDropdown('SAL');this.showResend=false;
        }
    }
    handleSelfEmployed(event) {
        let isSelfEmployedSelected = this.template.querySelector('[data-id="selfEmployed"]');
        isSelfEmployedSelected.checked = event.target.checked;
        let isSalariedSelected = this.template.querySelector('[data-id="salaried"]');
        isSalariedSelected.checked = false;this.profile = '';this.profileId = '';
        //CISP-2752-START
        if(isSelfEmployedSelected?.checked){isSalariedSelected.disabled = true;isSelfEmployedSelected?.reportValidity();isSalariedSelected?.reportValidity();
        }else{isSalariedSelected.disabled = false;}
        // CISP-2752-END
        if (isSelfEmployedSelected.checked) {
            if(this.isTwoWheeler){this.profile = '';this.bsrOccupation='';this.showItrTemplate = false;this.showGstTemplate = false;this.showIncomeOptions = false;this.showScanAndDevice = false;this.showSave = true;this.showAreaOfReg=false;this.showYearOfReg = false;
            }else if(!this.isTwoWheeler){
                if (!this.isPan) {
                    this.showItrTemplate = true;
                    this.isDoYouFileITRDisabled = true;
                    this.doFileITRChecked = false;
                    this.showGstTemplate = true;
                    this.doFileGSTChecked = true;
                    this.showScanAndDevice = false;
                } else if (this.isPan) {
                    this.doFileITRChecked = true;
                    this.doFileGSTChecked = false;
                    this.showItrTemplate = true;
                    this.showGstTemplate = false;
                    this.showScanAndDevice = true;
                }
                this.showIncomeOptions = true;
                this.showSave = false;
                this.showCaptureBankStatement = false;
            }
            this.isSalaried = false;this.isSelfEmployed = true;this.isShowSaleriedNonSalired = true;this.isIncomeCreditedTobank = false;this.showIncomeCreditBankCheck = false;this.gstNumber = '';this.showGST = false;this.passwdForPdf = '';this.showPasswordStatement = false;this.toMonth = '';this.fromMonth = '';this.showLinkSection = false;this.documentType = '';this.showDocType = false;this.assesmentYear = '';this.showITR = false;this.scanDeviceChecked = false;this.onlineUploadLinkChecked = false;this.onlineLinkChecked = false;this.areaOfRegisteration = '';this.uniqueRegNumber = '';this.showURNField = false;this.showCheckRegiateration = false;this.showIncomeAssesment = false;this.showIncomeAnalysis = false;this.showCaptureITR = false;this.isProfileSep = false;this.processProfileDropdown('SEP/SENP');this.showResend=false;
        } else if (!isSelfEmployedSelected.checked) {this.employerName='';this.currentYearsEmployment='';this.totalYearsEmploymnet='';this.profile='';this.bsrOccupation='';
            this.isProfileSep = false;
            this.isShowSaleriedNonSalired = false;
            this.isSalaried = false;
            this.isSelfEmployed = false;
            this.showURN = false;
            this.showCheckRegiateration = false;
            this.mciChecked = false;
            this.icaiChecked = false;
            this.icwaiChecked = false;
            if(!this.isTwoWheeler){this.showScanAndDevice = false;this.isIncomeCreditedTobank = false;this.showIncomeCreditBankCheck = false;this.doFileITRChecked = false;this.doFileGSTChecked = false;this.showItrTemplate = false;this.showGstTemplate = false;
                // let isUploadOnline = this.template.querySelector('[data-id="uploadOnlineLink"]');
                // isUploadOnline.checked = false;
                // let isScanDevice = this.template.querySelector('[data-id="scanDevice"]');
                // isScanDevice.checked = false;
                // let isOnlineLink = this.template.querySelector('[data-id="onlineLink"]');
                // isOnlineLink.checked = false;
                this.showIncomeOptions = false;this.gstNumber = '';this.showGST = false;this.passwdForPdf = '';this.showPasswordStatement = false;this.toMonth = '';this.fromMonth = '';this.showLinkSection = false;this.documentType = '';this.showDocType = false;this.assesmentYear = '';this.showITR = false;this.scanDeviceChecked = false;this.onlineUploadLinkChecked = false;this.onlineLinkChecked = false;this.areaOfRegisteration = '';this.uniqueRegNumber = '';this.regAnyFollowing = false;this.showRegisterationOptions = false;this.showURN = false;this.showCheckRegiateration = false;this.showIncomeAssesment = false;this.showSave = false;this.showCaptureBankStatement = false;this.showIncomeAnalysis = false;
            }this.profileValuesData = [];this.showResend=false;
        }
    }
    handleIncomeCreditedToBankAccount(event) {
        this.isIncomeCreditedTobank = event.target.checked;
        if (this.isIncomeCreditedTobank) {this.isIncomeCreditedTobank = true;this.showIncomeCreditBankCheck = true;this.doFileITRChecked = false;this.doFileGSTChecked = false;this.showItrTemplate = false;this.showGstTemplate = false;this.showCaptureITR = false;this.showIncomeOptions = true;this.gstNumber = '';this.showGST = false;this.passwdForPdf = '';this.showPasswordStatement = false;this.toMonth = '';this.fromMonth = '';this.showLinkSection = false;this.documentType = '';this.showDocType = false;this.assesmentYear = '';this.showITR = false;this.scanDeviceChecked = false;this.onlineUploadLinkChecked = false;this.onlineLinkChecked = false;this.areaOfRegisteration = '';this.uniqueRegNumber = '';this.regAnyFollowing = false;this.showRegisterationOptions = false;this.showURN = false;this.showCheckRegiateration = false;this.showIncomeAssesment = false;this.showSave = false;this.showCaptureBankStatement = false;this.showIncomeAnalysis = false;this.showResend=false;
        } else if (!this.isIncomeCreditedTobank) {//CISP:3179
            this.isOnlineViaLinkChecked=false; this.isExecutive=false;this.SMSTobeTriggered='Customer';this.ExecutiveMobileNo='';
            if (!this.isPan) {this.doFileITRChecked = false;this.isDoYouFileITRDisabled = true;this.showIncomeOptions = false;this.incomeSourceStatus = 'NIP';this.dispatchEvent(new CustomEvent('incomesourcestatus', { detail: this.incomeSourceStatus }));
            } else if (this.isPan) {this.doFileITRChecked = true;this.isDoYouFileITRDisabled = false;this.showIncomeOptions = true;
            }this.isIncomeCreditedTobank = false;this.showIncomeCreditBankCheck = true;this.doFileGSTChecked = false;this.showItrTemplate = true;this.showGstTemplate = false;
            // let isUploadOnline = this.template.querySelector('[data-id="uploadOnlineLink"]');
            // isUploadOnline.checked = false;
            // let isScanDevice = this.template.querySelector('[data-id="scanDevice"]');
            // isScanDevice.checked = false;
            // let isOnlineLink = this.template.querySelector('[data-id="onlineLink"]');
            // isOnlineLink.checked = false;
            this.gstNumber = '';this.showGST = false;this.passwdForPdf = '';this.showPasswordStatement = false;this.toMonth = '';this.fromMonth = '';this.showLinkSection = false;this.documentType = '';this.showDocType = false;this.assesmentYear = '';this.showITR = false;this.scanDeviceChecked = false;this.onlineUploadLinkChecked = false;this.onlineLinkChecked = false;this.areaOfRegisteration = '';this.uniqueRegNumber = '';this.regAnyFollowing = false;this.showRegisterationOptions = false;this.showURN = false;this.showCheckRegiateration = false;this.showIncomeAssesment = false;this.showSave = false;this.showCaptureBankStatement = false;this.showIncomeAnalysis = false;this.showCaptureITR = false;this.showResend=false;
        }
    }
    handleRegistered(event) {
        this.regAnyFollowing = event.target.checked;
        if (this.regAnyFollowing) {
            this.regAnyFollowing = true;
            if (this.mciChecked) {this.showURNField = true;this.showAreaOfReg = true;this.showYearOfReg = true;this.isURNDisabled = false;this.isAreaOfRegDisabled = false;this.isYearOfRegDisabled = false;this.showCheckRegiateration = true;this.isCheckRegButtonDisable = false;
            } else if (this.icaiChecked) {this.showURNField = true;this.showAreaOfReg = false;this.showYearOfReg = true;this.isURNDisabled = false;this.isAreaOfRegDisabled = false;this.isYearOfRegDisabled = false;this.showCheckRegiateration = true;this.isCheckRegButtonDisable = false;
            } else if (this.isICWAIMDisable) {this.showURNField = true;this.showAreaOfReg = false;this.showYearOfReg = true;this.isURNDisabled = false;this.isAreaOfRegDisabled = false;this.isYearOfRegDisabled = false;this.showCheckRegiateration = true;this.isCheckRegButtonDisable = false;
            }
        } else if (!this.regAnyFollowing) {this.regAnyFollowing = false;this.isURNDisabled = true;this.isAreaOfRegDisabled = true;this.isYearOfRegDisabled = true;this.isCheckRegButtonDisable = true;
        }
    }
    handleOnlineViaLink(event) {
        this.isOnlineViaLink = event.target.checked;
        if(this.isOnlineViaLink ===true)
        {
            this.isOnlineViaLinkChecked =true; //CISP:3179
        }
        else{ this.isOnlineViaLinkChecked =false; this.isExecutive=false;this.SMSTobeTriggered='Customer';this.ExecutiveMobileNo='';}

        if (this.isIncomeCreditedTobank && this.isOnlineViaLink) {this.showITR = false;this.showDocType = false;this.onlineLinkChecked = true;this.scanDeviceChecked = false;let isUploadOnline = this.template.querySelector('[data-id="uploadOnlineLink"]');isUploadOnline.checked = false;let isScanDevice = this.template.querySelector('[data-id="scanDevice"]');isScanDevice.checked = false;this.onlineUploadLinkChecked = false;this.showLinkSection = true;this.toDateDisabled = true;
            var today = new Date();
            today.setMonth(today.getMonth() - 1);
            let toMnth = today.getFullYear() + '-' + (today.getMonth() + 1);
            let fromDate;
            let toDate;
            if ((today.getMonth() + 1) < 10) {toDate = today.getFullYear() + '-' + '0' + (today.getMonth() + 1);
            }else {toDate = today.getFullYear() + '-' + (today.getMonth() + 1);}
            today.setMonth(today.getMonth() - 7);
            if ((today.getMonth() + 1) < 10) {fromDate = today.getFullYear() + '-' + '0' + (today.getMonth() + 1);
            }else {fromDate = today.getFullYear() + '-' + (today.getMonth() + 1);}
            this.fromMonth = fromDate;
            this.toMonth = toDate;
            this.passwdForPdf = '';
            this.showPasswordStatement = false;
            this.showCaptureBankStatement = false;
            this.showCaptureITR = false;
            if(this.isTwoWheeler){this.showIncomeAssesment = false;this.showSave = true ;this.showResend = false;
            } else if(!this.isTwoWheeler){this.showSave = false ;this.showIncomeAssesment = true;this.showResend = true;
            }this.showIncomeAnalysis = false;this.assesmentYear = '';this.showITR = false;this.documentType = '';this.showDocType = false;this.gstNumber = '';this.showGST = false;
        }
        if (this.isIncomeCreditedTobank && !this.isOnlineViaLink) {this.onlineLinkChecked = true;this.scanDeviceChecked = false;let isUploadOnline = this.template.querySelector('[data-id="uploadOnlineLink"]');isUploadOnline.checked = false;let isScanDevice = this.template.querySelector('[data-id="scanDevice"]');isScanDevice.checked = false;this.onlineUploadLinkChecked = false;this.toMonth = '';this.fromMonth = '';this.showLinkSection = false;this.passwdForPdf = '';this.showPasswordStatement = false;this.showCaptureBankStatement = false;this.showIncomeAssesment = false;this.showSave = false;this.showResend = false;this.showIncomeAnalysis = false;this.showCaptureITR = false;this.assesmentYear = '';this.showITR = false;this.documentType = '';this.showDocType = false;this.gstNumber = '';this.showGST = false;
        }
        if (this.doFileITRChecked && this.isOnlineViaLink) {
            this.onlineLinkChecked = true;
            this.scanDeviceChecked = false;
            let isUploadOnline = this.template.querySelector('[data-id="uploadOnlineLink"]');
            isUploadOnline.checked = false;
            this.showScanAndDevice = true
            if (this.doFileITRChecked) {let isScanDevice = this.template.querySelector('[data-id="scanDevice"]');isScanDevice.checked = false;}
            this.onlineUploadLinkChecked = false;
            this.toMonth = '';
            this.fromMonth = '';
            this.showLinkSection = false;
            this.passwdForPdf = '';
            this.showPasswordStatement = false;
            this.showCaptureBankStatement = false;
            this.showIncomeAnalysis = false;
            this.showCaptureITR = false;
            this.assesmentYear = '';
            this.showITR = true;
            if(this.isTwoWheeler){this.showIncomeAssesment = false;this.showSave = true ;this.showResend = false;
            } else if(!this.isTwoWheeler){this.showSave = false ;this.showIncomeAssesment = true;this.showResend = true;}
            this.documentType = '';
            this.showDocType = false;
            this.gstNumber = '';
            this.showGST = false;
        }
        if (this.doFileITRChecked && !this.isOnlineViaLink) {this.onlineLinkChecked = true;this.scanDeviceChecked = false;let isUploadOnline = this.template.querySelector('[data-id="uploadOnlineLink"]');isUploadOnline.checked = false;let isScanDevice = this.template.querySelector('[data-id="scanDevice"]');isScanDevice.checked = false;this.onlineUploadLinkChecked = false;this.toMonth = '';this.fromMonth = '';this.showLinkSection = false;this.passwdForPdf = '';this.showPasswordStatement = false;this.showCaptureBankStatement = false;this.showIncomeAnalysis = false;this.assesmentYear = '';this.showITR = false;this.showIncomeAssesment = false;this.showSave = false;this.showResend = false;this.showCaptureITR = false;this.documentType = '';this.showDocType = false;this.gstNumber = '';this.showGST = false;
        }
        if (this.doFileGSTChecked && this.isOnlineViaLink) {
            this.onlineLinkChecked = true;
            this.scanDeviceChecked = false;
            let isUploadOnline = this.template.querySelector('[data-id="uploadOnlineLink"]');
            isUploadOnline.checked = false;
            if (this.isSalaried) {let isScanDevice = this.template.querySelector('[data-id="scanDevice"]');isScanDevice.checked = false;}
            this.onlineUploadLinkChecked = false;
            this.toMonth = '';
            this.fromMonth = '';
            this.showLinkSection = true;
            this.toDateDisabled = true;
            var today = new Date();
            today.setMonth(today.getMonth() - 1);
            let toMnth = today.getFullYear() + '-' + (today.getMonth() + 1);
            let fromDate;
            let toDate;
            if ((today.getMonth() + 1) < 10) { toDate = today.getFullYear() + '-' + '0' + (today.getMonth() + 1); }
            else { toDate = today.getFullYear() + '-' + (today.getMonth() + 1); }
            today.setMonth(today.getMonth() - 14);
            if ((today.getMonth() + 1) < 10) { fromDate = today.getFullYear() + '-' + '0' + (today.getMonth() + 1); }
            else { fromDate = today.getFullYear() + '-' + (today.getMonth() + 1); }
            this.fromMonth = fromDate;
            this.toMonth = toDate;
            this.passwdForPdf = '';
            this.showPasswordStatement = false;
            this.showCaptureBankStatement = false;
            this.showIncomeAnalysis = false;
            this.assesmentYear = '';
            this.showITR = false;
            if(this.isTwoWheeler){this.showIncomeAssesment = false;this.showSave = true ;this.showResend = false;
            } else if(!this.isTwoWheeler){this.showSave = false ;this.showIncomeAssesment = true;this.showResend = true;}this.documentType = '';this.showDocType = false;this.gstNumber = '';this.showGST = true;
        }
        if (this.doFileGSTChecked && !this.isOnlineViaLink) {
            this.onlineLinkChecked = true;this.scanDeviceChecked = false;
            let isUploadOnline = this.template.querySelector('[data-id="uploadOnlineLink"]');
            isUploadOnline.checked = false;
            if (this.isSalaried) {let isScanDevice = this.template.querySelector('[data-id="scanDevice"]');isScanDevice.checked = false;}
            this.onlineUploadLinkChecked = false;this.toMonth = '';this.fromMonth = '';this.showLinkSection = false;this.passwdForPdf = '';this.showPasswordStatement = false;this.showCaptureBankStatement = false;this.showIncomeAnalysis = false;this.assesmentYear = '';this.showITR = false;this.showIncomeAssesment = false;this.showSave = false;this.showResend = false;this.documentType = '';this.showDocType = false;this.gstNumber = '';this.showGST = false;this.showCaptureITR = false;
        }
    }
    handleUploadOnlineViaLink(event) {
        this.isUploadOnlineViaLink = event.detail.checked;
        if(this.isUploadOnlineViaLink===true)
        {
            this.isOnlineViaLinkChecked=true; //CISP: 3179
        } else{ this.isOnlineViaLinkChecked =false; this.isExecutive=false;this.SMSTobeTriggered='Customer';this.ExecutiveMobileNo=''; }
        if (this.isIncomeCreditedTobank && this.isUploadOnlineViaLink) {
            let isUploadOnline = this.template.querySelector('[data-id="onlineLink"]');isUploadOnline.checked = false;
            let isScanDevice = this.template.querySelector('[data-id="scanDevice"]');isScanDevice.checked = false;
            this.onlineLinkChecked = false;this.onlineUploadLinkChecked = true;this.scanDeviceChecked = false;this.toMonth = '';this.fromMonth = '';this.showLinkSection = true;this.toDateDisabled = false;this.passwdForPdf = '';this.showPasswordStatement = true;this.showCaptureBankStatement = false;
            if(this.isTwoWheeler){this.showIncomeAssesment = false;this.showSave = true ;this.showResend = false;
            } else if(!this.isTwoWheeler){this.showSave = false ;this.showIncomeAssesment = true;this.showResend = true;}
            this.showIncomeAnalysis = false;this.showCaptureITR = false;this.assesmentYear = '';this.showITR = false;this.documentType = '';this.showDocType = false;this.gstNumber = '';this.showGST = false;
        }
        if (this.isIncomeCreditedTobank && !this.isUploadOnlineViaLink) {
            let isUploadOnline = this.template.querySelector('[data-id="onlineLink"]');isUploadOnline.checked = false;
            let isScanDevice = this.template.querySelector('[data-id="scanDevice"]');isScanDevice.checked = false;
            this.onlineLinkChecked = false;this.scanDeviceChecked = false;this.onlineUploadLinkChecked = false;this.toMonth = '';this.fromMonth = '';this.showLinkSection = false;this.passwdForPdf = '';this.showPasswordStatement = false;this.showCaptureBankStatement = false;this.showIncomeAssesment = false;this.showSave = false;this.showResend = false;this.showIncomeAnalysis = false;this.showCaptureITR = false;this.assesmentYear = '';this.showITR = false;this.documentType = '';this.showDocType = false;this.gstNumber = '';this.showGST = false;
        }
        if (this.doFileITRChecked && this.isUploadOnlineViaLink) {
            let isUploadOnline = this.template.querySelector('[data-id="onlineLink"]');isUploadOnline.checked = false;
            let isScanDevice = this.template.querySelector('[data-id="scanDevice"]');isScanDevice.checked = false;
            this.onlineLinkChecked = false;this.scanDeviceChecked = false;this.onlineUploadLinkChecked = true;this.toMonth = '';this.fromMonth = '';this.showLinkSection = false;this.passwdForPdf = '';this.showPasswordStatement = false;this.showCaptureBankStatement = false;this.showIncomeAnalysis = false;this.showCaptureITR = false;this.assesmentYear = '';this.showITR = true;
            if(this.isTwoWheeler){this.showIncomeAssesment = false;this.showSave = true ;this.showResend = false;
            } else if(!this.isTwoWheeler){this.showSave = false ;this.showIncomeAssesment = true;this.showResend = true;}
            this.showDocType = true;this.gstNumber = '';this.showGST = false;
        }
        if (this.doFileITRChecked && !this.isUploadOnlineViaLink) {
            let isUploadOnline = this.template.querySelector('[data-id="onlineLink"]');isUploadOnline.checked = false;
            let isScanDevice = this.template.querySelector('[data-id="scanDevice"]');isScanDevice.checked = false;
            this.onlineLinkChecked = false;this.scanDeviceChecked = false;this.onlineUploadLinkChecked = false;this.toMonth = '';this.fromMonth = '';this.showLinkSection = false;this.passwdForPdf = '';this.showPasswordStatement = false;this.showCaptureBankStatement = false;this.showIncomeAnalysis = false;this.showCaptureITR = false;this.assesmentYear = '';this.showITR = false;this.showIncomeAssesment = false;this.showSave = false;this.showResend = false;this.documentType = '';this.showDocType = false;this.gstNumber = '';this.showGST = false;
        }
        if (this.doFileGSTChecked && this.isUploadOnlineViaLink) {
            let isUploadOnline = this.template.querySelector('[data-id="onlineLink"]');isUploadOnline.checked = false;
            if (this.isSalaried) {let isScanDevice = this.template.querySelector('[data-id="scanDevice"]');isScanDevice.checked = false;}
            this.onlineLinkChecked = false;this.scanDeviceChecked = false;this.onlineUploadLinkChecked = true;this.showLinkSection = true;this.toDateDisabled = true;
            var today = new Date();
            today.setMonth(today.getMonth() - 1);
            let toMnth = today.getFullYear() + '-' + (today.getMonth() + 1);
            let fromDate;
            let toDate;
            if ((today.getMonth() + 1) < 10) { toDate = today.getFullYear() + '-' + '0' + (today.getMonth() + 1); }
            else { toDate = today.getFullYear() + '-' + (today.getMonth() + 1); }
            today.setMonth(today.getMonth() - 14);
            if ((today.getMonth() + 1) < 10) { fromDate = today.getFullYear() + '-' + '0' + (today.getMonth() + 1); }
            else { fromDate = today.getFullYear() + '-' + (today.getMonth() + 1); }
            this.fromMonth = fromDate;
            this.toMonth = toDate;
            this.passwdForPdf = '';
            this.showPasswordStatement = false;
            this.showCaptureBankStatement = false;
            this.showIncomeAnalysis = false;
            this.assesmentYear = '';
            this.showITR = false;
            if(this.isTwoWheeler){this.showIncomeAssesment = false;this.showSave = true ;this.showResend = false;
            } else if(!this.isTwoWheeler){this.showSave = false ;this.showIncomeAssesment = true;this.showResend = true;
            }this.documentType = '';this.showDocType = false;this.gstNumber = '';this.showGST = true;
        }
        if (this.doFileGSTChecked && !this.isUploadOnlineViaLink) {
            let isUploadOnline = this.template.querySelector('[data-id="onlineLink"]');
            isUploadOnline.checked = false;
            if (this.isSalaried) {let isScanDevice = this.template.querySelector('[data-id="scanDevice"]');isScanDevice.checked = false;}
            this.onlineLinkChecked = false;this.scanDeviceChecked = false;this.onlineUploadLinkChecked = false;this.toMonth = '';this.fromMonth = '';this.showLinkSection = false;this.passwdForPdf = '';this.showPasswordStatement = false;this.showCaptureBankStatement = false;this.showIncomeAnalysis = false;this.assesmentYear = '';this.showITR = false;this.showIncomeAssesment = false;this.showSave = false;this.showResend = false;this.documentType = '';this.showDocType = false;this.gstNumber = '';this.showGST = false;this.showCaptureITR = false;
        }
    }
    handleScanDevice(event) {
        this.isScanDeviceChecked = event.target.checked;
        if(this.isScanDeviceChecked===true)
        {
            this.isOnlineViaLinkChecked=false; //CISP: 3179
            this.isExecutive=false;//CISP: 3179
            this.ExecutiveMobileNo='';
        }
        let isScanDeviceSelected = this.template.querySelector('[data-id="scanDevice"]');
        if (this.isIncomeCreditedTobank && this.isScanDeviceChecked && isScanDeviceSelected.checked) {
            let isOnline = this.template.querySelector('[data-id="onlineLink"]');isOnline.checked = false;
            let isUploadOnline = this.template.querySelector('[data-id="uploadOnlineLink"]');
            isUploadOnline.checked = false;this.onlineLinkChecked = false;this.onlineUploadLinkChecked = false;this.scanDeviceChecked = true;this.toMonth = '';this.fromMonth = '';this.showLinkSection = true;this.toDateDisabled = false;this.toMonth = false;this.showCaptureITR = false;this.showCaptureBankStatement = true;
            if(this.isTwoWheeler){this.showIncomeAssesment = false;this.showSave = true ;this.showResend = false;this.showIncomeAnalysis = false;} else if(!this.isTwoWheeler){this.showSave = false ;this.showIncomeAssesment = true;this.showResend = true;this.showIncomeAnalysis = true;}
            this.assesmentYear = '';this.showITR = false;this.documentType = '';this.showDocType = false;this.gstNumber = '';this.showGST = false;
        }
        if (this.isIncomeCreditedTobank && !this.isScanDeviceChecked) {
            let isOnline = this.template.querySelector('[data-id="onlineLink"]');isOnline.checked = false;
            let isUploadOnline = this.template.querySelector('[data-id="uploadOnlineLink"]');isUploadOnline.checked = false;
            this.onlineLinkChecked = false;this.onlineUploadLinkChecked = false;this.scanDeviceChecked = false;this.toMonth = '';this.fromMonth = '';this.showLinkSection = false;this.passwdForPdf = '';this.showPasswordStatement = false;this.showCaptureBankStatement = false;this.showIncomeAssesment = false;this.showSave = false;this.showResend = false;this.showIncomeAnalysis = false;this.showCaptureITR = false;this.assesmentYear = '';this.showITR = false;this.documentType = '';this.showDocType = false;this.gstNumber = '';this.showGST = false;
        }
        if (this.doFileITRChecked && this.isScanDeviceChecked) {
            let isOnline = this.template.querySelector('[data-id="onlineLink"]');isOnline.checked = false;
            let isUploadOnline = this.template.querySelector('[data-id="uploadOnlineLink"]');isUploadOnline.checked = false;
            this.onlineLinkChecked = false;this.scanDeviceChecked = true;this.onlineUploadLinkChecked = false;this.toMonth = '';this.fromMonth = '';this.showLinkSection = false;this.showCaptureBankStatement = false;this.assesmentYear = '';this.showITR = true;
            if(this.isTwoWheeler){this.showIncomeAssesment = false;this.showSave = true ;this.showResend = false;this.showIncomeAnalysis = false;} else if(!this.isTwoWheeler){this.showSave = false ;this.showIncomeAssesment = true;this.showResend = true;this.showIncomeAnalysis = true;}this.showCaptureITR = true;this.showDocType = true;this.gstNumber = '';this.showGST = false;
        }
        if (this.doFileITRChecked && !this.isScanDeviceChecked) {
            let isOnline = this.template.querySelector('[data-id="onlineLink"]');isOnline.checked = false;
            let isUploadOnline = this.template.querySelector('[data-id="uploadOnlineLink"]');isUploadOnline.checked = false;
            this.onlineLinkChecked = false;this.scanDeviceChecked = false;this.onlineUploadLinkChecked = false;this.toMonth = '';this.fromMonth = '';this.showLinkSection = false;this.passwdForPdf = '';this.showPasswordStatement = false;this.showCaptureBankStatement = false;this.showCaptureITR = false;this.showIncomeAnalysis = false;this.assesmentYear = '';this.showITR = false;this.showIncomeAssesment = false;this.showSave = false;this.showResend = false;this.documentType = '';this.showDocType = false;this.gstNumber = '';this.showGST = false;
        }
        if (this.regAnyFollowing && this.isScanDeviceChecked) {this.showCaptureITR = true;}
    }
    handleDoFileITR(event) {
        let isFileITRSelected = this.template.querySelector('[data-id="fileITR"]');
        isFileITRSelected.checked = event.target.checked;this.disableResend=true;this.isIncomeAssesmentButtonDisable=false;
        if (isFileITRSelected.checked) {
            this.isIncomeCreditedTobank = false;
            if (this.isSalaried) {this.showIncomeCreditBankCheck = true;
            } else { this.showIncomeCreditBankCheck = false; }
            this.doFileITRChecked = true;this.doFileGSTChecked = false;this.showItrTemplate = true;this.showGstTemplate = false;this.showIncomeOptions = true;this.gstNumber = '';this.showGST = false;this.passwdForPdf = '';this.showPasswordStatement = false;this.toMonth = '';this.fromMonth = '';this.showLinkSection = false;this.showDocType = false;this.assesmentYear = '';this.showITR = false;this.scanDeviceChecked = false;this.onlineUploadLinkChecked = false;this.onlineLinkChecked = false;
            if (this.isSalaried) {this.regAnyFollowing = false;this.showURN = false;
            } else {this.regAnyFollowing = true;this.showURN = true;this.showScanAndDevice = true;}
            this.showIncomeAssesment = false;this.showSave = false;this.showCaptureBankStatement = false;this.showIncomeAnalysis = false;this.showCaptureITR = false;this.showResend=false;
        } else if (!isFileITRSelected.checked) {
            this.isOnlineViaLinkChecked=false;//CISP:3179
            this.isExecutive= false;//CISP:3179
            this.SMSTobeTriggered='Customer';
            this.ExecutiveMobileNo='';
            this.isIncomeCreditedTobank = false;
            if (this.isSalaried) {this.showIncomeCreditBankCheck = true;this.incomeSourceStatus = 'NIP';this.dispatchEvent(new CustomEvent('incomesourcestatus', { detail: this.incomeSourceStatus }));
            } else { this.showIncomeCreditBankCheck = false; }
            this.doFileITRChecked = false;this.showItrTemplate = true;
            if (this.isSalaried) {
                this.doFileGSTChecked = false;this.showGstTemplate = false;let isUploadOnline = this.template.querySelector('[data-id="uploadOnlineLink"]');isUploadOnline.checked = false;let isScanDevice = this.template.querySelector('[data-id="scanDevice"]');isScanDevice.checked = false;let isOnlineLink = this.template.querySelector('[data-id="onlineLink"]');isOnlineLink.checked = false;this.showIncomeOptions = false;
            } else {
                this.showCaptureITR = false;this.doFileGSTChecked = true;this.showGstTemplate = true;this.showScanAndDevice = false;let isUploadOnline = this.template.querySelector('[data-id="uploadOnlineLink"]');isUploadOnline.checked = false;let isScanDevice = this.template.querySelector('[data-id="scanDevice"]');isScanDevice.checked = false;let isOnlineLink = this.template.querySelector('[data-id="onlineLink"]');isOnlineLink.checked = false;this.showIncomeOptions = true;
            }
            this.gstNumber = '';this.showGST = false;this.passwdForPdf = '';this.showPasswordStatement = false;this.toMonth = '';this.fromMonth = '';this.showLinkSection = false;this.documentType = '';this.showDocType = false;this.assesmentYear = '';this.showITR = false;this.scanDeviceChecked = false;this.onlineUploadLinkChecked = false;this.onlineLinkChecked = false;
            if (this.isSalaried) {this.regAnyFollowing = false;this.showURN = false;
            } else {this.regAnyFollowing = true;this.showURN = true;}
            this.showIncomeAssesment = false;this.showSave = false;this.showCaptureBankStatement = false;this.showIncomeAnalysis = false;this.showResend=false;
        }
    }
    handleDoFileGST(event) {
        let isFileGSTSelected = this.template.querySelector('[data-id="fileGST"]');
        isFileGSTSelected.checked = event.target.checked;

        if (isFileGSTSelected.checked) {this.isIncomeCreditedTobank = false;this.doFileITRChecked = false;this.doFileGSTChecked = true;this.showItrTemplate = true;this.showGstTemplate = true;this.showIncomeOptions = true;this.gstNumber = '';this.showGST = false;this.passwdForPdf = '';this.showPasswordStatement = false;this.toMonth = '';this.fromMonth = '';this.showLinkSection = false;this.showDocType = false;this.assesmentYear = '';this.showITR = false;this.scanDeviceChecked = false;this.onlineUploadLinkChecked = false;this.onlineLinkChecked = false;this.showIncomeAssesment = false;this.showSave = false;this.showCaptureBankStatement = false;this.showIncomeAnalysis = false;this.showCaptureITR = false;this.showPasswordStatement = false;this.showResend=false;
        } else if (!isFileGSTSelected.checked) {
            this.isOnlineViaLinkChecked=false;//CISP:3179
            this.isExecutive= false;//CISP:3179
            this.SMSTobeTriggered='Customer';
            this.ExecutiveMobileNo='';
        this.isIncomeCreditedTobank = false;this.doFileITRChecked = false;this.showItrTemplate = true;this.gstNumber = '';this.showGST = false;this.passwdForPdf = '';this.showPasswordStatement = false;this.toMonth = '';this.fromMonth = '';this.showLinkSection = false;this.documentType = '';this.showDocType = false;this.assesmentYear = '';this.showITR = false;this.scanDeviceChecked = false;this.onlineUploadLinkChecked = false;this.onlineLinkChecked = false;this.showIncomeAssesment = false;this.showSave = false;this.showCaptureBankStatement = false;this.showIncomeAnalysis = false;this.doFileGSTChecked= false;this.showResend=false;this.incomeSourceStatus = 'NIP';this.dispatchEvent(new CustomEvent('incomesourcestatus', { detail: this.incomeSourceStatus }));this.showGstTemplate = true;let isUploadOnline = this.template.querySelector('[data-id="uploadOnlineLink"]');isUploadOnline.checked = false;let isOnlineLink = this.template.querySelector('[data-id="onlineLink"]');isOnlineLink.checked = false;this.showIncomeOptions = false;}}
    handleMCI(event) {
        this.mciChecked = event.target.checked;
        this.membershipType = 'mci';
        this.uniqueRegNumber='';this.areaOfRegisteration='';this.yearOfRegisteration='';
        this.regAnyFollowing = true;
        if (this.regAnyFollowing && this.mciChecked) {this.regAnyFollowing = true;this.showAreaOfReg = true;this.showYearOfReg = true;this.showURNField = true;this.icwaiChecked = false;this.icaiChecked = false;this.showCheckRegiateration = true;this.isURNDisabled = false;this.isAreaOfRegDisabled = false;this.isYearOfRegDisabled = false;this.isCheckRegButtonDisable = false;
        } else if (this.regAnyFollowing && !this.mciChecked) {this.showAreaOfReg = false;this.showYearOfReg = false;this.showURNField = false;this.mciChecked = false;this.icwaiChecked = false;this.icaiChecked = false;this.showCheckRegiateration = false;}
    }
    handleICAI(event) {
        this.icaiChecked = event.target.checked;
        this.membershipType = 'icai';
        this.uniqueRegNumber='';this.areaOfRegisteration='';this.yearOfRegisteration='';
        if (this.icaiChecked) {this.regAnyFollowing = true;this.showAreaOfReg = false;this.showYearOfReg = false;this.showURNField = true;this.mciChecked = false;this.icwaiChecked = false;this.showCheckRegiateration = true;this.isURNDisabled = false;this.isAreaOfRegDisabled = false;this.isYearOfRegDisabled = false;this.isCheckRegButtonDisable = false;
        } else if (!this.icaiChecked) {this.showAreaOfReg = false;this.showYearOfReg = false;this.showURNField = false;this.mciChecked = false;this.icwaiChecked = false;this.icaiChecked = false;this.showCheckRegiateration = false;}
    }
    handleICWAI(event) {
        this.icwaiChecked = event.target.checked;
        this.membershipType = 'icwaim';
        this.uniqueRegNumber='';this.areaOfRegisteration='';this.yearOfRegisteration='';
        if (this.icwaiChecked) {this.regAnyFollowing = true;this.showAreaOfReg = false;this.showYearOfReg = false;this.showURNField = true;this.mciChecked = false;this.icaiChecked = false;this.showCheckRegiateration = true;this.isURNDisabled = false;this.isAreaOfRegDisabled = false;this.isYearOfRegDisabled = false;this.isCheckRegButtonDisable = false;
        } else if (!this.icwaiChecked) {this.showAreaOfReg = false;this.showYearOfReg = false;this.showURNField = false;this.mciChecked = false;this.icwaiChecked = false;this.icaiChecked = false;this.showCheckRegiateration = false;}
    }
    handleInputFieldChange(event) {
        const field = event.target.name;
        if (field === 'incomeFromField') {
            let incomeIncSource = event.target.value;
            this.incomeIncSource = incomeIncSource;
            let elem = this.template.querySelector(".incomeDec");
            elem.setCustomValidity("");
            if (incomeIncSource && (incomeIncSource < parseInt(Income5000))) {//CISP-5670
                elem.setCustomValidity(Incomemessage);
            }elem.reportValidity();
        } else if (field === 'nameOfRecbankField') {
            this.bankName = event.target.value;
        } else if (field === 'accountNumberField') {
            this.accountNum = event.target.value;
        } else if (field === 'salaried') {
            this.isSalaried = event.target.value;
        } else if (field === 'selfEmployed') {
            this.isSelfEmployed = event.target.value;
        } else if (field === 'employerNameField') {
            this.employerName = event.target.value;
        } else if (field === 'currentYearsField') {
            this.currentYearsEmployment = event.target.value;
        } //CISP:2973
        else if(field==='SMSTobeTriggered')

        {  this.SMSTobeTriggered = event.target.value; 
            console.log('The value of the trigger sms after ', this.SMSTobeTriggered)
            if(this.SMSTobeTriggered ==='Executive')
            { 
                this.isExecutive = true;
                console.log('i am in if of executive', this.isExecutive)
            } 
            else{this.isExecutive = false;
                this.ExecutiveMobileNo='';}
        }
        else if(field==='ExecutiveNumber')
        {
            this.ExecutiveMobileNo = event.target.value;
            console.log('The value of the mobile number  ', this.ExecutiveMobileNo)
        }
        else if (field === 'totalYearsField') {
            this.totalYearsEmploymnet = event.target.value;
        } else if (field === 'profileField') {
            this.profile = event.target.value;
            let profileValue;profileValue = this.getProfileId(event.target.value).profileCategory;
            this.profileId = this.getProfileId(event.target.value).profileId;
            this.bsrOccupation = '95012';
            if (profileValue === 'SEP') {this.showURN = true;this.isProfileSep = true;this.showRegisterationOptions = true;this.mciChecked=false;this.icaiChecked=false;this.icwaiChecked=false;this.isICWAIMDisable=false;this.isMCIDdisabled=false;this.isICAIDisable=false;this.checkRegButton=false;this.isCheckRegButtonDisable=false;
            } else {this.isProfileSep = false;this.showURNField = false;this.showAreaOfReg = false;this.showYearOfReg = false;this.showRegisterationOptions = false;this.showCheckRegiateration = false;}
        } else if (field === 'bsrField') {
            this.bsrOccupation = event.target.value;
        } else if (field === 'urnField') {
            this.uniqueRegNumber = event.target.value;
        } else if (field === 'areaOfRegField') {
            this.areaOfRegisteration = event.target.value;
        } else if (field === 'assesmentYearField') {
            this.assesmentYear = event.target.value;
            if( event.target.value==this.assessmentYearsValues[1].value ||  event.target.value==this.assessmentYearsValues[2].value){
               this.showToast('Please upload latest Assessment Year document if available','', 'warning');
            }
        } else if (field === 'docTypeField') {
            this.documentType = event.target.value;
            if(event.target.value=='Form26As'){
                this.showToast('Please upload ITR if available','', 'warning');
            }
        } else if (field === 'fromMonthField') {
            this.fromMonth = event.target.value;
        } else if (field === 'toMonthField') {
            this.toMonth = event.target.value;
        } else if (field === 'passwdForPdfField') {
            this.passwdForPdf = event.target.value;
        } else if (field === 'gstNumberField') {
            this.gstNumber = event.target.value;
        } else if (field === 'yearOfRegField') {
            this.yearOfRegisteration = event.target.value;
        }
    }
    getDate(event) {try{const userTodate = event.target.value;const enteredToDate = this.template.querySelector('lightning-input[data-id=toMonth]');this.toMonth = userTodate;this.toDateDisabled = false;
    var userToDate = new Date(parseInt(this.toMonth.split("-")[0]),parseInt(this.toMonth.split("-")[1]) - 1)
        var userFromDate = new Date();
        let diffInMonths = (this.monthDiff(userToDate,userFromDate) + 5);
        if( diffInMonths>0 && diffInMonths<5 ) { 
            let outPut = []; let dd = parseInt(userTodate.replace(/-/g, "")); let sNUm = dd.toString();
            for (let i = 0; i < sNUm.length; i++) { outPut.push(+sNUm.charAt(i)); }
            let mnth = "" + outPut[4] + outPut[5]; let yr = "" + outPut[0] + outPut[1] + outPut[2] + outPut[3];
            let frmDate; if (mnth > 0 + 6) { frmDate = yr + '-' + '0' + parseInt(mnth - 6); }
            if (mnth <= 0 + 6) { let finalMnth = (parseInt(mnth) + 6);
                if (finalMnth < 10) { frmDate = parseInt(yr - 1) + '-' + '0' + (parseInt(mnth) + 6);
                } else { frmDate = parseInt(yr - 1) + '-' + (parseInt(mnth) + 6);
                } } this.template.querySelector("lightning-input[data-id=fromMonth]").value = frmDate;//dd.toString();
            this.fromMonth = frmDate;enteredToDate.setCustomValidity("");
        } else if(diffInMonths <= 0) {enteredToDate.setCustomValidity("To Month should not be older than last 4 months");this.template.querySelector('lightning-input[data-id=toMonth]').value = '';this.template.querySelector("lightning-input[data-id=fromMonth]").value = '';
        } else if(diffInMonths > 0) {enteredToDate.setCustomValidity("To Month should be less than current Month");this.template.querySelector('lightning-input[data-id=toMonth]').value = '';this.template.querySelector("lightning-input[data-id=fromMonth]").value = '';}enteredToDate.reportValidity();
    }catch(error){console.log(error);}
    }
    monthDiff(userToDate, userFromDate) {return (userToDate.getMonth() - userFromDate.getMonth()) + (12 * (userToDate.getFullYear() - userFromDate.getFullYear()))}
    async captureBankStatement() { await this.isfieldsCompleted('Customer Bank Statement','capture'); }
    async captureITR() { await this.isfieldsCompleted(this.documentType,'capture');}
    @api async isfieldsCompleted(doctype, from){//CISP-3065-START
        if(this.isIncomeCreditedTobank ){
            if((this.accountNum === null || this.accountNum === undefined ||this.accountNum ==='') || (this.bankName === null || this.bankName === undefined || this.bankName === '')){
                const evt = new ShowToastEvent({title: "warning", message: 'Bank Name and bank account number is mandotory',variant: 'warning',});this.dispatchEvent(evt);return true;
            }
        }
        if (!this.validityCheck('lightning-input') || !this.validityCheck('lightning-combobox')) {this.showToast(this.label.fillAllRequiredFields,'', 'warning');this.checkValidit = false;this.isIncomeDetailDisable = false;this.isIncomeAssesmentButtonDisable=false;this.isDoYouFileITRDisabled = false;return true;//CISP-2664
        } else if (this.showRegisterationOptions && (this.mciChecked || this.icaiChecked || this.icwaiChecked) && !this.isICWAIMDisable && !this.isICAIDisable && !this.isMCIDdisabled) {
            this.showToast('', 'Complete registration process.', 'warning');
            return true;
        } else if(from=='capture'){ this.documentType=doctype; this.createdoc(doctype);
        } else if(from=='save'){
            if((this.doFileITRChecked || this.isIncomeCreditedTobank || this.doFileGSTChecked || this.onlineLinkChecked || this.onlineUploadLinkChecked || this.scanDeviceChecked) && (!this.incomeAssessmentDone || !this.disableIncomeAnalysis) && !this.isTwoWheeler){
                if ((this.isIncomeCreditedTobank && !this.bankStatementSuccessTick && this.scanDeviceChecked && !this.isTractor) || (this.doFileITRChecked && !this.checkITRButton && this.scanDeviceChecked && !this.isTractor)) {this.showToast('', 'Capture document first.', 'warning');return true;
                }else if(!this.incomeAssessmentDone){
                    if(!this.isTractor){
                        this.showToast('', 'Complete Income Assesment first.', 'warning');
                        return true;
                    }
                }else if(!this.disableIncomeAnalysis){this.showToast('', 'Complete Income Analysis first.', 'warning');return true;
                }
            }
            if(this.showRegisterationOptions && (this.mciChecked || this.icaiChecked || this.icwaiChecked) && !this.isICWAIMDisable && !this.isICAIDisable && !this.isMCIDdisabled){this.showToast('', 'Complete registration process.', 'warning');return true;}
            if(!this.profile && !this.profileId && !this.isTractor){this.showToast(this.label.fillAllRequiredFields,'', 'warning');return true;}//CISP-3065-END
            if (this.validityCheck('lightning-input') || this.validityCheck('lightning-combobox')) {
                this.checkValidit = true;this.isIncomeDetailDisable = true;this.isBankSelected = true;this.saveFlag = true; 
                await saveIncomeDetails({ incomeDetails: JSON.stringify(this.saveIncomeSource()), applicantId: this.applicantId, isTractor: this.isTractor  }).then(response => {
                    if(response?.status === 'success'){
                        this.incomeSourceId = response?.recordId;this.checkSaveButton = true;this.disableSave = true;this.isDeleteDisable = true;
                        const evt = new ShowToastEvent({
                            title: "success",message: 'Income Source Details Saved',variant: 'success',
                        }); this.dispatchEvent(evt);
                        if(this.incomeSourceStatus==='NIP'){
                            const evt = new ShowToastEvent({
                                title: "Warning",message: 'Income Source Marking as NIP',variant: 'warning',
                            });this.dispatchEvent(evt);
                        }
                    } else {
                        const evt = new ShowToastEvent({ title: "error", message: response?.message, variant: 'error', });
                        this.dispatchEvent(evt);
                    }
                }).catch(error => {
                    const evt = new ShowToastEvent({ title: 'Error in Saving Income Source Details', message: error, variant: 'error', });
                    this.dispatchEvent(evt);
                    this.checkSaveButton = false;
                    this.disableSave = false;
                });
            }
        }
    }
    async createdoc(docTypevar) {
        this.isLoading = true;
        await this.checkDocPresent(docTypevar, false,false);
        setTimeout(() => {
            this.isLoading = false;
            if (!this.documetAlreadyPresent && FORM_FACTOR=='Large') {
                createOtherDocument({ docType: docTypevar, applicantId: this.applicantId, loanApplicationId: this.currentOppRecordId })
                    .then(result => {
                        this.documentRecordId = result;
                        this.openUploadComp(docTypevar);
                    }).catch(error => { this.error = error;});
            }else {this.openUploadComp(docTypevar);}
        }, 5000);
    }
    changeflagvalue(event) {
        if(FORM_FACTOR!='Large'){
        this.checkDocPresent(this.docType, false,true);
        }else{if(event.detail.contentDocumentId==null){
                this.uploadViewDocFlag = false;this.showToast('Capture document','','warning');this.bankStatementSuccessTick=false;this.checkITRButton=false;
            }else{
                this.uploadViewDocFlag = false;
                this.contentDocumentId = event.detail.contentDocumentId;
                this.uploadedDocument = event.detail.uploadedDocType;
                this.afterDocumentUploaded(event.detail.contentDocumentId);
            }
        }
    }
    afterDocumentUploaded(contentDocumentId){
        if (this.docType === 'Customer Bank Statement' && contentDocumentId != null) {
            this.bankStatementSuccessTick = true;
            this.showToast('Success','Bank Statement captured successfully', 'success');
            this.isIncomeDetailDisable = true;
            this.isBankSelected = true;
            this.isDoYouFileITRDisabled = true;
        }else if ((this.docType == 'ITR-Forms' || this.docType == 'ITR-V' || this.docType == 'Form26As') && contentDocumentId != null) {
            this.checkITRButton = true;
            this.showToast('Success',this.docType + ' captured successfully', 'success');
            this.isIncomeDetailDisable = true;
            this.isBankSelected = true;
            this.isDoYouFileITRDisabled = true;
        }
    }
    validityCheck(query) {
        return [...this.template.querySelectorAll(query)]
            .reduce((validSoFar, inputField) => {
                inputField.reportValidity();
                return validSoFar && inputField.checkValidity();
            }, true);
    }
    selectedStateHandler(event) {
        this.bankId = event.detail.selectedValueId;
        this.bank = event.detail.selectedValueName;
        this.records = event.detail.records;
        this.bankName = event.detail.selectedValueName;
    }
    selectedCityHandler(event) {
        this.areaId = event.detail.selectedValueId;
        this.area = event.detail.selectedValueName;
        this.records = event.detail.records;
        this.areaOfRegisteration = event.detail.selectedValueName;
    }
    checkRegisteration() {
        let urnInput = this.template.querySelector('lightning-input[data-id=urn]');
        let yearInput;
        let areaInput;
        if (this.mciChecked) {
            yearInput = this.template.querySelector('lightning-input[data-id=yearReg]');
            yearInput.reportValidity();
            areaInput = this.template.querySelector('lightning-combobox[data-id=areaReg]');
            areaInput.reportValidity();
        }
        urnInput.reportValidity();
        if (urnInput.validity.valid && (this.icaiChecked || this.icwaiChecked || (this.mciChecked && yearInput.validity.valid && areaInput.validity.valid))) {
            this.isLoading = true;
            let mciDetails = {
                'MembershipType': this.membershipType,
                'year_of_reg': this.yearOfRegisteration,
                'MembershipId': this.uniqueRegNumber,
                'medical_council': this.areaOfRegisteration
            };
            doMembershipCallout({
                'inputJSONString': JSON.stringify(mciDetails),
                'applicantId': this.applicantId,
                'loanAppId':this.currentOppRecordId
            }).then(result => {
                    if (result !== null) {
                        this.isCheckRegButtonDisable = true;
                        this.checkRegButton = true;
                        this.isURNDisabled = true;
                        this.isAreaOfRegDisabled = true;
                        this.isYearOfRegDisabled = true;
                        const obj = JSON.parse(result);
                        if (obj.ResponseData.Fields.Applicants.Applicant.Services.Service[0].Status === 'Pass') {
                            this.incomeSourceStatus = 'SEP';
                            this.isMCIDdisabled = true;
                            this.isICAIDisable = true;
                            this.isICWAIMDisable = true;
                            this.showToast('Success','SEP Verified', 'success');
                            this.isLoading = false;
                        } else if (obj.ResponseData.Fields.Applicants.Applicant.Services.Service[0].Status === 'Fail') {
                            this.incomeSourceStatus = 'SEP-Not Verified';
                            this.isMCIDdisabled = true;
                            this.isICAIDisable = true;
                            this.isICWAIMDisable = true;
                            this.showToast('SEP Not Verified','', 'warning');
                            this.isLoading = false;
                        } else if (obj.ResponseData.Fields.Applicants.Applicant.Services.Service[0].Status === null) {
                            this.incomeSourceStatus = 'NIP';
                            this.isMCIDdisabled = true;
                            this.isICAIDisable = true;
                            this.isICWAIMDisable = true;                            
                            this.showToast('Income Source mark as NIP','', 'warning');
                            this.isLoading = false;
                        }
                    }
                }).catch(error => {this.showToast( error?.body?.message,'', 'warning');
                        this.isLoading = false;});
        }
    }
    @api async checkIncomeAssesment() {
        if (!this.validityCheck('lightning-input') || !this.validityCheck('lightning-combobox')) {
            this.showToast(this.label.fillAllRequiredFields,'', 'warning');
            this.checkValidit = false;
            this.isIncomeDetailDisable = false;
            this.isBankSelected = true;
            this.isIncomeAssesmentButtonDisable=false;
            this.isDoYouFileITRDisabled = false;
            return true;
        } else if (this.showRegisterationOptions && (this.mciChecked || this.icaiChecked || this.icwaiChecked) && !this.isICWAIMDisable && !this.isICAIDisable && !this.isMCIDdisabled) {
            this.showToast('', 'Complete registration process.', 'warning');
            return true;
        } else if ((this.isIncomeCreditedTobank && !this.bankStatementSuccessTick && this.scanDeviceChecked) || (this.doFileITRChecked && !this.checkITRButton && this.scanDeviceChecked))
         {
            this.showToast('Capture document first.','', 'warning');
        }
        else if(this.SMSTobeTriggered=='Executive' && this.ExecutiveMobileNo =='') //CISP:
        {
            this.showToast('Please enter the Executive Phone Number.','', 'warning');
            return true;
        }
        else if (this.validityCheck('lightning-input') || this.validityCheck('lightning-combobox')) {
            this.checkValidit = true;
            if (this.incomeSourceId == null) {
                if(this.isIncomeCreditedTobank ){
                    if((this.accountNum === null || this.accountNum === undefined ||this.accountNum ==='') || (this.bankName === null || this.bankName === undefined || this.bankName === '')){
                        const evt = new ShowToastEvent({title: "warning", message: 'Bank Name and bank account number is mandotory',variant: 'warning',});this.dispatchEvent(evt);return null;
                    } else {await checkBankIncomeDetails({ applicantId: this.applicantId, bankName: this.bankName, accountNum: this.accountNum })
                            .then(response => {
                                if (response == false) {const evt = new ShowToastEvent({ title: "warning",message: 'Applicant’s bank statement for this bank and account number is present',variant: 'warning',});this.dispatchEvent(evt);this.saveDataAndApiCalls();
                                } else if (response == true) {//this.incomeAssessmentDone = true;
                                    this.saveDataAndApiCalls();
                                }}).catch(error => { });}

                    }else{ //this.incomeAssessmentDone = true;
                        this.saveDataAndApiCalls();}
            } else {    //this.incomeAssessmentDone = true;
               this.saveDataAndApiCalls();}
        }return this.checkValidit;
    }
    async updateRecordDetails(fields) {
        const recordInput = { fields };
        await updateRecord(recordInput).then(() => { }) .catch(error => { });
    }
    saveIncomeSource() {console.log('this.incomeAssessmentDone ', this.incomeAssessmentDone);
        const incomeSourceArray = [];
        const incomeSourceDetailsFields = {};
        if(this.saveFlag && this.isTwoWheeler){this.incomeAssessmentDone = true;}//CISP-3053
        incomeSourceDetailsFields['bankAccountNumber'] = this.accountNum;
        incomeSourceDetailsFields['nameOfRecipientBank'] = this.bankId;
        incomeSourceDetailsFields['incomeAssessmentDone'] = this.incomeAssessmentDone;
        incomeSourceDetailsFields['Id'] = this.incomeSourceId;
        incomeSourceDetailsFields['Income'] = this.incomeIncSource;
        incomeSourceDetailsFields['name'] = this.employerName ? this.employerName : '';
        incomeSourceDetailsFields['applicantId'] = this.applicantId;
        incomeSourceDetailsFields['areaOfRegistration'] = this.areaOfRegisteration;
        incomeSourceDetailsFields['yearOfRegisteration'] = this.yearOfRegisteration;
        incomeSourceDetailsFields['bsrOccupation'] = this.bsrOccupation;
        incomeSourceDetailsFields['gstMetghod'] = this.doFileGSTChecked ? this.onlineLinkChecked ? Online_via_link : this.onlineUploadLinkChecked ? Upload_online_via_link : this.scanDeviceChecked ? Scan_using_device : '' : '';
        incomeSourceDetailsFields['isIncomeCreatedInBank'] = this.isIncomeCreditedTobank;
        incomeSourceDetailsFields['incomeMethod'] = this.isIncomeCreditedTobank ? this.onlineLinkChecked ? Online_via_link : this.onlineUploadLinkChecked ? Upload_online_via_link : this.scanDeviceChecked ? Scan_using_device : '' : '';
        incomeSourceDetailsFields['isICAI'] = this.icaiChecked;
        incomeSourceDetailsFields['isICWAI'] = this.icwaiChecked;
        incomeSourceDetailsFields['isMCI'] = this.mciChecked;
        incomeSourceDetailsFields['itrMethod'] = this.doFileITRChecked ? this.onlineLinkChecked ? Online_via_link : this.onlineUploadLinkChecked ? Upload_online_via_link : this.scanDeviceChecked ? Scan_using_device : '' : '';
        incomeSourceDetailsFields['isFileGST'] = this.doFileGSTChecked;
        incomeSourceDetailsFields['isFileITR'] = this.doFileITRChecked;
        incomeSourceDetailsFields['employeeBussinessName'] = this.employerName;
        incomeSourceDetailsFields['fromMonth'] = this.fromMonth;
        incomeSourceDetailsFields['toMonth'] = this.toMonth;
        incomeSourceDetailsFields['isIncomeSouce'] = false;
        incomeSourceDetailsFields['isSalaried'] = this.isSalaried;
        incomeSourceDetailsFields['isSelfEmployed'] = this.isSelfEmployed;
        incomeSourceDetailsFields['salariedSelfEmp'] = this.isSalaried ? salaried : this.isSalaried ? SelfEmployed ? this.SelfEmployed : '' : '';
        incomeSourceDetailsFields['isCurrentResidenceCumOffice'] = false;
        incomeSourceDetailsFields['legal'] = 'Individual';
        incomeSourceDetailsFields['gstNumber'] = this.gstNumber;
        incomeSourceDetailsFields['noOfLoanTakenInPast'] = '';
        incomeSourceDetailsFields['uniqueRegistrationNumber'] = this.uniqueRegNumber;
        incomeSourceDetailsFields['profile'] = this.profileId;
        incomeSourceDetailsFields['totalYearsEmploymentBusiness'] = this.totalYearsEmploymnet;
        incomeSourceDetailsFields['currentYearsEmploymentBusiness'] = this.currentYearsEmployment;
        incomeSourceDetailsFields['passwordForPdfProtectedStatement'] = this.passwdForPdf;
        incomeSourceDetailsFields['assessmentYear'] = this.assesmentYear;
        incomeSourceDetailsFields['documentType'] = this.documentType;
        incomeSourceDetailsFields['incomeSourceStatus'] = this.incomeSourceStatus;
        incomeSourceDetailsFields['SMSSentTo'] =  this.SMSTobeTriggered;//CISP: 2973
        incomeSourceDetailsFields['ExNoofEx'] = this.ExecutiveMobileNo;
        incomeSourceArray.push(incomeSourceDetailsFields);
        return incomeSourceArray;
    }
    errorInCatch() {const evt = new ShowToastEvent({ title: "Error", message: this.tryCatchError.body.message, variant: 'Error', });this.dispatchEvent(evt);}
    deleteIncomeSource() {const screenEvent = new CustomEvent("deleteincome", { detail: this.incomeDetail.key });this.dispatchEvent(screenEvent);}
    processProfileDropdown(categoryData) {
        this.isLoading = true;
        let profileArray = [];
        getProfile({ category: categoryData }).then(response => {
                if (response && response.length > 0) {
                    for (let index = 0; index < response.length; index++) {
                        if(this.isTractor && response[index].Name == 'AGRICULTURIST') {
                            this.profile = response[index].Name;
                            this.profileId = response[index].Id;
                        }
                        let profileData = {};
                        profileData.value = response[index].Name;
                        profileData.label = response[index].Name;
                        profileData.id = response[index].Id;
                        profileData.code = response[index].Code__c;
                        profileData.category = response[index].Category__c;
                        profileArray.push(profileData);
                    }
                    this.profileValuesData = profileArray;
                    if (this.pageReloaded) {let profileCat = this.getProfileId(this.profile).profileCategory;}
                }this.isLoading = false;
            }).catch(error => { this.isLoading = false; });
    }
    getProfileId(profileName) {
        this.isLoading = true;
        let profileData = {}
        if (this.profileValuesData && this.profileValuesData.length) {
            for (let index = 0; index < this.profileValuesData.length; index++) {
                if (this.profileValuesData[index].value === profileName) {
                    profileData.profileCategory = this.profileValuesData[index].category;
                    if (profileData.profileCategory === 'SEP') {
                        this.isProfileSep = true;
                        this.showRegisterationOptions = true;
                    } else if (profileData.profileCategory === 'SENP') {
                        this.showIncomeCreditBankCheck = false;
                        this.isProfileSep = false;
                        this.showRegisterationOptions = false;
                    } profileData.profileId = this.profileValuesData[index].id;
                }}}this.isLoading = false;return profileData;
    }
    async scanReportGeneration() {
        this.isLoading = true;
        let scanUploadReportGenerationString = {
            'perfiosTransactionId': this.perfiosTransactionId,
            'loanApplicationId': this.currentOppRecordId };
        await doScanUploadReportGeneration({ scanUploadReportGenerationString: JSON.stringify(scanUploadReportGenerationString) })
            .then(result => {
                this.isLoading = false;
                this.showToast('Report Generation Initiated','','success');
                const scanFields = {};this.incomeAssessmentDone = true;
                scanFields[INCOME_DETAIL_ID_FIELD.fieldApiName] = this.incomeSourceId;
                scanFields[INCOME_ASSESMENT_DONE.fieldApiName] = this.incomeAssessmentDone;
                scanFields[ReportInitiated_FIELD.fieldApiName] = true;
                this.updateRecordDetails(scanFields);
                this.disableIncomeAnalysis = true;
                doBSTransactionStatusAsyncCallout({ clientTransactionId: this.perfiosTransactionId, loanApplicationId: this.currentOppRecordId, incomeDtlId: this.incomeSourceId ,uploadType: 'scanUpload'});
            }).catch(error => {this.isLoading = false;this.showToast('Kindly retry after sometime','','error');});
    }
    updateApicall(apiType, isUpdateAPIAccebilty, status, counter, Id) {updateAPICounterAndAccesibility({ incomeId: Id, apiType: apiType, counter: counter + 1, isUpdateAPIAccebilty: isUpdateAPIAccebilty }).then(updateResponse => {this.isLoading = false;}).catch(error => { this.isLoading = false; });}
    @api saveDetails() {
        saveIncomeDetails({ incomeDetails: JSON.stringify(this.saveIncomeSource()), applicantId: this.applicantId, isTractor: this.isTractor }).then(response => {
            if(response?.status === 'success'){this.incomeSourceId = response?.recordId;
            } else {const evt = new ShowToastEvent({ title: "error", message: response?.message, variant: 'error', });this.dispatchEvent(evt);this.disableSave = false;this.showToast('Error', response?.message, 'error');}
        }).catch(error => {this.showToast('Error in saving Income Source details', error, 'error');this.checkSaveButton = false;this.disableSave = false;});
    }
    checkDocPresent(docType, fromConnectedCallback,afterUpload) {       
        fetchDocument({ docType: docType, applicantId: this.applicantId })
            .then(response => {
                if (response != null) {
                    this.documentRecordId = response;
                    if (fromConnectedCallback) { 
                        getContentDocumentId({ documentId: this.documentRecordId })
                        .then(response => {if(response){this.contentDocumentId=response;}});
                        if (docType == 'ITR-Forms' || docType == 'ITR-V' || docType == 'Form26As') {this.checkITRButton = true; this.captureITRDisabled = true;
                        }else {this.bankStatementSuccessTick = true;this.disableBS = true;}
                    } else if (!fromConnectedCallback && !afterUpload) { this.documetAlreadyPresent = true;
                    }else if(afterUpload){
                        getContentDocumentId({ documentId: this.documentRecordId })
                        .then(response => {
                            if(response==null){this.showToast('Capture document','','warning');this.bankStatementSuccessTick=false;this.checkITRButton=false;
                            }else{this.contentDocumentId=response;this.uploadViewDocFlag = false;this.afterDocumentUploaded(response);}
                        }).catch(error => {return false;});
                    }
                } else {this.documetAlreadyPresent = false;return false;}
            }).catch(error => {return false;});
    }
    async handleSave() {await this.isfieldsCompleted('','save');}
    saveDataAndApiCalls() {
        saveIncomeDetails({ incomeDetails: JSON.stringify(this.saveIncomeSource()), applicantId: this.applicantId, isTractor: this.isTractor }).then(response => {
            if(response?.status === 'success'){
                if(!this.isTractor){this.incomeSourceId = response?.recordId; this.showToast('Success', 'Income Source Saved !', 'success');this.incomeAssessmentDone = true;}//CISP-15137
                if(this.isTractor){
                    this.incomeSourceId = response?.recordId;
                    if (this.doFileITRChecked && this.onlineLinkChecked) { this.eligibilityITR('ITROnline', 'ITR');
                    }
                    if (this.doFileITRChecked && this.onlineUploadLinkChecked) { this.eligibilityITR('ITRUpload', 'ITRUpload');
                    }
                    if (this.doFileGSTChecked && this.onlineLinkChecked) {this.eligibilityGST('GSTOnline', 'GST');
                    }
                    if (this.doFileGSTChecked && this.onlineUploadLinkChecked) {this.eligibilityGST('GSTUpload', 'GSTUpload');
                    }
                    if (this.isIncomeCreditedTobank && this.onlineLinkChecked) {this.eligibilityBankStatementApi('netbankingFetch', 'BANK_STATEMENT');
                    }
                    if (this.isIncomeCreditedTobank && this.onlineUploadLinkChecked) {this.eligibilityBankStatementApi('statement', 'BSUpload');
                    }
                    if (this.isIncomeCreditedTobank && this.scanDeviceChecked) { this.eligibilityScanUploadsApi('BSScanUpload');
                    }
                    if (this.doFileITRChecked && this.scanDeviceChecked) { this.eligibilityScanUploadsApi('ITRScanUpload');
                    }
                }
                if (this.incomeSourceStatus === 'NIP') {
                    this.isDoYouFileITRDisabled = true;
                    this.isMCIDdisabled = true;
                    this.isICAIDisable = true;
                    this.isICWAIMDisable = true;
                    this.toDateDisabled = true;
                    this.isCheckRegButtonDisable = true;
                } this.isDeleteDisable = true;
            } else { this.showToast('Error', response?.message, 'error');}
        }).catch(error => { this.showToast('Error in saving Income Source details', error, 'error');});
    }
    openUploadComp(docTypevar) {
        if (docTypevar == 'Customer ITR') { }
        this.docType = docTypevar;
        this.showUpload = true;
        this.showDocView = false;
        this.isVehicleDoc = true;
        this.isAllDocType = false;
        this.uploadViewDocFlag = true;
    }
    docDeleted() {this.documentRecordId = null;}
    showToast(title, message, variant) {
        const evt = new ShowToastEvent({ title: title,message: message,variant: variant,
        }); this.dispatchEvent(evt);
    }
    async itrApiCall(incomeDetailString, icounter, apiType ,fromResend) {
        await doITROnlineCallout({ 'incomeDetailString': JSON.stringify(incomeDetailString) }).then(result => {
            this.isLoading = false;
            const evt = new ShowToastEvent({ title: "Success",message: 'ITR Passed',variant: 'Success',});
            this.dispatchEvent(evt);
            this.disableResend = false;
            const itrFields = {};this.incomeAssessmentDone = true;
            itrFields[INCOME_DETAIL_ID_FIELD.fieldApiName] = this.incomeSourceId;
            itrFields[INCOME_ASSESMENT_DONE.fieldApiName] = this.incomeAssessmentDone;
            itrFields[CTR_FIELD.fieldApiName] = JSON.parse(result).clientTransactionId;
            this.updateRecordDetails(itrFields);
            this.disableAll();
            this.url = JSON.parse(result).Request_Initiation_Url;
            doITRTransactionStatusAsyncCallout({ clientTransactionId: JSON.parse(result).clientTransactionId, loanApplicationId: this.currentOppRecordId, incomeDtlId: this.incomeSourceId ,uploadType : 'online' });
            if (JSON.parse(result).url) {
                if(!fromResend){
                    this.isLoading = true;
                    this.updateApicall(apiType, true, 'Success', icounter, this.incomeSourceId);
                }
            } else {
                if(!fromResend){
                    this.isLoading = true;
                    this.updateApicall(apiType, false, 'nonSuccess', icounter, this.incomeSourceId);
                }
            }
            if(this.url){this.emailInitiate();}
        }).catch(error => {
            if(!fromResend){
                this.isLoading = false;
                this.updateApicall(apiType, false, 'nonSuccess', icounter, this.incomeSourceId);
            }
            this.showToast('Kindle Retry ', error?.body?.message, 'error');
        });
    }
    async gstApiCall(incomeDetailString, GSTCOUNTER, apiType, fromResend) {
        await doGSTOnlineCallout({
            'incomeDetailString': JSON.stringify(incomeDetailString)
        }).then(result => {
                this.isLoading = false;
                const evt = new ShowToastEvent({ title: "Success", message: 'GST Passed',variant: 'success',}); this.dispatchEvent(evt);
                this.disableResend = false;
                const gstFields = {};this.incomeAssessmentDone = true;
                gstFields[INCOME_DETAIL_ID_FIELD.fieldApiName] = this.incomeSourceId;
                gstFields[INCOME_ASSESMENT_DONE.fieldApiName] = this.incomeAssessmentDone;
                gstFields[CTR_FIELD.fieldApiName] = JSON.parse(result).clientTransactionId;
                this.updateRecordDetails(gstFields);
                //this.isCustomLookupFieldDisabled=true;
                this.disableAll();
                this.clientTransactionId = JSON.parse(result).clientTransactionId;
                this.url = JSON.parse(result).Request_Initiation_Url;
                doGSTTransactionStatusAsyncCallout({ clientTransactionId: JSON.parse(result).clientTransactionId, loanApplicationId: this.currentOppRecordId, incomeDtlId: this.incomeSourceId });
                if (JSON.parse(result).url) {
                    if(!fromResend){
                    this.isLoading = true;
                    this.updateApicall(apiType, true, 'Success', GSTCOUNTER, this.incomeSourceId);
                    }
                } else {
                    if(!fromResend){
                    this.isLoading = true;
                    this.updateApicall(apiType, false, 'NonSuccess', GSTCOUNTER, this.incomeSourceId);
                    }
                }
                if(this.url){this.emailInitiate();}
            }).catch(error => {
                if(!fromResend){
                this.isLoading = false;
                this.updateApicall(apiType, false, 'NonSuccess', GSTCOUNTER, this.incomeSourceId);
                }
                this.showToast('Kindle Retry ', error?.body?.message, 'error');
            });
    }
    async perfiosApiCall(incomeDetailString, BSCOUNTER, apiType , fromResend) {
        let ExNo = this.ExecutiveMobileNo; //CISP: 2978 Added new parameter Executive No 
        await doPerfiosGenerateLinkCallout({ 'incomeDetailString': JSON.stringify(incomeDetailString), 'executivemobileno':ExNo})
            .then(result => {
                this.isLoading = false;
                const evt = new ShowToastEvent({title: "Success",message: 'Bank Statement Passed',variant: 'success',
                }); this.dispatchEvent(evt);
                this.disableResend = false;
                const obj = JSON.parse(result);
                const bankFields = {};this.incomeAssessmentDone = true;
                bankFields[INCOME_DETAIL_ID_FIELD.fieldApiName] = this.incomeSourceId;
                bankFields[INCOME_ASSESMENT_DONE.fieldApiName] = this.incomeAssessmentDone;
                bankFields[CTR_FIELD.fieldApiName] = JSON.parse(result).ClientTransactionId;
                this.updateRecordDetails(bankFields);
                this.disableAll();
                this.url = JSON.parse(result).Request_Initiation_Url;
                doBSTransactionStatusAsyncCallout({ clientTransactionId: JSON.parse(result).ClientTransactionId, loanApplicationId: this.currentOppRecordId, incomeDtlId: this.incomeSourceId ,uploadType: 'online'});
                if (obj.Message === 'SUCCESS') {
                    if(!fromResend){
                        this.isLoading = true;
                        this.updateApicall(apiType, true, 'Success', BSCOUNTER, this.incomeSourceId);
                    }
                } else {
                    if(!fromResend){
                        this.isLoading = true;
                        this.updateApicall(apiType, false, 'NonSuccess', BSCOUNTER, this.incomeSourceId);
                    }
                }
                if(this.url){this.emailInitiate();}
            }).catch(error => { if(!fromResend){ this.isLoading = false; this.updateApicall(apiType, false, 'NonSuccess', BSCOUNTER, this.incomeSourceId); } this.showToast('Error', error?.body?.message, 'error'); });
    }
    eligibilityITR(itrType, apiType) {
        let finalData = { applicantId: this.applicantId, apiType: apiType, incomeDetailId: this.incomeSourceId };
        this.isLoading = true;
        getAPIEligibility({ checkEligibilityData: JSON.stringify(finalData) })
            .then(eresult => {
                this.isLoading = false;
                if (eresult && Object.keys(eresult).length > 0) {
                    if (eresult.ITR === 'NotAllowed') {
                        this.showToast('Warning', 'Already Accessed ITR', 'warning');
                        this.disableAll();
                    } else {
                        if (eresult.ITRCOUNTER <= 3) {
                            this.showToast('Success', 'Income Source Saved !', 'success');
                            this.itrType = itrType;
                            this.isLoading = true;
                            let incomeDetailString = {
                                'loanApplicationId': this.currentOppRecordId,
                                'applicantId': this.applicantId,
                                'itrType': this.itrType
                            };
                            this.itrApiCall(incomeDetailString, eresult.ITRCOUNTER, apiType, false);
                        } else {
                            this.showToast('Attempts Exhausted', 'Select other Option', 'warning');
                            this.isIncomeAssesmentButtonDisable = true;
                            this.disableResend = false;
                        }
                    }
                }
            }).catch(error => {this.isLoading = false;});
    }
    eligibilityGST(gstType, apiType) {
        this.gstType = gstType;
        let finalData = { applicantId: this.applicantId, apiType: apiType, gstNumber: this.gstNumber, incomeDetailId: this.incomeSourceId };
        this.isLoading = true;
        getAPIEligibility({ checkEligibilityData: JSON.stringify(finalData) }).then(eresult => {
            this.isLoading = false;
            if (eresult && Object.keys(eresult).length > 0) {
                if (eresult.GST === 'NotAllowed') {
                    this.showToast('Warning', 'Already Accessed With GST Number', 'warning');
                    this.disableAll();
                } else {
                    if (eresult.GSTCOUNTER <= 3) {
                        this.showToast('Success', 'Income Source Saved !', 'success');
                            let gcounter;
                        gcounter = eresult.GSTCOUNTER;
                        this.gstType = gstType;
                        this.isLoading = true;
                        let incomeDetailString = {
                            'loanApplicationId': this.currentOppRecordId,
                            'incomeDtlId': this.incomeSourceId,
                            'gstType': gstType,
                            'applicantId': this.applicantId
                        };
                        this.gstApiCall(incomeDetailString, eresult.GSTCOUNTER, apiType, false);
                    } else {
                        this.showToast('Attempts Exhausted', 'Select other Option', 'warning');
                        this.isIncomeAssesmentButtonDisable = true;
                        this.disableResend = false;
                    }
                }
            }
        }).catch(error => { this.isLoading = false;});
    }
    eligibilityBankStatementApi(bsType, apiType) {
        let finalData = { applicantId: this.applicantId, apiType: apiType, incomeDetailId: this.incomeSourceId };
        this.isLoading = true;
        getAPIEligibility({ checkEligibilityData: JSON.stringify(finalData) }).then(eresult => {
            this.isLoading = false;
            if (eresult && Object.keys(eresult).length > 0) {
                if (eresult.BANK_STATEMENT === 'NotAllowed') {
                    this.showToast('Warning', 'Already Accessed With BANK_STATEMENT Number', 'warning');
                    this.disableAll();
                } else {
                    if (eresult.BSCOUNTER <= 3) {
                        this.showToast('Success', 'Income Source Saved !', 'success');
                        this.bsType = bsType;
                        this.isLoading = true;
                        let incomeDetailString = {
                            'loanApplicationId': this.currentOppRecordId,
                            'incomeDetailId': this.incomeSourceId,
                            'bankType': this.bsType
                        };
                        this.perfiosApiCall(incomeDetailString, eresult.BSCOUNTER, apiType);
                    } else {
                        this.showToast('Attempts Exhausted', 'Select other Option', 'warning');
                        this.isIncomeAssesmentButtonDisable = true;
                        this.disableResend = false;
                    }
                }
            }
        }).catch(error => { });
    }
    eligibilityScanUploadsApi(scanType) {
        let finalData = { applicantId: this.applicantId, apiType: scanType, incomeDetailId: this.incomeSourceId };
        this.isLoading = true;
        getAPIEligibility({ checkEligibilityData: JSON.stringify(finalData) })
            .then(eresult => {
                this.isLoading = false;
                if (eresult && Object.keys(eresult).length > 0) {
                    if (scanType == 'BSScanUpload') {
                        if (eresult.bsScanUploadCounter <= 3) {
                            this.bsScanUploadApi();
                        } else {
                            this.showToast('Attempts Exhausted', 'Select other Option', 'warning');
                            this.isIncomeAssesmentButtonDisable = true;
                            this.disableResend = false;
                        }
                    } else {
                        if (eresult.itrScanUploadCounter <= 3) {
                            this.itrScanUploadApi();
                        } else {
                            this.showToast('Attempts Exhausted', 'Select other Option', 'warning');
                            this.isIncomeAssesmentButtonDisable = true;
                            this.disableResend = false;
                        }
                    }
               }
            }).catch(error => { });
    }
    handleResend() {
        if (this.doFileITRChecked && this.onlineLinkChecked) {
            let incomeDetailString = {
                'loanApplicationId': this.currentOppRecordId,
                'applicantId': this.applicantId,
                'itrType': 'ITROnline'
            };
            this.itrResendFlag = true;
            this.itrApiCall(incomeDetailString, 0 , 'ITR',true);
        }
        if (this.doFileITRChecked && this.onlineUploadLinkChecked) {
            let incomeDetailString = {
                'loanApplicationId': this.currentOppRecordId,
                'applicantId': this.applicantId,
                'itrType': 'ITRUpload'
            };
            this.itrApiCall(incomeDetailString, 0 , 'ITRUpload',true);
        }
        if (this.doFileGSTChecked && this.onlineLinkChecked) {
            let incomeDetailString = {
                'loanApplicationId': this.currentOppRecordId,
                'incomeDtlId': this.incomeSourceId,
                'gstType': 'GSTOnline',
                'applicantId': this.applicantId
            };this.gstApiCall(incomeDetailString, 0, 'GST', true);
        }
        if (this.doFileGSTChecked && this.onlineUploadLinkChecked) {
            let incomeDetailString = {
                'loanApplicationId': this.currentOppRecordId,
                'incomeDtlId': this.incomeSourceId,
                'gstType': 'GSTUpload',
                'applicantId': this.applicantId
            };this.gstApiCall(incomeDetailString, 0, 'GSTUpload', true);
        }
        if (this.isIncomeCreditedTobank && this.onlineLinkChecked) {
            let incomeDetailString = {
                'loanApplicationId': this.currentOppRecordId,
                'incomeDetailId': this.incomeSourceId,
                'bankType': 'netbankingFetch'
            };this.perfiosApiCall(incomeDetailString, 0, 'BANK_STATEMENT', true);
        }
        if (this.isIncomeCreditedTobank && this.onlineUploadLinkChecked) {
            let incomeDetailString = {
                'loanApplicationId': this.currentOppRecordId,
                'incomeDetailId': this.incomeSourceId,
                'bankType': 'statement'};
            this.perfiosApiCall(incomeDetailString, 0, 'BSUpload', true);
        }
        if (this.isIncomeCreditedTobank && this.scanDeviceChecked) { this.bsScanUploadApi();}
        if (this.doFileITRChecked && this.scanDeviceChecked) { this.itrScanUploadApi();}
    }
    bsFileId;
    async bsScanUploadApi() {
        let scanUploadInitiateString = { 'incomeDetailId':  this.incomeSourceId,'contentId':this.contentDocumentId, 'loanApplicationId': this.currentOppRecordId, 'employerName':this.employerName, 'employmentType': this.isSalaried ? salaried : SelfEmployed, 'yearMonthTo': this.toMonth, 'yearMonthFrom': this.fromMonth,'password':this.passwdForPdf,bankName: this.bankName};
        this.isLoading = true;
        await doScanUploadInitiate({ scanUploadInitiateString: JSON.stringify(scanUploadInitiateString) }).then(result => {
                this.isLoading = false;
                this.showToast('Bank Statement Uploaded to Perfios','','success');
                const scanFields = {};this.incomeAssessmentDone = true;
                scanFields[INCOME_DETAIL_ID_FIELD.fieldApiName] = this.incomeSourceId;
                scanFields[INCOME_ASSESMENT_DONE.fieldApiName] = this.incomeAssessmentDone;
                scanFields[PERFIOS_ID_FIELD.fieldApiName] = result.perfiosTransactionId;
                scanFields[UploadedToPerfios_FIELD.fieldApiName] = true;
                this.template.querySelector('[data-id="incomeAssesment"]').disabled=true;
                this.template.querySelector('[data-id="captureBS"]').disabled=true;
                this.updateRecordDetails(scanFields);
                this.perfiosTransactionId = result.perfiosTransactionId;
                this.disableAll();
                this.disableIncomeAnalysis = false;
            }).catch(error => {
                this.isLoading = false;
                if(error.body.message==='Unrecognized base64 character: "'){ this.showToast('Error','No Response found','error'); } else{this.showToast(error?.body?.message,'','error');}
            });
    }
    async itrScanUploadApi() {
        this.isLoading = true;
        let type;
        if (this.documentType == 'ITR-V') {type = 'SCANNED_ITRV';} else if (this.documentType == 'ITR-Forms') {type = 'SCANNED_ITR';} else { type = 'SCANNED_FORM26AS';}
        await doITRScanUploadInitiate({ incomeDetailId:  this.incomeSourceId,applicantId: this.applicantId,contentDocumentId :this.contentDocumentId, loanAppId: this.currentOppRecordId,documentType : type}).then(result => {
                 this.isLoading = false;
                const scanFields = {};this.incomeAssessmentDone = true;
                scanFields[INCOME_DETAIL_ID_FIELD.fieldApiName] = this.incomeSourceId;
                scanFields[INCOME_ASSESMENT_DONE.fieldApiName] = this.incomeAssessmentDone;
                scanFields[PERFIOS_ID_FIELD.fieldApiName] = JSON.parse(result).transactionId;
                scanFields[UploadedToPerfios_FIELD.fieldApiName] = true;
                this.transactionId = JSON.parse(result).transactionId;
                this.template.querySelector('[data-id="incomeAssesment"]').disabled=true;
                this.template.querySelector('[data-id="captureITR"]').disabled=true;
                this.updateRecordDetails(scanFields);
                this.showToast(this.documentType+' Uploaded to Perfios.','','success');
                this.disableAll();
                this.disableIncomeAnalysis = false;
            }).catch(error => {
                this.isLoading = false;
                this.showToast('Kindle Retry',error?.body?.message,'error');
            });
    }
    async itrCompleteTransactionApi() {
        this.isLoading = true;
        let itrScanUploadCompleteTransactionString = {
            'perfiosTransactionId': this.transactionId,
            'loanApplicationId': this.currentOppRecordId};
        await doITRScanUploadCompleteTransaction({ itrScanUploadCompleteTransactionString: JSON.stringify(itrScanUploadCompleteTransactionString) }).then(result => {
                this.isLoading = false;
                this.showToast('Report Generation Initiated','','success');
                const scanFields = {};this.incomeAssessmentDone = true;
                scanFields[INCOME_DETAIL_ID_FIELD.fieldApiName] = this.incomeSourceId;
                scanFields[INCOME_ASSESMENT_DONE.fieldApiName] = this.incomeAssessmentDone;
                scanFields[ReportInitiated_FIELD.fieldApiName] = true;
                this.updateRecordDetails(scanFields);
                this.disableIncomeAnalysis=true;
                doITRTransactionStatusAsyncCallout({ clientTransactionId: this.transactionId, loanApplicationId: this.currentOppRecordId, incomeDtlId: this.incomeSourceId ,uploadType : 'scanUpload' });
            }).catch(error => { this.isLoading = false; this.showToast('Kindly retry after sometime','','error'); });
    }
    handleIncomeAnalysis() {
        this.isIncomeAssesmentButtonDisable = true;
        checkAPISatus({LoanId:this.currentOppRecordId , incomeId: this.incomeSourceId}).
        then((result)=>{
            if(result=='Success'){
                if (this.documentType == 'Customer Bank Statement') {
                    this.scanReportGeneration();
                }else {
                   this.itrCompleteTransactionApi();
                }
            } else if(result=='Processing'){
                this.disableIncomeAnalysis = false;
                this.showToast('', 'System is processing data. Please try after some time.', 'warning')
            }
            else{
                this.isIncomeAssesmentButtonDisable = false;
                this.disableIncomeAnalysis = true;
                this.showToast('', result, 'warning')
            }
        }).catch((error)=>{
            this.isIncomeAssesmentButtonDisable = false;
            this.disableIncomeAnalysis = true;
            this.showToast('', error, 'warning')
        })
    }
    showToast(title,message,variant){const evt = new ShowToastEvent({title: title,message: message,variant: variant,});this.dispatchEvent(evt);}
    disableAll(){
        this.isBankSelected=true;
        this.isIncomeDetailDisable = true;
        this.isIncomeAssesmentButtonDisable = true;
        this.checkAssessment=true;
        this.isDoYouFileITRDisabled = true;
        this.isMCIDdisabled = true;
        this.isICAIDisable = true;
        this.isICWAIMDisable = true;
        this.toDateDisabled = true;
        this.isCheckRegButtonDisable = true;
    }
    @api async disableEverything(){
        let allElements = await this.template.querySelectorAll('*');
        allElements.forEach(element =>element.disabled = true);
        // D2C chagne - Raman R S
        if(this.incomeDetail?.Applicant__r?.Opportunity__r?.LeadSource == 'D2C'){
            this.lookupInputDisabled = true;
            this.disableValue = true;
        }
        // EO D2C change
    }
    emailInitiate(){
        let emailRequestWrapper={
            'leadId': this.leadNumber,
            'emailTo': this.emailId,
            'emailCC': this.emailId,
            'emailSubject': PerfiosEmailTitle.replace('{!Applicant__c.Customer_First_Name__c}', this.firstName),
            'emailBody' : PerfiosEmail.replace('{!url}', this.url),
            'loanApplicationId': this.currentOppRecordId
        };
        doEmailServiceCallout({emailService : JSON.stringify(emailRequestWrapper)}).then(result=>{
        }).catch(error=>{});
    }
}