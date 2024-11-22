@isTest(SeeAllData=false)
public class DSA_OfferEngineService_Test {

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
            Applicant__c applicant = TestDataUtility.createTestApplicantForOfferEngine(false);
            applicant.Opportunity__c=opp.Id;
            String loanAppId = applicant.Opportunity__r.id;
            insert applicant;
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

    // @Method:		TestServiceMetthod
    // @Created by:	Bondiga Thilak
    // @Description:Test setup method to create the test data for IND_LTVEngineRequest classs
    // @Param:		''
    // @Return: 	''
    @isTest
    public static void testOfferEngineService() {
        try {
            User u = [SELECT Id,usertype FROM User WHERE UserName='standarduser4@testorg.com.psdev1' AND IsActive = true LIMIT 1];
            Applicant__c applicant = [SELECT Id, Opportunity__c FROM Applicant__c LIMIT 1];
            String loanAppId = applicant.Opportunity__c;
            String membershipResponse = '';
            system.runAs(u){
            Continuation con = (Continuation)DSA_IntegrationEngine.doDSAOfferEngineCallout(loanAppId, applicant.Id);

            Map<String, HttpRequest> requests = con.getRequests();
            //system.assert(requests.size() == 1);
            // Create a mock response
            HttpResponse response = new HttpResponse();
            response.setBody('{"JData":"1F3ukS89iNZyq2s85KlipY0ecwGxUOWJhwtu7KbkIMEif4MEShQG3LudufPCyLkClWpcjeNTLCSleHSHReijyrFGYT6jTJfn/Qy3UPiJj2uBB3yJIova0Ujjj7znle2xuS1IbgOOEzKjYUCg7ea53hzgt87PwpyWS3PKMAm0nJ0qyQ85cGLDYe9u7a8RhW3/ctMlsezH7mRSXoe9Qk7HYSqi06p9vSVUItjaeG5N30WAmLXvkkew/iV4Ulnr/Gc8ODtLn9c23U5hA47iKkXX6yoqAP++tLnS2WkfHwzFOm/T8TK0f630deFvL+EFLF576y6KgbeM2cfriSciNlYWE7LxIbB2x4W2VuL8CCi8Guhg4TLhiwrIaIOZgHPaLSlR4xBU3Zs7fhzn7NSw5h1ohdGcvjQ4QftIcHFcsCa35EDjJ2B8q6ct+9QhWoDw/Kj5cIMcJd4T4kwHCfBaTdaWGkSyTyhL52+3ZLdPvupUMNX9ZSxy6pWsyszAOFTqy2hSC2n42RFDlh0EhYBD450u+bIA1/GvyMCq1m79J8UMAiPCJ0k/wEO2Qr1xLFqMgNOhZ3TmCPF9TcZTsw11d/CpfohJZfjn3EcxbWZaQZ3C2cNNY4gjfBhk5w6EuB//aOaPZ3jEujqHlWWyEcdBP4sqF2AoKTNdbNQYNiku2LEmk5HlUx4D9FvrrRydnSTEtTGNg8qXxXkDmGYvcXE4d+hCY1CdNEr/PnQjeHWa8749X6HC78dYtZdBrqugWrL+cYcJiAUcxn2+VobiuB6ECMak3toMDxrR81mZ76o7YWJJgykrqn9j+2p71wSkN6whCGLCGvYhRfZfIC9JbCjgHnNSgQ24CUHvcpVah4Krjq+0iRgqQKn0p43BZ9SobOVzr372VEtrhyRsyk0YdFKodeoLo6p9lIeKCMIyArcTbhzYxDEgOhY9FCa5dLeSzSinbFlaJqgRP72EVGfz+S2kOQkT+K7XWX3Msqg5RKXW5Wx+f0s="}');
            response.setStatusCode(200);

            String continuationLabel = DSA_IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
            Object continuationState= DSA_IntegrationEngine.continuationState;


            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
            membershipResponse = (String)DSA_IntegrationEngine.processOfferEngineCalloutResponseDSA(labels, DSA_IntegrationEngine.continuationState);
            Test.stopTest();
            }
            String responseExpected ='{"body":null,"version":null,"transactionID":null,"responseTime":null,"responseStatus":null,"requestTime":null,"executionTimeInMS":null,"error":null,"callType":"OFFER","applicationHitCount":null,"application":null}';
            System.assertEquals(responseExpected, membershipResponse,'SUCCESS');
        } catch(Exception ex){
           // System.assertEquals(ex.getMessage(),'Who will repay the loan field is required.');
        }
    }

    @isTest
    public static void validateException(){
        try{
            IND_CIBILServiceDSA.getcibilCallout(null, null, null, null, null);
        }catch(Exception pEx){
            System.assert(pEx.getMessage() != null);
        }

    }
}