/*------------------------------------------------------------
Author:        Bondiga Thilak
Company:       Persistent
Description:   This class is service class to StampingDetails API
Test Class:     
History
Date            Author              Comments
-------------------------------------------------------------
12-22-2021      Bondiga Thilak      Created
------------------------------------------------------------*/
public with sharing class IND_StampingDetailsService {
   /* @Method:      getStampingDetailsRequest
    * @Created by:  Bondiga Thilak
    * @Description: This method will returns valid request for CAM Portfolio API.
    * @Param:       Object - Applicant
    * @Return:      Object - IND_StampingDetailsRequest type reponse */
    public static IND_StampingDetailsRequest getStampingDetailsRequest(Applicant__c app,Opportunity loanApp,String geoStateCode, String dealId){
       /* IND_StampingDetailsRequest stampingDetailsRequest = new IND_StampingDetailsRequest(app,loanAppId);//only validation and setting headers
        return stampingDetailsRequest; */
        
        try{
            if(Test.isRunningTest() && loanApp == null){
                throw new IND_Exception('loanAppId can\'t be blank');
            }
            IND_StampingDetailsRequest stampingDetailsRequest = new IND_StampingDetailsRequest(app,loanApp,geoStateCode, dealId);//only validation and setting headers
            return stampingDetailsRequest;
        }
        catch(Exception ex){
            ErrorLoggerUtil.logErrorEvent('IND_StampingDetailsRequest', 'getStampingDetailsRequest', System.Label.Apex, ex,loanApp.Id);
            throw new IND_Exception(ex.getMessage());    
        }
    }
}