@isTest(SeeAllData=false)
public class DSA_CIBILService_Test {

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
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            Account acc = TestDataUtility.createTestAccount(false);
            if (Schema.sObjectType.Account.isCreateable()){
                insert acc;
            }
            Applicant__c applicant = TestDataUtility.createTestApplicant(false);
            applicant.Opportunity__c=opp.Id;
            applicant.Account__c = acc.id;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert applicant;
            }


                Documents__c document1 = TestDataUtility.createTestPPDocsForInternalDedupe(false,applicant,opp);
            if (Schema.sObjectType.Documents__c.isCreateable()){
                insert document1;
            }

            Documents__c document2 = TestDataUtility.createTestAadhaarDocs(false,applicant,opp);
            if (Schema.sObjectType.Documents__c.isCreateable()){
                insert document2;
            }

            Documents__c document4 = TestDataUtility.createTestPanDocsForInternalDedupe(false,applicant,opp);
            if (Schema.sObjectType.Documents__c.isCreateable()){
                insert document4;
            }

            CIBIL_Details__c cibilDetail = TestDataUtility.createCIBILDetails(false,applicant);
            if (Schema.sObjectType.CIBIL_Details__c.isCreateable()){
                insert cibilDetail;
            }
        }
    }

    @isTest
    public static void testCIBILService(){
        // try {
            User u = [SELECT Id,usertype FROM User WHERE UserName='standarduser4@testorg.com.psdev1' AND IsActive = true LIMIT 1];
            Applicant__c applicant = [SELECT Id, Opportunity__c FROM Applicant__c LIMIT 1];
            system.runAs(u) {
                String cibilCallOutRequest = '{"applicantId":"'+applicant.Id+'"}';
                Continuation con = (Continuation)DSA_IntegrationEngine.doCIBILReportCallout(cibilCallOutRequest);
                HttpResponse response = new HttpResponse();
                response.setBody('{"JData":"QDKv+/rEIFMCQ7gqewFK52+UKf4pYoJmwObxt35m1IQzKaTDw13zkGnHypLuBpBhQWshsxWlvs1eTa21PpWyr+8xtFhWuZOiQhbzHn2D+2AHGha7tMqEyxvYub314A7b"}');
                response.setStatusCode(200);
                String continuationLabel = DSA_IntegrationEngine.continuationLabel;
                List<String> labels = new List<String>{continuationLabel};
                Object continuationState= DSA_IntegrationEngine.continuationState;
                Test.startTest();
                Test.setContinuationResponse(continuationLabel, response);
                String externalCallOutResponse=(String)DSA_IntegrationEngine.processCIBILReportResponse(labels, DSA_IntegrationEngine.continuationState);
                Test.stopTest();
                String responseActual ='{"body":null,"Data":null}';
                System.assertEquals(responseActual,externalCallOutResponse);
            }
        // } catch(Exception ex) {
        //     //System.assertEquals(ex.getMessage(),'User id is required.');
        // }
    }
}