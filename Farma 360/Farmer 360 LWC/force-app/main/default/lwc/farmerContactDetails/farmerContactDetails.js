import { refreshApex } from '@salesforce/apex';
import search from '@salesforce/apex/AccountSearchController.search';
import { LightningElement, track } from 'lwc';
// import updateContacts from '@salesforce/apex/AccountSearchController.updateContacts';
import uploadFile from '@salesforce/apex/AccountSearchController.uploadFile'; // Import the uploadFile method
// import insertVisitNotes from '@salesforce/apex/AccountSearchController.insertVisitNotes';
import getRecentContacts from '@salesforce/apex/AccountSearchController.getRecentContacts';
import Icons from '@salesforce/resourceUrl/farmer360';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class FarmerContactDetails extends LightningElement {

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
    @track pictureHandler = false
    @track showMapDetails = false;
    @track showSearch = true;
    @track contactId;
    @track showHandlerVisitNotes = false;
    @track visitNotes = '';
    @track visitName = '';
  //  @track acceptedFormats = ['.jpg', '.jpeg', '.png'];
    @track draftValues = [];
    @track contactName = '';
 //   @api acceptedFormats;
   // @api myRecordId;
    fileData;
   @track handlSearchFunction = 'true';
//==============================File Uploaded======================================
   /* openfileUpload(event) {
        const file = event.target.files[0]
        var reader = new FileReader()
        reader.onload = () => {
            var base64 = reader.result.split(',')[1]
            this.fileData = {
                'filename': file.name,
                'base64': base64,
                'recordId': this.recordId
            }
            console.log(this.fileData)
        }
        reader.readAsDataURL(file)
    }*/
    
    get acceptedFormats() {
        return ['.xlsx', '.xls', '.csv', '.png', '.doc', '.docx', '.pdf', '.jpg'];
    }

   async handleUploadFinished(event) {
        const uploadedFiles = event.detail.files;
        const file = uploadedFiles[0]; // Assuming only one file is uploaded
        console.log('file=> '+file+' selectedId=> '+this.selectedContactDetails)
        if (file && this.selectedContactDetails) {
            const { name } = file;
            
            try {
                // Convert the file to base64
                const base64 = await this.readFileAsBase64(file);
                
                // Call the Apex method to upload the file
                const result = await uploadFile({ base64, filename: name, contactId: this.selectedContactDetails });

                // Handle successful upload
                this.showToast(`${name} uploaded successfully for contact: ${this.selectedContactDetails}`, 'success');
            } catch (error) {
                // Handle upload error
                console.error('Error uploading file:', error);
                this.showToast('Error', 'An error occurred while uploading the file', 'error');
            }
        } else {
            // Handle missing file or contact
            this.showToast('Error', 'Please select a contact and choose a file to upload', 'error');
        }
    }
    

    // Utility method to show toast messages
    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(event);
    }

    // Utility method to convert file to base64
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

  /*  handleUploadFinished(event) { 
        const uploadedFiles = event.detail.files;
        console.log('No. of files uploaded : ' + uploadedFiles.length);

    }*/
//==============================File Uploaded======================================
    handlePictureClick(event) {
        this.iscontactObj = false;
        if (this.contactObj.idField) {
            this.pictureHandler = true;
            this.showLandDetailsForm = false;
            this.showOrderDetailsForm = false;
            this.showHarvestDetailsForm = false;
            this.showSearch = false;
            this.showHandlerVisitNotes = false;
            this.handlSearchFunction = false;

           
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
        { label: 'Email', fieldName: 'Email', type: 'email', editable: true, }
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
        this.showSearch = true; 
    }
}

connectedCallback() {
    this.fetchRecentContacts();
}

fetchRecentContacts() {
    getRecentContacts()
        .then(result => {
            this.contactDetails = result;
            this.allContacts = result; 
        })
        .catch(error => {
            this.error = error;
        });
}
    
    											   

