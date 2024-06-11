global class ScheduleEmailSendDemoCompleted implements Schedulable {
 global void execute(SchedulableContext sc) {
        // Call your invocable method
        EmailSendDemoCompleted.sendToEmail();
    }
}