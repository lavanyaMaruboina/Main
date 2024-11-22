/*------------------------------------------------------------
Author:        Bharath
Company:       Persistent
Description:   This class is  class Request class to Perfios IHM receipt API
Test Class:     
History
Date            Author              Comments
-------------------------------------------------------------
12-29-2021      Bharath Moka      Created
------------------------------------------------------------*/

public class IND_IHMReceiptRequest extends ParentAPIRequest {
	
    public string Deal_Number {get;set;} 
    // @Method:      IND_IHMReceipt
    // @Created by:  Bharath Moka
    // @Description: Contructor to initialize the details
    // @Param:       Object applicant Record
    // @Return:      ''
    public IND_IHMReceiptRequest(Applicant__c app,String loanAppId, String dealId){  
        //currently hardcode Id's has been passed these will be changed at the time of handshaking.

        if(app.Opportunity__r.Product_Type__c == System.Label.Tractor){
            Deal_Number__c DealNumberObj = [SELECT Id, Deal_Number__c FROM Deal_Number__c WHERE Id =: dealId];
            this.Deal_Number = DealNumberObj.Deal_Number__c;
		}

        if( app != null && app.Opportunity__r.Product_Type__c != System.Label.Tractor){
        this.Deal_Number = app.Opportunity__r.Deal_Number__c; // 'TUT06226H'; 
        }
        validate(System.Label.IHMReceipt);
    }    
    
    // @Method:      getHttpRequestHeaders
    // @Created by:  Bharath Moka
    // @Description: Method to get the HTTP request header data
    // @Param:       ''
    // @Return:      Header required to callout the service.
    public override Map<String,String> getHttpRequestHeaders(){    
        Map<String,String> requestHeaderMap = Utilities.getHeaders();
        return requestHeaderMap;
    }
    
    // @Method:      validate
    // @Created by:  Bharath Moka
    // @Description: Method to validate the required input details
    // @Param:       Service name
    // @Return:      True - If all the validations are passed.
   
    public override boolean validate(String serviceName){
        
        if(String.isBlank(this.Deal_Number)){
            throw new IND_Exception(System.Label.Deal_Number);
        } 
        return true;
    }
}