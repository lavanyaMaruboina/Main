/**
* @author Khushiram.
* @company Persistent Systems
* @description A  Test class for the IND_LWC_CreditAssessmentCntrl class
* Inputs: None
* History:
* 2/09/2021 Khushiram.
*/

@isTest
public class IND_LWC_CreditAssessmentCntrlTest {
       @isTest
    public static void getUserRemarksTest(){
        try{
                Opportunity opgr1 = new Opportunity();
                opgr1.StageName = 'Qualification';
                opgr1.CloseDate = Date.newInstance(2021, 1, 11);
                opgr1.Name = 'testone';
                insert opgr1;
                
                Applicant__c apgr1 = new Applicant__c();
                apgr1.Opportunity__c = opgr1.Id;
                apgr1.Contact_number__c = '9743514830';
                apgr1.Applicant_Type__c = 'Borrower';
                apgr1.In_Active_Applicant__c = false;
                insert apgr1;
            
                Test.startTest();
                     IND_LWC_CreditAssessmentCntrl.getUserRemarks(apgr1.Applicant_Type__c,opgr1.Id);
                     IND_LWC_CreditAssessmentCntrl.getUserRemarks(apgr1.Applicant_Type__c,null);
                Test.stopTest();
            
         }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void getUserRemarksTest1(){
        try{
                Opportunity opgr1 = new Opportunity();
                opgr1.StageName = 'Qualification';
                opgr1.CloseDate = Date.newInstance(2021, 1, 11);
                opgr1.Name = 'testone';
                insert opgr1;
                
                Applicant__c apgr1 = new Applicant__c();
                apgr1.Opportunity__c = opgr1.Id;
                apgr1.Contact_number__c = '9743514830';
                apgr1.Applicant_Type__c = 'Borrower';
                apgr1.In_Active_Applicant__c = false;
                insert apgr1;
            
                Test.startTest();
                     IND_LWC_CreditAssessmentCntrl.getUserRemarks(apgr1.Id,opgr1.Id);
                Test.stopTest();
            
         }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void saveUserRemarksTest(){
        try{
                Opportunity opgr2 = new Opportunity();
                opgr2.StageName = 'Qualification';
                opgr2.CloseDate = Date.newInstance(2021, 1, 11);
                opgr2.Name = 'testone';
                insert opgr2;
                
                Applicant__c apgr2 = new Applicant__c();
                apgr2.Opportunity__c = opgr2.Id;
                apgr2.Contact_number__c = '9743514830';
                apgr2.Applicant_Type__c = 'Borrower';
                apgr2.In_Active_Applicant__c = false;
                apgr2.Remarks__c = 'test';
                insert apgr2;
               
                Test.startTest();
                     IND_LWC_CreditAssessmentCntrl.saveUserRemarks(apgr2.Applicant_Type__c,opgr2.Id,apgr2.Remarks__c);
                Test.stopTest();
            
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
     @isTest
    public static void saveUserRemarksTest1(){
        try{
                Opportunity opgr2 = new Opportunity();
                opgr2.StageName = 'Qualification';
                opgr2.CloseDate = Date.newInstance(2021, 1, 11);
                opgr2.Name = 'testone';
                insert opgr2;
                
                Applicant__c apgr2 = new Applicant__c();
                apgr2.Opportunity__c = opgr2.Id;
                apgr2.Contact_number__c = '9743514830';
                apgr2.Applicant_Type__c = 'Borrower';
                apgr2.In_Active_Applicant__c = false;
                apgr2.Remarks__c = 'test';
                insert apgr2;
               
                Test.startTest();
                     IND_LWC_CreditAssessmentCntrl.saveUserRemarks(apgr2.Id,opgr2.Id,apgr2.Remarks__c);
                Test.stopTest();
            
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
}