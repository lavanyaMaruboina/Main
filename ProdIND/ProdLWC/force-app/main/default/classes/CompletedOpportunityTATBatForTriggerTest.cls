@isTest
public class CompletedOpportunityTATBatForTriggerTest {
    
    @testSetup
    static void setup() {
        // Insert initial Opportunity data needed for the test
        List<Opportunity> opps = new List<Opportunity>();
        
        // Create Opportunities with initial stages
        for (Integer i = 0; i < 5; i++) {
            Opportunity opp = new Opportunity(
                Name = 'Test Opportunity ' + i,
                StageName = 'Prospecting', // Initial Stage
                CloseDate = System.today().addDays(30),
                Amount = 50000
            );
            opps.add(opp);
        }
        insert opps;
        
        // Update StageName to simulate stage history
        for (Opportunity opp : [SELECT Id FROM Opportunity]) {
            opp.StageName = 'Loan Application'; // New stage
        }
        update opps;
    }

    //We have another TAT reports. So commenting this code
    // @isTest
    // static void testBatchProcessing() {
    //     // Fetch the Opportunity IDs
    //     List<Opportunity> opportunities = [SELECT Id FROM Opportunity];
    //     Set<Id> opportunityIds = new Set<Id>();
    //     for (Opportunity opp : opportunities) {
    //         opportunityIds.add(opp.Id);
    //     }
        
    //     // Initialize the batch class with Opportunity IDs
    //     CompletedOpportunityTATBatchForTrigger batch = new CompletedOpportunityTATBatchForTrigger(opportunityIds);
        
    //     Test.startTest();
        
    //     // Execute the batch class
    //     Database.executeBatch(batch);
        
    //     // Simulate asynchronous processing
    //     Test.stopTest();
        
    //     // Validate that the TAT_Report__c records were created/updated
    //     List<TAT_Report__c> tatReports = [SELECT Id, Loan_Application__c, Loan_Initiation__c, Credit_Processing__c, Disbursement_Request_Preparation__c, Post_Sanction_Checks_and_Documentation__c, Pre_Disbursement_Check__c 
    //                                       FROM TAT_Report__c];
                                          
    //     // Assert that TAT records were created or updated
    //     System.assert(tatReports.size() > 0, 'TAT_Report__c records should have been created or updated.');
        
    //     // Additional assertions to check field values, if needed
    //     for (TAT_Report__c tatReport : tatReports) {
    //         System.assertNotEquals(null, tatReport.Loan_Application__c, 'Loan_Application__c should not be null.');
    //         // You can add further assertions for other fields if required
    //     }
    // }
}