@isTest
private with sharing class PurgeUnusedRecordsBatchTest {
    
    @testSetup 
    static void testDataSetup(){
        //create Oppty records
            List<Opportunity> opptyList = new List<Opportunity>();
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            opp.Name = 'VDR Test';
            opp.StageName='Post Sanction Checks and Documentation';
            opp.Product_Type__c='Passenger Vehicles';
            opp.CVO_Accepts_SPDC_Documents__c = 'No';
            opptyList.add(opp);
            Opportunity opp2 = TestDataUtility.createTestOpportunity1(false);
            opp2.Name = 'VDR Negative Test';
            opp2.CloseDate = Date.today();
            opptyList.add(opp2);
            Opportunity opp3 = TestDataUtility.createTestOpportunity1(false);
            opp3.Name = 'Oppty 3';
            opp3.CloseDate = Date.today();
            opptyList.add(opp3);
            if(Schema.sObjectType.Opportunity.isCreateable()){
                insert opptyList;
            }
            
            //create Vehicle_Detail__c record
            List<Vehicle_Detail__c> vdList = new List<Vehicle_Detail__c>();
            Vehicle_Detail__c  vehicleDetail = TestDataUtility.createTestVehicleDetailForIbb(false, opp);
            vehicleDetail.Is_RC_Limit_Check_correctly_captured__c='No';
            vdList.add(vehicleDetail);
            if (Schema.sObjectType.Vehicle_Detail__c.isCreateable()){
                insert vdList;
            }
        //Create Applicant__c Data
        List<Applicant__c> applicantList = new List<Applicant__c>();
        Applicant__c applicant1 = TestDataUtility.createTestApplicatnt1(false);
        applicant1.Opportunity__c = opp.Id;
        applicant1.Who_will_repay_the_loan__c = 'Borrower';
        applicant1.Scorecard_Decision__c = 'Light Red';
        applicantList.add(applicant1);
        Applicant__c applicant2 = TestDataUtility.createTestApplicatnt2(false);
        applicant2.Opportunity__c = opp.Id;
        applicantList.add(applicant2);
        if(Schema.sObjectType.Applicant__c.isCreateable()){
            insert applicantList;
        }
        Documents__c doc1 = TestDataUtility.createTestDocumentITR(false, applicant1, opp);
        doc1.Vehicle_Detail__c = vehicleDetail.Id;
        doc1.Opportunity_Relation__c = opp.Id;
        doc1.Is_Document_Eligible__c='No';
        doc1.Is_active__c = true;
        doc1.Document_Type__c = 'Chassis Number uploaded during verification';
        doc1.Additional_Document__c = true;
        insert doc1;
        ContentVersion contentVersion = new ContentVersion(
            Title          = 'testfname',
            PathOnClient   = 'Pic.jpg',
            VersionData    = Blob.valueOf('Test Content'),
            IsMajorVersion = true);
        insert contentVersion; 
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.LinkedEntityId = doc1.Id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.ShareType = 'V';
        cdl.Visibility = 'AllUsers';
        insert cdl;
    }
    
    @isTest
    private static void PurgeUnusedRecordsBatchTestPositive() {
        try{
            Test.startTest();
            PurgeUnusedRecordsBatch obj = new PurgeUnusedRecordsBatch('SELECT Id FROM Documents__c LIMIT 1');
            DataBase.executeBatch(obj);
            Test.stopTest();
        }
        catch(Exception e){
            System.debug('error '+e.getMessage());
        }
    }
}