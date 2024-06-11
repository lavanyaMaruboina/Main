global class ScheduleOnHoldORRejected implements Schedulable {
 global void execute(SchedulableContext sc) {
        // Call your invocable method
        CreateAndSendCSVFileRejectHoldViaEmail1.createAndSendCSVFile();
    }
}