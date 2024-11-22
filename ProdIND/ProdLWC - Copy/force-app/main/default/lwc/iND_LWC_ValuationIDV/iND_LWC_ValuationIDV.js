/* Screen created By : Divya J
   Screen Name: 'iND_LWC_ValuationIDV'
   Description : Valuation IDV details will capture in this module.
   created on: 10 FEB 2022
 */ 

import { LightningElement, wire, api, track } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import LightningCardApplyCSS from '@salesforce/resourceUrl/loanApplication';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import loadVehicleDetailsData from '@salesforce/apex/IND_ValuationIDVCntrl.loadVehicleDetailsData';
import checkValidationBeforeSubmit from '@salesforce/apex/IND_ValuationIDVCntrl.checkValidationBeforeSubmit';
import deleteDocument from '@salesforce/apex/IND_DocumentUploadCntrl.deleteDocument';
import vehicleInsuranceDetails from '@salesforce/label/c.vehicleInsuranceDetails';
import captureVehicleDocuments from '@salesforce/label/c.captureVehicleDocuments';
import vehicledetailsSaved from '@salesforce/label/c.Vehicle_Valuation_Details_Saved';
import Borrower from '@salesforce/label/c.Borrower';
import CoBorrower from '@salesforce/label/c.CoBorrower';
import ValuationReport from '@salesforce/label/c.ValuationReport';
import InsurancePolicy from '@salesforce/label/c.InsurancePolicy';
import createDocument from '@salesforce/apex/IND_DocumentUploadCntrl.createDocumentForCheque';
import VEHICLE_DETAIL_OBJECT from '@salesforce/schema/Vehicle_Detail__c';
import VEHICLE_ID_FIELD from '@salesforce/schema/Vehicle_Detail__c.Id';
import INSURANCE_TYPE_FIELD from '@salesforce/schema/Vehicle_Detail__c.Insurance_type__c';
import INSURANCE_NUMBER_FIELD from '@salesforce/schema/Vehicle_Detail__c.Insurance_number__c';
import INSURANCE_DECLARED_VALUE_FIELD from '@salesforce/schema/Vehicle_Detail__c.Insurance_declared_value__c';
import INSURANCE_DATE_FIELD from '@salesforce/schema/Vehicle_Detail__c.Ins_Issuance_date__c';
import INSURANCE_EXPIRY_DATE_FIELD from '@salesforce/schema/Vehicle_Detail__c.Ins_Expiry_date__c';
import mandotoryDetailsNotProvide from '@salesforce/label/c.Mandotory_details_are_not_given_Please_provide';
import mfc from '@salesforce/label/c.MFC';
import Comprehensive from '@salesforce/label/c.Comprehensive';
import OEM from '@salesforce/label/c.OEM';
import Empanelled from '@salesforce/label/c.Empanelled';
import RCDocument from '@salesforce/label/c.RC_Document';
import valuationDecisioningMessage from '@salesforce/label/c.valuationDecisioningMessage';
import valuationDecisioningRequiredMessage from '@salesforce/label/c.valuationDecisioningRequiredMessage';
import valPriceLTVPricingEnginerequired from '@salesforce/label/c.valPriceLTVPricingEnginerequired';
import doMFCFetchValuationReportCallout from '@salesforce/apexContinuation/IntegrationEngine.doMFCFetchValuationReportCallout';
import mcfSuccessResponse from '@salesforce/label/c.MFC_Success_Response';
import reportGeneratedMessage from '@salesforce/label/c.MFCReportGeneratedMessage';
import ValuationIDV from '@salesforce/label/c.Valuation_IDV';
import CreditProcessing from '@salesforce/label/c.Credit_Processing';
import VALUATION_PRICE_FIELD from '@salesforce/schema/Vehicle_Detail__c.Valuation_price__c';
import VALUATION_REPORTURL_FIELD from '@salesforce/schema/Vehicle_Detail__c.MFC_valuation_Report_URL__c';
import DOC_ID_FIELD from '@salesforce/schema/Documents__c.Id';
import DOCUMENT_TYPE_FIELD from '@salesforce/schema/Documents__c.Document_Type__c';
import DOCUMENT_NAME_FIELD from '@salesforce/schema/Documents__c.Name';
import IS_PHOTOCOPY_FIELD from '@salesforce/schema/Documents__c.Is_Photocopy__c';
import VALUATION_DECISIONING_TYPE_FIELD from '@salesforce/schema/Vehicle_Detail__c.Valuation_Decisioning__c';
import VALUATION_OverallRemarks_FIELD from '@salesforce/schema/Vehicle_Detail__c.Overall_Remarks__c';

