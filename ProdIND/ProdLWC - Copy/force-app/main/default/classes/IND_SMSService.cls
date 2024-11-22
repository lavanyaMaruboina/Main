/*------------------------------------------------------------
Author:        Divya Jawale
Company:       Salesforce
Description:   This class is service class for the SMS Getway API 
Test Class:    IND_SMSService_Test 
History
Date            Author              Comments
-------------------------------------------------------------
8-10-2021      Divya Jawale      Created
------------------------------------------------------------*/
public class IND_SMSService {   
    /*
* @Method:      getSmsCallOutRequest
* @Created by:  Divya
* @Description: This method will returns valid request SMS Gateway API
* @Param:       Object - Applicant Object 
* @Return:      Object - IND_SMSRequest type request
*/
    public static IND_SMSRequest getSmsCallOutRequest(RequestWrapper requestWrapper){
        try{
            IND_SMSRequest smsRequest = new IND_SMSRequest(requestWrapper);
            return smsRequest;
        }
        catch(Exception ex){
            ErrorLoggerUtil.logErrorEvent('IND_SMSService', 'getSmsCallOutRequest', System.Label.Apex, ex, requestWrapper.loanApplicationId);
            throw new IND_Exception(ex.getMessage());   
        }
    }   
}