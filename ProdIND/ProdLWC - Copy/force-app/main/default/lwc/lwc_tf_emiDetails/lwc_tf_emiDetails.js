import { LightningElement,api } from 'lwc';
import getFinalTermData from '@salesforce/apex/IND_OfferScreenController.loadOfferScreenData';
import emiRepaymentSchedule from '@salesforce/apex/IND_OfferScreenController.emiRepaymentSchedule'; 
import getVehicleDetails from '@salesforce/apex/IND_VehicleInspectionRCLimitDetails.getVehicleDetailsRecord';
import getOfferResponse from '@salesforce/apex/IND_OfferScreenController.getOfferResponse';
import updateTransactionRecord from '@salesforce/apex/IND_OfferScreenController.updateTransactionRecord';
import getTransactionRecord from '@salesforce/apex/IND_OfferScreenController.getTransactionRecord';
import tractorOfferEngineCallout from '@salesforce/apex/IntegrationEngine.tractorOfferEngine'; 
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import L2_Offer_Engine_Completed from '@salesforce/schema/Final_Term__c.L2_Offer_Engine_Completed__c'; 
import L2_Structured_Records_Submitted from '@salesforce/schema/Final_Term__c.L2_Structured_Records_Submitted__c'; 
import final_ID_FIELD from '@salesforce/schema/Final_Term__c.Id';
import { updateRecord } from 'lightning/uiRecordApi';
import OfferengineMinLoanAmount from '@salesforce/schema/Final_Term__c.OfferengineMinLoanAmount__c';//SFTRAC-126
import OfferengineMaxLoanAmount from '@salesforce/schema/Final_Term__c.OfferengineMaxLoanAmount__c';//SFTRAC-126
import Loan_Amount from '@salesforce/schema/Final_Term__c.Loan_Amount__c';//SFTRAC-126
import OfferengineMaxTenure from '@salesforce/schema/Final_Term__c.OfferengineMaxTenure__c';//SFTRAC-126
import OfferengineMinTenure from '@salesforce/schema/Final_Term__c.OfferengineMinTenure__c';//SFTRAC-126
import Tenure from '@salesforce/schema/Final_Term__c.Tenure__c';//SFTRAC-126
import EMI_Amount from '@salesforce/schema/Final_Term__c.EMI_Amount__c';//SFTRAC-126
import Required_CRM_IRR from '@salesforce/schema/Final_Term__c.Required_CRM_IRR__c';//SFTRAC-126
import Net_IRR from '@salesforce/schema/Final_Term__c.Net_IRR__c';//SFTRAC-126
import Gross_IRR from '@salesforce/schema/Final_Term__c.Gross_IRR__c';//SFTRAC-126
import Bank_IRR from '@salesforce/schema/Final_Term__c.Bank_IRR__c'; //SFTRAC-126
import Offer_Agreement_Amount from '@salesforce/schema/Final_Term__c.Offer_Agreement_Amount__c'; //SFTRAC-126
import gradedRepaymentSchedule from '@salesforce/apex/EMI_CalculatorController.gradedRepaymentSchedule';
import calculateMonthlyEMI from '@salesforce/apex/StruturedEMICal.calculateMonthlyEMI';

