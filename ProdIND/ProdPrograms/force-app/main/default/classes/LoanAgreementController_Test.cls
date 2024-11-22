@isTest
public class LoanAgreementController_Test {
    
    @testSetup 
    static void testDataSetup() 
    {
        
         Integer ranNum1 = Integer.valueOf(Math.Random() * 10);
        Integer ranNum2 = Integer.valueOf(Math.Random() * 10);
        //create user
        Profile p = [SELECT Id FROM Profile WHERE Name='IBL Business Executive'];
        User u = new User(Alias = 'standt2', Email='standarduser2@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,Maker_Id__c='12',IsActive = true,
                          TimeZoneSidKey='America/Los_Angeles',UserName='test_userprod123@indusbank.com.uat',MobilePhone = '9089078967');
        insert u;
        Profile p1 = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u1 = new User(Alias = 'standt21', Email='standarduser21@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing1'+ranNum2, LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p1.Id,Maker_Id__c='123',IsActive = true,
                          TimeZoneSidKey='America/Los_Angeles',UserName='test_user1@indusbank.com.uat',MobilePhone = '9089078967');
        insert u1;
        List<TeleVerification__c> lstTVR =new  list<TeleVerification__c>();
        System.runAs(u) 
        {
            // Create Opportunity
            Opportunity opp = TestDataUtility.createTestOpportunityForOcr(false);
            //opp.StageName = System.Label.Credit_Processing;
            opp.Sub_Stage__c = System.Label.Field_Investigation;
            opp.StageName = 'Post Sanction Checks and Documentation';
            opp.Is_Mobile_Journey_Completed__c = true;
            opp.Vehicle_Type__c = System.Label.used;
            opp.Product_Type__c = System.Label.TwoWheeler;
            opp.Sanction_Status__c = System.Label.nonStp;
            insert opp;    
            
            //Create Deal_Number_Setting__c
            Deal_Number_Setting__c dlNumberSetting= new Deal_Number_Setting__c();
            dlNumberSetting.Name = System.Label.TwoWheeler;
            dlNumberSetting.MDNField1__c ='AB';
            dlNumberSetting.MDNField2__c =2;
            insert dlNumberSetting;
            system.debug('Deal Setting'+ dlNumberSetting);
            
            //create Deal_Number__c
            Deal_Number__c dl = new Deal_Number__c();
            dl.Loan_Application__c = opp.Id;
            dl.DNField1__c = dlNumberSetting.MDNField1__c;
            dl.DNField2__c = String.valueOf(dlNumberSetting.MDNField2__c);
            //dl.Sub_Stage__c = 'test';
            insert dl;
            
            Opportunity opp1 = TestDataUtility.createTestOpportunityForOcr(false);
            //opp.StageName = System.Label.Credit_Processing;
            opp1.Sub_Stage__c = System.Label.Field_Investigation;
            opp1.StageName = 'Post Sanction Checks and Documentation';
            opp1.Is_Mobile_Journey_Completed__c = true;
            opp1.Vehicle_Type__c = System.Label.used;
            opp1.Product_Type__c = 'Passenger Vehicles';
            opp1.Sanction_Status__c = System.Label.nonStp;
            insert opp1;   
            
            Deal_Number__c dl1 = new Deal_Number__c();
            dl1.Loan_Application__c = opp1.Id;
            dl1.DNField1__c = dlNumberSetting.MDNField1__c;
            dl1.DNField2__c = String.valueOf(dlNumberSetting.MDNField2__c);
            //dl1.Sub_Stage__c = 'test';
            insert dl1;
            
            //create Vehicle Details
            Vehicle_Detail__c vd = TestDataUtility.createTestVehicleDetail(false);
            vd.Loan_Application__c = opp.Id;
            vd.Deal_Number__c = dl.Id;
            insert vd;
            
            //Create Case
            Id tvrRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('TVR').getRecordTypeId();
            case objCase = new case();
            objCase.OwnerId = u.Id;
            objCase.Status = 'Pass';
            objCase.Subject = opp.Name+'_TVR';
            objCase.RecordTypeId = tvrRecordTypeId;
            objCase.Loan_Application__c = opp.Id;            
            insert objCase;                   
            
            List<Applicant__c> applicantList = new List<Applicant__c>();
            // Create Applicant__c
            Applicant__c applicant1 = TestDataUtility.createTestApplicantForMFCValuation(false, opp);
            applicant1.Willing_to_open_Bank_Account_with_IIB__c = true;
            applicant1.Applicant_Type__c = 'Borrower';        
            
            // Create Applicant__c
            Applicant__c applicant2 = TestDataUtility.createTestApplicantForMFCValuation(false, opp);
            applicant2.Willing_to_open_Bank_Account_with_IIB__c = true;
            applicant2.Applicant_Type__c = 'Co-Borrower';        
            
            applicantList.add(applicant1);
            applicantList.add(applicant2);
            
            insert applicantList;
               
            //Create Televerification
            TeleVerification__c objTVR1 = new TeleVerification__c(); 
            objTVR1.Name = '_TVR';
            objTVR1.Case__c = objCase.Id;         
            objTVR1.RecordTypeId = Schema.SObjectType.TeleVerification__c.getRecordTypeInfosByName().get('Post-Sanction').getRecordTypeId();               
            objTVR1.Applicant__c = applicant1.id;
            objTVR1.Loan_Application__c = opp.Id;
            lstTVR.add(objTVR1); 
            
            TeleVerification__c objTVR2 = new TeleVerification__c(); 
            objTVR2.Name = '_TVR';
            objTVR2.Case__c = objCase.Id;         
            objTVR2.RecordTypeId = Schema.SObjectType.TeleVerification__c.getRecordTypeInfosByName().get('Pre-Sanction').getRecordTypeId();               
            objTVR2.Applicant__c = applicant2.id;
            objTVR2.Loan_Application__c = opp.Id;
            lstTVR.add(objTVR2);   
            insert lstTVR;
            
            //Create Invoice Details 
            Invoice_Details__c invoice = new Invoice_Details__c();
            invoice.Loan_Application__c = opp.Id;
            invoice.Invoice_Amount_incl_discounts__c=1000;
            invoice.Tax_Invoice_Date__c = System.today();
            insert invoice;
            
            //Create Final Term
            Final_Term__c ft = new Final_Term__c();
            ft.Loan_Application__c = opp.Id;
            ft.Loan_Amount__c='100000';
            insert ft;    
            
            // Create Document
            Documents__c doc1 = TestDataUtility.createTestKYCDocsForOcrFront(false, applicant1, opp);
            doc1.Document_Type__c = 'Agreement Copy';
            doc1.Addresss_Type__c = System.Label.Document_Office_Address_Type;
            doc1.Is_Active__c = true;
            doc1.Name = 'IHM Receipt';
            doc1.Aadhar_Source__c = 'OTP';
            insert doc1;
            
            //Create Loan Application Transaction History
            Loan_Application_Transaction_History__c loanAppHis = new Loan_Application_Transaction_History__c(Name = System.Label.IHM,
                                                                                                             Deal_Number__c = dl.Id,
                                                                                                             Screen__c = System.Label.IHM,
                                                                                                             Module__c = System.Label.Post_Sanction_Checks_and_Documentation,
                                                                                                             Submitted_Flag__c = true,
                                                                                                             Loan_Application_ID__c = opp.Id);
            insert loanAppHis;
            
            //create Bl_Code_Details 
			Bl_Code_Details__c BlCodeDetails = new Bl_Code_Details__c(Bl_Code__c = 'Test');
            insert BlCodeDetails;
            
            //Create Bank Branch Details
            BankBranchDetails__c bankBranchDetails = new BankBranchDetails__c(UniqueIdentifier__c = 'test', Bl_Code_Details__c = BlCodeDetails.Id);
            insert bankBranchDetails;          
            
            // Create Loan agreement        
            Loan_Agreement__c la = new Loan_Agreement__c(e_agreement_Agreement_Signed_For_Borrowe__c = 'Yes', 
                                                         Loan_Application__c = opp.Id, Agreement_Type__c = 'Physical agreement',Existing_LA_Stamped_For__c = 'ITM00101');
            insert la;
            
            //Create Stamp Detail
            List<Stamp_Detail__c> stampingList = new List<Stamp_Detail__c>();
            Stamp_Detail__c stampDetail1 = new Stamp_Detail__c(Stamp_Date__c = System.today(), Type__c = 'Loan Agreement', Loan_Agreement__c = la.Id); 
            Stamp_Detail__c stampDetail2 = new Stamp_Detail__c(Stamp_Date__c = System.today(), Type__c = 'Additional LA', Loan_Agreement__c = la.Id); 
            stampingList.add(stampDetail1);
            stampingList.add(stampDetail2);
            insert stampingList;
        }             
    }
    
