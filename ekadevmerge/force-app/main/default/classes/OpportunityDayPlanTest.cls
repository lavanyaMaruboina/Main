@isTest
public class OpportunityDayPlanTest {
    
    @isTest
    static void testGetOpportunities() {    
        Opportunity testOpportunity = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Nurturing',
            CloseDate = Date.valueOf('2023-12-01'),
            OwnerId = UserInfo.getUserId(),           
            Status_of_Day_Plan__c = 'Not Completed'
        );
        insert testOpportunity;
        
        List<Opportunity> OpportunityLst= OpportunityDayPlan.getOpportunities();
        system.assertEquals(1, OpportunityLst.size());
    }
    
    @isTest
    static void testUpdateOpportunities() {
        Opportunity testOpportunity = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Nurturing',
            CloseDate = Date.valueOf('2023-12-01'),
            OwnerId = UserInfo.getUserId(),           
            Status_of_Day_Plan__c = 'Not Completed'
        );
        insert testOpportunity;  
        
        Bypass_Validations_On_Opportunity__c testSetting = new Bypass_Validations_On_Opportunity__c(
            Name = 'Bypass_Validations_On_Opportunity__c',
            Bypass_Validations__c = true
        );
        insert testSetting;
        
        List<Bypass_Validations_On_Opportunity__c> updateLstfalse = new List<Bypass_Validations_On_Opportunity__c>();
        List<Bypass_Validations_On_Opportunity__c> csLstfalse = [SELECT id,name,Bypass_Validations__c FROM Bypass_Validations_On_Opportunity__c];
        for(Bypass_Validations_On_Opportunity__c csf : csLstfalse){
            csf.Bypass_Validations__c = false;
            updateLstfalse.add(csf);
        }
        update updateLstfalse;
        
        List<opportunity> opportunityData = new List<opportunity>{
            new opportunity(Id = testOpportunity.Id, Status_of_Day_Plan__c = 'Not Completed')
                };
                    
                    System.runAs(new User(Id = UserInfo.getUserId())) {
                        String result = OpportunityDayPlan.updateOpportunities(opportunityData);
                        
                        System.assertEquals('success', result, 'Update should be successful');
                        
                        Opportunity updatedOpportunity = [SELECT Id, Status_of_Day_Plan__c FROM Opportunity WHERE Id = :testOpportunity.Id LIMIT 1];
                        System.assertEquals('Not Completed', updatedOpportunity.Status_of_Day_Plan__c, 'Opportunity status should be updated');
                        
                        Bypass_Validations_On_Opportunity__c updatedSetting = [SELECT Id, Bypass_Validations__c FROM Bypass_Validations_On_Opportunity__c WHERE Id = :testSetting.Id LIMIT 1];
                        System.assertEquals(true, updatedSetting.Bypass_Validations__c, 'Custom setting should be updated');
                    }
        
    }
}