// Author: Raman Raj Saxena
// Company: Salesforce
// Description: Child component for ConVox CTI functionality
// History
// Date            Author              Comments
// -------------------------------------------------------------
//                 Raman Raj Saxena           Created
// 02-08-2022      Haarika Chodisetti         Modified
// ------------------------------------------------------------
import { LightningElement, wire, api, track } from "lwc";
import getApplicantData from "@salesforce/apex/CTIApplicantViewController.getApplicantData";
import getRefreshedApplicantData from "@salesforce/apex/CTIApplicantViewController.getRefreshedApplicantData";

import Basic_Details from "@salesforce/label/c.Basic_Details";
import Aadhar_Details from "@salesforce/label/c.Aadhar_Details";
import Personal_Details from "@salesforce/label/c.Personal_Details";
import Professional_Details from "@salesforce/label/c.Professional_Details";
import Vehicle_Details from "@salesforce/label/c.Vehicle_Details";
import Initial_Offer_Details from "@salesforce/label/c.Initial_Offer_Details";

export default class LightningExampleAccordionMultiple extends LightningElement {
  activeSections = ["loginDetails"];
  activeSectionsMessage = "";
  recordId;
  @track applicantData;
  @track refreshedData;
  @track error;
  @api appId;
  twoWheeler = false;
  PV = false;
  refinance = false;
  etb = true;
  label = {
    Basic_Details,
    Aadhar_Details,
    Personal_Details,
    Professional_Details,
    Vehicle_Details,
    Initial_Offer_Details
  };

  //Raman - populate applicantData FROM the data returned by getApplicantData
  @wire(getApplicantData, { recordId: "$appId" })
  wiredApplicant({ error, data }) {
    console.log("wired : ", this.appId);
    if (data) {
      this.applicantData = JSON.parse(JSON.stringify(data));
      var that = this;
      setTimeout(function () {
        that.validateFields();
      }, 100);

      this.error = undefined;
    } else if (error) {
      this.error = error;
      this.applicantData = undefined;
    }
  }

  //Haarika - 02-08-2022 - Repopulate applicantData with updated data returned by getRefreshedApplicantData
  getRefreshedDetails() {
    getRefreshedApplicantData({ recordId: this.appId })
      .then((data) => {
        this.applicantData = JSON.parse(JSON.stringify(data));
      })
      .error((error) => {
        console.log(error);
      });
  }

  //Haarika - 02-08-2022 - determine the journey type
  get productType() {
    let val;
    const twoWheelerNew = "Two Wheeler New";
    const passengerVehiclesUsed = "Passenger Vehicles Used";
    const refin = "Refinance";
    if (this.applicantData?.initialOfferDetails) {
      val =
        this.applicantData.initialOfferDetails.Product_Type__c +
        " " +
        this.applicantData.initialOfferDetails.Vehicle_Type__c;
      if (val === twoWheelerNew) {
        this.twoWheeler = true;
      } else if (val === passengerVehiclesUsed) {
        this.PV = true;
      } else if (
        this.applicantData.initialOfferDetails.Vehicle_Type__c === refin
      ) {
        this.refinance = true;
      }
    }
    return val;
  }

  //Raman - validate fields
  validateFields() {
    this.template.querySelectorAll("lightning-input").forEach((element) => {
      if (
        (element.value == null || element.value == "") &&
        element.type != "checkbox" &&
        !element.className.includes("auto-filled")
      ) {
        element.className = "invalid";
      }
    });
  }

  //Raman - get Applicant_c details of current Applicant
  get applicant() {
    if (
      this.applicantData?.applicant &&
      this.applicantData.applicant.Contact_number__c != null &&
      this.applicantData.applicant.Contact_number__c ===
        this.applicantData.applicant.Whatsapp_number__c
    ) {
      this.applicantData.applicant.areWhatsappMobileSame = true;
    }
    return this.applicantData?.applicant == null
      ? {}
      : this.applicantData.applicant;
  }

  
  //Raman - get Documents__c record details of Aadhar type of current Applicant
  get aadharDocument() {
    return this.applicantData?.aadharAddressDetails == null
      ? {}
      : this.applicantData.aadharAddressDetails;
  }
  get poaDocument() {
    return this.applicantData?.poaDetails == null
      ? {}
      : this.applicantData.poaDetails;
  }

  //Raman - get Vehicle details of current Applicant
  get vehicleDetails() {
    return this.applicantData?.vehicleDetails == null
      ? {}
      : this.applicantData.vehicleDetails;
  }

  //Haarika - 02-08-2022 - get Income details of current Applicant
  get incomeDetails() {
    return this.applicantData?.incomeDetails == null
      ? {}
      : this.applicantData.incomeDetails;
  }
  
  get monthlyIncome(){
    return this.applicantData?.applicant?.Declared_income__c ? this.applicantData.applicant.Declared_income__c/12 : null;
  }
  
   get finalTermDetails(){
      return this.applicantData?.finalTermDetails == null?{}:this.applicantData.finalTermDetails;
  }

  //Haarika - 02-08-2022 - get Existing EMI details of current Applicant
  get existingEMIDetails() {
    return this.applicantData?.existingEMIDetails == null
      ? {}
      : this.applicantData.existingEMIDetails;
  }

  //Raman - get opportunity(Initial Offer) details of current Applicant
  get initialOffer() {
    return this.applicantData?.initialOfferDetails == null
      ? {}
      : this.applicantData.initialOfferDetails;
  }

  get isETB(){
    return this.applicantData?.initialOfferDetails?.Is_ETB__c == true ? true : false;
  }

  get isReKYC(){
    return this.applicantData?.initialOfferDetails?.RE_KYC_Stage__c != null ? true : false;
  }

  get showPreOfferKYC(){
    return this.applicantData?.initialOfferDetails?.Is_ETB__c == false ? true : this.applicantData?.initialOfferDetails?.RE_KYC_Stage__c == 'PreInitialOffer'?true:false;
  }

  get bankExecutiveLabel(){
    return this.twoWheeler ? 'MO Name': 'Bank Executive Name';
  }

  get bankExecutiveContactLabel(){
    return this.twoWheeler ? 'MO Contact': 'Bank Executive Contact';
  }

  //*CFDI-341
  get panNumber() {
    return (this.applicant.PAN_No__c != null && this.applicant.PAN_No__c != undefined) ? this.applicant.PAN_No__c.toUpperCase(): this.applicant.PAN_No__c;
  }

  get ETB_OR_NTB() {
    return this.isETB ? 'ETB' : 'NTB';
  }

  handleSectionToggle(event) {
    const openSections = event.detail.openSections;

    if (openSections.length === 0) {
      this.activeSectionsMessage = "All sections are closed";
    } else {
      this.activeSectionsMessage = "Open sections: " + openSections.join(", ");
    }
  }
}