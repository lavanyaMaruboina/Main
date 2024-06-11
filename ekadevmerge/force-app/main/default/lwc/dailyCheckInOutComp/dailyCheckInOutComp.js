import { refreshApex } from '@salesforce/apex';
import updatedetails from '@salesforce/apex/OpportunityLocationController.getTopleads';
import getCurrentUserDailyCheckInId from '@salesforce/apex/getSystemCheckInRecord.getCurrentUserDailyCheckInId';
import SYSTEM_CHECK_IN_OBJECT from '@salesforce/schema/System_Check_In__c';
import PROFILE_NAME from '@salesforce/schema/User.Profile.Name';
import Id from '@salesforce/user/Id';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { createRecord, getRecord, updateRecord } from 'lightning/uiRecordApi';
import { LightningElement, track, wire } from 'lwc';

export default class DailyCheckInOutComp extends LightningElement {

    @track userLatitude;
    @track userLongitude;
    @track userId;
    @track displayCheckInBtnFlag = true;
    @track displayDailyCheckInBtn = false;
    @track displayDailyCheckOutBtn = false;
    @track displayMessage='';
    // isShowModal=false;
    // @api records;
    // @api error;
    // @track demoCount;
    // @track paymentsCount;
    // @track callCount;
    // @track isModalOpen = false;

    @track isModalOpen = false;
    @track demoCount;
    @track paymentsCount;
    @track callCount;
    @track records;
    @track error;
   
    @track checkInTime;
    @track checkOutTime;
    @track CheckInRecordId;
    @track profileName;
    @track profileDetails;

    @wire(getRecord, {
        recordId: Id,
        fields: [PROFILE_NAME]
    }) wireuser({
        error,
        data
    }) {
        if (error) {
            console.log('@@@@@error '  + error);
        } else if (data) {
            this.profileDetails = data.fields.Profile.value;
            this.profileName = this.profileDetails.fields.Name.value;
        }
    }

    connectedCallback(){

        if (navigator.geolocation) {
            navigator.geolocation.getCurrentPosition(position => {
   
                // Get the Latitude and Longitude from Geolocation API
                this.userLatitude = position.coords.latitude;
                this.userLongitude = position.coords.longitude;
            });
        }
        
        this.displayCheckInBtnFlag = false;
        this.displayDailyCheckInBtn = false;
        this.displayDailyCheckOutBtn = false;
        this.displayMessage='';

        getCurrentUserDailyCheckInId()
            .then((data) => {
                if(data){
                    if(data.Check_In_Time__c !=null && data.Check_Out_Time__c != null){
                        this.displayCheckInBtnFlag = true;
                        this.displayMessage='Your Daily Check IN/OUT  time logged successfully. Check In Time  ::: '+data.Check_In_Time__c +' Check Out Time ::: ' +data.Check_Out_Time__c;
                        console.log('Display Message :::'+ this.displayMessage);
                    }else if(data.Check_In_Time__c !=null && data.Check_Out_Time__c == null){
                    this.CheckInRecordId = data.Id;
                    this.displayDailyCheckOutBtn = true;
                    this.displayCheckInBtnFlag = true;  
                                       
             /*______________ Calculation ________________________*/ 

             const current = new Date();
             let end = new Date(data.Check_In_Time__c);
            let diff = current.getTime() - end.getTime();
            let hours = Math.floor(diff / 1000 / 60 / 60);
            diff -= hours * 1000 * 60 * 60;
            let minutes = Math.floor(diff / 1000 / 60);
            console.log(hours + " hours " + minutes + " minutes ");

            /*______________ Calculation ________________________*/ 
                   
            this.displayMessage='Today you checked in at :: '+ end +  ' Session time is :: ' + hours + " hours " + minutes + " minutes "; //new Date();  //(new Date()- data.Check_In_Time__c);        
        }
                }else{
                    this.displayDailyCheckInBtn = true;
                    this.displayCheckInBtnFlag = false;
                }
            })
            .catch(error => {
            });
    }

    handleDailyCheckIn(event) {
    
        updatedetails()
            .then(result => {
                this.demoCount = result.DemoCount;
                this.paymentsCount = result.PaymentsCount;
                this.callCount = result.CallCount;
                this.isModalOpen = true;
            })
            .catch(error => {
                // Handle any errors
                console.error(error);
            });
            this.displayDailyCheckInBtn = false;
            this.displayDailyCheckOutBtn = true;

            this.userId = Id;
            this.checkInTime = new Date().toISOString();

            if(this.userId){
                this.createSystemCheckInRecord();
                }
            }
        hideModalBox(event){
          this.isModalOpen = false;
        }
        //  updatedetails()
        //     .then(result=>{
        //         this.records=result;
        //         console.log('this.records========='+this.records);
        //         this.error=undefined;
        //     })
        //     .catch(error=>{
        //         this.error=error;
        //         this.records=undefined;
        //     });

