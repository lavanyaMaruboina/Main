@isTest
public class accountsDayPlanTest {
    @isTest 
    static void testGetAccounts() {
        Account testAccount = new Account(
            Name = 'Test Account',
            OwnerId = UserInfo.getUserId(),
            Specialization__c = 'ENT',
            Status__c = 'Active',
            Status_of_Day_Plan__c = 'Not Completed',
            Notes_Reamrks__c = 'xyz',
            Reason__c = '',
            Date_of_Movement_to_cs_team__c = Date.valueOf('2023-12-01'),
            Moved_to_CS_Team__c = 'Yes',
            Stable_Month__c = 'January'
        );
        insert testAccount;
        
        List<Account> result = accountsDayPlan.getAccounts();
        system.assertEquals(1, result.size());        
    }   
    
    @isTest
    static void testUpdateAccounts() {
        Account testAccount = new Account(
            Name = 'Test Account',
            OwnerId = UserInfo.getUserId(),
            Specialization__c = 'Test Specialization',
            Status_of_Day_Plan__c = 'Test Status'
        );
        insert testAccount;
        
        List<Account> accountData = new List<Account>{
            new Account(Id = testAccount.Id, Status_of_Day_Plan__c = 'Completed')
        };                 
      	String result = accountsDayPlan.updateAccounts(accountData);       
        System.assertEquals('success', result, 'Update should be successful');  
        Account updatedAccount = [SELECT Id, Name, Status_of_Day_Plan__c FROM Account WHERE Id = :testAccount.Id LIMIT 1];
        System.assertEquals('Completed', updatedAccount.Status_of_Day_Plan__c, 'Status_of_Day_Plan__c should be updated');
    }          
}