import { LightningElement, wire, api, track} from "lwc";
import userId from '@salesforce/user/Id';
import getCurrentUserRole from "@salesforce/apex/GetFilesController.getUserRole";
import getRelatedFiles from "@salesforce/apex/GetFilesController.getFilesList";
import isKYCDocument from "@salesforce/apex/GetFilesController.isKYCDocument";
import deleteFile from "@salesforce/apex/GetFilesController.deleteFile";
import isResiDocument from "@salesforce/apex/GetFilesController.isResiDocument";

import { deleteRecord} from "lightning/uiRecordApi";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { refreshApex } from "@salesforce/apex";

import AadhaarCard from '@salesforce/label/c.AadhaarCard';
import DrivingLicences from '@salesforce/label/c.DrivingLicences';
import PassportCard from '@salesforce/label/c.PassportCard';
import VoterIdCard from '@salesforce/label/c.VoterIdCard';

const actions = [
  { label: "Re-Upload File", name: "upload"}
];

const BASE64EXP = new RegExp(/^data(.*)base64,/);
const columns = [
  {
    label: "Id",
    fieldName: "id",
    type: "filePreview",
    typeAttributes: {
      anchorText: { fieldName: "title" },
      versionId: { fieldName: "latestVersionId" }
    }
  },
  { label: "Uploaded Date", fieldName: "createdDate", type: "date" },
  { label: "Uploaded by", fieldName: "createdBy", type: "string" },
  { type: "action", typeAttributes: { rowActions: actions } }
];


const columns1 = [
  {
    label: "Id",
    fieldName: "id",
    type: "filePreview",
    typeAttributes: {
      anchorText: { fieldName: "title" },
      versionId: { fieldName: "latestVersionId" }
    }
  },
  { label: "Uploaded Date", fieldName: "createdDate", type: "date" },
  { label: "Uploaded by", fieldName: "createdBy", type: "string" }
];

export default class FilesRelatedList extends LightningElement {
  @track currentUserRole;


  @api
  recordId;

  _filesList;
  fileTitle;
  fileName;
  @track files = [];
  showModal = false;
  @track columns;
  versionDetails = [];
  fileUpload = false;
  _currentDocId = null;
  showPreview = false;
  currentPreviewFileId = null;
  showSpinner = false;
  type;
  @track totalNumberOfFiles = 0;
  kycDOCFlag;
  restrictFileFormat = false;
  currentDocumentRecordTypeId;
  modalPopUpUpload;
  handleBackUpload = false;
  backUploadApp = false;
  @track documentSide = 'Front';
  showSpinnerinModel = false;
  templateFrontBackUpload = true;
  captureApp=false;
  reUploadFileData;


  label={
    AadhaarCard,
    PassportCard,
    VoterIdCard,
    DrivingLicences
}

get acceptedFormats() {
      return ['.jpg', '.png','.jpeg'];
}


  @wire(getCurrentUserRole, { recordId: userId}) 
  getUserRole({error, data}) {
    console.log('data-->'+data);
      if (data) {
          this.currentUserRole = data;
          this.columns = this.currentUserRole !== 'BE' ?  columns1:columns;
          console.log('this.columns'+this.columns);
      } else if (error) {
        console.log('this.error'+JSON.stringify(error));
          this.error = error ;
      }
  }

  @wire(getRelatedFiles, { recordId: "$recordId" })
  getFilesList(filesList) {
    this._filesList = filesList;
    const { error, data } = filesList;
    if (!error && data) {
      this.files = data;
      this.totalNumberOfFiles = '(' +this.files.length + ')';
      console.log("files found " + JSON.stringify(this.files));
    }
    else{
        console.log("files not found " + JSON.stringify(error));
    }
  } 

  @track showUploadBtn = false;
  connectedCallback(){
    isResiDocument({'documentId' : this.recordId}).then((result)=>{
       if(result){
          this.showUploadBtn = true;
       }
    }).catch(error=>{});
  }

  handleClick(){
    this.modalPopUpUpload = true;
  }

  async handleRowAction(event) {
    const action = event.detail.action.name;
    const row = event.detail.row;
    this.reUploadFileData = event.detail.row;
    this._currentDocId = row.id;
    if(action === 'upload'){
      let result = await isKYCDocument({'documentId' : this.recordId});
      if(result){
        this.showToastMessage('Info', 'Re-Uploading is not allowed for KYC documents!', 'info');
      }else{
        this.modalPopUpUpload = true;
      }
    } 
  } 

  handleDocumentPopupClose(){
    this.modalPopUpUpload = false;
  }

  showToastMessage(title, message, variant) {
    if (title) {
        this.dispatchEvent(new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        }));
    } else {
        this.dispatchEvent(new ShowToastEvent({
            message: message,
            variant: variant,
        }));
    }
}

  handleFrontUploadFinished(event){
    if(this.reUploadFileData?.id){
      this._deleteRecord(this.reUploadFileData.id);
    }else{
      this.showToastMessage('', 'File Uploaded Successfully', 'success');
      refreshApex(this._filesList);
    }
    this.modalPopUpUpload = false;
}

  _deleteRecord(recordId) {
      console.log('recordIds->'+recordId);
      deleteFile({'contentDocumentId': recordId,'linkedEntityId' : this.recordId})
      .then(() => {
        this.reUploadFileData = undefined;
        refreshApex(this._filesList);
        this.showToastMessage('Re-Uploaded', 'File Re-Uploaded Successfully', 'success');
      })
      .catch((err) => {
        this.showToastMessage('Re-Uploaded', 'Error Occurred While Re-Uploading File', 'error');
      });
  }

}