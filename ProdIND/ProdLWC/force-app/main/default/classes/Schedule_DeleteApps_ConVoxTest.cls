/*------------------------------------------------------------
Author:        Haarika Chodisetti
Company:       Salesforce
Description:   This class is to test methods of Schedule_DeleteApplicants_ConVox
History
Date            Author              Comments
-------------------------------------------------------------
16-08-2022      Haarika Chodisetti         Created
------------------------------------------------------------*/
@isTest
private class Schedule_DeleteApps_ConVoxTest
{

    /*
     * @Method:      callApi
     * @Created by:  Haarika Chodisetti
     * @Description: Tests the functionality of Schedule_DeleteApplicants_ConVox with the help of CTIMockHttpClass
     * @Param:       
     * @Return:     
     History
     Date            Author              Comments
     -------------------------------------------------------------
     16-08-2022      Haarika Chodisetti         Created
     ------------------------------------------------------------*/
    static testmethod void schedulerTest() 
    {
        String CRON_EXP = '0 0 0 15 3 ? *';
        
        // Create your test data
        Opportunity opp = TestDataUtility.createTestOpportunity(true);
        Applicant__c app = TestDataUtility.createTestApplicantService(true, opp);
        app.Disposition__c = IntegrationConstants.DISPOSITION_NOT_INTERESTED;
        update app;
        ConVox_Configuration__c configValues = ConVox_Configuration__c.getInstance();
        configValues.EndPoint__c = IntegrationConstants.CONVOX_END_POINT;
        upsert configValues; 
        
        Test.startTest();

			Test.setMock(HttpCalloutMock.class, New CTIMockHttpClass());     
            String jobId = System.schedule('Schedular Test',  CRON_EXP, new Schedule_DeleteApplicants_ConVox());
            CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
            System.assertEquals(CRON_EXP, ct.CronExpression);
            System.assertEquals(0, ct.TimesTriggered);

        Test.stopTest();
        
    }
}