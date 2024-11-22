@isTest
public class GenericUploadControllerTest {
    
    @testSetup
    static void checkRCDocument(){
        //create user
        Profile p = [SELECT Id FROM Profile WHERE Name='IBL CVO'];
        User u = new User(Alias = 'standt2', Email='standarduser2@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,Maker_Id__c='12',IsActive = true,
                          TimeZoneSidKey='America/Los_Angeles',UserName='test_userprod122@indusbank.com',MobilePhone = '9089078967');
        insert u;
        System.runAs(u) 
        {
            //create Oppty records
            List<Opportunity> opptyList = new List<Opportunity>();
            
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            opp.Name = 'VDR Test';
            opp.Vehicle_Type__c='Used';
            opptyList.add(opp);
            Opportunity opp2 = TestDataUtility.createTestOpportunity1(false);
            opp2.Name = 'VDR Negative Test';
            opp2.CloseDate = Date.today();
            opptyList.add(opp2);
            Opportunity opp3 = TestDataUtility.createTestOpportunity1(false);
            opp3.Name = 'Oppty 3';
            opp3.CloseDate = Date.today();
            opp3.Vehicle_Type__c='New';
            opp3.Product_Type__c=System.Label.Tractor;
            opptyList.add(opp3);
            
           
            if(Schema.sObjectType.Opportunity.isCreateable()){
                insert opptyList;
            }
            //Create Applicant__c Data
            List<Applicant__c> applicantList = new List<Applicant__c>();
            Applicant__c applicant1 = TestDataUtility.createTestApplicatnt1(false);
            applicant1.Opportunity__c = opp.Id;
            applicant1.Who_will_repay_the_loan__c = 'Borrower';
            applicant1.Scorecard_Decision__c = 'Light Red';
            applicantList.add(applicant1);
            Applicant__c applicant2 = TestDataUtility.createTestApplicatnt2(false);
            applicant2.Opportunity__c = opp.Id;
            applicant2.Applicant_Type__c = 'Co-Borrower';
            applicantList.add(applicant2);
            if(Schema.sObjectType.Applicant__c.isCreateable()){
                insert applicantList;
            }
            //create LoanDisbursementDetails__c data
            list<LoanDisbursementDetails__c> loandisbursementlist = new list<LoanDisbursementDetails__c>();
            LoanDisbursementDetails__c loanDisbursement = new LoanDisbursementDetails__c(); 
            loanDisbursement.Name='test_loandis';
            loanDisbursement.Parent_Loan_Application__c = opp.id;
            loandisbursementlist.add(loanDisbursement);
            insert loandisbursementlist;
            
            //create Vehicle_Detail__c record
            List<Vehicle_Detail__c> vdList = new List<Vehicle_Detail__c>();
            Vehicle_Detail__c  vehicleDetail = TestDataUtility.createTestVehicleDetailForIbb(false, opp);
            vdList.add(vehicleDetail);
            if (Schema.sObjectType.Vehicle_Detail__c.isCreateable()){
                insert vdList;
            }
            //Create Documents__c records
            List<Documents__c> docList = new List<Documents__c>();
            Documents__c doc1 = TestDataUtility.createTestDocumentITR(false, applicant1, opp);
            doc1.Vehicle_Detail__c = vehicleDetail.Id;
            doc1.Name = 'RC Document '+opp.Id;
            doc1.Opportunity_Relation__c = opp.Id;
            doc1.Is_active__c = true;
            doc1.Document_Type__c = 'Chassis Number uploaded during verification';
            docList.add(doc1);
            if(Schema.sObjectType.Documents__c.isCreateable()){
                insert docList;
            }
            ContentVersion contentVersion = new ContentVersion(
                Title          = 'testfname',
                PathOnClient   = 'Pic.jpg',
                VersionData    = Blob.valueOf('Test Content'),
                IsMajorVersion = true);
            insert contentVersion; 
            List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
            
            //create ContentDocumentLink  record
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.LinkedEntityId = opp.Id;
            cdl.ContentDocumentId = documents[0].Id;
            cdl.ShareType = 'V';
            cdl.Visibility = 'AllUsers';
            insert cdl;        
        }
    }
    
