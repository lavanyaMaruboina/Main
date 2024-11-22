@isTest(SeeAllData=false)
public class IND_DocAuthDocumentReportServiceTest {
    
    
    @isTest
    public static void testIND_DocAuthDocumentReportService(){
        
        try{   
            
            Profile p = [SELECT Id FROM Profile WHERE Name='CMU'];
            system.debug('p'+ p);
            User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                              EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                              LocaleSidKey='en_US', ProfileId = p.Id,  MobilePhone = '9701498575',
                              Maker_Id__c='1002',
                              TimeZoneSidKey='America/Los_Angeles',
                              UserName='standarduser4@testorg.com.psdev1');
            insert u;
            System.runAs(u){
                Opportunity opp = TestDataUtility.createTestOpportunity(false);
                if (Schema.sObjectType.Opportunity.isCreateable()){
                    insert opp;
                }
                Applicant__c applicant = TestDataUtility.createTestApplicant(false);
                applicant.Opportunity__c=opp.Id;
                if (Schema.sObjectType.Applicant__c.isCreateable()){
                    insert applicant;
                }
                Documents__c document1 = TestDataUtility.createTestPPDocsForInternalDedupe(false,applicant,opp);
                if (Schema.sObjectType.Documents__c.isCreateable()){
                    insert document1;
                }
                String docId = '00671000001DVS1AAO';
                String loanAppId = '00671000001DVS1AAO';
                //Continuation con = (Continuation)IntegrationEngine.doDocAuthReportAsyncCallout(applicant.Id,loanAppId,loanAppId);
                // Create a mock response
                HttpResponse response = new HttpResponse();
                response.setBody('{"JData":"BWHtZwTWQ/utALn0CIZraGVD9vaxcefI/j1bjsgIfJYfEMn21c+0Vg5ZzhRHl1vQ+5H1u3+Q+3MmWINb7BRiqezb35fu/tci3tm84p+95InNu94gN2Ogm6QSjgTH7t6wPrhx3nGCFl2+b4c04AI/9FAwTjsfDpDwC5WmNPmVYmw1O6sippneyRdCdJiFI4EBRgyniXuJOx+YLTx1iDjyMAig29G/v2e30xLgW4OKBguP1643CTALK845WM4LmYhRFrNUMHBnwCNRPSbK3oFFnjq903Of1TtdV5uSdVb40aGuU7703wRZlU06O5EjuPeju8FzIZfNRI215spTkn9a02KE6dKaJyg4LXeHppwPjxSa/Js2kJNHr41FZyhxB73Eh97zigJ65BTWkHurERKJG8U89FQBJBr7+VP0qSY/53nOmEgcBMoI/oNTceyEcKbvLdgifFn4iJ88GFIxMjRGUrPJzlcPU/dMpkKJf3vMhZnrjbi13IVuktFldeF2ZcVo0fkcwQDrTlqv5aRwPOXFMad6lbvexLyhAEtTYbP3GT6XE4hkEp8s/GsCyMt1EuagDzuUlB0neibMAVJWryUjTeH7gQjuJCzvrPBq27DTb7Q+1b6ngJdM6G3arm3rjQH+s4+09h43QHwU2lEsKQ1MErennUp3ch0XsbDuRQzSrxT50nB7sw+IYLHmhSG1khAd3WskQHFHg1YC3EhQKEej+jINnISPo2Ku8SojNU4bGOCbV6fhTuvfX+NYy71zdCImHrpUC0iIUNo2oXap4ldZhCfwT8uZKQqHy+5KgPd7P9VSUdzqHlnwLWSocqogJ+ku1hDzngttd1UmiYiFhWD7XTYJUIMxPfIMwdQ2fHJHmK8EjhJJlSPQzQ0k5MkgcSdX+pNChUL6xeopyBn+125PS7bSyFIOdP58hpwn4K5fOG0xHn8slbtg7OUzFnVcUCWPOr+fUIKZE/wMT15jAj2tQ0t9Lf3iGrYX5VhP9tSWUuKtvcE+Pt6MFPY9wx6xBr5oVN44puWH9E+UXTORFwQgJnzPuc3Ehiujea1WPOCmkF59ferJy7r83wrcgNXNK57N0SobV5urJehlLYJyUD4UPSwx2NS1Xqop+oVOgXYiFkWVgq35DbTCKRpHwnT/CWOQAUsOx1kobsvIVcDlIH94WjVqo0+UdBogYcA6GwyHz3wTUmgPweOsmQoJtKKEm+QcPwSV/pT0xBK24mXrWU8kc4S3NjP0rR6pyuKocUtroexT+99k8TdOQXFlGKAkN2+q1jtGLbz+hEH97Uc0xFCbW2f6HyeGMMxLZ4tzch3pgntTg0q5tB1R7TWHspRQsC6nyEtju10XrEZLXundUYTTVyrEclyhTEOHa8stEsRSH48s/ejDDqLcZrdKxKHUJvb2q2L/Aelx2UjYGrMMu4LJ8S5tghfgVuLSwQuiWKDdmL5YxKiE0thZsAHO94JeH0T2M63CniQmIfTBB6EUINv8qgsxkF0YO+2ArA5hwFFkHQQq22Xw/YkYnnYoWEt46RCfijoTcHIiL3MSxw587KvnuVyjz8YUcz/8TVmWb9Lpo6ruzj7eLciOpaGsJ5uHT5lCuH8DQBrXOI3x27lHwnTI/oq1Joqq0xDEG1a5o50OdRXtIAnljkMjJOm7jUTxmeYWA6PEbY69k/Kd2SEJRJwzjXC3YvQrFrh+pjol/qj5zP3Y4UpNeOr4ZzNeWwJAP/MWehXm+3+bnvM5fByt5G1j0w=="}');
                response.setStatusCode(200);
                
                String continuationLabel = IntegrationEngine.continuationLabel;
                List<String> labels = new List<String>{continuationLabel};
                    Object continuationState= IntegrationEngine.continuationState;
                
                String createapplicantCallOutResponse;
                system.runAs(u){
                    Test.startTest();
                    Test.setContinuationResponse(continuationLabel, response);
                    createapplicantCallOutResponse= (String)IntegrationEngine.processDocAuthCreateApplicantResponse(labels, IntegrationEngine.continuationState);
                    Test.stopTest();
                }
                String responseActual ='{"body":null,"ResponseData":{"Status":"Success","ResponseInfo":{"SolutionSetInstanceId":"7c5d206d-70a2-4fdc-9732-caedd105fe48","ApplicationId":26573693},"Fields":{"Decision":"Pass","ApplicationId":"26573693","ApplicationData":{"Services":{"Service":{"Skip":"N","Name":"DocumentAuthentication","Id":"","EnableSimulation":"False","Consent":"true"}}},"Applicants":{"Applicant":{"Services":{"Service":[{"Status":"Pass","Operations":{"Operation":[{"Status":"Pass","Params":{"Param":[]},"Name":"Createapplicant","Id":"","Errors":null,"Data":{"Response":{"RawResponse":"{\\"addresses\\":[],\\"country\\":\\"gbr\\",\\"country_of_birth\\":null,\\"created_at\\":\\"2021-12-12T11:16:20Z\\",\\"delete_at\\":null,\\"dob\\":null,\\"email\\":null,\\"first_name\\":\\"GOURAB\\",\\"gender\\":null,\\"href\\":\\"/v2/applicants/aef797fe-7311-460b-8895-8abbfce61b56\\",\\"id\\":\\"aef797fe-7311-460b-8895-8abbfce61b56\\",\\"id_numbers\\":[],\\"last_name\\":\\"GOSWAMI\\",\\"middle_name\\":null,\\"mobile\\":null,\\"mothers_maiden_name\\":null,\\"nationality\\":null,\\"previous_last_name\\":null,\\"sandbox\\":false,\\"telephone\\":null,\\"title\\":null,\\"town_of_birth\\":null}"}}}]},"Name":"DocumentAuthentication","Id":""}]},"ApplicantMiddleName":"","ApplicantLastName":"GOSWAMI","ApplicantIdentifier":"8b5f45b8-3482-4373-acfd-b6db16ebfd21","ApplicantFirstName":"GOURAB"}}}},"RequestId":"12122021164613581"}';
                System.assertEquals(responseActual,createapplicantCallOutResponse, 'SUCCESS');
            }
        } catch(Exception ex){
            System.assertEquals(ex.getMessage(),'Null label', 'Exception');
        }
    }
    
    @isTest
    public static void testDocAuthCreateApplicantService2(){
        
        try{   
            
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            Applicant__c applicant = TestDataUtility.createTestApplicantForDocAuth(false);
            applicant.Opportunity__c=opp.Id;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert applicant;
            }
            String loanAppId = '00671000001DVS1AAO';
            Continuation con = (Continuation)IntegrationEngine.doDocAuthCreateApplicantCallout(applicant.Id,loanAppId);
            // Create a mock response
            HttpResponse response = new HttpResponse();
            response.setBody('{"JData":"BWHtZwTWQ/utALn0CIZraGVD9vaxcefI/j1bjsgIfJYfEMn21c+0Vg5ZzhRHl1vQ+5H1u3+Q+3MmWINb7BRiqezb35fu/tci3tm84p+95InNu94gN2Ogm6QSjgTH7t6wPrhx3nGCFl2+b4c04AI/9FAwTjsfDpDwC5WmNPmVYmw1O6sippneyRdCdJiFI4EBRgyniXuJOx+YLTx1iDjyMAig29G/v2e30xLgW4OKBguP1643CTALK845WM4LmYhRFrNUMHBnwCNRPSbK3oFFnjq903Of1TtdV5uSdVb40aGuU7703wRZlU06O5EjuPeju8FzIZfNRI215spTkn9a02KE6dKaJyg4LXeHppwPjxSa/Js2kJNHr41FZyhxB73Eh97zigJ65BTWkHurERKJG8U89FQBJBr7+VP0qSY/53nOmEgcBMoI/oNTceyEcKbvLdgifFn4iJ88GFIxMjRGUrPJzlcPU/dMpkKJf3vMhZnrjbi13IVuktFldeF2ZcVo0fkcwQDrTlqv5aRwPOXFMad6lbvexLyhAEtTYbP3GT6XE4hkEp8s/GsCyMt1EuagDzuUlB0neibMAVJWryUjTeH7gQjuJCzvrPBq27DTb7Q+1b6ngJdM6G3arm3rjQH+s4+09h43QHwU2lEsKQ1MErennUp3ch0XsbDuRQzSrxT50nB7sw+IYLHmhSG1khAd3WskQHFHg1YC3EhQKEej+jINnISPo2Ku8SojNU4bGOCbV6fhTuvfX+NYy71zdCImHrpUC0iIUNo2oXap4ldZhCfwT8uZKQqHy+5KgPd7P9VSUdzqHlnwLWSocqogJ+ku1hDzngttd1UmiYiFhWD7XTYJUIMxPfIMwdQ2fHJHmK8EjhJJlSPQzQ0k5MkgcSdX+pNChUL6xeopyBn+125PS7bSyFIOdP58hpwn4K5fOG0xHn8slbtg7OUzFnVcUCWPOr+fUIKZE/wMT15jAj2tQ0t9Lf3iGrYX5VhP9tSWUuKtvcE+Pt6MFPY9wx6xBr5oVN44puWH9E+UXTORFwQgJnzPuc3Ehiujea1WPOCmkF59ferJy7r83wrcgNXNK57N0SobV5urJehlLYJyUD4UPSwx2NS1Xqop+oVOgXYiFkWVgq35DbTCKRpHwnT/CWOQAUsOx1kobsvIVcDlIH94WjVqo0+UdBogYcA6GwyHz3wTUmgPweOsmQoJtKKEm+QcPwSV/pT0xBK24mXrWU8kc4S3NjP0rR6pyuKocUtroexT+99k8TdOQXFlGKAkN2+q1jtGLbz+hEH97Uc0xFCbW2f6HyeGMMxLZ4tzch3pgntTg0q5tB1R7TWHspRQsC6nyEtju10XrEZLXundUYTTVyrEclyhTEOHa8stEsRSH48s/ejDDqLcZrdKxKHUJvb2q2L/Aelx2UjYGrMMu4LJ8S5tghfgVuLSwQuiWKDdmL5YxKiE0thZsAHO94JeH0T2M63CniQmIfTBB6EUINv8qgsxkF0YO+2ArA5hwFFkHQQq22Xw/YkYnnYoWEt46RCfijoTcHIiL3MSxw587KvnuVyjz8YUcz/8TVmWb9Lpo6ruzj7eLciOpaGsJ5uHT5lCuH8DQBrXOI3x27lHwnTI/oq1Joqq0xDEG1a5o50OdRXtIAnljkMjJOm7jUTxmeYWA6PEbY69k/Kd2SEJRJwzjXC3YvQrFrh+pjol/qj5zP3Y4UpNeOr4ZzNeWwJAP/MWehXm+3+bnvM5fByt5G1j0w=="}');
            response.setStatusCode(200);
            
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
                Object continuationState= IntegrationEngine.continuationState;
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
            String createapplicantCallOutResponse= (String)IntegrationEngine.processDocAuthCreateApplicantResponse(labels, IntegrationEngine.continuationState);
            Test.stopTest();
            String responseActual ='{"body":null,"ResponseData":{"Status":"Success","ResponseInfo":{"SolutionSetInstanceId":"7c5d206d-70a2-4fdc-9732-caedd105fe48","ApplicationId":26573693},"Fields":{"Decision":"Pass","ApplicationId":"26573693","ApplicationData":{"Services":{"Service":{"Skip":"N","Name":"DocumentAuthentication","Id":"","EnableSimulation":"False","Consent":"true"}}},"Applicants":{"Applicant":{"Services":{"Service":[{"Status":"Pass","Operations":{"Operation":[{"Status":"Pass","Params":{"Param":[]},"Name":"Createapplicant","Id":"","Errors":null,"Data":{"Response":{"RawResponse":"{\\"addresses\\":[],\\"country\\":\\"gbr\\",\\"country_of_birth\\":null,\\"created_at\\":\\"2021-12-12T11:16:20Z\\",\\"delete_at\\":null,\\"dob\\":null,\\"email\\":null,\\"first_name\\":\\"GOURAB\\",\\"gender\\":null,\\"href\\":\\"/v2/applicants/aef797fe-7311-460b-8895-8abbfce61b56\\",\\"id\\":\\"aef797fe-7311-460b-8895-8abbfce61b56\\",\\"id_numbers\\":[],\\"last_name\\":\\"GOSWAMI\\",\\"middle_name\\":null,\\"mobile\\":null,\\"mothers_maiden_name\\":null,\\"nationality\\":null,\\"previous_last_name\\":null,\\"sandbox\\":false,\\"telephone\\":null,\\"title\\":null,\\"town_of_birth\\":null}"}}}]},"Name":"DocumentAuthentication","Id":""}]},"ApplicantMiddleName":"","ApplicantLastName":"GOSWAMI","ApplicantIdentifier":"8b5f45b8-3482-4373-acfd-b6db16ebfd21","ApplicantFirstName":"GOURAB"}}}},"RequestId":"12122021164613581"}';
            System.assertEquals(responseActual,createapplicantCallOutResponse, 'SUCCESS');
            
        } catch(Exception ex){
            System.assertEquals(ex.getMessage(),System.Label.LastName, 'Exception');
        }
    }
    
    @isTest
    public static void testDocAuthCreateApplicantService3(){
        
        try{   
            
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            Applicant__c applicant = TestDataUtility.createTestApplicantForDocAuth2(false);
            applicant.Opportunity__c=opp.Id;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert applicant;
            }
            String loanAppId = '00671000001DVS1AAO';
            Continuation con = (Continuation)IntegrationEngine.doDocAuthCreateApplicantCallout(applicant.Id,loanAppId);
            // Create a mock response
            HttpResponse response = new HttpResponse();
            response.setBody('{"JData":"BWHtZwTWQ/utALn0CIZraGVD9vaxcefI/j1bjsgIfJYfEMn21c+0Vg5ZzhRHl1vQ+5H1u3+Q+3MmWINb7BRiqezb35fu/tci3tm84p+95InNu94gN2Ogm6QSjgTH7t6wPrhx3nGCFl2+b4c04AI/9FAwTjsfDpDwC5WmNPmVYmw1O6sippneyRdCdJiFI4EBRgyniXuJOx+YLTx1iDjyMAig29G/v2e30xLgW4OKBguP1643CTALK845WM4LmYhRFrNUMHBnwCNRPSbK3oFFnjq903Of1TtdV5uSdVb40aGuU7703wRZlU06O5EjuPeju8FzIZfNRI215spTkn9a02KE6dKaJyg4LXeHppwPjxSa/Js2kJNHr41FZyhxB73Eh97zigJ65BTWkHurERKJG8U89FQBJBr7+VP0qSY/53nOmEgcBMoI/oNTceyEcKbvLdgifFn4iJ88GFIxMjRGUrPJzlcPU/dMpkKJf3vMhZnrjbi13IVuktFldeF2ZcVo0fkcwQDrTlqv5aRwPOXFMad6lbvexLyhAEtTYbP3GT6XE4hkEp8s/GsCyMt1EuagDzuUlB0neibMAVJWryUjTeH7gQjuJCzvrPBq27DTb7Q+1b6ngJdM6G3arm3rjQH+s4+09h43QHwU2lEsKQ1MErennUp3ch0XsbDuRQzSrxT50nB7sw+IYLHmhSG1khAd3WskQHFHg1YC3EhQKEej+jINnISPo2Ku8SojNU4bGOCbV6fhTuvfX+NYy71zdCImHrpUC0iIUNo2oXap4ldZhCfwT8uZKQqHy+5KgPd7P9VSUdzqHlnwLWSocqogJ+ku1hDzngttd1UmiYiFhWD7XTYJUIMxPfIMwdQ2fHJHmK8EjhJJlSPQzQ0k5MkgcSdX+pNChUL6xeopyBn+125PS7bSyFIOdP58hpwn4K5fOG0xHn8slbtg7OUzFnVcUCWPOr+fUIKZE/wMT15jAj2tQ0t9Lf3iGrYX5VhP9tSWUuKtvcE+Pt6MFPY9wx6xBr5oVN44puWH9E+UXTORFwQgJnzPuc3Ehiujea1WPOCmkF59ferJy7r83wrcgNXNK57N0SobV5urJehlLYJyUD4UPSwx2NS1Xqop+oVOgXYiFkWVgq35DbTCKRpHwnT/CWOQAUsOx1kobsvIVcDlIH94WjVqo0+UdBogYcA6GwyHz3wTUmgPweOsmQoJtKKEm+QcPwSV/pT0xBK24mXrWU8kc4S3NjP0rR6pyuKocUtroexT+99k8TdOQXFlGKAkN2+q1jtGLbz+hEH97Uc0xFCbW2f6HyeGMMxLZ4tzch3pgntTg0q5tB1R7TWHspRQsC6nyEtju10XrEZLXundUYTTVyrEclyhTEOHa8stEsRSH48s/ejDDqLcZrdKxKHUJvb2q2L/Aelx2UjYGrMMu4LJ8S5tghfgVuLSwQuiWKDdmL5YxKiE0thZsAHO94JeH0T2M63CniQmIfTBB6EUINv8qgsxkF0YO+2ArA5hwFFkHQQq22Xw/YkYnnYoWEt46RCfijoTcHIiL3MSxw587KvnuVyjz8YUcz/8TVmWb9Lpo6ruzj7eLciOpaGsJ5uHT5lCuH8DQBrXOI3x27lHwnTI/oq1Joqq0xDEG1a5o50OdRXtIAnljkMjJOm7jUTxmeYWA6PEbY69k/Kd2SEJRJwzjXC3YvQrFrh+pjol/qj5zP3Y4UpNeOr4ZzNeWwJAP/MWehXm+3+bnvM5fByt5G1j0w=="}');
            response.setStatusCode(200);
            
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
                Object continuationState= IntegrationEngine.continuationState;
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
            String createapplicantCallOutResponse= (String)IntegrationEngine.processDocAuthCreateApplicantResponse(labels, IntegrationEngine.continuationState);
            Test.stopTest();
            String responseActual ='{"body":null,"ResponseData":{"Status":"Success","ResponseInfo":{"SolutionSetInstanceId":"7c5d206d-70a2-4fdc-9732-caedd105fe48","ApplicationId":26573693},"Fields":{"Decision":"Pass","ApplicationId":"26573693","ApplicationData":{"Services":{"Service":{"Skip":"N","Name":"DocumentAuthentication","Id":"","EnableSimulation":"False","Consent":"true"}}},"Applicants":{"Applicant":{"Services":{"Service":[{"Status":"Pass","Operations":{"Operation":[{"Status":"Pass","Params":{"Param":[]},"Name":"Createapplicant","Id":"","Errors":null,"Data":{"Response":{"RawResponse":"{\\"addresses\\":[],\\"country\\":\\"gbr\\",\\"country_of_birth\\":null,\\"created_at\\":\\"2021-12-12T11:16:20Z\\",\\"delete_at\\":null,\\"dob\\":null,\\"email\\":null,\\"first_name\\":\\"GOURAB\\",\\"gender\\":null,\\"href\\":\\"/v2/applicants/aef797fe-7311-460b-8895-8abbfce61b56\\",\\"id\\":\\"aef797fe-7311-460b-8895-8abbfce61b56\\",\\"id_numbers\\":[],\\"last_name\\":\\"GOSWAMI\\",\\"middle_name\\":null,\\"mobile\\":null,\\"mothers_maiden_name\\":null,\\"nationality\\":null,\\"previous_last_name\\":null,\\"sandbox\\":false,\\"telephone\\":null,\\"title\\":null,\\"town_of_birth\\":null}"}}}]},"Name":"DocumentAuthentication","Id":""}]},"ApplicantMiddleName":"","ApplicantLastName":"GOSWAMI","ApplicantIdentifier":"8b5f45b8-3482-4373-acfd-b6db16ebfd21","ApplicantFirstName":"GOURAB"}}}},"RequestId":"12122021164613581"}';
            System.assertEquals(responseActual,createapplicantCallOutResponse, 'SUCCESS');
            
        } catch(Exception ex){
            System.assertEquals(ex.getMessage(),System.Label.FirstName, 'Exception');
        }
    }
    
    
    
    @isTest
    public static void testDocAuthCreateApplicantService5(){
        
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
            String loanAppId = '00671000001DVS1AAO';
            Continuation con = (Continuation)IntegrationEngine.doDocAuthCreateApplicantCallout(applicant.Id,loanAppId);
            // Create a mock response
            HttpResponse response = new HttpResponse();
            response.setBody('{"JData":"BWHtZwTWQ/utALn0CIZraGVD9vaxcefI/j1bjsgIfJYfEMn21c+0Vg5ZzhRHl1vQ+5H1u3+Q+3MmWINb7BRiqezb35fu/tci3tm84p+95InNu94gN2Ogm6QSjgTH7t6wPrhx3nGCFl2+b4c04AI/9FAwTjsfDpDwC5WmNPmVYmw1O6sippneyRdCdJiFI4EBRgyniXuJOx+YLTx1iDjyMAig29G/v2e30xLgW4OKBguP1643CTALK845WM4LmYhRFrNUMHBnwCNRPSbK3oFFnjq903Of1TtdV5uSdVb40aGuU7703wRZlU06O5EjuPeju8FzIZfNRI215spTkn9a02KE6dKaJyg4LXeHppwPjxSa/Js2kJNHr41FZyhxB73Eh97zigJ65BTWkHurERKJG8U89FQBJBr7+VP0qSY/53nOmEgcBMoI/oNTceyEcKbvLdgifFn4iJ88GFIxMjRGUrPJzlcPU/dMpkKJf3vMhZnrjbi13IVuktFldeF2ZcVo0fkcwQDrTlqv5aRwPOXFMad6lbvexLyhAEtTYbP3GT6XE4hkEp8s/GsCyMt1EuagDzuUlB0neibMAVJWryUjTeH7gQjuJCzvrPBq27DTb7Q+1b6ngJdM6G3arm3rjQH+s4+09h43QHwU2lEsKQ1MErennUp3ch0XsbDuRQzSrxT50nB7sw+IYLHmhSG1khAd3WskQHFHg1YC3EhQKEej+jINnISPo2Ku8SojNU4bGOCbV6fhTuvfX+NYy71zdCImHrpUC0iIUNo2oXap4ldZhCfwT8uZKQqHy+5KgPd7P9VSUdzqHlnwLWSocqogJ+ku1hDzngttd1UmiYiFhWD7XTYJUIMxPfIMwdQ2fHJHmK8EjhJJlSPQzQ0k5MkgcSdX+pNChUL6xeopyBn+125PS7bSyFIOdP58hpwn4K5fOG0xHn8slbtg7OUzFnVcUCWPOr+fUIKZE/wMT15jAj2tQ0t9Lf3iGrYX5VhP9tSWUuKtvcE+Pt6MFPY9wx6xBr5oVN44puWH9E+UXTORFwQgJnzPuc3Ehiujea1WPOCmkF59ferJy7r83wrcgNXNK57N0SobV5urJehlLYJyUD4UPSwx2NS1Xqop+oVOgXYiFkWVgq35DbTCKRpHwnT/CWOQAUsOx1kobsvIVcDlIH94WjVqo0+UdBogYcA6GwyHz3wTUmgPweOsmQoJtKKEm+QcPwSV/pT0xBK24mXrWU8kc4S3NjP0rR6pyuKocUtroexT+99k8TdOQXFlGKAkN2+q1jtGLbz+hEH97Uc0xFCbW2f6HyeGMMxLZ4tzch3pgntTg0q5tB1R7TWHspRQsC6nyEtju10XrEZLXundUYTTVyrEclyhTEOHa8stEsRSH48s/ejDDqLcZrdKxKHUJvb2q2L/Aelx2UjYGrMMu4LJ8S5tghfgVuLSwQuiWKDdmL5YxKiE0thZsAHO94JeH0T2M63CniQmIfTBB6EUINv8qgsxkF0YO+2ArA5hwFFkHQQq22Xw/YkYnnYoWEt46RCfijoTcHIiL3MSxw587KvnuVyjz8YUcz/8TVmWb9Lpo6ruzj7eLciOpaGsJ5uHT5lCuH8DQBrXOI3x27lHwnTI/oq1Joqq0xDEG1a5o50OdRXtIAnljkMjJOm7jUTxmeYWA6PEbY69k/Kd2SEJRJwzjXC3YvQrFrh+pjol/qj5zP3Y4UpNeOr4ZzNeWwJAP/MWehXm+3+bnvM5fByt5G1j0w=="}');
            response.setStatusCode(500);
            
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
                Object continuationState= IntegrationEngine.continuationState;
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
            String createapplicantCallOutResponse= (String)IntegrationEngine.processDocAuthCreateApplicantResponse(labels, IntegrationEngine.continuationState);
            Test.stopTest();
            String responseActual ='{"body":null,"ResponseData":{"Status":"Success","ResponseInfo":{"SolutionSetInstanceId":"7c5d206d-70a2-4fdc-9732-caedd105fe48","ApplicationId":26573693},"Fields":{"Decision":"Pass","ApplicationId":"26573693","ApplicationData":{"Services":{"Service":{"Skip":"N","Name":"DocumentAuthentication","Id":"","EnableSimulation":"False","Consent":"true"}}},"Applicants":{"Applicant":{"Services":{"Service":[{"Status":"Pass","Operations":{"Operation":[{"Status":"Pass","Params":{"Param":[]},"Name":"Createapplicant","Id":"","Errors":null,"Data":{"Response":{"RawResponse":"{\\"addresses\\":[],\\"country\\":\\"gbr\\",\\"country_of_birth\\":null,\\"created_at\\":\\"2021-12-12T11:16:20Z\\",\\"delete_at\\":null,\\"dob\\":null,\\"email\\":null,\\"first_name\\":\\"GOURAB\\",\\"gender\\":null,\\"href\\":\\"/v2/applicants/aef797fe-7311-460b-8895-8abbfce61b56\\",\\"id\\":\\"aef797fe-7311-460b-8895-8abbfce61b56\\",\\"id_numbers\\":[],\\"last_name\\":\\"GOSWAMI\\",\\"middle_name\\":null,\\"mobile\\":null,\\"mothers_maiden_name\\":null,\\"nationality\\":null,\\"previous_last_name\\":null,\\"sandbox\\":false,\\"telephone\\":null,\\"title\\":null,\\"town_of_birth\\":null}"}}}]},"Name":"DocumentAuthentication","Id":""}]},"ApplicantMiddleName":"","ApplicantLastName":"GOSWAMI","ApplicantIdentifier":"8b5f45b8-3482-4373-acfd-b6db16ebfd21","ApplicantFirstName":"GOURAB"}}}},"RequestId":"12122021164613581"}';
            System.assertEquals(responseActual,createapplicantCallOutResponse, 'SUCCESS');
            
        } catch(Exception ex){
            // System.assertEquals(ex.getMessage(),'Please enter the Maker Id', 'Exception');
        }
    }
    
    @isTest
    public static void validateException(){
        Opportunity opp = TestDataUtility.createTestOpportunity(false);
        if (Schema.sObjectType.Opportunity.isCreateable()){
            insert opp;
        }
        Applicant__c applicant = TestDataUtility.createTestApplicantForDocAuth2(false);
        applicant.Opportunity__c=opp.Id;
        if (Schema.sObjectType.Applicant__c.isCreateable()){
            insert applicant;
        }
        IND_DocAuthDocumentReportService.drCallout(applicant);
        try{
            IND_DocAuthDocumentReportService.drCallout(null);
        }catch(Exception pEx){
            System.assert(pEx.getMessage() != null);
        }
        
        IND_DocAuthDocumentReportService.DocAuthReportAsyncCallout(applicant);
        try{
            IND_DocAuthDocumentReportService.DocAuthReportAsyncCallout(null);
        }catch(Exception pEx){
            System.assert(pEx.getMessage() != null);
        }
        
    }
    
    
}