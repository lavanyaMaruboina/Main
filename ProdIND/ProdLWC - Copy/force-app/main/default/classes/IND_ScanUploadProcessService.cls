/*------------------------------------------------------------
Author: Aman Mundhada
Company: Persistent Systems
Description: This class is service class for IND_ScanUploadProcess API
Test Class: IND_ScanUploadProcessService_Test
History
Date            Author              Comments
------------------------------------------------------------- 
04-01-2022    Aman Mundhada            Created
------------------------------------------------------------*/
public class IND_ScanUploadProcessService {

    /*
* @Method:      getScanUploadProcess
* @Created by:  Aman Mundhada
* @Description: Method to return Request for IND_ScanUploadProcess
* @Param:       Object - RequestWrapper
* @Return:      Object - IND_ScanUploadProcessRequest 
*/
     public static IND_ScanUploadProcessRequest getScanUploadProcess(RequestWrapper requestWrapper){
        try
        {    
            IND_ScanUploadProcessRequest scanUploadProcess = new IND_ScanUploadProcessRequest(requestWrapper);
            return scanUploadProcess;
        }
        catch(Exception ex){
            ErrorLoggerUtil.logErrorEvent('IND_ScanUploadInitiateService', 'getScanUploadProcess', System.Label.Apex, ex,requestWrapper.loanApplicationId);
            throw new IND_Exception(ex.getMessage());         
        }  
    }
    
    
}