import ID_FIELD from "@salesforce/schema/Opportunity.Id";
import SUB_STAGE_FIELD from "@salesforce/schema/Opportunity.Sub_Stage__c";
import ReadOnlyLeadAccess from '@salesforce/label/c.ReadOnlyLeadAccess';
import getParentLeadNumber from '@salesforce/apex/Ind_VehicleValuationController.getParentLeadNumber'//CISP-3590
import MFC_Valuation_Report_Date from '@salesforce/schema/Vehicle_Detail__c.MFC_Valuation_Report_Date__c';//SFTRAC-2277
export default class IND_LWC_ValuationIDV extends NavigationMixin(LightningElement) {
    mfcGenerationDate;isRevokedApp = false;//CISP-2737/3590
    parentLeadNo = '';//CISP-3590
    activeSections = ['A', 'B'];
    @track substage = false ;//CISP-3075
    @api recordSaved;
    leadSource;//D2C Change
    customerType;


    label = {
        vehicleInsuranceDetails,
        captureVehicleDocuments,
        vehicledetailsSaved,
        Borrower,
        CoBorrower,
        ValuationReport,
        InsurancePolicy,
        mandotoryDetailsNotProvide,
        mfc,
        mcfSuccessResponse,
        reportGeneratedMessage,
        Comprehensive,
        Empanelled,
        OEM,
        RCDocument,
        valuationDecisioningMessage,
        valuationDecisioningRequiredMessage,
        valPriceLTVPricingEnginerequired,
        ValuationIDV,
        CreditProcessing
    }
    @api recordid;// = '00671000001DmvtAAC';//Hardcoded until module get merged
    @track applicantId;
    @track vehicleId;
    @track uploadViewDocFlag;
    @track doctype;
    @track isphotocopy = false;
    @track isStepOne = false;
    @track currentStep = this.label.vehicleInsuranceDetails;
    @track isEnableUploadViewDoc = true;
    @track isEnablePrev = false;
    @track isEnableSaveAndExit = false;
    @track isBorrower = true;
    @track tryCatchError = '';
    @api documentRecordId; //This variable used in Upload-And-View-Document parent cmp
    @track insuranceType = '';
    @track insurerName = '';
    @track insuranceNumber = '';
    @track insuranceDeclaredValue = '';
    @track insuranceDateField;
    @track insuranceExpiryDate;
    @track insuranceExpiryCheckbox = false;
    @track currentDate;
    @track leadNumber;
    @track vehicleRegNoValue;
    @track chassisNumber;
    @track makeValue;
    @track model;
    @track variant;
    @track engineNumber;
    @track yeatOfManufacturing;
    @track valuationPrice = '';
    @track valuerCategory;
    @track enableMFCReport = true;
    @track enableValuationPrice = true;
    @track valuationPricePopup = false;
    @track reportGenerated;
    @track reportURL;
    @track overallRemarks;
    @track enableInsuranceSection = false;
    @track docUploadSuccessfully = false;
    @track docUploaded = false;
    @track uploadviewdocpopup;
    @track insuredDelclaredValuePopup = false;
    @track valuationDecisioning;
    @track insurancePolicyCheckbox = false;
    @track enableInsuranceDeclared = false;
    @track ltvEnginge;
    @track pricingEngine;
    @track insurancePolicyPopup = false;
    @track showRCDocumentPopup = false;
    @api checkleadaccess;//coming from tabloanApplication
    @api isTractor;
    @track oemDealerFlag = false;
    @api vehicleDetail;
    @track serialNumber = '';
    @track hideSerialNumber = true;
    @wire(getObjectInfo, { objectApiName: VEHICLE_DETAIL_OBJECT })
    vehicleDetailMetaData;

    @track requestIdMFC;
    @wire(getPicklistValues,
        {
            recordTypeId: '$vehicleDetailMetaData.data.defaultRecordTypeId',
            fieldApiName: INSURANCE_TYPE_FIELD
        }
    )
    insuranceTypeValues;

    @wire(getPicklistValues,
        {
            recordTypeId: '$vehicleDetailMetaData.data.defaultRecordTypeId',
            fieldApiName: VALUATION_DECISIONING_TYPE_FIELD
        }
    )
    valuationDecisioningValues;

