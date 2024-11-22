/*------------------------------------------------------------
Author:        Bondiga Thilak
Company:       Persistent Systems
Description:   This class is wrapper class for the Agreement Booklet API request 
Test Class:     
History
Date            Author              Comments
-------------------------------------------------------------
12-21-2021      Bondiga Thilak       Created
------------------------------------------------------------*/
public class IND_AgreementBookletRequest extends ParentAPIRequest{
      
    public string Deal_No {get;set;}
    public string Agreement_Booklet_No {get;set;}
    public string Product {get;set;}
    public string Bl_Code {get;set;}
    public string Maker_Id {get;set;} 
    
    // @Method:      IND_AgreementBookletRequest
    // @Created by:  Bondiga Thilak
    // @Description: Contructor to initialize the details
    // @Param:       Object applicant Record
    // @Return:      ''
    public IND_AgreementBookletRequest(String bookletNo, Applicant__c app,String loanAppId,String dealId){
        if(loanAppId == null && Test.isRunningTest()){
            throw new IND_Exception(System.label.LoanApplicationNOTNULL);
        }        
        String productCode = '';
        if(app.Opportunity__r.Product_Type__c != null){
            if(!app.Opportunity__r.Product_Type__c.equals('ALL')){
                productCode = app.Opportunity__r.Product_Type__c == 'Two Wheeler' ? 'H' : app.Opportunity__r.Product_Type__c == 'Passenger Vehicles' ? 'C' : app.Opportunity__r.Product_Type__c == 'Tractor' ? 'T' : app.Opportunity__r.Product_Type__c;

            }

        }
        If(app.Opportunity__r.Product_Type__c == 'Tractor'){
            Deal_Number__c dealObj =[Select Id ,Deal_Number__c from Deal_Number__c where Id=:dealId];
            this.Deal_No = dealObj.Deal_Number__c; // RJG01179D
        }else{
            this.Deal_No = app.Opportunity__r.Deal_number__c; // RJG01179D
        }
        this.Agreement_Booklet_No = bookletNo; //'D00025234'; 
        this.Product =  productCode;   // 'C'; //H or C
        this.Bl_Code = app.Opportunity__r.Agent_BL_code__c;  // 'RJG';
        this.Maker_Id = IntegrationUtilities.getMakerId();  
        
        validate(System.Label.AgreementBooklet);
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
        if(this.Agreement_Booklet_No == null && String.isBlank(this.Agreement_Booklet_No)){
            throw new IND_Exception(System.Label.Agreement_Booklet_No_Error);
        } 
        if(this.Product == null && String.isBlank(this.Product)){
            throw new IND_Exception(System.Label.ProductId);
        } 
        if(this.Bl_Code == null && String.isBlank(this.Bl_Code)){
            throw new IND_Exception(System.Label.Bl_Code);
        } 
        if(this.Maker_Id == null && String.isBlank(this.Maker_Id)){
            throw new IND_Exception(System.Label.Maker_IdError);
        } 
        return true;
    }
    
}