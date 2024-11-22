/* eslint-disable no-unused-vars */
import { LightningElement, api, track, wire } from "lwc";
import { getPicklistValues, getObjectInfo } from "lightning/uiObjectInfoApi";
import { createRecord, updateRecord } from "lightning/uiRecordApi";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { CurrentPageReference, NavigationMixin } from "lightning/navigation";
import createCoBorrower from "@salesforce/apex/IND_DSAController.createCoBorrower";
import getIncomeDetailsByRecordId from "@salesforce/apex/IND_DSAController.getIncomeDetailsByRecordId";
import getProfile from "@salesforce/apex/IND_DSAController.getProfile";
import RegEx_Number from "@salesforce/label/c.RegEx_Number";
import getLoanApplicationStageName from '@salesforce/apex/LwcLOSLoanApplicationCntrl.getLoanApplicationStageName'; // CISP:13870
import OBJECT_INCOME_DETAILS from "@salesforce/schema/Income_Details__c";
import OBJECT_EXISTING_EMI from "@salesforce/schema/Existing_EMI__c";
import APPLICANT from "@salesforce/schema/Applicant__c";
import INCOME_SOURCE_FIELD from "@salesforce/schema/Applicant__c.Income_Source__c";
import PROFILE_FIELD from "@salesforce/schema/Applicant__c.Profile__c";
import deleteCoborrower from '@salesforce/apex/DSA_WSController.deleteCoBorrower';

