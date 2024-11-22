import { LightningElement,api,track } from 'lwc';
import getHoldProposals from '@salesforce/apex/ProposalStatusClass.fetchHoldProposals';
import Hold_By_You from '@salesforce/label/c.Hold_By_You';
export default class IND_LWC_ProposalOnHoldByYou extends LightningElement {
  @api camIdVsCamObjMap;
  @api approvedBy;
  @api pendingWith;//CISP-2864
  @track holdProposalList=[];
  @track camData;
  isTwoWheeler = false;
  @api
  fetchHoldProposal(approvedBy,loanApplicationVsBankBranch,loanIdVsVehicleDetail,daysPending,pendingWith){//CISP-2863//CISP-2864
      if(approvedBy){
        this.approvedBy = approvedBy;
        getHoldProposals({approvedBy:this.approvedBy, daysPending:daysPending,pendingWith:pendingWith})//CISP-2863//CISP-2864
        .then(res=>{
          if(res){
            this.camData = res;
            let camIdVsDeviationList = this.camData.camIdVsDeviationListMap;
            loanIdVsVehicleDetail = this.camData.loanIdVsVehicleDetail;
            let camIdVsApprovalByStatus = this.camData.camIdVsApprovalByStatus
            this.camIdVsCamObjMap = this.camData.camIdVsCamObjMap;
            let loanIdVsTotalExposure = this.camData.loanIdVsTotalExposure;
            loanApplicationVsBankBranch = this.camData.loanApplicationVsBankBranch;
            this.holdProposalList = [];
            for(let camId in camIdVsDeviationList){
              const deviationList = camIdVsDeviationList[camId];
              let obj = Object.create(this.camIdVsCamObjMap[camId]);
              if(loanApplicationVsBankBranch && loanApplicationVsBankBranch[this.camIdVsCamObjMap[camId].Loan_Application__c]){
                obj.branchName = loanApplicationVsBankBranch[this.camIdVsCamObjMap[camId].Loan_Application__c].Name;
              }
              if(loanIdVsVehicleDetail && loanIdVsVehicleDetail[this.camIdVsCamObjMap[camId].Loan_Application__c]){
                obj.variant = loanIdVsVehicleDetail[this.camIdVsCamObjMap[camId].Loan_Application__c].Variant__c;
                if (this.camIdVsCamObjMap[camId].Loan_Application__r.Product_Type__c === 'Two Wheeler') {
                  obj.segment = loanIdVsVehicleDetail[this.camIdVsCamObjMap[camId].Loan_Application__c].Product_Segment__c;
                  this.isTwoWheeler = true;
                }
              }
              if(camIdVsApprovalByStatus && camIdVsApprovalByStatus[camId]){
                obj.approvalDone = camIdVsApprovalByStatus[camId];
              }
              if(loanIdVsTotalExposure && loanIdVsTotalExposure[this.camIdVsCamObjMap[camId].Loan_Application__c]){
                obj.TotalExposure = loanIdVsTotalExposure[this.camIdVsCamObjMap[camId].Loan_Application__c];
              }
              obj.daysPending = obj.No_of_Days_Pending__c;
              if (parseInt(obj.No_of_Days_Pending__c) > 3) {//Strat CISP-2863
                obj.rowStyle =  'background:red;';
            }else{
              obj.rowStyle = null;
            }//Start CISP-2863
              obj.Status = Hold_By_You;

              obj.URL = '/apex/IBLCAMPage' + '?id='+camId;
              this.holdProposalList.push(obj);
            }
          }
        })
      }
  }
}