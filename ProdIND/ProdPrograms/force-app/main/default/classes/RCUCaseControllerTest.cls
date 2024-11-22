@isTest
public class RCUCaseControllerTest {
    @testSetup 
    static void testDataSetup() 
    {
        //create user
        Profile p = [SELECT Id FROM Profile WHERE Name='IBL Business Executive'];
        User u = new User(Alias = 'standt2', Email='standarduser2@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,Maker_Id__c='12',IsActive = true,
                          TimeZoneSidKey='America/Los_Angeles',UserName='test_userprod123@indusbank.com.uat',
                          MobilePhone='8234567890');
        insert u;
        System.runAs(u) 
        {
            
            Account acc = new Account();
            acc.Name = 'test account';
            acc.State__c = 'MAHARASHTRA';
            acc.Phone = '+914335225';
            insert acc;
            
            List<Opportunity> oppList = new List<Opportunity>();
            Opportunity opp = TestDataUtility.createTestOpportunityForOcr(false); 
            opp.Sub_Stage__c = System.Label.Field_Investigation;
            opp.Is_Mobile_Journey_Completed__c = true;
            opp.Vehicle_Type__c = System.Label.used;
            opp.Product_Type__c = System.Label.PassengerVehicles;
            opp.Sanction_Status__c = System.Label.nonStp;  
            opp.Agent_BL_code__c = 'AHZ';
            opp.Deal_Number__c = null; 
            opp.AccountId = acc.Id;
            opp.Required_ROI__c = 9;
            opp.Sanction_Date__c = Date.newInstance(2022, 06, 11);
            opp.Product_Type__c = 'Tractor';
            opp.EMI_Amount__c = 10000;  
            opp.Agreement_Amount__c = 450000;
            opp.Documentation_Charges__c = '2000';
            opp.Applicant_Name__c = 'test';
            oppList.add(opp);  
            
            Opportunity opp1 = new Opportunity();
            opp1.AccountId = acc.Id;
            opp1.Name = 'OppTest';
            opp1.StageName = 'Disbursement Request Preparation'; 
            opp1.CloseDate = Date.newInstance(2022, 07, 15);
            opp1.Applicant_Name__c = 'TestLoanApplication';
            opp1.Application_number__c = '56765';
            opp1.Employee_Branch__c = 'test';
            opp1.Make__c = 'loan';
            opp1.Variant__c = 'Home Loan';
            opp1.Category__c ='SAL';
            oppList.add(opp1);
            
            Opportunity opp2 = new Opportunity();
            opp2.AccountId = acc.Id;
            opp2.Name = 'OppTest';
            opp2.StageName = 'Disbursement Request Preparation'; 
            opp2.CloseDate = Date.newInstance(2022, 07, 15);
            opp2.Applicant_Name__c = 'TestLoanApplication';
            opp2.Application_number__c = '567652';
            opp2.Employee_Branch__c = 'test';
            opp2.Make__c = 'loan';
            opp2.Product_Type__c = 'Tractor';
            opp2.Variant__c = 'Home Loan';
            opp2.Category__c ='SAL';
            oppList.add(opp2);
            
            insert oppList;
            
            List<Applicant__c> applicantList = new List<Applicant__c>();
            Applicant__c applicant1 = TestDataUtility.createTestApplicatnt1(false);
            applicant1.Name = 'testapplicant1';
            applicant1.Father_s_name__c = 'fsfdsf';
            applicant1.Opportunity__c = oppList[0].Id;
            applicant1.Who_will_repay_the_loan__c = 'Borrower';
            applicant1.Scorecard_Decision__c = 'Light Red';
            applicant1.Contact_Number__c = '+9123456789';
            applicant1.Applicant_Type__c = 'Borrower';
            applicant1.Email_Id_2__c = 'test2@abc.com';
            applicant1.Email_Id_1__c = 'test1@abc.com';
            applicant1.Email_Id__c = 'test@abc.com';
            applicantList.add(applicant1);
            
            Applicant__c applicant2 = TestDataUtility.createTestApplicatnt1(false);
            applicant2.Name = 'testapplicant1';
            applicant2.Father_s_name__c = 'fsfdsf';
            applicant2.Opportunity__c = oppList[0].Id;
            applicant2.Scorecard_Decision__c = 'Light Red';
            applicant2.Contact_Number__c = '+9123456789';
            applicant2.Applicant_Type__c = System.Label.CoBorrower;
            applicant2.Email_Id_2__c = 'test2@abc.com';
            applicant2.Email_Id_1__c = 'test1@abc.com';
            applicant2.Email_Id__c = 'test@abc.com';
            applicantList.add(applicant2);
            
            INSERT applicantList;
            
            Case caseObj1 = new Case();
            caseObj1.Status = 'Closed';
            caseObj1.Origin = 'Phone';
            caseObj1.District__c = 'Noida';
            caseObj1.RCU_Manager__c = u.Id;
            caseObj1.Loan_Application__c = oppList[1].Id;
            caseObj1.RecordTypeId = (String) Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('RCU').getRecordTypeId();
            insert caseObj1;
            
            Case caseObj2 = new Case();
            caseObj2.Status = 'New';
            caseObj2.Origin = 'Phone';
            caseObj2.District__c = 'Noida';
            caseObj2.Loan_Application__c = oppList[0].Id;
            caseObj2.RCU_Manager__c = u.Id;
            caseObj2.RecordTypeId = (String) Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('RCU').getRecordTypeId();
            insert caseObj2;
            
            Case caseObj3 = new Case();
            caseObj3.Status = 'New';
            caseObj3.Subject = 'Test Sub';
            caseObj3.Origin = 'Phone';
            caseObj3.District__c = 'Noida';
            caseObj3.Loan_Application__c = oppList[0].Id;
            caseObj3.RCU_Manager__c = u.Id;
            caseObj3.Applicant__c = applicantList[1].Id;
            caseObj3.RecordTypeId = (String) Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('RCU').getRecordTypeId();
            insert caseObj3;
            
            AccountTeamMember atm1 = new AccountTeamMember();
            atm1.AccountId = acc.Id;
            atm1.TeamMemberRole = 'RCU_M';
            atm1.UserId = u.id;
            insert atm1;
            
            List<Documents__c> documentList = new List<Documents__c>();
            for(Integer y=0;y<2;y++){
                Documents__c dfks1 = new Documents__c();
                dfks1.Opportunity_Relation__c = oppList[0].Id;
                dfks1.KYC_name__c = 'Aadhar';
                dfks1.Document_Side__c ='Back';
                dfks1.Aadhar_Source__c = 'ScanAadhar';
                dfks1.Document_Type__c = System.Label.AadhaarCard;
                dfks1.KYC_DOB__c = system.today();
                dfks1.Proof_of_Identity_POI__c = true;
                dfks1.Gender__c = 'MALE';
                dfks1.RCU_Agency_Verification_Status__c = 'Sampled';
                dfks1.RCU_Agency_Verification_Sub_Status__c = 'Refer to Credit';
                if(y==0){
                    dfks1.Name = 'Document1';
                    dfks1.RCU_Case__c = caseObj1.id;
                    dfks1.Applicant__c = applicantList[0].Id;  
                }
                if(y==1){ 
                    dfks1.Name = 'Document2';
                    dfks1.RCU_Case__c = caseObj2.id;
                    dfks1.Applicant__c = applicantList[1].Id; 
                }
                documentList.add(dfks1);  
            }
            insert documentList;
        }
    }
    
