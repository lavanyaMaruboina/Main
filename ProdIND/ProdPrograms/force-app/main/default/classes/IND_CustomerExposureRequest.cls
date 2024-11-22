/*------------------------------------------------------------
Author:        Bondiga Thilak
Company:       Persistent Systems
Description:   This class is wrapper class for the Customer Exposure API request 
Test Class:     
History
Date            Author              Comments
-------------------------------------------------------------
12-1-2022      Bondiga Thilak       Created
------------------------------------------------------------*/
public class IND_CustomerExposureRequest extends ParentAPIRequest{
    //request paramaters for DealMaster request
    
    public final List<Customer_Dt>  customer_Dt{get;set;}
    public class Customer_Dt{
        public final string Customer_Code {get;set;}
        public final string Lead_Id {get;set;}
    }
    
    
    
    // @Method:      IND_DealMasterRequest
    // @Created by:  Bondiga Thilak
    // @Description: Contructor to initialize the details
    // @Param:       Object applicant Record
    // @Return:      ''
    public IND_CustomerExposureRequest(List<String> lstCustCodes, String loanAppId){  //List<Application__c> lstapp
        //currently hardcode Id's has been passed these will be changed at the time of handshaking.
        System.debug('lstCustCodes'+lstCustCodes);
        customer_Dt = new List<Customer_Dt>(); 
        for(String str: lstCustCodes){
            Customer_Dt dt = new Customer_Dt();
            dt.Customer_Code=str; 
            dt.Lead_Id=loanAppId;
            customer_Dt.add(dt);
         }
        
       // List<Applicant__c> lstApp = [SELECT Id,Opportunity__r.Customer_Deal_No__c,Opportunity__r.Lead_number__c,Customer_Code__c FROM Applicant__c WHERE Customer_Code__c  IN : setstr WITH SECURITY_ENFORCED ]; 
       // system.debug('BH lstApp==> '+lstApp);
        
       // customer_Dt = new list<Customer_Dt>();
       // Customer_Dt dt = new Customer_Dt();
      /*  for(Applicant__c app : lstApp){
            dt.Customer_Code=app.Customer_Code__c;
            //dt.Lead_Id=app.Opportunity__r.Lead_number__c;
            dt.Lead_Id=loanAppId;
            customer_Dt.add(dt);             
        }*/
        
      /*  Customer_Dt = new list<Customer_Dt>();
        Customer_Dt dt1 = new Customer_Dt();
        dt1.Customer_Code='CU5658609';
        dt1.Lead_Id='TLN011D';
        Customer_Dt.add(dt1); 
        
        Customer_Dt dt2 = new Customer_Dt();
        dt2.Customer_Code='abc';
        dt2.Lead_Id='abc';
        Customer_Dt.add(dt2);*/
        
        validate(System.Label.CustomerExposure);
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
        
        for(Integer i=0;i<Customer_Dt.size();i++){
            if(String.isBlank(this.Customer_Dt[i].Customer_Code)){
                throw new IND_Exception(System.Label.CustomerCode );
            }
            if(String.isBlank(this.Customer_Dt[i].Lead_Id)){
                throw new IND_Exception(System.Label.Lead_IDError );
            }
 
        }
        
        return true;
    }
    
}