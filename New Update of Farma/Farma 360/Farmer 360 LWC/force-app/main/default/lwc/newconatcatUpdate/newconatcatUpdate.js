import { LightningElement, track, api, wire } from 'lwc';
import search from '@salesforce/apex/AccountSearchController.search';
import updateContacts from '@salesforce/apex/AccountSearchController.updateContacts';
import insertVisitNotes from '@salesforce/apex/AccountSearchController.insertVisitNotes';
//import associateFileWithContact from '@salesforce/apex/AccountSearchController.associateFileWithContact';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class  NewconatcatUpdate  extends LightningElement {
    @track contactDetails = [];
    @track error;
    @track isModalOpen = false;
    @track selectedContactDetails = [];
    @track editedFields = {};
    @track showLandDetailsForm = false;
    @track showOrderDetailsForm = false;
    @track iscontactObj = false;
    @track showHarvestDetailsForm = false;
    @track contactDetailsForm = true;
    @track tabsHandler = false;
    @track pictureHandler = false;
    @track showMapDetails = false;
    @track showSearch = true;
    @track showHandlerVisitNotes = false;
    @track contactId;
    @track visitName = '';
    @track visitNotes = '';
    @track contactName = '';
    @track acceptedFormats = ['.jpg', '.jpeg', '.png'];
    @track draftValues = [];
    @track contactName = '';

    handleUploadFinished(event) {
        const uploadedFiles = event.detail.files;
        const contactId = this.contactObj.idField;

        uploadedFiles.forEach(file => {
            const fileId = file.documentId;
            associateFileWithContact({ fileId: fileId, contactId: contactId })
                .then(() => {
                    this.showToast('Success', 'File uploaded with contact', 'success');
                })
                .catch(error => {
                    this.showToast('Error', 'Error associating file with contact: ' + error.body.message, 'error');
                });
        });
    }

    handlePictureClick(event) {
        this.iscontactObj = false;
        if (this.contactObj.idField) {
            this.pictureHandler = true;
            this.showLandDetailsForm = false;
            this.showOrderDetailsForm = false;
            this.showHarvestDetailsForm = false;
            this.showSearch = false;
            this.showHandlerVisitNotes = false;
            this.showMapDetails = false;
        }
    }

    @track contactObj = {
        idField: "",
        nameField: "",
        phoneField: "",
        emailField: null
    };

    contactColumns = [
        { label: 'Farmer Name', fieldName: 'Name', type: 'text', editable: true },
        { label: 'Phone', fieldName: 'Phone', type: 'phone', editable: true },
        { label: 'Email', fieldName: 'Email', type: 'email', editable: true }
    ];

    handleSearchChange(event) {
        const searchTerm = event.target.value;
        if (searchTerm.length > 2) {
            search({ searchTerm: searchTerm })
                .then(result => {
                    this.contactDetails = result.contacts;
                    this.error = undefined;
                })
                .catch(error => {
                    this.error = error;
                });
        } else {
            this.contactDetails = undefined;
        }
    }

    handleSave(event) {
        const updatedFields = event.detail.draftValues;
        updateContacts({ data: updatedFields })
            .then(result => {
                this.draftValues = [];
                this.showToast('Success', 'Records updated successfully', 'success');
            })
            .catch(error => {
                this.error = error;
                this.showToast('Error', 'An error occurred while updating the records', 'error');
            });
    }

    handleCellChange(event) {
        const updatedFields = event.detail.draftValues;
        this.draftValues = updatedFields;
        this.handleSave(event); // Automatically save changes
    }

    handleRowSelection(event) {
        const selectedRow = event.detail.selectedRows[0];
        this.contactObj.idField = selectedRow.Id;
        this.contactObj.nameField = selectedRow.Name;
        this.contactObj.phoneField = selectedRow.Phone;
        this.contactObj.emailField = selectedRow.Email;

        // Close the contact table and open the detail contact page
        this.contactDetailsForm = false;
        this.iscontactObj = true;
        this.showLandDetailsForm = false;
        this.showOrderDetailsForm = false;
        this.showHarvestDetailsForm = false;
        this.tabsHandler = true;
        this.showSearch = false;
    }

    handleFieldChange(event) {
        const fieldName = event.target.dataset.field;
        const value = event.target.value;
        this.editedFields = { ...this.editedFields, [fieldName]: value };
    }

    handleBack(event) {
        this.contactDetailsForm = true;
        this.iscontactObj = false;
        this.showLandDetailsForm = false;
        this.showOrderDetailsForm = false;
        this.showHarvestDetailsForm = false;
        this.tabsHandler = false;
        this.showMapDetails = false;
        window.location.reload();
    }

    handleMain() {
        this.iscontactObj = true;
        this.isModalOpen = true;
        this.showLandDetailsForm = false;
        this.showOrderDetailsForm = false;
        this.showHarvestDetailsForm = false;
        this.tabsHandler = true;
        this.pictureHandler = false;
        this.showMapDetails = false;
    }

    handleLandDetails(event) {
        this.iscontactObj = false;
        if (this.contactObj.idField) {
            this.showLandDetailsForm = true;
            this.showOrderDetailsForm = false;
            this.showHarvestDetailsForm = false;
            this.tabsHandler = true;
            this.showSearch = false;
            this.pictureHandler = false;
            this.showMapDetails = false;
        }
    }

    handleHarvestDetails(event) {
        this.iscontactObj = false;
        if (this.contactObj.idField) {
            this.showLandDetailsForm = false;
            this.showOrderDetailsForm = false;
            this.showHarvestDetailsForm = true;
            this.tabsHandler = true;
            this.showSearch = false;
            this.pictureHandler = false;
            this.showMapDetails = false;
        }
    }

    handleOrderChange(event) {
        this.iscontactObj = false;
        if (this.contactObj.idField) {
            this.showOrderDetailsForm = true;
            this.showLandDetailsForm = false;
            this.showHarvestDetailsForm = false;
            this.tabsHandler = true;
            this.showSearch = false;
            this.pictureHandler = false;
            this.showMapDetails = false;
        }
    }

    handleVisitNotesClick() {
        this.iscontactObj = false;
        if (this.contactObj.idField) {
            this.showHandlerVisitNotes = true;
            this.contactDetailsForm = false;
            this.showOrderDetailsForm = false;
            this.showLandDetailsForm = false;
            this.showHarvestDetailsForm = false;
            this.tabsHandler = true;
            this.showSearch = false;
            this.pictureHandler = false;
            this.showMapDetails = false;
        }
    }

    handleContactNameChange(event) {
        this.contactName = event.target.value;
    }

    handleVisitNameChange(event) {
        this.visitName = event.target.value;
    }

    handleVisitNotesChange(event) {
        this.visitNotes = event.target.value;
    }

     handleVisitSave() {
        if (this.selectedContactDetails && this.visitName && this.visitNotes) {
            insertVisitNotes({
                contactId: this.selectedContactDetails.Id,
                visitName: this.visitName,
                visitNotes: this.visitNotes
            })
                .then(() => {
                    this.visitName = '';
                    this.visitNotes = '';
                    this.selectedContactDetails = null;
                    this.showToast('Success', 'Visit notes saved successfully', 'success');
                })
                .catch(error => {
                    this.showToast('Error', 'An error occurred while saving visit notes: ' + error.body.message, 'error');
                });
        } else {
            this.showToast('Error', 'Please select a contact and fill in all fields', 'error');
        }
    }
    handleMapClick(event) {
        this.iscontactObj = false;
        if (this.contactObj.idField) {
          
            this.showMapDetails = true;
            this.showHandlerVisitNotes = false;
            this.tabsHandler = true;
            this.showLandDetailsForm = false;
            this.showOrderDetailsForm = false;
            this.showSearch = false;
            this.pictureHandler = false;
           
        }
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }
}