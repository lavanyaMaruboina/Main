import { LightningElement, api, track, wire } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { CurrentPageReference, NavigationMixin } from "lightning/navigation";
import getProducts from "@salesforce/apex/IND_DSAController.getProducts";
import saveAssetDetails from "@salesforce/apex/IND_DSAController.saveAssetDetails";
import createCoBorrower from "@salesforce/apex/IND_DSAController.createCoborrowerScreening";
import getAssetDetailsByRecordId from "@salesforce/apex/IND_DSAController.getAssetDetailsByRecordId"; 
import getLoanApplicationStageName from '@salesforce/apex/LwcLOSLoanApplicationCntrl.getLoanApplicationStageName'; // CISP:13870

export default class Dsa_assetScreen extends NavigationMixin(LightningElement) {
    @track disableCheckEligibilityButton = false;
    @track checkEligbilutyClass = "ibl-btn-red";
    @track journeyStopPopUp = false;
    @track coborrowerPopup = false;
    @track CoborrowerIncome;
    @track modalHeader='Add Co-Borrower';
    @track journeyStopMessage='Sorry we are not able to serve you.'
    @track withdrawn = false; //CISP-13870
    make;
    model;
    variant;
    modelcode; //SFD2C-161
    makecode;//SFD2C-161
    variantcode;//SFD2C-161
    estimatedAssetValue;
    requiredLoanAmount;
    makeOptions = [];
    modelOptions = [];
    variantOptions = [];
    fields = [];
    isShowModal = false;
    showSpinner = false;
    recordId;
    btnName;
    @api dsarecordId; // added for CISP-13870
    assetDetailId;
    modalMessage =
        "Are you sure you want to submit the details? \n All information entered, once submitted cannot be edited.";
    @api applicant;
    @api appWrapper;

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

    get getDisableMake() {
        return this.makeOptions.length === 0;
    }

    get getDisableModel() {
        return this.modelOptions.length === 0;
    }

    get getDisableVariant() {
        return this.variantOptions.length === 0;
    }

    async connectedCallback() {
        this.makeOptions = await this.getProductValues("Make", "");
        if (this.recordId) {
            await getAssetDetailsByRecordId({ recordId: this.recordId })
                .then((data) => {
                    this.makecode = data.Vehicle_Details__r?.[0].Make_Code__c; //SFD2C-161
                    this.modelcode = data.Vehicle_Details__r?.[0].Model_Code__c; //SFD2C-161
                    this.variantcode = data.Vehicle_Details__r?.[0].Variant_Code__c; //SFD2C-161
                    this.make=data.Vehicle_Details__r?.[0].Make__c //SFD2C-201
                    this.model=data.Vehicle_Details__r?.[0].Model__c //SFD2C-201
                    this.variant=data.Vehicle_Details__r?.[0].Variant__c //SFD2C-201
                    this.estimatedAssetValue =
                        data.Vehicle_Details__r?.[0].Base_Price__c;
                    this.requiredLoanAmount = data.Required_Loan_amount__c;
                    this.assetDetailId = data.Vehicle_Details__r?.[0].Id;
                })
                .then(() => { //SFD2C-161
                    if (this.makecode) { 
                        let option = this.makeOptions.find(
                            (e) => e.value === this.makecode
                        );
                        return this.getProductValues("Model", option.id).then(
                            (data) => {
                                this.modelOptions = data;
                            }
                        );
                    }
                })
                .then(() => { //SFD2C-161
                    if (this.modelcode) {
                        let option = this.modelOptions.find(
                            (e) => e.value === this.modelcode
                        );
                        return this.getProductValues("Variant", option.id).then(
                            (data) => {
                                this.variantOptions = data;
                            }
                        );
                    }
                })
                .catch(() => {
                    this.showToast(
                        "Error",
                        "Error retrieving loan details. Please try again or start a new application.",
                        "error"
                    );
                });
        }
    }

