/**
* @Name         IND_ResidenceFIPDFController_Test
* @Author       mohammad_shahkomeni
* @Company      Persistent Systems
* @Description  This test class used to test IND_ResidenceFIPDFController
* Inputs:       None
* Test Class:   None
* History:      
* Date            Author              Comments
* -------------------------------------------------------------
* 02-20-2022      mohammad_shahkomeni      Created
* ------------------------------------------------------------
*/
@isTest(seeAllData = false)
public class IND_ResidenceFIPDFController_Test {
    
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
        doc1.Addresss_Type__c = System.Label.Document_Current_Residential_Address_Type;
        insert doc1;
        Documents__c doc2 = TestDataUtility.createTestKYCDocsForOcrFront(false, applicant, opp);
        doc2.Document_Type__c = System.Label.Residence_Front_View;
        doc2.Addresss_Type__c = System.Label.Document_Current_Residential_Address_Type;
        insert doc2;
        // Create ContentVersion
        ContentVersion contVer1 = TestDataUtility.createContentVersionforOcrFront('Test document for content version',true, doc1);
        ContentVersion contVer2 = TestDataUtility.createContentVersionforOcrFront('Test document for content version',true, doc2);
        // Create Case
        Case cse = TestDataUtility.createTestCase(false, opp, applicant);
        cse.Type = 'Current Residence FI';
        insert cse;
        // Create Field Investigation
        Field_Investigation__c fiRecord = TestDataUtility.createTestFieldInvestigation(true, cse);
    }
    
    @isTest 
    public static void testResidenceFIPDFController(){
        
        Field_Investigation__c fiRecord = [SELECT Id FROM Field_Investigation__c LIMIT 1];
        Case cse = [SELECT Id, Status FROM Case LIMIT 1];
        cse.Status = System.Label.FI_Accepted;
        update cse;
        
        PageReference pageRef = Page.IND_ResidenceFIRenderAsPDF;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('fiId',fiRecord.id);
        
        Test.startTest();
        IND_ResidenceFIPDFController contrl = new IND_ResidenceFIPDFController();
        Test.stopTest();
        
        System.assertNotEquals(null, contrl.inputWrapper);
        

    }
}