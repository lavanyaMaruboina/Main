/* Screen created By : Kruthi Nadig
Screen Name: 'LWC_LOS_GenericUploadDocument'
Description : Generic Component for Uploading Specific Documents.
created on: 19 April 2022
*/
import { LightningElement,api,track,wire } from 'lwc';
import deleteDocument from '@salesforce/apex/IND_DocumentUploadCntrl.deleteDocument';
import getProfile from '@salesforce/apex/IND_DocumentUploadCntrl.getProfile';
import deleteContentDocument from '@salesforce/apex/GenericUploadController.deleteContentDocument';
import changeFilename from '@salesforce/apex/GenericUploadController.changeFilename';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import imageuploaded from '@salesforce/label/c.imageuploaded';
import DocumentDeleted from '@salesforce/label/c.DocumentDeleted';
import DocumentTypeNotSelected from '@salesforce/label/c.DocumentTypeNotSelected';
import FileUpload from '@salesforce/label/c.FileUpload';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import {getRecord, updateRecord } from 'lightning/uiRecordApi';
import createOtherDocument from '@salesforce/apex/GenericUploadController.createOtherDocument';
import DOC_ID_FIELD from '@salesforce/schema/Documents__c.Id';
import DOCUMENT_TYPE_FIELD from '@salesforce/schema/Documents__c.Document_Type__c';
import DOCUMENT_NAME_FIELD from '@salesforce/schema/Documents__c.Name';
import IS_PHOTOCOPY_FIELD from '@salesforce/schema/Documents__c.Is_Photocopy__c';
import { NavigationMixin } from 'lightning/navigation';
import DOCUMENT_OBJECT_OBJECT from '@salesforce/schema/Documents__c';
import FORM_FACTOR from '@salesforce/client/formFactor';
import userId from '@salesforce/user/Id';
import UserNameFld from '@salesforce/schema/User.Name';
import userEmailFld from '@salesforce/schema/User.Email';
import getContentVersion from '@salesforce/apex/GenericUploadController.getContentVersion';
import getProfileName from '@salesforce/apex/GenericUploadController.getProfileName';
import IBL_Community_Partners_URL from '@salesforce/label/c.IBL_Community_Partners_URL';
export default class iND_LWC_RTO_DPN_POA_ViewDocument extends NavigationMixin(LightningElement)  {
    communityPartnersURL = IBL_Community_Partners_URL;
    currentUserId = userId;
    currentUserName;
    currentUserEmailId;
    label = {
        imageuploaded,
        DocumentDeleted,
        DocumentTypeNotSelected,
        FileUpload
        
    }

    fileUploadResp = {};
    webApp=true;
    mobileTabApp=false;
    @track isView=true ;
    @track tryCatchError='';
    @api filename;
    @api uploadviewdocpopup;
    @api type;
    @api showupload;
    @api showdocview;
    @api isphotocopy=false;
    @api originalcopy;
    @api doctype;
    @api vehicledocs;
    @api alldocs;
    @api currentdocid; //get currentDoc ID from Insurance and valuation Component
    @api currentapplicantid;
    @api currentloanapplicationid;
    @api currentvehiclerecordid;
    @api label;
    @api createdoconparentbutton;
    @api contentDocumentId;
    @api title = "Upload Documents";
    @api documentrecordidfromparent;
    @api docotherrecordtype = false;
    @track documentRecordId;
    @track disabledFileUpload=true;
    @track docUploadSuccessfully=false;
    @track docUploaded=false;
    @track disableCancel=false;
    @track queryFilters = "";
    isLoading=false;
    @api additionaldocument;
    iscommunityuser;
    isPreview = false;
    converId;
    height = 32;
    @track documentsConfig = {
        objectName: "ContentDocumentLink",
        tableConfig: {
            columns: [
                { api: 'ContentDocument.Title', label: 'Title', fieldName: 'title', sortable: true },
                { api: 'ContentDocument.ContentSize', label: 'Size (bytes)', fieldName: 'ContentSize', type: 'number', sortable: true, callAttributes: { alignment: 'left' } },
                { api: 'ContentDocument.FileType', label: 'File Type', fieldName: 'FileType', sortable: true },
                { api: 'ContentDocument.Owner.Name', label: 'Owner', fieldName: 'OwnerName', sortable: true },
                { label: 'preview', type: 'button-icon', typeAttributes: { name: 'Preview', iconName: 'utility:preview', variant: 'brand-outline'} }                
            ],
            hideCheckboxColumn: true
        },
        queryFilters: 'LinkedEntityId ='+this.documentRecordId ,
        pageSize: '5',
        limit: '100'
    };


