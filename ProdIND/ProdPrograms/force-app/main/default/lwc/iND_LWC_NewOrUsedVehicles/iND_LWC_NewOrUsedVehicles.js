import { LightningElement, track, wire, api } from "lwc";
import { loadStyle } from "lightning/platformResourceLoader";
import LightningCardApplyCSS from "@salesforce/resourceUrl/loanApplication";
import { getPicklistValues } from "lightning/uiObjectInfoApi";
import { getObjectInfo } from "lightning/uiObjectInfoApi";
import {
    // createRecord,
    getRecord,
    updateRecord,
    getFieldValue,
} from "lightning/uiRecordApi";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { NavigationMixin } from "lightning/navigation";
import NewUsed_Vehicles from "@salesforce/label/c.New_Used_Vehicles";
import Vehicle_New from "@salesforce/label/c.Vehicle_New";
import Vehicle_Old from "@salesforce/label/c.Vehicle_Old";
import Regex_NumberOnly from "@salesforce/label/c.Regex_NumberOnly";
import Vehicle_Old_PlaceHolder from "@salesforce/label/c.Vehicle_Old_Pattern_PlaceHolder";
import Vehicle_New_PlaceHolder from "@salesforce/label/c.Vehicle_New_Pattern_PlaceHolder";
import VehicleType from "@salesforce/label/c.VehicleType";
import getUsedRegAndVehilceDetails from "@salesforce/apex/LoanDisbursementController.getUsedRegAndVehilceDetails";
import GetLoanDisbursementDetails from "@salesforce/apex/LoanDisbursementController.getLoanDisbursementDetails";
import loadInsuranceDetails from "@salesforce/apex/LoanDisbursementController.loadInsuranceDetails";
import LoanDisbursement_OBJECT from "@salesforce/schema/LoanDisbursementDetails__c";
import LoanDisbursement_ID_FIELD from "@salesforce/schema/LoanDisbursementDetails__c.Id";
import DeliveryOption_FIELD from "@salesforce/schema/LoanDisbursementDetails__c.Vehicle_Delivered__c";
import RegTypeOption_FIELD from "@salesforce/schema/LoanDisbursementDetails__c.Reg_type__c";
import RegistrationNo_FIELD from "@salesforce/schema/LoanDisbursementDetails__c.Registration_Number__c";
import NameTransfered_FIELD from "@salesforce/schema/LoanDisbursementDetails__c.Name_transferred__c";
import CurrentVehicleOwner_FIELD from "@salesforce/schema/LoanDisbursementDetails__c.Current_vehicle_owner__c";
import LienMarked_FIELD from "@salesforce/schema/LoanDisbursementDetails__c.Lien_marked_IBL__c";
import MarkedOn_FIELD from "@salesforce/schema/LoanDisbursementDetails__c.Marked_on__c";
import NowLienInNameOf_FIELD from "@salesforce/schema/LoanDisbursementDetails__c.Now_lien_in_the_name_of__c";
import EngineNo_FIELD from "@salesforce/schema/LoanDisbursementDetails__c.Engine_no__c";
import ChassisNo_FIELD from "@salesforce/schema/LoanDisbursementDetails__c.Chassis_no__c";
import RTATaxes_Remitted_Upto_FIELD from "@salesforce/schema/LoanDisbursementDetails__c.RTA_taxes_remitted_upto__c";
import Parent_Loan_Application_FIELD from "@salesforce/schema/LoanDisbursementDetails__c.Parent_Loan_Application__c";

import VehicleDetails_OBJECT from "@salesforce/schema/Vehicle_Detail__c";
import VehRegType_FIELD from "@salesforce/schema/Vehicle_Detail__c.Vehicle_type__c";
import VehRegistrationNo_FIELD from "@salesforce/schema/Vehicle_Detail__c.Vehicle_Registration_number__c";
import VehEngineNo_FIELD from "@salesforce/schema/Vehicle_Detail__c.Engine_number__c";
import VehChassisNo_FIELD from "@salesforce/schema/Vehicle_Detail__c.Chassis_number__c";
import mandotoryDetailsNotProvide from "@salesforce/label/c.Mandotory_details_are_not_given_Please_provide";
import LoanApplicationId_Field from "@salesforce/schema/Opportunity.Id";
import LoanApplicationSubStage_Field from "@salesforce/schema/Opportunity.Sub_Stage__c";
import DealNumberId from '@salesforce/schema/Deal_Number__c.Id';
import fetchLoanDetails from '@salesforce/apex/IND_LWC_LoanDetailsCntrl.fetchLoanDetails';//Ola integration changes
import isRevokedLead from '@salesforce/apex/LoanDisbursementController.isRevokedLead';

