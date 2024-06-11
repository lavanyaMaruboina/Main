@isTest
private class LSQ_CreateContactTest {
  
    static testMethod void testBatchMethodOne()
    {
        Account testAccount=new Account( name='Test Account001',LSQ_ExtID__c='LSQG00001',Temporary_Contact_Name__c='Test Name', phone='12121333',Temporary_Contact_Email__c='test@email.com', lsq_imported__c=true);
        insert testAccount;         
        test.startTest();
        LSQ_CreateContactBatch testInstance= new LSQ_CreateContactBatch();
        String queryTest='Select id,lsq_imported__c, LSQ_ExtID__c, Temporary_Contact_Name__c, phone,Temporary_Contact_Email__c from account where lsq_imported__c=true and LSQ_ExtID__c like \'LSQG%\'';
        testInstance.queryAccount=queryTest;
        Id jobID= Database.executeBatch(testInstance,10);
        test.stopTest();
        
        
        
        
    }
}