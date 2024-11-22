/*------------------------------------------------------------
Author:        Prathik
Company:       Persistent Systems
Description:   Test class for IND_FicoDeviationRequest class
Apex Class:    IND_FicoDeviationRequest
History
Date            Author              Comments
-------------------------------------------------------------
12-21-2021      Prathik       Created
------------------------------------------------------------*/
@isTest
public class IND_FicoDeviationService_Test {
    
    @testSetup
    public static void createTestData(){       
        //Create User     
        Contact con = TestDataUtility.createTestContact(true);
        Profile p = [SELECT Id FROM Profile WHERE Name='IBL Partner Community Counter Staff'];     
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',MobilePhone = '9999999999',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,Maker_Id__c='12',IsActive = true,
                          TimeZoneSidKey='America/Los_Angeles', ContactId = con.Id,
                          UserName='test1_userprod123@indusbank.com');
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
            Customer_Code__c cco = new Customer_Code__c();        
            cco.Loan_Application__c = opp.Id;
            cco.Cheque_Return_Count__c = 2;
            cco.Name = 'CU010104';
            insert cco;
            
            Exposure__c objExposure = new Exposure__c(Name = 'TestexpName',
                                                      Loan_Application__c = opp.id,
                                                      Applicant__c = applicant.id,
                                                      Customer_Code__c = cco.Id,
                                                      Finance_Amt__c = 20000,
                                                      Sanctioned_Amt__c = 50000,
                                                      Exposure_Type__c = 'Existing',
                                                      Type__c = 'Borrower Exposure',
                                                      Deal_Stage__c = 'something',
                                                      Deal_No__c = 'something1',
                                                      Deal_Date__c = system.today()-30,
                                                      Product__c = 'a',
                                                      Product_Variant_Name__c = 'test',
                                                      Used__c = 'Y',
                                                      Status_Flag__c = 'N',
                                                      Over_Due__c = 1200,
                                                      AD__c = 3,
                                                      PD__c = 2,
                                                      Current_Demand__c = 15,
                                                      Mor1__c = 'Yes',
                                                      Mor2__c = 'Yes',
                                                      SOH__c = 10992);
            
            insert objExposure;
        }        
    }
    
    // @Method: TestServiceMetthod
    // @Created by : Prathik
    // @Description:Test setup method to create the test data for IND_FicoDeviationRequest classs
    // @Param: ''
    // @Return: ''
    @isTest
    public static void testIND_FicoDeviationService(){
        try{
            User u = [SELECT Id,usertype FROM User WHERE UserName='test1_userprod123@indusbank.com' AND IsActive = true LIMIT 1];                             
            
            Applicant__c applicant = [SELECT Id, Opportunity__c FROM Applicant__c LIMIT 1];
            
            Continuation con = (Continuation)IntegrationEngine.doFicoDeviationCallout(applicant.Id,applicant.Opportunity__c);
            
            // Create a mock response
            HttpResponse response = new HttpResponse();
            response.setBody('{"JData":"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"}');
            response.setStatusCode(200);
            
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
                Object continuationState= IntegrationEngine.continuationState; 
            System.runAs(u)
            {
                Test.startTest();
                Test.setContinuationResponse(continuationLabel, response);
                String ficoDevResponse = (String)IntegrationEngine.processFicoDeviationAPIResponse(labels, IntegrationEngine.continuationState);
                Test.stopTest();
                system.debug('ficoDevResponse '+ficoDevResponse);
                String responseExpected ='{"body":null,"level":"L2","deviationName":"MINIMUM AGE OF BORROWER - SALARIED (IN YEARS)","deviationId":"1001"}';
                System.assertEquals(responseExpected, ficoDevResponse);
            }
        } catch(Exception ex){
            //System.assertEquals(ex.getMessage(),'Script-thrown exception');
            
        }
    }
    
    @isTest
    public static void testIND_FicoDeviationService2(){
        try{            
            User u = [SELECT Id,usertype FROM User WHERE UserName='test1_userprod123@indusbank.com' AND IsActive = true LIMIT 1];                             
            
            Applicant__c applicant = [SELECT Id, Opportunity__c FROM Applicant__c LIMIT 1];
            //  Continuation con = (Continuation)IntegrationEngine.doFicoDeviationCallout(applicant.Id,loanAppId);
            
            // Create a mock response
            HttpResponse response = new HttpResponse();
            response.setBody('{"JData":"PT+HRov67yzPXOSQY7wforwlLfunVvv6GceifpBbee0CucheGQoZ1ThaaK8q1Ct4qHfrkxV2Xs+iVPAF6riBx65RntfxOAL6bUmCT2GEc/bxyscnKcxrXo6maa2QIYH5ZsxcIxi0oSiTPsDGkzN5rQ=="}');
            response.setStatusCode(200);
            
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
                Object continuationState= IntegrationEngine.continuationState; 
            String ficoDevResponse = '';
            system.runAs(u){
                Test.startTest();
                Test.setContinuationResponse(continuationLabel, response);
                ficoDevResponse = (String)IntegrationEngine.processFicoDeviationAPIResponse(labels, IntegrationEngine.continuationState);
                Test.stopTest();
            }
            system.debug('ficoDevResponse '+ficoDevResponse);
            String responseExpected ='{"body":null,"level":"L2","deviationName":"MINIMUM AGE OF BORROWER - SALARIED (IN YEARS)","deviationId":"1001"}';
            System.assertEquals(responseExpected, ficoDevResponse);
        } catch(Exception ex){
            //System.assertEquals(ex.getMessage(),'Please enter Lead Id.');
            System.assertEquals(ex.getMessage(),'Null label');
            
        }
    }
    @isTest
    public static void testIND_FicoDeviationService3(){
        User u = [SELECT Id,usertype FROM User WHERE UserName='test1_userprod123@indusbank.com' AND IsActive = true LIMIT 1];                             
        
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        
        System.runAs(u)
        {
            try
            {
                IND_FicoDeviationRequest obj = new IND_FicoDeviationRequest(opp.Id,opp);    
            }
            catch(Exception e){
                
            }            
        }        
    }
    @isTest
    public static void getFicoDeviationRequest(){
        
        User u = [SELECT Id,usertype FROM User WHERE UserName='test1_userprod123@indusbank.com' AND IsActive = true LIMIT 1];                             
        
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        
        System.runAs(u)
        {
            try
            {	
                Opportunity opp1;
                IND_FicoDeviationService.getFicoDeviationRequest(opp.id,opp);
                
            }
            catch(Exception e){
                
            }            
        }                                   
    }
    @isTest
    public static void validateException(){
        try{
            User u = [SELECT Id,usertype FROM User WHERE UserName='test1_userprod123@indusbank.com' AND IsActive = true LIMIT 1];  
            System.runAs(u)
            {                           
                IND_FicoDeviationService.getFicoDeviationRequest(null, null);  
            }
        }catch(Exception ex){
            System.assertEquals(ex.getMessage(),'Loan application id should not be null');
        }
        
    }

}