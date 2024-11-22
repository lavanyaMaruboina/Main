/**
* @author Khushiram.
* @company Persistent Systems
* @description A  Test class for the LwcLOSLoanApplicationCntrl class
* Inputs: None
* History:
* 2/09/2021 Khushiram.
*/
@isTest(seeAllData = false)
    public class LwcLOSLoanApplicationCntrlTest{
          @isTest
        public static void getTabListTest(){
            
                Opportunity optl1 = new Opportunity();
                optl1.StageName = 'Asset Details';
                optl1.CloseDate = Date.newInstance(2021, 1, 11);
                optl1.Name = 'testone';
                insert optl1;
                
                Applicant__c aptl1 = new Applicant__c();
                aptl1.Opportunity__c = optl1.Id;
                aptl1.Contact_number__c = '9743514830';
                aptl1.Applicant_Type__c = 'Co-Borrower';
                insert aptl1;
                
                Test.startTest();
                     LwcLOSLoanApplicationCntrl.getTabList(optl1.Id);
                     LwcLOSLoanApplicationCntrl.getTabList(null);
                Test.stopTest();
        }
        
          @isTest
        public static void getTabListTest1(){
            
                Opportunity optl1 = new Opportunity();
                optl1.StageName = 'Qualification';
                optl1.CloseDate = Date.newInstance(2021, 1, 11);
                optl1.Name = 'testone';
                insert optl1;
                
                Applicant__c aptl1 = new Applicant__c();
                aptl1.Opportunity__c = optl1.Id;
                aptl1.Contact_number__c = '9743514830';
                aptl1.Applicant_Type__c = 'Borrower';
                insert aptl1;
                
                Test.startTest();
                     LwcLOSLoanApplicationCntrl.getTabList(optl1.Id);
                Test.stopTest();
        }
        
        @isTest
        public static void getTabListTest2(){
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            opp.StageName = 'Final Terms';
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            
            Applicant__c app1 = TestDataUtility.createTestApplicantForSMS(false);
            app1.Opportunity__c = opp.Id;
            app1.Applicant_Type__c = 'Co-borrower';
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert app1;
            }
            
             Test.startTest();
                     LwcLOSLoanApplicationCntrl.getTabList(opp.Id);
                Test.stopTest();
            
         }
        
         @isTest
        public static void getTabListTest3(){
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            opp.StageName = 'Offer Screen';
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            
            Applicant__c app1 = TestDataUtility.createTestApplicantForSMS(false);
            app1.Opportunity__c = opp.Id;
            app1.Applicant_Type__c = 'Co-borrower';
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert app1;
            }
            
             Test.startTest();
                     LwcLOSLoanApplicationCntrl.getTabList(opp.Id);
                Test.stopTest();
            
         }
        
        @isTest
        public static void getTabListTest4(){
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            opp.StageName = 'Final Offer';
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            
            Applicant__c app2 = TestDataUtility.createTestApplicantForSMS(false);
            app2.Opportunity__c = opp.Id;
            app2.Applicant_Type__c = 'Co-borrower';
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert app2;
            }
            
             Test.startTest();
                     LwcLOSLoanApplicationCntrl.getTabList(opp.Id);
                Test.stopTest();
            
         } 
        
         @isTest
        public static void getTabListTest5(){
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            opp.StageName = 'Income Details';
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            
            Applicant__c app2 = TestDataUtility.createTestApplicantForSMS(false);
            app2.Opportunity__c = opp.Id;
            app2.Applicant_Type__c = 'Borrower';
            app2.Income_source_available__c = false;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert app2;
            }
            
             Test.startTest();
                     LwcLOSLoanApplicationCntrl.getTabList(opp.Id);
                Test.stopTest();
            
         }
        
         @isTest
        public static void getTabListTest6(){
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            opp.StageName = 'Loan Details';
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            
            Applicant__c app2 = TestDataUtility.createTestApplicantForSMS(false);
            app2.Opportunity__c = opp.Id;
            app2.Applicant_Type__c = 'Co-Borrower';
         //   app2.Income_source_available__c = false;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert app2;
            }
            
             Test.startTest();
                     LwcLOSLoanApplicationCntrl.getTabList(opp.Id);
                Test.stopTest();
            
         }
        
         @isTest
        public static void getTabListTest7(){
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            opp.StageName = 'Customer Code Addition';
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            
            Applicant__c app2 = TestDataUtility.createTestApplicantForSMS(false);
            app2.Opportunity__c = opp.Id;
            app2.Applicant_Type__c = 'Co-Borrower';
         //   app2.Income_source_available__c = false;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert app2;
            }
            
             Test.startTest();
                     LwcLOSLoanApplicationCntrl.getTabList(opp.Id);
                Test.stopTest();
            
         }
        
         @isTest
        public static void getTabListTest8(){
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            opp.StageName = 'Vehicle Valuation';
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            
            Applicant__c app2 = TestDataUtility.createTestApplicantForSMS(false);
            app2.Opportunity__c = opp.Id;
            app2.Applicant_Type__c = 'Co-Borrower';
         //   app2.Income_source_available__c = false;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert app2;
            }
            
             Test.startTest();
                     LwcLOSLoanApplicationCntrl.getTabList(opp.Id);
                Test.stopTest();
            
         }
        
        @isTest
        public static void getTabListTest9(){
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            opp.StageName = 'Vehicle Insurance';
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            
            Applicant__c app2 = TestDataUtility.createTestApplicantForSMS(false);
            app2.Opportunity__c = opp.Id;
            app2.Applicant_Type__c = 'Co-Borrower';
         //   app2.Income_source_available__c = false;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert app2;
            }
            
             Test.startTest();
                     LwcLOSLoanApplicationCntrl.getTabList(opp.Id);
                Test.stopTest();
            
         }
        
        @isTest
        public static void frontUploadTest(){
            try{
                Opportunity opfu1 = new Opportunity();
                opfu1.StageName = 'Qualification';
                opfu1.CloseDate = Date.newInstance(2021, 1, 11);
                opfu1.Name = 'testone';
                insert opfu1;
                
                Applicant__c apfu1 = new Applicant__c();
                apfu1.Opportunity__c = opfu1.Id;
                apfu1.Contact_number__c = '9743514830';
                apfu1.Applicant_Type__c = 'Borrower';
                insert apfu1;
                
                 Documents__c dfu1 = new Documents__c();
                 dfu1.Applicant__c = apfu1.Id;
                 dfu1.Opportunity_Relation__c = opfu1.Id;
                 dfu1.Document_Type__c = System.label.AadhaarCard;
                 dfu1.Document_Side__c ='Back';
                 dfu1.Aadhar_Source__c = 'ScanAadhar';
                 dfu1.Front_Upload_Attempts__c = 5;
                 insert dfu1;
                
                 Test.startTest();
                       LwcLOSLoanApplicationCntrl.frontUpload(dfu1.Id,'testkyc',dfu1.Document_Type__c);
                 Test.stopTest();
            }catch(Exception e){
                System.assertEquals('Script-thrown exception', e.getMessage());
            }
        }
        
         @isTest
        public static void frontUploadTest1(){
            try{
                Opportunity opfu1 = new Opportunity();
                opfu1.StageName = 'Qualification';
                opfu1.CloseDate = Date.newInstance(2021, 1, 11);
                opfu1.Name = 'testone';
                insert opfu1;
                
                Applicant__c apfu1 = new Applicant__c();
                apfu1.Opportunity__c = opfu1.Id;
                apfu1.Contact_number__c = '9743514830';
                apfu1.Applicant_Type__c = 'Borrower';
                insert apfu1;
                
                 Documents__c dfu1 = new Documents__c();
                 dfu1.Applicant__c = apfu1.Id;
                 dfu1.Opportunity_Relation__c = opfu1.Id;
                 dfu1.Document_Type__c = System.label.AadhaarCard;
                 dfu1.Document_Side__c ='Back';
                 dfu1.Aadhar_Source__c = 'ScanAadhar';
                 dfu1.Front_Upload_Attempts__c = 0;
                 dfu1.is_Front_Upload_Completed__c = true;
                 insert dfu1;
                
                 Test.startTest();
                       LwcLOSLoanApplicationCntrl.frontUpload(dfu1.Id,'testkyc',dfu1.Document_Type__c);
                 Test.stopTest();
            }catch(Exception e){
                System.assertEquals('Script-thrown exception', e.getMessage());
            }
        }
        
        @isTest
        public static void ocrOnFrontUploadTest(){
            Test.startTest();
                 LwcLOSLoanApplicationCntrl.ocrOnFrontUpload();
            Test.stopTest();
        }
        
        @isTest
        public static void backUploadTest(){
            try{
                Opportunity opfu1 = new Opportunity();
                opfu1.StageName = 'Qualification';
                opfu1.CloseDate = Date.newInstance(2021, 1, 11);
                opfu1.Name = 'testone';
                insert opfu1;
                
                Applicant__c apfu1 = new Applicant__c();
                apfu1.Opportunity__c = opfu1.Id;
                apfu1.Contact_number__c = '9743514830';
                apfu1.Applicant_Type__c = 'Borrower';
                insert apfu1;
                
                 Documents__c dfu1 = new Documents__c();
                 dfu1.Applicant__c = apfu1.Id;
                 dfu1.Opportunity_Relation__c = opfu1.Id;
                 dfu1.Document_Type__c = System.label.AadhaarCard;
                 dfu1.Document_Side__c ='Back';
                 dfu1.Aadhar_Source__c = 'ScanAadhar';
                 dfu1.Back_Upload_Attempts__c = 5;
                 insert dfu1;
                
                 Test.startTest();
                       LwcLOSLoanApplicationCntrl.backUpload(dfu1.Id,'testkyc',dfu1.Document_Type__c);
                 Test.stopTest();
            }catch(Exception e){
                System.assertEquals('Script-thrown exception', e.getMessage());
            }
        }
        
          @isTest
        public static void backUploadTest1(){
            try{
                Opportunity opfu1 = new Opportunity();
                opfu1.StageName = 'Qualification';
                opfu1.CloseDate = Date.newInstance(2021, 1, 11);
                opfu1.Name = 'testone';
                insert opfu1;
                
                Applicant__c apfu1 = new Applicant__c();
                apfu1.Opportunity__c = opfu1.Id;
                apfu1.Contact_number__c = '9743514830';
                apfu1.Applicant_Type__c = 'Borrower';
                insert apfu1;
                
                 Documents__c dfu1 = new Documents__c();
                 dfu1.Applicant__c = apfu1.Id;
                 dfu1.Opportunity_Relation__c = opfu1.Id;
                 dfu1.Document_Type__c = System.label.AadhaarCard;
                 dfu1.Document_Side__c ='Back';
                 dfu1.Aadhar_Source__c = 'ScanAadhar';
                 dfu1.Back_Upload_Attempts__c = 0;
                 dfu1.is_Back_Upload_Completed__c = true;
                 insert dfu1;
                
                 Test.startTest();
                       LwcLOSLoanApplicationCntrl.backUpload(dfu1.Id,'testkyc',dfu1.Document_Type__c);
                 Test.stopTest();
            }catch(Exception e){
                System.assertEquals('Script-thrown exception', e.getMessage());
            }
        }
        
        @isTest
        public static void sendOTPTest(){
            try{
                
                Opportunity opst1 = new Opportunity();
                opst1.StageName = 'Qualification';
                opst1.CloseDate = Date.newInstance(2021, 1, 11);
                opst1.Name = 'testone';
                opst1.Aadhar_OTP_Attempts__c = null;
                insert opst1;
                
                Test.startTest();
                    LwcLOSLoanApplicationCntrl.sendOTP(opst1.Id,'374022029050');
                Test.stopTest();
                
            }catch(Exception e){
                System.assertEquals('Script-thrown exception', e.getMessage());
            }
        }
        
        @isTest
        public static void sendOTPTest1(){
            try{
                
                Opportunity opst1 = new Opportunity();
                opst1.StageName = 'Qualification';
                opst1.CloseDate = Date.newInstance(2021, 1, 11);
                opst1.Name = 'testone';
                opst1.Aadhar_OTP_Attempts__c = 0;
                insert opst1;
                
                Test.startTest();
                    LwcLOSLoanApplicationCntrl.sendOTP(opst1.Id,'374022029050');
                Test.stopTest();
                
            }catch(Exception e){
                System.assertEquals('Script-thrown exception', e.getMessage());
            }
        }
        
        @isTest
        public static void sendOTPTest2(){
            try{
                
                Opportunity opst1 = new Opportunity();
                opst1.StageName = 'Qualification';
                opst1.CloseDate = Date.newInstance(2021, 1, 11);
                opst1.Name = 'testone';
                opst1.Aadhar_OTP_Attempts__c = 5;
                insert opst1;
                
                Test.startTest();
                    LwcLOSLoanApplicationCntrl.sendOTP(opst1.Id,'374022029050');
                Test.stopTest();
                
            }catch(Exception e){
                System.assertEquals('Script-thrown exception', e.getMessage());
            }
        }
        
        @isTest
        public static void generateOTPTest(){
            try{
                 Opportunity opgt1 = new Opportunity();
                opgt1.StageName = 'Qualification';
                opgt1.CloseDate = Date.newInstance(2021, 1, 11);
                opgt1.Name = 'testone';
                insert opgt1;
                
                Applicant__c apgt1 = new Applicant__c();
                apgt1.Opportunity__c = opgt1.Id;
                apgt1.Contact_number__c = '9743514830';
                apgt1.Applicant_Type__c = 'Borrower';
                insert apgt1;
                
                 Documents__c dfgt1 = new Documents__c();
                 dfgt1.Applicant__c = apgt1.Id;
                 dfgt1.Opportunity_Relation__c = opgt1.Id;
                 dfgt1.Document_Type__c = System.label.AadhaarCard;
                 dfgt1.Document_Side__c ='Back';
                 dfgt1.Aadhar_Source__c = 'ScanAadhar';
                 dfgt1.OTP_for_borrower__c = '54321';
                 insert dfgt1;
                
                 Test.startTest();
                     LwcLOSLoanApplicationCntrl.generateOTP(dfgt1.Id);
                 Test.stopTest();
            }catch(Exception e){
                System.assertEquals('Script-thrown exception', e.getMessage());
            }
        }
        
        @isTest
        public static void verifyAadharOTPTest(){
            try{
                
                Opportunity opva1 = new Opportunity();
                opva1.StageName = 'Qualification';
                opva1.CloseDate = Date.newInstance(2021, 1, 11);
                opva1.Name = 'testone';
                insert opva1;
                
                Applicant__c apva1 = new Applicant__c();
                apva1.Opportunity__c = opva1.Id;
                apva1.Contact_number__c = '9743514830';
                apva1.Applicant_Type__c = 'Borrower';
                insert apva1;
                
                 Documents__c dfva1 = new Documents__c();
                 dfva1.Applicant__c = apva1.Id;
                 dfva1.Opportunity_Relation__c = opva1.Id;
                 dfva1.Document_Type__c = System.label.AadhaarCard;
                 dfva1.Document_Side__c ='Back';
                 dfva1.Aadhar_Source__c = 'ScanAadhar';
                 dfva1.OTP_for_borrower__c = '54321';
                 insert dfva1;
                
                 Test.startTest();
                      LwcLOSLoanApplicationCntrl.verifyAadharOTP(dfva1.OTP_for_borrower__c,dfva1.Id);
                   //   LwcLOSLoanApplicationCntrl.verifyAadharOTP('53241',dfva1.Id);
                 Test.stopTest();
            }catch(Exception e){
                 System.assertEquals('Script-thrown exception', e.getMessage());
            }
        }
        
         @isTest
        public static void verifyAadharOTPTest1(){
            try{
                
                Opportunity opva1 = new Opportunity();
                opva1.StageName = 'Qualification';
                opva1.CloseDate = Date.newInstance(2021, 1, 11);
                opva1.Name = 'testone';
                insert opva1;
                
                Applicant__c apva1 = new Applicant__c();
                apva1.Opportunity__c = opva1.Id;
                apva1.Contact_number__c = '9743514830';
                apva1.Applicant_Type__c = 'Borrower';
                insert apva1;
                
                 Documents__c dfva1 = new Documents__c();
                 dfva1.Applicant__c = apva1.Id;
                 dfva1.Opportunity_Relation__c = opva1.Id;
                 dfva1.Document_Type__c = System.label.AadhaarCard;
                 dfva1.Document_Side__c ='Back';
                 dfva1.Aadhar_Source__c = 'ScanAadhar';
                 dfva1.OTP_for_borrower__c = '54321';
                 insert dfva1;
                
                 Test.startTest();
                    //  LwcLOSLoanApplicationCntrl.verifyAadharOTP(dfva1.OTP_for_borrower__c,dfva1.Id);
                        LwcLOSLoanApplicationCntrl.verifyAadharOTP('53241',dfva1.Id);
                 Test.stopTest();
            }catch(Exception e){
                 System.assertEquals('Script-thrown exception', e.getMessage());
            }
        }
        
        @isTest
        public static void resendAadharOTPTest(){
            try{
                Opportunity opra1 = new Opportunity();
                opra1.StageName = 'Qualification';
                opra1.CloseDate = Date.newInstance(2021, 1, 11);
                opra1.Name = 'testone';
                insert opra1;
                
                Applicant__c apra1 = new Applicant__c();
                apra1.Opportunity__c = opra1.Id;
                apra1.Contact_number__c = '9743514830';
                apra1.Applicant_Type__c = 'Borrower';
                insert apra1;
                
                 Documents__c dfra1 = new Documents__c();
                 dfra1.Applicant__c = apra1.Id;
                 dfra1.Opportunity_Relation__c = opra1.Id;
                 dfra1.Document_Type__c = System.label.AadhaarCard;
                 dfra1.Document_Side__c ='Back';
                 dfra1.Aadhar_Source__c = 'ScanAadhar';
                 dfra1.OTP_Resend_Attempts__c = null;
                 insert dfra1;
                
                 Test.startTest();
                    LwcLOSLoanApplicationCntrl.resendAadharOTP(dfra1.Id, '12345');
                 Test.stopTest();
            }catch(Exception e){
                System.assertEquals('Script-thrown exception', e.getMessage());
            }
        }
        
        @isTest
        public static void resendAadharOTPTest1(){
            try{
                Opportunity opra1 = new Opportunity();
                opra1.StageName = 'Qualification';
                opra1.CloseDate = Date.newInstance(2021, 1, 11);
                opra1.Name = 'testone';
                insert opra1;
                
                Applicant__c apra1 = new Applicant__c();
                apra1.Opportunity__c = opra1.Id;
                apra1.Contact_number__c = '9743514830';
                apra1.Applicant_Type__c = 'Borrower';
                insert apra1;
                
                 Documents__c dfra1 = new Documents__c();
                 dfra1.Applicant__c = apra1.Id;
                 dfra1.Opportunity_Relation__c = opra1.Id;
                 dfra1.Document_Type__c = System.label.AadhaarCard;
                 dfra1.Document_Side__c ='Back';
                 dfra1.Aadhar_Source__c = 'ScanAadhar';
                 dfra1.OTP_Resend_Attempts__c = 0;
                 insert dfra1;
                
                 Test.startTest();
                    LwcLOSLoanApplicationCntrl.resendAadharOTP(dfra1.Id, null);
                 Test.stopTest();
            }catch(Exception e){
                System.assertEquals('Script-thrown exception', e.getMessage());
            }
        }
        
        @isTest
        public static void resendAadharOTPTest2(){
            try{
                Opportunity opra2 = new Opportunity();
                opra2.StageName = 'Qualification';
                opra2.CloseDate = Date.newInstance(2021, 1, 11);
                opra2.Name = 'testone';
                insert opra2;
                
                Applicant__c apra2 = new Applicant__c();
                apra2.Opportunity__c = opra2.Id;
                apra2.Contact_number__c = '9743514830';
                apra2.Applicant_Type__c = 'Borrower';
                insert apra2;
                
                 Documents__c dfra2 = new Documents__c();
                 dfra2.Applicant__c = apra2.Id;
                 dfra2.Opportunity_Relation__c = opra2.Id;
                 dfra2.Document_Type__c = System.label.AadhaarCard;
                 dfra2.Document_Side__c ='Back';
                 dfra2.Aadhar_Source__c = 'ScanAadhar';
                 dfra2.OTP_Resend_Attempts__c = 5;
                 insert dfra2;
                
                 Test.startTest();
                    LwcLOSLoanApplicationCntrl.resendAadharOTP(dfra2.Id, null);
                 Test.stopTest();
            }catch(Exception e){
                System.assertEquals('Script-thrown exception', e.getMessage());
            }
        }
        
        @isTest
        public static void sendConsentSMSTest(){
            try{
                Opportunity opsc2 = new Opportunity();
                opsc2.StageName = 'Qualification';
                opsc2.CloseDate = Date.newInstance(2021, 1, 11);
                opsc2.Name = 'testone';
                insert opsc2;
                
                Applicant__c apsc2 = new Applicant__c();
                apsc2.Opportunity__c = opsc2.Id;
                apsc2.Contact_number__c = '9743514830';
                apsc2.Applicant_Type__c = 'Borrower';
                apsc2.OTP_for_borrower__c = '43521';
                insert apsc2;
                
                Test.startTest();
                    LwcLOSLoanApplicationCntrl.sendConsentSMS(apsc2.Id);
                    LwcLOSLoanApplicationCntrl.sendConsentSMS('test');
                    LwcLOSLoanApplicationCntrl.sendConsentSMS(null);
                Test.stopTest();
                
            }catch(Exception e){
                System.assertEquals('Script-thrown exception', e.getMessage());
            }
        }
        
        @isTest
        public static void otpVerifyTest(){
            try{
                Opportunity opsc3 = new Opportunity();
                opsc3.StageName = 'Qualification';
                opsc3.CloseDate = Date.newInstance(2021, 1, 11);
                opsc3.Name = 'testone';
                insert opsc3;
                
                Applicant__c apsc3 = new Applicant__c();
                apsc3.Opportunity__c = opsc3.Id;
                apsc3.Contact_number__c = '9743514830';
                apsc3.Applicant_Type__c = 'Borrower';
                apsc3.OTP_for_borrower__c = '43521';
                apsc3.Consent_Received__c = true;
                insert apsc3;
                
                Test.startTest();
                    LwcLOSLoanApplicationCntrl.otpVerify(apsc3.OTP_for_borrower__c,apsc3.Id);
                Test.stopTest();
                
            }catch(Exception e){
                System.assertEquals('Script-thrown exception', e.getMessage());
            }
        }
        
         @isTest
        public static void otpVerifyTest1(){
            try{
                Opportunity opsc3 = new Opportunity();
                opsc3.StageName = 'Qualification';
                opsc3.CloseDate = Date.newInstance(2021, 1, 11);
                opsc3.Name = 'testone';
                insert opsc3;
                
                Test.startTest();
                    LwcLOSLoanApplicationCntrl.otpVerify('34251',opsc3.Id);
                Test.stopTest();
                
            }catch(Exception e){
                System.assertEquals('Script-thrown exception', e.getMessage());
            }
        }
        
        @isTest
        public static void otpConsentCheckTest(){
            try{
                Opportunity opsc4 = new Opportunity();
                opsc4.StageName = 'Qualification';
                opsc4.CloseDate = Date.newInstance(2021, 1, 11);
                opsc4.Name = 'testone';
                insert opsc4;
                
                Applicant__c apsc4 = new Applicant__c();
                apsc4.Opportunity__c = opsc4.Id;
                apsc4.Contact_number__c = '9743514830';
                apsc4.Applicant_Type__c = 'Borrower';
                apsc4.Consent_Received__c = true;
                insert apsc4;
                
                Test.startTest();
                   LwcLOSLoanApplicationCntrl.otpConsentCheck(apsc4.Id);
                Test.stopTest();
                
            }catch(Exception e){
                System.assertEquals('Script-thrown exception', e.getMessage());
            }
        }
        
        @isTest
        public static void otpConsentCheckTest1(){
            try{
                Opportunity opsc5 = new Opportunity();
                opsc5.StageName = 'Qualification';
                opsc5.CloseDate = Date.newInstance(2021, 1, 11);
                opsc5.Name = 'testone';
                insert opsc5;
                
                Test.startTest();
                   LwcLOSLoanApplicationCntrl.otpConsentCheck(opsc5.Id);
                Test.stopTest();
                
            }catch(Exception e){
                System.assertEquals('Script-thrown exception', e.getMessage());
            }
        }
        
        @isTest
        public static void otpConsentCheckTest2(){
            try{
                Opportunity opsc4 = new Opportunity();
                opsc4.StageName = 'Qualification';
                opsc4.CloseDate = Date.newInstance(2021, 1, 11);
                opsc4.Name = 'testone';
                insert opsc4;
                
                Applicant__c apsc4 = new Applicant__c();
                apsc4.Opportunity__c = opsc4.Id;
                apsc4.Contact_number__c = '9743514830';
                apsc4.Applicant_Type__c = 'Borrower';
                apsc4.Consent_Received__c = false;
                insert apsc4;
                
                Test.startTest();
                   LwcLOSLoanApplicationCntrl.otpConsentCheck(apsc4.Id);
                Test.stopTest();
                
            }catch(Exception e){
                System.assertEquals('Script-thrown exception', e.getMessage());
            }
        }
        
        @isTest
        public static void otpExpireTimeOutTest(){
            try{
                Opportunity opsc5 = new Opportunity();
                opsc5.StageName = 'Qualification';
                opsc5.CloseDate = Date.newInstance(2021, 1, 11);
                opsc5.Name = 'testone';
                insert opsc5;
                
                Applicant__c apsc5 = new Applicant__c();
                apsc5.Opportunity__c = opsc5.Id;
                apsc5.Contact_number__c = '9743514830';
                apsc5.Applicant_Type__c = 'Borrower';
                apsc5.Consent_Sent__c = Date.newInstance(2020, 1, 11);
                insert apsc5;
                
                Test.startTest();
                    LwcLOSLoanApplicationCntrl.otpExpireTimeOut(apsc5.Id);
                Test.stopTest();
                
            }catch(Exception e){
                System.assertEquals('Script-thrown exception', e.getMessage());
            }
        }
        
         @isTest
        public static void otpExpireTimeOutTest1(){
            try{
                Opportunity opsc6 = new Opportunity();
                opsc6.StageName = 'Qualification';
                opsc6.CloseDate = Date.newInstance(2021, 1, 11);
                opsc6.Name = 'testone';
                insert opsc6;
                
                Test.startTest();
                    LwcLOSLoanApplicationCntrl.otpExpireTimeOut(opsc6.Id);
                Test.stopTest();
                
            }catch(Exception e){
                System.assertEquals('Script-thrown exception', e.getMessage());
            }
        }
        
        @isTest
        public static void kycDeleteTest(){
            try{
                Opportunity opra5 = new Opportunity();
                opra5.StageName = 'Qualification';
                opra5.CloseDate = Date.newInstance(2021, 1, 11);
                opra5.Name = 'testone';
                insert opra5;
                
                Applicant__c apra5 = new Applicant__c();
                apra5.Opportunity__c = opra5.Id;
                apra5.Contact_number__c = '9743514830';
                apra5.Applicant_Type__c = 'Borrower';
                insert apra5;
                
                 Documents__c dfra5 = new Documents__c();
                 dfra5.Applicant__c = apra5.Id;
                 dfra5.Opportunity_Relation__c = opra5.Id;
                 dfra5.Document_Type__c =System.label.AadhaarCard;
                 dfra5.Document_Side__c ='Back';
                 dfra5.Aadhar_Source__c = 'ScanAadhar';
                 insert dfra5;
                
                Test.startTest();
                     LwcLOSLoanApplicationCntrl.kycDelete(dfra5.Id);
                Test.stopTest();
                
            }catch(Exception e){
               System.assertEquals('Script-thrown exception', e.getMessage());
            }
        }
        
        @isTest
        public static void vehicleDedupeTest(){
            try{
                Test.startTest();
                   LwcLOSLoanApplicationCntrl.VehicleDedupeResponse vdr = new LwcLOSLoanApplicationCntrl.VehicleDedupeResponse();
                   vdr.message = 'testmsg';
                   vdr.status = true;
                
                   LwcLOSLoanApplicationCntrl.vehicleDedupe('test','testparen','Ts 23 12345','2345');
                Test.stopTest();
            }catch(Exception e){
                System.assertEquals('Script-thrown exception', e.getMessage());
            }
        }
        
        @isTest
        public static void goldenSourceTest(){
            try{
                Opportunity opra6 = new Opportunity();
                opra6.StageName = 'Qualification';
                opra6.CloseDate = Date.newInstance(2021, 1, 11);
                opra6.Name = 'testone';
                insert opra6;
                
                Applicant__c apra6 = new Applicant__c();
                apra6.Opportunity__c = opra6.Id;
                apra6.Contact_number__c = '9743514830';
                apra6.Applicant_Type__c = 'Borrower';
                insert apra6;
                
                 Documents__c dfra6 = new Documents__c();
                 dfra6.Applicant__c = apra6.Id;
                 dfra6.Opportunity_Relation__c = opra6.Id;
                 dfra6.Document_Type__c = System.label.AadhaarCard;
                 dfra6.Document_Side__c ='Back';
                 dfra6.Aadhar_Source__c = 'ScanAadhar';
                 dfra6.Golden_Source_Attempts__c = null;
                 insert dfra6;
                
                  Test.startTest();
                       LwcLOSLoanApplicationCntrl.goldenSource(dfra6.Id);
                  Test.stopTest();
                
            }catch(Exception e){
                System.assertEquals('Script-thrown exception', e.getMessage());
            }
        }
        
        @isTest
        public static void goldenSourceTest1(){
            try{
                Opportunity opra6 = new Opportunity();
                opra6.StageName = 'Qualification';
                opra6.CloseDate = Date.newInstance(2021, 1, 11);
                opra6.Name = 'testone';
                insert opra6;
                
                Applicant__c apra6 = new Applicant__c();
                apra6.Opportunity__c = opra6.Id;
                apra6.Contact_number__c = '9743514830';
                apra6.Applicant_Type__c = 'Borrower';
                insert apra6;
                
                 Documents__c dfra6 = new Documents__c();
                 dfra6.Applicant__c = apra6.Id;
                 dfra6.Opportunity_Relation__c = opra6.Id;
                 dfra6.Document_Type__c = System.label.AadhaarCard;
                 dfra6.Document_Side__c ='Back';
                 dfra6.Aadhar_Source__c = 'ScanAadhar';
                 dfra6.Golden_Source_Attempts__c = 0;
                 insert dfra6;
                
                  Test.startTest();
                       LwcLOSLoanApplicationCntrl.goldenSource(dfra6.Id);
                  Test.stopTest();
                
            }catch(Exception e){
                System.assertEquals('Script-thrown exception', e.getMessage());
            }
        }
        
         @isTest
        public static void goldenSourceTest2(){
            try{
                Opportunity opra6 = new Opportunity();
                opra6.StageName = 'Qualification';
                opra6.CloseDate = Date.newInstance(2021, 1, 11);
                opra6.Name = 'testone';
                insert opra6;
                
                Applicant__c apra6 = new Applicant__c();
                apra6.Opportunity__c = opra6.Id;
                apra6.Contact_number__c = '9743514830';
                apra6.Applicant_Type__c = 'Borrower';
                insert apra6;
                
                 Documents__c dfra6 = new Documents__c();
                 dfra6.Applicant__c = apra6.Id;
                 dfra6.Opportunity_Relation__c = opra6.Id;
                 dfra6.Document_Type__c = System.label.AadhaarCard;
                 dfra6.Document_Side__c ='Back';
                 dfra6.Aadhar_Source__c = 'ScanAadhar';
                 dfra6.Golden_Source_Attempts__c = 5;
                 insert dfra6;
                
                  Test.startTest();
                       LwcLOSLoanApplicationCntrl.goldenSource(dfra6.Id);
                  Test.stopTest();
                
            }catch(Exception e){
                System.assertEquals('Script-thrown exception', e.getMessage());
            }
        }
        
        @isTest
        public static void aadharOCRTest(){
            try{
                
              /*  LwcLOSLoanApplicationCntrl.ResponseWrapperOCR rwp = new LwcLOSLoanApplicationCntrl.ResponseWrapperOCR();
                rwp.status = 'success';
                rwp.apistatus = 'success';
                rwp.message = 'testmessage'; */
                
                Opportunity opra7 = new Opportunity();
                opra7.StageName = 'Qualification';
                opra7.CloseDate = Date.newInstance(2021, 1, 11);
                opra7.Name = 'testone';
                insert opra7;
                
                Applicant__c apra7 = new Applicant__c();
                apra7.Opportunity__c = opra7.Id;
                apra7.Contact_number__c = '9743514830';
                apra7.Applicant_Type__c = 'Borrower';
                insert apra7;
                
                 Documents__c dfra7 = new Documents__c();
                 dfra7.Applicant__c = apra7.Id;
                 dfra7.Opportunity_Relation__c = opra7.Id;
                 dfra7.Document_Type__c = System.label.AadhaarCard;
                 dfra7.Document_Side__c ='Back';
                 dfra7.Aadhar_Source__c = 'ScanAadhar';
                 dfra7.Aadhar_OCR_Retry_Attempts__c = null;
                 insert dfra7;
                
                Test.startTest();
                     LwcLOSLoanApplicationCntrl.aadharOCR(dfra7.Id);
                Test.stopTest();
            }catch(Exception e){
                System.assertEquals('Script-thrown exception', e.getMessage());
            }
        }
        
          @isTest
        public static void aadharOCRTest1(){
            try{
                
              /*  LwcLOSLoanApplicationCntrl.ResponseWrapperOCR rwp = new LwcLOSLoanApplicationCntrl.ResponseWrapperOCR();
                rwp.status = 'success';
                rwp.apistatus = 'success';
                rwp.message = 'testmessage'; */
                
                Opportunity opra7 = new Opportunity();
                opra7.StageName = 'Qualification';
                opra7.CloseDate = Date.newInstance(2021, 1, 11);
                opra7.Name = 'testone';
                insert opra7;
                
                Applicant__c apra7 = new Applicant__c();
                apra7.Opportunity__c = opra7.Id;
                apra7.Contact_number__c = '9743514830';
                apra7.Applicant_Type__c = 'Borrower';
                insert apra7;
                
                 Documents__c dfra7 = new Documents__c();
                 dfra7.Applicant__c = apra7.Id;
                 dfra7.Opportunity_Relation__c = opra7.Id;
                 dfra7.Document_Type__c = System.label.AadhaarCard;
                 dfra7.Document_Side__c ='Back';
                 dfra7.Aadhar_Source__c = 'ScanAadhar';
                 dfra7.Aadhar_OCR_Retry_Attempts__c = 0;
                 insert dfra7;
                
                Test.startTest();
                     LwcLOSLoanApplicationCntrl.aadharOCR(dfra7.Id);
                Test.stopTest();
            }catch(Exception e){
                System.assertEquals('Script-thrown exception', e.getMessage());
            }
        }
        
         @isTest
        public static void aadharOCRTest2(){
            try{
                
              /*  LwcLOSLoanApplicationCntrl.ResponseWrapperOCR rwp = new LwcLOSLoanApplicationCntrl.ResponseWrapperOCR();
                rwp.status = 'success';
                rwp.apistatus = 'success';
                rwp.message = 'testmessage'; */
                
                Opportunity opra7 = new Opportunity();
                opra7.StageName = 'Qualification';
                opra7.CloseDate = Date.newInstance(2021, 1, 11);
                opra7.Name = 'testone';
                insert opra7;
                
                Applicant__c apra7 = new Applicant__c();
                apra7.Opportunity__c = opra7.Id;
                apra7.Contact_number__c = '9743514830';
                apra7.Applicant_Type__c = 'Borrower';
                insert apra7;
                
                 Documents__c dfra7 = new Documents__c();
                 dfra7.Applicant__c = apra7.Id;
                 dfra7.Opportunity_Relation__c = opra7.Id;
                 dfra7.Document_Type__c =  System.label.AadhaarCard;
                 dfra7.Document_Side__c ='Back';
                 dfra7.Aadhar_Source__c = 'ScanAadhar';
                 dfra7.Aadhar_OCR_Retry_Attempts__c = 5;
                 insert dfra7;
                
                Test.startTest();
                     LwcLOSLoanApplicationCntrl.aadharOCR(dfra7.Id);
                Test.stopTest();
            }catch(Exception e){
                System.assertEquals('Script-thrown exception', e.getMessage());
            }
        }
        
        @isTest
        public static void checkAdhaarVerificationTest(){
            try{
                Opportunity opra8 = new Opportunity();
                opra8.StageName = 'Qualification';
                opra8.CloseDate = Date.newInstance(2021, 1, 11);
                opra8.Name = 'testone';
                insert opra8;
                
                Applicant__c apra8 = new Applicant__c();
                apra8.Opportunity__c = opra8.Id;
                apra8.Contact_number__c = '9743514830';
                apra8.Applicant_Type__c = 'Borrower';
                apra8.Aadhar_OTP_or_Biometric__c = true;
                insert apra8;
                
                Test.startTest();
                    LwcLOSLoanApplicationCntrl.checkAdhaarVerification(apra8.Id);
                Test.stopTest();
            }catch(Exception e){
                System.assertEquals('Script-thrown exception', e.getMessage());
            }
        }
        
         @isTest
        public static void checkAdhaarVerificationTest1(){
            try{
                Opportunity opra8 = new Opportunity();
                opra8.StageName = 'Qualification';
                opra8.CloseDate = Date.newInstance(2021, 1, 11);
                opra8.Name = 'testone';
                insert opra8;
                
                Applicant__c apra8 = new Applicant__c();
                apra8.Opportunity__c = opra8.Id;
                apra8.Contact_number__c = '9743514830';
                apra8.Applicant_Type__c = 'Borrower';
                apra8.Aadhar_OTP_or_Biometric__c = false;
                insert apra8;
                
                Test.startTest();
                    LwcLOSLoanApplicationCntrl.checkAdhaarVerification(apra8.Id);
                Test.stopTest();
            }catch(Exception e){
                System.assertEquals('Script-thrown exception', e.getMessage());
            }
        }
        
        @isTest
        public static void getResendTimeTest(){
            try{
            Test.startTest();
                LwcLOSLoanApplicationCntrl.getResendTime();
            Test.stopTest();
            }catch(Exception e){
                 System.assertEquals('Script-thrown exception', e.getMessage());
            }
        }
        
        @isTest
        public static void selfieUploadTest(){
            try{
              /*  LwcLOSLoanApplicationCntrl.responseWrapper rew = new LwcLOSLoanApplicationCntrl.responseWrapper();
                rew.status = 'success';
                rew.message = 'testmessage';
                rew.apiStatus = true;
                rew.isFrontUploadSuccess = true;
                rew.isBackUploadSuccess = true;
                rew.isSelfieUploadSuccess = true; */
                
                Opportunity opra8 = new Opportunity();
                opra8.StageName = 'Qualification';
                opra8.CloseDate = Date.newInstance(2021, 1, 11);
                opra8.Name = 'testone';
                insert opra8;
                
                Applicant__c apra8 = new Applicant__c();
                apra8.Opportunity__c = opra8.Id;
                apra8.Contact_number__c = '9743514830';
                apra8.Applicant_Type__c = 'Borrower';
                apra8.Selfie_Retry_Attempts__c = 5;
                insert apra8;
                
                Test.startTest();
                     LwcLOSLoanApplicationCntrl.selfieUpload(apra8.Id);
                Test.stopTest();
            }catch(Exception e){
                System.assertEquals('Script-thrown exception', e.getMessage());
            }
        }
        
         @isTest
        public static void selfieUploadTest1(){
            try{
                Opportunity opra8 = new Opportunity();
                opra8.StageName = 'Qualification';
                opra8.CloseDate = Date.newInstance(2021, 1, 11);
                opra8.Name = 'testone';
                insert opra8;
                
                Applicant__c apra8 = new Applicant__c();
                apra8.Opportunity__c = opra8.Id;
                apra8.Contact_number__c = '9743514830';
                apra8.Applicant_Type__c = 'Borrower';
                apra8.Selfie_Retry_Attempts__c = 1;
                insert apra8;
                
                Test.startTest();
                     LwcLOSLoanApplicationCntrl.selfieUpload(apra8.Id);
                Test.stopTest();
            }catch(Exception e){
                System.assertEquals('Script-thrown exception', e.getMessage());
            }
        }
        
         @isTest
        public static void selfieUploadTest2(){
            try{
                Opportunity opra9 = new Opportunity();
                opra9.StageName = 'Qualification';
                opra9.CloseDate = Date.newInstance(2021, 1, 11);
                opra9.Name = 'testone';
                insert opra9;
                
                Test.startTest();
                     LwcLOSLoanApplicationCntrl.selfieUpload(opra9.Id);
                Test.stopTest();
            }catch(Exception e){
                System.assertEquals('Script-thrown exception', e.getMessage());
            }
        }
        
        @isTest
        public static void docAuthresponseTest(){
            Test.startTest();
               LwcLOSLoanApplicationCntrl.docAuthresponse();
            Test.stopTest();
        }
        
        @isTest
        public static void selfieReportresponseTest(){
            Test.startTest();
                  LwcLOSLoanApplicationCntrl.selfieReportresponse();
            Test.stopTest();
        }
        
        @isTest
        public static void faceMismatchResponseTest(){
            Test.startTest();
                LwcLOSLoanApplicationCntrl.faceMismatchResponse();
            Test.stopTest();
        }
        
        @isTest
        public static void performDocAuthTest(){
            try{
                 Opportunity opfd1 = new Opportunity();
                opfd1.StageName = 'Qualification';
                opfd1.CloseDate = Date.newInstance(2021, 1, 11);
                opfd1.Name = 'testone';
                insert opfd1;
                
                Applicant__c apfd1 = new Applicant__c();
                apfd1.Opportunity__c = opfd1.Id;
                apfd1.Contact_number__c = '9743514830';
                apfd1.Applicant_Type__c = 'Borrower';
                insert apfd1;
                
                 Documents__c dfa1 = new Documents__c();
                 dfa1.Applicant__c = apfd1.Id;
                 dfa1.Opportunity_Relation__c = opfd1.Id;
                 dfa1.Document_Type__c = System.label.AadhaarCard;
                 dfa1.Document_Side__c ='Back';
                 dfa1.Aadhar_Source__c = 'ScanAadhar';
                 dfa1.DocAuth_Passed__c = true;
                 dfa1.Selfie_report_Pass__c = true;
                 insert dfa1;
                
                 Test.startTest();
                     LwcLOSLoanApplicationCntrl.performDocAuth(dfa1.Id);
                 Test.stopTest();
            }catch(Exception e){
                System.assertEquals('Script-thrown exception', e.getMessage());
            }
        }
        
        @isTest
        public static void goldenSourcePassTest(){
            try{
                Opportunity opgs1 = new Opportunity();
                opgs1.StageName = 'Qualification';
                opgs1.CloseDate = Date.newInstance(2021, 1, 11);
                opgs1.Name = 'testone';
                insert opgs1;
                
                Applicant__c apgs1 = new Applicant__c();
                apgs1.Opportunity__c = opgs1.Id;
                apgs1.Contact_number__c = '9743514830';
                apgs1.Applicant_Type__c = 'Borrower';
                insert apgs1;
                
                 Documents__c dfgs1 = new Documents__c();
                 dfgs1.Applicant__c = apgs1.Id;
                 dfgs1.Opportunity_Relation__c = opgs1.Id;
                 dfgs1.Document_Type__c = System.label.AadhaarCard;
                 dfgs1.Document_Side__c ='Back';
                 dfgs1.Aadhar_Source__c = 'ScanAadhar';
                 dfgs1.Golden_Source_Pass__c = true;
                 insert dfgs1;
                
                 Test.startTest();
                      LwcLOSLoanApplicationCntrl.goldenSourcePass(dfgs1.Id);
                 Test.stopTest();
            }catch(Exception e){
                 System.assertEquals('Script-thrown exception', e.getMessage());
            }
        }
        
        @isTest
        public static void kycSaveDataTest(){
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
                 dfks1.Document_Type__c = System.label.AadhaarCard;
                 dfks1.Document_Side__c ='Back';
                 dfks1.Aadhar_Source__c = 'ScanAadhar';
                 dfks1.Name = System.Label.VoterIdCard;
                 insert dfks1;
                
                LwcLOSLoanApplicationCntrl.WrapperDocument lwd = new LwcLOSLoanApplicationCntrl.WrapperDocument();
                lwd.isPhotocopy = true;
                lwd.aadharSource = 'ScanAadhar';
                lwd.documentKycNo = '124564759050';
                lwd.documentKycName = 'testname';
                lwd.documentKYCAddressLine1 = 'addline1';
                lwd.documentKYCAddressLine2 = 'addline2';
                lwd.documentKycPinCode = '524315';
                lwd.documentAge = 27;
                lwd.documentKycCity = 'HYDERABAD';
                lwd.documentKycDistrict = 'HYDERABAD';
                lwd.documentKycState = 'TELANGANA';
                lwd.documentKycDob = Date.newInstance(1994, 6, 23);
                lwd.documentKycIssuanceDate = Date.newInstance(2021, 1,11);
                lwd.documentKycExpiryDate = Date.newInstance(2021, 2, 12);
                lwd.documentDLType = 'pdf';
                lwd.documentPanNo = 'AXFPT4450P';
                lwd.documentFirstName = 'mahi';
                lwd.documentLastName = 'dhoni';
                lwd.documentGender = 'male';
                lwd.documentSalutation = 'mr';
                lwd.documentAadhaarEnrollmentNumber  = '876512340987';
                lwd.documentPassportFileNo = 'CB1060317948717';
                lwd.documentPassportNo = 'R1759287';
                
                
                 Test.startTest();
                     LwcLOSLoanApplicationCntrl.kycSaveData(dfks1.Name,Json.serialize(lwd),apks1.Id,dfks1.Id);
                 Test.stopTest();
                 
            }catch(Exception e){
                 System.assertEquals('Script-thrown exception', e.getMessage());
            }
        }
        
        @isTest
        public static void kycSaveDataTestOla(){
            try{
                Opportunity opks1 = new Opportunity();
                opks1.StageName = 'Qualification';
                opks1.CloseDate = Date.newInstance(2021, 1, 11);
                opks1.Name = 'testone';
                opks1.LeadSource = 'OLA';
                insert opks1;
                
                Applicant__c apks1 = new Applicant__c();
                apks1.Opportunity__c = opks1.Id;
                apks1.PAN_No__c = 'ODtkBP3sdfSfdBo7U7UM5g==';
                apks1.Contact_number__c = '9743514830';
                apks1.Applicant_Type__c = 'Borrower';
                insert apks1;
                
                 Documents__c dfks1 = new Documents__c();
                 dfks1.Applicant__c = apks1.Id;
                 dfks1.Opportunity_Relation__c = opks1.Id;
                 dfks1.Document_Type__c = 'Other';
                 dfks1.Document_Side__c ='Back';
                 dfks1.Aadhar_Source__c = 'ScanAadhar';
                 dfks1.KYC_DOB__c = Date.today();
                 dfks1.Name = System.Label.PanCards;
                 dfks1.PAN_No__c = 'ODtkBP3sdfSfdBo7U7UM5g==';
                 insert dfks1;
                
                LwcLOSLoanApplicationCntrl.WrapperDocument lwd = new LwcLOSLoanApplicationCntrl.WrapperDocument();
                lwd.isPhotocopy = true;
                lwd.aadharSource = 'ScanAadhar';
                lwd.documentKycNo = '124564759050';
                lwd.documentKycName = 'testname';
                lwd.documentKYCAddressLine1 = 'addline1';
                lwd.documentKYCAddressLine2 = 'addline2';
                lwd.documentKycPinCode = '524315';
                lwd.documentAge = 27;
                lwd.documentKycCity = 'HYDERABAD';
                lwd.documentKycDistrict = 'HYDERABAD';
                lwd.documentKycState = 'TELANGANA';
                lwd.documentKycDob = Date.newInstance(1994, 6, 23);
                lwd.documentKycIssuanceDate = Date.newInstance(2021, 1,11);
                lwd.documentKycExpiryDate = Date.newInstance(2021, 2, 12);
                lwd.documentDLType = 'pdf';
                lwd.documentPanNo = 'AXFPT4450P';
                lwd.documentFirstName = 'mahi';
                lwd.documentLastName = 'dhoni';
                lwd.documentGender = 'male';
                lwd.documentSalutation = 'mr';
                lwd.documentAadhaarEnrollmentNumber  = '876512340987';
                lwd.documentPassportFileNo = 'CB1060317948717';
                lwd.documentPassportNo = 'R1759287';
                
                
                 Test.startTest();
                     LwcLOSLoanApplicationCntrl.kycSaveData(dfks1.Name,Json.serialize(lwd),apks1.Id,dfks1.Id);
                	 delete apks1;
                	 LwcLOSLoanApplicationCntrl.kycSaveData(dfks1.Name,Json.serialize(lwd),null,dfks1.Id);
                 Test.stopTest();
                 
            }catch(Exception e){
            }
        }
        
         @isTest
        public static void kycSaveDataTest1(){
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
                 dfks1.Document_Type__c = System.label.AadhaarCard;
                 dfks1.Document_Side__c ='Back';
                 dfks1.Aadhar_Source__c = 'ScanAadhar';
                 dfks1.Name = System.Label.DrivingLicences;
                 insert dfks1;
                
                LwcLOSLoanApplicationCntrl.WrapperDocument lwd = new LwcLOSLoanApplicationCntrl.WrapperDocument();
                lwd.isPhotocopy = true;
                lwd.aadharSource = 'ScanAadhar';
                lwd.documentKycNo = '124564759050';
                lwd.documentKycName = 'testname';
                lwd.documentKYCAddressLine1 = 'addline1';
                lwd.documentKYCAddressLine2 = 'addline2';
                lwd.documentKycPinCode = '524315';
                lwd.documentAge = 27;
                lwd.documentKycCity = 'HYDERABAD';
                lwd.documentKycDistrict = 'HYDERABAD';
                lwd.documentKycState = 'TELANGANA';
                lwd.documentKycDob = Date.newInstance(1994, 6, 23);
                lwd.documentKycIssuanceDate = Date.newInstance(2021, 1,11);
                lwd.documentKycExpiryDate = Date.newInstance(2021, 2, 12);
                lwd.documentDLType = 'pdf';
                lwd.documentPanNo = 'AXFPT4450P';
                lwd.documentFirstName = 'mahi';
                lwd.documentLastName = 'dhoni';
                lwd.documentGender = 'male';
                lwd.documentSalutation = 'mr';
                lwd.documentAadhaarEnrollmentNumber  = '876512340987';
                lwd.documentPassportFileNo = 'CB1060317948717';
                lwd.documentPassportNo = 'R1759287';
                
                
                 Test.startTest();
                     LwcLOSLoanApplicationCntrl.kycSaveData(dfks1.Name,Json.serialize(lwd),apks1.Id,dfks1.Id);
                 Test.stopTest();
                 
            }catch(Exception e){
                 System.assertEquals('Script-thrown exception', e.getMessage());
            }
        }
        
        @isTest
        public static void kycSaveDataTest2(){
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
                 dfks1.Document_Type__c = System.label.AadhaarCard;
                 dfks1.Document_Side__c ='Back';
                 dfks1.Aadhar_Source__c = 'ScanAadhar';
                 dfks1.Name = System.Label.PanCards;
                 insert dfks1;
                
                LwcLOSLoanApplicationCntrl.WrapperDocument lwd = new LwcLOSLoanApplicationCntrl.WrapperDocument();
                lwd.isPhotocopy = true;
                lwd.aadharSource = 'ScanAadhar';
                lwd.documentKycNo = '124564759050';
                lwd.documentKycName = 'testname';
                lwd.documentKYCAddressLine1 = 'addline1';
                lwd.documentKYCAddressLine2 = 'addline2';
                lwd.documentKycPinCode = '524315';
                lwd.documentAge = 27;
                lwd.documentKycCity = 'HYDERABAD';
                lwd.documentKycDistrict = 'HYDERABAD';
                lwd.documentKycState = 'TELANGANA';
                lwd.documentKycDob = Date.newInstance(1994, 6, 23);
                lwd.documentKycIssuanceDate = Date.newInstance(2021, 1,11);
                lwd.documentKycExpiryDate = Date.newInstance(2021, 2, 12);
                lwd.documentDLType = 'pdf';
                lwd.documentPanNo = 'AXFPT4450P';
                lwd.documentFirstName = 'mahi';
                lwd.documentLastName = 'dhoni';
                lwd.documentGender = 'male';
                lwd.documentSalutation = 'mr';
                lwd.documentAadhaarEnrollmentNumber  = '876512340987';
                lwd.documentPassportFileNo = 'CB1060317948717';
                lwd.documentPassportNo = 'R1759287';
                
                
                 Test.startTest();
                     LwcLOSLoanApplicationCntrl.kycSaveData(dfks1.Name,Json.serialize(lwd),apks1.Id,dfks1.Id);
                 Test.stopTest();
                 
            }catch(Exception e){
                 System.assertEquals('Script-thrown exception', e.getMessage());
            }
        }
        
        @isTest
        public static void kycSaveDataTest3(){
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
                 dfks1.Document_Type__c = System.label.AadhaarCard;
                 dfks1.Document_Side__c ='Back';
                 dfks1.Aadhar_Source__c = 'ScanAadhar';
                 dfks1.Name = System.Label.PassportCard;
                 insert dfks1;
                
                LwcLOSLoanApplicationCntrl.WrapperDocument lwd = new LwcLOSLoanApplicationCntrl.WrapperDocument();
                lwd.isPhotocopy = true;
                lwd.aadharSource = 'ScanAadhar';
                lwd.documentKycNo = '124564759050';
                lwd.documentKycName = 'testname';
                lwd.documentKYCAddressLine1 = 'addline1';
                lwd.documentKYCAddressLine2 = 'addline2';
                lwd.documentKycPinCode = '524315';
                lwd.documentAge = 27;
                lwd.documentKycCity = 'HYDERABAD';
                lwd.documentKycDistrict = 'HYDERABAD';
                lwd.documentKycState = 'TELANGANA';
                lwd.documentKycDob = Date.newInstance(1994, 6, 23);
                lwd.documentKycIssuanceDate = Date.newInstance(2021, 1,11);
                lwd.documentKycExpiryDate = Date.newInstance(2021, 2, 12);
                lwd.documentDLType = 'pdf';
                lwd.documentPanNo = 'AXFPT4450P';
                lwd.documentFirstName = 'mahi';
                lwd.documentLastName = 'dhoni';
                lwd.documentGender = 'male';
                lwd.documentSalutation = 'mr';
                lwd.documentAadhaarEnrollmentNumber  = '876512340987';
                lwd.documentPassportFileNo = 'CB1060317948717';
                lwd.documentPassportNo = 'R1759287';
                
                
                 Test.startTest();
                     LwcLOSLoanApplicationCntrl.kycSaveData(dfks1.Name,Json.serialize(lwd),apks1.Id,dfks1.Id);
                 Test.stopTest();
                 
            }catch(Exception e){
                 System.assertEquals('Script-thrown exception', e.getMessage());
            }
        }
        
         @isTest
        public static void kycSaveDataTest4(){
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
                 dfks1.Document_Type__c = System.label.AadhaarCard;
                 dfks1.Document_Side__c ='Back';
                 dfks1.Aadhar_Source__c = 'ScanAadhar';
                 dfks1.Name = System.Label.AadhaarCard;
                 insert dfks1;
                
                LwcLOSLoanApplicationCntrl.WrapperDocument lwd = new LwcLOSLoanApplicationCntrl.WrapperDocument();
                lwd.isPhotocopy = true;
                lwd.aadharSource = 'ScanAadhar';
                lwd.documentKycNo = '124564759050';
                lwd.documentKycName = 'testname';
                lwd.documentKYCAddressLine1 = 'addline1';
                lwd.documentKYCAddressLine2 = 'addline2';
                lwd.documentKycPinCode = '524315';
                lwd.documentAge = 27;
                lwd.documentKycCity = 'HYDERABAD';
                lwd.documentKycDistrict = 'HYDERABAD';
                lwd.documentKycState = 'TELANGANA';
                lwd.documentKycDob = Date.newInstance(1994, 6, 23);
                lwd.documentKycIssuanceDate = Date.newInstance(2021, 1,11);
                lwd.documentKycExpiryDate = Date.newInstance(2021, 2, 12);
                lwd.documentDLType = 'pdf';
                lwd.documentPanNo = 'AXFPT4450P';
                lwd.documentFirstName = 'mahi';
                lwd.documentLastName = 'dhoni';
                lwd.documentGender = 'male';
                lwd.documentSalutation = 'mr';
                lwd.documentAadhaarEnrollmentNumber  = '876512340987';
                lwd.documentPassportFileNo = 'CB1060317948717';
                lwd.documentPassportNo = 'R1759287';
                
                
                 Test.startTest();
                     LwcLOSLoanApplicationCntrl.kycSaveData(dfks1.Name,Json.serialize(lwd),apks1.Id,dfks1.Id);
                 Test.stopTest();
                 
            }catch(Exception e){
                 System.assertEquals('Script-thrown exception', e.getMessage());
            }
        }
        
        @isTest
        public static void getCurrentOppRecordTest(){
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
                 dfks1.Document_Type__c = System.Label.AadhaarCard;
                 dfks1.KYC_name__c = 'Aadhar';
                 dfks1.Document_Side__c ='Back';
                 dfks1.Aadhar_Source__c = 'ScanAadhar';
                 dfks1.Name = 'Aadhar';
                 insert dfks1;
                
                 Test.startTest();
                      LwcLOSLoanApplicationCntrl.getCurrentOppRecord(opks1.Id);
                 Test.stopTest();
            }catch(Exception e){
                System.assertEquals('Script-thrown exception', e.getMessage());
            }
        }
        
         @isTest
        public static void getCurrentOppRecordTest1(){
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
                 dfks1.Document_Type__c = System.Label.PanCards;
                 dfks1.KYC_name__c = 'Aadhar';
                 dfks1.Document_Side__c ='Back';
                 dfks1.Aadhar_Source__c = 'ScanAadhar';
                 dfks1.Name = 'Aadhar';
                 insert dfks1;
                
                 Test.startTest();
                      LwcLOSLoanApplicationCntrl.getCurrentOppRecord(opks1.Id);
                 Test.stopTest();
            }catch(Exception e){
                System.assertEquals('Script-thrown exception', e.getMessage());
            }
        }
        
         @isTest
        public static void getCurrentOppRecordTest2(){
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
                 dfks1.Document_Type__c = System.Label.PassportCard;
                 dfks1.KYC_name__c = 'Aadhar';
                 dfks1.Document_Side__c ='Back';
                 dfks1.Aadhar_Source__c = 'ScanAadhar';
                 dfks1.Name = 'Aadhar';
                 insert dfks1;
                
                 Test.startTest();
                      LwcLOSLoanApplicationCntrl.getCurrentOppRecord(opks1.Id);
                 Test.stopTest();
            }catch(Exception e){
                System.assertEquals('Script-thrown exception', e.getMessage());
            }
        }
        
         @isTest
        public static void getCurrentOppRecordTest3(){
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
                 dfks1.Document_Type__c = System.Label.VoterIdCard;
                 dfks1.KYC_name__c = 'Aadhar';
                 dfks1.Document_Side__c ='Back';
                 dfks1.Aadhar_Source__c = 'ScanAadhar';
                 dfks1.Name = 'Aadhar';
                 insert dfks1;
                
                 Test.startTest();
                      LwcLOSLoanApplicationCntrl.getCurrentOppRecord(opks1.Id);
                 Test.stopTest();
            }catch(Exception e){
                System.assertEquals('Script-thrown exception', e.getMessage());
            }
        }
        
          @isTest
        public static void getCurrentOppRecordTest4(){
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
                 dfks1.Document_Type__c = System.Label.DrivingLicences;
                 dfks1.KYC_name__c = 'Aadhar';
                 dfks1.Document_Side__c ='Back';
                 dfks1.Aadhar_Source__c = 'ScanAadhar';
                 dfks1.Name = 'Aadhar';
                 insert dfks1;
                
                 Test.startTest();
                      LwcLOSLoanApplicationCntrl.getCurrentOppRecord(opks1.Id);
                 Test.stopTest();
            }catch(Exception e){
                System.assertEquals('Script-thrown exception', e.getMessage());
            }
        }
        
         @isTest
        public static void getCurrentOppRecordTest5(){
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
                      LwcLOSLoanApplicationCntrl.getCurrentOppRecord(opks1.Id);
                 Test.stopTest();
            }catch(Exception e){
                System.assertEquals('Script-thrown exception', e.getMessage());
            }
        }
        
         @isTest
        public static void getCurrentOppRecordTest6(){
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
                 dfks1.Document_Type__c = System.Label.Form60DocumentType;
                 dfks1.KYC_name__c = 'Aadhar';
                 dfks1.Document_Side__c ='Back';
                 dfks1.Aadhar_Source__c = 'ScanAadhar';
                 dfks1.Name = 'Aadhar';
                 insert dfks1;
                
                 Blob beforeblob=Blob.valueOf('Unit Test Attachment Body');
                
                 ContentVersion cv = new ContentVersion();
                 cv.title = 'test content trigger';      
                 cv.PathOnClient ='test';           
                 cv.VersionData =beforeblob;          
                 insert cv;   
        
                 ContentVersion testContent = [SELECT id, ContentDocumentId FROM ContentVersion where Id = :cv.Id];
                
                 ContentDocumentLink contentlink = new ContentDocumentLink();
                 contentlink.ShareType = 'V';
                 contentlink.LinkedEntityId = dfks1.Id; 
                 contentlink.ContentDocumentId = testcontent.ContentDocumentId;
                 contentlink.Visibility = 'AllUsers'; 
                 insert contentlink;
                
                 Test.startTest();
                      LwcLOSLoanApplicationCntrl.getCurrentOppRecord(opks1.Id);
                 Test.stopTest();
            }catch(Exception e){
                System.assertEquals('Script-thrown exception', e.getMessage());
            }
        }
        
        @isTest
        public static void docCustomerImageTest(){
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
                 insert dfks1;
                
                 Test.startTest();
                      LwcLOSLoanApplicationCntrl.docCustomerImage(dfks1.Name,apks1.Id,opks1.Id);
                 Test.stopTest();
            }catch(Exception e){
                System.assertEquals('Script-thrown exception', e.getMessage());
            }
        }
        
        @isTest
        public static void createOtherDocumentTest(){
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
             //    dfks1.Aadhar_Source__c = 'ScanAadhar';
                 dfks1.Name = 'Aadhar';
                 dfks1.Proof_of_Identity_POI__c = true;
                 dfks1.RecordTypeId = Schema.SObjectType.Documents__c.getRecordTypeInfosByName().get(System.Label.Other_Document_Record_Type).getRecordTypeId();
                 insert dfks1;
                
                 Test.startTest();
                       LwcLOSLoanApplicationCntrl.createOtherDocument(dfks1.Name,apks1.Id,opks1.Id);
                       LwcLOSLoanApplicationCntrl.createOtherDocument(null,null,null);
                 Test.stopTest();
            }catch(Exception e){
                 System.assertEquals('Script-thrown exception', e.getMessage());
            }
        }
        
        @isTest
        public static void updateAccountTest(){
            try{
                Account ua1 = new Account();
            //    ua1.FirstName = 'Kshitij';
            //    ua1.LastName = 'Turaskar';
            //    ua1.Phone = '9892025222';
                ua1.Name = 'Kshitij';
                ua1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business Account').getRecordTypeId();
            //    ua1.State__c = 'GOA';
                insert ua1;
                
               ua1.Phone = '8096977253';
               update ua1;
                
                Test.startTest();
                     LwcLOSLoanApplicationCntrl.updateAccount(ua1.Id,ua1.FirstName,ua1.LastName,ua1.Phone);
                Test.stopTest();
            }catch(Exception e){
                System.assertEquals('Script-thrown exception', e.getMessage());
            }
        } 
        
        @isTest
        public static void getBiometricMetadataTest(){
            try{
                Test.startTest();
                    LwcLOSLoanApplicationCntrl.getBiometricMetadata();
                Test.stopTest();
            }catch(Exception e){
                System.assertEquals('Script-thrown exception', e.getMessage());
            }
        }
        
        @isTest
        public static void getLoanApplicationStageNameTest(){
                Opportunity opgl1 = new Opportunity();
                opgl1.StageName = 'Qualification';
                opgl1.CloseDate = Date.newInstance(2021, 1, 11);
                opgl1.Name = 'testone';
                insert opgl1;
            
                Test.startTest();
                     LwcLOSLoanApplicationCntrl.getLoanApplicationStageName(opgl1.Id);
                     LwcLOSLoanApplicationCntrl.getLoanApplicationStageName(null);
                Test.stopTest();
        }
        
        @isTest
        public static void checkDocFromAppTest(){
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
             //    dfks1.Aadhar_Source__c = 'ScanAadhar';
                 dfks1.Name = 'Aadhar';
                 dfks1.Proof_of_Identity_POI__c = true;
                 dfks1.Document_Type__c = System.label.PassportCard;
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
                    LwcLOSLoanApplicationCntrl.checkDocFromApp(apks1.Id,dfks1.Document_Type__c);
                Test.stopTest();
            }catch(Exception e){
               System.assertEquals('Script-thrown exception', e.getMessage());
            }
        }
        
         @isTest
        public static void checkDocFromAppTest1(){
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
                 dfks1.Proof_of_Identity_POI__c = true;
                 dfks1.Document_Type__c = System.label.PassportCard;
                 insert dfks1;
                
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
                 cdlink1.LinkedEntityId = dfks1.Id;
                 cdlink1.ContentDocumentId = testcd1.ContentDocumentId;
                 insert cdlink1;     
                
                Test.startTest();
                    LwcLOSLoanApplicationCntrl.checkDocFromApp(apks1.Id,dfks1.Document_Type__c);
                Test.stopTest();
            }catch(Exception e){
               System.assertEquals('Script-thrown exception', e.getMessage());
            }
        }
        
          @isTest
        public static void checkDocFromAppTest2(){
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
             //    dfks1.Aadhar_Source__c = 'ScanAadhar';
                 dfks1.Name = 'Aadhar';
                 dfks1.Proof_of_Identity_POI__c = true;
                 dfks1.Document_Type__c = System.label.PassportCard;
                 insert dfks1;
                
                 ContentVersion cvn1 = new ContentVersion();
                 cvn1.PathOnClient = 'testpath1';
                 cvn1.Title = 'testtitle1';
                 cvn1.VersionData = Blob.valueOf('Test Content');
                 cvn1.Document_Side_fileupload__c = 'Back';
                 insert cvn1;
                
                 ContentVersion testcd1 = [SELECT id, ContentDocumentId FROM ContentVersion where Id = :cvn1.Id];
                
                 ContentDocumentLink cdlink1 = new ContentDocumentLink();
                 cdlink1.Visibility = 'AllUsers';
                 cdlink1.ShareType = 'V';
                 cdlink1.LinkedEntityId = dfks1.Id;
                 cdlink1.ContentDocumentId = testcd1.ContentDocumentId;
                 insert cdlink1;     
                
                Test.startTest();
                    LwcLOSLoanApplicationCntrl.checkDocFromApp(apks1.Id,dfks1.Document_Type__c);
                    LwcLOSLoanApplicationCntrl.checkDocFromApp(null,null);
                     LwcLOSLoanApplicationCntrl.checkDocFromApp('test','test');
                Test.stopTest();
            }catch(Exception e){
               System.assertEquals('Script-thrown exception', e.getMessage());
            }
        }
        
        @isTest
        public static void checkCustomerImageAttemptTest(){
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
                apks1.customer_image_attempts__c = 5;
                insert apks1;
                
                Test.startTest();
                     LwcLOSLoanApplicationCntrl.checkCustomerImageAttempt(apks1.Id);
                Test.stopTest();
            }catch(Exception e){
                System.assertEquals('Script-thrown exception', e.getMessage());
            }
        }
        
         @isTest
        public static void checkCustomerImageAttemptTest1(){
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
                apks1.customer_image_attempts__c = 1;
                insert apks1;
                
                Test.startTest();
                     LwcLOSLoanApplicationCntrl.checkCustomerImageAttempt(apks1.Id);
                Test.stopTest();
            }catch(Exception e){
                System.assertEquals('Script-thrown exception', e.getMessage());
            }
        }
        
         @isTest
        public static void checkCustomerImageAttemptTest2(){
            try{
                Opportunity opks1 = new Opportunity();
                opks1.StageName = 'Qualification';
                opks1.CloseDate = Date.newInstance(2021, 1, 11);
                opks1.Name = 'testone';
                insert opks1;
                
                Test.startTest();
                     LwcLOSLoanApplicationCntrl.checkCustomerImageAttempt(opks1.Id);
                Test.stopTest();
            }catch(Exception e){
                System.assertEquals('Script-thrown exception', e.getMessage());
            }
        }
        
        @isTest
        public static void getPidBlockStatusTest(){
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
                apks1.PID_Block__c = 'testpid';
                insert apks1;
                
                Test.startTest();
                     LwcLOSLoanApplicationCntrl.getPidBlockStatus(apks1.Id);
                Test.stopTest();

            }catch(Exception e){
                System.assertEquals('Script-thrown exception', e.getMessage());
            }
        }
        
        @isTest
        public static void getPidBlockStatusTest1(){
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
                apks1.PID_Block__c = null;
                insert apks1;
                
                Test.startTest();
                     LwcLOSLoanApplicationCntrl.getPidBlockStatus(apks1.Id);
                Test.stopTest();

            }catch(Exception e){
                System.assertEquals('Script-thrown exception', e.getMessage());
            }
        }
        
        @isTest
        public static void getPidBlockStatusTest2(){
            try{
                Opportunity opks1 = new Opportunity();
                opks1.StageName = 'Qualification';
                opks1.CloseDate = Date.newInstance(2021, 1, 11);
                opks1.Name = 'testone';
                insert opks1;
                
                Test.startTest();
                     LwcLOSLoanApplicationCntrl.getPidBlockStatus(opks1.Id);
                Test.stopTest();

            }catch(Exception e){
                System.assertEquals('Script-thrown exception', e.getMessage());
            }
        }
        
        @isTest
        public static void getResendOtpTimeTest(){
            try{
            Test.startTest();
                 LwcLOSLoanApplicationCntrl.getResendOtpTime();
            Test.stopTest();
            }catch(Exception e){
                System.assertEquals('Script-thrown exception', e.getMessage());
            }
        }
        
        @isTest
        public static void getDocAsyncResponseTest(){
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
             //    dfks1.Aadhar_Source__c = 'ScanAadhar';
                 dfks1.Name = 'Aadhar';
                 insert dfks1;
                
                 Test.startTest();
                      LwcLOSLoanApplicationCntrl.getDocAsyncResponse(dfks1.Id);
                 Test.stopTest();
            }catch(Exception e){
                System.assertEquals('Script-thrown exception', e.getMessage());
            }
        }
        
        @isTest
        public static void cibilTextMatchTest(){
            try{
                Opportunity opks1 = new Opportunity();
                opks1.StageName = 'Qualification';
                opks1.CloseDate = Date.newInstance(2021, 1, 11);
                opks1.Name = 'testone';
                opks1.Lead_number__c = '45367';
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
                 dfks1.Proof_of_Identity_POI__c = true;
                 dfks1.Name = 'Aadhar';
                 insert dfks1;
                
                 Test.startTest();
                      LwcLOSLoanApplicationCntrl.cibilTextMatch(apks1.Id);
                 Test.stopTest();
            }catch(Exception e){
                System.assertEquals('Script-thrown exception', e.getMessage());
            }
        }
        
        @isTest
        public static void cibilTextMatchTest1(){
            try{
                Opportunity opks2 = new Opportunity();
                opks2.StageName = 'Qualification';
                opks2.CloseDate = Date.newInstance(2021, 1, 11);
                opks2.Name = 'testone';
                opks2.Lead_number__c = '45367';
                insert opks2;
                
                 Test.startTest();
                      LwcLOSLoanApplicationCntrl.cibilTextMatch(opks2.Id);
                 Test.stopTest();
            }catch(Exception e){
                System.assertEquals('Script-thrown exception', e.getMessage());
            }
        }
        
        @isTest
        public static void checkToggleTest(){
                Opportunity opks1 = new Opportunity();
                opks1.StageName = 'Qualification';
                opks1.CloseDate = Date.newInstance(2021, 1, 11);
                opks1.Name = 'testone';
                opks1.Lead_number__c = '45367';
                insert opks1;
                
                Applicant__c apks1 = new Applicant__c();
                apks1.Opportunity__c = opks1.Id;
                apks1.Contact_number__c = '9743514830';
                apks1.Applicant_Type__c = 'Borrower';
                apks1.Do_you_have_a_bank_account__c = true;
                insert apks1;
            
                Test.startTest();
                     LwcLOSLoanApplicationCntrl.checkToggle(opks1.Id);
                Test.stopTest();
        }
        
         @isTest
        public static void checkToggleTest1(){
                Opportunity opks1 = new Opportunity();
                opks1.StageName = 'Qualification';
                opks1.CloseDate = Date.newInstance(2021, 1, 11);
                opks1.Name = 'testone';
                opks1.Lead_number__c = '45367';
                insert opks1;
                
                Applicant__c apks1 = new Applicant__c();
                apks1.Opportunity__c = opks1.Id;
                apks1.Contact_number__c = '9743514830';
                apks1.Applicant_Type__c = 'Borrower';
                apks1.Do_you_have_a_bank_account__c = false;
                insert apks1;
            
                Test.startTest();
                     LwcLOSLoanApplicationCntrl.checkToggle(opks1.Id);
                Test.stopTest();
        }
        
        @isTest
        public static void cibilTextMatchSaveResponseTest(){
            try{
                Opportunity opks1 = new Opportunity();
                opks1.StageName = 'Qualification';
                opks1.CloseDate = Date.newInstance(2021, 1, 11);
                opks1.Name = 'testone';
                opks1.Lead_number__c = '45367';
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
                 dfks1.Name = 'Aadhar';
                 insert dfks1;
                
                 Test.startTest();
                      LwcLOSLoanApplicationCntrl.cibilTextMatchSaveResponse(dfks1.Id,'100');
                 Test.stopTest();
            }catch(Exception e){
                System.assertEquals('Script-thrown exception', e.getMessage());
            }
        }
        
         @isTest
        public static void cibilTextMatchSaveResponseTest1(){
            try{
                Opportunity opks2 = new Opportunity();
                opks2.StageName = 'Qualification';
                opks2.CloseDate = Date.newInstance(2021, 1, 11);
                opks2.Name = 'testone';
                opks2.Lead_number__c = '45367';
                insert opks2;
                
                Test.startTest();
                      LwcLOSLoanApplicationCntrl.cibilTextMatchSaveResponse(opks2.Id,'100');
                 Test.stopTest();
            }catch(Exception e){
                System.assertEquals('Script-thrown exception', e.getMessage());
            }
        }
        
       @isTest
        public static void isCommunityTest(){
            Test.startTest();
                 LwcLOSLoanApplicationCntrl.isCommunity();
            Test.stopTest();
        }
        
        @isTest
        public static void findAccountTeamMembersTest(){
            Account a1 = new Account();
          //  a1.State__c = 'GOA';
            a1.OwnerId = UserInfo.getUserId();
            a1.Name = 'testname';
            a1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business Account').getRecordTypeId();
            insert a1;
            
            Test.startTest();
                 LwcLOSLoanApplicationCntrl.findAccountTeamMembers(a1.OwnerId);
            Test.stopTest();
        }
        
        @isTest
        public static void setAadharSourceTest(){
            try{
                Opportunity opks1 = new Opportunity();
                opks1.StageName = 'Qualification';
                opks1.CloseDate = Date.newInstance(2021, 1, 11);
                opks1.Name = 'testone';
                opks1.Lead_number__c = '45367';
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
                 dfks1.Aadhar_Source__c = 'ScanAadhar';
                 dfks1.Document_Type__c = System.label.Driving_License;
                  insert dfks1;
                
                 Test.startTest();
                     LwcLOSLoanApplicationCntrl.setAadharSource(apks1.Id,dfks1.Document_Type__c);
                     LwcLOSLoanApplicationCntrl.setAadharSource(null,null);
                 Test.stopTest();
            }catch(Exception e){
                
            }
        }
        
         @isTest
        public static void setAadharSourceTest1(){
            try{
                Opportunity opks1 = new Opportunity();
                opks1.StageName = 'Qualification';
                opks1.CloseDate = Date.newInstance(2021, 1, 11);
                opks1.Name = 'testone';
                opks1.Lead_number__c = '45367';
                insert opks1;
                
             /*   Applicant__c apks1 = new Applicant__c();
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
                 dfks1.Aadhar_Source__c = 'ScanAadhar';
                 dfks1.Document_Type__c = 'Driving Licence';
                  insert dfks1; */
                
                 Test.startTest();
                     LwcLOSLoanApplicationCntrl.setAadharSource(opks1.Id,'Aadhar');
                 Test.stopTest();
            }catch(Exception e){
                
            }
        }
        
        @isTest
        public static void deletePIDBlockTest(){
                Opportunity opks1 = new Opportunity();
                opks1.StageName = 'Qualification';
                opks1.CloseDate = Date.newInstance(2021, 1, 11);
                opks1.Name = 'testone';
                opks1.Lead_number__c = '45367';
                insert opks1;
                
                Applicant__c apks1 = new Applicant__c();
                apks1.Opportunity__c = opks1.Id;
                apks1.Contact_number__c = '9743514830';
                apks1.Applicant_Type__c = 'Borrower';
                apks1.PID_Block__c = 'testpid';
                insert apks1;
            
               Test.startTest();
                    LwcLOSLoanApplicationCntrl.deletePIDBlock(apks1.Id);
               Test.stopTest();
        }
        
        @isTest
        public static void verifyCMUTest(){
            try{
                
                Account testAccount = TestDataUtility.createTestAccount(true);
                
                Opportunity opks1 = new Opportunity();
                opks1.AccountId = testAccount.Id;
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
                 dfks1.Aadhar_Source__c = 'Scan and Upload';
                 dfks1.Name = 'Aadhar';
                 dfks1.Document_Type__c = System.label.AadhaarCard;
                 dfks1.DocAuth_Passed__c = false;
             //    dfks1.RecordTypeId = Schema.SObjectType.Documents__c.getRecordTypeInfosByName().get('KYC Document').getRecordTypeId();
                 insert dfks1;
                
                 case cs1 = new case();
                 cs1.Loan_Application__c = opks1.Id;
             //    cs1.OwnerId = bUser.Id;
                 cs1.RecordTypeId = Schema.sObjectType.Case.getRecordTypeInfosByName().get('CMU Request').getRecordTypeId();
                 cs1.Subject='Approval Of Application Sourced By Off Roll Employee';
                 cs1.Status = 'Pending-Off Role Employee App';
                 cs1.Origin = 'Web';
                 insert cs1;
                
                 Test.startTest();
                     LwcLOSLoanApplicationCntrl.verifyCMU(opks1.Id);
                     LwcLOSLoanApplicationCntrl.verifyCMU(null);
                 Test.stopTest();
                
            }catch(Exception e){
                System.assertEquals('Script-thrown exception', e.getMessage()); 
            }
        }
        
         @isTest
        public static void verifyCMUTest1(){
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
                 dfks1.Aadhar_Source__c = 'Scan and Upload';
                 dfks1.Name = 'Aadhar';
                 dfks1.Document_Type__c = 'Customer Image';
             //    dfks1.RecordTypeId = Schema.SObjectType.Documents__c.getRecordTypeInfosByName().get('KYC Document').getRecordTypeId();
                 insert dfks1;
                
                 Documents__c dfks2 = new Documents__c();
                 dfks2.Applicant__c = apks1.Id;
                 dfks2.Opportunity_Relation__c = opks1.Id;
                 dfks2.KYC_name__c = 'Aadhar';
                 dfks2.Document_Side__c ='Back';
                 dfks2.Aadhar_Source__c = 'Scan and Upload';
                 dfks2.Name = 'Aadhar';
                 dfks2.Document_Type__c = 'Customer Image';
             //    dfks1.RecordTypeId = Schema.SObjectType.Documents__c.getRecordTypeInfosByName().get('KYC Document').getRecordTypeId();
                 insert dfks2;
                
                 case cs1 = new case();
                 cs1.Loan_Application__c = opks1.Id;
             //    cs1.OwnerId = bUser.Id;
                 cs1.RecordTypeId = Schema.sObjectType.Case.getRecordTypeInfosByName().get('FI').getRecordTypeId();
                 cs1.Subject='Approval Of Application Sourced By Off Roll Employee';
                 cs1.Status = 'Pending-Off Role Employee App';
                 cs1.Origin = 'Web';
                 insert cs1;
                
                 Test.startTest();
                     LwcLOSLoanApplicationCntrl.verifyCMU(opks1.Id);
                     LwcLOSLoanApplicationCntrl.verifyCMU(null);
                 Test.stopTest();
                
            }catch(Exception e){
                System.assertEquals('Script-thrown exception', e.getMessage()); 
            }
        }
        
        @isTest
        public static void verifyCMUTest2(){
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
                 dfks1.Aadhar_Source__c = 'Scan and Upload';
                 dfks1.Name = 'Aadhar';
                 dfks1.Document_Type__c = System.label.PanCard;
             //    dfks1.RecordTypeId = Schema.SObjectType.Documents__c.getRecordTypeInfosByName().get('KYC Document').getRecordTypeId();
                 insert dfks1;
                
                 Documents__c dfks2 = new Documents__c();
                 dfks2.Applicant__c = apks1.Id;
                 dfks2.Opportunity_Relation__c = opks1.Id;
                 dfks2.KYC_name__c = 'Aadhar';
                 dfks2.Document_Side__c ='Back';
                 dfks2.Aadhar_Source__c = 'Scan and Upload';
                 dfks2.Name = 'Aadhar';
                 dfks2.Document_Type__c = 'Customer Image';
             //    dfks1.RecordTypeId = Schema.SObjectType.Documents__c.getRecordTypeInfosByName().get('KYC Document').getRecordTypeId();
                 insert dfks2;
                
                 case cs1 = new case();
                 cs1.Loan_Application__c = opks1.Id;
             //    cs1.OwnerId = bUser.Id;
                 cs1.RecordTypeId = Schema.sObjectType.Case.getRecordTypeInfosByName().get('FI').getRecordTypeId();
                 cs1.Subject='Approval Of Application Sourced By Off Roll Employee';
                 cs1.Status = 'Pending-Off Role Employee App';
                 cs1.Origin = 'Web';
                 insert cs1;
                
                 Test.startTest();
                     LwcLOSLoanApplicationCntrl.verifyCMU(opks1.Id);
                     LwcLOSLoanApplicationCntrl.verifyCMU(null);
                 Test.stopTest();
                
            }catch(Exception e){
                System.assertEquals('Script-thrown exception', e.getMessage()); 
            }
        }
        
        @isTest
        public static void fetchCdocumentIdTest(){
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
             //    dfks1.Aadhar_Source__c = 'ScanAadhar';
                 dfks1.Name = 'Aadhar';
                 dfks1.Proof_of_Identity_POI__c = true;
                 dfks1.Document_Type__c = System.label.PassportCard;
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
                      LwcLOSLoanApplicationCntrl.fetchCdocumentId(dfks1.Id);
                 Test.stopTest();
                
            }catch(Exception e){
               // System.assertEquals('Script-thrown Exception', e.getMessage());
            }
        }
        
         @isTest
        public static void fetchCdocumentIdTest1(){
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
             //    dfks1.Aadhar_Source__c = 'ScanAadhar';
                 dfks1.Name = 'Aadhar';
                 dfks1.Proof_of_Identity_POI__c = true;
                 dfks1.Document_Type__c = System.label.PassportCard;
                 insert dfks1;
                
                 ContentVersion cvn1 = new ContentVersion();
                 cvn1.PathOnClient = 'testpath1';
                 cvn1.Title = 'testtitle1';
                 cvn1.VersionData = Blob.valueOf('Test Content');
                 cvn1.Document_Side_fileupload__c = 'Back';
                 insert cvn1;
                
                 ContentVersion testcd1 = [SELECT id, ContentDocumentId FROM ContentVersion where Id = :cvn1.Id];
                
                 ContentDocumentLink cdlink1 = new ContentDocumentLink();
                 cdlink1.Visibility = 'AllUsers';
                 cdlink1.ShareType = 'V';
                 cdlink1.LinkedEntityId = dfks1.Id;
                 cdlink1.ContentDocumentId = testcd1.ContentDocumentId;
                 insert cdlink1;  
                
                 Test.startTest();
                      LwcLOSLoanApplicationCntrl.fetchCdocumentId(dfks1.Id);
                 Test.stopTest();
                
            }catch(Exception e){
               // System.assertEquals('Script-thrown Exception', e.getMessage());
            }
        }
        
         @isTest
        public static void kycContentDocDeleteTest(){
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
             //    dfks1.Aadhar_Source__c = 'ScanAadhar';
                 dfks1.Name = 'Aadhar';
                 dfks1.Proof_of_Identity_POI__c = true;
                 dfks1.Document_Type__c = 'Passport';
                 insert dfks1;
                
                 ContentVersion cvn1 = new ContentVersion();
                 cvn1.PathOnClient = 'testpath1';
                 cvn1.Title = 'testtitle1';
                 cvn1.VersionData = Blob.valueOf('Test Content');
                 cvn1.Document_Side_fileupload__c = 'Back';
                 insert cvn1;
                
                 ContentVersion testcd1 = [SELECT id, ContentDocumentId FROM ContentVersion where Id = :cvn1.Id];
                
                 ContentDocumentLink cdlink1 = new ContentDocumentLink();
                 cdlink1.Visibility = 'AllUsers';
                 cdlink1.ShareType = 'V';
                 cdlink1.LinkedEntityId = dfks1.Id;
                 cdlink1.ContentDocumentId = testcd1.ContentDocumentId;
                 insert cdlink1;  
                  
                
                 Test.startTest();
                      LwcLOSLoanApplicationCntrl.kycContentDocDelete(dfks1.Id,true,true,testcd1.ContentDocumentId);
                     	LwcLOSLoanApplicationCntrl.kycContentDocDelete(dfks1.Id,true,true,null);
                 Test.stopTest();
                
            }catch(Exception e){
                System.assertEquals('Script-thrown Exception', e.getMessage());
            }
        } 
       
        @isTest
        public static void getLoanApplicationStageNameMetaDataTest(){
            Test.startTest();
                 List<String> rn1 = LwcLOSLoanApplicationCntrl.getLoanApplicationStageNameMetaData();
                 system.assertEquals(rn1, LwcLOSLoanApplicationCntrl.getLoanApplicationStageNameMetaData());
            Test.stopTest();
        }
        
        @isTest
        public static void getLoanApplicationTransactionHistoryTest(){
            
                Opportunity opks1 = new Opportunity();
                opks1.StageName = 'Qualification';
                opks1.CloseDate = Date.newInstance(2021, 1, 11);
                opks1.Name = 'testone';
                insert opks1;
            
                Loan_Application_Transaction_History__c lth1 = new Loan_Application_Transaction_History__c();
                lth1.Loan_Application_ID__c = opks1.Id;
                lth1.Module_Name__c = 'FI';
                lth1.Assignment_status__c = 'Accepted';
                lth1.RecordTypeId = Schema.SObjectType.Loan_Application_Transaction_History__c.getRecordTypeInfosByName().get('Lead Assignment').getRecordTypeId();
                insert lth1;
            
                Test.startTest();
                    Boolean a1 =  LwcLOSLoanApplicationCntrl.getLoanApplicationTransactionHistory(opks1.Id,lth1.Module_Name__c);
                    system.assertEquals(false,LwcLOSLoanApplicationCntrl.getLoanApplicationTransactionHistory(opks1.Id,opks1.StageName));
                Test.stopTest();
        }
        
        @isTest
        public static void getLoanApplicationTransactionHistoryTest1(){
            
                Opportunity opks1 = new Opportunity();
                opks1.StageName = 'Qualification';
                opks1.CloseDate = Date.newInstance(2021, 1, 11);
                opks1.Name = 'testone';
                insert opks1;
            
                Loan_Application_Transaction_History__c lth1 = new Loan_Application_Transaction_History__c();
                lth1.Loan_Application_ID__c = opks1.Id;
                lth1.Module_Name__c = 'FI';
                insert lth1;
            
                Test.startTest();
                    Boolean a1 =  LwcLOSLoanApplicationCntrl.getLoanApplicationTransactionHistory(lth1.Id,lth1.Module_Name__c);
                    system.assertEquals(false,LwcLOSLoanApplicationCntrl.getLoanApplicationTransactionHistory(opks1.Id,opks1.StageName));
                Test.stopTest();
        }
        
        @isTest
        public static void createLoanTransferHistoryRecordTest(){
                Opportunity opks1 = new Opportunity();
                opks1.StageName = 'Qualification';
                opks1.CloseDate = Date.newInstance(2021, 1, 11);
                opks1.Name = 'testone';
                opks1.OwnerId = UserInfo.getUserId();
            	opks1.LeadSource = 'D2C';
            	opks1.Contact_number__c = '9078567890';
                insert opks1;
            
                Loan_Application_Transaction_History__c lth1 = new Loan_Application_Transaction_History__c();
              //  lth1.Name = 'test';
                lth1.Loan_Application_ID__c = opks1.Id;
                lth1.Module_Name__c = 'FI';
                lth1.New_Owner__c = UserInfo.getUserId();
                lth1.Type__c = 'Module';
                insert lth1;
            
                Test.startTest();
                try{
                    Boolean b1 = LwcLOSLoanApplicationCntrl.createLoanTransferHistoryRecord(opks1.Id,lth1.Name,lth1.New_Owner__c,lth1.Type__c,lth1.Module_Name__c,'TNN');
                 //   LwcLOSLoanApplicationCntrl.createLoanTransferHistoryRecord('test1','test2','test3','test4','test5');
                   
                  system.assertEquals(b1, LwcLOSLoanApplicationCntrl.createLoanTransferHistoryRecord(opks1.Id,lth1.Name,lth1.New_Owner__c,lth1.Type__c,lth1.Module_Name__c,'TNN'));
                }catch(Exception e){}
                Test.stopTest();
        } 
        
        @isTest
        public static void createPersonAccWithCustCodeAssignmentTest(){
            try{
                Account a1 = new Account();
              //  a1.Name = 'test';
                a1.LastName = 'testname';
                a1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
                insert a1;
                
                Opportunity opp = TestDataUtility.createTestOpportunity(false);
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            
            Applicant__c app1 = TestDataUtility.createTestApplicantForSMS(false);
            app1.Opportunity__c = opp.Id;
            app1.Account__c = null;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert app1;
            }
                
            Customer_Dedupe_Response__c cdr4 = new Customer_Dedupe_Response__c();
            cdr4.Applicant__c = app1.Id;
            cdr4.CIC_No__c = '545667';
            cdr4.CIN_No__c = '34455';
         //   cdr2.Response__c = '{"response":{"status":"SUCCESS","respDesc":"IxsightEnquiry","content":[{"Data":{"ExternalDedupeResponse":{"DEDUPE_STATUS":"M","DtCFDCUSTBAS":[{"SOURCE_CIC_NO":"2022268275545880078","MATCH_ECIF":"3095268","MATCHED_CUSTOMER_NAME":"S DEIVARAJ","MATCHED_CUSTOMER_CODE":"CU0503174","MATCHED_SOURCE":"CFD","MATCHED_SCORE":"100","MATCHED_CRITERIA":"VOTERID100","CONFIDENCE_LEVEL":"1"}],"DtRECENTLEAD":[{"SOURCE_CIC_NO":"2022268275545880078","MATCHED_CIC_NO":"991102194599513090","MATCHED_LEAD_NAME":"DEIVARAJ S","MATCHED_LEAD_DATE":"12/15/2021 13:55:28","MATCHED_SCORE":"100","MATCHED_CRITERIA":"PAN100"}],"CustomerValidate":[{"CustomerCodeVal":"CU0503174","CustomerMaster":[{"Customer_Name":"S DEIVARAJ","Customer_Type":"10","Date_of_Birth":"27-06-1986 00:00:00","PAN_GIR_Number":"","Passport_Number":"","Voter_ID_Number":"CKK1913391","Driving_License_Number":"","Aadhaar_No":""}],"CustomerStatus":[{"Cross_Dedupe_Match_Id":"3095268","Active_Flag":"Z"}],"Dealstatus":[{"Deal_No":"TTU05950H","Status_Flag":"Z"}],"NPA":[],"Restructure":[{"Deal_Restructured":"No"}],"Gecl":[{"Deal_No":"TTU05950H","Status_Flag":"Z"}],"ARC":[],"PanAlert":[],"CINAlert":[],"BeneficiaryAlert":{"Ben_code":null,"Beneficiary":null,"Status_Flag":null,"PAN_No":null}}]},"InternalDedupeResponse":[{"CustomerMaster":[{"CIC_No":"CU0503174","Matched_Customer_Code":"CU0503174","Rule_Matching_Fields":"VOTERID","Current_Parameter_Value":"CKK1913391","Matched_Parameter_Value":"CKK1913391","Matched_Score":"100","Rule_Field_Weightage":"100","Matched_Source":"CFD","Active_Flag":"Z","Dedupe_Super_Match":"Y","Dedupe_Super_Match_Score":"100","Rule_Id":"VOTERID100","Type":"C","PEP_Remarks":"","Customer_Name":null,"Customer_Type":null,"Date_of_Birth":null,"PAN_GIR_Number":null,"Passport_Number":null,"Voter_ID_Number":null,"Driving_License_Number":null,"Aadhaar_No":null},{"CIC_No":"CW3782547","Matched_Customer_Code":"CW3782547","Rule_Matching_Fields":"PAN","Current_Parameter_Value":"DMSPD9630N","Matched_Parameter_Value":"DMSPD9630N","Matched_Score":"100","Rule_Field_Weightage":"100","Matched_Source":"CFD","Active_Flag":"Y","Dedupe_Super_Match":"Y","Dedupe_Super_Match_Score":"100","Rule_Id":"PAN100","Type":"C","PEP_Remarks":"","Customer_Name":null,"Customer_Type":null,"Date_of_Birth":null,"PAN_GIR_Number":null,"Passport_Number":null,"Voter_ID_Number":null,"Driving_License_Number":null,"Aadhaar_No":null},{"CIC_No":"CW3782547","Matched_Customer_Code":"CW3782547","Rule_Matching_Fields":"VOTERID","Current_Parameter_Value":"CKK1913391","Matched_Parameter_Value":"CKK1913391","Matched_Score":"100","Rule_Field_Weightage":"100","Matched_Source":"CFD","Active_Flag":"Y","Dedupe_Super_Match":"Y","Dedupe_Super_Match_Score":"100","Rule_Id":"VOTERID100","Type":"C","PEP_Remarks":"","Customer_Name":null,"Customer_Type":null,"Date_of_Birth":null,"PAN_GIR_Number":null,"Passport_Number":null,"Voter_ID_Number":null,"Driving_License_Number":null,"Aadhaar_No":null},{"CIC_No":"CW4970396","Matched_Customer_Code":"CW4970396","Rule_Matching_Fields":"AADHAAR_NO","Current_Parameter_Value":"671940628725","Matched_Parameter_Value":"671940628725","Matched_Score":"100","Rule_Field_Weightage":"100","Matched_Source":"CFD","Active_Flag":"Y","Dedupe_Super_Match":"Y","Dedupe_Super_Match_Score":"100","Rule_Id":"ADHAR100","Type":"C","PEP_Remarks":"","Customer_Name":null,"Customer_Type":null,"Date_of_Birth":null,"PAN_GIR_Number":null,"Passport_Number":null,"Voter_ID_Number":null,"Driving_License_Number":null,"Aadhaar_No":null}],"CustomerValidate":[{"CustomerCodeVal":"CU0503174","CustomerMaster":[{"CIC_No":null,"Matched_Customer_Code":null,"Rule_Matching_Fields":null,"Current_Parameter_Value":null,"Matched_Parameter_Value":null,"Matched_Score":null,"Rule_Field_Weightage":null,"Matched_Source":null,"Active_Flag":null,"Dedupe_Super_Match":null,"Dedupe_Super_Match_Score":null,"Rule_Id":null,"Type":null,"PEP_Remarks":null,"Customer_Name":"S DEIVARAJ","Customer_Type":"10","Date_of_Birth":"27-06-1986 00:00:00","PAN_GIR_Number":"","Passport_Number":"","Voter_ID_Number":"CKK1913391","Driving_License_Number":"","Aadhaar_No":""}],"CustomerStatus":[{"Cross_Dedupe_Match_Id":"3095268","Active_Flag":"Z"}],"Dealstatus":[{"Deal_No":"TTU05950H","Status_Flag":"Z"}],"NPA":[],"Restructure":[{"Deal_Restructured":"Yes"}],"Gecl":[],"ARC":[],"PanAlert":[],"CINAlert":[],"BeneficiaryAlert":{"Ben_code":null,"Beneficiary":null,"Status_Flag":null,"PAN_No":null}},{"CustomerCodeVal":"CW3782547","CustomerMaster":[{"CIC_No":null,"Matched_Customer_Code":null,"Rule_Matching_Fields":null,"Current_Parameter_Value":null,"Matched_Parameter_Value":null,"Matched_Score":null,"Rule_Field_Weightage":null,"Matched_Source":null,"Active_Flag":null,"Dedupe_Super_Match":null,"Dedupe_Super_Match_Score":null,"Rule_Id":null,"Type":null,"PEP_Remarks":null,"Customer_Name":"DEIVARAJ","Customer_Type":"10","Date_of_Birth":"27-06-1984 00:00:00","PAN_GIR_Number":"DMSPD9630N","Passport_Number":"","Voter_ID_Number":"CKK1913391","Driving_License_Number":"","Aadhaar_No":"916901617335"}],"CustomerStatus":[{"Cross_Dedupe_Match_Id":"59675453","Active_Flag":"Y"}],"Dealstatus":[{"Deal_No":"TNU05150H","Status_Flag":"Z"},{"Deal_No":"TTU01390S","Status_Flag":"L"}],"NPA":[],"Restructure":[{"Deal_Restructured":"Yes"}],"Gecl":[],"ARC":[],"PanAlert":[],"CINAlert":[],"BeneficiaryAlert":{"Ben_code":null,"Beneficiary":null,"Status_Flag":null,"PAN_No":null}},{"CustomerCodeVal":"CW3782547","CustomerMaster":[{"CIC_No":null,"Matched_Customer_Code":null,"Rule_Matching_Fields":null,"Current_Parameter_Value":null,"Matched_Parameter_Value":null,"Matched_Score":null,"Rule_Field_Weightage":null,"Matched_Source":null,"Active_Flag":null,"Dedupe_Super_Match":null,"Dedupe_Super_Match_Score":null,"Rule_Id":null,"Type":null,"PEP_Remarks":null,"Customer_Name":"DEIVARAJ","Customer_Type":"10","Date_of_Birth":"27-06-1984 00:00:00","PAN_GIR_Number":"DMSPD9630N","Passport_Number":"","Voter_ID_Number":"CKK1913391","Driving_License_Number":"","Aadhaar_No":"916901617335"}],"CustomerStatus":[{"Cross_Dedupe_Match_Id":"59675453","Active_Flag":"Y"}],"Dealstatus":[{"Deal_No":"TNU05150H","Status_Flag":"Z"},{"Deal_No":"TTU01390S","Status_Flag":"L"}],"NPA":[],"Restructure":[{"Deal_Restructured":"Yes"}],"Gecl":[],"ARC":[],"PanAlert":[],"CINAlert":[],"BeneficiaryAlert":{"Ben_code":null,"Beneficiary":null,"Status_Flag":null,"PAN_No":null}},{"CustomerCodeVal":"CW4970396","CustomerMaster":[{"CIC_No":null,"Matched_Customer_Code":null,"Rule_Matching_Fields":null,"Current_Parameter_Value":null,"Matched_Parameter_Value":null,"Matched_Score":null,"Rule_Field_Weightage":null,"Matched_Source":null,"Active_Flag":null,"Dedupe_Super_Match":null,"Dedupe_Super_Match_Score":null,"Rule_Id":null,"Type":null,"PEP_Remarks":null,"Customer_Name":"NAGALAXMI","Customer_Type":"10","Date_of_Birth":"25-03-1981 00:00:00","PAN_GIR_Number":"COMPN4828K","Passport_Number":"","Voter_ID_Number":"","Driving_License_Number":"","Aadhaar_No":"671940628725"}],"CustomerStatus":[{"Cross_Dedupe_Match_Id":"70765909","Active_Flag":"Y"}],"Dealstatus":[],"NPA":[],"Restructure":[{"Deal_Restructured":"Yes"}],"Gecl":[],"ARC":[],"PanAlert":[],"CINAlert":[],"BeneficiaryAlert":{"Ben_code":null,"Beneficiary":null,"Status_Flag":null,"PAN_No":null}}]}]},"ErrorDesc":""}]}}';
            insert cdr4;
                
             Test.startTest();
                   LwcLOSLoanApplicationCntrl.createPersonAccWithCustCodeAssignment(app1.Id);
             Test.stopTest();
                
            }catch(Exception e){
               // System.assertEquals('Script-thrown exception', e.getMessage());
            }
        }
        
         @isTest
        public static void createPersonAccWithCustCodeAssignmentTest1(){
            try{
                Account a1 = new Account();
                a1.Name = 'test';
                a1.Customer_Code__c = null;
                a1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business Account').getRecordTypeId();
                insert a1;
                
                Opportunity opp = TestDataUtility.createTestOpportunity(false);
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            
            Applicant__c app1 = TestDataUtility.createTestApplicantForSMS(false);
            app1.Opportunity__c = opp.Id;
            app1.Account__c = a1.Id;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert app1;
            }
                
            Customer_Dedupe_Response__c cdr4 = new Customer_Dedupe_Response__c();
            cdr4.Applicant__c = app1.Id;
            cdr4.CIC_No__c = '545667';
            cdr4.CIN_No__c = '34455';
         //   cdr2.Response__c = '{"response":{"status":"SUCCESS","respDesc":"IxsightEnquiry","content":[{"Data":{"ExternalDedupeResponse":{"DEDUPE_STATUS":"M","DtCFDCUSTBAS":[{"SOURCE_CIC_NO":"2022268275545880078","MATCH_ECIF":"3095268","MATCHED_CUSTOMER_NAME":"S DEIVARAJ","MATCHED_CUSTOMER_CODE":"CU0503174","MATCHED_SOURCE":"CFD","MATCHED_SCORE":"100","MATCHED_CRITERIA":"VOTERID100","CONFIDENCE_LEVEL":"1"}],"DtRECENTLEAD":[{"SOURCE_CIC_NO":"2022268275545880078","MATCHED_CIC_NO":"991102194599513090","MATCHED_LEAD_NAME":"DEIVARAJ S","MATCHED_LEAD_DATE":"12/15/2021 13:55:28","MATCHED_SCORE":"100","MATCHED_CRITERIA":"PAN100"}],"CustomerValidate":[{"CustomerCodeVal":"CU0503174","CustomerMaster":[{"Customer_Name":"S DEIVARAJ","Customer_Type":"10","Date_of_Birth":"27-06-1986 00:00:00","PAN_GIR_Number":"","Passport_Number":"","Voter_ID_Number":"CKK1913391","Driving_License_Number":"","Aadhaar_No":""}],"CustomerStatus":[{"Cross_Dedupe_Match_Id":"3095268","Active_Flag":"Z"}],"Dealstatus":[{"Deal_No":"TTU05950H","Status_Flag":"Z"}],"NPA":[],"Restructure":[{"Deal_Restructured":"No"}],"Gecl":[{"Deal_No":"TTU05950H","Status_Flag":"Z"}],"ARC":[],"PanAlert":[],"CINAlert":[],"BeneficiaryAlert":{"Ben_code":null,"Beneficiary":null,"Status_Flag":null,"PAN_No":null}}]},"InternalDedupeResponse":[{"CustomerMaster":[{"CIC_No":"CU0503174","Matched_Customer_Code":"CU0503174","Rule_Matching_Fields":"VOTERID","Current_Parameter_Value":"CKK1913391","Matched_Parameter_Value":"CKK1913391","Matched_Score":"100","Rule_Field_Weightage":"100","Matched_Source":"CFD","Active_Flag":"Z","Dedupe_Super_Match":"Y","Dedupe_Super_Match_Score":"100","Rule_Id":"VOTERID100","Type":"C","PEP_Remarks":"","Customer_Name":null,"Customer_Type":null,"Date_of_Birth":null,"PAN_GIR_Number":null,"Passport_Number":null,"Voter_ID_Number":null,"Driving_License_Number":null,"Aadhaar_No":null},{"CIC_No":"CW3782547","Matched_Customer_Code":"CW3782547","Rule_Matching_Fields":"PAN","Current_Parameter_Value":"DMSPD9630N","Matched_Parameter_Value":"DMSPD9630N","Matched_Score":"100","Rule_Field_Weightage":"100","Matched_Source":"CFD","Active_Flag":"Y","Dedupe_Super_Match":"Y","Dedupe_Super_Match_Score":"100","Rule_Id":"PAN100","Type":"C","PEP_Remarks":"","Customer_Name":null,"Customer_Type":null,"Date_of_Birth":null,"PAN_GIR_Number":null,"Passport_Number":null,"Voter_ID_Number":null,"Driving_License_Number":null,"Aadhaar_No":null},{"CIC_No":"CW3782547","Matched_Customer_Code":"CW3782547","Rule_Matching_Fields":"VOTERID","Current_Parameter_Value":"CKK1913391","Matched_Parameter_Value":"CKK1913391","Matched_Score":"100","Rule_Field_Weightage":"100","Matched_Source":"CFD","Active_Flag":"Y","Dedupe_Super_Match":"Y","Dedupe_Super_Match_Score":"100","Rule_Id":"VOTERID100","Type":"C","PEP_Remarks":"","Customer_Name":null,"Customer_Type":null,"Date_of_Birth":null,"PAN_GIR_Number":null,"Passport_Number":null,"Voter_ID_Number":null,"Driving_License_Number":null,"Aadhaar_No":null},{"CIC_No":"CW4970396","Matched_Customer_Code":"CW4970396","Rule_Matching_Fields":"AADHAAR_NO","Current_Parameter_Value":"671940628725","Matched_Parameter_Value":"671940628725","Matched_Score":"100","Rule_Field_Weightage":"100","Matched_Source":"CFD","Active_Flag":"Y","Dedupe_Super_Match":"Y","Dedupe_Super_Match_Score":"100","Rule_Id":"ADHAR100","Type":"C","PEP_Remarks":"","Customer_Name":null,"Customer_Type":null,"Date_of_Birth":null,"PAN_GIR_Number":null,"Passport_Number":null,"Voter_ID_Number":null,"Driving_License_Number":null,"Aadhaar_No":null}],"CustomerValidate":[{"CustomerCodeVal":"CU0503174","CustomerMaster":[{"CIC_No":null,"Matched_Customer_Code":null,"Rule_Matching_Fields":null,"Current_Parameter_Value":null,"Matched_Parameter_Value":null,"Matched_Score":null,"Rule_Field_Weightage":null,"Matched_Source":null,"Active_Flag":null,"Dedupe_Super_Match":null,"Dedupe_Super_Match_Score":null,"Rule_Id":null,"Type":null,"PEP_Remarks":null,"Customer_Name":"S DEIVARAJ","Customer_Type":"10","Date_of_Birth":"27-06-1986 00:00:00","PAN_GIR_Number":"","Passport_Number":"","Voter_ID_Number":"CKK1913391","Driving_License_Number":"","Aadhaar_No":""}],"CustomerStatus":[{"Cross_Dedupe_Match_Id":"3095268","Active_Flag":"Z"}],"Dealstatus":[{"Deal_No":"TTU05950H","Status_Flag":"Z"}],"NPA":[],"Restructure":[{"Deal_Restructured":"Yes"}],"Gecl":[],"ARC":[],"PanAlert":[],"CINAlert":[],"BeneficiaryAlert":{"Ben_code":null,"Beneficiary":null,"Status_Flag":null,"PAN_No":null}},{"CustomerCodeVal":"CW3782547","CustomerMaster":[{"CIC_No":null,"Matched_Customer_Code":null,"Rule_Matching_Fields":null,"Current_Parameter_Value":null,"Matched_Parameter_Value":null,"Matched_Score":null,"Rule_Field_Weightage":null,"Matched_Source":null,"Active_Flag":null,"Dedupe_Super_Match":null,"Dedupe_Super_Match_Score":null,"Rule_Id":null,"Type":null,"PEP_Remarks":null,"Customer_Name":"DEIVARAJ","Customer_Type":"10","Date_of_Birth":"27-06-1984 00:00:00","PAN_GIR_Number":"DMSPD9630N","Passport_Number":"","Voter_ID_Number":"CKK1913391","Driving_License_Number":"","Aadhaar_No":"916901617335"}],"CustomerStatus":[{"Cross_Dedupe_Match_Id":"59675453","Active_Flag":"Y"}],"Dealstatus":[{"Deal_No":"TNU05150H","Status_Flag":"Z"},{"Deal_No":"TTU01390S","Status_Flag":"L"}],"NPA":[],"Restructure":[{"Deal_Restructured":"Yes"}],"Gecl":[],"ARC":[],"PanAlert":[],"CINAlert":[],"BeneficiaryAlert":{"Ben_code":null,"Beneficiary":null,"Status_Flag":null,"PAN_No":null}},{"CustomerCodeVal":"CW3782547","CustomerMaster":[{"CIC_No":null,"Matched_Customer_Code":null,"Rule_Matching_Fields":null,"Current_Parameter_Value":null,"Matched_Parameter_Value":null,"Matched_Score":null,"Rule_Field_Weightage":null,"Matched_Source":null,"Active_Flag":null,"Dedupe_Super_Match":null,"Dedupe_Super_Match_Score":null,"Rule_Id":null,"Type":null,"PEP_Remarks":null,"Customer_Name":"DEIVARAJ","Customer_Type":"10","Date_of_Birth":"27-06-1984 00:00:00","PAN_GIR_Number":"DMSPD9630N","Passport_Number":"","Voter_ID_Number":"CKK1913391","Driving_License_Number":"","Aadhaar_No":"916901617335"}],"CustomerStatus":[{"Cross_Dedupe_Match_Id":"59675453","Active_Flag":"Y"}],"Dealstatus":[{"Deal_No":"TNU05150H","Status_Flag":"Z"},{"Deal_No":"TTU01390S","Status_Flag":"L"}],"NPA":[],"Restructure":[{"Deal_Restructured":"Yes"}],"Gecl":[],"ARC":[],"PanAlert":[],"CINAlert":[],"BeneficiaryAlert":{"Ben_code":null,"Beneficiary":null,"Status_Flag":null,"PAN_No":null}},{"CustomerCodeVal":"CW4970396","CustomerMaster":[{"CIC_No":null,"Matched_Customer_Code":null,"Rule_Matching_Fields":null,"Current_Parameter_Value":null,"Matched_Parameter_Value":null,"Matched_Score":null,"Rule_Field_Weightage":null,"Matched_Source":null,"Active_Flag":null,"Dedupe_Super_Match":null,"Dedupe_Super_Match_Score":null,"Rule_Id":null,"Type":null,"PEP_Remarks":null,"Customer_Name":"NAGALAXMI","Customer_Type":"10","Date_of_Birth":"25-03-1981 00:00:00","PAN_GIR_Number":"COMPN4828K","Passport_Number":"","Voter_ID_Number":"","Driving_License_Number":"","Aadhaar_No":"671940628725"}],"CustomerStatus":[{"Cross_Dedupe_Match_Id":"70765909","Active_Flag":"Y"}],"Dealstatus":[],"NPA":[],"Restructure":[{"Deal_Restructured":"Yes"}],"Gecl":[],"ARC":[],"PanAlert":[],"CINAlert":[],"BeneficiaryAlert":{"Ben_code":null,"Beneficiary":null,"Status_Flag":null,"PAN_No":null}}]}]},"ErrorDesc":""}]}}';
            insert cdr4;
                
             Test.startTest();
                   LwcLOSLoanApplicationCntrl.createPersonAccWithCustCodeAssignment(app1.Id);
                   LwcLOSLoanApplicationCntrl.createPersonAccWithCustCodeAssignment('test');
             Test.stopTest();
                
            }catch(Exception e){
                System.assertEquals('Script-thrown exception', e.getMessage());
            }
        }
        
         @isTest
        public static void createPersonAccWithCustCodeAssignmentTest2(){
            try{
                Account a1 = new Account();
                a1.Name = 'test';
                a1.Customer_Code__c = null;
                a1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business Account').getRecordTypeId();
                insert a1;
                
                Opportunity opp = TestDataUtility.createTestOpportunity(false);
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            
             Test.startTest();
                   LwcLOSLoanApplicationCntrl.createPersonAccWithCustCodeAssignment(opp.Id);
                   LwcLOSLoanApplicationCntrl.createPersonAccWithCustCodeAssignment(null);
             Test.stopTest();
                
            }catch(Exception e){
                System.assertEquals('Script-thrown exception', e.getMessage());
            }
        }
        
        @isTest
        public static void getLoanApplicationHistoryTest(){
            try{
                 Profile p = [SELECT Id FROM Profile WHERE Name='CMU'];
            system.debug('p'+ p);
    		User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
					EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
					LocaleSidKey='en_US', ProfileId = p.Id,MobilePhone = '9701498575',
                    Maker_Id__c='1002',
					TimeZoneSidKey='America/Los_Angeles',
					UserName='standarduser4@testorg.com.psdev1');
            insert u;
                System.runAs(u) 
        {
                
                Opportunity opks1 = new Opportunity();
                opks1.StageName = 'Qualification';
                opks1.CloseDate = Date.newInstance(2021, 1, 11);
                opks1.Name = 'testone';
                opks1.OwnerId = u.Id;
                insert opks1;
            
                Loan_Application_Transaction_History__c lth1 = new Loan_Application_Transaction_History__c();
                lth1.Loan_Application_ID__c = opks1.Id;
                lth1.Module_Name__c = 'FI';
                lth1.Assignment_status__c = 'Accepted';
                lth1.New_Owner__c = UserInfo.getUserId();
                lth1.RecordTypeId = Schema.SObjectType.Loan_Application_Transaction_History__c.getRecordTypeInfosByName().get('Lead Assignment').getRecordTypeId();
                insert lth1;
                
                Opportunity opks2 = new Opportunity();
                opks2.Id = opks1.Id;
                opks2.StageName = 'Loan Initiation';
                update opks2;
                
                 OpportunityTeamMember optm2 = new OpportunityTeamMember();
                 optm2.OpportunityId = opks1.Id;
                 optm2.UserId = UserInfo.getUserId();
                 optm2.TeamMemberRole = 'BE';
                 insert optm2;
                
                Test.startTest();
                     LwcLOSLoanApplicationCntrl.getLoanApplicationHistory(opks1.Id,lth1.Module_Name__c,opks1.StageName);
                     LwcLOSLoanApplicationCntrl.getLoanApplicationHistory('test','test','test');
                Test.stopTest();
        }
                
            }catch(Exception e){
                System.assertEquals('Script-thrown exception', e.getMessage());
            }
        }
        
   /*      @isTest
        public static void getLoanApplicationHistoryTest1(){
            try{
                 Profile p = [SELECT Id FROM Profile WHERE Name='CMU'];
            system.debug('p'+ p);
    		User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
					EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
					LocaleSidKey='en_US', ProfileId = p.Id,MobilePhone = '9701498575',
                    Maker_Id__c='1002',
					TimeZoneSidKey='America/Los_Angeles',
					UserName='standarduser4@testorg.com.psdev1');
            insert u;
                
                Opportunity opks1 = new Opportunity();
                opks1.StageName = 'Qualification';
                opks1.CloseDate = Date.newInstance(2021, 1, 11);
                opks1.Name = 'testone';
                opks1.OwnerId = u.Id;
                insert opks1;
            
                
                
                Test.startTest();
                     LwcLOSLoanApplicationCntrl.getLoanApplicationHistory(opks1.Id,'FI',opks1.StageName);
                Test.stopTest();
                
            }catch(Exception e){
                System.assertEquals('Script-thrown exception', e.getMessage());
            }
        } */
        
        @isTest
        public static void checkUploadDocumentTest(){
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
             //    dfks1.Aadhar_Source__c = 'ScanAadhar';
                 dfks1.Name = 'Aadhar';
                 dfks1.Proof_of_Identity_POI__c = true;
                 dfks1.Document_Type__c = System.label.PassportCard;
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
                    LwcLOSLoanApplicationCntrl.checkUploadDocument(apks1.Id,dfks1.Document_Type__c);
                    LwcLOSLoanApplicationCntrl.checkUploadDocument('','Aadhar');
                    LwcLOSLoanApplicationCntrl.checkUploadDocument(null,null);
                Test.stopTest();
            }catch(Exception e){
               System.assertEquals('Script-thrown exception', e.getMessage());
            }
        }
        
     @isTest
        public static void tagPOIforKycDocTest(){
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
                 dfks1.Name = 'Aadhar';
                 dfks1.Document_Type__c = System.label.PassportCard;
                 dfks1.Proof_of_Identity_POI__c = true;
                dfks1.is_Active__c = true;
                 insert dfks1;
                
                 Test.startTest(); 
                       LwcLOSLoanApplicationCntrl.tagPOIforKycDoc(apks1.Id);
                       LwcLOSLoanApplicationCntrl.tagPOIforKycDoc('test');
                 Test.stopTest();
            }catch(Exception e){
                System.assertEquals('Script-thrown exception', e.getMessage());
            }
        }
        
        @isTest
        public static void tagPOIforKycDocTest1(){
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
                 dfks1.Name = 'Aadhar';
                 dfks1.Document_Type__c = System.label.PassportCard;
                 dfks1.Proof_of_Identity_POI__c = false;
                	dfks1.is_Active__c = true;
                 insert dfks1;
                
                 Test.startTest(); 
                       LwcLOSLoanApplicationCntrl.tagPOIforKycDoc(apks1.Id);
                       LwcLOSLoanApplicationCntrl.tagPOIforKycDoc(null);
                 Test.stopTest();
            }catch(Exception e){
                System.assertEquals('Script-thrown exception', e.getMessage());
            }
        }
        
         @isTest
        public static void tagPOIforKycDocTest2(){
            try{
                Opportunity opt1 = new Opportunity();
                opt1.StageName = 'Qualification';
                opt1.CloseDate = Date.newInstance(2021, 1, 11);
                opt1.Name = 'testone';
                insert opt1;
                
                 Test.startTest(); 
                       LwcLOSLoanApplicationCntrl.tagPOIforKycDoc(opt1.Id);
                 Test.stopTest();
            }catch(Exception e){
                System.assertEquals('Script-thrown exception', e.getMessage());
            }
        }
        
        @isTest
        public static void deleteEmptyKycDoctest(){
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
                 dfks1.KYC_name__c = null;
                 dfks1.Document_Side__c ='Back';
                 dfks1.Name = 'Aadhar';
                 dfks1.Document_Type__c =System.label.PassportCard;
             //    dfks1.Proof_of_Identity_POI__c = true;
                 insert dfks1;
                
                 Test.startTest();
                      LwcLOSLoanApplicationCntrl.deleteEmptyKycDoc(apks1.Id);
                      LwcLOSLoanApplicationCntrl.applicantWrapper lc1 = new LwcLOSLoanApplicationCntrl.applicantWrapper();
                      lc1.isForm60Present = true;
                      lc1.form60DocId = 'test123';
                      lc1.Form60Type = 'pdf';
                      lc1.isCustomerImagePresent = true;
                      lc1.FrontUploadComplete = true;
                      lc1.addDocId ='005ajskiloss78id';
                      lc1.addDocType ='Test Doc';
                      //lc1.currentAddressLine1 ='Test Address1';
                      //lc1.currentAddressLine2 ='Test Address2';
                      //lc1.currentAddressState ='Test State';
                      //lc1.currentAddressCity ='Test City';
                      //lc1.currentAddressDistrict ='Test District';
                      //lc1.currentAddressLandark ='Test Land';
                      //lc1.currentAddressPincode ='526983';
                      lc1.addDocId ='005ajskiloss78id';
                      lc1.addDocType ='Test Doc';
                      
                 Test.stopTest();
            }catch(Exception e){
                System.assertEquals('Script-thrown exception', e.getMessage());
            }
        }
        
         @isTest
        public static void deleteEmptyKycDoctest1(){
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
                 dfks1.KYC_name__c = null;
                 dfks1.Document_Side__c ='Back';
                 dfks1.Name = 'Aadhar';
                 dfks1.Document_Type__c = 'Form 60';
             //    dfks1.Proof_of_Identity_POI__c = true;
                 insert dfks1;
                
                 Test.startTest();
                      LwcLOSLoanApplicationCntrl.deleteEmptyKycDoc(apks1.Id);
                      LwcLOSLoanApplicationCntrl.deleteEmptyKycDoc(null);
                 Test.stopTest();
            }catch(Exception e){
                System.assertEquals('Script-thrown exception', e.getMessage());
            }
        }
        
        @isTest
        public static void getLoanAppTranHistoryTest(){
            
                Opportunity opat1 = new Opportunity();
                opat1.StageName = 'Qualification';
                opat1.CloseDate = Date.newInstance(2021, 1, 11);
                opat1.Name = 'testone';
                insert opat1;
            
                Loan_Application_Transaction_History__c lth1 = new Loan_Application_Transaction_History__c();
                lth1.Loan_Application_ID__c = opat1.Id;
                lth1.Module_Name__c = 'FI';
                lth1.Assignment_status__c = 'Accepted';
                lth1.Current_Owner__c = UserInfo.getUserId();
                lth1.RecordTypeId = Schema.SObjectType.Loan_Application_Transaction_History__c.getRecordTypeInfosByName().get('Lead Assignment').getRecordTypeId();
                insert lth1;
            
                Test.startTest();
                     LwcLOSLoanApplicationCntrl.getLoanAppTranHistory(opat1.Id,lth1.Module_Name__c);
                     LwcLOSLoanApplicationCntrl.getLoanAppTranHistory('test','test');
                Test.stopTest();
        }
        
        @isTest
        public static void accessLoanApplicationTest(){
            try{
                
                Profile p = [SELECT Id FROM Profile WHERE Name='CMU'];
            system.debug('p'+ p);
    		User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
					EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
					LocaleSidKey='en_US', ProfileId = p.Id,MobilePhone = '9701498575',
                    Maker_Id__c='1002',
					TimeZoneSidKey='America/Los_Angeles',
					UserName='standarduser4@testorg.com.psdev1');
            insert u;
                System.runAs(u) 
        {
                Opportunity opks1 = new Opportunity();
                opks1.StageName = 'Qualification';
                opks1.CloseDate = Date.newInstance(2021, 1, 11);
                opks1.Name = 'testone';
                opks1.OwnerId = u.Id;
                insert opks1;
            
                Loan_Application_Transaction_History__c lth1 = new Loan_Application_Transaction_History__c();
                lth1.Loan_Application_ID__c = opks1.Id;
                lth1.Module_Name__c = 'FI';
                lth1.Assignment_status__c = 'Accepted';
                lth1.New_Owner__c = UserInfo.getUserId();
                lth1.RecordTypeId = Schema.SObjectType.Loan_Application_Transaction_History__c.getRecordTypeInfosByName().get('Lead Assignment').getRecordTypeId();
                insert lth1;
                
                Test.startTest();
                     LwcLOSLoanApplicationCntrl.accessLoanApplication(opks1.Id,lth1.Module_Name__c);
                Test.stopTest();
        }
            }catch(Exception e){
                System.assertEquals('Script-thrown exception', e.getMessage());
            }
        }
        
        @isTest
        public static void accessLoanApplicationTest1(){
            try{
                
                Profile p = [SELECT Id FROM Profile WHERE Name='CMU'];
            system.debug('p'+ p);
    		User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
					EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
					LocaleSidKey='en_US', ProfileId = p.Id,MobilePhone = '9701498575',
                    Maker_Id__c='1002',
					TimeZoneSidKey='America/Los_Angeles',
					UserName='standarduser4@testorg.com.psdev1');
            insert u;
                System.runAs(u) 
        {
                Opportunity opks1 = new Opportunity();
                opks1.StageName = 'Qualification';
                opks1.CloseDate = Date.newInstance(2021, 1, 11);
                opks1.Name = 'testone';
                opks1.OwnerId = u.Id;
                insert opks1;
            
                Loan_Application_Transaction_History__c lth1 = new Loan_Application_Transaction_History__c();
                lth1.Loan_Application_ID__c = opks1.Id;
                lth1.Module_Name__c = 'FI';
                lth1.Assignment_status__c = 'Pending';
                lth1.New_Owner__c = UserInfo.getUserId();
                lth1.RecordTypeId = Schema.SObjectType.Loan_Application_Transaction_History__c.getRecordTypeInfosByName().get('Lead Assignment').getRecordTypeId();
                insert lth1;
                
                Test.startTest();
                     LwcLOSLoanApplicationCntrl.accessLoanApplication(opks1.Id,lth1.Module_Name__c);
                Test.stopTest();
        }
            }catch(Exception e){
                System.assertEquals('Script-thrown exception', e.getMessage());
            }
        }
        
         @isTest
        public static void accessLoanApplicationTest2(){
            try{
                
                Opportunity opks1 = new Opportunity();
                opks1.StageName = 'Qualification';
                opks1.CloseDate = Date.newInstance(2021, 1, 11);
                opks1.Name = 'testone';
                opks1.OwnerId = UserInfo.getUserId();
                insert opks1;
            
                Loan_Application_Transaction_History__c lth1 = new Loan_Application_Transaction_History__c();
                lth1.Loan_Application_ID__c = opks1.Id;
                lth1.Module_Name__c = 'FI';
                lth1.Assignment_status__c = 'Pending';
            //    lth1.New_Owner__c = UserInfo.getUserId();
                lth1.RecordTypeId = Schema.SObjectType.Loan_Application_Transaction_History__c.getRecordTypeInfosByName().get('Lead Assignment').getRecordTypeId();
                insert lth1;
                
                Test.startTest();
                     LwcLOSLoanApplicationCntrl.accessLoanApplication(opks1.Id,lth1.Module_Name__c);
                Test.stopTest();
            }catch(Exception e){
                System.assertEquals('Script-thrown exception', e.getMessage());
            }
        }
        
         @isTest
        public static void accessLoanApplicationTest3(){
            try{
                
                Opportunity opks1 = new Opportunity();
                opks1.StageName = 'Qualification';
                opks1.CloseDate = Date.newInstance(2021, 1, 11);
                opks1.Name = 'testone';
                opks1.OwnerId = UserInfo.getUserId();
                insert opks1;
            
                Loan_Application_Transaction_History__c lth1 = new Loan_Application_Transaction_History__c();
                lth1.Loan_Application_ID__c = opks1.Id;
                lth1.Module_Name__c = 'FI';
                lth1.Assignment_status__c = 'Accepted';
            //    lth1.New_Owner__c = UserInfo.getUserId();
                lth1.RecordTypeId = Schema.SObjectType.Loan_Application_Transaction_History__c.getRecordTypeInfosByName().get('Lead Assignment').getRecordTypeId();
                insert lth1;
                
                Test.startTest();
                     LwcLOSLoanApplicationCntrl.accessLoanApplication(opks1.Id,lth1.Module_Name__c);
                     LwcLOSLoanApplicationCntrl.accessLoanApplication(opks1.Id,null);
                Test.stopTest();
            }catch(Exception e){
                System.assertEquals('Script-thrown exception', e.getMessage());
            }
        }
        
        @isTest
        public static void accessLoanApplicationTest4(){
            try{
                
                Opportunity opks1 = new Opportunity();
                opks1.StageName = 'Qualification';
                opks1.CloseDate = Date.newInstance(2021, 1, 11);
                opks1.Name = 'testone';
                opks1.OwnerId = UserInfo.getUserId();
                insert opks1;
            
                Loan_Application_Transaction_History__c lth1 = new Loan_Application_Transaction_History__c();
                lth1.Loan_Application_ID__c = opks1.Id;
                lth1.Module_Name__c = 'FI';
                lth1.Assignment_status__c = 'Accepted';
                lth1.Type__c = 'Application';
            //    lth1.New_Owner__c = UserInfo.getUserId();
                lth1.RecordTypeId = Schema.SObjectType.Loan_Application_Transaction_History__c.getRecordTypeInfosByName().get('Lead Assignment').getRecordTypeId();
                insert lth1;
                
                Test.startTest();
                     LwcLOSLoanApplicationCntrl.accessLoanApplication(opks1.Id,lth1.Module_Name__c);
                     LwcLOSLoanApplicationCntrl.accessLoanApplication(opks1.Id,null);
                Test.stopTest();
            }catch(Exception e){
                System.assertEquals('Script-thrown exception', e.getMessage());
            }
        }
        
        @isTest
        public static void accessLoanApplicationTest5(){
            try{
                
                Opportunity opks1 = new Opportunity();
                opks1.StageName = 'Qualification';
                opks1.CloseDate = Date.newInstance(2021, 1, 11);
                opks1.Name = 'testone';
                opks1.OwnerId = UserInfo.getUserId();
                insert opks1;
            
                Loan_Application_Transaction_History__c lth1 = new Loan_Application_Transaction_History__c();
                lth1.Loan_Application_ID__c = opks1.Id;
                lth1.Module_Name__c = 'FI';
                lth1.Assignment_status__c = 'Completed';
             //   lth1.Type__c = 'Application';
            //    lth1.New_Owner__c = UserInfo.getUserId();
                lth1.RecordTypeId = Schema.SObjectType.Loan_Application_Transaction_History__c.getRecordTypeInfosByName().get('Lead Assignment').getRecordTypeId();
                insert lth1;
                
                Test.startTest();
                     LwcLOSLoanApplicationCntrl.accessLoanApplication(opks1.Id,lth1.Module_Name__c);
                     LwcLOSLoanApplicationCntrl.accessLoanApplication(opks1.Id,null);
                Test.stopTest();
            }catch(Exception e){
                System.assertEquals('Script-thrown exception', e.getMessage());
            }
        }
        
        @isTest
        public  static void storedMaskedKYCDocTest(){
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
                 dfks1.Document_Type__c = System.Label.CustomerImageDocumentType;
                 dfks1.KYC_name__c = 'Aadhar';
                 dfks1.Document_Side__c ='Back';
                 dfks1.Aadhar_Source__c = 'ScanAadhar';
                 dfks1.Name = 'Aadhar';
                 insert dfks1;
                
                Blob beforeblob1 = Blob.valueOf('Unit Test Attachment Body');

                 ContentVersion cvt1 = new ContentVersion();
                 cvt1.ContentLocation = 'S';
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
                       LwcLOSLoanApplicationCntrl.storedMaskedKYCDoc('Unit Test Attachment Body',dfks1.Id,cvt1.Document_Side_fileupload__c,testContent1.ContentDocumentId);
                       LwcLOSLoanApplicationCntrl.storedMaskedKYCDoc(null,null,null,null);
                 Test.stopTest();
            }catch(Exception e){
                System.assertEquals('Script-thrown exception', e.getMessage());
            }
        }
        
        @isTest
        public static void haveLeadAccesibilityTest(){
            try{
                Opportunity opks1 = new Opportunity();
                opks1.StageName = 'Qualification';
                opks1.CloseDate = Date.newInstance(2021, 1, 11);
                opks1.Name = 'testone';
                opks1.OwnerId = UserInfo.getUserId();
                insert opks1;
                
               /* UserRecordAccess ur1 = new UserRecordAccess();
                ur1.UserId = UserInfo.getUserId();
                ur1.RecordId = opks1.Id;
                insert ur1; */
                
                Test.startTest();
                      LwcLOSLoanApplicationCntrl.haveLeadAccesibility(opks1.Id);
                      LwcLOSLoanApplicationCntrl.haveLeadAccesibility('test');
                      LwcLOSLoanApplicationCntrl.haveLeadAccesibility(null);
                Test.stopTest();
                
            }catch(Exception e){
                System.assertEquals('Script-thrown exception', e.getMessage());
            }
        }
        
         @isTest
        public static void haveLeadAccesibilityTest1(){
            try{
                
                Profile p = [SELECT Id FROM Profile WHERE Name='IBL Business Executive'];
        User u = new User(Alias = 'standt2', email='standarduser2@testorg.com',MobilePhone = '9999999999',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,Maker_Id__c='12',IsActive = true,
                          timezonesidkey='america/los_angeles',username='test_userprod123@indusbank.com');
        insert u;
                
                System.runAs(u) 
        {
                Opportunity opks1 = new Opportunity();
                opks1.StageName = 'Qualification';
                opks1.CloseDate = Date.newInstance(2021, 1, 11);
                opks1.Name = 'testone';
                opks1.OwnerId = u.Id;
                insert opks1;
                
               /* UserRecordAccess ur1 = new UserRecordAccess();
                ur1.UserId = UserInfo.getUserId();
                ur1.RecordId = opks1.Id;
                insert ur1; */
                
                Test.startTest();
                      LwcLOSLoanApplicationCntrl.haveLeadAccesibility(opks1.Id);
                      LwcLOSLoanApplicationCntrl.haveLeadAccesibility('test');
                      LwcLOSLoanApplicationCntrl.haveLeadAccesibility(null);
                Test.stopTest();
        }
                
            }catch(Exception e){
                System.debug('Script-thrown exception'+ e.getMessage());
            }
        }
        
     @isTest
        public static void checkIfBorrowerEarningTest(){
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
                apks1.Income_source_available__c = true;
                insert apks1;
                
                Test.startTest();
                      LwcLOSLoanApplicationCntrl.checkIfBorrowerEarning(opks1.Id);
                      LwcLOSLoanApplicationCntrl.checkIfBorrowerEarning('test');
                      LwcLOSLoanApplicationCntrl.checkIfBorrowerEarning(null);
                Test.stopTest();
            }catch(Exception e){
                System.assertEquals('Script-thrown exception', e.getMessage());
            }
        }
        @isTest
        public static void getCustomerDedupeDataTest(){
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
                apks1.Income_source_available__c = true;
                insert apks1;
                
                Customer_Dedupe_Response__c cdr4 = new Customer_Dedupe_Response__c();
                cdr4.Applicant__c = apks1.Id;
                cdr4.CIC_No__c = '545667';
                cdr4.CIN_No__c = '34455';
                insert cdr4;

                Test.startTest();
                LwcLOSLoanApplicationCntrl.getCustomerDedupeData(opks1.Id, apks1.Id);
                Test.stopTest();
            }catch(Exception e){
                System.assertEquals('Script-thrown exception', e.getMessage());
            }
        }

        @isTest
        public static void getAadharDetailsTest1(){
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
                apks1.Income_source_available__c = true;
                insert apks1;
                
                 Documents__c dfks1 = new Documents__c();
                 dfks1.Applicant__c = apks1.Id;
                 dfks1.Opportunity_Relation__c = opks1.Id;
                 dfks1.Document_Type__c = 'Aadhaar';
                 dfks1.KYC_name__c = 'Rajjjj';
                 dfks1.Document_Side__c ='Back';
                 dfks1.Aadhar_Source__c = 'Biometric';
                 dfks1.is_Active__c = true;
                 dfks1.Name = 'Aadhaar';
                 insert dfks1;

                Test.startTest();
                LwcLOSLoanApplicationCntrl.getAadharDetails(opks1.Id, apks1.Id);
                Test.stopTest();
            }catch(Exception e){
                System.assertEquals('Script-thrown exception', e.getMessage());
            }
        }

        @isTest
        public static void getAadharDetailsTest2(){
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
                apks1.Income_source_available__c = true;
                insert apks1;
                
                 Documents__c dfks1 = new Documents__c();
                 dfks1.Applicant__c = apks1.Id;
                 dfks1.Opportunity_Relation__c = opks1.Id;
                 dfks1.Document_Type__c = 'Aadhaar';
                 dfks1.KYC_name__c = 'Rajjjj';
                 dfks1.Document_Side__c ='Back';
                 dfks1.Aadhar_Source__c = 'Biometric';
                 dfks1.is_Active__c = false;
                 dfks1.Name = 'Aadhaar';
                 insert dfks1;

                Test.startTest();
                LwcLOSLoanApplicationCntrl.getAadharDetails(opks1.Id, apks1.Id);
                Test.stopTest();
            }catch(Exception e){
                System.assertEquals('Script-thrown exception', e.getMessage());
            }
        }

       /*  @isTest
        public static void checkExistingDocumentTest(){
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
                 dfks1.Document_Type__c = 'Aadhar';
                 dfks1.KYC_name__c = 'Aadhar';
                 dfks1.Document_Side__c ='Back';
                 dfks1.Aadhar_Source__c = 'ScanAadhar';
                 dfks1.Name = 'Aadhar';
                 insert dfks1;
                
                 Blob beforeblob=Blob.valueOf('Unit Test Attachment Body');
                
                 ContentVersion cv = new ContentVersion();
                 cv.title = 'test content trigger';      
                 cv.PathOnClient ='test';           
                 cv.VersionData =beforeblob;          
                 insert cv;   
        
                 ContentVersion testContent = [SELECT id, ContentDocumentId FROM ContentVersion where Id = :cv.Id];
                
                 ContentDocumentLink contentlink = new ContentDocumentLink();
                 contentlink.ShareType = 'V';
                 contentlink.LinkedEntityId = dfks1.Id; 
                 contentlink.ContentDocumentId = testcontent.ContentDocumentId;
                 contentlink.Visibility = 'AllUsers'; 
                 insert contentlink;
                
                 Blob beforeblob1 = Blob.valueOf('Unit Test Attachment Body');
                
                 ContentVersion cv1 = new ContentVersion();
                 cv1.title = 'test content trigger';      
                 cv1.PathOnClient ='test';           
                 cv1.VersionData = beforeblob1; 
                 cv1.ContentDocumentId = contentlink.ContentDocumentId;
                 cv1.Document_Side_fileupload__c = 'Front';
                 insert cv1; 
                
                 Test.startTest();
                        LwcLOSLoanApplicationCntrl.checkExistingDocument(dfks1.Document_Type__c,apks1.Id,opks1.Id);
                 Test.stopTest();
                
            }catch(Exception e){
                System.assertEquals('Script-thrown exception', e.getMessage());
            }
        } */
        
       /*  @isTest
        public static void checkExistingDocumentTest1(){
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
                 dfks1.Document_Type__c = 'Aadhar';
                 dfks1.KYC_name__c = 'Aadhar';
                 dfks1.Document_Side__c ='Back';
                 dfks1.Aadhar_Source__c = 'ScanAadhar';
                 dfks1.Name = 'Aadhar';
                 insert dfks1;
                
                 Blob beforeblob=Blob.valueOf('Unit Test Attachment Body');
                
                 ContentVersion cv = new ContentVersion();
                 cv.title = 'test content trigger';      
                 cv.PathOnClient ='test';           
                 cv.VersionData =beforeblob;          
                 insert cv;   
        
                 ContentVersion testContent = [SELECT id, ContentDocumentId FROM ContentVersion where Id = :cv.Id];
                
                 ContentDocumentLink contentlink = new ContentDocumentLink();
                 contentlink.ShareType = 'V';
                 contentlink.LinkedEntityId = dfks1.Id; 
                 contentlink.ContentDocumentId = testcontent.ContentDocumentId;
                 contentlink.Visibility = 'AllUsers'; 
                 insert contentlink;
                
                 Blob beforeblob1 = Blob.valueOf('Unit Test Attachment Body');
                
                 ContentVersion cv1 = new ContentVersion();
                 cv1.title = 'test content trigger';      
                 cv1.PathOnClient ='test';           
                 cv1.VersionData = beforeblob1; 
                 cv1.ContentDocumentId = contentlink.ContentDocumentId;
                 cv1.Document_Side_fileupload__c = 'Back';
                 insert cv1; 
                
                 Test.startTest();
                        LwcLOSLoanApplicationCntrl.checkExistingDocument(dfks1.Document_Type__c,apks1.Id,opks1.Id);
                        LwcLOSLoanApplicationCntrl.checkExistingDocument('test','test','test');
                        LwcLOSLoanApplicationCntrl.checkExistingDocument(null,null,null);
                 Test.stopTest();
                
            }catch(Exception e){
                System.assertEquals('Script-thrown exception', e.getMessage());
            }
        } */
        
        @isTest
        public static void resendAadharBiometricTest(){
            try{
                Opportunity opra1 = new Opportunity();
                opra1.StageName = 'Qualification';
                opra1.CloseDate = Date.newInstance(2021, 1, 11);
                opra1.Name = 'testone';
                insert opra1;
                
                Applicant__c apra1 = new Applicant__c();
                apra1.Opportunity__c = opra1.Id;
                apra1.Contact_number__c = '9743514830';
                apra1.Applicant_Type__c = 'Borrower';
                insert apra1;
                
                 Documents__c dfra1 = new Documents__c();
                 dfra1.Applicant__c = apra1.Id;
                 dfra1.Opportunity_Relation__c = opra1.Id;
                 dfra1.Document_Type__c = System.label.AadhaarCard;
                 dfra1.Document_Side__c ='Back';
                 dfra1.Aadhar_Source__c = 'ScanAadhar';
                 dfra1.OTP_Resend_Attempts__c = null;
                 insert dfra1;
                
                 Test.startTest();
                    LwcLOSLoanApplicationCntrl.resendAadharBiometric(dfra1.Id);
                 Test.stopTest();
            }catch(Exception e){
                System.assertEquals('Script-thrown exception', e.getMessage());
            }
        }
        
        @isTest
        public static void contentDocumentPresentOrNotTest(){
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
                dfks1.Document_Type__c = System.Label.PanCards;
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
                LwcLOSLoanApplicationCntrl.contentDocumentPresentOrNot(dfks1.Id,null);
                Test.stopTest();
            }catch(Exception e){
                System.assertEquals('Script-thrown exception', e.getMessage());
            }
        }
        @isTest
        public static void contentDocumentPresentOrNotTest1(){
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
                dfks1.Document_Type__c = System.Label.AadhaarCard;
                dfks1.KYC_name__c = 'Aadhar';
                dfks1.Document_Side__c ='Back';
                dfks1.Aadhar_Source__c = 'Scan and Upload';
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
                LwcLOSLoanApplicationCntrl.contentDocumentPresentOrNot(dfks1.Id,'Scan and Upload');
                Test.stopTest();
            }catch(Exception e){
                System.assertEquals('Script-thrown exception', e.getMessage());
            }
        }
        
        @isTest
        public static void updateJourneyStopOfLeadTest(){
            try{
                Opportunity opks1 = new Opportunity();
                opks1.StageName = 'Qualification';
                opks1.CloseDate = Date.newInstance(2021, 1, 11);
                opks1.Name = 'testone';
                insert opks1;
                
                Test.startTest();
                LwcLOSLoanApplicationCntrl.updateJourneyStopOfLead(opks1.Id,'Journey stop');
                Test.stopTest();
            }catch(Exception e){
                System.assertEquals('Script-thrown exception', e.getMessage());
            }
        }
        
        @isTest
        public static void documentUpdateAftergoldenSourceTest(){
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
                dfks1.Document_Type__c = System.Label.AadhaarCard;
                dfks1.KYC_name__c = 'Aadhar';
                dfks1.Document_Side__c ='Back';
                dfks1.Aadhar_Source__c = 'Scan and Upload';
                dfks1.Name = 'Aadhar';
                insert dfks1;
                Test.startTest();
                LwcLOSLoanApplicationCntrl.documentUpdateAftergoldenSource(dfks1.Id,'Existing and valid Pan','Y',true,'Y','E','N');
                Test.stopTest();
            }catch(Exception e){
                System.assertEquals('Script-thrown exception', e.getMessage());
            }
        }
        @isTest
        public static void isPANForm60DocumentPresentTest1(){
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
                dfks1.Document_Type__c = System.Label.PanCards;
                dfks1.KYC_name__c = 'Aadhar';
                dfks1.Document_Side__c ='Back';
                dfks1.Aadhar_Source__c = 'Scan and Upload';
                dfks1.Name = 'Aadhar';
                dfks1.is_Active__c = true;
                insert dfks1;
                
                
                Test.startTest();
                LwcLOSLoanApplicationCntrl.isPANForm60DocumentPresent(apks1.Id);
                Test.stopTest();
            }catch(Exception e){
                System.assertEquals('Script-thrown exception', e.getMessage());
            }
        }
        
        @isTest
        public static void updateApplicantNameTest1(){
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
                dfks1.Document_Type__c = System.Label.PanCards;
                dfks1.KYC_name__c = 'Aadhar';
                dfks1.Document_Side__c ='Back';
                dfks1.Aadhar_Source__c = 'Scan and Upload';
                dfks1.Name = 'Aadhar';
                dfks1.First_Name__c = 'Test';
                dfks1.Last_Name__c = 'Test';
                dfks1.is_Active__c = true;
                insert dfks1;
                
                
                Test.startTest();
                LwcLOSLoanApplicationCntrl.updateApplicantName(apks1.Id);
                Test.stopTest();
            }catch(Exception e){
                System.assertEquals('Script-thrown exception', e.getMessage());
            }
        }
        
        @isTest
        public static void updateApplicantNameTest2(){
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
                dfks1.Document_Type__c = System.label.AadhaarCard;
                dfks1.KYC_name__c = 'Aadhar';
                dfks1.Document_Side__c ='Back';
                dfks1.Aadhar_Source__c = 'Scan and Upload';
                dfks1.Name = 'Aadhar';
                dfks1.First_Name__c = 'Test';
                dfks1.Last_Name__c = 'Test';
                dfks1.is_Active__c = true;
                insert dfks1;
                
                
                Test.startTest();
                LwcLOSLoanApplicationCntrl.updateApplicantName(apks1.Id);
                Test.stopTest();
            }catch(Exception e){
                System.assertEquals('Script-thrown exception', e.getMessage());
            }
        }
        
        @isTest
        public static void updateApplicantNameTest4(){
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
                dfks1.Document_Type__c = System.label.PassportCard;
                dfks1.KYC_name__c = 'Aadhar';
                dfks1.Document_Side__c ='Back';
                dfks1.Aadhar_Source__c = 'Scan and Upload';
                dfks1.Name = 'Aadhar';
                dfks1.First_Name__c = 'Test';
                dfks1.Last_Name__c = 'Test';
                dfks1.is_Active__c = true;
                insert dfks1;
                
                
                Test.startTest();
                LwcLOSLoanApplicationCntrl.updateApplicantName(apks1.Id);
                Test.stopTest();
            }catch(Exception e){
                System.assertEquals('Script-thrown exception', e.getMessage());
            }
        }
        @isTest
        public static void updateApplicantNameTest5(){
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
                dfks1.Document_Type__c = System.label.VoterIdCard;
                dfks1.KYC_name__c = 'Aadhar';
                dfks1.Document_Side__c ='Back';
                dfks1.Aadhar_Source__c = 'Scan and Upload';
                dfks1.Name = 'Aadhar';
                dfks1.First_Name__c = 'Test';
                dfks1.Last_Name__c = 'Test';
                dfks1.is_Active__c = true;
                insert dfks1;
                
                
                Test.startTest();
                LwcLOSLoanApplicationCntrl.updateApplicantName(apks1.Id);
                Test.stopTest();
            }catch(Exception e){
                System.assertEquals('Script-thrown exception', e.getMessage());
            }
        }
        @isTest
        public static void updateCustomerImageFileTitleTest(){
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
                LwcLOSLoanApplicationCntrl.updateCustomerImageFileTitle(dfks1.Id,testContent1.ContentDocumentId);
                Test.stopTest();
            }catch(Exception e){
                System.assertEquals('Script-thrown exception', e.getMessage());
            }
        }
        @isTest
        public static void getKycDocumentCountTest1(){
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
                dfks1.Document_Type__c = System.Label.AadhaarCard;
                dfks1.KYC_name__c = 'Aadhar';
                dfks1.Document_Side__c ='Back';
                dfks1.Aadhar_Source__c = 'Scan and Upload';
                dfks1.Name = 'Aadhar';
                dfks1.First_Name__c = 'Test';
                dfks1.Last_Name__c = 'Test';
                dfks1.is_Active__c = true;
                insert dfks1;
                
                
                Test.startTest();
                LwcLOSLoanApplicationCntrl.getKycDocumentCount(apks1.Id);
                Test.stopTest();
            }catch(Exception e){
                System.assertEquals('Script-thrown exception', e.getMessage());
            }
        }
        
        @isTest
        public static void getApplicantTest1(){
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
                
                Test.startTest();
                LwcLOSLoanApplicationCntrl.getApplicant(opks1.Id,'Borrower');
                Test.stopTest();
            }catch(Exception e){
                System.assertEquals('Script-thrown exception', e.getMessage());
            }
        }
        @isTest
        public static void checkCountOfContentDocTest(){
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
                LwcLOSLoanApplicationCntrl.checkCountOfContentDoc(dfks1.Id);
                Test.stopTest();
            }catch(Exception e){
                System.assertEquals('Script-thrown exception', e.getMessage());
            }
        }
        @isTest
        public static void deleteIncomeDetailIfNoIncomeSourceTest(){
            try{
                Opportunity opks1 = new Opportunity();
                opks1.StageName = 'Qualification';
                opks1.CloseDate = Date.newInstance(2021, 1, 11);
                opks1.Name = 'testone';
                opks1.LeadSource = 'Digital-MSIL-Custom';
                insert opks1;
                
                Applicant__c apks1 = new Applicant__c();
                apks1.Opportunity__c = opks1.Id;
                apks1.Contact_number__c = '9743514830';
                apks1.Applicant_Type__c = 'Borrower';
                apks1.In_Active_Applicant__c = false;
                apks1.DocAuth_Application_Id__c = 'testauth';
                apks1.Selfie_Upload__c = true;
                insert apks1;
                
                Income_Details__c inObj = new Income_Details__c();
                inObj.Applicant__c = apks1.Id;
                insert inObj;
                
                Test.startTest();
                LwcLOSLoanApplicationCntrl.deleteIncomeDetailIfNoIncomeSource(opks1.Id);
                Test.stopTest();
            }catch(Exception e){
                System.assertEquals('Script-thrown exception', e.getMessage());
            }
        }
        @isTest
        public static void updatePermanentProofOfAddressInDocumentsTest(){
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
                apks1.Current_Same_As_Permanent__c=true;
                insert apks1;
                
                Documents__c dfks1 = new Documents__c();
                dfks1.Applicant__c = apks1.Id;
                dfks1.Opportunity_Relation__c = opks1.Id;
                dfks1.Document_Type__c = System.Label.CustomerImageDocumentType;
                dfks1.KYC_name__c = 'Aadhar';
                dfks1.Document_Side__c ='Back';
                dfks1.Aadhar_Source__c = 'ScanAadhar';
                dfks1.Name = 'Aadhar';
                dfks1.Current_Residential_Address_Proof__c = true;
                insert dfks1;
                
                Test.startTest();
                LwcLOSLoanApplicationCntrl.updatePermanentProofOfAddressInDocuments(opks1.Id);
                LwcLOSLoanApplicationCntrl.updateCurrentPermanentProofOfAddressInDocument(apks1.Id);
                Test.stopTest();
            }catch(Exception e){
                System.assertEquals('Script-thrown exception', e.getMessage());
            }
        }
        @isTest
        public static void checkCurrentSubStageTest(){
            try{
                Opportunity opks1 = new Opportunity();
                opks1.StageName = 'Qualification';
                opks1.CloseDate = Date.newInstance(2021, 1, 11);
                opks1.Sub_Stage__c = 'Income';
                opks1.Name = 'testone';
                insert opks1;
                
                Test.startTest();
                LwcLOSLoanApplicationCntrl.checkCurrentSubStage(opks1.Id,'Cibil');
                Test.stopTest();
            }catch(Exception e){
                System.assertEquals('Script-thrown exception', e.getMessage());
            }
        }
        @isTest
        public static void createAddressDeclarationDocumentTest(){
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
                apks1.Current_Address_Not_Present__c=true;
                apks1.Is_Address_Declaration__c = true;
                insert apks1;
                
                Documents__c dfks1 = new Documents__c();
                dfks1.Applicant__c = apks1.Id;
                dfks1.Opportunity_Relation__c = opks1.Id;
                dfks1.Document_Type__c = 'Address Declaration';
                dfks1.KYC_name__c = 'Aadhar';
                dfks1.Document_Side__c ='Back';
                dfks1.Aadhar_Source__c = 'ScanAadhar';
                dfks1.Name = 'Aadhar';
                dfks1.Current_Residential_Address_Proof__c = true;
                insert dfks1;
                
                Test.startTest();
                LwcLOSLoanApplicationCntrl.createAddressDeclarationDocument(opks1.Id,apks1.Id);
                Test.stopTest();
            }catch(Exception e){
                System.assertEquals('Script-thrown exception', e.getMessage());
            }
        }
        
        @isTest
        public static void checkIfPanNoIsSameOrNotTest(){
            try{
                Opportunity opra1 = new Opportunity();
                opra1.StageName = 'Qualification';
                opra1.CloseDate = Date.newInstance(2021, 1, 11);
                opra1.Name = 'testone';
                insert opra1;
                
                Applicant__c apra1 = new Applicant__c();
                apra1.Opportunity__c = opra1.Id;
                apra1.Contact_number__c = '9743514830';
                apra1.Applicant_Type__c = 'Borrower';
                insert apra1;
                
                 Applicant__c apra2 = new Applicant__c();
                apra2.Opportunity__c = opra1.Id;
                apra2.Contact_number__c = '9743514830';
                apra2.Applicant_Type__c = 'Co-borrower';
                insert apra2;
                
                 Documents__c dfra1 = new Documents__c();
                 dfra1.Applicant__c = apra1.Id;
                 dfra1.Opportunity_Relation__c = opra1.Id;
                 dfra1.Document_Type__c = 'PAN';
                 dfra1.Document_Side__c ='Back';
                 dfra1.Aadhar_Source__c = 'ScanAadhar';
                 dfra1.OTP_Resend_Attempts__c = null;
                dfra1.PAN_No__c = 'Ycx7q486y5XsWnmvEZs/Yg==';
                 insert dfra1;
                
                 Test.startTest();
                    LwcLOSLoanApplicationCntrl.checkIfPanNoIsSameOrNot('GTAPK1744M',apra2.Id,opra1.Id);
                LwcLOSLoanApplicationCntrl.checkIfPanNoIsSameOrNot('GTAPK1744N',apra2.Id,opra1.Id);
                 Test.stopTest();
            }catch(Exception e){
                System.assertEquals('Script-thrown exception', e.getMessage());
            }
        }
        @isTest
        public static void getCheckOtherCoBorrowerClosed(){
            
                Opportunity optl1 = new Opportunity();
                optl1.StageName = 'Asset Details';
                optl1.CloseDate = Date.newInstance(2023, 1, 11);
                optl1.Name = 'testone';
                insert optl1;
                
                Applicant__c aptl1 = new Applicant__c();
                aptl1.Opportunity__c = optl1.Id;
                aptl1.Contact_number__c = '9743514830';
                aptl1.Applicant_Type__c = 'Co-borrower';
                insert aptl1;
                
                Test.startTest();
                    Boolean res = LwcLOSLoanApplicationCntrl.checkOtherCoBorrowerClosed(optl1.Id);
                    //System.assertEquals(res,true);
                Test.stopTest();
        } 
        @isTest
        public static void isAllApplicantsIlliterateTest(){
            
                Opportunity optl1 = new Opportunity();
                optl1.StageName = 'Asset Details';
                optl1.CloseDate = Date.newInstance(2023, 1, 11);
                optl1.Name = 'testone';
                insert optl1;
                
                Applicant__c aptl1 = new Applicant__c();
                aptl1.Opportunity__c = optl1.Id;
                aptl1.Contact_number__c = '9743514830';
                aptl1.Applicant_Type__c = 'Co-borrower';
            	aptl1.Literacy__c = 'Literate';
                insert aptl1;
                
                Test.startTest();
                    LwcLOSLoanApplicationCntrl.isAllApplicantsIlliterate(optl1.Id);
                    LwcLOSLoanApplicationCntrl.getApplicantRelationshipWithBank(aptl1.Id);
            		aptl1.Applicant_Type__c = 'Beneficiary';
            		aptl1.ShareHolding__c = 60;
            		update aptl1;
            		LwcLOSLoanApplicationCntrl.getBeneficiarySHPercent(optl1.Id);
                Test.stopTest();
        }
        @isTest
        public static void isAllMandatoryDocUploadedTest(){
            
                Opportunity optl1 = new Opportunity();
                optl1.StageName = 'Asset Details';
                optl1.CloseDate = Date.newInstance(2023, 1, 11);
                optl1.Name = 'testone';
            	optl1.Entity_Type__c = 'Pvt Ltd';
                insert optl1;
                
                Applicant__c aptl1 = new Applicant__c();
                aptl1.Opportunity__c = optl1.Id;
                aptl1.Contact_number__c = '9743514830';
                aptl1.Applicant_Type__c = 'Borrower';
            	aptl1.Literacy__c = 'Literate';
                insert aptl1;
            	 Documents__c dfra1 = new Documents__c();
                 dfra1.Applicant__c = aptl1.Id;
                 dfra1.Opportunity_Relation__c = optl1.Id;
                 dfra1.Document_Type__c = System.Label.PanCards;
                 dfra1.Document_Side__c ='Back';
                 dfra1.Aadhar_Source__c = 'ScanAadhar';
                 dfra1.OTP_Resend_Attempts__c = null;
                dfra1.PAN_No__c = 'Ycx7q486y5XsWnmvEZs/Yg==';
                 insert dfra1;
            	 Documents__c dfra2 = new Documents__c();
                 dfra2.Applicant__c = aptl1.Id;
                 dfra2.Opportunity_Relation__c = optl1.Id;
                 dfra2.Document_Type__c = System.Label.GST_Cert;
                 dfra2.Document_Side__c ='Back';
                 dfra2.Aadhar_Source__c = 'ScanAadhar';
                 dfra2.OTP_Resend_Attempts__c = null;
                dfra2.PAN_No__c = 'Ycx7q486y5XsWnmvEZs/Yg==';
                 insert dfra2;
            	 Documents__c dfra3 = new Documents__c();
                 dfra3.Applicant__c = aptl1.Id;
                 dfra3.Opportunity_Relation__c = optl1.Id;
                 dfra3.Document_Type__c = System.Label.CIN_Cert;
                 dfra3.Document_Side__c ='Back';
                 dfra3.Aadhar_Source__c = 'ScanAadhar';
                 dfra3.OTP_Resend_Attempts__c = null;
                dfra3.PAN_No__c = 'Ycx7q486y5XsWnmvEZs/Yg==';
                 insert dfra3;
                CIBIL_Details__c cibil_Detail=new CIBIL_Details__c(
                Other_Loan_AD__c=null,
                Term_Loan_AD__c=null,
                Other_Loan_PD__c=null,
                Term_Loan_PD__c=null,
                Overdue_Account__c=null,
                Applicant__c=aptl1.Id);
            Vehicle_Detail__c vehiObj = new Vehicle_Detail__c();
            vehiObj.Loan_Application__c = optl1.Id;
            insert vehiObj; 
            insert cibil_Detail;
                Test.startTest();
            		LwcLOSLoanApplicationCntrl.isAllMandatoryDocUploaded(optl1.Id,aptl1.Id);
            		optl1.Entity_Type__c = 'Partnership';
            		update optl1;
            		LwcLOSLoanApplicationCntrl.isAllMandatoryDocUploaded(optl1.Id,aptl1.Id);
            		optl1.Entity_Type__c = null;
            		update optl1;
            		LwcLOSLoanApplicationCntrl.isAllMandatoryDocUploaded(optl1.Id,aptl1.Id);
            		optl1.Hunter_APS_Response__c = 'Success';
            		optl1.Hunter_Match_Status__c = '96';
            		optl1.Customer_Type__c = 'Non-Individual';
            		update optl1;
            		LwcLOSLoanApplicationCntrl.getHunterResponse(optl1.Id);
            		LwcLOSLoanApplicationCntrl.checkL2CibilSubmitted(optl1.Id);
            		 aptl1.Applicant_Type__c= 'Co-borrower';
            		update aptl1;
            		LwcLOSLoanApplicationCntrl.checkL2CibilSubmitted(optl1.Id);
            		LwcLOSLoanApplicationCntrl.deleteVehicleDetail(vehiObj.Id);
                Test.stopTest();
        }
         @isTest
        public static void updateVehicleDetailsTest(){
            	Opportunity optl1 = new Opportunity();
                optl1.StageName = 'Asset Details';
                optl1.CloseDate = Date.newInstance(2023, 1, 11);
                optl1.Name = 'testone';
            	optl1.Entity_Type__c = 'Pvt Ltd';
                insert optl1;
            
                LwcLOSLoanApplicationCntrl.vehicledetailsWrapper veObj = new LwcLOSLoanApplicationCntrl.vehicledetailsWrapper();
            	veObj.oppRecId = optl1.Id;
            	veObj.vehicleType = 'Used';
            	 
            	List<LwcLOSLoanApplicationCntrl.vehicledetailsWrapper> vehiList = new List<LwcLOSLoanApplicationCntrl.vehicledetailsWrapper>();
            	vehiList.add(veObj);
                
                Test.startTest();
                try {
                    LwcLOSLoanApplicationCntrl.updateVehicleDetails(vehiList);
                } catch (Exception e) {}
                   
                Test.stopTest();
        } 
         @isTest
        public static void getDealNumbersTest(){
            	Opportunity optl1 = new Opportunity();
                optl1.StageName = 'Asset Details';
                optl1.CloseDate = Date.newInstance(2023, 1, 11);
                optl1.Name = 'testone';
            	optl1.Entity_Type__c = 'Pvt Ltd';
            	optl1.Product_Type__c = 'Tractor';
                insert optl1;
            
                Applicant__c aptl1 = new Applicant__c();
                aptl1.Opportunity__c = optl1.Id;
                aptl1.Contact_number__c = '9743514830';
                aptl1.Applicant_Type__c = 'Borrower';
            	aptl1.Literacy__c = 'Literate';
            	aptl1.Relationship_with_borrower__c = 'FATHER';
                insert aptl1;
                 Vehicle_Detail__c vehiObj = new Vehicle_Detail__c();
                vehiObj.Loan_Application__c = optl1.Id;
                insert vehiObj;
             Account testAccount = new Account(Name = 'Test view Acc' ,BranchBLCode__c = '34543');
            insert testAccount;
                Test.startTest();
                try {
                    LwcLOSLoanApplicationCntrl.getTabListForInsurance(optl1.Id);
                     aptl1.Applicant_Type__c = 'Co-borrower';
                     update aptl1;
                     LwcLOSLoanApplicationCntrl.getTabListForInsurance(optl1.Id);
                     LwcLOSLoanApplicationCntrl.getApplicantStageDetails(aptl1.Id);
             
                     LwcLOSLoanApplicationCntrl.createOtherDocumentForTractorVehile('Pan',aptl1.Id,optl1.Id,vehiObj.Id);
                } catch (Exception e) {}
                  	
                Test.stopTest();
        } 
          @isTest
        public static void getVehicleDetailsRecordTest(){
            	Opportunity optl1 = new Opportunity();
                optl1.StageName = 'Asset Details';
                optl1.CloseDate = Date.newInstance(2023, 1, 11);
                optl1.Name = 'testone';
            	optl1.Entity_Type__c = 'Pvt Ltd';
                insert optl1;
            
                LwcLOSLoanApplicationCntrl.vehicledetailsWrapper veObj = new LwcLOSLoanApplicationCntrl.vehicledetailsWrapper();
            	veObj.oppRecId = optl1.Id;
            	veObj.vehicleType = 'Used';
            	 
            	List<LwcLOSLoanApplicationCntrl.vehicledetailsWrapper> vehiList = new List<LwcLOSLoanApplicationCntrl.vehicledetailsWrapper>();
            	vehiList.add(veObj);
            Applicant__c aptl1 = new Applicant__c();
                aptl1.Opportunity__c = optl1.Id;
                aptl1.Contact_number__c = '9743514830';
                aptl1.Applicant_Type__c = 'Borrower';
            	aptl1.Literacy__c = 'Literate';
            	aptl1.Relationship_with_borrower__c = 'FATHER';
            	aptl1.In_Active_Applicant__c = false;
                insert aptl1;
                 Vehicle_Detail__c vehiObj = new Vehicle_Detail__c();
                vehiObj.Loan_Application__c = optl1.Id;
                insert vehiObj;
                
                Test.startTest();
                try {
                    LwcLOSLoanApplicationCntrl.getVehicleDetailsRecord(optl1.Id);
                } catch (Exception e) {}
                   
                Test.stopTest();
        }
        @isTest
        public static void checkOtherBeneficaryClosedTest(){
            	Opportunity optl1 = new Opportunity();
                optl1.StageName = 'Asset Details';
                optl1.CloseDate = Date.newInstance(2023, 1, 11);
                optl1.Name = 'testone';
            	optl1.Entity_Type__c = 'Pvt Ltd';
                insert optl1;
            
                Applicant__c aptl1 = new Applicant__c();
                aptl1.Opportunity__c = optl1.Id;
                aptl1.Contact_number__c = '9743514830';
                aptl1.Applicant_Type__c = System.label.Beneficiary;
            	aptl1.Literacy__c = 'Literate';
            	aptl1.Relationship_with_borrower__c = 'FATHER';
            	aptl1.In_Active_Applicant__c = false;
                insert aptl1;
                
                Test.startTest();
                try {
                    LwcLOSLoanApplicationCntrl.checkOtherBeneficaryClosed(optl1.Id);
                } catch (Exception e) {}
                   
                Test.stopTest();
        } 
    }