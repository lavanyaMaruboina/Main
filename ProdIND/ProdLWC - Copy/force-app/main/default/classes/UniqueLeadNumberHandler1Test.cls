@isTest
public class UniqueLeadNumberHandler1Test {
      @isTest
    public static void generateLeadnumberTest(){
         Opportunity opp = TestDataUtility.createTestOpportunity(false);
      //   opp.Lead_Number_Sequence__c = '00262';
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
         System_Configuration__c seqNumber = New System_Configuration__c(Name='System Configuration',Application_Date__c	=Date.today(),Application_Sequence_No__c=6,Eligible_Roles_for_BE_Assignment__c='BE,CS',
                                                                       Eligible_Roles_for_CS_Assignment__c='CS,MA',Eligible_Roles_for_MA_Assignment__c='MA,MO',Eligible_Roles_for_MO_Assignment__c='BE,CS,MA,MO',
                                                                       Lead_Sequence_No__c='984935');
        Insert seqNumber;
          Map<Id, Opportunity> opMap = new Map<Id, Opportunity>();
          opMap.put(opp.Id,opp);
        
        Test.startTest();
              UniqueLeadNumberHandler1.generateLeadnumber(opMap);
        Test.stopTest();
    }
}