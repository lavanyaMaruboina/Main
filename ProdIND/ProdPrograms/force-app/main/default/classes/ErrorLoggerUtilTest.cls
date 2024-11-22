@isTest
public class ErrorLoggerUtilTest {
    
    public class OtherException extends Exception{
        public string name;
    }
    
    @isTest
    public static void logErrorEventTest(){
        
        Opportunity ope1 = new Opportunity();
        ope1.StageName = 'Qualification';
        ope1.CloseDate = Date.newInstance(2021, 1, 11);
        ope1.Name = 'testone';
        insert ope1;
        
        OtherException oe1 = new OtherException();
        
        ErrorLogEvent__e LogEntry = new ErrorLogEvent__e();
        LogEntry.Class_Name__c = 'utility';
        LogEntry.Method_Name__c = 'getAccount';
        LogEntry.Error_Message__c = 'testerror';
        LogEntry.Error_Stacktrace__c = 'lineno56';
        LogEntry.Error_Cause__c = 'fieldmissing';
        LogEntry.Line_Number__c = 23;
        LogEntry.Session_Id__c = UserInfo.getSessionId();
        LogEntry.Error_Type__c = 'testerror';
        LogEntry.Loan_Application_ID__c = ope1.Id;
        
        
        Test.startTest();
        ErrorLoggerUtil.logErrorEvent('utility','getAccount','dmlexeption',oe1,ope1.Id);
        Test.stopTest();
        List<Error_Log__c> lstRecords = [SELECT Id FROM Error_Log__c WHERE Class_Name__c = 'utility' AND Method_Name__c = 'getAccount'];
        System.assert(!lstRecords.isEmpty());
    }
    
    @isTest
    public static void logErrorEventTest1(){
        
        OtherException oe2 = new OtherException();
        Test.startTest();
        ErrorLoggerUtil.logErrorEvent('utility','getOpportunity','testdml',oe2);
        Test.stopTest();
        List<Error_Log__c> lstRecords = [SELECT Id FROM Error_Log__c WHERE Class_Name__c = 'utility' AND Method_Name__c = 'getOpportunity'];
        System.assert(!lstRecords.isEmpty());
    }
    
    @isTest
    public static void logErrorTest(){
        OtherException oe3 = new OtherException();
        Test.startTest();
        Error_Log__c objErrorLog = ErrorLoggerUtil.logError('utility','getAccount','testdml',oe3);
        Test.stopTest();
        System.assert(objErrorLog.Class_Name__c == 'utility');
        System.assert(objErrorLog.Method_Name__c == 'getAccount');
    }
}