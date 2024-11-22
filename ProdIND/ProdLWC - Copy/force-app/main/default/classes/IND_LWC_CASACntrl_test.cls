@isTest
public class IND_LWC_CASACntrl_test {
    @testSetup static void setup(){

        Account accobj = new Account();
        accobj.Name = 'testname';
        accobj.State__c = 'ASSAM';
        accobj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business Account').getRecordTypeId();
        insert accobj;

        Opportunity oppObj = TestDataUtility.createTestOpportunity(false);
        oppobj.accountid = accobj.id;
        insert oppobj;
      
        Applicant__c applicant = new Applicant__c();
        applicant.Customer_Qualification__c='B4';
        applicant.Opportunity__c= oppObj.Id;
        applicant.Customer_First_Name__c='TestFirstName';
        applicant.Customer_Last_Name__c='TestLastName';
        applicant.Mother_s_name__c='TestMothersName';
        applicant.Father_s_name__c='TestFathersName';
        applicant.Marital_status__c='DIVOR';
        applicant.Contact_number__c='9876543210';
        applicant.Email_Id__c='abc@abc.com';
        applicant.Name='Applicant Name';
        applicant.Declared_income__c=123456;
        applicant.Start_Date__c= String.valueOf(System.today());
        applicant.Loan_Amount__c=123456;
        applicant.Application_Consent_Received__c= true;
        applicant.Current_Same_As_Permanent__c = true;
        applicant.In_Active_Applicant__c = false;
        applicant.CASA_Consent_Received__c= true;
        applicant.CASA_Consent_Received_Time__c=DateTime.Now();
        applicant.CASA_Consent_OTP__c='1542';
        applicant.CASA_Form_SMS_Sent__c=DateTime.Now();
        insert applicant;

        List<Documents__c> dcList = new List<Documents__c>();
        Documents__c doc = new Documents__c();
        doc.KYC_District__c='Nellore';
        doc.PAN_No__c='324425244222';
        doc.Proof_of_Identity_POI__c= true;
        doc.Document_Type__c='Form 60';
        doc.Current_Residential_Address_Proof__c = true;
        doc.Permanent_Residential_Address_Proof__c=true;
        doc.KYC_No__c = Integrationutilities.getencryptedrequest('TN2020090003150',System.Label.privateKey,System.Label.ivkey);
        doc.KYC_Expiry_Date__c=Date.parse('06/07/2023');
        doc.Salutation__c='Mr.';
        doc.First_Name__c='abc';
        doc.Last_Name__c='test2';
        doc.KYC_DOB__c=Date.parse('06/07/2000');
        doc.Gender__c='MALE';
        doc.KYC_City__c='Indore';
        doc.KYC_State__c='MH';
        doc.KYC_Pin_Code__c='435222';
        doc.KYC_Address_Line_1__c='Test address kyc 1';
        doc.KYC_Address_Line_2__c='Test address kyc 1';
        doc.Passport_No__c = 'A22570';
        doc.Opportunity_Relation__c=oppObj.Id;
        doc.Applicant__c= applicant.Id;

        Documents__c doc1 = new Documents__c();
        doc1.KYC_District__c='Indore';
        doc1.PAN_No__c='32442542221113432';
        doc1.Proof_of_Identity_POI__c= true;
        doc1.Document_Type__c=system.label.DrivingLicences;
        doc1.Current_Residential_Address_Proof__c = true;
        doc1.Permanent_Residential_Address_Proof__c=false;
        doc1.KYC_No__c = Integrationutilities.getencryptedrequest('TN2020090003150',System.Label.privateKey,System.Label.ivkey);
        doc1.KYC_Expiry_Date__c=Date.parse('06/07/2024');
        doc1.Salutation__c='Mr.';
        doc1.First_Name__c='abcd';
        doc1.Last_Name__c='test3';
        doc1.KYC_DOB__c=Date.parse('06/08/2000');
        doc1.Gender__c='MALE';
        doc1.KYC_City__c='Indore';
        doc1.KYC_State__c='MP';
        doc1.KYC_Pin_Code__c='43522';
        doc1.KYC_Address_Line_1__c='Test address kyc 2';
        doc1.KYC_Address_Line_2__c='Test address kyc 2';
        doc1.Passport_No__c = 'A42570';
        doc1.Opportunity_Relation__c=oppObj.Id;
        doc1.Applicant__c= applicant.Id;

        Documents__c doc2 = new Documents__c();
        doc2.KYC_District__c='Delhi';
        doc2.PAN_No__c='324425422113432';
        doc2.Proof_of_Identity_POI__c= true;
        doc2.Document_Type__c='Pan';
        doc2.Current_Residential_Address_Proof__c = true;
        doc2.Permanent_Residential_Address_Proof__c=false;
        doc2.KYC_No__c = Integrationutilities.getencryptedrequest('TN2020090003150',System.Label.privateKey,System.Label.ivkey);
        doc2.KYC_Expiry_Date__c=Date.parse('06/08/2023');
        doc2.Salutation__c='Mr.';
        doc2.First_Name__c='acd';
        doc2.Last_Name__c='test4';
        doc2.KYC_DOB__c=Date.parse('06/08/2000');
        doc2.Gender__c='MALE';
        doc2.KYC_City__c='Delhi';
        doc2.KYC_State__c='UP';
        doc2.KYC_Pin_Code__c='4522';
        doc2.KYC_Address_Line_1__c='Test address kyc 3';
        doc2.KYC_Address_Line_2__c='Test address kyc 3';
        doc2.Passport_No__c = 'A47570';
        doc2.Opportunity_Relation__c=oppObj.Id;
        doc2.Applicant__c= applicant.Id;

        Documents__c doc3 = new Documents__c();
        doc3.KYC_District__c='Delhi';
        doc3.PAN_No__c='324425422113432';
        doc3.Proof_of_Identity_POI__c= true;
        doc3.Document_Type__c=system.label.VoterIdCard;
        doc3.Current_Residential_Address_Proof__c = true;
        doc3.Permanent_Residential_Address_Proof__c=false;
        doc3.KYC_No__c = Integrationutilities.getencryptedrequest('TN2020090003150',System.Label.privateKey,System.Label.ivkey);
        doc3.KYC_Expiry_Date__c=Date.parse('06/09/2023');
        doc3.Salutation__c='Mr.';
        doc3.First_Name__c='acwd';
        doc3.Last_Name__c='test5';
        doc3.KYC_DOB__c=Date.parse('06/09/2000');
        doc3.Gender__c='MALE';
        doc3.KYC_City__c='Bhopal';
        doc3.KYC_State__c='MP';
        doc3.KYC_Pin_Code__c='5222';
        doc3.KYC_Address_Line_1__c='Test address kyc 4';
        doc3.KYC_Address_Line_2__c='Test address kyc 4';
        doc3.Passport_No__c = 'A27570';
        doc3.Opportunity_Relation__c=oppObj.Id;
        doc3.Applicant__c= applicant.Id;

        Documents__c doc4 = new Documents__c();
        doc4.KYC_District__c='Pune';
        doc4.PAN_No__c='324425422113432';
        doc4.Proof_of_Identity_POI__c= true;
        doc4.Document_Type__c=system.label.PassportCard;
        doc4.Current_Residential_Address_Proof__c = true;
        doc4.Permanent_Residential_Address_Proof__c=false;
        doc4.KYC_No__c = Integrationutilities.getencryptedrequest('TN2020090003150',System.Label.privateKey,System.Label.ivkey);
        doc4.KYC_Expiry_Date__c=Date.parse('06/10/2023');
        doc4.Salutation__c='Mr.';
        doc4.First_Name__c='aced';
        doc4.Last_Name__c='test6';
        doc4.KYC_DOB__c=Date.parse('06/10/2000');
        doc4.Gender__c='MALE';
        doc4.KYC_City__c='Pune';
        doc4.KYC_State__c='MH';
        doc4.KYC_Pin_Code__c='5333';
        doc4.KYC_Address_Line_1__c='Test address kyc 5';
        doc4.KYC_Address_Line_2__c='Test address kyc 5';
        doc4.Passport_No__c = 'A27590';
        doc4.Opportunity_Relation__c=oppObj.Id;
        doc4.Applicant__c= applicant.Id;

        Documents__c doc5 = new Documents__c();
        doc5.KYC_District__c='Mumbai';
        doc5.PAN_No__c='324425422113412';
        doc5.Proof_of_Identity_POI__c= true;
        doc5.Document_Type__c=system.label.AadhaarCard;
        doc5.Current_Residential_Address_Proof__c = true;
        doc5.Permanent_Residential_Address_Proof__c=false;
        doc5.KYC_No__c = Integrationutilities.getencryptedrequest('TN2020090003150',System.Label.privateKey,System.Label.ivkey);
        doc5.KYC_Expiry_Date__c=Date.parse('06/10/2023');
        doc5.Salutation__c='Mr.';
        doc5.First_Name__c='acde';
        doc5.Last_Name__c='test7';
        doc5.KYC_DOB__c=Date.parse('06/11/2000');
        doc5.Gender__c='MALE';
        doc5.KYC_City__c='Mumbai';
        doc5.KYC_State__c='MH';
        doc5.KYC_Pin_Code__c='5343';
        doc5.KYC_Address_Line_1__c='Test address kyc 6';
        doc5.KYC_Address_Line_2__c='Test address kyc 6';
        doc5.Passport_No__c = 'A27500';
        doc5.Opportunity_Relation__c=oppObj.Id;
        doc5.Applicant__c= applicant.Id;
        insert doc;
        insert doc1;
        insert doc2;
        insert doc3;
        insert doc4;
        insert doc5;
        dcList.add(doc);
        dcList.add(doc1);
        dcList.add(doc2);
        dcList.add(doc3);
        dcList.add(doc4);
        dcList.add(doc5);

        Profile_Master__c profile = new Profile_Master__c();
        profile.Name = 'sarth';
        profile.Code__c='160';
        profile.Sub_Bucket_Desc__c='Sub Bucket Desc';
        insert profile;

        Income_Details__c incDetail = new Income_Details__c();
        incDetail.Name='abcccsss';
        incDetail.Applicant__c=applicant.Id;
        incDetail.Primary_Income_Source__c = true;
        incDetail.Office_Address_Line_1__c='office address 1';
        incDetail.Office_Address_Line_2__c='office address 2';
        incDetail.Office_City__c='Indore';
        incDetail.Office_District__c='Indore';
        incDetail.Office_PinCode__c='452001';
        incDetail.Office_State__c='MP';
        incDetail.IsOfficeAddressSubmitted__c=true;
        incDetail.Profile__c= profile.Id;
        insert incDetail;
        
        CASA_Bank_Form__c casaBankForms = new CASA_Bank_Form__c();
        casaBankForms.Nominee_address__c='JAHHFGAFFAFFG';
        casaBankForms.Nominee_name__c='RRDKE';
        casaBankForms.Nominee_DOB__c=Date.parse('06/07/2000');
        casaBankForms.Relationship_with_borrower__c='Good';
        casaBankForms.Loan_Application__c= oppObj.Id;
        casaBankForms.Nominee_available__c= true;
        casaBankForms.Applicant__c= applicant.Id;
        insert casaBankForms;

        Final_Term__c finalTerm = new Final_Term__c();
        finalTerm.Tenure__c='2';
        finalTerm.EMI_Amount__c=12342;
        finalTerm.Loan_Application__c= oppObj.Id;
        insert finalTerm;

        Loan_Agreement__c loanAgreement= new Loan_Agreement__c();
        loanAgreement.Ist_EMI_Due_Date__c=Date.parse('06/09/2022');
        loanAgreement.Loan_Application__c= oppObj.Id;
        insert loanAgreement;

        Repayments__c repay = new Repayments__c();
        repay.lst_EMI_Due_Date__c=Date.parse('06/10/2022');
        repay.Loan_Application__c= oppObj.Id;
        repay.Is_Netbanking_available_with_customer__c='Yes';
        insert repay;
    }


