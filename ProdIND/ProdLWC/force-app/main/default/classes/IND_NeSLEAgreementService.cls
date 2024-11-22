/*------------------------------------------------------------
Author:        Bondiga Thilak
Company:       Persistent
Description:   This class is service class to NeSL Agreement Status API
Test Class:     
History
Date            Author              Comments
-------------------------------------------------------------
12-22-2021      Bondiga Thilak      Created
------------------------------------------------------------*/
public class IND_NeSLEAgreementService {
   /* @Method:    getNeSLEAgreementRequest
    * @Created by:  Bhushan Charde
    * @Description: This method will returns valid request for Deal Master API.
    * @Param:       Object - Applicant
    * @Return:      Object - IND_NeSLEAgreementRequest type reponse */
    public static IND_NeSLEAgreementRequest getNeSLEAgreementRequest(Applicant__c app,String loanAppId){
        IND_NeSLEAgreementRequest neSLEAgreement = new IND_NeSLEAgreementRequest(app,loanAppId);//only validation and setting headers
        return neSLEAgreement;
        /*try{
            IND_NeSLEAgreementRequest neSLEAgreement = new IND_NeSLEAgreementRequest(app,loanAppId);//only validation and setting headers
            return neSLEAgreement;
        }
        catch(Exception ex){
            ErrorLoggerUtil.logErrorEvent('IND_NeSLEAgreementRequest', 'getNeSLEAgreementRequest', System.Label.Apex, ex,loanAppId);
            throw new IND_Exception(ex.getMessage());   
        }*/
    }
}