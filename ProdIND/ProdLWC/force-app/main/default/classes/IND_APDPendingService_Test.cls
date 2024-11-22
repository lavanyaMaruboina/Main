/*------------------------------------------------------------
Author:        Bondiga Thilak
Company:       Persistent Systems
Description:   Test class for IND_APDPendingRequest class 
Apex Class:    IND_APDPendingRequest
History
Date            Author              Comments
-------------------------------------------------------------
12-22-2021      Bondiga Thilak       Created
------------------------------------------------------------*/
@isTest(SeeAllData=false)
public class IND_APDPendingService_Test {
    
    // @Method:     TestServiceMetthod
    // @Created by: Bondiga Thilak
    // @Description:Test setup method to create the test data for IND_APDPendingRequest classs
    // @Param:      ''  
    // @Return:     ''  
    @isTest
    public static void testAPDPendingService(){
        try{
            //Test.setMock(HttpCalloutMock.class, new SMSHttpCalloutMock());
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
            
            
            Continuation con = (Continuation)IntegrationEngine.doAPDPendingCallout(applicant.Id,loanAppId);
            
            //Map<String, HttpRequest> requests = con.getRequests();
            //system.assert(requests.size() == 1);
            // Create a mock response
            HttpResponse response = new HttpResponse();
            response.setBody('JData":"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"');            
            response.setStatusCode(200);
            
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
            Object continuationState= IntegrationEngine.continuationState;   
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
            String membershipResponse = (String)IntegrationEngine.processAPDPendingAPIResponse(labels, IntegrationEngine.continuationState);
            Test.stopTest();
            String responseExpected ='{"response":{"status":"SUCCESS","respDesc":"APD Pending","content":[{"User_APD_Pending":{"UserRCPendings":[{"Name":"ANOOP S","Segment_Code":"TWO_WHEELER","Deal_Count":"12","Count_1_30":"3","Count_31_60":"0","Count_61_90":"2","Count_Above_90":"0","Total_Count":"5","Doc_Type":"RC Pending"}],"UserInsurancePending":[{"Name":"ANOOP S","Segment_Code":"","Deposit_Avl":"NON-DEPOSIT","Count_1_30":"27","SOH_1_30":"7611241.9500","Count_31_60":"31","SOH_31_60":"9162863.1300","Count_61_90":"28","SOH_61_90":"5379053.8800","Count_Above_90":"231","SOH_Above_90":"60793192.9200","Total_Count":"317","Doc_Type":"Insurance Pending"}]},"Dealer_APD_Pending":{"DealerRCPending":[{"Name":"INDUS MOTOR CO PVT LTD","Deal_Count":"447","Count_1_30":"84","Count_31_60":"5","Count_61_90":"1","Count_Above_90":"4","Total_Count":"94","Doc_Type":"RC Pending"},{"Name":"INDUS MOTOR CO PVT LTD","Deal_Count":"235","Count_1_30":"201","Count_31_60":"30","Count_61_90":"2","Count_Above_90":"2","Total_Count":"235","Doc_Type":"Invoice Pending"}],"DealerInsurancePending":[{"Name":"INDUS MOTOR CO PVT LTD","Deposit_Avl":"DEPOSIT","Count_1_30":"1","SOH_1_30":"107582.4900","Count_31_60":"0","SOH_31_60":"0.0000","Count_61_90":"2","SOH_61_90":"196973.3500","Count_Above_90":"8","SOH_Above_90":"1680122.5100","Total_Count":"11","Doc_Type":"Insurance Pending"},{"Name":"INDUS MOTOR CO PVT LTD","Deposit_Avl":"NON-DEPOSIT","Count_1_30":"1647","SOH_1_30":"660208085.5100","Count_31_60":"1498","SOH_31_60":"549788486.0700","Count_61_90":"1446","SOH_61_90":"471674532.7800","Count_Above_90":"10461","SOH_Above_90":"2915809035.1000","Total_Count":"15052","Doc_Type":"Insurance Pending"}]}}]}}';
            System.assertEquals(responseExpected, membershipResponse,'SUCCESS');
        } catch(Exception ex){
           // System.assertEquals(ex.getMessage(),'Script-thrown exception','ex');
        }
    }
    
