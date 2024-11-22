@isTest(SeeAllData=false)
public class IND_ValidateRecentLeadService_Test {
    
    @isTest
    public static void testValidateRecentLeadService(){
        
        try{   
            Profile p = [SELECT Id FROM Profile WHERE Name='CMU'];
            system.debug('p'+ p);
            User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                              EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
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
            String sCICNo ='9876543123456789876';
            String sLeadNo = applicant.Opportunity__r.Lead_number__c;
          //  String loanAppId = '00671000001DVS1AAO';
            Continuation con = (Continuation)IntegrationEngine.doValidateRecentLeadCallout(sCICNo, sLeadNo,opp.Id, applicant.Id);
            // Create a mock response
            HttpResponse response = new HttpResponse();
            String  body = '{"JData":"bmvHXB5/b59ltoDPA8dwPKjM9zW1GwK5fvqA5/8G5ni8b8FxZYO/CLqOFaA2ryZy+lUPrA60fAON5+NVtwgP2pLGsEuJ4uZMGJ36GxMUCSpCAacVXVTErj1WOcEqNKYYr3tUgkuF9XVcRgTRu7qWwUWzarAysWhuK4KSbAFujuA="}';
            response.setBody(body);
            response.setStatusCode(200);
            
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
                Object continuationState= IntegrationEngine.continuationState;
            String validateRecentCallOutResponse;
            system.runAs(u){
                Test.startTest();
                Test.setContinuationResponse(continuationLabel, response);
                validateRecentCallOutResponse= (String)IntegrationEngine.processValidateRecentLeadResponse(labels, IntegrationEngine.continuationState);
                Test.stopTest();
            }
            // String responseActual ='{"body":null,"response":{"status":"SUCCESS","respDesc":"Match Status Verified","content":[{"PG_Application_No":"","PG_cust_dedupe":"1"}]}}';
            // System.assertEquals(responseActual,validateRecentCallOutResponse,'Success');
            
        } catch(Exception ex){
            // System.assertEquals(ex.getMessage(),'Please enter the Maker Id');
        }
    }
    
    @isTest
    public static void testValidateRecentLeadService2(){
        
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
            
            String cicNo =' ';
            final String LeadNo = applicant.Opportunity__r.Lead_number__c;
         //   String loanAppId = '00671000001DVS1AAO';
            Continuation con = (Continuation)IntegrationEngine.doValidateRecentLeadCallout(cicNo, LeadNo,opp.Id, applicant.Id);
            // Create a mock response
            HttpResponse response = new HttpResponse();
            String body ='{"JData":"bmvHXB5/b59ltoDPA8dwPKjM9zW1GwK5fvqA5/8G5ni8b8FxZYO/CLqOFaA2ryZy+lUPrA60fAON5+NVtwgP2pLGsEuJ4uZMGJ36GxMUCSpCAacVXVTErj1WOcEqNKYYr3tUgkuF9XVcRgTRu7qWwUWzarAysWhuK4KSbAFujuA="}';
            response.setBody(body);
            response.setStatusCode(200);
            
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
                Object continuationState= IntegrationEngine.continuationState;
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
            String validateRecentCallOutResponse= (String)IntegrationEngine.processValidateRecentLeadResponse(labels, IntegrationEngine.continuationState);
            Test.stopTest();
            // String responseActual ='{"body":null,"response":{"status":"SUCCESS","respDesc":"Match Status Verified","content":[{"PG_Application_No":"","PG_cust_dedupe":"1"}]}}';
            // System.assertEquals(responseActual,validateRecentCallOutResponse,'SUCCESS');
            
        } catch(Exception ex){
            // System.assertEquals(ex.getMessage(),'Please enter the Maker Id');
        }
    }
    
    @isTest
    public static void testValidateRecentLeadService3(){
        
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
            
            String cicNo ='9876543123456789876';
            final String LeadNo = '';
         //   String loanAppId = '00671000001DVS1AAO';
            Continuation con = (Continuation)IntegrationEngine.doValidateRecentLeadCallout(cicNo, LeadNo,opp.Id, applicant.Id);
            // Create a mock response
            HttpResponse response = new HttpResponse();
            String  body = '{"JData":"bmvHXB5/b59ltoDPA8dwPKjM9zW1GwK5fvqA5/8G5ni8b8FxZYO/CLqOFaA2ryZy+lUPrA60fAON5+NVtwgP2pLGsEuJ4uZMGJ36GxMUCSpCAacVXVTErj1WOcEqNKYYr3tUgkuF9XVcRgTRu7qWwUWzarAysWhuK4KSbAFujuA="}';
            response.setBody(body);  
            response.setStatusCode(200);
            
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
                Object continuationState= IntegrationEngine.continuationState;
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
            String validateRecentCallOutResponse= (String)IntegrationEngine.processValidateRecentLeadResponse(labels, IntegrationEngine.continuationState);
            Test.stopTest();
            // String responseActual ='{"body":null,"response":{"status":"SUCCESS","respDesc":"Match Status Verified","content":[{"PG_Application_No":"","PG_cust_dedupe":"1"}]}}';
            // System.assertEquals(responseActual,validateRecentCallOutResponse,'SUCCESS');
            
        } catch(Exception ex){
            // System.assertEquals(ex.getMessage(),'Please enter Lead Id.');
        }
    }
    
    @isTest
    public static void testValidateRecentLeadService4(){
        
        try{   
            Opportunity opp = TestDataUtility.createTestOpportunityforCarwalePricesAPI(false);
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            Applicant__c applicant = TestDataUtility.createTestApplicant(false);
            applicant.Opportunity__c=opp.Id;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert applicant;
            }
            
            String cicNo ='';
            final String LeadNo = applicant.Opportunity__r.Lead_number__c;
           // String loanAppId = '00671000001DVS1AAO';
            Continuation con = (Continuation)IntegrationEngine.doValidateRecentLeadCallout(cicNo, LeadNo,opp.Id, applicant.Id);
            // Create a mock response
            HttpResponse response = new HttpResponse();
            String body = '{"JData":"bmvHXB5/b59ltoDPA8dwPKjM9zW1GwK5fvqA5/8G5ni8b8FxZYO/CLqOFaA2ryZy+lUPrA60fAON5+NVtwgP2pLGsEuJ4uZMGJ36GxMUCSpCAacVXVTErj1WOcEqNKYYr3tUgkuF9XVcRgTRu7qWwUWzarAysWhuK4KSbAFujuA="}';
            response.setBody(body);
            response.setStatusCode(200);
            
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
                Object continuationState= IntegrationEngine.continuationState;
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
            String validateRecentCallOutResponse= (String)IntegrationEngine.processValidateRecentLeadResponse(labels, IntegrationEngine.continuationState);
            Test.stopTest();
            // String responseActual ='{"body":null,"response":{"status":"SUCCESS","respDesc":"Match Status Verified","content":[{"PG_Application_No":"","PG_cust_dedupe":"1"}]}}';
            // System.assertEquals(responseActual,validateRecentCallOutResponse,'SUCCESS');
            
        } catch(Exception ex){
            // System.assertEquals(ex.getMessage(),'Please enter the Maker Id');
        }
    }
    
    
}