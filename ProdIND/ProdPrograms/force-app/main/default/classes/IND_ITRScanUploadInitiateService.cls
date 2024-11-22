/*------------------------------------------------------------
Author: Satyam More
Company: Persistent Systems
Description: This class is service class for IND_ITRScanUploadInitiate API
Test Class: 
History
Date            Author              Comments
------------------------------------------------------------- 
02-02-2022    Satyam More             Created
------------------------------------------------------------*/

public class IND_ITRScanUploadInitiateService {
/*
* @Method:      getScanUploadInitiate
* @Created by:  Aman Mundhada
* @Description: Method to return Request for IND_ScanUploadInitiate
* @Param:       Object - RequestWrapper
* @Return:      Object - IND_ScanUploadInitiateRequest 
*/
     public static IND_ITRScanUploadInitiateRequest getITRScanUploadInitiate(Applicant__c app, String loanAppId,String panNo){
        try
        {    
            IND_ITRScanUploadInitiateRequest itrScanUploadInitiate = new IND_ITRScanUploadInitiateRequest(app, loanAppId,panNo);
            return itrScanUploadInitiate;
        }
        catch(Exception ex){
            ErrorLoggerUtil.logErrorEvent('IND_ITRScanUploadInitiateService', 'getITRScanUploadInitiate', System.Label.Apex, ex,loanAppId);
            throw new IND_Exception(ex.getMessage());         
        }  
    }
}