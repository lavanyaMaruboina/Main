@isTest
public class SignatureHelperTest {

    @isTest
    private static void testSaveSign() {
        Opportunity opp = TestDataUtility.createTestOpportunity(true);
        Applicant__c applicant = TestDataUtility.createTestApplicant(false);
        applicant.Opportunity__c = opp.Id;
        insert applicant;
        Documents__c doc = TestDataUtility.createTestKYCDocsForOcrFront(true, applicant, opp);
        Test.startTest();
        String str = SignatureHelper.saveSign('Test', doc.Id);
        Test.stopTest();
        System.assertNotEquals(null, str);
    }
    
    @isTest
    private static void testSaveSignException() {
        try {
            Test.startTest();
            String str = SignatureHelper.saveSign(null, 'Test');
            Test.stopTest();
        } catch(Exception e) {
            System.assertNotEquals(null, e.getMessage());
        }
    }
}