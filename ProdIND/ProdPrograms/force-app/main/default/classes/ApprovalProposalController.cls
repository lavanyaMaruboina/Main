public class ApprovalProposalController {
    @AuraEnabled(cacheable=true)
  public static List<Proposal_Approval_Log__c> getProposal() {
  return [SELECT Id, Name,Approval_Status__c,Remark__c,Role__c,Deviation_Status__c,Deviation_Id__c FROM Proposal_Approval_Log__c	];
  }

  @AuraEnabled
public static string updateProposalRecords(Object proposals) {
    List<Proposal_Approval_Log__c> proposalApprovalUpdates = (List<Proposal_Approval_Log__c>) JSON.deserialize(
         JSON.serialize(proposals),
         List<Proposal_Approval_Log__c>.class
    );
    try {
        update proposalApprovalUpdates;
        return 'Success: Proposal Approvals updated successfully';
    }
    catch (Exception e) {
        return 'The following exception has occurred: ' + e.getMessage();
    }
}


}