    @wire(getRecord, { recordId: userId, fields: [UserNameFld, userEmailFld] })
    userDetails({ error, data }) {
        if (data) {
            this.currentUserName = data.fields.Name.value;
            this.currentUserEmailId = data.fields.Email.value;
        } else if (error) {
            this.error = error;
        }
    }

    @wire(getObjectInfo, { objectApiName: DOCUMENT_OBJECT_OBJECT })
    opportunityMetaData;

    @wire(getPicklistValues,
        { 
            recordTypeId: '$opportunityMetaData.data.defaultRecordTypeId', 
            fieldApiName: DOCUMENT_TYPE_FIELD
        } 
    )
    documentTypeValues;

    get acceptedFormats() {
        return ['.jpg', '.png','.jpeg','.docx','.pdf'];
    }
    
    connectedCallback(){
        getProfileName({ loanApplicationId: this.currentloanapplicationid })
        .then(result => {
          console.log('Result in RTO view ', result);
          if(result){
              this.iscommunityuser = result;
          }
          
        })
        .catch(error => {
          console.error('Error:', error);
        });
        console.log('LOAId'+this.currentloanapplicationid);
        if(FORM_FACTOR!='Large'){
            this.mobileTabApp=true;
            this.webApp=false;
        }
        else{
            console.log('docType ',this.doctype);
            this.mobileTabApp=false;
            this.webApp=true;
        }
       if(this.filename == undefined) {
           this.filename = this.doctype;
       }
        console.log('this.documentrecordidfromparent  from Parent : '+this.documentrecordidfromparent);
        if(this.documentrecordidfromparent){
            console.log('in  documentrecordidfromparent: ',);
            this.documentRecordId=this.documentrecordidfromparent;
            this.documentsConfig.queryFilters = 'LinkedEntityId =\''+this.documentRecordId+'\'';

            console.log('this.documentsConfig.queryFilters ',this.documentsConfig.queryFilters);
        }   
    }

    uploadDone(){
        //this.uploadviewdocpopup = false;
        console.log('Check COntent File Id :'+this.contentDocumentId);
        this.fileUploadResp.contentDocumentId = this.contentDocumentId;
        this.fileUploadResp.DocumentId = this.documentRecordId;
        this.dispatchEvent(new CustomEvent('changeflagvalue', { detail: this.fileUploadResp }));
        this.uploadviewdocpopup = false;
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
  
    deleteFile = event => {
        JSON.stringify(event.detail);
		this.isLoading=true;
		deleteContentDocument({ docIds: event.detail.row.Id })
        .then(() => {
            this.isLoading=false;
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
	}

    hideModalBox() {
        this.isPreview = false;
    }

    previewFile = event => {
        console.log('preview Id',event.detail.row.ContentDocumentId);
        if(this.iscommunityuser == true){
            console.log('in community user-- : ',this.iscommunityuser);
            getContentVersion({ conDocId: event.detail.row.ContentDocumentId })
              .then(result => {
                /*console.log('Result in getContentVersion', result);
                let fileType = result[0].FileType;
                if(result!=null){
                    this[NavigationMixin.Navigate]({
                        type: 'standard__webPage',
                        attributes: {
                            url : this.communityPartnersURL+ '/sfc/servlet.shepherd/version/renditionDownload?rendition=THUMB720BY480&versionId='+ result[0].Id
                        }
                    }, false );
                    
                }*/
                this.converId = result[0].Id;
                this.isPreview = true;
              })
              .catch(error => {
                console.error('Error:', error);
            });

        }else{
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
}