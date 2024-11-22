// Screen created By : Vinita K
// Screen Name: 'LWC_LOS_VehicleInsurance'
// Description : Vehicle Insurance details will capture in this module.
// created on: 30 Nov 2021

import { LightningElement, wire, api, track } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import LightningCardApplyCSS from '@salesforce/resourceUrl/loanApplication';
import { getPicklistValues ,getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getRecord,updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import loadVehicleInsuranceDetails from '@salesforce/apex/IND_LWC_VehicleInsuranceCntrl.loadVehicleInsuranceDetails';
import insertAllVehicleDetailForTractor from '@salesforce/apex/IND_LWC_VehicleInsuranceCntrl.insertAllVehicleDetailForTractor';
import checkCountOfContentDoc from '@salesforce/apex/LwcLOSLoanApplicationCntrl.checkCountOfContentDoc';
import checkCountOfContentDocTractor from '@salesforce/apex/LwcLOSLoanApplicationCntrl.checkCountOfContentDocTractor';
import vehicleInsuranceDetails from '@salesforce/label/c.vehicleInsuranceDetails';
import captureVehicleDocuments from '@salesforce/label/c.captureVehicleDocuments';
import vehicledetailsSaved from '@salesforce/label/c.Vehicle_Valuation_Details_Saved';
import Borrower from '@salesforce/label/c.Borrower';
import CoBorrower from '@salesforce/label/c.CoBorrower';
import InsurancePolicy from '@salesforce/label/c.InsurancePolicy';
import VehicleImage from '@salesforce/label/c.VehicleImage';
import journeyStop from '@salesforce/label/c.Journey_stop';
import RC_Copy from '@salesforce/label/c.RC_Copy';
import OPP_ID_FIELD from '@salesforce/schema/Opportunity.Id';
import STAGENAME from '@salesforce/schema/Opportunity.StageName';
import EXISTING_MOTOR_INSURANCE_PREMIUM from '@salesforce/schema/Opportunity.Existing_Motor_Insurance_Premium__c';
import LAST_STAGE_NAME from '@salesforce/schema/Opportunity.LastStageName__c';
import JOURNEY_STATUS_FIELD from '@salesforce/schema/Opportunity.Journey_Status__c';
import createDocument from '@salesforce/apex/IND_DocumentUploadCntrl.createDocument';
import VEHICLE_DETAIL_OBJECT from '@salesforce/schema/Vehicle_Detail__c';
import VEHICLE_ID_FIELD from '@salesforce/schema/Vehicle_Detail__c.Id';
import OPPORTUNITY_VEHICLE_FIELD from '@salesforce/schema/Vehicle_Detail__c.Loan_Application__c';
import INSURER_NAME_FIELD from '@salesforce/schema/Vehicle_Detail__c.Insurer_name__c';
import INSURANCE_TYPE_FIELD from '@salesforce/schema/Vehicle_Detail__c.Insurance_type__c';
import INSURANCE_NUMBER_FIELD from '@salesforce/schema/Vehicle_Detail__c.Insurance_number__c';
import INSURANCE_DECLARED_VALUE_FIELD from '@salesforce/schema/Vehicle_Detail__c.Insurance_declared_value__c';
import INSURANCE_AVAILABLE_FIELD from '@salesforce/schema/Vehicle_Detail__c.Insurance_Available__c';
import INSURANCE_DATE_FIELD from '@salesforce/schema/Vehicle_Detail__c.Ins_Issuance_date__c';
import INSURANCE_EXPIRY_DATE_FIELD from '@salesforce/schema/Vehicle_Detail__c.Ins_Expiry_date__c';
import mandotoryDetailsNotProvide from '@salesforce/label/c.Mandotory_details_are_not_given_Please_provide';
import INSURANCE_EXPIRY_CHECKBOX from '@salesforce/schema/Vehicle_Detail__c.Insurance_expiring_within_60_days__c';
import isCommunity from '@salesforce/apex/LwcLOSLoanApplicationCntrl.isCommunity';
import docCustomerImage from '@salesforce/apex/LwcLOSLoanApplicationCntrl.createOtherDocument';
import docCustomerImageTractorVehicle from '@salesforce/apex/LwcLOSLoanApplicationCntrl.createOtherDocumentForTractorVehile';
import fetchDocument from '@salesforce/apex/Ind_IncomeDetailsCtrl.fetchDocument';
import fetchDocumentTractorVehicle from '@salesforce/apex/Ind_IncomeDetailsCtrl.fetchDocumentTractorVehicle';
import getApplicantId from '@salesforce/apex/Utilities.getApplicantId';
import checkImageExist from '@salesforce/apex/Ind_IncomeDetailsCtrl.checkImageExist';
import checkImageExistForTractorCase from '@salesforce/apex/Ind_IncomeDetailsCtrl.checkImageExistForTractorCase';
import FORM_FACTOR from '@salesforce/client/formFactor';
import ReadOnlyLeadAccess from '@salesforce/label/c.ReadOnlyLeadAccess';
import getLoanApplicationHistory from '@salesforce/apex/LwcLOSLoanApplicationCntrl.getLoanApplicationHistory';
import accessLoanApplication from '@salesforce/apex/LwcLOSLoanApplicationCntrl.accessLoanApplication';
import Regex_NumberOnly from '@salesforce/label/c.Regex_NumberOnly';

export default class LWC_LOS_VehicleInsurance extends NavigationMixin(LightningElement) {

    label = {
        vehicleInsuranceDetails,
        captureVehicleDocuments,
        vehicledetailsSaved,
        Borrower,
        CoBorrower,
        InsurancePolicy,
        VehicleImage,
        RC_Copy,
        mandotoryDetailsNotProvide,
        journeyStop,
        Regex_NumberOnly
    }
    
    //prashanth
    @api isD2cApplication;
    @api isRevokedLoanApplication;
    @track createdoconparentbutton = false;
    
    
    @api checkleadaccess;//coming from tabloanApplication
    @api recordid;
    @track isEnableNext = false;
    @api applicantId;
    @api uploadViewDocFlag;
    @track isStepOne = false;
    @track isStepTwo = false;
    @track currentStep = this.label.vehicleInsuranceDetails;
    @track isEnableUploadViewDoc = true;
    @track isEnablePrev = false;
    @track isEnableSaveAndExit = false;
    @api activeTab;
    @track tabList = [];
    @track isBorrower = true;
    @track tryCatchError = '';
    @track documentRecordId;
    @track insuranceType = '';
    @track insurerName = '';
    @track insuranceNumber = '';
    @track insuranceDeclaredValue = '';
    @track insuranceDateField;
    @track insuranceExpiryDate;
    @track insuranceExpiryCheckbox = false;
    @track currentDate;
    @track showVehicleInsurance = true;
    @track navToVehicleValuation = false;
    @track captureVehicleInsuranceDisabled = false;
    @track lastStage;
    @track currentStageName;
    @track showFileUploadAndView = false;
    @track fromHome= false;
    @track insuranceAvailable = false;
    @track allVehicleDetails = []; 
    @track isProductTypeTractor = false;
    @track documentRecordIdForTractorVehicle;
    @track tractorVehicleId = null;
    @track documentUplodedOnIndex;
    existingMotorInsurancePremium;
    isPv = false;

    get isStepOne() {
        return this.currentStep === this.label.vehicleInsuranceDetails;
    }

    get isEnablePrev() {
        return this.currentStep !== this.label.vehicleInsuranceDetails;
    }

    get isEnableSaveAndExit() {
        return this.currentStep !== this.label.vehicleInsuranceDetails;
    }

    @wire(getObjectInfo, { objectApiName: VEHICLE_DETAIL_OBJECT })
    opportunityMetaData;

    @wire(getPicklistValues,
        {
            recordTypeId: '$opportunityMetaData.data.defaultRecordTypeId',
            fieldApiName: INSURANCE_TYPE_FIELD
        }        
    )
    insuranceTypeValues;
    isSpinnerMoving = false;
    async init(){
        console.log('record id and active tab ', this.recordid, this.activeTab);
        const currentApplicantId = await getApplicantId({
            opportunityId: this.recordid,
            applicantType: this.activeTab,
        })
        this.applicantId = currentApplicantId;
        console.log(' fetched current applicant id =>' , this.applicantId);
    }

    //CISP-15702 Start
    @wire(getRecord, { recordId: '$recordid', fields: ['Opportunity.UploadAndViewDocDisable__c']})
    wireOpportunityRec;
    get isUploadViewDisabled(){
        return this.wireOpportunityRec.data ? this.wireOpportunityRec.data.fields.UploadAndViewDocDisable__c.value : false;
    }
    //CISP-15702 End
    
    async connectedCallback() {
        this.isSpinnerMoving = true;
        await this.init();
        await fetchDocument({ 'applicantId': this.applicantId, 'docType': 'Vehicle Insurance Policy' }).then(result => {
            if(result){
                try {
                    this.documentRecordId = result;
                    checkCountOfContentDoc({'docId':this.documentRecordId}).then(response=>{
                        if(response == true){
                            this.captureVehicleInsuranceDisabled=true;
                            this.tickCaptureInsurancePolicy=true;
                            this.isSpinnerMoving = false;
                        }else{
                            this.isSpinnerMoving = false;
                        }
                    }).catch(error=>{
                        this.isSpinnerMoving = false;
                    });
                } catch (error) {
                    console.log(error);
                    this.isSpinnerMoving = false;
                }    
            } else{
                this.isSpinnerMoving = false;
            }           
        }).catch(error=>{
            this.isSpinnerMoving = false;
        });
        console.log('This.recordId -> ' + this.recordid , ' current applicant id =>' , this.vehicleDetailId);
        await loadVehicleInsuranceDetails({ loanApplicationId: this.recordid, 'applicantId': this.applicantId })
            .then(response => {
                let result = JSON.parse(response);
                let count = 0;
                if(result.length > 0){
                    if(result[0].productType !== 'Tractor'){
                        this.isProductTypeTractor = false;
                this.vehicleDetailId = result[0].vehicleDetailId;
                this.insurerName = result[0].insurerName;
                this.insuranceType = result[0].insuranceType;
                this.insuranceNumber = result[0].insuranceNumber;
                this.insuranceDeclaredValue = result[0].insuranceDeclaredValue;
                this.insuranceDateField = result[0].insIssuanceDate;
                this.insuranceExpiryDate = result[0].insExpiryDate;
                this.insuranceExpiryCheckbox = result[0].isInsuranceExpired;
                this.lastStage = result[0].lastStage;
                this.currentStageName = result[0].currentStageName;
            }
            else{
                this.isProductTypeTractor = true;
                this.lastStage = result[0].lastStage;
                this.currentStageName = result[0].currentStageName;
                result.forEach(item =>{
                    count++;
                    item.accordionLabel = 'Insurance ('+ item.vehicleAccordianLabel+ ')';
                });
                this.allVehicleDetails = result;
                this.allVehicleDetails = result.map(vehicle => ({
                    ...vehicle,
                    isDisabled: true
                }));
                }
            }
                this.isPv = result[0].productType && result[0].productType == 'Passenger Vehicles' ? true : false;
                this.existingMotorInsurancePremium = result[0].existingMotorInsurancePremium;

                if (this.currentStep === this.label.vehicleInsuranceDetails) {
                    this.isStepOne = true;
                    this.isEnablePrev = false;
                    this.isEnableSaveAndExit = false;
                } else if (this.currentStep === this.label.captureVehicleDocuments) {
                    this.isStepTwo = true;
                    this.isEnablePrev = true;
                    this.isEnableSaveAndExit = true;
                }
            })
            .catch(error => {
                this.tryCatchError = error;
                //this.errorInCatch();//commented cz throwing error for error.body.message
            });  
        this.callAccessLoanApplication();
    }

    handleOnfinish(event) {
        console.log('entered');
        const evnts = new CustomEvent('vehiclevaleve', { detail: event });
        this.dispatchEvent(evnts);
        //this.template.querySelector('c-i-N-D_-L-W-C_-View-Application-Data').submit(event);
    }
    renderedCallback() {
        loadStyle(this, LightningCardApplyCSS);
        if (this.currentStage === 'Credit Processing'|| this.currentStageName === 'Loan Initiation' || this.currentStageName === 'Additional Details' || this.currentStageName === 'Asset Details' || (this.currentStageName != undefined && this.currentStageName !== 'Vehicle Insurance' && this.lastStage !== 'Vehicle Insurance' && this.lastStage != undefined)) {////CISP-519
            this.disableEverything();
            if (this.currentStage === 'Credit Processing'){
                this.isEnableNext = true;
                if (this.template.querySelector('.next')) { this.template.querySelector('.next').disabled = false; }
            }
        }
        //prashanth
        if(this.isD2cApplication && this.currentStageName !== undefined && this.currentStageName != 'Vehicle Insurance' && this.lastStage != 'Vehicle Insurance'){
            this.disableEverything();
        }
        if(this.isRevokedLoanApplication){this.disableEverything();}
    }
    errorInCatch() {
        const evt = new ShowToastEvent({
            title: "Error",
            message: this.tryCatchError.body.message,
            variant: 'Error',
        });
        this.dispatchEvent(evt);
    }
    async updateRecordDetails(fields) {
        try {
            console.log('fields ', fields);
            const recordInput = { fields };
            console.log('recordInput ', recordInput);
            await updateRecord(recordInput)
                .then(() => {
                    console.log('Inside then');
                })
                .catch(error => {
                    console.log('Inside catch');
                });
        } catch (error) {
            console.log('error ', error);
        }

    }
    handleInsuranceNumber() {
        let insuranceNumberInput = this.template.querySelector('lightning-input[data-id=insNum]');
        let insuranceNumber = insuranceNumberInput.value;
        this.insuranceNumber = insuranceNumber;
        insuranceNumberInput.reportValidity();
    }
    handleExistingMotorInsPre(){
        let ExistingMIpInput = this.template.querySelector('lightning-input[data-id=exiMip]');
        let existingMotorInsurancePremiumInput = ExistingMIpInput.value;
        this.existingMotorInsurancePremium = existingMotorInsurancePremiumInput;
        ExistingMIpInput.reportValidity();
    }
    handleInsuranceName() {
        let insurerNameInput = this.template.querySelector('lightning-input[data-id=insName]');
        let insurerName = insurerNameInput.value;
        this.insurerName = insurerName;
        insurerNameInput.reportValidity();
    }
    handleInsuranceDeclaredValue() {
        let insuranceDeclaredValueInput = this.template.querySelector('lightning-input[data-id=insDecVal]');
        let insuranceDeclaredValue = insuranceDeclaredValueInput.value;
        this.insuranceDeclaredValue = insuranceDeclaredValue;
        insuranceDeclaredValueInput.reportValidity();
    }
    handleChange(event){
        const fieldName = event.target.dataset.fieldname;
        const index = parseInt(event.target.dataset.index, 10);
        if (fieldName === 'insuranceAvailable') {
            const newToggleValue = !this.allVehicleDetails[index][fieldName]; 
            this.allVehicleDetails[index][fieldName] = newToggleValue;
            this.allVehicleDetails[index].isDisabled = !newToggleValue;
            // Clear all fields if insuranceAvailable is toggled to NO
            if (!newToggleValue && this.isProductTypeTractor) {
                this.allVehicleDetails[index].insuranceNumber = '';
                this.allVehicleDetails[index].insurerName = '';
                this.allVehicleDetails[index].insuranceType = '';
                this.allVehicleDetails[index].insuranceDeclaredValue = 0;
                this.allVehicleDetails[index].insIssuanceDate = '';
                this.allVehicleDetails[index].insExpiryDate = '';
            }
        }
        else if(event.target.dataset.fieldname === 'insuranceDateField'){
            this.template.querySelectorAll('lightning-input[data-id=expDate]')[event.target.dataset.index].reportValidity();
            this.allVehicleDetails[event.target.dataset.index][event.target.dataset.fieldname] = event.target.value;

            var differenceInExpDays = ((new Date(this.allVehicleDetails[event.target.dataset.index]['insuranceExpiryDate'])).getTime() - (new Date(this.allVehicleDetails[event.target.dataset.index][event.target.dataset.fieldname])).getTime()) / (1000 * 3600 * 24);
            var today = new Date();
            var differenceInDays = (today.getTime() - (new Date(this.allVehicleDetails[event.target.dataset.index][event.target.dataset.fieldname])).getTime()) / (1000 * 3600 * 24);

            if(this.allVehicleDetails[event.target.dataset.index]['insuranceExpiryDate'] !==null && differenceInExpDays < 0 ){
                event.target.setCustomValidity('Date should not be greater than expiry date');
            } else if (differenceInDays < 0) {
                event.target.setCustomValidity('Date should be less than current date');
            } else{
                event.target.setCustomValidity('');
            } 
            if(this.isProductTypeTractor){ //SFTRAC-660
                var expirydt = new Date();
                var issdt = new Date();
                issdt = new Date(event.target.value);
                issdt = issdt.setDate((issdt).getDate()+ 364);
                console.log('date-----'+new Date(issdt).toISOString().split('T')[0]);
                this.template.querySelectorAll('lightning-input[data-id=expDate]')[event.target.dataset.index].value = new Date(issdt).toISOString().split('T')[0];
                this.allVehicleDetails[event.target.dataset.index]['insuranceExpiryDate'] = new Date(issdt).toISOString().split('T')[0];
                console.log('expirydate-----'+this.allVehicleDetails[event.target.dataset.index]['insuranceExpiryDate']);
                var today = new Date();
                today.setDate(today.getDate());
                differenceInDays = (((new Date(issdt)) / (1000 * 60 * 60 * 24)) % 1890) - ((today / (1000 * 60 * 60 * 24)) % 1890);
                if ((differenceInDays <= 90 && differenceInDays > 0) || ((new Date(issdt)) < today)) {
                this.allVehicleDetails[event.target.dataset.index]['insuranceExpiryCheckbox'] = true;
                }
                else {
                    this.allVehicleDetails[event.target.dataset.index]['insuranceExpiryCheckbox'] = false;
                }
            } 
            event.target.reportValidity();
        }
        else if(event.target.dataset.fieldname === 'insuranceExpiryDate'){
            event.target.reportValidity();
            this.allVehicleDetails[event.target.dataset.index][event.target.dataset.fieldname] = event.target.value;

            var today = new Date();
            var inputCmp = this.template.querySelector('lightning-input[data-id=kycIssuaceDateId]');
            this.currentDate = today;
            today.setDate(today.getDate() + 60);
            differenceInDays = ((today / (1000 * 60 * 60 * 24)) % 1890) - (((new Date(this.allVehicleDetails[event.target.dataset.index][event.target.dataset.fieldname])) / (1000 * 60 * 60 * 24)) % 1890);

            if (differenceInDays <= 60 && differenceInDays > 0 || (new Date(this.allVehicleDetails[event.target.dataset.index][event.target.dataset.fieldname])) < today) {
                this.allVehicleDetails[event.target.dataset.index]['insuranceExpiryCheckbox'] = true;
            } else {
                this.allVehicleDetails[event.target.dataset.index]['insuranceExpiryCheckbox'] = false;
            }
        }
        else{   
            this.allVehicleDetails[event.target.dataset.index][event.target.dataset.fieldname] = event.target.value;
        }
    }
    handleIssuanceDate() {
        let issuanceDateInput = this.template.querySelector('lightning-input[data-id=issDate]');
        let insuranceDateField = issuanceDateInput.value;
        this.insuranceDateField = insuranceDateField;
        issuanceDateInput.reportValidity();

        let expiryDateInput = this.template.querySelector('lightning-input[data-id=expDate]');
        let expiryDateField = expiryDateInput.value;
        this.expiryDateField = expiryDateField;
        expiryDateInput.reportValidity();

        var differenceInExpDays = ((new Date(this.expiryDateField)).getTime() - (new Date(this.insuranceDateField)).getTime()) / (1000 * 3600 * 24);
        console.log('Check Difference ::',differenceInExpDays);
        var today = new Date();
        var differenceInDays = (today.getTime() - (new Date(this.insuranceDateField)).getTime()) / (1000 * 3600 * 24);

        if(this.expiryDateField !==null && differenceInExpDays < 0 ){
            issuanceDateInput.setCustomValidity('Date should not be greater than expiry date');
        } else if (differenceInDays < 0) {
            issuanceDateInput.setCustomValidity('Date should be less than current date');
        } else{
            issuanceDateInput.setCustomValidity('');
        }
    }
    handleExpiryDate() {
        var differenceInDays = -1;
        let expiryDateInput = this.template.querySelector('lightning-input[data-id=expDate]');
        let insuranceExpiryDate = expiryDateInput.value;
        this.insuranceExpiryDate = insuranceExpiryDate;
        expiryDateInput.reportValidity();
        //check if entered date is within 60 days
        var today = new Date();
        var inputCmp = this.template.querySelector('lightning-input[data-id=kycIssuaceDateId]');
        this.currentDate = today;
        let maxDays = 60;
        if(this.isPv){
            maxDays = 90;
        }
        today.setDate(today.getDate() + maxDays);
        console.log('hi' + this.insuranceExpiryDate);
        console.log('hi2' + this.insuranceDateField);
        differenceInDays = ((today / (1000 * 60 * 60 * 24)) % 1890) - (((new Date(this.insuranceExpiryDate)) / (1000 * 60 * 60 * 24)) % 1890);
        // diffWithDOB =  (((new Date(this.insuranceExpiryDate))/ (1000 * 60 * 60 * 24)) % 1890) - ((new Date(this.insuranceDateField))/(1000 * 60 * 60 * 24)) % 1890;
        //          //(((new Date(this.insuranceDateField)).getTime())/ (1000 * 60 * 60 * 24)) % 1890);
        // //Check if Insurance expiry date is within or equal 60 or already expired
        // console.log('hi3' + diffWithDOB);
        // if (differenceInDays < 0) {
        //     console.log('afGFDZn1509');  
        //     inputCmp.setCustomValidity('Date should be less than current date');
        // } else if(diffWithDOB > 0 || diffWithDOB == 0) {
        //     inputCmp.setCustomValidity('Date should be greater than DOB');
        // } else {
        //     inputCmp.setCustomValidity('');
        // }

        if (differenceInDays <= maxDays && differenceInDays > 0 || (new Date(this.insuranceExpiryDate)) < today) {
            this.insuranceExpiryCheckbox = true;
        } else {
            this.insuranceExpiryCheckbox = false;
        }
    }
    handleInsurancePolicy(event) {
        if(this.isProductTypeTractor){
            this.documentRecordIdForTractorVehicle = event.target.dataset.documentid;
            this.tractorVehicleId = event.target.dataset.vehicleid;
            this.documentUplodedOnIndex = event.target.dataset.index;
        }
        this.createdoc('Vehicle Insurance Policy');
    }
    async createdoc(docTypevar) {
        try{

            if(!this.isProductTypeTractor){
            if(FORM_FACTOR==='Large'){
                let result = await checkCountOfContentDoc({'docId':this.documentRecordId});
                if(this.documentRecordId != null && result == false){
                    this.allowSubmit = true;
                    this.docType = docTypevar;
                    this.showUpload = true;
                    this.showDocView = false;
                    this.isVehicleDoc = true;
                    this.isAllDocType = false;
                    this.uploadViewDocFlag = true;
                }else{
                    docCustomerImage({ 'docType': docTypevar, 'applicantId': this.applicantId, 'loanApplicationId': this.recordid })
                    .then(result => {
                        if(result){
                                this.documentRecordId = result;
                                console.log('docTypevar ', docTypevar);
                                this.allowSubmit = true;
                                this.docType = docTypevar;
                                this.showUpload = true;
                                this.showDocView = false;
                                this.isVehicleDoc = true;
                                this.isAllDocType = false;
                                this.uploadViewDocFlag = true;
                            }
                        })
                        .catch(error => {
                            this.error = error;
                        });
    
                    }
                }
                else if(FORM_FACTOR !='Large'){
                    fetchDocument({ applicantId: this.applicantId, docType: docTypevar }).then(result => {
                        if(result===null){
                            this.documentRecordId = result;
                            this.allowSubmit = true;
                            this.docType = docTypevar;
                            this.showUpload = true;
                            this.showDocView = false;
                            this.isVehicleDoc = true;
                            this.isAllDocType = false;
                            this.uploadViewDocFlag = true;
                        }else{
                            this.showToast('Warning','Document is already Captured', 'warning');
                        }
                    })
                    .catch(error => {
                        this.error = error;
                    });

                }
            }
            else{
                if(FORM_FACTOR==='Large'){
                    let result = await checkCountOfContentDoc({'docId':this.documentRecordIdForTractorVehicle});
                    if(this.documentRecordIdForTractorVehicle != null && result == false){
                        this.allowSubmit = true;
                        this.docType = docTypevar;
                        this.showUpload = true;
                        this.showDocView = false;
                        this.isVehicleDoc = true;
                        this.isAllDocType = false;
                        this.uploadViewDocFlag = true;
                    }else{
                        docCustomerImageTractorVehicle({ 'docType': docTypevar, 'applicantId': this.applicantId, 'loanApplicationId': this.recordid, 'vehicleId': this.tractorVehicleId})
                        .then(result => {
                            if(result){
                                this.documentRecordIdForTractorVehicle = result;
                                console.log('docTypevar ', docTypevar);
                                this.allowSubmit = true;
                                this.docType = docTypevar;
                                this.showUpload = true;
                                this.showDocView = false;
                                this.isVehicleDoc = true;
                                this.isAllDocType = false;
                                this.uploadViewDocFlag = true;
                            }
                        })
                        .catch(error => {
                            this.error = error;
                        });
                    }
                }else if(FORM_FACTOR !='Large'){
                    fetchDocumentTractorVehicle({ applicantId: this.applicantId, docType: docTypevar,  'vehicleId':  this.tractorVehicleId }).then(result => {
                        if(result===null){
                            this.documentRecordIdForTractorVehicle = result;
                            this.allowSubmit = true;
                            this.docType = docTypevar;
                            this.showUpload = true;
                            this.showDocView = false;
                            this.isVehicleDoc = true;
                            this.isAllDocType = false;
                            this.uploadViewDocFlag = true;
                            this.createdoconparentbutton = true;
                        }else{
                            this.showToast('Warning','Document is already Captured', 'warning');
                        }
                    }).catch(error => {
                        console.log('handleInsurancePolicy Error:: ',error);
                    });
                }
            }
        }catch(error){
            console.log('error ', error);
        }    
    }
       
    async changeflagvalue(event) {
        this.uploadViewDocFlag = false;
        if(!this.isProductTypeTractor){
        let result = await checkCountOfContentDoc({'docId':this.documentRecordId});
        if(result == true){this.captureVehicleInsuranceDisabled=true;this.tickCaptureInsurancePolicy=true;}
        if(FORM_FACTOR!='Large'){
            checkImageExist({ applicantId: this.applicantId, documentType : this.label.InsurancePolicy }).then(response => {
                if(response===false){
                    this.showToast('','Document Upload Fail','warning');
                }else if(response===true){
                    this.captureVehicleInsuranceDisabled = true;
                    this.tickCaptureInsurancePolicy =  true;
                    this.showToast('Success',this.docType + ' Document captured successfully', 'success');
                }
            }).catch(error => {
                console.log('checkImagePresent error:',error);
            });
        }
    }
    else{
        let result = await checkCountOfContentDoc({'docId':this.documentRecordIdForTractorVehicle});
        if(result == true){
            this.allVehicleDetails[this.documentUplodedOnIndex].istickCaptureInsurancePolicy = true;
            this.allVehicleDetails[this.documentUplodedOnIndex].isCaptureInsuranceAvailable = true;
        }
        if(FORM_FACTOR!='Large'){
            checkImageExistForTractorCase({ vehicleId: this.tractorVehicleId, documentType : this.label.InsurancePolicy }).then(response => {
                if(response===false){
                    this.showToast('','Document Upload Fail','warning');
                }else if(response===true){
                    this.allVehicleDetails[this.documentUplodedOnIndex].istickCaptureInsurancePolicy = true;
                    this.allVehicleDetails[this.documentUplodedOnIndex].isCaptureInsuranceAvailable = true;
                    this.showToast('Success',this.docType + ' Document captured successfully', 'success');
                }
            }).catch(error => {
                console.log('checkImagePresent error:',error);
            });
        }
    }
}
    handleSaveAndExit() {
        let insuranceNumberInput = this.template.querySelector('lightning-input[data-id=insNum]');
        let insurerNameInput = this.template.querySelector('lightning-input[data-id=insName]');
        let insuranceTypeInput = this.template.querySelector('lightning-input[data-id=insDecVal]');
        let insuranceDeclaredValueInput = this.template.querySelector('.insType');
        let issuanceDateInput = this.template.querySelector('lightning-input[data-id=issDate]');
        let expiryDateInput = this.template.querySelector('lightning-input[data-id=expDate]');
        let existingMotorIns;
        if(this.isPv){
            existingMotorIns = this.template.querySelector('lightning-input[data-id=exiMip]');
            existingMotorIns.reportValidity();
        }
        insuranceNumberInput.reportValidity();
        insurerNameInput.reportValidity();
        insuranceTypeInput.reportValidity();
        insuranceDeclaredValueInput.reportValidity();
        issuanceDateInput.reportValidity();
        expiryDateInput.reportValidity();

        if (insuranceNumberInput.validity.valid === true && insurerNameInput.validity.valid === true && insuranceTypeInput.validity.valid === true && insuranceDeclaredValueInput.validity.valid === true && issuanceDateInput.validity.valid === true && expiryDateInput.validity.valid === true) {
            const vehicleDetailsFields = {};
            vehicleDetailsFields[VEHICLE_ID_FIELD.fieldApiName] = this.vehicleDetailId;
            vehicleDetailsFields[INSURER_NAME_FIELD.fieldApiName] = this.insurerName;
            vehicleDetailsFields[INSURANCE_TYPE_FIELD.fieldApiName] = this.insuranceType;
            vehicleDetailsFields[INSURANCE_NUMBER_FIELD.fieldApiName] = this.insuranceNumber;
            vehicleDetailsFields[INSURANCE_DECLARED_VALUE_FIELD.fieldApiName] = this.insuranceDeclaredValue;
            vehicleDetailsFields[INSURANCE_DATE_FIELD.fieldApiName] = this.insuranceDateField;
            vehicleDetailsFields[INSURANCE_EXPIRY_DATE_FIELD.fieldApiName] = this.insuranceExpiryDate;
            vehicleDetailsFields[INSURANCE_EXPIRY_CHECKBOX.fieldApiName] = this.insuranceExpiryCheckbox;
            this.updateRecordDetails(vehicleDetailsFields)
                .then(() => {
                    const evt = new ShowToastEvent({
                        title: "Success",
                        message: this.label.mandotoryDetailsNotProvide,
                        variant: 'success',
                    });
                    this.dispatchEvent(evt);
                })
                .catch(error => {
                    this.tryCatchError = error;
                    this.errorInCatch();
                });
            //Navigate to Home Screen
            this.navigateToHomePage();

        } else if (insuranceNumberInput.validity.valid !== true || insurerNameInput.validity.valid !== true || insuranceTypeInput.validity.valid !== true || insuranceDeclaredValueInput.validity.valid !== true || issuanceDateInput.validity.valid !== true || expiryDateInput.validity.valid !== true || (this.isPv && existingMotorIns.validity.valid !== true)) {
            const evt = new ShowToastEvent({
                title: this.label.mandotoryDetailsNotProvide,
                variant: 'error',

            });
            this.dispatchEvent(evt);
            return null;
        }
        return true;
    }
    navigateToHomePage() {
        this[NavigationMixin.Navigate]({
            type: 'standard__navItemPage',
            attributes: {
                apiName: 'IndusInd_Home'
            }
        });
    }
    navigateToValuationPage() {
        this[NavigationMixin.Navigate]({
            type: 'standard__navItemPage',
            attributes: {
                apiName: 'Vehicle_Valuation'
            }
        });
    }
    handleInsuranceType(event) {
        this.insuranceType = event.detail.value;
    }
    handleUploadViewDoc() {
        this.showUpload = true;
        this.showPhotoCopy = false;
        this.showDocView = true;
        this.isVehicleDoc = false;
        this.isAllDocType = true;
        this.uploadViewDocFlag = true;
    }

    @api currentStage;

    async handleSubmit() {
        console.log('Check Vehicle Id : ',this.vehicleDetailId,' - ',this.currentStage);
        if (this.currentStage === 'Credit Processing') {
            const evt = new ShowToastEvent({
                title: "Warning",
                message: "You are on credit processing",
                variant: 'warning',
            });
            this.dispatchEvent(evt);
            const nextStage = new CustomEvent('submit');
            this.dispatchEvent(nextStage);
        }
        else {
            if(!this.isProductTypeTractor){
            let insuranceNumberInput = this.template.querySelector('lightning-input[data-id=insNum]');
            let insurerNameInput = this.template.querySelector('lightning-input[data-id=insName]');
            let insuranceTypeInput = this.template.querySelector('lightning-input[data-id=insDecVal]');
            let insuranceDeclaredValueInput = this.template.querySelector('.insType');
            let issuanceDateInput = this.template.querySelector('lightning-input[data-id=issDate]');
            let expiryDateInput = this.template.querySelector('lightning-input[data-id=expDate]');
            let existingMotorIns;
            if(this.isPv){
                existingMotorIns = this.template.querySelector('lightning-input[data-id=exiMip]');
                existingMotorIns.reportValidity();
            }
            insuranceNumberInput.reportValidity();
            insurerNameInput.reportValidity();
            insuranceTypeInput.reportValidity();
            insuranceDeclaredValueInput.reportValidity();
            issuanceDateInput.reportValidity();
            expiryDateInput.reportValidity();
            let result = await checkCountOfContentDoc({'docId':this.documentRecordId});
            if(result == false){
                const evt = new ShowToastEvent({
                    message: 'Please upload Insurance Policy.',
                    variant: 'warning',
                });
                this.dispatchEvent(evt);
                return;
            }
            if (insuranceNumberInput.validity.valid === true && insurerNameInput.validity.valid === true && insuranceTypeInput.validity.valid === true && insuranceDeclaredValueInput.validity.valid === true && issuanceDateInput.validity.valid === true && expiryDateInput.validity.valid === true && (!this.isPv || (this.isPv && existingMotorIns.validity.valid == true))) {
                if ((this.insuranceExpiryCheckbox || this.insuranceType === "Third Party") && !this.isD2cApplication) {
                    const oppFields = {};
                    oppFields[OPP_ID_FIELD.fieldApiName] = this.recordid;
                    oppFields[JOURNEY_STATUS_FIELD.fieldApiName] = 'Non STP';
                    this.updateRecordDetails(oppFields)
                        .then(() => {
                            console.log('Inside non stp application');
                            const evt = new ShowToastEvent({
                                message: 'Application is marked as Non STP.',
                                variant: 'warning',
                            });
                            this.dispatchEvent(evt);
                        })
                }
                this.saveVehicleInsurance();
            }
            return true;
        }
        else{
            let vehicleObj = [];
            for (let index = 0; index < this.allVehicleDetails.length; index++) {
                if(this.allVehicleDetails[index] && this.allVehicleDetails[index].insuranceAvailable){
                    vehicleObj.push({'vehicleId' : this.allVehicleDetails[index].vehicleDetailId, 'documentUploaded' : false});
                }              
            }
            let result = await checkCountOfContentDocTractor({'payload':JSON.stringify(vehicleObj),'documenType':'Vehicle Insurance Policy'});
            if(result == false){
                const evt = new ShowToastEvent({
                    message: 'Please upload Insurance Policy.',
                    variant: 'warning',
                });
                this.dispatchEvent(evt);
                return;
            }
            let allVehicleDetails = this.allVehicleDetails;
            let insuranceNumberInput = this.template.querySelectorAll('lightning-input[data-id=insNum]');
            let insurerNameInput = this.template.querySelectorAll('lightning-input[data-id=insName]');
            let insuranceTypeInput = this.template.querySelectorAll('lightning-input[data-id=insDecVal]');
            let insuranceDeclaredValueInput = this.template.querySelectorAll('.insType');
            let issuanceDateInput = this.template.querySelectorAll('lightning-input[data-id=issDate]');
            let expiryDateInput = this.template.querySelectorAll('lightning-input[data-id=expDate]');

            insuranceNumberInput.forEach(iteratorFunction);
            insurerNameInput.forEach(iteratorFunction);
            insuranceTypeInput.forEach(iteratorFunction);
            insuranceDeclaredValueInput.forEach(iteratorFunction);
            issuanceDateInput.forEach(iteratorFunction);
            expiryDateInput.forEach(iteratorFunction);
            function iteratorFunction(item,index){
                if(allVehicleDetails[index].insuranceAvailable) {
                    item.reportValidity();
                }
            }

            let isInsursnceExpCheckBoxAndInsuranceType = false;
            allVehicleDetails.forEach(item=>{
                if(item.insuranceExpiryDate != null && (item.insuranceExpiryCheckbox || item.insuranceType === "Third Party"))
                    isInsursnceExpCheckBoxAndInsuranceType = true;
            })
            let checkFieldValidity = this.checkFieldValidity(allVehicleDetails,insuranceNumberInput,insurerNameInput,insuranceTypeInput,insuranceDeclaredValueInput,issuanceDateInput,expiryDateInput);
            if(checkFieldValidity) {
                if (isInsursnceExpCheckBoxAndInsuranceType && !this.isD2cApplication) {
                    const oppFields = {};
                    oppFields[OPP_ID_FIELD.fieldApiName] = this.recordid;
                    oppFields[JOURNEY_STATUS_FIELD.fieldApiName] = 'Non STP';
                    this.updateRecordDetails(oppFields)
                        .then(() => {
                            console.log('Inside non stp application2');
                            const evt = new ShowToastEvent({
                                message: 'Application is marked as Non STP.',
                                variant: 'warning',
                            });
                            this.dispatchEvent(evt);
                        })
                }
                this.saveVehicleInsurance();
            }
        }     
        
    }
    }

    checkFieldValidity(allVehicleDetails,insuranceNumberInput,insurerNameInput,insuranceTypeInput,insuranceDeclaredValueInput,issuanceDateInput,expiryDateInput){
        insuranceNumberInput.forEach(validityCheckForInsuranceNumber); 
        insurerNameInput.forEach(validityCheckForInsurerName);
        insuranceTypeInput.forEach(validityCheckForInsuranceType);
        insuranceDeclaredValueInput.forEach(validityCheckForInsuranceDeclaredValue);
        issuanceDateInput.forEach(validityCheckForInsuranceDate);
        expiryDateInput.forEach(validityCheckForExpiryDate);
        
        function validityCheckForInsuranceNumber(item,index){
            allVehicleDetails[index].insuranceNumberValid = true;
            if(!item.validity.valid){
                allVehicleDetails[index].insuranceNumberValid = false;
            }
        }

        function validityCheckForInsurerName(item,index){
            allVehicleDetails[index].insurerNameValid = true;
            if(!item.validity.valid){
                allVehicleDetails[index].insurerNameValid = false;
            }
        }

        function validityCheckForInsuranceType(item,index){
            allVehicleDetails[index].insuranceInsuranceTypeValid = true;
            if(!item.validity.valid){
                allVehicleDetails[index].insuranceInsuranceTypeValid = false;
            }
        }

        function validityCheckForInsuranceDeclaredValue(item,index){
            allVehicleDetails[index].insuranceInsuranceDeclaredValueValid = true;
            if(!item.validity.valid){
                allVehicleDetails[index].insuranceInsuranceDeclaredValueValid = false;
            }
        }

        function validityCheckForInsuranceDate(item,index){
            allVehicleDetails[index].insuranceInsuranceDateValid = true;
            if(!item.validity.valid){
                allVehicleDetails[index].insuranceInsuranceDateValid = false;
            }
        }

        function validityCheckForExpiryDate(item,index){
            allVehicleDetails[index].insuranceExpiryDateValid = true;
            if(!item.validity.valid){
                allVehicleDetails[index].insuranceExpiryDateValid = false;
            }
        }

        let isAllItemValid = true;
        allVehicleDetails.forEach(item=>{
            if(!item.insuranceNumberValid) isAllItemValid = false;
            if(!item.insurerNameValid) isAllItemValid = false;
            if(!item.insuranceInsuranceTypeValid) isAllItemValid = false;
            if(!item.insuranceInsuranceDateValid) isAllItemValid = false;
            if(!item.insuranceInsuranceDeclaredValueValid) isAllItemValid = false;
            if(!item.insuranceExpiryDateValid) isAllItemValid = false;
        })
        return isAllItemValid;

    }

    async callLoanApplicationHistory(nextStage){
        this.isSpinnerMoving = true;
        await getLoanApplicationHistory({ loanId: this.recordid, stage: 'Vehicle Insurance',nextStage: nextStage}).then(response => {
            this.isSpinnerMoving = false;
            console.log('getLoanApplicationHistory Response:: ', response);
          if(response){ 
              this.navigateToHomePage();
          }else{
            
            this.dispatchEvent(new CustomEvent('submitnavigation', { detail: nextStage }));
            //prashanth
            if(this.isD2cApplication){
                this.dispatchEvent(new CustomEvent('expirydateupdated', { detail: 'null' }));
                if(nextStage === 'Vehicle Valuation'){
                    this.disableEverything();
                }
            }
            
          }
        }).catch(error => {
            this.isSpinnerMoving = false;
            console.log('Error in getLoanApplicationHistory:: ', error);
        });
    }

    callAccessLoanApplication(){
        accessLoanApplication({ loanId: this.recordid , stage: 'Vehicle Insurance'}).then(response => {
            console.log('accessLoanApplication Response:: ', response);
            if(!response){ 
                this.disableEverything();
                console.log('here 2');
                if(this.checkleadaccess){//if lead is accessible but user from different profile is viewing that
                    const evt = new ShowToastEvent({
                        title: ReadOnlyLeadAccess,
                        variant: 'warning',
                        mode: 'sticky'
                    });
                    this.dispatchEvent(evt);
                    this.disableEverything();
                }
            }
          }).catch(error => {
              console.log('Error in accessLoanApplication:: ', error);
          });
    }

    handleActive(event) {
        this.activeTab = event.target.value;
        if (this.activeTab === this.label.CoBorrower) {
            this.isBorrower = false;
        } else if (this.activeTab === this.label.Borrower) {
            this.isBorrower = true;
        }
    }
    async saveVehicleInsurance(){
        if(!this.isProductTypeTractor){
        console.log('Inside Vehicle Else : ',this.vehicleDetailId,'-',this.insurerName,'',this.insuranceType,'',this.insuranceNumber,'',this.insuranceDeclaredValue,'',this.insuranceDateField,'',this.insuranceExpiryDate,'',this.insuranceExpiryCheckbox);
        let saveStatus = {'allowedNavigate': false,'saveMessage': ''};
        const vehicleDetailsFields = {};
        vehicleDetailsFields[VEHICLE_ID_FIELD.fieldApiName] = this.vehicleDetailId;
        vehicleDetailsFields[INSURER_NAME_FIELD.fieldApiName] = this.insurerName;
        vehicleDetailsFields[INSURANCE_TYPE_FIELD.fieldApiName] = this.insuranceType;
        vehicleDetailsFields[INSURANCE_NUMBER_FIELD.fieldApiName] = this.insuranceNumber;
        vehicleDetailsFields[INSURANCE_DECLARED_VALUE_FIELD.fieldApiName] = this.insuranceDeclaredValue;
        vehicleDetailsFields[INSURANCE_DATE_FIELD.fieldApiName] = this.insuranceDateField;
        vehicleDetailsFields[INSURANCE_EXPIRY_DATE_FIELD.fieldApiName] = this.insuranceExpiryDate;
        vehicleDetailsFields[INSURANCE_EXPIRY_CHECKBOX.fieldApiName] = this.insuranceExpiryCheckbox;                    
        await this.updateRecordDetails(vehicleDetailsFields)
            .then(() => {
                console.log('Inside saved Then : ');
                const event = new ShowToastEvent({
                        // title: 'success',
                        message: 'Vehicle Insurance details saved !',
                        variant: 'success',
                    });
                    this.dispatchEvent(event);
                    if(!this.fromHome){
                        let nextStage;
                        nextStage = 'Vehicle Valuation';
                        const oppFields = {};
                        oppFields[OPP_ID_FIELD.fieldApiName] = this.recordid;
                        oppFields[STAGENAME.fieldApiName] = nextStage;
                        oppFields[LAST_STAGE_NAME.fieldApiName] = nextStage;
                        if (this.isPv){                            
                            oppFields[EXISTING_MOTOR_INSURANCE_PREMIUM.fieldApiName] = this.existingMotorInsurancePremium;
                        }
                        this.updateRecordDetails(oppFields);
                        this.callLoanApplicationHistory('Vehicle Valuation');
                    }
                saveStatus.allowedNavigate = true;
                saveStatus.saveMessage = 'Navigation Success';
            })
            .catch (error => {
                console.log('Error in save data ',error);
                saveStatus.allowedNavigate = false;
                saveStatus.saveMessage = 'Navigation Fail';
            });
            return saveStatus;
    }
    else{
        let saveStatus = {'allowedNavigate': false,'saveMessage': ''};
        let vehicleInsuranceTractor = [];
        let hasImplementVehicleSubtype = false;
        this.allVehicleDetails.forEach(element =>{
            const vehicleDetailsFields = {};
            vehicleDetailsFields[VEHICLE_ID_FIELD.fieldApiName] = element.vehicleDetailId ? element.vehicleDetailId : '';
            vehicleDetailsFields[INSURER_NAME_FIELD.fieldApiName] = element.insurerName?element.insurerName:'';
            vehicleDetailsFields[INSURANCE_TYPE_FIELD.fieldApiName] = element.insuranceType?element.insuranceType:'';
            vehicleDetailsFields[INSURANCE_NUMBER_FIELD.fieldApiName] = element.insuranceNumber?element.insuranceNumber:'';
            vehicleDetailsFields[INSURANCE_DECLARED_VALUE_FIELD.fieldApiName] = element.insuranceDeclaredValue?element.insuranceDeclaredValue:'';
            vehicleDetailsFields[INSURANCE_AVAILABLE_FIELD.fieldApiName] = element.insuranceAvailable;
            if(element.insuranceDateField){
                let insuranceDate = new Date(element.insuranceDateField);
                vehicleDetailsFields[INSURANCE_DATE_FIELD.fieldApiName] = insuranceDate.getFullYear() + "-" + (insuranceDate.getMonth() + 1) + "-" + insuranceDate.getDate();
            }
            if(element.insuranceExpiryDate){
                let insuranceExpiryDate = new Date(element.insuranceExpiryDate);
                vehicleDetailsFields[INSURANCE_EXPIRY_DATE_FIELD.fieldApiName] = insuranceExpiryDate.getFullYear() + "-" + (insuranceExpiryDate.getMonth() + 1) + "-" + insuranceExpiryDate.getDate();
            }
            vehicleDetailsFields[INSURANCE_EXPIRY_CHECKBOX.fieldApiName] = element.insuranceExpiryCheckbox;
            vehicleInsuranceTractor.push(vehicleDetailsFields);
        });

        console.log('JSON.stringify(vehicleInsuranceTractor)-->'+ JSON.stringify(vehicleInsuranceTractor));
        if (this.allVehicleDetails.length == 1 && this.allVehicleDetails[0].vehicleSubTypeStr == 'Implement'){
            hasImplementVehicleSubtype = true;
        }
        insertAllVehicleDetailForTractor({ allTractorVehicleData: JSON.stringify(vehicleInsuranceTractor)})
        .then(response => {
                const event = new ShowToastEvent({
                        // title: 'success',
                        message: 'Vehicle Insurance details saved !',
                        variant: 'success',
                    });
                    this.dispatchEvent(event);
                    if(!this.fromHome){
                        if (hasImplementVehicleSubtype) {
                            const oppFields = {};
                            oppFields[OPP_ID_FIELD.fieldApiName] = this.recordid;
                            oppFields[STAGENAME.fieldApiName] = 'Loan Details';
                            oppFields[LAST_STAGE_NAME.fieldApiName] = 'Loan Details';
                            const fields = oppFields;
                            const recordInput = { fields };
                            updateRecord(recordInput).then(() => {
                                this.callLoanApplicationHistory('Loan Details');
                            }).catch(error=>{});
                        }
                        else {
                            let nextStage;
                            nextStage = 'Vehicle Valuation';
                            const oppFields = {};
                            oppFields[OPP_ID_FIELD.fieldApiName] = this.recordid;
                            oppFields[STAGENAME.fieldApiName] = nextStage;
                            oppFields[LAST_STAGE_NAME.fieldApiName] = nextStage;
                            const fields = oppFields;
                            const recordInput = { fields };
                            updateRecord(recordInput).then(() => {
                                this.callLoanApplicationHistory(nextStage);
                            }).catch(error=>{});
                        }
                    }
                saveStatus.allowedNavigate = true;
                saveStatus.saveMessage = 'Navigation Success';
        })
        .catch(error => {
            console.log('Error in save data ',error);
            saveStatus.allowedNavigate = false;
            saveStatus.saveMessage = 'Navigation Fail';
        });


    }
    
}
    async handleHome(){
        this.fromHome = true;
        await this.saveVehicleInsurance().then(submitResult=>{
            console.log('Inside Home: ',submitResult.allowedNavigate);
            if(submitResult.allowedNavigate){
                    this.navigateToHomePage();
            }
        }).catch(error => {
            console.log('Error In Saving Details - Error:: ', error);
        });
    }

    navigateToHomePage() {
        isCommunity()
            .then(response => {
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
            })
            .catch(error => {
            });

    }

    viewUploadViewFloater(){
        this.showFileUploadAndView = true;
    }
    closeUploadViewFloater(event){
        this.showFileUploadAndView = false;
    }

    disableEverything(){
        let allElements = this.template.querySelectorAll('*');
            allElements.forEach(element =>
            element.disabled = true
            );
    }

    changeToggle(event){
        this.insuranceAvailable = !this.insuranceAvailable;
    }
}