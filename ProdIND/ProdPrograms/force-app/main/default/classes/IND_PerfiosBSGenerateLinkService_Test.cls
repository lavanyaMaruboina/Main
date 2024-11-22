/*------------------------------------------------------------
Author:        Manish Baldota
Company:       Persistent Systems
Description:   Test class for IND_PerfiosBSGenerateLinkService,IntegrationEngine,IND_PerfiosBSGenerateLinkResponse class 
Apex Class:    IND_PerfiosBSGenerateLinkService,IntegrationEngine,IND_PerfiosBSGenerateLinkResponse,IND_PerfiosBSGenerateLinkRequest
History
Date            Author              Comments
-------------------------------------------------------------
12-23-2021      Manish Baldota       Created
------------------------------------------------------------*/
@isTest
public class IND_PerfiosBSGenerateLinkService_Test {
    // @Method:     createTestData
    // @Created by: Manish Baldota
    // @Description:Test setup method to create the test data for IND_PerfiosBSGenerateLinkService_Test classs
    // @Param:      ''  
    // @Return:     '' 
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
        
        Income_Details__c incomeDetails =  TestDataUtility.createIncomeDetailsRecord();
        incomeDetails.Applicant__c = applicant.Id;
        if (Schema.sObjectType.Income_Details__c.isCreateable()){
            insert incomeDetails;
        }
            
        Applicant__c negativeApplicant =new Applicant__c(Name='negativeApplicant',
                                           Contact_Number__c ='1234',
                                           Customer_First_Name__c='GOURAB',
                                           Customer_Last_Name__c='GOSWAMI',
                                           Whatsapp_number__c='',
                                           Consent_Received__c=true,
                                            Income_Ca__c='SAL',
                                            Profile__c = 'Software Engineer',
                                            Bureau_Pull_Attempts__c=1,
                                            Selfie_Retry_Attempts__c=2,
                                            Income_Source__c='Non-Earning',
                                            Income_source_available__c = true,
                                            Preferred_address_for_communication__c = 'Permanent Address',
                                            of_family_members_residing_with_you__c = '2',
                                            Residence_country__c = 'India',
                                            Who_will_repay_the_loan__c = 'Borrower',
                                            Marital_status__c = 'SINGP',
                                            Spouse_Name__c = 'Sameer',
                                            Father_s_name__c = 'Viraa',
                                            Mother_s_name__c = 'Neeta',
                                            Opportunity__c = opp.Id,
                                            Communication_language__c = 'Hindi',
                                            Customer_Qualification__c = 'B2',
                                            Email_Id__c = '',
                                            DocAuth_Application_Id__c = 'AC1241_24524353_g1',
                                            
                                            Consent_Sent__c=DateTime.valueOf(DateTime.now().getTime()-4));
        if (Schema.sObjectType.Applicant__c.isCreateable()){
            insert negativeApplicant;
        }
       Income_Details__c incomeDetailsNegative =  TestDataUtility.createIncomeDetailsRecord();
        incomeDetailsNegative.Applicant__c = negativeApplicant.Id;
        
