/*------------------------------------------------------------
Author:        Khushiram
Company:       Persistent Systems
Description:   This class contains all Integration Utility methods.
Inputs:        None 
Test Class:      
History
Date            Author              Comments
-------------------------------------------------------------
1-10-2021      Khushiram       Created
11-12-2021     Bhushan Charde  Modified - Incorporated Continuation Framework changes
15-12-2021     Santhosh        Modified - Async/Platform Events related changes
01-4-2022      Santhosh		   Modified - getCicNo logic
16-11-2022      Rohan		   Modified - network id SOQL logic
------------------------------------------------------------*/
public with sharing class IntegrationUtilities {
    
    /*
* @Method Name - gattingCheckEligibilityAPI
* @Created by: Neha G.
* @description: Method will call an API to check Eligibility of Applicant for Loan:IND-308
*/
    public static String gattingCheckEligibilityAPI(){
        WrapperCheckEligibilityAPI responseJSON = new WrapperCheckEligibilityAPI();
        String serializedResponseAPI = JSON.serialize(responseJSON);
        return '{"status":"false","message":"Journey Stop"}';
    }
    
    /*
* @Method Name - WrapperCheckEligibilityAPI
* @Created by: Neha G.
* @description: Wrapper Class for gattingCheckEligibilityAPI() function
*/
    public class WrapperCheckEligibilityAPI {
        public String status {get;set;} 
        public String message {get;set;}
        
        WrapperCheckEligibilityAPI() {
            this.status = '';
            this.message = '';
        }
    }
    
    
    /*
* @Method Name - getAPIConfiguration
* @Created by: Divya
* @description: Fetching metadata based on the service name
* @Param:       String - serviceName
* @Return:      Object - Integration_Configuration__mdt type
*/    
    public static Integration_Configuration__mdt getAPIConfiguration(String serviceName){
        Integration_Configuration__mdt metadataApi = new Integration_Configuration__mdt();
        
        if(Schema.sObjectType.Integration_Configuration__mdt.isAccessible()){
            metadataApi = [Select API__c,Auth_Techniquie__c,Auth_Token__c,Auth_Type__c,DeveloperName,DML_Target_Object__c,
                           Enable_Message_logs__c, MasterLabel,Named_Credential__c,Parent_Object__c,Password__c,Request_fields__c,IsStub_Required__c,
                           Rest_Method__c,Target_Object__c,Target_URL__c,Username__c,Integration_Name__c,Endpoint_URL__c,Encryption_Key__c,IsActive_Integration__c,
                           isSync__c,Response_wrapper__c,Timeout__c, Channel_Name__c
                           From Integration_Configuration__mdt
                           WHERE Integration_Name__c =: serviceName];  
            
        }
        return metadataApi;
    } 
    
    /*
* @Method Name - parseJSONResponse
* @Created by: Divya
* @description: Parsing response to its wrapper type
* @Param:       String - responseBody
* @Param:       String - className
* @Param:       String - serviceName
* @Return:      Object - ParentAPIResponse type
*/ 
    public static ParentAPIResponse parseJSONResponse(String responseBody, String className){
        ParentAPIResponse res;
        
        try{
            JSONParser parser = JSON.createParser(responseBody);
            Type wrapperType = Type.forName(className);
            res = (ParentAPIResponse)parser.readValueAs(wrapperType);
        }catch(Exception ex){
            ErrorLoggerUtil.logErrorEvent('IntegrationUtilities', 'parseJSONResponse', System.Label.Apex, ex);
            throw ex;
        }
        return res;
    }
    
    /*
* @Method:      getStubResponse
* @Created by:  Bhushan
* @Description: Method to return Stub Response for API
* @Param:       String - serviceName
* @Return:      String - returns stub reponse
*/
    public static String getStubResponse(String serviceName){
        Stub_Response__mdt [] stubAPI =  [Select Response_Type__c, Response_xml_Json__c
                        From Stub_Response__mdt
                        WHERE Service_Name__c =: serviceName];
        if(stubAPI.size() > 0){
            return stubAPI[0].Response_xml_Json__c;
        } else {
            return null;
        }
    }
    
   /*
* @Method:      publishHighPayload
* @Created by:  Santhosh Mothe
* @Description: 
* @Param:       String - serviceName, req, reqExt
* @Return:      void
*/
public static void publishHighPayload(String request, String requestExt, String service, String plainReq, String targetObjectId, String docId){ //CISP-13969 Added docId param
    String refId;
    if(service == System.Label.RegistrationStatus || service == System.Label.SIStatus || service == System.Label.GetCRIFReport) {
        refId = targetObjectId + '-' + string.valueOf(Utilities.generateUniqueNumberAsyncCallout(6)); 
    } else {
        refId = docId+'-'+string.valueOf(Utilities.generateUniqueNumberAsyncCallout(6));
    }

    String loanId = IntegrationEngine.loanApplicationRef;
    Opportunity loanRec = [Select Id, CRIFF_Report_Initiated__c From Opportunity Where Id =: loanId Limit 1];

    List<High_Payload_Request__e> platformEventforDocReportList = new List<High_Payload_Request__e>();
    High_Payload_Request__e platformEventforDocReport = new High_Payload_Request__e();
    platformEventforDocReport.Request__c = request; 
    platformEventforDocReport.Request_Ext__c = requestExt; 
    platformEventforDocReport.SVC_Name__c = service;
    platformEventforDocReport.Reference_Id__c = refId;
    platformEventforDocReportList.add(platformEventforDocReport);
    

    List<Integration_Log__c> intLogList = new List<Integration_Log__c>();
    List<Database.SaveResult> results = EventBus.publish(platformEventforDocReportList);
    for (Database.SaveResult saveresult : results) {
        if (saveresult.isSuccess()) {
            // Get the UUID that uniquely identifies this event publish
            Integration_Log__c intObj=new Integration_Log__c();
            intObj.Original_request__c = plainReq;
            intObj.Encrypted_request__c = request;
            intObj.RequestExt__c = requestExt;  
            intObj.ReferenceId__c = refId;  
            intObj.Service_Name__c = service;
            intObj.Status__c = 'Success';
            intObj.isSync__c = false;
            intObj.targetRecordId__c = targetObjectId;
            intObj.Loan_Application__c = IntegrationEngine.loanApplicationRef;
            intLogList.add(intObj);
            if(service == 'GetCRIFReport'){loanRec.CRIFF_Report_Initiated__c = true;}
            
        } else {
            for(Database.Error err : saveresult.getErrors()) {
                ErrorLoggerUtil.logErrorEvent('IntegrationUtilities', 'publishHighPayload', System.Label.Apex, new AuraHandledException('Events publishing issue.') , IntegrationEngine.loanApplicationRef);
            }
        }
    }
    if(Schema.sObjectType.Integration_Log__c.isUpdateable())
    {
        try{
            upsert intLogList;
            if(service == 'GetCRIFReport'){update loanRec;}
        }catch(Exception ex){
            ErrorLoggerUtil.logErrorEvent('IntegrationUtilities', 'publishHighPayload', System.Label.Apex, ex, IntegrationEngine.loanApplicationRef);
            throw new AuraHandledException(ex.getMessage());
        }
    }
}
/*
* @Method:      publishLowPayload
* @Created by:  Santhosh Mothe
* @Description: 
* @Param:       String - serviceName, req, reqExt
* @Return:      void
*/
public static void publishLowPayload(String request, String service, String plainReq, String targetObjectId, String docId){ //CISP-13969 Added docId param
    
    String refId;
    if(service == System.Label.RegistrationStatus || service == System.Label.SIStatus || service == System.Label.GetCRIFReport) {
        refId = targetObjectId + '-' + string.valueOf(Utilities.generateUniqueNumberAsyncCallout(6));
    } else {
        refId = docId+'-'+string.valueOf(Utilities.generateUniqueNumberAsyncCallout(6));
    }
    String loanId = IntegrationEngine.loanApplicationRef;
    Opportunity loanRec = [Select Id, CRIFF_Report_Initiated__c From Opportunity Where Id =: loanId Limit 1];

    List<Low_Payload_Request__e> platformEventforDocReportList = new List<Low_Payload_Request__e>();
    Low_Payload_Request__e platformEventforDocReport = new Low_Payload_Request__e();
    platformEventforDocReport.Request__c = request; 
    platformEventforDocReport.SVC_Name__c = service;
    platformEventforDocReport.Reference_Id__c = refId;
    platformEventforDocReportList.add(platformEventforDocReport);
    
    List<Integration_Log__c> intLogList = new List<Integration_Log__c>();
    List<Database.SaveResult> results = EventBus.publish(platformEventforDocReportList);
    for (Database.SaveResult saveresult : results) {
        if (saveresult.isSuccess()) {
            // Get the UUID that uniquely identifies this event publish
            Integration_Log__c intObj=new Integration_Log__c();
            intObj.Original_request__c = plainReq;
            intObj.Encrypted_request__c = request;
            intObj.ReferenceId__c = refId;  
            intObj.Service_Name__c = service;
            intObj.isSync__c = false;
            intObj.targetRecordId__c = targetObjectId;
            intObj.Loan_Application__c = IntegrationEngine.loanApplicationRef;
            intLogList.add(intObj);
            if(service == 'GetCRIFReport'){loanRec.CRIFF_Report_Initiated__c = true;}
            
        } else {
            for(Database.Error err : saveresult.getErrors()) {
                ErrorLoggerUtil.logErrorEvent('IntegrationUtilities', 'publishLowPayload', System.Label.Apex, new AuraHandledException('Events publishing issue.'), IntegrationEngine.loanApplicationRef);
            }
        }
    }
    if(Schema.sObjectType.Integration_Log__c.isUpdateable())
    {
        try{
            upsert intLogList;
            if(service == 'GetCRIFReport'){update loanRec;}
        }catch(Exception ex){
            ErrorLoggerUtil.logErrorEvent('IntegrationUtilities', 'publishLowPayload', System.Label.Apex, ex, IntegrationEngine.loanApplicationRef);
            throw new AuraHandledException(ex.getMessage());
        }
    }
}
    
    /*
* @Method:      getEncryptedRequest
* @Created by:  Divya
* @Description: Method to return Encrypted Request
* @Param:       String - JSON Request
* @Param:       String - key
* @Param:       String - vkey
* @Return:      String - encryptedString
*/
    public static String getEncryptedRequest(String requestJSON,String key,String vKey){
        Blob privateKey = Blob.valueOf(getAPIKeys(key));
        Blob ivkey = Blob.valueOf(getAPIKeys(vKey)); 
        Blob data = Blob.valueOf(requestJSON);  
        Blob encrypted = Crypto.encrypt('AES256', privateKey, ivkey, data); 
        String encryptedString = EncodingUtil.base64Encode(encrypted);  
        return encryptedString;
    }
    
    /*
* @Method:      getDecryptedResponse
* @Created by:  Divya
* @Description: Method to return Decrypted Response
* @Param:       String - JSON Response
* @Param:       String - key
* @Param:       String - vkey
* @Return:      String - decryptedString
*/
    public static String getDecryptedResponse(String responseJSON,String key,String vKey){
        System.debug('Line 248'+responseJSON);
        Blob privateKey = Blob.valueOf(getAPIKeys(key));  
        Blob ivkey = Blob.valueOf(getAPIKeys(vKey)); 
        Blob data = EncodingUtil.base64Decode(responseJSON);
        Blob decrypted = Crypto.decrypt('AES256', privateKey, ivkey, data);   
        String decryptedString = decrypted.toString();  
        return decryptedString;
    }
    
    @InvocableMethod(label='Insert plain response' description='Insert plain response')
    public static List<String> getPlainTextForLogFromFlow(List<String> encryResponse) {
        String decryptedResponse='';
        List<String> decryptedResponseList = new List<String>();
        
        if(encryResponse[0] != null){
            String responseBody = encryResponse[0].substring(10, encryResponse[0].length()-2);                                                               
            decryptedResponse = getDecryptedResponse(responseBody,System.Label.privateKey,System.Label.ivkey);
        }
        decryptedResponseList.add(decryptedResponse);
        return decryptedResponseList;
    }
    
    /*
* @Method:      getPlainTextForLog
* @Created by:  Bhushan
* @Description: Method to return Stub Response for API
* @Param:       String - encryptedText
* @Return:      String - decryptedRequest
*/    
    public static String getPlainTextForLog(String encryptedText) {
        String decryptedRequest='';
        if(encryptedText != null && !String.isBlank(encryptedText)){
            String requestBody = encryptedText.substring(10, encryptedText.length()-2);                                                               
            decryptedRequest = getDecryptedResponse(requestBody, System.Label.privateKey, System.Label.ivkey);
        }
        return decryptedRequest;
    }
    
    /*
* @Method:      createIntegrationLogger
* @Created by:  Bhushan
* @Description: Method to write IntegrationLogger via Platform Events
* @Param:       String - request
* @Param:       String - encryptedRequest
* @Param:       String - response
* @Param:       String - encryptedResponse
* @Param:       String - serviceName
* @Param:       String - elapseTime
* @Param:       String - loanApplicationId
* @Param:       String - Status
*/     
    public static void createIntegrationLogger(String request, String encryptedRequest,String response, String encryptedResponse,
                                               String serviceName, String elapseTime, String loanApplicationId, String status){
                                                   system.debug('BH Logs:: request= '+request+' loanApplicationId='+loanApplicationId);
                                                   system.debug('BH Logs:: response= '+response+' serviceName='+serviceName);
                                                    system.debug('BH Logs:: elapseTime= '+elapseTime+' status='+status);
                                                   String req='';
                                                   String encryReq='';
                                                   String res='';
                                                   String encryRes='';
                                                   boolean contentVersionRequiredFlag = false;
                                                   Map<String, String> tempMap;
                                                   
                                                   if (request.length() <= 131072){
                                                       req = request;
                                                   }
                                                   else{
                                                       contentVersionRequiredFlag = true;
                                                   }
                                                   if (response.length() <= 131072){
                                                       res = response;   
                                                   }
                                                   else{
                                                       contentVersionRequiredFlag = true;
                                                   }
                                                   if (encryptedRequest.length() <= 131072){
                                                       encryReq = encryptedRequest;
                                                   }
                                                   else{
                                                       contentVersionRequiredFlag = true;
                                                   }
                                                   if (encryptedResponse.length() <= 131072){
                                                       encryRes = encryptedResponse;   
                                                   }
                                                   else{
                                                       contentVersionRequiredFlag = true;
                                                   }
                                                   if(contentVersionRequiredFlag == true){
                                                       createContentDocforIntegrationLog(request, encryptedRequest, response, encryptedResponse,serviceName, elapseTime, loanApplicationId, status);
                                                       return;
                                                   }
                                                   
                                                   
                                                   List<Integration_Logger_Event__e> intgLogPlatformEventList = new List<Integration_Logger_Event__e>();
                                                   Integration_Logger_Event__e platformEventIntgLog = new Integration_Logger_Event__e();
                                                   platformEventIntgLog.Request__c = req;  
                                                   //platformEventIntgLog.Request_Ext__c=reqExt;                                  
                                                   platformEventIntgLog.EncryptedRequest__c = encryptedRequest;
                                                   platformEventIntgLog.Response__c = res;
                                                   //platformEventIntgLog.Response_Ext__c =resExt;                                  
                                                   platformEventIntgLog.EncryptedResponse__c = encryptedResponse;
                                                   platformEventIntgLog.ServiceName__c = serviceName;
                                                   platformEventIntgLog.Elapsed_Time__c = elapseTime; 
                                                    if(serviceName == 'Procredit KFS' || serviceName == 'ProCredit_SMS' || serviceName == 'Reverse Status KFS Consent Procredit'){                                
                                                    platformEventIntgLog.ProCredit_Deal__c  = loanApplicationId;
                                                   }else{
                                                    platformEventIntgLog.Loan_Application_ID__c  = loanApplicationId;
                                                   }
                                                   platformEventIntgLog.Status__c = status;
                                                   intgLogPlatformEventList.add(platformEventIntgLog);
                                                   List<Database.SaveResult> results = EventBus.publish(intgLogPlatformEventList);
                                                   for (Database.SaveResult saveresult : results) {
                                                       if (saveresult.isSuccess()) {
                                                           System.debug('Successfully published event for Integration Logger');
                                                       } else {
                                                           for(Database.Error err : saveresult.getErrors()) {
                                                               System.debug('Error returned during event published ' +err.getStatusCode() +' - ' +err.getMessage());
                                                           }
                                                       }
                                                   }
                                               } 

                                                   /*
* @Method:      createIntegrationLoggerTFoffer
* @Created by:  Bhushan
* @Description: Method to write IntegrationLogger via Platform Events
* @Param:       String - request
* @Param:       String - encryptedRequest
* @Param:       String - response
* @Param:       String - encryptedResponse
* @Param:       String - serviceName
* @Param:       String - elapseTime
* @Param:       String - loanApplicationId
* @Param:       String - Status
*/     
    public static void createIntegrationLoggerTFoffer(String request, String encryptedRequest,String response, String encryptedResponse,
                                                        String serviceName, String elapseTime, String loanApplicationId, String status,String vehicleId){
        String req='';
        String encryReq='';
        String res='';
        String encryRes='';
        boolean contentVersionRequiredFlag = false;
        Map<String, String> tempMap;
        
        if (request.length() <= 131072){
            req = request;
        }
        else{
            contentVersionRequiredFlag = true;
        }
        if (response.length() <= 131072){
            res = response;   
        }
        else{
            contentVersionRequiredFlag = true;
        }
        if (encryptedRequest.length() <= 131072){
            encryReq = encryptedRequest;
        }
        else{
            contentVersionRequiredFlag = true;
        }
        if (encryptedResponse.length() <= 131072){
            encryRes = encryptedResponse;   
        }
        else{
            contentVersionRequiredFlag = true;
        }
        if(contentVersionRequiredFlag == true){
            createContentDocforIntegrationLog(request, encryptedRequest, response, encryptedResponse,serviceName, elapseTime, loanApplicationId, status);
            return;
        }
        
        
        List<Integration_Logger_Event__e> intgLogPlatformEventList = new List<Integration_Logger_Event__e>();
        Integration_Logger_Event__e platformEventIntgLog = new Integration_Logger_Event__e();
        platformEventIntgLog.Request__c = req;                                 
        platformEventIntgLog.EncryptedRequest__c = encryptedRequest;
        platformEventIntgLog.Response__c = res;                                
        platformEventIntgLog.EncryptedResponse__c = encryptedResponse;
        platformEventIntgLog.ServiceName__c = serviceName;
        platformEventIntgLog.Elapsed_Time__c = elapseTime; 
        platformEventIntgLog.Loan_Application_ID__c  = loanApplicationId;
        platformEventIntgLog.Status__c = status;
        platformEventIntgLog.Reference_Id__c = vehicleId;
        intgLogPlatformEventList.add(platformEventIntgLog);
        List<Database.SaveResult> results = EventBus.publish(intgLogPlatformEventList);
        for (Database.SaveResult saveresult : results) {
            if (saveresult.isSuccess()) {
                System.debug('Successfully published event for Integration Logger');
            } else {
                for(Database.Error err : saveresult.getErrors()) {
                    System.debug('Error returned during event published ' +err.getStatusCode() +' - ' +err.getMessage());
                }
            }
        }
    }

                                                   /*
* @Method:      createIntegrationLogger
* @Created by:  Gaurav Rawat
* @Description: Method to write IntegrationLogger via Platform Events
* @Param:       String - request
* @Param:       String - encryptedRequest
* @Param:       String - response
* @Param:       String - encryptedResponse
* @Param:       String - serviceName
* @Param:       String - elapseTime
* @Param:       String - loanApplicationId
* @Param:       String - Status
* @Param:       String - targetObjectId
*/     
    public static void createIntegrationLogger(String request, String encryptedRequest,String response, String encryptedResponse,String serviceName, String elapseTime, String loanApplicationId, String status, String targetObjectId){
        String req='';
        String encryReq='';
        String res='';
        String encryRes='';
        boolean contentVersionRequiredFlag = false;
        Map<String, String> tempMap;
        
        if (request.length() <= 131072){
            req = request;
        }
        else{
            contentVersionRequiredFlag = true;
        }
        if (response.length() <= 131072){
            res = response;   
        }
        else{
            contentVersionRequiredFlag = true;
        }
        if (encryptedRequest.length() <= 131072){
            encryReq = encryptedRequest;
        }
        else{
            contentVersionRequiredFlag = true;
        }
        if (encryptedResponse.length() <= 131072){
            encryRes = encryptedResponse;   
        }
        else{
            contentVersionRequiredFlag = true;
        }
        if(contentVersionRequiredFlag == true){
            createContentDocforIntegrationLog(request, encryptedRequest, response, encryptedResponse,serviceName, elapseTime, loanApplicationId, status);
            return;
        }
        
        
        List<Integration_Logger_Event__e> intgLogPlatformEventList = new List<Integration_Logger_Event__e>();
        Integration_Logger_Event__e platformEventIntgLog = new Integration_Logger_Event__e();
        platformEventIntgLog.Request__c = req;  
        //platformEventIntgLog.Request_Ext__c=reqExt;                                  
        platformEventIntgLog.EncryptedRequest__c = encryptedRequest;
        platformEventIntgLog.Response__c = res;
        //platformEventIntgLog.Response_Ext__c =resExt;                                  
        platformEventIntgLog.EncryptedResponse__c = encryptedResponse;
        platformEventIntgLog.ServiceName__c = serviceName;
        platformEventIntgLog.Elapsed_Time__c = elapseTime; 
        platformEventIntgLog.Loan_Application_ID__c  = loanApplicationId;
        if(String.isNotBlank(targetObjectId)){
            platformEventIntgLog.uidRefId__c  = targetObjectId;
        }
        platformEventIntgLog.Status__c = status;
        intgLogPlatformEventList.add(platformEventIntgLog);
        List<Database.SaveResult> results = EventBus.publish(intgLogPlatformEventList);
        for (Database.SaveResult saveresult : results) {
            if (saveresult.isSuccess()) {
                System.debug('Successfully published event for Integration Logger');
            } else {
                for(Database.Error err : saveresult.getErrors()) {
                    System.debug('Error returned during event published ' +err.getStatusCode() +' - ' +err.getMessage());
                }
            }
        }
    } 

    /* This also be deleted once Status & LoanAppId work get completed
* @Method:      createIntegrationLogger
* @Created by:  Sharad
* @Description: Method to write IntegrationLogger via Platform Events
* @Param:       String - request
* @Param:       String - encryptedRequest
* @Param:       String - response
* @Param:       String - encryptedResponse
* @Param:       String - serviceName
* @Param:       String - elapseTime
*/    
    public static void createIntegrationLogger(String request, String encryptedRequest,String response, String encryptedResponse,
                                               String serviceName, String elapseTime, String loanApplicationId){
                                                   String req='';
                                                   String encryReq='';
                                                   String res='';
                                                   String encryRes='';
                                                   boolean contentVersionRequiredFlag = false;
                                                    Map<String, String> tempMap;
                                                  
                                                   if (request.length() <= 131072){
                                                       req = request;
                                                   }
                                                   else{
                                                       contentVersionRequiredFlag = true;
                                                   }
                                                   if (response.length() <= 131072){
                                                       res = response;   
                                                   }
                                                   else{
                                                       contentVersionRequiredFlag = true;
                                                   }
                                                   if (encryptedRequest.length() <= 131072){
                                                       encryReq = encryptedRequest;
                                                   }
                                                   else{
                                                       contentVersionRequiredFlag = true;
                                                   }
                                                   if (encryptedResponse.length() <= 131072){
                                                       encryRes = encryptedResponse;   
                                                   }
                                                   else{
                                                       contentVersionRequiredFlag = true;
                                                   }
                                                   if(contentVersionRequiredFlag == true){
                                                       //createContentDocforIntegrationLog(request, encryptedRequest, response, encryptedResponse,serviceName, elapseTime, loanApplicationId, '');
                                                       return;
                                                   }
                                                   
                                                   List<Integration_Logger_Event__e> intgLogPlatformEventList = new List<Integration_Logger_Event__e>();
                                                   Integration_Logger_Event__e platformEventIntgLog = new Integration_Logger_Event__e();
                                                   platformEventIntgLog.Request__c = req;  
                                                   //platformEventIntgLog.Request_Ext__c=reqExt;                                  
                                                   platformEventIntgLog.EncryptedRequest__c = encryptedRequest;
                                                   platformEventIntgLog.Response__c = res;
                                                   //platformEventIntgLog.Response_Ext__c =resExt;                                  
                                                   platformEventIntgLog.EncryptedResponse__c = encryptedResponse;
                                                   platformEventIntgLog.ServiceName__c = serviceName;
                                                   platformEventIntgLog.Elapsed_Time__c = elapseTime; 
                                                   platformEventIntgLog.Loan_Application_ID__c  = loanApplicationId; 
                                                   intgLogPlatformEventList.add(platformEventIntgLog);
                                                   List<Database.SaveResult> results = EventBus.publish(intgLogPlatformEventList);
                                                   for (Database.SaveResult saveresult : results) {
                                                       if (saveresult.isSuccess()) {
                                                       } else {
                                                           for(Database.Error err : saveresult.getErrors()) {
                                                           }
                                                       }
                                                   }
                                               }   
       
    /*
* @Method:      createIntegrationLogger
* @Created by:  Sharad
* @Description: Method to write IntegrationLogger via Platform Events
* @Param:       String - request
* @Param:       String - encryptedRequest
* @Param:       String - response
* @Param:       String - encryptedResponse
* @Param:       String - serviceName
* @Param:       String - elapseTime
*/    
    public static void createIntegrationLogger(String request, String encryptedRequest,String response, String encryptedResponse,
                                               String serviceName, String elapseTime){
                                                   List<Integration_Logger_Event__e> intgLogPlatformEventList = new List<Integration_Logger_Event__e>();
                                                   Integration_Logger_Event__e platformEventIntgLog = new Integration_Logger_Event__e();
                                                   platformEventIntgLog.Request__c = request;                                  
                                                   platformEventIntgLog.EncryptedRequest__c = encryptedRequest;
                                                   platformEventIntgLog.Response__c = response;
                                                   platformEventIntgLog.EncryptedResponse__c = encryptedResponse;
                                                   platformEventIntgLog.ServiceName__c = serviceName;
                                                   platformEventIntgLog.Elapsed_Time__c = elapseTime;                                  
                                                   intgLogPlatformEventList.add(platformEventIntgLog);
                                                   List<Database.SaveResult> results = EventBus.publish(intgLogPlatformEventList);
                                                   for (Database.SaveResult saveresult : results) {
                                                       if (saveresult.isSuccess()) {
                                                       } else {
                                                           for(Database.Error err : saveresult.getErrors()) {
                                                           }
                                                       }
                                                   }
                                               }
    
    public static void updateIntegrationLogger(String response, String encryptedResponse, String service, String uuid){
        List<Integration_Logger_Event__e> intgLogPlatformEventList = new List<Integration_Logger_Event__e>();
        Integration_Logger_Event__e platformEventIntgLog = new Integration_Logger_Event__e();
        platformEventIntgLog.Response__c = response;
        platformEventIntgLog.EncryptedResponse__c = encryptedResponse;
        platformEventIntgLog.ServiceName__c = service;
        platformEventIntgLog.uidRefId__c = uuid;
        
        intgLogPlatformEventList.add(platformEventIntgLog);
        List<Database.SaveResult> results = EventBus.publish(intgLogPlatformEventList);
        for (Database.SaveResult saveresult : results) {
            if (saveresult.isSuccess()) {
            } else {
                for(Database.Error err : saveresult.getErrors()) {
                }
            }
        }
    }
    
    //Logic not implemented yet-WIP
    //Bhushan  
    public static string parseResponseDOM(HttpResponse response){
        
        Dom.Document doc = response.getBodyDocument();
        Dom.XMLNode address = doc.getRootElement();   
        return '';
    }
    
    /*
* @Method:      parseJSONRequest
* @Created by:  Divya Jawale 
* @Description: Method used to parse the request
* @Param:      String - responseBody
* @Param:      String - className
* @return:     String - RequestWrapper type
*/
    public static RequestWrapper parseJSONRequest(String responseBody, String className){
        RequestWrapper res;
        try{
            JSONParser parser = JSON.createParser(responseBody);
            Type wrapperType = Type.forName(className);
            res = (RequestWrapper)parser.readValueAs(wrapperType);
        }catch(Exception ex){
            ErrorLoggerUtil.logErrorEvent('CalloutProcessor', 'parseJSONRequest', System.Label.Apex, ex);
            throw new CalloutException(ex.getMessage());  
        }
        return res;
    }
    
    /*
* @Method:      getMakerId
* @Created by:  Manish B 
* @Description: Method used return maker Id.
* @return:      String 
*/
    public static String getMakerId(){
        User user = [SELECT Maker_Id__c,User_Id__c FROM User WHERE Id =:userInfo.getUserId()];//CISP-21524
        String userId = user.User_Id__c;
        String[] userIdNum = userId.split('_'); 
        String makerUserId = userIdNum[0].trim();
        return makerUserId;//CISP-21524
    }
    
    
    /*
* @Method:      getCicNo
* @Created by:  Aman Mundhada
* @Description: Method used generate and return cic no.
* @return:      String 
*/
    @AuraEnabled
    public static String getCicNo(){
        
        String cicNo=String.valueOf(Datetime.now().formatGMT('yyyyMMddHHmmss'));
        String randomNumber = String.valueOf(Utilities.generateUniqueNumber(5));
        cicNo = cicNo + randomNumber;
        return cicNo;
    }
    
    /*
* @Method:      handlePayloadResponse
* @Created by:  Santhosh Mothe 
* @Description: Method used to process the response in Async
* @Param:      List - responseBody
* @Param:      String - className
* @return:     String - RequestWrapper type
*/
    public static void handleLowPayloadResponse(AsyncPayloadReponse[] AsyncPayloadReponses){
        try{
        Map<String, AsyncPayloadReponse> refIdRespMap = new Map<String, AsyncPayloadReponse>();
        for(AsyncPayloadReponse asyncPayloadResp : AsyncPayloadReponses){
            refIdRespMap.put(asyncPayloadResp.referenceId, asyncPayloadResp);
        }
        List<Integration_Log__c> intLogList = new List<Integration_Log__c>();
        for(Integration_Log__c iLog : [Select id, Loan_Application__c, Loan_Application__r.Product_Type__c, ReferenceId__c, Original_response__c, Service_Name__c, Encrypted_response__c,EncryptedResponseExt__c,ResponseExt__c  from Integration_Log__c where ReferenceId__c in :refIdRespMap.keySet()]){
          AsyncPayloadReponse asycPayload = refIdRespMap.get(iLog.ReferenceId__c);
            String wholeRes ='';
           if(asycPayload.responseExt != null && !String.isBlank(asycPayload.responseExt)){
              wholeRes = IntegrationUtilities.getPlainTextForLog(asycPayload.response+asycPayload.responseExt);
           }else{
              wholeRes = IntegrationUtilities.getPlainTextForLog(asycPayload.response);//OLA-238
           }
           if(wholeRes.length() <= 131072){
            iLog.Original_response__c  = wholeRes;
           }else if(wholeRes.length() > 131072 && wholeRes.length()<=262144){
            iLog.Original_response__c = wholeRes.substring(0, 131071);
            iLog.ResponseExt__c = wholeRes.substring(131072,262143); 
           }else{
            ErrorLoggerUtil.logErrorEvent('IntegrationUtilities', 'handleLowPayloadResponse', System.Label.Apex, new AuraHandledException('Response string length is too long'));
             }//OLA-238
             iLog.Encrypted_response__c = asycPayload.response;
             iLog.EncryptedResponseExt__c = asycPayload.responseExt;
            if(ilog.Service_Name__c == System.Label.GSTStatus || ilog.Service_Name__c == System.Label.ITRStatus || ilog.Service_Name__c == System.Label.Perfios_BS_Transaction_Status){
                String responseStr = IntegrationUtilities.getPlainTextForLog(wholeRes);
                String searalizedJson = JSON.serializePretty(JSON.deserializeUntyped(responseStr));
                PerfiosStatusAPIResponse apiResponse = (PerfiosStatusAPIResponse) IntegrationUtilities.parseJSONResponse(searalizedJson, 'PerfiosStatusAPIResponse');
                system.debug('searalizedJson '+searalizedJson);
                if(apiResponse.status == 'COMPLETED'){
                    iLog.Status__c = System.Label.Success;
                } else {
                    iLog.Status__c = System.Label.Failure;
                }
            }
            
            intLogList.add(iLog);
            
        }  
            update intLogList;
        }catch(Exception ex){
            ErrorLoggerUtil.logErrorEvent('IntegrationUtilities', 'handlePayloadResponse', System.Label.Apex, ex);
        }
    }
    
    /*
* @Method:      highPayloadResponse
* @Created by:  Santhosh Mothe 
* @Description: Method used to process the response in Async
* @Param:      List - responseBody
* @Param:      AsyncPayloadReponse aSyncPayloadReponse
*/
    public static void highPayloadResponse(AsyncPayloadReponse[] aSyncPayloadReponses){
        Map<String, AsyncPayloadReponse> refIdRespMap = new Map<String, AsyncPayloadReponse>();
        for(AsyncPayloadReponse asyncPayloadResp : aSyncPayloadReponses){
            refIdRespMap.put(asyncPayloadResp.referenceId, asyncPayloadResp);
        }
        List<Integration_Log__c> intLogList = new List<Integration_Log__c>();
        for(Integration_Log__c iLog : [Select id, ReferenceId__c, Original_response__c, ResponseExt__c from Integration_Log__c where ReferenceId__c in :refIdRespMap.keySet()]){
            AsyncPayloadReponse asycPayload = refIdRespMap.get(iLog.ReferenceId__c);
            String wholeResp = IntegrationUtilities.getPlainTextForLog(asycPayload.response+asycPayload.responseExt);
            if(wholeResp.length() <= 131072){
                iLog.Original_response__c = wholeResp; 
            }
            else if(wholeResp.length() > 131072 && wholeResp.length()<=262144){
                iLog.Original_response__c = wholeResp.substring(0, 131071);
                iLog.ResponseExt__c = wholeResp.substring(131072,262143);   
            }
            else{
                ErrorLoggerUtil.logErrorEvent('IntegrationUtilities', 'highPayloadResponse', System.Label.Apex, new AuraHandledException('Response string length is too long'));
                
            }
            
            //iLog.ResponseExt__c = IntegrationUtilities.getPlainTextForLog(asycPayload.responseExt);
            iLog.EncryptedResponseExt__c = asycPayload.responseExt;
            //iLog.Original_response__c = IntegrationUtilities.getPlainTextForLog(asycPayload.response);
            iLog.Encrypted_response__c = asycPayload.response;
            //iLog.Encrypted_response__c = refIdRespMap.get(iLog.ReferenceId__c);
            //iLog.Original_response__c  = IntegrationUtilities.getPlainTextForLog(refIdRespMap.get(iLog.ReferenceId__c));
            //iLog.ResponseExt__c = 
            intLogList.add(iLog);
            //IntegrationUtilities.updateIntegrationLogger(Original_response__c, Encrypted_response__c );
        }  
        
        try{
            update intLogList;
        }catch(Exception ex){
            ErrorLoggerUtil.logErrorEvent('IntegrationUtilities', 'highPayloadResponse', System.Label.Apex, ex);
        }
        
        
        
        
    }
    
    /*
* @Method:      getAPIKeys
* @Created by:  Bhushan Charde 
* @Description: Method used to get keys for encryption and decryption
* @Param:      String
* @Return:     String
*/
    public static String getAPIKeys(String label){
        
        Security_Setting__mdt metadataApi = Security_Setting__mdt.getInstance(System.Label.MasterKey);
        
        if(System.Label.privateKey.equals(label)){
            return metadataApi?.Private_Key__c;
        }
        if(System.Label.ivkey.equals(label)){
            return metadataApi?.IV_Key__c;
        }
        
        return '';
    }
        
   /* public static Map<String,String> callAPI(String encrpteddata, String apiName){ 
        String apikey;
        Map<String,String> compResponse = new  Map<String,String>(); 
         
        
        String endPoint = 'https://ibluatapig.indusind.com/app/uat/cfdlosuat/los/api/GetNeSL_EAgreement';
        try{
            Http http=new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(endPoint);
            
            request.setHeader('Content-Type','application/json');
            request.setHeader('X-IBM-Client-Id','238b67a9-394f-4fa8-8673-195efab1be9a');
            request.setHeader('X-IBM-Client-Secret','hB8jK8vC3fL3xK4wP6fB8oG4hF6tI6tQ2kV5iL2fV4cD3dK4qY');
            request.setBody(encrpteddata);
            request.setMethod('POST');  
            request.setTimeout(120000); 
            //request.setTimeout(1); 
            HttpResponse response = http.send(request);
            
            String status = response.getStatus();
            String statusCode = string.valueof(response.getStatusCode());
            string res = response.getBody();
            String contentType = response.getHeader('Content-Type');
            
            compResponse.put('Status',status); 
            compResponse.put('StatusCode',statusCode);  
            compResponse.put('Response',res);
            compResponse.put('contentKey',contentType);
        }
        catch(exception e){
            ErrorLoggerUtil.logErrorEvent('CalloutProcessor', 'createHttpRequest', System.Label.Apex, e, IntegrationEngine.loanApplicationRef);
            throw new IND_Exception(e.getMessage()); 
              
        }
        return compResponse;
    }
    
 public static Map<String,String> callingAPI(String encrpteddata,String apiName){
        Map<String,String> resBody = IntegrationUtilities.callAPI(encrpteddata,apiName);
        return resBody;
    }*/

    public static String getCoborrowerName(String coBorrowerString){
        return 'Co Borrower';
    }
    
    /*
* @Method:      createContentDocforIntegrationLog
* @Created by:  Santhosh Mothe 
* @Description: Method used to process the req/resp size is more than 1.31Lac characters
* @Param:      String request
* @Param:      String response
* @Param:      String encryptedRequest
* @Param:      String encryptedResponse
* @Param:      String loanApplicationId
* @Param:      String status
*/
    @future
    public static void createContentDocforIntegrationLog(String request, String encryptedRequest,String response, String encryptedResponse,
                                                         String serviceName, String elapseTime, String loanApplicationId, String status){
        
        Integration_Log__c intObj=new Integration_Log__c();
        intObj.Original_request__c = 'Please refer related list for request file';
        intObj.Original_response__c = 'Please refer related list for response file';     
        intObj.Encrypted_request__c = 'Please refer related list for encrypted request file';
        intObj.Encrypted_response__c = 'Please refer related list for encrypted response file';
        intObj.Service_Name__c = serviceName; 
        intObj.Elapsed_Time__c = elapseTime;
        intObj.Loan_Application__c = loanApplicationId; 
        intObj.Status__c = status;
		User usr = [Select Id,Name,IsPortalEnabled,profile.name from User where id=:UserInfo.getUserId()];
        try{                                                     
        
            //Modified by Rohan for DSA
            insert intObj;
                Id netId;                                    
            //String netId = network.getNetworkId();  
            if(usr.profile.name=='DSA Community User'){
                netId = [SELECT Id FROM Network where Name='DSA'].Id; 
            }
            else{
                netId = [SELECT Id FROM Network where Name='IndusDrive'].Id; 
            }  
            // End of DSA Modification                                               
            //Create a new request file
            ContentVersion reqFile = new ContentVersion();
            reqFile.PathOnClient = 'RequestFile.txt';
            reqFile.Title = 'RequestFile';
            if(Limits.getHeapSize() > Limits.getLimitHeapSize()/2){
                reqFile.VersionData = Blob.valueOf('/');
            }
            else{
                reqFile.VersionData = Blob.valueOf(request);
            }
            if(usr.IsPortalEnabled){
                reqFile.NetworkId = netId;
            }       
            insert reqFile;
            
            //Query the contentDocumentId
            ContentVersion insertedReqFile = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =:reqFile.Id];
            
            //Link the file with the IntegrationLog
            ContentDocumentLink linkedReqFile = new ContentDocumentLink(LinkedEntityId=intObj.id, ContentDocumentId=insertedReqFile.ContentDocumentId);
            insert linkedReqFile;

            //Create a new Encryptedrequest file
            ContentVersion encryptedReqFile = new ContentVersion();
            encryptedReqFile.PathOnClient = 'Encrypted_Request_File.txt';
            encryptedReqFile.Title = 'Encrypted Request File';
            encryptedReqFile.VersionData = Blob.valueOf(encryptedRequest);
            if(usr.IsPortalEnabled){
                encryptedReqFile.NetworkId = netId;
            }   
            insert encryptedReqFile;
            
            //Query the contentDocumentId
            ContentVersion insertedEncReqFile = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =:encryptedReqFile.Id];
            
            //Link the file with the IntegrationLog
            ContentDocumentLink linkedEncReqFile = new ContentDocumentLink(LinkedEntityId=intObj.id, ContentDocumentId=insertedEncReqFile.ContentDocumentId);
            insert linkedEncReqFile; 
                                                                 
            //Create a new response file
            if(String.isNotEmpty(response)){
                ContentVersion resFile = new ContentVersion();
                resFile.PathOnClient = 'ResponseFile.txt';
                resFile.Title = 'ResponseFile';
                resFile.VersionData = Blob.valueOf(response);
                if(usr.IsPortalEnabled){
                    resFile.NetworkId = netId;
                }     
                insert resFile;
                
                //Query the contentDocumentId
                ContentVersion insertedResFile = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =:resFile.Id];
                
                //Link the file with the IntegrationLog
                ContentDocumentLink linkedResFile = new ContentDocumentLink(LinkedEntityId=intObj.id, ContentDocumentId=insertedResFile.ContentDocumentId);
                insert linkedResFile;

            }
            if(String.isNotEmpty(encryptedResponse)){
                //Create a new Encryptedresponse file
                ContentVersion encryptedResFile = new ContentVersion();
                encryptedResFile.PathOnClient = 'Encrypted_Response_File.txt';
                encryptedResFile.Title = 'Encrypted Response File';
                encryptedResFile.VersionData = Blob.valueOf(encryptedResponse);
                if(usr.IsPortalEnabled){
                    encryptedResFile.NetworkId = netId;
                }   
                insert encryptedResFile;
                
                //Query the contentDocumentId
                ContentVersion insertedEncResFile = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =:encryptedResFile.Id];
                
                //Link the file with the IntegrationLog
                ContentDocumentLink linkedEncResFile = new ContentDocumentLink(LinkedEntityId=intObj.id, ContentDocumentId=insertedEncResFile.ContentDocumentId);
                insert linkedEncResFile;
            }
            
        }
        Catch(Exception e){
            system.debug('error line at:'+e.getLineNumber());
            system.debug('error message at:'+e.getMessage());
            ErrorLoggerUtil.logErrorEvent('IntegrationUtilities', 'createContentDocforIntegrationLog', System.Label.Apex, e, loanApplicationId);
            throw new IND_Exception(System.Label.NoResponse);
        }

    }
   	
    //CISP-3080
    @AuraEnabled 
    public static void saveImagetoSF(String base64Imag, String documentId, String tknNo){
        try{
            if(String.isEmpty(base64Imag) || String.isEmpty(documentId) || String.isEmpty(tknNo)){
                throw new IND_Exception('Kindly re-try.');
            }
            System.debug('base64Imag ' + base64Imag);
            User usr = [Select Id,Name,IsPortalEnabled from User where id=:UserInfo.getUserId()];
            Id netId = [SELECT Id FROM Network LIMIT 1].Id;
            
            List<Documents__c> updateDocsList1 = new List<Documents__c>();
            List<Documents__c> docList = [Select id, ContentVersionId__c FROM Documents__c WHERE id =: documentId LIMIT 1];
            String permameters = 'base64Imag :: ' + base64Imag + ' | documentId :: ' + documentId + ' | tknNo :: ' + tknNo;

            if(docList.size()>0){
                System.debug('documentId '+ documentId);
                ContentVersion conVer = new ContentVersion();
                conVer.ContentLocation = 'S';
                conVer.Document_Side_fileupload__c = 'Front';
                conVer.Title = 'Front'+'_'+'Aadhaar'+'_'+DateTime.now().millisecond()+'.JPEG';
                conVer.VersionData = EncodingUtil.base64Decode(base64Imag);
                conVer.PathOnClient = 'Front'+'_'+'Aadhaar'+'_'+DateTime.now().millisecond()+'.JPEG';
                if(usr.IsPortalEnabled){
                    conVer.NetworkId = netId;    
                }
                insert conVer; 
                
                docList[0].ContentVersionId__c = conVer.Id;
                if(!String.isBlank(tknNo)){
                    docList[0].IND_Aadhaar_Vault_Token_ID__c = tknNo;
                }
                updateDocsList1.add(docList[0]);
                update updateDocsList1;
                
                Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:conVer.Id].ContentDocumentId;
                
                ContentDocumentLink conDocLink = New ContentDocumentLink();
                conDocLink.LinkedEntityId = documentId;
                conDocLink.ContentDocumentId = conDoc;
                conDocLink.shareType = 'V';
                insert conDocLink;
            }else{
                throw new IND_Exception('Kindly re-try.');
            }
            String insertionResult = docList.size() > 0 ? JSON.serialize(docList[0]) : '';
            IntegrationUtilities.createIntegrationLogger(insertionResult, '', permameters, '', 'saveImagetoSF', '0',null,System.Label.Success);
        }Catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('IntegrationUtilities', 'saveImagetoSF', System.Label.Apex, e);
            throw new IND_Exception(e.getMessage());
        }
    }
      //CISP-3039
      @AuraEnabled
    public static void saveTKNID(String documentId, String tknNo){
        try{
            List<Documents__c> docList = [Select id,IND_Aadhaar_Vault_Token_ID__c FROM Documents__c WHERE id =: documentId LIMIT 1];
            if(docList.size()>0){
                docList[0].IND_Aadhaar_Vault_Token_ID__c = tknNo;
            }
            update docList;
        }catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('IntegrationUtilities', 'saveTKNID', System.Label.Apex, e);
            throw new IND_Exception(e.getMessage());
        }
    }
    
