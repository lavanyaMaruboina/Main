@isTest
public class Schedule_Lead_Number_SequenceTest {
     @isTest
    public static void testData(){
       
        System_Configuration__c sysConfig = new System_Configuration__c();
        sysConfig.Name = 'System Configuration';
        sysConfig.Eligible_Roles_for_BE_Assignment__c = 'BE,CS';
        sysConfig.Eligible_Roles_for_CS_Assignment__c = 'CS,MA';
        sysConfig.Eligible_Roles_for_MA_Assignment__c = 'MA,MO';
        sysConfig.Eligible_Roles_for_MO_Assignment__c = 'BE,CS,MA,MO';
        insert sysConfig;
        
        List<Opportunity> opList = new List<Opportunity>();
        
        Opportunity opl2 = new Opportunity();
        opl2.StageName = 'Qualification';
        opl2.CloseDate = System.today();
        opl2.Name = 'testname';
        //opl1.Application_Sequence_Number__c = '00165';
        insert opl2;
        opList.add(opl2);
        
        Schedule_Lead_Number_Sequence sn2 = new Schedule_Lead_Number_Sequence();
        string sn3 = '0 00 00 * * ?';
        Id jobId = System.schedule('LeadSeq', sn3, sn2);
        System.assert(jobId != null);
       
    }
}