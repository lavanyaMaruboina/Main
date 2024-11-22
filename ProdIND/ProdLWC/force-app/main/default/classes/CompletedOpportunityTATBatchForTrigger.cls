global class CompletedOpportunityTATBatchForTrigger implements Database.Batchable<SObject>, Database.Stateful {
    private Set<Id> opportunityIds;
 
    // Constructor to accept the Opportunity IDs from the trigger
    global CompletedOpportunityTATBatchForTrigger(Set<Id> oppIds) {
        this.opportunityIds = oppIds;
    }
 
    global Database.QueryLocator start(Database.BatchableContext BC) {
        // Query the Opportunities based on the provided IDs
        return Database.getQueryLocator([
            SELECT Id, CreatedDate, StageName, Payment_Request_Generation_Date__c
            FROM Opportunity 
            WHERE Id IN :opportunityIds
        ]);
    }
 
    global void execute(Database.BatchableContext BC, List<SObject> scope) {
        //We have another TAT reports. So commenting this code
        // List<TAT_Report__c> tatRecordsToUpsert = new List<TAT_Report__c>();
        // Set<Id> opportunityIds = new Set<Id>();
 
        // // Collect Opportunity IDs from the scope
        // for (SObject s : scope) {
        //     Opportunity opp = (Opportunity) s;
        //     opportunityIds.add(opp.Id);
        // }
 
        // // Query Stage History for the Opportunities
        // List<OpportunityHistory> stageHistories = [
        //     SELECT Id, OpportunityId, StageName, CreatedDate
        //     FROM OpportunityHistory
        //     WHERE OpportunityId IN :opportunityIds
        //     ORDER BY CreatedDate ASC
        // ];
 
        // // Map to store the stage history for each Opportunity by stage name
        // Map<Id, Map<String, Datetime>> stageHistoryMap = new Map<Id, Map<String, Datetime>>();
        // for (OpportunityHistory history : stageHistories) {
        //     if (!stageHistoryMap.containsKey(history.OpportunityId)) {
        //         stageHistoryMap.put(history.OpportunityId, new Map<String, Datetime>());
        //     }
        //     stageHistoryMap.get(history.OpportunityId).put(history.StageName, history.CreatedDate);
        // }
 
        // // Process each Opportunity and update TAT fields
        // for (SObject s : scope) {
        //     Opportunity opp = (Opportunity) s;
        //     TAT_Report__c tatRecord;
 
        //     // Check if a TAT record already exists for this Opportunity
        //     List<TAT_Report__c> existingTATs = [
        //         SELECT Id, Loan_Application__c, Loan_Initiation__c, Credit_Processing__c, Disbursement_Request_Preparation__c, Post_Sanction_Checks_and_Documentation__c, Pre_Disbursement_Check__c 
        //         FROM TAT_Report__c 
        //         WHERE Loan_Application__c = :opp.Id 
        //         LIMIT 1
        //     ];
 
        //     if (!existingTATs.isEmpty()) {
        //         tatRecord = existingTATs[0];
        //     } else {
        //         tatRecord = new TAT_Report__c(Loan_Application__c = opp.Id);
        //     }
 
        //     // Update fields based on the stage history for each Opportunity
        //     Map<String, Datetime> stagesForOpp = stageHistoryMap.get(opp.Id);
        //     if (stagesForOpp != null) {
        //         tatRecord.Loan_Initiation__c = stagesForOpp.get('Loan Initiation');
        //         tatRecord.Credit_Processing__c = stagesForOpp.get('Credit Processing');
        //         tatRecord.Disbursement_Request_Preparation__c = stagesForOpp.get('Disbursement Request Preparation');
        //         tatRecord.Post_Sanction_Checks_and_Documentation__c = stagesForOpp.get('Post Sanction Checks and Documentation');
        //         tatRecord.Pre_Disbursement_Check__c = stagesForOpp.get('Pre Disbursement Check');
        //     }
 
        //     tatRecordsToUpsert.add(tatRecord);
        // }
 
        // // Upsert the TAT records in bulk
        // if (!tatRecordsToUpsert.isEmpty()) {
        //     upsert tatRecordsToUpsert;
        // }
    }
 
    global void finish(Database.BatchableContext BC) {
        System.debug('Batch process for TAT records completed.');
    }
}