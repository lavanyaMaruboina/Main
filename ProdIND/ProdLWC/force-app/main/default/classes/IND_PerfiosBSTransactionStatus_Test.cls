/*------------------------------------------------------------
Author:        Manish Baldota
Company:       Persistent Systems
Description:   Test class for IND_PerfiosBSTransactionStatusService,IntegrationEngine,IND_PerfiosBSTransactionStatusResponse,IND_PerfiosBSTransactionStatusRequest class 
Apex Class:    IND_PerfiosBSTransactionStatusService,IntegrationEngine,IND_PerfiosBSTransactionStatusResponse,IND_PerfiosBSTransactionStatusRequest
History
Date            Author              Comments
-------------------------------------------------------------
12-23-2021      Manish Baldota       Created
------------------------------------------------------------*/
@isTest
public class IND_PerfiosBSTransactionStatus_Test {
    // @Method:		createTestData
    // @Created by:	Manish Baldota
    // @Description:Test setup method to create the test data for IND_PerfiosBSTransactionStatus_Test classs
    // @Param:		''	
    // @Return: 	'' 
    
    @isTest
    public static void testIND_TransactionStatusAPI(){
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
            
         //   Income_Details__c incomedetails = TestDataUtility.createTestIncomeDetails(false, applicant);
         //   incomedetails.Perfios_Transaction_Id__c = '04022022111044173';
         //   insert incomedetails;
            
            Test.startTest();
            //String clientTransactionId ='04022022111044173';
            //String loanApplicationId= '00671000001DVNBAA4'; 
            //String incomeDtlId= '';
      //      IND_PerfiosBSTransactionStatusRequest perfiosbstransactionstatusrequest = new IND_PerfiosBSTransactionStatusRequest(String.valueOf(incomedetails.id));
      //      perfiosbstransactionstatusrequest.getHttpRequestHeaders();
     //       IntegrationEngine.doBSTransactionStatusAsyncCallout(String.valueOf(incomedetails.id),String.valueOf(opp.id),String.valueOf(incomedetails.id));
            Test.stopTest();
        } catch(Exception ex){
            System.assertEquals(ex.getMessage(),'Script-thrown exception');
        }
    }
    
    /*@TestSetup
public static void createTestData(){
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
// @Method:		testIND_TransactionStatusAPI
// @Created by:	Manish Baldota
// @Description:Test setup method to create the test data for IND_PerfiosBSTransactionStatusService_Test classs
// @Param:		''	
// @Return: 	'' 
@isTest
public static void testIND_TransactionStatusAPI(){
try{
Applicant__c applicant = [SELECT ID FROM Applicant__c LIMIT 1];           
Continuation con = (Continuation)IntegrationEngine.doPerfiosBSTransactionStatusCallout(applicant.Id);

HttpResponse response = new HttpResponse();
response.setBody('{ "JData":"+W/AVp8dDVyg2zif21T5vxwiP8SI8UmUZyjdOnveVsuAuhyYxqrotswsZ+YJwCCfexW4WOXqWjCcBVg9e9rpjinAq0XhtOQ/RgqqYFyk7QMUG0ZJipi3hXF5xVEyZN+6bJsHQ21LYMu1RaFTtOPHHWwEGvLGcMPjYZQspB/O9LBb8+itgplSgpIgQQlUWHaWxuKMV9u88u0Y9n6406yhMf4akbYUXTJNmk6LpJ1gDX+XZX6j4WzUI72K+0r3spr84IWN8HtYBCtngih8goEPKw=="}');              response.setStatusCode(200);

String continuationLabel = IntegrationEngine.continuationLabel;
List<String> labels = new List<String>{continuationLabel};
Object continuationState= IntegrationEngine.continuationState;   
Test.startTest();
Test.setContinuationResponse(continuationLabel, response);
String membershipResponse = (String)IntegrationEngine.processPerfiosTransactionStatusAPIResponse(labels, IntegrationEngine.continuationState);
Test.stopTest();
String responseExpected ='SUCCESS';
System.assertEquals(responseExpected, membershipResponse);
} catch(Exception ex){
System.assertEquals(ex.getMessage(),'Script-thrown exception');
}
}*/
}