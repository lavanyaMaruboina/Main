/*Author:        Aman Mundhada
Company:       Persistent Systems
Description:   Test class created to validate the IND_VoterIdRequest IND_VoterIdService IND_VoterIdResponse class
History
Date            Author              Comments
-------------------------------------------------------------
1-12-2021      Aman Mundhada       Created
------------------------------------------------------------*/

@isTest(SeeAllData=false)
public class IND_VoterIdService_Test {
    
    @isTest
    public static void testINDVoterIdService(){
        
        try{   
            Profile p = [SELECT Id FROM Profile WHERE Name='CMU'];
            
            User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                              EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                              LocaleSidKey='en_US', ProfileId = p.Id,MobilePhone = '9701498575',
                              Maker_Id__c='1002',User_Id__c = '29927_MO',
                              TimeZoneSidKey='America/Los_Angeles',
                              UserName='standarduser4@testorg.com.psdev1');
            insert u;
            System.runAs(u) {            
                Opportunity opp = TestDataUtility.createTestOpportunity(false);
                if (Schema.sObjectType.Opportunity.isCreateable()){
                    insert opp;
                }
                Applicant__c applicant = TestDataUtility.createTestApplicantForVoterId(false);
                applicant.Opportunity__c=opp.Id;
                if (Schema.sObjectType.Applicant__c.isCreateable()){
                    insert applicant;
                }
                
                Documents__c document = TestDataUtility.createTestVoterIdDocs(false,applicant,opp);
                if (Schema.sObjectType.Documents__c.isCreateable()){
                    insert document;
                }
                
                String kycFieldsVoterIdString = '{"applicantId":"'+applicant.Id+'" ,"kycNo":"'+document.KYC_No__c+'"}';
                
                Continuation con = (Continuation)IntegrationEngine.doVoterIdCallout(kycFieldsVoterIdString);
                // Create a mock response
                HttpResponse response = new HttpResponse();
                response.setBody('{"JData":"DbTbDvFFL3lFceNs8odJ70KwcKEYfIw3oXLCRljIf+EFFdjqVgEYfml+CE5Lw3sG3PsFbBRiqaxWf1TFv4lipWX1Ikx/WVfrDmxSNE79RrHf0ok4FHSqpKcuhQB1EUqPBot+Jv7gpXykw0AvFB1xjtdfd+74qKgUo8epnDMcaMeHvHGhHSAK3q/aJeyZ8a0pwq8LOrqbpWCMYCEpRhMuXtceIohaRIp5o3jAmFCI0Nnlu2yBrDZ4BTkff/nnpAliHB8tyuHIyQsgjyclu6fkp6I7KLjc7YjYRFa1ktgk3QQKPJlCWWfH5TZq/yuNEBojFT4UK32pxBkMGGt10wk3GB0pOdCq004Q/pnxOmyKDDPTQtsxuk8MJ3mbdFuYl0J1mkXyThvp/DTi/azvDH6enZXX3ulMqDsNt9uitFFgEn8WmPSFtzHFDB3rN0DTQexyJeaLiLPXLZkiIucEWr9c7oIDSA2srlmRNW09X9JDDih6mHk+Q7oksoWbbCu2WmrHHbQPvj6saReobTFVm+xBEuBsxHdrvc4I2KxsFOVnUPQIwqgxQKGXZ7AMWVgZqCcBAoGBluF8/O3QmDR5lEoEdicIJr8gggf9P0JHzfpzH8ERYrAyfKPrkdq7W3LRjnXh9VAoBP8GOr5tNiq6Z+ZDofLhyN2ZGiX9PF9VWj6SDgty+gAC7tff/TNx4Ne7HHdOX2C5VPyHtbkYxutfO/nkMfB7siFagGBrIrk5eYASykWwKlY4gYuLgbhp6YJJ7XzTx9nG4F3rudFISJ5+p8Ha2i9XZu0ZDS1YLq9jgAVize5ZQmkngPnWja+sOPE28EFpJjLM1BVy3BC8akot/i/0sKQZ65y7BHTlkyeVPGQH3K7kpoUyXFHs7g5z1DnH4ELvP7GkE5860CkmlxhjtVukR2erN7vnV4NCQXnxa1900MpDcd3U2d+U/6JZZ/fhJLqdn2i/xtAFSvyhCYNmpm5xQ9+CXm0MSUDkgt4hL/c5S7JYgcfxp5ShlidcyBJ1nPakNYUnKNc3ZvRdi33HTHyi7lxMZCO3j1ntx96hDL1j3MmKeiUWVwCxcbcUi378AWEs3hCiLvDNRCci+UN8Fcv6t8pb6PUmkSnuSFN/mD/lZAkeoTfkfhpMgJO+d75AxsdtzsRWELGQPgyMOHwgawubfQZGbDXtj1Sckk7NGZDeul3Ydisinnbs3zYqfnrimZDNUnrZhd6MTf3gkD+9OL4YSMiPubiZAqt0RacLVxjKoXnCEYVJpySxWa0x4IURZCONXx68hNDLyctTq0LD+Wm/H6t+dS7NdAXhU9ppFlQx0efgGhOg+20sdURzs8hxp63PuuLBoU6nC8pk3lFiAbYDlB2tYzasomizT+MSJBEqoWL57frwEzjBmYzsrOwHqAD6pPgqiqIePX+XUv0Bfm3nVbVYuw2DQyLVVW0rHgTbNsYytLIm+HQFb7tXZNUt114vAKvVyeJzwJ+eBMGXQcCfwwJ85xFa93jVge/z6ooq4C+duF9DxtbZqqR4/TqEItjZFF4Y3Li+ddHFsl5ZZLDHXi/brLUhm58Aq98VQI+IYcUoGKSIue/BAUbnNqbBlwfiwgL3oMC+PHCIaIt24R4MKEnUQC8ifti33yUDSvaPVt1HzHaAQQdehxq/G7UUZlKNkl1E/uynXnyKpiOmqIIU4t/Liuk5cqYze/am3GPfGBAcd72m5TTajWTBQCnWLlwchO2WQ7lpnZiBDaUZteRRkZxryfy6eLMZlKoIVDeaNwDLA9Dxmt/lFkZRSZ5rnIKbIq+o7KzHYpcCfAwuRUc2LVcchIiZRoq5du7PP1sZAwVSK+WGIxCFuauk4p1JBW4UCPV4zLLhromCSlO1euozpZSP40XEUi6xFzjEEoFKzJiyejrKebKLPndE5WduEWo1HpoAGMbGhG444HBvqfkrxydVct/WJKzy+oa9Df9sC+Q="}');
                response.setStatusCode(200);
                
                String continuationLabel = IntegrationEngine.continuationLabel;
                List<String> labels = new List<String>{continuationLabel};
                    Object continuationState= IntegrationEngine.continuationState;
                String voterCallOutResponse='';
                Test.startTest();
                Test.setContinuationResponse(continuationLabel, response);
                voterCallOutResponse= (String)IntegrationEngine.processVoterIdCallOutResponse(labels, IntegrationEngine.continuationState);
                Test.stopTest();
                String responseExpected ='{"body":null,"ResponseData":{"Status":"Success","ResponseInfo":{"SolutionSetInstanceId":"1b30af9d-8420-4b17-b3e3-6351c0d70656","ApplicationId":26585600},"Fields":{"ApplicationId":"26585600","ApplicationData":{"Services":{"Service":{"Skip":"N","Name":"SDE034","Id":"","EnableSimulation":"","Consent":"true"}}},"Applicants":{"Applicant":{"Telephones":{"Telephone":{"TelephoneType":"01","TelephoneNumber":"9402615811"}},"Services":{"Service":[{"Status":"Pass","Operations":{"Operation":[{"Status":"Pass","Id":"SDE034P001","Errors":null,"Data":{"Response":{"RawResponse":"{\\"request_id\\":\\"26585603\\",\\"status\\":\\"101\\",\\"timestamp\\":\\"12/14/2021 8:25:38 PM\\",\\"description\\":\\"Sucess\\",\\"result\\":[{\\"name\\":\\"DREMA\\",\\"gender\\":\\"F\\",\\"age\\":\\"31\\",\\"ac_name\\":\\"TAWANG\\",\\"epic_no\\":\\"AR01002024213\\",\\"ps_lat_long\\":\\"27.589542,91.861294\\",\\"email_id\\":\\"\\",\\"rln_type\\":\\"F\\",\\"rln_name\\":\\"PHURPA TSERING\\",\\"district\\":\\"\\",\\"state\\":\\"ARUNACHAL PRADESH\\",\\"ac_no\\":\\"2\\",\\"house_no\\":\\"E-113\\",\\"mob_no\\":\\"9402615811\\",\\"pincode\\":\\"900000\\",\\"ps_name\\":\\"GOVT. MIDDLE SCHOOL,SHYO\\",\\"pc_name\\":\\"ARUNACHAL WEST\\",\\"dob_derived\\":\\"08/01/1987\\",\\"part_name\\":\\"SHYO\\",\\"part_no\\":\\"12\\",\\"pc_no\\":\\"1.0\\",\\"dist_name\\":\\"TAWANG\\",\\"st_code\\":\\"S02\\",\\"last_update\\":\\"MON JUN 10 23:10:09 IST 2019\\"}]}"}}}]},"Name":"SDE034","Id":"SDE034"}]},"Identifiers":null,"ApplicantIdentifier":"c499a0cd-6fee-45a1-8497-0f15c392e518"}}}},"RequestId":"14122021202535835"}';
                System.assertEquals(responseExpected, voterCallOutResponse,'Success');
            }
        } catch(Exception ex){
            System.assertEquals(ex.getMessage(),'Script-thrown exception');
        }
    }
    
    @isTest
    public static void testINDVoterIdService3(){
        
        try{   
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            Applicant__c applicant = TestDataUtility.createTestApplicantForVoterId(false);
            applicant.Opportunity__c=opp.Id;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert applicant;
            }
            
            Documents__c document = TestDataUtility.createTestVoterIdDocs2(false,applicant,opp);
            if (Schema.sObjectType.Documents__c.isCreateable()){
                insert document;
            }
            
            String kycFieldsVoterIdString = '{"applicantId":"'+applicant.Id+'" ,"kycNo":"'+document.KYC_No__c+'"}';
            
            Continuation con = (Continuation)IntegrationEngine.doVoterIdCallout(kycFieldsVoterIdString);
            // Create a mock response
            HttpResponse response = new HttpResponse();
            response.setBody('{"JData":"DbTbDvFFL3lFceNs8odJ70KwcKEYfIw3oXLCRljIf+EFFdjqVgEYfml+CE5Lw3sG3PsFbBRiqaxWf1TFv4lipWX1Ikx/WVfrDmxSNE79RrHf0ok4FHSqpKcuhQB1EUqPBot+Jv7gpXykw0AvFB1xjtdfd+74qKgUo8epnDMcaMeHvHGhHSAK3q/aJeyZ8a0pwq8LOrqbpWCMYCEpRhMuXtceIohaRIp5o3jAmFCI0Nnlu2yBrDZ4BTkff/nnpAliHB8tyuHIyQsgjyclu6fkp6I7KLjc7YjYRFa1ktgk3QQKPJlCWWfH5TZq/yuNEBojFT4UK32pxBkMGGt10wk3GB0pOdCq004Q/pnxOmyKDDPTQtsxuk8MJ3mbdFuYl0J1mkXyThvp/DTi/azvDH6enZXX3ulMqDsNt9uitFFgEn8WmPSFtzHFDB3rN0DTQexyJeaLiLPXLZkiIucEWr9c7oIDSA2srlmRNW09X9JDDih6mHk+Q7oksoWbbCu2WmrHHbQPvj6saReobTFVm+xBEuBsxHdrvc4I2KxsFOVnUPQIwqgxQKGXZ7AMWVgZqCcBAoGBluF8/O3QmDR5lEoEdicIJr8gggf9P0JHzfpzH8ERYrAyfKPrkdq7W3LRjnXh9VAoBP8GOr5tNiq6Z+ZDofLhyN2ZGiX9PF9VWj6SDgty+gAC7tff/TNx4Ne7HHdOX2C5VPyHtbkYxutfO/nkMfB7siFagGBrIrk5eYASykWwKlY4gYuLgbhp6YJJ7XzTx9nG4F3rudFISJ5+p8Ha2i9XZu0ZDS1YLq9jgAVize5ZQmkngPnWja+sOPE28EFpJjLM1BVy3BC8akot/i/0sKQZ65y7BHTlkyeVPGQH3K7kpoUyXFHs7g5z1DnH4ELvP7GkE5860CkmlxhjtVukR2erN7vnV4NCQXnxa1900MpDcd3U2d+U/6JZZ/fhJLqdn2i/xtAFSvyhCYNmpm5xQ9+CXm0MSUDkgt4hL/c5S7JYgcfxp5ShlidcyBJ1nPakNYUnKNc3ZvRdi33HTHyi7lxMZCO3j1ntx96hDL1j3MmKeiUWVwCxcbcUi378AWEs3hCiLvDNRCci+UN8Fcv6t8pb6PUmkSnuSFN/mD/lZAkeoTfkfhpMgJO+d75AxsdtzsRWELGQPgyMOHwgawubfQZGbDXtj1Sckk7NGZDeul3Ydisinnbs3zYqfnrimZDNUnrZhd6MTf3gkD+9OL4YSMiPubiZAqt0RacLVxjKoXnCEYVJpySxWa0x4IURZCONXx68hNDLyctTq0LD+Wm/H6t+dS7NdAXhU9ppFlQx0efgGhOg+20sdURzs8hxp63PuuLBoU6nC8pk3lFiAbYDlB2tYzasomizT+MSJBEqoWL57frwEzjBmYzsrOwHqAD6pPgqiqIePX+XUv0Bfm3nVbVYuw2DQyLVVW0rHgTbNsYytLIm+HQFb7tXZNUt114vAKvVyeJzwJ+eBMGXQcCfwwJ85xFa93jVge/z6ooq4C+duF9DxtbZqqR4/TqEItjZFF4Y3Li+ddHFsl5ZZLDHXi/brLUhm58Aq98VQI+IYcUoGKSIue/BAUbnNqbBlwfiwgL3oMC+PHCIaIt24R4MKEnUQC8ifti33yUDSvaPVt1HzHaAQQdehxq/G7UUZlKNkl1E/uynXnyKpiOmqIIU4t/Liuk5cqYze/am3GPfGBAcd72m5TTajWTBQCnWLlwchO2WQ7lpnZiBDaUZteRRkZxryfy6eLMZlKoIVDeaNwDLA9Dxmt/lFkZRSZ5rnIKbIq+o7KzHYpcCfAwuRUc2LVcchIiZRoq5du7PP1sZAwVSK+WGIxCFuauk4p1JBW4UCPV4zLLhromCSlO1euozpZSP40XEUi6xFzjEEoFKzJiyejrKebKLPndE5WduEWo1HpoAGMbGhG444HBvqfkrxydVct/WJKzy+oa9Df9sC+Q="}');
            response.setStatusCode(200);
            
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
                Object continuationState= IntegrationEngine.continuationState;
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
            String voterCallOutResponse= (String)IntegrationEngine.processVoterIdCallOutResponse(labels, IntegrationEngine.continuationState);
            Test.stopTest();
            String responseExpected ='{"body":null,"ResponseData":{"Status":"Success","ResponseInfo":{"SolutionSetInstanceId":"1b30af9d-8420-4b17-b3e3-6351c0d70656","ApplicationId":26585600},"Fields":{"ApplicationId":"26585600","ApplicationData":{"Services":{"Service":{"Skip":"N","Name":"SDE034","Id":"","EnableSimulation":"","Consent":"true"}}},"Applicants":{"Applicant":{"Telephones":{"Telephone":{"TelephoneType":"01","TelephoneNumber":"9402615811"}},"Services":{"Service":[{"Status":"Pass","Operations":{"Operation":[{"Status":"Pass","Id":"SDE034P001","Errors":null,"Data":{"Response":{"RawResponse":"{\\"request_id\\":\\"26585603\\",\\"status\\":\\"101\\",\\"timestamp\\":\\"12/14/2021 8:25:38 PM\\",\\"description\\":\\"Sucess\\",\\"result\\":[{\\"name\\":\\"DREMA\\",\\"gender\\":\\"F\\",\\"age\\":\\"31\\",\\"ac_name\\":\\"TAWANG\\",\\"epic_no\\":\\"AR01002024213\\",\\"ps_lat_long\\":\\"27.589542,91.861294\\",\\"email_id\\":\\"\\",\\"rln_type\\":\\"F\\",\\"rln_name\\":\\"PHURPA TSERING\\",\\"district\\":\\"\\",\\"state\\":\\"ARUNACHAL PRADESH\\",\\"ac_no\\":\\"2\\",\\"house_no\\":\\"E-113\\",\\"mob_no\\":\\"9402615811\\",\\"pincode\\":\\"900000\\",\\"ps_name\\":\\"GOVT. MIDDLE SCHOOL,SHYO\\",\\"pc_name\\":\\"ARUNACHAL WEST\\",\\"dob_derived\\":\\"08/01/1987\\",\\"part_name\\":\\"SHYO\\",\\"part_no\\":\\"12\\",\\"pc_no\\":\\"1.0\\",\\"dist_name\\":\\"TAWANG\\",\\"st_code\\":\\"S02\\",\\"last_update\\":\\"MON JUN 10 23:10:09 IST 2019\\"}]}"}}}]},"Name":"SDE034","Id":"SDE034"}]},"Identifiers":null,"ApplicantIdentifier":"c499a0cd-6fee-45a1-8497-0f15c392e518"}}}},"RequestId":"14122021202535835"}';
            System.assertEquals(responseExpected, voterCallOutResponse,'Fail');
            
        } catch(Exception ex){
            //  System.assertEquals(ex.getMessage(),'Please enter the Maker Id','Exception');
        }
    }
    
    @isTest
    public static void testINDVoterIdService4(){
        
        try{   
            Profile p = [SELECT Id FROM Profile WHERE Name='CMU'];
            
            User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                              EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                              LocaleSidKey='en_US', ProfileId = p.Id,MobilePhone = '9701498575',
                              Maker_Id__c='1002',User_Id__c = '29927_MO',
                              TimeZoneSidKey='America/Los_Angeles',
                              UserName='standarduser4@testorg.com.psdev1');
            insert u;
            System.runAs(u) {            
                Opportunity opp = TestDataUtility.createTestOpportunity(false);
                if (Schema.sObjectType.Opportunity.isCreateable()){
                    insert opp;
                }
                Applicant__c applicant = TestDataUtility.createTestApplicantForVoterId(false);
                applicant.Opportunity__c=opp.Id;
                if (Schema.sObjectType.Applicant__c.isCreateable()){
                    insert applicant;
                }
                
                Documents__c document = TestDataUtility.createTestVoterIdDocs(false,applicant,opp);
                if (Schema.sObjectType.Documents__c.isCreateable()){
                    insert document;
                }
                
                String kycFieldsVoterIdString = '{"applicantId":"'+applicant.Id+'" ,"kycNo":"'+document.KYC_No__c+'"}';
                
                Continuation con = (Continuation)IntegrationEngine.doVoterIdCallout(kycFieldsVoterIdString);
                // Create a mock response
                HttpResponse response = new HttpResponse();
                response.setBody('{"JData":"DbTbDvFFL3lFceNs8odJ70KwcKEYfIw3oXLCRljIf+EFFdjqVgEYfml+CE5Lw3sG3PsFbBRiqaxWf1TFv4lipWX1Ikx/WVfrDmxSNE79RrHf0ok4FHSqpKcuhQB1EUqPBot+Jv7gpXykw0AvFB1xjtdfd+74qKgUo8epnDMcaMeHvHGhHSAK3q/aJeyZ8a0pwq8LOrqbpWCMYCEpRhMuXtceIohaRIp5o3jAmFCI0Nnlu2yBrDZ4BTkff/nnpAliHB8tyuHIyQsgjyclu6fkp6I7KLjc7YjYRFa1ktgk3QQKPJlCWWfH5TZq/yuNEBojFT4UK32pxBkMGGt10wk3GB0pOdCq004Q/pnxOmyKDDPTQtsxuk8MJ3mbdFuYl0J1mkXyThvp/DTi/azvDH6enZXX3ulMqDsNt9uitFFgEn8WmPSFtzHFDB3rN0DTQexyJeaLiLPXLZkiIucEWr9c7oIDSA2srlmRNW09X9JDDih6mHk+Q7oksoWbbCu2WmrHHbQPvj6saReobTFVm+xBEuBsxHdrvc4I2KxsFOVnUPQIwqgxQKGXZ7AMWVgZqCcBAoGBluF8/O3QmDR5lEoEdicIJr8gggf9P0JHzfpzH8ERYrAyfKPrkdq7W3LRjnXh9VAoBP8GOr5tNiq6Z+ZDofLhyN2ZGiX9PF9VWj6SDgty+gAC7tff/TNx4Ne7HHdOX2C5VPyHtbkYxutfO/nkMfB7siFagGBrIrk5eYASykWwKlY4gYuLgbhp6YJJ7XzTx9nG4F3rudFISJ5+p8Ha2i9XZu0ZDS1YLq9jgAVize5ZQmkngPnWja+sOPE28EFpJjLM1BVy3BC8akot/i/0sKQZ65y7BHTlkyeVPGQH3K7kpoUyXFHs7g5z1DnH4ELvP7GkE5860CkmlxhjtVukR2erN7vnV4NCQXnxa1900MpDcd3U2d+U/6JZZ/fhJLqdn2i/xtAFSvyhCYNmpm5xQ9+CXm0MSUDkgt4hL/c5S7JYgcfxp5ShlidcyBJ1nPakNYUnKNc3ZvRdi33HTHyi7lxMZCO3j1ntx96hDL1j3MmKeiUWVwCxcbcUi378AWEs3hCiLvDNRCci+UN8Fcv6t8pb6PUmkSnuSFN/mD/lZAkeoTfkfhpMgJO+d75AxsdtzsRWELGQPgyMOHwgawubfQZGbDXtj1Sckk7NGZDeul3Ydisinnbs3zYqfnrimZDNUnrZhd6MTf3gkD+9OL4YSMiPubiZAqt0RacLVxjKoXnCEYVJpySxWa0x4IURZCONXx68hNDLyctTq0LD+Wm/H6t+dS7NdAXhU9ppFlQx0efgGhOg+20sdURzs8hxp63PuuLBoU6nC8pk3lFiAbYDlB2tYzasomizT+MSJBEqoWL57frwEzjBmYzsrOwHqAD6pPgqiqIePX+XUv0Bfm3nVbVYuw2DQyLVVW0rHgTbNsYytLIm+HQFb7tXZNUt114vAKvVyeJzwJ+eBMGXQcCfwwJ85xFa93jVge/z6ooq4C+duF9DxtbZqqR4/TqEItjZFF4Y3Li+ddHFsl5ZZLDHXi/brLUhm58Aq98VQI+IYcUoGKSIue/BAUbnNqbBlwfiwgL3oMC+PHCIaIt24R4MKEnUQC8ifti33yUDSvaPVt1HzHaAQQdehxq/G7UUZlKNkl1E/uynXnyKpiOmqIIU4t/Liuk5cqYze/am3GPfGBAcd72m5TTajWTBQCnWLlwchO2WQ7lpnZiBDaUZteRRkZxryfy6eLMZlKoIVDeaNwDLA9Dxmt/lFkZRSZ5rnIKbIq+o7KzHYpcCfAwuRUc2LVcchIiZRoq5du7PP1sZAwVSK+WGIxCFuauk4p1JBW4UCPV4zLLhromCSlO1euozpZSP40XEUi6xFzjEEoFKzJiyejrKebKLPndE5WduEWo1HpoAGMbGhG444HBvqfkrxydVct/WJKzy+oa9Df9sC+Q="}');
                response.setStatusCode(500);
                
                String continuationLabel = IntegrationEngine.continuationLabel;
                List<String> labels = new List<String>{continuationLabel};
                    Object continuationState= IntegrationEngine.continuationState;
                String voterCallOutResponse='';
                Test.startTest();
                Test.setContinuationResponse(continuationLabel, response);
                voterCallOutResponse= (String)IntegrationEngine.processVoterIdCallOutResponse(labels, IntegrationEngine.continuationState);
                Test.stopTest();
                
                String responseExpected ='{"body":null,"ResponseData":{"Status":"Success","ResponseInfo":{"SolutionSetInstanceId":"1b30af9d-8420-4b17-b3e3-6351c0d70656","ApplicationId":26585600},"Fields":{"ApplicationId":"26585600","ApplicationData":{"Services":{"Service":{"Skip":"N","Name":"SDE034","Id":"","EnableSimulation":"","Consent":"true"}}},"Applicants":{"Applicant":{"Telephones":{"Telephone":{"TelephoneType":"01","TelephoneNumber":"9402615811"}},"Services":{"Service":[{"Status":"Pass","Operations":{"Operation":[{"Status":"Pass","Id":"SDE034P001","Errors":null,"Data":{"Response":{"RawResponse":"{\\"request_id\\":\\"26585603\\",\\"status\\":\\"101\\",\\"timestamp\\":\\"12/14/2021 8:25:38 PM\\",\\"description\\":\\"Sucess\\",\\"result\\":[{\\"name\\":\\"DREMA\\",\\"gender\\":\\"F\\",\\"age\\":\\"31\\",\\"ac_name\\":\\"TAWANG\\",\\"epic_no\\":\\"AR01002024213\\",\\"ps_lat_long\\":\\"27.589542,91.861294\\",\\"email_id\\":\\"\\",\\"rln_type\\":\\"F\\",\\"rln_name\\":\\"PHURPA TSERING\\",\\"district\\":\\"\\",\\"state\\":\\"ARUNACHAL PRADESH\\",\\"ac_no\\":\\"2\\",\\"house_no\\":\\"E-113\\",\\"mob_no\\":\\"9402615811\\",\\"pincode\\":\\"900000\\",\\"ps_name\\":\\"GOVT. MIDDLE SCHOOL,SHYO\\",\\"pc_name\\":\\"ARUNACHAL WEST\\",\\"dob_derived\\":\\"08/01/1987\\",\\"part_name\\":\\"SHYO\\",\\"part_no\\":\\"12\\",\\"pc_no\\":\\"1.0\\",\\"dist_name\\":\\"TAWANG\\",\\"st_code\\":\\"S02\\",\\"last_update\\":\\"MON JUN 10 23:10:09 IST 2019\\"}]}"}}}]},"Name":"SDE034","Id":"SDE034"}]},"Identifiers":null,"ApplicantIdentifier":"c499a0cd-6fee-45a1-8497-0f15c392e518"}}}},"RequestId":"14122021202535835"}';
                System.assertEquals(responseExpected, voterCallOutResponse,'Success');
            }
        } catch(Exception ex){
            System.assertEquals(ex.getMessage(),'No Response Found.');
        }
    }
    
    //added by Hemanth Thikka
    @isTest
    public static void testOne(){
        Opportunity opgt1 = new Opportunity();
        opgt1.StageName = 'Qualification';
        opgt1.CloseDate = Date.newInstance(2021, 1, 11);
        opgt1.Name = 'testone';
        insert opgt1;
        
        Applicant__c apgt1 = new Applicant__c();
        apgt1.Opportunity__c = opgt1.Id;
        apgt1.Contact_number__c = '9743514830';
        apgt1.Applicant_Type__c = 'Borrower';
        insert apgt1;
        
        Income_Details__c idt1 = new Income_Details__c();
        idt1.Applicant__c = apgt1.Id;
        idt1.API_Transaction_Status__c = 'testapi';
        idt1.Bank_Account_Number__c = '32543409214';
        idt1.Client_Transaction_Id__c = 'testclient';
        idt1.Remarks__c = 'no comments';
        insert idt1;
        
        RequestWrapper rw1 = new RequestWrapper();
        rw1.applicantId = apgt1.Id;
        rw1.panNumber = apgt1.PAN_No__c;
        rw1.firstName = 'testone';
        rw1.lastName = 'testlast';
        rw1.dealNumber = 'testdl';
        rw1.dateOfBirth = '23061994';
        rw1.telephoneNumber = '9999999999';
        rw1.kycNo = '4635643';
        rw1.kycPassportFileNo = 'pt23556';
        rw1.kycGender = 'male';
        rw1.kycPassportNo = '232041';
        rw1.leadId = '676476368';
        rw1.email = 'test@gmail.com';
        rw1.income = '200000';
        rw1.aadhaarNo = '56678862431';
        rw1.dOB = Datetime.newInstance(1994, 6, 23, 12, 30, 0);
        rw1.vehicleRegisterationNumber = 'ap 26 1234';
        rw1.loanApplicationId = opgt1.Id;
        rw1.noOfCoborrowers = '8';
        rw1.vehicleType = 'TwoWheelers';
        rw1.CityId = '26';
        rw1.VariantCode = 'test123';
        rw1.customerCode = 'samplle123';
        rw1.oldDealNo = 'test453';
        rw1.nocNo = '45545667';
        rw1.product = 'testprd';
        rw1.category = 'motor';
        rw1.subCategory = 'testsub';
        rw1.applicantId = 'testapid';
        rw1.cicNo = '1234';
        rw1.emailTo = 'samplw@gmail.com';
        rw1.emailCC = 'testcc@gmail.com';
        rw1.emailSubject = 'testclass';
        rw1.emailBody = 'testbody';
        rw1.loanAmount = '1500000';
        rw1.loanDuration = '60';
        rw1.loanType = 'Personal';
        rw1.processingType = 'typeone';
        rw1.acceptancePolicy = 'test';
        rw1.uploadingScannedStatements = 'docs';
        rw1.yearMonthFrom = '6';
        rw1.yearMonthTo = '10';
        rw1.productType = 'vehicle';
        rw1.employmentType = 'permenant';
        rw1.employerName = 'dhoni';
        rw1.fileId = 'testfield';
        rw1.institutionId = '23';
        rw1.password = '12345';
        rw1.perfiosTransactionId = 'testper';
        rw1.uid = '134455';
        rw1.otp = '764345';
        rw1.txn = '4566633445';
        rw1.rnn = 'testrnn';
        rw1.applicantFirstName = 'mahi';
        rw1.applicantMiddleName = 'singh';
        rw1.applicantLastName = 'dhoni';
        rw1.name = 'name';
        rw1.destinationName = 'ap';
        rw1.destinationNames = 'ap';
        rw1.cinNo = 'testcin';
        rw1.applicationNo = '134355544655';
        rw1.vehicleId = 'v34566';
        rw1.age = '26';
        rw1.gender = 'male';
        rw1.insProduct = 'testprd';
        rw1.planCode = 'testplan';
        rw1.Fin_Amount = '50000';
        rw1.tenure = '36';
        rw1.dealNumber = 'Insurance Premium';
        rw1.Borrower_Type = 'Insurance Recommendation';
        rw1.Vehicle_Category = 'Insurance Recommendation';
        rw1.Variant = 'Insurance Recommendation';
        rw1.Fin_Amount = '1000';
        rw1.Balance_Available = '100';
        rw1.Agreement_Value = '10000';
        rw1.Motor_Expiry_Date = '2023-12-11';
        rw1.Motor_Premium = '1000';
        rw1.coBorrowerPanNumber = 'BTWSA3241J';
        rw1.coBorrowerDob = datetime.newInstance(1995, 9, 15, 12, 30, 0);
        rw1.coBorrowerIncome = '200000';
        rw1.coBorrowerCinNo = '3445666';
        rw1.contactNumber = '8888888888';
        rw1.otpForBorrower = '345643';
        rw1.flag = 'testflag';
        rw1.valuerCategory = 'tetsvaluer';
        rw1.placeOfInspection = 'city';
        rw1.locationOfVehicle = 'ap';
        rw1.city = 'nellore';
        rw1.state = 'ap';
        rw1.incomeDtlId = idt1.Id;
        rw1.gstType = 'testgst';
        rw1.itrType = 'testitr';
        rw1.bankType = 'national';
        rw1.GstNumber = 'g667438383883';
        rw1.kycDOB = Date.newInstance(1995, 9, 15);
        rw1.year = '2020';
        rw1.month = '6';
        rw1.stateCode = '29';
        rw1.color = 'red';
        rw1.owner = 'testowner';
        rw1.kilometer = '200';
        rw1.incomeDetailId = idt1.Id;
        rw1.incomeDetails = idt1;
        rw1.whatsappNo = '7777777777';
        rw1.reportType = 'Account';
        rw1.enachStatus = 'testenach';
        rw1.contentId = 'con1234';
        rw1.crmIrrRequested = 'testcrm123';
        rw1.exShowroomPrice = '40000';
        rw1.onRoadPrice = '70000';
        rw1.finalTermId = 'testfinal';
        rw1.fundingOnExShowroom = '4000';
        rw1.fundingOnORP = 'teston';
        rw1.currentScreen = 'testscreen';
        rw1.sumOfFundedInsurance = '40000';
        rw1.riskBand = 'testrisk';
        rw1.borrowerNIP = 'testnip';
        rw1.coBorrowerNIP = 'conip';
        rw1.borrowerPresentAddress = 'testadd';
        rw1.coBorrowerPresentAddress = 'testcoadd';
        rw1.emi = '1000';
        rw1.subProduct = 'testsub';
        rw1.thresholdNetIRR = 'testirr';
        
        Test.startTest();
        IND_VoterIdRequest vr1 = new IND_VoterIdRequest(rw1);
        Map<String,String> vrh1 = vr1.getHttpRequestHeaders();
        Test.stopTest();
    }
    
}