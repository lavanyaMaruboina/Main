import { LightningElement,track,wire,api } from 'lwc';
import {createRecord,getRecord,updateRecord,getFieldValue} from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import RC_Upload from '@salesforce/label/c.RC_Upload';
import Vehicle_New from '@salesforce/label/c.Vehicle_New';
import Vehicle_Old from '@salesforce/label/c.Vehicle_Old';
import Vehicle_Old_PlaceHolder from '@salesforce/label/c.Vehicle_Old_Pattern_PlaceHolder';
import Vehicle_New_PlaceHolder from '@salesforce/label/c.Vehicle_New_Pattern_PlaceHolder';
import RegistrationDateError from '@salesforce/label/c.RegistrationDateError';
import LoanDisbursement_OBJECT from '@salesforce/schema/LoanDisbursementDetails__c';
import LoanDisbursement_ID_FIELD from '@salesforce/schema/LoanDisbursementDetails__c.Id';
import LoanApplication_ID_FIELD from '@salesforce/schema/Opportunity.Id';
import LoanApplication_SUBSTAGE_FIELD from '@salesforce/schema/Opportunity.Sub_Stage__c';
import RegistrationFormat_FIELD from '@salesforce/schema/LoanDisbursementDetails__c.Registration_Format__c';
import RegistrationNumber_FIELD from '@salesforce/schema/LoanDisbursementDetails__c.Registration_Number__c';
import RegOwnerName_FIELD from '@salesforce/schema/LoanDisbursementDetails__c.Registration_Owner_Nam__c';
import RegtrationDate_FIELD from '@salesforce/schema/LoanDisbursementDetails__c.Registration_Date__c';
import RCDocument_FIELD from '@salesforce/schema/LoanDisbursementDetails__c.RC_Document__c';
import Parent_Loan_Application_FIELD from '@salesforce/schema/LoanDisbursementDetails__c.Parent_Loan_Application__c';
import DocumentActive_FIELD from '@salesforce/schema/Documents__c.is_Active__c';
import DocumentId_FIELD from '@salesforce/schema/Documents__c.Id';
import mandotoryDetailsNotProvide from '@salesforce/label/c.Mandotory_details_are_not_given_Please_provide';
import RCUploadErrorTitle from '@salesforce/label/c.RC_Upload_Error_Title';
import NewRCDocType from '@salesforce/label/c.New_RC_Doc_Type';
//import OldRCDocType from '@salesforce/label/c.Old_RC_Doc_Type';
import RCInsertSuccess from '@salesforce/label/c.RC_Upload_Save_Success';
import RCSubstage from '@salesforce/label/c.RC_Disbursement_Substage';
import RCUpdateSuccess from '@salesforce/label/c.RC_Upload_Update_Success';
import DMSSuccess from '@salesforce/label/c.DMS_Success';
import DMSError from '@salesforce/label/c.DMS_Error';
import checkRCDocument from '@salesforce/apex/GenericUploadController.checkRCDocument';
import clearRCDocument from '@salesforce/apex/GenericUploadController.clearRCDocument';
import doDMSUploadCallout from '@salesforce/apexContinuation/IntegrationEngine.doDMSUploadCallout';
import fetchDisbursementRecord from '@salesforce/apex/GenericUploadController.fetchDisbursementRecord';
import fetchLoanApplicationSubStage from '@salesforce/apex/GenericUploadController.fetchLoanApplicationSubStage';
import checkPaymentRequest from '@salesforce/apex/GenericUploadController.checkPaymentRequest'
import Payment_Request_Generated from '@salesforce/label/c.Payment_Request_Generated';
const rcuUploadFields = [RegistrationFormat_FIELD,RegistrationNumber_FIELD,RegOwnerName_FIELD,RegtrationDate_FIELD];
export default class IND_LWC_RCUpload extends LightningElement {
    @api dealId = '';
    paymentRequestGenerated = Payment_Request_Generated;
    label = {
        RC_Upload,
        mandotoryDetailsNotProvide,
        RegistrationDateError,
        RCUploadErrorTitle,
        NewRCDocType,
        RCInsertSuccess,
        RCSubstage,
        RCUpdateSuccess,
        DMSSuccess,
        DMSError
    };

