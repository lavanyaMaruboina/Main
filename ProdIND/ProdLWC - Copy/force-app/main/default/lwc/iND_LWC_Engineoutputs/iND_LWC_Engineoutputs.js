import { LightningElement, track,api } from 'lwc';
import getApplicants_MTD from '@salesforce/apex/IND_RiskSummaryController.getApplicants';
import updateRiskSummaryData_MTD from '@salesforce/apex/IND_RiskSummaryController.updateRiskSummaryData';
import retryAttemptsExasted from '@salesforce/apex/IND_RiskSummaryController.retryAttemptsExasted';
import applicantid from '@salesforce/schema/Applicant__c.Id';
import applicantjourney from '@salesforce/schema/Applicant__c.Journey_Stage__c';
import doAMLCheckCallout from '@salesforce/apexContinuation/IntegrationEngine.doAMLCheckCallout';
import REFINANCE_LABEL from '@salesforce/label/c.Refinance';
import USED_LABEL from '@salesforce/label/c.used';
import PASSENGER_VEHICLE_LABEL from '@salesforce/label/c.PassengerVehicles';
import TWO_WHEELER_LABEL from '@salesforce/label/c.TwoWheeler' ;
import {  updateRecord } from 'lightning/uiRecordApi';
const scorecardVal={
        'Dark Green':1,
        'Light Green':2,
        'Yellow':3,
        'Orange': 4,
        'Red':5
}
export default class IND_LWC_Engineoutputs extends LightningElement {

    activeSections = ['ScorecardOutput', 'FIEngine', 'LTVEngine', 'GatingScreeningEngine', 'PricingEngine',
                    'OfferEngine'];
    @track appRecords = {};
    @track finalTerms = {};
    @track vehicleDetail = {};
    @track disableFields = false;
    @track loanApp = {};
    @track showAMLCheckButton;
    @api currentStage;
    @api recordId;
    @api creditval;
    @track riskBand;
    @track gatingscreening
    @track priceConsider;
    @track ltvAsPerORP;
    @track pricingValue;
    @track disabledAMLButton;
    @track disableSubmitBtn=false;
    @track netBankIRRorImputedBankIRR;
    @track subStage;
    @track coborrowerid;
    @track borrowerid;
    @track showCoBorrowerSection = false;
    @track isTractor = false;
    @track finalTermList = [];
    checkEligibilityMessage = '';
    connectedCallback() {
        this.getApplicants();
    }

