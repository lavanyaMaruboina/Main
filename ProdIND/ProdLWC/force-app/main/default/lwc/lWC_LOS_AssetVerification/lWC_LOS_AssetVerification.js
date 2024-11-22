import { LightningElement,api,track,wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord } from 'lightning/uiRecordApi';
import UserNameFld from '@salesforce/schema/User.Name';
import userEmailFld from '@salesforce/schema/User.Email';
import userId from '@salesforce/user/Id';
import { NavigationMixin } from 'lightning/navigation';
import getassetVerificationsId from '@salesforce/apex/LWCLOSAssetVerificationCntrl.getassetVerificationsId';
//import getassetVerificationsRecord from '@salesforce/apex/LWCLOSAssetVerificationCntrl.getassetVerificationsRecord';
import createCaseAVRecords from '@salesforce/apex/LWCLOSAssetVerificationCntrl.createCaseAVRecords';
import createDocumentRecord from '@salesforce/apex/LWCLOSAssetVerificationCntrl.createDocumentRecord';
import FORM_FACTOR from '@salesforce/client/formFactor';
import deleteDocument from '@salesforce/apex/LWCLOSAssetVerificationCntrl.deleteDocument';
import sendNotification from '@salesforce/apex/LWCLOSAssetVerificationCntrl.sendNotification';
import isDocumentUploaded from '@salesforce/apex/LWCLOSAssetVerificationCntrl.isDocumentUploaded';
import checkAssetVerificationStatus from '@salesforce/apex/LWCLOSAssetVerificationCntrl.checkAssetVerificationStatus'; // SFTRAC-665
import previewDocument from '@salesforce/apex/LWCLOSAssetVerificationCntrl.previewDocument'; // SFTRAC-1130
import { refreshApex } from '@salesforce/apex';
import haveCaseAccesibility from '@salesforce/apex/LWCLOSAssetVerificationCntrl.haveCaseAccesibility';//CISP: 2692
export default class LWC_LOS_AssetVerification extends NavigationMixin(LightningElement) {
    @api recordId ;

    oppvehicleType = null;
    
    isTypeNew = false;
    isTypeNewUsedRef = false;
    isTypeUsedRef = false;
    @api dealId; //SFTRAC-99
    @api psdStage; //SFTRAC-99
    @track avRecIdList = [];
    applicantId;
    loanApplicationId;
    loanDetailsStageName;
    loanDetailsSubStage;
    documentType;
    currentAVId;
    showUpload = false;
    showDocView = false;
    isVehicleDoc = false;
    isAllDocType = false;
    uploadViewDocFlag = false;
    @track isModalOpen = false;
    sendingRecordTypeName = 'Asset Verification Documents';
    //@track dateOfSubmission;
    isPSStage = false; //SFTRAC-147
   isAssetCaseVerified = false;
    allowEdit = false;

    engineImgUploaded = false; //SFTRAC-665
    chassisImgUploaded = false; //SFTRAC-665
    selfieWithVehImgUploaded = false; //SFTRAC-665
    vehFrontImgUploaded = false; //SFTRAC-665
    vehBackImgUploaded = false; //SFTRAC-665

    vehRightImgUploaded = false; //SFTRAC-665
    vehLeftImgUploaded = false; //SFTRAC-665
    hmrImgUploaded = false; //SFTRAC-665
    chassisPlateImgUploaded = false; //SFTRAC-665
    get isWebApp(){
        return FORM_FACTOR == 'Large' ? true : false;
    }

    @track currentUserName;
    @track currentUserEmailId;
    @wire(getRecord, { recordId: userId, fields: [UserNameFld, userEmailFld] })
    userDetails({ error, data }) 
    {
        if (data) {
            this.currentUserName = data.fields.Name.value; 
            this.currentUserEmailId = data.fields.Email.value; 
        } else if (error) {
            console.log(error);
        }
    }

