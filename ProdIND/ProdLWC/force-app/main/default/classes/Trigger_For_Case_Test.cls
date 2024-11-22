/*
* @author: Nidhi Dhote
* @company: Persistent Systems
* @description: Test class for Trigger For Case class.
* History:
* Inputs: None
* 11/10/2012  Added by Nidhi . 
*/
@isTest
public class Trigger_For_Case_Test {
    
    public static testmethod void testupdateforcase()
    {
        Test.startTest();
        TriggerSwitch__c trgSwitch = new TriggerSwitch__c();
        trgSwitch.Name = 'Trigger_For_Case';
        trgSwitch.Active__c = true;
        insert trgSwitch;
        
        Account testAccount = new Account(Name='Test Account');
        insert testAccount;
        
        List<Opportunity> opp = new List<Opportunity>();
        for(Integer i=0;i<2;i++) {
            opp.add(new Opportunity(Name= 'Opportunity'+i,
                                          StageName='Loan Initiation',
                                          CloseDate=System.today().addMonths(1),
                                          AccountId= testAccount.Id));
        }
  		insert opp;
        
        List<Case> doc = new List<Case>();     
        Case updateCase = new Case(CMU_Accept__c = false, Loan_Application__c = opp[1].id, Status = 'new');
        insert updateCase;
        OpportunityTeamMember insertTeam = new OpportunityTeamMember(TeamMemberRole = 'teamLeader', UserId = UserInfo.getUserId(), OpportunityId=opp[1].id);
        insert insertTeam;
        
        try{
            updateCase.CMU_Accept__c = true;
            update updateCase;
            insertTeam.TeamMemberRole = 'CMU Team member';
            insertTeam.UserId = UserInfo.getUserId();
            insertTeam.OpportunityId = opp[1].id;
            update insertTeam;
        }
        catch(Exception e)
        {
            Boolean expectedExceptionThrown = e.getMessage().contains('XYZ') ? true : false;
            System.AssertEquals(expectedExceptionThrown, false);
        }
        Test.stopTest();
    }
}