export default class Lwc_tf_emiDetails extends LightningElement {
    @api recordId;
    @api dealId = '';
    finalLoanAmount;
    dealDate;
    tenure;
    installmentType;
    installmentFrequency;
    firstEMI;
    secondEMI;
    advanceEMI;
    crmIRR;
    requiredCRMIRR;
    frequency;
    assetId;
    totalPaybleEMI;
    showEquated;
    SpinnerMoving;
    showStructured;
    showAmort;
    isFinalTermChanged;
    isInstSchDisabled = false;
    isdisableSubmit = true;
    loanAgreementAmt;
    disableCallOfferEngine = true;
    showInstButton = false;
    isSubmittedLA = false;
    showStr = false;
    isl2OfferEngineCompleted = false;
    isl2StructuredRecordsCreated = false;
    finalTermId;
    readMode;
    editMode;
    totalFundedPremiumValue; //SFTRAC-126
    async connectedCallback(){
        await getVehicleDetails({loanApplicationId: this.recordId,dealId: this.dealId}).then((result) => {
            this.assetId = result.Id;
         })
        await getTransactionRecord({loanApplicationId:this.recordId,dealId:this.dealId}).then((result)=>{
            this.isSubmittedLA = result;   
            if(result){
            this.disableEverything();
            }
        });
        await getFinalTermData({ loanApplicationId:this.recordId,vehicleId:this.assetId}).then((data) => {
            if (data) {
            let parsedData = JSON.parse(data);
            this.finalLoanAmount = Number(parsedData.loanAmount) + Number(parsedData.totalFundedPremium);
            this.totalFundedPremiumValue = Number(parsedData.totalFundedPremium); //SFTRAC-126
            this.dealDate = parsedData.dealDate;
            this.isFinalTermChanged = parsedData.isFinalTermChanged;
            this.tenure = parsedData.tenure;
            this.installmentType = parsedData.installmentType;
            this.installmentFrequency = parsedData.installmentFrequency;
            this.firstEMI = parsedData.firstEMI; 
            this.secondEMI = parsedData.secondEMI; 
            this.advanceEMI = parsedData.advanceEmi;
            this.crmIRR = parsedData.crmIRR;
            this.requiredCRMIRR = parsedData.requriedCRMIRR;
            this.loanAgreementAmt = parsedData.loanAgreementAmount;
            this.finalTermId = parsedData.getrecordId;
            this.isl2OfferEngineCompleted = parsedData.isL2OfferEngineCompleted;
            this.isl2StructuredRecordsCreated = parsedData.isL2StructuredRecordsCreated;
            switch (this.installmentFrequency){
                case 'Monthly':
                    this.frequency = 1;
                    break;
                case 'bi-monthly':
                    this.frequency = 2;
                    break;
                case 'Quarterly':
                    this.frequency = 3;
                    break;
                case 'Half yearly':
                    this.frequency = 6; 
                    break;
                default:
                    this.frequency = 1;
                    break;           
            }
            if(this.isl2StructuredRecordsCreated && !this.isl2OfferEngineCompleted){
                this.disableCallOfferEngine = false;
            }
            if((!this.isFinalTermChanged || this.isSubmittedLA)){ 
                this.readMode = true;
                if(this.installmentType == 'Equated'){
                this.handleEMIRepayment();
                }
                else if(this.installmentType == 'Structured'){
                    this.showStructured = true;
                this.readMode = true;
                }
                this.disableEverything();


            } 
            else if(this.isFinalTermChanged && !this.isSubmittedLA){  
                this.editMode = true;
                if(this.installmentType == 'Equated'){
                this.showInstButton = true;
                }
                else if(this.installmentType == 'Structured'){
                    this.showStr = true;
                }
            }
            this.SpinnerMoving = false;
            
            }}).catch(error => {
            this.SpinnerMoving = false;
            });
           if((this.showStructured && (!this.isFinalTermChanged || this.isSubmittedLA)) || (this.isl2OfferEngineCompleted && !this.isSubmittedLA)){
                if(this.isl2OfferEngineCompleted && !this.isSubmittedLA){
                    this.isdisableSubmit = false;
                }
           /* await getOfferResponse({loanApplicationId:this.recordId,vehicleId:this.assetId}).then((result)=> {
            if(result.contentVersion == true){
                this.plainText = atob(result.response);
            }else{
                this.plainText = result.response;
            }
                const parsedResponse = JSON.parse(this.plainText);
                let amortSch = parsedResponse?.application?.offerEngineDetails?.offerEngineDecision?.amortizationSchedule;
                this.totalPaybleEMI = amortSch;
                this.showAmort = true;
            
            //const parsedResponse = JSON.parse(result);
                
            }
            ); */
            await calculateMonthlyEMI({loanApplicationId:this.recordId,vehicleID:this.assetId}).then((result)=>{
                this.cashFlows = result;
            })
            await gradedRepaymentSchedule({cashFlows:this.cashFlows,principal:this.finalLoanAmount,irr:this.requiredCRMIRR,loanDate:this.dealDate,increment:this.tenure,day:0,frequency:this.frequency,repaymentDate:this.firstEMI,secondEMI:this.secondEMI}).then((result)=>{
                this.totalPaybleEMI = result;
                this.showEquated = true;
                this.SpinnerMoving = false;
            }).catch((error) => {
                this.SpinnerMoving = false;
            });
        }
    }

    handleInstSch(){
        this.isInstSchDisabled = true;
        this.showEquated = true;
        this.handleEMIRepayment();
    }

