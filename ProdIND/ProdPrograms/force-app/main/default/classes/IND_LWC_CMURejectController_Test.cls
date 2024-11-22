@isTest
public class IND_LWC_CMURejectController_Test {
    @testSetup static void setup() {
        Test.startTest();
        Account testAccount = new Account(Name='Test Account');
        insert testAccount;
        Opportunity opp = new Opportunity( Name= 'Opportunity',
                                          StageName='Qualification',
                                          CloseDate=System.today().addMonths(1),
                                          AccountId= testAccount.Id,
                                          OTP_for_borrower__c='99999',
                                          Applicant_Name__c='ayu',
                                          Mfr_Expence_Reimburse__c=32, 
                                          Mfr_Expence_Reimburse_Amt__c='6700'
                                          ,Mfr_Expence_Reimburse_Type__c='yhh' ,
                                          Mfr_Incentive__c=98,
                                          Main_Dealer_Incentive_Amount__c=76,
                                          Sub_Dealer_Ancentive_Amount__c=8798,
                                          DSM_Incentive1__c=767,
                                          DSM_Incentive2__c=65 ,DSM_Name1__c='bhgb' ,
                                          DSM_Name2__c='hhg', Dealer_Disc_to_Customer__c='878',
                                          Dealer_Expence_Reimburse_Type__c='hgfh',
                                          Gift_through_Dealer_Amount__c='866', Required_Tenure__c=7,
                                          Non_Dealer_DSM_Name1__c='jhfgh',
                                          Non_Dealer_DSM_Name2__c='jhhf',
                                          Non_Dealer_DSM_Incentive1__c=776, Non_Dealer_DSM_Incentive2__c=766,
                                          Required_ROI__c=5, Service_Charges__c='76', Parent_Deal_number__c='7878',
                                          Documentation_Charges__c='98', Stamping_Charges__c='87', Loan_amount__c='76777',
                                          Contact_number__c = '415.555.1212',Front_Upload_Attempts__c=0,Back_Upload_Attempts__c=0,Selfie_Retry_Attempts__c=2);
        insert opp; 
        
        
        //Applicant object for testing.
        Applicant__c applicant = new Applicant__c(Name='Applicant1',Contact_Number__c ='1234567891',Opportunity__c = opp.Id,
                                                  Whatsapp_number__c='1231231231',Income_Ca__c='SAL',
                                                  Profile__c = 'Software Engineer', Bureau_Pull_Attempts__c=1,
                                                  Income_Source__c='Non-Earning',Mother_s_name__c = 'Mother Name',Father_s_name__c = 'Father Name',
                                                  Spouse_Name__c = 'Spouse Name');
        insert applicant;

        Case cs1 = new Case();
        cs1.Applicant__c = applicant.Id;
        cs1.Loan_Application__c = opp.Id;
        cs1.Origin = 'Email';
        cs1.SuppliedCompany = 'testpvt';
        insert cs1;
        
        //Document object for front side image testing.
        Documents__c aadhar = new Documents__c(Applicant__c =applicant.id,CMU_Rejection_Reason__c='Incorrect fields',Rejection_Fields__c = 'Salutation',CMU_Accept_Reject__c = 'Reject',Document_Type__c = System.Label.AadhaarCard,Opportunity_Relation__c=opp.id,Is_Front__c = true,Document_Side__c ='Front');
        insert aadhar;
        
        //Document object for Back side image testing.
        Documents__c pan = new Documents__c(Applicant__c =applicant.id,CMU_Rejection_Reason__c='Incorrect fields',Rejection_Fields__c = 'KYC name',CMU_Accept_Reject__c = 'Reject',Document_Type__c = system.Label.PanCard,Opportunity_Relation__c=opp.id,Is_Back__c = true,Document_Side__c ='Back');
        insert pan;
        
        //Document object for Back side image testing.
        Documents__c passport = new Documents__c(Applicant__c =applicant.id,CMU_Rejection_Reason__c='Incorrect fields',Rejection_Fields__c = 'KYC No.',CMU_Accept_Reject__c = 'Reject',Document_Type__c = system.Label.PassportCard,Opportunity_Relation__c=opp.id,Is_Back__c = true,Document_Side__c ='Back');
        insert passport;

        Documents__c Voter = new Documents__c(Applicant__c =applicant.id,CMU_Rejection_Reason__c='Incorrect fields',Rejection_Fields__c = 'KYC No.',CMU_Accept_Reject__c = 'Reject',Document_Type__c = system.Label.VoterIdCard,Opportunity_Relation__c=opp.id,Is_Back__c = true,Document_Side__c ='Back');
        insert Voter;

        // For image uploading and linking to Opp obj record.
        Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion Body to be insert in test class for testing'); 
        ContentVersion sampleImageUpload = new ContentVersion(
            Title='IndusIndLogo', 
            PathOnClient ='IndusIndLogo.png',
            VersionData = bodyBlob, 
            origin = 'H'
        );
        insert sampleImageUpload;
        
        ContentVersion uploadedImage = [SELECT Id,ContentDocumentId 
                                        FROM ContentVersion WHERE Id = :sampleImageUpload.Id LIMIT 1];
        
        ContentDocumentLink contentlink = new ContentDocumentLink();
        contentlink.LinkedEntityId = pan.id;
        contentlink.contentdocumentid = uploadedImage.contentdocumentid;
        contentlink.ShareType = 'V';
        insert contentlink;
        
        
        //Added bu Ruchi Jain for IND-279
        List<Opportunity> testOpportunity = new List<Opportunity>();
        for(Integer i=0;i<2;i++) {
            testOpportunity.add(new Opportunity(Name = 'Opportunity'+i,StageName='Qualification',
                                                CloseDate=System.today().addMonths(1),
                                                AccountId= testAccount.Id,
                                                OTP_for_borrower__c='9999',
                                                Applicant_Name__c='ayu',
                                                Mfr_Expence_Reimburse__c=32, 
                                                Mfr_Expence_Reimburse_Amt__c='6700'
                                                ,Mfr_Expence_Reimburse_Type__c='yhh' ,
                                                Mfr_Incentive__c=98,
                                                Main_Dealer_Incentive_Amount__c=76,
                                                Sub_Dealer_Ancentive_Amount__c=8798,
                                                DSM_Incentive1__c=767,
                                                DSM_Incentive2__c=65 ,DSM_Name1__c='bhgb' ,
                                                DSM_Name2__c='hhg', Dealer_Disc_to_Customer__c='878',
                                                Dealer_Expence_Reimburse_Type__c='hgfh',
                                                Gift_through_Dealer_Amount__c='866', Required_Tenure__c=7,
                                                Non_Dealer_DSM_Name1__c='jhfgh',
                                                Non_Dealer_DSM_Name2__c='jhhf',
                                                Non_Dealer_DSM_Incentive1__c=776, Non_Dealer_DSM_Incentive2__c=766,
                                                Required_ROI__c=5, 
                                                Service_Charges__c='76', Parent_Deal_number__c='7878',
                                                Documentation_Charges__c='98', Stamping_Charges__c='87', Loan_amount__c='76777',
                                                Contact_number__c = '415.555.1212', Aadhar_OCR_Retry_Attempts__c = 3));
        }
        insert testOpportunity;
        test.stopTest();
    }
    
