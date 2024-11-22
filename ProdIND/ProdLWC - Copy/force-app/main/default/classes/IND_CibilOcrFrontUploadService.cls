/*------------------------------------------------------------
Author: Satyam More
Company: Persistent Systems
Description: This class is service class for the CIBIL OCR Front Upload API
Test Class: IND_CibilOcrFrontUploadService_Test
History
Date            Author              Comments
------------------------------------------------------------- 
27-10-2021    Satyam More            Created
------------------------------------------------------------*/

public class IND_CibilOcrFrontUploadService {
    /*
* @Method:      getCibilOcrFrontUploadCallOutRequest
* @Created by:  Satyam More 
* @Description: Method to return Response for CIBIL OCR Front Upload API
* @Param:       Object - Document
* @Return:      Object - IND_CibilOcrFrontUploadRequest type request
*/
    
    public static IND_CibilOcrFrontUploadRequest getCibilOcrFrontUploadCallOutRequest(Documents__c doc, String contentDocumentId,String loanAppId){
        try
        {
            IND_CibilOcrFrontUploadRequest ocrfuRequest = new IND_CibilOcrFrontUploadRequest(doc,contentDocumentId,loanAppId);
            return ocrfuRequest;
        }
        catch(Exception ex){
                    ErrorLoggerUtil.logErrorEvent('IND_CibilOcrFrontUploadService', 'getCibilOcrFrontUploadCallOutRequest', System.Label.Apex, ex,loanAppId);
            throw new IND_Exception(ex.getMessage());           
        }
    }
}