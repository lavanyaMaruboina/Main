import getAccountDetails from '@salesforce/apex/AccountSearchController.getAccountDetails';
import createDealer from '@salesforce/apex/DealerCreation.createDealer';
import getActiveTypePicklistValues from '@salesforce/apex/DealerCreation.getActiveTypePicklistValues';
import LightningAlert from 'lightning/alert';
import { LightningElement, track, wire } from 'lwc';

export default class DealerCreationForm extends LightningElement {

    @track firstName = '';
    @track lastName = '';
    @track email = '';
    @track phone = '';
    // @track registrationNumber = '';
    @track yearStarted = '';
    @track ContactName = '';
    @track ContactPhone = '';
    @track isActive = '';
    // @track gstNumber = '';
    @track accountId = '';
    @track statusOptions = [];
    @track selectedStatus;
    @track shippingStreet;
    @track shippingCity;
    @track shippingState;
    @track shippingPostalCode;
    @track shippingCountry;
    @track accountDetails = false;
    @track showAccountForm = true;
    @track ShowListofDealers =false;

    handleFirstNameChange(event){
        this.firstName = event.target.value;
    }

    handleLastNameChange(event){
        this.lastName = event.target.value;

    }

    handleEmailChange(event){
        this.email = event.target.value;
    }

    handlePhoneChange(event){
        this.phone = event.target.value;
    }

    // handleRegistrationNumber(event){
    //     this.registrationNumber = event.target.value;
    // }

    handleYearStarted(event){
        this.yearStarted = event.target.value;
    }

    handleContactNameChange(event){
        this.ContactName = event.target.value;
    }

    handleContactPhoneChange(event){
        this.ContactPhone = event.target.value;
    }

    // handleIsActive(event){
    //     this.isActive = event.target.value;
    // }

    // handlGstNumber(event){
    //     this.gstNumber = event.target.value;
    // }

    addressChange(event) {
        this.shippingStreet = event.target.street;
        this.shippingCity = event.target.city;
        this.shippingState = event.target.province;
        this.shippingCountry = event.target.country;
        this.shippingPostalCode = event.target.postalCode;
    }
   
    @wire(getActiveTypePicklistValues)
    wiredPicklistValues({ error, data }) {
        if (data) {
            this.statusOptions = data.map(value => ({ label: value, value }));
        } else if (error) {
            this.error = error;
        }
    }

    handleIsActive(event) {
        this.selectedStatus = event.target.value;
    }


    handleSave() {
        if (this.validateForm()) {
            const dealer = {
                FirstName: this.firstName,
                LastName: this.lastName,
                Email__c: this.email,
                Phone: this.phone,
                // registrationNumber: this.registrationNumber,
                YearStarted: this.yearStarted,
                Primary_Contact_Name__c: this.ContactName,
                Primary_Contact_Phone__c: this.ContactPhone,
                Active__c: this.selectedStatus,
                // gstNumber: this.gstNumber,
                ShippingStreet: this.shippingStreet,
                ShippingCity: this.shippingCity,
                ShippingState: this.shippingState,
                ShippingPostalCode: this.shippingPostalCode,
                ShippingCountry: this.shippingCountry

            };

            createDealer({ dealer })
                .then(result => {
                    console.log('Dealer created successfully', result);
                    this.resetForm();
                    this.showAccountForm=false;
                    //this.accountDetails =true;
                    this.fetchAccountDetails( result.Id);
                    this.accountId = result.Id;
                    this.showSuccessAlertSuccess();
                    
                    //alert('Dealer created successfully');
                })
                .catch(error => {
                    console.error('Error creating Dealer', error);
                    alert('An error occurred while creating the Dealer');
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
        // this.registrationNumber = '';
        this.yearStarted = '';
        this.ContactName = '';
        this.ContactPhone = '';
        this.isActive = '';
        // this.gstNumber = '';
        this.shippingStreet = '';
        this.shippingCity = '';
        this.shippingState = '';
        this.shippingPostalCode = '';
        this.shippingCountry = '';
    }
    fetchAccountDetails(accountId) {
        getAccountDetails({ accountId })
            .then(data => {
                if (data) {
                    console.log('Fetched contact details', JSON.stringify(data));
                    this.account = [data];
                    this.accountDetails = true;
                }
            })
            .catch(error => {
                console.error('Error fetching contact details:', error);
            });
    }
    
    backToDealerDetails(){
        this.accountDetails = false;
        this.showAccountForm = false;
        this.ShowListofDealers =true;
        window.location.reload();
    }
    showErrorAlert(headerLabel, bodyMessage) {
        LightningAlert.open({
            message: bodyMessage,
            theme: 'error',
            label: headerLabel,
        });
    }

    showSuccessAlertSuccess() {
        LightningAlert.open({
            message: 'Dealer Created successfully',
            theme: 'Success',
            label: 'Success',
        });
    }

}