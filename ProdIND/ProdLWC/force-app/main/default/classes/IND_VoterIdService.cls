/*------------------------------------------------------------
Author: Aman Mundhada
Company: Persistent Systems
Description: This class is service class for the Voter Id API
Test Class: IND_VoterIdService_Test
History
Date            Author              Comments
------------------------------------------------------------- 
11-11-2021    Aman Mundhada            Created
------------------------------------------------------------*/

public class IND_VoterIdService {
    
 /*
* @Method:      getVoterIdCallOutRequest
* @Created by:  Aman Mundhada
* @Description: Method to return Request for Voter Id API
* @Param:       Object - RequestWrapper
* @Return:      Object - IND_VoterIdRequest type response
*/
     public static IND_VoterIdRequest getVoterIdCallOutRequest(RequestWrapper requestWrapper){
        try
        {    
            IND_VoterIdRequest voterIdRequest = new IND_VoterIdRequest(requestWrapper);
            return voterIdRequest;
        }
        catch(Exception ex){
            ErrorLoggerUtil.logErrorEvent('IND_VoterIdService', 'getVoterIdCallOutRequest', System.Label.Apex, ex,requestWrapper.loanApplicationId);
            throw new IND_Exception(ex.getMessage());         
        }  
    }
    
    
}