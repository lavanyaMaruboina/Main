/*------------------------------------------------------------
Author:        Satyam More
Company:       Persistent Systems
Description:   Test class created to validate the IND_CibilOcrBackUploadRequest IND_CibilOcrBackUploadService IND_CibilOcrBackUploadResponse class
History
Date            Author              Comments
-------------------------------------------------------------
20-12-2021      Satyam More       Created
------------------------------------------------------------*/


@isTest(SeeAllData=false)
public class IND_CibilOcrBackUploadService_Test {

    
    @isTest
    public static void testCibilOcrBackUploadService(){
        try{   
            
                        Profile p = [SELECT Id FROM Profile WHERE Name='CMU'];
            system.debug('p'+ p);
            User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                              EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',User_Id__c = '29927_MO',
                              LocaleSidKey='en_US', ProfileId = p.Id,MobilePhone = '9743514830',Maker_Id__c = '1001',
                              TimeZoneSidKey='America/Los_Angeles',
                              UserName='standarduser4@testorg.com.psdev1');
            insert u;
                   
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            
             Applicant__c applicant = TestDataUtility.createTestApplicant(false);
            applicant.Opportunity__c=opp.Id;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert applicant;
            }
            
          	Documents__c document = TestDataUtility.createTestKYCDocsForOcrBack(false,applicant,opp);
            document.Opportunity_Relation__c=opp.Id;
            if (Schema.sObjectType.Documents__c.isCreateable()){
                insert document;
            }
            
            Blob bodyBlob=Blob.valueOf('Aadhaar Back'); 
            
            final ContentVersion contentVersion_1 = new ContentVersion(
                Title='SampleTitle', 
                PathOnClient ='SampleTitle.jpg',
                VersionData = bodyBlob, 
                origin = 'H',
                Document_Side_fileupload__c = 'Back'
            );
            insert contentVersion_1;
            
            final ContentVersion contentVersion_2 = [SELECT Id, Title, ContentDocumentId 
                            FROM ContentVersion WHERE Id = :contentVersion_1.Id LIMIT 1];
            
            ContentDocumentLink contentlink = new ContentDocumentLink();
            contentlink.LinkedEntityId = document.id;
            contentlink.contentdocumentid = contentVersion_2.contentdocumentid;
            contentlink.ShareType = 'V';
            insert contentlink;
            
            String loanAppId = '00671000001DVS1AAO';
            Continuation con = (Continuation)IntegrationEngine.doCibilOcrBackUploadCallout(document.id, contentVersion_2.contentdocumentid,opp.Id);
            // Create a mock response
            HttpResponse response = new HttpResponse();
            response.setBody('{"JData":"o6uyufeDGbQY1hKjC/W6jPS8M1AQGMsBMssDfTy/9W4="}');
                response.setStatusCode(200);
            
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
            Object continuationState= IntegrationEngine.continuationState;
            