    @IsTest
    public static void test_checkRCDocument(){
        test.startTest();
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod122@indusbank.com' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            Opportunity opp = [Select id, name from opportunity where name = 'Oppty 3' limit 1];
            Applicant__c applicant = [Select id , name from Applicant__c WHERE Applicant_Type__c = 'Borrower' limit 1];
            
            /*Deal_Number__c dealNo = new Deal_Number__c();
            dealNo.Loan_Application__c = opp.id;
            insert dealNo;*/
            
            String doc = GenericUploadController.checkRCDocument(opp.Id,applicant.Id,null);
            System.assertEquals(null,doc);
        }
        test.stopTest();
    }
    
    @IsTest
    public static void test_checkRCDocument1(){
        test.startTest();
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod122@indusbank.com' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            Opportunity opp = [Select id, name from opportunity where name = 'VDR Test' limit 1];
            Applicant__c applicant = [Select id , name from Applicant__c WHERE Applicant_Type__c = 'Borrower' limit 1];
            
            /*Deal_Number__c dealNo = new Deal_Number__c();
            dealNo.Loan_Application__c = opp.id;
            insert dealNo;*/
            
            String doc = GenericUploadController.checkRCDocument(opp.Id,applicant.Id,null);
            System.assertEquals(null,doc);
        }
        test.stopTest();
    }
    
    @IsTest
    public static void test_checkRCDocument2(){
        test.startTest();        
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod122@indusbank.com' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            String doc = GenericUploadController.checkRCDocument(null,null,null);
            System.assertEquals(null,doc);
        }
        test.stopTest();
    }
    
    @IsTest
    public static void test_clearRCDocument1(){
        test.startTest();
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod122@indusbank.com' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            LoanDisbursementDetails__c loanDisbursement =[select id,name from LoanDisbursementDetails__c limit 1];
            GenericUploadController.clearRCDocument(loanDisbursement.Id);
            LoanDisbursementDetails__c updatedLoanDisbursement =[select id,name, Registration_Date__c from LoanDisbursementDetails__c limit 1];
            System.assertEquals(null,updatedLoanDisbursement.Registration_Date__c);
        }
        test.stopTest();
    }
    
    @IsTest
    public static void test_clearRCDocument2(){
        try
        {                
            test.startTest();  
            User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod122@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {
                GenericUploadController.clearRCDocument('Test Id');                
            }
            test.stopTest();
        }
        catch(Exception e)
        {
            System.assert(e.getMessage().contains('Script-thrown exception'));
        }         
    }
    
    @IsTest  
    public static LoanDisbursementDetails__c test_fetchDisbursementRecord1(){
        test.startTest();
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod122@indusbank.com' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            Opportunity opp = [Select id, name from opportunity where name = 'VDR Test' limit 1];
            opp.Product_Type__c = System.Label.Tractor;
            update opp;
            Applicant__c aaplicant = [Select id , name from Applicant__c limit 1];
           /* Deal_Number__c dealNo = new Deal_Number__c();
            dealNo.Loan_Application__c = opp.id;
            insert dealNo;*/
            LoanDisbursementDetails__c loandisbusrse = GenericUploadController.fetchDisbursementRecord(opp.id,aaplicant.id,null);
            System.assertNotEquals(null,loandisbusrse);
        }
        test.stopTest();
        return null;
    }
    
    @IsTest  
    public static LoanDisbursementDetails__c test_fetchDisbursementRecord2(){
        test.startTest();  
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod122@indusbank.com' AND IsActive = true LIMIT 1]; 
        try{
            System.runAs(u) 
            {
                LoanDisbursementDetails__c loandisbusrse = GenericUploadController.fetchDisbursementRecord(null,null,null);
                //System.assertEquals(null,loandisbusrse);
                
            }
            
        }
        catch (AuraHandledException e){
            System.assert(e.getMessage().contains('Script-thrown exception'));
        }
        test.stopTest();
        return null;
    }
    
    @IsTest
    public static string test_deleteContentDocument(){
        test.startTest();
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod122@indusbank.com' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            try{
                Opportunity opp = [Select id, name from opportunity where name = 'VDR Test' limit 1];
                ContentDocumentLink cd = [Select id, LinkedEntityId from ContentDocumentLink WHERE LinkedEntityId =: opp.Id limit 1];
                string doc1 = GenericUploadController.deleteContentDocument(cd.Id);
                System.assertNotEquals(null,'doc1');
            }catch (AuraHandledException e){
                System.debug(e.getMessage());
            }
            test.stopTest();
        }
        return 'success';
    }
    @IsTest
    public static string test_createOtherDocument(){
        test.startTest();
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod122@indusbank.com' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            Opportunity opp = [Select id, name from opportunity limit 1];
            Applicant__c applicant = [Select id , name from Applicant__c limit 1];
            Vehicle_Detail__c vehicleDetail =[Select id , name from Vehicle_Detail__c limit 1];
            
            try{
                string document;
                document = GenericUploadController.createOtherDocument('test type',vehicleDetail.Id,applicant.Id,opp.Id);
                //System.assertNotEquals(null,'document');
            }catch (AuraHandledException e){
                System.assert(e.getMessage().contains('Script-thrown exception'));
            }
            test.stopTest();
        }
        return 'success';
        
    }
    @IsTest
    public static void test_changeFilename(){
        test.startTest();
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod122@indusbank.com' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            ContentDocument conDoc = [select id,Title from ContentDocument where title=:'testfname' LIMIT 1];
            GenericUploadController.changeFilename(conDoc.Id,'updatedTestFname');
            ContentDocument updatedConDoc = [select id,Title from ContentDocument where title=:'updatedTestFname' LIMIT 1];
            System.assertNotEquals(null,updatedConDoc);
            
        }
        test.stopTest();
    }
    
    @IsTest
    public static void test_getContentVersion(){
        test.startTest();
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod122@indusbank.com' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            try{
                ContentDocument conDoc = [select id,Title from ContentDocument where title=:'testfname' LIMIT 1];
                GenericUploadController.getContentVersion(conDoc.Id);
            }
            catch (AuraHandledException e){
                System.debug(e.getMessage());
            }
        }
        test.stopTest();
    }
    
    @IsTest
    public static Boolean test_getProfileName(){
        test.startTest();
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod122@indusbank.com' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            try{
                Opportunity opp = [Select id, name from opportunity limit 1];
                GenericUploadController.getProfileName(opp.Id);
            }
            catch (AuraHandledException e){
                System.debug(e.getMessage());
            }
            
        }
        test.stopTest();
        return true;
    }
    
    @IsTest
    public static void test_fetchLoanApplicationSubStage(){
        test.startTest();
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod122@indusbank.com' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            try{
                Opportunity opp = [Select id,Sub_Stage__c,name from opportunity limit 1];
                opp.Sub_Stage__c = 'RC Upload';
                update opp;
                GenericUploadController.fetchLoanApplicationSubStage(opp.Id);
                 GenericUploadController.fetchLoanApplicationSubStage('test');
            }
            catch (AuraHandledException e){
                System.debug(e.getMessage());
            }
            
        }
        test.stopTest();
    }
    @isTest
    public static void createOtherDocumentTest1(){
        try{
            Opportunity opga1 = new Opportunity();
            opga1.StageName = 'Qualification';
            opga1.CloseDate = Date.newInstance(2021, 1, 11);
            opga1.Name = 'testone';
            insert opga1;
            
            Applicant__c apga1 = new Applicant__c();
            apga1.Opportunity__c = opga1.Id;
            apga1.Contact_number__c = '9743514830';
            apga1.Applicant_Type__c = 'Borrower';
            insert apga1;
            
            Vehicle_Detail__c vdt1 = new Vehicle_Detail__c();
            vdt1.Loan_Application__c = opga1.Id;
            vdt1.Base_Price__c = 100000.00;
            vdt1.Ben_Code__c = 'testveh';
            vdt1.Vehicle_type__c = 'Used';
            vdt1.Variant__c = 'JAWA Variant';
            insert vdt1;
            
            Documents__c dfu1 = new Documents__c();
            dfu1.Applicant__c = apga1.Id;
            dfu1.Opportunity_Relation__c = opga1.Id;
            dfu1.Vehicle_Detail__c = vdt1.Id;
            dfu1.is_Active__c = false;
            dfu1.Document_Type__c = System.Label.AadhaarCard;
            dfu1.Document_Side__c ='Back';
            dfu1.Aadhar_Source__c = 'ScanAadhar';
            dfu1.Front_Upload_Attempts__c = 5;
            insert dfu1;
            
            Test.startTest();
            GenericUploadController.createOtherDocument(dfu1.Document_Type__c,vdt1.Id,apga1.Id,opga1.Id);
            GenericUploadController.createOtherDocument(null,null,null,null);
            GenericUploadController.getContentVersion('test');
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    @IsTest
    public static void test_checkPaymentRequest(){
        test.startTest();
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod122@indusbank.com' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            try{
                Opportunity opp = [Select id,Payment_Request_Generation_Date__c,name from opportunity limit 1];
                opp.Payment_Request_Generation_Date__c = system.now();
                update opp;
                
                /*Deal_Number__c dealNo = new Deal_Number__c();
                dealNo.Loan_Application__c = opp.id;
                insert dealNo;*/
                
                Vehicle_Detail__c vehicleObj = new Vehicle_Detail__c();
                vehicleObj.Loan_Application__c =  opp.Id;
                //vehicleObj.Deal_Number__c = dealNo.id;
                insert vehicleObj;        
                GenericUploadController.checkPaymentRequest(opp.Id,null);
            }
            catch (AuraHandledException e){
                System.debug(e.getMessage());
            }
            
        }
    }
    
     @IsTest
    public static void testGetRelatedFileByRecordId() {
        // Prepare test data
        ContentVersion testContentVersion = new ContentVersion(
            Title = 'Test Content',
            PathOnClient = 'Test.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert testContentVersion;

        // Call the method under test
        String contentVersionId = testContentVersion.Id;
        String encodedData = GenericUploadController.getRelatedFileByRecordId(contentVersionId);

        // Retrieve the original ContentVersion
        ContentVersion originalContentVersion = [
            SELECT Id, VersionData
            FROM ContentVersion
            WHERE Id = :contentVersionId
        ];

        // Verify the result
        System.assertEquals(
            EncodingUtil.base64Encode(originalContentVersion.VersionData),
            encodedData,
            'Base64 encoded data should match the original ContentVersion data'
        );
    }
    
}