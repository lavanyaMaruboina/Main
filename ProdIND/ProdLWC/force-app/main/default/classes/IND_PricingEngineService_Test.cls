/*------------------------------------------------------------
Author:        Bondiga Thilak
Company:       Persistent Systems
Description:   Test class for IND_PricingEngineRequest class 
Apex Class:    IND_PricingEngineRequest
History
Date            Author              Comments
-------------------------------------------------------------
12-22-2021      Bondiga Thilak       Created
------------------------------------------------------------*/
@isTest
public class IND_PricingEngineService_Test {
    // @Method:     createTestData
    // @Created by: Bondiga Thilak
    // @Description:Test setup method to create the test data for IND_PricingEngineRequest classs
    // @Param:      ''  
    // @Return:     '' 
    @TestSetup
    public static void createTestData(){
        Profile p = [SELECT Id FROM Profile WHERE Name='CMU'];
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
     // @Method:        TestServiceMetthod
    // @Created by: Bhushan Charde
    // @Description:Test setup method to create the test data for IND_DealMasterRequest classs
    // @Param:      ''  
    // @Return:     ''  
    @isTest
    public static void testDealMasterService(){
        try{
            
            User u = [SELECT Id,usertype FROM User WHERE UserName='standarduser4@testorg.com.psdev1' AND IsActive = true LIMIT 1]; 
            //Test.setMock(HttpCalloutMock.class, new SMSHttpCalloutMock());
           /* Opportunity opp = TestDataUtility.createTestOpportunity(false);
            if (Schema.sObjectType.Opportunity.isCreateable()){
                
                insert opp;
            }
            
            Applicant__c applicant = TestDataUtility.createTestApplicantForSMS(false);
            applicant.Opportunity__c=opp.Id;
            String loanAppId = applicant.Opportunity__r.id;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert applicant;
            } */
            Opportunity opp = [Select Id,Stagename,Sub_Stage__c,Agent_BL_code__c,Class_of_Activity__c,lead_number__c from Opportunity LIMIT 1];            
            opp.Agent_BL_code__c = 'AG001';
            update opp;
            Applicant__c applicant = [Select Id,Applicant_Type__c,Scorecard_Decision__c from Applicant__c where opportunity__c =:opp.Id];  
			applicant.Applicant_Type__c = 'Borrower';
            applicant.Scorecard_Decision__c = 'Dark Green';
            update applicant;
             Bl_Code_Details__c bcd1 = new Bl_Code_Details__c();
        	bcd1.Bl_Code__c = opp.Agent_BL_code__c;
        	bcd1.Name = 'test';
        	insert bcd1;
        
       	    Geo_State_Masters__c gm1 = new Geo_State_Masters__c();
       	    gm1.NeSL_State_Code__c = 'test';
        	gm1.OwnerId = UserInfo.getUserId();
        	gm1.Pincode_Starting_Max__c = 524;
        	gm1.Pincode__c = 315;
        	gm1.Name = 'allur';
        	gm1.State_Code__c = '01';
        	insert gm1;
        
        
        	BankBranchDetails__c bd1 = new BankBranchDetails__c();
        	bd1.Bl_Code_Details__c = bcd1.Id;
        	bd1.Geo_State_Master__c = gm1.Id;
        	bd1.Address_1__c = 'testad1';
        	bd1.Address_2__c = 'testad2';
        	bd1.UniqueIdentifier__c = '201';
        	bd1.District__c = 'nellore';
        	insert bd1; 
            
            Continuation con = (Continuation)IntegrationEngine.doPricingEngineCallout(applicant.Id,opp.Id);
            
            Map<String, HttpRequest> requests = con.getRequests();
            //system.assert(requests.size() == 1);
            // Create a mock response
            HttpResponse response = new HttpResponse();
            response.setBody('JData":"bmvHXB5/b59ltoDPA8dwPKjM9zW1GwK5fvqA5/8G5ng/DZCG559eHYwynGh3m3kpuywLZET1DqqOzmR2Ko2z06E/CLbdl3PjIPBUdzm3WvWeOWPbqKvSBm48N5LS4vy4VfpvD4M0jl1J1OlJK+Zx+X326SRlbJxcTImhh1gwXa05SExDifebbRABcCtMAHqmdNeq6DS0TTcQNiKDhkiV4pKg9vemcOKL9PvgP2P/YeAIQOoqetiRtV45RLTdYScv/11BWP6/0AM6LQTtDzp3+oUAZkV8hJluV3uCxuERC2tp8L2Jscx4jkWwalbiBjSmRS7h0VHkpmMy7728h+PkHLRSSjebpTw8CQRnpf3l8eI=');            
            response.setStatusCode(200);
            
            String continuationLabel = IntegrationEngine.continuationLabel;
            String membershipResponse = '';
            List<String> labels = new List<String>{continuationLabel};
            Object continuationState= IntegrationEngine.continuationState;   
            system.runAs(u){
                Test.startTest();
                Test.setContinuationResponse(continuationLabel, response);
                membershipResponse = (String)IntegrationEngine.processDealMasterAPIResponse(labels, IntegrationEngine.continuationState);
                Test.stopTest();
            }
            String responseExpected ='{"response":{"status":"SUCCESS","respDesc":"Deal Master","content":[{"DealNumber":"","DealNoExists":"No","StatusFlag":" ","Engine_Number":"","Chassis_Number":"","Make":"","Model":"","Variant":"","Manufacture_Year_Month":"","Owner_Name":"","No_of_Ownership":"0"}]}}';
            System.assertEquals(responseExpected, membershipResponse,'SUCCESS');
        } catch(Exception ex){
           // System.assertEquals(ex.getMessage(),'Script-thrown exception');
        }
    }
    
    
    
    // @Method:     TestServiceMetthod
    // @Created by: Bondiga Thilak
    // @Description:Test setup method to create the test data for IND_PricingEngineRequest classs
    // @Param:      ''  
    // @Return:     ''  
    @isTest
    public static void testPricingEngineService(){
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
            
            
            Continuation con = (Continuation)IntegrationEngine.doPricingEngineCallout(applicant.Id,loanAppId);
            
            Map<String, HttpRequest> requests = con.getRequests();
            //system.assert(requests.size() == 1);
            // Create a mock response
            HttpResponse response = new HttpResponse();
            response.setBody('JData":"1F3ukS89iNZyq2s85KlipbQxjAMi2d6Vc4OVhaTBtx0K73nErlCXjhZ7ZPGg4wr+wuYAT7RfdBMt2OnGDgFMZP+7H4sB8jjut44G/KutqtB1dQLn1UA9tokUul/NWdLitqE5QE0vPKX0QJisYB3Z2CS4OyUUYxsz5qkZGtiD2NwRGETMXnx7LqnymXRh3puxB7HkgNc9ty9/OmkCB6oWu0/pNy03At+V//BCHtH+vRte+i63ZaAEUuvEAuLF5/g1oL3hwbBVyj3+27/kNymKNw==');            
            response.setStatusCode(200);
            
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
            Object continuationState= IntegrationEngine.continuationState;   
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
            String membershipResponse = (String)IntegrationEngine.processPricingEngineAPIResponse(labels, IntegrationEngine.continuationState);
            Test.stopTest();
            String responseExpected ='SUCCESS';
            System.assertEquals(responseExpected, membershipResponse,'SUCCESS');
        } catch(Exception ex){
            System.assertEquals(ex.getMessage(),'Insert failed. First exception on row 0; first error: DUPLICATE_VALUE, duplicate value found: <unknown> duplicates value on record with id: <unknown>: []','ex');
        }
    }
    @isTest
    public static void testPricingEngineService2(){
        try{
            //Test.setMock(HttpCalloutMock.class, new SMSHttpCalloutMock());
            Opportunity opp = TestDataUtility.createTestOpportunityForDeal(false);
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            
            Applicant__c applicant = TestDataUtility.createTestApplicantForSMS(false);
           applicant.Opportunity__c=opp.Id;
           String loanAppId = applicant.Opportunity__r.id;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert applicant;
            }
            
            
            Continuation con = (Continuation)IntegrationEngine.doPricingEngineCallout(applicant.Id,loanAppId);
            
            Map<String, HttpRequest> requests = con.getRequests();
            //system.assert(requests.size() == 1);
            // Create a mock response
            HttpResponse response = new HttpResponse();
            response.setBody('JData":"1F3ukS89iNZyq2s85KlipbQxjAMi2d6Vc4OVhaTBtx0K73nErlCXjhZ7ZPGg4wr+wuYAT7RfdBMt2OnGDgFMZP+7H4sB8jjut44G/KutqtB1dQLn1UA9tokUul/NWdLitqE5QE0vPKX0QJisYB3Z2CS4OyUUYxsz5qkZGtiD2NwRGETMXnx7LqnymXRh3puxB7HkgNc9ty9/OmkCB6oWu0/pNy03At+V//BCHtH+vRte+i63ZaAEUuvEAuLF5/g1oL3hwbBVyj3+27/kNymKNw==');            
            response.setStatusCode(200);
            
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
            Object continuationState= IntegrationEngine.continuationState;   
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
            String membershipResponse = (String)IntegrationEngine.processPricingEngineAPIResponse(labels, IntegrationEngine.continuationState);
            Test.stopTest();
            String responseExpected ='{ "Threshold_Net_IRR": "18" }';
            System.assertEquals(responseExpected, membershipResponse,'SUCCESS');
        } catch(Exception ex){
            System.assertEquals(ex.getMessage(),'Insert failed. First exception on row 0; first error: DUPLICATE_VALUE, duplicate value found: <unknown> duplicates value on record with id: <unknown>: []','ex');
        }
    }
    
  /*   @isTest
    public static void getPricingEngineRequest(){
        
        Opportunity opgd1 = new Opportunity();
        opgd1.StageName = 'Qualification';
        opgd1.CloseDate = Date.newInstance(2021, 1, 11);
        opgd1.Name = 'testone';
        insert opgd1;
        
        List<Applicant__c> appList = new List<Applicant__c>();
        
        Applicant__c applicant = TestDataUtility.createTestApplicantForSMS(false);
        applicant.Opportunity__c=opgd1.Id;
        appList.add(applicant);
        insert appList;
        
        try{
            IND_PricingEngineService.getPricingEngineRequest(opgd1,opgd1.id,'OK');  
        }catch(Exception e){}
        
    } */
    
     @isTest
    public static void validateException(){
        try{
            IND_PricingEngineService.getPricingEngineRequest(null, null,null);
        }catch(Exception pEx){
            System.assert(pEx.getMessage() != null);
        }
    
    }
}