public with sharing class OpportunityHelper {
    @AuraEnabled(cacheable=true)
    public static List<Opportunity> getOpportunityList() {
        return [SELECT Id, Name
            FROM opportunity];
    }
}