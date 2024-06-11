import { LightningElement, api, wire, track } from 'lwc';
import { getRecord, updateRecord, getFieldValue } from 'lightning/uiRecordApi';
import allowedRadiusLabel from '@salesforce/label/c.AllowedRadiusMeter'
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import PRIMARY_CLINIC_LATITUDE from "@salesforce/schema/Opportunity.Account.BillingLatitude";
import PRIMARY_CLINIC_LONGITUDE from "@salesforce/schema/Opportunity.Account.BillingLongitude";
import SECONDARY_CLINIC_LATITUDE from "@salesforce/schema/Opportunity.Account.ShippingLatitude";
import SECONDARY_CLINIC_LONGITUDE from "@salesforce/schema/Opportunity.Account.ShippingLongitude";



var FIELDS_JS;


export default class CheckInOutComp extends LightningElement {


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
    @track leadRec;
    @track displayCheckInBtn = false;
    @track displayCheckOutBtn = false;
    @track displaySelectAddresRG = false;
    @track displayErrorBanner = false;
    @track currentRecCheckInTime;
    @track currentRecCheckOutTime;
    @track currentRecCheckInCount;
    @track currentRecLatitude;
    @track currentRecLongitude;
    @track currentRecSecondaryLatitude;
    @track currentRecSecondaryLongitude;

