/*------------------------------------------------------------
Author: Parimal shinde & Vishal Gadhave 
Company: Nanostuffs 
Description: This class is service class for the Reverce Status API
Test Class: 
History
Date            Author                                    Comments
------------------------------------------------------------- 
15-09-2022       Parimal shinde & Vishal Gadhave           Created
------------------------------------------------------------*/




public class IND_ReverseStatusService {
     /*
* @Method:      getRevercestatusCallOutRequest
* @Created by:  Parimal shinde & Vishal Gadhave
* @Description: This method will process the Reverce Status 
*/
   
    public static ParentAPIRequest getReverseStatusCallOutRequest(Id loanAppId,String status, String code){
        try {
            //CISP-21374 Start
            Opportunity opp = [SELECT Id, LeadSource FROM Opportunity WHERE Id =:loanAppId WITH SECURITY_ENFORCED];
            if(opp.LeadSource == System.Label.Mahindra_Custom_Lead_API_Value || opp.LeadSource == System.Label.Mahindra_PreA_Lead_API_Value){
                IND_MahindraReverseStatusRequest reverseStatusRequest = new IND_MahindraReverseStatusRequest(loanAppId,status, code);
                return reverseStatusRequest;
            }else{
            //CISP-21374 End
                IND_ReverseStatusRequest reverseStatusRequest = new IND_ReverseStatusRequest(loanAppId,status, code);
                return reverseStatusRequest;
            }
        }
        catch(Exception ex){ErrorLoggerUtil.logErrorEvent('IND_ReverseStatusService', 'getRevercestatusCallOutRequest', System.Label.Apex, ex,loanAppId);throw new IND_Exception(ex.getMessage()); } 
    }

}