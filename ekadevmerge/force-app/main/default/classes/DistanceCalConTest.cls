@isTest
public class DistanceCalConTest {
    static testMethod void testDistanceCalcon() {
     // Create a user 
     Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u = new User(Alias = 'standt', 
                          Email='standarduser@testorg.com',
                          EmailEncodingKey='UTF-8', 
                          LastName='Testing', 
                          LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', 
                          ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles', 
                          UserName='standarduser' + System.currentTimeMillis() + '@testorg.com'); // Appending timestamp to make the username unique
        insert u;

        Check_IN_Out__c ch = new Check_IN_Out__c(
                                  Check_In_Time__c = DateTime.now(),
                                  Check_In_Geolocation__latitude__s = 37.7749, // replace with actual latitude value
                                  Check_In_Geolocation__longitude__s = -122.4194, // replace with actual longitude value
                                  OwnerId = u.Id     
                                                );
                    insert ch;

        // Create a System_Check_In__c record
        System_Check_In__c sysCheckIn = new System_Check_In__c(
            Check_In_Time__c = DateTime.now(),
            Check_In_Geolocation__latitude__s = 37.7749, // replace with actual latitude value
            Check_In_Geolocation__longitude__s = -122.4194, // replace with actual longitude value
            OwnerId = u.Id
        );
        insert sysCheckIn;

        // Create multiple Check_IN_Out__c records with different geolocation values
        List<Check_IN_Out__c> checkInOutList = new List<Check_IN_Out__c>();
        for (Integer i = 0; i < 5; i++) {
            Check_IN_Out__c checkInOut = new Check_IN_Out__c(
                Check_In_Time__c = DateTime.now(),
                Check_In_Geolocation__latitude__s = 37.775 + i, // replace with different latitude values
                Check_In_Geolocation__longitude__s = -122.42 + i, // replace with different longitude values
                OwnerId = u.Id
            );
            checkInOutList.add(checkInOut);
        }
        insert checkInOutList;
        
        System.runAs(u){
              Test.startTest();
             DistanceCalCon.desCalcon();
             Test.stopTest();
        }
       

        // Verify that the distance is calculated and updated
       // System_Check_In__c updatedSysCheckIn = [SELECT Id, Distance_Travel_Per_Day__c FROM System_Check_In__c WHERE Id = :sysCheckIn.Id];
        
        // Add assertions to check whether the Distance_Travel_Per_Day__c field is updated with a non-zero value
       // System.assertNotEquals(updatedSysCheckIn.Distance_Travel_Per_Day__c, 0, 'Distance not calculated and updated');

        // Add additional assertions based on specific logic
        // For example, check the Distance_Travel_Per_Day__c against expected values based on the specific test data.
        // Add assertions for different scenarios to cover more branches of your code.

        // Example: Assert that the distance is correctly calculated for each record in checkInOutList
       /* List<Check_IN_Out__c> updatedCheckInOutList = [SELECT Id, Distance_Travel_Per_Day__c FROM Check_IN_Out__c WHERE Id IN :checkInOutList];
        for (Check_IN_Out__c checkInOut : updatedCheckInOutList) {
          System.assertNotEquals(checkInOut.Distance_Travel_Per_Day__c, 0, 'Distance not calculated and updated for Check_IN_Out__c record');
        }*/
    
}
}