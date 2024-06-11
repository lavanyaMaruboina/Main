@isTest
global class MockHttpResponse implements HttpCalloutMock {

    Integer statusCode;  // injected by caller
    String testResult;
    global MockHttpResponse (Integer statusCode, String testResult) 
    {   this.statusCode = statusCode; 
        this.testResult = testResult;}

    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        switch on this.statusCode{
            when 200 {
                res.setHeader('Content-Type', 'application/json');
                if(testResult == 'success'){
                    // Create a fake success response
                    res.setBody('{"phoneNumber":"123456789","isSaved":"Y","message":"Saved"}');
                }else{
                    // Create a fake error response
                    res.setBody('{"phoneNumber":null,"isSaved":"N","message":"Phone Number is mandatory"}');
                }
                res.setStatusCode(200);
            } when 400 {
                // Create a fake failure response
                res.setBody('Internal Server Error. Please contact Administrator.');
                res.setStatusCode(400);

            }
        
        }
        return res;
    }

}