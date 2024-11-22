/*------------------------------------------------------------
Author:        Aman Mundhada
Company:       Persistent Systems
Description:   Test class created to validate the IND_PassportRequest IND_PassportService IND_PassportResponse class
History
Date            Author              Comments
-------------------------------------------------------------
10-12-2021      Aman Mundhada       Created
------------------------------------------------------------*/


@isTest(SeeAllData=false)
public class IND_PassportService_Test {

    
    @isTest
    public static void testINDPassportService(){ 
        
        try{              
             Profile p = [SELECT Id FROM Profile WHERE Name='CMU'];
           
    		User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
					EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
					LocaleSidKey='en_US', ProfileId = p.Id,MobilePhone = '9701498575',
Maker_Id__c='1002',User_Id__c = '29927_MO',
					TimeZoneSidKey='America/Los_Angeles',
					UserName='standarduser4@testorg.com.psdev1');
            insert u;
            System.runAs(u){
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
           if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            Applicant__c applicant = TestDataUtility.createTestApplicantForPassport(false);
            applicant.Opportunity__c=opp.Id;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert applicant;
            }
            Documents__c document = TestDataUtility.createTestPPDocs(false,applicant,opp);
            if (Schema.sObjectType.Documents__c.isCreateable()){
                insert document;
            }
            Datetime dOB = (Datetime)document.KYC_DOB__c;
            String dateOfBirth= dOB.format('ddMMyyyy') ;
            String ppCallOutRequest = '{"applicantId":"'+applicant.Id+'" ,"dateOfBirth":"'+dateOfBirth+'" ,"kycPassportNo":"'+document.Passport_No__c+'","kycPassportFileNo":"'+document.Passport_File_No__c+'","firstName":"'+applicant.Customer_First_Name__c+'","lastName":"'+applicant.Customer_Last_Name__c+'","email":"","kycGender":"'+document.Gender__c+'"}';
            
            Continuation con = (Continuation)IntegrationEngine.doPPCallout(ppCallOutRequest);
            // Create a mock response
        	HttpResponse response = new HttpResponse();
            response.setBody('{"JData":"vz+0HRIa7MZUAaPO1qm8zJFUf6d4ipIt2F1fh/j48YA63dH9imVJaZtoRrYI+I5D/om00iSdyKPP/JUHHA3uXNI4ftcUPA+WS9Li0rMPcW85wMTx6bnHMuYPga0MS6gV2gFF9nn59YD78G30ZlDaSwaD6kV0oQosZ2nICIfK8BPX7G+gVqU7YXUZfgBAQa8xeNLCnteqgJJLc8ZKfs5GglF+y3SvU5vmg1HeGCnAxv6j/ElRiVd8rWLdqP1/eMQ427WLSgdB+x/V5SGzGeRBLxyW4J36QQfOzbojsF2SAgKsiST4Yokjlf4FXINPQTWkVwc7T0Mu8jQ7x+/B0xAI7Is2B1a0DTkV6BsxGbJ5UpdaNzw0uXDEcY49BLn+8wkNMH+0SycU2UOqAgL5iGmkCVLBkFf0so7SYGenatD/Vfyxv1xDKdhX6FWWW0PBwrJ5o1Kk5e5r4R2Cf81gk/wg1KzFm9FGQCf/SldvknQ5eroDScnih20/zoOXNjYGnSriGpXyRt9LMfg+QQKh7Lv7DgbgkJIChg04tgHPzxEJ4lL7JhYyazPiXVr7uSzW9CYeqftAxObPv394XIvaRuYMnmurSvS3e/iZj7OEb6ZPPRGbhuCvI6T98myGbPqnDDKZbGyv9wmTgtutt9dq/8/vGkDJLwhats25EVUPF6tiiVWuOyBNQQfsS1ZLRBeTonEfOgwMYo3Y3vo8itWuil2lCgCSbQ5t3tsfo61aN1b4EcncPOh9b6t9Zop2OXzQtTvd/qx0A8BR0aMkWIXWX101TEEcHprKLlB+Rd9b2Tc0bFdiKENOwKJUcofP1Fr9y0YJ9hwl/Kyw6DOmoPi65fycAdmpy04oiFnA+2yuahWNsue8oCGFh5zNlZNM69k8erpqrF1kyTACBGHvJtElYgpDGz5np4X+BRDmsjnH5fOefmWzh5ZTQOpEVMjf0FB9vfzUM0BHxk5SY8H7wMwwjC+g9smI0mieH4I1+55o9L6MJd/ZMKbavzJBHtUArmX8u0dc1iI1LTr9zi4+ZRSrtMCCbfO2YK0dVif9A5BU26wPgERLtsZTsY7lU9QZw9tQlKOlmhyqquooFy18YUNY7NfI+G+wHRRS05v5ct+cDsRwHVDjeYVuKIlDI25IgmtIxDg4P/XxRZaSEpvBeZo1xEA7gaMjkaTgC0oWTmMkU/VJ/UxiOv6hz3ZPCvUhEpepHGd/JNLfcyZeCzw5kbnnZfSaTYQ9adTjgTnuyNGppPsogZ5cro/GxUoYhCkj1gOLWLLXhuIXFeqqFQx3d5oBqt6tp/58ba39XGwZ5Gx0+7hWDZXi8Sgq6lFLA4Td+GBeqMDVRrAPvKRmOssI/qwIpRWfkjAo4pI/IZQdv5g3Pc4ok5J6LNBcyA5tWTAhJQ5cSReTbX4J6vb9eTR4u5o3U+M8xwLQh08NahoZm8LR7WUVxmGAAxiF8bLEylKULmYaNTqdbt+Hnwzojrh+DBhQiDPzdlX/3JEkAuBpI/prTvQd/eCnAbJr2LGmSfaxJ6ID9QY7JEA8D06yzFNuHLf/pquAzEq6/vYikjsqha8675Zqq0zvU/Tx5OHnwsaYEH28Ki3RlsdAI8fnX7/tmIBiqGJMXeU2JzfncqmR3xDBCKlaLdNvHZ9iLpOU/bQ0H/1yjsF9zjvy0lzEMJOGsFoOhNqSMjwW+Oju4PIZQiDCcyaxlk2o5SNx+1lgt0zBG2aUU8LY58Y7Qi72Kl4YYcptbX2wvm0IWWkj/mw6wlpEytZe+b4hEHXqpe0ISRFsDZVE2F1XVio/XASfwnoCruP68IwTxhdYqt+u8DN7UDML7WJBj6dBIrY/YZgYYbixzFNqGj5EEGiONqf9Ur8GEzumvGPT/NQFMzalQq2M9xTeljEuHoWiBgNxX0tGMxQ1zhKUEN8TS+NUyatAgind/+N3pFrF0lHt/mzt2zaxAM6E5ix9sac="}');
            response.setStatusCode(200);
      
            String continuationLabel = IntegrationEngine.continuationLabel;
 		    List<String> labels = new List<String>{continuationLabel};
            Object continuationState= IntegrationEngine.continuationState;   
            String ppCallOutResponse='';
            system.runAs(u){
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
            ppCallOutResponse = (String)IntegrationEngine.processPPCallOutResponse(labels, IntegrationEngine.continuationState);
            Test.stopTest();
            }
            String responseExpected ='{"body":null,"ResponseData":{"Status":"Success","ResponseInfo":{"SolutionSetInstanceId":"f4a6e08c-12eb-47dd-b611-a39ac30eedc4","ApplicationId":26578322},"Fields":{"Decision":"Pass","ApplicationId":"26578322","ApplicationData":{"Services":{"Service":{"Skip":"N","Name":"PublicDataAPI","Id":"","EnableSimulation":"","Consent":"true"}}},"Applicants":{"Applicant":{"Services":{"Service":[{"Status":"Pass","Operations":{"Operation":[{"Status":"Pass","Params":{"Param":[{"Value":"Y","Name":"consent"},{"Value":"MA2072741184320","Name":"fileNo"}]},"Name":"passport-verification","Id":"","Errors":null,"Data":{"Response":{"RawResponse":"{\\"result\\":{\\"passport-verification\\":{\\"requestId\\":\\"4abf204b-012c-41a4-b7d6-451be3c2a5b1\\",\\"result\\":{\\"name\\":{\\"nameFromPassport\\":\\"DWARAKESH\\",\\"surnameFromPassport\\":\\"RAJAGOPALAN\\",\\"nameMatch\\":true,\\"nameScore\\":1.0},\\"passportNumber\\":{\\"passportNumberFromSource\\":\\"U6926433\\",\\"passportNumberMatch\\":null},\\"dateOfIssue\\":{\\"dispatchedOnFromSource\\":\\"09/01/2020\\",\\"dateOfIssueMatch\\":null},\\"typeOfApplication\\":\\"Normal\\",\\"applicationDate\\":\\"08/01/2020\\"},\\"statusCode\\":101},\\"requestId\\":\\"6fbc0726-7087-46df-8d08-802aeb6f8d2b\\",\\"statusCode\\":\\"101\\"}}"}}}]},"Name":"PublicDataAPI","Id":""}]},"Identifiers":null,"Gender":"M","DateOfBirth":"8021990-01-01T00:00:00.000Z","ApplicantMiddleName":"","ApplicantLastName":" Rajagopalan","ApplicantIdentifier":"096cae9b-d5b4-4b37-903c-22a3121656b5","ApplicantFirstName":"Dwarakesh"}}}},"RequestId":"13122021175530466"}';        
            System.assertEquals(responseExpected,ppCallOutResponse,'Fail');
            }    
        } catch(Exception ex){
            System.assertEquals(ex.getMessage(),'Please enter the Maker Id','Exception');
        }
    }
    
     @isTest
    public static void testINDPassportService2(){
        
        try{              
           
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            Applicant__c applicant = TestDataUtility.createTestApplicantForPassport(false);
            applicant.Opportunity__c=opp.Id;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert applicant;
            }
            
            Documents__c document = TestDataUtility.createTestPPDocs2(false,applicant,opp);
            if (Schema.sObjectType.Documents__c.isCreateable()){
                insert document;
            }
            
            Datetime dOB = (Datetime)document.KYC_DOB__c;
            String dateOfBirth= dOB.format('ddMMyyyy') ;
                       
            String ppCallOutRequest = '{"applicantId":"'+applicant.Id+'" ,"dateOfBirth":"'+dateOfBirth+'" ,"kycPassportNo":"'+document.Passport_No__c+'","kycPassportFileNo":"'+document.Passport_File_No__c+'","firstName":"'+applicant.Customer_First_Name__c+'","lastName":"'+applicant.Customer_Last_Name__c+'","email":"","kycGender":"'+document.Gender__c+'"}';
            Continuation con = (Continuation)IntegrationEngine.doPPCallout(ppCallOutRequest);
            // Create a mock response
        	HttpResponse response = new HttpResponse();
          	response.setBody('{"JData":"vz+0HRIa7MZUAaPO1qm8zJFUf6d4ipIt2F1fh/j48YA63dH9imVJaZtoRrYI+I5D/om00iSdyKPP/JUHHA3uXNI4ftcUPA+WS9Li0rMPcW85wMTx6bnHMuYPga0MS6gV2gFF9nn59YD78G30ZlDaSwaD6kV0oQosZ2nICIfK8BPX7G+gVqU7YXUZfgBAQa8xeNLCnteqgJJLc8ZKfs5GglF+y3SvU5vmg1HeGCnAxv6j/ElRiVd8rWLdqP1/eMQ427WLSgdB+x/V5SGzGeRBLxyW4J36QQfOzbojsF2SAgKsiST4Yokjlf4FXINPQTWkVwc7T0Mu8jQ7x+/B0xAI7Is2B1a0DTkV6BsxGbJ5UpdaNzw0uXDEcY49BLn+8wkNMH+0SycU2UOqAgL5iGmkCVLBkFf0so7SYGenatD/Vfyxv1xDKdhX6FWWW0PBwrJ5o1Kk5e5r4R2Cf81gk/wg1KzFm9FGQCf/SldvknQ5eroDScnih20/zoOXNjYGnSriGpXyRt9LMfg+QQKh7Lv7DgbgkJIChg04tgHPzxEJ4lL7JhYyazPiXVr7uSzW9CYeqftAxObPv394XIvaRuYMnmurSvS3e/iZj7OEb6ZPPRGbhuCvI6T98myGbPqnDDKZbGyv9wmTgtutt9dq/8/vGkDJLwhats25EVUPF6tiiVWuOyBNQQfsS1ZLRBeTonEfOgwMYo3Y3vo8itWuil2lCgCSbQ5t3tsfo61aN1b4EcncPOh9b6t9Zop2OXzQtTvd/qx0A8BR0aMkWIXWX101TEEcHprKLlB+Rd9b2Tc0bFdiKENOwKJUcofP1Fr9y0YJ9hwl/Kyw6DOmoPi65fycAdmpy04oiFnA+2yuahWNsue8oCGFh5zNlZNM69k8erpqrF1kyTACBGHvJtElYgpDGz5np4X+BRDmsjnH5fOefmWzh5ZTQOpEVMjf0FB9vfzUM0BHxk5SY8H7wMwwjC+g9smI0mieH4I1+55o9L6MJd/ZMKbavzJBHtUArmX8u0dc1iI1LTr9zi4+ZRSrtMCCbfO2YK0dVif9A5BU26wPgERLtsZTsY7lU9QZw9tQlKOlmhyqquooFy18YUNY7NfI+G+wHRRS05v5ct+cDsRwHVDjeYVuKIlDI25IgmtIxDg4P/XxRZaSEpvBeZo1xEA7gaMjkaTgC0oWTmMkU/VJ/UxiOv6hz3ZPCvUhEpepHGd/JNLfcyZeCzw5kbnnZfSaTYQ9adTjgTnuyNGppPsogZ5cro/GxUoYhCkj1gOLWLLXhuIXFeqqFQx3d5oBqt6tp/58ba39XGwZ5Gx0+7hWDZXi8Sgq6lFLA4Td+GBeqMDVRrAPvKRmOssI/qwIpRWfkjAo4pI/IZQdv5g3Pc4ok5J6LNBcyA5tWTAhJQ5cSReTbX4J6vb9eTR4u5o3U+M8xwLQh08NahoZm8LR7WUVxmGAAxiF8bLEylKULmYaNTqdbt+Hnwzojrh+DBhQiDPzdlX/3JEkAuBpI/prTvQd/eCnAbJr2LGmSfaxJ6ID9QY7JEA8D06yzFNuHLf/pquAzEq6/vYikjsqha8675Zqq0zvU/Tx5OHnwsaYEH28Ki3RlsdAI8fnX7/tmIBiqGJMXeU2JzfncqmR3xDBCKlaLdNvHZ9iLpOU/bQ0H/1yjsF9zjvy0lzEMJOGsFoOhNqSMjwW+Oju4PIZQiDCcyaxlk2o5SNx+1lgt0zBG2aUU8LY58Y7Qi72Kl4YYcptbX2wvm0IWWkj/mw6wlpEytZe+b4hEHXqpe0ISRFsDZVE2F1XVio/XASfwnoCruP68IwTxhdYqt+u8DN7UDML7WJBj6dBIrY/YZgYYbixzFNqGj5EEGiONqf9Ur8GEzumvGPT/NQFMzalQq2M9xTeljEuHoWiBgNxX0tGMxQ1zhKUEN8TS+NUyatAgind/+N3pFrF0lHt/mzt2zaxAM6E5ix9sac="}');
            response.setStatusCode(200);
      
            String continuationLabel = IntegrationEngine.continuationLabel;
 		    List<String> labels = new List<String>{continuationLabel};
            Object continuationState= IntegrationEngine.continuationState;         
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
            String ppCallOutResponse = (String)IntegrationEngine.processPPCallOutResponse(labels, IntegrationEngine.continuationState);
            Test.stopTest();
            String responseExpected ='{"body":null,"ResponseData":{"Status":"Success","ResponseInfo":{"SolutionSetInstanceId":"f4a6e08c-12eb-47dd-b611-a39ac30eedc4","ApplicationId":26578322},"Fields":{"Decision":"Pass","ApplicationId":"26578322","ApplicationData":{"Services":{"Service":{"Skip":"N","Name":"PublicDataAPI","Id":"","EnableSimulation":"","Consent":"true"}}},"Applicants":{"Applicant":{"Services":{"Service":[{"Status":"Pass","Operations":{"Operation":[{"Status":"Pass","Params":{"Param":[{"Value":"Y","Name":"consent"},{"Value":"MA2072741184320","Name":"fileNo"}]},"Name":"passport-verification","Id":"","Errors":null,"Data":{"Response":{"RawResponse":"{\\"result\\":{\\"passport-verification\\":{\\"requestId\\":\\"4abf204b-012c-41a4-b7d6-451be3c2a5b1\\",\\"result\\":{\\"name\\":{\\"nameFromPassport\\":\\"DWARAKESH\\",\\"surnameFromPassport\\":\\"RAJAGOPALAN\\",\\"nameMatch\\":true,\\"nameScore\\":1.0},\\"passportNumber\\":{\\"passportNumberFromSource\\":\\"U6926433\\",\\"passportNumberMatch\\":null},\\"dateOfIssue\\":{\\"dispatchedOnFromSource\\":\\"09/01/2020\\",\\"dateOfIssueMatch\\":null},\\"typeOfApplication\\":\\"Normal\\",\\"applicationDate\\":\\"08/01/2020\\"},\\"statusCode\\":101},\\"requestId\\":\\"6fbc0726-7087-46df-8d08-802aeb6f8d2b\\",\\"statusCode\\":\\"101\\"}}"}}}]},"Name":"PublicDataAPI","Id":""}]},"Identifiers":null,"Gender":"M","DateOfBirth":"8021990-01-01T00:00:00.000Z","ApplicantMiddleName":"","ApplicantLastName":" Rajagopalan","ApplicantIdentifier":"096cae9b-d5b4-4b37-903c-22a3121656b5","ApplicantFirstName":"Dwarakesh"}}}},"RequestId":"13122021175530466"}';        
            System.assertEquals(responseExpected,ppCallOutResponse,'Fail');
            
        } catch(Exception ex){
            System.assertEquals(ex.getMessage(),'Please enter the Maker Id','Exception');
        }
    }
    
     @isTest
    public static void testINDPassportService3(){
        
        try{              
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            Applicant__c applicant = TestDataUtility.createTestApplicantForPassport(false);
            applicant.Opportunity__c=opp.Id;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert applicant;
            }
            
            Documents__c document = TestDataUtility.createTestPPDocs3(false,applicant,opp);
            if (Schema.sObjectType.Documents__c.isCreateable()){
                insert document;
            }
            
            Datetime dOB = (Datetime)document.KYC_DOB__c;
            String dateOfBirth= dOB.format('ddMMyyyy') ;
                       
            String ppCallOutRequest = '{"applicantId":"'+applicant.Id+'" ,"dateOfBirth":"'+dateOfBirth+'" ,"kycPassportNo":"'+document.Passport_No__c+'","kycPassportFileNo":"'+document.Passport_File_No__c+'","firstName":"'+applicant.Customer_First_Name__c+'","lastName":"'+applicant.Customer_Last_Name__c+'","email":"","kycGender":"'+document.Gender__c+'"}';
             Continuation con = (Continuation)IntegrationEngine.doPPCallout(ppCallOutRequest);
            // Create a mock response
        	HttpResponse response = new HttpResponse();
            response.setBody('{"JData":"vz+0HRIa7MZUAaPO1qm8zJFUf6d4ipIt2F1fh/j48YA63dH9imVJaZtoRrYI+I5D/om00iSdyKPP/JUHHA3uXNI4ftcUPA+WS9Li0rMPcW85wMTx6bnHMuYPga0MS6gV2gFF9nn59YD78G30ZlDaSwaD6kV0oQosZ2nICIfK8BPX7G+gVqU7YXUZfgBAQa8xeNLCnteqgJJLc8ZKfs5GglF+y3SvU5vmg1HeGCnAxv6j/ElRiVd8rWLdqP1/eMQ427WLSgdB+x/V5SGzGeRBLxyW4J36QQfOzbojsF2SAgKsiST4Yokjlf4FXINPQTWkVwc7T0Mu8jQ7x+/B0xAI7Is2B1a0DTkV6BsxGbJ5UpdaNzw0uXDEcY49BLn+8wkNMH+0SycU2UOqAgL5iGmkCVLBkFf0so7SYGenatD/Vfyxv1xDKdhX6FWWW0PBwrJ5o1Kk5e5r4R2Cf81gk/wg1KzFm9FGQCf/SldvknQ5eroDScnih20/zoOXNjYGnSriGpXyRt9LMfg+QQKh7Lv7DgbgkJIChg04tgHPzxEJ4lL7JhYyazPiXVr7uSzW9CYeqftAxObPv394XIvaRuYMnmurSvS3e/iZj7OEb6ZPPRGbhuCvI6T98myGbPqnDDKZbGyv9wmTgtutt9dq/8/vGkDJLwhats25EVUPF6tiiVWuOyBNQQfsS1ZLRBeTonEfOgwMYo3Y3vo8itWuil2lCgCSbQ5t3tsfo61aN1b4EcncPOh9b6t9Zop2OXzQtTvd/qx0A8BR0aMkWIXWX101TEEcHprKLlB+Rd9b2Tc0bFdiKENOwKJUcofP1Fr9y0YJ9hwl/Kyw6DOmoPi65fycAdmpy04oiFnA+2yuahWNsue8oCGFh5zNlZNM69k8erpqrF1kyTACBGHvJtElYgpDGz5np4X+BRDmsjnH5fOefmWzh5ZTQOpEVMjf0FB9vfzUM0BHxk5SY8H7wMwwjC+g9smI0mieH4I1+55o9L6MJd/ZMKbavzJBHtUArmX8u0dc1iI1LTr9zi4+ZRSrtMCCbfO2YK0dVif9A5BU26wPgERLtsZTsY7lU9QZw9tQlKOlmhyqquooFy18YUNY7NfI+G+wHRRS05v5ct+cDsRwHVDjeYVuKIlDI25IgmtIxDg4P/XxRZaSEpvBeZo1xEA7gaMjkaTgC0oWTmMkU/VJ/UxiOv6hz3ZPCvUhEpepHGd/JNLfcyZeCzw5kbnnZfSaTYQ9adTjgTnuyNGppPsogZ5cro/GxUoYhCkj1gOLWLLXhuIXFeqqFQx3d5oBqt6tp/58ba39XGwZ5Gx0+7hWDZXi8Sgq6lFLA4Td+GBeqMDVRrAPvKRmOssI/qwIpRWfkjAo4pI/IZQdv5g3Pc4ok5J6LNBcyA5tWTAhJQ5cSReTbX4J6vb9eTR4u5o3U+M8xwLQh08NahoZm8LR7WUVxmGAAxiF8bLEylKULmYaNTqdbt+Hnwzojrh+DBhQiDPzdlX/3JEkAuBpI/prTvQd/eCnAbJr2LGmSfaxJ6ID9QY7JEA8D06yzFNuHLf/pquAzEq6/vYikjsqha8675Zqq0zvU/Tx5OHnwsaYEH28Ki3RlsdAI8fnX7/tmIBiqGJMXeU2JzfncqmR3xDBCKlaLdNvHZ9iLpOU/bQ0H/1yjsF9zjvy0lzEMJOGsFoOhNqSMjwW+Oju4PIZQiDCcyaxlk2o5SNx+1lgt0zBG2aUU8LY58Y7Qi72Kl4YYcptbX2wvm0IWWkj/mw6wlpEytZe+b4hEHXqpe0ISRFsDZVE2F1XVio/XASfwnoCruP68IwTxhdYqt+u8DN7UDML7WJBj6dBIrY/YZgYYbixzFNqGj5EEGiONqf9Ur8GEzumvGPT/NQFMzalQq2M9xTeljEuHoWiBgNxX0tGMxQ1zhKUEN8TS+NUyatAgind/+N3pFrF0lHt/mzt2zaxAM6E5ix9sac="}');
            response.setStatusCode(200);
      
            String continuationLabel = IntegrationEngine.continuationLabel;
 		    List<String> labels = new List<String>{continuationLabel};
            Object continuationState= IntegrationEngine.continuationState;         
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
            String ppCallOutResponse = (String)IntegrationEngine.processPPCallOutResponse(labels, IntegrationEngine.continuationState);
            Test.stopTest();
            String responseExpected ='{"body":null,"ResponseData":{"Status":"Success","ResponseInfo":{"SolutionSetInstanceId":"f4a6e08c-12eb-47dd-b611-a39ac30eedc4","ApplicationId":26578322},"Fields":{"Decision":"Pass","ApplicationId":"26578322","ApplicationData":{"Services":{"Service":{"Skip":"N","Name":"PublicDataAPI","Id":"","EnableSimulation":"","Consent":"true"}}},"Applicants":{"Applicant":{"Services":{"Service":[{"Status":"Pass","Operations":{"Operation":[{"Status":"Pass","Params":{"Param":[{"Value":"Y","Name":"consent"},{"Value":"MA2072741184320","Name":"fileNo"}]},"Name":"passport-verification","Id":"","Errors":null,"Data":{"Response":{"RawResponse":"{\\"result\\":{\\"passport-verification\\":{\\"requestId\\":\\"4abf204b-012c-41a4-b7d6-451be3c2a5b1\\",\\"result\\":{\\"name\\":{\\"nameFromPassport\\":\\"DWARAKESH\\",\\"surnameFromPassport\\":\\"RAJAGOPALAN\\",\\"nameMatch\\":true,\\"nameScore\\":1.0},\\"passportNumber\\":{\\"passportNumberFromSource\\":\\"U6926433\\",\\"passportNumberMatch\\":null},\\"dateOfIssue\\":{\\"dispatchedOnFromSource\\":\\"09/01/2020\\",\\"dateOfIssueMatch\\":null},\\"typeOfApplication\\":\\"Normal\\",\\"applicationDate\\":\\"08/01/2020\\"},\\"statusCode\\":101},\\"requestId\\":\\"6fbc0726-7087-46df-8d08-802aeb6f8d2b\\",\\"statusCode\\":\\"101\\"}}"}}}]},"Name":"PublicDataAPI","Id":""}]},"Identifiers":null,"Gender":"M","DateOfBirth":"8021990-01-01T00:00:00.000Z","ApplicantMiddleName":"","ApplicantLastName":" Rajagopalan","ApplicantIdentifier":"096cae9b-d5b4-4b37-903c-22a3121656b5","ApplicantFirstName":"Dwarakesh"}}}},"RequestId":"13122021175530466"}';        
            System.assertEquals(responseExpected,ppCallOutResponse,'Success');
            
        } catch(Exception ex){
            System.assertEquals(ex.getMessage(),'Please enter the Maker Id','Exception');
        }
    }
    
     @isTest
    public static void testINDPassportService4(){
        
        try{              
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            Applicant__c applicant = TestDataUtility.createTestApplicantForPassport(false);
            applicant.Opportunity__c=opp.Id;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert applicant;
            }
            
            Documents__c document = TestDataUtility.createTestPPDocs4(false,applicant,opp);
            if (Schema.sObjectType.Documents__c.isCreateable()){
                insert document;
            }
            
            Datetime dOB = (Datetime)document.KYC_DOB__c;
            String dateOfBirth= dOB.format('ddMMyyyy') ;
                       
            String ppCallOutRequest = '{"applicantId":"'+applicant.Id+'" ,"dateOfBirth":"'+dateOfBirth+'" ,"kycPassportNo":"'+document.Passport_No__c+'","kycPassportFileNo":"'+document.Passport_File_No__c+'","firstName":"'+applicant.Customer_First_Name__c+'","lastName":"'+applicant.Customer_Last_Name__c+'","email":"","kycGender":"'+document.Gender__c+'"}';
              Continuation con = (Continuation)IntegrationEngine.doPPCallout(ppCallOutRequest);
            // Create a mock response
        	HttpResponse response = new HttpResponse();
            response.setBody('{"JData":"vz+0HRIa7MZUAaPO1qm8zJFUf6d4ipIt2F1fh/j48YA63dH9imVJaZtoRrYI+I5D/om00iSdyKPP/JUHHA3uXNI4ftcUPA+WS9Li0rMPcW85wMTx6bnHMuYPga0MS6gV2gFF9nn59YD78G30ZlDaSwaD6kV0oQosZ2nICIfK8BPX7G+gVqU7YXUZfgBAQa8xeNLCnteqgJJLc8ZKfs5GglF+y3SvU5vmg1HeGCnAxv6j/ElRiVd8rWLdqP1/eMQ427WLSgdB+x/V5SGzGeRBLxyW4J36QQfOzbojsF2SAgKsiST4Yokjlf4FXINPQTWkVwc7T0Mu8jQ7x+/B0xAI7Is2B1a0DTkV6BsxGbJ5UpdaNzw0uXDEcY49BLn+8wkNMH+0SycU2UOqAgL5iGmkCVLBkFf0so7SYGenatD/Vfyxv1xDKdhX6FWWW0PBwrJ5o1Kk5e5r4R2Cf81gk/wg1KzFm9FGQCf/SldvknQ5eroDScnih20/zoOXNjYGnSriGpXyRt9LMfg+QQKh7Lv7DgbgkJIChg04tgHPzxEJ4lL7JhYyazPiXVr7uSzW9CYeqftAxObPv394XIvaRuYMnmurSvS3e/iZj7OEb6ZPPRGbhuCvI6T98myGbPqnDDKZbGyv9wmTgtutt9dq/8/vGkDJLwhats25EVUPF6tiiVWuOyBNQQfsS1ZLRBeTonEfOgwMYo3Y3vo8itWuil2lCgCSbQ5t3tsfo61aN1b4EcncPOh9b6t9Zop2OXzQtTvd/qx0A8BR0aMkWIXWX101TEEcHprKLlB+Rd9b2Tc0bFdiKENOwKJUcofP1Fr9y0YJ9hwl/Kyw6DOmoPi65fycAdmpy04oiFnA+2yuahWNsue8oCGFh5zNlZNM69k8erpqrF1kyTACBGHvJtElYgpDGz5np4X+BRDmsjnH5fOefmWzh5ZTQOpEVMjf0FB9vfzUM0BHxk5SY8H7wMwwjC+g9smI0mieH4I1+55o9L6MJd/ZMKbavzJBHtUArmX8u0dc1iI1LTr9zi4+ZRSrtMCCbfO2YK0dVif9A5BU26wPgERLtsZTsY7lU9QZw9tQlKOlmhyqquooFy18YUNY7NfI+G+wHRRS05v5ct+cDsRwHVDjeYVuKIlDI25IgmtIxDg4P/XxRZaSEpvBeZo1xEA7gaMjkaTgC0oWTmMkU/VJ/UxiOv6hz3ZPCvUhEpepHGd/JNLfcyZeCzw5kbnnZfSaTYQ9adTjgTnuyNGppPsogZ5cro/GxUoYhCkj1gOLWLLXhuIXFeqqFQx3d5oBqt6tp/58ba39XGwZ5Gx0+7hWDZXi8Sgq6lFLA4Td+GBeqMDVRrAPvKRmOssI/qwIpRWfkjAo4pI/IZQdv5g3Pc4ok5J6LNBcyA5tWTAhJQ5cSReTbX4J6vb9eTR4u5o3U+M8xwLQh08NahoZm8LR7WUVxmGAAxiF8bLEylKULmYaNTqdbt+Hnwzojrh+DBhQiDPzdlX/3JEkAuBpI/prTvQd/eCnAbJr2LGmSfaxJ6ID9QY7JEA8D06yzFNuHLf/pquAzEq6/vYikjsqha8675Zqq0zvU/Tx5OHnwsaYEH28Ki3RlsdAI8fnX7/tmIBiqGJMXeU2JzfncqmR3xDBCKlaLdNvHZ9iLpOU/bQ0H/1yjsF9zjvy0lzEMJOGsFoOhNqSMjwW+Oju4PIZQiDCcyaxlk2o5SNx+1lgt0zBG2aUU8LY58Y7Qi72Kl4YYcptbX2wvm0IWWkj/mw6wlpEytZe+b4hEHXqpe0ISRFsDZVE2F1XVio/XASfwnoCruP68IwTxhdYqt+u8DN7UDML7WJBj6dBIrY/YZgYYbixzFNqGj5EEGiONqf9Ur8GEzumvGPT/NQFMzalQq2M9xTeljEuHoWiBgNxX0tGMxQ1zhKUEN8TS+NUyatAgind/+N3pFrF0lHt/mzt2zaxAM6E5ix9sac="}');
            response.setStatusCode(200);
      
            String continuationLabel = IntegrationEngine.continuationLabel;
 		    List<String> labels = new List<String>{continuationLabel};
            Object continuationState= IntegrationEngine.continuationState;         
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
             String ppCallOutResponse = (String)IntegrationEngine.processPPCallOutResponse(labels, IntegrationEngine.continuationState);
            Test.stopTest();
            String responseExpected ='{"body":null,"ResponseData":{"Status":"Success","ResponseInfo":{"SolutionSetInstanceId":"f4a6e08c-12eb-47dd-b611-a39ac30eedc4","ApplicationId":26578322},"Fields":{"Decision":"Pass","ApplicationId":"26578322","ApplicationData":{"Services":{"Service":{"Skip":"N","Name":"PublicDataAPI","Id":"","EnableSimulation":"","Consent":"true"}}},"Applicants":{"Applicant":{"Services":{"Service":[{"Status":"Pass","Operations":{"Operation":[{"Status":"Pass","Params":{"Param":[{"Value":"Y","Name":"consent"},{"Value":"MA2072741184320","Name":"fileNo"}]},"Name":"passport-verification","Id":"","Errors":null,"Data":{"Response":{"RawResponse":"{\\"result\\":{\\"passport-verification\\":{\\"requestId\\":\\"4abf204b-012c-41a4-b7d6-451be3c2a5b1\\",\\"result\\":{\\"name\\":{\\"nameFromPassport\\":\\"DWARAKESH\\",\\"surnameFromPassport\\":\\"RAJAGOPALAN\\",\\"nameMatch\\":true,\\"nameScore\\":1.0},\\"passportNumber\\":{\\"passportNumberFromSource\\":\\"U6926433\\",\\"passportNumberMatch\\":null},\\"dateOfIssue\\":{\\"dispatchedOnFromSource\\":\\"09/01/2020\\",\\"dateOfIssueMatch\\":null},\\"typeOfApplication\\":\\"Normal\\",\\"applicationDate\\":\\"08/01/2020\\"},\\"statusCode\\":101},\\"requestId\\":\\"6fbc0726-7087-46df-8d08-802aeb6f8d2b\\",\\"statusCode\\":\\"101\\"}}"}}}]},"Name":"PublicDataAPI","Id":""}]},"Identifiers":null,"Gender":"M","DateOfBirth":"8021990-01-01T00:00:00.000Z","ApplicantMiddleName":"","ApplicantLastName":" Rajagopalan","ApplicantIdentifier":"096cae9b-d5b4-4b37-903c-22a3121656b5","ApplicantFirstName":"Dwarakesh"}}}},"RequestId":"13122021175530466"}';        
            System.assertEquals(responseExpected,ppCallOutResponse,'Fail');
            
        } catch(Exception ex){
            System.assertEquals(ex.getMessage(),System.Label.FileNo,'Exception');
        }
    }
    
     @isTest
    public static void testINDPassportService5(){
        
        try{              
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            Applicant__c applicant = TestDataUtility.createTestApplicantForPassport(false);
            applicant.Opportunity__c=opp.Id;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert applicant;
            }
            
            Documents__c document = TestDataUtility.createTestPPDocs5(false,applicant,opp);
            if (Schema.sObjectType.Documents__c.isCreateable()){
                insert document;
            }
            
            Datetime dOB = (Datetime)document.KYC_DOB__c;
            String dateOfBirth= dOB.format('ddMMyyyy') ;
                       
            String ppCallOutRequest = '{"applicantId":"'+applicant.Id+'" ,"dateOfBirth":"'+dateOfBirth+'" ,"kycPassportNo":"'+document.Passport_No__c+'","kycPassportFileNo":"'+document.Passport_File_No__c+'","firstName":"'+applicant.Customer_First_Name__c+'","lastName":"'+applicant.Customer_Last_Name__c+'","email":"","kycGender":"'+document.Gender__c+'"}';
              Continuation con = (Continuation)IntegrationEngine.doPPCallout(ppCallOutRequest);
            // Create a mock response
        	HttpResponse response = new HttpResponse();
            response.setBody('{"JData":"vz+0HRIa7MZUAaPO1qm8zJFUf6d4ipIt2F1fh/j48YA63dH9imVJaZtoRrYI+I5D/om00iSdyKPP/JUHHA3uXNI4ftcUPA+WS9Li0rMPcW85wMTx6bnHMuYPga0MS6gV2gFF9nn59YD78G30ZlDaSwaD6kV0oQosZ2nICIfK8BPX7G+gVqU7YXUZfgBAQa8xeNLCnteqgJJLc8ZKfs5GglF+y3SvU5vmg1HeGCnAxv6j/ElRiVd8rWLdqP1/eMQ427WLSgdB+x/V5SGzGeRBLxyW4J36QQfOzbojsF2SAgKsiST4Yokjlf4FXINPQTWkVwc7T0Mu8jQ7x+/B0xAI7Is2B1a0DTkV6BsxGbJ5UpdaNzw0uXDEcY49BLn+8wkNMH+0SycU2UOqAgL5iGmkCVLBkFf0so7SYGenatD/Vfyxv1xDKdhX6FWWW0PBwrJ5o1Kk5e5r4R2Cf81gk/wg1KzFm9FGQCf/SldvknQ5eroDScnih20/zoOXNjYGnSriGpXyRt9LMfg+QQKh7Lv7DgbgkJIChg04tgHPzxEJ4lL7JhYyazPiXVr7uSzW9CYeqftAxObPv394XIvaRuYMnmurSvS3e/iZj7OEb6ZPPRGbhuCvI6T98myGbPqnDDKZbGyv9wmTgtutt9dq/8/vGkDJLwhats25EVUPF6tiiVWuOyBNQQfsS1ZLRBeTonEfOgwMYo3Y3vo8itWuil2lCgCSbQ5t3tsfo61aN1b4EcncPOh9b6t9Zop2OXzQtTvd/qx0A8BR0aMkWIXWX101TEEcHprKLlB+Rd9b2Tc0bFdiKENOwKJUcofP1Fr9y0YJ9hwl/Kyw6DOmoPi65fycAdmpy04oiFnA+2yuahWNsue8oCGFh5zNlZNM69k8erpqrF1kyTACBGHvJtElYgpDGz5np4X+BRDmsjnH5fOefmWzh5ZTQOpEVMjf0FB9vfzUM0BHxk5SY8H7wMwwjC+g9smI0mieH4I1+55o9L6MJd/ZMKbavzJBHtUArmX8u0dc1iI1LTr9zi4+ZRSrtMCCbfO2YK0dVif9A5BU26wPgERLtsZTsY7lU9QZw9tQlKOlmhyqquooFy18YUNY7NfI+G+wHRRS05v5ct+cDsRwHVDjeYVuKIlDI25IgmtIxDg4P/XxRZaSEpvBeZo1xEA7gaMjkaTgC0oWTmMkU/VJ/UxiOv6hz3ZPCvUhEpepHGd/JNLfcyZeCzw5kbnnZfSaTYQ9adTjgTnuyNGppPsogZ5cro/GxUoYhCkj1gOLWLLXhuIXFeqqFQx3d5oBqt6tp/58ba39XGwZ5Gx0+7hWDZXi8Sgq6lFLA4Td+GBeqMDVRrAPvKRmOssI/qwIpRWfkjAo4pI/IZQdv5g3Pc4ok5J6LNBcyA5tWTAhJQ5cSReTbX4J6vb9eTR4u5o3U+M8xwLQh08NahoZm8LR7WUVxmGAAxiF8bLEylKULmYaNTqdbt+Hnwzojrh+DBhQiDPzdlX/3JEkAuBpI/prTvQd/eCnAbJr2LGmSfaxJ6ID9QY7JEA8D06yzFNuHLf/pquAzEq6/vYikjsqha8675Zqq0zvU/Tx5OHnwsaYEH28Ki3RlsdAI8fnX7/tmIBiqGJMXeU2JzfncqmR3xDBCKlaLdNvHZ9iLpOU/bQ0H/1yjsF9zjvy0lzEMJOGsFoOhNqSMjwW+Oju4PIZQiDCcyaxlk2o5SNx+1lgt0zBG2aUU8LY58Y7Qi72Kl4YYcptbX2wvm0IWWkj/mw6wlpEytZe+b4hEHXqpe0ISRFsDZVE2F1XVio/XASfwnoCruP68IwTxhdYqt+u8DN7UDML7WJBj6dBIrY/YZgYYbixzFNqGj5EEGiONqf9Ur8GEzumvGPT/NQFMzalQq2M9xTeljEuHoWiBgNxX0tGMxQ1zhKUEN8TS+NUyatAgind/+N3pFrF0lHt/mzt2zaxAM6E5ix9sac="}');
            response.setStatusCode(200);
      
            String continuationLabel = IntegrationEngine.continuationLabel;
 		    List<String> labels = new List<String>{continuationLabel};
            Object continuationState= IntegrationEngine.continuationState;         
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
            String ppCallOutResponse = (String)IntegrationEngine.processPPCallOutResponse(labels, IntegrationEngine.continuationState);
            Test.stopTest();
            String responseExpected ='{"body":null,"ResponseData":{"Status":"Success","ResponseInfo":{"SolutionSetInstanceId":"f4a6e08c-12eb-47dd-b611-a39ac30eedc4","ApplicationId":26578322},"Fields":{"Decision":"Pass","ApplicationId":"26578322","ApplicationData":{"Services":{"Service":{"Skip":"N","Name":"PublicDataAPI","Id":"","EnableSimulation":"","Consent":"true"}}},"Applicants":{"Applicant":{"Services":{"Service":[{"Status":"Pass","Operations":{"Operation":[{"Status":"Pass","Params":{"Param":[{"Value":"Y","Name":"consent"},{"Value":"MA2072741184320","Name":"fileNo"}]},"Name":"passport-verification","Id":"","Errors":null,"Data":{"Response":{"RawResponse":"{\\"result\\":{\\"passport-verification\\":{\\"requestId\\":\\"4abf204b-012c-41a4-b7d6-451be3c2a5b1\\",\\"result\\":{\\"name\\":{\\"nameFromPassport\\":\\"DWARAKESH\\",\\"surnameFromPassport\\":\\"RAJAGOPALAN\\",\\"nameMatch\\":true,\\"nameScore\\":1.0},\\"passportNumber\\":{\\"passportNumberFromSource\\":\\"U6926433\\",\\"passportNumberMatch\\":null},\\"dateOfIssue\\":{\\"dispatchedOnFromSource\\":\\"09/01/2020\\",\\"dateOfIssueMatch\\":null},\\"typeOfApplication\\":\\"Normal\\",\\"applicationDate\\":\\"08/01/2020\\"},\\"statusCode\\":101},\\"requestId\\":\\"6fbc0726-7087-46df-8d08-802aeb6f8d2b\\",\\"statusCode\\":\\"101\\"}}"}}}]},"Name":"PublicDataAPI","Id":""}]},"Identifiers":null,"Gender":"M","DateOfBirth":"8021990-01-01T00:00:00.000Z","ApplicantMiddleName":"","ApplicantLastName":" Rajagopalan","ApplicantIdentifier":"096cae9b-d5b4-4b37-903c-22a3121656b5","ApplicantFirstName":"Dwarakesh"}}}},"RequestId":"13122021175530466"}';        
            System.assertEquals(responseExpected,ppCallOutResponse,'Fail');
            
        } catch(Exception ex){
            System.assertEquals(ex.getMessage(),System.Label.PassportNumber,'Exception');
        }
    }
    
     @isTest
    public static void testINDPassportService6(){
        
        try{              
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            Applicant__c applicant = TestDataUtility.createTestApplicantForPassport(false);
            applicant.Opportunity__c=opp.Id;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert applicant;
            }
            
            Documents__c document = TestDataUtility.createTestPPDocs6(false,applicant,opp);
            if (Schema.sObjectType.Documents__c.isCreateable()){
                insert document;
            }
            
            Datetime dOB = (Datetime)document.KYC_DOB__c;
            String dateOfBirth= dOB.format('ddMMyyyy') ;
                       
            String ppCallOutRequest = '{"applicantId":"'+applicant.Id+'" ,"dateOfBirth":"'+dateOfBirth+'" ,"kycPassportNo":"'+document.Passport_No__c+'","kycPassportFileNo":"'+document.Passport_File_No__c+'","firstName":"'+applicant.Customer_First_Name__c+'","lastName":"'+applicant.Customer_Last_Name__c+'","email":"","kycGender":"'+document.Gender__c+'"}';
             Continuation con = (Continuation)IntegrationEngine.doPPCallout(ppCallOutRequest);
            // Create a mock response
        	HttpResponse response = new HttpResponse();
            response.setBody('{"JData":"vz+0HRIa7MZUAaPO1qm8zJFUf6d4ipIt2F1fh/j48YA63dH9imVJaZtoRrYI+I5D/om00iSdyKPP/JUHHA3uXNI4ftcUPA+WS9Li0rMPcW85wMTx6bnHMuYPga0MS6gV2gFF9nn59YD78G30ZlDaSwaD6kV0oQosZ2nICIfK8BPX7G+gVqU7YXUZfgBAQa8xeNLCnteqgJJLc8ZKfs5GglF+y3SvU5vmg1HeGCnAxv6j/ElRiVd8rWLdqP1/eMQ427WLSgdB+x/V5SGzGeRBLxyW4J36QQfOzbojsF2SAgKsiST4Yokjlf4FXINPQTWkVwc7T0Mu8jQ7x+/B0xAI7Is2B1a0DTkV6BsxGbJ5UpdaNzw0uXDEcY49BLn+8wkNMH+0SycU2UOqAgL5iGmkCVLBkFf0so7SYGenatD/Vfyxv1xDKdhX6FWWW0PBwrJ5o1Kk5e5r4R2Cf81gk/wg1KzFm9FGQCf/SldvknQ5eroDScnih20/zoOXNjYGnSriGpXyRt9LMfg+QQKh7Lv7DgbgkJIChg04tgHPzxEJ4lL7JhYyazPiXVr7uSzW9CYeqftAxObPv394XIvaRuYMnmurSvS3e/iZj7OEb6ZPPRGbhuCvI6T98myGbPqnDDKZbGyv9wmTgtutt9dq/8/vGkDJLwhats25EVUPF6tiiVWuOyBNQQfsS1ZLRBeTonEfOgwMYo3Y3vo8itWuil2lCgCSbQ5t3tsfo61aN1b4EcncPOh9b6t9Zop2OXzQtTvd/qx0A8BR0aMkWIXWX101TEEcHprKLlB+Rd9b2Tc0bFdiKENOwKJUcofP1Fr9y0YJ9hwl/Kyw6DOmoPi65fycAdmpy04oiFnA+2yuahWNsue8oCGFh5zNlZNM69k8erpqrF1kyTACBGHvJtElYgpDGz5np4X+BRDmsjnH5fOefmWzh5ZTQOpEVMjf0FB9vfzUM0BHxk5SY8H7wMwwjC+g9smI0mieH4I1+55o9L6MJd/ZMKbavzJBHtUArmX8u0dc1iI1LTr9zi4+ZRSrtMCCbfO2YK0dVif9A5BU26wPgERLtsZTsY7lU9QZw9tQlKOlmhyqquooFy18YUNY7NfI+G+wHRRS05v5ct+cDsRwHVDjeYVuKIlDI25IgmtIxDg4P/XxRZaSEpvBeZo1xEA7gaMjkaTgC0oWTmMkU/VJ/UxiOv6hz3ZPCvUhEpepHGd/JNLfcyZeCzw5kbnnZfSaTYQ9adTjgTnuyNGppPsogZ5cro/GxUoYhCkj1gOLWLLXhuIXFeqqFQx3d5oBqt6tp/58ba39XGwZ5Gx0+7hWDZXi8Sgq6lFLA4Td+GBeqMDVRrAPvKRmOssI/qwIpRWfkjAo4pI/IZQdv5g3Pc4ok5J6LNBcyA5tWTAhJQ5cSReTbX4J6vb9eTR4u5o3U+M8xwLQh08NahoZm8LR7WUVxmGAAxiF8bLEylKULmYaNTqdbt+Hnwzojrh+DBhQiDPzdlX/3JEkAuBpI/prTvQd/eCnAbJr2LGmSfaxJ6ID9QY7JEA8D06yzFNuHLf/pquAzEq6/vYikjsqha8675Zqq0zvU/Tx5OHnwsaYEH28Ki3RlsdAI8fnX7/tmIBiqGJMXeU2JzfncqmR3xDBCKlaLdNvHZ9iLpOU/bQ0H/1yjsF9zjvy0lzEMJOGsFoOhNqSMjwW+Oju4PIZQiDCcyaxlk2o5SNx+1lgt0zBG2aUU8LY58Y7Qi72Kl4YYcptbX2wvm0IWWkj/mw6wlpEytZe+b4hEHXqpe0ISRFsDZVE2F1XVio/XASfwnoCruP68IwTxhdYqt+u8DN7UDML7WJBj6dBIrY/YZgYYbixzFNqGj5EEGiONqf9Ur8GEzumvGPT/NQFMzalQq2M9xTeljEuHoWiBgNxX0tGMxQ1zhKUEN8TS+NUyatAgind/+N3pFrF0lHt/mzt2zaxAM6E5ix9sac="}');
            response.setStatusCode(200);
      
            String continuationLabel = IntegrationEngine.continuationLabel;
 		    List<String> labels = new List<String>{continuationLabel};
            Object continuationState= IntegrationEngine.continuationState;         
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
             String ppCallOutResponse = (String)IntegrationEngine.processPPCallOutResponse(labels, IntegrationEngine.continuationState);
            Test.stopTest();
            String responseExpected ='{"body":null,"ResponseData":{"Status":"Success","ResponseInfo":{"SolutionSetInstanceId":"f4a6e08c-12eb-47dd-b611-a39ac30eedc4","ApplicationId":26578322},"Fields":{"Decision":"Pass","ApplicationId":"26578322","ApplicationData":{"Services":{"Service":{"Skip":"N","Name":"PublicDataAPI","Id":"","EnableSimulation":"","Consent":"true"}}},"Applicants":{"Applicant":{"Services":{"Service":[{"Status":"Pass","Operations":{"Operation":[{"Status":"Pass","Params":{"Param":[{"Value":"Y","Name":"consent"},{"Value":"MA2072741184320","Name":"fileNo"}]},"Name":"passport-verification","Id":"","Errors":null,"Data":{"Response":{"RawResponse":"{\\"result\\":{\\"passport-verification\\":{\\"requestId\\":\\"4abf204b-012c-41a4-b7d6-451be3c2a5b1\\",\\"result\\":{\\"name\\":{\\"nameFromPassport\\":\\"DWARAKESH\\",\\"surnameFromPassport\\":\\"RAJAGOPALAN\\",\\"nameMatch\\":true,\\"nameScore\\":1.0},\\"passportNumber\\":{\\"passportNumberFromSource\\":\\"U6926433\\",\\"passportNumberMatch\\":null},\\"dateOfIssue\\":{\\"dispatchedOnFromSource\\":\\"09/01/2020\\",\\"dateOfIssueMatch\\":null},\\"typeOfApplication\\":\\"Normal\\",\\"applicationDate\\":\\"08/01/2020\\"},\\"statusCode\\":101},\\"requestId\\":\\"6fbc0726-7087-46df-8d08-802aeb6f8d2b\\",\\"statusCode\\":\\"101\\"}}"}}}]},"Name":"PublicDataAPI","Id":""}]},"Identifiers":null,"Gender":"M","DateOfBirth":"8021990-01-01T00:00:00.000Z","ApplicantMiddleName":"","ApplicantLastName":" Rajagopalan","ApplicantIdentifier":"096cae9b-d5b4-4b37-903c-22a3121656b5","ApplicantFirstName":"Dwarakesh"}}}},"RequestId":"13122021175530466"}';        
            System.assertEquals(responseExpected,ppCallOutResponse,'Fail');
            
        } catch(Exception ex){
            System.assertEquals(ex.getMessage(),System.Label.Gender,'Exception');
        }
    }
    
     @isTest
    public static void testINDPassportService7(){
        
        try{              
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            Applicant__c applicant = TestDataUtility.createTestApplicantForPassport(false);
            applicant.Opportunity__c=opp.Id;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert applicant;
            }
            
            Documents__c document = TestDataUtility.createTestPPDocs7(false,applicant,opp);
            if (Schema.sObjectType.Documents__c.isCreateable()){
                insert document;
            }
            
            Datetime dOB = (Datetime)document.KYC_DOB__c;
            String dateOfBirth='';
            if(dOB!=null){
            dateOfBirth= dOB.format('ddMMyyyy') ;
            }   
            String ppCallOutRequest = '{"applicantId":"'+applicant.Id+'" ,"dateOfBirth":"'+dateOfBirth+'" ,"kycPassportNo":"'+document.Passport_No__c+'","kycPassportFileNo":"'+document.Passport_File_No__c+'","firstName":"'+applicant.Customer_First_Name__c+'","lastName":"'+applicant.Customer_Last_Name__c+'","email":"","kycGender":"'+document.Gender__c+'"}';
   			Continuation con = (Continuation)IntegrationEngine.doPPCallout(ppCallOutRequest);
            // Create a mock response
        	HttpResponse response = new HttpResponse();
            response.setBody('{"JData":"vz+0HRIa7MZUAaPO1qm8zJFUf6d4ipIt2F1fh/j48YA63dH9imVJaZtoRrYI+I5D/om00iSdyKPP/JUHHA3uXNI4ftcUPA+WS9Li0rMPcW85wMTx6bnHMuYPga0MS6gV2gFF9nn59YD78G30ZlDaSwaD6kV0oQosZ2nICIfK8BPX7G+gVqU7YXUZfgBAQa8xeNLCnteqgJJLc8ZKfs5GglF+y3SvU5vmg1HeGCnAxv6j/ElRiVd8rWLdqP1/eMQ427WLSgdB+x/V5SGzGeRBLxyW4J36QQfOzbojsF2SAgKsiST4Yokjlf4FXINPQTWkVwc7T0Mu8jQ7x+/B0xAI7Is2B1a0DTkV6BsxGbJ5UpdaNzw0uXDEcY49BLn+8wkNMH+0SycU2UOqAgL5iGmkCVLBkFf0so7SYGenatD/Vfyxv1xDKdhX6FWWW0PBwrJ5o1Kk5e5r4R2Cf81gk/wg1KzFm9FGQCf/SldvknQ5eroDScnih20/zoOXNjYGnSriGpXyRt9LMfg+QQKh7Lv7DgbgkJIChg04tgHPzxEJ4lL7JhYyazPiXVr7uSzW9CYeqftAxObPv394XIvaRuYMnmurSvS3e/iZj7OEb6ZPPRGbhuCvI6T98myGbPqnDDKZbGyv9wmTgtutt9dq/8/vGkDJLwhats25EVUPF6tiiVWuOyBNQQfsS1ZLRBeTonEfOgwMYo3Y3vo8itWuil2lCgCSbQ5t3tsfo61aN1b4EcncPOh9b6t9Zop2OXzQtTvd/qx0A8BR0aMkWIXWX101TEEcHprKLlB+Rd9b2Tc0bFdiKENOwKJUcofP1Fr9y0YJ9hwl/Kyw6DOmoPi65fycAdmpy04oiFnA+2yuahWNsue8oCGFh5zNlZNM69k8erpqrF1kyTACBGHvJtElYgpDGz5np4X+BRDmsjnH5fOefmWzh5ZTQOpEVMjf0FB9vfzUM0BHxk5SY8H7wMwwjC+g9smI0mieH4I1+55o9L6MJd/ZMKbavzJBHtUArmX8u0dc1iI1LTr9zi4+ZRSrtMCCbfO2YK0dVif9A5BU26wPgERLtsZTsY7lU9QZw9tQlKOlmhyqquooFy18YUNY7NfI+G+wHRRS05v5ct+cDsRwHVDjeYVuKIlDI25IgmtIxDg4P/XxRZaSEpvBeZo1xEA7gaMjkaTgC0oWTmMkU/VJ/UxiOv6hz3ZPCvUhEpepHGd/JNLfcyZeCzw5kbnnZfSaTYQ9adTjgTnuyNGppPsogZ5cro/GxUoYhCkj1gOLWLLXhuIXFeqqFQx3d5oBqt6tp/58ba39XGwZ5Gx0+7hWDZXi8Sgq6lFLA4Td+GBeqMDVRrAPvKRmOssI/qwIpRWfkjAo4pI/IZQdv5g3Pc4ok5J6LNBcyA5tWTAhJQ5cSReTbX4J6vb9eTR4u5o3U+M8xwLQh08NahoZm8LR7WUVxmGAAxiF8bLEylKULmYaNTqdbt+Hnwzojrh+DBhQiDPzdlX/3JEkAuBpI/prTvQd/eCnAbJr2LGmSfaxJ6ID9QY7JEA8D06yzFNuHLf/pquAzEq6/vYikjsqha8675Zqq0zvU/Tx5OHnwsaYEH28Ki3RlsdAI8fnX7/tmIBiqGJMXeU2JzfncqmR3xDBCKlaLdNvHZ9iLpOU/bQ0H/1yjsF9zjvy0lzEMJOGsFoOhNqSMjwW+Oju4PIZQiDCcyaxlk2o5SNx+1lgt0zBG2aUU8LY58Y7Qi72Kl4YYcptbX2wvm0IWWkj/mw6wlpEytZe+b4hEHXqpe0ISRFsDZVE2F1XVio/XASfwnoCruP68IwTxhdYqt+u8DN7UDML7WJBj6dBIrY/YZgYYbixzFNqGj5EEGiONqf9Ur8GEzumvGPT/NQFMzalQq2M9xTeljEuHoWiBgNxX0tGMxQ1zhKUEN8TS+NUyatAgind/+N3pFrF0lHt/mzt2zaxAM6E5ix9sac="}');
            response.setStatusCode(200);
      
            String continuationLabel = IntegrationEngine.continuationLabel;
 		    List<String> labels = new List<String>{continuationLabel};
            Object continuationState= IntegrationEngine.continuationState;         
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
             String ppCallOutResponse = (String)IntegrationEngine.processPPCallOutResponse(labels, IntegrationEngine.continuationState);
            Test.stopTest();
            String responseExpected ='{"body":null,"ResponseData":{"Status":"Success","ResponseInfo":{"SolutionSetInstanceId":"f4a6e08c-12eb-47dd-b611-a39ac30eedc4","ApplicationId":26578322},"Fields":{"Decision":"Pass","ApplicationId":"26578322","ApplicationData":{"Services":{"Service":{"Skip":"N","Name":"PublicDataAPI","Id":"","EnableSimulation":"","Consent":"true"}}},"Applicants":{"Applicant":{"Services":{"Service":[{"Status":"Pass","Operations":{"Operation":[{"Status":"Pass","Params":{"Param":[{"Value":"Y","Name":"consent"},{"Value":"MA2072741184320","Name":"fileNo"}]},"Name":"passport-verification","Id":"","Errors":null,"Data":{"Response":{"RawResponse":"{\\"result\\":{\\"passport-verification\\":{\\"requestId\\":\\"4abf204b-012c-41a4-b7d6-451be3c2a5b1\\",\\"result\\":{\\"name\\":{\\"nameFromPassport\\":\\"DWARAKESH\\",\\"surnameFromPassport\\":\\"RAJAGOPALAN\\",\\"nameMatch\\":true,\\"nameScore\\":1.0},\\"passportNumber\\":{\\"passportNumberFromSource\\":\\"U6926433\\",\\"passportNumberMatch\\":null},\\"dateOfIssue\\":{\\"dispatchedOnFromSource\\":\\"09/01/2020\\",\\"dateOfIssueMatch\\":null},\\"typeOfApplication\\":\\"Normal\\",\\"applicationDate\\":\\"08/01/2020\\"},\\"statusCode\\":101},\\"requestId\\":\\"6fbc0726-7087-46df-8d08-802aeb6f8d2b\\",\\"statusCode\\":\\"101\\"}}"}}}]},"Name":"PublicDataAPI","Id":""}]},"Identifiers":null,"Gender":"M","DateOfBirth":"8021990-01-01T00:00:00.000Z","ApplicantMiddleName":"","ApplicantLastName":" Rajagopalan","ApplicantIdentifier":"096cae9b-d5b4-4b37-903c-22a3121656b5","ApplicantFirstName":"Dwarakesh"}}}},"RequestId":"13122021175530466"}';        
            System.assertEquals(responseExpected,ppCallOutResponse,'Fail');
            
        } catch(Exception ex){
            System.assertEquals(ex.getMessage(),System.Label.DateOfBirth,'Exception');
        }
    }
    
     @isTest
    public static void testINDPassportService8(){
        
        try{              
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            Applicant__c applicant = TestDataUtility.createTestApplicantForPassport2(false);
            applicant.Opportunity__c=opp.Id;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert applicant;
            }
            
            Documents__c document = TestDataUtility.createTestPPDocs(false,applicant,opp);
            if (Schema.sObjectType.Documents__c.isCreateable()){
                insert document;
            }
            
            Datetime dOB = (Datetime)document.KYC_DOB__c;
            String dateOfBirth= dOB.format('ddMMyyyy') ;
            String ppCallOutRequest='';
            if(applicant.Customer_Last_Name__c==null){
			ppCallOutRequest = '{"applicantId":"'+applicant.Id+'" ,"dateOfBirth":"'+dateOfBirth+'" ,"kycPassportNo":"'+document.Passport_No__c+'","kycPassportFileNo":"'+document.Passport_File_No__c+'","firstName":"'+applicant.Customer_First_Name__c+'","lastName":"","email":"","kycGender":"'+document.Gender__c+'"}';
           }
            else{
           ppCallOutRequest = '{"applicantId":"'+applicant.Id+'" ,"dateOfBirth":"'+dateOfBirth+'" ,"kycPassportNo":"'+document.Passport_No__c+'","kycPassportFileNo":"'+document.Passport_File_No__c+'","firstName":"'+applicant.Customer_First_Name__c+'","lastName":"'+applicant.Customer_Last_Name__c+'","email":"","kycGender":"'+document.Gender__c+'"}';
            }           
         	 Continuation con = (Continuation)IntegrationEngine.doPPCallout(ppCallOutRequest);
            // Create a mock response
        	HttpResponse response = new HttpResponse();
             response.setBody('{"JData":"vz+0HRIa7MZUAaPO1qm8zJFUf6d4ipIt2F1fh/j48YA63dH9imVJaZtoRrYI+I5D/om00iSdyKPP/JUHHA3uXNI4ftcUPA+WS9Li0rMPcW85wMTx6bnHMuYPga0MS6gV2gFF9nn59YD78G30ZlDaSwaD6kV0oQosZ2nICIfK8BPX7G+gVqU7YXUZfgBAQa8xeNLCnteqgJJLc8ZKfs5GglF+y3SvU5vmg1HeGCnAxv6j/ElRiVd8rWLdqP1/eMQ427WLSgdB+x/V5SGzGeRBLxyW4J36QQfOzbojsF2SAgKsiST4Yokjlf4FXINPQTWkVwc7T0Mu8jQ7x+/B0xAI7Is2B1a0DTkV6BsxGbJ5UpdaNzw0uXDEcY49BLn+8wkNMH+0SycU2UOqAgL5iGmkCVLBkFf0so7SYGenatD/Vfyxv1xDKdhX6FWWW0PBwrJ5o1Kk5e5r4R2Cf81gk/wg1KzFm9FGQCf/SldvknQ5eroDScnih20/zoOXNjYGnSriGpXyRt9LMfg+QQKh7Lv7DgbgkJIChg04tgHPzxEJ4lL7JhYyazPiXVr7uSzW9CYeqftAxObPv394XIvaRuYMnmurSvS3e/iZj7OEb6ZPPRGbhuCvI6T98myGbPqnDDKZbGyv9wmTgtutt9dq/8/vGkDJLwhats25EVUPF6tiiVWuOyBNQQfsS1ZLRBeTonEfOgwMYo3Y3vo8itWuil2lCgCSbQ5t3tsfo61aN1b4EcncPOh9b6t9Zop2OXzQtTvd/qx0A8BR0aMkWIXWX101TEEcHprKLlB+Rd9b2Tc0bFdiKENOwKJUcofP1Fr9y0YJ9hwl/Kyw6DOmoPi65fycAdmpy04oiFnA+2yuahWNsue8oCGFh5zNlZNM69k8erpqrF1kyTACBGHvJtElYgpDGz5np4X+BRDmsjnH5fOefmWzh5ZTQOpEVMjf0FB9vfzUM0BHxk5SY8H7wMwwjC+g9smI0mieH4I1+55o9L6MJd/ZMKbavzJBHtUArmX8u0dc1iI1LTr9zi4+ZRSrtMCCbfO2YK0dVif9A5BU26wPgERLtsZTsY7lU9QZw9tQlKOlmhyqquooFy18YUNY7NfI+G+wHRRS05v5ct+cDsRwHVDjeYVuKIlDI25IgmtIxDg4P/XxRZaSEpvBeZo1xEA7gaMjkaTgC0oWTmMkU/VJ/UxiOv6hz3ZPCvUhEpepHGd/JNLfcyZeCzw5kbnnZfSaTYQ9adTjgTnuyNGppPsogZ5cro/GxUoYhCkj1gOLWLLXhuIXFeqqFQx3d5oBqt6tp/58ba39XGwZ5Gx0+7hWDZXi8Sgq6lFLA4Td+GBeqMDVRrAPvKRmOssI/qwIpRWfkjAo4pI/IZQdv5g3Pc4ok5J6LNBcyA5tWTAhJQ5cSReTbX4J6vb9eTR4u5o3U+M8xwLQh08NahoZm8LR7WUVxmGAAxiF8bLEylKULmYaNTqdbt+Hnwzojrh+DBhQiDPzdlX/3JEkAuBpI/prTvQd/eCnAbJr2LGmSfaxJ6ID9QY7JEA8D06yzFNuHLf/pquAzEq6/vYikjsqha8675Zqq0zvU/Tx5OHnwsaYEH28Ki3RlsdAI8fnX7/tmIBiqGJMXeU2JzfncqmR3xDBCKlaLdNvHZ9iLpOU/bQ0H/1yjsF9zjvy0lzEMJOGsFoOhNqSMjwW+Oju4PIZQiDCcyaxlk2o5SNx+1lgt0zBG2aUU8LY58Y7Qi72Kl4YYcptbX2wvm0IWWkj/mw6wlpEytZe+b4hEHXqpe0ISRFsDZVE2F1XVio/XASfwnoCruP68IwTxhdYqt+u8DN7UDML7WJBj6dBIrY/YZgYYbixzFNqGj5EEGiONqf9Ur8GEzumvGPT/NQFMzalQq2M9xTeljEuHoWiBgNxX0tGMxQ1zhKUEN8TS+NUyatAgind/+N3pFrF0lHt/mzt2zaxAM6E5ix9sac="}');
            response.setStatusCode(200);
      
            String continuationLabel = IntegrationEngine.continuationLabel;
 		    List<String> labels = new List<String>{continuationLabel};
            Object continuationState= IntegrationEngine.continuationState;         
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
            String ppCallOutResponse = (String)IntegrationEngine.processPPCallOutResponse(labels, IntegrationEngine.continuationState);
            Test.stopTest();
            String responseExpected ='{"body":null,"ResponseData":{"Status":"Success","ResponseInfo":{"SolutionSetInstanceId":"f4a6e08c-12eb-47dd-b611-a39ac30eedc4","ApplicationId":26578322},"Fields":{"Decision":"Pass","ApplicationId":"26578322","ApplicationData":{"Services":{"Service":{"Skip":"N","Name":"PublicDataAPI","Id":"","EnableSimulation":"","Consent":"true"}}},"Applicants":{"Applicant":{"Services":{"Service":[{"Status":"Pass","Operations":{"Operation":[{"Status":"Pass","Params":{"Param":[{"Value":"Y","Name":"consent"},{"Value":"MA2072741184320","Name":"fileNo"}]},"Name":"passport-verification","Id":"","Errors":null,"Data":{"Response":{"RawResponse":"{\\"result\\":{\\"passport-verification\\":{\\"requestId\\":\\"4abf204b-012c-41a4-b7d6-451be3c2a5b1\\",\\"result\\":{\\"name\\":{\\"nameFromPassport\\":\\"DWARAKESH\\",\\"surnameFromPassport\\":\\"RAJAGOPALAN\\",\\"nameMatch\\":true,\\"nameScore\\":1.0},\\"passportNumber\\":{\\"passportNumberFromSource\\":\\"U6926433\\",\\"passportNumberMatch\\":null},\\"dateOfIssue\\":{\\"dispatchedOnFromSource\\":\\"09/01/2020\\",\\"dateOfIssueMatch\\":null},\\"typeOfApplication\\":\\"Normal\\",\\"applicationDate\\":\\"08/01/2020\\"},\\"statusCode\\":101},\\"requestId\\":\\"6fbc0726-7087-46df-8d08-802aeb6f8d2b\\",\\"statusCode\\":\\"101\\"}}"}}}]},"Name":"PublicDataAPI","Id":""}]},"Identifiers":null,"Gender":"M","DateOfBirth":"8021990-01-01T00:00:00.000Z","ApplicantMiddleName":"","ApplicantLastName":" Rajagopalan","ApplicantIdentifier":"096cae9b-d5b4-4b37-903c-22a3121656b5","ApplicantFirstName":"Dwarakesh"}}}},"RequestId":"13122021175530466"}';        
            System.assertEquals(responseExpected,ppCallOutResponse,'Fail');
            
        } catch(Exception ex){
            System.assertEquals(ex.getMessage(),System.Label.LastName,'Exception');
        }
    }
    
     @isTest
    public static void testINDPassportService9(){
        
        try{              
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            Applicant__c applicant = TestDataUtility.createTestApplicantForPassport3(false);
            applicant.Opportunity__c=opp.Id;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert applicant;
            }
            
            Documents__c document = TestDataUtility.createTestPPDocs(false,applicant,opp);
            if (Schema.sObjectType.Documents__c.isCreateable()){
                insert document;
            }
            
            Datetime dOB = (Datetime)document.KYC_DOB__c;
            String dateOfBirth= dOB.format('ddMMyyyy') ;
            String ppCallOutRequest='';
            if(applicant.Customer_First_Name__c==null){
            ppCallOutRequest = '{"applicantId":"'+applicant.Id+'" ,"dateOfBirth":"'+dateOfBirth+'" ,"kycPassportNo":"'+document.Passport_No__c+'","kycPassportFileNo":"'+document.Passport_File_No__c+'","firstName":"","lastName":"'+applicant.Customer_Last_Name__c+'","email":"","kycGender":"'+document.Gender__c+'"}';   
            }
            else{
            ppCallOutRequest = '{"applicantId":"'+applicant.Id+'" ,"dateOfBirth":"'+dateOfBirth+'" ,"kycPassportNo":"'+document.Passport_No__c+'","kycPassportFileNo":"'+document.Passport_File_No__c+'","firstName":"'+applicant.Customer_First_Name__c+'","lastName":"'+applicant.Customer_Last_Name__c+'","email":"","kycGender":"'+document.Gender__c+'"}';
            }
             Continuation con = (Continuation)IntegrationEngine.doPPCallout(ppCallOutRequest);
            // Create a mock response
        	HttpResponse response = new HttpResponse();
             response.setBody('{"JData":"vz+0HRIa7MZUAaPO1qm8zJFUf6d4ipIt2F1fh/j48YA63dH9imVJaZtoRrYI+I5D/om00iSdyKPP/JUHHA3uXNI4ftcUPA+WS9Li0rMPcW85wMTx6bnHMuYPga0MS6gV2gFF9nn59YD78G30ZlDaSwaD6kV0oQosZ2nICIfK8BPX7G+gVqU7YXUZfgBAQa8xeNLCnteqgJJLc8ZKfs5GglF+y3SvU5vmg1HeGCnAxv6j/ElRiVd8rWLdqP1/eMQ427WLSgdB+x/V5SGzGeRBLxyW4J36QQfOzbojsF2SAgKsiST4Yokjlf4FXINPQTWkVwc7T0Mu8jQ7x+/B0xAI7Is2B1a0DTkV6BsxGbJ5UpdaNzw0uXDEcY49BLn+8wkNMH+0SycU2UOqAgL5iGmkCVLBkFf0so7SYGenatD/Vfyxv1xDKdhX6FWWW0PBwrJ5o1Kk5e5r4R2Cf81gk/wg1KzFm9FGQCf/SldvknQ5eroDScnih20/zoOXNjYGnSriGpXyRt9LMfg+QQKh7Lv7DgbgkJIChg04tgHPzxEJ4lL7JhYyazPiXVr7uSzW9CYeqftAxObPv394XIvaRuYMnmurSvS3e/iZj7OEb6ZPPRGbhuCvI6T98myGbPqnDDKZbGyv9wmTgtutt9dq/8/vGkDJLwhats25EVUPF6tiiVWuOyBNQQfsS1ZLRBeTonEfOgwMYo3Y3vo8itWuil2lCgCSbQ5t3tsfo61aN1b4EcncPOh9b6t9Zop2OXzQtTvd/qx0A8BR0aMkWIXWX101TEEcHprKLlB+Rd9b2Tc0bFdiKENOwKJUcofP1Fr9y0YJ9hwl/Kyw6DOmoPi65fycAdmpy04oiFnA+2yuahWNsue8oCGFh5zNlZNM69k8erpqrF1kyTACBGHvJtElYgpDGz5np4X+BRDmsjnH5fOefmWzh5ZTQOpEVMjf0FB9vfzUM0BHxk5SY8H7wMwwjC+g9smI0mieH4I1+55o9L6MJd/ZMKbavzJBHtUArmX8u0dc1iI1LTr9zi4+ZRSrtMCCbfO2YK0dVif9A5BU26wPgERLtsZTsY7lU9QZw9tQlKOlmhyqquooFy18YUNY7NfI+G+wHRRS05v5ct+cDsRwHVDjeYVuKIlDI25IgmtIxDg4P/XxRZaSEpvBeZo1xEA7gaMjkaTgC0oWTmMkU/VJ/UxiOv6hz3ZPCvUhEpepHGd/JNLfcyZeCzw5kbnnZfSaTYQ9adTjgTnuyNGppPsogZ5cro/GxUoYhCkj1gOLWLLXhuIXFeqqFQx3d5oBqt6tp/58ba39XGwZ5Gx0+7hWDZXi8Sgq6lFLA4Td+GBeqMDVRrAPvKRmOssI/qwIpRWfkjAo4pI/IZQdv5g3Pc4ok5J6LNBcyA5tWTAhJQ5cSReTbX4J6vb9eTR4u5o3U+M8xwLQh08NahoZm8LR7WUVxmGAAxiF8bLEylKULmYaNTqdbt+Hnwzojrh+DBhQiDPzdlX/3JEkAuBpI/prTvQd/eCnAbJr2LGmSfaxJ6ID9QY7JEA8D06yzFNuHLf/pquAzEq6/vYikjsqha8675Zqq0zvU/Tx5OHnwsaYEH28Ki3RlsdAI8fnX7/tmIBiqGJMXeU2JzfncqmR3xDBCKlaLdNvHZ9iLpOU/bQ0H/1yjsF9zjvy0lzEMJOGsFoOhNqSMjwW+Oju4PIZQiDCcyaxlk2o5SNx+1lgt0zBG2aUU8LY58Y7Qi72Kl4YYcptbX2wvm0IWWkj/mw6wlpEytZe+b4hEHXqpe0ISRFsDZVE2F1XVio/XASfwnoCruP68IwTxhdYqt+u8DN7UDML7WJBj6dBIrY/YZgYYbixzFNqGj5EEGiONqf9Ur8GEzumvGPT/NQFMzalQq2M9xTeljEuHoWiBgNxX0tGMxQ1zhKUEN8TS+NUyatAgind/+N3pFrF0lHt/mzt2zaxAM6E5ix9sac="}');
            response.setStatusCode(200);
      
            String continuationLabel = IntegrationEngine.continuationLabel;
 		    List<String> labels = new List<String>{continuationLabel};
            Object continuationState= IntegrationEngine.continuationState;         
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
            String ppCallOutResponse = (String)IntegrationEngine.processPPCallOutResponse(labels, IntegrationEngine.continuationState);
            Test.stopTest();
            String responseExpected ='{"body":null,"ResponseData":{"Status":"Success","ResponseInfo":{"SolutionSetInstanceId":"f4a6e08c-12eb-47dd-b611-a39ac30eedc4","ApplicationId":26578322},"Fields":{"Decision":"Pass","ApplicationId":"26578322","ApplicationData":{"Services":{"Service":{"Skip":"N","Name":"PublicDataAPI","Id":"","EnableSimulation":"","Consent":"true"}}},"Applicants":{"Applicant":{"Services":{"Service":[{"Status":"Pass","Operations":{"Operation":[{"Status":"Pass","Params":{"Param":[{"Value":"Y","Name":"consent"},{"Value":"MA2072741184320","Name":"fileNo"}]},"Name":"passport-verification","Id":"","Errors":null,"Data":{"Response":{"RawResponse":"{\\"result\\":{\\"passport-verification\\":{\\"requestId\\":\\"4abf204b-012c-41a4-b7d6-451be3c2a5b1\\",\\"result\\":{\\"name\\":{\\"nameFromPassport\\":\\"DWARAKESH\\",\\"surnameFromPassport\\":\\"RAJAGOPALAN\\",\\"nameMatch\\":true,\\"nameScore\\":1.0},\\"passportNumber\\":{\\"passportNumberFromSource\\":\\"U6926433\\",\\"passportNumberMatch\\":null},\\"dateOfIssue\\":{\\"dispatchedOnFromSource\\":\\"09/01/2020\\",\\"dateOfIssueMatch\\":null},\\"typeOfApplication\\":\\"Normal\\",\\"applicationDate\\":\\"08/01/2020\\"},\\"statusCode\\":101},\\"requestId\\":\\"6fbc0726-7087-46df-8d08-802aeb6f8d2b\\",\\"statusCode\\":\\"101\\"}}"}}}]},"Name":"PublicDataAPI","Id":""}]},"Identifiers":null,"Gender":"M","DateOfBirth":"8021990-01-01T00:00:00.000Z","ApplicantMiddleName":"","ApplicantLastName":" Rajagopalan","ApplicantIdentifier":"096cae9b-d5b4-4b37-903c-22a3121656b5","ApplicantFirstName":"Dwarakesh"}}}},"RequestId":"13122021175530466"}';        
            System.assertEquals(responseExpected,ppCallOutResponse,'Fail');
            
        } catch(Exception ex){
            System.assertEquals(ex.getMessage(),System.Label.FirstName,'Exception');
        }
    }
    
    @isTest
    public static void testINDPassportService10(){
        
        try{              
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            Applicant__c applicant = TestDataUtility.createTestApplicantForPassport3(false);
            applicant.Opportunity__c=opp.Id;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert applicant;
            }
            
            Documents__c document = TestDataUtility.createTestPPDocs(false,applicant,opp);
            if (Schema.sObjectType.Documents__c.isCreateable()){
                insert document;
            }
            
            Datetime dOB = (Datetime)document.KYC_DOB__c;
            String dateOfBirth= dOB.format('ddMMyyyy') ;
            String ppCallOutRequest='';
            if(applicant.Customer_First_Name__c==null){
            ppCallOutRequest = '{"applicantId":"'+applicant.Id+'" ,"dateOfBirth":"'+dateOfBirth+'" ,"kycPassportNo":"'+document.Passport_No__c+'","kycPassportFileNo":"'+document.Passport_File_No__c+'","firstName":"","lastName":"'+applicant.Customer_Last_Name__c+'","email":"","kycGender":"'+document.Gender__c+'"}';   
            }
            else{
            ppCallOutRequest = '{"applicantId":"'+applicant.Id+'" ,"dateOfBirth":"'+dateOfBirth+'" ,"kycPassportNo":"'+document.Passport_No__c+'","kycPassportFileNo":"'+document.Passport_File_No__c+'","firstName":"'+applicant.Customer_First_Name__c+'","lastName":"'+applicant.Customer_Last_Name__c+'","email":"","kycGender":"'+document.Gender__c+'"}';
            }
             Continuation con = (Continuation)IntegrationEngine.doPPCallout(ppCallOutRequest);
            // Create a mock response
        	HttpResponse response = new HttpResponse();
             response.setBody('{"JData":"vz+0HRIa7MZUAaPO1qm8zJFUf6d4ipIt2F1fh/j48YA63dH9imVJaZtoRrYI+I5D/om00iSdyKPP/JUHHA3uXNI4ftcUPA+WS9Li0rMPcW85wMTx6bnHMuYPga0MS6gV2gFF9nn59YD78G30ZlDaSwaD6kV0oQosZ2nICIfK8BPX7G+gVqU7YXUZfgBAQa8xeNLCnteqgJJLc8ZKfs5GglF+y3SvU5vmg1HeGCnAxv6j/ElRiVd8rWLdqP1/eMQ427WLSgdB+x/V5SGzGeRBLxyW4J36QQfOzbojsF2SAgKsiST4Yokjlf4FXINPQTWkVwc7T0Mu8jQ7x+/B0xAI7Is2B1a0DTkV6BsxGbJ5UpdaNzw0uXDEcY49BLn+8wkNMH+0SycU2UOqAgL5iGmkCVLBkFf0so7SYGenatD/Vfyxv1xDKdhX6FWWW0PBwrJ5o1Kk5e5r4R2Cf81gk/wg1KzFm9FGQCf/SldvknQ5eroDScnih20/zoOXNjYGnSriGpXyRt9LMfg+QQKh7Lv7DgbgkJIChg04tgHPzxEJ4lL7JhYyazPiXVr7uSzW9CYeqftAxObPv394XIvaRuYMnmurSvS3e/iZj7OEb6ZPPRGbhuCvI6T98myGbPqnDDKZbGyv9wmTgtutt9dq/8/vGkDJLwhats25EVUPF6tiiVWuOyBNQQfsS1ZLRBeTonEfOgwMYo3Y3vo8itWuil2lCgCSbQ5t3tsfo61aN1b4EcncPOh9b6t9Zop2OXzQtTvd/qx0A8BR0aMkWIXWX101TEEcHprKLlB+Rd9b2Tc0bFdiKENOwKJUcofP1Fr9y0YJ9hwl/Kyw6DOmoPi65fycAdmpy04oiFnA+2yuahWNsue8oCGFh5zNlZNM69k8erpqrF1kyTACBGHvJtElYgpDGz5np4X+BRDmsjnH5fOefmWzh5ZTQOpEVMjf0FB9vfzUM0BHxk5SY8H7wMwwjC+g9smI0mieH4I1+55o9L6MJd/ZMKbavzJBHtUArmX8u0dc1iI1LTr9zi4+ZRSrtMCCbfO2YK0dVif9A5BU26wPgERLtsZTsY7lU9QZw9tQlKOlmhyqquooFy18YUNY7NfI+G+wHRRS05v5ct+cDsRwHVDjeYVuKIlDI25IgmtIxDg4P/XxRZaSEpvBeZo1xEA7gaMjkaTgC0oWTmMkU/VJ/UxiOv6hz3ZPCvUhEpepHGd/JNLfcyZeCzw5kbnnZfSaTYQ9adTjgTnuyNGppPsogZ5cro/GxUoYhCkj1gOLWLLXhuIXFeqqFQx3d5oBqt6tp/58ba39XGwZ5Gx0+7hWDZXi8Sgq6lFLA4Td+GBeqMDVRrAPvKRmOssI/qwIpRWfkjAo4pI/IZQdv5g3Pc4ok5J6LNBcyA5tWTAhJQ5cSReTbX4J6vb9eTR4u5o3U+M8xwLQh08NahoZm8LR7WUVxmGAAxiF8bLEylKULmYaNTqdbt+Hnwzojrh+DBhQiDPzdlX/3JEkAuBpI/prTvQd/eCnAbJr2LGmSfaxJ6ID9QY7JEA8D06yzFNuHLf/pquAzEq6/vYikjsqha8675Zqq0zvU/Tx5OHnwsaYEH28Ki3RlsdAI8fnX7/tmIBiqGJMXeU2JzfncqmR3xDBCKlaLdNvHZ9iLpOU/bQ0H/1yjsF9zjvy0lzEMJOGsFoOhNqSMjwW+Oju4PIZQiDCcyaxlk2o5SNx+1lgt0zBG2aUU8LY58Y7Qi72Kl4YYcptbX2wvm0IWWkj/mw6wlpEytZe+b4hEHXqpe0ISRFsDZVE2F1XVio/XASfwnoCruP68IwTxhdYqt+u8DN7UDML7WJBj6dBIrY/YZgYYbixzFNqGj5EEGiONqf9Ur8GEzumvGPT/NQFMzalQq2M9xTeljEuHoWiBgNxX0tGMxQ1zhKUEN8TS+NUyatAgind/+N3pFrF0lHt/mzt2zaxAM6E5ix9sac="}');
            response.setStatusCode(500);
      
            String continuationLabel = IntegrationEngine.continuationLabel;
 		    List<String> labels = new List<String>{continuationLabel};
            Object continuationState= IntegrationEngine.continuationState;         
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
            String ppCallOutResponse = (String)IntegrationEngine.processPPCallOutResponse(labels, IntegrationEngine.continuationState);
            Test.stopTest();
            String responseExpected ='{"body":null,"ResponseData":{"Status":"Success","ResponseInfo":{"SolutionSetInstanceId":"f4a6e08c-12eb-47dd-b611-a39ac30eedc4","ApplicationId":26578322},"Fields":{"Decision":"Pass","ApplicationId":"26578322","ApplicationData":{"Services":{"Service":{"Skip":"N","Name":"PublicDataAPI","Id":"","EnableSimulation":"","Consent":"true"}}},"Applicants":{"Applicant":{"Services":{"Service":[{"Status":"Pass","Operations":{"Operation":[{"Status":"Pass","Params":{"Param":[{"Value":"Y","Name":"consent"},{"Value":"MA2072741184320","Name":"fileNo"}]},"Name":"passport-verification","Id":"","Errors":null,"Data":{"Response":{"RawResponse":"{\\"result\\":{\\"passport-verification\\":{\\"requestId\\":\\"4abf204b-012c-41a4-b7d6-451be3c2a5b1\\",\\"result\\":{\\"name\\":{\\"nameFromPassport\\":\\"DWARAKESH\\",\\"surnameFromPassport\\":\\"RAJAGOPALAN\\",\\"nameMatch\\":true,\\"nameScore\\":1.0},\\"passportNumber\\":{\\"passportNumberFromSource\\":\\"U6926433\\",\\"passportNumberMatch\\":null},\\"dateOfIssue\\":{\\"dispatchedOnFromSource\\":\\"09/01/2020\\",\\"dateOfIssueMatch\\":null},\\"typeOfApplication\\":\\"Normal\\",\\"applicationDate\\":\\"08/01/2020\\"},\\"statusCode\\":101},\\"requestId\\":\\"6fbc0726-7087-46df-8d08-802aeb6f8d2b\\",\\"statusCode\\":\\"101\\"}}"}}}]},"Name":"PublicDataAPI","Id":""}]},"Identifiers":null,"Gender":"M","DateOfBirth":"8021990-01-01T00:00:00.000Z","ApplicantMiddleName":"","ApplicantLastName":" Rajagopalan","ApplicantIdentifier":"096cae9b-d5b4-4b37-903c-22a3121656b5","ApplicantFirstName":"Dwarakesh"}}}},"RequestId":"13122021175530466"}';        
            System.assertEquals(responseExpected,ppCallOutResponse,'Fail');
            
        } catch(Exception ex){
            System.assertEquals(ex.getMessage(),System.Label.FirstName,'Exception');
        }
    } 
         @isTest
    public static void getPPCallOutRequestTest(){
        
        try{
        Opportunity opgd1 = new Opportunity();
        opgd1.StageName = 'Qualification';
        opgd1.CloseDate = Date.newInstance(2021, 1, 11);
        opgd1.Name = 'testone';
        insert opgd1;
        
        RequestWrapper reqWrapper = new RequestWrapper();
        reqWrapper.applicantId = opgd1.Id;
        
        List<Applicant__c> appList = new List<Applicant__c>();
        
        Applicant__c applicant = TestDataUtility.createTestApplicantForSMS(false);
        applicant.Opportunity__c=opgd1.Id;
        appList.add(applicant);
        insert appList;
        IND_PassportService.getPPCallOutRequest(reqWrapper);
        }
        catch(Exception e){}
        
    }
}