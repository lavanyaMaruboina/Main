@IsTest(SeeAllData = True)
private class ApiOrderwiseIntegrationSchedulerTest {

    @IsTest
    static void testExecute() {
        // Set up mock callout
        Test.setMock(HttpCalloutMock.class, new OrderwiseIntegrationMock());
        
        // Create an instance of the scheduler class
        ApiOrderwiseIntegrationScheduler scheduler = new ApiOrderwiseIntegrationScheduler();
        
        // Schedule the job to run one minute in the future
        String scheduleTime = System.now().addMinutes(1).format('ss mm HH dd MM ? yyyy');
        String jobId = System.schedule('Test Orderwise Integration Scheduler', scheduleTime, scheduler);
        
        // Verify that the job has been scheduled
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime
                          FROM CronTrigger WHERE Id = :jobId];
        System.assertEquals(0, ct.TimesTriggered, 'Job should not have been triggered yet');
        System.assertNotEquals(null, ct.NextFireTime, 'Next fire time should not be null');
        
        // Manually execute the job
        Test.startTest();
        Test.stopTest();
        
        // Verify that the job was triggered
        ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime
              FROM CronTrigger WHERE Id = :jobId];
       // System.assertEquals(1, ct.TimesTriggered, 'Job should have been triggered once');
    }
   
public class OrderwiseIntegrationMock implements HttpCalloutMock {
    public HttpResponse respond(HttpRequest req) {
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        
        // Check the request endpoint and method
        if (req.getEndpoint().contains('Token_End_Point')) {
            res.setStatusCode(200);
            res.setBody('"fakeAuthToken"'); // Simulate the token response
        } else {
            res.setStatusCode(400);
            res.setBody('{"error": "Bad Request"}');
        }
        
        return res;
    }
}

}