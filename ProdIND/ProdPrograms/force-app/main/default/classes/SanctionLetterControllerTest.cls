@isTest
public class SanctionLetterControllerTest {
 
    
    // @testSetup
    // static void setupTestData() {
    //     Account accobj = new Account();
    //     accobj.Name = 'testname';
    //     accobj.State__c = 'ASSAM';
    //     accobj.BranchBLCode__c='909';
    //     accobj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business Account').getRecordTypeId();
    //     insert accobj;
        
    //     Account accobj1 = new Account();
    //     accobj1.Name = 'testname';
    //     accobj1.State__c = 'ASSAM';
    //     accobj1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business Account').getRecordTypeId();
    //     insert accobj1;
        
    //     Opportunity oppObj = new Opportunity();
    //     oppObj.Name = 'Test Opportunity';
    //     oppObj.StageName = 'Prospecting';
    //     oppObj.CloseDate = Date.today().addMonths(1);
    //     oppObj.Lead_number__c = '12345'; 
    //     insert oppObj;
        
    //     Opportunity oppObj1 = new Opportunity();
    //     oppObj1.Name = 'Test Opportunity';
    //     oppObj1.StageName = 'Prospecting';
    //     oppObj1.CloseDate = Date.today().addMonths(1);
    //     insert oppObj1;
        
                    /*
            Opportunity opp1 = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Prospecting',
            CloseDate = Date.today()
            );
            insert opp1;

            // Create a test Vehicle_Detail__c
            Vehicle_Detail__c vehicle1 = new Vehicle_Detail__c(
            Loan_Application__c = opp1.Id
            );
            insert vehicle1;

            Applicant__c applicant11 = new Applicant__c(
            Name = 'Test Applicant',
            Applicant_Type__c = 'Borrower',
            Opportunity__c = oppObj.Id,
            Contact_number__c = '12345',
            Whatsapp_number__c = '12345',
            OTP_for_borrower__c = '12345',
            Application_Consent_OTP__c = '65432',
            CASA_Consent_OTP__c = '78901'
            );
            insert applicant11;

            */
                    
                    
                    /*
            // Create a mock Integration_Configuration__mdt
            Integration_Configuration__mdt integrationConfig = new Integration_Configuration__mdt(
            MasterLabel = 'SMSGateway',
            Timeout__c = '12000',
            IsStub_Required__c = false,
            IsActive_Integration__c = true
            );
            insert integrationConfig;
            */
        
        
        
        // ContentVersion testContentVersion = new ContentVersion(
        //     Title = 'Test Document',
        //     PathOnClient = 'TestDocument.txt',
        //     VersionData = Blob.valueOf('Test Document Content'),
        //     FirstPublishLocationId = oppObj.Id
        // );
        // insert testContentVersion;
        
        // Applicant__c applicant = new Applicant__c();
        // applicant.Sanction_Consent_OTP__c = '123';
        // applicant.Applicant_Type__c = 'Borrower';
        // applicant.Sanction_Consent_Need_Clarification__c = false;
        // applicant.Sanction_Consent_NeedClarification_Count__c = 0;
        // applicant.Sanction_Consent_OTP__c = '12345';
        // applicant.Sanction_Form_SMS_Sent__c = DateTime.now().addDays(-4);
        // applicant.Opportunity__c = oppObj.Id;
        // applicant.Application_Form_SMS_Sent__c = System.now();
        // applicant.Application_Consent_Received__c = true;
        // applicant.Sanction_Consent_Accepted__c = false;
        // insert applicant;
        
        // Applicant__c applicant1 = new Applicant__c();
        // applicant1.Sanction_Consent_OTP__c = '321';
        // applicant1.Sanction_Form_SMS_Sent__c = DateTime.now().addMinutes(-100);
        // applicant1.Opportunity__c = oppObj1.Id;
        // applicant1.Application_Form_SMS_Sent__c = System.now();
        // applicant1.Application_Consent_Received__c = true;
        // insert applicant1;
        
        // Applicant__c applicant3 = new Applicant__c(
        //     Applicant_Type__c = 'Borrower', 
        //     Opportunity__c = oppObj.Id, 
        //     Sanction_Consent_OTP__c = '12345', 
        //     Sanction_Consent_Accepted__c = false, 
        //     Sanction_Form_SMS_Sent__c = null
        // );
        // insert applicant3;
        
