/**
* @author Ruchi Jain
* @company Persistent Systems
* @description A  Test class for the DateTimeHandle class
* Inputs: None
* History:
* 27/10/2021 Ruchi Jain
*/
@isTest
public class DateTimeHandleTest {
    
    @testSetup static void setup() {
         Account testAccount = TestDataUtility.createTestAccount(true);
            
            Opportunity oppObj = TestDataUtility.createTestOpportunity(false);
            oppObj.AccountId = testAccount.Id;
            insert oppObj;
         Applicant__c applicantObj = TestDataUtility.createTestApplicant(false);
            applicantObj.Opportunity__c= oppObj.Id;
            applicantObj.Consent_Received__c=true;
        	applicantObj.OTP_for_borrower__c='19333';
            applicantObj.Consent_Sent__c=DateTime.valueOf(DateTime.now().getTime()-4);
            insert applicantObj;
         Applicant__c applicantObj1 = TestDataUtility.createTestApplicant(false);
            applicantObj1.Opportunity__c= oppObj.Id;
            applicantObj1.Consent_Received__c=false;
        	applicantObj1.OTP_for_borrower__c='19393';
            applicantObj1.Register_for_WhatsApp_Banking__c=true;
            applicantObj1.Consent_Sent__c=DateTime.valueOf(DateTime.now().getTime()-27248698);
            insert applicantObj1;
    }
    
    //Test method enableCheckboxTest 
    @isTest
    static  void enableCheckboxTest() {
        try{
            Applicant__c app=[Select Id,OTP_for_borrower__c from Applicant__c limit 1];
            app.Register_for_WhatsApp_Banking__c = true;
            update app;
            PageReference testPage = Page.AcceptConsent; 
            Test.setCurrentPage(testPage);
            testPage.getParameters().put('id', String.valueOf(app.Id));
            testPage.getParameters().put('otp', String.valueOf(app.OTP_for_borrower__c));
            
            ApexPages.StandardController stdSetController = new ApexPages.StandardController(app);
            
            Test.startTest();
            DateTimeHandle ext = new DateTimeHandle(stdSetController); 
            ext.enableCheckbox();
            
            system.assertEquals(true,app.Consent_Received__c);
            Test.stopTest();
        }Catch(Exception e){
            system.assertEquals('Script-thrown exception', e.getMessage());
        }
        
        
    }
    
   @isTest
    static  void dosentenableCheckboxTest() {
        try{
           Applicant__c app=[Select Id,Consent_Sent__c,OTP_for_borrower__c from Applicant__c where Consent_Received__c=false  limit 1];
            system.debug('time'+(app.Consent_Sent__c.getTime())/60000);
            PageReference testPage = Page.AcceptConsent; 
            Test.setCurrentPage(testPage);
            testPage.getParameters().put('id', String.valueOf(app.Id));
            testPage.getParameters().put('otp', String.valueOf(app.OTP_for_borrower__c));

            
            ApexPages.StandardController stdSetController = new ApexPages.StandardController(app);
            
            Test.startTest();
            DateTimeHandle ext = new DateTimeHandle(stdSetController); 
            ext.vfMetadata = [select id,WspNotRegistered__c,WspRegisteredContent__c from VfPageContent__mdt where Label ='BodyContent'];
            ext.enableCheckbox();
            Test.stopTest();
            
            system.assertEquals(false,app.Consent_Received__c);
        }Catch(Exception e){
            system.assertEquals('Script-thrown exception', e.getMessage());
        }
        
    }
}