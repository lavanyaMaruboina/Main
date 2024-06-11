import getContactDetails from '@salesforce/apex/AccountSearchController.getContactDetails';
import createContact from '@salesforce/apex/ContactController.createContact';
import CONTACT_OBJECT from '@salesforce/schema/Contact';
import SUB_TYPE_FIELD from '@salesforce/schema/Contact.Sub_Type__c';
import FARMER_TYPE_FIELD from '@salesforce/schema/Contact.Type_of_Farmer__c';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import { LightningElement, track, wire } from 'lwc';

export default class ContactForm extends LightningElement {
    @track firstName = '';
    @track lastName = '';
    @track email = '';
    @track phone = '';
    @track mailingStreet = '';
    @track mailingCity = '';
    @track mailingState = '';
    @track mailingPostalCode = '';
    @track mailingCountry = '';
    @track dob = '';
    @track aadharNumber = '';
    @track panNumber = '';
    @track contactDetails = false;
    @track showContactForm = true;
    @track contactId = '';
    @track landForms = false;
    @track statusOptions = [];
    @track subTypeOptions = [];
    selectedFarmerType = '';
    selectedSubType = '';
    picklistValuesObj;
    @track contactId;

    @track countyOptions;
    @track continentOptions;

    @wire(getObjectInfo, { objectApiName: CONTACT_OBJECT })
    contactInfo;

    @wire(getPicklistValues, { recordTypeId: '$contactInfo.data.defaultRecordTypeId', fieldApiName: SUB_TYPE_FIELD })
    countryFieldInfo({ data, error }) {
        if (data) this.countryFieldData = data;
    }

    @wire(getPicklistValues, { recordTypeId: '$contactInfo.data.defaultRecordTypeId', fieldApiName: FARMER_TYPE_FIELD })
    continentFieldInfo({ data, error }) {
        if (data) this.continentOptions = data.values;
    }

    handleFarmerTypeChange(event) {
        let key = this.countryFieldData.controllerValues[event.target.value];
        this.countyOptions = this.countryFieldData.values.filter(opt => opt.validFor.includes(key));
        this.selectedFarmerType = event.target.value;
    }

    handleSubTypeChange(event) {
        this.selectedSubType = event.target.value;
    }

    handleFirstNameChange(event) {
        this.firstName = event.target.value;
    }

    handleLastNameChange(event) {
        this.lastName = event.target.value;
    }

    handleEmailChange(event) {
        this.email = event.target.value;
    }

    handlePhoneChange(event) {
        this.phone = event.target.value;
    }

    handleMailingStreetChange(event) {
        this.mailingStreet = event.target.value;
    }

    handleMailingCityChange(event) {
        this.mailingCity = event.target.value;
    }

    handleMailingStateChange(event) {
        this.mailingState = event.target.value;
    }

    handleMailingPostalCodeChange(event) {
        this.mailingPostalCode = event.target.value;
    }

    handleMailingCountryChange(event) {
        this.mailingCountry = event.target.value;
    }

    handleDOBChange(event) {
        this.dob = event.target.value;
    }

    handleAadharChange(event) {
        this.aadharNumber = event.target.value;
    }

    handlePANNumberChange(event) {
        this.panNumber = event.target.value;
    }

    handleSave() {
        if (this.validateForm()) {
            const fields = {
                FirstName: this.firstName,
                LastName: this.lastName,
                Email: this.email,
                Phone: this.phone,
                MailingStreet: this.mailingStreet,
                MailingCity: this.mailingCity,
                MailingState: this.mailingState,
                MailingPostalCode: this.mailingPostalCode,
                MailingCountry: this.mailingCountry,
                DOB__c: this.dob,
                Aadhar_Number__c: this.aadharNumber,
                PAN_Card__c: this.panNumber,
                Type_of_Farmer__c: this.selectedFarmerType,
                Sub_Type__c: this.selectedSubType
            };

            createContact({ contact: fields })
                .then(result => {
                    console.log('Contact created successfully:', result);
                    console.log('contact id======',result.Id);
                  
                    this.resetForm();
                    this.showContactForm=false;
                    alert('Contact created successfully');
                     this.fetchContactDetails( result.Id);
                     this.contactId=result.Id;
                })
                .catch(error => {
                    console.error('Error creating contact:', error);
                });
        }
    }

    validateForm() {
        const allValid = [...this.template.querySelectorAll('lightning-input')]
            .reduce((validSoFar, inputCmp) => {
                inputCmp.reportValidity();
                return validSoFar && inputCmp.checkValidity();
            }, true);
        return allValid;
    }

    handleCancel() {
        window.location.reload();
    }

    resetForm() {
        this.firstName = '';
        this.lastName = '';
        this.email = '';
        this.phone = '';
        this.mailingStreet = '';
        this.mailingCity = '';
        this.mailingState = '';
        this.mailingPostalCode = '';
        this.mailingCountry = '';
        this.selectedFarmerType = '';
        this.selectedSubType = '';
        this.dob = '';
        this.aadharNumber = '';
        this.panNumber = '';
    }

    fetchContactDetails(contactId) {
        getContactDetails({ contactId })
            .then(data => {
                if (data) {
                    console.log('Fetched contact details', data);
                    this.contact = [data];
                    this.contactDetails = true;
                }
            })
            .catch(error => {
                console.error('Error fetching contact details:', error);
            });
    }

    handleCreateLand() {
        this.landForms = true;
        this.showContactForm = false;
        this.contactDetails = false;
    }

    handleBack() {
        window.location.reload();
    }
}