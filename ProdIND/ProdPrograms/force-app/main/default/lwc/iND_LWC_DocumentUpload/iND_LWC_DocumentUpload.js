import { LightningElement, track, wire, api } from 'lwc';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import changeFilename from '@salesforce/apex/GenericUploadController.changeFilename'; 
import deleteDocument from '@salesforce/apex/IND_DocumentUploadCntrl.deleteDocument';
import getApplicantDetails from '@salesforce/apex/IND_DocumentUploadCntrl.getApplicantDetails';
import getDocuments from '@salesforce/apex/IND_DocumentUploadCntrl.getDocuments';
import inactiveDocuments from '@salesforce/apex/IND_DocumentUploadCntrl.inactiveDocuments';
import deleteContentDocument from '@salesforce/apex/IND_DocumentUploadCntrl.deleteContentDocument';
import getDocumentTypes from '@salesforce/apex/IND_DocumentUploadCntrl.getDocumentTypes';
import isDeleteable from '@salesforce/apex/IND_DocumentUploadCntrl.isDeleteable';
import getDocumentByType from '@salesforce/apex/IND_DocumentUploadCntrl.getDocumentByType';
import getUserDetails from '@salesforce/apex/IND_DocumentUploadCntrl.getUserDetails';
import currentUserId from '@salesforce/label/c.currentUserId';
import currentUserName from '@salesforce/label/c.currentUserName';
import currentUserEmailid from '@salesforce/label/c.currentUserEmailid';
import mode from '@salesforce/label/c.mode';
import currentApplicantid from '@salesforce/label/c.currentApplicantid';
import NotHaveEnoughPermission from '@salesforce/label/c.NotHaveEnoughPermission';
import IntegratorAppURL from '@salesforce/label/c.IntegratorAppURL';
import isPaymentRequestGenerated from '@salesforce/apex/LoanDisbursementController.isPaymentRequestGenerated';
import checkMAProfile from '@salesforce/apex/IND_DocumentUploadCntrl.getMAProfileName'; //CISP-2743
import isProfileCVO from '@salesforce/apex/IND_DocumentUploadCntrl.isProfileCVO'; //CISP-2743
import loanApplicationproductType from '@salesforce/apex/IND_DocumentUploadCntrl.loanApplicationproductType';
import loanApplicationCustomerType from '@salesforce/apex/IND_DocumentUploadCntrl.loanApplicationCustomerType'; //SFTRAC-286
import checkUserAbleToDeleteDoc from '@salesforce/apex/IND_DocumentUploadCntrl.checkUserAbleToDeleteDoc';
import contentDocumentPresentOrNot from '@salesforce/apex/IND_DocumentUploadCntrl.contentDocumentPresentOrNot';
import checkDeleteButtonRequired from '@salesforce/apex/IND_DocumentUploadCntrl.checkDeleteButtonRequired';

import { createRecord, updateRecord, deleteRecord } from 'lightning/uiRecordApi';
import FORM_FACTOR from '@salesforce/client/formFactor';
import DOC_ID_FIELD from '@salesforce/schema/Documents__c.Id';
import imageuploaded from '@salesforce/label/c.imageuploaded';
import DocumentDeleted from '@salesforce/label/c.DocumentDeleted';
import DocumentTypeNotSelected from '@salesforce/label/c.DocumentTypeNotSelected';
import FileUpload from '@salesforce/label/c.FileUpload';
import DOCUMENT_VEHICLE_DETAIL_FIELD from '@salesforce/schema/Documents__c.Vehicle_Detail__c'; //CISP-22284
import DOCUMENT_TYPE_FIELD from '@salesforce/schema/Documents__c.Document_Type__c';
import DOCUMENT_NUMBER from '@salesforce/schema/Documents__c.Document_Number__c';
import DOCUMENT_OPP_FIELD from '@salesforce/schema/Documents__c.Opportunity_Relation__c';
import DOCUMENT_APP_FIELD from '@salesforce/schema/Documents__c.Applicant__c';
import DOCUMENT_NAME_FIELD from '@salesforce/schema/Documents__c.Name';
import DOCUMENT_RECORDTYPEID_FIELD from '@salesforce/schema/Documents__c.RecordTypeId';
import DOCUMENT_ISACTIVE_FIELD from '@salesforce/schema/Documents__c.is_Active__c';
import IS_PHOTOCOPY_FIELD from '@salesforce/schema/Documents__c.Is_this_a_Photocopy__c';
import { NavigationMixin } from 'lightning/navigation';
import DOCUMENT_OBJECT_INFO from '@salesforce/schema/Documents__c';
import SystemModstamp from '@salesforce/schema/Account.SystemModstamp';
import getProfileName from '@salesforce/apex/GenericUploadController.getProfileName';
import getContentVersion from '@salesforce/apex/GenericUploadController.getContentVersion';
import IBL_Community_Partners_URL from '@salesforce/label/c.IBL_Community_Partners_URL';
import createDocumentForCheque from '@salesforce/apex/IND_DocumentUploadCntrl.createDocumentForCheque';// IND-4645
import countOfChequesDoc from '@salesforce/apex/IND_DocumentUploadCntrl.countOfChequesDoc';// IND-4645
import getVehicleData from '@salesforce/apex/IND_DocumentUploadCntrl.getVehicleData';// IND-4645
import DOCUMENT_ISADDITIONALDOC from '@salesforce/schema/Documents__c.Additional_Document__c';// IND-4645
import checkOwner from '@salesforce/apex/Utilities.checkOwner';
import uploadTractorDocument from '@salesforce/apex/Utilities.uploadTractorDocument';
import AadhaarCard from '@salesforce/label/c.AadhaarCard';
import DrivingLicences from '@salesforce/label/c.DrivingLicences';
import VoterIdCard from '@salesforce/label/c.VoterIdCard';
import PassportCard from '@salesforce/label/c.PassportCard';
import Guarantor from '@salesforce/label/c.Guarantor';
import Borrower from '@salesforce/label/c.Borrower';
import checkFileSize from '@salesforce/apex/IND_DocumentUploadCntrl.checkFileSize'

