/*------------------------------------------------------------
Author:        Divya Jawale
Company:       Salesforce
Description:   This class is service class for the EPFO Auth API 
Test Class:    IND_EPFOAuthService_Test 
History
Date            Author              Comments
-------------------------------------------------------------
17-12-2021      Divya Jawale      Created
------------------------------------------------------------*/
public class IND_EPFOAuthService {
/*
    * @Method:      getEPFOAuthCallOut
    * @Created by:  Divya
    * @Description: This method will returns valid requestEPFO Auth API
    * @Param:       Object - Applicant String uanNumber 
    * @Return:      Object - IND_EPFOAuthRequest type request
    */
    public static IND_EPFOAuthRequest getEPFOAuthCallOut(Applicant__c app, String uanNumber, String loanAppId){
        try{
            IND_EPFOAuthRequest epfoAuthRequest = new IND_EPFOAuthRequest(app,uanNumber,loanAppId);//only validation and setting headers
            return epfoAuthRequest;
        }
        catch(Exception ex){
            ErrorLoggerUtil.logErrorEvent('IND_EPFOAuthService', 'getEPFOAuthCallOut', System.Label.Apex, ex,loanAppId);
            throw new IND_Exception(ex.getMessage());   
        }
    }
}