    @api isRevokedLoanApplication;//CISP-2735
    async connectedCallback() {

        
        if(this.isTractor){
            this.currentStage = this.vehicleDetail.stage;
            this.substage = this.vehicleDetail.subStage == 'Valuation IDV' ? false:true;
            this.customerType = this.vehicleDetail?.customerType;
            this.leadSource = this.vehicleDetail.leadSource;
            this.leadNumber = this.vehicleDetail.leadNumber;
            this.vehicleRegNoValue = this.vehicleDetail.vehicleRegNumber;
            this.makeValue = this.vehicleDetail.vehicleMake;
            this.chassisNumber = this.vehicleDetail.chassisNumber;
            this.model = this.vehicleDetail.vehicleModel;
            this.variant = this.vehicleDetail.vehicleVarient;
            this.engineNumber = this.vehicleDetail.engineNumber;
            this.serialNumber = this.vehicleDetail.serialNumber;
            if(this.vehicleDetail.vehicleSubType == 'Implement') {
                this.hideSerialNumber = false;
            }
            this.yeatOfManufacturing = this.vehicleDetail.manufacturerYearMonth;
            this.valuationPrice = this.vehicleDetail.valuationPrice;
            this.valuationDecisioning = this.vehicleDetail.valuationDecisioning;
            this.reportURL = this.vehicleDetail.reportURL;
            this.vehicleId = this.vehicleDetail.vehicleDetailId;
            this.applicantId = this.vehicleDetail.applicantId;
            this.valuerCategory = this.vehicleDetail.valuerCategory;
            this.insuranceType = this.vehicleDetail.insuranceType;
            if (this.insuranceType === null || this.insuranceType !== this.label.Comprehensive) {
                this.insuranceType = this.label.Comprehensive; //By Defualt Insurance Type is Comprehensive
            }
            this.insuranceNumber = this.vehicleDetail.insuranceNumber;
            this.insuranceDeclaredValue = this.vehicleDetail.insuranceDeclaredValue;
            this.insuranceDateField = this.vehicleDetail.insIssuenceDate;
            this.insuranceExpiryDate = this.vehicleDetail.insExpiryDate;
            this.insuranceExpiryCheckbox = this.vehicleDetail.isInsuranceExpired;
            this.docType = this.vehicleDetail.documentType;
            this.ltvEnginge = this.vehicleDetail.ltvEnginge;
            this.pricingEngine = this.vehicleDetail.pricingEngine;
            this.oemDealerFlag = this.vehicleDetail.oemCheck;
            this.requestIdMFC = this.vehicleDetail.requestId;
            if (this.insuranceExpiryCheckbox !== this.enableInsuranceSection) {
                this.enableInsuranceSection = true; // Enable insurance policy section if ‘Insurance expiring within 60 days’ is true.
            }
            if (this.valuerCategory === this.label.mfc) {
                this.enableMFCReport = false; // Enable MFC valuation report button if valuer category is MFC
            } else {
                this.enableMFCReport = true; // Disable MFC valuation report button
            }
            if (this.valuerCategory === this.label.mfc && this.oemDealerFlag) {
                this.enableMFCReport = true
                }
            if ((this.valuerCategory === this.label.Empanelled || this.valuerCategory === this.label.OEM) && (this.vehicleDetail.subStage == 'Valuation IDV') && this.leadSource !== 'D2C') {//CISP-3075
                this.enableValuationPrice = false;  // Enable Valuation Price field if valuer category is 'Empanelled' or 'OEM'
            }
            //SFTRAC-2284 Start
            if(this.valuerCategory === this.label.Empanelled){
                this.enableValuationPrice = true;
            }
            //SFTRAC-2284 End
        }
        else{
         await loadVehicleDetailsData({ loanApplicationId: this.recordid })
            .then(response => {
                let result = JSON.parse(response);
                console.log('Result!!!! ', result);
                this.currentStage = result.stage;
                this.substage = result.subStage == 'Valuation IDV' ?false:true//CISP-3075
                this.leadSource = result.leadSource;//D2C Change
                this.leadNumber = result.leadNumber;
                this.vehicleRegNoValue = result.vehicleRegNumber;
                this.makeValue = result.vehicleMake;
                this.chassisNumber = result.chassisNumber;
                this.model = result.vehicleModel;
                this.variant = result.vehicleVarient;
                this.engineNumber = result.engineNumber;
                this.yeatOfManufacturing = result.manufacturerYearMonth;
                this.valuationPrice = result.valuationPrice;
                this.valuationDecisioning = result.valuationDecisioning;
                this.reportURL = result.reportURL;
                this.vehicleId = result.vehicleDetailId;
                this.applicantId = result.applicantId;
                this.valuerCategory = result.valuerCategory;
                this.insuranceType = result.insuranceType;
                if (this.insuranceType === null || this.insuranceType !== this.label.Comprehensive) {
                    this.insuranceType = this.label.Comprehensive; //By Defualt Insurance Type is Comprehensive
                }
                this.insuranceNumber = result.insuranceNumber;
                this.insuranceDeclaredValue = result.insuranceDeclaredValue;
                this.insuranceDateField = result.insIssuenceDate;
                this.insuranceExpiryDate = result.insExpiryDate;
                this.insuranceExpiryCheckbox = result.isInsuranceExpired;
                this.docType = result.documentType;
                this.ltvEnginge = result.ltvEnginge;
                this.pricingEngine = result.pricingEngine;
                this.oemDealerFlag = result.oemCheck;
                this.requestIdMFC = result.requestId;
                if (this.insuranceExpiryCheckbox !== this.enableInsuranceSection) {
                    this.enableInsuranceSection = true; // Enable insurance policy section if ‘Insurance expiring within 60 days’ is true.
                }
                if (this.valuerCategory === this.label.mfc) {
                    this.enableMFCReport = false; // Enable MFC valuation report button if valuer category is MFC
                } else {
                    this.enableMFCReport = true; // Disable MFC valuation report button
                }
                if (this.valuerCategory === this.label.mfc && this.oemDealerFlag) {
                    this.enableMFCReport = true
                    }
                if ((this.valuerCategory === this.label.Empanelled || this.valuerCategory === this.label.OEM) && (result.subStage == 'Valuation IDV') && this.leadSource !== 'D2C') {//CISP-3075
                    this.enableValuationPrice = false;  // Enable Valuation Price field if valuer category is 'Empanelled' or 'OEM'
                }

            })
            .catch(error => {
                this.tryCatchError = error;
                this.errorInCatch();
            });
        }
        //Fetching Vehicle Details data on component load
         

            if(this.checkleadaccess){//if lead is accessible but user from different profile is viewing that
                const evt = new ShowToastEvent({
                title: ReadOnlyLeadAccess,
                variant: 'warning',
                mode: 'sticky'
                });
                this.dispatchEvent(evt);
               console.log('from tab loan');
               this.disableEverything();
   
            }
            //CISP-3590
                getParentLeadNumber({ leadId: this.recordid })
                .then(result => {
                console.log('Result', result);
                if(result){
                    
                    this.parentLeadNo = result?.Parent_Loan_Application__r?.Lead_number__c;
                    this.parentLeadNo = this.parentLeadNo?.toString().substring(0,12);//CISP-2904
                    this.isRevokedApp = result?.Parent_Loan_Application__r?.Is_Revoked__c;
                }
                })
                .catch(error => {
                console.error('Error:', error);
            });
            //CISP-3590

           if(this.isRevokedLoanApplication){this.disableEverything();}//CISP-2735
    }
    disableEverything(){
          let allElements = this.template.querySelectorAll('*');
          allElements.forEach(element =>
          element.disabled = true
        );

    }
    renderedCallback() {
        loadStyle(this, LightningCardApplyCSS);
        if(this.isRevokedLoanApplication){this.disableEverything();}//CISP-2735
        if(this.isTractor && this.template.querySelector('lightning-input[data-id=expDate]')!=undefined){
            this.template.querySelector('lightning-input[data-id=expDate]').disabled = true;
        }
    }
    // handle error catch
    errorInCatch() {
        const evt = new ShowToastEvent({
            title: "Error",
            message: this.tryCatchError.body.message,
            variant: 'Error',
        });
        this.dispatchEvent(evt);
    }
    //handle update record
    async updateRecordDetails(fields) {
        const recordInput = { fields };
        await updateRecord(recordInput)
            .then(() => {
                console.log('record update success', JSON.stringify(fields));
            })
            .catch(error => {
                console.log('record update Error:==>', error);
                // this.tryCatchError = error;
                // this.errorInCatch();
            });
    }
    //handle issurance number field 
    handleInsuranceNumber() {
        let insuranceNumberInput = this.template.querySelector('lightning-input[data-id=insNum]');
        let insuranceNumber = insuranceNumberInput.value;
        this.insuranceNumber = insuranceNumber;
        insuranceNumberInput.reportValidity();
    }
    //handle insurance declared value field
    handleInsuranceDeclaredValue() {
        let insuranceDeclaredValueInput = this.template.querySelector('lightning-input[data-id=insDecVal]');
        let insuranceDeclaredValue = insuranceDeclaredValueInput.value;
        this.insuranceDeclaredValue = insuranceDeclaredValue;
        this.insuredDelclaredValuePopup = true;
        insuranceDeclaredValueInput.reportValidity();
    }
    //handle issuance date field
    handleIssuanceDate() {
        let issuanceDateInput = this.template.querySelector('lightning-input[data-id=issDate]');
        let insuranceDateField = issuanceDateInput.value;
        this.insuranceDateField = insuranceDateField;
        issuanceDateInput.reportValidity();
    }
    //handle expiry date field
    handleExpiryDate() {
        var differenceInDays = -1;
        let expiryDateInput = this.template.querySelector('lightning-input[data-id=expDate]');
        let insuranceExpiryDate = expiryDateInput.value;
        this.insuranceExpiryDate = insuranceExpiryDate;
        expiryDateInput.reportValidity();
        //check if entered date is within 60 days
        var today = new Date();
        this.currentDate = today;
        today.setDate(today.getDate() + 60);
        differenceInDays = ((today / (1000 * 60 * 60 * 24)) % 1890) - (((new Date(this.insuranceExpiryDate)) / (1000 * 60 * 60 * 24)) % 1890);
        //Check if Insurance expiry date is within or equal 60 or already expired
        if (differenceInDays <= 60 && differenceInDays > 0 || (new Date(this.insuranceExpiryDate)) < today) {
            this.insuranceExpiryCheckbox = true;
        } else {
            this.insuranceExpiryCheckbox = false;
        }
    }
    //Save document records
    saveDocumentRecord() {
        const docFields = {};
        docFields[DOC_ID_FIELD.fieldApiName] = this.documentRecordId;
        docFields[DOCUMENT_TYPE_FIELD.fieldApiName] = this.docType;
        docFields[DOCUMENT_NAME_FIELD.fieldApiName] = this.docType;
        docFields[IS_PHOTOCOPY_FIELD.fieldApiName] = this.isPhotocopy;
        this.updateRecordDetails(docFields)
            .then(() => {
                this.docUploadSuccessfully = true;
            }).catch(error => {
                console.log('error in updating the document');
            })
        this.docUploaded = true;
    }

