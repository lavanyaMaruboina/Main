/*------------------------------------------------------------
Author: Aman Mundhada
Company: Persistent Systems
Description: This class is wrapper class for the Driving License Request
Test Class: IND_DrivingLicenseService_Test
History
Date            Author              Comments
------------------------------------------------------------- 
10-11-2021    Aman Mundhada           Created
------------------------------------------------------------*/


public class IND_DrivingLicenseRequest extends ParentAPIRequest {
    //request paramaters for Driving License request
    public final String Lead_Id {get;set;}
    public final String DateOfBirth{get;set;}
    public final String Identify_IdNumber{get;set;}
    public final String Identify_IdType{get;set;}
    public final String Maker_Id{get;set;}
    
   	//constructor
    // @Method:      IND_DrivingLicenseRequest
    // @Created by:  Aman Mundhada
    // @Description: Contructor to initialize the details
    // @Param:       Object Request Wrapper
    // @Return:      ''    
    public IND_DrivingLicenseRequest(RequestWrapper requestWrapper){
        if( requestWrapper != null){
            this.Lead_Id = requestWrapper.leadId==null?'':requestWrapper.leadId; 
            this.DateOfBirth= requestWrapper.dateOfBirth==null?'':requestWrapper.dateOfBirth;
            this.Identify_IdNumber = requestWrapper.dlNumber==null?'':requestWrapper.dlNumber;  
            this.Identify_IdType = System.label.DrivingLicenceIdType;             
            this.Maker_Id=IntegrationUtilities.getMakerId();
        }
        validate(System.Label.Driving_License);
    }
    
    //Method to get the HTTP request header data
    // @Method:      getHttpRequestHeaders
    // @Created by:  Aman Mundhada
    // @Description: Method to get the HTTP request header data
    // @Param:       ''
    // @Return:      Header required to callout the service.   
    Public override Map<String,String> getHttpRequestHeaders(){
        //Map to store HTTP request header data
     Map<String,String> requestHeaderMap = Utilities.getHeaders();
        return requestHeaderMap;
    }
    
    //Method to validate the request data
    // @Method:      validate
    // @Created by:  Aman Mundhada
    // @Description: Method to validate the required input details
    // @Param:       Service name
    // @Return:      True - If all the validations are passed.    
    public override boolean validate(String serviceName){
        if(String.isBlank(this.Lead_Id)){
            throw new IND_Exception(System.Label.LeadId);
        }
        
        if(String.isBlank(this.DateOfBirth)){
            throw new IND_Exception(System.Label.DateOfBirth);
        }
        
        if(String.isBlank(this.Identify_IdNumber)){
            throw new IND_Exception(System.Label.DrivingLicenseNumber);
        }
        
        if(String.isBlank(this.Identify_IdType)){
            throw new IND_Exception(System.Label.IdType);
        }
        
        if(String.isBlank(this.Maker_Id)){
            throw new IND_Exception(System.Label.MakerId);
        }        
        return true;
    }
    
}