/*------------------------------------------------------------
Author:        Yugandhar
Company:       Persistent
Description:   This class is service class to Initiate NeSL EAgreement API
Test Class:    
History
Date            Author              Comments
-------------------------------------------------------------
12-31-2021      Yugandhar             Created
------------------------------------------------------------*/
public class IND_InitiateNeSLEAgreementService {
    
    @testVisible
    public static Boolean induceException;
    
    /* @Method:      getInitiateNeSLEAgreementRequest
    * @Created by:  Yugandhar
    * @Description: This method will returns valid request for Initiate NeSL Agreement API.
    * @Param:       Object - Applicant 
                    String - loanAppId,initiationMethod
    * @Return:      Object - IND_InitiateNeSLEAgreementRequest type reponse */
   
    public static IND_InitiateNeSLEAgreementRequest getInitiateNeSLEAgreementRequest(Applicant__c app,String loanAppId,String initiationMethod,String dealId){ // Gaurav Changes
        try{
            if(induceException == true) {
                throw new IND_Exception('Test Exception');
            }
            IND_InitiateNeSLEAgreementRequest initiateNeSLRequest = new IND_InitiateNeSLEAgreementRequest(app,loanAppId,initiationMethod,dealId);// Gaurav Changes
            return initiateNeSLRequest;
        }
        catch(Exception ex){
            ErrorLoggerUtil.logErrorEvent('IND_InitiateNeSLEAgreementService', 'getInitiateNeSLEAgreementRequest', System.Label.Apex, ex,loanAppId);
            throw new  IND_Exception(ex.getMessage()); 
       }
    }
}