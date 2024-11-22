import { LightningElement, api, track } from 'lwc';
import getForwardedProposals from '@salesforce/apex/ProposalStatusClass.fetchForwardedProposals';

export default class IND_LWC_ProposalForwardByYou extends LightningElement {
  @api camIdVsCamObjMap;
  @api approvedBy;
  @track forwardedByList = [];
  isTwoWheeler = false;
  connectedCallback() {
    try {
      if (this.camIdVsCamObjMap) {
        this.fetchForwardProposal();
      }
    } catch (error) {
      console.error(error);
    }
  }
  @api
  fetchForwardProposal(camIdVsObjMap, camIdVsIsHoldMap, loanApplicationVsBankBranch, loanIdVsVehicleDetail, pendingWith, loanIdVsTotalExposure) {//CISP-2864
    if (camIdVsObjMap) {
      this.camIdVsCamObjMap = camIdVsObjMap;
      if (this.camIdVsCamObjMap) {
        getForwardedProposals({ camIdVsCamMap: this.camIdVsCamObjMap,pendingWith:pendingWith })//CISP-2864
          .then(res => {
            if (res) {
              this.camData = res;
              
              let camIdVsDeviationListMap = this.camData.IdVsProposalApprovalLog;
              this.forwardedByList = [];
              for (let camId in camIdVsDeviationListMap) {
                const proposalList = res[camId];
                let obj = Object.create(this.camIdVsCamObjMap[camId]);
                if (loanApplicationVsBankBranch && loanApplicationVsBankBranch[this.camIdVsCamObjMap[camId].Loan_Application__c]) {
                  obj.branchName = loanApplicationVsBankBranch[this.camIdVsCamObjMap[camId].Loan_Application__c].Name;
                }
                if (loanIdVsVehicleDetail && loanIdVsVehicleDetail[this.camIdVsCamObjMap[camId].Loan_Application__c]) {
                  obj.variant = loanIdVsVehicleDetail[this.camIdVsCamObjMap[camId].Loan_Application__c].Variant__c;
                  if (this.camIdVsCamObjMap[camId].Loan_Application__r.Product_Type__c === 'Two Wheeler') {
                    obj.segment = loanIdVsVehicleDetail[this.camIdVsCamObjMap[camId].Loan_Application__c].Product_Segment__c;
                    this.isTwoWheeler = true;
                  }
                }
                if (loanIdVsTotalExposure && loanIdVsTotalExposure[this.camIdVsCamObjMap[camId].Loan_Application__c]) {
                  obj.TotalExposure = loanIdVsTotalExposure[this.camIdVsCamObjMap[camId].Loan_Application__c];
                }
                obj.URL = '/apex/IBLCAMPage' + '?id=' + camId;
                if (camIdVsIsHoldMap && camIdVsIsHoldMap[camId] != null) {
                  obj.isHoldByOthers = camIdVsIsHoldMap[camId];
                }
                if (parseInt(obj.No_of_Days_Pending__c) > 3) {//Strat CISP-2863
                  obj.rowStyle =  'background:red;';
                }else{
                    obj.rowStyle = null;
                }//Start CISP-2863
                this.forwardedByList.push(obj);
              }
            }
          })
      }
    }
  }

}