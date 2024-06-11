@isTest
public class TestUpdateRelateFieldsUpdateGoLive {
    @isTest
    static void testTriggerLogic() {
        Account testAccount = new Account(
        Name = 'Test Account',
            //AccountId = testAccount.Id,
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
            //Reason__c = 'Product Related Reason',
            Infra_In_Clinic__c = 'Laptop/ Desktop',
            Does_the_doctor_have_Preferred_Pharmacy__c = 'Own Pharmacy',
            Does_the_doctor_have_their_own_Lab__c = 'Yes',
            Does_the_doctor_have_their_own_pharmacy__c = 'Yes',
            Pharmacy_Type__c = 'Licensed Pharmacy',
            Type = 'Existing Business',
            Notes_Reamrks__c = 'Testing Create',
            Check_In_Time__c = DateTime.newInstance(System.today(), Time.newInstance(8, 0, 0, 0)),
            Check_Out_Time__c = DateTime.newInstance(System.today(), Time.newInstance(1, 0, 0, 0)),
            Check_In_Count__c = 7.0,
            Phone = '9989494234'
        );
        insert testAccount;
        
        RecordType RT = [SELECT Id, DeveloperName FROM RecordType WHERE Id = '0121e000000DhclAAC'];

       // Schema.RecordTypeInfo rtInfo = Opportunity.sObjectType.getRecordTypeInfosByDeveloperName().get('HXNG_Team');
        //Id recordTypeId = (rtInfo != null) ? rtInfo.getRecordTypeId() : null;
        Opportunity testOpportunity = new Opportunity(
            Name = 'Test Opportunity',
            AccountId = testAccount.Id,
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
            RecordTypeId = '0121e000000DhclAAC',

            Staff_Name__c = 'lavanya',
            Software_Name__c = 'Testing',
            //Reason1__c = 'Product Related Reason',
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

        // Insert the opportunity to invoke the trigger
        insert testOpportunity;

        // Retrieve the updated account
        Account updatedAccount = [SELECT Id, Eka_Id__c, Number_of_Staff_in_Clinic__c, Other_Apps_Used__c, 
                                        OPD_Days__c, Staff_Alternate_Phone_Number__c, OPD_timings__c,
                                        OPD_Start_Timing__c, OPD_End_Timing__c, Daily_OPD_Vol__c,
                                        Staff_Name__c, Software_Name__c, Reason__c, Infra_In_Clinic__c,
                                        Does_the_doctor_have_Preferred_Pharmacy__c, 
                                        Does_the_doctor_have_their_own_Lab__c, 
                                        Does_the_doctor_have_their_own_pharmacy__c, Pharmacy_Type__c,
                                        Type, Notes_Reamrks__c, Check_In_Time__c, Check_Out_Time__c,
                                        Check_In_Count__c, Phone
                                    FROM Account WHERE Id = :testAccount.Id];

        System.assertEquals(testOpportunity.Eka_Id__c, updatedAccount.Eka_Id__c);
        System.assertEquals(testOpportunity.Number_of_Staff_in_Clinic__c, updatedAccount.Number_of_Staff_in_Clinic__c);

        testOpportunity.Eka_Id__c = 'New Value';
   
        update testOpportunity;

        // Retrieve the updated account again
        updatedAccount = [SELECT Id, Eka_Id__c, Number_of_Staff_in_Clinic__c, Other_Apps_Used__c, 
                                OPD_Days__c, Staff_Alternate_Phone_Number__c, OPD_timings__c,
                                OPD_Start_Timing__c, OPD_End_Timing__c, Daily_OPD_Vol__c,
                                Staff_Name__c, Software_Name__c, Reason__c, Infra_In_Clinic__c,
                                Does_the_doctor_have_Preferred_Pharmacy__c, 
                                Does_the_doctor_have_their_own_Lab__c, 
                                Does_the_doctor_have_their_own_pharmacy__c, Pharmacy_Type__c,
                                Type, Notes_Reamrks__c, Check_In_Time__c, Check_Out_Time__c,
                                Check_In_Count__c, Phone
                            FROM Account WHERE Id = :testAccount.Id];

        // Add assertions to verify that the fields were updated correctly after the second update
      //  System.assertEquals(testOpportunity.Eka_Id__c, updatedAccount.Eka_Id__c);
       // System.assertEquals(testOpportunity.Number_of_Staff_in_Clinic__c, updatedAccount.Number_of_Staff_in_Clinic__c);
        // Add similar assertions for other fields
    }
}