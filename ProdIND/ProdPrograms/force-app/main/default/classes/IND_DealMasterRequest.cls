/*------------------------------------------------------------
Author:        Bondiga Thilak
Company:       Persistent Systems
Description:   This class is wrapper class for the Deal Master API request 
Test Class:     
History
Date            Author              Comments
-------------------------------------------------------------
12-21-2021      Bondiga Thilak       Created
------------------------------------------------------------*/
public class IND_DealMasterRequest extends ParentAPIRequest{
	//request paramaters for DealMaster request
    public final string Lead_Id {get;set;}
    public final string DealNumber {get;set;}
    
    // @Method:      IND_DealMasterRequest
    // @Created by:  Bondiga Thilak
    // @Description: Contructor to initialize the details
    // @Param:       Object applicant Record
    // @Return:      ''
    public IND_DealMasterRequest(Applicant__c app,String loanAppId){  
        //currently hardcode Id's has been passed these will be changed at the time of handshaking.
        this.DealNumber = app.Opportunity__r.Parent_Deal_number__c;  //app.Opportunity__r.Customer_Deal_No__c;  //TUT06226H
        this.Lead_Id = app.Opportunity__r.Lead_number__c;  //app.Opportunity__r.Lead_number__c;  //AC8374834_84384738 
        validate(System.Label.DealMaster);
    } 
    
    // @Method:      IND_DealMasterRequest
    // @Created by:  Daksh Mandowara
    // @Description: Contructor to initialize the details
    // @Param:       Deal Number and Lead Number
    // @Return:      ''
    public IND_DealMasterRequest(String dealNumber,String leadNumber){  
        this.DealNumber = dealNumber;  //Deal Number from front-end;  //TUT06226H
        this.Lead_Id = leadNumber;  //app.Opportunity__r.Lead_number__c;  //AC8374834_84384738 
        validate(System.Label.DealMaster);
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
        
        if(this.DealNumber == null && String.isBlank(this.DealNumber)){
            throw new IND_Exception(System.Label.deal_Number);
        }
        if(this.Lead_Id == null && String.isBlank(this.Lead_Id)){
            throw new IND_Exception(System.Label.Lead_IDError);
        }        
        return true;
    }
    
}