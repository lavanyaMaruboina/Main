import { LightningElement ,track,api} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import FORM_FACTOR from '@salesforce/client/formFactor';
import aadharOCR from '@salesforce/apex/LwcLOSLoanApplicationCntrl.aadharOCR';

export default class LightningExampleLayoutItemDefault extends LightningElement {
   @track templateScanManuallyOptions = false;
   @track templateScanAndUploadOptions = false;
   @track templateAadharNumberField = false;
   @track templateSubmitButton = false;
   @track templateKYCFields = false;
   @track templateBiometricOTPOptions = false;
   @track modalPopUpToggleFlag = false;
   @track disableOCRButton=false;
   @track disableAadharField = true;
   @track disableSubmitButton=true;
   @track disableUploadButton=true;
   @api PopupOTPForSubmit=false;
   @track salutionOptions = [
      {value: 'Mr', label: 'Mr'},
      {value: 'Mrs', label: 'Mrs'}
   ];
   @api myRecordId;

   @track GenderOptions = [
         { label: 'Male', value: 'Male' },
         { label: 'Female', value: 'Female' },
      ];

@track modalPopUpCaptureImage=false;
   handleSubmitClick(){
      this.modalPopUpCaptureImage=true;
   }

   captureCustomerImageClose() {
      this.modalPopUpCaptureImage = false;
  }

  captureImageDone(){
   this.modalPopUpCaptureImage = false;
  }

  captureCustomerImageClose(){
   this.modalPopUpCaptureImage = false;  
  }

  handleUploadFinished(event) {
   //Get the list of uploaded files
      const evt = new ShowToastEvent({
         title: 'Uploaded',
         message: "Aadhar Uploaded Successfully",
         variant: 'success',
         
      });
      this.dispatchEvent(evt);
}

   //Labels of Radio Buttons
   get aadharBiometicOTP() {
   return [
   { label: 'Biometric/OTP', value: 'Biometric/OTP' },
   { label: 'Scan and Upload', value: 'ScanAndUpload' },
   ];
   }

   get acceptedFormats() {
      return ['.jpg', '.png','.jpeg'];
  }

   get wayOfCapturingAadhar() {
      return [
      { label: 'Scan Aadhar', value: 'ScanAadhar' },
      { label: 'Manually Enter', value: 'ManuallyEnter' },
      ];
      }

   get wayOfSelectingBiometricOtp() {
      return [
      { label: 'Biometric', value: 'Biometric' },
      { label: 'OTP', value: 'OTP' },
      ];
      }

   //Start: This function shows Biometric/OTP  and ScanAndUpload radio button
   biometricOTPSelectAndUpload(){
   const selectedValue = this.template.querySelectorAll('lightning-radio-group');
   if(selectedValue[0].value=='Biometric/OTP'){
   this.templateScanManuallyOptions=true;
   this.templateScanAndUploadOptions = false;
   this.templateAadharNumberField = false;
   this.templateSubmitButton = false;
   this.templateKYCFields = false;
   this.templateBiometricOTPOptions = false;
   this.disableOCRButton = true;
   this.disableUploadButton=true;
   }
   else if(selectedValue[0].value=='ScanAndUpload'){
   this.templateScanManuallyOptions=false;
   this.templateScanAndUploadOptions = true;
   this.templateAadharNumberField = false;
   this.templateSubmitButton = false;
   this.templateKYCFields = true;
   this.templateBiometricOTPOptions = false;
   this.disableUploadButton=false;
   }
   }
   //End: This function shows Biometric/OTP  and ScanAndUpload radio button

   //Aadhar Number field validation
   aadharEntered;

   validateAadhar(event){
      this.templateSubmitButton=true;
      var regexp= /^[2-9]{1}[0-9]{11}$/;      
      var aadharvalue=event.target.value;
      this.aadharEntered = event.target.value;
      
      const aadharComp = this.template.querySelector('[data-id="aadharNumber"]');
   
      if(aadharvalue.length == 12 && regexp.test(aadharvalue)){
         this.templateBiometricOTPOptions = true;
         aadharComp.setCustomValidity("");
      }
      else{
         this.templateBiometricOTPOptions = false;
         aadharComp.setCustomValidity("Not a valid Aadhar Number");
      }
      aadharComp.reportValidity();
   }

