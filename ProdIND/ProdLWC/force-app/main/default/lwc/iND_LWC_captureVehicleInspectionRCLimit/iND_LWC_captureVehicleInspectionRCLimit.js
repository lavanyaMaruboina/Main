import { LightningElement,api,wire,track } from 'lwc';

import { getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import getVehicleDetailsRecord from '@salesforce/apex/IND_VehicleInspectionRCLimitDetails.getVehicleDetailsRecord';
import getLoanAmountfromFO from '@salesforce/apex/IND_VehicleInspectionRCLimitDetails.getLoanAmountfromFO';
import getValidApplicants from '@salesforce/apex/IND_VehicleInspectionRCLimitDetails.getValidApplicants';
import getLoanApplicationDetails from '@salesforce/apex/IND_VehicleInspectionRCLimitDetails.getLoanApplicationDetails';
import getApplicantId from '@salesforce/apex/IND_VehicleInspectionRCLimitDetails.getApplicantId';
import doRCLimitCheckCallout from '@salesforce/apexContinuation/IntegrationEngine.doRCLimitCheckCallout';
import updateVehicleInspectionRCDetails from '@salesforce/apex/IND_VehicleInspectionRCLimitDetails.updateVehicleInspectionRCDetails';
import saveRCLimitResponseDetails from '@salesforce/apex/IND_VehicleInspectionRCLimitDetails.saveRCLimitResponseDetails';
import savecontinueWithRCLimitvalue from '@salesforce/apex/IND_VehicleInspectionRCLimitDetails.savecontinueWithRCLimitvalue';
import saveFinalButtonStatus from '@salesforce/apex/IND_VehicleInspectionRCLimitDetails.saveFinalButtonStatus';
import createDocumentForAdditionalDocument from '@salesforce/apex/IND_DocumentUploadCntrl.createDocumentForAdditionalDocument';
import retryCountIncrease from '@salesforce/apex/IND_VehicleInspectionRCLimitDetails.retryCountIncrease';
import updateTransactionRecord from '@salesforce/apex/IND_VehicleInspectionRCLimitDetails.updateTransactionRecord';
import VEHICLE_DETAIL_OBJECT from '@salesforce/schema/Vehicle_Detail__c';
import VEHICLE_LOCATION from '@salesforce/schema/Vehicle_Detail__c.Location_of_Vehicle_Inspection__c';
import getCaseId from '@salesforce/apex/IND_VehicleInspectionRCLimitDetails.getCaseId';
import checkIfReadOnly from '@salesforce/apex/IND_VehicleInspectionRCLimitDetails.checkIfReadOnly';
import Vehicle_Inspection_Error_Message from '@salesforce/label/c.Vehicle_Inspection_Error_Message';
import getDocumentData from '@salesforce/apex/IND_VehicleInspectionRCLimitDetails.getDocumentData';
import getDocumentDataTractor from '@salesforce/apex/IND_VehicleInspectionRCLimitDetails.getDocumentDataTractor';
import updateVehicleDetailsByCVO from '@salesforce/apex/IND_VehicleInspectionRCLimitDetails.updateVehicleDetailsByCVO';
import SystemModstamp from '@salesforce/schema/Account.SystemModstamp';

// Example :- import greeting from '@salesforce/label/c.greeting';'
export default class IND_LWC_captureVehicleInspectionRCLimit extends LightningElement {
    @api dealId = '';
    @track isTwVehicleType = false;//CISP-8762
    isCommunityUser;
    caseId; //SFTRAC-99
    isTractor; //SFTRAC-99
    vehicleInspectionByCVO;
    RCLimitApprovedByCVO;
    isCVORemarksNO = false;
    @api currentStep;
    isBEUserEnabled;
    disabledPostSantionButton ;
    disabledUploadBranchApproval;
    disabledPreDisField = false; 
    isvehicleInspectionApprovedbyCVOHandle;
    isRCLimitCorrectlyCaptured;
    isEnabledButtonOnPreDis = true;
    CVORemarksForRcLimitValue;
    CVORemarksFieldValue;
    isRCLimitCorrectlyCapturedValue;
    vehicleInspectionApprovedbyCVO;
    isStagePreDisbursement; 
    isStagePostSantion;
    activeSections = ['Vehicle Inspection', 'RC Limit Check' ];
    isLoading = false;
    actualSubmit = false;
    documentRecordId;
    docDataExist;
    docType;
    isAllDocType = false;
    showDocView;
    showUpload;
    showPhotoCopy;
    isVehicleDoc;
    uploadViewDocFlag;
    error;
    engineNumber;
    engineNumberCaptured;
    chassisNumber;
    chassisNumberCaptured;
    vehicleRegNumber;
    vehicleRegNumberCaptured;
    dealerName;
    locationOfVehicle;
    submitVehicleInspectionbutton = false;
    @api
    disableSubmitVehicleInspectionButton = false;
    vehicleLocationPickList;
    validloanAmountfromFOPage;
    validApplicants;
    validVehicleType;
    noOfProposalsAvailable;
    availableDisbursalAmount;
    noOfDaysRCPending;
    financeAmount;
    continueWithRCLimit = false;
    loanApplnStage;
    disablevehicleInspectionApproved = true;
    disableremarksField = false;
    disableCVORemarks = true;
    loanApplnSubStage;
    loadComponent;
    uploadScreen;
    isLoading = false;
    @track disableRCLimitCheckButton = true;
    submitVehicleInspectionRCLimitbutton = false;
    disableFinalSubmitButton = true; 
    documentRecordList;
    applicantId; //a0U71000000ECKfEAO
    //recordId1='00671000001Kmj3AAC';
    @api recordId //= '00671000001Kmj3AAC';
    vehicleRecordId //= 'a0Y710000003vWPEAY';
    uploadVehicleDocument = false;
    ContentDocumentId;
    docTypeWithIdList = [];
    docTypeWithIdList1 = [];
    vehicleDocumentAfterUpload = [];
    vehicleDocumentEngineChassis = [];
    isUploadedEngineNumber = false;
    @track isReadOnly;
    isView;
    vehicleInspectionErrorMessage = Vehicle_Inspection_Error_Message;
    @track vehicleInspectionapprovalLabel ='Vehicle inspection approved by CVO';
    @track remarkLabel = 'CVO remarks';
    isVehicleDelivered =false;
    docTypeNameList = ['Selfie with Vehicle-uploaded during verification','Vehicle Front-uploaded during verification','Vehicle Back-uploaded during verification']
    isVehicleDelivered =false;
    vehSubcategory;
    //Added By Poonam for dynamic take picklist values from Vehicle object 
    @wire(getObjectInfo, { objectApiName: VEHICLE_DETAIL_OBJECT })
        vehicleData;

        @wire(getPicklistValues,
            {
                recordTypeId: '$vehicleData.data.defaultRecordTypeId', 
                fieldApiName: VEHICLE_LOCATION
            }
        )
        vehicleLocation;

       
        get isRCLimitSectionEnable(){
            if(this.isTractor && (this.vehSubcategory === 'UPD' || this.vehSubcategory === 'UPO') ){
                this.isTwVehicleType = true;
                return true;
            }else{
                return this.isTwVehicleType;
            }
        }
        async init() {
            this.isLoading = true;
            this.disabledPreDisField = true;
            console.log('currentStep in vehicle : ',this.currentStep);
           
            try {
               
                await checkIfReadOnly({ lAId: this.recordId, dealId: this.dealId })
                .then(result => {
                    console.log('Result checkIfReadOnly', result);
                    this.disabledPostSantionButton = result;
                    this.disabledUploadBranchApproval = result;
                    this.isStagePostSantion = true;
                })
                .catch(error => {
                    console.error('Error:', error);
                });
                await getCaseId({loanApplicationId: this.recordId}) //SFTRAC-99
                .then(data => {
                    if(data!=null){
                    this.caseId = data;
                }
            });
               await getLoanApplicationDetails({ loanApplicationId: this.recordId })
                .then(result => {
                    if(result!=null){
                        result = JSON.parse(result);
                        console.log('result getLoanApplicationDetails--',result);
                        this.isBEUserEnabled = result.isOwnerSame;
                        this.isCommunityUser = result.isCommunityUser;
                        this.vehicleType = result.loanApplication.Vehicle_Type__c;
                        this.loanApplnStage = result.loanApplication.StageName;
                        this.loanApplnSubStage = result.loanApplication.Sub_Stage__c;
                        if((result.loanApplication.Product_Type__c != 'Passenger Vehicles' && result.loanApplication.Product_Type__c != 'Tractor') || (result.loanApplication.Product_Type__c == 'Passenger Vehicles' && this.vehicleType == 'New') || (result.loanApplication.LeadSource == 'OLA' || result.loanApplication.LeadSource == 'D2C')){//CISP-8762
                            this.isTwVehicleType = true;
                           // if()
                            console.log('isTwVehicleType 1==>',this.isTwVehicleType );
                            
                        }
                                                    console.log('isTwVehicleType 2==>',this.isTwVehicleType );
                        if(result.loanApplication.Product_Type__c == 'Tractor'){ //SFTRAC-99
                            this.isTractor = true;
                            this.vehicleInspectionapprovalLabel = 'Vehicle inspection approved by PE';
                            this.remarkLabel = 'PE remarks';
                        }
                        if(result.loanApplication.Finance_Amount__c == null){
                            this.financeAmount = 0;
                        }else{
                            this.financeAmount = Number(result.loanApplication.Finance_Amount__c);
                        }
                        console.log('financeAmount ::' + this.financeAmount);
                        if(this.vehicleType == 'Used' || this.vehicleType == 'Refinance' || this.vehicleType == 'External Refinance' || this.vehicleType == 'Internal Refinance'){
                            this.validVehicleType = true;
                        }
                        if(this.loanApplnStage == 'Disbursement Request Preparation'  && this.currentStep == 'post-sanction'){
                            this.disabledPreDisField = true;
                        }
                        else if(this.loanApplnStage == 'Disbursement Request Preparation'  && this.currentStep == 'pre-disbursement'){
                            console.log('Vehicle inspection when stage is disbursment and step is pre dis sanction  : ',);
                            this.isStagePreDisbursement = true
                            this.isStagePostSantion = false; 
                            this.disabledPreDisField = true;
                            this.disabledPostSantionButton = true;
                            this.disabledUploadBranchApproval = true;
                        }
                        if(this.loanApplnStage == 'Pre Disbursement Check' && this.currentStep != 'post-sanction'){
                            console.log('in pre dis vehicle : ',);
                            this.isStagePreDisbursement = true
                            this.isStagePostSantion = false; 
                            this.disabledPreDisField = false;
                            this.disabledPostSantionButton = true;
                            this.disabledUploadBranchApproval = true;
                            
                        }else if(this.loanApplnStage == 'Pre Disbursement Check' && this.currentStep == 'post-sanction'){
                            console.log('in post dis vehicle when stage is pre dis : ',);
                            this.isStagePreDisbursement = false;
                            this.isStagePostSantion = true;
                            this.disabledPreDisField = true;
                        }
                    }
                });
                await getLoanAmountfromFO({ loanApplicationId: this.recordId, dealId: this.dealId })
                .then(result => {
                    console.log('Inside getLoanAmountfromFO function in connectedcallback',result);
                    if(result!=null){
                        this.validloanAmountfromFOPage = result;
                    }
                })
                .catch(error => {
                    //this.error = error;
                    console.log('Error in getLoanAmountfromFO connectedCallback Function ::', error);
                });

                await  getValidApplicants({ loanApplicationId: this.recordId })
                .then(result => {
                    console.log('Inside getValidApplicants function in connectedcallback',result);
                    if(result!=null){
                        this.validApplicants = result;
                    }
                })
                .catch(error => {
                    //this.error = error;
                    console.log('Error in getValidApplicants connectedCallback Function ::'+ error);
                })
                
            } catch (error) {
                console.log('error : ',error);
            } finally {
                //this.isLoaded = true;
            }
            console.log('validloanAmountfromFOPage : ',this.validloanAmountfromFOPage);
            console.log('validApplicants : ',this.validApplicants);
            console.log('validVehicleType : ',this.validVehicleType);
            
        /*if((this.validloanAmountfromFOPage && this.validApplicants && this.validVehicleType) || this.isTractor){ //SFTRAC-99
            this.loadComponent = true;
            this.isLoading = false;
        }else{
            this.loadComponent = false;
            this.isLoading = false;
            this.updateLATransaction();
        } */

        await getApplicantId({ loanApplicationId: this.recordId })
        .then(result => {
            console.log('Inside getApplicantId function in connectedcallback');
            if(result!=null){
                this.applicantId = result;
                console.log('applicantId :::' + this.applicantId);
            }
        })
        .catch(error => {
            this.error = error;
            console.log('Error in getApplicantId connectedCallback Function ::'+ this.error);
        })
        await getVehicleDetailsRecord({ loanApplicationId: this.recordId, dealId: this.dealId })
        .then(result=>{
            if(result!=null){
                console.log('Inside getVehicleDetailsRecord function in connectedcallback');
                console.log('result--',result);
                this.engineNumberCaptured = result.Engine_number__c;
                this.vehSubcategory = result.Vehicle_SubCategory__c; //
                this.engineNumber = result.Engine_Number_during_Inspection__c;
                console.log('engineNumberCaptured ::' + this.engineNumberCaptured);
                this.chassisNumberCaptured = result.Chassis_number__c;
                console.log('chassisNumberCaptured ::' + this.chassisNumberCaptured);
                this.chassisNumber = result.Chassis_Number_during_Inspection__c;
                this.vehicleRegNumberCaptured = result.Vehicle_Registration_number__c;
                this.vehicleRegNumber = result.Vehicle_Reg_No_during_Inspection__c;
                this.locationOfVehicle = result.Location_of_Vehicle_Inspection__c;
                this.remarksvalue = result.Remarks__c;
                this.CVORemarksFieldValue = result.CVO_remarks__c;
                this.CVORemarksForRcLimitValue = result.CVO_Remarks_for_RC_Limit__c;
                console.log('vehicleRegNumberCaptured ::' + this.vehicleRegNumberCaptured);
                this.dealerName = result.Dealer_Sub_dealer_name__c;
                console.log('dealerName ::' + this.dealerName);
                this.vehicleRecordId = result.Id;
                this.vehicleInspectionByCVO = result.Vehicle_inspection_approved_by_CVO__c;
                this.RCLimitApprovedByCVO =  result.Is_RC_Limit_Check_correctly_captured__c;
                this.continueWithRCLimit = result.Can_we_continue_with_above_RC_limit__c;
                if(this.loanApplnStage == 'Post Sanction Checks and Documentation'){
                    if(this.vehicleInspectionByCVO == 'No' && this.RCLimitApprovedByCVO == 'No'){
                        console.log('if both cvo remarks are NO')
                        this.disabledPostSantionButton = false;
                        this.disabledUploadBranchApproval = false;
                        this.isStagePostSantion = true;
                    }else if(this.vehicleInspectionByCVO == 'No'){
                        console.log('if vehicleInspectionByCVO are NO');
                        this.disabledPostSantionButton = false;
                        this.disabledUploadBranchApproval = true;
                        this.isStagePostSantion = true;
                        this.continueWithRCLimit = true;
                    }else if(this.RCLimitApprovedByCVO == 'No'){
                        console.log('if CVORemarksForRcLimitValue are NO');
                        this.disabledPostSantionButton = true;
                        this.disabledUploadBranchApproval = false;
                        this.isStagePostSantion = true;
                        this.submitVehicleInspectionbutton = true;
                        this.disableRCLimitCheckButton = false;
                    }
                }
                if(result.Vehicle_Delivered__c == 'Yes' || result.Vehicle_Delivered__c == 'yes'){ 
                    this.isVehicleDelivered = true;
                    }
                //console.log('vehicleRecordId ::' + vehicleRecordId);
            }
        })
        .catch(error => {
            this.error = error;
            console.log('Error in getVehicleDetailsRecord connectedCallback Function ::'+ error);
        })
        await getDocumentData({ loanApplicationId: this.recordId ,vehicleRecordId : this.vehicleRecordId })
          .then(result => {
            this.documentRecordList = result;
            console.log('Result getDocumentData', this.documentRecordList);  
            if(this.documentRecordList){
            this.documentRecordList.forEach(currentItem => {
                console.log('currentItem.Document_Type__c : ',currentItem.Document_Type__c);
                if(this.docTypeNameList.includes(currentItem.Document_Type__c)){
                this.vehicleDocumentAfterUpload.push(currentItem);
                }
                if(currentItem.Document_Type__c == 'Chassis Number uploaded during verification' || currentItem.Document_Type__c == 'Engine Number uploaded during verification' ){
                    console.log('currentItem.Document_Type__c : ',currentItem.Document_Type__c);
                    this.vehicleDocumentEngineChassis.push(currentItem.Document_Type__c);
                }
            });
            }
           console.log('this.vehicleDocumentAfterUpload : ',this.vehicleDocumentAfterUpload);
           console.log('this.vehicleDocumentEngineChassis : ',this.vehicleDocumentEngineChassis);
          })
        
          .catch(error => {
            console.error('Error:', error);
        });
        if((this.validloanAmountfromFOPage && this.validApplicants && this.validVehicleType) || this.isTractor){ //SFTRAC-99
            this.loadComponent = true;
            this.isLoading = false;
        }else{
            this.loadComponent = false;
            this.isLoading = false;
            this.updateLATransaction();
        }
        if((this.isTractor && this.vehicleType == 'New' && !this.isVehicleDelivered)){
            this.loadComponent = false;
            this.updateLATransaction();
        }
        }
        updateLATransaction(){
            console.log('OUTPUT updateLATransaction: ',);
            updateTransactionRecord({ loanApplicationId: this.recordId, dealId: this.dealId })
              .then(result => {
                console.log('Result updateLATransaction', result);
              })
              .catch(error => {
                console.error('Error:', error);
            });
        }
    async connectedCallback() {
        await this.init();
        if(!this.isTractor){
            this.disableSubmitVehicleInspectionButton  = true;
        }
        console.log('Inside IND_LWC_captureVehicleInspectionRCLimit connectedCallback',this.disableSubmitVehicleInspectionButton);   
          

        if(this.isRevokedLoanApplication){this.disableEverything();}//CISP-2735
    }
    renderedCallback(){
      if(this.isRevokedLoanApplication){this.disableEverything();}//CISP-2735
    }
    disableEverything(){
        let allElements = this.template.querySelectorAll('*');
        allElements.forEach(element =>
            element.disabled = true
        );
    }
    @api isRevokedLoanApplication;//CISP-2735
    //CISP-2735-END

  

    handleInputFieldChange(event) {
        const fieldName = event.target.name;
        console.log('On Change Handler Executed for :: ' + fieldName);
        this.submitVehicleInspectionbutton = false;
        this.disableSubmitVehicleInspectionButton = false;
        console.log('submitVehicleInspectionbutton ::' + this.submitVehicleInspectionbutton);
        if (fieldName == 'engineNumberField') {
            this.engineNumber = event.target.value;
            console.log('engineNumber ::'+ this.engineNumber);
        } else if (fieldName == 'chassisNumberField') {
            this.chassisNumber = event.target.value;
            console.log('chassisNumber ::'+ this.chassisNumber);
        } else if (fieldName == 'VehicleRegNumberField') {
            this.vehicleRegNumber = event.target.value;
            console.log('vehicleRegNumber ::'+ this.vehicleRegNumber);
        } else if (fieldName == 'remarksField'){
            this.remarksvalue = event.target.value;
            console.log('remarksvalue ::'+ this.remarksvalue);
        }
    }

    handlevehiclelocationChange(event){
        this.submitVehicleInspectionbutton = false;
        this.disableSubmitVehicleInspectionButton = false;
        this.locationOfVehicle = event.target.value;
        console.log('Location of Vehicle Inspection ::', this.locationOfVehicle);
    }

    handleCaptureEngineNumber(event) {
        this.showUpload = true;
        this.showPhotoCopy = false;
        this.showDocView = true;
        this.isVehicleDoc = true;
        //this.isAllDocType = true;
        this.docType = 'Engine Number uploaded during Verification';
        this.uploadViewDocFlag = true;
        this.disableSubmitVehicleInspectionButton = false;
        this.submitVehicleInspectionbutton = false;
    }

    handleCaptureChassisNumber(event){
        this.showUpload = true;
        this.showPhotoCopy = false;
        this.showDocView = true;
        this.isVehicleDoc = true;
        //this.isAllDocType = true;
        this.docType = 'Chassis Number uploaded during verification';
        this.uploadViewDocFlag = true;
        this.disableSubmitVehicleInspectionButton = false;
        this.submitVehicleInspectionbutton = false;
    }

    handleSelfiewithVehicle(event){
        this.showUpload = true;
        this.showPhotoCopy = false;
        this.showDocView = true;
        this.isVehicleDoc = true;
        //this.isAllDocType = true;
        this.docType = 'Selfie with Vehicle-uploaded during verification';
        this.uploadViewDocFlag = true;
        this.disableSubmitVehicleInspectionButton = false;
        this.submitVehicleInspectionbutton = false;
    }

    handleCaptureVehicleFront(event){
        this.showUpload = true;
        this.showPhotoCopy = false;
        this.showDocView = true;
        this.isVehicleDoc = true;
        //this.isAllDocType = true;
        this.docType = 'Vehicle Front-uploaded during verification';
        this.uploadViewDocFlag = true;
        this.disableSubmitVehicleInspectionButton = false;
        this.submitVehicleInspectionbutton = false;
    }

    handleCaptureVehicleBack(event){
        this.showUpload = true;
        this.showPhotoCopy = false;
        this.showDocView = true;
        this.isVehicleDoc = true;
        //this.isAllDocType = true;
        this.docType = 'Vehicle Back-uploaded during verification';
        this.uploadViewDocFlag = true;
        this.disableSubmitVehicleInspectionButton = false;
        this.submitVehicleInspectionbutton = false;
    }

    handleUploadBranchInchargeApproval(event){
        this.showUpload = true;
        this.showPhotoCopy = false;
        this.showDocView = true;
        this.isVehicleDoc = true;
        //this.isAllDocType = true;
        this.docType = 'Branch In-charge Approval Email';
        this.uploadViewDocFlag = true;
        this.disableSubmitVehicleInspectionButton = false;
        this.submitVehicleInspectionbutton = false;
    }


    changeFlagValue() {
        console.log('changeflagvalue : ',);
       // this.uploadViewDocFlag = false;
        this.uploadVehicleDocument = false;
    }
    //Added by Poonam to upload document using generic lwc component

    docUploadSuccessfully(event){
        console.log('OUTPUT docUploadSuccessfully: ',);
        this.ContentDocumentId = event.detail;
        if(this.docType == 'Selfie with Vehicle-uploaded during verification' || this.docType == 'Vehicle Front-uploaded during verification' || this.docType == 'Vehicle Back-uploaded during verification'){
            console.log('in if ______ : ',this.docType);    
            this.docTypeWithIdList.push(this.docType);
        }
        if(this.docType == 'Engine Number uploaded during Verification' || this.docType == 'Chassis Number uploaded during verification'){
            console.log('in if ***** : ',this.docType);    
            this.docTypeWithIdList1.push(this.docType);
        }
        console.log('this.ContentDocumentId ---- : ',this.ContentDocumentId);
        console.log('this.docTypeWithIdList : ',this.docTypeWithIdList);
       console.log('this.docTypeWithIdList1 : ',this.docTypeWithIdList1);
    } 
    handleViewDocument(event){
        console.log('handleViewDocument : ',);
        this.docType = event.target.value;
        console.log('handleViewDocument : ',this.docType);
        let documentId = this.documentRecordList.filter(item => {
            if(item.Document_Type__c.toUpperCase() === this.docType.toUpperCase())
            return item;
        });
        console.log('documentId : ',documentId);
        if(documentId.length>0){
            console.log('OUTPUT : ',documentId[0].Id);
            this.isView = false;
            this.uploadViewDocFlag = true;
            this.showUpload = false;
            this.showPhotoCopy = false;
            this.showDocView = true;
            this.isVehicleDoc = true;
            this.isAllDocType = false;
            this.documentRecordId = documentId[0].Id;
        }else{
            console.log('in else part ---- : ',);
            const evt = new ShowToastEvent({
                title: 'Document not found',
                message: 'This type of document not uploded yet.',
                variant: 'info',
            });
            this.dispatchEvent(evt);
        }
    }
    changeflagvalueForViewDoc(){
        this.uploadViewDocFlag = false;
    }
    handleUploadDocument(event){
        console.log('handleUploadDocument : ',);
        if(event.target.value != 'Branch In-charge Approval Email')
            this.disableSubmitVehicleInspectionButton = false;
        this.docType = event.target.value;
        console.log('OUTPUT this.docType: ',this.docType);
        createDocumentForAdditionalDocument({docType:this.docType,vehicleDetailId: this.vehicleRecordId,applicantId:this.applicantId,loanApplicationId: this.recordId,
         })
          .then(result => {
            console.log('Result', result);
            this.uploadVehicleDocument = true;
            this.documentRecordId = result;
            this.showUpload = true;
            this.showPhotoCopy = false;
            this.showDocView = true;
            this.isVehicleDoc = true;
            this.isAllDocType = false;
            this.uploadViewDocFlag = false;
          })
          .catch(error => {
            console.error('Error:', error);
        });
        
       console.log('OUTPUT : ',this.uploadChequeDocFlag);
    }

    isTrue(docTypeNameList, docTypeWithIdList){
        return docTypeNameList.every(i => docTypeWithIdList.includes(i));
      }
    @api handleSubmitVehicleInspectionFromParent(){
        this.updateSubmitVehicleInspection(false);
    }
    async handleSubmitVehicleInspection(){
        if(this.isTractor){
            let result = await getDocumentDataTractor({ loanApplicationId: this.recordId ,vehicleRecordId : this.vehicleRecordId });
            if(!result){
                const evt = new ShowToastEvent({
                    title: 'Warning',
                    message: this.vehicleInspectionErrorMessage,
                    variant: 'warning',
                });
                this.dispatchEvent(evt);
                return;
            }else{
                //this.updateSubmitVehicleInspection(true);
                this.saveFinalButton();
            }
        }else{
            this.updateSubmitVehicleInspection(true);
        }
    }
    updateSubmitVehicleInspection(subFlag){
        console.log('Method called');
        let isAllFileUploaded = this.isTrue(this.docTypeNameList,this.docTypeWithIdList);
      // isAllFileUploaded = true;
       let isSuccess = false;
        console.log('isAllFileUploaded *****: ',isAllFileUploaded);
       if(isAllFileUploaded == true || this.vehicleDocumentAfterUpload.length == 3){
        console.log('Inside handleSubmitVehicleInspection method' );
        console.log('this.engineNumberCaptured ==  undefined : ',this.engineNumberCaptured);
        console.log('OUTPUT : ',this.docTypeWithIdList1.includes('Engine Number uploaded during Verification'));
        console.log('OUTPUT : ',);
        if((this.engineNumber==this.engineNumberCaptured) && (this.chassisNumber==this.chassisNumberCaptured) && (this.vehicleRegNumber==this.vehicleRegNumberCaptured) && (this.locationOfVehicle != null || this.locationOfVehicle != undefined) && (this.chassisNumberCaptured != undefined) && this.engineNumberCaptured != undefined){
            console.log('Inside matched condition or if condition in handleSubmitVehicleInspection method' );
            this.submitVehicleInspectionbutton = true;
            this.disableSubmitVehicleInspectionButton = true;
            if(this.vehicleInspectionByCVO == 'No' && this.RCLimitApprovedByCVO != 'No'){
                this.disableRCLimitCheckButton = true;
            }else
                this.disableRCLimitCheckButton = false;
            var vehicleInspectionDetails = {
                'engineNumber': this.engineNumber,
                'chassisNumber': this.chassisNumber,
                'vehicleRegNumber': this.vehicleRegNumber,
                'locationOfVehicle': this.locationOfVehicle,
                'remarks': this.remarksvalue,
            }
            updateVehicleInspectionRCDetails({loanApplicationId : this.recordId, vehicleRecordId : this.vehicleRecordId, vehicleInspectionDetails : JSON.stringify(vehicleInspectionDetails), dealId: this.dealId})
                .then(result => {
                   //this.submitVehicleInspectionbutton = false;
                    console.log('result ::' + result);
                    const evt = new ShowToastEvent({
                        title: 'Submitted',
                        message: 'Vehicle Inspection done successfully!',
                        variant: 'success',
                    });
                    this.dispatchEvent(evt);
                    if(!this.isTwVehicleType){this.saveFinalButton();}//CISP-8762
                })
                .catch(error => {
                    this.error = error;
                    console.log('Error in handleSubmitVehicleInspection->updateVehicleRecordDetails Function ::', error);
                    const evt = new ShowToastEvent({
                        title: 'Error',
                        message: error,
                        variant: 'error',
                    });
                    this.dispatchEvent(evt);
                })
                isSuccess = true;    
            
            if(this.submitVehicleInspectionbutton && this.continueWithRCLimit || (this.isTractor)){
                this.submitVehicleInspectionRCLimitbutton = false;
                this.disableFinalSubmitButton = false;
            }
        }
        else if (!((this.engineNumber==this.engineNumberCaptured) && (this.chassisNumber==this.chassisNumberCaptured) && (this.vehicleRegNumber==this.vehicleRegNumberCaptured)) && this.engineNumberCaptured != undefined && this.chassisNumberCaptured != undefined){
            console.log('Inside not matched condition or else condition in handleSubmitVehicleInspection method' );
            this.submitVehicleInspectionbutton = false;
            this.disableRCLimitCheckButton = true;
            this.disableSubmitVehicleInspectionButton = false;
            const evt = new ShowToastEvent({
                title: 'Error',
                message: 'Vehicle Registration Number OR Engine number OR Chassis number do not match with information captured earlier.',
                variant: 'error',
            });
            this.dispatchEvent(evt);
        }else if ((this.locationOfVehicle == null || this.locationOfVehicle == undefined)){
            this.submitVehicleInspectionbutton = false;
            this.disableSubmitVehicleInspectionButton = false;
            const evt = new ShowToastEvent({
                title: 'Error',
                message: 'Please select a value for Location of Vehicle Inspection before submission.',
                variant: 'error',
            });
            this.dispatchEvent(evt);

        }else if((this.engineNumberCaptured == '' || this.engineNumberCaptured == undefined) && (!(this.docTypeWithIdList1.includes('Engine Number uploaded during Verification') || this.vehicleDocumentEngineChassis.includes('Engine Number uploaded during verification')))){
           console.log('this.docTypeWithIdList1.includes : ',this.docTypeWithIdList1.includes('Engine Number uploaded during Verification'));
           console.log('this.vehicleDocumentEngineChassis : ',this.vehicleDocumentEngineChassis.includes('Engine Number uploaded during verification'));
            console.log('OUTPUT : ',(!(this.docTypeWithIdList1.includes('Engine Number uploaded during Verification') || this.vehicleDocumentEngineChassis.includes('Engine Number uploaded during verification'))));
            console.log('when engine number empty : ',);
            const evt = new ShowToastEvent({
                title: 'Error',
                message: 'Please Upload Engine Number',
                variant: 'error',
            });
            this.dispatchEvent(evt);
        }
        else if((this.chassisNumberCaptured == '' || this.chassisNumberCaptured == undefined) && (!(this.docTypeWithIdList1.includes('Chassis Number uploaded during verification') || this.vehicleDocumentEngineChassis.includes('Chassis Number uploaded during verification')))){
            console.log('when chassis number empty : ',);
            const evt = new ShowToastEvent({
                title: 'Error',
                message: 'Please Upload Chassis Number',
                variant: 'error',
            });
            this.dispatchEvent(evt);
        }else if(this.engineNumberCaptured ==  undefined && (this.docTypeWithIdList1.includes('Engine Number uploaded during Verification') || this.vehicleDocumentEngineChassis.includes('Engine Number uploaded during verification'))){
            console.log('when engine number empty---')
            isSuccess = this.updateInspectionData();
        }
        else if(this.chassisNumberCaptured ==  undefined && (this.docTypeWithIdList1.includes('Chassis Number uploaded during verification') || this.vehicleDocumentEngineChassis.includes('Chassis Number uploaded during verification'))){
            console.log('when chassis number empty---')
            isSuccess = this.updateInspectionData();
        }
    }else{
        const evt = new ShowToastEvent({
            title: 'Error',
            message: this.vehicleInspectionErrorMessage,
            variant: 'error',
        });
        this.dispatchEvent(evt);
    }
    // Creates the event with the data.
    if(subFlag == false){
    const actionResultEvent = new CustomEvent("submitresultaction", {
        detail: {isSuccess: isSuccess}
      });
  
      // Dispatches the event.
      this.dispatchEvent(actionResultEvent);
    }
    }
    updateInspectionData(){
        this.submitVehicleInspectionbutton = true;
        this.disableSubmitVehicleInspectionButton = true;
        if(this.vehicleInspectionByCVO == 'No' && this.RCLimitApprovedByCVO != 'No'){
            this.disableRCLimitCheckButton = true;
        }else
            this.disableRCLimitCheckButton = false;
        let isSuccess = false;
    console.log('inside in this block  : ',);
            var vehicleInspectionDetails = {
                'engineNumber': this.engineNumber,
                'chassisNumber': this.chassisNumber,
                'vehicleRegNumber': this.vehicleRegNumber,
                'locationOfVehicle': this.locationOfVehicle,
                'remarks': this.remarksvalue,
            }
            updateVehicleInspectionRCDetails({loanApplicationId : this.recordId, vehicleRecordId : this.vehicleRecordId, vehicleInspectionDetails : JSON.stringify(vehicleInspectionDetails), dealId: this.dealId})
                .then(result => {
                   //this.submitVehicleInspectionbutton = false;
                    console.log('result ::' + result);
                    isSuccess = true;
                    const evt = new ShowToastEvent({
                        title: 'Submitted',
                        message: 'Vehicle Inspection done successfully!',
                        variant: 'success',
                    });
                    this.dispatchEvent(evt);
                    if(!this.isTwVehicleType){this.saveFinalButton();}//CISP-8762
                })
                .catch(error => {
                    this.error = error;
                    console.log('Error in handleSubmitVehicleInspection->updateVehicleRecordDetails Function ::', error);
                    const evt = new ShowToastEvent({
                        title: 'Error',
                        message: error,
                        variant: 'error',
                    });
                    this.dispatchEvent(evt);
                })
            
            if(this.submitVehicleInspectionbutton && this.continueWithRCLimit || (this.isTractor)){
                this.submitVehicleInspectionRCLimitbutton = false;
                this.disableFinalSubmitButton = false;
            }
            return isSuccess;
        }
    oncheckRCLimitButton(event){
        //eval("$A.get('event.force:refreshView').fire();");
        console.log('Inside oncheckRCLimitButton function in LWC' );
        this.disableRCLimitCheckButton = true;
        this.isLoading = true;
        doRCLimitCheckCallout({applicantId: this.applicantId, loanAppId : this.recordId, dealId: this.dealId})
             .then(result => {
                // const event = new ShowToastEvent({
                //     title: 'Success',
                //     message: 'Received a response',
                //     variant: 'success',
                // });
                console.log('In Then Promise');
                this.disableRCLimitCheckButton = false;
                this.isLoading = false;
                // this.dispatchEvent(event);
                 if(result!=null){
                    console.log('Result in RCLimitCheck API ::' + JSON.stringify(JSON.parse(result)));
                    const obj = JSON.parse(result);
                    console.log('objobj : ',obj);
                    //responseExpected ='{"response":{"status":"SUCCESS","respDesc":"Check RC Limit","content":[{"No_Of_Proposals_Available":"1","Available_Disbursal_Amount":"10000.00","Pending_Flag":"Y","Payment_To_DSA_Flag":"N"}]}}';
                    if(obj.response.status == 'SUCCESS'){
                        saveRCLimitResponseDetails({loanApplicationId : this.recordId, vehicleRecordId : this.vehicleRecordId, response : JSON.stringify(obj.response.content[0])})
                            .then(result => {
                                console.log('Result in saveRCLimitResponseDetails Function ::' , result);
                            })
                            .catch(error => {
                                this.error = error;
                                console.log('Error in saveRCLimitResponseDetails Function ::', error);
                            })
                        const event = new ShowToastEvent({
                            title: 'Success',
                            message: 'Received successful response',
                            variant: 'success',
                        });
                        this.dispatchEvent(event);
                        this.noOfProposalsAvailable = obj.response.content[0].No_Of_Proposals_Available;
                        this.availableDisbursalAmount = obj.response.content[0].Available_Disbursal_Amount;
                        console.log('No of proposals available ::' + this.noOfProposalsAvailable);
                        console.log('Available Disbursal Amount ::' + this.availableDisbursalAmount);
                        if(obj.response.content[0].Pending_Flag == 'Y'){
                            this.noOfDaysRCPending = true;
                        }else{
                            this.noOfDaysRCPending = false;
                        }
                        console.log('this.noOfProposalsAvailable >=1 ::' + (this.noOfProposalsAvailable >=1));
                        console.log('this.availableDisbursalAmount >= this.financeAmount ::' + (this.availableDisbursalAmount >= this.financeAmount));
                        console.log('this.noOfDaysRCPending == true ::' + (this.noOfDaysRCPending == true));
                        if((this.noOfProposalsAvailable >=1) && (this.availableDisbursalAmount >= this.financeAmount) && (this.noOfDaysRCPending == true)){
                            this.continueWithRCLimit = true;
                        }else{
                            this.continueWithRCLimit = false;
                        }
                        //this.continueWithRCLimit = true;
                        console.log('this.continueWithRCLimit ::' + this.continueWithRCLimit);
                        savecontinueWithRCLimitvalue({loanApplicationId : this.recordId, vehicleRecordId : this.vehicleRecordId, continueWithRCLimit : this.continueWithRCLimit})
                            .then(result => {
                                console.log('Result in savecontinueWithRCLimitvalue Function ::' + result);
                            })
                            .catch(error => {
                                this.error = error;
                                console.log('Error in savecontinueWithRCLimitvalue Function ::'+ error.message);
                            })
                            
                        if(this.submitVehicleInspectionbutton == true && this.continueWithRCLimit == true || (this.isTractor)){
                            this.disableFinalSubmitButton = false;
                        }
                        this.retryCount();
                        }
                    else{
                       this.retryCount();
                        const event = new ShowToastEvent({
                            title: 'Error',
                            message: 'Received some error in response.Please Check and try again.',
                            variant: 'error',
                        });
                        this.dispatchEvent(event);
                    }
                 }

             })
             .catch(error => {
                this.disableRCLimitCheckButton = false;
                this.isLoading = false;
                 console.log('error in do rc limit callout => ' , error );
                 const event = new ShowToastEvent({
                    title: 'Error',
                    message: error.body.message,
                    variant: 'error',
                });
                this.dispatchEvent(event);
             })
    }
    retryCount(){
        retryCountIncrease({ loanApplicationId: this.recordId })
        .then(result => {
          console.log('Result', result);
        })
        .catch(error => {
          console.error('Error:', error);
      });
    }
    async onFinalSubmitButton(event){
        
        if(this.submitVehicleInspectionbutton == true && (this.continueWithRCLimit == true || this.isTractor)){
            if(this.isTractor){
                let result = await getDocumentDataTractor({ loanApplicationId: this.recordId ,vehicleRecordId : this.vehicleRecordId });
                if(!result){
                    const evt = new ShowToastEvent({
                        title: 'Warning',
                        message: this.vehicleInspectionErrorMessage,
                        variant: 'warning',
                    });
                    this.dispatchEvent(evt);
                    return;
                }
            }
            this.submitVehicleInspectionRCLimitbutton = true;
            this.disableFinalSubmitButton = true;
            this.saveFinalButton();
        }
    }//CISP-8762 changes
    saveFinalButton(){
        this.submitVehicleInspectionRCLimitbutton = true;
        let msg = '';
        if(this.isTwVehicleType){
            msg = 'Vehicle Inspection and RC Limit Check done successfully.';
        }else{
            msg = 'Vehicle Inspection done successfully.'
        }
        saveFinalButtonStatus({loanApplicationId : this.recordId, vehicleRecordId : this.vehicleRecordId, finalButtonStatus : this.submitVehicleInspectionRCLimitbutton, dealId: this.dealId})
        .then(result => {
            console.log('Result in saveFinalButtonStatus Function ::' + result);
            //this.isReadOnly = true;
            const event = new ShowToastEvent({
                title: 'Success',
                message: msg,
                variant: 'success',
            });
            this.dispatchEvent(event);
            if(this.isTractor){
                this.disabledPostSantionButton = true;
                this.disabledUploadBranchApproval = true;
                this.isReadOnly = true;
                this.disableRCLimitCheckButton = true;
            }
        })
        .catch(error => {
            this.error = error;
            //this.isReadOnly = false;
            console.log('Error in saveFinalButtonStatus Function ::'+ error.message);
        })
    }
    onFinalSubmitButtonPreDis(){
        let isVehicleDetailsCorrect = false;
        let isRcDataCorrect = false;
        console.log('onFinalSubmitButtonPreDis button called : ',);
        if(this.vehicleInspectionApprovedbyCVO == 'No'){
            let CVORemarksField = this.template.querySelector('lightning-input[data-id=CVORemarksField]');
            console.log('CVORemarksField : ',CVORemarksField.value);
            CVORemarksField.reportValidity();
            if (CVORemarksField.validity.valid === true && CVORemarksField.value != ''){
               isVehicleDetailsCorrect = false;
            }else{
               isVehicleDetailsCorrect = true;
                this.dispatchEvent(
                    new ShowToastEvent({
                    title: "Error",
                    message: 'Please fill remarks.',
                    variant: 'error' 
                })
                );
            }
        }
        if(this.isRCLimitCorrectlyCapturedValue == 'No' && this.isTwVehicleType){//CISP-8762
            let CVORemarksForRcLimit = this.template.querySelector('lightning-input[data-id=CVORemarksForRcLimit]');
            console.log('CVORemarksForRcLimit : ',CVORemarksForRcLimit.value);
            CVORemarksForRcLimit.reportValidity();
            if (CVORemarksForRcLimit.validity.valid === true && CVORemarksForRcLimit.value != ''){
                isRcDataCorrect = false;
            }else{
                isRcDataCorrect = true;
                this.dispatchEvent(
                    new ShowToastEvent({
                    title: "Error",
                    message: 'Please fill remarks.',
                    variant: 'error' 
                })
                );
            }
        }//CISP-8762 changes start
        if(isRcDataCorrect == false && isVehicleDetailsCorrect == false){
            console.log('in final if #### : ',);
            let objData = [];
            let obj;
            let msg = '';
            if(this.isTwVehicleType){
                obj={
                    'Id': this.vehicleRecordId,
                    'Vehicle_inspection_approved_by_CVO__c':this.vehicleInspectionApprovedbyCVO,
                    'CVO_remarks__c':this.template.querySelector('lightning-input[data-id=CVORemarksField]').value,
                    'CVO_Remarks_for_RC_Limit__c':this.template.querySelector('lightning-input[data-id=CVORemarksForRcLimit]').value,
                    'Is_RC_Limit_Check_correctly_captured__c':this.isRCLimitCorrectlyCapturedValue
                }
                msg = 'Vehicle Inspection and RC Limit Check done successfully.';
            }else{
                obj={
                    'Id': this.vehicleRecordId,
                    'Vehicle_inspection_approved_by_CVO__c':this.vehicleInspectionApprovedbyCVO,
                    'CVO_remarks__c':this.template.querySelector('lightning-input[data-id=CVORemarksField]').value,
                }
                msg = 'Vehicle Inspection done successfully.';
            }
            //CISP-8762 end
            objData.push(obj);
            console.log('objData : ',objData);
            updateVehicleDetailsByCVO({ loanApplicationId : this.recordId, data : JSON.stringify(objData), dealId: this.dealId})
              .then(result => {
                console.log('Result', result);
                //this.isStagePreDisbursement = true
                //this.isStagePostSantion = true;
                this.isEnabledButtonOnPreDis = true;
                const event = new ShowToastEvent({
                    title: 'Success',
                    message: msg,
                    variant: 'success',
                });
                this.dispatchEvent(event);
              })
              .catch(error => {
                console.error('Error:', error);
                this.isStagePreDisbursement = true
                this.isStagePostSantion = false;
                this.isEnabledButtonOnPreDis = false;
            });
        }else{ 
            console.log('in final else #### : ',);
        }

    }
    vehicleInspectionApprovedbyCVOHandle(event){
        this.isvehicleInspectionApprovedbyCVOHandle = true;
        this.vehicleInspectionApprovedbyCVO = event.target.value;
        if((this.isvehicleInspectionApprovedbyCVOHandle == true && this.isRCLimitCorrectlyCaptured == true && this.isTwVehicleType) || (this.isvehicleInspectionApprovedbyCVOHandle == true && !this.isTwVehicleType)){
            this.isEnabledButtonOnPreDis = false;
        }
    }
    handleisRCLimitCorrectlyCaptured(event){
        this.isRCLimitCorrectlyCaptured = true;
        if((this.isvehicleInspectionApprovedbyCVOHandle == true && this.isRCLimitCorrectlyCaptured == true && this.isTwVehicleType) || (this.isRCLimitCorrectlyCaptured == true && !this.isTwVehicleType)){
            this.isEnabledButtonOnPreDis = false;
        }
        this.isRCLimitCorrectlyCapturedValue = event.target.value;
       // this.disableSubmitVehicleInspectionButton = false;
    }
}