import { LightningElement,wire,api,track } from 'lwc';
 import getFinalTerms from '@salesforce/apex/GetFinalTermsRecords.getFinalTerms';
 import getFinalOfferDetailsflag from '@salesforce/apex/GetFinalTermsRecords.getFinalOfferDetailsflag';
 import doSmsCallout from '@salesforce/apexContinuation/IntegrationEngine.doSmsGatewayCallout';
 import checkRetryExhaustedForResendSMS from '@salesforce/apexContinuation/FinalTermscontroller.checkRetryExhaustedForResendSMS';
 import retryCountIncreaseForResendSMS from '@salesforce/apexContinuation/FinalTermscontroller.retryCountIncreaseForResendSMS';
 import {ShowToastEvent} from 'lightning/platformShowToastEvent';
 import Retry_Exhausted from '@salesforce/label/c.Retry_Exhausted';
 import ResendSMS from '@salesforce/apexContinuation/FinalTermscontroller.ResendSMS';

 
 export default class LwcFinalOffer extends LightningElement {
   @api recordId;
    @track fields;
    @track isEnableNext=false;
    @track lstRecords =[];
    @api appname='';
    @api tempvar = '';
    @api cat='d';
    @api decision='';
    @api count = 0;

    @api currentStage;

    @track isloanstatus;
    @track iconname;

    @track label = {
        Retry_Exhausted 
        };

    connectedCallback(){
        
        getFinalOfferDetailsflag({
            offerId :this.recordId
        }).then(result=>{

            if( result == 'GREEN'){
                this.iconname = 'action:approval';
                this.isloanstatus = 'greenworld';
            }
            else if (result == 'YELLOW'){
                this.iconname = 'action:approval';
                this.isloanstatus = 'yellowworld';
            }
            else{
                this.iconname = 'utility:spinner';
                this.isloanstatus = 'yellowworld';
            }
        }).catch(error=>{

        });

    }


    @wire (getFinalTerms,{ opp :'$recordId' })
    fetchData(value) {
        const {
            data,
            error
        } = value;
        if(data){
        for (let key in data) {
            this.lstRecords.push({value:data[key], key:key});
         }
         for (let key in data) {
            if(this.count==0){
                this.tempvar = data[key];
                this.appname = this.appname.concat(this.tempvar);
                this.count++;
            }
         }
         if(this.cat=='a') {
             this.decision = this.cat;
         }else if(this.cat=='b'){
             this.decision = this.cat;
         }else{
             this.decision = this.cat;
         }
        }
        else if(error){
            console.log(error);
            this.lstRecords = [];
        }
    }
    handleOnfinish(event) {
        console.log('entered');
        const evnts = new CustomEvent('riskvalevent', { detail: event });
                            this.dispatchEvent(evnts);
        //this.template.querySelector('c-i-N-D_-L-W-C_-View-Application-Data').submit(event);
    }
    handleSms(){
        alert('handle Click');
        checkRetryExhaustedForResendSMS()
        .then(result=>{
            //alert('result'+JSON.stringify(result))
            if(result == this.label.Retry_Exhausted){
                const event = new ShowToastEvent({
                      title: 'Error',
                      message: this.label.Retry_Exhausted,
                      variant: 'error',
                  });
                  this.dispatchEvent(event);
              }else{

                ResendSMS()
                .then(result=>{
                 alert('result.length'+result.length);
                 if(result != null || result != undefined || result.length != 0){
                    
                 }
                })
                .catch(error=>{});
             
               /* let smsRequestString = {
                    'applicantId': 'a0U71000000ASsf',  // appid need to send?
                    'loanApplicationId':'00671000001EDRRAA4',      // this.recordId,
                    'flag':'LAS' ,
                    };
                    
                    doSmsCallout({
                    smsRequestString: JSON.stringify(smsRequestString)
                    })
                    .then(smsresult => {
                       // alert('Callout success'+JSON.stringify(smsresult))
                    if (smsresult == 'SUCCESS') {
                    console.log('sms result => ', smsresult);
                    retryCountIncreaseForResendSMS()
                    .then(result=>{
                        console.log('Success');
                       // alert('Count Increased'+JSON.stringify(result));
                    })
                    .catch(error=>{
                        //alert('error in count'+JSON.stringify(error))
                        console.log(error);
                    });
                    }
                    })
                    .catch(error => {
                    this.error = error;
                    //alert('error'+JSON.stringify(error))
                    console.log('Consent ERROR' + JSON.stringify(error));
                    });*/
              }
        })
        .catch(error => {
           // alert('Error11'+JSON.stringify(error))
            console.log(error);
        });
    
    } 
    
    handleSubmit(){
        if(this.currentStage === 'Credit Processing'){
            const nextStage = new CustomEvent('submit');
            this.dispatchEvent(nextStage);
        }
    }
    renderedCallback(){
        if(this.currentStage === 'Credit Processing'){
    
            let allElements = this.template.querySelectorAll('*');

            allElements.forEach(element =>

                element.disabled = true

            );
            this.isEnableNext=true;
            if(this.template.querySelector('.next')){this.template.querySelector('.next').disabled = false;}

        }
    }
  
 }