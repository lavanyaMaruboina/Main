/*------------------------------------------------------------
Author:        Santhosh Mothe
Company:       Persistent Systems
Description:   Class is to validate SSO credentails at SF login page
History
Date            Author              Comments
-------------------------------------------------------------
24-1-2022      Santhosh Mothe       Created
------------------------------------------------------------*/
@RestResource(urlMapping='/delegatedauth/*')
global without sharing class DelegatedAuthService {
    
    public static final Blob AUTH_TRUE = Blob.valueOf(System.Label.Auth_True);
    public static final Blob AUTH_FALSE = Blob.valueOf(System.Label.Auth_False);
    
    public static ParentAPIRequest parentAPIRequest{get;set;}
    
    @HttpPost
    global static void doPost() {
        
        Blob responseBody = AUTH_FALSE;
        RestRequest req = RestContext.request;
                
        try{
            Dom.Document doc = new Dom.Document();
            doc.load(req.requestBody.toString());
            Dom.XMLNode authRequest = doc.getRootElement();
            
            Dom.XMLNode xmlBody = authRequest.getChildElement('Body', 'http://schemas.xmlsoap.org/soap/envelope/');
            Dom.XMLNode authenticate = xmlBody.getChildElement('Authenticate', 'urn:authentication.soap.sforce.com');
            String username = authenticate.getChildElement('username', 'urn:authentication.soap.sforce.com').getText();
            String password = authenticate.getChildElement('password', 'urn:authentication.soap.sforce.com').getText();
            String sourceIp = authenticate.getChildElement('sourceIp', 'urn:authentication.soap.sforce.com').getText(); 
            
            
            List<User> users = [SELECT Id, username FROM User WHERE username = :username WITH SECURITY_ENFORCED Limit 1];
            if (users.size() == 0 ) {
                responseBody = AUTH_FALSE; 
                RestResponse res = RestContext.response; 
                res.addHeader('Content-Type', 'application/soap+xml');
                res.statusCode = 201;
                res.responseBody = responseBody;
            } else {
                username = username.substring(0, username.indexOf('@'));
                Ind_DelegateAuthRequest drRequest = new Ind_DelegateAuthRequest(username, password);
                DelegatedAuthService.parentAPIRequest = drRequest;
                String requestBody = '';
                String body = '';
                requestBody = parentAPIRequest.convertToJSON();
                
                String encryptedRequest = IntegrationUtilities.getEncryptedRequest(requestBody,System.Label.privateKey,System.Label.ivkey);  
                String jdataRequest = '"JData":';                    
                body='{'+jdataRequest + '"'+encryptedRequest+'"'+'}';
                
                     
                Http h = new Http();
                HttpRequest hr = new HttpRequest();
                
                Integration_Configuration__mdt apiConfiguration = IntegrationUtilities.getAPIConfiguration(System.Label.ADAuthentication);
                
                if(apiConfiguration != null){
                    if(!apiConfiguration.IsActive_Integration__c){
                        throw new IND_Exception(System.Label.ServiceDown);
                    }
                    
                    hr.setEndpoint('callout:Indus_API'+apiConfiguration.Endpoint_URL__c.trim()); 
                }
                Security_Setting__mdt metadataApi = Security_Setting__mdt.getInstance(System.Label.IBMMasterKey); 
                hr.setHeader(System.Label.X_IBM_Client_Id, metadataApi?.Client_Id__c);
        		hr.setHeader(System.Label.X_IBM_Client_Secret, metadataApi?.Client_Secret__c);
                
                hr.setHeader('Content-Type', 'application/json');
                hr.setMethod('POST');
                hr.setBody(body);
                HttpResponse hrs = h.send(hr);
               
                String response = hrs.getBody();                
                response = response.substring(10, response.length()-2);
                
                String decryptedResponse = IntegrationUtilities.getDecryptedResponse(response, System.Label.privateKey, System.Label.ivkey);
                
                Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(decryptedResponse);
                Map<String, Object> m2 = (Map<String, Object>) m.get('response');
                
                String respDesc = (String)m2.get('respDesc');
                
                if (hrs.getStatusCode() == 200 && respDesc == System.Label.Credentials_Validated_Sucessfully)  {
                    responseBody = AUTH_TRUE;
                    RestResponse res = RestContext.response;
                    res.statusCode = hrs.getStatusCode();
                    res.responseBody = responseBody;
                    res.addHeader('Content-Type', 'application/soap+xml');
                   
                }
                else if (hrs.getStatusCode() == 200 && respDesc == System.Label.The_user_name_or_password_is_incorrect)  {
                    responseBody = AUTH_FALSE; 
                    RestResponse res = RestContext.response;  
                    res.addHeader('Content-Type', 'application/soap+xml');
                    res.statusCode = 201;
                    res.responseBody = responseBody;    
                }
                else if (hrs.getStatusCode() == 200 && respDesc == System.Label.Account_is_Deactivated)  {
                    responseBody = AUTH_FALSE; 
                    RestResponse res = RestContext.response;  
                    res.addHeader('Content-Type', 'application/soap+xml');
                    res.statusCode = 201;
                    res.responseBody = responseBody;    
                }
                else if (hrs.getStatusCode() == 200 && respDesc == System.Label.Account_is_Temporarily_Disabled)  {
                    responseBody = AUTH_FALSE; 
                    RestResponse res = RestContext.response; 
                    res.addHeader('Content-Type', 'application/soap+xml');
                    res.statusCode = 201;
                    res.responseBody = responseBody;    
                }
                else if (hrs.getStatusCode() == 200 && respDesc == System.Label.An_Error_Occurred_Please_try_again_later)  {
                    responseBody = AUTH_FALSE; 
                    RestResponse res = RestContext.response; 
                    res.addHeader('Content-Type', 'application/soap+xml');
                    res.statusCode = 201;
                    res.responseBody = responseBody;    
                }
                else{
                    responseBody = AUTH_FALSE;
                    RestResponse res = RestContext.response; 
                    res.addHeader('Content-Type', 'application/soap+xml');
                    res.statusCode = 201;
                    res.responseBody = responseBody; 
                    
                }
                
            }
        }
        catch(Exception ex)
        {
            System.debug('Exception-->'+ex.getMessage() + ' Exception line number-->'+
                         ex.getLineNumber()+' Exception stack trace-->'+ ex.getStackTraceString());
            ErrorLoggerUtil.logErrorEvent('DelegatedAuthService', 'post', System.Label.Apex, ex);
            RestResponse res = RestContext.response;
            res.statusCode = 400;
            res.addHeader('Content-Type', 'application/soap+xml');
            res.responseBody = AUTH_FALSE;
            
        }
    }
}