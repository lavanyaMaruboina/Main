global class ScheduleSendEmailTask implements Schedulable {
 global void execute(SchedulableContext sc) {
        // Call your invocable method
        SendEmailTasks.sendToEmail();

}
}