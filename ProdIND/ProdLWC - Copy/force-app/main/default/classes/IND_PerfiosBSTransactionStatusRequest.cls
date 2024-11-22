/*------------------------------------------------------------
Author:        Manish Baldota
Company:       Persistent Systems
Description:   This class is wrapper class for the Perfios Bank Statement Transaction Status API request 
Test Class:    
History
Date            Author              Comments
-------------------------------------------------------------
12-22-2021      Manish Baldota      Created
01-11-2022		Manish Baldota		Changes After changed in request format
------------------------------------------------------------*/
public class IND_PerfiosBSTransactionStatusRequest extends ParentAPIRequest {
    
  	public string ClientTransactionId {get;set;}

    // @Method:      IND_PerfiosBSTransactionStatusRequest
    // @Created by:  Manish Baldota
    // @Description: Contructor to initialize the details
    // @Param:       ''
    // @Return:      ''
    public IND_PerfiosBSTransactionStatusRequest(String clientTransactionId){          
        //Transaction ID Details needs to be finalized, weather we want to store those or not <Confirmation required>
        this.ClientTransactionId = clientTransactionId;  
        validate(System.label.Perfios_BS_Transaction_Status);
    }  
    // @Method:      getHttpRequestHeaders
    // @Created by:  Manish Baldota
    // @Description: Method to get the HTTP request header data
    // @Param:       ''
    // @Return:      Header required to callout the service.
    public override Map<String,String> getHttpRequestHeaders(){    
        Map<String,String> requestHeaderMap = Utilities.getHeaders();
        return requestHeaderMap;
    }
    // @Method:      validate
    // @Created by:  Manish Baldota
    // @Description: abstract Method to validate the required input details
    // @Param:       Service name
    // @Return:      True - If all the validations are passed.
    public override boolean validate(String serviceName){
        if(this.ClientTransactionId  != null && String.isBlank(this.ClientTransactionId)){
            throw new IND_Exception(System.Label.TxnIdErrorMsg);
        }     
        return true;
    }
    
}