    async handleEMIRepayment(){
        await emiRepaymentSchedule({principal:this.finalLoanAmount,irr:this.requiredCRMIRR,loanDate:this.dealDate,increment:this.tenure,frequency:this.frequency,repaymentDate:this.firstEMI,secondEMI:this.secondEMI,advanceEMI:this.advanceEMI}).then((result) => {
            this.totalPaybleEMI = result;
            if(!this.isFinalTermChanged || this.isSubmittedLA){
                this.readMode = true;
            }
            this.showEquated = true;
            this.SpinnerMoving = false;
            this.isdisableSubmit = false;
        })
        .catch((error) => {
            this.SpinnerMoving = false;
        });
    }
    handleSubmit(){
        this.updateLATransaction();
        this.disableEverything();
    }
    updateLATransaction(){
        updateTransactionRecord({ loanApplicationId: this.recordId, dealId: this.dealId })
          .then(result => {
            console.log('Result', result);
          })
          .catch(error => {
            console.error('Error:', error);
        });
    }
    disableEverything(){
        let allElements = this.template.querySelectorAll('*');
        allElements.forEach(element => {
            // if(element.label !== 'Revoke'){
                element.disabled = true
            // }
       });
    }
    handleCallOfferEngine(){
        this.handleTFOfferEngineCalloutHelper();
}
 handleTFOfferEngineCalloutHelper(){
    tractorOfferEngineCallout({ loanAppId: this.recordId, vehicleId: this.assetId,screenName : 'EMI Details'}).then(
        result => {
            const parsedResponse = JSON.parse(result);
            let amortSch = parsedResponse?.application?.offerEngineDetails?.offerEngineDecision?.amortizationSchedule;
            const offerEngineResponse = parsedResponse?.application?.offerEngineDetails?.offerEngineDecision;
            //this.totalPaybleEMI = amortSch;
            //this.showAmort = true; 
            this.isdisableSubmit = false;
            const evt = new ShowToastEvent({
                title: 'Success',
                message: "Offer Engine Success",
                variant: 'success',
            });
            const FinalTermsFields = {};
            FinalTermsFields[final_ID_FIELD.fieldApiName]=this.finalTermId;
            FinalTermsFields[L2_Offer_Engine_Completed.fieldApiName] = true;
            ////SFTRAC-126 Starts
            FinalTermsFields[OfferengineMinLoanAmount.fieldApiName] = offerEngineResponse !== undefined ?  offerEngineResponse.minLoanAmt : '';
            FinalTermsFields[OfferengineMaxLoanAmount.fieldApiName] = offerEngineResponse !== undefined ?  offerEngineResponse.maxLoanAmt : '';
            FinalTermsFields[Loan_Amount.fieldApiName] = offerEngineResponse !== undefined ?  (parseFloat(offerEngineResponse.displayLoanAmt) - this.totalFundedPremiumValue).toString() : ''; //SFTRAC-126
            FinalTermsFields[OfferengineMinTenure.fieldApiName] = offerEngineResponse !== undefined ?  offerEngineResponse.minTenure : '';
            FinalTermsFields[OfferengineMaxTenure.fieldApiName] = offerEngineResponse !== undefined ?  offerEngineResponse.maxTenure : '';
            FinalTermsFields[Tenure.fieldApiName] = offerEngineResponse !== undefined ?  offerEngineResponse.displayTenure.toString() : '';
            FinalTermsFields[EMI_Amount.fieldApiName] = offerEngineResponse !== undefined ?  offerEngineResponse.displayEMI : '';
            FinalTermsFields[Required_CRM_IRR.fieldApiName] = offerEngineResponse !== undefined ?  offerEngineResponse.displayCrmIrr.toString() : '';
            FinalTermsFields[Net_IRR.fieldApiName] = offerEngineResponse !== undefined ?  offerEngineResponse.netIrr : '';
            FinalTermsFields[Gross_IRR.fieldApiName] = offerEngineResponse !== undefined ?  offerEngineResponse.grossIrr : '';
            FinalTermsFields[Bank_IRR.fieldApiName] = offerEngineResponse !== undefined ?  offerEngineResponse.bankCrmIrr.toString() : '';
            FinalTermsFields[Offer_Agreement_Amount.fieldApiName] = offerEngineResponse !== undefined ?  offerEngineResponse.agreementAmount : '';
            ////SFTRAC-126 Ends
            this.updateRecordDetails(FinalTermsFields);
            this.dispatchEvent(evt);
            this.SpinnerMoving = false; 
            this.disableCallOfferEngine = true;  
            if(this.installmentType == 'Structured'){
                this.totalPaybleEMI = amortSch;
                this.showAmort = true; 
                } else {
                    this.handleEMIRepayment();
                }
            }).catch(error => {
                console.log('Error in Offer Engine API.', error);
                const evt = new ShowToastEvent({
                    title: 'Error',
                    message: "Offer Engine API Failed",
                    variant: 'error',
                });
                this.dispatchEvent(evt);
                this.SpinnerMoving = false;
                this.disableCallOfferEngine = false;  
            });
}
async updateRecordDetails(fields) {
    const recordInput = { fields };
    console.log('before update ', recordInput);
    await updateRecord(recordInput)
        .then(() => {
            console.log('record  is updated successfully');
        })
        .catch(error => {
            console.log('record update error', error);
        });
}

handleEvent(event){
    this.disableCallOfferEngine = event.detail;
    const FinalTermsFields = {};
    FinalTermsFields[final_ID_FIELD.fieldApiName]=this.finalTermId;
    FinalTermsFields[L2_Structured_Records_Submitted.fieldApiName]=true;
    this.updateRecordDetails(FinalTermsFields);
}
}