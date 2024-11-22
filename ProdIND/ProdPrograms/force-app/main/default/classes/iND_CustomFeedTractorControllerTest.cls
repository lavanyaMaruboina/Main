@isTest
public class iND_CustomFeedTractorControllerTest {
    
 @testSetup
    static void setupTestData() {
        Account acc = TestDataUtility.createTestAccount(false);
        insert acc;
        
        Opportunity opp = TestDataUtility.createTestOpportunity1(false);
        opp.AccountId = acc.Id;
        insert opp;
        
        Applicant__c app = TestDataUtility.createTestApplicatnt1(false);
        app.Opportunity__c =opp.Id;
        insert app;
        
        Documents__c testDocument = TestDataUtility.createTestDocument(false);
        testDocument.Opportunity_Relation__c =opp.Id;
        testDocument.Applicant__c =app.Id;
        insert testDocument;
        
        Case cs = TestDataUtility.createTestCase(false,opp,app);
        cs.Case_Document__c = testDocument.Id;
        insert cs;

    }

    @isTest
    static void testGetOrgBaseUrl() {
        Test.StartTest();
        String baseUrl = iND_CustomFeedTractorController.getOrgBaseUrl();
        System.assertNotEquals(null, baseUrl);
        Test.StopTest();
    }

    @isTest
    static void testGetAccountId() {
        Documents__c testDocument = [SELECT Id FROM Documents__c LIMIT 1];
        Test.StartTest();
        String accountId = iND_CustomFeedTractorController.getAccountId(testDocument.Id);
        System.assertNotEquals(null, accountId);
        Test.StopTest();
    }

    @isTest
    static void testGetAllCasesRelatedToAccount() {
        Documents__c testDocument = [SELECT Id FROM Documents__c LIMIT 1];
        Test.StartTest();
        List<Case> result = iND_CustomFeedTractorController.getAllCasesRelatedToAccount(testDocument.Id);
        System.assertEquals(1, result.size());
        Test.StopTest();
    }
    @isTest
    static void testGetAllCasesRelatedToAccountForNull() {
        Documents__c testDocument = [SELECT Id FROM Documents__c LIMIT 1];
        Test.StartTest();
        List<Case> result = iND_CustomFeedTractorController.getAllCasesRelatedToAccount(null);
        System.assertEquals(null, result);
        Test.StopTest();
    }

    @isTest
    static void testCreateQueryCaseRecords() {
        Documents__c testDocument = [SELECT Id FROM Documents__c LIMIT 1];
        Case cs =[SELECT Id FROM Case LIMIT 1];

        Id userId = UserInfo.getUserId();
        String body = 'Test case body';

        Test.startTest();
        Case createdCase = iND_CustomFeedTractorController.createQueryCaseRecords(userId, testDocument.Id, body);
        Test.stopTest();

    }
    @isTest
    static void testCreateQueryCaseRecords1() {
        Documents__c testDocument = [SELECT Id FROM Documents__c LIMIT 1];
        //Case cs =[SELECT Id FROM Case LIMIT 1];
       // Id userId = [select id from user where name = 'RCU Manager Test'].Id;
        
        Profile p = [SELECT Id FROM Profile WHERE Name='IBL TF RCU Manager'];
        User u = new User(Alias = 'standt2', Email='standarduser2@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,Maker_Id__c='12',IsActive = true,
                          TimeZoneSidKey='America/Los_Angeles',UserName='test_userprod1231212!@indusbank.com.uat.test',
                          MobilePhone='8234567890');
        User u2 = new User(Alias = '2standt2', Email='2standarduser2@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,Maker_Id__c='12',IsActive = true,
                          TimeZoneSidKey='America/Los_Angeles',UserName='2test_userprod1231212!@indusbank.com.uat.test',
                          MobilePhone='2382345678');
        insert u;
        insert u2;
        
        System.runAs(u){
            
            String body = 'Test case body';
            //Id userId = UserInfo.getUserId();
            
            Test.startTest();        
            Case createdCase = iND_CustomFeedTractorController.createQueryCaseRecords(u2.Id,testDocument.Id , body);
            Test.stopTest();
            
        }
    }
    
    @isTest
    static void testGetAllPreviousChat() {
        Case cs =[SELECT Id FROM Case LIMIT 1];
        Test.StartTest();
        iND_CustomFeedTractorController.WrapperData wrapData = iND_CustomFeedTractorController.getAllPreviousChat(cs.Id);
        System.assertNotEquals(null, wrapData);
        Test.StopTest();
    }

    @isTest
    static void testUpdateCase() {
        Case cs =[SELECT Id,CreatedById FROM Case LIMIT 1];
        Test.StartTest();
        String result = iND_CustomFeedTractorController.updateCase(cs.Id, cs.CreatedById);
        System.assertEquals('Case Updated Successfully', result);
        Test.StopTest();
    }
}