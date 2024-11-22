import { api, track, LightningElement,wire } from "lwc";
import { updateRecord,getRecord } from "lightning/uiRecordApi";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import doRegistrationJourneyCallout from "@salesforce/apexContinuation/IntegrationEngine.doRegistrationJourneyCallout";
import doSmsGatewayCallout from "@salesforce/apexContinuation/IntegrationEngine.doSmsGatewayCallout";
import doEnachRegistrationStatusAsyncCallout from '@salesforce/apex/IntegrationEngine.doEnachRegistrationStatusAsyncCallout';
import REPAYMENT_DETAILS_ID from "@salesforce/schema/Repayments__c.Id";
import URL_FIELD from "@salesforce/schema/Repayments__c.URL__c";
import E_NACH_SESSION from "@salesforce/schema/Repayments__c.E_Nach_Session__c";
import MESSAGE from "@salesforce/schema/Repayments__c.Message__c";
import ENACH_BUTTON_CLICK_TIME_FIELD from "@salesforce/schema/Repayments__c.Initiate_E_NACH_Btn_Click_Date_And_Time__c";//Added by Rajasekar as part of CISP-22313
import displayRepaymentInfo from "@salesforce/apex/RepaymentScreenController.displayRepaymentInfo";
//import TIMEOUT_LABEL from "@salesforce/label/c.Label_Timeout";
import URL_NOT_RECEIVED_ERROR_LABEL from "@salesforce/label/c.Label_Timeout";
import checkRetryExhausted from "@salesforce/apex/ENACHController.checkRetryExhausted";
import retryCountIncrease from "@salesforce/apex/ENACHController.retryCountIncrease";
import RETRY_ERROR_MSG from "@salesforce/label/c.Retry_Limit_Exhausted";
import RETRY_ERROR_MSG_FINAL_OFFER from "@salesforce/label/c.Enach_Retry_Limit_Exhausted_in_Final_Offer";
import RETRIGGER_TIME from "@salesforce/label/c.Enach_Trigger_Link_Time_seconds";
import RETRIGGER_STATUS_CHECK_FREQUENCY_TIME from "@salesforce/label/c.Enach_Trigger_Link_Status_Check_Frequency_Time_seconds";//Added by Rajasekar as part of CISP-22313
import ENACH_ATTEMPTS from "@salesforce/label/c.Initiate_ENACH_Attempts";
import SMS_ATTEMPTS from "@salesforce/label/c.ENACH_Sms_Retry_Limit";
import E_NACH_API_Status__c from "@salesforce/schema/Repayments__c.E_NACH_API_Status__c";
import Repayment_Remarks__c from "@salesforce/schema/Repayments__c.Repayment_Remarks__c";
import Repayments_Captured_Correctly__c from "@salesforce/schema/Repayments__c.Repayments_Captured_Correctly__c";
//import submitENACH from "@salesforce/apex/ENACHController.submitENACH";
// import STAGE_FIELD from "@salesforce/schema/Opportunity.StageName";
import updateLoanTransaction from "@salesforce/apex/RepaymentScreenController.updateLoanTransaction";
import isCheckReadOnly from "@salesforce/apex/RepaymentScreenController.isCheckReadOnly";
import POST_SANCTION_CHECKS_AND_DOCUMENTATION	 from "@salesforce/label/c.Post_Sanction_Checks_and_Documentation";
import PRE_DISBURSEMENT_CHECK from "@salesforce/label/c.Pre_Disbursement_Check";
import ENACHSUCESSMSG from "@salesforce/label/c.eNachSucessMsg";
import LOAN_STAGE_ADDITIONAL_DOCUMENTS from "@salesforce/label/c.Loan_Stage_Additional_Documents";
import enachJournyStatusHistory from "@salesforce/apex/ENACHController.enachJournyStatusHistory";
import NoResponse from "@salesforce/label/c.NoResponse";

