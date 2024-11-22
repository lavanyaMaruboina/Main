/*------------------------------------------------------------
Author:        Bharath Moka
Company:       Persistent Systems
Description:   Test class for IND_UidaiOTPService_Test class 
Apex Class:    IND_UidaiOTPService_Test
History
Date            Author              Comments
-------------------------------------------------------------
12-31-2021      Bharath Moka      Created
01-07-2022      Bhushan Charde    Modified
------------------------------------------------------------*/
@isTest
public class IND_UidaiOTPService_Test {
    
    // @Method:		TestServiceMetthod
    // @Created by:	Bharath Moka
    // @Description:Test setup method to create the test data for IND_UidaiOTPServiceRequest classs
    // @Param:		''	
    // @Return: 	''
    @isTest
    public static void testUidaiOTPService(){
        try{
            
            Profile p = [SELECT Id FROM Profile WHERE Name='CMU'];
        
    		User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
					EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
					LocaleSidKey='en_US', ProfileId = p.Id,
					TimeZoneSidKey='America/Los_Angeles',
					UserName='standarduser4@testorg.com.psdev1',User_Id__c = '29927_MO',
                              MobilePhone='9533089614',Maker_Id__c = '100'
                             );
            insert u;
            system.runAs(u){
            
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            
            Applicant__c applicant = TestDataUtility.createTestApplicantForSMS(false);
            applicant.Opportunity__c=opp.Id;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert applicant;
            }
            
             Documents__c document = TestDataUtility.createTestAadhaarDocs(false,applicant,opp);
            if (Schema.sObjectType.Documents__c.isCreateable()){
                insert document;
            }
            
            String str = '{"applicantId":"'+applicant.Id+'"  ,"loanApplicationId":"00671000001Dz1tAAC", "leadId":"L10012200039", "aadhaarNo":"12938221212"}'; 
            Continuation con = (Continuation)IntegrationEngine.doUidaiOTPCallout(str);
            
            // Create a mock response
            HttpResponse response = new HttpResponse();
            response.setBody('{"JData":"bmvHXB5/b59ltoDPA8dwPKjM9zW1GwK5fvqA5/8G5ngkBW8NcV1dKVggrF/7A7jHQbSjrNuEsJyw+YVULV1THH+oTAZnQzuDAIJkciJctdEK8eYZCCGx/8UGpiYlclA1ZQnGM65d6eQ83ROwTvuRtv+lSg3Q6F32ptiFqjzO+EBtITsncHtarNCxlV6/6BTK+8vLYFK1aon+946cH6ABb2VoJ8/vXNxqFKHajTyhMJvGThopwT50oDAPDI1cQCCNEWNbg4gNGJhnFE3yd1JdnEdFHzMfPf/pN6MKTfCiqWYnXpuwn0eOxVFRavN5bMhSFCJ5DpSm7oEEMssPcO4ThE7kQUtV5mTjVWssqPaRGPjhDDlPvWCbA8NIMY1sju2d8khNuXp0hXWzw0mkzy23kBxFuGKlf+dmB3IC1KPUWU0x/HpyFeeJUd1gsTNe5y+MhHo5j6g+daiAMg1ntha5R9W4USIYUuCbqt06XCmn92hUcQePkkrXtWrHl27EMyB9+aDAe1/IEarTHGMzGDffCmvM1xhk/KMB5+4pCX6AIe+G98hwOBbfCBpI82EZBuWRyJAxc7HFFrs/bS7R8ZoCUHvwsG0ySDmCY+HYYGNMEcalGrSqi1jsNBasqKhK0KD2d4EN7gmLpiLusVYGo3s6vwNoAu6hsIN6YKxChnnIIM0INN+HaycPktX6zUOh1/NfdvCiqEyVMeqHWWg2KT9BSNw/R18qYRwM70UmEoo6ppp/P5DxKnuE/asbOtaV72zCWzHxxtsCDuqZ1zQ2ciqpNg=="}');
            response.setStatusCode(200);
            
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
            Object continuationState= IntegrationEngine.continuationState;   
            String uidaiOTPResponse;
           // system.runAs(u){
                Test.startTest();
                Test.setContinuationResponse(continuationLabel, response);
                uidaiOTPResponse = (String)IntegrationEngine.processUidaiOtpResponse(labels, IntegrationEngine.continuationState);          
                Test.stopTest();
           // }
            String responseExpected ='"{\\"kycResponse\\": {\\"TransactionInfo\\": {\\"Pan\\": \\"6071890510925076003\\", \\"Proc_Code\\": \\"140000\\", \\"Transm_Date_time\\": \\"1229133218\\", \\"Stan\\": \\"247733\\", \\"Local_Trans_Time\\": \\"190218\\", \\"Local_date\\": \\"1229\\", \\"AcqId\\": \\"200031\\", \\"RRN\\": \\"136319247733\\", \\"ResponseCode\\": \\"00\\", \\"ResponseMsg\\": \\"Approved\\", \\"CA_Tid\\": \\"register\\", \\"CA_ID\\": \\"IBLA76232I02361\\", \\"CA_TA\\": \\"IBL HOUSE ANDHERI      MUMBAI       MHIN\\"}, \\"UidData\\": {\\"txn\\": \\"247733\\"}}}"';
            System.assertEquals(responseExpected, uidaiOTPResponse, 'Success');
        }
        } catch(Exception ex){
            System.assertEquals(ex.getMessage(),'Maker Id Error', 'Exception');
        }
    }
    
    @isTest
    public static void testUidaiOTPService2(){
        try{
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            
            Applicant__c applicant = TestDataUtility.createTestApplicantForSMS(false);
            applicant.Opportunity__c=opp.Id;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert applicant;
            }
            
             Documents__c document = TestDataUtility.createTestAadhaarDocs(false,applicant,opp);
            if (Schema.sObjectType.Documents__c.isCreateable()){
                insert document;
            }
            
           String str = '{"applicantId":"'+applicant.Id+'"  ,"loanApplicationId":"00671000001Dz1tAAC", "leadId":"L10012200039", "aadhaarNo":""}';
            Continuation con = (Continuation)IntegrationEngine.doUidaiOTPCallout(str);
            
            // Create a mock response
            HttpResponse response = new HttpResponse();
            response.setBody('{"JData":"bmvHXB5/b59ltoDPA8dwPKjM9zW1GwK5fvqA5/8G5ngkBW8NcV1dKVggrF/7A7jHQbSjrNuEsJyw+YVULV1THH+oTAZnQzuDAIJkciJctdEK8eYZCCGx/8UGpiYlclA1ZQnGM65d6eQ83ROwTvuRtv+lSg3Q6F32ptiFqjzO+EBtITsncHtarNCxlV6/6BTK+8vLYFK1aon+946cH6ABb2VoJ8/vXNxqFKHajTyhMJvGThopwT50oDAPDI1cQCCNEWNbg4gNGJhnFE3yd1JdnEdFHzMfPf/pN6MKTfCiqWYnXpuwn0eOxVFRavN5bMhSFCJ5DpSm7oEEMssPcO4ThE7kQUtV5mTjVWssqPaRGPjhDDlPvWCbA8NIMY1sju2d8khNuXp0hXWzw0mkzy23kBxFuGKlf+dmB3IC1KPUWU0x/HpyFeeJUd1gsTNe5y+MhHo5j6g+daiAMg1ntha5R9W4USIYUuCbqt06XCmn92hUcQePkkrXtWrHl27EMyB9+aDAe1/IEarTHGMzGDffCmvM1xhk/KMB5+4pCX6AIe+G98hwOBbfCBpI82EZBuWRyJAxc7HFFrs/bS7R8ZoCUHvwsG0ySDmCY+HYYGNMEcalGrSqi1jsNBasqKhK0KD2d4EN7gmLpiLusVYGo3s6vwNoAu6hsIN6YKxChnnIIM0INN+HaycPktX6zUOh1/NfdvCiqEyVMeqHWWg2KT9BSNw/R18qYRwM70UmEoo6ppp/P5DxKnuE/asbOtaV72zCWzHxxtsCDuqZ1zQ2ciqpNg=="}');
            response.setStatusCode(200);
            
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
            Object continuationState= IntegrationEngine.continuationState;   
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
            String uidaiOTPResponse = (String)IntegrationEngine.processUidaiOtpResponse(labels, IntegrationEngine.continuationState);          
            Test.stopTest();
            String responseExpected ='"{\\"kycResponse\\": {\\"TransactionInfo\\": {\\"Pan\\": \\"6071890510925076003\\", \\"Proc_Code\\": \\"140000\\", \\"Transm_Date_time\\": \\"1229133218\\", \\"Stan\\": \\"247733\\", \\"Local_Trans_Time\\": \\"190218\\", \\"Local_date\\": \\"1229\\", \\"AcqId\\": \\"200031\\", \\"RRN\\": \\"136319247733\\", \\"ResponseCode\\": \\"00\\", \\"ResponseMsg\\": \\"Approved\\", \\"CA_Tid\\": \\"register\\", \\"CA_ID\\": \\"IBLA76232I02361\\", \\"CA_TA\\": \\"IBL HOUSE ANDHERI      MUMBAI       MHIN\\"}, \\"UidData\\": {\\"txn\\": \\"247733\\"}}}"';
            System.assertEquals(responseExpected, uidaiOTPResponse, 'Success');
        } catch(Exception ex){
           // System.assertEquals(ex.getMessage(),'Maker Id Error', 'Exception');
        }
    } 
     
     @isTest
    public static void testUidaiOTPService3(){
        try{
            String str = null; 
            Continuation con = (Continuation)IntegrationEngine.doUidaiOTPCallout(str);   
        } catch(Exception ex){
           System.assertEquals(ex.getMessage(),System.Label.Retry, 'Exception');
        }
    }  
    
     // @Method:		TestServiceMetthod
    // @Created by:	Bharath Moka
    // @Description:Test setup method to create the test data for IND_UidaiOTPServiceRequest classs
    // @Param:		''	
    // @Return: 	''
    @isTest
    public static void testUidaiOTPService4(){
        try{
            
            Profile p = [SELECT Id FROM Profile WHERE Name='CMU'];
        
    		User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
					EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
					LocaleSidKey='en_US', ProfileId = p.Id,
					TimeZoneSidKey='America/Los_Angeles',
					UserName='standarduser4@testorg.com.psdev1',User_Id__c = '29927_MO',
                              MobilePhone='9533089614',Maker_Id__c = '100'
                             );
            insert u;
            
            system.runAs(u){
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            
            Applicant__c applicant = TestDataUtility.createTestApplicantForSMS(false);
            applicant.Opportunity__c=opp.Id;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert applicant;
            }
            
             Documents__c document = TestDataUtility.createTestAadhaarDocs(false,applicant,opp);
            if (Schema.sObjectType.Documents__c.isCreateable()){
                insert document;
            }
            
            String str = '{"applicantId":"'+applicant.Id+'"  ,"loanApplicationId":"00671000001Dz1tAAC", "leadId":"L10012200039", "aadhaarNo":"12938221212"}'; 
            Continuation con = (Continuation)IntegrationEngine.doUidaiOTPCallout(str);
            
            // Create a mock response
            HttpResponse response = new HttpResponse();
            response.setBody('{"JData":"bmvHXB5/b59ltoDPA8dwPKjM9zW1GwK5fvqA5/8G5ngkBW8NcV1dKVggrF/7A7jHQbSjrNuEsJyw+YVULV1THH+oTAZnQzuDAIJkciJctdEK8eYZCCGx/8UGpiYlclA1ZQnGM65d6eQ83ROwTvuRtv+lSg3Q6F32ptiFqjzO+EBtITsncHtarNCxlV6/6BTK+8vLYFK1aon+946cH6ABb2VoJ8/vXNxqFKHajTyhMJvGThopwT50oDAPDI1cQCCNEWNbg4gNGJhnFE3yd1JdnEdFHzMfPf/pN6MKTfCiqWYnXpuwn0eOxVFRavN5bMhSFCJ5DpSm7oEEMssPcO4ThE7kQUtV5mTjVWssqPaRGPjhDDlPvWCbA8NIMY1sju2d8khNuXp0hXWzw0mkzy23kBxFuGKlf+dmB3IC1KPUWU0x/HpyFeeJUd1gsTNe5y+MhHo5j6g+daiAMg1ntha5R9W4USIYUuCbqt06XCmn92hUcQePkkrXtWrHl27EMyB9+aDAe1/IEarTHGMzGDffCmvM1xhk/KMB5+4pCX6AIe+G98hwOBbfCBpI82EZBuWRyJAxc7HFFrs/bS7R8ZoCUHvwsG0ySDmCY+HYYGNMEcalGrSqi1jsNBasqKhK0KD2d4EN7gmLpiLusVYGo3s6vwNoAu6hsIN6YKxChnnIIM0INN+HaycPktX6zUOh1/NfdvCiqEyVMeqHWWg2KT9BSNw/R18qYRwM70UmEoo6ppp/P5DxKnuE/asbOtaV72zCWzHxxtsCDuqZ1zQ2ciqpNg=="}');
            response.setStatusCode(500);
            
            String continuationLabel = IntegrationEngine.continuationLabel;
            List<String> labels = new List<String>{continuationLabel};
            Object continuationState= IntegrationEngine.continuationState;   
            String uidaiOTPResponse;
           // system.runAs(u){
                Test.startTest();
                Test.setContinuationResponse(continuationLabel, response);
                uidaiOTPResponse = (String)IntegrationEngine.processUidaiOtpResponse(labels, IntegrationEngine.continuationState);          
                Test.stopTest();
            //}
            String responseExpected ='"{\\"kycResponse\\": {\\"TransactionInfo\\": {\\"Pan\\": \\"6071890510925076003\\", \\"Proc_Code\\": \\"140000\\", \\"Transm_Date_time\\": \\"1229133218\\", \\"Stan\\": \\"247733\\", \\"Local_Trans_Time\\": \\"190218\\", \\"Local_date\\": \\"1229\\", \\"AcqId\\": \\"200031\\", \\"RRN\\": \\"136319247733\\", \\"ResponseCode\\": \\"00\\", \\"ResponseMsg\\": \\"Approved\\", \\"CA_Tid\\": \\"register\\", \\"CA_ID\\": \\"IBLA76232I02361\\", \\"CA_TA\\": \\"IBL HOUSE ANDHERI      MUMBAI       MHIN\\"}, \\"UidData\\": {\\"txn\\": \\"247733\\"}}}"';
            System.assertEquals(responseExpected, uidaiOTPResponse, 'Success');
            }
            } catch(Exception ex){
            System.assertEquals(ex.getMessage(),'No Response Found.', 'Exception');
        }
    }
    
    
}