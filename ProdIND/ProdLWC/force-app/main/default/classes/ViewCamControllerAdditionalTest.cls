@isTest
public class ViewCamControllerAdditionalTest {
 
    @testSetup
    static void setupTestData() {
        // Create user with unique username using current timestamp 
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator' LIMIT 1];
        String uniqueUsername = 'testuser_' + System.currentTimeMillis() + '@testorg.com';
        User u = new User(Alias = 'testuser', Email='testuser@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='User', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id, IsActive = true,
                          TimeZoneSidKey='America/Los_Angeles', UserName=uniqueUsername,MobilePhone='1234567890');
 
        System.runAs(u) {
            
            Opportunity opp = new Opportunity(
                Name = 'Test Opportunity',
                StageName = 'Qualification',
                CloseDate = System.today().addMonths(1)
            );
            insert opp;
            Opportunity opp1 = new Opportunity(
                Name = 'Test Opportunitys',
                StageName = 'Qualification',
                CloseDate = System.today().addMonths(1)
            );
            insert opp1;
 
            // Insert Vehicle Detail associated with Opportunity
            Vehicle_Detail__c vehicleDetail = new Vehicle_Detail__c(
                Loan_Application__c = opp.Id, // Loan_Application__c field refers to the Opportunity
                Distance__c = 120,
                Gross_Receipts_Month__c = 5000,
                Number_of_vehicle_owned__c = 3,
                Expense__c = 2000,
                Vehicle_Route__c = 'Route A',
                Route__c = 'Market Load'
            );
            insert vehicleDetail;
        }
    }
 
    @isTest
    static void testGetViabilityDetailsSuccess() {
        // Retrieve test data
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        Vehicle_Detail__c vehicleDetail = [SELECT Id FROM Vehicle_Detail__c WHERE Loan_Application__c = :opp.Id LIMIT 1];
 
        // Call the method
        Test.startTest();
        List<Vehicle_Detail__c> result = ViewCamControllerAdditional.getViabilityDetails(opp.Id, vehicleDetail.Id);
        Test.stopTest();

        System.assertNotEquals(null, result, 'Result should not be null');
      
    }
 
    @isTest
    static void testGetViabilityDetailsNoData() {
        // Call the method with invalid vehicleId
        ViewCamControllerAdditional.simulateTestException = true;
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        Vehicle_Detail__c vehicleDetail = [SELECT Id FROM Vehicle_Detail__c WHERE Loan_Application__c = :opp.Id LIMIT 1];

        Test.startTest();
        List<Vehicle_Detail__c> result = ViewCamControllerAdditional.getViabilityDetails(opp.Id, vehicleDetail.Id);
        Test.stopTest();
    }

}