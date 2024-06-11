public with sharing class leadsDayPlan {
    @AuraEnabled(cacheable=true)
    public static List<Lead> getLeads() {
        // Query leads and return the list
        return [
            SELECT Id,Owner.Name,OwnerId,Name,Status_of_Day_Plan__c,Phone,RecordType.Name,RecordTypeId
            FROM Lead WHERE OwnerId =: UserInfo.getUserId() ORDER BY createddate DESC
            
        ];
    }

    @AuraEnabled
    public static string updateLeads(Object leadData) {
        List<Bypass_Validations_On_Lead__c> updateLstfalse = new List<Bypass_Validations_On_Lead__c>();
        List<Bypass_Validations_On_Lead__c> updateLsttrue = new List<Bypass_Validations_On_Lead__c>();
        List<Lead> leadsToUpdate = new List<Lead>();

        List<Bypass_Validations_On_Lead__c> csLstfalse = [SELECT id,name,Bypass_Validations__c FROM Bypass_Validations_On_Lead__c WHERE name LIKE 'Bypass Validations%'];
        for(Bypass_Validations_On_Lead__c csf : csLstfalse){
            csf.Bypass_Validations__c = false;
            updateLstfalse.add(csf);
        }
        update updateLstfalse;
        
        List<lead> leadLst = (list<lead>) json.deserialize(
            json.serialize(leadData), List<Lead>.class
        );

        if(!leadLst.isempty()){
            update leadLst;
            List<Bypass_Validations_On_Lead__c> csLsttrue = [SELECT id,name,Bypass_Validations__c FROM Bypass_Validations_On_Lead__c WHERE name LIKE 'Bypass Validations%'];
            for(Bypass_Validations_On_Lead__c cst : csLsttrue){
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