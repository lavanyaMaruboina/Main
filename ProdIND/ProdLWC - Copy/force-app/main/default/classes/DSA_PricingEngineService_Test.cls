@isTest
public class DSA_PricingEngineService_Test {

    // @Method:     createTestData
    // @Created by: Bondiga Thilak
    // @Description:Test setup method to create the test data for IND_PricingEngineRequest classs
    // @Param:      ''
    // @Return:     ''
    @TestSetup
    public static void createTestData(){
        Profile p = [SELECT Id FROM Profile WHERE Name='IBL CVO'];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',MobilePhone = '9999999999',
                        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                        LocaleSidKey='en_US', ProfileId = p.Id, Maker_Id__c='12',User_Id__c = '29927_MO',
                        TimeZoneSidKey='America/Los_Angeles',
                        UserName='standarduser4@testorg.com.psdev1');
        insert u;
        System.runAs(u) {
            Opportunity opp = TestDataUtility.createTestOpportunityForLTV(false);
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            Applicant__c applicant = TestDataUtility.createTestApplicantForLTV(false);
            applicant.Opportunity__c=opp.Id;
            String loanAppId = applicant.Opportunity__r.id;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert applicant;
            }
            Profile_Master__c profileMaster = new Profile_Master__c(Name = 'Profile Master', Code__c = 'abcd1234abcd123', Category__c = 'test');
            insert profileMaster;
            insert new Income_Details__c(Name= 'Test',Applicant__c = applicant.Id, Income__c =1000000, Profile__c= profileMaster.Id);

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
            Vehicle_Detail__c vd = TestDataUtility.createTestVehicleDetailForLTV(true, opp);
            insert new Product2(name = vd.Model__c, asset_category__c = 'C', External_Reference_Id__c = 'Model-P007-test', Type__c = 'Model');
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
            User u = [SELECT Id,usertype FROM User WHERE UserName='standarduser4@testorg.com.psdev1' AND IsActive = true LIMIT 1];
            Applicant__c applicant = [SELECT Id, Opportunity__c FROM Applicant__c LIMIT 1];
            String loanAppId = applicant.Opportunity__c;
            system.runAs(u){
            //Test.setMock(HttpCalloutMock.class, new SMSHttpCalloutMock());
            Continuation con = (Continuation)DSA_IntegrationEngine.doPricingEngineCallout(applicant.Id,loanAppId);
                

            Map<String, HttpRequest> requests = con.getRequests();
            //system.assert(requests.size() == 1);
            // Create a mock response
            HttpResponse response = new HttpResponse();
            response.setBody('{"JData":"1F3ukS89iNZyq2s85KlipSRpTQ+5rfJ61qE6HROQS/5HLbX9arEI+HX/1kySUpX3ym7jvtKBLUUWz+zQaCGr73R0xXfz+tXg1bXs1Ovf7QEfKFCA2T0oVeLkj+M0YAMXTRMo9lJo7cleRDCsPEmP8w7LovsFi6sV5rU6YBW1rtmq0f1l25rXuEw1IKxYK+KwwU1kokJxtJKC51hWSa8EJeZVAlDssup+y5eF0gWZrN5GPKx3FLYKF8K4qoNcon7VCKzdioytdv3a0+dftehOW8ORlNlG1gfivkH8uctv5Ng8oQWltuJJEkRuy8iGPd7g"}');
            response.setStatusCode(200);

            String continuationLabel = DSA_IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
            Object continuationState= DSA_IntegrationEngine.continuationState;
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
            String membershipResponse = (String)DSA_IntegrationEngine.processPricingEngineAPIResponse(labels, DSA_IntegrationEngine.continuationState);
            Test.stopTest();
            String responseExpected ='{"body":null,"application":null}';
            System.assertEquals(responseExpected, membershipResponse,'SUCCESS');
            }
        } catch(Exception ex){
            System.assertEquals(ex.getMessage(),'Insert failed. First exception on row 0; first error: DUPLICATE_VALUE, duplicate value found: <unknown> duplicates value on record with id: <unknown>: []','ex');
        }
    }
    
    
    @isTest
    public static void testPricingEngineServiceNew(){
        try{
            User u = [SELECT Id,usertype FROM User WHERE UserName='standarduser4@testorg.com.psdev1' AND IsActive = true LIMIT 1];
            Applicant__c applicant = [SELECT Id, Opportunity__c FROM Applicant__c LIMIT 1];
            applicant.Scorecard_Decision__c='Light Green';
            
            update applicant;
            String loanAppId = applicant.Opportunity__c;
            
            system.runAs(u){
                Continuation con = (Continuation)DSA_IntegrationEngine.doPricingEngineCallout(applicant.Id,loanAppId);
                
                applicant.Scorecard_Decision__c='Dark Green';
                update applicant;
                Continuation con0 = (Continuation)DSA_IntegrationEngine.doPricingEngineCallout(applicant.Id,loanAppId);
                
                applicant.Scorecard_Decision__c='Yellow';
                update applicant;
                Continuation con1 = (Continuation)DSA_IntegrationEngine.doPricingEngineCallout(applicant.Id,loanAppId);
                
                applicant.Scorecard_Decision__c='Orange';
                update applicant;
                Continuation con2 = (Continuation)DSA_IntegrationEngine.doPricingEngineCallout(applicant.Id,loanAppId);
                
                applicant.Scorecard_Decision__c='Red';
                update applicant;
                Continuation con3 = (Continuation)DSA_IntegrationEngine.doPricingEngineCallout(applicant.Id,loanAppId);
               
               /* applicant.Scorecard_Decision__c='';
                update applicant;
                Continuation con4 = (Continuation)DSA_IntegrationEngine.doPricingEngineCallout(applicant.Id,loanAppId);
               */
            }
         } catch(Exception ex){
            System.assertEquals(ex.getMessage(),'Insert failed. First exception on row 0; first error: DUPLICATE_VALUE, duplicate value found: <unknown> duplicates value on record with id: <unknown>: []','ex');
          }
    }
  /*  
     @isTest
    public static void testPricingEngineServiceNew1(){
       
            User u = [SELECT Id,usertype FROM User WHERE UserName='standarduser4@testorg.com.psdev1' AND IsActive = true LIMIT 1];
            Applicant__c applicant = [SELECT Id, Opportunity__c FROM Applicant__c LIMIT 1];
            applicant.Scorecard_Decision__c='Blue';
           update applicant;
            String loanAppId = applicant.Opportunity__c;
            
            system.runAs(u){
            Continuation con = (Continuation)DSA_IntegrationEngine.doPricingEngineCallout(applicant.Id,loanAppId);
            }
    }
    
  */  
    @isTest
    public static void testPricingEngineService2(){
        try{
            //Test.setMock(HttpCalloutMock.class, new SMSHttpCalloutMock());
            User u = [SELECT Id,usertype FROM User WHERE UserName='standarduser4@testorg.com.psdev1' AND IsActive = true LIMIT 1];
            Applicant__c applicant = [SELECT Id, Opportunity__c FROM Applicant__c LIMIT 1];
            String loanAppId = applicant.Opportunity__c;
            system.runAs(u){


            Continuation con = (Continuation)DSA_IntegrationEngine.doPricingEngineCallout(applicant.Id,loanAppId);

            Map<String, HttpRequest> requests = con.getRequests();
            //system.assert(requests.size() == 1);
            // Create a mock response
            HttpResponse response = new HttpResponse();
            response.setBody('{"JData":"1F3ukS89iNZyq2s85KlipSRpTQ+5rfJ61qE6HROQS/5HLbX9arEI+HX/1kySUpX3ym7jvtKBLUUWz+zQaCGr73R0xXfz+tXg1bXs1Ovf7QEfKFCA2T0oVeLkj+M0YAMXTRMo9lJo7cleRDCsPEmP8w7LovsFi6sV5rU6YBW1rtmq0f1l25rXuEw1IKxYK+KwwU1kokJxtJKC51hWSa8EJeZVAlDssup+y5eF0gWZrN5GPKx3FLYKF8K4qoNcon7VCKzdioytdv3a0+dftehOW8ORlNlG1gfivkH8uctv5Ng8oQWltuJJEkRuy8iGPd7g"}');
            response.setStatusCode(200);

            String continuationLabel = DSA_IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
            Object continuationState= DSA_IntegrationEngine.continuationState;
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
            String membershipResponse = (String)DSA_IntegrationEngine.processPricingEngineAPIResponse(labels, DSA_IntegrationEngine.continuationState);
            Test.stopTest();
            String responseExpected ='{"body":null,"application":null}';
            System.assertEquals(responseExpected, membershipResponse,'SUCCESS');
            }
        } catch(Exception ex){
            System.assertEquals(ex.getMessage(),'Insert failed. First exception on row 0; first error: DUPLICATE_VALUE, duplicate value found: <unknown> duplicates value on record with id: <unknown>: []','ex');
        }
    }
    
    @isTest
    public static void testPricingEngineServiceforRiskBand02(){
        try{
            //Test.setMock(HttpCalloutMock.class, new SMSHttpCalloutMock());
            User u = [SELECT Id,usertype FROM User WHERE UserName='standarduser4@testorg.com.psdev1' AND IsActive = true LIMIT 1];
            Applicant__c applicant = [SELECT Id, Opportunity__c FROM Applicant__c LIMIT 1];
            String loanAppId = applicant.Opportunity__c;
            system.runAs(u){


            Continuation con = (Continuation)DSA_IntegrationEngine.doPricingEngineCallout(applicant.Id,loanAppId);

            Map<String, HttpRequest> requests = con.getRequests();
            //system.assert(requests.size() == 1);

            HttpResponse response = new HttpResponse();
            response.setBody('{"JData":"1F3ukS89iNZyq2s85KlipSRpTQ+5rfJ61qE6HROQS/5HLbX9arEI+HX/1kySUpX3ym7jvtKBLUUWz+zQaCGr73R0xXfz+tXg1bXs1Ovf7QEfKFCA2T0oVeLkj+M0YAMXTRMo9lJo7cleRDCsPEmP8w7LovsFi6sV5rU6YBW1rtmq0f1l25rXuEw1IKxYK+KwwU1kokJxtJKC51hWSa8EJeZVAlDssup+y5eF0gWZrN5GPKx3FLYKF8K4qoNcon7VCKzdioytdv3a0+dftehOW8ORlNlG1gfivkH8uctv5Ng8oQWltuJJEkRuy8iGPd7g"}');
            response.setStatusCode(200);

            String continuationLabel = DSA_IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
            Object continuationState= DSA_IntegrationEngine.continuationState;
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
            String membershipResponse = (String)DSA_IntegrationEngine.processPricingEngineAPIResponse(labels, DSA_IntegrationEngine.continuationState);
            Test.stopTest();
            String responseExpected ='{"body":null,"application":null}';
            System.assertEquals(responseExpected, membershipResponse,'SUCCESS');
            }
        } catch(Exception ex){
            System.assertEquals(ex.getMessage(),'Insert failed. First exception on row 0; first error: DUPLICATE_VALUE, duplicate value found: <unknown> duplicates value on record with id: <unknown>: []','ex');
        }
    }

    @isTest
    public static void validateException(){
        try{
            IND_PricingEngineServiceDSA.getPricingEngineRequest(null, null,null);
        }catch(Exception pEx){
            System.assert(pEx.getMessage() != null);
        }

    }
}