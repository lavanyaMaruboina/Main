@isTest
public class iND_CustomLookupTest {
    
     @testSetup static void methodName() {
     
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        system.debug('p'+ p);
        
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles',isActive = true,
                          MobilePhone = '9701498575',
                          UserName='standarduser41@testorg.com.psdev1',Maker_Id__c='123');
        insert u;
        
         System.runAs(new User(Id = UserInfo.getUserId())){
         Account acc = TestDataUtility.createTestAccount(false);
         acc.type = 'PV';
         acc.State__c = 'TAMILNADU';
            insert acc;
            
         Opportunity opp1 = TestDataUtility.createTestLoanApplication(false);
          opp1.AccountId = acc.Id;
          opp1.LeadSource = 'D2C';
          opp1.Product_Type__c = 'Tractor';
         if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp1;
           }
        
        AccountTeamMember acctmem=new AccountTeamMember();
            acctmem.AccountId = acc.Id;
            acctmem.UserId = u.Id;
            acctmem.TeamMemberRole = 'BE';
            insert acctmem;
             
         }
   }
    
    @isTest
    private static void verifyFindRecords(){
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        system.debug('p'+ p);
        
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles',
                          MobilePhone = '9701498575',
                          UserName='standarduser4@testorg.com.psdev1',Maker_Id__c='123');
        insert u;
        
        System.runAs(new User(Id = UserInfo.getUserId())){
            
            Account testAccount = TestDataUtility.createTestAccount(true);
            
             Opportunity opp = TestDataUtility.createTestOpportunity(false);
             opp.AccountId = testAccount.Id;
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            
            string AccountID = opp.AccountId;
            
            Accountteammember acctmem=new Accountteammember();
            acctmem.AccountId = opp.AccountId;
            acctmem.UserId = UserInfo.getUserId();
            acctmem.TeamMemberRole = 'BE';
            insert acctmem;
            
            List<sobject> result = iND_CustomLookup.findRecords('IndusDrive Site Guest User','Account',opp.id,AccountID,AccountID);
           // System.assert(!result.isEmpty());
        }
        iND_CustomLookup.userWrap objInput = new iND_CustomLookup.userWrap();
        objInput.id = u.Id;
        objInput.name = u.Name;
    }   
    

    
      @isTest
    private static void findUserRecordsTest(){            
            Account acc = [Select Id from Account limit 1];
            Opportunity opp = [Select Id from Opportunity limit 1];
           
            Test.startTest();
            List<AccountTeamMember> result = iND_CustomLookup.findUserRecords('IndusDrive Site Guest User','Account',opp.id,acc.Id,acc.Id);
            Test.stopTest();   
    }
    
    @isTest
    private static void getBranchesOfStateTest(){            
            Account acc = [Select Id,state__c,Type from Account limit 1];
            Opportunity opp = [Select Id,Product_Type__c from Opportunity limit 1];
           
            Test.startTest();
            List<Account> result = iND_CustomLookup.getBranchesOfState(acc.State__c,acc.type,opp.Id);
            Test.stopTest();   
    }
}