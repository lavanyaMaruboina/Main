/*------------------------------------------------------------
Author:        Thilak Bondiga
Company:       Persistent Systems
Description:   This class is wrapper class for the Stamping Details API request 
Test Class:     
History
Date            Author              Comments
-------------------------------------------------------------
12-21-2021      Thilak Bondiga       Created
------------------------------------------------------------*/
public with sharing class IND_StampingDetailsRequest extends ParentAPIRequest {
    
    public final string Deal_No {get;set;}
    public final string Geo_State_Code {get;set;}
    public final string Fin_Amount {get;set;}
    public final string Unit {get;set;}
    public final string Product {get;set;}
    public final string Sub_Product {get;set;}
    
    
    // @Method:      IND_StampingDetailsPortfolioRequest
    // @Created by:  Thilak Bondiga
    // @Description: Contructor to initialize the details
    // @Param:       Object applicant Record
    // @Return:      ''
    public IND_StampingDetailsRequest(Applicant__c app,Opportunity loanApp,String geoStateCode, String dealId){
        //currently hardcode Id's has been passed these will be changed at the time of handshaking.
        String prodType = loanApp.Product_Type__c == 'Two Wheeler' ? 'H' : loanApp.Product_Type__c == Label.Tractor ? 'T' : 'C';
        this.Deal_No = loanApp.Deal_Number__c; 
        this.Geo_State_Code = geoStateCode;
        List<Final_Term__c> finaltermsList = new List<Final_Term__c>();
        if(loanApp.Product_Type__c == System.Label.Tractor){
            List<Vehicle_Detail__c> VehicleLst = [SELECT Id,Deal_Number__r.Deal_Number__c FROM Vehicle_Detail__c WHERE Deal_Number__c =: dealId WITH SECURITY_ENFORCED];
            if(VehicleLst.size() > 0){
                this.Deal_No = VehicleLst[0].Deal_Number__r.Deal_Number__c;
                finaltermsList = [SELECT Id,Loan_Amount__c,Loan_Application__r.Total_Funded_Premium__c FROM Final_Term__c WHERE Loan_Application__c = :loanApp.Id AND Vehicle_Detail__c =: VehicleLst[0].Id WITH SECURITY_ENFORCED LIMIT 1];
            }
        }else{
            finaltermsList = [SELECT Id,Loan_Amount__c,Loan_Application__r.Total_Funded_Premium__c 
                                FROM Final_Term__c 
                                WHERE Loan_Application__c = :loanApp.Id 
                                WITH SECURITY_ENFORCED  
                                LIMIT 1];
        }
        this.Fin_Amount = String.valueOf(Decimal.valueOf(finaltermsList[0].Loan_amount__c) + finaltermsList[0].Loan_Application__r.Total_Funded_Premium__c);
        // this.Fin_Amount = String.valueOf(loanApp.Finance_Amount__c.setScale(2)); 
        this.Unit = 'CFD';
        this.Product = prodType;
        this.Sub_Product = 'VEHICLE'; 
        
        validate(System.Label.StampingDetails);
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
        
        if(this.Deal_No == null && String.isBlank(this.Deal_No)){
            throw new IND_Exception(System.Label.deal_Number);
        }        
        if(this.Geo_State_Code == null && String.isBlank(this.Geo_State_Code)){
            throw new IND_Exception(System.Label.GeoStateCode);
        }        
        if(this.Fin_Amount == null && String.isBlank(this.Fin_Amount)){
            throw new IND_Exception(System.Label.FinAmount);
        }
        if(this.Unit == null && String.isBlank(this.Unit)){
            throw new IND_Exception(System.Label.Unit);
        }        
        if(this.Product == null && String.isBlank(this.Product)){
            throw new IND_Exception(System.Label.Product);
        }      
        if(this.Sub_Product == null && String.isBlank(this.Sub_Product)){
            throw new IND_Exception(System.Label.SubProduct);
        }
         
        return true;
    }
}