import { LightningElement, api, track, wire } from "lwc";
import { CurrentPageReference, NavigationMixin } from "lightning/navigation";
import getIncomeDetailsByRecordId from "@salesforce/apex/IND_DSAController.getIncomeDetailsByRecordId";
import getAssetDetailsByRecordId from "@salesforce/apex/IND_DSAController.getAssetDetailsByRecordId";
import getOfferDetailsByRecordId from "@salesforce/apex/IND_DSAController.getOfferDetailsByRecordId";
import getLoanApplicationStageName from '@salesforce/apex/LwcLOSLoanApplicationCntrl.getLoanApplicationStageName'; // CISP:20684
//SFD2C-148
import getDocumentdetailsByRecordId from "@salesforce/apex/IND_DSAController.getDocumentdetailsByRecordId";
export default class Dsa_summary_page extends NavigationMixin(LightningElement) {
    activeSections = ['A','B','C','D'];
    dob;
    gender;
    addressLine1;
    addressLine2;
    state;
    city;
    pinCode;
    applicantName;
    whatsAppNumberSameAsContactNumber;
    incomeSource;
    incomeCategory;
    borrincome;
    coborrincome;
    profile;
    monthlyExistingEMI;
    make;
    model;
    variant;
    estimatedAssetValue;
    customerMobile;
    whatsappNumber;
    maxEligibleLoanAmount;
    maxTenure;
    irr;
    emi;
    ApplicantDoB;//SFD2C-148
    @api dtWrapper;
    @track assetDetailsWrapper = {};
    @track withdrawn = false; //CISP-20684

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

    handleReturn(){

        this[NavigationMixin.Navigate]({
            type: "standard__objectPage",
            attributes: {
                actionName: "list",
                objectApiName: "Opportunity"
            }
        });
    }

    get hascoborrIncome(){
        return this.coborrincome ? true : false;
    }

    async connectedCallback() {
        getIncomeDetailsByRecordId({ recordId: this.recordId })
            .then((result) => {
                let borrower = result.find(e => e.Applicant_Type__c === "Borrower");
                let coborr = result.length > 1 ? result.find(e => e.Applicant_Type__c === "Co-borrower") : undefined;
                this.incomeSource = borrower?.Income_Source__c || coborr?.Income_Source__c;
                this.incomeCategory = borrower?.Income_Ca__c || coborr?.Income_Ca__c;
                this.profile = borrower?.Income_Details__r?.[0].Profile__r?.Name || coborr?.Income_Details__r?.[0].Profile__r?.Name;
                this.borrincome = borrower?.Income_Details__r?.[0].Income__c;
                this.coborrincome = coborr?.Income_Details__r?.[0].Income__c;
                this.monthlyExistingEMI = borrower?.Existing_EMIs__r?.[0].EMI__c || coborr?.Existing_EMIs__r?.[0].EMI__c;
                this.ApplicantDoB = borrower?.DSA_DOB__c;//SFD2C-148
            })
            .catch((error) => {
                console.log("error " + error);
            });
        getAssetDetailsByRecordId({ recordId: this.recordId })
            .then((result) => {
                this.assetDetailsWrapper = result;
                this.make = result.Vehicle_Details__r?.[0]?.Make__c;
                this.model = result.Vehicle_Details__r?.[0]?.Model__c;
                this.variant = result.Vehicle_Details__r?.[0]?.Variant__c;
                this.estimatedAssetValue = result.Vehicle_Details__r?.[0]?.Base_Price__c;
            })
            .catch((error) => {
                console.log("error " + error);
            });
        getOfferDetailsByRecordId({ recordId: this.recordId })
            .then((result) => {
                this.maxEligibleLoanAmount = result.Final_Terms__r?.[0]?.Loan_Amount__c;
                this.maxTenure = result.Final_Terms__r?.[0]?.Tenure__c;
                this.irr = result.Final_Terms__r?.[0]?.CRM_IRR__c;
                this.emi = result.Final_Terms__r?.[0]?.EMI_Amount__c;
            })
            .catch((error) => {
                console.log("error " + error);
            });
           // SFD2C-148
            getDocumentdetailsByRecordId({recordId: this.recordId})
            .then((result)=>{
                console.log('result--'+this.ApplicantDoB);
                if(result?.KYC_DOB__c){
                    this.dob = result.KYC_DOB__c;
                }
                else{
                    this.dob = this.ApplicantDoB;
                }
                if(result?.Gender__c){
                    this.gender = result.Gender__c;
                }
                else{
                    this.gender = this.dtWrapper.applicant.Gender__c;
                }

            }).catch((error) => {
                console.log("error " +JSON.stringify(error));
            });
        let salutation = this.dtWrapper.applicant?.Documents__r?.[0]?.Salutation__c;

        this.applicantName = (salutation
            ? salutation + " "
            : "") +
              this.dtWrapper.applicant.Customer_First_Name__c +
              " " +
              this.dtWrapper.applicant.Customer_Last_Name__c;
        this.whatsAppNumberSameAsContactNumber = this.dtWrapper.applicant.Contact_number__c === this.dtWrapper.applicant.Whatsapp_number__c;
        this.customerMobile = '+91 '+this.dtWrapper.applicant.Contact_number__c;
        this.whatsappNumber = '+91 '+this.dtWrapper.applicant.Whatsapp_number__c;
         /*CISP-CISP-20684 : START */
         await getLoanApplicationStageName({ loanApplicationId: this.recordId }).then(result => {
            console.log('getLoanApplicationStageName> '+JSON.stringify(result));
            if(result == "Withdrawn"){
                this.withdrawn = true;
            }
        });
         /*CISP-20684 : END */
    }
}