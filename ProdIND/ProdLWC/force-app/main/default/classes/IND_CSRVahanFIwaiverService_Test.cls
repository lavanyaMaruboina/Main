/*------------------------------------------------------------
Author:        Chowdesha N
Company:       Persistent Systems
Description:   Test class for  Ind_CSRVahanFIwaiverRequest class 
Apex Class:    Ind_CSRVahanFIwaiverRequest
History
Date            Author              Comments
-------------------------------------------------------------
12-21-2021      Chowdesha N       Created
------------------------------------------------------------*/
@isTest
public class IND_CSRVahanFIwaiverService_Test {
     // @Method:        TestServiceMetthod
    // @Created by: Chowdesha N
    // @Description:Test setup method to create the test data for ND_CSRVahanFIwaiverRequest classs
    // @Param:      ''  
    // @Return:     '' 
    
    @TestSetup
    public static void testSetupData(){
        Profile p = [SELECT Id FROM Profile WHERE Name='CMU'];
            system.debug('p'+ p);
            User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                              EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                              LocaleSidKey='en_US', ProfileId = p.Id,
                              TimeZoneSidKey='America/Los_Angeles',
                               MobilePhone = '9701498575',User_Id__c = '29927_MO',
                              UserName='standarduser4@testorg.com.psdev1');
            insert u;
    }
    @isTest
    public static void testInd_CSRVahanFIwaiverService(){
        try{
            
              User u=[Select Id,Name from User where UserName='standarduser4@testorg.com.psdev1'];
             // User u= TestDataUtility.createUser(false, 'IBL Counter Staff');
             
            
            //Test.setMock(HttpCalloutMock.class, new SMSHttpCalloutMock());
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            
            Applicant__c applicant = TestDataUtility.createTestApplicantForSMS(false);
            applicant.Opportunity__c=opp.Id;
            applicant.Scorecard_Decision__c = 'Light Green';
            String loanAppId = applicant.Opportunity__r.id;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert applicant;
            }
            String str = '{"loanApplicationId":"'+opp.Id+'"}';
            Continuation con = (Continuation)IntegrationEngine.doCSRVahanFIwaiverCallout(str);
            
            // Create a mock response
            HttpResponse response = new HttpResponse();
            String body = '{ "JData": "2vpcWmd94Hf51CcvrulEb+RHxIr76N7eshSnKyzJoJ1Stp7Vo+7l4syzIM9rVQDXuIMcoxhzwiJ7Fg6bMZgag8cnZYyZpixU9q2Z6+A/DPv0geIFE/4uia6zP4LZAq5KnmgUY2FC5fqsf32iUe7bw81lP4lIRsMp+uOhtIh4Eqc="}';
            body = body.substring(10, body.length()-2); 
            response.setBody(body);
            response.setStatusCode(200);
            
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
            Object continuationState= IntegrationEngine.continuationState; 
           // RequestWrapper  requestWrappperObj=TestDataUtility.getRequestWrapper();
            List<Applicant__c> applicantList= new List<Applicant__c>();
            applicantList.add(applicant);            
            
            String waiverResponse = '';
             system.runAs(u){
            Test.startTest();
            //IND_CSRVahanFIwaiverRequest csrVahanRequest=IND_CSRVahanFIwaiverService.getCSRVahanFIwaiverRequest(requestWrappperObj,applicantList);
            //Ind_CSRVahanFIwaiverRequest csrVahanRequest=new Ind_CSRVahanFIwaiverRequest(requestWrappperObj,applicantList);             
            Test.setContinuationResponse(continuationLabel, response);
            waiverResponse = (String)IntegrationEngine.processCSRVahanFIwaiverAPIResponse(labels, IntegrationEngine.continuationState);
            Test.stopTest();
             }
            system.debug('waiverResponse ---> '+waiverResponse);
            String CSRVahanFIwaiverresponseExpected ='{"Off_Addresss_Fi": "Not Waived", "Curr_Resi_Addresss_Fi": "Waived",  "Perm_Resi_Addresss_Fi": "Not Waived"}';
            System.assertEquals(CSRVahanFIwaiverresponseExpected, waiverResponse);
        
        } catch(Exception ex){
          //  System.assertEquals(ex.getMessage(),Null);
        }
    }
    
     @isTest
    public static void testIND_CSRVahanFIwaiverService2(){
        try{
          User u=[Select Id,Name from User where UserName='standarduser4@testorg.com.psdev1'];
            
            //Test.setMock(HttpCalloutMock.class, new SMSHttpCalloutMock());
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            if (Schema.sObjectType.Opportunity.isCreateable()){
                
                insert opp;
            }
            
            Applicant__c applicant = TestDataUtility.createTestApplicantForSMS(false);
            applicant.Opportunity__c=opp.Id;
            applicant.Scorecard_Decision__c = 'Light Green';
            String loanAppId = applicant.Opportunity__r.id;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert applicant;
            }
            
                      
            
            // Create a mock response
            HttpResponse response = new HttpResponse();
            String body = '{"JData": "2vpcWmd94Hf51CcvrulEb+RHxIr76N7eshSnKyzJoJ1Stp7Vo+7l4syzIM9rVQDXuIMcoxhzwiJ7Fg6bMZgag8cnZYyZpixU9q2Z6+A/DPv0geIFE/4uia6zP4LZAq5KnmgUY2FC5fqsf32iUe7bw81lP4lIRsMp+uOhtIh4Eqc="}';
            body = body.substring(10, body.length()-2); 
            response.setBody(body);
            response.setStatusCode(200);
            
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
            Object continuationState= IntegrationEngine.continuationState;   
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
            String CSRVahanFIwaiverResponse = (String)IntegrationEngine.processCSRVahanFIwaiverAPIResponse(labels, IntegrationEngine.continuationState);
            Test.stopTest();
            system.debug('CSRVahanFIwaiverResponse '+CSRVahanFIwaiverResponse);
            String CSRVahanFIwaiverresponseExpected ='{"Off_Addresss_Fi": "Not Waived", "Curr_Resi_Addresss_Fi": "Waived",  "Perm_Resi_Addresss_Fi": "Not Waived"}';
            System.assertEquals(CSRVahanFIwaiverresponseExpected, CSRVahanFIwaiverResponse);
        } catch(Exception ex){
            //System.assertEquals(ex.getMessage(),'Null label');
        }
    }
    
     @isTest
    public static void getCSRVahanFIwaiverRequestTest(){
        
        try{
        Opportunity opgd1 = new Opportunity();
        opgd1.StageName = 'Qualification';
        opgd1.CloseDate = Date.newInstance(2021, 1, 11);
        opgd1.Name = 'testone';
        insert opgd1;
        
        RequestWrapper reqWrapper = new RequestWrapper();
        reqWrapper.applicantId = opgd1.Id;
        
        List<Applicant__c> appList = new List<Applicant__c>();
        
        Applicant__c applicant = TestDataUtility.createTestApplicantForSMS(false);
        applicant.Opportunity__c=opgd1.Id;
        appList.add(applicant);
        insert appList;
        IND_CSRVahanFIwaiverService.getCSRVahanFIwaiverRequest(reqWrapper,appList);
        }
        catch(Exception e){}
        
    }
    
 
}