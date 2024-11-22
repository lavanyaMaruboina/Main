/*------------------------------------------------------------
Author:        Bhushan Charde
Company:       Persistent
Description:   This class is service class to Perfios ITR Online API
Test Class:     
History
Date            Author              Comments
-------------------------------------------------------------
12-19-2021      Bhushan Charde      Created
------------------------------------------------------------*/
public class IND_PerfiosITROnlineService {
    
	/* @Method:      getPerfiosITROnlineRequest
    * @Created by:  Bhushan Charde
    * @Description: This method will returns valid request for Perfios ITR Online API.
    * @Param:       Object - Applicant
    * @Return:      Object - IND_PerfiosITROnlineRequest type reponse */
    
    public static IND_PerfiosITROnlineRequest getPerfiosITROnlineRequest(RequestWrapper requestWrapper){
        try{
            IND_PerfiosITROnlineRequest itrOnlineRequest = new IND_PerfiosITROnlineRequest(requestWrapper);
            return itrOnlineRequest;
        }
        catch(Exception ex){
            ErrorLoggerUtil.logErrorEvent('IND_PerfiosITROnlineService', 'getPerfiosITROnlineRequest', System.Label.Apex, ex, requestWrapper.loanApplicationId);
            throw new IND_Exception(ex.getMessage());   
        }
    }
}