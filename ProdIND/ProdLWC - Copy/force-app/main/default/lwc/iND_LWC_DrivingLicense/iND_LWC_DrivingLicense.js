import { LightningElement,api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import kycDelete from '@salesforce/apex/LwcLOSLoanApplicationCntrl.kycDelete';

export default class IND_LWC_DrivingLicense extends NavigationMixin(LightningElement) {
    get options() {
        return [
            { label: 'Is this a Photocopy?', value: 'option1' }
        ];
    }
// Start : Capture Image  Component Pop-UP on Upload Button

modalPopUpCaptureImage = false;

ImageLoad(){

    this.modalPopUpCaptureImage = true;

    

}

closeModal() {

    this.modalPopUpCaptureImage = false

}

// End : Capture Image Component Pop-UP on Upload Button    




//Added by Ruchi Jain
@api id='a0O71000000HDyXEAW';
   openCancelPopUP=false; //for opening/closing of QuitPop-up
   
   //handleCancel method for opening QuitPop-up
      handleCancel(){
         this.openCancelPopUP=true;
      }
      closepopup(){
         this.openCancelPopUP=false;
      }
//navigate
navigateToLightningComponent() {
    console.log("back");
    
    this.kycDeleteFields();
    this.closepopup();
      this[NavigationMixin.Navigate]({
         "type": "standard__component",
         "attributes": {
            
            "componentName": "c__AuraQuitPopUp"
         }
      });
      console.log("back");
     
}

      //kycDelete method for deleting document and fields
      kycDeleteFields(){
        console.log("here del");
    //     const nullvalue="";
    //   this.template.querySelector('lightning-input').value=nullvalue;
      this.template.querySelectorAll("lightning-input").forEach(item => {
        let fieldValue=item.value;
        let fieldLabel=item.label;            
        if(fieldValue){
            console.log("printinh "+item.value);
            item.value="";
            console.log("printinh after "+item.value);

        }
      });
        kycDelete({LoanApplicationId: this.id})
         .then(result => {
            console.log("here2");
         })
         .catch(error => {
            this.error = error;
            console.log(this.error);
            console.log("error came");
            
         });
      }
      doneDisable=true;//disabling done button
      fieldPopulated;//Flag for Populated fields
      flag=0;
    changeEvent(){
        if(this.template.querySelector('.Golden-Source').disabled==true && this.template.querySelector('.Doc-Auth').disabled==true)
        {
          console.log("All disabled");
            //For checking null fields
          this.template.querySelectorAll("lightning-input").forEach(item => {
              let fieldValue=item.value;
              let fieldLabel=item.label;            
              if(!fieldValue){
                  item.setCustomValidity('Please Enter '+fieldLabel);
                  this.fieldPopulated=false;//flag for fields(null)
                  this.flag=0;
                  console.log("not filled");
              }
              else{
                  item.setCustomValidity("");
                  this.fieldPopulated=true;//flag for fields(not null)
                  this.flag= this.flag+1;
                   console.log(" filled"+ this.flag);
              }
              item.reportValidity();
          });
          console.log("done button");
  
          //Checking for expiry date
        //   if(this.template.querySelector('DL').getTime<Today.getTime+30)
        //   {
        //       const evt = new ShowToastEvent({
        //       title: 'Error',
        //       message: 'Please recapture alternate KYC by clicking on Cancel',
        //       variant: 'error',
        //    });
        //    this.dispatchEvent(evt);
        //    }
           //enabling done button
           if(  this.flag==14){
            console.log("14");
            this.doneDisable=false;
           }
  
           //this.navigateToLightningComponent();//to navigate to Loan application
        }
    }
   handleDone(){
    console.log("here done");
    
    //Checking if Golden-Source, Doc-Auth,Ocr are disabled
    //&& this.template.querySelector('OCR').disabled==true //Ocr button not present

      //Name,Address line fetched from apex method for failing field level validation
      //Make fields editable if validation failing
      goldenSource({LoanApplicationId: this.id})
      .then(result => {
         console.log("here in golden");
      })
      .catch(error => {
         this.error = error;
         const evt = new ShowToastEvent({
            title: 'Error',
            message: 'Please verify Name and Address fields',
            variant: 'error',
         });
         this.dispatchEvent(evt);
         console.log(this.error);
         console.log("error came");
         
      });

   }

   //Done button Action
  
   saveData(){
    this[NavigationMixin.Navigate]({
        "type": "standard__component",
        "attributes": {
           
           "componentName": "c__AuraQuitPopUp"
        }
     });
     console.log("done button");

   }

}