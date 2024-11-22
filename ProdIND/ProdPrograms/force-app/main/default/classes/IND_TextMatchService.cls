/*------------------------------------------------------------
Author: Satyam More
Company: Persistent Systems
Description: This class is service class for the Text Match API
Test Class: 
History
Date            Author              Comments
------------------------------------------------------------- 
09-01-2022    Satyam More            Created
------------------------------------------------------------*/

public class IND_TextMatchService {
    /*
* @Method:      getTextMatchCallOutRequest
* @Created by:  Satyam More
* @Description: This method will process the Text Match API
* @Param:       Object - RequestWrapper 
* @Return:      Object - IND_TextMatchRequest type request
*/

    public static IND_TextMatchRequest getTextMatchCallOutRequest(RequestWrapper requestWrapper){
        try
        {
            IND_TextMatchRequest textMatch = new IND_TextMatchRequest(requestWrapper);
            return textMatch;
        }
        catch(Exception ex){
                        ErrorLoggerUtil.logErrorEvent('IND_TextMatchService', 'getTextMatchCallOutRequest', System.Label.Apex, ex,requestWrapper.loanApplicationId);
            throw new AuraHandledException(ex.getMessage());          
        } 
    }
}