  /*  public static void testAPDPendingService2(){
        try{
            //Test.setMock(HttpCalloutMock.class, new SMSHttpCalloutMock());
            Opportunity opp = TestDataUtility.createTestOpportunityforCarwalePricesAPI(false);
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            
            Applicant__c applicant = TestDataUtility.createTestApplicantForSMS(false);
            applicant.Opportunity__c=opp.Id;
             String loanAppId = applicant.Opportunity__r.id;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert applicant;
            }
            
            
            Continuation con = (Continuation)IntegrationEngine.doAPDPendingCallout(applicant.Id,loanAppId);
            
            //Map<String, HttpRequest> requests = con.getRequests();
            //system.assert(requests.size() == 1);
            // Create a mock response
            HttpResponse response = new HttpResponse();
            response.setBody('JData":"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"');            
            response.setStatusCode(200);
            
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
            Object continuationState= IntegrationEngine.continuationState;   
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
            String membershipResponse = (String)IntegrationEngine.processAPDPendingAPIResponse(labels, IntegrationEngine.continuationState);
            Test.stopTest();
            String responseExpected ='{"response":{"status":"SUCCESS","respDesc":"APD Pending","content":[{"User_APD_Pending":{"UserRCPendings":[{"Name":"ANOOP S","Segment_Code":"TWO_WHEELER","Deal_Count":"12","Count_1_30":"3","Count_31_60":"0","Count_61_90":"2","Count_Above_90":"0","Total_Count":"5","Doc_Type":"RC Pending"}],"UserInsurancePending":[{"Name":"ANOOP S","Segment_Code":"","Deposit_Avl":"NON-DEPOSIT","Count_1_30":"27","SOH_1_30":"7611241.9500","Count_31_60":"31","SOH_31_60":"9162863.1300","Count_61_90":"28","SOH_61_90":"5379053.8800","Count_Above_90":"231","SOH_Above_90":"60793192.9200","Total_Count":"317","Doc_Type":"Insurance Pending"}]},"Dealer_APD_Pending":{"DealerRCPending":[{"Name":"INDUS MOTOR CO PVT LTD","Deal_Count":"447","Count_1_30":"84","Count_31_60":"5","Count_61_90":"1","Count_Above_90":"4","Total_Count":"94","Doc_Type":"RC Pending"},{"Name":"INDUS MOTOR CO PVT LTD","Deal_Count":"235","Count_1_30":"201","Count_31_60":"30","Count_61_90":"2","Count_Above_90":"2","Total_Count":"235","Doc_Type":"Invoice Pending"}],"DealerInsurancePending":[{"Name":"INDUS MOTOR CO PVT LTD","Deposit_Avl":"DEPOSIT","Count_1_30":"1","SOH_1_30":"107582.4900","Count_31_60":"0","SOH_31_60":"0.0000","Count_61_90":"2","SOH_61_90":"196973.3500","Count_Above_90":"8","SOH_Above_90":"1680122.5100","Total_Count":"11","Doc_Type":"Insurance Pending"},{"Name":"INDUS MOTOR CO PVT LTD","Deposit_Avl":"NON-DEPOSIT","Count_1_30":"1647","SOH_1_30":"660208085.5100","Count_31_60":"1498","SOH_31_60":"549788486.0700","Count_61_90":"1446","SOH_61_90":"471674532.7800","Count_Above_90":"10461","SOH_Above_90":"2915809035.1000","Total_Count":"15052","Doc_Type":"Insurance Pending"}]}}]}}';
            System.assertEquals(responseExpected, membershipResponse,'SUCCESS');
        } catch(Exception ex){
            System.assertEquals(ex.getMessage(),'Script-thrown exception','ex');
        }
    } */
    
