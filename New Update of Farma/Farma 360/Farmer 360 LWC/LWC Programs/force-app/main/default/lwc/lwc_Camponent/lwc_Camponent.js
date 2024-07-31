import { LightningElement, track } from 'lwc';
import createLeadRecord from '@salesforce/apex/LandDetailsController.createLeadRecord';

export default class LeadCaptureForm extends LightningElement {
    @track firstName = '';
    @track lastName = '';
    @track company = '';
    @track title = '';
    @track email = '';
    @track phone = '';
    // Add more tracked variables for other fields

    handleFirstNameChange(event) {
        this.firstName = event.target.value;
    }

    handleLastNameChange(event) {
        this.lastName = event.target.value;
    }

    handleCompanyChange(event) {
        this.company = event.target.value;
    }

    handleTitleChange(event) {
        this.title = event.target.value;
    }

    handleEmailChange(event) {
        this.email = event.target.value;
    }

    handlePhoneChange(event) {
        this.phone = event.target.value;
    }

    // Add event handlers for other fields as necessary

    handleSubmit() {
        // Call Apex method to create Lead record
        createLeadRecord({
            firstName: this.firstName,
            lastName: this.lastName,
            company: this.company,
            title: this.title,
            email: this.email,
            phone: this.phone
            // Pass other field values here
        })
        .then(result => {
            // Handle success
            console.log('Lead created successfully: ' + result);
            // Display pop-up message
            this.showSuccessPopup();
            // Refresh the page
            window.location.reload();
        })
        .catch(error => {
            // Handle error
            console.error('Error creating Lead: ' + error);
            // Display error pop-up
             this.showErrorPopup(error);
        });
    }

    // showSuccessPopup() {
    //     const successEvent = new CustomEvent('showsuccess', {
    //         detail: {
    //             title: 'Success',
    //             message: 'Lead created successfully',
    //         },
    //     });
    //     this.dispatchEvent(successEvent);
    // }

    // showErrorPopup(error) {
    //     const errorEvent = new CustomEvent('showerror', {
    //         detail: {
    //             title: 'Error',
    //             message: error.body.message,
    //         },
    //     });
    //     this.dispatchEvent(errorEvent);
    // }
}