        if (Schema.sObjectType.Income_Details__c.isCreateable()){
            insert incomeDetailsNegative;
        }
            
    }
    // @Method:     testIND_generateLinkAPI
    // @Created by: Manish Baldota
    // @Description:Test method to cover the Perfios Bank Statement generate link API with +ve scenarios
    // @Param:      ''  
    // @Return:     '' 
    @isTest
    public static void testIND_generateLinkAPI(){
        try{
            Applicant__c applicant = [SELECT ID FROM Applicant__c WHERE Name <> 'negativeApplicant' LIMIT 1];    
            Income_Details__c incomeDetails = [SELECT ID FROM Income_Details__c WHERE Applicant__c =:applicant.Id LIMIT 1];           
            Continuation con = (Continuation)IntegrationEngine.doPerfiosGenerateLinkCallout(incomeDetails.Id,'8433211089');
           
            HttpResponse response = new HttpResponse();
            response.setBody('{ "JData":"+W/AVp8dDVyg2zif21T5vxwiP8SI8UmUZyjdOnveVsuAuhyYxqrotswsZ+YJwCCfexW4WOXqWjCcBVg9e9rpjinAq0XhtOQ/RgqqYFyk7QMUG0ZJipi3hXF5xVEyZN+6bJsHQ21LYMu1RaFTtOPHHWwEGvLGcMPjYZQspB/O9LBb8+itgplSgpIgQQlUWHaWxuKMV9u88u0Y9n6406yhMf4akbYUXTJNmk6LpJ1gDX+XZX6j4WzUI72K+0r3spr84IWN8HtYBCtngih8goEPKw=="}');              response.setStatusCode(200);
            
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
                Object continuationState= IntegrationEngine.continuationState;   
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
            String membershipResponse = (String)IntegrationEngine.processPerfiosGenerateLinkAPIResponse(labels, IntegrationEngine.continuationState);
            Test.stopTest();
            String responseExpected ='SUCCESS';
            System.assertEquals(responseExpected, membershipResponse);
        } catch(Exception ex){
            System.assertEquals(ex.getMessage(),'Script-thrown exception');
        }
    }
    // @Method:     testIND_generateLinkAPINegative
    // @Created by: Manish Baldota
    // @Description: Test method to cover the Perfios Bank Statement generate link API with -ve scenarios
    // @Param:      ''  
    // @Return:     '' 
    @isTest
    public static void testIND_generateLinkAPINegative(){
        try{
            Applicant__c applicant = [SELECT ID FROM Applicant__c WHERE Name = 'negativeApplicant' LIMIT 1];    
            Income_Details__c incomeDetails = [SELECT ID FROM Income_Details__c WHERE Applicant__c =:applicant.Id LIMIT 1];           
            Continuation con = (Continuation)IntegrationEngine.doPerfiosGenerateLinkCallout(incomeDetails.Id,'8433211089');
            
            HttpResponse response = new HttpResponse();
            response.setBody('{ "JData":"+W/AVp8dDVyg2zif21T5vxwiP8SI8UmUZyjdOnveVsuAuhyYxqrotswsZ+YJwCCfexW4WOXqWjCcBVg9e9rpjinAq0XhtOQ/RgqqYFyk7QMUG0ZJipi3hXF5xVEyZN+6bJsHQ21LYMu1RaFTtOPHHWwEGvLGcMPjYZQspB/O9LBb8+itgplSgpIgQQlUWHaWxuKMV9u88u0Y9n6406yhMf4akbYUXTJNmk6LpJ1gDX+XZX6j4WzUI72K+0r3spr84IWN8HtYBCtngih8goEPKw=="}');              response.setStatusCode(200);
            
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
                Object continuationState= IntegrationEngine.continuationState;   
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
            String membershipResponse = (String)IntegrationEngine.processPerfiosGenerateLinkAPIResponse(labels, IntegrationEngine.continuationState);
            Test.stopTest();
            String responseExpected ='SUCCESS';
            System.assertEquals(responseExpected, membershipResponse);
        } catch(Exception ex){
            System.assertEquals(ex.getMessage(),'Script-thrown exception');
        }
    }
    @isTest
    public static void getCallOutRequest(){
        try{
           Opportunity opgd1 = new Opportunity();
            opgd1.StageName = 'Qualification';
            opgd1.CloseDate = Date.newInstance(2021, 1, 11);
            opgd1.Name = 'testone';
            insert opgd1;
            
            RequestWrapper reqWrapper = new RequestWrapper();
            reqWrapper.applicantId = opgd1.Id;
            IND_PerfiosBSGenerateLinkService.getCallOutRequest(reqWrapper,'8433211089');
            
        } catch(Exception ex){
            //System.assertEquals(ex.getMessage(),'Script-thrown exception');
        }
    }
}