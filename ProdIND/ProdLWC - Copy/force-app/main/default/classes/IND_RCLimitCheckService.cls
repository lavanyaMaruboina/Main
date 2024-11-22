/*------------------------------------------------------------
Author:        Bondiga Thilak
Company:       Persistent
Description:   This class is service class to RCLimitCheck API
Test Class:     
History
Date            Author              Comments
-------------------------------------------------------------
01-28-2022     Bondiga Thilak      Created
------------------------------------------------------------*/
public class IND_RCLimitCheckService {
    /* @Method:    getRCLimitCheckRequest
     * @Created by:  Bondiga Thilak
     * @Description: This method will returns valid request for Deal Master API.
     * @Param:       Object - Applicant
     * @Return:      Object - IND_RCLimitCheckRequest type reponse */
     public static IND_RCLimitCheckRequest getRCLimitCheckRequestPerDeal(Applicant__c app,String loanAppId,String dealId){
         try{
             IND_RCLimitCheckRequest rcRequest = new IND_RCLimitCheckRequest(app,loanAppId,dealId);//only validation and setting headers
             return rcRequest;
         }
         catch(Exception ex){
             ErrorLoggerUtil.logErrorEvent('IND_RCLimitCheckRequest', 'getRCLimitCheckRequest', System.Label.Apex, ex,loanAppId);
             throw new IND_Exception(ex.getMessage());   
         }
     }
 
     public static IND_RCLimitCheckRequest getRCLimitCheckRequest(Applicant__c app,String loanAppId,String callType, String dealId){
         try{
             IND_RCLimitCheckRequest rcRequest = new IND_RCLimitCheckRequest(app,loanAppId,callType,dealId);//only validation and setting headers
             return rcRequest;
         }
         catch(Exception ex){
             ErrorLoggerUtil.logErrorEvent('IND_RCLimitCheckRequest', 'getRCLimitCheckRequest', System.Label.Apex, ex,loanAppId);
             throw new IND_Exception(ex.getMessage());   
         }
     }
 }