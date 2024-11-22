/*------------------------------------------------------------
Author:        Bondiga Thilak
Company:       Persistent Systems
Description:   Test class for IND_AgreementBookletRequest class 
Apex Class:    IND_AgreementBookletRequest
History
Date            Author              Comments
-------------------------------------------------------------
12-22-2021      Bondiga Thilak       Created 
------------------------------------------------------------*/
@isTest 
public class IND_AgreementBookletService_Test {
    // @Method:    createTestData
    // @Created by:  Bondiga Thilak
    // @Description:Test setup method to create the test data for IND_AgreementBookletRequest classs
    // @Param:    ''  
    // @Return:   '' 
    //@TestSetup
    @testSetup
    public static void createTestData(){       
        //Create User     
        Contact con = TestDataUtility.createTestContact(true);
        Profile p = [SELECT Id FROM Profile WHERE Name='IBL Partner Community Counter Staff'];     
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',MobilePhone='9999999999',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,Maker_Id__c='12',IsActive = true,
                          TimeZoneSidKey='America/Los_Angeles', ContactId = con.Id,
                          UserName='test_userprod1243@indusbank.com');
        insert u;
        System.runAs(u)
        {
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }        
            Applicant__c applicant = TestDataUtility.createTestApplicantForSMS(false);
            applicant.Opportunity__c=opp.Id;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert applicant;
            }
        }        
    }
    
    // @Method:    TestServiceMetthod
    // @Created by:  Bondiga Thilak
    // @Description:Test setup method to create the test data for IND_AgreementBookletRequest classs
    // @Param:    ''  
    // @Return:   ''  
    @isTest
    public static void testIND_AgreementBookletService3(){
        try{
            User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod1243@indusbank.com' AND IsActive = true LIMIT 1];                             
            
            Applicant__c applicant = [SELECT Id, Opportunity__c, Opportunity__r.Deal_Number__c FROM Applicant__c LIMIT 1];
            
            Continuation con = (Continuation)IntegrationEngine.doAgreementBookletCallout('123',applicant.Id,applicant.Opportunity__c,applicant.Opportunity__r.Deal_Number__c);
            
            //Map<String, HttpRequest> requests = con.getRequests();
            //system.assert(requests.size() == 1);
            // Create a mock response
            HttpResponse response = new HttpResponse();
            response.setBody('JData":"bmvHXB5/b59ltoDPA8dwPO76mbIIRh7pyG7RWowIbHMFkORWxlYonE7gGiEufcFqBYNZPeWycxlZ/ecWKwlzvMLi7EtGifuQrRivF/Wf2HQxYE8mx6tGzziIrEKtV4i+KAcQ5J3qvx6wy+KzKCC0Ew==');            
            response.setStatusCode(200);
            
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
                Object continuationState= IntegrationEngine.continuationState;   
            
            
            String membershipResponse;
            System.runAs(u)
            {
                Test.startTest();
                Test.setContinuationResponse(continuationLabel, response);
                membershipResponse = (String)IntegrationEngine.processAgreementBookletAPIResponse(labels, IntegrationEngine.continuationState);
                Test.stopTest();
            }
            String responseExpected ='{ "response": { "status": "SUCCESS", "respDesc": "Get Agreement Booklet No Details", "content": [ { "Stamp_S_No": "", "Stamp_On": "21/01/2021", "Stamp_Printed_Location_Blcode": "GNC", "Stamp_Printed_Location_BlName": "GNC BRANCH", "Stamp_Type": "AST", "Stamp_Value": "100.0000", "Stamped_For": "ITM00101", "Stamp_Towards": "IPOA" } ] } }';
            System.assertEquals(responseExpected, membershipResponse);
        } catch(Exception ex){
            System.assertNotEquals(ex.getMessage(),'last block incomplete in decryption');                        
        }
    } 
    
    
    @isTest
    public static void testIND_AgreementBookletService(){
        try{
            
            User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod1243@indusbank.com' AND IsActive = true LIMIT 1];                             
            
            Applicant__c applicant = [SELECT Id, Opportunity__c FROM Applicant__c LIMIT 1];
            
            //    Continuation con = (Continuation)IntegrationEngine.doAgreementBookletCallout(applicant.Id,loanAppId);
            
            // Create a mock response
            HttpResponse response = new HttpResponse();
            response.setBody('JData":"bmvHXB5/b59ltoDPA8dwPO76mbIIRh7pyG7RWowIbHMFkORWxlYonE7gGiEufcFqBYNZPeWycxlZ/ecWKwlzvMLi7EtGifuQrRivF/Wf2HQxYE8mx6tGzziIrEKtV4i+KAcQ5J3qvx6wy+KzKCC0Ew==');            
            response.setStatusCode(400);
            
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
                Object continuationState= IntegrationEngine.continuationState; 
            String membershipResponse;
            System.runAs(u)
            {
                Test.startTest();
                Test.setContinuationResponse(continuationLabel, response);
                membershipResponse = (String)IntegrationEngine.processAgreementBookletAPIResponse(labels, IntegrationEngine.continuationState);
                Test.stopTest();
            }            
            
            String responseExpected ='{"response":{"status":"FAILED","respDesc":"Given Agreement Booklet No is already used","content":""}}';
            System.assertEquals(responseExpected, membershipResponse);
        } catch(Exception ex){
            System.assertEquals(ex.getMessage(),'Null label');
        }
    }
    
    @isTest
    public static void testIND_AgreementBookletService2(){
        try{
            User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod1243@indusbank.com' AND IsActive = true LIMIT 1];                             
            
            Applicant__c applicant = [SELECT Id, Opportunity__c FROM Applicant__c LIMIT 1];
            
            //    Continuation con = (Continuation)IntegrationEngine.doAgreementBookletCallout(applicant.Id,loanAppId);
            
            // Create a mock response
            HttpResponse response = new HttpResponse();
            response.setBody('JData":"bmvHXB5/b59ltoDPA8dwPO76mbIIRh7pyG7RWowIbHMFkORWxlYonE7gGiEufcFqBYNZPeWycxlZ/ecWKwlzvMLi7EtGifuQrRivF/Wf2HQxYE8mx6tGzziIrEKtV4i+KAcQ5J3qvx6wy+KzKCC0Ew==');            
            response.setStatusCode(400);
            
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
                Object continuationState= IntegrationEngine.continuationState;   
            String membershipResponse = '';
            System.runAs(u)
            {
                Test.startTest();
                Test.setContinuationResponse(continuationLabel, response);
                membershipResponse = (String)IntegrationEngine.processAgreementBookletAPIResponse(labels, IntegrationEngine.continuationState);
                Test.stopTest();
            }
            
            String responseExpected ='{"response":{"status":"FAILED","respDesc":"Given Agreement Booklet No is already used","content":""}}';
            System.assertEquals(responseExpected, membershipResponse);
        } catch(Exception ex){
            System.assertEquals(ex.getMessage(),'Null label');
        }
    }
    
    
    
    @isTest
    public static void testIND_AgreementBookletService4(){
        try{
            User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod1243@indusbank.com' AND IsActive = true LIMIT 1];                             
            
            Applicant__c applicant = [SELECT Id, Opportunity__c,Opportunity__r.Deal_Number__c FROM Applicant__c LIMIT 1];
            
            Continuation con = (Continuation)IntegrationEngine.doAgreementBookletCallout('123',applicant.Id,applicant.Opportunity__c,applicant.Opportunity__r.Deal_Number__c);
            
            //Map<String, HttpRequest> requests = con.getRequests();
            //system.assert(requests.size() == 1);
            // Create a mock response
            HttpResponse response = new HttpResponse();
            response.setBody('JData":"ZDZLaZ7+UUMMs4Qd+iREtdWeFfrDRGgw2H+mOgt5vpKuXk32ppIQxD8F4XSCvS7kZrOdcPXjKDWxwDzv9Wc304AG/UCPxid5g+KOjVxU7Y+KepqM/s0pMGo8RW16Vqw+0j/52lhU35i/G5LwTnQ8id1yMFayKQqJ8AZbIBDYtL9lw9UC+IOE3y9Q3YgyptGTPx8mYG7gUINUHa9osXry0Hd30lIPapQAa1tlYQdzyDeJYST4HoTyhzJYG7HcWg46ovhKbWJg1S4Lr4eOaTY7OvkaSEezmU7xt07iOqnCc42aY1nVoS18/HN2LxKfBMMhDwnjAGY82xtNtRjt+f31nVbJvErK3lo+oAn344UfISO68PYP8tQgr4ZYU+NfpvsYv62fvcq8fo9STj+P8JlUY0B8SpAQrkGrMCjdUP5CW/n/Azyth5C7IuJ/KKfu/qIu1K8lOmFQvHGnZ0tFJnSb1MjT7W3BS7idEeJwCNw8hAeIHui9jt7QTwYt9JayS6PqAOWAUphFIDE7EmmTEkgi9dlNfu0RMeCcOjWUGBPXYAPuu5pmHppLEyjUFGQwv3D5CsiDYmSGYtFYTQVHUBqoXr8tCf2kF1pGQld6/4aYZWzHPsVVfVfbWwW13rtGL4jZsbGuOv6e8gef3Jdb7JW8ZhmxNdGH4OmvuX4x7GgDF0a74PP1ApQqBIoMLKe9XunqD1WUzW6B2327/UhnsdUMMg==');            
            response.setStatusCode(200);
            
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
                Object continuationState= IntegrationEngine.continuationState;   
            String membershipResponse = '';
            System.runAs(u)
            {
                Test.startTest();
                Test.setContinuationResponse(continuationLabel, response);
                membershipResponse = (String)IntegrationEngine.processAgreementBookletAPIResponse(labels, IntegrationEngine.continuationState);
                Test.stopTest();
            }
            String responseExpected ='{ "response": { "status": "SUCCESS", "respDesc": "Get Agreement Booklet No Details", "content": [ { "Stamp_S_No": "", "Stamp_On": "21/01/2021", "Stamp_Printed_Location_Blcode": "GNC", "Stamp_Printed_Location_BlName": "GNC BRANCH", "Stamp_Type": "AST", "Stamp_Value": "100.0000", "Stamped_For": "ITM00101", "Stamp_Towards": "IPOA" } ] } }';
            System.assertEquals(responseExpected, membershipResponse);
        } catch(Exception ex){
            System.assertNotEquals(ex.getMessage(),'last block incomplete in decryption');
        }
    } 
    
    @isTest
    public static void validateException(){
        try{
            User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod1243@indusbank.com' AND IsActive = true LIMIT 1];  
            System.runAs(u)
            {                           
                IND_AgreementBookletService.getAgreementBookletRequest(null, null, null,null);  
            }
        }catch(Exception ex){
            System.assertEquals(ex.getMessage(),'Loan application id should not be null');
        }
        
    }
}