     @isTest
    static void testGetCaseDetails() {
        // Test data setup
         //Applicant object for testing.
       
        Account testAccount = new Account(Name='Test Account');
        insert testAccount;
        Opportunity opp = new Opportunity( Name= 'Opportunity',
                                          StageName='Qualification',
                                          CloseDate=System.today().addMonths(1),
                                          AccountId= testAccount.Id,
                                          OTP_for_borrower__c='99999',
                                          Applicant_Name__c='ayu',
                                          Mfr_Expence_Reimburse__c=32, 
                                          Mfr_Expence_Reimburse_Amt__c='6700'
                                          ,Mfr_Expence_Reimburse_Type__c='yhh' ,
                                          Mfr_Incentive__c=98,
                                          Main_Dealer_Incentive_Amount__c=76,
                                          Sub_Dealer_Ancentive_Amount__c=8798,
                                          DSM_Incentive1__c=767,
                                          DSM_Incentive2__c=65 ,DSM_Name1__c='bhgb' ,
                                          DSM_Name2__c='hhg', Dealer_Disc_to_Customer__c='878',
                                          Dealer_Expence_Reimburse_Type__c='hgfh',
                                          Gift_through_Dealer_Amount__c='866', Required_Tenure__c=7,
                                          Non_Dealer_DSM_Name1__c='jhfgh',
                                          Non_Dealer_DSM_Name2__c='jhhf',
                                          Non_Dealer_DSM_Incentive1__c=776, Non_Dealer_DSM_Incentive2__c=766,
                                          Required_ROI__c=5, Service_Charges__c='76', Parent_Deal_number__c='7878',
                                          Documentation_Charges__c='98', Stamping_Charges__c='87', Loan_amount__c='76777',
                                          Contact_number__c = '415.555.1212',Front_Upload_Attempts__c=0,Back_Upload_Attempts__c=0,Selfie_Retry_Attempts__c=2);
        insert opp; 
        
        
        
        Applicant__c applicant = new Applicant__c(Name='Applicant1',Contact_Number__c ='1234567891',Opportunity__c = opp.Id,
                                                  Whatsapp_number__c='1231231231',Income_Ca__c='SAL',
                                                  Profile__c = 'Software Engineer', Bureau_Pull_Attempts__c=1,
                                                  Income_Source__c='Non-Earning',Mother_s_name__c = 'Mother Name',Father_s_name__c = 'Father Name',
                                                  Spouse_Name__c = 'Spouse Name');
        insert applicant;
        Case testCase = new Case(
            CMU_Case_Submitted_By__c = 'Test User',
            Loan_Application__c =opp.id ,
            Accept_Case__c = true,
           
           
            Status = 'Test Status'
        );
        insert testCase;

        // Call the method under test
        Test.startTest();
        Case result = IND_LWC_CMURejectController.getCaseDetails(testCase.Id);
        //IND_LWC_CMURejectController.updateCase(testCase.Id);
        Test.stopTest();

        // Assertion
        //System.assertEquals(testCase.CMU_Case_Submitted_By__c, result.CMU_Case_Submitted_By__c);
        // Add more assertions for other fields if necessary
    }
    
