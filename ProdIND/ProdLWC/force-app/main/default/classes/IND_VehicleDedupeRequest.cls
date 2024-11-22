/*------------------------------------------------------------
Author: Sharad Kathane
Company: Persistent Systems
Description: This class is wrapper class for the Vehicle Dedupe Request
Test Class: 
History
Date            Author              Comments
------------------------------------------------------------- 
27-10-2021    Sharad Kathane            Created
24-12-2021	  Satyam More               Modified
3-3-2022      Santhosh Mothe			removed validation for customer code
------------------------------------------------------------*/

public class IND_VehicleDedupeRequest extends ParentAPIRequest{
    
    //request paramaters for Vehicle Dedupe request
    public final String Customer_Code{get;set;}
    public final String Old_Deal_No{get;set;}
    public final String Reg_No{get;set;}
    public final String NOC_No{get;set;}
    public final String Product {get;set;}
    public final String Category {get;set;}
    public final String Sub_Category {get;set;}
    
    //constructor
    // @Method:      IND_VehicleDedupeRequest
    // @Created by:  Sharad Kathane
    // @Description: Contructor to initialize the details
    // @Param:       Object Request Wrapper
    // @Return:      ''
    // 
    public IND_VehicleDedupeRequest(RequestWrapper requestwrapper){  
        if( requestwrapper != null){
            this.Customer_Code = requestwrapper.customerCode==null?'':requestwrapper.customerCode ; 
            this.Old_Deal_No = requestwrapper.oldDealNo==null?'':requestwrapper.oldDealNo ; 
            this.Reg_No = requestwrapper.vehicleRegisterationNumber==null?'':requestwrapper.vehicleRegisterationNumber ; 
            this.NOC_No = requestwrapper.nocNo==null?'':requestwrapper.nocNo ; 
            this.Product = requestwrapper.product==null?'':requestwrapper.product ; 
            this.Category = requestwrapper.category==null?'':requestwrapper.category ; 
            this.Sub_Category = requestwrapper.subCategory==null?'':requestwrapper.subCategory ;
        }
        system.debug('+++++this.Product '+this.Product+'+++++this.Category '+this.Category+'+++++this.Sub_Category '+this.Sub_Category);
        if(this.Product == 'Tractor'){
            validateTractor(System.Label.Vehicle_Dedupe);
        }else{
        validate(System.Label.Vehicle_Dedupe);
        }
    }
    
    //Method to get the HTTP request header data
    // @Method:      getHttpRequestHeaders
    // @Created by:  Sharad Kathane
    // @Description: Method to get the HTTP request header data
    // @Param:       ''
    // @Return:      Header required to callout the service.
    
    public override Map<String,String> getHttpRequestHeaders(){    
        Map<String,String> requestHeaderMap = Utilities.getHeaders();
        return requestHeaderMap;
    }
    
     //Method to validate the request data
    // @Method:      getHttpRequestHeaders
    // @Created by:  Sharad Kathane
    // @Description: Method to validate the required input details
    // @Param:       Service name
    // @Return:      True - If all the validations are passed.
    
    
    public override boolean validate(String serviceName){
        /*if(String.isBlank(this.Old_Deal_No)){
            throw new IND_Exception(System.Label.OldDealNo);
        }*/
        if(String.isBlank(this.Reg_No)){
            throw new IND_Exception(System.Label.VehicleRegistrationNumber);
        }
       if(String.isBlank(this.Product)){
            throw new IND_Exception(System.Label.Product);
        }
        if(String.isBlank(this.Category)){
            throw new IND_Exception(System.Label.Category);
        }
        if(String.isBlank(this.Sub_Category)){
            throw new IND_Exception(System.Label.SubCategory);
        }
        return true;
    }
    
    public override boolean validateTractor(String serviceName){
       if(String.isBlank(this.Product)){
            throw new IND_Exception(System.Label.Product);
        }
        if(String.isBlank(this.Sub_Category)){
            throw new IND_Exception(System.Label.SubCategory);
        }
        return true;
    }
}