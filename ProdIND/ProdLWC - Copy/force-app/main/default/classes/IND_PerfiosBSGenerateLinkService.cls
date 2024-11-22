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
public class IND_PerfiosBSGenerateLinkService {
    
    // @Method:      membershipCallout
    // @Created by:  Manish Baldota
    // @Description: This method helps to perfrom the callout through callout processor class and return the response to calling method.
    // @Param:       Object - Applicant
    // @Return:      Object - IND_PerfiosBSGenerateLinkResponse type reponse   
    public static IND_PerfiosBSGenerateLinkRequest getCallOutRequest(RequestWrapper requestWrapper, string executivemobileno){
        try{
            IND_PerfiosBSGenerateLinkRequest request = new IND_PerfiosBSGenerateLinkRequest(requestWrapper, executivemobileno);
            return request;
        }
        catch(Exception ex){
            ErrorLoggerUtil.logErrorEvent('IND_PerfiosBSGenerateLinkService', 'getCallOutRequest', System.Label.Apex, ex);
            throw new IND_Exception(ex.getMessage());   
        }
    }
    
}