/*------------------------------------------------------------
Author: Bhushan Charde 
Company: Persistent Systems
Description: This class is wrapper class for the ENACH Registration Journey Request
Test Class: 
History
Date            Author              Comments
------------------------------------------------------------- 
12-28-2021    Bhushan Charde            Created
------------------------------------------------------------*/
public class IND_ENACHRegistrationStatusRequest extends ParentAPIRequest {
	
    public String session{get;set;}
    public String api_action{get;set;}
    
    public IND_ENACHRegistrationStatusRequest(RequestWrapper requestWrapper){
        if(requestWrapper != null){
            this.session = requestWrapper.enachStatus;
            this.api_action = 'checkResultsession';
        }
        validate(System.Label.RegistrationStatus);
    }
    
    // @Method:      validate
    // @Created by:  Bhushan Charde
    // @Description: Method to validate the required input details
    // @Param:       Service name
    // @Return:      True - If all the validations are passed.
    public override boolean validate(String serviceName){
        if(String.isBlank(this.session)){
            ErrorLoggerUtil.logErrorEvent('IND_ENACHRegistrationStatusRequest', 'validate', System.Label.Apex, new AuraHandledException('Please Enter Session'));
            throw new AuraHandledException('Please Enter Session');
        }
        if(String.isBlank(this.api_action)){
            ErrorLoggerUtil.logErrorEvent('IND_ENACHRegistrationStatusRequest', 'validate', System.Label.Apex, new AuraHandledException('Please Enter API Action'));
            throw new AuraHandledException('Please Enter API Action');
        }
        return true;
    }
    
    // @Method:      getHttpRequestHeaders
    // @Created by:  Bhushan Charde
    // @Description: Method to get the HTTP request header data
    // @Param:       ''
    // @Return:      Header required to callout the service.
    public override Map<String,String> getHttpRequestHeaders(){
        Map<String,String> requestHeaderMap = new Map<String,String>();
        requestHeaderMap.put(IntegrationConstants.CONTENT_TYPE , IntegrationConstants.CONTENT_TYPE_JSON);
        requestHeaderMap.put('IBL-Client-Id', System.Label.IBM_Client_ID);
        requestHeaderMap.put('IBL-Client-Secret', System.Label.IBM_Client_Secret);
        return requestHeaderMap;
    }
}