  /*   @isTest
    public static void testAPDPendingService5(){
        try{
            Profile p = [SELECT Id FROM Profile WHERE Name='IBL Counter Staff'];
            system.debug('p'+ p);
            User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                              EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                              LocaleSidKey='en_US', ProfileId = p.Id,
                              TimeZoneSidKey='America/Los_Angeles',
                              UserName='standarduser4@testorg.com.psdev1');
            insert u;
            
            //Test.setMock(HttpCalloutMock.class, new SMSHttpCalloutMock());
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
            
            
            Continuation con = (Continuation)IntegrationEngine.doAPDPendingCallout(applicant.Id,opp.Id);
            
            //Map<String, HttpRequest> requests = con.getRequests();
            //system.assert(requests.size() == 1);
            // Create a mock response
            HttpResponse response = new HttpResponse();
            response.setBody('JData":"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"');            
            response.setStatusCode(200);
            
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
            Object continuationState= IntegrationEngine.continuationState;
            String membershipResponse = '';
            system.runAs(u){
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
            membershipResponse = (String)IntegrationEngine.processAPDPendingAPIResponse(labels, IntegrationEngine.continuationState);
            Test.stopTest();
             }
            String responseExpected ='{"response":{"status":"SUCCESS","respDesc":"APD Pending","content":[{"User_APD_Pending":{"UserRCPendings":[{"Name":"ANOOP S","Segment_Code":"TWO_WHEELER","Deal_Count":"12","Count_1_30":"3","Count_31_60":"0","Count_61_90":"2","Count_Above_90":"0","Total_Count":"5","Doc_Type":"RC Pending"}],"UserInsurancePending":[{"Name":"ANOOP S","Segment_Code":"","Deposit_Avl":"NON-DEPOSIT","Count_1_30":"27","SOH_1_30":"7611241.9500","Count_31_60":"31","SOH_31_60":"9162863.1300","Count_61_90":"28","SOH_61_90":"5379053.8800","Count_Above_90":"231","SOH_Above_90":"60793192.9200","Total_Count":"317","Doc_Type":"Insurance Pending"}]},"Dealer_APD_Pending":{"DealerRCPending":[{"Name":"INDUS MOTOR CO PVT LTD","Deal_Count":"447","Count_1_30":"84","Count_31_60":"5","Count_61_90":"1","Count_Above_90":"4","Total_Count":"94","Doc_Type":"RC Pending"},{"Name":"INDUS MOTOR CO PVT LTD","Deal_Count":"235","Count_1_30":"201","Count_31_60":"30","Count_61_90":"2","Count_Above_90":"2","Total_Count":"235","Doc_Type":"Invoice Pending"}],"DealerInsurancePending":[{"Name":"INDUS MOTOR CO PVT LTD","Deposit_Avl":"DEPOSIT","Count_1_30":"1","SOH_1_30":"107582.4900","Count_31_60":"0","SOH_31_60":"0.0000","Count_61_90":"2","SOH_61_90":"196973.3500","Count_Above_90":"8","SOH_Above_90":"1680122.5100","Total_Count":"11","Doc_Type":"Insurance Pending"},{"Name":"INDUS MOTOR CO PVT LTD","Deposit_Avl":"NON-DEPOSIT","Count_1_30":"1647","SOH_1_30":"660208085.5100","Count_31_60":"1498","SOH_31_60":"549788486.0700","Count_61_90":"1446","SOH_61_90":"471674532.7800","Count_Above_90":"10461","SOH_Above_90":"2915809035.1000","Total_Count":"15052","Doc_Type":"Insurance Pending"}]}}]}}';
            System.assertEquals(responseExpected, membershipResponse,'SUCCESS');
        } catch(Exception ex){
            System.assertEquals(ex.getMessage(),'Insert failed. First exception on row 0; first error: FIELD_CUSTOM_VALIDATION_EXCEPTION, Mobile number should be of 10 digits: [MobilePhone]','ex');
        }
    } */
    
