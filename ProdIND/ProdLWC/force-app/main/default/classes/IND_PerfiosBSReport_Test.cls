/*------------------------------------------------------------
Author:        Manish Baldota
Company:       Persistent Systems
Description:   Test class for IND_PerfiosBSReportService,IntegrationEngine,IND_PerfiosBSReportRequest,IND_PerfiosBSReportResponse class 
Apex Class:    IND_PerfiosBSReportService,IntegrationEngine,IND_PerfiosBSReportRequest,IND_PerfiosBSReportResponse
History
Date            Author              Comments
-------------------------------------------------------------
12-23-2021      Manish Baldota       Created
------------------------------------------------------------*/
@isTest
public class IND_PerfiosBSReport_Test {
    // @Method:		createTestData
    // @Created by:	Manish Baldota
    // @Description:Test setup method to create the test data for IND_PerfiosBSReport_Test classs
    // @Param:		''	
    // @Return: 	'' 
    @TestSetup
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
    // @Method:		TestServiceMetthod
    // @Created by:	Manish Baldota
    // @Description:Test setup method to create the test data for IND_PerfiosBSTransactionStatusService_Test classs
    // @Param:		''	
    // @Return: 	'' 
   /* @isTest
    public static void testIND_TransactionReport(){
        try{
            Opportunity optl1 = new Opportunity();
                optl1.StageName = 'Asset Details';
                optl1.CloseDate = Date.newInstance(2021, 1, 11);
                optl1.Name = 'testone';
                insert optl1;
                
                Applicant__c applicant = new Applicant__c();
                applicant.Opportunity__c = optl1.Id;
                applicant.Contact_number__c = '9743514830';
                applicant.Applicant_Type__c = 'Co-Borrower';
                insert applicant;
                           
            Continuation con = (Continuation)IntegrationEngine.doPerfiosBSTransactionReportCallout(applicant.Id,optl1.Id);
           
            HttpResponse response = new HttpResponse();
			response.setBody('{"JData": "OKVvNtV2YjZyATlZCw0a6EhDVyAy/PrdjzXXfaLpQfRw20UFo3CUxVREevn6J4cypDitsg4IEe+j59NYSa++6GngViTkY+TbWCqMtCO/gkT9yXHP1VxtctfZ6um+TySaFH+UQ5jXbSWTzJ4u39608v80FdSwVgwnTazzYjkN1YLPJRvpyPPwaxmXidnzy4MeURGkENtOYc27wW8CemyRow39AaD4gREfgkojwsZSMiA="}');
            response.setStatusCode(200);            
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
                Object continuationState= IntegrationEngine.continuationState;   
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
            String membershipResponse = (String)IntegrationEngine.processPerfiosTransactionReportResponse(labels, IntegrationEngine.continuationState);
            Test.stopTest();
            String responseExpected ='SUCCESS';
            System.assertEquals(responseExpected, membershipResponse);
        } catch(Exception ex){
            System.assertEquals(ex.getMessage(),'Script-thrown exception');
        }
    } */
    
        @isTest
    public static void validateException(){
        try{
            IND_PerfiosBSReportService.getCallOutRequest(null, null);
        }catch(Exception pEx){
            System.assert(pEx.getMessage() != null);
        }
        
    }
    
}