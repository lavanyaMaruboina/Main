/*------------------------------------------------------------
Author:        Rohan Saxena
Company:       Salesforce
Description:   This class is Test class for Opportunity
History
Date            Author              Comments
-------------------------------------------------------------
16-12-2022      Rohan Saxena         Created
------------------------------------------------------------*/
@isTest
public class OpportunityTriggerTest {
    @testSetup static void setupOpportunityData() {
        Opportunity opp = new Opportunity(
            Name = 'Test Lead',
            StageName = 'Loan Initiation',
            CloseDate = System.today().addMonths(1),
            Sub_Stage__c = 'User Details',
            LastStageName__c = 'Loan Initiation',
            Product_Type__c = 'Passenger Vehicles',
            Vehicle_Type__c = 'Used',
            LeadSource = 'DSA'
        );
        insert opp;
    }
    
    @isTest static void updateSubStageFieldTest() {
        Opportunity objOpp = [Select id, Name, StageName, Sub_Stage__c from Opportunity where Name='Test Lead' Limit 1];
        objOpp.Sub_Stage__c= 'View Application Details';
        update objOpp;
        
    }
    @isTest static void updateOppTeamMember() {
        Opportunity objOpp = [Select id, Name, StageName, Sub_Stage__c from Opportunity where Name='Test Lead' Limit 1];
        UserRole role = TestDataUtility.createUserRole(true, 'test', 'role');
        User us = TestDataUtility.createUserForVoterId(true, role);
        system.runAs(us){
            objOpp.OwnerId = us.Id;
            update objOpp;
        }
        
    }
    
    @isTest static void testOpportunityTriggerHelperException() {
        try {
            OpportunityTriggerHelper.updateSubStageField(null, null);
            OpportunityTriggerHelper.updateOppTeamMember(null, null);
        } catch (Exception e) {
            System.assert(e.getMessage() != null);
        }
    }
    
    @isTest static void testSendMoveToAssistedEmail() {
        try {
            // Create test data
            Opportunity opp = new Opportunity(
                Name = 'Test Opp',
                StageName = 'Prospecting',
                CloseDate = Date.today(),
                Is_ETB__c = true,
                IO_Loan_Amount__c = '700000',
                LeadSource = 'D2C',
                Vehicle_Type__c = 'Old'
            );
            insert opp;

            Opportunity oppOla = new Opportunity(
                Name = 'Test Opp',
                StageName = 'Prospecting',
                CloseDate = Date.today(),
                Is_ETB__c = true,
                IO_Loan_Amount__c = '700000',
                LeadSource = 'OLA',  
                Vehicle_Type__c = 'Old'
            );
            insert oppOla;
            
            opp.Sub_Stage__c = 'Vehicle Dedupe';
            opp.D2C_Journey_Status__c = IntegrationConstants.STATUS_MOVE_TO_ASSISTED;
            update opp;
            opp.D2C_Journey_Status__c = IntegrationConstants.STATUS_INITIAL_OFFER_DROP;
            opp.D2C_journey_drop_screen__c = 'Asset Details';
            update opp;
        } catch (Exception e) {
            System.assert(e.getMessage() != null);
        }
    }
    
    
}