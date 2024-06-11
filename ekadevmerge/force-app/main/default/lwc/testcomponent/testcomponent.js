import ekaPayment from '@salesforce/apex/EkaPaymentController.PaymentRecord';
import currentRecordType from '@salesforce/apex/EkaPaymentController.methodName1';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { LightningElement, api, track, wire } from 'lwc';

export default class testcomponent extends LightningElement {
    @track isFormVisible = false;
    @wire(ekaPayment)
    yourApexWireAdapter;
    @api recordId;
    leadRecord;
    @track alldata;
    //test;
    @track ekaPlusVal=false;
    @track ekaProVal=false;
    @track ekaPremiumVal=false;
    @track ekaPremiumPlusVal=false;
    @track specificValue1;
    @track specificValue2;
    @track specificValue3;
    @track specificValue4;

   
    @wire(currentRecordType, { leadId: '$recordId' })
    leadDetails({ error, data }) {
        if (data) {
          this.leadRecord = data.RecordType.Name;
          this.alldata = data;
          console.log('all data------'+alldata);
          this.handleSpecificValues();
         // this.test = data.Subscription_Plan__c;
          this.error = undefined;
          //alert(this.leadRecord.RecordType.Name);
        } else if (error) {
          this.error = error;
          this.contacts = undefined;
        }
      }

    saveHandler() {
        //alert(this.leadDetails.RecordType.Name);
        if(this.isInputValid()){
        this.template.querySelector('lightning-record-edit-form').submit();
    
        //alert(this.recordId);
    }
    else{
        const toastEvent = new ShowToastEvent({
            title: 'Error',
            message: 'Please fill the Required Fields',
            variant: 'error',
        });
        this.dispatchEvent(toastEvent);
    }
}
    handleSuccess() {
        // Show a toast message
        const toastEvent = new ShowToastEvent({
            title: 'Success',
            message: 'Record created successfully',
            variant: 'success',
        });
        this.dispatchEvent(toastEvent);
        this.dispatchEvent(new CloseActionScreenEvent());

    }

    isInputValid(){
        let isValid=true;
        let inputFields = this.template.querySelectorAll('.validate');
        inputFields.forEach(inputField =>{
            if(!inputField.value){
                //inputField.reportValidity();
                isValid=false;
            }
           // this.contact[inputField.name]=inputField.value;
        });
        return isValid;
   }
    
   onchangeevent(event){
    const selectedValue = event.target.value;
    if(selectedValue === 'Eka Plus'){
        this.ekaPlusVal = true;
        this.ekaProVal = false;
        this.ekaPremiumVal = false;
        this.ekaPremiumPlusVal = false;
    }else if(selectedValue === 'Eka Pro'){   
        this.ekaPlusVal = false;
        this.ekaProVal = true;
        this.ekaPremiumVal = false;
        this.ekaPremiumPlusVal = false;
    }else if(selectedValue === 'Eka Premium'){
        this.ekaProVal = false;
        this.ekaPlusVal = false;
        this.ekaPremiumVal = true;
        this.ekaPremiumPlusVal = false;
    }else if(selectedValue === 'Eka Premium Plus'){
        this.ekaProVal = false;
        this.ekaPlusVal = false;
        this.ekaPremiumVal = false;
        this.ekaPremiumPlusVal = true;
    }
   }
  /* handleSpecificValues() {
    // Assume 'ValueToFetch' is the specific value you want to fetch from each picklist
    this.specificValue1 = this.alldata.Amount_of_Eka_Plus__c === 'ValueToFetch' ? 'ValueToFetch' : null;
    this.specificValue2 = this.alldata.Amount_of_Eka_Pro__c === 'ValueToFetch' ? 'ValueToFetch' : null;
    this.specificValue3 = this.alldata.Amount_of_Eka_Premium__c === 'ValueToFetch' ? 'ValueToFetch' : null;
    this.specificValue4 = this.alldata.Amount_of_Eka_Premium_Plus__c === 'ValueToFetch' ? 'ValueToFetch' : null;

    // Perform logic based on the specific values
    // For example:
    if (this.specificValue1) {
        // Handle scenario for specificValue1
    }
}*/

}