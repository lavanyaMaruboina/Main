@isTest
public class GetFilesControllerTest {
    
    @testSetup 
    static void testDataSetup() {
        //create user
        Profile p = [SELECT Id FROM Profile WHERE Name='IBL Business Executive'];
        UserRole ur = new UserRole(Name = 'CEO');
        insert ur;
        User u = new User(Alias = 'standt2', Email='standarduser2@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id, UserRoleId = ur.Id, Maker_Id__c='12',IsActive = true,
                          TimeZoneSidKey='America/Los_Angeles',UserName='test1_userprod123@indusbank.com',MobilePhone = '9089078967');
        insert u;
        
        Profile p1 = [SELECT Id FROM Profile WHERE Name='Platform Event Profile'];
        User u1 = new User(Alias = 'standt2', Email='standarduser2@testorg.com',
                           EmailEncodingKey='UTF-8', LastName='platformUser', LanguageLocaleKey='en_US',
                           LocaleSidKey='en_US', ProfileId = p1.Id,Maker_Id__c='12',IsActive = true,
                           TimeZoneSidKey='America/Los_Angeles',UserName='platformUser@indusbank.com',MobilePhone = '9089078967');
        insert u1;
        System.runAs(u) 
        {
            // Create Opportunity
            Opportunity oppUsed = TestDataUtility.createTestOpportunityForOcr(false);
            oppUsed.Sub_Stage__c = System.Label.Field_Investigation;
            oppUsed.Is_Mobile_Journey_Completed__c = true;
            oppUsed.Vehicle_Type__c = System.Label.used;
            oppUsed.Product_Type__c = System.Label.TwoWheeler;
            oppUsed.Sanction_Status__c = System.Label.nonStp;
            insert oppUsed; 
            
            Opportunity opp = TestDataUtility.createTestOpportunityForOcr(false);
            opp.Name = 'VDR Test';
            opp.StageName='Post Sanction Checks and Documentation';
            opp.Product_Type__c='Tractor';
            opp.CVO_Accepts_SPDC_Documents__c = 'No';
            insert opp;    
            
            // Create Applicant__c
            Applicant__c applicant = TestDataUtility.createTestApplicantForMFCValuation(false, opp);
            applicant.Willing_to_open_Bank_Account_with_IIB__c = true;
            applicant.Applicant_Type__c = 'Borrower';
            applicant.Customer_Qualification__c = 'B1';
            applicant.Marital_status__c = 'MARR';
            insert applicant;
            
            Applicant__c applicant1 = TestDataUtility.createTestApplicantForMFCValuation(false, opp);
            applicant1.Willing_to_open_Bank_Account_with_IIB__c = true;
            applicant1.Applicant_Type__c = System.Label.CoBorrower;
            applicant1.Customer_Qualification__c = 'B1';
            applicant1.Marital_status__c = 'MARR';
            insert applicant1;
            
            Documents__c docRec = TestDataUtility.createTestKYCDocForBre(true, applicant, opp);
            ContentVersion contentVersion = TestDataUtility.createContentVersionforOcrFront('test',true,docRec);
        }
        
        System.runAs(u1) 
        {
            Opportunity oppUsed = TestDataUtility.createTestOpportunityForOcr(false);
            oppUsed.Sub_Stage__c = System.Label.Field_Investigation;
            oppUsed.Is_Mobile_Journey_Completed__c = true;
            oppUsed.Vehicle_Type__c = System.Label.used;
            oppUsed.Product_Type__c = System.Label.TwoWheeler;
            oppUsed.Sanction_Status__c = System.Label.nonStp;
            insert oppUsed;               
        }
    }
    
    @isTest
    public static void getUserRoleTest(){
        try{
            
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE UserName='test1_userprod123@indusbank.com' AND IsActive = true LIMIT 1];
            System.runAs(u) 
            {
                String result = GetFilesController.getUserRole(u.Id);
                System.assertEquals('CEO', result);
                
                String result1 = GetFilesController.getUserRole(null);
                System.assertEquals(null, result1);
            }
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void getFilesListTest(){
        try{
            
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE UserName='test1_userprod123@indusbank.com' AND IsActive = true LIMIT 1];
            Opportunity oppRec1 = [SELECT Id, Vehicle_Type__c, Product_Type__c FROM Opportunity WHERE Name='VDR Test' LIMIT 1];
            Applicant__c appRec = [SELECT Id, Opportunity__c FROM Applicant__c WHERE Applicant_Type__c = 'Borrower' LIMIT 1];
            Documents__c docRec = [SELECT Id, Opportunity_Relation__c,Applicant__c,Document_Type__c FROM Documents__c  LIMIT 1];
            
            System.runAs(u) 
            {
                GetFilesController.FilesWrapper[] filesList = GetFilesController.getFilesList(docRec.Id);
                System.assertEquals('KYC Document', filesList[0].recordTypeName);
                
                GetFilesController.FilesWrapper[] filesList1 = GetFilesController.getFilesList(null);
                System.assertEquals(null, filesList1);
                
                GetFilesController.FileVersionWrapper fileVersion = new GetFilesController.FileVersionWrapper('test','test','test',Date.today(),'test');
            }
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void isKYCDocumentTest(){
        try{
            
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE UserName='test1_userprod123@indusbank.com' AND IsActive = true LIMIT 1];
            Opportunity oppRec1 = [SELECT Id, Vehicle_Type__c, Product_Type__c FROM Opportunity WHERE Name='VDR Test' LIMIT 1];
            Applicant__c appRec = [SELECT Id, Opportunity__c FROM Applicant__c WHERE Applicant_Type__c = 'Borrower' LIMIT 1];
            Documents__c docRec = [SELECT Id, Opportunity_Relation__c,Applicant__c,Document_Type__c FROM Documents__c  LIMIT 1];
            ContentVersion contentVersion = TestDataUtility.createContentVersionforOcrFront('test',true,docRec);
            ContentVersion testContent = [SELECT id, ContentDocumentId FROM ContentVersion limit 1];
            
            ContentDocumentLink contentlink=new ContentDocumentLink();
            contentlink.LinkedEntityId=oppRec1.id;
            contentlink.ContentDocumentId=testcontent.ContentDocumentId;
            contentlink.Visibility = 'AllUsers'; 
            insert contentlink;
            
            System.runAs(u) 
            {
                GetFilesController.isKYCDocument(docRec.Id);
                GetFilesController.deleteFile(testcontent.ContentDocumentId,contentlink.Id);
                GetFilesController.deleteFile(docRec.Id,docRec.Id);
            }
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void isResiDocumentTest(){
        User u = [SELECT Id,usertype FROM User WHERE UserName='test1_userprod123@indusbank.com' AND IsActive = true LIMIT 1];
    
        system.runAs(u)
        {
            String resiRecordTypeId = Schema.sObjectType.Documents__c.getRecordTypeInfosByName().get('Resi Profile Documents').getRecordTypeId();
            Opportunity oppRec1 = [SELECT Id, Vehicle_Type__c, Product_Type__c FROM Opportunity WHERE Name='VDR Test' LIMIT 1];
            Documents__c docRec = [SELECT Id, Opportunity_Relation__c,Applicant__c,Document_Type__c FROM Documents__c  LIMIT 1];
            docRec.RecordTypeId = resiRecordTypeId;
            docRec.Document_Type__c = 'Resi Profile Document';
            update docRec;
            
            Test.startTest();
            GetFilesController.isResiDocument(docRec.Id);
            Test.StopTest();
        
        }
          
    }
    
}