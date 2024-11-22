/*------------------------------------------------------------
Author:        Bhushan Charde
Company:       Persistent Systems
Description:   This class is wrapper class for the Perfios GST Online API request 
Test Class:     
History
Date            Author              Comments
-------------------------------------------------------------
12-19-2021      Bhushan Charde       Created
------------------------------------------------------------*/
public class IND_PerfiosGSTOnlineRequest extends ParentAPIRequest {
	
    public List<string> gstNumberList = new List<string>();
    public final string Type 		 {get;set;}
    public final string Lead_Id 	 {get;set;}
    public final string Maker_Id 	 {get;set;}
    public final string MobileNumber {get;set;}
    public final string productType  {get;set;}
    public final string Source       {get;set;}
    
    // @Method:      IND_PerfiosGSTOnlineRequest
    // @Created by:  Bhushan Charde
    // @Description: Contructor to initialize the details
    // @Param:       Object applicant Record
    // @Return:      ''
    public IND_PerfiosGSTOnlineRequest(RequestWrapper requestWrapper){  
        if(requestWrapper != null){     
            this.gstNumberList.add(requestWrapper.GstNumber);   
            this.Type = requestWrapper.gstType;
            this.Maker_Id = IntegrationUtilities.getMakerId() == null ? '': IntegrationUtilities.getMakerId();
            this.Lead_Id = requestWrapper.leadId;	
            this.MobileNumber = requestWrapper.contactNumber;
            this.productType = 'summary';
            this.Source = 'Salesforce';
        }
        validate(System.Label.GSTOnline);
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
        
        if(this.gstNumberList.isEmpty()){
            throw new IND_Exception(System.Label.GstNumberError);
        }
        if(String.isBlank(this.Type)){
            throw new IND_Exception(System.Label.GstTypeError);
        }
        
        if(String.isBlank(this.MobileNumber)){
            throw new IND_Exception(System.Label.MobileNumber_Error);
        }         
        return true;
    }
}