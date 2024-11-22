/* eslint-disable no-unused-vars */
import { LightningElement, track, api, wire } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { NavigationMixin, CurrentPageReference } from "lightning/navigation";
import assignToBE from "@salesforce/apex/IND_DSAController.assignToBE";
import getOfferDetailsByRecordId from "@salesforce/apex/IND_DSAController.getOfferDetailsByRecordId";
import createCoBorrower from "@salesforce/apex/IND_DSAController.createCoborrowerScreening";
import getLoanApplicationStageName from '@salesforce/apex/LwcLOSLoanApplicationCntrl.getLoanApplicationStageName'; // CISP:13870
import GetBEDetails from "@salesforce/apex/IND_DSAController.GetBEDetails";
import UserId from '@salesforce/user/Id';

export default class Dsa_offerScreen extends NavigationMixin(LightningElement) {
    showSpinner = false;
    @api offerdata;
    coborrowerAnnualIncome;
    checksubmitdisabled=true;
    @track BElistOptions=[];
    @track prefBEId;
    selectedBE;
  //  disableCoborrowerIncomeField = false; //offerdata.disableCoborrowerIncomeField;
    @api applicantid;
    @api loanid;
    @api dsarecordId; // added for CISP-13870
    @track withdrawn = false; //added for CISP-13870
    @api recordId;
    disableTransferToBE = false;
    shallShowBETransferPopUp = false;

    currentPageReference;
    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (
            currentPageReference &&
            currentPageReference?.attributes?.recordId
        ) {
            this.recordId = currentPageReference.attributes.recordId;
        }
    }

    get transferToBEClass(){
        return this.disableTransferToBE ? "ibl-btn-red_disabled responsive-btn" : "ibl-btn-red responsive-btn";
    }

    async connectedCallback() {
        if (this.recordId) {
            this.showSpinner = true;
            await getOfferDetailsByRecordId({ recordId: this.recordId })
                .then((data) => {
                    if (data) {
                        let obj = {
                            maxEligibleLoanAmount : data.Final_Terms__r?.[0]?.Loan_Amount__c,
                            maxTenure : data.Final_Terms__r?.[0]?.Tenure__c,
                            irr : data.Final_Terms__r?.[0]?.CRM_IRR__c,
                            emi : data.Final_Terms__r?.[0]?.EMI_Amount__c
                        }
                        this.offerdata = obj;
                        if(!parseFloat(obj?.maxEligibleLoanAmount) > 0){
                            this.disableTransferToBE = true;
                        }
                    }
                    this.showSpinner = false;
                })
                .catch((e) => {
                    this.showSpinner = false;
                    this.showToast("Error", "Error retrieving loan details. Please try again or start a new application.", "error");
                });
        }
        GetBEDetails({userId :UserId,ApplicantId : this.applicantid}).then((response)=>{
            for (var key in response) {
                if(response[key].includes("__Preffered__")){
                    let val=response[key];
                   let actualval= val.replace('__Preffered__', '');
                   this.prefBEId=key;
                   this.selectedBE=key;
                    this.BElistOptions.push({ label: actualval, value: key });
                }else{
                    this.BElistOptions.push({ label: response[key], value: key });
                }
            }
        }).catch((error)=>{
            this.showToast("Error", "Error retrieving BE Details.", "error");
            console.log('error-->'+JSON.stringify(error));
        });

    }

    get submitBtnClass() {
        return this.coborrowerAnnualIncome ? "ibl-btn-ochre" : "ibl-btn-red_disabled";
    }

    showToast(toastTitle, message, variant) {
        const evt = new ShowToastEvent({
            title: toastTitle,
            message: message,
            variant: variant
        });
        this.dispatchEvent(evt);
    }

    handleBETransfer() {
        if(this.prefBEId ===null || this.prefBEId===undefined ||this.prefBEId===''){
            this.showToast("Error", 'BE name cannot be left blank', "Error");
        }
        else{
        this.shallShowBETransferPopUp = false;
        this.showSpinner=true;
        assignToBE({ loanId: this.loanid,UserId: this.selectedBE})
            .then((beName) => {
                this.showSpinner=false;
                this.showToast("All done!", 'Your application is transferred to BE "' + beName + '". Redirecting to home page...', "success");
                this[NavigationMixin.Navigate]({
                    type: "standard__namedPage",
                    attributes: {
                        pageName: "home"
                    }
                });
            })
            .catch((e) => {
                this.showSpinner=false;
                this.showToast("Error", JSON.stringify(e), "error");
            });
        }
    }

    handleCoborrowerSubmit() {
        this.showSpinner = true;
        createCoBorrower({
            loanApplication: this.loanid,
            applicant: this.applicantid,
            income: this.coborrowerAnnualIncome
        })
            .then(() => {
                this.template.querySelector("c-dsa_-b-r-e_engines").handleCheckEligibility(this.applicantid, this.loanid, false);
                this.showSpinner = false;
            })
            .catch((error) => {
                this.showToast("Error", error.body.message, "Error");
                this.showSpinner = false;
            });
    }

    handleScreening(event) {
        this.showSpinner = false;
    }

    handleIncome(event) {
        this.coborrowerAnnualIncome = event.target.value;
        if(this.coborrowerAnnualIncome !==null && this.coborrowerAnnualIncome !=='undefined'){
            this.checksubmitdisabled=false;
        }
    }

    handleBREComplete(event) {
        this.showSpinner = false;
        this.offerdata = event.detail;
        if(!parseFloat(this.offerdata?.maxEligibleLoanAmount) > 0){
            this.disableTransferToBE = true;
        }
    }

    handleSaveExit() {
        this[NavigationMixin.Navigate]({
            type: "standard__namedPage",
            attributes: {
                pageName: "home"
            }
        });
    }

    showBETransferPopUp() {
        this.shallShowBETransferPopUp = true;
    }

    hideBETransferPopUp() {
        this.shallShowBETransferPopUp = false;
    }
    handleBESelection(event){
        this.selectedBE=event.target.value;
    }
    async renderedCallback() {
        console.log('dsarecordId>>> offersccreen>> '+this.dsarecordId);
        /*CISP-13870 : START */
        await getLoanApplicationStageName({ loanApplicationId: this.recordId }).then(result => {
            console.log('getLoanApplicationStageName> '+JSON.stringify(result));
            if(result == "Withdrawn"){
                this.withdrawn = true;
            }
        });
        /*CISP-13870 : END */
    }
}