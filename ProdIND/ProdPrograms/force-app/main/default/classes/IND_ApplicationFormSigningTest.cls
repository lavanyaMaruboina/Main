@isTest
public class IND_ApplicationFormSigningTest {
     @testSetup static void setup(){
        
        Account accobj = new Account();
        accobj.Name = 'testname';
        accobj.State__c = 'ASSAM';
        accobj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business Account').getRecordTypeId();
        insert accobj;
        
        Opportunity oppObj = TestDataUtility.createTestOpportunity(false);
        oppobj.accountid = accobj.id;
        insert oppobj;
        
        Applicant__c applicant = TestDataUtility.createTestApplicant(false);
        applicant.Opportunity__c = oppObj.Id;
        applicant.Application_Form_SMS_Sent__c = System.now();
        applicant.Application_Consent_Received__c = true;
        insert applicant;
        
        Documents__c getDoc = TestDataUtility.createTestDocumentITR(false, applicant, oppObj);
        getDoc.Applicant__c = applicant.id;
        getDoc.Addresss_Type__c = 'Current Residential Address';
        insert getDoc;
        
        Income_Details__c incme = TestDataUtility.createIncomeDetailsRecord();
        incme.Applicant__c = applicant.id;
         incme.Assessment_Year__c='2022';
         incme.Document_Type__c='ITR-Forms';
        insert incme;
         
          if(incme.Capture_Income_Method__c !=null)
        {
          string CapturedIncomemethod = incme.Capture_Income_Method__c;
        }
        else
        {
            string CapturedIncomemethod = 'Not applicable';
        }
         
          if(incme.Assessment_Year__c !=null)
        {
          string AssessmentYear = incme.Assessment_Year__c;
        }
        else
        {
            string AssessmentYear = 'Not applicable';
        }
         
         
          if(incme.Document_Type__c !=null)
        {
          string DocumentType =  incme.Document_Type__c;
        }
        else
        {
           string  DocumentType = 'Not applicable';
        }
        
          if(incme.To_Month__c !=null)
        {
          string ToMonth = incme.To_Month__c;
        }
        else
        {
            string ToMonth = 'Not applicable';
        }
         
        
        Vehicle_Detail__c veh = TestDataUtility.createTestVehicleDetailForMFCValuation(true, oppObj);
    }