    navigateToIntegratorApp() {
        this[NavigationMixin.Navigate]({
            type: "standard__webPage",
            attributes: {
                url: 'ibl://indusindbank.com/integratorInfo?leadId=' + this.applicantId + '&userid=' + userId + '&mode=' + this.documentType + '&username=' + this.currentUserName + '&useremailid=' + this.currentUserEmailId + '&documentSide=Front&caseID=' + this.recordId
            }
        });
    }
    @track caseAccessable;
    renderedCallback(){
        if(this.caseAccessable == false && !this.psdStage) {
            if(this.template.querySelectorAll('lightning-button') && this.template.querySelectorAll('lightning-button').length > 0){
                this.template.querySelectorAll('lightning-button').forEach(element => {
                    element.disabled = true;
                });
            }
            const evt = new ShowToastEvent({
                title: 'This case is owned by another user. It is available in Read only mode. You will not able to edit it.',
                variant: 'warning',
                mode: 'dismissable' });
            this.dispatchEvent(evt);
        }
    }
    async connectedCallback() {
        this.caseAccessable = await haveCaseAccesibility({'caseId' : this.recordId});
        await this.init(); 
        if(this.oppvehicleType == 'New'){
            this.isTypeNew = true;
            if(this.oppvehicleType =='Used' || this.oppvehicleType =='Refinance'){
                this.isTypeNewUsedRef = true;    
            }
        }else if(this.oppvehicleType =='Used' || this.oppvehicleType =='Refinance'){
            this.isTypeUsedRef = true;    
        }
        if(this.loanDetailsStageName =='Disbursement Request Preparation' && this.isAssetCaseVerified == true){
            this.isPSStage = true;
        }else if(this.isAssetCaseVerified == false){
            this.allowEdit = true;
        }
    }
    avRecId;
    async init() {  
        console.log('this.recordid ',this.recordId);
                await getassetVerificationsId({caseId : this.recordId, psdStage : this.psdStage, dealId : this.dealId}).then(response =>{ 
            console.log('getassetVerificationsId response ',response);
            this.avRecIdList = response.aVIDWrapperList;
            this.oppvehicleType = response.vehicleType;
            this.applicantId = response.applicantId;
            this.loanApplicationId = response.loanDetailsId;
            this.loanDetailsStageName = response.loanDetailsStageName;
            this.loanDetailsSubStage = response.loanDetailsSubStage;
            this.avRecIdList = this.avRecIdList.map((avItem) => {return { ...avItem, Status__c:avItem.avStatusValue};});//SFTRAC-1431
            return refreshApex(this.avRecIdList); //SFTRAC-1431 
        }).catch(error => { 
            console.log('assetVerifications Error:: ',error);
        });
        setTimeout(() => {
        }, 60000);

        console.log('this.avRecIdList '+ this.avRecIdList +'oppvehicleType '+this.oppvehicleType);
        let result1 = await checkAssetVerificationStatus({'loanApplicationId': this.recordid});
                result1 = result1.trim();
                if (result1 == 'Asset Verification Completed') {
                    this.isAssetCaseVerified = true;
                } else {
                    //this.toastMsg('Asset Verification is not completed. Please complete it before get valuation.');
                    this.isAssetCaseVerified = false;
                }

        //SFTRAC-1785 Starts
        let options = [
            { label: 'Capture Engine Number', value: 'Engine Number uploaded during verification', subTypes: ['Harvester', 'Tractor'] },
            { label: 'Capture Chassis Number ', value: 'Chassis Number uploaded during verification', subTypes: ['Harvester', 'Tractor'] },
            { label: 'Capture Chassis plate', value: 'Capture Chassis plate', subTypes: ['Harvester', 'Tractor'] },
            { label: 'Capture Selfie with Asset & Customer', value: 'Selfie with Vehicle-uploaded during verification', subTypes: ['Implement', 'Harvester', 'Tractor'] },
            { label: 'Capture Vehicle Front', value: 'Vehicle Front-uploaded during verification', subTypes: ['Implement', 'Harvester', 'Tractor'] },
            { label: 'Capture Vehicle Back', value: 'Vehicle Back-uploaded during verification', subTypes: ['Implement', 'Harvester', 'Tractor'] },
            { label: 'Capture Vehicle Right Side', value: 'Capture Vehicle Right Side', subTypes: ['Implement', 'Harvester', 'Tractor'] },
            { label: 'Capture Vehicle Left Side', value: 'Capture Vehicle Left Side', subTypes: ['Implement', 'Harvester', 'Tractor'] },
            { label: 'Capture HMR', value: 'Capture HMR', subTypes: ['Harvester', 'Tractor'] },
            { label: 'Capture Serial Number', value: 'Capture Serial Number', subTypes: ['Implement'] }, //SFTRAC-1785
        ];
        this.documentTypeList = options;
        console.log('this.documentTypeList ++ ',this.documentTypeList);
        //SFTRAC-1785 End
    }

