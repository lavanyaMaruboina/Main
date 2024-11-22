/*------------------------------------------------------------
Author: Satyam More
Company: Persistent Systems
Description: This class is wrapper class for the Email Service Request
Test Class: 
History
Date            Author              Comments
------------------------------------------------------------- 
03-01-2022    Satyam More            Created
------------------------------------------------------------*/

public class IND_EmailServiceRequest extends ParentAPIRequest {
    //request paramaters for Email Service request
    public final String Lead_Id{get;set;}
    public final String EMail_To{get;set;}
    public final String EMail_CC{get;set;}
    public final String EMail_Subject{get;set;}
    public final String EMail_Body{get;set;}
    public final String Maker_Id{get;set;}
    public final String flag{get;set;} // Added for OLA-204 to by pass Maker Id  
    
    //constructor
    // @Method:      IND_EmailServiceRequest
    // @Created by:  Satyam More
    // @Description: Contructor to initialize the details
    // @Param:       Object Request Wrapper
    // @Return:      ''
    // 
    public IND_EmailServiceRequest(RequestWrapper requestWrapper){
        if( requestWrapper != null){
            this.Lead_Id = requestWrapper.leadId==null?'':requestWrapper.leadId;
            this.EMail_To = requestWrapper.emailTo==null?'':requestWrapper.emailTo ; 
            this.EMail_CC = requestWrapper.emailCC==null?'':requestWrapper.emailCC ;
            this.EMail_Subject = requestWrapper.emailSubject==null?'':requestWrapper.emailSubject;
            this.EMail_Body = requestWrapper.emailBody==null?'':requestWrapper.emailBody ;
            /*For OLA-204 to by pass Maker Id - Start*/ 
            this.flag = requestWrapper.flag == null? '' : requestWrapper.flag;
            system.debug('this.flag>> '+this.flag);
            if(String.isBlank(this.flag) || this.flag != 'cutomer_intimation'){
            this.Maker_Id = IntegrationUtilities.getMakerId() ;
            }
            /*For OLA-204 to by pass Maker Id - End*/ 
        }
        validate(System.Label.EmailService);
    }
    
    //Method to get the HTTP request header data
    // @Method:      getHttpRequestHeaders
    // @Created by:  Satyam More
    // @Description: Method to get the HTTP request header data
    // @Param:       ''
    // @Return:      Header required to callout the service.
    
    public override Map<String,String> getHttpRequestHeaders(){
        //Map to store HTTP request header data
        Map<String,String> requestHeaderMap = new Map<String,String>();
        requestHeaderMap.put(IntegrationConstants.CONTENT_TYPE , IntegrationConstants.CONTENT_TYPE_JSON);
        requestHeaderMap.put('IBL-Client-Id', System.Label.IBM_Client_ID);
        requestHeaderMap.put('IBL-Client-Secret', System.Label.IBM_Client_Secret);
        return requestHeaderMap;
    }
    
    //Method to validate the request data
    // @Method:      getHttpRequestHeaders
    // @Created by:  Satyam More
    // @Description: Method to validate the required input details
    // @Param:       Service name
    // @Return:      True - If all the validations are passed.
    
    public override boolean validate(String serviceName){
        if(String.isBlank(this.Lead_Id)){
            throw new IND_Exception(System.Label.LeadId);
        }
        if(String.isBlank(this.EMail_To)){
            throw new IND_Exception(System.Label.Email);            
        }
        if(String.isBlank(this.EMail_CC)){
            throw new IND_Exception(System.Label.Email);    
        }
        if(String.isBlank(this.EMail_Subject)){
            throw new IND_Exception(System.Label.EmailSubject);
        } 
        if(String.isBlank(this.EMail_Body)){
            throw new IND_Exception(System.Label.EmailBody);
        } 
        if(String.isBlank(this.Maker_Id) && this.flag != 'cutomer_intimation'){ // Added exception for cutomer_intimation emails, OLA-204  
            throw new IND_Exception(System.Label.MakerId);
        } 
        return true;
    }
}