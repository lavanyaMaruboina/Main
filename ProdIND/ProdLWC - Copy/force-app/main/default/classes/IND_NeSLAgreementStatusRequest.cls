/*------------------------------------------------------------
Author:        Bondiga Thilak
Company:       Persistent Systems
Description:   This class is wrapper class for the NeSL Agreement Status API request 
Test Class:     
History
Date            Author              Comments
-------------------------------------------------------------
12-21-2021      Bondiga Thilak       Created
------------------------------------------------------------*/
public class IND_NeSLAgreementStatusRequest extends ParentAPIRequest{
	  
    public string Deal_No {get;set;}
    
    // @Method:      IND_NeSLAgreementRequest
    // @Created by:  Bondiga Thilak
    // @Description: Contructor to initialize the details
    // @Param:       Object applicant Record
    // @Return:      ''
    public IND_NeSLAgreementStatusRequest(Applicant__c app,String loanAppId){ 
        //if( app ! = null) {
        //currently hardcode Id's has been passed these will be changed at the time of handshaking.
        //this.DealNumber = app.Opportunity__r.Parent_Deal_number__c;  //app.Opportunity__r.Customer_Deal_No__c;
        // this.Deal_No = 'RJG01179D';//app.Opportunity__r.Parent_Deal_number__c;
        this.Deal_No = app.Opportunity__r.Deal_Number__c;
        validate(System.Label.NeSLAgreementStatus);
    }    
    
    // @Method:      getHttpRequestHeaders
    // @Created by:  Bondiga Thilak
    // @Description: Method to get the HTTP request header data
    // @Param:       ''
    // @Return:      Header required to callout the service.
    public override Map<String,String> getHttpRequestHeaders(){    
        Map<String,String> requestHeaderMap = Utilities.getHeaders();  
        return requestHeaderMap;
    }
    
    // @Method:      validate
    // @Created by:  Bondiga Thilak
    // @Description: Method to validate the required input details
    // @Param:       Service name
    // @Return:      True - If all the validations are passed.
   
    public override boolean validate(String serviceName){
        
        if(this.Deal_No == null && String.isBlank(this.Deal_No)){
            throw new IND_Exception(System.Label.deal_Number);
        } 
        return true;
    }
    
}