import { LightningElement, track, api } from 'lwc';
import getRequestDetails_MTD from '@salesforce/apex/ViewCamController.getRequestDetails';
import getCAMPortfolioDetails from '@salesforce/apex/ExternalCAMDataController.getCAMPortfolioDetails';


export default class IND_LWC_CAMportfili extends LightningElement {
  @api recordId;
  @track portfolioContent = [];
  @api applicantId;
  @api loanApplicationId;
  hasPortfolioContent=false;
  errorMsg='No data found';

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
            this.requestPortfolioDetails();
          }
        }
      })
  }
  requestPortfolioDetails() {
    try {
      getCAMPortfolioDetails({ loanAppId:this.loanApplicationId,camId:this.recordId })
        .then(response => {
          console.log('response',response);
          if(response && response.length > 0){
             this.portfolioContent = response;
             this.hasPortfolioContent=true;
          }
        })
        .catch(error => {
          console.error(error);
        })
    } catch (error) {
      console.error(error);
    }
  }
  handleCloseButton() {
    self.close();
  }
}