export default class IND_LWC_DocumentUpload extends NavigationMixin(LightningElement) {
    vehicleDetailId
    communityPartnersURL = IBL_Community_Partners_URL;
    iscommunityuser;
    isNonDividual = false;
    beneficiaryVisible;
    @track beneficiaryList = [];
    /* STRAC-49 */
    isTractor; 
    @track coborrowerList = []; 
    guarantorVisible;
    guarantorId;
    /* STRAC-49 */
    @api contentDocumentId;
    @api calledFrom;
    @api recordid = '00671000001KkqvAAC';
    label = {
        currentUserId,
        currentUserName,
        currentUserEmailid,
        currentApplicantid,
        mode,
        imageuploaded,
        DocumentDeleted,
        DocumentTypeNotSelected,
        FileUpload
    }
    @track defaultRecordTypeId;
    @track recordTypeIds;
    @track currentUserId
    @track currentUserName
    @track currentUserEmailId
    loanApplicationId;
    uploadViewDocPopup = true;
    showModal = true;
    fileUploadResp = {};
    @track docUploadSuccessfully = false;
    @track docTypes = [];
    @track docIdList = [];
    @track docUploaded = false;
    @track applicants;
    @track borrowerVisible = false;
    @track coBorrowerVisible = false;
    @track borrowerApplicantId;
    @track coBorrowerApplicantId;
    @track currentapplicantid;
    @track documentIdList=[];
    @track contentDocumentIds=[];
    @api documentrecordidfromparent;
    @api docotherrecordtype = false;
    @track documentRecordId;
    @track noDocsFound = false;
    @api filename;
    webApp = true;
    mobileTabApp = false;
    disabledFileUpload = true;
    disabledIsPhotocopy = true;
    @api isphotocopy = false;
    docType;
    @api additionaldocument;
    showFrontBackUpload = false;
    showFileUpload = false;
    documentSide = 'Front';
    isFrontUploaded = false;
    isBackUploaded = false;
    hideTabWhenPaymentGenerated = true;
    hideDeleteIconFromDatatable = true;
    isFileDelete = false;
    restrictFileFormat = false ;//CISP-2969
    isTwoWheeler = false;
    isPreview = false;
    converId;
    height = 32;
    ableToDeleteDoc = false;
    currentDocumentRecordTypeId;
    latestDocRecId;
    documentNumber;
    allowUploadBE=false;
    @track documentsConfig = {
        objectName: "ContentDocumentLink",
        tableConfig: {
            columns: [
                { api: 'ContentDocument.Title', label: 'Title', fieldName: 'title', sortable: true },
                { api: 'ContentDocument.ContentSize', label: 'Size (bytes)', fieldName: 'ContentSize', type: 'number', sortable: true, callAttributes: { alignment: 'left' } },
                { api: 'ContentDocument.FileType', label: 'File Type', fieldName: 'FileType', sortable: true },
                { api: 'ContentDocument.Owner.Name', label: 'Owner', fieldName: 'OwnerName', sortable: true },
                { api: 'ContentDocument.CreatedDate', label: 'Created Date/Time', fieldName: 'CreatedDate', type: 'date', sortable: true, typeAttributes: { 
                    year: 'numeric', 
                    month: '2-digit', 
                    day: '2-digit', 
                    hour: '2-digit',
                    minute: '2-digit',
                    second: '2-digit',
                    hour12: true
                }},
                { label: 'preview', type: 'button-icon', typeAttributes: { name: 'Preview', iconName: 'utility:preview', variant: 'brand-outline' } },
                { label: '#', type: 'button-icon', typeAttributes: { name: 'delete', iconName: 'utility:delete', variant: 'bare' } }
            ],
            hideCheckboxColumn: true
        },
        queryFilters: 'LinkedEntityId = ' + this.recordid,
        pageSize: '5',
        limit: '100'
    };


    //CISP-22305 Start
    activeTabName = 'Borrower';

    get docTypePicklist(){
        if(this.isTwoWheeler === true){
            let filteredArray = [];
            if(this.activeTabName === 'Borrower'){
                filteredArray = this.docTypes.filter(item => item.label !== "Passbook - Co-Borrower" && item.label !== "Bank Statement - Co-Borrower");
            }else{
                filteredArray = this.docTypes.filter(item => item.label !== "Passbook - Borrower" && item.label !== "Bank Statement - Borrower");

            }
            return filteredArray;
        }
        return this.docTypes;
    }
    //CISP-22305 End

    @wire(getObjectInfo, { objectApiName: DOCUMENT_OBJECT_INFO })
    documentMetaData({data, error}) {
        if(data) {
            let optionsValues = [];
            this.defaultRecordTypeId = data.defaultRecordTypeId;
            const rtInfos = data.recordTypeInfos;

            let rtValues = Object.values(rtInfos);

            for(let i = 0; i < rtValues.length; i++) {
                if(rtValues[i].name !== 'Master') {
                    optionsValues.push({
                        label: rtValues[i].name,
                        value: rtValues[i].recordTypeId
                    })
                }
            }

            this.recordTypeIds = optionsValues;
        }
        else if(error) {
            window.console.log('Error ===> '+JSON.stringify(error));
        }
    }

    @wire(getPicklistValues, {
        recordTypeId: '$defaultRecordTypeId',
        fieldApiName: DOCUMENT_TYPE_FIELD
    })
    documentTypeValues;

    renderedCallback() {
       
    }
    get acceptedFormats() {
        if(this.restrictFileFormat)//CISP-2969
        {
            return ['.jpg','.jpeg']; 
        }
        else {
            return ['.jpg','.png', '.jpeg', '.docx', '.pdf'];
        }
        
    }

    async connectedCallback() {
        await loanApplicationproductType({ loanApplicationId: this.recordid })
        .then(response => {
            console.log('response---'+response);
           // if (response===true) {
            if(response== 'Two Wheeler'){
                this.isTwoWheeler = true;
                // this.disabledIsPhotocopy=true;
            }
            else if(response == 'Tractor'){
                this.isTractor = true;
            }
            });
        await loanApplicationCustomerType({ loanApplicationId: this.recordid }) //SFTRAC-286
        .then(response => {
           // if (response===true) {
            if(response== 'Non-Individual'){
                this.isNonDividual = true; 
            }
        });
        await checkOwner({loanAppId:this.recordid}).then(response=>{
            if(response == true){
                this.allowUploadBE = true;
            }
        });
        // JIRA ticket:  INDI-4678,  Imperative call to isPaymentRequestGenerated method
        //checking if, payment req. is generated then disabled the ligtning-tab(upload) on UI.
        await isPaymentRequestGenerated({ loanApplicationId: this.recordid })
        .then(response => {
           console.log('response from apex: ',response)
           if(response === true)
           {
               this.hideDeleteIconFromDatatable = false;
               this.hideTabWhenPaymentGenerated = false;
           }
        })
        .catch(error => {
           console.error(error);
        });

        //CISP-2743 --start
        console.log('this.documentrecordidfromparent '+this.documentrecordidfromparent);
        await checkMAProfile({ loanApplicationId: this.recordid }).then((response) => {
            if(response) {
                console.log('MA profile value: ',response)
                this.hideDeleteIconFromDatatable = false;
            }
        })
        .catch((err) => {
            console.log('err',err);
        })
        //CISP-2743 --end
   
        this.hideDeleteIconFromDatatable === false ? this.documentsConfig.tableConfig.columns.splice(6,1) : this.documentsConfig.tableConfig.columns;

        getProfileName({ loanApplicationId: this.recordid })
        .then(result => {
            console.log('Result in generic upload ', result);
            if(result){
                this.iscommunityuser = result;
            }
            
        })
        .catch(error => {
            console.error('Error:', error);
        });
        console.debug(FORM_FACTOR);
        if (FORM_FACTOR != 'Large') {
            this.mobileTabApp = true;
            this.webApp = false;
        } else {
            this.mobileTabApp = false;
            this.webApp = true;
        } 
        getApplicantDetails({loanApplicationId : this.recordid})
        .then(result => {
            if(result){
                if(result.length>0){
                    this.applicants = result;
                    for(let res of result){
                        if(res.Applicant_Type__c.includes('Borrower')){
                            this.borrowerVisible = true;
                            this.borrowerApplicantId = res.Id;
                        }else if(res.Applicant_Type__c.includes('Co-borrower')){
                            this.coBorrowerVisible = true;
                            this.coBorrowerApplicantId = res.Id;
                            this.coborrowerList.push({Id:res.Id,Name:res.Name});
                        }else if(res.Applicant_Type__c.includes('Guarantor')){ //SFTRAC-49
                            this.guarantorVisible = true;
                            this.guarantorId = res.Id;
                        }    
                        else if(res.Applicant_Type__c.includes('Beneficiary')){ //SFTRAC-286
                            this.beneficiaryVisible = true;
                            this.beneficiaryList.push({Id:res.Id,Name:res.Name});                            
                        }
                    }
                }
            }
            }
        ).catch(error => {
            console.log('FileName not change error'+JSON.stringify(error));
        });  
        // INDI-4645
        getVehicleData({ loanApplicationId : this.recordid })
          .then(result => {
            console.log('Result', result);
            if(result){
                this.vehicleDetailId = result;
            }
          })
          .catch(error => {
            console.error('Error:', error);
        });
        // INDI-4645
        // getDocumentData({loanApplicationId : this.loanApplicationId})
        // .then(result => {

        //     }
        // ).catch(error => {
        //     console.log('FileName not change error'+JSON.stringify(error));
        // });  
        if (this.documentrecordidfromparent) {
            console.log('in  documentrecordidfromparent: ', );
            this.documentRecordId = this.documentrecordidfromparent;
            this.documentsConfig.queryFilters = 'LinkedEntityId =\'' + this.recordid + '\'';
            console.log('in  documentrecordidfromparent: ', this.documentRecordId);
        }
        
        checkDeleteButtonRequired({ loanApplicationId: this.recordid})
        .then(res => {
            if(!res && this.isTwoWheeler){
                this.documentsConfig.tableConfig.columns.pop();
            }
        })
    }


