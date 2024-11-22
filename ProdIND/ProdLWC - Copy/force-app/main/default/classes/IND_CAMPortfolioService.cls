/*------------------------------------------------------------
Author:        Bondiga Thilak
Company:       Persistent
Description:   This class is service class to CAM Portfolio API
Test Class:     
History
Date            Author              Comments
-------------------------------------------------------------
12-22-2021      Bondiga Thilak      Created
------------------------------------------------------------*/
public class IND_CAMPortfolioService {
  /* @Method:      getCAMPortfolioRequest
    * @Created by:  Bondiga Thilak
    * @Description: This method will returns valid request for CAM Portfolio API.
    * @Param:       Object - Applicant
    * @Return:      Object - IND_CAMPortfolioRequest type reponse */
    public static IND_CAMPortfolioRequest getCAMPortfolioRequest(Applicant__c app,String loanAppId){
        try{
            IND_CAMPortfolioRequest camPortfolioMasterRequest = new IND_CAMPortfolioRequest(app,loanAppId);//only validation and setting headers
            return camPortfolioMasterRequest;
        }
        catch(Exception ex){
            ErrorLoggerUtil.logErrorEvent('IND_CAMPortfolioRequest', 'getCAMPortfolioRequest', System.Label.Apex, ex,loanAppId);
            throw new AuraHandledException(ex.getMessage());   
        }
    }
}