public class getUserCheckInDetails {
    @AuraEnabled(cacheable=true)
    public static list<Check_IN_Out__c> getDetails(Id oppId, Id userId){
        system.debug('oppId '+ oppId);
        system.debug('userId '+ userId);
        list<Check_IN_Out__c> userCheckInList = [Select Id, Check_In_Time__c,Check_Out_Time__c,createdDate from Check_IN_Out__c where 
                                           Opportunity__c =: oppId and createdDate = TODAY and OwnerId =: userId limit 1];
        system.debug('userCheckInList ' + userCheckInList);
        if(userCheckInList != null){
            return userCheckInList;          
        }else{
            return null;
        }
    }   
}