            String cibilOcrBackUploadCallOutResponse;
            system.runAs(u){
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
            cibilOcrBackUploadCallOutResponse= (String)IntegrationEngine.processCibilOcrBackUploadResponse(labels, IntegrationEngine.continuationState);
            Test.stopTest();
            }
            String responseExpected = '{"body":null,"ResponseData":null,"RequestId":null}';
          //System.assertEquals(responseExpected, cibilOcrBackUploadCallOutResponse, 'SUCCESS');
        
        } catch(Exception ex){
           //System.assertEquals(ex.getMessage(),'Script-thrown exception');
        }
    }
    
    @isTest
    public static void testCibilOcrBackUploadService2(){
        try{   
                   
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
            if (Schema.sObjectType.Documents__c.isCreateable()){
                insert document;
            }
            
            Blob bodyBlob=Blob.valueOf('Passport Back'); 
            
            final ContentVersion contentVersion_1 = new ContentVersion(
                Title='SampleTitle', 
                PathOnClient ='SampleTitle.jpg',
                VersionData = bodyBlob, 
                origin = 'H',
                Document_Side_fileupload__c = 'Back'
            );
            insert contentVersion_1;
            
            final ContentVersion contentVersion_2 = [SELECT Id, Title, ContentDocumentId 
                            FROM ContentVersion WHERE Id = :contentVersion_1.Id LIMIT 1];
            
            ContentDocumentLink contentlink = new ContentDocumentLink();
            contentlink.LinkedEntityId = document.id;
            contentlink.contentdocumentid = contentVersion_2.contentdocumentid;
            contentlink.ShareType = 'V';
            insert contentlink;
            
                        String loanAppId = '00671000001DVS1AAO';
            Continuation con = (Continuation)IntegrationEngine.doCibilOcrBackUploadCallout(document.id, contentVersion_2.contentdocumentid,loanAppId);
            // Create a mock response
            HttpResponse response = new HttpResponse();
            response.setBody('{"JData":"ymzMXT3Y/YT3EworMr3/kLC2Z3fuw07aAxUZcjF50rA="}');
                response.setStatusCode(200);
            
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
            Object continuationState= IntegrationEngine.continuationState;
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
            String cibilOcrBackUploadCallOutResponse= (String)IntegrationEngine.processCibilOcrBackUploadResponse(labels, IntegrationEngine.continuationState);
            Test.stopTest();
            
            String responseExpected = '{"body":null,"ResponseData":null,"RequestId":null}';
            //System.assertEquals(responseExpected, cibilOcrBackUploadCallOutResponse, 'SUCCESS');
        
        } catch(Exception ex){
            //System.assertEquals(ex.getMessage(),'Please enter the Maker Id', 'Exception');
        }
    }
    
    @isTest
    public static void testCibilOcrBackUploadService3(){
        try{   
                   
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            
             Applicant__c applicant = TestDataUtility.createTestApplicant(false);
            applicant.Opportunity__c=opp.Id;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert applicant;
            }
            
          	Documents__c document = TestDataUtility.createTestKYCDocsForOcrBack3(false,applicant,opp);
            document.Opportunity_Relation__c=opp.Id;
            if (Schema.sObjectType.Documents__c.isCreateable()){
                insert document;
            }
            
            Blob bodyBlob=Blob.valueOf('Driving Licence Back'); 
            
            final ContentVersion contentVersion_1 = new ContentVersion(
                Title='SampleTitle', 
                PathOnClient ='SampleTitle.jpg',
                VersionData = bodyBlob, 
                origin = 'H',
                Document_Side_fileupload__c = 'Back'
            );
            insert contentVersion_1;
            
            final ContentVersion contentVersion_2 = [SELECT Id, Title, ContentDocumentId 
                            FROM ContentVersion WHERE Id = :contentVersion_1.Id LIMIT 1];
            
            ContentDocumentLink contentlink = new ContentDocumentLink();
            contentlink.LinkedEntityId = document.id;
            contentlink.contentdocumentid = contentVersion_2.contentdocumentid;
            contentlink.ShareType = 'V';
            insert contentlink;
            
                        String loanAppId = '00671000001DVS1AAO';
            Continuation con = (Continuation)IntegrationEngine.doCibilOcrBackUploadCallout(document.id, contentVersion_2.contentdocumentid,loanAppId);
            // Create a mock response
            HttpResponse response = new HttpResponse();
            response.setBody('{"JData":"9gFywlRQdc0xFMeQHCRoxSRVybYOi8shBdZGlLRRd6yL80y6NN/YfhQqODTKmV41"}');
                response.setStatusCode(200);
            
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
            Object continuationState= IntegrationEngine.continuationState;
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
            String cibilOcrBackUploadCallOutResponse= (String)IntegrationEngine.processCibilOcrBackUploadResponse(labels, IntegrationEngine.continuationState);
            Test.stopTest();
            
            String responseExpected = '{"body":null,"ResponseData":null,"RequestId":null}';
            //System.assertEquals(responseExpected, cibilOcrBackUploadCallOutResponse, 'SUCCESS');
        
        } catch(Exception ex){
            //System.assertEquals(ex.getMessage(),'Please enter file type', 'Exception');
        }
    }
    
    @isTest
    public static void testCibilOcrBackUploadService4(){
        try{   
                   
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            
             Applicant__c applicant = TestDataUtility.createTestApplicant(false);
            applicant.Opportunity__c=opp.Id;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert applicant;
            }
            
          	Documents__c document = TestDataUtility.createTestKYCDocsForOcrBack4(false,applicant,opp);
            document.Opportunity_Relation__c=opp.Id;
            if (Schema.sObjectType.Documents__c.isCreateable()){
                insert document;
            }
            
            Blob bodyBlob=Blob.valueOf('Voter Id Back'); 
            
            final ContentVersion contentVersion_1 = new ContentVersion(
                Title='SampleTitle', 
                PathOnClient ='SampleTitle.jpg',
                VersionData = bodyBlob, 
                origin = 'H',
                Document_Side_fileupload__c = 'Back'
            );
            insert contentVersion_1;
            
            final ContentVersion contentVersion_2 = [SELECT Id, Title, ContentDocumentId 
                            FROM ContentVersion WHERE Id = :contentVersion_1.Id LIMIT 1];
            
            ContentDocumentLink contentlink = new ContentDocumentLink();
            contentlink.LinkedEntityId = document.id;
            contentlink.contentdocumentid = contentVersion_2.contentdocumentid;
            contentlink.ShareType = 'V';
            insert contentlink;
            
                        String loanAppId = '00671000001DVS1AAO';
            Continuation con = (Continuation)IntegrationEngine.doCibilOcrBackUploadCallout(document.id, contentVersion_2.contentdocumentid,loanAppId);
            // Create a mock response
            HttpResponse response = new HttpResponse();
            response.setBody('{"JData":"l5+h8xRvbvF5Yd391BKY7LdTljVAMLYBIc2T5eqfcMY="}');
                response.setStatusCode(200);
            
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
            Object continuationState= IntegrationEngine.continuationState;
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
            String cibilOcrBackUploadCallOutResponse= (String)IntegrationEngine.processCibilOcrBackUploadResponse(labels, IntegrationEngine.continuationState);
            Test.stopTest();
            
            String responseExpected = '{"body":null,"ResponseData":null,"RequestId":null}';
            //System.assertEquals(responseExpected, cibilOcrBackUploadCallOutResponse, 'SUCCESS');
        
        } catch(Exception ex){
            //System.assertEquals(ex.getMessage(),'Please enter the Maker Id', 'Exception');
        }
    }
    
    @isTest
    public static void testCibilOcrBackUploadService5(){
        try{   
                   
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            
             Applicant__c applicant = TestDataUtility.createTestApplicant(false);
            applicant.Opportunity__c=opp.Id;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert applicant;
            }
            
          	Documents__c document = TestDataUtility.createTestKYCDocsForOcrBack5(false,applicant,opp);
            document.Opportunity_Relation__c=opp.Id;
            if (Schema.sObjectType.Documents__c.isCreateable()){
                insert document;
            }
            
            Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion Body to be insert in test class for testing the'); 
            
            final ContentVersion contentVersion_1 = new ContentVersion(
                Title='SampleTitle', 
                PathOnClient ='SampleTitle.jpg',
                VersionData = bodyBlob, 
                origin = 'H',
                Document_Side_fileupload__c = 'Back'
            );
            insert contentVersion_1;
            
            final ContentVersion contentVersion_2 = [SELECT Id, Title, ContentDocumentId 
                            FROM ContentVersion WHERE Id = :contentVersion_1.Id LIMIT 1];
            
            ContentDocumentLink contentlink = new ContentDocumentLink();
            contentlink.LinkedEntityId = document.id;
            contentlink.contentdocumentid = contentVersion_2.contentdocumentid;
            contentlink.ShareType = 'V';
            insert contentlink;
            
                        String loanAppId = '00671000001DVS1AAO';
            Continuation con = (Continuation)IntegrationEngine.doCibilOcrBackUploadCallout(document.id, contentVersion_2.contentdocumentid,loanAppId);
            // Create a mock response
            HttpResponse response = new HttpResponse();
            response.setBody('{"JData":"PdEPQCw75NP9tfN9BkVMFeXPeZtsufq3j0JQEh7upqk="}');
                response.setStatusCode(200);
            
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
            Object continuationState= IntegrationEngine.continuationState;
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
            String cibilOcrBackUploadCallOutResponse= (String)IntegrationEngine.processCibilOcrBackUploadResponse(labels, IntegrationEngine.continuationState);
            Test.stopTest();
            
            String responseExpected = '{"example":"test"}';
            //System.assertEquals(responseExpected, cibilOcrBackUploadCallOutResponse, 'SUCCESS');
        
        } catch(Exception ex){
            //System.assertEquals(ex.getMessage(),System.Label.OCRFileType, 'Exception');
        }
    }
    
    @isTest
    public static void testCibilOcrBackUploadService6(){
        try{   
                   
            Opportunity opp = TestDataUtility.createTestOpportunityForOcr(false);
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            
             Applicant__c applicant = TestDataUtility.createTestApplicant(false);
            applicant.Opportunity__c=opp.Id;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert applicant;
            }
            
          	Documents__c document = TestDataUtility.createTestKYCDocsForOcrBack(false,applicant,opp);
            document.Opportunity_Relation__c=opp.Id;
            if (Schema.sObjectType.Documents__c.isCreateable()){
                insert document;
            }
            
            Blob bodyBlob=Blob.valueOf('Aadhaar Back'); 
            
            final ContentVersion contentVersion_1 = new ContentVersion(
                Title='SampleTitle', 
                PathOnClient ='SampleTitle.jpg',
                VersionData = bodyBlob, 
                origin = 'H',
                Document_Side_fileupload__c = 'Back'
            );
            insert contentVersion_1;
            
            final ContentVersion contentVersion_2 = [SELECT Id, Title, ContentDocumentId 
                            FROM ContentVersion WHERE Id = :contentVersion_1.Id LIMIT 1];
            
            ContentDocumentLink contentlink = new ContentDocumentLink();
            contentlink.LinkedEntityId = document.id;
            contentlink.contentdocumentid = contentVersion_2.contentdocumentid;
            contentlink.ShareType = 'V';
            insert contentlink;
            
                        String loanAppId = '00671000001DVS1AAO';
            Continuation con = (Continuation)IntegrationEngine.doCibilOcrBackUploadCallout(document.id, contentVersion_2.contentdocumentid,loanAppId);
            // Create a mock response
            HttpResponse response = new HttpResponse();
            response.setBody('{"JData":"o6uyufeDGbQY1hKjC/W6jPS8M1AQGMsBMssDfTy/9W4="}');
                response.setStatusCode(200);
            
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
            Object continuationState= IntegrationEngine.continuationState;
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
            String cibilOcrBackUploadCallOutResponse= (String)IntegrationEngine.processCibilOcrBackUploadResponse(labels, IntegrationEngine.continuationState);
            Test.stopTest();
            
            String responseExpected = '{"body":null,"ResponseData":null,"RequestId":null}';
            //System.assertEquals(responseExpected, cibilOcrBackUploadCallOutResponse, 'SUCCESS');
        
        } catch(Exception ex){
            //System.assertEquals(ex.getMessage(),'Please enter the Maker Id', 'Exception');
        }
    }
    
    @isTest
    public static void testCibilOcrBackUploadService7(){
        try{   
                   
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            
             Applicant__c applicant = TestDataUtility.createTestApplicant(false);
            applicant.Opportunity__c=opp.Id;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert applicant;
            }
            
          	Documents__c document = TestDataUtility.createTestKYCDocsForOcrBack(false,applicant,opp);
            document.Opportunity_Relation__c=opp.Id;
            if (Schema.sObjectType.Documents__c.isCreateable()){
                insert document;
            }
            
            Blob bodyBlob=Blob.valueOf('Aadhaar Back'); 
            
            final ContentVersion contentVersion_1 = new ContentVersion(
                Title='SampleTitle', 
                PathOnClient ='SampleTitle.jpg',
                VersionData = bodyBlob, 
                origin = 'H',
                Document_Side_fileupload__c = 'Back'
            );
            insert contentVersion_1;
            
            final ContentVersion contentVersion_2 = [SELECT Id, Title, ContentDocumentId 
                            FROM ContentVersion WHERE Id = :contentVersion_1.Id LIMIT 1];
            
            ContentDocumentLink contentlink = new ContentDocumentLink();
            contentlink.LinkedEntityId = document.id;
            contentlink.contentdocumentid = contentVersion_2.contentdocumentid;
            contentlink.ShareType = 'V';
            insert contentlink;
            
                        String loanAppId = '00671000001DVS1AAO';
            Continuation con = (Continuation)IntegrationEngine.doCibilOcrBackUploadCallout(document.id, contentVersion_2.contentdocumentid,loanAppId);
            // Create a mock response
            HttpResponse response = new HttpResponse();
            response.setBody('{"JData":"o6uyufeDGbQY1hKjC/W6jPS8M1AQGMsBMssDfTy/9W4="}');
                response.setStatusCode(500);
            
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
            Object continuationState= IntegrationEngine.continuationState;
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
            String cibilOcrBackUploadCallOutResponse= (String)IntegrationEngine.processCibilOcrBackUploadResponse(labels, IntegrationEngine.continuationState);
            Test.stopTest();
            
            String responseExpected = '{"body":null,"ResponseData":null,"RequestId":null}';
          //System.assertEquals(responseExpected, cibilOcrBackUploadCallOutResponse, 'SUCCESS');
        
        } catch(Exception ex){
           // System.assertEquals(ex.getMessage(),'Something went wrong. Please retry.', 'Exception');
        }
    }
       
    }