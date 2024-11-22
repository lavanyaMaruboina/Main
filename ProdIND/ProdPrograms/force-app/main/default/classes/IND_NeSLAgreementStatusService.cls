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
public class IND_NeSLAgreementStatusService {
   /* @Method:    getNeSLAgreementStatusRequest
    * @Created by:  Bhushan Charde
    * @Description: This method will returns valid request for Deal Master API.
    * @Param:       Object - Applicant
    * @Return:      Object - IND_NeSLAgreementStatusRequest type reponse */
    public static IND_NeSLAgreementStatusRequest getNeSLAgreementStatusRequest(Applicant__c app,String loanAppId){
        IND_NeSLAgreementStatusRequest neSLAgreementStatusRequest = new IND_NeSLAgreementStatusRequest(app,loanAppId);//only validation and setting headers
        return neSLAgreementStatusRequest;
        /*try{
			IND_NeSLAgreementStatusRequest neSLAgreementStatusRequest = new IND_NeSLAgreementStatusRequest(app,loanAppId);//only validation and setting headers
            return neSLAgreementStatusRequest;
        }
        catch(Exception ex){
            ErrorLoggerUtil.logErrorEvent('IND_NeSLAgreementStatusRequest', 'getNeSLAgreementStatusRequest', System.Label.Apex, ex,loanAppId);
            throw new IND_Exception(ex.getMessage());   
        }*/
    }
}