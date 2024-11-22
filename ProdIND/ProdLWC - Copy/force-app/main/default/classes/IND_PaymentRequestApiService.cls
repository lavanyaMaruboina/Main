/*------------------------------------------------------------
Author: Neeraj Mehethrajkar
Company: Salesforce
Description: This class is service class for the Payment Request API. SFTRAC-241
Test Class: 
History
Date            Author              Comments
------------------------------------------------------------- 
29-11-2023     Neeraj Mehethrajkar  Created
------------------------------------------------------------*/
public class IND_PaymentRequestApiService {

    /*
    * @Method:      getPaymentRequestCallOutRequest
    * @Created by:  Neeraj Mehethrajkar
    * @Description: This method will process the 
    * @Param:       Object - RequestWrapper 
    * @Return:      Object - IND_PaymentRequestApiRequest type request
    */
    public static IND_PaymentRequestApiRequest getPaymentRequestCallOutRequest(String loanAppId, String dealId){
        try {
            IND_PaymentRequestApiRequest paymentRequest = new IND_PaymentRequestApiRequest(loanAppId, dealId);
            return paymentRequest;
        }
        catch(Exception ex){
            ErrorLoggerUtil.logErrorEvent('IND_PaymentRequestApiService', 'getPaymentRequestCallOutRequest', System.Label.Apex, ex,loanAppId);
            throw new IND_Exception(ex.getMessage());          
        } 
    }
}