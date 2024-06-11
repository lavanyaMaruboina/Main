global class DailyScheduleRunTrainingSchedule implements Schedulable {
 global void execute(SchedulableContext sc) {
        // Call your invocable method
        // Related Taining Schedule Activity Status
        EmailSendTrainingScheduled.sendToEmail();
    }
}