    @api rcUploadTitle = 'RC Upload';
    @api listOfDocument = {fileName:'', contentDocumentId : '', documentRecordId: ''}; // use the format to pass data = {fileName:'', contentDocumentId : '', documentRecordId: ''}
    @api documentRecordId;

    @api uploadRCDocFlag;
    @api uploadViewDocFlag;
    @api recordid;
    @api disbursementRecordId;
    @api applicantid;
    @api applicantdetails = [];
    @api disablefields = false;

    disableUpload = false;
    disableSubmit = true;
    disableRegFormat = false;
    disableRegNumber = false;
    disableRegOwner = false;
    disableRegDate = false;


    @track isEnableUploadViewDoc=true;
    @track isSpinnerMoving=false;
    @track registrationFormat;
    @track registrationNumber;
    @track registrationOwnerName;
    @track dateOfRegistration;
    
    @track todaysDate = (function() {
        var today = new Date();
        var dd = String(today.getDate()).padStart(2, '0');
        var mm = String(today.getMonth() + 1).padStart(2, '0'); //January is 0!
        var yyyy = today.getFullYear();
        today = mm + '/' + dd + '/' + yyyy;
        return today
    })();  
    
    @track registrationFormatOptions = [
        { label: 'New', value: 'New' },
        { label: 'Old', value: 'Old' },
    ];

    @track isRCphotocopy = false;
    @track isShowTable = false;
    docType;
    pageVisible = false;

    vehicleType;
    connectedCallback(){
        this.isSpinnerMoving = true;
        try{
            checkPaymentRequest({ loanApplicationId: this.recordid, dealId: this.dealId })
              .then(result => {
                console.log('Result checkPaymentRequest', result);
                if(result){
                    if(result?.Vehicle_Details__r){
                        this.currentvehiclerecordid = result?.Vehicle_Details__r[0].Id;
                    }
                    if(result.Payment_Request_Generation_Date__c!= null)
                        this.pageVisible = true;
                }
              })
              .catch(error => {
                console.error('Error:', error);
            });
            this.disableScreen(this.disablefields);
            checkRCDocument({loanApplicationId: this.recordid,applicantId: this.applicantid, dealId: this.dealId}).
            then(result => {
                console.log('result ', result);
                if(result){
                    this.disableUpload = true;
                    this.disableSubmit = false;
                    this.documentRecordId = result;
                }
            })
            .catch(error =>{
                console.log('error'+error.body);
                this.dispatchEvent(                
                    new ShowToastEvent({
                        title: this.label.RCUploadErrorTitle,
                        message : error.body,
                        variant: 'error',
                    }),
                );
            });
    
            fetchDisbursementRecord({loanApplicationId: this.recordid,applicantId: this.applicantid, dealId: this.dealId}).
            then(result => {
                if(result != null) {
                    this.disbursementRecordId = result.Id;
                    this.vehicleType = result.Parent_Loan_Application__r.Vehicle_Type__c;
                }
            })
            .catch(error =>{
                console.log('error'+error.body);
                this.dispatchEvent(                
                    new ShowToastEvent({
                        title: this.label.RCUploadErrorTitle,
                        message : error.body,
                        variant: 'error',
                    }),
                );
            });
    
            console.log('inside RC')
            
            fetchLoanApplicationSubStage({loanApplicationId: this.recordid}).then(result => {
                console.log('fetchLoanApplicationSubStage '+result);
                this.isRCSubmitted = result;
            }).catch(error =>{
                console.log('error'+error.body);
            }).finally(()=>{
                this.isSpinnerMoving = false;
            });
        }catch(error){
            this.isSpinnerMoving = false;
            this.dispatchEvent(                
                new ShowToastEvent({
                    title: 'Error!',
                    message : 'Something Went Wrong!',
                    variant: 'error',
                }),
            );
        }
    }

    @track isRCSubmitted = false;

