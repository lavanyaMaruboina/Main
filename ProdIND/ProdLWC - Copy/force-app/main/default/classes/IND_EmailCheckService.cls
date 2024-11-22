/*------------------------------------------------------------
Author: Satyam More
Company: Persistent Systems
Description: This class is service class for the Email Check API
Test Class: IND_EmailCheckService_Test
History
Date            Author              Comments
------------------------------------------------------------- 
30-11-2021    Satyam More            Created
------------------------------------------------------------*/

public class IND_EmailCheckService {

    /*
* @Method:      getEmailCheckCallOutRequest
* @Created by:  Satyam More
* @Description: This method will process the Email Check API
* @Param:       Object - RequestWrapper 
* @Return:      Object - IND_EmailCheckRequest type request
*/
    
   public static IND_EmailCheckRequest getEmailCheckCallOutRequest(RequestWrapper requestWrapper,String loanAppId){
        try
        {
            IND_EmailCheckRequest emailcheckRequest = new IND_EmailCheckRequest(requestWrapper,loanAppId);
            return emailcheckRequest;
        }
        catch(Exception ex){
            ErrorLoggerUtil.logErrorEvent('IND_EmailCheckService', 'getEmailCheckCallOutRequest', System.Label.Apex, ex,loanAppId);
            throw new IND_Exception(ex.getMessage());        
        }     
} 
    
}