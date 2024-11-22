@isTest
public class IND_StampingDetailsResponseTest {
    
    @isTest
    public static void verifyIND_StampingDetailsResponse(){
        //create user
        Profile p = [SELECT Id FROM Profile WHERE Name='IBL Business Executive'];
        User u = new User(Alias = 'standt2', Email='standarduser2@testorg.com',MobilePhone = '9999999999',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,Maker_Id__c='12',IsActive = true,
                          TimeZoneSidKey='America/Los_Angeles',UserName='test_userprod12345@indusbank.com');
        insert u;
        System.runAs(u) 
        {
            Test.startTest();
            IND_StampingDetailsResponse.Response objRes = new IND_StampingDetailsResponse.Response();
            System.assertEquals(objRes.status, null);
            System.assertEquals(objRes.respDesc, null);
            System.assertEquals(objRes.content, null);
            IND_StampingDetailsResponse.Content objRes1 = new IND_StampingDetailsResponse.Content();
            System.assertEquals(objRes1.Status_Code, null);
            System.assertEquals(objRes1.Status_Description, null);
            System.assertEquals(objRes1.Esign_Link, null);
            System.assertEquals(objRes1.Dt_Stamping_Agree_Master, null);
            System.assertEquals(objRes1.StampedForDDL, null);
            System.assertEquals(objRes1.StampTypeDDL, null);
            System.assertEquals(objRes1.StampTowardsDDL, null);
            IND_StampingDetailsResponse.StampedForDDL objRes2 = new IND_StampingDetailsResponse.StampedForDDL();
            System.assertEquals(objRes2.Display, null);
            System.assertEquals(objRes2.Data, null);
            System.assertEquals(objRes2.Product, null);
            System.assertEquals(objRes2.Active_Flag, null);
            IND_StampingDetailsResponse.StampTowardsDDL objRes3 = new IND_StampingDetailsResponse.StampTowardsDDL();
            System.assertEquals(objRes3.Text, null);
            System.assertEquals(objRes3.Value, null);
            IND_StampingDetailsResponse.Dt_Stamping_Agree_Master objRes4 = new IND_StampingDetailsResponse.Dt_Stamping_Agree_Master();
            System.assertEquals(objRes4.Document_Type, null);
            System.assertEquals(objRes4.Document_Template_ID, null);
            System.assertEquals(objRes4.StampDuty_Amount, null);
            System.assertEquals(objRes4.NESL_ESigning_Applicable_Flag, null);
            System.assertEquals(objRes4.NESL_EStamp_Applicable_Flag, null);
            System.assertEquals(objRes4.NESL_ESigning_Manual_Override_Flag, null);
            System.assertEquals(objRes4.NESL_Digital_EStamp_Required_Flag, null);
            System.assertEquals(objRes4.SHCIL_EStamp_Flag, null);
            System.assertEquals(objRes4.Franking_Flag, null);
            System.assertEquals(objRes4.NESL_Digital_EStamp_Required_Flag, null);
            System.assertEquals(objRes4.SHCIL_EStamp_Flag, null);
            System.assertEquals(objRes4.Franking_Flag, null);
            System.assertEquals(objRes4.Adhesive_Flag, null);
            System.assertEquals(objRes4.Stamp_Paper_Flag, null);
            System.assertEquals(objRes4.Cess_OnStampdutyAmount, null);
            IND_StampingDetailsResponse objRes5 = new IND_StampingDetailsResponse();
            System.assertEquals(objRes5.response, null);
            Test.stopTest();
        }
    }
}