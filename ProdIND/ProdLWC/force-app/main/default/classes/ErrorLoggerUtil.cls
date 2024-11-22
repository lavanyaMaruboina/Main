/**********************************************************************************************************************************
* @Class Name - ErrorLoggerUtil
* @Created on: 20-Aug-2021
* @Modified on - 
* @description: This class will be used to handle the exception of every type.
*******************************************************************************************************************/
public class ErrorLoggerUtil{
   
    /**
    * @author: Manish Baldota
    * @company: Persistent System
    * @description: This method is being used to create ErrorLogEvent__e platform event.
    * Inputs: className - Class Name where error is thrown,
    * methodName - Method Name where error is thrown,
    * errorType - Context of Error Aura/Apex/LWC/Trigger etc. 
    * errorObject - record of Exception method
    * Returns: NA
    * History:
    * 12/08/2021 Manish Baldota Initial Developement 
    */
    public static void logErrorEvent(String className, String methodName, String errorType,Exception errorObject, String loanApplicationId){
        String beautifiedMessage = '';
        ErrorLogEvent__e errorLogEntry = new ErrorLogEvent__e(
            Class_Name__c = className,
            Method_Name__c = methodName,
            Error_Message__c = errorObject.getMessage(),
            Error_Stacktrace__c = errorObject.getStackTraceString(),
            Error_Cause__c = errorObject.getTypeName(),
            Line_Number__c = errorObject.getLineNumber(),
            Session_Id__c = UserInfo.getSessionId(),
            Error_Type__c = errorType,
            Loan_Application_ID__c = loanApplicationId
        );
        EventBus.publish(errorLogEntry);
    }
    
    /**
    * @author: Manish Baldota
    * @company: Persistent System
    * @description: This method is being used to create ErrorLogEvent__e platform event.
    * Inputs: className - Class Name where error is thrown,
    * methodName - Method Name where error is thrown,
    * errorType - Context of Error Aura/Apex/LWC/Trigger etc. 
    * errorObject - record of Exception method
    * Returns: NA
    * History:
    * 12/08/2021 Manish Baldota Initial Developement 
    */
    public static void logErrorEvent(String className, String methodName, String errorType,Exception errorObject){
        String beautifiedMessage = '';
        ErrorLogEvent__e errorLogEntry = new ErrorLogEvent__e(
            Class_Name__c = className,
            Method_Name__c = methodName,
            Error_Message__c = errorObject.getMessage(),
            Error_Stacktrace__c = errorObject.getStackTraceString(),
            Error_Cause__c = errorObject.getTypeName(),
            Line_Number__c = errorObject.getLineNumber(),
            Session_Id__c = UserInfo.getSessionId(),
            Error_Type__c = errorType
        );
        System.debug('errorLogEntry --> ' + errorLogEntry);
        EventBus.publish(errorLogEntry);
    }
    
    public static Error_Log__c logError(String className, String methodName, String errorType,Exception errorObject){
        String beautifiedMessage = '';
        Error_Log__c errorLogEntry = new Error_Log__c(
            Class_Name__c = className,
            Method_Name__c = methodName,
            Error_Message__c = errorObject.getMessage(),
            Error_Stacktrace__c = errorObject.getStackTraceString(),
            Error_Cause__c = errorObject.getTypeName(),
            Line_Number__c = errorObject.getLineNumber(),
            Session_Id__c = UserInfo.getSessionId(),
            Error_Type__c = errorType
        );
        return errorLogEntry;
    }
    /**
    * @author: Manish Baldota
    * @company: Persistent System
    * @description: This method is being used to create Error log record for Error_Log__c object
    * Inputs: ErrorLogEvent__e record [event]
    * Returns: Error_Log__c record to maintain the list in trigger.
    * History:
    * 12/08/2021 Manish Baldota Initial Developement 
    */
    public static Error_Log__c createErrorLogRecord(ErrorLogEvent__e event){
        Error_Log__c errorLogEntry = new Error_Log__c(Class_Name__c = event.Class_Name__c,
                                                      Method_Name__c = event.Method_Name__c,
                                                      Error_Message__c = event.Error_Message__c,
                                                      Error_Stacktrace__c = event.Error_Stacktrace__c,
                                                      Error_Cause__c = event.Error_Cause__c,
                                                      Line_Number__c = event.Line_Number__c,
                                                      Session_Id__c = event.Session_Id__c,
                                                      Error_Type__c = event.Error_Type__c,
                                                      Loan_Application__c = event.Loan_Application_ID__c,
                                                      ProCredit_Deals__c = event.ProCredit_Deal_Id__c);
        return errorLogEntry;
    }

    public static void logErrorEventProCreditDeal(String className, String methodName, String errorType,Exception errorObject, String ProCreditDeal_Id){
        String beautifiedMessage = '';
        ErrorLogEvent__e errorLogEntry = new ErrorLogEvent__e(
            Class_Name__c = className,
            Method_Name__c = methodName,
            Error_Message__c = errorObject.getMessage(),
            Error_Stacktrace__c = errorObject.getStackTraceString(),
            Error_Cause__c = errorObject.getTypeName(),
            Line_Number__c = errorObject.getLineNumber(),
            Session_Id__c = UserInfo.getSessionId(),
            Error_Type__c = errorType,
            ProCredit_Deal_Id__c = ProCreditDeal_Id            
        );
        EventBus.publish(errorLogEntry);
    }
}