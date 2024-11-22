/*------------------------------------------------------------
Author:        Divya Jawale
Company:       Persistent Systems
Description:   This class is wrapper class for the EPFO Auth request 
Test Class:    IND_EPFOAuthService_Test 
History
Date            Author              Comments
-------------------------------------------------------------
17-12-2021      Divya Jawale       Created
------------------------------------------------------------*/
public class IND_EPFOAuthRequest extends ParentAPIRequest {
    //request paramaters for EPFO Auth request 
    public final String Maker_Id{get;set;}
    public final String TelephoneNumber{get;set;}
    public final String UAN{get;set;} 
    public final String Lead_Id{get;set;}
    
    /*
@Method:      IND_EPFOAuthRequest
@Created by:  Divya Jawale
@Description: Contructor to initialize the details
@Param:       Object - Applicant__c ,String uanNumber
@Return:      '' 
*/
    public IND_EPFOAuthRequest(Applicant__c app, String uanNumber, String loanAppId){        
        if( app != null && uanNumber != null){
            this.Maker_Id = IntegrationUtilities.getMakerId();
            this.TelephoneNumber = app.Contact_number__c;
            this.UAN = uanNumber;
            this.Lead_Id = app.Opportunity__r.Lead_Number__c ;
        }
        validate(System.Label.EPFOAuthAPI);
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
        if(String.isBlank(this.Maker_Id)){
            throw new IND_Exception(System.Label.MakerId);
        } 
        if(String.isBlank(this.UAN)){
            throw new IND_Exception(System.Label.UAN);
        }
        if(String.isBlank(this.Lead_Id)){
            throw new IND_Exception(System.Label.LeadId);
        }
        return true;
    }
}