export default class IND_LWC_eNachRepaymentMandate extends LightningElement {
  @api recordId;
  @api dealId;
  @api currentStep;
  isReadOnly;
  @api applicantId;
  @track repaymentsId;
  @track url;
  isEnachRetryExhausted;
  isSMSRetryExhausted;
  showSpinner = false;
  timeLeft = RETRIGGER_TIME;
  timeLeftInMins = '0'+Math.trunc((this.timeLeft-1)/60);//Added by Rajasekar as part of CISP-22313
  timeLeftInSecs = (this.timeLeft-1)%60;//Added by Rajasekar as part of CISP-22313
  showTimer = false;
  sendLinkButtonDisabled;
  smsResult;
  accLastDigits;
  showENACHSubmitButton=false;
  isPreDisbursementFieldsDisabled=true;//disabled during post sanction, enabled during pre disbursement
  yesNoOptionList;
  repaymentCapturedCorrectly='No';
  repaymentRemarks;
  stageName;
  disableInitiateENACH=false;
  isENACHSubmitVisible=false;
  enachSession;
  @track eNachMessage;
  @track eNachStatus;
  @track isENachStatusShow;
  @track isENachMessageShow;
  @track enachStatusData = [];//CISP-21750

  get isInitiateENACHButtonDisabled(){
    return this.disableInitiateENACH || this.isEnachRetryExhausted || this.showENACHSubmitButton|| this.isReadOnly;
  }
  get isENACHSubmitButtonVisible(){
    return this.isENACHSubmitVisible;
  }
  get isSendLinkDisabled() {
    return this.sendLinkButtonDisabled || this.isReadOnly;
  }
  isInitiateBtnClicked = false;
  async connectedCallback() {
    console.log("connectedCallback called " , this.applicantId);
    
    var yesNoOptionList = new Array();
    yesNoOptionList.push({ label: "Yes", value: "Yes" });
    yesNoOptionList.push({ label: "No", value: "No" });
    this.yesNoOption = yesNoOptionList;

    await isCheckReadOnly({loanApplicationId : this.recordId, dealId : this.dealId}).then(result=>{
        this.isReadOnly=result.isCheckReadOnly;
        this.stageName = result.stageName;
        //CISP=4181 Set readonly to false as Loan_Application_Transaction_History__c records are not created yet
        if(this.currentStep == 'final-offer') {
          this.isPreDisbursementFieldsDisabled = true;
          this.isReadOnly = false;
        }
        if(this.stageName == POST_SANCTION_CHECKS_AND_DOCUMENTATION){
            this.isPreDisbursementFieldsDisabled=true;
        }else if(this.currentStep == 'post-sanction' && this.stageName == PRE_DISBURSEMENT_CHECK){
          this.isPreDisbursementFieldsDisabled = true;
        }else if(this.currentStep == 'pre-disbursement' && this.stageName == PRE_DISBURSEMENT_CHECK){
          this.isPreDisbursementFieldsDisabled = false;
        }else if(this.currentStep == 'pre-disbursement' && this.stageName == LOAN_STAGE_ADDITIONAL_DOCUMENTS){
          this.isPreDisbursementFieldsDisabled = false;
          this.isReadOnly = true;
        }else if(this.currentStep == 'post-sanction' && this.stageName == LOAN_STAGE_ADDITIONAL_DOCUMENTS){
          this.isPreDisbursementFieldsDisabled = true;
          this.isReadOnly = true;
        }
    }).catch(error=>{
      console.log('isCheckReadOnly error '+error);
    });

    await displayRepaymentInfo({ loanAppId: this.recordId ,dealId:this.dealId})
      .then((result) => {
        if (result != null) {
          this.url = result.URL__c;
          this.repaymentsId = result.Id;
          this.eNachStatus=result.E_NACH_API_Status__c;
          this.eNachMessage=result.Message__c;
          this.repaymentCapturedCorrectly=result.Repayments_Captured_Correctly__c;
          this.repaymentRemarks=result.Repayment_Remarks__c;
          if(result.E_NACH_API_Status__c != '' && result.E_NACH_API_Status__c != null && result.E_NACH_API_Status__c != undefined){
            this.isENachStatusShow=true;
          }
          if(result.Message__c != '' && result.Message__c != null && result.Message__c != undefined){
            this.isENachMessageShow=true;
          }
          if(this.eNachStatus==='ENACH Registration Success'){
            this.isENACHSubmitVisible=true;
            //this.sendLinkButtonDisabled = true;
            this.disableInitiateENACH = true;
          }else if(this.currentStep == 'final-offer' && this.eNachStatus==='In Progress'){//CISP-4181 Allow users in L2 journey to re-initiate  e-Nach is e-NACH status is 'In Progress'
            this.showENACHSubmitButton=true;
          } 
          // else if(this.currentStep != 'final-offer' && this.eNachStatus === 'FAILED') {//CISP-4181 If e-NACH status is 'Failed' in L2 journey CVO should not be allowed to re-initiate  e-Nach
          //   this.disableInitiateENACH = true;
          // }
          this.accLastDigits= result?.Account_Number__c ? result.Account_Number__c.slice(-3) : undefined;

          //Added by Rajasekar as part of CISP-22313 - Starts
          let timeTenMinsAgo = new Date()-600000;
          let eNachBtnClickTime = result.Initiate_E_NACH_Btn_Click_Date_And_Time__c != null? new Date(result.Initiate_E_NACH_Btn_Click_Date_And_Time__c):null;
          if(this.eNachStatus !=='ENACH Registration Success' && this.eNachStatus !=='ENACH Registration Failed' && eNachBtnClickTime != null && timeTenMinsAgo < eNachBtnClickTime){
            this.disableInitiateENACH = true;
            this.showTimer = true;
            this.timeLeft = Math.trunc((eNachBtnClickTime - timeTenMinsAgo)/1000);
            this.startCountDown();
          }
          //Added by Rajasekar as part of CISP-22313 - Ends
        }
      })
      .catch((error) => {
        this.error = error;
        console.log("Error in displayRepaymentInfo connectedCallback Function ::" + error);
      });

    await checkRetryExhausted({ loanApplicationId: this.recordId, serviceName: ENACH_ATTEMPTS, dealId : this.dealId})
      .then((result) => {
        if (result != null) {
          this.isEnachRetryExhausted = result;
          if(this.isEnachRetryExhausted){
            if(this.currentStep == 'final-offer' && this.isReadOnly == false) {
              this.showToast(RETRY_ERROR_MSG_FINAL_OFFER, "error");
            }
            if(!this.isReadOnly && this.stageName == POST_SANCTION_CHECKS_AND_DOCUMENTATION){this.sendUpdateToParent({isScreenEditable:true});}
          }
        }
      })
      .catch((error) => {
        this.error = error;
        console.log("Error in enach checkRetryExhausted connectedCallback Function ::" + error);
      });
      //CISP-4181 User should have provision to retrigger the SMS button after 1minute each time until registration is successful
      /*await checkRetryExhausted({ loanApplicationId: this.recordId, serviceName: SMS_ATTEMPTS })
      .then((result) => {
        if (result != null) {
          this.isSMSRetryExhausted = result;
          if (this.isSMSRetryExhausted) {
            this.sendLinkButtonDisabled = true;
            this.sendUpdateToParent({isScreenEditable:true});
          }
        }
      })
      .catch((error) => {
        this.error = error;
        console.log("Error in sms checkRetryExhausted connectedCallback Function ::" + error);
      });*/
      if(this.isRevokedLoanApplication){this.disableEverything();}//CISP-2735
      await enachJournyStatusHistory({loanApplicationId: this.recordId})
      .then((result) => {//CISP-21750
        let finalRes = JSON.parse(JSON.stringify(result));
          console.log('enachJournyStatusHistory',finalRes);
          finalRes.forEach((item,index) =>{
            let reqestVal = JSON.parse(item?.Original_request__c);
            let responseVal = JSON.parse(item?.Original_response__c);
            if( reqestVal != null && responseVal != null){
            this.enachStatusData.push({rowIndex: index + 1,originalRequestSession:reqestVal?.session,originalResponseMsg:responseVal?.npcistatus})
            }             
          });
      })
      .catch((error) => {
        console.log(error,'err1');
          this.error = error;
      });//CISP-21750   
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
  incrementRetryCount(service) {
    console.log("increment");
    retryCountIncrease({ loanApplicationId: this.recordId, serviceName: service, dealId: this.dealId})
      .then((result) => {
        // if (result != null) {
        //     this.isEnachRetryExhausted =result;
        // }
      })
      .catch((error) => {
        this.error = error;
        console.log("Error in enach retryCountIncrease Function ::" + error);
      });
  }
  
  async initiateENach() {
    this.showSpinner = true;
    let isRetryExhausted = await checkRetryExhausted({ loanApplicationId: this.recordId, serviceName: ENACH_ATTEMPTS, dealId : this.dealId});
    if (!isRetryExhausted) {
      // this.showToast("E-Nach Request Initiated", "Success");
      await this.initiateEnachHandler();
    } else {
      this.sendUpdateToParent({isScreenEditable:true});
      //CISP-4181 Show a different error message in the final offer screen if retry attempts exhausted
      if(this.currentStep == 'final-offer') {
        this.showToast(RETRY_ERROR_MSG_FINAL_OFFER, "error");
        this.gotoFinalOfferPage();
      } else {
      this.showToast(RETRY_ERROR_MSG, "error");
      }
      this.isEnachRetryExhausted = true;
      this.showSpinner = false;
    }
  }

  async initiateEnachHandler(){
    await doRegistrationJourneyCallout({ applicantId: this.applicantId, loanAppId: this.recordId, dealId : this.dealId})
        .then((result) => {
          let response  = JSON.parse(result);
          if(response.Resp_Code === '200'){
            this.isInitiateBtnClicked = true;
            this.disableInitiateENACH=true; //need to unable so that user can retry
            //this.sendLinkButtonDisabled = false;
            console.log('response..'+JSON.stringify(result));
            const repaymentFIELDS = {};
            this.url = response.Registration_Url;
            this.enachSession = response.Session_Id;
            this.eNachMessage = response.Resp_Message;
            repaymentFIELDS[REPAYMENT_DETAILS_ID.fieldApiName] = this.repaymentsId;
            repaymentFIELDS[URL_FIELD.fieldApiName] = response.Registration_Url;
            repaymentFIELDS[E_NACH_SESSION.fieldApiName] = response.Session_Id;
            repaymentFIELDS[MESSAGE.fieldApiName] = response.Resp_Message;
            //Added by Rajasekar as part of CISP-22313 - Starts
            let currentTime = new Date();
            repaymentFIELDS[ENACH_BUTTON_CLICK_TIME_FIELD.fieldApiName] = currentTime.toString();
            //Added by Rajasekar as part of CISP-22313 - Ends
            this.incrementRetryCount(ENACH_ATTEMPTS);
            this.showToast(ENACHSUCESSMSG, "Success");
            this.updateRecordDetails(repaymentFIELDS);
            // this.incrementRetryCount(ENACH_ATTEMPTS);
            this.enachTriggerHandler();
            this.showSpinner = false;
          }else{
            console.log("E-Nach initate Error-> " + response.Resp_Msg);
            this.showToast(`${NoResponse}`, "error");
            this.incrementRetryCount(ENACH_ATTEMPTS);
            this.showSpinner = false;
          }
        })
        .catch((error) => {
          this.showToast(`${error.body.message}`, "error");
          console.log("E-Nach initate Error->", error);
          this.incrementRetryCount(ENACH_ATTEMPTS);
          this.showSpinner = false;
        });
  
  }
   /*async triggerENachLink() {
    if (!this.url) {
      this.showToast(URL_NOT_RECEIVED_ERROR_LABEL, "error");
      return;
    }
    if(this.isInitiateBtnClicked){
      //CISP-4181 User should have provision to retrigger the SMS button after 1minute each time until registration is successful
      let isRetryExhausted = await checkRetryExhausted({ loanApplicationId: this.recordId, serviceName: SMS_ATTEMPTS });
      if (!isRetryExhausted) {
        this.enachTriggerHandler();
      } else {
        this.sendUpdateToParent({isScreenEditable:true});
        this.showToast(RETRY_ERROR_MSG, "error");
        this.sendLinkButtonDisabled = true;
        this.showSpinner = false;
      }
    }else{
      //let isRetryExhausted = await checkRetryExhausted({ loanApplicationId: this.recordId, serviceName: SMS_ATTEMPTS });
      //if (!isRetryExhausted) {
        await this.initiateEnachHandler().then(()=>{
          this.enachTriggerHandler();

        });
       } else {
        this.sendUpdateToParent({isScreenEditable:true});
        this.showToast(RETRY_ERROR_MSG, "error");
        this.sendLinkButtonDisabled = true;
        this.showSpinner = false;
      }


    }
  }*/
  async enachTriggerHandler(){
    this.showSpinner = true;
        let smsRequestString = {
          applicantId: this.applicantId,
          loanApplicationId: this.recordId,
          flag: "ENACH",
          url: this.url,
          accountNumEnd:this.accLastDigits
        };
        await doSmsGatewayCallout({ smsRequestString: JSON.stringify(smsRequestString)})
          .then(() => {
            const repaymentFIELDS = {};
           // this.eNachStatus = 'In Progress';
            this.isInitiateBtnClicked = false;
            if(this.eNachStatus != 'ENACH Registration Success'){
            repaymentFIELDS[REPAYMENT_DETAILS_ID.fieldApiName] = this.repaymentsId;
            repaymentFIELDS[E_NACH_API_Status__c.fieldApiName] ='In Progress';
            this.updateRecordDetails(repaymentFIELDS);// After SMS is successfully sent, Screen is not editable
            }
            this.showTimer = true;
            //this.sendLinkButtonDisabled = true;
            this.showSpinner = false;
            this.incrementRetryCount(SMS_ATTEMPTS);
            this.startCountDown();
            console.log("Trigger E-Nach Response ->");
            let reqwrap = {};
            reqwrap.enachStatus = this.enachSession;

            doEnachRegistrationStatusAsyncCallout({statusCheckString : JSON.stringify(reqwrap), loanApplicationId : this.recordId})
            .then((result) => {
              console.log('PE success');
            }).catch(error => {
              console.log('PE success');
            });
          })
          .catch((error) => {
            this.showSpinner = false;
            //this.sendLinkButtonDisabled = true;
            this.showTimer = true;
            this.incrementRetryCount(SMS_ATTEMPTS); //SMS Returning error
            this.startCountDown();
            console.log("Trigger E-NACH error->", error);
          });
  }


  showToast(info, vari) {
    const event = new ShowToastEvent({
      title: "Message",
      message: info,
      variant: vari
    });
    this.dispatchEvent(event);
  }

  sendUpdateToParent(fields){
    const selectedEvent = new CustomEvent("enachchange", {detail:fields});
    this.dispatchEvent(selectedEvent);
  }
  async updateRecordDetails(fields) {
    const recordInput = { fields };
    console.log("before update ", recordInput);
    await updateRecord(recordInput)
      .then(() => {
        this.showToast('Data Saved Successfully','success');//Toast Message Updated by Rajasekar as part of CISP-22313
      })
      .catch((error) => {
        console.log("record update fail in catch", JSON.stringify(fields));
        console.log("record update Fields: ", fields);
        console.log("record update error", error);
      });
  }
  handleENACHSubmit(){
    updateLoanTransaction({loanApplicationId:this.recordId,module:POST_SANCTION_CHECKS_AND_DOCUMENTATION, dealId : this.dealId})
    .then(()=>{
      this.isReadOnly = true;
      this.showToast('Data Saved Successfully','success');//Toast Message Updated by Rajasekar as part of CISP-22313
    })
    .catch((error)=>{
      console.log('submitENACH error '+error);
    })
  }

  handleFieldChange(event){
    const fieldName = event.target.name;
    if (fieldName === "repaymentCapturedCorrectly") {
      this.repaymentCapturedCorrectly=event.target.value;
    }
    if (fieldName === "repaymentRemarks") {
      this.repaymentRemarks=event.target.value;
    }
  }

  handlePreDisbursementSubmit(){
    const repaymentFIELDS = {};
    repaymentFIELDS[REPAYMENT_DETAILS_ID.fieldApiName] = this.repaymentsId;
    repaymentFIELDS[Repayment_Remarks__c.fieldApiName] = this.repaymentRemarks;
    repaymentFIELDS[Repayments_Captured_Correctly__c.fieldApiName] =this.repaymentCapturedCorrectly;
    this.updateRecordDetails(repaymentFIELDS);
    updateLoanTransaction({loanApplicationId:this.recordId,module:PRE_DISBURSEMENT_CHECK})
    .then(()=>{
      this.showToast('Data Saved Successfully','success');//Toast Message Updated by Rajasekar as part of CISP-22313
      this.isReadOnly = true;
    })
    .catch((error)=>{
      console.log('handlePreDisbursementSubmit error '+error);
    })
  }
  startCountDown() {
    let timerId = setInterval(() => {
      //Added by Rajasekar as part of CISP-22313 - Starts
      if((this.timeLeft%RETRIGGER_STATUS_CHECK_FREQUENCY_TIME) == 0){
        console.log('Inside status check frequency block. Current time left : ',this.timeLeft);
        this.checkEnachResponseStatus(timerId);//Added logic to check the status of the response in specific time frequency and then clear timeout and show the 'Initiate E-nach' button enabled or disabled based on the response
      }
      //Added by Rajasekar as part of CISP-22313 - Ends
      if(this.timeLeft == 0) {
        clearTimeout(timerId);
        this.showTimer = false;
        //this.sendLinkButtonDisabled = false;
        this.disableInitiateENACH = false;
        this.timeLeft = RETRIGGER_TIME; //Reset timer
      } else {
        this.timeLeft--;
        //Added by Rajasekar as part of CISP-22313 - Starts
        this.timeLeftInMins = '0'+Math.trunc(this.timeLeft/60);
        let timeLeftInSecsWithFraction = (this.timeLeft%60).toString();
        this.timeLeftInSecs = timeLeftInSecsWithFraction.length == '2' ? timeLeftInSecsWithFraction : '0'+timeLeftInSecsWithFraction;
        //Added by Rajasekar as part of CISP-22313 - Ends
      }
    }, 1000);
  }
  gotoFinalOfferPage() {
    const evt = new CustomEvent('gotofinalofferpage');
    this.dispatchEvent(evt);
  }
  
  /**This method is added by Rajasekar as part of CISP-22313
   **This js method will check the status of the response and then clear timeout and show/hide the 'Initiate E-nach' button based on the response**/
   checkEnachResponseStatus(timerId) {
    console.log('Inside checkEnachResponseStatus js method. timerId : ',timerId);
    displayRepaymentInfo({ loanAppId: this.recordId ,dealId:this.dealId})
        .then((result) => {
        console.log('Inside checkEnachResponseStatus js method. result : ',result);
        if (result != null) {
            this.eNachStatus=result.E_NACH_API_Status__c;
            this.eNachMessage=result.Message__c;
            if(result.E_NACH_API_Status__c != '' && result.E_NACH_API_Status__c != null && result.E_NACH_API_Status__c != undefined){
              this.isENachStatusShow=true;
            }
            if(result.Message__c != '' && result.Message__c != null && result.Message__c != undefined){
              this.isENachMessageShow=true;
            }
            if(this.eNachStatus==='ENACH Registration Success'){
              console.log('Inside checkEnachResponseStatus js method. status success ');
              clearTimeout(timerId);
              this.showTimer = false;
              this.isENACHSubmitVisible=true;
              this.disableInitiateENACH = true;
            }else if(this.currentStep == 'final-offer' && this.eNachStatus === 'In Progress'){
              console.log('Inside checkEnachResponseStatus js method. status in progress ');
              this.showENACHSubmitButton=true;
            }else if(this.currentStep != 'final-offer' && this.eNachStatus === 'ENACH Registration Failed') {
              console.log('Inside checkEnachResponseStatus js method. status failed ');
              clearTimeout(timerId);
              this.showTimer = false;
              this.disableInitiateENACH = false;
            }
          }
        })
        .catch((error) => {
          this.error = error;
          console.log("Error in checkEnachResponseStatus Function ::" + error);
        });
    }
}