    @isTest 
    public static void renderCASACntrlTest(){
        
        Applicant__c appli =[SELECT Id, CASA_Consent_Received__c , CASA_Consent_Received_Time__c ,CASA_Consent_OTP__c FROM Applicant__c LIMIT 1];
            
        List<Applicant__c> apList = new List<Applicant__c>();
        apList.add(appli);

        PageReference testPage = Page.IND_CASAConsentPage;
        Test.setCurrentPage(testPage);
        testPage.getParameters().put('Id', String.valueOf(appli.Id));
        testPage.getParameters().put('connum', String.valueOf(appli.CASA_Consent_OTP__c));

        IND_LWC_CASACntrl ext = new IND_LWC_CASACntrl();
        ext.acceptConsent =true;
        Test.StartTest();
        ApexPages.StandardController sc = new  ApexPages.StandardController(appli);
        ext.getlinkExpired();
        ext.acceptandRender();
        appli.CASA_Consent_OTP__c='1543';
        Update appli;
         ext.getlinkExpired();
         appli.CASA_Consent_OTP__c=null;
        Update appli;
          ext.getlinkExpired();
         appli.CASA_Consent_OTP__c='';
        Update appli;
          ext.getlinkExpired();
        //ext.Records = apList;
        Test.StopTest();
    }
}