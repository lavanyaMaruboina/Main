/*------------------------------------------------------------
Author:        Bhushan Charde
Company:       Persistent Systems
Description:   This class contains methods related to UIDAI OTP Verify - API callout.
Inputs:        None 
Test Class:     
History
Date            Author              Comments
-------------------------------------------------------------
9-12-2021      Bhushan Charde       Created
------------------------------------------------------------*/
public class IND_UidaiOTPVerifyService {
	 /*
    * @Method:      uidaiOTPVerifyCallout
    * @Created by:  Bhushan Charde
    * @Description: This method will process the UIDAI OTP Verify API
    * @Param:       Object - Document Object 
    * @Return:      Object - IND_UidaiOTPVerifyResponse type response
    */
    public static IND_UidaiOTPVerifyRequest getUidaiOtpVerifyRequest(RequestWrapper requestWrapper){
        try
        {	
            IND_UidaiOTPVerifyRequest uidaiOTPVerifyRequest = new IND_UidaiOTPVerifyRequest(requestWrapper);          
            return uidaiOTPVerifyRequest;
        }
        catch(Exception ex)
        {
            ErrorLoggerUtil.logErrorEvent('IND_UidaiOTPVerifyService', 'uidaiOTPVerifyCallout', System.Label.Apex, ex,requestWrapper.loanApplicationId);
            throw new IND_Exception(ex.getMessage());         
        }  
    }
}