import { LightningElement, wire, track } from 'lwc';
import getLeads from '@salesforce/apex/leadsDayPlan.getLeads';
import updateLeads from '@salesforce/apex/leadsDayPlan.updateLeads';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';

const columns=[
    {label:"RM Name",fieldName:"OwnerName"},
    {label:"Doctor Name",fieldName:"Name"},
    {label:"Phone",fieldName:"Phone"},
    {label:"Record Type",fieldName:"RecordTypeName"},
    {label:"Day Plan Status",fieldName:"Status_of_Day_Plan__c",type:'Text',editable: true},

];

export default class LeadsDayPlan extends LightningElement {
    @track data = [];
    @track draftValues = [];
    @track columns = columns;
    @track initialRecords;
    @track error;
    wiredLead
    
    @wire(getLeads)
    leadData(result) {
        console.log('result---->'+JSON.stringify(result));
        this.wiredLead = result;
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
        updateLeads({ leadData : updatedField })
            .then(result =>{
                console.log('apex result'+JSON.stringify(result));
                this.dispatchEvent(
                    new ShowToastEvent({
                    title: 'Success',
                    message: 'Records updated successfully',
                    variant: 'success',
                    })
               );
               return refreshApex(this.wiredLead);

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

}