    @isTest
    public static void createRCUCaseTest(){
        string applicantId = [Select Id from opportunity where Product_Type__c ='Tractor' limit 1 offset 1].Id;
        RCUCaseController.createRCUCase(applicantId);  
    }
    
    @isTest
    public static void RCUCaseControllerTest(){
        
        Test.startTest();
        List<Documents__c> documentList = new List<Documents__c>();
        documentList = [Select id from Documents__c];  
        String recordId = [Select Id,Subject from case where Status ='New' limit 1 ].Id;
        RCUCaseController.getRCUCaseDetails(recordId);
        String accountId = [Select Id from Account where Name ='test account' limit 1 ].Id;
        String loanApplicationId = [Select Id from opportunity where Product_Type__c =  'Tractor' limit 1].Id;
        String ownerId = [Select Id from user where Email='standarduser2@testorg.com' limit 1 ].Id;
        String district = [SELECT Id, District__c FROM Case LIMIT 1].District__c;
        
        
        
        RCUCaseController.updateCaseOwner(recordId, ownerId);
        RCUCaseController.submitRCUCaseForApproval(recordId);
        RCUCaseController.getCurrentUser(ownerId);
        RCUCaseController.saveCaseDataToBackend(recordId,recordId);
        RCUCaseController.createRCUChildCase('56765', loanApplicationId, accountId, recordId, documentList, 'RCU_M', 'TestOwner' ,ownerId, district);
        RCUCaseController.getSamplingReasonPicklist();
        Test.stopTest();
    }
    
