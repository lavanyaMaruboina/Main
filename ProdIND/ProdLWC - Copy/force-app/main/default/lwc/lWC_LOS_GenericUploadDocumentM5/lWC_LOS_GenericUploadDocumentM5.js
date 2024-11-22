/* Screen created By : Kruthi Nadig
Screen Name: 'LWC_LOS_GenericUploadDocument'
Description : Generic Component for Uploading Specific Documents.
created on: 19 April 2022
*/
import { LightningElement,api,track,wire } from 'lwc';
import deleteDocument from '@salesforce/apex/IND_DocumentUploadCntrl.deleteDocument';
//import getProfile from '@salesforce/apex/IND_DocumentUploadCntrl.getProfile';
import deleteContentDocument from '@salesforce/apex/GenericUploadController.deleteContentDocument';
import GetLoanapplicationHistory from  "@salesforce/apex/LoanAgreementController.GetLoanapplicationHistory"; //CISP:3405
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
import LandHolderDocumentType from '@salesforce/label/c.Land_Holder_Document_Type';
import residentFrontView from '@salesforce/label/c.Residence_Front_View';
import otherFilesDeleted from '@salesforce/apex/GenericUploadController.otherFilesDeleted';
export default class LWC_LOS_UploadAndViewDocument extends NavigationMixin(LightningElement)  {
    communityPartnersURL = IBL_Community_Partners_URL;
    currentUserId = userId;
    leadId;
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
    @api ischequeclose = false;
    @api isviewinvoice;
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
    @track isLoanagrrementsubmiteed;
    @api additionaldocument;
    @api iscommunityuser;
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
                { label: 'preview', type: 'button-icon', typeAttributes: { name: 'Preview', iconName: 'utility:preview', variant: 'brand-outline'} },
                { label: '#', type: 'button-icon', typeAttributes: { name: 'delete', iconName: 'utility:delete', variant: 'bare' } }
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
        console.log('currentapplicantid-->',this.currentapplicantid);
        console.log('currentloanapplicationid--->',this.currentloanapplicationid);

        getProfileName({ loanApplicationId: this.currentloanapplicationid })
          .then(result => {
            console.log('Result in document upload ', result);
            if(result){
                this.iscommunityuser = result;
            }
            
          })
          .catch(error => {
            console.error('Error:', error);
        });
        console.log('AAA',this.uploadviewdocpopup);
        if(this.isviewinvoice != undefined){
            this.isView = this.isviewinvoice;
        }
       
