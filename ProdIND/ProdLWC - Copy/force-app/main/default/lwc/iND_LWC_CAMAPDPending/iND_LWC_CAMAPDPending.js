import { LightningElement,track,api } from 'lwc';
import getRequestDetails_MTD from '@salesforce/apex/ViewCamController.getRequestDetails';
import getAPDPendingDetails from '@salesforce/apex/ExternalCAMDataController.getAPDPendingDetails';

export default class IND_LWC_CAMAPDPending extends LightningElement {
  @api recordId;
  @track showExecutiveAPD = false;
  @track showDealerAPD = false;
  @track hasUserRCAPD = false;
  @track hasUserInsuranceAPD = false;
  @track hasDealerRCAPD = false;
  @track hasDealerInsuranceAPD = false;
  @track executiveUserName;
  @track dealerName;
  @track errorMsg;
  @api applicantId;
  @api loanApplicationId;
  UserRCPendings = [];
  UserInsurancePending = [];
  DealerRCPending = [];
  DealerInsurancePending = [];

  connectedCallback() {
    try {
      this.getRequestDetails();
    } catch (error) {
      console.error(error);
    }
  }
  getRequestDetails() {
    getRequestDetails_MTD({ camId: this.recordId })
      .then(response => {
        console.log('getRequestDetails', JSON.stringify(response));
        if (response) {
          // response = JSON.parse(response);
          this.applicantId = response.applicantId;
          this.loanApplicationId = response.loanAppId;
          console.log('recordId', this.recordId, this.applicantId, this.loanApplicationId);

          if (this.applicantId && this.loanApplicationId) {
            getAPDPendingDetails({loanAppId:this.loanApplicationId,camId:this.recordId})
            .then(response=>{
              console.log('response',response);
              if(response && response.length > 0){
                response.forEach(element => {
                  if(element.Log_Type__c === 'User RC APD'){
                    if(!this.executiveUserName && element.Name__c){
                      this.executiveUserName = element.Name__c;
                    }
                    this.hasUserRCAPD = true;
                    this.UserRCPendings.push(element);
                  }else if(element.Log_Type__c === 'User Insurance APD'){
                    if(!this.executiveUserName && element.Name__c){
                      this.executiveUserName = element.Name__c;
                    }
                    this.hasUserInsuranceAPD = true;
                    this.UserInsurancePending.push(element);
                  }else if(element.Log_Type__c === 'Dealer RC APD'){
                    if(!this.executiveUserName && element.Name__c){
                      this.dealerName = element.Name__c;
                    }
                    this.hasDealerRCAPD = true;
                    this.DealerRCPending.push(element);
                  }else if(element.Log_Type__c === 'Dealer Insurance APD'){
                    if(!this.executiveUserName && element.Name__c){
                      this.dealerName = element.Name__c;
                    }
                    this.hasDealerInsuranceAPD = true;
                    this.DealerInsurancePending.push(element);
                  }
                });
                this.showExecutiveAPD = this.hasUserRCAPD || this.hasUserInsuranceAPD ? true : false;
                this.showDealerAPD = this.hasDealerRCAPD || this.hasDealerInsuranceAPD ? true : false;
              }else{
                this.errorMsg = 'No data found';
              }
            })
            .catch(error=>{
              this.errorMsg = error.body.message;
              console.error('here',error);
            });
          }
        }
      })
  }
}