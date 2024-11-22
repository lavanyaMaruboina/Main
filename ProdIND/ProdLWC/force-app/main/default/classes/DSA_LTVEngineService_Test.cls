@isTest(SeeAllData=false)
public class DSA_LTVEngineService_Test {

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
    public static void testLTVEngineService() {
        try {
            User u = [SELECT Id,usertype FROM User WHERE UserName='standarduser4@testorg.com.psdev1' AND IsActive = true LIMIT 1];
            Applicant__c applicant = [SELECT Id, Opportunity__c FROM Applicant__c LIMIT 1];
            String loanAppId = applicant.Opportunity__c;
            String membershipResponse = '';
            system.runAs(u){
            Continuation con = (Continuation)DSA_IntegrationEngine.doLTVEngineCallout(applicant.Id,loanAppId);

            Map<String, HttpRequest> requests = con.getRequests();
            //system.assert(requests.size() == 1);
            // Create a mock response
            HttpResponse response = new HttpResponse();
            response.setBody('{"JData":"1F3ukS89iNZyq2s85KlipVyhUm4luUqOJ6t9i3fmdWUP0o3+YAw4ctladyVLI9CVMVJyHe5SRMdL0WuRGbqYSxa852jnT10hp7UB+pikGrEP0A5vnpRX35jb0hKkpGCQDskj76JK+ARKwlEtddTWbWXto/a/EPfLhzbM6j4RoFcLgq9brn24FjE7kExX4xns8ofR4Md1KobJQ3l8wjaxrxswscTgh3tXRpWOc06kHih1D+Zt9ODA8gHBWPdfXd+OL1wrD/bgv1EfC3MDRw+LiM2gpxztUbRhdGD4Tn51nQBxY+o8hk/dh7caR2VsGFJHDKtoUstjxt0T8skWNx3ltA=="}');
            response.setStatusCode(200);

            String continuationLabel = DSA_IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
            Object continuationState= DSA_IntegrationEngine.continuationState;


            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
            membershipResponse = (String)DSA_IntegrationEngine.processLTVEngineAPIResponse(labels, DSA_IntegrationEngine.continuationState);
            Test.stopTest();
            }
            String responseExpected ='{"body":null,"application":null}';
            System.assertEquals(responseExpected, membershipResponse,'SUCCESS');
        } catch(Exception ex){
            System.assertEquals(ex.getMessage(),'Who will repay the loan field is required.');
        }
    }


    @isTest
    public static void testLTVEngineService2(){

        try{
            User u = [SELECT Id,usertype FROM User WHERE UserName='standarduser4@testorg.com.psdev1' AND IsActive = true LIMIT 1];
            Applicant__c applicant = [SELECT Id,Customer_First_Name__c,Customer_Last_Name__c, Opportunity__c FROM Applicant__c LIMIT 1];
            String loanAppId = applicant.Opportunity__c;
            String panCallOutResponse = '';
            system.runAs(u){
            String ltvEngineRequest = '{"applicantId":"'+applicant.Id+'" ,"panNumber":"CSWPG3660G","firstName":"'+applicant.Customer_First_Name__c+'","lastName":"'+applicant.Customer_Last_Name__c+' "}';
            Continuation con = (Continuation)DSA_IntegrationEngine.doLTVEngineCallout(ltvEngineRequest, loanAppId);
            // Create a mock response
            HttpResponse response = new HttpResponse();
            response.setBody('{"JData":"bmvHXB5/b59ltoDPA8dwPKjM9zW1GwK5fvqA5/8G5njg6LzMAYI4Id6LrLJmRnoijeFuaYkwDnaZHsa+6xYit82GLmdlqwXm0BAn6A39s+8tEj1DO22pB2d+pdaaLuahdq9qhYsY6BgGXwQveaGe+qoE4LwKTSymv3ZxeE/r6N6i8Jj51Sf62N2i1LJhaAOKAIhf3hW/g9kO5MXzbWm4eZn7whfcMFdjvVr3NW4wI788aR9xGUvwj87yC5uQuaM5hKzMwKJJJKU0eR4sNzzTPForbed5aCwoRITFkUeQ/l8yNywULXNPSI8qTYEEyt5yW9tfbI6t+Vm48d8F807UycU2Kn4G+Z2DYm9yfuHn+NqlO3nRJnjgmcud83kQT+0j"}');
            response.setStatusCode(200);

            String continuationLabel = DSA_IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
                Object continuationState= DSA_IntegrationEngine.continuationState;

            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
            panCallOutResponse= (String)DSA_IntegrationEngine.processLTVEngineAPIResponse(labels, DSA_IntegrationEngine.continuationState);
            Test.stopTest();
            }
            String responseExpected ='{"body":null,"application":null}';
            System.assertEquals(responseExpected, panCallOutResponse, 'SUCCESS');

        } catch(Exception ex){
            System.assertEquals(ex.getMessage(),'Who will repay the loan field is required.');
        }
    }

    @isTest
    public static void testLTVEngineService4(){
        User u = [SELECT Id,usertype FROM User WHERE UserName='standarduser4@testorg.com.psdev1' AND IsActive = true LIMIT 1];
        system.runAs(u){
        Applicant__c applicant = [SELECT Id, Opportunity__c FROM Applicant__c LIMIT 1];
        Opportunity opp = [SELECT StageName, CloseDate, Is_Pre_Approved__c, Name, Product_Type__c, Vehicle_Type__c, Agent_BL_code__c, Lead_number__c, LeadSource FROM Opportunity WHERE Id = :applicant.Opportunity__c];
        RequestWrapper reqWrapper = new RequestWrapper();
        reqWrapper.applicantId = applicant.Id;
        reqWrapper.coBorrowerPresentAddress = 'test';
        reqWrapper.coBorrowerNIP = 'dd';
        reqWrapper.subProduct = 'test';
        reqWrapper.scoreCardDecision = 'Red';
        reqWrapper.proposalBasedOn = String.valueOf(System.today().addDays(15));

        IND_LTVEngineRequestDSA objResult = new IND_LTVEngineRequestDSA(opp, reqWrapper);

        String errorMsg = '';
        try{
            reqWrapper.scoreCardDecision = null;
            objResult= IND_LTVEngineServiceDSA.getLTVEngineRequest(opp, opp.Id, reqWrapper);
        }catch(Exception pEx){
            errorMsg =   pEx.getMessage();
        }
        System.assert(errorMsg.contains(System.Label.RiskBand));
    }
    }

}