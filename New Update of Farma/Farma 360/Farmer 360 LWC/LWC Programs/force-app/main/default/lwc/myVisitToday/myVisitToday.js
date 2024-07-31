import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import { LightningElement, track,api, wire } from 'lwc';
import getMyVisits from '@salesforce/apex/visitContactDetails.getMyVisits';
import updateVisitCancelReason from '@salesforce/apex/visitContactDetails.updateVisitCancelReason';
import editVisit from '@salesforce/apex/visitContactDetails.editVisitDetails'; //edit
import updateVisitExecuteLatLong from '@salesforce/apex/visitContactDetails.updateVisitExecuteLatLong';
import updateVisitCompleteLatLong from '@salesforce/apex/visitContactDetails.updateVisitCompleteLatLong';
import VISIT_Object from '@salesforce/schema/Visit__c';
import Cancel_Field from '@salesforce/schema/Visit__c.Cancel_Reason__c';
import Visit__c from '@salesforce/schema/Visit__c';
import Visit_Location__c from '@salesforce/schema/Visit__c.Visit_Location__c';
import Type_Of_Visit__c from '@salesforce/schema/Visit__c.Type_Of_Visit__c';
import Type_Of_Visit_For_Dealer__c from '@salesforce/schema/Visit__c.Type_Of_Visit_For_Dealer__c';
import createVisit from '@salesforce/apex/VisitController.createVisit';
import searchContacts from '@salesforce/apex/VisitController.searchContacts';
import searchAccount from '@salesforce/apex/VisitController.searchAccount';
import searchContactName from '@salesforce/apex/VisitController.searchContactName';
import LightningAlert from 'lightning/alert';
import fetchVisitDetails from '@salesforce/apex/VisitController.fetchVisitDetails';
import getUserDetails from '@salesforce/apex/userController.getUserDetails';
import Id from "@salesforce/user/Id";
import searchLandDetails from '@salesforce/apex/visitContactDetails.searchLandDetails';
import Icons from '@salesforce/resourceUrl/farmer360';

export default class MyVisitToday extends LightningElement {
    

    @track visits = [];
    @track visits;
    @track error;
    @track executeVisit = false;
    @track showVisitClone = false;
    @track showExecuteModal = false;
    @track showAllViist =true;
    @track showModal = false;
    @track latitude;
    @track longitude;
    @track markerVar = [];
    @track value;
    @track selectedVisitId;
    @track selectedvisit;
    @track showChildComponent = false;
    @track showCloneComponent = false;

    //@api contactId = this.selectedVisitId;

    @track VisitDetails = [];

    @track visitObj = {
        idField:"",
        repName: "",
        visitedParty: "",
        farmerVisitType: "",
        dealerVisitType: "",
        contactId: "",
        accountId: "",
        visitStatus: "",
        vistiDateTime: "",
        selectedLandId:'',
        landName:"",
        htmlVisitValue:""
    }
    @api contactid;

    @track selectedVisitDetails = this.contactid;

    @track visitedPartyValue = 'None';
    @track visitTypeFarmerValue;
    @track visitTypeDealerValue = 'None';
    @track isFarmer = true; //*
    @track isDealer = true; //*
    @track repName;
    @track visitedParty = '';
    @track farmerVisitType = '';
    @track dealerVisitType = '';
    @api contactId;
    @track contactName = '';
    @track dealerName = '';
    @api accountId = '';
    @track visitStatus = 'Planned';
    @track vistiDateTime = '';
    @track contacts = [];
    @track dealers = [];
    @track visitTypeFarmerOptions;
    @track visitTypeDealerOptions;
    @track visitedPartyOptions;
    @track userName;
    cancelPickListOptions=[];

