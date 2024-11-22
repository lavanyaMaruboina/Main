import { LightningElement, track, api,wire } from 'lwc';
import getVehicleValuationDetailsForTractor from '@salesforce/apex/Ind_VehicleValuationController.getVehicleValuationDetailsForTractor';
import isCommunity from '@salesforce/apex/LwcLOSLoanApplicationCntrl.isCommunity';
import { NavigationMixin } from 'lightning/navigation';
import OPP_ID_FIELD from '@salesforce/schema/Opportunity.Id';
import STAGENAME from '@salesforce/schema/Opportunity.StageName';
import LAST_STAGE_NAME from '@salesforce/schema/Opportunity.LastStageName__c';
import { updateRecord, getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import vehicleValuationDetailsSaved from '@salesforce/label/c.Vehicle_Valuation_Details_Saved';
export default class LWC_LOS_ParentVehicleValuation extends NavigationMixin(LightningElement) {
    @api recordid;
    @api activeTab;
    @api checkleadaccess;
    @api isRevokedLoanApplication;
    @track isTractorProduct = false;
    @track isCmpLoaded = false;
    allVehicleDetails;
    @track submitButtonDisabled = true;
    navCount = 0;
    vehicleData = [];
    @api currentStage;
    @track vehiclePresent = false;
    @track isEnableNext = false;

    @wire(getRecord, { recordId: '$recordid', fields: ['Opportunity.Product_Type__c'] })
    wiredAccountPre({ error, data }) {
        if (data) {
            this.isTractorProduct = data.fields.Product_Type__c.value == 'Tractor' ?  true : false;
            this.init();
            if(this.isRevokedLoanApplication){
                this.submitButtonDisabled = true;
            }
        } else if (error) {
        }
    }

    async init() {
        this.isCmpLoaded = true;
        this.submitButtonDisabled =true;
        const vehicleDetails = await getVehicleValuationDetailsForTractor({ loanApplicationId: this.recordid });
        this.allVehicleDetails = JSON.parse(vehicleDetails);
        if(this.isTractorProduct && this.allVehicleDetails.length > 0){
            this.vehiclePresent = true;
        }else if(this.isTractorProduct){
            this.vehiclePresent = false;
        }
        if(!this.isTractorProduct){
            this.vehiclePresent = true;
        }
        if(this.currentStage == 'Credit Processing' && this.isTractorProduct){
            this.isEnableNext = true;
        }
    }
    handleHome(event) {
        let getData = this.template.querySelectorAll("c-l-W-C-_-L-O-S-_-Vehicle-Valuation").forEach(item => {
            item.handleHomeClick();
        });

    }
    homenavigation(event) {
        this.navCount = this.navCount + Number(event.detail.count);
        if (this.navCount == this.allVehicleDetails.length) {
            console.log('inside check count');
            this.navigateToHomePage();
        }
    }
    submitVehicleValuation(event) {
        const isVehicleSubmit = event.detail.isSubmit;
        this.vehicleData.push(event.detail);
        let checkNavigate = false;
        let currentIndex = Number(event.detail.currentIndex);
        if(isVehicleSubmit && this.template.querySelectorAll("c-l-W-C-_-L-O-S-_-Vehicle-Valuation") && this.template.querySelectorAll("c-l-W-C-_-L-O-S-_-Vehicle-Valuation")[currentIndex]){
           this.template.querySelectorAll("c-l-W-C-_-L-O-S-_-Vehicle-Valuation")[currentIndex].disableEverything();
        }
        if (this.vehicleData.length == this.allVehicleDetails.length) {
            for (let i = 0; i < this.allVehicleDetails.length; i++) {
                if (this.vehicleData[i].isSubmit == true) {
                    checkNavigate = true;
                } else {
                    checkNavigate = false;
                }
            }
            if(checkNavigate){
                this.submitButtonDisabled = false;
                // const oppFields = {};
                // oppFields[OPP_ID_FIELD.fieldApiName] = this.recordid;
                // oppFields[STAGENAME.fieldApiName] = 'Loan Details';
                // oppFields[LAST_STAGE_NAME.fieldApiName] = 'Loan Details';
                // this.updateRecordDetails(oppFields);
                // this.template.querySelector("c-l-W-C-_-L-O-S-_-Vehicle-Valuation").callLoanApplicationHistory('Loan Details');
            }else{
                const evt = new ShowToastEvent({
                    title: "Info",
                    message: 'Please submit all vehicle valuation screen for  all vehicles!',
                    variant: 'info',
                });
                this.dispatchEvent(evt);
            }
        }else{
            const evt = new ShowToastEvent({
                title: "Info",
                message: 'Please submit all vehicle valuation screen for  all vehicles!',
                variant: 'info',
            });
            this.dispatchEvent(evt);
        }
    }
    handleSubmit(event){
        let changeStage = true; 
        for (let i = 0; i < this.allVehicleDetails.length; i++) {
            if (this.vehicleData[i].isSubmit == false) {
                changeStage = false;
                break;
            }
        }
        if(changeStage){
            const oppFields = {};
            oppFields[OPP_ID_FIELD.fieldApiName] = this.recordid;
            oppFields[STAGENAME.fieldApiName] = 'Loan Details';
            oppFields[LAST_STAGE_NAME.fieldApiName] = 'Loan Details';
            this.updateRecordDetails(oppFields);
        }else{
            const evt = new ShowToastEvent({
                title: "Info",
                message: 'Please submit all vehicle valuation screen for  all vehicles!',
                variant: 'info',
            });
            this.dispatchEvent(evt);
        }
    }
    async updateRecordDetails(fields) {
        const recordInput = { fields };
        console.log('recordInput', recordInput);
        await updateRecord(recordInput)
            .then(() => {
                const evt = new ShowToastEvent({
                    title: "Success",
                    message: vehicleValuationDetailsSaved,
                    variant: 'success',
                });
                this.dispatchEvent(evt);
                this.template.querySelector("c-l-W-C-_-L-O-S-_-Vehicle-Valuation").callLoanApplicationHistory('Loan Details');
            })
            .catch(error => {
                console.log('error in updation =>', error);
                this.tryCatchError = error;
            });
    }
    viewUploadViewFloater(event) {
        console.log('inside Parent viewUploadViewFloater');
        let count = 0;
        let getData = this.template.querySelectorAll("c-l-W-C-_-L-O-S-_-Vehicle-Valuation").forEach(item => {
            if (count == 0) {
                console.log('inside new count for doc', count);
                item.viewUploadViewFloater();
                count++;
            }

        });
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
                            apiName: 'Home'
                        }
                    });
                }
            })
            .catch(error => {
            });

    }

    handleOnfinish(event) {
        const evnts = new CustomEvent('loanvaleve', { detail: event, bubbles:true, composed:true });
        this.dispatchEvent(evnts);
    }
}