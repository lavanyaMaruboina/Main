/*------------------------------------------------------------
Author:        Thilak Bondiga
Company:       Persistent Systems
Description:   This class is wrapper class for the CAM Portfolio API request 
Test Class:     
History
Date            Author              Comments
-------------------------------------------------------------
12-21-2021      Thilak Bondiga       Created
------------------------------------------------------------*/
public class IND_CAMPortfolioRequest extends ParentAPIRequest {
	
    public string maker_Id {get;set;}
    public string Product_Id {get;set;}  
    public string lead_Id {get;set;}
    public string Cic_No {get;set;}
    
    
    
    // @Method:      IND_CAMPortfolioRequest
    // @Created by:  Thilak Bondiga
    // @Description: Contructor to initialize the details
    // @Param:       Object applicant Record
    // @Return:      ''
    public IND_CAMPortfolioRequest(Applicant__c app,String loanAppId){
        List<CIBIL_Details__c> cibilDetailList = [SELECT Id, CIC_No__c from CIBIL_Details__c WHERE Applicant__c  =: app.Id];

        this.Maker_Id = IntegrationUtilities.getMakerId();
        this.Product_Id = app.Opportunity__r.Product_Type__c!=null && app.Opportunity__r.Product_Type__c == 'Two Wheeler' ? 'H' : app.Opportunity__r.Product_Type__c == 'Passenger Vehicles' ? 'C' :'' ; //H or C
        this.Lead_Id = app.Opportunity__r.Lead_number__c + '_'+ app.applicant_number__c;  
        this.Cic_No = cibilDetailList.size() > 0 && cibilDetailList[0].CIC_No__c != null ? String.valueOf(cibilDetailList[0].CIC_No__c) : '';
        
        validate(System.Label.CAMPortfolio);
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
        
        if(this.Product_Id == null && String.isBlank(this.Product_Id)){
            throw new IND_Exception(System.Label.ProductId);
        }
        if(this.Lead_Id == null && String.isBlank(this.Lead_Id)){
            throw new IND_Exception(System.Label.Lead_IDError);
        }        
        if(this.Maker_Id == null && String.isBlank(this.Maker_Id)){
            throw new IND_Exception(System.Label.Maker_IdError);
        }
        if(this.Cic_No == null && String.isBlank(this.Cic_No)){
            throw new IND_Exception(System.Label.CIC_IdError);
        }
        
        return true;
    }
}