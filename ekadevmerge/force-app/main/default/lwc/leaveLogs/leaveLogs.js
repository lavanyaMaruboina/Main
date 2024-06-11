import { LightningElement, track,wire } from 'lwc';
import saveLeaveLogRecord from '@salesforce/apex/LeaveLogController.saveLeaveLogRecord';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';

export default class leaveLogs  extends LightningElement {
    @track startDate;
    @track endDate;
    @track Reason;
    @track isFormVisible = false;
    @wire(saveLeaveLogRecord, { startDate: '$startDate', endDate: '$endDate',Reason:'Reason' })
    saveLeaveResult;

    handleStartDateChange(event) {
        this.startDate = event.target.value;
    }
    
    handleEndDateChange(event) {
        this.endDate = event.target.value;
    }
    handleReasonChange(event){
        this.Reason=event.target.value;
    }
    // Other form fields and methods go here
   showForm(){
        this.isFormVisible=true;
    }

    saveLeaveLog() {

          // Validate start date and end date
    if (!this.startDate || !this.endDate || !this.Reason ) {
        // Show an error toast if start date or end date is not provided
        const errorToastEvent = new ShowToastEvent({
            title: 'Error',
            message: 'Please enter start date ,end date and Reason',
            variant: 'error',
        });
        this.dispatchEvent(errorToastEvent);
        return;
    }
        // Implement your logic to save the leave log record
        // You may want to call an Apex method to handle the record creation
        
        console.log("start date"+this.startDate);
        console.log("end date"+this.endDate);
        console.log("Reason"+this.Reason);

        saveLeaveLogRecord({startDate: this.startDate, endDate: this.endDate,Reason: this.Reason })
            .then(result => {
                // Handle success
                console.log('Leave Log record saved: ', result);
                this.isFormVisible = false; // Hide the form after saving
               
                                // Show success toast message
                                const toastEvent = new ShowToastEvent({
                                    title: 'Success!',
                                    message: "Leave request submitted", // Use the response message from Apex
                                    variant: 'success',
                                });
                                this.dispatchEvent(toastEvent);
                             return refreshApex(this.saveLeaveResult);
            })
            .catch(error => {
                // Handle error
                console.error('Error saving Leave Log record: ', error);
            });
    }
    // cancelLeaveLog()
    // {
    //     this.startDate="";
    //     this.endDate="";
    //     this.isFormVisible = false;
    // }
}