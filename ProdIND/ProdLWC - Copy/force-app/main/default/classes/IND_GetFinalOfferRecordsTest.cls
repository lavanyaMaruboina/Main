@isTest(SeeAllData=false)
public with sharing class IND_GetFinalOfferRecordsTest {
    
    public class OtherException extends Exception{
        public string name;
    }
    @testSetup
    static void testDataSetup()
    {
        //create user
        Profile p = [SELECT Id FROM Profile WHERE Name='IBL CVO'];
        User u = new User(Alias = 'standt2', Email='standarduser2@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,Maker_Id__c='12',IsActive = true,
                          TimeZoneSidKey='America/Los_Angeles',UserName='test_userprod125@indusbank.com',MobilePhone = '9089078967');
        insert u;
        Profile p1 = [SELECT Id FROM Profile WHERE Name='IBL Operation Head'];
        User u1 = new User(Alias = 'standt23', Email='standarduser23@testorg.com',
                           EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                           LocaleSidKey='en_US', ProfileId = p1.Id,Maker_Id__c='1256',IsActive = true,
                           TimeZoneSidKey='America/Los_Angeles',UserName='test_userprod15@indusbank.com',MobilePhone = '9089078967');
        insert u1;
        System.debug(u1);
        System.runAs(u)
        {
            // Create Opportunity
            Opportunity opp = TestDataUtility.createTestOpportunityForOcr(false);
            //opp.StageName = System.Label.Credit_Processing;
            opp.Sub_Stage__c = System.Label.Field_Investigation;
            opp.Is_Mobile_Journey_Completed__c = true;
            opp.Vehicle_Type__c = System.Label.used;
            opp.Product_Type__c = System.Label.TwoWheeler;
            opp.Sanction_Status__c = System.Label.nonStp;
            insert opp;
            //final Term Insert
            Final_Term__c finaltermObj = new Final_Term__c();
            finaltermObj.Loan_Application__c = opp.Id;
            finaltermObj.Loan_Amount__c = '100000';
            insert finaltermObj;
            //Create Repayment
            Repayments__c repay = TestDataUtility.createTestRepayments(false, opp);
            repay.Is_Netbanking_available_with_customer__c = 'Yes';
            repay.EMl_Amt_Is_filled_correctly__c = 'Yes';
            insert repay;
            // Create Applicant__c
            Applicant__c applicant = TestDataUtility.createTestApplicantForMFCValuation(false, opp);
            applicant.Willing_to_open_Bank_Account_with_IIB__c = true;
            applicant.Applicant_Type__c = System.Label.Borrower;
            applicant.Customer_Qualification__c = 'B1';
            applicant.Marital_status__c = 'UNMAR';
            insert applicant;
            // Create Documents__c
            Documents__c doc1 = TestDataUtility.createTestKYCDocsForOcrFront(false, applicant, opp);
            doc1.Document_Type__c = 'ACH Mandate Form';
            doc1.Addresss_Type__c = System.Label.Document_Office_Address_Type;
            doc1.Aadhar_Source__c = 'OTP';
            doc1.is_Active__c = true;
            insert doc1;
            // Create final term
            Final_Term__c ft = new Final_Term__c(EMI_Amount__c=100,Repayment_mode__c='ACH', Loan_Application__c = opp.Id);
            insert ft;
            // Create Loan agreement
            Loan_Agreement__c la = new Loan_Agreement__c(Ist_EMI_Due_Date__c=System.today(), Loan_Application__c = opp.Id);
            insert la;
            //Create Loan Application Transaction History
            Loan_Application_Transaction_History__c loanAppHis = new Loan_Application_Transaction_History__c(Screen__c = 'Repayment Mandate',
                                                                                                             Module__c = 'test', Submitted_Flag__c = false,
                                                                                                             Loan_Application_ID__c = opp.Id);
            insert loanAppHis;
            Loan_Application_Transaction_History__c loanAppHis1 = new Loan_Application_Transaction_History__c(Screen__c = 'Loan Agreement',
                                                                                                              Module__c = 'Post Sanction Checks and Documentation', Submitted_Flag__c = true,
                                                                                                              Loan_Application_ID__c = opp.Id);
            insert loanAppHis1;
        }
    }
    
    @isTest
    public static void errorMethodTest(){
        
        Opportunity ope1 = new Opportunity();
        ope1.StageName = 'Qualification';
        ope1.CloseDate = Date.newInstance(2021, 1, 11);
        ope1.Name = 'testone';
        insert ope1;
        
        OtherException oe1 = new OtherException();
        
        ErrorLogEvent__e LogEntry = new ErrorLogEvent__e();
        LogEntry.Class_Name__c = 'utility';
        LogEntry.Method_Name__c = 'getAccount';
        LogEntry.Error_Message__c = 'testerror';
        LogEntry.Error_Stacktrace__c = 'lineno56';
        LogEntry.Error_Cause__c = 'fieldmissing';
        LogEntry.Line_Number__c = 23;
        LogEntry.Session_Id__c = UserInfo.getSessionId();
        LogEntry.Error_Type__c = 'testerror';
        LogEntry.Loan_Application_ID__c = ope1.Id;
        
        Test.startTest();
        IND_GetFinalOfferRecords.errorMethod(LogEntry.Class_Name__c,LogEntry.Method_Name__c,'test',oe1);
        Test.stopTest();
        
    }
    
    @isTest
    public static void applicantRejectMethodTest(){
        try{
            Opportunity opgr3 = new Opportunity();
            opgr3.StageName = 'Qualification';
            opgr3.CloseDate = Date.newInstance(2021, 1, 11);
            opgr3.Name = 'testone';
            insert opgr3;
            
            Applicant__c apgr3 = new Applicant__c();
            apgr3.Opportunity__c = opgr3.Id;
            apgr3.Contact_number__c = '9743514830';
            apgr3.Applicant_Type__c = 'Borrower';
            apgr3.Scorecard_Decision__c = 'Dark Red';
            insert apgr3;
            
            Test.startTest();
            IND_GetFinalOfferRecords.applicantRejectMethod(opgr3.Id);
            Test.stopTest();
            
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void applicantRejectMethodTest1(){
        try{
            Opportunity opgr3 = new Opportunity();
            opgr3.StageName = 'Qualification';
            opgr3.CloseDate = Date.newInstance(2021, 1, 11);
            opgr3.Name = 'testone';
            insert opgr3;
            
            Applicant__c apgr4 = new Applicant__c();
            apgr4.Opportunity__c = opgr3.Id;
            apgr4.Contact_number__c = '9743514830';
            apgr4.Applicant_Type__c = 'Borrower';
            //   apgr3.Scorecard_Decision__c = 'Green';
            insert apgr4;
            
            Test.startTest();
            IND_GetFinalOfferRecords.applicantRejectMethod(opgr3.Id);
            Test.stopTest();
            
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void getDetailsTest(){
        try{
            Opportunity opgr4 = new Opportunity();
            opgr4.StageName = 'Qualification';
            opgr4.CloseDate = Date.newInstance(2021, 1, 11);
            opgr4.Name = 'testone';
            opgr4.Journey_Status__c = 'Non STP';
            insert opgr4;
            
            Applicant__c apgr4 = new Applicant__c();
            apgr4.Opportunity__c = opgr4.Id;
            apgr4.Contact_number__c = '9743514830';
            apgr4.Applicant_Type__c = 'Borrower';
            apgr4.Scorecard_Decision__c = 'Red';
            insert apgr4;
            
            Retry_Count__c rc4 = new Retry_Count__c();
            rc4.Loan_Application_Id__c = opgr4.Id;
            rc4.Service_Name__c = 'FinalTermApi';
            rc4.User_Id__c = UserInfo.getUserId();
            rc4.IsAPIFailed__c = true;
            insert rc4;
            
            Test.startTest();
            IND_GetFinalOfferRecords.getDetails(opgr4.Id);
            IND_GetFinalOfferRecords.getDetails('test');
            Test.stopTest();
            
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void getDetailsTest1(){
        try{
            Opportunity opgr4 = new Opportunity();
            opgr4.StageName = 'Qualification';
            opgr4.CloseDate = Date.newInstance(2021, 1, 11);
            opgr4.Name = 'testone';
            opgr4.Journey_Status__c = 'Non STP';
            insert opgr4;
            
            Applicant__c apgr4 = new Applicant__c();
            apgr4.Opportunity__c = opgr4.Id;
            apgr4.Contact_number__c = '9743514830';
            apgr4.Applicant_Type__c = 'Borrower';
            apgr4.Scorecard_Decision__c = 'Dark Green';
            insert apgr4;
            
            Retry_Count__c rc4 = new Retry_Count__c();
            rc4.Loan_Application_Id__c = opgr4.Id;
            rc4.Service_Name__c = 'FinalTermApi';
            rc4.User_Id__c = UserInfo.getUserId();
            rc4.IsAPIFailed__c = true;
            insert rc4;
            
            Test.startTest();
            IND_GetFinalOfferRecords.getDetails(opgr4.Id);
            Test.stopTest();
            
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void getDetailsTest2(){
        try{
            Opportunity opgr4 = new Opportunity();
            opgr4.StageName = 'Qualification';
            opgr4.CloseDate = Date.newInstance(2021, 1, 11);
            opgr4.Name = 'testone';
            opgr4.Journey_Status__c = 'Non STP';
            insert opgr4;
            
            Applicant__c apgr4 = new Applicant__c();
            apgr4.Opportunity__c = opgr4.Id;
            apgr4.Contact_number__c = '9743514830';
            apgr4.Applicant_Type__c = 'Borrower';
            apgr4.Scorecard_Decision__c = 'Light Green';
            insert apgr4;
            
            Retry_Count__c rc4 = new Retry_Count__c();
            rc4.Loan_Application_Id__c = opgr4.Id;
            rc4.Service_Name__c = 'FinalTermApi';
            rc4.User_Id__c = UserInfo.getUserId();
            rc4.IsAPIFailed__c = true;
            insert rc4;
            
            Test.startTest();
            IND_GetFinalOfferRecords.getDetails(opgr4.Id);
            Test.stopTest();
            
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void getDetailsTest3(){
        try{
            Opportunity opgr4 = new Opportunity();
            opgr4.StageName = 'Qualification';
            opgr4.CloseDate = Date.newInstance(2021, 1, 11);
            opgr4.Name = 'testone';
            opgr4.Journey_Status__c = 'Non STP';
            insert opgr4;
            
            Applicant__c apgr4 = new Applicant__c();
            apgr4.Opportunity__c = opgr4.Id;
            apgr4.Contact_number__c = '9743514830';
            apgr4.Applicant_Type__c = 'Borrower';
            apgr4.Scorecard_Decision__c = 'YELLOW';
            insert apgr4;
            
            Retry_Count__c rc4 = new Retry_Count__c();
            rc4.Loan_Application_Id__c = opgr4.Id;
            rc4.Service_Name__c = 'FinalTermApi';
            rc4.User_Id__c = UserInfo.getUserId();
            rc4.IsAPIFailed__c = true;
            insert rc4;
            
            Test.startTest();
            IND_GetFinalOfferRecords.getDetails(opgr4.Id);
            Test.stopTest();
            
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void getDetailsTest4(){
        try{
            Opportunity opgr4 = new Opportunity();
            opgr4.StageName = 'Qualification';
            opgr4.CloseDate = Date.newInstance(2021, 1, 11);
            opgr4.Name = 'testone';
            opgr4.Journey_Status__c = 'Non STP';
            insert opgr4;
            
            Applicant__c apgr4 = new Applicant__c();
            apgr4.Opportunity__c = opgr4.Id;
            apgr4.Contact_number__c = '9743514830';
            apgr4.Applicant_Type__c = 'Borrower';
            apgr4.Scorecard_Decision__c = 'Light Red';
            insert apgr4;
            
            Retry_Count__c rc4 = new Retry_Count__c();
            rc4.Loan_Application_Id__c = opgr4.Id;
            rc4.Service_Name__c = 'FinalTermApi';
            rc4.User_Id__c = UserInfo.getUserId();
            rc4.IsAPIFailed__c = true;
            insert rc4;
            
            Test.startTest();
            IND_GetFinalOfferRecords.getDetails(opgr4.Id);
            Test.stopTest();
            
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void getDetailsTest5(){
        try{
            Opportunity opgr4 = new Opportunity();
            opgr4.StageName = 'Qualification';
            opgr4.CloseDate = Date.newInstance(2021, 1, 11);
            opgr4.Name = 'testone';
            opgr4.Journey_Status__c = 'Non STP';
            insert opgr4;
            
            Applicant__c apgr4 = new Applicant__c();
            apgr4.Opportunity__c = opgr4.Id;
            apgr4.Contact_number__c = '9743514830';
            apgr4.Applicant_Type__c = 'Borrower';
            apgr4.Scorecard_Decision__c = 'Dark Red';
            insert apgr4;
            
            Retry_Count__c rc4 = new Retry_Count__c();
            rc4.Loan_Application_Id__c = opgr4.Id;
            rc4.Service_Name__c = 'FinalTermApi';
            rc4.User_Id__c = UserInfo.getUserId();
            rc4.IsAPIFailed__c = true;
            insert rc4;
            
            Test.startTest();
            IND_GetFinalOfferRecords.getDetails(opgr4.Id);
            Test.stopTest();
            
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void getDetailsTest6(){
        try{
            Opportunity opgr4 = new Opportunity();
            opgr4.StageName = 'Qualification';
            opgr4.CloseDate = Date.newInstance(2021, 1, 11);
            opgr4.Name = 'testone';
            opgr4.Journey_Status__c = 'Non STP';
            insert opgr4;
            
            Applicant__c apgr4 = new Applicant__c();
            apgr4.Opportunity__c = opgr4.Id;
            apgr4.Contact_number__c = '9743514830';
            apgr4.Applicant_Type__c = 'Borrower';
            apgr4.Scorecard_Decision__c = 'GREEN';
            insert apgr4;
            
            Retry_Count__c rc4 = new Retry_Count__c();
            rc4.Loan_Application_Id__c = opgr4.Id;
            rc4.Service_Name__c = 'FinalTermApi';
            rc4.User_Id__c = UserInfo.getUserId();
            rc4.IsAPIFailed__c = true;
            insert rc4;
            
            Test.startTest();
            IND_GetFinalOfferRecords.getDetails(opgr4.Id);
            Test.stopTest();
            
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void getDetailsTest7(){
        try{
            Opportunity opgr7 = new Opportunity();
            opgr7.StageName = 'Qualification';
            opgr7.CloseDate = Date.newInstance(2021, 1, 11);
            opgr7.Name = 'testone';
            opgr7.Journey_Status__c = 'Non STP';
            insert opgr7;
            
            /*z   Applicant__c apgr4 = new Applicant__c();
apgr4.Opportunity__c = opgr4.Id;
apgr4.Contact_number__c = '9743514830';
apgr4.Applicant_Type__c = 'Borrower';
apgr4.Scorecard_Decision__c = 'GREEN';
insert apgr4;

Retry_Count__c rc4 = new Retry_Count__c();
rc4.Loan_Application_Id__c = opgr4.Id;
rc4.Service_Name__c = 'FinalTermApi';
rc4.User_Id__c = UserInfo.getUserId();
rc4.IsAPIFailed__c = true;
insert rc4; */
            
            Test.startTest();
            IND_GetFinalOfferRecords.getDetails(opgr7.Id);
            IND_GetFinalOfferRecords.getDetails(null);
            Test.stopTest();
            
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void getDetailsTest8(){
        try{
            Opportunity opgr4 = new Opportunity();
            opgr4.StageName = 'Qualification';
            opgr4.CloseDate = Date.newInstance(2021, 1, 11);
            opgr4.Name = 'testone';
            opgr4.Journey_Status__c = system.label.Non_STP;
            insert opgr4;
            
            Applicant__c apgr4 = new Applicant__c();
            apgr4.Opportunity__c = opgr4.Id;
            apgr4.Contact_number__c = '9743514830';
            apgr4.Applicant_Type__c = 'Borrower';
            apgr4.Scorecard_Decision__c = 'GREEN';
            insert apgr4;
            
            Retry_Count__c rc4 = new Retry_Count__c();
            rc4.Loan_Application_Id__c = opgr4.Id;
            rc4.Service_Name__c = 'FinalTermApi';
            rc4.User_Id__c = UserInfo.getUserId();
            rc4.IsAPIFailed__c = true;
            insert rc4;
            
            Test.startTest();
            IND_GetFinalOfferRecords.getDetails(opgr4.Id);
            Test.stopTest();
            
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void getFinalOfferDetailsflagTest(){
        try{
            Opportunity opfd1 = new Opportunity();
            opfd1.StageName = 'Qualification';
            opfd1.CloseDate = Date.newInstance(2021, 1, 11);
            opfd1.Name = 'testone';
            opfd1.Journey_Status__c = 'Non STP';
            insert opfd1;
            
            Applicant__c apfd1 = new Applicant__c();
            apfd1.Opportunity__c = opfd1.Id;
            apfd1.Contact_number__c = '9743514830';
            apfd1.Applicant_Type__c = 'Borrower';
            apfd1.Scorecard_Decision__c = 'Dark Green';
            apfd1.In_Active_Applicant__c=false;
            insert apfd1;
            
            Retry_Count__c rfd4 = new Retry_Count__c();
            rfd4.Loan_Application_Id__c = opfd1.Id;
            rfd4.Service_Name__c = 'FinalTermsEligiblitycheck';
            rfd4.User_Id__c = UserInfo.getUserId();
            rfd4.IsAPIFailed__c = true;
            insert rfd4;
            
            Test.startTest();
            IND_GetFinalOfferRecords.getFinalOfferDetailsflag(rfd4.Id);
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void getFinalOfferRecordTest(){
        try{
            Opportunity opfr1 = new Opportunity();
            opfr1.StageName = 'Qualification';
            opfr1.CloseDate = Date.newInstance(2021, 1, 11);
            opfr1.Name = 'testone';
            opfr1.Product_Type__c = 'Passenger Vehicles';
            insert opfr1;
            
            Applicant__c apfr1 = new Applicant__c();
            apfr1.Opportunity__c = opfr1.Id;
            apfr1.Contact_number__c = '9743514830';
            apfr1.Applicant_Type__c = 'Borrower';
            insert apfr1;
            
            Vehicle_Detail__c vfr1 = new Vehicle_Detail__c();
            vfr1.Loan_Application__c = opfr1.Id;
            vfr1.Base_Price__c = 100000.00;
            vfr1.Ben_Code__c = 'testveh';
            insert vfr1; 
            
            Retry_Count__c rfr1 = new Retry_Count__c();
            rfr1.Loan_Application_Id__c = opfr1.Id;
            rfr1.Service_Name__c = 'FinalTermsEligiblitycheck';
            rfr1.User_Id__c = UserInfo.getUserId();
            insert rfr1;
            
            Final_Term__c fgr1 = new Final_Term__c();
            fgr1.CRM_IRR__c = 120;
            fgr1.Loan_Application__c = opfr1.Id;
            fgr1.Holiday_period__c='30';
            fgr1.Loan_Amount__c = '10000';
            fgr1.Tenure__c = '12';
            fgr1.Net_IRR__c = 10;
            fgr1.Repayment_mode__c='N';
            fgr1.Do_you_want_to_initiate_e_NACH__c=true;
            //   fgr1.FIwaiver_offAddress__c = 'Not Waived';
            insert fgr1;
            
            Test.startTest();
            IND_GetFinalOfferRecords.getFinalOfferRecord(opfr1.Id);
            Test.stopTest();
            
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void getFinalOfferRecordTest1(){
        try{
            Opportunity opfr1 = new Opportunity();
            opfr1.StageName = 'Qualification';
            opfr1.CloseDate = Date.newInstance(2021, 1, 11);
            opfr1.Name = 'testone';
            opfr1.Product_Type__c= 'Passenger Vehicles';
            insert opfr1;
            
            Applicant__c apfr1 = new Applicant__c();
            apfr1.Opportunity__c = opfr1.Id;
            apfr1.Contact_number__c = '9743514830';
            apfr1.Applicant_Type__c = 'Borrower';
            insert apfr1;
            
            Vehicle_Detail__c vfr1 = new Vehicle_Detail__c();
            vfr1.Loan_Application__c = opfr1.Id;
            vfr1.Base_Price__c = 100000.00;
            vfr1.Ben_Code__c = 'testveh';
            insert vfr1; 
            
            
            Final_Term__c fgr1 = new Final_Term__c();
            fgr1.CRM_IRR__c = 120;
            fgr1.Loan_Application__c = opfr1.Id;
            fgr1.Holiday_period__c='30';
            fgr1.Loan_Amount__c = null;
            fgr1.Tenure__c = '12';
            fgr1.Gross_IRR__c= 10;
            //   fgr1.FIwaiver_offAddress__c = 'Not Waived';
            insert fgr1;
            
            Test.startTest();
            IND_GetFinalOfferRecords.getFinalOfferRecord(opfr1.Id);
            Test.stopTest();
            
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void getFinalOfferRecordTest2(){
        try{
            Opportunity opfr1 = new Opportunity();
            opfr1.StageName = 'Qualification';
            opfr1.CloseDate = Date.newInstance(2021, 1, 11);
            opfr1.Name = 'testone';
            insert opfr1;
            
            Applicant__c apfr1 = new Applicant__c();
            apfr1.Opportunity__c = opfr1.Id;
            apfr1.Contact_number__c = '9743514830';
            apfr1.Applicant_Type__c = 'Borrower';
            insert apfr1;
            
            Vehicle_Detail__c vfr1 = new Vehicle_Detail__c();
            vfr1.Loan_Application__c = opfr1.Id;
            vfr1.Base_Price__c = 100000.00;
            vfr1.Ben_Code__c = 'testveh';
            insert vfr1; 
            
            
            Final_Term__c fgr1 = new Final_Term__c();
            fgr1.CRM_IRR__c = 120;
            fgr1.Loan_Application__c = opfr1.Id;
            fgr1.Holiday_period__c='30';
            fgr1.Loan_Amount__c = null;
            fgr1.Tenure__c = null;
            //   fgr1.FIwaiver_offAddress__c = 'Not Waived';
            insert fgr1;
            
            Test.startTest();
            IND_GetFinalOfferRecords.getFinalOfferRecord(opfr1.Id);
            Test.stopTest();
            
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void getFinalOfferRecordTest3(){
        try{
            Opportunity opfr1 = new Opportunity();
            opfr1.StageName = 'Qualification';
            opfr1.CloseDate = Date.newInstance(2021, 1, 11);
            opfr1.Name = 'testone';
            opfr1.Required_Loan_amount__c = 100000;
            insert opfr1;
            
            Applicant__c apfr1 = new Applicant__c();
            apfr1.Opportunity__c = opfr1.Id;
            apfr1.Contact_number__c = '9743514830';
            apfr1.Applicant_Type__c = 'Borrower';
            insert apfr1;
            
            Vehicle_Detail__c vfr1 = new Vehicle_Detail__c();
            vfr1.Loan_Application__c = opfr1.Id;
            vfr1.Base_Price__c = 100000.00;
            vfr1.Ben_Code__c = 'testveh';
            insert vfr1; 
            
            
            Final_Term__c fgr1 = new Final_Term__c();
            fgr1.CRM_IRR__c = 120;
            fgr1.Loan_Application__c = opfr1.Id;
            fgr1.Holiday_period__c='30';
            fgr1.Loan_Amount__c = null;
            fgr1.Tenure__c = null;
            //   fgr1.FIwaiver_offAddress__c = 'Not Waived';
            insert fgr1;
            
            Test.startTest();
            IND_GetFinalOfferRecords.getFinalOfferRecord(opfr1.Id);
            Test.stopTest();
            
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void getFinalOfferRecordTest4(){
        try{
            Opportunity opfr1 = new Opportunity();
            opfr1.StageName = 'Qualification';
            opfr1.CloseDate = Date.newInstance(2021, 1, 11);
            opfr1.Name = 'testone';
            opfr1.Required_Loan_amount__c = 100000;
            insert opfr1;
            
            Applicant__c apfr1 = new Applicant__c();
            apfr1.Opportunity__c = opfr1.Id;
            apfr1.Contact_number__c = '9743514830';
            apfr1.Applicant_Type__c = 'Borrower';
            insert apfr1;
            
            Vehicle_Detail__c vfr1 = new Vehicle_Detail__c();
            vfr1.Loan_Application__c = opfr1.Id;
            vfr1.Base_Price__c = 100000.00;
            vfr1.Ben_Code__c = 'testveh';
            insert vfr1; 
            
            
            Final_Term__c fgr1 = new Final_Term__c();
            fgr1.CRM_IRR__c = null;
            fgr1.Loan_Application__c = opfr1.Id;
            fgr1.Holiday_period__c='30';
            fgr1.Loan_Amount__c = null;
            fgr1.Tenure__c = null;
            //   fgr1.FIwaiver_offAddress__c = 'Not Waived';
            insert fgr1;
            
            Test.startTest();
            IND_GetFinalOfferRecords.getFinalOfferRecord(opfr1.Id);
            Test.stopTest();
            
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void getFinalOfferRecordTest5(){
        try{
            Opportunity opfr1 = new Opportunity();
            opfr1.StageName = 'Qualification';
            opfr1.CloseDate = Date.newInstance(2021, 1, 11);
            opfr1.Name = 'testone';
            opfr1.Required_Loan_amount__c = 100000;
            insert opfr1;
            
            Applicant__c apfr1 = new Applicant__c();
            apfr1.Opportunity__c = opfr1.Id;
            apfr1.Contact_number__c = '9743514830';
            apfr1.Applicant_Type__c = 'Borrower';
            insert apfr1;
            
            Vehicle_Detail__c vfr1 = new Vehicle_Detail__c();
            vfr1.Loan_Application__c = opfr1.Id;
            vfr1.Base_Price__c = 100000.00;
            vfr1.Ben_Code__c = 'testveh';
            insert vfr1; 
            
            
            Final_Term__c fgr1 = new Final_Term__c();
            fgr1.CRM_IRR__c = null;
            fgr1.Loan_Application__c = opfr1.Id;
            fgr1.Holiday_period__c='30';
            fgr1.Loan_Amount__c = null;
            fgr1.Tenure__c = null;
            //   fgr1.FIwaiver_offAddress__c = 'Not Waived';
            fgr1.EMI_Amount__c = 10000;
            insert fgr1;
            
            Test.startTest();
            IND_GetFinalOfferRecords.getFinalOfferRecord(opfr1.Id);
            IND_GetFinalOfferRecords.getFinalOfferRecord('test');
            Test.stopTest();
            
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    /*@isTest
    public static void checkRepaymentRecordAndRetryCountTest() {
        try
        {
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod125@indusbank.com' AND IsActive = true LIMIT 1];
            System.runAs(u)
            {
                Opportunity opfr1 = new Opportunity();
        opfr1.StageName = 'Qualification';
        opfr1.CloseDate = Date.newInstance(2021, 1, 11);
        opfr1.Name = 'testone';
        opfr1.Required_Loan_amount__c = 100000;
        opfr1.Product_Type__c='Tractor';
        insert opfr1;

        // Create Repayments__c record related to the test opportunity
        Repayments__c repay = TestDataUtility.createTestRepayments(false, opfr1);
            repay.Is_Netbanking_available_with_customer__c = 'Yes';
            repay.EMl_Amt_Is_filled_correctly__c = 'Yes';
            repay.Loan_Application__c=opfr1.Id;
            insert repay;

        // Create Retry_Count__c record related to the test opportunity
        Retry_Count__c testRetryCount = new Retry_Count__c(
            Loan_Application_Id__c = opfr1.Id,
            Service_Name__c = System.label.Initiate_ENACH_Attempts,
            User_Id__c = UserInfo.getUserId(),
            Count__c = 1 
        );
        insert testRetryCount;

        Test.startTest();
        // Call the method under test
        String result = IND_GetFinalOfferRecords.checkRepaymentRecordAndRetryCount(opfr1.Id);
        Test.stopTest();

        // Assert the result
        // Depending on the result, assert the returned JSON structure or specific values
        // For example:
        System.assertNotEquals(null, result);
        // Add more specific assertions as needed
    }

        } catch(Exception e)
        {
            system.debug('error '+ e.getMessage());
        }
    }*/
    
    @isTest
    public static void getFinalOfferRecordForTractorTest(){
        // Create test data
        Opportunity opfr1 = new Opportunity();
        opfr1.StageName = 'Qualification';
        opfr1.CloseDate = Date.newInstance(2021, 1, 11);
        opfr1.Name = 'testone';
        opfr1.Required_Loan_amount__c = 100000;
        opfr1.Product_Type__c='Tractor';
        insert opfr1;
        
        Applicant__c apfr1 = new Applicant__c();
        apfr1.Opportunity__c = opfr1.Id;
        apfr1.Contact_number__c = '9743514830';
        apfr1.Applicant_Type__c = 'Borrower';
        insert apfr1;
        
        Vehicle_Detail__c vfr1 = new Vehicle_Detail__c();
        vfr1.Loan_Application__c = opfr1.Id;
        vfr1.Base_Price__c = 100000.00;
        vfr1.Ben_Code__c = 'testveh';
        vfr1.Loan_Amount__c=1500000;
        vfr1.Required_Tenure__c=25000;
        vfr1.Required_CRM_IRR__c=55000;
        insert vfr1;
        
        Final_Term__c fgr1 = new Final_Term__c();
        fgr1.CRM_IRR__c = null;
        fgr1.Loan_Application__c = opfr1.Id;
        fgr1.Holiday_period__c='30';
        fgr1.Loan_Amount__c = '10000';
        fgr1.Tenure__c = '50000';
        fgr1.EMI_Amount__c = 10000;
        fgr1.Vehicle_Detail__c=vfr1.Id;
        fgr1.Required_CRM_IRR__c='test';
        fgr1.No_of_Installment__c=2;
        fgr1.EMI_Amount__c=1000;
        fgr1.Repayment_mode__c='N';
        fgr1.Do_you_want_to_initiate_e_NACH__c=true;
        insert fgr1;
        
        
        
        // Set up mock data for the query results
        /*Test.setMock(
Database.QueryLocator.class,
new YourMockQueryLocator(new List<SObject>{testApplicant, testOpportunity, testVehicleDetail})
);*/
        
        Test.startTest();
        // Call the method under test
        IND_GetFinalOfferRecords.getFinalOfferRecordForTractor(opfr1.Id);
        Test.stopTest();
        
        // Assert the result
        //System.assertNotEquals(null, result);
        // Add more specific assertions as needed
    }
    
     @isTest
    public static void getFinalOfferRecordForTractorTest1(){
        // Create test data
        Opportunity opfr1 = new Opportunity();
        opfr1.StageName = 'Qualification';
        opfr1.CloseDate = Date.newInstance(2021, 1, 11);
        opfr1.Name = 'testone';
        opfr1.Required_Loan_amount__c = 100000;
        opfr1.Product_Type__c='Two Wheeler';
        insert opfr1;
        
        Applicant__c apfr1 = new Applicant__c();
        apfr1.Opportunity__c = opfr1.Id;
        apfr1.Contact_number__c = '9743514830';
        apfr1.Applicant_Type__c = 'Borrower';
        insert apfr1;
        
        Vehicle_Detail__c vfr1 = new Vehicle_Detail__c();
        vfr1.Loan_Application__c = opfr1.Id;
        vfr1.Base_Price__c = 100000.00;
        vfr1.Ben_Code__c = 'testveh';
        vfr1.Loan_Amount__c=Null;
        vfr1.Required_Tenure__c=25000;
        vfr1.Required_CRM_IRR__c=55000;
        insert vfr1;
        
        Final_Term__c fgr1 = new Final_Term__c();
        fgr1.CRM_IRR__c = null;
        fgr1.Loan_Application__c = opfr1.Id;
        fgr1.Holiday_period__c='30';
        fgr1.Loan_Amount__c = '10000';
        fgr1.Tenure__c = null;
        fgr1.EMI_Amount__c = 10000;
        fgr1.Vehicle_Detail__c=vfr1.Id;
        fgr1.Required_CRM_IRR__c=null;
        fgr1.No_of_Installment__c=null;
        fgr1.EMI_Amount__c=null;
        fgr1.Repayment_mode__c=null;
        fgr1.Do_you_want_to_initiate_e_NACH__c=false;
        insert fgr1;
        
     
        
        Test.startTest();
        // Call the method under test
        IND_GetFinalOfferRecords.getFinalOfferRecordForTractor(opfr1.Id);
        Test.stopTest();
        
        // Assert the result
        //System.assertNotEquals(null, result);
        // Add more specific assertions as needed
    }
    
    
     @isTest
    public static void assingedLeadtoTFCVOTest() {
        // Create test data
         Account acc = new Account(
        	Name = 'Test Account',
            Type = 'TW',
            Product_Type__c = 'New',
            BranchBLCode__c = 'HDT',
            State__c = 'HARYANA'
        );
        insert acc;
        Opportunity opfr1 = new Opportunity();
        opfr1.StageName = 'Qualification';
        opfr1.CloseDate = Date.newInstance(2021, 1, 11);
        opfr1.Name = 'testone';
        opfr1.AccountId=acc.Id;
        opfr1.Required_Loan_amount__c = 100000;
        opfr1.Product_Type__c='Tractor';
        insert opfr1;

         
        // Assign an AccountTeamMember with TeamMemberRole 'CVO' to the test account
        AccountTeamMember testTeamMember = new AccountTeamMember(
            AccountId = acc.Id,
            TeamMemberRole = 'CVO',
            UserId = UserInfo.getUserId()
        );
        insert testTeamMember;

        // Create an Applicant related to the test opportunity
       Applicant__c apfr1 = new Applicant__c();
        apfr1.Opportunity__c = opfr1.Id;
        apfr1.Contact_number__c = '9743514830';
        apfr1.Applicant_Type__c = 'Borrower';
        apfr1.In_Active_Applicant__c=false;
        apfr1.Journey_Stage__c='User Details';
        insert apfr1;
        Test.startTest();
        // Call the method under test
        Boolean result = IND_GetFinalOfferRecords.assingedLeadtoTFCVO(opfr1.Id);
        Test.stopTest();

        // Assert the result
        System.assertEquals(true, result);
        // Add more specific assertions as needed
    }
    
     @isTest
    public static void checkRepaymentRecordAndRetryCountTest() {
        // Create test data
        Opportunity opfr1 = new Opportunity();
        opfr1.StageName = 'Qualification';
        opfr1.CloseDate = Date.newInstance(2021, 1, 11);
        opfr1.Name = 'testone';
        opfr1.Required_Loan_amount__c = 100000;
        opfr1.Product_Type__c='Tractor';
        insert opfr1;

        // Create Repayments__c record related to the test opportunity
        Repayments__c repay = TestDataUtility.createTestRepayments(false, opfr1);
            repay.Is_Netbanking_available_with_customer__c = 'Yes';
            repay.EMl_Amt_Is_filled_correctly__c = 'Yes';
            repay.Loan_Application__c=opfr1.Id;
            insert repay;

        // Create Retry_Count__c record related to the test opportunity
        Retry_Count__c testRetryCount = new Retry_Count__c(
            Loan_Application_Id__c = opfr1.Id,
            Service_Name__c = System.label.Initiate_ENACH_Attempts,
            User_Id__c = UserInfo.getUserId(),
            Count__c = 1 
        );
        insert testRetryCount;

        Test.startTest();
        // Call the method under test
        String result = IND_GetFinalOfferRecords.checkRepaymentRecordAndRetryCount(opfr1.Id);
        Test.stopTest();

        // Assert the result
        // Depending on the result, assert the returned JSON structure or specific values
        // For example:
        System.assertNotEquals(null, result);
        // Add more specific assertions as needed
    }
   /* @isTest
     public static void getFinalOfferDetailsflagTest() {
    // Define test data
    final String DARK_GREEN = 'Dark Green';
    final String LIGHT_GREEN = 'Light Green';
    final String DARK_RED = 'Dark Red';
    final String LOADING = 'Loading';
    final String GREEN = 'Green';
    final String JOURENY_STATUS_STP = 'STP';
    final String JOURENY_STAUS_STOP = 'STOP';

    Opportunity opfr1 = new Opportunity(
        StageName = 'Qualification',
        CloseDate = Date.newInstance(2021, 1, 11),
        Name = 'testone',
        Required_Loan_amount__c = 100000,
        Product_Type__c='Tractor',
        Journey_Status__c='Non-STP'
    );
    insert opfr1;

    // Create a test Retry_Count__c record
    Retry_Count__c rc4 = new Retry_Count__c(
        Loan_Application_Id__c = opfr1.Id,
        Service_Name__c = 'FinalTermApi',
        User_Id__c = UserInfo.getUserId(),
        IsAPIFailed__c = true
    );
    insert rc4;

    Applicant__c testApplicant = new Applicant__c(
        Opportunity__c = opfr1.Id,
        In_Active_Applicant__c = false,
       
        Scorecard_Decision__c = DARK_GREEN // Set score decision as Dark Green for testing
    );
    insert testApplicant;

    // Call the method under test
    Test.startTest();
    String result;
    try {
        result = IND_GetFinalOfferRecords.getFinalOfferDetailsflag(opfr1.Id);
    } catch (Exception e) {
        result = e.getMessage();
    }
    Test.stopTest();

    // Perform assertions
    // Assert that the result is not null, indicating that the method executed without throwing an exception
    System.assertNotEquals(null, result);
    // Add more specific assertions as needed to verify the behavior of the method under different scenarios
}*/
}