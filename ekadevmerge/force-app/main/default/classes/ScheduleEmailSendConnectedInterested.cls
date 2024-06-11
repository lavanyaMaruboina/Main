global class ScheduleEmailSendConnectedInterested implements Schedulable {
 global void execute(SchedulableContext sc) {
        // Call your invocable method
        EmailSendConnectedInterested1.sendToEmail();
    }
}