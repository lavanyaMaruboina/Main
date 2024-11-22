/*------------------------------------------------------------
Author:        Bondiga Thilak
Company:       Persistent
Description:   This class is service class to Agreement Booklet API
Test Class:     
History
Date            Author              Comments
-------------------------------------------------------------
12-22-2021      Bondiga Thilak      Created
------------------------------------------------------------*/
public class IND_AgreementBookletService {
   /* @Method:      getAgreementBookletRequest
    * @Created by:  Bondiga Thilak
    * @Description: This method will returns valid request for CAM Portfolio API.
    * @Param:       Object - Applicant
    * @Return:      Object - IND_AgreementBookletRequest type reponse */
    public static IND_AgreementBookletRequest getAgreementBookletRequest(String bookletNo, Applicant__c app,String loanAppId,String dealId){
        try{
            IND_AgreementBookletRequest agreementBooklet = new IND_AgreementBookletRequest(bookletNo, app,loanAppId,dealId);//only validation and setting headers
            return agreementBooklet;
        }
        catch(Exception ex){
            ErrorLoggerUtil.logErrorEvent('IND_AgreementBookletRequest', 'getAgreementBookletRequest', System.Label.Apex, ex,loanAppId);
            throw new IND_Exception(ex.getMessage());   
        }
    }
}