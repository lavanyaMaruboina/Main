@isTest
public class IND_CombinedBERRequestTest {
    
    @TestSetup
    static void testData(){
        Opportunity opks1 = new Opportunity();
        opks1.StageName = 'Qualification';
        opks1.CloseDate = Date.newInstance(2021, 1, 11);
        opks1.Name = 'Test-2';
        opks1.Vehicle_Type__c = 'New';
        opks1.Product_Type__c = 'Tractor';
        insert opks1;
        
        Applicant__c apks1 = new Applicant__c();
        apks1.Opportunity__c = opks1.Id;
        apks1.Contact_number__c = '9743514830';
        apks1.Applicant_Type__c = 'Borrower';
        apks1.In_Active_Applicant__c = false;
        apks1.DocAuth_Application_Id__c = 'T-authTest';
        apks1.Selfie_Upload__c = true;
        insert apks1;
        
        Documents__c doc = new Documents__c();
        doc.Name = 'Test document';
        doc.Document_Type__c = 'PAN';
        doc.Document_Side__c = 'Front';
        doc.Age__c = 30;
        doc.KYC_DOB__c = Date.newInstance(1993, 05, 05);
        doc.KYC_City__c = 'Mumbai';
        doc.PAN_No__c = 'testpan';
        doc.KYC_name__c = 'Test KYC Name';
        doc.KYC_No__c = Integrationutilities.getencryptedrequest('TN2020090003150',System.Label.privateKey,System.Label.ivkey);
        doc.KYC_Issuance_Date__c = Date.newInstance(2022, 05, 20);
        doc.Proof_of_Address_POA__c = true;
        doc.Proof_of_Identity_POI__c = true;
        doc.Opportunity_Relation__c = opks1.Id;
        doc.Applicant__c =apks1.id;
        insert doc;
        
        Vehicle_Detail__c vehicleDetailObj = new Vehicle_Detail__c();
        vehicleDetailObj.Loan_Application__c = opks1.Id;
        vehicleDetailObj.Variant__c  = 'M&M KUV100 NXT K8 DIESEL';
        vehicleDetailObj.Make__c = 'TVS';
        vehicleDetailObj.Model__c = 'MAHINDRA MARAZZO';
        vehicleDetailObj.Vehicle_SubType__c = 'Tractor';
        vehicleDetailObj.Invoice_Price__c = 23.08;
        vehicleDetailObj.Vehicle_Type__c = 'New';
        insert vehicleDetailObj;
        
        Final_Term__c finalTermObj = new Final_Term__c();
        finalTermObj.Loan_Application__c = opks1.Id;
        finalTermObj.PricingEngine_thresholdNetrr__c = 78.2;
        finalTermObj.Vehicle_Detail__c = vehicleDetailObj.Id;
        finalTermObj.Installment_Frequency__c = 'Monthly';
        finalTermObj.Rreferrer_Incentive__c = '112';
        finalTermObj.Provisional_Channel_Cost__c = '2000';
        finalTermObj.EMI_Amount__c = 1230;
        finalTermObj.Structured_L1_Call__c = true;
        insert finalTermObj;
        
        Id caseFIRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('FI').getRecordTypeId();
        Case cse = TestDataUtility.createTestCase(true,opks1,apks1);
        cse.RecordTypeId = caseFIRecordTypeId;
        update cse;
        Field_Investigation__c fi = TestDataUtility.createTestFieldInvestigation(false,cse);
        fi.Relationship__c = '';
        fi.Area__c = '123';
        fi.Pin_Code__c = '600066';
        fi.Land_Irrigation_source__c = 'test';
        fi.Type_of_Crop__c = 'test';
        fi.Yield_Per_Acre_monthly__c = 1234;
        fi.IS_CUSTOMER_HAVING_IMPLEMENT__c = 'Yes';
        fi.Agri_Commercial__c = 'Yes';
        fi.Since_how_long_in_Agri_commercial__c = '4';
        fi.Sub_Scheme_Type__c = '0.1-2 acre';
        fi.Scheme_Type__c = 'FTU';
        fi.Existing_no_of_vehicles__c = 'More than two 4 wheeler';
        fi.Number_of_Earning_Member_in_Family__c = '>5';
        fi.Assets_at_Home_Sum_up__c = 'Electricity';
        fi.How_many_members_in_the_Family__c = 4;
        insert fi;
        
        Cattle_Information__c  cattleRec = new Cattle_Information__c ();
        cattleRec.Nos_of_Cattle__c = 5;
        cattleRec.Cattle_Name__c  = 'BULL';
        cattleRec.Field_Investigation__c = fi.Id;
        insert cattleRec;
        
        Land_Holding_Detail__c lh = new Land_Holding_Detail__c();
        lh.Field_Investigation__c = fi.Id;
        lh.Survey_No__c = 'A123';
        lh.Land_holding_In_acres__c = 12;
        lh.Ownership_Type__c = 'Individual';
        lh.Land_holder_Name__c = 'test';
        lh.Type__c = 'Borrower';
        lh.Approximate_value_of_Agri_Land__c = 12345;
        insert lh;
        
        Existing_Tractor_Loan_Information__c etli = new Existing_Tractor_Loan_Information__c();
        etli.Field_Investigation__c = fi.Id;
        etli.Loan_Free__c = 'No';
        insert etli;
        
        Crop_Master__c cm = new Crop_Master__c();
        cm.Yield_Acre__c = 123;
        cm.Sold_Price__c = 1234;
        insert cm;
        
        Crop_Detail__c cd = new Crop_Detail__c();
        cd.Crop_Type__c = 'Kharif';
        cd.Net_Income__c = 1234;
        cd.Crop_Master__c = cm.Id;
        cd.Land_Survey_No__c = 'A123';
        cd.Field_Investigation__c = fi.Id;
        insert cd;
        
        Crop_Detail__c cd1 = new Crop_Detail__c();
        cd1.Crop_Type__c = 'Summer';
        cd1.Net_Income__c = 1234;
        cd1.Crop_Master__c = cm.Id;
        cd1.Land_Survey_No__c = 'A12321QXAS';
        cd1.Field_Investigation__c = fi.Id;
        insert cd1;
        
        Crop_Detail__c cd2 = new Crop_Detail__c();
        cd2.Crop_Type__c = 'Rabi';
        cd2.Net_Income__c = 1234;
        cd2.Crop_Master__c = cm.Id;
        cd2.Land_Survey_No__c = 'A12321Q';
        cd2.Field_Investigation__c = fi.Id;
        insert cd2;
        
        KCC_And_Other_Loan_Information__c  kccRec = new KCC_And_Other_Loan_Information__c();
        kccRec.Loan_Type__c = 'KCC';
        kccRec.Loan_Stakeholders__c = 'Borrower';
        kccRec.Loan_number__c = '1234R';
        kccRec.LOAN_AMOUNT__c = 20000;
        kccRec.BANK_NAME__c = 'Test';
        kccRec.Loan_Start_Date__c  = Date.newInstance(2020, 05, 20);
        kccRec.EMI_Amount__c  = '2000';
        kccRec.Last_EMI_Paid_Date__c  = Date.newInstance(2023, 05, 20);
        kccRec.Total_Remarks_by_FI_Agent__c = 'test';
        kccRec.Model_Details__c = 'test';
		kccRec.Field_Investigation__c = fi.Id;
        insert kccRec;
        
        Total_Expense_and_investment__c totalExpenseRec = new Total_Expense_and_investment__c();
        totalExpenseRec.Name ='TESTREC';
        totalExpenseRec.Type__c ='Expense';
        totalExpenseRec.Expenses_and_Investment_Type__c  ='Approx Medical Expenses';
        totalExpenseRec.Amount__c =1213;
        totalExpenseRec.Field_Investigation__c = fi.Id;
        insert totalExpenseRec;
        
        Category_Master__c categoryMasterRec = new Category_Master__c();
        categoryMasterRec.Category__c = 'Test Cat 1';
        categoryMasterRec.Sub_category__c = 'Test Sub cat 1';
        categoryMasterRec.Income__c = 12;
        insert categoryMasterRec;
        
        Non_Agri_Income__c agriRec = new Non_Agri_Income__c();
        agriRec.Utilization__c = '65';
        agriRec.Total_Income__c = 250;
        agriRec.Category_Master__c = categoryMasterRec.Id;
        agriRec.Field_Investigation__c = fi.Id;
        insert agriRec;
        
        Viability_of_Existing_Proposed_Tractor__c viablityRec = new Viability_of_Existing_Proposed_Tractor__c();
        viablityRec.Usage_Type__c = 'Agriculture';
        viablityRec.Diesal_counsumption_hr__c = 4;
        viablityRec.Diesal_Rate_Hr__c = 88;
        viablityRec.Existing_Proposed__c = 'Proposed';
        viablityRec.Expenses__c = 100;
        viablityRec.Net_Income__c = 2000;
        viablityRec.Nos_of_Hours_run_in_year__c = 10;
        viablityRec.Per_Hour_Rate__c = 500;
        viablityRec.Total_Income__c = 5000;
        viablityRec.Tractor_Harvester__c = 'Tractor';
        viablityRec.Field_Investigation__c = fi.Id;
        insert viablityRec;
    }
    
    @isTest
    public static void IND_CombinedBERRequestTest1(){
        Opportunity opks1 = [Select id,Vehicle_Type__c From Opportunity limit 1];
        
        Vehicle_Detail__c vehicleDetailObj = [Select Id From Vehicle_Detail__c Limit 1];
        
        Test.startTest();
        IND_CombinedBERRequest testCont = new IND_CombinedBERRequest(opks1.Id,vehicleDetailObj.Id);
        Test.stopTest();
    }
}