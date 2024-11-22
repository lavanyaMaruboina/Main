/*------------------------------------------------------------
Author:        Bhushan Charde
Company:       Persistent Systems
Description:   Test class for IND_PerfiosGSTReportRequest class 
Apex Class:    IND_PerfiosGSTReportRequest
History
Date            Author              Comments
-------------------------------------------------------------
12-24-2021      Bhushan Charde       Created
------------------------------------------------------------*/
@isTest
public class IND_PerfiosGSTReportService_Test {
    
	// @Method:		TestServiceMetthod
    // @Created by:	Bhushan Charde
    // @Description:Test setup method to create the test data for IND_PerfiosGSTReportRequest classs
    // @Param:		''	
    // @Return: 	'' 
  /*  @isTest
    public static void testPerfiosGSTReportService() {
        try{
            
              Profile p = [SELECT Id FROM Profile WHERE Name='IBL Counter Staff'];
        
    		User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
					EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
					LocaleSidKey='en_US', ProfileId = p.Id,
					TimeZoneSidKey='America/Los_Angeles',
					UserName='standarduser4@testorg.com.psdev1');
            insert u;
            
            
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            
            Applicant__c applicant = TestDataUtility.createTestApplicantForSMS(false);
            applicant.Opportunity__c=opp.Id;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert applicant;
            }
            
            
        //    Continuation con = (Continuation)IntegrationEngine.doGSTReportCallout(applicant.Id,opp.Id);
            
            // Create a mock response
            HttpResponse response = new HttpResponse();
            response.setBody('{"JData": "q5qhPMUP9HERSW8N1BxyafbhhFQ/IjOGP46cZles1NfyIeVyjzlxldhjBMyqEK41hVlH1vYHMJ0ixSYYAGC4HevCLmVNlF0OhZ3V/hTPaP2ltA6TmyJ5V1SfwU+Mu69vh913Qyl4JvXFVkdFcreUv+Z77cRM7m+WcTeMdsav0L1GOUKBr3cXxAKs13fHGPNKN1aWEoI9K7gb7kxQjoUGkBM0AWoJ0Qqz5icGPk62N1c="}');
            response.setStatusCode(200);
            
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
                Object continuationState= IntegrationEngine.continuationState;   
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
            String gstResponse = (String)IntegrationEngine.processGSTReportAPIResponse(labels, IntegrationEngine.continuationState);
            Test.stopTest();
            system.debug('gstResponse '+gstResponse);
            String responseExpected ='{"success":true,"transactionId":"PGIVD4KVODTQAV64FWFIK","url":"https://apidemo.perfios.com/KYCServer/api/v1/gstpdfupload/widget/indusIndRetail/PGIVD4KVODTQAV64FWFIK"}';
            System.assertEquals(responseExpected, gstResponse);
        } catch(Exception ex){
            System.assert(ex.getMessage() != null, 'Script-thrown exception');
        }
    }
    
    
    @isTest
    public static void testPerfiosGSTReportService2(){
        try{
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            
            Applicant__c applicant = TestDataUtility.createTestApplicantForSMSnesl(false);
            applicant.Opportunity__c=opp.Id;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert applicant;
            }
            Income_Details__c incomeDetails = TestDataUtility.createIncomeDetailsRecord();
             incomeDetails.Applicant__c = applicant.Id;
             if (Schema.sObjectType.Income_Details__c.isCreateable()){
             insert incomeDetails;
             }
             String PerfiosGSTReportServicerequest = '{"Lead_Id": "AC9834773_4895748573243","PerfiosTransactionId":"ABCDE12345","reportFormat":"Test" }';
            //   String loanAppId = '00671000001DVS1AAO';
         //   Continuation con = (Continuation)IntegrationEngine.doGSTReportCallout(applicant.Id,opp.Id);
            
            // Create a mock response
            HttpResponse response = new HttpResponse();
            response.setBody('{"JData": "q5qhPMUP9HERSW8N1BxyafbhhFQ/IjOGP46cZles1NfyIeVyjzlxldhjBMyqEK41hVlH1vYHMJ0ixSYYAGC4HevCLmVNlF0OhZ3V/hTPaP2ltA6TmyJ5V1SfwU+Mu69vh913Qyl4JvXFVkdFcreUv+Z77cRM7m+WcTeMdsav0L1GOUKBr3cXxAKs13fHGPNKN1aWEoI9K7gb7kxQjoUGkBM0AWoJ0Qqz5icGPk62N1c="}');
            response.setStatusCode(200);
            
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
                Object continuationState= IntegrationEngine.continuationState;   
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
            String gstResponse = (String)IntegrationEngine.processGSTReportAPIResponse(labels, IntegrationEngine.continuationState);          
            Test.stopTest();
            //String responseExpected ='"{\\"kycResponse\\": {\\"TransactionInfo\\": {\\"Pan\\": \\"6071890510925076003\\", \\"Proc_Code\\": \\"140000\\", \\"Transm_Date_time\\": \\"1229133218\\", \\"Stan\\": \\"247733\\", \\"Local_Trans_Time\\": \\"190218\\", \\"Local_date\\": \\"1229\\", \\"AcqId\\": \\"200031\\", \\"RRN\\": \\"136319247733\\", \\"ResponseCode\\": \\"00\\", \\"ResponseMsg\\": \\"Approved\\", \\"CA_Tid\\": \\"register\\", \\"CA_ID\\": \\"IBLA76232I02361\\", \\"CA_TA\\": \\"IBL HOUSE ANDHERI      MUMBAI       MHIN\\"}, \\"UidData\\": {\\"txn\\": \\"247733\\"}}}"';
            String responseExpected ='{"success":true,"transactionId":"PGIVD4KVODTQAV64FWFIK","url":"https://apidemo.perfios.com/KYCServer/api/v1/gstpdfupload/widget/indusIndRetail/PGIVD4KVODTQAV64FWFIK"}';
            
            System.assertEquals(responseExpected, gstResponse);
        } catch(Exception ex){
            System.assertEquals(ex.getMessage(),'Null label', 'Exception');
        }
    } */
    
    
    @isTest
    public static void verifyGetPerfiosGSTReportRequest(){
        Opportunity opp = TestDataUtility.createTestOpportunity(false);
        insert opp;
        
        Applicant__c applicant = TestDataUtility.createTestApplicant(false);
        applicant.Opportunity__c = opp.Id;
        insert applicant;    
        try{
          //  IND_PerfiosGSTReportRequest result = new IND_PerfiosGSTReportRequest(new Income_Details__c(), opp, null, null);
               IND_PerfiosGSTReportService.getPerfiosGSTReportRequest(applicant);
        //    System.debug('result ==>'+result);
        }catch(Exception pEx){
            System.debug('pEx ==>'+pEx); 
        }
        
          
    } 
    
    
    
}