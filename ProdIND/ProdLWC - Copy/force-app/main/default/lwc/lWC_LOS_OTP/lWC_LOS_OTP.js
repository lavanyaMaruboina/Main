import { LightningElement , api ,track,wire} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import otpVerify from '@salesforce/apex/LwcLOSLoanApplicationCntrl.otpVerify';
import otpConsentCheck from '@salesforce/apex/LwcLOSLoanApplicationCntrl.otpConsentCheck';
import ExceptionMessage from '@salesforce/label/c.ExceptionMessage';
import doSmsCallout from '@salesforce/apex/LwcLOSLoanApplicationCntrl.doSmsGatewayCallout';//CISP-2787

import sendConsentSMS from '@salesforce/apex/LwcLOSLoanApplicationCntrl.sendConsentSMS';
import otpExpireTimeOut from '@salesforce/apex/LwcLOSLoanApplicationCntrl.otpExpireTimeOut';
import updateConsentStatus from '@salesforce/apex/StoreDateTimeForConcent.updateConsentStatus';
import OtpExpired  from '@salesforce/label/c.OtpExpired';
import OtpVerified  from '@salesforce/label/c.OtpVerified';
import CheckOtp  from '@salesforce/label/c.CheckOtp';
import WrongOtp  from '@salesforce/label/c.WrongOtp';
import OtpSentAgain  from '@salesforce/label/c.OtpSentAgain';
import SuccessMessage  from '@salesforce/label/c.SuccessMessage';
import ToastSuccess  from '@salesforce/label/c.ToastSuccess';
import Expired from '@salesforce/label/c.Expired';
import OtpSent from '@salesforce/label/c.OtpSent';
import ToastError from '@salesforce/label/c.ToastError';
import otpSentSuccessfully from '@salesforce/label/c.otpSentSuccessfully';
import otpSend from '@salesforce/label/c.otpSend';
import FailResponseApi from '@salesforce/label/c.FailResponseApi';

