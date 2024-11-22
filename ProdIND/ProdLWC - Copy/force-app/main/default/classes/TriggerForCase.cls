@isTest
public class TriggerForCase {
    
    public static testmethod void testupdateforcase()
    {
        Test.startTest();
        TriggerSwitch__c trgSwitch = new TriggerSwitch__c();
        trgSwitch.Name = 'Trigger_For_Case';
        trgSwitch.Active__c = true;
        insert trgSwitch;
        
        Account testAccount = new Account(Name='Test Account');
        insert testAccount;
        Opportunity opp = new Opportunity( Name= 'Opportunity',
                                          StageName='Prospecting',
                                          CloseDate=System.today().addMonths(1),
                                          AccountId= testAccount.Id);
        insert opp;
        List<Case> doc = new List<Case>();     
        Case updateCase = new Case(CMU_Accept__c = false, Loan_Application__c = opp.id, Status = 'new');
        insert updateCase;
        OpportunityTeamMember insertTeam = new OpportunityTeamMember(TeamMemberRole = 'teamLeader', UserId = UserInfo.getUserId(), OpportunityId=opp.id);
        insert insertTeam;
        
        try{
            updateCase.CMU_Accept__c = true;
            update updateCase;
            insertTeam.TeamMemberRole = 'CMU Team member';
            insertTeam.UserId = UserInfo.getUserId();
            insertTeam.OpportunityId = opp.id;
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