    handlerIsPhotocopy(event) {
        this.isPhotocopy = event.target.checked;
    }
    //handle upload image close
    uploadImageClose() {
        if (!this.docUploadSuccessfully) {
            deleteDocument({ documentId: this.documentRecordId }) //apex method call
                .then(result => {
                    console.log('deleted:', this.documentRecordId);
                })
                .catch(error => {
                    this.tryCatchError = error;
                    this.errorInCatch();
                });
        }
        this.uploadviewdocpopup = false;
        this.dispatchEvent(new CustomEvent('changeflagvalue'));
    }

    // handle Valuation Report button functionality
    handleValuationReport() {
        createDocument({ 'docType' : this.label.ValuationReport, vehicleDetailId: this.vehicleId, applicantId: this.applicantId, loanApplicationId: this.recordid })
            .then(result => {

                this.documentRecordId = result;
                this.showUpload = true;
                this.docType = this.label.ValuationReport;
                this.showPhotoCopy = true;
                this.showDocView = false;
                this.isVehicleDoc = true;
                this.isAllDocType = false;
                this.uploadViewDocFlag = true;
                this.saveDocumentRecord();
            })
            .catch(error => {
                this.tryCatchError = error;
                this.errorInCatch();
            });

    }

    //handle Insurance Policy button functionality
    handleInsurancePolicy() {
        createDocument({ 'docType' : this.label.InsurancePolicy, vehicleDetailId: this.vehicleId, applicantId: this.applicantId, loanApplicationId: this.recordid })
            .then(result => {
                this.documentRecordId = result;
                this.docType = this.label.InsurancePolicy;
                this.showUpload = true;
                this.showPhotoCopy = true;
                this.showDocView = false;
                this.isVehicleDoc = true;
                this.isAllDocType = false;
                this.uploadViewDocFlag = true;
                this.saveDocumentRecord();
            })
            .catch(error => {
                this.tryCatchError = error;
                this.errorInCatch();
            });

    }

