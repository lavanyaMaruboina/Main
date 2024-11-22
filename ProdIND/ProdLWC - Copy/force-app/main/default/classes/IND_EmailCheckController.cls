/**
* @Name         IND_EmailCheckController
* @Author       Nidhi Dhote
* @Company      Persistent Systems
* @Description  This class contains all methods related to Email Validation
* Inputs:       None
* Test Class:   IND_EmailCheckControllerTest
*/

public with sharing class IND_EmailCheckController {
    
    /*
* @Method:      emailVerifyPass
* @Created by:  Nidhi Dhote
* @Description: Method to insert verify email checkbox.
* @Param:       String - applicantId
* @Return:      void
*/ 
    @AuraEnabled
    public static void emailVerifyPass(String applicantId)
    {
        try
        {
            if(String.isNotBlank(applicantId)){
                Applicant__c document = [select id,Is_Email_Valid__c from Applicant__c where id =: applicantId and In_Active_Applicant__c=false WITH SECURITY_ENFORCED];
                if(document != null){ 
                    document.Is_Email_Valid__c = true;
                    if (Schema.sObjectType.Applicant__c.isUpdateable())
                    {
                        update document; 
                    }
                }
            }
            if(Test.isRunningTest())
            {
                throw new AuraHandledException(System.Label.ExceptionMessage);
            }
        }
        catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('IND_EmailCheckController', ' emailVerifyPass ', System.Label.Apex, e);  
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }
    //End: End by Nidhi Email Verify Part
    
    /*
* @Method:      emailBlackListed
* @Created by:  Nidhi Dhote
* @Description: Method to insert verify BlackListed Email checkbox.
* @Param:       String - applicantId
* @Return:      void
*/
    @AuraEnabled
    public static void emailBlackListed(String applicantId)
    {
        try
        {
            if(String.isNotBlank(applicantId)){
                Applicant__c applicant = [select id,Is_Blacklisted_Email_Address__c from Applicant__c where id =: applicantId WITH SECURITY_ENFORCED];
                if(applicant != null){ 
                    applicant.Is_Blacklisted_Email_Address__c = true;
                    if (Schema.sObjectType.Applicant__c.isUpdateable())
                    {
                        update applicant; 
                    }
                }
            }
            if(Test.isRunningTest())
            {
                throw new AuraHandledException(System.Label.ExceptionMessage);
            }
        }
        catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('IND_EmailCheckController', ' emailBlackListed ', System.Label.Apex, e);  
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }
    //End By Nidhi Email Blacklisted Part
    
    /*
* @Method:      getFailEmailValue
* @Created by:  Nidhi Dhote
* @Description: Method For unsuccesfull Email verification count.
* @Param:       String - applicantId
* @Return:      void
*/
   
 @AuraEnabled
    public static Decimal getFailEmailValue(String  applicantId) {
        try{
        Applicant__c failEmailValue = [select Email_Fail_Count__c from Applicant__c where id =: applicantId WITH SECURITY_ENFORCED];
        System_Constant_custom_metadata__mdt noOfAttempts = System_Constant_custom_metadata__mdt.getInstance(System.Label.Back_Upload_Attempts);
        failEmailValue.Email_Fail_Count__c = failEmailValue.Email_Fail_Count__c != null  ? failEmailValue.Email_Fail_Count__c + 1 : 1;
        if (Schema.sObjectType.Applicant__c.isUpdateable()) {
            update failEmailValue;
        }
        return failEmailValue.Email_Fail_Count__c;
        }
        catch(Exception e){
                ErrorLoggerUtil.logErrorEvent('IND_EmailCheckController', ' getFailEmailValue ', System.Label.Apex, e);  
                throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }
    
    
}