    @isTest 
    public static void renderasPdfcontrollerTest()
    {
        Applicant__c applicant =[select id,name,Application_Form_SMS_Sent__c from Applicant__c];
        
        List<Applicant__c> apList = new List<Applicant__c>();
        apList.add(applicant);
            
        PageReference testPage = Page.Ind_ApplicationForm; 
        Test.setCurrentPage(testPage);
        testPage.getParameters().put('Id', String.valueOf(applicant.Id));
        
        Test.StartTest();
        ApexPages.StandardController sc = new  ApexPages.StandardController(applicant);     
        renderasPdfcontroller ext = new renderasPdfcontroller(sc);
        ext.getlinkExpired();
        ext.acceptandRender();
        ext.Records = apList;
        Test.StopTest();
    }
     @isTest 
    public static void renderasPdfcontrollerTest12()
    {
       Opportunity opfv1 = new Opportunity();
       opfv1.StageName = 'Credit Processing';
       opfv1.CloseDate = Date.newInstance(2021, 1, 11);
       opfv1.Name = 'testone';
       opfv1.Product_Type__c = System.Label.Tractor;
       insert opfv1;
        
        Applicant__c applicant = new Applicant__c();
        applicant.Opportunity__c = opfv1.Id;
        applicant.Contact_number__c = '9743514830';
        applicant.Applicant_Type__c = 'Borrower';
        applicant.Who_will_repay_the_loan__c = 'Borrower';
        applicant.Application_Consent_Received__c = true;
        insert applicant;
                
        List<Documents__c> dcList = new List<Documents__c>();
        Documents__c dfks1 = new Documents__c();
        dfks1.Applicant__c = applicant.Id;
        dfks1.Opportunity_Relation__c = opfv1.Id;
        dfks1.KYC_name__c = 'Aadhar';
        dfks1.Document_Side__c ='Back';
        dfks1.Aadhar_Source__c = 'ScanAadhar';
        dfks1.Name = 'Aadhar';
        dfks1.Document_Type__c = system.label.PassportCard;
        dfks1.Current_Residential_Address_Proof__c = true;
        dfks1.Passport_No__c = 'A22570';
        dfks1.KYC_District__c = 'Nellore';
        insert dfks1;
        dcList.add(dfks1);
     
        
     //   Applicant__c applicant =[select id,name,Application_Form_SMS_Sent__c from Applicant__c];
        applicant.Application_Form_SMS_Sent__c = datetime.newInstance(2014, 9, 15, 12, 30, 0);
        update applicant;
        
        List<Applicant__c> apList = new List<Applicant__c>();
        apList.add(applicant);
            
        PageReference testPage = Page.Ind_ApplicationForm; 
        Test.setCurrentPage(testPage);
        testPage.getParameters().put('Id', String.valueOf(applicant.Id));
        
        Vehicle_Detail__c vehicleDetail = new Vehicle_Detail__c();
        vehicleDetail.Loan_Application__c = opfv1.Id;
        vehicleDetail.Can_we_continue_with_above_RC_limit__c = true;
        insert vehicleDetail;
        
        Final_Term__c ftv1 = new Final_Term__c();
        ftv1.CRM_IRR__c = 120;
        ftv1.Loan_Application__c = opfv1.Id;
        ftv1.Holiday_period__c='30';
        ftv1.EMI_Amount__c= 10000;
        insert ftv1;
        
        Test.StartTest();
        ApexPages.StandardController sc = new  ApexPages.StandardController(applicant);   
        try{
        IND_ApplicationFormSigning ext = new IND_ApplicationFormSigning();
        ext.getlinkExpired();
        ext.acceptandRender();
        ext.Records = apList;
        ext.FinalTermObj = ftv1;
        ext.lst_document = dcList;
            }catch(Exception e){
            System.debug('e '+e.getMessage());
        }
        Test.StopTest();
    }
    @isTest 
    public static void renderasPdfcontrollerTest13()
    {
       Opportunity opfv1 = new Opportunity();
       opfv1.StageName = 'Credit Processing';
       opfv1.CloseDate = Date.newInstance(2021, 1, 11);
       opfv1.Name = 'testone';
       opfv1.Product_Type__c = System.Label.Tractor;
       insert opfv1;
        
        Applicant__c applicant = new Applicant__c();
        applicant.Opportunity__c = opfv1.Id;
        applicant.Contact_number__c = '9743514830';
        applicant.Applicant_Type__c = 'Borrower';
        applicant.Who_will_repay_the_loan__c = 'Borrower';
        applicant.Application_Consent_Received__c = true;
        insert applicant;
                
        List<Documents__c> dcList = new List<Documents__c>();
        Documents__c dfks1 = new Documents__c();
        dfks1.Applicant__c = applicant.Id;
        dfks1.Opportunity_Relation__c = opfv1.Id;
        dfks1.KYC_name__c = 'Aadhar';
        dfks1.Document_Side__c ='Back';
        dfks1.Aadhar_Source__c = 'ScanAadhar';
        dfks1.Name = 'Aadhar';
        dfks1.Document_Type__c = system.label.PassportCard;
        dfks1.Current_Residential_Address_Proof__c = true;
        dfks1.Passport_No__c = 'A22570';
        dfks1.KYC_District__c = 'Nellore';
        insert dfks1;
        dcList.add(dfks1);
     
        
     //   Applicant__c applicant =[select id,name,Application_Form_SMS_Sent__c from Applicant__c];
        applicant.Application_Form_SMS_Sent__c = datetime.newInstance(2014, 9, 15, 12, 30, 0);
        update applicant;
        
        List<Applicant__c> apList = new List<Applicant__c>();
        apList.add(applicant);
            
        PageReference testPage = Page.Ind_ApplicationForm; 
        Test.setCurrentPage(testPage);
        testPage.getParameters().put('Id', String.valueOf(applicant.Id));
        
        Vehicle_Detail__c vehicleDetail = new Vehicle_Detail__c();
        vehicleDetail.Loan_Application__c = opfv1.Id;
        vehicleDetail.Can_we_continue_with_above_RC_limit__c = true;
        vehicleDetail.Vehicle_type__c = system.label.new;
        insert vehicleDetail;
        
        Final_Term__c ftv1 = new Final_Term__c();
        ftv1.CRM_IRR__c = 120;
        ftv1.Loan_Application__c = opfv1.Id;
        ftv1.Holiday_period__c='30';
        ftv1.EMI_Amount__c= 10000;
        insert ftv1;
        
        Test.StartTest();
        ApexPages.StandardController sc = new  ApexPages.StandardController(applicant);   
        try{
        IND_ApplicationFormSigning ext = new IND_ApplicationFormSigning();
        ext.getlinkExpired();
        ext.acceptandRender();
        ext.Records = apList;
        ext.FinalTermObj = ftv1;
        ext.lst_document = dcList;
            }catch(Exception e){
            System.debug('e '+e.getMessage());
        }
        Test.StopTest();
    }
@isTest 
    public static void renderasPdfcontrollerTest14()
    {
       Opportunity opfv1 = new Opportunity();
       opfv1.StageName = 'Credit Processing';
       opfv1.CloseDate = Date.newInstance(2021, 1, 11);
       opfv1.Name = 'testone';
       opfv1.Product_Type__c = System.Label.Tractor;
       insert opfv1;
        
        Applicant__c applicant = new Applicant__c();
        applicant.Opportunity__c = opfv1.Id;
        applicant.Contact_number__c = '9743514830';
        applicant.Applicant_Type__c = 'Borrower';
        applicant.Who_will_repay_the_loan__c = 'Borrower';
        applicant.Application_Consent_Received__c = true;
        insert applicant;
                
        List<Documents__c> dcList = new List<Documents__c>();
        Documents__c dfks1 = new Documents__c();
        dfks1.Applicant__c = applicant.Id;
        dfks1.Opportunity_Relation__c = opfv1.Id;
        dfks1.KYC_name__c = 'Aadhar';
        dfks1.Document_Side__c ='Back';
        dfks1.Aadhar_Source__c = 'ScanAadhar';
        dfks1.Name = 'Aadhar';
        dfks1.Document_Type__c = system.label.PassportCard;
        dfks1.Current_Residential_Address_Proof__c = true;
        dfks1.Passport_No__c = 'A22570';
        dfks1.KYC_District__c = 'Nellore';
        insert dfks1;
        dcList.add(dfks1);
     
        
     //   Applicant__c applicant =[select id,name,Application_Form_SMS_Sent__c from Applicant__c];
        applicant.Application_Form_SMS_Sent__c = datetime.newInstance(2014, 9, 15, 12, 30, 0);
        update applicant;
        
        List<Applicant__c> apList = new List<Applicant__c>();
        apList.add(applicant);
            
        PageReference testPage = Page.Ind_ApplicationForm; 
        Test.setCurrentPage(testPage);
        testPage.getParameters().put('Id', String.valueOf(applicant.Id));
        
        Vehicle_Detail__c vehicleDetail = new Vehicle_Detail__c();
        vehicleDetail.Loan_Application__c = opfv1.Id;
        vehicleDetail.Can_we_continue_with_above_RC_limit__c = true;
        vehicleDetail.Vehicle_type__c = 'Used';
        insert vehicleDetail;
        
        Final_Term__c ftv1 = new Final_Term__c();
        ftv1.CRM_IRR__c = 120;
        ftv1.Loan_Application__c = opfv1.Id;
        ftv1.Holiday_period__c='30';
        ftv1.EMI_Amount__c= 10000;
        insert ftv1;
        
        InsuranceDetails__c incomedetail = new InsuranceDetails__c();
        incomedetail.Applicant__c = applicant.Id;
        incomedetail.Loan_Application__c = opfv1.Id;
        insert incomedetail;
        
        Test.StartTest();
        ApexPages.StandardController sc = new  ApexPages.StandardController(applicant);   
        try{
        IND_ApplicationFormSigning ext = new IND_ApplicationFormSigning();
        ext.getlinkExpired();
        ext.acceptandRender();
        ext.Records = apList;
        ext.FinalTermObj = ftv1;
        ext.lst_document = dcList;
            }catch(Exception e){
            System.debug('e '+e.getMessage());
        }
        Test.StopTest();
    }

