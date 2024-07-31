import { LightningElement, track, wire } from 'lwc';
import getContactDetails from '@salesforce/apex/AccountSearchController.getContactDetails';
import createContact from '@salesforce/apex/ContactController.createContact';
import CONTACT_OBJECT from '@salesforce/schema/Contact';
import SUB_TYPE_FIELD from '@salesforce/schema/Contact.Sub_Type__c';
import FARMER_TYPE_FIELD from '@salesforce/schema/Contact.Type_of_Farmer__c';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import uploadFile from '@salesforce/apex/ImageController.uploadFile';
import Icons from '@salesforce/resourceUrl/farmer360';
import LightningAlert from 'lightning/alert';


export default class ContactForm extends LightningElement {

    camera = Icons + '/farmer360/KipiIcons/HomePage/camera.png';

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


    @track isCameraInitialized = false;
    videoElement;
    canvasElement;
    capturedImageData;

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
                    this.showSuccessAlert();
                    this.showContactForm=false;
                     this.fetchContactDetails( result.Id);
                     this.contactId=result.Id;
                     this.sendImageToApex();
                    
                })
                .catch(error => {
                    console.error('Error creating contact:', error);
                    this.showErrorAlert();
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


    renderedCallback() {
        if (!this.videoElement) {
            this.videoElement = this.template.querySelector('.videoElement');
            this.canvasElement = this.template.querySelector('.canvasElement');
        }
    }

    async initCamera() {
        if (navigator.mediaDevices && navigator.mediaDevices.getUserMedia) {
            try {
                this.videoElement.srcObject = await navigator.mediaDevices.getUserMedia({ video: true, audio: false });
                this.isCameraInitialized = true;
            } catch (error) {
                console.error('Error accessing camera: ', JSON.stringify(error));
            }
        } else {
            console.error('getUserMedia is not supported in this browser');
        }
    }

    async captureImage() {
        if (this.videoElement && this.videoElement.srcObject) {
            this.canvasElement.height = this.videoElement.videoHeight;
            this.canvasElement.width = this.videoElement.videoWidth;
            const context = this.canvasElement.getContext('2d');
            context.drawImage(this.videoElement, 0, 0, this.canvasElement.width, this.canvasElement.height);
            this.capturedImageData = this.canvasElement.toDataURL('image/png');

            const imageElement = this.template.querySelector('.imageElement');
            imageElement.setAttribute('src', this.capturedImageData);
            imageElement.classList.add('slds-show');
            imageElement.classList.remove('slds-hide');
            
            // Do not stop the camera here; keep it running until the image is sent
        }
        console.log('Image>>>>>', this.capturedImageData);
    }

    async sendImageToApex() {
        console.log('Apex called', this.capturedImageData);
        if (this.capturedImageData) {
            try {
                const response = await uploadFile({ 
                    base64: this.capturedImageData.split(',')[1], 
                    filename: 'CapturedImage.png', 
                    contactId: this.contactId 
                });
                console.log('Image sent successfully: ', response);
                
                // Stop the camera and update the state after sending the image
                if (this.videoElement && this.videoElement.srcObject) {
                    this.videoElement.srcObject.getTracks().forEach((track) => track.stop());
                    this.videoElement.srcObject = null;
                    this.isCameraInitialized = false;
                }
            } catch (error) {
                console.error('Error sending image to Apex: ', error);
            }
        } else {
            console.error('No image data to send');
        }
    }

    //

    // Method to show an success alert
        showSuccessAlert() {
            LightningAlert.open({
                message: 'Contact Created',
                theme: 'Success',
                label: 'Success',
            });
        }

        // Method to show an error alert
        showErrorAlert(headerLabel, bodyMessage) {
            LightningAlert.open({
                message: bodyMessage,
                theme: 'error',
                label: headerLabel,
            });
        }

}