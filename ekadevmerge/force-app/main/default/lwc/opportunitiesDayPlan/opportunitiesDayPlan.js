import { LightningElement, wire, track, api } from 'lwc';
import getOpportunities from '@salesforce/apex/OpportunityDayPlan.getOpportunities';
import updateOpportunities from '@salesforce/apex/OpportunityDayPlan.updateOpportunities';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';

const columns=[
     {label:"RM Name",fieldName:"OwnerName"},
     {label:"Doctor Name",fieldName:"Name"},
     {label:"Phone",fieldName:"Phone__c"},
     {label:"Record Type",fieldName:"RecordTypeName"},
     {label:"Specialization",fieldName:"Specialization__c"},
     {label:"Day Plan Status",fieldName:"Status_of_Day_Plan__c",editable: true},
    // {label:"Visit Status",fieldName:"Activity_Status__c",editable: true},
    // {label:"Visited",fieldName:"Visited__c",editable: true},
     //{label:"Plan's Missing",fieldName:"Plan_s_Missing__c",editable: true},
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
    },

];

export default class OpportunitiesDayPlan extends LightningElement {
    @track data = [];
    @track draftValues = [];
    @track columns = columns;
    @track initialRecords;
    @track error;
    isModalOpen = false;
    selectedOpportunityId;
    wiredOpportunity;
    
    @wire(getOpportunities)
    opportunityData(result) {
        console.log('result---->'+JSON.stringify(result));
        this.wiredOpportunity = result;
        if (result.data) {
            
            this.data = result.data;
            this.initialRecords = result.data;
            this.data = result.data.map(record => ({
                ...record,
                RecordTypeName: record.RecordType ? record.RecordType.Name : '',
                OwnerName: record.Owner ? record.Owner.Name : ''
            }));
       
        } else if (result.error) {
            this.data = undefined;
        }
    }

    handleSave(event) {

        const updatedField = event.detail.draftValues;
        // Call Apex method to save changes
        updateOpportunities({ opportunityData : updatedField })
            .then(result =>{
                console.log('apex result'+JSON.stringify(result));
                this.dispatchEvent(
                    new ShowToastEvent({
                    title: 'Success',
                    message: 'Records updated successfully',
                    variant: 'success',
                    })
               );
               return refreshApex(this.wiredOpportunity);

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
            this.selectedOpportunityId = row.Id;
            this.isModalOpen = true;
            console.log('selectedOpportunityId---------'+this.selectedOpportunityId);
        }
    }

    handleModalClose() {
        // Handle modal close event
        this.isModalOpen = false;
    }


}