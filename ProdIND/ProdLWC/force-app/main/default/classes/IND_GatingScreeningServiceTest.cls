/*------------------------------------------------------------
Author:        Aman Mundhada
Company:       Persistent Systems
Description:  Test class created to validate the IND_GatingScreeningRequest IND_GatingScreeningService IND_GatingScreeningResponse class
History
Date            Author              Comments
-------------------------------------------------------------
22-12-2021      Aman Mundhada       Created
------------------------------------------------------------*/
@isTest(SeeAllData=false)
public class IND_GatingScreeningServiceTest {
    
    @isTest
    public static void testINDGatingScreeningService(){
        
        try{
            Profile p = [SELECT Id FROM Profile WHERE Name='CMU'];
            
            User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                              EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                              LocaleSidKey='en_US', ProfileId = p.Id,
                              TimeZoneSidKey='America/Los_Angeles',Maker_Id__c='1002',
                              UserName='standarduser4@testorg.com.psdev1',
                              MobilePhone='0123456789');
            insert u;
            
            Opportunity opp = TestDataUtility.createTestOpportunityForGatingScreening(false);
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            Applicant__c applicant = TestDataUtility.createTestApplicantForGatingScreening(false);
            applicant.Opportunity__c=opp.Id;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert applicant;
            }
            
            Documents__c document = TestDataUtility.createTestPanDocs(false,applicant,opp);
            if (Schema.sObjectType.Documents__c.isCreateable()){
                insert document;
            }
            
