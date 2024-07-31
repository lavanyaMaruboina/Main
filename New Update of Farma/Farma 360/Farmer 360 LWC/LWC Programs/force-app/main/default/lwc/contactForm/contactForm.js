import { LightningElement, track, wire, api } from 'lwc';
import getContactDetails from '@salesforce/apex/AccountSearchController.getContactDetails';
import createContact from '@salesforce/apex/ContactController.createContact';
import CONTACT_OBJECT from '@salesforce/schema/Contact';
import SUB_TYPE_FIELD from '@salesforce/schema/Contact.Sub_Type__c';
import FARMER_TYPE_FIELD from '@salesforce/schema/Contact.Type_of_Farmer__c';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import uploadFile from '@salesforce/apex/ImageController.uploadFile';
import Icons from '@salesforce/resourceUrl/farmer360';
import LightningAlert from 'lightning/alert';
import saveFarmerSignature from '@salesforce/apex/SignatureController.saveFarmerSignature';
import Id from "@salesforce/user/Id";


export default class ContactForm extends LightningElement {

    camera = Icons + '/farmer360/KipiIcons/HomePage/camera.png';

    @track firstName = '';
    @track userId = Id;
    @track lastName = '';
    @track email = '';
    @track consent;
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
    capturedImages = []; // Array to store captured images
    imageContainer;

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

    handleFarmerConsentChange(event) {
        this.consent = true;
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
                Farmer_Consent__c: this.consent,
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
                    console.log('contact id======', result.Id);


                    this.resetForm();
                    this.showSuccessAlert();
                    this.showContactForm = false;
                    this.fetchContactDetails(result.Id);
                    this.contactId = result.Id;
                    this.sendImageToApex();
                    this.attachSignaturetoFarmer();
                    //  this.saveSignature(e);

                })
                .catch(error => {
                    console.error('Error creating contact:', error);
                    this.showErrorAlert();
                });
        }

    }

    attachSignaturetoFarmer(){
        console.log('I am in Sending the signature to farmer');
    saveFarmerSignature({UserID : this.userId , recId: this.contactId})
    .then(result => {
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: 'Signature Image saved in record',
                variant: 'success',
            }),
        );
        this.showSuccessAlert();
        console.log('got the user id : ', this.userId);
        console.log('got the record id : ', this.contactId);
        //console.log('record id for the signature: ', this.recordId);
    })
    .catch(error => {
        //show error message
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error uploading signature in Salesforce record',
                message: error.body.message,
                variant: 'error',
            }),
        );
    });

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
        this.consent = false;
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
            this.imageContainer = this.template.querySelector('.imageContainer'); // Get the container for images
            this.fileInputElement = this.template.querySelector('.file-input'); // Get the file input element
            
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
            // Create a new canvas for each capture
            const newCanvas = document.createElement('canvas');
            newCanvas.height = this.videoElement.videoHeight;
            newCanvas.width = this.videoElement.videoWidth;
            const context = newCanvas.getContext('2d');
            context.drawImage(this.videoElement, 0, 0, newCanvas.width, newCanvas.height);

            // Add date and time
            const now = new Date();
            const dateTimeString = now.toLocaleString();
            context.font = '20px Arial';
            context.fillStyle = 'white';
            context.fillText(dateTimeString, 10, newCanvas.height - 40);

            // Get location
            if (navigator.geolocation) {
                navigator.geolocation.getCurrentPosition((position) => {
                    const { latitude, longitude } = position.coords;
                    const locationString = `Lat: ${latitude.toFixed(6)}, Lon: ${longitude.toFixed(6)}`;
                    context.fillText(locationString, 10, newCanvas.height - 10);

                    const imageData = newCanvas.toDataURL('image/png');
                    this.addCapturedImage(newCanvas, imageData);
                }, (error) => {
                    console.error('Error getting location: ', error);
                    this.addImageDataAndShow(newCanvas, dateTimeString, 'Location error');
                });
            } else {
                console.error('Geolocation is not supported in this browser');
                this.addImageDataAndShow(newCanvas, dateTimeString, 'Geolocation not supported');
            }
        }
    }

    triggerFileUpload() {
        this.fileInputElement.click();
    }

    handleFileUpload(event) {
        const file = event.target.files[0];
        if (file) {
            const reader = new FileReader();
            reader.onload = (e) => {
                const imageData = e.target.result;
                this.addCapturedImage(null, imageData, true); // Indicate this is an uploaded image
            };
            reader.readAsDataURL(file);
        }
    }

    addCapturedImage(canvas, imageData, isUploaded = false) {
        const imageWrapper = document.createElement('div');
        imageWrapper.classList.add('image-wrapper');

        const imageElement = document.createElement('img');
        imageElement.setAttribute('src', imageData);
        imageElement.classList.add('slds-show');
        imageElement.classList.remove('slds-hide');

        const deleteButton = document.createElement('button');
        deleteButton.textContent = 'Remove';
        deleteButton.classList.add('slds-button', 'slds-button_destructive');
        deleteButton.style.position = 'absolute';
        deleteButton.style.top = '5px';
        deleteButton.style.right = '5px';
        deleteButton.style.backgroundColor = '#e74c3c';
        deleteButton.style.color = 'white';
        deleteButton.style.border = 'none';
        deleteButton.style.padding = '5px 10px';
        deleteButton.style.cursor = 'pointer';
        deleteButton.style.zIndex = '10';

        deleteButton.onclick = () => {
            this.imageContainer.removeChild(imageWrapper);
            this.capturedImages = this.capturedImages.filter(img => img !== imageData);
        };

        imageWrapper.style.position = 'relative';
        imageWrapper.style.display = 'inline-block';

        imageWrapper.appendChild(imageElement);
        imageWrapper.appendChild(deleteButton);
        this.imageContainer.appendChild(imageWrapper);
        console.log('Image container>>>', this.imageContainer);

        this.capturedImages.push(imageData);
        console.log('Capture Image container>>>', JSON.stringify(this.capturedImages));
    }

    addImageDataAndShow(canvas, dateTimeString, locationString) {
        const context = canvas.getContext('2d');
        context.font = '20px Arial';
        context.fillStyle = 'white';
        context.fillText(dateTimeString, 10, canvas.height - 40);
        context.fillText(locationString, 10, canvas.height - 10);

        const imageData = canvas.toDataURL('image/png');
        this.addCapturedImage(canvas, imageData);
    }

    async sendImageToApex() {
        console.log('Apex called', this.capturedImages);
        if (this.capturedImages.length > 0) {
            try {
                for (let imageData of this.capturedImages) {
                    const response = await uploadFile({
                        base64: imageData.split(',')[1],
                        filename: 'CapturedImage.png',
                        contactId: this.contactId
                    });
                    console.log('Image sent successfully: ', response);
                }

                // Stop the camera and update the state after sending the images
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