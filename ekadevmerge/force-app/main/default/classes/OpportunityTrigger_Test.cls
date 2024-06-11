@isTest
public class OpportunityTrigger_Test {

    @isTest
    static void testTriggerLogic() {
        Account testAccount = new Account(
            Name = 'Test Account'
        );
        insert testAccount;
      
        list<recordtype> RT = [SELECT id,name,SobjectType FROM RecordType WHERE name = 'HXNG Team' AND SobjectType = 'Opportunity'];
        Opportunity testOpportunity = new Opportunity(
            Name = 'Test Opportunity',
            accountId = testAccount.id,
            RecordTypeId = RT[0].Id,          
            Activity_Status__c = 'Pitched',
            Number_of_Staff_in_Clinic__c=7.0,
            Eka_Id__c = 'WWW.URL.com',
            Other_Apps_Used__c = 'Pen & Paper',
            OPD_Days__c = 'Mon',            
            Staff_Alternate_Phone_Number__c = '9989393127',
            OPD_timings__c = Time.newInstance(9, 0, 0, 0),
            OPD_Start_Timing__c = Time.newInstance(18, 0, 0, 0),
            OPD_End_Timing__c = Time.newInstance(6, 0, 0, 0),
            Daily_OPD_Vol__c = 4.0,
            Staff_Name__c = 'lavanya',
            Software_Name__c = 'Testing',
            Infra_In_Clinic__c = 'Laptop/ Desktop',
            Does_the_doctor_have_Preferred_Pharmacy__c = 'Own Pharmacy',
            Does_the_doctor_have_their_own_Lab__c = 'Yes',
            Does_the_doctor_have_their_own_pharmacy__c = 'Yes',
            Pharmacy_Type__c = 'Licensed Pharmacy',
            Phar__c = 'Licensed Pharmacy',
            Type = 'Existing Business',
            Notes_Remarks__c = 'Testing Create',
            Check_In_Time__c = DateTime.newInstance(System.today(), Time.newInstance(8, 0, 0, 0)),
            Check_Out_Time__c = DateTime.newInstance(System.today(), Time.newInstance(1, 0, 0, 0)),
            Check_In_Count__c = 7,
            Phone__c = '9989494234',
            StageName = 'Demo',
            CloseDate = Date.newInstance(2024, 01, 02)
        );
        insert testOpportunity;

        testOpportunity.Number_of_Staff_in_Clinic__c = 10;

        update testOpportunity;

        List<opportunity> oppList = [SELECT id,name,Check_In_Time__c,StageName,CloseDate,Check_Out_Time__c,Phone__c,Check_In_Count__c,AccountId,Staff_Name__c,Pharmacy_Type__c,Type,Notes_Remarks__c,Does_the_doctor_have_their_own_Lab__c,Does_the_doctor_have_their_own_pharmacy__c,Software_Name__c,Infra_in_clinic__c,Does_the_doctor_have_Preferred_Pharmacy__c,OPD_End_Timing__c,Daily_OPD_Vol__c,Eka_Id__c,OPD_timings__c,OPD_Start_Timing__c,Number_of_Staff_in_Clinic__c,Other_Apps_Used__c,OPD_Days__c,Staff_Alternate_Phone_Number__c,RecordTypeId FROM opportunity];

        System.assertNotEquals(null, oppList);
    }   
}