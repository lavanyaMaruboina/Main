/*------------------------------------------------------------
Author:        Prathik
Company:       Persistent
Description:   This class is service class to IND Fico Ddeviation API
Test Class:    
History
Date            Author              Comments
-------------------------------------------------------------
12-19-2021      Prathik             Created
------------------------------------------------------------*/
public class IND_FicoDeviationService {
    /* @Method:      getFicoDeviationRequest
    * @Created by:  Prathik
    * @Description: This method will returns valid request for Perfios GST Online API.
    * @Param:       Object - Applicant
    * @Return:      Object - IND_FicoDeviationRequest type reponse */
   
    public static IND_FicoDeviationRequest getFicoDeviationRequest(String loanAppId, Opportunity opty){
        try{
            IND_FicoDeviationRequest ficoDeviationRequest = new IND_FicoDeviationRequest(loanAppId, opty);
            return ficoDeviationRequest;
        }
        catch(Exception ex){
            ErrorLoggerUtil.logErrorEvent('IND_FicoDeviationService', 'getFicoDeviationRequest', System.Label.Apex, ex,loanAppId);
            throw new  IND_Exception(ex.getMessage()); 
       }
    }
}