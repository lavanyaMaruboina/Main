@isTest
public class EmailSendDemoCompletedTest {
        @isTest
    static void testSendToEmail() {
        Opportunity matchingOpportunity1 = new Opportunity(
            Name = 'Matching Opportunity 1',
            Activity_Status__c = 'Demo Completed',
            StageName = 'Demo',
            Email__c = 'abc@gmail.com',
            Date1__c = system.Today().addDays(-10),
            Demo_Completion_Date__c = system.Today(), 
            CloseDate = Date.newInstance(2024, 01, 01)
        );
         insert matchingOpportunity1;
        Test.startTest();
            EmailSendDemoCompleted.sendToEmail();    
        Test.stopTest();
        
  
    }


}