     @isTest
    static void testGetLoanApplication() {
        
        Account testAccount = new Account(Name='Test Account');
        insert testAccount;
        Opportunity opp = new Opportunity( Name= 'Opportunity',
                                          StageName='Qualification',
                                          CloseDate=System.today().addMonths(1),
                                          AccountId= testAccount.Id,
                                          OTP_for_borrower__c='99999',
                                          Applicant_Name__c='ayu',
                                          Mfr_Expence_Reimburse__c=32, 
                                          Mfr_Expence_Reimburse_Amt__c='6700'
                                          ,Mfr_Expence_Reimburse_Type__c='yhh' ,
                                          Mfr_Incentive__c=98,
                                          Main_Dealer_Incentive_Amount__c=76,
                                          Sub_Dealer_Ancentive_Amount__c=8798,
                                          DSM_Incentive1__c=767,
                                          DSM_Incentive2__c=65 ,DSM_Name1__c='bhgb' ,
                                          DSM_Name2__c='hhg', Dealer_Disc_to_Customer__c='878',
                                          Dealer_Expence_Reimburse_Type__c='hgfh',
                                          Gift_through_Dealer_Amount__c='866', Required_Tenure__c=7,
                                          Non_Dealer_DSM_Name1__c='jhfgh',
                                          Non_Dealer_DSM_Name2__c='jhhf',
                                          Non_Dealer_DSM_Incentive1__c=776, Non_Dealer_DSM_Incentive2__c=766,
                                          Required_ROI__c=5, Service_Charges__c='76', Parent_Deal_number__c='7878',
                                          Documentation_Charges__c='98', Stamping_Charges__c='87', Loan_amount__c='76777',
                                          Contact_number__c = '415.555.1212',Front_Upload_Attempts__c=0,Back_Upload_Attempts__c=0,Selfie_Retry_Attempts__c=2);
        insert opp; 
        
         Applicant__c applicant = new Applicant__c(Name='Applicant1',Contact_Number__c ='1234567891',Opportunity__c = opp.Id,
                                                  Whatsapp_number__c='1231231231',Income_Ca__c='SAL',
                                                  Profile__c = 'Software Engineer', Bureau_Pull_Attempts__c=1,
                                                  Income_Source__c='Non-Earning',Mother_s_name__c = 'Mother Name',Father_s_name__c = 'Father Name',
                                                  Spouse_Name__c = 'Spouse Name');
        insert applicant;
        Case testCase = new Case(
            Loan_Application__c = opp.Id,
            
            Status = 'Test Status'
        );
        insert testCase;

        // Call the method under test
        Test.startTest();
        Case result = IND_LWC_CMURejectController.getLoanApplication(testCase.Id);
        Test.stopTest();

       
    }
    
    

