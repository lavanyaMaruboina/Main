/*------------------------------------------------------------
Author:        Neeraj Mehethrajkar
Company:       Salesforce
Description:   Test class for IND_PaymentRequestApiService Successful response.
Inputs:        None 
Test Classes:    
History
Date            Author                   Comments
-------------------------------------------------------------
1-07-2022      Neeraj Mehethrajkar       Created
------------------------------------------------------------*/
@isTest
public class IND_PaymentRequestAPIMock implements HttpCalloutMock{
	public HTTPResponse respond(HTTPRequest request) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"JData":"bmvHXB5/b59ltoDPA8dwPKjM9zW1GwK5fvqA5/8G5niBMRDutmgxxKuKRdocLOppcx7lZS4q1+ywCWRX68DBE6j685Q5CUnILU/Iyr4O7C1QU/Qn5judBaLL8WzmfM9F+l4eheWPW1D9Z9Fw31JWLYLBlbaJRAhWLDptolMrNms="}');            
        res.setStatusCode(200);
        return res;
    }
}