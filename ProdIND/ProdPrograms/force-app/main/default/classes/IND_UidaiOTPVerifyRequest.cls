/*------------------------------------------------------------
Author:        Bhushan Charde
Company:       Persistent Systems
Description:   This class contains methods related to UIDAI OTP Verify Request Class.
Inputs:        None 
Test Class:     
History
Date            Author              Comments
-------------------------------------------------------------
9-12-2021      Bhushan Charde       Created
9-30-2021      Bhushan Charde       Modified - Request params changed
------------------------------------------------------------*/
public class IND_UidaiOTPVerifyRequest extends ParentAPIRequest{
    
	public final string LeadId  {get;set;}
    public final string MakerId {get;set;}
    public final string UId 	  {get;set;}
    public final string otp 	  {get;set;}
    public final string txn 	  {get;set;}
    public final string rrn 	  {get;set;}
    
    // @Method:      IND_UidaiOTPVerifyRequest
    // @Created by:  Bhushan Charde
    // @Description: Contructor to initialize the details
    // @Param:       Object applicant Record
    // @Return:  
    public IND_UidaiOTPVerifyRequest(RequestWrapper requestWrapper){
      if( requestWrapper != null){
		this.LeadId = requestWrapper.leadId; 
		this.MakerId = IntegrationUtilities.getMakerId();
		this.UId = requestWrapper.uid;
        this.otp = requestWrapper.otp;
        this.txn = requestWrapper.txn;
        this.rrn = requestWrapper.rnn;
      }
        validate(System.Label.UIDAIOTPVERIFY);
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
        String request ='<VerifyOTP>';
        request+='<LeadId>'+this.LeadId+'</LeadId>';
        request+='<MakerId>'+this.MakerId+'</MakerId>';
        request+='<UId>'+this.UId+'</UId>';
        request+='<OTP>'+this.otp+'</OTP>';
        request+='<TXN>'+this.txn+'</TXN>';
        request+='<RRN>'+this.rrn+'</RRN>';
        request+= '</VerifyOTP>';
        return request;
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
        if(string.isBlank(this.otp)){
            throw new IND_Exception(System.Label.UIDAIOTP_ERR);
        }
        if(string.isBlank(this.UId)){
            throw new IND_Exception(System.Label.UIDAIAadhaar_ERR);
        }
        if(string.isBlank(this.txn)){
            throw new IND_Exception(System.Label.UIDAITXN_ERR);
        }
        if(string.isBlank(this.rrn)){
            throw new IND_Exception(System.Label.UIDAIRRN_ERR);
        }
        return true;
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