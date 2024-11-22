@isTest
public class IND_GetFinalOfferDetailsTestClass {    
    @testSetup 
    static void testDataSetup() 
    {
        //create user
        Profile p = [SELECT Id FROM Profile WHERE Name='IBL Business Executive'];
        User u = new User(Alias = 'standt2', Email='standarduser2@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,Maker_Id__c='12',IsActive = true,
                          TimeZoneSidKey='America/Los_Angeles',UserName='test_userprod123@indusbank.com.uat',MobilePhone = '9089078967');
        insert u;
        System.runAs(u) 
        {
            // Create Opportunity
            Opportunity oppObj = TestDataUtility.createTestLoanApplication(false);
            oppObj.Sanction_Status__c = 'STP';
            oppObj.AML_Check_status__c = System.Label.Approved; 
            oppObj.AML_Check_Completed__c = true;
            oppObj.StageName = 'Qualification';
            oppObj.Sub_Stage__c = 'Final Terms';
            oppObj.CloseDate = Date.newInstance(2021, 1, 11);
            oppObj.Name = 'testone';
            oppObj.Applicant_Name__c = 'Test';
            oppObj.Consent_Received__c = true;
            oppObj.Contact_number__c = '1234567890';
            oppObj.Make__c = 'Make Test';
            oppObj.Model__c = 'Test Model';
            oppObj.Variant__c = 'TestV';
            oppObj.Loan_amount__c = '1234';
            oppObj.Sanction_Message_Triggered__c = true;

            insert oppObj;
            
            //Applicant of type of borrower
            Applicant__c applicant1 = TestDataUtility.createTestApplicant(false);
            applicant1.Opportunity__c = oppObj.Id;
            applicant1.Applicant_Type__c = 'Borrower';
            applicant1.Consent_Received__c = true;
            applicant1.PAN_CIN_Match__c = false;
            applicant1.FaceMismatch__c = false;
            applicant1.Check_Eligibility_Match__c = true;
            applicant1.Bureau_Pull_Match__c = true;
			applicant1.Insurance_Consent_Received__c = true;
            applicant1.Application_Consent_Received__c = true;
            applicant1.Customer_Qualification__c = 'B1';
            applicant1.Marital_status__c = 'MARR';
            
            insert applicant1; 
            
            //Applicant of type of borrower
            Applicant__c applicant2 = TestDataUtility.createTestApplicant(false);
            applicant2.Opportunity__c = oppObj.Id;
            applicant2.Applicant_Type__c = System.label.Coborrower;
            applicant2.Consent_Received__c = true;
            applicant2.PAN_CIN_Match__c = false;
            applicant2.FaceMismatch__c = false;
            applicant2.Check_Eligibility_Match__c = true;
            applicant2.Bureau_Pull_Match__c = true;
			applicant2.Insurance_Consent_Received__c = true;
            applicant2.Application_Consent_Received__c = true;
            applicant2.Customer_Qualification__c = 'B1';
            applicant2.Marital_status__c = 'MARR';
            
            insert applicant2;
            
            //create Vehicle_Detail__c record
            List<Vehicle_Detail__c> vdList = new List<Vehicle_Detail__c>();
            Vehicle_Detail__c  vehicleDetail = TestDataUtility.createTestVehicleDetailForIbb(false, oppObj);
            vdList.add(vehicleDetail);
            if (Schema.sObjectType.Vehicle_Detail__c.isCreateable()){
                insert vdList;
            }
            
            //Final term record
            Final_Term__c finalTermObj = new Final_Term__c();
            finalTermObj.Loan_Application__c = oppObj.Id;
            finalTermObj.is_Active__c = true;
            finalTermObj.Tenure__c = '1234';
            finalTermObj.CRM_IRR__c = 34;
            finalTermObj.EMI_Amount__c = 76;
			finalTermObj.Loan_amount__c = '76';

            insert finalTermObj;
            
            String tvrRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('TVR').getRecordTypeId();
            String amlRecordTypeId = (String) Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(System.Label.AML_Check).getRecordTypeId();
            String cmuRecordTypeId = (String) Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(System.Label.CMURequest).getRecordTypeId();
            Case case1 = TestDataUtility.createTestCase(false, oppObj, applicant1);
            case1.Status = 'Pass';
            case1.RecordTypeId = tvrRecordTypeId;
            insert case1; 
            
            TeleVerification__c tvrRec = new TeleVerification__c();
            tvrRec.Case__c = case1.Id;
            tvrRec.Loan_Application__c = oppObj.Id;
            insert tvrRec;
            
            Case case2 = TestDataUtility.createTestCase(false, oppObj, applicant1);
            case2.Status = System.Label.Completed;
            case2.RecordTypeId = amlRecordTypeId;
            insert case2;
            
            Case case3 = TestDataUtility.createTestCase(false, oppObj, applicant1);
            case3.Status = 'Closed';
            case3.RecordTypeId = cmuRecordTypeId;
            insert case3;
            
            CAM__c cam1 = new CAM__c();
            cam1.Proposal_Status__c = 'Accept';
            cam1.Loan_Application__c = oppObj.Id;
            insert cam1;
            
            
            
            String docKycRecordTypeId = Schema.getGlobalDescribe().get('Documents__c').getDescribe().getRecordTypeInfosByName().get('KYC Document').getRecordTypeId();
            
            List<Documents__c> documentsList = new List<Documents__c>();
            Documents__c document1 = new Documents__c();
            document1.IHM_receipt_number__c = '2324';
            document1.Name = 'test document';
            document1.IHM_receipt_date__c = Date.newInstance(2022, 06, 19); 
            document1.IHM_amount_as_per_receipt__c = 35700;
            document1.Opportunity_Relation__c = oppObj.Id;
            document1.Document_Type__c = System.Label.AadhaarCard;
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
            document1.Applicant__c = applicant1.Id;
            document1.Proof_of_Address_POA__c = true;
            document1.Proof_of_Identity_POI__c = true;
            document1.Is_this_a_Photocopy__c = false;
            document1.Case__c = case3.Id;
            document1.CMU_Accept_Reject__c =  'Accept';
            documentsList.add(document1);

            Documents__c document2 = new Documents__c();
            document2.IHM_receipt_number__c = '2324';
            document2.Name = 'test document';
            document2.IHM_receipt_date__c = Date.newInstance(2022, 06, 19); 
            document2.IHM_amount_as_per_receipt__c = 35700;
            document2.Opportunity_Relation__c = oppObj.Id;
            document2.Document_Type__c = 'IHM Receipt';
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
            document2.Applicant__c = applicant1.Id;
            documentsList.add(document2);

            Documents__c document3 = new Documents__c();
            document3.IHM_receipt_number__c = '2324';
            document3.Name = 'test document';
            document3.IHM_receipt_date__c = Date.newInstance(2022, 06, 19); 
            document3.IHM_amount_as_per_receipt__c = 35700;
            document3.Opportunity_Relation__c = oppObj.Id;
            document3.Document_Type__c = System.Label.PassportCard;
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
            document3.Applicant__c = applicant1.Id;
            documentsList.add(document3);

            Documents__c document4 = new Documents__c();
            document4.IHM_receipt_number__c = '2324';
            document4.Name = 'test document';
            document4.IHM_receipt_date__c = Date.newInstance(2022, 06, 19); 
            document4.IHM_amount_as_per_receipt__c = 35700;
            document4.Opportunity_Relation__c = oppObj.Id;
            document4.Document_Type__c = System.Label.PanCards;
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
            document4.Applicant__c = applicant1.Id;
            document4.Is_this_a_Photocopy__c = false;
            documentsList.add(document4);

            Documents__c document5 = new Documents__c();
            document5.IHM_receipt_number__c = '2324';
            document5.Name = 'test document';
            document5.IHM_receipt_date__c = Date.newInstance(2022, 06, 19); 
            document5.IHM_amount_as_per_receipt__c = 35700;
            document5.Opportunity_Relation__c = oppObj.Id;
            document5.Document_Type__c = System.Label.Form60DocumentType;
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
            document5.Applicant__c = applicant1.Id;
            documentsList.add(document5);

            Documents__c document6 = new Documents__c();
            document6.IHM_receipt_number__c = '2324';
            document6.Name = 'test document';
            document6.IHM_receipt_date__c = Date.newInstance(2022, 06, 19); 
            document6.IHM_amount_as_per_receipt__c = 35700;
            document6.Opportunity_Relation__c = oppObj.Id;
            document6.Document_Type__c = System.Label.Form60DocumentType;
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
            document6.Applicant__c = applicant1.Id;
            document6.Is_this_a_Photocopy__c = false;
            documentsList.add(document6);
            
            Documents__c document11 = new Documents__c();
            document11.IHM_receipt_number__c = '2324';
            document11.Name = 'test document';
            document11.IHM_receipt_date__c = Date.newInstance(2022, 06, 19); 
            document11.IHM_amount_as_per_receipt__c = 35700;
            document11.Opportunity_Relation__c = oppObj.Id;
            document11.Document_Type__c = System.Label.AadhaarCard;
            document11.is_Active__c = true;
            document11.KYC_State__c = 'MAHARASHTRA';
            document11.KYC_Address_Line_2__c = 'address2 MAHARASHTRA';
            document11.KYC_Address_Line_1__c = 'address1 MAHARASHTRA';
            document11.KYC_No__c = Integrationutilities.getencryptedrequest('TN2020090003150',System.Label.privateKey,System.Label.ivkey);
            document11.Passport_No__c = 'ABC324321'; 
            document11.Address_line_1_PR__c = 'test address 1PR';
            document11.Address_line_CR_2__c = 'test address 2';
            document11.Address_line_2_PR__c = 'test address 2PR';
            document11.KYC_Pin_Code__c = '11111';
            document11.KYC_DOB__c = Date.newInstance(2022, 06, 16);
            document11.PAN_No__c = 'B4226274';
            document11.RecordTypeId = docKycRecordTypeId;
            document11.Applicant__c = applicant2.Id;
            document11.Proof_of_Address_POA__c = true;
            document11.Proof_of_Identity_POI__c = true;
            document11.Is_this_a_Photocopy__c = false;
            document11.Case__c = case3.Id;
            document11.CMU_Accept_Reject__c =  'Accept';
            documentsList.add(document11);

            Documents__c document12 = new Documents__c();
            document12.IHM_receipt_number__c = '2324';
            document12.Name = 'test document';
            document12.IHM_receipt_date__c = Date.newInstance(2022, 06, 19); 
            document12.IHM_amount_as_per_receipt__c = 35700;
            document12.Opportunity_Relation__c = oppObj.Id;
            document12.Document_Type__c = 'IHM Receipt';
            document12.is_Active__c = true;
            document12.KYC_State__c = 'MAHARASHTRA';
            document12.KYC_Address_Line_2__c = 'address2 MAHARASHTRA';
            document12.KYC_Address_Line_1__c = 'address1 MAHARASHTRA';
            document12.KYC_No__c = Integrationutilities.getencryptedrequest('TN2020090003150',System.Label.privateKey,System.Label.ivkey);
            document12.Passport_No__c = 'ABC324321'; 
            document12.Address_line_1_PR__c = 'test address 1PR';
            document12.Address_line_CR_2__c = 'test address 2';
            document12.Address_line_2_PR__c = 'test address 2PR';
            document12.KYC_Pin_Code__c = '11111';
            document12.KYC_DOB__c = Date.newInstance(2022, 06, 16);
            document12.PAN_No__c = 'B4226274';
            document12.RecordTypeId = docKycRecordTypeId;
            document12.Applicant__c = applicant2.Id;
            documentsList.add(document12);

            Documents__c document13 = new Documents__c();
            document13.IHM_receipt_number__c = '2324';
            document13.Name = 'test document';
            document13.IHM_receipt_date__c = Date.newInstance(2022, 06, 19); 
            document13.IHM_amount_as_per_receipt__c = 35700;
            document13.Opportunity_Relation__c = oppObj.Id;
            document13.Document_Type__c = System.Label.PassportCard;
            document13.is_Active__c = true;
            document13.KYC_State__c = 'MAHARASHTRA';
            document13.KYC_Address_Line_2__c = 'address2 MAHARASHTRA';
            document13.KYC_Address_Line_1__c = 'address1 MAHARASHTRA';
            document13.KYC_No__c = Integrationutilities.getencryptedrequest('TN2020090003150',System.Label.privateKey,System.Label.ivkey);
            document13.Passport_No__c = 'ABC324321'; 
            document13.Address_line_1_PR__c = 'test address 1PR';
            document13.Address_line_CR_2__c = 'test address 2';
            document13.Address_line_2_PR__c = 'test address 2PR';
            document13.KYC_Pin_Code__c = '11111';
            document13.KYC_DOB__c = Date.newInstance(2022, 06, 16);
            document13.PAN_No__c = 'B4226274';
            document13.RecordTypeId = docKycRecordTypeId;
            document13.Applicant__c = applicant2.Id;
            documentsList.add(document13);

            Documents__c document14 = new Documents__c();
            document14.IHM_receipt_number__c = '2324';
            document14.Name = 'test document';
            document14.IHM_receipt_date__c = Date.newInstance(2022, 06, 19); 
            document14.IHM_amount_as_per_receipt__c = 35700;
            document14.Opportunity_Relation__c = oppObj.Id;
            document14.Document_Type__c = System.Label.PanCards;
            document14.is_Active__c = true;
            document14.KYC_State__c = 'MAHARASHTRA';
            document14.KYC_Address_Line_2__c = 'address2 MAHARASHTRA';
            document14.KYC_Address_Line_1__c = 'address1 MAHARASHTRA';
            document14.KYC_No__c = Integrationutilities.getencryptedrequest('TN2020090003150',System.Label.privateKey,System.Label.ivkey);
            document14.Passport_No__c = 'ABC324321'; 
            document14.Address_line_1_PR__c = 'test address 1PR';
            document14.Address_line_CR_2__c = 'test address 2';
            document14.Address_line_2_PR__c = 'test address 2PR';
            document14.KYC_Pin_Code__c = '11111';
            document14.KYC_DOB__c = Date.newInstance(2022, 06, 16);
            document14.PAN_No__c = 'B4226274';
            document14.RecordTypeId = docKycRecordTypeId;
            document14.Applicant__c = applicant2.Id;
            document14.Is_this_a_Photocopy__c = false;
            documentsList.add(document14);

            Documents__c document15 = new Documents__c();
            document15.IHM_receipt_number__c = '2324';
            document15.Name = 'test document';
            document15.IHM_receipt_date__c = Date.newInstance(2022, 06, 19); 
            document15.IHM_amount_as_per_receipt__c = 35700;
            document15.Opportunity_Relation__c = oppObj.Id;
            document15.Document_Type__c = System.Label.Form60DocumentType;
            document15.is_Active__c = true;
            document15.KYC_State__c = 'MAHARASHTRA';
            document15.KYC_Address_Line_2__c = 'address2 MAHARASHTRA';
            document15.KYC_Address_Line_1__c = 'address1 MAHARASHTRA';
            document15.KYC_No__c = Integrationutilities.getencryptedrequest('TN2020090003150',System.Label.privateKey,System.Label.ivkey);
            document15.Passport_No__c = 'ABC324321'; 
            document15.Address_line_1_PR__c = 'test address 1PR';
            document15.Address_line_CR_2__c = 'test address 2';
            document15.Address_line_2_PR__c = 'test address 2PR';
            document15.KYC_Pin_Code__c = '11111';
            document15.KYC_DOB__c = Date.newInstance(2022, 06, 16);
            document15.PAN_No__c = 'B4226274';
            document15.RecordTypeId = docKycRecordTypeId;
            document15.Applicant__c = applicant2.Id;
            documentsList.add(document15);

            Documents__c document16 = new Documents__c();
            document16.IHM_receipt_number__c = '2324';
            document16.Name = 'test document';
            document16.IHM_receipt_date__c = Date.newInstance(2022, 06, 19); 
            document16.IHM_amount_as_per_receipt__c = 35700;
            document16.Opportunity_Relation__c = oppObj.Id;
            document16.Document_Type__c = System.Label.Form60DocumentType;
            document16.is_Active__c = true;
            document16.KYC_State__c = 'MAHARASHTRA';
            document16.KYC_Address_Line_2__c = 'address2 MAHARASHTRA';
            document16.KYC_Address_Line_1__c = 'address1 MAHARASHTRA';
            document16.KYC_No__c = Integrationutilities.getencryptedrequest('TN2020090003150',System.Label.privateKey,System.Label.ivkey);
            document16.Passport_No__c = 'ABC324321'; 
            document16.Address_line_1_PR__c = 'test address 1PR';
            document16.Address_line_CR_2__c = 'test address 2';
            document16.Address_line_2_PR__c = 'test address 2PR';
            document16.KYC_Pin_Code__c = '11111';
            document16.KYC_DOB__c = Date.newInstance(2022, 06, 16);
            document16.PAN_No__c = 'B4226274';
            document16.RecordTypeId = docKycRecordTypeId;
            document16.Applicant__c = applicant2.Id;
            document16.Is_this_a_Photocopy__c = false;
            documentsList.add(document16);

            insert documentsList;
        }
    }
    @isTest
    public static void IND_GetFinalOfferDetailsTest(){
        try
        {
            Opportunity oppObj = [SELECT Id FROM Opportunity LIMIT 1];
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {
                IND_GetFinalOfferDetails.FinalOfferDetails finalDetailsWrapper = new IND_GetFinalOfferDetails.FinalOfferDetails();
                finalDetailsWrapper = IND_GetFinalOfferDetails.getFinalOfferDetails(oppObj.Id);
                System.assert(finalDetailsWrapper != NULL);    
            }                       
            Test.stopTest();
        }catch(Exception e){
            System.debug(e.getMessage());
        }
    }
    
