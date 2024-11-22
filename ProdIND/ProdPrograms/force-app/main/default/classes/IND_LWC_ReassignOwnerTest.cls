/**
* @Name         IND_LWC_ReassignOwnerTest
* @Author       Udit Singhal
* @Company      Salesforce
* @Description  This class contains all test methods of IND_LWC_ReassignOwner class.
*/
@isTest
public class IND_LWC_ReassignOwnerTest {
    
    @testSetup
    static voId testDataSetup(){
        Profile profileRecord = [SELECT Id
                                 FROM Profile
                                 WHERE Name = 'CMU'];
        User userRecord = new User(Alias = 'standt2', EmployeeNumber = 'IBL-1234', Email = 'standarduser2@testorg.com', EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US', LocaleSIdKey = 'en_US', ProfileId = profileRecord.Id, Maker_Id__c = '12', IsActive = true, TimeZoneSIdKey = 'America/Los_Angeles', UserName = 'test_userprod12345@indusbank.com', MobilePhone = '9089078967');
        insert userRecord;
        
        User newUserRecord = new User(Alias = 'standt3', EmployeeNumber = 'IBL-5678', Email = 'standarduser2@testorg.com', EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US', LocaleSIdKey = 'en_US', ProfileId = profileRecord.Id, Maker_Id__c = '12', IsActive = true, TimeZoneSIdKey = 'America/Los_Angeles', UserName = 'test_userprod123456@indusbank.com', MobilePhone = '9089078967');
        insert newUserRecord;
        
        System.runAs(userRecord){
            TriggerSwitch__c trgSwitch = new TriggerSwitch__c();
            trgSwitch.Name = 'Trigger_For_Case';
            trgSwitch.Active__c = true;
            insert trgSwitch;
            
            Account testAccount = new Account(Name = 'TW_Account',State__c='Haryana');
            insert testAccount;
            
            Account testAccount2 = new Account(Name = 'PV_Account',State__c = 'Haryana');
            insert testAccount2;
            
            AccountTeamMember accTeamMember = new AccountTeamMember();
            accTeamMember.AccountId = testAccount.Id;
            accTeamMember.UserId = userRecord.Id;
            accTeamMember.TeamMemberRole = 'MA';
            insert accTeamMember;
            
            AccountTeamMember accTeamMember2 = new AccountTeamMember();
            accTeamMember2.AccountId = testAccount2.Id;
            accTeamMember2.UserId = userRecord.Id;
            accTeamMember2.TeamMemberRole = 'MA';
            insert accTeamMember2;
        }
    }
    
    @isTest
    public static voId testGetLoanApplicationRecords() {
        String reassignmentType = 'Lead Assignment';
        Boolean isTwoWheeler = false;
        Id blCode = [SELECT Id FROM Account WHERE Name = 'PV_Account' LIMIT 1].Id;
        String leadSource = '';
        String teamRole = 'MA';
        String leadNumber = null;
        String benCode = null;
        
        User userRecord = [SELECT Id FROM User WHERE Alias = 'standt2' LIMIT 1];
        System.runAs(userRecord){
            
            List<Opportunity> oppToInsertList = new List<Opportunity>();
            for (Integer i = 0; i < 2; i++){
                oppToInsertList.add(new Opportunity(Name = 'Opportunity' + i, StageName = 'Loan Initiation', CloseDate = System.today().addMonths(1), AccountId = blCode, Product_Type__c = 'Two Wheeler'));
            }
            insert oppToInsertList;
        }
        
        Test.startTest();
        List<Opportunity> oppList = IND_LWC_ReassignOwner.getLoanApplicationRecords(reassignmentType, isTwoWheeler, blCode, leadSource, teamRole, leadNumber, benCode);
        Test.stopTest();
        System.assert(oppList.size() > 0);
    }
    
    @isTest
    public static voId testGetLoanApplicationRecords_CVO_Assignment() {
        String reassignmentType = 'CVO Assignment';
        Boolean isTwoWheeler = true;
        Id blCode = [SELECT Id FROM Account WHERE Name = 'TW_Account' LIMIT 1].Id;
        String leadSource = 'D2C';
        String teamRole = 'MA';
        String leadNumber = null;
        String benCode = 'IBL';
        
        User userRecord = [SELECT Id FROM User WHERE Alias = 'standt2' LIMIT 1];
        System.runAs(userRecord){
            
            List<Opportunity> oppToInsertList = new List<Opportunity>();
            for (Integer i = 0; i < 2; i++){
                oppToInsertList.add(new Opportunity(Name = 'Opportunity' + i, StageName = 'Credit Processing', LeadSource = 'D2C', CloseDate = System.today().addMonths(1), AccountId = blCode, Product_Type__c = 'Two Wheeler'));
            }
            insert oppToInsertList;
        }
        
        Test.startTest();
        List<Opportunity> oppList = IND_LWC_ReassignOwner.getLoanApplicationRecords(reassignmentType, isTwoWheeler, blCode, leadSource, teamRole, leadNumber, benCode);
        Test.stopTest();
        System.assert(oppList.size() > 0);
    }
    
    @isTest
    public static voId testGetFICaseRecords() {
        Id blCode = [SELECT Id FROM Account WHERE Name = 'TW_Account' LIMIT 1].Id;
        String leadSource = '';
        String teamRole = 'MA';
        String leadNumber = null;
        String benCode = 'IBL';
        
        User userRecord = [SELECT Id FROM User WHERE Alias = 'standt2' LIMIT 1];
        System.runAs(userRecord){
            
            List<Opportunity> oppToInsertList = new List<Opportunity>();
            for (Integer i = 0; i < 2; i++){
                oppToInsertList.add(new Opportunity(Name = 'Opportunity' + i, StageName = 'Loan Initiation', CloseDate = System.today().addMonths(1), AccountId = blCode, Product_Type__c = 'Two Wheeler'));
            }
            insert oppToInsertList;
            
            List<Case> caseToInsertList = new List<Case>();
            
            Case newCase = new Case(CMU_Accept__c = false, AccountId = blCode, Loan_Application__c = oppToInsertList[1].Id, Status = 'new', Subject = 'ValId CMU Request Case', Type = 'CMU Request', OwnerId = UserInfo.getUserId());
            caseToInsertList.add(newCase);
            
            Case newCase2 = new Case(CMU_Accept__c = false, AccountId = blCode, Loan_Application__c = oppToInsertList[1].Id, Status = 'new', Subject = 'FI Case', Type = 'Office FI', OwnerId = UserInfo.getUserId(), RecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByName().get('FI').getRecordTypeId());
            caseToInsertList.add(newCase2);
            
            insert caseToInsertList;
        }
        
        Test.startTest();
        List<Case> caseList = IND_LWC_ReassignOwner.getFICaseRecords(blCode, leadSource, teamRole, leadNumber, benCode);
        Test.stopTest();
        System.assert(caseList.size() > 0);
    }
    
    @isTest
    public static voId testGetCMUCaseRecords() {
        Id blCode = [SELECT Id FROM Account WHERE Name = 'TW_Account' LIMIT 1].Id;
        String leadSource = '';
        String teamRole = 'MA';
        String leadNumber = null;
        String benCode = 'IBL';
        
        User userRecord = [SELECT Id FROM User WHERE Alias = 'standt2' LIMIT 1];
        System.runAs(userRecord){
            
            List<Opportunity> oppToInsertList = new List<Opportunity>();
            for (Integer i = 0; i < 2; i++){
                oppToInsertList.add(new Opportunity(Name = 'Opportunity' + i, StageName = 'Loan Initiation', CloseDate = System.today().addMonths(1), AccountId = blCode, Product_Type__c = 'Two Wheeler'));
            }
            insert oppToInsertList;
            
            List<Case> caseToInsertList = new List<Case>();
            
            Case newCase = new Case(CMU_Accept__c = false, AccountId = blCode, Loan_Application__c = oppToInsertList[1].Id, Status = 'Pending with Sales', Subject = 'ValId CMU Request Case', Type = 'CMU Request', OwnerId = UserInfo.getUserId());
            caseToInsertList.add(newCase);
            
            Case newCase2 = new Case(CMU_Accept__c = false, AccountId = blCode, Loan_Application__c = oppToInsertList[1].Id, Status = 'Pending with Sales', Subject = 'FI Case', Type = 'Office FI', OwnerId = UserInfo.getUserId(), RecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByName().get('CMU Request').getRecordTypeId());
            caseToInsertList.add(newCase2);
            
            insert caseToInsertList;
        }
        
        Test.startTest();
        List<Case> caseList = IND_LWC_ReassignOwner.getCMUCaseRecords(blCode, leadSource, teamRole, leadNumber, benCode);
        Test.stopTest();
        System.assert(caseList.size() > 0);
    }
    
    @isTest
    public static voId testGetReassignOwnerRecords() {
        String reassignmentType = 'Lead Assignment';
        Id blCode = [SELECT Id FROM Account WHERE Name = 'PV_Account' LIMIT 1].Id;
        
        User userRecord = [SELECT Id FROM User WHERE Alias = 'standt2' LIMIT 1];
        System.runAs(userRecord){
            
            List<Opportunity> oppToInsertList = new List<Opportunity>();
            for (Integer i = 0; i < 2; i++){
                oppToInsertList.add(new Opportunity(Name = 'Opportunity' + i, StageName = 'Loan Initiation', CloseDate = System.today().addMonths(1), AccountId = blCode, Product_Type__c = 'Two Wheeler'));
            }
            insert oppToInsertList;
            
            Reassign_Owner_Log__c reassignLogRecord = new Reassign_Owner_Log__c();
            reassignLogRecord.Loan_Application__c = oppToInsertList[0].Id;
            reassignLogRecord.Approval_Status__c = 'Pending';
            reassignLogRecord.Previous_Record_Owner__c = userRecord.Id;
            reassignLogRecord.New_Record_Owner__c = userRecord.Id;
            reassignLogRecord.Reassignment_Type__c = reassignmentType;
            reassignLogRecord.Reassignment_Requestor__c = userRecord.Id;
            reassignLogRecord.Reassignment_Approver__c = userRecord.Id;
            
            insert reassignLogRecord;
        }
        
        Test.startTest();
        List<Reassign_Owner_Log__c> reassignOwnerLogList = IND_LWC_ReassignOwner.getReassignOwnerRecords(reassignmentType, userRecord.Id);
        Test.stopTest();
        System.assert(reassignOwnerLogList.size() > 0);
    }
    
    @isTest
    public static voId testGetEligibleUserRecords() {
        String reassignmentType = 'Lead Assignment';
        String leadSource = 'D2C';
        String teamRole = 'MA';
        Id branchAccountId = [SELECT Id FROM Account WHERE Name = 'TW_Account' LIMIT 1].Id;
        String searchTerm = 'IBL';
        
        User userRecord = [SELECT Id FROM User WHERE Alias = 'standt2' LIMIT 1];
        System.runAs(userRecord){
            
            List<Opportunity> oppToInsertList = new List<Opportunity>();
            for (Integer i = 0; i < 2; i++){
                oppToInsertList.add(new Opportunity(Name = 'Opportunity' + i, StageName = 'Loan Initiation', CloseDate = System.today().addMonths(1), AccountId = branchAccountId, Product_Type__c = 'Two Wheeler'));
            }
            insert oppToInsertList;
        }
        
        Test.startTest();
        List<sObject> usersList = IND_LWC_ReassignOwner.getEligibleUserRecords(reassignmentType, leadSource, teamRole, branchAccountId, searchTerm);
        Test.stopTest();
        System.assert(usersList.size() > 0);
    }
    @isTest
    public static voId testGetEligibleUserRecords2() {
        String reassignmentType = 'Lead Assignment';
        String leadSource = 'OLA';
        String teamRole = 'MA';
        Id branchAccountId = [SELECT Id FROM Account WHERE Name = 'TW_Account' LIMIT 1].Id;
        String searchTerm = 'IBL';
        User userRecord = [SELECT Id FROM User WHERE Alias = 'standt2' LIMIT 1];
        System.runAs(userRecord){
            
            List<Opportunity> oppToInsertList = new List<Opportunity>();
            for (Integer i = 0; i < 2; i++){
                oppToInsertList.add(new Opportunity(Name = 'Opportunity' + i, StageName = 'Loan Initiation', CloseDate = System.today().addMonths(1), AccountId = branchAccountId, Product_Type__c = 'Two Wheeler'));
            }
            insert oppToInsertList;
        }
        
        Test.startTest();
        List<sObject> usersList = IND_LWC_ReassignOwner.getEligibleUserRecords(reassignmentType, leadSource, teamRole, branchAccountId, searchTerm);
        Test.stopTest();
    }
    @isTest
    public static voId testGetEligibleUserRecords3() {
        String reassignmentType = 'Lead Assignment';
        String leadSource = '';
        String teamRole = 'MA';
        Id branchAccountId = [SELECT Id FROM Account WHERE Name = 'TW_Account' LIMIT 1].Id;
        String searchTerm = 'IBL';
        
        User userRecord = [SELECT Id FROM User WHERE Alias = 'standt2' LIMIT 1];
        System.runAs(userRecord){
            
            List<Opportunity> oppToInsertList = new List<Opportunity>();
            for (Integer i = 0; i < 2; i++){
                oppToInsertList.add(new Opportunity(Name = 'Opportunity' + i, StageName = 'Loan Initiation', CloseDate = System.today().addMonths(1), AccountId = branchAccountId, Product_Type__c = 'Two Wheeler'));
            }
            insert oppToInsertList;
        }
        
        Test.startTest();
        List<sObject> usersList = IND_LWC_ReassignOwner.getEligibleUserRecords(reassignmentType, leadSource, teamRole, branchAccountId, searchTerm);
        Test.stopTest();
        System.assert(usersList.size() > 0);
    }
    @isTest
    public static voId testGetEligibleUserRecordsLA2() {
        String reassignmentType = 'CMU Case Assignment';
        String leadSource = '';
        String teamRole = 'MA';
        Id branchAccountId = [SELECT Id FROM Account WHERE Name = 'TW_Account' LIMIT 1].Id;
        String searchTerm = 'IBL';
        
        User userRecord = [SELECT Id FROM User WHERE Alias = 'standt2' LIMIT 1];
        System.runAs(userRecord){
            
            List<Opportunity> oppToInsertList = new List<Opportunity>();
            for (Integer i = 0; i < 2; i++){
                oppToInsertList.add(new Opportunity(Name = 'Opportunity' + i, StageName = 'Loan Initiation', CloseDate = System.today().addMonths(1), AccountId = branchAccountId, Product_Type__c = 'Two Wheeler'));
            }
            insert oppToInsertList;
        }
        
        Test.startTest();
        List<sObject> usersList = IND_LWC_ReassignOwner.getEligibleUserRecords(reassignmentType, leadSource, teamRole, branchAccountId, searchTerm);
        Test.stopTest();
    }
    @isTest
    public static voId testGetEligibleUserRecordsLA3() {
        String reassignmentType = 'CMU Case Assignment';
        String leadSource = 'OLA';
        String teamRole = 'MA';
        Id branchAccountId = [SELECT Id FROM Account WHERE Name = 'TW_Account' LIMIT 1].Id;
        String searchTerm = 'IBL';
        
        User userRecord = [SELECT Id FROM User WHERE Alias = 'standt2' LIMIT 1];
        System.runAs(userRecord){
            
            List<Opportunity> oppToInsertList = new List<Opportunity>();
            for (Integer i = 0; i < 2; i++){
                oppToInsertList.add(new Opportunity(Name = 'Opportunity' + i, StageName = 'Loan Initiation', CloseDate = System.today().addMonths(1), AccountId = branchAccountId, Product_Type__c = 'Two Wheeler'));
            }
            insert oppToInsertList;
        }
        
        Test.startTest();
        List<sObject> usersList = IND_LWC_ReassignOwner.getEligibleUserRecords(reassignmentType, leadSource, teamRole, branchAccountId, searchTerm);
        Test.stopTest();
            }
    @isTest
    public static voId testGetEligibleUserRecordsLA4() {
        String reassignmentType = 'FI Case Assignment';
        String leadSource = '';
        String teamRole = 'MA';
        Id branchAccountId = [SELECT Id FROM Account WHERE Name = 'TW_Account' LIMIT 1].Id;
        String searchTerm = 'IBL';
        
        User userRecord = [SELECT Id FROM User WHERE Alias = 'standt2' LIMIT 1];
        System.runAs(userRecord){
            
            List<Opportunity> oppToInsertList = new List<Opportunity>();
            for (Integer i = 0; i < 2; i++){
                oppToInsertList.add(new Opportunity(Name = 'Opportunity' + i, StageName = 'Loan Initiation', CloseDate = System.today().addMonths(1), AccountId = branchAccountId, Product_Type__c = 'Two Wheeler'));
            }
            insert oppToInsertList;
        }
        
        Test.startTest();
        List<sObject> usersList = IND_LWC_ReassignOwner.getEligibleUserRecords(reassignmentType, leadSource, teamRole, branchAccountId, searchTerm);
        Test.stopTest();
    }
    @isTest
    public static voId testGetEligibleUserRecordsFI2() {
        String reassignmentType = 'FI Case Assignment';
        String leadSource = 'OLA';
        String teamRole = 'MA';
        Id branchAccountId = [SELECT Id FROM Account WHERE Name = 'TW_Account' LIMIT 1].Id;
        String searchTerm = 'IBL';
        
        User userRecord = [SELECT Id FROM User WHERE Alias = 'standt2' LIMIT 1];
        System.runAs(userRecord){
            
            List<Opportunity> oppToInsertList = new List<Opportunity>();
            for (Integer i = 0; i < 2; i++){
                oppToInsertList.add(new Opportunity(Name = 'Opportunity' + i, StageName = 'Loan Initiation', CloseDate = System.today().addMonths(1), AccountId = branchAccountId, Product_Type__c = 'Two Wheeler'));
            }
            insert oppToInsertList;
        }
        
        Test.startTest();
        List<sObject> usersList = IND_LWC_ReassignOwner.getEligibleUserRecords(reassignmentType, leadSource, teamRole, branchAccountId, searchTerm);
        Test.stopTest();
    }
    @isTest
    public static voId testGetEligibleUserRecordsFI3() {
        String reassignmentType = 'FI Case Assignment';
        String leadSource = 'D2C';
        String teamRole = 'MA';
        Id branchAccountId = [SELECT Id FROM Account WHERE Name = 'TW_Account' LIMIT 1].Id;
        String searchTerm = 'IBL';
        User userRecord = [SELECT Id FROM User WHERE Alias = 'standt2' LIMIT 1];
        System.runAs(userRecord){
            List<Opportunity> oppToInsertList = new List<Opportunity>();
            for (Integer i = 0; i < 2; i++){
                oppToInsertList.add(new Opportunity(Name = 'Opportunity' + i, StageName = 'Loan Initiation', CloseDate = System.today().addMonths(1), AccountId = branchAccountId, Product_Type__c = 'Two Wheeler'));
            }
            insert oppToInsertList;
        }
        Test.startTest();
        List<sObject> usersList = IND_LWC_ReassignOwner.getEligibleUserRecords(reassignmentType, leadSource, teamRole, branchAccountId, searchTerm);
        Test.stopTest();
    }
    @isTest
    public static voId testGetEligibleUserRecords4() {
        String reassignmentType = 'CVO Assignment';
        String leadSource = '';
        String teamRole = 'MA';
        Id branchAccountId = [SELECT Id FROM Account WHERE Name = 'TW_Account' LIMIT 1].Id;
        String searchTerm = 'IBL';
        
        User userRecord = [SELECT Id FROM User WHERE Alias = 'standt2' LIMIT 1];
        System.runAs(userRecord){
            
            List<Opportunity> oppToInsertList = new List<Opportunity>();
            for (Integer i = 0; i < 2; i++){
                oppToInsertList.add(new Opportunity(Name = 'Opportunity' + i, StageName = 'Loan Initiation', CloseDate = System.today().addMonths(1), AccountId = branchAccountId, Product_Type__c = 'Two Wheeler'));
            }
            insert oppToInsertList;
        }
        
        Test.startTest();
        List<sObject> usersList = IND_LWC_ReassignOwner.getEligibleUserRecords(reassignmentType, leadSource, teamRole, branchAccountId, searchTerm);
        Test.stopTest();
    }
    @isTest
    public static voId testSubmitReassignmentRequest() {
        String reassignmentType = 'Lead Assignment';
        String approverRole = 'MA';
        Id branchId = [SELECT Id FROM Account WHERE Name = 'PV_Account' LIMIT 1].Id;
        List<Id> selectedRecordIdList = new List<Id>();
        Boolean isApproved = false;
        
        User userRecord = [SELECT Id FROM User WHERE Alias = 'standt2' LIMIT 1];
        System.runAs(userRecord){
            
            List<Opportunity> oppToInsertList = new List<Opportunity>();
            for (Integer i = 0; i < 2; i++){
                oppToInsertList.add(new Opportunity(Name = 'Opportunity' + i, StageName = 'Loan Initiation', CloseDate = System.today().addMonths(1), AccountId = branchId, Product_Type__c = 'Two Wheeler'));
            }
            insert oppToInsertList;
            selectedRecordIdList.add(oppToInsertList[0].Id);
            selectedRecordIdList.add(oppToInsertList[1].Id);
        }
        
        Test.startTest();
        String result = IND_LWC_ReassignOwner.submitReassignmentRequest(reassignmentType, approverRole, userRecord.Id, userRecord.Id, branchId, selectedRecordIdList, isApproved);
        Test.stopTest();
        System.assert(String.isNotBlank(result));
    }
    @isTest
    public static voId testSubmitReassignmentRequest2() {
        String reassignmentType = 'Lead Assignment';
        String approverRole = 'MA';
        Id branchId = [SELECT Id FROM Account WHERE Name = 'PV_Account' LIMIT 1].Id;
        List<Id> selectedRecordIdList = new List<Id>();
        Boolean isApproved = false;
        
        User userRecord = [SELECT Id FROM User WHERE Alias = 'standt2' LIMIT 1];
        User userRecord2 = [SELECT Id FROM User WHERE Alias = 'standt3' LIMIT 1];
        System.runAs(userRecord){
            List<Opportunity> oppToInsertList = new List<Opportunity>();
            for (Integer i = 0; i < 2; i++){
                oppToInsertList.add(new Opportunity(Name = 'Opportunity' + i, StageName = 'Loan Initiation', CloseDate = System.today().addMonths(1), AccountId = branchId, Product_Type__c = 'Two Wheeler'));
            }
            insert oppToInsertList;
            selectedRecordIdList.add(oppToInsertList[0].Id);
            selectedRecordIdList.add(oppToInsertList[1].Id);
        }
        Test.startTest();
        String result = IND_LWC_ReassignOwner.submitReassignmentRequest(reassignmentType, approverRole, userRecord.Id, userRecord2.Id, branchId, selectedRecordIdList, isApproved);
        Test.stopTest();
        System.assert(String.isNotBlank(result));
    }
    @isTest
    public static voId testSubmitReassignmentRequest3() {
        String reassignmentType = 'FI Case Assignment';
        String approverRole = 'MA';
        Id branchId = [SELECT Id FROM Account WHERE Name = 'PV_Account' LIMIT 1].Id;
        List<Id> selectedRecordIdList = new List<Id>();
        Boolean isApproved = false;
        
        User userRecord = [SELECT Id FROM User WHERE Alias = 'standt2' LIMIT 1];
        User userRecord2 = [SELECT Id FROM User WHERE Alias = 'standt3' LIMIT 1];
        System.runAs(userRecord){
            List<Opportunity> oppToInsertList = new List<Opportunity>();
            for (Integer i = 0; i < 2; i++){
                oppToInsertList.add(new Opportunity(Name = 'Opportunity' + i, StageName = 'Loan Initiation', CloseDate = System.today().addMonths(1), AccountId = branchId, Product_Type__c = 'Two Wheeler'));
            }
            insert oppToInsertList;
            List<Case> caseToInsertList = new List<Case>();
            Case newCase = new Case(CMU_Accept__c = false, AccountId = branchId, Loan_Application__c = oppToInsertList[0].Id, Status = 'Pending with Sales', Subject = 'ValId CMU Request Case', Type = 'CMU Request', OwnerId = UserInfo.getUserId());
            caseToInsertList.add(newCase);
            Case newCase2 = new Case(CMU_Accept__c = false, AccountId = branchId, Loan_Application__c = oppToInsertList[0].Id, Status = 'Pending with Sales', Subject = 'FI Case', Type = 'Office FI', OwnerId = UserInfo.getUserId(), RecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByName().get('CMU Request').getRecordTypeId());
            caseToInsertList.add(newCase2);
            insert caseToInsertList;
            selectedRecordIdList.add(caseToInsertList[0].Id);
            selectedRecordIdList.add(caseToInsertList[1].Id);
        }
        Test.startTest();
        String result = IND_LWC_ReassignOwner.submitReassignmentRequest(reassignmentType, approverRole, userRecord.Id, userRecord2.Id, branchId, selectedRecordIdList, isApproved);
        Test.stopTest();
        System.assert(String.isNotBlank(result));
    }
    
    @isTest
    public static voId testSubmitReassignmentRequest_CMU_Case_Assignment() {
        String reassignmentType = 'CMU Case Assignment';
        String approverRole = 'MA';
        Id branchId = [SELECT Id FROM Account WHERE Name = 'PV_Account' LIMIT 1].Id;
        List<Id> selectedRecordIdList = new List<Id>();
        Boolean isApproved = false;
        
        User userRecord = [SELECT Id FROM User WHERE Alias = 'standt2' LIMIT 1];
        System.runAs(userRecord){
            
            List<Opportunity> oppToInsertList = new List<Opportunity>();
            for (Integer i = 0; i < 2; i++){
                oppToInsertList.add(new Opportunity(Name = 'Opportunity' + i, StageName = 'Loan Initiation', CloseDate = System.today().addMonths(1), AccountId = branchId, Product_Type__c = 'Two Wheeler'));
            }
            insert oppToInsertList;
            
            List<Case> caseToInsertList = new List<Case>();
            
            Case newCase = new Case(CMU_Accept__c = false, AccountId = branchId, Loan_Application__c = oppToInsertList[0].Id, Status = 'Pending with Sales', Subject = 'ValId CMU Request Case', Type = 'CMU Request', OwnerId = UserInfo.getUserId());
            caseToInsertList.add(newCase);
            
            Case newCase2 = new Case(CMU_Accept__c = false, AccountId = branchId, Loan_Application__c = oppToInsertList[0].Id, Status = 'Pending with Sales', Subject = 'FI Case', Type = 'Office FI', OwnerId = UserInfo.getUserId(), RecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByName().get('CMU Request').getRecordTypeId());
            caseToInsertList.add(newCase2);
            
            insert caseToInsertList;
            
            selectedRecordIdList.add(caseToInsertList[0].Id);
            selectedRecordIdList.add(caseToInsertList[1].Id);
        }
        
        Test.startTest();
        String result = IND_LWC_ReassignOwner.submitReassignmentRequest(reassignmentType, approverRole, userRecord.Id, userRecord.Id, branchId, selectedRecordIdList, isApproved);
        Test.stopTest();
        System.assert(String.isNotBlank(result));
    }
    
    @isTest
    public static voId testSubmitReassignmentRequest_Auto_Approve() {
        String reassignmentType = 'Lead Assignment';
        String approverRole = 'MA';
        Id branchId = [SELECT Id FROM Account WHERE Name = 'PV_Account' LIMIT 1].Id;
        List<Id> selectedRecordIdList = new List<Id>();
        Boolean isApproved = true;
        
        User userRecord = [SELECT Id FROM User WHERE Alias = 'standt2' LIMIT 1];
        System.runAs(userRecord){
            
            List<Opportunity> oppToInsertList = new List<Opportunity>();
            for (Integer i = 0; i < 2; i++){
                oppToInsertList.add(new Opportunity(Name = 'Opportunity' + i, StageName = 'Loan Initiation', CloseDate = System.today().addMonths(1), AccountId = branchId, Product_Type__c = 'Two Wheeler'));
            }
            insert oppToInsertList;
            selectedRecordIdList.add(oppToInsertList[0].Id);
            selectedRecordIdList.add(oppToInsertList[1].Id);
        }
        
        Test.startTest();
        String result = IND_LWC_ReassignOwner.submitReassignmentRequest(reassignmentType, approverRole, userRecord.Id, userRecord.Id, branchId, selectedRecordIdList, isApproved);
        Test.stopTest();
        System.assert(String.isNotBlank(result));
    }
        @isTest
    public static voId testSubmitReassignmentRequest_Auto_Approve2() {
        String reassignmentType = 'FI Case Assignment';
        String approverRole = 'MA';
        Id branchId = [SELECT Id FROM Account WHERE Name = 'PV_Account' LIMIT 1].Id;
        List<Id> selectedRecordIdList = new List<Id>();
        Boolean isApproved = true;
        
        User userRecord = [SELECT Id FROM User WHERE Alias = 'standt2' LIMIT 1];
        System.runAs(userRecord){
            
            List<Opportunity> oppToInsertList = new List<Opportunity>();
            for (Integer i = 0; i < 2; i++){
                oppToInsertList.add(new Opportunity(Name = 'Opportunity' + i, StageName = 'Loan Initiation', CloseDate = System.today().addMonths(1), AccountId = branchId, Product_Type__c = 'Two Wheeler'));
            }
            insert oppToInsertList;
            selectedRecordIdList.add(oppToInsertList[0].Id);
            selectedRecordIdList.add(oppToInsertList[1].Id);
        }
        
        Test.startTest();
        String result = IND_LWC_ReassignOwner.submitReassignmentRequest(reassignmentType, approverRole, userRecord.Id, userRecord.Id, branchId, selectedRecordIdList, isApproved);
        Test.stopTest();
        System.assert(String.isNotBlank(result));
    }    
    @isTest
    public static voId testProcessReassignmentRequest_Lead_Assignment_Reject() {
        String reassignmentType = 'Lead Assignment';
        Id blCode = [SELECT Id FROM Account WHERE Name = 'PV_Account' LIMIT 1].Id;
        List<Id> selectedRecordIdList = new List<Id>();
        Boolean isApproved = false;
        
        User userRecord = [SELECT Id FROM User WHERE Alias = 'standt2' LIMIT 1];
        System.runAs(userRecord){
            
            List<Opportunity> oppToInsertList = new List<Opportunity>();
            for (Integer i = 0; i < 2; i++){
                oppToInsertList.add(new Opportunity(Name = 'Opportunity' + i, StageName = 'Loan Initiation', CloseDate = System.today().addMonths(1), AccountId = blCode, Product_Type__c = 'Two Wheeler'));
            }
            insert oppToInsertList;
            
            Reassign_Owner_Log__c reassignLogRecord = new Reassign_Owner_Log__c();
            reassignLogRecord.Loan_Application__c = oppToInsertList[0].Id;
            reassignLogRecord.Approval_Status__c = 'Pending';
            reassignLogRecord.Previous_Record_Owner__c = userRecord.Id;
            reassignLogRecord.New_Record_Owner__c = userRecord.Id;
            reassignLogRecord.Reassignment_Type__c = reassignmentType;
            reassignLogRecord.Reassignment_Requestor__c = userRecord.Id;
            reassignLogRecord.Reassignment_Approver__c = userRecord.Id;
            
            insert reassignLogRecord;
            selectedRecordIdList.add(reassignLogRecord.Id);
        }
        
        Test.startTest();
        String result = IND_LWC_ReassignOwner.processReassignmentRequest(reassignmentType, selectedRecordIdList, isApproved);
        Test.stopTest();
        System.assert(String.isNotBlank(result));
    }
    
    @isTest
    public static voId testProcessReassignmentRequest_Lead_Assignment_Approve() {
        String reassignmentType = 'Lead Assignment';
        Id blCode = [SELECT Id FROM Account WHERE Name = 'PV_Account' LIMIT 1].Id;
        List<Id> selectedRecordIdList = new List<Id>();
        Boolean isApproved = true;
        
        User userRecord = [SELECT Id FROM User WHERE Alias = 'standt2' LIMIT 1];
        System.runAs(userRecord){
            
            List<Opportunity> oppToInsertList = new List<Opportunity>();
            for (Integer i = 0; i < 2; i++){
                oppToInsertList.add(new Opportunity(Name = 'Opportunity' + i, StageName = 'Loan Initiation', CloseDate = System.today().addMonths(1), AccountId = blCode, Product_Type__c = 'Two Wheeler'));
            }
            insert oppToInsertList;
            
            List<Case> caseToInsertList = new List<Case>();
            
            Case newCase = new Case(CMU_Accept__c = false, AccountId = blCode, Loan_Application__c = oppToInsertList[0].Id, Status = 'Pending with Sales', Subject = 'ValId CMU Request Case', Type = 'CMU Request', OwnerId = UserInfo.getUserId());
            caseToInsertList.add(newCase);
            
            Case newCase2 = new Case(CMU_Accept__c = false, AccountId = blCode, Loan_Application__c = oppToInsertList[0].Id, Status = 'Pending with Sales', Subject = 'FI Case', Type = 'Office FI', OwnerId = UserInfo.getUserId(), RecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByName().get('CMU Request').getRecordTypeId());
            caseToInsertList.add(newCase2);
            
            insert caseToInsertList;
            
            Reassign_Owner_Log__c reassignLogRecord = new Reassign_Owner_Log__c();
            reassignLogRecord.Loan_Application__c = oppToInsertList[0].Id;
            reassignLogRecord.Approval_Status__c = 'Pending';
            reassignLogRecord.Previous_Record_Owner__c = userRecord.Id;
            reassignLogRecord.New_Record_Owner__c = userRecord.Id;
            reassignLogRecord.Reassignment_Type__c = reassignmentType;
            reassignLogRecord.Reassignment_Requestor__c = userRecord.Id;
            reassignLogRecord.Reassignment_Approver__c = userRecord.Id;
            
            insert reassignLogRecord;
            selectedRecordIdList.add(reassignLogRecord.Id);
        }
        
        Test.startTest();
        String result = IND_LWC_ReassignOwner.processReassignmentRequest(reassignmentType, selectedRecordIdList, isApproved);
        Test.stopTest();
        System.assert(String.isNotBlank(result));
    }
    
    @isTest
    public static voId testProcessReassignmentRequest_CVO_Assignment_Approve() {
        String reassignmentType = 'CVO Assignment';
        Id blCode = [SELECT Id FROM Account WHERE Name = 'PV_Account' LIMIT 1].Id;
        List<Id> selectedRecordIdList = new List<Id>();
        Boolean isApproved = true;
        
        User userRecord = [SELECT Id FROM User WHERE Alias = 'standt2' LIMIT 1];
        System.runAs(userRecord){
            
            List<Opportunity> oppToInsertList = new List<Opportunity>();
            for (Integer i = 0; i < 2; i++){
                oppToInsertList.add(new Opportunity(Name = 'Opportunity' + i, StageName = 'Loan Initiation', CloseDate = System.today().addMonths(1), AccountId = blCode, Product_Type__c = 'Two Wheeler'));
            }
            insert oppToInsertList;
            
            List<Case> caseToInsertList = new List<Case>();
            
            Case newCase = new Case(CMU_Accept__c = false, AccountId = blCode, Loan_Application__c = oppToInsertList[0].Id, Status = 'Pending with Sales', Subject = 'ValId CMU Request Case', Type = 'CMU Request', OwnerId = UserInfo.getUserId());
            caseToInsertList.add(newCase);
            
            Case newCase2 = new Case(CMU_Accept__c = false, AccountId = blCode, Loan_Application__c = oppToInsertList[0].Id, Status = 'Pending with Sales', Subject = 'FI Case', Type = 'Office FI', OwnerId = UserInfo.getUserId(), RecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByName().get('CMU Request').getRecordTypeId());
            caseToInsertList.add(newCase2);
            
            insert caseToInsertList;
            
            Reassign_Owner_Log__c reassignLogRecord = new Reassign_Owner_Log__c();
            reassignLogRecord.Loan_Application__c = oppToInsertList[0].Id;
            reassignLogRecord.Approval_Status__c = 'Pending';
            reassignLogRecord.Previous_Record_Owner__c = userRecord.Id;
            reassignLogRecord.New_Record_Owner__c = userRecord.Id;
            reassignLogRecord.Reassignment_Type__c = reassignmentType;
            reassignLogRecord.Reassignment_Requestor__c = userRecord.Id;
            reassignLogRecord.Reassignment_Approver__c = userRecord.Id;
            
            insert reassignLogRecord;
            selectedRecordIdList.add(reassignLogRecord.Id);
        }
        
        Test.startTest();
        String result = IND_LWC_ReassignOwner.processReassignmentRequest(reassignmentType, selectedRecordIdList, isApproved);
        Test.stopTest();
        System.assert(String.isNotBlank(result));
    }
    
    @isTest
    public static voId testProcessReassignmentRequest_FI_Assignment() {
        String reassignmentType = 'FI Case Assignment';
        Id blCode = [SELECT Id FROM Account WHERE Name = 'PV_Account' LIMIT 1].Id;
        List<Id> selectedRecordIdList = new List<Id>();
        Boolean isApproved = true;
        
        User userRecord = [SELECT Id FROM User WHERE Alias = 'standt2' LIMIT 1];
        System.runAs(userRecord){
            
            List<Opportunity> oppToInsertList = new List<Opportunity>();
            for (Integer i = 0; i < 2; i++){
                oppToInsertList.add(new Opportunity(Name = 'Opportunity' + i, StageName = 'Loan Initiation', CloseDate = System.today().addMonths(1), AccountId = blCode, Product_Type__c = 'Two Wheeler'));
            }
            insert oppToInsertList;
            
            List<Case> caseToInsertList = new List<Case>();
            
            Case newCase = new Case(CMU_Accept__c = false, AccountId = blCode, Loan_Application__c = oppToInsertList[0].Id, Status = 'Pending with Sales', Subject = 'ValId CMU Request Case', Type = 'CMU Request', OwnerId = UserInfo.getUserId());
            caseToInsertList.add(newCase);
            
            Case newCase2 = new Case(CMU_Accept__c = false, AccountId = blCode, Loan_Application__c = oppToInsertList[0].Id, Status = 'Pending with Sales', Subject = 'FI Case', Type = 'Office FI', OwnerId = UserInfo.getUserId(), RecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByName().get('CMU Request').getRecordTypeId());
            caseToInsertList.add(newCase2);
            
            insert caseToInsertList;
            
            Reassign_Owner_Log__c reassignLogRecord = new Reassign_Owner_Log__c();
            reassignLogRecord.Loan_Application__c = oppToInsertList[0].Id;
            reassignLogRecord.Case__c = caseToInsertList[0].Id;
            reassignLogRecord.Approval_Status__c = 'Pending';
            reassignLogRecord.Previous_Record_Owner__c = userRecord.Id;
            reassignLogRecord.New_Record_Owner__c = userRecord.Id;
            reassignLogRecord.Reassignment_Type__c = reassignmentType;
            reassignLogRecord.Reassignment_Requestor__c = userRecord.Id;
            reassignLogRecord.Reassignment_Approver__c = userRecord.Id;
            
            insert reassignLogRecord;
            selectedRecordIdList.add(reassignLogRecord.Id);
        }
        
        Test.startTest();
        String result = IND_LWC_ReassignOwner.processReassignmentRequest(reassignmentType, selectedRecordIdList, isApproved);
        Test.stopTest();
        System.assert(String.isNotBlank(result));
    }
    
    @isTest
    public static voId testProcessReassignmentRequest_Exception() {
        String reassignmentType = 'Lead Assignment';
        Id blCode = [SELECT Id FROM Account WHERE Name = 'PV_Account' LIMIT 1].Id;
        List<Id> selectedRecordIdList = new List<Id>();
        Boolean isApproved = true;
        
        User userRecord = [SELECT Id FROM User WHERE Alias = 'standt2' LIMIT 1];
        System.runAs(userRecord){
            
            List<Opportunity> oppToInsertList = new List<Opportunity>();
            for (Integer i = 0; i < 2; i++){
                oppToInsertList.add(new Opportunity(Name = 'Opportunity' + i, StageName = 'Loan Initiation', CloseDate = System.today().addMonths(1), AccountId = blCode, Product_Type__c = 'Two Wheeler'));
            }
            insert oppToInsertList;
            
            List<Case> caseToInsertList = new List<Case>();
            
            Case newCase = new Case(CMU_Accept__c = false, AccountId = blCode, Loan_Application__c = oppToInsertList[0].Id, Status = 'Pending with Sales', Subject = 'ValId CMU Request Case', Type = 'CMU Request', OwnerId = UserInfo.getUserId());
            caseToInsertList.add(newCase);
            
            Case newCase2 = new Case(CMU_Accept__c = false, AccountId = blCode, Loan_Application__c = oppToInsertList[0].Id, Status = 'Pending with Sales', Subject = 'FI Case', Type = 'Office FI', OwnerId = UserInfo.getUserId(), RecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByName().get('CMU Request').getRecordTypeId());
            caseToInsertList.add(newCase2);
            
            insert caseToInsertList;
            
            Reassign_Owner_Log__c reassignLogRecord = new Reassign_Owner_Log__c();
            reassignLogRecord.Loan_Application__c = oppToInsertList[0].Id;
            reassignLogRecord.Approval_Status__c = 'Pending';
            reassignLogRecord.Previous_Record_Owner__c = userRecord.Id;
            reassignLogRecord.New_Record_Owner__c = userRecord.Id;
            reassignLogRecord.Reassignment_Type__c = reassignmentType;
            reassignLogRecord.Reassignment_Requestor__c = userRecord.Id;
            reassignLogRecord.Reassignment_Approver__c = userRecord.Id;
            
            insert reassignLogRecord;
            selectedRecordIdList.add(reassignLogRecord.Id);
        }
        
        userRecord.isActive = false;
        update userRecord;
        
        Test.startTest();
        String result = IND_LWC_ReassignOwner.processReassignmentRequest(reassignmentType, selectedRecordIdList, isApproved);
        Test.stopTest();
        System.assert(String.isNotBlank(result));
    }
    
    @isTest
    public static voId testProcessReassignmentRequest_Exception2() {
        String reassignmentType = 'Lead Assignment';
        Id blCode = [SELECT Id FROM Account WHERE Name = 'PV_Account' LIMIT 1].Id;
        List<Id> selectedRecordIdList = new List<Id>();
        Boolean isApproved = true;
        
        User userRecord = [SELECT Id FROM User WHERE Alias = 'standt2' LIMIT 1];
        System.runAs(userRecord){
            
            List<Opportunity> oppToInsertList = new List<Opportunity>();
            for (Integer i = 0; i < 2; i++){
                oppToInsertList.add(new Opportunity(Name = 'Opportunity' + i, StageName = 'Loan Initiation', CloseDate = System.today().addMonths(1), AccountId = blCode, Product_Type__c = 'Two Wheeler'));
            }
            insert oppToInsertList;
        }
        
        Test.startTest();
        String result = IND_LWC_ReassignOwner.processReassignmentRequest(reassignmentType, null, isApproved);
        Test.stopTest();
        System.assert(String.isNotBlank(result));
    }
    @isTest
    public static voId testSubmitReassignmentRequest_2() {
        String reassignmentType = 'Lead Assignment';
        String approverRole = 'MA';
        Id branchId = [SELECT Id FROM Account WHERE Name = 'PV_Account' LIMIT 1].Id;
        List<Id> selectedRecordIdList = new List<Id>();
        Boolean isApproved = true;
        
        User userRecord = [SELECT Id FROM User WHERE Alias = 'standt2' LIMIT 1];
        User userRecord2 = [SELECT Id FROM User WHERE Alias = 'standt3' LIMIT 1];
        System.runAs(userRecord){
            List<Opportunity> oppToInsertList = new List<Opportunity>();
            for (Integer i = 0; i < 2; i++){
                oppToInsertList.add(new Opportunity(Name = 'Opportunity' + i, StageName = 'Loan Initiation', CloseDate = System.today().addMonths(1), AccountId = branchId, Product_Type__c = 'Two Wheeler'));
            }
            insert oppToInsertList;
            selectedRecordIdList.add(oppToInsertList[0].Id);
            selectedRecordIdList.add(oppToInsertList[1].Id);
        }
        Test.startTest();
        String result = IND_LWC_ReassignOwner.submitReassignmentRequest(reassignmentType, approverRole, userRecord.Id, userRecord2.Id, branchId, selectedRecordIdList, isApproved);
        Test.stopTest();
    }
    @isTest
    public static voId testSubmitReassignmentRequest_3() {
        String reassignmentType = 'Lead Assignment';
        String approverRole = 'MA';
        Id branchId = [SELECT Id FROM Account WHERE Name = 'PV_Account' LIMIT 1].Id;
        List<Id> selectedRecordIdList = new List<Id>();
        Boolean isApproved = false;
        
        User userRecord = [SELECT Id FROM User WHERE Alias = 'standt2' LIMIT 1];
        User userRecord2 = [SELECT Id FROM User WHERE Alias = 'standt3' LIMIT 1];
        System.runAs(userRecord){
            List<Opportunity> oppToInsertList = new List<Opportunity>();
            for (Integer i = 0; i < 2; i++){
                oppToInsertList.add(new Opportunity(Name = 'Opportunity' + i, StageName = 'Loan Initiation', CloseDate = System.today().addMonths(1), AccountId = branchId, Product_Type__c = 'Two Wheeler'));
            }
            insert oppToInsertList;
            selectedRecordIdList.add(oppToInsertList[0].Id);
            selectedRecordIdList.add(oppToInsertList[1].Id);
        }
        Test.startTest();
        String result = IND_LWC_ReassignOwner.submitReassignmentRequest(reassignmentType, approverRole, userRecord.Id, userRecord2.Id, branchId, selectedRecordIdList, isApproved);
        Test.stopTest();
    }
    /*@isTest
    public static voId testSubmitReassignmentRequest_4() {
        String reassignmentType = 'Lead Assignment';
        String approverRole = 'MA';
        Id branchId = [SELECT Id FROM Account WHERE Name = 'PV_Account' LIMIT 1].Id;
        List<Id> selectedRecordIdList = new List<Id>();
        Boolean isApproved = false;
        Account acct = new Account(Name='Apex Test'); 
        insert acct;
        //Contact con = new Contact(LastName='Apex Test', AccountId=acct.Id); 
        //insert con;
        Profile profileRecord = [SELECT Id
                                 FROM Profile
                                 WHERE Name = 'IBL Business Executive'];
        User userRecord = new User(Alias = 'standt4', EmployeeNumber = 'IBL-1234', Email = 'standarduser2@testorg.com', EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US', LocaleSIdKey = 'en_US', ProfileId = profileRecord.Id, Maker_Id__c = '12', TimeZoneSIdKey = 'America/Los_Angeles', UserName = 'test_userprod1234sftsfdt5@indusbank.com', MobilePhone = '9089078967');
        insert userRecord;
        User userRecord2 = [SELECT Id FROM User WHERE Alias = 'standt3' LIMIT 1];
        System.runAs(userRecord){
            List<Opportunity> oppToInsertList = new List<Opportunity>();
            for (Integer i = 0; i < 2; i++){
                oppToInsertList.add(new Opportunity(Name = 'Opportunity' + i, StageName = 'Loan Initiation', CloseDate = System.today().addMonths(1), AccountId = branchId, Product_Type__c = 'Two Wheeler'));
            }
            insert oppToInsertList;
            selectedRecordIdList.add(oppToInsertList[0].Id);
            selectedRecordIdList.add(oppToInsertList[1].Id);
        }
        Test.startTest();
        String result = IND_LWC_ReassignOwner.submitReassignmentRequest(reassignmentType, approverRole, userRecord.Id, userRecord2.Id, branchId, selectedRecordIdList, isApproved);
        Test.stopTest();
    }*/
}