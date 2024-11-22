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
global class CTIMockHttpClass implements HttpCalloutMock{

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
            HttpResponse response = new HttpResponse();
        	conVoxAPIHandler.resultWrapper rW = new conVoxAPIHandler.resultWrapper();
        	rW.status = 'GL000';
       		rW.message = 'SUCCESS';
        	rW.ActiveListID = '1-TestList';
        	rW.DeActiveListID = 'null';
        	String encryptedResponse = IntegrationUtilities.getEncryptedRequest(JSON.serialize(rW),System.Label.privateKey,System.Label.ivkey); 
        	String jdataRequest = '"JData":';
        	String requestBody = '{'+jdataRequest + '"'+encryptedResponse+'"'+'}';
            response.setBody(requestBody);
            response.setStatusCode(200);            
            return response;
        }   
}