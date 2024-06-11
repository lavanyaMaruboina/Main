public with sharing class OpportunityDayPlan {
    @AuraEnabled(cacheable=true)
    public static List<Opportunity> getOpportunities() {
        // Query leads and return the list
        return [
            SELECT Id,Owner.Name,OwnerId,Name,Phone__c,Specialization__c,Status_of_Day_Plan__c,Activity_Status__c,Visited__c,Plan_s_Missing__c,RecordType.Name,RecordTypeId
            FROM Opportunity WHERE OwnerId =: UserInfo.getUserId() ORDER BY createddate DESC

        
        ];
    }

    @AuraEnabled
    public static string updateOpportunities(Object opportunityData) {
        List<Opportunity> opportunitiesToUpdate = new List<Opportunity>();
        List<Bypass_Validations_On_Opportunity__c> updateLstfalse = new List<Bypass_Validations_On_Opportunity__c>();
        List<Bypass_Validations_On_Opportunity__c> updateLsttrue = new List<Bypass_Validations_On_Opportunity__c>();
        
        List<Bypass_Validations_On_Opportunity__c> csLstfalse = [SELECT id,name,Bypass_Validations__c FROM Bypass_Validations_On_Opportunity__c WHERE name LIKE 'Bypass Validations%'];
        for(Bypass_Validations_On_Opportunity__c csf : csLstfalse){
            csf.Bypass_Validations__c = false;
            updateLstfalse.add(csf);
        }
        update updateLstfalse;
  
        List<opportunity> opportunityLst = (list<opportunity>) json.deserialize(
            json.serialize(opportunityData), List<Opportunity>.class
        );

        if(!opportunityLst.isempty()){
            update opportunityLst;
            List<Bypass_Validations_On_Opportunity__c> csLsttrue = [SELECT id,name,Bypass_Validations__c FROM Bypass_Validations_On_Opportunity__c WHERE name LIKE 'Bypass Validations%'];
            for(Bypass_Validations_On_Opportunity__c cst : csLsttrue){
                cst.Bypass_Validations__c = true;
                updateLsttrue.add(cst);
            }
            update updateLsttrue;
            return 'success';
        }
        else{
            return 'Failed';
        }
    }
}