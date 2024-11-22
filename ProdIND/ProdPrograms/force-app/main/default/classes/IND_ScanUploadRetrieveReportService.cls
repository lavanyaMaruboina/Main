/*------------------------------------------------------------
Author: Aman Mundhada
Company: Persistent Systems
Description: This class is service class for IND_ScanUploadRetrieveReport API
Test Class: IND_ScanUploadReportGenerationService_Test
History
Date            Author              Comments
------------------------------------------------------------- 
11-02-2022    Aman Mundhada            Created
------------------------------------------------------------*/
public class IND_ScanUploadRetrieveReportService {

        /*
* @Method:      getScanUploadRetrieveReportRequest
* @Created by:  Aman Mundhada
* @Description: Method to return Request for IND_ScanUploadRetrieveReport
* @Param:       Object - RequestWrapper
* @Return:      Object - IND_ScanUploadRetrieveReportRequest 
*/
     public static IND_ScanUploadRetrieveReportRequest getScanUploadRetrieveReportRequest(){
        try
        {    
            IND_ScanUploadRetrieveReportRequest scanUploadRetrieveReport = new IND_ScanUploadRetrieveReportRequest();
            return scanUploadRetrieveReport;
        }
        catch(Exception ex){
            ErrorLoggerUtil.logErrorEvent('IND_ScanUploadRetrieveReportService', 'getScanUploadRetrieveReportRequest', System.Label.Apex, ex);
            throw new IND_Exception(ex.getMessage());         
        }  
    }
    
    
    
}