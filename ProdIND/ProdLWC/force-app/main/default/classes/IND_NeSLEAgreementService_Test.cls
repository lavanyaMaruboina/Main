/*------------------------------------------------------------
Author:        Bondiga Thilak
Company:       Persistent Systems
Description:   Test class for IND_NeSLEAgreementRequest class 
Apex Class:    IND_NeSLEAgreementRequest
History
Date            Author              Comments
-------------------------------------------------------------
12-22-2021      Bondiga Thilak       Created
------------------------------------------------------------*/
@isTest
public class IND_NeSLEAgreementService_Test {
   @TestSetup
    public static void createTestData(){
        Profile p = [SELECT Id FROM Profile WHERE Name='IBL Business Executive'];
            system.debug('p'+ p);
            User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                              EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                              LocaleSidKey='en_US', ProfileId = p.Id,
                              TimeZoneSidKey='America/Los_Angeles',
                              UserName='standarduser4@testorg.com.psdev1',
                             MobilePhone='9533089614');
            insert u;
        System.runAs(u){
        Opportunity opp = TestDataUtility.createTestOpportunity(false);
        if (Schema.sObjectType.Opportunity.isCreateable()){
            insert opp;
        }        
        Applicant__c applicant = TestDataUtility.createTestApplicantForSMS(false);
        applicant.Opportunity__c=opp.Id;
         String loanAppId = applicant.Opportunity__r.id;
        if (Schema.sObjectType.Applicant__c.isCreateable()){
            insert applicant;
        }
        }
    }
    // @Method:		TestServiceMetthod
    // @Created by:	Bondiga Thilak
    // @Description:Test setup method to create the test data for IND_NeSLEAgreementRequest classs
    // @Param:		''	
    // @Return: 	''  
    @isTest
    public static void testIND_NeSLEAgreementService(){
        try{
         
            Opportunity opp = [Select Id from Opportunity LIMIT 1];
            Applicant__c app = [Select Id from Applicant__c LIMIT 1];
            User u = [SELECT Id,usertype FROM User WHERE UserName='standarduser4@testorg.com.psdev1' AND IsActive = true LIMIT 1]; 
            Continuation con = (Continuation)IntegrationEngine.doNeSLEAgreementCallout(app.Id,opp.Id);
            
            Map<String, HttpRequest> requests = con.getRequests();
            //system.assert(requests.size() == 1);
            // Create a mock response
            HttpResponse response = new HttpResponse();
            response.setBody('JData":"bmvHXB5/b59ltoDPA8dwPO76mbIIRh7pyG7RWowIbHN3hk8QTRxk4W3LV5BWkeHFJjhX/Xcs99yoZDxzViyvqe537/9zDCEJb2TKUPcyY9/GgqfjY6ZWWzrpBd3L9pqc');            
            response.setStatusCode(200);
            
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
            Object continuationState= IntegrationEngine.continuationState;   
             String membershipResponse = '';
            system.runAs(u){
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
            membershipResponse = (String)IntegrationEngine.processNeSLEAgreementAPIResponse(labels, IntegrationEngine.continuationState);
            Test.stopTest();
            }
            String responseExpected ='{ "response": { "status": "SUCCESS", "respDesc": "NeSL eAgreement Status", "content": [ { "txnID": "CFDVEHCTKS09666C202104211526145384", "docImage": "JVBERi0xLjQKJeLjz9MKMiAwIG9iago8PC9GaWx0ZXIvRmxhdGVEZWNvZGUvTGVuZ3RoIDQ5Pj5zdHJlYW0KeJwr5HIK4TI2U7AwMFMISeFyDeEK5CpUMFQwAEIImZyroB" } ] } }';
            System.assertEquals(responseExpected, membershipResponse);
        } catch(Exception ex){
           // System.assertEquals(ex.getMessage(),'Null label');
        }
    }
    
    
    @isTest
    public static void testIND_NeSLEAgreementService1(){
        try{
             
            Opportunity opp = [Select Id from Opportunity LIMIT 1];
            Applicant__c app = [Select Id from Applicant__c LIMIT 1];
            User u = [SELECT Id,usertype FROM User WHERE UserName='standarduser4@testorg.com.psdev1' AND IsActive = true LIMIT 1];
            Continuation con = (Continuation)IntegrationEngine.doNeSLEAgreementCallout(app.Id,opp.Id);
            
            Map<String, HttpRequest> requests = con.getRequests();
            //system.assert(requests.size() == 1);
            // Create a mock response
            HttpResponse response = new HttpResponse();
            response.setBody('JData":"bmvHXB5/b59ltoDPA8dwPO76mbIIRh7pyG7RWowIbHN3hk8QTRxk4W3LV5BWkeHFJjhX/Xcs99yoZDxzViyvqe537/9zDCEJb2TKUPcyY9/GgqfjY6ZWWzrpBd3L9pqc');            
            response.setStatusCode(200);
            
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
            Object continuationState= IntegrationEngine.continuationState;
             String membershipResponse = '';
            system.runAs(u){
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
            membershipResponse = (String)IntegrationEngine.processNeSLEAgreementAPIResponse(labels, IntegrationEngine.continuationState);
            Test.stopTest();
            }
            String responseExpected ='{ "response": { "status": "SUCCESS", "respDesc": "NeSL eAgreement Status", "content": [ { "txnID": "CFDVEHCTKS09666C202104211526145384", "docImage": "JVBERi0xLjQKJeLjz9MKMiAwIG9iago8PC9GaWx0ZXIvRmxhdGVEZWNvZGUvTGVuZ3RoIDQ5Pj5zdHJlYW0KeJwr5HIK4TI2U7AwMFMISeFyDeEK5CpUMFQwAEIImZyroB" } ] } }';
            System.assertEquals(responseExpected, membershipResponse);
        } catch(Exception ex){
            //System.assertEquals(ex.getMessage(),'Null label');
        }
    }
    
    @isTest
    public static void testIND_NeSLEAgreementService2(){
        try{
            Opportunity opp = [Select Id from Opportunity LIMIT 1];
            Applicant__c app = [Select Id from Applicant__c LIMIT 1];
            User u = [SELECT Id,usertype FROM User WHERE UserName='standarduser4@testorg.com.psdev1' AND IsActive = true LIMIT 1];
            Continuation con = (Continuation)IntegrationEngine.doNeSLEAgreementCallout(app.Id,opp.Id);
            
            Map<String, HttpRequest> requests = con.getRequests();
            //system.assert(requests.size() == 1);
            // Create a mock response
            HttpResponse response = new HttpResponse();
            response.setBody('JData":"bmvHXB5/b59ltoDPA8dwPO76mbIIRh7pyG7RWowIbHN3hk8QTRxk4W3LV5BWkeHFJjhX/Xcs99yoZDxzViyvqe537/9zDCEJb2TKUPcyY9/GgqfjY6ZWWzrpBd3L9pqc');            
            response.setStatusCode(400);
            
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
            Object continuationState= IntegrationEngine.continuationState;
            String membershipResponse = '';
            system.runAs(u){
                Test.startTest();
                Test.setContinuationResponse(continuationLabel, response);
                membershipResponse = (String)IntegrationEngine.processNeSLEAgreementAPIResponse(labels, IntegrationEngine.continuationState);
                Test.stopTest();
            }
            
            String responseExpected ='{"response":{"status":"FAILED","respDesc":"NESL TXN Id not Found","content":""}}';
            System.assertEquals(responseExpected, membershipResponse);
        } catch(Exception ex){
           // System.assertEquals(ex.getMessage(),'Null label');
        }
    }
    
    @isTest
    public static void testOne(){
        
          Opportunity opp = [Select Id from Opportunity LIMIT 1];
            Applicant__c app = [Select Id from Applicant__c LIMIT 1];
        
        Test.startTest();
             IND_NeSLEAgreementService.getNeSLEAgreementRequest(app,opp.Id);
        Test.stopTest();
    } 
}