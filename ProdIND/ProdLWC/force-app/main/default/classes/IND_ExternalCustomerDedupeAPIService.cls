/*------------------------------------------------------------
Author:        Divya Jawale
Company:       Salesforce
Description:   This class is service class for the External Customer Dedupe API 
Test Class:    IND_ExternalCustomerDedupeService_Test
History
Date            Author              Comments
-------------------------------------------------------------
28-10-2021      Divya Jawale      Created
------------------------------------------------------------*/
public class IND_ExternalCustomerDedupeAPIService {

    /*
    * @Method:      getExternalDedupeCallout
    * @Created by:  Divya
    * @Description: This method will returns valid External Customer Dedupe API
    * @Param:       Id - Applicant Object 
    * @Return:      Object - IND_ExternalCustomerDedupeAPIRequest type request
    */
    public static IND_ExternalCustomerDedupeAPIRequest getExternalDedupeCallout(Applicant__c app, List<Documents__c> docs, String loanAppId){
        try{
            IND_ExternalCustomerDedupeAPIRequest request = new IND_ExternalCustomerDedupeAPIRequest(app, docs,loanAppId);
            return request;
        }
        catch(Exception ex){
            ErrorLoggerUtil.logErrorEvent('IND_ExternalCustomerDedupeAPIService', 'getexternalDedupeCallout', System.Label.Apex, ex,loanAppId);
            throw new IND_Exception(ex.getMessage());   
        }
    }
    
}