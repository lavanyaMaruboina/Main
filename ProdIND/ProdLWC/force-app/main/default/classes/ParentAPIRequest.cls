/*
* @Author	: Sharad Kathane
* Version 	: Initial
* Date		: 08-10-2021	
* Description:  Base class for all HTTP API request
*/
public with sharing abstract class ParentAPIRequest {
    
    /*To convert the object to json format*/
    public String convertToJSON(){
        return JSON.serialize(this);
    }
    
    public String convertToNullEscapeJson(){
        return JSON.serialize(this, true);
    }
    
    /*Method to be implemented by all the requests to validate the service and request data*/
    //Add all the mandatory request parameters in the list to validate the request
    public virtual Boolean validate(String serviceName){return true;}
    public virtual Boolean validateTractor(String serviceName){return true;}
    public virtual Boolean validate(String serviceName,String oppProductType){return true;} //SFTRAC-629
    public virtual Boolean validate(){
        return true;
    }
    public virtual Boolean validate(String serviceName,Boolean isImplement){
        return true;
    }
    
    
    /*Method to populate Http request header data, It can be overriden for setting specific header data*/
    public virtual Map<String,String> getHttpRequestHeaders(){
        Map<String,String> requestHeaderMap = new Map<String,String>();
        requestHeaderMap.put(IntegrationConstants.CONTENT_TYPE,IntegrationConstants.CONTENT_TYPE_JSON);
        return requestHeaderMap;
    }
    
    /*To return XML generated request*/
    public virtual String xmlConvertedRequest(){
        return '';
    }
    
}