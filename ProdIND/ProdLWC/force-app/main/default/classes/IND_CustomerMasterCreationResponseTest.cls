@isTest
public class IND_CustomerMasterCreationResponseTest {
    
    @isTest
    public static void verifyIND_CustomerMasterCreationResponse(){
        Profile p = [SELECT Id FROM Profile WHERE Name='IBL Business Executive'];
        
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles',
                          MobilePhone = '9701498575', IsActive = true,
                          UserName='standarduser4@testorg.com.psdev1',Maker_Id__c='10002');
        insert u;
        System.runAs(u) 
        {
            Test.startTest();
            IND_CustomerMasterCreationResponse.Response objRes = new IND_CustomerMasterCreationResponse.Response();
            System.assertEquals(objRes.status, null);
            System.assertEquals(objRes.respDesc, null);
            System.assertEquals(objRes.content, null);
            //public static void verifyIND_CustomerMasterCreationResponse(){
            IND_CustomerMasterCreationResponse.Content objRes1 = new IND_CustomerMasterCreationResponse.Content();
            System.assertEquals(objRes1.CreationStatus, null);
            System.assertEquals(objRes1.Customer_Code, null);
            
            IND_CustomerMasterCreationResponse obj = new IND_CustomerMasterCreationResponse();
            System.assertEquals(obj.response, null);
            Test.stopTest();
        }
    }
    
}