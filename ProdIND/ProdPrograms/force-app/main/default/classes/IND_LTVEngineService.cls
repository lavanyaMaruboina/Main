/*------------------------------------------------------------
Author:        Bondiga Thilak
Company:       Persistent
Description:   This class is service class to LTV Engine API
Test Class:     
History
Date            Author              Comments
-------------------------------------------------------------
12-22-2021      Bondiga Thilak      Created
------------------------------------------------------------*/
public class IND_LTVEngineService {
   /* @Method:      getLTVEngineRequest
    * @Created by:  Bondiga Thilak
    * @Description: This method will returns valid request for LTV Engine  API.
    * @Param:       Object - Applicant
    * @Return:      Object - IND_LTVEngineRequest */
    public static IND_LTVEngineRequest getLTVEngineRequest(Opportunity opp,String loanAppId,RequestWrapper requestWrapper){
        try{
            IND_LTVEngineRequest ltvengineRequest = new IND_LTVEngineRequest(opp,requestWrapper);
            return ltvengineRequest;
        }
        catch(Exception ex){
            ErrorLoggerUtil.logErrorEvent('IND_LTVEngineRequest', 'getLTVEngineRequest', System.Label.Apex, ex,loanAppId);
            throw new IND_Exception(ex.getMessage());   
        }
    }
}