    handleRecordType(event){
        try{
        if(this.documentRecordId && this.defaultRecordTypeId && event.target.value!=this.defaultRecordTypeId){
            this.defaultRecordTypeId = event.target.value;
            const fields = {};
            fields[DOCUMENT_TYPE_FIELD.fieldApiName] = '';
            fields[DOCUMENT_RECORDTYPEID_FIELD.fieldApiName] = this.defaultRecordTypeId; 
            fields[DOC_ID_FIELD.fieldApiName] = this.documentRecordId;
            var objRecordInput = {fields};
            updateRecord(objRecordInput).then(response => {}).catch(error => {
                console.error('Error: ' +JSON.stringify(error));
            });
        }else{
            this.defaultRecordTypeId = event.target.value;
        }
        }catch(err){
            console.debug(err);
        }
    }
    handleDocType(event) {
        console.log('handleDocType : ',);
        try{
            console.log('doctype--'+event.target.value);
            if(this.isTractor && event.target.value == 'Electronic Bill'){ //STRAC-49
                this.disabledIsPhotocopy = false;
            }
            else{
                this.disabledIsPhotocopy = true;
            }
        if (this.documentRecordId && this.docType && event.target.value!=this.docType) {
            console.log('OUTPUThandleDocType if part: ',);
            this.docType = event.detail.value;
            const fields = {};
            //CISP-22284 Start
            if(this.isTwoWheeler){
                if(this.docType == 'RTO' || this.docType == 'DPN' || this.docType == 'Agreement Wrapper Booklet'){
                    fields[DOCUMENT_VEHICLE_DETAIL_FIELD.fieldApiName] = this.vehicleDetailId;
                }else{
                    fields[DOCUMENT_VEHICLE_DETAIL_FIELD.fieldApiName] = '';
                }
                //CISP-22434 Start
                if(this.docType == 'Borrower\'s Passbook' || this.docType == 'Borrower\'s Bank Statement' || this.docType == 'Co-Borrower\'s Passbook' || this.docType == 'Co-Borrower\'s Bank Statement'){
                    fields[DOCUMENT_ISADDITIONALDOC.fieldApiName] = true;
                }
                //CISP-22434 End
            }
            //CISP-22284 End
            fields[DOCUMENT_TYPE_FIELD.fieldApiName] = this.docType; 
            fields[DOC_ID_FIELD.fieldApiName] = this.documentRecordId;
            for(let documentType of this.docTypes){
                if(documentType.value.includes(this.docType)){
                    if(documentType.recordtype.includes('KYC')){
                        // this.disabledIsPhotocopy = true;
                        this.restrictFileFormat = true; //CISP-2969
                    }else{
                        // if(this.isTwoWheeler === false){this.disabledIsPhotocopy = false;}
                        this.restrictFileFormat = false; //CISP-2969
                    }
                    fields[DOCUMENT_RECORDTYPEID_FIELD.fieldApiName] = documentType.recordtypeid;
                    this.currentDocumentRecordTypeId = documentType.recordtypeid;
                }
            }
            var objRecordInput = {fields};
            updateRecord(objRecordInput).then(response => {
                console.debug(response);
            }).catch(error => {
                console.error('Error: ' +JSON.stringify(error));
            });
            
        } else if(!event.detail.value) {
            console.log('OUTPUThandleDocType else if part: ',);
            const evt = new ShowToastEvent({
                message: this.label.DocumentTypeNotSelected,
                variant: 'warning',
            });
            this.dispatchEvent(evt);
        }else{
            console.log('OUTPUThandleDocType else part: ',);
            this.docType = event.detail.value;
            this.createDocument();
        }
        console.debug(this.documentRecordId);
        if(this.isTractor && this.isNonDividual ){
            if ( this.documentNumber !== undefined && this.documentNumber !== null && this.documentNumber !== ''){
            if(this.documentRecordId && (this.docType == AadhaarCard  || this.docType == DrivingLicences 
                || this.docType == VoterIdCard  || this.docType == PassportCard)){
            this.showFrontBackUpload = true;
            this.showFileUpload = false;
        } else if(this.documentRecordId && this.documentNumber){
            this.showFileUpload = true;
            this.showFrontBackUpload = false;
        }
        }else {
            const evt = new ShowToastEvent({
                message: 'Please Enter the Document Number',
                variant: 'warning',
            });
            this.dispatchEvent(evt);
        }
    }
    else if (this.isTractor && !this.isNonDividual){
        if(this.documentRecordId && (this.docType == AadhaarCard  || this.docType == DrivingLicences 
            || this.docType == VoterIdCard  || this.docType == PassportCard)){
            this.showFrontBackUpload = true;
            this.showFileUpload = false;
        } else if(this.documentRecordId){
            this.showFileUpload = true;
            this.showFrontBackUpload = false;
        }
    }
    else{
        if(this.documentRecordId && (this.docType == AadhaarCard  || this.docType == DrivingLicences 
            || this.docType == VoterIdCard  || this.docType == PassportCard)){
            this.showFrontBackUpload = true;
            this.showFileUpload = false;
        } else if(this.documentRecordId){
            this.showFileUpload = true;
            this.showFrontBackUpload = false;
        }
    }
        }catch(err){
            console.debug(err);
        }
    }
    handleDocNumber(event) {
        try{
            if(!this.docType){
                const evt = new ShowToastEvent({
                    message: 'Please select the document type first',
                    variant: 'warning',
                });
                this.dispatchEvent(evt);
                this.documentNumber = '';
            }
        if (this.documentRecordId && this.docType) {
            this.documentNumber = event.detail.value;
            const fields = {};
            fields[DOCUMENT_NUMBER.fieldApiName] = this.documentNumber; 
            fields[DOC_ID_FIELD.fieldApiName] = this.documentRecordId;
            
            var objRecordInput = {fields};
            updateRecord(objRecordInput).then(response => {
                console.debug(response);
            }).catch(error => {
                console.error('Error: ' +JSON.stringify(error));
            });
        } 
        if(this.isTractor && this.isNonDividual ){
            if ( this.documentNumber !== undefined && this.documentNumber !== null && this.documentNumber !== ''){
                if(this.documentRecordId && (this.docType == AadhaarCard  || this.docType == DrivingLicences 
                    || this.docType == VoterIdCard  || this.docType == PassportCard)){
                this.showFrontBackUpload = true;
                this.showFileUpload = false;
            } else if(this.documentRecordId && this.documentNumber){
                this.showFileUpload = true;
                this.showFrontBackUpload = false;
            }
            }else {
                const evt = new ShowToastEvent({
                    message: 'Please Enter the Document Number',
                    variant: 'warning',
                });
                this.dispatchEvent(evt);
            }
        }
        else if (this.isTractor && !this.isNonDividual){
            if(this.documentRecordId && (this.docType == AadhaarCard  || this.docType == DrivingLicences 
                || this.docType == VoterIdCard  || this.docType == PassportCard)){
                this.showFrontBackUpload = true;
                this.showFileUpload = false;
            } else if(this.documentRecordId){
                this.showFileUpload = true;
                this.showFrontBackUpload = false;
            }
        }
        }catch(err){
            console.debug(err);
        }
    }

