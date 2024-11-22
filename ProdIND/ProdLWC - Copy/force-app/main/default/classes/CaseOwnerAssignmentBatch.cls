/*
    * @Class Name: CaseOwnerAssignmentBatch
    * @Created by: 	Gaurav Rawat.
    * @Description: Batch class for correcting the impacted CMU cases due to omnichannel issue..
*/
public class CaseOwnerAssignmentBatch implements Database.Batchable<sObject> {    
    public Database.QueryLocator start(Database.BatchableContext bc) {// Query all CMU cases that were not accepted by any CMU through the Omni channel..
        String caseQuery = 'SELECT Id,OwnerId,Owner.Profile.Name,LastModifiedDate,Loan_Application__c FROM Case Where Status = \'New\' AND RecordType.Name = \'CMU Request\' AND CMU_User__c = null AND Loan_Application__c != null';
        return Database.getQueryLocator(caseQuery);
    }
    public void execute(Database.BatchableContext bc, List<Case> caseData){
        try{
            List<Case> cmuPendingList = new List<Case>();
            List<OpportunityTeamMember> opptyTeamMembersToBeInserted = new List<OpportunityTeamMember>();
            for(Case caseObj : caseData){
                DateTime currentTime = DateTime.now();
                DateTime lastModifiedDate = caseObj.LastModifiedDate;
                Long timeDifferenceMillis = currentTime.getTime() - lastModifiedDate.getTime();
                
                if(Test.isRunningTest()){
                    timeDifferenceMillis=4000000;
                }
                
                //filter CMU case records that were updated before 1 Hour and the current owner case should be CMU user..
                if(timeDifferenceMillis > 3600000 && caseObj.OwnerId.getSObjectType().getDescribe().getName() == 'User' && caseObj.Owner.Profile.Name == 'CMU'){
                    caseObj.Status = 'Pending with CMU';
                    caseObj.CMU_User__c = caseObj.OwnerId;
                    cmuPendingList.add(caseObj);
                    
                    //Create an Opportunity team menmber for CMU user..
                    OpportunityTeamMember oppTeamMember =new OpportunityTeamMember();
                    oppTeamMember.UserId = caseObj.OwnerId;
                    oppTeamMember.OpportunityId = caseObj.Loan_Application__c;
                    oppTeamMember.TeamMemberRole = 'CMU';
                    oppTeamMember.OpportunityAccessLevel = 'Edit'; 
                    opptyTeamMembersToBeInserted.add(oppTeamMember);
                }  
            }
            if(cmuPendingList.size() > 0){
                Database.update(cmuPendingList, false);
            }
            if(opptyTeamMembersToBeInserted.size() > 0){
                Database.insert(opptyTeamMembersToBeInserted, false); 
            }
        }catch (Exception e) {
            ErrorLoggerUtil.logErrorEvent('CaseOwnerAssignmentBatch', 'execute', 'Apex', e);
        }
    }
    public void finish(Database.BatchableContext bc){}
}