    showModalBox() {
        this.btnName = "Confirm Details";
        let errors = this.validateFields();
        if (errors.length > 0) {
            this.showToast("Error", "Invalid " + errors.join(", "), "error");
        } else {
            this.isShowModal = true;
        }
    }

    handleModalCancel() {
        this.isShowModal = false;
    }

    handleModalConfirm() {
        // this.disableCheckEligibilityButton=true;
        //this.checkEligbilutyClass='ibl-btn-disabled';
        this.isShowModal = false;
        this.saveAssetRecord().then(() => {
            if (this.btnName === "Confirm Details") {
                //RUN BRE
                this.template
                    .querySelector("c-dsa_-b-r-e_engines")
                    .handleCheckEligibility(
                        this.applicant,
                        this.appWrapper.opp.Id,
                        true
                    );
            }
        });
    }

    async saveAssetRecord() {
        this.fields = [];
        this.fields.push(
            this.make,
            this.model,
            this.variant,
            this.estimatedAssetValue,
            this.requiredLoanAmount,
            this.makecode, //SFD2C-161
            this.modelcode, //SFD2C-161
            this.variantcode //SFD2C-161
        );
        await saveAssetDetails({
            applicantId: this.applicant,
            assetDetailId: this.assetDetailId,
            fields: this.fields
        });
    }

    handleSaveExitClick() {
        this.btnName = "saveandexitbtn";
        this.showSpinner = true;
        this.saveAssetRecord()
            .then(() => {
                this.showToast("Success", "Lead saved successfully", "success");
                this[NavigationMixin.Navigate]({
                    type: "standard__namedPage",
                    attributes: {
                        pageName: "home"
                    }
                });
            })
            .catch((error) => {
                console.log('error-->'+error);
                this.showToast(
                    "Error",
                    "Error saving lead. Please try again.",
                    "error"
                );
                this.showSpinner = false;
            });
    }

    async getProductValues(type, parentId) {
        this.showSpinner = true;
        let options = [];
        await getProducts({ type, parentId })
            .then((data) => {
                if (data) {
                    data.forEach((prod) => {
                        //SFD2C-161
                       if(prod.Type__c==='Make'){
                        options.push({
                            label: prod.Name,
                            value: prod.Make_Code__c,
                            id: prod.Id
                        });
                    }
                    else if(prod.Type__c==='Model'){
                        options.push({
                            label: prod.Name,
                            value: prod.Model_Code__c,
                            id: prod.Id
                        });
                    }
                    else if(prod.Type__c==='Variant'){
                        options.push({
                            label: prod.Name,
                            value: prod.Variant_Code__c,
                            id: prod.Id
                        });
                    }
                    });
                }
                this.showSpinner = false;
            })
            .catch((error) => {
                this.showToast(
                    "Error",
                    "Error retrieving data. Please try again.",
                    "error"
                );
                this.error = error;
                this.showSpinner = false;
            });
        return options;
    }

    handleChange(event) {
        //SFD2C-161 start
        this.make =event.target.dataset.id =='make' ?  event.target.options.find(opt => opt.value === event.detail.value).label : this.make;
        this.model =event.target.dataset.id =='model' ?  event.target.options.find(opt => opt.value === event.detail.value).label : this.model;
        this.variant =event.target.dataset.id =='variant' ?  event.target.options.find(opt => opt.value === event.detail.value).label : this.variant;
        this.makecode = this.template.querySelector(
            "lightning-combobox[data-id=make]"
        ).value;
        this.modelcode = this.template.querySelector(
            "lightning-combobox[data-id=model]"
        ).value;
        this.variantcode = this.template.querySelector(
            "lightning-combobox[data-id=variant]"
        ).value;
            //SFD2C-161 end
        this.estimatedAssetValue = this.template.querySelector(
            "lightning-input[data-id=estimatedAssetValue]"
        ).value;
        this.requiredLoanAmount = this.template.querySelector(
            "lightning-input[data-id=requiredLoanAmount]"
        ).value;
        let field = event.target.dataset.id;
        let value = event.target.value;
        if (field === "make") {
            let option = this.makeOptions.find((e) => e.value === value);
            this.getProductValues("Model", option.id).then((data) => {
                this.modelOptions = data;
            });
            this.model = "";
            this.variant = "";
            this.modelcode=""; //SFD2C-161
            this.variantcode=""; //SFD2C-161
        }
        if (field === "model") {
            let option = this.modelOptions.find((e) => e.value === value);
            this.getProductValues("Variant", option.id).then((data) => {
                this.variantOptions = data;
            });
            this.variant = "";
            this.variantcode=""; //SFD2C-161
        }
    }

