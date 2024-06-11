import { LightningElement, api, wire, track } from 'lwc';
import { getRecord, updateRecord, getFieldValue } from 'lightning/uiRecordApi';
import allowedRadiusLabel from '@salesforce/label/c.AllowedRadiusMeter'
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';

//import PRIMARY_CHECK_IN_LATITUDE from "@salesforce/schema/Opportunity.Account.Check_In_Geolocation__Latitude__s";
//import PRIMARY_CHECK_IN_LONGITUDE from "@salesforce/schema/Opportunity.Account.Check_In_Geolocation__Longitude__s";
import PRIMARY_CLINIC_LATITUDE from "@salesforce/schema/Opportunity.Account.BillingLatitude";
import PRIMARY_CLINIC_LONGITUDE from "@salesforce/schema/Opportunity.Account.BillingLongitude";
import SECONDARY_CLINIC_LATITUDE from "@salesforce/schema/Opportunity.Account.ShippingLatitude";
import SECONDARY_CLINIC_LONGITUDE from "@salesforce/schema/Opportunity.Account.ShippingLongitude";



var FIELDS_JS;
const OppAPIName = 'Opportunity';
const accountAPIName = 'Account';


export default class CheckInOutTracker extends LightningElement {


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
    @track displaySetLocationNCheckInBtn = false;
    @track displayMsgBanner = false;
    @track currentRecCheckInTime;
    @track currentRecCheckOutTime;
    @track currentRecCheckInCount;
    @track currentRecPrimaryLatitude;
    @track currentRecPrimaryLongitude;
    @track currentRecSecondaryLatitude;
    @track currentRecSecondaryLongitude;
    @track currentRecPrimaryCheckInLatitude;
    @track currentRecPrimaryCheckInLongitude;
    @track currentRecSecondaryCheckInLatitude;
    @track currentRecSecondaryCheckInLongitude;
    @track displayMsg;
    @track distanceToClinicByAddress;
    @track distanceToClinicByGeoLocation;
    @track distanceToSecondaryClinic;
    @track displayPageLoader;
    //variables for Messages


    get options() {
        return [
            { label: 'Primary Clinic', value: 'primaryClinic' },
            { label: 'Secondary Clinic', value: 'secondaryClinic' },
        ];
    }
    