     @isTest 
    public static void renderasPdfcontrollerTest1()
    {
       Opportunity opfv1 = new Opportunity();
       opfv1.StageName = 'Credit Processing';
       opfv1.CloseDate = Date.newInstance(2021, 1, 11);
       opfv1.Name = 'testone';
       opfv1.Product_Type__c = system.label.TwoWheeler;
       insert opfv1;
        
        Applicant__c applicant = new Applicant__c();
        applicant.Opportunity__c = opfv1.Id;
        applicant.Contact_number__c = '9743514830';
        applicant.Applicant_Type__c = 'Borrower';
        applicant.Who_will_repay_the_loan__c = 'Borrower';
        applicant.Application_Consent_Received__c = true;
        insert applicant;
                
        List<Documents__c> dcList = new List<Documents__c>();
        Documents__c dfks1 = new Documents__c();
        dfks1.Applicant__c = applicant.Id;
        dfks1.Opportunity_Relation__c = opfv1.Id;
        dfks1.KYC_name__c = 'Aadhar';
        dfks1.Document_Side__c ='Back';
        dfks1.Aadhar_Source__c = 'ScanAadhar';
        dfks1.Name = 'Aadhar';
        dfks1.Document_Type__c = system.label.PassportCard;
        dfks1.Current_Residential_Address_Proof__c = true;
        dfks1.Passport_No__c = 'A22570';
        dfks1.KYC_District__c = 'Nellore';
        insert dfks1;
        dcList.add(dfks1);
     
        
     //   Applicant__c applicant =[select id,name,Application_Form_SMS_Sent__c from Applicant__c];
        applicant.Application_Form_SMS_Sent__c = datetime.newInstance(2014, 9, 15, 12, 30, 0);
        update applicant;
        
        List<Applicant__c> apList = new List<Applicant__c>();
        apList.add(applicant);
            
        PageReference testPage = Page.Ind_ApplicationForm; 
        Test.setCurrentPage(testPage);
        testPage.getParameters().put('Id', String.valueOf(applicant.Id));
        
        Final_Term__c ftv1 = new Final_Term__c();
        ftv1.CRM_IRR__c = 120;
        ftv1.Loan_Application__c = opfv1.Id;
        ftv1.Holiday_period__c='30';
        ftv1.EMI_Amount__c= 10000;
        insert ftv1;
        
        Test.StartTest();
        ApexPages.StandardController sc = new  ApexPages.StandardController(applicant);   
        try{
        IND_ApplicationFormSigning ext = new IND_ApplicationFormSigning();
        ext.getlinkExpired();
        ext.acceptandRender();
        ext.Records = apList;
        ext.FinalTermObj = ftv1;
        ext.lst_document = dcList;
            }catch(Exception e){
            System.debug('e '+e.getMessage());
        }
        Test.StopTest();
    }
    
     @isTest 
    public static void renderasPdfcontrollerTest2()
    {
       Opportunity opfv1 = new Opportunity();
       opfv1.StageName = 'Credit Processing';
       opfv1.CloseDate = Date.newInstance(2021, 1, 11);
       opfv1.Name = 'testone';
       opfv1.Product_Type__c = system.label.PassengerVehicles;
       opfv1.Vehicle_Type__c = system.label.used;
       opfv1.Funding_on_ORP__c = true;
       opfv1.Funding_on_Ex_Showroom__c = true;
       insert opfv1;
        
        Applicant__c applicant = new Applicant__c();
        applicant.Opportunity__c = opfv1.Id;
        applicant.Contact_number__c = '9743514830';
        applicant.Applicant_Type__c = 'Borrower';
        applicant.Who_will_repay_the_loan__c = 'Borrower';
        applicant.Application_Consent_Received__c = true;
        applicant.Current_Same_As_Permanent__c = true;
        applicant.Application_Form_SMS_Sent__c = Date.today().addDays(-90);
        insert applicant;
        
        applicant.Whatsapp_number__c = applicant.Contact_number__c;
        update applicant;
                
        List<Documents__c> dcList = new List<Documents__c>();
        Documents__c dfks2 = new Documents__c();
        dfks2.Applicant__c = applicant.Id;
        dfks2.Opportunity_Relation__c = opfv1.Id;
        dfks2.KYC_name__c = 'Aadhar';
        dfks2.Document_Side__c ='Back';
        dfks2.Aadhar_Source__c = 'ScanAadhar';
        dfks2.Name = 'Aadhar';
        dfks2.Document_Type__c = system.label.AadhaarCard;
        dfks2.Current_Residential_Address_Proof__c = true;
        //dfks2.KYC_No__c = 'test';
        dfks2.KYC_District__c = 'Nellore';
        insert dfks2;
        dcList.add(dfks2);
        
        Date docDate = Date.today();
        Test.setCreatedDate(dfks2.Id, docDate);
     
        
     //   Applicant__c applicant =[select id,name,Application_Form_SMS_Sent__c from Applicant__c];
        applicant.Application_Form_SMS_Sent__c = datetime.newInstance(2014, 9, 15, 12, 30, 0);
        update applicant;
        
        List<Applicant__c> apList = new List<Applicant__c>();
        apList.add(applicant);
            
        PageReference testPage = Page.Ind_ApplicationForm; 
        Test.setCurrentPage(testPage);
        testPage.getParameters().put('Id', String.valueOf(applicant.Id));
        
        Final_Term__c ftv1 = new Final_Term__c();
        ftv1.CRM_IRR__c = 120;
        ftv1.Loan_Application__c = opfv1.Id;
        ftv1.Holiday_period__c='30';
        ftv1.EMI_Amount__c= 10000;
        insert ftv1;
        
        Test.StartTest();
        ApexPages.StandardController sc = new  ApexPages.StandardController(applicant);  
        try{
        IND_ApplicationFormSigning ext = new IND_ApplicationFormSigning();
        ext.getlinkExpired();
        ext.acceptandRender();
        ext.Records = apList;
        ext.FinalTermObj = ftv1;
        ext.lst_document = dcList;
        ext.passportdocument = dfks2;
        ext.document = dcList;
            }catch(Exception e){
            System.debug('e '+e.getMessage());
        }
        Test.StopTest();
    }
    
