/*------------------------------------------------------------
Author: Bhushan Charde
Company: Persistent Systems
Description: This class is service class for IND_ScanUploadRetrieveReport API
Test Class: IND_ScanUploadReportGenerationService_Test
History
Date            Author              Comments
------------------------------------------------------------- 
11-02-2022    Bhushan Charde            Created
------------------------------------------------------------*/
public class IND_ITRScanUploadRetrieveReportService {
	
    
        /*
* @Method:      getITRScanUploadRetrieveReportRequest
* @Created by:  Bhushan Charde
* @Description: Method to return Request for IND_ITRScanUploadRetrieveReport
* @Param:       Object - RequestWrapper
* @Return:      Object - IND_ITRScanUploadRetrieveReportRequest 
*/
    public static IND_ITRScanUploadRetrieveReportRequest getITRScanUploadRetrieveReportRequest(){
        IND_ITRScanUploadRetrieveReportRequest scanUploadRetrieveReport = new IND_ITRScanUploadRetrieveReportRequest();
            return scanUploadRetrieveReport;
         /* try
        {    
            IND_ITRScanUploadRetrieveReportRequest scanUploadRetrieveReport = new IND_ITRScanUploadRetrieveReportRequest();
            return scanUploadRetrieveReport;
        }
        catch(Exception ex){
            ErrorLoggerUtil.logErrorEvent('IND_ITRScanUploadRetrieveReportRequest', 'getITRScanUploadRetrieveReportRequest', System.Label.Apex, ex);
            throw new IND_Exception(ex.getMessage());         
        }  */
    }
}