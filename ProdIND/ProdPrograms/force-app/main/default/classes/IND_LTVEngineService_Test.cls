/*------------------------------------------------------------
Author:        Bondiga Thilak
Company:       Persistent Systems
Description:   Test class for IND_LTVEngineRequest class 
Apex Class:    IND_LTVEngineRequest
History
Date            Author              Comments
-------------------------------------------------------------
12-22-2021      Bondiga Thilak       Created
------------------------------------------------------------*/
@isTest(SeeAllData=false)
public class IND_LTVEngineService_Test {
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
    // @Method:		TestServiceMetthod
    // @Created by:	Bondiga Thilak
    // @Description:Test setup method to create the test data for IND_LTVEngineRequest classs
    // @Param:		''	
    // @Return: 	''  
    @isTest
    public static void testLTVEngineService(){
        try{
           Opportunity opp = [Select Id,Stagename,Sub_Stage__c,Agent_BL_code__c,Class_of_Activity__c,lead_number__c from Opportunity LIMIT 1];            
            opp.Agent_BL_code__c = 'AG001';
            update opp;
            Applicant__c applicant = [Select Id,Applicant_Type__c,Scorecard_Decision__c from Applicant__c where opportunity__c =:opp.Id]; 
            applicant.Applicant_Type__c = 'Borrower';
            applicant.Who_will_repay_the_loan__c = 'Borrower';
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
            Vehicle_Detail__c  vehicleDetail1 = TestDataUtility.createTestVehicleDetailForIbb(false, opp);
            vehicleDetail1.Vehicle_Type__c = 'New';
            vehicleDetail1.Variant_Code__c = 'TEICH364TR';
            vehicleDetail1.Vehicle_SubType__c = 'Tractor';
            vehicleDetail1.Variant__c = 'EICHER 364DI 35HP';
            vehicleDetail1.Model_Code__c = 'EICHER';
            insert vehicleDetail1;
            Product2 prd1 = new Product2();
            prd1.Asset_Category__c = 'te';
            prd1.Capacity_1__c = 1000.00;
            prd1.Capacity_2__c = 2000.00;
            prd1.Capacity_Units_1__c = 'test12';
            prd1.Capacity_Units_2__c = 'test13';
            prd1.Type__c = 'Make';
            prd1.External_Reference_Id__c = '58568568';
            prd1.Name = 'book';
            prd1.Model_Code__c = vehicleDetail1.Model_Code__c;
            insert prd1;
            
            Continuation con = (Continuation)IntegrationEngine.doLTVEngineCallout(applicant.Id,opp.Id);
            
            Map<String, HttpRequest> requests = con.getRequests();
            //system.assert(requests.size() == 1);
            // Create a mock response
            HttpResponse response = new HttpResponse();
            //response.setBody('JData":"1F3ukS89iNZyq2s85KlipVyhUm4luUqOJ6t9i3fmdWU6H+3fm6YvLehkRqgGPwtcT32TgaHEdQhhtHWiR+nmZSGrQzt9OQupUS619MUr97+aMDATKsWr/4CUyxv03LzTYikBvSh9n9ArDF18RsOyccTx3tzp/M1m2GqLbiUwnMrUKnQ/BNNvpk45ryLWWx1h9VNGX1h1uh3/VEVILG65ql4WHaU4xuGcts9FUn+/PoDZHVimXOEZNJJIf7h9Ve1ZtP59RaWzRNU3tz7c9uKspAv/uUQi1jRZQjaZAz0H6tg="');            
            response.setBody('{"JData":"99QFoqV7jJWIuvZQUNcXiIdarVyQMFuJobBndcXvojg="}');
            response.setStatusCode(200);
            
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
            Object continuationState= IntegrationEngine.continuationState;  
            String membershipResponse = '';
            
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
            membershipResponse = (String)IntegrationEngine.processLTVEngineAPIResponse(labels, IntegrationEngine.continuationState);
            Test.stopTest();
            
            String responseExpected ='{  "LTV": "80"}';
            //System.assertEquals(responseExpected, membershipResponse,'SUCCESS');
            }
         catch(Exception ex){
           // System.assertEquals(ex.getMessage(),'Who will repay the loan field is required.');
        }
    } 
    
   
    @isTest
    public static void testLTVEngineService2(){
        
        try{   
             Profile p = [SELECT Id FROM Profile WHERE Name='CMU'];
            system.debug('p'+ p);
            User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                              EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                              LocaleSidKey='en_US', ProfileId = p.Id,
                              TimeZoneSidKey='America/Los_Angeles',
                              MobilePhone = '9701498575',
                              UserName='standarduser4@testorg.com.psdev1' ,
                              Maker_Id__c='100001');
            insert u;
            system.runAs(u){
            //Test.setMock(HttpCalloutMock.class, new PanVerificationHttpCalloutMock());
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            Applicant__c applicant = TestDataUtility.createTestApplicant(false);
            applicant.Opportunity__c=opp.Id;
            String loanAppId = applicant.Opportunity__r.id;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert applicant;
            }
            
            String ltvEngineRequest = '{"applicantId":"'+applicant.Id+'" ,"panNumber":"CSWPG3660G","firstName":"'+applicant.Customer_First_Name__c+'","lastName":"'+applicant.Customer_Last_Name__c+' "}';
            Continuation con = (Continuation)IntegrationEngine.doLTVEngineCallout(ltvEngineRequest, loanAppId);
            // Create a mock response
            HttpResponse response = new HttpResponse();
            response.setBody('{"JData":"bmvHXB5/b59ltoDPA8dwPKjM9zW1GwK5fvqA5/8G5njg6LzMAYI4Id6LrLJmRnoijeFuaYkwDnaZHsa+6xYit82GLmdlqwXm0BAn6A39s+8tEj1DO22pB2d+pdaaLuahdq9qhYsY6BgGXwQveaGe+qoE4LwKTSymv3ZxeE/r6N6i8Jj51Sf62N2i1LJhaAOKAIhf3hW/g9kO5MXzbWm4eZn7whfcMFdjvVr3NW4wI788aR9xGUvwj87yC5uQuaM5hKzMwKJJJKU0eR4sNzzTPForbed5aCwoRITFkUeQ/l8yNywULXNPSI8qTYEEyt5yW9tfbI6t+Vm48d8F807UycU2Kn4G+Z2DYm9yfuHn+NqlO3nRJnjgmcud83kQT+0j"}');
            response.setStatusCode(200);
            
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
                Object continuationState= IntegrationEngine.continuationState;
            String panCallOutResponse = '';
            
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
            panCallOutResponse= (String)IntegrationEngine.processLTVEngineAPIResponse(labels, IntegrationEngine.continuationState);
            Test.stopTest();
            
            String responseExpected ='{"body":null,"response":{"status":"SUCCESS","respDesc":"PAN Status verified Successfully","content":[{"NSDLReturnCdDesc":"Success","NSDLPANStatusDesc":"Existing and Valid PAN","NSDLPANStatus":"E","Name":"Shri GOURAB  GOSWAMI","IDNSDLNameMatch":100,"ID":"CSWPG3660G"}]}}';
            System.assertEquals(responseExpected, panCallOutResponse, 'SUCCESS');
            }
        } catch(Exception ex){
           // System.assertEquals(ex.getMessage(),'Who will repay the loan field is required.');
        }
    }  
    /*
    
      @isTest
    public static void testLTVEngineService3(){
        
        try{   
             Profile p = [SELECT Id FROM Profile WHERE Name='IBL Counter Staff'];
            system.debug('p'+ p);
            User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                              EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                              LocaleSidKey='en_US', ProfileId = p.Id,
                              TimeZoneSidKey='America/Los_Angeles',
                              MobilePhone = '9701498575',
                              UserName='standarduser4@testorg.com.psdev1',
                              Maker_Id__c='100001');
            insert u;
            //Test.setMock(HttpCalloutMock.class, new PanVerificationHttpCalloutMock());
            Opportunity opp = TestDataUtility.createTestOpportunityltv(false);
            
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            Applicant__c applicant = TestDataUtility.createTestApplicant(false);
            applicant.Opportunity__c=opp.Id;
            applicant.Customer_First_Name__c = '';
            String loanAppId = applicant.Opportunity__r.id;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert applicant;
            }
            
            
            
            Test.startTest();
            IND_LTVEngineService.getLTVEngineRequest(opp,applicant.id,'score','card');
            Test.stopTest();
            
           
        } catch(Exception ex){
            System.assertEquals(ex.getMessage(),'List has no rows for assignment to SObject', 'Exception');
        }
    } 
    

    */
    
    @isTest
    public static void testLTVEngineService4(){
        
         Opportunity opgd1 = new Opportunity();
        opgd1.StageName = 'Qualification';
        opgd1.CloseDate = Date.newInstance(2021, 1, 11);
        opgd1.Name = 'testone';
        opgd1.Product_Type__c = 'Two Wheeler';
        opgd1.Vehicle_Type__c = 'New';
        opgd1.Agent_BL_code__c = 'AG-00';
        insert opgd1;
        
        List<Applicant__c> appList = new List<Applicant__c>();
        Applicant__c applicant = TestDataUtility.createTestApplicantForSMS(false);
        applicant.Opportunity__c = opgd1.Id;
        applicant.Applicant_Type__c  = 'Borrower';
        applicant.Scorecard_Decision__c = 'Red';
        applicant.Contact_number__c = '9898989898';
        applicant.Gender__c = 'MALE';
        applicant.Marital_status__c = 'UNMAR';
        applicant.Residence_country__c = 'India';
        appList.add(applicant);
        insert appList;
        applicant.Opportunity__r = opgd1;  
        
        RequestWrapper reqWrapper = new RequestWrapper();
        reqWrapper.applicantId = applicant.Id;
        reqWrapper.coBorrowerPresentAddress = 'test';
        reqWrapper.coBorrowerNIP = 'dd';
        reqWrapper.subProduct = 'test';
        reqWrapper.scoreCardDecision = 'Red';
        reqWrapper.proposalBasedOn = String.valueOf(System.today().addDays(15));
        
        Bl_Code_Details__c bcd1 = new Bl_Code_Details__c();
        bcd1.Bl_Code__c = opgd1.Agent_BL_code__c;
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
        
        Profile_Master__c obj1 = new Profile_Master__c();
        obj1.code__c = '1';
        obj1.Category__c  = '121';
        obj1.Name='test';
        insert obj1;
        
        Income_Details__c incomeObj = new Income_Details__c();
        incomeObj.Applicant__c = applicant.id;
        incomeObj.Profile__c = obj1.Id;
        insert incomeObj;
        
        IND_LTVEngineRequest objResult = new IND_LTVEngineRequest(opgd1, reqWrapper);
       
        String errorMsg = '';
        try{
            reqWrapper.scoreCardDecision = null;
            objResult= IND_LTVEngineService.getLTVEngineRequest(opgd1, opgd1.Id, reqWrapper);
        }catch(Exception pEx){
            errorMsg =   pEx.getMessage();
        }
        System.assert(errorMsg.contains(System.Label.RiskBand));
        
    }
    
}