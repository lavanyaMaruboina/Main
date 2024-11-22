import { LightningElement, api, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { getRecord, updateRecord } from 'lightning/uiRecordApi';
import getOppRecord from '@salesforce/apex/KFSCalloutController.getOppRecord';
import getFinalOfferDetailsFromApex from '@salesforce/apex/KFSCalloutController.getFinalOfferDetails'; // Get Final Offer Details
//import FORM_FACTOR from '@salesforce/client/formFactor';

import doKFSAPICallout from '@salesforce/apex/IntegrationEngine.doKFSCallout';
//import doKFSSmsGatewayAPI from '@salesforce/apex/IntegrationEngine.doKFSSmsGatewayAPI';
import doKFSSmsGatewayAPI from '@salesforce/apex/KFSCalloutController.doKFSSmsGatewayAPI';

// import doKFSSmsGatewayAPINonIndividual from '@salesforce/apex/KFSCalloutController.doKFSSmsGatewayAPINonIndividual';
import isPaymentRequestGenerated from '@salesforce/apex/LoanDisbursementController.isPaymentRequestGenerated';
import createKFSDocument from '@salesforce/apex/KFSCalloutController.createDocument';
//import isPaymentRequestGeneratedTractor from '@salesforce/apex/KFSCalloutController.isPaymentRequestGenerated';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
//import getDealNumberDetails from '@salesforce/apex/LoanDisbursementController.getDealNumberDetails';
//import getDealNumbers from '@salesforce/apex/LoanDisbursementController.getDealNumbers';
import getVehicleRecordId from '@salesforce/apex/KFSCalloutController.getVehicleRecordId';
//import kfsCalloutMultipleDeals from '@salesforce/apex/KFSCalloutController.kfsCalloutMultipleDeals';
//import checkKFSConsentGiven from '@salesforce/apex/LoanDisbursementController.checkKFSConsentGiven';
import Tractor from '@salesforce/label/c.Tractor';
import otherFilesDeleted from '@salesforce/apex/GenericUploadController.otherFilesDeleted';

const columns = [
    { label: 'Deal Number', fieldName: 'DealNumber', type: 'text'}
];

export default class IND_LWC_KFS extends NavigationMixin(LightningElement){
    disableKFSBtn = false;
    isTractor = false;
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

    doctype = 'KFS';
    vehicleRecordId='';
    docId='';
    disabledFileUpload=false;
    uploadviewdocpopup = false;
    documentToDelete;
    modalPopUpCaptureImage=false;
    disableUpload=false;
    get acceptedFormats() {
            return ['.jpg', '.png', '.jpeg', '.docx', '.pdf']
    }

    captureKFS(){
        if(this.requestfortesting==null || this.requestfortesting =='' || this.requestfortesting==undefined){
            this.showToastMessage('', 'Click Initiate KFS button and then upload document', 'error');
        }else{
            //this.deleteImage(this.docId, false, true, this.documentToDelete);
            this.modalPopUpCaptureImage = true;
        }
    }

    handleUploadFinished(event) {
        this.showToastMessage('', 'Key Fact Statement uploaded successfully', 'Success');
        this.documentToDelete = event.detail.files[0].documentId;
        otherFilesDeleted({contentDocId : this.documentToDelete, documentId : this.docId}).then(data =>{
            console.log('otherFilesDeleted .');
        }).catch(error =>{
                console.log('otherFilesDeleted error.',error);
        }); 
        console.log('this.documentToDelete___'+this.documentToDelete);
    }

    captureImageDone() {
        this.modalPopUpCaptureImage = false;
    }
    captureCustomerImageClose(){
        this.modalPopUpCaptureImage = false;
    }
    handleDealNumber(event){
        this.dealNumberfortesting = event.target.value;
        console.log('this.dealNumberfortesting___'+this.dealNumberfortesting);
    }

    async connectedCallback(){
        console.log('KFS connected callback');
        let res = await getOppRecord({'loanId' : this.recordid});
    if(res && res.length > 0 && res[0].Product_Type__c == 'Tractor'){
      this.isTractor = true;
      //this.disableUpload = true;
    }else{
        this.requestfortesting = res[0].KFS_URL__c;
       // this.disableKFSBtn = false;
        if(this.requestfortesting !== null && this.requestfortesting !== '' && this.requestfortesting != undefined){
            this.disableKFSBtn = true;
        }
    }

    if(this.isTractor){
        await getVehicleRecordId({oppId:this.recordid,dealId:this.dealId}).then(result=>{
            this.vehicleRecordId = result.Id;
            this.requestfortesting = result.KFS_URL__c;
            //this.disableKFSBtn = true;
            if(this.requestfortesting !== null && this.requestfortesting !== '' && this.requestfortesting != undefined){
                this.disableKFSBtn = true;
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
                return ;
            }
        });

        /*
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
        */
        

            if(this.pactGenerated && !this.kfsSanctionGiven){
            if(this.pactGenerated){
            console.log('response pact ==> return');
            this.callKFS();
            }else{
                this.disableKFSBtn = false;
                if(this.kfsSanctionGiven){
                this.showToastMessage('', 'Key Fact Statement Consent already taken.', 'Success');
                this.disableKFSBtn = true;
                }
            }
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
        this.disableKFSBtn = true;
        this.isSpinnerMoving = true;
       let status;
        let apiInputs = {
            'fromProCredit': false,
            'loanApplicationId' : this.recordid,
            'dealId' : this.dealId
        }
        await doKFSAPICallout({'kfsRequestString' : JSON.stringify(apiInputs)}).then(result =>{
            try{
                console.log('result___doKFSresponse___'+JSON.stringify(result));
                status = result.status;
                if(status == 'SUCCESS'){
                    this.kfsResponse = result.app_str;
                    console.log('this.kfsResponse___'+this.kfsResponse);
                    this.isSpinnerMoving = false;
                    this.showToastMessage('', 'Key Fact Statement Success', 'Success');
                    //this.kfsresposne.contactNumber = mobileNumberValue;
                    console.log('smsresult____'+this.kfsresposne);
                    
                    const smsresult =  this.sendKFSSMS();
                    console.log('smsresult____'+smsresult);
                    if(smsresult === 'SUCCESS'){
                        //this.disableKFSBtn = false;
                        this.showToastMessage('', 'Key Fact Statement Success', 'Success');
                    }else{
                       // this.showToastMessage('', 'Key Fact Statement SMS Error', 'error');
                        this.disableKFSBtn = false;
                        this.isSpinnerMoving = false;
                    }
                    

                }else{
                    this.showToastMessage('', 'Key Fact Statement Error fail', 'error');
                    this.disableKFSBtn = false;
                    this.isSpinnerMoving = false;
                }
            }catch(error){
                console.log('Error in Parsing Dedupe API__'+error);
                this.showToastMessage('', 'Key Fact Statement Error catch', 'error');
                //timeInterval = 30000;
                this.isSpinnerMoving = false;
                this.disableKFSBtn = false;
            //    setTimeout(() => {
            //         this.disableKFSBtn = false;
            //     }, timeInterval); 
            }
        }).catch(error => {
            this.showToastMessage('', 'Key Fact Statement Error.', 'error');
            this.isSpinnerMoving = false;
            this.disableKFSBtn = false;
            console.log('error___'+error);
            console.log('error___'+JSON.stringify(error));
            // timeInterval = 30000;
            //     setTimeout(() => {
            //         this.disableKFSBtn = false;
            //     }, timeInterval);
                
        });
    }

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
                    this.showToastMessage('', 'Key Fact Statement Success', 'Success');
                    this.requestfortesting = response.requestfortesting;
                    this.disableKFSBtn = true;
                    //this.disableKFSBtn = false;
                    if(this.isTractor){
                         const applicantFields = {};
                         applicantFields['Id'] = this.vehicleRecordId;
                         applicantFields['KFS_URL__c'] = this.requestfortesting;
                         this.updateRecordDetails(applicantFields);
                    }else{
                        const applicantFields = {};
                         applicantFields['Id'] = this.recordid;
                         applicantFields['KFS_URL__c'] = this.requestfortesting;
                         this.updateRecordDetails(applicantFields);
                    }
                    this.isSpinnerMoving = false;
                   // this.disableKFSBtn = false;
                    return 'SUCCESS';
                }else{
                    this.isSpinnerMoving = false;
                    //this.showToastMessage('', 'Key Fact Statement SMS Errorr', 'error');
                    this.disableKFSBtn = false;
                    return 'ERROR';
                }
            }catch {
            this.isSpinnerMoving = false;
            this.disableKFSBtn = false;
             return 'ERROR';
            }
         }).catch(error => {
            this.isSpinnerMoving = false;
            console.log('error sms'+error);
            this.disableKFSBtn = false;
            return 'ERROR';
        })
        
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