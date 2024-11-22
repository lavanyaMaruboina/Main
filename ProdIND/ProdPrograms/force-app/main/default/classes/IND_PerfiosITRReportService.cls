/*------------------------------------------------------------
Author:        Thilak Bondiga
Company:       Persistent
Description:   This class is service class to Perfios ITR Report API
Test Class:     
History
Date            Author              Comments
-------------------------------------------------------------
12-19-2021      Thilak Bondiga      Created
------------------------------------------------------------*/
public class IND_PerfiosITRReportService {
	/* @Method:      getPerfiosITRReportRequest
    * @Created by:  Thilak Bondiga
    * @Description: This method will returns valid request for Perfios ITR Report API.
    * @Param:       Object - Applicant
    * @Return:      Object - IND_PerfiosITRReportRequest type reponse */ 
    
    public static IND_PerfiosITRReportRequest getPerfiosITRReportRequest(Applicant__c app){
        try{
            IND_PerfiosITRReportRequest iTRReportRequest = new IND_PerfiosITRReportRequest(app);
            return iTRReportRequest;
        }
        catch(Exception ex){
            ErrorLoggerUtil.logErrorEvent('IND_PerfiosITRReportService', 'getPerfiosITRReportRequest', System.Label.Apex, ex);
            throw new AuraHandledException(ex.getMessage());   
        }
    }
}