        // Applicant__c applicant4 = new Applicant__c(
        //     Name = 'Test Applicant',
        //     Applicant_Type__c = 'Borrower',
        //     Opportunity__c = oppObj.Id,
        //     Sanction_Consent_Not_Accepted__c = false,
        //     Sanction_Form_SMS_Sent__c = null,
        //     Sanction_Consent_OTP__c = '12345'
        // );
        // insert applicant4;
        
        // Vehicle_Detail__c vehicleDetail1 = new Vehicle_Detail__c(
        //     Loan_Application__c = oppObj.Id,
        //     Vehicle_Type__c = 'Sedan'
        // );
        // insert vehicleDetail1;
        
        
        // Income_Details__c incomedetails = new Income_Details__c(Applicant__c =applicant.id, Perfios_Transaction_Id__c = '04022022111044173');
        // insert incomedetails;
        
    //     Income_Details__c incomedetails1 = new Income_Details__c(Applicant__c =applicant1.id, Perfios_Transaction_Id__c = '04022022111044173');
    //     insert incomedetails1;
        
    //     Final_Term__c finalTerm = new Final_Term__c();
    //     finalTerm.Loan_Application__c = oppObj.Id;
    //     finalTerm.Tenure__c = '36';
    //     finalTerm.Service_charges__c = '500';
    //     finalTerm.Documentation_charges__c = '200';
    //     finalTerm.Stamping_charges__c = '50';
    //     finalTerm.Verification_charges__c = '100';
    //     finalTerm.Advance_EMI__c = false;
    //     finalTerm.Calculated_Gross_LTV__c = 85;
    //     finalTerm.Required_CRM_IRR__c = '6.5';
    //     finalTerm.Loan_Amount__c = '1000';
    //     finalTerm.First_EMI_Date__c = Date.today().addMonths(2);
    //     finalTerm.Holiday_period__c = '30';
    //     finalTerm.Installment_Type__c = 'Equated';
    //     finalTerm.Gross_IRR__c = 7.5;
    //     insert finalTerm;
        
    //     Final_Term__c finalTerm1 = new Final_Term__c();
    //     finalTerm1.Loan_Application__c = oppObj1.Id;
    //     finalTerm1.Tenure__c = '36';
    //     finalTerm1.Service_charges__c = '500';
    //     finalTerm1.Documentation_charges__c = '200';
    //     finalTerm1.Stamping_charges__c = '50';
    //     finalTerm1.Verification_charges__c = '100';
    //     finalTerm1.Advance_EMI__c = false;
    //     finalTerm1.Calculated_Gross_LTV__c = 85;
    //     finalTerm1.Required_CRM_IRR__c = '6.5';
    //     finalTerm1.Loan_Amount__c = '1000';
    //     finalTerm1.First_EMI_Date__c = Date.today().addMonths(2);
    //     finalTerm1.Holiday_period__c = '30';
    //     finalTerm1.Installment_Type__c = 'Equated';
    //     finalTerm1.Gross_IRR__c = 7.5;
    //     insert finalTerm1;
        
    //     Documents__c permanentDoc = new Documents__c();
    //     permanentDoc.Name = 'Permanent Address Document';
    //     permanentDoc.Applicant__c = applicant.Id;
    //     permanentDoc.Opportunity_Relation__c = oppObj.Id;
    //     permanentDoc.Addresss_Type__c = 'Permanent Residential Address';
    //     permanentDoc.Vehicle_Detail__c = vehicleDetail1.Id;
    //     permanentDoc.Document_Type__c = 'PAN';
    //     permanentDoc.is_Active__c = true;
    //     insert permanentDoc;
        
    //     Documents__c currentDoc = new Documents__c();
    //     currentDoc.Name = 'Current Address Document';
    //     currentDoc.Applicant__c = applicant1.Id;
    //     currentDoc.Opportunity_Relation__c = oppObj1.Id;
    //     currentDoc.Addresss_Type__c = 'Current Residential Address';
    //     insert currentDoc; 
    //     // Step 1: Create test data
    // Key_Fact_Statement__c keyFact = new Key_Fact_Statement__c(Keyfact_Form_SMS_Sent__c = system.today(), Entity_Type__c = 'Type1');
    // insert keyFact;

    // KFS_Applicant__c applicant5 = new KFS_Applicant__c(Key_Fact_Statement__c = keyFact.Id, Customer_Name__c = 'John Doe');
    // insert applicant5;

    // KFS_Instalment_Schedule__c instalment = new KFS_Instalment_Schedule__c(Key_Fact_Statement__c = keyFact.Id, EMI_Amount__c = 5000);
    // insert instalment;

