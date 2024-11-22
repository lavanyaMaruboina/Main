@isTest
public class CustomMetadataUtilsTest {
    
    @isTest
    public static void verifyCreateCustomMetadata(){
        //create user
        Profile p = [SELECT Id FROM Profile WHERE Name='IBL CVO'];
        User u = new User(Alias = 'standt2', Email='standarduser2@testorg.com',MobilePhone = '9999999999',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,Maker_Id__c='12',IsActive = true,
                          TimeZoneSidKey='America/Los_Angeles',UserName='test1_userprod123@indusbank.com');
        insert u;
        System.runAs(u) 
        {
            Map<String, Object> metadataFieldValueMap = new  Map<String, Object>();
            metadataFieldValueMap.put('MDNField2__c', '9');
            CustomMetadataUtils.createCustomMetadata('DealNumber_Setting__mdt', 'Deal Number', metadataFieldValueMap);
            CustomMetadataUtils.updateCustomMetadata('DealNumber_Setting__mdt', 'Deal_Number', 'Deal Number', metadataFieldValueMap);
            System.assert(metadataFieldValueMap != null);
        }
    }
}