import { LightningElement, track, wire } from 'lwc';
import createContact from '@salesforce/apex/ContactController.createContact';
import getContactDetails from '@salesforce/apex/AccountSearchController.getContactDetails';

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
    @track contactDetails = false;
    @track showContactForm = true;
    @track contactId = '';
    @track landForms = false;
    @track contactList = [];

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

    handleSave() {
        if (this.validateForm()) {
            const contact = {
                FirstName: this.firstName,
                LastName: this.lastName,
                Email: this.email,
                Phone: this.phone,
                MailingStreet: this.mailingStreet,
                MailingCity: this.mailingCity,
                MailingState: this.mailingState,
                MailingPostalCode: this.mailingPostalCode,
                MailingCountry: this.mailingCountry
            };

            createContact({ contact })
                .then(result => {
                    console.log('Contact created successfully', result);
                    this.contactId = result.Id;
                    this.fetchContactDetails(this.contactId);
                    this.showContactForm = false;
                    alert('Contact created successfully');
                })
                .catch(error => {
                    console.error('Error creating contact', error);
                    alert('An error occurred while creating the contact');
                });
        } else {
            console.error('Please fill in all required fields');
            alert('Please fill in all required fields');
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

    handleCreateLand(){
        this.landForms = true;
        this.showContactForm = false;
        this.contactDetails = false;
    }

    handleBack(){
        window.location.reload();
    }
}