@isTest
public class TaskTriggerTest {

    @isTest
    static void testTaskCreationOnApplicanInsert1() {
        Opportunity opp = TestDataUtility.createTestOpportunityForEligibleMaster(true);
            
        Applicant__c app = TestDataUtility.createTestApplicantForDSA(true,opp);

        Task newTask = new Task();
        newTask.Subject = 'Follow Up';
        newTask.Status = 'Not Started';
        newTask.Priority = 'Normal';
        newTask.WhatId = app.Id;
        newTask.ActivityDate = Date.today().addDays(7);
        newTask.Description = 'Follow up with the customer regarding their requirements.';
        
        Test.startTest();
        insert newTask;
		
        // Verify that a task has been created for the account
        List<Task> tasks = [SELECT Id, Subject, WhatId FROM Task WHERE WhatId = :app.Id];
        System.assertEquals(1, tasks.size());
        
        Test.stopTest();
    }

}