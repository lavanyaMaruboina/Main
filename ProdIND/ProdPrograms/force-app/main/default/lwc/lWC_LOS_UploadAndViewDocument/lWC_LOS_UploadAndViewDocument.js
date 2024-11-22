// Screen created By : Vinita K
// Screen Name: 'LWC_LOS_UploadAndViewDocuments'
// Description : Generic Component for Upload and View Documents.
// created on: 3 Dec 2021

import { LightningElement, api, track, wire } from 'lwc';
import deactivateOldDocs from '@salesforce/apex/RepaymentScreenController.deactivateOldDocs';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getRecord, updateRecord } from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';
import FORM_FACTOR from '@salesforce/client/formFactor';
import userId from '@salesforce/user/Id';

import loadInputsForDocumentsUpload from '@salesforce/apex/IND_DocumentUploadCntrl.loadInputsForDocumentsUpload';
import deleteDocument from '@salesforce/apex/IND_DocumentUploadCntrl.deleteDocument';
import getProfile from '@salesforce/apex/IND_DocumentUploadCntrl.getProfile';
import deleteDocumentsFromContentDocument from '@salesforce/apex/IND_DocumentUploadCntrl.deleteDocumentsFromContentDocument';
import createDocument from '@salesforce/apex/IND_DocumentUploadCntrl.createDocumentForCheque';
import imageuploaded from '@salesforce/label/c.imageuploaded';
import DocumentDeleted from '@salesforce/label/c.DocumentDeleted';
import DocumentTypeNotSelected from '@salesforce/label/c.DocumentTypeNotSelected';
import FileUpload from '@salesforce/label/c.FileUpload';

import DOC_ID_FIELD from '@salesforce/schema/Documents__c.Id';
import DOCUMENT_TYPE_FIELD from '@salesforce/schema/Documents__c.Document_Type__c';
import DOCUMENT_NAME_FIELD from '@salesforce/schema/Documents__c.Name';
import IS_PHOTOCOPY_FIELD from '@salesforce/schema/Documents__c.Is_this_a_Photocopy__c';
import DOCUMENT_OBJECT_OBJECT from '@salesforce/schema/Documents__c';
import UserNameFld from '@salesforce/schema/User.Name';
import userEmailFld from '@salesforce/schema/User.Email';
import officeFrontView from '@salesforce/label/c.Office_Front_View';
import residentFrontView from '@salesforce/label/c.Residence_Front_View';

export default class LWC_LOS_UploadAndViewDocument extends NavigationMixin(LightningElement) {
    @api recordtypename; //CISP-2975
    @api documentRecordId;
    @api contentDocumentId = null;
    @api currentdocid;
    @api currentapplicantid;
    @api parentId;
    @api currentloanapplicationid;
    @api currentvehiclerecordid;
    @api uploadviewdocpopup;
    @api type;
    @api showupload;
    @api showdocview;
    @api isphotocopy = false;
    @api originalcopy;
    @api doctype;
    @api vehicledocs;
    @api alldocs;
    @api label;
    @api createdoconparentbutton;
    @api documentrecordidfromparent;

    @api functionality; //To be used to write custom code in fetchDataMap;passed from parent
    @track isView = true; // added by aditya
    @track tempValue = true;
    @track tryCatchError = '';
    @track disabledFileUpload = true;
    @track docUploadSuccessfully = false;
    @track docUploaded = false;
    @track disableCancel = false;
    @track queryFilters = "";
    
    webApp = true;
    isPhotocopy = false;
    mobileTabApp = false;
    isLoading = false;
    captureBackSide=false;
    BackmobileTabApp=false;
    disabledBackFileUpload=false;
    captureTabLabel='Capture';
    fileUploadLabel='Upload File';
    currentUserId = userId;
    backContentDocumentId=null;
    otherDocumentRecordTypeId;
    currentUserName;
    currentUserEmailId;

    label = {
        imageuploaded,
        DocumentDeleted,
        DocumentTypeNotSelected,
        FileUpload
    }

    //kycDocuments = ['Aadhaar', 'Driving Licence', 'PAN', 'Passport', 'Voter Id'];
    kycDocuments = ['36','5','7','4','PAN']; //API name of Document Type picklist 
    @track documentsConfig = {
        objectName: "ContentDocument",
        tableConfig: {
            columns: [
                { api: 'Title', label: 'Title', fieldName: 'Title', sortable: true },
                { api: 'ContentSize', label: 'Size (bytes)', fieldName: 'ContentSize', type: 'number', sortable: true, callAttributes: { alignment: 'left' } },
                { api: 'FileType', label: 'File Type', fieldName: 'FileType', sortable: true },
                { api: 'Owner.Name', label: 'Owner', fieldName: 'OwnerName', sortable: true },
                { label: 'preview', type: 'button-icon', typeAttributes: { name: 'Preview', iconName: 'utility:preview', variant: 'brand-outline' } },
                { label: '#', type: 'button-icon', typeAttributes: { name: 'delete', iconName: 'utility:delete', variant: 'bare' } }
            ],
            hideCheckboxColumn: true
        },
        sortBy: 'CreatedDate',
        queryFilters: this.currentloanapplicationid,
        pageSize: '5',
        limit: '100'
    };

