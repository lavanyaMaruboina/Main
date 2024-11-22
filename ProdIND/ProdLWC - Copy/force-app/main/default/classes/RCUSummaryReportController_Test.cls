@isTest
public class RCUSummaryReportController_Test {
	@TestSetup static void rcuData() {
        Integer ranNum2 = Integer.valueOf(Math.Random() * 10);
		Profile p1 = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u = new User(Alias = 'standt21', Email='standarduser21@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing1'+ranNum2, LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p1.Id,Maker_Id__c='123',IsActive = true,
                          TimeZoneSidKey='America/Los_Angeles',UserName='test_user1@indusbank.com.uat',MobilePhone = '9089078967');
        insert u;
        System.runAs(u) 
        {
            Opportunity opp = TestDataUtility.createTestOpportunityForOcr(false);
            opp.Sub_Stage__c = System.Label.Field_Investigation;
            opp.StageName = 'Post Sanction Checks and Documentation';
            opp.Is_Mobile_Journey_Completed__c = true;
            opp.Vehicle_Type__c = System.Label.used;
            opp.Product_Type__c = System.Label.TwoWheeler;
            opp.Sanction_Status__c = System.Label.nonStp;
            insert opp;   
            
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
            
            Id rcuRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('RCU').getRecordTypeId();
            case objCase = new case();
            objCase.OwnerId = u.Id;
            objCase.Status = 'Pass';
            objCase.Subject = opp.Name+'_RCU';
            objCase.Origin='Email';
            objCase.RecordTypeId = rcuRecordTypeId;
            objCase.Loan_Application__c = opp.Id;
            objCase.Applicant__c = applicantList[0].Id;
            objCase.Overall_RCU_Agency_Verification_Remarks__c ='test';
            //objCase.Overall_RCU_Verification_Status__c ='test';
           // objCase.Overall_RCU_Agency_Verification_Status__c = 'Positive';
            //objCase.Overall_RCU_Verification_Status__c ='Positive';
            insert objCase;
            
            Income_Details__c in1 = TestDataUtility.createTestIncomeDetails(false);
            in1.Applicant__c = applicantList[0].Id;
            in1.Salaried_Self_employed__c = 'Salaried';
            in1.Office_State__c = 'MAHARASHTRA';
            in1.Is_Salaried__c = true;
            in1.Is_Income_Credited_In_Bank_Account__c = true;
            in1.Client_Transaction_Id__c = 'test123';
            in1.Perfios_Transaction_Id__c = 'sample123';
            in1.Do_You_File_ITR__c = true;
            in1.Income__c = 100000;
            in1.Income_from_Perfios__c = 50000;
            in1.Remarks__c = 'nocomments';
            in1.Primary_Income_Source__c = true;
            insert in1;
            
            Documents__c doc1 = TestDataUtility.createTestKYCDocsForOcrFront(false, applicant1, opp);
            doc1.Document_Type__c = 'Agreement Copy';
            doc1.Addresss_Type__c = System.Label.Document_Office_Address_Type;
            doc1.Is_Active__c = true;
            doc1.Name = 'IHM Receipt';
            doc1.Aadhar_Source__c = 'OTP';
            doc1.RCU_Case__c =objCase.Id;
            doc1.Opportunity_Relation__c = opp.Id;
            //doc1.RCU_Agency_Verification_Status__c = 'Sampled';
           // doc1.RCU_Agency_Verification_Sub_Status__c ='Positive';
            insert doc1;
            
            ContentVersion contVer1 = TestDataUtility.createContentVersionforOcrFront('Test document for content version',true, doc1);
        }
	}
    @isTest
    public static void testRCUReportGeneration(){
        Case caseObj = [SELECT Id from Case where Status = 'Pass' ];
        RCUSummaryReportController.RCUSummaryWrapper rcuData = RCUSummaryReportController.getRCUSummary(caseObj.Id);
    }
    @isTest
    public static void testPdfGeneration(){
        Case caseObj = [SELECT Id from Case where Status = 'Pass' ];
        list<string> pageStrings = RCUSummaryReportController.getPDFprint(caseObj.Id);
    }
    
    @isTest
    public static void getAllRCUDocsTest(){
        Opportunity opp = [select id from Opportunity limit 1];
        Documents__c doc = [select id,Opportunity_Relation__c, Document_Type__c from Documents__c limit 1];
        doc.Document_Type__c = Label.AadhaarCard;
        update doc;
        
        Test.startTest();
        RCUSummaryReportController.getAllRCUDocs(opp.Id);
        
        doc.Document_Type__c = Label.VoterIdCard;
        update doc;
        RCUSummaryReportController.getAllRCUDocs(opp.Id);
        
        doc.Document_Type__c = Label.PassportCard;
        update doc;
        RCUSummaryReportController.getAllRCUDocs(opp.Id);
        
        doc.Document_Type__c = Label.DrivingLicences;
        update doc;
        RCUSummaryReportController.getAllRCUDocs(opp.Id);
        
        doc.Document_Type__c = Label.Telephone_bill;
        update doc;
        RCUSummaryReportController.getAllRCUDocs(opp.Id);
        
        Test.stopTest();
    }
}