    isRevokedLead = false;//CISP-2735
    // get Applicant and Final terms information
    getApplicants() {
        getApplicants_MTD({ loanAppId: this.recordId })
            .then(response => {
                this.isTractor = response[0].Product_Type__c == 'Tractor' ? true : false;
                response.forEach(element => {
                   
                   // this.disabledAMLButton = !element.Received_AML_API_response__c?true:false;
                    this.appRecords = element.Applicants__r[0];
                    this.finalTerms = element.Final_Terms__r[0];
                    this.finalTermList = element.Final_Terms__r;
                    this.vehicleDetail = element.Vehicle_Details__r[0];
                    this.subStage = element.Sub_Stage__c;
                    if(element.Sub_Stage__c != 'View Application Details'){ 
                        this.disableSubmitBtn = true;
                    }
                    
                    //console.log('testing', element.Final_Terms__r[0]);
                    let tempscorecardval=0;
                    for(let x in element.Applicants__r){
                        if(element.Applicants__r[x].Applicant_Type__c == 'Co-borrower'){ 
                            this.showCoBorrowerSection = true;
                            this.coborrowerid=element.Applicants__r[x].Id;
                        }  
                        if(element.Applicants__r[x].Applicant_Type__c == 'Borrower'){ 
                            this.borrowerid=element.Applicants__r[x].Id;
                            this.checkEligibilityMessage = element.Applicants__r[x].Check_Eligibility_Message__c;
                        }                                            
                        if(scorecardVal[element.Applicants__r[x].Scorecard_Decision__c] != undefined){
                            if(tempscorecardval <scorecardVal[element.Applicants__r[x].Scorecard_Decision__c]){
                                tempscorecardval = scorecardVal[element.Applicants__r[x].Scorecard_Decision__c];
                                this.riskBand =element.Applicants__r[x].Scorecard_Decision__c;
                            }                               
                        }                        
                    }
                    
                    if(element.Product_Type__c === PASSENGER_VEHICLE_LABEL && (element.Vehicle_Type__c === USED_LABEL || element.Vehicle_Type__c === REFINANCE_LABEL)){
                        this.priceConsider = this.vehicleDetail.Base_Prices__c;
                    }
                    
                    this.pricingValue = this.finalTerms.PricingEngine_thresholdNetrr__c;
                    this.ltvAsPerORP = element.LtvEngine_Ltv__c;

                    if(element.Product_Type__c === TWO_WHEELER_LABEL){
                        this.netBankIRRorImputedBankIRR = this.finalTerms.Inputted_IRR__c; 
                    }else if(element.Product_Type__c === PASSENGER_VEHICLE_LABEL){
                        this.netBankIRRorImputedBankIRR = this.finalTerms.Net_IRR__c; 
                    }
                    
                });
                this.loanApp = response[0];
                //CISP-2735-START
                this.isRevokedLead = this.loanApp?.Is_Revoked__c;
                if(this.isRevokedLead){
                    console.log('is Revoked engine');
                    this.disabledAMLButton = true;
                    this.disableFields = true;
                }
                //CISP-2735-END
                this.disableFields = true;
                if(!this.disabledAMLButton){ 	
                    retryAttemptsExasted({loanApplicationId : this.recordId})	
                    .then(res=> { 	
                        console.log(' retry attempts '+res);	
                        this.disabledAMLButton = res;	
                        	
                    })	
                }
               
            })
            .catch(error => {
                console.log('error... ',error);
            });
    }

    // Handle section open and close

    handleclick(event) {

        let position = parseInt(event.currentTarget.dataset.position);
        let sections = this.template.querySelectorAll('.slds-section');

        if (sections != null) {
            if (sections[position].classList.contains('slds-is-open')) {
                sections[position].classList.remove('slds-is-open');
            } else {
                sections[position].classList.add('slds-is-open');
            }
        }
    }

    handleSubmit(event) {    
        this.disableSubmitBtn = true;
        event.preventDefault();
        if(this.currentStage=='Credit Processing'){
            if(this.borrowerid!='' && this.borrowerid!=null){
                const applicantfieldupdate = {};
                applicantfieldupdate[applicantid.fieldApiName] = this.borrowerid;
                applicantfieldupdate[applicantjourney.fieldApiName] = 'User Details';
                console.log('FinalTerm::'+JSON.stringify(applicantfieldupdate));
                this.updateRecordDetails(applicantfieldupdate);
            }
            if(this.coborrowerid!='' && this.coborrowerid!=null){
                const applicantfieldupdate = {};
                applicantfieldupdate[applicantid.fieldApiName] = this.coborrowerid;
                applicantfieldupdate[applicantjourney.fieldApiName] = 'User Details';
                console.log('FinalTerm::'+JSON.stringify(applicantfieldupdate));
                this.updateRecordDetails(applicantfieldupdate);
            }
        }
       
        // Creates the event with the contact ID data.
        const selectedEvent = new CustomEvent('risksummaryevent', { detail:'View Application Details' });
        // Dispatches the event.
        this.dispatchEvent(selectedEvent);
           
    }

    async updateRecordDetails(fields) {
        const recordInput = { fields };
        await updateRecord(recordInput)
            .then(() => {
                console.log('after update', recordInput);
                return true;
            })
            .catch(error => {
                console.log('Error in update', error);
            });
    }

    handleAMLCheck(event) {
        if(event.detail==true){
            this.disableSubmitBtn = false;
        }else{
            this.disableSubmitBtn = true;
        }
        if(this.subStage != 'View Application Details'){ 
            this.disableSubmitBtn = true;
        }
    }
    
}