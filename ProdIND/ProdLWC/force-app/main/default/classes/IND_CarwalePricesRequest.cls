/*------------------------------------------------------------
Author: Satyam More
Company: Persistent Systems
Description: This class is wrapper class for the CarWale Prices request
Test Class: IND_CarwalePricesService_Test
History
Date            Author              Comments
------------------------------------------------------------- 
21-12-2021    Satyam More            Created
------------------------------------------------------------*/

public class IND_CarwalePricesRequest extends ParentAPIRequest {
//request paramaters for CarWale Prices request
    public final String VehicleType{get;set;}
    public final String CityId{get;set;}
    public final String VariantCode{get;set;}
    public final String Lead_Id{get;set;}
    public final String Maker_Id{get;set;}
    
    //constructor
    // @Method:      IND_CarwalePricesRequest
    // @Created by:  Satyam More
    // @Description: Contructor to initialize the details
    // @Param:       Object Request Wrapper
    // @Return:      ''
    // 
    public IND_CarwalePricesRequest(RequestWrapper requestWrapper, String loanAppId){
        if( requestWrapper != null){
            this.VehicleType = requestWrapper.vehicleType==null?'':requestWrapper.vehicleType; 
            this.CityId = requestWrapper.CityId==null?'':requestWrapper.CityId;
            this.VariantCode = requestWrapper.VariantCode==null?'':requestWrapper.VariantCode; 
            this.Lead_Id = requestWrapper.leadId==null?'':requestWrapper.leadId;     
            this.Maker_ID = IntegrationUtilities.getMakerId();
        }
        validate(System.Label.CarWalePrices);
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
        if(String.isBlank(this.VehicleType)){
            throw new IND_Exception(System.Label.VehicleType);            
        }
        if(String.isBlank(this.CityId)){
            throw new IND_Exception(System.Label.CityId);            
        }
        if(String.isBlank(this.VariantCode)){
            throw new IND_Exception(System.Label.VarientCode);            
        }
        if(String.isBlank(this.Lead_Id)){
            throw new IND_Exception(System.Label.LeadId);
        }
        if(String.isBlank(this.Maker_ID)){
            throw new IND_Exception(System.Label.MakerId);    
        }
        return true;
    }
}