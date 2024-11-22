/*------------------------------------------------------------
Author:        Aman Mundhada
Company:       Persistent Systems
Description:   Test class created to validate the IND_DrivingLicenseRequest IND_DrivingLicenseService IND_DrivingLicenseResponse class
History
Date            Author              Comments
-------------------------------------------------------------
1-12-2021      Aman Mundhada       Created
------------------------------------------------------------*/
@isTest(SeeAllData=false)
public class IND_DrivingLicenseService_Test {
    
    @TestSetup
    public static void testSetupData(){
        Profile p = [SELECT Id FROM Profile WHERE Name='CMU'];   
    		User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
					EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
					LocaleSidKey='en_US', ProfileId = p.Id,MobilePhone = '9701498575',
					TimeZoneSidKey='America/Los_Angeles',Maker_Id__c='1001',
					UserName='standarduser4@testorg.com.psdev1');
            insert u;
    }
    @isTest
    public static void testINDDrivingLicenseService(){
        
        try{   
            User u=[Select Id,Name from User Where UserName='standarduser4@testorg.com.psdev1'];
            
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            Applicant__c applicant = TestDataUtility.createTestApplicant(false);
            applicant.Opportunity__c=opp.Id;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert applicant;
            }
            
            Documents__c document = TestDataUtility.createTestDLDocs(false,applicant,opp);
            if (Schema.sObjectType.Documents__c.isCreateable()){
                insert document;
            }
            
            Datetime dOB = (Datetime)document.KYC_DOB__c;
            String dateOfBirth= dOB.format('ddMMyyyy') ;
            
            String dlCallOutRequest = '{"applicantId":"'+applicant.Id+'" ,"dateOfBirth":"'+dateOfBirth+'" ,"dlNumber":"TN2020090003150"}';
            Continuation con = (Continuation)IntegrationEngine.doDLCallout(dlCallOutRequest);
            HttpResponse response = new HttpResponse();
            response.setBody('{"JData":"62AJ1Cg+PQw/eIEdwr8qsHh14lA1ifepzRkNF0X0b6/AZKW3pBcJvolzlz87NKBoiscyQKYUuWCwS0mVGBRihYj+AolUoT6FOfE85Pv8562uGyMsWjSncjuy091kztjV9Qs60cj8wAaeJ1d4dYSx0O1CLHJ0hcAXPMPXG2ta6Rjk8ey/1FPMFIbcMTXvA/1GhC+kw0jIlcTJ7mRQF/I2Fhrz7JxmX6VXo5paGkTex1DIjzKH5BQaEpU50RPTLu/CzMfd4AQz2jgaL6u1CYGdLchWFWf3KE4hp9q09Y2DWIog/eSoupO2cJTvNXYmU12xmhJS4Wm6hphj2nNwC1mcneSbJi+J7z3451v5bw4VQXFbjnuJkC0mMH6tzAzKDu7jSD8qBXaRScp1KCZgBEqgDtmZ0ynBUzbUVQtR4ofnEdWlCcBGknUfb5cjEjVNlucx1SnVA2QkqhZkgY0FIOkSgoqqCgHoh4IMVZbTas18fbOc30KZ2I12UH/3Xa5W+tTQ0B6s6x9nPm9kiSJL4eIZF3QdE9I8do5q8/lS/ZrVNOgWUFoIk36gQ/z4Gn1EBn+F9CZQv5xhS/4gFc5CDV1vuw+SROXoe86mCCR9xizgF0fc7uRLyjaTdMHKPZtj+OZGMyF2a+KC0QT/m7uofG3BNRmf48NCSFznRFa/fkiTIs2zvuTScus+Emus+NyBVNxjp07RmlP6bK24HdP8hTdTAnGiyhdi7lW5FJj5eYk50gWVOZm8ZxETfTVD6DNtZmIkC4yiFLOnoRkWhe78UK8WlxBcfwHh+XVNjjYZzHJ4HiGWI6xO4cldACQt1fh/iWWhgIyLZ+IT4ZsOwtzOx66U33iLB0e5D1hSxWtQoOy4iHul8ctfoDm9KUcscAgOmvydWaBIh1WwNqEZvWBNoadITDTWAx2z5teaZ++8phP9Qt61zJ3t6+quq+htjPVns8OEi8FJILtrmD9eOaw4mpUbwHATkSLzJgkqb5sXN0LhL1Hh6xDOMwJMQDPmu44znNsU28+oOE/Q+GUY4d/DOQLyag3o3JrTKzn3L7qAS7Q+FscBhoaTAJiWYjy/uWctS8aDxq9KLpRJSAy3p+2MCR7M1NNh1camAgi5/JhJlT2QCHoVrvysh1t4K/dAUN1QLczmqQKhVDAxxnb8YaTb+5J8zjik2mDEw1eyvcEMWnKyoSMcDIg38lQqHCg5me5C+wHDXCUKwqEBn79LrQmV3TrcLmUUBaPNIIudfAX/+SLIg6P8jTjSJypgrmvOs/GImxYBPoLaSlDr1bIYK84a58E7P21+bLo+zQ0VyxwPRoLFAtvP6Ly85mP86iGNVPOurmn3z1oTuAkw6CouYaUSEVqEKRMnUSm1pUmg1SuiRqe6IIKrXNvReSfv02OwwB7wzHfu6KW3bMXPz2f7PPMglFNlEDPbMkz0A+i3SrzcGdaC2vr4O5I3y8Fbb3VqgocobOrpC5W+/Q465w2+dLv5EG/8W5AXGbSmWDdFx2xXLMTM7xWfBR8SPB+L5jQrrnq65N8iayUy0ECmuMDCZCSpKTxU/WfFbXIJDmUlWYAacFE8yDGEroS5cEE09kpR/K8FQtD7HcDaJAT7jaJyAoHJJ1Uh0CoCsi/ybM5Uvs9xBsN9UHX2nSylGt+crvbeszIJLbiuo+DXzNAwOJ/d1ve+sfvRuQ=="}');
            response.setStatusCode(200);
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
            Object continuationState= IntegrationEngine.continuationState;
            String dlCallOutResponse='';
            system.runAs(u){
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
            dlCallOutResponse=(String)IntegrationEngine.processDLCallOutResponse(labels, IntegrationEngine.continuationState);
            Test.stopTest();
            }    
            String responseExpected ='{"body":null,"ResponseData":{"Untagged":"MARA THE |, ARDEE | PUNE","Street":"MILL ROAD","Status":"Success","State":"","ResponseInfo":{"SolutionSetInstanceId":"a010f185-d448-48a2-bce7-1f33212327ec","ApplicationId":26951964},"Pin":"400254","locality":"KAMAL NAGAR","Landmark":"NEAR PUJARI HOSPITAL","House":"BLOCK NO . X , SECTOR 5 , FLAT C - 19  04","Floor":"1","Fields":{"Decision":"Pass","ApplicationId":"26951964","ApplicationData":{"Services":{"Service":{"Skip":"N","Name":"PublicDataAPI","Id":"","EnableSimulation":"","Consent":"true"}}},"Applicants":{"Applicant":{"Services":{"Service":[{"Status":"Pass","Operations":{"Operation":[{"Status":"Pass","Params":{"Param":[{"Value":"Y","Name":"consent"}]},"Name":"dl","Id":"","Errors":null,"Data":{"Response":{"RawResponse":"{\\"result\\":{\\"dl\\":{\\"result\\":{},\\"request_id\\":\\"f73e6599-c022-4489-886a-16837d76046b\\",\\"status-code\\":\\"102\\"},\\"request_id\\":\\"35d4d0d0-e862-441d-ae28-97c4a75c8604\\",\\"status-code\\":\\"101\\"}}"}}}]},"Name":"PublicDataAPI","Id":""}]},"Identifiers":{"Identifier":{"IdType":"04","IdNumber":"TN2020090003150"}},"DateOfBirth":"08021990","ApplicantIdentifier":"e72119d9-4e2c-427a-8276-c1d98048a728"}}},"District":"","Complex":"","CO":"","City":"","Building":"SUNIL APARTMENT"},"RequestId":"20012022145902503"}';        
            System.assertEquals(responseExpected,dlCallOutResponse,'Success');
            
        } catch(Exception ex){
            //System.assertEquals(ex.getMessage(),'Script-thrown exception');
        }
    }
    
    @isTest
    public static void testINDDrivingLicenseService2(){
        
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
            
            Documents__c document = TestDataUtility.createTestDLDocs(false,applicant,opp);
            if (Schema.sObjectType.Documents__c.isCreateable()){
                insert document;
            }
            
            Datetime dOB = (Datetime)document.KYC_DOB__c;
            String dateOfBirth= dOB.format('ddMMyyyy') ;
            
            String dlCallOutRequest = '{"applicantId":"'+applicant.Id+'" ,"dateOfBirth":"" ,"dlNumber":"TN2020090003150"}';
            Continuation con = (Continuation)IntegrationEngine.doDLCallout(dlCallOutRequest);
            HttpResponse response = new HttpResponse();
            response.setBody('{"JData":"62AJ1Cg+PQw/eIEdwr8qsHh14lA1ifepzRkNF0X0b6/AZKW3pBcJvolzlz87NKBoiscyQKYUuWCwS0mVGBRihYj+AolUoT6FOfE85Pv8562uGyMsWjSncjuy091kztjV9Qs60cj8wAaeJ1d4dYSx0O1CLHJ0hcAXPMPXG2ta6Rjk8ey/1FPMFIbcMTXvA/1GhC+kw0jIlcTJ7mRQF/I2Fhrz7JxmX6VXo5paGkTex1DIjzKH5BQaEpU50RPTLu/CzMfd4AQz2jgaL6u1CYGdLchWFWf3KE4hp9q09Y2DWIog/eSoupO2cJTvNXYmU12xmhJS4Wm6hphj2nNwC1mcneSbJi+J7z3451v5bw4VQXFbjnuJkC0mMH6tzAzKDu7jSD8qBXaRScp1KCZgBEqgDtmZ0ynBUzbUVQtR4ofnEdWlCcBGknUfb5cjEjVNlucx1SnVA2QkqhZkgY0FIOkSgoqqCgHoh4IMVZbTas18fbOc30KZ2I12UH/3Xa5W+tTQ0B6s6x9nPm9kiSJL4eIZF3QdE9I8do5q8/lS/ZrVNOgWUFoIk36gQ/z4Gn1EBn+F9CZQv5xhS/4gFc5CDV1vuw+SROXoe86mCCR9xizgF0fc7uRLyjaTdMHKPZtj+OZGMyF2a+KC0QT/m7uofG3BNRmf48NCSFznRFa/fkiTIs2zvuTScus+Emus+NyBVNxjp07RmlP6bK24HdP8hTdTAnGiyhdi7lW5FJj5eYk50gWVOZm8ZxETfTVD6DNtZmIkC4yiFLOnoRkWhe78UK8WlxBcfwHh+XVNjjYZzHJ4HiGWI6xO4cldACQt1fh/iWWhgIyLZ+IT4ZsOwtzOx66U33iLB0e5D1hSxWtQoOy4iHul8ctfoDm9KUcscAgOmvydWaBIh1WwNqEZvWBNoadITDTWAx2z5teaZ++8phP9Qt61zJ3t6+quq+htjPVns8OEi8FJILtrmD9eOaw4mpUbwHATkSLzJgkqb5sXN0LhL1Hh6xDOMwJMQDPmu44znNsU28+oOE/Q+GUY4d/DOQLyag3o3JrTKzn3L7qAS7Q+FscBhoaTAJiWYjy/uWctS8aDxq9KLpRJSAy3p+2MCR7M1NNh1camAgi5/JhJlT2QCHoVrvysh1t4K/dAUN1QLczmqQKhVDAxxnb8YaTb+5J8zjik2mDEw1eyvcEMWnKyoSMcDIg38lQqHCg5me5C+wHDXCUKwqEBn79LrQmV3TrcLmUUBaPNIIudfAX/+SLIg6P8jTjSJypgrmvOs/GImxYBPoLaSlDr1bIYK84a58E7P21+bLo+zQ0VyxwPRoLFAtvP6Ly85mP86iGNVPOurmn3z1oTuAkw6CouYaUSEVqEKRMnUSm1pUmg1SuiRqe6IIKrXNvReSfv02OwwB7wzHfu6KW3bMXPz2f7PPMglFNlEDPbMkz0A+i3SrzcGdaC2vr4O5I3y8Fbb3VqgocobOrpC5W+/Q465w2+dLv5EG/8W5AXGbSmWDdFx2xXLMTM7xWfBR8SPB+L5jQrrnq65N8iayUy0ECmuMDCZCSpKTxU/WfFbXIJDmUlWYAacFE8yDGEroS5cEE09kpR/K8FQtD7HcDaJAT7jaJyAoHJJ1Uh0CoCsi/ybM5Uvs9xBsN9UHX2nSylGt+crvbeszIJLbiuo+DXzNAwOJ/d1ve+sfvRuQ=="}');
            response.setStatusCode(200);
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
                Object continuationState= IntegrationEngine.continuationState;         
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
            String dlCallOutResponse=(String)IntegrationEngine.processDLCallOutResponse(labels, IntegrationEngine.continuationState);
            
            Test.stopTest();
            String responseExpected ='{"body":null,"ResponseData":{"Untagged":"MARA THE |, ARDEE | PUNE","Street":"MILL ROAD","Status":"Success","State":"","ResponseInfo":{"SolutionSetInstanceId":"a010f185-d448-48a2-bce7-1f33212327ec","ApplicationId":26951964},"Pin":"400254","locality":"KAMAL NAGAR","Landmark":"NEAR PUJARI HOSPITAL","House":"BLOCK NO . X , SECTOR 5 , FLAT C - 19  04","Floor":"1","Fields":{"Decision":"Pass","ApplicationId":"26951964","ApplicationData":{"Services":{"Service":{"Skip":"N","Name":"PublicDataAPI","Id":"","EnableSimulation":"","Consent":"true"}}},"Applicants":{"Applicant":{"Services":{"Service":[{"Status":"Pass","Operations":{"Operation":[{"Status":"Pass","Params":{"Param":[{"Value":"Y","Name":"consent"}]},"Name":"dl","Id":"","Errors":null,"Data":{"Response":{"RawResponse":"{\\"result\\":{\\"dl\\":{\\"result\\":{},\\"request_id\\":\\"f73e6599-c022-4489-886a-16837d76046b\\",\\"status-code\\":\\"102\\"},\\"request_id\\":\\"35d4d0d0-e862-441d-ae28-97c4a75c8604\\",\\"status-code\\":\\"101\\"}}"}}}]},"Name":"PublicDataAPI","Id":""}]},"Identifiers":{"Identifier":{"IdType":"04","IdNumber":"TN2020090003150"}},"DateOfBirth":"08021990","ApplicantIdentifier":"e72119d9-4e2c-427a-8276-c1d98048a728"}}},"District":"","Complex":"","CO":"","City":"","Building":"SUNIL APARTMENT"},"RequestId":"20012022145902503"}';        
            System.assertEquals(responseExpected,dlCallOutResponse,'Fail');
            
        } catch(Exception ex){
            System.assertEquals(ex.getMessage(),System.Label.DateOfBirth,'Exception');
        }
    }
    
    @isTest
    public static void testINDDrivingLicenseService3(){
        
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
            
            Documents__c document = TestDataUtility.createTestDLDocs(false,applicant,opp);
            if (Schema.sObjectType.Documents__c.isCreateable()){
                insert document;
            }
            
            Datetime dOB = (Datetime)document.KYC_DOB__c;
            String dateOfBirth= dOB.format('ddMMyyyy') ;
            
            String dlCallOutRequest = '{"applicantId":"'+applicant.Id+'" ,"dateOfBirth":"'+dateOfBirth+'" ,"dlNumber":""}';
            Continuation con = (Continuation)IntegrationEngine.doDLCallout(dlCallOutRequest);
            HttpResponse response = new HttpResponse();
            response.setBody('{"JData":"62AJ1Cg+PQw/eIEdwr8qsHh14lA1ifepzRkNF0X0b6/AZKW3pBcJvolzlz87NKBoiscyQKYUuWCwS0mVGBRihYj+AolUoT6FOfE85Pv8562uGyMsWjSncjuy091kztjV9Qs60cj8wAaeJ1d4dYSx0O1CLHJ0hcAXPMPXG2ta6Rjk8ey/1FPMFIbcMTXvA/1GhC+kw0jIlcTJ7mRQF/I2Fhrz7JxmX6VXo5paGkTex1DIjzKH5BQaEpU50RPTLu/CzMfd4AQz2jgaL6u1CYGdLchWFWf3KE4hp9q09Y2DWIog/eSoupO2cJTvNXYmU12xmhJS4Wm6hphj2nNwC1mcneSbJi+J7z3451v5bw4VQXFbjnuJkC0mMH6tzAzKDu7jSD8qBXaRScp1KCZgBEqgDtmZ0ynBUzbUVQtR4ofnEdWlCcBGknUfb5cjEjVNlucx1SnVA2QkqhZkgY0FIOkSgoqqCgHoh4IMVZbTas18fbOc30KZ2I12UH/3Xa5W+tTQ0B6s6x9nPm9kiSJL4eIZF3QdE9I8do5q8/lS/ZrVNOgWUFoIk36gQ/z4Gn1EBn+F9CZQv5xhS/4gFc5CDV1vuw+SROXoe86mCCR9xizgF0fc7uRLyjaTdMHKPZtj+OZGMyF2a+KC0QT/m7uofG3BNRmf48NCSFznRFa/fkiTIs2zvuTScus+Emus+NyBVNxjp07RmlP6bK24HdP8hTdTAnGiyhdi7lW5FJj5eYk50gWVOZm8ZxETfTVD6DNtZmIkC4yiFLOnoRkWhe78UK8WlxBcfwHh+XVNjjYZzHJ4HiGWI6xO4cldACQt1fh/iWWhgIyLZ+IT4ZsOwtzOx66U33iLB0e5D1hSxWtQoOy4iHul8ctfoDm9KUcscAgOmvydWaBIh1WwNqEZvWBNoadITDTWAx2z5teaZ++8phP9Qt61zJ3t6+quq+htjPVns8OEi8FJILtrmD9eOaw4mpUbwHATkSLzJgkqb5sXN0LhL1Hh6xDOMwJMQDPmu44znNsU28+oOE/Q+GUY4d/DOQLyag3o3JrTKzn3L7qAS7Q+FscBhoaTAJiWYjy/uWctS8aDxq9KLpRJSAy3p+2MCR7M1NNh1camAgi5/JhJlT2QCHoVrvysh1t4K/dAUN1QLczmqQKhVDAxxnb8YaTb+5J8zjik2mDEw1eyvcEMWnKyoSMcDIg38lQqHCg5me5C+wHDXCUKwqEBn79LrQmV3TrcLmUUBaPNIIudfAX/+SLIg6P8jTjSJypgrmvOs/GImxYBPoLaSlDr1bIYK84a58E7P21+bLo+zQ0VyxwPRoLFAtvP6Ly85mP86iGNVPOurmn3z1oTuAkw6CouYaUSEVqEKRMnUSm1pUmg1SuiRqe6IIKrXNvReSfv02OwwB7wzHfu6KW3bMXPz2f7PPMglFNlEDPbMkz0A+i3SrzcGdaC2vr4O5I3y8Fbb3VqgocobOrpC5W+/Q465w2+dLv5EG/8W5AXGbSmWDdFx2xXLMTM7xWfBR8SPB+L5jQrrnq65N8iayUy0ECmuMDCZCSpKTxU/WfFbXIJDmUlWYAacFE8yDGEroS5cEE09kpR/K8FQtD7HcDaJAT7jaJyAoHJJ1Uh0CoCsi/ybM5Uvs9xBsN9UHX2nSylGt+crvbeszIJLbiuo+DXzNAwOJ/d1ve+sfvRuQ=="}');
            response.setStatusCode(200);
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
                Object continuationState= IntegrationEngine.continuationState;         
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
            String dlCallOutResponse=(String)IntegrationEngine.processDLCallOutResponse(labels, IntegrationEngine.continuationState);
            
            Test.stopTest();
            String responseExpected ='{"body":null,"ResponseData":{"Untagged":"MARA THE |, ARDEE | PUNE","Street":"MILL ROAD","Status":"Success","State":"","ResponseInfo":{"SolutionSetInstanceId":"a010f185-d448-48a2-bce7-1f33212327ec","ApplicationId":26951964},"Pin":"400254","locality":"KAMAL NAGAR","Landmark":"NEAR PUJARI HOSPITAL","House":"BLOCK NO . X , SECTOR 5 , FLAT C - 19  04","Floor":"1","Fields":{"Decision":"Pass","ApplicationId":"26951964","ApplicationData":{"Services":{"Service":{"Skip":"N","Name":"PublicDataAPI","Id":"","EnableSimulation":"","Consent":"true"}}},"Applicants":{"Applicant":{"Services":{"Service":[{"Status":"Pass","Operations":{"Operation":[{"Status":"Pass","Params":{"Param":[{"Value":"Y","Name":"consent"}]},"Name":"dl","Id":"","Errors":null,"Data":{"Response":{"RawResponse":"{\\"result\\":{\\"dl\\":{\\"result\\":{},\\"request_id\\":\\"f73e6599-c022-4489-886a-16837d76046b\\",\\"status-code\\":\\"102\\"},\\"request_id\\":\\"35d4d0d0-e862-441d-ae28-97c4a75c8604\\",\\"status-code\\":\\"101\\"}}"}}}]},"Name":"PublicDataAPI","Id":""}]},"Identifiers":{"Identifier":{"IdType":"04","IdNumber":"TN2020090003150"}},"DateOfBirth":"08021990","ApplicantIdentifier":"e72119d9-4e2c-427a-8276-c1d98048a728"}}},"District":"","Complex":"","CO":"","City":"","Building":"SUNIL APARTMENT"},"RequestId":"20012022145902503"}';        
            System.assertEquals(responseExpected,dlCallOutResponse,'Fail');
            
        } catch(Exception ex){
            System.assertEquals(ex.getMessage(),System.Label.DrivingLicenseNumber,'Exception');
        }
    }
     
 /*   @isTest
    public static void testINDDrivingLicenseService5(){
        
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
            
            Documents__c document = TestDataUtility.createTestDLDocs(false,applicant,opp);
            if (Schema.sObjectType.Documents__c.isCreateable()){
                insert document;
            }
            
            Datetime dOB = (Datetime)document.KYC_DOB__c;
            String dateOfBirth= dOB.format('ddMMyyyy') ;
            
            String dlCallOutRequest = '{"applicantId":"'+applicant.Id+'" ,"dateOfBirth":"'+dateOfBirth+'" ,"dlNumber":"TN2020090003150"}';
            Continuation con = (Continuation)IntegrationEngine.doDLCallout(dlCallOutRequest);
            HttpResponse response = new HttpResponse();
            response.setBody('{"JData":"62AJ1Cg+PQw/eIEdwr8qsHh14lA1ifepzRkNF0X0b6/AZKW3pBcJvolzlz87NKBoiscyQKYUuWCwS0mVGBRihYj+AolUoT6FOfE85Pv8562uGyMsWjSncjuy091kztjV9Qs60cj8wAaeJ1d4dYSx0O1CLHJ0hcAXPMPXG2ta6Rjk8ey/1FPMFIbcMTXvA/1GhC+kw0jIlcTJ7mRQF/I2Fhrz7JxmX6VXo5paGkTex1DIjzKH5BQaEpU50RPTLu/CzMfd4AQz2jgaL6u1CYGdLchWFWf3KE4hp9q09Y2DWIog/eSoupO2cJTvNXYmU12xmhJS4Wm6hphj2nNwC1mcneSbJi+J7z3451v5bw4VQXFbjnuJkC0mMH6tzAzKDu7jSD8qBXaRScp1KCZgBEqgDtmZ0ynBUzbUVQtR4ofnEdWlCcBGknUfb5cjEjVNlucx1SnVA2QkqhZkgY0FIOkSgoqqCgHoh4IMVZbTas18fbOc30KZ2I12UH/3Xa5W+tTQ0B6s6x9nPm9kiSJL4eIZF3QdE9I8do5q8/lS/ZrVNOgWUFoIk36gQ/z4Gn1EBn+F9CZQv5xhS/4gFc5CDV1vuw+SROXoe86mCCR9xizgF0fc7uRLyjaTdMHKPZtj+OZGMyF2a+KC0QT/m7uofG3BNRmf48NCSFznRFa/fkiTIs2zvuTScus+Emus+NyBVNxjp07RmlP6bK24HdP8hTdTAnGiyhdi7lW5FJj5eYk50gWVOZm8ZxETfTVD6DNtZmIkC4yiFLOnoRkWhe78UK8WlxBcfwHh+XVNjjYZzHJ4HiGWI6xO4cldACQt1fh/iWWhgIyLZ+IT4ZsOwtzOx66U33iLB0e5D1hSxWtQoOy4iHul8ctfoDm9KUcscAgOmvydWaBIh1WwNqEZvWBNoadITDTWAx2z5teaZ++8phP9Qt61zJ3t6+quq+htjPVns8OEi8FJILtrmD9eOaw4mpUbwHATkSLzJgkqb5sXN0LhL1Hh6xDOMwJMQDPmu44znNsU28+oOE/Q+GUY4d/DOQLyag3o3JrTKzn3L7qAS7Q+FscBhoaTAJiWYjy/uWctS8aDxq9KLpRJSAy3p+2MCR7M1NNh1camAgi5/JhJlT2QCHoVrvysh1t4K/dAUN1QLczmqQKhVDAxxnb8YaTb+5J8zjik2mDEw1eyvcEMWnKyoSMcDIg38lQqHCg5me5C+wHDXCUKwqEBn79LrQmV3TrcLmUUBaPNIIudfAX/+SLIg6P8jTjSJypgrmvOs/GImxYBPoLaSlDr1bIYK84a58E7P21+bLo+zQ0VyxwPRoLFAtvP6Ly85mP86iGNVPOurmn3z1oTuAkw6CouYaUSEVqEKRMnUSm1pUmg1SuiRqe6IIKrXNvReSfv02OwwB7wzHfu6KW3bMXPz2f7PPMglFNlEDPbMkz0A+i3SrzcGdaC2vr4O5I3y8Fbb3VqgocobOrpC5W+/Q465w2+dLv5EG/8W5AXGbSmWDdFx2xXLMTM7xWfBR8SPB+L5jQrrnq65N8iayUy0ECmuMDCZCSpKTxU/WfFbXIJDmUlWYAacFE8yDGEroS5cEE09kpR/K8FQtD7HcDaJAT7jaJyAoHJJ1Uh0CoCsi/ybM5Uvs9xBsN9UHX2nSylGt+crvbeszIJLbiuo+DXzNAwOJ/d1ve+sfvRuQ=="}');
            response.setStatusCode(500);
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
            Object continuationState= IntegrationEngine.continuationState;         
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
            String dlCallOutResponse=(String)IntegrationEngine.processDLCallOutResponse(labels, IntegrationEngine.continuationState);
            Test.stopTest();
            String responseExpected ='{"body":null,"ResponseData":{"Untagged":"MARA THE |, ARDEE | PUNE","Street":"MILL ROAD","Status":"Success","State":"","ResponseInfo":{"SolutionSetInstanceId":"a010f185-d448-48a2-bce7-1f33212327ec","ApplicationId":26951964},"Pin":"400254","locality":"KAMAL NAGAR","Landmark":"NEAR PUJARI HOSPITAL","House":"BLOCK NO . X , SECTOR 5 , FLAT C - 19  04","Floor":"1","Fields":{"Decision":"Pass","ApplicationId":"26951964","ApplicationData":{"Services":{"Service":{"Skip":"N","Name":"PublicDataAPI","Id":"","EnableSimulation":"","Consent":"true"}}},"Applicants":{"Applicant":{"Services":{"Service":[{"Status":"Pass","Operations":{"Operation":[{"Status":"Pass","Params":{"Param":[{"Value":"Y","Name":"consent"}]},"Name":"dl","Id":"","Errors":null,"Data":{"Response":{"RawResponse":"{\\"result\\":{\\"dl\\":{\\"result\\":{},\\"request_id\\":\\"f73e6599-c022-4489-886a-16837d76046b\\",\\"status-code\\":\\"102\\"},\\"request_id\\":\\"35d4d0d0-e862-441d-ae28-97c4a75c8604\\",\\"status-code\\":\\"101\\"}}"}}}]},"Name":"PublicDataAPI","Id":""}]},"Identifiers":{"Identifier":{"IdType":"04","IdNumber":"TN2020090003150"}},"DateOfBirth":"08021990","ApplicantIdentifier":"e72119d9-4e2c-427a-8276-c1d98048a728"}}},"District":"","Complex":"","CO":"","City":"","Building":"SUNIL APARTMENT"},"RequestId":"20012022145902503"}';        
            System.assertEquals(responseExpected,dlCallOutResponse,'Fail');
            
        } catch(Exception ex){
            System.assertEquals(ex.getMessage(),System.Label.Retry,'Exception');
        }
    }
*/
    
    @isTest
    public static void testINDDrivingLicenseService6(){
        
        try{   
             //User u=[Select Id,Name from User Where Name='standarduser4@testorg.com.psdev1'];
            
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            Applicant__c applicant = TestDataUtility.createTestApplicant(false);
            applicant.Opportunity__c=opp.Id;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert applicant;
            }
            
            Documents__c document = TestDataUtility.createTestDLDocs(false,applicant,opp);
            if (Schema.sObjectType.Documents__c.isCreateable()){
                insert document;
            }
            
            Datetime dOB = (Datetime)document.KYC_DOB__c;
            String dateOfBirth= dOB.format('ddMMyyyy') ;
            
            String dlCallOutRequest = '{"applicantId":"'+applicant.Id+'" ,"dateOfBirth":"'+dateOfBirth+'" ,"dlNumber":"TN2020090003150"}';
            Continuation con = (Continuation)IntegrationEngine.doDLCallout(dlCallOutRequest);
            HttpResponse response = new HttpResponse();
            response.setBody('{"JData":"62AJ1Cg+PQw/eIEdwr8qsHh14lA1ifepzRkNF0X0b6/AZKW3pBcJvolzlz87NKBoiscyQKYUuWCwS0mVGBRihYj+AolUoT6FOfE85Pv8562uGyMsWjSncjuy091kztjV9Qs60cj8wAaeJ1d4dYSx0O1CLHJ0hcAXPMPXG2ta6Rjk8ey/1FPMFIbcMTXvA/1GhC+kw0jIlcTJ7mRQF/I2Fhrz7JxmX6VXo5paGkTex1DIjzKH5BQaEpU50RPTLu/CzMfd4AQz2jgaL6u1CYGdLchWFWf3KE4hp9q09Y2DWIog/eSoupO2cJTvNXYmU12xmhJS4Wm6hphj2nNwC1mcneSbJi+J7z3451v5bw4VQXFbjnuJkC0mMH6tzAzKDu7jSD8qBXaRScp1KCZgBEqgDtmZ0ynBUzbUVQtR4ofnEdWlCcBGknUfb5cjEjVNlucx1SnVA2QkqhZkgY0FIOkSgoqqCgHoh4IMVZbTas18fbOc30KZ2I12UH/3Xa5W+tTQ0B6s6x9nPm9kiSJL4eIZF3QdE9I8do5q8/lS/ZrVNOgWUFoIk36gQ/z4Gn1EBn+F9CZQv5xhS/4gFc5CDV1vuw+SROXoe86mCCR9xizgF0fc7uRLyjaTdMHKPZtj+OZGMyF2a+KC0QT/m7uofG3BNRmf48NCSFznRFa/fkiTIs2zvuTScus+Emus+NyBVNxjp07RmlP6bK24HdP8hTdTAnGiyhdi7lW5FJj5eYk50gWVOZm8ZxETfTVD6DNtZmIkC4yiFLOnoRkWhe78UK8WlxBcfwHh+XVNjjYZzHJ4HiGWI6xO4cldACQt1fh/iWWhgIyLZ+IT4ZsOwtzOx66U33iLB0e5D1hSxWtQoOy4iHul8ctfoDm9KUcscAgOmvydWaBIh1WwNqEZvWBNoadITDTWAx2z5teaZ++8phP9Qt61zJ3t6+quq+htjPVns8OEi8FJILtrmD9eOaw4mpUbwHATkSLzJgkqb5sXN0LhL1Hh6xDOMwJMQDPmu44znNsU28+oOE/Q+GUY4d/DOQLyag3o3JrTKzn3L7qAS7Q+FscBhoaTAJiWYjy/uWctS8aDxq9KLpRJSAy3p+2MCR7M1NNh1camAgi5/JhJlT2QCHoVrvysh1t4K/dAUN1QLczmqQKhVDAxxnb8YaTb+5J8zjik2mDEw1eyvcEMWnKyoSMcDIg38lQqHCg5me5C+wHDXCUKwqEBn79LrQmV3TrcLmUUBaPNIIudfAX/+SLIg6P8jTjSJypgrmvOs/GImxYBPoLaSlDr1bIYK84a58E7P21+bLo+zQ0VyxwPRoLFAtvP6Ly85mP86iGNVPOurmn3z1oTuAkw6CouYaUSEVqEKRMnUSm1pUmg1SuiRqe6IIKrXNvReSfv02OwwB7wzHfu6KW3bMXPz2f7PPMglFNlEDPbMkz0A+i3SrzcGdaC2vr4O5I3y8Fbb3VqgocobOrpC5W+/Q465w2+dLv5EG/8W5AXGbSmWDdFx2xXLMTM7xWfBR8SPB+L5jQrrnq65N8iayUy0ECmuMDCZCSpKTxU/WfFbXIJDmUlWYAacFE8yDGEroS5cEE09kpR/K8FQtD7HcDaJAT7jaJyAoHJJ1Uh0CoCsi/ybM5Uvs9xBsN9UHX2nSylGt+crvbeszIJLbiuo+DXzNAwOJ/d1ve+sfvRuQ=="}');
            response.setStatusCode(500);
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
            Object continuationState= IntegrationEngine.continuationState;
            String dlCallOutResponse='';
            //system.runAs(u){
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
            dlCallOutResponse=(String)IntegrationEngine.processDLCallOutResponse(labels, IntegrationEngine.continuationState);
            Test.stopTest();
            //}    
            String responseExpected ='{"body":null,"ResponseData":{"Untagged":"MARA THE |, ARDEE | PUNE","Street":"MILL ROAD","Status":"Success","State":"","ResponseInfo":{"SolutionSetInstanceId":"a010f185-d448-48a2-bce7-1f33212327ec","ApplicationId":26951964},"Pin":"400254","locality":"KAMAL NAGAR","Landmark":"NEAR PUJARI HOSPITAL","House":"BLOCK NO . X , SECTOR 5 , FLAT C - 19  04","Floor":"1","Fields":{"Decision":"Pass","ApplicationId":"26951964","ApplicationData":{"Services":{"Service":{"Skip":"N","Name":"PublicDataAPI","Id":"","EnableSimulation":"","Consent":"true"}}},"Applicants":{"Applicant":{"Services":{"Service":[{"Status":"Pass","Operations":{"Operation":[{"Status":"Pass","Params":{"Param":[{"Value":"Y","Name":"consent"}]},"Name":"dl","Id":"","Errors":null,"Data":{"Response":{"RawResponse":"{\\"result\\":{\\"dl\\":{\\"result\\":{},\\"request_id\\":\\"f73e6599-c022-4489-886a-16837d76046b\\",\\"status-code\\":\\"102\\"},\\"request_id\\":\\"35d4d0d0-e862-441d-ae28-97c4a75c8604\\",\\"status-code\\":\\"101\\"}}"}}}]},"Name":"PublicDataAPI","Id":""}]},"Identifiers":{"Identifier":{"IdType":"04","IdNumber":"TN2020090003150"}},"DateOfBirth":"08021990","ApplicantIdentifier":"e72119d9-4e2c-427a-8276-c1d98048a728"}}},"District":"","Complex":"","CO":"","City":"","Building":"SUNIL APARTMENT"},"RequestId":"20012022145902503"}';        
            System.assertEquals(responseExpected,dlCallOutResponse,'Success');
            
        } catch(Exception ex){
            //System.assertEquals(ex.getMessage(),'No Response Found.');
        }
    }
}