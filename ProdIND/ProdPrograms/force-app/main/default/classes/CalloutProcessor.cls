/*------------------------------------------------------------
Author:        Divya Jawale
Company:       Persistent Systems
Description:   This class contains methods to process request and response for all callouts.
Inputs:        None 
Test Class:     
History
Date            Author              Comments
-------------------------------------------------------------
1-10-2021      Divya Jawale       Created
11-12-2021      Bhushan Charde     Modified - Incorporated Continuation Framework changes
------------------------------------------------------------*/
public class CalloutProcessor {
    
    public String serviceName {get;set;}
    public ParentAPIRequest parentAPIRequest {get;set;}
    
    public Map<String,String> headerData{get;set;}
    public String body {get;set;}
    
    public CalloutProcessor(String serviceName, ParentAPIRequest parentAPIRequest){
        this.serviceName = serviceName;
        this.parentAPIRequest= parentAPIRequest;
    }
    
    /*
* @Method:      populateHeaderData
* @Created by:  Divya
* @Description: This method will set heads for API Requests
*/
    public void populateHeaderData(HttpRequest request){
        if(request != null && headerData != null && !headerData.isEmpty()){
            Set<String> keys = headerData.keySet();
            for(String key: keys){
                if(String.isNotBlank(headerData.get(key))){
                    request.setHeader(key, headerData.get(key));
                }               
            }
        }
    }
    
    /*
* @Method:      createHttpRequest
* @Created by:  Bhushan Charde
* @Description: This method will returns HttpRequest for APIs
* @Return:      Object - HttpRequest
*/
    public HttpRequest createHttpRequest(){
        HttpRequest httpRequest = new HttpRequest();
        Integration_Configuration__mdt apiConfiguration = IntegrationUtilities.getAPIConfiguration(serviceName);
        try {
            if(apiConfiguration != null){
                if(!apiConfiguration.IsActive_Integration__c){
                    throw new IND_Exception(System.Label.ServiceDown);
                }
                
                String searalizedJson='';
                String requestBody='';
                Decimal timeout = apiConfiguration.Timeout__c;
                
                String endpoint ='callout:Indus_API'+apiConfiguration.Endpoint_URL__c.trim();
                //String endpoint ='callout:IndusInd_Org'+apiConfiguration.Endpoint_URL__c.trim();
                //String endpoint = 'https://indusapiuat.indusind.com/indusapi-np/uat/cfdlos/Global-Repository/NESL/GetAgreementBookletNoDetails';
                String methodType = apiConfiguration.Rest_Method__c.trim();
                Map<String,String> requestHeaderMap = new Map<String,String>();
                if(serviceName == 'UIDAI OTP' || serviceName == 'UIDAI OTP Verify' || serviceName == 'UIDAI Biometric'){
                    requestBody = parentAPIRequest.xmlConvertedRequest();
                    requestHeaderMap = ParentAPIRequest.getHttpRequestHeaders();
                }else If(serviceName == system.label.Membership){
                    requestBody = parentAPIRequest.convertToNullEscapeJson();
                    requestHeaderMap = ParentAPIRequest.getHttpRequestHeaders();
                    
                    if(apiConfiguration.Encryption_Key__c != null){                    
                        requestHeaderMap.put('APIKEY',apiConfiguration.Encryption_Key__c);
                    }
                }else if(serviceName == System.Label.Payment_Request_For_Tractor){
                    requestBody = parentAPIRequest.convertToJSON();
                    Security_Setting__mdt metadataApi = Security_Setting__mdt.getInstance(System.Label.IBMMasterKey);
                    requestHeaderMap.put(IntegrationConstants.CONTENT_TYPE , IntegrationConstants.CONTENT_TYPE_JSON);
                    requestHeaderMap.put('IBL-Client-Id', metadataApi?.Client_Id__c);
                    requestHeaderMap.put('IBL-Client-Secret', metadataApi?.Client_Secret__c);
                    if(apiConfiguration.Encryption_Key__c != null){                    
                        requestHeaderMap.put('APIKEY',apiConfiguration.Encryption_Key__c);
                    }
                }else{
                    requestBody = parentAPIRequest.convertToJSON();
                    requestHeaderMap = ParentAPIRequest.getHttpRequestHeaders();
                    
                    if(apiConfiguration.Encryption_Key__c != null){                    
                        requestHeaderMap.put('APIKEY',apiConfiguration.Encryption_Key__c);
                    }
                }  
                String encryptedRequest = '';
                String JdataRequest = '';
                
                if(serviceName == System.Label.D2CVehicleValuation || serviceName == System.Label.D2CDisbursement || serviceName == System.Label.D2CSanction || serviceName == System.Label.D2CVehicleDedupe){
                    endpoint = 'callout:IBM_Org'+apiConfiguration.Endpoint_URL__c.trim();
                    JdataRequest = '"bffData":';
                    encryptedRequest = IBMEncryption.getEncryptedRequest(requestBody, System.Label.privateKey, System.Label.ivkey);  
                }else{
                    encryptedRequest = IntegrationUtilities.getEncryptedRequest(requestBody, System.Label.privateKey, System.Label.ivkey);  
                    JdataRequest = '"JData":';
                }
                body='{'+JdataRequest + '"'+encryptedRequest+'"'+'}';
                headerData = requestHeaderMap;                    
                
                System.debug('createHttpRequest encryptedRequest--> '+encryptedRequest);               
                System.debug('Request Generated is '+requestBody);                 
                Http http = new Http();
                
                populateHeaderData(httpRequest); 
                httpRequest.setMethod(methodType);                  
                httpRequest.setEndpoint(endpoint);
                if(timeout != null){
                    httpRequest.setTimeout(Integer.valueOf(timeout));
                }
                if(body != null){
                    httpRequest.setBody(body);
                }
            }
        }catch(Exception ex){
            System.debug('Exception-->'+ex.getMessage() + ' Exception line number-->'+
                         ex.getLineNumber()+' Exception stack trace-->'+ ex.getStackTraceString());
            ErrorLoggerUtil.logErrorEvent('CalloutProcessor', 'createHttpRequest', System.Label.Apex, ex, IntegrationEngine.loanApplicationRef);
            throw new IND_Exception(ex.getMessage());
        }
        system.debug('CalloutProcessor createHttpRequest - '+httpRequest.getBody());
        return httpRequest;
    }
    
