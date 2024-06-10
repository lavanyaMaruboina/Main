import { LightningElement, track, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import search from '@salesforce/apex/AccountSearchController.search';
import getRecentContacts from '@salesforce/apex/AccountSearchController.getRecentContacts';
import updateContacts from '@salesforce/apex/AccountSearchController.updateContacts';
import uploadFile from '@salesforce/apex/AccountSearchController.uploadFile';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import Icons from '@salesforce/resourceUrl/farmer360';

export default class Tab extends LightningElement {
    @track contactDetails = [];
    @track error;
    @track isModalOpen = false;
    @track selectedContactDetails;
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
    @track contactId;
    @track showHandlerVisitNotes = false;
    @track visitNotes = '';
    @track visitName = '';
    @track actualStartTime;
    @track actualEndTime;
    @track showHandlerVisitNotes = true; 
    @track draftValues = [];
    @track contactName = '';
    @track showVisitDetails = false;
    

    fileData;

    get acceptedFormats() {
        return ['.xlsx', '.xls', '.csv', '.png', '.doc', '.docx', '.pdf', '.jpg'];
    }

    async handleUploadFinished(event) {
        const uploadedFiles = event.detail.files;
        const file = uploadedFiles[0];
        if (file && this.selectedContactDetails) {
            const { name } = file;
            try {
                const base64 = await this.readFileAsBase64(file);
                const result = await uploadFile({ base64, filename: name, contactId: this.selectedContactDetails });
                this.showToast(`${name} uploaded successfully for contact: ${this.selectedContactDetails}`, 'success');
            } catch (error) {
                this.showToast('Error', 'An error occurred while uploading the file', 'error');
            }
        } else {
            this.showToast('Error', 'Please select a contact and choose a file to upload', 'error');
        }
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(event);
    }

    readFileAsBase64(file) {
        return new Promise((resolve, reject) => {
            const reader = new FileReader();
            reader.onload = () => {
                const base64 = reader.result.split(',')[1];
                resolve(base64);
            };
            reader.onerror = error => reject(error);
            reader.readAsDataURL(file);
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
            this.showVisitDetails = false;
        }
        this.pictureHandler = true;
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
                      this.showSearch = false;
                })
                .catch(error => {
                    this.error = error;
                });
        } else {
            this.fetchRecentContacts();
            this.showSearch = true; // Fetch all contacts when search term is cleared or less than 3 characters
        }
    }

    connectedCallback() {
        this.fetchRecentContacts();
    }

    fetchRecentContacts() {
        getRecentContacts()
            .then(result => {
                this.contactDetails = result;
                this.allContacts = result; // Store all contacts for use when search term is cleared
            })
            .catch(error => {
                this.error = error;
            });
    }

    handleSave() {
        const updatedFields = this.draftValues;
        updateContacts({ contactsToUpdate: updatedFields })
            .then(result => {
                this.draftValues = [];
                this.showToast('Success', 'Records updated successfully', 'success');
                this.contactDetails = this.contactDetails.map(contact => {
                    const updatedContact = result.find(updated => updated.Id === contact.Id);
                    if (updatedContact) {
                        return { ...contact, ...updatedContact };
                    }
                    return contact;
                });
                this.draftValues = [];
                refreshApex(this.contactDetails);
            })
            .catch(error => {
                this.error = error;
                this.showToast('Error', 'An error occurred while updating the records', 'error');
            });
    }

    handleCellChange(event) {
        const updatedFields = event.detail.draftValues;
        this.draftValues = [...updatedFields];
    }

    handleCardClick(event) {
        const selectedRow = event.currentTarget.dataset.id;
        console.log('ID>>>>>', event.currentTarget.dataset.id);
        this.selectedContactDetails = selectedRow.Id;
        console.log('RowId=> '+this.selectedContactDetails);
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
        this.showVisitDetails =false;
    }

    handleRowSelection(event) {
        const selectedRow = event.detail.selectedRows[0];
        this.selectedContactDetails = selectedRow.Id;
        console.log('RowId=> '+this.selectedContactDetails);
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
       this.showVisitDetails = false;
    }

    handleMain() {
        console.log('main called');
        this.iscontactObj = true;
        this.isModalOpen = true;
        this.showLandDetailsForm = false;
        this.showOrderDetailsForm = false;
        this.showHarvestDetailsForm = false;
        this.tabsHandler = true;
        this.pictureHandler = false;
        this.showMapDetails = false;
        this.showVisitDetails =false;
    }

    handleLandDetails(event) {
        console.log('details called');
            this.iscontactObj = false;
        if (this.contactObj.idField) {
            this.showLandDetailsForm = true;
            this.showOrderDetailsForm = false;
            this.showHarvestDetailsForm = false;
            this.tabsHandler = true;
            this.showSearch = false;
            this.pictureHandler = false;
            this.showMapDetails = false;
            this.showHandlerVisitNotes = false;
        }
    }

    handleHarvestDetails(event) {
        console.log('Harvest details called');
        this.iscontactObj = false;
        if (this.contactObj.idField) {
            this.showLandDetailsForm = false;
            this.showOrderDetailsForm = false;
            this.showHarvestDetailsForm = true;
            this.tabsHandler = true;
            this.showSearch = false;
            this.pictureHandler = false;
            this.showMapDetails = false;
            this.showVisitDetails =false;
        }
    }

    handleOrderChange(event) {
        console.log('Order change called');
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
        console.log('Visit notes called');
        this.iscontactObj = false;
        if (this.contactObj.idField) {
            this.showVisitDetails = true;
            this.contactDetailsForm = false;
            //this.showHandlerVisitNotes = true;
             this.contactDetailsForm = false;
            this.showOrderDetailsForm  = false;
            this.showLandDetailsForm = false;
            this.showHarvestDetailsForm = false;
            this.tabsHandler = true;
            this.showSearch = false;
            this.pictureHandler = false;
            this.showMapDetails = false;
        }
    }

    handleVisitNameChange(event) {
        this.visitName = event.target.value;
    }

    handleVisitNoteChange(event) {
        this.visitNotes = event.target.value;
    }

    handleActualStartTimeChange(event) {
        this.actualStartTime = event.target.value;
    }

    handleActualEndTimeChange(event) {
        this.actualEndTime = event.target.value;
    }

    handleVisitSave() {
          //const VisitorID = this.contactObj.idField;
        this.iscontactObj = true;
        this.showHandlerVisitNotes = false;
        this.contactDetailsForm = false;
        this.showOrderDetailsForm = false;
        this.showLandDetailsForm = false;
        this.showHarvestDetailsForm = false;
        this.tabsHandler = true;
        this.showSearch = false;
        this.pictureHandler = false;
        const visitNote = {
            VisitorId: this.contactObj.idField,
            Notes__c: this.visitNotes,
            Name: this.visitName,
            actualStartTime: this.actualStartTime,
            actualEndTime: this.actualEndTime
        };

        insertVisitNotes({contactId: contactId, 
            visitName: this.visitName, 
            visitNotes: this.visitNotes,
            actualStartTime: this.actualStartTime,
            actualEndTime: this.actualEndTime})
            .then(() => {
                this.visitNotes = '';
                this.visitName = '';
                this.showToast('Success', 'Visit notes saved successfully', 'success');
            })
            .catch(error => {
                this.showToast('Error', 'An error occurred while saving visit notes', 'error');
            });
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
            this.showVisitDetails = false;
           
        }
    }

showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(event);
    }
 
  land = Icons + '/farmer360/KipiIcons/HomePage/land.png';
  map = Icons + '/farmer360/KipiIcons/HomePage/map.png';
  order = Icons + '/farmer360/KipiIcons/HomePage/order.png';
  picture = Icons + '/farmer360/KipiIcons/HomePage/picture.png';
  notes = Icons + '/farmer360/KipiIcons/HomePage/notes.png';
  filter = Icons + '/farmer360/KipiIcons/HomePage/filter.png';
  report = Icons + '/farmer360/KipiIcons/HomePage/report.png';
  visit = Icons + '/farmer360/KipiIcons/HomePage/visit.png';

      @track tabs = [
        { id: 1, label: 'Main', logoUrl: this.main, className: 'tags-unselected', selected: false },
        { id: 2, label: 'Land Details', logoUrl: this.land, className: 'tags-unselected', selected: false },
        { id: 3, label: 'Order Details', logoUrl: this.order, className: 'tags-unselected', selected: false },
        { id: 4, label: 'Reports', logoUrl: this.report, className: 'tags-unselected', selected: false },
        { id: 5, label: 'Visit', logoUrl: this.visit, className: 'tags-unselected', selected: false },
        { id: 6, label: 'Map', logoUrl: this.map, className: 'tags-unselected', selected: false },
        { id: 7, label: 'Visit Notes', logoUrl: this.notes, className: 'tags-unselected', selected: false },
        { id: 8, label: 'Picture', logoUrl: this.picture, className: 'tags-unselected', selected: false }
    ];

    toggleTagOptionsSelection(event) {
        const label = event.currentTarget.dataset.label;

        this.tabs = this.tabs.map(tab => {
            if (tab.label === label) {
                return {
                    ...tab,
                    selected: true,
                    className: 'tags-selected'
                };
            }
            return {
                ...tab,
                selected: false,
                className: 'tags-unselected'
            };
        });

        console.log('Updated Tabs:', JSON.stringify(this.tabs));
    }
    handleSearchContacts(event) {
    const searchTerm = event.target.value;
    if (searchTerm.length > 2) {
        searchContacts({ searchKey: searchTerm })
            .then(result => {
                this.contactDetails = result;
                this.error = undefined;
            })
            .catch(error => {
                this.error = error;
                this.contactDetails = []; // Clear contact details on error
            });
    } else {
        // Fetch recent contacts if search term is cleared or less than 3 characters
        this.fetchRecentContacts();
    }
}

    handleTabClick(event) {
        const label = event.currentTarget.dataset.label;
        this.toggleTagOptionsSelection(event);

        switch (label) {
            case 'Main':
                this.handleMain(event);
                break;
            case 'Land Details':
                this.handleLandDetails(event);
                break;
            case 'Order Details':
                this.handleOrderChange(event);
                break;
            case 'Visit':
                this.handleVisitNotesClick(event);
                break;
            case 'Reports':
                this.handleReportClick(event);
                break;
            case 'Map':
                this.handleMapClick(event);
                break;
            case 'Picture':
                this.handlePictureClick(event);
                break;
            default:
                break;
        }
    }
}