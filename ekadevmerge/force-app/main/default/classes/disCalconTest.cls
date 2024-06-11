@isTest
private class disCalconTest {

    @isTest
    static void testDist() {
        // Create a test user
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.com');
        insert u;

        // Set the user context for the test
        System.runAs(u) {
            // Create a Check_IN_Out__c record for testing
            Check_IN_Out__c testRecord = new Check_IN_Out__c(
                //Name = 'Test Record',
                OwnerId = UserInfo.getUserId(),
                Check_In_Time__c = System.now(),
                Check_In_Geolocation__longitude__s = 123.456,
                Check_In_Geolocation__latitude__s = 78.910
            );
            insert testRecord;

            // Call the method in the class being tested
            Test.startTest();
            disCalcon.dist();
            Test.stopTest();

            // Add assertions based on the expected behavior of the method
            // For example, you can assert the size of the returned list
            List<Check_IN_Out__c> result = [SELECT Id FROM Check_IN_Out__c];
            System.assertEquals(1, result.size(), 'There should be one record created today for the current user.');
        }
    }
}