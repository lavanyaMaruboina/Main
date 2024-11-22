/*
* @Test Class:  IND_LWC_VehicleInsuranceCntrlTest
* @Author: 		Vinita K.
* @Description :Test Class for IND_LWC_VehicleInsuranceCntrl .
* @Company:     Persistent Systems
*/
@isTest(seeAllData = false)
public class IND_DatatableCntrlTest {
    @TestSetup
    public static void createTestData(){
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
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }        
            Applicant__c applicant = TestDataUtility.createTestApplicantForSMS(false);
            applicant.Opportunity__c=opp.Id;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert applicant;
            }
            
            //Create Documents__c records            
            Documents__c doc = TestDataUtility.createTestDocumentITR(false, applicant, opp);            
            doc.Name = 'test';
            doc.Opportunity_Relation__c = opp.Id;
            doc.Is_active__c = true;
            doc.Document_Type__c = 'Chassis Number uploaded during verification';
            
            if(Schema.sObjectType.Documents__c.isCreateable()){
                insert doc;
            }
            ContentVersion contentVersion = new ContentVersion(
                Title          = 'testfname',
                PathOnClient   = 'Pic.jpg',
                VersionData    = Blob.valueOf('Test Content'),
                IsMajorVersion = true);
            insert contentVersion; 
            List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
            
            //create ContentDocumentLink  record
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.LinkedEntityId = doc.Id;
            cdl.ContentDocumentId = documents[0].Id;
            cdl.ShareType = 'V';
            cdl.Visibility = 'AllUsers';
            insert cdl;   
        }
    }
    
    @isTest
    public static void fetchDataMapCachedTest(){
        try{
            User u = [SELECT Id,usertype FROM User WHERE UserName='standarduser4@testorg.com.psdev1' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {
                Opportunity oppRec = [SELECT Id, Product_Type__c, Deal_Number__c, Finance_Amount__c FROM Opportunity LIMIT 1]; 
                Map<String, Object> fdMap = new Map<String, Object>();                                
                fdMap.put('Opportunity__c',oppRec);                
                Test.startTest();
                IND_DatatableCntrl.fetchDataMapCached(fdMap);
                Test.stopTest();
            }
            
        }catch(Exception e){
            System.assert(e.getMessage().contains('Script-thrown exception'));
        }
    }
    
     @isTest
    public static void fetchDataMapCachedTest1(){
        try{
            User u = [SELECT Id,usertype FROM User WHERE UserName='standarduser4@testorg.com.psdev1' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {
                Opportunity oppRec = [SELECT Id, Product_Type__c, Deal_Number__c, Finance_Amount__c FROM Opportunity LIMIT 1]; 
                Map<String, Object> fdMap = new Map<String, Object>();                                
                fdMap.put('Opportunity__c',oppRec); 
                
                Map<String, Object> fdmap1 = new Map<String, Object>();
                fdmap1.put('ContentDocumentLink',oppRec);
                
                Test.startTest();
                   IND_DatatableCntrl.fetchDataMapCached(fdmap1);
                Test.stopTest();
            }
            
        }catch(Exception e){
            System.assert(e.getMessage().contains('Script-thrown exception'));
        }
    }
    
    @isTest
    public static void getACHDocumentTest(){
        try{
            User u = [SELECT Id,usertype FROM User WHERE UserName='standarduser4@testorg.com.psdev1' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {
                Opportunity oppRec = [SELECT Id FROM Opportunity LIMIT 1]; 
                Test.startTest();
                Map<String, Object> result = IND_DatatableCntrl.getACHDocuments(oppRec.Id,'test',1);
                Test.stopTest();
                System.assertNotEquals(null,result);
            }
            
        }catch(Exception e){
            System.assert(e.getMessage().contains('Script-thrown exception'));
        }
    }
}