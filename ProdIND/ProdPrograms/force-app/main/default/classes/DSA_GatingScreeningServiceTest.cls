/*------------------------------------------------------------
Author:        Aman Mundhada
Company:       Persistent Systems
Description:  Test class created to validate the IND_GatingScreeningRequest IND_GatingScreeningService IND_GatingScreeningResponse class
History
Date            Author              Comments
-------------------------------------------------------------
22-12-2021      Aman Mundhada       Created
------------------------------------------------------------*/
@isTest(SeeAllData=false)
public class DSA_GatingScreeningServiceTest {

    @TestSetup
    static void testData() {
        Profile p = [SELECT Id FROM Profile WHERE Name='IBL CVO'];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',MobilePhone = '9999999999',
                        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                        LocaleSidKey='en_US', ProfileId = p.Id, Maker_Id__c='12',User_Id__c = '29927_MO',
                        TimeZoneSidKey='America/Los_Angeles',
                        UserName='standarduser4@testorg.com.psdev1');
        insert u;
        System.runAs(u) {
            Opportunity opp = TestDataUtility.createTestOpportunityforLTV(true);
            Applicant__c applicant = TestDataUtility.createTestApplicantForLTV(false);
            applicant.Opportunity__c=opp.Id;
            String loanAppId = applicant.Opportunity__r.id;
            insert applicant;
            Documents__c document = TestDataUtility.createTestPanDocs(false,applicant,opp);
            if (Schema.sObjectType.Documents__c.isCreateable()){
                insert document;
            }
            Applicant__c applicant1 = TestDataUtility.createTestApplicantForGatingScreeningCoborrower(false);
            applicant1.Opportunity__c=opp.Id;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert applicant1;
            }

            Customer_dedupe_response__c custDedupe = TestDataUtility.createCustomerDedupeResponse(false, applicant);
            if (Schema.sObjectType.Customer_dedupe_response__c.isCreateable()){
                insert custDedupe;
            }

             Customer_dedupe_response__c custDedupe1 = TestDataUtility.createCustomerDedupeResponse(false, applicant1);
            if (Schema.sObjectType.Customer_dedupe_response__c.isCreateable()){
                insert custDedupe1;
            }

              Documents__c document1 = TestDataUtility.createTestPanDocs(false,applicant1,opp);
            if (Schema.sObjectType.Documents__c.isCreateable()){
                insert document1;
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

    @isTest
    public static void testINDGatingScreeningService(){

        try{
            User u = [SELECT Id,usertype FROM User WHERE UserName='standarduser4@testorg.com.psdev1' AND IsActive = true LIMIT 1];
            Applicant__c applicant = [SELECT Id, Opportunity__c FROM Applicant__c LIMIT 1];
            String loanAppId = applicant.Opportunity__c;

            system.runAs(u) {
                String gatingScreeningCallOutRequest = '{"applicantId":"'+applicant.Id+'" ,"loanApplicationId":"'+loanAppId+'"}';
                Continuation con = (Continuation)DSA_IntegrationEngine.doGatingScreeningCheckEligibilityCallout(gatingScreeningCallOutRequest);
                HttpResponse response = new HttpResponse();
                response.setBody('{"JData":"QDKv+/rEIFMCQ7gqewFK52+UKf4pYoJmwObxt35m1IQzKaTDw13zkGnHypLuBpBhQWshsxWlvs1eTa21PpWyr+8xtFhWuZOiQhbzHn2D+2AHGha7tMqEyxvYub314A7b"}');
                response.setStatusCode(200);
                String continuationLabel = DSA_IntegrationEngine.continuationLabel;
                List<String> labels = new List<String>{continuationLabel};
                Object continuationState= DSA_IntegrationEngine.continuationState;
                String gatingScreeningCallOutResponse='';
                Test.startTest();
                Test.setContinuationResponse(continuationLabel, response);
                gatingScreeningCallOutResponse=(String)DSA_IntegrationEngine.processGatingScreeningCallOutResponse(labels, DSA_IntegrationEngine.continuationState);
                Test.stopTest();
                String responseExpected ='{"body":null,"application":null}';
                System.assertEquals(responseExpected,gatingScreeningCallOutResponse,'Success');
            }
        } catch(Exception ex){
            System.assertEquals(ex.getMessage(),'Script-thrown exception');
        }
    }

    @isTest
    public static void validateException(){
        try{
            IND_GatingScreeningServiceDSA.getGatingScreeningCallOutRequest(null);
        }catch(Exception pEx){
            System.assert(pEx.getMessage() != null);
        }

    }
}