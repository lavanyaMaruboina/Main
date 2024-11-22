import { LightningElement,track,api } from 'lwc';
// import getRelatedEMI_MTD from '@salesforce/apex/ViewCamController.getRelatedEMI';
import getRequestDetails_MTD from '@salesforce/apex/ViewCamController.getRequestDetails';
import toastMsg from '@salesforce/label/c.Message_Loan_application_do_not_have_amount_or_tenure';
import finalTermDetails from '@salesforce/apex/ViewCamController.finalTermDetails';
import isTractorLead from '@salesforce/apex/ViewCamController.isTractorLead';
import emiRepaymentSchedule from '@salesforce/apex/ViewCamController.emiRepaymentSchedule';
import getOfferResponse from '@salesforce/apex/IND_OfferScreenController.getOfferResponse';


export default class IND_LWC_CAMViewEMI extends LightningElement {
  @api recordId;
  @api vehicleId;
  @track relatedEMI;
  @track errorMessage = toastMsg;
  showMessage = false;
  @track totalPaybleEMI = [];
  @track showEMIDetails = false;
  @track isTractorLead = false;
  @track isStructured;
  @track isCmpRendered = false;
  async connectedCallback() {
    try {
      let result = await isTractorLead({'camId' : this.recordId});
      this.isTractorLead = result;
      if(result){
        finalTermDetails({ vehicleId: this.vehicleId})
        .then(response => {
          if(response && response.installmentType == 'Structured'){
            this.isStructured = true;
            this.isCmpRendered = true;
            getOfferResponse({'loanApplicationId':response.loanAppId,'vehicleId':this.vehicleId}).then((result)=> {
              let plainText;
              if(result.contentVersion == true){
                  plainText = atob(result.response);
              }else{
                  plainText = result.response;
              }
              const parsedResponse = JSON.parse(plainText);
              let amortSch = parsedResponse?.application?.offerEngineDetails?.offerEngineDecision?.amortizationSchedule;
              this.totalPaybleEMI = amortSch
            }).catch(error=>{
              console.log(error);
            });
          }else{
            this.isStructured = false;
            this.isCmpRendered = true;
            emiRepaymentSchedule({'vehicleId' : this.vehicleId}).then((result) => {
              this.showEMIDetails = true;
              this.totalPaybleEMI = result
            }).catch(error=>{
              console.log('error - ', error);
            });
          }
        }).catch(error=>{
          console.log('error - ', error);
        });
      }else{
        this.getRequestDetails();
      }
    } catch (error) {
      console.error(error);
      this.showMessage = true;
    }
  }
  getRequestDetails() {
    console.log(this.errorMessage);
    if (this.vehicleId) {
      finalTermDetails({ vehicleId: this.vehicleId})
        .then(response => {
          if (response) {
            let emiAmount = response.emiAmount;
            let tenure = response.tenure;
            let emiList = [];
            if(emiAmount && tenure){
              for (let index = 1; index <= tenure; index++) {
                emiList.push({
                  from: index,
                  to: index,
                  emi: emiAmount
                });
              }
            }
  
            this.relatedEMI = emiList;
            this.showMessage = emiList.length === 0;
          } else {
            this.showMessage = true;
          }
        });
    }else{
      getRequestDetails_MTD({ camId: this.recordId})
        .then(response => {
          console.log('getRequestDetails', JSON.stringify(response));
          if (response) {
            // response = JSON.parse(response);
            this.applicantId = response.applicantId;
            this.loanApplicationId = response.loanAppId;
            let emiAmount = response.emiAmount;
            let tenure = response.tenure;
            let emiList = [];
            if(emiAmount && tenure){
              for (let index = 1; index <= tenure; index++) {
                emiList.push({
                  from: index,
                  to: index,
                  emi: emiAmount
                });
              }
            }
  
            this.relatedEMI = emiList;
            this.showMessage = emiList.length === 0;
          } else {
            this.showMessage = true;
          }
        });
    }
  }

  handleCloseButton(){
    self.close();
  }

}