public with sharing class iND_CustomLookup_WithSharing {

    @AuraEnabled(cacheable=true)  
    public static List<sobject> findRecord_one(String searchKey, String objectName, String loanID, string AccountID, String branchId){
       List<sobject> objlist = iND_CustomLookup.findRecords(searchKey, objectName, loanID, AccountID,branchId);
        return objlist;
    }
}