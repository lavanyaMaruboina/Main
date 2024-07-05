public with sharing class DealerCreation {
    @AuraEnabled
    public static Account createDealer (Account dealer) {
        system.debug('Dealer==============='+dealer);
        try {
            system.debug('Dealer==============='+dealer);
            insert dealer;
            system.debug('Dealer==============='+dealer);
            return dealer;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled(cacheable=true)
    public static List<String> getActiveTypePicklistValues() {
        List<String> picklistValues = new List<String>();
        Schema.DescribeFieldResult fieldResult = Account.Active__c.getDescribe();
        for (Schema.PicklistEntry entry : fieldResult.getPicklistValues()) {
            picklistValues.add(entry.getLabel());
        }
        return picklistValues;
    }
}