    handlerIsPhotocopy(event) {
        this.isPhotocopy = event.target.checked;
        console.debug(this.isPhotocopy);
        if(this.isPhotocopy!=undefined || this.isPhotocopy!=null){
            const fields = {};
            fields[DOC_ID_FIELD.fieldApiName] = this.documentRecordId;
            fields[IS_PHOTOCOPY_FIELD.fieldApiName] = this.isPhotocopy;
            var objRecordInput = {fields};
            updateRecord(objRecordInput).then(response => {
                console.debug(response);
            }).catch(error => {
                console.error('Error: ' +JSON.stringify(error));
            });
        }
    }
    async handleFileUploadForTW(event){
        console.log('handleFileUploadForTW ' , event.detail.files);
        let validDoc = true;
        if(event.detail.files.length >0){
            let file = event.detail.files[0];
            await checkFileSize({docId : this.documentRecordId}).then(data=>{
                console.log('data',data);
                if(data) {validDoc = false;const evt = new ShowToastEvent({
                    title: 'Error',
                    message: data,
                    variant: 'error',
                });
                this.dispatchEvent(evt);}
            }).catch(error =>{
                console.log('error',error);
            })
        }
        if(validDoc){
            try{
                for (var index = 0; index < event.detail.files.length; index++) {
                    this.docIdList.push(event.detail.files[index].documentId)
                    this.contentDocumentIds.push(event.detail.files[index].documentId);
                }
                console.log('this.docIdList ' + this.docIdList);
                //this.contentDocumentId = event.detail.files[0].documentId;
    
                console.log('Check Document Id : ' + this.contentDocumentId);
                const evt = new ShowToastEvent({
                    title: 'Uploaded',
                    message: 'File Uploaded successfully..!',
                    variant: 'success',
                });
                this.dispatchEvent(evt);
                if(this.showFrontBackUpload)
                    this.isFrontUploaded = true;
                else
                    this.isFrontUploaded = false;
                    if(this.docType != 'Cheques SPDC' && this.docType != 'IHM Receipt'){    // INDI-4645
                        inactiveDocuments({docId : this.documentRecordId,
                                        docType : this.docType,
                                        loanApplicationId : this.recordid,
                                        documentSide : 'Front',applicantId : this.currentapplicantid
                                        })
                                .then(result => {console.log('OUTPUT  result in inactive document: ',)}
                                ).catch(error => {
                                    console.error(error);
                        }); 
                    }// INDI-4645
                this.documentIdList.push(this.documentRecordId);
                this.latestDocRecId = this.documentRecordId;
                if(this.showFrontBackUpload && this.isFrontUploaded && this.isBackUploaded){
                    console.log('in front upload  : ',);
                this.documentRecordId = null;
                }
                if((this.showFrontBackUpload == false && this.isFrontUploaded == false) && !this.isTractor){
                    console.log('in front upload  when other doc: ',);
                    this.documentRecordId = null; 
                }
                this.docType = '';
                this.documentNumber = '';
                this.getAllDocumentType(); // INDI-4645 changes (update document list drop down)
                if(this.isTractor && this.calledFrom == 'demographic'){
                    this.dispatchEvent(new CustomEvent('changeflagvalue', { detail: this.documentRecordId }));
                }
            }catch(err){
                console.debug(err);
            }
            }
    }

    handleFileUpload(event) {
        if(this.isTwoWheeler){
            this.handleFileUploadForTW(event);
        }else{
        console.log('handle')
        console.log('handleFileUpload ' , event.detail.files);
        try{
            for (var index = 0; index < event.detail.files.length; index++) {
                this.docIdList.push(event.detail.files[index].documentId)
                this.contentDocumentIds.push(event.detail.files[index].documentId);
            }
            console.log('this.docIdList ' + this.docIdList);
            //this.contentDocumentId = event.detail.files[0].documentId;

            console.log('Check Document Id : ' + this.contentDocumentId);
            const evt = new ShowToastEvent({
                title: 'Uploaded',
                message: 'File Uploaded successfully..!',
                variant: 'success',
            });
            this.dispatchEvent(evt);
            if(this.showFrontBackUpload)
                this.isFrontUploaded = true;
            else
                this.isFrontUploaded = false;
                if(this.docType != 'Cheques SPDC' && this.docType != 'IHM Receipt'){    // INDI-4645
                    inactiveDocuments({docId : this.documentRecordId,
                                    docType : this.docType,
                                    loanApplicationId : this.recordid,
                                    documentSide : 'Front',applicantId : this.currentapplicantid
                                    })
                            .then(result => {console.log('OUTPUT  result in inactive document: ',)}
                            ).catch(error => {
                                console.error(error);
                    }); 
                }// INDI-4645
            this.documentIdList.push(this.documentRecordId);
            this.latestDocRecId = this.documentRecordId;
            if(this.showFrontBackUpload && this.isFrontUploaded && this.isBackUploaded){
                console.log('in front upload  : ',);
            this.documentRecordId = null;
            }
            if((this.showFrontBackUpload == false && this.isFrontUploaded == false) && !this.isTractor){
                console.log('in front upload  when other doc: ',);
                this.documentRecordId = null; 
            }
            this.docType = '';
            this.documentNumber = '';
            this.getAllDocumentType(); // INDI-4645 changes (update document list drop down)
            if(this.isTractor && this.calledFrom == 'demographic'){
                this.dispatchEvent(new CustomEvent('changeflagvalue', { detail: this.documentRecordId }));
            }
        }catch(err){
            console.debug(err);
        }
        }
    }
    async handleBackFileUploadForTW(event){
        console.log('handleFileUploadForTW ' , event.detail.files);
        let validDoc = true;
        if(event.detail.files.length >0){
            let file = event.detail.files[0];
            await checkFileSize({docId : this.documentRecordId}).then(data=>{
                console.log('data',data);
                if(data) {validDoc = false;const evt = new ShowToastEvent({
                    title: 'Error',
                    message: data,
                    variant: 'error',
                });
                this.dispatchEvent(evt);}
            }).catch(error =>{
                console.log('error',error);
            })
        }
        if(validDoc){
            try{
                for (var index = 0; index < event.detail.files.length; index++) {
                    this.docIdList.push(event.detail.files[index].documentId)
                    this.contentDocumentIds.push(event.detail.files[index].documentId);
                }
                console.log('this.docIdList ' + this.docIdList);
                //this.contentDocumentId = event.detail.files[0].documentId;
    
                console.log('Check Document Id : ' + this.contentDocumentId);
                const evt = new ShowToastEvent({
                    title: 'Uploaded',
                    message: 'File Uploaded successfully..!',
                    variant: 'success',
                });
                this.dispatchEvent(evt);
                this.isBackUploaded = true;
                inactiveDocuments({docId : this.documentRecordId,
                                   docType : this.docType,
                                   loanApplicationId : this.recordid,
                                   documentSide : 'Back',applicantId : this.currentapplicantid
                                  })
                        .then(result => {}
                        ).catch(error => {
                            console.error(error);
                        }); 
                this.documentIdList.push(this.documentRecordId);
                this.latestDocRecId = this.documentRecordId;
                if(this.showFrontBackUpload && this.isFrontUploaded && this.isBackUploaded){
                    console.log('in back upload  : ',);
                    this.documentRecordId = null;
                    }
                    if(this.showFrontBackUpload == false && this.isBackUploaded == false){
                        console.log('in back upload  when other doc: ',);
                        this.documentRecordId = null; 
                    }
                this.docType = '';
                this.documentNumber = '';
            }catch(err){
                console.debug(err);
            }
        }

    }

