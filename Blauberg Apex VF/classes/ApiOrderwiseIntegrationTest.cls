@IsTest(SeeAllData =true)
public class ApiOrderwiseIntegrationTest {
    
    @IsTest
    static void testGetToken() {
        // Set up mock callout
        Test.setMock(HttpCalloutMock.class, new OrderwiseIntegrationMock());
        
        // Invoke the method
        List<String> tokens = ApiOrderwiseIntegration.getToken();
        
     
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