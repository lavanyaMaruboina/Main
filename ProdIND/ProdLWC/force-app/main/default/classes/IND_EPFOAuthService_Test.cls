/*------------------------------------------------------------
Author:        Divya Jawale
Company:       Persistent Systems
Description:   Test class created to validate the IND_EPFOAuthRequest IND_EPFOAuthService IND_EPFOAuthResponse class
History
Date            Author              Comments
-------------------------------------------------------------
21-12-2021      Divya Jawale      Created
------------------------------------------------------------*/
@isTest(SeeAllData=false)
public class IND_EPFOAuthService_Test {
    @TestSetup
    public static void createTestData(){
        Profile p = [SELECT Id FROM Profile WHERE Name='CMU'];
            system.debug('p'+ p);
            User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                              EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                              LocaleSidKey='en_US', ProfileId = p.Id,
                              TimeZoneSidKey='America/Los_Angeles',
                              UserName='standarduser4@testorg.com.psdev1',
                             MobilePhone='9533089614');
            insert u;
        System.runAs(u){
        Opportunity opp = TestDataUtility.createTestOpportunity(false);
        if (Schema.sObjectType.Opportunity.isCreateable()){
            insert opp;
        }        
        Applicant__c applicant = TestDataUtility.createTestApplicantForSMS(false);
        applicant.Opportunity__c=opp.Id;
         String loanAppId = applicant.Opportunity__r.id;
        if (Schema.sObjectType.Applicant__c.isCreateable()){
            insert applicant;
        }
        }
    }
    @isTest
    public static void testEPFOAuthService(){
        
        try{   
            Opportunity opp = [Select Id,Stagename,Sub_Stage__c,View_Application_Sub_Stages__c,Class_of_Activity__c,lead_number__c,LeadSource from Opportunity LIMIT 1];            
   		    Applicant__c app = [Select Id from Applicant__c LIMIT 1];
            User u = [SELECT Id,usertype FROM User WHERE UserName='standarduser4@testorg.com.psdev1' AND IsActive = true LIMIT 1]; 
            String uanNumber = '100869899380';
            Continuation con = (Continuation)IntegrationEngine.doEPFOAuthCallout(app.Id,uanNumber,opp.Id);
            // Create a mock response
            HttpResponse response = new HttpResponse();
            string body='{"JData":"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"}';
            response.setBody(body);
            response.setStatusCode(200);
            
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
                Object continuationState= IntegrationEngine.continuationState;
             String epfoAuthCallOutResponse;
            system.runAs(u){
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
             epfoAuthCallOutResponse= (String)IntegrationEngine.processEPFOAuthResponse(labels, IntegrationEngine.continuationState);
            //IND_EPFOAuthRequest epfoRequest=IND_EPFOAuthService.getEPFOAuthCallOut(applicant,uanNumber,opp.Id );
            Test.stopTest();
            }
            String responseActual ='{"body":null,"ResponseData":{"Status":"Success","ResponseInfo":{"SolutionSetInstanceId":"664fadc6-02f5-41b5-b2a2-c3e4df96967e","ApplicationId":26633435},"Fields":{"Decision":"Pass","ApplicationId":"26633435","ApplicationData":{"Services":{"Service":{"Skip":"N","Name":"PublicDataAPI","Id":"","EnableSimulation":"false","Consent":"true"}}},"Applicants":{"Applicant":{"Telephones":{"Telephone":{"TelephoneType":"01","TelephoneNumber":"9730926500"}},"Services":{"Service":[{"Status":"Pass","Operations":{"Operation":[{"Status":"Pass","Params":{"Param":[{"Value":"Y","Name":"consent"},{"Value":"100869899380","Name":"uan"}]},"Name":"epf-auth","Id":"","Data":{"Response":{"RawResponse":"{\\"result\\":{\\"epf-auth\\":{\\"requestId\\":\\"0a2583b3-7c69-4f12-a5e1-82a225a735cd\\",\\"result\\":{\\"employers\\":[{\\"startMonthYear\\":null,\\"lastMonthYear\\":null,\\"establishmentId\\":\\"TNMAS0085057000\\",\\"establishmentName\\":\\"CONSTIENT GLOBAL SOLUTIONS\\",\\"address\\":{\\"city\\":\\"SANTHOME\\",\\"state\\":\\"TAMIL NADU\\",\\"pincode\\":\\"600004\\",\\"district\\":null,\\"address\\":\\"86-B, 4TH FLOOR, 86-B, 4TH FLOOR,\\"},\\"memberId\\":\\"TNMAS00850570000000086\\",\\"exitReason\\":null,\\"status\\":\\"MULTIPLE_EMPLOYEES_WITH_SAME_NAME\\"}],\\"personalDetails\\":{\\"name\\":\\"BAIREDDY MANJUNATH\\",\\"fatherOrHusbandName\\":null,\\"aadhaarVerificationStatus\\":null,\\"bankAccountStatus\\":null,\\"panVerificationStatus\\":null,\\"contactNo\\":null},\\"summary\\":{\\"minimumWorkExperienceInMonths\\":null,\\"lastEmployer\\":{}},\\"remark\\":\\"\\"},\\"statusCode\\":101},\\"requestId\\":\\"923dfa2c-b373-4975-b275-5c38d28c11c8\\",\\"statusCode\\":\\"101\\"}}"}}}]},"Name":"PublicDataAPI","Id":""}]},"ApplicantIdentifier":"f00bfba5-98b2-4735-a59a-99d77dc1dbc2"}}}},"RequestId":"21122021162717595"}';
            System.assertEquals(responseActual,epfoAuthCallOutResponse,'Success');
            
        }
        catch(Exception ex){
             //System.assertEquals(ex.getMessage(),'Null label');
        }
    }
    
    @isTest
    public static void testEPFOAuthService2(){
        
        try{   
            
            Opportunity opp = [Select Id,Stagename,Sub_Stage__c,View_Application_Sub_Stages__c,Class_of_Activity__c,lead_number__c,LeadSource from Opportunity LIMIT 1];            
   		    Applicant__c app = [Select Id from Applicant__c LIMIT 1];
            User u = [SELECT Id,usertype FROM User WHERE UserName='standarduser4@testorg.com.psdev1' AND IsActive = true LIMIT 1]; 
            String uanNumber = '100869899380';
            Continuation con = (Continuation)IntegrationEngine.doEPFOAuthCallout(app.Id,uanNumber,opp.Id);
            // Create a mock response
            HttpResponse response = new HttpResponse();
            string body='{"JData":"o6RRG0OuQnAf65jc6kEC6TTmwrq9BS5sgxWO4oBC6+zxuKZ8fK01M6jHTHA3mCzNJW/S9OS50AFgAFVrZFRKbKoByWVmXw9ohuTDVpNnkToE/YMVbVL8XyWVWMP8MrV9TtFEXOEsTeQV3ODN/81dFnNuhud9MjfNO6qvP4ivPjhwUuzTBvtFHG+EQy3CZzyi6bGRI1tUcWzu+X+7I+OtisfCCHBdO9hzxSqfVVnMniqZb7pn7qpVDH+VP0WR11zbXKIKeDUWTOVTvDZGx52y7IEEV4zoLaxSvkkW3Jt33zJcu1D19fDPyq1nmPXklPNf/vPFuA8dALYWoNzns62ejhr+LxgKFduZKAhisCeUAWalcIBrJITq19JDjHBsbHphmB4TxonLXhUqb+JwE2Z4AmkhjRLG49jyjIw8gbqdgjb5T+rXNJopaCOPbZTb/XMI/BQz6QuW1KWipyj3pg55zPcpaPfpqx1VKQlL6EZSgoMtE4NtMmwWTgT0LsuVbnqWYRSkdLFnFMfMYl0eOe90CQQtvnVO2TNsAnQmVM5/LaGeXMQ4UsNLfPo6q8y7QQA8Gw1RVkEbrzji7Z1hJ9YWB0fyhQtyc0WCq1cj4SBn4lDTtFhWJpeo/lzKCpsHD0OwyrrbcOivD/51OzgN5WPdWZERNa1Y8wcW6SOyqrRT2ko2mM0nK3OGsCD7RkMx7bIbaTMn3b7VLZhZmKVOBaUgljM2jYa5seoBlmF/iqRA3rZgIpsznr6J17CBQwrmTyUSABlnODbSozE75oaFwddXU0Di/7OAyBf9S9cBnIJcDA60ObgX3AHwWGOuQDll2GU6H55m1NetxK2yfJjx57UfH4QiB6vhX/NoF9XViO6LWDBJVcIddizlbaeNmT6ftZDJYrd4lQxi11c6PHGjUosyRd0y6eL67nAd+VnLsmYxYoyX1EEr20s6cALcYFwfahjIi7qb+c1+xs0qbuT1dyaZu2Sv2n9bN8EKDMjDbYhGkqJ8InGarjI3NY3416FpDb6pELGOoGMJYZJZqNlF+cp0nj2T426nW1gic7MbRnicGlfPWUNMcywcUn6J76dI5vKzpJ7HS8DQdD1NI7xcQGgsyfepe0cf84oVdDKxHgDzSGz1WV9beOjI8xA0bznhBlmdoVQAIlZRdgKg/RjCN1ZLPBIAJOeGIbxwK/PLsdutxCVY9udiDbinx2qExRAQ3SBismYg+O5U4PEzTEUTABOkdfBRBNcNU6dyZU71rTAfEfR6z3L7MGs6n4dyUBYGzyJIwf5e+MNI+DzkkBSmtfldOZVaBbmrIK6TBtVqcRrEvIVqWJcXnb3jLazmj8Qr2oRFHchbbCeSgJZxjYfxCbhAO0Lr2yjne2T1SbF/WnN7D2r9xLvieII60itl1XbtLEuptHLG35ZEYce4mvcfuLMiViUO8t9V126jAfQwCRcirgtpCT9fPyfruJD7uZ3Y0/9VR22G0WvWUf+CJjcXoLvp0MFopxsICtXwNi02vMOhb0UjY/Jy15pKFffgI4kLdpACnhy/OLUVtwK+P4GqCvFlCfEHKet3HYW9JC5zINmEJV+lH0GJJkrO522M4ksCiZ2ck+7yaIiUOwqO+knEayeCBx9Vrkna/mNJ7y4j8nq44rWYACR7V9nqxlRgzwJVHuuLzNlEmRARZI/IXK9IP+f07okZF0+E8Jio4w1Ew+AE4vuOVcpvXhKq2mAVhB//6DY3Ljd5vMngPEfKL+TtTk6AZ5btov4TJF4JLpZIQK7nl91eJfLvYjwKZzSheEuy1OZQhjihY1pma1GqPkdAH7SGVoE97DEjB6sOo6DOboqj92GpmaO3jGv57LBWabQQ8HDot7JTgvaFLpUw+02HV0Gupz85CNtBhNjGsh0rm27H6gdzUvvvFtIB82mltheCTdHHwkkAViSiFc7X2mtm5qYnF/h4oTOFPl1OtOQH5T41+zbOVVdH7cpjMpIL4pEvZaVvgVfophiZVo5WVsecwbxN79CkhlFuXvA4U5LC6YjWDUXYYsZ059BJ9tgRm0cb3QSlwVonUCU0xVxNjCg81zj52pZnktoUu2QSFaVo9FWuoto+Efs35fEOBfbr8VtvG82rLXTvwNFFOqom22mzEElFkeiIPhV0wP5Sv4AhYhmBq+0I9h+dErM2nMkyVxNhLfW+UFoOsTPcIkZQWpdO8bLZ1/xc5OnRqdwg1nUwU9Lp9K/w8FIx8wVMD5q6UFgkcM6rB+XQpA4rsAo636lJJ5OLxS62Xv6lGNnVdFnwt6wbxwc="}';
            response.setBody(body);
            response.setStatusCode(200);
            
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
                Object continuationState= IntegrationEngine.continuationState;
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
            String epfoAuthCallOutResponse= (String)IntegrationEngine.processEPFOAuthResponse(labels, IntegrationEngine.continuationState);
            Test.stopTest();
            String responseActual ='{"body":null,"ResponseData":{"Status":"Success","ResponseInfo":{"SolutionSetInstanceId":"664fadc6-02f5-41b5-b2a2-c3e4df96967e","ApplicationId":26633435},"Fields":{"Decision":"Pass","ApplicationId":"26633435","ApplicationData":{"Services":{"Service":{"Skip":"N","Name":"PublicDataAPI","Id":"","EnableSimulation":"false","Consent":"true"}}},"Applicants":{"Applicant":{"Telephones":{"Telephone":{"TelephoneType":"01","TelephoneNumber":"9730926500"}},"Services":{"Service":[{"Status":"Pass","Operations":{"Operation":[{"Status":"Pass","Params":{"Param":[{"Value":"Y","Name":"consent"},{"Value":"100869899380","Name":"uan"}]},"Name":"epf-auth","Id":"","Data":{"Response":{"RawResponse":"{\\"result\\":{\\"epf-auth\\":{\\"requestId\\":\\"0a2583b3-7c69-4f12-a5e1-82a225a735cd\\",\\"result\\":{\\"employers\\":[{\\"startMonthYear\\":null,\\"lastMonthYear\\":null,\\"establishmentId\\":\\"TNMAS0085057000\\",\\"establishmentName\\":\\"CONSTIENT GLOBAL SOLUTIONS\\",\\"address\\":{\\"city\\":\\"SANTHOME\\",\\"state\\":\\"TAMIL NADU\\",\\"pincode\\":\\"600004\\",\\"district\\":null,\\"address\\":\\"86-B, 4TH FLOOR, 86-B, 4TH FLOOR,\\"},\\"memberId\\":\\"TNMAS00850570000000086\\",\\"exitReason\\":null,\\"status\\":\\"MULTIPLE_EMPLOYEES_WITH_SAME_NAME\\"}],\\"personalDetails\\":{\\"name\\":\\"BAIREDDY MANJUNATH\\",\\"fatherOrHusbandName\\":null,\\"aadhaarVerificationStatus\\":null,\\"bankAccountStatus\\":null,\\"panVerificationStatus\\":null,\\"contactNo\\":null},\\"summary\\":{\\"minimumWorkExperienceInMonths\\":null,\\"lastEmployer\\":{}},\\"remark\\":\\"\\"},\\"statusCode\\":101},\\"requestId\\":\\"923dfa2c-b373-4975-b275-5c38d28c11c8\\",\\"statusCode\\":\\"101\\"}}"}}}]},"Name":"PublicDataAPI","Id":""}]},"ApplicantIdentifier":"f00bfba5-98b2-4735-a59a-99d77dc1dbc2"}}}},"RequestId":"21122021162717595"}';
            System.assertEquals(responseActual,epfoAuthCallOutResponse,'Success');
            
        } catch(Exception ex){
            //   System.assertEquals(ex.getMessage(),System.Label.LeadId,'Exception');
        }
    }
    
    @isTest
    public static void testEPFOAuthService3(){
        
        try{   
            
            Opportunity opp = [Select Id,Stagename,Sub_Stage__c,View_Application_Sub_Stages__c,Class_of_Activity__c,lead_number__c,LeadSource from Opportunity LIMIT 1];            
   		    Applicant__c app = [Select Id from Applicant__c LIMIT 1];
            User u = [SELECT Id,usertype FROM User WHERE UserName='standarduser4@testorg.com.psdev1' AND IsActive = true LIMIT 1]; 
            String uanNumber = '';
            Continuation con = (Continuation)IntegrationEngine.doEPFOAuthCallout(app.Id,uanNumber,opp.Id);
            // Create a mock response
            HttpResponse response = new HttpResponse();
            string body='{"JData":"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"}';
            response.setBody(body);
            response.setStatusCode(200);
            
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
                Object continuationState= IntegrationEngine.continuationState;
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
            String epfoAuthCallOutResponse= (String)IntegrationEngine.processEPFOAuthResponse(labels, IntegrationEngine.continuationState);
            Test.stopTest();
            String responseActual ='{"body":null,"ResponseData":{"Status":"Success","ResponseInfo":{"SolutionSetInstanceId":"664fadc6-02f5-41b5-b2a2-c3e4df96967e","ApplicationId":26633435},"Fields":{"Decision":"Pass","ApplicationId":"26633435","ApplicationData":{"Services":{"Service":{"Skip":"N","Name":"PublicDataAPI","Id":"","EnableSimulation":"false","Consent":"true"}}},"Applicants":{"Applicant":{"Telephones":{"Telephone":{"TelephoneType":"01","TelephoneNumber":"9730926500"}},"Services":{"Service":[{"Status":"Pass","Operations":{"Operation":[{"Status":"Pass","Params":{"Param":[{"Value":"Y","Name":"consent"},{"Value":"100869899380","Name":"uan"}]},"Name":"epf-auth","Id":"","Data":{"Response":{"RawResponse":"{\\"result\\":{\\"epf-auth\\":{\\"requestId\\":\\"0a2583b3-7c69-4f12-a5e1-82a225a735cd\\",\\"result\\":{\\"employers\\":[{\\"startMonthYear\\":null,\\"lastMonthYear\\":null,\\"establishmentId\\":\\"TNMAS0085057000\\",\\"establishmentName\\":\\"CONSTIENT GLOBAL SOLUTIONS\\",\\"address\\":{\\"city\\":\\"SANTHOME\\",\\"state\\":\\"TAMIL NADU\\",\\"pincode\\":\\"600004\\",\\"district\\":null,\\"address\\":\\"86-B, 4TH FLOOR, 86-B, 4TH FLOOR,\\"},\\"memberId\\":\\"TNMAS00850570000000086\\",\\"exitReason\\":null,\\"status\\":\\"MULTIPLE_EMPLOYEES_WITH_SAME_NAME\\"}],\\"personalDetails\\":{\\"name\\":\\"BAIREDDY MANJUNATH\\",\\"fatherOrHusbandName\\":null,\\"aadhaarVerificationStatus\\":null,\\"bankAccountStatus\\":null,\\"panVerificationStatus\\":null,\\"contactNo\\":null},\\"summary\\":{\\"minimumWorkExperienceInMonths\\":null,\\"lastEmployer\\":{}},\\"remark\\":\\"\\"},\\"statusCode\\":101},\\"requestId\\":\\"923dfa2c-b373-4975-b275-5c38d28c11c8\\",\\"statusCode\\":\\"101\\"}}"}}}]},"Name":"PublicDataAPI","Id":""}]},"ApplicantIdentifier":"f00bfba5-98b2-4735-a59a-99d77dc1dbc2"}}}},"RequestId":"21122021162717595"}';
            System.assertEquals(responseActual,epfoAuthCallOutResponse,'Success');
            
        } catch(Exception ex){
            //  System.assertEquals(ex.getMessage(),System.Label.UAN,'Exception');
        }
    }
    
    @isTest
    public static void verifyGetEPFOAuthCallOut(){
        Opportunity opp = [Select Id,Stagename,Sub_Stage__c,View_Application_Sub_Stages__c,Class_of_Activity__c,lead_number__c,LeadSource from Opportunity LIMIT 1];            
        opp.Lead_number__c = '12121';
        update opp;
        String uanNumber = '100869899380';
        Applicant__c app = [Select Id,Contact_Number__c,Opportunity__r.Lead_Number__c from Applicant__c LIMIT 1];
        
        IND_EPFOAuthRequest result = new IND_EPFOAuthRequest(app, uanNumber, opp.Id);
        
        Map<String,String> requestHeaderMap = result.getHttpRequestHeaders();
        System.assert(requestHeaderMap != null, 'request headers should not be blank');
        
        try{
            result = IND_EPFOAuthService.getEPFOAuthCallOut(app, uanNumber, opp.Id);
            System.debug('result ==>'+result);
        }catch(Exception pEx){
            System.debug('pEx ==>'+pEx); 
        }
    }
    
    @isTest
    public static void validateException(){
        try{
            IND_EPFOAuthService.getEPFOAuthCallOut(null, null, null);
        }catch(Exception pEx){
            System.assert(pEx.getMessage() != null);
        }
        
    }
}