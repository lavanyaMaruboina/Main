/*------------------------------------------------------------
Author:        Bondiga Thilak
Company:       Persistent Systems
Description:   Test class for IND_StampingDetailsRequest class 
Apex Class:    IND_StampingDetailsRequest
History
Date            Author              Comments
-------------------------------------------------------------
12-22-2021      Bondiga Thilak       Created
------------------------------------------------------------*/
@isTest
public class IND_StampingDetailsService_Test {
    // @Method:     createTestData
    // @Created by: Bondiga Thilak
    // @Description:Test setup method to create the test data for IND_StampingDetailsRequest classs
    // @Param:      ''  
    // @Return:     '' 
    @TestSetup
    public static void createTestData(){
        Profile p = [SELECT Id FROM Profile WHERE Name='IBL Business Executive'];
        
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles',
                          MobilePhone = '9701498575', IsActive = true,
                          UserName='standarduser4@testorg.com.psdev1',Maker_Id__c='10002');
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
            Final_Term__c ft2 = new Final_Term__c();
            ft2.CRM_IRR__c = 120;
            ft2.Loan_Application__c = opp.Id;
            ft2.Holiday_period__c='30';
            ft2.EMI_Amount__c= 10000;
            ft2.FIwaiver_offAddress__c = 'Not Waived';
            ft2.Loan_Amount__c = '1500000345';
            ft2.Tenure__c='56';
            insert ft2;
        }
    }
    
    @isTest
    public static void getStampingDetailsRequestTest1(){
        try{            
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE UserName='standarduser4@testorg.com.psdev1' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {
                Opportunity oppRec = [SELECT Id, Product_Type__c, Deal_Number__c, Finance_Amount__c FROM Opportunity LIMIT 1]; 
                Applicant__c appRec = [SELECT Id, Opportunity__c FROM Applicant__c WHERE Opportunity__c =: oppRec.Id LIMIT 1]; 
                IND_StampingDetailsRequest stampingDetailsRequest = IND_StampingDetailsService.getStampingDetailsRequest(appRec, oppRec, '123','456');
                System.assertNotEquals(null, stampingDetailsRequest);
            }
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void getStampingDetailsRequestTest2(){
        try{            
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE UserName='standarduser4@testorg.com.psdev1' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {
                Opportunity oppRec = [SELECT Id FROM Opportunity LIMIT 1]; 
                Applicant__c appRec = [SELECT Id, Opportunity__c FROM Applicant__c WHERE Opportunity__c =: oppRec.Id LIMIT 1]; 
                IND_StampingDetailsService.getStampingDetailsRequest(appRec, oppRec, '123','456');
            }
            Test.stopTest();
        }catch(Exception e){            
            System.assert(e.getMessage().contains('SObject row was retrieved via SOQL without querying the requested field'));
        }
    }
    
    @isTest
    public static void getStampingDetailsRequestTest3(){
        try{            
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE UserName='standarduser4@testorg.com.psdev1' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {                 
                IND_StampingDetailsService.getStampingDetailsRequest(null, null, '123','456');
            }
            Test.stopTest();
        }catch(Exception e){
            System.assert(e.getMessage().contains('Attempt to de-reference a null object'));            
        }
    }   
}