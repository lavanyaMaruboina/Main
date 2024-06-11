@isTest
public class UpdateRelateFieldsUpdateGoLiveTest {

    @isTest
    static void testTriggerLogic() {
        // Create an Account with the specified Record Type
        Account testAccount = new Account(
            Name = 'Test Account'
        );
        insert testAccount;

        
        list<recordtype> RT = [SELECT id,name FROM RecordType WHERE name = 'HXNG Team'];
        // Create an Opportunity related to the Account
        Opportunity testOpportunity = new Opportunity(
            Name = 'Test Opportunity',
            accountId = testAccount.id,
            RecordTypeId = RT[1].Id,
                        
            
            
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
            // Add more fields as needed
        );
        insert testOpportunity;

        // Run trigger logic by updating the Opportunity
        testOpportunity.Number_of_Staff_in_Clinic__c = 10;
        // Update other fields as needed

        // Trigger the update by updating the Opportunity
        update testOpportunity;

        // Retrieve the updated Account
        Account updatedAccount = [SELECT Id,  Eka_Id__c,Number_of_Staff_in_Clinic__c /* Add other fields */ FROM Account WHERE Id = :testAccount.Id LIMIT 1];

        // Add assertions based on your expected results
        System.assertEquals(testOpportunity.Eka_Id__c, updatedAccount.Eka_Id__c);
        System.assertEquals(testOpportunity.Number_of_Staff_in_Clinic__c, updatedAccount.Number_of_Staff_in_Clinic__c);
        // Add more assertions as needed
    }
}