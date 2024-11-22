/*------------------------------------------------------------
Author:        Bondiga Thilak
Company:       Persistent Systems
Description:   This class is wrapper class for the Deal Master API request 
Test Class:     
History
Date            Author              Comments
-------------------------------------------------------------
01-28-2022      Bondiga Thilak       Created
------------------------------------------------------------*/
public class IND_RCLimitCheckRequest extends ParentAPIRequest{
	//request paramaters for RCLimitCheck request
    public final string Application_No {get;set;}
    public final string Vehicle_Id {get;set;}
    public final string Ben_Code {get;set;}
    public final string Product {get;set;} 
    public final string Finance_amount {get;set;}
    
    // @Method:      IND_RCLimitCheckRequest
    // @Created by:  Bondiga Thilak
    // @Description: Contructor to initialize the details
    // @Param:       Object applicant Record
    // @Return:      ''
    public IND_RCLimitCheckRequest(Applicant__c app,String loanAppId, String dealId){  
        try{
         if(app != null){
        //currently hardcode Id's has been passed these will be changed at the time of handshaking.
        this.Application_No = app?.Opportunity__r?.Application_number__c;/*'AC4969614_85523017724';*/
        //this.Vehicle_Id = 'MRBALENO3_V1';//app.Opportunity__r.Application_number__c;//
        //this.Ben_Code = 'BEN000951';
        //this.Product = 'C';
         }	
        List<Product2> variantList = new List<Product2>();
        List<Vehicle_Detail__c> vehDetailList = new List<Vehicle_Detail__c>();
        List<Final_Term__c> finalTermList = new List<Final_Term__c>();
        Opportunity opp = [SELECT Id, Product_Type__c FROM Opportunity WHERE Id =: loanAppId WITH SECURITY_ENFORCED];
        if(opp.Product_Type__c == System.Label.Tractor){
            vehDetailList = [SELECT ID,Product__c,Variant__c, Loan_Application__c,Ben_Code__c 
                                FROM Vehicle_Detail__c 
                                WHERE Loan_Application__c =:app.Opportunity__c AND Deal_Number__c =: dealId
                                WITH SECURITY_ENFORCED];
            finalTermList = [SELECT ID ,Referrer_Ben_Code__c,Loan_amount__c,Loan_Application__r.Total_Funded_Premium__c 
                                FROM Final_Term__c 
                                WHERE Loan_Application__c =:app.Opportunity__c AND Vehicle_Detail__c =: vehDetailList[0].Id
                                WITH SECURITY_ENFORCED];
        }else{
            vehDetailList = [SELECT ID,Product__c,Variant__c, Loan_Application__c,Ben_Code__c 
                            FROM Vehicle_Detail__c 
                            WHERE Loan_Application__c =:app.Opportunity__c
                            WITH SECURITY_ENFORCED];
            finalTermList = [SELECT ID ,Referrer_Ben_Code__c,Loan_amount__c,Loan_Application__r.Total_Funded_Premium__c 
                            FROM Final_Term__c 
                            WHERE Loan_Application__c =:app.Opportunity__c 
                            WITH SECURITY_ENFORCED];
        }
        if(!vehDetailList.isEmpty()){
            variantList = [Select Id, Variant_Code__c from Product2 where Name =: vehDetailList[0].Variant__c WITH SECURITY_ENFORCED];
        }   
        if(finalTermList.size()>0){               
            this.Finance_amount = String.valueOf(Decimal.valueOf(finalTermList[0].Loan_amount__c) + finalTermList[0].Loan_Application__r.Total_Funded_Premium__c);
        }
        for(Vehicle_Detail__c vedObj:vehDetailList)
            { 
            	this.Product = vedObj.Product__c != null && vedObj.Product__c == 'Two Wheeler' ?'H': vedObj.Product__c == 'Passenger Vehicles' ? 'C' :'' ;
                if(vedObj.Ben_Code__c != null){
                	this.Ben_Code=vedObj.Ben_Code__c;
                }else{
                    if(finalTermList.size()>0){
                        this.Ben_Code=finalTermList[0].Referrer_Ben_Code__c;
                    }
                }
                this.Vehicle_Id = vehDetailList[0].Variant__c;
            }
        validate(System.Label.RCLimitCheck);
        }
        catch(Exception ex){
            ErrorLoggerUtil.logErrorEvent('IND_RCLimitCheckRequest', 'IND_RCLimitCheckRequest', System.Label.Apex, ex,loanAppId);
            throw new IND_Exception(ex.getMessage());   
        }
    }   
    public IND_RCLimitCheckRequest(Applicant__c app,String loanAppId,String callType, String dealId){  
        try{
         if(app != null){
        //currently hardcode Id's has been passed these will be changed at the time of handshaking.
        this.Application_No = app?.Opportunity__r?.Application_number__c;/*'AC4969614_85523017724';*/
        //this.Vehicle_Id = 'MRBALENO3_V1';//app.Opportunity__r.Application_number__c;//
        //this.Ben_Code = 'BEN000951';
        //this.Product = 'C';
         }	
        List<Product2> variantList = new List<Product2>();
        List<Vehicle_Detail__c> vehDetailList = new List<Vehicle_Detail__c>();
        List<Final_Term__c> finalTermList = new List<Final_Term__c>();
        Opportunity opp = [SELECT Id, Product_Type__c FROM Opportunity WHERE Id =:loanAppId WITH SECURITY_ENFORCED];
        if(opp.Product_Type__c == System.Label.Tractor){
            vehDetailList = [SELECT ID,Product__c,Variant__c, Loan_Application__c,Ben_Code__c 
                            FROM Vehicle_Detail__c 
                            WHERE Loan_Application__c =:app.Opportunity__c AND Deal_Number__c =: dealId
                            WITH SECURITY_ENFORCED];
            finalTermList = [SELECT ID ,Referrer_Ben_Code__c,Loan_amount__c,Loan_Application__r.Total_Funded_Premium__c 
                            FROM Final_Term__c 
                            WHERE Loan_Application__c =:app.Opportunity__c AND Vehicle_Detail__c =: vehDetailList[0].Id
                            WITH SECURITY_ENFORCED];
        }else{
            vehDetailList = [SELECT ID,Product__c,Variant__c, Loan_Application__c,Ben_Code__c 
                            FROM Vehicle_Detail__c 
                            WHERE Loan_Application__c =:app.Opportunity__c
                            WITH SECURITY_ENFORCED];
            finalTermList = [SELECT ID ,Referrer_Ben_Code__c,Loan_amount__c,Loan_Application__r.Total_Funded_Premium__c 
                            FROM Final_Term__c 
                            WHERE Loan_Application__c =:app.Opportunity__c
                            WITH SECURITY_ENFORCED];
        }
        if(!vehDetailList.isEmpty()){
            variantList = [Select Id, Variant_Code__c from Product2 where Name =: vehDetailList[0].Variant__c WITH SECURITY_ENFORCED];
        }
        if(finalTermList.size()>0){               
            this.Finance_amount = String.valueOf(Decimal.valueOf(finalTermList[0].Loan_amount__c) + finalTermList[0].Loan_Application__r.Total_Funded_Premium__c);
        }
        for(Vehicle_Detail__c vedObj:vehDetailList)
            { 
            	this.Product = vedObj.Product__c != null && vedObj.Product__c == 'Two Wheeler' ?'H': vedObj.Product__c == 'Passenger Vehicles' ? 'C' :'' ;
                if(vedObj.Ben_Code__c != null && callType == 'Dealer'){
                	this.Ben_Code=vedObj.Ben_Code__c;
                }else if(finalTermList.size()>0 && finalTermList[0].Referrer_Ben_Code__c != null && callType == 'DSA' ){
                        this.Ben_Code=finalTermList[0].Referrer_Ben_Code__c;
                }
                this.Vehicle_Id = vehDetailList[0].Variant__c;
            }
        validate(System.Label.RCLimitCheck);
        }
        catch(Exception ex){
            ErrorLoggerUtil.logErrorEvent('IND_RCLimitCheckRequest', 'IND_RCLimitCheckRequest', System.Label.Apex, ex,loanAppId);
            throw new IND_Exception(ex.getMessage());   
        }
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
        
        if(this.Application_No == null && String.isBlank(this.Application_No)){
            throw new IND_Exception(System.Label.AppId);
        }
        if(this.Vehicle_Id == null && String.isBlank(this.Vehicle_Id)){
            throw new IND_Exception(System.Label.VehicleId);
        }
		if(this.Ben_Code == null && String.isBlank(this.Ben_Code)){
            throw new IND_Exception(System.Label.Ben_Code);
        }
		if(this.Product == null && String.isBlank(this.Product)){
            throw new IND_Exception(System.Label.ProductError);
        }     
        if(this.Finance_amount == null && String.isBlank(this.Finance_amount)){
            throw new IND_Exception(System.Label.FinanceError);
        }    
        return true;
    }
    
}