    /*
* @Method:      createHttpRequestForReverseStatus
* @Created by:  Vishal Gadhave
* @Description: This method will returns HttpRequest for MSIL Reverse API only
* @Return:      Object - HttpRequest
*/
    public HttpRequest createHttpRequestForReverseStatus(){
        HttpRequest httpRequest = new HttpRequest();
        Integration_Configuration__mdt apiConfiguration = IntegrationUtilities.getAPIConfiguration(serviceName);
        try {
            if(apiConfiguration != null){
                if(!apiConfiguration.IsActive_Integration__c){
                    throw new IND_Exception(System.Label.ServiceDown);
                }
                
                String searalizedJson='';
                String requestBody='';
                Decimal timeout = apiConfiguration.Timeout__c;
                String endpoint = 'callout:Indus_API'+apiConfiguration.Endpoint_URL__c.trim();
                String methodType = apiConfiguration.Rest_Method__c.trim();
                Map<String,String> requestHeaderMap = new Map<String,String>();
                
                requestBody = parentAPIRequest.convertToJSON();
                requestHeaderMap = ParentAPIRequest.getHttpRequestHeaders();
                
                Security_Setting__mdt securityMtd = Security_Setting__mdt.getInstance('Reverse_Status');
                requestHeaderMap.put('IBL-Client-Id',securityMtd.Client_Id__c);
                requestHeaderMap.put('IBL-Client-Secret',securityMtd.Client_Secret__c);
                String encryptedRequest = IntegrationUtilities.getEncryptedRequest(requestBody, System.Label.privateKey, System.Label.ivkey);  
                String JdataRequest = '"JData":';                  
                body='{'+JdataRequest + '"'+encryptedRequest+'"'+'}';
                headerData = requestHeaderMap;                    
                System.debug('createHttpRequestForReverseStatus encryptedRequest--> '+encryptedRequest);               
                System.debug('Request Generated is '+requestBody);                 
                Http http = new Http();
                
                populateHeaderData(httpRequest); 
                httpRequest.setMethod(methodType);                  
                httpRequest.setEndpoint(endpoint);
                if(timeout != null){
                    httpRequest.setTimeout(Integer.valueOf(timeout));
                }
                if(body != null){
                    system.debug('body---' + body);
                    httpRequest.setBody(body);
                }
            }
        }catch(Exception ex){
            System.debug('Exception-->'+ex.getMessage() + ' Exception line number-->'+
                         ex.getLineNumber()+' Exception stack trace-->'+ ex.getStackTraceString());
            ErrorLoggerUtil.logErrorEvent('CalloutProcessor', 'createHttpRequestForReverseStatus', System.Label.Apex, ex, IntegrationEngine.loanApplicationRef);
            throw new IND_Exception(ex.getMessage());
        }
        system.debug('CalloutProcessor createHttpRequestForReverseStatus - '+httpRequest.getBody());
        return httpRequest;
    }
    