        // @wire(updatedetails) accountresponse({data , error}){
        //     if(data)
        //     {
        //         this.records=data;
        //         console.log(JSON.stringify(this.records));
        //         //this.accounts=data;
        //         this.error=null;
        //     }
        //     else if(error)
        //     {
        //         this.records=null;
        //         this.error=error;
        //     }
        // }
//=============================================================================================================
//         handleDailyCheckIn(event) {
//             // Fetch data for demoCount, paymentsCount, and callCount
//             updatedetails()
//                 .then(result => {
//                     this.demoCount = result.DemoCount;
//                     this.paymentsCount = result.PaymentsCount;
//                     this.callCount = result.CallCount;
//                     this.isModalOpen = true;
//                 })
//                 .catch(error => {
//                     // Handle any errors
//                     console.error(error);
//                 });
    
//             // Fetch additional records data
//             updatedetails()
//                 .then(result => {
//                     this.records = result;
//                     this.error = undefined;
//                 })
//                 .catch(error => {
//                     this.error = error;
//                     this.records = undefined;
//                 });
//         }
    
//         @wire(updatedetails)
//         accountresponse({ data, error }) {
//             if (data) {
//                 this.records = data;
//                 this.error = null;
//             } else if (error) {
//                 this.records = null;
//                 this.error = error;
//             }    
//         this.displayDailyCheckInBtn = false;
//         this.displayDailyCheckOutBtn = true;
//             this.userId = Id;
//             this.checkInTime = new Date().toISOString();

//             if(this.userId){
//                 this.createSystemCheckInRecord();
//                 }
//   }

  createSystemCheckInRecord(){

    const fields = {};
        fields['Check_In_Geolocation__Latitude__s']= this.userLatitude;
        fields['Check_In_Geolocation__Longitude__s']= this.userLongitude;
        fields['User__c']= this.userId;
        fields['Check_In_Time__c'] = this.checkInTime;
        fields['User_Profile__c'] = this.profileName;

    const recordInput = { apiName: SYSTEM_CHECK_IN_OBJECT.objectApiName, fields };
   
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
            return refreshApex();  
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

//    handleDailyCheckOut(event){

//     if(this.CheckInRecordId){

//     const fields = {};
//     fields['Id'] = this.CheckInRecordId;
//     fields['Check_Out_Time__c'] = new Date().toISOString();
//     fields['Check_Out_Geolocation__Latitude__s'] = this.userLatitude;
//     fields['Check_Out_Geolocation__Longitude__s'] = this.userLongitude;
//     const recordInput = { fields };
   
//     updateRecord(recordInput)
//         .then((record) => {
//             console.log('record ' + JSON.stringify(record));
//             this.dispatchEvent(
//                 new ShowToastEvent({
//                     title: 'Success',
//                     message: 'Check Out Time Recorded Successfully.',
//                     variant: 'success'
//                 })
//             );
//         })
//         .catch(error => {
//             this.dispatchEvent(
//                 new ShowToastEvent({
//                     title: 'Error creating record',
//                     message: error.body.message,
//                     variant: 'error'
//                 })
//             );
//         });
//         this.displayDailyCheckOutBtn = false;
//         this.displayCheckInBtnFlag = true;
//     }else{

//     }
//   }
handleDailyCheckOut(event) {
    try {
        if (this.CheckInRecordId) {
            // ... (existing code)
            const fields = {};
    fields['Id'] = this.CheckInRecordId;
    fields['Check_Out_Time__c'] = new Date().toISOString();
    fields['Check_Out_Geolocation__Latitude__s'] = this.userLatitude;
    fields['Check_Out_Geolocation__Longitude__s'] = this.userLongitude;
    const recordInput = { fields };
            updateRecord(recordInput)
                .then((record) => {
                    console.log('Record updated successfully:', JSON.stringify(record));
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'Check Out Time Recorded Successfully.',
                            variant: 'success'
                        })
                    );
                })
                .catch(error => {
                    console.error('Error updating record:', JSON.stringify(error));
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error updating record',
                            message: error.body.message,
                            variant: 'error'
                        })
                    );
                });
                this.displayDailyCheckOutBtn = false;
                this.displayCheckInBtnFlag = true;
            // ... (existing code)
        } else {
            // ... (existing code)
        }
    } catch (ex) {
        console.error('Exception in handleDailyCheckOut:', ex);
    }
}

}