    @track errorMsg;
    @track distanceToClinic;
    @track distanceToSecondaryClinic;
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
            FIELDS_JS = [PRIMARY_CLINIC_LATITUDE, PRIMARY_CLINIC_LONGITUDE, SECONDARY_CLINIC_LATITUDE, SECONDARY_CLINIC_LONGITUDE, this.currentObjectName.concat('.Check_In_Time__c'), this.currentObjectName.concat('.Check_Out_Time__c'), this.currentObjectName.concat('.Check_In_Count__c')];
            console.log('Fields ' + FIELDS_JS);
        }
        console.log('connectedCallback Exit');
    }
    @wire(getRecord, { recordId: '$recordId', fields: FIELDS_JS })
    wiredRecordFun({ error, data }) {
        console.log('Wired Function Invoked');
        this.displayCheckOutBtn = false;
        this.displayCheckInBtn = false;
        if (data) {
            console.log('Data returned  Success');
            this.currentRecord = data;
            this.currentError = undefined;
            this.currentRecCheckInTime = this.currentRecord.fields.Check_In_Time__c.value;
            this.currentRecCheckOutTime = this.currentRecord.fields.Check_Out_Time__c.value;
            this.currentRecCheckInCount = this.currentRecord.fields.Check_In_Count__c.value;
            this.currentRecLatitude = getFieldValue(this.currentRecord, PRIMARY_CLINIC_LATITUDE);
            console.log('Latitude from Account::::'+this.currentRecLatitude);
            this.currentRecLongitude = getFieldValue(this.currentRecord, PRIMARY_CLINIC_LONGITUDE);
            console.log('Longitude from Account::::::'+this.currentRecLongitude);
            this.currentRecSecondaryLatitude = getFieldValue(this.currentRecord, SECONDARY_CLINIC_LATITUDE);
            console.log(this.currentRecSecondaryLatitude);
            this.currentRecSecondaryLongitude = getFieldValue(this.currentRecord, SECONDARY_CLINIC_LONGITUDE);
            console.log(this.currentRecSecondaryLongitude);

            if ((this.currentRecLatitude == null || this.currentRecLatitude == undefined) || (this.currentRecLongitude == null || this.currentRecLongitude == undefined)) {
               console.log('Inside First Condition');
                this.displayErrorBanner = true;
                this.displayCheckOutBtn = false;
                this.displayCheckInBtn = false;
                this.displaySelectAddresRG = false;
                this.errorMsg = 'No Geolocation available for the clinic. You can not edit this record in Connect/Demo/Training stage !!! ';
            }
            else if (
                (this.currentRecLatitude != null || this.currentRecLatitude != undefined) && (this.currentRecLongitude != null || this.currentRecLongitude != undefined)
                &&
                (this.currentRecSecondaryLatitude == null || this.currentRecSecondaryLatitude == undefined) && (this.currentRecSecondaryLongitude == null || this.currentRecSecondaryLongitude == undefined)
            ) {
                this.distanceToClinic = this.geoDistance(this.userLatitude, this.userLongitude, this.currentRecLatitude, this.currentRecLongitude);
                console.log('Allowed Distance :: ' + allowedRadiusLabel + '::: Actual Distance::: ' + this.distanceToClinic);
                if (this.distanceToClinic > allowedRadiusLabel) {
                    this.displayErrorBanner = true;
                    this.displayCheckOutBtn = false;
                    this.displayCheckInBtn = false;
                    this.errorMsg = 'Not allowed to Check In from current location';
                }
                else {
                    if ((this.currentRecCheckInTime == null || this.currentRecCheckInTime == undefined) && (this.currentRecCheckOutTime == null || this.currentRecCheckOutTime == undefined)) {
                        this.displayCheckInBtn = true;
                        this.displayErrorBanner = false;
                        this.displayCheckOutBtn = false;
                        this.displaySelectAddresRG = false;
                    }
                    else if ((this.currentRecCheckInTime != null && this.currentRecCheckInTime != undefined) && (this.currentRecCheckOutTime == undefined || this.currentRecCheckOutTime == null)) {
                        this.displayCheckOutBtn = true;
                        this.displayCheckInBtn = false;
                        this.displayErrorBanner = false;
                        this.displaySelectAddresRG = false;
                    }
                }
            }
            else if (
                (this.currentRecLatitude != null || this.currentRecLatitude != undefined) && (this.currentRecLongitude != null || this.currentRecLongitude != undefined)
                &&
                (this.currentRecSecondaryLatitude != null || this.currentRecSecondaryLatitude != undefined) && (this.currentRecSecondaryLongitude != null || this.currentRecSecondaryLongitude != undefined)
            ) {
                if ((this.currentRecCheckInTime == null || this.currentRecCheckInTime == undefined) && (this.currentRecCheckOutTime == null || this.currentRecCheckOutTime == undefined)) {
                    this.distanceToClinic = this.geoDistance(this.userLatitude, this.userLongitude, this.currentRecLatitude, this.currentRecLongitude);
                    console.log('Distance to first clinic :::' + this.distanceToClinic);
                    this.distanceToSecondaryClinic = this.geoDistance(this.userLatitude, this.userLongitude, this.currentRecSecondaryLatitude, this.currentRecSecondaryLongitude);
                    console.log('Distance to second clinic :::' + this.distanceToSecondaryClinic);
                    this.displaySelectAddresRG = true;
                    this.displayCheckOutBtn = false;
                    this.displayCheckInBtn = false;
                    this.displayErrorBanner = false;
                }
                else if ((this.currentRecCheckInTime != null && this.currentRecCheckInTime != undefined) && (this.currentRecCheckOutTime == undefined || this.currentRecCheckOutTime == null)) {
                    this.displayCheckOutBtn = true;
                    this.displayCheckInBtn = false;
                    this.displayErrorBanner = false;
                    this.displaySelectAddresRG = false;
                }

            }

        }
        else if (error) {

            console.log('No Data returned - enterted in  error :::::' + error);
        }
        console.log('Wired Function Exit');
    }
    handleCheckIn(event) {
        console.log('Inside handleCheckIn');
        const fields = {};
        fields['Id'] = this.recordId;
        fields['Check_In_Time__c'] = new Date().toISOString();
        const recordInput = { fields };
        updateRecord(recordInput)
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Checked In  Successfully',
                        variant: 'success'
                    })
                );
                // Display fresh data in the form
                this.displayCheckInBtn = false;
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

    handleCheckOut(event) {
        console.log('Inside handleCheckOut');
        const fields = {};
        fields['Id'] = this.recordId;
        fields['Check_Out_Time__c'] = new Date().toISOString();
        fields['Check_In_Count__c'] = this.currentRecCheckInCount + 1;
        const recordInput = { fields };
        updateRecord(recordInput)
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Checked Out  Successfully',
                        variant: 'success'
                    })
                );
                this.displayCheckOutBtn = false;
                // Display fresh data in the form
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


    handleAddressSelection(event) {
        console.log('Inside handleAddressSelection');
        if (event.target.value === 'primaryClinic') {
            if (this.distanceToClinic > allowedRadiusLabel) {
                this.displayErrorBanner = true;
                this.errorMsg = 'Not allowed to Check In from current location';
                return;
            }
        }
        else if (event.target.value === 'secondaryClinic') {
            if (this.distanceToSecondaryClinic > allowedRadiusLabel) {
                this.displayErrorBanner = true;
                this.errorMsg = 'Not allowed to Check In from current location';
                return;
            }
        }
        else if (event.target.value == undefined) {
            return;
        }
        const fields = {};
        fields['Id'] = this.recordId;
        fields['Check_In_Time__c'] = new Date().toISOString();
        const recordInput = { fields };
        updateRecord(recordInput)
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Checked In  Successfully',
                        variant: 'success'
                    })
                );
                // Display fresh data in the form
                this.displayCheckInBtn = false;
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

    geoDistance(uLatitude, uLongitude, recLatitude, recLongitude) {
        console.log('Inside :::: geoDistance:::');
        var radlat1 = Math.PI * uLatitude / 180
        var radlat2 = Math.PI * recLatitude / 180
        var radlon1 = Math.PI * uLongitude / 180
        var radlon2 = Math.PI * recLongitude / 180
        var theta = this.userLongitude - this.currentRecLongitude
        var radtheta = Math.PI * theta / 180
        var dist = Math.sin(radlat1) * Math.sin(radlat2) + Math.cos(radlat1) * Math.cos(radlat2) * Math.cos(radtheta);
        dist = Math.acos(dist)
        dist = dist * 180 / Math.PI
        dist = dist * 60 * 1.1515; // Calculates in Miles -Default
        dist = (dist * 1.609344) * 1000; //Calculates in KM --> multipled by 1000 to get in Meters
        //  if (unit=="N") { dist = dist * 0.8684 } //Calculates in Nautical Miles
        console.log('Moving out from geolocation :::' + dist);
        return dist;
    }


}