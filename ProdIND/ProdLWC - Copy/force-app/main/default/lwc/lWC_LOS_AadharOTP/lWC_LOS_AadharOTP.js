import { LightningElement, api, track} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import verifyAadharOTP from '@salesforce/apex/LwcLOSLoanApplicationCntrl.verifyAadharOTP';
import resendAadharOTP from '@salesforce/apex/LwcLOSLoanApplicationCntrl.resendAadharOTP';
import doUidaiOTPCallout from '@salesforce/apexContinuation/IntegrationEngine.doUidaiOTPCallout'; 
import doUidaiOTPVerifyCallout from '@salesforce/apex/IntegrationEngine.doUidaiOTPVerifyCallout2';
import saveImagetoSF from '@salesforce/apex/IntegrationUtilities.saveImagetoSF';
// import saveTKNId from '@salesforce/apex/IntegrationUtilities.saveTKNID';

//This class generates OTP Popup for KYC Type: Aadhar and verify if User enterd and Sytem generated OTP are same
export default class LWC_LOS_AadharOTP extends LightningElement {
    generatedOTP;
    enteredOTP;
    resentOtpStatus;
    @api otpMatch;
    @api generateotppopup = false;
    @track currentOppRecordId;
    @track disableResendButton = true;
    @track disableVerifyButton = true;
    @track disableGenerateOtpButton = false;
    @track delaytime;
    @track checkaadharpopup=false;
    @api currentdocumentid;
    @api kycaadharno;
    @api applicantid;
    @api loanapplicationd;
    @track isSpinnerMoving = false;
    @track uidaiTXN;
    @track uidaiRRN;
    @api prodtype;
    @api bmdsensorno;//CISP-15413
    @track tryCatchError;
    //Start: handleGenerateOtpClick() fetches generated OTP stored in current Loan Applicant object
    handleGenerateOtpClick(){
        this.isSpinnerMoving=true;
        console.log('aadhar no ',this.kycaadharno);
        let uidaiGenerateOtpRequest = {
            'aadhaarNo': this.kycaadharno,
            'applicantId' : this.applicantid,
            'loanApplicationId' : this.loanapplicationd
            };
        
        console.log('uidai otp Req==>',uidaiGenerateOtpRequest);

        doUidaiOTPCallout({'kycUidaiRequestString': JSON.stringify(uidaiGenerateOtpRequest)}) //'a0U710000008cg1EAA'
        .then(result => {
            this.isSpinnerMoving=false;
            this.generateotppopup = true;
            const obj = JSON.parse(result);
            const objJson = JSON.parse(obj);
            console.log('UIDAI OTP API Resposne Parsed :==>',objJson, objJson.kycResponse.TransactionInfo.ResponseMsg);
            if(objJson.kycResponse.TransactionInfo.ResponseMsg==='Approved') {
                this.disableResendButton = false;
                this.disableVerifyButton = false;
                this.disableGenerateOtpButton=true;
                const evt = new ShowToastEvent({
                    title: "OTP Sent",
                    message: "OTP Sent Successfully!",
                    variant: 'success',
                });
                this.dispatchEvent(evt);
                this.uidaiTXN = objJson.kycResponse.UidData.txn;
                this.uidaiRRN = objJson.kycResponse.TransactionInfo.RRN;
            } else if(objJson.kycResponse.TransactionInfo.ResponseMsg==='Invalid Aadhaar Number') {
                this.disableResendButton = true;
                this.disableVerifyButton = true;
                this.checkaadharpopup=true;
                const evt = new ShowToastEvent({
                    title: "Error",
                    message: objJson.kycResponse.TransactionInfo.ResponseMsg,
                    variant: 'error',
                });
                this.dispatchEvent(evt);
                this.closepopup();
            } else {
                this.disableResendButton = true;
                this.disableVerifyButton = true;
                this.generateotppopup=false;
                const evt = new ShowToastEvent({
                    title: "Error",
                    message: objJson.kycResponse.TransactionInfo.ResponseMsg,
                    variant: 'error',
                });
                this.dispatchEvent(evt);
                this.dispatchEvent(new CustomEvent('clickpopupcross'));
            }
        })
        .catch(error =>{
            this.isSpinnerMoving=false;
            console.log("here error :",error);
        });
    }
    //End: handleGenerateOtpClick()

