@isTest
public class CAMControllerTest {
    @testSetup
    public static void testSetup(){
        List<User> runningUser = [SELECT Id,Name,Profile.Name FROM User WHERE Id=:UserInfo.getUserId()];
        //create user
        Profile p = [SELECT Id FROM Profile WHERE Name='IBL Business Executive'];
        User u = new User(Alias = 'standt2', Email='standarduser2@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,Maker_Id__c='12',IsActive = true,
                          TimeZoneSidKey='America/Los_Angeles',UserName='test_userprod12390@indusbank.com',MobilePhone = '9089078967');
        insert u;

        System.runAs(u) 
        {
            Opportunity opgr1 = new Opportunity();
            opgr1.StageName = 'Qualification';
            opgr1.CloseDate = Date.newInstance(2021, 1, 11);
            opgr1.Name = 'testone';
            opgr1.Product_Type__c = 'Tractor';
            insert opgr1;
            
            Applicant__c apgr1 = new Applicant__c();
            apgr1.Opportunity__c = opgr1.Id;
            apgr1.Contact_number__c = '9743514830';
            apgr1.Applicant_Type__c = 'Borrower';
            apgr1.Total_Insurance_Payable__c = 200000;
            insert apgr1;
            
            CAM__c cam1 = new CAM__c();
            cam1.Active__c = true;
            cam1.Loan_Application__c = opgr1.Id;
            cam1.CAM_Conditional_approval_remarks__c = 'Test approval remark';
            cam1.CAM_conditional_approval_requirement__c = 'Yes';
            insert cam1;
            
            CIBIL_Details__c cDetail = new CIBIL_Details__c();
            cDetail.CIC_No__c = 'Test CIC';
            cDetail.Score__c = 'Test score';
            cDetail.CIBIL_Report_URl__c = 'Test URL';
            cDetail.Maker_Date__c = Date.newInstance(2022, 05, 19);
            cDetail.Equifax_Report_URl__c = 'Test equi URL';
            cDetail.Applicant__c = apgr1.Id;
            insert cDetail;
            
            
            Documents__c doc = new Documents__c();
            doc.Name = 'Test document';
            doc.Document_Type__c = 'PAN';
            doc.Document_Side__c = 'Front';
            doc.Age__c = 30;
            doc.KYC_DOB__c = Date.newInstance(1993, 05, 05);
            doc.PAN_No__c = 'testpan';
            doc.KYC_name__c = 'Test KYC Name';
            doc.KYC_No__c = Integrationutilities.getencryptedrequest('TN2020090003150',System.Label.privateKey,System.Label.ivkey);
            doc.KYC_Issuance_Date__c = Date.newInstance(2022, 05, 20);
            doc.Proof_of_Address_POA__c = true;
            doc.Proof_of_Identity_POI__c = true;
            doc.Opportunity_Relation__c = opgr1.Id;
            doc.Applicant__c = apgr1.Id;
            insert doc;
            
            InsuranceDetails__c iDetail = new InsuranceDetails__c();
            iDetail.Applicant__c = apgr1.Id;
            iDetail.Loan_Application__c = opgr1.Id;
            iDetail.Name = 'Test Insurance';
            iDetail.Product_Type__c = 'test pro';
            iDetail.Amount__c = 20000;
            iDetail.Funded_Premium__c = 2000;
            iDetail.Funded_Non_funded__c = 'Non-Funded';
            insert iDetail;
            
            Existing_EMI__c emi = new Existing_EMI__c();
            emi.Applicant_Id__c = apgr1.Id;
            emi.EMI__c = 2000.00;
            insert emi;
            
            Deal_Number__c dealNumber = TestDataUtility.createDealNumber(true,opgr1);
            
            Loan_Application_Transaction_History__c lATH = new Loan_Application_Transaction_History__c();
            lATH.Loan_Application_ID__c = opgr1.Id;
            lATH.Submitted_Flag__c = False;
            lATH.Screen__c = 'CAM and Conditional Approval';
            lATH.Module__c = 'Pre Disbursement Check';
            lATH.Deal_Number__c = dealNumber.Id;
            insert lATH;
            
            Deviation__c d1 = new Deviation__c();
            d1.Parent_CAM__c = cam1.Id;
            insert d1;
            
            Proposal_Approval_Log__c pa1 = new Proposal_Approval_Log__c();
            pa1.Parent_CAM__c = cam1.Id;
            pa1.Deviation_Id__c = d1.Id;
            pa1.Role__c = 'SCM';
            insert pa1;
            
        }

        Profile p1 = [SELECT Id FROM Profile WHERE Name='Platform Event Profile'];
        User u1 = new User(Alias = 'standt2', Email='standarduser2@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='platformUser', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p1.Id,Maker_Id__c='12',IsActive = true,
                          TimeZoneSidKey='America/Los_Angeles',UserName='platformUser@indusbank.com',MobilePhone = '9089078967');
        insert u1;
        System.runAs(u) 
        {
            Opportunity opgr2 = new Opportunity();
            opgr2.StageName = 'Qualification';
            opgr2.CloseDate = Date.newInstance(2021, 1, 11);
            opgr2.Name = 'testtwo';
            opgr2.Product_Type__c = 'Tractor';
            insert opgr2;

            Deal_Number__c dealNumber1 = TestDataUtility.createDealNumber(true,opgr2);
        }
    }
    
    
    @isTest 
    public static void getRelatedCAM_Positive()
    {
        // Arrange 
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod12390@indusbank.com' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
            Deal_Number__c dealNum = [SELECT Id FROM Deal_Number__c LIMIT 1];
            //Act
            Test.startTest();
            CAMController.DataWrapper canWrap = CAMController.getRelatedCAM(opp.Id, dealNum.Id);
            Test.stopTest();
            // Assert
            System.assert(canWrap!= null);
            
        }
    } 
    
    @isTest 
    public static void getRelatedCAM_Negative()
    {
        // Arrange 
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod12390@indusbank.com' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
            //Act
            Test.startTest();
            CAMController.DataWrapper canWrap = CAMController.getRelatedCAM(null,null);
            Test.stopTest();
            // Assert
            System.assertEquals(null,canWrap);
        }

    } 
    
    @isTest
    public static void updateCAM_Positive()
    {
        // Arrange
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod12390@indusbank.com' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
            Deal_Number__c dealNum = [SELECT Id FROM Deal_Number__c LIMIT 1];
            CAM__c cam = [SELECT Id FROM CAM__c LIMIT 1];
            // Act
            Test.startTest();
            Boolean dataVar = CAMController.updateCAM(cam.Id,'Yes','test remark',opp.Id, dealNum.Id);
            Test.stopTest();
            // Assert
            System.assertEquals(true, dataVar);
        }
    }
    
    @isTest
    public static void updateCAM_Negative()
    {
        // Arrange
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod12390@indusbank.com' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            // Act
            Test.startTest();
            Boolean dataVar = CAMController.updateCAM(null, null, null, null, null);
            Test.stopTest();
            //Assert
            System.assertEquals(false, dataVar);
        }


    }
}