    validateAmountChange(event) {
        let fieldName = event.target.dataset.id;
        let estimatedAssetValue = this.template.querySelector(
            "lightning-input[data-id=estimatedAssetValue]"
        );
        let requiredLoanAmount = this.template.querySelector(
            "lightning-input[data-id=requiredLoanAmount]"
        );
        if (this.estimatedAssetValue && this.requiredLoanAmount) {
            let isValid =
                parseFloat(this.estimatedAssetValue) >=
                parseFloat(this.requiredLoanAmount);
            if (isValid) {
                estimatedAssetValue.setCustomValidity("");
                requiredLoanAmount.setCustomValidity("");
            } else {
                estimatedAssetValue.setCustomValidity(
                    "Estimated asset value should be greater than Required loan amount"
                );
                requiredLoanAmount.setCustomValidity(
                    "Required loan amount should be less than Estimated asset value"
                );
            }
            estimatedAssetValue.reportValidity();
            requiredLoanAmount.reportValidity();
        } else {
            estimatedAssetValue.setCustomValidity("");
            requiredLoanAmount.setCustomValidity("");
            if (fieldName === "estimatedAssetValue") {
                requiredLoanAmount.reportValidity();
            } else {
                estimatedAssetValue.reportValidity();
            }
        }
    }

    @api
    validateFields() {
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
        console.log(errors);
        return errors;
    }

    handleScreening(event) {
        if (event.detail.journeyStopPopUp === true) {
            this.disableCheckEligibilityButton =
                event.detail.disableCheckEligibilityButton;
                if(event.detail.api=='offer'){
                    this.journeyStopMessage='Dear Customer, your income is insufficient to generate the offer. Please get in touch with IndusInd Bank representative'
                }
            // this.checkEligbilutyClass='ibl-btn-disabled';
            this.journeyStopPopUp = event.detail.journeyStopPopUp;
        }
        if (event.detail.coborrowerPopup === true) {
            if(event.detail.count>=2){
                this.modalHeader='Change Co-Borrower';
            }
            this.coborrowerPopup = event.detail.coborrowerPopup;
        }
    }

    handleChangeCoborrower(event) {
        this.CoborrowerIncome = event.target.value;
    }

    handleCancel() {
        this.coborrowerPopup = false;
        this.journeyStopPopUp = false;
        this[NavigationMixin.Navigate]({
            type: "standard__namedPage",
            attributes: {
                pageName: "home"
            }
        });
    }

    saveCoborrower() {
        this.coborrowerPopup = false;
        createCoBorrower({
            loanApplication: this.appWrapper.opp.Id,
            applicant: this.applicant,
            income: this.CoborrowerIncome
        })
            .then(() => {
                this.template
                    .querySelector("c-dsa_-b-r-e_engines")
                    .handleCheckEligibility(
                        this.applicant,
                        this.appWrapper.opp.Id,
                        false
                    );
            })
            .catch((error) => {
                this.showToast("Error", error.body.message, "Error");
            });
    }

    handleBREComplete(event) {
        this.dispatchEvent(
            new CustomEvent("brecomplete", {
                detail: event.detail
            })
        );
    }

    showToast(toastTitle, message, variant) {
        const evt = new ShowToastEvent({
            title: toastTitle,
            message: message,
            variant: variant
        });
        this.dispatchEvent(evt);
    }
    async renderedCallback() {
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