 /*    @isTest
    public static void testAPDPendingService4(){
        try{
            Profile p = [SELECT Id FROM Profile WHERE Name='IBL Counter Staff'];
            system.debug('p'+ p);
            User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                              EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                              LocaleSidKey='en_US', ProfileId = p.Id,
                              TimeZoneSidKey='America/Los_Angeles',
                              UserName='standarduser4@testorg.com.psdev1');
            insert u;
            
            //Test.setMock(HttpCalloutMock.class, new SMSHttpCalloutMock());
            Opportunity opp = TestDataUtility.createTestOpportunitydealmaster(false);
            if (Schema.sObjectType.Opportunity.isCreateable()){
            	insert opp;
            }
            
            Applicant__c applicant = TestDataUtility.createTestApplicantForSMS(false);
            //applicant.Opportunity__c=opp.Id;
             String loanAppId = applicant.Opportunity__r.id;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert applicant;
            }
            
            
            Continuation con = (Continuation)IntegrationEngine.doAPDPendingCallout(applicant.Id,loanAppId);
            
            //Map<String, HttpRequest> requests = con.getRequests();
            //system.assert(requests.size() == 1);
            // Create a mock response
            HttpResponse response = new HttpResponse();
            response.setBody('JData":"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"');            
            response.setStatusCode(200);
            
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
            Object continuationState= IntegrationEngine.continuationState;
            String membershipResponse = '';
            system.runAs(u){
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
            membershipResponse = (String)IntegrationEngine.processAPDPendingAPIResponse(labels, IntegrationEngine.continuationState);
            Test.stopTest();
             }
            String responseExpected ='{"response":{"status":"SUCCESS","respDesc":"APD Pending","content":[{"User_APD_Pending":{"UserRCPendings":[{"Name":"ANOOP S","Segment_Code":"TWO_WHEELER","Deal_Count":"12","Count_1_30":"3","Count_31_60":"0","Count_61_90":"2","Count_Above_90":"0","Total_Count":"5","Doc_Type":"RC Pending"}],"UserInsurancePending":[{"Name":"ANOOP S","Segment_Code":"","Deposit_Avl":"NON-DEPOSIT","Count_1_30":"27","SOH_1_30":"7611241.9500","Count_31_60":"31","SOH_31_60":"9162863.1300","Count_61_90":"28","SOH_61_90":"5379053.8800","Count_Above_90":"231","SOH_Above_90":"60793192.9200","Total_Count":"317","Doc_Type":"Insurance Pending"}]},"Dealer_APD_Pending":{"DealerRCPending":[{"Name":"INDUS MOTOR CO PVT LTD","Deal_Count":"447","Count_1_30":"84","Count_31_60":"5","Count_61_90":"1","Count_Above_90":"4","Total_Count":"94","Doc_Type":"RC Pending"},{"Name":"INDUS MOTOR CO PVT LTD","Deal_Count":"235","Count_1_30":"201","Count_31_60":"30","Count_61_90":"2","Count_Above_90":"2","Total_Count":"235","Doc_Type":"Invoice Pending"}],"DealerInsurancePending":[{"Name":"INDUS MOTOR CO PVT LTD","Deposit_Avl":"DEPOSIT","Count_1_30":"1","SOH_1_30":"107582.4900","Count_31_60":"0","SOH_31_60":"0.0000","Count_61_90":"2","SOH_61_90":"196973.3500","Count_Above_90":"8","SOH_Above_90":"1680122.5100","Total_Count":"11","Doc_Type":"Insurance Pending"},{"Name":"INDUS MOTOR CO PVT LTD","Deposit_Avl":"NON-DEPOSIT","Count_1_30":"1647","SOH_1_30":"660208085.5100","Count_31_60":"1498","SOH_31_60":"549788486.0700","Count_61_90":"1446","SOH_61_90":"471674532.7800","Count_Above_90":"10461","SOH_Above_90":"2915809035.1000","Total_Count":"15052","Doc_Type":"Insurance Pending"}]}}]}}';
            System.assertEquals(responseExpected, membershipResponse,'SUCCESS');
        } catch(Exception ex){
            System.assertEquals(ex.getMessage(),'Insert failed. First exception on row 0; first error: FIELD_CUSTOM_VALIDATION_EXCEPTION, Mobile number should be of 10 digits: [MobilePhone]','ex');
            
        }
    } */
    
