/*------------------------------------------------------------
Author: Aman Mundhada
Company: Persistent Systems
Description: This class is service class for IND_ScanUploadInitiate API
Test Class: IND_ScanUploadInitiateService_Test
History
Date            Author              Comments
------------------------------------------------------------- 
03-01-2022    Aman Mundhada            Created
------------------------------------------------------------*/
public class IND_ScanUploadInitiateService {
/*
* @Method:      getScanUploadInitiate
* @Created by:  Aman Mundhada
* @Description: Method to return Request for IND_ScanUploadInitiate
* @Param:       Object - RequestWrapper
* @Return:      Object - IND_ScanUploadInitiateRequest 
*/
     public static IND_ScanUploadInitiateRequest getScanUploadInitiate(RequestWrapper requestWrapper){
        try
        {    
            IND_ScanUploadInitiateRequest scanUploadInitiate = new IND_ScanUploadInitiateRequest(requestWrapper);
            return scanUploadInitiate;
        }
        catch(Exception ex){
            ErrorLoggerUtil.logErrorEvent('IND_ScanUploadInitiateService', 'getScanUploadInitiate', System.Label.Apex, ex,requestWrapper.loanApplicationId);
            throw new IND_Exception(ex.getMessage());         
        }  
    }
    
    
}