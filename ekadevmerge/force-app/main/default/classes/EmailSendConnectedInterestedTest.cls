@isTest
public class EmailSendConnectedInterestedTest {
    @isTest
    static void testSendToEmail() {
        Opportunity matchingOpportunity1 = new Opportunity(
            Name = 'Matching Opportunity 1',
            Activity_Status__c = 'Connected-Interested',
            StageName = 'Demo',
            Email__c = 'abc@gmail.com',
            Date1__c = system.Today().addDays(-14),
            CloseDate = Date.newInstance(2024, 01, 02)
        );
         insert matchingOpportunity1;
        Test.startTest();
            EmailSendConnectedInterested1.sendToEmail();    
        Test.stopTest();
        
  
    }
}