    @isTest
    public static void IND_getDisabledBtnTest(){
        try
        {
            Opportunity oppObj = [SELECT Id,Sub_Stage__c FROM Opportunity LIMIT 1];
            oppObj.Sub_Stage__c = 'Sanction of Application';
            update oppObj;
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {
                IND_GetFinalOfferDetails.BtnDisableWrapper btnDisabled = IND_GetFinalOfferDetails.getDisabledBtn(oppObj.Id);
                System.assertEquals(true, btnDisabled.triggerDisabled); 
				System.assertEquals(false, btnDisabled.submitDisabled);    
            }                     
            Test.stopTest();
        }catch(Exception e){
            System.debug(e.getMessage());
        }
    }
    
    @isTest
    public static void IND_getFinalTermRecordIdTest(){
        try
        {
            Opportunity oppObj = [SELECT Id FROM Opportunity LIMIT 1];
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {
                String returnId1 = IND_GetFinalOfferDetails.getFinalTermRecordId(oppObj.Id);
                System.assertNotEquals(null, returnId1);  
                
                String returnId2 = IND_GetFinalOfferDetails.getFinalTermRecordId(null);
                System.assertEquals(null, returnId2);    
            }                                    
            Test.stopTest();
        }catch(Exception e){
            System.debug(e.getMessage());
        }
    }
    