    // navigate to valuation page
    navigateToValuationPage() {
        this[NavigationMixin.Navigate]({
            type: 'standard__navItemPage',
            attributes: {
                apiName: 'Vehicle_Valuation'
            }
        });
    }

    // handle valuation decisioning
    handlevaluationDecisioning(event) {
        this.valuationDecisioning = event.detail.value;
    }
    //handle Upload and View Document button functionality
    handleUploadViewDoc() {
        createDocument({  'docType' : 'Upload RC', vehicleDetailId: this.vehicleId, applicantId: this.applicantId, loanApplicationId: this.recordid })
            .then(result => {
                this.documentRecordId = result;
                this.docType = 'Upload RC';
                this.showUpload = true;
                this.showPhotoCopy = true;
                this.showDocView = false;
                this.isVehicleDoc = true;
                this.isAllDocType = false;
                this.uploadViewDocFlag = true;
                this.saveDocumentRecord();
            })
            .catch(error => {
                this.tryCatchError = error;
                this.errorInCatch();
            });

    }

    @api currentStage;
    @track validatioFlag = false;


    handleSave(){
        this.handleSubmit();
    }

    //handle submit functionality
    handleSubmit() {
        console.log('this.valuationPrice ',this.valuationPrice ,'this.ltvEnginge ',this.ltvEnginge ,'this.pricingEngine ',this.pricingEngine);

        if (!this.valuationDecisioning) {
            const evt = new ShowToastEvent({
                title: "Warning",
                message: this.label.valuationDecisioningRequiredMessage,
                variant: 'warning',
            });
            this.dispatchEvent(evt);
        }
        else if (this.valuationDecisioning === 'No') {
            const evt = new ShowToastEvent({
                title: "Warning",
                message: this.label.valuationDecisioningMessage,
                variant: 'warning',
            });
            this.dispatchEvent(evt);
        }
        else if (!this.isTractor && (!this.valuationPrice || !this.ltvEnginge || !this.pricingEngine || (parseInt(this.valuationPrice) == 0))) {
            const evt = new ShowToastEvent({
                title: "Error",
                message: this.label.valPriceLTVPricingEnginerequired,
                variant: 'Error',
            });
            this.dispatchEvent(evt);
        }else if(this.isTractor && ((!this.reportURL) && this.valuerCategory === this.label.mfc)){
            const evt = new ShowToastEvent({
                title: "Error",
                message: 'MFC Valuation report is required!',
                variant: 'Error',
            });
            this.dispatchEvent(evt);
        }else if(this.isTractor && ((!this.valuationPrice) || (parseInt(this.valuationPrice) == 0))){
            const evt = new ShowToastEvent({
                title: "Error",
                message: 'Valuation price is required!',
                variant: 'Error',
            });
            this.dispatchEvent(evt);
        }
        else if (this.insurancePolicyCheckbox == false && this.enableInsuranceSection) {
            this.insurancePolicyPopup = true;

        } else {
            checkValidationBeforeSubmit({ loanApplicationId: this.recordid, vehicleId : this.vehicleId })
                .then(backendResponse => {
                    const wrapperObj = JSON.parse(backendResponse);
                    console.log('wrapperObj : ',wrapperObj);
                    if (wrapperObj.status === true) {
                        let insuranceNumberInput = this.template.querySelector('lightning-input[data-id=insNum]');
                        let insuranceDeclaredValueInput = this.template.querySelector('lightning-input[data-id=insDecVal]');
                        let issuanceDateInput = this.template.querySelector('lightning-input[data-id=issDate]');
                        let expiryDateInput = this.template.querySelector('lightning-input[data-id=expDate]');
                        /*
                           Valustion IDV if the insurance is expiring than it will come to insidee if condition
                           and updating the sub stage then fire event to navigate to next screen.
                           */
                        if (insuranceNumberInput && insuranceDeclaredValueInput && issuanceDateInput && expiryDateInput) {
                            insuranceNumberInput.reportValidity();
                            insuranceDeclaredValueInput.reportValidity();
                            issuanceDateInput.reportValidity();
                            expiryDateInput.reportValidity();

                            if (insuranceNumberInput.validity.valid === true && insuranceDeclaredValueInput.validity.valid === true
                                && issuanceDateInput.validity.valid === true && expiryDateInput.validity.valid === true) {
                                this.validatioFlag = true;
                                const vehicleDetailsFields = {};
                                vehicleDetailsFields[VEHICLE_ID_FIELD.fieldApiName] = this.vehicleId;
                                vehicleDetailsFields[VALUATION_PRICE_FIELD.fieldApiName] = this.valuationPrice;
                                vehicleDetailsFields[VALUATION_REPORTURL_FIELD.fieldApiName] = this.reportURL;
                                vehicleDetailsFields[VALUATION_OverallRemarks_FIELD.fieldApiName] = this.overallRemarks;
                                vehicleDetailsFields[VALUATION_DECISIONING_TYPE_FIELD.fieldApiName] = this.valuationDecisioning;
                                vehicleDetailsFields[INSURANCE_DECLARED_VALUE_FIELD.fieldApiName] = this.insuranceDeclaredValue;
                                vehicleDetailsFields[INSURANCE_TYPE_FIELD.fieldApiName] = this.insuranceType;
                                vehicleDetailsFields[INSURANCE_NUMBER_FIELD.fieldApiName] = this.insuranceNumber;
                                vehicleDetailsFields[INSURANCE_DATE_FIELD.fieldApiName] = this.insuranceDateField;
                                vehicleDetailsFields[INSURANCE_EXPIRY_DATE_FIELD.fieldApiName] = this.insuranceExpiryDate;
                                vehicleDetailsFields[MFC_Valuation_Report_Date.fieldApiName] = this.mfcGenerationDate;  
                                this.updateRecordDetails(vehicleDetailsFields)
                                    .then(() => {
                                        const evt = new ShowToastEvent({
                                            title: 'Success',
                                            message: this.label.vehicledetailsSaved,
                                            variant: 'success',
                                        });
                                        this.dispatchEvent(evt);
                                        if(!this.isTractor){
                                            const fields = {};
                                            fields[ID_FIELD.fieldApiName] = this.recordid;
                                            fields[SUB_STAGE_FIELD.fieldApiName] = this.label.ValuationIDV;
                                            this.updateRecordDetails(fields);
                                            this.dispatchEvent(new CustomEvent('valuationidvevent', { detail: this.label.ValuationIDV }));
                                        }
                                        else{
                                            this.substage = true;
                                            this.recordSaved = true;
                                            this.enableValuationPrice = true;
                                            console.log('Successfully Validated');
                                        }
                                    }).catch(error=>{
                                        const evt = new ShowToastEvent({
                                            title: 'Error',
                                            message: 'Something went wrong!',
                                            variant: 'error',
                                        });
                                        this.dispatchEvent(evt);
                                    });

                            } else if (insuranceNumberInput.validity.valid !== true || insuranceDeclaredValueInput.validity.valid !== true
                                || issuanceDateInput.validity.valid !== true || expiryDateInput.validity.valid !== true) {
                                const evt = new ShowToastEvent({
                                    title: this.label.mandotoryDetailsNotProvide,
                                    variant: 'error',
                                });
                                this.dispatchEvent(evt);
                                return null;
                            }
                        } else {
                            /*
                            Valustion IDV if the insurance is not expiring than it will come to else block 
                            and updating the sub stage then fire event to navigate to next screen.
                            */
                            const vehicleDetailsFields = {};
                            vehicleDetailsFields[VEHICLE_ID_FIELD.fieldApiName] = this.vehicleId;
                            vehicleDetailsFields[VALUATION_PRICE_FIELD.fieldApiName] = this.valuationPrice;
                            vehicleDetailsFields[VALUATION_REPORTURL_FIELD.fieldApiName] = this.reportURL;
                            vehicleDetailsFields[VALUATION_OverallRemarks_FIELD.fieldApiName] = this.overallRemarks;
                            vehicleDetailsFields[VALUATION_DECISIONING_TYPE_FIELD.fieldApiName] = this.valuationDecisioning;
                            vehicleDetailsFields[MFC_Valuation_Report_Date.fieldApiName] = this.mfcGenerationDate;  
                            console.log('vehicleDetailsFields : ',vehicleDetailsFields);
                            this.updateRecordDetails(vehicleDetailsFields)
                                .then(() => {
                                    const evt = new ShowToastEvent({
                                        title: 'Success',
                                        message: this.label.vehicledetailsSaved,
                                        variant: 'success',
                                    });
                                    this.dispatchEvent(evt);

                                    if(!this.isTractor){
                                        const fields = {};
                                        fields[ID_FIELD.fieldApiName] = this.recordid;
                                        fields[SUB_STAGE_FIELD.fieldApiName] = this.label.ValuationIDV;
                                        this.updateRecordDetails(fields);
                                        this.dispatchEvent(new CustomEvent('valuationidvevent', { detail: this.label.ValuationIDV }));
                                    }
                                    else{
                                        this.substage = true;
                                        this.recordSaved = true;
                                        this.enableValuationPrice = true;
                                        console.log('Successfully Validated');
                                    }
                                }).catch(error=>{
                                    const evt = new ShowToastEvent({
                                        title: 'Error',
                                        message: 'Something went wrong!',
                                        variant: 'error',
                                    });
                                    this.dispatchEvent(evt);
                                });
                        }

                        /*
                        If any required document are missing or any failures then this else will be executed.
                        */
                    } else {
                        const evt = new ShowToastEvent({
                            title: 'Error',
                            message: wrapperObj.message,
                            variant: 'error',
                        });
                        this.dispatchEvent(evt);
                    }
                })
        }
    }

