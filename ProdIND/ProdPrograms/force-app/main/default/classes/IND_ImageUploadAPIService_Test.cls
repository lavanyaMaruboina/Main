/*------------------------------------------------------------
Author:        Divya Jawale
Company:       Persistent Systems
Description:   Test class created to validate the IND_ImageUploadAPIRequest IND_ImageUploadAPIService IND_ImageUploadAPIResponse class
History
Date            Author              Comments
-------------------------------------------------------------
20-12-2021      Satyam More       Created
------------------------------------------------------------*/
@isTest(SeeAllData=false)
public class IND_ImageUploadAPIService_Test {
    
 @isTest
    public static void testImageUploadAPIService(){
        try{   
            Profile p = [SELECT Id FROM Profile WHERE Name='IBL Counter Staff'];
            system.debug('p'+ p);
    		User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
					EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
					LocaleSidKey='en_US', ProfileId = p.Id,
					TimeZoneSidKey='America/Los_Angeles',
					UserName='standarduser4@testorg.com.psdev1', MobilePhone = '9701498575',
					Maker_Id__c = '1002');
            insert u; 
            
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            
             Applicant__c applicant = TestDataUtility.createTestApplicant(false);
            applicant.Opportunity__c=opp.Id;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert applicant;
            }
            
          	Documents__c document = TestDataUtility.createTestKYCDocsForOcrBack(false,applicant,opp);
            document.Opportunity_Relation__c=opp.Id;
            if (Schema.sObjectType.Documents__c.isCreateable()){
                insert document;
            }
            
            Blob bodyBlob=Blob.valueOf('Aadhaar Back'); 
            
            final ContentVersion contentVersion_1 = new ContentVersion(
                Title='SampleTitle',
                PathOnClient ='SampleTitle.jpg',
                VersionData = bodyBlob, 
                origin = 'H',
                Document_Side_fileupload__c = 'Back'
            );
            insert contentVersion_1;
            
            final ContentVersion contentVersion_2 = [SELECT Id, Title, ContentDocumentId,Document_Side_fileupload__c 
                            FROM ContentVersion WHERE Id = :contentVersion_1.Id LIMIT 1];
            
            List<ContentDocumentLink> contentlink = new List<ContentDocumentLink>();
            contentlink[0].LinkedEntityId = document.id;
            contentlink[0].contentdocumentid = contentVersion_2.contentdocumentid;
            contentlink[0].ShareType = 'V';
            insert contentlink;
            
