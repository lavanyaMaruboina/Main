/*------------------------------------------------------------
Author:        Rajat Jaiswal
Description:   This class is service class to WeightedIRR API
Test Class:     
History
Date            Author              Comments
-------------------------------------------------------------
24-03-2023     Rajat Jaiswal       Created
------------------------------------------------------------*/
public class IND_WeightedIRRService {
    /* @Method:      getWeightedIRRRequest
     * @Created by:  Rajat Jaiswal
     * @Description: This method will returns valid request for WeightedIRR API.
     * @Param:       Object - Applicant
     * @Return:      Object - IND_WeightedIRRRequest type reponse */
         public static IND_WeightedIRRRequest getWeightedIRRRequest(String empId,String loanAppId){
         try{
             IND_WeightedIRRRequest weightedIRRRequest = new IND_WeightedIRRRequest(empId,loanAppId);//only validation and setting headers
             return weightedIRRRequest;
         }
         catch(Exception ex){
             ErrorLoggerUtil.logErrorEvent('IND_WeightedIRRRequest', 'getWeightedIRRRequest', System.Label.Apex, ex,loanAppId);
             throw new IND_Exception(ex.getMessage());   
         }
     }
 }