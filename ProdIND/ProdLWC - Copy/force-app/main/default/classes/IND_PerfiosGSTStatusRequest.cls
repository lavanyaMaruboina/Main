/*------------------------------------------------------------
Author		:Bhushan Charde
Company		:Persistent Systems
Description	:This class is wrapper class for the Perfios GST Status API request 
Test Class	:     
History		:
Date            Author              Comments
-------------------------------------------------------------
12-27-2021      Bhushan Charde       Created
------------------------------------------------------------*/
public class IND_PerfiosGSTStatusRequest extends ParentAPIRequest {
    
	public string ClientTransactionId  {get;set;}
    
    // @Method      :IND_PerfiosGSTStatusRequest
    // @Created by  :Bhushan Charde
    // @Description :Contructor to initialize the details
    // @Param       :Object applicant Record
    // @Return		:''
    public IND_PerfiosGSTStatusRequest(String txnId){  
        this.ClientTransactionId = txnId;     
        validate(System.Label.GSTStatus);
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
        if(String.isBlank(this.ClientTransactionId)){
            throw new IND_Exception(System.Label.ClientTransactionIdError);
        }
        return true;
    }
}