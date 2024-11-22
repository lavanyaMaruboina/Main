/*------------------------------------------------------------
Author:        Bhushan Charde
Company:       Persistent
Description:   This class is service class to Perfios GST Report API
Test Class:     
History
Date            Author              Comments
-------------------------------------------------------------
12-23-2021      Bhushan Charde      Created
------------------------------------------------------------*/
public class IND_PerfiosGSTReportService {
	/* @Method:      getPerfiosGSTReportRequest
    * @Created by:  Thilak Bondiga
    * @Description: This method will returns valid request for Perfios GST Report API.
    * @Param:       Object - Applicant
    * @Return:      Object - IND_PerfiosGSTReportRequest type reponse */ 
    
    public static IND_PerfiosGSTReportRequest getPerfiosGSTReportRequest(Applicant__c app){
        try{
            IND_PerfiosGSTReportRequest gstReportRequest = new IND_PerfiosGSTReportRequest(app);
            return gstReportRequest;
        }
        catch(Exception ex){
            ErrorLoggerUtil.logErrorEvent('IND_PerfiosGSTReportService', 'getPerfiosGSTReportRequest', System.Label.Apex, ex);
            throw new AuraHandledException(ex.getMessage());   
        }
    }
}