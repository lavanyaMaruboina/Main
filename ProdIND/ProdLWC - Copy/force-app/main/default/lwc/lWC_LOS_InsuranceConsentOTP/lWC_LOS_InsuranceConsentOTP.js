import { LightningElement,api,track } from 'lwc';
import ExceptionMessage from '@salesforce/label/c.ExceptionMessage';
import doSmsCallout from '@salesforce/apexContinuation/IntegrationEngine.doSmsGatewayCallout';
import sendConsentSMS from '@salesforce/apex/IND_InsuranceConsentOTP.sendConsentSMS';
import otpVerify from '@salesforce/apex/IND_InsuranceConsentOTP.otpVerify';
import getResendTime from '@salesforce/apex/IND_InsuranceConsentOTP.getResendTime';
import otpExpireTimeOut from '@salesforce/apex/IND_InsuranceConsentOTP.otpExpireTimeOut';
import updateConsentStatus from '@salesforce/apex/IND_InsuranceConsentOTP.updateConsentStatus';
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
import FailResponseApi from '@salesforce/label/c.FailResponseApi';
import IndBankImage from '@salesforce/resourceUrl/SiteSamples';


export default class LWC_LOS_InsuranceConsentOTP extends LightningElement {
@api otpmatch;
@api  otp ;
@api name;
@api recordid;
@api otpVerified=false;
getIndBankImage = IndBankImage + '/img/indusind.png';

label={    
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

@track resend=true;
@track delaytime;
@track verify=true;

connectedCallback(){
    console.log(this.name)
}
   
handleConsent(){//For resend functionality

this.verify=false;
this.handleOtpPopup();
   getResendTime()
    .then(result => {
        console.log('in handleconsent')
        this.delaytime=result;
        setTimeout(() => {
            this.resend = false;
        }, this.delaytime);//enable resent after timeout
    })
    .catch(error => {
        this.error = error;
        console.log(this.error);
    });

}

handleOtpPopup() {
    console.log(this.recordid)
    updateConsentStatus({ applicantId: this.recordid,name:this.name })
        .then(result => {
            if(result){
            console.log('in handleOTP')
            this.consentfirstTime=true;
            } else{
                this.consentfirstTime=false;
            }
                this.gettimeout();
        })
        .catch(error => { console.log('error---------- ',error); });
    
}
//On Click of resend button
consentfirstTime=false;
handleResend(){     
   
    updateConsentStatus({applicantId:this.recordid,name:this.name})
        .then(result =>{
            if(result){
                   
                this.consentfirstTime=true;
                }
                else{
                    this.consentfirstTime=false;
                }
                this.gettimeout();
        })
        .catch(error => {
            console.log(error);
        });

}

doSmsApiCall(){
    let smsRequestString= {
        'loanApplicationId': this.recordid ,
        'flag':'OTP',
        'applicantId' : this.recordid};
    //console.log('sms string'+JSON.stringify(smsRequestString));
    doSmsCallout({ smsRequestString:  JSON.stringify(smsRequestString) })
    .then(result => {
        console.log("came to doSmsCallout " + result);
        if (result == 'SUCCESS') {
            this.message="OTP sent successfully!"
            console.log("SMS sent successfully")            
        } else {
            this.message="Enter valid OTP"            
        }
    })
    .catch(error => {
        console.log("ERROR in doSmsCallout")
        console.log("error came doSmsCallout "+ error.body.message );       
        
    })
}

//handleVerify method for verifying the otp,if it matches the otp for borrower ,shows success,IND-279

handleVerify(event){
        this.otp = this.template.querySelector('input[data-id=OTP]').value;

        otpExpireTimeOut({applicantId:this.recordid})
        .then(result =>{
            if(result==true){
                console.log("Expire")
            }
            else{
                otpVerify({otpnumber : this.otp, applicantId: this.recordid,name:this.name})                
                .then(result => {
                    this.otpmatch=result;
                    console.log('result '+result)
                    if(this.otpmatch==true){
                        console.log('Verified')
                        this.message="OTP Verified Successfully "
                        this.otpVerified=true
                        //Passing the status of OTP verification to parent in order to display the consent

                        const myEvent=new CustomEvent('verified',{
                            detail:this.otpVerified
                        })

                        this.dispatchEvent(myEvent)
                        this.dispatchEvent(new CustomEvent('changebuttoncolor')); //Change color of button when refresh(Loan Application)
                        this.closepopup();//close pop-up
                        this.dispatchEvent(new CustomEvent('changeaadharsubmitpopupflag'));//Custom event to change AadharOTP Submit popup close flag 
                    
                     }
                    else
                    {
                        alert("Enter valid OTP")
                        this.message="Please enter valid OTP"
                    }
                })
                .catch(error => {
                    this.error = error;
                });
            }})
        .catch(error => {
            console.log(error);
        });     
    
    
}

gettimeout(){   
    console.log("From gettimeout()"+this.consentfirstTime)
    otpExpireTimeOut({applicantId:this.recordid})
    .then(result =>{
        console.log('from otpExpire result---------'+result)

        if(result || this.consentfirstTime){
            
            sendConsentSMS({ applicantId: this.recordid, name:this.name })
            .then(result => {               
                this.response = result;
                console.log("OTP :" + this.response);
                this.doSmsApiCall();
            })
            .catch(error => {
                this.error = error;
                console.log("here error :" + error);
            });
            this.consentfirstTime=this.consentfirstTime+1;
        }
        else{
            console.log("Otp already sent")
            alert("OTP is already sent! Try after 30 min")
        }
    })
    .catch(error=>{})
}


//to close the otp-verification pop up
closepopup() {
    this.otppopup = false;
    this.dispatchEvent(new CustomEvent('changeflagvalue'));//Custom event to chang flag value(Loan Application)
}

}