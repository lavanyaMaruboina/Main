@isTest
public class IND_RevokeController_Test {
    @testSetup 
    static void testDataSetup() 
    {
        //create user
        Profile p = [SELECT Id FROM Profile WHERE Name='IBL Business Executive'];
        User u = new User(Alias = 'standt2', Email='standarduser2@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,Maker_Id__c='12',IsActive = true,
                          TimeZoneSidKey='America/Los_Angeles',UserName='test_userprod123@indusbank.com.uat',
                          MobilePhone='8234567890',EmployeeNumber='IBL-1234');
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
            opp.Deal_Number__c = '100101'; 
            opp.AccountId = acc.Id;
            opp.Required_ROI__c = 9;
            opp.Sanction_Date__c = Date.newInstance(2022, 06, 11);
            opp.Product_Type__c =  system.label.TwoWheeler;
            opp.EMI_Amount__c = 10000;  
            opp.Agreement_Amount__c = 450000;
            opp.Documentation_Charges__c = '2000';
            opp.Applicant_Name__c = 'test';
            
            Opportunity opp2 = TestDataUtility.createTestOpportunityForOcr(false); 
            opp2.Sub_Stage__c = System.Label.Field_Investigation;
            opp2.Is_Mobile_Journey_Completed__c = true;
            opp2.Vehicle_Type__c = System.Label.used;
            opp2.Sanction_Status__c = System.Label.nonStp;  
            opp2.Agent_BL_code__c = 'AHZ';
            opp2.Deal_Number__c = '100101'; 
            opp2.AccountId = acc.Id;
            opp2.Required_ROI__c = 9;
            opp2.Sanction_Date__c = Date.newInstance(2022, 06, 11);
            opp2.Product_Type__c =  'Tractor';
            opp2.EMI_Amount__c = 10000;  
            opp2.Agreement_Amount__c = 450000;
            opp2.Documentation_Charges__c = '2000';
            opp2.Applicant_Name__c = 'test';
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
            
            Customer_Dedupe_Response__c customerDedupe1 = new Customer_Dedupe_Response__c();
            customerDedupe1.Applicant__c = applicantList[0].Id;
            insert customerDedupe1;
            
            String docKycRecordTypeId = Schema.getGlobalDescribe().get('Documents__c').getDescribe().getRecordTypeInfosByName().get('KYC Document').getRecordTypeId();
            
            ContentVersion content=new ContentVersion(); 
            content.Title='Header_Picture1'; 
            content.PathOnClient='/' + content.Title + '.jpg'; 
            Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion Body'); 
            content.VersionData=bodyBlob; 
            content.origin = 'H';
            insert content;
            
            List<Documents__c> documentsList = new List<Documents__c>();
            Documents__c document1 = new Documents__c();
            document1.IHM_receipt_number__c = '2324';
            document1.Name = 'test document';
            document1.IHM_receipt_date__c = Date.newInstance(2022, 06, 19); 
            document1.IHM_amount_as_per_receipt__c = 35700;
            document1.Opportunity_Relation__c = oppList[0].Id;
            //document1.Document_Type__c = 'Aadhaar';
            document1.is_Active__c = true;
            document1.KYC_State__c = 'MAHARASHTRA';
            document1.KYC_Address_Line_2__c = 'address2 MAHARASHTRA';
            document1.KYC_Address_Line_1__c = 'address1 MAHARASHTRA';
            document1.KYC_No__c = Integrationutilities.getencryptedrequest('TN2020090003150',System.Label.privateKey,System.Label.ivkey);
            document1.Passport_No__c = 'ABC324321'; 
            document1.Address_line_1_PR__c = 'test address 1PR';
            document1.Address_line_CR_2__c = 'test address 2';
            document1.Address_line_2_PR__c = 'test address 2PR';
            document1.KYC_Pin_Code__c = '11111';
            document1.KYC_DOB__c = Date.newInstance(2022, 06, 16);
            document1.PAN_No__c = 'B4226274';
            document1.RecordTypeId = docKycRecordTypeId;
            document1.Applicant__c = applicantList[0].Id;
            documentsList.add(document1);
            
            Documents__c document2 = new Documents__c();
            document2.IHM_receipt_number__c = '2324';
            document2.Name = 'test document';
            document2.IHM_receipt_date__c = Date.newInstance(2022, 06, 19); 
            document2.IHM_amount_as_per_receipt__c = 35700;
            document2.Opportunity_Relation__c = oppList[0].Id;
            //document2.Document_Type__c = 'IHM Receipt';
            document2.is_Active__c = true;
            document2.KYC_State__c = 'MAHARASHTRA';
            document2.KYC_Address_Line_2__c = 'address2 MAHARASHTRA';
            document2.KYC_Address_Line_1__c = 'address1 MAHARASHTRA';
            document2.KYC_No__c = Integrationutilities.getencryptedrequest('TN2020090003150',System.Label.privateKey,System.Label.ivkey);
            document2.Passport_No__c = 'ABC324321'; 
            document2.Address_line_1_PR__c = 'test address 1PR';
            document2.Address_line_CR_2__c = 'test address 2';
            document2.Address_line_2_PR__c = 'test address 2PR';
            document2.KYC_Pin_Code__c = '11111';
            document2.KYC_DOB__c = Date.newInstance(2022, 06, 16);
            document2.PAN_No__c = 'B4226274';
            document2.RecordTypeId = docKycRecordTypeId;
            document2.Applicant__c = applicantList[0].Id;
            documentsList.add(document2);
            
            Documents__c document3 = new Documents__c();
            document3.IHM_receipt_number__c = '2324';
            document3.Name = 'test document';
            document3.IHM_receipt_date__c = Date.newInstance(2022, 06, 19); 
            document3.IHM_amount_as_per_receipt__c = 35700;
            document3.Opportunity_Relation__c = oppList[0].Id;
            //document3.Document_Type__c = System.Label.PassportCard;
            document3.is_Active__c = true;
            document3.KYC_State__c = 'MAHARASHTRA';
            document3.KYC_Address_Line_2__c = 'address2 MAHARASHTRA';
            document3.KYC_Address_Line_1__c = 'address1 MAHARASHTRA';
            document3.KYC_No__c = Integrationutilities.getencryptedrequest('TN2020090003150',System.Label.privateKey,System.Label.ivkey);
            document3.Passport_No__c = 'ABC324321'; 
            document3.Address_line_1_PR__c = 'test address 1PR';
            document3.Address_line_CR_2__c = 'test address 2';
            document3.Address_line_2_PR__c = 'test address 2PR';
            document3.KYC_Pin_Code__c = '11111';
            document3.KYC_DOB__c = Date.newInstance(2022, 06, 16);
            document3.PAN_No__c = 'B4226274';
            document3.RecordTypeId = docKycRecordTypeId;
            document3.Applicant__c = applicantList[0].Id;
            documentsList.add(document3);
            
            Documents__c document4 = new Documents__c();
            document4.IHM_receipt_number__c = '2324';
            document4.Name = 'test document';
            document4.IHM_receipt_date__c = Date.newInstance(2022, 06, 19); 
            document4.IHM_amount_as_per_receipt__c = 35700;
            document4.Opportunity_Relation__c = oppList[0].Id;
            //document4.Document_Type__c = System.Label.PanCards;
            document4.is_Active__c = true;
            document4.KYC_State__c = 'MAHARASHTRA';
            document4.KYC_Address_Line_2__c = 'address2 MAHARASHTRA';
            document4.KYC_Address_Line_1__c = 'address1 MAHARASHTRA';
            document4.KYC_No__c = Integrationutilities.getencryptedrequest('TN2020090003150',System.Label.privateKey,System.Label.ivkey);
            document4.Passport_No__c = 'ABC324321'; 
            document4.Address_line_1_PR__c = 'test address 1PR';
            document4.Address_line_CR_2__c = 'test address 2';
            document4.Address_line_2_PR__c = 'test address 2PR';
            document4.KYC_Pin_Code__c = '11111';
            document4.KYC_DOB__c = Date.newInstance(2022, 06, 16);
            document4.PAN_No__c = 'B4226274';
            document4.RecordTypeId = docKycRecordTypeId;
            document4.Applicant__c = applicantList[0].Id;
            documentsList.add(document4);
            
            Documents__c document5 = new Documents__c();
            document5.IHM_receipt_number__c = '2324';
            document5.Name = 'test document';
            document5.IHM_receipt_date__c = Date.newInstance(2022, 06, 19); 
            document5.IHM_amount_as_per_receipt__c = 35700;
            document5.Opportunity_Relation__c = oppList[0].Id;
            //document5.Document_Type__c = System.Label.VoterIdCard;
            document5.is_Active__c = true;
            document5.KYC_State__c = 'MAHARASHTRA';
            document5.KYC_Address_Line_2__c = 'address2 MAHARASHTRA';
            document5.KYC_Address_Line_1__c = 'address1 MAHARASHTRA';
            document5.KYC_No__c = Integrationutilities.getencryptedrequest('TN2020090003150',System.Label.privateKey,System.Label.ivkey);
            document5.Passport_No__c = 'ABC324321'; 
            document5.Address_line_1_PR__c = 'test address 1PR';
            document5.Address_line_CR_2__c = 'test address 2';
            document5.Address_line_2_PR__c = 'test address 2PR';
            document5.KYC_Pin_Code__c = '11111';
            document5.KYC_DOB__c = Date.newInstance(2022, 06, 16);
            document5.PAN_No__c = 'B4226274';
            document5.RecordTypeId = docKycRecordTypeId;
            document5.Applicant__c = applicantList[0].Id;
            documentsList.add(document5);
            
            Documents__c document6 = new Documents__c();
            document6.IHM_receipt_number__c = '2324';
            document6.Name = 'test document';
            document6.IHM_receipt_date__c = Date.newInstance(2022, 06, 19); 
            document6.IHM_amount_as_per_receipt__c = 35700;
            document6.Opportunity_Relation__c = oppList[0].Id;
            //document6.Document_Type__c = 'Driving License';
            document6.is_Active__c = true;
            document6.KYC_State__c = 'MAHARASHTRA';
            document6.KYC_Address_Line_2__c = 'address2 MAHARASHTRA';
            document6.KYC_Address_Line_1__c = 'address1 MAHARASHTRA';
            document6.KYC_No__c = Integrationutilities.getencryptedrequest('TN2020090003150',System.Label.privateKey,System.Label.ivkey);
            document6.Passport_No__c = 'ABC324321'; 
            document6.Address_line_1_PR__c = 'test address 1PR';
            document6.Address_line_CR_2__c = 'test address 2';
            document6.Address_line_2_PR__c = 'test address 2PR';
            document6.KYC_Pin_Code__c = '11111';
            document6.KYC_DOB__c = Date.newInstance(2022, 06, 16);
            document6.PAN_No__c = 'B4226274';
            document6.RecordTypeId = docKycRecordTypeId;
            document6.Applicant__c = applicantList[0].Id;
            documentsList.add(document6);
            
            insert documentsList; 
            
            ContentDocumentLink contentlink = new ContentDocumentLink();
            contentlink.LinkedEntityId = documentsList[0].id;
            contentlink.contentdocumentid = [select contentdocumentid from contentversion where id =: content.id].contentdocumentid;
            contentlink.ShareType = 'I';
            contentlink.Visibility = 'AllUsers'; 
            insert contentlink;
            
            List<Vehicle_Detail__c> vehicleDetailList = new List<Vehicle_Detail__c>();
            Vehicle_Detail__c vehicleDetail = new Vehicle_Detail__c();
            vehicleDetail.Vehicle_Type__c = 'New';
            vehicleDetail.Finance_Amount__c = null;
            vehicleDetail.Eligible_Loan_Amount__c =  null;
            vehicleDetail.Dealer_Sub_dealer_name__c =  null;
            vehicleDetail.Vehicle_Registration_number__c =  null;
            vehicleDetail.Make__c =  null;
            vehicleDetail.Model__c =  null;
            vehicleDetail.Variant_Code__c =  null;
            vehicleDetail.Variant__c =  null;
            vehicleDetail.Ben_Code__c =  'testveh';
            vehicleDetail.Ins_Expiry_date__c =  null;
            vehicleDetail.Purpose_of_Purchase__c =  null;
            vehicleDetail.Variant__c = 'test variant';
            vehicleDetail.Make__c = 'Test make';
            vehicleDetail.Model__c = 'test Model';
            vehicleDetail.Dealer_Sub_dealer_name__c = 'test dealer';
            vehicleDetail.Engine_number__c = '443243432';
            vehicleDetail.Chassis_number__c = '543543422';
            vehicleDetail.Loan_Application__c = oppList[0].Id;
            vehicleDetailList.add(vehicleDetail);
            insert vehicleDetailList;
            
            List<Final_Term__c> finalTermList = new List<Final_Term__c>();
            Final_Term__c finalTerm = new Final_Term__c();
            finalTerm.Loan_Amount__c = '230000';
            finalTerm.Tenure__c = '3';
            finalTerm.Holiday_period__c  = '30';
            finalTerm.Advance_EMI__c = true;
            finalTerm.EMI_Amount__c = 23456;
            finalTerm.CRM_IRR__c = 545643 ;
            finalTerm.Service_charges__c = '553432';
            finalTerm.Documentation_charges__c = '545435';
            finalTerm.Stamping_charges__c = null;
            finalTerm.Installment_Type__c = 'Equated';
            finalTerm.Loan_Application__c = oppList[0].Id;
            finalTermList.add(finalTerm);
            
            insert finalTermList;
            
            Case caseObj1 = new Case();
            caseObj1.Status = 'Pending with Sales';
            caseObj1.Origin = 'Phone';
            caseObj1.Loan_Application__c = oppList[0].Id;
            caseObj1.RecordTypeId = (String) Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(System.Label.CMURequest).getRecordTypeId();
            insert caseObj1;
            
            Case caseObj2 = new Case();
            caseObj2.Status = 'New';
            caseObj2.Origin = 'Phone';
            caseObj2.Loan_Application__c = oppList[0].Id;
            caseObj2.RecordTypeId = (String) Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(System.Label.TVR).getRecordTypeId();
            insert caseObj2;
            
            Case caseObj3 = new Case();
            caseObj3.Status = 'Pending with Sales';
            caseObj3.Origin = 'Phone';
            caseObj3.Loan_Application__c = oppList[0].Id;
            //caseObj3.Product_Type__c='test';
            
            caseObj3.RecordTypeId = (String) Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('RCU').getRecordTypeId();
            insert caseObj3;
            
            Documents__c doc = new Documents__c();
            doc.Id = documentsList[0].id;
            doc.Case__c=Null;
            doc.RCU_Case__c = caseObj3.Id;
            update doc;
            
            
        }
    }
    
    @isTest
    public static void loanApplicationRevokeTest1(){
        try{
            String loanApplicationId = [Select id From Opportunity LIMIT 1].Id;
            List<Documents__c> doc = [select id from Documents__c];
            user u = [select id from user limit 1];
            String revokeType = 'General Revoke';
            IND_RevokeController.loanApplicationRevoke(loanApplicationId, revokeType, u.id ,new list<id>{doc[0].Id});
        }catch(Exception e){
            System.debug('Line 254' + e.getMessage());
        }
    }
    
    @isTest
    public static void loanApplicationRevokeTest(){
        try{
            Opportunity loanApplication = [Select id From Opportunity LIMIT 1];
            loanApplication.Revoke_Parent_Deal_Number__c = 'AF9C00754-01';
            update loanApplication;
            List<Documents__c> doc = [select id from Documents__c];
            user u = [select id from user limit 1];
            String revokeType = 'payandpayoutchanges';
            IND_RevokeController.loanApplicationRevoke(loanApplication.Id, revokeType, u.id ,new list<id>{doc[0].Id});
        }catch(Exception e){
            System.debug('Line 254' + e.getMessage());
        }
    }
    
    @isTest
    public static void loanApplicationRevokeTest2(){
        try{
            String loanApplicationId = [Select id From Opportunity LIMIT 1].Id;
            String revokeType = 'Add/Change Co-Borrower';
            List<Documents__c> doc = [select id from Documents__c];
            user u = [select id from user limit 1];
            IND_RevokeController.loanApplicationRevoke(loanApplicationId, revokeType, u.id ,new list<id>{doc[0].Id});
        }catch(Exception e){
            System.debug('Line 265' + e.getMessage());
        }
    }
    @isTest
    public static void loanApplicationRevokeTest3(){
        try{
            String loanApplicationId = [Select id From Opportunity LIMIT 1].Id;
            String revokeType ='removecoborroweraddcoborrower';
            List<Documents__c> doc = [select id from Documents__c];
            user u = [select id from user limit 1];
            IND_RevokeController.loanApplicationRevoke(loanApplicationId, revokeType, u.id ,new list<id>{doc[0].Id});
        }catch(Exception e){
            System.debug('Line 265' + e.getMessage());
        }
    } @isTest
    public static void loanApplicationRevokeTest4(){
        try{
            String loanApplicationId = [Select id From Opportunity LIMIT 1].Id;
            String revokeType = 'assetmodifications';
            List<Documents__c> doc = [select id from Documents__c];
            user u = [select id from user limit 1];
            IND_RevokeController.loanApplicationRevoke(loanApplicationId, revokeType, u.id ,new list<id>{doc[0].Id});
        }catch(Exception e){
            System.debug('Line 265' + e.getMessage());
        }
    }
    
    @isTest
    public static void loanApplicationRevokeTest5(){
        try{
            String loanApplicationId = [Select id From Opportunity LIMIT 1].Id;
            String revokeType = 'anyloaninformationchanges';
            List<Documents__c> doc = [select id from Documents__c];
            user u = [select id from user limit 1];
            IND_RevokeController.loanApplicationRevoke(loanApplicationId, revokeType, u.id ,new list<id>{doc[0].Id});
        }catch(Exception e){
            System.debug('Line 265' + e.getMessage());
        }
    }
    
    @isTest
    public static void loanApplicationRevokeTest6(){
        try{
            String loanApplicationId = [Select id From Opportunity LIMIT 1].Id;
            String revokeType = 'anyloaninformationchanges';
            List<Documents__c> doc = [select id from Documents__c];
            user u = [select id from user limit 1];
            IND_RevokeController.loanApplicationRevoke(loanApplicationId, revokeType, u.id ,new list<id>{doc[0].Id});
        }catch(Exception e){
            System.debug('Line 265' + e.getMessage());
        }
    }
    
     @isTest
    public static void loanApplicationRevokeTest7(){
        try{
            String loanApplicationId = [Select id From Opportunity LIMIT 1].Id;
            
            Applicant__c applicant1 = new Applicant__c();
            applicant1.Opportunity__c = loanApplicationId;
            applicant1.Insurance_Consent_Received__c = false;
            applicant1.Name = 'test name';
            applicant1.IsPrimary__c = true;
            applicant1.Applicant_Type__c = 'Borrower';
            applicant1.In_Active_Applicant__c = false;
            insert applicant1;
            
            String revokeType = 'D2C_Revoke';
            List<Documents__c> doc = [select id from Documents__c];
            
            Income_Details__c incomeRec = new Income_Details__c();
            incomeRec.Applicant__c = applicant1.Id;
            insert incomeRec;
            
            user u = [select id from user limit 1];
            IND_RevokeController.loanApplicationRevoke(loanApplicationId, revokeType, u.id ,new list<id>{doc[0].Id});
            IND_RevokeController.loanApplicationRevoke(null, 'test', null , null);
        }catch(Exception e){
            System.debug('Line 265' + e.getMessage());
        }
    }
    
      @isTest
    public static void loanApplicationRevokeTest8(){
        try{
            String loanApplicationId = [Select id From Opportunity LIMIT 1].Id;
            
            Applicant__c applicant1 = new Applicant__c();
            applicant1.Opportunity__c = loanApplicationId;
            applicant1.Insurance_Consent_Received__c = false;
            applicant1.Name = 'test name';
            applicant1.IsPrimary__c = true;
            applicant1.Applicant_Type__c = 'Borrower';
            applicant1.In_Active_Applicant__c = false;
            applicant1.CRIFF_Report_URL__c = 'https://cfdservice.indusind.com/CIBIL_CIR_IDV_Report/transunion/ViewCrifReport';
            insert applicant1;
            
            String revokeType = 'payandpayoutchanges';
            List<Documents__c> doc = [select id from Documents__c];
            
            Income_Details__c incomeRec = new Income_Details__c();
            incomeRec.Applicant__c = applicant1.Id;
            insert incomeRec;
            
            user u = [select id from user limit 1];
            IND_RevokeController.loanApplicationRevoke(loanApplicationId, revokeType, u.id ,new list<id>{doc[0].Id});
            IND_RevokeController.loanApplicationRevoke(null, 'test', null , null);
        }catch(Exception e){
            System.debug('Line 265' + e.getMessage());
        }
    }
  @isTest
    public static void loanApplicationRevokeTest9(){
        try{
            String loanApplicationId = [Select id From Opportunity LIMIT 1].Id;
            
            Applicant__c applicant1 = new Applicant__c();
            applicant1.Opportunity__c = loanApplicationId;
            applicant1.Insurance_Consent_Received__c = false;
            applicant1.Name = 'test name';
            applicant1.IsPrimary__c = true;
            applicant1.Applicant_Type__c = 'Borrower';
            applicant1.In_Active_Applicant__c = false;
            applicant1.Repayment_Will_Be_Done_By__c = 'test';
            insert applicant1;
            
            String revokeType = 'payandpayoutchanges';
            List<Documents__c> doc = [select id from Documents__c];
            
            Income_Details__c incomeRec = new Income_Details__c();
            incomeRec.Applicant__c = applicant1.Id;
            insert incomeRec;
            
            user u = [select id from user limit 1];
            IND_RevokeController.loanApplicationRevoke(loanApplicationId, revokeType, u.id ,new list<id>{doc[0].Id});
            IND_RevokeController.loanApplicationRevoke(null, 'test', null , null);
        }catch(Exception e){
            System.debug('Line 265' + e.getMessage());
        }
    }
    
    @isTest
    public static void updateClonedLoanApplicationOwner1(){
        try{
            Opportunity loanApplication = [Select id From Opportunity LIMIT 1];
            loanApplication.LeadSource = 'Digital-MSIL-Custom';
            update loanApplication;
            user u = [select id from user limit 1];
            IND_RevokeController.updateClonedLoanApplicationOwner(loanApplication.Id, loanApplication.Id, u.Id);
        }catch(Exception e){
            System.debug('Line 265' + e.getMessage());
        }
    }
    @isTest
    public static void updateClonedLoanApplicationOwner2(){
        try{
            Opportunity loanApplication = [Select id From Opportunity LIMIT 1];
            user u = [select id from user limit 1];
            IND_RevokeController.updateClonedLoanApplicationOwner(loanApplication.Id, loanApplication.Id, u.Id);
        }catch(Exception e){
            System.debug('Line 265' + e.getMessage());
        }
    }
    @isTest
    public static void isRevokedLoanApplication1(){
        try{
            String loanApplicationId = [Select id From Opportunity LIMIT 1].Id;
            IND_RevokeController.isRevokedLoanApplication(loanApplicationId);
        }catch(Exception e){
            System.debug('Line 265' + e.getMessage());
        }
    }
    @isTest
    public static void upsertRecordDetails1(){
        try{
            String loanApplicationId = [Select id From Opportunity LIMIT 1].Id;
            IND_RevokeController.upsertRecordDetails(loanApplicationId,'', 'Applicant__c');
        }catch(Exception e){
            System.debug('Line 265' + e.getMessage());
        }
    }
    @isTest
    public static void isPACTLMSIntegrationLogFailedTest(){
        
        opportunity loanApplication = [Select id,Product_Type__c From Opportunity LIMIT 1];
        loanApplication.Product_Type__c = 'Tractor';
        update loanApplication;
        
        Deal_Number_Setting__c dlNumberSetting= new Deal_Number_Setting__c();
        dlNumberSetting.Name = System.Label.Tractor;
        dlNumberSetting.MDNField1__c ='AB';
        dlNumberSetting.MDNField2__c =2;
        insert dlNumberSetting;
        
        
        Deal_Number__c dl=new Deal_Number__c();
        dl.Loan_Application__c = loanApplication.Id;
        dl.DNField1__c = dlNumberSetting.MDNField1__c;
        dl.DNField2__c = String.valueOf(dlNumberSetting.MDNField2__c);
        //dl.Sub_Stage__c = 'test';
        insert dl;
        
        Integration_Log__c intLog = new Integration_Log__c();
        intLog.Service_Name__c = 'PACT/LMS';
        intLog.Loan_Application__c = loanApplication.Id;
        intLog.targetRecordId__c = dl.Id;
        insert intLog;
        
        IND_RevokeController.isPACTLMSIntegrationLogFailed(loanApplication.Id, dl.Id);
        //IND_RevokeController.isPACTLMSIntegrationLogFailed(null, null);
        
    }
    
    @isTest
    public static void isPACTLMSIntegrationLogFailedTest1(){
        
        opportunity loanApplication = [Select id,Product_Type__c From Opportunity LIMIT 1];
        loanApplication.Product_Type__c = 'Tractor';
        update loanApplication;
        
        Deal_Number_Setting__c dlNumberSetting= new Deal_Number_Setting__c();
        dlNumberSetting.Name = System.Label.Tractor;
        dlNumberSetting.MDNField1__c ='AB';
        dlNumberSetting.MDNField2__c = 2.0;
        insert dlNumberSetting;
        
        
        Deal_Number__c dl=new Deal_Number__c();
        dl.Loan_Application__c = loanApplication.Id;
        dl.DNField1__c = dlNumberSetting.MDNField1__c;
        dl.DNField2__c = String.valueOf(dlNumberSetting.MDNField2__c.round());
        //dl.Sub_Stage__c = 'test';
        insert dl;        
        
        
        Integration_Log__c intLog = new Integration_Log__c();
        intLog.Service_Name__c = 'PACT/LMS';
        intLog.Loan_Application__c = loanApplication.Id;
        intLog.targetRecordId__c = dl.Id;
        insert intLog;
        
        IND_RevokeController.isPACTLMSIntegrationLogFailed(loanApplication.Id, dl.Id);
        //IND_RevokeController.isPACTLMSIntegrationLogFailed(null, null);
        
    }
    
   @isTest
    public static void getRCUDocumentsListTest(){
        String loanApplicationId = [Select id From Opportunity LIMIT 1].Id;
        
        Id recordTypeId = Schema.SObjectType.Documents__c.getRecordTypeInfosByName().get('DSA Documents').getRecordTypeId();
               
            
        List<Documents__c> doc = [SELECT Id,Name,Document_Type__c,Applicant_Type__c,RCU_Case__r.Loan_Application__c,RCU_Case__r.Loan_Application__r.Product_Type__c,RCU_Case__r.RecordType.Name,RCU_Case__c,RecordType.Name From Documents__c where RCU_Case__r.Loan_Application__c =:loanApplicationId AND Case__c = null AND RCU_Case__r.RecordType.Name = 'RCU'  And Is_Active__c=true ];
        System.debug('Document lISTTTTTT====>'+doc);
        List<Documents__c> updatedDocList=new List<Documents__c>();
        for(Documents__c docObj:doc){
            docObj.RecordTypeId=recordTypeId;
            updatedDocList.add(docObj);
        }
        update updatedDocList;
        // ContentDocumentLink conDocLink = [Select id from ContentDocumentLink limit 1];
        test.startTest();
        IND_RevokeController.getRCUDocumentsList(loanApplicationId);
        test.stopTest();
        
    }
    
    @isTest
    public static void getRCUDocumentsListTest1(){
        String loanApplicationId = [Select id From Opportunity LIMIT 1].Id;
        
        Id recordTypeId = Schema.SObjectType.Documents__c.getRecordTypeInfosByName().get('DSA Documents').getRecordTypeId();
               
            
        List<Documents__c> doc = [SELECT Id,Name,Document_Type__c,Applicant_Type__c,RCU_Case__r.Loan_Application__c,RCU_Case__r.Loan_Application__r.Product_Type__c,RCU_Case__r.RecordType.Name,RCU_Case__c,RecordType.Name From Documents__c where RCU_Case__r.Loan_Application__c =:loanApplicationId AND Case__c = null AND RCU_Case__r.RecordType.Name = 'RCU'  And Is_Active__c=true ];
        System.debug('Document lISTTTTTT====>'+doc);
        List<Documents__c> updatedDocList=new List<Documents__c>();
        for(Documents__c docObj:doc){
            docObj.RecordTypeId=recordTypeId;
            updatedDocList.add(docObj);
        }
        update updatedDocList;
        // ContentDocumentLink conDocLink = [Select id from ContentDocumentLink limit 1];
        test.startTest();
        IND_RevokeController.getRCUDocumentsList(Null);
        test.stopTest();
        
    }
    
    @isTest
    public static void cloneValuationReportsTest()
    {
        try{
            String loanApplicationId = [Select id From Opportunity LIMIT 1].Id;
            
            string veh = [select Id from Vehicle_Detail__c where Loan_Application__c =:loanApplicationId limit 1].Id;
            
            Asset_Verification__c s = new Asset_Verification__c();
            s.Name = 'test';
            s.Vehicle_Detail__c = veh;
            insert s;
            
            Applicant__c app = [select id,In_Active_Applicant__c from Applicant__c limit 1];
            app.In_Active_Applicant__c = false;
            update app;
            
            String docKycRecordTypeId = Schema.getGlobalDescribe().get('Documents__c').getDescribe().getRecordTypeInfosByName().get('Asset Verification Documents').getRecordTypeId();
            List<Documents__c> doc = [select id,RecordTypeId,Asset_Verification__c,Document_Type__c from Documents__c where Opportunity_Relation__c = :loanApplicationId limit 1];
            doc[0].RecordTypeId = docKycRecordTypeId;
            doc[0].Asset_Verification__c = s.Id;
            doc[0].Applicant__c = app.Id;
            doc[0].Document_Type__c = 'Valuation Report';
            update doc;
            
            IND_RevokeController.cloneValuationReports(loanApplicationId, loanApplicationId);
        }catch(Exception e){
            System.debug('Line 254' + e.getMessage());
        }
    }
    
    @isTest
    public static void isTractorLoanApplicationTest(){
        try{
            String loanApplicationId = [Select id From Opportunity LIMIT 1].Id;
            Test.startTest();
            String str = IND_RevokeController.isTractorLoanApplication(loanApplicationId);
            Test.stopTest();
            System.assertNotEquals(null,str);
        }
        catch(Exception e){
            System.debug('Exception : ' + e.getMessage());
        }
    }
    
    @isTest
    public static void isUserSelectionLookupRequiredOnRevokeTest(){
        try{
            
            String loanApplicationId = [Select id From Opportunity LIMIT 1].Id;
           /* List<Account> accList=[Select Id from Account];
            User userDetail=[Select Id,Name from User];
            AccountTeamMember atm = new AccountTeamMember(
        	AccountId = accList[0].Id,
            UserId = userDetail.Id,
            TeamMemberRole = 'BE'
        );
        insert atm;*/
            Test.startTest();
            String str = IND_RevokeController.isUserSelectionLookupRequiredOnRevoke(loanApplicationId);
            Test.stopTest();
            System.assertNotEquals(null,str);
        }
        catch(Exception e){
            System.debug('Exception : ' + e.getMessage());
        }
    }
    
     @isTest
    public static void isUserSelectionLookupRequiredOnRevokeTest1(){
        try{
            
            /*List<Opportunity> oppList = [SELECT Id, AccountId, Account.BranchBLCode__c, LeadSource, Product_Type__c, CreatedBy.Name, CreatedBy.EmployeeNumber, CreatedBy.IsActive
                                     FROM Opportunity
                                     WHERE Id = :loanApplicationId
                                     WITH SECURITY_ENFORCED
                                     LIMIT 1];
        if (oppList.size() > 0){
            List<AccountTeamMember> eligibleMemberList = [SELECT UserId FROM AccountTeamMember WHERE AccountId = :oppList[0].AccountId AND User.IsActive = true AND TeamMemberRole = 'MA'];//CISP-14306
            if(String.isBlank(oppList[0].LeadSource) && oppList[0].Product_Type__c == 'Two Wheeler' && oppList[0].CreatedBy.IsActive == false) {
                if(eligibleMemberList.size() > 0) {//CISP-14306
                    isUserSelectionNeeded = true;
                } else {//CISP-14306
                    mapData.put('ph1TWRevokeErr','BL Code ' +(String.isN*/
            List<Account> accList=[Select Id from Account];
            String loanApplicationId = [Select id From Opportunity LIMIT 1].Id;
            
            Opportunity opp = new Opportunity(); 
            opp.Sub_Stage__c = System.Label.Field_Investigation;
            opp.Is_Mobile_Journey_Completed__c = true;
            opp.LeadSource='';
            opp.CreatedBy.IsActive=false;
            opp.Vehicle_Type__c = System.Label.used;
            opp.Product_Type__c = System.Label.PassengerVehicles;
            opp.Sanction_Status__c = System.Label.nonStp;  
            opp.Agent_BL_code__c = 'AHZ';
            opp.Deal_Number__c = '100101'; 
            opp.AccountId = accList[0].Id;
            opp.Required_ROI__c = 9;
            opp.Sanction_Date__c = Date.newInstance(2022, 06, 11);
            opp.Product_Type__c =  system.label.TwoWheeler;
            opp.EMI_Amount__c = 10000;  
            opp.Agreement_Amount__c = 450000;
            opp.Documentation_Charges__c = '2000';
            opp.Applicant_Name__c = 'test';
            
            insert opp;
            User userDetail=[Select Id,Name from User];
            AccountTeamMember atm = new AccountTeamMember(
        	AccountId = accList[0].Id,
            UserId = userDetail.Id,
            TeamMemberRole = 'BE'
        );
        insert atm;
            Test.startTest();
            String str = IND_RevokeController.isUserSelectionLookupRequiredOnRevoke(opp.Id);
            Test.stopTest();
            System.assertNotEquals(null,str);
        }
        catch(Exception e){
            System.debug('Exception : ' + e.getMessage());
        }
    }
    
    
    @isTest
    public static void getEligibleUsersForRevokedApplicationTest(){
        try{
            Account acc= [SELECT Id FROM Account WHERE Name='test account' LIMIT 1];
            Test.startTest();
            List<sObject> sObj = IND_RevokeController.getEligibleUsersForRevokedApplication(acc.Id,'IBL-1234');
            Test.stopTest();
            System.assertEquals(0,sObj.size());
        }
        catch(Exception e){
            System.debug('Exception : ' + e.getMessage());
        }
    }
    
    @isTest
    public static void sendCustomNotificationTest(){
        try{
            Case caseObj = [Select id,CaseNumber,OwnerId From Case LIMIT 1];
            IND_RevokeController.CustomNotificationWrapper customCaseNotification = new IND_RevokeController.CustomNotificationWrapper();
            customCaseNotification.caseId = caseObj.Id;
            customCaseNotification.notificationTitle = 'Case Assignment';
            customCaseNotification.notificationBody = 'Case ' + caseObj.CaseNumber + ' has been assigned to you.';
            customCaseNotification.ownerId = caseObj.OwnerId;
            Test.startTest();
            IND_RevokeController.sendCustomNotification(customCaseNotification);
            Test.stopTest();
            
        }catch(Exception e){
            System.debug('Exception : ' + e.getMessage());
        }
    }
    
    @isTest
    public static void upsertRecordDetailsTest(){
        try{
            String loanApplicationId = [Select id From Opportunity LIMIT 1].Id;
            Test.startTest();
            IND_RevokeController.upsertRecordDetails(loanApplicationId, 'Cibil_Decision__c', 'CIBIL_Details__c');
            Test.stopTest();
        }catch(Exception e){
            System.debug('Exception : ' + e.getMessage());
        }
    }
    
    @isTest
    static void testCopyClosedFICases() {
        try{
            Opportunity oldOpportunity = [Select id From Opportunity LIMIT 1];
            Opportunity newOpportunity = [Select id From Opportunity WHERE Product_Type__c =  'Tractor' LIMIT 1];
            Case cs = [SELECT Id,Status FROM Case WHERE Loan_Application__c =:oldOpportunity.Id LIMIT 1];
            cs.status = 'Completed';
            cs.Subject = 'This Record is_only_for Testing...';
            cs.Loan_Application__c = oldOpportunity.Id;
            cs.RecordTypeId = [SELECT id from RecordType where DeveloperName = 'FI'].Id;
            update cs;
            Applicant__c applicant = TestDataUtility.createTestApplicantService(false,oldOpportunity);
            applicant.Applicant_Type__c = 'Guarantor';
            insert applicant;
            Map<Id,Applicant__c> newApplicantMap =New Map<Id,Applicant__c>();
            newApplicantMap.put(applicant.Id,applicant);
            Field_Investigation__c Fi= TestDataUtility.createTestFieldInvestigation(true, cs);
            Case caseObj2 = new Case();
            caseObj2.Status = 'Accepted';
            caseObj2.Origin = 'Phone';
            caseObj2.Loan_Application__c = oldOpportunity.Id;
            caseObj2.Subject = 'This Record is only for Testing...';
            caseObj2.RecordTypeId =  [SELECT id from RecordType where DeveloperName = 'Asset_Verification'].Id;
            insert caseObj2;
            Asset_Verification__c s = new Asset_Verification__c();
            s.Name = 'test';
            s.Case__c = caseObj2.Id;
            insert s;
            Test.startTest();
            IND_RevokeController.copyClosedFICases(oldOpportunity.Id, newOpportunity.Id,'payandpayoutchanges',newApplicantMap);
            Test.stopTest();
            System.assertNotEquals(null, [SELECT id FROM Case WHERE Loan_Application__c = :newOpportunity.Id]);
        }catch(Exception e){
            System.debug('Exception : ' + e.getMessage());
        }
    }
    
    @isTest
    public static void testcloneValuationReports(){
        try{
            Opportunity oldOpportunity = TestDataUtility.createTestLoanApplication(true);
            Opportunity newOpportunity = TestDataUtility.createTestLoanApplication(true);
            Applicant__c applicant = TestDataUtility.createTestApplicantService(false,oldOpportunity);
            applicant.Applicant_Type__c = 'Guarantor';
            insert applicant;
            Map<Id,Applicant__c> newApplicantMap =New Map<Id,Applicant__c>();
            newApplicantMap.put(applicant.Id,applicant);
            Documents__c doc = TestDataUtility.createTestDLDocs1(false, applicant, oldOpportunity);
            doc.Document_Type__c = 'Valuation Report';
            doc.Is_Active__c = true;
            insert doc;
            Test.startTest();
            IND_RevokeController.cloneValuationReports(oldOpportunity.Id,newOpportunity.Id);
            IND_RevokeController.cloneCustomerDedpue(newOpportunity.Id,oldOpportunity.Id,newApplicantMap);
            Test.stopTest();
            System.assertNotEquals(null, [SELECT id FROM Case WHERE Loan_Application__c = :newOpportunity.Id]);
        }catch(Exception e){
            System.debug('Exception : ' + e.getMessage());
        }
    }
    
    @isTest
    public static void testCloneRCUCase(){
        try{
            Opportunity oldOpportunity = [Select id From Opportunity LIMIT 1];
            Opportunity newOpportunity = [Select id From Opportunity LIMIT 1];
            OpportunityTeamMember otm =New OpportunityTeamMember();
            otm.OpportunityId=oldOpportunity.Id;
            otm.UserId = [SELECT Id FROM User WHERE Email='standarduser2@testorg.com' LIMIT 1].Id;
            insert otm;
            Applicant__c applicant = TestDataUtility.createTestApplicantService(true,oldOpportunity);
            Map<Id,Applicant__c> newApplicantMap =New Map<Id,Applicant__c>();
            newApplicantMap.put(applicant.Id,applicant);
            List<Case> cases = [SELECT Id,RCU_Agent__c FROM Case LIMIT 1];
            if(cases.size()!=0){
                cases[0].RCU_Agent__c =  [SELECT Id FROM User WHERE Email='standarduser2@testorg.com' LIMIT 1].Id;
                cases[0].Loan_Application__c = oldOpportunity.Id;
                cases[0].ParentId = null;
                cases[0].RecordTypeId = (String) Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('RCU').getRecordTypeId();
                update cases;
            }
            Case caseObj1 = new Case();
            caseObj1.Status = 'Pending with Sales';
            caseObj1.Origin = 'Phone';
            caseObj1.Loan_Application__c = oldOpportunity.Id;
            caseObj1.ParentId =cases[0].Id;
            insert caseObj1;
            Documents__c doc = TestDataUtility.createTestDLDocs1(false, applicant, oldOpportunity);
            doc.Case__c = cases[0].Id;
            doc.is_Active__c = true;
            doc.RCU_Case__c = cases[0].Id;
            insert doc;
            CIBIL_Details__c cibilRec = TestDataUtility.createCIBILDetails(true,applicant);
            Customer_Reference__c cr =New Customer_Reference__c(Applicant__c = applicant.Id,Loan_Application__c = oldOpportunity.Id);
            insert cr;
            Test.startTest();
            IND_RevokeController.cloneCMUCase(oldOpportunity.Id,newOpportunity.Id,System.Label.CMURequest,'removecoborroweraddcoborrower');
            IND_RevokeController.getCurrentOppRecord(newOpportunity.Id);
            IND_RevokeController.cloneCibil(newOpportunity.Id,oldOpportunity.Id,newApplicantMap);
            IND_RevokeController.cloneReference(newOpportunity.Id,oldOpportunity.Id,newApplicantMap);
            IND_RevokeController.cloneRCUCase(oldOpportunity.Id,newOpportunity.Id,'RCU',New List<Id>(),newApplicantMap);
            Test.stopTest();
            System.assertNotEquals(null, [SELECT id FROM Case WHERE Loan_Application__c = :newOpportunity.Id]);
        }catch(Exception e){
            System.debug('Exception : ' + e.getMessage());
        }
    }
    
   
    
}