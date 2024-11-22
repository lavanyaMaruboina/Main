/*------------------------------------------------------------
Author:        Satyam More
Company:       Persistent Systems
Description:   Test class created to validate the IND_CibilOcrFrontUploadRequest IND_CibilOcrFrontUploadService IND_CibilOcrFrontUploadResponse class
History
Date            Author              Comments
-------------------------------------------------------------
12-12-2021      Satyam More       Created
------------------------------------------------------------*/

@isTest(SeeAllData=false)
public class IND_CibilOcrFrontUploadService_Test {

    @isTest
    public static void testCibilOcrFrontUploadService(){
        
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
            
          	Documents__c document = TestDataUtility.createTestKYCDocsForOcrFront(false,applicant,opp);
            document.Opportunity_Relation__c=opp.Id;
            if (Schema.sObjectType.Documents__c.isCreateable()){
                insert document;
            }
            
            Blob bodyBlob=Blob.valueOf('Aadhaar Front'); 
            
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
           
            String loanAppId = '00671000001DVS1AAO';
            Continuation con = (Continuation)IntegrationEngine.doCibilOcrFrontUploadCallout(document.id, contentVersion_2.contentdocumentid,loanAppId);
            // Create a mock response
            HttpResponse response = new HttpResponse();
            response.setBody('{"JData":"o6uyufeDGbQY1hKjC/W6jL+xpjtDh33Y6IRD2dGYsCI="}');
                response.setStatusCode(200);
            
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
            Object continuationState= IntegrationEngine.continuationState;
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
            String cibilOcrFrontUploadCallOutResponse= (String)IntegrationEngine.processCibilOcrFrontUploadResponse(labels, IntegrationEngine.continuationState);
            Test.stopTest();
            
            String responseExpected = '{"body":null,"ResponseData":null,"RequestId":null}';
            System.assertEquals(responseExpected, cibilOcrFrontUploadCallOutResponse, 'SUCCESS');
        
        } catch(Exception ex){
            System.assertEquals(ex.getMessage(),'Please enter the Maker Id', 'Exception');
        }
    }
    
    @isTest
    public static void testCibilOcrFrontUploadService2(){
        
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
            
          	Documents__c document = TestDataUtility.createTestKYCDocsForOcrFront2(false,applicant,opp);
            document.Opportunity_Relation__c=opp.Id;
            if (Schema.sObjectType.Documents__c.isCreateable()){
                insert document;
            }
            
            Blob bodyBlob=Blob.valueOf('Passport Front'); 
            
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
                        String loanAppId = '00671000001DVS1AAO';
            Continuation con = (Continuation)IntegrationEngine.doCibilOcrFrontUploadCallout(document.id, contentVersion_2.contentdocumentid,loanAppId);            // Create a mock response
            HttpResponse response = new HttpResponse();
            response.setBody('{"JData":"ymzMXT3Y/YT3EworMr3/kM598Ve8NCSsoBK4gPtThTE="}');
                response.setStatusCode(200);
            
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
            Object continuationState= IntegrationEngine.continuationState;
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
            String cibilOcrFrontUploadCallOutResponse= (String)IntegrationEngine.processCibilOcrFrontUploadResponse(labels, IntegrationEngine.continuationState);
            Test.stopTest();
            
            String responseExpected = '{"body":null,"ResponseData":null,"RequestId":null}';
            System.assertEquals(responseExpected, cibilOcrFrontUploadCallOutResponse, 'SUCCESS');
        
        } catch(Exception ex){
            System.assertEquals(ex.getMessage(),'Please enter the Maker Id', 'Exception');
        }
    }
    
    @isTest
    public static void testCibilOcrFrontUploadService3(){
        
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
            
          	Documents__c document = TestDataUtility.createTestKYCDocsForOcrFront3(false,applicant,opp);
            document.Opportunity_Relation__c=opp.Id;
            if (Schema.sObjectType.Documents__c.isCreateable()){
                insert document;
            }
            
            Blob bodyBlob=Blob.valueOf('PAN Front'); 
            
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
                        String loanAppId = '00671000001DVS1AAO';
            Continuation con = (Continuation)IntegrationEngine.doCibilOcrFrontUploadCallout(document.id, contentVersion_2.contentdocumentid,loanAppId);
            // Create a mock response
            HttpResponse response = new HttpResponse();
            response.setBody('{"JData":"w7VgHplOsc900ZPs11HVqmETBwJbC/PzCx1MM/8B6Uk="}');
                response.setStatusCode(200);
            
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
            Object continuationState= IntegrationEngine.continuationState;
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
            String cibilOcrFrontUploadCallOutResponse= (String)IntegrationEngine.processCibilOcrFrontUploadResponse(labels, IntegrationEngine.continuationState);
            Test.stopTest();
            
            String responseExpected = '{"body":null,"ResponseData":null,"RequestId":null}';
            //System.assertEquals(responseExpected, cibilOcrFrontUploadCallOutResponse, 'SUCCESS');
        
        } catch(Exception ex){
            //System.assertEquals(ex.getMessage(),'Please enter the Maker Id', 'Exception');
        }
    }
    
    @isTest
    public static void testCibilOcrFrontUploadService4(){
        
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
            
          	Documents__c document = TestDataUtility.createTestKYCDocsForOcrFront4(false,applicant,opp);
            document.Opportunity_Relation__c=opp.Id;
            if (Schema.sObjectType.Documents__c.isCreateable()){
                insert document;
            }
            
            Blob bodyBlob=Blob.valueOf('Driving Licence Front'); 
            
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
                        String loanAppId = '00671000001DVS1AAO';
            Continuation con = (Continuation)IntegrationEngine.doCibilOcrFrontUploadCallout(document.id, contentVersion_2.contentdocumentid,loanAppId);
            // Create a mock response
            HttpResponse response = new HttpResponse();
            response.setBody('{"JData":"9gFywlRQdc0xFMeQHCRoxWRsPndzBgN9lJKEPKFUv/2Cxl8Fi8b2xRtlNeVmRWjm"}');
                response.setStatusCode(200);
            
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
            Object continuationState= IntegrationEngine.continuationState;
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
            String cibilOcrFrontUploadCallOutResponse= (String)IntegrationEngine.processCibilOcrFrontUploadResponse(labels, IntegrationEngine.continuationState);
            Test.stopTest();
            
            String responseExpected = '{"body":null,"ResponseData":null,"RequestId":null}';
            //System.assertEquals(responseExpected, cibilOcrFrontUploadCallOutResponse, 'SUCCESS');
        
        } catch(Exception ex){
            //System.assertEquals(ex.getMessage(),'Please enter file type', 'Exception');
        }
    }
    
    @isTest
    public static void testCibilOcrFrontUploadService5(){
        
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
            
          	Documents__c document = TestDataUtility.createTestKYCDocsForOcrFront5(false,applicant,opp);
            document.Opportunity_Relation__c=opp.Id;
            if (Schema.sObjectType.Documents__c.isCreateable()){
                insert document;
            }
            
            Blob bodyBlob=Blob.valueOf('Voter Id Front'); 
            
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
                        String loanAppId = '00671000001DVS1AAO';
            Continuation con = (Continuation)IntegrationEngine.doCibilOcrFrontUploadCallout(document.id, contentVersion_2.contentdocumentid,loanAppId);
            // Create a mock response
            HttpResponse response = new HttpResponse();
            response.setBody('{"JData":"l5+h8xRvbvF5Yd391BKY7JVToC7NAtyZDGfoKb35OiQ="}');
                response.setStatusCode(200);
            
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
            Object continuationState= IntegrationEngine.continuationState;
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
            String cibilOcrFrontUploadCallOutResponse= (String)IntegrationEngine.processCibilOcrFrontUploadResponse(labels, IntegrationEngine.continuationState);
            Test.stopTest();
            
            String responseExpected = '{"body":null,"ResponseData":null,"RequestId":null}';
            //System.assertEquals(responseExpected, cibilOcrFrontUploadCallOutResponse, 'SUCCESS');
        
        } catch(Exception ex){
            //System.assertEquals(ex.getMessage(),'Please enter the Maker Id', 'Exception');
        }
    }
    
    @isTest
    public static void testCibilOcrFrontUploadService6(){
        
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
            
          	Documents__c document = TestDataUtility.createTestKYCDocsForOcrFront6(false,applicant,opp);
            document.Opportunity_Relation__c=opp.Id;
            if (Schema.sObjectType.Documents__c.isCreateable()){
                insert document;
            }
            
            Blob bodyBlob=Blob.valueOf('test'); 
            
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
                        String loanAppId = '00671000001DVS1AAO';
            Continuation con = (Continuation)IntegrationEngine.doCibilOcrFrontUploadCallout(document.id, contentVersion_2.contentdocumentid,loanAppId);
            // Create a mock response
            HttpResponse response = new HttpResponse();
            response.setBody('{"JData":"PdEPQCw75NP9tfN9BkVMFeXPeZtsufq3j0JQEh7upqk="}');
                response.setStatusCode(200);
            
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
            Object continuationState= IntegrationEngine.continuationState;
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
            String cibilOcrFrontUploadCallOutResponse= (String)IntegrationEngine.processCibilOcrFrontUploadResponse(labels, IntegrationEngine.continuationState);
            Test.stopTest();
            
            String responseExpected = '{"example":"test"}';
            //System.assertEquals(responseExpected, cibilOcrFrontUploadCallOutResponse, 'SUCCESS');
        
        } catch(Exception ex){
            //System.assertEquals(ex.getMessage(),System.Label.OCRFileType, 'Exception');
        }
    }
    
    @isTest
    public static void testCibilOcrFrontUploadService7(){
        
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
            
          	Documents__c document = TestDataUtility.createTestKYCDocsForOcrFront(false,applicant,opp);
            document.Opportunity_Relation__c=opp.Id;
            if (Schema.sObjectType.Documents__c.isCreateable()){
                insert document;
            }
            
            Blob bodyBlob=Blob.valueOf('Aadhaar Front'); 
            
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
           
                        String loanAppId = '00671000001DVS1AAO';
            Continuation con = (Continuation)IntegrationEngine.doCibilOcrFrontUploadCallout(document.id, contentVersion_2.contentdocumentid,loanAppId);
            // Create a mock response
            HttpResponse response = new HttpResponse();
            response.setBody('{"JData":"o6uyufeDGbQY1hKjC/W6jL+xpjtDh33Y6IRD2dGYsCI="}');
                response.setStatusCode(200);
            
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
            Object continuationState= IntegrationEngine.continuationState;
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
            String cibilOcrFrontUploadCallOutResponse= (String)IntegrationEngine.processCibilOcrFrontUploadResponse(labels, IntegrationEngine.continuationState);
            Test.stopTest();
            
            String responseExpected = '{"body":null,"ResponseData":null,"RequestId":null}';
          //System.assertEquals(responseExpected, cibilOcrFrontUploadCallOutResponse, 'SUCCESS');
        
        } catch(Exception ex){
            //System.assertEquals(ex.getMessage(),'Insert failed. First exception on row 0; first error: CANNOT_INSERT_UPDATE_ACTIVATE_ENTITY, record type missing for: Account: []', 'Exception');
        }
    }
    
      @isTest
    public static void testCibilOcrFrontUploadService8(){
        
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
            
          	Documents__c document = TestDataUtility.createTestKYCDocsForOcrFront(false,applicant,opp);
            document.Opportunity_Relation__c=opp.Id;
            if (Schema.sObjectType.Documents__c.isCreateable()){
                insert document;
            }
            
            Blob bodyBlob=Blob.valueOf('Aadhaar Front'); 
            
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
           
            String loanAppId = '00671000001DVS1AAO';
            Continuation con = (Continuation)IntegrationEngine.doCibilOcrFrontUploadCallout(document.id, contentVersion_2.contentdocumentid,loanAppId);
            // Create a mock response
            HttpResponse response = new HttpResponse();
            response.setBody('{"JData":"o6uyufeDGbQY1hKjC/W6jL+xpjtDh33Y6IRD2dGYsCI="}');
                response.setStatusCode(500);
            
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
            Object continuationState= IntegrationEngine.continuationState;
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
            String cibilOcrFrontUploadCallOutResponse= (String)IntegrationEngine.processCibilOcrFrontUploadResponse(labels, IntegrationEngine.continuationState);
            Test.stopTest();
            
            String responseExpected = '{"body":null,"ResponseData":null,"RequestId":null}';
            //System.assertEquals(responseExpected, cibilOcrFrontUploadCallOutResponse, 'SUCCESS');
        
        } catch(Exception ex){
            System.assertEquals(ex.getMessage(),'No Response Found.', 'Exception');
        }
    }
    
    /*@isTest
    public static void testCibilOcrFrontUploadService8(){
        
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
            
          	Documents__c document = TestDataUtility.createTestKYCDocsForOcrFront(false,applicant,opp);
            document.Opportunity_Relation__c=opp.Id;
            if (Schema.sObjectType.Documents__c.isCreateable()){
                insert document;
            }
            
            Blob bodyBlob=Blob.valueOf('Aadhaar Front'); 
            
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
           
                        String loanAppId = '00671000001DVS1AAO';
            Continuation con = (Continuation)IntegrationEngine.doCibilOcrFrontUploadCallout(document.id, contentVersion_2.contentdocumentid,loanAppId);
            // Create a mock response
            HttpResponse response = new HttpResponse();
            response.setBody('{"JData":"o6uyufeDGbQY1hKjC/W6jL+xpjtDh33Y6IRD2dGYsCI="}');
                response.setStatusCode(500); 
            
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
            Object continuationState= IntegrationEngine.continuationState;
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
            String cibilOcrFrontUploadCallOutResponse= (String)IntegrationEngine.processCibilOcrFrontUploadResponse(labels, IntegrationEngine.continuationState);
            Test.stopTest();
            
            String responseExpected = '{"body":null,"ResponseData":null,"RequestId":null}';
            System.assertEquals(responseExpected, cibilOcrFrontUploadCallOutResponse, 'SUCCESS');
        
        } catch(Exception ex){
            System.assertEquals(ex.getMessage(),'Please enter the Maker Id', 'Exception');
        }
    }*/
}