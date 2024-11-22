@isTest
public class Recall_application_Helper_ClassTest {
     @isTest
    public static void searchUserHelperTest(){
        
        UserRole r = new UserRole(DeveloperName = 'MyCustomRole', Name = 'My Role');
        insert r;
        
        Profile p = [SELECT Id FROM Profile WHERE Name='IBL CVO'];
        
    		User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
					EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
					LocaleSidKey='en_US', ProfileId = p.Id,
					TimeZoneSidKey='America/Los_Angeles',
                    MobilePhone = '9701498575',
					Maker_Id__c = '1002',
                     UserRoleId = r.Id,
					UserName='standarduser4@testorg.com.psdev1');
            insert u;
        
        Test.startTest();
             Recall_application_Helper_Class.searchUserHelper(u.Id);
        Test.stopTest();
    }
            
}