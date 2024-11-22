/*------------------------------------------------------------
Author:        Rohan Saxena
Company:       Salesforce
Description:   This class is Test class for RC Limit
History
Date            Author              Comments
-------------------------------------------------------------
16-12-2022      Rohan Saxena         Created
------------------------------------------------------------*/
@isTest 
public class DSA_RC_Limit_Dt_Test {
    @testSetup static void setupRCLimitData() {
        MIS_RC_Limit_Dt__c objRC_Limit = new MIS_RC_Limit_Dt__c(
            Name='test',
            Deal_No__c='1234',
            IBL_Lien_Marked__c='Y'    
        );
        insert objRC_Limit;
         MIS_RC_Limit_Dt__c objRC_Limit2 = new MIS_RC_Limit_Dt__c(
            Name='test',
            Deal_No__c='1235',
            IBL_Lien_Marked__c='N'    
        );
        insert objRC_Limit2;
        Opportunity opp = new Opportunity(
            Name = 'Test Lead',
            StageName = 'Loan Initiation',
            CloseDate = System.today().addMonths(1),
            Sub_Stage__c = 'User Details',
            LastStageName__c = 'Loan Initiation',
            Product_Type__c = 'Passenger Vehicles',
            Vehicle_Type__c = 'Used',
            LeadSource = 'DSA',
            Deal_Number__c = '1234'
        );
        insert opp;
        Opportunity opp2 = new Opportunity(
            Name = 'Test Lead',
            StageName = 'Loan Initiation',
            CloseDate = System.today().addMonths(1),
            Sub_Stage__c = 'User Details',
            LastStageName__c = 'Loan Initiation',
            Product_Type__c = 'Passenger Vehicles',
            Vehicle_Type__c = 'Used',
            LeadSource = 'DSA',
            Deal_Number__c = '1235'
        );
        insert opp2;
        Opportunity opp3 = new Opportunity(
            Name = 'Test Lead',
            StageName = 'Loan Initiation',
            CloseDate = System.today().addMonths(1),
            Sub_Stage__c = 'User Details',
            LastStageName__c = 'Loan Initiation',
            Product_Type__c = 'Passenger Vehicles',
            Vehicle_Type__c = 'Used',
            LeadSource = 'DSA',
            Deal_Number__c = '1236'
        );
        insert opp3;
        Opportunity opp4 = new Opportunity(
            Name = 'Test Lead',
            StageName = 'Loan Initiation',
            CloseDate = System.today().addMonths(1),
            Sub_Stage__c = 'User Details',
            LastStageName__c = 'Loan Initiation',
            Product_Type__c = 'Passenger Vehicles',
            Vehicle_Type__c = 'Used',
            LeadSource = 'DSA',
            Deal_Number__c = '1237'
        );
        insert opp4;
    }
    @isTest static void updateDisbursedfieldTest() {
        List<MIS_RC_Limit_Dt__c> lstRCLimit = [Select id, name,Deal_No__c,IBL_Lien_Marked__c from MIS_RC_Limit_Dt__c ];
        List<MIS_RC_Limit_Dt__c> updateRC = new List<MIS_RC_Limit_Dt__c>();
        for(MIS_RC_Limit_Dt__c RC: lstRCLimit){
            if(RC.IBL_Lien_Marked__c=='Y'){
                RC.IBL_Lien_Marked__c='N';
            }
            else{
                RC.IBL_Lien_Marked__c='Y';
            }
            updateRC.add(RC);
        }
        update updateRC;
        MIS_RC_Limit_Dt__c objRC_Limit = new MIS_RC_Limit_Dt__c(
            Name='test',
            Deal_No__c='1236',
            IBL_Lien_Marked__c='Y'    
        );
        insert objRC_Limit;
         MIS_RC_Limit_Dt__c objRC_Limit2 = new MIS_RC_Limit_Dt__c(
            Name='test',
            Deal_No__c='1237',
            IBL_Lien_Marked__c='N'    
        );
        insert objRC_Limit2;
        
    }
}