    handleToggleSection(event) {
        this.activeSectionMessage =
            'Open section name:  ' + event.detail.openSections;
    }
    @track documentTypeList =[];
    @track filteredOptions = []; //SFTRAC-1785
    /*get aVDocList() {
        let options = [
            { label: 'Capture Engine Number', value: 'Engine Number uploaded during verification' },
            { label: 'Capture Chassis Number ', value: 'Chassis Number uploaded during verification' },
            { label: 'Capture Chassis plate', value: 'Capture Chassis plate' },
            { label: 'Capture Selfie with Asset & Customer', value: 'Selfie with Vehicle-uploaded during verification' },
            { label: 'Capture Vehicle Front', value: 'Vehicle Front-uploaded during verification' },
            { label: 'Capture Vehicle Back', value: 'Vehicle Back-uploaded during verification' },
            { label: 'Capture Vehicle Right Side', value: 'Capture Vehicle Right Side' },
            { label: 'Capture Vehicle Left Side', value: 'Capture Vehicle Left Side' },
            { label: 'Capture HMR', value: 'Capture HMR' },
        ];
        this.documentTypeList = options;
        console.log('this.documentTypeList ++ ',this.documentTypeList);
        return options;
    }*/
    //SFTRAC-1785 Start
    filterOptions(subType) {
        console.log('+++++subType ', subType);
        console.log('+++++this.documentTypeList ', this.documentTypeList);
        return this.documentTypeList.filter(option => option.subTypes.includes(subType));
    }//SFTRAC-1785 End

    /*submithandler(event){
        console.log('SUBMIT 006C20000098yprIAA');
        createCaseAVRecords({loanApplicationId : '006C20000098yprIAA'}).then(result =>{
            console.log('createCaseAVRecords Error:: ',result);
        })
        .catch(error =>{
            console.log('createCaseAVRecords Error:: ',error);
        })
    }*/
    handleStatusChange(event) {
        const selectedStatus = event.detail.value;
        console.log('selectedStatus', selectedStatus);
        const recordId = event.target.dataset.recordId;
        console.log('recordId', recordId);
        console.log('avRecIdList', this.avRecIdList);
        const avRecord = this.avRecIdList.find(av => av.avId === recordId);
        console.log('avRecord', avRecord);

        if (selectedStatus === 'Completed') {
            if (avRecord) {
                const currentDate = new Date().toISOString();
                this.avRecIdList = this.avRecIdList.map((avItem) => {
                    if (avItem.avId === recordId) {
                        return { ...avItem, dateOfSubmission: currentDate, isCompleted:false, Status__c : selectedStatus };
                    }
                    return avItem;
                });
            }
            //this.dateOfSubmission = new Date().toISOString();
        } else {
            if (avRecord) {
                const currentDate = null;
                this.avRecIdList = this.avRecIdList.map((avItem) => {
                    if (avItem.avId === recordId) {
                        return { ...avItem, dateOfSubmission: currentDate,isCompleted:false, Status__c : selectedStatus };
                    }
                    return avItem;
                });
            }
        }
    }
    vehicleId;
    handleUploadButtonClick(event) {
        this.uploadViewDocFlag = false;
        console.log('handleUploadButtonClick ',event.target.dataset.recordId);
        console.log('handleUploadButtonClick documentType '+this.documentType + 'sendingRecordTypeName '+this.sendingRecordTypeName);
        this.isModalOpen = true; 
        this.documentType = '';
        this.disabledFileUpload =false; 
        this.currentAVId = event.target.dataset.recordId;
        this.vehicleId = this.avRecIdList.find(avItem => avItem.avId === this.currentAVId)?.vehicleId;
        const subType = this.avRecIdList.find(avItem => avItem.avId === this.currentAVId)?.avVehicleSubType; //SFTRAC-1785
        this.filteredOptions = this.filterOptions(subType); //SFTRAC-1785
    }

    async createDocument(docType, recordType,currentAssetVerifiId,currentVehicleId) {
            await createDocumentRecord({ caseId: this.recordId, applicantId: this.applicantId, vehicleId: currentVehicleId, assetVerifiId: currentAssetVerifiId, loanApplicationId: this.loanApplicationId, documentType: docType, recordTypeName: recordType })
            .then((response) => {
                console.log('response ', response);
                this.documentId = response;    
                this.openUploadComp(recordType);//CISP-2975  
            })
            .catch((error) => {
                if (error.body.message) {
                    this.showErrorToast(error.body.message);
                } else {
                    this.showErrorToast('Something went wrong, Please contact System Administrator');
                }
                this.documentTypeDisabled = false;
            });
    }