    @track userId = Id;
    savedImageId;
    turnOnCam = false;
    camera = Icons + '/farmer360/KipiIcons/HomePage/camera.png';
    @track isCameraInitialized = false;
    videoElement;
    canvasElement;
    capturedImageData;
    //@track contactName;
    error;
    @track typeOfVisit;
    @track landName = '';
    @track selectedLandId='';
    @track lands = [];
    @track currentDateTime = '';

    
    @wire(getObjectInfo, { objectApiName: Visit__c })
    objectInfo;

    
        @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: Cancel_Field })
    wiredCancelPicklistValues({ data, error }) {
        if (data) {
            console.log('cancelPickListOptions>>>>>'+JSON.stringify(data.values));
            this.cancelPickListOptions = data.values.map(item => {
                return { label: item.label, value: item.value };
            });
        } else if (error) {
            console.error('Error fetching picklist values:', error);
        }
    }

    handleChange(event) {
        this.value = event.detail.value;
        console.log('Selected value:', this.value); // Optional: log the selected value for debugging
    }

    @wire(getMyVisits)
    wiredVisits({ error, data }) {
        if (data) {
            this.visits = data.map(visit => ({
                ...visit,
                FormattedTime: this.formatTimeToIST(visit.Date__c),
                DealerName: visit.Dealer__r ? visit.Dealer__r.Name : '',
                FarmerName: visit.Customer__r ? visit.Customer__r.Name : '',
                tileClass: visit.Customer__r ? 'tile-farmer' : visit.Dealer__r ? 'tile-dealer' : 'tile-visit'
            }));

            console.log('My visits>>', JSON.stringify(this.visits));
            console.log('objectInfo>>>>>>'+JSON.stringify(this.objectInfo));

        } else if (error) {
            console.error(error);
            this.error = error;
        }
    }

    formatTimeToIST(dateStr) {
        let options = { timeZone: 'Asia/Kolkata', hour: '2-digit', minute: '2-digit', second: '2-digit' };
        let date = new Date(dateStr);
        return date.toLocaleTimeString('en-IN', options);
    }

    handleCancelClick(event) {
        this.selectedVisitId = event.target.dataset.id;
        this.showModal = true;
        this.showChildComponent = false;
        this.showCloneComponent = false;
        console.log('Id >>', this.selectedVisitId);
        
        
    }

    handleGetLocation() {
        console.log('I am in');
        if (navigator.geolocation) {
            navigator.geolocation.getCurrentPosition(
                (position) => {
                    this.latitude = position.coords.latitude;
                    this.longitude = position.coords.longitude;
                    this.markerVar = [
                        {
                            location: {
                                Latitude: this.latitude,
                                Longitude: this.longitude
                            },
                            title: 'Current Location',
                            description: `Lat: ${this.latitude}, Long: ${this.longitude}`
                        }
                    ];
                    console.log('Latitude: ', this.latitude);
                    console.log('Longitude: ', this.longitude);
                },
                (error) => {
                    console.error('Error getting location', error);
                    // Handle error accordingly
                }
            );
        } else {
            console.error('Geolocation is not supported by this browser.');
            // Handle error accordingly
        }
    }

    setCurrentDateTime() {
        console.log('I am capturing current date and time here: ');
        const now = new Date();
        
        // Format date and time as yyyy-mm-dd hh:mm:ss : 2024-07-27T10:15:00.000+0000
        const formattedDateTime = now.getFullYear() + '-' 
            + String(now.getMonth() + 1).padStart(2, '0') + '-' 
            + String(now.getDate()).padStart(2, '0') + 'T' 
            + String(now.getHours()).padStart(2, '0') + ':' 
            + String(now.getMinutes()).padStart(2, '0') + ':' 
            + String(now.getSeconds()).padStart(2, '0')+'.000+000';

        this.currentDateTime = formattedDateTime;
        console.log('Capture the Date and Time : ',this.currentDateTime);
    }
    

    handleVisitExecute(event) {
        this.selectedVisitId = event.target.dataset.id;
        this.showAllViist  = true;
        this.showChildComponent = true;
        //this.VisitUpdate = true;
        this.showModal = false;

        console.log('selected visit Id is  >>', this.selectedVisitId);
        this.handleGetLocation();
        this.setCurrentDateTime();
        this.showVisitForm();
        setTimeout(() => {
            this.handlesavelatlong();
        }, 10000);
        //this.handlesavelatlong();
    }
    handleVisitClone(event){
         this.selectedVisitId = event.target.dataset.id;
        this.showAllViist  = false;
        this.showCloneComponent = true;
        //this.VisitUpdate = true;
        this.showModal = false;

        console.log('selected visit Id is  >>', this.selectedVisitId);
        this.handleGetLocation();
        this.showVisitForm();
        setTimeout(() => {
            this.handlesavelatlong();
        }, 10000);
    }

    handlesavelatlong(){
        updateVisitExecuteLatLong({ visitId: this.selectedVisitId, lat: this.latitude, longi: this.longitude })
            .then(() => {
                this.visits = this.visits.map(visit => {
                    if (visit.Id === this.selectedVisitId) {
                        return { ...visit, lat: this.latitude, longi: this.longitude};
                    }
                    return visit;
                });
                console.log('Visit updated successfully');
            })
            .catch(error => {
                this.error = error;
                console.error('Error updating visit:', error);
            });
    }


    handlesaveVisitCompletelatlong(){
        updateVisitCompleteLatLong({ visitId: this.selectedVisitId, lat: this.latitude, longi: this.longitude })
            .then(() => {
                this.visits = this.visits.map(visit => {
                    if (visit.Id === this.selectedVisitId) {
                        return { ...visit, lat: this.latitude, longi: this.longitude};
                        console.log('visit id match with selected visit id', this.selectedVisitId);
                    }
                    return visit;
                });
                console.log('Visit updated successfully');
            })
            .catch(error => {
                this.error = error;
                console.error('Error updating visit:', error);
            });
    }
    
    handleVisitComplete(event) {
        this.selectedVisitId = event.target.dataset.id;
        
        //this.showModal = true;
        console.log('Id >>', this.selectedVisitId);
        this.handleGetLocation();
        this.showVisitForm();
        setTimeout(() => {
            this.handlesaveVisitCompletelatlong();
        }, 10000);
          
    }
    

    handleCloseModal() {
        this.showModal = false;
        this.showExecuteModal = false;
        this.showAllViist = true;
    }

    handleChange(event) {
        this.value = event.detail.value;
    }


    showVisitForm(){
        //this.executeVisit = true;
        this.showAllViist = false;
        //this.showExecuteModal = true;
    }

    //child component data
    @wire(getUserDetails, { userId: '$userId' })
    wiredUser({ error, data }) {
        if (data) {
            this.userName = data.Name;
            console.log('userName=> ' + JSON.stringify(this.userName)); 
        } else if (error) {
            console.error(error);
        }
  }

  @wire(getObjectInfo, { objectApiName: Visit__c })
  visitInfo;

  @wire(getPicklistValues, { recordTypeId: '$visitInfo.data.defaultRecordTypeId', fieldApiName: Visit_Location__c })
  visitedTypeInfo({ data, error }) {
      if (data) this.visitedPartyOptions = data.values;
  }

  @wire(getPicklistValues, { recordTypeId: '$visitInfo.data.defaultRecordTypeId', fieldApiName: Type_Of_Visit__c })
  farmerVisitTypeInfo({ data, error }) {
      if (data) this.visitTypeFarmerOptions = data.values;
  }

  @wire(getPicklistValues, { recordTypeId: '$visitInfo.data.defaultRecordTypeId', fieldApiName: Type_Of_Visit_For_Dealer__c })
  dealerVisitTypeInfo({ data, error }) {
      if (data) this.visitTypeDealerOptions = data.values;
  }

  @wire(searchContactName, { contactId: '$contactId' })
  wiredContact({ data, error }) {
      if (data) {
          //this.contactName = data.Name;
          this.data = data;
          //console.log('type of visit data=> ' ,this.typeOfVisit);
          console.log('data=> ' + JSON.stringify(data));
          console.log('visit id=> ' ,this.selectedVisitDetails);
      } else if (error) {
          this.error = error;
          console.log('error=> ' + JSON.stringify(error));
      }
  }

  @wire(fetchVisitDetails,{VisitId: '$selectedVisitDetails'})
  fetchedVisitDetails({data, error}){
      if(data){
          this.data = data;
          this.typeOfVisit = data.Type_Of_Visit__c;
          console.log('type of visit data=> ' ,this.typeOfVisit);
          console.log('data=> ' + JSON.stringify(data));

      }
      else if (error) {
          this.error = error;
          console.log('error=> ' + JSON.stringify(error));
  }
}

  handleInputChange(event){
    
      const field = event.target.name;
      this.contactObj = { ...this.visitObj, [field]: event.target.value };
      console.log('This is all data >>>', JSON.stringify(this.visitObj));
  }

  handleRepNameChange(event){
      this.repName = event.target.value;
      console.log('Rep Name is : ',this.repName);
  }


  visitedPartyHandleChange(event) {
      this.visitedParty = event.target.value;
      console.log('Visted party Value is : ',this.visitedParty);
      if(this.visitedParty == 'Farmer'){
          this.isFarmer = true;
          this.isDealer = false;
      }
      else if(this.visitedParty == 'Dealer'){
          this.isFarmer = false;
          this.isDealer = true;
      }
      else if(this.visitedParty == 'None'){
          this.isFarmer = false;
          this.isDealer = false;
      }
  }

  visitTypeFarmerHandleChange(event) {
      this.farmerVisitType = event.target.value;
      console.log(' Vist Type of Farmer Value is : ',this.farmerVisitType);
  }

  visitTypeDealerHandleChange(event) {
      this.dealerVisitType = event.target.value;
      console.log('Vist Type of Dealer Value is : ',this.dealerVisitType);
  }


  handleFarmerIdChange(event){
      this.farmerId = event.target.value;
  }

  handleContactSearch(event){
      this.contactName = event.target.value;
      if (this.contactName.length > 2) {
          searchContacts({ searchTerm: this.contactName })
              .then(result => {
                  this.contacts = result;
              })
              .catch(error => {
                  this.dispatchEvent(
                      new ShowToastEvent({
                          title: 'Error searching accounts',
                          message: 'erro message',
                          variant: 'error',
                      }),
                  );
              });
      } else {
          this.contacts = [];
      }
  }

  selectContact(event) {
      console.log('selected farmer Id>>', this.contactId);
      this.contactId = event.target.dataset.id;
      this.contactName = event.target.label;
      console.log('selected farmer Id>>', this.contactId);
      this.contacts = [];
  }

  handledealerIdChange(event){
      this.dealerId = event.target.value;
  }

  handleDealerSearch(event){
      this.dealerName = event.target.value;
      if (this.dealerName.length > 2) {
          searchAccount({ searchTerm: this.dealerName })
              .then(result => {
                  this.dealers = result;
              })
              .catch(error => {
                  this.dispatchEvent(
                      new ShowToastEvent({
                          title: 'Error searching accounts',
                          message: 'erro message',
                          variant: 'error',
                      }),
                  );
              });
      } else {
          this.dealers = [];
      }
  }

  selectDealer(event){
      this.accountId = event.target.dataset.id;
      this.contactName = event.target.label;
      console.log('selected Dealer Id>>', this.accountId);
      this.dealers = [];
  }

  handleStartDateChange(event){
      this.vistiDateTime = event.target.value;
  }

  showSuccessAlert(message, theme, label) {
      LightningAlert.open({
          message: 'Visit Created',
          theme: 'Success',
          label: 'Success',
      });
  }   

  handleCreateLand(){
      const fields = {
          Name : this.repName,
          Visit_Location__c : this.visitedParty,
          Type_Of_Visit__c : this.farmerVisitType,
          Type_Of_Visit_For_Dealer__c : this.dealerVisitType,
          Customer__c : this.contactId,
          Dealer__c : this.accountId,
          Status__c : this.visitStatus,
          Date__c : this.vistiDateTime
      };

      createVisit({ visit: fields })
              .then(result => {
                  console.log('Visit created successfully:', result);
                  console.log('Visit id======',result.Id);
                  this.showSuccessAlert('Event created successfully!', 'Success', 'Success');
                  
              })
              .catch(error => {
                  console.error('Error creating Visit:', error);
                  this.showSuccessAlert('Error while creating Visit!', 'Error', 'Error');
              });
  }

  handleUpdatedVisitSave() {
      const recordId = this.selectedVisitDetails;
     
      console.log('recordId Lavanya 195===> ' + recordId);

      const updatedVisit = {
          Id: this.selectedVisitId,
          Visit_Location__c : this.visitObj.visitedParty,
          Type_Of_Visit__c : this.visitObj.farmerVisitType,
          Type_Of_Visit_For_Dealer__c : this.visitObj.dealerVisitType,
          Customer__c : this.visitObj.contactId,
          Dealer__c : this.visitObj.accountId,
          Status__c : this.visitObj.visitStatus,
          Date__c : this.visitObj.vistiDateTime,
          Land_Details__c : this.visitObj.selectedLandId
      };

      console.log('updatedVisit Lavanya 203  ===> ' + JSON.stringify(updatedVisit));
      
      const fieldsToUpdate = {
          Id: recordId,
          Visit_Location__c : updatedVisit.visitedParty,
          Type_Of_Visit__c : updatedVisit.farmerVisitType,
          Type_Of_Visit_For_Dealer__c : updatedVisit.dealerVisitType,
          Customer__c : updatedVisit.contactId,
          Dealer__c : updatedVisit.accountId,
          Status__c : updatedVisit.visitStatus,
          Date__c : updatedVisit.vistiDateTime

      };
  
      updateVisitDetails({ id: recordId, visitDetailsList: fieldsToUpdate })
          .then(result => {
              console.log('result=> ' + JSON.stringify(result));
              //this.iscontactObj = true;
              
              //this.showToast('Success', 'Records updated successfully', 'success');
              //alert('Records updated successfully');
              this.showSuccessAlertUpdate();
              console.log('refresh is calling');
             //this.refreshApexcontact();
             console.log('refresh is done'); 
              console.log('looping');

              this.VisitDetails = this.VisitDetails.map(visit => {
                  
                  if (visit.Id === recordId) {
                      return { ...visit, ...updatedVisit };
                  }
                  return visit;
              });

              console.log('looping done');

          })
          .catch(error => {
              console.error(error);
              this.showErrorAlert('Error', 'An error occurred while updating the records lavanya');
              //this.showToast('Error', 'An error occurred while updating the records', 'error');
          });
      }

      showSuccessAlertUpdate() {
          LightningAlert.open({
              message: 'Farmer has been Updated successfully by lavanya',
              theme: 'Success',
              label: 'Success',
          });
      }

      handleConfirmEdit() {
        updateVisitCancelReason({ visitId: this.selectedVisitId, cancelReason: this.value })
            .then(() => {
                this.visits = this.visits.map(visit => {
                    if (visit.Id === this.selectedVisitId) {
                        return { ...visit, Cancel_Reason__c: this.value };
                    }
                    return visit;
                });
                this.showModal = false;
                console.log('Visit edited successfully');
            })
            .catch(error => {
                this.error = error;
                console.error('Error editing visit:', error);
            });
    }

  handleReset() {
      console.log('Restting the form');
      window.location.reload();
  }
  /************land search**************** */
  handleLandSearch(event) {
    this.landName = event.target.value;

    // Call the Apex method
    searchLandDetails({ searchKey: this.landName })
        .then(result => {
            // Handle the result
            this.lands = result;
        })
        .catch(error => {
            // Handle any errors
            console.error('Error fetching land details:', error);
        });
}
//get
selectland(event) {
    this.selectedLandId = event.target.dataset.id;
    this.landName = event.target.label;
    this.lands=[];

    // Handle land selection
    console.log('Selected Land ID:', this.selectedLandId);
}

}


/*Rutuja */