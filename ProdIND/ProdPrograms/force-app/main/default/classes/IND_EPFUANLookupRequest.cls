/*------------------------------------------------------------
Author:        Divya Jawale
Company:       Persistent Systems
Description:   This class is wrapper class for the EPF UAN Lookup request 
Test Class:     IND_EPFUANLookupService_Test
History
Date            Author              Comments
-------------------------------------------------------------
21-12-2021      Divya Jawale       Created
------------------------------------------------------------*/
public class IND_EPFUANLookupRequest extends ParentAPIRequest{
    //request paramaters for EPF UAN Lookup request 
    public final String Maker_Id{get;set;}
    public final String TelephoneNumber{get;set;}
    public final String Lead_Id{get;set;}
    
   /*
@Method:      IND_EPFUANLookupRequest
@Created by:  Divya Jawale
@Description: Contructor to initialize the details
@Param:       Object - Applicant__c 
@Return:      '' 
*/
    public IND_EPFUANLookupRequest(Applicant__c app,String loanAppId){
        if( app != null){
            this.Maker_Id = IntegrationUtilities.getMakerId();
            this.TelephoneNumber = app.Contact_number__c;
            this.Lead_Id = app.Opportunity__r.Lead_Number__c + '_' + app.applicant_number__c;//CISP-2879
        }
        validate(System.Label.EPFUANLookupAPI);
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
@Return:      True - If all the validations are passed.
*/
    public override boolean validate(){
        if(String.isBlank(this.Maker_Id)){
            throw new IND_Exception(System.Label.MakerId);
        } 
        if(String.isBlank(this.TelephoneNumber)){
            throw new IND_Exception(System.Label.EnterMobileNumber);
        }
        if(String.isBlank(this.Lead_Id)){
            throw new IND_Exception(System.Label.LeadId);
        }
        return true;
    }
    
   /*Method to validate the request data
@Method:      validate
@Created by:  Divya Jawale
@Description: Method to validate the required input details
@Return:      True - If all the validations are passed.
*/
    public override boolean validate(String serviceName){
        return true;
    }
}