@isTest
public class IND_ReverseStatusCalloutKFSQueueableTest {
    @isTest
    static void testQueueableExecution() {
        // Step 1: Create test data
        Opportunity oppObj = new Opportunity();
        oppObj.Name = 'Test Opportunity';
        oppObj.StageName = 'Prospecting';
        oppObj.CloseDate = Date.today().addMonths(1);
        oppObj.Lead_number__c = '12345'; 
        insert oppObj;
        ProCredit_Deals__c procreditDeal = new ProCredit_Deals__c(
         Deal_Number__c = '2324234',
         Maker_Id__c = 'TestMaker'
        );
        insert procreditDeal;
        Key_Fact_Statement__c kfs = new Key_Fact_Statement__c(
            Unique_Id__c = '12345',
            Lead_Number__c = 'Lead123',
            Deal_Number__c = '1;2;3',
            Product__c = 'Product A',
            Loan_Application__c = oppObj.Id,
            Maker_Id__c = 'Maker123'
        );
        insert kfs;

        // Step 2: Set up the API configuration metadata
        // Integration_Configuration__mdt config = new Integration_Configuration__mdt(
        //     DeveloperName = 'Reverse_Status_of_KFS_statement',
        //     Rest_Method__c = 'POST',
        //     Endpoint_URL__c = '/test/endpoint',
        //     IsActive_Integration__c = true
        // );
        // insert config;

        // Step 3: Mock the HTTP response
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpSuccessResponse());

        // Step 4: Enqueue the queueable job
        IND_ReverseStatusCalloutKFSQueueable job = new IND_ReverseStatusCalloutKFSQueueable(kfs.Id, 'Accept');
        System.enqueueJob(job);

        Test.stopTest();

        // Step 5: Assertions to validate the job execution
        System.assertEquals(1, [SELECT COUNT() FROM Key_Fact_Statement__c WHERE Id = :kfs.Id]);
        // Add more assertions as needed based on what the job does
    }
    @isTest
    static void testQueueableExecution1() {
        Opportunity oppObj = new Opportunity();
        oppObj.Name = 'Test Opportunity';
        oppObj.StageName = 'Prospecting';
        oppObj.CloseDate = Date.today().addMonths(1);
        oppObj.Lead_number__c = '12345'; 
        insert oppObj;
        ProCredit_Deals__c procreditDeal = new ProCredit_Deals__c(
         Deal_Number__c = '2324234',
         Maker_Id__c = 'TestMaker'
        );
        insert procreditDeal;
        Key_Fact_Statement__c kfs = new Key_Fact_Statement__c(
            Unique_Id__c = '12345',
            Lead_Number__c = 'Lead123',
            Deal_Number__c = '1;2;3',
            Product__c = 'Product A',
            Loan_Application__c = oppObj.Id,
            Maker_Id__c = 'Maker123'
        );
        insert kfs;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpErrorResponse());
        IND_ReverseStatusCalloutKFSQueueable job = new IND_ReverseStatusCalloutKFSQueueable(kfs.Id, '');
        System.enqueueJob(job);
        Test.stopTest();
        System.assertEquals(1, [SELECT COUNT() FROM Key_Fact_Statement__c WHERE Id = :kfs.Id]);

    }

// Mock HTTP response class

private class MockHttpSuccessResponse implements HttpCalloutMock {
    public HTTPResponse respond(HttpRequest request) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"success": true, "data": {}}'); // Adjust this as per your actual response
        response.setStatusCode(200);
        return response;
    }
}
private class MockHttpErrorResponse implements HttpCalloutMock {
    public HTTPResponse respond(HttpRequest request) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"error": "Something went wrong"}'); // Simulated error response
        response.setStatusCode(500); // Simulating a server error
        return response;
    }
}
}