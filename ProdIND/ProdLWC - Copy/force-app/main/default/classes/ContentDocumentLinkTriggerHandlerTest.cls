@isTest
public class ContentDocumentLinkTriggerHandlerTest {
    @testSetup
    static void setup(){
        Profile p = [SELECT Id FROM Profile WHERE Name='IBL Business Executive'];
        User u = new User(Alias = 'standt2', Email='standarduser2@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,Maker_Id__c='12',IsActive = true,
                          TimeZoneSidKey='America/Los_Angeles',UserName='test_userprodabc123@indusbank.com',MobilePhone = '9089078967');
        insert u;
        System.runAs(u) 
        {
            //create Oppty record
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            opp.Name = 'VDR Test';
            opp.StageName='Post Sanction Checks and Documentation';
            opp.Product_Type__c='Passenger Vehicles';
            opp.CVO_Accepts_SPDC_Documents__c = 'No';
            if(Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            
            
            
            //create ContentVersion record
            ContentVersion contentVersion = new ContentVersion(
                Title          = 'testfname',
                PathOnClient   = 'Pic.jpg',
                VersionData    = Blob.valueOf('Test Content'),
                IsMajorVersion = true);
            insert contentVersion; 
            
            
            
        }
    }
    
    @isTest
    public static void test_DocVisibility(){
        Test.startTest();
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprodabc123@indusbank.com' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            Opportunity opp =[Select Id, Name From Opportunity Where Name ='VDR Test' LIMIt 1];
            List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
            //create ContentDocumentLink  record
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.LinkedEntityId = opp.Id;
            cdl.ContentDocumentId = documents[0].Id;
            cdl.ShareType = 'V';
            cdl.Visibility = 'InternalUsers';
            insert cdl;
            
            ContentDocumentLink contDocLInk = [Select Id, ShareType, Visibility From ContentDocumentLink Where Id =: cdl.Id];
            System.assertNotEquals(null, contDocLInk);
            System.assertEquals('AllUsers', contDocLInk.Visibility);
        }
        Test.stopTest();
    }
    @isTest
    public static void deactivateDuplicateDocument(){
        Test.startTest();
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprodabc123@indusbank.com' AND IsActive = true LIMIT 1];
        System.runAs(u)
        {
            Documents__c dcument= TestDataUtility.createTestDocument(true);
            system.debug('dcument ::'+dcument);
            TestDataUtility.createContentVersionforOcrFront('Test doc',true, dcument);
            Documents__c dcument2= TestDataUtility.createTestDocument(true);
            system.debug('dcument ::'+dcument);
            TestDataUtility.createContentVersionforOcrFront('Test doc',true, dcument2);
           List<ContentDocumentLink> contdocLink =  [select Id,LinkedEntityId from ContentDocumentLink where LinkedEntityId =:dcument.Id];
            system.debug('contdocLink ::'+contdocLink );
            ContentDocumentLinkTriggerHandler.deactivateDuplicateDocument(contdocLink);
        }
        Test.stopTest();
    }
}