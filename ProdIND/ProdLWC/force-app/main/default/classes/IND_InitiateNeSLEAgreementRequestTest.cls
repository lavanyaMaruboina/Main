@isTest
public class IND_InitiateNeSLEAgreementRequestTest {

    @testSetup 
    static void testDataSetup() 
    {
        //create user
        Profile p = [SELECT Id FROM Profile WHERE Name='IBL Business Executive'];
        User u = new User(Alias = 'standt2', Email='standarduser2@testorg.com',MobilePhone = '9999999999',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,Maker_Id__c='12',IsActive = true,
                          TimeZoneSidKey='America/Los_Angeles',UserName='test1_userprod123@indusbank.com');
        insert u;
        System.runAs(u) 
        {

            Account acc = new Account();
            acc.Name = 'test account';
            acc.State__c = 'MAHARASHTRA';
            acc.Phone = '+914335225';
            insert acc;

          /*  List<Opportunity> oppList = new List<Opportunity>();
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
            opp.Product_Type__c =  system.label.TwoWheeler;
            opp.EMI_Amount__c = 10000;  
            opp.Agreement_Amount__c = 450000;
            opp.Documentation_Charges__c = '2000';
            opp.Applicant_Name__c = 'test';
            oppList.add(opp);  
            
            insert oppList;
            */
            
            //isWorking
            
            List<Opportunity> oppList = new List<Opportunity>();
            
             Opportunity opp1 = TestDataUtility.createTestOpportunityForOcr(false); 
            opp1.Sub_Stage__c = System.Label.Field_Investigation;
            opp1.Is_Mobile_Journey_Completed__c = true;
            opp1.Vehicle_Type__c = System.Label.used;
            opp1.Product_Type__c = System.Label.PassengerVehicles;
            opp1.Sanction_Status__c = System.Label.nonStp;  
            opp1.Agent_BL_code__c = 'AHZ';
            opp1.Deal_Number__c = null; 
            opp1.AccountId = acc.Id;
            opp1.Required_ROI__c = 9;
            opp1.Sanction_Date__c = Date.newInstance(2022, 06, 11);
            opp1.EMI_Amount__c = 10000;  
            opp1.Agreement_Amount__c = 450000;
            opp1.Documentation_Charges__c = '2000';
            opp1.Applicant_Name__c = 'test';
            oppList.add(opp1);  
            
            
            Opportunity opp = TestDataUtility.createTestOpportunityForOcr(false); 
            opp.Sub_Stage__c = System.Label.Field_Investigation;
            opp.Is_Mobile_Journey_Completed__c = true;
            opp.Vehicle_Type__c = System.Label.used;
            opp.Product_Type__c = System.Label.Tractor;
            opp.Sanction_Status__c = System.Label.nonStp;  
            opp.Agent_BL_code__c = 'AHZ';
            opp.Deal_Number__c = null; 
            opp.AccountId = acc.Id;
            opp.Required_ROI__c = 9;
            opp.Sanction_Date__c = Date.newInstance(2022, 06, 11);
            opp.EMI_Amount__c = 10000;  
            opp.Agreement_Amount__c = 450000;
            opp.Documentation_Charges__c = '2000';
            opp.Applicant_Name__c = 'test';
            oppList.add(opp);  
            
            insert oppList;
            
            
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
           // dl.Sub_Stage__c = 'test';
            insert dl;

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
            
            INSERT applicantList;

            
            String docKycRecordTypeId = Schema.getGlobalDescribe().get('Documents__c').getDescribe().getRecordTypeInfosByName().get('KYC Document').getRecordTypeId();

            List<Documents__c> documentsList = new List<Documents__c>();
            Documents__c document1 = new Documents__c();
            document1.IHM_receipt_number__c = '2324';
            document1.Name = 'test document';
            document1.IHM_receipt_date__c = Date.newInstance(2022, 06, 19); 
            document1.IHM_amount_as_per_receipt__c = 35700;
            document1.Opportunity_Relation__c = oppList[0].Id;
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
            document1.Applicant__c = applicantList[0].Id;
            documentsList.add(document1);

            Documents__c document2 = new Documents__c();
            document2.IHM_receipt_number__c = '2324';
            document2.Name = 'test document';
            document2.IHM_receipt_date__c = Date.newInstance(2022, 06, 19); 
            document2.IHM_amount_as_per_receipt__c = 35700;
            document2.Opportunity_Relation__c = oppList[0].Id;
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
            document2.Applicant__c = applicantList[0].Id;
            documentsList.add(document2);

            Documents__c document3 = new Documents__c();
            document3.IHM_receipt_number__c = '2324';
            document3.Name = 'test document';
            document3.IHM_receipt_date__c = Date.newInstance(2022, 06, 19); 
            document3.IHM_amount_as_per_receipt__c = 35700;
            document3.Opportunity_Relation__c = oppList[0].Id;
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
            document3.Applicant__c = applicantList[0].Id;
            documentsList.add(document3);

            Documents__c document4 = new Documents__c();
            document4.IHM_receipt_number__c = '2324';
            document4.Name = 'test document';
            document4.IHM_receipt_date__c = Date.newInstance(2022, 06, 19); 
            document4.IHM_amount_as_per_receipt__c = 35700;
            document4.Opportunity_Relation__c = oppList[0].Id;
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
            document4.Applicant__c = applicantList[0].Id;
            documentsList.add(document4);

            Documents__c document5 = new Documents__c();
            document5.IHM_receipt_number__c = '2324';
            document5.Name = 'test document';
            document5.IHM_receipt_date__c = Date.newInstance(2022, 06, 19); 
            document5.IHM_amount_as_per_receipt__c = 35700;
            document5.Opportunity_Relation__c = oppList[0].Id;
            document5.Document_Type__c = System.Label.VoterIdCard;
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
            document6.Document_Type__c = System.Label.DrivingLicences;
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

            List<Income_Details__c> incomeDetailsList = new List<Income_Details__c>();
            Income_Details__c incomeDetails1 = new Income_Details__c();
            incomeDetails1.Office_Address_Line_1__c = 'test Office_Address_Line_1__c';
            incomeDetails1.Office_Address_Line_2__c =  'test Office_Address_Line_2__c';
            incomeDetails1.Office_State__c = 'MAHARASHTRA';
            incomeDetails1.Email_Id_1__c = 'test@abc.com';
            incomeDetails1.Applicant__c = applicantList[0].Id;
            incomeDetails1.Office_PinCode__c = '111045';
            incomeDetailsList.add(incomeDetails1);
            insert incomeDetailsList;

            //create InsuranceDetails__c records
            List<InsuranceDetails__c> insurList = new List<InsuranceDetails__c>();
            InsuranceDetails__c ins = new InsuranceDetails__c();
            ins.Name = 'iName';
            ins.Funded_Non_funded__c = 'Funded';
            ins.Amount__c = 100000;
            ins.Loan_Application__c = oppList[0].Id;
            insurList.add(ins);
            insert insurList;

            list<Geo_State_Masters__c> geoStateMasterlst = new list<Geo_State_Masters__c> ();
            Geo_State_Masters__c geoStateMaster = new Geo_State_Masters__c(Name = 'Rajasthan', State_Code__c = '27', NeSL_State_Code__c = 'MH', Pincode__c = 141, Pincode_Starting_Max__c = 141);
            geoStateMasterlst.add(geoStateMaster);
            insert geoStateMasterlst;

            List< SOC_Master__c > socMasterlst  = new List< SOC_Master__c > ();
            SOC_Master__c socMaster = new SOC_Master__c(From_Date__c = Date.newInstance(2022,06,10), Asset_val_charges__c ='At Actuals',	Cersairgnch__c ='At Actuals',	Cibil_charges__c = 'CIBIL / Other CI',	Closure_bank_acc_charges__c = '500',Colln_chrg_chq_rtn__c = 'Rs. 300 per Instance',	Collnchrgcash__c = 'upto 1% of Cash',	Collnchrgpdcs__c = 'Rs. 100 per Instan',	Compensation_charges__c = 'uyuyuuyuyu',	Due_date_charges__c = '@ Contracted Rate',	Dupnocch__c = '500 per Vehicle',	Fore_closure_charges__c='200',	Legal_repo_charges__c ='At Actuals',	Loancc__c = '1500 per case',	Nesl_registration_charges__c = 'At Actuals',	Nesl_renewal_charges__c = ' At Actuals',	Nocusageconv__c = 'NOC to convert fro',	Other_charges__c = 'At Actuals',	Over_due_int_mon__c = 'Upto 36% per Annum',	Pre_closure_charges__c = '2% - 5% of the',	Repay_dc__c = 'Upto Rs. 500 per',	Repay_dishonr_charges__c = '500',	Roc_consult_fee__c = 'At Actuals',	Roc_filing_charges__c = '2500',	Rto_registration_charges__c = 'At Actuals',	Sms_tc_charges__c = 'At Actuals',	Statement_charges__c = 'Statement of a/c c',	Swap_charges__c = 'upto Rs. 500 per S',	Tradecertch__c = 'At Actuals',	Travelcc__c = 'At Actuals',Vehicle_reg_hypothecation_verification__c = 'Vehicle registratn' );
            socMasterlst.add(socMaster);
            insert socMasterlst;

            List < Loan_Agreement__c> loanAgreementlst = new  List < Loan_Agreement__c> ();
            Loan_Agreement__c  loanAgreement = new Loan_Agreement__c();
            loanAgreement.Ist_EMI_Due_Date__c = Date.newInstance(2022, 08, 08);
            loanAgreement.X2nd_EMI_Due_Date__c = Date.newInstance(2022, 12, 08);
            loanAgreement.Geo_State_Code__c = '27';
            loanAgreement.AgreementDate__c = Date.today();
            loanAgreement.Effective_Deal_Date__c = Date.newInstance(2022, 12, 08);
            loanAgreement.Agreement_Type__c = null;
            loanAgreement.Add_POA_SD_Initiation_method__c = null;
            loanAgreement.Agreement_Booklet_Num__c = '64008873';
            loanAgreement.Total_POA_Stamping__c = null;
            loanAgreement.Loan_Application__c = oppList[0].Id;
            loanAgreementlst.add(loanAgreement);
            insert loanAgreementlst;

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
            
            List<Invoice_Details__c> invoiceDetailsList = new List<Invoice_Details__c>();
            Invoice_Details__c invoiceDetails = new Invoice_Details__c();
            invoiceDetails.Tax_Invoice_No__c = '434352';
            invoiceDetails.Tax_Invoice_Date__c = Date.newInstance(2022, 06, 03);
            invoiceDetails.Engine_No__c = '45435435';
            invoiceDetails.Chassis_No__c = '54354354';
            invoiceDetails.Invoice_Amount_incl_discounts__c  = 5424565;
            invoiceDetails.Loan_Application__c = oppList[0].Id;
            invoiceDetailsList.add(invoiceDetails);
            insert invoiceDetailsList;

            List<Structered_EMI__c> structeredEmiList = new List<Structered_EMI__c> ();
            Structered_EMI__c structeredEmi = new Structered_EMI__c ();
            structeredEmi.From_Month__c = 1;
            structeredEmi.To_Month__c = 9;
            structeredEmi.Number_of_Installments__c = 9;
            structeredEmi.EMI_Amount__c = 45000;
            structeredEmi.Loan_Application__c = oppList[0].Id;
            structeredEmiList.add(structeredEmi);
            insert structeredEmiList;

            //Create Stamp Detail
            List<Stamp_Detail__c> stampingList = new List<Stamp_Detail__c>();
            Stamp_Detail__c stampDetail1 = new Stamp_Detail__c();
            stampDetail1.Stamp_S_No__c = 'test';
            stampDetail1.Stamp_Type__c = 'test';
            stampDetail1.Stamp_Value__c = 10000;
            stampDetail1.Stamp_For__c = 'test';
            stampDetail1.Stamp_Date__c = System.today();
            stampDetail1.Stamp_Printed_Location_Blcode__c = 'a1234';
            stampDetail1.Loan_Agreement__c = loanAgreementlst[0].Id;
            stampingList.add(stampDetail1);
            insert stampingList;

            List<Benefi__c > benefiList = new List<Benefi__c > ();
            Benefi__c bnf1 = new Benefi__c();
            bnf1.Ben_code__c = 'testveh';
            bnf1.Name = 'test';
            bnf1.Dealer_Code__c = 'testdealer';
            bnf1.Dealership_Nature__c = 'MDR';
            bnf1.Indusind_AcNo__c = '12345678910';
            bnf1.Beneficiary__c = 'DSA';
            bnf1.Status_Flag__c = 'L';
            bnf1.Pseudo_DSM__c = 'Y';
            bnf1.Status_Flag__c = 'L';
            benefiList.add(bnf1);
            insert benefiList;

            List<Bl_Code_Details__c> blCodeDetails = new List<Bl_Code_Details__c> ();
            Bl_Code_Details__c bcd1 = new Bl_Code_Details__c();
            bcd1.Bl_Code__c = oppList[0].Agent_BL_code__c;
            bcd1.Name = 'test';
            blCodeDetails.add(bcd1);
            insert blCodeDetails;

            List<BankBranchDetails__c> bankBranchDetails = new List<BankBranchDetails__c> ();
            BankBranchDetails__c bd1 = new BankBranchDetails__c();
            bd1.City__c = 'pune';
            bd1.Address_1__c = 'testad1';
            bd1.Address_2__c = 'testad2';
            bd1.Address_3__c = 'testad3';
            bd1.Address_4__c = 'testad4';
            bd1.Bl_Code_Details__c = blCodeDetails[0].Id;
            bd1.UniqueIdentifier__c = 'A123';
            bankBranchDetails.add(bd1);
            insert bankBranchDetails;
            
        }
    }


