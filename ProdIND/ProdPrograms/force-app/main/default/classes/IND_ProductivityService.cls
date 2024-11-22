/*------------------------------------------------------------
Author:        Rajat Jaiswal
Description:   This class is service class to Productivity API
Test Class:     
History
Date            Author              Comments
-------------------------------------------------------------
24-03-2023     Rajat Jaiswal       Created
------------------------------------------------------------*/
public class IND_ProductivityService {
    /* @Method:      getProductivityRequest
     * @Created by:  Rajat Jaiswal
     * @Description: This method will returns valid request for Productivity API.
     * @Param:       Object - Applicant
     * @Return:      Object - IND_ProductivityRequest type reponse */
         public static IND_ProductivityRequest getProductivityRequest(String empId,String loanAppId){
         try{
             IND_ProductivityRequest productivityRequest = new IND_ProductivityRequest(empId,loanAppId);//only validation and setting headers
             return productivityRequest;
         }
         catch(Exception ex){
             ErrorLoggerUtil.logErrorEvent('IND_ProductivityRequest', 'getProductivityRequest', System.Label.Apex, ex,loanAppId);
             throw new IND_Exception(ex.getMessage());   
         }
     }
 }