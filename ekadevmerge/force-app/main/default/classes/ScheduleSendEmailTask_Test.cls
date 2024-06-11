@isTest
public class ScheduleSendEmailTask_Test {
  @isTest
    static void testSendToTaskEmail() {
        
        Date tomorrowDate = Date.today().addDays(1);
        Task testTask = new Task(
            Subject = 'Test Task',
            Status = 'Open',
            ActivityDate = tomorrowDate
        );
        insert testTask;
        Date tomorrowDate1 = Date.today().addDays(1);
        Task testTask1 = new Task(
            Subject = 'Test Task',
            Status = 'Open',
            ActivityDate = Date.newInstance(2024, 30, 01)
        );
        insert testTask1;
        
            Test.startTest();            
            SendEmailTasks.sendToEmail();
            Test.stopTest();
        
    }
}