    /*
* @Method:      createHttpRequestForAadhaarVaultApi
* @Created by:  Poonam Tilokani
* @Description: This method will returns HttpRequest for Vault api
* @Return:      Object - HttpRequest
*/
    public HttpRequest createHttpRequestForAadhaarVaultApi(){
        HttpRequest httpRequest = new HttpRequest();
        Integration_Configuration__mdt apiConfiguration = IntegrationUtilities.getAPIConfiguration(serviceName);
        try {
            if(apiConfiguration != null){
                if(!apiConfiguration.IsActive_Integration__c){
                    throw new IND_Exception(System.Label.ServiceDown);
                }
                
                String searalizedJson='';
                String requestBody='';
                Decimal timeout = apiConfiguration.Timeout__c;
                String endpoint = System.label.vaultApiEndPointUrl;
                String methodType = apiConfiguration.Rest_Method__c.trim();
                Map<String,String> requestHeaderMap = new Map<String,String>();
                
                requestBody = parentAPIRequest.convertToJSON();
                requestHeaderMap = ParentAPIRequest.getHttpRequestHeaders();
                
                requestHeaderMap.put('IBL-Client-Id',System.label.clientIdVaultApi);
                requestHeaderMap.put('IBL-Client-Secret',System.label.clientSecretVaultApi);
                String encryptedRequest = IntegrationUtilities.getEncryptedRequest(requestBody, System.Label.privateKey, System.Label.ivkey);  
                String JdataRequest = '"JData":';                  
                body='{'+JdataRequest + '"'+encryptedRequest+'"'+'}';                 
                headerData = requestHeaderMap;                    
             
                System.debug('Request Generated is '+requestBody);                 
                Http http = new Http();
                
                populateHeaderData(httpRequest); 
                httpRequest.setMethod(methodType);                  
                httpRequest.setEndpoint(endpoint);
                if(timeout != null){
                    httpRequest.setTimeout(Integer.valueOf(timeout));
                }
                if(body != null){
                    system.debug('body---' + body);
                    httpRequest.setBody(body);
                }
            }
        }catch(Exception ex){
            System.debug('Exception-->'+ex.getMessage() + ' Exception line number-->'+
                         ex.getLineNumber()+' Exception stack trace-->'+ ex.getStackTraceString());
            ErrorLoggerUtil.logErrorEvent('CalloutProcessor', 'createHttpRequestForAadhaarVaultApi', System.Label.Apex, ex, IntegrationEngine.loanApplicationRef);
            throw new IND_Exception(ex.getMessage());
        }
        system.debug('CalloutProcessor createHttpRequestForAadhaarVaultApi - '+httpRequest.getBody());
        return httpRequest;
    }
    
