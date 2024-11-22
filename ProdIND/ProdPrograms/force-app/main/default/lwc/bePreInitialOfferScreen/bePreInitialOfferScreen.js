// Author: Haarika Chodisetti
// Company: Salesforce
// Description: Child component for Business Executive Pre Initial Offer functionality
import { LightningElement, wire, api, track } from "lwc";
import getApplicantData from "@salesforce/apex/beScreensController.getApplicantData";
import getRefreshedApplicantData from "@salesforce/apex/beScreensController.getRefreshedApplicantData";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

export default class bePreInitial extends LightningElement {
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
  aggregator = false;

  isSpinnerMoving = false;
  connectedCallback(){
  this.isSpinnerMoving = true;
  getApplicantData({ 'recordId': this.appId})
    .then((data) =>{
    console.log("wired : ", this.appId);
    if (data) {
      this.applicantData = JSON.parse(JSON.stringify(data));
      var that = this;
      setTimeout(function () {
        that.validateFields();
      }, 100);

      this.error = undefined;
      this.isSpinnerMoving = false;
    } else {
      this.isSpinnerMoving = false;
      this.error = error;
      this.applicantData = undefined;
  }
  }).catch(error=>{
      this.error = error;
      this.applicantData = undefined;
      this.isSpinnerMoving = false;
  });

  }

  getRefreshedDetails() {
    getRefreshedApplicantData({ recordId: this.appId })
      .then((data) => {
        this.applicantData = JSON.parse(JSON.stringify(data));
      })
      .error((error) => {
        console.log(error);
      });
  }

  get productType() {
    let val;
    if (this.applicantData?.initialOfferDetails) {
      console.log(
        "this.applicantData.initialOfferDetails ",
        this.applicantData.initialOfferDetails
      );

      val =
        this.applicantData.initialOfferDetails.Product_Type__c +
        " " +
        this.applicantData.initialOfferDetails.Vehicle_Type__c;
        if (this.applicantData.initialOfferDetails.Aggregator_Source__c != null) {
          this.aggregator = true;
          console.log('set');
        }
        else if (val === "Two Wheeler New"){
          this.twoWheeler = true;
        } 
        else if (val === "Passenger Vehicles Used") {
          this.PV = true;
        } else if (
          this.applicantData.initialOfferDetails.Vehicle_Type__c === "Refinance"
        ) {
          this.refinance = true;
        } 
    }
    return val;
  }

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

  get applicant() {
    if (this.applicantData?.applicant) {
      if (
        this.applicantData.applicant.Contact_number__c != null &&
        this.applicantData.applicant.Contact_number__c ===
          this.applicantData.applicant.Whatsapp_number__c
      ) {
        this.applicantData.applicant.areWhatsappMobileSame = true;
      }
    }
    return this.applicantData?.applicant == null
      ? {}
      : this.applicantData.applicant;
  }

  showToast(toastTitle, message, variant) {
    const evt = new ShowToastEvent({
      title: toastTitle,
      message: message,
      variant: variant
    });
    this.dispatchEvent(evt);
  }

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

  // get preInitialAddressDocument(){
  //   return this.applicantData?.preInitialAddressDetails == null?{}:this.applicantData.preInitialAddressDetails;
  // }

  get vehicleDetails() {
    return this.applicantData?.vehicleDetails == null
      ? {}
      : this.applicantData.vehicleDetails;
  }

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

  get existingEMIDetails() {
    return this.applicantData?.existingEMIDetails == null
      ? {}
      : this.applicantData.existingEMIDetails;
  }

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