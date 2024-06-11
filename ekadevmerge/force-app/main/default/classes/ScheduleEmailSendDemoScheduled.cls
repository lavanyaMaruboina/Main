global class ScheduleEmailSendDemoScheduled implements Schedulable {
 global void execute(SchedulableContext sc) {
        // Call your invocable method
        EmailSendDemoScheduled.sendToEmail();
    }
}