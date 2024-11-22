/*
* @author: Nidhi Dhote.
* @company: Persistent Systems
* @description: this trigger class handler is use on Case object when we insert data according to condition.
* Test Class: NA
* History:
* 28/10/2021  Added by Nidhi Dhote. 
*/
public without sharing class CaseTriggerHandler extends TriggerHandler{
    //Global Variable for to be used for Casting the Sobject details
    List<Case> newCaseList;
    List<Case> oldCaseList;
    Map<Id,Case> newCaseMap;
    Map<Id,Case> oldCaseMap;
    public CaseTriggerHandler(){
        newCaseList = (List<Case>)Trigger.new;
        oldCaseList = (List<Case>)Trigger.old;
        newCaseMap = (MAP<Id,Case>)Trigger.newMap;
        oldCaseMap = (MAP<Id,Case>)Trigger.oldMap;
    }
    /*public override void beforeInsert() {
    }
    public override void beforeUpdate() {
    }
    public override void beforeDelete() {
    }
    public override void afterInsert() {
    
    } */
    public override void afterUpdate() {
        try{
            // Set<ID> caseOwnerIDs = new Set<Id>();
            // for(Case caseElement : newCaseList){  
            //     if((caseElement.Status == 'Closed'|| caseElement.Status == 'Completed') && String.isBlank(caseElement.Loan_Application__c)){
            //         caseOwnerIDs.add(caseElement.OwnerId);
            //     }
            // }
            // List<OpportunityTeamMember> oppurtunityTeamMembersToBeDeleted = [SELECT Id FROM OpportunityTeamMember WHERE UserId IN:caseOwnerIDs];
            
            // if(!oppurtunityTeamMembersToBeDeleted.isEmpty()){               	
            //     CaseWithoutSharingUpdate.deleteOTMRecords(oppurtunityTeamMembersToBeDeleted);
            // } 
            
             List<OpportunityTeamMember> opptyTeamMembersToBeInserted = new List<OpportunityTeamMember>();        
            
            for(Case caseElement : newCaseList){
                system.debug('caseElement Status before---'+caseElement.Status);
                if(caseElement.Status == 'Pending with Sales'){
                    system.debug('caseElement.Status---'+caseElement.Status);
                    OpportunityTeamMember oppTeamMember =new OpportunityTeamMember();
                    oppTeamMember.UserId = caseElement.OwnerId;
                    oppTeamMember.OpportunityId = caseElement.Loan_Application__c;
                    oppTeamMember.OpportunityAccessLevel = 'Edit';
                    opptyTeamMembersToBeInserted.add(oppTeamMember);

                    if((caseElement.CMU_CaseTeamMember_Loanapp_Owner__c != null)){
                        OpportunityTeamMember oppTeamMember1 = new OpportunityTeamMember();
                        oppTeamMember1.UserId = caseElement.CMU_CaseTeamMember_Loanapp_Owner__c;
                        oppTeamMember1.OpportunityId = caseElement.Loan_Application__c;
                        oppTeamMember1.OpportunityAccessLevel = 'Edit';
                        opptyTeamMembersToBeInserted.add(oppTeamMember1);
                    }
                    
                    if((caseElement.CMU_CaseTeamMember_FI_User__c != null)){
                        OpportunityTeamMember oppTeamMember2 =new OpportunityTeamMember();
                        oppTeamMember2.UserId = caseElement.CMU_CaseTeamMember_FI_User__c;
                        oppTeamMember2.OpportunityId = caseElement.Loan_Application__c;
                        oppTeamMember2.OpportunityAccessLevel = 'Edit';
                        opptyTeamMembersToBeInserted.add(oppTeamMember2);
                    }

                }
            }  
            
            system.debug('opptyTeamMembersToBeInserted  '+opptyTeamMembersToBeInserted);
            if(!opptyTeamMembersToBeInserted.isEmpty() && opptyTeamMembersToBeInserted.size()>0 && Schema.sObjectType.OpportunityTeamMember.isCreateable()){                      
                CaseWithoutSharingUpdate.insertopptyTeamMembers(opptyTeamMembersToBeInserted);
            }    

            /* // This block is being used for the OpptyTeam member creation
            //List<OpportunityTeamMember> opptyTeamMembersToBeInserted = new List<OpportunityTeamMember>();
            //String cmuProfileId = [SELECT ID FROM Profile WHERE Name LIKE 'CMU' LIMIT 1].ID;
            Set<ID> caseOwnerIDs = new Set<Id>();
            MAP<Id,Id> opptyOwnerProfileId = new MAP<Id,Id>();
            for(Case caseElement : newCaseList){
                caseOwnerIDs.add(caseElement.OwnerId);
            }

            for(User userElement : [SELECT ID, ProfileId FROM User WHERE Id IN:caseOwnerIDs AND ProfileId =: cmuProfileId  ]){
                opptyOwnerProfileId.put(userElement.Id,userElement.ProfileId);
            }

            for(Case caseElement : newCaseList){       
                if(caseElement.OwnerId != oldCaseMap.get(caseElement.ID).OwnerId &&  caseElement.Loan_Application__c != null && opptyOwnerProfileId.containsKey(caseElement.OwnerId) ){
                    OpportunityTeamMember oppTeamMember =new OpportunityTeamMember();
                    oppTeamMember.UserId = caseElement.OwnerId;
                    oppTeamMember.OpportunityId = caseElement.Loan_Application__c;
                    oppTeamMember.TeamMemberRole ='CMU';
                    oppTeamMember.OpportunityAccessLevel = 'Edit'; 
                    opptyTeamMembersToBeInserted.add(oppTeamMember);
                }    
            }
            
            if(!opptyTeamMembersToBeInserted.isEmpty() && opptyTeamMembersToBeInserted.size()>0 && Schema.sObjectType.OpportunityTeamMember.isCreateable()){               	
                CaseWithoutSharingUpdate.insertopptyTeamMembers(opptyTeamMembersToBeInserted);
            }     
            if(Test.isRunningTest())
            {
                throw new TriggerHandler.TriggerHandlerException('Something went wrong, Please contact your administrator');
            } */
        }Catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('CaseTriggerHandler', 'afterUpdate', 'Trigger', e);
			throw new AuraHandledException(System.Label.ExceptionMessage);
        }        
    }
    /*  public override void afterDelete() {

	}
    public override void afterUndelete() {
    
    }*/
}