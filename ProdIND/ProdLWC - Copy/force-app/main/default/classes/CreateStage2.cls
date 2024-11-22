public with sharing class CreateStage2 {
   
    @AuraEnabled
    public static Opportunity fetchOpp(){
        return[SELECT id,Name,StageName,CloseDate FROM Opportunity ORDER BY CreatedDate DESC LIMIT 1];
        
    }
}