@isTest
public class Recall_applicationTest {
    
    @isTest
    public static void reaclltranferedApplictaionTest(){
        Opportunity opra1 = new Opportunity();
        opra1.StageName = 'Vehicle insurance';
        opra1.CloseDate = Date.newInstance(2021, 1, 11);
        opra1.Name = 'testone';
        insert opra1;
        
        Vehicle_Detail__c  vehicleDetail =  TestDataUtility.createTestVehicleDetailForIbb(false, opra1);
        vehicleDetail.OEM_Dealer__c = false;
        insert vehicleDetail;
        
        Lead_Genaration_Metadata__mdt lgm1 = [SELECT id,MasterLabel,FieldSetName__c,Object__c,UpdateOrDeactivateOperation__c FROM Lead_Genaration_Metadata__mdt WHERE UpdateOrDeactivateOperation__c = 'Update' limit 1];
        
        Loan_Application_Transaction_History__c lth1 = new Loan_Application_Transaction_History__c();
        lth1.Loan_Application_ID__c = opra1.Id;
        lth1.Assignment_status__c = 'Pending';
        lth1.Module_Name__c = opra1.StageName;
        lth1.New_Owner__c = UserInfo.getUserId();
        lth1.RecordTypeId = Schema.SObjectType.Loan_Application_Transaction_History__c.getRecordTypeInfosByName().get('Lead Assignment').getRecordTypeId();
        upsert lth1;
        
        OpportunityTeamMember optm2 = new OpportunityTeamMember();
        optm2.OpportunityId = opra1.Id;
        optm2.UserId = lth1.New_Owner__c;
        optm2.TeamMemberRole = 'BE';
      //  optm2.Assign_To__c = null;
        insert optm2;
        
        Test.startTest();
        Boolean result = Recall_application.reaclltranferedApplictaion(opra1.Id);
      //  System.assert(result);
        Test.stopTest();
    }
    
    
    
    @isTest
    public static void getUpdateTest(){        
        Opportunity opra2 = new Opportunity();
        opra2.StageName = 'Vehicle insurance';
        opra2.CloseDate = Date.newInstance(2021, 1, 11); 
        opra2.Name = 'testone';
        insert opra2;
        
        Applicant__c applicant = TestDataUtility.createTestApplicantForSMS(false);
        applicant.Opportunity__c = opra2.Id;
        applicant.Applicant_Type__c  = null;
        applicant.Scorecard_Decision__c = 'Red';
        insert applicant;
        
        Vehicle_Detail__c  vehicleDetail =  TestDataUtility.createTestVehicleDetailForIbb(false, opra2);
        vehicleDetail.OEM_Dealer__c = true;
        insert vehicleDetail;
        
        Test.startTest();
        Boolean result = Recall_application.getUpdate('LA_VehicleInsurancePurgeFields', 'Vehicle_Detail__c', opra2.Id);
        Recall_application.getUpdate('LA_VehicleInsurancePurgeFields', 'Income_Details__c', opra2.Id);
        Recall_application.getUpdate('LA_VehicleInsurancePurgeFields', 'Opportunity', opra2.Id);
        Recall_application.getUpdate('LA_VehicleInsurancePurgeFields', 'Applicant__c', opra2.Id);
        System.assert(result);
        Test.stopTest();
    }
    
    @isTest
    public static void getDecivateTest(){
        Opportunity opra2 = new Opportunity();
        opra2.StageName = 'Vehicle insurance';
        opra2.CloseDate = Date.newInstance(2021, 1, 11);
        opra2.Name = 'testone';
        insert opra2;
        
        Vehicle_Detail__c  vehicleDetail =  TestDataUtility.createTestVehicleDetailForIbb(false, opra2);
        vehicleDetail.OEM_Dealer__c = false;
        insert vehicleDetail;
        
        Test.startTest();
        Boolean result = Recall_application.getDecivate('Vehicle_Detail__c', opra2.Id);
        Recall_application.getDecivate('Field_Investigation__c', opra2.Id);
        Recall_application.getDecivate('Income_Details__c', opra2.Id);
        Recall_application.getDecivate('Existing_EMI__c', opra2.Id);
        Recall_application.getDecivate('Documents__c', opra2.Id);
        System.assert(result);
        Test.stopTest();
    }
    
    
    
    
    
    
    
    
    
    
  
     @isTest
    public static void getUserRoleTest(){
        
            Profile p = [SELECT Id FROM Profile WHERE Name='CMU'];
            system.debug('p'+ p);
            User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                              EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                              LocaleSidKey='en_US', ProfileId = p.Id,Maker_Id__c = '1001',
                              TimeZoneSidKey='America/Los_Angeles',
                              MobilePhone = '9701498575',
                              UserName='standarduser4@testorg.com.psdev1');
            insert u; 
             System.runAs(u) 
            {
            Account au1 = new Account();
            au1.Name = 'test';
            au1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business Account').getRecordTypeId();
            insert au1;
        
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            opp.AccountId = au1.Id;
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
        
            AccountTeamMember atm2 = new AccountTeamMember();
            atm2.AccountId = opp.AccountId;
		    atm2.TeamMemberRole = 'BE';
            atm2.UserId = u.Id;
            insert atm2;
        
            Test.startTest();
                  Recall_application.getUserRole(u.Id,opp.Id);
            Test.stopTest();
            }
    }
    
    @isTest
    public static void checkLoanApplicationTransactionHistoryTest(){
         Opportunity opks1 = new Opportunity();
                opks1.StageName = 'Qualification';
                opks1.CloseDate = Date.newInstance(2021, 1, 11);
                opks1.Name = 'testone';
                insert opks1;
            
                Loan_Application_Transaction_History__c lth1 = new Loan_Application_Transaction_History__c();
                lth1.Loan_Application_ID__c = opks1.Id;
                lth1.Module_Name__c = 'FI';
                insert lth1;
        
                Test.startTest();
                       Recall_application.checkLoanApplicationTransactionHistory(opks1.Id,lth1.Module__c);
                Test.stopTest();
    }
    
     @isTest
    public static void checkLoanApplicationTransactionHistoryTest1(){
         Opportunity opks1 = new Opportunity();
                opks1.StageName = 'Qualification';
                opks1.CloseDate = Date.newInstance(2021, 1, 11);
                opks1.Name = 'testone';
                insert opks1;
            
                Loan_Application_Transaction_History__c lth1 = new Loan_Application_Transaction_History__c();
                lth1.Loan_Application_ID__c = opks1.Id;
                lth1.Module_Name__c = 'FI';
                lth1.Assignment_status__c = 'Pending';
                lth1.RecordTypeId = Schema.SObjectType.Loan_Application_Transaction_History__c.getRecordTypeInfosByName().get('Lead Assignment' ).getRecordTypeId();
                insert lth1;
        
                Test.startTest();
                       Recall_application.checkLoanApplicationTransactionHistory(opks1.Id,lth1.Module_Name__c);
                Test.stopTest();
    }
    
}