     @isTest 
    public static void renderasPdfcontrollerTest21()
    {
       Opportunity opfv1 = new Opportunity();
       opfv1.StageName = 'Credit Processing';
       opfv1.CloseDate = Date.newInstance(2021, 1, 11);
       opfv1.Name = 'testone';
       opfv1.Product_Type__c = system.label.PassengerVehicles;
       opfv1.Vehicle_Type__c = system.label.used;
       insert opfv1;
        
        Applicant__c applicant = new Applicant__c();
        applicant.Opportunity__c = opfv1.Id;
        applicant.Contact_number__c = '9743514830';
        applicant.Applicant_Type__c = 'Borrower';
        applicant.Who_will_repay_the_loan__c = 'Borrower';
        applicant.Application_Consent_Received__c = true;
       applicant.Marital_status__c='	DVRCE';
        applicant.Communication_language__c = '	BE';
        
        applicant.Current_Same_As_Permanent__c = true;
        insert applicant;
        
        applicant.Whatsapp_number__c = applicant.Contact_number__c;
        update applicant;
        
        Income_Details__c in1 = TestDataUtility.createTestIncomeDetails(false);
        in1.Applicant__c = applicant.id;
        in1.Salaried_Self_employed__c = 'Salaried';
        in1.Office_State__c = 'MAHARASHTRA';
        in1.Capture_Income_Method__c ='Upload online via link' ;
        in1.From_Month__c ='JAN';
        in1.Document_Type__c ='Form26As';
        in1.To_Month__c ='Feb';
        insert in1;
        
         if(in1.From_Month__c !=null)
        {
          string FromMonth =in1.From_Month__c;
        }
        
        if(in1.Capture_Income_Method__c !=null)
        {
          string CapturedIncomemethod =  in1.Capture_Income_Method__c;
        }
        
         if(in1.Document_Type__c !=null)
        {
         string  DocumentType = in1.Document_Type__c;
        }
        
         if(in1.To_Month__c !=null)
        {
          string ToMonth = in1.To_Month__c;
        }
        else
        {
            string ToMonth = 'Not applicable';
        }
                
        List<Documents__c> dcList = new List<Documents__c>();
        Documents__c dfks2 = new Documents__c();
        dfks2.Applicant__c = applicant.Id;
        dfks2.Opportunity_Relation__c = opfv1.Id;
        dfks2.KYC_name__c = 'Aadhar';
        dfks2.Document_Side__c ='Back';
        dfks2.Aadhar_Source__c = 'ScanAadhar';
        dfks2.Name = 'Aadhar';
        dfks2.Document_Type__c = system.label.AadhaarCard;
        dfks2.Current_Residential_Address_Proof__c = true;
        //dfks2.KYC_No__c = 'test';
      //  dfks2.KYC_District__c = 'Nellore';
        insert dfks2;
        dcList.add(dfks2);
     
        
     //   Applicant__c applicant =[select id,name,Application_Form_SMS_Sent__c from Applicant__c];
        applicant.Application_Form_SMS_Sent__c = datetime.newInstance(2014, 9, 15, 12, 30, 0);
        update applicant;
        
         if(applicant.Marital_status__c!=null)
        {
           string MaritalStatus = applicant.Marital_status__c.toLowerCase();
            MaritalStatus = MaritalStatus.capitalize();  
        }
        
        if(applicant.Communication_language__c!=null)
        {
        string CommunicationLan = applicant.Communication_language__c.toLowerCase();
         CommunicationLan =  CommunicationLan.capitalize();
        }
        
         if(applicant.Who_will_repay_the_loan__c==null )
        {
          Applicant__c AppOne=[select Who_will_repay_the_loan__c from Applicant__c where Opportunity__c=:applicant.Opportunity__c and Who_will_repay_the_loan__c!=null and Applicant_Type__c!=:applicant.Applicant_Type__c ];
            string whoWillPay= AppOne.Who_will_repay_the_loan__c;
        }
        else{
            string whoWillPay=applicant.Who_will_repay_the_loan__c;
        }
        
        
        List<Applicant__c> apList = new List<Applicant__c>();
        apList.add(applicant);
            
        PageReference testPage = Page.Ind_ApplicationForm; 
        Test.setCurrentPage(testPage);
        testPage.getParameters().put('Id', String.valueOf(applicant.Id));
        
        Final_Term__c ftv1 = new Final_Term__c();
        ftv1.CRM_IRR__c = 120;
        ftv1.Loan_Application__c = opfv1.Id;
        ftv1.Holiday_period__c='30';
        ftv1.EMI_Amount__c= 10000;
        insert ftv1;
        
        Test.StartTest();
        ApexPages.StandardController sc = new  ApexPages.StandardController(applicant);  
        try{
        IND_ApplicationFormSigning ext = new IND_ApplicationFormSigning();
        ext.getlinkExpired();
        ext.acceptandRender();
        ext.Records = apList;
        ext.FinalTermObj = ftv1;
        ext.lst_document = dcList;
        ext.passportdocument = dfks2;
        ext.document = dcList;
            }catch(Exception e){
            System.debug('e '+e.getMessage());
        }
        Test.StopTest();
    }
    