export default class LWC_LOS_OTP extends LightningElement { 
@api otpmatch;
@api  otp ;
@api otppopup=false ;
@api currentapplicationid;
@api recordid;

@track timer ;
@track showtimer = true;//CISP-2934
@track resend=false;
@track delaytime;
@track timervalue = "00:00"; //CISP-2934

disableInput=false;
consentfirstTime=false;
timerOn = true;
value;     
@api mode = '';//DSA	
resendOTPCount = 0;//DSA
label={
otpSend,
OtpExpired,
OtpVerified,
CheckOtp,
WrongOtp,
OtpSentAgain,
SuccessMessage,
ToastSuccess,
Expired,
OtpSent,
ToastError,
otpSentSuccessfully,
FailResponseApi,
ExceptionMessage
}

renderedCallback(){
    sessionStorage.removeItem('timer');
    this.handleRefresh();
}

handleResend() { 
    this.showResendTimer();
    updateConsentStatus({applicantId:this.currentapplicationid}).then(result =>{
        console.log('updateConsentStatus():: ',result);
        if(result){   
            this.consentfirstTime=true;
        } else {
            this.consentfirstTime=false;
        }
        this.gettimeout();
    }).catch(error => {
        console.log(error);
    });
}

@api showResendTimer(){
    this.showtimer=true;
    this.timervalue = "00:00"//CISP-2934
    var remaining = 60;
    if ( sessionStorage.getItem('timer') == "NaN:NaN" || sessionStorage.getItem('timer') == null || sessionStorage.getItem('timer') == undefined  || sessionStorage.getItem('timer') == "00:00") {
        var parentThis = this;
        parentThis.timervalue = "00:00";//CISP-2934
        parentThis.showtimer = true; //new code        
        var interval = setInterval(function () {//CISP-2934
            parentThis.timervalue = "00:00";//CISP-2934
            var m = Math.floor(remaining / 60);
            var s = remaining % 60;
            m = m < 10 ? '0' + m : m;
            s = s < 10 ? '0' + s : s;
            
        if(m>=0 && s>=0){
            parentThis.resend=true;
            parentThis.timervalue= m + ':' + s;      
            sessionStorage.setItem('timer',m + ':' + s);
         }
         if(m<=0 && s<=0){       
             parentThis.resend=false;
             sessionStorage.setItem('timer','00' + ':' + '00');
             clearInterval(interval);//CISP-2934
             if(m>=0 && s>=0){
                parentThis.showtimer = false;
            }
        }
        remaining -= 1;
            
        if(remaining >= 0 && this.timerOn) {     
            setTimeout(function() {                   
                timer(remaining);
            }, 1000);
            return;
        }
    
        if(!this.timerOn) {
                return;
            }
        }, 1000);
    } else { 
        var parentThis = this;
        this.timervalue = sessionStorage.getItem('timer');
        var interval = setInterval(function() {
            if (sessionStorage.getItem('timer') != "00:00" && parentThis.showtimer) {
                 parentThis.timervalue = sessionStorage.getItem('timer');
                 parentThis.resend=true;
            } else {
                clearInterval(interval);
                sessionStorage.removeItem('timer');
                parentThis.showtimer = false;
                parentThis.resend=false;
            }
        },1000)
     }
}

doSmsApiCall(){
    let smsRequestString= {
        'loanApplicationId': this.recordid ,
        'flag':'OTP',
        'applicantId' : this.currentapplicationid};
        doSmsCallout({ smsRequestString: JSON.stringify(smsRequestString), loanId:this.recordid })//CISP-2787
        .then((result) => {
        console.log("came to doSmsCallout " + result);
        if (result == 'SUCCESS') {
            const evt = new ShowToastEvent({
                title: this.label.OtpSentAgain,
                variant: this.label.ToastSuccess,
            });
            this.dispatchEvent(evt);
        } else {
            const evt = new ShowToastEvent({
                title: this.label.FailResponseApi,
                variant: 'warning',
            });
            this.dispatchEvent(evt);
        }
    }).catch(error => {
        console.log("error came doSmsCallout "+ error.body.message );
        
        const evt = new ShowToastEvent({
            title: this.label.ExceptionMessage,
            variant: 'warning',
        });
        this.dispatchEvent(evt);
    })
}
checkConsentRecieved=false;
handleInput(){
    this.checkConsentRecieved=true;
    this.handleRefresh();
}

//to check if Consent_Received__c checkbox is checked and if checked close popup,
handleRefresh(){
    otpConsentCheck({applicantId:  this.currentapplicationid}).then(result => {
        this.otprefreshresult=result;
        if(result==true){
            this.dispatchEvent(new CustomEvent('changebuttoncolor'));//Change color of button when refresh(Loan Application)
            // CISP-2787
            this.closepopup();//CISP-2927
            this.showtimer = false;
            this.otppopup = false;
            // CISP-2787-END
        }
    }).catch(error => {
        this.error = error;
        console.log(this.error);
    });  
}

//handleVerify method for verifying the otp,if it matches the otp for borrower ,shows success,IND-279
handleVerify(event){
    this.otp = this.template.querySelector('input[data-id=OTP]').value;
    otpExpireTimeOut({applicantId:this.currentapplicationid}).then(result =>{
        if(result==true){
            const evt = new ShowToastEvent({
                title: this.label.Expired,
                message: this.label.OtpExpired,
                variant: this.label.ToastError,
            });
            this.dispatchEvent(evt); 
        } else {
            otpVerify({otpnumber : this.otp, applicantId: this.currentapplicationid}).then(result => {
                this.otpmatch=result;
                if(this.otpmatch==true){
                    const evt = new ShowToastEvent({
                        title: this.label.SuccessMessage,
                        message: this.label.OtpVerified,   
                        variant: this.label.ToastSuccess,
                    });
                    this.dispatchEvent(evt);
                    this.dispatchEvent(new CustomEvent('changebuttoncolor')); //Change color of button when refresh(Loan Application)
                    //CISP-2787
                    this.showtimer = false;
                    this.otppopup = false;
                    //CISP-2787-END
                    this.dispatchEvent(new CustomEvent('changeaadharsubmitpopupflag'));//Custom event to change AadharOTP Submit popup close flag 
                } else {
                    //DSA - Added condition as the below toast is handled in dsa js	
                    if (this.mode !== 'DSA') {
                        const evt = new ShowToastEvent({
                            title: this.label.WrongOtp,
                            message: this.label.CheckOtp,
                            variant: this.label.ToastError,
                        });
                        this.dispatchEvent(evt);
                    }
                    //DSA - sending invalidotp event	
                    this.dispatchEvent(
                        new CustomEvent("invalidotp")
                    );
                }
            }).catch(error => {
                this.error = error;
            });
        }}).catch(error => {
            console.log(error);
    });    
}

gettimeout(){
    otpExpireTimeOut({applicantId:this.currentapplicationid}).then(result =>{
        if (this.consentfirstTime || result) {//CISP-2787
            this.resendOTPCount++;
            //DSA - resend otp exhaust logic	
            if (this.mode === 'DSA' && this.resendOTPCount > 3) {
                this.dispatchEvent(
                    new CustomEvent("resendexhausted")
                );
            } else {
                if (this.mode === 'DSA' && this.resendOTPCount === 3) {
                    this.dispatchEvent(new ShowToastEvent({
                        title: 'OTP Resends Exhausted',
                        message: 'This is the last attempt to resend the OTP.',
                        variant: 'warning'
                    }));
                }
            
            sendConsentSMS({ applicantId: this.currentapplicationid }).then(result => {
                this.response = result;
                console.log("Randon number :" + this.response);
                this.doSmsApiCall();
            }).catch(error => {
                this.error = error;
                console.log("here error :" + error);
            });
                    // this.consentfirstTime = this.consentfirstTime + 1;//CISP-2787
        }
                } else {
            const evt = new ShowToastEvent({
                title: this.label.otpSend,
                variant: 'warning',
            });
            this.dispatchEvent(evt); 
        }
    }).catch(error=>{})
}

    //to close the otp-verification pop up
    closepopup() {
        this.showtimer=false;
        this.otppopup = false;
        this.dispatchEvent(new CustomEvent('changeflagvalue'));//Custom event to chang flag value(Loan Application)
    }

}