    @isTest
    public static void IND_triggerSanctionCommunicationTest(){
        try
        {
            Opportunity oppObj = [SELECT Id FROM Opportunity LIMIT 1];
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {
                List<String> returnList1 = IND_GetFinalOfferDetails.triggerSanctionCommunication(oppObj.Id);            
                System.assertNotEquals(null, returnList1);    
                List<String> returnList2 = IND_GetFinalOfferDetails.triggerSanctionCommunication(null);            
                System.assertNotEquals(null, returnList2);
            }                                    
            Test.stopTest();
        }catch(Exception e){
            System.debug(e.getMessage());
        }
    }
    
    @isTest
    public static void IND_triggerSanctionCommunicationTest1(){
        try
        {
            Opportunity oppObj = [SELECT Id FROM Opportunity LIMIT 1];
         
            Test.startTest();
            oppObj.Sanction_Status__c = System.Label.nonStp;            
            update oppObj;  
            User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {                
                List<String> returnList3 = IND_GetFinalOfferDetails.triggerSanctionCommunication(oppObj.Id); 
                System.assertNotEquals(null, returnList3);
            }                                    
            Test.stopTest();
        }catch(Exception e){
            System.debug(e.getMessage());
        }
    }
    
    @isTest
    public static void IND_triggerSanctionCommunicationTest2(){
        try
        {
            Opportunity oppObj = [SELECT Id,IsRejected__c FROM Opportunity LIMIT 1];
            oppObj.IsRejected__c = true;
            update oppObj;
            
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {
                List<String> returnList1 = IND_GetFinalOfferDetails.triggerSanctionCommunication(oppObj.Id);            
                System.assertNotEquals(null, returnList1);    
                List<String> returnList2 = IND_GetFinalOfferDetails.triggerSanctionCommunication(null);            
                System.assertNotEquals(null, returnList2);
            }                                    
            Test.stopTest();
        }catch(Exception e){
            System.debug(e.getMessage());
        }
    }
    
