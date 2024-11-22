import { LightningElement,track,api } from 'lwc';
import getNonApprovedProposals from '@salesforce/apex/ProposalStatusClass.fetchNonApprovedProposals';

export default class IND_LWC_ProposalNotApproved extends LightningElement {
  @api camIdVsCamObjMap;
  @api approvedBy;
  @track nonApprovedProposalList=[];
  @track camData;
  isTwoWheeler = false;
  @api
  fetchNonApprovalProposal(camIdVsObjMap,accountIdVsTeamMemberMap,camIdVsForwardedUserList,forwardedOnlyList,currentUserId,camIdVsIsHoldMap,loanApplicationVsBankBranch,loanIdVsVehicleDetail,pendingWith,loanIdVsTotalExposure){//CISP-2864
    if(camIdVsObjMap && accountIdVsTeamMemberMap){
      this.forwardedByList = [];
      this.camIdVsCamObjMap = camIdVsObjMap;
      if(this.camIdVsCamObjMap){
          getNonApprovedProposals({camIdVsCamObj:this.camIdVsCamObjMap,accountIdVsTeamMember:accountIdVsTeamMemberMap,approvedBy:this.approvedBy,pendingWith:pendingWith})//CISP-2864
        .then(res=>{
          if(res){
            this.camData = res;
            let camIdVsDeviationList = this.camData.camIdVsDeviationListMap;
            let camIdVsApprovalByStatus = this.camData.camIdVsApprovalByStatus;
            this.nonApprovedProposalList = [];
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
              if(loanIdVsTotalExposure && loanIdVsTotalExposure[this.camIdVsCamObjMap[camId].Loan_Application__c]){
                obj.TotalExposure = loanIdVsTotalExposure[this.camIdVsCamObjMap[camId].Loan_Application__c];
              }
              if(camIdVsApprovalByStatus && camIdVsApprovalByStatus[camId]){
                obj.approvalDone = camIdVsApprovalByStatus[camId];
              }
              if(camIdVsForwardedUserList){
                if(camIdVsForwardedUserList[camId] && camIdVsForwardedUserList[camId].includes(currentUserId)){
                  obj.Status = 'Forwarded To You, Action Pending';
                }
                else{
                    obj.Status = 'Action Pending';
                }
              }
              if(camIdVsIsHoldMap && camIdVsIsHoldMap[camId]!=null){
                obj.isHoldByOthers = camIdVsIsHoldMap[camId];
            }
              obj.daysPending = obj.No_of_Days_Pending__c;
              if (parseInt(obj.No_of_Days_Pending__c) > 3) {//Strat CISP-2863
                obj.rowStyle =  'background:red;';
              }else{
                  obj.rowStyle = null;
              }//Start CISP-2863
              obj.URL = '/apex/IBLCAMPage' + '?id='+camId;
              this.nonApprovedProposalList.push(this.camIdVsCamObjMap[camId]);
            }
            // let forwardedOnlyList = camIdVsForwardedUserList
            if(forwardedOnlyList){
              for(let camId in this.camIdVsCamObjMap){
                  if(camIdVsApprovalByStatus[camId] && camIdVsApprovalByStatus[camId]=='Not Approved'){
                    let camObj = Object.create(this.camIdVsCamObjMap[camId]);
                    // let deviationRole=element.Role__c;
                    // if(deviationRole && deviationRole.includes(this.approvedBy)){
                    //     camObj.approvalDone = 'Not Approved';
                    // }
                    // else{
                    //     camObj.approvalDone = this.approvedBy+' not available';
                    // }
                    if(camIdVsIsHoldMap && camIdVsIsHoldMap[camId]!=null){
                      camObj.isHoldByOthers = camIdVsIsHoldMap[camId];
                  }
                    if(camIdVsApprovalByStatus && camIdVsApprovalByStatus[camId]){
                        camObj.approvalDone = camIdVsApprovalByStatus[camId];
                    }
                    camObj.URL = '/apex/IBLCAMPage' + '?id='+camId;
                    camObj.daysPending = camObj.No_of_Days_Pending__c;
                    if (parseInt(camObj.No_of_Days_Pending__c) > 3) {//Strat CISP-2863
                      camObj.rowStyle =  'background:red;';
                    }else{
                        camObj.rowStyle = null;
                    }//Start CISP-2863
                    forwardedOnlyList.forEach(element => {
                        if(element.Parent_CAM__c==camId && (!camIdVsDeviationList[camId] || camIdVsDeviationList[camId].length==0)){
                            camObj.Status = 'Forwarded To You';
                        }
                    });
                    let proposalObj = this.nonApprovedProposalList.find(proposal=>proposal.Id==camObj.Id);
                    if(!proposalObj){
                      this.nonApprovedProposalList.push(camObj);
                    }
                  }
              }
          }
          }
        })
      }
    }
  }
}