//to calculate IRR value
    public static double calculateIRR(List<Double> cashFlows) {
        system.debug('++++ Entering calculateIRR method');
        Double guess = 0.1; // Initial guess for IRR
        Double x0 = 0.0;
        Double x1 = guess;
        // Maximum number of iterations
        Integer maxIterations = 100;
        Integer iterations = 0;
        Double epsilon = 0.00001; // Error tolerance
        while (Math.abs(x1 - x0) > epsilon && iterations < maxIterations) {
            x0 = x1;
            x1 = x0 - calculateNPV(cashFlows, x0) / calculateDerivative(cashFlows, x0);
            iterations++;
        }
        system.debug('++++ Exist calculateIRR method');
        system.debug('++++x1 '+x1);
        return x1;
    }
    
    private static Double calculateNPV(List<Double> cashFlows, Double rate) {
        Double npv = 0.0;
        Integer n = cashFlows.size();
        for (Integer i = 0; i < n; i++) {
            npv += cashFlows[i] / Math.pow((1 + rate), i);
        }
        system.debug('++++ npv '+npv);
        return npv;
    }
    
    private static Double calculateDerivative(List<Double> cashFlows, Double rate) {
        Double derivative = 0.0;
        Integer n = cashFlows.size();
        for (Integer i = 1; i < n; i++) {
            derivative -= i * cashFlows[i] / Math.pow((1 + rate), i + 1);
        }
        system.debug('++++ derivative '+derivative);
        return derivative;
    }
    
}