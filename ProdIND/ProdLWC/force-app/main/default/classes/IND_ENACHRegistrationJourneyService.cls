/*------------------------------------------------------------
Author:        Bhushan charde
Company:       Persistent Systems
Description:   This class is service class for the ENACH Registration Journey API 
Test Class:    IND_ENACHRegistrationJourneyService_Test 
History
Date            Author              Comments
-------------------------------------------------------------
12-28-2021      Bhushan charde     Created
------------------------------------------------------------*/
public class IND_ENACHRegistrationJourneyService {
    /*
* @Method:      getRegiJourneyCallOutRequest
* @Created by:  Bhushan charde
* @Description: This method will returns valid request Registration Journey API
* @Param:       Object - Applicant Object 
* @Return:      Object - IND_ENACHRegistrationJourneyRequest type request
*/
  public static IND_ENACHRegistrationJourneyRequest getRegiJourneyCallOutRequest(Applicant__c app, String loanAppId,String dealId){
      try{
          IND_ENACHRegistrationJourneyRequest enachRequest = new IND_ENACHRegistrationJourneyRequest(app,loanAppId,dealId);
          return enachRequest;
      }
      catch(Exception ex){
          ErrorLoggerUtil.logErrorEvent('IND_ENACHRegistrationJourneyService', 'getRegiJourneyCallOutRequest', System.Label.Apex, ex, loanAppId);
          throw new AuraHandledException(ex.getMessage());   
      }
  }   
  
}