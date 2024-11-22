/*------------------------------------------------------------
Author: Satyam More
Company: Persistent Systems
Description: This class is service class for IND_ITRScanDocumentUpload API
Test Class: 
History
Date            Author              Comments
------------------------------------------------------------- 
07-02-2022    Satyam More             Created
------------------------------------------------------------*/

public class IND_ITRScanDocumentUploadService {
/*
* @Method:      getITRScanDocumentUpload
* @Created by:  Aman Mundhada
* @Description: Method to return Request for IND_ScanUploadInitiate
* @Param:       Object - RequestWrapper
* @Return:      Object - IND_ITRScanDocumentUploadRequest 
*/
     public static IND_ITRScanDocumentUploadRequest getITRScanDocumentUpload(Documents__c doc, String contentDocumentId,String perfiosTransactionId, String loanAppId){
        try
        {    
            IND_ITRScanDocumentUploadRequest itrScanDocumentUpload = new IND_ITRScanDocumentUploadRequest(doc,contentDocumentId,perfiosTransactionId, loanAppId);
            return itrScanDocumentUpload;
        }
        catch(Exception ex){
            ErrorLoggerUtil.logErrorEvent('IND_ITRScanUploadInitiateService', 'getITRScanDocumentUpload', System.Label.Apex, ex,loanAppId);
            throw new IND_Exception(ex.getMessage());         
        }  
    }
}