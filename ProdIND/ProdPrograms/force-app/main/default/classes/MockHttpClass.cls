/*------------------------------------------------------------
Author:        Haarika Chodisetti
Company:       Salesforce
Description:   This class is mock the responses of conVox APIs to help test classes
History
Date            Author              Comments
-------------------------------------------------------------
16-08-2022      Haarika Chodisetti         Created
------------------------------------------------------------*/
@isTest
global class MockHttpClass implements HttpCalloutMock{

    /*
     * @Method:      respond
     * @Created by:  Haarika Chodisetti
     * @Description: This method is to provide mock response to the passed request
     * @Param:       HTTPRequest      
     * @Return:      HTTPResponse    
     History
     Date            Author              Comments
     -------------------------------------------------------------
     16-08-2022      Haarika Chodisetti         Created
     ------------------------------------------------------------*/
    global HTTPResponse respond(HTTPRequest req){
            system.debug('in mock class');
            // Creating a fake response.
            HttpResponse response = new HttpResponse();
            response.setBody('{"status": "GL000","message": "SUCCESS","ActiveListID": "1-TestList","DeActiveListID": "nul"}');
            response.setStatusCode(200);            
            return response;
        }   
}