@isTest
public class AgreementBookletDetailsTest {
    
    @isTest
    public static void verifyIND_AgreementBookletDetails(){
        //create user
        Profile p = [SELECT Id FROM Profile WHERE Name='IBL Business Executive'];
        User u = new User(Alias = 'standt2', Email='standarduser2@testorg.com',MobilePhone = '9999999999',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,Maker_Id__c='12',IsActive = true,
                          TimeZoneSidKey='America/Los_Angeles',UserName='test1_userprod123@indusbank.com');
        insert u;
        System.runAs(u) 
        {
            Test.startTest();
            AgreementBookletDetails.Response objRes = new AgreementBookletDetails.Response();
            System.assertEquals(objRes.status, null);
            System.assertEquals(objRes.respDesc, null);
            System.assertEquals(objRes.content, null);
            AgreementBookletDetails.Content objContent = new AgreementBookletDetails.Content();
            System.assertEquals(objContent.Stamp_S_No, null);
            System.assertEquals(objContent.Stamp_On, null);
            System.assertEquals(objContent.Stamp_Printed_Location_Blcode, null);
            System.assertEquals(objContent.Stamp_Printed_Location_BlName, null);
            System.assertEquals(objContent.Stamp_Type, null);
            System.assertEquals(objContent.Stamp_Value, null);
            System.assertEquals(objContent.Stamped_For, null);
            System.assertEquals(objContent.Stamp_Towards, null);
            AgreementBookletDetails aBDetails = AgreementBookletDetails.parse('{"response":null}');
            System.assertNotEquals(null, aBDetails);
            Test.stopTest();
        }
    }
}