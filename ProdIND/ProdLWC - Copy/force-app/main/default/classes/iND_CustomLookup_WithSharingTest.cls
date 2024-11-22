@isTest
public class iND_CustomLookup_WithSharingTest {
      @isTest
    public static void findRecord_oneTest(){
        
                Account testAccount = TestDataUtility.createTestAccount(true);
        
                Opportunity opga1 = new Opportunity();
                opga1.AccountId = testAccount.Id;
                opga1.StageName = 'Qualification';
                opga1.CloseDate = Date.newInstance(2021, 1, 11);
                opga1.Name = 'testone';
                insert opga1;
        
                AccountTeamMember atm2 = new AccountTeamMember();
                atm2.AccountId = opga1.AccountId;
   		        atm2.TeamMemberRole = 'SCM';
                atm2.UserId = UserInfo.getUserId();
                insert atm2;
        
        Test.startTest();
           iND_CustomLookup_WithSharing.findRecord_one('Name','Opportunity',opga1.Id, opga1.AccountId, opga1.AccountId);
        Test.stopTest();
    }
}