     @isTest 
    public static void renderasPdfcontrollerTest3()
    {  
        try{
            
        
        Opportunity opfv2  = new Opportunity();
         opfv2.StageName = 'Credit Processing';
       opfv2.CloseDate = Date.newInstance(2021, 1, 11);
       opfv2.Name = 'testone';
       opfv2.Product_Type__c = system.label.PassengerVehicles;
       opfv2.Vehicle_Type__c = system.label.used;
       insert opfv2;
     
       Vehicle_Detail__c vgd1 = new Vehicle_Detail__c();
        vgd1.Loan_Application__c = opfv2.Id;
        vgd1.Base_Price__c = 100000.00;
        vgd1.Ben_Code__c = 'testveh';
        vgd1.Product__c = system.label.TwoWheeler;
        vgd1.Vehicle_type__c = system.label.new;
        insert vgd1; 
        
            Applicant__c applicant2 = new Applicant__c();
        applicant2.Opportunity__c = opfv2.Id;
        applicant2.Contact_number__c = '9743514830';
        applicant2.Applicant_Type__c = 'Borrower';
        applicant2.Who_will_repay_the_loan__c = 'Borrower';
        applicant2.Application_Consent_Received__c = true;
       applicant2.Marital_status__c='	DVRCE';
        applicant2.Communication_language__c = '	BE';

        
        applicant2.Current_Same_As_Permanent__c = true;
        insert applicant2;
     
            List<Documents__c> dcListtt = new List<Documents__c>();
        Documents__c dfks22 = new Documents__c();
        dfks22.Applicant__c = applicant2.Id;
        dfks22.Opportunity_Relation__c = opfv2.Id;
        dfks22.KYC_name__c = 'Aadhar';
        dfks22.Document_Side__c ='Back';
        dfks22.Aadhar_Source__c = 'ScanAadhar';
        dfks22.Name = 'Aadhar';
        dfks22.Document_Type__c = system.label.AadhaarCard;
        dfks22.Current_Residential_Address_Proof__c = true;
        //dfks2.KYC_No__c = 'test';
      //  dfks2.KYC_District__c = 'Nellore';
        insert dfks22;
        dcListtt.add(dfks22);
     
       string currentRecordurl ='1234';
        if(currentRecordurl == applicant2.Application_Consent_OTP__c){
                    system.debug('update link '+false);
           
                }
                else if (currentRecordurl != applicant2.Application_Consent_OTP__c){
                    system.debug('New link '+false);
                    
                }
        
         if(applicant2.Applicant_Type__c == 'Borrower')
         {
             IND_ApplicationFormSigning.createApplicationFormPdf(dfks22.id,system.Label.Insurance_for_borrower,opfv2.id);
             Id DocID = GenericUploadController.createOtherDocument(system.Label.Insurance_for_borrower,vgd1.Id,applicant2.id , applicant2.Opportunity__c);
			// IND_ApplicationFormSigning.createApplicationFormBorrowerPdf(DocID);
         }
          else
          {
              system.debug('ttt');
          }

        
       Opportunity opfv1 = new Opportunity();
       opfv1.StageName = 'Credit Processing';
       opfv1.CloseDate = Date.newInstance(2021, 1, 11);
       opfv1.Name = 'testone';
       insert opfv1;
        
         Income_Details__c in3 = TestDataUtility.createTestIncomeDetails(false);
        in3.Applicant__c = applicant2.id;
        in3.Salaried_Self_employed__c = 'Salaried';
        in3.Office_State__c = 'MAHARASHTRA';
        in3.From_Month__c ='JAN';
     
        insert in3;
        
            if(in3.To_Month__c !=null)
        {
          string ToMonth = in3.To_Month__c;
        }
        else
        {
            string ToMonth = 'Not applicable';
        }
        
        Applicant__c applicant = new Applicant__c();
        applicant.Opportunity__c = opfv1.Id;
        applicant.Contact_number__c = '9743514830';
        applicant.Applicant_Type__c = 'Borrower';
        applicant.Who_will_repay_the_loan__c = 'Borrower';
        applicant.Application_Consent_Received__c = true;
        insert applicant;
                
        List<Documents__c> dcList = new List<Documents__c>();
        Documents__c dfks2 = new Documents__c();
        dfks2.Applicant__c = applicant.Id;
        dfks2.Opportunity_Relation__c = opfv1.Id;
        dfks2.KYC_name__c = 'Aadhar';
        dfks2.Document_Side__c ='Back';
        dfks2.Aadhar_Source__c = 'ScanAadhar';
        dfks2.Name = 'Aadhar';
        dfks2.Document_Type__c = system.label.PanCard;
        dfks2.PAN_No__c = 'AFENY7645N';
      //  dfks2.Current_Residential_Address_Proof__c = true;
        dfks2.Permanent_Residential_Address_Proof__c = true;
        dfks2.KYC_District__c = 'Nellore';
        insert dfks2;
        dcList.add(dfks2);
     
        
     //   Applicant__c applicant =[select id,name,Application_Form_SMS_Sent__c from Applicant__c];
        applicant.Application_Form_SMS_Sent__c = datetime.newInstance(2014, 9, 15, 12, 30, 0);
        update applicant;
        
        List<Applicant__c> apList = new List<Applicant__c>();
        apList.add(applicant);
            
        PageReference testPage = Page.Ind_ApplicationForm; 
        Test.setCurrentPage(testPage);
        testPage.getParameters().put('Id', String.valueOf(applicant.Id));
        
        Final_Term__c ftv1 = new Final_Term__c();
        ftv1.CRM_IRR__c = 120;
        ftv1.Loan_Application__c = opfv1.Id;
        ftv1.Holiday_period__c='30';
        ftv1.EMI_Amount__c= 10000;
        insert ftv1;
        
        Test.StartTest();
        ApexPages.StandardController sc = new  ApexPages.StandardController(applicant);
        try{
            
            IND_ApplicationFormSigning ext = new IND_ApplicationFormSigning();
            //IND_ApplicationFormSigning.createApplicationFormBorrowerPdf( dfks2.id);
            ext.getlinkExpired();
            ext.acceptandRender();
            ext.Records = apList;
            ext.FinalTermObj = ftv1;
            ext.lst_document = dcList;
            ext.passportdocument = dfks2;
            ext.document = dcList;
        }catch(Exception e){
            System.debug('e '+e.getMessage());
        }
        Test.StopTest();
        }
        catch(Exception e){
            System.debug('e '+e.getMessage());
        
        } 
    }
    
