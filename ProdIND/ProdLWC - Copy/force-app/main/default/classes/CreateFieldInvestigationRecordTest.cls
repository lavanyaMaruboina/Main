@isTest
public class CreateFieldInvestigationRecordTest{
    @isTest
    public static void uploadDocumentsTest(){
        
        Opportunity opks1 = new Opportunity();
        opks1.StageName = 'Qualification';
        opks1.CloseDate = Date.newInstance(2021, 1, 11);
        opks1.Name = 'testone';
        insert opks1;
        
        Applicant__c apks1 = new Applicant__c();
        apks1.Opportunity__c = opks1.Id;
        apks1.Contact_number__c = '9743514830';
        apks1.Applicant_Type__c = 'Borrower';
        insert apks1;
        
        Documents__c dfks1 = new Documents__c();
        dfks1.Applicant__c = apks1.Id;
        dfks1.Opportunity_Relation__c = opks1.Id;
        dfks1.KYC_name__c = 'Aadhar';
        dfks1.Document_Side__c ='Back';
        dfks1.Aadhar_Source__c = 'ScanAadhar';
        dfks1.Name = 'Aadhar';
        dfks1.Proof_of_Identity_POI__c = true;
        insert dfks1;
        
        ContentVersion cV1 = new ContentVersion();
        cV1.ContentLocation = 'S'; 
        cV1.PathOnClient = 'Test';
        cV1.Origin = 'H';
        cV1.OwnerId = UserInfo.getUserId();
        cV1.Title = 'Test';
        cV1.VersionData = Blob.valueOf('Test Content');
        Insert cV1;
        
        Map<String,String> patDoc = new Map<String,String>();
        patDoc.put('base64',cV1.Id);
        patDoc.put('filename','patDoc');
        
        
        Map<String,String> landPhto = new Map<String,String>();
        landPhto.put('base64',cV1.Id);
        landPhto.put('filename','landPhto');
        
        Map<String,String> rentAgrData = new Map<String,String>();
        rentAgrData.put('base64',cV1.Id);
        rentAgrData.put('filename','rentAgrData');
        
        Map<String,String> pensionDoc = new Map<String,String>();
        pensionDoc.put('base64',cV1.Id);
        pensionDoc.put('filename','pensionDoc');
        
        ContentVersion testcd1 = [SELECT id, ContentDocumentId FROM ContentVersion where Id = :cV1.Id];
        
        ContentDocumentLink cdlink1 = new ContentDocumentLink();
        cdlink1.Visibility = 'AllUsers';
        cdlink1.ShareType = 'V';
        cdlink1.LinkedEntityId = dfks1.Id;
        cdlink1.ContentDocumentId = testcd1.ContentDocumentId;
        insert cdlink1;   
        
        Test.startTest();
        Boolean result = CreateFieldInvestigationRecord.uploadDocuments(patDoc,landPhto,rentAgrData,pensionDoc,opks1.Id);
        System.assert(result);
        Test.stopTest();
        
    }
    
    @isTest
    public static void createContentVersionTest(){
        
        ContentVersion cVersion = new ContentVersion();
        cVersion.ContentLocation = 'S'; 
        cVersion.PathOnClient = 'Test';
        cVersion.Origin = 'H';
        cVersion.OwnerId = UserInfo.getUserId();
        cVersion.Title = 'Test';
        cVersion.VersionData = Blob.valueOf('Test Content');
        Insert cVersion;
        
        Test.startTest();
        ContentVersion objCV = CreateFieldInvestigationRecord.createContentVersion('base','Aadhar');
        System.assert(objCV != null);
        objCV = CreateFieldInvestigationRecord.createContentVersion('',null);
        System.assert(objCV != null);
        Test.stopTest();
    }
    
    @isTest
    public static void createContentLinkTest(){
        
        Opportunity opks1 = new Opportunity();
        opks1.StageName = 'Qualification';
        opks1.CloseDate = Date.newInstance(2021, 1, 11);
        opks1.Name = 'testone';
        insert opks1;
        
        Applicant__c apks1 = new Applicant__c();
        apks1.Opportunity__c = opks1.Id;
        apks1.Contact_number__c = '9743514830';
        apks1.Applicant_Type__c = 'Borrower';
        insert apks1;
        
        Documents__c dfks1 = new Documents__c();
        dfks1.Applicant__c = apks1.Id;
        dfks1.Opportunity_Relation__c = opks1.Id;
        dfks1.KYC_name__c = 'Aadhar';
        dfks1.Document_Side__c ='Back';
        dfks1.Aadhar_Source__c = 'ScanAadhar';
        dfks1.Name = 'Aadhar';
        dfks1.Proof_of_Identity_POI__c = true;
        insert dfks1;
        
        ContentVersion cvn1 = new ContentVersion();
        cvn1.PathOnClient = 'testpath1';
        cvn1.Title = 'testtitle1';
        cvn1.VersionData = Blob.valueOf('Test Content');
        cvn1.Document_Side_fileupload__c = 'Front';
        insert cvn1;
        
        ContentVersion testcd1 = [SELECT id, ContentDocumentId FROM ContentVersion where Id = :cvn1.Id];
        
        ContentDocumentLink cdlink1 = new ContentDocumentLink();
        cdlink1.Visibility = 'AllUsers';
        cdlink1.ShareType = 'V';
        cdlink1.LinkedEntityId = dfks1.Id;
        cdlink1.ContentDocumentId = testcd1.ContentDocumentId;
        insert cdlink1;
        
        Test.startTest();
        ContentDocumentLink objLink = CreateFieldInvestigationRecord.createContentLink(cvn1.Id,opks1.Id);
        System.assert(objLink != null);
        objLink = CreateFieldInvestigationRecord.createContentLink(null,null);
        System.assert(objLink == null);
        Test.stopTest();
    }
    
    
   
    
}