    @wire(getRecord, { recordId: userId, fields: [UserNameFld, userEmailFld] }) userDetails({ error, data }) {
        if (data) {
            this.currentUserName = data.fields.Name.value;
            this.currentUserEmailId = data.fields.Email.value;
        } else if (error) {
            this.error = error;
        }
    }

    @wire(getObjectInfo, { objectApiName: DOCUMENT_OBJECT_OBJECT }) opportunityMetaData;

    @wire(getPicklistValues, { recordTypeId: '$opportunityMetaData.data.defaultRecordTypeId', fieldApiName: DOCUMENT_TYPE_FIELD }) documentTypeValues;

    get acceptedFormats() {
        if ((FORM_FACTOR !== 'Large') && (this.doctype === 'Vehicle RC Copy' || this.doctype === 'Vehicle Image' || this.doctype === 'Vehicle Insurance Policy')) {
            return ['.pdf'];
        } else if(this.doctype === 'ITR-Forms' || this.doctype === 'Customer Bank Statement' || this.doctype ==='ITR-V' || this.doctype ==='Form26As'){
            return ['.pdf'];
        } else if((this.recordtypename != '' || this.recordtypename != null || this.recordtypename != undefined) && (this.recordtypename?.includes('KYC') || this.doctype === officeFrontView || this.doctype === residentFrontView)){//CISP-2975//CISP-3075
            return ['.jpg','.jpeg'];
        }//CISP-2975
        else {
            return ['.jpg', '.png', '.jpeg', '.docx', '.pdf'];
        }
    }
    
    async connectedCallback() {
        console.log('OUTPUT recordtypename: ',this.recordtypename); //CISP-2975
        await loadInputsForDocumentsUpload().then(result => {
            this.otherDocumentRecordTypeId = result?.otherDocumentRecordTypeId;
        }).catch(error => {
            console.log('loadInputsForDocumentsUpload - Error:: ', error);
        });

        if (this.doctype === 'Vehicle RC Copy') {
            this.isphotocopy = true;
        }

        console.log('Document ID:: ' + this.documentrecordidfromparent);

        if (this.documentrecordidfromparent) {
            this.documentRecordId = this.documentrecordidfromparent;
        }

        if (FORM_FACTOR != 'Large') {
            this.mobileTabApp = true;
            this.webApp = false; 
            if (this.kycDocuments.includes(this.doctype)){
                this.captureTabLabel='Capture Front Side';
                this.BackmobileTabApp=true;
            }
        } else {
            this.mobileTabApp = false;
            this.webApp = true;

            if (this.kycDocuments.includes(this.doctype)){
                this.fileUploadLabel='Capture Front Side';
                this.captureBackSide=true;
            }
        }
        
        if (this.alldocs === true) {
            this.disabledFileUpload = true;
        } else if (this.vehicledocs === true) {
            this.disabledFileUpload = false;
        }

        if (this.createdoconparentbutton) {
            createDocument({ 'docType' :  this.doctype, vehicleDetailId: this.currentvehiclerecordid, applicantId: this.currentapplicantid, loanApplicationId: this.currentloanapplicationid }).then(result => {
                this.documentRecordId = result;
                this.saveDocumentRecord();
            }).catch(error => {
                this.tryCatchError = error;
                this.errorInCatch();
            });
        }

        getProfile().then(result => {
            if (result == 'ApplicationformSigning Profile') {
                this.isView = false;
            }
        }).catch(error => {
            this.tryCatchError = error;
            this.errorInCatch();
        });
    }

    errorInCatch() {
        const evt = new ShowToastEvent({
            title: "Error",
            message: this.tryCatchError.body,
            variant: 'Error',
        });
        this.dispatchEvent(evt);
    }