    renderedCallback() {
        if(this.isRCSubmitted){
            this.template.querySelectorAll('lightning-input').forEach(element => {
                if(!element.disabled){
                    element.disabled = true;
                }
            });
            this.template.querySelectorAll('lightning-combobox').forEach(element => {
                if(!element.disabled){
                    element.disabled = true;
                }
            });
            this.template.querySelectorAll('button').forEach(element => {
                if(!element.disabled){
                    element.disabled = true;
                }
            });
        }
    }

    handleUploadViewDoc() {
        if(this.vehicleType == 'New'){
            this.docType = 'RC';
        }else if(this.vehicleType == 'Used' || this.vehicleType == 'Refinance'){
            this.docType = 'Post Payments Request RC';
        }
        console.log('this.docType ', this.docType);
        this.showUpload = true;
        this.showPhotoCopy = false;
        this.showDocView = false;
        this.isVehicleDoc = true;
        this.isAllDocType = false;
        this.uploadRCDocFlag = false;
        this.uploadViewDocFlag = true;
    }

    handleUploadViewAndDelete(){
        this.showUpload = true;
        this.showPhotoCopy = false;
        this.showDocView = false;
        this.isVehicleDoc = true;
        this.isAllDocType = false;
        this.uploadViewDocFlag = false;
        this.uploadRCDocFlag = true;
        this.docType = this.label.NewRCDocType;
        console.log('applicantid'+this.applicantid);
    }

    @track registerationNumberFormatValue = '';
    @track vehicleRegistrationNumberValue = '';
    @track vehicleRegistrationPattern = Vehicle_New;
    @track vehicleRegistrationPatternPlaceholder='';

    handleInputFieldChange(event) {
        const field = event.target.name;
        if(field === 'registrationFormatField'){
            this.registrationFormat = event.target.value;
            if(this.registrationFormat == 'Old'){
                this.vehicleRegistrationPattern = Vehicle_Old;
                this.vehicleRegistrationPatternPlaceholder = Vehicle_Old_PlaceHolder;
                console.log('vehicle Registratin paterrn ' ,Vehicle_Old_PlaceHolder);
            
            }
            else if(this.registrationFormat == 'New'){
                this.vehicleRegistrationPattern = Vehicle_New;
                this.vehicleRegistrationPatternPlaceholder =  Vehicle_New_PlaceHolder;
                console.log('vehicle new Registratin paterrn ' ,Vehicle_New_PlaceHolder);
            }
        }
    }



    //Wire the output of the out of the box method getRecord to the property newUsedVehicleInfo;
    @wire(getRecord, {recordId: '$disbursementRecordId',fields: rcuUploadFields})
    rcUploadInfo({ error, data }) {
        if (error) {
            let message = 'Unknown error';
            if (Array.isArray(error.body)) {
                message = error.body.map(e => e.message).join(', ');
            } else if (typeof error.body.message === 'string') {
                message = error.body.message;
            }
            this.dispatchEvent(
                new ShowToastEvent({
                    title: this.label.RCUploadErrorTitle,
                    message : this.message,
                    variant: 'error',
                }),
            );
        } else if (data) {
            //alert(JSON.stringify(data));
            this.registrationFormat = data.fields.Registration_Format__c.value;
            this.registrationNumber = data.fields.Registration_Number__c.value;
            this.registrationOwnerName = data.fields.Registration_Owner_Nam__c.value;
            this.dateOfRegistration = data.fields.Registration_Date__c.value;
        }
    }

    // async insertRCUploadInfoDetails(fields) {
    //     const recordInput = { apiName: LoanDisbursement_OBJECT.objectApiName, fields };
    //     //Calling createRecord method of uiRecordApi
    //     await createRecord(recordInput)
    //     .then(response =>{
    //         this.isSpinnerMoving = false;
    //         this.dispatchEvent(
    //             new ShowToastEvent({
    //                 title: 'Success',
    //                 message: this.label.RCInsertSuccess,
    //                 variant: 'success'
    //             }),
    //             );
    //         this.disbursementRecordId = response.id;
    //         console.log('disbursementrec..'+this.disbursementRecordId);
    //         const loaFields = {};
    //         loaFields[LoanApplication_ID_FIELD.fieldApiName] = this.recordid;
    //         loaFields[LoanApplication_SUBSTAGE_FIELD.fieldApiName] = 'RC Upload';
    //         this.updateLoanAppStage(loaFields);  
    //         this.handleUploadRC();
            
