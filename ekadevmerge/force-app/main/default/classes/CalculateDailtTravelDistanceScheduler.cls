global class CalculateDailtTravelDistanceScheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        CalculateDailyTraveledDistance b = new CalculateDailyTraveledDistance(); 
        database.executebatch(b);
    }
}