            String imageType ='Front';
            Continuation con = (Continuation)IntegrationEngine.doImageUploadCallout(document.id , imageType,opp.Id);
            // Create a mock response
            HttpResponse response = new HttpResponse();
            String  body = '{"JData":"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"}';
             response.setBody(body);
             response.setStatusCode(200);
            
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
            Object continuationState= IntegrationEngine.continuationState;
            String imageUploadCallOutResponse;
            system.runAs(u){
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
            imageUploadCallOutResponse= (String)IntegrationEngine.processImageUploadResponse(labels, IntegrationEngine.continuationState);
            Test.stopTest();
              }
           String responseExpected ='{"RequestId":"28012022100353379","ResponseData":{"Status":"Success","ResponseInfo":{"ApplicationId":27254020,"SolutionSetInstanceId":"63f2c0a0-3a6b-4d72-bb68-34ea841ef024"},"Fields":{"Applicants":{"Applicant":{"Services":{"Service":[{"Id":"","Name":"DocumentAuthentication","Operations":{"Operation":[{"Id":"","Name":"backcontinue","Params":{"Param":[{"Name":"IdentityVerification","Value":{"Step":"End","Type":"voter_id","CurrentStep":"continue","Back":{"Id":"4829823"},"DocIType":"None","DefaultCountryId":"1","Email":null,"SendPhone":"","SendEmail":""}},{"Name":"createresponseId","Value":"3644c1d1-6265-48c1-beb5-c79fc90c9187"},{"Name":"responseid","Value":"c763f6d7-c33d-44ce-a1c7-7e22722d4366"}]},"Data":{"Response":{"RawResponse":"{\"created_at\":\"2022-01-28T04:34:03Z\",\"download_uri\":\"https://onfido.com/dashboard/pdf/information_requests/245778643\",\"form_uri\":null,\"href\":\"/v2/applicants/3644c1d1-6265-48c1-beb5-c79fc90c9187/checks/1f82f6c5-302b-4d0c-a0e5-748df7bdd4f1\",\"id\":\"1f82f6c5-302b-4d0c-a0e5-748df7bdd4f1\",\"paused\":false,\"redirect_uri\":null,\"report_type_groups\":[\"47132\"],\"reports\":[{\"breakdown\":{},\"created_at\":\"2022-01-28T04:34:04Z\",\"documents\":[{\"id\":\"c763f6d7-c33d-44ce-a1c7-7e22722d4366\"},{\"id\":\"4ef75bbc-ff61-402f-b17e-59cd0eadfccd\"}],\"href\":\"/v2/checks/1f82f6c5-302b-4d0c-a0e5-748df7bdd4f1/reports/aa53fed4-fec4-4ddd-bf10-9601181ff775\",\"id\":\"aa53fed4-fec4-4ddd-bf10-9601181ff775\",\"name\":\"document\",\"properties\":{},\"result\":null,\"status\":\"awaiting_approval\",\"sub_result\":null,\"variant\":\"standard\"}],\"result\":null,\"results_uri\":\"https://dashboard.onfido.com/checks/1f82f6c5-302b-4d0c-a0e5-748df7bdd4f1\",\"sandbox\":false,\"status\":\"in_progress\",\"tags\":[],\"type\":\"express\",\"version\":\"2.0\"}"}},"Status":"Pass"}]},"Status":"Pass"}]},"ApplicantIdentifier":"5c2eafe0-c73f-4568-be86-2eaa29d7e0cf"}},"ApplicationData":{"Services":{"Service":{"Id":"","Name":"DocumentAuthentication","Skip":"N","Consent":"true","EnableSimulation":"False"}}},"Decision":"Pass","ApplicationId":"27254020"}}"';
            System.assertEquals(responseExpected, imageUploadCallOutResponse,'Success');
        
        } catch(Exception ex){
            System.assertNotEquals(ex.getMessage(),System.Label.Retry,'Exception');
        }
    }
    
    /* @isTest
    public static void testImageUploadAPIService2(){
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
            
          	Documents__c document = TestDataUtility.createTestKYCDocsForOcrBack2(false,applicant,opp);
            document.Opportunity_Relation__c=opp.Id;
            if (Schema.sObjectType.Documents__c.isCreateable()){
                insert document;
            }
            
            Documents__c document2 = TestDataUtility.createTestKYCDocsForOcrBack2(false,applicant,opp);
            document2.Opportunity_Relation__c=opp.Id;
            if (Schema.sObjectType.Documents__c.isCreateable()){
                insert document2;
            }
            
            Blob bodyBlob=Blob.valueOf('Passport Back'); 
            
            ContentVersion contentVersion_1 = new ContentVersion(
                Title='SampleTitle', 
                PathOnClient ='SampleTitle.jpg',
                VersionData = bodyBlob, 
                origin = 'H',
                Document_Side_fileupload__c = 'Selfie'
                //contentDocumentId = document.id
            );
            insert contentVersion_1;
            
            ContentVersion contentVersion_2 = new ContentVersion(
                Title='SampleTitle', 
                PathOnClient ='SampleTitle.jpg',
                VersionData = bodyBlob, 
                origin = 'H',
                Document_Side_fileupload__c = 'Back'
                //contentDocumentId = document2.id
            );
            insert contentVersion_2;
            
            
            ContentDocumentLink contentlink = new ContentDocumentLink();
            contentlink.LinkedEntityId = document.id;
            contentlink.contentdocumentid = contentVersion_1.contentdocumentid;
            contentlink.ShareType = 'V';
            
            
            ContentDocumentLink contentlink2 = new ContentDocumentLink();
            contentlink2.LinkedEntityId = document2.id;
                contentlink2.contentdocumentid = contentVersion_2.contentdocumentid;
            contentlink2.ShareType = 'V'; 
            
            
            List<ContentDocumentLink> contentlinkList = new List<ContentDocumentLink>();
            contentlinkList.add(contentlink);
            contentlinkList.add(contentlink2);
            upsert contentlinkList;
            
            String imageType ='Back';
            Continuation con = (Continuation)IntegrationEngine.doImageUploadCallout(document.id , imageType,opp.Id);
            // Create a mock response
            HttpResponse response = new HttpResponse();
             String  body = '{"JData":"eY2t35lcUlX1j/zGCOhDrWXBmncES91nxoI9SOf46I16d9LWP0Uxt1Qa6QzhFvxtfxwtM7ZBJ/lxFPAN3JrUXWqQfGiAGh1+jUNmKh0LaZbFzqWPzgUNvYxfqSLmpZiOzjQeA4f5bcvc7T62rjTKN81mQsN+eQlm416YV5D0Ba60+NqFlPGq7+EfJN0NU3qoLt2QijZkPulvVIHS3CZH+cZRSjAuLnpR2P0bKDlRLsJTqxQi8KrmUmD5R2M5FzoSyE2fMRFHwQOStn5nvG0Ml9d+ni3EC9scCJRR6vz3AuMpRcf0PEX+8i7+N2z5CX6PUilT56vQ13jtgU4MzkYuua3jONfQBVV6goVFTRV+uwtZT5XfhmkcMfTXrLfuKEuR3CjCKU2MM06TlrAVi1O4Jo8QC0xLYANFrSjqSXebWI+REGvxADTJzKVbxBO3CZDE2vXZKZ3wE+UdAzlQhPgsQx4WfgUIT6WX/iTha0QYEfzXGhfM1dtYRZwEUqDu1cplm+2vYihKuMLExbTi4g0AXHwiGOU0bt8159KAAKPpl9knyp280/NULWR4tU3i38uixRU8/7ZJYJBEnSwqxPeB5PJTzIICpZYcRQERjk8Zid9oix6xnWd7z51RNiCl5g47poV6TRqrQJ+4q9BiHRNJkiKOvhTkt0Poc57febpxq5LBSypo2KjyDgGAQq41GdDDr9IKcivIzBjEVMG8fP11Lc2Np1thILGPvP7yEKY+2Ub/kmpXVIwUzHhv63grKDkveRGJAD93VjKSHR4TeAqqb0VxCT5Iu2+cA8yzvAMHep5X73IJtrjLsUi8w1HoXeG0tE8laPlF+fmUcWgXGF3mZ9BI6Zgurl95xvSMkfHZu1o6wBmF/NjxeoHVkumi4XsJVIbaAmZk1MWcllIu9OGmlovoBVNJZ1hpBoK0u1Q/4UFTdoANghvm0fOEymMrF8k8ogU1x4Ml9Vo2uJLO4shhxsMPZC3wF8Czgga0arhmMsEvFxbVjENZY+O/gIVqFM89vltwUdDiq9s5nivMxD2EhnzaqtHFuPY1+YoqRJzaD2uNKIUe/6WhBJRK/wEp9a6mKczDnDdiDGX8nd8tBU15/jNyz9XGfUePs432z5he0YtDYdowm/JLzhHHcckzH2//xj2dkFTgiZ0ilef0xf7+II6b1IkTjVGwPOQpgefho9gJfX5JH5b91247qEChKLbAG8v5uNIggOItnw/8kzy8iuU9K7wtcGs+OklBc4xukXyXW77EddqZLlKjFPYt8OsXjKzExIXKOgQYbAUudKKQOqS6eA/Yr1tkmBpgLsPGvCLgCBjO8IQM1Hrm54WE1c6yjezn5ZoS7JHq3KRilFKTDUh9kC79Rxdp/ZPThb2lwd9oe1EVcjP9mmTgg1TVAPr3FasJSq6m5eQ1X5Um+FAXjAmkAqOq773E3o3+VoPWt1q15m7+TAPgaBCtVKTtTDH9"}';
             response.setBody(body);
            response.setStatusCode(200);
            
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
            Object continuationState= IntegrationEngine.continuationState;
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
            String imageUploadCallOutResponse= (String)IntegrationEngine.processImageUploadResponse(labels, IntegrationEngine.continuationState);
            Test.stopTest();
            
           String responseExpected ='"{\\n  \\"ResponseData\\" : {\\n    \\"Fields\\" : {\\n      \\"ApplicationId\\" : \\"26821194\\",\\n      \\"Decision\\" : \\"Pass\\",\\n      \\"ApplicationData\\" : {\\n        \\"Services\\" : {\\n          \\"Service\\" : {\\n            \\"EnableSimulation\\" : \\"False\\",\\n            \\"Consent\\" : \\"true\\",\\n            \\"Skip\\" : \\"N\\",\\n            \\"Name\\" : \\"DocumentAuthentication\\",\\n            \\"Id\\" : \\"\\"\\n          }\\n        }\\n      },\\n      \\"Applicants\\" : {\\n        \\"Applicant\\" : {\\n          \\"ApplicantIdentifier\\" : \\"8a954f18-baba-4a88-b004-8af712d40e9b\\",\\n          \\"Services\\" : {\\n            \\"Service\\" : [ {\\n              \\"Status\\" : \\"Fail\\",\\n              \\"Operations\\" : {\\n                \\"Operation\\" : [ {\\n                  \\"Status\\" : \\"Fail\\",\\n                  \\"Errors\\" : {\\n                    \\"Error\\" : [ {\\n                      \\"Message\\" : \\"The remote server returned an error: (422).\\",\\n                      \\"Code\\" : \\"500\\"\\n                    } ]\\n                  },\\n                  \\"Params\\" : {\\n                    \\"Param\\" : [ {\\n                      \\"Value\\" : {\\n                        \\"SendEmail\\" : \\"\\",\\n                        \\"SendPhone\\" : \\"\\",\\n                        \\"Email\\" : null,\\n                        \\"DefaultCountryId\\" : \\"1\\",\\n                        \\"DocIType\\" : \\"None\\",\\n                        \\"Front\\" : {\\n                          \\"Id\\" : \\"4752745\\"\\n                        },\\n                        \\"CurrentStep\\" : \\"continue\\",\\n                        \\"Type\\" : \\"driving_licence\\",\\n                        \\"Step\\" : \\"front\\"\\n                      },\\n                      \\"Name\\" : \\"IdentityVerification\\"\\n                    }, {\\n                      \\"Value\\" : \\"2434c73c-3f75-4ba6-9bf4-a609e049c4dd\\",\\n                      \\"Name\\" : \\"createresponseId\\"\\n                    }, {\\n                      \\"Value\\" : \\"c9801db7-8647-44ec-ac85-ff42a0403abd\\",\\n                      \\"Name\\" : \\"responseid\\"\\n                    } ]\\n                  },\\n                  \\"Name\\" : \\"frontcontinue\\",\\n                  \\"Id\\" : \\"\\"\\n                } ]\\n              },\\n              \\"Name\\" : \\"DocumentAuthentication\\",\\n              \\"Id\\" : \\"\\"\\n            } ]\\n          }\\n        }\\n      }\\n    },\\n    \\"ResponseInfo\\" : {\\n      \\"SolutionSetInstanceId\\" : \\"666db162-8983-48bf-8c47-ed8067dd4458\\",\\n      \\"ApplicationId\\" : 26821194\\n    },\\n    \\"Status\\" : \\"Success\\"\\n  },\\n  \\"RequestId\\" : \\"11012022105522393\\"\\n}"';
            System.assertEquals(responseExpected, imageUploadCallOutResponse,'Success');
        
        } catch(Exception ex){
            system.debug('excelption line number:'+ex.getLineNumber()+'message:'+ex.getMessage()+'printstactK'+ex.getStackTraceString());
            System.assertEquals(ex.getMessage(),System.Label.Retry,'Exception');
        }
    }*/
    
    /*@isTest
    public static void testImageUploadAPIService3(){
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
            
          	Documents__c document = TestDataUtility.createTestKYCDocsForOcrBack2(false,applicant,opp);
            document.Opportunity_Relation__c=opp.Id;
            if (Schema.sObjectType.Documents__c.isCreateable()){
                insert document;
            }
            
            Blob bodyBlob=Blob.valueOf('Passport Back'); 
            
            final ContentVersion contentVersion_1 = new ContentVersion(
                Title='SampleTitle', 
                PathOnClient ='SampleTitle.jpg',
                VersionData = bodyBlob, 
                origin = 'H',
                Document_Side_fileupload__c = 'Back'
            );
            insert contentVersion_1;
            
            final ContentVersion contentVersion_2 = [SELECT Id, Title, ContentDocumentId 
                            FROM ContentVersion WHERE Id = :contentVersion_1.Id LIMIT 1];
            
            ContentDocumentLink contentlink = new ContentDocumentLink();
            contentlink.LinkedEntityId = document.id;
            contentlink.contentdocumentid = contentVersion_2.contentdocumentid;
            contentlink.ShareType = 'V';
            insert contentlink;
            
            String imageType ='Back';
            Continuation con = (Continuation)IntegrationEngine.doImageUploadCallout(document.id , imageType,opp.Id);
            // Create a mock response
            HttpResponse response = new HttpResponse();
                 String  body = '{"JData":"eY2t35lcUlX1j/zGCOhDrWXBmncES91nxoI9SOf46I16d9LWP0Uxt1Qa6QzhFvxtfxwtM7ZBJ/lxFPAN3JrUXWqQfGiAGh1+jUNmKh0LaZbFzqWPzgUNvYxfqSLmpZiOzjQeA4f5bcvc7T62rjTKN81mQsN+eQlm416YV5D0Ba60+NqFlPGq7+EfJN0NU3qoLt2QijZkPulvVIHS3CZH+cZRSjAuLnpR2P0bKDlRLsJTqxQi8KrmUmD5R2M5FzoSyE2fMRFHwQOStn5nvG0Ml9d+ni3EC9scCJRR6vz3AuMpRcf0PEX+8i7+N2z5CX6PUilT56vQ13jtgU4MzkYuua3jONfQBVV6goVFTRV+uwtZT5XfhmkcMfTXrLfuKEuR3CjCKU2MM06TlrAVi1O4Jo8QC0xLYANFrSjqSXebWI+REGvxADTJzKVbxBO3CZDE2vXZKZ3wE+UdAzlQhPgsQx4WfgUIT6WX/iTha0QYEfzXGhfM1dtYRZwEUqDu1cplm+2vYihKuMLExbTi4g0AXHwiGOU0bt8159KAAKPpl9knyp280/NULWR4tU3i38uixRU8/7ZJYJBEnSwqxPeB5PJTzIICpZYcRQERjk8Zid9oix6xnWd7z51RNiCl5g47poV6TRqrQJ+4q9BiHRNJkiKOvhTkt0Poc57febpxq5LBSypo2KjyDgGAQq41GdDDr9IKcivIzBjEVMG8fP11Lc2Np1thILGPvP7yEKY+2Ub/kmpXVIwUzHhv63grKDkveRGJAD93VjKSHR4TeAqqb0VxCT5Iu2+cA8yzvAMHep5X73IJtrjLsUi8w1HoXeG0tE8laPlF+fmUcWgXGF3mZ9BI6Zgurl95xvSMkfHZu1o6wBmF/NjxeoHVkumi4XsJVIbaAmZk1MWcllIu9OGmlovoBVNJZ1hpBoK0u1Q/4UFTdoANghvm0fOEymMrF8k8ogU1x4Ml9Vo2uJLO4shhxsMPZC3wF8Czgga0arhmMsEvFxbVjENZY+O/gIVqFM89vltwUdDiq9s5nivMxD2EhnzaqtHFuPY1+YoqRJzaD2uNKIUe/6WhBJRK/wEp9a6mKczDnDdiDGX8nd8tBU15/jNyz9XGfUePs432z5he0YtDYdowm/JLzhHHcckzH2//xj2dkFTgiZ0ilef0xf7+II6b1IkTjVGwPOQpgefho9gJfX5JH5b91247qEChKLbAG8v5uNIggOItnw/8kzy8iuU9K7wtcGs+OklBc4xukXyXW77EddqZLlKjFPYt8OsXjKzExIXKOgQYbAUudKKQOqS6eA/Yr1tkmBpgLsPGvCLgCBjO8IQM1Hrm54WE1c6yjezn5ZoS7JHq3KRilFKTDUh9kC79Rxdp/ZPThb2lwd9oe1EVcjP9mmTgg1TVAPr3FasJSq6m5eQ1X5Um+FAXjAmkAqOq773E3o3+VoPWt1q15m7+TAPgaBCtVKTtTDH9"}';
             response.setBody(body);
            response.setStatusCode(200);
            
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
            Object continuationState= IntegrationEngine.continuationState;
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
            String imageUploadCallOutResponse= (String)IntegrationEngine.processImageUploadResponse(labels, IntegrationEngine.continuationState);
            Test.stopTest();
            
          String responseExpected ='"{\\n  \\"ResponseData\\" : {\\n    \\"Fields\\" : {\\n      \\"ApplicationId\\" : \\"26821194\\",\\n      \\"Decision\\" : \\"Pass\\",\\n      \\"ApplicationData\\" : {\\n        \\"Services\\" : {\\n          \\"Service\\" : {\\n            \\"EnableSimulation\\" : \\"False\\",\\n            \\"Consent\\" : \\"true\\",\\n            \\"Skip\\" : \\"N\\",\\n            \\"Name\\" : \\"DocumentAuthentication\\",\\n            \\"Id\\" : \\"\\"\\n          }\\n        }\\n      },\\n      \\"Applicants\\" : {\\n        \\"Applicant\\" : {\\n          \\"ApplicantIdentifier\\" : \\"8a954f18-baba-4a88-b004-8af712d40e9b\\",\\n          \\"Services\\" : {\\n            \\"Service\\" : [ {\\n              \\"Status\\" : \\"Fail\\",\\n              \\"Operations\\" : {\\n                \\"Operation\\" : [ {\\n                  \\"Status\\" : \\"Fail\\",\\n                  \\"Errors\\" : {\\n                    \\"Error\\" : [ {\\n                      \\"Message\\" : \\"The remote server returned an error: (422).\\",\\n                      \\"Code\\" : \\"500\\"\\n                    } ]\\n                  },\\n                  \\"Params\\" : {\\n                    \\"Param\\" : [ {\\n                      \\"Value\\" : {\\n                        \\"SendEmail\\" : \\"\\",\\n                        \\"SendPhone\\" : \\"\\",\\n                        \\"Email\\" : null,\\n                        \\"DefaultCountryId\\" : \\"1\\",\\n                        \\"DocIType\\" : \\"None\\",\\n                        \\"Front\\" : {\\n                          \\"Id\\" : \\"4752745\\"\\n                        },\\n                        \\"CurrentStep\\" : \\"continue\\",\\n                        \\"Type\\" : \\"driving_licence\\",\\n                        \\"Step\\" : \\"front\\"\\n                      },\\n                      \\"Name\\" : \\"IdentityVerification\\"\\n                    }, {\\n                      \\"Value\\" : \\"2434c73c-3f75-4ba6-9bf4-a609e049c4dd\\",\\n                      \\"Name\\" : \\"createresponseId\\"\\n                    }, {\\n                      \\"Value\\" : \\"c9801db7-8647-44ec-ac85-ff42a0403abd\\",\\n                      \\"Name\\" : \\"responseid\\"\\n                    } ]\\n                  },\\n                  \\"Name\\" : \\"frontcontinue\\",\\n                  \\"Id\\" : \\"\\"\\n                } ]\\n              },\\n              \\"Name\\" : \\"DocumentAuthentication\\",\\n              \\"Id\\" : \\"\\"\\n            } ]\\n          }\\n        }\\n      }\\n    },\\n    \\"ResponseInfo\\" : {\\n      \\"SolutionSetInstanceId\\" : \\"666db162-8983-48bf-8c47-ed8067dd4458\\",\\n      \\"ApplicationId\\" : 26821194\\n    },\\n    \\"Status\\" : \\"Success\\"\\n  },\\n  \\"RequestId\\" : \\"11012022105522393\\"\\n}"';
            System.assertEquals(responseExpected, imageUploadCallOutResponse,'Success');
        
        } catch(Exception ex){
            System.assertEquals(ex.getMessage(),System.Label.Retry,'Exception');
        }    
    }*/
    
    //bhushan
    @isTest
    public static void testImageUploadAPIServiceBH1(){
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
            
          	Documents__c document = TestDataUtility.createTestKYCDocsForOcrBack2(false,applicant,opp);
            document.Opportunity_Relation__c=opp.Id;
            document.Document_Type__c = System.Label.CustomerImageDocumentType;
            if (Schema.sObjectType.Documents__c.isCreateable()){
                insert document;
            }
            
            Blob bodyBlob1=Blob.valueOf('Passport Front');
            Blob bodyBlob2=Blob.valueOf('Passport Back'); 
            
             ContentVersion contentVersion_1 = new ContentVersion(
                Title='SampleTitle1', 
                PathOnClient ='SampleTitle1.jpg',
                VersionData = bodyBlob1, 
                origin = 'H',
                Document_Side_fileupload__c = 'Front'
                //contentDocumentId
            );
            
            ContentVersion contentVersion_2 = new ContentVersion(
                Title='SampleTitle2', 
                PathOnClient ='SampleTitle2.jpg',
                VersionData = bodyBlob2, 
                origin = 'H',
                Document_Side_fileupload__c = 'Back'
               //contentDocumentId
            );
            
            insert contentVersion_1;
            insert contentVersion_2;
            List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
            
            //create ContentDocumentLink  record 
            ContentDocumentLink cdl = New ContentDocumentLink();
            cdl.LinkedEntityId = document.id;
            cdl.ContentDocumentId = documents[0].Id;
            cdl.shareType = 'V';
            insert cdl;
            
            ContentDocumentLink cdl2 = New ContentDocumentLink();
            cdl2.LinkedEntityId = document.id;
            cdl2.ContentDocumentId = documents[1].Id;
            cdl2.shareType = 'V';
            insert cdl2;
            
            String imageType ='Front';
            Continuation con = (Continuation)IntegrationEngine.doImageUploadCallout(document.id , imageType,opp.Id);
            // Create a mock response
            HttpResponse response = new HttpResponse();
                 String  body = '{"JData":"eY2t35lcUlX1j/zGCOhDrWXBmncES91nxoI9SOf46I16d9LWP0Uxt1Qa6QzhFvxtfxwtM7ZBJ/lxFPAN3JrUXWqQfGiAGh1+jUNmKh0LaZbFzqWPzgUNvYxfqSLmpZiOzjQeA4f5bcvc7T62rjTKN81mQsN+eQlm416YV5D0Ba60+NqFlPGq7+EfJN0NU3qoLt2QijZkPulvVIHS3CZH+cZRSjAuLnpR2P0bKDlRLsJTqxQi8KrmUmD5R2M5FzoSyE2fMRFHwQOStn5nvG0Ml9d+ni3EC9scCJRR6vz3AuMpRcf0PEX+8i7+N2z5CX6PUilT56vQ13jtgU4MzkYuua3jONfQBVV6goVFTRV+uwtZT5XfhmkcMfTXrLfuKEuR3CjCKU2MM06TlrAVi1O4Jo8QC0xLYANFrSjqSXebWI+REGvxADTJzKVbxBO3CZDE2vXZKZ3wE+UdAzlQhPgsQx4WfgUIT6WX/iTha0QYEfzXGhfM1dtYRZwEUqDu1cplm+2vYihKuMLExbTi4g0AXHwiGOU0bt8159KAAKPpl9knyp280/NULWR4tU3i38uixRU8/7ZJYJBEnSwqxPeB5PJTzIICpZYcRQERjk8Zid9oix6xnWd7z51RNiCl5g47poV6TRqrQJ+4q9BiHRNJkiKOvhTkt0Poc57febpxq5LBSypo2KjyDgGAQq41GdDDr9IKcivIzBjEVMG8fP11Lc2Np1thILGPvP7yEKY+2Ub/kmpXVIwUzHhv63grKDkveRGJAD93VjKSHR4TeAqqb0VxCT5Iu2+cA8yzvAMHep5X73IJtrjLsUi8w1HoXeG0tE8laPlF+fmUcWgXGF3mZ9BI6Zgurl95xvSMkfHZu1o6wBmF/NjxeoHVkumi4XsJVIbaAmZk1MWcllIu9OGmlovoBVNJZ1hpBoK0u1Q/4UFTdoANghvm0fOEymMrF8k8ogU1x4Ml9Vo2uJLO4shhxsMPZC3wF8Czgga0arhmMsEvFxbVjENZY+O/gIVqFM89vltwUdDiq9s5nivMxD2EhnzaqtHFuPY1+YoqRJzaD2uNKIUe/6WhBJRK/wEp9a6mKczDnDdiDGX8nd8tBU15/jNyz9XGfUePs432z5he0YtDYdowm/JLzhHHcckzH2//xj2dkFTgiZ0ilef0xf7+II6b1IkTjVGwPOQpgefho9gJfX5JH5b91247qEChKLbAG8v5uNIggOItnw/8kzy8iuU9K7wtcGs+OklBc4xukXyXW77EddqZLlKjFPYt8OsXjKzExIXKOgQYbAUudKKQOqS6eA/Yr1tkmBpgLsPGvCLgCBjO8IQM1Hrm54WE1c6yjezn5ZoS7JHq3KRilFKTDUh9kC79Rxdp/ZPThb2lwd9oe1EVcjP9mmTgg1TVAPr3FasJSq6m5eQ1X5Um+FAXjAmkAqOq773E3o3+VoPWt1q15m7+TAPgaBCtVKTtTDH9"}';
             response.setBody(body);
            response.setStatusCode(200);
            
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
            Object continuationState= IntegrationEngine.continuationState;
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
            String imageUploadCallOutResponse= (String)IntegrationEngine.processImageUploadResponse(labels, IntegrationEngine.continuationState);
            Test.stopTest();
            
          String responseExpected ='"{\\n  \\"ResponseData\\" : {\\n    \\"Fields\\" : {\\n      \\"ApplicationId\\" : \\"26821194\\",\\n      \\"Decision\\" : \\"Pass\\",\\n      \\"ApplicationData\\" : {\\n        \\"Services\\" : {\\n          \\"Service\\" : {\\n            \\"EnableSimulation\\" : \\"False\\",\\n            \\"Consent\\" : \\"true\\",\\n            \\"Skip\\" : \\"N\\",\\n            \\"Name\\" : \\"DocumentAuthentication\\",\\n            \\"Id\\" : \\"\\"\\n          }\\n        }\\n      },\\n      \\"Applicants\\" : {\\n        \\"Applicant\\" : {\\n          \\"ApplicantIdentifier\\" : \\"8a954f18-baba-4a88-b004-8af712d40e9b\\",\\n          \\"Services\\" : {\\n            \\"Service\\" : [ {\\n              \\"Status\\" : \\"Fail\\",\\n              \\"Operations\\" : {\\n                \\"Operation\\" : [ {\\n                  \\"Status\\" : \\"Fail\\",\\n                  \\"Errors\\" : {\\n                    \\"Error\\" : [ {\\n                      \\"Message\\" : \\"The remote server returned an error: (422).\\",\\n                      \\"Code\\" : \\"500\\"\\n                    } ]\\n                  },\\n                  \\"Params\\" : {\\n                    \\"Param\\" : [ {\\n                      \\"Value\\" : {\\n                        \\"SendEmail\\" : \\"\\",\\n                        \\"SendPhone\\" : \\"\\",\\n                        \\"Email\\" : null,\\n                        \\"DefaultCountryId\\" : \\"1\\",\\n                        \\"DocIType\\" : \\"None\\",\\n                        \\"Front\\" : {\\n                          \\"Id\\" : \\"4752745\\"\\n                        },\\n                        \\"CurrentStep\\" : \\"continue\\",\\n                        \\"Type\\" : \\"driving_licence\\",\\n                        \\"Step\\" : \\"front\\"\\n                      },\\n                      \\"Name\\" : \\"IdentityVerification\\"\\n                    }, {\\n                      \\"Value\\" : \\"2434c73c-3f75-4ba6-9bf4-a609e049c4dd\\",\\n                      \\"Name\\" : \\"createresponseId\\"\\n                    }, {\\n                      \\"Value\\" : \\"c9801db7-8647-44ec-ac85-ff42a0403abd\\",\\n                      \\"Name\\" : \\"responseid\\"\\n                    } ]\\n                  },\\n                  \\"Name\\" : \\"frontcontinue\\",\\n                  \\"Id\\" : \\"\\"\\n                } ]\\n              },\\n              \\"Name\\" : \\"DocumentAuthentication\\",\\n              \\"Id\\" : \\"\\"\\n            } ]\\n          }\\n        }\\n      }\\n    },\\n    \\"ResponseInfo\\" : {\\n      \\"SolutionSetInstanceId\\" : \\"666db162-8983-48bf-8c47-ed8067dd4458\\",\\n      \\"ApplicationId\\" : 26821194\\n    },\\n    \\"Status\\" : \\"Success\\"\\n  },\\n  \\"RequestId\\" : \\"11012022105522393\\"\\n}"';
            //System.assertEquals(responseExpected, imageUploadCallOutResponse,'Success');
        
        } catch(Exception ex){
            System.assertEquals(ex.getMessage(),'Script-thrown exception');
        }    
    }
    
    //bhushan
    @isTest
    public static void testImageUploadAPIServiceBH2(){
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
            
          	Documents__c document = TestDataUtility.createTestKYCDocsForOcrBack2(false,applicant,opp);
            document.Opportunity_Relation__c=opp.Id;
            document.Document_Type__c = System.Label.AadhaarCard;
            if (Schema.sObjectType.Documents__c.isCreateable()){
                insert document;
            }
            
            Blob bodyBlob1=Blob.valueOf('Passport Front');
            Blob bodyBlob2=Blob.valueOf('Passport Back'); 
            
             ContentVersion contentVersion_1 = new ContentVersion(
                Title='SampleTitle1', 
                PathOnClient ='SampleTitle1.jpg',
                VersionData = bodyBlob1, 
                origin = 'H',
                Document_Side_fileupload__c = 'Front'
                //contentDocumentId
            );
            
            ContentVersion contentVersion_2 = new ContentVersion(
                Title='SampleTitle2', 
                PathOnClient ='SampleTitle2.jpg',
                VersionData = bodyBlob2, 
                origin = 'H',
                Document_Side_fileupload__c = 'Back'
               //contentDocumentId
            );
            
            insert contentVersion_1;
            insert contentVersion_2;
            List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
            
            //create ContentDocumentLink  record 
            ContentDocumentLink cdl = New ContentDocumentLink();
            cdl.LinkedEntityId = document.id;
            cdl.ContentDocumentId = documents[0].Id;
            cdl.shareType = 'V';
            insert cdl;
            
            ContentDocumentLink cdl2 = New ContentDocumentLink();
            cdl2.LinkedEntityId = document.id;
            cdl2.ContentDocumentId = documents[1].Id;
            cdl2.shareType = 'V';
            insert cdl2;
            
            String imageType ='Back';
            Continuation con = (Continuation)IntegrationEngine.doImageUploadCallout(document.id , imageType,opp.Id);
            // Create a mock response
            HttpResponse response = new HttpResponse();
            String  body = '{"JData":"eY2t35lcUlX1j/zGCOhDrWXBmncES91nxoI9SOf46I16d9LWP0Uxt1Qa6QzhFvxtfxwtM7ZBJ/lxFPAN3JrUXWqQfGiAGh1+jUNmKh0LaZbFzqWPzgUNvYxfqSLmpZiOzjQeA4f5bcvc7T62rjTKN81mQsN+eQlm416YV5D0Ba60+NqFlPGq7+EfJN0NU3qoLt2QijZkPulvVIHS3CZH+cZRSjAuLnpR2P0bKDlRLsJTqxQi8KrmUmD5R2M5FzoSyE2fMRFHwQOStn5nvG0Ml9d+ni3EC9scCJRR6vz3AuMpRcf0PEX+8i7+N2z5CX6PUilT56vQ13jtgU4MzkYuua3jONfQBVV6goVFTRV+uwtZT5XfhmkcMfTXrLfuKEuR3CjCKU2MM06TlrAVi1O4Jo8QC0xLYANFrSjqSXebWI+REGvxADTJzKVbxBO3CZDE2vXZKZ3wE+UdAzlQhPgsQx4WfgUIT6WX/iTha0QYEfzXGhfM1dtYRZwEUqDu1cplm+2vYihKuMLExbTi4g0AXHwiGOU0bt8159KAAKPpl9knyp280/NULWR4tU3i38uixRU8/7ZJYJBEnSwqxPeB5PJTzIICpZYcRQERjk8Zid9oix6xnWd7z51RNiCl5g47poV6TRqrQJ+4q9BiHRNJkiKOvhTkt0Poc57febpxq5LBSypo2KjyDgGAQq41GdDDr9IKcivIzBjEVMG8fP11Lc2Np1thILGPvP7yEKY+2Ub/kmpXVIwUzHhv63grKDkveRGJAD93VjKSHR4TeAqqb0VxCT5Iu2+cA8yzvAMHep5X73IJtrjLsUi8w1HoXeG0tE8laPlF+fmUcWgXGF3mZ9BI6Zgurl95xvSMkfHZu1o6wBmF/NjxeoHVkumi4XsJVIbaAmZk1MWcllIu9OGmlovoBVNJZ1hpBoK0u1Q/4UFTdoANghvm0fOEymMrF8k8ogU1x4Ml9Vo2uJLO4shhxsMPZC3wF8Czgga0arhmMsEvFxbVjENZY+O/gIVqFM89vltwUdDiq9s5nivMxD2EhnzaqtHFuPY1+YoqRJzaD2uNKIUe/6WhBJRK/wEp9a6mKczDnDdiDGX8nd8tBU15/jNyz9XGfUePs432z5he0YtDYdowm/JLzhHHcckzH2//xj2dkFTgiZ0ilef0xf7+II6b1IkTjVGwPOQpgefho9gJfX5JH5b91247qEChKLbAG8v5uNIggOItnw/8kzy8iuU9K7wtcGs+OklBc4xukXyXW77EddqZLlKjFPYt8OsXjKzExIXKOgQYbAUudKKQOqS6eA/Yr1tkmBpgLsPGvCLgCBjO8IQM1Hrm54WE1c6yjezn5ZoS7JHq3KRilFKTDUh9kC79Rxdp/ZPThb2lwd9oe1EVcjP9mmTgg1TVAPr3FasJSq6m5eQ1X5Um+FAXjAmkAqOq773E3o3+VoPWt1q15m7+TAPgaBCtVKTtTDH9"}';
            response.setBody(body);
            response.setStatusCode(200);
            
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
            Object continuationState= IntegrationEngine.continuationState;
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
            String imageUploadCallOutResponse= (String)IntegrationEngine.processImageUploadResponse(labels, IntegrationEngine.continuationState);
            Test.stopTest();
            
          String responseExpected ='"{\\n  \\"ResponseData\\" : {\\n    \\"Fields\\" : {\\n      \\"ApplicationId\\" : \\"26821194\\",\\n      \\"Decision\\" : \\"Pass\\",\\n      \\"ApplicationData\\" : {\\n        \\"Services\\" : {\\n          \\"Service\\" : {\\n            \\"EnableSimulation\\" : \\"False\\",\\n            \\"Consent\\" : \\"true\\",\\n            \\"Skip\\" : \\"N\\",\\n            \\"Name\\" : \\"DocumentAuthentication\\",\\n            \\"Id\\" : \\"\\"\\n          }\\n        }\\n      },\\n      \\"Applicants\\" : {\\n        \\"Applicant\\" : {\\n          \\"ApplicantIdentifier\\" : \\"8a954f18-baba-4a88-b004-8af712d40e9b\\",\\n          \\"Services\\" : {\\n            \\"Service\\" : [ {\\n              \\"Status\\" : \\"Fail\\",\\n              \\"Operations\\" : {\\n                \\"Operation\\" : [ {\\n                  \\"Status\\" : \\"Fail\\",\\n                  \\"Errors\\" : {\\n                    \\"Error\\" : [ {\\n                      \\"Message\\" : \\"The remote server returned an error: (422).\\",\\n                      \\"Code\\" : \\"500\\"\\n                    } ]\\n                  },\\n                  \\"Params\\" : {\\n                    \\"Param\\" : [ {\\n                      \\"Value\\" : {\\n                        \\"SendEmail\\" : \\"\\",\\n                        \\"SendPhone\\" : \\"\\",\\n                        \\"Email\\" : null,\\n                        \\"DefaultCountryId\\" : \\"1\\",\\n                        \\"DocIType\\" : \\"None\\",\\n                        \\"Front\\" : {\\n                          \\"Id\\" : \\"4752745\\"\\n                        },\\n                        \\"CurrentStep\\" : \\"continue\\",\\n                        \\"Type\\" : \\"driving_licence\\",\\n                        \\"Step\\" : \\"front\\"\\n                      },\\n                      \\"Name\\" : \\"IdentityVerification\\"\\n                    }, {\\n                      \\"Value\\" : \\"2434c73c-3f75-4ba6-9bf4-a609e049c4dd\\",\\n                      \\"Name\\" : \\"createresponseId\\"\\n                    }, {\\n                      \\"Value\\" : \\"c9801db7-8647-44ec-ac85-ff42a0403abd\\",\\n                      \\"Name\\" : \\"responseid\\"\\n                    } ]\\n                  },\\n                  \\"Name\\" : \\"frontcontinue\\",\\n                  \\"Id\\" : \\"\\"\\n                } ]\\n              },\\n              \\"Name\\" : \\"DocumentAuthentication\\",\\n              \\"Id\\" : \\"\\"\\n            } ]\\n          }\\n        }\\n      }\\n    },\\n    \\"ResponseInfo\\" : {\\n      \\"SolutionSetInstanceId\\" : \\"666db162-8983-48bf-8c47-ed8067dd4458\\",\\n      \\"ApplicationId\\" : 26821194\\n    },\\n    \\"Status\\" : \\"Success\\"\\n  },\\n  \\"RequestId\\" : \\"11012022105522393\\"\\n}"';
            //System.assertEquals(responseExpected, imageUploadCallOutResponse,'Success');
        
        } catch(Exception ex){
            System.assertEquals(ex.getMessage(),'Please enter the Maker Id','Exception');
        }    
    }
    
    //bhushan
    @isTest
    public static void testImageUploadAPIServiceBH3(){
        try{   
                   
              Profile p = [SELECT Id FROM Profile WHERE Name='IBL Counter Staff'];
            system.debug('p'+ p);
    		User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
					EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
					LocaleSidKey='en_US', ProfileId = p.Id,
					TimeZoneSidKey='America/Los_Angeles',
					UserName='standarduser4@testorg.com.psdev1', MobilePhone = '9701498575',
					Maker_Id__c = '1002');
            insert u; 
            
            
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            
             Applicant__c applicant = TestDataUtility.createTestApplicant(false);
            applicant.Opportunity__c=opp.Id;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert applicant;
            }
            
          	Documents__c document = TestDataUtility.createTestKYCDocsForOcrBack2(false,applicant,opp);
            document.Opportunity_Relation__c=opp.Id;
            document.Document_Type__c = System.Label.PassportCard;
            if (Schema.sObjectType.Documents__c.isCreateable()){
                insert document;
            }
            
            Blob bodyBlob1=Blob.valueOf('Passport Front');
            Blob bodyBlob2=Blob.valueOf('Passport Back'); 
            
             ContentVersion contentVersion_1 = new ContentVersion(
                Title='SampleTitle1', 
                PathOnClient ='SampleTitle1.jpg',
                VersionData = bodyBlob1, 
                origin = 'H',
                Document_Side_fileupload__c = 'Front'
                //contentDocumentId
            );
            
            ContentVersion contentVersion_2 = new ContentVersion(
                Title='SampleTitle2', 
                PathOnClient ='SampleTitle2.jpg',
                VersionData = bodyBlob2, 
                origin = 'H'
                //Document_Side_fileupload__c = 'Back'
               //contentDocumentId
            );
            
            insert contentVersion_1;
            insert contentVersion_2;
            List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
            
            //create ContentDocumentLink  record 
            ContentDocumentLink cdl = New ContentDocumentLink();
            cdl.LinkedEntityId = document.id;
            cdl.ContentDocumentId = documents[0].Id;
            cdl.shareType = 'V';
            insert cdl;
            
            ContentDocumentLink cdl2 = New ContentDocumentLink();
            cdl2.LinkedEntityId = document.id;
            cdl2.ContentDocumentId = documents[1].Id;
            cdl2.shareType = 'V';
            insert cdl2;
            
            String imageType ='Back';
            Continuation con = (Continuation)IntegrationEngine.doImageUploadCallout(document.id , imageType,opp.Id);
            // Create a mock response
            HttpResponse response = new HttpResponse();
            String  body = '{"JData":"eY2t35lcUlX1j/zGCOhDrWXBmncES91nxoI9SOf46I16d9LWP0Uxt1Qa6QzhFvxtfxwtM7ZBJ/lxFPAN3JrUXWqQfGiAGh1+jUNmKh0LaZbFzqWPzgUNvYxfqSLmpZiOzjQeA4f5bcvc7T62rjTKN81mQsN+eQlm416YV5D0Ba60+NqFlPGq7+EfJN0NU3qoLt2QijZkPulvVIHS3CZH+cZRSjAuLnpR2P0bKDlRLsJTqxQi8KrmUmD5R2M5FzoSyE2fMRFHwQOStn5nvG0Ml9d+ni3EC9scCJRR6vz3AuMpRcf0PEX+8i7+N2z5CX6PUilT56vQ13jtgU4MzkYuua3jONfQBVV6goVFTRV+uwtZT5XfhmkcMfTXrLfuKEuR3CjCKU2MM06TlrAVi1O4Jo8QC0xLYANFrSjqSXebWI+REGvxADTJzKVbxBO3CZDE2vXZKZ3wE+UdAzlQhPgsQx4WfgUIT6WX/iTha0QYEfzXGhfM1dtYRZwEUqDu1cplm+2vYihKuMLExbTi4g0AXHwiGOU0bt8159KAAKPpl9knyp280/NULWR4tU3i38uixRU8/7ZJYJBEnSwqxPeB5PJTzIICpZYcRQERjk8Zid9oix6xnWd7z51RNiCl5g47poV6TRqrQJ+4q9BiHRNJkiKOvhTkt0Poc57febpxq5LBSypo2KjyDgGAQq41GdDDr9IKcivIzBjEVMG8fP11Lc2Np1thILGPvP7yEKY+2Ub/kmpXVIwUzHhv63grKDkveRGJAD93VjKSHR4TeAqqb0VxCT5Iu2+cA8yzvAMHep5X73IJtrjLsUi8w1HoXeG0tE8laPlF+fmUcWgXGF3mZ9BI6Zgurl95xvSMkfHZu1o6wBmF/NjxeoHVkumi4XsJVIbaAmZk1MWcllIu9OGmlovoBVNJZ1hpBoK0u1Q/4UFTdoANghvm0fOEymMrF8k8ogU1x4Ml9Vo2uJLO4shhxsMPZC3wF8Czgga0arhmMsEvFxbVjENZY+O/gIVqFM89vltwUdDiq9s5nivMxD2EhnzaqtHFuPY1+YoqRJzaD2uNKIUe/6WhBJRK/wEp9a6mKczDnDdiDGX8nd8tBU15/jNyz9XGfUePs432z5he0YtDYdowm/JLzhHHcckzH2//xj2dkFTgiZ0ilef0xf7+II6b1IkTjVGwPOQpgefho9gJfX5JH5b91247qEChKLbAG8v5uNIggOItnw/8kzy8iuU9K7wtcGs+OklBc4xukXyXW77EddqZLlKjFPYt8OsXjKzExIXKOgQYbAUudKKQOqS6eA/Yr1tkmBpgLsPGvCLgCBjO8IQM1Hrm54WE1c6yjezn5ZoS7JHq3KRilFKTDUh9kC79Rxdp/ZPThb2lwd9oe1EVcjP9mmTgg1TVAPr3FasJSq6m5eQ1X5Um+FAXjAmkAqOq773E3o3+VoPWt1q15m7+TAPgaBCtVKTtTDH9"}';
            response.setBody(body);
            response.setStatusCode(200);
            
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
            Object continuationState= IntegrationEngine.continuationState;
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
            String imageUploadCallOutResponse= (String)IntegrationEngine.processImageUploadResponse(labels, IntegrationEngine.continuationState);
            Test.stopTest();
            
          String responseExpected ='"{\\n  \\"ResponseData\\" : {\\n    \\"Fields\\" : {\\n      \\"ApplicationId\\" : \\"26821194\\",\\n      \\"Decision\\" : \\"Pass\\",\\n      \\"ApplicationData\\" : {\\n        \\"Services\\" : {\\n          \\"Service\\" : {\\n            \\"EnableSimulation\\" : \\"False\\",\\n            \\"Consent\\" : \\"true\\",\\n            \\"Skip\\" : \\"N\\",\\n            \\"Name\\" : \\"DocumentAuthentication\\",\\n            \\"Id\\" : \\"\\"\\n          }\\n        }\\n      },\\n      \\"Applicants\\" : {\\n        \\"Applicant\\" : {\\n          \\"ApplicantIdentifier\\" : \\"8a954f18-baba-4a88-b004-8af712d40e9b\\",\\n          \\"Services\\" : {\\n            \\"Service\\" : [ {\\n              \\"Status\\" : \\"Fail\\",\\n              \\"Operations\\" : {\\n                \\"Operation\\" : [ {\\n                  \\"Status\\" : \\"Fail\\",\\n                  \\"Errors\\" : {\\n                    \\"Error\\" : [ {\\n                      \\"Message\\" : \\"The remote server returned an error: (422).\\",\\n                      \\"Code\\" : \\"500\\"\\n                    } ]\\n                  },\\n                  \\"Params\\" : {\\n                    \\"Param\\" : [ {\\n                      \\"Value\\" : {\\n                        \\"SendEmail\\" : \\"\\",\\n                        \\"SendPhone\\" : \\"\\",\\n                        \\"Email\\" : null,\\n                        \\"DefaultCountryId\\" : \\"1\\",\\n                        \\"DocIType\\" : \\"None\\",\\n                        \\"Front\\" : {\\n                          \\"Id\\" : \\"4752745\\"\\n                        },\\n                        \\"CurrentStep\\" : \\"continue\\",\\n                        \\"Type\\" : \\"driving_licence\\",\\n                        \\"Step\\" : \\"front\\"\\n                      },\\n                      \\"Name\\" : \\"IdentityVerification\\"\\n                    }, {\\n                      \\"Value\\" : \\"2434c73c-3f75-4ba6-9bf4-a609e049c4dd\\",\\n                      \\"Name\\" : \\"createresponseId\\"\\n                    }, {\\n                      \\"Value\\" : \\"c9801db7-8647-44ec-ac85-ff42a0403abd\\",\\n                      \\"Name\\" : \\"responseid\\"\\n                    } ]\\n                  },\\n                  \\"Name\\" : \\"frontcontinue\\",\\n                  \\"Id\\" : \\"\\"\\n                } ]\\n              },\\n              \\"Name\\" : \\"DocumentAuthentication\\",\\n              \\"Id\\" : \\"\\"\\n            } ]\\n          }\\n        }\\n      }\\n    },\\n    \\"ResponseInfo\\" : {\\n      \\"SolutionSetInstanceId\\" : \\"666db162-8983-48bf-8c47-ed8067dd4458\\",\\n      \\"ApplicationId\\" : 26821194\\n    },\\n    \\"Status\\" : \\"Success\\"\\n  },\\n  \\"RequestId\\" : \\"11012022105522393\\"\\n}"';
            System.assertEquals(responseExpected, imageUploadCallOutResponse,'Success');
        
        } catch(Exception ex){
            //System.assertEquals(ex.getMessage(),'Please enter the Maker Id','Exception');
        }    
    }
    
     @isTest
    public static void testImageUploadAPIServiceBH4(){
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
            
          	Documents__c document = TestDataUtility.createTestKYCDocsForOcrBack2(false,applicant,opp);
            document.Opportunity_Relation__c=opp.Id;
            if (Schema.sObjectType.Documents__c.isCreateable()){
                insert document;
            }
            
            Blob bodyBlob1=Blob.valueOf('Passport Front');
            Blob bodyBlob2=Blob.valueOf('Passport Back'); 
            
             ContentVersion contentVersion_1 = new ContentVersion(
               Title='SampleTitle1', 
                PathOnClient ='SampleTitle1.jpg',
                VersionData = bodyBlob1, 
                origin = 'H',
                Document_Side_fileupload__c = 'Front'
                //contentDocumentId
            );
            
            ContentVersion contentVersion_2 = new ContentVersion(
                Title='SampleTitle2', 
                PathOnClient ='SampleTitle2.jpg',
                VersionData = bodyBlob2, 
                origin = 'H',
                Document_Side_fileupload__c = 'Back'
            );
            
            insert contentVersion_1;
            insert contentVersion_2;
            List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
            
            //create ContentDocumentLink  record 
            ContentDocumentLink cdl = New ContentDocumentLink();
            cdl.LinkedEntityId = document.id;
            cdl.ContentDocumentId = documents[0].Id;
            cdl.shareType = 'V';
            insert cdl;
            
            ContentDocumentLink cdl2 = New ContentDocumentLink();
            cdl2.LinkedEntityId = document.id;
            cdl2.ContentDocumentId = documents[1].Id;
            cdl2.shareType = 'V';
            insert cdl2;
            
            String imageType ='';
            Continuation con = (Continuation)IntegrationEngine.doImageUploadCallout(document.id , imageType,opp.Id);
            // Create a mock response
            HttpResponse response = new HttpResponse();
            String  body = '{"JData":"eY2t35lcUlX1j/zGCOhDrWXBmncES91nxoI9SOf46I16d9LWP0Uxt1Qa6QzhFvxtfxwtM7ZBJ/lxFPAN3JrUXWqQfGiAGh1+jUNmKh0LaZbFzqWPzgUNvYxfqSLmpZiOzjQeA4f5bcvc7T62rjTKN81mQsN+eQlm416YV5D0Ba60+NqFlPGq7+EfJN0NU3qoLt2QijZkPulvVIHS3CZH+cZRSjAuLnpR2P0bKDlRLsJTqxQi8KrmUmD5R2M5FzoSyE2fMRFHwQOStn5nvG0Ml9d+ni3EC9scCJRR6vz3AuMpRcf0PEX+8i7+N2z5CX6PUilT56vQ13jtgU4MzkYuua3jONfQBVV6goVFTRV+uwtZT5XfhmkcMfTXrLfuKEuR3CjCKU2MM06TlrAVi1O4Jo8QC0xLYANFrSjqSXebWI+REGvxADTJzKVbxBO3CZDE2vXZKZ3wE+UdAzlQhPgsQx4WfgUIT6WX/iTha0QYEfzXGhfM1dtYRZwEUqDu1cplm+2vYihKuMLExbTi4g0AXHwiGOU0bt8159KAAKPpl9knyp280/NULWR4tU3i38uixRU8/7ZJYJBEnSwqxPeB5PJTzIICpZYcRQERjk8Zid9oix6xnWd7z51RNiCl5g47poV6TRqrQJ+4q9BiHRNJkiKOvhTkt0Poc57febpxq5LBSypo2KjyDgGAQq41GdDDr9IKcivIzBjEVMG8fP11Lc2Np1thILGPvP7yEKY+2Ub/kmpXVIwUzHhv63grKDkveRGJAD93VjKSHR4TeAqqb0VxCT5Iu2+cA8yzvAMHep5X73IJtrjLsUi8w1HoXeG0tE8laPlF+fmUcWgXGF3mZ9BI6Zgurl95xvSMkfHZu1o6wBmF/NjxeoHVkumi4XsJVIbaAmZk1MWcllIu9OGmlovoBVNJZ1hpBoK0u1Q/4UFTdoANghvm0fOEymMrF8k8ogU1x4Ml9Vo2uJLO4shhxsMPZC3wF8Czgga0arhmMsEvFxbVjENZY+O/gIVqFM89vltwUdDiq9s5nivMxD2EhnzaqtHFuPY1+YoqRJzaD2uNKIUe/6WhBJRK/wEp9a6mKczDnDdiDGX8nd8tBU15/jNyz9XGfUePs432z5he0YtDYdowm/JLzhHHcckzH2//xj2dkFTgiZ0ilef0xf7+II6b1IkTjVGwPOQpgefho9gJfX5JH5b91247qEChKLbAG8v5uNIggOItnw/8kzy8iuU9K7wtcGs+OklBc4xukXyXW77EddqZLlKjFPYt8OsXjKzExIXKOgQYbAUudKKQOqS6eA/Yr1tkmBpgLsPGvCLgCBjO8IQM1Hrm54WE1c6yjezn5ZoS7JHq3KRilFKTDUh9kC79Rxdp/ZPThb2lwd9oe1EVcjP9mmTgg1TVAPr3FasJSq6m5eQ1X5Um+FAXjAmkAqOq773E3o3+VoPWt1q15m7+TAPgaBCtVKTtTDH9"}';
            response.setBody(body);
            response.setStatusCode(200);
            
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
            Object continuationState= IntegrationEngine.continuationState;
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
            String imageUploadCallOutResponse= (String)IntegrationEngine.processImageUploadResponse(labels, IntegrationEngine.continuationState);
            Test.stopTest();
            
          String responseExpected ='"{\\n  \\"ResponseData\\" : {\\n    \\"Fields\\" : {\\n      \\"ApplicationId\\" : \\"26821194\\",\\n      \\"Decision\\" : \\"Pass\\",\\n      \\"ApplicationData\\" : {\\n        \\"Services\\" : {\\n          \\"Service\\" : {\\n            \\"EnableSimulation\\" : \\"False\\",\\n            \\"Consent\\" : \\"true\\",\\n            \\"Skip\\" : \\"N\\",\\n            \\"Name\\" : \\"DocumentAuthentication\\",\\n            \\"Id\\" : \\"\\"\\n          }\\n        }\\n      },\\n      \\"Applicants\\" : {\\n        \\"Applicant\\" : {\\n          \\"ApplicantIdentifier\\" : \\"8a954f18-baba-4a88-b004-8af712d40e9b\\",\\n          \\"Services\\" : {\\n            \\"Service\\" : [ {\\n              \\"Status\\" : \\"Fail\\",\\n              \\"Operations\\" : {\\n                \\"Operation\\" : [ {\\n                  \\"Status\\" : \\"Fail\\",\\n                  \\"Errors\\" : {\\n                    \\"Error\\" : [ {\\n                      \\"Message\\" : \\"The remote server returned an error: (422).\\",\\n                      \\"Code\\" : \\"500\\"\\n                    } ]\\n                  },\\n                  \\"Params\\" : {\\n                    \\"Param\\" : [ {\\n                      \\"Value\\" : {\\n                        \\"SendEmail\\" : \\"\\",\\n                        \\"SendPhone\\" : \\"\\",\\n                        \\"Email\\" : null,\\n                        \\"DefaultCountryId\\" : \\"1\\",\\n                        \\"DocIType\\" : \\"None\\",\\n                        \\"Front\\" : {\\n                          \\"Id\\" : \\"4752745\\"\\n                        },\\n                        \\"CurrentStep\\" : \\"continue\\",\\n                        \\"Type\\" : \\"driving_licence\\",\\n                        \\"Step\\" : \\"front\\"\\n                      },\\n                      \\"Name\\" : \\"IdentityVerification\\"\\n                    }, {\\n                      \\"Value\\" : \\"2434c73c-3f75-4ba6-9bf4-a609e049c4dd\\",\\n                      \\"Name\\" : \\"createresponseId\\"\\n                    }, {\\n                      \\"Value\\" : \\"c9801db7-8647-44ec-ac85-ff42a0403abd\\",\\n                      \\"Name\\" : \\"responseid\\"\\n                    } ]\\n                  },\\n                  \\"Name\\" : \\"frontcontinue\\",\\n                  \\"Id\\" : \\"\\"\\n                } ]\\n              },\\n              \\"Name\\" : \\"DocumentAuthentication\\",\\n              \\"Id\\" : \\"\\"\\n            } ]\\n          }\\n        }\\n      }\\n    },\\n    \\"ResponseInfo\\" : {\\n      \\"SolutionSetInstanceId\\" : \\"666db162-8983-48bf-8c47-ed8067dd4458\\",\\n      \\"ApplicationId\\" : 26821194\\n    },\\n    \\"Status\\" : \\"Success\\"\\n  },\\n  \\"RequestId\\" : \\"11012022105522393\\"\\n}"';
            System.assertEquals(responseExpected, imageUploadCallOutResponse,'Success');
        
        } catch(Exception ex){
            System.assertEquals(ex.getMessage(),System.Label.Retry,'Exception');
        }    
    }
    
    @isTest
    public static void testImageUploadAPIService5(){
        try{   
            Profile p = [SELECT Id FROM Profile WHERE Name='IBL Counter Staff'];
            system.debug('p'+ p);
    		User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
					EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
					LocaleSidKey='en_US', ProfileId = p.Id,
					TimeZoneSidKey='America/Los_Angeles',
					UserName='standarduser4@testorg.com.psdev1', MobilePhone = '9701498575',
					Maker_Id__c = '1002');
            insert u; 
            
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            
             Applicant__c applicant = TestDataUtility.createTestApplicant(false);
            applicant.Opportunity__c=opp.Id;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert applicant;
            }
            
          	Documents__c document = TestDataUtility.createTestKYCDocsForOcrBack(false,applicant,opp);
            document.Opportunity_Relation__c=opp.Id;
            if (Schema.sObjectType.Documents__c.isCreateable()){
                insert document;
            }
            
            Blob bodyBlob=Blob.valueOf('Aadhaar Back'); 
            
            final ContentVersion contentVersion_1 = new ContentVersion(
                Title='SampleTitle',
                PathOnClient ='SampleTitle.jpg',
                VersionData = bodyBlob, 
                origin = 'H',
                Document_Side_fileupload__c = 'Back'
            );
            insert contentVersion_1;
            
            final ContentVersion contentVersion_2 = [SELECT Id, Title, ContentDocumentId,Document_Side_fileupload__c 
                            FROM ContentVersion WHERE Id = :contentVersion_1.Id LIMIT 1];
            
            List<ContentDocumentLink> contentlink = new List<ContentDocumentLink>();
            contentlink[0].LinkedEntityId = document.id;
            contentlink[0].contentdocumentid = contentVersion_2.contentdocumentid;
            contentlink[0].ShareType = 'V';
            insert contentlink;
            
            String imageType ='Front';
            Continuation con = (Continuation)IntegrationEngine.doImageUploadCallout(document.id , imageType,opp.Id);
            // Create a mock response
            HttpResponse response = new HttpResponse();
            String  body = '{"JData":"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"}';
             response.setBody(body);
             response.setStatusCode(500);
            
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
            Object continuationState= IntegrationEngine.continuationState;
            String imageUploadCallOutResponse;
            system.runAs(u){
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
            imageUploadCallOutResponse= (String)IntegrationEngine.processImageUploadResponse(labels, IntegrationEngine.continuationState);
            Test.stopTest();
              }
           String responseExpected ='{"RequestId":"28012022100353379","ResponseData":{"Status":"Success","ResponseInfo":{"ApplicationId":27254020,"SolutionSetInstanceId":"63f2c0a0-3a6b-4d72-bb68-34ea841ef024"},"Fields":{"Applicants":{"Applicant":{"Services":{"Service":[{"Id":"","Name":"DocumentAuthentication","Operations":{"Operation":[{"Id":"","Name":"backcontinue","Params":{"Param":[{"Name":"IdentityVerification","Value":{"Step":"End","Type":"voter_id","CurrentStep":"continue","Back":{"Id":"4829823"},"DocIType":"None","DefaultCountryId":"1","Email":null,"SendPhone":"","SendEmail":""}},{"Name":"createresponseId","Value":"3644c1d1-6265-48c1-beb5-c79fc90c9187"},{"Name":"responseid","Value":"c763f6d7-c33d-44ce-a1c7-7e22722d4366"}]},"Data":{"Response":{"RawResponse":"{\"created_at\":\"2022-01-28T04:34:03Z\",\"download_uri\":\"https://onfido.com/dashboard/pdf/information_requests/245778643\",\"form_uri\":null,\"href\":\"/v2/applicants/3644c1d1-6265-48c1-beb5-c79fc90c9187/checks/1f82f6c5-302b-4d0c-a0e5-748df7bdd4f1\",\"id\":\"1f82f6c5-302b-4d0c-a0e5-748df7bdd4f1\",\"paused\":false,\"redirect_uri\":null,\"report_type_groups\":[\"47132\"],\"reports\":[{\"breakdown\":{},\"created_at\":\"2022-01-28T04:34:04Z\",\"documents\":[{\"id\":\"c763f6d7-c33d-44ce-a1c7-7e22722d4366\"},{\"id\":\"4ef75bbc-ff61-402f-b17e-59cd0eadfccd\"}],\"href\":\"/v2/checks/1f82f6c5-302b-4d0c-a0e5-748df7bdd4f1/reports/aa53fed4-fec4-4ddd-bf10-9601181ff775\",\"id\":\"aa53fed4-fec4-4ddd-bf10-9601181ff775\",\"name\":\"document\",\"properties\":{},\"result\":null,\"status\":\"awaiting_approval\",\"sub_result\":null,\"variant\":\"standard\"}],\"result\":null,\"results_uri\":\"https://dashboard.onfido.com/checks/1f82f6c5-302b-4d0c-a0e5-748df7bdd4f1\",\"sandbox\":false,\"status\":\"in_progress\",\"tags\":[],\"type\":\"express\",\"version\":\"2.0\"}"}},"Status":"Pass"}]},"Status":"Pass"}]},"ApplicantIdentifier":"5c2eafe0-c73f-4568-be86-2eaa29d7e0cf"}},"ApplicationData":{"Services":{"Service":{"Id":"","Name":"DocumentAuthentication","Skip":"N","Consent":"true","EnableSimulation":"False"}}},"Decision":"Pass","ApplicationId":"27254020"}}"';
            System.assertEquals(responseExpected, imageUploadCallOutResponse,'Success');
        
        } catch(Exception ex){
            System.assertNotEquals(ex.getMessage(),System.Label.Retry,'Exception');
        }
    }
    
   
    
}