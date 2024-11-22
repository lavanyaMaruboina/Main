@IsTest
public class MockHttpRespDelegAuthTest {

    @IsTest
    static void testRespond() {
        MockHttpRespDelegAuth mock = new MockHttpRespDelegAuth();
        HttpRequest req = new HttpRequest();
        req.setEndpoint('http://example.com');
        req.setMethod('GET');
        HttpResponse res = new HttpResponse();
        res.setStatusCode(200);
        res.setBody('{"success": true}');
        mock.addResponse(res);
        HttpResponse response = mock.respond(req);
        System.assertEquals(res, response);
    }
}