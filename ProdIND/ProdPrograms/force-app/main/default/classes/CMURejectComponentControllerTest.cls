@isTest
public class CMURejectComponentControllerTest {
    
    @TestSetup
    static void testData(){
        Opportunity opp = TestDataUtility.createTestOpportunity(false);
        opp.Name = 'VDR Test';
        opp.Product_Type__c = 'Tractor';
        insert opp;
        
        Documents__c testDoc = TestDataUtility.createTestDocument(false);
        testDoc.CMU_Accept_Reject__c = 'Reject';
        testDoc.CMU_Rejection_Reason__c='Test';
        testDoc.Opportunity_Relation__c = opp.Id;
        insert testDoc;
    }
    
    @isTest
    static void testGetDocumentsList() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        Test.startTest();
        List<Documents__c> resultDocsList = CMURejectComponentController.getDocumentsList(opp.Id);
        Test.stopTest();       
        System.assertEquals(1, resultDocsList.size());
    }
    
    @isTest
    static void testGetDocumentDetails() {
        Documents__c testDoc = [SELECT Id FROM Documents__c LIMIT 1];
        Test.startTest();
        List<Documents__c> resultDocsList = CMURejectComponentController.getDocumentDetails(testDoc.Id);
        Test.stopTest();
        System.assertEquals(1, resultDocsList.size());
    }
}