@isTest
public class IND_InitiateNeSLEAgreementResponseTest {
    @isTest
    public static void verifyIND_InitiateNeSLEAgreementResponse(){
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
            IND_InitiateNeSLEAgreementResponse.ResponseData objRes = new IND_InitiateNeSLEAgreementResponse.ResponseData();
            System.assertEquals(objRes.status, null);
            System.assertEquals(objRes.respDesc, null);
            System.assertEquals(objRes.content, null);
            IND_InitiateNeSLEAgreementResponse.Content objRes1 = new IND_InitiateNeSLEAgreementResponse.Content();
            System.assertEquals(objRes1.ResURL, null);
            System.assertEquals(objRes1.res, null);
            System.assertEquals(objRes1.Status_Code, null);
            System.assertEquals(objRes1.Status_Description, null);
            System.assertEquals(objRes1.Esign_Link, null);
        }
    }
}