    handleBackFileUpload(event){
        if(this.isTwoWheeler){
            this.handleBackFileUploadForTW(event);
        }else{
        console.log('handleBackFileUpload')
        console.log('handleBackFileUpload ' , event.detail.files);
        try{
            for (var index = 0; index < event.detail.files.length; index++) {
                this.docIdList.push(event.detail.files[index].documentId)
                this.contentDocumentIds.push(event.detail.files[index].documentId);
            }
            console.log('this.docIdList ' + this.docIdList);
            //this.contentDocumentId = event.detail.files[0].documentId;

            console.log('Check Document Id : ' + this.contentDocumentId);
            const evt = new ShowToastEvent({
                title: 'Uploaded',
                message: 'File Uploaded successfully..!',
                variant: 'success',
            });
            this.dispatchEvent(evt);
            this.isBackUploaded = true;
            inactiveDocuments({docId : this.documentRecordId,
                               docType : this.docType,
                               loanApplicationId : this.recordid,
                               documentSide : 'Back',applicantId : this.currentapplicantid
                              })
                    .then(result => {}
                    ).catch(error => {
                        console.error(error);
                    }); 
            this.documentIdList.push(this.documentRecordId);
            this.latestDocRecId = this.documentRecordId;
            if(this.showFrontBackUpload && this.isFrontUploaded && this.isBackUploaded){
                console.log('in back upload  : ',);
                this.documentRecordId = null;
                }
                if(this.showFrontBackUpload == false && this.isBackUploaded == false){
                    console.log('in back upload  when other doc: ',);
                    this.documentRecordId = null; 
                }
            this.docType = '';
            this.documentNumber = '';
        }catch(err){
            console.debug(err);
        }
        }
    }

    saveDocumentRecord() {
        const docFields = {};
        console.log('Check Document Values : ' + this.documentRecordId, '', this.docType, '', this.isPhotocopy);
        docFields[DOC_ID_FIELD.fieldApiName] = this.documentRecordId;
        docFields[DOCUMENT_TYPE_FIELD.fieldApiName] = this.docType;
        docFields[DOCUMENT_NAME_FIELD.fieldApiName] = this.docType;
        docFields[IS_PHOTOCOPY_FIELD.fieldApiName] = this.isPhotocopy;
        this.updateRecordDetails(docFields)
            .then(() => {
                this.docUploadSuccessfully = true;
                console.log('File Uploaded');
                this.dispatchEvent(new CustomEvent('fileuploadstatus', { detail: this.docUploadSuccessfully }));
            });
        this.docUploaded = true;
    }

