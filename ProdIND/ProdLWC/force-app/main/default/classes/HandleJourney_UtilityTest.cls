@isTest
public class HandleJourney_UtilityTest {
    @isTest
    public static void handleCMUJourneyRestartTest(){
        try{
        Opportunity opp = TestDataUtility.createTestOpportunity(false);
        opp.Journey_Restart_Reason__c = 'testreason';
        opp.CloseDate = Date.newInstance(2022, 1, 11);
        //opp.StageName = 'Journey Restart';
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            
            Applicant__c applicant = TestDataUtility.createTestApplicantForSMS(false);
            applicant.Opportunity__c = opp.Id;
            applicant.Applicant_Type__c = System.label.Borrower;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert applicant;
            }
        
            Test.startTest();
                HandleJourney_Utility.handleCMUJourneyRestart(applicant.Id,opp.Journey_Restart_Reason__c);
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void handleLoanApplictionNumberTest(){
         Opportunity opp = TestDataUtility.createTestOpportunity(false);
         if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
        
           Test.startTest();
                  HandleJourney_Utility.handleLoanApplictionNumber(opp.Id,'CMU Journey Restart');
                //  HandleJourney_Utility.handleLoanApplictionNumber('_JR','CMU Journey Restart');
           Test.stopTest();
    }
     @isTest
    public static void handleCMUJourneyRestartTest1(){
        try{
        Opportunity opp = TestDataUtility.createTestOpportunity(false);
        opp.Journey_Restart_Reason__c = 'testreason';
        opp.CloseDate = Date.newInstance(2022, 1, 11);
        //opp.StageName = 'Journey Restart';
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            
            Applicant__c applicant = TestDataUtility.createTestApplicantForSMS(false);
            applicant.Opportunity__c = opp.Id;
            applicant.Applicant_Type__c = System.label.Borrower;
            applicant.In_Active_Applicant__c = false;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert applicant;
            }
        
            Test.startTest();
                HandleJourney_Utility.handleCMUJourneyRestart(applicant.Id,opp.Journey_Restart_Reason__c);
                HandleJourney_Utility.handleCMUJourneyRestart('test','test');
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
     @isTest
    public static void handleCMUJourneyRestartTest2(){
        try{
        Opportunity opp = TestDataUtility.createTestOpportunity(false);
        opp.Journey_Restart_Reason__c = 'testreason';
        opp.CloseDate = Date.newInstance(2022, 1, 11);
       // opp.LeadSource = 'DSA';
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            
            Applicant__c applicant = TestDataUtility.createTestApplicantForSMS(false);
            applicant.Opportunity__c = opp.Id;
            applicant.Applicant_Type__c = 'Co-Borrower';
            applicant.In_Active_Applicant__c = false;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert applicant;
            }
        
            Test.startTest();
                HandleJourney_Utility.handleCMUJourneyRestart(applicant.Id,opp.Journey_Restart_Reason__c);
                HandleJourney_Utility.handleCMUJourneyRestart('test','test');
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    
    public static void handleCMUJourneyRestartTest3(){
        try{
        Opportunity opp = TestDataUtility.createTestOpportunity(false);
        opp.Journey_Restart_Reason__c = 'testreason';
        opp.CloseDate = Date.newInstance(2022, 1, 11);
        opp.StageName = 'Journey Restart';
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            
            Applicant__c applicant = TestDataUtility.createTestApplicantForSMS(false);
            applicant.Opportunity__c = opp.Id;
            applicant.Applicant_Type__c = 'Co-Borrower';
            applicant.In_Active_Applicant__c = false;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert applicant;
            }
        
            Test.startTest();
                HandleJourney_Utility.handleCMUJourneyRestart(applicant.Id,opp.Journey_Restart_Reason__c);
                HandleJourney_Utility.handleCMUJourneyRestart('test','test');
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void getLastSalesUserIdTest(){
        try{
            Opportunity opks1 = new Opportunity();
                opks1.StageName = 'Qualification';
                opks1.CloseDate = Date.newInstance(2021, 1, 11);
                opks1.Name = 'testone';
                opks1.OwnerId = UserInfo.getUserId();
                insert opks1;
            
                Loan_Application_Transaction_History__c lth1 = new Loan_Application_Transaction_History__c();
                lth1.Loan_Application_ID__c = opks1.Id;
                lth1.Module_Name__c = 'Credit Processing';
                lth1.Assignment_status__c = 'Accepted';
                lth1.RecordTypeId = Schema.SObjectType.Loan_Application_Transaction_History__c.getRecordTypeInfosByName().get('Stage Change').getRecordTypeId();
                insert lth1;
            
                Test.startTest();
                      HandleJourney_Utility.getLastSalesUserId(opks1.Id);
                Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void getLastSalesUserIdTest1(){
        try{
            Opportunity opks1 = new Opportunity();
                opks1.StageName = 'Qualification';
                opks1.CloseDate = Date.newInstance(2021, 1, 11);
                opks1.Name = 'testone';
                opks1.OwnerId = UserInfo.getUserId();
                insert opks1;
            
                Loan_Application_Transaction_History__c lth1 = new Loan_Application_Transaction_History__c();
                lth1.Loan_Application_ID__c = opks1.Id;
                lth1.Module_Name__c = 'Credit Processing';
                lth1.Assignment_status__c = 'Accepted';
                lth1.Current_Owner__c = UserInfo.getUserId();
                lth1.RecordTypeId = Schema.SObjectType.Loan_Application_Transaction_History__c.getRecordTypeInfosByName().get('Stage Change').getRecordTypeId();
                insert lth1;
            
                Test.startTest();
                      HandleJourney_Utility.getLastSalesUserId(opks1.Id);
                      HandleJourney_Utility.getLastSalesUserId('test');
                      HandleJourney_Utility.handleLoanApplictionNumber(null,null);
                Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    @isTest
    public static void getBussDoneByIDTest1(){
        try{
            Account acc = new Account();
            acc.Name = 'AccName';
            insert acc;
            
            Account acc1 = new Account();
            acc1.Name = 'AccName';
            insert acc1;
            
            Opportunity opks1 = new Opportunity();
            opks1.StageName = 'Qualification';
            opks1.CloseDate = Date.newInstance(2021, 1, 11);
            opks1.Name = 'testone';
            opks1.OwnerId = UserInfo.getUserId();
            opks1.AccountId = acc.Id;
            opks1.PreviousAccountId__c = acc1.Id;
            insert opks1;
            
            AccountTeamMember atm2 = new AccountTeamMember();
            atm2.AccountId = opks1.AccountId;
            atm2.TeamMemberRole = 'BE';
            atm2.UserId = UserInfo.getUserId();
            insert atm2;
            
                Test.startTest();
                      HandleJourney_Utility.getBussDoneByID(opks1.Id);
            		
                Test.stopTest();
        }catch(Exception e){
            
        }
    }
    
     @isTest
    public static void getBussSourceByTestTest1(){
        try{
            Account acc = new Account();
            acc.Name = 'AccName';
            insert acc;
            
            Account acc1 = new Account();
            acc1.Name = 'AccName';
            insert acc1;
            
            Opportunity opks1 = new Opportunity();
            opks1.StageName = 'Qualification';
            opks1.CloseDate = Date.newInstance(2021, 1, 11);
            opks1.Name = 'testone';
            opks1.OwnerId = UserInfo.getUserId();
            opks1.AccountId = acc.Id;
            opks1.PreviousAccountId__c = acc1.Id;
            insert opks1;
            
            AccountTeamMember atm2 = new AccountTeamMember();
            atm2.AccountId = opks1.AccountId;
            atm2.TeamMemberRole = 'BE';
            atm2.UserId = UserInfo.getUserId();
            insert atm2;
            
                Test.startTest();
                      HandleJourney_Utility.getBussSourceBy(opks1.Id);
            		
                Test.stopTest();
        }catch(Exception e){
            
        }
    }
    
    @isTest
    public static void getBussSourceByTest(){
        try{
            Account acc = new Account();
            acc.Name = 'AccName';
            insert acc;
            
            Opportunity opks1 = new Opportunity();
            opks1.StageName = 'Qualification';
            opks1.CloseDate = Date.newInstance(2021, 1, 11);
            opks1.Name = 'testone';
            opks1.OwnerId = UserInfo.getUserId();
            opks1.AccountId = acc.Id;
            insert opks1;
            
            AccountTeamMember atm2 = new AccountTeamMember();
            atm2.AccountId = opks1.AccountId;
            atm2.TeamMemberRole = 'BE';
            atm2.UserId = UserInfo.getUserId();
            insert atm2;
            
                Test.startTest();
                      HandleJourney_Utility.getBussSourceBy(opks1.Id);
                        		
                Test.stopTest();
        }catch(Exception e){
            
        }
    }
    @isTest
    public static void getBussDoneByIDTest(){
        try{
            Account acc = new Account();
            acc.Name = 'AccName';
            insert acc;
            
            Opportunity opks1 = new Opportunity();
            opks1.StageName = 'Qualification';
            opks1.CloseDate = Date.newInstance(2021, 1, 11);
            opks1.Name = 'testone';
            opks1.OwnerId = UserInfo.getUserId();
            opks1.AccountId = acc.Id;
            insert opks1;
            
            AccountTeamMember atm2 = new AccountTeamMember();
            atm2.AccountId = opks1.AccountId;
            atm2.TeamMemberRole = 'BE';
            atm2.UserId = UserInfo.getUserId();
            insert atm2;
            
                Test.startTest();
                      HandleJourney_Utility.getBussDoneByID(opks1.Id);
            		
                Test.stopTest();
        }catch(Exception e){
            
        }
    }
}