    changeflagvalue(event) {
        console.log('event.detail.uploadedDocType : ', JSON.stringify(event.detail.uploadedDocType));
        if (event.detail.uploadedDocType === this.label.RCDocument) {
            this.showRCDocumentPopup = true;
        }
        this.uploadViewDocFlag = false;
    }

    handleRCDocumentPopupOk() {
        this.showRCDocumentPopup = false;
    }

    handleRCDocumentPopupCancel() {
        deleteDocument({ documentId: this.documentRecordId }) //apex method call
            .then(result => {
                console.log('deleted:', this.documentRecordId);
            })
            .catch(error => {
                this.tryCatchError = error;
                this.errorInCatch();
            });
        this.showRCDocumentPopup = false;
    }

    // Handle Valuation Price Okay button functionality
    handleValuationPricePopupOk() {
        this.valuationPricePopup = false;
        this.enableValuationPrice = true;
    }

    // Handle Valuation Price Cancel button functionality
    handleValuationPricePopup() {
        this.valuationPricePopup = false;
    }

    // Handle Insured Delclared Value Popup Okay button functionality
    handleInsuredDelclaredValuePopupOk() {
        this.insuredDelclaredValuePopup = false;
        this.enableInsuranceDeclared = true;
    }

    // Handle Insured Delclared Value Popup Cancel button functionality
    handleInsuredDelclaredValuePopupCancel() {
        this.insuredDelclaredValuePopup = false;
    }

