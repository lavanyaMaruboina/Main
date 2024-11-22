/* eslint-disable no-unused-vars  */
import { LightningElement, track, wire, api } from "lwc";
import { CurrentPageReference, NavigationMixin } from "lightning/navigation";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { getPicklistValues } from "lightning/uiObjectInfoApi";
import { getObjectInfo } from "lightning/uiObjectInfoApi";
import {
    createRecord,
    updateRecord,
    getRecordNotifyChange
} from "lightning/uiRecordApi";
import { loadStyle } from "lightning/platformResourceLoader";
import DSAStyles from "@salesforce/resourceUrl/DSAStyles";
import APPLICANT from "@salesforce/schema/Applicant__c";
import DOC_OBJECT from "@salesforce/schema/Documents__c";
import CDR_OBJECT from "@salesforce/schema/Customer_Dedupe_Response__c";
import GENDER_FIELD from "@salesforce/schema/Documents__c.Gender__c";
import SALUTATION_FIELD from "@salesforce/schema/Documents__c.Salutation__c";

//START-Apex Methods
import initializeNewLeadData from "@salesforce/apex/IND_DSAController.initializeNewLeadData";
import getLoanByRecordId from "@salesforce/apex/IND_DSAController.getLoanByRecordId";
import saveLead from "@salesforce/apex/IND_DSAController.saveLead";
import getStateCityMaster from "@salesforce/apex/IND_DSAController.getStateCityMaster";
import doPANCallout from "@salesforce/apexContinuation/IntegrationEngine.doPANCallout";
import updateConsentStatus from "@salesforce/apex/StoreDateTimeForConcent.updateConsentStatus";
import otpExpireTimeOut from "@salesforce/apex/LwcLOSLoanApplicationCntrl.otpExpireTimeOut";
import doSmsCallout from "@salesforce/apexContinuation/IntegrationEngine.doSmsGatewayCallout";
import sendConsentSMS from "@salesforce/apex/LwcLOSLoanApplicationCntrl.sendConsentSMS";
import doExternalDedupeAPICallout from "@salesforce/apexContinuation/IntegrationEngine.doExternalDedupeCallout";
import getRetryCount from "@salesforce/apex/IND_DSAController.getRetryCount";
import validateCustomerCode from "@salesforce/apex/IND_DSAController.validateCustomerCode";
//END-Apex Methods

//START-Labels
import Address_Pattern from "@salesforce/label/c.Address_Pattern";
import AddressnotValid from "@salesforce/label/c.AddressnotValid";
import Age_Max from "@salesforce/label/c.Age_Max";
import Age_Min from "@salesforce/label/c.Age_Min";
import Mobile_Number_Error_Msg from "@salesforce/label/c.Mobile_Number_Error_Msg";
import Pan_Pattern from "@salesforce/label/c.Pan_Pattern";
import Pin_code_Pattern from "@salesforce/label/c.Pin_code_Pattern";
import RegEx_Alphabets_Only from "@salesforce/label/c.RegEx_Alphabets_Only";
import Regex_Alphabets_Only_DSA from "@salesforce/label/c.Regex_Alphabets_Only_DSA";
import RegEx_Number from "@salesforce/label/c.RegEx_Number";
import Salutations_List from "@salesforce/label/c.Salutations_List";
import otpSentSuccessfully from "@salesforce/label/c.otpSentSuccessfully";
import otpSend from "@salesforce/label/c.otpSend";
import FailResponseApi from "@salesforce/label/c.FailResponseApi";
import userDetails from "@salesforce/label/c.userDetails";
import CheckOtp from "@salesforce/label/c.CheckOtp";
import WrongOtp from "@salesforce/label/c.WrongOtp";
import ToastError from "@salesforce/label/c.ToastError";
import getLoanApplicationStageName from '@salesforce/apex/LwcLOSLoanApplicationCntrl.getLoanApplicationStageName'; // CISP:13870
//END-Labels
const DEDUPE_SPINNER_TEXT = "Please wait... This may take upto 1 minute.";
const DEDUPE_SPINNER_TEXT2 =
    "This is taking longer than expected... This may take upto 1 minute.";