     // @Method:     TestServiceMetthod
    // @Created by: Bondiga Thilak
    // @Description:Test setup method to create the test data for IND_APDPendingRequest classs
    // @Param:      ''  
    // @Return:     ''  
    @isTest
    public static void testAPDPendingService2(){
        try{
            //Test.setMock(HttpCalloutMock.class, new SMSHttpCalloutMock());
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
            
            
            Continuation con = (Continuation)IntegrationEngine.doAPDPendingCallout(applicant.Id,loanAppId);
            
            //Map<String, HttpRequest> requests = con.getRequests();
            //system.assert(requests.size() == 1);
            // Create a mock response
            HttpResponse response = new HttpResponse();
            response.setBody('JData":"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"');            
            response.setStatusCode(500);
            
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
            Object continuationState= IntegrationEngine.continuationState;   
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
            String membershipResponse = (String)IntegrationEngine.processAPDPendingAPIResponse(labels, IntegrationEngine.continuationState);
            Test.stopTest();
            String responseExpected ='{"response":{"status":"SUCCESS","respDesc":"APD Pending","content":[{"User_APD_Pending":{"UserRCPendings":[{"Name":"ANOOP S","Segment_Code":"TWO_WHEELER","Deal_Count":"12","Count_1_30":"3","Count_31_60":"0","Count_61_90":"2","Count_Above_90":"0","Total_Count":"5","Doc_Type":"RC Pending"}],"UserInsurancePending":[{"Name":"ANOOP S","Segment_Code":"","Deposit_Avl":"NON-DEPOSIT","Count_1_30":"27","SOH_1_30":"7611241.9500","Count_31_60":"31","SOH_31_60":"9162863.1300","Count_61_90":"28","SOH_61_90":"5379053.8800","Count_Above_90":"231","SOH_Above_90":"60793192.9200","Total_Count":"317","Doc_Type":"Insurance Pending"}]},"Dealer_APD_Pending":{"DealerRCPending":[{"Name":"INDUS MOTOR CO PVT LTD","Deal_Count":"447","Count_1_30":"84","Count_31_60":"5","Count_61_90":"1","Count_Above_90":"4","Total_Count":"94","Doc_Type":"RC Pending"},{"Name":"INDUS MOTOR CO PVT LTD","Deal_Count":"235","Count_1_30":"201","Count_31_60":"30","Count_61_90":"2","Count_Above_90":"2","Total_Count":"235","Doc_Type":"Invoice Pending"}],"DealerInsurancePending":[{"Name":"INDUS MOTOR CO PVT LTD","Deposit_Avl":"DEPOSIT","Count_1_30":"1","SOH_1_30":"107582.4900","Count_31_60":"0","SOH_31_60":"0.0000","Count_61_90":"2","SOH_61_90":"196973.3500","Count_Above_90":"8","SOH_Above_90":"1680122.5100","Total_Count":"11","Doc_Type":"Insurance Pending"},{"Name":"INDUS MOTOR CO PVT LTD","Deposit_Avl":"NON-DEPOSIT","Count_1_30":"1647","SOH_1_30":"660208085.5100","Count_31_60":"1498","SOH_31_60":"549788486.0700","Count_61_90":"1446","SOH_61_90":"471674532.7800","Count_Above_90":"10461","SOH_Above_90":"2915809035.1000","Total_Count":"15052","Doc_Type":"Insurance Pending"}]}}]}}';
            System.assertEquals(responseExpected, membershipResponse,'SUCCESS');
        } catch(Exception ex){
           // System.assertEquals(ex.getMessage(),'Script-thrown exception','ex');
        }
    }
    
    @isTest
    public static void getAPDPendingRequestTest(){
                Opportunity opgd1 = new Opportunity();
                opgd1.StageName = 'Qualification';
                opgd1.CloseDate = Date.newInstance(2021, 1, 11);
                opgd1.Name = 'testone';
                insert opgd1;
                
                Applicant__c apgd1 = new Applicant__c();
                apgd1.Opportunity__c = opgd1.Id;
                apgd1.Contact_number__c = '9743514830';
                apgd1.Applicant_Type__c = 'Borrower';
                insert apgd1;
        
                Test.startTest();
                try{
                    IND_APDPendingService.getAPDPendingRequest(apgd1,opgd1.Id);
                }catch(Exception ex){
                  //  System.assertEquals(ex.getMessage(),'Maker Id Error');
                }
                    
                Test.stopTest();
                
    } 
    
}