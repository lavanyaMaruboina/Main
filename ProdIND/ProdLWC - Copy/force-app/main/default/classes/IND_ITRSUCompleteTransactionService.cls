/*------------------------------------------------------------
Author: Satyam More
Company: Persistent Systems
Description: This class is service class for IND_ITRSUCompleteTransaction API
Test Class: 
History
Date            Author              Comments
------------------------------------------------------------- 
03-02-2022    Satyam More            Created
------------------------------------------------------------*/

public class IND_ITRSUCompleteTransactionService {
    
    /*
* @Method:      getITRSUCompleteTransactionRequest
* @Created by:  Satyam More
* @Description: Method to return Request for IND_ScanUploadReportGeneration
* @Param:       Object - RequestWrapper
* @Return:      Object - IND_ScanUploadReportGenerationRequest 
*/
     public static IND_ITRSUCompleteTransactionRequest getITRSUCompleteTransactionRequest(String loanAppId){
        try
        {    
            IND_ITRSUCompleteTransactionRequest itsSUCompleteTransaction = new IND_ITRSUCompleteTransactionRequest();
            return itsSUCompleteTransaction;
        }
        catch(Exception ex){
            ErrorLoggerUtil.logErrorEvent('IND_ITRSUCompleteTransactionService', 'getITRSUCompleteTransactionRequest', System.Label.Apex, ex,loanAppId);
            throw new IND_Exception(ex.getMessage());         
        }  
    }

}