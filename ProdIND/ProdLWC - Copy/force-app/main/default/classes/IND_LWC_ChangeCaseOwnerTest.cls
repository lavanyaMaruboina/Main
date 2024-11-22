/**
 * @Name         IND_LWC_ChangeCaseOwnerTest
 * @Author       Udit Singhal
 * @Company      Salesforce
 * @Description  This class contains all test methods of IND_LWC_ChangeCaseOwner class.
 */
@isTest
public class IND_LWC_ChangeCaseOwnerTest{
    @testSetup
    static void testDataSetup(){
        //create user
        Profile profileRecord = [SELECT Id
                                 FROM Profile
                                 WHERE Name = 'CMU'];
        User userRecord = new User(Alias = 'standt2', Email = 'standarduser2@testorg.com', EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', ProfileId = profileRecord.Id, Maker_Id__c = '12', IsActive = true, TimeZoneSidKey = 'America/Los_Angeles', UserName = 'test_userprod12345@indusbank.com', MobilePhone = '9089078967');
        insert userRecord;

        User newUserRecord = new User(Alias = 'standt3', Email = 'standarduser2@testorg.com', EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', ProfileId = profileRecord.Id, Maker_Id__c = '12', IsActive = true, TimeZoneSidKey = 'America/Los_Angeles', UserName = 'test_userprod123456@indusbank.com', MobilePhone = '9089078967');
        insert newUserRecord;

        Group cmuQueue = [SELECT Id
                          FROM Group
                          WHERE Type = 'Queue' AND NAME = 'CMU'];

        GroupMember groupMemberRecord = new GroupMember(GroupId = cmuQueue.Id, UserOrGroupId = userRecord.Id);
        insert groupMemberRecord;

        System.runAs(userRecord){
            TriggerSwitch__c trgSwitch = new TriggerSwitch__c();
            trgSwitch.Name = 'Trigger_For_Case';
            trgSwitch.Active__c = true;
            insert trgSwitch;

            Account testAccount = new Account(Name = 'Test Account');
            insert testAccount;

            List<Opportunity> opp = new List<Opportunity>();
            for (Integer i = 0; i < 2; i++){
                opp.add(new Opportunity(Name = 'Opportunity' + i, StageName = 'Loan Initiation', CloseDate = System.today().addMonths(1), AccountId = testAccount.Id));
            }
            insert opp;

            List<Case> caseList = new List<Case>();

            Case newCase = new Case(CMU_Accept__c = false, Loan_Application__c = opp[1].id, Status = 'new', Subject = 'Valid CMU Request Case', Type = 'CMU Request', OwnerId = UserInfo.getUserId());
            caseList.add(newCase);

            Case newCase2 = new Case(CMU_Accept__c = false, Loan_Application__c = opp[1].id, Status = 'new', Subject = 'Invalid CMU Request Case', Type = 'Office FI', OwnerId = UserInfo.getUserId(), RecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByName().get('FI').getRecordTypeId());
            caseList.add(newCase2);

            insert caseList;
        }
    }

    @isTest
    public static void getCMUQueueIdTest(){
        Test.startTest();
        User userRecord = [SELECT Id, usertype
                           FROM User
                           WHERE UserName = 'test_userprod12345@indusbank.com' AND IsActive = true
                           LIMIT 1];
        System.runAs(userRecord){
            Id cmuQueueId = IND_LWC_ChangeCaseOwner.getCMUQueueId();
            System.assert(String.isNotBlank(cmuQueueId), 'CMU queue not found in the system');
        }
        Test.stopTest();
    }

    @isTest
    public static void getUsersFromQueueTest(){
        Test.startTest();
        User userRecord = [SELECT Id, usertype, Name
                           FROM User
                           WHERE UserName = 'test_userprod12345@indusbank.com' AND IsActive = true
                           LIMIT 1];
        System.runAs(userRecord){
            Id cmuQueueId = IND_LWC_ChangeCaseOwner.getCMUQueueId();
            List<sObject> cmuUsersList = IND_LWC_ChangeCaseOwner.getUsersFromQueue(cmuQueueId, 'Name', 'Tes');

            System.assert(cmuUsersList.size() > 0, 'Users assigned to CMU queue not found');
        }
        Test.stopTest();
    }

    @isTest
    public static void getUsersFromQueueNegativeTest(){
        try{
            Test.startTest();

            User userRecord = [SELECT Id, usertype, Name
                               FROM User
                               WHERE UserName = 'test_userprod12345@indusbank.com' AND IsActive = true
                               LIMIT 1];
            System.runAs(userRecord){
                Id cmuQueueId = IND_LWC_ChangeCaseOwner.getCMUQueueId();
                List<sObject> cmuUsersList = IND_LWC_ChangeCaseOwner.getUsersFromQueue(cmuQueueId, 'test', 'Tes'); //Passing invalid searchField
            }

            Test.stopTest();
            throw new MyException('GetUsersFromQueue method should have failed'); 

        } catch (Exception e){
            System.assert(e.getMessage().contains('Script-thrown exception'), 'Test method should have thrown Script-thrown exception');
        }
    }

    @isTest
    public static void validateCaseRecordTypeTest(){
        Test.startTest();
        User userRecord = [SELECT Id, usertype, Name
                           FROM User
                           WHERE UserName = 'test_userprod12345@indusbank.com' AND IsActive = true
                           LIMIT 1];
        System.runAs(userRecord){
            List<Id> selectedCaseIdList = new List<Id>{ [SELECT Id
                                                         FROM Case
                                                         WHERE RecordType.DeveloperName = 'CMU_Request'
                                                         LIMIT 1].Id };
            Boolean isValid = IND_LWC_ChangeCaseOwner.validateCaseRecordType(selectedCaseIdList);

            System.assert(selectedCaseIdList.size() > 0, 'No case of CMU Request recordtype found');
            System.assert(isValid, 'selected case is not a valid case');
        }
        Test.stopTest();
    }

    @isTest
    public static void validateCaseRecordTypeNegativeTest(){
        Test.startTest();
        User userRecord = [SELECT Id, usertype, Name
                           FROM User
                           WHERE UserName = 'test_userprod12345@indusbank.com' AND IsActive = true
                           LIMIT 1];
        System.runAs(userRecord){
            List<Id> selectedCaseIdList = new List<Id>{ [SELECT Id
                                                         FROM Case
                                                         WHERE RecordType.DeveloperName != 'CMU_Request'
                                                         LIMIT 1].Id };
            Boolean isValid = IND_LWC_ChangeCaseOwner.validateCaseRecordType(selectedCaseIdList);

            System.assert(selectedCaseIdList.size() > 0, 'No case with invalid recordtype found');
            System.assert(!isValid, 'selected case is a valid case');
        }
        Test.stopTest();
    }

    @isTest
    public static void changeCaseOwnerTest(){
        Test.startTest();
        User newUserRecord = [SELECT Id, usertype, Name
                              FROM User
                              WHERE UserName = 'test_userprod123456@indusbank.com' AND IsActive = true
                              LIMIT 1];
        List<Id> selectedCaseIdList = new List<Id>{ [SELECT Id
                                                     FROM Case
                                                     WHERE RecordType.DeveloperName = 'CMU_Request'
                                                     LIMIT 1].Id };

        String result = IND_LWC_ChangeCaseOwner.changeCaseOwner(selectedCaseIdList, newUserRecord.Id);

        System.assertEquals('Success', result, 'Change case owner failed.');
        Test.stopTest();
    }

    @isTest
    public static void changeCaseOwnerNegativeTest(){
        try{
            Test.startTest();
            User newUserRecord = [SELECT Id, usertype, Name
                                  FROM User
                                  WHERE UserName = 'test_userprod123456@indusbank.com' AND IsActive = true
                                  LIMIT 1];
            List<Id> selectedCaseIdList = new List<Id>{ [SELECT Id
                                                         FROM Case
                                                         WHERE RecordType.DeveloperName = 'CMU_Request'
                                                         LIMIT 1].Id };

            String result = IND_LWC_ChangeCaseOwner.changeCaseOwner(selectedCaseIdList, selectedCaseIdList[0]); //Passing Invalid Id
            Test.stopTest();

            throw new MyException('ChangeCaseOwner method should have failed'); 
        } catch (Exception e){
            System.assert(e.getMessage().contains('Script-thrown exception'), 'Test method should have thrown Script-thrown exception');
        }
    }

    public class MyException extends Exception{ 
    }

}