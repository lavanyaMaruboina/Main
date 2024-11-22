/**
* Test class for AdditionalDocumentsClass
*/
@IsTest
public class AdditionalDocumentsClassTest {
    @testSetup
    static void setup(){
        Profile p = [SELECT Id FROM Profile WHERE Name='IBL Business Executive'];
        User u = new User(Alias = 'standt2', Email='standarduser234567892@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,Maker_Id__c='12',IsActive = true,
                          TimeZoneSidKey='America/Los_Angeles',UserName='test_userprod9876543266@indusbank.com',MobilePhone = '9009078967');
        insert u;
        System.runAs(u) 
        {
            //create Oppty records
            List<Opportunity> opptyList = new List<Opportunity>();
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            opp.Name = 'VDR Test';
            opp.StageName='Post Sanction Checks and Documentation';
            opp.Product_Type__c=System.Label.Tractor;
            opp.CVO_Accepts_SPDC_Documents__c = 'No';
            opptyList.add(opp);
            Opportunity opp2 = TestDataUtility.createTestOpportunity1(false);
            opp2.Name = 'VDR Negative Test';
            opp2.CloseDate = Date.today();
            opp2.Product_Type__c=System.Label.Tractor;
            opptyList.add(opp2);
            Opportunity opp3 = TestDataUtility.createTestOpportunity1(false);
            opp3.Name = 'Oppty 3';
            opp3.Product_Type__c=System.Label.Tractor;
            opp3.CloseDate = Date.today();
            opptyList.add(opp3);
            if(Schema.sObjectType.Opportunity.isCreateable()){
                insert opptyList;
            }
            
            //Create Deal_Number__c record
            //Deal_Number__c createDealNumber = TestDataUtility.createDealNumber(true,opp);
            Deal_Number_Setting__c dlNumberSetting= new Deal_Number_Setting__c();
            dlNumberSetting.Name = System.Label.Tractor;
            dlNumberSetting.MDNField1__c ='AB';
            dlNumberSetting.MDNField2__c = 2.0;
            insert dlNumberSetting;
            
            Deal_Number__c dl=new Deal_Number__c();
            dl.Loan_Application__c = opp.Id;
            dl.DNField1__c = dlNumberSetting.MDNField1__c;
            dl.DNField2__c = String.valueOf(dlNumberSetting.MDNField2__c.round());
            //dl.Sub_Stage__c = 'test';
            //dl.ProductCode__c = 'T';
            insert dl;
            
            //Create Deal_Number__c record for 'VDR Negative Test'
            Deal_Number__c dl2=new Deal_Number__c();
            dl2.Loan_Application__c = opp2.Id;
            dl2.DNField1__c = dlNumberSetting.MDNField1__c;
            dl2.DNField2__c = String.valueOf(dlNumberSetting.MDNField2__c.round());
            //dl2.Sub_Stage__c = 'test';
            insert dl2;
            
            //create Vehicle_Detail__c record
            List<Vehicle_Detail__c> vdList = new List<Vehicle_Detail__c>();
            Vehicle_Detail__c  vehicleDetail = TestDataUtility.createTestVehicleDetailForIbb(false, opp);
            vehicleDetail.Is_RC_Limit_Check_correctly_captured__c='No';
            vehicleDetail.Deal_Number__c = dl.Id;
            vdList.add(vehicleDetail);
            Vehicle_Detail__c  vehicleDetail2 = TestDataUtility.createTestVehicleDetailForIbb(false, opp2);
            vehicleDetail2.Is_RC_Limit_Check_correctly_captured__c='No';
            vehicleDetail2.Deal_Number__c = dl2.Id;
            vdList.add(vehicleDetail2);
            if (Schema.sObjectType.Vehicle_Detail__c.isCreateable()){
                insert vdList;
            }
            
            //create Final_Term__c record
            List<Final_Term__c> ftList = new List<Final_Term__c>();
            Final_Term__c ft = new Final_Term__c();
            ft.CRM_IRR__c = 120;
            ft.Loan_Application__c = opp2.Id;
            ft.Holiday_period__c='30';
            ft.EMI_Amount__c= 10000;
            ft.FIwaiver_offAddress__c = 'Not Waived';
            ft.Installment_Type__c ='Structured';
            ftList.add(ft);
            Final_Term__c ft2 = new Final_Term__c();
            ft2.CRM_IRR__c = 120;
            ft2.Loan_Application__c = opp3.Id;
            ft2.Holiday_period__c='30';
            ft2.EMI_Amount__c= 10000;
            ft2.FIwaiver_offAddress__c = 'Not Waived';
            ft2.Loan_Amount__c = '1500000345';
            ftList.add(ft2);
            if(Schema.sObjectType.Final_Term__c.isCreateable()){
                insert ftList;
            }
            
            //Create Applicant__c Data
            List<Applicant__c> applicantList = new List<Applicant__c>();
            Applicant__c applicant1 = TestDataUtility.createTestApplicatnt1(false);
            applicant1.Opportunity__c = opp.Id;
            applicant1.Who_will_repay_the_loan__c = 'Borrower';
            applicant1.Scorecard_Decision__c = 'Light Red';
            applicantList.add(applicant1);
            Applicant__c applicant2 = TestDataUtility.createTestApplicatnt2(false);
            applicant2.Opportunity__c = opp.Id;
            applicantList.add(applicant2);
            if(Schema.sObjectType.Applicant__c.isCreateable()){
                insert applicantList;
            }
            
            //Create Loan_Application_Transaction_History__c
            List<Loan_Application_Transaction_History__c> laptHistList = new List<Loan_Application_Transaction_History__c>();
            Loan_Application_Transaction_History__c lth1 = new Loan_Application_Transaction_History__c();
            lth1.Loan_Application_ID__c = opp.Id;
            lth1.Name ='Additional Documents';
            lth1.Module__c = 'Pre Disbursement Check';
            lth1.Screen__c = 'Vehicle Inspection and RC Check';
            lth1.Deal_Number__c = dl.Id;
            lth1.Module_Name__c = 'FI';
            lth1.Submitted_Flag__c = true;
            laptHistList.add(lth1);
            Loan_Application_Transaction_History__c lth2 = new Loan_Application_Transaction_History__c();
            lth2.Loan_Application_ID__c = opp.Id;
            lth2.Deal_Number__c = dl.Id;
            lth2.Module__c = 'Post Sanction Checks and Documentation';
            lth2.Name ='Additional Documents';
            lth2.Screen__c = 'Structured EMI';
            lth2.Module_Name__c = 'FI';
            lth2.Submitted_Flag__c = true;
            laptHistList.add(lth2);
            
            Loan_Application_Transaction_History__c lth3 = new Loan_Application_Transaction_History__c();
            lth3.Loan_Application_ID__c = opp2.Id;
            lth3.Module__c = 'Pre Disbursement Check';
            lth3.Deal_Number__c = dl2.Id;
            
            //lth3.Name ='Additional Documents';
            lth3.Screen__c = 'Structured EMI';
            lth3.Module_Name__c = 'FI';
            lth3.Submitted_Flag__c = false;
            laptHistList.add(lth3);
            
            Loan_Application_Transaction_History__c lth4 = new Loan_Application_Transaction_History__c();
            lth4.Loan_Application_ID__c = opp.Id;
            lth4.Module__c = 'Post Sanction Checks and Documentation';
            //lth3.Name ='Additional Documents';
            lth4.Screen__c = 'Vehicle Inspection and RC Check';
            lth4.Deal_Number__c = dl.Id;
            lth4.Module_Name__c = 'FI';
            lth4.Submitted_Flag__c = true;
            laptHistList.add(lth4);
            Loan_Application_Transaction_History__c lth5 = new Loan_Application_Transaction_History__c();
            lth5.Loan_Application_ID__c = opp.Id;
            lth5.Module__c = 'Post Sanction Checks and Documentation';
            //lth3.Name ='Additional Documents';
            lth5.Screen__c = 'Security Mandate';
            lth5.Deal_Number__c = dl.Id;
            lth5.Module_Name__c = 'FI';
            lth5.Submitted_Flag__c = true;
            laptHistList.add(lth5);
            
            Loan_Application_Transaction_History__c lth6 = new Loan_Application_Transaction_History__c();
            lth6.Loan_Application_ID__c = opp.Id;
            lth6.Module__c = 'Post Sanction Checks and Documentation';
            //lth3.Name ='Additional Documents';
            lth6.Screen__c = 'Repayment Mandate';
            lth6.Deal_Number__c = dl.Id;
            lth6.Module_Name__c = 'FI';
            lth6.Submitted_Flag__c = true;
            laptHistList.add(lth6);
            
            Loan_Application_Transaction_History__c lth7 = new Loan_Application_Transaction_History__c();
            lth7.Loan_Application_ID__c = opp.Id;
            lth7.Module__c = 'Post Sanction Checks and Documentation';
            //lth3.Name ='Additional Documents';
            lth7.Screen__c = 'RTO, DPN, POA Documents Upload';
            lth7.Module_Name__c = 'FI';
            lth7.Deal_Number__c = dl.Id;
            lth7.Submitted_Flag__c = true;
            laptHistList.add(lth7);
            
            Loan_Application_Transaction_History__c lth8 = new Loan_Application_Transaction_History__c();
            lth8.Loan_Application_ID__c = opp.Id;
            lth8.Module__c = 'Post Sanction Checks and Documentation';
            //lth3.Name ='Additional Documents';
            lth8.Screen__c = 'Additional Documents';
            lth8.Module_Name__c = 'FI';
            lth8.Deal_Number__c = dl.Id;
            lth8.Submitted_Flag__c = true;
            laptHistList.add(lth8);
            
            Loan_Application_Transaction_History__c lth9 = new Loan_Application_Transaction_History__c();
            lth9.Loan_Application_ID__c = opp.Id;
            lth9.Module__c = 'Pre Disbursement Check';
            //lth3.Name ='Additional Documents';
            lth9.Screen__c = 'Security Mandate';
            lth9.Module_Name__c = 'FI';
            lth9.Deal_Number__c = dl.Id;
            lth9.Submitted_Flag__c = true;
            laptHistList.add(lth9);
            
            
            Loan_Application_Transaction_History__c lth10 = new Loan_Application_Transaction_History__c();
            lth10.Loan_Application_ID__c = opp.Id;
            lth10.Module__c = 'Pre Disbursement Check';
            //lth3.Name ='Additional Documents';
            lth10.Screen__c = 'Repayment Mandate';
            lth10.Module_Name__c = 'FI';
            lth10.Deal_Number__c = dl.Id;
            lth10.Submitted_Flag__c = true;
            laptHistList.add(lth10);     
            
            Loan_Application_Transaction_History__c lth11 = new Loan_Application_Transaction_History__c();
            lth11.Loan_Application_ID__c = opp.Id;
            lth11.Module__c = 'Post Sanction Checks and Documentation';
            //lth3.Name ='Additional Documents';
            lth11.Screen__c = 'IHM';
            lth11.Module_Name__c = 'FI';
            lth11.Submitted_Flag__c = true;
            lth11.Deal_Number__c = dl.Id;
            laptHistList.add(lth11);  
            
            Loan_Application_Transaction_History__c lth12 = new Loan_Application_Transaction_History__c();
            lth12.Loan_Application_ID__c = opp.Id;
            lth12.Module__c = 'Pre Disbursement Check';
            //lth3.Name ='Additional Documents';
            lth12.Screen__c = 'IHM';
            lth12.Deal_Number__c = dl.Id;
            lth12.Module_Name__c = 'FI';
            lth12.Submitted_Flag__c = true;
            laptHistList.add(lth12);  
            
            Loan_Application_Transaction_History__c lth13 = new Loan_Application_Transaction_History__c();
            lth13.Loan_Application_ID__c = opp.Id;
            lth13.Module__c = 'Post Sanction Checks and Documentation';
            lth13.Screen__c = 'Loan Agreement';
            lth13.Module_Name__c = 'FI';
            lth13.Deal_Number__c = dl.Id;
            
            lth13.Submitted_Flag__c = true;
            laptHistList.add(lth13);
            
            Loan_Application_Transaction_History__c lth14 = new Loan_Application_Transaction_History__c();
            lth14.Loan_Application_ID__c = opp.Id;
            lth14.Module__c = 'Pre Disbursement Check';
            lth14.Screen__c = 'Loan Agreement';
            lth14.Module_Name__c = 'FI';
            lth14.Submitted_Flag__c = true;
            lth14.Deal_Number__c = dl.Id;
            
            laptHistList.add(lth14);
            
            Loan_Application_Transaction_History__c lth15 = new Loan_Application_Transaction_History__c();
            lth15.Loan_Application_ID__c = opp.Id;
            lth15.Module__c = 'Pre Disbursement Check';
            lth15.Screen__c = 'RTO, DPN, POA Documents Upload';
            lth15.Module_Name__c = 'FI';
            lth15.Deal_Number__c = dl.Id;
            
            lth15.Submitted_Flag__c = true;
            laptHistList.add(lth15);
            
            Loan_Application_Transaction_History__c lth16 = new Loan_Application_Transaction_History__c();
            lth16.Loan_Application_ID__c = opp.Id;
            lth16.Module__c = 'Pre Disbursement Check';
            lth16.Screen__c = 'Additional Documents';
            lth16.Module_Name__c = 'FI';
            lth16.Deal_Number__c = dl.Id;
            
            lth16.Submitted_Flag__c = true;
            laptHistList.add(lth16);
            
            Loan_Application_Transaction_History__c lth17 = new Loan_Application_Transaction_History__c();
            lth17.Loan_Application_ID__c = opp.Id;
            lth17.Module__c = 'Pre Disbursement Check';
            lth17.Screen__c = 'Invoice';
            lth17.Module_Name__c = 'FI';
            lth17.Deal_Number__c = dl.Id;
            
            lth17.Submitted_Flag__c = true;
            laptHistList.add(lth17);
            
            Loan_Application_Transaction_History__c lth18 = new Loan_Application_Transaction_History__c();
            lth18.Loan_Application_ID__c = opp.Id;
            lth18.Module__c = 'Post Sanction Checks and Documentation';
            lth18.Screen__c = 'Invoice';
            lth18.Module_Name__c = 'FI';
            lth18.Deal_Number__c = dl.Id;
            
            lth18.Submitted_Flag__c = true;
            laptHistList.add(lth18);
            if(Schema.sObjectType.Loan_Application_Transaction_History__c.isCreateable()){
                insert laptHistList;
            }
            
            //Create Documents__c records
            List<Documents__c> docList = new List<Documents__c>();
            Documents__c doc1 = TestDataUtility.createTestDocumentITR(false, applicant1, opp);
            doc1.Vehicle_Detail__c = vehicleDetail.Id;
            doc1.Opportunity_Relation__c = opp.Id;
            doc1.Is_Document_Eligible__c='No';
            doc1.Is_active__c = true;
            doc1.Document_Type__c = 'Chassis Number uploaded during verification';
            doc1.Additional_Document__c = true;
            docList.add(doc1);
            
            Documents__c doc2 = TestDataUtility.createTestDocumentITR(false, applicant1, opp);
            doc2.Vehicle_Detail__c = vehicleDetail.Id;
            doc2.Opportunity_Relation__c = opp.Id;
            doc2.Is_Document_Eligible__c='No';
            doc2.Is_active__c = true;
            doc2.Document_Type__c = 'RTO';
            doc2.Additional_Document__c = true;
            docList.add(doc2);
            
            Documents__c doc3 = TestDataUtility.createTestDocumentITR(false, applicant1, opp);
            doc3.Vehicle_Detail__c = vehicleDetail.Id;
            doc3.Opportunity_Relation__c = opp.Id;
            doc3.Are_enter_details_as_per_RC_doc_upload__c='No';
            doc3.Is_active__c = true;
            doc3.Document_Type__c = 'RC Document';
            doc3.Additional_Document__c = true;
            docList.add(doc3);
            
            Documents__c doc4 = TestDataUtility.createTestDocumentITR(false, applicant1, opp);
            doc4.Vehicle_Detail__c = vehicleDetail.Id;
            doc4.Opportunity_Relation__c = opp.Id;
            doc4.Is_Cancelled_NOC_legible__c='No';
            doc4.Is_active__c = true;
            doc4.Document_Type__c = 'NOC';
            doc4.Additional_Document__c = true;
            docList.add(doc4);
            
            
            Documents__c doc5 = TestDataUtility.createTestDocumentITR(false, applicant1, opp);
            doc5.Vehicle_Detail__c = vehicleDetail.Id;
            doc5.Opportunity_Relation__c = opp.Id;
            doc5.enter_details_asper_Tax_Invoice_upload__c='No';
            doc5.Is_active__c = true;
            doc5.Document_Type__c = 'Tax Invoice';
            doc5.Additional_Document__c = true;
            docList.add(doc5);
            
            Documents__c doc6 = TestDataUtility.createTestDocumentITR(false, applicant1, opp);
            doc6.Vehicle_Detail__c = vehicleDetail.Id;
            doc6.Opportunity_Relation__c = opp.Id;
            doc6.Is_Sale_Agreement_legible__c='No';
            doc6.Is_active__c = true;
            doc6.Document_Type__c = 'Sale Agreement';
            doc6.Additional_Document__c = true;
            docList.add(doc6);
            
            Documents__c doc7 = TestDataUtility.createTestDocumentITR(false, applicant1, opp);
            doc7.Vehicle_Detail__c = vehicleDetail.Id;
            doc7.Opportunity_Relation__c = opp.Id;
            doc7.Is_IHM_Receipt_legible__c= false;
            doc7.Is_active__c = true;
            doc7.Document_Type__c = 'IHM Receipt';
            doc7.Additional_Document__c = true;
            docList.add(doc7);
            
            Documents__c doc8 = TestDataUtility.createTestDocumentITR(false, applicant1, opp);
            doc8.Vehicle_Detail__c = vehicleDetail.Id;
            doc8.Opportunity_Relation__c = opp.Id;
            doc8.Is_Branch_Undertaking_Letter_legible__c= 'No';
            doc8.Is_active__c = true;
            doc8.Document_Type__c = 'Branch Undertaking letter';
            doc8.Additional_Document__c = true;
            docList.add(doc8);
            
            Documents__c doc9 = TestDataUtility.createTestDocumentITR(false, applicant1, opp);
            doc9.Vehicle_Detail__c = vehicleDetail.Id;
            doc9.Opportunity_Relation__c = opp.Id;
            doc9.Buyer_Seller_Undertaking_Letter_legib__c= 'No';
            doc9.Is_active__c = true;
            doc9.Document_Type__c = 'Buyer-Seller Undertaking letter';
            doc9.Additional_Document__c = true;
            docList.add(doc9);
            
            Documents__c doc10 = TestDataUtility.createTestDocumentITR(false, applicant1, opp);
            doc10.Vehicle_Detail__c = vehicleDetail.Id;
            doc10.Opportunity_Relation__c = opp.Id;
            doc10.Is_sale_DD_legible__c= 'No';
            doc10.Is_active__c = true;
            doc10.Document_Type__c = 'DD for closing existing loan';
            doc10.Additional_Document__c = true;
            docList.add(doc10);
            
            Documents__c doc11 = TestDataUtility.createTestDocumentITR(false, applicant1, opp);
            doc11.Vehicle_Detail__c = vehicleDetail.Id;
            doc11.Opportunity_Relation__c = opp.Id;
            doc11.Is_sale_Foreclosure_Letter_legible__c= 'No';
            doc11.Is_active__c = true;
            doc11.Document_Type__c = 'Foreclosure letter for closed existing loan';
            doc11.Additional_Document__c = true;
            docList.add(doc11);
            
            Documents__c doc12 = TestDataUtility.createTestDocumentITR(false, applicant1, opp);
            doc12.Vehicle_Detail__c = vehicleDetail.Id;
            doc12.Opportunity_Relation__c = opp.Id;
            doc12.Is_passbook_legible_for_Borrower__c= 'No';
            doc12.Is_active__c = true;
            doc12.Document_Type__c = 'Borrower\'s Passbook';
            doc12.Additional_Document__c = true;
            docList.add(doc12);
            
            Documents__c doc13 = TestDataUtility.createTestDocumentITR(false, applicant1, opp);
            doc13.Vehicle_Detail__c = vehicleDetail.Id;
            doc13.Opportunity_Relation__c = opp.Id;
            doc13.Buy_Seller_Indemnity_LTR_legible__c= 'No';
            doc13.Is_active__c = true;
            doc13.Document_Type__c = 'Indemnity letter';
            doc13.Additional_Document__c = true;
            docList.add(doc13);
            
            Documents__c doc14 = TestDataUtility.createTestDocumentITR(false, applicant1, opp);
            doc14.Vehicle_Detail__c = vehicleDetail.Id;
            doc14.Opportunity_Relation__c = opp.Id;
            doc14.enter_DETLS_asper_COBWR_pasbook_upload__c= 'No';
            doc14.Is_active__c = true;
            doc14.Document_Type__c = 'Co-Borrower\'s Passbook';
            doc14.Additional_Document__c = true;
            docList.add(doc14);
            
            Documents__c doc15 = TestDataUtility.createTestDocumentITR(false, applicant1, opp);
            doc15.Vehicle_Detail__c = vehicleDetail.Id;
            doc15.Opportunity_Relation__c = opp.Id;
            doc15.DETLS_asper_COBWR_bank_STMT_upload__c= 'No';
            doc15.Is_active__c = true;
            doc15.Document_Type__c = 'Co-Borrower\'s Bank Statement';
            doc15.Additional_Document__c = true;
            docList.add(doc15);
            
            Documents__c doc16 = TestDataUtility.createTestDocumentITR(false, applicant1, opp);
            doc16.Vehicle_Detail__c = vehicleDetail.Id;
            doc16.Opportunity_Relation__c = opp.Id;
            doc16.DETLS_asper_COBWR_canc_chq_upload__c= 'No';
            doc16.Is_active__c = true;
            doc16.Document_Type__c = 'Co-Borrower\'s Cancel Cheque';
            doc16.Additional_Document__c = true;
            docList.add(doc16);
            
            Documents__c doc17 = TestDataUtility.createTestDocumentITR(false, applicant1, opp);
            doc17.Vehicle_Detail__c = vehicleDetail.Id;
            doc17.Opportunity_Relation__c = opp.Id;
            doc17.enter_DETLS_asper_BWR_bank_STMT_upload__c= 'No';
            doc17.Is_active__c = true;
            doc17.Document_Type__c = 'Borrower\'s Bank Statement';
            doc17.Additional_Document__c = true;
            docList.add(doc17);
            
            Documents__c doc18 = TestDataUtility.createTestDocumentITR(false, applicant1, opp);
            doc18.Vehicle_Detail__c = vehicleDetail.Id;
            doc18.Opportunity_Relation__c = opp.Id;
            doc18.enter_DETLS_as_per_BWR_canc_chq_upload__c= 'No';
            doc18.Is_active__c = true;
            doc18.Document_Type__c = 'Borrower\'s Cancel Cheque';
            doc18.Additional_Document__c = true;
            docList.add(doc18);
            
            Documents__c doc19 = TestDataUtility.createTestDocumentITR(false, applicant1, opp);
            doc19.Vehicle_Detail__c = vehicleDetail.Id;
            doc19.Opportunity_Relation__c = opp.Id;
            doc19.Is_Payment_Receipt_legible__c= 'No';
            doc19.Is_active__c = true;
            doc19.Document_Type__c = 'Payment Receipt';
            doc19.Additional_Document__c = true;
            docList.add(doc19);
            
            Documents__c doc20 = TestDataUtility.createTestDocumentITR(false, applicant1, opp);
            doc20.Vehicle_Detail__c = vehicleDetail.Id;
            doc20.Opportunity_Relation__c = opp.Id;
            doc20.Doc_for_Good_Health_borrower_legible__c= 'No';
            doc20.Is_active__c = true;
            doc20.Document_Type__c = 'Declaration of Borrower Good Health';
            doc20.Additional_Document__c = true;
            docList.add(doc20);
            
            if(Schema.sObjectType.Documents__c.isCreateable()){
                insert docList;
            }
            
            //Create Retry_Count__c records
            List<Retry_Count__c> rtCountList = new List<Retry_Count__c>();
            Retry_Count__c retryCount = new Retry_Count__c();
            retryCount.Service_Name__c = 'RC Limit Check';
            retryCount.Count__c = 0;
            retryCount.Loan_Application_Id__c = opp.Id;
            rtCountList.add(retryCount);
            if(Schema.sObjectType.Retry_Count__c.isCreateable()){
                insert rtCountList;
            }
            
            //Create Structered_EMI__c records
            List<Structered_EMI__c> semiList = new List<Structered_EMI__c>();
            Structered_EMI__c semi = new Structered_EMI__c();
            semi.From_Month__c = 1;
            semi.To_Month__c = 9;
            semi.EMI_Amount__c = 45000;
            semi.Number_of_Installments__c = 9;
            semi.Loan_Application__c = opp.Id;
            semiList.add(semi);
            Structered_EMI__c semi2 = new Structered_EMI__c();
            semi2.From_Month__c = 5;
            semi2.To_Month__c = 9;
            semi2.EMI_Amount__c = 50000;
            semi2.Number_of_Installments__c = 4;
            semi2.Loan_Application__c = opp.Id;
            semiList.add(semi2);
            if(Schema.sObjectType.Structered_EMI__c.isCreateable()){
                insert semiList;
            }
            
            //create InsuranceDetails__c records
            List<InsuranceDetails__c> insurList = new List<InsuranceDetails__c>();
            InsuranceDetails__c ins = new InsuranceDetails__c();
            ins.Name = 'iName';
            ins.Loan_Application__c = opp.Id;
            insurList.add(ins);
            if(Schema.sObjectType.InsuranceDetails__c.isCreateable()){
                insert insurList;
            }
            Repayments__c repay= new Repayments__c();
            repay.Is_ACH_Mandate_legible__c = 'No';
            repay.Loan_Application__c = opp.Id;
            repay.Is_Netbanking_available_with_customer__c = 'Yes';
            if(Schema.sObjectType.Repayments__c.isCreateable()){
                insert repay;
            }
            Loan_Agreement__c LoanRecord = new Loan_Agreement__c();
            LoanRecord.Is_Physical_Agreement_Eligible__c = 'No';
            LoanRecord.Loan_Application__c = opp.Id;
            insert LoanRecord;
            
            Invoice_Details__c invoiceRecord = new Invoice_Details__c();
            invoiceRecord.Is_Invoice_date_correctly_captured__c = 'No';
            invoiceRecord.Loan_Application__c = opp.Id;
            insert invoiceRecord;
            
            ContentVersion contentVersion = new ContentVersion(
                Title          = 'testfname',
                PathOnClient   = 'Pic.jpg',
                VersionData    = Blob.valueOf('Test Content'),
                IsMajorVersion = true);
            insert contentVersion; 
            List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
            
            //create ContentDocumentLink  record
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.LinkedEntityId = doc1.Id;
            cdl.ContentDocumentId = documents[0].Id;
            cdl.ShareType = 'V';
            cdl.Visibility = 'AllUsers';
            insert cdl;
        }
    }
    
