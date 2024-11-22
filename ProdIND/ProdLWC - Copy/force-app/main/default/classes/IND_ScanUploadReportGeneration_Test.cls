/*------------------------------------------------------------
Author:        Aman Mundhada
Company:       Persistent Systems
Description:   Test class created to validate the IND_ScanUploadReportGenerationRequest IND_ScanUploadReportGenerationService class
History
Date            Author              Comments
-------------------------------------------------------------
13-01-2021      Aman Mundhada       Created
------------------------------------------------------------*/
@isTest(SeeAllData=false)
public class IND_ScanUploadReportGeneration_Test {

         @isTest
    public static void testINDScanUploadReportGenerationService(){
        
        try{   
            String scanUploadProcessCallOutRequest = '{"perfiosTransactionId":"R7Y71641289497542"}';
            Continuation con = (Continuation)IntegrationEngine.doScanUploadReportGeneration(scanUploadProcessCallOutRequest);
            HttpResponse response = new HttpResponse();
            response.setBody('{"JData":"oxsntvu9HAvlIXWS4iwcf/tmimQo7pOi8M1eLAEel8o="}');
        	response.setStatusCode(200);
            String continuationLabel = IntegrationEngine.continuationLabel;
 		    List<String> labels = new List<String>{continuationLabel};
            Object continuationState= IntegrationEngine.continuationState;         
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
       //     String scanUploadProcessCallOutResponse=(String)IntegrationEngine.processScanUploadReportGenerationResponse(labels, IntegrationEngine.continuationState);
            Test.stopTest();
            String responseExpected ='{"success": {}}';
            responseExpected= JSON.serializePretty(JSON.deserializeUntyped(responseExpected));
      //      System.assertEquals(responseExpected,scanUploadProcessCallOutResponse,'Success');
            
        } catch(Exception ex){
         //   System.assertEquals(ex.getMessage(),'Attempt to de-reference a null object');
        }
    }
    
     @isTest
    public static void testINDScanUploadReportGenerationService1(){
        
        try{   
            String scanUploadProcessCallOutRequest = '{"perfiosTransactionId":"R7Y71641289497542"}';
            Continuation con = (Continuation)IntegrationEngine.doScanUploadReportGeneration(scanUploadProcessCallOutRequest);
            HttpResponse response = new HttpResponse();
            response.setBody('{"JData":"oxsntvu9HAvlIXWS4iwcf/tmimQo7pOi8M1eLAEel8o="}');
        	response.setStatusCode(500);
            String continuationLabel = IntegrationEngine.continuationLabel;
 		    List<String> labels = new List<String>{continuationLabel};
            Object continuationState= IntegrationEngine.continuationState;         
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
       //     String scanUploadProcessCallOutResponse=(String)IntegrationEngine.processScanUploadReportGenerationResponse(labels, IntegrationEngine.continuationState);
            Test.stopTest();
            String responseExpected ='{"success": {}}';
            responseExpected= JSON.serializePretty(JSON.deserializeUntyped(responseExpected));
      //      System.assertEquals(responseExpected,scanUploadProcessCallOutResponse,'Success');
            
        } catch(Exception ex){
         //   System.assertEquals(ex.getMessage(),'Attempt to de-reference a null object');
        }
    }
    
    @isTest
    public static void validateTest(){
        Test.startTest();
             IND_ScanUploadReportGenerationRequest gr1 = new IND_ScanUploadReportGenerationRequest();
             gr1.validate('test');
        Test.stopTest();
    }
    
}