handleSave() {
    const updatedFields = this.draftValues;
    updateContacts({ contactsToUpdate: updatedFields })
        .then(result => {
            console.log('result=> ' + JSON.stringify(result));
            this.draftValues = [];
            this.showToast('Success', 'Records updated successfully', 'success');

            // Update contactDetails array with the updated data
														   
            this.contactDetails = this.contactDetails.map(contact => {
                const updatedContact = result.find(updated => updated.Id === contact.Id);
                if (updatedContact) {
                    return { ...contact, ...updatedContact };
                }
                return contact;
            });

            // Reset draftValues and refreshApex
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

    ContactId ;

    handleCardClick(event) {
        this.ContactId = event.currentTarget.dataset.id;
        const selectedId = event.currentTarget.dataset.id;
        console.log('ID>>>>>', selectedId);
        const selectedContact = this.contactDetails.find(contact => contact.Id === selectedId);
    
        if (selectedContact) {
            this.selectedContactDetails = selectedContact.Id;
            console.log('RowId=> ' + this.selectedContactDetails);
            this.contactObj.idField = selectedContact.Id;
            this.contactObj.nameField = selectedContact.Name;
            this.contactObj.phoneField = selectedContact.Phone;
            this.contactObj.emailField = selectedContact.Email;
        }
        this.contactDetailsForm = false;
        this.iscontactObj = true;
        this.showLandDetailsForm = false;
        this.showOrderDetailsForm = false;
        this.showHarvestDetailsForm = false;
        this.tabsHandler = true;
        this.showSearch = false;
        this.handlSearchFunction = false;

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
        this.handlSearchFunction = false;

    }

    handleFieldChange(event) {
        const fieldName = event.target.dataset.field;
        const value = event.target.value;
        this.editedFields = { ...this.editedFields, [fieldName]: value };
    }

    handleBack(event) {
        location.reload();
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
        this.showHandlerVisitNotes=false;
        this.handlSearchFunction = false;

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
            this.handlSearchFunction = false;
            

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
            this.handlSearchFunction = false;

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
            this.showHandlerVisitNotes=false;
            //this.handlSearchFunction = false;

        }
    }

    handleVisitNotesClick() {
        console.log('Visit notes called');
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
            this.handlSearchFunction = false;

        }
    }

    handleVisitNameChange(event) {
        this.visitName = event.target.value;
    }

    handleVisitChange(event) {
        this.visitNotes = event.target.value;
    }

    handleContactChange(event) {
        this.contactName = event.target.value;
    }

    handleVisitSave() {
        this.iscontactObj = true;
        this.showHandlerVisitNotes = false;
        this.contactDetailsForm = false;
        this.showOrderDetailsForm = false;
        this.showLandDetailsForm = false;
        this.showHarvestDetailsForm = false;
        this.tabsHandler = true;
        this.showSearch = false;
        this.pictureHandler = false;
        this.handlSearchFunction = false;

        const visitNote = {
            Contact__c: this.contactObj.idField,
            Notes__c: this.visitNotes,
            Name: this.visitName
        };

        insertVisitNotes({ visitNote: visitNote })
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
            this.handlSearchFunction = false;

           
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
        { id: 1, label: 'Main', logoUrl: this.visit, className: 'tags-selected', selected: true },
        { id: 2, label: 'Land Details', logoUrl: this.land, className: 'tags-unselected', selected: false },
        { id: 3, label: 'Order Details', logoUrl: this.order, className: 'tags-unselected', selected: false },
        { id: 4, label: 'Reports', logoUrl: this.report, className: 'tags-unselected', selected: false },
        { id: 5, label: 'Visit', logoUrl: this.visit, className: 'tags-unselected', selected: false },
        { id: 6, label: 'Map', logoUrl: this.map, className: 'tags-unselected', selected: false }
        // { id: 7, label: 'Visit Notes', logoUrl: this.notes, className: 'tags-unselected', selected: false },
        // { id: 8, label: 'Picture', logoUrl: this.picture, className: 'tags-unselected', selected: false }
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