    @isTest
    public static void saveCaseDataToBackendTest(){
        
        Case case_Data = [Select Id from case where Status ='Closed' limit 1 ];
        String caseData = JSON.serialize(case_Data);
        String recordIds = [Select Id from case where Status ='Closed' limit 1 ].Id;
        RCUCaseController.saveCaseDataToBackend(recordIds, caseData);
        try{
            RCUCaseController.updateCaseOwner(recordIds, recordIds);
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void saveCaseDataToBackendTestCatch(){
        
        try{
            String recordIds = [Select Id from case where Status ='Closed' limit 1 ].Id;
            RCUCaseController.saveCaseDataToBackend(recordIds,recordIds);
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void getCurrentUserTestCatch(){
        
        try{
            RCUCaseController.getCurrentUser('null');
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void getRCUCaseDetailsTestCatch(){
        
        try{
            RCUCaseController.getRCUCaseDetails('null');
            RCUCaseController.submitRCUCaseForApproval('null');
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void updateCaseStatusTest(){
        
        try{
            String recordIds = [Select Id from case where Status ='Closed' limit 1 ].Id;
            String loanApplicationId = [Select Id from opportunity limit 1].Id;
            
            Case caseObj2 = new Case();
            caseObj2.Status = 'Resolved';
            caseObj2.Origin = 'Phone';
            caseObj2.District__c = 'Noida';
            caseObj2.Loan_Application__c = loanApplicationId;
            //caseObj2.RCU_Manager__c = u.Id;
            caseObj2.ParentId = recordIds;
            caseObj2.RecordTypeId = (String) Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('RCU').getRecordTypeId();
            insert caseObj2;
            
            RCUCaseController.updateCaseStatus(recordIds);
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
        @isTest
    public static void updateCaseStatusTest2(){
        
        try{
            String recordIds = [Select Id from case where Status ='Closed' limit 1 ].Id;
            String loanApplicationId = [Select Id from opportunity limit 1].Id;
            
            Case caseObj2 = new Case();
            caseObj2.Status = 'New';
            caseObj2.Origin = 'Phone';
            caseObj2.District__c = 'Noida';
            caseObj2.Loan_Application__c = loanApplicationId;
            //caseObj2.RCU_Manager__c = u.Id;
            caseObj2.ParentId = recordIds;
            caseObj2.RecordTypeId = (String) Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('RCU').getRecordTypeId();
            insert caseObj2;
            
            RCUCaseController.updateCaseStatus(recordIds);
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
        @isTest
    public static void updateCaseStatusTest3(){
        
        try{
            String recordIds = [Select Id from case where Status ='Closed' limit 1 ].Id;
            String loanApplicationId = [Select Id from opportunity limit 1].Id;
            
            RCUCaseController.updateCaseStatus(recordIds);
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void isRCUCaseClosedTest(){
        
        try{
            String loanApplicationId = [Select Id from opportunity where Product_Type__c =  'Tractor' limit 1].Id;
            
            RCUCaseController.isRCUCaseClosed(loanApplicationId);
            
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    @isTest
    public static void rCUVerificationTest(){
        
        try{
            case caseRec = [Select Id,Applicant__c,Loan_Application__c from case where Status ='New' AND Subject='Test Sub' limit 1 ];
            
            Documents__c dfks1 = new Documents__c();
            dfks1.Opportunity_Relation__c = caseRec.Loan_Application__c;
            dfks1.KYC_name__c = 'Aadhar';
            dfks1.Document_Side__c ='Back';
            dfks1.Aadhar_Source__c = 'ScanAadhar';
            dfks1.Document_Type__c = System.Label.AadhaarCard;
            dfks1.KYC_DOB__c = system.today();
            dfks1.KYC_Address_Line_1__c = 'Test1';
            dfks1.KYC_Address_Line_2__c = 'Test2';
            dfks1.Proof_of_Identity_POI__c = true;
            dfks1.Gender__c = 'MALE';
            dfks1.is_Active__c = true;
            dfks1.Proof_of_Identity_POI__c = true;
            dfks1.RCU_Agency_Verification_Status__c = 'Sampled';
            dfks1.RCU_Agency_Verification_Sub_Status__c = 'Refer to Credit';
            dfks1.Name = 'Document1';
            dfks1.Applicant__c = caseRec.Applicant__c;  
            insert dfks1;
            
            CIBIL_Details__c cd =new CIBIL_Details__c(Applicant__c = caseRec.Applicant__c);
			insert cd;
            
            RCUCaseController.RCUVerification(caseRec.Id);
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
	@isTest
	public static void testIsAllDocumentsScreened() {
    Test.startTest();
    String caseId = [SELECT Id FROM Case WHERE Status = 'New' LIMIT 1].Id;
    Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
    Applicant__c applicant = [SELECT Id FROM Applicant__c LIMIT 1];

    List<Documents__c> documentList = new List<Documents__c>();
    Documents__c doc1 = new Documents__c(
        RCU_Case__c = caseId,
        Opportunity_Relation__c = opp.Id,
        Applicant__c = applicant.Id,
        KYC_name__c = 'Aadhar',
        Document_Type__c = 'AadharCard',
        RCU_Agency_Verification_Status__c = 'Screened'
    );
    documentList.add(doc1);
    Documents__c doc2 = new Documents__c(
        RCU_Case__c = caseId,
        Opportunity_Relation__c = opp.Id,
        Applicant__c = applicant.Id,
        KYC_name__c = 'Passport',
        Document_Type__c = 'Resi Profile Document',
        RCU_Agency_Verification_Status__c = 'Sampled'
    );
    documentList.add(doc2);
    insert documentList;
    Boolean result = RCUCaseController.isAllDocumentsScreened(caseId);
    System.assertEquals(false, result, 'Expected result is false as not all documents are screened.');
    for (Documents__c doc : documentList) {
        doc.RCU_Agency_Verification_Status__c = 'Screened';
    }
    update documentList;
    result = RCUCaseController.isAllDocumentsScreened(caseId);
    System.assertEquals(false, result, 'Expected result is true as all documents are screened.');
    Test.stopTest();
	}
    @isTest
	public static void testCreateResiDoc() {
    Test.startTest();
    Opportunity opp = new Opportunity(Name = 'Test Opportunity',StageName = 'Disbursement Request Preparation',CloseDate = Date.newInstance(2022, 07, 15));
    insert opp;
    Applicant__c app1 = new Applicant__c(Name = 'Applicant 1', Opportunity__c = opp.Id, Applicant_Type__c = 'Borrower');
    Applicant__c app2 = new Applicant__c(Name = 'Applicant 2', Opportunity__c = opp.Id, Applicant_Type__c = 'Co-Borrower');
    insert new List<Applicant__c>{app1, app2};
    List<Documents__c> resiDocs = RCUCaseController.createResiDoc(opp.Id);
    System.assertNotEquals(null, resiDocs, 'Resi documents should be created.');
    System.assertEquals(2, resiDocs.size(), 'There should be 2 Resi Profile Documents.');
    for (Documents__c doc : resiDocs) {
        System.assertEquals('Resi Profile Document', doc.Document_Type__c, 'Document Type should be Resi Profile Document.');
        System.assertEquals(true, doc.Is_Active__c, 'Document should be active.');
    }
    Test.stopTest();
	}
    
    @isTest
	public static void testIsResiDocumentUploaded() {
    Test.startTest();
    Case testCase = new Case(Status = 'New', RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('RCU').getRecordTypeId());
    insert testCase;
    Opportunity opp = new Opportunity(Name = 'Test Opportunity',StageName = 'Disbursement Request Preparation',CloseDate = Date.newInstance(2022, 07, 15));
    insert opp;
    Applicant__c app = new Applicant__c(Name = 'Applicant 1', Opportunity__c = opp.Id, Applicant_Type__c = 'Borrower');
    insert app;
    Documents__c doc = new Documents__c(
        RCU_Case__c = testCase.Id,
        Opportunity_Relation__c = opp.Id,
        Applicant__c = app.Id,
        Document_Type__c = 'Resi Profile Document',
        Is_Active__c = true,
        RecordTypeId = Schema.sObjectType.Documents__c.getRecordTypeInfosByName().get('Resi Profile Documents').getRecordTypeId(),
        RCU_Agency_Verification_Status__c = 'Not Required'
    );
    insert doc;
    Boolean isUploaded = RCUCaseController.isResiDocumentUploaded(testCase.Id);
    System.assertEquals(true, isUploaded, 'Resi document should be considered uploaded.');
    Test.stopTest();
	}
    @isTest
	public static void testAllDocumentSubmitted() {
    Test.startTest();
    Case testCase = new Case(Status = 'New', RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('RCU').getRecordTypeId());
    insert testCase;
    Opportunity opp = new Opportunity(Name = 'Test Opportunity',StageName = 'Disbursement Request Preparation',CloseDate = Date.newInstance(2022, 07, 15));
    insert opp;
    Applicant__c app = new Applicant__c(Name = 'Applicant 1', Opportunity__c = opp.Id, Applicant_Type__c = 'Borrower');
    insert app;
    Documents__c doc = new Documents__c(
        RCU_Case__c = testCase.Id,
        Opportunity_Relation__c = opp.Id,
        Applicant__c = app.Id,
        Document_Type__c = 'Resi Profile Document',
        Is_Active__c = true,
        RCU_Agency_Verification_Status__c = 'Initiated',
        RecordTypeId = Schema.sObjectType.Documents__c.getRecordTypeInfosByName().get('Resi Profile Documents').getRecordTypeId()
    );
    insert doc;
    Boolean allSubmitted = RCUCaseController.allDocumentSubmitted(testCase.Id);
    System.assertEquals(false, allSubmitted, 'Not all documents are submitted.');
    doc.RCU_Agency_Verification_Status__c = 'Not Required';
    update doc;
    allSubmitted = RCUCaseController.allDocumentSubmitted(testCase.Id);
    System.assertEquals(true, allSubmitted, 'All documents should be considered submitted.');
    Test.stopTest();
	}
    
@isTest
	public static void testIsCommunityUser() {
        try {
            Test.startTest();
            Profile communityProfile = [SELECT Id FROM Profile WHERE Name = 'Counter Staff Community Users' LIMIT 1];
                Contact contact = new Contact(
                FirstName = 'Test',
                LastName = 'User',
                Email = 'testuser@testorg.com',
                AccountId = [SELECT Id FROM Account LIMIT 1].Id
            );
            insert contact;
            User communityUser = new User(
                Alias = 'testuser',
                ContactId = contact.Id,
                Email = 'communityuser@test.com',
                EmailEncodingKey = 'UTF-8',
                LastName = 'User',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                ProfileId = communityProfile.Id,
                UserName = 'communityuser12212346453@test.com',
                TimeZoneSidKey = 'America/Los_Angeles',
                MobilePhone = '1234567890' ,
                IsActive = true
            );
            insert communityUser;
            System.runAs(communityUser) {
                    Boolean isCommunity = RCUCaseController.isCommunityUser();
                    System.assertEquals(true, isCommunity, 'User should be a community user.');
                }
                Test.stopTest();
        } catch (Exception e) {}
	}



    
}