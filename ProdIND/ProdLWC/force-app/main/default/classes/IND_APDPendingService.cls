/*------------------------------------------------------------
Author:        Bondiga Thilak
Company:       Persistent
Description:   This class is service class to APD Pending API
Test Class:     
History
Date            Author              Comments
-------------------------------------------------------------
12-28-2021      Bondiga Thilak      Created
------------------------------------------------------------*/
public class IND_APDPendingService {
   /* @Method:      getAPDPendingRequest
    * @Created by:  Bondiga Thilak
    * @Description: This method will returns valid request for CAM Portfolio API.
    * @Param:       Object - Applicant
    * @Return:      Object - IND_APDPendingRequest type reponse */
    public static IND_APDPendingRequest getAPDPendingRequest(Applicant__c app,String loanAppId){
        try{
            IND_APDPendingRequest apdpendingRequest = new IND_APDPendingRequest(app,loanAppId);//only validation and setting headers
            return apdpendingRequest;
        }
        catch(Exception ex){
            ErrorLoggerUtil.logErrorEvent('IND_APDPendingRequest', 'getAPDPendingRequest', System.Label.Apex, ex,loanAppId);
            throw new IND_Exception(ex.getMessage());   
        }
    }
}