export default class Dsa_createNewLead extends NavigationMixin(
    LightningElement
) {
    label = {
        Address_Pattern,
        AddressnotValid,
        Age_Max,
        Age_Min,
        Mobile_Number_Error_Msg,
        Pan_Pattern,
        Pin_code_Pattern,
        RegEx_Alphabets_Only,
        Regex_Alphabets_Only_DSA,
        RegEx_Number,
        otpSend,
        otpSentSuccessfully,
        FailResponseApi,
        userDetails,
        CheckOtp,
        WrongOtp,
        ToastError
    };
    screens = {
        initialScreen: 0,
        incomeScreen: 10,
        assetScreen: 20,
        offerScreen: 30,
        summaryPage: 40
    };

    //Form fields
    applicantId;
    leadNumber;
    customerMobile;
    whatsAppNumber;
    firstName;
    lastName;
    gender;
    addressLine1;
    addressLine2;
    city;
    state;
    pincode;
    panNumber;
    dob;
    registerForWhatsAppBanking = true;
    //END Form fields
    @track offerValue;
    spinnerText;
    cardTitle = "New Lead";
    screenName;
    disablePANField = false;
    panverified = false;
    panVerifyCount = 0;
    whatsAppNumberSameAsContactNumber = true;
    showSpinner = true;
    stateCityMap = new Map();
    modalPopUpToggleFlag = false;
    consentReceived = false;
    matchingCustomerCode;
    @track dataWrapper;
    @track stateList = [];
    @track customerCodeList = [];
    invalidOTPCount = 0;
    isShowModal = false;
    @api mode;
    disablePincode = false;
    disableSaveExit = false;
    dedupeJourneyStatus;
    modalMessage =
        "Are you sure you want to submit the details? \n All information entered, once submitted cannot be edited.";
    //DEDUPE_PROPS

    externalDedupeAPIMaxAttempts;
    dsarecordId;   // added for CISP-13870
    externalDedupeAPICurrentAttempts;
    customerDedupeResponse;
    cicNo;
    custFlag;
    recordId;
    renderedCallbackCalled = false;
    stateCityMaster;
    //END

    cityList = [];
    incomeScreenErrors = [];
    panDocId;

    currentPageReference;
    @track withdrawn = false; //FOR CISP-13870
    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (
            currentPageReference &&
            currentPageReference?.attributes?.recordId
        ) {
            this.recordId = currentPageReference.attributes.recordId;
        }
    }

    /* START - GET PICKLIST METHODS */

    @wire(getObjectInfo, { objectApiName: APPLICANT })
    applicantObjectInfo;

    @wire(getObjectInfo, { objectApiName: DOC_OBJECT })
    docObjectInfo;

    //Gender
    @wire(getPicklistValues, {
        recordTypeId: "$docObjectInfo.data.defaultRecordTypeId",
        fieldApiName: GENDER_FIELD
    })
    genderValues;

    //Gender
    @wire(getPicklistValues, {
        recordTypeId: "$docObjectInfo.data.defaultRecordTypeId",
        fieldApiName: SALUTATION_FIELD
    })
    salutationValues;
    /* END - GET PICKLIST METHODS */

    @api
    get getStateDisabled() {
        return (
            this.stateList.length === 0 ||
            (this.recordId && this.consentReceived)
        );
    }

    @api
    get getCityDisabled() {
        return (
            this.cityList.length === 0 ||
            (this.recordId && this.consentReceived)
        );
    }

    @api
    get getPincodeDisabled() {
        return this.cityList.length === 0 || this.disablePincode;
    }

    @api
    get getSalutationDisabled() {
        return (
            !this.salutationValues ||
            this.salutationValues.length === 0 ||
            (this.recordId && this.consentReceived)
        );
    }

    @api
    get getGenderDisabled() {
        return (
            !this.genderValues ||
            this.genderValues?.length === 0 ||
            (this.recordId && this.consentReceived)
        );
    }

    @api
    get disableConsentBtn() {
        return !this.panverified;
    }

    @api
    get consentBtnClass() {
        return this.panverified ? "ibl-btn-ochre" : "ibl-btn-red_disabled";
    }

    @api
    get verifyPANBtnClass() {
        return this.panverified ? "ibl-btn-red_disabled" : "ibl-btn-ochre";
    }

    @api
    get saveExitBtnClass() {
        return this.consentReceived
            ? "ibl-btn-red_disabled responsive-btn"
            : "ibl-btn-red_secondary responsive-btn";
    }

    @api
    get showInitialScreen() {
        return this.screenName === this.screens.initialScreen;
    }

    @api
    get showIncomeScreen() {
        return this.screenName === this.screens.incomeScreen;
    }

    @api
    get showAssetScreen() {
        return this.screenName === this.screens.assetScreen;
    }

    @api
    get showOfferScreen() {
        return this.screenName === this.screens.offerScreen;
    }
    @api
    get showSummaryPage() {
        return this.screenName === this.screens.summaryPage;
    }

    @api
    get getShowSpinner() {
        return this.showSpinner;
    }
    @api
    get offerData(){
        return this.offerValue;
    }
    kycDocRecordTypeId;
    get kycDocRecordType() {
        let rtId = this.kycDocRecordTypeId;
        if (!rtId) {
            Object.keys(this.docObjectInfo.data.recordTypeInfos).forEach(
                (e) => {
                    if (
                        this.docObjectInfo.data.recordTypeInfos[e].name ===
                        "KYC Document"
                    ) {
                        rtId = e;
                    }
                }
            );
        }
        return rtId;
    }

    async connectedCallback() {
        loadStyle(this, DSAStyles); //Fix for the input phone css not in center
        await this.loadStateCities();
        this.showSpinner = true;
        if (!this.recordId) {
            initializeNewLeadData()
                .then((response) => {
                    this.dataWrapper = response;
                    this.leadNumber = response.opp.Lead_number__c;
                    this.dsarecordId = response.opp.Id; // added for CISP-13870
                    console.log('this.dsarecordId>> '+this.dsarecordId) // added for CISP-13870
                    this.showSpinner = false;

                    this[NavigationMixin.Navigate]({
                        type: 'standard__webPage',
                        attributes: {
                            url: window.location.origin + '/referfromeasywheels/s/opportunity/' + response.opp.Id + '/' + response.opp.Lead_number__c
                        }
                    }, true);
                })
                .catch((error) => {
                    this.showToast(
                        "Error",
                        "Error initiating new application",
                        "error"
                    );
                    this.showSpinner = false;
                });
            this.screenName = this.screens.initialScreen;
        }
    }

    async renderedCallback() {
        if (this.recordId && !this.renderedCallbackCalled) {
            this.renderedCallbackCalled = true;
            this.dsarecordId = this.recordId;
            getLoanByRecordId({ recordId: this.recordId })
                .then((result) => {
                    this.applicantId = result.applicant.Id;
                    this.dataWrapper = result;
                    if (result.opp.DSA_Stage__c == undefined || result.opp.DSA_Stage__c === "Initial") {
                        this.repopulateFields();
                        this.showSpinner = false;
                        getRecordNotifyChange([{ recordId: this.recordId }]);
                        this.screenName = this.screens.initialScreen;
                    } else if (result.opp.DSA_Stage__c === "Income") {
                        this.screenName = this.screens.incomeScreen;
                    } else if (result.opp.DSA_Stage__c === "Asset") {
                        this.screenName = this.screens.assetScreen;
                    } else if (result.opp.DSA_Stage__c === "Offer") {
                        this.screenName = this.screens.offerScreen;
                    } else if (result.opp.DSA_Stage__c === "Transferred") {
                        this.screenName = this.screens.summaryPage;
                    }
                })
                .catch((error) => {
                    this.showToast(
                        "Error",
                        "Error retrieving loan details. Please try again or start a new application.",
                        "error"
                    );
                });
        }
        await getLoanApplicationStageName({ loanApplicationId: this.recordId }).then(result => { 
            console.log('getLoanApplicationStageName> '+JSON.stringify(result));
            if(result == "Withdrawn"){
                this.withdrawn = true;
            }
        });
        /*CISP-13870 : END */
        
    }

    repopulateFields() {
        const applicantFieldMap = new Map([
            ["Id", "applicantId"],
            ["Contact_number__c", "customerMobile"],
            ["Consent_Received__c", "consentReceived"],
            ["Customer_First_Name__c", "firstName"],
            ["Customer_Last_Name__c", "lastName"],
            ["Office_Address_Line_1__c", "addressLine1"],
            ["Office_Address_Line_2__c", "addressLine2"],
            ["Office_State__c", "state"],
            ["Office_City__c", "city"],
            ["Office_PinCode__c", "pincode"],
            ["Whatsapp_number__c", "whatsAppNumber"],
            ["Register_for_WhatsApp_Banking__c", "registerForWhatsAppBanking"]
        ]);
        const documentsFieldMap = new Map([
            ["Id", "panDocId"],
            ["Gender__c", "gender"],
            ["KYC_DOB__c", "dob"],
            ["PAN_No__c", "panNumber"],
            ["Salutation__c", "salutation"]
        ]);

        this.leadNumber = this.dataWrapper.opp.Lead_number__c;
        if (this.dataWrapper.applicant) {
            Object.keys(this.dataWrapper.applicant).forEach((field) => {
                if (applicantFieldMap.has(field)) {
                    this[applicantFieldMap.get(field)] =
                        this.dataWrapper.applicant[field];
                }
            });
        }

        if (this.dataWrapper.applicant?.Documents__r?.[0]) {
            Object.keys(this.dataWrapper.applicant?.Documents__r?.[0]).forEach(
                (field) => {
                    if (documentsFieldMap.has(field)) {
                        this[documentsFieldMap.get(field)] =
                            this.dataWrapper.applicant?.Documents__r[0][field];
                    }
                }
            );
        }

        if (this.dataWrapper.opp.Integration_Log__r?.length > 0) {
            this.dataWrapper.opp.Integration_Log__r.forEach((e) => {
                if (
                    e.Service_Name__c === "PAN Verification" &&
                    e.Status__c === "Success"
                ) {
                    let json = JSON.parse(e.Original_response__c);
                    this.panverified =
                        json.response.content[0].NSDLPANStatus === "E";
                    this.disablePANField = this.panverified;
                }
            });
        }

        if (this.state) {
            this.handleStateSelection({ target: { value: this.state } });
        }

        if (this.consentReceived) {
            //Tried many other things but nothing worked so used setTimeout - Swapnil
            setTimeout(()=>{this.disableAll()}, 1000);
        }
        this.applicantId = this.dataWrapper.applicant.Id;
    }

    loadStateCities() {
        getStateCityMaster()
            .then((data) => {
                if (data) {
                    this.stateCityMaster = data;
                    this.stateList = [];
                    data.forEach((state) => {
                        this.stateList.push({
                            label: state.Name,
                            value: state.Name
                        });
                        if (state.City_State_Masters__r?.length > 0) {
                            this.stateCityMap.set(
                                state.Name,
                                state.City_State_Masters__r
                            );
                        } else {
                            this.stateCityMap.set(state.Name, [
                                { State__c: state.Id, Name: state.Name }
                            ]);
                        }
                    });
                }
            })
            .catch((error) => {
                if (error) {
                    this.showToast(
                        "Error",
                        "Error retrieving state city data",
                        "error"
                    );
                }
            });
    }

    handleCustomerMobileChange(event) {
        let customerMobile = event.target.value;
        let whatsAppNumberSameAsContactNumber = this.template.querySelector(
            "lightning-input[data-id=whatsAppNumberSameAsContactNumber]"
        ).checked;
        let customerMobileField = this.template.querySelector(
            "lightning-input[data-id=customerMobile]"
        );
        customerMobileField.reportValidity();
        if (
            whatsAppNumberSameAsContactNumber &&
            customerMobileField.checkValidity() &&
            customerMobile?.length > 0
        ) {
            this.whatsAppNumber = customerMobile;
            console.log(
                this.template.querySelector(
                    "lightning-input[data-id=whatsAppNumber]"
                ).value
            );
        }
    }

    handleStateSelection(event) {
        let selectedState = event.target.value;
        if (selectedState !== "") {
            this.cityList = this.stateCityMap
                .get(selectedState)
                .map((city) => ({
                    label: city.Name,
                    value: city.Name
                }))
                .sort((a, b) => {
                    let x = a.label.toUpperCase();
                    let y = b.label.toUpperCase();
                    if (x < y) return -1;
                    if (x > y) return 1;
                    return 0;
                });
        } else {
            this.cityList = [];
        }
    }

    handleCheckBoxChange(event) {
        let cbName = event.target.name;
        if (cbName === "whatsAppNumberSameAsContactNumber") {
            if (event.target.checked) {
                let customerMobileField = this.template.querySelector(
                    "lightning-input[data-id=customerMobile]"
                );
                let whatsAppField = this.template.querySelector(
                    "lightning-input[data-id=whatsAppNumber]"
                );
                customerMobileField.reportValidity();
                if (customerMobileField.checkValidity()) {
                    this.customerMobile = customerMobileField.value;
                    whatsAppField.value = this.customerMobile;
                    this.whatsAppNumber = this.customerMobile;
                    whatsAppField.reportValidity();
                    this.whatsAppNumberSameAsContactNumber = true;
                } else {
                    event.target.checked = false;
                }
            } else {
                this.whatsAppNumberSameAsContactNumber = false;
                this.whatsAppNumber = "";
            }
        }
    }

    //prettier-ignore
    validateSaveExitFields() {
        let errors = [];
        if (this.screenName === this.screens.initialScreen) {    
        [
            this.template.querySelector("lightning-input[data-id=customerMobile]"),
            this.template.querySelector("lightning-input[data-id=firstName]"),
            this.template.querySelector("lightning-input[data-id=lastName]")
        ].reduce((validSoFar, inputField) => {
            inputField.reportValidity();
            if (!inputField.checkValidity() && inputField.label) {
                errors.push(inputField.label);
            }
            return validSoFar && inputField.checkValidity();
        }, true);
        }
        else if (this.screenName === this.screens.incomeScreen) {
           errors = this.incomeScreenErrors;
        }

        return errors;
    }

    validateFields() {
        let errors = [];
        if (this.screenName === this.screens.initialScreen) {
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
        } else if (this.screenName === this.screens.incomeScreen) {
            errors = this.incomeScreenErrors;
        }
        return errors;
    }

    validateDob() {
        let minAge = parseInt(this.label.Age_Min, 10);
        let maxAge = parseInt(this.label.Age_Max, 10);
        let today = new Date();
        let dob = new Date(
            this.template.querySelector("lightning-input[data-id=dob]").value
        );
        let compare_date = (today.getDate() + 1);
        compare_date = compare_date > 31 ? 31 : compare_date;
        if(today.getMonth() === 1 && compare_date > 28){
            compare_date = 28;
        }
        if(compare_date > 30 && (today.getMonth() === 3 || today.getMonth() === 5 || today.getMonth() === 8 || today.getMonth() === 10)){
            compare_date = 30;
        }
        let minDate = new Date(
            today.getFullYear() -
                minAge +
                "-" +
                String(today.getMonth() + 1).padStart(2, "0") +
                "-" +
                compare_date
        );
        let maxDate = new Date(
            today.getFullYear() -
                maxAge +
                "-" +
                String(today.getMonth() + 1).padStart(2, "0") +
                "-" +
                compare_date
        );
        return dob > maxDate && dob < minDate;
    }

    handleDobChange(event) {
        let isDobValid = this.validateDob();
        let dobField = this.template.querySelector(
            "lightning-input[data-id=dob]"
        );
        if (!isDobValid) {
            dobField.setCustomValidity("Min age is 18 and Max age is 80");
        } else {
            dobField.setCustomValidity("");
        }
        dobField.reportValidity();
    }

    handlePincodeChange(event) {
        let pincodeField = this.template.querySelector(
            "lightning-input[data-id=pincode]"
        );
        let pincode = pincodeField.value;
        let pincodemin, pincodemax;
        let state = this.template.querySelector(
            "lightning-combobox[data-id=state]"
        ).value;
        if (state && this.stateCityMaster) {
            let stateData = this.stateCityMaster.forEach((st) => {
                if (st.Name === state) {
                    pincodemin = st.Pincode__c;
                    pincodemax = st.Pincode_Starting_Max__c;
                }
            });
        }
        if (pincode && pincodemin && pincodemax) {
            let pincodeprefix = parseInt(pincode.substring(0, 2), 10);
            let isValid =
                pincodeprefix >= pincodemin && pincodeprefix <= pincodemax;
            if (isValid) {
                pincodeField.setCustomValidity("");
            } else {
                pincodeField.setCustomValidity(
                    "Pincode doesn't belong to the selected state"
                );
            }
            pincodeField.reportValidity();
        }
        //TODO validate pincode
    }

    handleNextClick() {
        this.showSpinner = true;
        let errors = [];

        errors = this.validateFields();
        if (errors.length > 0) {
            this.showToast("Error", "Invalid " + errors.join(", "), "error");
            this.showSpinner = false;
        } else {
            this.spinnerText = DEDUPE_SPINNER_TEXT;
            this.processFormFields();
            if (this.consentReceived && this.panverified) {
                this.saveLead()
                    .then(() => {
                        let panDoc = this.getPanObject();
                        let upsert = this.panDocId
                            ? updateRecord
                            : createRecord;
                        upsert(panDoc);
                        console.log("calling dedupe apex method:" + new Date());
                        this.doDedupe();
                    })
                    .catch((error) => {
                        this.showToast("Error", error, "error");
                        this.showSpinner = false;
                        this.spinnerText = null;
                    });
            } else {
                let message = !this.consentReceived
                    ? "Consent required"
                    : !this.panverified
                    ? "PAN verification required"
                    : "Error occurred";
                this.showToast("Error", message, "error");
                this.showSpinner = false;
                this.spinnerText = null;
            }
            // }
        }
    }

    handleSaveExitClick(event) {
        //Here we just want to validate non null fields and save
        //So that DSA can pick up the application later
        this.showSpinner = true;
        let errors = this.validateSaveExitFields();
        if (errors.length > 0) {
            this.showToast("Error", "Invalid " + errors.join(", "), "error");
            this.showSpinner = false;
        } else {
            this.processFormFields();
            this.saveLead()
                .then(() => {
                    //Save Update Document Record
                    let panDoc = this.getPanObject();
                    let upsert = this.panDocId ? updateRecord : createRecord;
                    upsert(panDoc);
                    updateRecord({
                        fields:{
                            Id: this.recordId || this.dataWrapper.opp.Id,
                            DSA_Stage__c: 'Initial'
                        }
                    })
                })
                .then(() => {
                    this.showToast(
                        "Success",
                        "Lead saved successfully",
                        "success"
                    );
                    this.showSpinner = false;
                    this[NavigationMixin.Navigate]({
                        type: "standard__namedPage",
                        attributes: {
                            pageName: "home"
                        }
                    });
                })
                .catch((error) => {
                    this.showToast("Error", "Error saving new lead", "error");
                    this.showSpinner = false;
                });
        }
    }

    validatePANVerifyFields() {
        let errors = [];
        [
            this.template.querySelector(
                "lightning-input[data-id=customerMobile]"
            ),
            this.template.querySelector("lightning-input[data-id=firstName]"),
            this.template.querySelector("lightning-input[data-id=lastName]"),
            this.template.querySelector("lightning-input[data-id=panNumber]"),
            this.template.querySelector(
                "lightning-combobox[data-id=salutation]"
            )
        ].reduce((validSoFar, inputField) => {
            inputField.reportValidity();
            if (!inputField.checkValidity() && inputField.label) {
                errors.push(inputField.label);
            }
            return validSoFar && inputField.checkValidity();
        }, true);
        return errors;
    }

    handleVerifyPANClick(event) {
        let errors = this.validatePANVerifyFields();
        if (errors.length > 0) {
            this.showToast("Error", "Invalid " + errors.join(", "), "error");
        } else {
            this.showSpinner = true;
            this.processFormFields();
            this.saveLead().then(() => {
                this.verifyPAN();
            });
        }
    }

    handleConsentClick(event) {
        let errors = this.validateFields();
        if (errors.length > 0) {
            this.showToast("Error", "Invalid " + errors.join(", "), "error");
            this.showSpinner = false;
        } else {
            this.isShowModal = true;
        }
    }

    handleModalConfirm(event) {
        this.isShowModal = false;
        let errors = this.validateFields();
        if (errors.length > 0) {
            this.showToast("Error", "Invalid " + errors.join(", "), "error");
            this.showSpinner = false;
        } else {
            this.consentReceived = false;
            if (
                this.modalPopUpToggleFlag === false &&
                this.applicantId !== ""
            ) {
                updateRecord({
                    fields: {
                        Id: this.applicantId,
                        Contact_number__c: this.template.querySelector(
                            "lightning-input[data-id=customerMobile]"
                        ).value,
                        Whatsapp_number__c: this.template.querySelector(
                            "lightning-input[data-id=whatsAppNumber]"
                        ).value
                    }
                }).then(() => {
                    this.modalPopUpToggleFlag = true; //To open otp pop-up
                    updateConsentStatus({ applicantId: this.applicantId })
                        .then((result) => {
                            this.template
                                .querySelector("c-l-W-C_-L-O-S_-O-T-P")
                                .showResendTimer();
                            if (result) {
                                this.consentfirstTime = true;
                            } else {
                                this.consentfirstTime = false;
                            }
                            this.gettimeout();
                        })
                        .catch((error) => {
                            this.showToast(
                                "Error",
                                "Error getting consent",
                                "error"
                            );
                        });
                });
            }
        }
    }

    handleModalCancel() {
        this.isShowModal = false;
    }

    gettimeout() {
        otpExpireTimeOut({ applicantId: this.currentapplicationid })
            .then((result) => {
                if (result || this.consentfirstTime) {
                    sendConsentSMS({ applicantId: this.applicantId })
                        .then((response) => {
                            this.response = response;
                            this.doSmsApiCall();
                        })
                        .catch((error) => {
                            this.error = error;
                        });
                } else {
                    this.showToast("Warning", this.label.otpSend, "warning");
                }
            })
            .catch((error) => {
                this.showToast("Error", "Error", "error");
            });
    }
    doSmsApiCall() {
        let smsRequestString = {
            loanApplicationId: this.dataWrapper.opp.Id,
            flag: "OTP",
            applicantId: this.applicantId
        };
        doSmsCallout({ smsRequestString: JSON.stringify(smsRequestString) })
            .then((result) => {
                if (result === "SUCCESS") {
                    this.showToast(
                        "Success",
                        this.label.otpSentSuccessfully,
                        "success"
                    );
                } else {
                    this.showToast(
                        "Warning",
                        this.label.FailResponseApi,
                        "warning"
                    );
                }
            })
            .catch((error) => {
                this.showToast("Error", "Error sending SMS", "error");
            });
    }

    handleOTPVerify() {
        this.showSpinner = true;
        this.consentReceived = true;
        this.modalPopUpToggleFlag = false;
        this.disableSaveExit = true;
        this.processFormFields();
        this.saveLead().then(()=>{
            let panDoc = this.getPanObject();
            let upsert = this.panDocId
                ? updateRecord
                : createRecord;
            upsert(panDoc).then(()=>{
                this.disableAll();
                this.showSpinner = false;
            })
            .catch(e=>{
                this.showSpinner = false;
                console.log(e);
            })
        })
        .catch(e=>{
            this.showSpinner = false;
            console.log(e);
        })
    }

    handleModalManualClose() {
        this.modalPopUpToggleFlag = false;
    }

    handleInvalidOTP() {
        this.invalidOTPCount++;
        if (this.invalidOTPCount >= 3) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: "Error",
                    message:
                        "OTP verification retries exhausted. Please try later.",
                    variant: "error",
                })
            );
            this.modalPopUpToggleFlag = false;
            this[NavigationMixin.Navigate]({
                type: "standard__namedPage",
                attributes: {
                    pageName: "home"
                }
            });
        }else{
            this.dispatchEvent(new ShowToastEvent({
                title: this.label.WrongOtp,
                message: this.label.CheckOtp,
                variant: this.label.ToastError
            }));
        }
    }

    handleResendExhausted(){
        this.dispatchEvent(
            new ShowToastEvent({
                title: "Error",
                message:
                    "OTP resend exhausted. Please try later.",
                variant: "error",
            })
        );
        this.modalPopUpToggleFlag = false;
        this[NavigationMixin.Navigate]({
            type: "standard__namedPage",
            attributes: {
                pageName: "home"
            }
        });
    }

    disableAll() {
        [...this.template.querySelectorAll("lightning-input")].forEach(
            (elem) => {
                elem.disabled = true;
            }
        );
        [...this.template.querySelectorAll("lightning-combobox")].forEach(
            (elem) => {
                elem.disabled = true;
            }
        );
        [...this.template.querySelectorAll("lightning-checkbox")].forEach(
            (elem) => {
                elem.disabled = true;
            }
        );
        this.disablePincode = true;
    }

    handleComplete() {
        this.showSpinner = true;
        if (this.screenName === this.screens.incomeScreen) {
            updateRecord({
                fields: {
                    Id: this.recordId || this.dataWrapper.opp.Id,
                    DSA_Stage__c: "Asset"
                }
            })
                .then(() => {
                    this.showSpinner = false;
                    this.screenName = this.screens.assetScreen;
                })
                .catch((error) => {
                    this.showSpinner = false;
                    this.showToast(
                        "Error",
                        "Error saving lead. Please try again.",
                        "error"
                    );
                });
        }
    }

    handleBREComplete(event) {
        this.offerValue=event.detail;
        console.log('create new lead data->'+event.detail);
        updateRecord({
            fields: {
                Id: this.recordId || this.dataWrapper.opp.Id,
                DSA_Stage__c: "Offer"
            }
        }).then(() => {
            this.screenName = this.screens.offerScreen;
        });
    }

    // handleincomeScreenData(event) {
    //     if (event.detail.incomeSource === "Earning") {
    //         this.dataWrapper.applicant.Income_Source__c =
    //             event.detail.incomeSource;
    //         this.dataWrapper.applicant.Income_Ca__c =
    //             event.detail.incomeCategory;
    //         this.dataWrapper.applicant.Profile__c = event.detail.profile;
    //         this.dataWrapper.applicant.Declared_Income__c =
    //             event.detail.annualIncome;
    //         this.dataWrapper.applicant.EMI_paid__c = event.detail.existingEMI;
    //     }
    //     //this.dataWrapper.applicant.Id = this.applicantId;
    //     this.incomeScreenErrors = event.detail.errors;
    // }

    async verifyPAN() {
        if (this.panVerifyCount > 1) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: "Error",
                    message:
                        "PAN verification retries exhausted. Please try later.",
                    variant: "error"
                })
            );
            this[NavigationMixin.Navigate]({
                type: "standard__namedPage",
                attributes: {
                    pageName: "home"
                }
            });
        } else {
            this.panVerifyCount++;
            this.showSpinner = true;
            let kycPanDetails = {
                applicantId: this.applicantId, //Applicant__c.Id
                panNumber: this.dataWrapper.applicant.PAN_No__c, //Applicant__c.PAN_No__c
                firstName: this.dataWrapper.applicant.Customer_First_Name__c, //Applicant__c.Customer_First_Name__c
                lastName: this.dataWrapper.applicant.Customer_Last_Name__c, //Applicant__c.Customer_Last_Name__c
                loanApplicationId: this.dataWrapper.opp.Id, //Opportunity.Id
                leadId: this.dataWrapper.opp.Lead_number__c
            };

            await doPANCallout({
                kycPanDetailRequest: JSON.stringify(kycPanDetails)
            })
                .then((result) => {
                    const obj = JSON.parse(result);
                    console.log("PAN verify response");
                    console.log(obj);
                    let panDoc;
                    if (obj.response.content[0].NSDLPANStatus === "E") {
                        /*let fullName =
                            obj.response.content[0].Name.toUpperCase();
                        let salutationsList = Salutations_List.split("@;");
                        let salutValue = fullName.substring(
                            0,
                            fullName.indexOf(" ")
                        );
                        const index = salutationsList.findIndex(
                            (salutation) => salutation === salutValue
                        );
                        if (index !== -1) {
                            fullName = fullName.substring(
                                fullName.indexOf(" ") + 1
                            );
                        }
                        let apiResFirstName = "";
                        let apiResLastName = "";
                        if (fullName.split(" ").length > 1) {
                            apiResLastName = fullName.substring(
                                fullName.lastIndexOf(" ") + 1
                            );
                            apiResFirstName = fullName.substring(
                                0,
                                fullName.lastIndexOf(" ")
                            );
                        } else {
                            apiResFirstName = fullName;
                        }
                        let kycName = fullName === "" ? this.kycName : fullName;
                        let panFirstName =
                            apiResFirstName === ""
                                ? this.firstName
                                : apiResFirstName;
                        let panLastName =
                            apiResLastName === ""
                                ? this.lastName
                                : apiResLastName;*/
                        let nsdlPanName = obj.response.content[0].Name;
                        let NSDLPANStatus = obj.response.content[0].NSDLPANStatus;
                        
                        this.showToast(
                            obj.response.content[0].NSDLReturnCdDesc,
                            obj.response.content[0].NSDLPANStatusDesc,
                            "success"
                        );
                        this.panverified = true;
                        this.disablePANField = true;
                        panDoc = this.getPanObject();
                        panDoc.fields.First_Name__c = this.dataWrapper.applicant.Customer_First_Name__c;
                        panDoc.fields.Last_Name__c = this.dataWrapper.applicant.Customer_Last_Name__c;
                        panDoc.fields.KYC_name__c = this.dataWrapper.applicant.Customer_First_Name__c + ' ' + this.dataWrapper.applicant.Customer_Last_Name__c;
                        panDoc.fields.NSDLPANName__c = nsdlPanName;
                        panDoc.fields.NSDLPANStatus__c = NSDLPANStatus;
                        

                    } else if (
                        obj.response.content[0].NSDLPANStatus ===
                        ("F" || "X" || "D" || "N" || "EA" || "EC" || "ED" || "EI" || "EL" || "EM" || "EP" || "ES" || "EU")
                    ) {
                        this.showToast(
                            "Error",
                            obj.response.content[0].NSDLPANStatusDesc,
                            "error"
                        );
                    } else {
                        this.showToast(
                            "Error",
                            "Invalid PAN",
                            "error"
                        );
                    }
                    return panDoc;
                })
                .then((panDoc) => {
                    if (panDoc) {
                        let upsert = this.panDocId
                            ? updateRecord
                            : createRecord;
                        upsert(panDoc)
                            .then((record) => {
                                this.showSpinner = false;
                                this.panDocId = record.id;
                            })
                            .catch((error) => {
                                this.showToast(
                                    "Error",
                                    error.body.message,
                                    "error"
                                );
                                this.showSpinner = false;
                            });
                    } else {
                        this.showSpinner = false;
                    }
                })
                .catch((error) => {
                    this.showSpinner = false;
                    this.showToast(
                        "Error",
                        "Error verifying PAN. Please retry.",
                        "error"
                    );
                });
        }
    }

    handlePANChange(event){
        event.target.value = event.target.value.toUpperCase();
    }

    getPanObject() {
        let panDoc = {
            fields: {
                Name: "PAN",
                RecordTypeId: this.kycDocRecordType,
                Document_Type__c: "PAN",
                PAN_No__c: this.template
                    .querySelector("lightning-input[data-id=panNumber]")
                    .value?.toUpperCase(),
                KYC_DOB__c: this.template.querySelector(
                    "lightning-input[data-id=dob]"
                ).value,
                Gender__c: this.template.querySelector(
                    "lightning-combobox[data-id=gender]"
                ).value,
                Proof_of_Identity_POI__c: true,
                KYC_Address_Line_1__c: this.template.querySelector(
                    "lightning-input[data-id=addressLine1]"
                ).value,
                KYC_Address_Line_2__c: this.template.querySelector(
                    "lightning-input[data-id=addressLine2]"
                ).value,
                KYC_City__c: this.template.querySelector(
                    "lightning-combobox[data-id=city]"
                ).value,
                KYC_State__c: this.template.querySelector(
                    "lightning-combobox[data-id=state]"
                ).value,
                KYC_Pin_Code__c: this.template.querySelector(
                    "lightning-input[data-id=pincode]"
                ).value,
                Salutation__c: this.template.querySelector(
                    "lightning-combobox[data-id=salutation]"
                ).value,
                is_Active__c: true
            }
        };
        if (this.panDocId) {
            panDoc.fields.Id = this.panDocId;
        } else {
            panDoc.apiName = DOC_OBJECT.objectApiName;
            panDoc.fields.Applicant__c = this.applicantId;
            panDoc.fields.Opportunity_Relation__c = this.dataWrapper.opp.Id;
        }
        return panDoc;
    }

    async doDedupe() {
        this.showSpinner = true;
        let externalDedupeStatus;
        let apiInputs = {
            applicantId: this.applicantId,
            leadId: this.leadNumber,
            loanApplicationId: this.dataWrapper.opp.Id
        };
        //Get retried counts before executing API - This will also consider current execution count

        console.log("getting retry count:" + new Date());
        await getRetryCount({
            loanApplicationId: this.dataWrapper.opp.Id,
            applicantType: "Borrower",
            countfieldName: "Customer_Dedupe__c",
            metadataAttemptsField: "Customer_Dedupe_Attempts"
        })
            .then((result) => {
                console.log("retry count received:" + new Date());
                let jsonResult = JSON.parse(result);
                this.externalDedupeAPICurrentAttempts = jsonResult.retryCount;
                this.externalDedupeAPIMaxAttempts =
                    jsonResult.externalDedupeAPIMaxAttempts;
            })
            .catch((error) => {
                console.log(
                    "Error in getting API Count: " + error?.body?.message
                );
            });

        if (
            this.externalDedupeAPICurrentAttempts <=
            this.externalDedupeAPIMaxAttempts
        ) {
            console.log(
                "Executing External Dedupe API:: ",
                JSON.stringify(apiInputs),
                new Date()
            );

            await doExternalDedupeAPICallout({
                externalDedupeRequestString: JSON.stringify(apiInputs)
            })
                .then((result) => {
                    console.log("dedupe response received:" + new Date());
                    this.cicNo = result.cicNo;

                    try {
                        this.customerDedupeResponse = JSON.parse(
                            result.Response
                        );

                        if (this.customerDedupeResponse.response.status) {
                            externalDedupeStatus =
                                this.customerDedupeResponse.response.status;
                        }
                    } catch (error) {
                        console.log("Error in Parsing Dedupe API");
                        if (result.Response) {
                            this.customerDedupeResponse = result.Response;
                        } else {
                            this.customerDedupeResponse = result;
                        }
                        externalDedupeStatus = "FAILED";
                    }

                    console.log("Current CIC NO:: ", result.cicNo);
                    this.processDedupeResponse();
                })
                .catch((error) => {
                    console.log(
                        "Error in Executing External Dedupe API:: ",
                        error
                    );
                    externalDedupeStatus = "FAILED";
                });

            console.log(
                "External Dedupe Parsed Response:: ",
                this.customerDedupeResponse
            );
            console.log("External Dedupe API Status:: ", externalDedupeStatus);

            if (externalDedupeStatus === "FAILED") {
                console.log("dedupe response failed retrying:" + new Date());
                this.spinnerText = DEDUPE_SPINNER_TEXT2;
                await this.doDedupe();
            }
        }
        // else{
        //     this.showToast(
        //         "Error",
        //         "Max dedupe retries done. Please try later.",
        //         "error"
        //     );
        //     this.disableAll();
        //     this[NavigationMixin.Navigate]({
        //         type: "standard__namedPage",
        //         attributes: {
        //             pageName: "home"
        //         }
        //     });
        // }
    }

    // prettier-ignore
    processDedupeResponse() {
        let internalDedupeResponseArray = this.customerDedupeResponse?.response?.content[0]?.Data?.InternalDedupeResponse; //[0]?.CustomerValidate;
        let externalDedupeResponse = this.customerDedupeResponse?.response?.content[0]?.Data?.ExternalDedupeResponse?.CustomerValidate;
        let dedupeConditionMatch = false;
        let ruleId = '';
        let customerType = '';
        let cmArray = [];

        if (internalDedupeResponseArray?.length > 0) {
            for (let idrItem of internalDedupeResponseArray) {
                if(idrItem?.CustomerValidate){
                    for (let cvItem of idrItem.CustomerValidate) {
                            cmArray.push(...cvItem.CustomerMaster)
                    }
                }
                if(idrItem?.CustomerMaster){
                    cmArray.push(...idrItem.CustomerMaster);
                }
            }
            if(cmArray.length !== 0){
                for (let cm of cmArray) {
                    if (Object.prototype.hasOwnProperty.call(cm, "Rule_Id") &&
                        cm.Rule_Id != null && ruleId !== "PAN100") {
                            ruleId = cm.Rule_Id;
                    }
                    if (Object.prototype.hasOwnProperty.call(cm, "Customer_Type") &&
                        cm.Customer_Type != null && customerType !== "10") {
                            customerType = cm.Customer_Type;
                    }
                }
            }
            if(ruleId === "PAN100" && customerType === "10"){
                dedupeConditionMatch = true;
            }
        }

        if (!this.matchingCustomerCode && externalDedupeResponse?.length > 0) {
            for (let cvItem of externalDedupeResponse) {
                let cmArr = cvItem?.CustomerMaster;
                for (let cm of cmArr) {
                    if (Object.prototype.hasOwnProperty.call(cm, "MATCHED_CRITERIA") &&
                        Object.prototype.hasOwnProperty.call(cm, "Customer_Type") &&
                        cm.MATCHED_CRITERIA === "PAN100" &&
                        cm.Customer_Type === "10" &&
                        cm.Matched_Source === "CFD") {
                            dedupeConditionMatch = true;
                    }
                }
            }
        }

        console.log("Matched customer code", this.matchingCustomerCode);
        createRecord({
            apiName: CDR_OBJECT.objectApiName,
            fields: {
                Applicant__c: this.applicantId,
                Response__c: JSON.stringify(this.customerDedupeResponse),
                CIC_No__c: this.cicNo,
                Customer_Code__c: this.matchingCustomerCode,
                Customer_Status_Flag__c: this.custFlag,
                External_Dedupe_Status__c: this.customerDedupeResponse?.response?.content[0]?.Data?.ExternalDedupeResponse?.DEDUPE_STATUS
            }
        }).then(()=>{
            return validateCustomerCode({applicantId: this.applicantId, ruleIdCustomerTypeMatch: dedupeConditionMatch});
        }).then(dedupeValidationResponse =>{
            let dedupeValidationResponseJSON = JSON.parse(dedupeValidationResponse);
            if(dedupeValidationResponseJSON.isValid === false){
                this.journeyStop();
            }else{
                updateRecord({
                    fields: {
                        Id:
                            this.recordId ||
                            this.dataWrapper.opp.Id,
                        DSA_Stage__c: "Income"
                    }
                }).then(() => {
                    this.screenName = this.screens.incomeScreen;
                    this.showSpinner = false;
                    this.spinnerText = null;
                });
            }
        }).catch((error) => {
            this.showToast("Error", error.body.message, "error");
            this.showSpinner = false;
        });
    }

    journeyStop() {
        this.showToast(
            "Error",
            "Cannot proceed with the Application... Redirecting to home.",
            "error"
        );
        this.disableAll();
        this[NavigationMixin.Navigate]({
            type: "standard__namedPage",
            attributes: {
                pageName: "home"
            }
        });
    }

    // prettier-ignore
    processFormFields(){
        if(this.screenName === this.screens.initialScreen){
            let dw = JSON.parse(JSON.stringify(this.dataWrapper));
            dw.updateOpportunity = false;//Set to true if update opportunity required;

            dw.applicant.Opportunity__c = dw.opp.Id;

            dw.applicant.Id = this.applicantId;
            dw.applicant.Applicant_Type__c = 'Borrower';

            dw.applicant.Contact_number__c = this.template.querySelector("lightning-input[data-id=customerMobile]").value;

            dw.applicant.Whatsapp_number__c = this.template.querySelector("lightning-input[data-id=whatsAppNumber]").value;

            dw.applicant.Register_for_WhatsApp_Banking__c = this.template.querySelector("lightning-input[data-id=registerForWhatsAppBanking]").checked;

            dw.applicant.Customer_First_Name__c = this.template.querySelector("lightning-input[data-id=firstName]").value?.trim();

            dw.applicant.Customer_Last_Name__c = this.template.querySelector("lightning-input[data-id=lastName]").value?.trim();

            dw.applicant.Gender__c = this.template.querySelector("lightning-combobox[data-id=gender]").value;

            dw.applicant.Name = dw.applicant.Customer_First_Name__c + ' ' + dw.applicant.Customer_Last_Name__c;

            dw.applicant.Office_Address_Line_1__c = this.template.querySelector("lightning-input[data-id=addressLine1]").value;

            dw.applicant.Office_Address_Line_2__c = this.template.querySelector("lightning-input[data-id=addressLine2]").value;

            dw.applicant.Office_City__c = this.template.querySelector("lightning-combobox[data-id=city]").value;

            dw.applicant.Office_State__c = this.template.querySelector("lightning-combobox[data-id=state]").value;

            dw.applicant.Office_PinCode__c = this.template.querySelector("lightning-input[data-id=pincode]").value;

            dw.applicant.Residence_country__c = 'India';
            
            dw.applicant.PAN_No__c = this.template.querySelector("lightning-input[data-id=panNumber]").value?.toUpperCase();

            dw.applicant.Journey_Stage__c = this.label.userDetails;

            dw.applicant.Consent_Received__c = this.consentReceived;

            if(this.template.querySelector("lightning-input[data-id=dob]").value !== null && this.template.querySelector("lightning-input[data-id=dob]").value !==''){
                dw.applicant.DSA_DOB__c = this.template.querySelector("lightning-input[data-id=dob]").value;
            }

            this.dataWrapper = JSON.parse(JSON.stringify(dw));
        }
    }

    async saveLead() {
        console.log("Reached SaveLead");
        let dw = JSON.parse(JSON.stringify(this.dataWrapper));
        delete dw.opp.Integration_Log__r;
        delete dw.applicant.Documents__r;
        delete dw.applicant.Customer_Dedupe_Response__r;
        this.applicantId = await saveLead({
            dataWrapperJSON: JSON.stringify(dw)
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