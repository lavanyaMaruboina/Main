import { LightningElement, api, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { getRecord, updateRecord } from 'lightning/uiRecordApi';
import getOppRecord from '@salesforce/apex/KFSCalloutController.getOppRecord';
import getFinalOfferDetailsFromApex from '@salesforce/apex/KFSCalloutController.getFinalOfferDetails'; // Get Final Offer Details
//import FORM_FACTOR from '@salesforce/client/formFactor';

import doKFSAPICallout from '@salesforce/apex/IntegrationEngine.doKFSCallout';
import doKFSSmsGatewayAPI from '@salesforce/apex/IntegrationEngine.doKFSSmsGatewayAPI';
import RETRIGGER_TIME from "@salesforce/label/c.KFS_Retrigger_Time";

//import doKFSSmsGatewayAPI from '@salesforce/apex/KFSCalloutController.doKFSSmsGatewayAPI';

// import doKFSSmsGatewayAPINonIndividual from '@salesforce/apex/KFSCalloutController.doKFSSmsGatewayAPINonIndividual';
import isPaymentRequestGenerated from '@salesforce/apex/LoanDisbursementController.isPaymentRequestGenerated';
import createKFSDocument from '@salesforce/apex/KFSCalloutController.createDocument';
//import isPaymentRequestGeneratedTractor from '@salesforce/apex/KFSCalloutController.isPaymentRequestGenerated';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
//import getDealNumberDetails from '@salesforce/apex/LoanDisbursementController.getDealNumberDetails';
//import getDealNumbers from '@salesforce/apex/LoanDisbursementController.getDealNumbers';
import getVehicleRecordId from '@salesforce/apex/KFSCalloutController.getVehicleRecordId';
//import kfsCalloutMultipleDeals from '@salesforce/apex/KFSCalloutController.kfsCalloutMultipleDeals';
import checkKFSConsentGiven from '@salesforce/apex/KFSCalloutController.checkKFSConsentGiven';
import Tractor from '@salesforce/label/c.Tractor';
import otherFilesDeleted from '@salesforce/apex/GenericUploadController.otherFilesDeleted';
import getKFSSmsLocation from '@salesforce/apex/KFSCalloutController.getKFSSmsLocation';
import updateReverseStatus from '@salesforce/apex/KFSCalloutController.updateReverseStatus';
const columns = [
    { label: 'Deal Number', fieldName: 'DealNumber', type: 'text'}
];

export default class IND_LWC_KFS extends NavigationMixin(LightningElement){
    disableKFSBtn = false;
    isTractor = false;
    kfsTypeVal;
    disableCmbBox=false;
    @track kfsOptions = [{label: "Hard Copy",value: "Physical"}, {label: "SMS",value: "Digital"}];
    @track dealNumberOptions =[];
    @track finalOfferDetails;
    @track dealNumberData = [];
    @track tractorDealNo = '';
    @api recordid;@api disbursementrecordid;@api applicantid;@api loanapplicantdetails;
    @api dealId='';
    @track dealNumberfortesting = '';
    @track requestfortesting;
    @track multiAsset = false;
    columns = columns;

    timeLeft = RETRIGGER_TIME;
  showTimer = false;

    doctype = 'KFS';
    vehicleRecordId='';
    docId='';
    disabledFileUpload=false;
    uploadviewdocpopup = false;
    documentToDelete;
    modalPopUpCaptureImage=false;
    disableUpload=false;
    showKFSLink=true;
    get acceptedFormats() {
            return ['.jpg', '.png', '.jpeg', '.docx', '.pdf']
    }

    startCountDown() {
        console.log('countdown');
        let timerId = setInterval(() => {
          if (this.timeLeft == 0) {
            clearTimeout(timerId);
            this.showTimer = false;
            //this.sendLinkButtonDisabled = false;
            this.disableKFSBtn = false;
            this.disableCmbBox = false;
            this.timeLeft = RETRIGGER_TIME; //Reset timer
          } else {
            this.timeLeft--;
          }
        }, 1000);
      }

    handleOnchange(event){
        this.kfsTypeVal = event.target.value;
        console.log('kfsvalue___'+this.kfsTypeVal);
    }
    captureKFS(){
        if(this.requestfortesting==null || this.requestfortesting =='' || this.requestfortesting==undefined){
            this.showToastMessage('', 'Click Initiate KFS button and then upload document', 'error');
        }else{
            //this.deleteImage(this.docId, false, true, this.documentToDelete);
            this.modalPopUpCaptureImage = true;
        }
    }

    async handleUploadFinished(event) {
        this.showToastMessage('', 'Key Fact Statement uploaded successfully', 'Success');
        this.documentToDelete = event.detail.files[0].documentId;
        console.log('upload finished');
        await otherFilesDeleted({contentDocId : this.documentToDelete, documentId : this.docId}).then(data =>{
            console.log('otherFilesDeleted .');
        }).catch(error =>{
            console.log('otherFilesDeleted error.',error);
        }); 
        console.log('this.documentToDelete___'+this.documentToDelete);

        await updateReverseStatus({oppId:this.recordid});
    }

    captureImageDone() {
        this.modalPopUpCaptureImage = false;
    }
    captureImageClose(){
        this.modalPopUpCaptureImage = false;
    }
    handleDealNumber(event){
        this.dealNumberfortesting = event.target.value;
        console.log('this.dealNumberfortesting___'+this.dealNumberfortesting);
    }

    @track Bl_Locations=[];

    async connectedCallback(){
        console.log('KFS connected callback');
        await getKFSSmsLocation().then(result =>{
            this.Bl_Locations = result.All_BL_Codes__c.split(';');
            console.log('this.Bl_Location__'+this.Bl_Locations);
          }).catch(err => {
            console.log(err,'err from pennydrop');
          });
        let res = await getOppRecord({'loanId' : this.recordid});
        this.accName = res[0].Account.Name;
        console.log('this.accName___'+this.accName);
    if(res && res.length > 0 && res[0].Product_Type__c == 'Tractor'){
      this.isTractor = true;
      //this.disableUpload = true;
    }else{
        this.requestfortesting = res[0].KFS_URL__c;
        this.kfsTypeVal = res[0].KFS_Type__c;

        if(this.kfsTypeVal == 'Physical'){
            this.showKFSLink = true;
            this.disableKFSBtn = true;
            this.disableCmbBox = true;
        }else{
            this.showKFSLink = false;
        }
       // this.disableKFSBtn = false;
        if(this.requestfortesting !== null && this.requestfortesting !== '' && this.requestfortesting != undefined){
            if(this.kfsTypeVal==null || this.kfsTypeVal=='' || this.kfsTypeVal==undefined){
                this.kfsTypeVal = 'Physical';
                this.showKFSLink = true;
                this.disableKFSBtn = true;
            }
        }
    }

    if(!this.isTractor && this.Bl_Locations.includes(this.accName?.toUpperCase())){
        this.kfsOptions = [{label: "Hard Copy",value: "Physical"}, {label: "SMS",value: "Digital"}];
    }else{
        this.kfsOptions = [{label: "Hard Copy",value: "Physical"}];
    }

    if(this.isTractor){
        await getVehicleRecordId({oppId:this.recordid,dealId:this.dealId}).then(result=>{
            this.vehicleRecordId = result.Id;
            this.requestfortesting = result.KFS_URL__c;
            this.kfsTypeVal = result.KFS_Type__c;
            if(this.kfsTypeVal == 'Physical'){
                this.showKFSLink = true;
                this.disableKFSBtn = true;
                this.disableCmbBox = true;
            }else{
                this.showKFSLink = false;
            }
            //this.disableKFSBtn = true;
            if(this.requestfortesting !== null && this.requestfortesting !== '' && this.requestfortesting != undefined){
                if(this.kfsTypeVal==null || this.kfsTypeVal=='' || this.kfsTypeVal==undefined){
                    this.kfsTypeVal = 'Physical';
                    this.showKFSLink = true;
                    this.disableKFSBtn = true;
                }
              
            }
        }).catch(error => {
            console.log(error);
        });
    }

    await createKFSDocument({vehicleDetailId:this.vehicleRecordId,oppId:this.recordid,isTractor:this.isTractor}).then(result=>{
        this.docId = result;
    }).catch(error => {
        console.log('error--->'+error);
    });

   /* await isPaymentRequestGeneratedTractor({oppId : this.recordid}).then(result=>{
        if (result === false) {
            const evt = new ShowToastEvent({
                title: "Error",
                message: 'Payment Request is not generated, Please generate it in previous tab.',
                variant: 'Error',
            });
            this.dispatchEvent(evt);
        }
    }).catch(error => {
        console.log(error);
    });
    */
/*
    await getDealNumbers({oppId : this.recordid}).then(result=>{
        if(result){
            this.multiAsset = result.multiAsset;
            this.dealNumberOptions = result?.dealNumberWrapperList.map(deal => ({
                label: deal.dealNumber,
                value: deal.dealId,
                isPayamentRequestCompleted : deal.isPayamentRequestCompleted,
            }));
            let dealNumberOptions = this.dealNumberOptions;
            console.log('dealNumberOptions___'+JSON.stringify(dealNumberOptions));
            console.log('dealNumberOptions_s__'+this.dealNumberOptions);
            let custObj;
            if(this.multiAsset){
                //this.disableKFSBtn = true;
                for (let key in dealNumberOptions){
                    if(dealNumberOptions[key].isPayamentRequestCompleted){
                    custObj = {
                        ...{'DealNumber' : dealNumberOptions[key].label}
                    };
                    if(custObj != undefined || custObj != null){//CISP-9170||CISP-9193
                        this.dealNumberData.push(custObj);
                    }
                }
                }
            }
           
        }
    }).catch(error=>{
        console.log(error);
    });

    await getDealNumberDetails({loanApplicationId: this.recordid, dealId: this.dealId}).then(result=>{
        if(result){
            if (result.Loan_Application__r.Product_Type__c == Tractor && result.Loan_Application__r.StageName) {
                this.tractorDealNo = result.Deal_Number__c;
            }
        }
    }).catch(error=>{
        console.log(error);
    });
    console.log('dealId___'+this.dealId);

    */

    await getFinalOfferDetailsFromApex({ loanId : this.recordid, dealId: this.dealId}).then(data => {
        if (data != null || data != undefined) {
          this.finalOfferDetails = data;
          console.log('data-->',JSON.stringify(data));
        }
      }).catch(error => {
        console.error('getFinalOfferDetailsFromApex error: ' , error);
      });

    
    }

    /*
    handleRowSelection = event => {
        let selectedRows=event.detail.selectedRows;
        if(selectedRows.length == 0){
            this.disableKFSBtn= true;
        }else{
            this.disableKFSBtn= false;
        }
       console.log('handleRowSelection___');
    }

    async handleSelection(){
        let selectedRows = this.template.querySelector('lightning-datatable').getSelectedRows();
        console.log('selectedRows : ',selectedRows.length);
        let selectedData = JSON.parse(JSON.stringify(selectedRows));
        let selectedDealNumbers = '';
        selectedData.forEach(currentItem => {
            selectedDealNumbers = selectedDealNumbers + currentItem.DealNumber + ';';
        });
        console.log('OUTPUT invalidCustomerCodes: ',selectedDealNumbers);
        selectedDealNumbers = selectedDealNumbers.substring(0,selectedDealNumbers.length-1);
        console.log('OUTPUT : ',selectedDealNumbers);

        await kfsCalloutMultipleDeals({ oppId: this.recordid, selectedDealNumbers: selectedDealNumbers})
          .then(result => {
            console.log('SUcess__'+result);
          })
          .catch(error => {
            console.error('Error:', error);
        });
    }

    */

    
    get getFinalOfferDetailflag() {
        return (this.finalOfferDetails != null || this.finalOfferDetails != undefined) ? true : false;
      }

      get getFinalOfferDetails() {
        return this.finalOfferDetails;
      }

      get getMMVDetails() {
        let makeModelVariant = this.getFinalOfferDetails.makeModelVariant == undefined ? '' : this.getFinalOfferDetails.makeModelVariant;
        return makeModelVariant;
      }

      showToastMessage(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        }));
    }

    navigateToNextTab() {
        this.dispatchEvent(
            new CustomEvent('successfullysubmitted')
        );
    }


    @track pactGenerated = true;
    @track kfsSanctionGiven = false;
      async initiateKFS(){
        this.disableKFSBtn = true;
        this.disableCmbBox = true;
        let result = this.validateInputs();
        if(result){return;}
      
       // if(this.isTractor && this.multiAsset){
            //this.handleSelection();
            //this.disableKFSBtn = false;
       // }else{
            this.sendKFS();
           /* const applicantFields = {};
            applicantFields['Id'] = this.recordid;
            applicantFields['Deal_Number__c'] = this.dealNumberfortesting;
            this.updateRecordDetails(applicantFields);
            */
       // }
        
      }

      validateInputs(){
        let kfsTypeInput = this.template.querySelector('lightning-combobox[data-id=kfsType]');
        if(kfsTypeInput !== null){
            kfsTypeInput.reportValidity();

            if(!kfsTypeInput.value){
                this.showToastMessage('', 'Select KFS Type Value', 'warning');
                this.disableKFSBtn = false;
                this.disableCmbBox = false;
                return true;
            }
        }
      }

      async sendKFS(){
        console.log('63 KFS');
        await isPaymentRequestGenerated({ loanApplicationId: this.recordid,dealId : this.dealId })
        .then(response => {
            console.log('response pact ==> kfs', response);
            if (response === false) {
                const evt = new ShowToastEvent({
                    title: "Error",
                    message: 'Payment Request is not generated, Please generate it in previous tab.',
                    variant: 'Error',
                });
                this.dispatchEvent(evt);
                this.pactGenerated = false;
                this.disableKFSBtn = false;
                this.disableCmbBox = false;
                return ;
            }
        });

        
        await checkKFSConsentGiven({loanApplicationId: this.recordid,dealId : this.dealId })
        .then(response => {
            if (response === true) {
                console.log('his.kfsSanctionGiven___');
                this.kfsSanctionGiven = true;
                this.showToastMessage('', 'Key Fact Statement Consent already taken.', 'Success');
                this.disableKFSBtn = true;
                return;
            }
        });
        
        

            if(this.pactGenerated && !this.kfsSanctionGiven){
            //if(this.pactGenerated){
            console.log('response pact ==> return');
            this.callKFS();
            /*} else{
                this.disableKFSBtn = false;
                if(this.kfsSanctionGiven){
                this.showToastMessage('', 'Key Fact Statement Consent already taken.', 'Success');
                this.disableKFSBtn = true;
                }
            }*/
        }

    }
    @track isSpinnerMoving=false;
    /* async callKFS(){
        let timeInterval;
        this.disableKFSBtn = true;
        this.isSpinnerMoving = true;
        let apiInputs = {
            'fromProCredit': false,
            'loanApplicationId' : this.recordid,
            'dealId' : this.dealId
        }
         await doKFSAPICallout({'kfsRequestString' : JSON.stringify(apiInputs)}).then(result =>{
            try{
               // this.cicNo = result.Response;
                this.showToastMessage('', 'Key Fact Statement Success', 'Success');
                this.isSpinnerMoving = false;
                this.navigateToNextTab();
                timeInterval = 30000;
                setTimeout(() => {
                    this.disableKFSBtn = false;
                }, timeInterval);

            } catch(error){
                console.log('Error in Parsing Dedupe API__'+error);
                this.showToastMessage('', 'Key Fact Statement Error', 'error');
                timeInterval = 30000;
                this.isSpinnerMoving = false;
                setTimeout(() => {
                    this.disableKFSBtn = false;
                }, timeInterval);
            }
        }).catch(error => {
            this.showToastMessage('', 'Key Fact Statement Error.', 'error');
            this.isSpinnerMoving = false;
            timeInterval = 30000;
                setTimeout(() => {
                    this.disableKFSBtn = false;
                }, timeInterval);
        });
       
    }
    */
    kfsResponse = '';
    async callKFS(){
        let timeInterval;
        this.isSpinnerMoving = true;
        let status;
        let apiInputs = {
            'fromProCredit': false,
            'loanApplicationId' : this.recordid,
            'dealId' : this.dealId,
            'KFSSmsType' : this.kfsTypeVal
        }
        await doKFSAPICallout({'kfsRequestString' : JSON.stringify(apiInputs)}).then(result =>{
            try{
                console.log('result___doKFSresponse___'+JSON.stringify(result));
                status = result.status;
                if(status == 'SUCCESS'){
                    this.kfsResponse = result.app_str;
                    console.log('this.kfsResponse___'+this.kfsResponse);
                    this.isSpinnerMoving = false;
                    //this.showToastMessage('', 'Key Fact Statement Success', 'Success');
                    const smsresult =  this.sendKFSSMS();
                   // console.log('smsresult____'+smsresult);
                  
                 }else if(status == 'FINALTERMS NOT AVAILABLE'){
                    this.showToastMessage('', 'Payment Request deatils not yet available to generate KFS, Please try again in 15 minutes.', 'error');
                    this.disableKFSBtn = false;
                    this.disableCmbBox = false;
                    this.isSpinnerMoving = false;
                 }else{
                    /*if(this.kfsTypeVal == 'Digital'){
                        this.showToastMessage('', 'Failure sending SMS, Please Initiate Key Fact Statement again for sending SMS.', 'error');
                    }else{
                        this.showToastMessage('', 'Key Fact Statement Failed, Please try again', 'error');
                    }
                        */
                    this.showToastMessage('', 'Payment Request deatils not yet available to generate KFS, Please try again in 15 minutes.', 'error');
                    this.disableKFSBtn = false;
                    this.disableCmbBox = false;
                    this.isSpinnerMoving = false;
                }
            }catch(error){
                this.showToastMessage('', 'Payment Request deatils not yet available to generate KFS, Please try again in 15 minutes.', 'error');
                console.log('Error in Parsing  API__'+error);
               /* if(this.kfsTypeVal == 'Digital'){
                    this.showToastMessage('', 'Failure sending SMS, Please Initiate Key Fact Statement again for sending SMS.', 'error');
                }else{
                    this.showToastMessage('', 'Key Fact Statement Failed, Please try again', 'error');
                }
                    */
                this.isSpinnerMoving = false;
                this.disableKFSBtn = false;
                this.disableCmbBox = false;
            }
        }).catch(error => {
            this.showToastMessage('', 'Payment Request deatils not yet available to generate KFS, Please try again in 15 minutes.', 'error');
            /*if(this.kfsTypeVal == 'Digital'){
                this.showToastMessage('', 'Failure sending SMS, Please Initiate Key Fact Statement again for sending SMS.', 'error');
            }else{
                this.showToastMessage('', 'Key Fact Statement Failed, Please try again', 'error');
            }
                */
            this.isSpinnerMoving = false;
            this.disableKFSBtn = false;
            this.disableCmbBox = false;
            console.log('error___'+error);
            console.log('error___'+JSON.stringify(error));     
        });
    }
    smsStatus='';
    async sendKFSSMS(){
        console.log('sendKFSSMS___');
        console.log('sendKFSSMS___res___'+ typeof this.kfsResponse);
        let status;
        
       await doKFSSmsGatewayAPI({'smsRequestString' : this.kfsResponse})
        .then(response => {
            console.log('result___doKFSrsmsssesponse___'+JSON.stringify(response));
            try{
                status = response.status;
                if(status == 'SUCCESS'){
                    //this.showToastMessage('', 'Key Fact Statement Success', 'Success');
                    this.requestfortesting = response.requestfortesting;
                    if(this.kfsTypeVal == 'Physical'){
                        this.showKFSLink = true;
                        this.disableKFSBtn = true;
                    }else{
                        this.showTimer = true;
                        this.startCountDown();
                    }
                    if(this.isTractor){
                         const applicantFields = {};
                         applicantFields['Id'] = this.vehicleRecordId;
                         applicantFields['KFS_URL__c'] = this.requestfortesting;
                         applicantFields['KFS_Type__c'] = this.kfsTypeVal;
                         this.updateRecordDetails(applicantFields);
                    }else{
                        const applicantFields = {};
                         applicantFields['Id'] = this.recordid;
                         applicantFields['KFS_URL__c'] = this.requestfortesting;
                         applicantFields['KFS_Type__c'] = this.kfsTypeVal;
                         this.updateRecordDetails(applicantFields);
                    }
                    this.isSpinnerMoving = false;
                    this.smsStatus='SUCCESS';
                }else{
                    this.isSpinnerMoving = false;
                    //this.showToastMessage('', 'Key Fact Statement SMS Errorr', 'error');
                    //this.disableKFSBtn = false;
                    this.smsStatus='ERROR';
                }
            }catch {
            this.isSpinnerMoving = false;
           // this.disableKFSBtn = false;
            this.smsStatus='ERROR';
            }
         }).catch(error => {
            this.isSpinnerMoving = false;
            console.log('error sms'+error);
            //this.disableKFSBtn = false;
            this.smsStatus='ERROR';
        });
        console.log('yyyg__'+this.smsStatus);

        if(this.smsStatus === 'SUCCESS'){
            if(this.kfsTypeVal == 'Digital'){
                this.showToastMessage('', 'Key Fact Statement SMS has been sent successfully. Fo resending SMS try again after 10 mins', 'Success');
            }else{
                this.showToastMessage('', 'Key Fact Statement Success', 'Success');
            }
        }else{
            if(this.kfsTypeVal == 'Digital'){
                this.showToastMessage('', 'Failure sending SMS, Please Initiate Key Fact Statement again for sending SMS.', 'error');
            }else{
                this.showToastMessage('', 'Key Fact Statement Failed, Please try again', 'error');
            }
            this.disableKFSBtn = false;
            this.disableCmbBox = false;
            this.isSpinnerMoving = false;
        }
    }

    async updateRecordDetails(fields) {
        const recordInput = { fields };
        await updateRecord(recordInput).then((result) => {
            console.log('result__');
           
        }).catch(error => {
            console.log('hsdhfv__'+JSON.stringify(error));
            this.showToastMessage('', JSON.stringify(error), 'error');
            this.disableKFSBtn = false;
        });
    }
   
}