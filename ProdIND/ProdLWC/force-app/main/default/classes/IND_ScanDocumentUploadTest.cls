/*------------------------------------------------------------
Author:        Aman Mundhada
Company:       Persistent Systems
Description:   Test class created to validate the IND_ScanDocumentUpload API
History
Date            Author              Comments
-------------------------------------------------------------
17-02-2022      Aman Mundhada       Created
------------------------------------------------------------*/
@isTest(SeeAllData=false)
public class IND_ScanDocumentUploadTest {
    @testSetup
    static void setupTestData(){
        Profile p = [SELECT Id FROM Profile WHERE Name='CMU'];   
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',MobilePhone = '9999999999',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles',
                          UserName='standarduser4@testorg.com.psdev1');
        insert u;
    }
    
    @isTest
    public static void testINDScanDocumentUpload(){       
        try{   
            
            User u=[SELECT Id from User WHERE UserName = 'standarduser4@testorg.com.psdev1'];
            
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            
            Applicant__c applicant = TestDataUtility.createTestApplicant(false);
            applicant.Opportunity__c=opp.Id;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert applicant;
            }
            
            Documents__c document = TestDataUtility.createTestKYCDocsForOcrFront(false,applicant,opp);
            document.Opportunity_Relation__c=opp.Id;
            if (Schema.sObjectType.Documents__c.isCreateable()){
                insert document;
            }
            
            Blob bodyBlob=Blob.valueOf('Bank Statement'); 
            
            final ContentVersion contentVersion_1 = new ContentVersion(
                Title='SampleTitle', 
                PathOnClient ='SampleTitle.jpg',
                VersionData = bodyBlob, 
                origin = 'H',
                Document_Side_fileupload__c = 'Front'
            );
            insert contentVersion_1;
            
            final ContentVersion contentVersion_2 = [SELECT Id, Title, ContentDocumentId 
                                                     FROM ContentVersion WHERE Id = :contentVersion_1.Id LIMIT 1];
            
            ContentDocumentLink contentlink = new ContentDocumentLink();
            contentlink.LinkedEntityId = document.id;
            contentlink.contentdocumentid = contentVersion_2.contentdocumentid;
            contentlink.ShareType = 'V';
            insert contentlink;
            
            String scanDocumentUploadCallOutRequest = '{"perfiosTransactionId":"2ET81644576294904" ,"contentId":"'+contentVersion_2.contentdocumentid+'"}';
            //  Continuation con = (Continuation)IntegrationEngine.doScanDocumentUpload(scanDocumentUploadCallOutRequest);
            HttpResponse response = new HttpResponse();
            response.setBody('{"JData":"rOrlD78G4XgCZ1qt0ydb90MRQhM5WBlYAkrG5ciw7IdUYAyk0rb1j6qNvDE5WwQ/trKk+rwfHQR1AiIrAsUwsdqVnvfarJKxnxATxz3lIsI1FXT26JEdt22mWZV8mAfu5KFHL0FUie0ZkerfYlRMVbrgn8ayc58xk/MFmOEVR24Gpo3tfl80bfhGqJuz+p5j"}');
            response.setStatusCode(200);
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
                Object continuationState= IntegrationEngine.continuationState;
            String scanDocumentUploadCallOutResponse='';
            system.runAs(u){
                Test.startTest();
                Test.setContinuationResponse(continuationLabel, response);
                //  scanDocumentUploadCallOutResponse=(String)IntegrationEngine.processScanDocumentUploadResponse(labels, IntegrationEngine.continuationState);
                Test.stopTest();
            }    
            String responseExpected ='{  "error" : {"code" : "NoActiveTransaction","message" : "We could not find an active transaction corresponding to this transaction Id"}}';        
            responseExpected= JSON.serializePretty(JSON.deserializeUntyped(responseExpected));
            System.assertEquals(responseExpected,scanDocumentUploadCallOutResponse,'Success');
            
        } catch(Exception ex){
            System.assertEquals(ex.getMessage(),'Null label');
        }
    }     
}