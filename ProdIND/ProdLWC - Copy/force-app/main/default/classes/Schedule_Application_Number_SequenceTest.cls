@isTest
public class Schedule_Application_Number_SequenceTest {
    
 /*   @isTest
    public static void testData(){
        System_Configuration__c sysConfig = new System_Configuration__c();
        sysConfig.Name = 'System Configuration';
        sysConfig.Eligible_Roles_for_BE_Assignment__c = 'BE,CS';
        sysConfig.Eligible_Roles_for_CS_Assignment__c = 'CS,MA';
        sysConfig.Eligible_Roles_for_MA_Assignment__c = 'MA,MO';
        sysConfig.Eligible_Roles_for_MO_Assignment__c = 'BE,CS,MA,MO';
        insert sysConfig;
        
        List<Opportunity> opList = new List<Opportunity>();
        
        Opportunity opl1 = new Opportunity();
        opl1.StageName = 'Qualification';
        opl1.CloseDate = System.today();
        opl1.Name = 'testname';
        //opl1.Application_Sequence_Number__c = '00165';
        insert opl1;
        opList.add(opl1);
        
        
        Schedule_Application_Number_Sequence sn1 = new Schedule_Application_Number_Sequence();
        string sn2 = '0 00 00 * * ?';
        Id jobId = System.schedule('LeadSeq', sn2, sn1);
        System.assert(jobId != null);
    } */
}