    // // Step 2: Invoke the method that contains the queries (replace with your actual method)
    // // Example: YourClass.methodThatUsesQueries(keyFact.Id);

    // // Step 3: Assert results
    // List<Key_Fact_Statement__c> retrievedKeyFacts = [SELECT Id, Keyfact_Form_SMS_Sent__c FROM Key_Fact_Statement__c WHERE Id = :keyFact.Id];
    // System.assertEquals(1, retrievedKeyFacts.size(), 'Should return one Key Fact Statement.');

    // List<KFS_Applicant__c> retrievedApplicants = [SELECT Id FROM KFS_Applicant__c WHERE Key_Fact_Statement__c = :keyFact.Id];
    // System.assertEquals(1, retrievedApplicants.size(), 'Should return one applicant.');

    // List<KFS_Instalment_Schedule__c> retrievedInstalments = [SELECT Id FROM KFS_Instalment_Schedule__c WHERE Key_Fact_Statement__c = :keyFact.Id];
    // System.assertEquals(1, retrievedInstalments.size(), 'Should return one instalment.');
    
    // }
    
    
    
    /*@isTest
    static void createTestAcceptandRenderFalse() {
        
        Opportunity opp = new Opportunity(
            StageName = 'Credit Processing',
            CloseDate = Date.newInstance(2021, 1, 11),
            Name = 'Test Opportunity',
            Product_Type__c = 'Tractor' 
        );
        insert opp;
        
        Applicant__c applObj = new Applicant__c(
            Applicant_Type__c = 'Borrower',
            Opportunity__c = opp.Id,
            Sanction_Consent_Accepted__c = false,
            Sanction_Form_SMS_Sent__c = system.today(),
            Sanction_Consent_OTP__c = '12345' 
        );
        insert applObj;
    }
    
    @isTest
    static void testAcceptandRenderFalse() {
        Applicant__c applObj = [SELECT Id, Sanction_Form_SMS_Sent__c, Sanction_Consent_OTP__c, Sanction_Consent_Accepted__c FROM Applicant__c WHERE Applicant_Type__c = 'Borrower' LIMIT 1];
        Test.setCurrentPageReference(new PageReference('/apex/IND_SanctionFormRenderPage?id=' + applObj.Id + '&connum=' + applObj.Sanction_Consent_OTP__c));
        SanctionLetterController controller = new SanctionLetterController();
        controller.currentRecordId = applObj.Id;
        
        Test.startTest();
        createTestAcceptandRenderFalse();
        PageReference result = controller.acceptandRender();
        Test.stopTest();
        
        System.assertEquals(false, applObj.Sanction_Consent_Accepted__c, 'Sanction Consent not updated correctly');
        System.assertNotEquals(system.today(), applObj.Sanction_Form_SMS_Sent__c, 'Sanction Form SMS Sent not updated correctly');
    }
    
    
    /*@isTest
    static void createTestNotAcceptandRenderFalse() {
        
        Opportunity opp = new Opportunity(
            StageName = 'Credit Processing',
            CloseDate = Date.newInstance(2021, 1, 11),
            Name = 'Test Opportunity',
            Product_Type__c = 'Tractor' 
        );
        insert opp;
        
        Applicant__c applObj = new Applicant__c(
            Applicant_Type__c = 'Borrower',
            Opportunity__c = opp.Id,
            Sanction_Consent_Not_Accepted__c = false,
            Sanction_Form_SMS_Sent__c = system.today(),
            Sanction_Consent_OTP__c = '12345' 
        );
        insert applObj;
    }*/
    
