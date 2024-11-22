/*------------------------------------------------------------
Author:        Aman Mundhada
Company:       Salesforce
Description:   This class is request class for the IBB Master Request 
Test Class:    IND_IbbMasterServiceTest
History
Date            Author              Comments
-------------------------------------------------------------
16-12-2021      Aman Mundhada       Created
------------------------------------------------------------*/

public class IND_IbbMasterRequest extends ParentAPIRequest {
    //request paramaters for IBB Master Request
 
    public final String application_no{get;set;}
    public final String vehicle_id {get;set;}  
    public final String year{get;set;}
    public final String month {get;set;}  
    public final String product_variant{get;set;}
    public final String state_code {get;set;}  
    public final String color{get;set;}
    public final String owner {get;set;}  
    public final String kilometer {get;set;} 
    
    //constructor
    // @Method:      IND_IbbMasterRequest
    // @Created by:  Aman Mundhada
    // @Description: Contructor to initialize the details
    // @Param:       Object Request Wrapper
    // @Return:      ''    
    public IND_IbbMasterRequest(RequestWrapper requestWrapper){
        this.product_variant=requestWrapper.variant==null?'':requestWrapper.variant;
        this.application_no=requestWrapper.applicationNo==null?'':requestWrapper.applicationNo;
        this.vehicle_id= '1';//requestWrapper.vehicleId==null?'':requestWrapper.vehicleId; // defaulted as 1, as per email by Thanggmani on 12th July
        this.color=requestWrapper.color==null?'':requestWrapper.color;
        this.owner=requestWrapper.owner==null?'':requestWrapper.owner;
        this.kilometer=requestWrapper.kilometer==null?'':requestWrapper.kilometer;
        this.year=requestWrapper.year==null?'':requestWrapper.year;
        this.month=requestWrapper.month==null?'':requestWrapper.month;
        this.state_code=requestWrapper.stateCode==null?'':requestWrapper.stateCode;

        validate(System.Label.IBBMaster);
    }
    
    //Method to get the HTTP request header data
    // @Method:      getHttpRequestHeaders
    // @Created by:  Aman Mundhada
    // @Description: Method to get the HTTP request header data
    // @Param:       ''
    // @Return:      Header required to callout the service.
    public override Map<String,String> getHttpRequestHeaders(){
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
        if(String.isBlank(this.application_no)){
            throw new IND_Exception(System.Label.ApplicationNo);
        }
        if(String.isBlank(this.vehicle_id)){            
            throw new IND_Exception(System.Label.VehicleId);
        }   
         if(String.isBlank(this.year)){
            throw new IND_Exception(System.Label.year_month_Error);
        }
        if(String.isBlank(this.month)){            
            throw new IND_Exception(System.Label.year_month_Error);
        }   
         if(String.isBlank(this.product_variant)){
            throw new IND_Exception(System.Label.Variant);
        }
        if(String.isBlank(this.state_code)){            
            throw new IND_Exception(System.Label.StateCodeError);
        }   
         if(String.isBlank(this.color)){
            throw new IND_Exception(System.Label.Color);
        }
        if(String.isBlank(this.owner)){            
            throw new IND_Exception(System.Label.Owner);
        }
         if(String.isBlank(this.kilometer)){            
            throw new IND_Exception(System.Label.Kilometer);
        }
        return true;
    }
}