    /*
* @Method:      getHttpResponse
* @Created by:  Bhushan Charde
* @Description: This method will returns HttpResponse for APIs
* @Return:      Object - ParentAPIResponse
*/
    public ParentAPIResponse getHttpResponse(HttpResponse response, String serviceName){
        system.debug('::getHttpResponse response '+response);
        ParentAPIResponse apiResponse=null;
        String responseBody= '';
        String decryptedResponse='';
        Integration_Configuration__mdt apiConfiguration = IntegrationUtilities.getAPIConfiguration(serviceName);           
        try{
            if(response != null){                        
                if(response.getStatusCode() == 200){
                    responseBody = response.getBody();     
                    responseBody = responseBody.substring(10, responseBody.length()-2);
                   
                    decryptedResponse = IntegrationUtilities.getDecryptedResponse(responseBody,System.Label.privateKey,System.Label.ivkey);
                    if(serviceName == 'Driving License'){ 
                        decryptedResponse = decryptedResponse.replace('/', '');
                    }else if(serviceName == 'AML Check' && decryptedResponse.contains('"matchedRecords":{}')){
                        decryptedResponse = response.getBody();
                    }else if(serviceName == 'BikeWale Prices' && decryptedResponse.contains('[')){//CISP-654
                        decryptedResponse = decryptedResponse.replace('[', '');
                        decryptedResponse = decryptedResponse.replace(']', '');
                    }//CISP-654
                    system.debug('getHttpResponse decryptedResponse--> '+decryptedResponse);
                    String searalizedJson = JSON.serializePretty(JSON.deserializeUntyped(decryptedResponse));
                    system.debug('getHttpResponse searalizedJson--> '+searalizedJson);
                    apiResponse = IntegrationUtilities.parseJSONResponse(searalizedJson, apiConfiguration.Response_wrapper__c);                             
                } else {
                    system.debug('response.getStatusCode()=== '+response.getStatusCode());
                    integer statusCode = response.getStatusCode();
                    String errString = '[Status Code = '+ statusCode +' ] Response-->'+IntegrationUtilities.getPlainTextForLog(response.getBody());
                    ErrorLoggerUtil.logErrorEvent('CalloutProcessor', 'getHttpResponse', System.Label.Apex, new IND_Exception(errString), IntegrationEngine.loanApplicationRef);
                    throw new IND_Exception(System.Label.Retry);
                } 
            }
            return apiResponse;
        } catch(CalloutException ex) {
            System.debug('CalloutProcessor process() Exception-->'+ex.getMessage() +
                         ' Exception line number-->'+ ex.getLineNumber()+ 
                         ' Stack Tracer-->'+ ex.getLineNumber()); 
            
            ErrorLoggerUtil.logErrorEvent('CalloutProcessor', 'getHttpResponse', System.Label.Apex, ex, IntegrationEngine.loanApplicationRef);
            throw new CalloutException(ex.getMessage()); 
        }	        
    }
    
    /*
* @Method:      getHttpResponseForAll
* @Created by:  Bhushan Charde
* @Description: This method will returns HttpResponse for APIs
* @Return:      String 
*/
    public String getHttpResponseForAll(HttpResponse response, String serviceName){ 
        String responseBody= '';
        String searalizedJson='';
        Integration_Configuration__mdt apiConfiguration = IntegrationUtilities.getAPIConfiguration(serviceName);           
        try{
            
            if(response != null){                        
                if(response.getStatusCode() == 200){
                    responseBody = response.getBody();                        
                    responseBody = responseBody.substring(10, responseBody.length()-2);  
                    
                    String decryptedResponse = IntegrationUtilities.getDecryptedResponse(responseBody,System.Label.privateKey,System.Label.ivkey);
                    System.debug('getHttpResponseForAll decryptedResponseResponse--> '+decryptedResponse);
                    searalizedJson = JSON.serializePretty(JSON.deserializeUntyped(decryptedResponse));
                    
                    if(serviceName == 'UIDAI OTP' || serviceName == 'UIDAI OTP Verify' || serviceName == 'UIDAI Biometric'){ 
                        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(decryptedResponse);
                        Map<String, Object> m2 = (Map<String, Object>) m.get('response');
                        List<Object> m3 = (List<Object>) m2.get('content');
                        String str = (String)m3.get(0);
                        searalizedJson = XMLParser.xmlToJson(str);
                    }
                    
                } else {
                    integer statusCode = response.getStatusCode();
                    String errString = '[Status Code = '+ statusCode +' ] '+IntegrationUtilities.getPlainTextForLog(response.getBody());
                    ErrorLoggerUtil.logErrorEvent('CalloutProcessor', 'getHttpResponseForAll', System.Label.Apex, new IND_Exception(errString), IntegrationEngine.loanApplicationRef); 	
                    throw new IND_Exception(System.Label.Retry);
                }
            }
            system.debug('getHttpResponseForAll searalizedJson---> '+searalizedJson);
            return searalizedJson;
        } catch(CalloutException ex) {
            System.debug('CalloutProcessor process() Exception-->'+ex.getMessage() +
                         ' Exception line number-->'+ ex.getLineNumber()+ 
                         ' Stack Tracer-->'+ ex.getLineNumber()); 
            
            ErrorLoggerUtil.logErrorEvent('CalloutProcessor', 'getHttpResponseForAll', System.Label.Apex, ex, IntegrationEngine.loanApplicationRef);
            throw new CalloutException(ex.getMessage()); 
        }	        
    }
}