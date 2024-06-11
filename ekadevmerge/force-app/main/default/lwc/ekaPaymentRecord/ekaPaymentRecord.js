import ekaPayment from '@salesforce/apex/EkaPaymentController.PaymentRecord';
import currentRecordType from '@salesforce/apex/EkaPaymentController.methodName1';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { LightningElement, api, track, wire } from 'lwc';
 
export default class ekaPaymentRecord extends LightningElement {
    @track isFormVisible = false;
    @wire(ekaPayment)
    yourApexWireAdapter;
    @api recordId;
    leadRecord;
    discountRate;
    netAmount;
    netGSTAmount;
    //isAdmin;
    @track numberOfYears;
    //test;
    @track ekaPlusVal=false;
    @track ekaProVal=false;
    @track ekaPremiumVal=false;
    @track ekaPremiumPlusVal=false;
   
    @wire(currentRecordType, { leadId: '$recordId' })
    leadDetails({ error, data }) {
        if (data) {
          this.leadRecord = data.RecordType.Name;
         // this.test = data.Subscription_Plan__c;
          this.error = undefined;
          //alert(this.leadRecord.RecordType.Name);
        } else if (error) {
          this.error = error;
          this.contacts = undefined;
        }
      }
      // @wire(currentISUser)
      // userDetails({ error, data }) {
      //     if (data) {
      //       this.isAdmin = data;
      //     //alert(this.isAdmin);
      //      // this.test = data.Subscription_Plan__c;
      //       this.error = undefined;
      //       //alert(this.leadRecord.RecordType.Name);
      //     } else if (error) {
      //       this.error = error;
      //       this.isAdmin = undefined;
      //     }
      //   }
 
    saveHandler(event) {
        console.log('saveHandler');
       // alert(this.leadDetails.RecordType.Name);
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
        //alert('Lavanya>>>>>>');
        const toastEvent = new ShowToastEvent({
            title: 'Success',
            message: 'Record created successfully',
            variant: 'success',
        });
        this.dispatchEvent(toastEvent);
        this.dispatchEvent(new CloseActionScreenEvent());
 
    }
 
    isInputValid(){
      console.log('IsInputValidCalled');
        let isValid=true;
        let inputFields = this.template.querySelectorAll('.validate');
        inputFields.forEach(inputField =>{
            if(!inputField.value){
              console.log('InsideIfMethod');
                //inputField.reportValidity();
                isValid=false;
            }
           // this.contact[inputField.name]=inputField.value;
        });
        return isValid;
   }
 
   onchangeevent(event){
    this.discountRate=null;
    this.netAmount=null;
    this.netGSTAmount=null;
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
   // this.calculateGST();
    this.numberOfYears=null;
   }
   handleYears(){
    //this.calculateGST();
   }

handleDiscountChange(event) {
  
  // Get the entered amount value
  this.discountRate = parseFloat(event.target.value);
  //alert(this.isAdmin);

  console.log(this.discountRate);
  this.calculateGST();
  // const amountValue=this.template.querySelector('[data-id="Amount"]').value;
  // console.log('amount valuue>>>>'+amountValue);
  // if(amountValue){
    
  //   this.netAmount= parseFloat(amountValue)-(parseFloat(amountValue)*this.discountRate)/100;
  //   console.log('Net amount>>>>'+this.netAmount);
  //   this.netGSTAmount=this.netAmount+this.netAmount*18/100;
  // }
}
cancelHandler(event){
  this.dispatchEvent(new CloseActionScreenEvent());
}
calculateGST()
{
  const discount=this.template.querySelector('[data-id="Amount"]')
  if((this.discountRate!=undefined || this.discountRate!=null || this.discountRate!='') && discount){
  const amountValue=this.template.querySelector('[data-id="Amount"]').value;
  console.log('amount valuue>>>>'+amountValue);
  if(amountValue){
    
    this.netAmount= parseFloat(amountValue)-(parseFloat(amountValue)*this.discountRate)/100;
    console.log('Net amount>>>>'+this.netAmount);
    this.netGSTAmount=this.netAmount+this.netAmount*18/100;
  }
}

  }
}