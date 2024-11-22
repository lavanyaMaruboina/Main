public class Schedule_Lead_Number_Sequence implements Schedulable {
    public void execute(SchedulableContext SC)

     {

      list<Opportunity> lastOpp = new List<Opportunity>([Select Id,Lead_Number_Sequence__c from Opportunity where CreatedDate = TODAY WITH SECURITY_ENFORCED order by CreatedDate Desc limit 1]);
      System_Configuration__c seqNumber = System_Configuration__c.getValues('System Configuration');
      
       if(!lastOpp.isEmpty()){
            String lastFiveDigits = lastOpp[0].Lead_Number_Sequence__c ;
            seqNumber.Lead_Sequence_No__c = lastFiveDigits;
        }
        seqNumber.Valid_Lead_Number_Date__c = Date.Today() + 1;
        update seqNumber;


     }
}