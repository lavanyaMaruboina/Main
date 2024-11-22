/*------------------------------------------------------------
Author:        Bhushan Charde
Company:       Persistent Systems
Description:   This class is wrapper class for the Customer Name Search request 
Test Class:    IND_CustomerNameSearchService_Test 
History
Date            Author              Comments
-------------------------------------------------------------
12-01-2022      Bhushan Charde      Created
14-03-2022		Santhosh Mothe		loanAppId tracking
------------------------------------------------------------*/
public class IND_CustomerNameSearchRequest extends ParentAPIRequest{
	public final String Deal_Number{get;set;}
    public final String Customer_Code{get;set;}

    public IND_CustomerNameSearchRequest(RequestWrapper requestWrapper, String loanAppId){
        if( requestWrapper != null){
           this.Deal_Number= requestWrapper.dealNumber==null?'':requestWrapper.dealNumber;//'AHX13408C'
           this.Customer_Code= requestWrapper.customerCode==null?'':requestWrapper.customerCode;       
        }
        validate(System.Label.CustomerNameSearch);
    }
    
    //Method to get the HTTP request header data
    public override Map<String,String> getHttpRequestHeaders(){    
        Map<String,String> requestHeaderMap = Utilities.getHeaders();
        return requestHeaderMap;
    }
    
      /*
    * @Method:      validate
    * @Created by:  Divya
    * @Description: This method will returns valid request SMS Gateway API
    * @Param:       String - serviceName
    * @Return:      boolean - true/false
    */
    public override boolean validate(String serviceName){
        if(String.isBlank(this.Deal_Number) && String.isBlank(this.Customer_Code)) {
            throw new IND_Exception(System.Label.DealNoORCustCode_ERR);
        } 
        return true;
    }
}
//dummy commit