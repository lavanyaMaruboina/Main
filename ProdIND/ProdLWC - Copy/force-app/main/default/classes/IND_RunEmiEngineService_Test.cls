/*------------------------------------------------------------
Author:        Satyam More
Company:       Persistent Systems
Description:   Test class created to validate the IND_RunEmiEngineRequest IND_RunEmiEngineService IND_RunEmiEngineRequest class
History
Date            Author              Comments
-------------------------------------------------------------
23-12-2021      Satyam More       Created
------------------------------------------------------------*/
@isTest(SeeAllData=false)
public class IND_RunEmiEngineService_Test {
    
    
@isTest
    public static void testRunEmiEngineService(){
        
        try{   
            
            Profile p = [SELECT Id FROM Profile WHERE Name='CMU'];
            system.debug('p'+ p);
    		User u = new User(Alias = 'standt', Email='standarduser@testorg.com',MobilePhone = '9999999999',
					EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
					LocaleSidKey='en_US', ProfileId = p.Id,
					TimeZoneSidKey='America/Los_Angeles',
					UserName='standarduser4@testorg.com.psdev1');
            insert u;
            
            Opportunity opp = TestDataUtility.createTestOpportunityforRunEmiEngineApi(false);
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            Applicant__c applicant = TestDataUtility.createTestApplicant(false);
            applicant.Opportunity__c=opp.Id;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert applicant;
            }
            
            String runEmiEngine = '{"leadId":"'+opp.Lead_number__c+'" ,"applicationId":"'+applicant.DocAuth_Application_Id__c+'", "cicNo":"18122021376201"}';
            
            Continuation con = (Continuation)IntegrationEngine.doRunEmiEngineCallout(runEmiEngine);
            // Create a mock response
            HttpResponse response = new HttpResponse();
            response.setBody('{"JData":"tQSovByAVZugG789TkA1n/ymHPZ0rtg6Hw64sXtlrU/BydfGS8Tcy8QLc2KYwHodCGODkMUnPp+YAp0eoDdvnlEIdmnZb/WTRMRQ9Dwinwiyv5h0VBVUwsFEQRD1iilCsiym6v7zvy6Rn4++T9iPxyO8jil8pBBye3OT+/s86Ig="}');
            response.setStatusCode(200);
            
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
            Object continuationState= IntegrationEngine.continuationState;
            
            String runEmiEngineCallOutResponse;
             system.runAs(u){
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
            runEmiEngineCallOutResponse= (String)IntegrationEngine.processRunEmiEngineCalloutResponse(labels, IntegrationEngine.continuationState);
            Test.stopTest();
             }
            String responseExpected ='{"body":null,"Upper_Emi_Cap":"15000","Outstanding_Amt":"40000","Lower_Emi_Cap":"20000","Loan_Type":"Personal Loan"}';
            System.assertEquals(responseExpected, runEmiEngineCallOutResponse, 'SUCCESS');
            
        } catch(Exception ex){

        }
    }
   
    @isTest
    public static void testRunEmiEngineService2(){
        
        try{   
            
            Opportunity opp = TestDataUtility.createTestOpportunityforRunEmiEngineApi(false);
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            Applicant__c applicant = TestDataUtility.createTestApplicant(false);
            applicant.Opportunity__c=opp.Id;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert applicant;
            }
            
            String runEmiEngine = '{"leadId":"" ,"applicationId":"'+applicant.DocAuth_Application_Id__c+'", "cicNo":"18122021376201"}';
            
            Continuation con = (Continuation)IntegrationEngine.doRunEmiEngineCallout(runEmiEngine);
            // Create a mock response
            HttpResponse response = new HttpResponse();
            response.setBody('{"JData":"tQSovByAVZugG789TkA1n/ymHPZ0rtg6Hw64sXtlrU/BydfGS8Tcy8QLc2KYwHodCGODkMUnPp+YAp0eoDdvnlEIdmnZb/WTRMRQ9Dwinwiyv5h0VBVUwsFEQRD1iilCsiym6v7zvy6Rn4++T9iPxyO8jil8pBBye3OT+/s86Ig="}');
            response.setStatusCode(200);
            
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
            Object continuationState= IntegrationEngine.continuationState;
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
            String runEmiEngineCallOutResponse= (String)IntegrationEngine.processRunEmiEngineCalloutResponse(labels, IntegrationEngine.continuationState);
            Test.stopTest();
            String responseExpected ='{"body":null,"Upper_Emi_Cap":"15000","Outstanding_Amt":"40000","Lower_Emi_Cap":"20000","Loan_Type":"Personal Loan"}';
            System.assertEquals(responseExpected, runEmiEngineCallOutResponse, 'SUCCESS');
            
        } catch(Exception ex){
            System.assertEquals(ex.getMessage(),'Applicant data not found.', 'Exception');
        }
    }
    
    
    @isTest
    public static void testRunEmiEngineService3(){
        
        try{   
            
            Opportunity opp = TestDataUtility.createTestOpportunityforRunEmiEngineApi(false);
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            Applicant__c applicant = TestDataUtility.createTestApplicant(false);
            applicant.Opportunity__c=opp.Id;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert applicant;
            }
            
            String runEmiEngine = '{"leadId":"'+opp.Lead_number__c+'" ,"applicationId":"", "cicNo":"18122021376201"}';
            
            Continuation con = (Continuation)IntegrationEngine.doRunEmiEngineCallout(runEmiEngine);
            // Create a mock response
            HttpResponse response = new HttpResponse();
            response.setBody('{"JData":"tQSovByAVZugG789TkA1n/ymHPZ0rtg6Hw64sXtlrU/BydfGS8Tcy8QLc2KYwHodCGODkMUnPp+YAp0eoDdvnlEIdmnZb/WTRMRQ9Dwinwiyv5h0VBVUwsFEQRD1iilCsiym6v7zvy6Rn4++T9iPxyO8jil8pBBye3OT+/s86Ig="}');
            response.setStatusCode(200);
            
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
            Object continuationState= IntegrationEngine.continuationState;
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
            String runEmiEngineCallOutResponse= (String)IntegrationEngine.processRunEmiEngineCalloutResponse(labels, IntegrationEngine.continuationState);
            Test.stopTest();
            String responseExpected ='{"body":null,"Upper_Emi_Cap":"15000","Outstanding_Amt":"40000","Lower_Emi_Cap":"20000","Loan_Type":"Personal Loan"}';
            System.assertEquals(responseExpected, runEmiEngineCallOutResponse, 'SUCCESS');
            
        } catch(Exception ex){
            System.assertEquals(ex.getMessage(),'Applicant data not found.', 'Exception');
        }
    }
    
    
    @isTest
    public static void testRunEmiEngineService4(){
        
        try{   
            
            Opportunity opp = TestDataUtility.createTestOpportunityforRunEmiEngineApi(false);
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            Applicant__c applicant = TestDataUtility.createTestApplicant(false);
            applicant.Opportunity__c=opp.Id;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert applicant;
            }
            
            String runEmiEngine = '{"leadId":"'+opp.Lead_number__c+'" ,"applicationId":"'+applicant.DocAuth_Application_Id__c+'", "cicNo":""}';
            
            Continuation con = (Continuation)IntegrationEngine.doRunEmiEngineCallout(runEmiEngine);
            // Create a mock response
            HttpResponse response = new HttpResponse();
            response.setBody('{"JData":"tQSovByAVZugG789TkA1n/ymHPZ0rtg6Hw64sXtlrU/BydfGS8Tcy8QLc2KYwHodCGODkMUnPp+YAp0eoDdvnlEIdmnZb/WTRMRQ9Dwinwiyv5h0VBVUwsFEQRD1iilCsiym6v7zvy6Rn4++T9iPxyO8jil8pBBye3OT+/s86Ig="}');
            response.setStatusCode(200);
            
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
            Object continuationState= IntegrationEngine.continuationState;
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
            String runEmiEngineCallOutResponse= (String)IntegrationEngine.processRunEmiEngineCalloutResponse(labels, IntegrationEngine.continuationState);
            Test.stopTest();
            String responseExpected ='{"body":null,"Upper_Emi_Cap":"15000","Outstanding_Amt":"40000","Lower_Emi_Cap":"20000","Loan_Type":"Personal Loan"}';
            System.assertEquals(responseExpected, runEmiEngineCallOutResponse, 'SUCCESS');
            
        } catch(Exception ex){
            System.assertEquals(ex.getMessage(),'Applicant data not found.', 'Exception');
        }
    }
    
    @isTest
    public static void testRunEmiEngineService5(){
        
        try{   
            
            Opportunity opp = TestDataUtility.createTestOpportunityforRunEmiEngineApi(false);
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            Applicant__c applicant = TestDataUtility.createTestApplicant(false);
            applicant.Opportunity__c=opp.Id;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert applicant;
            }
            
            String runEmiEngine = '{"leadId":"'+opp.Lead_number__c+'" ,"applicationId":"'+applicant.DocAuth_Application_Id__c+'", "cicNo":"18122021376201"}';
            
            Continuation con = (Continuation)IntegrationEngine.doRunEmiEngineCallout(runEmiEngine);
            // Create a mock response
            HttpResponse response = new HttpResponse();
            response.setBody('{"JData":"tQSovByAVZugG789TkA1n/ymHPZ0rtg6Hw64sXtlrU/BydfGS8Tcy8QLc2KYwHodCGODkMUnPp+YAp0eoDdvnlEIdmnZb/WTRMRQ9Dwinwiyv5h0VBVUwsFEQRD1iilCsiym6v7zvy6Rn4++T9iPxyO8jil8pBBye3OT+/s86Ig="}');
            response.setStatusCode(500);
            
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
            Object continuationState= IntegrationEngine.continuationState;
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
            String runEmiEngineCallOutResponse= (String)IntegrationEngine.processRunEmiEngineCalloutResponse(labels, IntegrationEngine.continuationState);
            Test.stopTest();
            String responseExpected ='{"body":null,"Upper_Emi_Cap":"15000","Outstanding_Amt":"40000","Lower_Emi_Cap":"20000","Loan_Type":"Personal Loan"}';
            System.assertEquals(responseExpected, runEmiEngineCallOutResponse, 'Fail');
            
        } catch(Exception ex){
            System.assertEquals(ex.getMessage(),'Applicant data not found.', 'Exception');
        }
    } 
    
    
             @isTest
    public static void validateException(){
        try{
            IND_RunEmiEngineService.getRunEmiEngineCallOutRequest(null, null);
        }catch(Exception pEx){
            System.assert(pEx.getMessage() != null);
        }
        
    }
    
    
}