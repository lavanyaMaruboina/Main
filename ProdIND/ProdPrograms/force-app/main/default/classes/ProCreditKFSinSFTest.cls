@isTest
public class ProCreditKFSinSFTest {
    
      private class MockHttpResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            String response = '{"response":{"status":"SUCCESS","respDesc":"SMS has been sent successfully.","content":[{"Transaction_Id":" 5000000000000000000-30000000000000000\\n"}]}}';
            //String jdataRequest = '"bffData":';
            String encryptedResponse = IntegrationUtilities.getEncryptedRequest(response, System.Label.privateKey, System.Label.ivkey);  
            //String encryptedResponse = IntegrationUtilities.getEncryptedRequest(response,System.Label.privateKey,System.Label.ivkey); 
            String jdataRequest = '"JData":';
            res.setBody('{'+jdataRequest+'"'+encryptedResponse+'}');
            return res;
        }
    }
    
@isTest
    static void testGetSmsUrl() {
        // Create test data
        ProCredit_Deals__c testDeal = new ProCredit_Deals__c(
            Unique_Id__c = 'uniqueId123',
            SMS_URL__c = 'https://test.sms.url'
        );
        insert testDeal;

        // Set up the REST request
        RestRequest req = new RestRequest();
        req.requestURI = '/services/v1/proCreditKFSinSF/' + testDeal.Unique_Id__c;
        RestContext.request = req;
        RestContext.response = new RestResponse();

        // Call the method
        Test.startTest();
        ProCreditKFSinSF.getSmsUrl();
        Test.stopTest();

        // Assert the response
        System.assertEquals(201, RestContext.response.statusCode);
        String responseBody = RestContext.response.responseBody.toString();
    }
    
    
    static testmethod void testUploadLeadDetails() {
        // Setup test data for the request body
        
        
        // Mock the decryption utility method to return controlled output
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
        String testLeadPayload = '{"Source": "Procredit","Product": "H","Unique_Id":"987654","Entity_Type":"IND","Maker_Id": "123","DealNumbers": [{"Deal_No": "TTM01037S"}]}';
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = '/services/apexrest/v1/proCreditKFSinSF/';
        system.debug('request.requestURI---' + request.requestURI);
        request.httpMethod = 'Post';
        request.requestBody = Blob.valueof(IntegrationUtilities.getEncryptedRequest(testLeadPayload,System.Label.privateKey,System.Label.ivkey));
		request.addHeader('Content-Type', 'application/json');
        RestContext.request = request;
        RestContext.response =response;
        
       
        ProCreditKFSinSF.uploadLeadDetails();

        Test.stopTest();
        
      
    }
    
    
    
}