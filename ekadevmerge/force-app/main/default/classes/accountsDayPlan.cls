public with sharing class accountsDayPlan {
    @AuraEnabled(cacheable=true)
    public static List<Account> getAccounts() {
        // Query leads and return the list
        return [
            SELECT Id,Owner.Name,OwnerId,Name,Specialization__c,Status_of_Day_Plan__c,CreatedById
            FROM Account WHERE OwnerId =: UserInfo.getUserId() ORDER BY createddate DESC
            
        ];
    }

    @AuraEnabled
    public static string updateAccounts(Object accountData) {
        List<Account> accountsToUpdate = new List<Account>();       
        List<Account> accountLst = (list<Account>) json.deserialize(
            json.serialize(accountData), List<Account>.class
        );

        if(!accountLst.isempty()){
            update accountLst;
            return 'success';
        }
        else{
            return 'Failed';
        }
    }

    //lavanya
}