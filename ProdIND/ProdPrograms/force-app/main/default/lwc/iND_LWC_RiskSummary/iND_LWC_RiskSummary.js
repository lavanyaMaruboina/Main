import { LightningElement, track,api } from 'lwc';
import getApplicants_MTD from '@salesforce/apex/IND_RiskSummaryController.getApplicants';
import updateRiskSummaryData_MTD from '@salesforce/apex/IND_RiskSummaryController.updateRiskSummaryData';

import doAMLCheckCallout from '@salesforce/apexContinuation/IntegrationEngine.doAMLCheckCallout';
import REFINANCE_LABEL from '@salesforce/label/c.Refinance';
import USED_LABEL from '@salesforce/label/c.used';
import PASSENGER_VEHICLE_LABEL from '@salesforce/label/c.PassengerVehicles';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import TWO_WHEELER_LABEL from '@salesforce/label/c.TwoWheeler' ;
import ReadOnlyLeadAccess from '@salesforce/label/c.ReadOnlyLeadAccess';

const scorecardVal={
        'Dark Green':1,
        'Light Green':2,
        'Yellow':3,
        'Orange': 4,
        'Red':5
}
export default class IND_LWC_RiskSummary extends LightningElement {

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
    @track substage;
    @track netBankIRRorImputedBankIRR;
    @track finalTermList = [];
    @track isTractor = false;
    checkEligibilityMessage = '';
    disableSubmit=false;
    showCoBorrowerSection = false;
    requestedLoanAmount;//CISP-2877
    @api checkleadaccess;//coming from tabloanApplication;

    @api isRevokedLoanApplication;//CISP-2735
    // code changes as per requirement given by Ruchi jain
    connectedCallback(){
            this.getApplicants();
            
            if(this.checkleadaccess){//if lead is accessible but user from different profile is viewing that
                const evt = new ShowToastEvent({
                title: ReadOnlyLeadAccess,
                variant: 'warning',
                mode: 'sticky'
            });
            this.dispatchEvent(evt);
            console.log('from tab loan');
            this.disableSubmit=true;
            this.disableEverything();
          }
          if(this.isRevokedLoanApplication){this.disableFields=true;this.disableSubmit=true;this.disableEverything();}//CISP-2735
  }
  renderedCallback(){
    if(this.checkleadaccess){
    this.disableFields=true;
    this.disableSubmit=true;
    this.disableEverything();
    }
    if(this.isRevokedLoanApplication){this.disableFields=true;this.disableSubmit=true;this.disableEverything();}//CISP-2735
  }
  // code changes as per requirement given by Ruchi jain
  disableEverything(){
         let allElements = this.template.querySelectorAll('*');
         allElements.forEach(element =>
         element.disabled = true
         );
  }

    // get Applicant and Final terms information
    getApplicants() {
        getApplicants_MTD({ loanAppId: this.recordId })
            .then(response => {
                this.isTractor = response[0].Product_Type__c == 'Tractor' ? true : false;
                response.forEach(element => {                  
                    this.appRecords = element.Applicants__r[0];
                    this.finalTerms = element.Final_Terms__r[0];
                    this.finalTermList = element.Final_Terms__r;
                    this.vehicleDetail = element.Vehicle_Details__r[0];
                    this.substage=element.Sub_Stage__c;
                    this.requestedLoanAmount = this.finalTerms && this.finalTerms.Loan_Amount__c!=null ? parseFloat(this.finalTerms.Loan_Amount__c) + parseFloat(element.Total_Funded_Premium__c) : element.Total_Funded_Premium__c;//CISP-2877
                    console.log('testing', element.Final_Terms__r[0]);
                    console.log('Sub_Stage__c', element.Sub_Stage__c);
                    console.log('this.substage'+this.substage);
            if(this.substage!='Risk Summary'){
                this.disableEverything();
            }
                    let tempscorecardval=0; 
                    for(let x in element.Applicants__r){
                        if(element.Applicants__r[x].Applicant_Type__c == 'Co-borrower'){ 
                            this.showCoBorrowerSection = true;
                        } 
                        if(element.Applicants__r[x].Applicant_Type__c == 'Borrower'){
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
                    }else if(this.isTractor && (element.Vehicle_Type__c === USED_LABEL || element.Vehicle_Type__c === REFINANCE_LABEL)){ // SFTRAC-95
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
               
                this.disableFields = true;
               
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
      /*  updateRiskSummaryData_MTD({ finalTerm: JSON.stringify(this.finalTerms), loanApps: JSON.stringify(this.loanApp) })
        .then(response => {
        })
        .catch(error => {
            this.isSpinnerMoving = false;
        })*/
        this.disableSubmit=true;
        event.preventDefault();

        // Creates the event with the contact ID data.
        const selectedEvent = new CustomEvent('risksummaryevent', { detail:'Risk Summary' });
        // Dispatches the event.
        this.dispatchEvent(selectedEvent);
           
    }

    // handleAMLCheck() {
    //     console.log('aml api check');
    //     doAMLCheckCallout({applicantId:'a0U71000000ApFlEAK' ,loanAppId:this.recordId})
    //     .then(result =>{
    //         console.log('result of aml api =>', result);
    //     })
    //     .catch(error=>{
    //         console.log('error in aml api => ', error);
    //     })
    // }

    renderedCallback(){
        
            if(this.currentStage === 'Credit Processing'){
    
                let allElements = this.template.querySelectorAll('*');
    
                allElements.forEach(element =>
    
                    element.disabled = true
    
                );
                if(this.template.querySelector('.submit')){this.template.querySelector('.submit').disabled = false;}
            }
            if(this.currentStage === 'Credit Processing'){
                this.showAMLCheckButton = true;
            }
    }
}