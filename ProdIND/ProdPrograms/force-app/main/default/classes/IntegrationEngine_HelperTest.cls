@isTest
public class IntegrationEngine_HelperTest {
    @isTest
    public static void testForm60API_Success() {
        // Create test data
        List<Id> ids = insertTestApplicantAndDocument();

        String loanAppId = ids[0];
        String applicantId = ids[1];

        // Mock user data
        User testUser = [SELECT Id FROM User LIMIT 1];
        User testUserWithUserId = new User(Id = testUser.Id, User_Id__c = 'USR_Test_123');
        update testUserWithUserId;

        // Mock HTTP response
        Test.setMock(HttpCalloutMock.class, new Form60APIMockResponse());

        // Test the method
        Test.startTest();
        try {
            IntegrationEngine_Helper.form60API(loanAppId, applicantId);
        } catch (Exception ex) {
        }
        Test.stopTest();
    }

    @isTest
    public static void testForm60API_Error() {
        // Create test data
        List<Id> ids = insertTestApplicantAndDocument();

        String loanAppId = ids[0];
        String applicantId = ids[1];

        // Mock user data
        User testUser = [SELECT Id FROM User LIMIT 1];
        User testUserWithUserId = new User(Id = testUser.Id, User_Id__c = 'USR_Test_123');
        update testUserWithUserId;

        // Mock HTTP response with error
        Test.setMock(HttpCalloutMock.class, new Form60APIMockErrorResponse());

        // Test the method
        Test.startTest();
        try {
            IntegrationEngine_Helper.form60API(loanAppId, applicantId);
        } catch (Exception ex) {
        }
        Test.stopTest();
    }

    @isTest
    public static void testForm60API_Exception() {
        // Create test data
        List<Id> ids = insertTestApplicantAndDocument();

        String loanAppId = ids[0];
        String applicantId = ids[1];

        // Mock user data
        User testUser = [SELECT Id FROM User LIMIT 1];
        User testUserWithUserId = new User(Id = testUser.Id, User_Id__c = 'USR_Test_123');
        update testUserWithUserId;

        // Test the method with exception
        Test.startTest();
        try {
            IntegrationEngine_Helper.form60API(loanAppId, applicantId);
        } catch (Exception ex) {
        }
        Test.stopTest();
    }

    private static List<Id> insertTestApplicantAndDocument() {
        // Insert Opportunity
        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30)
        );
        insert opp;

        // Insert Applicant
        Applicant__c applicant = new Applicant__c(
            Customer_Code__c = 'CUST123',
            In_Active_Applicant__c = false,
            Opportunity__c = opp.Id
        );
        insert applicant;

        // Insert Document
        Documents__c document = new Documents__c(
            Applicant__c = applicant.Id,
            Document_Type__c = 'Form 60',
            First_Name__c = 'John',
            Last_Name__c = 'Doe',
            Father_Name__c = 'Richard Doe',
            KYC_DOB__c = Date.newInstance(1990, 1, 1),
            KYC_Address_Line_1__c = '123 Main St',
            KYC_City__c = 'Pune',
            KYC_District__c = 'Pune',
            KYC_State__c = 'Maharashtra',
            KYC_Pin_Code__c = '411001',
            Mobile_Number__c = '9876543210',
            PAN_Acknowledgement_Number__c = 'PAN123456',
            Estimated_Annual_Income__c = 500000,
            Age__c = 30,
            Gender__c = 'Male',
            Amount_of_Transaction__c = 10000,
            Aadhaar_Enrollment_Number__c = '',
            Opportunity_Relation__c = opp.Id
        );
        insert document;

        return new List<Id>{opp.Id, applicant.Id};
    }

    // Mock HTTP response class for success scenario
    private class Form60APIMockResponse implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{ "response" : { "content" : [ ], "respDesc" : "Customer Form 60 Details Saved Successfully", "status" : "SUCCESS" } }');
            return res;
        }
    }

    // Mock HTTP response class for error scenario
    private class Form60APIMockErrorResponse implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(500);
            res.setBody('{"response":{"status":"ERROR","respDesc":"Internal Server Error"}}');
            return res;
        }
    }
}