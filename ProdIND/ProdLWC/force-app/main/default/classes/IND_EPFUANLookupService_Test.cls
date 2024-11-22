/*------------------------------------------------------------
Author:        Divya Jawale
Company:       Persistent Systems
Description:   Test class created to validate the IND_EPFUANLookupRequest IND_EPFUANLookupService IND_EPFUANLookupResponse class
History
Date            Author              Comments
-------------------------------------------------------------
21-12-2021      Divya Jawale      Created
------------------------------------------------------------*/
@isTest(SeeAllData=false)
public class IND_EPFUANLookupService_Test {
    @isTest
    public static void testEPFUANLookupService(){
        
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
            Continuation con = (Continuation)IntegrationEngine.doEPFUANLookupCallout(applicant.Id,loanAppId);
            // Create a mock response
            HttpResponse response = new HttpResponse();
            String body ='{"JData":"eY2t35lcUlX1j/zGCOhDrXO90WZsdzPEFT3bbuMlzoPlOA0gZuerj2pDa9sGdgc5odkZxT/oCNCqK7dCfy/xab/EcJkLgAxi905C5rrNkUYbglU76Zz0MjcgXWgjMXwuthTYIScWDp8JjeHv2nYdLfz306rSPk8BBS3i+NfSa0bbSxIBRgMxAnbXbFgaGoLhgUwKq3ZKPU4wPTJXgm/QAyvjIcMMA8TSIevEXSwIaC6yAj4Q5mWNNR4Fysj/zwdOSf9pBGBgrEO+ML3mlb9HQe/RXHMhlZ6sawAH02jaBQZsGqWw/Co68mn6Z1qayzWkK5zN0yjMXmCAREW9fehAqyeeuWbAPR/vYU7Sf2J01P3i9i1MBYfWFPwYMknvdtrzV7QwMkHl3/ErRVd8Adfyczq2giFl1HRGpFyVVvC0pf7d9Xs36SRxqIGkbGfvMN/+bgTneP7nDmO4TsPOB3CUEHji6ZzZwx5T7EVUT9aK5Iq6x5Ro7ITNnESTCSRssgrCDE2facDpAGVqlVS+4Lsvz6xdP33iPHsUGcvpIbzLVO0UZYbY2jcOzk4v9mBC7gN3/RTsr/Fzki3GMbb4yej1uOdR3llQRkyKmD1jisyqSsDcwk+ZpeWQ73t+S1/uhYYYQ12mUzUToy6zJB+IZqf+APWp3hdKT/LAWlxP+JjwajchqWZPFhid9p+0MGzQMukJCRp8ahccagNKa2kNVRTVrTxuL2gHXJqpK7hW8fwlsfj2+sFTKR6V8ED/8mQkJP0kYje5Em9ggqaMqPdtcE+X2yYBoDa/UIqDe4Y+KTyzr7UOEIq+a80lwsjY0tO7rdkxQygwyEA5MFO0zTR47K66ZqCEopGc/jo9pEhgppTe0eINPADEhF7GJNpcVkFBHd1qO4KRtWPJ6XFIw+rSZShvQovT0hHrhmCDtxq/wY2N1aofDcfFx31aUvGqYGu64IKlAm0By4H5PEAsx8Bns3ZY0RpHjuTbThn71DFtgBqfCk8kOYYRV4xXDYLeHQd1KQVOyINJnHoa4Ej7AXqHodwrEujUWjYd37ig0lTNDexXCpUMrXVHULfevNwrRFmWtGj6q+r/YUsuP6u0MSd63wOlPXdkv2TU8OzV9WkdWlcnX2yUdQksp3pt2w31kK+Y108/MBMmC6So0wrWFBN+pwcAOyusvRbok5aJQVWpQ/w5hC1WpePeUY1E8IJvtAdyjtoGXRU5a6k7ez/3tIW06ZJkDw1GlyPUQsgSLjdCIULl9mSFBG41+JoqvJKMclchwfyxPMaQqdyNmZE2k/9z4XRX3d5TZG6p0Fs1AD7VAcDGpKc="}';
            response.setBody(body);
            response.setStatusCode(200);
            
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
                Object continuationState= IntegrationEngine.continuationState;
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
            String epfoUANLookupCallOutResponse= (String)IntegrationEngine.processEPFUANLookupResponse(labels, IntegrationEngine.continuationState);
            Test.stopTest();
            String responseActual ='{"body":null,"ResponseData":{"Status":"Success","ResponseInfo":{"SolutionSetInstanceId":"0d4c19cd-cd2c-49c3-b334-e3087ebf02fa","ApplicationId":26867037},"Fields":{"Decision":"Pass","ApplicationId":"26867037","ApplicationData":{"Services":{"Service":{"Skip":"N","Name":"PublicDataAPI","Id":"","EnableSimulation":"false","Consent":"true"}}},"Applicants":{"Applicant":{"Telephones":{"Telephone":{"TelephoneType":"01","TelephoneNumber":"9730926500"}},"Services":{"Service":[{"Status":"Pass","Operations":{"Operation":[{"Status":"Pass","Params":{"Param":[{"Value":"Y","Name":"consent"}]},"Name":"uan-lookup","Id":"","Data":{"Response":{"RawResponse":"{\\"result\\":{\\"uan-lookup\\":{\\"result\\":{},\\"request_id\\":\\"c32483ae-2fe6-400b-af65-41762f40a959\\",\\"status-code\\":\\"103\\"},\\"request_id\\":\\"93232171-a1bf-4ec8-9ced-573340590561\\",\\"status-code\\":\\"101\\"}}"}}}]},"Name":"PublicDataAPI","Id":""}]},"ApplicantIdentifier":"828a975f-4ae8-4642-93aa-b854a7c4544c"}}}},"RequestId":"11012022183608385"}';
            System.assertEquals(responseActual,epfoUANLookupCallOutResponse,'Success');
            
        } catch(Exception ex){
            System.assertEquals(ex.getMessage(),'Script-thrown exception','Exception');
        }
    }


    @isTest
    public static void testEPFUANLookupService33(){
        
        try{   
            
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            Applicant__c applicant = TestDataUtility.createTestApplicant(false);
            applicant.Opportunity__c = opp.Id;
            //applicant.Contact_number__c = null;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert applicant;
            }
            String loanAppId = opp.Id;
            Continuation con = (Continuation)IntegrationEngine.doEPFUANLookupCallout(applicant.Id,loanAppId);
            // Create a mock response
            HttpResponse response = new HttpResponse();
            String body ='{"JData":"eY2t35lcUlX1j/zGCOhDrXO90WZsdzPEFT3bbuMlzoPlOA0gZuerj2pDa9sGdgc5odkZxT/oCNCqK7dCfy/xab/EcJkLgAxi905C5rrNkUYbglU76Zz0MjcgXWgjMXwuthTYIScWDp8JjeHv2nYdLfz306rSPk8BBS3i+NfSa0bbSxIBRgMxAnbXbFgaGoLhgUwKq3ZKPU4wPTJXgm/QAyvjIcMMA8TSIevEXSwIaC6yAj4Q5mWNNR4Fysj/zwdOSf9pBGBgrEO+ML3mlb9HQe/RXHMhlZ6sawAH02jaBQZsGqWw/Co68mn6Z1qayzWkK5zN0yjMXmCAREW9fehAqyeeuWbAPR/vYU7Sf2J01P3i9i1MBYfWFPwYMknvdtrzV7QwMkHl3/ErRVd8Adfyczq2giFl1HRGpFyVVvC0pf7d9Xs36SRxqIGkbGfvMN/+bgTneP7nDmO4TsPOB3CUEHji6ZzZwx5T7EVUT9aK5Iq6x5Ro7ITNnESTCSRssgrCDE2facDpAGVqlVS+4Lsvz6xdP33iPHsUGcvpIbzLVO0UZYbY2jcOzk4v9mBC7gN3/RTsr/Fzki3GMbb4yej1uOdR3llQRkyKmD1jisyqSsDcwk+ZpeWQ73t+S1/uhYYYQ12mUzUToy6zJB+IZqf+APWp3hdKT/LAWlxP+JjwajchqWZPFhid9p+0MGzQMukJCRp8ahccagNKa2kNVRTVrTxuL2gHXJqpK7hW8fwlsfj2+sFTKR6V8ED/8mQkJP0kYje5Em9ggqaMqPdtcE+X2yYBoDa/UIqDe4Y+KTyzr7UOEIq+a80lwsjY0tO7rdkxQygwyEA5MFO0zTR47K66ZqCEopGc/jo9pEhgppTe0eINPADEhF7GJNpcVkFBHd1qO4KRtWPJ6XFIw+rSZShvQovT0hHrhmCDtxq/wY2N1aofDcfFx31aUvGqYGu64IKlAm0By4H5PEAsx8Bns3ZY0RpHjuTbThn71DFtgBqfCk8kOYYRV4xXDYLeHQd1KQVOyINJnHoa4Ej7AXqHodwrEujUWjYd37ig0lTNDexXCpUMrXVHULfevNwrRFmWtGj6q+r/YUsuP6u0MSd63wOlPXdkv2TU8OzV9WkdWlcnX2yUdQksp3pt2w31kK+Y108/MBMmC6So0wrWFBN+pwcAOyusvRbok5aJQVWpQ/w5hC1WpePeUY1E8IJvtAdyjtoGXRU5a6k7ez/3tIW06ZJkDw1GlyPUQsgSLjdCIULl9mSFBG41+JoqvJKMclchwfyxPMaQqdyNmZE2k/9z4XRX3d5TZG6p0Fs1AD7VAcDGpKc="}';
            response.setBody(body);
            response.setStatusCode(200);
            
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
                Object continuationState= IntegrationEngine.continuationState;
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
            String epfoUANLookupCallOutResponse= (String)IntegrationEngine.processEPFUANLookupResponse(labels, IntegrationEngine.continuationState);
            Test.stopTest();
            String responseActual ='{"body":null,"ResponseData":{"Status":"Success","ResponseInfo":{"SolutionSetInstanceId":"0d4c19cd-cd2c-49c3-b334-e3087ebf02fa","ApplicationId":26867037},"Fields":{"Decision":"Pass","ApplicationId":"26867037","ApplicationData":{"Services":{"Service":{"Skip":"N","Name":"PublicDataAPI","Id":"","EnableSimulation":"false","Consent":"true"}}},"Applicants":{"Applicant":{"Telephones":{"Telephone":{"TelephoneType":"01","TelephoneNumber":"9730926500"}},"Services":{"Service":[{"Status":"Pass","Operations":{"Operation":[{"Status":"Pass","Params":{"Param":[{"Value":"Y","Name":"consent"}]},"Name":"uan-lookup","Id":"","Data":{"Response":{"RawResponse":"{\\"result\\":{\\"uan-lookup\\":{\\"result\\":{},\\"request_id\\":\\"c32483ae-2fe6-400b-af65-41762f40a959\\",\\"status-code\\":\\"103\\"},\\"request_id\\":\\"93232171-a1bf-4ec8-9ced-573340590561\\",\\"status-code\\":\\"101\\"}}"}}}]},"Name":"PublicDataAPI","Id":""}]},"ApplicantIdentifier":"828a975f-4ae8-4642-93aa-b854a7c4544c"}}}},"RequestId":"11012022183608385"}';
            System.assertEquals(responseActual,epfoUANLookupCallOutResponse,'Success');
            
        } catch(Exception ex){
            System.assertEquals(ex.getMessage(),'Script-thrown exception','Exception');
        }
    }
    
    /*
     @isTest
    public static void testEPFUANLookupService2(){
        
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
            Continuation con = (Continuation)IntegrationEngine.doEPFUANLookupCallout(applicant.Id,loanAppId);
            // Create a mock response
            HttpResponse response = new HttpResponse();
            //string body='{"JData":"KRo6kJ+TobEZYweJSoCn8/OCQ9+6RD8OP6tmi86dA8wtYJkGzrCAHV1YlGvGQYziIUovvc/be3eTt6QpKdWAZh/g1KZPHdZZmKfyBRmvSFg="}';
             string body='{"JData":"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"}';
            response.setBody(body);
            response.setStatusCode(200);
            
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
                Object continuationState= IntegrationEngine.continuationState;
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
            String epfoUANLookupCallOutResponse= (String)IntegrationEngine.processEPFUANLookupResponse(labels, IntegrationEngine.continuationState);
            Test.stopTest();
          // String responseActual ='{"body":null,"RequestId":"21122021135159789","ResponseData":{"Status":"Success","ResponseInfo":{"ApplicationId":26632441,"SolutionSetInstanceId":"95da75d3-5c9a-4647-a93b-3331067d8e8a"},"Fields":{"Applicants":{"Applicant":{"Services":{"Service":[{"Id":"","Name":"PublicDataAPI","Operations":{"Operation":[{"Id":"","Name":"uan-lookup","Params":{"Param":[{"Name":"consent","Value":"Y"}]},"Data":{"Response":{"RawResponse":"{\"result\":{\"uan-lookup\":{\"result\":{\"uan\":[\"100102118335\",\"100869899380\"]},\"request_id\":\"8404c42a-7fbd-4215-b56c-c296543500ad\",\"status-code\":\"101\"},\"request_id\":\"2f0721e9-8607-4539-8cab-52383b39ed74\",\"status-code\":\"101\"}}"}},"Status":"Pass"}]},"Status":"Pass"}]},"Telephones":{"Telephone":{"TelephoneNumber":"9940062860","TelephoneType":"01"}},"ApplicantIdentifier":"3acd167a-8c52-4b50-b27b-b90d52e06ddd"}},"ApplicationData":{"Services":{"Service":{"Id":"","Name":"PublicDataAPI","Skip":"N","Consent":"true","EnableSimulation":"false"}}},"Decision":"Pass","ApplicationId":"26632441"}}}';
             //String responseActual='{"body":null,"ResponseData":null,"RequestId":null}';
            String responseActual = '{"body":null,"ResponseData":{"Status":"Success","ResponseInfo":{"SolutionSetInstanceId":"664fadc6-02f5-41b5-b2a2-c3e4df96967e","ApplicationId":26633435},"Fields":{"Decision":"Pass","ApplicationId":"26633435","ApplicationData":{"Services":{"Service":{"Skip":"N","Name":"PublicDataAPI","Id":"","EnableSimulation":"false","Consent":"true"}}},"Applicants":{"Applicant":{"Telephones":{"Telephone":{"TelephoneType":"01","TelephoneNumber":"9730926500"}},"Services":{"Service":[{"Status":"Pass","Operations":{"Operation":[{"Status":"Pass","Params":{"Param":[{"Value":"Y","Name":"consent"},{"Value":"100869899380","Name":"uan"}]},"Name":"epf-auth","Id":"","Data":{"Response":{"RawResponse":"{\"result\":{\"epf-auth\":{\"requestId\":\"0a2583b3-7c69-4f12-a5e1-82a225a735cd\",\"result\":{\"employers\":[{\"startMonthYear\":null,\"lastMonthYear\":null,\"establishmentId\":\"TNMAS0085057000\",\"establishmentName\":\"CONSTIENT GLOBAL SOLUTIONS\",\"address\":{\"city\":\"SANTHOME\",\"state\":\"TAMIL NADU\",\"pincode\":\"600004\",\"district\":null,\"address\":\"86-B, 4TH FLOOR, 86-B, 4TH FLOOR,\"},\"memberId\":\"TNMAS00850570000000086\",\"exitReason\":null,\"status\":\"MULTIPLE_EMPLOYEES_WITH_SAME_NAME\"}],\"personalDetails\":{\"name\":\"BAIREDDY MANJUNATH\",\"fatherOrHusbandName\":null,\"aadhaarVerificationStatus\":null,\"bankAccountStatus\":null,\"panVerificationStatus\":null,\"contactNo\":null},\"summary\":{\"minimumWorkExperienceInMonths\":null,\"lastEmployer\":{}},\"remark\":\"\"},\"statusCode\":101},\"requestId\":\"923dfa2c-b373-4975-b275-5c38d28c11c8\",\"statusCode\":\"101\"}}"}}}]},"Name":"PublicDataAPI","Id":""}]},"ApplicantIdentifier":"f00bfba5-98b2-4735-a59a-99d77dc1dbc2"}}}},"RequestId":"21122021162717595"}';
            System.assertEquals(responseActual,epfoUANLookupCallOutResponse,'Success');
            
        } catch(Exception ex){
            System.assertEquals(ex.getMessage(),'Script-thrown exception','Exception');
        }
    }
    
    */
    @isTest
    public static void validateException(){
       // String errorMessage = '';
        try{
            IND_EPFUANLookupService.getEPFUANLookupCallOutRequest(null, null);
        }catch(Exception pEx){
              System.assert(pEx.getMessage() != null);
        }
       // System.assert(errorMessage.contains('Applicant should not be null'));
    }
    
    @isTest
    public static void testEPFUANLookupService4(){
        
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
            Continuation con = (Continuation)IntegrationEngine.doEPFUANLookupCallout(applicant.Id,loanAppId);
            // Create a mock response
            HttpResponse response = new HttpResponse();
            String body ='{"JData":"eY2t35lcUlX1j/zGCOhDrXO90WZsdzPEFT3bbuMlzoPlOA0gZuerj2pDa9sGdgc5odkZxT/oCNCqK7dCfy/xab/EcJkLgAxi905C5rrNkUYbglU76Zz0MjcgXWgjMXwuthTYIScWDp8JjeHv2nYdLfz306rSPk8BBS3i+NfSa0bbSxIBRgMxAnbXbFgaGoLhgUwKq3ZKPU4wPTJXgm/QAyvjIcMMA8TSIevEXSwIaC6yAj4Q5mWNNR4Fysj/zwdOSf9pBGBgrEO+ML3mlb9HQe/RXHMhlZ6sawAH02jaBQZsGqWw/Co68mn6Z1qayzWkK5zN0yjMXmCAREW9fehAqyeeuWbAPR/vYU7Sf2J01P3i9i1MBYfWFPwYMknvdtrzV7QwMkHl3/ErRVd8Adfyczq2giFl1HRGpFyVVvC0pf7d9Xs36SRxqIGkbGfvMN/+bgTneP7nDmO4TsPOB3CUEHji6ZzZwx5T7EVUT9aK5Iq6x5Ro7ITNnESTCSRssgrCDE2facDpAGVqlVS+4Lsvz6xdP33iPHsUGcvpIbzLVO0UZYbY2jcOzk4v9mBC7gN3/RTsr/Fzki3GMbb4yej1uOdR3llQRkyKmD1jisyqSsDcwk+ZpeWQ73t+S1/uhYYYQ12mUzUToy6zJB+IZqf+APWp3hdKT/LAWlxP+JjwajchqWZPFhid9p+0MGzQMukJCRp8ahccagNKa2kNVRTVrTxuL2gHXJqpK7hW8fwlsfj2+sFTKR6V8ED/8mQkJP0kYje5Em9ggqaMqPdtcE+X2yYBoDa/UIqDe4Y+KTyzr7UOEIq+a80lwsjY0tO7rdkxQygwyEA5MFO0zTR47K66ZqCEopGc/jo9pEhgppTe0eINPADEhF7GJNpcVkFBHd1qO4KRtWPJ6XFIw+rSZShvQovT0hHrhmCDtxq/wY2N1aofDcfFx31aUvGqYGu64IKlAm0By4H5PEAsx8Bns3ZY0RpHjuTbThn71DFtgBqfCk8kOYYRV4xXDYLeHQd1KQVOyINJnHoa4Ej7AXqHodwrEujUWjYd37ig0lTNDexXCpUMrXVHULfevNwrRFmWtGj6q+r/YUsuP6u0MSd63wOlPXdkv2TU8OzV9WkdWlcnX2yUdQksp3pt2w31kK+Y108/MBMmC6So0wrWFBN+pwcAOyusvRbok5aJQVWpQ/w5hC1WpePeUY1E8IJvtAdyjtoGXRU5a6k7ez/3tIW06ZJkDw1GlyPUQsgSLjdCIULl9mSFBG41+JoqvJKMclchwfyxPMaQqdyNmZE2k/9z4XRX3d5TZG6p0Fs1AD7VAcDGpKc="}';
            response.setBody(body);
            response.setStatusCode(500);
            
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
                Object continuationState= IntegrationEngine.continuationState;
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
            String epfoUANLookupCallOutResponse= (String)IntegrationEngine.processEPFUANLookupResponse(labels, IntegrationEngine.continuationState);
            Test.stopTest();
            String responseActual ='{"body":null,"ResponseData":{"Status":"Success","ResponseInfo":{"SolutionSetInstanceId":"0d4c19cd-cd2c-49c3-b334-e3087ebf02fa","ApplicationId":26867037},"Fields":{"Decision":"Pass","ApplicationId":"26867037","ApplicationData":{"Services":{"Service":{"Skip":"N","Name":"PublicDataAPI","Id":"","EnableSimulation":"false","Consent":"true"}}},"Applicants":{"Applicant":{"Telephones":{"Telephone":{"TelephoneType":"01","TelephoneNumber":"9730926500"}},"Services":{"Service":[{"Status":"Pass","Operations":{"Operation":[{"Status":"Pass","Params":{"Param":[{"Value":"Y","Name":"consent"}]},"Name":"uan-lookup","Id":"","Data":{"Response":{"RawResponse":"{\\"result\\":{\\"uan-lookup\\":{\\"result\\":{},\\"request_id\\":\\"c32483ae-2fe6-400b-af65-41762f40a959\\",\\"status-code\\":\\"103\\"},\\"request_id\\":\\"93232171-a1bf-4ec8-9ced-573340590561\\",\\"status-code\\":\\"101\\"}}"}}}]},"Name":"PublicDataAPI","Id":""}]},"ApplicantIdentifier":"828a975f-4ae8-4642-93aa-b854a7c4544c"}}}},"RequestId":"11012022183608385"}';
            System.assertEquals(responseActual,epfoUANLookupCallOutResponse,'Success');
            
        } catch(Exception ex){
            System.assertEquals(ex.getMessage(),'Something went wrong. Please retry.','Exception');
        }
    }
    
    
}