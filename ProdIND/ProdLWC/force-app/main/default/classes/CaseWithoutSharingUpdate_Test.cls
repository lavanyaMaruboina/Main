/**
* @Name         CaseWithoutSharingUpdate_Test
* @Author       mohammad_shahkomeni
* @Company      Persistent Systems
* @Description  This test class used to test CaseWithoutSharingUpdate
* Inputs:       None
* Test Class:   None
* History:      
* Date            Author              Comments
* -------------------------------------------------------------
* 05-24-2022      mohammad_shahkomeni      Created
* ------------------------------------------------------------
*/
@isTest(seeAllData = false)
public with sharing class CaseWithoutSharingUpdate_Test {
    @isTest 
    public static void testUpdateCase(){
        try{
        Opportunity opp = TestDataUtility.createTestOpportunityForOcr(true);
       
        Applicant__c applicant = TestDataUtility.createTestApplicantForMFCValuation(true, opp);
        
        Case cse = TestDataUtility.createTestCase(true, opp, applicant);
        
        Test.startTest();
        cse.Status = System.Label.FI_Accepted;
        CaseWithoutSharingUpdate.updateCase(cse);
        CaseWithoutSharingUpdate.updateCase(null);
        Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }   
    @isTest
    public static void updateFiTest(){
        try{
                Opportunity opks1 = new Opportunity();
                opks1.StageName = 'Qualification';
                opks1.CloseDate = Date.newInstance(2021, 1, 11);
                opks1.Name = 'testone';
                insert opks1;
                
                Applicant__c apks1 = new Applicant__c();
                apks1.Opportunity__c = opks1.Id;
                apks1.Contact_number__c = '9743514830';
                apks1.Applicant_Type__c = 'Borrower';
                insert apks1;
                
                 case cs1 = new case();
                 cs1.Loan_Application__c = opks1.Id;
                 cs1.Applicant__c = apks1.Id;
                 cs1.Subject='Approval Of Application Sourced By Off Roll Employee';
                 cs1.Status = 'Pending-Off Role Employee App';
                 cs1.Origin = 'Web';
                 insert cs1; 
        
                 Field_Investigation__c fiv1 = new Field_Investigation__c();
                 fiv1.Case__c = cs1.Id;
                 fiv1.Address_Line_1__c = 'lineone';
                 fiv1.Address_Line_2__c = 'linetwo';
                 fiv1.RecordTypeId = Schema.SObjectType.Field_Investigation__c.getRecordTypeInfosByName().get('Permanent').getRecordTypeId();
                 insert fiv1;
        
                 Test.startTest();
                     CaseWithoutSharingUpdate.updateFi(fiv1);
                     CaseWithoutSharingUpdate.updateFi(null);
                 Test.stopTest();
        }catch(Exception e){
                 System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void insertopptyTeamMembersTest(){
        try{
                Opportunity opks1 = new Opportunity();
                opks1.StageName = 'Qualification';
                opks1.CloseDate = Date.newInstance(2021, 1, 11);
                opks1.Name = 'testone';
                insert opks1;
                
                List<OpportunityTeamMember> opTeamList = new List<OpportunityTeamMember>();
                OpportunityTeamMember optm2 = new OpportunityTeamMember();
                optm2.OpportunityId = opks1.Id;
                optm2.UserId = UserInfo.getUserId();
                optm2.TeamMemberRole = 'FI';
                insert optm2;
                opTeamList.add(optm2);
            
                Test.startTest();
                     CaseWithoutSharingUpdate.insertopptyTeamMembers(opTeamList);
                     CaseWithoutSharingUpdate.insertopptyTeamMembers(null);
                Test.stopTest();
                
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void deleteOTMRecordsTest(){
        try{
                Opportunity opks1 = new Opportunity();
                opks1.StageName = 'Qualification';
                opks1.CloseDate = Date.newInstance(2021, 1, 11);
                opks1.Name = 'testone';
                insert opks1;
                
                List<OpportunityTeamMember> opTeamList1 = new List<OpportunityTeamMember>();
                OpportunityTeamMember optm2 = new OpportunityTeamMember();
                optm2.OpportunityId = opks1.Id;
                optm2.UserId = UserInfo.getUserId();
                optm2.TeamMemberRole = 'FI';
                insert optm2;
                opTeamList1.add(optm2);
        
                Test.startTest();
                     CaseWithoutSharingUpdate.deleteOTMRecords(opTeamList1);
                     CaseWithoutSharingUpdate.deleteOTMRecords(null);
                Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    @isTest
    public static void deleteOCRRetryCountsTest(){
        try{
            Opportunity opks1 = new Opportunity();
            opks1.StageName = 'Qualification';
            opks1.CloseDate = Date.newInstance(2021, 1, 11);
            opks1.Name = 'testone';
            insert opks1;
            
            List<Retry_Count__c> retryCountList = new List<Retry_Count__c>();
            Retry_Count__c retryCount = new Retry_Count__c();
            retryCount.Loan_Application_Id__c = opks1.Id;
            retryCount.Service_Name__c = System.Label.CMU_Front;
            retryCount.Count__c = 2;
            retryCountList.add(retryCount);

            Retry_Count__c retryCount1 = new Retry_Count__c();
            retryCount1.Loan_Application_Id__c = opks1.Id;
            retryCount1.Service_Name__c = System.Label.CMU_Back;
            retryCount1.Count__c = 2;
            retryCountList.add(retryCount1);
            insert retryCountList;
            Test.startTest();
                CaseWithoutSharingUpdate.deleteOCRRetryCounts(retryCountList);
                CaseWithoutSharingUpdate.deleteOCRRetryCounts(null);
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    @isTest
        public  static void storedMaskedKYCDocTest(){
            try{
                Opportunity opks1 = new Opportunity();
                opks1.StageName = 'Qualification';
                opks1.CloseDate = Date.newInstance(2021, 1, 11);
                opks1.Name = 'testone';
                insert opks1;
                
                Applicant__c apks1 = new Applicant__c();
                apks1.Opportunity__c = opks1.Id;
                apks1.Contact_number__c = '9743514830';
                apks1.Applicant_Type__c = 'Borrower';
                insert apks1;
                
                 Documents__c dfks1 = new Documents__c();
                 dfks1.Applicant__c = apks1.Id;
                 dfks1.Opportunity_Relation__c = opks1.Id;
                 dfks1.Document_Type__c = System.Label.CustomerImageDocumentType;
                 dfks1.KYC_name__c = 'Aadhar';
                 dfks1.Document_Side__c ='Back';
                 dfks1.Aadhar_Source__c = 'ScanAadhar';
                 dfks1.Name = 'Aadhar';
                 insert dfks1;
                
                Blob beforeblob1 = Blob.valueOf('Unit Test Attachment Body');

                 ContentVersion cvt1 = new ContentVersion();
                 cvt1.ContentLocation = 'S';
                 cvt1.title = 'test content trigger';      
                 cvt1.PathOnClient ='test';           
                 cvt1.VersionData = beforeblob1;
                 cvt1.Document_Side_fileupload__c = 'Selfie';
                 insert cvt1;   
        
                 ContentVersion testContent1 = [SELECT id, ContentDocumentId FROM ContentVersion where Id = :cvt1.Id];

        
                 ContentDocumentLink contentlink1 = new ContentDocumentLink();
                 contentlink1.ShareType = 'V';
                 contentlink1.LinkedEntityId = dfks1.Id; 
                 contentlink1.ContentDocumentId = testContent1.ContentDocumentId;
                 contentlink1.Visibility = 'AllUsers'; 
                 insert contentlink1;
                
                 Test.startTest();
                 CaseWithoutSharingUpdate.storedMaskedKYCDoc('Unit Test Attachment Body',dfks1.Id,cvt1.Document_Side_fileupload__c,testContent1.ContentDocumentId);
                 CaseWithoutSharingUpdate.storedMaskedKYCDoc(null,null,null,null);
                 Test.stopTest();
            }catch(Exception e){
                System.assertEquals('Script-thrown exception', e.getMessage());
            }
        }
        @isTest
        public  static void updateCaseFIListTest(){
            try{
                List<Case> caseList = new List<Case>();
                Opportunity opds1 = new Opportunity();
                opds1.StageName = 'Qualification';
                opds1.CloseDate = Date.newInstance(2021, 1, 11);
                opds1.Name = 'testone';
                opds1.Product_Type__c = 'Passenger Vehicles';
                insert opds1;
                Case caseObj = new Case();
                caseObj.Loan_Application__c = opds1.id;
                caseObj.Type = 'TVR';
                caseObj.RecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByName().get('TVR').getRecordTypeId();
                caseObj.Status = 'New';
                caseObj.Priority = 'Medium';
                caseList.add(caseObj);
                insert caseList;
                Field_Investigation__c fiRecord = new Field_Investigation__c();
                fiRecord.Case__c = caseList[0].Id;
                fiRecord.Office_FI_Completion_Time__c = Date.today()-90;
                fiRecord.Residence_FI_completion_time__c = Date.today()-90;
                List<Field_Investigation__c>fiList = new List<Field_Investigation__c>();
                fiList.add(fiRecord);
                insert fiList;
                 Test.startTest();
                    CaseWithoutSharingUpdate.updateCaseList(caseList);
                    CaseWithoutSharingUpdate.updateCaseList(null);
                    CaseWithoutSharingUpdate.updateFiList(fiList);
                    CaseWithoutSharingUpdate.updateFiList(null);
                 Test.stopTest();
            }catch(Exception e){
                System.assertEquals('Script-thrown exception', e.getMessage());
            }
        }
        @isTest
        public  static void updateCaseFIListTest2(){
            try{
                List<Case> caseList = new List<Case>();
                Opportunity opds1 = new Opportunity();
                opds1.StageName = 'Qualification';
                opds1.CloseDate = Date.newInstance(2021, 1, 11);
                opds1.Name = 'testone';
                opds1.Product_Type__c = 'Passenger Vehicles';
                insert opds1;
                Case caseObj = new Case();
                caseObj.Loan_Application__c = opds1.id;
                caseObj.Type = 'TVR';
                caseObj.RecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByName().get('TVR').getRecordTypeId();
                caseObj.Status = 'New';
                caseObj.Priority = 'Medium';
                caseList.add(caseObj);
                insert caseList;
                Field_Investigation__c fiRecord = new Field_Investigation__c();
                fiRecord.Case__c = caseList[0].Id;
                fiRecord.Office_FI_Completion_Time__c = Date.today()-90;
                fiRecord.Residence_FI_completion_time__c = Date.today()-90;
                List<Field_Investigation__c>fiList = new List<Field_Investigation__c>();
                fiList.add(fiRecord);
                insert fiList;
                 Test.startTest();
                    CaseWithoutSharingUpdate.updateFiList(fiList);
                    CaseWithoutSharingUpdate.updateFiList(null);
                 Test.stopTest();
            }catch(Exception e){
                System.assertEquals('Script-thrown exception', e.getMessage());
            }
        }
        @isTest
        public  static void updateCaseFIListTest3(){
            try{
                List<Case> caseList = new List<Case>();
                Opportunity opds1 = new Opportunity();
                opds1.StageName = 'Qualification';
                opds1.CloseDate = Date.newInstance(2021, 1, 11);
                opds1.Name = 'testone';
                opds1.Product_Type__c = 'Passenger Vehicles';
                insert opds1;
                Case caseObj = new Case();
                caseObj.Loan_Application__c = opds1.id;
                caseObj.RecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByName().get('Asset Verification').getRecordTypeId();
                caseObj.Status = 'New';
                caseObj.Priority = 'Medium';
                caseList.add(caseObj);
                insert caseList;
                Asset_Verification__c asset = new Asset_Verification__c();
                asset.Case__c = caseList[0].Id;
                insert asset;
                 Test.startTest();
                    CaseWithoutSharingUpdate.getAssetVerRecord(opds1.Id,'');
                 Test.stopTest();
            }catch(Exception e){
                System.assertEquals('Script-thrown exception', e.getMessage());
            }
        }
}