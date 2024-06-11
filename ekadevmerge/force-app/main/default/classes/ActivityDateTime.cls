public with sharing class ActivityDateTime {

    @AuraEnabled
    public static string insertactivity(String activityDateTime) {
        try {
            Opportunity opp = new Opportunity();
            opp.Activity_Date_Time__c = DateTime.valueOf(activityDateTime);
            insert opp;
            return opp.Id;
        } catch (Exception e) {
            return e.getMessage();
        }
    }
}