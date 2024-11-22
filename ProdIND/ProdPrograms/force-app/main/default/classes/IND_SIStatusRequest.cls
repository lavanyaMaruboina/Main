/*------------------------------------------------------------
Author:        Bondiga Thilak
Company:       Persistent Systems
Description:   This class is wrapper class for the SIStatus API request 
Test Class:     
History
Date            Author              Comments
-------------------------------------------------------------
01-02-2021      Bondiga Thilak       Created
------------------------------------------------------------*/
public class IND_SIStatusRequest extends ParentAPIRequest{
	//request paramaters for SIStatus request
	
    public List<SI_Status_Req> SI_Status_Req{get;set;}

	public class SI_Status_Req {
		public String Customer_Code{get;set;}
		public String Deal_No{get;set;}
	}
    
    //public final string Customer_Code {get;set;}
    //public final string Deal_No {get;set;}
    
    // @Method:      IND_SIStatusRequest
    // @Created by:  Bondiga Thilak
    // @Description: Contructor to initialize the details
    // @Param:       Object applicant Record
    // @Return:      ''
    public IND_SIStatusRequest(RequestWrapper requestWrapper){  
        //currently hardcode Id's has been passed these will be changed at the time of handshaking.
        SI_Status_Req = new list<SI_Status_Req>();
        
        SI_Status_Req dt1 = new SI_Status_Req();
        dt1.Customer_Code= requestWrapper.customerCode;
        dt1.Deal_No= requestWrapper.dealNumber;
        SI_Status_Req.add(dt1); 
        
        validate(System.Label.SIStatus);
    }     
    
    // @Method:      getHttpRequestHeaders
    // @Created by:  Bondiga Thilak
    // @Description: Method to get the HTTP request header data
    // @Param:       ''
    // @Return:      Header required to callout the service.
    public override Map<String,String> getHttpRequestHeaders(){ 
        //Map to store HTTP request header data
        Map<String,String> requestHeaderMap = Utilities.getHeaders();  
        return requestHeaderMap;
    }
    
    // @Method:      validate
    // @Created by:  Bondiga Thilak
    // @Description: Method to validate the required input details
    // @Param:       Service name
    // @Return:      True - If all the validations are passed.
   
    public override boolean validate(String serviceName){
        for(Integer i=0;i<SI_Status_Req.size();i++){
            if(String.isBlank(this.SI_Status_Req[i].Customer_Code)){
                throw new IND_Exception(System.Label.CustomerCode );
            }
            if(String.isBlank(this.SI_Status_Req[i].Deal_No)){
                throw new IND_Exception(System.Label.deal_Number );
            }
 
        }
        /*
        if(this.Customer_Code == null && String.isBlank(this.Customer_Code)){
            throw new IND_Exception(System.Label.CustomerCode);
        }
        if(this.Deal_No == null && String.isBlank(this.Deal_No)){
            throw new IND_Exception(System.Label.deal_Number);
        }        */
        return true;
    }
    
}