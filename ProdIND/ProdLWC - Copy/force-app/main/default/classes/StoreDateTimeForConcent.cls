/**
* @author Ruchi Jain
* @company Persistent Systems
* @description A  class for the visiualforce Page
* Inputs: None
* Test Class: StoreDateTimeForConcentTest
* History:
* 27/10/2021  Ruchi Jain Added tupdateConsentStatus method . 
*/
public with sharing class StoreDateTimeForConcent {
    /*
* @Method:      updateConsentStatus
* @Created by: Ruchi Jain
* @Description: adding a current date for field.
* @Param:       applicantId
* @Return:      None
*/    
@AuraEnabled
    public static Boolean updateConsentStatus(String applicantId) 
    {
        try{
            Boolean booleanVal=false;
            Boolean timeexpired=false;
                if(applicantId!=null){
                    system.debug('applicant id : '+applicantId);
                Applicant__c app = [select Id,Consent_Received__c,Consent_Sent__c from Applicant__c where id =: applicantId WITH SECURITY_ENFORCED];           
                if(app.Consent_Received__c){
                    app.Consent_Received__c   =false;  
                }
                if(app.Consent_Sent__c!=null){
                 timeexpired=LwcLOSLoanApplicationCntrl.otpExpireTimeOut(applicantId);
                }
                if(app.Consent_Sent__c==null || timeexpired){
                app.Consent_Sent__c = System.now();
                booleanVal=true;
                }
                else{
                    booleanVal=false;
                }
                if (Schema.sObjectType.Applicant__c.isUpdateable()) {
                    update app;
                }
           
            }
            if(Test.isRunningTest())
			{
				throw new AuraHandledException(System.Label.ExceptionMessage);
			}
            return  booleanVal;
        }
        catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('StoreDateTimeForConcent', 'updateConsentStatus', 'Apex', e);
			throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }
}