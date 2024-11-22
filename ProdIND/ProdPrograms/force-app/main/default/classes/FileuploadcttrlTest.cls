@isTest
public class FileuploadcttrlTest {
    @isTest
    public static void fetchFilesTest(){
        try{
            Opportunity opks1 = new Opportunity();
                opks1.StageName = 'Qualification';
                opks1.CloseDate = Date.newInstance(2021, 1, 11);
                opks1.Name = 'testone';
                insert opks1;
                
                Applicant__c apks1 = new Applicant__c();
                apks1.Opportunity__c = opks1.Id;
                apks1.Contact_number__c = '9743514830';
                apks1.Applicant_Type__c = 'Borrower';
                apks1.In_Active_Applicant__c = false;
                apks1.DocAuth_Application_Id__c = 'testauth';
                apks1.Selfie_Upload__c = true;
                insert apks1;
                
                 Documents__c dfks1 = new Documents__c();
                 dfks1.Applicant__c = apks1.Id;
                 dfks1.Opportunity_Relation__c = opks1.Id;
                 dfks1.Document_Type__c = System.Label.CustomerImageDocumentType;
                 dfks1.KYC_name__c = 'Aadhar';
                 dfks1.Document_Side__c ='Back';
                 dfks1.Aadhar_Source__c = 'ScanAadhar';
                 dfks1.Name = 'Aadhar';
                 insert dfks1;
                
                Blob beforeblob1 = Blob.valueOf('Unit Test Attachment Body');

                 ContentVersion cvt1 = new ContentVersion();
                 cvt1.title = 'test content trigger';      
                 cvt1.PathOnClient ='test';           
                 cvt1.VersionData = beforeblob1;
                 cvt1.Document_Side_fileupload__c = 'Selfie';
                 insert cvt1;   
        
                 ContentVersion testContent1 = [SELECT id, ContentDocumentId FROM ContentVersion where Id = :cvt1.Id];

        
                 ContentDocumentLink contentlink1 = new ContentDocumentLink();
                 contentlink1.ShareType = 'V';
                 contentlink1.LinkedEntityId = dfks1.Id; 
                 contentlink1.ContentDocumentId = testContent1.ContentDocumentId;
                 contentlink1.Visibility = 'AllUsers'; 
                 insert contentlink1;
            
                 Test.startTest();
                       Fileuploadcttrl.fetchFiles(contentlink1.LinkedEntityId);
                       Fileuploadcttrl.fetchFiles(null);
                 Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void deleteFileTest(){
        try{
            Opportunity opks1 = new Opportunity();
                opks1.StageName = 'Qualification';
                opks1.CloseDate = Date.newInstance(2021, 1, 11);
                opks1.Name = 'testone';
                insert opks1;
                
                Applicant__c apks1 = new Applicant__c();
                apks1.Opportunity__c = opks1.Id;
                apks1.Contact_number__c = '9743514830';
                apks1.Applicant_Type__c = 'Borrower';
                apks1.In_Active_Applicant__c = false;
                apks1.DocAuth_Application_Id__c = 'testauth';
                apks1.Selfie_Upload__c = true;
                insert apks1;
                
                 Documents__c dfks1 = new Documents__c();
                 dfks1.Applicant__c = apks1.Id;
                 dfks1.Opportunity_Relation__c = opks1.Id;
                 dfks1.Document_Type__c = System.Label.CustomerImageDocumentType;
                 dfks1.KYC_name__c = 'Aadhar';
                 dfks1.Document_Side__c ='Back';
                 dfks1.Aadhar_Source__c = 'ScanAadhar';
                 dfks1.Name = 'Aadhar';
                 insert dfks1;
                
                Blob beforeblob1 = Blob.valueOf('Unit Test Attachment Body');

                 ContentVersion cvt1 = new ContentVersion();
                 cvt1.title = 'test content trigger';      
                 cvt1.PathOnClient ='test';           
                 cvt1.VersionData = beforeblob1;
                 cvt1.Document_Side_fileupload__c = 'Selfie';
                 insert cvt1;   
        
                 ContentVersion testContent1 = [SELECT id, ContentDocumentId FROM ContentVersion where Id = :cvt1.Id];

        
                 ContentDocumentLink contentlink1 = new ContentDocumentLink();
                 contentlink1.ShareType = 'V';
                 contentlink1.LinkedEntityId = dfks1.Id; 
                 contentlink1.ContentDocumentId = testContent1.ContentDocumentId;
                 contentlink1.Visibility = 'AllUsers'; 
                 insert contentlink1;
            
                 Test.startTest();
                        Fileuploadcttrl.deleteFile(contentlink1.ContentDocumentId);
                        Fileuploadcttrl.deleteFile(null);
                 Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
}