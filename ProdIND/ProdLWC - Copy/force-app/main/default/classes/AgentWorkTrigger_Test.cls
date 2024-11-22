@isTest (seeAllData=true)
public class AgentWorkTrigger_Test {
    
    @istest
    public static void testAgentTrigger(){
                
        Account accVal = new Account(Name='Test Account56435');
        insert accVal;
        
        List<Opportunity> opp = new List<Opportunity>();
        for(Integer i=0;i<2;i++) {
            opp.add(new Opportunity(Name= 'Opportunity'+i,
                                    StageName='Loan Initiation',
                                    CloseDate=System.today().addMonths(1),
                                    AccountId= accVal.Id));
        }
        insert opp;
        
        //	List<OpportunityTeamMember> oppTeamMembersToBeInserted = new List<OpportunityTeamMember>();
        List<Case> doc = new List<Case>();     
        Case caseVal = new Case(CMU_Accept__c = false, Loan_Application__c = opp[1].id, Status = 'new',Type='CMU Request');
        insert caseVal;
        List<String> caseList=new List<String>();
        Case caseVal1 = new Case(CMU_Accept__c = true, Loan_Application__c = opp[1].id, Status = 'new',Type='CMU Request');
        Insert caseVal1;
        caseList.add(caseVal1.Id);
        caseList.add(caseVal.Id);
        Map<String,string>caseNumOwnerMap= new Map<String,String>();
        ServiceChannel SChannelId= [SELECT Id,DeveloperName FROM ServiceChannel Where DeveloperName= 'CMU_Service_Channel' Limit 1];
        
        User user1 = new User();
        user1.id = UserInfo.getUserId();
        MAP<Id,Id> opptyOwnerProfileId = new MAP<Id,Id>();
        Map<String, String> serviceChanelMap=new Map<String, String>();
        System.runAs(user1){  
            List<AgentWork> workItems = new List<AgentWork>();
            TriggerSwitch__c trgSwitch = new TriggerSwitch__c();
        	trgSwitch.Name = 'AgentWorkTrigger';
        	trgSwitch.Active__c = true;
        	database.insert(trgSwitch,false);
            workItems.add(new AgentWork(WorkItemId = caseVal.Id, UserId = user1.id, ServiceChannelId = SChannelId.Id));
            try{
               Database.insert(workItems); 
            }catch(Exception e){
                System.debug(e);
            }
            caseNumOwnerMap.put(caseVal.Id,user1.id);
            opptyOwnerProfileId.put(workItems[0].Ownerid,user1.ProfileId);
            serviceChanelMap.put(SChannelId.Id,SChannelId.DeveloperName);
            AgentWorkTriggerHandler ggtHandler=new AgentWorkTriggerHandler();
            ggtHandler.newAgentWorkList=workItems;
            ggtHandler.caselist=caseList;
            ggtHandler.caseNumOwnerMap=caseNumOwnerMap;
            ggtHandler.opptyOwnerProfileId=opptyOwnerProfileId;
            ggtHandler.serviceChanelMap=serviceChanelMap;
            try{
               ggtHandler.afterUpdate(); 
            }catch(Exception e){
                System.debug(e);
            }
            
            //workItems[0].WorkItemId=caseVal.Id;
            //update workItems[0];
        }   
        
        
    }
}