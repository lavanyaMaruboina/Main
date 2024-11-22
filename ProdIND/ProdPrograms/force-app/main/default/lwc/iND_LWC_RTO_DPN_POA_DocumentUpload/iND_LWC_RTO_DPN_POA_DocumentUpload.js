import { LightningElement, api, track, wire } from 'lwc';

import fetchDetails from '@salesforce/apex/RtoDpnPoaDocumentController.fetchDetails';
import submitDocuments from '@salesforce/apex/RtoDpnPoaDocumentController.submitDocuments';
import getApplicantRecord from '@salesforce/apex/RtoDpnPoaDocumentController.getApplicantRecord';
import createDocuments from '@salesforce/apex/RtoDpnPoaDocumentController.createDocuments';
import deleteContentDocument from '@salesforce/apex/RtoDpnPoaDocumentController.deleteContentDocument';
import validateDocument from '@salesforce/apex/RtoDpnPoaDocumentController.validateDocument';
import updateContentDocument from '@salesforce/apex/RtoDpnPoaDocumentController.updateContentDocument';
import allDealClosed from '@salesforce/apex/RtoDpnPoaDocumentController.allDealClosed';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import SUBMITSUCCESSFULLY from '@salesforce/label/c.SubmitSuccessfully';
import CHECK_POST_SANCTION_SCREENS_MSG from '@salesforce/label/c.Check_Post_Sanction_screens_Msg';
import No_Payment_Executive from '@salesforce/label/c.No_Payment_Executive';
// CISP-4770 - START
import Insurance_Details from '@salesforce/label/c.Insurance_Detail';
import NewUsed_Vehicles from '@salesforce/label/c.New_Used_Vehicles';
import Beneficiary_Details from '@salesforce/label/c.Beneficiary_Details';
import Business_Payment from '@salesforce/label/c.Business_Payment';
import GetLoanDisbursementDetails from '@salesforce/apex/LoanDisbursementController.getLoanDisbursementDetails';
import { getRecord, updateRecord } from 'lightning/uiRecordApi';
import ParentLoanApp_Field from '@salesforce/schema/Opportunity.Id';
import isPRSubmittedbyBE from '@salesforce/schema/Opportunity.isPRSubmittedbyBE__c';
import ProductType_Field from '@salesforce/schema/Opportunity.Product_Type__c';
import LoanApplicationStage_Field from '@salesforce/schema/Opportunity.StageName';
import LoanApplicationSubStage_Field from '@salesforce/schema/Opportunity.Sub_Stage__c';
import Tractor from '@salesforce/label/c.Tractor';

const OPPORTUNITY_FIELDS = [ParentLoanApp_Field,isPRSubmittedbyBE, ProductType_Field,LoanApplicationStage_Field, LoanApplicationSubStage_Field];
// CISP-4770 - END

import checkAssetVerificationStatus from '@salesforce/apex/LWCLOSAssetVerificationCntrl.checkAssetVerificationStatus'; // SFTRAC-162

export default class IND_LWC_RTO_DPN_POA_DocumentUpload extends NavigationMixin(LightningElement) {
    @api dealId = '';
    @api recordId;
    @api currentStep;
    viewDocFlag;
    uploadAdditionalDocFlag;
    changeFlagValue;
    docType;
    showDocView;
    showPhotoCopy;
    showUpload;
    isVehicleDoc;
    isAllDocType;
    documentRecordId;
    previousDocumentRecordId;
    vehiclerecordid;
    applicantid;
    popupTitle;
    error;
    
    disableDocument;
    isDocumentValue;
    yesNoOptions = [];

    disableSubmitBtn1
    @api disableSubmitBtn = false;
    postSancationCheck = false;
    showSpinner = false;

    preDisbursementCheck;
    productType;
vehicleType; // SFTRAC-162
    oppStage;
    docDetails;
    rtoRemarkReq;
    dpnRemarkReq;
    poaRemarkReq;

    rtoDocObj = {Id: '', Is_Document_Eligible__c : '', Correctly_Captured__c : '', Remarks__c : ''};
    dpnDocObj = {Id: '', Is_Document_Eligible__c : '', Correctly_Captured__c : '', Remarks__c : ''};
    poaDocObj = {Id: '', Is_Document_Eligible__c : '', Correctly_Captured__c : '', Remarks__c : ''};

