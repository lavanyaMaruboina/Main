public with sharing class LeaveLogController {
    @AuraEnabled
    public static void saveLeaveLogRecord(Date startDate, Date endDate,String Reason) {
        Leave_logs__c leaveLog = new Leave_logs__c();
        leaveLog.leave_start_date__c = Date.valueOf(startDate);
        leaveLog.leave_end_date__c = Date.valueOf(endDate);
        leaveLog.Reason__c = Reason;
        insert leaveLog;
    }
}