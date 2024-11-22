/*------------------------------------------------------------
Author:        Gaurav Rawat
Company:       
Description:   This class is service class to IND Fico Ddeviation API
Test Class:    
History
Date            Author              Comments
-------------------------------------------------------------
12-19-2021      Gaurav Rawat             Created
------------------------------------------------------------*/
public class IND_FicoDeviationServiceTractor {
    /* @Method:      getFicoDeviationRequest
    * @Created by:  Gaurav Rawat
    * @Description: This method will returns valid request for Perfios GST Online API.
    * @Param:       Object - Applicant
    * @Return:      Object - IND_FicoDeviationRequestTractor type reponse */
   
    public static IND_FicoDeviationRequestTractor getFicoDeviationRequest(String loanAppId, Opportunity opty){
        try{
            IND_FicoDeviationRequestTractor ficoDeviationRequest = new IND_FicoDeviationRequestTractor(loanAppId, opty);
            return ficoDeviationRequest;
        }
        catch(Exception ex){
            ErrorLoggerUtil.logErrorEvent('IND_FicoDeviationServiceTractor', 'getFicoDeviationRequest', System.Label.Apex, ex,loanAppId);
            throw new  IND_Exception(ex.getMessage()); 
       }
    }
}