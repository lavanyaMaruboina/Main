@isTest
private class LSQ_CreateAccountNContactTest {
  
    static testMethod void testBatchMethodOne()
    {
        Account testAccount=new Account(name='LSQ Data Account');
        insert testAccount;
        
        Opportunity testOpp=new Opportunity(
            stageName='Connected',
            CloseDate=System.today()+30,
            LSQ_ExtID__c='testid0001',
            lSQ_imported__c=true,
            name='testOpp', 
            Email__c='test@email.com', 
            Phone__c='9087654321', 
            Daily_OPD_Vol__c=-1,  
            GMB_Paid__c=false,
            Infra_in_clinic__c='', 
            Number_of_Staff_in_Clinic__c=-1, 
            OPD_Days__c='Mon;Tue;Wed;Thurs;Fri', 
            OPD_Start_Timing__c= Time.newInstance(10,55,00,000),
            OPD_End_Timing__c=Time.newInstance(18,00,00,000), 
            OPD_Start_Timing_2__c=Time.newInstance(10,55,00,000),
            OPD_End_Timing_2__c=Time.newInstance(12,55,00,000),
            Other_Apps_Used__c='Other Software', 
            Software_Name__c='NA', Specialization__c='Homeopathic',
            Staff_Alternate_Phone_Number__c='',
            Staff_Name__c='',
            AccountId=testAccount.id
        );      
        
        insert testOpp; 
        
        test.startTest();
        LSQ_CreateAccountNContactBatch testInstance= new LSQ_CreateAccountNContactBatch();
        String queryTest='Select id, LSQ_ExtID__c, name, Temp_Clinic_Name__c, Email__c, Phone__c, Daily_OPD_Vol__c,  GMB_Paid__c, Infra_in_clinic__c, Number_of_Staff_in_Clinic__c, OPD_Days__c, OPD_Start_Timing__c, OPD_End_Timing__c, OPD_Start_Timing_2__c, OPD_End_Timing_2__c, Other_Apps_Used__c, Software_Name__c, Specialization__c, Staff_Alternate_Phone_Number__c, Staff_Name__c  from opportunity where lsq_imported__c=true and account.name=\'LSQ Data Account\'';
        testInstance.queryOpp=queryTest;
        Id jobID= Database.executeBatch(testInstance,10);
        test.stopTest();
        
        
        
        
    }
}