import { LightningElement,api, track, wire } from 'lwc';
import IndBankImage from '@salesforce/resourceUrl/SiteSamples';
import applicationFormExpire from '@salesforce/apex/IND_InsuranceConsentOTP.applicationFormExpire';
import CONSENT_LINK_EXPIRED from '@salesforce/label/c.Consent_Link_Expired';
import INSURANCE_INVALID_CONSENT from '@salesforce/label/c.Insurance_Invalid_Consent';
import INSURANCE_CONSENT_ALREADY_SUBMITTED from '@salesforce/label/c.Insurance_Consent_already_Submitted';
import INSURANCE_CONSENT_ERROR_MESSAGE from '@salesforce/label/c.Insurance_Consent_Error_Message';
import  INSURANCE_RESPONSE_RECEIVED from '@salesforce/label/c.Insurance_Response_Received';
import  URL_is_Expired from '@salesforce/label/c.URL_is_Expired'; 

export default class LWC_LOS_ParentInsuranceConsentOtp extends LightningElement {
    @api recordId;      
    @track showInsuranceConsent=false;  
    @track showSubmittedPageVar=false;  
    @track burl;   
    @track pageMessage;
    getIndBankImage = IndBankImage + '/img/indusind.png';   


parameters = {};

connectedCallback()
{ 

    this.parameters = this.getQueryParameters();
        console.log(this.parameters.connum);

applicationFormExpire({applicantId:this.recordId, connum :this.parameters.connum })
    .then(result =>{        
        //this should be for application form signing
        if(result ){ 
            console.log(' Response :: ',result);
            if(result == 'Link Expired'){
                this.showInsuranceConsent=false;
                this.showSubmittedPageVar=true; 
                this.pageMessage = CONSENT_LINK_EXPIRED;
                console.log(' Response :: ',this.pageMessage +' showSubmittedPageVar :'+this.showSubmittedPageVar);
            }else if(result == 'Url Expired'){
                this.showInsuranceConsent=false;
                this.showSubmittedPageVar=true; 
                this.pageMessage = URL_is_Expired;
            }else if(result == 'Consent recieved'){
                this.showSubmittedPageVar=true;
                this.pageMessage = INSURANCE_CONSENT_ALREADY_SUBMITTED;
            }else if(result == 'Valid Consent'){
                this.showInsuranceConsent=true;
                this.showSubmittedPageVar=false;
            } else if(result == 'Invalid Consent'){
                this.showInsuranceConsent=false;
                this.showSubmittedPageVar=true;
                this.pageMessage = INSURANCE_INVALID_CONSENT;
            }   
        }else{
            this.showInsuranceConsent=false;
                this.showSubmittedPageVar=true;
                this.pageMessage = INSURANCE_CONSENT_ERROR_MESSAGE;
        }               
    })
    .catch(error => {
        console.log(error);
    });
}

getQueryParameters() {
    var params = {};
    var search = location.search.substring(1);
    console.log(' search :',search);

    if (search) {
        params = JSON.parse('{"' + search.replace(/&/g, '","').replace(/=/g, '":"') + '"}', (key, value) => {
            return key === "" ? value : decodeURIComponent(value)
        });
    }

    return params;
}


    showThankyouConsentPage()
    {
        
        console.log('showThankyouConsentPage'+this.recordId)
        this.showInsuranceConsent=false;
        this.showSubmittedPageVar=true;
        this.pageMessage = INSURANCE_RESPONSE_RECEIVED;
        
    }

}