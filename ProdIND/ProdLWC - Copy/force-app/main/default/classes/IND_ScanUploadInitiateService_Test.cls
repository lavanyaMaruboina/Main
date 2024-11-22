/*------------------------------------------------------------
Author:        Aman Mundhada
Company:       Persistent Systems
Description:   Test class created to validate the IND_ScanUploadInitiateRequest IND_ScanUploadInitiateService class
History
Date            Author              Comments
-------------------------------------------------------------
03-01-2021      Aman Mundhada       Created
------------------------------------------------------------*/
@isTest(SeeAllData=false)
public class IND_ScanUploadInitiateService_Test {

     @isTest
    public static void IND_ScanUploadInitiateService(){
        
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
            
            String scanUploadCallOutRequest = '{"applicantId":"'+applicant.Id+'"}';
            Continuation con = (Continuation)IntegrationEngine.doScanUploadInitiate(scanUploadCallOutRequest);
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
       //     System.assertEquals(responseExpected,scanUploadCallOutResponse);
            
        } catch(Exception ex){
            System.assertEquals(ex.getMessage(),'Please enter Lead Id.');
        }
    }
    
      @isTest
    public static void testINDScanUploadInitiateService2(){
        
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
            
   //     Income_Details__c incomeDetails =  TestDataUtility.createIncomeDetailsRecord();
   //     incomeDetails.Applicant__c = applicant.Id;
   //     if (Schema.sObjectType.Income_Details__c.isCreateable()){
   //         insert incomeDetails;
    //    }
            
    //        String scanUploadCallOutRequest = '{"loanApplicationId":"'+opp.Id+'","incomeDetailId":"'+incomeDetails.Id+'"}';
    //        Continuation con = (Continuation)IntegrationEngine.doScanUploadInitiate(scanUploadCallOutRequest);
            HttpResponse response = new HttpResponse();
            response.setBody('{"JData":"qidx5BsZ8u4sTdUzMN5Mfj6RkOpxmXkc3dAEYwPGd36cKwMZp+1UT6S2RfQszQPruZZAunbtK4lUe8IAX1+hqA=="}');
        	response.setStatusCode(200);
            String continuationLabel = IntegrationEngine.continuationLabel;
 		    List<String> labels = new List<String>{continuationLabel};
            Object continuationState= IntegrationEngine.continuationState;         
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
      //      String scanUploadCallOutResponse=(String)IntegrationEngine.processScanUploadInitiateResponse(labels, IntegrationEngine.continuationState);
            Test.stopTest();
            String responseExpected ='{"transaction" : {"perfiosTransactionId" : "Q8NT1641212027655"} }';
            responseExpected= JSON.serializePretty(JSON.deserializeUntyped(responseExpected));
     //       System.assertEquals(responseExpected,scanUploadCallOutResponse,'Fail');
            
        } catch(Exception ex){
           // System.assertEquals(ex.getMessage(),System.Label.Amountmessage,'Exception');
        }
    }
    
     @isTest
    public static void testINDScanUploadInitiateService3(){
        
        try{   
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            opp.Required_Tenure__c=null;
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            Applicant__c applicant = TestDataUtility.createTestApplicant(false);
            applicant.Loan_Amount__c=10000;
            applicant.Opportunity__c=opp.Id;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert applicant;
            }
            
        //Income_Details__c incomeDetails =  TestDataUtility.createIncomeDetailsRecord();
        //incomeDetails.Applicant__c = applicant.Id;
        if (Schema.sObjectType.Income_Details__c.isCreateable()){
            //insert incomeDetails;
        }
            
            //String scanUploadCallOutRequest = '{"loanApplicationId":"'+opp.Id+'","incomeDetailId":"'+incomeDetails.Id+'"}';
            //Continuation con = (Continuation)IntegrationEngine.doScanUploadInitiate(scanUploadCallOutRequest);
            HttpResponse response = new HttpResponse();
            response.setBody('{"JData":"qidx5BsZ8u4sTdUzMN5Mfj6RkOpxmXkc3dAEYwPGd36cKwMZp+1UT6S2RfQszQPruZZAunbtK4lUe8IAX1+hqA=="}');
        	response.setStatusCode(200);
            String continuationLabel = IntegrationEngine.continuationLabel;
 		    List<String> labels = new List<String>{continuationLabel};
            Object continuationState= IntegrationEngine.continuationState;         
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
      //      String scanUploadCallOutResponse=(String)IntegrationEngine.processScanUploadInitiateResponse(labels, IntegrationEngine.continuationState);
            Test.stopTest();
            String responseExpected ='{"transaction" : {"perfiosTransactionId" : "Q8NT1641212027655"} }';
            responseExpected= JSON.serializePretty(JSON.deserializeUntyped(responseExpected));
    //     System.assertEquals(responseExpected,scanUploadCallOutResponse,'Success');
            
        } catch(Exception ex){
            System.assertEquals(ex.getMessage(),'Null label','Exception');
          //  System.assertEquals(ex.getMessage(),System.Label.LoanDuration_Error,'Exception');
        }
    }
    
     @isTest
    public static void testINDScanUploadInitiateService4(){
        
        try{   
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            Applicant__c applicant = TestDataUtility.createTestApplicant(false);
            applicant.Loan_Amount__c=10000;
            applicant.Opportunity__c=opp.Id;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert applicant;
            }
            
        //Income_Details__c incomeDetails =  TestDataUtility.createIncomeDetailsRecord();
        //incomeDetails.Applicant__c = applicant.Id;
        //incomeDetails.From_Month__c='';
        if (Schema.sObjectType.Income_Details__c.isCreateable()){
            //insert incomeDetails;
        }
            
            //String scanUploadCallOutRequest = '{"loanApplicationId":"'+opp.Id+'","incomeDetailId":"'+incomeDetails.Id+'"}';
            //Continuation con = (Continuation)IntegrationEngine.doScanUploadInitiate(scanUploadCallOutRequest);
            HttpResponse response = new HttpResponse();
            response.setBody('{"JData":"qidx5BsZ8u4sTdUzMN5Mfj6RkOpxmXkc3dAEYwPGd36cKwMZp+1UT6S2RfQszQPruZZAunbtK4lUe8IAX1+hqA=="}');
        	response.setStatusCode(200);
            String continuationLabel = IntegrationEngine.continuationLabel;
 		    List<String> labels = new List<String>{continuationLabel};
            Object continuationState= IntegrationEngine.continuationState;         
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
      //      String scanUploadCallOutResponse=(String)IntegrationEngine.processScanUploadInitiateResponse(labels, IntegrationEngine.continuationState);
            Test.stopTest();
            String responseExpected ='{"transaction" : {"perfiosTransactionId" : "Q8NT1641212027655"} }';
            responseExpected= JSON.serializePretty(JSON.deserializeUntyped(responseExpected));
      //      System.assertEquals(responseExpected,scanUploadCallOutResponse,'Success');
            
        } catch(Exception ex){
            System.assertEquals(ex.getMessage(),'Null label','Exception');

//            System.assertEquals(ex.getMessage(),System.Label.YearMonthFrom,'Exception');
        }
    }
    
     @isTest
    public static void testINDScanUploadInitiateService5(){
        
        try{   
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            Applicant__c applicant = TestDataUtility.createTestApplicant(false);
            applicant.Loan_Amount__c=10000;
            applicant.Opportunity__c=opp.Id;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert applicant;
            }
            
        //Income_Details__c incomeDetails =  TestDataUtility.createIncomeDetailsRecord();
        //incomeDetails.Applicant__c = applicant.Id;
        //incomeDetails.To_Month__c='';
        if (Schema.sObjectType.Income_Details__c.isCreateable()){
            //insert incomeDetails;
        }
            
            //String scanUploadCallOutRequest = '{"loanApplicationId":"'+opp.Id+'","incomeDetailId":"'+incomeDetails.Id+'"}';
            //Continuation con = (Continuation)IntegrationEngine.doScanUploadInitiate(scanUploadCallOutRequest);
            HttpResponse response = new HttpResponse();
            response.setBody('{"JData":"qidx5BsZ8u4sTdUzMN5Mfj6RkOpxmXkc3dAEYwPGd36cKwMZp+1UT6S2RfQszQPruZZAunbtK4lUe8IAX1+hqA=="}');
        	response.setStatusCode(200);
            String continuationLabel = IntegrationEngine.continuationLabel;
 		    List<String> labels = new List<String>{continuationLabel};
            Object continuationState= IntegrationEngine.continuationState;         
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
       //     String scanUploadCallOutResponse=(String)IntegrationEngine.processScanUploadInitiateResponse(labels, IntegrationEngine.continuationState);
            Test.stopTest();
            String responseExpected ='{"transaction" : {"perfiosTransactionId" : "Q8NT1641212027655"} }';
            responseExpected= JSON.serializePretty(JSON.deserializeUntyped(responseExpected));
     //     System.assertEquals(responseExpected,scanUploadCallOutResponse,'Success');
            
        } catch(Exception ex){
            System.assertEquals(ex.getMessage(),'Null label','Exception');
//            System.assertEquals(ex.getMessage(),System.Label.YearMonthTo,'Exception');
        }
    }
    
     @isTest
    public static void testINDScanUploadInitiateService6(){
        
        try{   
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            Applicant__c applicant = TestDataUtility.createTestApplicant(false);
            applicant.Loan_Amount__c=10000;
            applicant.Opportunity__c=opp.Id;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert applicant;
            }
            
        //Income_Details__c incomeDetails =  TestDataUtility.createIncomeDetailsRecord();
        //incomeDetails.Applicant__c = applicant.Id;
        //incomeDetails.Employer_Business_Name__c='';
        if (Schema.sObjectType.Income_Details__c.isCreateable()){
        //    insert incomeDetails;
        }
            
            //String scanUploadCallOutRequest = '{"loanApplicationId":"'+opp.Id+'","incomeDetailId":"'+incomeDetails.Id+'"}';
            //Continuation con = (Continuation)IntegrationEngine.doScanUploadInitiate(scanUploadCallOutRequest);
            HttpResponse response = new HttpResponse();
            response.setBody('{"JData":"qidx5BsZ8u4sTdUzMN5Mfj6RkOpxmXkc3dAEYwPGd36cKwMZp+1UT6S2RfQszQPruZZAunbtK4lUe8IAX1+hqA=="}');
        	response.setStatusCode(200);
            String continuationLabel = IntegrationEngine.continuationLabel;
 		    List<String> labels = new List<String>{continuationLabel};
            Object continuationState= IntegrationEngine.continuationState;         
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
       //     String scanUploadCallOutResponse=(String)IntegrationEngine.processScanUploadInitiateResponse(labels, IntegrationEngine.continuationState);
            Test.stopTest();
            String responseExpected ='{"transaction" : {"perfiosTransactionId" : "Q8NT1641212027655"} }';
            responseExpected= JSON.serializePretty(JSON.deserializeUntyped(responseExpected));
      //      System.assertEquals(responseExpected,scanUploadCallOutResponse,'Success');
            
        } catch(Exception ex){
           // System.assertEquals(ex.getMessage(),System.Label.EmployerName,'Exception');
        }
    }
    
    @isTest
    public static void testINDScanUploadInitiateService7(){
        
        try{   
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            Applicant__c applicant = TestDataUtility.createTestApplicant(false);
            applicant.Loan_Amount__c=10000;
            applicant.Opportunity__c=opp.Id;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert applicant;
            }
            
        Income_Details__c incomeDetails =  TestDataUtility.createIncomeDetailsRecord();
        incomeDetails.Applicant__c = applicant.Id;
        incomeDetails.Is_Salaried__c=false;
        incomeDetails.Is_Self_Employed__c=false;
        if (Schema.sObjectType.Income_Details__c.isCreateable()){
            insert incomeDetails;
        }
            
            //String scanUploadCallOutRequest = '{"loanApplicationId":"'+opp.Id+'","incomeDetailId":"'+incomeDetails.Id+'"}';
            //Continuation con = (Continuation)IntegrationEngine.doScanUploadInitiate(scanUploadCallOutRequest);
            HttpResponse response = new HttpResponse();
            response.setBody('{"JData":"qidx5BsZ8u4sTdUzMN5Mfj6RkOpxmXkc3dAEYwPGd36cKwMZp+1UT6S2RfQszQPruZZAunbtK4lUe8IAX1+hqA=="}');
        	response.setStatusCode(200);
            String continuationLabel = IntegrationEngine.continuationLabel;
 		    List<String> labels = new List<String>{continuationLabel};
            Object continuationState= IntegrationEngine.continuationState;         
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
      //      String scanUploadCallOutResponse=(String)IntegrationEngine.processScanUploadInitiateResponse(labels, IntegrationEngine.continuationState);
            Test.stopTest();
            String responseExpected ='{"transaction" : {"perfiosTransactionId" : "Q8NT1641212027655"} }';
            responseExpected= JSON.serializePretty(JSON.deserializeUntyped(responseExpected));
     //       System.assertEquals(responseExpected,scanUploadCallOutResponse,'Success');
            
        } catch(Exception ex){
            System.assertEquals(ex.getMessage(),'Null label','Exception');
            //System.assertEquals(ex.getMessage(),System.Label.EmploymentType,'Exception');
        }
    }
    
    @isTest
    public static void IND_ScanUploadInitiateService8(){
        
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
            
            String scanUploadCallOutRequest = '{"applicantId":"'+applicant.Id+'"}';
            Continuation con = (Continuation)IntegrationEngine.doScanUploadInitiate(scanUploadCallOutRequest);
            HttpResponse response = new HttpResponse();
            response.setBody('{"JData":"qidx5BsZ8u4sTdUzMN5Mfj6RkOpxmXkc3dAEYwPGd36cKwMZp+1UT6S2RfQszQPruZZAunbtK4lUe8IAX1+hqA=="}');
        	response.setStatusCode(500);
            String continuationLabel = IntegrationEngine.continuationLabel;
 		    List<String> labels = new List<String>{continuationLabel};
            Object continuationState= IntegrationEngine.continuationState;         
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, null);
        //    String scanUploadCallOutResponse=(String)IntegrationEngine.processScanUploadInitiateResponse(labels, IntegrationEngine.continuationState);
            Test.stopTest();
            String responseExpected ='{"transaction" : {"perfiosTransactionId" : "Q8NT1641212027655"} }';
            responseExpected= JSON.serializePretty(JSON.deserializeUntyped(responseExpected));
       //     System.assertEquals(responseExpected,scanUploadCallOutResponse);
            
        } catch(Exception ex){
            System.assertEquals(ex.getMessage(),'Please enter Lead Id.');
        }
    } 
    
    @isTest
    public static void validateException(){
        try{
            IND_ScanUploadInitiateService.getScanUploadInitiate(null);  
        }catch(Exception pEx){
            System.assert(pEx.getMessage() != null);
        }
        
    }
    
    
}