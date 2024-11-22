/*------------------------------------------------------------
Author: Aman Mundhada
Company: Persistent Systems
Description: This class is service class for the Passport API
Test Class: IND_PassportService_Test
History
Date            Author              Comments
------------------------------------------------------------- 
11-11-2021    Aman Mundhada           Created
------------------------------------------------------------*/


public class IND_PassportService {
    
      /*
* @Method:      getPPCallOutRequest
* @Created by:  Aman Mundhada 
* @Description: Method to return Request for Passport API
* @Param:       Object - RequestWrapper
* @Return:      Object - IND_PassportRequest type response
*/
      public static IND_PassportRequest getPPCallOutRequest(RequestWrapper requestWrapper){
        try
        {    
            IND_PassportRequest ppRequest = new IND_PassportRequest(requestWrapper);
            return ppRequest;
        }
        catch(Exception ex){
            ErrorLoggerUtil.logErrorEvent('IND_PassportService', 'getPPCallOutRequest', System.Label.Apex, ex,requestWrapper.loanApplicationId);
            throw new IND_Exception(ex.getMessage());         
        }  
    }
    
}