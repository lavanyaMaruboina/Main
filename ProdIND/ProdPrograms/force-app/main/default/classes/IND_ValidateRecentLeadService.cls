/*------------------------------------------------------------
Author:        Divya Jawale
Company:       Salesforce
Description:   This class is service class for the Validate Recent Lead  API 
Test Class:    IND_ValidateRecentLeadService_Test 
History
Date            Author              Comments
-------------------------------------------------------------
18-11-2021      Divya Jawale      Created
------------------------------------------------------------*/
 
public class IND_ValidateRecentLeadService {
    /*
* @Method:      getValidateRecentLeadRequest
* @Created by:  Divya Jawale 
* @Description: Method to return Response for Validate Recent Lead API
* @Param:       String - sLeadNo and CIC_No
* @Return:      IND_ValidateRecentLeadRequest type request
*/
    public static IND_ValidateRecentLeadRequest getValidateRecentLeadRequest(String sCICNo, String sLeadNo, String loanAppId){
        try
        {
            IND_ValidateRecentLeadRequest request = new IND_ValidateRecentLeadRequest(sCICNo, sLeadNo,loanAppId);            
            return request;
        }
        catch(Exception ex){
            ErrorLoggerUtil.logErrorEvent('IND_ValidateRecentLeadService', 'validateRecentLeadCallout', System.Label.Apex, ex,loanAppId);
            throw new IND_Exception(ex.getMessage());          
        }  
    }

}