   /* @isTest
    static void testNotAcceptandRenderFalse() {
        Applicant__c applObj = [SELECT Id, Sanction_Form_SMS_Sent__c, Sanction_Consent_OTP__c, Sanction_Consent_Not_Accepted__c FROM Applicant__c WHERE Applicant_Type__c = 'Borrower' LIMIT 1];
        Test.setCurrentPageReference(new PageReference('/apex/IND_SanctionFormRenderPage?id=' + applObj.Id + '&connum=' + applObj.Sanction_Consent_OTP__c));
        SanctionLetterController controller = new SanctionLetterController();
        controller.currentRecordId = applObj.Id;
        
        Test.startTest();
        createTestNotAcceptandRenderFalse();
        PageReference result = controller.notAcceptandRender();
        Test.stopTest();
        
        System.assertEquals(false, applObj.Sanction_Consent_Not_Accepted__c, 'Sanction Consent not updated correctly');
        System.assertNotEquals(system.today(), applObj.Sanction_Form_SMS_Sent__c, 'Sanction Form SMS Sent not updated correctly');
    }
    
    @isTest
    static void testInterestCalculation() {
        
        Opportunity opp = new Opportunity(
            StageName = 'Credit Processing',
            CloseDate = Date.newInstance(2021, 1, 11),
            Name = 'Test Opportunity',
            Product_Type__c = 'Tractor' 
        );
        insert opp;
        
        Final_Term__c finalTerm = new Final_Term__c(
            CRM_IRR__c = 12.0, 
            Loan_Application__c = opp.Id,
            Holiday_period__c = '30',
            EMI_Amount__c = 1000.0, 
            Tenure__c = '12', 
            Loan_Amount__c = '10000' 
        );
        insert finalTerm;
        
        Test.startTest();
        Decimal noOFInstal = Decimal.valueOf(finalTerm.Holiday_period__c) == 30 ? Decimal.valueOf(finalTerm.Tenure__c) - 1 : Decimal.valueOf(finalTerm.Holiday_period__c) == 0 ? Decimal.valueOf(finalTerm.Tenure__c) : 0;
        Decimal loanamountforCal = Decimal.valueOf(finalTerm.Loan_Amount__c);
        Decimal amountofEmi = finalTerm.EMI_Amount__c;
        Decimal totalIntrestAmount = (noOFInstal * amountofEmi) - loanamountforCal;
        System.assertEquals(1000.0, totalIntrestAmount, 'Total interest amount calculation is incorrect');
        Test.stopTest();
    }
    
    @isTest
    static void testGetDateTimeFormat() {
        
        DateTime dt = DateTime.now();
        Test.startTest();
        String formattedDateTime = SanctionLetterController.getDateTimeFormat(dt);
        Test.stopTest();
        
        String expectedFormat = String.valueOf(dt.day()).leftPad(2, '0') + '/' +
            String.valueOf(dt.month()).leftPad(2, '0') + '/' +
            String.valueOf(dt.year()) + ' ' +
            String.valueOf(dt.hour()).leftPad(2, '0') + ':' +
            String.valueOf(dt.minute()).leftPad(2, '0') + ':' +
            String.valueOf(dt.second()).leftPad(2, '0');
        
        System.assertEquals(expectedFormat, formattedDateTime, 'Formatted date-time should match expected format');
    }
    
    
    @isTest
    static void testNeedClarificationRender() {
        Applicant__c testApplicant = [SELECT Id FROM Applicant__c LIMIT 1];
        
        Test.setCurrentPage(ApexPages.currentPage()); 
        ApexPages.currentPage().getParameters().put('id', testApplicant.Id);
        
        SanctionLetterController controller = new SanctionLetterController();
        
        Test.startTest();
        PageReference result = controller.needClarificationRender();
        Test.stopTest();
        
        Applicant__c updatedApplicant = [SELECT Sanction_Consent_Need_Clarification__c, 
                                         Sanction_Form_SMS_Sent__c, 
                                         Sanction_Consent_NeedClarification_Count__c 
                                         FROM Applicant__c 
                                         WHERE Id = :testApplicant.Id];
        
        System.assertEquals(true, updatedApplicant.Sanction_Consent_Need_Clarification__c);
        System.assertNotEquals(null, updatedApplicant.Sanction_Form_SMS_Sent__c);
        System.assertEquals(1, updatedApplicant.Sanction_Consent_NeedClarification_Count__c);
        System.assertEquals(null, result, 'Page reference should be null');
    }
    
    
    @isTest
    static void testCreateApplicationFormPdf() {
        List<ContentVersion> testContentVersions = [SELECT ContentDocumentId,Title FROM ContentVersion WHERE Title = 'Test Document' LIMIT 1];
        List<Opportunity> testOpps = [SELECT Id,Name FROM Opportunity WHERE Name = 'Test Opportunity' LIMIT 1];
        Documents__c doc = [SELECT Id FROM Documents__c WHERE Name='Current Address Document' LIMIT 1];
        System.assert(!testContentVersions.isEmpty(), 'Test ContentVersion should be created');
        System.assert(!testOpps.isEmpty(), 'Test Opportunity should be created');
        
        ContentVersion testContentVersion = testContentVersions[0];
        Opportunity testOpp = testOpps[0];
        
        Test.startTest();
        SanctionLetterController.createApplicationFormPdf(doc.Id, 'Test Label', testOpp.Id);
        Test.stopTest();
        
        List<ContentDocumentLink> contentDocLinks = [SELECT Id, ContentDocumentId,LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId = :testOpp.Id];
        System.assert(!contentDocLinks.isEmpty(), 'ContentDocument should be created and linked to the Opportunity');
        
        ContentDocument contentDoc = [SELECT Id, Title, FileType FROM ContentDocument WHERE Id = :contentDocLinks[0].ContentDocumentId];
        
    }
    /*
    @isTest
    static void testLinkExpiredTrue() {
        List<Applicant__c> applicants = [SELECT Id FROM Applicant__c WHERE Sanction_Consent_OTP__c = '123' LIMIT 1];
        if (!applicants.isEmpty()) {
            Test.startTest();
            
            PageReference pageRef = ApexPages.CurrentPage(); 
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id', applicants[0].Id);
            ApexPages.currentPage().getParameters().put('connum', '123');
            
            SanctionLetterController controller = new SanctionLetterController(); 
            //Boolean result = controller.getlinkExpired();
            
            System.assertEquals(true, result, 'Expected the link to be expired');
            Test.stopTest();
        }
    }
    
    @isTest
    static void testLinkExpiredFalse() {
        
        List<Applicant__c> applicants = [SELECT Id FROM Applicant__c WHERE Sanction_Consent_OTP__c = '321' LIMIT 1];
        if (!applicants.isEmpty()) {
            Test.startTest();
            
            PageReference pageRef = ApexPages.CurrentPage(); 
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id', applicants[0].Id);
            ApexPages.currentPage().getParameters().put('connum', '321');
            
            SanctionLetterController controller = new SanctionLetterController(); 
            //Boolean result = controller.getlinkExpired();
            
            System.assertEquals(false, result, 'Expected the link to be valid');
            Test.stopTest();
        }
    }
    
    @isTest
    static void testLinkExpiredFalseNewLink() {
        List<Applicant__c> applicants = [SELECT Id FROM Applicant__c WHERE Sanction_Consent_OTP__c = '321' LIMIT 1];
        if (!applicants.isEmpty()) {
            Test.startTest();
            
            PageReference pageRef =ApexPages.CurrentPage(); 
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id', applicants[0].Id);
            ApexPages.currentPage().getParameters().put('connum', '321');
            
            SanctionLetterController controller = new SanctionLetterController(); 
            //Boolean result = controller.getlinkExpired();
            
            System.assertEquals(false, result, 'Expected the link to be invalid due to mismatched OTP');
            Test.stopTest();
        }
    }
    
    @isTest
    static void testLinkExpiredNullSentDate() {
        List<Applicant__c> applicants = [SELECT Id FROM Applicant__c WHERE Sanction_Consent_OTP__c = '111' LIMIT 1];
        if (!applicants.isEmpty()) {
            Applicant__c nullDateApplicant = new Applicant__c(
                Sanction_Consent_OTP__c = '111'
            );
            insert nullDateApplicant;
            
            Test.startTest();
            
            PageReference pageRef = ApexPages.CurrentPage(); 
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id', applicants[0].Id);
            ApexPages.currentPage().getParameters().put('connum', '111');
            
            SanctionLetterController controller = new SanctionLetterController(); 
            //Boolean result = controller.getlinkExpired();
            
            System.assertEquals(false, result, 'Expected the link to be valid as sent date is null');
            Test.stopTest();
        }
    }*/
    /*@isTest
    static void testMaskOddCharacters() {
        
        String input = 'Test';
        
        Test.startTest();
        String maskedString = SanctionLetterController.maskOddCharacters(input);
        Test.stopTest();
        
        System.assertNotEquals(null, maskedString, 'Masked string should not be null');
        System.assertEquals('T*s*', maskedString, 'Masked string should have odd characters replaced with *');
    }*/
    