    //Start: handleVerifyClick() verify if OTP generated by system and User entered OTP are same or not
    handleVerifyClick(){
        try{

        
        this.isSpinnerMoving=true;
        this.enteredOTP = this.template.querySelector('input[data-id=OTP]').value;
        console.log('this.enteredOTP',this.enteredOTP);
        if(this.enteredOTP === null || this.enteredOTP ===''){
            this.isSpinnerMoving=false;
            const evt = new ShowToastEvent({
                title: "Warning",
                message: "Please Enter UIDAI OTP",
                variant: 'warning',
            });
            this.dispatchEvent(evt);
        }else if(this.enteredOTP!==null || this.enteredOTP !==''){
            let uidaiVerifyRequest = {
            'uid': this.kycaadharno,
            'otp': this.enteredOTP,
            'txn': this.uidaiTXN,
            'rnn': this.uidaiRRN,
            'applicantId' : this.applicantid,
            'loanApplicationId' : this.loanapplicationd,
            'documentId' : this.currentdocumentid
            };

        doUidaiOTPVerifyCallout({'kycUidaiRequestString': JSON.stringify(uidaiVerifyRequest)})
       .then(result => {
            this.isSpinnerMoving=false;
            const obj = JSON.parse(result);
            const objJSON = JSON.parse(obj);
            console.log('UIDAI VERIFY OTP API Resposne NOT Parsed :==>',obj);
            console.log('UIDAI VERIFY OTP API Resposne Parsed :==>',objJSON);
            console.log('The output is ', objJSON.kycResponse.TransactionInfo.ResponseMsg)

            if(objJSON.kycResponse.TransactionInfo.ResponseMsg==='Approved'){
                // if(objJSON.kycResponse?.UidData?.tkn != null){
                //     let Aadhaar_Vault_Token_ID = objJSON.kycResponse?.UidData?.tkn;
                //     saveTKNId({ documentId: this.currentdocumentid , tknNo: Aadhaar_Vault_Token_ID})
                //       .then(result => {
                //         console.log('Result', result);
                //       })
                //       .catch(error => {
                //         console.error('Error:', error);
                //     });
                // }
                let base64Imag = objJSON.kycResponse?.UidData?.Pht;
                let tknNumber = objJSON.kycResponse?.UidData?.tkn;
                saveImagetoSF({'base64Imag': base64Imag,'documentId':this.currentdocumentid, 'tknNo':tknNumber});
                console.log('The event is dispatch to parent')
                this.disableVerifyButton = false;
                this.generateotppopup=false; 
                this.dispatchEvent(new CustomEvent('verifybuttonclick',{ detail: obj}));
            }
            // else if(objJSON.kycResponse.TransactionInfo.ResponseMsg==='Resident authentication failed'){
            //     this.checkaadharpopup=true;
            //     this.generateotppopup=false;
            //     this.dispatchEvent(new CustomEvent('clickpopupcross'));
            // }
            else{
                this.generateotppopup=true;
                this.disableVerifyButton = true;
                const evt = new ShowToastEvent({
                    title: "Error",
                    message: objJSON.kycResponse.TransactionInfo.ResponseMsg+'. Please retry',
                    variant: 'error',
                });
                this.dispatchEvent(evt);
            }
        })
        .catch(error =>{
            this.isSpinnerMoving=false;
            this.tryCatchError = error;
            this.generateotppopup = false;
            console.log('UIDAI VERIFY API Error :==>',error);
            if(error?.body?.message){
                this.errorInCatch();
            }else{
                const evt = new ShowToastEvent({
                    title: "Error",
                    message: "Error parsing Aadhaar response, special character found. Please contact System Admin",
                    variant: 'error',
                });
                this.dispatchEvent(evt);
            }
        });
    }
    

        /*verifyAadharOTP({enteredOtpNumber : this.enteredOTP, docRecordId : this.currentdocumentid})
        .then(result => {
            this.isSpinnerMoving=false;
            this.otpMatch=result;
            if(this.otpMatch==true) {
                const evt = new ShowToastEvent({
                    title: "Success",
                    message: "OTP Verified Successfully",
                    variant: 'success',
                });
                this.dispatchEvent(evt);
                this.generateotppopup=false; 
                this.dispatchEvent(new CustomEvent('changeaadharsubmitpopupflag'));//Custom event to change AadharOTP Submit popup close flag 
            }
            else{
                const evt = new ShowToastEvent({
                    title: "Please re-try",
                    message: "OTP Verification Failed",
                    variant: 'error',
                });
                this.dispatchEvent(evt);
            } 
          })
        .catch(error =>{
            this.error = error;
            console.log("here error :" + error);
        });*/
    }
    catch(e){ console.log('The error is ',e)}

    
}
//End: handleVerifyClick() verify if OTP generated by system and User entered OTP are same or not

    //Start:handleResendClick() for enabling the resend button after a particular time period
    handleResendClick(){
        resendAadharOTP({docRecordId: this.currentdocumentid,bmdsensorno:this.bmdsensorno})
        .then(result => {
            //this.resentOtpStatus=result;
            if(result){
                this.disableResendButton=false;
                this.handleGenerateOtpClick();
            }
            else{
                this.disableResendButton=true;
                this.generateotppopup = false;
                const evt = new ShowToastEvent({
                    title: "Attempts Exhausted ",
                    message: "Attempt to do e-KYC through OTP for this applicant is unsuccessful. Please upload an alternate KYC [Voter Identity Card, Driving License or Passport]",
                    variant: 'error',
                });
                this.dispatchEvent(evt);
                this.dispatchEvent(new CustomEvent('changeresendotpexhaust'));//Custom event if resend attempts exhausts             
            }
        })
        .catch(error => {
            this.error = error;
            console.log(this.error);
        });

    }  
    //End:handleResendClick() for enabling the resend button after a particular time period      

    //to close the otp-verification pop up
    closepopup() {
        this.generateotppopup = false;
        this.dispatchEvent(new CustomEvent('clickpopupcross'));
    }

    handleOkButtonPopup(){
        this.checkaadharpopup=false;
    }

     //handle Catch errors
     errorInCatch() {
        const evt = new ShowToastEvent({
            title: "Error",
            message: this.tryCatchError.body.message,
            variant: 'Error',
        });
        this.dispatchEvent(evt);
    }
}