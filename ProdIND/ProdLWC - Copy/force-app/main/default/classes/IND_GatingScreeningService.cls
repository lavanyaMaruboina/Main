/*------------------------------------------------------------
Author: Aman Mundhada
Company: Persistent Systems
Description: This class is service class for the Gating Screening-Check Eligibility
Test Class: IND_GatingScreeningServiceTest
History
Date            Author              Comments
------------------------------------------------------------- 
16-12-2021    Aman Mundhada           Created
------------------------------------------------------------*/

public class IND_GatingScreeningService {
    /*
* @Method:      getGatingScreeningCallOutRequest
* @Created by:  Aman Mundhada 
* @Description: Method to return Request for Gating Screening-Check Eligibility
* @Param:       Object - RequestWrapper
* @Return:      Object - IND_GatingScreeningRequest type response
*/
    public static IND_GatingScreeningRequest getGatingScreeningCallOutRequest(RequestWrapper requestWrapper){
        try
        {    
            IND_GatingScreeningRequest gatingScreeningRequest = new IND_GatingScreeningRequest(requestWrapper);
            return gatingScreeningRequest;
        }
        catch(Exception ex){
            ErrorLoggerUtil.logErrorEvent('IND_GatingScreeningService', 'getGatingScreeningCallOutRequest', System.Label.Apex, ex);
            throw new IND_Exception(ex.getMessage());         
        }  
    }    
}