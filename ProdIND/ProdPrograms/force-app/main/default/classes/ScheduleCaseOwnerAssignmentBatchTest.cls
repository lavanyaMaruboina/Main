@isTest
public class ScheduleCaseOwnerAssignmentBatchTest {
    
    @testSetup
    public static void testSetup(){
        // Create Opportunity            
        
        Opportunity opp = new Opportunity();
        opp.Name = 'LoanApplicationName';
        opp.StageName = 'Loan Details';
        opp.CloseDate = system.today();
        insert opp; 
        
        Profile profile = [SELECT Id,Name FROM Profile WHERE Name = 'CMU' LIMIT 1];
        
        User testUser = new User(
            ProfileId = profile.Id,
            FirstName = 'TestCMU',
            LastName = 'User',
            Email = 'testuser@example.com',
            Username = 'cmutestuser@example.com',
            Alias = 'Cmusr',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles',
            mobilePhone= '9087567896'
        );
        insert testUser;      
        
        Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('CMU Request').getRecordTypeId();       
        
        Case caseInstance= new Case();
        caseInstance.Status='New';
        caseInstance.Loan_Application__c=opp.Id;
        caseInstance.RecordTypeId=caseRecordTypeId;
        caseInstance.OwnerId=testUser.Id;
        caseInstance.Subject='Test subject';
        
        insert caseInstance;     
        
    } 
    
    static testMethod  void CaseOwnerAssignmentBatchTest(){
        
        ScheduleCaseOwnerAssignmentBatch scheduledClassInstance = new ScheduleCaseOwnerAssignmentBatch();
        //String jobName = 'TestScheduledJob';
        //String cronExp = '0 0 0 ? * *';
        
        Test.startTest();
        // System.schedule(jobName, cronExp, scheduledClassInstance);
        scheduledClassInstance.execute(null); // to execute right now
        Test.stopTest();
        
        Case cs=[SELECT Id,Status from Case WHERE Subject='Test subject' LIMIT 1];
        System.assertEquals(cs.Status,'Pending with CMU');
        
    }
}