import { LightningElement, api, wire, track } from 'lwc';
import { getRecord, updateRecord, getFieldValue } from 'lightning/uiRecordApi';
import allowedRadiusLabel from '@salesforce/label/c.AllowedRadiusMeter'
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import ACCOUNT_ID from '@salesforce/schema/Opportunity.Account.Id';
import PRIMARY_CLINIC_LATITUDE from "@salesforce/schema/Opportunity.Account.BillingLatitude";
import PRIMARY_CLINIC_LONGITUDE from "@salesforce/schema/Opportunity.Account.BillingLongitude";
import SECONDARY_CLINIC_LATITUDE from "@salesforce/schema/Opportunity.Account.ShippingLatitude";
import SECONDARY_CLINIC_LONGITUDE from "@salesforce/schema/Opportunity.Account.ShippingLongitude";



var FIELDS_JS;


export default class SetGeoLocationComp extends LightningElement {


    //variables

    @api objectApiName;
    @api recordId;
    @track currenObjectName;
    @track currenRecordId;
    @track userLatitude;
    @track userLongitude
    // variables for Buttons
    @track currentRecord;
    @track currentError;
    @track currentAccounID;
    @track displaySetGeoLocationBtn = false;
    @track currentRecLatitude;
    @track currentRecLongitude;
    @track errorMsg;
   
    //variables for Messages


    get options() {
        return [
            { label: 'Primary Clinic', value: 'primaryClinic' },
            { label: 'Secondary Clinic', value: 'secondaryClinic' },
        ];
    }
    connectedCallback() {
        console.log('connectedCallback Invoked');
        if (navigator.geolocation) {
            navigator.geolocation.getCurrentPosition(position => {

                // Get the Latitude and Longitude from Geolocation API
                this.userLatitude = position.coords.latitude;
                this.userLongitude = position.coords.longitude;
                console.log('The Current latitude is :::' + this.userLatitude);
                console.log('The Current longitude is :::' + this.userLongitude);
            });
        }
        this.currenRecordId = this.recordId;
        this.currentObjectName = this.objectApiName;
        if (this.currentObjectName != null && this.currentObjectName != undefined) {
            FIELDS_JS = [ACCOUNT_ID,PRIMARY_CLINIC_LATITUDE, PRIMARY_CLINIC_LONGITUDE]//, SECONDARY_CLINIC_LATITUDE, SECONDARY_CLINIC_LONGITUDE, this.currentObjectName.concat('.Check_In_Time__c'), this.currentObjectName.concat('.Check_Out_Time__c'), this.currentObjectName.concat('.Check_In_Count__c')];
            console.log('Fields ' + FIELDS_JS);
        }
        console.log('connectedCallback Exit');
    }
    @wire(getRecord, { recordId: '$recordId', fields: FIELDS_JS })
    wiredRecordFun({ error, data }) {
        console.log('Wired Function Invoked');
        this.displaySetGeoLocationBtn = false;
        if (data) {
            console.log('Data returned  Success');
            this.currentRecord = data;
            this.currentError = undefined;
            this.currentRecLatitude = getFieldValue(this.currentRecord, PRIMARY_CLINIC_LATITUDE);
            console.log(this.currentRecLatitude);
            this.currentRecLongitude = getFieldValue(this.currentRecord, PRIMARY_CLINIC_LONGITUDE);
            console.log(this.currentRecLongitude);
            this.currentAccounID= getFieldValue(this.currentRecord, ACCOUNT_ID);
            if ((this.currentRecLatitude == null || this.currentRecLatitude == undefined) || (this.currentRecLongitude == null || this.currentRecLongitude == undefined)) {
                this.displaySetGeoLocationBtn=true;               
            }
            
        }
        else if (error) {

            console.log('No Data returned - enterted in  error :::::' + error);
        }
        console.log('Wired Function Exit');
    }
    handleSetGeoLocation(event) {
        console.log('Inside handleSetGeoLocation');
        const fields = {};
        fields['Id'] = this.currentAccounID;
        fields['BillingLatitude'] =this.userLatitude ;
        fields['BillingLongitude']=this.userLongitude

        const recordInput = { fields };
        updateRecord(recordInput)
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Geo Location set  Successfully',
                        variant: 'success'
                    })
                );
                // Display fresh data in the form
                this.displaySetGeoLocationBtn = false;
                return refreshApex(this.currentRecord);
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error creating record',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
            });
    }

     


}