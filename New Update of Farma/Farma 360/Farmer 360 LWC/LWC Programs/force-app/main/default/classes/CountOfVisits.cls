public without sharing class CountOfVisits {
    
    // Wrapper class to hold the visit counts
    public class VisitCounts {
        @AuraEnabled public Integer farmerPlannedVisits;
        @AuraEnabled public Integer farmerExecutedVisits;
        @AuraEnabled public Integer dealerPlannedVisits;
        @AuraEnabled public Integer dealerExecutedVisits;

        // Constructor
        
        public VisitCounts(Integer farmerPlanned, Integer farmerExecuted, Integer dealerPlanned, Integer dealerExecuted) {
            this.farmerPlannedVisits = farmerPlanned;
            this.farmerExecutedVisits = farmerExecuted;
            this.dealerPlannedVisits = dealerPlanned;
            this.dealerExecutedVisits = dealerExecuted;
        }
    }

    // Method to get all visit counts for a given user
    @AuraEnabled(cacheable=true)
    public static VisitCounts getVisitCounts(Id userId) {
        Integer farmerPlanned = getFarmerPlannedVisits(userId);
        Integer farmerExecuted = getFarmerExecutedVisits(userId);
        Integer dealerPlanned = getDealerPlannedVisits(userId);
        Integer dealerExecuted = getDealerExecutedVisits(userId);
        
        return new VisitCounts(farmerPlanned, farmerExecuted, dealerPlanned, dealerExecuted);
    }
	 @AuraEnabled
    public static Integer getFarmerPlannedVisits(Id userId) {
        List<Visit__c> farmerPlannedVisits = [SELECT Id FROM Visit__c 
                                              WHERE CreatedById = :userId 
                                              AND Status__c = 'Planned' 
                                              AND CreatedDate = TODAY 
                                              AND Visit_Location__c = 'Farmer'];
        System.debug('FarmerPlannedVisits Value Count is: ' + farmerPlannedVisits.size());
        return farmerPlannedVisits.size();
    }
	 @AuraEnabled
    public static Integer getFarmerExecutedVisits(Id userId) {
        List<Visit__c> farmerExecutedVisits = [SELECT Id FROM Visit__c 
                                               WHERE CreatedById = :userId 
                                               AND Status__c = 'Completed' 
                                               AND CreatedDate = TODAY 
                                               AND Visit_Location__c = 'Farmer'];
        System.debug('FarmerExecutedVisits Value Count is: ' + farmerExecutedVisits.size());
        return farmerExecutedVisits.size();
    }
	 @AuraEnabled
    public static Integer getDealerPlannedVisits(Id userId) {
        List<Visit__c> dealerPlannedVisits = [SELECT Id FROM Visit__c 
                                              WHERE CreatedById = :userId 
                                              AND Status__c = 'Planned' 
                                              AND CreatedDate = TODAY 
                                              AND Visit_Location__c = 'Dealer'];
        System.debug('DealerPlannedVisits Value Count is: ' + dealerPlannedVisits.size());
        return dealerPlannedVisits.size();
    }
	 @AuraEnabled
    public static Integer getDealerExecutedVisits(Id userId) {
        List<Visit__c> dealerExecutedVisits = [SELECT Id FROM Visit__c 
                                               WHERE CreatedById = :userId 
                                               AND Status__c = 'Completed' 
                                               AND CreatedDate = TODAY 
                                               AND Visit_Location__c = 'Dealer'];
        System.debug('DealerExecutedVisits Value Count is: ' + dealerExecutedVisits.size());
        return dealerExecutedVisits.size();
    }
}