@isTest
private class Schedule_batchDeleteApps_ConVoxTest
{

    static testmethod void schedulerTest() 
    {
        String CRON_EXP = '0 0 0 15 3 ? *';
        
        // Create your test data
        Opportunity opp = TestDataUtility.createTestOpportunity(true);
        Applicant__c app = TestDataUtility.createTestApplicantService(true, opp);
        app.Disposition__c = 'Not Interested';
        update app;
        ConVox_Configuration__c configValues = ConVox_Configuration__c.getInstance();
        configValues.EndPoint__c = IntegrationConstants.CONVOX_END_POINT;
        upsert configValues; 
        Test.startTest();

			Test.setMock(HttpCalloutMock.class, New MockHttpClass());        
            String jobId = System.schedule('Schedular Test',  CRON_EXP, new Schedule_DeleteApplicants_ConVox());
            CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
            System.assertEquals(CRON_EXP, ct.CronExpression);
            System.assertEquals(0, ct.TimesTriggered);

        Test.stopTest();
        
    }
}