export default class Dsa_incomeScreen extends NavigationMixin(
    LightningElement
) {
    label = {
        RegEx_Number
    };
    applicantId;
    existingEmi;
    incomeSource;
    incomeCategory;
    profile;
    annualIncome;
    errors;
    incomeDetails = [];
    appDetails = [];
    @track coBorr;
    coBorrContact = false;
    coBorrText = false;
    incomeSourceList;
    showSpinnerReason = ["incomeSourceList"];
    isShowModal = false;
    recordId;
    renderedCallbackCalled = false;
    disableProfile = false;
    disableIncomeSource = false;
    incomeDetailsId;
    @track withdrawn = false; //FOR CISP-13870
    @api dsarecordId = false; // FOR CISP-13870
    existingEMIId;
    coborrowerId;
    modalMessage =
        "Are you sure you want to submit the details? \n All information entered, once submitted cannot be edited.";

    get showSpinner() {
        return this.showSpinnerReason.length !== 0;
    }

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

    //Income Source

    @wire(getObjectInfo, { objectApiName: APPLICANT })
    applicantObjectInfo;

    @wire(getPicklistValues, {
        recordTypeId: "$applicantObjectInfo.data.defaultRecordTypeId",
        fieldApiName: INCOME_SOURCE_FIELD
    })
    wiredIncomeSourceList(response) {
        if (response?.data) {
            this.incomeSourceList = response;
            this.removeSpinnerReason("incomeSourceList");
        }
    }

    removeSpinnerReason(reason) {
        this.showSpinnerReason = this.showSpinnerReason.filter(
            (item) => item !== reason
        );
    }

    //Profile (Sub-Category)
    @wire(getPicklistValues, {
        recordTypeId: "$applicantObjectInfo.data.defaultRecordTypeId",
        fieldApiName: PROFILE_FIELD
    })
    profileList;

    get incomeCategoryList() {
        return [
            { label: "Salaried", value: "SAL" },
            { label: "Self Employed Professional", value: "SEP" },
            { label: "Self Employed Non-Professional", value: "SENP" }
        ];
    }

    @api set applicant(value) {
        this.applicantId = value;
    }

    get applicant() {
        return this.applicantId;
    }

    get getProfileDisabled() {
        return !this.incomeCategory || this.disableProfile;
    }

    //prettier-ignore
    async renderedCallback() {
        if (this.recordId && !this.renderedCallbackCalled) {
            this.renderedCallbackCalled = true;
            getIncomeDetailsByRecordId({ recordId: this.recordId })
                .then((data) => {
                    if (data) {
                        let borrower = data.find(e => e.Applicant_Type__c === "Borrower");
                        let borcoborr = data.length > 1 ? data.find(e => e.Applicant_Type__c === "Co-borrower") : borrower;
                        this.coborrowerId = data.length > 1 ? data.find(e => e.Applicant_Type__c === "Co-borrower").Id : null;
                        this.incomeSource = borrower.Income_Source__c;
                        this.incomeCategory = borcoborr.Income_Ca__c;
                        this.profile = borcoborr.Income_Details__r?.[0].Profile__r?.Name;
                        this.annualIncome = borcoborr.Income_Details__r?.[0].Income__c;
                        this.existingEmi = borrower.Existing_EMIs__r?.[0].EMI__c;//SFD2C-147
                        this.template.querySelector(
                            "lightning-input[data-id=existingEmi]"
                        ).value = this.existingEmi;
                        this.incomeDetailsId = borcoborr.Income_Details__r?.[0].Id;
                        this.existingEMIId = borrower.Existing_EMIs__r?.[0].Id;//SFD2C-147
                    }
                }).then(()=>{
                    if(this.incomeCategory){
                        this.getProfileValues(this.incomeCategory);
                    }
                })
                .catch((error) => {
                    console.log('getIncomeDetailsByRecordId'+error);
                    this.showToast("Error", "Error occurred", "error");
                });
        }
        /*CISP-13870 : START */
        await getLoanApplicationStageName({ loanApplicationId: this.recordId }).then(result => {
            console.log('getLoanApplicationStageName> '+JSON.stringify(result));
            if(result == "Withdrawn"){
                this.withdrawn = true;
            }
        });
        /*CISP-13870 : END */
    }

    handleChange(event) {
        //let temp = event.target.data-id;
        let field = event.target.dataset.id;
        let value = event.target.value;
        this[field] = value;

        if (field === "incomeCategory") {
            this.getProfileValues(value);
            this.profile = null;
        }
        if(field === 'incomeSource'){
            this.incomeDetailsId = null;
            this.existingEMIId = null;
        }
    }

    validateEMIIncomeChange(event) {
        let fieldName = event.target.dataset.id;
        let emiField = this.template.querySelector(
            "lightning-input[data-id=existingEmi]"
        );
        let annualIncomeField = this.template.querySelector(
            "lightning-input[data-id=annualIncome]"
        );
        if (this.existingEmi && this.annualIncome) {
            let isValid =
                parseFloat(this.existingEmi) < parseFloat(this.annualIncome)/12;
            if (isValid) {
                emiField.setCustomValidity("");
                annualIncomeField.setCustomValidity("");
            } else {
                emiField.setCustomValidity(
                    "Monthly existing EMI should be less than Monthly Income."
                );
                annualIncomeField.setCustomValidity(
                    "Monthly income should be more than Monthly existing EMI."
                );
            }
            emiField.reportValidity();
            annualIncomeField.reportValidity();
        } else {
            emiField.setCustomValidity("");
            annualIncomeField.setCustomValidity("");
            if (fieldName === "existingEmi") {
                annualIncomeField.reportValidity();
            } else {
                emiField.reportValidity();
            }
        }
    }

    get showCoborrText() {
        return this.incomeSource === "Non-Earning";
    }

    async getProfileValues(value) {
        this.showSpinnerReason.push("getProfileValues");
        let profileArray = [];
        await getProfile({ category: value })
            .then((response) => {
                if (response && response.length > 0) {
                    for (let index = 0; index < response.length; index++) {
                        let profileData = {};
                        profileData.value = response[index].Name;
                        profileData.label = response[index].Name;
                        profileData.id = response[index].Id;
                        profileData.code = response[index].Code__c;
                        profileData.category = response[index].Category__c;
                        profileArray.push(profileData);
                    }
                    this.profileList = profileArray.sort((a, b) => {
                        let x = a.label.toUpperCase();
                        let y = b.label.toUpperCase();
                        if (x < y) return -1;
                        if (x > y) return 1;
                        return 0;
                    });
                }
                this.removeSpinnerReason("getProfileValues");
            })
            .catch((error) => {
                this.removeSpinnerReason("getProfileValues");
            });
    }

    async createCoBorrRecord() {
        console.log("Reached async method , applicantId : ", this.applicantId);
        this.coborrowerId = await createCoBorrower({
            borrowerId: this.applicantId,
            coborrowerId: this.coborrowerId,
            fields: this.appDetails
        });

        return this.createRelatedRecords(this.coborrowerId);
    }

    async createRelatedRecords(applicantId) {
        this.showSpinnerReason.push("createRelatedRecords");
        let upsert = this.incomeDetailsId
            ? updateRecord
            : createRecord;
        let incomeDetailsObject = {
            fields: {
                Income__c: this.annualIncome,
                Salaried_Self_employed__c:
                    this.incomeCategory === "SAL"
                        ? "Salaried"
                        : "Self employed",
                Is_Salaried__c: this.incomeCategory === "SAL",
                Is_Self_Employed__c: this.incomeCategory !== "SAL",
                Profile__c: this.profileList.find(
                    (e) => e.value === this.profile
                )?.id
            }
        }
        if(this.incomeDetailsId){
            incomeDetailsObject.fields.Id = this.incomeDetailsId;
        }else{
            incomeDetailsObject.apiName = this.incomeDetailsId ? null : OBJECT_INCOME_DETAILS.objectApiName;
            incomeDetailsObject.fields.Applicant__c = applicantId;
        }
        await upsert(incomeDetailsObject)
            .then(() => {
                if (this.existingEmi > 0) {
                    let upsertExistingEMI = this.existingEMIId ? updateRecord : createRecord;
                    let existingEMIObject = {
                        fields: {
                            EMI__c: this.existingEmi
                        }
                    };
                    if(this.existingEMIId){
                        existingEMIObject.fields.Id = this.existingEMIId;
                    }else{
                        existingEMIObject.apiName = this.existingEMIId ? null : OBJECT_EXISTING_EMI.objectApiName;
                        existingEMIObject.fields.Applicant_Id__c = this.applicantId;
                    }
                    upsertExistingEMI(existingEMIObject);
                }
                this.removeSpinnerReason("createRelatedRecords");
            })
            .catch((error) => {
                this.showToast("Error", error.body.message, "error");
                this.removeSpinnerReason("createRelatedRecords");
            });
    }

    @api
    validateFields() {
        console.log("called validateFields");
        let errors = [];
        [
            ...this.template.querySelectorAll("lightning-input"),
            ...this.template.querySelectorAll("lightning-combobox")
        ].reduce((validSoFar, inputField) => {
            inputField.reportValidity();
            if (!inputField.checkValidity() && inputField.label) {
                errors.push(inputField.label);
            }
            return validSoFar && inputField.checkValidity();
        }, true);
        return errors;
    }

    handleNextClick() {
        let errors = this.validateFields();
        if (errors.length === 0) {
            this.isShowModal = true;
        } else {
            this.showToast(
                "Error",
                "Invalid " + errors.join(", "),
                "error"
            );
            this.removeSpinnerReason("next");
        }
    }

    handleModalCancel() {
        this.isShowModal = false;
    }

    async handleModalConfirm(btnName) {
        this.isShowModal = false;
        this.showSpinnerReason.push("next");
        //this.applicantId = "a0UC400000040ELMAY";
        let applicantRecord = {
            fields: {
                Id: this.applicantId,
                Income_Source__c: this.incomeSource,
                Income_Ca__c:
                    this.incomeSource === "Earning" ? this.incomeCategory : "",
                Profile__c: this.incomeSource === "Earning" ? this.profile : "",
                Declared_income__c:
                    this.incomeSource === "Earning" ? this.annualIncome : "",
                Income_source_available__c: this.incomeSource === "Earning" ? true : false,
                Who_will_repay_the_loan__c:
                    this.incomeSource === "Earning" ? "Borrower" : "Co-borrower"
            }
        };
        await updateRecord(applicantRecord)
            .then(() => {
                if (this.incomeSource === "Earning") {
                    this.createRelatedRecords(this.applicantId);
                     deleteCoborrower({AppId: this.applicantId}).catch((error)=>{
                        console.error(error);
                    });
                } else {
                    console.log("in Non-Earning part ");
                    this.appDetails.push(
                        this.incomeSource,
                        this.incomeCategory,
                        this.profile,
                        this.annualIncome,
                        this.existingEmi
                    );
                    this.createCoBorrRecord();
                }
            })
            .then(() => {
                if (btnName !== "saveandexitbtn") {
                    this.dispatchEvent(new CustomEvent("complete"));
                    this.removeSpinnerReason("next");
                }
            })
            .catch((error) => {
                this.showToast("Error", JSON.stringify(error), "error");
                this.removeSpinnerReason("next");
            });

    }

    async handleSaveExitClick(event) {
        this.showSpinnerReason.push("saveexit");
        await this.handleModalConfirm(event.target.name);
        this.removeSpinnerReason("saveexit");
        this.showToast("Success", "Lead saved successfully", "success");
        this[NavigationMixin.Navigate]({
            type: "standard__namedPage",
            attributes: {
                pageName: "home"
            }
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