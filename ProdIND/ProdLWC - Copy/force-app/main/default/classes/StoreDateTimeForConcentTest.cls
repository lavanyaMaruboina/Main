/**
* @author Ruchi Jain
* @company Persistent Systems
* @description A  Test class for the StoreDateTimeForConcent class
* Inputs: None
* History:
* 27/10/2021 Ruchi Jain
*/
@isTest(SeeAllData=false)
public class StoreDateTimeForConcentTest {

 @testSetup static void setup() {
         Account testAccount = TestDataUtility.createTestAccount(true);
            
            Opportunity oppObj = TestDataUtility.createTestOpportunity(false);
            oppObj.AccountId = testAccount.Id;
            insert oppObj;
         Applicant__c applicantObj = TestDataUtility.createTestApplicant(false);
            applicantObj.Opportunity__c= oppObj.Id;
            applicantObj.Consent_Received__c=true;
            insert applicantObj;
    }
    
    @isTest static void  testUpdateOnOpportunity(){
        try{
        Applicant__c app=[Select Id ,Consent_Received__c from Applicant__c limit 1];
        System.debug('Sucessfully Changed' +  app.Consent_Received__c);
        Test.startTest();
        StoreDateTimeForConcent.updateConsentStatus(app.id);
        Test.stopTest();
        System.assertEquals(true, app.Consent_Received__c);
        }Catch(Exception e){
            system.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
       
        
        @isTest static void  testUpdateOnOpportunityFalseResult(){
            try{
            Applicant__c app=[Select Id ,Consent_Received__c from Applicant__c limit 1];
            System.debug('Sucessfully Changed' +  app.Consent_Received__c);
            StoreDateTimeForConcent.updateConsentStatus(app.id);
            System.assertEquals(true, app.Consent_Received__c);
            }Catch(Exception e){
           	system.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
            
    @isTest
    public static void updateConsentStatusTest(){
        try{
                Opportunity opuc1 = new Opportunity();
                opuc1.StageName = 'Qualification';
                opuc1.CloseDate = Date.newInstance(2021, 1, 11);
                opuc1.Name = 'testone';
                insert opuc1;
                
                Applicant__c auc1 = new Applicant__c();
                auc1.Opportunity__c = opuc1.Id;
                auc1.Contact_number__c = '9743514830';
                auc1.Applicant_Type__c = 'Borrower';
                auc1.Consent_Sent__c   =null;
                insert auc1;
        
                Test.startTest();
                      StoreDateTimeForConcent.updateConsentStatus(auc1.Id);
                Test.stopTest();
        }catch(Exception e){
                 System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }    
    
  
}