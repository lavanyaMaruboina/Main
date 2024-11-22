/*------------------------------------------------------------
Author: Aman Mundhada
Company: Persistent Systems
Description: This class is service class for IND_ScanUploadReportGeneration API
Test Class: IND_ScanUploadReportGenerationService_Test
History
Date            Author              Comments
------------------------------------------------------------- 
04-01-2022    Aman Mundhada            Created
------------------------------------------------------------*/
public class IND_ScanUploadReportGenerationService {

    /*
* @Method:      getScanUploadReportGenerationRequest
* @Created by:  Aman Mundhada
* @Description: Method to return Request for IND_ScanUploadReportGeneration
* @Param:       Object - RequestWrapper
* @Return:      Object - IND_ScanUploadReportGenerationRequest 
*/
    public static Boolean isFromTest = false;
    
    public static IND_ScanUploadReportGenerationRequest getScanUploadReportGenerationRequest(RequestWrapper requestWrapper){
        try{  
            if(isFromTest){
                throw new IND_Exception('script test exception');       
            }
            IND_ScanUploadReportGenerationRequest scanUploadReportGeneration = new IND_ScanUploadReportGenerationRequest();
            return scanUploadReportGeneration;
        }catch(Exception ex){
            ErrorLoggerUtil.logErrorEvent('IND_ScanUploadReportGenerationService', 'getScanUploadReportGenerationRequest', System.Label.Apex, ex,requestWrapper.loanApplicationId);
            throw new IND_Exception(ex.getMessage());         
        }  
    }
    
    
}