   //On focus shows the Original Aadhar value
   showAadharNo(event){
      event.target.value= this.aadharEntered;
   }

   //On blur show the masked value
   blurAadharNo(event){
      var temp = event.target.value;   
      if(temp.length == 12){ 
         //temp = temp.replace(/^[2-9]{1}[0-9]{11}$/, "************");
         var prefix = temp.substr(0, temp.length - 4);
         var suffix = temp.substr(-4);
         var masked = prefix.replace(/\d/g, '*');
         var a = masked + suffix
         event.target.value= a;
      }
   }

   //To find out User's Form Factor
   connectedCallback() {
   console.log('The device form factor is: ' + FORM_FACTOR); 
   }

   //Start: 'Scan Aadhar' radio button's different options on the basis of Devices
   scanManualRadioOptions='';
   changeOCRSection(){
   const selectedValue = this.template.querySelectorAll('lightning-radio-group');
   this.scanManualRadioOptions = selectedValue[1].value;
   if(selectedValue[1].value=='ScanAadhar'){
   this.templateAadharNumberField=true;
   this.templateBiometricOTPOptions=false;
   this.templateSubmitButton=true;
   this.disableOCRButton = false;
   this.disableAadharField=true;

   if(FORM_FACTOR=='Large')
   {
   //LOW_LOS_DocUpload component will be called here.
   this.disableUploadButton=false;
   this.disableSubmitButton=true;
   }
   else if(this.FORM_FACTOR=='Small')
   {
      //call the deep-link and redirect user to the Capture screen component.
   }
   }

   else if(selectedValue[1].value=='ManuallyEnter'){
      console.log('in manually '+selectedValue[1].value);
   this.templateAadharNumberField = true;
   this.disableAadharField = false;
   this.disableSubmitButton=true;
   this.disableOCRButton = true;
   this.disableUploadButton=true;
   }
   }
   //End: 'Scan Aadhar' radio button's different options on the basis of Devices

   //Start: handleOCR() perform differently on the basis of JSON response for OCR button
   handleOCR(){
   aadharOCR({loanApplicationId : '006710000012CfdAAE'}).then(result =>{
         let response = JSON.parse(result);
         console.log("print " + this.response+ " space   "+response);
         if(response.status == 'true' && response.apistatus == 'true' ){
         this.templateAadharNumberField=true;
         this.disableAadharField=true;
         this.disableOCRButton=true;
         var temp='234523452345';
         var prefix = temp.substr(0, temp.length - 4);
         var suffix = temp.substr(-4);
         var masked = prefix.replace(/\d/g, '*');
         var a = masked + suffix;
         this.aadharEntered=a;
         const aadharComp = this.template.querySelector('[data-id="aadharNumber"]');
         if(aadharComp!=null){
         this.templateBiometricOTPOptions = true;
         }
        }
         else if(response.status  == 'false' && response.apistatus == 'true'){
         this.disableOCRButton=true;
         const evt = new ShowToastEvent({
            title: 'Message',
            message: 'Check the Aadhar Number',
            variant: 'error'
         });
         this.dispatchEvent(evt);
         }
         else if(response.status  == 'false' && response.apistatus == 'false'){
            //Allow user to retry for certain time and show the message
         this.templateScanManuallyOptions=true;
         this.templateAadharNumberField=false;
         this.templateSubmitButton=false;
         const evt = new ShowToastEvent({
         title: 'Message',
         message: 'Request Timeout',
         variant: 'error'
      });
      this.dispatchEvent(evt);
         }
   })
   .error(error =>{
         this.error = error;
   });
   }
   //End: handleOCR() perform differently on the basis of JSON response for OCR button

