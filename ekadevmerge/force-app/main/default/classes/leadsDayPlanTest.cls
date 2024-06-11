@istest
public class leadsDayPlanTest {

    @isTest
    static void testGetLeads() {
        Lead testLead = new Lead(
            FirstName = 'Test',
            LastName = 'Lead',
            Gender__c = 'Male',
            Phone = '9587463212',
            Company = 'Xyz',
            Clinic_Type__c = 'Polyclinic',
            Specialization__c = 'ENT',
            LeadSource = 'Organic search',
            OwnerId = UserInfo.getUserId(),
            Status_of_Day_Plan__c = 'Completed'
        );
        insert testLead;
        List<lead> leadLst= leadsDayPlan.getLeads();
        system.assertEquals(1, leadLst.size());
        
    }
    
    @isTest
    static void testUpdateLeads() {
        Lead testLead = new Lead(
            FirstName = 'Test',
            LastName = 'Lead',
            Gender__c = 'Male',
            Phone = '9587463212',
            Company = 'Xyz',
            Clinic_Type__c = 'Polyclinic',
            Specialization__c = 'ENT',
            LeadSource = 'Organic search',
            day_plan_date__c = Date.valueOf('2023-12-01'),
            lead_Purpose__c = 'Request for EMR',            
            OwnerId = UserInfo.getUserId(),
            Status_of_Day_Plan__c = 'Completed'
        );
        insert testLead;
        
        Bypass_Validations_On_Lead__c testSetting = new Bypass_Validations_On_Lead__c(
            Name = 'Bypass_Validations_On_Lead__c',
            Bypass_Validations__c = true
        );
        insert testSetting;
        List<Bypass_Validations_On_Lead__c> updateLstfalse = new List<Bypass_Validations_On_Lead__c>();
        List<Bypass_Validations_On_Lead__c> csLstfalse = [SELECT id,name,Bypass_Validations__c FROM Bypass_Validations_On_Lead__c];
        for(Bypass_Validations_On_Lead__c csf : csLstfalse){
            csf.Bypass_Validations__c = false;
            updateLstfalse.add(csf);
        }
        update updateLstfalse;
        
        List<Lead> leadData = new List<Lead>{
            new Lead(Id = testLead.Id, Status_of_Day_Plan__c = 'Not Completed')
                };
                    
                    System.runAs(new User(Id = UserInfo.getUserId())) {
                        String result = leadsDayPlan.updateLeads(leadData);
                        
                        System.assertEquals('success', result, 'Update should be successful');
                        
                        Lead updatedLead = [SELECT Id, LastName, Status_of_Day_Plan__c FROM Lead WHERE Id = :testLead.Id LIMIT 1];
                        System.assertEquals('Not Completed', updatedLead.Status_of_Day_Plan__c, 'Lead status should be updated');
                        
                        Bypass_Validations_On_Lead__c updatedSetting = [SELECT Id, Bypass_Validations__c FROM Bypass_Validations_On_Lead__c WHERE Id = :testSetting.Id LIMIT 1];
                        System.assertEquals(true, updatedSetting.Bypass_Validations__c, 'Custom setting should be updated');
                    }
    }
}