const NewUsedVehicleFields = [
    DeliveryOption_FIELD,
    RegTypeOption_FIELD,
    RegistrationNo_FIELD,
    NameTransfered_FIELD,
    CurrentVehicleOwner_FIELD,
    LienMarked_FIELD,
    MarkedOn_FIELD,
    NowLienInNameOf_FIELD,
    EngineNo_FIELD,
    ChassisNo_FIELD,
    RTATaxes_Remitted_Upto_FIELD,
    Parent_Loan_Application_FIELD,
];

const VehicleDetailFields = [
    VehRegType_FIELD,
    VehRegistrationNo_FIELD,
    VehEngineNo_FIELD,
    VehChassisNo_FIELD,
];

export default class IND_LWC_NewOrUsedVehicles extends NavigationMixin(
    LightningElement
) {
    @api dealId = '';
    @track isSpinnerMoving = true;

    @api uploadViewDocFlag;
    @api recordid;
    @api disbursementrecordid;
    @api applicantId;
    @api testParentLoanIdForVehicleDetail;
    @api disablefields;

    label = {
        NewUsed_Vehicles,
        mandotoryDetailsNotProvide,
        Regex_NumberOnly,
    };
    @track todayDate;
    @track isEnableUploadViewDoc = true;
    @track deliveryOptions;
    @track deliveryOptionsTemp;
    @track regTypeOptions;
    @track regNumber;
    @track nameTransferred;
    @track currentVehicleOwner;
    @track lienMarked;
    @track markedOnDate;
    @track nowLienInTheNameOf;
    @track engineNumber;
    @track chassisNumber;
    @track vehicleType;
    @track rtaTaxRemittedUpto;
    @track details;
    @track vehicleRegistrationPattern = Vehicle_New;
    @track vehicleRegistrationPatternPlaceholder = Vehicle_New_PlaceHolder;
    @track isNewUsedVehicleInfoUpdated = false;
    @track isVehRegNoTypeDisable = false;
    @track isVehEngineNoDisable = false;
    @track isVehChassisNoDisable = false;
    @track isLienInTheNameOfDisable = false;
    @track IsMarkedOnDisable = false;
    @track leadSource;//Ola integration changes
    @track vehicletype;//CISP-5752

    @track deliveryRadioOptions = [
        { label: "Yes", value: "Yes" },
        { label: "No", value: "No" },
    ];
    @track regTypeRadioOptions = [
        { label: "New", value: "New" },
        { label: "Old", value: "Old" },
    ];
    @track nameTransferredOptions = [
        { label: "Yes", value: "Yes" },
        { label: "No", value: "No" },
    ];
    @track lienMarkedOptions = [
        { label: "Yes", value: "yes" },
        { label: "No", value: "no" },
    ];
    @track isNewVehicle;
    @api currentloanappstage;
    @api currentloanappsubstage;
    @track requiredRegNo = false;
    @track requiredFields = true;
    @track requiredDeliveryDetails = true;
    @track requiredLienInTheName = true;//CISP-5752
    @track requiredMarkedOn = true;//CISP-5752
    @track isTractor = false;//SFTRAC-144
    @track serailNumber;//SFTRAC-144
    @track vehicleSubType;//SFTRAC-144
    @track requiredSerailNumber = false;//SFTRAC-144
    @track isNotImplementVehicleType = true;
    // CISP-4770 - SRTART
    @api frompostsanction = false;
    //CISP-4770 - END
    handleUploadViewDoc() {
            this.showUpload = true;
            this.showPhotoCopy = false;
            this.showDocView = true;
            this.isVehicleDoc = false;
            this.isAllDocType = true;
            this.uploadViewDocFlag = true;
        }
        // @wire(GetLoanDisbursementDetails,{loanApplicationId: '$recordid'})
        // disbursementDetailInfo({ error, data }) {
        //     if (error) {
        //         console.debug(error);
        //         //Hide spinner
        //         this.isSpinnerMoving=false;

    //         let message = 'Unknown error';
    //         if (Array.isArray(error.body)) {
    //             message = error.body.map(e => e.message).join(', ');
    //         } else if (typeof error.body.message === 'string') {
    //             message = error.body.message;
    //         }
    //         /*this.dispatchEvent(
    //             new ShowToastEvent({
    //                 title: 'Error while accessing Vehicle Details',
    //                 message : this.message,
    //                 variant: 'error',
    //             }),
    //         );*/
    //     } else if (data) {
    //         console.debug(data);
    //         //Hide spinner
    //         this.isSpinnerMoving=false;
    //         let response = data;
    //         if(response){
    //             this.disbursementrecordid = response.id;
    //             if(response.Parent_Loan_Application__c){
    //                 if(response.Parent_Loan_Application__r.Vehicle_Type__c.includes('Used')){
    //                     this.regTypeOptions = response.Parent_Loan_Application__r.Registration_Number_Format__c;
    //                     this.regNumber = response.Parent_Loan_Application__r.Vehicle_Registration_Number__c;
    //                     this.isVehRegNoTypeDisable = true;
    //                     this.isLienInTheNameOfDisable = false;
    //                     this.IsMarkedOnDisable = false;
    //                     this.isNewVehicle = false;
    //                     this.rtaTaxRemittedUpto = response.RTA_taxes_remitted_upto__c;
    //                     this.requiredRegNo = false;
    //                     this.requiredFields = true;
    //                 }else{
    //                     this.isNewVehicle = true;
    //                     this.isLienInTheNameOfDisable = true;
    //                     this.IsMarkedOnDisable = true;
    //                     this.isVehRegNoTypeDisable = false;
    //                     this.requiredRegNo = true;
    //                     this.requiredFields = false;
    //                 }
    //             }
    //         }
    //     }
    // }
    //Get Vehicle Information
    @wire(getUsedRegAndVehilceDetails, { loanApplicationId: "$recordid", dealId: '$dealId' })
    vehicleDetailInfo({ error, data }) {
        if (error) {
            //Hide spinner
            this.isSpinnerMoving = false;

            let message = "Unknown error";
            if (Array.isArray(error.body)) {
                message = error.body.map((e) => e.message).join(", ");
            } else if (typeof error.body.message === "string") {
                message = error.body.message;
            }
            this.dispatchEvent(
                new ShowToastEvent({
                    title: "Error while accessing Vehicle Details",
                    message: this.message,
                    variant: "error",
                })
            );
        } else if (data) {
            //Hide spinner
            this.isSpinnerMoving = false;
            console.debug(data);

            if (data) {
                this.regNumber = data.Vehicle_Registration_number__c;
                this.chassisNumber = data.Chassis_number__c;
                this.engineNumber = data.Engine_number__c;
                if ((data.Vehicle_type__c.includes("Used") || data.Vehicle_type__c.includes("Refinance")) && data.Product_Type__c!='Tractor') {//CISP-5752
                    this.isVehRegNoTypeDisable = true;
                    this.isLienInTheNameOfDisable = false;
                    this.IsMarkedOnDisable = false;
                    this.isNewVehicle = false;
                    //this.requiredRegNo = false;
                    this.requiredFields = false;
                    this.requiredLienInTheName = false;//CISP-5752
                    this.requiredMarkedOn = false;//CISP-5752
                } else {
                    if(data.Product_Type__c!='Tractor'){
                        this.isNewVehicle = true;
                        this.isLienInTheNameOfDisable = true;
                        this.IsMarkedOnDisable = true;
                        this.isVehRegNoTypeDisable = false;
                        //this.requiredRegNo = true;
                        this.requiredFields = false;
                        this.requiredLienInTheName = false;//CISP-5752
                        this.requiredMarkedOn = false;//CISP-5752
                    }
                    else{
                        this.isVehRegNoTypeDisable = true;
                        this.requiredRegNo = false;
                        this.requiredSerailNumber = false;
                    }
                }
            } else {
                this.isVehRegNoTypeDisable = false;
                this.isVehEngineNoDisable = false;
                this.isVehChassisNoDisable = false;
                this.requiredDeliveryDetails = true;
            }
        }
    }

    //Wire the output of the out of the box method getRecord to the property newUsedVehicleInfo;
    @wire(getRecord, {
        recordId: "$disbursementrecordid",
        fields: NewUsedVehicleFields,
    })
    newUsedVehicleInfo({ error, data }) {
        if (error) {
            //Hide spinner
            this.isSpinnerMoving = false;

            let message = "Unknown error";
            if (Array.isArray(error.body)) {
                message = error.body.map((e) => e.message).join(", ");
            } else if (typeof error.body.message === "string") {
                message = error.body.message;
            }
            /*this.dispatchEvent(
                      new ShowToastEvent({
                          title: 'Error while accessing New/Used Vehicle Details',
                          message : this.message,
                          variant: 'error',
                      }),
                  );*/
        } else if (data) {
            console.debug(data);
            //Hide spinner
            this.isSpinnerMoving = false;
            //alert(JSON.stringify(data));
            this.connectedCallback();
            this.deliveryOptions = data.fields.Vehicle_Delivered__c.value;

            if (data.fields.Vehicle_Delivered__c.value) {
                if (data.fields.Vehicle_Delivered__c.value.includes("No")) {
                    this.isVehEngineNoDisable = true;
                    this.isVehChassisNoDisable = true;
                    this.requiredDeliveryDetails = false;
                } else {
                    this.isVehEngineNoDisable = false;
                    this.isVehChassisNoDisable = false;
                    this.requiredDeliveryDetails = true;
                }
            }
            this.regTypeOptions = data.fields.Reg_type__c.value;
            if (this.regTypeOptions) {
                if (this.regTypeOptions.includes("Old")) {
                    this.vehicleRegistrationPattern = Vehicle_Old;
                    this.vehicleRegistrationPatternPlaceholder = Vehicle_Old_PlaceHolder;
                    console.debug(
                        "vehicle Registratin paterrn ",
                        Vehicle_Old_PlaceHolder
                    );
                } else if (this.regTypeOptions.includes("New")) {
                    this.vehicleRegistrationPattern = Vehicle_New;
                    this.vehicleRegistrationPatternPlaceholder = Vehicle_New_PlaceHolder;
                    console.debug(
                        "vehicle new Registratin paterrn ",
                        Vehicle_New_PlaceHolder
                    );
                }
            }
            this.regNumber = data.fields.Registration_Number__c.value;
            this.nameTransferred = data.fields.Name_transferred__c.value;
            this.currentVehicleOwner = data.fields.Current_vehicle_owner__c.value;
            this.lienMarked = data.fields.Lien_marked_IBL__c.value ? "yes" : "no";
            this.markedOnDate = data.fields.Marked_on__c.value;
            this.nowLienInTheNameOf = data.fields.Now_lien_in_the_name_of__c.value;
           this.engineNumber = data.fields.Engine_no__c.value;
           this.chassisNumber = data.fields.Chassis_no__c.value;
            this.rtaTaxRemittedUpto = data.fields.RTA_taxes_remitted_upto__c.value;
        }
    }
    isRevokedLead;
    async connectedCallback() {
        await isRevokedLead({'loanApplicationId':this.recordid}).then(result=>{
            if(result){ this.isRevokedLead = true; }
        });
        console.log("this.disbursementrecordid:", this.disbursementrecordid);
        this.todayDate = new Date().toDateString();
        await fetchLoanDetails({ opportunityId: this.recordid, dealId: this.dealId }).then(result => {
            this.leadSource = result?.loanApplicationDetails[0]?.LeadSource;
            this.vehicletype = result?.loanApplicationDetails[0].Vehicle_Details__r[0]?.Vehicle_type__c;//CISP-5752
            if(result?.loanApplicationDetails[0]?.Product_Type__c != 'Tractor'){
                this.regTypeOptions = result?.loanApplicationDetails[0]?.Registration_Number_Format__c;//CISP-5752
                this.regNumber = result?.loanApplicationDetails[0]?.Vehicle_Registration_Number__c;//CISP-5752
            }
            if(this.leadSource=='OLA'){
                this.deliveryOptions = "No";
            }

            if(result?.loanApplicationDetails[0]?.Product_Type__c == 'Tractor') {//SFTRAC-144
                this.isTractor = true;
                this.serailNumber = this.serailNumber ? this.serailNumber : result?.loanApplicationDetails[0].Vehicle_Details__r[0]?.Serial_number__c;
                this.vehicleSubType = result?.loanApplicationDetails[0].Vehicle_Details__r[0]?.Vehicle_SubType__c;
                this.deliveryOptions = this.deliveryOptions ? this.deliveryOptions : result?.loanApplicationDetails[0].Vehicle_Details__r[0]?.Vehicle_Delivered__c;
                this.deliveryOptionsTemp = this.deliveryOptions;
                this.regNumber = this.regNumber ? this.regNumber : result?.loanApplicationDetails[0].Vehicle_Details__r[0]?.Vehicle_Registration_number__c;
                this.regTypeOptions = this.regTypeOptions ? this.regTypeOptions : result?.loanApplicationDetails[0].Vehicle_Details__r[0]?.Registration_Number_Format__c;
                
                this.chassisNumber = this.chassisNumber ? this.chassisNumber : result?.loanApplicationDetails[0].Vehicle_Details__r[0]?.Chassis_number__c;
                this.engineNumber = this.engineNumber ? this.engineNumber : result?.loanApplicationDetails[0].Vehicle_Details__r[0]?.Engine_number__c;
            }
        });//Ola Integration changes
        // GetLoanDisbursementDetails({ loanApplicationId: this.recordid })
        // .then(response => {
        //     console.debug(response);
        //     if(response){
        //         if(response.Parent_Loan_Application__c){
        //             if(response.Parent_Loan_Application__r.Vehicle_Type__c.includes('Used')){
        //                 this.regTypeOptions = response.Parent_Loan_Application__r.Registration_Number_Format__c;
        //                 this.regNumber = response.Parent_Loan_Application__r.Vehicle_Registration_Number__c;
        //                 this.isVehRegNoTypeDisable = true;
        //                 this.isLienInTheNameOfDisable = false;
        //                 this.IsMarkedOnDisable = false;
        //                 this.isNewVehicle = false;
        //                 this.rtaTaxRemittedUpto = response.RTA_taxes_remitted_upto__c;
        //                 this.requiredRegNo = false;
        //                 this.requiredFields = true;
        //             }else{
        //                 this.isNewVehicle = true;
        //                 this.isLienInTheNameOfDisable = true;
        //                 this.IsMarkedOnDisable = true;
        //                 this.isVehRegNoTypeDisable = false;
        //                 this.requiredRegNo = true;
        //                 this.requiredFields = false;
        //             }
        //         }
        //         this.disbursementrecordid = response.Id;
        //     }
        // })
        // .catch(error => {
        //     this.tryCatchError = error;
        //     console.debug(this.tryCatchError);
        //     this.errorInCatch();
        // });

        if(this.isTractor) {//SFTRAC-144
            if (this.vehicletype == "Used" || this.vehicletype == "Refinance") {
                this.isVehRegNoTypeDisable = false;//SFTRAC-1827
                this.requiredRegNo = true;
            } else {
                this.isVehRegNoTypeDisable = false;
            }

            if(this.vehicleSubType == 'Implement') {
                this.requiredSerailNumber = true;
                this.isNotImplementVehicleType = false;
            }
            if(this.deliveryOptionsTemp == 'No'){
                this.isVehChassisNoDisable = true;
                this.isVehEngineNoDisable = true;
            }
            if(this.deliveryOptionsTemp == 'Yes'){
                this.isVehChassisNoDisable = true;
                this.isVehEngineNoDisable = true;
                //this.isVehRegNoTypeDisable = true; SFTRAC-1827
                if(this.template.querySelector('[data-id="deliveryRadioGroupField"]')){
                    this.template.querySelector('[data-id="deliveryRadioGroupField"]').disabled = true;
                }
            }
        } else{
            if(this.vehicletype == 'Used' || this.vehicletype == 'Refinance'){//CISP-5752
                this.isNewVehicle = false;
                this.requiredDeliveryDetails = true;
            }//CISP-5752
        }
}

    renderedCallback() {
        loadStyle(this, LightningCardApplyCSS);
        if (this.disablefields) {
            let inputFields = this.template.querySelectorAll('.slds-form-element__control');
            if (this.disablefields) {
                for (let input of inputFields) {
                    input.disabled = true;
                }
            }
        }
        if(this.leadSource=='OLA'){
            this.template.querySelector('[data-id="deliveryRadioGroupField"]').disabled = true;
            this.isVehEngineNoDisable=true;
            this.isVehChassisNoDisable=true;
            this.connectedCallback();
        }
        if(this.deliveryOptionsTemp == 'Yes'){
            this.isVehChassisNoDisable = true;
            this.isVehEngineNoDisable = true;
            //this.isVehRegNoTypeDisable = true; SFTRAC-1827
            if(this.template.querySelector('[data-id="deliveryRadioGroupField"]')){
                this.template.querySelector('[data-id="deliveryRadioGroupField"]').disabled = true;
            }
        }
        if(this.isRevokedLead){
            this.template.querySelectorAll('*').forEach(element=>{
                element.disabled = true;
            });
        }
    }

    handleInputFieldChange(event) {
        const field = event.target.name;
        this.isNewUsedVehicleInfoUpdated = true;
        if (field === "deliveryRadioGroupField") {
            this.deliveryOptions = event.target.value;
            if(this.vehicletype == 'Used' || this.vehicletype == 'Refinance'){//CISP-5752
                this.isVehEngineNoDisable = true;
                this.isVehChassisNoDisable = true;
            }else{//CISP-5752
            if (this.deliveryOptions.includes("No")) {
                this.isVehEngineNoDisable = true;
                this.isVehChassisNoDisable = true;
                this.requiredDeliveryDetails = false;
            } else {
                this.isVehEngineNoDisable = false;
                this.isVehChassisNoDisable = false;
                this.requiredDeliveryDetails = true;
            }
        }//CISP-5752
        } else if (field === "regTypeRadioGroupField") {
            this.regTypeOptions = event.target.value;

            if (this.regTypeOptions.includes("Old")) {
                this.vehicleRegistrationPattern = Vehicle_Old;
                this.vehicleRegistrationPatternPlaceholder = Vehicle_Old_PlaceHolder;
                console.debug("vehicle Registratin paterrn ", Vehicle_Old_PlaceHolder);
            } else if (this.regTypeOptions.includes("New")) {
                this.vehicleRegistrationPattern = Vehicle_New;
                this.vehicleRegistrationPatternPlaceholder = Vehicle_New_PlaceHolder;
                console.debug(
                    "vehicle new Registratin paterrn ",
                    Vehicle_New_PlaceHolder
                );
            }
        } else if (field === "nameTransferedField") {
            this.nameTransferred = event.target.value;
        } else if (field === "lienMarkedField") {
            this.lienMarked = event.target.value;
            console.debug(this.lienMarked);
            if (this.lienMarked) {
                if (this.lienMarked.includes("yes")) {
                    this.isLienInTheNameOfDisable = true;
                    this.IsMarkedOnDisable = false;
                    this.requiredMarkedOn = true;//CISP-5752
                    this.requiredLienInTheName = false;//CISP-5752
                } else {
                    this.isLienInTheNameOfDisable = false;
                    this.IsMarkedOnDisable = true;
                    this.requiredLienInTheName = true;//CISP-5752
                    this.requiredMarkedOn = false;//CISP-5752
                }
            }
        } else if(field === 'markedOnDateField'){
            this.markedOnDate = event.target.value;
        }
    }

    loadNewUsedVehicleDetails() {}

    handleSubmit(event) {
        const field = event.target.name;
        console.debug(field.includes("newUsedVehicleSubmit"));
        if (field.includes("newUsedVehicleSubmit")) {
            let deliveryOptionValue = this.template.querySelector("lightning-radio-group[data-id=deliveryRadioGroupField]");
            let regNoValue = this.template.querySelector("lightning-input[data-id=regNoField]");
            let nameTransferValue = this.template.querySelector("lightning-combobox[data-id=nameTransferedField]");
            let currentVehicleOwnerValue = this.template.querySelector("lightning-input[data-id=currentVehicleOwnerField]");
            let lienMarkedValue = this.template.querySelector("lightning-combobox[data-id=lienMarkedField]");
            let markedOnValue = this.template.querySelector("lightning-input[data-id=markedOnDateField]");
            let nowLienInNameValue = this.template.querySelector("lightning-input[data-id=nowLienInTheNameOfField]");
            let engineNoValue = this.template.querySelector("lightning-input[data-id=engineNumberField]");
            let chassisNoValue = this.template.querySelector("lightning-input[data-id=chassisNumberField]");
            let rtaTaxRemittedUptoValue = this.template.querySelector("lightning-input[data-id=rtaTaxRemittedUptoField]");

            deliveryOptionValue.reportValidity();
            regNoValue.reportValidity();
            nameTransferValue.reportValidity();
            currentVehicleOwnerValue.reportValidity();
            markedOnValue.reportValidity();
            lienMarkedValue.reportValidity();
            nowLienInNameValue.reportValidity();
            if(this.isNotImplementVehicleType){
                engineNoValue.reportValidity();
                chassisNoValue.reportValidity();
            }
            rtaTaxRemittedUptoValue.reportValidity();

            console.log("regNoValue:", regNoValue);
            console.log("regNoValue:", engineNoValue);
            
            if (deliveryOptionValue.validity.valid && regNoValue.validity.valid && nameTransferValue.validity.valid && currentVehicleOwnerValue.validity.valid &&
                markedOnValue.validity.valid && nowLienInNameValue.validity.valid &&
                rtaTaxRemittedUptoValue.validity.valid && ((!this.isNotImplementVehicleType) || (this.isNotImplementVehicleType && engineNoValue.validity.valid && chassisNoValue.validity.valid))) {
                //Show spinner
                this.isSpinnerMoving = true;
                console.debug(this.disbursementrecordid);
                const newUsedVehicleFields = {};
                if (this.disbursementrecordid) {
                    newUsedVehicleFields[LoanDisbursement_ID_FIELD.fieldApiName] = this.disbursementrecordid;
                } else {
                    newUsedVehicleFields[Parent_Loan_Application_FIELD.fieldApiName] = this.recordid;
                }
                console.debug(markedOnValue.value);
                
                newUsedVehicleFields[DeliveryOption_FIELD.fieldApiName] = this.deliveryOptions;
                newUsedVehicleFields[RegTypeOption_FIELD.fieldApiName] = this.regTypeOptions;
                newUsedVehicleFields[RegistrationNo_FIELD.fieldApiName] = this.template.querySelector("lightning-input[data-id=regNoField]").value;
                newUsedVehicleFields[NameTransfered_FIELD.fieldApiName] = this.nameTransferred ? this.nameTransferred : "";
                newUsedVehicleFields[CurrentVehicleOwner_FIELD.fieldApiName] = this.template.querySelector("lightning-input[data-id=currentVehicleOwnerField]").value;
                newUsedVehicleFields[LienMarked_FIELD.fieldApiName] = this.lienMarked ? this.lienMarked.includes("yes") ? true : false : false;
                newUsedVehicleFields[MarkedOn_FIELD.fieldApiName] = this.template.querySelector("lightning-input[data-id=markedOnDateField]").value;
                newUsedVehicleFields[NowLienInNameOf_FIELD.fieldApiName] = this.template.querySelector("lightning-input[data-id=nowLienInTheNameOfField]").value;
                if(this.isNotImplementVehicleType){
                    newUsedVehicleFields[EngineNo_FIELD.fieldApiName] = this.template.querySelector("lightning-input[data-id=engineNumberField]").value;
                    newUsedVehicleFields[ChassisNo_FIELD.fieldApiName] = this.template.querySelector("lightning-input[data-id=chassisNumberField]").value;
                }
                newUsedVehicleFields[RTATaxes_Remitted_Upto_FIELD.fieldApiName] = this.template.querySelector("lightning-input[data-id=rtaTaxRemittedUptoField]").value;
                
                this.insertNewUsedVehicleDetails(newUsedVehicleFields);
                /*if(this.isNewUsedVehicleInfoUpdated==true){
                            newUsedVehicleFields[LoanDisbursement_ID_FIELD.fieldApiName] = this.disbursementrecordid;
                            this.updateNewUsedVehicleDetails(newUsedVehicleFields);
                        }
                        else{
                            this.insertNewUsedVehicleDetails(newUsedVehicleFields);
                        }*/
            } else {
                const evt = new ShowToastEvent({
                    title: "Error",
                    title: this.label.mandotoryDetailsNotProvide,
                    variant: "error",
                });
                this.dispatchEvent(evt);
                return null;
            }
        }
    }

    changeflagvalue() {
        this.uploadViewDocFlag = false;
    }

    async updateLoanApplicationDetails(fields) {
        const recordInput = { fields };
        //Calling createRecord method of uiRecordApi
        await updateRecord(recordInput)
            .then((response) => {
                //Hide spinner
                this.isSpinnerMoving = false;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: "Success",
                        message: "New Used Vehicle Info has successfully saved.",
                        variant: "success",
                    })
                );
                //this.saveLoanApplicationTransactionHistory(this.recordid,'Business Payments');
                this.navigateToNextTab();
            })
            .catch((error) => {
                //Hide spinner
                this.isSpinnerMoving = false;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: "Error",
                        message: "There are some error while saving Loan Application.",
                        variant: "error",
                    })
                );
            });
    }
    async insertNewUsedVehicleDetails(fields) {
        console.debug(fields);
        console.debug(this.disbursementrecordid);
        // if (this.disbursementrecordid) {
            const recordInput = { fields };
            await updateRecord(recordInput)
                .then((response) => {
                    //Hide spinner
                    this.isSpinnerMoving = false;
                    this.hasError = false;
                    console.debug(this.currentloanappstage);
                    console.debug(this.currentloanappsubstage);
                    this.disablefields = true;
                    if (
                        this.currentloanappstage.includes(
                            "Disbursement Request Preparation"
                        ) && !this.currentloanappsubstage.includes("New/Used Vehicle Details")
                    ) {
                        if(this.isTractor == false){
                            const loanApplicationInfo = {};
                            loanApplicationInfo[LoanApplicationId_Field.fieldApiName] =
                            this.recordid;
                            loanApplicationInfo[LoanApplicationSubStage_Field.fieldApiName] =
                            "New/Used Vehicle Details";
                            this.updateLoanApplicationDetails(loanApplicationInfo);
                        }else if(this.isTractor == true){
                            const dealNumberInfo = {};
                            dealNumberInfo[DealNumberId.fieldApiName] = this.dealId;
                            dealNumberInfo['Sub_Stage__c'] = 'New/Used Vehicle Details';
                            this.updateLoanApplicationDetails(dealNumberInfo);
                        }
                    } else {
                        // CISP-4770 - START
                        if(this.frompostsanction)
                              this.navigateToNextTab();
                        //CISP-4770 - END 
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: "Success",
                                message: "New Used Vehicle Info has successfully saved.",
                                variant: "success",
                            })
                        );
                    }

                    //this.navigateToNextTab();
                    //this.saveLoanApplicationTransactionHistory(this.recordid,'Business Payments');
                })
                .catch((error) => {
                    //Hide spinner
                    console.debug(error);
                    this.isSpinnerMoving = false;
                    this.hasError = true;
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: "Error",
                            message: "There are some error while saving Loan Application.",
                            variant: "error",
                        })
                    );
                });
        // } else {
        //     const recordInput = {
        //         apiName: LoanDisbursement_OBJECT.objectApiName,
        //         fields,
        //     };
        //     //Calling createRecord method of uiRecordApi
        //     await createRecord(recordInput)
        //         .then((response) => {
        //             //Hide spinner
        //             this.isSpinnerMoving = false;
        //             this.dispatchEvent(
        //                 new ShowToastEvent({
        //                     title: "Success",
        //                     message: "New Used Vehicle Info has successfully saved.",
        //                     variant: "success",
        //                 })
        //             );
        //             this.disbursementrecordid = response.id;
        //             this.navigateToNextTab();
        //         })
        //         .catch((error) => {
        //             //Hide spinner
        //             this.isSpinnerMoving = false;
        //             this.dispatchEvent(
        //                 new ShowToastEvent({
        //                     title: "Error",
        //                     message: error.body.message,
        //                     variant: "error",
        //                 })
        //             );
        //         });
        // }
    }

    /*async updateNewUsedVehicleDetails(fields) {
          const recordInput = {fields};
          //Calling createRecord method of uiRecordApi
          await updateRecord(recordInput)
          .then(response =>{
              //Hide spinner
              this.isSpinnerMoving=false;
              this.dispatchEvent(
                  new ShowToastEvent({
                      title: 'Success',
                      message: 'New Used Vehicle Info has successfully updated.',
                      variant: 'success'
                  }),
              );
              this.disbursementrecordid = response.id;   
              this.navigateToNextTab();  
          })
          .catch(error => {
              //Hide spinner
              this.isSpinnerMoving=false;
              this.dispatchEvent(
                  new ShowToastEvent({
                      title: 'Error',
                      message: error.body.message,
                      variant: 'error'
                  }),
              );
          });
      }*/

    navigateToNextTab() {
        this.dispatchEvent(
            new CustomEvent("successfullysubmitted", {
                detail: this.disbursementrecordid,
            })
        );
    }
    errorInCatch() {
        const evt = new ShowToastEvent({
            title: "Error",
            message: this.tryCatchError.body,
            variant: "Error",
        });
        this.dispatchEvent(evt);
    }
}