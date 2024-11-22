/*------------------------------------------------------------
Author: Satyam More
Company: Persistent Systems
Description: This class is service class for the DocAuth Create Applicant API
Test Class: IND_DocAuthCreateApplicantService_Test
History
Date            Author              Comments
------------------------------------------------------------- 
19-11-2021    Satyam More            Created
------------------------------------------------------------*/

public class IND_DocAuthCreateApplicantService {
/*
* @Method:      createapplicantCallout
* @Created by:  Satyam More
* @Description: This method will process the DocAuth Create Applicant API
* @Param:       Object - Applicant Object
* @Return:      Object - IND_DocAuthCreateApplicantRequest type request
*/
    
    public static IND_DocAuthCreateApplicantRequest getDocAuthCreateApplicantCallOutRequest(Applicant__c app,String loanAppId){
        try
        {
            IND_DocAuthCreateApplicantRequest createapplicantRequest = new IND_DocAuthCreateApplicantRequest(app,loanAppId);
            return createapplicantRequest;
        }
        catch(Exception ex){
            ErrorLoggerUtil.logErrorEvent('IND_DocAuthCreateApplicantService', 'getDocAuthCreateApplicantCallOutRequest', System.Label.Apex, ex,loanAppId);
            throw new IND_Exception(ex.getMessage());
        } 
    }
}