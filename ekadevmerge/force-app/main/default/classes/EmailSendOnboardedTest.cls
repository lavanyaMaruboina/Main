@isTest
public class EmailSendOnboardedTest {
 @isTest
    static void testSendToEmail() {
        Opportunity matchingOpportunity1 = new Opportunity(
            Name = 'Matching Opportunity 1',
            Activity_Status__c = 'Onboarded',
            StageName = 'Demo',
            Email__c = 'abc@gmail.com',
            Date1__c = system.Today().addDays(-5),
            CloseDate = Date.newInstance(2024, 01, 02)
        );
         insert matchingOpportunity1;
        Test.startTest();
            EmailSendOnboarded.sendToEmail();    
        Test.stopTest();
        
  
    }
}