    async uploadDone() {
        try {
            let result = await contentDocumentPresentOrNot({'docId': this.latestDocRecId});
            if(!result){
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Info',
                        message: 'Please upload document or click on cancel.',
                        variant: 'warning'
                    })
                );
                return;
            }
        } catch (error) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Something Went Wrong!',
                    variant: 'error'
                })
            );
            return;
        }
        console.log('OUTPUT uploadDone: ',);
        console.log('this.showFrontBackUpload ',this.showFrontBackUpload);
        console.log('this.isFrontUploaded ',this.isFrontUploaded);
        console.log('this.isBackUploaded: ',this.isBackUploaded);
        //this.uploadViewDocPopup = false;
        if(this.showFrontBackUpload && (!this.isFrontUploaded || !this.isBackUploaded)){
            const evt = new ShowToastEvent({
                title: 'Error!!',
                message: 'Please upload both sides of the document!',
                variant: 'error',
            });
            this.dispatchEvent(evt);
        } else {
            if(this.isTractor && FORM_FACTOR != 'Large'){
                inactiveDocuments({docId : this.documentRecordId,docType : this.docType,loanApplicationId : this.recordid,documentSide : 'Back',applicantId : this.currentapplicantid})
                .then(result => {}
                ).catch(error => {}); 
            }
            console.log('OUTPUT handle done esle part : ',);
            console.log('Check COntent File Id :' , this.contentDocumentId);
            this.fileUploadResp.contentDocumentId = this.contentDocumentId;
            this.fileUploadResp.DocumentId = this.documentRecordId;
            console.log('OUTPUT this.fileUploadResp: ',this.fileUploadResp);
            this.dispatchEvent(new CustomEvent('changeflagvalue', { detail: this.fileUploadResp }));
            this.uploadViewDocPopup = false;
        }
    }

    uploadImageClose() {
        if(this.documentRecordI){
            deleteRecord(this.documentRecordId)
            .then(() => {
                console.debug('Record deleted');
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error deleting record',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
            });
        }
        this.uploadViewDocPopup = false;
        this.dispatchEvent(new CustomEvent('changeflagvalue', { detail: this.contentDocumentId }));
    }

    hideModalBox() {
        this.isPreview = false;
    }

    captureCustomerImageApp() {
        this.latestDocRecId = this.documentRecordId;
        var appDocType = ['Aadhaar', 'Driving Licence', 'PAN', 'Passport', 'Voter Id', 'Form 60', 'Bank Statement', 'Electronic Bill', 'Telephone bill', 'Post paid mobile bill', 'Gas bill', 'Water Bill', 'Property or municipal tax receipt', 'Govt pension payment order', 'Govt letter of accommodation allotment', 'Customer ITR', 'Customer Bank Statement'];
        //var appDocType = ['36', '4', 'PAN', '5', '7', 'Form 60', 'Bank Statement', 'Electronic Bill', '3', 'Post paid mobile bill', 'Gas bill', 'Water Bill', 'Property or municipal tax receipt', 'Govt pension payment order', 'Govt letter of accommodation allotment', 'Customer ITR', 'Customer Bank Statement'];
        var oppDocType = ['Customer Insurance Policy', 'Vehicle RC Copy', 'Vehicle Image', 'RC Document'];
        if(this.isTractor){ 
        var appDocType = ['Aadhaar', 'Driving Licence', 'PAN', 'Passport', 'Voter Id', 'Form 60', 'Bank Statement', 'Electronic Bill', 'Telephone bill', 'Post paid mobile bill', 'Gas bill', 'Water Bill', 'Property or municipal tax receipt', 'Govt pension payment order', 'Govt letter of accommodation allotment', 'Customer ITR', 'Customer Bank Statement','Electronic Bill','House Tax Receipt','Land document','Sale agreement','Leased land proof','Seller RC Document','Exchanged asset RC Document','Form of Particular / RC - Borrower Asset','Form of Particular / RC - Co-Borrower Asset','Form of Particular / RC - Guarantor Asset','Vahan Extract','Foreclosure letter for closed existing loan','Release letter','Loan NOC other Bank','CH/DCH FI format','Loan Statement 1','Loan Statement 2','Loan Statement 3','OD clearance proof 1','OD clearance proof 2','OD clearance proof 3','OD clearance proof 4','ITR-Forms','Salary certificate','Work order','Affidavit','Talathi/Sarpanch Certificate','Subsidy sanction letter','Fund Utilisation letter for Refinance'];
        if(this.isNonDividual){
            var appDocType = ['Aadhaar', 'Driving Licence', 'PAN', 'Passport', 'Voter Id', 'Form 60', 'Bank Statement', 'Electronic Bill', 'Telephone bill', 'Post paid mobile bill', 'Gas bill', 'Water Bill', 'Property or municipal tax receipt', 'Govt pension payment order', 'Govt letter of accommodation allotment', 'Customer ITR', 'Customer Bank Statement','Electronic Bill','House Tax Receipt','Land document','Sale agreement','Leased land proof','Seller RC Document','Exchanged asset RC Document','Form of Particular / RC - Borrower Asset','Form of Particular / RC - Co-Borrower Asset','Form of Particular / RC - Guarantor Asset','Vahan Extract','Foreclosure letter for closed existing loan','Release letter','Loan NOC other Bank','CH/DCH FI format','Loan Statement 1','Loan Statement 2','Loan Statement 3','OD clearance proof 1','OD clearance proof 2','OD clearance proof 3','OD clearance proof 4','ITR-Forms','Salary certificate','Work order','Affidavit','Talathi/Sarpanch Certificate','Subsidy sanction letter','Fund Utilisation letter for Refinance',            'PARTNERSHIP DEED','PARTNERSHIP REGISTRATION CERT','MEMORANDUM OF ASSOCIATION','ARTICLES OF ASSOCIATION','CERTIFICATE OF COMMENCEMENT OF BUSINESS','CERTIFICATE OF INCORPORATION','TRUST DEED','SHOPS & ESTABLISHMENT CERTIFICATE','GST CERTIFICATE','UDYAM REGISTRATION CERTIFICATE','SALES TAX REGISTRATION CERTIFICATE','MSME REGISTRATION CERTIFICATE','UDYOG AADHAAR REG CERTIFICATE','Utility bill in the name of company'];
        }
        }
        this.leadId = this.currentapplicantid;
        if (appDocType.includes(this.docType)) {
            this.leadId = this.currentapplicantid;
        } else if (oppDocType.includes(this.doctType)) {
            this.leadId = this.recordid;
        }
        if(this.docType){
            let userDetails;
            getUserDetails({})
            .then(result => {
            if(result){
                userDetails = result;
                this[NavigationMixin.Navigate]({
                    type: "standard__webPage",
                    attributes: {
                        url: IntegratorAppURL + this.label.currentApplicantid + '=' + this.leadId + '&' + this.label.currentUserId + '=' + userDetails[this.label.currentUserId] + '&' + this.label.mode + '=' + this.docType + '&' + this.label.currentUserName + '=' + userDetails[this.label.currentUserName] + '&' + this.label.currentUserEmailid + '=' + userDetails[this.label.currentUserEmailid] + '&documentSide=' + this.documentSide + '&loanApplicationId=' +  this.recordid + '&documentRecordTypeId=' + this.currentDocumentRecordTypeId + '&documentRecordId=' + this.documentRecordId
                    }
                });
            }
            }).catch(error => {
                console.debug(error);
            });
        }
        
    }

    captureFrontApp(){
        this.documentSide = 'Front';
        this.captureCustomerImageApp();
    }

    captureBackApp(){
        this.documentSide = 'Back';
        this.captureCustomerImageApp();
    }

    handleMainTab(event){
        this.docTypes = [];
        getDocumentTypes({loanApplicationId : this.recordid, 
            loanApplicantId : this.borrowerApplicantId,
            action: event.target.value})
        .then(result => {
        if(result){
            this.docTypes = JSON.parse(result);
        }
        }).catch(error => {
            console.debug(error);
        });
    }
    handleActive(event){
            this.docTypes = [];
            this.activeTabName = event.target.value; //CISP-22305
            if(this.isTractor){ //SFTRAC-49
                if(this.borrowerVisible && event.target.label == Borrower){
                    this.currentapplicantid = this.borrowerApplicantId;
                }else if(this.guarantorVisible && event.target.label == Guarantor){
                    this.currentapplicantid = this.guarantorId;
                }else if(this.applicants){
                    for (let index = 0; index < this.applicants.length; index++) {
                        let element = this.applicants[index];
                        if(element.Id.includes(event.target.value)){
                            this.currentapplicantid = element.Id;
                        }
                    }
                }
            }else{
                if(this.applicants){
                    this.applicants.forEach(element => {
                        if(element.Applicant_Type__c.includes(event.target.value)){
                            this.currentapplicantid = element.Id;
                        }
                    });
                }
            }
            console.log('currentApplicantId---- Test '+this.currentapplicantid);
            console.debug(this.currentapplicantid);
            if(this.isNonDividual && this.isTractor && event.target.label == 'Borrower'){
            getDocumentTypes({loanApplicationId : this.recordid, 
                                loanApplicantId : this.currentapplicantid,
                                action: 'Upload',customerType: 'Non-Individual'})
            .then(result => {
                if(result){
                    this.docTypes = JSON.parse(result);
                }
            }).catch(error => {
                console.debug(error);
            });}
            else{
            getDocumentTypes({loanApplicationId : this.recordid, 
                                loanApplicantId : this.currentapplicantid,
                                action: 'Upload'})
            .then(result => {
                if(result){
                    this.docTypes = JSON.parse(result);
                }
            }).catch(error => {
                console.debug(error);
            });
            }
        if(this.documentRecordId && this.currentapplicantid){
            const fields = {};
            fields[DOCUMENT_APP_FIELD.fieldApiName] = this.currentapplicantid;
            fields[DOC_ID_FIELD.fieldApiName] = this.documentRecordId;
            var objRecordInput = {fields};
            updateRecord(objRecordInput).then(response => {
                console.debug(response)
            }).catch(error => {
                console.error('Error: ' +JSON.stringify(error));
            });
        }else if(!this.isTractor){
            if(this.applicants){
                this.applicants.forEach(element => {
                    if(element.Applicant_Type__c.includes(event.target.value)){
                        this.currentapplicantid = element.Id;
                    }
                });
            }
        }
    }
    handleViewTab(event){
        this.docTypes = [];
        this.activeTabName = event.target.value; //CISP-22305
        if(this.isTractor){ //SFTRAC-49
            if(this.borrowerVisible && event.target.label == Borrower){
                this.currentapplicantid = this.borrowerApplicantId;
            }else if(this.guarantorVisible && event.target.label == Guarantor){
                this.currentapplicantid = this.guarantorId;
            }else if(this.applicants){
                for (let index = 0; index < this.applicants.length; index++) {
                    let element = this.applicants[index];
                    if(element.Id.includes(event.target.value)){
                        this.currentapplicantid = element.Id;
                        break;
                    }
                }
            }
        }else{
            if(this.applicants){
                this.applicants.forEach(element => {
                    if(element.Applicant_Type__c.includes(event.target.value)){
                        this.currentapplicantid = element.Id;
                    }
                });
            }
        }
        console.debug(this.currentapplicantid);
        getDocumentTypes({loanApplicationId : this.recordid, 
            loanApplicantId : this.currentapplicantid,
            action: 'View'})
        .then(result => {
            if(result){
                this.docTypes = JSON.parse(result);
                if(this.docTypes.length>0){
                    this.noDocsFound = false;    
                }else{
                    this.noDocsFound = true;
                }
            }
        }).catch(error => {
            console.debug(error);
        });
        
        getDocuments({loanApplicationId : this.recordid,applicantId : this.currentapplicantid})
        .then(result => {
            console.log('getDoc ---',result);
            if(result){
                let docIds = [];
                let docIdsString = '';
                if(result.length>0){
                    for(let id of result){
                        docIds.push('\''+id+'\'');
                    }
                    if(docIds && docIds.length>0){
                        docIdsString = '('+docIds.filter(Boolean).join(",")+')';
                        this.documentsConfig.queryFilters = 'Id IN '+docIdsString;
                    }else{
                        this.noDocsFound = true;    
                    }
                }else{
                    this.noDocsFound = true;
                }
            }else{
                this.noDocsFound = true;
            }
        }
        ).catch(error => {
            console.error(error);
        }); 
    }
    handleDocTypeFromView(event){
        try{
            console.log('event.target : ',event.target.value);
            let typeOfDoc = event.target.value;
            if(this.isTractor){ //SFTRAC-49
                if(this.borrowerVisible && event.target.dataset.applicant == Borrower){
                    this.currentapplicantid = this.borrowerApplicantId;
                }else if(this.guarantorVisible && event.target.dataset.applicant == Guarantor){
                    this.currentapplicantid = this.guarantorId;
                }else if(this.applicants){
                    for (let index = 0; index < this.applicants.length; index++) {
                        let element = this.applicants[index];
                        if(element.Id.includes(event.target.dataset.applicant)){
                            this.currentapplicantid = element.Id;
                        }
                    }
                }
            }else{
                if(this.applicants){
                    this.applicants.forEach(element => {
                        if(element.Applicant_Type__c.includes(event.target.dataset.applicant)){
                            this.currentapplicantid = element.Id;
                        }
                    });
                }
            }
        console.log('---',this.currentapplicantid);
        getDocumentByType({ loanApplicationId : this.recordid,applicantId: this.currentapplicantid,
                            docType:  typeOfDoc})
        .then(result => {
            console.log('getDocumentByType',result);
            if(result){
                console.log('getDocumentByType',result);
                let docIds = [];
                let docIdsString = '';
                if(result.length>0){
                    for(let id of result){
                        docIds.push('\''+id+'\'');
                    }
                    if(docIds && docIds.length>0){
                        docIdsString = '('+docIds.filter(Boolean).join(",")+')';
                        console.log('OUTPUT docIdsString: ',docIdsString);
                        console.log('OUTPUT : ',this.docTypes);
                        if(typeOfDoc == 'All'){
                            console.log('in if when doc is all : ',);
                        this.documentsConfig.queryFilters = 'Id IN '+docIdsString;
                        }else if(typeOfDoc == 'TVR'){
                            console.log('in tvr : ',);
                            this.documentsConfig.queryFilters = 'Id IN '+docIdsString;
                        }
                        else if(typeOfDoc == 'AML'){
                            console.log('in AML : ',);
                            this.documentsConfig.queryFilters = 'Id IN '+docIdsString;
                        }
                        else{
                            console.log('in else when doc is other : ',);
                        this.documentsConfig.queryFilters = 'LinkedEntityId IN '+docIdsString;
                        }
                        const objChild = this.template.querySelector('c-l-W-C_-L-O-S_-Data-table-S-F');
                        objChild.fetchRecords();
                    }else{
                        this.noDocsFound = true;    
                    }
                }else{
                    this.noDocsFound = true;
                }
            }else{
                this.noDocsFound = true;
            }
        })
        .catch(error => {
            this.isLoading=false;
        });
    }catch(err){
        console.debug(err);
    }
        
    }
    handleRowAction(event){
        const actionName = event.detail.action.name;
 
        switch (actionName) {
            case 'Preview':
                this.previewFile(event);
                break;
            case 'Download':
                this.downloadFile(event);
                break;
            case 'delete':
                this.deleteFile(event);
                break;
            default:
        }
    }
  
    async deleteFile(event) {
        console.debug(JSON.stringify(event.detail.row));
        await checkUserAbleToDeleteDoc({LinkedEntityId: event.detail.row.LinkedEntityId, loanApplicationId: this.recordid})
        .then((res) => {
            if(res == true) {
                this.ableToDeleteDoc = true;
            }else {
                this.ableToDeleteDoc = false;
            }
        });
        // CISP-2743 -- start
        await isProfileCVO({ LinkedEntityId: event.detail.row.LinkedEntityId, loanApplicationId: this.recordid})
        .then( (response) => {
            if(response == true) {
                this.isFileDelete = true;
            }
            else {
                this.isFileDelete = false;
            }
            console.log('resp of delete is: ',response)
        })
        .catch((err) => {

        })
        // CISP-2743 -- end
        console.log('isFileDelete is: ',this.isFileDelete)
        //CISP: CISP-2587 user cant delete the file
        if(this.isFileDelete || this.ableToDeleteDoc || event.detail.row.title == 'Insurance form borrower' || event.detail.row.title == 'Insurance form coborrower' ||event.detail.row.title == 'Application form borrower'||event.detail.row.title == 'Application form coborrower' )
        {
            console.log('The delete file ',event.detail.row.title);
            this.dispatchEvent(
                new ShowToastEvent({
                    message: 'Document can not be deleted !',
                    variant: 'warning'
                })
            );
            return;
        }
        else
        {
            isDeleteable({ documentId: event.detail.row.LinkedEntityId })
            .then((result) => {
                console.debug(result);
                if(result==true){
                    this.isLoading=true;
                    deleteContentDocument({ docId: event.detail.row.LinkedEntityId })//CISP-2525 (delete document record instead contentdoc)
                    .then(() => {
                    //  this.isLoading=false;
                        this.dispatchEvent(
                            new ShowToastEvent({
                                message: 'Document Deleted !',
                                variant: 'success'
                            })
                        );
                    })
                    .catch(error => {
                        console.log('Error delete '+error)
                        this.isLoading=false;
                        this.tryCatchError=error;
                        this.errorInCatch();
                    });
                }else{
                    const evt = new ShowToastEvent({
                        title: 'Access Denied!',
                        message: NotHaveEnoughPermission,
                        variant: 'error',
                    });
                    this.dispatchEvent(evt);
    
                }
            })
            .catch(error => {
                console.log('Error delete '+error)
                this.isLoading=false;
            });
        }
	}

    previewFile = event => {
        console.log('preview Id'+event.detail.row.ContentDocumentId);
        if(this.iscommunityuser == true){
            console.log('in community user-- : ',this.iscommunityuser);
            getContentVersion({ conDocId: event.detail.row.ContentDocumentId })
              .then(result => {
                /*console.log('Result in getContentVersion', result);
                let fileType = result[0].FileType;
                if(result!=null){
                    console.log('url : ',this.communityPartnersURL+ '/sfc/servlet.shepherd/version/renditionDownload?rendition=ORIGINAL_'+fileType+'&versionId=' + result[0].Id);
                    this[NavigationMixin.Navigate]({
                        type: 'standard__webPage',
                        attributes: {
                            url : this.communityPartnersURL+ '/sfc/servlet.shepherd/version/renditionDownload?rendition=THUMB720BY480&versionId=' + result[0].Id
                        }
                    }, false );
                    
                }*/
                this.converId = result[0].Id;
                this.isPreview = true;
                //this.uploadViewDocPopup = false;
              })
              .catch(error => {
                console.error('Error:', error);
            });

        }
        else{
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'filePreview'
            },
            state : {
                selectedRecordId: event.detail.row.ContentDocumentId 
            }
        });
        }
    }
    async createDocument(){
        let docTypeTemp = this.docType;
        console.log('OUTPUT : createDocument',);
        // Creating mapping of fields of Document with values
        let recordTypeId;
        for(let docType of this.docTypes){
            if(docType.label.includes(this.docType) || docType.value.includes(this.docType)){//INDI-4645 added Or condition
                recordTypeId = docType.recordtypeid;
                this.currentDocumentRecordTypeId = docType.recordtypeid;
            }
        }
       
        console.log('recordTypeId : createDocument',recordTypeId);
         // INDI-4645 Changes
         if(this.docType == 'Cheques SPDC'){
            let chequesCount = 0;
            console.log('OUTPUT  Cheques SPDC: ',);
            await countOfChequesDoc({ loanApplicationId: this.recordid })
              .then(result => {
                console.log('Result countOfChequesDoc', result);
                chequesCount = parseInt(result) + 1;
              })
              .catch(error => {
                console.error('Error:', error);
            });
            await createDocumentForCheque({ docType:this.docType,vehicleDetailId:this.vehicleDetailId,applicantId:this.currentapplicantid,loanApplicationId: this.recordid,
                chequeSeq:chequesCount  })
              .then(result => {
                console.log('Result', result);
                this.documentRecordId = result;
                    if(this.documentRecordId){
                        console.log('documentRecordId ****', this.documentRecordId);
                        this.showFileUpload = true;
                        this.showFrontBackUpload = false;
                        this.disabledFileUpload = false;
                    }
              })
              .catch(error => {
                console.error('Error:', error);
            });
         // INDI-4645 Changes    
        }else{
            if(this.allowUploadBE == false) {
        const fields = {};
        //CISP-22284 Start
        if(this.isTwoWheeler){
            if(this.docType == 'RTO' || this.docType == 'DPN' || this.docType == 'Agreement Wrapper Booklet'){
                fields[DOCUMENT_VEHICLE_DETAIL_FIELD.fieldApiName] = this.vehicleDetailId;
            }
        }
        //CISP-22284 End
        fields[DOCUMENT_RECORDTYPEID_FIELD.fieldApiName] = recordTypeId; 
        fields[DOCUMENT_TYPE_FIELD.fieldApiName] = this.docType;
        fields[DOCUMENT_OPP_FIELD.fieldApiName] = this.recordid;
        fields[DOCUMENT_APP_FIELD.fieldApiName] = this.currentapplicantid;
        fields[DOCUMENT_NAME_FIELD.fieldApiName] = this.docType;
        if(this.isTractor == true){
            fields[DOCUMENT_ISACTIVE_FIELD.fieldApiName] = false;
        }else{
        fields[DOCUMENT_ISACTIVE_FIELD.fieldApiName] = true;
        }
        //INDI-4645 Changes          
        if(this.docType == 'Borrower\'s Passbook' || this.docType == 'NOC' || this.docType == 'RC Document' || (this.isTwoWheeler == true && (this.docType == 'Borrower\'s Bank Statement' || this.docType == 'Co-Borrower\'s Passbook' || this.docType == 'Co-Borrower\'s Bank Statement'))){ //CISP-22434
            fields[DOCUMENT_ISADDITIONALDOC.fieldApiName] = true;
        }
        // Record details to pass to create method with api name of Object.
        var objRecordInput = {'apiName' : DOCUMENT_OBJECT_INFO.objectApiName, fields};
        console.log('objRecordInput : ',objRecordInput);
        // LDS method to create record.
        createRecord(objRecordInput).then(response => {
            this.documentRecordId = response.id;
            this.disabledFileUpload = false;
            // if(this.isTwoWheeler === false){this.disabledIsPhotocopy = false;}
            for(let docType of this.docTypes){
                if(docType.value.includes(this.docType)){
                    if(docType.recordtype.includes('KYC')){
                        this.restrictFileFormat = true
                        // this.disabledIsPhotocopy = true;//CISP-2969
                    }
                    else{
                        this.restrictFileFormat = false;//CISP-2969
                    }
                }
            }
            console.log('after createRecord',this.documentRecordId);
            if(this.isTractor  && this.isNonDividual ){
                if ( this.documentNumber !== undefined && this.documentNumber !== null && this.documentNumber !== ''){
                    if(this.documentRecordId && (this.docType == AadhaarCard  || this.docType == DrivingLicences 
                        || this.docType == VoterIdCard  || this.docType == PassportCard)){
                    this.showFrontBackUpload = true;
                    this.showFileUpload = false;
                } else if(this.documentRecordId && this.documentNumber){
                    this.showFileUpload = true;
                    this.showFrontBackUpload = false;
                }
                }else {
                    const evt = new ShowToastEvent({
                        message: 'Please Enter the Document Number',
                        variant: 'warning',
                    });
                    this.dispatchEvent(evt);
                }
            }
            else if (this.isTractor && !this.isNonDividual){
                if(this.documentRecordId && (this.docType == AadhaarCard  || this.docType == DrivingLicences 
                    || this.docType == VoterIdCard  || this.docType == PassportCard)){
                    this.showFrontBackUpload = true;
                    this.showFileUpload = false;
                } else if(this.documentRecordId){
                    this.showFileUpload = true;
                    this.showFrontBackUpload = false;
                }
            }
            else{
                if(this.documentRecordId && (this.docType == AadhaarCard  || this.docType == DrivingLicences 
                    || this.docType == VoterIdCard  || this.docType == PassportCard)){
                    this.showFrontBackUpload = true;
                    this.showFileUpload = false;
            } else if(this.documentRecordId){
                this.showFileUpload = true;
                this.showFrontBackUpload = false;
            }
        }
        }).catch(error => {
            console.error('Error: ' +JSON.stringify(error));
        });
        }
        else {
        if(this.docType == 'Borrower\'s Passbook' || this.docType == 'NOC' || this.docType == 'RC Document'){
            var isAdditionalDoc = true;
        } else {
            var isAdditionalDoc = false;
        }
        var docWrapper = {
            RecordTypeId : recordTypeId,
            DocType : this.docType,
            OppId : this.recordid,
            AppId : this.currentapplicantid,
            IsAddDoc : isAdditionalDoc
        }
        uploadTractorDocument({docWrapper:docWrapper}).then(result=>{
            this.documentRecordId = result;
            this.disabledFileUpload = false;
            // if(this.isTwoWheeler === false){this.disabledIsPhotocopy = false;}
            for(let docType of this.docTypes){
                if(docType.value.includes(this.docType)){
                    if(docType.recordtype.includes('KYC')){
                        this.restrictFileFormat = true
                        // this.disabledIsPhotocopy = true;//CISP-2969
                    }
                    else{
                        this.restrictFileFormat = false;//CISP-2969
                    }
                }
            }
            if(this.isTractor && this.isNonDividual ){
                if ( this.documentNumber !== undefined && this.documentNumber !== null && this.documentNumber !== ''){
                    if(this.documentRecordId && (this.docType == AadhaarCard  || this.docType == DrivingLicences 
                        || this.docType == VoterIdCard  || this.docType == PassportCard)){
                    this.showFrontBackUpload = true;
                    this.showFileUpload = false;
                } else if(this.documentRecordId && this.documentNumber){
                    this.showFileUpload = true;
                    this.showFrontBackUpload = false;
                }
                }else {
                    const evt = new ShowToastEvent({
                        message: 'Please Enter the Document Number',
                        variant: 'warning',
                    });
                    this.dispatchEvent(evt);
                }
            }
            else if (this.isTractor && !this.isNonDividual){
                if(this.documentRecordId && (this.docType == AadhaarCard  || this.docType == DrivingLicences 
                    || this.docType == VoterIdCard  || this.docType == PassportCard)){
                    this.showFrontBackUpload = true;
                    this.showFileUpload = false;
                } else if(this.documentRecordId){
                    this.showFileUpload = true;
                    this.showFrontBackUpload = false;
                }
            }
            else{
                if(this.documentRecordId && (this.docType == AadhaarCard  || this.docType == DrivingLicences 
                    || this.docType == VoterIdCard  || this.docType == PassportCard)){
                    this.showFrontBackUpload = true;
                    this.showFileUpload = false;
            } else if(this.documentRecordId){
                this.showFileUpload = true;
                this.showFrontBackUpload = false;
            }
        }
        }).catch(error => {
            console.error('Error: ' +JSON.stringify(error));
        });

    }
    }
}

    // INDI-4645 changes
    getAllDocumentType(){
        this.docTypes = [];
        getDocumentTypes({loanApplicationId : this.recordid,
                            loanApplicantId : this.currentapplicantid,
                            action: 'Upload'})
        .then(result => {
            if(result){
                console.log('OUTPUT getDocumentTypes in create record : ',JSON.parse(result));
                this.docTypes = JSON.parse(result);
            }
        }).catch(error => {
            console.debug(error);
        });
    }
    // INDI-4645 changes
}