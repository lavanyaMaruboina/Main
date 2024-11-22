@isTest
public class assetVerificationTriggerHandlerTest {
    @isTest
    public static void updateCaseStatusTest(){
        
        Opportunity opp=TestDataUtility.createTestOpportunity1(false);
        opp.Sanction_Date__c=System.Today();
        Insert opp;
        
         Applicant__c applicant1 = TestDataUtility.createTestApplicatnt1(false);
            applicant1.Opportunity__c = opp.Id;
            
       Case cse=TestDataUtility.createTestCase(false,opp,applicant1);
        Insert cse;
        
        Opportunity opp1=TestDataUtility.createTestOpportunity1(false);
        opp1.Sanction_Date__c=System.Today();
        Insert opp1;
        
         Applicant__c applicant2 = TestDataUtility.createTestApplicatnt1(false);
            applicant2.Opportunity__c = opp1.Id;
            
       Case cse1=TestDataUtility.createTestCase(false,opp1,applicant2);
        Insert cse1;
        
        Asset_Verification__c  avRec = new Asset_Verification__c ();
        avRec.Name = 'testName';
        avRec.Status__c = 'Inprogress';
        avRec.Case__c = cse.Id;
        insert avRec;
        
        List<Id> avRecList=New List<Id>();
        List<Id> caseIdList=New List<Id>();
        caseIdList.add(cse1.Id);
        avRecList.add(avRec.Case__c);
        //if
        Test.startTest();
        assetVerificationTriggerHandler.updateCaseStatus(avRecList);
        assetVerificationTriggerHandler.updateCaseStatus(caseIdList);
        
        avRec.Status__c = 'Completed';
        update avRec;
        
        delete avRec;
        Test.stopTest();
        
      
    }
    @isTest
    public static void updateIsPSVerifiedAssetTest(){
        List<Asset_Verification__c> avList=new List<Asset_Verification__c>();
        Opportunity opp=TestDataUtility.createTestOpportunity1(false);
        opp.Sanction_Date__c=System.Today();
        Insert opp;
        
         Applicant__c applicant1 = TestDataUtility.createTestApplicatnt1(false);
            applicant1.Opportunity__c = opp.Id;
            
       Case cse1=TestDataUtility.createTestCase(false,opp,applicant1);
        Insert cse1;
         Set<Id> caseIds=New Set<Id>();
          
        
        Asset_Verification__c  avRec = new Asset_Verification__c ();
        avRec.Name = 'testName';
        avRec.Is_Post_Sanction_Verified_Asset__c=True;
        avRec.Status__c = 'Completed';
        avRec.Case__c = cse1.Id;
        insert avRec;   
       
        caseIds.add(avRec.Case__c);
        avList.add(avRec);
        Test.startTest();
        assetVerificationTriggerHandler.updateIsPSVerifiedAsset(avList,caseIds);
        Test.stopTest();
    }
}