    openUploadComp(recordType) {//CISP-2975
        console.log('gee');
        this.showUpload = true;
        this.showDocView = false;
        this.isVehicleDoc = true;
        this.isAllDocType = false;
        //this.sendingRecordTypeName = recordType;//CISP-2975
        this.uploadViewDocFlag = true;
        this.documentTypeDisabled = false;
    }

    documentTypeDisabled = false;
    handleChange( event ) {
        this.documentTypeDisabled = true;
        console.log('handleChange');
        this.documentType = '';
        let value = event.target.value;
        let label = event.target.label;
        console.log( label + ' – ' + value );
        this.documentType = event.target.value;
        console.log('handleChange documentType ',this.documentType);

         //this.createDocument(event.target.name, this.label.kycDocument);
         if(this.documentType == undefined || this.documentType == null){
            this.showErrorToast('Please select document type');
            this.documentTypeDisabled = false;
        }else{
            this.createDocument(this.documentType, this.sendingRecordTypeName, this.currentAVId, this.vehicleId);
        }
    }

    closeModal() {
        // to close modal set isModalOpen tarck value as false
        this.isModalOpen = false;
        console.log('!this.documentId ',!this.documentId);
        console.log('!this.documentId2 ',this.documentId);
        console.log('this.disabledFileUpload ',this.disabledFileUpload);
        if(this.documentId && this.disabledFileUpload == false){
            console.log('this.documentId ',this.documentId);
            deleteDocument({ documentId: this.documentId}).then(result => {
                console.log('Delete Document - Result:: ', result);
                this.init();
                }).catch(error => {
                    console.log('error ',error);
                //this.tryCatchError = error;
                //this.errorInCatch();
            });
        }
        this.uploadViewDocFlag = false;
        this.disabledFileUpload = false;
        
    }
    submitDetails() {
        // to close modal set isModalOpen tarck value as false
        //Add your code to call apex method or do some processing
        this.isModalOpen = false;
        this.disabledFileUpload = false;
        this.uploadViewDocFlag = false;
        if(this.isWebApp){this.closeModal();}else{this.init();}
        console.log('ibl://indusindbank.com/integratorInfo?leadId=' + this.loanApplicationId + '&userid=' + userId + '&mode=' + this.documentType + '&username=' + this.currentUserName + '&useremailid=' + this.currentUserEmailId + '&documentSide=Front&caseID=' + this.recordId);
    }

    showErrorToast(message) {
        const toastEvent = new ShowToastEvent({
            title: 'Error',
            message: message,
            variant: 'error',
        });
        this.dispatchEvent(toastEvent);
    }

    async changeflagvalue(event) {
        this.uploadViewDocFlag = false;
        if (event.detail && event.detail.contentDocumentId != null && event.detail.backcontentDocumentId != null) {
            const evt = new ShowToastEvent({
                title: "All uploaded!",
                variant: 'success',
            });
            this.dispatchEvent(evt);
        }
    }

    docDeleted() { 
        console.log('docDeleted');
        this.documentId = null; 
    }
   handleInitiateAV(event){ ////SFTRAC-99
        this.assetVerId = event.target.value;
        sendNotification({assetVerId : this.assetVerId}).then((response) => {
            console.log('response ', response);
            const evt = new ShowToastEvent({
                title: "Notification Sent",
                variant: 'success',
            });
            this.dispatchEvent(evt);
        })

    }
    async handleSubmit(event) {
        event.preventDefault();   
        let assetId = event.target.dataset.id;
        console.log('onsubmit event recordEditForm Record ID >>> '+ event.target.dataset.id);
        let statusValues = this.avRecIdList.map((avItem) => { if (avItem.avId === assetId ) {return avItem.Status__c; }});//SFTRAC-1431
        let documentUploadflag = this.avRecIdList.some(avItem =>  { 
            if(avItem.avId === assetId && avItem.isImplement == true){
                if (avItem.avId === assetId && avItem.serialNoUploaded && avItem.selfieWithVehImgUploaded && avItem.vehFrontImgUploaded && avItem.vehBackImgUploaded && avItem.vehRightImgUploaded && avItem.vehLeftImgUploaded) {
                    return true;
                }
            }else{
                if (avItem.avId === assetId && avItem.engineImgUploaded && avItem.chassisImgUploaded && avItem.selfieWithVehImgUploaded && avItem.vehFrontImgUploaded && avItem.vehBackImgUploaded && avItem.vehRightImgUploaded && avItem.vehLeftImgUploaded && avItem.hmrImgUploaded && avItem.chassisPlateImgUploaded) {
                    return true;
                }
            }
            return false; });
        if(documentUploadflag == true ){
            const currentDate = new Date().toISOString();
            this.avRecIdList = this.avRecIdList.map((avItem) => { if (avItem.avId === assetId && avItem.Status__c == 'Completed') { return { ...avItem, isCompleted:true, avStatus:true}; } return avItem;});
            this.template.querySelector(`[data-id="${assetId}"]`).submit();
        }else if (statusValues.includes('Completed') && documentUploadflag == false) {
            const evt = new ShowToastEvent({
                title: "Please upload all the mandatory documents",
                variant: 'error',
            });
            this.dispatchEvent(evt);
            this.avRecIdList = this.avRecIdList.map((avItem) => { if (avItem.avId === assetId) { return { ...avItem, Status__c:avItem.avStatusValue}; } return avItem;});//SFTRAC-1431
            statusValues = documentUploadflag = null; //SFTRAC-1431 
            return refreshApex(this.avRecIdList); //SFTRAC-1431  
        }else{
            this.template.querySelector(`[data-id="${assetId}"]`).submit();
        }
        statusValues = documentUploadflag = null;
    }