    /*@isTest 
    public static void renderasPdfcontrollerTest12()
    {
        Opportunity opfv1 = new Opportunity();
        opfv1.StageName = 'Credit Processing';
        opfv1.CloseDate = Date.newInstance(2021, 1, 11);
        opfv1.Name = 'testone';
        opfv1.Product_Type__c = System.Label.Tractor;
        insert opfv1;
        
        Applicant__c applicantBorrower = new Applicant__c();
        applicantBorrower.Opportunity__c = opfv1.Id;
        applicantBorrower.Sanction_Consent_Accepted__c=false;
        applicantBorrower.Contact_number__c = '9743514830';
        applicantBorrower.Applicant_Type__c = 'Borrower';
        applicantBorrower.Whatsapp_number__c = '292029';
        applicantBorrower.Who_will_repay_the_loan__c = 'Borrower';
        applicantBorrower.Application_Consent_Received__c = true;
        insert applicantBorrower;
        
        Applicant__c applicantCoBorrower = new Applicant__c();
        applicantCoBorrower.Opportunity__c = opfv1.Id;
        applicantCoBorrower.Contact_number__c = '9743000830';
        applicantCoBorrower.Applicant_Type__c = 'Coborrower';
        applicantCoBorrower.Who_will_repay_the_loan__c = 'Coborrower';
        applicantCoBorrower.Application_Consent_Received__c = false;
        insert applicantCoBorrower;
        
        List<Documents__c> dcList = new List<Documents__c>();
        Documents__c dfks1 = new Documents__c();
        dfks1.Applicant__c = applicantBorrower.Id;
        dfks1.Opportunity_Relation__c = opfv1.Id;
        dfks1.PAN_No__c = '';
        dfks1.KYC_No__c = '';
        
        dfks1.KYC_City__c = 'Nellore';
        dfks1.KYC_State__c = 'Nellore';
        dfks1.Current_Residential_Address_Proof__c=false;
        dfks1.KYC_name__c = 'Aadhar';
        dfks1.Document_Side__c ='Back';
        dfks1.Aadhar_Source__c = 'ScanAadhar';
        dfks1.Name = 'Aadhar';
        dfks1.Document_Type__c = 'PAN';
        dfks1.Current_Residential_Address_Proof__c = true;
        dfks1.Passport_No__c = 'A22570';
        dfks1.KYC_District__c = 'Nellore';
        insert dfks1;
        dcList.add(dfks1);
        
        
        //   Applicant__c applicant =[select id,name,Application_Form_SMS_Sent__c from Applicant__c];
        applicantBorrower.Application_Form_SMS_Sent__c = datetime.newInstance(2014, 9, 15, 12, 30, 0);
        update applicantBorrower;
        
        List<Applicant__c> apList = new List<Applicant__c>();
        apList.add(applicantBorrower);
        
        PageReference testPage = Page.Ind_ApplicationForm; 
        Test.setCurrentPage(testPage);
        testPage.getParameters().put('Id', String.valueOf(applicantBorrower.Id));
        
        Vehicle_Detail__c vehicleDetail = new Vehicle_Detail__c();
        vehicleDetail.Loan_Application__c = opfv1.Id;
        vehicleDetail.Can_we_continue_with_above_RC_limit__c = true;
        insert vehicleDetail;
        
        Final_Term__c ftv1 = new Final_Term__c();
        ftv1.CRM_IRR__c = 120;
        ftv1.Loan_Application__c = opfv1.Id;
        ftv1.Holiday_period__c='30';
        ftv1.EMI_Amount__c= 10000;
        ftv1.Tenure__c = '12'; 
        ftv1.Loan_Amount__c = '10000'; 
        insert ftv1;
        
        Final_Term__c ftv11 = new Final_Term__c();
        ftv11.CRM_IRR__c = 120;
        ftv11.Loan_Application__c = opfv1.Id;
        ftv11.Holiday_period__c=Null;
        ftv11.EMI_Amount__c= Null;
        insert ftv11;
        
        Test.StartTest();
        ApexPages.StandardController sc = new  ApexPages.StandardController(applicantBorrower);   
        try{
            SanctionLetterController ext = new SanctionLetterController();
            
        }catch(Exception e){
            System.debug('e '+e.getMessage());
        }
        Test.StopTest();
    } */
    
