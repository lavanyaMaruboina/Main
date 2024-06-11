global class ScheduleEmailSendOnboarded implements Schedulable {
 global void execute(SchedulableContext sc) {
        // Call your invocable method
        EmailSendOnboarded.sendToEmail();
    }
}