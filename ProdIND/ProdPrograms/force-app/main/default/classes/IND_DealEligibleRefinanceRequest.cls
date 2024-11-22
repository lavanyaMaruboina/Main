/*------------------------------------------------------------
Author:        Divya Jawale
Company:       Persistent Systems
Description:   This class is wrapper class for the Deal Eligible Refinance request 
Test Class:    IND_DealEligibleRefinanceService_Test 
History
Date            Author              Comments
-------------------------------------------------------------
22-12-2021      Divya Jawale       Created
------------------------------------------------------------*/
public with sharing class IND_DealEligibleRefinanceRequest extends ParentAPIRequest {
    //request paramaters for Deal Eligible Refinance request 
    public String Lead_Id{get;set;}
    public String DealNumber{get;set;}
    public String Product{get;set;} 
    
/*
@Method:      IND_DealEligibleRefinanceRequest
@Created by:  Divya Jawale
@Description: Contructor to initialize the details
@Param:       Object - Opportunity
@Return:      '' 
*/
    public IND_DealEligibleRefinanceRequest(Opportunity opp, String dealNumber){
        if( opp != null){
            this.Lead_Id = opp.Lead_number__c ;
            this.DealNumber = String.isNotBlank(dealNumber) ? dealNumber : opp.Parent_Deal_number__c;
            this.Product = opp.Product_Type__c == 'Two Wheeler'?'H' : opp.Product_Type__c == 'Passenger Vehicles' ?'C' : opp.Product_Type__c == 'Tractor' ? 'T' : '';
        }
        validate(System.Label.DealEligibleRefinanceAPI);
    }
    
/*Method to get the HTTP request header data
@Method:      getHttpRequestHeaders
@Created by:  Divya Jawale
@Description: Method to get the HTTP request header data
@Param:       ''
@Return:      Header required to callout the service.
*/
    public override Map<String,String> getHttpRequestHeaders(){    
        Map<String,String> requestHeaderMap = Utilities.getHeaders();
        return requestHeaderMap;
    }
    
/*Method to validate the request data
@Method:      validate
@Created by:  Divya Jawale
@Description: Method to validate the required input details
@Param:       Service name
@Return:      True - If all the validations are passed.
*/
    public override boolean validate(String serviceName){
        
        if(String.isBlank(this.Lead_Id)){
            throw new IND_Exception(System.Label.LeadId);
        }
        if(String.isBlank(this.DealNumber)){
            throw new IND_Exception(System.Label.deal_Number);
        } 
        if(String.isBlank(this.Product)){
            throw new IND_Exception(System.Label.Product);
        }
        return true;
    }
}