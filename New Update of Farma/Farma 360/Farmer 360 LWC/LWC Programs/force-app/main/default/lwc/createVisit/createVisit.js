import { api, LightningElement, track, wire } from 'lwc';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import Visit__c from '@salesforce/schema/Visit__c';
import Visit_Location__c from '@salesforce/schema/Visit__c.Visit_Location__c';
import Type_Of_Visit__c from '@salesforce/schema/Visit__c.Type_Of_Visit__c';
import Type_Of_Visit_For_Dealer__c from '@salesforce/schema/Visit__c.Type_Of_Visit_For_Dealer__c';
import createVisit from '@salesforce/apex/VisitController.createVisit';
import searchContacts from '@salesforce/apex/VisitController.searchContacts';
import searchAccount from '@salesforce/apex/VisitController.searchAccount';
import searchContactName from '@salesforce/apex/VisitController.searchContactName';
//import LightningAlert from 'lightning/alert';
import getUserDetails from '@salesforce/apex/userController.getUserDetails';
import Id from "@salesforce/user/Id";


export default class CreateVisit extends LightningElement {

    @track visitedPartyValue = 'None';
    @track visitTypeFarmerValue;
    @track visitTypeDealerValue = 'None';
    @track isFarmer = false;
    @track isDealer = false;
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
    @track userId = Id;
    @track showModal = false;
    @track createdVisit;
    //@track contactName;
    error;

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
            console.log('data=> ' + JSON.stringify(data));
        } else if (error) {
            this.error = error;
            console.log('error=> ' + JSON.stringify(error));
        }
    }

    // @wire(searchContactName, { contactId: '$userId' })
    // wiredUser({ error, data }) {
    //     if (data) {
    //         this.userName = data.Name; 
    //     } else if (error) {
    //         console.error(error);
    //     }
    // }

    

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
/*****date value***** */
     dateval;


  get dateValue(){
    if(this.dateval == undefined)
    {
      this.dateval = new Date().toISOString().substring(0, 10);
    }
    return this.dateval;
  }

  changedate(event){
    this.dateval = event.target.value;
  }


    handleCreateVisit(){
        const fields = {
            Name : this.userName,
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
                    this.createdVisit = result;
                    this.showModal = true;
                })
                .catch(error => {
                    console.error('Error creating Visit:', error);
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error creating Visit',
                            message: error.message,
                            variant: 'error',
                        }),
                    );
                });
    }

    closeModal() {
        this.showModal = false;
        this.handleReset();
    }

    handleClone() {
        this.showModal = false;
        // Populate the form with the data from the created visit
        this.repName = this.createdVisit.Name;
        this.visitedParty = this.createdVisit.Visit_Location__c;
        if(this.visitedParty == 'Farmer') {
            this.isFarmer = true;
            this.isDealer = false;
            this.farmerVisitType = this.createdVisit.Type_Of_Visit__c;
            this.contactName = this.createdVisit.Customer__c;
        } else if(this.visitedParty == 'Dealer') {
            this.isFarmer = false;
            this.isDealer = true;
            this.dealerVisitType = this.createdVisit.Type_Of_Visit_For_Dealer__c;
            this.dealerName = this.createdVisit.Dealer__c;
        }
        this.vistiDateTime = this.createdVisit.Date__c;
    }

    handleReset() {
        console.log('Restting the form');
        window.location.reload();
    }
    

}