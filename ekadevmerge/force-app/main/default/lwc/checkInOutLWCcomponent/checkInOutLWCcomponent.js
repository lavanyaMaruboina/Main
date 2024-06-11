import { refreshApex } from '@salesforce/apex';
import allowedRadiusLabel from '@salesforce/label/c.AllowedRadiusMeter';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { createRecord, getFieldValue, getRecord, updateRecord } from 'lightning/uiRecordApi';
import { LightningElement, api, track, wire } from 'lwc';

import PRIMARY_CLINIC_LATITUDE from "@salesforce/schema/Opportunity.Account.BillingLatitude";
import PRIMARY_CLINIC_LONGITUDE from "@salesforce/schema/Opportunity.Account.BillingLongitude";
import SECONDARY_CLINIC_LATITUDE from "@salesforce/schema/Opportunity.Account.ShippingLatitude";
import SECONDARY_CLINIC_LONGITUDE from "@salesforce/schema/Opportunity.Account.ShippingLongitude";

import SECONDARY_CLINIC_CITY from "@salesforce/schema/Opportunity.Account.ShippingCity";
import SECONDARY_CLINIC_STATE from "@salesforce/schema/Opportunity.Account.ShippingState";
import SECONDARY_CLINIC_STREET from "@salesforce/schema/Opportunity.Account.ShippingStreet"; //Mahesh Reddy
//import SECONDARY_CLINIC_POSTALCODE from "@salesforce/schema/Opportunity.Account.ShippingPostalCode";
//import SECONDARY_CLINIC_COUNTRY from "@salesforce/schema/Opportunity.Account.ShippingCountry";

// To get current login user info
import NAME_FIELD from '@salesforce/schema/User.Name';
import USER_ID from '@salesforce/user/Id';

//import getDetails from '@salesforce/apex/getUserCheckInDetails.getDetails';

import CLINIC_CHECK_IN_OBJECT from '@salesforce/schema/Check_IN_Out__c';

var FIELDS_JS;
const OppAPIName = 'Opportunity';
const accountAPIName = 'Account';

export default class CheckInOutLWCcomponent extends LightningElement {

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
    @track locationEnabled;
    @track displayCheckInBtnWithoutGeolocationCaptured = false;
    //variables for Messages


    @track checkOutTime;
    @track checkInTimeRecord = null;

    @track userName;
    @track currentUserId;

    //Mahesh Reddy
    @track currentRecSecondaryStreet;
    @track currentRecSecondaryCity;
    @track currentRecSecondaryState;
    //@track currentRecSecondaryPostalCode;
    //@track currentRecSecondaryCountry;

    @wire(getRecord, {
        recordId: USER_ID,
        fields: [NAME_FIELD]
    }) wireuser({
        error,
        data
    }) {
        if (error) {
           this.userName = error ; 
        } else if (data) {
            this.userName = data.fields.Name.value;
        }
    }

    get options() {
        return [
            { label: 'Primary Clinic', value: 'primaryClinic' },
            { label: 'Secondary Clinic', value: 'secondaryClinic' },
        ];
    }