    uploadImageClose() {
        if (!this.docUploadSuccessfully) {
            deleteDocument({ documentId: this.documentRecordId }).then(result => {
                console.log('Delete Document - Result:: ', result);
                if (this.doctype == 'ITR-Forms' || this.doctype == 'ITR-V' || this.doctype == 'Form26As' || this.doctype == 'Customer Bank Statement' || this.doctype === 'Vehicle RC Copy' || this.doctype === 'Vehicle Image' || this.doctype === 'Vehicle Insurance Policy') {
                    this.dispatchEvent(new CustomEvent('docdelete'));
                }
            }).catch(error => {
                this.tryCatchError = error;
                this.errorInCatch();
            });
        }

        this.uploadviewdocpopup = false;
        var values = { uploadedDocType: this.doctype, contentDocumentId: null };
        this.dispatchEvent(new CustomEvent('changeflagvalue', { detail: values }));
    }

    handleCancelPopupButton() {
        this.uploadviewdocpopup = false;
        this.dispatchEvent(new CustomEvent('changeflagvalue'));
    }

    handlerIsPhotocopy(event) {
        this.isPhotocopy = event.target.checked;
    }

    handleDocType(event) {
        this.docType = event.detail.value;
        
        if (this.docType !== null || this.docType !== '') {
            if (this.documentRecordId !== null) {
                deleteDocument({ documentId: this.documentRecordId });
            }

            createDocument({  'docType' :  this.docType, vehicleDetailId: this.currentvehiclerecordid, applicantId: this.currentapplicantid, loanApplicationId: this.currentloanapplicationid }).then(result => {
                this.documentRecordId = result;
                this.uploadViewDocFlag = true;
                this.saveDocumentRecord();
            }).catch(error => {
                this.tryCatchError = error;
                this.errorInCatch();
            });
            this.disabledFileUpload = false;
        } else {
            const evt = new ShowToastEvent({
                message: this.label.DocumentTypeNotSelected,
                variant: 'warning',
            });
            this.dispatchEvent(evt);
        }
    }

    async updateRecordDetails(fields) {
        const recordInput = { fields };
        await updateRecord(recordInput).then(() => {
            console.log('Record Update:: ', JSON.stringify(fields));
        }).catch(error => {
            this.tryCatchError = error;
            this.errorInCatch();
        });
    }

    handleFileUpload(event) {
        this.contentDocumentId = event.detail.files[0].documentId;

        const evt = new ShowToastEvent({
            title: 'Uploaded',
            message: 'File Uploaded successfully..!',
            variant: 'success',
        });

        this.dispatchEvent(evt);
        this.saveDocumentRecord();
        if(this.functionality != null && this.functionality != '' && this.functionality != undefined){
            let childElem=this.template.querySelector('c-l-W-C_-L-O-S_-Datatable');
            console.log('~~childElem'+childElem);
            childElem.fetchRecords();//refresh child component
            deactivateOldDocs({loanApplicationId:this.currentloanapplicationid,newDocId:this.documentRecordId,docType:this.doctype})
            .then(()=>{
                console.log('Success deactivateOldDocs');
            })
            .catch((e)=>{
                console.log('Error in deactivateOldDocs '+e);
            })
        }
    }

    handleBackFileUpload(event){
        this.backContentDocumentId = event.detail.files[0].documentId;

        const evt = new ShowToastEvent({
            title: 'Uploaded',
            message: 'File Uploaded successfully..!',
            variant: 'success',
        });
        this.dispatchEvent(evt);
    }

    saveDocumentRecord() {
        const docFields = {};
        docFields[DOC_ID_FIELD.fieldApiName] = this.documentRecordId;
        docFields[DOCUMENT_TYPE_FIELD.fieldApiName] = this.docType ? this.docType : this.doctype;
        docFields[DOCUMENT_NAME_FIELD.fieldApiName] = this.docType ? this.docType : this.doctype;
        docFields[IS_PHOTOCOPY_FIELD.fieldApiName] = this.isPhotocopy;
        
        this.updateRecordDetails(docFields).then(() => {
            this.docUploadSuccessfully = true;
            console.log('File Uploaded:: ', docFields);
            this.dispatchEvent(new CustomEvent('fileuploadstatus', { detail: this.docUploadSuccessfully }));
        });
        this.docUploaded = true;
    }

    uploadDone() {
        this.uploadviewdocpopup = false;
        var values = { uploadedDocType: this.doctype, contentDocumentId: this.contentDocumentId ,backcontentDocumentId: this.backContentDocumentId};
        this.dispatchEvent(new CustomEvent('changeflagvalue', { detail: values }));
        
        if (this.doctype === 'Vehicle RC Copy') {
            this.updatePhotocopy();
        }
    }

