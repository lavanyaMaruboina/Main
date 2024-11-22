import { LightningElement,track,api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import doGenerateTokenAPI from '@salesforce/apex/IntegrationEngine.doGenerateTokenAPI';
import getRequestDetails_MTD from '@salesforce/apex/ViewCamController.getRequestDetails';
import getRequestDetailsForTractor_MTD from '@salesforce/apex/ViewCamController.getRequestDetailsForTractor';
import CIBIL_Report from '@salesforce/label/c.CIBIL_Report';
import Equifax_Report from '@salesforce/label/c.Equifax_Report';
import CRIF_Report from '@salesforce/label/c.CRIF_Report';
import Message_No_Borrower_Or_CIBIL_Report_URL from '@salesforce/label/c.Message_No_Borrower_Or_CIBIL_Report_URL';
import Message_No_Borrower_Or_CRIF_Report_URL from '@salesforce/label/c.Message_No_Borrower_Or_CRIF_Report_URL';
import Message_No_CoBorrower_Or_CIBIL_Report_URL from '@salesforce/label/c.Message_No_CoBorrower_Or_CIBIL_Report_URL';
import Message_No_Beneficiary_Or_CIBIL_Report_URL from '@salesforce/label/c.Message_No_Beneficiary_Or_CIBIL_Report_URL';
import Message_No_Beneficiary_Or_Equifax_Report_URL from '@salesforce/label/c.Message_No_Beneficiary_Or_Equifax_Report_URL';
import Message_No_Guarantor_Or_CIBIL_Report_URL from '@salesforce/label/c.Message_No_Guarantor_Or_CIBIL_Report_URL';
import Message_No_Guarantor_Or_Equifax_Report_URL from '@salesforce/label/c.Message_No_Guarantor_Or_Equifax_Report_URL';
import Message_No_Borrower_Or_Equifax_Report_URL from '@salesforce/label/c.Message_No_Borrower_Or_Equifax_Report_URL';
import Message_No_CoBorrower_Or_Equifax_Report_URL from '@salesforce/label/c.Message_No_CoBorrower_Or_Equifax_Report_URL';

export default class IND_LWC_CibilEquifaxReport extends NavigationMixin(LightningElement){
  @api recordId
  @api message
  @api applicantId; 
  @api isTractor = false;
  @track borrowerCibilRecord;
  @track coBorrowerCibilRecord;
  @track coBorrowerCibilRecordTractor;
  @track customerType;
  @track crifReportURL;
  @track guarantorCibilRecordTractor;
  @track errorMsg;
  @track reportURL;
  @track reportheader;
  @track label = {  
    CIBIL_Report,
    Equifax_Report,
    CRIF_Report
  }

  connectedCallback(){
    console.log('recordId',this.recordId);
    if(this.recordId){
      this.message = this.recordId.split(' ');
      this.recordId = this.message[0];
      this.getRequestDetails();
    }
  }
  getRequestDetails(){
    getRequestDetails_MTD({camId:this.recordId})
    .then(response=>{
      if(response){
        this.customerType=response.customerType;
        this.crifReportURL=response.reportURL;
        this.borrowerCibilRecord = response.borrowerCibilRecord;
        this.coBorrowerCibilRecord = response.coBorrowerCibilRecord;
        this.guarantorCibilRecordTractor = response.guarantorCibilRecord;
      }
    })

    if(this.isTractor){
      getRequestDetailsForTractor_MTD({camId:this.recordId, applicantId:this.applicantId})
      .then(response=>{
        if(response){
          this.coBorrowerCibilRecordTractor = response.coBorrowerCibilRecord;
          console.log('response.coBorrowerCibilRecord-->'+JSON.stringify(response.coBorrowerCibilRecord));
        }
      })
    }
    


        doGenerateTokenAPI()
        .then(resp => {
            console.log(' Response : ', resp);
            let messageList = this.message[1].split('-');
            if(messageList && messageList[0] == 'Cibil'){
              if(messageList[1]=='Borrower'){
                if(this.borrowerCibilRecord && this.borrowerCibilRecord.CIBIL_Report_URl__c){
                  this.reportURL = this.borrowerCibilRecord?.CIBIL_Report_URl__c + '&SessionId=' + resp;
                }
                else{
                  this.errorMsg = Message_No_Borrower_Or_CIBIL_Report_URL;
                }
              }
              else if(messageList[1]=='CoBorrower' ||messageList[1]=='Beneficiary'){
                if((this.coBorrowerCibilRecord  && this.coBorrowerCibilRecord.CIBIL_Report_URl__c ) || (this.coBorrowerCibilRecordTractor && this.coBorrowerCibilRecordTractor.CIBIL_Report_URl__c)){
                  if(this.isTractor){
                    this.reportURL = this.coBorrowerCibilRecordTractor?.CIBIL_Report_URl__c + '&SessionId=' + resp;
                  }
                  else{
                  this.reportURL = this.coBorrowerCibilRecord?.CIBIL_Report_URl__c + '&SessionId=' + resp;
                  }
                }
                else{
                  if(messageList[1]=='CoBorrower'){
                    this.errorMsg = Message_No_CoBorrower_Or_CIBIL_Report_URL;
                  }
                  else if(messageList[1]=='Beneficiary'){
                    this.errorMsg = Message_No_Beneficiary_Or_CIBIL_Report_URL;
                  }
                }
              }
            
              else if(messageList[1]=='Guarantor'){
                if(this.guarantorCibilRecordTractor && this.guarantorCibilRecordTractor.CIBIL_Report_URl__c){
                    this.reportURL = this.guarantorCibilRecordTractor?.CIBIL_Report_URl__c + '&SessionId=' + resp;
                }
                else{
                  this.errorMsg = Message_No_Guarantor_Or_CIBIL_Report_URL;
                }
              }
            this.reportheader = this.label.CIBIL_Report;
            }
            else if(messageList && messageList[0] == 'Equifax'){
              if(messageList[1]=='Borrower'){
                console.log('this.borrowerCibilRecord:: ', this.borrowerCibilRecord);
                if(this.borrowerCibilRecord && this.borrowerCibilRecord.Equifax_Report_URl__c){
                this.reportURL = this.borrowerCibilRecord?.Equifax_Report_URl__c + '&SessionId=' + resp;
                }
                else{
                  this.errorMsg = Message_No_Borrower_Or_Equifax_Report_URL;
                }
              }
              else if(messageList[1]=='CoBorrower' || messageList[1]=='Beneficiary'){
                if((this.coBorrowerCibilRecord && this.coBorrowerCibilRecord.Equifax_Report_URl__c) || (this.coBorrowerCibilRecordTractor && this.coBorrowerCibilRecordTractor.Equifax_Report_URl__c)){
                  if(this.isTractor){
                    this.reportURL = this.coBorrowerCibilRecordTractor?.Equifax_Report_URl__c + '&SessionId=' + resp;
                  }
                  else{
                  this.reportURL = this.coBorrowerCibilRecord?.Equifax_Report_URl__c + '&SessionId=' + resp;
                  }
                }
                else{
                  if(messageList[1]=='CoBorrower' ){
                    this.errorMsg = Message_No_CoBorrower_Or_Equifax_Report_URL;
                  }
                  else if(messageList[1]=='Beneficiary' ){
                    this.errorMsg = Message_No_Beneficiary_Or_Equifax_Report_URL;
                  }
                }
              }
              else if(messageList[1]=='Guarantor'){
                if(this.guarantorCibilRecordTractor && this.guarantorCibilRecordTractor.Equifax_Report_URl__c){
                    this.reportURL = this.guarantorCibilRecordTractor?.Equifax_Report_URl__c + '&SessionId=' + resp;
                }
                else{
                  this.errorMsg = Message_No_Guarantor_Or_Equifax_Report_URL;
                }
              }
              this.reportheader = this.label.Equifax_Report;

            }
            else if(messageList && messageList[0] == 'CRIF'){

              if(messageList[1]=='Borrower'){
                if(this.crifReportURL){
                this.reportURL = this.crifReportURL + '&SessionId=' + resp;
                }
                else{
                  this.errorMsg =Message_No_Borrower_Or_CRIF_Report_URL;
                }
              }   
              this.reportheader = this.label.CRIF_Report;

            }
            if (this.reportURL) {
              window.location.href = this.reportURL;
            }
        })
        .catch(error=>{
          console.error(error);
        })
      }
    
  handleCloseButton(){
    self.close();
  }
}