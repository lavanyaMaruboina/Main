public with sharing class OpportunityLocationController {
    @AuraEnabled
    public static Map<String, Integer> getTopleads() 
    {
        
        Map<String, Integer> result = new Map<String, Integer>();

        // Count the number of leads with Demo_Scheduled_date_time__c today
        AggregateResult demoCount = [SELECT COUNT(Id) FROM Lead WHERE Demo_Scheduled_date_time__c = TODAY];
        result.put('DemoCount', Integer.valueOf(demoCount.get('expr0')));
    
        // Count the number of leads with Expected_Payments__c today
        AggregateResult paymentsCount = [SELECT COUNT(Id) FROM Lead WHERE Expected_Payments__c = TODAY];
        result.put('PaymentsCount', Integer.valueOf(paymentsCount.get('expr0')));
    
        // Count the number of leads with Call__c today
        AggregateResult callCount = [SELECT COUNT(Id) FROM Lead WHERE Call__c = TODAY];
        result.put('CallCount', Integer.valueOf(callCount.get('expr0')));
    
        return result;
    
    }
    
}