    connectedCallback() {
        console.log('connectedCallback Invoked');

        this.currentUserId = USER_ID;
        console.log('current User id ' + this.currentUserId);
        console.log('userid '+ USER_ID);


        this.displayCheckInBtnWithoutGeolocationCaptured = false;
        this.displayCheckInBtn = false;
        this.displayCheckOutBtn = false;
        this.displaySelectAddresRG = false;
        this.displaySetLocationNCheckInBtn = false;
        this.displayMsgBanner = false;
        this.displayPageLoader = false;
        this.currenRecordId = this.recordId;
        this.currentObjectName = this.objectApiName;
        console.log('The current Object API:::' + this.currentObjectName);

      /*  getDetails( { oppId: this.currenRecordId , userId: this.currentUserId})
            .then(result => {
                console.log('result 122 '+ JSON.stringify(result ));
                if(result != null){
                this.checkInTimeRecord = result;
                this.checkOutTime = result.Check_Out_Time__c;
                console.log('check in data 122 '+ JSON.stringify(this.checkInTimeRecord ));
                console.log('result.Check_Out_Time__c '+ result.Check_Out_Time__c);
                console.log('this.checkOutTime '+this.checkOutTime);
                }else{
                    this.checkInTimeRecord = null;
                }
            })
            .catch(error => {
                //this.error = error;
                console.log('error 12222 '+ JSON.stringify(error));
            });  */


        if (this.currentObjectName != null && this.currentObjectName != undefined) {
            if (this.currentObjectName == OppAPIName) {
                FIELDS_JS = [PRIMARY_CLINIC_LATITUDE, PRIMARY_CLINIC_LONGITUDE, SECONDARY_CLINIC_LATITUDE, SECONDARY_CLINIC_LONGITUDE, SECONDARY_CLINIC_STREET, SECONDARY_CLINIC_CITY, SECONDARY_CLINIC_STATE, this.currentObjectName.concat('.Check_In_Geolocation__Latitude__s'), this.currentObjectName.concat('.Check_In_Geolocation__Longitude__s'), this.currentObjectName.concat('.Check_In_Time__c'), this.currentObjectName.concat('.Check_Out_Time__c'), this.currentObjectName.concat('.Check_In_Count__c')];
                console.log('Fields ' + FIELDS_JS);
            }
            else if (this.currentObjectName == accountAPIName) {
                FIELDS_JS = [this.currentObjectName.concat('.Check_In_Geolocation__Latitude__s'), this.currentObjectName.concat('.Check_In_Geolocation__Longitude__s'), this.currentObjectName.concat('.BillingLatitude'), this.currentObjectName.concat('.BillingLongitude'), this.currentObjectName.concat('.ShippingLatitude'), this.currentObjectName.concat('.ShippingLongitude'), this.currentObjectName.concat('.Check_In_Time__c'), this.currentObjectName.concat('.Check_Out_Time__c'), this.currentObjectName.concat('.Check_In_Count__c'), this.currentObjectName.concat('.ShippingStreet')];
                console.log('Fields ' + FIELDS_JS);
            }
        }

        console.log('connectedCallback Exit');
    }

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS_JS })
    wiredRecordFun({ error, data }) {
        console.log('Wired Function Invoked');
        this.displayCheckInBtnWithoutGeolocationCaptured = false;
        this.displayCheckInBtn = false;
        this.displayCheckOutBtn = false;
        this.displaySelectAddresRG = false;
        this.displaySetLocationNCheckInBtn = false;
        this.displayMsgBanner = false;
        this.displayPageLoader = false;
        if (data) {
            //fetch the field values -Start
            console.log('Data returned  Success');
            console.log('Data returned  Success lavanya==========================='+JSON.stringify(data));

            this.currentRecord = data;
             console.log('Data current record  Success lavanya==========================='+JSON.stringify(this.currentRecord));
            this.currentError = undefined;
            this.currentRecCheckInTime = this.currentRecord.fields.Check_In_Time__c.value;
            this.currentRecCheckOutTime = this.currentRecord.fields.Check_Out_Time__c.value;
            this.currentRecCheckInCount = this.currentRecord.fields.Check_In_Count__c.value;
            console.log('currentRecCheckInTime data '+ this.currentRecCheckInTime);
            if (this.currentObjectName == OppAPIName) {
                console.log('Inside Opportunity Record');
                this.currentRecPrimaryLatitude = getFieldValue(this.currentRecord, PRIMARY_CLINIC_LATITUDE);
                this.currentRecPrimaryLongitude = getFieldValue(this.currentRecord, PRIMARY_CLINIC_LONGITUDE);
                this.currentRecSecondaryLatitude = getFieldValue(this.currentRecord, SECONDARY_CLINIC_LATITUDE);
                this.currentRecSecondaryLongitude = getFieldValue(this.currentRecord, SECONDARY_CLINIC_LONGITUDE);
                this.currentRecSecondaryStreet = getFieldValue(this.currentRecord, SECONDARY_CLINIC_STREET);
                this.currentRecSecondaryCity = getFieldValue(this.currentRecord, SECONDARY_CLINIC_CITY);
                this.currentRecSecondaryState = getFieldValue(this.currentRecord, SECONDARY_CLINIC_STATE);
                //this.currentRecSecondaryPostalCode = getFieldValue(this.currentRecord, SECONDARY_CLINIC_POSTALCODE);
                //this.currentRecSecondaryCountry = getFieldValue(this.currentRecord, SECONDARY_CLINIC_COUNTRY);

            }
            else if (this.currentObjectName == accountAPIName) {
                console.log('Inside Account Record');
                this.currentRecPrimaryLatitude = this.currentRecord.fields.BillingLatitude.value;
                this.currentRecPrimaryLongitude = this.currentRecord.fields.BillingLongitude.value;
                this.currentRecSecondaryLatitude = this.currentRecord.fields.ShippingLatitude.value;
                this.currentRecSecondaryLongitude = this.currentRecord.fields.ShippingLongitude.value;
                this.currentRecSecondaryStreet = this.currentRecord.fields.ShippingStreet.value;
            }
            console.log('this.currentRecPrimaryLatitude '+ this.currentRecPrimaryLatitude + 'this.currentRecPrimaryLongitude '+ this.currentRecPrimaryLongitude);
            console.log('this.currentRecSecondaryLatitude '+ this.currentRecSecondaryLatitude + 'this.currentRecSecondaryLongitude '+ this.currentRecSecondaryLongitude);

            this.currentRecPrimaryCheckInLatitude = this.currentRecord.fields.Check_In_Geolocation__Latitude__s.value;
            this.currentRecPrimaryCheckInLongitude = this.currentRecord.fields.Check_In_Geolocation__Longitude__s.value;
            //fetch the field values - End
            //Requirement Handling - Start
            //Need to find the alternative 
            try {
                console.log('Inside outer try block');
                if (navigator && navigator.geolocation) {
                    console.log('Inside navigator and geolocation');
                    navigator.geolocation.getCurrentPosition(success => {
                        try {
                            if (success) {
                              //  if(this.checkInTimeRecord == null || this.checkInTimeRecord == undefined){
                                this.setVariablesCheckIn(success);
                                this.locationEnabled=true;
                             //   }else if(this.checkInTimeRecord != null || this.checkInTimeRecord != undefined 
                              //      && this.checkOutTime != undefined){
                              //      this.displayCheckOutBtn = true;
                             //   }
                            }                           
                        }
                        catch (err) {
                            console.log('@@@' + err && err.message ? err.message : 'Error');
                            alert(err && err.message ? err.message : 'Error occured');
                            this.displayCheckInBtnWithoutGeolocationCaptured = false;
                            this.displayMsgBanner = true;
                            this.displayCheckInBtn = false;
                            this.displayCheckOutBtn = false;
                            this.displaySelectAddresRG = false;
                            this.displaySetLocationNCheckInBtn = false;
                            this.displayMsg = '111Your device is unable to capture your current location. Please contact your System Admin.';
                        }
                        finally {
                           console.log('Finally Executed :: First');

                        }

                    }), (error => {
                        try {
                            console.log('@@@' + error && error.message ? error.message : 'Error');
                            alert(error && error.message ? error.message : 'Error occured');
                            this.displayCheckInBtnWithoutGeolocationCaptured = false;
                            this.displayMsgBanner = true;
                            this.displayCheckInBtn = false;
                            this.displayCheckOutBtn = false;
                            this.displaySelectAddresRG = false;
                            this.displaySetLocationNCheckInBtn = false;
                            this.displayMsg = '2222Your device is unable to capture your current location. Please contact your System Admin.';
                            this.locationEnabled=false;
                        }
                        catch (err) {
                            console.log('@@@' + err && err.message ? err.message : 'Error');
                            alert(err && err.message ? err.message : 'Error occured');
                            this.displayCheckInBtnWithoutGeolocationCaptured = false;
                            this.displayMsgBanner = true;
                            this.displayCheckInBtn = false;
                            this.displayCheckOutBtn = false;
                            this.displaySelectAddresRG = false;
                            this.displaySetLocationNCheckInBtn = false;
                            this.displayMsg = '333Your device is unable to capture your current location. Please contact your System Admin.';
                            this.locationEnabled=false;
                        }
                        finally {
                            console.log('Finally Executed :: Second');
                            if (!this.locationEnabled) {
                                this.displayCheckInBtnWithoutGeolocationCaptured = false;
                                this.displayMsgBanner = true;
                                this.displayMsg = '444Your device is unable to capture your current location. Please contact your System Admin.';
                            }

                        }
                    }), {
                        enableHighAccuracy: true,
                        timeout: 10000,
                        maximumAge: 0
                    };
                }
                else {
                    alert(error && error.message ? error.message : 'Error occured');
                    console.log('location disabled');
                    this.displayCheckInBtnWithoutGeolocationCaptured = false;
                    this.displayMsgBanner = true;
                    this.displayCheckInBtn = false;
                    this.displayCheckOutBtn = false;
                    this.displaySelectAddresRG = false;
                    this.displaySetLocationNCheckInBtn = false;
                    this.displayMsg = '555Your device is unable to capture your current location. Please contact your System Admin.';
                    this.locationEnabled=false;
                    
                }
            }
            catch (err) {
                console.log('@@@' + err && err.message ? err.message : 'Error');
                alert(err && err.message ? err.message : 'Error occured');
                this.currentError = err.message;
                this.displayCheckInBtnWithoutGeolocationCaptured = false;
                this.displayMsgBanner = true;
                this.displayCheckInBtn = false;
                this.displayCheckOutBtn = false;
                this.displaySelectAddresRG = false;
                this.displaySetLocationNCheckInBtn = false;
                this.displayMsg = '666Your device is unable to capture your current location. Please contact your System Admin.';
                this.locationEnabled=false;
            }
            finally {
                console.log('Finally Executed :: Second');
                if (!this.locationEnabled) {
                    console.log('currentRecCheckInTime '+ this.currentRecCheckInTime);
                    if(this.currentRecCheckInTime == null){
                        this.displayMsgBanner = true;
                    this.displayMsg = 'Your device is unable to capture your current location. You still can Check_In.';
                        this.displayCheckInBtnWithoutGeolocationCaptured = true;
                    }else if(this.currentRecCheckInTime != null && this.currentRecCheckOutTime == null){
                        this.displayCheckOutBtn = true;
                        this.displayCheckInBtnWithoutGeolocationCaptured = false;
                    }
                }
            }


        } else if (error) {

            console.log('No Data returned - enterted in  error :::::' + error);
        }
        console.log('Wired Function Exit');
    }

    setVariablesCheckIn(success) {
        // Get the Latitude and Longitude from Geolocation API
        try{
        this.userLatitude = success.coords.latitude;
        this.userLongitude = success.coords.longitude;
        console.log('The Current latitude is :::' + this.userLatitude);
        console.log('The Current longitude is :::' + this.userLongitude);
        if (this.userLatitude != null && this.userLongitude != null && this.userLatitude != undefined && this.userLongitude != undefined) {
         console.log('lavanya===================='+this.currentRecPrimaryLatitude);
            if ((this.currentRecPrimaryLatitude == null || this.currentRecPrimaryLatitude == undefined) || (this.currentRecPrimaryLongitude == null || this.currentRecPrimaryLongitude == undefined)) {
                if ((this.currentRecPrimaryCheckInLatitude == null || this.currentRecPrimaryCheckInLatitude == undefined) || (this.currentRecPrimaryCheckInLongitude == null || this.currentRecPrimaryCheckInLongitude == undefined)) {
                    this.displayMsgBanner = true;
                    this.displaySetLocationNCheckInBtn = true;
                    this.displayCheckOutBtn = false;
                    this.displayCheckInBtn = false;
                    this.displaySelectAddresRG = false;
                    this.displayPageLoader = false;
                    this.displayCheckInBtnWithoutGeolocationCaptured = false;
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
                        this.displayPageLoader = false;
                        this.displayCheckInBtnWithoutGeolocationCaptured = false;
                        this.displayMsg = 'Last geolocation of clinic does not  match with your current location. Reset your current location as clinic geolocation.Do update the address after check In - WITHOUT FAIL ';
                    }
                    else {
                        if ((this.currentRecCheckInTime == null || this.currentRecCheckInTime == undefined) && (this.currentRecCheckOutTime == null || this.currentRecCheckOutTime == undefined)) {
                            this.displayCheckInBtn = true;
                            this.displayMsgBanner = true;
                            this.displaySetLocationNCheckInBtn = false;
                            this.displayCheckOutBtn = false;
                            this.displaySelectAddresRG = false;
                            this.displayPageLoader = false;
                            this.displayCheckInBtnWithoutGeolocationCaptured = false;
                            this.displayMsg = 'Do update the address after check In - WITHOUT FAIL ';
                        }
                        else if ((this.currentRecCheckInTime != null && this.currentRecCheckInTime != undefined) && (this.currentRecCheckOutTime == undefined || this.currentRecCheckOutTime == null)) {
                            this.displayCheckOutBtn = true;
                            this.displayCheckInBtn = false;
                            this.displayMsgBanner = false;
                            this.displaySelectAddresRG = false;
                            this.displaySetLocationNCheckInBtn = false;
                            this.displayPageLoader = false;
                            this.displayCheckInBtnWithoutGeolocationCaptured = false;
                        }
                    }
                }
            }

            else if (
                (this.currentRecPrimaryLatitude != null && this.currentRecPrimaryLatitude != undefined) && (this.currentRecPrimaryLongitude != null && this.currentRecPrimaryLongitude != undefined)
                &&
                (this.currentRecSecondaryStreet == null || this.currentRecSecondaryStreet == undefined)
            ) {
                this.distanceToClinicByAddress = this.geoDistance(this.userLatitude, this.userLongitude, this.currentRecPrimaryLatitude, this.currentRecPrimaryLongitude);
                console.log('Allowed Distance :: ' + allowedRadiusLabel + '::: Actual Distance::: ' + this.distanceToClinicByAddress);
                if (this.distanceToClinicByAddress > allowedRadiusLabel) {
                    this.displayCheckInBtnWithoutGeolocationCaptured = false;
                    this.displayMsgBanner = true;
                    this.displayCheckOutBtn = false;
                    this.displayCheckInBtn = false;
                    this.displaySetLocationNCheckInBtn = false;
                    this.displayMsg = 'Not allowed to Check In from current location';
                }
                else {
                    if ((this.currentRecCheckInTime == null || this.currentRecCheckInTime == undefined) && (this.currentRecCheckOutTime == null || this.currentRecCheckOutTime == undefined)) {
                        console.log('Inside No checkin Time');
                        this.displayCheckInBtn = true;
                        this.displayMsgBanner = false;
                        this.displayCheckOutBtn = false;
                        this.displaySelectAddresRG = false;
                        this.displaySetLocationNCheckInBtn = false;
                        this.displayCheckInBtnWithoutGeolocationCaptured = false;
                    }
                    else if ((this.currentRecCheckInTime != null && this.currentRecCheckInTime != undefined) && (this.currentRecCheckOutTime == undefined || this.currentRecCheckOutTime == null)) {
                        this.displayCheckOutBtn = true;
                        this.displayCheckInBtn = false;
                        this.displayMsgBanner = false;
                        this.displaySelectAddresRG = false;
                        this.displaySetLocationNCheckInBtn = false;
                        this.displayCheckInBtnWithoutGeolocationCaptured = false;
                    }
                }
            }
            else if (
                (this.currentRecPrimaryLatitude != null || this.currentRecPrimaryLatitude != undefined) && (this.currentRecPrimaryLongitude != null || this.currentRecPrimaryLongitude != undefined)
                &&
                (this.currentRecSecondaryStreet != null || this.currentRecSecondaryStreet != undefined)
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
                    this.displaySetLocationNCheckInBtn = false;
                    this.displayCheckInBtnWithoutGeolocationCaptured = false;
                }
                else if ((this.currentRecCheckInTime != null && this.currentRecCheckInTime != undefined) && (this.currentRecCheckOutTime == undefined || this.currentRecCheckOutTime == null)) {
                    this.displayCheckOutBtn = true;
                    this.displayCheckInBtn = false;
                    this.displayMsgBanner = false;
                    this.displaySelectAddresRG = false;
                    this.displaySetLocationNCheckInBtn = false;
                    this.displayCheckInBtnWithoutGeolocationCaptured = false;
                }
            }
        }
        else {
            this.displayMsgBanner = true;
            this.displayCheckInBtn = false;
            this.displayMsgBanner = false;
            this.displayCheckOutBtn = false;
            this.displaySelectAddresRG = false;
            this.displaySetLocationNCheckInBtn = false;
            this.displayCheckInBtnWithoutGeolocationCaptured = false;
            this.displayMsg = 'Your Geolocation not captured, please refresh the page.';
        }
    }
        catch(err)
        {
               console.log('@@@' + err && err.message ? err.message : 'Error');
                alert(err && err.message ? err.message : 'Error occured');
                this.displayMsgBanner = true;
                this.displayCheckInBtn = false;
                this.displayCheckOutBtn = false;
                this.displaySelectAddresRG = false;
                this.displaySetLocationNCheckInBtn = false;
                this.displayCheckInBtnWithoutGeolocationCaptured = false;
                this.displayMsg = 'System error occured, please check all the required values are provided in the record.';

        }
}

    //Handle Component Event - start
    handleCheckIn(event) {
        this.createCheckInrecord();
    }

    handleSetGeolocationNCheckIn(event) {
        this.createCheckInrecord();
      //  this.displayCheckInBtn = true;
    }

    createCheckInrecord(){
        console.log('Inside createCheckInrecord');
        const fields = {};
        if (this.currentObjectName == OppAPIName) {
        fields['Opportunity__c'] = this.recordId;
        }else{
            fields['Go_Live_Doctor__c'] = this.recordId;
        }
        fields['Check_In_Time__c'] = new Date().toISOString();
        fields['Check_In_Geolocation__Latitude__s'] = this.userLatitude;
        fields['Check_In_Geolocation__Longitude__s'] = this.userLongitude;
        const recordInput = { apiName: CLINIC_CHECK_IN_OBJECT.objectApiName, fields };

        console.log('@@ create record metadata  '+ JSON.stringify(recordInput) );

        createRecord(recordInput)
        .then(data =>{
            console.log(' data ' + JSON.stringify(data));
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Check In Time Recorded successfully.',
                    variant: 'success',
                }),
            );
            this.displayCheckInBtn = true;
            return refreshApex(this.currentRecord);              
        })
        .catch(error => {
            console.log(JSON.stringify(error.body.message));
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error while creating record',
                    message: error.body.message,
                    variant: 'error',
                }),
            );
        });       
    }

    handleAddressSelection(event) {
        console.log('Inside handleAddressSelection');
        if (event.target.value === 'primaryClinic') {
            if (this.distanceToClinicByAddress > allowedRadiusLabel) {
                this.displayMsgBanner = true;
                this.displayMsg = 'Not allowed to Check In from current location';
                this.displayCheckInBtnWithoutGeolocationCaptured = false;
                return;
            }
        }
        else if (event.target.value === 'secondaryClinic') {
            if ((this.currentRecSecondaryLatitude != null || this.currentRecSecondaryLatitude != undefined) && (this.currentRecSecondaryLongitude != null || this.currentRecSecondaryLongitude != undefined) && (this.distanceToSecondaryClinic > allowedRadiusLabel)) {
                this.displayMsgBanner = true;
                this.displayMsg = 'Not allowed to Check In from current location';
                this.displayCheckInBtnWithoutGeolocationCaptured = false;
                return;
            }

        }
        else if (event.target.value == undefined) {
            return;
        }
        const fields = {};
        if (this.currentObjectName == OppAPIName) {
            fields['Opportunity__c'] = this.recordId;
            }else{
                fields['Go_Live_Doctor__c'] = this.recordId;
            }
            fields['Check_In_Time__c'] = new Date().toISOString();
            fields['Check_In_Geolocation__Latitude__s'] = this.userLatitude;
            fields['Check_In_Geolocation__Longitude__s'] = this.userLongitude;
            // Mahesh Reddy - Adding if condition to make primary check in values as false for secondary clinic
            if (event.target.value === 'secondaryClinic'){
                fields['Primary_Address_CheckIN__c'] = false;
            }
            const recordInput = { apiName: CLINIC_CHECK_IN_OBJECT.objectApiName, fields };

        createRecord(recordInput)
        .then(data =>{
            console.log(' data ' + JSON.stringify(data));
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Check In Time Recorded successfully.',
                    variant: 'success',
                }),
            );
            this.displayCheckInBtn = true;
            return refreshApex(this.currentRecord);              
        })
        .catch(error => {
            console.log(JSON.stringify(error.body.message));
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error while creating record',
                    message: error.body.message,
                    variant: 'error',
                }),
            );
        });  
        
       /* updateRecord(recordInput)
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
            });*/
    }

    handleCheckInWithoutGeolocation(event){
        console.log('Inside handleCheckInWithoutSetGeolocation');
        const fields = {};
       if (this.currentObjectName == OppAPIName) {
        fields['Opportunity__c'] = this.recordId;
        }else{
            fields['Go_Live_Doctor__c'] = this.recordId;
        }
        fields['Check_In_Time__c'] = new Date().toISOString();
        console.log('block location fields'+ JSON.stringify(fields));
        const recordInput = { apiName: CLINIC_CHECK_IN_OBJECT.objectApiName, fields };
        console.log('block location '+ JSON.stringify(recordInput));
        createRecord(recordInput)
        .then(data =>{
            console.log(' data ' + JSON.stringify(data));
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Check In Time Recorded successfully.',
                    variant: 'success',
                }),
            );
            return refreshApex(this.currentRecord);              
        })
        .catch(error => {
            console.log(JSON.stringify(error.body.message));
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error while creating record',
                    message: error.body.message,
                    variant: 'error',
                }),
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
        console.log('uLatitude, uLongitude, recLatitude, recLongitude:::' + uLatitude + '::' + uLongitude + '::' + recLatitude + '::' + recLongitude);

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