     @isTest
    static void testGetDateTimeFormat() {
        // Test case 1: Standard date
        DateTime testDateTime1 = DateTime.newInstance(2024, 9, 30, 15, 30, 0);
        String expectedFormat1 = '30/09/2024 15:30:00'; // Expected output
        String result1 = SanctionLetterController.getDateTimeFormat(testDateTime1);
        System.assertEquals(expectedFormat1, result1, 'The formatted date time does not match the expected value.');

        // Test case 2: Date with single digit day and month
        DateTime testDateTime2 = DateTime.newInstance(2024, 1, 5, 8, 5, 0);
        String expectedFormat2 = '05/01/2024 08:05:00'; // Expected output
        String result2 = SanctionLetterController.getDateTimeFormat(testDateTime2);
        System.assertEquals(expectedFormat2, result2, 'The formatted date time does not match the expected value.');

        // Test case 3: Leap year date
        DateTime testDateTime3 = DateTime.newInstance(2020, 2, 29, 12, 0, 0);
        String expectedFormat3 = '29/02/2020 12:00:00'; // Expected output
        String result3 = SanctionLetterController.getDateTimeFormat(testDateTime3);
        System.assertEquals(expectedFormat3, result3, 'The formatted date time does not match the expected value.');

        // Test case 4: End of the month
        DateTime testDateTime4 = DateTime.newInstance(2024, 4, 30, 23, 59, 59);
        String expectedFormat4 = '30/04/2024 23:59:59'; // Expected output
        String result4 = SanctionLetterController.getDateTimeFormat(testDateTime4);
        System.assertEquals(expectedFormat4, result4, 'The formatted date time does not match the expected value.');

        // Test case 5: Midnight time
        DateTime testDateTime5 = DateTime.newInstance(2024, 5, 1, 0, 0, 0);
        String expectedFormat5 = '01/05/2024 00:00:00'; // Expected output
        String result5 = SanctionLetterController.getDateTimeFormat(testDateTime5);
        System.assertEquals(expectedFormat5, result5, 'The formatted date time does not match the expected value.');

        // Test case 6: Year with four digits
        DateTime testDateTime6 = DateTime.newInstance(1999, 12, 31, 23, 59, 59);
        String expectedFormat6 = '31/12/1999 23:59:59'; // Expected output
        String result6 = SanctionLetterController.getDateTimeFormat(testDateTime6);
        System.assertEquals(expectedFormat6, result6, 'The formatted date time does not match the expected value.');
    }



