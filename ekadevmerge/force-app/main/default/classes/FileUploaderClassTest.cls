@isTest
public class FileUploaderClassTest {
    @isTest
    static void testUploadFile() {
        String filename = 'check in and out.png';
        String fileBody = 'VGhpcyBpcyBhIHRlc3QgZmlsZSBib2R5';
        String recordId = 'a041e000004fNd4AAE';
        String filename1 = 'check in and out.png';
        String fileBody1 = 'VGhpcyBpcyIHRlc3QgZmlsZSBib2R5';
        Test.startTest();
        String result = FileUploaderClass.uploadFile(filename, fileBody, recordId, filename1, fileBody1);
        Test.stopTest();
        //System.assertNotEquals(null, result, 'Upload should be successful');
    }

     @isTest
    static void testInsertRegistrationId() {
        // Test data
        Lead testLead = new Lead();
        testLead.FirstName = 'Test';
        testLead.LastName = 'Lead';
        testLead.Company = 'Test Company';
        insert testLead;

        Request_For_ID__c request = new Request_For_ID__c();
        String filename = 'check in and out.png';
        String fileBody = 'VGhpcyBpcyBhIHRlc3QgZmlsZSBib2R5';
        String filename1 = 'Day Plan activity.png';
        String fileBody1 = 'VGhpcyBpcyBhIHRlc3QgZmlsZSBib2R5';

        Test.startTest();
        String leadId = testLead.Id;
        String leadRecordName = 'Inside Sales';
        String Opporid = '0061e00000DgfNpAAJ';
        String oppRecodName = 'Inside Sales';

        String result = FileUploaderClass.Insertregistarionid(request, filename, filebody, filename1, filebody1, leadId, leadRecordName, Opporid, oppRecodName);
        Test.stopTest();

        System.assertNotEquals(null, result, 'Insertion should be successful');

        // Now verify that the fields are updated in the 'request' object
        Request_For_ID__c updatedRequest = [SELECT Lead__c, Record_Name__c, Opportunity_Name__c, Opportunity_Record_Name__c FROM Request_For_ID__c WHERE Id = :request.Id LIMIT 1];
        //System.assertEquals(leadId, updatedRequest.Lead__c, 'Lead__c field should be updated');
        //System.assertEquals(leadRecordName, updatedRequest.Record_Name__c, 'Record_Name__c field should be updated');
        //System.assertEquals(Opporid, updatedRequest.Opportunity_Name__c, 'Opportunity_Name__c field should be updated');
        //System.assertEquals(oppRecodName, updatedRequest.Opportunity_Record_Name__c, 'Opportunity_Record_Name__c field should be updated');
    }
  @isTest
    static void testMethodName1() {
        Lead testLead = new Lead();
        testLead.FirstName = 'Test';
        testLead.LastName = 'Lead';
        testLead.Company = 'Test Company';
        insert testLead;
        Test.startTest();
        lead resultLead = FileUploaderClass.methodName1(testLead.Id);
        Test.stopTest();
        System.assertNotEquals(null, resultLead, 'Lead should be retrieved successfully');
    }
    
    @isTest
    static void testMethodName2() {
        Opportunity testOpp = new Opportunity();
        testOpp.Name = 'Test Opportunity';      
        testOpp.StageName = 'Busy/Follow-Up';
        testOpp.CloseDate = Date.newInstance(2023, 6, 9);
        insert testOpp;
        Test.startTest();
        Opportunity resultOpp = FileUploaderClass.methodName2(testOpp.Id);
        Test.stopTest();

        System.assertNotEquals(null, resultOpp, 'Opportunity should be retrieved successfully');
    }
     @isTest
    static void testGetEmail() {
        Request_For_ID__c testRequest = new Request_For_ID__c();
        testRequest.Email_ID__c = 'lavanya@gmail.com';
        insert testRequest;
        Test.startTest();
        String resultEmail = FileUploaderClass.getEmail(testRequest.Id);
        Test.stopTest();

        System.assertNotEquals(null, resultEmail, 'Email should be retrieved successfully');
    }

    @isTest
    static void testIsEmailUnique() {
        Request_For_ID__c testRequest1 = new Request_For_ID__c();
        testRequest1.Email_ID__c = 'lavanya@gmail.com';
        insert testRequest1;

        Test.startTest();
        Boolean isUnique = FileUploaderClass.isEmailUnique('newemail@gmail.com', testRequest1.Id);
        Test.stopTest();

        System.assertEquals(true, isUnique, 'Email should be unique');
    }

    @isTest
    static void testIsEmailUniqueAnother() {
        Request_For_ID__c testRequest2 = new Request_For_ID__c();
        testRequest2.Email_ID__c = 'lavanya@gmail.com';
        insert testRequest2;

        Test.startTest();
        Boolean isUnique = FileUploaderClass.isEmailUnique('newemail@gmail.com', testRequest2.Id);
        Test.stopTest();

        System.assertEquals(true, isUnique, 'Email should be unique');
    }
}