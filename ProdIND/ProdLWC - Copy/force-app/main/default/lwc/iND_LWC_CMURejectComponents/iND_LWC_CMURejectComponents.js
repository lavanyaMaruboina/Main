import { LightningElement,api,wire,track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { getRecord } from 'lightning/uiRecordApi';
import getDocumentDetails from '@salesforce/apex/IND_LWC_CMURejectController.getDocumentsList';
import getDocDetails from '@salesforce/apex/IND_LWC_CMURejectController.getDocumentDetails';
import deleteRelatedDocuments from '@salesforce/apex/IND_LWC_CMURejectController.deleteRelatedDocuments';
import deleteRelatedDocumentsOnUpload from '@salesforce/apex/IND_LWC_CMURejectController.deleteRelatedDocumentsOnUpload';//CISP-3484
import checkPortalEnable from '@salesforce/apex/IND_LWC_CMURejectController.checkPortalEnable';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import FORM_FACTOR from '@salesforce/client/formFactor';

import IBL_Community_Partners_URL from '@salesforce/label/c.IBL_Community_Partners_URL';
import currentUserId from '@salesforce/label/c.currentUserId';
import currentUserName from '@salesforce/label/c.currentUserName';
import currentUserEmailid from '@salesforce/label/c.currentUserEmailid';
import mode from '@salesforce/label/c.mode';
import currentApplicantid from '@salesforce/label/c.currentApplicantid';
import AadhaarCard from '@salesforce/label/c.AadhaarCard';
import DrivingLicences from '@salesforce/label/c.DrivingLicences';
import PassportCard from '@salesforce/label/c.PassportCard';
import VoterIdCard from '@salesforce/label/c.VoterIdCard';
import RegEx_Alphabets_Only from '@salesforce/label/c.RegEx_Alphabets_Only';//CISP-19498
import lastNameError from '@salesforce/label/c.Last_Name_Error';//CISP-19498

import userId from '@salesforce/user/Id';
import UserNameFld from '@salesforce/schema/User.Name';
import userEmailFld from '@salesforce/schema/User.Email';

import doOCRfuCallout from '@salesforce/apexContinuation/IntegrationEngine.doCibilOcrFrontUploadCallout';
import doOCRbuCallout from '@salesforce/apexContinuation/IntegrationEngine.doCibilOcrBackUploadCallout';
import storedMaskedKYCDoc from '@salesforce/apex/LwcLOSLoanApplicationCntrl.storedMaskedKYCDoc';
//import getLoanApplication from '@salesforce/apex/IND_LWC_CMURejectController.getLoanApplication';
import getCaseDetails from '@salesforce/apex/IND_LWC_CMURejectController.getCaseDetails';
import updateCase from '@salesforce/apex/IND_LWC_CMURejectController.updateCase';
import getContentDocument from '@salesforce/apex/IND_LWC_CMURejectController.getContentDocument';
import updateCustomerImageFileTitle from '@salesforce/apex/LwcLOSLoanApplicationCntrl.updateCustomerImageFileTitle';
import getDecryptKycNumber from "@salesforce/apex/IND_LWC_CMURejectController.getDecryptKycNumber";
import getEncryptedRequest from "@salesforce/apex/IND_LWC_CMURejectController.getEncryptedRequest";
import updateApplicantDetails from "@salesforce/apex/IND_LWC_CMURejectController.updateApplicantDetails";
import doDocAuthReportAsyncCallout from '@salesforce/apex/IntegrationEngine.doDocAuthReportAsyncCallout';
import getDocAsyncResponse from '@salesforce/apex/LwcLOSLoanApplicationCntrl.getDocAsyncResponse';
import doSelfieReportAsyncCallout from '@salesforce/apex/IntegrationEngine.doSelfieReportAsyncCallout';
import doPANCallout from '@salesforce/apexContinuation/IntegrationEngine.doPANCallout';
import documentUpdateAftergoldenSource from '@salesforce/apex/LwcLOSLoanApplicationCntrl.documentUpdateAftergoldenSource';
import checkIfPanNoIsSameOrNot from '@salesforce/apex/LwcLOSLoanApplicationCntrl.checkIfPanNoIsSameOrNot';//CISP_15480
const columns = [
    {label: 'Document name', fieldName: 'Name', type: 'text', hideDefaultActions: true},
    {label: 'Applicant Name', fieldName: 'Applicant_name__c', type: 'text', hideDefaultActions: true},
    {label: 'Rejection Reason', fieldName: 'CMU_Rejection_Reason__c', type: 'text', hideDefaultActions: true},
    {label: 'Rejected Fields', fieldName: 'Rejection_Fields__c', type: 'text', hideDefaultActions: true},
    {label: 'CMU Comment', fieldName: 'CMU_Comment__c', type: 'text', hideDefaultActions: true},
    {alabel: 'Action', type: 'button', initialWidth: 80, typeAttributes:
    { label: { fieldName: 'actionLabel'}, title: 'Edit', name: 'edit', iconName: 'utility:edit', disabled: {fieldName: 'actionDisabled'}}},
    {alabel: 'Action', type: 'button', initialWidth: 80, typeAttributes:
    { label: { fieldName: 'actionLabel'}, title: 'upload', name: 'upload', iconName: 'utility:upload', disabled: {fieldName: 'actionDisabled'}}},
    {alabel: 'Action', type: 'button', initialWidth: 80,label: 'Doc Auth', typeAttributes:
    { label: { fieldName: 'actionLabel'}, title: 'Doc Auth', name: 'docAuth', iconName: 'utility:file', disabled: true}},
    {alabel: 'Action', type: 'button', initialWidth: 80, label:'Golden Source', typeAttributes:
    { label: { fieldName: 'actionLabel'}, title: 'Golden Source', name: 'goldenSource', iconName: 'utility:contract_doc', disabled: {fieldName: 'actionDisabled'}}},
    {alabel: 'Action', type: 'button', initialWidth: 80, label: 'Front',typeAttributes:
    { label: { fieldName: 'actionLabel'}, title: 'Preview', name: 'previewFront', iconName: 'utility:preview', disabled: {fieldName: 'previewActionDisabled'}}},
    {alabel: 'Action', type: 'button', initialWidth: 80,label: 'Back', typeAttributes:
    { label: { fieldName: 'actionLabel'}, title: 'Preview', name: 'previewBack', iconName: 'utility:preview', disabled: {fieldName: 'previewActionDisabled'}}},
];

export default class IND_LWC_CMURejectComponentController extends NavigationMixin(LightningElement) {
    nsdlPanName ; NSDLPANStatus;
    kycName;firstName = '' ; lastName = '';nsdlResponse;aadhaarSeedingStatus;docAuthButtonButton = false;nsdlPanMatch;
    alphabetCheckLabel = RegEx_Alphabets_Only;//CISP-19498
    lastNameErrorLabel = lastNameError;//CISP-19498
    @track isSubmitButtonDisable = true; //CISP-3718
    //showSpinner = false;
    @track isAcceptCaseModalOpen = false;
    @track acceptCase = false;
    @track caseOwnerId;
    @track caseAcceptedBy;
    @track caseStatus;
    @track uploadButtonDisabled = true;
    @track isTabUser = false;//CISP-2462
    @track tabUrl;//CISP-2462
    @track isSmallDevice;
    communityPartnersURL = IBL_Community_Partners_URL;
    frontUploadDocId;
    backUploadDocId;
    @track data = [];
    uploadedFileIDs = [];
    FileIDsForDeletion = [];
    columns = columns;
    rowOffset = 0;
    error = '';
    isModalOpen = false;
    editableFields = [];
    nonEditableFields = [];
    selectedRowId = '';
    handleBackUpload = false;
    backUploadApp = false;
    @api recordId;
    @api type;
    @api currentDocumentId;
    @api modalPopUpUpload;
    @api currentDocumentRecordTypeId;
    templateFrontBackUpload=true;
    captureApp=false;
    currentUserId = userId;
    currentUserEmailId;
    currentUserName;
    @track showSpinner = false;
    showSpinnerinModel = false;
    @track showOnlyToParterUser = false;
    loanApplicationId;
    fileType = '';
    kycDOCFlag; //CISP-2764
    restrictFileFormat = false;
    isPreview = false;
    converId;
    height = 32;
    @track documentSide = 'Front'; 
    leadSource;//OLA-114
    appEditableFields = [];
    applicantId;
    @track cardMsg;
    isRevoked=false;
    journeyStopReason;
    journeyStatus;
    caseAcceptedByName;
    caseSubmittedBy;
    label={
        currentUserId,
        currentUserName,
        currentUserEmailid,
        currentApplicantid,
        mode,
        AadhaarCard,
        PassportCard,
        VoterIdCard,
        DrivingLicences
    }
    currApplicantID;//CISP-15480
    currApplicantType;//CISP-15480
    @wire(getRecord, { recordId: userId, fields: [UserNameFld, userEmailFld] })
    userDetails({ error, data }) {
        if (data) {
            this.currentUserName = data.fields.Name.value;
            this.currentUserEmailId = data.fields.Email.value;
        } else if (error) {
            console.log('error ',error);
        }
    }

    //Get the initial data where CMU Accept/Rejct field has value Reject
    async connectedCallback(){
        console.log('Record Id:: ', this.recordId);
        
        await checkPortalEnable({}).then(result => {
            console.log('checkPortalEnable:: ',result)
            if(result){
                this.showOnlyToParterUser = true;
            }
        }).catch(error => {
            console.log('Error checkPortalEnable() ::',error);
        })

        if (FORM_FACTOR != 'Large') {
            this.templateFrontBackUpload=false;
            this.captureApp = true;
            this.isSmallDevice=true;
        }

        await getDocumentDetails({caseId : this.recordId}).then(result => {
            this.data = result;
            console.log('getDocumentDetails -result:: ', JSON.stringify(result));
        }).catch(error => {
            console.log('error ### ' , error);
            this.error = error;
        })

        await getCaseDetails({caseId : this.recordId}).then(result => {
            this.loanApplicationId = result.Loan_Application__c;//CISP-3718
            this.acceptCase = result.Accept_Case__c;
            this.caseAcceptedBy = result.CMU_Case_Accepted_By__c;
            this.caseSubmittedBy = result.CMU_Case_Submitted_By__c;
            this.caseOwnerId = result.OwnerId;
            this.caseStatus = result.Status;
            this.leadSource = result.Loan_Application__r.LeadSource; //OLA-114
            if(this.caseAcceptedBy){
                this.caseAcceptedByName = result.CMU_Case_Accepted_By__r.Name;
            }
            this.isRevoked = result.Loan_Application__r.Is_Revoked__c;
            this.journeyStatus = result.Loan_Application__r.Journey_Status__c;
            this.journeyStopReason = result.Loan_Application__r.Journey_Stop_Reason__c;


            if(userId == result.OwnerId && result.Accept_Case__c == true && userId == result.CMU_Case_Accepted_By__c 
                && this.caseStatus.toLowerCase() == 'Pending with Sales'.toLowerCase()){
                this.isSubmitButtonDisable = false;
            }

            if(result.Status == 'Closed'){
                this.isSubmitButtonDisable = true;//CISP-3718
            }
        }).catch(error => {
            console.log('error getCaseDetails ' , error);
            this.error = error;
        })

        await this.getDetailsofDocument();
        
        /*await getLoanApplication({caseId : this.recordId}).then(result =>{
            if(result){
                console.log('result : ',result);
                this.loanApplicationId = result.Loan_Application__c;//CISP-3718
                //OLA-114 start
                this.leadSource = result.Loan_Application__r.LeadSource;
                //OLA-114 end
                if(userId != result.OwnerId){
                    this.isSubmitButtonDisable = true;//CISP-3718
                }
                if(result.Status == 'Closed'){
                    this.isSubmitButtonDisable = true;//CISP-3718
                }
            }
        }).catch(error =>{
            console.log('error in getLoanApplication: ',error);
        })
        */
    }

    async getDetailsofDocument(){
        await getDocumentDetails({caseId : this.recordId}).then(result => {
            this.data = result.documentList;
            this.uploadButtonDisabled = result.isDisabled;
            this.data = this.data.map((rec) => ({ ...rec, actionDisabled: this.uploadButtonDisabled }));
        }).catch(error => {
            console.log('error ### ' , error);
            this.error = error;
        })
    }

    get showAcceptCaseButton(){
        if(this.acceptCase == false && this.caseAcceptedBy == null && this.caseStatus == 'Pending with Sales'){
            return true;
        }else{
            return false;
        }
    }

    get showLWCText(){
        if(this.isRevoked){
            this.cardMsg='The loan application is revoked, hence cannot edit the application';
            return true;
        }else if(this.journeyStopReason!=null || this.journeyStopReason!=undefined  || this.journeyStatus === 'Stop'){
            this.cardMsg='The loan application has undergone a journey restart, hence cannot edit the application';
            return true;
        }else if(this.acceptCase == true && userId != this.caseAcceptedBy && this.caseStatus == 'Pending with Sales'){
            this.cardMsg='This CMU case was already accepted by another user '+this.caseAcceptedByName+', hence you cannot submit';
            return true;
        }else if(this.caseStatus != 'Pending with Sales'){
            this.cardMsg='This CMU case was already submitted by '+this.caseSubmittedBy+', hence cannot submit again';
            return true;
        }
        else{
            return false;
        }
    }
    
    handleAcceptCaseModal(){
        this.showSpinner = true;
        this.isAcceptCaseModalOpen = true;
        this.showSpinner = false;
    }
   
    async handleAcceptCase(){
        this.showSpinner = true;
        await updateCase({caseId : this.recordId}).then(result =>{
            this.acceptCase = true;
            this.caseAcceptedBy = result.caseDetail.CMU_Case_Accepted_By__c;
            this.caseAcceptedByName = result.userName;
            this.caseStatus = result.caseDetail.Status;
            this.caseOwnerId = result.caseDetail.OwnerId;
            
            if( userId == result.caseDetail.OwnerId && result.caseDetail.Accept_Case__c == true && userId == result.caseDetail.CMU_Case_Accepted_By__c 
                && this.caseStatus.toLowerCase() == 'Pending with Sales'.toLowerCase()){
                this.isSubmitButtonDisable = false;
                this.data = this.data.map((rec) => ({ ...rec, actionDisabled: false }));
            }else{
                this.showLWCText = true;// Msg to display case was already accepted by another user
                this.cardMsg='This CMU case was already accepted by another user '+this.caseAcceptedByName+ ', hence you cannot submit';
                this.isSubmitButtonDisable = true;
                this.data = this.data.map((rec) => ({ ...rec, actionDisabled: true }));
            }
            this.isAcceptCaseModalOpen = false;
            this.showSpinner = false;
        }).catch(error =>{
            console.log('error in updateCase: ',error);
            this.isAcceptCaseModalOpen = false;
            this.showSpinner = false;
        })
    }


    get acceptedFormats() {
        if(this.restrictFileFormat)
        {
            return ['.jpg','.jpeg']; //CISP-2764
        }
        else {
            return ['.jpg', '.png','.jpeg'];
        }
    }

    //Open the dialog box when user click on edit
    async handleAction(event){
        const actionName = event.detail.action.name;
        if(this.isSubmitButtonDisable == true && (actionName == 'edit' || actionName == 'upload')){
            this.showToastMessage('', 'You will not be able to perform any action on the case as you are not the case owner', 'Info');
            return null;
        }

        //Added by Rajasekar as part of CISP-21297 - Starts
        let selectedRow = event.detail.row;
        await getDecryptKycNumber({'documentId' : selectedRow.Id}).then(result=>{
            if(result){
                if(result.decryptedKycNumber){
                    this.KycNumber = result.decryptedKycNumber;
                }else if(result.kycNo){
                    this.KycNumber = result.kycNo;
                }
                this.kycDocumentType = result.kycDocumentType;
                this.kycNoAPIName = result.kycNoAPIName;
                console.log('###Decrypted KycNumber ',this.KycNumber);
            }
        });
        //Added by Rajasekar as part of CISP-21297 - Ends
        
        if(actionName === 'edit'){
            let row = event.detail.row;
            this.appEditableFields =[];
            await getDocDetails({docId : row.Id,documentType : event.detail.row.Document_Type__c}).then(result => { 
                this.selectedRowId = row.Id;
                let jsonResult = result.document;
                this.applicantId = jsonResult.Applicant__c;
                let editableFieldAPINames = result.editableFields;                
                this.appEditableFields = result.appFieldList;                
                let nonEditFields = [];
                let uiEditableFields = [];

                for (const [key] of Object.entries(jsonResult)){                                       
                    if(key != 'Id' && key != 'Rejection_Fields__c' && !key.includes('Applicant__r') && key != 'Applicant__c'){ 
                        nonEditFields.push(key);
                    }
                }

                for(let j = 0; j<editableFieldAPINames.length; j++){  
                     for(let step=0; step < nonEditFields.length; step++){
                        if(editableFieldAPINames[j].toUpperCase().trim() === nonEditFields[step].toUpperCase().trim()){
                            uiEditableFields.push(nonEditFields[step]);
                            nonEditFields.splice([step],1);
                        }
                     }
                }
                this.nonEditableFields = nonEditFields;
                this.editableFields = uiEditableFields;
                getDecryptKycNumber({'documentId' : row.Id}).then(result=>{
                    if(result){ 
                        if(result.decryptedKycNumber){ this.KycNumber = result.decryptedKycNumber;
                        }else if(result.kycNo){ this.KycNumber = result.kycNo; }
                        this.kycDocumentType = result.kycDocumentType;
                        this.kycNoAPIName = result.kycNoAPIName;
                        let nonEditableFieldPresent = this.nonEditableFields.filter(result => {return result == this.kycNoAPIName});
                        let filteredData = this.nonEditableFields.filter(result => {return result != this.kycNoAPIName});
                        this.nonEditableFields = filteredData;
                        setTimeout(() => {
                            let editableKycElement = this.template.querySelector(`lightning-input-field[data-name=${this.kycNoAPIName}]`);
                            if(editableKycElement && this.KycNumber){
                                editableKycElement.value = this.KycNumber;
                            }else if(nonEditableFieldPresent){
                                this.enableNewKYCField = true;
                            }
    
                            let nonEditableKycElement = this.template.querySelector(`input[data-name=${this.kycNoAPIName}]`);
                            if(nonEditableKycElement && this.KycNumber){
                                nonEditableKycElement.value = this.KycNumber;
                            }
                        }, );
                    }
                });
            }).catch(error => {
                this.error = error;
            })
            this.isModalOpen = true;
        } else if(actionName === 'upload'){
            let row = event.detail.row;
            console.log('row ---: ',row);
            this.type = row.Document_Type__c;
            this.kycDOCFlag = row.RecordType.Name;
            this.currApplicantID = row.Applicant__c;//CISP-15480
            this.currApplicantType = row.applicant_Type__c;//CISP-15480
            console.log('kycDOCFlag is: ',this.kycDOCFlag)
            this.restrictFileFormat = this.kycDOCFlag =='KYC Document'? true : false;//CISP-2764
            this.currentDocumentId = row.Id;
            this.currentDocumentRecordTypeId = row.RecordTypeId;
            this.modalPopUpUpload = true;
            
            if(this.type === this.label.AadhaarCard || this.type === this.label.PassportCard || this.type === this.label.DrivingLicences || this.type === this.label.VoterIdCard){
                this.handleBackUpload = true;
                this.backUploadApp = true;
                this.documentSide = 'Front'; 
            } else {
                if(this.type == 'Customer Image'){
                    this.documentSide = 'Selfie';
                }else{
                    this.documentSide = 'Front'; 
                }
                this.handleBackUpload = false;
                this.backUploadApp = false;
            }
        } else if(actionName === 'previewFront'){
            let docId;
            let row = event.detail.row;
            this.type = row.Document_Type__c;

            await getContentDocument({ docId: row.Id }).then(result => {
                console.log('Get Content Document - Result:: ', JSON.parse(result));
                let dataResult = JSON.parse(result);
                
                if(dataResult){
                    dataResult?.contentDocLink?.forEach(element => {
                        dataResult.contentVersionList.forEach(item => {
                            if(element.ContentDocumentId == item.ContentDocumentId && (item.Document_Side_fileupload__c == 'Front' || item.Document_Side_fileupload__c == 'Selfie' || item.Document_Side_fileupload__c == undefined )) {
                                this.fileType = item.FileType;
                                if(this.showOnlyToParterUser  || this.leadSource=='OLA'){
                                    docId = item.Id;
                                } else
                                    docId = element.ContentDocumentId;
                                return;
                            }
                        });
                    });
                    this.previewFile(docId, 'Front');
                } else {
                    this.showToastMessage('', 'No File Found', 'Info');
                }
              }).catch(error => {
                console.error('Error:', error);
            });
        } else if(actionName === 'previewBack'){
            let docId;
            let row = event.detail.row;
            this.type = row.Document_Type__c;
            
            await getContentDocument({ docId: row.Id }).then(result => {
                console.log('Get Content Document - Result:: ', JSON.parse(result));
                let dataResult = JSON.parse(result);
                
                if(dataResult){
                    dataResult?.contentDocLink?.forEach(element => {
                        dataResult.contentVersionList.forEach(item => {
                            if(element.ContentDocumentId == item.ContentDocumentId && item.Document_Side_fileupload__c == 'Back'){
                                this.fileType = item.FileType;
                                if(this.showOnlyToParterUser  || this.leadSource=='OLA'){
                                    console.log('in if part : ',);
                                    docId = item.Id;
                                } else
                                    docId = element.ContentDocumentId;
                                return;
                            }
                        });
                    });
                    this.previewFile(docId, 'Back');
                } else {
                    this.showToastMessage('', 'No File Found', 'Info');
                }
            }).catch(error => {
                console.error('Error:', error);
            });
        }else if(actionName == 'docAuth'){
            let row = event.detail.row;
            if(row.Document_Type__c == 'PAN'){
                this.performDocAuth(row.Applicant__c,row.Id);
            }else{
                this.showToastMessage('Info', 'Doc Auth only applicable for PAN document', 'Info');
            }
            
        }
        else if(actionName == 'goldenSource'){
            let row = event.detail.row;
            if(row.Document_Type__c == 'PAN'){
                this.performGoldenSource(row);
            }else{
                this.showToastMessage('Info', 'Golden Source only applicable for PAN document', 'Info');
            }
        }
    }
    performDocAuth(docApplicantId,docId){
        if(this.frontUploadDocId == null){
            this.showToastMessage('Info', 'Please upload document first', 'Info');return null;
        }else{
            this.docAuthButtonButton = true
        console.log('OUTPUT docApplicantId: ',docApplicantId);
        console.log('OUTPUT docId: ',docId);
        this.showSpinner = true;
        doDocAuthReportAsyncCallout({ applicantId: docApplicantId, documentId: docId, loanApplicationId: this.loanApplicationId })
            .then(result => {
                let response = JSON.parse(result);
                console.log('OUTPUT response: ',response);
                this.showSpinner = false;
                getDocAsyncResponse({ documentId: docId })
                    .then(result => {
                        this.showSpinner = false;
                    }).catch(error => {
                        this.showSpinner = false;
                    });
            }).catch(error => {console.log('OUTPUTerror : ',error);this.showSpinner = false;});
        doSelfieReportAsyncCallout({ applicantId: docApplicantId, documentId: docId, loanApplicationId: this.loanApplicationId })
            .then(result => {this.showSpinner = false;})
            .catch(error => {this.showSpinner = false;});
        }
        }
    async performGoldenSource(row){
        // if(this.docAuthButtonButton){ CISP-22905
        this.showSpinner = true;
        let kycPanDetails = {
            'applicantId': row.Applicant__c,
            'panNumber': this.KycNumber,
            'firstName': this.firstName != '' ? this.firstName :row.First_Name__c,
            'lastName': this.lastName != '' ? this.lastName : row.Last_Name__c,
            'loanApplicationId': this.loanApplicationId  };
           await doPANCallout({ 'kycPanDetailRequest': JSON.stringify(kycPanDetails) })
          .then(result => {
            console.log('Result', result);
            this.showSpinner = false;
            const obj = JSON.parse(result);
            if (obj.response.content[0].NSDLPANStatus == 'E') {
                this.nsdlPanName = obj.response.content[0].Name;
                this.NSDLPANStatus = obj.response.content[0].NSDLPANStatus;
                this.nsdlPanMatch = obj.response.content[0].IDNSDLNameMatch;
                this.nsdlResponse = obj.response.content[0].NSDLPANStatusDesc;this.aadhaarSeedingStatus = obj.response.content[0].NSDLAadhaarSeedingStatus;
                if(obj.response.content[0].NSDLAadhaarSeedingStatus != 'Y'){this.showToastMessage('Error', 'PAN is not linked to Aadhaar.Please re-upload PAN once PAN is linked to Aadhaar', 'error');}
                this.handleGoldenSourceUpdate(true,row.Id);
                this.showToastMessage(obj.response.content[0].NSDLReturnCdDesc, obj.response.content[0].NSDLPANStatusDesc, 'success');
            } else if (obj.response.content[0].NSDLPANStatus == 'F' || 'X' || 'D' || 'N' || 'EA' || 'EC' || 'ED' || 'EI' || 'EL' || 'EM' || 'EP' || 'ES' || 'EU') {
                this.nsdlResponse = obj.response.content[0].NSDLPANStatusDesc;this.aadhaarSeedingStatus = obj.response.content[0].NSDLAadhaarSeedingStatus;
                this.handleGoldenSourceUpdate(false,row.Id);
                let errmsg = obj.response.content[0].NSDLPANStatusDesc != null ? obj.response.content[0].NSDLPANStatusDesc : 'Invalid';
                this.showToastMessage('Error', errmsg + ' please upload a valid PAN in order to proceed', 'error');
            }
          })
          .catch(error => {
            console.error('Error:', error);
            this.showSpinner = false;
            this.showToastMessage('Error', 'Please retry.', 'error');
        });
        // }else{
        //     this.showToastMessage('Error', 'Please click on Doc Auth first.', 'error');
        // }CISP-22905
    }
    handleGoldenSourceUpdate(isgoldenSourcePass,docId){
        console.log('OUTPUT : ',this.aadhaarSeedingStatus);
        documentUpdateAftergoldenSource({ documentId: docId,nsdlResponse: this.nsdlResponse,aadhaarSeedingStatus:this.aadhaarSeedingStatus, goldenSourcePass:isgoldenSourcePass,nsdlPanName : this.nsdlPanName ,NSDLPANStatus : this.NSDLPANStatus,nsdlPanMatch :this.nsdlPanMatch })
          .then(result => {
            console.log('Result', result);
          })
          .catch(error => {
            console.error('Error:', error);
        });
    }
    KycNumber = '';
    kycDocumentType;
    kycNoAPIName;
    @track enableNewKYCField;

    hideModalBox() {
        this.isPreview = false;
    }
    
    previewFile(contentDocId, sSide){      
        if(contentDocId){
            if(this.showOnlyToParterUser || this.leadSource=='OLA'){
                /*//CSIP-300
                if(FORM_FACTOR != 'Large'){
                    this.isTabUser = true;// CISP-2462
                    this.tabUrl = this.communityPartnersURL+ '/sfc/servlet.shepherd/version/renditionDownload?rendition=ORIGINAL_'+ this.fileType +'&versionId=' + contentDocId// CISP-2462
                }
                else{
                    console.log('OUTPUT FORM_FACTOR large: ',FORM_FACTOR);
                    this[NavigationMixin.Navigate]({
                        type: 'standard__webPage',
                        attributes: {
                            url : this.communityPartnersURL+ '/sfc/servlet.shepherd/version/renditionDownload?rendition=THUMB720BY480&versionId=' + contentDocId
                        }
                    }, false );
                }*/
                this.converId = contentDocId;
                this.isPreview = true;
            } else {
                this[NavigationMixin.Navigate]({
                    type: 'standard__namedPage',
                    attributes: {
                        pageName: 'filePreview'
                    },
                    state: {
                        selectedRecordId: contentDocId
                    }
                });
            }
        } else {
            let message = '';
            
            if(this.type === this.label.AadhaarCard || this.type === this.label.PassportCard || this.type === this.label.DrivingLicences || this.type === this.label.VoterIdCard){
                message = sSide + ' side file not uploded yet';
            } else {
                message = sSide + ' side file not available for this document type';
            }

            this.showToastMessage('Info', message, 'Info');
        }
    }

    handleDocumentPopupClose(){
        this.modalPopUpUpload = false;
    }

    async handleDocumentUploadDoneButton(){
        let detetionFiles;
        if(this.captureApp){
            await getContentDocument({ docId: this.currentDocumentId }).then(result => {
                console.log('handleDocumentUploadDoneButton Get Content Document - Result:: ', JSON.parse(result));
                let dataResult = JSON.parse(result);
                
                if(dataResult){
                    if(this.type == this.label.AadhaarCard || this.type == 'PAN') {
                        for(let i=0;i<dataResult.contentVersionList.length; i++){
                            if(dataResult.contentVersionList[i].Document_Side_fileupload__c == 'Front'  || dataResult.contentVersionList[i].Document_Side_fileupload__c == '' || dataResult.contentVersionList[i].Document_Side_fileupload__c == undefined || dataResult.contentVersionList[i].Document_Side_fileupload__c == null) {
                                this.fileType = dataResult.contentVersionList[i].FileType;
                                    this.frontUploadDocId = dataResult.contentVersionList[i].ContentDocumentId;
                                    this.frontuploadApi();
                                break;
                            }
                        }
                        
                        for(let i=0;i<dataResult.contentVersionList.length; i++){
                            if(dataResult.contentVersionList[i].Document_Side_fileupload__c == 'Back' || dataResult.contentVersionList[i].Document_Side_fileupload__c == '' || dataResult.contentVersionList[i].Document_Side_fileupload__c == undefined || dataResult.contentVersionList[i].Document_Side_fileupload__c == null) {
                                this.fileType = dataResult.contentVersionList[i].FileType;
                                    this.backUploadDocId = dataResult.contentVersionList[i].ContentDocumentId;
                                    this.backuploadApi();
                                break;
                            }
                        }
                    } else {
                        dataResult?.contentDocLink?.forEach(element => {
                            this.uploadedFileIDs.push(element.ContentDocumentId);
                        });
                        if(this.type == 'Customer Image'){
                            this.deleteDocsOnUploadFinish(this.uploadedFileIDs,'Selfie')
                        }else
                            this.deleteDocsOnUploadFinish(this.uploadedFileIDs,'Front');
                    }
                                        
                } else {
                    this.showToastMessage('', 'No File Found', 'Info');
                }
                console.log('handleDocumentUploadDoneButton : ',JSON.stringify(this.FileIDsForDeletion));  
                detetionFiles = JSON.stringify(this.FileIDsForDeletion);
              }).catch(error => {
                console.error('Error:', error);
            });
        }
        console.log('handleDocumentUploadDoneButton : ',this.currentDocumentId); 
         //this.deletedocs();
        this.FileIDsForDeletion = [];
        this.uploadedFileIDs = [];
        this.modalPopUpUpload = false;
        /*if(this.type == this.label.AadhaarCard && !this.captureApp){
            console.log('handleDocumentUploadDoneButton : ',JSON.stringify(this.FileIDsForDeletion));  
            detetionFiles = JSON.stringify(this.FileIDsForDeletion);
        }else{
            console.log('handleDocumentUploadDoneButton : ',JSON.stringify(this.uploadedFileIDs)); 
            detetionFiles = JSON.stringify(this.uploadedFileIDs);
        }*/

        /*await deleteRelatedDocuments({documentId : this.currentDocumentId,contentDocumentIds : detetionFiles}).then(() => {
            this.showToastMessage('Success', 'Documents are replaced Successfully.', 'success');
            this.modalPopUpUpload = false;
        }).catch(error => {
            this.error = error;
            this.showToastMessage('error', error, 'error');
            this.modalPopUpUpload = false;
        })*/

        
    }

    deleteDocsOnUploadFinish(detetionFiles,documentside){
        console.log('OUTPUT deleteDocsOnUploadFinish: ',detetionFiles);
        if(detetionFiles.length > 0){
            deleteRelatedDocumentsOnUpload({documentId : this.currentDocumentId,contentDocumentIds : JSON.stringify(detetionFiles),docSide:documentside}).then(() => {
                this.showToastMessage('Success', 'Documents are replaced Successfully.', 'success');
                this.FileIDsForDeletion = [];
                this.uploadedFileIDs = [];
            }).catch(error => {
                this.error = error;
                this.showToastMessage('error', error, 'error');
                console.log('OUTPUT ***: ',error);
            });
        }
    }

    deletedocs() {
        console.log('deletedocs---- : ',this.FileIDsForDeletion);  
        let detetionFiles = [];
        if(this.type == this.label.AadhaarCard){
            console.log('handleDocumentUploadDoneButton : ',JSON.stringify(this.FileIDsForDeletion));  
            detetionFiles = JSON.stringify(this.FileIDsForDeletion);
        }else{
            console.log('handleDocumentUploadDoneButton : ',JSON.stringify(this.uploadedFileIDs)); 
            detetionFiles = JSON.stringify(this.uploadedFileIDs);
        }
        if((this.FileIDsForDeletion.length >= 2 && this.type == this.label.AadhaarCard) || ((this.type == this.label.PassportCard || this.type == this.label.VoterIdCard || this.type == this.label.DrivingLicences) && this.uploadedFileIDs.length >= 2) || ((this.type != this.label.AadhaarCard && this.type != this.label.PassportCard && this.type != this.label.VoterIdCard && this.type != this.label.DrivingLicences) && this.uploadedFileIDs.length > 0)){  
        deleteRelatedDocuments({documentId : this.currentDocumentId,contentDocumentIds : detetionFiles}).then(() => {
            this.showToastMessage('Success', 'Documents are replaced Successfully.', 'success');
            this.FileIDsForDeletion = [];//CISP-2805
            this.uploadedFileIDs = [];//CISP-2805
            this.modalPopUpUpload = false;
        }).catch(error => {
            this.error = error;
            this.showToastMessage('error', error, 'error');
            this.modalPopUpUpload = false;
        });
        }
    }

    async backuploadApi() {
        this.showSpinnerinModel = true;
        await doOCRbuCallout({ documentId: this.currentDocumentId, contentDocumentId: this.backUploadDocId, loanAppId: this.loanApplicationId }).then(response => {
            const obj = JSON.parse(response);
            const status = obj.ResponseData.Fields.Applicants.Applicant.Services.Service[0].Status;
            console.log('OCR BU Callout:: ' ,obj);
            
            if (status == 'Pass') {
                this.backUploadRedCross = false;
                var responseData = obj.ResponseData.Fields.Applicants.Applicant.Services.Service[0].Operations.Operation[0].Data.Response.RawResponse;
                const parsedRespData = JSON.parse(responseData);                   
                let base64ImageResp = parsedRespData.result[0].details.base64Image;
                
                storedMaskedKYCDoc({base64Imag : base64ImageResp , documentId : this.currentDocumentId,docSide : 'Back',contentDocumentId:this.backUploadDocId }).then(response => {
                    console.log('storedMaskedKYCDoc Response:: ', response);
                    this.showSpinnerinModel = false;
                    this.FileIDsForDeletion.push(response);
                    //this.deletedocs();
                    this.deleteDocsOnUploadFinish(this.FileIDsForDeletion,'Back');
                    console.log('FileIDsForDeletion in back ---' ,this.FileIDsForDeletion);
                }).catch(error => {
                    console.log('storedMaskedKYCDoc Error:: ', error);
                });
                
                this.showToastMessage('Uploaded', 'Back OCR successful', 'success');
                
            } else if (status == 'Fail') {
                this.showSpinnerinModel = false;//CISP-2805
                console.log('back status fail : ',);
                this.FileIDsForDeletion.push(this.backUploadDocId);//CISP-2805
                this.deleteDocsOnUploadFinish(this.FileIDsForDeletion ,'Back');
            }
        }).catch(error => {
            this.showSpinnerinModel = false;//CISP-2805
            console.log('error OCR Back', error);
            this.FileIDsForDeletion.push(this.backUploadDocId);//CISP-2805
            this.deleteDocsOnUploadFinish(this.FileIDsForDeletion ,'Back');
        }).finally(() => {
        });
        //this.deletedocs();//CISP-2805
        
    }

    async frontuploadApi() {
        this.showSpinnerinModel = true;
        console.log('this.showSpinnerinModel : ',this.showSpinnerinModel);
        
        await doOCRfuCallout({ documentId: this.currentDocumentId, contentDocumentId: this.frontUploadDocId, loanAppId: this.loanApplicationId }).then(response => {
            this.disableAadharBackButton = false;
            const obj = JSON.parse(response);
            const status = obj.ResponseData.Fields.Applicants.Applicant.Services.Service[0].Status;
            console.log('obj  : ',obj);
            
            if (status == 'Pass') {
                var responseData = obj.ResponseData.Fields.Applicants.Applicant.Services.Service[0].Operations.Operation[0].Data.Response.RawResponse;
                const parsedRespData = JSON.parse(responseData);
                let base64ImageResp = parsedRespData.result[0].details.base64Image;
                if(this.type == this.label.AadhaarCard){
                storedMaskedKYCDoc({base64Imag : base64ImageResp , documentId : this.currentDocumentId,docSide : 'Front',contentDocumentId:this.frontUploadDocId }).then(response => {
                    console.log('storedMaskedKYCDoc - Response:: ', response);
                    this.FileIDsForDeletion.push(response);
                    //this.deletedocs();
                    this.deleteDocsOnUploadFinish( this.FileIDsForDeletion , 'Front');
                    console.log('FileIDsForDeletion in front ---' ,this.FileIDsForDeletion);
                }).catch(error => {
                    console.log('storedMaskedKYCDoc - Error:: ', error);
                });
            }else if(this.type == 'PAN'){
                this.kycName = parsedRespData.result[0].details.name.value;var apiResFirstName = "";var apiResLastName = "";
                    if (this.kycName.split(" ").length > 1) {
                        apiResFirstName = this.kycName.substring(0, this.kycName.lastIndexOf(' '));
                        apiResLastName = this.kycName.substring(this.kycName.lastIndexOf(' ') + 1);
                    }else{apiResFirstName = this.kycName;}
                    this.firstName = apiResFirstName;this.lastName = apiResLastName;
                    this.KycNumber = parsedRespData.result[0].details.pan_no.value;
                    this.FileIDsForDeletion.push(this.frontUploadDocId);//CISP-2805
                    checkIfPanNoIsSameOrNot({ panNo: this.KycNumber , applicantId: this.currApplicantID, leadApplicationId : this.loanApplicationId })
                            .then(result => {
                                console.log('Result', result);
                                if(result && result.length > 0 && result[0].samePanUploaded){
                                    this.showToastMessage( 'Error','Please select different Pan. It is already uploaded for ' +  result[0].applicantType, 'error');
                                    this.modalPopUpUpload = false;
                                    this.frontUploadDocId = null;
                                    this.FileIDsForDeletion = [];
                                }else{
                                    this.deleteDocsOnUploadFinish(this.FileIDsForDeletion,'Front');
                                }
                            })
                            .catch(error => {
                                console.error('Error:', error);
                        });
            }
                this.showSpinnerinModel = false;
                this.showToastMessage('Uploaded', 'Front OCR successful', 'success');
                
            } else if (status == 'Fail') {
                console.log('status fail : ',);
                this.showSpinnerinModel = false;//CISP-2805
                this.FileIDsForDeletion.push(this.frontUploadDocId);//CISP-2805
                this.deleteDocsOnUploadFinish(this.FileIDsForDeletion,'Front')
            }
        }).catch(error => {
            this.showSpinnerinModel = false;//CISP-2805
            console.log('Front ocr error', error);
            this.FileIDsForDeletion.push(this.frontUploadDocId);//CISP-2805
            this.deleteDocsOnUploadFinish(this.FileIDsForDeletion,'Front')
        }).finally(() => {

        })
        //this.deletedocs();//CISP-2805
    }

    handleFrontUploadFinished(event){
        console.log('handleFrontUploadFinished : ',event.detail.files);
        const uploadedFiles = event.detail.files;
        
        for(let i = 0; i < uploadedFiles.length; i++) {
            this.uploadedFileIDs.push(uploadedFiles[i].documentId);
        }  

        console.log('this.uploadedFileIDs : ',this.uploadedFileIDs);    
        
        if(this.type == this.label.AadhaarCard || this.type == 'PAN'){
            this.frontUploadDocId = uploadedFiles[0].documentId;
            this.frontuploadApi();
        }else if(this.type != this.label.AadhaarCard && this.type != 'Customer Image'){
            this.deleteDocsOnUploadFinish(this.uploadedFileIDs,'Front'); 
        }

        if(this.type == 'Customer Image'){
            updateCustomerImageFileTitle({'documentId' : this.currentDocumentId, 'contentDocumentData':uploadedFiles[0].documentId});
            this.deleteDocsOnUploadFinish(this.uploadedFileIDs,'Selfie'); 
        }
        /*if((this.type != this.label.AadhaarCard && this.type != this.label.PassportCard && this.type != this.label.VoterIdCard && this.type != this.label.DrivingLicences && this.uploadedFileIDs.length >= 1) || ((this.type == this.label.PassportCard || this.type == this.label.VoterIdCard || this.type == this.label.DrivingLicences) && this.uploadedFileIDs.length >= 2)){
            this.modalPopUpUpload = false;
            this.handleDocumentUploadDoneButton();
        }*/
        

        this.showToastMessage('Uploaded', 'Front uploaded', 'success');
    }

    handleBacktUploadFinished(event){
       const uploadedFiles = event.detail.files;
        for(let i = 0; i < uploadedFiles.length; i++) {
            this.uploadedFileIDs.push(uploadedFiles[i].documentId);
        }

        this.showToastMessage('Uploaded', 'Back uploaded', 'success');

        if(this.type == this.label.AadhaarCard){
            this.backUploadDocId = uploadedFiles[0].documentId;
            this.backuploadApi();
        }else{
            this.deleteDocsOnUploadFinish(this.uploadedFileIDs,'Back'); 
        }
       /* if((this.type == this.label.PassportCard || this.type == this.label.VoterIdCard || this.type == this.label.DrivingLicences) && this.uploadedFileIDs.length >= 2){
            this.modalPopUpUpload = false;
            this.handleDocumentUploadDoneButton();
        }*/
    }

    handleSuccess() {
        const evt = new ShowToastEvent({
            title : 'Success',
            message : 'Document Details saved successfully.',
            variant : 'success'
        });
        this.dispatchEvent(evt);
        this.closeModal();
    }

    async handleOnSubmit(event){
        event.preventDefault();
        try {
            if(this.emptyFieldCheck('.docInpuField')){
                this.showToastMessage('error', 'Please enter values in all Rejected Fields!', 'error');
                return;
            }else{
                let editableKycElement = this.template.querySelector(`lightning-input-field[data-name=${this.kycNoAPIName}]`);
                let maskedAadhaarNumber;
                if(editableKycElement){
                    let kycNo = editableKycElement.value;
                    if(!kycNo){ 
                        const evt = new ShowToastEvent({
                            title : 'Error',
                            message : 'KYC number is required.',
                            variant : 'error'
                        });
                        this.dispatchEvent(evt);
                        return; 
                    }
                    if(this.kycDocumentType == 'Aadhaar No.'){
                        maskedAadhaarNumber = kycNo.replace(/\d(?=\d{4})/g, "*");
                    }
                    let result = await getEncryptedRequest({'requestJSON':kycNo});
                    editableKycElement.value = result;
                }
                const fields = {};
                await this.template.querySelectorAll(`lightning-input-field`).forEach((input) => {
                    fields[input.fieldName] = input.value;
                });
                if(this.appEditableFields?.length > 0){
                    const validateInputField = (fieldValue) => {
                        return String(fieldValue).toLowerCase().match(/^(?=.{3,26}$)((^[A-Za-z ]+$)\2?(?!\2))+$/);
                    };
                    let invalidInputField = false;
                    this.appEditableFields.forEach((item) => {
                            if(validateInputField(item.value) == null)
                            {
                                invalidInputField = true;
                            }
                       
                    });
                    if(!invalidInputField)
                    updateApplicantDetails({appFieldList: this.appEditableFields, applicantId : this.applicantId})
                    else
                    {
                    const evt = new ShowToastEvent({
                        title : 'Error',
                        message : 'Invalid input field(s)',
                        variant : 'error'
                    });
                    this.dispatchEvent(evt);
                    return;
                    }

                }
                if(maskedAadhaarNumber){ fields['Masked_KYC_No__c'] = maskedAadhaarNumber;}
                this.template.querySelector('lightning-record-edit-form').submit(fields);
            }
        } catch (error) {
            console.log(error);
        }
    }

    handleError() {
        const evt = new ShowToastEvent({
            title : 'Error',
            message : 'Document Details failed to update.',
            variant : 'error'
        });
        this.dispatchEvent(evt);
        this.closeModal();
    }     

    closeModal(){
        this.isModalOpen = false;
        this.KycNumber = '';
        this.kycDocumentType = '';
        this.kycNoAPIName = '';
        this.enableNewKYCField = false;
        this.isAcceptCaseModalOpen = false;
    }

    captureFrontApp() {
        if(this.type == 'Customer Image'){
            this.captureCustomerImageApp('Selfie');

        }else{
            this.captureCustomerImageApp('Front');
        }
    }

    captureBackApp() {
        this.captureCustomerImageApp('Back');
    }

    captureCustomerImageApp(docSide) {
        console.log('URL:: ibl://indusindbank.com/integratorInfo?' + this.label.currentApplicantid + '=' + this.currApplicantID + '&' + this.label.currentUserId + '=' + this.currentUserId + '&' + this.label.mode + '=' + this.type + '&' + this.label.currentUserName + '=' + this.currentUserName + '&' + this.label.currentUserEmailid + '=' + this.currentUserEmailId + '&documentSide=' + docSide + '&loanApplicationId=' +  this.recordId + '&documentRecordTypeId=' +  this.currentDocumentRecordTypeId);

        this[NavigationMixin.Navigate]({
            type: "standard__webPage",
            attributes: {
                url: 'ibl://indusindbank.com/integratorInfo?' + this.label.currentApplicantid + '=' + this.currApplicantID + '&' + this.label.currentUserId + '=' + this.currentUserId + '&' + this.label.mode + '=' + this.type + '&' + this.label.currentUserName + '=' + this.currentUserName + '&' + this.label.currentUserEmailid + '=' + this.currentUserEmailId + '&documentSide=' + docSide + '&loanApplicationId=' +  this.recordId + '&documentRecordTypeId=' +  this.currentDocumentRecordTypeId
            }
        });
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

    showToastMessageModeBased(title, message, variant, mode) {
        if (title) {
            this.dispatchEvent(new ShowToastEvent({
                title: title,
                message: message,
                variant: variant,
                mode: mode,
            }));
        } else {
            this.dispatchEvent(new ShowToastEvent({
                message: message,
                variant: variant,
                mode: mode,
            }));
        }
    }

    async handleSubmit(){
        this.showSpinner = true;
        let submitInput = this.template.querySelector('c-i-N-D_-L-W-C_-L-O-S_-C-M-U-Submit-Action');
        console.log('Submit Input:: ', submitInput);
        
        if(submitInput){
            await submitInput.changeOwnerOnCmuSubmitAction();
        }
        this.showSpinner = false;
    }

    handleOnAppFieldChange(event){
        let fieldName = event.target.label;
        let fieldvalue = event.target.value;
        this.appEditableFields.find(opt => opt.label === fieldName).value = fieldvalue;
        console.log(this.appEditableFields);
    }

    emptyFieldCheck(query) {
        let isEmpty = false;
        [...this.template.querySelectorAll(query)].forEach(inputField => {
            if (!inputField.value) {
                isEmpty = true;
            }
        });
        return isEmpty;
    }
}