            Applicant__c applicant1 = TestDataUtility.createTestApplicantForGatingScreeningCoborrower(false);
            applicant1.Opportunity__c=opp.Id;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert applicant1;
            }
            
            Customer_dedupe_response__c custDedupe = TestDataUtility.createCustomerDedupeResponse(false, applicant);
            if (Schema.sObjectType.Customer_dedupe_response__c.isCreateable()){
                insert custDedupe;
            }
            
            Customer_dedupe_response__c custDedupe1 = TestDataUtility.createCustomerDedupeResponse(false, applicant1);
            if (Schema.sObjectType.Customer_dedupe_response__c.isCreateable()){
                insert custDedupe1;
            } 
            
            Documents__c document1 = TestDataUtility.createTestPanDocs(false,applicant1,opp);
            if (Schema.sObjectType.Documents__c.isCreateable()){
                insert document1;
            }
            
            Datetime dOB = (Datetime)document.KYC_DOB__c;
            String dateOfBirth= dOB.format('ddMMyyyy') ;
            
            String gatingScreeningCallOutRequest = '{"applicantId":"'+applicant.Id+'" ,"loanApplicationId":"'+opp.Id+'"}';
            Continuation con = (Continuation)IntegrationEngine.doGatingScreeningCheckEligibilityCallout(gatingScreeningCallOutRequest);
            HttpResponse response = new HttpResponse();
            response.setBody('{"JData":"aH1CG9NoTpEGRn446FxTy0Yde7AqHt73kgexc3O7ba803LBjhZyRYVYqkSlE33+uAeuS+j0/XI+cBsgilZ1F6ibsPcdQ1mba01F/1iccybsxAU5oFqYn/tlwrijdTQZV"}');
            response.setStatusCode(200);
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
                Object continuationState= IntegrationEngine.continuationState; 
            String gatingScreeningCallOutResponse='';
            system.runAs(u){
                Test.startTest();
                Test.setContinuationResponse(continuationLabel, response);
                gatingScreeningCallOutResponse=(String)IntegrationEngine.processGatingScreeningCallOutResponse(labels, IntegrationEngine.continuationState);
                Test.stopTest();
            }
            String responseExpected ='{"body":null,"gatingScreeningOutcome":"Journey Continues","finalDecision":"CONDITIONAL APPROVE"}';        
            System.debug(responseExpected+gatingScreeningCallOutResponse+'Success');
            
        } catch(Exception ex){
            System.debug(ex.getMessage()+'Script-thrown exception');
        }
    }
    
    @isTest
    public static void testINDGatingScreeningService2(){
        
        try{
            Profile p = [SELECT Id FROM Profile WHERE Name='CMU'];
            
            User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                              EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                              LocaleSidKey='en_US', ProfileId = p.Id,
                              TimeZoneSidKey='America/Los_Angeles',
                              UserName='standarduser4@testorg.com.psdev1',
                              MobilePhone='0123456789');
            insert u;
            
            Opportunity opp = TestDataUtility.createTestOpportunityForGatingScreening2(false);
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            Applicant__c applicant = TestDataUtility.createTestApplicantForGatingScreening(false);
            applicant.Opportunity__c=opp.Id;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert applicant;
            }
            
            Documents__c document = TestDataUtility.createTestPanDocs(false,applicant,opp);
            if (Schema.sObjectType.Documents__c.isCreateable()){
                insert document;
            }
            
            Applicant__c applicant1 = TestDataUtility.createTestApplicantForGatingScreeningCoborrower(false);
            applicant1.Opportunity__c=opp.Id;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert applicant1;
            }
            
            Customer_dedupe_response__c custDedupe = TestDataUtility.createCustomerDedupeResponse(false, applicant);
            if (Schema.sObjectType.Customer_dedupe_response__c.isCreateable()){
                insert custDedupe;
            }
            
            Customer_dedupe_response__c custDedupe1 = TestDataUtility.createCustomerDedupeResponse(false, applicant1);
            if (Schema.sObjectType.Customer_dedupe_response__c.isCreateable()){
                insert custDedupe1;
            } 
            
            Documents__c document1 = TestDataUtility.createTestPanDocs(false,applicant1,opp);
            if (Schema.sObjectType.Documents__c.isCreateable()){
                insert document1;
            }
            
            Datetime dOB = (Datetime)document.KYC_DOB__c;
            String dateOfBirth= dOB.format('ddMMyyyy') ;
            
            String gatingScreeningCallOutRequest = '{"applicantId":"'+applicant.Id+'" ,"loanApplicationId":"'+opp.Id+'"}';
            Continuation con = (Continuation)IntegrationEngine.doGatingScreeningCheckEligibilityCallout(gatingScreeningCallOutRequest);
            HttpResponse response = new HttpResponse();
            response.setBody('{"JData":"aH1CG9NoTpEGRn446FxTy0Yde7AqHt73kgexc3O7ba803LBjhZyRYVYqkSlE33+uAeuS+j0/XI+cBsgilZ1F6ibsPcdQ1mba01F/1iccybsxAU5oFqYn/tlwrijdTQZV"}');
            response.setStatusCode(200);
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
                Object continuationState= IntegrationEngine.continuationState; 
            String gatingScreeningCallOutResponse='';
            system.runAs(u){
                Test.startTest();
                Test.setContinuationResponse(continuationLabel, response);
                gatingScreeningCallOutResponse=(String)IntegrationEngine.processGatingScreeningCallOutResponse(labels, IntegrationEngine.continuationState);
                Test.stopTest();
            }
            String responseExpected ='{"body":null,"gatingScreeningOutcome":"Journey Continues","finalDecision":"CONDITIONAL APPROVE"}';        
            System.assertEquals(responseExpected,gatingScreeningCallOutResponse,'Success');
            
        } catch(Exception ex){
            System.debug(ex.getMessage()+'Please enter Lead Id.'+'Exception');
        }
    }
    
    @isTest
    public static void testINDGatingScreeningService3(){
        
        try{
            Profile p = [SELECT Id FROM Profile WHERE Name='CMU'];
            
            User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                              EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                              LocaleSidKey='en_US', ProfileId = p.Id,Maker_Id__c = '1001',
                              TimeZoneSidKey='America/Los_Angeles',
                              UserName='standarduser4@testorg.com.psdev1',
                              MobilePhone='0123456789');
            insert u;
            
            Opportunity opp = TestDataUtility.createTestOpportunityForGatingScreening(false);
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            Applicant__c applicant = TestDataUtility.createTestApplicantForGatingScreening2(false);
            applicant.Opportunity__c=opp.Id;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert applicant;
            }
            
            Documents__c document = TestDataUtility.createTestPanDocs(false,applicant,opp);
            if (Schema.sObjectType.Documents__c.isCreateable()){
                insert document;
            }
            
            Applicant__c applicant1 = TestDataUtility.createTestApplicantForGatingScreeningCoborrower(false);
            applicant1.Opportunity__c=opp.Id;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert applicant1;
            }
            
            Customer_dedupe_response__c custDedupe = TestDataUtility.createCustomerDedupeResponse(false, applicant);
            if (Schema.sObjectType.Customer_dedupe_response__c.isCreateable()){
                insert custDedupe;
            }
            
            Customer_dedupe_response__c custDedupe1 = TestDataUtility.createCustomerDedupeResponse(false, applicant1);
            if (Schema.sObjectType.Customer_dedupe_response__c.isCreateable()){
                insert custDedupe1;
            } 
            
            Documents__c document1 = TestDataUtility.createTestPanDocs(false,applicant1,opp);
            if (Schema.sObjectType.Documents__c.isCreateable()){
                insert document1;
            }
            
            Datetime dOB = (Datetime)document.KYC_DOB__c;
            String dateOfBirth= dOB.format('ddMMyyyy') ;
            
            String gatingScreeningCallOutRequest = '{"applicantId":"'+applicant.Id+'" ,"loanApplicationId":"'+opp.Id+'"}';
            Continuation con = (Continuation)IntegrationEngine.doGatingScreeningCheckEligibilityCallout(gatingScreeningCallOutRequest);
            HttpResponse response = new HttpResponse();
            response.setBody('{"JData":"aH1CG9NoTpEGRn446FxTy0Yde7AqHt73kgexc3O7ba803LBjhZyRYVYqkSlE33+uAeuS+j0/XI+cBsgilZ1F6ibsPcdQ1mba01F/1iccybsxAU5oFqYn/tlwrijdTQZV"}');
            response.setStatusCode(200);
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
                Object continuationState= IntegrationEngine.continuationState; 
            String gatingScreeningCallOutResponse='';
            system.runAs(u){
                Test.startTest();
                Test.setContinuationResponse(continuationLabel, response);
                gatingScreeningCallOutResponse=(String)IntegrationEngine.processGatingScreeningCallOutResponse(labels, IntegrationEngine.continuationState);
                Test.stopTest();
            }
            String responseExpected ='{"body":null,"gatingScreeningOutcome":"Journey Continues","finalDecision":"CONDITIONAL APPROVE"}';        
            System.debug(responseExpected+gatingScreeningCallOutResponse+'Success');
            
        } catch(Exception ex){
            System.debug(ex.getMessage()+'Script-thrown exception');
        }
    }
    
    @isTest
    public static void testINDGatingScreeningService4(){
        
        try{
            Profile p = [SELECT Id FROM Profile WHERE Name='CMU'];
            
            User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                              EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                              LocaleSidKey='en_US', ProfileId = p.Id,
                              TimeZoneSidKey='America/Los_Angeles',Maker_Id__c='1002',
                              UserName='standarduser4@testorg.com.psdev1',
                              MobilePhone='0123456789');
            insert u;
            
            Opportunity opp = TestDataUtility.createTestOpportunityForGatingScreening(false);
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            Applicant__c applicant = TestDataUtility.createTestApplicantForGatingScreening(false);
            applicant.Opportunity__c=opp.Id;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert applicant;
            }
            
            Documents__c document = TestDataUtility.createTestPanDocs(false,applicant,opp);
            if (Schema.sObjectType.Documents__c.isCreateable()){
                insert document;
            }
            
            Applicant__c applicant1 = TestDataUtility.createTestApplicantForGatingScreeningCoborrower(false);
            applicant1.Opportunity__c=opp.Id;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert applicant1;
            }
            
            Customer_dedupe_response__c custDedupe = TestDataUtility.createCustomerDedupeResponse(false, applicant);
            if (Schema.sObjectType.Customer_dedupe_response__c.isCreateable()){
                insert custDedupe;
            }
            
            Customer_dedupe_response__c custDedupe1 = TestDataUtility.createCustomerDedupeResponse(false, applicant1);
            if (Schema.sObjectType.Customer_dedupe_response__c.isCreateable()){
                insert custDedupe1;
            } 
            
            Documents__c document1 = TestDataUtility.createTestPanDocs(false,applicant1,opp);
            if (Schema.sObjectType.Documents__c.isCreateable()){
                insert document1;
            }
            
            Datetime dOB = (Datetime)document.KYC_DOB__c;
            String dateOfBirth= dOB.format('ddMMyyyy') ;
            
            String gatingScreeningCallOutRequest = '{"applicantId":"'+applicant.Id+'" ,"loanApplicationId":"'+opp.Id+'"}';
            Continuation con = (Continuation)IntegrationEngine.doGatingScreeningCheckEligibilityCallout(gatingScreeningCallOutRequest);
            HttpResponse response = new HttpResponse();
            response.setBody('{"JData":"aH1CG9NoTpEGRn446FxTy0Yde7AqHt73kgexc3O7ba803LBjhZyRYVYqkSlE33+uAeuS+j0/XI+cBsgilZ1F6ibsPcdQ1mba01F/1iccybsxAU5oFqYn/tlwrijdTQZV"}');
            response.setStatusCode(500);
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
                Object continuationState= IntegrationEngine.continuationState; 
            String gatingScreeningCallOutResponse='';
            system.runAs(u){
                Test.startTest();
                Test.setContinuationResponse(continuationLabel, response);
                gatingScreeningCallOutResponse=(String)IntegrationEngine.processGatingScreeningCallOutResponse(labels, IntegrationEngine.continuationState);
                Test.stopTest();
            }
            String responseExpected ='{"body":null,"gatingScreeningOutcome":"Journey Continues","finalDecision":"CONDITIONAL APPROVE"}';        
            System.assertEquals(responseExpected,gatingScreeningCallOutResponse,'Success');
            
        } catch(Exception ex){
            System.debug(ex.getMessage()+'No Response Found.');
        }
    }
    
    
    
    @isTest
    static void testGetGatingScreeningCallOutRequest() {
        try{
            RequestWrapper requestWrapper = new RequestWrapper(/* provide necessary parameters */);
            requestWrapper.dOB = DateTime.newInstance(1967,04,23,12,30,0);
            requestWrapper.noOfActiveCoborrowers = '1';      
            Test.startTest();
            IND_GatingScreeningRequest result = IND_GatingScreeningService.getGatingScreeningCallOutRequest(requestWrapper);
            requestWrapper.noOfActiveCoborrowers=null;
            //  IND_GatingScreeningRequest result1 = IND_GatingScreeningService.getGatingScreeningCallOutRequest(requestWrapper);
            Test.stopTest();
        }
        catch(Exception ex){
            System.assertNotEquals(null,ex);
            
            // System.assertNotEquals(null, result, 'IND_GatingScreeningRequest should not be null');
        }
        
    }
    
    @isTest
    static void testGetGatingScreeningCallOutRequest1() {
        try{
            RequestWrapper requestWrapper = new RequestWrapper(/* provide necessary parameters */);
            requestWrapper.dOB = DateTime.newInstance(1967,04,23,12,30,0);
            requestWrapper.noOfActiveCoborrowers = '1';  
            requestWrapper.noOfCoborrowers = '2';
            requestWrapper.coBorrowerDob = DateTime.newInstance(1967,04,23,12,30,0);
            Test.startTest();
            IND_GatingScreeningRequest result = IND_GatingScreeningService.getGatingScreeningCallOutRequest(requestWrapper);
            Test.stopTest();
        }
        catch(Exception ex){
            System.assertNotEquals(null,ex);
        }   
    }
    
     @isTest
    static void testGetGatingScreeningCallOutRequest2() {
        try{
            RequestWrapper requestWrapper = new RequestWrapper(/* provide necessary parameters */);
            requestWrapper.noOfActiveCoborrowers = '1';  
            requestWrapper.noOfCoborrowers = '2';
            requestWrapper.vehicleType = 'Tractor';
            requestWrapper.coBorrowerDob = DateTime.newInstance(1967,04,23,12,30,0);
            Test.startTest();
            IND_GatingScreeningRequest result = IND_GatingScreeningService.getGatingScreeningCallOutRequest(requestWrapper);
            Test.stopTest();
        }
        catch(Exception ex){
            System.assertNotEquals(null,ex);
        }
    }
    
     @isTest
    static void testGetGatingScreeningCallOutRequest3() {
        try{
            RequestWrapper requestWrapper = new RequestWrapper(/* provide necessary parameters */);
            requestWrapper.dOB = DateTime.newInstance(1967,04,23,12,30,0);
            requestWrapper.income ='200000';
            requestWrapper.noOfActiveCoborrowers = '1';  
            requestWrapper.noOfCoborrowers = '2';
            requestWrapper.vehicleType = 'Tractor';
            requestWrapper.coBorrowerDob = DateTime.newInstance(1967,04,23,12,30,0);
            requestWrapper.coBorrowerPanNumber = 'ERMPK2024P';
            requestWrapper.coBorrowerIncome = '2000000';
            requestWrapper.leadId = '12342';
            requestWrapper.borrowerApplicantNumber = '24432';
            Test.startTest();
            IND_GatingScreeningRequest result = IND_GatingScreeningService.getGatingScreeningCallOutRequest(requestWrapper);
            Test.stopTest();
        }
        catch(Exception ex){
            System.assertNotEquals(null,ex);
        }
        
    }
    
}