        console.log('isView : ',this.isView);
        console.log('chequeClose : ',this.ischequeclose);
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
            console.log('in  documentrecordidfromparent: ',this.documentRecordId);

        }
       if(this.alldocs===true){
            this.disabledFileUpload=true;
       }else if(this.vehicledocs===true){
        console.log('docTypegeg ',this.docType);
            this.disabledFileUpload=false;
       }
       if(this.createdoconparentbutton == "true"){
            console.log('createdoconparentbutton'+this.createdoconparentbutton);
            createOtherDocument({docType:this.doctype,vehicleDetailId: this.currentvehiclerecordid,applicantId:this.currentapplicantid,loanApplicationId: this.currentloanapplicationid})
            .then(result => {
                console.debug(result);
                this.documentRecordId = result;
                console.log('docId'+this.documentRecordId);
                this.documentsConfig.queryFilters = 'LinkedEntityId =\''+this.documentRecordId+'\'';
                this.showdocview = true;
                this.saveDocumentRecord();
            }).catch(error => {
                console.debug(error);
                this.tryCatchError=error;
                this.errorInCatch();
            });
       }

       /*getProfile()
       .then(result => {
       if(result =='ApplicationformSigning Profile'){
        this.isView = false;
       }
       })
       .catch(error => {
         this.tryCatchError=error;
       this.errorInCatch(); 
       });*/
     



    }


    async renderedCallback() {  //CISP 3405 
        console.log('I am render call back of the genreric uplod comp')
       await GetLoanapplicationHistory({ loanApplicationId: this.currentloanapplicationid })
        .then(result => {
          console.log('The resent from the ', result);
          if(result){
              this.isLoanagrrementsubmiteed= result;
          }   
        })
        .catch(error => {
          console.error('Error:', error);
      });
    }


   
 
    errorInCatch(){
        const evt = new ShowToastEvent({
            title: "Error",
            message: this.tryCatchError.body,
            variant: 'Error',
        });
        this.dispatchEvent(evt);
    }

    uploadImageClose(){
        if(!this.docUploadSuccessfully && this.isView == true && this.ischequeclose == false){
          deleteDocument({documentId: this.documentRecordId}) //apex method call
            .then(result => {
                console.log('deleted:',this.documentRecordId);
            })
            .catch(error => {
                this.tryCatchError=error;
                this.errorInCatch(); 
            });
        }
        this.uploadviewdocpopup=false;
        this.dispatchEvent(new CustomEvent('changeflagvalue', { detail: this.contentDocumentId }));
     }
 
    handlerIsPhotocopy(event){  
        this.isPhotocopy=event.target.checked;
    }

    handleDocType(event){
        this.docType = event.detail.value;
        if(this.docType!==null || this.docType!==''){
            if(this.documentRecordId !== null ){
               deleteDocument({documentId: this.documentRecordId});
            }
            createOtherDocument({docType:this.doctype,vehicleDetailId: this.currentvehiclerecordid,applicantId:this.currentapplicantid,loanApplicationId: this.currentloanapplicationid})
            .then(result =>{
                this.documentRecordId=result;
                this.uploadViewDocFlag = true;
                this.saveDocumentRecord();
            })
            .catch(error => {
                this.tryCatchError=error;
                this.errorInCatch();
            });
            this.disabledFileUpload=false;
        }
        else{
            const evt = new ShowToastEvent({
                 message: this.label.DocumentTypeNotSelected,
                 variant: 'warning',
             });
             this.dispatchEvent(evt);
        }
    }

    async updateRecordDetails(fields){
        const recordInput = { fields };
        await updateRecord(recordInput)
        .then(()=> {
            console.log('record update success',JSON.stringify(fields));
        })
        .catch(error => {
            this.tryCatchError=error;
            this.errorInCatch();
        });
    }

    handleFileUpload(event) {
        console.log('handleFileUpload');
        this.contentDocumentId = event.detail.files[0].documentId;
        changeFilename({contentDocId : this.contentDocumentId, fname : this.filename}).then(
            result => {
                console.log('FileName changed.');
                otherFilesDeleted({contentDocId : this.contentDocumentId, documentId : this.documentRecordId}).then(data =>{
                    console.log('otherFilesDeleted .');
                }).catch(error =>{
                        console.log('otherFilesDeleted error.',error);
                }); 
            }
        ).catch(error => {
            console.log('FileName not change error'+JSON.stringify(error));
        });
        console.log('Check Document Id : '+this.contentDocumentId );
        const evt = new ShowToastEvent({
            title: 'Uploaded',
            message: 'File Uploaded successfully..!',
            variant: 'success',
        });
        this.dispatchEvent(evt);
        // Added By Poonam 
        if(this.doctype == 'Cheques SPDC' || this.additionaldocument == "true"){
            this.dispatchEvent(new CustomEvent('fileuploadstatus',{detail: this.contentDocumentId}));
        }else{
            this.saveDocumentRecord();
        }
   }

    saveDocumentRecord(){
        const docFields = {};
        console.log('Check Document Values : '+this.documentRecordId,'',this.docType,'',this.isPhotocopy );
        docFields[DOC_ID_FIELD.fieldApiName] = this.documentRecordId;
        docFields[DOCUMENT_TYPE_FIELD.fieldApiName] = this.docType;
        docFields[DOCUMENT_NAME_FIELD.fieldApiName] = this.docType;
        docFields[IS_PHOTOCOPY_FIELD.fieldApiName] = this.isPhotocopy;
        this.updateRecordDetails(docFields)
        .then(()=> {
             this.docUploadSuccessfully=true;
             console.log('File Uploaded');
             this.dispatchEvent(new CustomEvent('fileuploadstatus',{detail: this.docUploadSuccessfully}));
            });
            this.docUploaded=true;
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
        console.log('The value of the  isLoanagrrementsubmiteed', this.isLoanagrrementsubmiteed)
        if( this.isLoanagrrementsubmiteed==true)// CISP:3504
        {
            this.dispatchEvent(
                new ShowToastEvent({
                    message: ' You can not delete the doucment !',
                    variant: 'warning '
                })
            ); 
        }
        else
        {
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
		
}

    hideModalBox() {
        this.isPreview = false;
    }

    hideModalBox() {
        this.isPreview = false;
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

    captureCustomerImageApp() {
        var appDocType = ['Aadhaar', 'Driving Licence', 'PAN', 'Passport', 'Voter Id', 'Form 60', 'Bank Statement','Electronic Bill','Telephone bill','Post paid mobile bill','Gas bill','Water Bill','Property or municipal tax receipt','Govt pension payment order','Govt letter of accommodation allotment', 'Customer ITR', 'Customer Bank Statement',LandHolderDocumentType,'Office Front View','Photo With Co Borrower','Photo With Borrower','ITR-Forms','Financial Statement',residentFrontView];
        var oppDocType = ['Customer Insurance Policy', 'Vehicle RC Copy', 'Vehicle Image'];
        if (appDocType.includes(this.doctype)) {
            this.leadId = this.currentapplicantid;
        } else {
            this.leadId = this.currentloanapplicationid;
        }
        this[NavigationMixin.Navigate]({
            type: "standard__webPage",
            attributes: {
                url: 'ibl://indusindbank.com/integratorInfo?' + 'leadId' + '=' + this.leadId + '&' + 'userid' + '=' + this.currentUserId + '&' + 'mode' + '=' + this.doctype + '&' + '	username' + '=' + this.currentUserName + '&' + 'useremailid' + '=' + this.currentUserEmailId + '&documentSide=' + 'Front'
            }
        });
    }
}