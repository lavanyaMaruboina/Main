/*------------------------------------------------------------
Author:        Bhushan Charde
Company:       Persistent Systems
Description:   This class is wrapper class for the Perfios ITR Online API request 
Test Class:     
History
Date            Author              Comments
-------------------------------------------------------------
12-21-2021      Bhushan Charde       Created
------------------------------------------------------------*/
public class IND_PerfiosITROnlineRequest extends ParentAPIRequest {
	
    public final string pan 		 {get;set;}
    public final string dob 		 {get;set;}
    public boolean scanned 			 {get;set;}
    public final string type 		 {get;set;}
    public final string Lead_Id 	 {get;set;}
    public final string Maker_Id 	 {get;set;}
    public final string MobileNumber {get;set;}
    public final string Source       {get;set;}
    
    
    // @Method:      IND_PerfiosITROnlineRequest
    // @Created by:  Bhushan Charde
    // @Description: Contructor to initialize the details
    // @Param:       Object applicant Record
    // @Return:      ''
    public IND_PerfiosITROnlineRequest(RequestWrapper requestWrapper){  
        if(requestWrapper != null){
            this.pan = requestWrapper.panNumber;
            this.dob = String.valueOf(requestWrapper.kycDOB);
            this.scanned = false;
            this.type = requestWrapper.itrType;
            this.Lead_Id = requestWrapper.leadId;
            this.Maker_Id = IntegrationUtilities.getMakerId();
            this.MobileNumber = requestWrapper.contactNumber;
            this.Source = 'Salesforce';
        }   
        validate(System.Label.ITROnline);
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
    
    // @Method:      validate
    // @Created by:  Bhushan Charde
    // @Description: Method to validate the required input details
    // @Param:       Service name
    // @Return:      True - If all the validations are passed.
   
    public override boolean validate(String serviceName){
        
        if(String.isBlank(this.pan)){
            throw new IND_Exception(System.Label.PAN_Number);
        }
        if(String.isBlank(this.dob)){
            throw new IND_Exception(System.Label.DateOfBirth);
        }
        if(String.isBlank(this.type)){
            throw new IND_Exception(System.Label.PanTypeError);
        }
        
        if(String.isBlank(this.MobileNumber)){
            throw new IND_Exception(System.Label.MobileNumber_Error);
        }
        
        return true;
    }
}