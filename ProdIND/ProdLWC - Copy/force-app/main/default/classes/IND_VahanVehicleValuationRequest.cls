/*------------------------------------------------------------
Author: Satyam More
Company: Persistent Systems
Description: This class is wrapper class for the Vahan Vehicle Valuation request
Test Class: 
History
Date            Author              Comments
------------------------------------------------------------- 
20-12-2021    Satyam More            Created
------------------------------------------------------------*/

public class IND_VahanVehicleValuationRequest extends ParentAPIRequest {
//request paramaters for Vahan Vehicle Valuation request
    Public final VahanDetails VahanDetails {get;set;}
    Public class VahanDetails{
    public final String Lead_Id{get;set;}
    public final String Registration_No{get;set;}
    public final String Maker_ID{get;set;}   
    }
   
    //constructor
    // @Method:      IND_VahanVehicleValuationRequest
    // @Created by:  Satyam More
    // @Description: Contructor to initialize the details
    // @Param:       Object Request Wrapper
    // @Return:      ''
    
    public IND_VahanVehicleValuationRequest(RequestWrapper requestWrapper, String loanAppId){
        System.debug('requestWrapper'+ requestWrapper);
        if( requestWrapper != null){
            this.VahanDetails = new VahanDetails();
            this.VahanDetails.Lead_Id = requestWrapper.leadId==null?'':requestWrapper.leadId;    
            this.VahanDetails.Registration_No = requestWrapper.vehicleRegisterationNumber==null?'':requestWrapper.vehicleRegisterationNumber ; 
            this.VahanDetails.Maker_ID = IntegrationUtilities.getMakerId();
        }
        validate(System.Label.VahanVehicleValuationAPI);
    }
    
    //Method to get the HTTP request header data
    // @Method:      getHttpRequestHeaders
    // @Created by:  Satyam More
    // @Description: Method to get the HTTP request header data
    // @Param:       ''
    // @Return:      Header required to callout the service.
    
    public override Map<String,String> getHttpRequestHeaders(){    
        Map<String,String> requestHeaderMap = Utilities.getHeaders();
        return requestHeaderMap;
    }
    
    //Method to validate the request data
    // @Method:      validate
    // @Created by:  Satyam More
    // @Description: Method to validate the required input details
    // @Param:       Service name
    // @Return:      True - If all the validations are passed.
    
    public override boolean validate(String serviceName){
        if(String.isBlank(this.VahanDetails.Lead_Id)){
            throw new IND_Exception(System.Label.LeadId);
        }
        if(String.isBlank(this.VahanDetails.Registration_No)){
            throw new IND_Exception(System.Label.VehicleRegistrationNumber);            
        }
        if(String.isBlank(this.VahanDetails.Maker_ID)){
            throw new IND_Exception(System.Label.MakerId);    
        }
        return true;
    }
    
    
}