 @isTest
    static void testUpdateCase() {
        // Test data setup
       Account testAccount = new Account(Name='Test Account');
        insert testAccount;
        Opportunity opp = new Opportunity( Name= 'Opportunity',
                                          StageName='Qualification',
                                          CloseDate=System.today().addMonths(1),
                                          AccountId= testAccount.Id,
                                          OTP_for_borrower__c='99999',
                                          Applicant_Name__c='ayu',
                                          Mfr_Expence_Reimburse__c=32, 
                                          Mfr_Expence_Reimburse_Amt__c='6700'
                                          ,Mfr_Expence_Reimburse_Type__c='yhh' ,
                                          Mfr_Incentive__c=98,
                                          Main_Dealer_Incentive_Amount__c=76,
                                          Sub_Dealer_Ancentive_Amount__c=8798,
                                          DSM_Incentive1__c=767,
                                          DSM_Incentive2__c=65 ,DSM_Name1__c='bhgb' ,
                                          DSM_Name2__c='hhg', Dealer_Disc_to_Customer__c='878',
                                          Dealer_Expence_Reimburse_Type__c='hgfh',
                                          Gift_through_Dealer_Amount__c='866', Required_Tenure__c=7,
                                          Non_Dealer_DSM_Name1__c='jhfgh',
                                          Non_Dealer_DSM_Name2__c='jhhf',
                                          Non_Dealer_DSM_Incentive1__c=776, Non_Dealer_DSM_Incentive2__c=766,
                                          Required_ROI__c=5, Service_Charges__c='76', Parent_Deal_number__c='7878',
                                          Documentation_Charges__c='98', Stamping_Charges__c='87', Loan_amount__c='76777',
                                          Contact_number__c = '415.555.1212',Front_Upload_Attempts__c=0,Back_Upload_Attempts__c=0,Selfie_Retry_Attempts__c=2);
        insert opp; 
        
        
        
        Applicant__c applicant = new Applicant__c(Name='Applicant1',Contact_Number__c ='1234567891',Opportunity__c = opp.Id,
                                                  Whatsapp_number__c='1231231231',Income_Ca__c='SAL',
                                                  Profile__c = 'Software Engineer', Bureau_Pull_Attempts__c=1,
                                                  Income_Source__c='Non-Earning',Mother_s_name__c = 'Mother Name',Father_s_name__c = 'Father Name',
                                                  Spouse_Name__c = 'Spouse Name');
        insert applicant;
        Case testCase = new Case(
            CMU_Case_Submitted_By__c = 'Test User',
            Loan_Application__c =opp.id ,
            Accept_Case__c = true,
           
           
            Status = 'Test Status'
        );
        insert testCase;
        // Call the method under test
        Test.startTest();
        IND_LWC_CMURejectController.updateCase(testCase.Id);
        Test.stopTest();

       
    }
    
    
    
    
    
    
    @isTest
    public static void testGetDocumentsList(){
        
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
        
        Case cs1 = new Case();
        cs1.Applicant__c = apks1.Id;
        insert cs1;
        String caseid = cs1.id;
        
        Opportunity opp = [SELECT ID FROM Opportunity WHERE name = 'Opportunity'];
        Test.startTest();
        IND_LWC_CMURejectController.getDocumentsList(caseid);     
        //system.assertEquals(3,docList.size());
        Test.stopTest();
    }
    @isTest
    public static void testGetDocumentDetails(){
        Test.startTest();
        Documents__c docPan = [SELECT ID,Document_Type__c FROM Documents__c WHERE Document_Type__c =:system.Label.PanCard];
        IND_LWC_CMURejectController.docFieldWrapper docElementPan = IND_LWC_CMURejectController.getDocumentDetails(docPan.ID,docPan.Document_Type__c);  
        system.assertEquals('KYC name',docElementPan.document.Rejection_Fields__c);
        
        Documents__c docAadhar = [SELECT ID,Document_Type__c FROM Documents__c WHERE Document_Type__c =:system.Label.AadhaarCard];
        IND_LWC_CMURejectController.docFieldWrapper docElementAadhar = IND_LWC_CMURejectController.getDocumentDetails(docAadhar.ID,docAadhar.Document_Type__c);    
        system.assertEquals('Salutation',docElementAadhar.document.Rejection_Fields__c);
        
        Documents__c docPassport = [SELECT ID,Document_Type__c FROM Documents__c WHERE Document_Type__c =:system.Label.PassportCard];
        IND_LWC_CMURejectController.docFieldWrapper docElementPaasport = IND_LWC_CMURejectController.getDocumentDetails(docPassport.ID,docPassport.Document_Type__c);    
        system.assertEquals('KYC No.',docElementPaasport.document.Rejection_Fields__c);
        Test.stopTest();
    }
    @isTest
    public static void testDeleteRelatedDocuments(){  
        Test.startTest();
        ContentVersion uploadedImage = [SELECT Id,ContentDocumentId FROM ContentVersion LIMIT 1];
        Documents__c docPan = [SELECT ID,Document_Type__c FROM Documents__c WHERE Document_Type__c =:system.Label.PanCard];
        List<String> docList = new List<String>();
        docList.add(uploadedImage.ContentDocumentId);
        IND_LWC_CMURejectController.deleteRelatedDocuments(docPan.ID,JSON.serialize(docList));
        Test.stopTest();
    }

