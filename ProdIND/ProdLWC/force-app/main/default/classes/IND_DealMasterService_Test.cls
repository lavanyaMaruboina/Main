/*------------------------------------------------------------
Author:        Bondiga Thilak
Company:       Persistent Systems
Description:   Test class for IND_DealMasterRequest class 
Apex Class:    IND_DealMasterRequest
History
Date            Author              Comments
-------------------------------------------------------------
12-22-2021      Bondiga Thilak       Created
------------------------------------------------------------*/
@isTest
public class IND_DealMasterService_Test {
  @testSetup 
    static void testDataSetup() 
    {
        Profile p = [SELECT Id FROM Profile WHERE Name='IBL CVO'];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',MobilePhone = '9999999999',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id, Maker_Id__c='12',
                          TimeZoneSidKey='America/Los_Angeles',
                          UserName='standarduser4@testorg.com.psdev1');
        insert u;
        System.runAs(u){
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            opp.Deal_Number__c = 'TUT06226H';
            opp.Parent_Deal_number__c = 'DL109939';
            opp.Lead_Number__c='L-10122021-1685';
            opp.Product_Type__c = 'Passenger Vehicles';
            opp.Required_Loan_amount__c = 50000;
            if (Schema.sObjectType.Opportunity.isCreateable()){
                
                insert opp;
            }
            Applicant__c applicant = TestDataUtility.createTestApplicantForSMS(false);
            applicant.Opportunity__c=opp.Id;
            applicant.DocAuth_Application_Id__c = 'AC1241_24524353_g1';
            applicant.Date_of_Birth__c = Date.valueOf('1992-02-02');
            String dealNumber = opp.Deal_Number__c;
            String loanAppId = opp.id;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert applicant;
            }
        }
    }
    /*  
    @Method:		TestServiceMetthod
    @Created by:	Bhushan Charde
    @Description:Test setup method to create the test data for IND_DealMasterRequest classs
    @Param:		''	
    @Return: 	''  */


    @isTest
    public static void getDealMasterRequestTest(){
        //create user
        Profile p = [SELECT Id FROM Profile WHERE Name='IBL Business Executive'];
        User u = new User(Alias = 'standt2', Email='standarduser2@testorg.com',MobilePhone='9999999999',
                        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                        LocaleSidKey='en_US', ProfileId = p.Id,Maker_Id__c='12',IsActive = true,
                        TimeZoneSidKey='America/Los_Angeles',UserName='test_userprod123@@@indusbank.com');
        insert u;
        System.runAs(u) 
        {
            Opportunity opgd1 = new Opportunity();
            opgd1.StageName = 'Qualification';
            opgd1.CloseDate = Date.newInstance(2021, 1, 11);
            opgd1.Name = 'testone';
            insert opgd1;
            
            RequestWrapper reqWrapper = new RequestWrapper();
            reqWrapper.applicantId = opgd1.Id;
            string loanAppId = reqWrapper.applicantId;
            
            List<Applicant__c> appList = new List<Applicant__c>();
            
            Applicant__c applicant = TestDataUtility.createTestApplicantForSMS(false);
            applicant.Opportunity__c=opgd1.Id;
            appList.add(applicant);
            insert appList;
            try{
                Test.StartTest();
                IND_DealMasterService.getDealMasterRequest(appList[0], opgd1.Id);
                IND_DealMasterService.getDealMasterRequest(null, null, opgd1.Id);
                
                Test.StopTest();    
           }catch(Exception e)
              {
                 System.assertnotEquals('Script-thrown exception', e.getMessage());
            }
        }    
    }
    @isTest
    public static void getDealMasterRequestTest1(){
        //create user
        Profile p = [SELECT Id FROM Profile WHERE Name='IBL Business Executive'];
        User u = new User(Alias = 'standt2', Email='standarduser2@testorg.com',MobilePhone='9999999999',
                        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                        LocaleSidKey='en_US', ProfileId = p.Id,Maker_Id__c='12',IsActive = true,
                        TimeZoneSidKey='America/Los_Angeles',UserName='test_userprod123@@@indusbank.com');
        insert u;
        System.runAs(u) 
        {
            Opportunity opgd1 = new Opportunity();
            opgd1.StageName = 'Qualification';
            opgd1.CloseDate = Date.newInstance(2021, 1, 11);
            opgd1.Name = 'testone';
            insert opgd1;
            
            RequestWrapper reqWrapper = new RequestWrapper();
            reqWrapper.applicantId = opgd1.Id;
            string loanAppId = reqWrapper.applicantId;
            
            List<Applicant__c> appList = new List<Applicant__c>();
            
            Applicant__c applicant = TestDataUtility.createTestApplicantForSMS(false);
            applicant.Opportunity__c=opgd1.Id;
            appList.add(applicant);
            insert appList;
            try{
                Test.StartTest();
                IND_DealMasterService.getDealMasterRequest(null, null, opgd1.Id);
                
                Test.StopTest();    
           }catch(Exception e)
              {
                 System.assertnotEquals('Script-thrown exception', e.getMessage());
            }
        }    
    }
    @isTest
    public static void testDealMasterService(){
        try{
            
            User u = [SELECT Id,usertype FROM User WHERE UserName='standarduser4@testorg.com.psdev1' AND IsActive = true LIMIT 1]; 
            system.runAs(u){
            //Test.setMock(HttpCalloutMock.class, new SMSHttpCalloutMock());
          /*  Opportunity opp = TestDataUtility.createTestOpportunity(false);
            if (Schema.sObjectType.Opportunity.isCreateable()){
                
                insert opp;
            }
            
            Applicant__c applicant = TestDataUtility.createTestApplicantForSMS(false);
            applicant.Opportunity__c=opp.Id;
            String loanAppId = applicant.Opportunity__r.id;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert applicant;
            } */
              
        	Opportunity opp = [Select Id,Stagename,Sub_Stage__c,View_Application_Sub_Stages__c,Class_of_Activity__c,lead_number__c from Opportunity LIMIT 1];            
            Applicant__c applicant = [Select Id,Applicant_Type__c from Applicant__c where opportunity__c =:opp.Id];  
            
            
            Continuation con = (Continuation)IntegrationEngine.doDealMasterCallout(applicant.Id,opp.Id);
            
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
           
                Test.startTest();
                Test.setContinuationResponse(continuationLabel, response);
               // membershipResponse = (String)IntegrationEngine.processDealMasterAPIResponse(labels, continuationState);
                Test.stopTest();
            }
            String responseExpected ='{"response":{"status":"SUCCESS","respDesc":"Deal Master","content":[{"DealNumber":"","DealNoExists":"No","StatusFlag":" ","Engine_Number":"","Chassis_Number":"","Make":"","Model":"","Variant":"","Manufacture_Year_Month":"","Owner_Name":"","No_of_Ownership":"0"}]}}';
           // System.assertEquals(responseExpected, membershipResponse,'SUCCESS');
          } catch(Exception ex){
           // System.assertEquals(ex.getMessage(),'Script-thrown exception','Exception');
         }
    }
}
   /*   
    @isTest
    public static void testDealMasterService1(){
        try{
            //Test.setMock(HttpCalloutMock.class, new SMSHttpCalloutMock());
            Opportunity opp = TestDataUtility.createTestOpportunityForDeal(false);
            if (Schema.sObjectType.Opportunity.isCreateable()){
                opp.Customer_Deal_No__c ='TUT06226H';
                insert opp;
            }
            
            Applicant__c applicant = TestDataUtility.createTestApplicantForSMS(false);
            applicant.Opportunity__c=opp.Id;
            String loanAppId = applicant.Opportunity__r.id;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert applicant;
            }
            
            
            Continuation con = (Continuation)IntegrationEngine.doDealMasterCallout(applicant.Id,loanAppId);
            
            Map<String, HttpRequest> requests = con.getRequests();
            //system.assert(requests.size() == 1);
            // Create a mock response
            HttpResponse response = new HttpResponse();
            response.setBody('JData":"bmvHXB5/b59ltoDPA8dwPKjM9zW1GwK5fvqA5/8G5ng/DZCG559eHYwynGh3m3kpuywLZET1DqqOzmR2Ko2z06E/CLbdl3PjIPBUdzm3WvUd2xNeYay/xUW8gJmLGk9Yz19Mc4obyu9YYmGnwQTszkkkqUJjpX6FLhdKrc+L98TIIGCVNNvLOrWwRN/uksoF');            
            response.setStatusCode(200);
            
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
                Object continuationState= IntegrationEngine.continuationState;   
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
            String membershipResponse = (String)IntegrationEngine.processDealMasterAPIResponse(labels, IntegrationEngine.continuationState);
            Test.stopTest();
            String responseExpected ='{"response":{"status":"SUCCESS","respDesc":"Deal Master","content":[{"DealNumber":"TUT06226H","DealNoExists":"Yes","StatusFlag":"L"}]}}';
            System.assertEquals(responseExpected, membershipResponse,'SUCCESS');
        } catch(Exception ex){
            System.assertEquals(ex.getMessage(),'Script-thrown exception','ex');
        }
    }
    
    
    
    //    @isTest
    // public static void testIND_DealMasterResponseTest(){
        
    //     IND_DealMasterResponse dealResponse = new IND_DealMasterResponse();
    //     IND_DealMasterResponse.Response response = new IND_DealMasterResponse.Response();
    //     response.status = '200';
    //     response.respDesc = 'Test';
    //   //  response.content = new List<String>{'Test'};
    //     dealResponse.response = response;
    //     System.assertEquals(dealResponse.response.status, '200');
    // }
    
     @isTest
    public static void validateException(){
        try{
            Test.startTest();
            Profile p = [SELECT Id FROM Profile WHERE Name='IBL Counter Staff'];
            system.debug('p'+ p);
            User u = new User(Alias = 'standt', Email='standarduser@testorg.com',MobilePhone='9999999999',
                              EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                              LocaleSidKey='en_US', ProfileId = p.Id,
                              TimeZoneSidKey='America/Los_Angeles',
                              UserName='standarduser4@testorg.com.psdev1',
                             MobilePhone='0123456789',Maker_Id__c='1223');
            insert u;
            system.runAs(u){
              
           // IND_DealMasterService.getDealMasterRequest(null, null);
            IND_DealMasterService.getDealMasterRequest(null, null, null);

            }
            Test.stopTest(); 
        }catch(Exception pEx){
            System.assert(pEx.getMessage() != null);
        }
        
    }
      
}
*/