   //Start: Enables Submit button for Biometric or OTP selection
   finalValue = ''
   changeBiometricOtp(){
      const selectedValue = this.template.querySelectorAll('lightning-radio-group');
      const aadharComp = this.template.querySelector('[data-id="aadharNumber"]');
      this.finalValue = selectedValue[2].value;
      this.templateSubmitButton=true;

      if(selectedValue[2].value=='Biometric' || selectedValue[2].value=='OTP'){
      this.disableSubmitButton = false;
      this.templateKYCFields = false;
   }
   }
   //End: Enables Submit button for Biometric or OTP selection

   //Start: This function creates Popup on click of Submit button
   modalPopUpToggleFlag = false;
   submitOtp(){
      console.log(this.scanManualRadioOptions+' '+this.finalValue);
         if(this.scanManualRadioOptions=='ScanAadhar' && this.finalValue=='Biometric'){
            this.modalPopUpToggleFlag = false;
            this.templateKYCFields = true;
         }
         else if(this.scanManualRadioOptions=='ScanAadhar' && this.finalValue=='OTP'){
            this.modalPopUpToggleFlag = false;
            this.templateKYCFields = true;
            this.PopupOTPForSubmit=true;
         }
         else if(this.scanManualRadioOptions=='ManuallyEnter'){
            this.modalPopUpToggleFlag = true;
            this.templateKYCFields = false;    
            this.disableAadharField=true; 
         }
   }
   //End: This function creates Popup on click of Submit button

   //Change value back to false for Submit(Yes/No) Popup
   closeModal() {
      this.modalPopUpToggleFlag = false
      }

      correctAadharYes(){
         this.templateKYCFields=true;
         this.disableSubmitButton=true;
         
         if(this.finalValue == 'Biometric'){
            //Redirect user to the Biometric capture deep link
            this.modalPopUpToggleFlag = false;
         }
         else if(this.finalValue == 'OTP'){
            this.modalPopUpToggleFlag = false;
            console.log("first   :"+this.PopupOTPForSubmit);
            this.PopupOTPForSubmit=true;
            console.log("second...   : "+this.PopupOTPForSubmit);
         }
      }

      wrongAadharNo(){
         this.modalPopUpToggleFlag = false;
         this.templateBiometricOTPOptions = true;
         this.templateSubmitButton=true;
         this.templateKYCFields=false;
         this.skipBioOtpFlag=true;
         this.disableAadharField=false;
      }

      handleSectionToggle(event) {
         const openSections = event.detail.openSections;
         if (openSections.length === 0) {
               this.activeSectionsMessage = 'All sections are closed';
         } else {
               this.activeSectionsMessage ='Open sections: ' + openSections.join(', ');
         }
      }

   //Opens KYC detils fields with auto filled details.
   submitKycDetails(event){
      this.section6 = true;
   }


   //Added by Ruchi Jain
   @api id='a015g00000YzqPnAAJ';
      openCancelPopUP=false; //for opening/closing of QuitPop-up
      
      //handleCancel method for opening QuitPop-up
         handleCancel(){
            this.openCancelPopUP=true;
         }
         closepopup(){
            this.openCancelPopUP=false;
         }
   //navigate
   navigateToLightningComponent() {
         this[NavigationMixin.Navigate]({
            "type": "standard__component",
            "attributes": {
               
               "componentName": "c__AuraQuitPopUp"
            }
         });
         this.kycDelete();
   }

         //kycDelete method for deleting document and fields
         kycDelete(){

         this.template.querySelector('lightning-input').reset();
            kycDelete({LoanApplicationId: this.id})
            .then(result => {
               console.log("here2");
            })
            .catch(error => {
               this.error = error;
               console.log("error came");
               console.log(this.error);
            });
         }
      handleDone(){
         if(this.template.querySelector('Golden-Source').disabled==true && this.template.querySelector('Doc-Auth').disabled==true && this.template.querySelector('OCR').disabled==true && 
         this.template.querySelector('lightning-input').value!=null )
         {
            if(this.template.querySelector('DL').getTime<Today.getTime+30)
            {
            const evt = new ShowToastEvent({
               title: 'Error',
               message: 'Please recapture alternate KYC by clicking on Cancel',
               variant: 'error',
            });
            this.dispatchEvent(evt);
            }
            this.navigateToLightningComponent();
         }
      }
}