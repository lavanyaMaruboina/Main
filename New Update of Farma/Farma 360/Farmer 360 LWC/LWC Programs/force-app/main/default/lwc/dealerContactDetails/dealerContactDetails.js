import search from '@salesforce/apex/AccountSearchController.searchDealer';
import updateContacts from '@salesforce/apex/AccountSearchController.updateDealerContact';
import uploadFile from '@salesforce/apex/AccountSearchController.uploadFile'; // Import the uploadFile method
import { LightningElement, api, track, wire } from 'lwc';
// import insertVisitNotes from '@salesforce/apex/AccountSearchController.insertVisitNotes';
import getFilesList from '@salesforce/apex/AccountSearchController.getFilesAccountList';
import getRecentAccounts from '@salesforce/apex/FetchAccountsData.getRecentAccounts';
import getUserCreatedDealers from '@salesforce/apex/AccountSearchController.getUserCreatedDealers';
import Icons from '@salesforce/resourceUrl/farmer360';
import userId from '@salesforce/user/Id';
import LightningAlert from 'lightning/alert';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';



export default class DealerContactDetails extends LightningElement {

    @track dealerDetails = [];
    @track usercreatedDealers = [];
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
    @track DealerDetailsList = {};
    @api accountId;
    selectedAccountRecord = false;
 //   @api acceptedFormats;
   // @api myRecordId;
    fileData;
   @track handlSearchFunction = 'true';
   filesList =[]
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
        avatar = Icons + '/farmer360/KipiIcons/HomePage/avatar.png';
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
    @wire(getFilesList, { accountId: '$accountId' })
    wiredFiles({ error, data }) {
        if (data) {
            this.filesList = data.map(file => ({
                id: file.contentDocumentId,
                title: file.title,
                fileExtension: file.fileExtension,
                imageUrl: 'data:image/' + file.fileExtension + ';base64,' + file.versionData
            }));
            console.log('Images 128=====>',JSON.stringify(this.filesList));
            this.dealerDetails = this.dealerDetails.map(account => {
                const file = this.filesList.find(f => f.contentDocumentId === account.Id);
                return {
                    ...account,
                    imageUrl: file ? file.imageUrl : null
                };
            });
        } else if (error) {
            
            console.error('Error fetching files:', error);
        }
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
            this.selectedAccountRecord = false;

           
    }
    this.pictureHandler = true;
}



 @track contactObj = {
        idField: "",
        nameField: "",
        phoneField: "",
        ContactPhone: "",
        ContactName: "",
        shippingStreetField : "",
        shippingCityField : "",
        shippingStateField : "",
        shippingPostalCodeField : "",
        shippingCountryField : "",
        emailField: null
    };

    contactColumns = [
        { label: 'Farmer Name', fieldName: 'Name', type: 'text', editable: true },
        { label: 'Phone', fieldName: 'Phone', type: 'phone', editable: true },
        { label: 'Email', fieldName: 'Email', type: 'email', editable: true },
        { label: 'Primary Contact Name', fieldName: 'ContactName', type: 'text', editable: true },
        { label: 'Primary Contact Phone', fieldName: 'ContactPhone', type: 'phone', editable: true, }
    ];


//      handleSearchChange(event) {   
     
//     const searchTerm = event.target.value;
   
//     if (searchTerm.length > 2) {
//         search({ searchTerm: searchTerm })
//             .then(result => {
//                 this.dealerDetails = result.accounts;
//                 this.error = undefined;
//                 this.showSearch = false;
                
//             })
//             .catch(error => {
//                 this.error = error;
//             });
//     } else {
//         this.fetchRecentContacts();
//         this.showSearch = true; 
//     }
// }

connectedCallback() {
    this.fetchRecentContacts();
    console.log('Componenet Loaded');
    this.getUserId(userId);
}

handleSearchChange(event) {
    const searchTerm = event.target.value.toLowerCase();

    if (searchTerm.length > 2) {
        this.filterAccounts(searchTerm);
        this.showSearch = false;
    } else {
        this.dealerDetails = [...this.allAccount];
        this.showSearch = true;
    }
}

filterAccounts(searchTerm) {
    this.dealerDetails = this.allAccount.filter(account => {
        return account.Name.toLowerCase().includes(searchTerm);
    });
}

fetchRecentContacts() {
    getRecentAccounts()
        .then(result => {
            this.dealerDetails = result.map(wrapper => {
                return {
                    ...wrapper.account,
                    imageUrl: wrapper.attachmentUrl
                };
            });
            this.allAccount = [...this.dealerDetails];
            console.log('All dealers >>>', JSON.stringify(this.dealerDetails));
            this.error = undefined;
        })
        .catch(error => {
            this.error = error;
            console.error('Error fetching accounts:', error);
        });
}

getUserId(){
    console.log('user id : ', userId);
    getUserCreatedDealers({userId: userId})
    .then(result => {
        console.log('result=> ' + JSON.stringify(result.length));
        this.usercreatedfarmers = result.length;
        console.log('user created dealers: ',this.usercreatedfarmers);
    })
    .catch(error => {
        this.error = error;
    });
}

handleInputChange(event) {
    const field = event.target.dataset.field;
    this.contactObj = { ...this.contactObj, [field]: event.target.value };
    console.log('This is all data: >>>', JSON.stringify(this.contactObj));
}

