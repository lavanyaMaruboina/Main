/*------------------------------------------------------------
Author:        Bhushan Charde
Company:       Persistent
Description:   This class is service class to Perfios GST Online API
Test Class:     
History
Date            Author              Comments
-------------------------------------------------------------
12-19-2021      Bhushan Charde      Created
------------------------------------------------------------*/
public class IND_PerfiosGSTOnlineService {
    /* @Method:      getPerfiosGSTOnlineRequest
    * @Created by:  Bhushan Charde
    * @Description: This method will returns valid request for Perfios GST Online API.
    * @Param:       Object - Applicant
    * @Return:      Object - IND_PerfiosGSTOnlineRequest type reponse */
    
    public static IND_PerfiosGSTOnlineRequest getPerfiosGSTOnlineRequest(RequestWrapper requestWrapper){
        try{
            IND_PerfiosGSTOnlineRequest gstOnlineRequest = new IND_PerfiosGSTOnlineRequest(requestWrapper);
            return gstOnlineRequest;
        }
        catch(Exception ex){
            ErrorLoggerUtil.logErrorEvent('IND_PerfiosGSTOnlineService', 'getPerfiosGSTOnlineRequest', System.Label.Apex, ex, requestWrapper.loanApplicationId);
            throw new IND_Exception(ex.getMessage());   
        }
    }
}