     @isTest 
    public static void renderasPdfcontrollerTest4()
    {
       Opportunity opfv1 = new Opportunity();
       opfv1.StageName = 'Credit Processing';
       opfv1.CloseDate = Date.newInstance(2021, 1, 11);
       opfv1.Name = 'testone';
       insert opfv1;
        
        Applicant__c applicant = new Applicant__c();
        applicant.Opportunity__c = opfv1.Id;
        applicant.Contact_number__c = '9743514830';
        applicant.Applicant_Type__c = 'Borrower';
        applicant.Who_will_repay_the_loan__c = 'Borrower';
        applicant.Application_Consent_Received__c = true;
        insert applicant;
                
        List<Documents__c> dcList = new List<Documents__c>();
        Documents__c dfks2 = new Documents__c();
        dfks2.Applicant__c = applicant.Id;
        dfks2.Opportunity_Relation__c = opfv1.Id;
        dfks2.KYC_name__c = 'Aadhar';
        dfks2.Document_Side__c ='Back';
        dfks2.Aadhar_Source__c = 'ScanAadhar';
        dfks2.Name = 'Aadhar';
        dfks2.Document_Type__c = system.label.VoterIdCard;
        //dfks2.KYC_No__c = 'test1234';
     //   dfks2
      //  dfks2.Current_Residential_Address_Proof__c = true;
        dfks2.Permanent_Residential_Address_Proof__c = true;
        insert dfks2;
        dcList.add(dfks2);
     
        
     //   Applicant__c applicant =[select id,name,Application_Form_SMS_Sent__c from Applicant__c];
        applicant.Application_Form_SMS_Sent__c = datetime.newInstance(2014, 9, 15, 12, 30, 0);
        update applicant;
        
        List<Applicant__c> apList = new List<Applicant__c>();
        apList.add(applicant);
            
        PageReference testPage = Page.Ind_ApplicationForm; 
        Test.setCurrentPage(testPage);
        testPage.getParameters().put('Id', String.valueOf(applicant.Id));
        
        Final_Term__c ftv1 = new Final_Term__c();
        ftv1.CRM_IRR__c = 120;
        ftv1.Loan_Application__c = opfv1.Id;
        ftv1.Holiday_period__c='30';
        ftv1.EMI_Amount__c= 10000;
        insert ftv1;
        
        List<Vehicle_Detail__c> vdList = new List<Vehicle_Detail__c>();
        Vehicle_Detail__c vgd1 = new Vehicle_Detail__c();
        vgd1.Loan_Application__c = opfv1.Id;
        vgd1.Base_Price__c = 100000.00;
        vgd1.Ben_Code__c = 'testveh';
        vgd1.Product__c = system.label.PassengerVehicles;
        insert vgd1; 
        vdList.add(vgd1);
        
        Test.StartTest();
        ApexPages.StandardController sc = new  ApexPages.StandardController(applicant);  
        try{
        IND_ApplicationFormSigning ext = new IND_ApplicationFormSigning();
        ext.vehiclelist = vdList;
        ext.getlinkExpired();
        ext.acceptandRender();
        ext.voterIddocument = dfks2;
            }catch(Exception e){
            System.debug('e '+e.getMessage());
        }
        Test.StopTest();
    }
    