    @isTest 
    public static void getHttpRequestHeadersTest(){
        try
        {            
            String docKycRecordTypeId = Schema.getGlobalDescribe().get('Documents__c').getDescribe().getRecordTypeInfosByName().get('KYC Document').getRecordTypeId();
            List<Applicant__c>  applicantList = [select Id, Name, Father_s_name__c, Opportunity__c, Who_will_repay_the_loan__c, Scorecard_Decision__c, Opportunity__r.Product_Type__c,Contact_Number__c, Applicant_Type__c, Email_Id_2__c,Email_Id_1__c, Email_Id__c, Opportunity__r.Account.Phone, (Select Id, KYC_State__c, KYC_No__c, Passport_No__c, Address_line_CR_1__c, Address_line_1_PR__c, Address_line_CR_2__c, Address_line_2_PR__c,KYC_Pin_Code__c,Document_Type__c, KYC_DOB__c From Documents__r Where RecordTypeId =: docKycRecordTypeId), (Select Id, Office_Address_Line_1__c, Office_Address_Line_2__c, Office_State__c, Email_Id_1__c, Office_PinCode__c From Income_Details__r )FROM Applicant__c Where Opportunity__r.Agent_BL_code__c = 'AHZ' AND Name = 'testapplicant1'];
            String loanAppId = applicantList[0].Opportunity__c;
            String initiationMethod = 'Face to Face';
            List<Documents__c> documentsList = [Select Id,IHM_receipt_number__c,Name,IHM_receipt_date__c,IHM_amount_as_per_receipt__c,Opportunity_Relation__c,Document_Type__c, KYC_State__c, KYC_Address_Line_2__c, KYC_Address_Line_1__c,KYC_No__c, Passport_No__c, Address_line_CR_1__c, Address_line_1_PR__c, Address_line_CR_2__c, Address_line_2_PR__c, KYC_Pin_Code__c, KYC_DOB__c, PAN_No__c  From Documents__c Where is_Active__c = true  LIMIT 1];
            List<InsuranceDetails__c> insurList = [Select id,Funded_Non_funded__c,Amount__c,Loan_Application__c From InsuranceDetails__c Where Loan_Application__c =: loanAppId AND Funded_Non_funded__c = 'Funded'];
            list<Geo_State_Masters__c> getStateMaster =[select State_Code__c,Name ,NeSL_State_Code__c from 	Geo_State_Masters__c];
            SOC_Master__c socMaster = [Select Id,From_Date__c, Asset_val_charges__c,	Cersairgnch__c,	Cibil_charges__c,	Closure_bank_acc_charges__c,Colln_chrg_chq_rtn__c,	Collnchrgcash__c,	Collnchrgpdcs__c,	Compensation_charges__c,	Due_date_charges__c,	Dupnocch__c,	Fore_closure_charges__c,	Legal_repo_charges__c,	Loancc__c,	Nesl_registration_charges__c,	Nesl_renewal_charges__c,	Nocusageconv__c,	Other_charges__c,	Over_due_int_mon__c,	Pre_closure_charges__c,	Repay_dc__c,	Repay_dishonr_charges__c,	Roc_consult_fee__c,	Roc_filing_charges__c,	Rto_registration_charges__c,	Sms_tc_charges__c,	Statement_charges__c,	Swap_charges__c,	Tradecertch__c,	Travelcc__c,Vehicle_reg_hypothecation_verification__c From SOC_Master__c Where From_Date__c <=: date.today() LIMIT 1];
            List<Structered_EMI__c> structeredEmiList = [Select Id,From_Month__c,To_Month__c,Number_of_Installments__c,EMI_Amount__c,Loan_Application__c From Structered_EMI__c Where Loan_Application__c =: loanAppId];
            List<Final_Term__c> finalTermList = [Select id,Installment_Type__c,EMI_Amount__c,Loan_Application__r.EMI_Amount__c,Tenure__c,Loan_Application__c From Final_Term__c Where Loan_Application__c =:  loanAppId LIMIT 1];
            List < Loan_Agreement__c> loanAgreementlst = [Select id, Geo_State_Code__c, Total_POA_Stamping__c,Total_Loan_Agreement_Stamp_Value__c, Loan_Application__r.Product_Type__c, Loan_Application__r.Applicant_Name__c From Loan_Agreement__c Where Loan_Application__c = :loanAppId];
            List<Stamp_Detail__c> stampingList = [Select Id,Stamp_S_No__c,Stamp_Type__c,Stamp_Value__c,Stamp_For__c,Stamp_Date__c,Stamp_Printed_Location_Blcode__c From Stamp_Detail__c WHERE Loan_Agreement__r.Loan_Application__c =: loanAppId ];
            List<Benefi__c > benefiList = [Select id, Dealership_Nature__c, Name From Benefi__c Where Ben_Code__c = 'testveh' ];
	
            List<BankBranchDetails__c> bankBranchDetails = [Select Id,City__c,Address_4__c,Address_3__c,Address_2__c,Address_1__c,Bl_Code__c From BankBranchDetails__c Where Bl_Code__c = 'AHZ'];
            Deal_Number__c dl=[Select Id From Deal_Number__c Limit 1];
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE UserName='test1_userprod123@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {
                IND_InitiateNeSLEAgreementRequest obj = new IND_InitiateNeSLEAgreementRequest(applicantList[0], loanAppId, initiationMethod, dl.Id);
                Map<String, String> requestHeaderMap = obj.getHttpRequestHeaders();
                
                finalTermList[0].Installment_Type__c = 'Structured';
                update finalTermList;
                
                IND_InitiateNeSLEAgreementRequest obj1 = new IND_InitiateNeSLEAgreementRequest(applicantList[0], loanAppId, initiationMethod, dl.Id);
               
                Documents__c doc1 = [SELECT id, Document_Type__c FROM Documents__c WHERE Document_Type__c =:System.Label.PanCards];
                //delete doc1;
                
                IND_InitiateNeSLEAgreementRequest obj2 = new IND_InitiateNeSLEAgreementRequest(applicantList[0], loanAppId, initiationMethod, dl.Id);

                Documents__c doc2 = [SELECT id, Document_Type__c FROM Documents__c WHERE Document_Type__c =:System.Label.VoterIdCard];
                delete doc2;
                
                IND_InitiateNeSLEAgreementRequest obj3 = new IND_InitiateNeSLEAgreementRequest(applicantList[0], loanAppId, initiationMethod,dl.Id);

                Documents__c doc3 = [SELECT id, Document_Type__c FROM Documents__c WHERE Document_Type__c =:System.Label.PassportCard];
                delete doc3;
                
                finalTermList[0].Installment_Type__c = '';
                update finalTermList;
                
                IND_InitiateNeSLEAgreementRequest obj4 = new IND_InitiateNeSLEAgreementRequest(applicantList[0], loanAppId, '', dl.Id);

                system.assertEquals(1, benefiList.size());
                system.assert(loanAgreementlst.size() >= 1);
                System.assert(!stampingList.isEmpty());
                System.assert(getStateMaster[0].State_Code__c == '27');
                System.assert(getStateMaster[0].NeSL_State_Code__c == 'MH');


            }
            Test.stopTest();
        }catch(Exception e)
        {
            String Error  = e.getMessage();
            //System.assertEquals('These fields are Madantory : 2nd documentID , Actual: These fields are Madantory : Loan number, Snct number, 2nd documentID ', Error);
        }

    }
	@isTest
    public static void getHttpRequestHeadersTest11(){
        try
        {            
            String docKycRecordTypeId = Schema.getGlobalDescribe().get('Documents__c').getDescribe().getRecordTypeInfosByName().get('KYC Document').getRecordTypeId();
            List<Applicant__c>  applicantList = [select Id, Name, Father_s_name__c, Opportunity__c, Who_will_repay_the_loan__c, Scorecard_Decision__c, Opportunity__r.Product_Type__c,Contact_Number__c, Applicant_Type__c, Email_Id_2__c,Email_Id_1__c, Email_Id__c, Opportunity__r.Account.Phone, (Select Id, KYC_State__c, KYC_No__c, Passport_No__c, Address_line_CR_1__c, Address_line_1_PR__c, Address_line_CR_2__c, Address_line_2_PR__c,KYC_Pin_Code__c,Document_Type__c, KYC_DOB__c From Documents__r Where RecordTypeId =: docKycRecordTypeId), (Select Id, Office_Address_Line_1__c, Office_Address_Line_2__c, Office_State__c, Email_Id_1__c, Office_PinCode__c From Income_Details__r )FROM Applicant__c Where Opportunity__r.Agent_BL_code__c = 'AHZ' AND Name = 'testapplicant1'];
             Deal_Number__c dl=[Select Id From Deal_Number__c Limit 1];
            String loanAppId = applicantList[0].Opportunity__c;
            String initiationMethod = 'Face to Face';
            
            Documents__c doc2 = [SELECT id, Document_Type__c FROM Documents__c WHERE Document_Type__c =:System.Label.AadhaarCard];
            delete doc2;
            
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE UserName='test1_userprod123@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {
                IND_InitiateNeSLEAgreementRequest obj = new IND_InitiateNeSLEAgreementRequest(applicantList[0], loanAppId, initiationMethod, dl.Id);
            }
            Test.stopTest();
        }catch(Exception e)
        {
            String Error  = e.getMessage();
            //System.assertEquals('These fields are Madantory : 2nd documentID , Actual: These fields are Madantory : Loan number, Snct number, 2nd documentID ', Error);
        }
    }   
    
    @isTest
    public static void getHttpRequestHeadersTest12(){
        try
        {            
            String docKycRecordTypeId = Schema.getGlobalDescribe().get('Documents__c').getDescribe().getRecordTypeInfosByName().get('KYC Document').getRecordTypeId();
            List<Applicant__c>  applicantList = [select Id, Name, Father_s_name__c, Opportunity__c, Who_will_repay_the_loan__c, Scorecard_Decision__c, Opportunity__r.Product_Type__c,Contact_Number__c, Applicant_Type__c, Email_Id_2__c,Email_Id_1__c, Email_Id__c, Opportunity__r.Account.Phone, (Select Id, KYC_State__c, KYC_No__c, Passport_No__c, Address_line_CR_1__c, Address_line_1_PR__c, Address_line_CR_2__c, Address_line_2_PR__c,KYC_Pin_Code__c,Document_Type__c, KYC_DOB__c From Documents__r Where RecordTypeId =: docKycRecordTypeId), (Select Id, Office_Address_Line_1__c, Office_Address_Line_2__c, Office_State__c, Email_Id_1__c, Office_PinCode__c From Income_Details__r )FROM Applicant__c Where Opportunity__r.Agent_BL_code__c = 'AHZ' AND Name = 'testapplicant1'];
            Deal_Number__c dl=[Select Id From Deal_Number__c Limit 1];
            String loanAppId = applicantList[0].Opportunity__c;
            String initiationMethod = 'Face to Face';
            
            List<Documents__c> doc2 = new List<Documents__c>([SELECT id, Document_Type__c FROM Documents__c WHERE Document_Type__c =:System.Label.AadhaarCard OR Document_Type__c = :System.Label.PassportCard]);
            delete doc2;
            
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE UserName='test1_userprod123@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {
                IND_InitiateNeSLEAgreementRequest obj = new IND_InitiateNeSLEAgreementRequest(applicantList[0], loanAppId, initiationMethod, dl.Id);
            }
            Test.stopTest();
        }catch(Exception e)
        {
            String Error  = e.getMessage();
            //System.assertEquals('These fields are Madantory : 2nd documentID , Actual: These fields are Madantory : Loan number, Snct number, 2nd documentID ', Error);
        }
    }  
    
    @isTest
    public static void getHttpRequestHeadersTest13(){
        try
        {            
            String docKycRecordTypeId = Schema.getGlobalDescribe().get('Documents__c').getDescribe().getRecordTypeInfosByName().get('KYC Document').getRecordTypeId();
            List<Applicant__c>  applicantList = [select Id, Name, Father_s_name__c, Opportunity__c, Who_will_repay_the_loan__c, Scorecard_Decision__c, Opportunity__r.Product_Type__c,Contact_Number__c, Applicant_Type__c, Email_Id_2__c,Email_Id_1__c, Email_Id__c, Opportunity__r.Account.Phone, (Select Id, KYC_State__c, KYC_No__c, Passport_No__c, Address_line_CR_1__c, Address_line_1_PR__c, Address_line_CR_2__c, Address_line_2_PR__c,KYC_Pin_Code__c,Document_Type__c, KYC_DOB__c From Documents__r Where RecordTypeId =: docKycRecordTypeId), (Select Id, Office_Address_Line_1__c, Office_Address_Line_2__c, Office_State__c, Email_Id_1__c, Office_PinCode__c From Income_Details__r )FROM Applicant__c Where Opportunity__r.Agent_BL_code__c = 'AHZ' AND Name = 'testapplicant1'];
             Deal_Number__c dl=[Select Id From Deal_Number__c Limit 1];
            String loanAppId = applicantList[0].Opportunity__c;
            String initiationMethod = 'Face to Face';
            
            Documents__c doc1 = [SELECT id, Document_Type__c FROM Documents__c WHERE Document_Type__c =:System.Label.PanCards];
            delete doc1;
            
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE UserName='test1_userprod123@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {
                IND_InitiateNeSLEAgreementRequest obj = new IND_InitiateNeSLEAgreementRequest(applicantList[0], loanAppId, initiationMethod,dl.Id);
            }
            Test.stopTest();
        }catch(Exception e)
        {
            String Error  = e.getMessage();
            //System.assertEquals('These fields are Madantory : 2nd documentID , Actual: These fields are Madantory : Loan number, Snct number, 2nd documentID ', Error);
        }
    }
    
    @isTest
    public static void getHttpRequestHeadersTest14(){
        try
        {            
            String docKycRecordTypeId = Schema.getGlobalDescribe().get('Documents__c').getDescribe().getRecordTypeInfosByName().get('KYC Document').getRecordTypeId();
            List<Applicant__c>  applicantList = [select Id, Name, Father_s_name__c, Opportunity__c, Who_will_repay_the_loan__c, Scorecard_Decision__c, Opportunity__r.Product_Type__c,Contact_Number__c, Applicant_Type__c, Email_Id_2__c,Email_Id_1__c, Email_Id__c, Opportunity__r.Account.Phone, (Select Id, KYC_State__c, KYC_No__c, Passport_No__c, Address_line_CR_1__c, Address_line_1_PR__c, Address_line_CR_2__c, Address_line_2_PR__c,KYC_Pin_Code__c,Document_Type__c, KYC_DOB__c From Documents__r Where RecordTypeId =: docKycRecordTypeId), (Select Id, Office_Address_Line_1__c, Office_Address_Line_2__c, Office_State__c, Email_Id_1__c, Office_PinCode__c From Income_Details__r )FROM Applicant__c Where Opportunity__r.Agent_BL_code__c = 'AHZ' AND Name = 'testapplicant1'];
            Deal_Number__c dl=[Select Id From Deal_Number__c Limit 1];
            String loanAppId = applicantList[0].Opportunity__c;
            String initiationMethod = 'Face to Face';
            
            Documents__c doc1 = [SELECT id, Document_Type__c FROM Documents__c WHERE Document_Type__c =:System.Label.VoterIdCard];
            delete doc1;
            
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE UserName='test1_userprod123@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {
                IND_InitiateNeSLEAgreementRequest obj = new IND_InitiateNeSLEAgreementRequest(applicantList[0], loanAppId, initiationMethod,dl.Id);
            }
            Test.stopTest();
        }catch(Exception e)
        {
            String Error  = e.getMessage();
            //System.assertEquals('These fields are Madantory : 2nd documentID , Actual: These fields are Madantory : Loan number, Snct number, 2nd documentID ', Error);
        }
    }
    
    @isTest
    public static void getHttpRequestHeadersTest15(){
        try
        {            
            String docKycRecordTypeId = Schema.getGlobalDescribe().get('Documents__c').getDescribe().getRecordTypeInfosByName().get('KYC Document').getRecordTypeId();
            List<Applicant__c>  applicantList = [select Id, Name, Father_s_name__c, Opportunity__c, Who_will_repay_the_loan__c, Scorecard_Decision__c, Opportunity__r.Product_Type__c,Contact_Number__c, Applicant_Type__c, Email_Id_2__c,Email_Id_1__c, Email_Id__c, Opportunity__r.Account.Phone, (Select Id, KYC_State__c, KYC_No__c, Passport_No__c, Address_line_CR_1__c, Address_line_1_PR__c, Address_line_CR_2__c, Address_line_2_PR__c,KYC_Pin_Code__c,Document_Type__c, KYC_DOB__c From Documents__r Where RecordTypeId =: docKycRecordTypeId), (Select Id, Office_Address_Line_1__c, Office_Address_Line_2__c, Office_State__c, Email_Id_1__c, Office_PinCode__c From Income_Details__r )FROM Applicant__c Where Opportunity__r.Agent_BL_code__c = 'AHZ' AND Name = 'testapplicant1'];
            Deal_Number__c dl=[Select Id From Deal_Number__c Limit 1];
            String loanAppId = applicantList[0].Opportunity__c;
            String initiationMethod = 'Face to Face';
            
            Documents__c doc1 = [SELECT id, Document_Type__c FROM Documents__c WHERE Document_Type__c =:System.Label.PassportCard];
            delete doc1;
            
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE UserName='test1_userprod123@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {
                IND_InitiateNeSLEAgreementRequest obj = new IND_InitiateNeSLEAgreementRequest(applicantList[0], loanAppId, initiationMethod, dl.Id);
            }
            Test.stopTest();
        }catch(Exception e)
        {
            String Error  = e.getMessage();
            //System.assertEquals('These fields are Madantory : 2nd documentID , Actual: These fields are Madantory : Loan number, Snct number, 2nd documentID ', Error);
        }
    }
    
    @isTest
    public static void getHttpRequestHeadersTest1(){
        try
        {            
            String docKycRecordTypeId = Schema.getGlobalDescribe().get('Documents__c').getDescribe().getRecordTypeInfosByName().get('KYC Document').getRecordTypeId();
            List<Applicant__c>  applicantList = [select Id, Name, Father_s_name__c, Opportunity__c, Who_will_repay_the_loan__c, Scorecard_Decision__c, Opportunity__r.Product_Type__c,Contact_Number__c, Applicant_Type__c, Email_Id_2__c,Email_Id_1__c, Email_Id__c, Opportunity__r.Account.Phone, (Select Id, KYC_State__c, KYC_No__c, Passport_No__c, Address_line_CR_1__c, Address_line_1_PR__c, Address_line_CR_2__c, Address_line_2_PR__c,KYC_Pin_Code__c,Document_Type__c, KYC_DOB__c From Documents__r Where RecordTypeId =: docKycRecordTypeId), (Select Id, Office_Address_Line_1__c, Office_Address_Line_2__c, Office_State__c, Email_Id_1__c, Office_PinCode__c From Income_Details__r )FROM Applicant__c Where Opportunity__r.Agent_BL_code__c = 'AHZ' AND Name = 'testapplicant1'];
             Deal_Number__c dl=[Select Id From Deal_Number__c Limit 1];
            String loanAppId = applicantList[0].Opportunity__c;
            String initiationMethod = 'Face to Face';
            Final_Term__c finalTerm = [Select Id,Installment_Type__c From Final_Term__c Where Loan_Application__c =: loanAppId];
			finalTerm.Installment_Type__c = 'Structured';
            update finalTerm;
            
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE UserName='test1_userprod123@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {
                IND_InitiateNeSLEAgreementRequest obj = new IND_InitiateNeSLEAgreementRequest(applicantList[0], loanAppId, initiationMethod, dl.Id);
            }
            Test.stopTest();
        }catch(Exception e)
        {
            String Error  = e.getMessage();
            //System.assertEquals('These fields are Madantory : 2nd documentID , Actual: These fields are Madantory : Loan number, Snct number, 2nd documentID ', Error);
        }
    }
    
    @isTest
    public static void getHttpRequestHeadersTest2(){
        try
        {            
            String docKycRecordTypeId = Schema.getGlobalDescribe().get('Documents__c').getDescribe().getRecordTypeInfosByName().get('KYC Document').getRecordTypeId();
            List<Applicant__c>  applicantList = [select Id, Name, Father_s_name__c, Opportunity__c, Who_will_repay_the_loan__c, Scorecard_Decision__c, Opportunity__r.Product_Type__c,Contact_Number__c, Applicant_Type__c, Email_Id_2__c,Email_Id_1__c, Email_Id__c, Opportunity__r.Account.Phone, (Select Id, KYC_State__c, KYC_No__c, Passport_No__c, Address_line_CR_1__c, Address_line_1_PR__c, Address_line_CR_2__c, Address_line_2_PR__c,KYC_Pin_Code__c,Document_Type__c, KYC_DOB__c From Documents__r Where RecordTypeId =: docKycRecordTypeId), (Select Id, Office_Address_Line_1__c, Office_Address_Line_2__c, Office_State__c, Email_Id_1__c, Office_PinCode__c From Income_Details__r )FROM Applicant__c Where Opportunity__r.Agent_BL_code__c = 'AHZ' AND Name = 'testapplicant1'];
            Deal_Number__c dl=[Select Id From Deal_Number__c Limit 1];
            String loanAppId = applicantList[0].Opportunity__c;
            String initiationMethod = 'Face to Face';
            Final_Term__c finalTerm = [Select Id,Installment_Type__c From Final_Term__c Where Loan_Application__c =: loanAppId];
			finalTerm.Installment_Type__c = '';
            update finalTerm;
            
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE UserName='test1_userprod123@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {
                IND_InitiateNeSLEAgreementRequest obj = new IND_InitiateNeSLEAgreementRequest(applicantList[0], loanAppId, initiationMethod, dl.Id);
            }
            Test.stopTest();
        }catch(Exception e)
        {
            String Error  = e.getMessage();
            //System.assertEquals('These fields are Madantory : 2nd documentID , Actual: These fields are Madantory : Loan number, Snct number, 2nd documentID ', Error);
        }
    }
    
    @isTest
    public static void getHttpRequestHeadersTest3(){
        try
        {            
            String docKycRecordTypeId = Schema.getGlobalDescribe().get('Documents__c').getDescribe().getRecordTypeInfosByName().get('KYC Document').getRecordTypeId();
            List<Applicant__c>  applicantList = [select Id, Name, Father_s_name__c, Opportunity__c, Who_will_repay_the_loan__c, Scorecard_Decision__c, Opportunity__r.Product_Type__c,Contact_Number__c, Applicant_Type__c, Email_Id_2__c,Email_Id_1__c, Email_Id__c, Opportunity__r.Account.Phone, (Select Id, KYC_State__c, KYC_No__c, Passport_No__c, Address_line_CR_1__c, Address_line_1_PR__c, Address_line_CR_2__c, Address_line_2_PR__c,KYC_Pin_Code__c,Document_Type__c, KYC_DOB__c From Documents__r Where RecordTypeId =: docKycRecordTypeId), (Select Id, Office_Address_Line_1__c, Office_Address_Line_2__c, Office_State__c, Email_Id_1__c, Office_PinCode__c From Income_Details__r )FROM Applicant__c Where Opportunity__r.Agent_BL_code__c = 'AHZ' AND Name = 'testapplicant1'];
           Deal_Number__c dl=[Select Id From Deal_Number__c Limit 1];
            String loanAppId = applicantList[0].Opportunity__c;
            String initiationMethod = 'Face to Face';
            Final_Term__c finalTerm = [Select Id,Installment_Type__c From Final_Term__c Where Loan_Application__c =: loanAppId];
			finalTerm.Installment_Type__c = 'Structured';
            update finalTerm;
            List<Structered_EMI__c> strList = new List<Structered_EMI__c>([Select Id From Structered_EMI__c Where Loan_Application__c =: loanAppId]);
            delete strList;
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE UserName='test1_userprod123@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {
                IND_InitiateNeSLEAgreementRequest obj = new IND_InitiateNeSLEAgreementRequest(applicantList[0], loanAppId, initiationMethod,dl.Id);
            }
            Test.stopTest();
        }catch(Exception e)
        {
            String Error  = e.getMessage();
            //System.assertEquals('These fields are Madantory : 2nd documentID , Actual: These fields are Madantory : Loan number, Snct number, 2nd documentID ', Error);
        }
    }
    
     @isTest
    public static void getHttpRequestHeadersTest4(){
        try
        {            
            String docKycRecordTypeId = Schema.getGlobalDescribe().get('Documents__c').getDescribe().getRecordTypeInfosByName().get('KYC Document').getRecordTypeId();
            List<Applicant__c>  applicantList = [select Id, Name, Father_s_name__c, Opportunity__c, Who_will_repay_the_loan__c, Scorecard_Decision__c, Opportunity__r.Product_Type__c,Contact_Number__c, Applicant_Type__c, Email_Id_2__c,Email_Id_1__c, Email_Id__c, Opportunity__r.Account.Phone, (Select Id, KYC_State__c, KYC_No__c, Passport_No__c, Address_line_CR_1__c, Address_line_1_PR__c, Address_line_CR_2__c, Address_line_2_PR__c,KYC_Pin_Code__c,Document_Type__c, KYC_DOB__c From Documents__r Where RecordTypeId =: docKycRecordTypeId), (Select Id, Office_Address_Line_1__c, Office_Address_Line_2__c, Office_State__c, Email_Id_1__c, Office_PinCode__c From Income_Details__r )FROM Applicant__c Where Opportunity__r.Agent_BL_code__c = 'AHZ' AND Name = 'testapplicant1'];
             Deal_Number__c dl=[Select Id From Deal_Number__c Limit 1];
            String loanAppId = applicantList[0].Opportunity__c;
            String initiationMethod = 'Face to Face';
            Final_Term__c finalTerm = [Select Id From Final_Term__c Where Loan_Application__c =: loanAppId];
			delete finalTerm;
            
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE UserName='test1_userprod123@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {
                IND_InitiateNeSLEAgreementRequest obj = new IND_InitiateNeSLEAgreementRequest(applicantList[0], loanAppId, initiationMethod,dl.Id);
            }
            Test.stopTest();
        }catch(Exception e)
        {
            String Error  = e.getMessage();
            //System.assertEquals('These fields are Madantory : 2nd documentID , Actual: These fields are Madantory : Loan number, Snct number, 2nd documentID ', Error);
        }
    }


}