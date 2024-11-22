/*------------------------------------------------------------
Author: Satyam More
Company: Persistent Systems
Description: This class is wrapper class for the Uidai Biometric API
Test Class: 
History
Date            Author              Comments
------------------------------------------------------------- 
05-01-2022    Satyam More            Created
------------------------------------------------------------*/

public class IND_UidaiBiometricService {
/*
    * @Method:      getUidaiBiometricRequest
    * @Created by:  Satyam More
    * @Description: This method will process the UIDAI OTP Verify API
    * @Param:       Object - Document Object 
    * @Return:      Object - IND_UidaiBiometricResponse type response
    */
    public static IND_UidaiBiometricRequest getUidaiBiometricRequest(Applicant__c app,String loanAppId){
        try
        {	
            IND_UidaiBiometricRequest uidaiBiometricRequest = new IND_UidaiBiometricRequest(app,loanAppId);          
            return uidaiBiometricRequest;
        }
        catch(Exception ex)
        {
            ErrorLoggerUtil.logErrorEvent('IND_UidaiBiometricService', 'getUidaiBiometricRequest', System.Label.Apex, ex,loanAppId);
            throw new AuraHandledException(ex.getMessage());         
        }  
    }
    
}