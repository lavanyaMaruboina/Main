/*------------------------------------------------------------
Author: Satyam More
Company: Persistent Systems
Description: This class is wrapper class for the DocAuth Document Report Request
Test Class: 
History
Date            Author              Comments
------------------------------------------------------------- 
19-11-2021    Satyam More            Created
------------------------------------------------------------*/

public class IND_DocAuthDocumentReportRequest extends ParentAPIRequest {
    //request paramaters for Document Report request
    public String Maker_Id{get;set;}
    public String appId{get;set;}
    
    /*
* @Method Name: Constructor
* @Created by: 	Santhosh Mothe.
* @Description: create the docAuthReportrequest
* @Param:       Applicant 
* @Return:      void
*/
    public IND_DocAuthDocumentReportRequest(String applicationId){
        if( applicationId != null){
            this.Maker_Id = IntegrationUtilities.getMakerId(); //'100001';
            Applicant__c app = [SELECT Id, DocAuth_Application_Id__c FROM Applicant__c where id = :applicationId WITH SECURITY_ENFORCED];
            this.appId = app.DocAuth_Application_Id__c;
            //this.appId = '22545999';
            //fetching details from Applicant Object
        }
        validate(System.Label.DocumentReport);
    }
    
    
    /*
* @Method Name: getHttpRequestHeaders
* @Created by: 	Santhosh Mothe.
* @Description: Method to get the HTTP request header data
* @Return:      Map
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
* @Created by: 	Santhosh Mothe.
* @Description: Method to validate the request data
* @Param:       String serviceName 
* @Return:      boolean
*/
    public override boolean validate(String serviceName){
        List<String> errorMessageList = new List<String>();
        if(String.isBlank(this.Maker_Id)){
            ErrorLoggerUtil.logErrorEvent('IND_DocAuthDocumentReportRequest', 'validate', System.Label.Apex, new AuraHandledException(System.Label.MakerId));
            throw new AuraHandledException(System.Label.MakerId);
        }
        if(String.isBlank(this.appId)){
            ErrorLoggerUtil.logErrorEvent('IND_DocAuthDocumentReportRequest', 'validate', System.Label.Apex, new AuraHandledException(System.Label.AppId));
            throw new AuraHandledException(System.Label.AppId);
        }
        
        return true;
    }
    
}