    @isTest
    public static void testdeleteRelatedDocumentsOnUpload(){  
        Test.startTest();
        ContentVersion uploadedImage = [SELECT Id,ContentDocumentId FROM ContentVersion LIMIT 1];
        Documents__c docPan = [SELECT ID,Document_Type__c FROM Documents__c WHERE Document_Type__c =:system.Label.PanCard];
        List<String> docList = new List<String>();
        docList.add(uploadedImage.ContentDocumentId);
        IND_LWC_CMURejectController.deleteRelatedDocumentsOnUpload(docPan.ID,JSON.serialize(docList),'Front');
        Test.stopTest();
    }
    
    @isTest
    public static void checkPortalEnableTest(){
        Test.startTest();
            IND_LWC_CMURejectController.checkPortalEnable();
        Test.stopTest();
    }

    @isTest
    public static void getDecryptKycNumberTest(){
        Test.startTest();
        Documents__c doc1 = [Select Id from Documents__c LIMIT 1];
            IND_LWC_CMURejectController.getDecryptKycNumber(doc1.Id);
        Test.stopTest();
    }
    @isTest
    public static void getDecryptKycNumberTest1(){
        Test.startTest();
        Documents__c doc1 = [Select Id from Documents__c where Document_Type__c =: system.Label.PanCard LIMIT 1];
            IND_LWC_CMURejectController.getDecryptKycNumber(doc1.Id);
        Test.stopTest();
    }
    @isTest
    public static void getDecryptKycNumberTest2(){
        Test.startTest();
        Documents__c doc1 = [Select Id from Documents__c where Document_Type__c =: system.Label.PassportCard LIMIT 1];
            IND_LWC_CMURejectController.getDecryptKycNumber(doc1.Id);
        Test.stopTest();
    }
    @isTest
    public static void getDecryptKycNumberTest3(){
        Test.startTest();
        Documents__c doc1 = [Select Id from Documents__c where Document_Type__c =: system.Label.VoterIdCard LIMIT 1];
            IND_LWC_CMURejectController.getDecryptKycNumber(doc1.Id);
        Test.stopTest();
    }
    
    /*
    @isTest
    public static void getEncryptedRequestTest(){
        Test.startTest();
        IND_LWC_CMURejectController.getEncryptedRequest('dA+JIj3LduKSaZAK3YBj3A==');
        Test.stopTest();
    }    
    */
    
