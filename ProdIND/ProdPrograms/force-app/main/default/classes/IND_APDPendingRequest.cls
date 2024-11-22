/*------------------------------------------------------------
Author:        Thilak Bondiga
Company:       Persistent Systems
Description:   This class is wrapper class for the APD Pending API request 
Test Class:     
History
Date            Author              Comments
-------------------------------------------------------------
12-28-2021      Thilak Bondiga       Created
------------------------------------------------------------*/
public class IND_APDPendingRequest extends ParentAPIRequest {
	
    public final string maker_Id {get;set;}
    public final string Dealer_No {get;set;}  
    public final string lead_Id {get;set;}
    
    
    
    // @Method:      IND_APD PendingRequest
    // @Created by:  Thilak Bondiga
    // @Description: Contructor to initialize the details
    // @Param:       Object applicant Record
    // @Return:      ''
    public IND_APDPendingRequest(Applicant__c app,String loanAppId){
        List<Final_Term__c> finaltermsList = new List<Final_Term__c>();
        finaltermsList = [SELECT Id, Referrer_Ben_Code__c FROM Final_Term__c WHERE Loan_Application__c =: loanAppId WITH SECURITY_ENFORCED LIMIT 1];

        this.Maker_Id = IntegrationUtilities.getMakerId();
        this.Dealer_No = finaltermsList.size()> 0 && finaltermsList[0].Referrer_Ben_Code__c!=null ? finaltermsList[0].Referrer_Ben_Code__c : '';
        this.Lead_Id = app.Opportunity__r.Lead_number__c + '_'+ app.applicant_number__c;
        
        validate(System.Label.APDPending);
    }    
    
    // @Method:      getHttpRequestHeaders
    // @Created by:  Thilak Bondiga
    // @Description: Method to get the HTTP request header data
    // @Param:       ''
    // @Return:      Header required to callout the service.
    public override Map<String,String> getHttpRequestHeaders(){    
        Map<String,String> requestHeaderMap = Utilities.getHeaders();
        return requestHeaderMap;
    }
    
    // @Method:      validate
    // @Created by:  Thilak Bondiga
    // @Description: Method to validate the required input details
    // @Param:       Service name
    // @Return:      True - If all the validations are passed.
   
    public override boolean validate(String serviceName){

        if(this.Maker_Id == null && String.isBlank(this.Maker_Id)){
            throw new IND_Exception(System.Label.Maker_IdError);
        }
        if(this.Dealer_No == null && String.isBlank(this.Dealer_No)){
            throw new IND_Exception(System.Label.deal_Number);
        }
        if(this.Lead_Id == null && String.isBlank(this.Lead_Id)){
            throw new IND_Exception(System.Label.Lead_IDError);
        }        
        
        
        return true;
    }
}