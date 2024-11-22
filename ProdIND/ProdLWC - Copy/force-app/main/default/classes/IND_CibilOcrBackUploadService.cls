/*------------------------------------------------------------
Author: Satyam More
Company: Persistent Systems
Description: This class is service class for the CIBIL OCR Back Upload API
Test Class: IND_CibilOcrBackUploadService_Test
History
Date            Author              Comments
------------------------------------------------------------- 
17-11-2021    Satyam More            Created
------------------------------------------------------------*/

public class IND_CibilOcrBackUploadService {
    /*
* @Method:      getCibilOcrBackUploadCallOutRequest
* @Created by:  Satyam More 
* @Description: Method to return Response for CIBIL OCR Back Upload API
* @Param:       Object - Document
* @Return:      Object - IND_CibilOcrBackUploadRequest type request
*/
    
    public static IND_CibilOcrBackUploadRequest getCibilOcrBackUploadCallOutRequest(Documents__c doc, String contentDocumentId,String loanAppId){
        try
        {
            IND_CibilOcrBackUploadRequest ocrbuRequest = new IND_CibilOcrBackUploadRequest(doc, contentDocumentId,loanAppId);
            return ocrbuRequest;
        }
        catch(Exception ex){
            ErrorLoggerUtil.logErrorEvent('IND_CibilOcrBackUploadService', 'ocrbuCallout', System.Label.Apex, ex,loanAppId);
            throw new IND_Exception(ex.getMessage());           
        }
    }
    
}