    @isTest
    public static void getContentDocumentTest(){
        Test.startTest();
        Documents__c doc1 = [Select Id from Documents__c LIMIT 1];
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
        contentlink1.LinkedEntityId = doc1.Id; 
        contentlink1.ContentDocumentId = testContent1.ContentDocumentId;
        contentlink1.Visibility = 'AllUsers'; 
        insert contentlink1;
            IND_LWC_CMURejectController.getContentDocument(doc1.Id);
        Test.stopTest();
    }

    
    @isTest
    public static void getDocumentsListTest3(){
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
            
                 case cs2 = new case();
                 cs2.Loan_Application__c = opks1.Id;
             //    cs2.RecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByName().get('FI').getRecordTypeId();
                 cs2.Subject='Approval Of Application Sourced By Off Roll Employee';
                 cs2.Status = 'Pending-Off Role Employee App';
                 cs2.Origin = 'Web';
                 cs2.Type = 'Problem';
                 cs2.Status = 'New';
                 cs2.Applicant__c = apks1.Id;
                 insert cs2; 
            
                 Documents__c dfks1 = new Documents__c();
                 dfks1.Case__c = cs2.Id;
                 dfks1.Applicant__c = apks1.Id;
                 dfks1.Opportunity_Relation__c = opks1.Id;
                 dfks1.KYC_name__c = 'Aadhar';
                 dfks1.Document_Side__c ='Back';
                 dfks1.Aadhar_Source__c = 'ScanAadhar';
                 dfks1.Name = 'Aadhar';
                 dfks1.Document_Type__c =system.Label.AadhaarCard;
                 dfks1.CMU_Accept_Reject__c = 'Reject';
                 dfks1.CMU_Rejection_Reason__c ='Incorrect fields';
                 dfks1.Rejection_Fields__c = 'Salutation;Gender;KYC Expiry Date;KYC Issuance Date;PAN No.';
                 insert dfks1;
            
                 Test.startTest();
                        IND_LWC_CMURejectController.getDocumentsList(cs2.Id);
                 Test.stopTest();
            
        }catch(Exception e){
            System.assertEquals('script-thrown exception', e.getMessage());
        }
        
    }
    
    @isTest
    public static void updateApplicantDetailsTest(){
    	try{
            Applicant__c app = [SELECT Id FROM Applicant__c WHERE Profile__c = 'Software Engineer' LIMIT 1];
            List<IND_LWC_CMURejectController.appFieldWrapper> appFieldList = new List<IND_LWC_CMURejectController.appFieldWrapper>();
                IND_LWC_CMURejectController.appFieldWrapper appFieldObj = new IND_LWC_CMURejectController.appFieldWrapper();
                appFieldObj.label = 'Father\'s Name';
                appFieldObj.value = 'Father\'s Name';
                appFieldList.add(appFieldObj);
            	IND_LWC_CMURejectController.appFieldWrapper appFieldObj1 = new IND_LWC_CMURejectController.appFieldWrapper();
                appFieldObj1.label = 'Mother\'s Name';
                appFieldObj1.value = 'Mother\'s Name';
                appFieldList.add(appFieldObj1);
            	IND_LWC_CMURejectController.appFieldWrapper appFieldObj2 = new IND_LWC_CMURejectController.appFieldWrapper();
                appFieldObj2.label = 'Spouse Name';
                appFieldObj2.value = 'Spouse\'s Name';
                appFieldList.add(appFieldObj2);
            Test.startTest();
            	IND_LWC_CMURejectController.updateApplicantDetails(appFieldList, app.Id);
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals('script-thrown exception', e.getMessage());
        }
    }
    @isTest
    public static void checkPanDocumentTest(){
        List<Documents__c> docList = [SELECT ID from Documents__c WHERE Document_Type__c =: system.Label.PanCard LIMIT 1];
        docList[0].NSDL_Response__c = 'Existing and Valid PAN' ;
        docList[0].AadhaarSeedingStatus__c = 'Y';
        update docList;
        Test.startTest();
        IND_LWC_CMURejectController.checkPanDocument(docList[0].Id);
        Test.stopTest();
        docList[0].AadhaarSeedingStatus__c = 'N';
        update docList;
        IND_LWC_CMURejectController.checkPanDocument(docList[0].Id);
    }    
     @isTest
    static void testGetAppFieldList() {
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
            
        Documents__c testDoc = new Documents__c(
            Applicant__c = apks1.id,
            Opportunity_Relation__c=opks1.id
        );
        insert testDoc;

        // Set up rejection fields
        String rejectionFields = 'Father;Mother;Spouse';

        // Call the method under test
        Test.startTest();
      IND_LWC_CMURejectController.getAppFieldList(testDoc, rejectionFields);
        Test.stopTest();

        // Assertion
      //  System.assertEquals(3, result.size()); // Expected number of appFieldWrapper objects

        // Check each field wrapper
        
    }
    
    
    
}