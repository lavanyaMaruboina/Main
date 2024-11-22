@isTest
public class IND_ENACHRegistrationJourneyResponseTest {
    @isTest 
    public static void verifyIND_ENACHRegistrationJourneyResponseTest(){
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
            IND_ENACHRegistrationJourneyResponse result=new IND_ENACHRegistrationJourneyResponse();
            result.Registration_Url='';
            result.Resp_Code='';
            result.Resp_Message='';
            result.Session_Id='';
            System.assertEquals(result.Registration_Url, '');
            Test.stopTest();
        }
    }
}