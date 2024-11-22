/*------------------------------------------------------------
Author:        Divya Jawale
Company:       Persistent Systems
Description:   This class is wrapper class for the Validate Recent Lead request 
Test Class:    IND_ValidateRecentLeadService_Test
History
Date            Author              Comments
-------------------------------------------------------------
18-11-2021      Divya Jawale       Created
------------------------------------------------------------*/
public class IND_ValidateRecentLeadRequest extends ParentAPIRequest {
    //request paramaters forValidate Recent Lead request
    
    public final String Lead_Id {get;set;}
    public final String Reference_No{get;set;}
    public final String Maker_Id{get;set;}
    
    /*
@Method:      IND_ValidateRecentLeadRequest
@Created by:  Divya Jawale
@Description: Contructor to initialize the details
@Param:       String - sCICNo and sLeadNo
@Return:      '' 
*/
    public IND_ValidateRecentLeadRequest(String sCICNo, String sLeadNo, String loanAppId){
        if(sCICNo != null && sLeadNo != null){
            this.Lead_Id = sLeadNo;
            this.Reference_No = sCICNo;
            this.Maker_Id = IntegrationUtilities.getMakerId();
        }
        validate(System.Label.ValidateRecentLead);
    }
    
    /*Method to get the HTTP request header data
@Method:      getHttpRequestHeaders
@Created by:  Divya Jawale
@Description: Method to get the HTTP request header data
@Param:       ''
@Return:      Header required to callout the service.
*/
    public override Map<String,String> getHttpRequestHeaders(){
        //Map to store HTTP request header data
        Map<String,String> requestHeaderMap = Utilities.getHeaders();
        return requestHeaderMap;
        //requestheadermap is used to fetch the request from client
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
        if(String.isBlank(this.Reference_No)){
            throw new IND_Exception(System.Label.ReferenceId);
        } 
        if(String.isBlank(this.Lead_Id)){
            throw new IND_Exception(System.Label.LeadId);
        }
        return true;
    }
}