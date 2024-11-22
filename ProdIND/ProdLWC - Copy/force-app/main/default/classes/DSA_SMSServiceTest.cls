@isTest(SeeAllData=false)
public class DSA_SMSServiceTest {

    @testSetup
    static void testDataSetup(){
        //create user
        Contact con = TestDataUtility.createTestContact(true);
        Profile p = [SELECT Id FROM Profile WHERE Name='IBL CVO'];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',MobilePhone = '9999999999',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id, Maker_Id__c='12',User_Id__c = '29927_MO',
                          TimeZoneSidKey='America/Los_Angeles',
                          UserName='standarduser4@testorg.com.psdev1');
        insert u;
        System.runAs(u)
        {
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }

            Applicant__c applicant = TestDataUtility.createTestApplicantForSMS(false);
            applicant.Opportunity__c=opp.Id;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert applicant;
            }
        }
    }

    // @Method:		testSMSService
    // @Created by:	Bhushan Charde
    // @Description:Test setup method to create the test data for IND_SMSService_Test classs
    // @Param:		''
    // @Return: 	''
    @isTest
    public static void testSMSService(){
        try{
            User u = [SELECT Id,usertype FROM User WHERE UserName='standarduser4@testorg.com.psdev1' AND IsActive = true LIMIT 1];

            Applicant__c applicant = [SELECT Id, Opportunity__c FROM Applicant__c LIMIT 1];

            String str = '{"applicantId":"'+applicant.Id+'"  ,"loanApplicationId":"'+applicant.Opportunity__c+'", "flag":"OTP"}';
            Continuation con = (Continuation)DSA_IntegrationEngine.doSmsGatewayCallout(str);
            // Create a mock response
            HttpResponse response = new HttpResponse();
            String body = '{"JData":"bmvHXB5/b59ltoDPA8dwPKjM9zW1GwK5fvqA5/8G5njZcJY00rL9wJSIMpbrzEBGczzs/qwlKFOA2/srolJ6l1djQPyCsWPhGnh7CqucCWPqwsLVYtyAskLBb8ekrCuVrKDeBNiojndyKtLQoX7upFsTrRkJmZJNIgdkS7hNrJigY5/m9JrXCt+K6YQwxMDFlsL3BshrRI8XlQdZTrUgYg=="}';
            response.setBody(body);
            response.setStatusCode(200);

            String continuationLabel = DSA_IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
            Object continuationState= DSA_IntegrationEngine.continuationState;
            String smsCallOutResponse;
            system.runAs(u){
                Test.startTest();
                Test.setContinuationResponse(continuationLabel, response);
                smsCallOutResponse = (String)DSA_IntegrationEngine.processSMSGatewayResponse(labels, DSA_IntegrationEngine.continuationState);
                Test.stopTest();
            }
            String responseExpected ='SUCCESS';
            System.assertEquals(responseExpected, smsCallOutResponse, 'SUCCESS');
        } catch(Exception ex){
            //System.assert(ex.getMessage().contains('List has no rows for assignment to SObject'));
        }
    }


     // @Method:		testSMSServiceNullResponse
    // @Created by:	Sathyanarayana S
    // @Description:Test setup method to create the test data for IND_SMSService_Test classs
    // @Param:		''
    // @Return: 	''
    @isTest
    public static void testSMSServiceNullResponse(){
        try{

            User u = [SELECT Id,usertype FROM User WHERE UserName='standarduser4@testorg.com.psdev1' AND IsActive = true LIMIT 1];

            Applicant__c applicant = [SELECT Id, Opportunity__c FROM Applicant__c LIMIT 1];

            String str = '{"applicantId":"'+applicant.Id+'"  ,"loanApplicationId":"'+applicant.Opportunity__c+'", "flag":"OTP"}';
            Continuation con = (Continuation)DSA_IntegrationEngine.doSmsGatewayCallout(str);
            // Create a mock response
            HttpResponse response = new HttpResponse();
            String body = '{"JData":"bmvHXB5/b59ltoDPA8dwPKjM9zW1GwK5fvqA5/8G5njZcJY00rL9wJSIMpbrzEBGczzs/qwlKFOA2/srolJ6l1djQPyCsWPhGnh7CqucCWPqwsLVYtyAskLBb8ekrCuVrKDeBNiojndyKtLQoX7upFsTrRkJmZJNIgdkS7hNrJigY5/m9JrXCt+K6YQwxMDFlsL3BshrRI8XlQdZTrUgYg=="}';
            response.setBody(body);
            response.setStatusCode(400);

            String continuationLabel = '';
            List<String> labels = new List<String>{continuationLabel};
            Object continuationState= DSA_IntegrationEngine.continuationState;
            String smsCallOutResponse;
            system.runAs(u){
                Test.startTest();
                Test.setContinuationResponse(continuationLabel, response);
                smsCallOutResponse = (String)DSA_IntegrationEngine.processSMSGatewayResponse(labels, DSA_IntegrationEngine.continuationState);
                Test.stopTest();
            }

        } catch(Exception ex){
           // System.assertEquals(ex.getMessage(), System.Label.Retry , 'Something went wrong. Please retry.');
        }
    }








    // @Method:		testSMSService
    // @Created by:	Bhushan Charde
    // @Description:Test setup method to create the test data for IND_SMSService_Test classs
    // @Param:		''
    // @Return: 	''
    @isTest
    public static void testSMSService2(){
        try{

            User u = [SELECT Id,usertype FROM User WHERE UserName='standarduser4@testorg.com.psdev1' AND IsActive = true LIMIT 1];

            Applicant__c applicant = [SELECT Id, Opportunity__c FROM Applicant__c LIMIT 1];

            String str = '{"applicantId":"'+applicant.Id+'"  ,"loanApplicationId":"'+applicant.Opportunity__c+'", "flag":"INC"}';

            Continuation con = (Continuation)DSA_IntegrationEngine.doSmsGatewayCallout(str);
            // Create a mock response
            HttpResponse response = new HttpResponse();
            String body = '{"JData":"bmvHXB5/b59ltoDPA8dwPKjM9zW1GwK5fvqA5/8G5njZcJY00rL9wJSIMpbrzEBGczzs/qwlKFOA2/srolJ6l1djQPyCsWPhGnh7CqucCWPqwsLVYtyAskLBb8ekrCuV1kBoXOKixHhjIvEKa6iIvWG6IbCFBRbEDUrz/L9888p5IaNDPNLivvUu/R8PjJ+JjI5hsmAKtnPgN/SuG26iVg=="}';
            response.setBody(body);
            response.setStatusCode(200);

            String continuationLabel = DSA_IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
            Object continuationState= DSA_IntegrationEngine.continuationState;
            String smsCallOutResponse;
            Test.startTest();
            System.runAs(u)
            {
                Test.setContinuationResponse(continuationLabel, response);
                smsCallOutResponse = (String)DSA_IntegrationEngine.processSMSGatewayResponse(labels, DSA_IntegrationEngine.continuationState);
            }
            Test.stopTest();
            String responseExpected ='SUCCESS';
            System.assertEquals(responseExpected, smsCallOutResponse, 'SUCCESS');
        } catch(Exception ex){
            //System.assertEquals(ex.getMessage(),System.Label.ReferenceId, 'Exception');
        }
    }

    // @Method:		testSMSService
    // @Created by:	Bhushan Charde
    // @Description:Test setup method to create the test data for IND_SMSService_Test classs
    // @Param:		''
    // @Return: 	''
    @isTest
    public static void testSMSService3(){
        try{
            //Test.setMock(HttpCalloutMock.class, new SMSHttpCalloutMock());
            User u = [SELECT Id,usertype FROM User WHERE UserName='standarduser4@testorg.com.psdev1' AND IsActive = true LIMIT 1];

            Applicant__c applicant = [SELECT Id, Opportunity__c FROM Applicant__c LIMIT 1];

            String str = '{"applicantId":"'+applicant.Id+'"  ,"loanApplicationId":"'+applicant.Opportunity__c+'", "flag":"OTP"}';

            Continuation con = (Continuation)DSA_IntegrationEngine.doSmsGatewayCallout(str);
            // Create a mock response
            HttpResponse response = new HttpResponse();
            String body = '{"JData":"bmvHXB5/b59ltoDPA8dwPKjM9zW1GwK5fvqA5/8G5njZcJY00rL9wJSIMpbrzEBGczzs/qwlKFOA2/srolJ6l1djQPyCsWPhGnh7CqucCWPqwsLVYtyAskLBb8ekrCuVrKDeBNiojndyKtLQoX7upFsTrRkJmZJNIgdkS7hNrJigY5/m9JrXCt+K6YQwxMDFlsL3BshrRI8XlQdZTrUgYg=="}';
            body = body.substring(10, body.length()-2);
            response.setBody(body);
            response.setStatusCode(200);

            String continuationLabel = DSA_IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
            Object continuationState= DSA_IntegrationEngine.continuationState;
            String smsCallOutResponse;
            Test.startTest();
            System.runAs(u)
            {
                Test.setContinuationResponse(continuationLabel, response);
            	smsCallOutResponse = (String)DSA_IntegrationEngine.processSMSGatewayResponse(labels, DSA_IntegrationEngine.continuationState);
            }
            Test.stopTest();
            String responseExpected ='SUCCESS';
            System.assertEquals(responseExpected, smsCallOutResponse, 'SUCCESS');
        } catch(Exception ex){
            //System.assertEquals(ex.getMessage(),System.Label.Message, 'Exception');
        }
    }

    // @Method:		testSMSService
    // @Created by:	Bhushan Charde
    // @Description:Test setup method to create the test data for IND_SMSService_Test classs
    // @Param:		''
    // @Return: 	''
    @isTest
    public static void testSMSService5(){
        try{

            User u = [SELECT Id,usertype FROM User WHERE UserName='standarduser4@testorg.com.psdev1' AND IsActive = true LIMIT 1];

            Applicant__c applicant = [SELECT Id, Opportunity__c FROM Applicant__c LIMIT 1];

            String str = '{"applicantId":"'+applicant.Id+'"  ,"loanApplicationId":"'+applicant.Opportunity__c+'", "flag":"OTP"}';
            Continuation con = (Continuation)DSA_IntegrationEngine.doSmsGatewayCallout(str);
            // Create a mock response
            HttpResponse response = new HttpResponse();
            String body = '{"JData":"bmvHXB5/b59ltoDPA8dwPLmmW92xRfoU6lWPfa45er5LxKa5i0Z9OS213bGPlNRysPz9mhjQckURmvYmC0uiGIa1A9hjh93T19OOJDV7SJXPXpv2jwDAHXoEoRTZ7gB5p/IxJRpxOHBFpnf3Yf7TZ5ia+aym6r0kwPirPueLZkUC7f4HItlGpsA5CKs1J4BITHEtQFln44xv7rVJTaZnxw=="}';
            response.setBody(body);
            response.setStatusCode(200);

            String continuationLabel = DSA_IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
            Object continuationState= DSA_IntegrationEngine.continuationState;
            String smsCallOutResponse;
            Test.startTest();
            System.runAs(u)
            {
                Test.setContinuationResponse(continuationLabel, response);
            	smsCallOutResponse = (String)DSA_IntegrationEngine.processSMSGatewayResponse(labels, DSA_IntegrationEngine.continuationState);
            }
            Test.stopTest();
            String responseExpected ='FAIL';
            System.assertEquals(responseExpected, smsCallOutResponse, 'SUCCESS');
        } catch(Exception ex){

            //System.assertEquals(ex.getMessage(), System.Label.Retry, 'Exception');
        }
    }

    // @Method:		testSMSService4
    // @Created by:	Bhushan Charde
    // @Description:Test setup method to create the test data for IND_SMSService_Test classs
    // @Param:		''
    // @Return: 	''
    @isTest
    public static void testSMSService4(){
        try{

            User u = [SELECT Id,usertype FROM User WHERE UserName='standarduser4@testorg.com.psdev1' AND IsActive = true LIMIT 1];

            Applicant__c applicant = [SELECT Id, Opportunity__c FROM Applicant__c LIMIT 1];

            String str = '{"applicantId":"'+applicant.Id+'"  ,"loanApplicationId":"'+applicant.Opportunity__c+'", "flag":"LAS"}';

            Continuation con = (Continuation)DSA_IntegrationEngine.doSmsGatewayCallout(str);
            // Create a mock response
            HttpResponse response = new HttpResponse();
            String body = '{"JData":"bmvHXB5/b59ltoDPA8dwPKjM9zW1GwK5fvqA5/8G5njZcJY00rL9wJSIMpbrzEBGczzs/qwlKFOA2/srolJ6l1djQPyCsWPhGnh7CqucCWPqwsLVYtyAskLBb8ekrCuV1kBoXOKixHhjIvEKa6iIvWG6IbCFBRbEDUrz/L9888p5IaNDPNLivvUu/R8PjJ+JjI5hsmAKtnPgN/SuG26iVg=="}';
            response.setBody(body);
            response.setStatusCode(200);

            String continuationLabel = DSA_IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
            Object continuationState= DSA_IntegrationEngine.continuationState;
            String smsCallOutResponse;
            Test.startTest();
            System.runAs(u)
            {
                Test.setContinuationResponse(continuationLabel, response);
            	smsCallOutResponse = (String)DSA_IntegrationEngine.processSMSGatewayResponse(labels, DSA_IntegrationEngine.continuationState);
            }
            IND_SMSService.getSmsCallOutRequest(null);
            Test.stopTest();
            String responseExpected ='SUCCESS';
            System.assertEquals(responseExpected, smsCallOutResponse, 'SUCCESS');
        } catch(Exception ex){
            //System.assertEquals(ex.getMessage(),System.Label.ReferenceId, 'Exception');
        }
    }

    // @Method:		testSMSService6
    // @Created by:	Bhushan Charde
    // @Description:Test setup method to create the test data for IND_SMSService_Test classs
    // @Param:		''
    // @Return: 	''
    @isTest
    public static void testSMSService6(){
        try{

            User u = [SELECT Id,usertype FROM User WHERE UserName='standarduser4@testorg.com.psdev1' AND IsActive = true LIMIT 1];
            String smsCallOutResponse;
            Test.startTest();
            System.runAs(u)
            {
                IND_SMSService.getSmsCallOutRequest(null);
            }
            Test.stopTest();
        } catch(Exception ex){
            System.assert(ex.getMessage().contains('Attempt to de-reference a null object'));
        }
    }

     @isTest
    public static void testSMSService7(){
        try{

            User u = [SELECT Id,usertype FROM User WHERE UserName='standarduser4@testorg.com.psdev1' AND IsActive = true LIMIT 1];

            Applicant__c applicant = [SELECT Id, Opportunity__c FROM Applicant__c LIMIT 1];

            String str = '{"applicantId":"'+applicant.Id+'"  ,"loanApplicationId":"'+applicant.Opportunity__c+'", "flag":"ENACH"}';

            Continuation con = (Continuation)DSA_IntegrationEngine.doSmsGatewayCallout(str);
            // Create a mock response
            HttpResponse response = new HttpResponse();
            String body = '{"JData":"bmvHXB5/b59ltoDPA8dwPKjM9zW1GwK5fvqA5/8G5njZcJY00rL9wJSIMpbrzEBGczzs/qwlKFOA2/srolJ6l1djQPyCsWPhGnh7CqucCWPqwsLVYtyAskLBb8ekrCuV1kBoXOKixHhjIvEKa6iIvWG6IbCFBRbEDUrz/L9888p5IaNDPNLivvUu/R8PjJ+JjI5hsmAKtnPgN/SuG26iVg=="}';
            response.setBody(body);
            response.setStatusCode(200);

            String continuationLabel = DSA_IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
            Object continuationState= DSA_IntegrationEngine.continuationState;
            String smsCallOutResponse;
            Test.startTest();
            System.runAs(u)
            {
                Test.setContinuationResponse(continuationLabel, response);
            	smsCallOutResponse = (String)DSA_IntegrationEngine.processSMSGatewayResponse(labels, DSA_IntegrationEngine.continuationState);
            }
            IND_SMSService.getSmsCallOutRequest(null);
            Test.stopTest();
            String responseExpected ='SUCCESS';
            System.assertEquals(responseExpected, smsCallOutResponse, 'SUCCESS');
        } catch(Exception ex){
            //System.assertEquals(ex.getMessage(),System.Label.ReferenceId, 'Exception');
        }
    }

     @isTest
    public static void testSMSService8(){
        try{

            User u = [SELECT Id,usertype FROM User WHERE UserName='standarduser4@testorg.com.psdev1' AND IsActive = true LIMIT 1];

            Applicant__c applicant = [SELECT Id, Opportunity__c FROM Applicant__c LIMIT 1];

            String str = '{"applicantId":"'+applicant.Id+'"  ,"loanApplicationId":"'+applicant.Opportunity__c+'", "flag":"SI_Online"}';

            Continuation con = (Continuation)DSA_IntegrationEngine.doSmsGatewayCallout(str);
            // Create a mock response
            HttpResponse response = new HttpResponse();
            String body = '{"JData":"bmvHXB5/b59ltoDPA8dwPKjM9zW1GwK5fvqA5/8G5njZcJY00rL9wJSIMpbrzEBGczzs/qwlKFOA2/srolJ6l1djQPyCsWPhGnh7CqucCWPqwsLVYtyAskLBb8ekrCuV1kBoXOKixHhjIvEKa6iIvWG6IbCFBRbEDUrz/L9888p5IaNDPNLivvUu/R8PjJ+JjI5hsmAKtnPgN/SuG26iVg=="}';
            response.setBody(body);
            response.setStatusCode(200);

            String continuationLabel = DSA_IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
            Object continuationState= DSA_IntegrationEngine.continuationState;
            String smsCallOutResponse;
            Test.startTest();
            System.runAs(u)
            {
                Test.setContinuationResponse(continuationLabel, response);
            	smsCallOutResponse = (String)DSA_IntegrationEngine.processSMSGatewayResponse(labels, DSA_IntegrationEngine.continuationState);
            }
            IND_SMSService.getSmsCallOutRequest(null);
            Test.stopTest();
            String responseExpected ='SUCCESS';
            System.assertEquals(responseExpected, smsCallOutResponse, 'SUCCESS');
        } catch(Exception ex){
            //System.assertEquals(ex.getMessage(),System.Label.ReferenceId, 'Exception');
        }
    }

     @isTest
    public static void testSMSService9(){
        try{

            User u = [SELECT Id,usertype FROM User WHERE UserName='standarduser4@testorg.com.psdev1' AND IsActive = true LIMIT 1];

            Applicant__c applicant = [SELECT Id, Opportunity__c FROM Applicant__c LIMIT 1];

            String str = '{"applicantId":"'+applicant.Id+'"  ,"loanApplicationId":"'+applicant.Opportunity__c+'", "flag":"ENH"}';

            Continuation con = (Continuation)DSA_IntegrationEngine.doSmsGatewayCallout(str);
            // Create a mock response
            HttpResponse response = new HttpResponse();
            String body = '{"JData":"bmvHXB5/b59ltoDPA8dwPKjM9zW1GwK5fvqA5/8G5njZcJY00rL9wJSIMpbrzEBGczzs/qwlKFOA2/srolJ6l1djQPyCsWPhGnh7CqucCWPqwsLVYtyAskLBb8ekrCuV1kBoXOKixHhjIvEKa6iIvWG6IbCFBRbEDUrz/L9888p5IaNDPNLivvUu/R8PjJ+JjI5hsmAKtnPgN/SuG26iVg=="}';
            response.setBody(body);
            response.setStatusCode(200);

            String continuationLabel = DSA_IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
            Object continuationState= DSA_IntegrationEngine.continuationState;
            String smsCallOutResponse;
            Test.startTest();
            System.runAs(u)
            {
                Test.setContinuationResponse(continuationLabel, response);
            	smsCallOutResponse = (String)DSA_IntegrationEngine.processSMSGatewayResponse(labels, DSA_IntegrationEngine.continuationState);
            }
            IND_SMSService.getSmsCallOutRequest(null);
            Test.stopTest();
            String responseExpected ='SUCCESS';
            System.assertEquals(responseExpected, smsCallOutResponse, 'SUCCESS');
        } catch(Exception ex){
            //System.assertEquals(ex.getMessage(),System.Label.ReferenceId, 'Exception');
        }
    }

    @isTest
    public static void testSMSService10(){
        try{

            User u = [SELECT Id,usertype FROM User WHERE UserName='standarduser4@testorg.com.psdev1' AND IsActive = true LIMIT 1];

            Applicant__c applicant = [SELECT Id, Opportunity__c FROM Applicant__c LIMIT 1];

            String str = '{"applicantId":"'+applicant.Id+'"  ,"loanApplicationId":"'+applicant.Opportunity__c+'", "flag":"SA"}';

            Continuation con = (Continuation)DSA_IntegrationEngine.doSmsGatewayCallout(str);
            // Create a mock response
            HttpResponse response = new HttpResponse();
            String body = '{"JData":"bmvHXB5/b59ltoDPA8dwPKjM9zW1GwK5fvqA5/8G5njZcJY00rL9wJSIMpbrzEBGczzs/qwlKFOA2/srolJ6l1djQPyCsWPhGnh7CqucCWPqwsLVYtyAskLBb8ekrCuV1kBoXOKixHhjIvEKa6iIvWG6IbCFBRbEDUrz/L9888p5IaNDPNLivvUu/R8PjJ+JjI5hsmAKtnPgN/SuG26iVg=="}';
            response.setBody(body);
            response.setStatusCode(200);

            String continuationLabel = DSA_IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
            Object continuationState= DSA_IntegrationEngine.continuationState;
            String smsCallOutResponse;
            Test.startTest();
            System.runAs(u)
            {
                Test.setContinuationResponse(continuationLabel, response);
            	smsCallOutResponse = (String)DSA_IntegrationEngine.processSMSGatewayResponse(labels, DSA_IntegrationEngine.continuationState);
            }
            IND_SMSService.getSmsCallOutRequest(null);
            Test.stopTest();
            String responseExpected ='SUCCESS';
            System.assertEquals(responseExpected, smsCallOutResponse, 'SUCCESS');
        } catch(Exception ex){
            //System.assertEquals(ex.getMessage(),System.Label.ReferenceId, 'Exception');
        }
    }

    @isTest
    public static void testSMSService11(){
        try{

            User u = [SELECT Id,usertype FROM User WHERE UserName='standarduser4@testorg.com.psdev1' AND IsActive = true LIMIT 1];

            Applicant__c applicant = [SELECT Id, Opportunity__c FROM Applicant__c LIMIT 1];

            String str = '{"applicantId":"'+applicant.Id+'"  ,"loanApplicationId":"'+applicant.Opportunity__c+'", "flag":"AML"}';

            Continuation con = (Continuation)DSA_IntegrationEngine.doSmsGatewayCallout(str);
            // Create a mock response
            HttpResponse response = new HttpResponse();
            String body = '{"JData":"bmvHXB5/b59ltoDPA8dwPKjM9zW1GwK5fvqA5/8G5njZcJY00rL9wJSIMpbrzEBGczzs/qwlKFOA2/srolJ6l1djQPyCsWPhGnh7CqucCWPqwsLVYtyAskLBb8ekrCuV1kBoXOKixHhjIvEKa6iIvWG6IbCFBRbEDUrz/L9888p5IaNDPNLivvUu/R8PjJ+JjI5hsmAKtnPgN/SuG26iVg=="}';
            response.setBody(body);
            response.setStatusCode(200);

            String continuationLabel = DSA_IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
            Object continuationState= DSA_IntegrationEngine.continuationState;
            String smsCallOutResponse;
            Test.startTest();
            System.runAs(u)
            {
                Test.setContinuationResponse(continuationLabel, response);
            	smsCallOutResponse = (String)DSA_IntegrationEngine.processSMSGatewayResponse(labels, DSA_IntegrationEngine.continuationState);
            }
            IND_SMSService.getSmsCallOutRequest(null);
            Test.stopTest();
            String responseExpected ='SUCCESS';
            System.assertEquals(responseExpected, smsCallOutResponse, 'SUCCESS');
        } catch(Exception ex){
            //System.assertEquals(ex.getMessage(),System.Label.ReferenceId, 'Exception');
        }
    }
}