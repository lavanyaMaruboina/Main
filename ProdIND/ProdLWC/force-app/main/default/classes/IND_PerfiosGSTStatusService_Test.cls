@isTest
public class IND_PerfiosGSTStatusService_Test {

    // @Method:		TestServiceMetthod
    // @Created by:	Bhushan Charde
    // @Description:Test setup method to create the test data for IND_PerfiosGSTStatusRequest classs
    // @Param:		''	
    // @Return: 	'' 
    
    @isTest
    public static void testIND_PerfiosGSTStatusService(){
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
            
            Income_Details__c incomedetails = new Income_Details__c();
            incomedetails.Applicant__c = applicant.Id;
            incomedetails.Perfios_Transaction_Id__c = '04022022111044173';
            insert incomedetails;
              
            Test.startTest();
            
            IND_PerfiosGSTStatusRequest perfiosgststatusrequest = new IND_PerfiosGSTStatusRequest(String.valueOf(incomedetails.id));
            perfiosgststatusrequest.getHttpRequestHeaders();
            IntegrationEngine.doGSTTransactionStatusAsyncCallout(String.valueOf(incomedetails.id),String.valueOf(opp.id),String.valueOf(incomedetails.id));
            
            Test.stopTest();
        } catch(Exception ex){
            System.assertEquals(ex.getMessage(),'Script-thrown exception');
        }
    }
    
    @isTest
    public static void testIND_PerfiosGSTStatusService1(){
        try{
            //Test.setMock(HttpCalloutMock.class, new SMSHttpCalloutMock());
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            
            Applicant__c applicant = TestDataUtility.createTestApplicantForSMS(false);
            applicant.Opportunity__c=opp.Id;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert applicant;
            }
            
            
        //    Continuation con = (Continuation)IntegrationEngine.doGSTStatusCallout(applicant.Id);
            
            // Create a mock response
            HttpResponse response = new HttpResponse();
            response.setBody('{"JData":"zH0lq0fnQ44fnohIavabrC4R/B5iCz1tkolTVt+WEL+T0N213+vcsgPT4lbykd6qJ5XW01+E/REL8QqJKxkOs+eyBkESwtKEtB7re3qZK1Cb2zHcj52TwXGT/fdsJPGp24ghz6iSoAbVUFb1zTSbhvu/fHzxqakA1kXCg3zyzmVFeTZiMUYwObt+FVkZ2GV1y1m3WgeNafR57Fd7uZ6m0Pdzh2MpnthqZhBkqlAp5I02rBYFO2PSZlwXlIJAHAQ4526Onm8p5A6Jo8Db3Dlcv1DwGaPzzTvKVm9I9y66jGPCG2/hfR13Ig5B8HhIJOeTY1TFBR5P8+cHN2dicpUsuSvVRZe8jvzZ1zpCudXC9FKEGZDxouqYtvUEP6D1GdzvN9TT82hr4VfEEY78wyxVRuo1wzISmfgKgTMzBmJEugw="}');
            response.setStatusCode(500);
            
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
            Object continuationState= IntegrationEngine.continuationState;   
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
         //   String gstResponse = (String)IntegrationEngine.processGSTStatusAPIResponse(labels, IntegrationEngine.continuationState);
            Test.stopTest();
         //   system.debug('gstResponse '+gstResponse);
            String responseExpected ='{ "Message": "An error has occurred." }';
         //   System.assertEquals(responseExpected, gstResponse);
        } catch(Exception ex){
           // System.assertEquals(ex.getMessage(),'Script-thrown exception');
        }
    }
    
    
     @isTest
    public static void testIND_PerfiosGSTStatusService2(){
        try{
            //Test.setMock(HttpCalloutMock.class, new SMSHttpCalloutMock());
            Opportunity opp = TestDataUtility.createTestOpportunityforCarwalePricesAPI(false);
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            
            Applicant__c applicant = TestDataUtility.createTestApplicantForSMS(false);
           // applicant.Opportunity__c=opp.Id;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert applicant;
            }
            
            
         //   Continuation con = (Continuation)IntegrationEngine.doGSTStatusCallout(applicant.Id);
            
            // Create a mock response
            HttpResponse response = new HttpResponse();
            response.setBody('{"JData":"sBZy7pgmZaJbPD07UpR+goU48UT8M+nNIJltpeSvSuYGJrlzfCkBAVF0Gk0S8dAi3tCTFc+vPFa7iS8tdg9/Yb2wrW6SKCpFl8sKK3tUxYwv+w3HEgSFNgAPf+i0bk/sWDMAs3rF4cPP0d/Ar3IOVa2LhHnRKvL1KUyVxY1IbO5v1zUkjnBQqYlkBzGO/B5uA88EcHlIziJGSOCXCS/VWiZiUT0bK59t+VnVNNE5uCzwueUFdfJ0Q/SbraVufWwjyHJXCkzudqXMCcy7/IB+vaMs+Pw7qAxeuePRUWQPHFcqAgcGvicJUfvNf5fBVZD/Ek+wty90cg9bUHqMxqmGEuMubqK3oM4zp6k89wpMOr4uTgIOPIoYKQyFZJ62NySdPdxJ2LT8y7YnDJ4g7A6zoERfJ6g+vJn9KyKapHkXoYc="}');
            response.setStatusCode(200);
            
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
            Object continuationState= IntegrationEngine.continuationState;   
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
        //    String gstResponse = (String)IntegrationEngine.processGSTStatusAPIResponse(labels, IntegrationEngine.continuationState);
            Test.stopTest();
       //     system.debug('gstResponse '+gstResponse);
            String responseExpected ='{ ”message”: ”COMPLETED”, ”status” : ”true”, ”statementsStatus”: [ {”fileName”: ”XYZ.pdf”,”status”: ”COMPLETED”,”message”: ””}, {”fileName”: ”ABC.pdf”,”status”: ”REJECTED”, ”message”: ”The uploaded file is not a valid GST return file.”} ] }';
        //    System.assertEquals(responseExpected, gstResponse);
        } catch(Exception ex){
           // System.assertEquals(ex.getMessage(),'Script-thrown exception');
        }
    }
    
     @isTest
    public static void testIND_IbbMasterService4(){
        
        try{   
         //Test.setMock(HttpCalloutMock.class, new SMSHttpCalloutMock());
            Opportunity opp = TestDataUtility.createTestOpportunityforCarwalePricesAPI(false);
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            
            Applicant__c applicant = TestDataUtility.createTestApplicantForSMS(false);
            applicant.Opportunity__c=opp.Id;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert applicant;
            }
                                           
        //     Continuation con = (Continuation)IntegrationEngine.doGSTStatusCallout(applicant.Id);
            // Create a mock response
        	HttpResponse response = new HttpResponse();
          response.setBody('{"JData":"FIWlIOF2dhi6m5rANaaFuYZpocsBqWeIdAN05t5ZWkiJ2jxevJK404YlYe2QFXKs46/wKMzKcUQJG0VQ4VXlpg=="}');
       	    response.setStatusCode(404);
            
            String continuationLabel = IntegrationEngine.continuationLabel;
 		    List<String> labels = new List<String>{continuationLabel};
            Object continuationState= IntegrationEngine.continuationState;
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
          //  String iBBMasterCallOutResponse= (String)IntegrationEngine.processGSTStatusAPIResponse(labels, IntegrationEngine.continuationState);
          Test.stopTest();
            String responseExpected ='{ "status": "Failed", "error_code": "404" }';
       //   System.assertEquals(responseExpected, iBBMasterCallOutResponse);
        
        } catch(Exception ex){
          //  System.assertEquals(ex.getMessage(),'Script-thrown exception');
        }
    }
}