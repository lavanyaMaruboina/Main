/*------------------------------------------------------------
Author:        Divya Jawale
Company:       Salesforce
Description:   This class is service class for the Get CIBIL Report API 
Test Class:    IND_CIBILService_Test 
History
Date            Author              Comments
-------------------------------------------------------------
8-10-2021      Divya Jawale      Created
------------------------------------------------------------*/
public class IND_CIBILService {
    /*
    * @Method:      getcibilCallout
    * @Created by:  Divya Jawale 
    * @Description: Method to return Response for CIBIL Report API
    * @Param:       Id - applicantId
    * @Return:      Object - IND_CIBILRequest type request
    */
  
    public static IND_CIBILRequest getcibilCallout(Applicant__c app, List<Documents__c> docs, String loanAppId, List<CIBIL_Details__c> cibilDetails, String customer_Code, String cicNo){
        try
        {
            IND_CIBILRequest request = new IND_CIBILRequest(app,docs,loanAppId,cibilDetails, customer_Code,cicNo);            
            return request;
        }
        catch(Exception ex){
            ErrorLoggerUtil.logErrorEvent('IND_CIBILService', 'getcibilCallout', System.Label.Apex, ex,loanAppId);
            throw new IND_Exception(ex.getMessage());          
        }  
    }

}