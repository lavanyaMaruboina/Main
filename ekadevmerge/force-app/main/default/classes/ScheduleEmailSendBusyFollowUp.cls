global class ScheduleEmailSendBusyFollowUp implements Schedulable {
 global void execute(SchedulableContext sc) {
        // Call your invocable method
        EmailSendBusyFollowUp.sendToEmail();
    }
}