/*------------------------------------------------------------
Author:        Santhosh Mothe
Company:       Persistent Systems
Description:   Test class created to validate the DelegateAuthService class
History
Date            Author              Comments
-------------------------------------------------------------
24-1-2021      Santhosh Mothe       Created
------------------------------------------------------------*/
global class MockHttpRespDelegAuth implements HttpCalloutMock{
    
        HttpResponse[] responses = new HttpResponse[0];
    
        public void addResponse(HttpResponse response) {
            responses.add(response);
        }
    
        global HTTPResponse respond(HTTPRequest req) {
            
            return responses[0];
        
    }
}