    @IsTest
    public static void test_getAdditionalData(){
        Test.startTest();
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod9876543266@indusbank.com' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            Opportunity opp =[Select Id, Name From Opportunity Where Name ='VDR Test' LIMIt 1];
            Deal_Number__c dealNumberRec = [SELECT Id FROM Deal_Number__c where Loan_Application__c=:opp.Id LIMIT 1];
            
            String addnlDataString = AdditionalDocumentsClass.getAdditionalData(opp.Id,dealNumberRec.Id);
            System.assertNotEquals('', addnlDataString);
            //negative
            try{
                Opportunity oppNeg =[Select Id, Name From Opportunity Where Name ='VDR Negative Test' LIMIt 1];
                Deal_Number__c dealNumberRecNeg = [SELECT Id FROM Deal_Number__c where Loan_Application__c=:oppNeg.Id LIMIT 1];
                
                String addnlDataStringNeg = AdditionalDocumentsClass.getAdditionalData(oppNeg.Id,dealNumberRecNeg.Id);
                //System.assertEquals('{"docDetails":[]}', addnlDataStringNeg);
            } catch(Exception ex){
                System.assert(ex.getMessage().contains('Implementation restriction'));
            }
            //negative 2
            try {
                //String addnlDataStringNeg2 = AdditionalDocumentsClass.getAdditionalData('yfydkhgkf','rewrw');
                //System.assertEquals('{"docDetails":[]}', addnlDataStringNeg2);
            } catch(Exception ex){
              //  System.assert(ex.getMessage().contains('Implementation restriction'));
            }
        }
        Test.stopTest();
    }
    @isTest
    public static void test_getInsuranceDetails(){
        Test.startTest();
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod9876543266@indusbank.com' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            Opportunity opp =[Select Id, Name From Opportunity Where Name ='VDR Test' LIMIt 1];
            List<InsuranceDetails__c> resultList = AdditionalDocumentsClass.getInsuranceDetails(opp.Id);
            System.assertNotEquals(null, resultList);
        }
        Test.stopTest();
    }
    @IsTest
    public static String test_getApplicantData(){
        test.startTest();
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod9876543266@indusbank.com' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            try{
                Opportunity opp = [Select id, name from opportunity limit 1];
                List<Applicant__c> app1 = AdditionalDocumentsClass.getApplicantData(opp.Id);
                System.assertNotEquals(null,app1);
                List<Applicant__c> app2 = AdditionalDocumentsClass.getApplicantData(null);
                System.assertEquals(null,app2);
            }catch (AuraHandledException e){
                System.debug(e.getMessage());
            }
            test.stopTest();
        }
        return 'success';
    }
    @isTest
    public static void test_getLoanApplicationCategory(){
        Test.startTest();
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod9876543266@indusbank.com' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            Opportunity opp =[Select Id, Name From Opportunity Where Name ='VDR Test' LIMIt 1];
            Deal_Number__c dealNumberRec = [SELECT Id FROM Deal_Number__c where Loan_Application__c=:opp.Id LIMIT 1];
            
            String result = AdditionalDocumentsClass.getLoanApplicationCategory(opp.Id,dealNumberRec.Id);
            System.assertNotEquals(null,result);
        }
        Test.stopTest();
        
    }
    @isTest
    public static void test_updateAdditionalDocument(){
        
        Test.startTest();
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod9876543266@indusbank.com' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            List<String> docTypeList = new List<String>{'Chassis Number uploaded during verification','Aadhaar'};
                Opportunity opp =[Select Id, Name From Opportunity Where Name ='VDR Test' LIMIt 1];
            Deal_Number__c dealNumberRec = [SELECT Id FROM Deal_Number__c where Loan_Application__c=:opp.Id LIMIT 1];
            
            
            List<Documents__c> doc=[SELECT Id,Document_Type__c,Cheque_Number__c FROM Documents__c Where Document_Type__c='Chassis Number uploaded during verification' LIMIT 1];
            String jsonStr = JSON.serialize(doc);
            AdditionalDocumentsClass.updateAdditionalDocument(opp.Id, jsonStr,true,JSON.serialize(docTypeList),dealNumberRec.Id);
            
            //negative
            try{      
                Opportunity opp1 =[Select Id, Name From Opportunity Where Name ='VDR Negative Test' LIMIt 1];
                Deal_Number__c dealNumberRec2 = [SELECT Id FROM Deal_Number__c where Loan_Application__c=:opp1.Id LIMIT 1];
                
                Documents__c doc1=[SELECT Id,Document_Type__c,Cheque_Number__c FROM Documents__c Where Document_Type__c='Chassis Number uploaded during verification' LIMIT 1];
                String jsonStr1 = JSON.serialize(doc1);
                AdditionalDocumentsClass.updateAdditionalDocument(opp1.Id, jsonStr1,true,JSON.serialize(docTypeList),dealNumberRec2.Id);
            }catch(Exception ex){
                System.assert(ex.getMessage().contains('Malformed JSON'));
            }
        }
        Test.stopTest(); 
        
    }
    @isTest
    public static void test_getBankName(){
        Test.startTest();
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod9876543266@indusbank.com' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            List<Bank_masters__c> bankMasterList = AdditionalDocumentsClass.getBankName();
            System.assertNotEquals(null,bankMasterList);
        }
        Test.stopTest();
    }
    @isTest
    public static void test_checkIfReadOnly(){
        Test.startTest();
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod9876543266@indusbank.com' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            Opportunity opp =[Select Id, Name From Opportunity Where Name ='VDR Test' LIMIt 1];  
            Deal_Number__c dealNumberRec = [SELECT Id FROM Deal_Number__c where Loan_Application__c=:opp.Id LIMIT 1];
            
            Boolean result1 = AdditionalDocumentsClass.checkIfReadOnly(opp.Id,dealNumberRec.Id);            
            System.assertEquals(true,result1);
            Boolean result2 = AdditionalDocumentsClass.checkIfReadOnly(null,null);
            System.assertEquals(false,result2);
        }
        Test.stopTest();
    }
    @isTest
    public static void test_fetchRelatedDocument(){
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod9876543266@indusbank.com' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            Test.startTest();
            Opportunity opp =[Select Id, Name From Opportunity Where Name ='VDR Test' LIMIt 1];
            Deal_Number__c dealNumberRec = [SELECT Id FROM Deal_Number__c where Loan_Application__c=:opp.Id LIMIT 1];
            
            String result = AdditionalDocumentsClass.fetchRelatedDocument(opp.Id,dealNumberRec.Id);
            System.assertNotEquals(null,result);
            
            opp.Product_Type__c = 'Two Wheeler';
            update opp;
            //Else Part
            String result2 = AdditionalDocumentsClass.fetchRelatedDocument(opp.Id,dealNumberRec.Id);
            System.assertNotEquals(null,result);
        }
        Test.stopTest();
    }
    @isTest
    public static void test_fetchContentDocument(){
        Test.startTest();
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod9876543266@indusbank.com' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            Opportunity opp =[Select Id, Name From Opportunity Where Name ='VDR Test' LIMIt 1];
            Deal_Number__c dealNumberRec = [SELECT Id FROM Deal_Number__c where Loan_Application__c=:opp.Id LIMIT 1];
            
            Documents__c doc=[SELECT Id,Document_Type__c,Cheque_Number__c FROM Documents__c Where Document_Type__c='Chassis Number uploaded during verification' LIMIT 1];   
            ContentDocumentLink cdl = AdditionalDocumentsClass.fetchContentDocument(opp.Id,doc.Document_Type__c,dealNumberRec.Id);
            System.assertNotEquals(null,cdl);
        }
        Test.stopTest();
    }
     @isTest
    public static void test_fetchContentDocumentElse(){
        Test.startTest();
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod9876543266@indusbank.com' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            Opportunity opp =[Select Id, Name,Product_Type__c From Opportunity Where Name ='VDR Test' LIMIt 1];
            Deal_Number__c dealNumberRec = [SELECT Id FROM Deal_Number__c where Loan_Application__c=:opp.Id LIMIT 1];
            
            opp.Product_Type__c = 'Two Wheeler';
            update opp;
            
            Documents__c doc=[SELECT Id,Document_Type__c,Cheque_Number__c FROM Documents__c Where Document_Type__c='Chassis Number uploaded during verification' LIMIT 1];   
            ContentDocumentLink cdl = AdditionalDocumentsClass.fetchContentDocument(opp.Id,doc.Document_Type__c,dealNumberRec.Id);
            System.assertNotEquals(null,cdl);
        }
        Test.stopTest();
    }
     @isTest
    public static void test_deleteDocRecord(){
        Test.startTest();
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod9876543266@indusbank.com' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            Opportunity opp =[Select Id, Name From Opportunity Where Name ='VDR Test' LIMIt 1];
            List<String> docDetails = new List<String>{'IHM Receipt'};
            AdditionalDocumentsClass.deleteDocRecord(opp.Id,docDetails);
        }
        Test.stopTest();
    }
    @isTest
    public static void test_fetchPicklistValue(){
        Test.startTest();
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod9876543266@indusbank.com' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            List<Map<String, String>> options = AdditionalDocumentsClass.fetchPicklistValue('Document_Type__c');
            System.assertNotEquals(null,options);
        }
        Test.stopTest();
    }
    @isTest
    public static void test_postSavedDataOnSubmit(){
        Test.startTest();
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod9876543266@indusbank.com' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            //else part
            Opportunity opp =[Select Id, Name,Product_Type__c From Opportunity Where Name ='VDR Test' LIMIt 1];
            List<Documents__c> doc=[SELECT Id,Document_Type__c,Cheque_Number__c FROM Documents__c Where Is_active__c = true];
            String jsonStr = JSON.serialize(doc);
            Deal_Number__c dealNumberRec = [SELECT Id FROM Deal_Number__c where Loan_Application__c=:opp.Id LIMIT 1];
            String result1 = AdditionalDocumentsClass.postSavedDataOnSubmit(opp.Id, jsonStr,dealNumberRec.Id);
            System.assertEquals('Success',result1);
            
            //if part
            Opportunity opp1 =[Select Id, Name,Product_Type__c From Opportunity Where Name ='VDR Negative Test' LIMIt 1];
            Deal_Number__c dealNumberRecNeg = [SELECT Id FROM Deal_Number__c where Loan_Application__c=:opp1.Id LIMIT 1];
            List<Documents__c> doc1=[SELECT Id,Document_Type__c,Cheque_Number__c FROM Documents__c Where Document_Type__c='Chassis Number uploaded during verification' LIMIT 1];
            String jsonStr1 = JSON.serialize(doc1);
            String result2 = AdditionalDocumentsClass.postSavedDataOnSubmit(opp1.Id, jsonStr1,dealNumberRecNeg.id);
            System.assertEquals('All the modules screens have not been completed, please complete',result2);
            
            //Other product type
            opp.Product_Type__c = 'Two Wheeler';
            update opp;
            String result3 = AdditionalDocumentsClass.postSavedDataOnSubmit(opp.Id, jsonStr,dealNumberRec.Id);
            
               //Other product type for opp1
            opp1.Product_Type__c = 'Two Wheeler';
            update opp1;
            String result4 = AdditionalDocumentsClass.postSavedDataOnSubmit(opp1.Id, jsonStr,dealNumberRecNeg.Id);

            
        }
        Test.stopTest();
    }
     @isTest
    public static void test_postSavedDataOnSubmitOtherProduct(){
        Test.startTest();
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod9876543266@indusbank.com' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            //else part
            Opportunity opp =[Select Id, Name,Product_Type__c,IND_Not_Provided_Documents__c From Opportunity Where Name ='VDR Test' LIMIt 1];
            List<Documents__c> doc=[SELECT Id,Document_Type__c,Cheque_Number__c FROM Documents__c Where Is_active__c = true];
            String jsonStr = JSON.serialize(doc);
            Deal_Number__c dealNumberRec = [SELECT Id FROM Deal_Number__c where Loan_Application__c=:opp.Id LIMIT 1];
            
            //Other product type
            opp.Product_Type__c = 'Two Wheeler';
            opp.IND_Not_Provided_Documents__c = 'No';
            opp.StageName= 'Pre Disbursement Check';
            update opp;
            
            String result1 = AdditionalDocumentsClass.postSavedDataOnSubmit(opp.Id, jsonStr,dealNumberRec.Id);
            System.assertEquals('Success',result1);
        }
        Test.stopTest();
    }
    
    @isTest
    public static  void test_notifyUsers(){
        Set<String> userIdSet=new Set<String>();
        String currentUserId=UserInfo.getUserId();
        // String currentUserId='skansd';
        userIdSet.add(currentUserId);
        Test.startTest();
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod9876543266@indusbank.com' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            Opportunity opp =[Select Id, Name From Opportunity Where Name ='VDR Test' LIMIt 1];
            String message = 'Loan Application ' + opp.Name + ' has been assigned to you.';
            AdditionalDocumentsClass.notifyUsers(userIdSet,opp.Id,message);
            //AdditionalDocumentsClass.notifyUsers(userIdSet,'sdsaddsam ','namas');
        }
        Test.stopTest();
    }
    @isTest
    public static void getContentVersionTypeTest(){
        try{
            
            Blob beforeblob1 = Blob.valueOf('Unit Test Attachment Body');
            
            ContentVersion cvt1 = new ContentVersion();
            cvt1.title = 'test content trigger';      
            cvt1.PathOnClient ='test';           
            cvt1.VersionData = beforeblob1;
            cvt1.Document_Side_fileupload__c = 'Selfie';
            insert cvt1;   
            
            Test.startTest();
            AdditionalDocumentsClass.getContentVersionType(cvt1.Id);
            AdditionalDocumentsClass.getContentVersionType(null);
            AdditionalDocumentsClass.getContentVersionType('test');
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
     @isTest
    public static void test_fetchAdditionalDocuments(){
        Test.startTest();
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod9876543266@indusbank.com' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            Opportunity opp =[Select Id, Name From Opportunity Where Name ='VDR Test' LIMIt 1];
            Deal_Number__c dealNumberRec = [SELECT Id FROM Deal_Number__c where Loan_Application__c=:opp.Id LIMIT 1];
            
            String str = AdditionalDocumentsClass.fetchAdditionalDocuments(opp.Id,dealNumberRec.Id);
            System.assertNotEquals(null,str);
        }
        Test.stopTest();
    }
         @isTest
    public static void test_fetchAdditionalDocumentsElse(){
        Test.startTest();
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod9876543266@indusbank.com' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            Opportunity opp =[Select Id, Name,Product_Type__c From Opportunity Where Name ='VDR Test' LIMIt 1];
            
            Deal_Number__c dealNumberRec = [SELECT Id FROM Deal_Number__c where Loan_Application__c=:opp.Id LIMIT 1];
            opp.Product_Type__c = 'Two Wheeler';
            update opp;
            
            String str = AdditionalDocumentsClass.fetchAdditionalDocuments(opp.Id,dealNumberRec.Id);
            System.assertNotEquals(null,str);
        }
        Test.stopTest();
    }
    
    @isTest
    public static void getLoanApplicationCategoryTest1(){
        Profile p = [SELECT Id FROM Profile WHERE Name='IBL Business Executive'];
        User u = new User(Alias = 'standt2', Email='standarduser2@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,Maker_Id__c='12',IsActive = true,
                          TimeZoneSidKey='America/Los_Angeles',UserName='test_userprod1236@indusbank.com',MobilePhone = '9089078967');
        insert u;
        
        System.runAs(u) 
        {
            
            Opportunity opga1 = new Opportunity();
            opga1.StageName = 'Qualification';
            opga1.CloseDate = Date.newInstance(2021, 1, 11);
            opga1.Name = 'testone';
            opga1.Product_Type__c = System.Label.Tractor;
            opga1.OwnerId = u.Id;
            insert opga1;
            
            Deal_Number_Setting__c dlNumberSetting= new Deal_Number_Setting__c();
            dlNumberSetting.Name = System.Label.Tractor;
            dlNumberSetting.MDNField1__c ='AB';
            dlNumberSetting.MDNField2__c = 2.0;
            insert dlNumberSetting;
            
            //Create Deal_Number__c record for 'VDR Test'
            Deal_Number__c dl=new Deal_Number__c();
            dl.Loan_Application__c = opga1.Id;
            dl.DNField1__c = dlNumberSetting.MDNField1__c;
            dl.DNField2__c = String.valueOf(dlNumberSetting.MDNField2__c.round());
            //dl.Sub_Stage__c = 'test';
//            insert dl;
            
            Test.startTest();
            AdditionalDocumentsClass.getLoanApplicationCategory(opga1.Id,'test');
            AdditionalDocumentsClass.getLoanApplicationCategory(null,null);
            Test.stopTest();
        }
    }  
    @isTest
    public static void postSavedDataOnSubmitTest3(){
        try{
            Opportunity opga1 = new Opportunity();
            opga1.StageName = 'Qualification';
            opga1.CloseDate = Date.newInstance(2021, 1, 11);
            opga1.Name = 'testone';
            opga1.Product_Type__c = System.Label.Tractor;
            insert opga1;
            
            Deal_Number_Setting__c dlNumberSetting= new Deal_Number_Setting__c();
            dlNumberSetting.Name = System.Label.Tractor;
            dlNumberSetting.MDNField1__c ='AB';
            dlNumberSetting.MDNField2__c = 2.0;
            insert dlNumberSetting;
            
            //Create Deal_Number__c record for 'VDR Test'
            Deal_Number__c dl=new Deal_Number__c();
            dl.Loan_Application__c = opga1.Id;
            dl.DNField1__c = dlNumberSetting.MDNField1__c;
            dl.DNField2__c = String.valueOf(dlNumberSetting.MDNField2__c.round());
            //dl.Sub_Stage__c = 'test';
            insert dl;
            
            Applicant__c apga1 = new Applicant__c();
            apga1.Opportunity__c = opga1.Id;
            apga1.Contact_number__c = '9743514830';
            apga1.Applicant_Type__c = 'Borrower';
            insert apga1;
            
            List<Documents__c> dcList = new List<Documents__c>();
            Documents__c dt2 = new Documents__c();
            dt2.Applicant__c = apga1.Id;
            dt2.Opportunity_Relation__c = opga1.Id;
            dt2.Document_Type__c = 'Seller\'s Passbook';
            dt2.entered_details_asper_passbook_upload__c = 'No';
            dt2.Document_Side__c ='Back';
            dt2.Aadhar_Source__c = 'ScanAadhar';
            dt2.is_Active__c = true;
            dt2.Additional_Document__c = true;
            insert dt2;
            dcList.add(dt2);
            
            
            Test.startTest();
            // AdditionalDocumentsClass.postSavedDataOnSubmit(opga1.Id,JSON.serialize(dcList),dl.Id);
            Test.stopTest();
            
        }catch(Exception e){
            //System.assertEquals('script-thrown exception', e.getmessage());
        }
    }
    
    @isTest
    public static void postSavedDataOnSubmitTest4(){
        try{
            Opportunity opga1 = new Opportunity();
            opga1.StageName = 'Qualification';
            opga1.CloseDate = Date.newInstance(2021, 1, 11);
            opga1.Name = 'testone';
            opga1.Product_Type__c = System.Label.Tractor;
            insert opga1;
            
            Deal_Number_Setting__c dlNumberSetting= new Deal_Number_Setting__c();
            dlNumberSetting.Name = System.Label.Tractor;
            dlNumberSetting.MDNField1__c ='AB';
            dlNumberSetting.MDNField2__c = 2.0;
            insert dlNumberSetting;
            
            //Create Deal_Number__c record for 'VDR Test'
            Deal_Number__c dl=new Deal_Number__c();
            dl.Loan_Application__c = opga1.Id;
            dl.DNField1__c = dlNumberSetting.MDNField1__c;
            dl.DNField2__c = String.valueOf(dlNumberSetting.MDNField2__c.round());
           // dl.Sub_Stage__c = 'test';
            insert dl;
            
            Applicant__c apga1 = new Applicant__c();
            apga1.Opportunity__c = opga1.Id;
            apga1.Contact_number__c = '9743514830';
            apga1.Applicant_Type__c = 'Borrower';
            insert apga1;
            
            List<Documents__c> dcList = new List<Documents__c>();
            Documents__c dt2 = new Documents__c();
            dt2.Applicant__c = apga1.Id;
            dt2.Opportunity_Relation__c = opga1.Id;
            dt2.Document_Type__c = 'Seller\'s Bank Statement';
            dt2.enter_details_asper_bank_STMT_upload__c = 'No';
            dt2.Document_Side__c ='Back';
            dt2.Aadhar_Source__c = 'ScanAadhar';
            dt2.is_Active__c = true;
            dt2.Additional_Document__c = true;
            insert dt2;
            dcList.add(dt2);
            
            
            Test.startTest();
            //AdditionalDocumentsClass.postSavedDataOnSubmit(opga1.Id,JSON.serialize(dcList),dl.Id);
            Test.stopTest();
            
        }catch(Exception e){
            //System.assertEquals('script-thrown exception', e.getmessage());
        }
    }
    
    @isTest
    public static void postSavedDataOnSubmitTest5(){
        try{
            Opportunity opga1 = new Opportunity();
            opga1.StageName = 'Qualification';
            opga1.CloseDate = Date.newInstance(2021, 1, 11);
            opga1.Name = 'testone';
            opga1.Product_Type__c = System.Label.Tractor;
            insert opga1;
            
            Deal_Number_Setting__c dlNumberSetting= new Deal_Number_Setting__c();
            dlNumberSetting.Name = System.Label.Tractor;
            dlNumberSetting.MDNField1__c ='AB';
            dlNumberSetting.MDNField2__c = 2.0;
            insert dlNumberSetting;
            
            //Create Deal_Number__c record for 'VDR Test'
            Deal_Number__c dl=new Deal_Number__c();
            dl.Loan_Application__c = opga1.Id;
            dl.DNField1__c = dlNumberSetting.MDNField1__c;
            dl.DNField2__c = String.valueOf(dlNumberSetting.MDNField2__c.round());
            //dl.Sub_Stage__c = 'test';
            insert dl;
            
            Applicant__c apga1 = new Applicant__c();
            apga1.Opportunity__c = opga1.Id;
            apga1.Contact_number__c = '9743514830';
            apga1.Applicant_Type__c = 'Borrower';
            insert apga1;
            
            List<Documents__c> dcList = new List<Documents__c>();
            Documents__c dt2 = new Documents__c();
            dt2.Applicant__c = apga1.Id;
            dt2.Opportunity_Relation__c = opga1.Id;
            dt2.Document_Type__c = 'Seller\'s Cancel Cheque';
            dt2.enter_details_as_per_canc_chq_upload__c = 'No';
            dt2.Document_Side__c ='Back';
            dt2.Aadhar_Source__c = 'ScanAadhar';
            dt2.is_Active__c = true;
            dt2.Additional_Document__c = true;
            insert dt2;
            dcList.add(dt2);
            
            
            Test.startTest();
            //AdditionalDocumentsClass.postSavedDataOnSubmit(opga1.Id,JSON.serialize(dcList),dl.Id);
            Test.stopTest();
            
        }catch(Exception e){
            //System.assertEquals('script-thrown exception', e.getmessage());
        }
    }
    
    @isTest
    public static void postSavedDataOnSubmitTest6(){
        try{
            Opportunity opga1 = new Opportunity();
            opga1.StageName = 'Qualification';
            opga1.CloseDate = Date.newInstance(2021, 1, 11);
            opga1.Name = 'testone';
            opga1.Product_Type__c = System.Label.Tractor;
            insert opga1;
            
            Deal_Number_Setting__c dlNumberSetting= new Deal_Number_Setting__c();
            dlNumberSetting.Name = System.Label.Tractor;
            dlNumberSetting.MDNField1__c ='AB';
            dlNumberSetting.MDNField2__c = 2.0;
            insert dlNumberSetting;
            
            //Create Deal_Number__c record for 'VDR Test'
            Deal_Number__c dl=new Deal_Number__c();
            dl.Loan_Application__c = opga1.Id;
            dl.DNField1__c = dlNumberSetting.MDNField1__c;
            dl.DNField2__c = String.valueOf(dlNumberSetting.MDNField2__c.round());
           // dl.Sub_Stage__c = 'test';
            insert dl;
            
            Applicant__c apga1 = new Applicant__c();
            apga1.Opportunity__c = opga1.Id;
            apga1.Contact_number__c = '9743514830';
            apga1.Applicant_Type__c = 'Borrower';
            insert apga1;
            
            List<Documents__c> dcList = new List<Documents__c>();
            Documents__c dt2 = new Documents__c();
            dt2.Applicant__c = apga1.Id;
            dt2.Opportunity_Relation__c = opga1.Id;
            dt2.Document_Type__c = 'Declaration of Co-Borrower Good Health';
            dt2.Doc_for_Good_Health_coborrower_legible__c = 'No';
            dt2.Document_Side__c ='Back';
            dt2.Aadhar_Source__c = 'ScanAadhar';
            dt2.is_Active__c = true;
            dt2.Additional_Document__c = true;
            insert dt2;
            dcList.add(dt2);
            
            
            Test.startTest();
            // AdditionalDocumentsClass.postSavedDataOnSubmit(opga1.Id,JSON.serialize(dcList),dl.Id);
            Test.stopTest();
            
        }catch(Exception e){
            //System.assertEquals('script-thrown exception', e.getmessage());
        }
    }
}