     @isTest 
    public static void renderasPdfcontrollerTest5()
    {
       Opportunity opfv1 = new Opportunity();
       opfv1.StageName = 'Credit Processing';
       opfv1.CloseDate = Date.newInstance(2021, 1, 11);
       opfv1.Name = 'testone';
       insert opfv1;
        
        Applicant__c applicant = new Applicant__c();
        applicant.Opportunity__c = opfv1.Id;
        applicant.Contact_number__c = '9743514830';
        applicant.Applicant_Type__c = 'Borrower';
        applicant.Who_will_repay_the_loan__c = 'Borrower';
        applicant.Application_Consent_Received__c = true;
        insert applicant;
                
        List<Documents__c> dcList = new List<Documents__c>();
        Documents__c dfks2 = new Documents__c();
        dfks2.Applicant__c = applicant.Id;
        dfks2.Opportunity_Relation__c = opfv1.Id;
        dfks2.KYC_name__c = 'Aadhar';
        dfks2.Document_Side__c ='Back';
        dfks2.Aadhar_Source__c = 'ScanAadhar';
        dfks2.Name = 'Aadhar';
        dfks2.Document_Type__c = system.label.DrivingLicences;
      //  dfks2.Current_Residential_Address_Proof__c = true;
        dfks2.Permanent_Residential_Address_Proof__c = true;
        //dfks2.KYC_No__c = 'samres';
        insert dfks2;
        dcList.add(dfks2);
     
        
     //   Applicant__c applicant =[select id,name,Application_Form_SMS_Sent__c from Applicant__c];
        applicant.Application_Form_SMS_Sent__c = datetime.newInstance(2014, 9, 15, 12, 30, 0);
        update applicant;
        
        List<Applicant__c> apList = new List<Applicant__c>();
        apList.add(applicant);
            
        PageReference testPage = Page.Ind_ApplicationForm; 
        Test.setCurrentPage(testPage);
        testPage.getParameters().put('Id', String.valueOf(applicant.Id));
        
        Final_Term__c ftv1 = new Final_Term__c();
        ftv1.CRM_IRR__c = 120;
        ftv1.Loan_Application__c = opfv1.Id;
        ftv1.Holiday_period__c='30';
        ftv1.EMI_Amount__c= 10000;
        insert ftv1;
        
        Vehicle_Detail__c vgd1 = new Vehicle_Detail__c();
        vgd1.Loan_Application__c = opfv1.Id;
        vgd1.Base_Price__c = 100000.00;
        vgd1.Ben_Code__c = 'testveh';
        vgd1.Product__c = system.label.TwoWheeler;
        insert vgd1; 
        
        Test.StartTest();
        ApexPages.StandardController sc = new  ApexPages.StandardController(applicant); 
        try{
        IND_ApplicationFormSigning ext = new IND_ApplicationFormSigning();
        ext.getlinkExpired();
        ext.acceptandRender();
        ext.voterIddocument = dfks2;
        ext.currentResDocumentList = dcList;
        ext.permanentResDocumentList = dcList;
            }catch(Exception e){
            System.debug('e '+e.getMessage());
        }
        Test.StopTest();
    }
    
     @isTest 
    public static void renderasPdfcontrollerTest6()
    {
       Opportunity opfv1 = new Opportunity();
       opfv1.StageName = 'Credit Processing';
       opfv1.CloseDate = Date.newInstance(2021, 1, 11);
       opfv1.Name = 'testone';
       opfv1.Vehicle_Type__c = system.label.New;
       insert opfv1;
        
        Applicant__c applicant = new Applicant__c();
        applicant.Opportunity__c = opfv1.Id;
        applicant.Contact_number__c = '9743514830';
        applicant.Applicant_Type__c = 'Co-borrower';
        applicant.Who_will_repay_the_loan__c = 'Co-borrower';
        applicant.Relationship_with_borrower__c ='MATERNAL GRANDMOTHER';
        applicant.Application_Consent_Received__c = true;
        insert applicant;
        
        
           if(applicant.Applicant_Type__c == 'Co-borrower')
        {
          string  RelationShipWithBorrower = applicant.Relationship_with_borrower__c.toLowerCase(); 
            RelationShipWithBorrower = RelationShipWithBorrower.capitalize();
        }
                
        List<Documents__c> dcList = new List<Documents__c>();
        Documents__c dfks2 = new Documents__c();
        dfks2.Applicant__c = applicant.Id;
        dfks2.Opportunity_Relation__c = opfv1.Id;
        dfks2.KYC_name__c = 'Aadhar';
        dfks2.Document_Side__c ='Back';
        dfks2.Aadhar_Source__c = 'ScanAadhar';
        dfks2.Name = 'Aadhar';
        dfks2.Document_Type__c = system.label.DrivingLicences;
      //  dfks2.Current_Residential_Address_Proof__c = true;
        dfks2.Permanent_Residential_Address_Proof__c = true;
        dfks2.Proof_of_Identity_POI__c = true;
     //   dfks2.Passport_No__c = 'A22570';
        insert dfks2;
        dcList.add(dfks2);
     
        
     //   Applicant__c applicant =[select id,name,Application_Form_SMS_Sent__c from Applicant__c];
        applicant.Application_Form_SMS_Sent__c = datetime.newInstance(2014, 9, 15, 12, 30, 0);
        update applicant;
        
        List<Applicant__c> apList = new List<Applicant__c>();
        apList.add(applicant);
            
        PageReference testPage = Page.Ind_ApplicationForm; 
        Test.setCurrentPage(testPage);
        testPage.getParameters().put('Id', String.valueOf(applicant.Id));
        
        Final_Term__c ftv1 = new Final_Term__c();
        ftv1.CRM_IRR__c = 120;
        ftv1.Loan_Application__c = opfv1.Id;
        ftv1.Holiday_period__c='30';
        ftv1.Required_CRM_IRR__c ='23455';
        ftv1.EMI_Amount__c= 10000;
        insert ftv1;
        
          if(ftv1.Required_CRM_IRR__c!=null)
        {    
          string RequiredROI= ftv1.Required_CRM_IRR__c +' %';  
        }  
       
        if(ftv1.Tenure__c!=null)
        {
            string RequiredTenure = ftv1.Tenure__c +' Months';
        }
       if(ftv1.OfferengineMaxTenure__c!=null)
       {
             string MaximumAvailableTenure =  ftv1.OfferengineMaxTenure__c+ ' Months';
       }
        
        Vehicle_Detail__c vgd1 = new Vehicle_Detail__c();
        vgd1.Loan_Application__c = opfv1.Id;
        vgd1.Base_Price__c = 100000.00;
        vgd1.Ben_Code__c = 'testveh';
        vgd1.Product__c = system.label.TwoWheeler;
        insert vgd1; 
        
        Test.StartTest();
        ApexPages.StandardController sc = new  ApexPages.StandardController(applicant); 
        try{
        IND_ApplicationFormSigning ext = new IND_ApplicationFormSigning();
        ext.getlinkExpired();
        ext.acceptandRender();
        ext.voterIddocument = dfks2;
        ext.currentResDocumentList = dcList;
        ext.permanentResDocumentList = dcList;
            }catch(Exception e){
            System.debug('e '+e.getMessage());
        }
        Test.StopTest();
    }
    
