/*------------------------------------------------------------
Author:        Satyam More
Company:       Persistent Systems
Description:   Test class created to validate the IND_PanVerificationRequest IND_PanVerificationService IND_PanVerificationResponse class
History
Date            Author              Comments
-------------------------------------------------------------
10-12-2021      Satyam More       Created
------------------------------------------------------------*/

@isTest(SeeAllData=false)
public class IND_PanVerificationService_Test {
    
    
    @isTest
    public static void testPanVerificationService(){
        
        try{   
            
            Profile p = [SELECT Id FROM Profile WHERE Name='CMU'];
            system.debug('p'+ p);
            User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                              EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                              LocaleSidKey='en_US', ProfileId = p.Id,MobilePhone = '9701498575',
                              Maker_Id__c='1002',
                              TimeZoneSidKey='America/Los_Angeles',
                              UserName='standarduser4@testorg.com.psdev1');
            insert u;
            
            system.runAs(u){
                Opportunity opp = TestDataUtility.createTestOpportunity(false);
                if (Schema.sObjectType.Opportunity.isCreateable()){
                    insert opp;
                }
                Applicant__c applicant = TestDataUtility.createTestApplicant(false);
                applicant.Opportunity__c=opp.Id;
                if (Schema.sObjectType.Applicant__c.isCreateable()){
                    insert applicant;
                }
                
                String panVerifyRequest = '{"applicantId":"'+applicant.Id+'" ,"panNumber":"CSWPG3660G","firstName":"'+applicant.Customer_First_Name__c+'","lastName":"'+applicant.Customer_Last_Name__c+' "}';
                
                Continuation con = (Continuation)IntegrationEngine.doPANCallout(panVerifyRequest);
                // Create a mock response
                HttpResponse response = new HttpResponse();
                response.setBody('{"JData":"bmvHXB5/b59ltoDPA8dwPKjM9zW1GwK5fvqA5/8G5njg6LzMAYI4Id6LrLJmRnoijeFuaYkwDnaZHsa+6xYit82GLmdlqwXm0BAn6A39s+8tEj1DO22pB2d+pdaaLuahdq9qhYsY6BgGXwQveaGe+qoE4LwKTSymv3ZxeE/r6N6i8Jj51Sf62N2i1LJhaAOKAIhf3hW/g9kO5MXzbWm4eZn7whfcMFdjvVr3NW4wI788aR9xGUvwj87yC5uQuaM5hKzMwKJJJKU0eR4sNzzTPForbed5aCwoRITFkUeQ/l8yNywULXNPSI8qTYEEyt5yW9tfbI6t+Vm48d8F807UycU2Kn4G+Z2DYm9yfuHn+NqlO3nRJnjgmcud83kQT+0j"}');
                response.setStatusCode(200);
                
                String continuationLabel = IntegrationEngine.continuationLabel;
                List<String> labels = new List<String>{continuationLabel};
                    Object continuationState= IntegrationEngine.continuationState;
                
                String panCallOutResponse;
                
                Test.startTest();
                Test.setContinuationResponse(continuationLabel, response);
                panCallOutResponse= (String)IntegrationEngine.processPANVerficationResponse(labels, IntegrationEngine.continuationState);
                Test.stopTest();
                
                String responseExpected ='{"body":null,"response":{"status":"SUCCESS","respDesc":"PAN Status verified Successfully","content":[{"NSDLReturnCdDesc":"Success","NSDLReturnCd":0,"NSDLPANStatusDesc":"Existing and Valid PAN","NSDLPANStatus":"E","NSDLAadhaarSeedingStatus":null,"Name":"Shri GOURAB  GOSWAMI","IDNSDLNameMatch":100,"ID":"CSWPG3660G"}]}}';
                System.assertEquals(responseExpected, panCallOutResponse, 'SUCCESS');
            }  
        } catch(Exception ex){
            System.assertEquals(ex.getMessage(),'Script-thrown exception', 'Exception');
        }
    }
    
    @isTest
    public static void testPanVerificationService2(){
        
        try{   
            
            //Test.setMock(HttpCalloutMock.class, new PanVerificationHttpCalloutMock());
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            Applicant__c applicant = TestDataUtility.createTestApplicant(false);
            applicant.Opportunity__c=opp.Id;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert applicant;
            }
            
            String panVerifyRequest = '{"applicantId":"'+applicant.Id+'" ,"panNumber":"CSWPG3660G","firstName":"","lastName":"'+applicant.Customer_Last_Name__c+' "}';
            Continuation con = (Continuation)IntegrationEngine.doPANCallout(panVerifyRequest);
            // Create a mock response
            HttpResponse response = new HttpResponse();
            response.setBody('{"JData":"bmvHXB5/b59ltoDPA8dwPKjM9zW1GwK5fvqA5/8G5njg6LzMAYI4Id6LrLJmRnoijeFuaYkwDnaZHsa+6xYit82GLmdlqwXm0BAn6A39s+8tEj1DO22pB2d+pdaaLuahdq9qhYsY6BgGXwQveaGe+qoE4LwKTSymv3ZxeE/r6N6i8Jj51Sf62N2i1LJhaAOKAIhf3hW/g9kO5MXzbWm4eZn7whfcMFdjvVr3NW4wI788aR9xGUvwj87yC5uQuaM5hKzMwKJJJKU0eR4sNzzTPForbed5aCwoRITFkUeQ/l8yNywULXNPSI8qTYEEyt5yW9tfbI6t+Vm48d8F807UycU2Kn4G+Z2DYm9yfuHn+NqlO3nRJnjgmcud83kQT+0j"}');
            response.setStatusCode(200);
            
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
                Object continuationState= IntegrationEngine.continuationState;
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
            String panCallOutResponse= (String)IntegrationEngine.processPANVerficationResponse(labels, IntegrationEngine.continuationState);
            Test.stopTest();
            String responseExpected ='{"body":null,"response":{"status":"SUCCESS","respDesc":"PAN Status verified Successfully","content":[{"NSDLReturnCdDesc":"Success","NSDLReturnCd":0,"NSDLPANStatusDesc":"Existing and Valid PAN","NSDLPANStatus":"E","NSDLAadhaarSeedingStatus":null,"Name":"Shri GOURAB  GOSWAMI","IDNSDLNameMatch":100,"ID":"CSWPG3660G"}]}}';
            System.assertEquals(responseExpected, panCallOutResponse, 'SUCCESS');
            
        } catch(Exception ex){
            System.assertEquals(ex.getMessage(),System.Label.ApplicantFirstName, 'Exception');
        }
    }
    @isTest
    public static void testPanVerificationService3(){
        
        try{   
            
            //Test.setMock(HttpCalloutMock.class, new PanVerificationHttpCalloutMock());
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            Applicant__c applicant = TestDataUtility.createTestApplicant(false);
            applicant.Opportunity__c=opp.Id;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert applicant;
            }
            
            String panVerifyRequest = '{"applicantId":"'+applicant.Id+'" ,"panNumber":"CSWPG3660G","firstName":"'+applicant.Customer_First_Name__c+'","lastName":""}';
            Continuation con = (Continuation)IntegrationEngine.doPANCallout(panVerifyRequest);
            // Create a mock response
            HttpResponse response = new HttpResponse();
            response.setBody('{"JData":"bmvHXB5/b59ltoDPA8dwPKjM9zW1GwK5fvqA5/8G5njg6LzMAYI4Id6LrLJmRnoijeFuaYkwDnaZHsa+6xYit82GLmdlqwXm0BAn6A39s+8tEj1DO22pB2d+pdaaLuahdq9qhYsY6BgGXwQveaGe+qoE4LwKTSymv3ZxeE/r6N6i8Jj51Sf62N2i1LJhaAOKAIhf3hW/g9kO5MXzbWm4eZn7whfcMFdjvVr3NW4wI788aR9xGUvwj87yC5uQuaM5hKzMwKJJJKU0eR4sNzzTPForbed5aCwoRITFkUeQ/l8yNywULXNPSI8qTYEEyt5yW9tfbI6t+Vm48d8F807UycU2Kn4G+Z2DYm9yfuHn+NqlO3nRJnjgmcud83kQT+0j"}');
            response.setStatusCode(200);
            
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
                Object continuationState= IntegrationEngine.continuationState;
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
            String panCallOutResponse= (String)IntegrationEngine.processPANVerficationResponse(labels, IntegrationEngine.continuationState);
            Test.stopTest();
            String responseExpected ='{"body":null,"response":{"status":"SUCCESS","respDesc":"PAN Status verified Successfully","content":[{"NSDLReturnCdDesc":"Success","NSDLReturnCd":0,"NSDLPANStatusDesc":"Existing and Valid PAN","NSDLPANStatus":"E","NSDLAadhaarSeedingStatus":null,"Name":"Shri GOURAB  GOSWAMI","IDNSDLNameMatch":100,"ID":"CSWPG3660G"}]}}';
            System.assertEquals(responseExpected, panCallOutResponse, 'SUCCESS');
            
        } catch(Exception ex){
            System.assertEquals(ex.getMessage(),System.Label.ApplicantLastName, 'Exception');
        }
    }
    
    @isTest
    public static void testPanVerificationService4(){
        
        try{   
            
            //Test.setMock(HttpCalloutMock.class, new PanVerificationHttpCalloutMock());
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            Applicant__c applicant = TestDataUtility.createTestApplicant(false);
            applicant.Opportunity__c=opp.Id;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert applicant;
            }
            
            String panVerifyRequest = '{"applicantId":"'+applicant.Id+'" ,"panNumber":"","firstName":"'+applicant.Customer_First_Name__c+'","lastName":"'+applicant.Customer_Last_Name__c+' "}';
            Continuation con = (Continuation)IntegrationEngine.doPANCallout(panVerifyRequest);
            // Create a mock response
            HttpResponse response = new HttpResponse();
            response.setBody('{"JData":"bmvHXB5/b59ltoDPA8dwPKjM9zW1GwK5fvqA5/8G5njg6LzMAYI4Id6LrLJmRnoijeFuaYkwDnaZHsa+6xYit82GLmdlqwXm0BAn6A39s+8tEj1DO22pB2d+pdaaLuahdq9qhYsY6BgGXwQveaGe+qoE4LwKTSymv3ZxeE/r6N6i8Jj51Sf62N2i1LJhaAOKAIhf3hW/g9kO5MXzbWm4eZn7whfcMFdjvVr3NW4wI788aR9xGUvwj87yC5uQuaM5hKzMwKJJJKU0eR4sNzzTPForbed5aCwoRITFkUeQ/l8yNywULXNPSI8qTYEEyt5yW9tfbI6t+Vm48d8F807UycU2Kn4G+Z2DYm9yfuHn+NqlO3nRJnjgmcud83kQT+0j"}');
            response.setStatusCode(200);
            
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
                Object continuationState= IntegrationEngine.continuationState;
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
            String panCallOutResponse= (String)IntegrationEngine.processPANVerficationResponse(labels, IntegrationEngine.continuationState);
            Test.stopTest();
            String responseExpected ='{"body":null,"response":{"status":"SUCCESS","respDesc":"PAN Status verified Successfully","content":[{"NSDLReturnCdDesc":"Success","NSDLReturnCd":0,"NSDLPANStatusDesc":"Existing and Valid PAN","NSDLPANStatus":"E","NSDLAadhaarSeedingStatus":null,"Name":"Shri GOURAB  GOSWAMI","IDNSDLNameMatch":100,"ID":"CSWPG3660G"}]}}';
            System.assertEquals(responseExpected, panCallOutResponse, 'SUCCESS');
            
        } catch(Exception ex){
            System.assertEquals(ex.getMessage(),System.Label.PAN_Number, 'Exception');
        }
    }
    
    /*@isTest
public static void testPanVerificationService5(){

try{   

//Test.setMock(HttpCalloutMock.class, new PanVerificationHttpCalloutMock());
Opportunity opp = TestDataUtility.createTestOpportunity(false);
if (Schema.sObjectType.Opportunity.isCreateable()){
insert opp;
}
Applicant__c applicant = TestDataUtility.createTestApplicant(false);
if (Schema.sObjectType.Applicant__c.isCreateable()){
insert applicant;
}

String panVerifyRequest = '{"applicantId":"'+applicant.Id+'" ,"panNumber":"CSWPG3660G","firstName":"'+applicant.Customer_First_Name__c+'","lastName":"'+applicant.Customer_Last_Name__c+' "}';
Continuation con = (Continuation)IntegrationEngine.doPANCallout(panVerifyRequest);
// Create a mock response
HttpResponse response = new HttpResponse();
response.setBody('{"JData":"bmvHXB5/b59ltoDPA8dwPKjM9zW1GwK5fvqA5/8G5njg6LzMAYI4Id6LrLJmRnoijeFuaYkwDnaZHsa+6xYit82GLmdlqwXm0BAn6A39s+8tEj1DO22pB2d+pdaaLuahdq9qhYsY6BgGXwQveaGe+qoE4LwKTSymv3ZxeE/r6N6i8Jj51Sf62N2i1LJhaAOKAIhf3hW/g9kO5MXzbWm4eZn7whfcMFdjvVr3NW4wI788aR9xGUvwj87yC5uQuaM5hKzMwKJJJKU0eR4sNzzTPForbed5aCwoRITFkUeQ/l8yNywULXNPSI8qTYEEyt5yW9tfbI6t+Vm48d8F807UycU2Kn4G+Z2DYm9yfuHn+NqlO3nRJnjgmcud83kQT+0j"}');
response.setStatusCode(200);

String continuationLabel = IntegrationEngine.continuationLabel;
List<String> labels = new List<String>{continuationLabel};
Object continuationState= IntegrationEngine.continuationState;
Test.startTest();
Test.setContinuationResponse(continuationLabel, response);
String panCallOutResponse= (String)IntegrationEngine.processPANVerficationResponse(labels, IntegrationEngine.continuationState);
Test.stopTest();
String responseExpected ='{"body":null,"response":{"status":"SUCCESS","respDesc":"PAN Status verified Successfully","content":[{"NSDLReturnCdDesc":"Success","NSDLPANStatusDesc":"Existing and Valid PAN","NSDLPANStatus":"E","Name":"Shri GOURAB  GOSWAMI","IDNSDLNameMatch":100,"ID":"CSWPG3660G"}]}}';
System.assertEquals(responseExpected, panCallOutResponse, 'SUCCESS');

} catch(Exception ex){
System.assertEquals(ex.getMessage(),System.Label.ReferenceId, 'Exception');
}
}*/
    
    @isTest
    public static void testPanVerificationService6(){
        
        try{   
            
            //Test.setMock(HttpCalloutMock.class, new PanVerificationHttpCalloutMock());
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            Applicant__c applicant = TestDataUtility.createTestApplicant(false);
            applicant.Opportunity__c=opp.Id;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert applicant;
            }
            
            String panVerifyRequest = '{"applicantId":"'+applicant.Id+'" ,"panNumber":"CSWPG3660G","firstName":"'+applicant.Customer_First_Name__c+'","lastName":"'+applicant.Customer_Last_Name__c+' "}';
            
            Continuation con = (Continuation)IntegrationEngine.doPANCallout(panVerifyRequest);
            // Create a mock response
            HttpResponse response = new HttpResponse();
            response.setBody('{"JData":"bmvHXB5/b59ltoDPA8dwPKjM9zW1GwK5fvqA5/8G5njg6LzMAYI4Id6LrLJmRnoijeFuaYkwDnaZHsa+6xYit82GLmdlqwXm0BAn6A39s+8tEj1DO22pB2d+pdaaLuahdq9qhYsY6BgGXwQveaGe+qoE4LwKTSymv3ZxeE/r6N6i8Jj51Sf62N2i1LJhaAOKAIhf3hW/g9kO5MXzbWm4eZn7whfcMFdjvVr3NW4wI788aR9xGUvwj87yC5uQuaM5hKzMwKJJJKU0eR4sNzzTPForbed5aCwoRITFkUeQ/l8yNywULXNPSI8qTYEEyt5yW9tfbI6t+Vm48d8F807UycU2Kn4G+Z2DYm9yfuHn+NqlO3nRJnjgmcud83kQT+0j"}');
            response.setStatusCode(500);
            
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
                Object continuationState= IntegrationEngine.continuationState;
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
            String panCallOutResponse= (String)IntegrationEngine.processPANVerficationResponse(labels, IntegrationEngine.continuationState);
            Test.stopTest();
            String responseExpected ='{"body":null,"response":{"status":"SUCCESS","respDesc":"PAN Status verified Successfully","content":[{"NSDLReturnCdDesc":"Success","NSDLReturnCd":0,"NSDLPANStatusDesc":"Existing and Valid PAN","NSDLPANStatus":"E","NSDLAadhaarSeedingStatus":null,"Name":"Shri GOURAB  GOSWAMI","IDNSDLNameMatch":100,"ID":"CSWPG3660G"}]}}';
            System.assertEquals(responseExpected, panCallOutResponse, 'SUCCESS');
            
        } catch(Exception ex){
            // System.assertEquals(ex.getMessage(),'No Response Found');
        }
    }
}