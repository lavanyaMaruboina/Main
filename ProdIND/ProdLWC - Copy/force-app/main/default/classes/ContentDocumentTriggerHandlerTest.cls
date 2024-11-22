@isTest
public class ContentDocumentTriggerHandlerTest {
    @testSetup static void setup() {
        //Create Conntent Document
        Opportunity opp = TestDataUtility.createTestOpportunity(false);
        if (Schema.sObjectType.Opportunity.isCreateable()){
            insert opp;
        }
        
        Applicant__c applicant = TestDataUtility.createTestApplicant(false);
        applicant.Opportunity__c=opp.Id;
        if (Schema.sObjectType.Applicant__c.isCreateable()){
            insert applicant;
        }
        
        Documents__c document = TestDataUtility.createTestKYCDocsForOcrBack2(false,applicant,opp);
        document.Opportunity_Relation__c=opp.Id;
        document.Document_Type__c = System.Label.CustomerImageDocumentType;
        if (Schema.sObjectType.Documents__c.isCreateable()){
            insert document;
        }

        Blob bodyBlob1=Blob.valueOf('Passport Front');
        Blob bodyBlob2=Blob.valueOf('Passport Back'); 

        ContentVersion contentVersion1 = new ContentVersion(Title='SampleTitle1', PathOnClient ='SampleTitle1.jpg', VersionData = bodyBlob1, origin = 'H', Document_Side_fileupload__c = 'Front');
        ContentVersion contentVersion2 = new ContentVersion(Title='SampleTitle2', PathOnClient ='SampleTitle2.jpg', VersionData = bodyBlob2, origin = 'H', Document_Side_fileupload__c = 'Back');
        
        insert contentVersion1;
        insert contentVersion2;
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        //create ContentDocumentLink  record 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = document.id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        insert cdl;
        
        ContentDocumentLink cdl2 = New ContentDocumentLink();
        cdl2.LinkedEntityId = document.id;
        cdl2.ContentDocumentId = documents[1].Id;
        cdl2.shareType = 'V';
        insert cdl2;      
    }
    
    @isTest
    public static void handleBeforeDeleteTest(){
        try{
            List<ContentDocument> contDocList = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
            
            Test.startTest();
                ContentDocumentTriggerHandler.handleBeforeDelete(contDocList);
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }

    @isTest
    public static void handleBeforeUpdateTest(){
        try{
            List<ContentDocument> contDocList = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
            
            Test.startTest();
                ContentDocumentTriggerHandler.handleBeforeUpdate(contDocList);
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }

    @isTest
    public static void updateDocumentCountTest(){
        try{
            List<ContentDocument> contDocList = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
            
            Test.startTest();
                ContentDocumentTriggerHandler.updateDocumentCount(contDocList);
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
}