    @isTest

    static void testMaskOddCharacters1() {
        Map<String, String> testCases = new Map<String, String>{
            'abcdef'       => 'a*c*e*', // b -> *, d -> *, f is masked (if there's a mask at the end)
            'abcde'        => 'a*c*e',  // b -> *, d -> *, e is not masked
            'a!b@c#d$e%'   => 'a*b*c*d*e*' // b -> *, d -> *, % is masked (if there's a mask at the end)
        };
        
        for (String input : testCases.keySet()) {
            String expected = testCases.get(input);
            String actual = SanctionLetterController.maskOddCharacters(input);
            System.assertEquals(expected, actual, 'For input: ' + input);
        }
    

    }
    

   // @isTest
    //static void testCreateApplicationFormPdf() {
       
        // Define test data
        //String docId = '67767';  // Use the inserted Document__c ID
        //String label = 'TestLabel';
       // String oppId = '454553';  // Use the inserted Opportunity ID

        // Start test context
       // Test.startTest();
        
        // Call the method being tested
       
           // SanctionLetterController.createApplicationFormPdf(docId, label, oppId);
       

        // End test context
        //Test.stopTest();

        // Verify no exceptions were thrown and that the method ran successfully
       // System.assert(true, 'Test completed successfully without exceptions');
   // }
   