    //     })
    //     .catch(error => {
    //         this.isSpinnerMoving = false;
    //         this.dispatchEvent(
    //             new ShowToastEvent({
    //                 title: 'Error',
    //                 message: error.body.message,
    //                 variant: 'error'
    //             }),
    //         );
    //     });
    // }

    async updateRCUploadInfoDetails(fields) {
        const recordInput = {fields};
        console.log('recordInput..'+JSON.stringify(recordInput));
        //Calling createRecord method of uiRecordApi
        await updateRecord(recordInput)
        .then(response =>{
            console.log('updateRecord');
            this.isSpinnerMoving = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: this.label.RCUpdateSuccess,
                    variant: 'success'
                }),
            );
            this.disbursementRecordId = response.id;  
            const loaFields = {};
            loaFields[LoanApplication_ID_FIELD.fieldApiName] = this.recordid;
            loaFields[LoanApplication_SUBSTAGE_FIELD.fieldApiName] = this.label.RCSubstage;
            this.updateLoanAppStage(loaFields);
            this.handleUploadRC(); 
            
            
        })
        .catch(error => {
            console.log('error'+JSON.stringify(error));
            this.isSpinnerMoving = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: error.body.message,
                    variant: 'error'
                }),
            );
        });
    }

    async updateLoanAppStage(fields) {
        
        const recordInput = {fields};
        await updateRecord(recordInput)
        .then(response => { 
            this.isRCSubmitted = true;
            this.renderedCallback();
            console.log('updateLoanAppStage Success'); 
        }).catch(error => {
            console.log('updateLoanAppStage error'+JSON.stringify(error));
            this.isSpinnerMoving = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: error.body,
                    variant: 'error'
                }),
            );
        });
    }

    handleSubmit(event) {
        const field = event.target.name;
        if(field === 'rcUploadSubmit'){
            console.log('handleSubmit');
            let regFormat = this.template.querySelector('lightning-combobox[data-id=registrationFormatField]');
            let regNo = this.template.querySelector('lightning-input[data-id=registrationNumberField]');
            let regOwName = this.template.querySelector('lightning-input[data-id=registrationOwnerNameField]');
            let regDate = this.template.querySelector('lightning-input[data-id=dateOfRegistrationField]');
            regFormat.reportValidity();
            regNo.reportValidity();
            regOwName.reportValidity();
            regDate.reportValidity();

            if (regFormat.validity.valid === true && regNo.validity.valid === true && regOwName.validity.valid === true && regDate.validity.valid === true){
                console.log('inside if 306');
                if(this.documentRecordId != undefined) {
                    this.isSpinnerMoving = true;
                    const rcUploadFields = {};
                    rcUploadFields[RegistrationFormat_FIELD.fieldApiName] = this.registrationFormat;
                    rcUploadFields[RegistrationNumber_FIELD.fieldApiName] = this.template.querySelector('lightning-input[data-id=registrationNumberField]').value;
                    rcUploadFields[RegOwnerName_FIELD.fieldApiName] = this.template.querySelector('lightning-input[data-id=registrationOwnerNameField]').value;
                    rcUploadFields[RegtrationDate_FIELD.fieldApiName] = this.template.querySelector('lightning-input[data-id=dateOfRegistrationField]').value;
                    console.log('Date..'+rcUploadFields[RegtrationDate_FIELD.fieldApiName]);
                    rcUploadFields[RCDocument_FIELD.fieldApiName] = this.documentRecordId;

                    //alert(JSON.stringify(rcUploadFields));
                    console.log('disbursementRecordId..'+this.disbursementRecordId);
                    if(this.disbursementRecordId != null){
                        console.log('inside if 321');
                        rcUploadFields[LoanDisbursement_ID_FIELD.fieldApiName] = this.disbursementRecordId;
                        rcUploadFields[LoanDisbursement_ID_FIELD.fieldApiName] = this.disbursementRecordId;
                        this.updateRCUploadInfoDetails(rcUploadFields);
                    }
                    // else{
                    //     console.log('inside else 325');
                    //     rcUploadFields[Parent_Loan_Application_FIELD.fieldApiName] = this.recordid;
                    //     this.insertRCUploadInfoDetails(rcUploadFields);

                    // }
                } else {
                    this.dispatchEvent(
                        new ShowToastEvent({
                        title: "Error",
                        title: 'RC Document file has to be uploaded.',
                        variant: 'error' 
                    })
                    );
                }
            }
            else {
                const evt = new ShowToastEvent({
                    title: "Error",
                    title: this.label.mandotoryDetailsNotProvide,
                    variant: 'error' 
                });
                this.dispatchEvent(evt);
                return null;
            }

            
        }
    }

    handleUploadRC() {
        this.isSpinnerMoving = true;
        doDMSUploadCallout({loanAppId : this.recordid,documentType: this.docType, dealId: this.dealId}).then(res =>{
            console.log('result..'+res);
            var response = res.response;
            if(response.status == 'SUCCESS') {
                this.isSpinnerMoving = false;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: this.label.DMSSuccess,
                        variant: 'success'
                    }),
                );
                this.disableScreen(true);
            } else {
                this.isSpinnerMoving = false;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Please try again!',
                        message: this.label.DMSError,
                        variant: 'error'
                    }),
                );
                
                this.clearValues();
                this.disableScreen(false);
            }
        }).catch(error =>{
            this.isSpinnerMoving = false;
            const evt = new ShowToastEvent({
                title: "Error",
                title: error.body,
                variant: 'error' 
            });
            this.dispatchEvent(evt);
        })
    }

    changeflagvalue() {
        this.uploadViewDocFlag = false;
    }

    changeUploadRCFlagValue(event) {
        this.uploadRCDocFlag = false;
        if(event.detail != undefined) {
            console.log('uploadresponse..'+JSON.stringify(event.detail));
            checkRCDocument({loanApplicationId: this.recordid,applicantId: this.applicantid, dealId: this.dealId}).
            then(result => {
                console.log('result ', result);
                if(result){
                    this.disableUpload = true;
                    this.disableSubmit = false;
                    this.documentRecordId = result;
                }
            })
            .catch(error =>{
                console.log('error'+error.body);
                this.dispatchEvent(                
                    new ShowToastEvent({
                        title: this.label.RCUploadErrorTitle,
                        message : error.body,
                        variant: 'error',
                    }),
                );
            });
        }
    }

    clearValues() {
        console.log('clearValues ');
        this.registrationFormat = null;
        this.registrationNumber = null;
        this.registrationOwnerName = null;
        this.dateOfRegistration = null;        
        clearRCDocument({loanDisbursementId : this.disbursementRecordId})
        .then(response =>{
            console.log('response'+JSON.stringify(response));
        })
        .catch(error => {
            console.log('error'+JSON.stringify(error));
        });
        /*console.log('docFields');
        const docFields = {};
        docFields[DocumentId_FIELD] = this.documentRecordId;
        docFields[DocumentActive_FIELD.fieldApiName] = false;
        console.log('docFields'+JSON.stringify(docFields));
        const recordInput = {docFields};
        console.log('recordInput'+JSON.stringify(recordInput));
        updateRecord(recordInput).then(() => {
            console.log('Document deactivated');
            this.documentRecordId = null;            
        }).catch(error => {
            console.log('Error '+JSON.stringify(error));
        });*/
    }

    disableScreen(disableValue) {
        if(disableValue == true) {
            this.disableUpload = true;
            this.disableSubmit = true;
            this.disableRegFormat = true;
            this.disableRegNumber = true;
            this.disableRegOwner = true;
            this.disableRegDate = true;
        } else {
            this.disableUpload = false;
            this.disableSubmit = true;
            this.disableRegFormat = false;
            this.disableRegNumber = false;
            this.disableRegOwner = false;
            this.disableRegDate = false;
        }
    }
}