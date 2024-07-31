import { LightningElement, wire, track, api } from 'lwc';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import Land_Yield__c from '@salesforce/schema/Land_Yield__c';
import Period__c from '@salesforce/schema/Land_Yield__c.Period__c';
import Year__c from '@salesforce/schema/Land_Yield__c.Year__c';
import searchLands from '@salesforce/apex/VisitController.searchLands';
import createLandYield from '@salesforce/apex/VisitController.createLandYield';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class LandYieldDetails extends LightningElement {

    @track landYieldName = '';
    @track periodOptions;
    @track periodChoosen = '';
    @track yearOptions;
    @track yearChoosen = '';
    @track QuantityEntered = '';
    @track descriptionEntred = '';
    @track landSearched = '';
    @track lands = []; 
    @api landId;
    @track createdLandYield = '';

    @wire(getObjectInfo, { objectApiName: Land_Yield__c })
    landYieldInfo;

    @wire(getPicklistValues, { recordTypeId: '$landYieldInfo.data.defaultRecordTypeId', fieldApiName: Period__c })
    periodInfo({ data, error }) {
        if (data) this.periodOptions = data.values;
    }

    @wire(getPicklistValues, { recordTypeId: '$landYieldInfo.data.defaultRecordTypeId', fieldApiName: Year__c })
    yearInfo({ data, error }) {
        if (data) this.yearOptions = data.values;
    }

    handleLandYieldNameChange(event){
        this.landYieldName = event.target.value;
        console.log('Land Yield Info : ',this.landYieldName);
    }

    handlePeriodChange(event){
        this.periodChoosen = event.target.value;
        console.log('Selected Period : ',this.periodChoosen);
    }

    handleYearChange(event){
        this.yearChoosen = event.target.value;
        console.log('Selected Year : ',this.yearChoosen);
    }

    handleLandYieldQuantityChange(event){
        this.QuantityEntered = event.target.value;
        console.log('Entered Quantity : ',this.QuantityEntered);
    }

    handleLandYieldDescriptionChange(event){
        this.descriptionEntred = event.target.value;
        console.log('Entered Description : ',this.descriptionEntred);
    }

    handleLandSearch(event){
        this.landSearched = event.target.value;
        if (this.landSearched.length > 2) {
            console.log('I am searching for the land');
            searchLands({ searchTerm: this.landSearched})
                .then(result => {
                    console.log('Result ==> ' + JSON.stringify(result));
                    this.lands = result;
                })
                .catch(error => {
                    console.log('I am in Error');
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error searching accounts',
                            message: 'erro message',
                            variant: 'error',
                        }),
                    );
                });
        } else {
            this.lands = [];
        }
    }

    selectLand(event){
        
        this.landId = event.target.dataset.id;
        this.landSearched = event.target.label;
        console.log('selected land Id>>', this.landId);
        this.lands = [];
    }

    handleReset() {
        console.log('Restting the form');
        window.location.reload();
    }

    handleCreateLandYield(){
        const fields = {
            Name : this.landYieldName,
            Description__c : this.descriptionEntred,
            Period__c : this.periodChoosen,
            Quantity__c : this.QuantityEntered,
            Year__c : this.yearChoosen,
            Land_Details__c : this.landId
        };

        createLandYield({ landYield: fields })
        .then(result => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Land Yield Created Successfully',
                    variant: 'success',
                })
            );
            console.log('Land Yield created successfully:', result);
            this.createdLandYield = result.Id;
            console.log('Land Yield created ID:', this.createdLandYield);
            
        })
        .catch(error => {
            console.error('Error creating Land Yield:', error);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error creating Land Yield',
                    message: error.message,
                    variant: 'error',
                }),
            );
        });
    }

}