@isTest
public class IND_InsuranceDetailsLWC_controllerTest {
    @isTest
    public static void enableCheckboxTest(){
        try{
            Opportunity opec1 = new Opportunity();
            opec1.StageName = 'Qualification';
            opec1.CloseDate = Date.newInstance(2021, 1, 11);
            opec1.Name = 'testone';
            insert opec1;
            
            Applicant__c apec1 = new Applicant__c();
            apec1.Opportunity__c = opec1.Id;
            apec1.Contact_number__c = '9743514830';
            apec1.Applicant_Type__c = 'Borrower';
            apec1.Insurance_Consent_Received__c = false;
            insert apec1;
            
            Test.startTest();
            IND_InsuranceDetailsLWC_controller.enableCheckbox(apec1.Id);
            IND_InsuranceDetailsLWC_controller.enableCheckbox(null);
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void enableCheckboxTest1(){
        
        Opportunity opec1 = new Opportunity();
        opec1.StageName = 'Qualification';
        opec1.CloseDate = Date.newInstance(2021, 1, 11);
        opec1.Name = 'testone';
        insert opec1;
        
        Applicant__c apec1 = new Applicant__c();
        apec1.Opportunity__c = opec1.Id;
        apec1.Contact_number__c = '9743514830';
        apec1.Applicant_Type__c = 'Borrower';
        apec1.Insurance_Consent_Received__c = True;
        insert apec1;
        
        Test.startTest();
        IND_InsuranceDetailsLWC_controller.enableCheckbox(apec1.Id);
        Test.stopTest();
    }
    
    @isTest
    public static void enableCheckboxTest2(){
        try{
            Opportunity opec2 = new Opportunity();
            opec2.StageName = 'Qualification';
            opec2.CloseDate = Date.newInstance(2021, 1, 11);
            opec2.Name = 'testone';
            insert opec2;
            
            Test.startTest();
            IND_InsuranceDetailsLWC_controller.enableCheckbox('test');
            IND_InsuranceDetailsLWC_controller.enableCheckbox(null);
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void getMotorVechileDetailsTest(){
        
        Opportunity opgd1 = new Opportunity();
        opgd1.StageName = 'Qualification';
        opgd1.CloseDate = Date.newInstance(2021, 1, 11);
        opgd1.Name = 'testone';
        insert opgd1;
        
        Applicant__c apgd1 = new Applicant__c();
        apgd1.Opportunity__c = opgd1.Id;
        apgd1.Contact_number__c = '9743514830';
        apgd1.Applicant_Type__c = 'Borrower';
        apgd1.In_Active_Applicant__c = false;
        insert apgd1;
        
        Vehicle_Detail__c vgd1 = new Vehicle_Detail__c();
        vgd1.Loan_Application__c = opgd1.Id;
        vgd1.Base_Price__c = 100000.00;
        vgd1.Ben_Code__c = 'testveh';
        insert vgd1; 
        
        IND_InsuranceDetailsLWC_controller.InsurancePremiumAPIResponseWrapper ip1 = new IND_InsuranceDetailsLWC_controller.InsurancePremiumAPIResponseWrapper();
        ip1.applicationNo = apgd1.Id;
        ip1.vehicleID = vgd1.Id;
        ip1.premium = 100000.00;
        ip1.lhc = 10000.00;
        ip1.statusFlag = 'true';
        ip1.errorCode = 401;
        ip1.errorDescription = 'server';
        
        Test.startTest();
        IND_InsuranceDetailsLWC_controller.getMotorVechileDetails(apgd1.Id);
        Test.stopTest();
    }
    
    @isTest
    public static void getInsuranceDetailsTest(){
        Opportunity opid1 = new Opportunity();
        opid1.StageName = 'Qualification';
        opid1.CloseDate = Date.newInstance(2021, 1, 11);
        opid1.Name = 'testone';
        insert opid1;
        
        Applicant__c apid1 = new Applicant__c();
        apid1.Opportunity__c = opid1.Id;
        apid1.Contact_number__c = '9743514830';
        apid1.Applicant_Type__c = 'Borrower';
        apid1.In_Active_Applicant__c = false;
        insert apid1;
        
        InsuranceDetails__c id1 = new InsuranceDetails__c();
        id1.Applicant__c = apid1.Id;
        id1.Loan_Application__c = opid1.Id;
        id1.Name = 'Insurance';
        insert id1;
        
        Test.startTest();
        //IND_InsuranceDetailsLWC_controller.getInsuranceDetails(apid1.Id);
        Test.stopTest();
    } 
    
    @isTest
    public static void fetchDataFromApplicatntObjTest(){
        Opportunity opfa1 = new Opportunity();
        opfa1.StageName = 'Qualification';
        opfa1.CloseDate = Date.newInstance(2021, 1, 11);
        opfa1.Name = 'testone';
        insert opfa1;
        
        Applicant__c apfa1 = new Applicant__c();
        apfa1.Opportunity__c = opfa1.Id;
        apfa1.Contact_number__c = '9743514830';
        apfa1.Applicant_Type__c = 'Borrower';
        insert apfa1;
        
        Test.startTest();
        //IND_InsuranceDetailsLWC_controller.fetchDataFromApplicatntObj(opfa1.Id,'Borrower');
        //Ashay
        IND_InsuranceDetailsLWC_controller.fetchDataFromApplicatntObj(opfa1.Id,'Borrower',apfa1.Id);
        Test.stopTest();
    }
    
    @isTest
    public static void fetchDataFromLoanApplicationTest(){
        
        Opportunity opfd1 = new Opportunity();
        opfd1.StageName = 'Qualification';
        opfd1.CloseDate = Date.newInstance(2021, 1, 11);
        opfd1.Name = 'testone';
        insert opfd1;
        
        Test.startTest();
        IND_InsuranceDetailsLWC_controller.fetchDataFromLoanApplication(opfd1.Id);
        Test.stopTest();
    }
    
    @isTest
    public static void fetchDataFromvehicleDetailsObjTest(){
        
        Opportunity opdf1 = new Opportunity();
        opdf1.StageName = 'Qualification';
        opdf1.CloseDate = Date.newInstance(2021, 1, 11);
        opdf1.Name = 'testone';
        insert opdf1;
        
        Vehicle_Detail__c vgd1 = new Vehicle_Detail__c();
        vgd1.Loan_Application__c = opdf1.Id;
        vgd1.Base_Price__c = 100000.00;
        vgd1.Ben_Code__c = 'testveh';
        insert vgd1; 
        
        Test.startTest();
        IND_InsuranceDetailsLWC_controller.fetchDataFromvehicleDetailsObj(opdf1.Id);
        Test.stopTest();
    }
    
    @isTest
    public static void existInsuranceDetailsMethodTest(){
        
        Opportunity opem1 = new Opportunity();
        opem1.StageName = 'Qualification';
        opem1.CloseDate = Date.newInstance(2021, 1, 11);
        opem1.Name = 'testone';
        insert opem1;
        
        Applicant__c apem1 = new Applicant__c();
        apem1.Opportunity__c = opem1.Id;
        apem1.Contact_number__c = '9743514830';
        apem1.Applicant_Type__c = 'Borrower';
        apem1.In_Active_Applicant__c = false;
        insert apem1;
        
        InsuranceDetails__c id1 = new InsuranceDetails__c();
        id1.Applicant__c = apem1.Id;
        id1.Loan_Application__c = opem1.Id;
        id1.Name = 'Insurance';
        insert id1;
        
        Test.startTest();
        IND_InsuranceDetailsLWC_controller.existInsuranceDetailsMethod(opem1.Id,apem1.Id);
        Test.stopTest();
    }
    
    @isTest
    public static void getMotorInsurancePreimumTest(){
        
        InsuranceMaster__c im1 = new InsuranceMaster__c();
        im1.Active__c = 'im';
        im1.Insurance_Company_Code__c = 'AUT';
        im1.Name = System.Label.InsuranceMaster;
        insert im1;
        
        Insurance_Premium_details__c ipd1 = new Insurance_Premium_details__c();
        ipd1.Insurance_Master__c = im1.Id;
        ipd1.Active_Flag__c = 'gm';
        ipd1.Addl_Doc_Charges__c = 1000.00;
        ipd1.Disable_Funding__c = 'testnft';
        ipd1.Insurance_Plan_Code__c = 'testplan';
        ipd1.Period__c = 100.0;
        ipd1.Premium__c = 1000.00;
        ipd1.Ins_Product__c = 'HEALTH';
        ipd1.Insurance_Plan_Code__c = 'Plancode 2';
        ipd1.Sum_Insured__c = 5000000;
        ipd1.External_id__c = '12';
        insert ipd1;
        
        Test.startTest();
        IND_InsuranceDetailsLWC_controller.getMotorInsurancePreimum(ipd1.Ins_Product__c,ipd1.Insurance_Plan_Code__c);
        Test.stopTest();
        
    }
    
    @isTest
    public static void callInuranceRecAPITest(){
        
        Opportunity opra1 = new Opportunity();
        opra1.StageName = 'Qualification';
        opra1.CloseDate = Date.newInstance(2021, 1, 11);
        opra1.Name = 'testone';
        opra1.Insurance_expiring_within_90_days__c = true;
        opra1.Funding_on_ORP__c = true;
        insert opra1;
        
        Applicant__c apra1 = new Applicant__c();
        apra1.Opportunity__c = opra1.Id;
        apra1.Contact_number__c = '9743514830';
        apra1.Applicant_Type__c = 'Borrower';
        insert apra1;
        
        Documents__c dtg1 = new Documents__c();
        dtg1.Applicant__c = apra1.Id;
        dtg1.Opportunity_Relation__c = opra1.Id;
        dtg1.Document_Type__c = System.Label.AadhaarCard;
        dtg1.Document_Side__c ='Back';
        dtg1.Aadhar_Source__c = 'ScanAadhar';
        dtg1.Age__c = 25;
        dtg1.KYC_DOB__c = Date.newInstance(1997, 06, 23);
        dtg1.Gender__c = 'MALE';
        dtg1.Proof_of_Identity_POI__c = true;
        insert dtg1;
        
        Final_Term__c fgd3 = new Final_Term__c();
        fgd3.CRM_IRR__c = 120;
        fgd3.Loan_Application__c = opra1.Id;
        fgd3.Holiday_period__c='30';
        fgd3.EMI_Amount__c= 10000;
        //   fgd3.Agreement_Amount__c = 100000.00;
        insert fgd3;
        
        Vehicle_Detail__c vgd1 = new Vehicle_Detail__c();
        vgd1.Loan_Application__c = opra1.Id;
        vgd1.Base_Price__c = 100000.00;
        vgd1.Ben_Code__c = 'testveh';
        vgd1.Vehicle_type__c = 'New';
        insert vgd1;
        
        RequestWrapper rw1 = new RequestWrapper();
        rw1.applicantId = apra1.id;
        rw1.Borrower_Type = apra1.Applicant_Type__c;
        
        Test.startTest();
        IND_InsuranceDetailsLWC_controller.callInuranceRecAPI(apra1.Applicant_Type__c,opra1.Id);
        Test.stopTest();
        
    }
    
    @isTest
    public static void callInuranceRecAPITest11(){
        
        Opportunity opra1 = new Opportunity();
        opra1.StageName = 'Qualification';
        opra1.CloseDate = Date.newInstance(2021, 1, 11);
        opra1.Name = 'testone';
        opra1.Insurance_expiring_within_90_days__c = true;
        opra1.Funding_on_Ex_Showroom__c = true;
        insert opra1;
        
        Applicant__c apra1 = new Applicant__c();
        apra1.Opportunity__c = opra1.Id;
        apra1.Contact_number__c = '9743514830';
        apra1.Applicant_Type__c = 'Borrower';
        insert apra1;
        
        Documents__c dtg1 = new Documents__c();
        dtg1.Applicant__c = apra1.Id;
        dtg1.Opportunity_Relation__c = opra1.Id;
        dtg1.Document_Type__c = System.Label.AadhaarCard;
        dtg1.Document_Side__c ='Back';
        dtg1.Aadhar_Source__c = 'ScanAadhar';
        dtg1.Age__c = 25;
        dtg1.KYC_DOB__c = Date.newInstance(1997, 06, 23);
        dtg1.Gender__c = 'MALE';
        dtg1.Proof_of_Identity_POI__c = true;
        insert dtg1;
        
        Final_Term__c fgd3 = new Final_Term__c();
        fgd3.CRM_IRR__c = 120;
        fgd3.Loan_Application__c = opra1.Id;
        fgd3.Holiday_period__c='30';
        fgd3.EMI_Amount__c= 10000;
        //   fgd3.Agreement_Amount__c = 100000.00;
        insert fgd3;
        
        Vehicle_Detail__c vgd1 = new Vehicle_Detail__c();
        vgd1.Loan_Application__c = opra1.Id;
        vgd1.Base_Price__c = 100000.00;
        vgd1.Ben_Code__c = 'testveh';
        vgd1.Vehicle_type__c = 'New';
        insert vgd1;
        
        RequestWrapper rw1 = new RequestWrapper();
        rw1.applicantId = apra1.id;
        rw1.Borrower_Type = apra1.Applicant_Type__c;
        
        Test.startTest();
        IND_InsuranceDetailsLWC_controller.callInuranceRecAPI(apra1.Applicant_Type__c,opra1.Id);
        Test.stopTest();
        
    }
    
    @isTest
    public static void callInuranceRecAPITest12(){
        
        Opportunity opra1 = new Opportunity();
        opra1.StageName = 'Qualification';
        opra1.CloseDate = Date.newInstance(2021, 1, 11);
        opra1.Name = 'testone';
        opra1.Insurance_expiring_within_90_days__c = true;
        opra1.Funding_on_Ex_Showroom__c = true;
        insert opra1;
        
        Applicant__c apra1 = new Applicant__c();
        apra1.Opportunity__c = opra1.Id;
        apra1.Contact_number__c = '9743514830';
        apra1.Applicant_Type__c = 'Borrower';
        insert apra1;
        
        Documents__c dtg1 = new Documents__c();
        dtg1.Applicant__c = apra1.Id;
        dtg1.Opportunity_Relation__c = opra1.Id;
        dtg1.Document_Type__c = System.Label.AadhaarCard;
        dtg1.Document_Side__c ='Back';
        dtg1.Aadhar_Source__c = 'ScanAadhar';
        dtg1.Age__c = 25;
        dtg1.KYC_DOB__c = Date.newInstance(1997, 06, 23);
        dtg1.Gender__c = 'MALE';
        dtg1.Proof_of_Identity_POI__c = true;
        insert dtg1;
        
        Final_Term__c fgd3 = new Final_Term__c();
        fgd3.CRM_IRR__c = 120;
        fgd3.Loan_Application__c = opra1.Id;
        fgd3.Holiday_period__c='30';
        fgd3.EMI_Amount__c= 10000;
        //   fgd3.Agreement_Amount__c = 100000.00;
        insert fgd3;
        
        Vehicle_Detail__c vgd1 = new Vehicle_Detail__c();
        vgd1.Loan_Application__c = opra1.Id;
        vgd1.Base_Price__c = 100000.00;
        vgd1.Ben_Code__c = 'testveh';
        vgd1.Vehicle_type__c = 'Used';
        insert vgd1;
        
        RequestWrapper rw1 = new RequestWrapper();
        rw1.applicantId = apra1.id;
        rw1.Borrower_Type = apra1.Applicant_Type__c;
        
        Test.startTest();
        IND_InsuranceDetailsLWC_controller.callInuranceRecAPI(apra1.Applicant_Type__c,opra1.Id);
        IND_InsuranceDetailsLWC_controller.getBorrowerDocument(opra1.Id);
        IND_InsuranceDetailsLWC_controller.getBorrowerDocument(null);

        Test.stopTest();
        
    }
    
    @isTest
    public static void callInuranceRecAPITest1(){
        
        Opportunity opra1 = new Opportunity();
        opra1.StageName = 'Qualification';
        opra1.CloseDate = Date.newInstance(2021, 1, 11);
        opra1.Name = 'testone';
        opra1.Insurance_expiring_within_90_days__c = false;
        insert opra1;
        
        Applicant__c apra1 = new Applicant__c();
        apra1.Opportunity__c = opra1.Id;
        apra1.Contact_number__c = '9743514830';
        apra1.Applicant_Type__c = 'Borrower';
        insert apra1;
        
        Documents__c dtg1 = new Documents__c();
        dtg1.Applicant__c = apra1.Id;
        dtg1.Opportunity_Relation__c = opra1.Id;
        dtg1.Document_Type__c = System.Label.AadhaarCard;
        dtg1.Document_Side__c ='Back';
        dtg1.Aadhar_Source__c = 'ScanAadhar';
        dtg1.Age__c = null;
        dtg1.KYC_DOB__c = Date.newInstance(1997, 06, 23);
        dtg1.Gender__c = 'MALE';
        dtg1.Proof_of_Identity_POI__c = true;
        insert dtg1;
        
        
        Final_Term__c fgd4 = new Final_Term__c();
        fgd4.CRM_IRR__c = 120;
        fgd4.Loan_Application__c = opra1.Id;
        fgd4.Holiday_period__c='30';
        fgd4.EMI_Amount__c= 10000;
        //   fgd3.Agreement_Amount__c = 100000.00;
        insert fgd4;
        
        Vehicle_Detail__c vgd1 = new Vehicle_Detail__c();
        vgd1.Loan_Application__c = opra1.Id;
        vgd1.Base_Price__c = 100000.00;
        vgd1.Ben_Code__c = 'testveh';
        insert vgd1;
        
        RequestWrapper rw1 = new RequestWrapper();
        rw1.applicantId = apra1.id;
        rw1.Borrower_Type = apra1.Applicant_Type__c;
        
        Test.startTest();
        IND_InsuranceDetailsLWC_controller.callInuranceRecAPI(apra1.Applicant_Type__c,opra1.Id);
        Test.stopTest();
        
    }
    
    @isTest
    public static void callInuranceRecAPITest14(){
        
        Opportunity opra1 = new Opportunity();
        opra1.StageName = 'Qualification';
        opra1.CloseDate = Date.newInstance(2021, 1, 11);
        opra1.Name = 'testone';
        opra1.Insurance_expiring_within_90_days__c = false;
        insert opra1;
        
        Applicant__c apra1 = new Applicant__c();
        apra1.Opportunity__c = opra1.Id;
        apra1.Contact_number__c = '9743514830';
        apra1.Applicant_Type__c = 'Borrower';
        insert apra1;
        
        Documents__c dtg1 = new Documents__c();
        dtg1.Applicant__c = apra1.Id;
        dtg1.Opportunity_Relation__c = opra1.Id;
        dtg1.Document_Type__c = System.Label.AadhaarCard;
        dtg1.Document_Side__c ='Back';
        dtg1.Aadhar_Source__c = 'ScanAadhar';
        dtg1.Age__c = null;
        dtg1.KYC_DOB__c = Date.newInstance(1997, 06, 23);
        dtg1.Gender__c = 'MALE';
        dtg1.Proof_of_Identity_POI__c = true;
        insert dtg1;
        
        
        Final_Term__c fgd4 = new Final_Term__c();
        fgd4.CRM_IRR__c = 120;
        fgd4.Loan_Application__c = opra1.Id;
        fgd4.Holiday_period__c='30';
        fgd4.EMI_Amount__c= 10000;
        //   fgd3.Agreement_Amount__c = 100000.00;
        insert fgd4;
        
        Vehicle_Detail__c vgd1 = new Vehicle_Detail__c();
        vgd1.Loan_Application__c = opra1.Id;
        vgd1.Base_Price__c = 100000.00;
        vgd1.Ben_Code__c = 'testveh';
        vgd1.Vehicle_type__c = 'New';
        insert vgd1;
        
        RequestWrapper rw1 = new RequestWrapper();
        rw1.applicantId = apra1.id;
        rw1.Borrower_Type = apra1.Applicant_Type__c;
        
        Test.startTest();
        IND_InsuranceDetailsLWC_controller.callInuranceRecAPI(apra1.Applicant_Type__c,opra1.Id);
        Test.stopTest();
        
    }
    
    @isTest
    public static void getApplicantIdTest(){
        try{
            Opportunity opgi1 = new Opportunity();
            opgi1.StageName = 'Qualification';
            opgi1.CloseDate = Date.newInstance(2021, 1, 11);
            opgi1.Name = 'testone';
            opgi1.Insurance_expiring_within_90_days__c = false;
            insert opgi1;
            
            Applicant__c apgi1 = new Applicant__c();
            apgi1.Opportunity__c = opgi1.Id;
            apgi1.Contact_number__c = '9743514830';
            apgi1.Applicant_Type__c = 'Borrower';
            insert apgi1;
            
            Test.startTest();
            IND_InsuranceDetailsLWC_controller.getApplicantId(opgi1.Id,apgi1.Applicant_Type__c);
            IND_InsuranceDetailsLWC_controller.getApplicantId(null,apgi1.Applicant_Type__c);
            Test.stopTest();
            
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void getApplicantIdTest1(){
        try{
            Opportunity opgi1 = new Opportunity();
            opgi1.StageName = 'Qualification';
            opgi1.CloseDate = Date.newInstance(2021, 1, 11);
            opgi1.Name = 'testone';
            insert opgi1;
            
            Test.startTest();
            IND_InsuranceDetailsLWC_controller.getApplicantId(opgi1.Id,'test');
            Test.stopTest();
            
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void sendInsuranceConsentTest(){
        try{
            Opportunity opic1 = new Opportunity();
            opic1.StageName = 'Qualification';
            opic1.CloseDate = Date.newInstance(2021, 1, 11);
            opic1.Name = 'testone';
            insert opic1;
            
            Applicant__c apic1 = new Applicant__c();
            apic1.Opportunity__c = opic1.Id;
            apic1.Contact_number__c = '9743514830';
            apic1.Applicant_Type__c = 'Borrower';
            insert apic1;
            
            Test.startTest();
            IND_InsuranceDetailsLWC_controller.sendInsuranceConsent(opic1.Id,apic1.Applicant_Type__c);
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void sendInsuranceConsentTest1(){
        try{
            Opportunity opic2 = new Opportunity();
            opic2.StageName = 'Qualification';
            opic2.CloseDate = Date.newInstance(2021, 1, 11);
            opic2.Name = 'testone';
            insert opic2;
            
            Test.startTest();
            IND_InsuranceDetailsLWC_controller.sendInsuranceConsent(opic2.Id,'test');
            Test.stopTest();
        }catch(Exception e){
            // System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void sendInsuranceConsentForSMSTest(){
        try{
            Opportunity opcf1 = new Opportunity();
            opcf1.StageName = 'Qualification';
            opcf1.CloseDate = Date.newInstance(2021, 1, 11);
            opcf1.Name = 'testone';
            insert opcf1;
            
            Applicant__c apcf1 = new Applicant__c();
            apcf1.Opportunity__c = opcf1.Id;
            apcf1.Contact_number__c = '9743514830';
            apcf1.Applicant_Type__c = 'Borrower';
            apcf1.In_Active_Applicant__c = false;
            insert apcf1;
            
            Test.startTest();
            //  IND_InsuranceDetailsLWC_controller.sendInsuranceConsentForSMS(opcf1.Id,apcf1.Applicant_Type__c);
            Test.stopTest();
            
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void sendInsuranceConsentForSMSTest1(){
        try{
            Opportunity opcf2 = new Opportunity();
            opcf2.StageName = 'Qualification';
            opcf2.CloseDate = Date.newInstance(2021, 1, 11);
            opcf2.Name = 'testone';
            insert opcf2;
            
            Test.startTest();
            //   IND_InsuranceDetailsLWC_controller.sendInsuranceConsentForSMS(opcf2.Id,'test');
            Test.stopTest();
            
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    } 
    
    @isTest
    public static void getInsuranceDetailsFromMasterTest(){
        try{
            
            Opportunity opdf1 = new Opportunity();
            opdf1.StageName = 'Qualification';
            opdf1.CloseDate = Date.newInstance(2021, 1, 11);
            opdf1.Name = 'testone';
            opdf1.Product_Type__c = System.Label.TwoWheeler;
            insert opdf1;
            
            InsuranceMaster__c im2 = new InsuranceMaster__c();
            im2.Name = 'Cholamandalam MS General Insurance Company Ltd.';
            im2.Active__c = 'im';
            im2.Insurance_Company_Code__c = 'AUT';
            //  im2.Name = System.Label.InsuranceMaster;
            insert im2;
            
            Insurance_Premium_details__c ipd2 = new Insurance_Premium_details__c();
            ipd2.Insurance_Master__c = im2.Id;
            ipd2.Addl_Doc_Charges__c = 1000.00;
            ipd2.Disable_Funding__c = 'testnft';
            ipd2.Insurance_Plan_Code__c = 'testplan';
            ipd2.Period__c = 100.0;
            ipd2.Premium__c = 1000.00;
            ipd2.Ins_Product__c = 'HEALTH';
            ipd2.Insurance_Plan_Code__c = 'Plancode 2';
            ipd2.Sum_Insured__c = 5000000;
            ipd2.External_id__c = '12';
            ipd2.Active_Flag__c = 'Y';
            ipd2.Loan_Product__c = 'H';
            insert ipd2;
            
            IND_InsuranceDetailsLWC_controller.Ins_Product ip1 = new IND_InsuranceDetailsLWC_controller.Ins_Product();
            ip1.Ins_Product = ipd2.Ins_Product__c;
            ip1.Plan_Code = 'testcode';
            ip1.Plan_Name = 'testname';
            ip1.Premium = 'testpremium';
            ip1.Sum_Insured = 'testsum';
            ip1.LHC = 'testlhc';
            ip1.Plan_Recommend = 'testplan';
            ip1.Disable_Funding = 'testdisable';
            ip1.Funding_Option = 'testoption';
            //   ip1.Stage = 'teststage';
            //    ip1.Sub_Stage = 'testsub';
            
            Test.startTest();
            IND_InsuranceDetailsLWC_controller.getInsuranceDetailsFromMaster(opdf1.Id);
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void getInsuranceDetailsFromMasterTest1(){
        try{
            
            Opportunity opdf1 = new Opportunity();
            opdf1.StageName = 'Qualification';
            opdf1.CloseDate = Date.newInstance(2021, 1, 11);
            opdf1.Name = 'testone';
            opdf1.Product_Type__c = System.Label.PassengerVehicles;
            insert opdf1;
            
            InsuranceMaster__c im2 = new InsuranceMaster__c();
            im2.Name = 'Cholamandalam MS General Insurance Company Ltd.';
            im2.Active__c = 'im';
            im2.Insurance_Company_Code__c = 'AUT';
            //  im2.Name = System.Label.InsuranceMaster;
            insert im2;
            
            Insurance_Premium_details__c ipd2 = new Insurance_Premium_details__c();
            ipd2.Insurance_Master__c = im2.Id;
            ipd2.Addl_Doc_Charges__c = 1000.00;
            ipd2.Disable_Funding__c = 'testnft';
            ipd2.Insurance_Plan_Code__c = 'testplan';
            ipd2.Period__c = 100.0;
            ipd2.Premium__c = 1000.00;
            ipd2.Ins_Product__c = 'HEALTH';
            ipd2.Insurance_Plan_Code__c = 'Plancode 2';
            ipd2.Sum_Insured__c = 5000000;
            ipd2.External_id__c = '12';
            ipd2.Active_Flag__c = 'Y';
            ipd2.Loan_Product__c = 'H';
            insert ipd2;
            
            IND_InsuranceDetailsLWC_controller.Ins_Product ip1 = new IND_InsuranceDetailsLWC_controller.Ins_Product();
            ip1.Ins_Product = ipd2.Ins_Product__c;
            ip1.Plan_Code = 'testcode';
            ip1.Plan_Name = 'testname';
            ip1.Premium = 'testpremium';
            ip1.Sum_Insured = 'testsum';
            ip1.LHC = 'testlhc';
            ip1.Plan_Recommend = 'testplan';
            ip1.Disable_Funding = 'testdisable';
            ip1.Funding_Option = 'testoption';
            //   ip1.Stage = 'teststage';
            //    ip1.Sub_Stage = 'testsub';
            
            Test.startTest();
            IND_InsuranceDetailsLWC_controller.getInsuranceDetailsFromMaster(opdf1.Id);
            IND_InsuranceDetailsLWC_controller.getInsuranceDetailsFromMaster('test');
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void isCustomerrequestedinMotorinsuranceTest(){
        try{
            Opportunity opcr1 = new Opportunity();
            opcr1.StageName = 'Qualification';
            opcr1.CloseDate = Date.newInstance(2021, 1, 11);
            opcr1.Name = 'testone';
            opcr1.Is_customer_interested_in_a_motor_insura__c = false;
            insert opcr1;
            
            Test.startTest();
            IND_InsuranceDetailsLWC_controller.isCustomerrequestedinMotorinsurance(opcr1.Id);
            Test.stopTest();
            
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void getMotorInsuranceFromLoanDetailsTest(){
        try{
            Opportunity opld1 = new Opportunity();
            opld1.StageName = 'Qualification';
            opld1.CloseDate = Date.newInstance(2021, 1, 11);
            opld1.Name = 'testone';
            opld1.Is_customer_interested_in_a_motor_insura__c = true;
            opld1.Vehicle_Type__c = System.Label.used;
            opld1.Funded__c = true;
            insert opld1;
            
            Test.startTest();
            IND_InsuranceDetailsLWC_controller.getMotorInsuranceFromLoanDetails(opld1.Id);
            IND_InsuranceDetailsLWC_controller.getMotorInsuranceFromLoanDetails(null);
            Test.stopTest();
            
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void getMotorInsuranceFromLoanDetailsTest1(){
        try{
            Opportunity opld1 = new Opportunity();
            opld1.StageName = 'Qualification';
            opld1.CloseDate = Date.newInstance(2021, 1, 11);
            opld1.Name = 'testone';
            opld1.Is_customer_interested_in_a_motor_insura__c = true;
            opld1.Vehicle_Type__c = System.Label.new;
            opld1.Funded__c = true;
            insert opld1;
            
            Test.startTest();
            IND_InsuranceDetailsLWC_controller.getMotorInsuranceFromLoanDetails(opld1.Id);
            IND_InsuranceDetailsLWC_controller.getMotorInsuranceFromLoanDetails(null);
            Test.stopTest();
            
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void submitInsuranceDetailsTest(){
        try{
            Opportunity opid1 = new Opportunity();
            opid1.StageName = 'Qualification';
            opid1.CloseDate = Date.newInstance(2021, 1, 11);
            opid1.Name = 'testone';
            
            insert opid1;
            
            Applicant__c apid1 = new Applicant__c();
            apid1.Opportunity__c = opid1.Id;
            apid1.Contact_number__c = '9743514830';
            apid1.Applicant_Type__c = 'Borrower';
            apid1.In_Active_Applicant__c = false;
            insert apid1; 
            List<IND_InsuranceDetailsLWC_controller.InsuranceWrapper> InsuranceWrapperList = new List<IND_InsuranceDetailsLWC_controller.InsuranceWrapper>();
            IND_InsuranceDetailsLWC_controller.InsuranceWrapper wrapperObj = new IND_InsuranceDetailsLWC_controller.InsuranceWrapper();
            wrapperObj.isFunded = true;
            wrapperObj.premium = 1000.00;
            wrapperObj.selectedPlan = 'testselect';
            wrapperObj.selectedProduct = 'testprd';
            InsuranceWrapperList.add(wrapperObj);
            
            IND_InsuranceDetailsLWC_controller.InsuranceWrapper iw = new IND_InsuranceDetailsLWC_controller.InsuranceWrapper();
            iw.isFunded = false;
            iw.premium = 1000.00;
            iw.selectedPlan = 'LI_EMI';
            iw.selectedProduct = 'LI_EMI';
            iw.comboLIPremium = 516.00;
            iw.comboEMIPremium = 4231.00;
            iw.eMIPassedinAPI = 516.00;
            InsuranceWrapperList.add(iw);
            IND_InsuranceDetailsLWC_controller.SubmitInsuranceRequestWrapper sr1 = new IND_InsuranceDetailsLWC_controller.SubmitInsuranceRequestWrapper();
            sr1.applicantId = apid1.Id;
            sr1.loanApplicationId = opid1.Id;
            sr1.ltvWithInsurance = 500;
            sr1.ltvWithoutInsurance = 500;
            sr1.totalInsurancePayable = 100.00;
            sr1.proposalLtv = 200.00;
            sr1.insProductDetails = InsuranceWrapperList;
            sr1.nextStage = 'Needs Analysis';
            sr1.premiumFunded = 500;
            sr1.submittedTabs = 'L1 - Borrower Insurance';
            
            Applicant__c apid2 = new Applicant__c();
            apid2.Opportunity__c = sr1.loanApplicationId;
            apid2.Contact_number__c = '9743514830';
            apid2.Applicant_Type__c = 'Borrower';
            apid2.In_Active_Applicant__c = false;
            apid2.LTV_without_insurance__c = sr1.ltvWithoutInsurance;
            insert apid2; 
            
            InsuranceDetails__c isd1 = new InsuranceDetails__c();
            isd1.Loan_Application__c = sr1.loanApplicationId;
            isd1.Applicant__c = sr1.applicantId;
            isd1.Name = 'TEST';
            insert isd1;
            
            Test.startTest();
            IND_InsuranceDetailsLWC_controller.submitInsuranceDetails(Json.serialize(sr1));
            IND_InsuranceDetailsLWC_controller.submitInsuranceDetails(null);
            Test.stopTest();
            
            
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }   
    
    
    @isTest
    public static void submitInsuranceDetailsTest1(){
        try{
            Opportunity opid1 = new Opportunity();
            opid1.StageName = 'Qualification';
            opid1.CloseDate = Date.newInstance(2021, 1, 11);
            opid1.Name = 'testone';
            opid1.StageName = 'Proposal';
            insert opid1;
            
            Applicant__c apid1 = new Applicant__c();
            apid1.Opportunity__c = opid1.Id;
            apid1.Contact_number__c = '9743514830';
            apid1.Applicant_Type__c = 'Borrower';
            apid1.In_Active_Applicant__c = false;
            insert apid1; 
            
            IND_InsuranceDetailsLWC_controller.InsuranceWrapper iw = new IND_InsuranceDetailsLWC_controller.InsuranceWrapper();
            iw.isFunded = null;
            iw.premium = 1000.00;
            iw.selectedPlan = 'testselect';
            iw.selectedProduct = 'testprd';
            
            IND_InsuranceDetailsLWC_controller.SubmitInsuranceRequestWrapper sr1 = new IND_InsuranceDetailsLWC_controller.SubmitInsuranceRequestWrapper();
            sr1.applicantId = apid1.Id;
            sr1.loanApplicationId = opid1.Id;
            sr1.ltvWithInsurance = 500;
            sr1.ltvWithoutInsurance = 500;
            sr1.totalInsurancePayable = 100.00;
            sr1.proposalLtv = 200.00;
            // sr1.gpaInsurance = iw;
            // sr1.healthInsurance = iw;
            // sr1.motorInsurance = iw;
            // sr1.comboInsurance = iw;
            sr1.nextStage = 'Needs Analysis';
            
            Applicant__c apid2 = new Applicant__c();
            apid2.Opportunity__c = sr1.loanApplicationId;
            apid2.Contact_number__c = '9743514830';
            apid2.Applicant_Type__c = 'Borrower';
            apid2.In_Active_Applicant__c = false;
            apid2.LTV_without_insurance__c = sr1.ltvWithoutInsurance;
            insert apid2; 
            
            Test.startTest();
            IND_InsuranceDetailsLWC_controller.submitInsuranceDetails(Json.serialize(sr1));
            IND_InsuranceDetailsLWC_controller.submitInsuranceDetails(null);
            Test.stopTest();
            
            
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }   
    @isTest
    public static void getFundingAvailibilityTest(){
        try{
            Opportunity opfr1 = new Opportunity();
            opfr1.StageName = 'Qualification';
            opfr1.CloseDate = Date.newInstance(2021, 1, 11);
            opfr1.Name = 'testone';
            opfr1.Product_Type__c=System.Label.Tractor;
            opfr1.Vehicle_Type__c = system.Label.new;
            opfr1.Funding_on_Ex_Showroom__c = true;
            opfr1.Ex_showroom_price__c = 300000.00;
            opfr1.Required_Loan_amount__c = 200000.00;
            insert opfr1;
            
            Vehicle_Detail__c vgd1 = new Vehicle_Detail__c();
            vgd1.Loan_Application__c = opfr1.Id;
            vgd1.Base_Price__c = 100000.00;
            vgd1.Ben_Code__c = 'testveh';
            insert vgd1; 
            
            Applicant__c apfr1 = new Applicant__c();
            apfr1.Opportunity__c = opfr1.Id;
            apfr1.Contact_number__c = '9743514830';
            apfr1.Applicant_Type__c = 'Borrower';
            insert apfr1; 
            
            Final_Term__c finalObj = new Final_Term__c();
            finalObj.Rreferrer_Incentive__c = '1000';
            finalObj.Loan_Amount__c = '41000';
            finalObj.OfferengineMinLoanAmount__c = 34534;
            finalObj.Dealer_incentive_amount_main_dealer__c = '567';
            finalObj.Trade_certificate__c = '34543';
            finalObj.Advance_EMI__c = true;
            finalObj.OfferengineMaxLoanAmount__c = 60000;
            finalObj.EMI_Amount__c = 4500;
            finalObj.OfferengineMinTenure__c = 67;
            finalObj.OfferengineMaxTenure__c = 100;
            finalObj.Tenure__c = '75';
            finalObj.PricingEngine_thresholdNetrr__c = 67899;
            finalObj.LtvEngine_Ltv__c = 567899;
            finalObj.Dealer_incentive_amount_sub_dealer__c = '300';
            finalObj.Holiday_period__c = '60';
            finalObj.Required_CRM_IRR__c = '1000';
            finalObj.Loan_Application__c = opfr1.Id;
            finalObj.Net_IRR__c = 100;
            insert finalObj;
            
            List<IND_InsuranceDetailsLWC_controller.InsuranceWrapper> InsuranceWrapperList = new List<IND_InsuranceDetailsLWC_controller.InsuranceWrapper>();
            IND_InsuranceDetailsLWC_controller.InsuranceWrapper wrapperObj = new IND_InsuranceDetailsLWC_controller.InsuranceWrapper();
            wrapperObj.isFunded = true;
            wrapperObj.premium = 1000.00;
            wrapperObj.selectedPlan = 'testselect';
            wrapperObj.selectedProduct = 'testprd';
            InsuranceWrapperList.add(wrapperObj);
            IND_InsuranceDetailsLWC_controller.GetFundingAvailabiltyRequestWrapper fr1 = new IND_InsuranceDetailsLWC_controller.GetFundingAvailabiltyRequestWrapper();
            fr1.loanApplicationId = opfr1.Id;
            fr1.insProductDetails = InsuranceWrapperList;
            
            IND_InsuranceDetailsLWC_controller.GetFundingAvailabiltyResponseWrapper fw1 = new IND_InsuranceDetailsLWC_controller.GetFundingAvailabiltyResponseWrapper();
            fw1.totalInsurancePayable = 20000;
            fw1.ltvWithInsurance = '100';
            fw1.ltvWithoutInsurance = '120';
            fw1.proposalLtv = 1000;
            fw1.totalPremiumFunded = 2000;
            fw1.responseStatus = true;
            
            Opportunity opfr2 = new Opportunity();
            opfr2.Id = fr1.loanApplicationId;
            //   opfr2.StageName = 'Qualification';
            //   opfr2.CloseDate = Date.newInstance(2021, 1, 11);
            //     opfr2.Name = 'testone';
            opfr2.Vehicle_Type__c = system.Label.new;
            opfr2.Funding_on_Ex_Showroom__c = true;
            opfr2.Ex_showroom_price__c = 300000.00;
            update opfr2;
            
            
            Test.startTest();
            IND_InsuranceDetailsLWC_controller.getFundingAvailibility(Json.serialize(fr1));
            IND_InsuranceDetailsLWC_controller.updateDetailsForD2C(fw1,opfr1.Id);

            Test.stopTest();
            
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void getFundingAvailibilityTest1(){
        try{
            Opportunity opfr1 = new Opportunity();
            opfr1.StageName = 'Qualification';
            opfr1.CloseDate = Date.newInstance(2021, 1, 11);
            opfr1.Name = 'testone';
            opfr1.StageName = 'Proposal';
            opfr1.Vehicle_Type__c = system.Label.new;
            opfr1.Funding_on_ORP__c = true;
            opfr1.On_Road_price__c = 290000.00;
            opfr1.Required_Loan_amount__c = 200000.00;
            insert opfr1;
            
            Vehicle_Detail__c vgd1 = new Vehicle_Detail__c();
            vgd1.Loan_Application__c = opfr1.Id;
            vgd1.Base_Price__c = 100000.00;
            vgd1.Ben_Code__c = 'testveh';
            insert vgd1; 
            
            Applicant__c apfr1 = new Applicant__c();
            apfr1.Opportunity__c = opfr1.Id;
            apfr1.Contact_number__c = '9743514830';
            apfr1.Applicant_Type__c = 'Borrower';
            insert apfr1; 
            Final_Term__c finalObj = new Final_Term__c();
            finalObj.Rreferrer_Incentive__c = '1000';
            finalObj.Loan_Amount__c = '41000';
            finalObj.OfferengineMinLoanAmount__c = 34534;
            finalObj.Dealer_incentive_amount_main_dealer__c = '567';
            finalObj.Trade_certificate__c = '34543';
            finalObj.Advance_EMI__c = true;
            finalObj.OfferengineMaxLoanAmount__c = 60000;
            finalObj.EMI_Amount__c = 4500;
            finalObj.OfferengineMinTenure__c = 67;
            finalObj.OfferengineMaxTenure__c = 100;
            finalObj.Tenure__c = '75';
            finalObj.PricingEngine_thresholdNetrr__c = 67899;
            finalObj.LtvEngine_Ltv__c = 567899;
            finalObj.Dealer_incentive_amount_sub_dealer__c = '300';
            finalObj.Holiday_period__c = '60';
            finalObj.Required_CRM_IRR__c = '1000';
            finalObj.Loan_Application__c = opfr1.Id;
            finalObj.Net_IRR__c = 100;
            insert finalObj;
            
            IND_InsuranceDetailsLWC_controller.InsuranceWrapper iw1 = new IND_InsuranceDetailsLWC_controller.InsuranceWrapper();
            iw1.isFunded = true;
            iw1.premium = 1000.00;
            iw1.selectedPlan = 'testselect';
            iw1.selectedProduct = 'testprd';
            
            List<IND_InsuranceDetailsLWC_controller.InsuranceWrapper> InsuranceWrapperList = new List<IND_InsuranceDetailsLWC_controller.InsuranceWrapper>();
            IND_InsuranceDetailsLWC_controller.InsuranceWrapper wrapperObj = new IND_InsuranceDetailsLWC_controller.InsuranceWrapper();
            wrapperObj.isFunded = true;
            wrapperObj.premium = 1000.00;
            wrapperObj.selectedPlan = 'testselect';
            wrapperObj.selectedProduct = 'testprd';
            InsuranceWrapperList.add(wrapperObj);
            IND_InsuranceDetailsLWC_controller.GetFundingAvailabiltyRequestWrapper fr1 = new IND_InsuranceDetailsLWC_controller.GetFundingAvailabiltyRequestWrapper();
            fr1.loanApplicationId = opfr1.Id;
            fr1.insProductDetails = InsuranceWrapperList;
            
            IND_InsuranceDetailsLWC_controller.GetFundingAvailabiltyResponseWrapper fw1 = new IND_InsuranceDetailsLWC_controller.GetFundingAvailabiltyResponseWrapper();
            fw1.totalInsurancePayable = 20000;
            fw1.ltvWithInsurance = 'sampleltv';
            fw1.ltvWithoutInsurance = 'sampwithout';
            fw1.proposalLtv = 1000;
            fw1.totalPremiumFunded = 2000;
            fw1.responseStatus = true;
            
            
            Test.startTest();
            IND_InsuranceDetailsLWC_controller.getFundingAvailibility(Json.serialize(fr1));
            Test.stopTest();
            
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void getFundingAvailibilityTest2(){
        try{
            Opportunity opfr1 = new Opportunity();
            opfr1.StageName = 'Qualification';
            opfr1.CloseDate = Date.newInstance(2021, 1, 11);
            opfr1.Name = 'testone';
            opfr1.StageName = 'Proposal';
            opfr1.Product_Type__c = 'Passenger Vehicles'; 
            opfr1.Vehicle_Type__c = System.Label.used;
            opfr1.Vehicle_Sub_Category__c = 'UOB';
            opfr1.Basic_Price__c = 200000.00;
            insert opfr1;
            
            Vehicle_Detail__c vgd1 = new Vehicle_Detail__c();
            vgd1.Loan_Application__c = opfr1.Id;
            vgd1.Base_Price__c = 100000.00;
            vgd1.Valuation_price__c = 300000.00;
            vgd1.Ben_Code__c = 'testveh';
            insert vgd1; 
            
            Applicant__c apfr1 = new Applicant__c();
            apfr1.Opportunity__c = opfr1.Id;
            apfr1.Contact_number__c = '9743514830';
            apfr1.Applicant_Type__c = 'Borrower';
            insert apfr1; 
            
            Final_Term__c finalObj = new Final_Term__c();
            finalObj.Rreferrer_Incentive__c = '1000';
            finalObj.Loan_Amount__c = '41000';
            finalObj.OfferengineMinLoanAmount__c = 34534;
            finalObj.Dealer_incentive_amount_main_dealer__c = '567';
            finalObj.Trade_certificate__c = '34543';
            finalObj.Advance_EMI__c = true;
            finalObj.OfferengineMaxLoanAmount__c = 60000;
            finalObj.EMI_Amount__c = 4500;
            finalObj.OfferengineMinTenure__c = 67;
            finalObj.OfferengineMaxTenure__c = 100;
            finalObj.Tenure__c = '75';
            finalObj.PricingEngine_thresholdNetrr__c = 67899;
            finalObj.LtvEngine_Ltv__c = 567899;
            finalObj.Dealer_incentive_amount_sub_dealer__c = '300';
            finalObj.Holiday_period__c = '60';
            finalObj.Required_CRM_IRR__c = '1000';
            finalObj.Loan_Application__c = opfr1.Id;
            finalObj.Net_IRR__c = 100;
            insert finalObj;
            
            IND_InsuranceDetailsLWC_controller.InsuranceWrapper iw1 = new IND_InsuranceDetailsLWC_controller.InsuranceWrapper();
            iw1.isFunded = true;
            iw1.premium = 1000.00;
            iw1.selectedPlan = 'testselect';
            iw1.selectedProduct = 'testprd';
            
            List<IND_InsuranceDetailsLWC_controller.InsuranceWrapper> InsuranceWrapperList = new List<IND_InsuranceDetailsLWC_controller.InsuranceWrapper>();
            IND_InsuranceDetailsLWC_controller.InsuranceWrapper wrapperObj = new IND_InsuranceDetailsLWC_controller.InsuranceWrapper();
            wrapperObj.isFunded = true;
            wrapperObj.premium = 1000.00;
            wrapperObj.selectedPlan = 'testselect';
            wrapperObj.selectedProduct = 'testprd';
            InsuranceWrapperList.add(wrapperObj);
            IND_InsuranceDetailsLWC_controller.GetFundingAvailabiltyRequestWrapper fr1 = new IND_InsuranceDetailsLWC_controller.GetFundingAvailabiltyRequestWrapper();
            fr1.loanApplicationId = opfr1.Id;
            fr1.insProductDetails = InsuranceWrapperList;
            
            IND_InsuranceDetailsLWC_controller.GetFundingAvailabiltyResponseWrapper fw1 = new IND_InsuranceDetailsLWC_controller.GetFundingAvailabiltyResponseWrapper();
            fw1.totalInsurancePayable = 20000;
            fw1.ltvWithInsurance = 'sampleltv';
            fw1.ltvWithoutInsurance = 'sampwithout';
            fw1.proposalLtv = 1000;
            fw1.totalPremiumFunded = 2000;
            fw1.responseStatus = true;
            
            
            Test.startTest();
            IND_InsuranceDetailsLWC_controller.getFundingAvailibility(Json.serialize(fr1));
            Test.stopTest();
            
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void getFundingAvailibilityTest3(){
        try{
            Opportunity opfr1 = new Opportunity();
            opfr1.StageName = 'Qualification';
            opfr1.CloseDate = Date.newInstance(2021, 1, 11);
            opfr1.Name = 'testone';
            opfr1.StageName = 'Proposal';
            opfr1.Vehicle_Type__c = System.Label.used;
            opfr1.Vehicle_Sub_Category__c = 'UIM';
            opfr1.Required_Loan_amount__c = 200000.00;
            insert opfr1;
            
            Vehicle_Detail__c vgd1 = new Vehicle_Detail__c();
            vgd1.Loan_Application__c = opfr1.Id;
            vgd1.Base_Price__c = 100000.00;
            vgd1.Ben_Code__c = 'testveh';
            vgd1.Eligible_Loan_Amount__c = 10000000.00;
            insert vgd1; 
            
            Applicant__c apfr1 = new Applicant__c();
            apfr1.Opportunity__c = opfr1.Id;
            apfr1.Contact_number__c = '9743514830';
            apfr1.Applicant_Type__c = 'Borrower';
            insert apfr1; 
            
            Final_Term__c finalObj = new Final_Term__c();
            finalObj.Rreferrer_Incentive__c = '1000';
            finalObj.Loan_Amount__c = '41000';
            finalObj.OfferengineMinLoanAmount__c = 34534;
            finalObj.Dealer_incentive_amount_main_dealer__c = '567';
            finalObj.Trade_certificate__c = '34543';
            finalObj.Advance_EMI__c = true;
            finalObj.OfferengineMaxLoanAmount__c = 60000;
            finalObj.EMI_Amount__c = 4500;
            finalObj.OfferengineMinTenure__c = 67;
            finalObj.OfferengineMaxTenure__c = 100;
            finalObj.Tenure__c = '75';
            finalObj.PricingEngine_thresholdNetrr__c = 67899;
            finalObj.LtvEngine_Ltv__c = 567899;
            finalObj.Dealer_incentive_amount_sub_dealer__c = '300';
            finalObj.Holiday_period__c = '60';
            finalObj.Required_CRM_IRR__c = '1000';
            finalObj.Loan_Application__c = opfr1.Id;
            finalObj.Net_IRR__c = 100;
            insert finalObj;
            
            IND_InsuranceDetailsLWC_controller.InsuranceWrapper iw1 = new IND_InsuranceDetailsLWC_controller.InsuranceWrapper();
            iw1.isFunded = true;
            iw1.premium = 1000.00;
            iw1.selectedPlan = 'testselect';
            iw1.selectedProduct = 'testprd';
            
            List<IND_InsuranceDetailsLWC_controller.InsuranceWrapper> InsuranceWrapperList = new List<IND_InsuranceDetailsLWC_controller.InsuranceWrapper>();
            IND_InsuranceDetailsLWC_controller.InsuranceWrapper wrapperObj = new IND_InsuranceDetailsLWC_controller.InsuranceWrapper();
            wrapperObj.isFunded = true;
            wrapperObj.premium = 1000.00;
            wrapperObj.selectedPlan = 'testselect';
            wrapperObj.selectedProduct = 'testprd';
            InsuranceWrapperList.add(wrapperObj);
            IND_InsuranceDetailsLWC_controller.GetFundingAvailabiltyRequestWrapper fr1 = new IND_InsuranceDetailsLWC_controller.GetFundingAvailabiltyRequestWrapper();
            fr1.loanApplicationId = opfr1.Id;
            fr1.insProductDetails = InsuranceWrapperList;
            
            IND_InsuranceDetailsLWC_controller.GetFundingAvailabiltyResponseWrapper fw1 = new IND_InsuranceDetailsLWC_controller.GetFundingAvailabiltyResponseWrapper();
            fw1.totalInsurancePayable = 20000;
            fw1.ltvWithInsurance = 'sampleltv';
            fw1.ltvWithoutInsurance = 'sampwithout';
            fw1.proposalLtv = 1000;
            fw1.totalPremiumFunded = 2000;
            fw1.responseStatus = true;
            
            
            Test.startTest();
            IND_InsuranceDetailsLWC_controller.getFundingAvailibility(Json.serialize(fr1));
            Test.stopTest();
            
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void getCurrentSubStageTest(){
        try{
            Opportunity opg1 = TestDataUtility.createTestOpportunity(false);
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opg1;
            }
            
            Test.startTest();
            IND_InsuranceDetailsLWC_controller.getCurrentSubStage(opg1.Id);
            IND_InsuranceDetailsLWC_controller.getCurrentSubStage(null);
            IND_InsuranceDetailsLWC_controller.getCurrentSubStage('test');
            Test.stopTest();
        }
        catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void getmotorfromoppTest(){
        try{
            Opportunity opg1 = TestDataUtility.createTestOpportunity(false);
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opg1;
            }
            
            Test.startTest();
            IND_InsuranceDetailsLWC_controller.getmotorfromopp(opg1.Id);
            IND_InsuranceDetailsLWC_controller.getmotorfromopp(null);
            IND_InsuranceDetailsLWC_controller.getmotorfromopp('test');
            Test.stopTest();
            
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void getInsuranceConsentCheckboxValueTest(){
        Opportunity opp = TestDataUtility.createTestOpportunity(false);
        if (Schema.sObjectType.Opportunity.isCreateable()){
            insert opp;
        }
        
        Applicant__c app1 = TestDataUtility.createTestApplicantForSMS(false);
        app1.Opportunity__c = opp.Id;
        app1.Applicant_Type__c = 'Co-borrower';
        if (Schema.sObjectType.Applicant__c.isCreateable()){
            insert app1;
        }
        
        Test.startTest();
        IND_InsuranceDetailsLWC_controller.getInsuranceConsentCheckboxValue(opp.Id,app1.Applicant_Type__c);
        Test.stopTest();
    }
    
    @isTest
    public static void updateInsuranceConsentReceivedTest(){
        try{
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            
            Applicant__c app1 = TestDataUtility.createTestApplicantForSMS(false);
            app1.Opportunity__c = opp.Id;
            app1.Applicant_Type__c = 'Co-borrower';
            app1.Consent_Received__c = true;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert app1;
            }
            
            Test.startTest();
            IND_InsuranceDetailsLWC_controller.updateInsuranceConsentReceived(app1.Consent_Received__c,opp.Id,app1.Applicant_Type__c);
            IND_InsuranceDetailsLWC_controller.updateInsuranceConsentReceived(true,'test',app1.Applicant_Type__c);
            IND_InsuranceDetailsLWC_controller.updateInsuranceConsentReceived(null,null,null);
            Test.stopTest();
            
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void getProductTypeFromOppTest(){
        Opportunity opp = TestDataUtility.createTestOpportunity(false);
        if (Schema.sObjectType.Opportunity.isCreateable()){
            insert opp;
        }
        
        Test.startTest();
        IND_InsuranceDetailsLWC_controller.getProductTypeFromOpp(opp.Id);
        Test.stopTest();
    }
    
    @isTest
    public static void fetchInsuranceRecordsTest(){
        Opportunity opp = TestDataUtility.createTestOpportunity(false);
        if (Schema.sObjectType.Opportunity.isCreateable()){
            insert opp;
        }
        
        Applicant__c app1 = TestDataUtility.createTestApplicantForSMS(false);
        app1.Opportunity__c = opp.Id;
        app1.Applicant_Type__c = 'Co-borrower';
        if (Schema.sObjectType.Applicant__c.isCreateable()){
            insert app1;
        }
        
        InsuranceDetails__c id1 = new InsuranceDetails__c();
        id1.Applicant__c = app1.Id;
        id1.Loan_Application__c = opp.Id;
        id1.Name = 'Insurance';
        insert id1;
        
        Test.startTest();
        //    IND_InsuranceDetailsLWC_controller.fetchInsuranceRecords(opp.Id);
        Test.stopTest();
    }
    
    @isTest
    public static void updateInsuranceConsentTest(){
        try{
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            
            Applicant__c app1 = TestDataUtility.createTestApplicantForSMS(false);
            app1.Opportunity__c = opp.Id;
            app1.Applicant_Type__c = 'Co-borrower';
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert app1;
            }
            
            Test.startTest();
            IND_InsuranceDetailsLWC_controller.updateInsuranceConsent(app1.Id,'LAS');
            IND_InsuranceDetailsLWC_controller.updateInsuranceConsent(app1.Id,'INC');
            IND_InsuranceDetailsLWC_controller.updateInsuranceConsent(null,'INC');
            IND_InsuranceDetailsLWC_controller.updateInsuranceConsent('test','test');
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void checkRetryExhaustedTest(){
        try{
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            
            Applicant__c app1 = TestDataUtility.createTestApplicantForSMS(false);
            app1.Opportunity__c = opp.Id;
            app1.Applicant_Type__c = 'Co-borrower';
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert app1;
            }
            
            Test.startTest();
            IND_InsuranceDetailsLWC_controller.checkRetryExhausted(opp.Id,'test',app1.Id);
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void checkRetryExhaustedTest1(){
        try{
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            
            Applicant__c app1 = TestDataUtility.createTestApplicantForSMS(false);
            app1.Opportunity__c = opp.Id;
            app1.Applicant_Type__c = 'Co-borrower';
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert app1;
            }
            
            Retry_Count__c rce1 = new Retry_Count__c();
            rce1.Loan_Application_Id__c = opp.Id;
            rce1.Service_Name__c = 'FinalTermApi';
            rce1.User_Id__c = UserInfo.getUserId();
            rce1.Applicant__c = app1.Id;
            rce1.Count__c = 1;
            insert rce1;
            
            Test.startTest();
            IND_InsuranceDetailsLWC_controller.checkRetryExhausted(opp.Id,rce1.Service_Name__c,app1.Id);
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void checkRetryExhaustedTest2(){
        try{
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            
            Applicant__c app1 = TestDataUtility.createTestApplicantForSMS(false);
            app1.Opportunity__c = opp.Id;
            app1.Applicant_Type__c = 'Co-borrower';
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert app1;
            }
            
            Retry_Count__c rce1 = new Retry_Count__c();
            rce1.Loan_Application_Id__c = opp.Id;
            rce1.Service_Name__c = 'FinalTermApi';
            rce1.User_Id__c = UserInfo.getUserId();
            rce1.Applicant__c = app1.Id;
            rce1.Count__c = 5;
            insert rce1;
            
            Test.startTest();
            IND_InsuranceDetailsLWC_controller.checkRetryExhausted(opp.Id,rce1.Service_Name__c,app1.Id);
            IND_InsuranceDetailsLWC_controller.checkRetryExhausted(null,null,'test');
            IND_InsuranceDetailsLWC_controller.checkRetryExhausted('test','test','test');
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void deleteExistingPlansTest(){
        try{
            Opportunity opec1 = new Opportunity();
            opec1.StageName = 'Qualification';
            opec1.CloseDate = Date.newInstance(2021, 1, 11);
            opec1.Name = 'testone';
            insert opec1;
            
            Applicant__c apec1 = new Applicant__c();
            apec1.Opportunity__c = opec1.Id;
            apec1.Contact_number__c = '9743514830';
            apec1.Applicant_Type__c = 'Borrower';
            insert apec1;
            
            InsuranceDetails__c insuDetail = new InsuranceDetails__c();
            insuDetail.Applicant__c = apec1.Id;
            insuDetail.Funded_Premium__c=400.00;
            insuDetail.Loan_Application__c = opec1.id;
            insuDetail.Name = 'MOTOR';
            insert insuDetail;
            
            Test.startTest();
            IND_InsuranceDetailsLWC_controller.deleteExistingPlans(opec1.id,apec1.Id);
            IND_InsuranceDetailsLWC_controller.deleteExistingPlans(null,null);
            IND_InsuranceDetailsLWC_controller.deleteExistingPlans('test','test');
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    @isTest
    public static void fetchOppourtunityDataTest1(){
        try{
            Opportunity opec1 = new Opportunity();
            opec1.StageName = 'Qualification';
            opec1.CloseDate = Date.newInstance(2021, 1, 11);
            opec1.Name = 'testone';
            insert opec1;
            
            Test.startTest();
            IND_InsuranceDetailsLWC_controller.fetchOppourtunityData(opec1.Id);
            IND_InsuranceDetailsLWC_controller.fetchOppourtunityData('test');
            IND_InsuranceDetailsLWC_controller.fetchOppourtunityData(null);
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    @isTest
    public static void checkInsuranseExpWith60DaysTest(){
        try{
            Opportunity opec1 = new Opportunity();
            opec1.StageName = 'Qualification';
            opec1.CloseDate = Date.newInstance(2021, 1, 11);
            opec1.Name = 'testone';
            insert opec1;
            
            Vehicle_Detail__c vgd1 = new Vehicle_Detail__c();
            vgd1.Loan_Application__c = opec1.Id;
            vgd1.Base_Price__c = 100000.00;
            vgd1.Ben_Code__c = 'testveh';
            vgd1.Insurance_expiring_within_60_days__c = true;
            insert vgd1; 
            
            Test.startTest();
            IND_InsuranceDetailsLWC_controller.checkInsuranseExpWith60Days(opec1.id);
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void checkInsuranseExpWith60DaysTest1(){
        try{
            Opportunity opec1 = new Opportunity();
            opec1.StageName = 'Qualification';
            opec1.CloseDate = Date.newInstance(2021, 1, 11);
            opec1.Name = 'testone';
            insert opec1;
            
            Test.startTest();
            IND_InsuranceDetailsLWC_controller.checkInsuranseExpWith60Days(opec1.id);
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    //Ashay
    @isTest
    public static void deleteExistingPlansTfTest(){
        Opportunity opp = TestDataUtility.createTestOpportunity(false);
        if (Schema.sObjectType.Opportunity.isCreateable()){
            insert opp;
        }
        
        Applicant__c app1 = TestDataUtility.createTestApplicantForSMS(false);
        app1.Opportunity__c = opp.Id;
        app1.Applicant_Type__c = 'Co-borrower';
        if (Schema.sObjectType.Applicant__c.isCreateable()){
            insert app1;
        }
        
        Vehicle_Detail__c vgd1 = new Vehicle_Detail__c();
        vgd1.Loan_Application__c = opp.Id;
        vgd1.Base_Price__c = 100000.00;
        vgd1.Ben_Code__c = 'testveh';
        vgd1.Insurance_expiring_within_60_days__c = false;
        insert vgd1; 
        
        InsuranceDetails__c id1 = new InsuranceDetails__c();
        id1.Applicant__c = app1.Id;
        id1.Loan_Application__c = opp.Id;
        id1.Name = 'Insurance';
        insert id1;
        
        Test.startTest();
        try {
            IND_InsuranceDetailsLWC_controller.deleteExistingPlansTf(opp.Id,vgd1.Id,true);
            IND_InsuranceDetailsLWC_controller.deleteExistingPlansTf(null,null,false);
            IND_InsuranceDetailsLWC_controller.deleteExistingPlansTf('test','test',false);
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
        Test.stopTest();
        
    }
    //Ashay
    @isTest
    public static void isApplicantInsuranceApplicableTest(){
        Opportunity opp = new Opportunity();
        opp.StageName = 'Qualification';
        opp.CloseDate = Date.newInstance(2021, 1, 11);
        opp.Name = 'testone';
        opp.Customer_Type__c ='Individual';
        insert opp;
        
        Applicant__c app1 = TestDataUtility.createTestApplicantForSMS(false);
        app1.Opportunity__c = opp.Id;
        app1.Applicant_Type__c = 'Co-borrower';
        if (Schema.sObjectType.Applicant__c.isCreateable()){
            insert app1;
        }
        
        Vehicle_Detail__c vgd1 = new Vehicle_Detail__c();
        vgd1.Loan_Application__c = opp.Id;
        vgd1.Base_Price__c = 100000.00;
        vgd1.Ben_Code__c = 'testveh';
        vgd1.Insurance_expiring_within_60_days__c = false;
        insert vgd1; 
        
        InsuranceDetails__c id1 = new InsuranceDetails__c();
        id1.Applicant__c = app1.Id;
        id1.Loan_Application__c = opp.Id;
        id1.Name = 'Insurance';
        insert id1;
        
        Test.startTest();
        IND_InsuranceDetailsLWC_controller.isApplicantInsuranceApplicable(opp.Id,vgd1.Id);
        IND_InsuranceDetailsLWC_controller.isApplicantInsuranceApplicable(null,null);
        IND_InsuranceDetailsLWC_controller.isApplicantInsuranceApplicable('test','test');
        Test.stopTest();
        
    }
    //Ashay
    @isTest
    public static void getAssetTabListTest(){
        Opportunity opp = new Opportunity();
        opp.StageName = 'Qualification';
        opp.CloseDate = Date.newInstance(2021, 1, 11);
        opp.Name = 'testone';
        opp.Customer_Type__c ='Individual';
        insert opp;
        
        Vehicle_Detail__c vgd1 = new Vehicle_Detail__c();
        vgd1.Loan_Application__c = opp.Id;
        vgd1.Base_Price__c = 100000.00;
        vgd1.Ben_Code__c = 'testveh';
        vgd1.Insurance_expiring_within_60_days__c = false;
        vgd1.Variant__c  = 'M&M KUV100 NXT K8 DIESEL';
        
        insert vgd1; 
        
        Test.startTest();
        IND_InsuranceDetailsLWC_controller.getAssetTabList(opp.Id);
        IND_InsuranceDetailsLWC_controller.getAssetTabList(null);
        IND_InsuranceDetailsLWC_controller.getAssetTabList('test');
        Test.stopTest();
        
    }
    //Ashay
    @isTest
    public static void getEligibleApplicantTabListTest1(){
        
        Opportunity opec1 = new Opportunity();
        opec1.StageName = 'Qualification';
        opec1.CloseDate = Date.newInstance(2021, 1, 11);
        opec1.Name = 'testone';
        insert opec1;
        
        Applicant__c apec1 = new Applicant__c();
        apec1.Opportunity__c = opec1.Id;
        apec1.Contact_number__c = '9743514830';
        apec1.Applicant_Type__c = 'Borrower';
        apec1.Insurance_Consent_Received__c = True;
        insert apec1;
        
        Test.startTest();
        IND_InsuranceDetailsLWC_controller.getEligibleApplicantTabList(opec1.Id);
        Test.stopTest();
    }
    //Ashay
    @isTest
    public static void getEligibleApplicantTabListTest2(){
        
        Opportunity opec1 = new Opportunity();
        opec1.StageName = 'Qualification';
        opec1.CloseDate = Date.newInstance(2021, 1, 11);
        opec1.Name = 'testone';
        insert opec1;
        
        Applicant__c apec1 = new Applicant__c();
        apec1.Opportunity__c = opec1.Id;
        apec1.Contact_number__c = '9743514830';
        apec1.Applicant_Type__c = System.Label.CoBorrower;
        apec1.Insurance_Consent_Received__c = True;
        apec1.IsPrimary__c = true;
        apec1.Relationship_with_borrower__c ='MATERNAL GRANDMOTHER';
        insert apec1;
        
        Test.startTest();
        IND_InsuranceDetailsLWC_controller.getEligibleApplicantTabList(opec1.Id);
        Test.stopTest();
    }
    //Ashay
    @isTest
    public static void finalSubmitTFInsuranceDetailsTest1(){
        try{
            Opportunity opid1 = new Opportunity();
            opid1.StageName = 'Qualification';
            opid1.CloseDate = Date.newInstance(2021, 1, 11);
            opid1.Name = 'testone';
            
            insert opid1;
            
            Applicant__c apid1 = new Applicant__c();
            apid1.Opportunity__c = opid1.Id;
            apid1.Contact_number__c = '9743514830';
            apid1.Applicant_Type__c = 'Borrower';
            apid1.In_Active_Applicant__c = false;
            insert apid1; 
           
            List<IND_InsuranceDetailsLWC_controller.InsuranceWrapper> InsuranceWrapperList = new List<IND_InsuranceDetailsLWC_controller.InsuranceWrapper>();
            IND_InsuranceDetailsLWC_controller.InsuranceWrapper wrapperObj = new IND_InsuranceDetailsLWC_controller.InsuranceWrapper();
            wrapperObj.isFunded = true;
            wrapperObj.premium = 1000.00;
            wrapperObj.selectedPlan = 'testselect';
            wrapperObj.selectedProduct = 'testprd';
            InsuranceWrapperList.add(wrapperObj);
            
            IND_InsuranceDetailsLWC_controller.InsuranceWrapper iw = new IND_InsuranceDetailsLWC_controller.InsuranceWrapper();
            iw.isFunded = false;
            iw.premium = 1000.00;
            iw.selectedPlan = 'LI_EMI';
            iw.selectedProduct = 'LI_EMI';
            iw.comboLIPremium = 516.00;
            iw.comboEMIPremium = 4231.00;
            iw.eMIPassedinAPI = 516.00;
            InsuranceWrapperList.add(iw);
            
            Vehicle_Detail__c vgd1 = new Vehicle_Detail__c();
            vgd1.Loan_Application__c = opid1.Id;
            vgd1.Base_Price__c = 100000.00;
            vgd1.Ben_Code__c = 'testveh';
            vgd1.Insurance_expiring_within_60_days__c = false;
            vgd1.Variant__c  = 'M&M KUV100 NXT K8 DIESEL';
            insert vgd1; 
            
            IND_InsuranceDetailsLWC_controller.SubmitInsuranceRequestWrapper sr1 = new IND_InsuranceDetailsLWC_controller.SubmitInsuranceRequestWrapper();
            sr1.applicantId = apid1.Id;
            sr1.loanApplicationId = opid1.Id;
            sr1.ltvWithInsurance = 500;
            sr1.ltvWithoutInsurance = 500;
            sr1.totalInsurancePayable = 100.00;
            sr1.proposalLtv = 200.00;
            sr1.insProductDetails = InsuranceWrapperList;
            sr1.nextStage = 'Needs Analysis';
            sr1.premiumFunded = 500;
            sr1.submittedTabs = 'L1 - Borrower Insurance';
            sr1.assetId = vgd1.Id;
            sr1.journeyOfLead = 'L1';
                
            Applicant__c apid2 = new Applicant__c();
            apid2.Opportunity__c = sr1.loanApplicationId;
            apid2.Contact_number__c = '9743514830';
            apid2.Applicant_Type__c = 'Borrower';
            apid2.In_Active_Applicant__c = false;
            apid2.LTV_without_insurance__c = sr1.ltvWithoutInsurance;
            insert apid2; 
            
            InsuranceDetails__c isd1 = new InsuranceDetails__c();
            isd1.Loan_Application__c = sr1.loanApplicationId;
            isd1.Applicant__c = sr1.applicantId;
            isd1.Name = 'TEST';
            insert isd1;
            
            Test.startTest();
            IND_InsuranceDetailsLWC_controller.finalSubmitTFInsuranceDetails(Json.serialize(sr1));
            IND_InsuranceDetailsLWC_controller.finalSubmitTFInsuranceDetails(null);
            IND_InsuranceDetailsLWC_controller.submitTFInsuranceDetails(Json.serialize(sr1));

            Test.stopTest();
            
            
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }   
    //Ashay
    @isTest
    public static void finalSubmitTFInsuranceDetailsTest2(){
        try{
            Opportunity opid1 = new Opportunity();
            opid1.StageName = 'Qualification';
            opid1.CloseDate = Date.newInstance(2021, 1, 11);
            opid1.Name = 'testone';
            
            insert opid1;
            
            Applicant__c apid1 = new Applicant__c();
            apid1.Opportunity__c = opid1.Id;
            apid1.Contact_number__c = '9743514830';
            apid1.Applicant_Type__c = 'Borrower';
            apid1.In_Active_Applicant__c = false;
            insert apid1; 
           
            List<IND_InsuranceDetailsLWC_controller.InsuranceWrapper> InsuranceWrapperList = new List<IND_InsuranceDetailsLWC_controller.InsuranceWrapper>();
            IND_InsuranceDetailsLWC_controller.InsuranceWrapper wrapperObj = new IND_InsuranceDetailsLWC_controller.InsuranceWrapper();
            wrapperObj.isFunded = true;
            wrapperObj.premium = 1000.00;
            wrapperObj.selectedPlan = 'testselect';
            wrapperObj.selectedProduct = 'testprd';
            InsuranceWrapperList.add(wrapperObj);
            
            IND_InsuranceDetailsLWC_controller.InsuranceWrapper iw = new IND_InsuranceDetailsLWC_controller.InsuranceWrapper();
            iw.isFunded = false;
            iw.premium = 1000.00;
            iw.selectedPlan = 'LI_EMI';
            iw.selectedProduct = 'LI_EMI';
            iw.comboLIPremium = 516.00;
            iw.comboEMIPremium = 4231.00;
            iw.eMIPassedinAPI = 516.00;
            InsuranceWrapperList.add(iw);
            
            Vehicle_Detail__c vgd1 = new Vehicle_Detail__c();
            vgd1.Loan_Application__c = opid1.Id;
            vgd1.Base_Price__c = 100000.00;
            vgd1.Ben_Code__c = 'testveh';
            vgd1.Insurance_expiring_within_60_days__c = false;
            vgd1.Variant__c  = 'M&M KUV100 NXT K8 DIESEL';
            insert vgd1; 
            
            IND_InsuranceDetailsLWC_controller.SubmitInsuranceRequestWrapper sr1 = new IND_InsuranceDetailsLWC_controller.SubmitInsuranceRequestWrapper();
            sr1.applicantId = apid1.Id;
            sr1.loanApplicationId = opid1.Id;
            sr1.ltvWithInsurance = 500;
            sr1.ltvWithoutInsurance = 500;
            sr1.totalInsurancePayable = 100.00;
            sr1.proposalLtv = 200.00;
            sr1.insProductDetails = InsuranceWrapperList;
            sr1.nextStage = 'Needs Analysis';
            sr1.premiumFunded = 500;
            sr1.submittedTabs = 'L1 - Borrower Insurance';
            sr1.assetId = vgd1.Id;
            sr1.journeyOfLead = 'L2';
                
            Applicant__c apid2 = new Applicant__c();
            apid2.Opportunity__c = sr1.loanApplicationId;
            apid2.Contact_number__c = '9743514830';
            apid2.Applicant_Type__c = 'Borrower';
            apid2.In_Active_Applicant__c = false;
            apid2.LTV_without_insurance__c = sr1.ltvWithoutInsurance;
            insert apid2; 
            
            InsuranceDetails__c isd1 = new InsuranceDetails__c();
            isd1.Loan_Application__c = sr1.loanApplicationId;
            isd1.Applicant__c = sr1.applicantId;
            isd1.Name = 'TEST';
            insert isd1;
            
            Test.startTest();
            IND_InsuranceDetailsLWC_controller.finalSubmitTFInsuranceDetails(Json.serialize(sr1));
            IND_InsuranceDetailsLWC_controller.finalSubmitTFInsuranceDetails(null);
            IND_InsuranceDetailsLWC_controller.submitTFInsuranceDetails(Json.serialize(sr1));
            
            Test.stopTest();
            
            
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }   
    //Ashay
    @isTest
    public static void finalSubmitTFInsuranceDetailsTest3(){
        try{
            Opportunity opid1 = new Opportunity();
            opid1.StageName = System.Label.Credit_Processing;
            opid1.CloseDate = Date.newInstance(2021, 1, 11);
            opid1.Name = 'testone';
            
            insert opid1;
            
            Applicant__c apid1 = new Applicant__c();
            apid1.Opportunity__c = opid1.Id;
            apid1.Contact_number__c = '9743514830';
            apid1.Applicant_Type__c = 'Borrower';
            apid1.In_Active_Applicant__c = false;
            insert apid1; 
           
            List<IND_InsuranceDetailsLWC_controller.InsuranceWrapper> InsuranceWrapperList = new List<IND_InsuranceDetailsLWC_controller.InsuranceWrapper>();
            IND_InsuranceDetailsLWC_controller.InsuranceWrapper wrapperObj = new IND_InsuranceDetailsLWC_controller.InsuranceWrapper();
            wrapperObj.isFunded = true;
            wrapperObj.premium = 1000.00;
            wrapperObj.selectedPlan = 'testselect';
            wrapperObj.selectedProduct = 'testprd';
            InsuranceWrapperList.add(wrapperObj);
            
            IND_InsuranceDetailsLWC_controller.InsuranceWrapper iw = new IND_InsuranceDetailsLWC_controller.InsuranceWrapper();
            iw.isFunded = false;
            iw.premium = 1000.00;
            iw.selectedPlan = 'LI_EMI';
            iw.selectedProduct = 'LI_EMI';
            iw.comboLIPremium = 516.00;
            iw.comboEMIPremium = 4231.00;
            iw.eMIPassedinAPI = 516.00;
            InsuranceWrapperList.add(iw);
            
            Vehicle_Detail__c vgd1 = new Vehicle_Detail__c();
            vgd1.Loan_Application__c = opid1.Id;
            vgd1.Base_Price__c = 100000.00;
            vgd1.Ben_Code__c = 'testveh';
            vgd1.Insurance_expiring_within_60_days__c = false;
            vgd1.Variant__c  = 'M&M KUV100 NXT K8 DIESEL';
            insert vgd1; 
            
            IND_InsuranceDetailsLWC_controller.SubmitInsuranceRequestWrapper sr1 = new IND_InsuranceDetailsLWC_controller.SubmitInsuranceRequestWrapper();
            sr1.applicantId = apid1.Id;
            sr1.loanApplicationId = opid1.Id;
            sr1.ltvWithInsurance = 500;
            sr1.ltvWithoutInsurance = 500;
            sr1.totalInsurancePayable = 100.00;
            sr1.proposalLtv = 200.00;
            sr1.insProductDetails = InsuranceWrapperList;
            sr1.nextStage = 'Needs Analysis';
            sr1.premiumFunded = 500;
            sr1.submittedTabs = 'L1 - Borrower Insurance';
            sr1.assetId = vgd1.Id;
            sr1.journeyOfLead = 'L2';
                
            Applicant__c apid2 = new Applicant__c();
            apid2.Opportunity__c = sr1.loanApplicationId;
            apid2.Contact_number__c = '9743514830';
            apid2.Applicant_Type__c = 'Borrower';
            apid2.In_Active_Applicant__c = false;
            apid2.LTV_without_insurance__c = sr1.ltvWithoutInsurance;
            insert apid2; 
            
            InsuranceDetails__c isd1 = new InsuranceDetails__c();
            isd1.Loan_Application__c = sr1.loanApplicationId;
            isd1.Applicant__c = sr1.applicantId;
            isd1.Name = 'TEST';
            insert isd1;
            
            Test.startTest();
            IND_InsuranceDetailsLWC_controller.finalSubmitTFInsuranceDetails(Json.serialize(sr1));
            IND_InsuranceDetailsLWC_controller.finalSubmitTFInsuranceDetails(null);
            IND_InsuranceDetailsLWC_controller.submitTFInsuranceDetails(Json.serialize(sr1));
            
            Test.stopTest();
            
            
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }   
    //Ashay
    @isTest
    public static void existTFInsuranceDetailsMethodTest(){
        try{
            
            Opportunity opid1 = new Opportunity();
            opid1.StageName = System.Label.Credit_Processing;
            opid1.CloseDate = Date.newInstance(2021, 1, 11);
            opid1.Name = 'testone';
            insert opid1;
            
            Applicant__c apid1 = new Applicant__c();
            apid1.Opportunity__c = opid1.Id;
            apid1.Contact_number__c = '9743514830';
            apid1.Applicant_Type__c = 'Borrower';
            apid1.In_Active_Applicant__c = false;
            insert apid1; 
           
            
            Vehicle_Detail__c vgd1 = new Vehicle_Detail__c();
            vgd1.Loan_Application__c = opid1.Id;
            vgd1.Base_Price__c = 100000.00;
            vgd1.Ben_Code__c = 'testveh';
            vgd1.Insurance_expiring_within_60_days__c = false;
            vgd1.Variant__c  = 'M&M KUV100 NXT K8 DIESEL';
            insert vgd1; 

            InsuranceDetails__c isd1 = new InsuranceDetails__c();
            isd1.Loan_Application__c = opid1.Id;
            isd1.Applicant__c = apid1.Id;
            isd1.Name = 'TEST';
            isd1.Vehicle_Detail__c=vgd1.Id;
            insert isd1;
            
            Test.startTest();
            IND_InsuranceDetailsLWC_controller.existTFInsuranceDetailsMethod(opid1.Id,apid1.Id,vgd1.Id);
            IND_InsuranceDetailsLWC_controller.existTFInsuranceDetailsMethod(null,null,null);            
            Test.stopTest();
            
            
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    //Ashay
    @isTest
    public static void getMotorInsuranceFromLoanDetailsTfTest(){
        
        Opportunity opdf1 = new Opportunity();
        opdf1.StageName = 'Qualification';
        opdf1.CloseDate = Date.newInstance(2021, 1, 11);
        opdf1.Name = 'testone';
        insert opdf1;
        
        Vehicle_Detail__c vgd1 = new Vehicle_Detail__c();
        vgd1.Loan_Application__c = opdf1.Id;
        vgd1.Base_Price__c = 100000.00;
        vgd1.Ben_Code__c = 'testveh';
        vgd1.Is_Customer_Interested_in_MotorInsurance__c = true;
        insert vgd1; 
        
        Test.startTest();
        IND_InsuranceDetailsLWC_controller.getMotorInsuranceFromLoanDetailsTf(opdf1.Id,vgd1.Id);
        Test.stopTest();
    }
     //Ashay
    @isTest
    public static void getMotorInsuranceFromLoanDetailsTfTestElsePart(){
        
        Opportunity opdf1 = new Opportunity();
        opdf1.StageName = 'Qualification';
        opdf1.CloseDate = Date.newInstance(2021, 1, 11);
        opdf1.Name = 'testone';
        insert opdf1;
        
        Vehicle_Detail__c vgd1 = new Vehicle_Detail__c();
        vgd1.Loan_Application__c = opdf1.Id;
        vgd1.Base_Price__c = 100000.00;
        vgd1.Ben_Code__c = 'testveh';
        vgd1.Is_Customer_Interested_in_MotorInsurance__c = false;
        insert vgd1; 
        
        Test.startTest();
        IND_InsuranceDetailsLWC_controller.getMotorInsuranceFromLoanDetailsTf(opdf1.Id,vgd1.Id);
        Test.stopTest();
    }
    //Ashay
    @isTest
    public static void fetchApplicantsTest1(){
        Opportunity opp = new Opportunity();
        opp.StageName = 'Qualification';
        opp.CloseDate = Date.newInstance(2021, 1, 11);
        opp.Name = 'testone';
        opp.Customer_Type__c ='Individual';
        opp.Entity_Type__c = 'Proprietorship';
        opp.Product_Type__c = Label.Tractor;
        insert opp;
        
        
        Applicant__c apid1 = new Applicant__c();
        apid1.Opportunity__c = opp.Id;
        apid1.Contact_number__c = '9743514830';
        apid1.Applicant_Type__c = 'Borrower';
        apid1.In_Active_Applicant__c = false;
        apid1.Application_Consent_Received__c = false;
        insert apid1; 
        
        Test.startTest();
        IND_InsuranceDetailsLWC_controller.fetchApplicants(opp.Id);
        Test.stopTest();
        
    }
    //Ashay
    @isTest
    public static void fetchApplicantsTest2(){
        Opportunity opp = new Opportunity();
        opp.StageName = 'Qualification';
        opp.CloseDate = Date.newInstance(2021, 1, 11);
        opp.Name = 'testone';
        opp.Customer_Type__c ='Non-Individual';
        opp.Entity_Type__c = 'Proprietorship';
        opp.Product_Type__c = Label.Tractor;
        insert opp;
        
        
        Applicant__c apid1 = new Applicant__c();
        apid1.Opportunity__c = opp.Id;
        apid1.Contact_number__c = '9743514830';
        apid1.Applicant_Type__c = 'Borrower';
        apid1.In_Active_Applicant__c = false;
        apid1.Application_Consent_Received__c = false;
        insert apid1; 
        
        Test.startTest();
        IND_InsuranceDetailsLWC_controller.fetchApplicants(opp.Id);
        Test.stopTest();
    }
    //Ashay
    @isTest
    public static void fetchApplicantsTest3(){
        Opportunity opp = new Opportunity();
        opp.StageName = 'Qualification';
        opp.CloseDate = Date.newInstance(2021, 1, 11);
        opp.Name = 'testone';
        opp.Customer_Type__c ='Non-Individual';
        opp.Product_Type__c = Label.Tractor;
        insert opp;
        
        
        Applicant__c apid1 = new Applicant__c();
        apid1.Opportunity__c = opp.Id;
        apid1.Contact_number__c = '9743514830';
        apid1.Applicant_Type__c = 'Borrower';
        apid1.In_Active_Applicant__c = false;
        apid1.Application_Consent_Received__c = false;
        insert apid1; 
        
        Test.startTest();
        IND_InsuranceDetailsLWC_controller.fetchApplicants(opp.Id);
        Test.stopTest();
        
    }
    //Ashay
    @isTest
    public static void isL1L2InsuranceSubmittedTest(){
        Opportunity opp = new Opportunity();
        opp.StageName = 'Qualification';
        opp.CloseDate = Date.newInstance(2021, 1, 11);
        opp.Name = 'testone';
        insert opp;
        
        Vehicle_Detail__c vgd1 = new Vehicle_Detail__c();
        vgd1.Loan_Application__c = opp.Id;
        vgd1.Base_Price__c = 100000.00;
        vgd1.Ben_Code__c = 'testveh';
        insert vgd1; 
        
        
        Test.startTest();
        IND_InsuranceDetailsLWC_controller.isL1L2InsuranceSubmitted(vgd1.Id);
        Test.stopTest();
        
    }
    @isTest
    public static void callInuranceRecAPITestIsExpiringPart(){
        
        Opportunity opra1 = new Opportunity();
        opra1.StageName = 'Qualification';
        opra1.CloseDate = Date.newInstance(2021, 1, 11);
        opra1.Name = 'testone';
        opra1.Insurance_expiring_within_90_days__c = true;
        opra1.Funding_on_ORP__c = true;
        opra1.Product_Type__c = System.Label.Tractor;
        opra1.X1st_yr_Insurance_Premium__c=200;
        
        insert opra1;
        
        Applicant__c apra1 = new Applicant__c();
        apra1.Opportunity__c = opra1.Id;
        apra1.Contact_number__c = '9743514830';
        apra1.Applicant_Type__c = 'Borrower';
        
        insert apra1;
        
        Documents__c dtg1 = new Documents__c();
        dtg1.Applicant__c = apra1.Id;
        dtg1.Opportunity_Relation__c = opra1.Id;
        dtg1.Document_Type__c = System.Label.AadhaarCard;
        dtg1.Document_Side__c ='Back';
        dtg1.Aadhar_Source__c = 'ScanAadhar';
        dtg1.Age__c = 25;
        dtg1.KYC_DOB__c = Date.newInstance(1997, 06, 23);
        dtg1.Gender__c = 'MALE';
        dtg1.Proof_of_Identity_POI__c = true;
        
        insert dtg1;
        
        Final_Term__c fgd3 = new Final_Term__c();
        fgd3.CRM_IRR__c = 120;
        fgd3.Loan_Application__c = opra1.Id;
        fgd3.Holiday_period__c='30';
        fgd3.EMI_Amount__c= 10000;
        
        insert fgd3;
        
        Vehicle_Detail__c vgd1 = new Vehicle_Detail__c();
        vgd1.Loan_Application__c = opra1.Id;
        vgd1.Base_Price__c = 100000.00;
        vgd1.Ben_Code__c = 'testveh';
        vgd1.Vehicle_type__c = 'New';
        vgd1.Is_Customer_Interested_in_MotorInsurance__c = true;
        vgd1.Ins_Expiry_date__c = System.today();
        vgd1.X1st_yr_Insurance_Premium__c=200;
        
        insert vgd1;
        
        RequestWrapper rw1 = new RequestWrapper();
        rw1.applicantId = apra1.id;
        rw1.Borrower_Type = apra1.Applicant_Type__c;
        //rw1.Vehicle_Detail__r.X1st_yr_Insurance_Premium__c=apra1.Opportunity__r.X1st_yr_Insurance_Premium__c;
        
        Test.startTest();
        //IND_InsuranceDetailsLWC_controller.callInuranceRecAPI(apra1.Applicant_Type__c,opra1.Id);
        Test.stopTest();
        
    }
 @isTest
    public static void getFundingAvailibilityTestTractorPart(){
        try{
            Opportunity opfr1 = new Opportunity();
            opfr1.StageName = 'Qualification';
            opfr1.CloseDate = Date.newInstance(2021, 1, 11);
            opfr1.Name = 'testone';
            //   opfr1.Vehicle_Type__c = system.Label.new;
            //   opfr1.Funding_on_Ex_Showroom__c = true;
            opfr1.Ex_showroom_price__c = 300000.00;
            opfr1.Product_Type__c= System.Label.Tractor;
            insert opfr1;
            
            Vehicle_Detail__c vgd1 = new Vehicle_Detail__c();
            vgd1.Loan_Application__c = opfr1.Id;
            vgd1.Base_Price__c = 100000.00;
            vgd1.Ben_Code__c = 'testveh';
            insert vgd1; 
            
            Applicant__c apfr1 = new Applicant__c();
            apfr1.Opportunity__c = opfr1.Id;
            apfr1.Contact_number__c = '9743514830';
            apfr1.Applicant_Type__c = 'Borrower';
            insert apfr1; 
            
            Final_Term__c finalObj = new Final_Term__c();
            finalObj.Rreferrer_Incentive__c = '1000';
            finalObj.Loan_Amount__c = '41000';
            finalObj.OfferengineMinLoanAmount__c = 34534;
            finalObj.Dealer_incentive_amount_main_dealer__c = '567';
            finalObj.Trade_certificate__c = '34543';
            finalObj.Advance_EMI__c = true;
            finalObj.OfferengineMaxLoanAmount__c = 60000;
            finalObj.EMI_Amount__c = 4500;
            finalObj.OfferengineMinTenure__c = 67;
            finalObj.OfferengineMaxTenure__c = 100;
            finalObj.Tenure__c = '75';
            finalObj.PricingEngine_thresholdNetrr__c = 67899;
            finalObj.LtvEngine_Ltv__c = 567899;
            finalObj.Dealer_incentive_amount_sub_dealer__c = '300';
            finalObj.Holiday_period__c = '60';
            finalObj.Required_CRM_IRR__c = '1000';
            finalObj.Loan_Application__c = opfr1.Id;
            finalObj.Net_IRR__c = 100;
            insert finalObj;
            
            List<IND_InsuranceDetailsLWC_controller.InsuranceWrapper> InsuranceWrapperList = new List<IND_InsuranceDetailsLWC_controller.InsuranceWrapper>();
            IND_InsuranceDetailsLWC_controller.InsuranceWrapper wrapperObj = new IND_InsuranceDetailsLWC_controller.InsuranceWrapper();
            wrapperObj.isFunded = true;
            wrapperObj.premium = 1000.00;
            wrapperObj.selectedPlan = 'testselect';
            wrapperObj.selectedProduct = 'testprd';
            InsuranceWrapperList.add(wrapperObj);
            IND_InsuranceDetailsLWC_controller.GetFundingAvailabiltyRequestWrapper fr1 = new IND_InsuranceDetailsLWC_controller.GetFundingAvailabiltyRequestWrapper();
            fr1.loanApplicationId = opfr1.Id;
            fr1.insProductDetails = InsuranceWrapperList;
            // sr1.gpaInsurance = iw;
            // sr1.healthInsurance = iw;
            // sr1.motorInsurance = iw;
            // sr1.comboInsurance = iw;
            
            IND_InsuranceDetailsLWC_controller.GetFundingAvailabiltyResponseWrapper fw1 = new IND_InsuranceDetailsLWC_controller.GetFundingAvailabiltyResponseWrapper();
            fw1.totalInsurancePayable = 20000;
            fw1.ltvWithInsurance = '100';
            fw1.ltvWithoutInsurance = '120';
            fw1.proposalLtv = 1000;
            fw1.totalPremiumFunded = 2000;
            fw1.responseStatus = true;
            
            Opportunity opfr2 = new Opportunity();
            opfr2.Id = fr1.loanApplicationId;
            //   opfr2.StageName = 'Qualification';
            //   opfr2.CloseDate = Date.newInstance(2021, 1, 11);
            //     opfr2.Name = 'testone';
            opfr2.Vehicle_Type__c = system.Label.new;
            opfr2.Funding_on_Ex_Showroom__c = true;
            opfr2.Ex_showroom_price__c = 300000.00;
            update opfr2;
            
            
            Test.startTest();
            IND_InsuranceDetailsLWC_controller.updateDetailsForD2C(fw1,opfr1.Id);
            IND_InsuranceDetailsLWC_controller.getFundingAvailibility(Json.serialize(fr1));
            Test.stopTest();
            
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    @isTest
    public static void updateVehicleDetailsTest(){
            Opportunity oppRec = new Opportunity();
            oppRec.StageName = 'Qualification';
            oppRec.CloseDate = Date.newInstance(2021, 1, 11);
            oppRec.Name = 'testone';
            insert oppRec;
            
            Vehicle_Detail__c vehRec = new Vehicle_Detail__c();
            vehRec.Loan_Application__c = oppRec.Id;
            vehRec.Make__c ='TATA';
            vehRec.Model__c ='testModel';
            vehRec.Variant__c = 'testvariant';            
            insert vehRec; 

            Test.startTest();
            IND_InsuranceDetailsLWC_controller.updateVehicleDetails(oppRec.Id,'L1');
            IND_InsuranceDetailsLWC_controller.updateVehicleDetails(oppRec.Id,'L2');
            Test.stopTest();
    }  
    @isTest
    public static void fetchInsuranceTest(){
            Opportunity oppRec = new Opportunity();
            oppRec.StageName = 'Qualification';
            oppRec.CloseDate = Date.newInstance(2021, 1, 11);
            oppRec.Name = 'testone';
            insert oppRec;
        
            Applicant__c appRec = new Applicant__c();
            appRec.Opportunity__c = oppRec.Id;
            appRec.Contact_number__c = '9743514830';
            appRec.Applicant_Type__c = 'Borrower';
            appRec.Insurance_Consent_Received__c = false;
            insert appRec;
        
            InsuranceDetails__c insRec = new InsuranceDetails__c();
            insRec.Applicant__c = appRec.Id;
            insRec.Loan_Application__c = oppRec.Id;
            insRec.Name = 'Insurance';
            insert insRec; 
        
            Test.startTest();
            IND_InsuranceDetailsLWC_controller.fetchInsurance(oppRec.Id);
            Test.stopTest();
    }
    @isTest
    public static void isL1InsuranceChangedTest(){
            Opportunity oppRec = new Opportunity();
            oppRec.StageName = 'Qualification';
            oppRec.CloseDate = Date.newInstance(2021, 1, 11);
            oppRec.Name = 'testone';
            insert oppRec;
            
            Vehicle_Detail__c vehRec = new Vehicle_Detail__c();
            vehRec.Loan_Application__c = oppRec.Id;
            vehRec.Make__c ='TATA';
            vehRec.Model__c ='testModel';
            vehRec.Variant__c = 'testvariant';            
            insert vehRec;
            
            Test.startTest();
            IND_InsuranceDetailsLWC_controller.isL1InsuranceChanged(vehRec.Id);
            Test.stopTest();
    }
    @isTest
    public static void getFundingAvailibilityForTractorTest(){

            Opportunity opfr1 = new Opportunity();
            opfr1.StageName = 'Qualification';
            opfr1.CloseDate = Date.newInstance(2021, 1, 11);
            opfr1.Name = 'testOpp';
            opfr1.Ex_showroom_price__c = 300000.00;
            opfr1.Product_Type__c= System.Label.Tractor;
            opfr1.Vehicle_Type__c = system.Label.new;
            opfr1.Funding_on_Ex_Showroom__c = true;
            opfr1.LeadSource = 'D2C';
            opfr1.isTopUpLoan__c = true;
            insert opfr1;
            
            Vehicle_Detail__c vgd1 = new Vehicle_Detail__c();
            vgd1.Loan_Application__c = opfr1.Id;
            vgd1.Base_Price__c = 100000.00;
            vgd1.Ben_Code__c = 'testveh';
            vgd1.Vehicle_Type__c = system.Label.new;
            vgd1.Grid_value__c = 2000.00;
            vgd1.Valuation_price__c = 5000.00;
            vgd1.Insurance_declared_value__c = 3000.00;
            insert vgd1; 
            
            Vehicle_Detail__c vgd2 = new Vehicle_Detail__c();
            vgd2.Loan_Application__c = opfr1.Id;
            vgd2.Base_Price__c = 100000.00;
            vgd2.Ben_Code__c = 'testveh';
            vgd2.Vehicle_Type__c = system.Label.new;
            vgd2.Grid_value__c = 2000.00;
            vgd2.Valuation_price__c = 5000.00;
            vgd2.Insurance_declared_value__c = 3000.00;
            insert vgd2; 
        
            Applicant__c apfr1 = new Applicant__c();
            apfr1.Opportunity__c = opfr1.Id;
            apfr1.Contact_number__c = '9743514830';
            apfr1.Applicant_Type__c = 'Borrower';
            insert apfr1; 
            
            Final_Term__c finalObj = new Final_Term__c();
            finalObj.Rreferrer_Incentive__c = '1000';
            finalObj.Loan_Amount__c = '41000';
            finalObj.OfferengineMinLoanAmount__c = 34534;
            finalObj.Dealer_incentive_amount_main_dealer__c = '567';
            finalObj.Trade_certificate__c = '34543';
            finalObj.Advance_EMI__c = true;
            finalObj.OfferengineMaxLoanAmount__c = 60000;
            finalObj.EMI_Amount__c = 4500;
            finalObj.OfferengineMinTenure__c = 67;
            finalObj.OfferengineMaxTenure__c = 100;
            finalObj.Tenure__c = '75';
            finalObj.PricingEngine_thresholdNetrr__c = 67899;
            finalObj.LtvEngine_Ltv__c = 567899;
            finalObj.Dealer_incentive_amount_sub_dealer__c = '300';
            finalObj.Holiday_period__c = '60';
            finalObj.Required_CRM_IRR__c = '1000';
            finalObj.Loan_Application__c = opfr1.Id;
            finalObj.Vehicle_Detail__c = vgd1.Id;
            finalObj.Net_IRR__c = 100;
            insert finalObj;
            
            List<IND_InsuranceDetailsLWC_controller.InsuranceWrapper> InsuranceWrapperList = new List<IND_InsuranceDetailsLWC_controller.InsuranceWrapper>();
            IND_InsuranceDetailsLWC_controller.InsuranceWrapper wrapperObj = new IND_InsuranceDetailsLWC_controller.InsuranceWrapper();
            wrapperObj.isFunded = true;
            wrapperObj.premium = 1000.00;
            wrapperObj.selectedPlan = 'testselect';
            wrapperObj.selectedProduct = 'testprd';
            InsuranceWrapperList.add(wrapperObj);
            
            IND_InsuranceDetailsLWC_controller.GetFundingAvailabiltyRequestWrapper fr1 = new IND_InsuranceDetailsLWC_controller.GetFundingAvailabiltyRequestWrapper();
            fr1.loanApplicationId = opfr1.Id;
            fr1.assetId = vgd1.Id;
            fr1.insProductDetails = InsuranceWrapperList;                      
            
            Test.startTest();
            IND_InsuranceDetailsLWC_controller.getFundingAvailibility(Json.serialize(fr1));
            Test.stopTest();
    }
    @isTest
    public static void getFundingAvailibilityForTractorTest1(){
        
            Opportunity opfr1 = new Opportunity();
            opfr1.StageName = 'Qualification';
            opfr1.CloseDate = Date.newInstance(2021, 1, 11);
            opfr1.Name = 'testOpp';
            opfr1.Ex_showroom_price__c = 300000.00;
            opfr1.Product_Type__c= System.Label.Tractor;
            opfr1.Vehicle_Type__c = system.Label.new;
            opfr1.Funding_on_Ex_Showroom__c = true;
            opfr1.LeadSource = 'D2C';
            opfr1.isTopUpLoan__c = true;
            insert opfr1;
            
            Vehicle_Detail__c vgd1 = new Vehicle_Detail__c();
            vgd1.Loan_Application__c = opfr1.Id;
            vgd1.Base_Price__c = 100000.00;
            vgd1.Ben_Code__c = 'testveh';
            vgd1.Vehicle_Type__c = system.Label.Used;
            vgd1.Grid_value__c = 2000.00;
            vgd1.Valuation_price__c = 5000.00;
            vgd1.Insurance_declared_value__c = 3000.00;
            insert vgd1; 
        
            Applicant__c apfr1 = new Applicant__c();
            apfr1.Opportunity__c = opfr1.Id;
            apfr1.Contact_number__c = '9743514830';
            apfr1.Applicant_Type__c = 'Borrower';
            insert apfr1; 
            
            Final_Term__c finalObj = new Final_Term__c();
            finalObj.Rreferrer_Incentive__c = '1000';
            finalObj.Loan_Amount__c = '410000';
            finalObj.OfferengineMinLoanAmount__c = 34534;
            finalObj.Dealer_incentive_amount_main_dealer__c = '567';
            finalObj.Trade_certificate__c = '34543';
            finalObj.Advance_EMI__c = true;
            finalObj.OfferengineMaxLoanAmount__c = 60000;
            finalObj.EMI_Amount__c = 4500;
            finalObj.OfferengineMinTenure__c = 67;
            finalObj.OfferengineMaxTenure__c = 100;
            finalObj.Tenure__c = '75';
            finalObj.PricingEngine_thresholdNetrr__c = 67899;
            finalObj.LtvEngine_Ltv__c = 567899;
            finalObj.Dealer_incentive_amount_sub_dealer__c = '300';
            finalObj.Holiday_period__c = '60';
            finalObj.Required_CRM_IRR__c = '1000';
            finalObj.Loan_Application__c = opfr1.Id;
            finalObj.Vehicle_Detail__c = vgd1.Id;
            finalObj.Net_IRR__c = 100;
            insert finalObj;
            
            List<IND_InsuranceDetailsLWC_controller.InsuranceWrapper> InsuranceWrapperList = new List<IND_InsuranceDetailsLWC_controller.InsuranceWrapper>();
            IND_InsuranceDetailsLWC_controller.InsuranceWrapper wrapperObj = new IND_InsuranceDetailsLWC_controller.InsuranceWrapper();
            wrapperObj.isFunded = true;
            wrapperObj.premium = 1000.00;
            wrapperObj.selectedPlan = 'testselect';
            wrapperObj.selectedProduct = 'testprd';
            InsuranceWrapperList.add(wrapperObj);
            
            IND_InsuranceDetailsLWC_controller.GetFundingAvailabiltyRequestWrapper fr1 = new IND_InsuranceDetailsLWC_controller.GetFundingAvailabiltyRequestWrapper();
            fr1.loanApplicationId = opfr1.Id;
            fr1.assetId = vgd1.Id;
            fr1.insProductDetails = InsuranceWrapperList;                      
            
            Test.startTest();
            IND_InsuranceDetailsLWC_controller.getFundingAvailibility(Json.serialize(fr1));
            Test.stopTest();
    }
    @isTest
    public static void getFinalTermLoanAmountTest(){
            Opportunity oppRec = new Opportunity();
            oppRec.StageName = 'Qualification';
            oppRec.CloseDate = Date.newInstance(2021, 1, 11);
            oppRec.Name = 'testone';
            insert oppRec;
            
            Final_Term__c finalObj = new Final_Term__c();
            finalObj.Loan_Amount__c = '410000';
            finalObj.Loan_Application__c = oppRec.Id;
            finalObj.EMI_Amount__c = 4500;
            insert finalObj; 

            Test.startTest();
            IND_InsuranceDetailsLWC_controller.getFinalTermLoanAmount(oppRec.Id);
            Test.stopTest();
    } 
}