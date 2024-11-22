/**
* @Name         IND_OfficeFIPDFController_Test
* @Author       mohammad_shahkomeni
* @Company      Persistent Systems
* @Description  This test class used to test IND_OfficeFIPDFController
* Inputs:       None
* Test Class:   None
* History:      
* Date            Author              Comments
* -------------------------------------------------------------
* 02-20-2022      mohammad_shahkomeni      Created
* ------------------------------------------------------------
*/
@isTest(seeAllData = false)
public class IND_OfficeFIPDFController_Test {
    
    @testSetup static void testDataSetup() {
        // Create Opportunity
        Opportunity opp = TestDataUtility.createTestOpportunityForOcr(false);
        opp.StageName = System.Label.Credit_Processing;
        opp.Sub_Stage__c = System.Label.Field_Investigation;
        opp.Is_Mobile_Journey_Completed__c = true;
        opp.Vehicle_Type__c = System.Label.used;
        opp.Product_Type__c = System.Label.TwoWheeler;
        opp.Sanction_Status__c = System.Label.nonStp;
        insert opp;
        // Create Applicant__c
        Applicant__c applicant = TestDataUtility.createTestApplicantForMFCValuation(true, opp);
        // Create Vehicle Detail
        Vehicle_Detail__c vehDet = TestDataUtility.createTestVehicleDetailForMFCValuation(true, opp);
        // Create Documents__c
        Documents__c doc1 = TestDataUtility.createTestKYCDocsForOcrFront(false, applicant, opp);
        doc1.Document_Type__c = System.Label.Signature;
        doc1.Addresss_Type__c = System.Label.Document_Office_Address_Type;
        insert doc1;
        Documents__c doc2 = TestDataUtility.createTestKYCDocsForOcrFront(false, applicant, opp);
        doc2.Document_Type__c = System.Label.Residence_Front_View;
        doc2.Addresss_Type__c = System.Label.Document_Office_Address_Type;
        insert doc2;
        // Create ContentVersion
        ContentVersion contVer1 = TestDataUtility.createContentVersionforOcrFront('Test document for content version',true, doc1);
        ContentVersion contVer2 = TestDataUtility.createContentVersionforOcrFront('Test document for content version',true, doc2);
        // Create Case
        Case cse = TestDataUtility.createTestCase(false, opp, applicant);
        cse.Type = System.Label.Case_Office_FI_Type;
        insert cse;
        // Create Field Investigation
        Field_Investigation__c fiRecord = TestDataUtility.createTestFieldInvestigation(true, cse);
    }
    
    @isTest 
    public static void testOfficeFIPDFController(){
       
        Field_Investigation__c fiRecord = [SELECT Id FROM Field_Investigation__c LIMIT 1];
        Case cse = [SELECT Id, Status FROM Case LIMIT 1];
        cse.Status = System.Label.FI_Accepted;
        update cse;
        
        PageReference pageRef = Page.IND_OfficeFIRenderAsPDF;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('fiId',fiRecord.id);
        
        Test.startTest();
        IND_OfficeFIPDFController contrl = new IND_OfficeFIPDFController();
        Test.stopTest();
        
        System.assertNotEquals(null, contrl.inputWrapper);
    }
    
    @isTest
    public static void getDocumentsOfFITest(){
            Opportunity optg1 = new Opportunity();
                optg1.StageName = 'Qualification';
                optg1.CloseDate = Date.newInstance(2021, 1, 11);
                optg1.Name = 'testone';
                insert optg1;
                
                Applicant__c apt1 = new Applicant__c();
                apt1.Opportunity__c = optg1.Id;
                apt1.Contact_number__c = '9743514830';
                apt1.Applicant_Type__c = 'Borrower';
                insert apt1;
                
                 Documents__c dtg1 = new Documents__c();
                 dtg1.Applicant__c = apt1.Id;
                 dtg1.Opportunity_Relation__c = optg1.Id;
                 dtg1.Document_Type__c = System.Label.Signature;
                 dtg1.Document_Side__c ='Back';
                 dtg1.Aadhar_Source__c = 'ScanAadhar';
                 dtg1.Addresss_Type__c = System.Label.Document_Office_Address_Type;
                 insert dtg1;
        
                 ContentVersion cvn1 = new ContentVersion();
                 cvn1.PathOnClient = 'testpath1';
                 cvn1.Title = 'testtitle1';
                 cvn1.VersionData = Blob.valueOf('Test Content');
                 cvn1.Document_Side_fileupload__c = 'Front';
                 insert cvn1;
                
                 ContentVersion testcd1 = [SELECT id, ContentDocumentId FROM ContentVersion where Id = :cvn1.Id];
                
                 ContentDocumentLink cdlink1 = new ContentDocumentLink();
                 cdlink1.Visibility = 'AllUsers';
                 cdlink1.ShareType = 'V';
                 cdlink1.LinkedEntityId = dtg1.Id;
                 cdlink1.ContentDocumentId = testcd1.ContentDocumentId;
                 insert cdlink1;
        
                  IND_OfficeFIInputWrapper.StringField ifw1 = new IND_OfficeFIInputWrapper.StringField();
                  ifw1.label = 'test';
                  ifw1.value = System.Label.buildingfrontview;
        
                  IND_OfficeFIInputWrapper iw1 = new IND_OfficeFIInputWrapper();
                //  iw1.buildingfrontview = ifw1.label;
       
                 Test.startTest();
                        IND_OfficeFIPDFController fdc = new IND_OfficeFIPDFController();
                       // fdc.getDocumentsOfFI(optg1.Id,apt1.Id);
                 Test.stopTest();
    }
    
}