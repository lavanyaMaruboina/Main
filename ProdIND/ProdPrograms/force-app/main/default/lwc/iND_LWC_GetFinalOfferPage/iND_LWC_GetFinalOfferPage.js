import { LightningElement, wire, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { updateRecord } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';
import getApplicantDetails from '@salesforce/apex/IND_GetFinalOfferDetails.getApplicantDetails';
import getFinalOfferDetailsFromApex from '@salesforce/apex/IND_GetFinalOfferDetails.getFinalOfferDetails'; // Get Final Offer Details
import getFinalOfferDetailsForTractor from '@salesforce/apex/IND_GetFinalOfferDetails.getFinalOfferDetailsForTractor'; // Get Final Offer Details


// import a method to send a mail of sanction the loan
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import triggerSanctionCommunicationFromApex from '@salesforce/apex/IND_GetFinalOfferDetails.triggerSanctionCommunication';
import d2cSanctionCommunication from '@salesforce/apex/D2C_IntegrationEngine.doSanctionCommunicationCallout';
import getDisabledBtn from '@salesforce/apex/IND_GetFinalOfferDetails.getDisabledBtn';
import initilizeEmailRequestWrapper from '@salesforce/apex/IND_GetFinalOfferDetails.initilizeEmailRequestWrapper';
import isConsentReceived from '@salesforce/apex/IND_GetFinalOfferDetails.isConsentReceived';
import getOppRecord from '@salesforce/apex/IND_GetFinalOfferDetails.getOppRecord';

// import custom labels
import SanctionCriteriaErrorMsg from '@salesforce/label/c.SanctionCriteriaErrorMsg';
import SanctionFinalTermErrorMsg from '@salesforce/label/c.SanctionFinalTermErrorMsg';
import SanctionApprovalMsg from '@salesforce/label/c.SanctionApprovalMsg';

import doEmailServiceCallout from '@salesforce/apexContinuation/IntegrationEngine.doEmailServiceCallout';
import doSmsCallout from '@salesforce/apexContinuation/IntegrationEngine.doSmsGatewayCallout';

import APPLICATION_FORM_SMS_SENT from '@salesforce/schema/Applicant__c.Application_Form_SMS_Sent__c';
import APPLICANT_ID from '@salesforce/schema/Applicant__c.Id';
import INSURANCE_CONSENT_SENT from '@salesforce/schema/Applicant__c.Insurance_Consent_OTP_Time__c';
import APPLICANT_INSURANCECONSENTOTP from '@salesforce/schema/Applicant__c.Insurance_Consent_OTP__c';
import APPLICANT_APPLICATIONCONSENTOTP from '@salesforce/schema/Applicant__c.Application_Consent_OTP__c';

import CONSENT_SENT_SUCCESSFULLY from '@salesforce/label/c.Consent_Sent_Successfully';

//Modified for D2C by Rohan
import { getRecord } from 'lightning/uiRecordApi';
import OPP_LEAD_SORCE from '@salesforce/schema/Opportunity.LeadSource';
//End of D2C Code

import OPP_PRODUCT_TYPE from '@salesforce/schema/Opportunity.Product_Type__c';
import getRecentEMIdetails from '@salesforce/apex/InstallmentScheduleController.getRecentEMIdetails';



export default class IND_LWC_GetFinalOfferPage extends NavigationMixin(LightningElement) {
  @api recordId;
  @track finalOfferDetails;
  @track disableTriggerBtn;
  @track disabledSubmitBtn;
  source='';
  @track isTractor = false;
  disableInsSchedule=false;
  isModalOpen=false;
  isInsSubmitted=false;
  disableInsSchedule=false;
  isModalOpen=false;
  isInsSubmitted=false;

  //Added for D2C
  @wire(getRecord, { recordId: '$recordId', fields: [OPP_LEAD_SORCE, OPP_PRODUCT_TYPE] })
  opportunity({ error, data }) {
    if (data) {
      this.source=data.fields.LeadSource.value;
      this.isTractor = data.fields.Product_Type__c.value == 'Tractor' ? true : false;
        
    } else if (error) {
       console.log('error-->'+JSON.stringify(error));
    }
  }
//end of D2C code
  get getDisableTriggerBtn() {
    let disableTriggerBtn = !this.disabledAppConsentBtn || !this.disabledInsuranceConsentBtn || this.disableTriggerBtn || this.isJourneyStatusStop || this.source==='D2C';
    console.log('disableTriggerBtn --> ', disableTriggerBtn);
    this.disableTriggerBtn = disableTriggerBtn;
    return disableTriggerBtn;
  }
  submitDisabled = false;
  get getDisabledSubmitBtn(){
    let disabledSubmitBtn = !this.disabledAppConsentBtn || !this.disabledInsuranceConsentBtn || (!this.disableTriggerBtn && !this.isTractor) || (this.disabledSubmitBtn && !this.isTractor) || (this.submitDisabled && this.isTractor) || this.isJourneyStatusStop;
    console.log('disabledSubmitBtn --> ', disabledSubmitBtn);
    this.disabledSubmitBtn = disabledSubmitBtn;
    return disabledSubmitBtn;
  }
  @track emailRequestWrapperList;
  disabledInsuranceConsentBtn;
  disabledAppConsentBtn;
  consentReceivedWrapperList;
  @track isJourneyStatusStop;
  @api isRevokedLoanApplication;//CISP-2735
  intervalId
  @track consentDetails = {};
  __consentdata
  @wire(getApplicantDetails, {loanId : '$recordId' })
  wiredgetConsent(result){
    this.__consentdata = result;
    if(result.data){
      this.consentDetails = JSON.parse(JSON.stringify(result.data));
      if(!(this.consentDetails.applicationformconsent).includes('- NA') && !(this.consentDetails.applicationformconsent).includes('- Pending')){
       this.disabledAppConsentBtn = true;
      }
      if(!(this.consentDetails?.insuranceformconsent).includes('- Pending')){ 
        this.disabledInsuranceConsentBtn = true;
      }
      if(!(this.consentDetails.applicationformconsent).includes('- Pending') && !(this.consentDetails.applicationformconsent).includes('- NA') && !(this.consentDetails?.insuranceformconsent).includes('- Pending')){     
        clearInterval(this.intervalId);
      }
    }
    if(result.error){
      console.error('error from getApplicantDetails ',result);
    }
  }
  disconnectedCallback() {
    clearInterval(this.intervalId);
  }
  async connectedCallback() {
    let res = await getOppRecord({'loanId' : this.recordId});
    if(res && res.length > 0 && res[0].Product_Type__c == 'Tractor'){
      this.isTractor = true;
    }
    await getRecentEMIdetails({loanId:this.recordId}).then((data)=>{
      if(data && data.length>0){
         this.disableInsSchedule = false;
      }else{
         this.disableInsSchedule = true;
      }
   }).catch((error) => { console.log('error in getRecentEMIdetails ',error);});
    this.intervalId = setInterval(() => {
      refreshApex(this.__consentdata);
    }, 5000);
  await Promise.resolve();
    console.log('Product_Type__c '+this.isTractor)
    if(this.isTractor){
      
      await getFinalOfferDetailsForTractor({ loanId : this.recordId }).then(data => {
        if (data != null || data != undefined) {
          this.finalOfferDetails = data;
          console.log('data-->',JSON.stringify(data));
          if(data.JourneyStatus == 'Stop'){
            console.log('JourneyStatus-->',data.JourneyStatus);
            this.disabledAppConsentBtn = true;
            this.disabledInsuranceConsentBtn = true;
            this.isJourneyStatusStop = true;
          }
          else{
            console.log('JourneyStatus Else-->',data.JourneyStatus);
            this.isJourneyStatusStop = false;
          }
        }
      }).catch(error => {
        console.error('getFinalOfferDetailsForTractor error: ' , error);
      });
    }
    else{
   await getFinalOfferDetailsFromApex({ loanId : this.recordId }).then(data => {
      if (data != null || data != undefined) {
        this.finalOfferDetails = data;
        console.log('data-->',JSON.stringify(data));
        if(data.JourneyStatus == 'Stop'){
          console.log('JourneyStatus-->',data.JourneyStatus);
          this.disabledAppConsentBtn = true;
          this.disabledInsuranceConsentBtn = true;
          this.isJourneyStatusStop = true;
        }
        else{
          console.log('JourneyStatus Else-->',data.JourneyStatus);
          this.isJourneyStatusStop = false;
        }
      }
    }).catch(error => {
      console.error('getFinalOfferDetailsFromApex error: ' , error);
    });
  }
  
    console.log('isJourneyStatusStop-->',this.isJourneyStatusStop);
   if(this.isJourneyStatusStop == false){
    isConsentReceived({loanApplicationId : this.recordId}).then(result => {
      this.consentReceivedWrapperList = result;
      //CISP-2665-START
      if(this.isTractor){
        let vehicleWrapperList = this.consentReceivedWrapperList.length > 0 ? this.consentReceivedWrapperList[0].vehicleListWrapper : [];
        if (vehicleWrapperList.length > 0) {
          let vehicleObj = vehicleWrapperList[0];
          if(vehicleObj && vehicleObj.Insurance_Details__r && vehicleObj.Insurance_Details__r.length > 0){
            this.disabledInsuranceConsentBtn = false
          }
        }else{
          this.disabledInsuranceConsentBtn= true;
        }
      }else{
      let insuranceConsentReceivedApplicant = this.consentReceivedWrapperList.filter(applicant => !applicant.insuranceConsentReceived);
      if(insuranceConsentReceivedApplicant.length > 0){this.disabledInsuranceConsentBtn = false;}else{this.disabledInsuranceConsentBtn= true;}
      }
      let applicationConsentReceivedApplicant = this.consentReceivedWrapperList.filter(applicant => !applicant.applicationConsentReceived);
      if(applicationConsentReceivedApplicant.length > 0){this.disabledAppConsentBtn = false;}else{this.disabledAppConsentBtn = true;}
      //CISP-2665-END
    }).catch(error => {
      console.log('isConsentReceived error: ' , error);
    });
   }
  if(!this.isTractor){
    initilizeEmailRequestWrapper({ loanAppId: this.recordId }).then(data => {
      if (data) {
        this.emailRequestWrapperList = data;
      }
    }).catch(error => {
      console.error('Error in initilizeEmailRequestWrapper: ' , error);
    });
  }
    

    this.getDisabledBtnFromApex();
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
  }//CISP-2735-END

  // getter for finalOfferDetails
  get getFinalOfferDetails() {
    return this.finalOfferDetails;
  }

  // getter for finalOfferDetails show to user
  get getFinalOfferDetailflag() {
    return (this.finalOfferDetails != null || this.finalOfferDetails != undefined) ? true : false;
  }

  // getter for Make + Model + Variant;
  get getMMVDetails() {
    let makeModelVariant = this.getFinalOfferDetails.makeModelVariant == undefined ? '' : this.getFinalOfferDetails.makeModelVariant;
    return makeModelVariant;
  }

  getDisabledBtnFromApex() {
    getDisabledBtn({ loanAppId: this.recordId }).then(result => {
      console.log('getTriggerBtnDisabled result: ' , result);
      this.disableTriggerBtn = result.triggerDisabled;
      this.disabledSubmitBtn = result.submitDisabled;
      this.submitDisabled = result.submitDisabled;
    }).catch(error => {
      console.error(error);
    });
  }

  handleSubmit(event) {
    try {
      //Modified by Rohan for D2C

      if (!this.isTractor && !this.isInsSubmitted && !this.disableInsSchedule) {
        const event = new ShowToastEvent({
            title: 'Warning',
            message: 'Submit Installment Schedule first',
            variant: 'Warning'
        });
        this.dispatchEvent(event);
        return;
      }

      this.disabledSubmitBtn = true;
      // Prevent Default
      event.preventDefault();
      if(this.source==='D2C' || this.isTractor){
        this.triggerSanctionCommunicationBtnHandler();
      }
      else{
        this.disabledSubmitBtn = true;
      const selectedEvent = new CustomEvent('sanctionofapplicationevent', { detail: 'Sanction of Application' });
      // Dispatches the event.
      this.dispatchEvent(selectedEvent);
    }
    } catch (error) {
      console.error(error);
    }
  }

  triggerSanctionCommunicationBtnHandler(event) {
    try {
      triggerSanctionCommunicationFromApex(
        { loanAppId: this.recordId }
      ).then((result) => {
        if ((result.includes('false') || result.includes('finaltermmissing')) && result.length > 0) {
          const event = new ShowToastEvent({
            title: '',
            message: result.includes('finaltermmissing') == false ? `${SanctionCriteriaErrorMsg}` : `${SanctionFinalTermErrorMsg}`,
            variant: 'error',
            mode: 'dismissable'
          });
          this.dispatchEvent(event);
          if(this.source==='D2C'){
            this.disabledSubmitBtn = false;
          }
        } else if (!result.includes('approved') && result.length > 0) {
          const event = new ShowToastEvent({
            title: '',
            message: `${result[0]}`,
            variant: 'error',
            mode: 'dismissable'
          });
          this.dispatchEvent(event);
          if(this.source==='D2C'){
            this.disabledSubmitBtn = false;
          }
        } else if (result.includes('approved')) {

          if(this.isTractor){
            this.disabledSubmitBtn = true;
            this.showToastNotification('', 'Screen Submitted Successfully', 'success', 'dismissable');

            const selectedEvent = new CustomEvent('sanctionofapplicationevent', { detail: 'Sanction of Application' });
            // Dispatches the event.
            this.dispatchEvent(selectedEvent);
          }
          else{
          this.showToastNotification('', `${SanctionApprovalMsg}`, 'success', 'dismissable');
          this.disableTriggerBtn = true;
          this.disabledSubmitBtn = false;
          if(this.source==='D2C'){
            this.disabledSubmitBtn = true;
            const selectedEvent = new CustomEvent('sanctionofapplicationevent', { detail: 'Sanction of Application' });
            d2cSanctionCommunication(
              { loanAppId: this.recordId }).then(result=>{
              }).catch(error=>{
                console.log('error in d2c sanction communication ',error)
              })
            // Dispatches the event.
            this.dispatchEvent(selectedEvent);
          }
          console.log('result', this.emailRequestWrapperList);
          this.emailRequestWrapperList.forEach(emailRequestWrapper => {
            doEmailServiceCallout({emailService : JSON.stringify(emailRequestWrapper)}).then(result=>{
            }).catch(error=>{
              console.error('error in email service callout ',error);
            });
          });
        }
        
        }
      }).catch((error) => {
        this.showToastNotification('Error', `${error?.body?.message}`, 'error', 'dismissable');//CISP-2495
        console.error('error --> ', error);
        if(this.source==='D2C'){
          this.disabledSubmitBtn = false;
        }
      });
    } catch (error) {
      console.error(error);
      if(this.source==='D2C'){
        this.disabledSubmitBtn = false;
      }
    }
  }

  triggerApplicationFormConsentHandler(event) {
    try {
      if (this.isTractor &&  this.disableFormButtons) {
        const event = new ShowToastEvent({
            title: 'Warning',
            message: 'Submit Installment Schedule first of all the Assets.',
            variant: 'Warning'
        });
        this.dispatchEvent(event);
        return;
      }

      this.consentReceivedWrapperList.forEach(consentReceivedWrapper => {
        if (consentReceivedWrapper.applicationConsentReceived == false) {
            this.sendConsentReceived(consentReceivedWrapper.applicantId,'LAS');
        }
      });
    } catch (error) {
      console.error('triggerApplicationFormConsentHandler error --> ', error);
    }
  }

  triggerInsuranceConsentHandler(event) {
    try {
      if (this.isTractor &&  this.disableFormButtons) {
        const event = new ShowToastEvent({
            title: 'Warning',
            message: 'Submit Installment Schedule first of all the Assets.',
            variant: 'Warning'
        });
        this.dispatchEvent(event);
        return;
      }

      if(this.isTractor && this.consentReceivedWrapperList && this.consentReceivedWrapperList.length > 0){
        let vehicleWrapperList = this.consentReceivedWrapperList[0].vehicleListWrapper;
        if (vehicleWrapperList.length > 0) {
          let vehicleObj = vehicleWrapperList[0];
          if(vehicleObj && vehicleObj.Insurance_Details__r && vehicleObj.Insurance_Details__r.length > 0){
            let  insuranceObj = vehicleObj.Insurance_Details__r[0];
            this.sendConsentReceived(insuranceObj.Applicant__c,'INC');
          }
        }
      }else{
      this.consentReceivedWrapperList.forEach(consentReceivedWrapper => {
        if (consentReceivedWrapper.insuranceConsentReceived == false) {
            this.sendConsentReceived(consentReceivedWrapper.applicantId,'INC');
        }
      });
      }
    } catch (error) {
      console.error('triggerInsuranceConsentHandler error --> ', error);
    }
  }

  async sendConsentReceived(appid, flag) {
    console.log('type of message' + flag);
    console.log('Applicant record Id :' + appid);

    let otpValue;
    //Updating the applicant record with consent fields
    const tDatetime = new Date().toISOString();
    const fields = {};
    fields[APPLICANT_ID.fieldApiName] = appid;

    if (flag == 'LAS') {
        let applicationRanNum = Math.floor(Math.random() * 10000);
        otpValue = applicationRanNum;
        fields[APPLICATION_FORM_SMS_SENT.fieldApiName] = tDatetime;
        fields[APPLICANT_APPLICATIONCONSENTOTP.fieldApiName] = String(applicationRanNum);
    }
    if (flag == 'INC') {
        let insRandNum = Math.floor(Math.random() * 10000);
        otpValue = insRandNum;
        fields[INSURANCE_CONSENT_SENT.fieldApiName] = tDatetime;
        fields[APPLICANT_INSURANCECONSENTOTP.fieldApiName] = String(insRandNum);
    }

    const recordInput = { fields };
    await updateRecord(recordInput)
        .then(() => {
            console.log('Applicant record updated', recordInput);
            let smsRequestString = {
                'applicantId': appid,
                'loanApplicationId': this.recordId,
                'flag': flag,
                'otpForInsConsent': otpValue
            };

            console.log('smsRequestString :', smsRequestString);
            doSmsCallout({ //await
                smsRequestString: JSON.stringify(smsRequestString)
            })
                .then(smsresult => {
                  console.log('smsresult : ', smsresult);
                    if (smsresult == 'SUCCESS') {
                        const event = new ShowToastEvent({
                          title: 'Success',
                          message: CONSENT_SENT_SUCCESSFULLY,
                          variant: 'success',
                        });
                        this.dispatchEvent(event);
                        this.getDisabledBtnFromApex();
                    }
                })
                .catch(error => {
                    this.error = error;
                    console.log('Consent ERROR' + JSON.stringify(error));
                });

        })
        .catch((error) => {
            this.error = error;
            console.log('Applicant record failed to update', recordInput);
        })
  }

  showToastNotification(title, message, variant, mode) {
    const event = new ShowToastEvent({
      title: `${title}`,
      message: `${message}`,
      variant: `${variant}`,
      mode: `${mode}`
    });
    this.dispatchEvent(event);
  }

  handleInstallmentSchedule(){this.isModalOpen=true;}
  handleCloseModal(){this.isModalOpen=false;}
  handleInsSubmit(){this.isModalOpen=false;this.isInsSubmitted = true;}
  isModalOpenForTractor = false;vehicleObjId;
  handleInstallmentScheduleForTractor(event){
    this.vehicleObjId = event.target.value;
    this.isModalOpenForTractor=true;
  }
  async closeModal() {
    this.isModalOpenForTractor = false; 
    //check if installment schedule is submitted now , and if submitted then dont show the validation
    try {
      this.disableFormButtons = await checkDisableFormButtons({ loanApplicationId: this.recordId });
      console.log('disableFormButtons: ' + this.disableFormButtons);
    } catch (error) {
      console.error('Error checking Final Term records: ', error);
    }
  }
}