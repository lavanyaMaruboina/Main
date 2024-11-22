/*------------------------------------------------------------
Author: Satyam More
Company: Persistent Systems
Description: This class is service class for the Pack Lms API
Test Class: 
History
Date            Author              Comments
------------------------------------------------------------- 
21-1-2022      Satyam More            Created
------------------------------------------------------------*/

public class IND_PactLmsService {
 /*
* @Method:      getPactLmsCallOutRequest
* @Created by:  Satyam More
* @Description: This method will process the PAN Verification API
* @Param:       Object - RequestWrapper 
* @Return:      Object - IND_PanVerificationRequest type request
*/
   
    public static IND_PactLmsRequest getPactLmsCallOutRequest(String loanAppId, String dealId){
        try {
            IND_PactLmsRequest pactLmsRequest = new IND_PactLmsRequest(loanAppId, dealId);
            return pactLmsRequest;
        }
        catch(Exception ex){
            ErrorLoggerUtil.logErrorEvent('IND_PactLmsService', 'getPactLmsCallOutRequest', System.Label.Apex, ex,loanAppId);
            throw new IND_Exception(ex.getMessage());          
        } 
    }
}