    @isTest
    public static void IND_triggerSanctionCommunicationTest3(){
        try
        {
            Opportunity oppObj = [SELECT Id,IsRejected__c,Sanction_Status__c FROM Opportunity LIMIT 1];
            oppObj.Sanction_Status__c = null;
            update oppObj;
            
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {
                List<String> returnList1 = IND_GetFinalOfferDetails.triggerSanctionCommunication(oppObj.Id);            
                System.assertNotEquals(null, returnList1);    
                List<String> returnList2 = IND_GetFinalOfferDetails.triggerSanctionCommunication(null);            
                System.assertNotEquals(null, returnList2);
            }                                    
            Test.stopTest();
        }catch(Exception e){
            System.debug(e.getMessage());
        }
    }
    
    @isTest
    public static void IND_triggerSanctionCommunicationTest31(){
        try
        {
            Opportunity oppObj = [SELECT Id,IsRejected__c,Sanction_Status__c,StageName FROM Opportunity LIMIT 1];
            oppObj.StageName = System.Label.Credit_Processing;
            update oppObj;
            
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {
                List<String> returnList1 = IND_GetFinalOfferDetails.triggerSanctionCommunication(oppObj.Id);            
                System.assertNotEquals(null, returnList1);    
                List<String> returnList2 = IND_GetFinalOfferDetails.triggerSanctionCommunication(null);            
                System.assertNotEquals(null, returnList2);
            }                                    
            Test.stopTest();
        }catch(Exception e){
            System.debug(e.getMessage());
        }
    }
    
