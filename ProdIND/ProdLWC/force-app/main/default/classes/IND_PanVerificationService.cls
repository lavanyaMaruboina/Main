/*------------------------------------------------------------
Author: Satyam More
Company: Persistent Systems
Description: This class is service class for the PAN Verification API
Test Class: IND_PANVerficationService_Test
History
Date            Author              Comments
------------------------------------------------------------- 
20-10-2021    Satyam More            Created
------------------------------------------------------------*/

public class IND_PanVerificationService {
    /*
* @Method:      getPANVerificationCallOutRequest
* @Created by:  Satyam More
* @Description: This method will process the PAN Verification API
* @Param:       Object - RequestWrapper 
* @Return:      Object - IND_PanVerificationRequest type request
*/
   
    public static IND_PanVerificationRequest getPANVerificationCallOutRequest(RequestWrapper requestWrapper){
        try
        {
            IND_PanVerificationRequest panRequest = new IND_PanVerificationRequest(requestWrapper);
            return panRequest;
        }
        catch(Exception ex){
            ErrorLoggerUtil.logErrorEvent('IND_PanVerificationService', 'getPANVerificationCallOutRequest', System.Label.Apex, ex,requestWrapper.loanApplicationId);
            throw new IND_Exception(ex.getMessage());          
        } 
    }
}