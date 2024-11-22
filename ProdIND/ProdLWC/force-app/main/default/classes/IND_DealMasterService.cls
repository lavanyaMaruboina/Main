/*------------------------------------------------------------
Author:        Bondiga Thilak
Company:       Persistent
Description:   This class is service class to Deal Master API
Test Class:     
History
Date            Author              Comments
-------------------------------------------------------------
12-22-2021      Bondiga Thilak      Created
------------------------------------------------------------*/
public class IND_DealMasterService {
   /* @Method:    getDealMasterRequest
    * @Created by:  Bondiga Thilak
    * @Description: This method will returns valid request for Deal Master API.
    * @Param:       Object - Applicant
    * @Return:      Object - IND_DealMasterRequest type reponse */
    public static IND_DealMasterRequest getDealMasterRequest(Applicant__c app,String loanAppId){
        try{
            IND_DealMasterRequest dealMasterRequest = new IND_DealMasterRequest(app,loanAppId);//only validation and setting headers
            return dealMasterRequest;
        }
        catch(Exception ex){
            ErrorLoggerUtil.logErrorEvent('IND_DealMasterRequest', 'getDealMasterRequest', System.Label.Apex, ex,loanAppId);
            throw new IND_Exception(ex.getMessage());   
        }
    }

    /* @Method:    getDealMasterRequest
    * @Created by:  Daksh Mandowara
    * @Description: This method will returns valid request for Deal Master API.
    * @Param:       String - Deal Number, String - Lead Number
    * @Return:      Object - IND_DealMasterRequest type reponse */
    public static IND_DealMasterRequest getDealMasterRequest(String dealNumber,String leadNumber, String loanAppId){
        try{
            IND_DealMasterRequest dealMasterRequest = new IND_DealMasterRequest(dealNumber,leadNumber);//only validation and setting headers
            return dealMasterRequest;
        }
        catch(Exception ex){
            ErrorLoggerUtil.logErrorEvent('IND_DealMasterRequest', 'getDealMasterRequest', System.Label.Apex, ex,loanAppId);
            throw new IND_Exception(ex.getMessage());   
        }
    }
}