    connectedCallback() {
        console.log('connectedCallback Invoked');
        this.displayCheckInBtn = false;
        this.displayCheckOutBtn = false;
        this.displaySelectAddresRG = false;
        this.displaySetLocationNCheckInBtn = false;
        this.displayMsgBanner = false;
        this.displayPageLoader=false;
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
        console.log('The current Object API:::' + this.currentObjectName);
        if (this.currentObjectName != null && this.currentObjectName != undefined) {
            if (this.currentObjectName == OppAPIName) {
                FIELDS_JS = [PRIMARY_CLINIC_LATITUDE, PRIMARY_CLINIC_LONGITUDE, SECONDARY_CLINIC_LATITUDE, SECONDARY_CLINIC_LONGITUDE,this.currentObjectName.concat('.Check_In_Geolocation__Latitude__s'), this.currentObjectName.concat('.Check_In_Geolocation__Longitude__s'), this.currentObjectName.concat('.Check_In_Time__c'), this.currentObjectName.concat('.Check_Out_Time__c'), this.currentObjectName.concat('.Check_In_Count__c')];
                console.log('Fields ' + FIELDS_JS);
            }

            else if (this.currentObjectName == accountAPIName) {
                FIELDS_JS = [this.currentObjectName.concat('.Check_In_Geolocation__Latitude__s'), this.currentObjectName.concat('.Check_In_Geolocation__Longitude__s'), this.currentObjectName.concat('.BillingLatitude'), this.currentObjectName.concat('.BillingLongitude'), this.currentObjectName.concat('.ShippingLatitude'), this.currentObjectName.concat('.ShippingLongitude'), this.currentObjectName.concat('.Check_In_Time__c'), this.currentObjectName.concat('.Check_Out_Time__c'), this.currentObjectName.concat('.Check_In_Count__c')];
                console.log('Fields ' + FIELDS_JS);
            }

        }

        console.log('connectedCallback Exit');
    }

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS_JS })
    wiredRecordFun({ error, data }) {
        console.log('Wired Function Invoked');
        this.displayCheckInBtn = false;
        this.displayCheckOutBtn = false;
        this.displaySelectAddresRG = false;
        this.displaySetLocationNCheckInBtn = false;
        this.displayMsgBanner = false;
        this.displayPageLoader=false;
        if (data) {
            //fetch the field values -Start
            console.log('Data returned  Success');
            this.currentRecord = data;
            this.currentError = undefined;
            this.currentRecCheckInTime = this.currentRecord.fields.Check_In_Time__c.value;
            this.currentRecCheckOutTime = this.currentRecord.fields.Check_Out_Time__c.value;
            this.currentRecCheckInCount = this.currentRecord.fields.Check_In_Count__c.value;

            if (this.currentObjectName == OppAPIName) {
                console.log('Inside Opportunity Record');
                this.currentRecPrimaryLatitude = getFieldValue(this.currentRecord, PRIMARY_CLINIC_LATITUDE);
                this.currentRecPrimaryLongitude = getFieldValue(this.currentRecord, PRIMARY_CLINIC_LONGITUDE);
                this.currentRecSecondaryLatitude = getFieldValue(this.currentRecord, SECONDARY_CLINIC_LATITUDE);
                this.currentRecSecondaryLongitude = getFieldValue(this.currentRecord, SECONDARY_CLINIC_LONGITUDE);
              //  this.currentRecPrimaryCheckInLatitude = getFieldValue(this.currentRecord, PRIMARY_CHECK_IN_LATITUDE);
              //  this.currentRecPrimaryCheckInLongitude = getFieldValue(this.currentRecord, PRIMARY_CHECK_IN_LONGITUDE);
            }
            else if (this.currentObjectName == accountAPIName) {
                console.log('Inside Account Record');
                this.currentRecPrimaryLatitude = this.currentRecord.fields.BillingLatitude.value;
                this.currentRecPrimaryLongitude = this.currentRecord.fields.BillingLongitude.value;
                this.currentRecSecondaryLatitude = this.currentRecord.fields.ShippingLatitude.value;
                this.currentRecSecondaryLongitude = this.currentRecord.fields.ShippingLongitude.value;
            }
                this.currentRecPrimaryCheckInLatitude = this.currentRecord.fields.Check_In_Geolocation__Latitude__s.value;
                this.currentRecPrimaryCheckInLongitude = this.currentRecord.fields.Check_In_Geolocation__Longitude__s.value;
            

            //fetch the field values - End

            //Requirement Handling - Start
            //Need to find the alternative 

          /*  if(this.userLatitude==null && this.userLongitude==null && this.userLatitude==undefined && this.userLongitude==undefined)
            {
                this.displayPageLoader=true;
                this.displayCheckInBtn = false;
                this.displayMsgBanner = false;
                this.displayCheckOutBtn = false;
                this.displaySelectAddresRG = false;
               // window.location.reload();
            } */

            if ((this.currentRecPrimaryLatitude == null || this.currentRecPrimaryLatitude == undefined) || (this.currentRecPrimaryLongitude == null || this.currentRecPrimaryLongitude == undefined)) {
                if ((this.currentRecPrimaryCheckInLatitude == null || this.currentRecPrimaryCheckInLatitude == undefined) || (this.currentRecPrimaryCheckInLongitude == null || this.currentRecPrimaryCheckInLongitude == undefined)) {
                    this.displayMsgBanner = true;
                    this.displaySetLocationNCheckInBtn = true;
                    this.displayCheckOutBtn = false;
                    this.displayCheckInBtn = false;
                    this.displaySelectAddresRG = false;
                    this.displayPageLoader=false;
                    this.displayMsg = 'No complete Address OR Geolocation captured earlier.Do update the address after check In - WITHOUT FAIL.';
                }
                else if ((this.currentRecPrimaryCheckInLatitude != null && this.currentRecPrimaryCheckInLatitude != undefined) && (this.currentRecPrimaryCheckInLongitude != null && this.currentRecPrimaryCheckInLongitude != undefined)) {
                    this.distanceToClinicByGeoLocation = this.geoDistance(this.userLatitude, this.userLongitude, this.currentRecPrimaryCheckInLatitude, this.currentRecPrimaryCheckInLongitude);
                    if (this.distanceToClinicByGeoLocation > 2000) {
                        this.displayMsgBanner = true;
                        this.displaySetLocationNCheckInBtn = true;
                        this.displayCheckOutBtn = false;
                        this.displayCheckInBtn = false;
                        this.displaySelectAddresRG = false;
                        this.displayPageLoader=false;
                        this.displayMsg = 'Last geolocation of clinic does not  match with your current location. Reset your current location as clinic geolocation.Do update the address after check In - WITHOUT FAIL ';
                    }
                    else {
                        if ((this.currentRecCheckInTime == null || this.currentRecCheckInTime == undefined) && (this.currentRecCheckOutTime == null || this.currentRecCheckOutTime == undefined)) {
                            this.displayCheckInBtn = true;
                            this.displayMsgBanner = true;
                            this.displaySetLocationNCheckInBtn = false;
                            this.displayCheckOutBtn = false;
                            this.displaySelectAddresRG = false;
                            this.displayPageLoader=false;
                            this.displayMsg = 'Do update the address after check In - WITHOUT FAIL ';
                        }
                        else if ((this.currentRecCheckInTime != null && this.currentRecCheckInTime != undefined) && (this.currentRecCheckOutTime == undefined || this.currentRecCheckOutTime == null)) {
                            this.displayCheckOutBtn = true;
                            this.displayCheckInBtn = false;
                            this.displayMsgBanner = false;
                            this.displaySelectAddresRG = false;
                            this.displaySetLocationNCheckInBtn = false;
                            this.displayPageLoader=false;
                        }
                    }
                }
            }

            else if (
                (this.currentRecPrimaryLatitude != null && this.currentRecPrimaryLatitude != undefined) && (this.currentRecPrimaryLongitude != null && this.currentRecPrimaryLongitude != undefined)
                &&
                (this.currentRecSecondaryLatitude == null || this.currentRecSecondaryLatitude == undefined) && (this.currentRecSecondaryLongitude == null || this.currentRecSecondaryLongitude == undefined)
            ) {
                this.distanceToClinicByAddress = this.geoDistance(this.userLatitude, this.userLongitude, this.currentRecPrimaryLatitude, this.currentRecPrimaryLongitude);
                console.log('Allowed Distance :: ' + allowedRadiusLabel + '::: Actual Distance::: ' + this.distanceToClinicByAddress);
                if (this.distanceToClinicByAddress > allowedRadiusLabel) {
                    this.displayMsgBanner = true;
                    this.displayCheckOutBtn = false;
                    this.displayCheckInBtn = false;
                    this.displayMsg = 'Not allowed to Check In from current location';
                }
                else {
                    if ((this.currentRecCheckInTime == null || this.currentRecCheckInTime == undefined) && (this.currentRecCheckOutTime == null || this.currentRecCheckOutTime == undefined)) {
                        console.log('Inside No checkin Time');
                        this.displayCheckInBtn = true;
                        this.displayMsgBanner = false;
                        this.displayCheckOutBtn = false;
                        this.displaySelectAddresRG = false;
                    }
                    else if ((this.currentRecCheckInTime != null && this.currentRecCheckInTime != undefined) && (this.currentRecCheckOutTime == undefined || this.currentRecCheckOutTime == null)) {
                        this.displayCheckOutBtn = true;
                        this.displayCheckInBtn = false;
                        this.displayMsgBanner = false;
                        this.displaySelectAddresRG = false;
                    }
                }
            }
            else if (
                (this.currentRecPrimaryLatitude != null || this.currentRecPrimaryLatitude != undefined) && (this.currentRecPrimaryLongitude != null || this.currentRecPrimaryLongitude != undefined)
                &&
                (this.currentRecSecondaryLatitude != null || this.currentRecSecondaryLatitude != undefined) && (this.currentRecSecondaryLongitude != null || this.currentRecSecondaryLongitude != undefined)
            ) {
                if ((this.currentRecCheckInTime == null || this.currentRecCheckInTime == undefined) && (this.currentRecCheckOutTime == null || this.currentRecCheckOutTime == undefined)) {
                    this.distanceToClinicByAddress = this.geoDistance(this.userLatitude, this.userLongitude, this.currentRecPrimaryLatitude, this.currentRecPrimaryLongitude);
                    console.log('Distance to first clinic :::' + this.distanceToClinicByAddress);
                    this.distanceToSecondaryClinic = this.geoDistance(this.userLatitude, this.userLongitude, this.currentRecSecondaryLatitude, this.currentRecSecondaryLongitude);
                    console.log('Distance to second clinic :::' + this.distanceToSecondaryClinic);
                    this.displaySelectAddresRG = true;
                    this.displayCheckOutBtn = false;
                    this.displayCheckInBtn = false;
                    this.displayMsgBanner = false;
                }
                else if ((this.currentRecCheckInTime != null && this.currentRecCheckInTime != undefined) && (this.currentRecCheckOutTime == undefined || this.currentRecCheckOutTime == null)) {
                    this.displayCheckOutBtn = true;
                    this.displayCheckInBtn = false;
                    this.displayMsgBanner = false;
                    this.displaySelectAddresRG = false;
                }
            }
        }
        else if (error) {

            console.log('No Data returned - enterted in  error :::::' + error);
        }
        console.log('Wired Function Exit');
    }

    //Handle Component Event - start
    handleCheckIn(event) {
        console.log('Inside handleCheckIn');
        const fields = {};
        fields['Id'] = this.recordId;
        fields['Check_In_Time__c'] = new Date().toISOString();
        fields['Check_In_Geolocation__Latitude__s'] = this.userLatitude;
        fields['Check_In_Geolocation__Longitude__s'] = this.userLongitude;
        const recordInput = { fields };
        updateRecord(recordInput)
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Checked In  Successfully.',
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
                        title: 'Failure',
                        message:'Error occured while saving the  record :::' + error.body.message,
                        variant: 'error'
                    })
                );
            });
    }

    handleSetGeolocationNCheckIn(event) {
        console.log('Inside handleSetGeolocationNCheckIn');
        if((this.userLatitude!=null && this.userLatitude!=undefined) && (this.userLongitude!=null && this.userLongitude!=undefined))
        {
        const fields = {};
        fields['Id'] = this.recordId;
        fields['Check_In_Time__c'] = new Date().toISOString();
        fields['Check_In_Geolocation__Latitude__s'] = this.userLatitude;
        fields['Check_In_Geolocation__Longitude__s'] = this.userLongitude;
        const recordInput = { fields };
        updateRecord(recordInput)
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Your current location is set to clinic location. Please do update address after check in- WITHOUT FAIL!!',
                        variant: 'success'
                    })
                );
                // Display fresh data in the form
                this.displaySetLocationNCheckInBtn = false;
                return refreshApex(this.currentRecord);
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Failure',
                        message: 'Error occured while saving the  record :::' + error.body.message,
                        variant: 'error'
                    })
                );
            });
        }
        else
        {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Failure',
                    message: 'Your current location is not fetched. Please enable location tracking in your device.',
                    variant: 'error'
                })
            );
        }


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
                        title: 'Failure',
                        message: 'Error occured while saving the  record :::' + error.body.message,
                        variant: 'error'
                    })
                );
            });
    }


    handleAddressSelection(event) {
        console.log('Inside handleAddressSelection');
        if (event.target.value === 'primaryClinic') {
            if (this.distanceToClinicByAddress > allowedRadiusLabel) {
                this.displayMsgBanner = true;
                this.displayMsg = 'Not allowed to Check In from current location';
                return;
            }
        }
        else if (event.target.value === 'secondaryClinic') {
            if (this.distanceToSecondaryClinic > allowedRadiusLabel) {
                this.displayMsgBanner = true;
                this.displayMsg = 'Not allowed to Check In from current location';
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
                        title: 'Failure',
                        message: 'Error occured while saving the  record :::' + error.body.message,
                        variant: 'error'
                    })
                );
            });
    }
    //Handle Component Event - End


    //Functions - Start
    geoDistance(uLatitude, uLongitude, recLatitude, recLongitude) {
        console.log('Inside :::: geoDistance:::');
        console.log('uLatitude, uLongitude, recLatitude, recLongitude:::' +uLatitude+'::'+ uLongitude+'::'+ recLatitude+'::'+ recLongitude);

        var radlat1 = Math.PI * uLatitude / 180
        var radlat2 = Math.PI * recLatitude / 180
        var radlon1 = Math.PI * uLongitude / 180
        var radlon2 = Math.PI * recLongitude / 180
        // var theta = this.userLongitude - this.currentRecPrimaryLongitude
        var theta = uLongitude - recLongitude;
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

    //Functions - End
}