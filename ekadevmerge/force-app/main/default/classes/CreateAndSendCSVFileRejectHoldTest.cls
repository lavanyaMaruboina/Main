@isTest
public class CreateAndSendCSVFileRejectHoldTest {
     @isTest
    static void testCreateAndSendCSVFile() {
        Test.startTest();
        Opportunity opp1 = new Opportunity(
            Name = 'TestOpp1',
            Activity_Status__c = 'On-Hold',
            StageName = 'Onboarded',
            CloseDate = Date.newInstance(2023, 6, 9),
            Onboarded_Date_Time__c = DateTime.newInstance(System.today(), Time.newInstance(8, 0, 0, 0)),
            Eka_Id__c = 'WWW.Google.Com',
            Payment_Status__c = 'Paid',
            Appointment_Link__c = 'https://test.salesforce.com'

        );
        Opportunity opp2 = new Opportunity(
            Name = 'TestOpp2',
            Activity_Status__c = 'Rejected',
            StageName = 'Onboarded',
            CloseDate = Date.newInstance(2023, 6, 9),
            Onboarded_Date_Time__c = DateTime.newInstance(System.today(), Time.newInstance(8, 0, 0, 0)),
            Eka_Id__c = 'WWW.Google.Com',
            Payment_Status__c = 'Paid',
            Appointment_Link__c = 'https://test.salesforce.com'
 
        );
        insert new List<Opportunity>{opp1,opp2};
            CreateAndSendCSVFileRejectHoldViaEmail1.createAndSendCSVFile();
        Test.stopTest();
    }

}