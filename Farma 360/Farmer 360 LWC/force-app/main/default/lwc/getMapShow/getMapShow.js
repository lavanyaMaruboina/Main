import { LightningElement, wire, track, api } from 'lwc';
import getLandDetails from '@salesforce/apex/LandDetailsController.getLandDetails';
import saveLandDetails from '@salesforce/apex/LandDetailsController.saveLandDetails';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';

export default class GetMapShow extends LightningElement {
    @api contactId;
    @track data;
    @track draftValues = [];
    @track error;

    columns = [
        { label: 'Land Name', fieldName: 'Name'},
        { label: 'Water Source', fieldName: 'Water_Source__c'},
        { label: 'Street', fieldName: 'Address__Street__s'},
        { label: 'City', fieldName: 'Address__City__s'},
        { label: 'State', fieldName: 'Address__StateCode__s'},
        { label: 'Postal Code', fieldName: 'Address__PostalCode__s'},
        { label: 'Country', fieldName: 'Address__CountryCode__s'},
    ];

    @wire(getLandDetails, { contactId: '$contactId' })
    wiredLandDetails(result) {
        this.wiredLandDetailsResult = result;
        if (result.data) {
            this.data = result.data;
            this.error = undefined;
        } else if (result.error) {
            this.error = result.error;
            this.data = undefined;
        }
    }

}