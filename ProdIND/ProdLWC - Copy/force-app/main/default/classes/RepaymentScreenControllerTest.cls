@isTest
public class RepaymentScreenControllerTest 
{
    @testSetup 
    static void testDataSetup() 
    {
        //create user
        Profile p = [SELECT Id FROM Profile WHERE Name='IBL CVO'];
        User u = new User(Alias = 'standt2', Email='standarduser2@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,Maker_Id__c='12',IsActive = true,
                          TimeZoneSidKey='America/Los_Angeles',UserName='test_userprod03@indusbank.com',MobilePhone = '9089078967');
        insert u;
        Profile p1 = [SELECT Id FROM Profile WHERE Name='IBL Operation Head'];
        User u1 = new User(Alias = 'standt23', Email='standarduser23@testorg.com',
                           EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                           LocaleSidKey='en_US', ProfileId = p1.Id,Maker_Id__c='1256',IsActive = true,
                           TimeZoneSidKey='America/Los_Angeles',UserName='test_userprod143@indusbank.com',MobilePhone = '9089078967');
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
    public static void displayRepaymentInfoTest(){
        try
        {    
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod03@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {
                Opportunity oppRec = [SELECT Id, Vehicle_Type__c, Product_Type__c FROM Opportunity WHERE Vehicle_Type__c = 'Used' LIMIT 1];
                oppRec.Product_Type__c = System.Label.Tractor;
                update oppRec;
                
                Deal_Number_Setting__c dlNumberSetting= new Deal_Number_Setting__c();
                dlNumberSetting.Name = System.Label.Tractor;
                dlNumberSetting.MDNField1__c ='AB';
                dlNumberSetting.MDNField2__c =2;
                insert dlNumberSetting;
                system.debug('Deal Setting'+ dlNumberSetting);
                
                Deal_Number__c dl = new Deal_Number__c();
                dl.Loan_Application__c = oppRec.Id;
                dl.DNField1__c = dlNumberSetting.MDNField1__c;
                dl.DNField2__c = String.valueOf(dlNumberSetting.MDNField2__c);
                dl.Sub_Stage__c = 'RC Upload';
               // insert dl;
                
                Repayments__c repayment1 = RepaymentScreenController.displayRepaymentInfo(oppRec.Id,dl.Id);
                RepaymentScreenController.displayRepaymentInfo(null,null);
                System.assertNotEquals(null, repayment1);
            }
            User u1 = [SELECT Id,usertype FROM User WHERE UserName='test_userprod143@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u1){
                Repayments__c repayment2 = RepaymentScreenController.displayRepaymentInfo('@#$%^','test');  
                System.assertEquals(null, repayment2);
            }
            Test.stopTest();            
        }
        catch(Exception e)
        {
            system.debug('error '+ e.getMessage());
        }
    }
    
    @isTest 
    public static void getRepaymentToBeDoneByTest(){
        try
        {    
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod03@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {
                Opportunity oppRec = [SELECT Id, Vehicle_Type__c, Product_Type__c FROM Opportunity WHERE Vehicle_Type__c = 'Used' LIMIT 1];            
                RepaymentScreenController.IsWillingDoneByWrapper applicant1Wrapper = RepaymentScreenController.getRepaymentToBeDoneBy(oppRec.Id);
                System.assertNotEquals(null, applicant1Wrapper);                
            }
            User u1 = [SELECT Id,usertype FROM User WHERE UserName='test_userprod143@indusbank.com' AND IsActive = true LIMIT 1]; 
            Opportunity oppRec = [SELECT Id, Vehicle_Type__c, Product_Type__c FROM Opportunity WHERE Vehicle_Type__c = 'Used' LIMIT 1];            
            System.runAs(u1){
                RepaymentScreenController.IsWillingDoneByWrapper applicant2Wrapper = RepaymentScreenController.getRepaymentToBeDoneBy('#$%^');
                System.assertNotEquals(null, applicant2Wrapper); 
            }
            Test.stopTest();            
        }
        catch(Exception e)
        {
            system.debug('error '+ e.getMessage());
        }
    }    
    
    @isTest 
    public static void getLoanAmountTest(){
        try
        {    
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod03@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {
                Opportunity oppRec = [SELECT Id, Vehicle_Type__c, Product_Type__c FROM Opportunity WHERE Vehicle_Type__c = 'Used' LIMIT 1];
                oppRec.Product_Type__c = System.Label.Tractor;
                update oppRec;
                
                Deal_Number_Setting__c dlNumberSetting= new Deal_Number_Setting__c();
                dlNumberSetting.Name = System.Label.Tractor;
                dlNumberSetting.MDNField1__c ='AB';
                dlNumberSetting.MDNField2__c =2;
                insert dlNumberSetting;
                system.debug('Deal Setting'+ dlNumberSetting);
                
                Deal_Number__c dl = new Deal_Number__c();
                dl.Loan_Application__c = oppRec.Id;
                dl.DNField1__c = dlNumberSetting.MDNField1__c;
                dl.DNField2__c = String.valueOf(dlNumberSetting.MDNField2__c);
                dl.Sub_Stage__c = 'RC Upload';
                insert dl;
                
                Final_Term__c finalTermObj = RepaymentScreenController.getLoanAmount(oppRec.Id,dl.id);
                System.assertNotEquals(null, finalTermObj);
                
            }
            User u1 = [SELECT Id,usertype FROM User WHERE UserName='test_userprod143@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u1){
                Final_Term__c finalTermObj = RepaymentScreenController.getLoanAmount('#$%^','test');
                System.assertEquals(null, finalTermObj); 
            }
            Test.stopTest();            
        }
        catch(Exception e)
        {
            system.debug('error '+ e.getMessage());
        }
    }  
    
    @isTest 
    public static void createRepaymentRecordTest(){
        try
        {    
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod03@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {
                Opportunity oppRec = [SELECT Id, Vehicle_Type__c, Product_Type__c FROM Opportunity WHERE Vehicle_Type__c = 'Used' LIMIT 1];   
                oppRec.Product_Type__c = System.Label.Tractor;
                update oppRec;
                
                Deal_Number_Setting__c dlNumberSetting= new Deal_Number_Setting__c();
                dlNumberSetting.Name = System.Label.Tractor;
                dlNumberSetting.MDNField1__c ='AB';
                dlNumberSetting.MDNField2__c =2;
                insert dlNumberSetting;
                system.debug('Deal Setting'+ dlNumberSetting);
                
                Deal_Number__c dl = new Deal_Number__c();
                dl.Loan_Application__c = oppRec.Id;
                dl.DNField1__c = dlNumberSetting.MDNField1__c;
                dl.DNField2__c = String.valueOf(dlNumberSetting.MDNField2__c);
                dl.Sub_Stage__c = 'RC Upload';
                insert dl;
                
                
                Repayments__c repay = [
                    SELECT
                    Id,
                    Is_Cancelled_Cheque_legible__c,
                    ACH_Form_filled_correctly__c,
                    Is_SI_form_Legible__c,
                    SI_Form_filled_correctly__c,
                    Authorization_mode_available__c,
                    E_NACH_API_Status__c,
                    Is_Netbanking_available_with_customer__c,
                    Is_debit_card_available_with_customer__c,
                    Repayment_Method__c,
                    Until_Cancelled__c,
                    End_Date__c,
                    Frequency__c,
                    Bank_Master__c,
                    Bank_Master__r.Name,
                    IFSC_Code__c,
                    Account_Number__c,
                    Remarks__c,
                    RecordType.DeveloperName,
                    SB_Or_CAis_ticked_appropriately__c
                    FROM Repayments__c
                    WHERE Loan_Application__c = :oppRec.Id                
                    LIMIT 1];            
                
                Repayments__c repayment1 = RepaymentScreenController.createRepaymentRecord(oppRec.Id,repay,dl.Id);
                System.assertNotEquals(null, repayment1);
                Repayments__c repayment2 = RepaymentScreenController.createRepaymentRecord(oppRec.Id,null,dl.Id);
                System.assertNotEquals(null, repayment2);
                Repayments__c repayment3 = RepaymentScreenController.createRepaymentRecord('@#$%^','@#$%^','test');
                System.assertEquals(null, repayment3);
                Repayments__c repayment4 = RepaymentScreenController.createRepaymentRecord(null,repay,null);
                System.assertNotEquals(null, repayment4);
            }
            Test.stopTest();            
        }
        catch(Exception e)
        {
            system.debug('error '+ e.getMessage());
        }
    }  
    
    @isTest 
    public static void getFinalTermRecordTest(){
        try
        {    
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod03@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {
                Opportunity oppRec = [SELECT Id, Vehicle_Type__c, Product_Type__c FROM Opportunity WHERE Vehicle_Type__c = 'Used' LIMIT 1];    
                oppRec.Product_Type__c = System.Label.Tractor;
                update oppRec;
                
                Deal_Number_Setting__c dlNumberSetting= new Deal_Number_Setting__c();
                dlNumberSetting.Name = System.Label.Tractor;
                dlNumberSetting.MDNField1__c ='AB';
                dlNumberSetting.MDNField2__c =2;
                insert dlNumberSetting;
                system.debug('Deal Setting'+ dlNumberSetting);
                
                Deal_Number__c dl = new Deal_Number__c();
                dl.Loan_Application__c = oppRec.Id;
                dl.DNField1__c = dlNumberSetting.MDNField1__c;
                dl.DNField2__c = String.valueOf(dlNumberSetting.MDNField2__c);
                dl.Sub_Stage__c = 'RC Upload';
                insert dl;
                
                Final_Term__c ft1 = RepaymentScreenController.getFinalTermRecord(oppRec.Id,dl.Id);
                System.assertNotEquals(null, ft1);
            }
            User u1 = [SELECT Id,usertype FROM User WHERE UserName='test_userprod143@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u1){
                Opportunity oppRec = [SELECT Id, Vehicle_Type__c, Product_Type__c FROM Opportunity WHERE Vehicle_Type__c = 'Used' LIMIT 1]; 
                oppRec.Product_Type__c = System.Label.Tractor;
                update oppRec;
                
                Deal_Number_Setting__c dlNumberSetting= new Deal_Number_Setting__c();
                dlNumberSetting.Name = System.Label.Tractor;
                dlNumberSetting.MDNField1__c ='AB';
                dlNumberSetting.MDNField2__c =2;
                insert dlNumberSetting;
                system.debug('Deal Setting'+ dlNumberSetting);
                
                Deal_Number__c dl = new Deal_Number__c();
                dl.Loan_Application__c = oppRec.Id;
                dl.DNField1__c = dlNumberSetting.MDNField1__c;
                dl.DNField2__c = String.valueOf(dlNumberSetting.MDNField2__c);
                dl.Sub_Stage__c = 'RC Upload';
                insert dl;
                Final_Term__c ft2 = RepaymentScreenController.getFinalTermRecord(oppRec.Id,dl.Id);
                RepaymentScreenController.getFinalTermRecord('test','test1');
                RepaymentScreenController.getFinalTermRecord(null,null);
                System.assertEquals(null, ft2);
            }
            Test.stopTest();            
        }
        catch(Exception e)
        {
            system.debug('error '+ e.getMessage());
        }
    }  
    
    @isTest 
    public static void getlstEMIDueDateTest(){
        try
        {    
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod03@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {   
                Opportunity oppObj = [Select Id From Opportunity LIMIT 1];
                oppObj.Product_Type__c = System.Label.Tractor;
                update oppObj;
                
                Deal_Number_Setting__c dlNumberSetting= new Deal_Number_Setting__c();
                dlNumberSetting.Name = System.Label.Tractor;
                dlNumberSetting.MDNField1__c ='AB';
                dlNumberSetting.MDNField2__c =2;
                insert dlNumberSetting;
                system.debug('Deal Setting'+ dlNumberSetting);
                
                Deal_Number__c dl = new Deal_Number__c();
                dl.Loan_Application__c = oppObj.Id;
                dl.DNField1__c = dlNumberSetting.MDNField1__c;
                dl.DNField2__c = String.valueOf(dlNumberSetting.MDNField2__c);
                dl.Sub_Stage__c = 'RC Upload';
                insert dl;
                
                
                Loan_Agreement__c loanAgreement = RepaymentScreenController.getlstEMIDueDate(null,null);
                System.assertEquals(null, loanAgreement);
                
                Loan_Agreement__c loanAgreement1 = RepaymentScreenController.getlstEMIDueDate(oppObj.Id,dl.Id);
                System.assertNotEquals(null, loanAgreement1);
            }
            Test.stopTest();            
        }
        catch(Exception e)
        {
            system.debug('error '+ e.getMessage());
        }
    } 
    
    @isTest 
    public static void getAuthorizationModeTest(){
        try
        {    
            Test.startTest();            
            User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod03@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {
                RepaymentScreenController.getAuthorizationMode(null);
                RepaymentScreenController.getAuthorizationMode('test');
            }
            Test.stopTest();            
        }
        catch(Exception e)
        {
            System.assert(e.getMessage().contains('Insufficient permissions'));
        }
    }
    
    @isTest 
    public static void validateACHDocsTest(){
        try
        {    
            Test.startTest();       
            User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod03@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {
                Opportunity oppRec = [SELECT Id, Vehicle_Type__c, Product_Type__c FROM Opportunity WHERE Vehicle_Type__c = 'Used' LIMIT 1];              
                String result = RepaymentScreenController.validateACHDocs(oppRec.Id);
                String result1 = RepaymentScreenController.validateACHDocs('test');  
                System.assertNotEquals(null, result);
            }
            Test.stopTest();            
        }
        catch(Exception e)
        {
            system.debug('error '+ e.getMessage());
        }
    }
    
    @isTest 
    public static void isLoanAgreementSubmittedTest(){
        try
        {    
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod03@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {
                Opportunity oppRec = [SELECT Id, Vehicle_Type__c, Product_Type__c FROM Opportunity WHERE Vehicle_Type__c = 'Used' LIMIT 1]; 
                oppRec.Product_Type__c = System.Label.Tractor;
                update oppRec;
                
                Deal_Number_Setting__c dlNumberSetting= new Deal_Number_Setting__c();
                dlNumberSetting.Name = System.Label.Tractor;
                dlNumberSetting.MDNField1__c ='AB';
                dlNumberSetting.MDNField2__c =2;
                insert dlNumberSetting;
                system.debug('Deal Setting'+ dlNumberSetting);
                
                Deal_Number__c dl = new Deal_Number__c();
                dl.Loan_Application__c = oppRec.Id;
                dl.DNField1__c = dlNumberSetting.MDNField1__c;
                dl.DNField2__c = String.valueOf(dlNumberSetting.MDNField2__c);
                dl.Sub_Stage__c = 'RC Upload';
                insert dl;
                
                oppRec.StageName = 'Post Sanction Checks and Documentation';
                update oppRec;
                Loan_Application_Transaction_History__c loanAppHis = [Select Id, Submitted_Flag__c, Name, Screen__c, Module__c
                                                                      From Loan_Application_Transaction_History__c Where 
                                                                      Loan_Application_ID__c =: oppRec.Id LIMIT 1];
                // loanAppHis.Name = 'Loan Agreement';
                loanAppHis.Screen__c = 'Loan Agreement';
                loanAppHis.Module__c = 'Post Sanction Checks and Documentation';
                loanAppHis.Submitted_Flag__c = true;
                update loanAppHis;
                Boolean result1 = RepaymentScreenController.isLoanAgreementSubmitted(oppRec.Id,dl.Id);
                System.assertNotEquals(false, result1);
                loanAppHis.Submitted_Flag__c = false;
                update loanAppHis;
                List<Applicant__c> applicantRec = [Select Id,Willing_to_open_Bank_Account_with_IIB__c from Applicant__c LIMIT 1];
                applicantRec[0].Willing_to_open_Bank_Account_with_IIB__c = false;
                update applicantRec;
                Boolean result2 = RepaymentScreenController.isLoanAgreementSubmitted(oppRec.Id,dl.Id);
                System.assertEquals(true, result2);
            }            
            Test.stopTest();            
        }
        catch(Exception e)
        {
            system.debug('error '+ e.getMessage());
        }
    }                 
    
    @isTest 
    public static void deactivateOldDocsTest(){
        try
        {    
            Test.startTest();      
            User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod03@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {
                Opportunity oppRec = [SELECT Id, Vehicle_Type__c, Product_Type__c FROM Opportunity WHERE Vehicle_Type__c = 'Used' LIMIT 1];     
                List<Documents__c> docList = new List<Documents__c>();
                for (Documents__c doc : [SELECT Id, is_Active__c FROM Documents__c WHERE Opportunity_Relation__c = :oppRec.id AND Document_Type__c =: System.Label.AadhaarCard]) {
                    doc.is_Active__c = true;
                    docList.add(doc);
                }
                update docList;
                RepaymentScreenController.deactivateOldDocs(oppRec.Id,'t',System.Label.AadhaarCard);  
                Documents__c doc = [SELECT Id, is_Active__c FROM Documents__c WHERE is_Active__c = false];
                System.assertNotEquals(null, doc);
            }
            User u1 = [SELECT Id,usertype FROM User WHERE UserName='test_userprod143@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u1){
                Opportunity oppRec = [SELECT Id, Vehicle_Type__c, Product_Type__c FROM Opportunity WHERE Vehicle_Type__c = 'Used' LIMIT 1];              
                RepaymentScreenController.deactivateOldDocs(oppRec.Id,'t','Pan');  
                Documents__c doc = [SELECT Id, is_Active__c FROM Documents__c WHERE is_Active__c = false];
                System.assertNotEquals(null, doc);
            }
            Test.stopTest();            
        }
        catch(Exception e)
        {
            system.debug('error '+ e.getMessage());
        }
    }
    
    @isTest 
    public static void createOtherDocumentTest(){
        try
        {    
            Test.startTest();            
            User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod03@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {
                Opportunity oppRec = [SELECT Id, Vehicle_Type__c, Product_Type__c FROM Opportunity WHERE Vehicle_Type__c = 'Used' LIMIT 1]; 
                Repayments__c repay = [SELECT Id FROM Repayments__c WHERE Loan_Application__c = :oppRec.Id LIMIT 1];  
                Applicant__c app = [SELECT Id FROM Applicant__c WHERE Opportunity__c = :oppRec.Id LIMIT 1];            
                RepaymentScreenController.createOtherDocument(System.Label.AadhaarCard,app.Id,oppRec.Id,repay.Id,'');  
            }
            Test.stopTest();            
        }
        catch(Exception e)
        {
            System.assert(e.getMessage().contains('Script-thrown exception'));
        }
    }
    
    @isTest 
    public static void updateLoanTransactionTest(){
        try
        {    
            Test.startTest(); 
            User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod03@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {
                Opportunity oppRec = [SELECT Id, Vehicle_Type__c, Product_Type__c FROM Opportunity WHERE Vehicle_Type__c = 'Used' LIMIT 1]; 
                oppRec.Product_Type__c = System.Label.Tractor;
                update oppRec;
                
                Deal_Number_Setting__c dlNumberSetting= new Deal_Number_Setting__c();
                dlNumberSetting.Name = System.Label.Tractor;
                dlNumberSetting.MDNField1__c ='AB';
                dlNumberSetting.MDNField2__c =2;
                insert dlNumberSetting;
                system.debug('Deal Setting'+ dlNumberSetting);
                
                Deal_Number__c dl = new Deal_Number__c();
                dl.Loan_Application__c = oppRec.Id;
                dl.DNField1__c = dlNumberSetting.MDNField1__c;
                dl.DNField2__c = String.valueOf(dlNumberSetting.MDNField2__c);
                dl.Sub_Stage__c = 'RC Upload';
                insert dl;
                
                RepaymentScreenController.updateLoanTransaction(oppRec.Id,'test',dl.Id); 
                
                Loan_Application_Transaction_History__c loanHistory = [SELECT Id, Name, Submitted_Flag__c FROM Loan_Application_Transaction_History__c WHERE Loan_Application_ID__c = :oppRec.Id LIMIT 1];
                System.assertNotEquals(null, loanHistory);
            }
            Test.stopTest();            
        }
        catch(Exception e)
        {
            system.debug('error '+ e.getMessage());
        }
    }
    
    @isTest 
    public static void updateLoanTransactionTest1(){
        try
        {    
            Test.startTest(); 
            User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod03@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {
                Opportunity oppRec = [SELECT Id, Vehicle_Type__c, Product_Type__c FROM Opportunity WHERE Vehicle_Type__c = 'Used' LIMIT 1];
                oppRec.Product_Type__c = System.Label.Tractor;
                update oppRec;
                
                Deal_Number_Setting__c dlNumberSetting= new Deal_Number_Setting__c();
                dlNumberSetting.Name = System.Label.Tractor;
                dlNumberSetting.MDNField1__c ='AB';
                dlNumberSetting.MDNField2__c =2;
                insert dlNumberSetting;
                system.debug('Deal Setting'+ dlNumberSetting);
                
                Deal_Number__c dl = new Deal_Number__c();
                dl.Loan_Application__c = oppRec.Id;
                dl.DNField1__c = dlNumberSetting.MDNField1__c;
                dl.DNField2__c = String.valueOf(dlNumberSetting.MDNField2__c);
                dl.Sub_Stage__c = 'RC Upload';
                insert dl;
                
                RepaymentScreenController.unsubmitLoanTransaction(oppRec.Id,'test',dl.Id); 
                
                Loan_Application_Transaction_History__c loanHistory = [SELECT Id, Name, Submitted_Flag__c FROM Loan_Application_Transaction_History__c WHERE Loan_Application_ID__c = :oppRec.Id LIMIT 1];
                System.assertNotEquals(null, loanHistory);
            }
            Test.stopTest();            
        }
        catch(Exception e)
        {
            system.debug('error '+ e.getMessage());
        }
    }
    
    @isTest
    public static void isCheckReadOnlyTest(){
        try{
            Test.startTest(); 
            User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod03@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {
                Opportunity oppRec = [SELECT Id,stageName FROM Opportunity LIMIT 1]; 	
                oppRec.StageName = 'Post Sanction Checks and Documentation';
                oppRec.Product_Type__c = System.Label.Tractor;
                update oppRec;
               
                Deal_Number_Setting__c dlNumberSetting= new Deal_Number_Setting__c();
                dlNumberSetting.Name = System.Label.Tractor;
                dlNumberSetting.MDNField1__c ='AB';
                dlNumberSetting.MDNField2__c =2;
                insert dlNumberSetting;
                system.debug('Deal Setting'+ dlNumberSetting);
                
                Deal_Number__c dl = new Deal_Number__c();
                dl.Loan_Application__c = oppRec.Id;
                dl.DNField1__c = dlNumberSetting.MDNField1__c;
                dl.DNField2__c = String.valueOf(dlNumberSetting.MDNField2__c);
                dl.Sub_Stage__c = 'RC Upload';
                insert dl;
                
                RepaymentScreenController.isCheckReadOnly(oppRec.Id,dl.Id);
                
                oppRec.StageName = 'Pre Disbursement Check';
                update oppRec;
                RepaymentScreenController.isCheckReadOnly(oppRec.Id,dl.Id);
            }
        }catch(Exception e){
            System.debug(e.getMessage());
        }
    }
    
    @isTest
    public static void documentRecordIdTest(){
        try{
            Test.startTest(); 
            User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod03@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {
                Opportunity oppRec = [SELECT Id, Vehicle_Type__c, Product_Type__c FROM Opportunity LIMIT 1]; 
                oppRec.Product_Type__c = System.Label.Tractor;
                update oppRec;
                
                Deal_Number_Setting__c dlNumberSetting= new Deal_Number_Setting__c();
                dlNumberSetting.Name = System.Label.Tractor;
                dlNumberSetting.MDNField1__c ='AB';
                dlNumberSetting.MDNField2__c =2;
                insert dlNumberSetting;
                system.debug('Deal Setting'+ dlNumberSetting);
                
                Deal_Number__c dl = new Deal_Number__c();
                dl.Loan_Application__c = oppRec.Id;
                dl.DNField1__c = dlNumberSetting.MDNField1__c;
                dl.DNField2__c = String.valueOf(dlNumberSetting.MDNField2__c);
                dl.Sub_Stage__c = 'RC Upload';
                insert dl;
                
                RepaymentScreenController.documentRecordId(oppRec.Id, 'ACH Mandate Form',dl.Id);
            }
             Test.stopTest(); 
        }catch(Exception e){
            System.debug(e.getMessage());
        }
    }
    @isTest
    public static void unsubmitLoanTransactionTest(){
        try{
            Test.startTest(); 
            User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod03@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {
                Opportunity oppRec = [SELECT Id, Vehicle_Type__c, Product_Type__c FROM Opportunity LIMIT 1]; 
                oppRec.Product_Type__c = System.Label.Tractor;
                update oppRec;
                
                Deal_Number_Setting__c dlNumberSetting= new Deal_Number_Setting__c();
                dlNumberSetting.Name = System.Label.Tractor;
                dlNumberSetting.MDNField1__c ='AB';
                dlNumberSetting.MDNField2__c =2;
                insert dlNumberSetting;
                system.debug('Deal Setting'+ dlNumberSetting);
                
                Deal_Number__c dl = new Deal_Number__c();
                dl.Loan_Application__c = oppRec.Id;
                dl.DNField1__c = dlNumberSetting.MDNField1__c;
                dl.DNField2__c = String.valueOf(dlNumberSetting.MDNField2__c);
                dl.Sub_Stage__c = 'RC Upload';
                insert dl;
                
                RepaymentScreenController.unsubmitLoanTransaction(oppRec.Id, 'Pre Disbursement Check',dl.Id);
            }
            Test.stopTest();
        }catch(Exception e){
            System.debug(e.getMessage());
        }
    }
    
    @isTest
    public static void displayRepaymentInfoTest2(){
        try{ 
            Opportunity opp = new Opportunity();
            opp.StageName = 'Qualification';
            opp.Vehicle_Type__c = System.Label.used;
            opp.Product_Type__c = System.Label.TwoWheeler;
            opp.Sanction_Status__c = System.Label.nonStp;
            insert opp;
            opp.Product_Type__c = System.Label.Tractor;
            update opp;
           
            Deal_Number_Setting__c dlNumberSetting= new Deal_Number_Setting__c();
            dlNumberSetting.Name = System.Label.Tractor;
            dlNumberSetting.MDNField1__c ='AB';
            dlNumberSetting.MDNField2__c =2;
            insert dlNumberSetting;
            system.debug('Deal Setting'+ dlNumberSetting);
            
            Deal_Number__c dl = new Deal_Number__c();
            dl.Loan_Application__c = opp.Id;
            dl.DNField1__c = dlNumberSetting.MDNField1__c;
            dl.DNField2__c = String.valueOf(dlNumberSetting.MDNField2__c);
            dl.Sub_Stage__c = 'RC Upload';
            insert dl;
            
            Repayments__c repayment = new Repayments__c();
            repayment.Loan_Application__c = opp.Id;
            repayment.Deal_Number__c = dl.Id;
            insert repayment;
            
            Test.startTest(); 
            RepaymentScreenController.displayRepaymentInfo(opp.Id,dl.Id);
            Test.stopTest();
            
        }catch(Exception e){
            System.debug(e.getMessage());
        }
    }
    
      @isTest
    public static void submitLoanTransactionTest(){
        try{ 
             User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod03@indusbank.com' AND IsActive = true LIMIT 1]; 
            system.runAs(u){
            Opportunity opp = new Opportunity();
            opp.StageName = 'Qualification';
            opp.Vehicle_Type__c = System.Label.used;
            opp.Product_Type__c = System.Label.Tractor;
            opp.Sanction_Status__c = System.Label.nonStp;
            insert opp;
            
            Deal_Number_Setting__c dlNumberSetting= new Deal_Number_Setting__c();
            dlNumberSetting.Name = System.Label.Tractor;
            dlNumberSetting.MDNField1__c ='AB';
            dlNumberSetting.MDNField2__c =2;
            insert dlNumberSetting;
            system.debug('Deal Setting'+ dlNumberSetting);
            
            Deal_Number__c dl = new Deal_Number__c();
            dl.Loan_Application__c = opp.Id;
            dl.DNField1__c = dlNumberSetting.MDNField1__c;
            dl.DNField2__c = String.valueOf(dlNumberSetting.MDNField2__c);
            dl.Sub_Stage__c = 'RC Upload';
            insert dl;
            
           Loan_Application_Transaction_History__c loanTranRec = new Loan_Application_Transaction_History__c();
           loanTranRec.Module__c  = 'Test Module';
           loanTranRec.Name = 'Repayment Mandate';
           loanTranRec.Screen__c = 'Repayment Mandate';
           loanTranRec.Deal_Number__c = dl.Id;
           loanTranRec.Loan_Application_ID__c = opp.Id;
           insert loanTranRec;
            
            Test.startTest(); 
            RepaymentScreenController.submitLoanTransaction(opp.Id,loanTranRec.Module__c,dl.Id);
            Test.stopTest();
            }
        }catch(Exception e){
            System.debug(e.getMessage());
        }
    }
}