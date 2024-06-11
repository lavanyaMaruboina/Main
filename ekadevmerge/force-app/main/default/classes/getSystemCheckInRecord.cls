public class getSystemCheckInRecord {
    
    @AuraEnabled
    public static System_Check_In__c getCurrentUserDailyCheckInId(){
        System_Check_In__c todayCheckInRecord;
            try {
                Id userId = UserInfo.getUserId();
                todayCheckInRecord = [select Id,Check_In_Time__c,Check_Out_Time__c from System_Check_In__c where User__c =: userId 
                                      and CreatedDate = TODAY limit 1];
                system.System.debug('todayCheckInId '+ todayCheckInRecord);
            } catch (Exception e) {
                // throw new AuraHandledException(e.getMessage());
                system.debug('Error: '+ e.getMessage());
            }
        return todayCheckInRecord;
    }
}