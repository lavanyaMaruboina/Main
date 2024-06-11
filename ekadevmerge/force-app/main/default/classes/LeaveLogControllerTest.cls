@isTest
private class LeaveLogControllerTest {

    @isTest
    static void testSaveLeaveLogRecord() {
        // Test data
        Date startDate = Date.newInstance(2024, 1, 1);
        Date endDate = Date.newInstance(2024, 1, 5);
        String reason = 'Vacation';

        // Call the method in the controller
        Test.startTest();
        LeaveLogController.saveLeaveLogRecord(startDate, endDate, reason);
        Test.stopTest();

        // Verify that a Leave_logs__c record was created
        list<Leave_logs__c> leaveLogsCount = [SELECT id FROM Leave_logs__c WHERE leave_start_date__c = :startDate AND leave_end_date__c = :endDate];
        System.assertEquals(1, leaveLogsCount.size(), 'Leave_logs__c record should be created');

        // Additional assertions can be added based on the specific requirements of your application
        // For example, you might want to check if certain fields in the created record have the expected values.
    }
}