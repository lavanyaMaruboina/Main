@isTest
public class PactExceptionHandleTest implements HttpCalloutMock{
public HTTPResponse respond(HTTPRequest req) {
    
    
    
            HttpResponse res = new HttpResponse();
     res.setHeader('Content-Type', 'application/json');
     res.setBody('{"JData":"bmvHXB5/b59ltoDPA8dwPKjM9zW1GwK5fvqA5/8G5niBMRDutmgxxKuKRdocLOppcx7lZS4q1+ywCWRX68DBE6j685Q5CUnILU/Iyr4O7C1QU/Qn5judBaLL8WzmfM9F+l4eheWPW1D9Z9Fw31JWLYLBlbaJRAhWLDptolMrNms="}'); 
            res.setStatusCode(500); // Simulate server error response
            //res.setBody('Internal Server Error');
            return res;
        }
}