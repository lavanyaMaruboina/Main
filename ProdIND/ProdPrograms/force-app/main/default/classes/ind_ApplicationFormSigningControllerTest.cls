@isTest
public class ind_ApplicationFormSigningControllerTest {
    @isTest
    public static void getloanappidTest(){
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
        
                Test.startTest();
                       ind_ApplicationFormSigningController.getloanappid(apks1.Id);
                Test.stopTest();
    }
    
    @isTest
    public static void getInsurenDetailsTest(){
        
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
        
                InsuranceDetails__c insuDetail = new InsuranceDetails__c();
                insuDetail.Applicant__c = apks1.id;
                insuDetail.Funded_Premium__c=400.00;
                insuDetail.Loan_Application__c = opks1.id;
           //     insuDetail.Funded_Non_funded__c = 'Funded';
           //     insuDetail.Name = 'MOTOR';
                insert insuDetail;
        
                Test.startTest();
                      ind_ApplicationFormSigningController.getInsurenDetails(apks1.id);
                Test.stopTest();
    }
    
    @isTest
    public static void getKYCDetailsTest(){
        
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
                 dfks1.Document_Type__c = 'Customer Image';
                 dfks1.Document_Side__c ='Back';
                 dfks1.Aadhar_Source__c = 'ScanAadhar';
                 insert dfks1;
        
                 Test.startTest();
                       ind_ApplicationFormSigningController.getKYCDetails(apks1.Id);
                 Test.stopTest();
    }
    
    @isTest
    public static void getIncomeDetailsTest(){
        
        Opportunity opp1 = TestDataUtility.createTestOpportunity(false);
        insert opp1;
        
        Applicant__c app1 = TestDataUtility.createTestApplicant(false);
        app1.Opportunity__c= opp1.Id;
        app1.Applicant_Type__c = System.Label.Borrower;
        insert app1;
        
        Income_Details__c inc1 = TestDataUtility.createTestIncomeDetails(false);
        inc1.Applicant__c = app1.id;
        insert inc1;
        
        Test.startTest();
             ind_ApplicationFormSigningController.getIncomeDetails(app1.id);
        Test.stopTest();
    }
    
    @isTest
    public static void getFinalTermTest(){
        
        Opportunity opp1 = TestDataUtility.createTestOpportunity(false);
        insert opp1;
        
        Applicant__c app1 = TestDataUtility.createTestApplicant(false);
        app1.Opportunity__c= opp1.Id;
        app1.Applicant_Type__c = System.Label.Borrower;
        insert app1;
        
        Final_Term__c ftv1 = new Final_Term__c();
        ftv1.CRM_IRR__c = 120;
        ftv1.Loan_Application__c = opp1.Id;
        ftv1.Holiday_period__c='30';
        ftv1.EMI_Amount__c= 10000;
        insert ftv1;
        
        Test.startTest();
             ind_ApplicationFormSigningController.getFinalTerm(app1.Id);
        Test.stopTest();
    }
    
    @isTest
    public static void getInsurenceDetailsTest(){
        Opportunity opp1 = TestDataUtility.createTestOpportunity(false);
        insert opp1;
        
        Applicant__c app1 = TestDataUtility.createTestApplicant(false);
        app1.Opportunity__c= opp1.Id;
        app1.Applicant_Type__c = System.Label.Borrower;
        insert app1;
        
        InsuranceDetails__c insuDetail = new InsuranceDetails__c();
        insuDetail.Applicant__c = app1.id;
        insuDetail.Funded_Premium__c=400.00;
        insuDetail.Loan_Application__c = opp1.id;
        insert insuDetail;
        
        Test.startTest();
              ind_ApplicationFormSigningController.getInsurenceDetails(app1.id);
        Test.stopTest();
    }
    
    @isTest
    public static void getvehicleTest(){
        Opportunity opp1 = TestDataUtility.createTestOpportunity(false);
        insert opp1;
        
        Applicant__c app1 = TestDataUtility.createTestApplicant(false);
        app1.Opportunity__c= opp1.Id;
        app1.Applicant_Type__c = System.Label.Borrower;
        insert app1;
        
        Vehicle_Detail__c vech = new Vehicle_Detail__c();
        vech.Loan_Application__c = opp1.Id;
        insert vech;
        
        Test.startTest();
              ind_ApplicationFormSigningController.getvehicle(app1.Id);
        Test.stopTest();
    }
    
    @isTest
    public static void getProductTypeTest(){
        Opportunity opp1 = TestDataUtility.createTestOpportunity(false);
        insert opp1;
        
        Applicant__c app1 = TestDataUtility.createTestApplicant(false);
        app1.Opportunity__c= opp1.Id;
        app1.Applicant_Type__c = System.Label.Borrower;
        insert app1;
        
        Test.startTest();
             ind_ApplicationFormSigningController.getProductType(app1.Id);
        Test.stopTest();
    }
    
    @isTest
    public static void getApplicentDocumentsTest(){
        Opportunity opp1 = TestDataUtility.createTestOpportunity(false);
        insert opp1;
        
        Applicant__c app1 = TestDataUtility.createTestApplicant(false);
        app1.Opportunity__c= opp1.Id;
        app1.Applicant_Type__c = System.Label.Borrower;
        insert app1;
        
        Documents__c dfks1 = new Documents__c();
        dfks1.Applicant__c = app1.Id;
        dfks1.Opportunity_Relation__c = opp1.Id;
        dfks1.Document_Type__c = 'Customer Image';
        dfks1.Document_Side__c ='Back';
        dfks1.Aadhar_Source__c = 'ScanAadhar';
        insert dfks1;
        
        Test.startTest();
              ind_ApplicationFormSigningController.getApplicentDocuments(app1.Id);
        Test.stopTest();
    }
    @isTest 
    public static void DisplayCustomerImageTest(){
        
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
                 dfks1.Document_Type__c = 'Customer Image';
                 dfks1.Document_Side__c ='Back';
                 dfks1.Aadhar_Source__c = 'ScanAadhar';
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
                        ind_ApplicationFormSigningController.DisplayCustomerImage(apks1.Id);
                 Test.stopTest();
       
    }
}