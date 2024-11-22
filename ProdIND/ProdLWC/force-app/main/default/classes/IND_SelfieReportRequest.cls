/*------------------------------------------------------------
Author: Santhosh Mothe
Company: Persistent Systems
Description: This class is wrapper class for the Selfie Report Request
Test Class:
History
Date Author Comments
-------------------------------------------------------------
19-11-2021 Santhosh Mothe Created
------------------------------------------------------------*/



public class IND_SelfieReportRequest extends ParentAPIRequest {
    //request paramaters for Selfie Report request
    public String appId{get;set;}
    
    /*
    * @Method Name: Constructor
    * @Created by: Santhosh Mothe.
    * @Description: create the selfieReportrequest
    * @Param: Applicant
    * @Return: void
    */
    public IND_SelfieReportRequest(String applicationId){
    if( applicationId != null){
    Applicant__c app = [SELECT Id, DocAuth_Application_Id__c FROM Applicant__c where id = :applicationId WITH SECURITY_ENFORCED];
    this.appId = app.DocAuth_Application_Id__c;
    }
    validate(System.Label.Selfie_Report);
    }
    
    
    /*
    * @Method Name: getHttpRequestHeaders
    * @Created by: Santhosh Mothe.
    * @Description: Method to get the HTTP request header data
    * @Return: Map
    */
    public override Map<String,String> getHttpRequestHeaders(){
    //Map to store HTTP request header data
    Map<String,String> requestHeaderMap = new Map<String,String>();
    requestHeaderMap.put(IntegrationConstants.CONTENT_TYPE , IntegrationConstants.CONTENT_TYPE_JSON);
    requestHeaderMap.put('IBL-Client-Id', System.Label.IBM_Client_ID);
    requestHeaderMap.put('IBL-Client-Secret', System.Label.IBM_Client_Secret);
    return requestHeaderMap;
    //requestheadermap is used to fetch the request from client
    }
    
    //
    /*
    * @Method Name: Constructor
    * @Created by: Santhosh Mothe.
    * @Description: Method to validate the request data
    * @Param: String serviceName
    * @Return: boolean
    */
    public override boolean validate(String serviceName){
    List<String> errorMessageList = new List<String>();
    
    if(String.isBlank(this.appId)){
    ErrorLoggerUtil.logErrorEvent('IND_SelfieReportRequest', 'validate', System.Label.Apex, new AuraHandledException(System.Label.AppId));
    throw new AuraHandledException(System.Label.AppId);
    }
    
    return true;
    }
    
    }