import { LightningElement,track } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getRCLimitData from "@salesforce/apex/IND_DSAController.getRCLimitData";
import getRCLimitTableData from '@salesforce/apex/IND_DSAControllerWithoutSharing.getRCLimitTableData'; // Added for CISP-12436

export default class Dsa_dashboard extends NavigationMixin(LightningElement) {
    sanctionedNoOfCars;
    sanctionedNoOfDays;
    sanctionedAmount;
    availableNoOfCars;
    availableNoOfDays;
    availableAmount;
    rcLimitLoading = false;
    showRCLimitStatus = false;
    showSpinner = false;
    rcLimitData; // Added for CISP-12436
    @track Vehilce;
    @track Amount;
    @track Ageing

    handleClick(event) {
        let btnName = event.target.name;
        if (btnName === "createNewLeadBtn") {
            this[NavigationMixin.Navigate]({
                type: "comm__namedPage",
                attributes: {
                    name: "createnewlead__c"
                }
            });
        } else if (btnName === "disbursedLeadBtn") {
            this[NavigationMixin.Navigate]({
                type: "comm__namedPage",
                attributes: {
                    name: "disbursedleads__c"
                }
            });
        } else if (btnName === "allLoanApplicationsBtn") {
            this[NavigationMixin.Navigate]({
                type: "standard__objectPage",
                attributes: {
                    actionName: "list",
                    objectApiName: "Opportunity"
                }
            });
        } else if (btnName === "rcLimitStatusBtn") {
            if (!this.showRCLimitStatus) {
                this.fetchAvailableRCLimit();
                /* CISP -12436 : START */
                // Call Apex method to get MIS_RC_Limit_Dt__c records
                getRCLimitTableData()
                .then((result) => {
                    console.log('RCLimit tabledata: '+JSON.stringify(result));
                    this.rcLimitData = result.map((record, index) => {
                        return {
                            rowIndex: index + 1,
                            ...record,
                            PDD_Days__c: this.calculatePDDDays(record.Disbursed_Date__c, record.IBL_Lien_Marked_On__c),
                        };
                    });
                })
                .catch((error) => {
                    this.error = error;
                });
                /* CISP -12436 : END */
            }
        }
    }
    /* CISP -12436 : START */
    calculatePDDDays(disbursedDate, iblLienMarkedOn) {
        console.log('disbursedDate> '+disbursedDate)
        console.log('iblLienMarkedOn> '+iblLienMarkedOn)
        if (disbursedDate && iblLienMarkedOn) {
            const disbursedDateObj = new Date(disbursedDate);
            const iblLienMarkedOnObj = new Date(iblLienMarkedOn);
            const timeDifference = disbursedDateObj - iblLienMarkedOnObj;
            return Math.floor(timeDifference / (1000 * 3600 * 24));
        }
        return null;
    }
     /* CISP -12436 : END */

    async fetchAvailableRCLimit() {
        this.showSpinner = true;
        let formatter = new Intl.NumberFormat('en-IN', {
            style: 'currency',
            currency: 'INR',
            currencyDisplay: 'code',
            maximumFractionDigits: 0
        });
        await getRCLimitData()
            .then((data) => {
                if(data.sanctionedNoOfCars){
                    this.sanctionedNoOfCars = data.sanctionedNoOfCars;
                    this.sanctionedAmount = data?.sanctionedAmount ? formatter.format(data.sanctionedAmount).replace('INR', '') : '';
                    this.sanctionedNoOfDays = data.sanctionedNoOfDays;
                    this.availableNoOfCars = data.availableNoOfCars;
                    this.availableAmount = data.availableAmount ? formatter.format(data.availableAmount).replace('INR', '') : '';
                    if (data.availableNoOfDays !== 'Limit Breached') {
                        this.availableNoOfDays = ~~data.availableNoOfDays;
                    }
                    else {
                        this.availableNoOfDays = data.availableNoOfDays;
                    }
                    this.showRCLimitStatus = true;
                } else {
                    this.showToast("Error", 'No RC Limit data exists for the DSA.', "error");
                }
                if (this.availableNoOfDays === 'Limit Breached') {
                    this.Ageing = 'color:red';
                }
                if (this.availableNoOfCars < 0) {
                    this.availableNoOfCars = 0;
                    this.Vehilce = 'color:red';
                }
                if (this.availableAmount.startsWith('-')) {
                    this.availableAmount = 0;
                    this.Amount = 'color:red';
                }
                this.showSpinner = false;
            })
            .catch((error) => {
                this.showToast("Error", error?.body?.message, "error");
                this.showSpinner = false;
                this.showRCLimitStatus = false;
            });
    }

    showToast(toastTitle, message, variant) {
        const evt = new ShowToastEvent({
            title: toastTitle,
            message: message,
            variant: variant
        });
        this.dispatchEvent(evt);
    }
}