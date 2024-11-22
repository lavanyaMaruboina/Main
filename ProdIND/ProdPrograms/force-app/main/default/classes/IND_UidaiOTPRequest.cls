/*------------------------------------------------------------
Author:        Bhushan Charde
Company:       Persistent Systems
Description:   This class is wrapper class for the UIDAI OTP API request 
Test Class:     
History
Date            Author              Comments
-------------------------------------------------------------
12-29-2021      Bhushan Charde       Created
------------------------------------------------------------*/
public class IND_UidaiOTPRequest extends ParentAPIRequest{
    
    public final string LeadId  {get;set;}
    public final string MakerId {get;set;}
    public final string UId 	{get;set;}
    
    // @Method:      IND_UidaiOTPRequest
    // @Created by:  Bhushan Charde
    // @Description: Contructor to initialize the details
    // @Param:       Object applicant Record
    // @Return:      ''
    public IND_UidaiOTPRequest(RequestWrapper requestWrapper){
        if(requestWrapper != null){
            this.LeadId = requestWrapper.leadId; 
		    this.MakerId = IntegrationUtilities.getMakerId();
		    this.UId = requestWrapper.aadhaarNo;
        }
        validate(System.Label.UIDAIOTPAPI);
    }
    
    // @Method:      validate
    // @Created by:  Bhushan Charde
    // @Description: Method to validate the required input details
    // @Param:       Service name
    // @Return:      True - If all the validations are passed.
    public override boolean validate(String serviceName){

        if(string.isBlank(this.MakerId)){
            throw new IND_Exception(System.Label.Maker_IdError);
        }
        if(string.isBlank(this.UId)){
            throw new IND_Exception(System.Label.UIDAIAadhaar_ERR);
        }
        return true;
    }
    
    public override String xmlConvertedRequest(){
        String xmlrequestBody = prepareRequest();
        return xmlrequestBody;
    }
  	
    // @Method:      prepareRequest
    // @Created by:  Bhushan Charde
    // @Description: Method to validate the required input details
    // @Return:      xml request
    private String prepareRequest(){
        String request ='<GenerateOTP>';
        request+='<LeadId>'+this.LeadId+'</LeadId>';
        request+='<MakerId>'+this.MakerId+'</MakerId>';
        request+='<UId>'+this.UId+'</UId>';
        request+= '</GenerateOTP>';
        return request;
    }
    
    // @Method:      getHttpRequestHeaders
    // @Created by:  Bhushan Charde
    // @Description: Method to get the HTTP request header data
    // @Param:       ''
    // @Return:      Header required to callout the service.
    public override Map<String,String> getHttpRequestHeaders(){
        Map<String,String> requestHeaderMap = Utilities.getHeaders();
        return requestHeaderMap;
    }
    
}