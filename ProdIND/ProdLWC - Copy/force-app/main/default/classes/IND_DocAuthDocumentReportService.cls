/*------------------------------------------------------------
Author: Satyam More
Company: Persistent Systems
Description: This class is service class for the Document Report API
Test Class: 
History
Date            Author              Comments
------------------------------------------------------------- 
19-11-2021    Satyam More            Created
------------------------------------------------------------*/

public class IND_DocAuthDocumentReportService {
    /*
* @Method:      drCallout
* @Created by:  Satyam More
* @Description: This method will process the Document Report API
* @Param:       Object - Applicant Object 
* @Return:      Object - IND_DocAuthDocumentReportResponse type response
*/
    public static IND_DocAuthDocumentReportResponse drCallout(Applicant__c app){
        try
        {
            /*IND_DocAuthDocumentReportRequest drRequest = new IND_DocAuthDocumentReportRequest(app);
            CalloutProcessor processor = new CalloutProcessor(System.Label.DocumentReport,drRequest);
            IND_DocAuthDocumentReportResponse response = (IND_DocAuthDocumentReportResponse)processor.process();*/
            return null;
        }
        catch(Exception ex){
            ErrorLoggerUtil.logErrorEvent('IND_DocAuthDocumentReportService', 'drCallout', System.Label.Apex, ex);
            throw new AuraHandledException(ex.getMessage());
        }  
    }
    
    public static void DocAuthReportAsyncCallout(Applicant__c app){
        try
        {
            //IND_DocAuthDocumentReportRequest drRequest = new IND_DocAuthDocumentReportRequest(app);
           // CalloutProcessor processor = new CalloutProcessor(System.Label.DocumentReport,drRequest);
           // processor.processAsync();
            
        }
        catch(Exception ex){
            ErrorLoggerUtil.logErrorEvent('IND_DocAuthDocumentReportService', 'drCallout', System.Label.Apex, ex);
            throw new AuraHandledException(ex.getMessage());
        }  
    }
}