    @isTest
    public static void IND_triggerSanctionCommunicationTest32(){
        try
        {
            Opportunity oppObj = [SELECT Id,IsRejected__c,Sanction_Status__c,StageName FROM Opportunity LIMIT 1];
            oppObj.StageName = System.Label.Credit_Processing;
            oppobj.Sanction_Status__c = System.Label.nonStp;
            update oppObj;
            
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {
                List<String> returnList1 = IND_GetFinalOfferDetails.triggerSanctionCommunication(oppObj.Id);            
                System.assertNotEquals(null, returnList1);    
                List<String> returnList2 = IND_GetFinalOfferDetails.triggerSanctionCommunication(null);            
                System.assertNotEquals(null, returnList2);
            }                                    
            Test.stopTest();
        }catch(Exception e){
            System.debug(e.getMessage());
        }
    }
    
    @isTest
    public static void IND_triggerSanctionCommunicationTest333(){
        try
        {
            Opportunity oppObj = [SELECT Id,IsRejected__c,Sanction_Status__c,StageName FROM Opportunity LIMIT 1];
            oppObj.StageName = System.Label.Credit_Processing;
            oppobj.Sanction_Status__c = System.Label.nonStp;
            update oppObj;
            
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {
                List<String> returnList1 = IND_GetFinalOfferDetails.triggerSanctionCommunication(oppObj.Id);            
                System.assertNotEquals(null, returnList1);    
                List<String> returnList2 = IND_GetFinalOfferDetails.triggerSanctionCommunication(null);            
                System.assertNotEquals(null, returnList2);
            }                                    
            Test.stopTest();
        }catch(Exception e){
            System.debug(e.getMessage());
        }
    }
    
