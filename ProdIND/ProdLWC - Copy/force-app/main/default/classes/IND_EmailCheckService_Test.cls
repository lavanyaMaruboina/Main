/*------------------------------------------------------------
Author:        Satyam More
Company:       Persistent Systems
Description:  Test class created to validate the IND_EmailCheckRequest IND_EmailCheckService IND_EmailCheckResponse class
History
Date            Author              Comments
-------------------------------------------------------------
1-12-2021      Satyam More       Created
------------------------------------------------------------*/

@isTest(SeeAllData=false)
public class IND_EmailCheckService_Test {
    
    
    @isTest
    public static void testEmailCheckService(){
        
        try{   
            
            Profile p = [SELECT Id FROM Profile WHERE Name='CMU'];
            system.debug('p'+ p);
            User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                    EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                    LocaleSidKey='en_US', ProfileId = p.Id,
                    TimeZoneSidKey='America/Los_Angeles',Maker_Id__c = '1001',User_Id__c = '29927_MO',
                    UserName='standarduser4@testorg.com.psdev1',
                    MobilePhone='0123456789');
            insert u;
            System.runas(u){
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            Applicant__c applicant = TestDataUtility.createTestApplicant(false);
            applicant.Opportunity__c=opp.Id;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert applicant;
            }
            
            String emailCheckrequest = '{"LeadId": "AC9834773_4895748573243","Email":"ganeshsun1991@gmail.com"}';
            
            Continuation con = (Continuation)IntegrationEngine.doEMAILCHECKCallout(emailCheckrequest);
            // Create a mock response
            HttpResponse response = new HttpResponse();
            response.setBody('{"JData":"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"}');
            response.setStatusCode(200);
            
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
            Object continuationState= IntegrationEngine.continuationState;
            
            String emailCheckCallOutResponse;
            // system.runAs(u){
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
            emailCheckCallOutResponse= (String)IntegrationEngine.processEmailCheckResponse(labels, IntegrationEngine.continuationState);
            Test.stopTest();
             
                 String responseExpected ='{"body":null,"ResponseData":{"Status":"Success","ResponseInfo":{"SolutionSetInstanceId":"1698404e-53d3-4ef1-bbab-85b20404ef6c","ApplicationId":23388791},"Fields":{"Decision":"Pass","ApplicationId":"23388791","ApplicationData":{"Services":{"Service":{"Skip":"N","Name":"EmailVerification","Id":"","Consent":"true"}}},"Applicants":{"Applicant":{"Services":{"Service":[{"Status":"Pass","Operations":{"Operation":[{"Status":"Pass","Params":{"Param":[]},"Name":"EmailVerification","Id":"","Data":{"Response":{"DSEmailVerificationStatus":{"Outcome":"Success","IsSuccess":"True"},"DSEmailVerificationData":{"Response":{"Success":"True","Data":{"Status":1,"RawResponse":"{\\"eam\\":{\\"longevity\\":3,\\"velocity\\":3,\\"date_first_seen\\":\\"2019-08-07\\",\\"popularity\\":1},\\"email_validation\\":{\\"domain_type\\":\\"freeisp\\",\\"status_code\\":50,\\"address\\":\\"ganeshsun1991@gmail.com\\",\\"status\\":\\"valid\\"}}","GatewayTransactionId":"7c54fc6d-835c-4aa9-9df0-852a6bc0881f"}},"Request":""},"DSEmailVerification":{"VelocityScore":"3","RequestDateTime":"2021-10-08T06:46:12.1757374Z","PopularityScore":"1","LongevityScore":"3","DateFirstSeen":"2019-08-07","BasicCheckStatusCodeDesc":"Valid email address.","BasicCheckStatusCode":"50","BasicCheckStatus":"valid"},"DREmailVerification":{"IsEmailValid":true,"IsEmailBlackListCheckSuccess":"True","IsEmailAPICallSuccess":"True","IsBlackListedEmailDomain":"False","IsBlackListedEmailAddress":"False","APIResponseInMS":"687"}}}}]},"Name":"EmailVerification","Id":""}]},"EmailAddress":"ganeshsun1991@gmail.com","ApplicantIdentifier":"57f4e621-c70c-4ad3-91b2-a3a5bef66200"}}}},"RequestId":"08102021121616781"}';
            System.assertEquals(responseExpected, emailCheckCallOutResponse, 'SUCCESS');
            }
        } catch(Exception ex){
            System.assertEquals(ex.getMessage(),'Insert failed. First exception on row 0; first error: FIELD_CUSTOM_VALIDATION_EXCEPTION, Please provide numeric value: [Maker_Id__c]', 'Exception');
        }
    }
    
    @isTest
    public static void testEmailCheckService2(){
        
        try{   
            
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            Applicant__c applicant = TestDataUtility.createTestApplicant(false);
            applicant.Opportunity__c=opp.Id;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert applicant;
            }
            
            String emailCheckrequest = '{"LeadId": "AC9834773_4895748573243","Email":""}';
            Continuation con = (Continuation)IntegrationEngine.doEMAILCHECKCallout(emailCheckrequest);
            // Create a mock response
            HttpResponse response = new HttpResponse();
            response.setBody('{"JData":"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"}');
            response.setStatusCode(200);
            
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
            Object continuationState= IntegrationEngine.continuationState;
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
            String emailCheckCallOutResponse= (String)IntegrationEngine.processEmailCheckResponse(labels, IntegrationEngine.continuationState);
            Test.stopTest();
            String responseExpected ='{"body":null,"ResponseData":{"Status":"Success","ResponseInfo":{"SolutionSetInstanceId":"1698404e-53d3-4ef1-bbab-85b20404ef6c","ApplicationId":23388791},"Fields":{"Decision":"Pass","ApplicationId":"23388791","ApplicationData":{"Services":{"Service":{"Skip":"N","Name":"EmailVerification","Id":"","Consent":"true"}}},"Applicants":{"Applicant":{"Services":{"Service":[{"Status":"Pass","Operations":{"Operation":[{"Status":"Pass","Params":{"Param":[]},"Name":"EmailVerification","Id":"","Data":{"Response":{"DSEmailVerificationStatus":{"Outcome":"Success","IsSuccess":"True"},"DSEmailVerificationData":{"Response":{"Success":"True","Data":{"Status":1,"RawResponse":"{\\"eam\\":{\\"longevity\\":3,\\"velocity\\":3,\\"date_first_seen\\":\\"2019-08-07\\",\\"popularity\\":1},\\"email_validation\\":{\\"domain_type\\":\\"freeisp\\",\\"status_code\\":50,\\"address\\":\\"ganeshsun1991@gmail.com\\",\\"status\\":\\"valid\\"}}","GatewayTransactionId":"7c54fc6d-835c-4aa9-9df0-852a6bc0881f"}},"Request":""},"DSEmailVerification":{"VelocityScore":"3","RequestDateTime":"2021-10-08T06:46:12.1757374Z","PopularityScore":"1","LongevityScore":"3","DateFirstSeen":"2019-08-07","BasicCheckStatusCodeDesc":"Valid email address.","BasicCheckStatusCode":"50","BasicCheckStatus":"valid"},"DREmailVerification":{"IsEmailValid":true,"IsEmailBlackListCheckSuccess":"True","IsEmailAPICallSuccess":"True","IsBlackListedEmailDomain":"False","IsBlackListedEmailAddress":"False","APIResponseInMS":"687"}}}}]},"Name":"EmailVerification","Id":""}]},"EmailAddress":"ganeshsun1991@gmail.com","ApplicantIdentifier":"57f4e621-c70c-4ad3-91b2-a3a5bef66200"}}}},"RequestId":"08102021121616781"}';
            System.assertEquals(responseExpected, emailCheckCallOutResponse, 'SUCCESS');
            
        } catch(Exception ex){
            System.assertEquals(ex.getMessage(),System.Label.EnterEmailAddress, 'Exception');
        }
    }
    
    @isTest
    public static void testEmailCheckService3(){
        
        try{   
            
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            Applicant__c applicant = TestDataUtility.createTestApplicant(false);
            applicant.Opportunity__c=opp.Id;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert applicant;
            }
            
            String emailCheckrequest = '{"LeadId": "AC9834773_4895748573243","Email":"ganeshsun1991@gmail.com"}';
            
            Continuation con = (Continuation)IntegrationEngine.doEMAILCHECKCallout(emailCheckrequest);
            // Create a mock response
            HttpResponse response = new HttpResponse();
            response.setBody('{"JData":"g3j/fafgeyHv/ljoubHZcW4bPumJFZ3fB7w7jVMKC75M9j/BCPrlkFpVdfKvxHH5aj4MzU1xiEZdSagCPg4B4K6fSqiscVobPJZbX5n8OD0M0EydDHr1XZLC0D8cC2F2kXBdqEstCv0J+lD/NDSDSSJFDhP3Dj9dkYsdRFwPZJbQy1ImMZQC5wDKMFIlAVEZne+9gj1Scl6wTz9SBfInYlYB/o/ulDCIh9IhS6XhdhQitGLIAhc/Pg01gXkf190Delm5X8ChFA6B/KuiWrZQoJKtMI7CP+N4AP8Qz/QLo7PlB7kVa6PVuanZPoRb0MDIMzgoiAovGW9ksTccV9V12iJkA7Ho0zzKvfKwe4PjdQeZWcX9rHMO4e59wF39zaSzDqv6RssuzPPdJf4PElyDR7blTWvWuugYjC49e2Yg4yl03bnRNKukt+7dkaRsJHbhSqn0h3nrr8j3fe5r0ksfZVObdV3VCDsD/COugKcF3CFZtITU/sC3ZBbmbxehAVs4A49fUrhdY5JvbQxPn6rEF1uvZfWNcK03EYBD37P/cCZOMn5+Z7F9bAgpuFpMTuJIHV6qiXkKo7IQ5TewTpU5kIHYBzv6jLm+CcS1ZxRARczykXe0IFH1TlgHi39c4ReYx8s86pxwHDD8fAm2Eypg+HYCZhwaGZKBw393mQ6km01HzXwNg7A+W3xLZ9sFlzhwo52krNozO5NEfGdgQM3vNs6QatZokmwtnCZfMNCWNFkxgjL5TgyYrjoQZMbD/Uvv7coSEJ6WXZeRJbZbP+LyAp/DaRNblz3rGt3AXsKyXIKd1vSFVxIcEvJWOqdzc2w72Y6/GbAb/1OckFTykb0rPlB8GDxFmGzvZrfuwkG7fVh+xjOgcO5APYIWSSmO2HATs7up7WnhRgMcHdb3PKHCgKwaXGErrbe0fhO+sEblvALM+PzCRjobcGuH1Y6bXl/kbExnQUjdQZlGBzVE2mnlEOwoXzdkmfzIMnb1kgDJsarvHnrVc1Yi1ZwPPa3hSCy/VVAvP0ckvCVLHxo15X/63CxeL9Q47zHnKCUf2vv46lS3XMM+jzojs96niGN/TY/hN9swuTJ25wZ6L+kN2dPWZ0EYTmsyNF3YpbKaFxzyHLpYVevSwdLODAXeVVs9oCksaWr/Niep+g4QmHO2ouTG87VLX9+krEhesqGD3JUOHV6+kkE3EM9Ezjaz+wWOs+U3LAFhQe5u55Tdqr2L0daDXH+SsuU10eBS12OKGQT+NJwvgycUr/v1nkpMW+47YA6GDIj1dE0LqCB+ULFwPTVOmfxZQKn8Dt8CHwHxWh8Zpv8AwVYQdxt+9DslV5G9egqWKQkpB33j0Ylh2T49Yi6HMNeqWLNFdo6U1dem0wlRwIWAh4mD5lmffN7Gwh3XE70E64G1DiDY447U4XCkh64HRRBwFMhRCVrkNZfNsObPEqUg72+sZebHAl4OVLKBYgDKJEa0mYoLPPu5q1M4CZwyihh80gR+PJ2eF6oJZoj1wfN6664GcxrujUdRy2uB6nT4NbfZYl3VMbaTbhhK3MMgrAFx992LmTczpGfW5jaX1De3YPuLEpbLmyVvXbU6Ae00iZ2prg1PUWbL43htWt0l84QXb3Q+MRR3W1Cx5WIJ4iFSEUtHKMc5/H9wrK6TlYCmi/tQyvqlU8763ot0lU4iKfU7v7VrjXysFBw3Bpv7OS0Nyzit0PuCeBsjd6lihHfCy3qCLBEwb00QOze2+9r/DBGpOdH61XJUQVb6/u4Y+d7lwP6XIC2sd9wo+sXHrhQmuGUjwBiwMe2k2ThiryQBvW8A1ort9Ru476g1pckPMR30E+cmv17hVrF/UTeoGXNXKEvStq5+mfGqSiQyGZD6gdwNP90m/OrH7kwZjW26aPYh/S5ePE5oVn08nDyXiY5YdLNPaSxAlrsdZYp+IZ2noNB6nBbx2v9SCHgn7uWAWNqYrm78EZR+sWf11zyD7He7Bi//tE9/17QmaHP2zoj3Ucu1spUjk9/ADdcj7jzF5rL5i0xCohJbutL5Vx3TPMl+c9OaTPhAFO1EkTYMVsFY3uyU8Nxj13MLnh1Yh3jhffekNRB310Ek5ftEKT7/OPbxdrOWWM53iX+Qp2BV9seiFuNsK8h42X33ZYWeybhRTkWcj6k2DIa6uzNXka5GMMTxhRU1qWlerTF/abeMKXXQKzn5UAaQx6dbUtV8kcUAnbikH9di9Fr2wOcMAbJxB8or"}');
            response.setStatusCode(500);
            
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
            Object continuationState= IntegrationEngine.continuationState;
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
            String emailCheckCallOutResponse= (String)IntegrationEngine.processEmailCheckResponse(labels, IntegrationEngine.continuationState);
            Test.stopTest();
            String responseExpected ='{"body":null,"ResponseData":{"Status":"Success","ResponseInfo":{"SolutionSetInstanceId":"1698404e-53d3-4ef1-bbab-85b20404ef6c","ApplicationId":23388791},"Fields":{"Decision":"Pass","ApplicationId":"23388791","ApplicationData":{"Services":{"Service":{"Skip":"N","Name":"EmailVerification","Id":"","Consent":"true"}}},"Applicants":{"Applicant":{"Services":{"Service":[{"Status":"Pass","Operations":{"Operation":[{"Status":"Pass","Params":{"Param":[]},"Name":"EmailVerification","Id":"","Data":{"Response":{"DSEmailVerificationStatus":{"Outcome":"Success","IsSuccess":"True"},"DSEmailVerificationData":{"Response":{"Success":"True","Data":{"Status":1,"RawResponse":"{\\"eam\\":{\\"longevity\\":3,\\"velocity\\":3,\\"date_first_seen\\":\\"2019-08-07\\",\\"popularity\\":1},\\"email_validation\\":{\\"domain_type\\":\\"freeisp\\",\\"status_code\\":50,\\"address\\":\\"ganeshsun1991@gmail.com\\",\\"status\\":\\"valid\\"}}","GatewayTransactionId":"7c54fc6d-835c-4aa9-9df0-852a6bc0881f"}},"Request":""},"DSEmailVerification":{"VelocityScore":"3","RequestDateTime":"2021-10-08T06:46:12.1757374Z","PopularityScore":"1","LongevityScore":"3","DateFirstSeen":"2019-08-07","BasicCheckStatusCodeDesc":"Valid email address.","BasicCheckStatusCode":"50","BasicCheckStatus":"valid"},"DREmailVerification":{"IsEmailValid":true,"IsEmailBlackListCheckSuccess":"True","IsEmailAPICallSuccess":"True","IsBlackListedEmailDomain":"False","IsBlackListedEmailAddress":"False","APIResponseInMS":"687"}}}}]},"Name":"EmailVerification","Id":""}]},"EmailAddress":"ganeshsun1991@gmail.com","ApplicantIdentifier":"57f4e621-c70c-4ad3-91b2-a3a5bef66200"}}}},"RequestId":"08102021121616781"}';
            System.assertEquals(responseExpected, emailCheckCallOutResponse, 'SUCCESS');
            
        } catch(Exception ex){
            //System.assertEquals(ex.getMessage(),System.Label.Retry, 'Exception');
        }
    }
}