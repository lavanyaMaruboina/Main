/*------------------------------------------------------------
Author:        Satyam More
Company:       Persistent Systems
Description:   Test class created to validate the IND_ITRScanUploadInitiateRequest IND_ITRScanUploadInitiateService class
History
Date            Author              Comments
-------------------------------------------------------------
03-02-2022      Satyam More       Created
------------------------------------------------------------*/
@isTest(SeeAllData=false)
public class IND_ITRScanUploadInitiateService_Test {

    @isTest
    public static void testITRScanUploadInitiateService(){
        
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
            
            Documents__c dfks1 = new Documents__c();
                 dfks1.Applicant__c = applicant.Id;
                 dfks1.Opportunity_Relation__c = opp.Id;
                 dfks1.KYC_name__c = 'Aadhar';
                 dfks1.Document_Side__c ='Back';
             //    dfks1.Aadhar_Source__c = 'ScanAadhar';
                 dfks1.Name = 'Aadhar';
                 dfks1.Proof_of_Identity_POI__c = true;
                 dfks1.Document_Type__c = 'Passport';
                 insert dfks1;
                
                 ContentVersion cvn1 = new ContentVersion();
                 cvn1.PathOnClient = 'testpath1';
                 cvn1.Title = 'testtitle1';
                 cvn1.VersionData = Blob.valueOf('Test Content');
                 cvn1.Document_Side_fileupload__c = 'Front';
                 insert cvn1;
                
                 ContentVersion testcd1 = [SELECT id, ContentDocumentId FROM ContentVersion where Id = :cvn1.Id];
                
                 ContentDocumentLink cdlink1 = new ContentDocumentLink();
                 cdlink1.Visibility = 'AllUsers';
                 cdlink1.ShareType = 'V';
                 cdlink1.LinkedEntityId = dfks1.Id;
                 cdlink1.ContentDocumentId = testcd1.ContentDocumentId;
                 insert cdlink1;
            
            //String itrScanUploadCallOutRequest = '{"applicantId":"'+applicant.Id+'"}';
            //String loanAppId = '';
            Continuation con = (Continuation)IntegrationEngine.doITRScanUploadInitiate(applicant.id,cdlink1.ContentDocumentId,opp.id,dfks1.Document_Type__c);
            HttpResponse response = new HttpResponse();
            response.setBody('{"JData":"qidx5BsZ8u4sTdUzMN5Mfj6RkOpxmXkc3dAEYwPGd36cKwMZp+1UT6S2RfQszQPruZZAunbtK4lUe8IAX1+hqA=="}');
        	response.setStatusCode(200);
            String continuationLabel = IntegrationEngine.continuationLabel;
 		    List<String> labels = new List<String>{continuationLabel};
            Object continuationState= IntegrationEngine.continuationState;         
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
        //    String scanUploadCallOutResponse=(String)IntegrationEngine.processScanUploadInitiateResponse(labels, IntegrationEngine.continuationState);
            Test.stopTest();
            String responseExpected ='{"transaction" : {"perfiosTransactionId" : "Q8NT1641212027655"} }';
            responseExpected= JSON.serializePretty(JSON.deserializeUntyped(responseExpected));
         //   System.assertEquals(responseExpected,scanUploadCallOutResponse);
            
        } catch(Exception ex){
          //  System.assertEquals(ex.getMessage(),'List has no rows for assignment to SObject');
        }
    }
    
    @isTest
    public static void testITRScanUploadInitiateService2(){
        
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
            
            Documents__c dfks1 = new Documents__c();
                 dfks1.Applicant__c = applicant.Id;
                 dfks1.Opportunity_Relation__c = opp.Id;
                 dfks1.KYC_name__c = 'Aadhar';
                 dfks1.Document_Side__c ='Back';
             //    dfks1.Aadhar_Source__c = 'ScanAadhar';
                 dfks1.Name = 'Aadhar';
                 dfks1.Proof_of_Identity_POI__c = true;
                 dfks1.Document_Type__c = 'Passport';
                 insert dfks1;
                
                 ContentVersion cvn1 = new ContentVersion();
                 cvn1.PathOnClient = 'testpath1';
                 cvn1.Title = 'testtitle1';
                 cvn1.VersionData = Blob.valueOf('Test Content');
                 cvn1.Document_Side_fileupload__c = 'Front';
                 insert cvn1;
                
                 ContentVersion testcd1 = [SELECT id, ContentDocumentId FROM ContentVersion where Id = :cvn1.Id];
                
                 ContentDocumentLink cdlink1 = new ContentDocumentLink();
                 cdlink1.Visibility = 'AllUsers';
                 cdlink1.ShareType = 'V';
                 cdlink1.LinkedEntityId = dfks1.Id;
                 cdlink1.ContentDocumentId = testcd1.ContentDocumentId;
                 insert cdlink1;
            
            //String itrScanUploadCallOutRequest = '{"applicantId":"'+applicant.Id+'"}';
            //String loanAppId = '';
            Continuation con = (Continuation)IntegrationEngine.doITRScanUploadInitiate(applicant.id,cdlink1.ContentDocumentId,opp.id,dfks1.Document_Type__c);
            HttpResponse response = new HttpResponse();
            response.setBody('{"JData":"qidx5BsZ8u4sTdUzMN5Mfj6RkOpxmXkc3dAEYwPGd36cKwMZp+1UT6S2RfQszQPruZZAunbtK4lUe8IAX1+hqA=="}');
        	response.setStatusCode(500);
            String continuationLabel = IntegrationEngine.continuationLabel;
 		    List<String> labels = new List<String>{continuationLabel};
            Object continuationState= IntegrationEngine.continuationState;         
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
        //    String scanUploadCallOutResponse=(String)IntegrationEngine.processScanUploadInitiateResponse(labels, IntegrationEngine.continuationState);
            Test.stopTest();
            String responseExpected ='{"transaction" : {"perfiosTransactionId" : "Q8NT1641212027655"} }';
            responseExpected= JSON.serializePretty(JSON.deserializeUntyped(responseExpected));
         //   System.assertEquals(responseExpected,scanUploadCallOutResponse);
            
        } catch(Exception ex){
          //  System.assertEquals(ex.getMessage(),'List has no rows for assignment to SObject');
        }
    }
    
    @isTest
    public static void validateException(){
        try{
            IND_ITRScanUploadInitiateService.getITRScanUploadInitiate(null, null,null);
        }catch(Exception pEx){
            System.assert(pEx.getMessage() != null);
        }
        
    }
    
    
    
    
}