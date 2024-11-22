/*------------------------------------------------------------
Author:        Bhushan Charde
Company:       Persistent Systems
Description:   This class contains methods related to UIDAI OTP -API callout.
Inputs:        None 
Test Class:     
History
Date            Author              Comments
-------------------------------------------------------------
9-12-2021      Bhushan Charde     Created
------------------------------------------------------------*/

public class IND_UidaiOTPService {
    /* 
    * @Method:      getUidaiOtpRequest
    * @Created by:  Bhushan Charde
    * @Description: This method will returns valid request UIDAI OTP API
    * @Param:       Object - Document Object 
    * @Return:      Object - IND_UidaiOTPRequest type request
    */
    public static IND_UidaiOTPRequest getUidaiOtpRequest(RequestWrapper requestWrapper){
        try
        {	
            IND_UidaiOTPRequest request = new IND_UidaiOTPRequest(requestWrapper);
            return request;
        }
        catch(Exception ex)
        {
            ErrorLoggerUtil.logErrorEvent('IND_UidaiOTPService', 'getUidaiOtpRequest', System.Label.Apex, ex, requestWrapper.loanApplicationId);
            throw new IND_Exception(ex.getMessage());          
        }  
    }
}