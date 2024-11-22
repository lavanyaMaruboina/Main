/*------------------------------------------------------------
Author: Satyam More
Company: Persistent Systems
Description: This class is wrapper class for the Vahan Vehicle Report Request
Test Class: 
History
Date            Author              Comments
------------------------------------------------------------- 
04-01-2022    Satyam More            Created
------------------------------------------------------------*/

public class IND_VahanVehicleReportRequest extends ParentAPIRequest {
    //request paramaters for Email Service request
    public final String Lead_Id{get;set;}
    public final String Veh_Reg_No{get;set;}
    
    //constructor
    // @Method:      IND_VahanVehicleReportRequest
    // @Created by:  Satyam More
    // @Description: Contructor to initialize the details
    // @Param:       Object Request Wrapper
    // @Return:      ''
    // 
    public IND_VahanVehicleReportRequest(RequestWrapper requestWrapper, String loanAppId){
        if( requestWrapper != null){
            this.Lead_Id = requestWrapper.leadId;
            this.Veh_Reg_No =requestWrapper.vehicleRegisterationNumber ; 
        }
        validate(System.Label.VahanReport);
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
    // @Method:      getHttpRequestHeaders
    // @Created by:  Satyam More
    // @Description: Method to validate the required input details
    // @Param:       Service name
    // @Return:      True - If all the validations are passed.
    
    public override boolean validate(String serviceName){
        if(String.isBlank(this.Lead_Id)){
            throw new IND_Exception(System.Label.LeadId);
        }
        if(String.isBlank(this.Veh_Reg_No)){
            throw new IND_Exception(System.Label.VehicleRegistrationNumber);            
        }
        return true;
    }
}