    handleRowAction(event) {
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

    deleteFile = event => {
        JSON.stringify(event.detail);
        this.isLoading = true;

        deleteDocumentsFromContentDocument({ docIds: event.detail.row.Id }).then(() => {
            this.isLoading = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    message: 'Document Deleted !',
                    variant: 'success'
                })
            );
        }).catch(error => {
            this.isLoading = false;
            this.tryCatchError = error;
            this.errorInCatch();
        });
    }

    previewFile = event => {
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'filePreview'
            },
            state: {
                selectedRecordId: event.detail.row.Id
            }
        });
    }

    captureCustomerImageApp(event) {
        let documentSide='Front';
        //let appDocType = ['Aadhaar', 'Driving Licence', 'PAN', 'Passport', 'Voter Id', 'Form 60', 'Bank Statement', 'Electronic Bill', 'Telephone bill', 'Post paid mobile bill', 'Gas bill', 'Water Bill', 'Property or municipal tax receipt', 'Govt pension payment order', 'Govt letter of accommodation allotment', 'Customer ITR', 'Customer Bank Statement', 'ITR-Forms', 'ITR-V', 'Form26As' ,'Vehicle Image','Vehicle Insurance Policy', 'Vehicle RC Copy'];
        let appDocType = [ '36','5','7','4','PAN','Form 60', 'Bank Statement', 'Electronic Bill', 'Telephone bill', 'Post paid mobile bill', 'Gas bill', 'Water Bill', 'Property or municipal tax receipt', 'Govt pension payment order', 'Govt letter of accommodation allotment', 'Customer ITR', 'Customer Bank Statement', 'ITR-Forms', 'ITR-V', 'Form26As' ,'Vehicle Image','Vehicle Insurance Policy', 'Vehicle RC Copy','Financial Statement']; //API name of Document Type picklist - 36,5,7,4
        let oppDocType = ['Valuation Report'];

        if (appDocType.includes(this.doctype)) {
            this.leadId = this.currentapplicantid;
        } else if (oppDocType.includes(this.doctype)) {
            this.leadId = this.currentloanapplicationid;
        }

        if (this.kycDocuments.includes(this.doctype)){
            documentSide=event.target.value;
        }

        if(this.doctype === 'ITR-Forms' || this.doctype === 'Customer Bank Statement' || this.doctype ==='ITR-V' || this.doctype ==='Form26As' || this.doctype === 'Vehicle RC Copy' || this.doctype === 'Vehicle Image' || this.doctype === 'Vehicle Insurance Policy'){
            this[NavigationMixin.Navigate]({
                type: "standard__webPage",
                attributes: {
                    url: 'ibl://indusindbank.com/integratorInfo?' + 'leadId' + '=' + this.leadId + '&' + 'userid' + '=' + this.currentUserId + '&' + 'mode' + '=' + this.doctype + '&' + '	username' + '=' + this.currentUserName + '&' + 'useremailid' + '=' + this.currentUserEmailId + '&documentSide=' + 'Front' + '&loanApplicationId=' +  this.currentloanapplicationid + '&documentRecordTypeId=' +  this.otherDocumentRecordTypeId + '&documentRecordId=' + this.documentRecordId
                }
            });
            //alert('ibl://indusindbank.com/integratorInfo?' + 'leadId' + '=' + this.leadId + '&' + 'userid' + '=' + this.currentUserId + '&' + 'mode' + '=' + this.doctype + '&' + ' username' + '=' + this.currentUserName + '&' + 'useremailid' + '=' + this.currentUserEmailId + '&documentSide=' + 'Front' + '&loanApplicationId=' +  this.currentloanapplicationid + '&documentRecordTypeId=' +  this.otherDocumentRecordTypeId);
        }else{ 
            this[NavigationMixin.Navigate]({
                type: "standard__webPage",
                attributes: {
                    url: 'ibl://indusindbank.com/integratorInfo?' + 'leadId' + '=' + this.leadId + '&' + 'userid' + '=' + this.currentUserId + '&' + 'mode' + '=' + this.doctype + '&' + '	username' + '=' + this.currentUserName + '&' + 'useremailid' + '=' + this.currentUserEmailId + '&documentSide=' + documentSide + '&documentRecordId=' + this.documentRecordId
                }
            });
            //alert('ibl://indusindbank.com/integratorInfo?' + 'leadId' + '=' + this.leadId + '&' + 'userid' + '=' + this.currentUserId + '&' + 'mode' + '=' + this.doctype + '&' + '	username' + '=' + this.currentUserName + '&' + 'useremailid' + '=' + this.currentUserEmailId + '&documentSide=' + documentSide);
        }
    }

    updatePhotocopy() {
        const docFields = {};
        docFields[DOC_ID_FIELD.fieldApiName] = this.documentRecordId;
        docFields[IS_PHOTOCOPY_FIELD.fieldApiName] = this.isPhotocopy;

        this.updateRecordDetails(docFields).then(() => {
            console.log('Update Record Details - Result:: ', docFields);
        }).catch((error) => {
            console.log('Update Record Details - Error:: ', error);
        })
    }
}