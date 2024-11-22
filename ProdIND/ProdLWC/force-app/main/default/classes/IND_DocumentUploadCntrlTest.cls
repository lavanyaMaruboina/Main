/*
* @Test Class:  IND_DocumentUploadCntrlTest
* @Author: 		Vinita K.
* @Description :All methods are to test class IND_DocumentUploadCntrl.
* @Company:     Persistent Systems
*/
@isTest(seeAllData = false)
public class IND_DocumentUploadCntrlTest {
    @testSetup
    static void setup(){
        //create user
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];//IBL CVO
        User u = new User(Alias = 'standt2', Email='standarduser2@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,Maker_Id__c='12',IsActive = true,
                          TimeZoneSidKey='America/Los_Angeles',UserName='test_userprod123Pro@indusbank.com',mobilePhone= '9087567898');
        insert u;
        System.runAs(u) 
        {
            //create Oppty records
            List<Opportunity> opptyList = new List<Opportunity>();
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            opp.Name = 'VDR Test';
            opp.Sanction_Date__c=NULL;
            opp.StageName = 'Final Offer';
            opp.Product_Type__c = 'Two Wheeler';
            opptyList.add(opp);
            
            Opportunity opp2 = TestDataUtility.createTestOpportunity1(false);
            opp2.Name = 'VDR Negative Test';
            opp2.CloseDate = Date.today();
            opp2.StageName = 'Credit Processing';
            opp2.Product_Type__c = 'Tractor';
            opptyList.add(opp2);
            
            Opportunity opp3 = TestDataUtility.createTestOpportunity1(false);
            opp3.Name = 'Oppty 3';
            opp3.CloseDate = Date.today();
            opp3.StageName = 'Post Sanction Checks and Documentation';
            opptyList.add(opp3);
            if(Schema.sObjectType.Opportunity.isCreateable()){
                insert opptyList;
            }
            
            //create Vehicle_Detail__c record
            List<Vehicle_Detail__c> vdList = new List<Vehicle_Detail__c>();
            Vehicle_Detail__c  vehicleDetail = TestDataUtility.createTestVehicleDetailForIbb(false, opp);
            
            vdList.add(vehicleDetail);
            if (Schema.sObjectType.Vehicle_Detail__c.isCreateable()){
                insert vdList;
            }
            
            //create Final_Term__c record
            List<Final_Term__c> ftList = new List<Final_Term__c>();
            Final_Term__c ft = new Final_Term__c();
            ft.CRM_IRR__c = 120;
            ft.Loan_Application__c = opp2.Id;
            ft.Holiday_period__c='30';
            ft.EMI_Amount__c= 10000;
            ft.FIwaiver_offAddress__c = 'Not Waived';
            ft.Installment_Type__c ='Structured';
            ftList.add(ft);
            Final_Term__c ft2 = new Final_Term__c();
            ft2.CRM_IRR__c = 120;
            ft2.Loan_Application__c = opp3.Id;
            ft2.Holiday_period__c='30';
            ft2.EMI_Amount__c= 10000;
            ft2.FIwaiver_offAddress__c = 'Not Waived';
            ft2.Loan_Amount__c = '1500000345';
            ftList.add(ft2);
            if(Schema.sObjectType.Final_Term__c.isCreateable()){
                insert ftList;
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
            applicantList.add(applicant2);
            if(Schema.sObjectType.Applicant__c.isCreateable()){
                insert applicantList;
            }
            
            //Create Loan_Application_Transaction_History__c
            List<Loan_Application_Transaction_History__c> laptHistList = new List<Loan_Application_Transaction_History__c>();
            Loan_Application_Transaction_History__c lth1 = new Loan_Application_Transaction_History__c();
            lth1.Loan_Application_ID__c = opp.Id;
            //lth1.Name ='Vehicle Inspection and RC Check';
            lth1.Module__c = 'Pre Disbursement Check';
            lth1.Screen__c = 'Vehicle Inspection and RC Check';
            lth1.Module_Name__c = 'FI';
            lth1.Submitted_Flag__c = true;
            laptHistList.add(lth1);
            Loan_Application_Transaction_History__c lth2 = new Loan_Application_Transaction_History__c();
            lth2.Loan_Application_ID__c = opp.Id;
            lth2.Module__c = 'Post Sanction Checks and Documentation';
            lth2.Screen__c = 'Structured EMI';
            lth2.Module_Name__c = 'FI';
            lth2.Submitted_Flag__c = true;
            laptHistList.add(lth2);
            if(Schema.sObjectType.Loan_Application_Transaction_History__c.isCreateable()){
                insert laptHistList;
            }
            
            //Create Documents__c records
            List<Documents__c> docList = new List<Documents__c>();
            Documents__c doc1 = TestDataUtility.createTestDocumentITR(false, applicant1, opp);
            doc1.Vehicle_Detail__c = vehicleDetail.Id;
            doc1.Opportunity_Relation__c = opp.Id;
            doc1.Is_active__c = true;
            doc1.Applicant__c=applicant1.Id;
            doc1.Cheque_Number__c=3;
            // doc1.Sequence_Number__c=20338;
            doc1.Name='Chassis Number uploaded during verification '+opp.Id+' ' + 20338;
            doc1.Document_Type__c = 'Chassis Number uploaded during verification';
            docList.add(doc1);
            
            Documents__c doc2 = TestDataUtility.createTestDocumentITR(false, applicant1, opp);
            doc2.Vehicle_Detail__c = vehicleDetail.Id;
            doc2.Opportunity_Relation__c = opp.Id;
            doc2.Is_active__c = true;
            doc2.Applicant__c=applicant1.Id;
            doc2.Cheque_Number__c=3;
            // doc1.Sequence_Number__c=20338;
            doc2.Name='Chassis Number uploaded during verification '+opp.Id;
            doc2.Document_Type__c = 'Chassis Number uploaded during verification';
            docList.add(doc2);
            
            Documents__c doc3 = TestDataUtility.createTestDocumentITR(false, applicant1, opp);
            doc3.Vehicle_Detail__c = vehicleDetail.Id;
            doc3.Opportunity_Relation__c = opp.Id;
            doc3.Is_active__c = true;
            doc3.Is_this_a_Photocopy__c = TRUE ;
            doc3.Applicant__c=applicant1.Id;
            doc3.Cheque_Number__c=3;
            // doc1.Sequence_Number__c=20338;
            doc3.Name='Chassis Number uploaded during verification '+' '+doc3.Sequence_Number__c;
            doc3.Document_Type__c = System.Label.New_RC_Doc_Type;            
            docList.add(doc3);
            
            Documents__c doc4 = TestDataUtility.createTestDocumentITR(false, applicant1, opp);
            doc4.Vehicle_Detail__c = vehicleDetail.Id;
            doc4.Opportunity_Relation__c = opp.Id;
            doc4.Is_active__c = true;
            doc4.Is_this_a_Photocopy__c = TRUE ;
            doc4.Applicant__c=applicant1.Id;
            doc4.Cheque_Number__c=3;
            doc4.Name='Aadhaar '+' '+doc4.Sequence_Number__c;
            doc4.Document_Type__c = System.Label.AadhaarCard;            
            docList.add(doc4);
            
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
            cdl.LinkedEntityId = doc3.Id;
            cdl.ContentDocumentId = documents[0].Id;
            cdl.ShareType = 'V';
            cdl.Visibility = 'AllUsers';
            insert cdl; 
            
            Id tvrRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('TVR').getRecordTypeId();
            case objCase = new case();
            objCase.OwnerId = u.Id;
            objCase.Status = 'Pass';
            objCase.Subject = opp.Name+'_TVR';
            objCase.RecordTypeId = tvrRecordTypeId;
            objCase.Loan_Application__c = opp.Id;            
            insert objCase;                   
            
            TeleVerification__c objTVR1 = new TeleVerification__c(); 
            objTVR1.Name = '_TVR'; 
            objTVR1.Case__c = objCase.Id;  
            objTVR1.RecordTypeId = Schema.SObjectType.TeleVerification__c.getRecordTypeInfosByName().get('Post-Sanction').getRecordTypeId();               
            objTVR1.Loan_Application__c = opp.Id;
            insert objTVR1;
            
            ContentDocumentLink cdl1 = new ContentDocumentLink();
            cdl1.LinkedEntityId = objTVR1.Id;
            cdl1.ContentDocumentId = documents[0].Id;
            cdl1.ShareType = 'V';
            cdl1.Visibility = 'AllUsers';
            insert cdl1; 
            
            AML_Check__c amlCheck = new AML_Check__c();
            amlCheck.Matched_base__c = 'MatchBase';
            amlCheck.List_Name__c = 'amlList';
            amlCheck.Name__c = 'amlName';
            amlCheck.Name_Score__c = 5;
            amlCheck.ML_Id__c = '45678';
            amlCheck.Nationality__c = 'IND';
            amlCheck.Nationality_Score__c = 90;
            amlCheck.ML_Address__c = 'Mumbai';
            amlCheck.ML_City__c = 'Mumbai';
            amlCheck.ML_Date_Of_Birth__c = String.valueOf(System.today());
            amlCheck.ML_Description__c = 'Creating aml Data';
            amlCheck.CA_Decision__c = '';
            amlCheck.Remarks_Credit_Analyst__c = '';
            amlCheck.CH_Decision__c = '';
            amlCheck.Remarks_Credit_Head__c = '';
            amlCheck.CMU_Decision__c = '';
            amlCheck.Remarks_CMU__c = '';
            amlCheck.BE_CVO_Decision__c = '';
            amlCheck.Remarks_BE_CVO__c = '';
            amlCheck.Score__c = 90;
            amlCheck.Loan_Application__c = opp.Id;
            amlCheck.Case__c = objCase.Id;
            insert amlCheck;
            
            ContentDocumentLink cdl2 = new ContentDocumentLink();
            cdl2.LinkedEntityId = amlCheck.Id;
            cdl2.ContentDocumentId = documents[0].Id;
            cdl2.ShareType = 'V';
            cdl2.Visibility = 'AllUsers';
            insert cdl2; 
            
            //Create Retry_Count__c records
            List<Retry_Count__c> rtCountList = new List<Retry_Count__c>();
            Retry_Count__c retryCount = new Retry_Count__c();
            retryCount.Service_Name__c = 'RC Limit Check';
            retryCount.Count__c = 0;
            retryCount.Loan_Application_Id__c = opp.Id;
            rtCountList.add(retryCount);
            if(Schema.sObjectType.Retry_Count__c.isCreateable()){
                insert rtCountList;
            }
            
            //Create Structered_EMI__c records
            List<Structered_EMI__c> semiList = new List<Structered_EMI__c>();
            Structered_EMI__c semi = new Structered_EMI__c();
            semi.From_Month__c = 1;
            semi.To_Month__c = 9;
            semi.EMI_Amount__c = 45000;
            semi.Number_of_Installments__c = 9;
            semi.Loan_Application__c = opp.Id;
            semiList.add(semi);
            Structered_EMI__c semi2 = new Structered_EMI__c();
            semi2.From_Month__c = 5;
            semi2.To_Month__c = 9;
            semi2.EMI_Amount__c = 50000;
            semi2.Number_of_Installments__c = 4;
            semi2.Loan_Application__c = opp.Id;
            semiList.add(semi2);
            if(Schema.sObjectType.Structered_EMI__c.isCreateable()){
                insert semiList;
            }
        }
    }
    