   @isTest
   static void SanctionLetterControllerTest() {
       // Setup test data
       Key_Fact_Statement__c kfs = new Key_Fact_Statement__c(
           Deal_Number__c = 'TestDeal123',
           Keyfact_Consent_Accepted__c = true,
           Type_Of_Instalments__c = 'M',
           Total_Interest_Amount__c = 10000,
           Vehicle_Sub_Category__c = 'New',
           Keyfact_Form_SMS_Sent__c= date.today()
       );
       insert kfs;
       Key_Fact_Statement__c kfs1 = new Key_Fact_Statement__c(
           Deal_Number__c = 'TestDeal123',
           Keyfact_Consent_Accepted__c = true,
           Type_Of_Instalments__c = 'M',
           Total_Interest_Amount__c = 10000,
           Vehicle_Sub_Category__c = 'New',
           Key_Fact_Statement__c = kfs.Id,
           Keyfact_Form_SMS_Sent__c = date.today()
       );
       insert kfs1;

       KFS_Applicant__c applicant6 = new KFS_Applicant__c(
           Customer_Name__c = 'John',
           SurName__c = 'Doe',
           Customer_Code__c = 'C123',
           Mobile_Number__c = '1234567890',
           PAN_GIR_Number__c = 'ABCDE1234F',
           Date_of_Birth__c = '25-09-1996',
           Key_Fact_Statement__c = kfs1.Id,
           Applicant_Type__c='Borrower',
           UCIC__c='123',
           CKYC_ID__c='123',
           Office_Address_Flag__c='O',
           Office_Address_Line_1__c='address1',
           Office_Address_Line_2__c='address2',
           Office_Address_Line_3__c='address3',
           Office_Address_Line_4__c='address4',
           Office_City__c='city',
           Office_Pin_code__c='600125',
           Office_State__c='State',
           Office_District__c='District'
           
       );
       insert applicant6;
       KFS_Instalment_Schedule__c kfsInstal = new KFS_Instalment_Schedule__c(
        Balance__c = 123213,
        Interest__c = 240,
        Principal__c = 2780,
        Key_Fact_Statement__c = kfs1.Id,
           EMI_Amount__c = 10
       );
       insert kfsInstal;

       // Setup the controller with the test data
       Test.startTest();
       ApexPages.currentPage().getParameters().put('id', String.valueOf(kfs.Id));
    //    PageReference pageRef = new PageReference('/apex/SanctionLetter'); // Adjust to your page reference
    //    pageRef.getParameters().put('id', kfs.Id);
       
       SanctionLetterController controller = new SanctionLetterController();
    //    controller.currentRecordId = kfs.Id;
    //    controller.currentResDocument = applicant6;
    //    controller.keyFactDealList = new List<Key_Fact_Statement__c> { kfs };
    //    controller.keyFactApplicantList = new List<KFS_Applicant__c> { applicant6 };

       // Execute any methods that need to be tested
    //    SanctionLetterController.SanctionLetterController(); // Replace with actual method calls

       
       Test.stopTest();
   }
 @isTest
   static void SanctionLetterControllerTest1() {
       // Setup test data
       Key_Fact_Statement__c kfs = new Key_Fact_Statement__c(
           Deal_Number__c = 'TestDeal123',
           Keyfact_Consent_Accepted__c = true,
           Type_Of_Instalments__c = 'M',
           Total_Interest_Amount__c = 10000,
           Vehicle_Sub_Category__c = 'New',
           Keyfact_Form_SMS_Sent__c= date.today()
       );
       insert kfs;
       Key_Fact_Statement__c kfs1 = new Key_Fact_Statement__c(
           Deal_Number__c = 'TestDeal123',
           Keyfact_Consent_Accepted__c = true,
           Type_Of_Instalments__c = 'M',
           Total_Interest_Amount__c = 10000,
           Vehicle_Sub_Category__c = 'New',
           Key_Fact_Statement__c = kfs.Id,
           Keyfact_Form_SMS_Sent__c = date.today()
       );
       insert kfs1;

       KFS_Applicant__c applicant6 = new KFS_Applicant__c(
           Customer_Name__c = 'John',
           SurName__c = 'Doe',
           Customer_Code__c = 'C123',
           Mobile_Number__c = '1234567890',
           PAN_GIR_Number__c = 'ABCDE1234F',
           Date_of_Birth__c = '25-09-1996',
           Key_Fact_Statement__c = kfs1.Id,
           Applicant_Type__c='Co-borrower',
           UCIC__c='123',
           CKYC_ID__c='123',
           Office_Address_Flag__c='O',
           Office_Address_Line_1__c='address1',
           Office_Address_Line_2__c='address2',
           Office_Address_Line_3__c='address3',
           Office_Address_Line_4__c='address4',
           Office_City__c='city',
           Office_Pin_code__c='600125',
           Office_State__c='State',
           Office_District__c='District'
           
       );
       insert applicant6;
       KFS_Instalment_Schedule__c kfsInstal = new KFS_Instalment_Schedule__c(
        Balance__c = 123213,
        Interest__c = 240,
        Principal__c = 2780,
        Key_Fact_Statement__c = kfs1.Id,
           EMI_Amount__c = 10
       );
       insert kfsInstal;

       // Setup the controller with the test data
       Test.startTest();
       ApexPages.currentPage().getParameters().put('id', String.valueOf(kfs.Id));
    //    PageReference pageRef = new PageReference('/apex/SanctionLetter'); // Adjust to your page reference
    //    pageRef.getParameters().put('id', kfs.Id);
       
       SanctionLetterController controller = new SanctionLetterController();
    //    controller.currentRecordId = kfs.Id;
    //    controller.currentResDocument = applicant6;
    //    controller.keyFactDealList = new List<Key_Fact_Statement__c> { kfs };
    //    controller.keyFactApplicantList = new List<KFS_Applicant__c> { applicant6 };

       // Execute any methods that need to be tested
    //    SanctionLetterController.SanctionLetterController(); // Replace with actual method calls

       
       Test.stopTest();
   }

}