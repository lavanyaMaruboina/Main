@isTest
public class EmailNotConnected1Test {
    @isTest
    static void testSendToEmail() {
        Opportunity matchingOpportunity1 = new Opportunity(
            Name = 'Matching Opportunity 1',
            Activity_Status__c = 'Not Connected',
            StageName = 'Demo',
            Email__c = 'abc@gmail.com',
            Date1__c = system.Today().addDays(-7),
            CloseDate = Date.newInstance(2024, 01, 02)
        );
         insert matchingOpportunity1;
        Test.startTest();
            EmailNotConnected1.sendToEmail();    
        Test.stopTest();
        
  
    }
}