    @isTest
    public static void createDocumentTest(){
        try{
            Opportunity opp =[Select Id, Name From Opportunity Where Name ='Oppty 3' LIMIt 1];
            Vehicle_Detail__c vehDet = [Select Id, Variant__c From Vehicle_Detail__c Where Variant__c = 'ALSTILELE' LIMIT 1];
            Applicant__c apsd2=[Select Id,Contact_number__c From Applicant__c Where Contact_number__c='9743514830' LIMIT 1];
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123Pro@indusbank.com' AND IsActive = true LIMIT 1];
            System.runAs(u)
            {
                IND_DocumentUploadCntrl.createDocument(vehDet.Id,apsd2.Id,opp.Id);
                IND_DocumentUploadCntrl.createDocument(null,null,null);
            }
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
        
    }
    
    @isTest
    public static void createDocumentForChequeTest(){
        try{
            Opportunity opp =[Select Id, Name From Opportunity Where Name ='VDR Test' LIMIt 1];
            Vehicle_Detail__c vehDet = [Select Id, Variant__c From Vehicle_Detail__c Where Variant__c = 'ALSTILELE' LIMIT 1];
            Applicant__c apsd2=[Select Id,Contact_number__c From Applicant__c Where Who_will_repay_the_loan__c = 'Borrower' LIMIT 1];
            String docName = 'Chassis Number uploaded during verification '+opp.Id + ' ' + 20338;
            Documents__c doc=[SELECT Id,Document_Type__c,Name, Cheque_Number__c FROM Documents__c Where Name =:docName AND Document_Type__c='Chassis Number uploaded during verification' LIMIT 1];
            
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123Pro@indusbank.com' AND IsActive = true LIMIT 1];
            System.runAs(u)
            {
                IND_DocumentUploadCntrl.createDocumentForCheque(doc.Document_Type__c,vehDet.Id,apsd2.Id,opp.Id,(Integer)doc.Cheque_Number__c,20338);
                // System.assertEquals(null,negTest );
            }
            Test.stopTest();
        }
        catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
        
    }
    
    @isTest
    public static void deleteDocumentTest(){
        try{
            Documents__c doc=[SELECT Id,Document_Type__c FROM Documents__c Where Document_Type__c='Chassis Number uploaded during verification' LIMIT 1];
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123Pro@indusbank.com' AND IsActive = true LIMIT 1];
            System.runAs(u)
            {
                IND_DocumentUploadCntrl.deleteDocument(doc.Id);
            }
            Test.stopTest();
            
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    } 
    
    @isTest
    public static void deleteDocumentsFromContentDocumentTest(){
        
        try{
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123Pro@indusbank.com' AND IsActive = true LIMIT 1];
            System.runAs(u)
            {
                Opportunity opp =[Select Id, Name From Opportunity Where Name ='Oppty 3' LIMIt 1];
                Vehicle_Detail__c vehDet = [Select Id, Variant__c From Vehicle_Detail__c Where Variant__c = 'ALSTILELE' LIMIT 1];
                Applicant__c apsd2=[Select Id,Contact_number__c From Applicant__c Where Contact_number__c='9743514830' LIMIT 1];
                Documents__c doc=[SELECT Id,Document_Type__c FROM Documents__c Where Document_Type__c='Chassis Number uploaded during verification' LIMIT 1];
                
                ContentVersion co1 = new ContentVersion();
                co1.PathOnClient = 'testone';
                co1.Title = 'testitle';
                co1.VersionData = Blob.valueOf('Test Content');
                co1.Document_Side_fileupload__c = 'Front';
                insert co1;
                
                ContentVersion testcd1 = [SELECT id, ContentDocumentId FROM ContentVersion where Id = : co1.Id];
                
                ContentDocumentLink cdlink1 = new ContentDocumentLink();
                cdlink1.Visibility = 'AllUsers';
                cdlink1.ShareType = 'V';
                cdlink1.LinkedEntityId = doc.Id;
                cdlink1.ContentDocumentId = testcd1.ContentDocumentId;
                insert cdlink1;  
                
                ContentVersion co2 = new ContentVersion();
                co2.ContentDocumentId = cdlink1.ContentDocumentId;
                co2.PathOnClient = 'testone';
                co2.Title = 'testitle';
                co2.VersionData = Blob.valueOf('Test Content');
                co2.Document_Side_fileupload__c = 'Selfie';
                insert co2;
                
                
                IND_DocumentUploadCntrl.deleteDocumentsFromContentDocument(cdlink1.Id);
            }
            Test.stopTest();
            
        } catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void getUserDetailsTest(){
        try{            
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123Pro@indusbank.com' AND IsActive = true LIMIT 1];
            System.runAs(u)
            {
                Map<String,String> result = IND_DocumentUploadCntrl.getUserDetails();
                System.assertNotEquals(null, result);
            }
            Test.stopTest();
            
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void isDeleteableTest(){
        try{            
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123Pro@indusbank.com' AND IsActive = true LIMIT 1];
            System.runAs(u)
            {
                Documents__c doc=[SELECT Id,Document_Type__c,Name, Cheque_Number__c FROM Documents__c LIMIT 1];
                Boolean result = IND_DocumentUploadCntrl.isDeleteable(doc.Id);
                IND_DocumentUploadCntrl.isDeleteable('test');
                IND_DocumentUploadCntrl.isDeleteable(null);
                System.assertNotEquals(false, result);
            }
            Test.stopTest();
            
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void createDocumentForAdditionalDocumentTest(){
        try{
            Opportunity opp =[Select Id, Name From Opportunity Where Name ='VDR Test' LIMIt 1];
            Vehicle_Detail__c vehDet = [Select Id, Variant__c From Vehicle_Detail__c Where Variant__c = 'ALSTILELE' LIMIT 1];
            Applicant__c apsd2=[Select Id,Contact_number__c From Applicant__c Where Who_will_repay_the_loan__c = 'Borrower' LIMIT 1];
            String docName = 'Chassis Number uploaded during verification '+opp.Id;
            Documents__c doc=[SELECT Id,Document_Type__c,Name, Cheque_Number__c FROM Documents__c Where Name =:docName AND Document_Type__c='Chassis Number uploaded during verification' LIMIT 1];
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123Pro@indusbank.com' AND IsActive = true LIMIT 1];
            System.runAs(u)
            {
                IND_DocumentUploadCntrl.createDocumentForAdditionalDocument(doc.Document_Type__c,vehDet.Id,apsd2.Id,opp.Id); 
            }
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @istest
    public static void getApplicantDetailsTest(){
        
        Test.startTest();
        
        // Opportunity oppNeg =[Select Id, Name From Opportunity Where Name ='VDR Test' LIMIt 1];
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123Pro@indusbank.com' AND IsActive = true LIMIT 1];
        System.runAs(u)
        {
            try{
                IND_DocumentUploadCntrl.getApplicantDetails('jsahdkjsahd');
            }catch(Exception ex){
                System.assert(ex.getMessage().contains('Invalid id'));
            }
            Opportunity opp =[Select Id, Name From Opportunity Where Name ='VDR Test' LIMIt 1];
            IND_DocumentUploadCntrl.getApplicantDetails(opp.Id);
        }
        Test.stopTest();        
    }
    
    @isTest
    public static void createOtherDocumentTest(){
        try{
            Opportunity opp =[Select Id, Name From Opportunity Where Name ='Oppty 3' LIMIt 1];
            Vehicle_Detail__c vehDet = [Select Id, Variant__c From Vehicle_Detail__c Where Variant__c = 'ALSTILELE' LIMIT 1];
            Applicant__c apsd2=[Select Id,Contact_number__c From Applicant__c Where Contact_number__c='9743514830' LIMIT 1];
            Documents__c doc=[SELECT Id,Document_Type__c FROM Documents__c Where Document_Type__c='Chassis Number uploaded during verification' LIMIT 1]; 
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123Pro@indusbank.com' AND IsActive = true LIMIT 1];
            System.runAs(u)
            {
                IND_DocumentUploadCntrl.createOtherDocument(doc.Document_Type__c, vehDet.Id, apsd2.Id, opp.Id);
            }
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void getDocumentByTypeTest(){
        try{            
            Opportunity opp =[Select Id, Name From Opportunity Where Name ='VDR Test' LIMIt 1];
            AML_Check__c amlObj = [SElect id from AML_Check__c limit 1];
            TeleVerification__c tele = [Select Id from TeleVerification__c limit 1];
            Vehicle_Detail__c vehDet = [Select Id, Variant__c From Vehicle_Detail__c Where Variant__c = 'ALSTILELE' LIMIT 1];
            Applicant__c apsd2=[Select Id,Contact_number__c From Applicant__c Where Contact_number__c='9743514830' LIMIT 1];
            Documents__c doc=[SELECT Id,Document_Type__c FROM Documents__c Where Document_Type__c='Chassis Number uploaded during verification' LIMIT 1]; 
                       
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123Pro@indusbank.com' AND IsActive = true LIMIT 1];
            System.runAs(u)
            {
                List<Id> result1 = IND_DocumentUploadCntrl.getDocumentByType(opp.Id,apsd2.Id, 'All');
                System.assertNotEquals(null, result1);
                
                List<Id> result3 = IND_DocumentUploadCntrl.getDocumentByType(null,null, 'Test');
                System.assertEquals(null, result3);
            }
            Test.stopTest();
            List<Id> result2 = IND_DocumentUploadCntrl.getDocumentByType(opp.Id,apsd2.Id, 'TVR');
                System.assertNotEquals(null, result2);
            List<Id> result3 = IND_DocumentUploadCntrl.getDocumentByType(opp.Id,apsd2.Id, 'AML');
            IND_DocumentUploadCntrl.getDocumentByType(opp.Id,apsd2.Id, 'PAN');
                System.assertNotEquals(null, result3);
        }catch(Exception e){
            system.debug('ex--'+e);
        }
    }
    
    @isTest
    public static void getDocumentTypesTest(){
        try{    
            Opportunity oppObj = [Select Id, StageName,Product_Type__c,Sanction_Date__c,Customer_Type__c from opportunity WHERE Product_Type__c = 'Tractor' LIMIT 1];
            Applicant__c apsd2=[Select Id,Contact_number__c, Opportunity__c From Applicant__c Where Who_will_repay_the_loan__c = 'Borrower'  LIMIT 1];
            User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123Pro@indusbank.com' AND IsActive = true LIMIT 1];
            Test.startTest();
            System.runAs(u)
            {
                String result1 = IND_DocumentUploadCntrl.getDocumentTypes(oppObj.Id, apsd2.Id, 'Upload','Non-Individual');
                System.assertNotEquals(null, result1);  
                String result2 = IND_DocumentUploadCntrl.getDocumentTypes(oppObj.Id, apsd2.Id, 'Test','Non-Individual');
                System.assertNotEquals(null, result2);  
            }
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    @isTest
    public static void getDocumentTypesTest2(){
        try{    
            Opportunity oppObj = [Select Id, StageName,Product_Type__c,Sanction_Date__c,Customer_Type__c from opportunity WHERE Product_Type__c = 'Two Wheeler' OR StageName = 'Credit Processing' OR StageName = 'Final Offer' OR StageName = 'Post Sanction Checks and Documentation' LIMIT 1];
            Applicant__c apsd2=[Select Id,Contact_number__c, Opportunity__c From Applicant__c Where Who_will_repay_the_loan__c = 'Borrower'  LIMIT 1];
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123Pro@indusbank.com' AND IsActive = true LIMIT 1];
            System.runAs(u)
            {
                String result1 = IND_DocumentUploadCntrl.getDocumentTypes(oppObj.Id, apsd2.Id, 'Upload','Non-Individual');
                System.assertNotEquals(null, result1);  
                String result2 = IND_DocumentUploadCntrl.getDocumentTypes(oppObj.Id, apsd2.Id, 'Test','Non-Individual');
                System.assertNotEquals(null, result2);  
            }
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @IsTest
    public static void deleteContentDocumentTest(){
        Test.startTest();  
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123Pro@indusbank.com' AND IsActive = true LIMIT 1];
        System.runAs(u)
        {
            //negative
            try 
            {
                IND_DocumentUploadCntrl.deleteContentDocument(null);            
            } 
            catch(Exception ex)
            {
                System.assert(ex.getMessage().contains('Script-thrown exception'));
            }
        }
        Test.stopTest();
    }
    
    @isTest
    public static void getDocumentsTest(){
        try{
			List<TeleVerification__c> teleObj = [Select Id from TeleVerification__c];            
            Applicant__c applicant=[Select Id, Opportunity__c, Contact_number__c From Applicant__c Where Scorecard_Decision__c = 'Light Red' LIMIT 1];            
            Test.startTest(); 
            User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123Pro@indusbank.com' AND IsActive = true LIMIT 1];
            System.runAs(u)
            {
                List<Id> docIds1 = IND_DocumentUploadCntrl.getDocuments(applicant.Opportunity__c, applicant.Id);
                System.assertNotEquals(null, docIds1);
                
                //Negative
                List<Id> docIds2 = IND_DocumentUploadCntrl.getDocuments(null,null);
                System.assertEquals(null, docIds2);
            }
            Test.stopTest();
            
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void inactiveDocumentsTest(){
        try{            
            Documents__c doc=[SELECT Id,Document_Type__c,Opportunity_Relation__c FROM Documents__c Where Document_Type__c='Chassis Number uploaded during verification' LIMIT 1]; 
            Test.startTest();
            doc.Document_Type__c = System.Label.AadhaarCard;
            update doc;
            ContentVersion contentVersion = new ContentVersion(
                Title          = 'testfname_aadhaar',
                PathOnClient   = 'Pic.jpg',
                VersionData    = Blob.valueOf('Test Content'),
                IsMajorVersion = true,
                Document_Side_fileupload__c = 'Front');
            insert contentVersion; 
            List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument Where Title = 'testfname_aadhaar'];
            
            //create ContentDocumentLink  record
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.LinkedEntityId = doc.Id;
            cdl.ContentDocumentId = documents[0].Id;
            cdl.ShareType = 'V';
            cdl.Visibility = 'AllUsers';
            insert cdl;
            User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123Pro@indusbank.com' AND IsActive = true LIMIT 1];
            System.runAs(u)
            {
                IND_DocumentUploadCntrl.inactiveDocuments(doc.Id, doc.Document_Type__c,doc.Opportunity_Relation__c, 'Front','');   
            }
            Test.stopTest();
            Documents__c updatedDoc=[SELECT Id, is_Active__c FROM Documents__c Where is_Active__c = false LIMIT 1]; 
            System.assertNotEquals(null, updatedDoc);
        }catch(Exception e){
            //System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void deleteDocumentsTest(){
        try{            
            Documents__c doc=[SELECT Id,Document_Type__c FROM Documents__c Where Document_Type__c='Chassis Number uploaded during verification' LIMIT 1]; 
            List<Id> docIds = new List<Id>();
            docIds.add(doc.Id);
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123Pro@indusbank.com' AND IsActive = true LIMIT 1];
            System.runAs(u)
            {
                IND_DocumentUploadCntrl.deleteDocuments(docIds, null);   
            }
            Test.stopTest();            
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void loadInputsForDocumentsUploadTest(){
        Test.startTest();
              IND_DocumentUploadCntrl.loadInputsForDocumentsUpload();
        Test.stopTest();
    }
    
    @isTest
    public static void deleteContentDocumentTest1(){
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
                       IND_DocumentUploadCntrl.deleteContentDocument(contentlink1.Id);
                 Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
        
    }
    
    @isTest
    public static void deleteDocumentsTest2(){
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
            
                 List<String> contId = new List<String>();
                 contId.add(testContent1.ContentDocumentId);
            
                 List<String> docList = new List<String>();
                 docList.add(dfks1.Id);
            
                 Test.startTest();
                        IND_DocumentUploadCntrl.deleteDocuments(docList,contId);
                 Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void getProfileTest(){
        Test.startTest();
             IND_DocumentUploadCntrl.getProfile();
        Test.stopTest();
    }
    
    @isTest
    public static void getDocumentByTypeTest3(){
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
                insert apks1;
            
                 Documents__c dfks1 = new Documents__c();
                 dfks1.Applicant__c = apks1.Id;
                 dfks1.Opportunity_Relation__c = opks1.Id;
                 dfks1.KYC_name__c = 'Aadhar';
                 dfks1.Document_Side__c ='Back';
                 dfks1.Aadhar_Source__c = 'ScanAadhar';
                 dfks1.Name = 'Aadhar';
                 dfks1.Document_Type__c = System.Label.AadhaarCard;
                 dfks1.is_Active__c = true;
                 insert dfks1;
            
                 Test.startTest();
                      IND_DocumentUploadCntrl.getDocumentByType(opks1.Id,apks1.Id,dfks1.Document_Type__c);
                      IND_DocumentUploadCntrl.getDocumentByType('test','test','test');
                      IND_DocumentUploadCntrl.getDocumentByType(null,null,null);
                 Test.stopTest();
        
        }catch(Exception e){
            System.assertEquals('script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void getAMLDocumentsTest1(){
        try{
            Test.startTest();
                IND_DocumentUploadCntrl.getAMLDocuments(null);
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals('script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void getTVRDocumentsTest1(){
        try{
            Test.startTest();
                 IND_DocumentUploadCntrl.getTVRDocuments(null);
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals('script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void isProfileMA() {
        try{
            Test.startTest();
                profile pId = [select id,name from profile where name='IBL Partner Community Marketing Agent'];
            Account a = new Account(name='test2');
            insert a;
            contact c = new contact(LastName='test',accountId=a.Id);
            insert c;
            User u = new User(Alias = 'testUser', Email='standarduser@testorg.com', 
    		EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', ContactId = c.Id,
    		LocaleSidKey='en_US', ProfileId = pId.Id,TimeZoneSidKey='America/New_York', UserName='testUser987@induslndBank.com',mobilePhone= '9087567896');
            insert u;
            System.runAs(u)
            {
                Opportunity opp = new Opportunity();
            	opp.Name = 'VDR Test';
            	opp.Sanction_Date__c=NULL;
            	opp.Product_type__C = 'Two Wheeler';
                opp.StageName = 'Qualification';
                opp.CloseDate = date.today();
                insert opp;
                
                Vehicle_Detail__c  vehicleDetail = TestDataUtility.createTestVehicleDetailForIbb(true, opp);
                
				IND_DocumentUploadCntrl.getMAProfileName(opp.Id);
                IND_DocumentUploadCntrl.getVehicleData(opp.Id);
            }
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals('script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void isProfileCVO1()
    {        
        try{
            Test.startTest();
                profile pId = [select id,name from profile where name='IBL CVO'];
            Account a = new Account(name='test2');
            insert a;
            contact c = new contact(LastName='test',accountId=a.Id);
            insert c;
            User u = new User(Alias = 'testUser', Email='standarduser@testorg.com', 
    		EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
    		LocaleSidKey='en_US', ProfileId = pId.Id,TimeZoneSidKey='America/New_York', UserName='testUser987@induslndBank.com',mobilePhone= '9087567897');
            insert u;
            System.runAs(u)
            {
                Opportunity opp = new Opportunity();
            	opp.Name = 'VDR Test';
            	opp.Sanction_Date__c=NULL;
            	opp.Product_type__C = 'Two Wheeler';
                opp.StageName = 'Qualification';
                opp.CloseDate = date.today();
                insert opp;
                
                Applicant__c apks1 = new Applicant__c();
                apks1.Opportunity__c = opp.Id;
                apks1.Contact_number__c = '9743514830';
                apks1.Applicant_Type__c = 'Borrower';
                apks1.In_Active_Applicant__c = false;
                insert apks1;
                
            	Documents__c doc1 = new Documents__c();
                doc1.Opportunity_Relation__c = opp.Id;
                doc1.Is_active__c = true;
                doc1.Cheque_Number__c=3;
                doc1.Applicant__c=apks1.Id;
                doc1.Name='Chassis Number uploaded during verification '+opp.Id+' ' + 20338;
                doc1.Document_Type__c = 'Customer Image';
                insert doc1;
				IND_DocumentUploadCntrl.isProfileCVO(doc1.Id,opp.Id);
            }
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals('script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void countOfChequesDoc1()
    {        
        try{
            Test.startTest();
                Opportunity opp = new Opportunity();
            	opp.Name = 'VDR Test';
            	opp.Sanction_Date__c=NULL;
            	opp.Product_type__C = 'Two Wheeler';
                opp.StageName = 'Qualification';
                opp.CloseDate = date.today();
                insert opp;
                
                Applicant__c apks1 = new Applicant__c();
                apks1.Opportunity__c = opp.Id;
                apks1.Contact_number__c = '9743514830';
                apks1.Applicant_Type__c = 'Borrower';
                apks1.In_Active_Applicant__c = false;
                insert apks1;
                
            	Documents__c doc1 = new Documents__c();
                doc1.Opportunity_Relation__c = opp.Id;
                doc1.Is_active__c = true;
                doc1.Cheque_Number__c=3;
                doc1.Applicant__c=apks1.Id;
                doc1.Name='Chassis Number uploaded during verification '+opp.Id+' ' + 20338;
                doc1.Document_Type__c = 'Cheques SPDC';
                insert doc1;
				IND_DocumentUploadCntrl.countOfChequesDoc(opp.Id);
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals('script-thrown exception', e.getMessage());
        }
    }
    
    
    @isTest
    public static void isProfileCVO()
    {        
        try{
            Test.startTest();
                profile pId = [select id,name from profile where name='IBL CVO'];
            Account a = new Account(name='test2');
            insert a;
            contact c = new contact(LastName='test',accountId=a.Id);
            insert c;
            User u = new User(Alias = 'testUser', Email='standarduser@testorg.com', 
    		EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
    		LocaleSidKey='en_US', ProfileId = pId.Id,TimeZoneSidKey='America/New_York', UserName='testUser987@induslndBank.com',mobilePhone= '9087567899');
            insert u;
            System.runAs(u)
            {
                Opportunity opp = new Opportunity();
            	opp.Name = 'VDR Test';
            	opp.Sanction_Date__c=NULL;
            	opp.Product_type__C = 'Two Wheeler';
                opp.StageName = 'Qualification';
                opp.CloseDate = date.today();
                insert opp;
                
                Applicant__c apks1 = new Applicant__c();
                apks1.Opportunity__c = opp.Id;
                apks1.Contact_number__c = '9743514830';
                apks1.Applicant_Type__c = 'Borrower';
                apks1.In_Active_Applicant__c = false;
                insert apks1;
                
            	Documents__c doc1 = new Documents__c();
                doc1.Opportunity_Relation__c = opp.Id;
                doc1.Is_active__c = true;
                doc1.Cheque_Number__c=3;
                doc1.Applicant__c=apks1.Id;
                doc1.Name='Chassis Number uploaded during verification '+opp.Id+' ' + 20338;
                doc1.Document_Type__c = 'Customer Image';
                insert doc1;
				IND_DocumentUploadCntrl.isProfileCVO(doc1.Id,opp.Id);
            }
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals('script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void countOfChequesDoc()
    {        
        try{
            Test.startTest();
    
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals('script-thrown exception', e.getMessage());
        }
    }

    @isTest
    public static void checkUserAbleToDeleteDoc()
    {        
        try{
            profile pId = [select id,name from profile where name='IBL CVO'];
            Account a = new Account(name='test2');
            insert a;
            contact c = new contact(LastName='test',accountId=a.Id);
            insert c;
            User u = new User(Alias = 'testUser', Email='standarduser@testorg.com', 
    		EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
    		LocaleSidKey='en_US', ProfileId = pId.Id,Maker_Id__c='12',TimeZoneSidKey='America/New_York', UserName='testUser987@induslndBank.com',MobilePhone='9087567898');
            insert u;
            System.runAs(u)
            {
                Opportunity opp = new Opportunity();
            	opp.Name = 'VDR Test';
            	opp.Sanction_Date__c=NULL;
            	opp.Product_type__C = 'Passenger Vehicles';
                opp.StageName = 'Qualification';
                opp.CloseDate = Date.today();
                insert opp;
                
                Applicant__c apks1 = new Applicant__c();
                apks1.Opportunity__c = opp.Id;
                apks1.Contact_number__c = '9743514830';
                apks1.Applicant_Type__c = 'Borrower';
                apks1.In_Active_Applicant__c = false;
                insert apks1;
                String cmuCaseRecordTypeId = Schema.sObjectType.Case.getRecordTypeInfosByName().get('CMU Request').getRecordTypeId();
                Case cmuCase = new Case();
                cmuCase.OwnerId = u.Id;
                cmuCase.Status = 'Pending with Sales';
                cmuCase.Subject = opp.Name+'_CMU';
                cmuCase.RecordTypeId = cmuCaseRecordTypeId;
                cmuCase.Loan_Application__c = opp.Id;
                insert cmuCase;

            	Documents__c doc1 = new Documents__c();
                doc1.Opportunity_Relation__c = opp.Id;
                doc1.Is_active__c = true;
                doc1.Cheque_Number__c=3;
                doc1.Applicant__c=apks1.Id;
                doc1.Name='Chassis Number uploaded during verification '+opp.Id+' ' + 20338;
                doc1.Document_Type__c = 'Customer Image';
                doc1.Case__c = cmuCase.Id;
                insert doc1;

                CAM__c cam1 = new CAM__c();
                cam1.Loan_Application__c = opp.Id;
                cam1.Trigger_Deviations__c = true;
                cam1.Action_Taken__c = false;
                cam1.Proposal_Status__c = 'Accept';
                cam1.Deviation_Created_Date__c = Date.today();
                insert cam1;
                
                Deviation__c dv1 = new Deviation__c();
                dv1.Parent_CAM__c = cam1.Id;
                dv1.Approval_Status__c = 'Approved';
                dv1.Proposal_Status__c = 'Approved';
                dv1.Deviation_Description__c = 'testdesc';
                dv1.Remarks__c = 'Test1';
                dv1.Deviation_Level__c = 'L3';
                dv1.Role__c = 'SH';
                dv1.Type__c = 'Normal Deviation';
                insert dv1;

                Test.startTest();
				IND_DocumentUploadCntrl.checkUserAbleToDeleteDoc(doc1.Id,opp.Id);
                Test.stopTest();
            }
            
        }catch(Exception e){
            System.assertEquals('script-thrown exception', e.getMessage());
        }
    }
     @isTest
    public static void contentDocumentPresentOrNotTest()
    {        
        try{
            Opportunity oppObj = new Opportunity();
            oppObj.Name = 'VDR Test1';
            oppObj.Sanction_Date__c=NULL;
            oppObj.Product_type__C = 'Passenger Vehicles';
            oppObj.StageName = 'Qualification';
            oppObj.CloseDate = Date.today();
            insert oppObj;
                
            Applicant__c apks1 = new Applicant__c();
            apks1.Opportunity__c = oppObj.Id;
            apks1.Contact_number__c = '9743514811';
            apks1.Applicant_Type__c = 'Borrower';
            apks1.In_Active_Applicant__c = false;
            insert apks1;
            
            Documents__c doc2 = new Documents__c();
            doc2.Opportunity_Relation__c = oppObj.Id;
            doc2.Is_active__c = true;
            doc2.Cheque_Number__c=3;
            doc2.Applicant__c=apks1.Id;
            doc2.Name='Chassis Number uploaded during verification';
            doc2.Document_Type__c = 'Customer Image';
            insert doc2;
            
            ContentVersion cvn1 = new ContentVersion();
            cvn1.PathOnClient = 'testpath1';
            cvn1.Title = 'testtitle1';
            cvn1.VersionData = Blob.valueOf('Test Content');
            cvn1.Document_Side_fileupload__c = 'Selfie';
            insert cvn1;
            
            ContentVersion testcd1 = [SELECT id, ContentDocumentId FROM ContentVersion where Id = :cvn1.Id];
            
            ContentDocumentLink cdlink1 = new ContentDocumentLink();
            cdlink1.Visibility = 'AllUsers';
            cdlink1.ShareType = 'V';
            cdlink1.LinkedEntityId = doc2.Id;
            cdlink1.ContentDocumentId = testcd1.ContentDocumentId;
            insert cdlink1; 
            
            Test.startTest();
            IND_DocumentUploadCntrl.contentDocumentPresentOrNot(doc2.Id);
            Test.stopTest();
        }
        catch(Exception e){
            System.assertEquals('script-thrown exception', e.getMessage());
        }
    }
    
     @isTest
    public static void loanApplicationCustomerTypeTest()
    {        
        try{
            Opportunity oppObj = new Opportunity();
            oppObj.Name = 'VDR Test1';
            oppObj.Sanction_Date__c=NULL;
            oppObj.Product_type__C = 'Tractor';
            oppObj.StageName = 'Qualification';
            oppObj.CloseDate = Date.today();
            oppObj.Customer_Type__c = 'Individual';
            insert oppObj;
            
            Test.startTest();
            IND_DocumentUploadCntrl.loanApplicationCustomerType(oppObj.Id);
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals('script-thrown exception', e.getMessage());
        }
    }
    
     @isTest
    public static void loanApplicationproductTypeTest()
    {        
        try{
            Opportunity oppObj = new Opportunity();
            oppObj.Name = 'VDR Test1';
            oppObj.Sanction_Date__c=NULL;
            oppObj.Product_type__C = 'Tractor';
            oppObj.StageName = 'Qualification';
            oppObj.CloseDate = Date.today();
            oppObj.Customer_Type__c = 'Non-Individual';
            insert oppObj;
            
            Test.startTest();
            IND_DocumentUploadCntrl.loanApplicationproductType(oppObj.Id);
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals('script-thrown exception', e.getMessage());
        }
    }
    @isTest
    public static void checkFileSizeTest(){
        Opportunity oppObj = new Opportunity();
            oppObj.Name = 'VDR Test1';
            oppObj.Sanction_Date__c=NULL;
            oppObj.Product_type__C = 'Passenger Vehicles';
            oppObj.StageName = 'Qualification';
            oppObj.CloseDate = Date.today();
            insert oppObj;
                
            Applicant__c apks1 = new Applicant__c();
            apks1.Opportunity__c = oppObj.Id;
            apks1.Contact_number__c = '9743514811';
            apks1.Applicant_Type__c = 'Borrower';
            apks1.In_Active_Applicant__c = false;
            insert apks1;
            
            Documents__c doc2 = new Documents__c();
            doc2.Opportunity_Relation__c = oppObj.Id;
            doc2.Is_active__c = true;
            doc2.Cheque_Number__c=3;
            doc2.Applicant__c=apks1.Id;
            doc2.Name='Chassis Number uploaded during verification';
            doc2.Document_Type__c = 'Customer Image';
            insert doc2;
            
            ContentVersion cvn1 = new ContentVersion();
            cvn1.PathOnClient = 'testpath1';
            cvn1.Title = 'testtitle1';
            cvn1.VersionData = Blob.valueOf('Test Content');
            cvn1.Document_Side_fileupload__c = 'Selfie';
            insert cvn1;
            
            ContentVersion testcd1 = [SELECT id, ContentDocumentId FROM ContentVersion where Id = :cvn1.Id];
            
            ContentDocumentLink cdlink1 = new ContentDocumentLink();
            cdlink1.Visibility = 'AllUsers';
            cdlink1.ShareType = 'V';
            cdlink1.LinkedEntityId = doc2.Id;
            cdlink1.ContentDocumentId = testcd1.ContentDocumentId;
            insert cdlink1; 
        Test.startTest();
            IND_DocumentUploadCntrl.checkFileSize(doc2.Id);
            Test.stopTest();

    }
    
    
    
}