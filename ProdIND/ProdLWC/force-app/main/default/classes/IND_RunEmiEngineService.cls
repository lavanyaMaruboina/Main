/*------------------------------------------------------------
Author: Satyam More
Company: Persistent Systems
Description: This class is service class for the Run Emi Engine API
Test Class: 
History
Date            Author              Comments
------------------------------------------------------------- 
27-12-2021    Satyam More            Created
------------------------------------------------------------*/

public class IND_RunEmiEngineService {
/*
* @Method:      getRunEmiEngineCallOutRequest
* @Created by:  Satyam More
* @Description: This method will process the Run Emi Engine API
* @Param:       Object - RequestWrapper 
* @Return:      Object - IND_RunEmiEngineRequest type request
*/
    public static IND_RunEmiEngineRequest getRunEmiEngineCallOutRequest(RequestWrapper requestWrapper, String loanAppId){
        try
        {
            IND_RunEmiEngineRequest runEmiEngineRequest = new IND_RunEmiEngineRequest(requestWrapper,loanAppId);
            return runEmiEngineRequest;
        }
        catch(Exception ex){
                        ErrorLoggerUtil.logErrorEvent('IND_RunEmiEngineService', 'getRunEmiEngineCallOutRequest', System.Label.Apex, ex,loanAppId);
            throw new IND_Exception(ex.getMessage());          
        } 
    }
}