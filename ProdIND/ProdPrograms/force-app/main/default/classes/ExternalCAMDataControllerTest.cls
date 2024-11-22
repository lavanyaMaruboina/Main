@isTest
public class ExternalCAMDataControllerTest {
    
    @testSetup
    public static void testSetup(){
        //create user
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u = new User(Alias = 'standt2', Email='standarduser2@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,Maker_Id__c='12',IsActive = true,
                          TimeZoneSidKey='America/Los_Angeles',UserName='test_userprod123@indusbank.com.uat',MobilePhone = '9089078967');
        insert u;   
        
        System.runAs(u) 
        {  
            Account testAccount = new Account(Name = 'Test view Acc' ,BranchBLCode__c = '34543');
            insert testAccount;
            
            Account parentAccount = new Account(Name = 'Parent Account Test' ,BranchBLCode__c = '34589');
            insert parentAccount;
            
            
            
            // ------------Opportunity 
            Opportunity opp = new Opportunity();
            opp.AccountId = testAccount.Id; 
            opp.Name= 'Opportunity Test';
            opp.StageName='Qualification';
            opp.CloseDate=System.today().addMonths(2);
            opp.Vehicle_Sub_Category__c= 'UIM';
            opp.Employee_Branch__c = 'Test Employee Branch';
            opp.Gross_IRR__c = 5353;
            opp.NOC_Number__c = 45654;
            opp.Funding_on_ORP__c = true;
            opp.Advance_EMI__c = true;
            opp.Customer_Code__c = '896745';
            opp.Deal_Number__c = 'TUT06226H';
            opp.Funding_on_Ex_Showroom__c = true;
            opp.Basic_Price__c = 67000;
            opp.Discount_on_Basic_Price__c = 6000;
            opp.Funding_on_ORP__c = false;
            opp.RTO_Road_Tax_New__c = 6000;
            opp.X1st_yr_Insurance_Premium__c = 1400;
            opp.Other_charges__c = 2000;
            opp.GST_Amount__c = 10999;
            opp.Agent_BL_code__c='MPP';
            opp.Sub_Stage__c = 'Field Investigation';
            opp.Service_Charges__c = '600';
            opp.Documentation_Charges__c = '500';
            opp.Dealer_Expence_Reimburse_Amt__c = '400';
            opp.DSM_Incentive1__c = 4003;
            opp.Loan_amount__c='500000';  
            opp.OTP_for_borrower__c='3999';
            opp.Applicant_Name__c='Test Applicant';
            opp.Mfr_Incentive__c=98;
            opp.Gift_through_Dealer_Amount__c='1466';
            opp.Required_Tenure__c=8;
            opp.Required_ROI__c=4;
            opp.Parent_Deal_number__c='7678';
            opp.Vehicle_Type__c = 'Used';
            opp.Product_Type__c = 'Two Wheeler';      
            insert opp;
            
            //----------Parent CAM
            CAM__c parentCam = new CAM__c();
            parentCam.Loan_Application__c = opp.Id;
            parentCam.BE_CVO_Remark__c = 'testbeCVO';
            parentCam.Is_Hold__c = true;
            parentCam.Conditional_Approval__c = 'testapproved';
            parentCam.Proposal_Status__c = 'Approved';
            insert parentCam;
            
            
            
            //  Applicant 
            Applicant__c applicant =new Applicant__c(Name='test',
                                                     Contact_Number__c ='1234567891',
                                                     Opportunity__c = opp.Id,
                                                     Customer_First_Name__c='GOURAB',
                                                     In_Active_Applicant__c = false,
                                                     Customer_Last_Name__c='GOSWAMI',
                                                     Whatsapp_number__c='1231231231',
                                                     Consent_Received__c=true,
                                                     Income_Ca__c='SAL',
                                                     Profile__c = 'Software Engineer',
                                                     Bureau_Pull_Attempts__c=1,
                                                     Selfie_Retry_Attempts__c=2,
                                                     Income_Source__c='Non-Earning',
                                                     Income_source_available__c = true,
                                                     Preferred_address_for_communication__c = 'Permanent Address',
                                                     of_family_members_residing_with_you__c = '2',
                                                     Residence_country__c = 'India',
                                                     Who_will_repay_the_loan__c = 'Borrower',
                                                     Marital_status__c = 'SINGP',
                                                     Spouse_Name__c = 'Sameer',
                                                     Father_s_name__c = 'Viraa',
                                                     Mother_s_name__c = 'Neeta',
                                                     Communication_language__c = 'Hindi',
                                                     Customer_Qualification__c = 'B2',
                                                     Email_Id__c = 'riya@gmail.com',
                                                     PAN_No__c ='BNIPM6633A',
                                                     DocAuth_Application_Id__c = 'AC1241_24524353_g1',
                                                     Applicant_Type__c ='Borrower',
                                                     Scorecard_Decision__c = 'Dark Green',
                                                     Current_Same_As_Permanent__c=true,
                                                     Consent_Sent__c=DateTime.valueOf(DateTime.now().getTime()-4));
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert applicant;
            }
            
            
            CIBIL_Details__c cibil_Detail=new CIBIL_Details__c(
                Other_Loan_AD__c=null,
                Term_Loan_AD__c=null,
                Other_Loan_PD__c=null,
                Term_Loan_PD__c=null,
                Overdue_Account__c=null,
                Applicant__c=applicant.Id);
            insert cibil_Detail;
            
            External_CAM_Data__c external_Cam_Data=new External_CAM_Data__c();
            external_Cam_Data.CAM__c=parentCam.Id;
            external_Cam_Data.Applicant__c=applicant.Id;
            insert external_Cam_Data;
            
            
            Documents__c document = new Documents__c(
                Opportunity_Relation__c = opp.Id,
                Applicant__c = applicant.Id,
                Document_Type__c = 'Signature',
                is_Active__c=true,
                Current_Residential_Address_Proof__c=true,
                KYC_Address_Line_1__c='Dummy Address 1',
                KYC_Address_Line_2__c='Dummy Address 2',
                Permanent_Residential_Address_Proof__c=true
            );
            
            insert document;
            
            Income_Details__c incomeDetail=new Income_Details__c(
                Office_Address_Line_1__c='dummy Address 1',
                Office_Address_Line_2__c='dummy Adrress 2',
                Applicant__c=applicant.Id
            );
            insert incomeDetail;
            
            Final_Term__c finalTeram = new Final_Term__c();
            finalTeram.CRM_IRR__c = 120;
            finalTeram.Loan_Application__c = opp.Id;
            finalTeram.Holiday_period__c='30';
            finalTeram.EMI_Amount__c= 10000;
            finalTeram.FIwaiver_offAddress__c = 'Not Waived';
            finalTeram.Tenure__c = '50';
            finalTeram.Inputted_IRR__c = 12;
            insert finalTeram;
            
            ContentVersion cv=new Contentversion();
            cv.title='ABC';
            cv.PathOnClient ='test';
            Blob b=Blob.valueOf('Unit Test Attachment Body');
            cv.versiondata=EncodingUtil.base64Decode('Unit Test Attachment Body');
            insert cv;
            
            List<ContentDocument> contentDocuments = [SELECT Id, Title, LatestPublishedVersionId  FROM ContentDocument];
            
            ContentDocumentLink contentDocumentLink = new ContentDocumentLink(
                ContentDocumentId = contentDocuments.get(0).Id,
                LinkedEntityId = document.Id,
                ShareType = 'V'
            );
            insert contentDocumentLink;                          
        }
    }
    
    @isTest 
    public static void storingExternalCAMDataCAMPortfolio(){
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            List<Opportunity> opportunityList=[select Id,Name From Opportunity limit 1];
            List<CAM__c>camList=[select Id,Name from CAM__c limit 1];
            List<Applicant__c>applicantList=[Select id,Name From Applicant__c limit 1];
            String Response='{ "status": "SUCCESS", "respDesc": "CAM Portfolio", "content": [ { "PANA_DT": [ { "Name": "BC                  ", "Year": "PANA 1st Year (Apr.2023- Mar.2024)", "Tot_Deals": "0", "Adv_Nos": "0", "Adv_Amt": "0.0000", "NoDue_Nos": "0", "NoDue_LOS": "0.0000", "STD1_Nos": "0", "STD1_LOS": "0.0000", "STD2_Nos": "0", "STD2_LOS": "0.0000", "STD3_Nos": "0", "STD3_LOS": "0.0000", "NPA1_Nos": "0", "NPA1_LOS": "0.0000", "NPA2_Nos": "0", "NPA2_LOS": "0.0000", "NPA3_Nos": "0", "NPA3_LOS": "0.0000", "NPAA_Nos": "0", "NPAA_LOS": "0.0000", "Tot_Nos": "0", "Tot_LOS": "0.0000" }, { "Name": "BC                  ", "Year": "PANA 2nd Year (Apr.2022- Mar.2023)", "Tot_Deals": "0", "Adv_Nos": "0", "Adv_Amt": "0.0000", "NoDue_Nos": "0", "NoDue_LOS": "0.0000", "STD1_Nos": "0", "STD1_LOS": "0.0000", "STD2_Nos": "0", "STD2_LOS": "0.0000", "STD3_Nos": "0", "STD3_LOS": "0.0000", "NPA1_Nos": "0", "NPA1_LOS": "0.0000", "NPA2_Nos": "0", "NPA2_LOS": "0.0000", "NPA3_Nos": "0", "NPA3_LOS": "0.0000", "NPAA_Nos": "0", "NPAA_LOS": "0.0000", "Tot_Nos": "0", "Tot_LOS": "0.0000" }, { "Name": "BC                  ", "Year": "PANA 3rd Year (Apr.2021- Mar.2022)", "Tot_Deals": "0", "Adv_Nos": "0", "Adv_Amt": "0.0000", "NoDue_Nos": "0", "NoDue_LOS": "0.0000", "STD1_Nos": "0", "STD1_LOS": "0.0000", "STD2_Nos": "0", "STD2_LOS": "0.0000", "STD3_Nos": "0", "STD3_LOS": "0.0000", "NPA1_Nos": "0", "NPA1_LOS": "0.0000", "NPA2_Nos": "0", "NPA2_LOS": "0.0000", "NPA3_Nos": "0", "NPA3_LOS": "0.0000", "NPAA_Nos": "0", "NPAA_LOS": "0.0000", "Tot_Nos": "0", "Tot_LOS": "0.0000" } ], "DPD_DT": null, "CIBIL_Dt": [ { "CIC_No": "0104202312582428609", "Account_Segment_Tag": "T022", "Reporting_Member_ShortName": "INDUSIND BANK", "Account_Number": "OCL00547C", "Account_Type": "1", "Owenership_Indicator": "1", "DateOpened_Or_Disbursed": "16062017", "Date_Of_Last_Payment": "21092021", "Date_Closed": "31102021", "Date_Reported": "", "HighCredit_Or_SanctionedAmount": "1358000.0000", "Current_Balance": "0.0000", "Amount_Overdue": "0.0000", "Payment_History1": "000XXX000000000000000", "Payment_History2": "", "Payment_History_StartDate": "01112021", "Payment_History_EndDate": "01122018", "SuitFiledOrWilfulDefault": "", "WrittenOffAndSettled": "", "ValueOfCollateral": "0.0000", "TypeOfCollateral": "", "CreditLimit": "0.0000", "CashLimit": "0.0000", "RateOfInterest": "0.0000", "RepaymentTenure": "52", "EmiAmount": "0.0000", "PaymentFrequency": "03", "ActualPaymentAmount": "0.0000", "WrittenoffAmountTotal": "0.0000", "WrittenoffAmountPrincipal": "0.0000", "SettlementAmount": "0.0000" }, { "CIC_No": "0104202312582428609", "Account_Segment_Tag": "T026", "Reporting_Member_ShortName": "NOT DISCLOSED", "Account_Number": "", "Account_Type": "1", "Owenership_Indicator": "4", "DateOpened_Or_Disbursed": "02122016", "Date_Of_Last_Payment": "29042021", "Date_Closed": "        ", "Date_Reported": "", "HighCredit_Or_SanctionedAmount": "667000.0000", "Current_Balance": "0.0000", "Amount_Overdue": "0.0000", "Payment_History1": "000000000000000000000000000000000000000000000000000000000000000000", "Payment_History2": "", "Payment_History_StartDate": "01022023", "Payment_History_EndDate": "01032020", "SuitFiledOrWilfulDefault": "", "WrittenOffAndSettled": "", "ValueOfCollateral": "0.0000", "TypeOfCollateral": "", "CreditLimit": "0.0000", "CashLimit": "0.0000", "RateOfInterest": "0.0000", "RepaymentTenure": "34", "EmiAmount": "21646.0000", "PaymentFrequency": "03", "ActualPaymentAmount": "3828.0000", "WrittenoffAmountTotal": "0.0000", "WrittenoffAmountPrincipal": "0.0000", "SettlementAmount": "0.0000" }, { "CIC_No": "0104202312582428609", "Account_Segment_Tag": "T001", "Reporting_Member_ShortName": "NOT DISCLOSED", "Account_Number": "", "Account_Type": "2", "Owenership_Indicator": "4", "DateOpened_Or_Disbursed": "16042015", "Date_Of_Last_Payment": "20012023", "Date_Closed": "        ", "Date_Reported": "", "HighCredit_Or_SanctionedAmount": "1228000.0000", "Current_Balance": "954999.0000", "Amount_Overdue": "24953.0000", "Payment_History1": "071STDSTDSTDSTDSTDSTDSTDSTDSTDSTDSTDSTDSTDSTDSTDSTDSTDSTDSTDSTDSTDSTD", "Payment_History2": "", "Payment_History_StartDate": "01032023", "Payment_History_EndDate": "01042020", "SuitFiledOrWilfulDefault": "", "WrittenOffAndSettled": "12", "ValueOfCollateral": "0.0000", "TypeOfCollateral": "01", "CreditLimit": "0.0000", "CashLimit": "0.0000", "RateOfInterest": "7.2500", "RepaymentTenure": "140", "EmiAmount": "11577.0000", "PaymentFrequency": "03", "ActualPaymentAmount": "323852.0000", "WrittenoffAmountTotal": "0.0000", "WrittenoffAmountPrincipal": "0.0000", "SettlementAmount": "0.0000" }, { "CIC_No": "0104202312582428609", "Account_Segment_Tag": "T002", "Reporting_Member_ShortName": "NOT DISCLOSED", "Account_Number": "", "Account_Type": "2", "Owenership_Indicator": "4", "DateOpened_Or_Disbursed": "16072020", "Date_Of_Last_Payment": "28022023", "Date_Closed": "        ", "Date_Reported": "", "HighCredit_Or_SanctionedAmount": "1768315.0000", "Current_Balance": "1683884.0000", "Amount_Overdue": "14156.0000", "Payment_History1": "011STDSTDSTDSTDSTDSTDSTDSTDSTDSTDSTDSTDSTDSTDSTDSTDSTDSTDSTDSTDSTDSTD", "Payment_History2": "", "Payment_History_StartDate": "01032023", "Payment_History_EndDate": "01072020", "SuitFiledOrWilfulDefault": "", "WrittenOffAndSettled": "", "ValueOfCollateral": "0.0000", "TypeOfCollateral": "01", "CreditLimit": "0.0000", "CashLimit": "0.0000", "RateOfInterest": "9.5500", "RepaymentTenure": "227", "EmiAmount": "14126.0000", "PaymentFrequency": "03", "ActualPaymentAmount": "426836.0000", "WrittenoffAmountTotal": "0.0000", "WrittenoffAmountPrincipal": "0.0000", "SettlementAmount": "0.0000" }, { "CIC_No": "0104202312582428609", "Account_Segment_Tag": "T043", "Reporting_Member_ShortName": "NOT DISCLOSED", "Account_Number": "", "Account_Type": "9", "Owenership_Indicator": "4", "DateOpened_Or_Disbursed": "23042010", "Date_Of_Last_Payment": "", "Date_Closed": "        ", "Date_Reported": "", "HighCredit_Or_SanctionedAmount": "1200000.0000", "Current_Balance": "1192491.0000", "Amount_Overdue": "0.0000", "Payment_History1": "000000000000XXXXXXSMASTDSMASMAXXX000000000000000000000000000000000", "Payment_History2": "", "Payment_History_StartDate": "01022023", "Payment_History_EndDate": "01052020", "SuitFiledOrWilfulDefault": "", "WrittenOffAndSettled": "", "ValueOfCollateral": "101213.0000", "TypeOfCollateral": "04", "CreditLimit": "0.0000", "CashLimit": "0.0000", "RateOfInterest": "10.9500", "RepaymentTenure": "0", "EmiAmount": "0.0000", "PaymentFrequency": "", "ActualPaymentAmount": "0.0000", "WrittenoffAmountTotal": "0.0000", "WrittenoffAmountPrincipal": "0.0000", "SettlementAmount": "0.0000" }, { "CIC_No": "0104202312582428609", "Account_Segment_Tag": "T004", "Reporting_Member_ShortName": "NOT DISCLOSED", "Account_Number": "", "Account_Type": "17", "Owenership_Indicator": "1", "DateOpened_Or_Disbursed": "31012023", "Date_Of_Last_Payment": "", "Date_Closed": "        ", "Date_Reported": "", "HighCredit_Or_SanctionedAmount": "4350000.0000", "Current_Balance": "4350000.0000", "Amount_Overdue": "0.0000", "Payment_History1": "000000", "Payment_History2": "", "Payment_History_StartDate": "01022023", "Payment_History_EndDate": "01012023", "SuitFiledOrWilfulDefault": "", "WrittenOffAndSettled": "", "ValueOfCollateral": "0.0000", "TypeOfCollateral": "", "CreditLimit": "0.0000", "CashLimit": "0.0000", "RateOfInterest": "0.0000", "RepaymentTenure": "59", "EmiAmount": "95580.0000", "PaymentFrequency": "03", "ActualPaymentAmount": "4350000.0000", "WrittenoffAmountTotal": "0.0000", "WrittenoffAmountPrincipal": "0.0000", "SettlementAmount": "0.0000" }, { "CIC_No": "0104202312582428609", "Account_Segment_Tag": "T005", "Reporting_Member_ShortName": "INDUSIND BANK", "Account_Number": "OCL01529D", "Account_Type": "17", "Owenership_Indicator": "4", "DateOpened_Or_Disbursed": "11112022", "Date_Of_Last_Payment": "07022023", "Date_Closed": "        ", "Date_Reported": "", "HighCredit_Or_SanctionedAmount": "1400000.0000", "Current_Balance": "1296029.0000", "Amount_Overdue": "0.0000", "Payment_History1": "000000000000", "Payment_History2": "", "Payment_History_StartDate": "01022023", "Payment_History_EndDate": "01112022", "SuitFiledOrWilfulDefault": "", "WrittenOffAndSettled": "", "ValueOfCollateral": "0.0000", "TypeOfCollateral": "", "CreditLimit": "0.0000", "CashLimit": "0.0000", "RateOfInterest": "0.0000", "RepaymentTenure": "36", "EmiAmount": "0.0000", "PaymentFrequency": "03", "ActualPaymentAmount": "0.0000", "WrittenoffAmountTotal": "0.0000", "WrittenoffAmountPrincipal": "0.0000", "SettlementAmount": "0.0000" }, { "CIC_No": "0104202312582428609", "Account_Segment_Tag": "T006", "Reporting_Member_ShortName": "NOT DISCLOSED", "Account_Number": "", "Account_Type": "17", "Owenership_Indicator": "3", "DateOpened_Or_Disbursed": "29062022", "Date_Of_Last_Payment": "15092022", "Date_Closed": "        ", "Date_Reported": "", "HighCredit_Or_SanctionedAmount": "2700000.0000", "Current_Balance": "2465842.0000", "Amount_Overdue": "0.0000", "Payment_History1": "000000000000000000000000000", "Payment_History2": "", "Payment_History_StartDate": "01022023", "Payment_History_EndDate": "01062022", "SuitFiledOrWilfulDefault": "", "WrittenOffAndSettled": "", "ValueOfCollateral": "0.0000", "TypeOfCollateral": "00", "CreditLimit": "0.0000", "CashLimit": "0.0000", "RateOfInterest": "0.0000", "RepaymentTenure": "60", "EmiAmount": "0.0000", "PaymentFrequency": "03", "ActualPaymentAmount": "0.0000", "WrittenoffAmountTotal": "0.0000", "WrittenoffAmountPrincipal": "0.0000", "SettlementAmount": "0.0000" }, { "CIC_No": "0104202312582428609", "Account_Segment_Tag": "T007", "Reporting_Member_ShortName": "NOT DISCLOSED", "Account_Number": "", "Account_Type": "17", "Owenership_Indicator": "3", "DateOpened_Or_Disbursed": "13062022", "Date_Of_Last_Payment": "16092022", "Date_Closed": "        ", "Date_Reported": "", "HighCredit_Or_SanctionedAmount": "2700000.0000", "Current_Balance": "2436213.0000", "Amount_Overdue": "0.0000", "Payment_History1": "000000000000000000000000000", "Payment_History2": "", "Payment_History_StartDate": "01022023", "Payment_History_EndDate": "01062022", "SuitFiledOrWilfulDefault": "", "WrittenOffAndSettled": "", "ValueOfCollateral": "0.0000", "TypeOfCollateral": "00", "CreditLimit": "0.0000", "CashLimit": "0.0000", "RateOfInterest": "0.0000", "RepaymentTenure": "60", "EmiAmount": "61650.0000", "PaymentFrequency": "03", "ActualPaymentAmount": "0.0000", "WrittenoffAmountTotal": "0.0000", "WrittenoffAmountPrincipal": "0.0000", "SettlementAmount": "0.0000" }, { "CIC_No": "0104202312582428609", "Account_Segment_Tag": "T008", "Reporting_Member_ShortName": "INDUSIND BANK", "Account_Number": "OCL01471D", "Account_Type": "17", "Owenership_Indicator": "4", "DateOpened_Or_Disbursed": "02042022", "Date_Of_Last_Payment": "22022023", "Date_Closed": "        ", "Date_Reported": "", "HighCredit_Or_SanctionedAmount": "3220000.0000", "Current_Balance": "2833559.0000", "Amount_Overdue": "0.0000", "Payment_History1": "000000000000000000000000000000000", "Payment_History2": "", "Payment_History_StartDate": "01022023", "Payment_History_EndDate": "01042022", "SuitFiledOrWilfulDefault": "", "WrittenOffAndSettled": "", "ValueOfCollateral": "0.0000", "TypeOfCollateral": "", "CreditLimit": "0.0000", "CashLimit": "0.0000", "RateOfInterest": "0.0000", "RepaymentTenure": "60", "EmiAmount": "0.0000", "PaymentFrequency": "03", "ActualPaymentAmount": "0.0000", "WrittenoffAmountTotal": "0.0000", "WrittenoffAmountPrincipal": "0.0000", "SettlementAmount": "0.0000" }, { "CIC_No": "0104202312582428609", "Account_Segment_Tag": "T009", "Reporting_Member_ShortName": "INDUSIND BANK", "Account_Number": "OCL01487D", "Account_Type": "17", "Owenership_Indicator": "4", "DateOpened_Or_Disbursed": "28032022", "Date_Of_Last_Payment": "21022023", "Date_Closed": "        ", "Date_Reported": "", "HighCredit_Or_SanctionedAmount": "2680000.0000", "Current_Balance": "2323139.0000", "Amount_Overdue": "0.0000", "Payment_History1": "000011000000000000000000000000000", "Payment_History2": "", "Payment_History_StartDate": "01022023", "Payment_History_EndDate": "01042022", "SuitFiledOrWilfulDefault": "", "WrittenOffAndSettled": "", "ValueOfCollateral": "0.0000", "TypeOfCollateral": "", "CreditLimit": "0.0000", "CashLimit": "0.0000", "RateOfInterest": "0.0000", "RepaymentTenure": "60", "EmiAmount": "0.0000", "PaymentFrequency": "03", "ActualPaymentAmount": "0.0000", "WrittenoffAmountTotal": "0.0000", "WrittenoffAmountPrincipal": "0.0000", "SettlementAmount": "0.0000" }, { "CIC_No": "0104202312582428609", "Account_Segment_Tag": "T010", "Reporting_Member_ShortName": "INDUSIND BANK", "Account_Number": "OCL01452D", "Account_Type": "17", "Owenership_Indicator": "1", "DateOpened_Or_Disbursed": "16112021", "Date_Of_Last_Payment": "21022023", "Date_Closed": "        ", "Date_Reported": "", "HighCredit_Or_SanctionedAmount": "700000.0000", "Current_Balance": "423007.0000", "Amount_Overdue": "0.0000", "Payment_History1": "000000000000000000000000000000000000007000000000", "Payment_History2": "", "Payment_History_StartDate": "01022023", "Payment_History_EndDate": "01112021", "SuitFiledOrWilfulDefault": "", "WrittenOffAndSettled": "", "ValueOfCollateral": "0.0000", "TypeOfCollateral": "", "CreditLimit": "0.0000", "CashLimit": "0.0000", "RateOfInterest": "0.0000", "RepaymentTenure": "36", "EmiAmount": "0.0000", "PaymentFrequency": "03", "ActualPaymentAmount": "0.0000", "WrittenoffAmountTotal": "0.0000", "WrittenoffAmountPrincipal": "0.0000", "SettlementAmount": "0.0000" }, { "CIC_No": "0104202312582428609", "Account_Segment_Tag": "T011", "Reporting_Member_ShortName": "INDUSIND BANK", "Account_Number": "OCL01453D", "Account_Type": "17", "Owenership_Indicator": "1", "DateOpened_Or_Disbursed": "16112021", "Date_Of_Last_Payment": "21022023", "Date_Closed": "        ", "Date_Reported": "", "HighCredit_Or_SanctionedAmount": "700000.0000", "Current_Balance": "426329.0000", "Amount_Overdue": "0.0000", "Payment_History1": "000000000000000000000000000000000000007000000000", "Payment_History2": "", "Payment_History_StartDate": "01022023", "Payment_History_EndDate": "01112021", "SuitFiledOrWilfulDefault": "", "WrittenOffAndSettled": "", "ValueOfCollateral": "0.0000", "TypeOfCollateral": "", "CreditLimit": "0.0000", "CashLimit": "0.0000", "RateOfInterest": "0.0000", "RepaymentTenure": "36", "EmiAmount": "0.0000", "PaymentFrequency": "03", "ActualPaymentAmount": "0.0000", "WrittenoffAmountTotal": "0.0000", "WrittenoffAmountPrincipal": "0.0000", "SettlementAmount": "0.0000" }, { "CIC_No": "0104202312582428609", "Account_Segment_Tag": "T012", "Reporting_Member_ShortName": "INDUSIND BANK", "Account_Number": "OCL01459D", "Account_Type": "17", "Owenership_Indicator": "4", "DateOpened_Or_Disbursed": "16112021", "Date_Of_Last_Payment": "05072022", "Date_Closed": "05072022", "Date_Reported": "", "HighCredit_Or_SanctionedAmount": "450000.0000", "Current_Balance": "0.0000", "Amount_Overdue": "0.0000", "Payment_History1": "000000000000000000000000000000", "Payment_History2": "", "Payment_History_StartDate": "01082022", "Payment_History_EndDate": "01112021", "SuitFiledOrWilfulDefault": "", "WrittenOffAndSettled": "", "ValueOfCollateral": "0.0000", "TypeOfCollateral": "", "CreditLimit": "0.0000", "CashLimit": "0.0000", "RateOfInterest": "0.0000", "RepaymentTenure": "24", "EmiAmount": "0.0000", "PaymentFrequency": "03", "ActualPaymentAmount": "0.0000", "WrittenoffAmountTotal": "0.0000", "WrittenoffAmountPrincipal": "0.0000", "SettlementAmount": "0.0000" }, { "CIC_No": "0104202312582428609", "Account_Segment_Tag": "T013", "Reporting_Member_ShortName": "INDUSIND BANK", "Account_Number": "OCL01460D", "Account_Type": "17", "Owenership_Indicator": "4", "DateOpened_Or_Disbursed": "16112021", "Date_Of_Last_Payment": "05072022", "Date_Closed": "05072022", "Date_Reported": "", "HighCredit_Or_SanctionedAmount": "350000.0000", "Current_Balance": "0.0000", "Amount_Overdue": "0.0000", "Payment_History1": "000000000000000000000000000000", "Payment_History2": "", "Payment_History_StartDate": "01082022", "Payment_History_EndDate": "01112021", "SuitFiledOrWilfulDefault": "", "WrittenOffAndSettled": "", "ValueOfCollateral": "0.0000", "TypeOfCollateral": "", "CreditLimit": "0.0000", "CashLimit": "0.0000", "RateOfInterest": "0.0000", "RepaymentTenure": "24", "EmiAmount": "0.0000", "PaymentFrequency": "03", "ActualPaymentAmount": "0.0000", "WrittenoffAmountTotal": "0.0000", "WrittenoffAmountPrincipal": "0.0000", "SettlementAmount": "0.0000" }, { "CIC_No": "0104202312582428609", "Account_Segment_Tag": "T014", "Reporting_Member_ShortName": "INDUSIND BANK", "Account_Number": "OCL01461D", "Account_Type": "17", "Owenership_Indicator": "4", "DateOpened_Or_Disbursed": "16112021", "Date_Of_Last_Payment": "05072022", "Date_Closed": "05072022", "Date_Reported": "", "HighCredit_Or_SanctionedAmount": "350000.0000", "Current_Balance": "0.0000", "Amount_Overdue": "0.0000", "Payment_History1": "000000000000000000000000000000", "Payment_History2": "", "Payment_History_StartDate": "01082022", "Payment_History_EndDate": "01112021", "SuitFiledOrWilfulDefault": "", "WrittenOffAndSettled": "", "ValueOfCollateral": "0.0000", "TypeOfCollateral": "", "CreditLimit": "0.0000", "CashLimit": "0.0000", "RateOfInterest": "0.0000", "RepaymentTenure": "24", "EmiAmount": "0.0000", "PaymentFrequency": "03", "ActualPaymentAmount": "0.0000", "WrittenoffAmountTotal": "0.0000", "WrittenoffAmountPrincipal": "0.0000", "SettlementAmount": "0.0000" }, { "CIC_No": "0104202312582428609", "Account_Segment_Tag": "T015", "Reporting_Member_ShortName": "INDUSIND BANK", "Account_Number": "OCL01462D", "Account_Type": "17", "Owenership_Indicator": "4", "DateOpened_Or_Disbursed": "16112021", "Date_Of_Last_Payment": "05072022", "Date_Closed": "05072022", "Date_Reported": "", "HighCredit_Or_SanctionedAmount": "300000.0000", "Current_Balance": "0.0000", "Amount_Overdue": "0.0000", "Payment_History1": "000000000000000000000000000000", "Payment_History2": "", "Payment_History_StartDate": "01082022", "Payment_History_EndDate": "01112021", "SuitFiledOrWilfulDefault": "", "WrittenOffAndSettled": "", "ValueOfCollateral": "0.0000", "TypeOfCollateral": "", "CreditLimit": "0.0000", "CashLimit": "0.0000", "RateOfInterest": "0.0000", "RepaymentTenure": "24", "EmiAmount": "0.0000", "PaymentFrequency": "03", "ActualPaymentAmount": "0.0000", "WrittenoffAmountTotal": "0.0000", "WrittenoffAmountPrincipal": "0.0000", "SettlementAmount": "0.0000" }, { "CIC_No": "0104202312582428609", "Account_Segment_Tag": "T017", "Reporting_Member_ShortName": "INDUSIND BANK", "Account_Number": "OCL01384D", "Account_Type": "17", "Owenership_Indicator": "4", "DateOpened_Or_Disbursed": "08032021", "Date_Of_Last_Payment": "22022023", "Date_Closed": "        ", "Date_Reported": "", "HighCredit_Or_SanctionedAmount": "3700000.0000", "Current_Balance": "2125471.0000", "Amount_Overdue": "0.0000", "Payment_History1": "000000000000000024000000000000000000000000000000000000000000000000", "Payment_History2": "", "Payment_History_StartDate": "01022023", "Payment_History_EndDate": "01042021", "SuitFiledOrWilfulDefault": "", "WrittenOffAndSettled": "", "ValueOfCollateral": "0.0000", "TypeOfCollateral": "", "CreditLimit": "0.0000", "CashLimit": "0.0000", "RateOfInterest": "0.0000", "RepaymentTenure": "48", "EmiAmount": "0.0000", "PaymentFrequency": "03", "ActualPaymentAmount": "0.0000", "WrittenoffAmountTotal": "0.0000", "WrittenoffAmountPrincipal": "0.0000", "SettlementAmount": "0.0000" }, { "CIC_No": "0104202312582428609", "Account_Segment_Tag": "T019", "Reporting_Member_ShortName": "INDUSIND BANK", "Account_Number": "OCL01169D", "Account_Type": "17", "Owenership_Indicator": "1", "DateOpened_Or_Disbursed": "17052019", "Date_Of_Last_Payment": "22022023", "Date_Closed": "        ", "Date_Reported": "", "HighCredit_Or_SanctionedAmount": "1920000.0000", "Current_Balance": "504140.0000", "Amount_Overdue": "0.0000", "Payment_History1": "000000000000000000000000000000000000000000000000000000000000000000", "Payment_History2": "", "Payment_History_StartDate": "01022023", "Payment_History_EndDate": "01032020", "SuitFiledOrWilfulDefault": "", "WrittenOffAndSettled": "", "ValueOfCollateral": "0.0000", "TypeOfCollateral": "", "CreditLimit": "0.0000", "CashLimit": "0.0000", "RateOfInterest": "0.0000", "RepaymentTenure": "57", "EmiAmount": "0.0000", "PaymentFrequency": "03", "ActualPaymentAmount": "0.0000", "WrittenoffAmountTotal": "0.0000", "WrittenoffAmountPrincipal": "0.0000", "SettlementAmount": "0.0000" }, { "CIC_No": "0104202312582428609", "Account_Segment_Tag": "T023", "Reporting_Member_ShortName": "NOT DISCLOSED", "Account_Number": "", "Account_Type": "17", "Owenership_Indicator": "4", "DateOpened_Or_Disbursed": "25042017", "Date_Of_Last_Payment": "14122022", "Date_Closed": "        ", "Date_Reported": "", "HighCredit_Or_SanctionedAmount": "3400000.0000", "Current_Balance": "0.0000", "Amount_Overdue": "0.0000", "Payment_History1": "000000000000000000001000002026002000000001000000031031030031031000061", "Payment_History2": "", "Payment_History_StartDate": "01032023", "Payment_History_EndDate": "01042020", "SuitFiledOrWilfulDefault": "", "WrittenOffAndSettled": "", "ValueOfCollateral": "3693000.0000", "TypeOfCollateral": "01", "CreditLimit": "0.0000", "CashLimit": "0.0000", "RateOfInterest": "7.3500", "RepaymentTenure": "28", "EmiAmount": "56666.0000", "PaymentFrequency": "03", "ActualPaymentAmount": "0.0000", "WrittenoffAmountTotal": "0.0000", "WrittenoffAmountPrincipal": "0.0000", "SettlementAmount": "0.0000" }, { "CIC_No": "0104202312582428609", "Account_Segment_Tag": "T027", "Reporting_Member_ShortName": "NOT DISCLOSED", "Account_Number": "", "Account_Type": "17", "Owenership_Indicator": "3", "DateOpened_Or_Disbursed": "24092016", "Date_Of_Last_Payment": "21062022", "Date_Closed": "21062022", "Date_Reported": "", "HighCredit_Or_SanctionedAmount": "2310000.0000", "Current_Balance": "0.0000", "Amount_Overdue": "0.0000", "Payment_History1": "000000000000000000000000000000000000000000", "Payment_History2": "", "Payment_History_StartDate": "01062022", "Payment_History_EndDate": "01072019", "SuitFiledOrWilfulDefault": "", "WrittenOffAndSettled": "", "ValueOfCollateral": "0.0000", "TypeOfCollateral": "", "CreditLimit": "0.0000", "CashLimit": "0.0000", "RateOfInterest": "11.0000", "RepaymentTenure": "48", "EmiAmount": "62201.0000", "PaymentFrequency": "03", "ActualPaymentAmount": "0.0000", "WrittenoffAmountTotal": "0.0000", "WrittenoffAmountPrincipal": "0.0000", "SettlementAmount": "0.0000" }, { "CIC_No": "0104202312582428609", "Account_Segment_Tag": "T028", "Reporting_Member_ShortName": "NOT DISCLOSED", "Account_Number": "", "Account_Type": "17", "Owenership_Indicator": "3", "DateOpened_Or_Disbursed": "24092016", "Date_Of_Last_Payment": "31032021", "Date_Closed": "        ", "Date_Reported": "", "HighCredit_Or_SanctionedAmount": "2310000.0000", "Current_Balance": "1619.0000", "Amount_Overdue": "0.0000", "Payment_History1": "000000000000000000000000000000000000000000000", "Payment_History2": "", "Payment_History_StartDate": "01072022", "Payment_History_EndDate": "01082019", "SuitFiledOrWilfulDefault": "", "WrittenOffAndSettled": "", "ValueOfCollateral": "0.0000", "TypeOfCollateral": "", "CreditLimit": "0.0000", "CashLimit": "0.0000", "RateOfInterest": "11.0000", "RepaymentTenure": "48", "EmiAmount": "62201.0000", "PaymentFrequency": "03", "ActualPaymentAmount": "0.0000", "WrittenoffAmountTotal": "0.0000", "WrittenoffAmountPrincipal": "0.0000", "SettlementAmount": "0.0000" }, { "CIC_No": "0104202312582428609", "Account_Segment_Tag": "T030", "Reporting_Member_ShortName": "NOT DISCLOSED", "Account_Number": "", "Account_Type": "17", "Owenership_Indicator": "1", "DateOpened_Or_Disbursed": "11032016", "Date_Of_Last_Payment": "04102021", "Date_Closed": "05102021", "Date_Reported": "", "HighCredit_Or_SanctionedAmount": "2500000.0000", "Current_Balance": "0.0000", "Amount_Overdue": "0.0000", "Payment_History1": "000000000001061008", "Payment_History2": "", "Payment_History_StartDate": "01102021", "Payment_History_EndDate": "01112018", "SuitFiledOrWilfulDefault": "", "WrittenOffAndSettled": "", "ValueOfCollateral": "11262000.0000", "TypeOfCollateral": "01", "CreditLimit": "0.0000", "CashLimit": "0.0000", "RateOfInterest": "11.7500", "RepaymentTenure": "13", "EmiAmount": "41666.0000", "PaymentFrequency": "03", "ActualPaymentAmount": "76488.0000", "WrittenoffAmountTotal": "0.0000", "WrittenoffAmountPrincipal": "0.0000", "SettlementAmount": "0.0000" }, { "CIC_No": "0104202312582428609", "Account_Segment_Tag": "T045", "Reporting_Member_ShortName": "INDUSIND BANK", "Account_Number": "OL004803H", "Account_Type": "17", "Owenership_Indicator": "4", "DateOpened_Or_Disbursed": "01012010", "Date_Of_Last_Payment": "29062012", "Date_Closed": "        ", "Date_Reported": "", "HighCredit_Or_SanctionedAmount": "1134000.0000", "Current_Balance": "0.0000", "Amount_Overdue": "0.0000", "Payment_History1": "000000000000000000000000000000000000000000000000000000000000000000", "Payment_History2": "", "Payment_History_StartDate": "01022023", "Payment_History_EndDate": "01032020", "SuitFiledOrWilfulDefault": "", "WrittenOffAndSettled": "", "ValueOfCollateral": "0.0000", "TypeOfCollateral": "", "CreditLimit": "0.0000", "CashLimit": "0.0000", "RateOfInterest": "0.0000", "RepaymentTenure": "48", "EmiAmount": "0.0000", "PaymentFrequency": "03", "ActualPaymentAmount": "0.0000", "WrittenoffAmountTotal": "0.0000", "WrittenoffAmountPrincipal": "0.0000", "SettlementAmount": "0.0000" }, { "CIC_No": "0104202312582428609", "Account_Segment_Tag": "T016", "Reporting_Member_ShortName": "INDUSIND BANK", "Account_Number": "OCL02187C", "Account_Type": "32", "Owenership_Indicator": "1", "DateOpened_Or_Disbursed": "12112021", "Date_Of_Last_Payment": "03082022", "Date_Closed": "03082022", "Date_Reported": "", "HighCredit_Or_SanctionedAmount": "800000.0000", "Current_Balance": "0.0000", "Amount_Overdue": "0.0000", "Payment_History1": "000000024000000000021000000000", "Payment_History2": "", "Payment_History_StartDate": "01082022", "Payment_History_EndDate": "01112021", "SuitFiledOrWilfulDefault": "", "WrittenOffAndSettled": "", "ValueOfCollateral": "0.0000", "TypeOfCollateral": "", "CreditLimit": "0.0000", "CashLimit": "0.0000", "RateOfInterest": "0.0000", "RepaymentTenure": "24", "EmiAmount": "0.0000", "PaymentFrequency": "03", "ActualPaymentAmount": "0.0000", "WrittenoffAmountTotal": "0.0000", "WrittenoffAmountPrincipal": "0.0000", "SettlementAmount": "0.0000" } ], "Non_IBL_Exposure": [ { "Application_No": "AC6048569_91861672071", "CIC_No": "0104202312582428609", "Account_Type": "1", "Account_Type_Desc": "Auto Loan (Personal) ", "Ownership": "Joint", "OpenDate": "02-12-2016", "LastPaymentDate": "29-04-2021", "HighCredit": "667000.0000", "CurrentBalance": "0.0000", "AmountOverdue": "0.0000", "WrittenoffAmountTotal": "0.0000", "ReasonforOverdue": "", "FinancierCode": "", "FinanicerName": "", "Maker_Id": "", "Maker_Date": "", "Expousure_Flag": "N", "Customer": "Borrower" }, { "Application_No": "AC6048569_91861672071", "CIC_No": "0104202312582428609", "Account_Type": "2", "Account_Type_Desc": "Housing Loan ", "Ownership": "Joint", "OpenDate": "16-04-2015", "LastPaymentDate": "20-01-2023", "HighCredit": "1228000.0000", "CurrentBalance": "954999.0000", "AmountOverdue": "24953.0000", "WrittenoffAmountTotal": "0.0000", "ReasonforOverdue": "", "FinancierCode": "", "FinanicerName": "", "Maker_Id": "", "Maker_Date": "", "Expousure_Flag": "N", "Customer": "Borrower" }, { "Application_No": "AC6048569_91861672071", "CIC_No": "0104202312582428609", "Account_Type": "2", "Account_Type_Desc": "Housing Loan ", "Ownership": "Joint", "OpenDate": "16-07-2020", "LastPaymentDate": "28-02-2023", "HighCredit": "1768315.0000", "CurrentBalance": "1683884.0000", "AmountOverdue": "14156.0000", "WrittenoffAmountTotal": "0.0000", "ReasonforOverdue": "", "FinancierCode": "", "FinanicerName": "", "Maker_Id": "", "Maker_Date": "", "Expousure_Flag": "N", "Customer": "Borrower" }, { "Application_No": "AC6048569_91861672071", "CIC_No": "0104202312582428609", "Account_Type": "7", "Account_Type_Desc": "Gold Loan ", "Ownership": "Individual", "OpenDate": "01-02-2023", "LastPaymentDate": "", "HighCredit": "300000.0000", "CurrentBalance": "300000.0000", "AmountOverdue": "0.0000", "WrittenoffAmountTotal": "0.0000", "ReasonforOverdue": "", "FinancierCode": "", "FinanicerName": "", "Maker_Id": "", "Maker_Date": "", "Expousure_Flag": "N", "Customer": "Borrower" }, { "Application_No": "AC6048569_91861672071", "CIC_No": "0104202312582428609", "Account_Type": "9", "Account_Type_Desc": "Loan to Professional ", "Ownership": "Joint", "OpenDate": "23-04-2010", "LastPaymentDate": "", "HighCredit": "1200000.0000", "CurrentBalance": "1192491.0000", "AmountOverdue": "0.0000", "WrittenoffAmountTotal": "0.0000", "ReasonforOverdue": "", "FinancierCode": "", "FinanicerName": "", "Maker_Id": "", "Maker_Date": "", "Expousure_Flag": "N", "Customer": "Borrower" }, { "Application_No": "AC6048569_91861672071", "CIC_No": "0104202312582428609", "Account_Type": "17", "Account_Type_Desc": "Commercial Vehicle Loan ", "Ownership": "Individual", "OpenDate": "31-01-2023", "LastPaymentDate": "", "HighCredit": "4350000.0000", "CurrentBalance": "4350000.0000", "AmountOverdue": "0.0000", "WrittenoffAmountTotal": "0.0000", "ReasonforOverdue": "", "FinancierCode": "", "FinanicerName": "", "Maker_Id": "", "Maker_Date": "", "Expousure_Flag": "N", "Customer": "Borrower" }, { "Application_No": "AC6048569_91861672071", "CIC_No": "0104202312582428609", "Account_Type": "17", "Account_Type_Desc": "Commercial Vehicle Loan ", "Ownership": "Joint", "OpenDate": "11-11-2022", "LastPaymentDate": "07-02-2023", "HighCredit": "1400000.0000", "CurrentBalance": "1296029.0000", "AmountOverdue": "0.0000", "WrittenoffAmountTotal": "0.0000", "ReasonforOverdue": "", "FinancierCode": "", "FinanicerName": "", "Maker_Id": "", "Maker_Date": "", "Expousure_Flag": "N", "Customer": "Borrower" }, { "Application_No": "AC6048569_91861672071", "CIC_No": "0104202312582428609", "Account_Type": "17", "Account_Type_Desc": "Commercial Vehicle Loan ", "Ownership": "Guarantor", "OpenDate": "29-06-2022", "LastPaymentDate": "15-09-2022", "HighCredit": "2700000.0000", "CurrentBalance": "2465842.0000", "AmountOverdue": "0.0000", "WrittenoffAmountTotal": "0.0000", "ReasonforOverdue": "", "FinancierCode": "", "FinanicerName": "", "Maker_Id": "", "Maker_Date": "", "Expousure_Flag": "N", "Customer": "Borrower" }, { "Application_No": "AC6048569_91861672071", "CIC_No": "0104202312582428609", "Account_Type": "17", "Account_Type_Desc": "Commercial Vehicle Loan ", "Ownership": "Guarantor", "OpenDate": "13-06-2022", "LastPaymentDate": "16-09-2022", "HighCredit": "2700000.0000", "CurrentBalance": "2436213.0000", "AmountOverdue": "0.0000", "WrittenoffAmountTotal": "0.0000", "ReasonforOverdue": "", "FinancierCode": "", "FinanicerName": "", "Maker_Id": "", "Maker_Date": "", "Expousure_Flag": "N", "Customer": "Borrower" }, { "Application_No": "AC6048569_91861672071", "CIC_No": "0104202312582428609", "Account_Type": "17", "Account_Type_Desc": "Commercial Vehicle Loan ", "Ownership": "Joint", "OpenDate": "02-04-2022", "LastPaymentDate": "22-02-2023", "HighCredit": "3220000.0000", "CurrentBalance": "2833559.0000", "AmountOverdue": "0.0000", "WrittenoffAmountTotal": "0.0000", "ReasonforOverdue": "", "FinancierCode": "", "FinanicerName": "", "Maker_Id": "", "Maker_Date": "", "Expousure_Flag": "N", "Customer": "Borrower" },'+'{ "Application_No": "AC6048569_91861672071", "CIC_No": "0104202312582428609", "Account_Type": "17", "Account_Type_Desc": "Commercial Vehicle Loan ", "Ownership": "Joint", "OpenDate": "28-03-2022", "LastPaymentDate": "21-02-2023", "HighCredit": "2680000.0000", "CurrentBalance": "2323139.0000", "AmountOverdue": "0.0000", "WrittenoffAmountTotal": "0.0000", "ReasonforOverdue": "", "FinancierCode": "", "FinanicerName": "", "Maker_Id": "", "Maker_Date": "", "Expousure_Flag": "N", "Customer": "Borrower" }, { "Application_No": "AC6048569_91861672071", "CIC_No": "0104202312582428609", "Account_Type": "17", "Account_Type_Desc": "Commercial Vehicle Loan ", "Ownership": "Individual", "OpenDate": "16-11-2021", "LastPaymentDate": "21-02-2023", "HighCredit": "700000.0000", "CurrentBalance": "423007.0000", "AmountOverdue": "0.0000", "WrittenoffAmountTotal": "0.0000", "ReasonforOverdue": "", "FinancierCode": "", "FinanicerName": "", "Maker_Id": "", "Maker_Date": "", "Expousure_Flag": "N", "Customer": "Borrower" }, { "Application_No": "AC6048569_91861672071", "CIC_No": "0104202312582428609", "Account_Type": "17", "Account_Type_Desc": "Commercial Vehicle Loan ", "Ownership": "Individual", "OpenDate": "16-11-2021", "LastPaymentDate": "21-02-2023", "HighCredit": "700000.0000", "CurrentBalance": "426329.0000", "AmountOverdue": "0.0000", "WrittenoffAmountTotal": "0.0000", "ReasonforOverdue": "", "FinancierCode": "", "FinanicerName": "", "Maker_Id": "", "Maker_Date": "", "Expousure_Flag": "N", "Customer": "Borrower" }, { "Application_No": "AC6048569_91861672071", "CIC_No": "0104202312582428609", "Account_Type": "17", "Account_Type_Desc": "Commercial Vehicle Loan ", "Ownership": "Joint", "OpenDate": "08-03-2021", "LastPaymentDate": "22-02-2023", "HighCredit": "3700000.0000", "CurrentBalance": "2125471.0000", "AmountOverdue": "0.0000", "WrittenoffAmountTotal": "0.0000", "ReasonforOverdue": "", "FinancierCode": "", "FinanicerName": "", "Maker_Id": "", "Maker_Date": "", "Expousure_Flag": "N", "Customer": "Borrower" }, { "Application_No": "AC6048569_91861672071", "CIC_No": "0104202312582428609", "Account_Type": "17", "Account_Type_Desc": "Commercial Vehicle Loan ", "Ownership": "Individual", "OpenDate": "17-05-2019", "LastPaymentDate": "22-02-2023", "HighCredit": "1920000.0000", "CurrentBalance": "504140.0000", "AmountOverdue": "0.0000", "WrittenoffAmountTotal": "0.0000", "ReasonforOverdue": "", "FinancierCode": "", "FinanicerName": "", "Maker_Id": "", "Maker_Date": "", "Expousure_Flag": "N", "Customer": "Borrower" }, { "Application_No": "AC6048569_91861672071", "CIC_No": "0104202312582428609", "Account_Type": "17", "Account_Type_Desc": "Commercial Vehicle Loan ", "Ownership": "Joint", "OpenDate": "25-04-2017", "LastPaymentDate": "14-12-2022", "HighCredit": "3400000.0000", "CurrentBalance": "0.0000", "AmountOverdue": "0.0000", "WrittenoffAmountTotal": "0.0000", "ReasonforOverdue": "", "FinancierCode": "", "FinanicerName": "", "Maker_Id": "", "Maker_Date": "", "Expousure_Flag": "N", "Customer": "Borrower" }, { "Application_No": "AC6048569_91861672071", "CIC_No": "0104202312582428609", "Account_Type": "17", "Account_Type_Desc": "Commercial Vehicle Loan ", "Ownership": "Guarantor", "OpenDate": "24-09-2016", "LastPaymentDate": "31-03-2021", "HighCredit": "2310000.0000", "CurrentBalance": "1619.0000", "AmountOverdue": "0.0000", "WrittenoffAmountTotal": "0.0000", "ReasonforOverdue": "", "FinancierCode": "", "FinanicerName": "", "Maker_Id": "", "Maker_Date": "", "Expousure_Flag": "N", "Customer": "Borrower" }, { "Application_No": "AC6048569_91861672071", "CIC_No": "0104202312582428609", "Account_Type": "17", "Account_Type_Desc": "Commercial Vehicle Loan ", "Ownership": "Joint", "OpenDate": "01-01-2010", "LastPaymentDate": "29-06-2012", "HighCredit": "1134000.0000", "CurrentBalance": "0.0000", "AmountOverdue": "0.0000", "WrittenoffAmountTotal": "0.0000", "ReasonforOverdue": "", "FinancierCode": "", "FinanicerName": "", "Maker_Id": "", "Maker_Date": "", "Expousure_Flag": "N", "Customer": "Borrower" }, { "Application_No": "AC6048569_91861672071", "CIC_No": "0104202312582428609", "Account_Type": "23", "Account_Type_Desc": "", "Ownership": "Individual", "OpenDate": "29-06-2020", "LastPaymentDate": "02-03-2023", "HighCredit": "116000.0000", "CurrentBalance": "19802.0000", "AmountOverdue": "0.0000", "WrittenoffAmountTotal": "0.0000", "ReasonforOverdue": "", "FinancierCode": "", "FinanicerName": "", "Maker_Id": "", "Maker_Date": "", "Expousure_Flag": "N", "Customer": "Borrower" } ], "CIBIL_Suit_Filed": [ { "Application_No": "AC6048569_91861672071", "Entity_Type": "INDIVIDUAL", "Type": "bo", "CIC_No": "0104202312582428609", "Score": "00733", "HighCredit_Or_SanctionedAmount": "75018461.0000", "Current_Balance": "23336524.0000", "RecentDate": "2/1/2023 12:00:00 AM", "OldestDate": "6/11/2005 12:00:00 AM", "Amount_Overdue": "39109.0000", "CibilDecision": "No Hit", "Month_Overdue": "2.0000", "NoOfEnLtSixMon": "6", "WrittenoffAmountTotal": "21381.0000", "SuitFiledOrWilfulDefault": "No", "CRIFScore_Desc": "" }, { "Application_No": "AC6048569_91861672071_g1", "Entity_Type": "INDIVIDUAL", "Type": "co", "CIC_No": "0104202313353932704", "Score": "00701", "HighCredit_Or_SanctionedAmount": "41547000.0000", "Current_Balance": "19418855.0000", "RecentDate": "1/31/2023 12:00:00 AM", "OldestDate": "3/11/2016 12:00:00 AM", "Amount_Overdue": "0.0000", "CibilDecision": "No Hit", "Month_Overdue": "", "NoOfEnLtSixMon": "8", "WrittenoffAmountTotal": "0.0000", "SuitFiledOrWilfulDefault": "No", "CRIFScore_Desc": "" } ], "IRR": [ { "Weighted_IRR_YTD": "11.24", "Weighted_IRR_N_YTD": "11.24", "Weighted_IRR_U_YTD": "0", "Weighted_IRR_R_YTD": "0" } ] } ] } }';
                Test.startTest();
            ExternalCAMDataController.storingExternalCAMData((String)opportunityList[0].Id,(String)camList[0].Id,Response,'CAM Portfolio',true,applicantList[0].Id);
            Test.stopTest();
            
        }
    }
    @isTest
    public static void storingExternalAPDDataCAMPortfolio(){
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1];
        System.runAs(u) 
        {
            List<Opportunity> opportunityList=[select Id,Name From Opportunity limit 1];
            List<CAM__c>camList=[select Id,Name from CAM__c limit 1];
            List<Applicant__c>applicantList=[Select id,Name From Applicant__c limit 1];
            String Response= '{   "status": "SUCCESS",   "respDesc": "APDPending",   "content": [     {       "User_APD_Pending": {         "UserRCPendings": [           {             "Name": "ANOOPS",             "Segment_Code": "",             "Deposit_Avl": "NON-DEPOSIT",             "Count_1_30": "31",             "SOH_1_30": "8009092.5100",             "Count_31_60": "21",             "SOH_31_60": "5004749.4500",             "Count_61_90": "19",             "SOH_61_90": "3859472.0100",             "Count_Above_90": "188",             "SOH_Above_90": "39738897.6000",             "Total_Count": "259",             "Doc_Type": "InsurancePending"           }         ],         "UserInsurancePending": [           {             "Name": "ANOOPS",             "Segment_Code": "",             "Deposit_Avl": "NON-DEPOSIT",             "Count_1_30": "31",             "SOH_1_30": "8009092.5100",             "Count_31_60": "21",             "SOH_31_60": "5004749.4500",             "Count_61_90": "19",             "SOH_61_90": "3859472.0100",             "Count_Above_90": "188",             "SOH_Above_90": "39738897.6000",             "Total_Count": "259",             "Doc_Type": "InsurancePending"           }         ]       },       "Dealer_APD_Pending": {         "DealerRCPending": [           {             "Name": "INDUSMOTORCOPVTLTD",             "Deal_Count": "818",             "Count_1_30": "215",             "Count_31_60": "63",             "Count_61_90": "18",             "Count_Above_90": "7",             "Total_Count": "303",             "Doc_Type": "RCPending"           },           {             "Name": "INDUSMOTORCOPVTLTD",             "Deal_Count": "318",             "Count_1_30": "283",             "Count_31_60": "34",             "Count_61_90": "1",             "Count_Above_90": "0",             "Total_Count": "318",             "Doc_Type": "InvoicePending"           }         ],         "DealerInsurancePending": [           {             "Name": "INDUSMOTORCOPVTLTD",             "Deposit_Avl": "DEPOSIT",             "Count_1_30": "0",             "SOH_1_30": "0.0000",             "Count_31_60": "0",             "SOH_31_60": "0.0000",             "Count_61_90": "0",             "SOH_61_90": "0.0000",             "Count_Above_90": "4",             "SOH_Above_90": "641100.2700",             "Total_Count": "4",             "Doc_Type": "InsurancePending"           },           {             "Name": "INDUSMOTORCOPVTLTD",             "Deposit_Avl": "NON-DEPOSIT",             "Count_1_30": "2106",             "SOH_1_30": "881285855.2800",             "Count_31_60": "1599",             "SOH_31_60": "664037640.5000",             "Count_61_90": "1585",             "SOH_61_90": "609049300.3300",             "Count_Above_90": "11920",             "SOH_Above_90": "3955571285.5800",             "Total_Count": "17210",             "Doc_Type": "InsurancePending"           }         ]       }     }   ] };';
            
            Test.startTest();
            ExternalCAMDataController.storingExternalCAMData((String)opportunityList[0].Id,(String)camList[0].Id,Response,'APD Pending',true,applicantList[0].Id);
            Test.stopTest();
        }  
    }
    
    @isTest
    public static void getCAMPortfolioDetailsTestMethod(){
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1];
        System.runAs(u) 
        {
            List<Opportunity> opportunityList=[select Id,Name From Opportunity limit 1];
            List<CAM__c>camList=[select Id,Name from CAM__c limit 1];
            List<Applicant__c>applicantList=[Select id,Name From Applicant__c limit 1];
            Test.startTest();
            List<External_CAM_Data__c>externalDataList=ExternalCAMDataController.getCAMPortfolioDetails(opportunityList.get(0).Id,camList.get(0).Id);
            Test.stopTest();
            System.assertEquals(0,externalDataList.size());
        }  
    }
    @isTest
    public static void getAPDPendingDetailsTestMethod(){
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1];
        System.runAs(u) 
        {
            List<Opportunity> opportunityList=[select Id,Name From Opportunity limit 1];
            List<CAM__c>camList=[select Id,Name from CAM__c limit 1];
            List<Applicant__c>applicantList=[Select id,Name From Applicant__c limit 1];
            Test.startTest();
            List<External_CAM_Data__c>externalDataList=ExternalCAMDataController.getAPDPendingDetails(opportunityList.get(0).Id,camList.get(0).Id);
            Test.stopTest();
            System.assertEquals(0,externalDataList.size());
        }  
    }
    @isTest
    public static void getCIBILTimelineDetailsTestMethod(){
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1];
        System.runAs(u) 
        {
            List<Opportunity> opportunityList=[select Id,Name From Opportunity limit 1];
            List<CAM__c>camList=[select Id,Name from CAM__c limit 1];
            List<Applicant__c>applicantList=[Select id,Name From Applicant__c limit 1];
            Test.startTest();
            List<External_CAM_Data__c>externalDataList=ExternalCAMDataController.getCIBILTimelineDetails(opportunityList.get(0).Id,applicantList.get(0).Id);
            Test.stopTest();
            system.debug('Test Data'+externalDataList.size());
            System.assertEquals(0,externalDataList.size());
        }  
    }
    @isTest
    public static void getCIBILExposureDetailsTestMethod(){
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1];
        System.runAs(u) 
        {
            List<Opportunity> opportunityList=[select Id,Name From Opportunity limit 1];
            List<CAM__c>camList=[select Id,Name from CAM__c limit 1];
            List<Applicant__c>applicantList=[Select id,Name From Applicant__c limit 1];
            Test.startTest();
            ExternalCAMDataController.getCIBILExposureDetails(opportunityList.get(0).Id,applicantList.get(0).Id);
            Test.stopTest();
        }  
    }
    @isTest
    public static void getKYCDetailsTestMethod(){
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1];
        System.runAs(u) 
        {
            List<Opportunity> opportunityList=[select Id,Name From Opportunity limit 1];
            List<CAM__c>camList=[select Id,Name from CAM__c limit 1];
            List<Applicant__c>applicantList=[Select id,Name From Applicant__c limit 1];
            Test.startTest();
            ExternalCAMDataController.getKYCDetails(applicantList.get(0).Id);
            Test.stopTest();
        }  
    }
    @isTest
    public static void getKYCDetailsTestMethod2(){
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1];
        System.runAs(u) 
        {
            List<Opportunity> opportunityList=[select Id,Name From Opportunity limit 1];
            List<CAM__c>camList=[select Id,Name from CAM__c limit 1];
            List<Applicant__c>applicantList=[Select id,Name From Applicant__c limit 1];
            Documents__c document=[select Id,KYC_Address_Line_2__c from Documents__c limit 1 ];
            document.KYC_Address_Line_2__c='';
            update document;
            Test.startTest();
            ExternalCAMDataController.getKYCDetails(applicantList.get(0).Id);
            Test.stopTest();
        }  
    }
    @isTest
    public static void getKYCDetailsTestMethod3(){
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1];
        System.runAs(u) 
        {
            List<Opportunity> opportunityList=[select Id,Name From Opportunity limit 1];
            List<CAM__c>camList=[select Id,Name from CAM__c limit 1];
            List<Applicant__c>applicantList=[Select id,Name From Applicant__c limit 1];
            Documents__c document=[select Id,KYC_Address_Line_1__c from Documents__c limit 1 ];
            document.KYC_Address_Line_1__c='';
            update document;
            Test.startTest();
            ExternalCAMDataController.getKYCDetails(applicantList.get(0).Id);
            Test.stopTest();
        }  
    }
    @isTest
    public static void getKYCDetailsTestMethod4(){
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1];
        System.runAs(u) 
        {
            List<Opportunity> opportunityList=[select Id,Name From Opportunity limit 1];
            List<CAM__c>camList=[select Id,Name from CAM__c limit 1];
            List<Applicant__c>applicantList=[Select id,Name From Applicant__c limit 1];
            Documents__c document=[select Id,KYC_Address_Line_1__c,KYC_Address_Line_2__c from Documents__c limit 1 ];
            document.KYC_Address_Line_1__c='';
            document.KYC_Address_Line_2__c='';
            update document;
            Test.startTest();
            ExternalCAMDataController.getKYCDetails(applicantList.get(0).Id);
            Test.stopTest();
        }  
    }
    @isTest
    public static void getKYCDetailsTestMethod6(){
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1];
        System.runAs(u) 
        {
            List<Opportunity> opportunityList=[select Id,Name From Opportunity limit 1];
            List<CAM__c>camList=[select Id,Name from CAM__c limit 1];
            List<Applicant__c>applicantList=[Select id,Name From Applicant__c limit 1];
            Income_Details__c income_Detail=[Select Id, Office_Address_Line_1__c, Office_Address_Line_2__c,Applicant__c from Income_Details__c limit 1 ];
            income_Detail.Office_Address_Line_2__c='';
            update income_Detail;
            Test.startTest();
            ExternalCAMDataController.getKYCDetails(applicantList.get(0).Id);
            Test.stopTest();
        }  
    }
    @isTest
    public static void getKYCDetailsTestMethod7(){
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1];
        System.runAs(u) 
        {
            List<Opportunity> opportunityList=[select Id,Name From Opportunity limit 1];
            List<CAM__c>camList=[select Id,Name from CAM__c limit 1];
            List<Applicant__c>applicantList=[Select id,Name From Applicant__c limit 1];
            Income_Details__c income_Detail=[Select Id, Office_Address_Line_1__c, Office_Address_Line_2__c,Applicant__c from Income_Details__c limit 1 ];
            income_Detail.Office_Address_Line_1__c='';
            update income_Detail;
            Test.startTest();
            ExternalCAMDataController.getKYCDetails(applicantList.get(0).Id);
            Test.stopTest();
        }  
    }
    @isTest
    public static void getKYCDetailsTestMethod8(){
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1];
        System.runAs(u) 
        {
            List<Opportunity> opportunityList=[select Id,Name From Opportunity limit 1];
            List<CAM__c>camList=[select Id,Name from CAM__c limit 1];
            List<Applicant__c>applicantList=[Select id,Name From Applicant__c limit 1];
            Income_Details__c income_Detail=[Select Id, Office_Address_Line_1__c, Office_Address_Line_2__c,Applicant__c from Income_Details__c limit 1 ];
            income_Detail.Office_Address_Line_1__c='';
            income_Detail.Office_Address_Line_2__c='';
            update income_Detail;
            Test.startTest();
            ExternalCAMDataController.getKYCDetails(applicantList.get(0).Id);
            Test.stopTest();
        }  
    }
    @isTest
    public static void storingCIBILDetailsTestMethod(){
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1];
        System.runAs(u) 
        {
            List<Opportunity> opportunityList=[select Id,Name From Opportunity limit 1];
            List<CAM__c>camList=[select Id,Name from CAM__c limit 1];
            List<Applicant__c>applicantList=[Select id,Name From Applicant__c limit 1];
            String Response= '{ "IsSuccess": "true", "StatusCode": "200", "StatusDescription": "SUCCESS", "Cibil_Report_URl": "https://www.dummy.com", "Cibil_LoanAccount_Details": [ { "Lead_Id": "123", "CIC_No": "987654321", "Account_Type": "Secured", "Account_Type_Desc": "Home Loan", "Ownership": "Individual", "OpenDate": "31-01-2023", "LastPaymentDate": "28-06-2023", "HighCredit": "500000", "CurrentBalance": "250000", "AmountOverdue": "0", "WrittenoffAmountTotal": "0", "ReasonforOverdue": "", "FinancierCode": "1234", "FinanicerName": "INDUSIND Bank", "Maker_Id": "789", "Maker_Date": "7-01-2023", "Expousure_Flag": "No", "Enquiry_Amount": { "CIC_No": "987654321", "Enquiring_Member_ShortName": "INDUSIND Bank", "Enquiry_Amount": "100000", "Date_Of_Enquiry": "7-06-2023" } } ], "Cibil_TimeLine_Details": [ { "Date_Processed": "31-01-2023", "Date_Z": "31-01-2023", "Lead_Id": "123", "ADE_CIC_No": "987654321", "Customer_Code": "CUST001", "Deal_No": "DEAL001", "CIBIL_Version": "2.0", "Score": "750", "Arrow_Type": "Up", "CIBIL_Detect_Decision": "Approved", "Customer_Role": "Primary", "Inprinciple_Decision": "Approved", "Final_Decision": "Approved" } ], "Equifax_Generated": "true", "Equifax_Report_URl": "https://www.dummy.com"}';
            Test.startTest();
            ExternalCAMDataController.storingCIBILDetails(opportunityList[0].Id,Response,applicantList[0].Id);
            Test.stopTest();
        }  
    }
    
    @isTest
    public static void getFinalTermsRecordMethod(){
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1];
        System.runAs(u) 
        {
            Final_Term__c FinalTerm =[select Id,Name From Final_Term__c limit 1];
            Test.startTest();
            ExternalCAMDataController.getFinalTermsRecord(FinalTerm.Id);
            Test.stopTest();
        }  
    }
    
    @isTest
    public static void getApplicantIdMethod(){
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1];
        System.runAs(u) 
        {
            List<Opportunity> opportunityList=[select Id,Name From Opportunity limit 1];
            Test.startTest();
            ExternalCAMDataController.getApplicantId(opportunityList[0].Id);
            Test.stopTest();
        }  
    }    
    
}