     @isTest 
    public static void renderasPdfcontrollerTest7()
    {
        try 
        {
            
        
       Opportunity opfv1 = new Opportunity();
       opfv1.StageName = 'Credit Processing';
       opfv1.CloseDate = Date.newInstance(2021, 1, 11);
       opfv1.Name = 'testone';
       opfv1.Vehicle_Type__c = system.label.New;
       insert opfv1;
        
        Applicant__c applicant = new Applicant__c();
        applicant.Opportunity__c = opfv1.Id;
        applicant.Contact_number__c = '9743514830';
        applicant.Applicant_Type__c = 'Borrower';
        applicant.Application_Consent_Received__c = true;
        insert applicant;
        
        Applicant__c applicanttHree = new Applicant__c();
        applicanttHree.Opportunity__c = opfv1.Id;
        applicanttHree.Contact_number__c = '9743514830';
        applicanttHree.Applicant_Type__c = 'Co-borrower';
        applicanttHree.Who_will_repay_the_loan__c ='Co-borrower';
        applicanttHree.Application_Consent_Received__c = true;
        insert applicanttHree;
        
        if(applicant.Who_will_repay_the_loan__c==null )
        {
          Applicant__c AppOne=[select Who_will_repay_the_loan__c from Applicant__c where Opportunity__c=:applicant.Opportunity__c and Who_will_repay_the_loan__c!=null and Applicant_Type__c!=:applicant.Applicant_Type__c ];
            string whoWillPay= AppOne.Who_will_repay_the_loan__c;
        }
                
        List<Documents__c> dcList = new List<Documents__c>();
        Documents__c dfks2 = new Documents__c();
        dfks2.Applicant__c = applicant.Id;
        dfks2.Opportunity_Relation__c = opfv1.Id;
        dfks2.KYC_name__c = 'Aadhar';
        dfks2.Document_Side__c ='Back';
        dfks2.Aadhar_Source__c = 'ScanAadhar';
        dfks2.Name = 'Aadhar';
        dfks2.Document_Type__c = system.label.DrivingLicences;
      //  dfks2.Current_Residential_Address_Proof__c = true;
        dfks2.Permanent_Residential_Address_Proof__c = true;
        dfks2.Proof_of_Identity_POI__c = true;
     //   dfks2.Passport_No__c = 'A22570';
        insert dfks2;
        dcList.add(dfks2);
     
        
     //   Applicant__c applicant =[select id,name,Application_Form_SMS_Sent__c from Applicant__c];
        applicant.Application_Form_SMS_Sent__c = datetime.newInstance(2014, 9, 15, 12, 30, 0);
        update applicant;
        
        List<Applicant__c> apList = new List<Applicant__c>();
        apList.add(applicant);
            
        PageReference testPage = Page.Ind_ApplicationForm; 
        Test.setCurrentPage(testPage);
        testPage.getParameters().put('Id', String.valueOf(applicant.Id));
        
        Final_Term__c ftv1 = new Final_Term__c();
        ftv1.CRM_IRR__c = 120;
        ftv1.Loan_Application__c = opfv1.Id;
        ftv1.Holiday_period__c='30';
        ftv1.EMI_Amount__c= 10000;
        insert ftv1;
        
        Vehicle_Detail__c vgd1 = new Vehicle_Detail__c();
        vgd1.Loan_Application__c = opfv1.Id;
        vgd1.Base_Price__c = 100000.00;
        vgd1.Ben_Code__c = 'testveh';
        vgd1.Product__c = system.label.TwoWheeler;
        vgd1.Vehicle_type__c = system.label.new;
        insert vgd1; 
        
        Income_Details__c in1 = TestDataUtility.createTestIncomeDetails(false);
        in1.Applicant__c = applicant.id;
        in1.Capture_Income_Method__c ='Online via link';
        in1.Salaried_Self_employed__c = 'Salaried';
        in1.Office_State__c = 'MAHARASHTRA';
        insert in1;
        
        
        
        if(applicanttHree.Applicant_Type__c == 'Borrower')
         {
             String DocID = GenericUploadController.createOtherDocument(system.Label.Application_form_borrower,vgd1.Id,applicanttHree.id , applicanttHree.Opportunity__c);
             //IND_ApplicationFormSigning.createApplicationFormBorrowerPdf(DocID);
         }
          else
          {
               System.debug('The test'); 
          }

        if(in1.Capture_Income_Method__c !=null)
        {
          string CapturedIncomemethod = in1.Capture_Income_Method__c;
        }
        else
        {
            string CapturedIncomemethod = 'Not applicable';
        }
        
        
        InsuranceDetails__c ins = new InsuranceDetails__c();
        ins.Name = 'iName';
        ins.Loan_Application__c = opfv1.Id;
        ins.Total_insurance_payable__c = 10000;
        ins.Applicant__c = applicant.id;
        insert ins;
        
        Test.StartTest();
        ApexPages.StandardController sc = new  ApexPages.StandardController(applicant);   
        try{
        IND_ApplicationFormSigning ext = new IND_ApplicationFormSigning();
           //IND_ApplicationFormSigning.createApplicationFormCoBorrowerPdf( dfks2.id); 
        ext.getlinkExpired();
        ext.acceptandRender();
        ext.voterIddocument = dfks2;
        ext.currentResDocumentList = dcList;
        ext.permanentResDocumentList = dcList;
            }catch(Exception e){
            System.debug('e '+e.getMessage());
        }
        Test.StopTest();
        }
        catch(Exception e){
            System.debug('e '+e.getMessage());
        
    }
    }
   
}