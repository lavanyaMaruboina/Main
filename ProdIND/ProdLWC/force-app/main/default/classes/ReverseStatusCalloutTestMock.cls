/*------------------------------------------------------------
Author:        Vishal Gadhave
Company:       Nanostuffs Technologies
Description:   Test class for IND_ReverseStatusCalloutQueueable Successful response.
Inputs:        None 
Test Classes:    
History
Date            Author              Comments
-------------------------------------------------------------
4-11-2022      Vishal               Created
------------------------------------------------------------*/
@isTest
public with sharing class ReverseStatusCalloutTestMock implements HttpCalloutMock {
	public HTTPResponse respond(HTTPRequest request) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"JData":"bmvHXB5/b59ltoDPA8dwPKjM9zW1GwK5fvqA5/8G5nhpGab2oAHPBL8OOLg6XcncE7ZWoUhYTTCmZ2N2SB9xH5MV5d1sol5VAR6KVxRntxIUL7vTL8T8vakfsym8yQB4yHTq4+8TB3jkwjQG8JFG7w4H27Ip9RKo9W3wLSmvRV0R+x8b5YL/9L/HCCs/LunxwFvYpwNGsCaX9e5h3DDUGD7pIKVLvq+lAC2tjEDB+DNXtloQybpUMepEtphgLteEDSgweYstHhvfTFaAu1vb/DcI7ZX6Qzid/nB2TOMmcbOFhvbgkwjLy8RCp6eeUmn4CAlyo84GV6NplUPTlV1ChnqZCXopjvHyekexAJ8qvKmbdhkQNbJKE5t7yW+cwhodsb28GtfClUAEdCEo7eF0SVGyYdlqsnjjjBQ3t6gx1MY="}');            
        res.setStatusCode(200);
        return res;
    }
}