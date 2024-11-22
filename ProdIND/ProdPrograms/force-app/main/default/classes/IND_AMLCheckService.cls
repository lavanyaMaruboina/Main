/*------------------------------------------------------------
Author: Vaishnavi Gadewar
Company: Persistent Systems
Description: This class is service class for the AML Check API
Test Class: IND_AMLCheckService_Test
History
Date            Author              Comments
------------------------------------------------------------- 
28-12-2021    Vaishnavi Gadewar         Created
------------------------------------------------------------*/

public class IND_AMLCheckService {
	public static IND_AMLCheckRequest getAMLCheckRequest(Applicant__c app, String loanAppId){
        try{
            IND_AMLCheckRequest request = new IND_AMLCheckRequest(app);
            return request;
        }
        catch(Exception ex){
            ErrorLoggerUtil.logErrorEvent('IND_AMLCheckService', 'getAMLCheckRequest', System.Label.Apex, ex, loanAppId);
            throw new IND_Exception(ex.getMessage());   
        }
    }
}