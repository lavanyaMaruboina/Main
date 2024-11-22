/*------------------------------------------------------------
Author:        Divya Jawale
Company:       Persistent Systems
Description:   This class is service class for the MFC Fetch Valuation Report API 
Test Class:    IND_MFCFetchValuationReportService_Test 
History
Date            Author              Comments
-------------------------------------------------------------
04-01-2022      Divya Jawale      Created
------------------------------------------------------------*/
public class IND_MFCFetchValuationReportService {
 /*
* @Method:      getMFCFetchValuationReportRequest
* @Created by:  Divya Jawale 
* @Description: Method to return Response for MFC Fetch Valuation Report API
* @Param:       Object - RequestWrapper
* @Return:      IND_MFCFetchValuationReportRequest type request
*/
    public static IND_MFCFetchValuationReportRequest getMFCFetchValuationReportRequest(RequestWrapper requestWrapper){
        try
        {
            IND_MFCFetchValuationReportRequest request = new IND_MFCFetchValuationReportRequest(requestWrapper);            
            return request;
        }
        catch(Exception ex){
            ErrorLoggerUtil.logErrorEvent('IND_MFCFetchValuationReportService', 'getMFCFetchValuationReportRequest', System.Label.Apex, ex);
            throw new IND_Exception(ex.getMessage());          
        }  
    }
}