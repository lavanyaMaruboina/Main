import uploadFile from '@salesforce/apex/AccountSearchController.getFilesList'; // Import the uploadFile method
import search from '@salesforce/apex/AccountSearchController.search';
import updateContactDetails from '@salesforce/apex/AccountSearchController.updateContactDetails';
import { LightningElement, api, track, wire } from 'lwc';
// import insertVisitNotes from '@salesforce/apex/AccountSearchController.insertVisitNotes';
import getFilesList from '@salesforce/apex/AccountSearchController.getFilesList';
import getRecentContacts from '@salesforce/apex/AccountSearchController.getRecentContacts';
import getUserCreatedFarmers from '@salesforce/apex/AccountSearchController.getUserCreatedFarmers';
import Icons from '@salesforce/resourceUrl/farmer360';
import userId from '@salesforce/user/Id';
import LightningAlert from 'lightning/alert';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class FarmerContactDetails extends NavigationMixin(LightningElement) {

    @track contactDetails = [];
    @track usercreatedfarmers = [];
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
    @track userId = userId;
    @track originalpan;
    @track originalDOB;
  //  @track acceptedFormats = ['.jpg', '.jpeg', '.png'];
    @track draftValues = [];
    @track contactName = '';
    @api contactId;
 //   @api acceptedFormats;

   @track handlSearchFunction = 'true';
   @track SelectContactUpdate=false;
   @api recordId='003QH000004fpSTYAY'
   filesList =[]
    //filesList =[{ contentDocumentId: '1', url: 'https://farmer360-dev-ed.develop.my.salesforce.com/sfc/p/QH000002VKqv/a/QH0000003cWz/VeVNfw33ukTgD5FKrKYNpbkT9UPI5w.yjdDlApNgcyI' }];
   originalContactId;

  
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
                
                const base64 = await this.readFileAsBase64(file);
                
                const result = await uploadFile({ base64, filename: name, contactId: this.selectedContactDetails });

                this.showToast(`${name} uploaded successfully for contact: ${this.selectedContactDetails}`, 'success');
            } catch (error) {
                
                console.error('Error uploading file:', error);
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
    // @wire(getContactDetails, { contactId: '$recordId' })
    // wiredContactDetails({ error, data }) {
    //     if (data) {
    //         this.contactDetails = data.map(contact => ({
    //             ...contact,
    //            // imageUrl:'data:image/' + file.fileExtension + ';base64,' + file.versionData
    //         }));
    //         console.log('wiredContactDetails  125==>',this.contactDetails);
    //     } else if (error) {
    //         console.error('Error fetching contact details:', error);
    //     }
    // }
 fetchFiles() {
     console.log('++++++++fetchFiles+++++++++');
        getFilesList({ contactId: this.originalContactId })
            .then(data => {
                this.filesList = data.map(file => ({
                    id: file.contentDocumentId,
                    title: file.title,
                    fileExtension: file.fileExtension,
                    imageUrl: 'data:image/' + file.fileExtension + ';base64,' + file.versionData
                }));
                console.log('Images 128=====>', JSON.stringify(this.filesList));
                this.contactDetails = this.contactDetails.map(contact => {
                    const file = this.filesList.find(f => f.contentDocumentId === contact.Id);
                    return {
                        ...contact,
                        imageUrl: file ? file.imageUrl : null
                    };
                });
            })
            .catch(error => {
                console.error('Error fetching files:', error);
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
            this.SelectContactUpdate = false;

           
    }
    this.pictureHandler = true;
}



 @track contactObj = {
        idField: "",
        lastNameField:"",
        firstNameField:"",
        nameField: "",
        phoneField: "",
        aadharNumber: "",
        panCardNumber: "",
        DOB: "",
        farmerType: "",
        subType: "",
        emailField: null,
        originalDOB :null
    };

    contactColumns = [
        { label: 'Farmer Name', fieldName: 'Name', type: 'text', editable: true },
        { label: 'Phone', fieldName: 'Phone', type: 'phone', editable: true },
        //{ label: 'Aadhar Number', fieldName: 'Aadhar_Number__c', type: 'Number', editable: true },
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
        this.getUserId();
        this.showSearch = true; 
    }
}

connectedCallback() {
    this.fetchRecentContacts();
    this.getUserId(userId);
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

getUserId(){
    console.log('user id : ', userId);
    getUserCreatedFarmers({userId: userId})
    .then(result => {
        console.log('result=> ' + JSON.stringify(result.length));
        this.usercreatedfarmers = result.length;
        console.log('user created farmers: ',this.usercreatedfarmers);
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
            this.refreshApexcontact();
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
        this.originalContactId = selectedId;
        const selectedContact = this.contactDetails.find(contact => contact.Id === selectedId);
    
        if (selectedContact) {
            this.selectedContactDetails = selectedContact.Id;
            console.log('RowId=> 258',selectedContact.PAN_Card__c);
            console.log(' after Row selection before callling apexs');
            console.log('Goining to call fetchFiles');
        this.fetchFiles();
            this.originalpan=selectedContact.PAN_Card__c;
            this.originalDOB = selectedContact.DOB__c;
            this.contactObj.originalDOB = selectedContact.DOB__c;
            this.contactObj.idField = selectedContact.Id;
            this.contactObj.nameField = selectedContact.Name;
            this.contactObj.firstNameField = selectedContact.FirstName;
            this.contactObj.lastNameField = selectedContact.LastName;
            this.contactObj.phoneField = selectedContact.Phone;
            this.contactObj.aadharNumber =selectedContact.Aadhar_Number__c;
            //this.contactObj.panCardNumber = selectedContact.PAN_Card__c;
            //this.contactObj.DOB = selectedContact.DOB__c;
            this.contactObj.panCardNumber = selectedContact.PAN_Card__c;
            this.contactObj.DOB = this.formatDate(new Date(selectedContact.DOB__c));
            this.contactObj.farmerType = selectedContact.Type_of_Farmer__c;
            this.contactObj.subType = selectedContact.Sub_Type__c;
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
        this.SelectContactUpdate = false;
        

    }

    handleRowSelection(event) {
        const selectedRow = event.detail.selectedRows[0];
        this.selectedContactDetails = selectedRow.Id;
        console.log('RowId=> '+this.selectedContactDetails);
        this.contactObj.idField = selectedRow.Id;
        //this.contactObj.nameField = selectedRow.Name;
        this.contactObj.firstNameField = selectedRow.FirstName;
        this.contactObj.lastNameField = selectedRow.LastName;
       // this.contactObj.
        this.contactObj.phoneField = selectedRow.Phone;
        this.contactObj.emailField = selectedRow.Email;
        this.contactObj.aadharNumber = selectedRow.Aadhar_Number__c;
       // this.contactObj.panCardNumber = this.formatPAN(selectedRow.PAN_Card__c);
       this.contactObj.panCardNumber = selectedRow.PAN_Card__c;
        this.contactObj.DOB = this.formatDate(new Date(selectedRow.DOB__c));
        //this.contactObj.DOB = selectedRow.DOB__c;
        this.contactObj.farmerType = selectedRow.Type_of_Farmer__c;
        this.contactObj.subType = selectedRow.Sub_Type__c;
    

        // Close the contact table and open the detail contact page
        this.contactDetailsForm = false;
        this.iscontactObj = true;
        this.showLandDetailsForm = false;
        this.showOrderDetailsForm = false;
        this.showHarvestDetailsForm = false;
        this.tabsHandler = true;
        this.showSearch = false;
        this.handlSearchFunction = false;
        this.SelectContactUpdate = false;

    }
    // Date Formate as DD-MM-YYYY
    formatDate(date) {
        let day = date.getDate();
        let month = date.getMonth() + 1; 
        let year = date.getFullYear();
    
        if (day < 10) {
            day = '0' + day;
        }
        if (month < 10) {
            month = '0' + month;
        }
    
        return `${day}-${month}-${year}`;
    }
    // PAN Formate EX-XXXXXXTR34

    formatPAN(pan) {

        let remainingPart = pan.slice(6).toUpperCase();
        let firstPart = "XXXXXX";
        return `${firstPart}${remainingPart}`;
    }
    formatAadhar(aAdhar) {
        
            let firstPart = "XXXXXXXX";
            let remainingPart = aAdhar.slice(-4);
            return `${firstPart}${remainingPart}`;
       
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
        this.SelectContactUpdate = false;

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
            this.SelectContactUpdate = false;
            

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
            this.SelectContactUpdate = false;

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
            this.SelectContactUpdate = false;
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
            this.SelectContactUpdate = false;

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
        this.SelectContactUpdate = false;

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
            this.SelectContactUpdate = false;

           
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
        { id: 2, label: 'Land', logoUrl: this.land, className: 'tags-unselected', selected: false },
        { id: 3, label: 'Prescription', logoUrl: this.order, className: 'tags-unselected', selected: false },
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
            case 'Land':
                this.handleLandDetails(event);
                break;
            case 'Prescription':
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


    //Edit Contact Details

    handleUpdate(){
        this.contactDetailsForm = false;
        this.SelectContactUpdate= true;
        this.iscontactObj = false;
        this.showHandlerVisitNotes = false;
        this.showOrderDetailsForm = false;
        this.showLandDetailsForm = false;
        this.showHarvestDetailsForm = false;
        this.tabsHandler = true;
        this.showSearch = false;
        this.pictureHandler = false;
        this.handlSearchFunction = false;  
        this.contactObj.panCardNumber=this.originalpan;
        this.contactObj.DOB=this.originalDOB;
        //console.log('original pan',this.originalpan);
    }
    backToFarmerDetails(){
        this.contactDetailsForm = false;
        this.SelectContactUpdate= false;
        this.iscontactObj = true;
        this.showHandlerVisitNotes = false;
        this.showOrderDetailsForm = false;
        this.showLandDetailsForm = false;
        this.showHarvestDetailsForm = false;
        this.tabsHandler = true;
        this.showSearch = false;
        this.pictureHandler = false;
        this.handlSearchFunction = false;  
    }
    handleInputChange(event){
      
            const field = event.target.name;
            this.contactObj = { ...this.contactObj, [field]: event.target.value };
            console.log('This is all data >>>', JSON.stringify(this.contactObj));
        }


        handleContactSave() {
            const recordId = this.selectedContactDetails;
           
            console.log('recordId Lavanya 195===> ' + recordId);
        
            const updatedContact = {
                Id: recordId,
                FirstName: this.contactObj.firstNameField,
                LastName: this.contactObj.lastNameField,
                Phone: this.contactObj.phoneField,
                Email: this.contactObj.emailField,
                Aadhar_Number__c: this.contactObj.aadharNumber,
                PAN_Card__c: this.contactObj.panCardNumber,
                DOB__c: this.contactObj.DOB


            };
            console.log('updatedContact Lavanya 203  ===> ' + JSON.stringify(updatedContact));
            const fieldsToUpdate = {
                Id: recordId,
                Name: updatedContact.Name,
                FirstName: updatedContact.FirstName,
                LastName: updatedContact.LastName,
                Phone: updatedContact.Phone,
                Email: updatedContact.Email,
                Aadhar_Number__c: updatedContact.Aadhar_Number__c,
                PAN_Card__c: updatedContact.PAN_Card__c,
                DOB__c: updatedContact.DOB__c

            };
        
            updateContactDetails({ id: recordId, ContactDetailsList: fieldsToUpdate })
                .then(result => {
                    console.log('result=> ' + JSON.stringify(result));
                    //this.iscontactObj = true;
                    
                    //this.showToast('Success', 'Records updated successfully', 'success');
                    //alert('Records updated successfully');
                    this.showSuccessAlertUpdate();
                    console.log('refresh is calling');
                   //this.refreshApexcontact();

                   console.log('refresh is done');

                    this.contactDetailsForm = false;
                    this.SelectContactUpdate= false;
                    this.iscontactObj = true;
                    this.showHandlerVisitNotes = false;
                    this.showOrderDetailsForm = false;
                    this.showLandDetailsForm = false;
                    this.showHarvestDetailsForm = false;
                    this.tabsHandler = true;
                    this.showSearch = false;
                    this.pictureHandler = false;
                    this.handlSearchFunction = false;  
                    console.log('looping');

                    this.contactDetails = this.contactDetails.map(contact => {
                        
                        if (contact.Id === recordId) {
                            return { ...contact, ...updatedContact };
                        }
                        return contact;
                    });

                    console.log('looping done');

                })
                .catch(error => {
                    console.error(error);
                    this.showErrorAlert('Error', 'An error occurred while updating the records');
                    //this.showToast('Error', 'An error occurred while updating the records', 'error');
                });
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
                    message: 'Farmer has been Updated successfully',
                    theme: 'Success',
                    label: 'Success',
                });
            }
            refreshApexcontact(){

                console.log('the thing is rrreshing');

                return refreshApex(this.contactDetails);
            }



    get formattedAadhar() {
        return this.maskNumber(String(this.contactObj.aadharNumber));
    }

    get formattedPanCard() {
        return this.maskNumber(this.contactObj.panCardNumber);
    }

    maskNumber(number) {
        if (!number) {
            return '';
        }
        const length = number.length;
        if (length <= 4) {
            return number;
        }
        const maskedSection = 'X'.repeat(length - 4);
        const visibleSection = number.slice(-4);
        return `${maskedSection}${visibleSection}`;
    }

    
}