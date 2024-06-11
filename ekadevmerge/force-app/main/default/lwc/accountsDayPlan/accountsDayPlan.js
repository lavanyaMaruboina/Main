import { LightningElement, wire, track } from 'lwc';
import getAccounts from '@salesforce/apex/accountsDayPlan.getAccounts';
import updateAccounts from '@salesforce/apex/accountsDayPlan.updateAccounts';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';

const columns=[
     {label:"RM Name",fieldName:"OwnerName"},
     {label:"Doctor Name",fieldName:"Name"},
     {label:"Phone",fieldName:"Phone"},
     {label:"Specialization",fieldName:"Specialization__c"},
     {label:"Day Plan Status",fieldName:"Status_of_Day_Plan__c",editable: true},
     {
        label: 'Create Day Plan',
        type: 'button',
        typeAttributes: {
            label: 'Create Day Plan',
            name: 'create_Day_Plan',
            title: 'Click to create a new Day Plan',    
            variant: 'brand',
            iconName: 'utility:add'
        }
    }
     

];

export default class AccountsDayPlan extends LightningElement {
    @track data = [];
    @track draftValues = [];
    @track columns = columns;
    @track initialRecords;
    @track error;
    wiredAccount;
    isModalOpen = false;
    selectedAccountId;
    
    @wire(getAccounts)
    accountData(result) {
        console.log('this result---->'+JSON.stringify(result));
        this.wiredAccount = result;
        if (result.data) {
            
            this.data = result.data;
            this.initialRecords = result.data;
            this.data = result.data.map(record => ({
                ...record,
                OwnerName: record.Owner ? record.Owner.Name : ''
            }));
       
        } else if (result.error) {
            this.data = undefined;
        }
    }

    handleSave(event){
        const updatedField = event.detail.draftValues;
        // Call Apex method to save changes
        updateAccounts({ accountData : updatedField })
            .then(result =>{
                console.log('apex result'+JSON.stringify(result));
                this.dispatchEvent(
                    new ShowToastEvent({
                    title: 'Success',
                    message: 'Records updated successfully',
                    variant: 'success',
                    })
               );
               return refreshApex(this.wiredAccount);

            })
            .catch(error => {
                this.error = error.body.output.errors[0].errorCode + error.body.output.errors[0].message;
                this.dispatchEvent(
                    new ShowToastEvent({
                    title: 'Error',
                    message: error.body.output.errors[0].errorCode + error.body.output.errors[0].message,
                    variant: 'error',
                    })
               );
            });
    }

    changeHandler(event) {
        const searchKey = event.target.value.toLowerCase();
        if (searchKey) {
        this.data = this.initialRecords;
        if (this.data) {
        let searchRecords = [];
        for (let record of this.data) {
        let valuesArray = Object.values(record);
        for (let val of valuesArray) {
        console.log('lavanya>>>>>>>>>>>>>' + JSON.stringify(val));
        let strVal = String(val);
        if (strVal) {
        if (strVal.toLowerCase().includes(searchKey)) {
        searchRecords.push(record);
        break;
                       }
                  }
             }
        }
   
        console.log('Matched Leads are ' + JSON.stringify(searchRecords));
        this.data = searchRecords;
        }
        } else {
            this.data = this.initialRecords;
        }
    }

    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;

        if (actionName === 'create_Day_Plan') {
            // Handle opening the modal
            this.selectedAccountId = row.Id;
            this.isModalOpen = true;
            console.log('selectedAccountId---------'+this.selectedAccountId);
        }
    }

    handleModalClose() {
        // Handle modal close event
        this.isModalOpen = false;
    }
}