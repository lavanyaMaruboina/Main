/*------------------------------------------------------------
Author:        kranthi makkena
Company:       Persistent
Description:   This class is service class to APD Pending API
Test Class:     
History
Date            Author              Comments
-------------------------------------------------------------
12-30-2021      kranthi makkena      Created
------------------------------------------------------------*/
public class IND_CustomerMasterCreationService {
     /* @Method:    getCustomerMasterCreationRequest
    * @Created by:  kranthi makkena
    * @Description: This method will returns valid request for CustomerMasterCreation API.
    * @Param:       Object - Applicant
    * @Return:      Object - IND_CustomerMasterCreationRequest type reponse */
     public static IND_CustomerMasterCreationRequest getCustomerMasterCreationRequest(Applicant__c app,String loanAppId, String religion, String caste, String district){
        try
        {
            //IND_CustomerMasterCreationRequest req = new  IND_CustomerMasterCreationRequest(app,loanAppId);
            IND_CustomerMasterCreationRequest req = new  IND_CustomerMasterCreationRequest(app,religion,caste,district);
            system.debug('***req'+req);
            return req;
        }
        catch(Exception ex){
            system.debug('***ex'+ex);
                        ErrorLoggerUtil.logErrorEvent('CustomerMasterCreationService', 'getCustomerMasterCreationRequest', System.Label.Apex, ex,loanAppId);
            throw new IND_Exception(ex.getMessage());         
        } 
    }

}