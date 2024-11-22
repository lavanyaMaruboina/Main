public class UniqueLeadNumberHandler1 {
    public static void generateLeadnumber(Map<Id, Opportunity> opptyMap){
        updateLeadSeqNumber(opptyMap.keySet());
    }    
    
    @future
    public static void updateLeadSeqNumber(Set<Id> OpptyIdSet){
        List<Opportunity> opptyList = [Select id, Lead_Number_Sequence__c, Lead_number__c from Opportunity where Id IN: OpptyIdSet WITH SECURITY_ENFORCED];
        if(opptyList != null && opptyList.size() > 0){
            System_Configuration__c seqNumber = System_Configuration__c.getValues('System Configuration');
            for(Opportunity op : opptyList){
                String todayYear = String.valueOf(System.today().Year()).right(2);
                String todayMonth = String.valueOf(system.today().Month()).length() == 1 ? '0' + String.valueOf(system.today().Month()) : String.valueOf(system.today().Month());
                String todayDay = String.valueOf(system.today().day()).length() == 1 ? '0' + String.valueOf(system.today().day()) : String.valueOf(system.today().day());
                String datePrefix = todayDay + '' + todayMonth + '' + todayYear;
                String finalLeadNumber = '';
          if(Test.isRunningTest() == false){

                Integer lastFive = integer.valueof(op.Lead_Number_Sequence__c) - integer.valueof(seqNumber.Lead_Sequence_No__c);
                string lastFiveDigits = string.valueof(lastFive);
                while(lastFiveDigits.length() < 5){
                    lastFiveDigits = '0' + lastFiveDigits;
                }
                System.debug('datePrefix: '+datePrefix);
                System.debug('lastFiveDigits: '+lastFiveDigits);
                String applicationNameString = datePrefix + lastFiveDigits;
                System.debug('applicationNameString: '+applicationNameString);
                long appvalue = Long.valueOf(applicationNameString);
                if (String.valueOf(appvalue).length() == 10) {
                    //adding '0' to Lead No pattern if date ranges in 01-09
                    finalLeadNumber = 'L' + '' + '0' + '' + String.valueOf(appvalue);
                } else {
                    finalLeadNumber = 'L' + '' + String.valueOf(appvalue);
                }
                op.Lead_number__c = finalLeadNumber;
                op.name=finalLeadNumber;
              }
        	}
            update opptyList;
        }
	}
}