    handleSuccess(event) {
        console.log('handleSuccess event recordEditForm'+ event.detail.fields);
        const evt = new ShowToastEvent({
            title: "Record Saved Success",
            variant: 'success',
        });
        this.dispatchEvent(evt);
    }

    get acceptedFormats() {
        if ((FORM_FACTOR !== 'Large') && (this.doctype === 'Vehicle RC Copy' || this.doctype === 'Vehicle Image' || this.doctype === 'Vehicle Insurance Policy')) {
            return ['.pdf'];
        } else if(this.doctype === 'ITR-Forms' || this.doctype === 'Customer Bank Statement' || this.doctype ==='ITR-V' || this.doctype ==='Form26As'){
            return ['.pdf'];
        } else if((this.recordtypename != '' || this.recordtypename != null || this.recordtypename != undefined) && (this.recordtypename?.includes('KYC'))){//CISP-2975//CISP-3075
            return ['.jpg','.jpeg'];
        }//CISP-2975
        else {
            return ['.jpg', '.png', '.jpeg', '.docx', '.pdf'];
        }
    }
    disabledFileUpload = false;

    handleFileUpload(event) {
        this.uploadViewDocFlag = false;
        this.isModalOpen = false;
        this.contentDocumentId = event.detail.files[0].documentId;
        this.init();
        const evt = new ShowToastEvent({
            title: 'Uploaded',
            message: 'File Uploaded successfully..!',
            variant: 'success',
        });
        this.disabledFileUpload = true;
        this.dispatchEvent(evt);
        this.documentId = this.documentType = null;
    }
    
    isSpinnerMoving = false;
    previewDocument(event){
        this.isSpinnerMoving = true;
        let assetId = event.target.dataset.id;
        const buttonType = event.target.dataset.type;
        let documentName;
        if (buttonType === 'engine') {
            documentName = 'Engine Number uploaded during verification';
        }else if (buttonType === 'chassisNumber') {
            documentName = 'Chassis Number uploaded during verification';
        }else if (buttonType === 'selfiewithVeh') {
            documentName = 'Selfie with Vehicle-uploaded during verification';
        }else if (buttonType === 'vehFront') {
            documentName = 'Vehicle Front-uploaded during verification';
        }else if (buttonType === 'vehBack') {
            documentName = 'Vehicle Back-uploaded during verification';
        }else if (buttonType === 'chassisPlate') {
            documentName = 'Capture Chassis plate';
        }else if (buttonType === 'vehRight') {
            documentName = 'Capture Vehicle Right Side';
        }else if (buttonType === 'vehLeft') {
            documentName = 'Capture Vehicle Left Side';
        }else if (buttonType === 'hmrImg') {
            documentName = 'Capture HMR';
        }else if (buttonType === 'serialNo') {//SFTRAC-1785
            documentName = 'Capture Serial Number';
        }
        console.log('++++previewDocument documentName '+documentName +' assetId '+assetId);
        this.previewDocumentCall(assetId, documentName);
    }

    async previewDocumentCall(assetId, docName) {
        try {
            const contentDocumentId = await previewDocument({ assetId, docName });
            console.log('Content Version Id:', contentDocumentId);
            this.isSpinnerMoving = false;
            this[NavigationMixin.Navigate]({
                type: 'standard__namedPage',
                attributes: {
                    pageName: 'filePreview'
                },
                state: {
                    selectedRecordId: contentDocumentId
                }
            });
        } catch (error) {
            console.error('Error:', error);
        }
    }
}