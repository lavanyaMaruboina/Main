import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import { updateRecord } from 'lightning/uiRecordApi';

import STAGENAME from '@salesforce/schema/Opportunity.StageName';
import LASTSTAGENAME from '@salesforce/schema/Opportunity.LastStageName__c';
import OPP_ID from '@salesforce/schema/Opportunity.Id';

import getVehicleRecords from '@salesforce/apex/IND_OfferScreenController.getVehicleRecords';
import checkL1OfferScreenSubmitted from '@salesforce/apex/IND_OfferScreenController.checkL1OfferScreenSubmitted';
import isCommunity from '@salesforce/apex/LwcLOSLoanApplicationCntrl.isCommunity';
import getDocumentsToCheckPan from '@salesforce/apex/IND_LWC_LoanDetailsCntrl.getDocumentsToCheckPan';

export default class Lwc_TF_OfferScreen_Parent extends NavigationMixin(LightningElement) {
    @api checkLeadAccess;
    @api isRevokedLoanApplication;
    @api recordid;
    @track vehicleRecords = [];
    @track disableSubmit = false;
    @track borrowerPAN = false;
    activeVehicle = [];

    renderedCallback(){
        if(this.isRevokedLoanApplication){this.disableEverything();}
    }
    disableEverything(){
        let allElements = this.template.querySelectorAll('*');
        allElements.forEach(element =>
            element.disabled = true
        );
    }
    @track loanAmountObj = {};
    async connectedCallback(){
        let resultofPan =  await getDocumentsToCheckPan({'loanApplicationId':this.recordid});
        let data = JSON.parse(resultofPan);
        if(data?.borrowerPanAvailable){
            this.borrowerPAN = true;
        }else{
            this.borrowerPAN = false;
        }
        await getVehicleRecords({'loanApplicationId' : this.recordid}).then(result => {
            console.log('result of getTFVehicleDetailIds> '+JSON.stringify(result));
            if(result){
                for (let index = 0; index < result.length; index++) {
                    const element = result[index];
                    if(element.Change_Pay_IN_Pay_OUT__c){
                        this.activeVehicle.push(element.Id);
                    }
                    this.loanAmountObj[element.Id] = (element.Final_Terms__r && element.Final_Terms__r.length > 0) ? element.Final_Terms__r[0].Loan_Amount__c ? parseInt(element.Final_Terms__r[0].Loan_Amount__c) : 0 : 0;
                }
                this.vehicleRecords = result;
            }else{
                console.log('something went wrong white fetching asset details')
            }
        });

        checkL1OfferScreenSubmitted({'loanApplicationId' : this.recordid, 'vehicleId' : ''}).then(result=>{
            if(result && result.length > 0){
                let stagename = result[0].Loan_Application__r.StageName;
                if(stagename != 'Offer Screen'){
                    this.disableSubmit = true;
                }
            }
        }).catch(error=>{
            console.log(error);
        })
    }

    updateLoanAmount(event){
        if(event.detail.vehicleId && event.detail.loanAmount){
            this.loanAmountObj[event.detail.vehicleId] = parseInt(event.detail.loanAmount);
        }
    }

    async handleButtonClick(event) {
        checkL1OfferScreenSubmitted({'loanApplicationId' : this.recordid, 'vehicleId' : ''}).then(result=>{
            let isSubmittedL2OfferScreens = true;
            for (let index = 0; index < result.length; index++) {
                const element = result[index];
                if(isSubmittedL2OfferScreens && !element.L1_Offer_Screen_Submitted__c){
                    isSubmittedL2OfferScreens = false;
                    break;
                }                
            }
            if(!isSubmittedL2OfferScreens){
                const evt = new ShowToastEvent({
                    title: 'Please submit the all offer screens!',
                    variant: 'warning',
                    mode: 'sticky'
                });
                this.dispatchEvent(evt);
                return;
            }else if(isSubmittedL2OfferScreens){
                let nextStage = 'Customer Code Addition';
                const oppFields = {};
                oppFields[OPP_ID.fieldApiName] = this.recordid;
                oppFields[STAGENAME.fieldApiName] = nextStage;
                oppFields[LASTSTAGENAME.fieldApiName]=nextStage;
                
                const fields = oppFields;
                const recordInput = { fields };
                updateRecord(recordInput).then((response) => {
                if(response){
                    this.dispatchEvent(new CustomEvent('submitnavigation', { detail: nextStage, bubbles: true, composed: true }));
                }
            });

            }
        })
    }

    handleCancel() {
        this.navigateToHomePage();
    }

    navigateToHomePage() {
        isCommunity()
            .then(response => {
                if (response) {
                    this[NavigationMixin.Navigate]({
                        type: 'standard__namedPage',
                        attributes: {
                            pageName: 'home'
                        },
                    });
                } else {
                    this[NavigationMixin.Navigate]({
                        type: 'standard__navItemPage',
                        attributes: {
                            apiName: 'IndusInd_Home'
                        }
                    });
                }
            })
            .catch(error => {
            });
    }
}