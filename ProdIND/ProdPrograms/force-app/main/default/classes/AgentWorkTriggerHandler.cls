/**
* @Name         AgentWorkTriggerHandler
* @Author       Karunakar
* @Company      Persistent Systems
* @Description  Agent Work handler class for trigger AgentWork
* Test Class:   
* History:     
*/
public without sharing class AgentWorkTriggerHandler extends TriggerHandler{
    @testvisible List<AgentWork> newAgentWorkList;
    List<AgentWork> oldAgentWorkList;
    Map<Id,AgentWork> newAgentWorkMap;
    Map<Id,AgentWork> oldAgentWorkMap;
    @testvisible Map<String,string>caseNumOwnerMap= new Map<String,String>();
    @testvisible  Map<String, String> serviceChanelMap = new Map<String, String>();
    @testvisible MAP<Id,Id> opptyOwnerProfileId = new MAP<Id,Id>();
    @testvisible  List<String>caselist = new List<String>();
    @testvisible  Map<String, String> caseOwnerMap = new Map<String, String>();
    @testvisible  Map<String, String> caseAgentWorkStatusMap = new Map<String, String>();
    
    public AgentWorkTriggerHandler(){
        newAgentWorkList = (List<AgentWork>)Trigger.new;
        oldAgentWorkList = (List<AgentWork>)Trigger.old;
        newAgentWorkMap = (MAP<Id,AgentWork>)Trigger.newMap;
        oldAgentWorkMap = (MAP<Id,AgentWork>)Trigger.oldMap;
    }
    
    /*
    * @Method:      afterUpdate
    * @Description: Check the Agent used created Account teammember record for CMU case Owner
    * @Param:       trigger context variables
    * @Return:      none.
    */
    public override void afterUpdate() {
        try{
            List<OpportunityTeamMember> opptyTeamMembersToBeInserted = new List<OpportunityTeamMember>();           
            List<string> caseOwnerIds = new List<String>();
            Map<String, String> caseLoanAppIdMap = new Map<String, String>();
            
            //Iterating agent work records and creating the map CaseId, caseOwnerId 
            for(AgentWork agentWrk : newAgentWorkList){
                if(agentWrk.ownerId!=null && agentWrk.AcceptDateTime!=null ){  //checking if the OMINI channel is accepted the request than AcceptDateTime will come           
                    caseNumOwnerMap.put(agentWrk.WorkItemId, agentWrk.LastModifiedById);
                    caselist.add(agentWrk.WorkItemId);
                    caseAgentWorkStatusMap.put(agentWrk.WorkItemId, agentWrk.Status);
                }
            }
            
            //Quering the Profile of case ownerId and checking Profile is CMU
            System.debug('caseNumOwnerMap.values()--' + caseNumOwnerMap.values());
            for(User userElement : [SELECT ID, ProfileId FROM User WHERE Id IN:caseNumOwnerMap.values() AND Profile.Name ='CMU' limit 1 ]){
                opptyOwnerProfileId.put(userElement.Id,userElement.ProfileId);
            }
            
            //fetching service channel and adding into a Map
            for(ServiceChannel serChannel : [SELECT Id, DeveloperName, StatusField FROM ServiceChannel where DeveloperName =:system.label.CMU_Service_Channel limit 1]){
                serviceChanelMap.put(serChannel.Id, serChannel.DeveloperName);
            }

            List<Case> updateCaseList = new List<Case>();
            
            //Querying the CMU case associated to WorkItem Id 
            for(Case caseRecord : [select Id, caseNumber, Status, ownerId,Loan_Application__c,CMU_User__c from Case where Id IN:caselist and Type =: system.label.CMU_Request]){//CISP-2496
                //checking if case related to CMU and case ownerId associated to that case
                if(caseNumOwnerMap.containsKey( caseRecord.Id) && caseRecord.Loan_Application__c != null){               
                    caseLoanAppIdMap.put(caseRecord.Id, caseRecord.Loan_Application__c); //Map of case id and OpptyId
                }     

                if(caseRecord.Status == 'New'){
                    caseRecord.Status = 'Pending with CMU';
                }
                 
                if(caseAgentWorkStatusMap.containsKey(caseRecord.Id) && caseRecord.Loan_Application__c != null){               
                    caseRecord.Agent_Work_Status__c = caseAgentWorkStatusMap.get(caseRecord.Id);
                }

                updateCaseList.add(caseRecord);
            }
            
            String cmuUserId;//CISP-2496
            for(AgentWork agentElement : newAgentWorkList){    
                if(caseLoanAppIdMap.containsKey(agentElement.WorkItemId) &&  opptyOwnerProfileId.containsKey(agentElement.LastModifiedById ) && 
                   serviceChanelMap.containsKey(agentElement.ServiceChannelId)){
                       OpportunityTeamMember oppTeamMember =new OpportunityTeamMember();
                       oppTeamMember.UserId = agentElement.LastModifiedById ;
                       oppTeamMember.OpportunityId = caseLoanAppIdMap.get(agentElement.WorkItemId);
                       oppTeamMember.TeamMemberRole ='CMU';
                       oppTeamMember.OpportunityAccessLevel = 'Edit'; 
                       opptyTeamMembersToBeInserted.add(oppTeamMember);
                       cmuUserId = agentElement.LastModifiedById;//CISP-2496
                   }    
            }

            if(!opptyTeamMembersToBeInserted.isEmpty() && Schema.sObjectType.OpportunityTeamMember.isCreateable()){
                if(!Test.isRunningTest()){
                	CaseWithoutSharingUpdate.insertopptyTeamMembers(opptyTeamMembersToBeInserted);
                }
            }
            if(cmuUserId != null && String.isNotBlank(cmuUserId)){//Start CISP-2496
                for (Case caseObj : updateCaseList) {
                    caseObj.CMU_User__c = cmuUserId;
                }
            }//End CISP-2496
            if(updateCaseList.size()>0 && updateCaseList!=null && Schema.sObjectType.Case.isUpdateable()){               	
                List<Database.SaveResult> srList=Database.update(updateCaseList,false);
            }

            system.debug('Log- newAgentWorkList ::' + newAgentWorkList);
            system.debug('Log- caseNumOwnerMap ::' + caseNumOwnerMap);
            system.debug('Log- caselist :' + caselist);
            system.debug('Log- serviceChanelMap :' + serviceChanelMap);
            system.debug('Log- opptyOwnerProfileId :' + opptyOwnerProfileId);
            system.debug('Log- caseLoanAppIdMap :' + caseLoanAppIdMap);
            system.debug('Log- updateCaseList :' + updateCaseList);
            system.debug('Log- opptyTeamMembersToBeInserted :' + opptyTeamMembersToBeInserted);
        }catch(exception e){
            system.debug('exception :'+e.getMessage());
            ErrorLoggerUtil.logErrorEvent('AgentWorkTriggerHandler', 'afterUpdate', 'Trigger', e);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }     
    }
}