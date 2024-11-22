/*------------------------------------------------------------
Author: Satyam More
Company: Persistent Systems
Description: This class is wrapper class for the Run Emi Engine Request 
Test Class: 
History
Date            Author              Comments
------------------------------------------------------------- 
27-12-2021    Satyam More            Created
------------------------------------------------------------*/

public class IND_RunEmiEngineRequest extends ParentAPIRequest {
    //request paramaters for Run Emi Engine request
    public final String Lead_Id{get;set;}
    public final String Maker_Id{get;set;}
    public final String Application_Id{get;set;}
    public final String CIC_No{get;set;}
    public final String parentDealNo{get;set;}// CISP-112 Added new attribute.
    public final string purposeOfPurchase {get;set;}
    
    //constructor
    // @Method:      IND_RunEmiEngineRequest
    // @Created by:  Satyam More
    // @Description: Contructor to initialize the details
    // @Param:       Object Request Wrapper
    // @Return:      ''
    // 
    public IND_RunEmiEngineRequest(RequestWrapper requestWrapper, String loanAppId){
        if( requestWrapper != null){
            this.Lead_Id = requestWrapper.leadId==null?'':requestWrapper.leadId+'_'+requestWrapper.applicantNumber;
            this.Maker_Id = IntegrationUtilities.getMakerId(); 
            this.Application_Id = requestWrapper.loanApplicationId==null?'':requestWrapper.loanApplicationId ;
            this.CIC_No = requestWrapper.cicNo==null?'':requestWrapper.cicNo;
            this.parentDealNo = requestWrapper.parentDealNo==null?'':requestWrapper.parentDealNo; // CISP-112
            if (!String.isBlank(requestWrapper.loanApplicationId)) {
                List<Vehicle_Detail__c> vehicleDetails = [SELECT Purpose_of_Purchase__c 
                                                          FROM Vehicle_Detail__c 
                                                          WHERE Loan_Application__c = :requestWrapper.loanApplicationId 
                                                          LIMIT 1];
                if (!vehicleDetails.isEmpty()) {
                    this.purposeOfPurchase = vehicleDetails[0].Purpose_of_Purchase__c;
                } else {
                    this.purposeOfPurchase = '';  
                }
            } else {
                this.purposeOfPurchase = ''; 
            }
        }
        validate(System.Label.RunEMIEngine);
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
        if(String.isBlank(this.Lead_Id)){
            throw new IND_Exception(System.Label.LeadId);
        }
        if(String.isBlank(this.Maker_Id)){
            throw new IND_Exception(System.Label.MakerId);            
        }
        if(String.isBlank(this.Application_Id)){
            throw new IND_Exception(System.Label.ApplicationId);    
        }
        if(String.isBlank(this.CIC_No)){
            throw new IND_Exception(System.Label.CibilError);
        }    
        return true;
    }
}