    @isTest
    public static void isRequiredStageCompletedTest1()
    {                                
        Test.startTest();
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            Opportunity opp = [Select Id from Opportunity LIMIT 1];
            Deal_Number__c deal = [select id from Deal_Number__c where Loan_Application__c = :opp.Id];
            String result = LoanAgreementController.isRequiredStageCompleted(opp.Id, deal.Id);
            System.assertNotEquals(null,result);
        }
        Test.stopTest();                     
    }
    
    @isTest
    public static void isRequiredStageCompletedTest2()
    {               
        Test.startTest();
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            Opportunity opp = [Select Id from Opportunity LIMIT 1];
            opp.Vehicle_Type__c = 'New';
            update opp;
            Deal_Number__c deal = [select id from Deal_Number__c where Loan_Application__c = :opp.Id];
            
            LoanAgreementController.isRequiredStageCompleted(opp.Id,deal.Id);
            
        }
        Test.stopTest();                     
    }
    
    @isTest
    public static void isPreDisbursementLASubmittedTest1()
    {                                
        Test.startTest();
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            Opportunity opp = [Select Id from Opportunity LIMIT 1];
            Loan_Application_Transaction_History__c loanAppHis = [Select Id, Submitted_Flag__c, Name, Screen__c, Module__c
                                                                  From Loan_Application_Transaction_History__c Where 
                                                                  Loan_Application_ID__c =: opp.Id LIMIT 1];
            loanAppHis.Name = 'Loan Agreement';
            loanAppHis.Screen__c = 'Loan Agreement';
            loanAppHis.Module__c = 'Pre Disbursement Check';
            update loanAppHis; 
            
            Deal_Number__c deal = [select id from Deal_Number__c where Loan_Application__c = :opp.Id];
            LoanAgreementController.isPreDisbursementLASubmitted(opp.Id,deal.Id);
            
        }
        Test.stopTest();                     
    }
    
    @isTest
    public static void isPreDisbursementLASubmittedTest2()
    {     
        try{
        Test.startTest();        
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            Opportunity opp = [select id from Opportunity limit 1];
            Deal_Number__c deal = [select id from Deal_Number__c where Loan_Application__c = :opp.Id];
            
            LoanAgreementController.isPreDisbursementLASubmitted(opp.Id, deal.Id);
          
        }
        Test.stopTest();    
        }catch(Exception e){
            system.debug('e'+e.getMessage());
        }
    }
    
    @isTest
    public static void isPostSanctionLASubmittedTest1()
    {                                
        Test.startTest();
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            Opportunity opp = [Select Id from Opportunity LIMIT 1];
            Loan_Application_Transaction_History__c loanAppHis = [Select Id, Submitted_Flag__c, Name, Screen__c, Module__c
                                                                  From Loan_Application_Transaction_History__c Where 
                                                                  Loan_Application_ID__c =: opp.Id LIMIT 1];
            loanAppHis.Name = 'Loan Agreement';
            loanAppHis.Screen__c = 'Loan Agreement';
            loanAppHis.Module__c = 'Post Sanction Checks and Documentation';
            update loanAppHis; 
            
            Deal_Number__c deal = [select id from Deal_Number__c where Loan_Application__c = :opp.Id];
            
            boolean result = LoanAgreementController.isPostSanctionLASubmitted(opp.Id, deal.Id);
            System.assertNotEquals(null,result);
        }
        Test.stopTest();                     
    }
    
    @isTest
    public static void isPostSanctionLASubmittedTest2()
    {                                
        Test.startTest();    
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            boolean result = LoanAgreementController.isPostSanctionLASubmitted(null,null);
            System.assertNotEquals(null,result);
        }
        Test.stopTest();                     
    }
    
    @isTest
    public static void updateLoanTransacionToSubmittedTest1()
    {                                
        Test.startTest();
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            Opportunity opp = [Select Id from Opportunity LIMIT 1];
            Loan_Application_Transaction_History__c loanAppHis = [Select Id, Submitted_Flag__c, Name, Screen__c, Module__c
                                                                  From Loan_Application_Transaction_History__c Where 
                                                                  Loan_Application_ID__c =: opp.Id LIMIT 1];
            loanAppHis.Name = 'Loan Agreement';
            loanAppHis.Screen__c = 'Loan Agreement';
            loanAppHis.Module__c = 'Post Sanction Checks and Documentation';
            loanAppHis.Submitted_Flag__c= false;
            update loanAppHis;
            
            Deal_Number__c deal = [select id from Deal_Number__c where Loan_Application__c = :opp.Id];
            
            System.debug('loanAppHis'+loanAppHis);
            boolean result = LoanAgreementController.updateLoanTransacionToSubmitted(opp.Id, deal.Id);
            System.assertNotEquals(null,result);
        }
        Test.stopTest();                     
    }    
    
    @isTest
    public static void updateLoanTransacionToSubmittedTest2()
    {                                
        Test.startTest();  
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            boolean result = LoanAgreementController.updateLoanTransacionToSubmitted(null,null);
            System.assertNotEquals(null,result);
        }
        Test.stopTest();                     
    }        
    
    @isTest
    public static void updateLoanTransacionHistoryToSubmittedTest1()
    {                                
        Test.startTest();
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            Opportunity opp = [Select Id from Opportunity LIMIT 1];
            Loan_Application_Transaction_History__c loanAppHis = [Select Id, Submitted_Flag__c, Name, Screen__c, Module__c
                                                                  From Loan_Application_Transaction_History__c Where 
                                                                  Loan_Application_ID__c =: opp.Id LIMIT 1];
            loanAppHis.Name = 'Loan Agreement';
            loanAppHis.Screen__c = 'Loan Agreement';
            loanAppHis.Module__c = 'Pre Disbursement Check';
            loanAppHis.Submitted_Flag__c = false;
            update loanAppHis; 
            
            Deal_Number__c deal = [select id from Deal_Number__c where Loan_Application__c = :opp.Id];
            
            boolean result = LoanAgreementController.updateLoanTransacionHistoryToSubmitted(opp.Id, deal.Id);
            System.assertNotEquals(null,result);
        }
        Test.stopTest();                     
    }
    
    @isTest
    public static void updateLoanTransacionHistoryToSubmittedTest2()
    {                                
        Test.startTest();    
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            boolean result = LoanAgreementController.updateLoanTransacionHistoryToSubmitted(null,null);
            System.assertNotEquals(null,result);
        }
        Test.stopTest();                     
    }
    
    @isTest
    public static void getLoanAgreementTest1(){
        try{                
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {
                Opportunity opp = [Select Id,Product_Type__c from Opportunity LIMIT 1];
                Deal_Number__c deal = [select id from Deal_Number__c where Loan_Application__c = :opp.Id];
                
                LoanAgreementController.getLoanAgreement(opp.Id, deal.Id);
                
                opp.Product_Type__c = 'Tractor';
                update opp;
                
                LoanAgreementController.getLoanAgreement(opp.Id, deal.Id);
                
            }
            Test.stopTest();
        }catch(Exception e){
            system.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void getLoanAgreementTest2()
    {
        try
        {                
            Test.startTest();   
            User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {
                LoanAgreementController.getLoanAgreement(null,null);
            }
            Test.stopTest();
        }
        catch(Exception e)
        {
            system.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
     @isTest
    public static void getLoanAgreementTest3(){
        try{                
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {
                Opportunity opp = [Select Id,Product_Type__c from Opportunity LIMIT 1];
                Deal_Number__c deal = [select id from Deal_Number__c where Loan_Application__c = :opp.Id];
                
                Applicant__c applicant1 = new Applicant__c();
                applicant1.Opportunity__c = opp.Id;
                applicant1.Willing_to_open_Bank_Account_with_IIB__c = true;
                applicant1.Applicant_Type__c = System.Label.Borrower; 
                insert applicant1;
                
                Documents__c  dfks1 = new Documents__c();
                 dfks1.Applicant__c = applicant1.Id;
                 dfks1.Opportunity_Relation__c = opp.Id;
                 dfks1.Document_Type__c = 'Form 60';
                 dfks1.KYC_name__c = 'Aadhar';
                 dfks1.Document_Side__c ='Back';
                 dfks1.Aadhar_Source__c = 'ScanAadhar';
                 dfks1.Name = 'Aadhar';
                 dfks1.is_Active__c = true;
                 insert dfks1;
                
                LoanAgreementController.getLoanAgreement(opp.Id, deal.Id);
                
                opp.Product_Type__c = 'Tractor';
                update opp;
                
                LoanAgreementController.getLoanAgreement(opp.Id, deal.Id);
                
            }
            Test.stopTest();
        }catch(Exception e){
            system.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    @isTest
    public static void getLoanAgreementTest4(){
        try{                
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {
                Opportunity opp = [Select Id,Product_Type__c from Opportunity LIMIT 1];
                Deal_Number__c deal = [select id from Deal_Number__c where Loan_Application__c = :opp.Id];
                
                Applicant__c applicant1 = new Applicant__c();
                applicant1.Opportunity__c = opp.Id;
                applicant1.Willing_to_open_Bank_Account_with_IIB__c = true;
                applicant1.Applicant_Type__c = System.Label.CoBorrower; 
                insert applicant1;
                
                Documents__c  dfks1 = new Documents__c();
                 dfks1.Applicant__c = applicant1.Id;
                 dfks1.Opportunity_Relation__c = opp.Id;
                 dfks1.Document_Type__c = 'Form 60';
                 dfks1.KYC_name__c = 'Aadhar';
                 dfks1.Document_Side__c ='Back';
                 dfks1.Aadhar_Source__c = 'ScanAadhar';
                 dfks1.Name = 'Aadhar';
                 dfks1.is_Active__c = true;
                 insert dfks1;
                
                LoanAgreementController.getLoanAgreement(opp.Id, deal.Id);
                
                opp.Product_Type__c = 'Tractor';
                update opp;
                
                LoanAgreementController.getLoanAgreement(opp.Id, deal.Id);
                
            }
            Test.stopTest();
        }catch(Exception e){
            system.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    
    @isTest
    public static void loanAgreementControllerTest(){
        try{               
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {
                Opportunity opp = [Select Id from Opportunity LIMIT 1];
                LoanAgreementController lc=new LoanAgreementController(opp.Id); 
                LoanAgreementController lc1=new LoanAgreementController(null); 
            }
            Test.stopTest();
        }catch(Exception e){
            system.assertEquals('Script-thrown exception', e.getMessage());
        }
    }          
    
    @isTest
    public static void getTeleVerificationDetailsTest1()
    {                                
        Test.startTest();
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            Opportunity opp = [Select Id from Opportunity LIMIT 1];
            LoanAgreementController lc=new LoanAgreementController(opp.Id); 
            List<TeleVerification__c> result = lc.getTeleVerificationDetails(opp.Id);
            System.assertNotEquals(null,result);
        }
        Test.stopTest();                     
    }
    
    @isTest
    public static void getTeleVerificationDetailsTest2()
    {                                
        Test.startTest();    
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            Opportunity opp = [Select Id from Opportunity LIMIT 1];
            LoanAgreementController lc=new LoanAgreementController(opp.Id); 
            List<TeleVerification__c> result = lc.getTeleVerificationDetails(null);
            System.assertEquals(null,result);
        }
        Test.stopTest();                     
    }
    
    @isTest
    public static void getGeoGraphicalStateTest()
    {                                
        try{
        Test.startTest();   
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            Opportunity opp = [Select Id from Opportunity LIMIT 1];
            String result1 = LoanAgreementController.getGeoGraphicalState(opp.Id);
            System.assertNotEquals(null,result1);
            Opportunity opp1 = [Select Id from Opportunity  where Product_Type__c = 'Passenger Vehicles' LIMIT 1];
            String result2 = LoanAgreementController.getGeoGraphicalState(opp1.Id);
            System.assertNotEquals(null,result2);
        }
        Test.stopTest();                     
        }catch(Exception e){
            System.debug(e.getMessage());
        }
    }
    
     @isTest
    public static void getGeoGraphicalStateTest2()
    {                                
        try{
        Test.startTest();   
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            Opportunity opp = [Select Id from Opportunity LIMIT 1];
            String result1 = LoanAgreementController.getGeoGraphicalState(opp.Id);
            System.assertNotEquals(null,result1);
            opp.Product_Type__c = System.Label.Tractor;
            update opp;
            //Opportunity opp1 = [Select Id from Opportunity  where Product_Type__c = 'Passenger Vehicles' LIMIT 1];
            String result2 = LoanAgreementController.getGeoGraphicalState(opp.Id);
            System.assertNotEquals(null,result2);
        }
        Test.stopTest();                     
        }catch(Exception e){
            System.debug(e.getMessage());
        }
    }
    
    @isTest
    public static void getTaxInvoiceDateTest1()
    {                                
        Test.startTest();
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            Opportunity opp = [Select Id,Product_Type__c from Opportunity LIMIT 1];  
            Deal_Number__c deal = [select id from Deal_Number__c where Loan_Application__c = :opp.Id];
            
            Date result = LoanAgreementController.getTaxInvoiceDate(opp.Id, deal.Id);
            System.assertNotEquals(null,result);
            
            opp.Product_Type__c = 'Tractor';
            update opp;
            
            Date result1 = LoanAgreementController.getTaxInvoiceDate(opp.Id, deal.Id);
        }
        Test.stopTest();                     
    }
    
    @isTest
    public static void getTaxInvoiceDateTest2()
    {
        try{
            Test.startTest();  
            User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {
                Date result = LoanAgreementController.getTaxInvoiceDate(null, null);
                System.assertEquals(null,result);
            }
            Test.stopTest(); 
        
        }catch(Exception e){
            System.debug(e.getMessage());
        }
         
                            
    }
    
    @isTest
    public static void getAdvancedEMITest1()
    {                                
        Test.startTest();
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            Opportunity opp = [Select Id,Product_Type__c from Opportunity LIMIT 1];
            Deal_Number__c deal = [select id from Deal_Number__c where Loan_Application__c = :opp.Id];
            
            Final_Term__c result = LoanAgreementController.getAdvancedEMI(opp.Id, deal.Id);
            System.assertNotEquals(null,result);
            
            opp.Product_Type__c = 'Tractor';
            update opp;
            
            Vehicle_Detail__c vd = [select id from Vehicle_Detail__c where Loan_Application__c = :opp.Id];
            
            Final_Term__c finalTerm = [select id,Vehicle_Detail__c from Final_Term__c where Loan_Application__c = :opp.Id];
            finalTerm.Vehicle_Detail__c = vd.Id;
            update finalTerm;
            
            Final_Term__c result1 = LoanAgreementController.getAdvancedEMI(opp.Id, deal.Id);
        }
        Test.stopTest();                     
    }
    
    @isTest
    public static void getAdvancedEMITest2()
    { 
        try{
            Test.startTest();      
            User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {
                Final_Term__c result = LoanAgreementController.getAdvancedEMI(null,null);
                System.assertEquals(null,result);
            }
            Test.stopTest();   
            
        
        }catch(Exception e){
            System.debug(e.getMessage());
        }
                          
    }
    
    @isTest
    public static void getStampingDetailsTest1()
    {                   
        try{
        Test.startTest();
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_user1@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            Opportunity opp = [Select Id from Opportunity LIMIT 1]; 
            Loan_Agreement__c la = [Select Id from Loan_Agreement__c Where Loan_Application__c =: opp.Id LIMIT 1];
            LoanAgreementController.StampingList result = LoanAgreementController.getStampingDetails(la.Id, opp.Id);
            System.assertNotEquals(null,result);
        }
        User u1 = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u1) 
        {
            Opportunity opp = [Select Id from Opportunity LIMIT 1]; 
            Loan_Agreement__c la = [Select Id from Loan_Agreement__c Where Loan_Application__c =: opp.Id LIMIT 1];
            LoanAgreementController.StampingList result = LoanAgreementController.getStampingDetails(la.Id, opp.Id);
            System.assertNotEquals(null,result);
        }
        Test.stopTest(); 
        }catch(Exception e){
            System.debug(e.getMessage());
        }
    }
    
    @isTest
    public static void getStampingDetailsTest2()
    {                   
        try{
            Test.startTest();     
            User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {
                LoanAgreementController.StampingList result = LoanAgreementController.getStampingDetails('test', 'test1');
                
            }
            Test.stopTest(); 
        }catch(Exception e){
            System.debug(e.getMessage());
        }
    }
    
    @isTest
    public static void getStampingList()
    {                   
        try{
            Test.startTest();     
            User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {
                LoanAgreementController.StampingList stpList = new LoanAgreementController.StampingList();
                stpList.existingStamping = new List<Stamp_Detail__c>();
				stpList.additionalStamping = new List<Stamp_Detail__c>();
                stpList.totalStampingOfExistingLA = 0.2;
                stpList.totalStampingOfAdditionalLA = 0.0;
                stpList.totalStampingDone = 0.9;
            }
            Test.stopTest(); 
        }catch(Exception e){
            System.debug(e.getMessage());
        }
    }
    
    @isTest
    public static void insertAdditionalStampingsTest()
    {            
        try{
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {
                Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1]; 
                Loan_Agreement__c la = [SELECT Id, 
                                        (SELECT Stamp_S_No__c,Stamp_Towards__c,Stamp_Type__c,Stamp_Value__c,
                                         Stamp_Date__c,Stamp_For__c,Type__c,Stamp_Location_Type__c FROM Stamp_Details__r) 
                                        FROM Loan_Agreement__c WHERE Loan_Application__c =: opp.Id LIMIT 1];
                LoanAgreementController.insertAdditionalStampings(JSON.serialize(la.Stamp_Details__r), la.Id);
                LoanAgreementController.insertAdditionalStampings('test',null);
                Loan_Agreement__c result = [SELECT Id, Is_Additional_Loan_Agreement_Stamp_Duty__c                                    
                                        FROM Loan_Agreement__c WHERE Loan_Application__c =: opp.Id AND Is_Additional_Loan_Agreement_Stamp_Duty__c = true LIMIT 1];
                System.assertNotEquals(null,result);
            }
            Test.stopTest();
        }catch(Exception e){
            System.debug(e.getMessage());
        }
    }
    
    /*@isTest
    public static void getResponseTest()
    {                                
        Test.startTest();     
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            String result = LoanAgreementController.getResponse();
            System.assertNotEquals(null,result);
        }
        Test.stopTest();                     
    } */
    
    @isTest
    public static void getAgreementBookletDetailsTest()
    {                                
        Test.startTest();
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            try
            {
                Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1]; 
                Loan_Agreement__c la = [SELECT Id FROM Loan_Agreement__c WHERE Loan_Application__c =: opp.Id LIMIT 1];
                String response = '{"response":{"status":"SUCCESS","respDesc":"Get Agreement Booklet No Details","content":[{"Stamp_S_No":"","Stamp_On":null,"Stamp_Printed_Location_Blcode":"GNC","Stamp_Printed_Location_BlName":"GNC BRANCH","Stamp_Type":"AST","Stamp_Value":"100.0000","Stamped_For":"ITM00101","Stamp_Towards":"AGREEMENT"}]}}';
                Deal_Number__c deal = [select id from Deal_Number__c where Loan_Application__c = :opp.Id];
                System.debug('response--'+response);
                LoanAgreementController.getAgreementBookletDetails(response, la.Id, opp.Id, '12345',deal.Id);
                
            }
            catch(Exception e)
            {
                system.assertEquals('Script-thrown exception', e.getMessage());
            }
            
            //System.assertNotEquals(null,result);
        }
        Test.stopTest();                     
    }
    
    @isTest
    public static void getDocumentDataTest1()
    {                                
        Test.startTest();
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            try{
                Opportunity opp = [Select Id,Product_Type__c from Opportunity LIMIT 1];
                Deal_Number__c deal = [select id from Deal_Number__c where Loan_Application__c = :opp.Id];
                List<Documents__c> result = LoanAgreementController.getDocumentData(opp.Id, deal.Id);
                System.assertNotEquals(null,result);
                
                opp.Product_Type__c = 'Tractor';
                update opp;
                
                List<Documents__c> result1 = LoanAgreementController.getDocumentData(opp.Id, deal.Id);
            }catch(Exception e){
                System.debug(e.getMessage());
            }
        }
        Test.stopTest();                     
    }
    
    @isTest
    public static void getDocumentDataTest2()
    {
        try{
            Test.startTest();  
            User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {
                List<Documents__c> result = LoanAgreementController.getDocumentData(null, null);
                System.assertEquals(null,result);
            }
            Test.stopTest();    
        }
        catch(exception e){
            System.debug(e.getMessage());
        }
                        
    }
    
    @isTest
    public static void currentUserProfileTest()
    {      
        try{
        Test.startTest();
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
      //  System.runAs(u) 
      //  {            
            String result1 = LoanAgreementController.currentUserProfile(UserInfo.getUserId());
            System.assertNotEquals(null,result1);
            String result2 = LoanAgreementController.currentUserProfile(null);
            LoanAgreementController.currentUserProfile('test');
            System.assertEquals(null,result2);
     //   }
        Test.stopTest(); 
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    @isTest
    public static void deleteLoanAgreementDetailsTest(){
        
        Test.startTest();
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {        
            Opportunity opp = [SELECT Id,Product_Type__c FROM Opportunity LIMIT 1]; 
            List<Loan_Agreement__c> la = [SELECT Id FROM Loan_Agreement__c WHERE Loan_Application__c =: opp.Id LIMIT 1];
            Deal_Number__c deal = [select id from Deal_Number__c where Loan_Application__c = :opp.Id];
            
            LoanAgreementController.deleteLoanAgreementDetails(opp.Id,'12345', deal.Id);
            Boolean returnObj = LoanAgreementController.getAPIsCalloutResponse(opp.Id);
            
           
        }
        Test.stopTest();
    }
    
     @isTest
    public static boolean getAPIsCalloutResponseTest(){
        
        Test.startTest();
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {        
            Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1]; 
            LoanAgreementController.getAPIsCalloutResponse(opp.Id);
        }
        Test.stopTest();
        return true;
    }
    @isTest
    public static boolean validateScannedDocsTest(){
        
        Test.startTest();
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {        
            Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1]; 
            Deal_Number__c deal = [select id from Deal_Number__c where Loan_Application__c = :opp.Id];
            Boolean returnVal = LoanAgreementController.validateScannedDocs(opp.Id, deal.Id);
            System.assertEquals(false, returnVal);
        }
        Test.stopTest();
        return true;
    }
    
    @isTest
    public static boolean isEmiDatesCapturedInBackendTest(){
        
        Test.startTest();
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {        
            Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1]; 
            Deal_Number__c deal = [select id from Deal_Number__c where Loan_Application__c = :opp.Id];
            Boolean returnVal = LoanAgreementController.isEmiDatesCapturedInBackend(opp.Id, deal.Id);
            System.assertEquals(false, returnVal);
            
            opp.Product_Type__c = 'Tractor';
            update opp;
            
            Boolean returnVal1 = LoanAgreementController.isEmiDatesCapturedInBackend(opp.Id, deal.Id);
            System.assertEquals(false, returnVal1);
        }
        Test.stopTest();
        return true;
    }
    
    
    @isTest
    public static void isEAgreementAPIsSuccessTest(){
        
        Test.startTest();
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {        
            Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1]; 
            try{
            	LoanAgreementController.EagreementAPIsStatusWrapper returnVal = LoanAgreementController.isEAgreementAPIsSuccess(opp.Id);
            }catch(Exception e){
                System.debug('Error'+e.getMessage());
            }
        }
        Test.stopTest();
    }
        
    @isTest
    public static boolean checkApiCalloutStatusTest(){
        
        Test.startTest();
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u)  
        {        
            Opportunity opp = [SELECT Id,Product_Type__c FROM Opportunity LIMIT 1]; 
            Loan_Agreement__c la = [Select Id From Loan_Agreement__c Where Loan_Application__c =: opp.Id LIMIT 1];
            Deal_Number__c deal = [select id from Deal_Number__c where Loan_Application__c = :opp.Id];
            LoanAgreementController.APIStatusWrapper returnVal = LoanAgreementController.checkApiCalloutStatus(opp.Id, la.Id, deal.Id);
            System.assertNotEquals(null, returnVal);
            
            opp.Product_Type__c = 'Tractor';
            update opp;
            
            LoanAgreementController.APIStatusWrapper returnVal1 = LoanAgreementController.checkApiCalloutStatus(opp.Id, la.Id, deal.Id);
        }
        Test.stopTest();
        return true;
    }
    
    @isTest
    public static void getGeoGraphicalStateTest3(){
        try{
            Opportunity opks1 = new Opportunity();
                opks1.StageName = 'Qualification';
                opks1.CloseDate = Date.newInstance(2021, 1, 11);
                opks1.Name = 'testone';
                opks1.Agent_BL_code__c = 'AG-00';
                opks1.Product_Type__c = 'Two Wheeler';
                insert opks1;
                
                Applicant__c apks1 = new Applicant__c();
                apks1.Opportunity__c = opks1.Id;
                apks1.Contact_number__c = '9743514830';
                apks1.Applicant_Type__c = 'Borrower';
                insert apks1;
        
                Bl_Code_Details__c bcd1 = new Bl_Code_Details__c();
              //  bcd1.Address_1__c = 'testadd';
              //  bcd1.Address_2__c = 'testadd2';
                bcd1.Bl_Code__c = opks1.Agent_BL_code__c;
                bcd1.Name = 'test';
                insert bcd1;
        
                Geo_State_Masters__c gm1 = new Geo_State_Masters__c();
                gm1.NeSL_State_Code__c = 'test';
                gm1.OwnerId = UserInfo.getUserId();
                gm1.Pincode_Starting_Max__c = 524;
                gm1.Pincode__c = 315;
                gm1.Name = 'allur';
                gm1.State_Code__c = '01';
                insert gm1;
        
                District_Master__c dm1 = new District_Master__c();
                dm1.Name = 'nellore';
                dm1.District_Code__c = 74;
                dm1.OwnerId = Userinfo.getUserId();
                dm1.Geo_State_Master__c = gm1.Id;
                insert dm1;
        
                BankBranchDetails__c bd1 = new BankBranchDetails__c();
                bd1.Bl_Code_Details__c = bcd1.Id;
                bd1.Geo_State_Master__c = gm1.Id;
             //   bd1.District_Master__c = dm1.Id;
                bd1.Address_1__c = 'testad1';
                bd1.Address_2__c = 'testad2';
                bd1.UniqueIdentifier__c = '201';
                bd1.District__c = 'nellore';
             //   bd1.Geo_State_Code__c = '202';
                bd1.Product__c = 'H';
                insert bd1;
            
                 Test.startTest();
                       LoanAgreementController.getGeoGraphicalState(opks1.Id);
            LoanAgreementController.getGeoGraphicalState(null);
                 Test.stopTest();
            
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void getGeoGraphicalStateTest4(){
        try{
            Opportunity opks1 = new Opportunity();
                opks1.StageName = 'Qualification';
                opks1.CloseDate = Date.newInstance(2021, 1, 11);
                opks1.Name = 'testone';
                opks1.Agent_BL_code__c = 'AG-00';
                opks1.Product_Type__c = 'Passenger Vehicles';
                insert opks1;
                
                Applicant__c apks1 = new Applicant__c();
                apks1.Opportunity__c = opks1.Id;
                apks1.Contact_number__c = '9743514830';
                apks1.Applicant_Type__c = 'Borrower';
                insert apks1;
        
                Bl_Code_Details__c bcd1 = new Bl_Code_Details__c();
              //  bcd1.Address_1__c = 'testadd';
              //  bcd1.Address_2__c = 'testadd2';
                bcd1.Bl_Code__c = opks1.Agent_BL_code__c;
                bcd1.Name = 'test';
                insert bcd1;
        
                Geo_State_Masters__c gm1 = new Geo_State_Masters__c();
                gm1.NeSL_State_Code__c = 'test';
                gm1.OwnerId = UserInfo.getUserId();
                gm1.Pincode_Starting_Max__c = 524;
                gm1.Pincode__c = 315;
                gm1.Name = 'allur';
                gm1.State_Code__c = '01';
                insert gm1;
        
                District_Master__c dm1 = new District_Master__c();
                dm1.Name = 'nellore';
                dm1.District_Code__c = 74;
                dm1.OwnerId = Userinfo.getUserId();
                dm1.Geo_State_Master__c = gm1.Id;
                insert dm1;
        
                BankBranchDetails__c bd1 = new BankBranchDetails__c();
                bd1.Bl_Code_Details__c = bcd1.Id;
                bd1.Geo_State_Master__c = gm1.Id;
             //   bd1.District_Master__c = dm1.Id;
                bd1.Address_1__c = 'testad1';
                bd1.Address_2__c = 'testad2';
                bd1.UniqueIdentifier__c = '201';
                bd1.District__c = 'nellore';
             //   bd1.Geo_State_Code__c = '202';
                bd1.Product__c = 'C';
                insert bd1;
            
                 Test.startTest();
                       LoanAgreementController.getGeoGraphicalState(opks1.Id);
                 Test.stopTest();
            
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void validateScannedDocsTest1(){
        try{
            Opportunity opks1 = new Opportunity();
                opks1.StageName = 'Qualification';
                opks1.CloseDate = Date.newInstance(2021, 1, 11);
                opks1.Name = 'testone';
            	opks1.Product_Type__c = 'Tractor';
                insert opks1;
                
            Deal_Number__c deal = [select id,Loan_Application__c from Deal_Number__c limit 1];
            deal.Loan_Application__c = opks1.Id;
            update deal;
                
            Vehicle_Detail__c vd1 = [select Id,Loan_Application__c,Deal_Number__c from Vehicle_Detail__c limit 1];
            //vd1.Loan_Application__c = opks1.Id;
            vd1.Deal_Number__c = deal.Id;
            update vd1;
            
                Applicant__c apks1 = new Applicant__c();
                apks1.Opportunity__c = opks1.Id;
                apks1.Contact_number__c = '9743514830';
                apks1.Applicant_Type__c = 'Borrower';
                apks1.In_Active_Applicant__c = false;
                apks1.DocAuth_Application_Id__c = 'testauth';
                apks1.Selfie_Upload__c = true;
                insert apks1;
                
                Documents__c  dfks1 = new Documents__c();
                 dfks1.Applicant__c = apks1.Id;
                 dfks1.Opportunity_Relation__c = opks1.Id;
                 dfks1.Document_Type__c = 'Agreement Copy';
                 dfks1.KYC_name__c = 'Aadhar';
                 dfks1.Document_Side__c ='Back';
                 dfks1.Aadhar_Source__c = 'ScanAadhar';
                 dfks1.Name = 'Aadhar';
                 dfks1.is_Active__c = true;
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
                       LoanAgreementController.validateScannedDocs(opks1.Id, deal.Id);
                       //LoanAgreementController.validateScannedDocs('test','test');
                       //LoanAgreementController.validateScannedDocs(null,null);
                 Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void TestGetLoanapplicationHistory()
    {
        try{
            Opportunity opp = [select id from Opportunity limit 1];
            Loan_Application_Transaction_History__c loanApp = [select id,screen__C from Loan_Application_Transaction_History__c];
            loanApp.screen__C = 'Loan Agreement';
            update loanApp;
            Test.startTest();
            	LoanAgreementController.GetLoanapplicationHistory(opp.Id);
            	LoanAgreementController.GetLoanapplicationHistory(null);
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void TestgetLoanApplication()
    {
        try{
            Opportunity opp = [select id from Opportunity limit 1];
            Test.startTest();
            	LoanAgreementController.getLoanApplication(opp.Id);
            	LoanAgreementController.getLoanApplication(null);
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void TestgetTVRDetails()
    {
        try{
            Opportunity opp = [select id from Opportunity limit 1];
            Test.startTest();
            	LoanAgreementController.getTVRDetails(opp.Id);
            	LoanAgreementController.getTVRDetails(null);
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
}