handleUpdatesave() {
    const recordId = this.accountId;
   
    console.log('recordId Lavanya 195===> ' + recordId);

    const updatedContact = {
        Id: recordId,
        Name: this.contactObj.nameField,
        Phone: this.contactObj.phoneField,
        Primary_Contact_Name__c: this.contactObj.ContactName,
        Primary_Contact_Phone__c: this.contactObj.ContactPhone,
        Email__c: this.contactObj.emailField,
        ShippingStreet: this.contactObj.shippingStreetField,
        ShippingCity: this.contactObj.shippingCityField,
        ShippingPostalCode: this.contactObj.shippingPostalCodeField,
        
    };
    console.log('updatedContact Lavanya 203  ===> ' + JSON.stringify(updatedContact));
    const fieldsToUpdate = {
        Id: recordId,
        Name: updatedContact.Name,
        Phone: updatedContact.Phone,
        Primary_Contact_Name__c: updatedContact.ContactName,
        Primary_Contact_Phone__c: updatedContact.ContactPhone,
        Email__c: updatedContact.Email__c,
        ShippingStreet: updatedContact.shippingStreetField,
        ShippingCity: updatedContact.shippingCityField,
        ShippingPostalCode: updatedContact.shippingPostalCodeField,
    };

    updateContacts({ id: recordId, DealerDetailsList: fieldsToUpdate })
        .then(result => {
            console.log('result=> ' + JSON.stringify(result));
            //this.iscontactObj = true;
            
            //this.showToast('Success', 'Records updated successfully', 'success');
            //alert('Records updated successfully');
            this.showSuccessAlertUpdate();
            this.selectedAccountRecord=false;
            this.iscontactObj = true;
            this.showLandDetailsForm = false;
            this.showOrderDetailsForm = false;
            this.showHarvestDetailsForm = false;
            this.tabsHandler = true;
            this.pictureHandler = false;
            this.showMapDetails = false;
            this.showHandlerVisitNotes=false;
            this.handlSearchFunction = false;
            
           
            this.dealerDetails = this.dealerDetails.map(account => {
                if (account.Id === recordId) {
                    return { ...account, ...updatedContact };
                }
                return account;
            });
        })
        .catch(error => {
            console.error(error);
            this.showErrorAlert();
            //this.showToast('Error', 'An error occurred while updating the records', 'error');
        });
    }
    handleUpdate(){
        this.selectedAccountRecord=true;
        this.iscontactObj = false;
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
    backToDealerDetails(){
        this.selectedAccountRecord=false;
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



     handleCellChange(event) {
        const updatedFields = event.detail.draftValues;
        this.contactObj = [...updatedFields];
    }

    ContactId ;

    handleCardClick(event) {
        this.ContactId = event.currentTarget.dataset.id;
        const selectedId = event.currentTarget.dataset.id;
        this.accountId = selectedId;

        console.log('ID>>>>>', selectedId);
       
        const selectedContact = this.dealerDetails.find(account => account.Id === selectedId);
    
        if (selectedContact) {
            this.selectedContactDetails = selectedContact.Id;
            console.log('RowId=> ' + this.selectedContactDetails);
            this.contactObj.idField = selectedContact.Id;
            this.contactObj.nameField = selectedContact.Name;
            this.contactObj.phoneField = selectedContact.Phone;
            this.contactObj.emailField = selectedContact.Email__c;
            this.contactObj.ContactName = selectedContact.Primary_Contact_Name__c;
            this.contactObj.ContactPhone = selectedContact.Primary_Contact_Phone__c;
            this.contactObj.shippingStreetField = selectedContact.ShippingStreet;
            this.contactObj.shippingCityField = selectedContact.ShippingCity;
            this.contactObj.shippingStateField = selectedContact.ShippingState;
            this.contactObj.shippingPostalCodeField = selectedContact.ShippingPostalCode;
            this.contactObj.shippingCountryField = selectedContact.ShippingCountry;
            console.log('This is all data >>>', JSON.stringify(this.contactObj));
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
        this.contactObj.ContactName = selectedRow.Primary_Contact_Name__c;
        this.contactObj.ContactPhone = selectedRow.Primary_Contact_Phone__c;
        this.contactObj.shippingStreetField = selectedRow.ShippingStreet;
        this.contactObj.shippingCityField = selectedRow.ShippingCity;
        this.contactObj.shippingStateField = selectedRow.ShippingState;
        this.contactObj.shippingPostalCodeField = selectedRow.ShippingPostalCode;
        this.contactObj.shippingCountryField = selectedRow.ShippingCountry;

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
        this.selectedAccountRecord = false;

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
            this.selectedAccountRecord = false;
            

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
            this.selectedAccountRecord=false;

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
            this.selectedAccountRecord = false;
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
            this.selectedAccountRecord = false;

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
        { id: 5, label: 'Visit', logoUrl: this.visit, className: 'tags-unselected', selected: false },
        // { id: 2, label: 'Land Details', logoUrl: this.land, className: 'tags-unselected', selected: false },
        { id: 3, label: 'Order', logoUrl: this.order, className: 'tags-unselected', selected: false },
        { id: 4, label: 'Report', logoUrl: this.report, className: 'tags-unselected', selected: false },
        
        // { id: 6, label: 'Map', logoUrl: this.map, className: 'tags-unselected', selected: false }
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
            // case 'Land Details':
            //     this.handleLandDetails(event);
            //     break;
            case 'Order':
                this.handleOrderChange(event);
                break;
            case 'Visit':
                this.handleVisitNotesClick(event);
                break;
            // case 'Reports':
            //     this.handleReportClick(event);
            //     break;
            case 'Report':
                this.handleMapClick(event);
                break;
            // case 'Picture':
            //     this.handlePictureClick(event);
            //     break;
            default:
                break;
        }

    }
  
    showErrorAlert(headerLabel, bodyMessage) {
        LightningAlert.open({
            message: bodyMessage,
            theme: 'error',
            label: headerLabel,
        });
    }

    showSuccessAlertUpdate() {
        LightningAlert.open({
            message: 'Dealer has been Updated successfully',
            theme: 'Success',
            label: 'Success',
        });
    }
}