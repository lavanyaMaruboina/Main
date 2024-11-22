/*------------------------------------------------------------
Author:        Satyam More
Company:       Persistent Systems
Description:   Test class created to validate the IND_EmailServiceRequest IND_EmailServiceService IND_EmailServiceResponse class
History
Date            Author              Comments
-------------------------------------------------------------
03-01-2022      Satyam More       Created
------------------------------------------------------------*/
@isTest(SeeAllData=false)
public class IND_EmailServiceService_Test {
@isTest
    public static void testEmailServiceService(){
        
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
            
            String emailService = '{"leadId":"'+opp.Lead_number__c+'" ,"emailTo":"satyam_more@persistent.com", "emailCC":"bhushan_charde@persistent.com", "emailSubject":"Test Email Service API", "emailBody":"Test Email Service API"}';
            
            Continuation con = (Continuation)IntegrationEngine.doEmailServiceCallout(emailService);
            // Create a mock response
            HttpResponse response = new HttpResponse();
            response.setBody('{"JData":"bmvHXB5/b59ltoDPA8dwPKjM9zW1GwK5fvqA5/8G5nhh0w0E1I+3oTmH6qu4bRWV2ZIKywha3ogGCQMc2PCp/haQEVQHkfdJYPSxjfd2DnM95cSKzj+Wu/SxWkUr0je1ZpGONr41Yd1JTq5juubLNw=="}');
            response.setStatusCode(200);
            
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
            Object continuationState= IntegrationEngine.continuationState;
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
            String emailServiceResponse= (String)IntegrationEngine.processEmailServiceResponse(labels, IntegrationEngine.continuationState);
            Test.stopTest();
            String responseExpected ='{"body":null,"response":{"status":"SUCCESS","respDesc":"Email-Sent","content":["Email Sent Successfully!"]}}';
            System.assertEquals(responseExpected, emailServiceResponse, 'SUCCESS');
            
        } catch(Exception ex){
            System.assertEquals(ex.getMessage(),'Script-thrown exception', 'Exception');
        }
    }
    
    @isTest
    public static void testEmailServiceService2(){
        
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
            
            String emailService = '{"leadId":"" ,"emailTo":"satyam_more@persistent.com", "emailCC":"bhushan_charde@persistent.com", "emailSubject":"Test Email Service API", "emailBody":"Test Email Service API"}';
            
            Continuation con = (Continuation)IntegrationEngine.doEmailServiceCallout(emailService);
            // Create a mock response
            HttpResponse response = new HttpResponse();
            response.setBody('{"JData":"bmvHXB5/b59ltoDPA8dwPKjM9zW1GwK5fvqA5/8G5nhh0w0E1I+3oTmH6qu4bRWV2ZIKywha3ogGCQMc2PCp/haQEVQHkfdJYPSxjfd2DnM95cSKzj+Wu/SxWkUr0je1ZpGONr41Yd1JTq5juubLNw=="}');
            response.setStatusCode(200);
            
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
            Object continuationState= IntegrationEngine.continuationState;
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
            String emailServiceResponse= (String)IntegrationEngine.processEmailServiceResponse(labels, IntegrationEngine.continuationState);
            Test.stopTest();
            String responseExpected ='{"body":null,"response":{"status":"SUCCESS","respDesc":"Email-Sent","content":["Email Sent Successfully!"]}}';
            System.assertEquals(responseExpected, emailServiceResponse, 'SUCCESS');
            
        } catch(Exception ex){
            System.assertEquals(ex.getMessage(),System.Label.LeadId, 'Exception');
        }
    }
    
    @isTest
    public static void testEmailServiceService3(){
        
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
            
            String emailService = '{"leadId":"'+opp.Lead_number__c+'" ,"emailTo":"", "emailCC":"bhushan_charde@persistent.com", "emailSubject":"Test Email Service API", "emailBody":"Test Email Service API"}';
            
            Continuation con = (Continuation)IntegrationEngine.doEmailServiceCallout(emailService);
            // Create a mock response
            HttpResponse response = new HttpResponse();
            response.setBody('{"JData":"bmvHXB5/b59ltoDPA8dwPKjM9zW1GwK5fvqA5/8G5nhh0w0E1I+3oTmH6qu4bRWV2ZIKywha3ogGCQMc2PCp/haQEVQHkfdJYPSxjfd2DnM95cSKzj+Wu/SxWkUr0je1ZpGONr41Yd1JTq5juubLNw=="}');
            response.setStatusCode(200);
            
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
            Object continuationState= IntegrationEngine.continuationState;
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
            String emailServiceResponse= (String)IntegrationEngine.processEmailServiceResponse(labels, IntegrationEngine.continuationState);
            Test.stopTest();
            String responseExpected ='{"body":null,"response":{"status":"SUCCESS","respDesc":"Email-Sent","content":["Email Sent Successfully!"]}}';
            System.assertEquals(responseExpected, emailServiceResponse, 'SUCCESS');
            
        } catch(Exception ex){
            System.assertEquals(ex.getMessage(),System.Label.Email, 'Exception');
        }
    }
    
    @isTest
    public static void testEmailServiceService4(){
        
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
            
            String emailService = '{"leadId":"'+opp.Lead_number__c+'" ,"emailTo":"satyam_more@persistent.com", "emailCC":"", "emailSubject":"Test Email Service API", "emailBody":"Test Email Service API"}';
            
            Continuation con = (Continuation)IntegrationEngine.doEmailServiceCallout(emailService);
            // Create a mock response
            HttpResponse response = new HttpResponse();
            response.setBody('{"JData":"bmvHXB5/b59ltoDPA8dwPKjM9zW1GwK5fvqA5/8G5nhh0w0E1I+3oTmH6qu4bRWV2ZIKywha3ogGCQMc2PCp/haQEVQHkfdJYPSxjfd2DnM95cSKzj+Wu/SxWkUr0je1ZpGONr41Yd1JTq5juubLNw=="}');
            response.setStatusCode(200);
            
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
            Object continuationState= IntegrationEngine.continuationState;
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
            String emailServiceResponse= (String)IntegrationEngine.processEmailServiceResponse(labels, IntegrationEngine.continuationState);
            Test.stopTest();
            String responseExpected ='{"body":null,"response":{"status":"SUCCESS","respDesc":"Email-Sent","content":["Email Sent Successfully!"]}}';
            System.assertEquals(responseExpected, emailServiceResponse, 'SUCCESS');
            
        } catch(Exception ex){
            System.assertEquals(ex.getMessage(),System.Label.Email, 'Exception');
        }
    }
    
    @isTest
    public static void testEmailServiceService5(){
        
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
            
            String emailService = '{"leadId":"'+opp.Lead_number__c+'" ,"emailTo":"satyam_more@persistent.com", "emailCC":"bhushan_charde@persistent.com", "emailSubject":"", "emailBody":"Test Email Service API"}';
            
            Continuation con = (Continuation)IntegrationEngine.doEmailServiceCallout(emailService);
            // Create a mock response
            HttpResponse response = new HttpResponse();
            response.setBody('{"JData":"bmvHXB5/b59ltoDPA8dwPKjM9zW1GwK5fvqA5/8G5nhh0w0E1I+3oTmH6qu4bRWV2ZIKywha3ogGCQMc2PCp/haQEVQHkfdJYPSxjfd2DnM95cSKzj+Wu/SxWkUr0je1ZpGONr41Yd1JTq5juubLNw=="}');
            response.setStatusCode(200);
            
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
            Object continuationState= IntegrationEngine.continuationState;
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
            String emailServiceResponse= (String)IntegrationEngine.processEmailServiceResponse(labels, IntegrationEngine.continuationState);
            Test.stopTest();
            String responseExpected ='{"body":null,"response":{"status":"SUCCESS","respDesc":"Email-Sent","content":["Email Sent Successfully!"]}}';
            System.assertEquals(responseExpected, emailServiceResponse, 'SUCCESS');
            
        } catch(Exception ex){
            System.assertEquals(ex.getMessage(),System.Label.EmailSubject, 'Exception');
        }
    }
    
    @isTest
    public static void testEmailServiceService6(){
        
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
            
            String emailService = '{"leadId":"'+opp.Lead_number__c+'" ,"emailTo":"satyam_more@persistent.com", "emailCC":"bhushan_charde@persistent.com", "emailSubject":"Test Email Service API", "emailBody":""}';
            
            Continuation con = (Continuation)IntegrationEngine.doEmailServiceCallout(emailService);
            // Create a mock response
            HttpResponse response = new HttpResponse();
            response.setBody('{"JData":"bmvHXB5/b59ltoDPA8dwPKjM9zW1GwK5fvqA5/8G5nhh0w0E1I+3oTmH6qu4bRWV2ZIKywha3ogGCQMc2PCp/haQEVQHkfdJYPSxjfd2DnM95cSKzj+Wu/SxWkUr0je1ZpGONr41Yd1JTq5juubLNw=="}');
            response.setStatusCode(200);
            
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
            Object continuationState= IntegrationEngine.continuationState;
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
            String emailServiceResponse= (String)IntegrationEngine.processEmailServiceResponse(labels, IntegrationEngine.continuationState);
            Test.stopTest();
            String responseExpected ='{"body":null,"response":{"status":"SUCCESS","respDesc":"Email-Sent","content":["Email Sent Successfully!"]}}';
            System.assertEquals(responseExpected, emailServiceResponse, 'SUCCESS');
            
        } catch(Exception ex){
            System.assertEquals(ex.getMessage(),System.Label.EmailBody, 'Exception');
        }
    }
    
    @isTest
    public static void testEmailServiceService7(){
        
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
            
            String emailService = '{"leadId":"'+opp.Lead_number__c+'" ,"emailTo":"satyam_more@persistent.com", "emailCC":"bhushan_charde@persistent.com", "emailSubject":"Test Email Service API", "emailBody":"Test Email Service API"}';
            
            Continuation con = (Continuation)IntegrationEngine.doEmailServiceCallout(emailService);
            // Create a mock response
            HttpResponse response = new HttpResponse();
            response.setBody('{"JData":"bmvHXB5/b59ltoDPA8dwPKjM9zW1GwK5fvqA5/8G5nhh0w0E1I+3oTmH6qu4bRWV2ZIKywha3ogGCQMc2PCp/haQEVQHkfdJYPSxjfd2DnM95cSKzj+Wu/SxWkUr0je1ZpGONr41Yd1JTq5juubLNw=="}');
            response.setStatusCode(500);
            
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
            Object continuationState= IntegrationEngine.continuationState;
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
            String emailServiceResponse= (String)IntegrationEngine.processEmailServiceResponse(labels, IntegrationEngine.continuationState);
            Test.stopTest();
            String responseExpected ='{"body":null,"response":{"status":"SUCCESS","respDesc":"Email-Sent","content":["Email Sent Successfully!"]}}';
            System.assertEquals(responseExpected, emailServiceResponse, 'SUCCESS');
            
        } catch(Exception ex){
            System.assertEquals(ex.getMessage(),'No Response Found.', 'Exception');
        }
    }
}