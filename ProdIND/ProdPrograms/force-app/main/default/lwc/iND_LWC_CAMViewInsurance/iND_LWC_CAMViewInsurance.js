import { LightningElement,track,api } from 'lwc';
import getRelatedInsurance_MTD from '@salesforce/apex/ViewCamController.getRelatedInsuranceDetails';

export default class IND_LWC_CAMViewInsurance extends LightningElement {
  @api recordId;
  @api vehicleId;
  @track insuranceDetails;
  @track totalAmountPayable;
  @track totalAmountFunded;
  @track hasInsurancePlans;

  connectedCallback(){
    console.log('recordId',this.recordId);
    if(this.recordId){
      this.getRelatedInsurances();
    }
  }
  handleCloseButton(){
    self.close();
  }
  getRelatedInsurances(){
    getRelatedInsurance_MTD({camId:this.recordId, vehicleId: this.vehicleId})
    .then(response=>{
      if(response){
        this.insuranceDetails = response;
        console.log('insuranceDetails',this.insuranceDetails);
        let totalAmount = 0;
        let totalAmountFunded = 0;

        this.insuranceDetails.forEach(element => {
          totalAmount+=element.Amount__c;
          if(element.Funded_Non_funded__c=='Funded'){
            totalAmountFunded+=element.Amount__c;
          }
          if(this.vehicleId && element?.Insurance_Plan__c == 'MOTOR' && element.Applicant__r.Applicant_Type__c){
            element.Applicant__r.Applicant_Type__c = element?.Vehicle_Detail__r?.Variant__c;
          }
        });
        this.totalAmountPayable = totalAmount;
        this.totalAmountFunded = totalAmountFunded;
        this.hasInsurancePlans = true;
      }
    })
    .catch(error=>{
      console.error(error); 
    })
  }
}