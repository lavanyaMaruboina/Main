global class CalculateDailyTravelDistanceScheduler implements Schedulable {
    
    global void execute(SchedulableContext sc) {
        CalculateDailyTravelDistance b = new CalculateDailyTravelDistance(); 
        database.executebatch(b);
    }
}