    //handle Insurance Policy okay button functionality
    handleInsurancePolicyCmpOk() {
        this.insurancePolicyCheckbox = true;
        this.insurancePolicyPopup = false;
        this.handleSubmit();
    }

    //handle MFC Valuation Report button functionality
    handleMFCValuationReport() {
        console.log('mfc report triggered');
        if (this.valuerCategory === this.label.mfc && (this.valuationPrice === null || this.valuationPrice == 0 || (!this.reportURL && this.isTractor))) {
            let leadRecordNo;//CISP-3590
            if(this.isRevokedApp == true && this.parentLeadNo != null){
                leadRecordNo = this.parentLeadNo;
            }else{
                leadRecordNo = this.leadNumber;
            }//CISP-3590
            const requestWrapper = {
                'loanApplicationId': this.recordid,//'00671000001AGR7',//
                'leadId': leadRecordNo,//'AC5202693_02154883293',//
                'vehicleRegisterationNumber': this.vehicleRegNoValue//'TN99U6312'//
            }
            console.log('mfc report triggered',requestWrapper);
            //Calling MFC Fetch valuation report API
            doMFCFetchValuationReportCallout({ mfcValuationReportRequestString: JSON.stringify(requestWrapper) })
                .then(result => {
                    const res = JSON.parse(result);
                    console.log('response==>', res);
                    if (res.response.status === 'SUCCESS') {
                        this.valuationPrice = parseFloat(res.response.content[0].Valuation_Price).toFixed(2);
                        this.reportGenerated = res.response.content[0].ReportGenerated;
                        this.reportURL = res.response.content[0].ReportURL;
                        this.overallRemarks = res.response.content[0].Overall_Remarks;
                        this.mfcGenerationDate = new Date();
                        this.isValuerCategory = true;
                        if (res.response.content[0].ReportGenerated === 'Yes') {
                            const event = new ShowToastEvent({
                                title: 'Success',
                                message: this.label.mcfSuccessResponse,
                                variant: 'success',
                            });
                            this.dispatchEvent(event);
                        }
                        //CISP-3609 start
                        if (this.valuerCategory === this.label.mfc && this.valuationPrice == 0) {
                            this.valuationPrice = '';
                            this.disableValuationReport = false;
                            const event = new ShowToastEvent({
                                title: 'Info',
                                message: 'Valuation is not completed by MFC. Please click View Valuation fetch API button',
                                variant: 'Info',
                                mode:'sticky',
                            });
                            this.dispatchEvent(event);
                        }//CISP-3609 end
                        const vehicleDetailsFields = {};
                        vehicleDetailsFields[VEHICLE_ID_FIELD.fieldApiName] = this.vehicleId;
                        vehicleDetailsFields[VALUATION_PRICE_FIELD.fieldApiName] = this.valuationPrice;
                        vehicleDetailsFields[VALUATION_REPORTURL_FIELD.fieldApiName] = this.reportURL;
                        vehicleDetailsFields[VALUATION_OverallRemarks_FIELD.fieldApiName] = this.overallRemarks;
                        vehicleDetailsFields[VALUATION_DECISIONING_TYPE_FIELD.fieldApiName] = this.valuationDecisioning;                          
                        vehicleDetailsFields[MFC_Valuation_Report_Date.fieldApiName] = this.mfcGenerationDate;  
                        console.log('vehicleDetailsFields : ',vehicleDetailsFields);
                        this.updateRecordDetails(vehicleDetailsFields)
                            .then(() => {
                               /* const evt = new ShowToastEvent({
                                    title: 'Success',
                                    message: this.label.vehicledetailsSaved,
                                    variant: 'success',
                                });
                                this.dispatchEvent(evt);*/
                            })
                    }
                    else {
                        console.log('MFC API failure response');
                        const event = new ShowToastEvent({
                            title: 'Error',
                            message: 'API response fail',
                            variant: 'error',
                        });
                        this.dispatchEvent(event);
                    }
                })
                .catch(error => {
                    console.log("Error came in MFC API : " + error);
                    console.log(error);
                });

        }
        //navigate report url in next tab
        if ((this.valuationPrice !== null  && this.valuationPrice != '' ) && (this.reportURL !== null && this.reportURL != '')) {
            this.navigateToReportURL();
        }


    }
    //Handle navigate report url in next tab
    navigateToReportURL() {
        const vehicleDetailsFields = {};
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: this.reportURL
            }
        });
    }

    //handle input field change
    handleInputFieldChange(event) {
        const fieldName = event.target.name;
        if (fieldName === 'make') {
            this.makeValue = event.target.value;
        } else if (fieldName === 'valuationPrice') {
            this.valuationPrice = event.target.value;;
            this.valuationPricePopup = true;
        } else if (fieldName === 'valuationDecisioning') {
            this.valuationDecisioning = event.target.value;;
        } else if (fieldName === 'chassisNumberField') {
            this.chassisNumber = event.target.value;
        } else if (fieldName === 'engineNumberField') {
            this.engineNumber = event.target.value;
        } else if (fieldName === 'vehicleRegNoValueField') {
            this.vehicleRegNoValue = event.target.value;
        } else if (fieldName === 'variantField') {
            this.variant = event.target.value;
        } else if (fieldName === 'modelField') {
            this.model = event.target.value;
        } else if (fieldName === 'vehicleTypeField') {
            this.vehicleType = event.target.value;
        }
    }
}