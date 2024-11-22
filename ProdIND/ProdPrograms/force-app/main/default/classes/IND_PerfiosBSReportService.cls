/*------------------------------------------------------------
Author:        Manish Baldota
Company:       Persistent
Description:   This class is service class to Perfios Bank Account Statement API
Test Class:     
History
Date            Author              Comments
-------------------------------------------------------------
12-21-2021      Manish Baldota      Created
------------------------------------------------------------*/
public class IND_PerfiosBSReportService {
    
    // @Method:      membershipCallout
    // @Created by:  Manish Baldota
    // @Description: This method helps to perfrom the callout through callout processor class and return the response to calling method.
    // @Param:       Object - Applicant
    // @Return:      Object - IND_PerfiosBSGenerateLinkResponse type reponse   
    public static IND_PerfiosBSReportRequest getCallOutRequest(Applicant__c app, String loanAppId){
        try{
            if(app != null){
                IND_PerfiosBSReportRequest request = new IND_PerfiosBSReportRequest(app,loanAppId);
            return request;
            }else{
                throw new IND_Exception('Please provide applicant details.');   
            }
            
        }
        catch(Exception ex){
            ErrorLoggerUtil.logErrorEvent('IND_PerfiosBSReportService', 'getCallOutRequest', System.Label.Apex, ex);
            throw new IND_Exception(ex.getMessage());   
        }
    }
    
}