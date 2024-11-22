/*------------------------------------------------------------
Author:        chowdesha N
Company:       Persistent
Description:   This class is service class to CSRVahanFIwaiver API
Test Class:     
History
Date            Author              Comments
-------------------------------------------------------------
12-28-2021      Chowdesha N      Created
------------------------------------------------------------*/
public class IND_CSRVahanFIwaiverService {
   /* @Method:      getCSRVahanFIwaiverRequest
    * @Created by:  Chowdesha N
    * @Description: This method will returns valid request for CSRVahanFIwaiver API.
    * @Param:       Object - Applicant
    * @Return:      Object - IND_CSRVahanFIwaiverRequest type reponse */
    
    public static IND_CSRVahanFIwaiverRequest getCSRVahanFIwaiverRequest(RequestWrapper requestWrapper, List<Applicant__c> appList){
        try{
           IND_CSRVahanFIwaiverRequest CSRVahanFIwaiverRequest = new IND_CSRVahanFIwaiverRequest(requestWrapper,appList);
            return CSRVahanFIwaiverRequest;
            
        }
        catch(Exception ex){
            ErrorLoggerUtil.logErrorEvent('IND_CSRVahanFIwaiverRequest', 'getCSRVahanFIwaiverRequest', System.Label.Apex, ex,requestWrapper.loanApplicationId);
            throw new IND_Exception(ex.getMessage());   
        }
    }
}