    @isTest
    public static void IND_triggerSanctionCommunicationTest33(){
        try
        {
            Opportunity oppObj = [SELECT Id,IsRejected__c,Sanction_Status__c,AML_Check_status__c,StageName FROM Opportunity LIMIT 1];
            oppObj.StageName = System.Label.Credit_Processing;
            oppObj.AML_Check_status__c = 'Rejected';
            oppobj.Sanction_Status__c = System.Label.nonStp;
            update oppObj;      
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1];
            System.runAs(u)
            {
                List<String> returnList1 = IND_GetFinalOfferDetails.triggerSanctionCommunication(oppObj.Id);            
                System.assertNotEquals(null, returnList1);    
                List<String> returnList2 = IND_GetFinalOfferDetails.triggerSanctionCommunication(null);            
                System.assertNotEquals(null, returnList2);
            }                                    
            Test.stopTest();
        }catch(Exception e){
            System.debug(e.getMessage());
        }
    }
    @isTest
    public static void IND_triggerSanctionCommunicationTest4(){
        try
        {
            Opportunity oppObj = [SELECT Id FROM Opportunity LIMIT 1];
            
            Final_Term__c finalTermObj = new Final_Term__c();
            finalTermObj = [Select Id From Final_Term__c Where Loan_Application__c = :oppObj.Id LIMIT 1];
            delete finalTermObj;
            
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {
                List<String> returnList1 = IND_GetFinalOfferDetails.triggerSanctionCommunication(oppObj.Id);            
                System.assertNotEquals(null, returnList1);    
                List<String> returnList2 = IND_GetFinalOfferDetails.triggerSanctionCommunication(null);            
                System.assertNotEquals(null, returnList2);
            }                                    
            Test.stopTest();
        }catch(Exception e){
            System.debug(e.getMessage());
        }
    }
    
    @isTest
    public static void IND_triggerSanctionCommunicationTest5(){
        try
        {
            Opportunity oppObj = [SELECT Id FROM Opportunity LIMIT 1];
            
            Final_Term__c finalTermObj = new Final_Term__c();
            finalTermObj = [Select Id From Final_Term__c Where Loan_Application__c = :oppObj.Id LIMIT 1];
            delete finalTermObj;
            
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
            u.ProfileId = [SELECT Id FROM Profile WHERE Name='CMU'].Id;
            update u;
                String amlRecordTypeId = (String) Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(System.Label.AML_Check).getRecordTypeId();
                Case caseObj = [Select Id,Status From Case Where Loan_Application__c = :oppObj.Id AND RecordTypeId = :amlRecordTypeId LIMIT 1];
                caseObj.ownerId = u.id;
                update caseObj;
                List<String> returnList1 = IND_GetFinalOfferDetails.triggerSanctionCommunication(oppObj.Id);            
                System.assertNotEquals(null, returnList1);    
                List<String> returnList2 = IND_GetFinalOfferDetails.triggerSanctionCommunication(null);            
                System.assertNotEquals(null, returnList2);
       
            Test.stopTest();
        }catch(Exception e){
            System.debug(e.getMessage());
        }
    }
    
    @isTest
    public static void IND_triggerSanctionCommunicationTest6(){
        try
        {
            Opportunity oppObj = [SELECT Id FROM Opportunity LIMIT 1];
            
            Final_Term__c finalTermObj = new Final_Term__c();
            finalTermObj = [Select Id From Final_Term__c Where Loan_Application__c = :oppObj.Id LIMIT 1];
            delete finalTermObj;
            
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
            u.ProfileId = [SELECT Id FROM Profile WHERE Name='IBL National Credit Manager'].Id;
            update u;
                String amlRecordTypeId = (String) Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(System.Label.AML_Check).getRecordTypeId();
                Case caseObj = [Select Id,Status From Case Where Loan_Application__c = :oppObj.Id AND RecordTypeId = :amlRecordTypeId LIMIT 1];
                caseObj.ownerId = u.id;
                update caseObj;
                List<String> returnList1 = IND_GetFinalOfferDetails.triggerSanctionCommunication(oppObj.Id);            
                System.assertNotEquals(null, returnList1);    
                List<String> returnList2 = IND_GetFinalOfferDetails.triggerSanctionCommunication(null);            
                System.assertNotEquals(null, returnList2);                        
            Test.stopTest();
        }catch(Exception e){
            System.debug(e.getMessage());
        }
    }
    
    @isTest
    public static void IND_triggerSanctionCommunicationTest7(){
        try
        {
            Opportunity oppObj = [SELECT Id FROM Opportunity LIMIT 1];
            
            Final_Term__c finalTermObj = new Final_Term__c();
            finalTermObj = [Select Id From Final_Term__c Where Loan_Application__c = :oppObj.Id LIMIT 1];
            delete finalTermObj;
            
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
            u.ProfileId = [SELECT Id FROM Profile WHERE Name='IBL Credit Analyst'].Id;
            update u;
                String amlRecordTypeId = (String) Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(System.Label.AML_Check).getRecordTypeId();
                Case caseObj = [Select Id,Status From Case Where Loan_Application__c = :oppObj.Id AND RecordTypeId = :amlRecordTypeId LIMIT 1];
                caseObj.ownerId = u.id;
                update caseObj;
                List<String> returnList1 = IND_GetFinalOfferDetails.triggerSanctionCommunication(oppObj.Id);            
                System.assertNotEquals(null, returnList1);    
                List<String> returnList2 = IND_GetFinalOfferDetails.triggerSanctionCommunication(null);            
                System.assertNotEquals(null, returnList2);                                   
            Test.stopTest();
        }catch(Exception e){
            System.debug(e.getMessage());
        }
    }
    
    @isTest
    public static void IND_triggerSanctionCommunicationTest8(){
        try
        {
            Opportunity oppObj = [SELECT Id FROM Opportunity LIMIT 1];
            
            Final_Term__c finalTermObj = new Final_Term__c();
            finalTermObj = [Select Id From Final_Term__c Where Loan_Application__c = :oppObj.Id LIMIT 1];
            delete finalTermObj;
            
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
            u.ProfileId = [SELECT Id FROM Profile WHERE Name='IBL Credit Head'].Id;
            update u;
                String amlRecordTypeId = (String) Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(System.Label.AML_Check).getRecordTypeId();
                Case caseObj = [Select Id,Status From Case Where Loan_Application__c = :oppObj.Id AND RecordTypeId = :amlRecordTypeId LIMIT 1];
                caseObj.ownerId = u.id;
                update caseObj;
                List<String> returnList1 = IND_GetFinalOfferDetails.triggerSanctionCommunication(oppObj.Id);            
                System.assertNotEquals(null, returnList1);    
                List<String> returnList2 = IND_GetFinalOfferDetails.triggerSanctionCommunication(null);            
                System.assertNotEquals(null, returnList2);                                   
            Test.stopTest();
        }catch(Exception e){
            System.debug(e.getMessage());
        }
    }
    
    @isTest
    public static void IND_initilizeEmailRequestWrapper(){
        try{
            Opportunity oppObj = [SELECT Id FROM Opportunity LIMIT 1];
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
            System.runAs(u){
                List<RequestWrapper> requestWrapper = IND_GetFinalOfferDetails.initilizeEmailRequestWrapper(oppObj.Id);
                System.assertNotEquals(null, requestWrapper);
            }
        }catch(Exception e){
            System.debug(e.getMessage());
        }
    }
    
    @isTest
    public static void IND_isConsentReceived(){
        try{
            Opportunity oppObj = [SELECT Id FROM Opportunity LIMIT 1];
            OppObj.Product_Type__c = 'Tractor';
            update Oppobj;
            Applicant__c appRec = new Applicant__c();
            appRec.Opportunity__c = oppObj.Id;
            appRec.Contact_number__c = '9743514830';
            appRec.Applicant_Type__c = 'Borrower';
            appRec.Insurance_Consent_Received__c = false;
            insert appRec;
            InsuranceDetails__c insRec = new InsuranceDetails__c();
            insRec.Applicant__c = appRec.Id;
            insRec.Loan_Application__c = oppObj.Id;
            insRec.Name = 'Insurance';
            insert insRec;
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
            System.runAs(u){
                List<IND_GetFinalOfferDetails.ConsentReceivedWrapper> consentWrapper = IND_GetFinalOfferDetails.isConsentReceived(oppObj.Id);
                System.assertNotEquals(null, consentWrapper);
                OppObj.Customer_Type__c = 'Non-Individual';
            	update Oppobj;
                List<IND_GetFinalOfferDetails.ConsentReceivedWrapper> consentWrapper1 = IND_GetFinalOfferDetails.isConsentReceived(oppObj.Id);
               	OppObj.Entity_Type__c = 'Proprietorship';
                update Oppobj;
                IND_GetFinalOfferDetails.isConsentReceived(oppObj.Id);
            }
        }catch(Exception e){
            System.debug(e.getMessage());
        }
    }
    @isTest
    public static void getApplicantDetailsTest(){
        try{
            Opportunity oppObj = [SELECT Id FROM Opportunity LIMIT 1];
            oppObj.Product_Type__c = 'Tractor';
            oppObj.Customer_Type__c = 'Individual';
            update oppObj;
            Applicant__c appRec = new Applicant__c();
            appRec.Opportunity__c = oppObj.Id;
            appRec.Contact_number__c = '9743514830';
            appRec.Applicant_Type__c = 'Borrower';
            appRec.Insurance_Consent_Received__c = false;
            insert appRec;
            InsuranceDetails__c insRec = new InsuranceDetails__c();
            insRec.Applicant__c = appRec.Id;
            insRec.Loan_Application__c = oppObj.Id;
            insRec.Name = 'Insurance';
            insert insRec;
        Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {
                 IND_GetFinalOfferDetails.applicantDetails applicantWrapper1 = IND_GetFinalOfferDetails.getApplicantDetails(oppObj.Id); 
                System.assertNotEquals(null, applicantWrapper1);
                appRec.Insurance_Consent_Received__c = true;
                Update appRec;
                IND_GetFinalOfferDetails.applicantDetails applicantWrapper2 = IND_GetFinalOfferDetails.getApplicantDetails(oppObj.Id); 
                
                
            }                                    
            Test.stopTest();
        }catch(Exception e){
            System.debug(e.getMessage());
        }
    }
    @isTest
    public static void IND_GetFinalOfferDetailsForTractorTest(){
        try
        {
            Opportunity oppObj = [SELECT Id FROM Opportunity LIMIT 1];
            oppObj.Product_Type__c = 'Tractor';
             update oppObj;
            Vehicle_Detail__c vehObj = [SELECT ID from Vehicle_Detail__c where Loan_Application__c=: oppObj.Id];
            vehObj.Approval_Status__c ='Approved';
            update vehObj;
            Final_Term__c finalTermObj = new Final_Term__c();
            finalTermObj.Loan_Application__c = oppObj.Id;
            finalTermObj.is_Active__c = true;
            finalTermObj.Tenure__c = '1234';
            finalTermObj.CRM_IRR__c = 34;
            finalTermObj.EMI_Amount__c = 76;
			finalTermObj.Loan_amount__c = '76';
			finalTermObj.Vehicle_Detail__c = vehObj.Id;
            insert finalTermObj;
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {
                IND_GetFinalOfferDetails.FinalOfferDetails finalDetailsWrapper = new IND_GetFinalOfferDetails.FinalOfferDetails();
                finalDetailsWrapper = IND_GetFinalOfferDetails.getFinalOfferDetailsForTractor(oppObj.Id);
                System.assert(finalDetailsWrapper != NULL);    
            }                       
            Test.stopTest();
        }catch(Exception e){
            System.debug(e.getMessage());
        }
    }
    @isTest
    public static void IND_triggerSanctionCommunicationForTractorTest(){
        try
        {
            Opportunity oppObj = [SELECT Id FROM Opportunity LIMIT 1];
            oppObj.Product_Type__c = 'Tractor';
            oppObj.StageName = System.Label.Credit_Processing;
            oppObj.Customer_Type__c = 'Individual';
             update oppObj;
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {
                List<String> returnList1 = IND_GetFinalOfferDetails.triggerSanctionCommunication(oppObj.Id);            
                System.assertNotEquals(null, returnList1); 
                oppObj.Customer_Type__c = 'Non-Individual';
                update oppObj;
                Applicant__c appRec = new Applicant__c();
            appRec.Opportunity__c = oppObj.Id;
            appRec.Contact_number__c = '9743514830';
            appRec.Applicant_Type__c = 'Beneficiarys';
            appRec.Insurance_Consent_Received__c = false;
            insert appRec;
                List<String> returnList2 = IND_GetFinalOfferDetails.triggerSanctionCommunication(oppObj.Id); 
                IND_GetFinalOfferDetails.getOppRecord(oppObj.Id);
                
            }                                    
            Test.stopTest();
        }catch(Exception e){
            System.debug(e.getMessage());
        }
    }
}