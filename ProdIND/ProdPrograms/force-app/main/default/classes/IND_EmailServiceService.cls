/*------------------------------------------------------------
Author: Satyam More
Company: Persistent Systems
Description: This class is service class for the Email Service API
Test Class: 
History
Date            Author              Comments
------------------------------------------------------------- 
03-01-2022    Satyam More            Created
------------------------------------------------------------*/

public class IND_EmailServiceService {
/*
* @Method:      getEmailServiceCallOutRequest
* @Created by:  Satyam More
* @Description: This method will process Email Service API
* @Param:       Object - RequestWrapper 
* @Return:      Object - IND_EmailServiceRequest type request
*/
   
    public static IND_EmailServiceRequest getEmailServiceCallOutRequest(RequestWrapper requestWrapper){
        try
        {
            IND_EmailServiceRequest emailServiceRequest = new IND_EmailServiceRequest(requestWrapper);
            return emailServiceRequest;
        }
        catch(Exception ex){
                        ErrorLoggerUtil.logErrorEvent('IND_EmailServiceService', 'getEmailServiceCallOutRequest', System.Label.Apex, ex,requestWrapper.loanApplicationId);
            throw new IND_Exception(ex.getMessage());          
        } 
    }
}