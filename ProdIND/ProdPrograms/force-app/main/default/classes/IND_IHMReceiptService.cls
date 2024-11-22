/*------------------------------------------------------------
Author:        Bharath Moka
Company:       Persistent
Description:   This class is service class to IHM Receipt Online API
Test Class:     
History
Date            Author              Comments
-------------------------------------------------------------
12-29-2021      Bharath Moka      Created
------------------------------------------------------------*/

public class IND_IHMReceiptService {
	/* @Method:      getIHMReceiptOnlineRequest
    * @Created by:  Bharath Moka
    * @Description: This method will returns valid request for IHM Receipt Online API.
    * @Param:       Object - Applicant
    * @Return:      Object - IND_IHMReceiptOnlineRequest type reponse */
    
    public static IND_IHMReceiptRequest getIHMReceiptRequest(Applicant__c app,String loanAppId,String dealId){
        try{
            IND_IHMReceiptRequest receiptRequest = new IND_IHMReceiptRequest(app,loanAppId,dealId);
            return receiptRequest;
        }
        catch(Exception ex){
            ErrorLoggerUtil.logErrorEvent('IND_IHMReceiptService', 'getIHMReceiptRequest', System.Label.Apex, ex,loanAppId);
            throw new IND_Exception(ex.getMessage());    
        }
    }
}