    isFieldDisabled;
    additionaldocument;
    leadSource = '';

    // CISP-4770 - START
    isPRSubmittedbyBEuser = false;
    frompostsanction =true;
    disabledmovetoPayReq = false;
    PaymentRequestpopup = false;
    @track loanApplication;
    @track currentSubTab = Business_Payment;
    @track disableBusinessPaymentFields = false;
    @track disableInsuranceFields = false;
    @track disableNewUsedVehicleFields = false;
    @track disableBenefeciaryFields = false;
    @track isPV = false;
    @track isTW = false; //CISP-22456
    @api disbursementrecordid;
    label = {
        Business_Payment,
        Insurance_Details,
        NewUsed_Vehicles,
        Beneficiary_Details
    }

    @track viewappsubtabs = {
        "bussinesspayment": true,
        "insurancedetails": false,
        "neworusedvehicle": false,
        "beneficiarydetails": false,
    }; 
    @track activeviewappsubtab = undefined;
    @track currentappstage;
    @track currentappsubstage;

    @wire(GetLoanDisbursementDetails, {
        loanApplicationId: '$recordId',
        dealId: '$dealId'
    }) listInfo({ error, data }) {
        if (data) {
            console.debug(data);
            this.disbursementrecordid = data.Id;
            console.debug('disbursementrecordid In RTO',this.disbursementrecordid);
        } else if (error) {
            console.error('error on GetLoanDisbursementDetails ',error);
        }
    }
    @wire(getRecord, { recordId: '$recordId', fields: OPPORTUNITY_FIELDS })
    wiredRecord({ error, data }) {
            if (error) {
                let message = 'Unknown error';
                if (Array.isArray(error.body)) {
                    message = error.body.map(e => e.message).join(', ');
                } else if (typeof error.body.message === 'string') {
                    message = error.body.message;
                }
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error loading loan application',
                        message,
                        variant: 'error',
                    }),
                );
            } else if (data) {
                this.loanApplication = data;
                console.table('RTO DPN data @  ',this.loanApplication);
                if (this.loanApplication.fields.StageName && this.loanApplication.fields.Sub_Stage__c) {
                    this.currentappstage = this.loanApplication.fields.StageName.value;
                    this.currentappssubtage = this.loanApplication.fields.Sub_Stage__c.value;
                    
                    this.isPRSubmittedbyBEuser = this.loanApplication.fields.isPRSubmittedbyBE__c.value;
                    if (this.loanApplication.fields.StageName.value.includes('Post Sanction Checks and Documentation')) {
                        this.isPV = this.loanApplication.fields.Product_Type__c.value.includes('Passenger Vehicles')? true:false;
                        this.isTW = this.loanApplication.fields.Product_Type__c.value.includes('Two Wheeler')? true:false; //CISP-22456
                            this.activeTab = Business_Payment;
                            this.currentSubTab = Business_Payment;
                            this.viewappsubtabs.bussinesspayment = true;
                            this.disableBusinessPaymentFields = false;
                            this.disableInsuranceFields = false;
                            this.disableNewUsedVehicleFields = false;
                            this.disableBenefeciaryFields = false;
                    }
                }

            }
        }

    // CISP-4717 - END
    
    //D2C Swapnil disable POA button
    get disablePOAUpload(){
        if(this.leadSource === 'D2C'){
            return true;
        }
        return this.disableSubmitBtn1;
    }

    async connectedCallback(){
        await getApplicantRecord({ loanApplicationId: this.recordId })
          .then(result => {
            console.log('Result getApplicantRecord', result);
            if(result){
                this.applicantid = result.Id;
            }
          })
          .catch(error => {
            console.error('Error:', error);
        });
        console.log('== connectedCallback ',this.currentStep);
        var optionList = new Array();
        optionList.push({ label: 'Yes', value: 'Yes' });
        optionList.push({ label: 'No', value: 'No' });
        this.yesNoOptions = optionList;
        this.disableSubmitBtn = true;
        await fetchDetails({ loanApplicationId: this.recordId, dealId: this.dealId })
        .then(result => {
            console.log("== Result getLADetails ", result);   
            if(result){
               // this.applicantid = result?.oppRec?.Applicant__c;
                this.vehiclerecordid = result?.oppRec?.Vehicle_Details__r == undefined ? '' : result?.oppRec?.Vehicle_Details__r[0]?.Id;
                this.productType = result?.oppRec?.Product_Type__c;
this.vehicleType = result?.oppRec?.Vehicle_Type__c; // SFTRAC-162
                this.postSancationCheck = result?.oppRec?.StageName == 'Post Sanction Checks and Documentation' ? true : false;
                this.preDisbursementCheck = result?.oppRec?.StageName == 'Pre Disbursement Check' ? true : false;
                this.oppStage = result?.oppRec?.StageName;
                this.leadSource = result?.oppRec?.LeadSource;//OLA-142
                //CISP-22284 Start
                if(this.productType == 'Two Wheeler'){
                    this.disableSubmitBtn = false;
                }
                //CISP-22284 End
                let isReadOnly = result?.showSubmitBtn;
                this.disableSubmitBtn1 = isReadOnly;
                if(this.currentStep == 'post-sanction' && this.oppStage == 'Pre Disbursement Check'){
                    this.disableSubmitBtn1 = true;
                    this.preDisbursementCheck = false;
                    this.postSancationCheck = true;
                    this.isFieldDisabled = true;
                }
                
                this.rtoDocObj.Id = result?.rtoDoc?.Id;
                this.rtoDocObj.Is_Document_Eligible__c = result?.rtoDoc?.Is_Document_Eligible__c;
                this.rtoDocObj.Correctly_Captured__c = result?.rtoDoc?.Correctly_Captured__c;
                this.rtoDocObj.Remarks__c = result?.rtoDoc?.Remarks__c;

                this.dpnDocObj.Id = result?.dpnDoc?.Id;
                this.dpnDocObj.Is_Document_Eligible__c = result?.dpnDoc?.Is_Document_Eligible__c;
                this.dpnDocObj.Correctly_Captured__c = result?.dpnDoc?.Correctly_Captured__c;
                this.dpnDocObj.Remarks__c = result?.dpnDoc?.Remarks__c;

                this.poaDocObj.Id = result?.poaDoc?.Id;
                this.poaDocObj.Is_Document_Eligible__c = result?.poaDoc?.Is_Document_Eligible__c;
                this.poaDocObj.Correctly_Captured__c = result?.poaDoc?.Correctly_Captured__c;
                this.poaDocObj.Remarks__c = result?.poaDoc?.Remarks__c;
                
                if(this.preDisbursementCheck){
                    this.isFieldDisabled = isReadOnly;
                    if(this.rtoDocObj.Is_Document_Eligible__c==='No' || this.rtoDocObj.Correctly_Captured__c==='No'
                        || this.dpnDocObj.Is_Document_Eligible__c==='No' || this.dpnDocObj.Correctly_Captured__c==='No'
                        || this.poaDocObj.Is_Document_Eligible__c==='No' || this.poaDocObj.Correctly_Captured__c==='No'){
                        this.isFieldDisabled=false;
                        this.disableSubmitBtn = false;
                    }
                }

                if(this.postSancationCheck){
                   this.isFieldDisabled = true;
                }
                console.log('== this.rtoDocObj ', this.rtoDocObj);
                console.log('== this.dpnDocObj ', this.dpnDocObj);
                console.log('== this.poaDocObj ', this.poaDocObj);

                if(this.currentStep == 'post-sanction' && this.oppStage == 'Disbursement Request Preparation'){
                    this.disableSubmitBtn1 = true;
                    this.preDisbursementCheck = false;
                    this.postSancationCheck = true;
                    this.isFieldDisabled = true;
                }
                if(this.currentStep == 'pre-disbursement' && this.oppStage == 'Disbursement Request Preparation'){
                    this.disableSubmitBtn1 = true;
                    this.preDisbursementCheck = true;
                    this.postSancationCheck = false;
                    this.isFieldDisabled = true;
                }
                this.validateDocumentHandler();
            }
        })
        .catch(error => {
            //this.error = error;
            console.log('== getLADetails error connected ', error);
        });
        if(this.isRevokedLoanApplication){this.disableEverything();}//CISP-2735
    }
    renderedCallback(){
      if(this.isRevokedLoanApplication){this.disableEverything();}//CISP-2735
      if(this.leadSource == 'OLA'){//OLA-142
        let allElements = this.template.querySelectorAll("[data-id='RTO']");
        allElements.forEach(element =>
            element.required = false
        );
        //this.template.querySelector("[data-id='RTO']").required = false;

      }//OLA-142
      
    }
    disableEverything(){
        let allElements = this.template.querySelectorAll('*');
        allElements.forEach(element =>
            element.disabled = true
        );
    }
    @api isRevokedLoanApplication;//CISP-2735
    //CISP-2735-END

    handleUploadDocument(event){
        try {
            let documentType = event.target.value;
            if(documentType == 'RTO'){
                this.previousDocumentRecordId = this.rtoDocObj.Id;
            }else if(documentType == 'DPN'){
                this.previousDocumentRecordId = this.dpnDocObj.Id;
            }else if(documentType == 'POA'){
                this.previousDocumentRecordId = this.poaDocObj.Id;
            }
        // this.disableSubmitBtn = false;
        console.log('== doc Type ',event.target.value);
        if(event.target.value){
            this.docType = event.target.value;
            this.popupTitle = 'Upload '+ event.target.value +' Document';
                if(this.previousDocumentRecordId != '' && this.previousDocumentRecordId != undefined && this.previousDocumentRecordId != null){
                    this.additionaldocument = "true";
                    this.documentIdWithType = this.previousDocumentRecordId + ' ' + this.docType;
                    this.uploadAdditionalDocFlag = true;
                    this.documentRecordId = this.previousDocumentRecordId;
                    this.showUpload = true;
                    this.showPhotoCopy = false;
                    this.showDocView = true;
                    this.isVehicleDoc = true;
                    this.isAllDocType = false;
                    this.uploadViewDocFlag = false;
                }else{
            createDocuments(
                    {docType :this.docType, 
                    vehicleDetailId : this.vehiclerecordid,
                    applicantId : this.applicantid,
                            loanApplicationId : this.recordId,
            })
             .then(result => {
                        this.additionaldocument = "false";
               console.log('== Result', result);
               this.documentIdWithType = result + ' ' + this.docType;
               console.log('== documentIdWithType : ',this.documentIdWithType);
               
                        this.documentIdWithType = result + ' ' + this.docType;
               this.uploadAdditionalDocFlag = true;
               this.documentRecordId = result;
               this.showUpload = true;
               this.showPhotoCopy = false;
               this.showDocView = true;
               this.isVehicleDoc = true;
               this.isAllDocType = false;
               this.uploadViewDocFlag = false;
               
                        if(this.docType == 'RTO'){
                            this.rtoDocObj.Id = result;
                        }else if(this.docType == 'DPN'){
                            this.dpnDocObj.Id = result;
                        }else if(this.docType == 'POA'){
                            this.poaDocObj.Id = result;
                        }
                        this.previousDocumentRecordId = result;
             })
             .catch(error => {
               console.log('Error:', error);
           });
                }

            }       
        } catch (error) {
            console.error('handleUploadDocument -- ',error);
        }
    }

    handleViewDocument(event){

        console.log('== view doc Type ',event.target.value);
        if(event.target.value){
            this.docType = event.target.value;

            this.popupTitle = 'View '+ event.target.value +' Document';
            
            if(this.docType == 'RTO'){
                this.documentRecordId = this.rtoDocObj.Id;
            }else if(this.docType == 'DPN'){
                this.documentRecordId = this.dpnDocObj.Id;
            }else if(this.docType == 'POA'){
                this.documentRecordId = this.poaDocObj.Id;
            }

            this.viewDocFlag = true;
            this.showUpload = true;
            this.showPhotoCopy = false;
            this.showDocView = true;
            this.isVehicleDoc = true;
            this.isAllDocType = false;
            this.uploadViewDocFlag = false;

        }

    }
    
    @track isDocumentValid = false;
    validateDocumentHandler(){
        validateDocument({vehicleDetailId : this.vehiclerecordid, applicantId : this.applicantid,loanApplicationId : this.recordId}).then(result => {
            console.log('== validateDocument result ', result);
            console.log('== validateDocument result.length ', this.disableSubmitBtn1);
            console.log('== validateDocument result.length ', this.disableSubmitBtn);
            console.log('== validateDocument result.length ', this.isdocumentValid);
            if(!this.disableSubmitBtn1 && this.disableSubmitBtn && result && !this.isdocumentValid && this.oppStage == 'Post Sanction Checks and Documentation'){
                console.log('== validateDocument result ', result);
                this.disableSubmitBtn = false;
                this.isDocumentValid = result;
            }
        }).catch(error => {
            console.log('Error:', error);
        });
    }

    @api async handleSubmitDocuments(){
        // CISP-4770 - START
        if(this.isPV && !this.isPRSubmittedbyBEuser){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Please complete the payment request section',
                    message: 'Please click on Move to payment request button and complete the details',
                    variant: 'error',
                }));
            return;
        }
        // CISP-4770 - END
        this.showSpinner = true;
        let msg = '';
        console.log('productType : ',this.productType);
        console.log('postSancationCheck : ',this.postSancationCheck);
        console.log('vehicleType : ',this.vehicleType); // SFTRAC-162
        if(this.postSancationCheck  && (this.productType == 'Two Wheeler' || this.productType == 'Passenger Vehicles')){
            let result = await validateDocument({vehicleDetailId : this.vehiclerecordid, applicantId : this.applicantid,loanApplicationId : this.recordId});
            if(this.oppStage == 'Post Sanction Checks and Documentation'){
                this.isDocumentValid = result;
            }
            if(this.isDocumentValid == true){
                this.submitDocumentsHandler();
             }else{
                 msg = 'Please upload RTO and DPN documents.';
                 console.log('productType ', this.documenValid);
                 this.showSpinner = false;
                 this.dispatchEvent(
                     new ShowToastEvent({
                         title: '',
                         message: msg,
                         variant: 'warning',
                     }));
             }
        }else  if(this.postSancationCheck){

           // SFTRAC-162 Starts
            if(this.productType == 'Tractor' && this.vehicleType == 'New'){
                checkAssetVerificationStatus({ 'loanApplicationId': this.recordId }).then(result => {
                        console.log('checkAssetVerificationStatus ', result);
                        //let result1 = result;
                        let result1 = result.trim();
                        console.log('checkAssetVerificationStatus result1', result1);
                        if (result1 == 'Asset Verification Completed') {
                            console.log('checkAssetVerificationStatus IN', result1);
                            this.submitDocumentsHandler();
                        } else {
                            console.log('checkAssetVerificationStatus ELSE', result1);
                            this.showSpinner = false;
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: 'Error:',
                                    message: 'Asset Verification is not completed. Please complete it before submiting RTO and DPN screen.',
                                    variant: 'Error',
                                }));
                        }
                    })
                    .catch(error => {
                        // Handle errors here
                        console.error(error);
                    });
            }else{                                       
            this.submitDocumentsHandler();
            }// SFTRAC-162 Ends
            
            //this.submitDocumentsHandler();
        }

        if(this.preDisbursementCheck){
            let docDetailList = [];
            if(this.rtoDocObj.Id != undefined && this.rtoDocObj.Id != null && this.rtoDocObj.Id != ''){
                docDetailList.push(this.rtoDocObj);
            }
            if(this.dpnDocObj.Id != undefined && this.dpnDocObj.Id != null && this.dpnDocObj.Id != ''){
                docDetailList.push(this.dpnDocObj);
            }
            if(this.poaDocObj.Id != undefined && this.poaDocObj.Id != null && this.poaDocObj.Id != ''){
                docDetailList.push(this.poaDocObj);
            }

            let valid = this.isFieldsValid();
            console.log('== isFieldsValid ', valid);
            if(valid){
                this.docDetails = JSON.stringify(docDetailList);
            }else{
                this.showSpinner = false;
                return;
            }
            this.submitDocumentsHandler();
        }
    }

    submitDocumentsHandler(){
        submitDocuments({ loanApplicationId: this.recordId, oppStage : this.oppStage, docDetails: this.docDetails,dealId: this.dealId })
        .then(result => {
            console.log("== Loan Submitted ", result);   
            if(result == 'Success'){
                console.log('== Loan Application Subimitted');
                this.disableSubmitBtn = true;
                this.disableSubmitBtn1 = true;
                this.isFieldDisabled = true;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: SUBMITSUCCESSFULLY,
                        variant: 'success',
                    }),
                );
                this.showSpinner = false;
                
                if(this.oppStage == 'Post Sanction Checks and Documentation' && this.productType == 'Passenger Vehicles' ){
                    this[NavigationMixin.Navigate]({
                        type: 'standard__navItemPage',
                        attributes: {
                            apiName: 'Home'
                        }
                    });
                }else if(this.oppStage == 'Post Sanction Checks and Documentation'){

                    if(this.productType == Tractor){
                        allDealClosed({oppId: this.recordId ,module: 'Post Sanction Checks and Documentation'}).then(result=>{
                            if(result == true){
                                this.dispatchParentRefreshEvent();
                            }
                        }).catch(error => {
                            console.log('== deleteContentDocument error ', error);
                        });
                    }else{
                        this.dispatchParentRefreshEvent();
                    }
                }
            }else if(result == CHECK_POST_SANCTION_SCREENS_MSG){
                this.showSpinner = false;
                this.dispatchEvent(                
                    new ShowToastEvent({
                        title: 'Error',
                        message: result,
                        variant: 'error',
                    }),
                );
            }else if(result == No_Payment_Executive){
                this.showSpinner = false;
                this.dispatchEvent(                
                    new ShowToastEvent({
                        title: 'Error',
                        message: result,
                        variant: 'error',
                    }),
                );
            }
            else{
                this.showSpinner = false;
                this.dispatchEvent(                
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Error in submitting documents',
                        variant: 'error',
                    }),
                );
            }
        })
        .catch(error => {
            //this.error = error;
            console.log('== getLADetails error ', error);
            this.showSpinner = false;
            this.dispatchEvent(                
                new ShowToastEvent({
                    title: 'Error',
                    message: error.body.message,
                    variant: 'error',
                }),
            );
        });
    }


    dispatchParentRefreshEvent(){
        this.dispatchEvent(
            new CustomEvent('refreshParentComponent',{
                bubbles:true,
                composed:true,
            })
        );
        eval("$A.get('e.force:refreshView').fire();");
    }

    isFieldsValid() {
        let isValid = true;
        let inputFields = this.template.querySelectorAll('.validate');
        inputFields.forEach(inputField => {
            if(!inputField.checkValidity()) {
                inputField.reportValidity();
                isValid = false;
            }
        });
        return isValid;
    }

    uploadImageClose(){
        this.viewDocFlag = false;
    }

    // to close the document upload popup
    changeFlagValueMethod(event) {
        this.uploadAdditionalDocFlag = false;
        this.viewDocFlag = false;
        console.log('== changeFlagValueMethod ', event.detail);
    }

    docUploadSuccessfully(event){
        this.ContentDocumentId = event.detail;
        console.log('== On Doc Upload this.ContentDocumentId ---- : ',this.ContentDocumentId);
        if(this.ContentDocumentId != true){
            deleteContentDocument({previousDocumentRecordId:this.previousDocumentRecordId, loanApplicationId : this.recordId  , contentDocumentId :  this.ContentDocumentId}).then(result => {
                console.log('== deleteContentDocument result ', result);
            }).catch(error => {
                console.log('== deleteContentDocument error ', error);
            });

            createDocuments(
                {docType :this.docType, 
                vehicleDetailId : this.vehiclerecordid,
                applicantId : this.applicantid,
                loanApplicationId : this.recordId,
            }).then(result => {
                console.log('== createDocuments result ', result);
                if(this.docType == 'RTO'){
                    this.rtoDocObj.Id = result;
                }else if(this.docType == 'DPN'){
                    this.dpnDocObj.Id = result;
                }else if(this.docType == 'POA'){
                    this.poaDocObj.Id = result;
                }
                let docType = this.docType + ' ' + result;
                updateContentDocument({
                    contentDocumentId : this.ContentDocumentId,
                    loanApplicationId : this.recordId,
                    documentRecordId : result,
                    docType : docType,
                }).then(result => {
                    console.log('== updateContentDocument ', result);
                }).catch(error => {
                    console.error('Error:', error);
                });
            }).catch(error => {
                console.error('Error:', error);
            });
        }
        this.validateDocumentHandler();
    }

    handleInputFieldChange(event){
        this.disableSubmitBtn = false;
        console.log('== Doc Type ', event.target.dataset.id);
        let docType = event.target.dataset.id;
        if(docType == 'RTO'){
            this.rtoDocObj[event.target.name] = event.target.value;
            this.rtoRemarkReq = (this.rtoDocObj.Is_Document_Eligible__c == 'No' || this.rtoDocObj.Correctly_Captured__c == 'No');
        }else if(docType == 'DPN'){
            this.dpnDocObj[event.target.name] = event.target.value;
            this.dpnRemarkReq = (this.dpnDocObj.Is_Document_Eligible__c == 'No' || this.dpnDocObj.Correctly_Captured__c == 'No');
        }else if(docType == 'POA'){
            this.poaDocObj[event.target.name] = event.target.value;
            this.poaRemarkReq = (this.poaDocObj.Is_Document_Eligible__c == 'No' || this.poaDocObj.Correctly_Captured__c == 'No');
        }
    }
     // CISP-4770 - START

     moveToPayReq(){
        this.PaymentRequestpopup = true;
    }

    handleActiveSubTab(event) {
        console.log('handleActiveSubTab ');
        this.activeviewappsubtab = event.target.value;
        if ((this.activeviewappsubtab === this.label.Business_Payment && !this.viewappsubtabs.bussinesspayment) ||
            (this.activeviewappsubtab === this.label.Insurance_Details && !this.viewappsubtabs.insurancedetails) ||
            (this.activeviewappsubtab === this.label.NewUsed_Vehicles && !this.viewappsubtabs.neworusedvehicle) ||
            (this.activeviewappsubtab === this.label.Beneficiary_Details && !this.viewappsubtabs.beneficiarydetails)) {
            const evt = new ShowToastEvent({
                title: 'Warning',
                message: 'Please submit the ' + this.currentSubTab + ' tab first',
                variant: 'warning',
            });
            this.dispatchEvent(evt);
        }
    }

    handleTabSwitch(event) {
        console.log('handleTabSwitch ',this.viewappsubtabs);
        this.disbursementrecordid = event.detail;
        let tab = this.template.querySelectorAll('lightning-tabset');
        tab.forEach(element => {
            if (element.activeTabValue == Business_Payment) {
                this.currentSubTab = Insurance_Details;
                this.viewappsubtabs.insurancedetails = true;
                element.activeTabValue = Insurance_Details;
                this.disableBusinessPaymentFields = true;
            } else if (element.activeTabValue == Insurance_Details) {
                this.currentSubTab = NewUsed_Vehicles;
                this.viewappsubtabs.neworusedvehicle = true;
                element.activeTabValue = NewUsed_Vehicles;
                this.disableBusinessPaymentFields = true;
                this.disableInsuranceFields = true;
            } else if (element.activeTabValue == NewUsed_Vehicles) {
                this.currentSubTab = Beneficiary_Details;
                this.viewappsubtabs.beneficiarydetails = true;
                element.activeTabValue = Beneficiary_Details;
                this.disableBusinessPaymentFields = true;
                this.disableInsuranceFields = true;
                this.disableNewUsedVehicleFields = true;
            } else if (this.currentSubTab == Beneficiary_Details) {
                this.currentSubTab = RCU;
                this.viewappsubtabs.rcuDetails = true;
                element.activeTabValue = RCU;
                this.disableBusinessPaymentFields = true;
                this.disableInsuranceFields = true;
                this.disableNewUsedVehicleFields = true;
                this.disableBenefeciaryFields = true;
            }
        });
    }
    hidePaymentRequests(){
        this.PaymentRequestpopup = false;
    }

    handleBeneficiaryFinish(){
        console.log('handleBeneficiaryFinish');
        const fields = {};
        fields[ParentLoanApp_Field.fieldApiName] = this.recordId;
        fields[isPRSubmittedbyBE.fieldApiName] = true;
        const recordInput = { fields };
        updateRecord(recordInput)
        .then(() => {
            this.PaymentRequestpopup = false;

        })
        .catch((error) => {
            console.log('Opportunity record failed to update', recordInput);
            console.log('ERROR' + JSON.stringify(error));
        })
    }
    // CISP-4770 - END
}