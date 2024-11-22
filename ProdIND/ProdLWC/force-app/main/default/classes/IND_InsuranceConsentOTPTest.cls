@isTest
public with sharing class IND_InsuranceConsentOTPTest {

    public static Documents__c getDoc = new Documents__c();
   @testSetup static void setup()
   {
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
       applicant.Applicant_Type__c='Borrower';
        applicant.Insurance_consent_sent_on__c = System.now();
        applicant.Insurance_Consent_Received__c = true;
        insert applicant;
            
       
       
       
       InsuranceDetails__c Details = new InsuranceDetails__c();
       Details.Name = 'Test Two';
       Details.Applicant__c= applicant.id;
       Details.Loan_Application__c =oppobj.id;
       Details.Amount__c= 3333.00;
       insert Details;
       
       
        Documents__c getDoc = TestDataUtility.createTestDocumentITR(false, applicant, oppObj);
        getDoc.Applicant__c = applicant.id;
        getDoc.Addresss_Type__c = 'Current Residential Address';
        insert getDoc;
       
        Vehicle_Detail__c veh = TestDataUtility.createTestVehicleDetailForMFCValuation(true, oppObj);

   }
    
      @isTest 
    public static void renderasPdfcontrollerTest()
    {
        try
        {
            Applicant__c applicant =[select id,name,Application_Form_SMS_Sent__c from Applicant__c];
        
        List<Applicant__c> apList = new List<Applicant__c>();
        apList.add(applicant);
            
        PageReference testPage = Page.Ind_ApplicationForm; 
        Test.setCurrentPage(testPage);
        testPage.getParameters().put('Id', String.valueOf(applicant.Id)); 
        Test.StartTest();
        ApexPages.StandardController sc = new  ApexPages.StandardController(applicant);     
        IND_InsuranceConsentOTP ext = new IND_InsuranceConsentOTP();
        ext.getlinkExpired();
        ext.acceptandRender();
        
        
        //ext.Records = apList;
        Test.StopTest();  
        }
        catch (exception e){
           
        }
      
     
      
    }
 @isTest 
 public static void renderasPdfcontrollerTestOne ()
        {
             Account accobjOne = new Account();
        accobjOne.Name = 'testname';
        accobjOne.State__c = 'ASSAM';
        accobjOne.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business Account').getRecordTypeId();
        insert accobjOne;
       
      Opportunity opfv1 = new Opportunity();
       opfv1.StageName = 'Credit Processing';
       opfv1.CloseDate = Date.newInstance(2021, 1, 11);
       opfv1.Name = 'testone';
       opfv1.Vehicle_Type__c = system.label.New;
       insert opfv1;
                   Vehicle_Detail__c vehrr = TestDataUtility.createTestVehicleDetailForMFCValuation(true, opfv1);
            
         Applicant__c applicantTwo = TestDataUtility.createTestApplicant(false);
        applicantTwo.Opportunity__c = opfv1.Id;
       applicantTwo.Applicant_Type__c='Borrower';
        applicantTwo.Insurance_consent_sent_on__c = System.now();
        applicantTwo.Insurance_Consent_Received__c = true;
        insert applicantTwo;
            try
            {
                  Test.startTest();
                string label;
                  if(applicantTwo.Applicant_Type__c == 'Borrower')
            {
                Label =system.Label.Insurance_for_borrower;
            }
            string DocID = GenericUploadController.createOtherDocument(Label,vehrr.id,applicantTwo.id ,applicantTwo.id);
              IND_InsuranceConsentOTP.createInsuranceFormPdf(getDoc.id,Label,applicantTwo.Opportunity__c); 
           Test.stopTest();
            }
             catch (exception e){  
        }
        }
    
            
    @isTest  
    public static void renderasPdfcontrollerTestTwo()
    {
        try{

           Account accobjTwo = new Account();
        accobjTwo.Name = 'testname';
        accobjTwo.State__c = 'ASSAM';
        accobjTwo.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business Account').getRecordTypeId();
        insert accobjTwo;
       
        Opportunity opfv2 = new Opportunity();
       opfv2.StageName = 'Credit Processing';
       opfv2.CloseDate = Date.newInstance(2021, 1, 11);
       opfv2.Name = 'testoneTwo';
        opfv2.Lead_number__c = '77777';
       opfv2.Vehicle_Type__c = system.label.New;
       insert opfv2;
        
       Applicant__c applicantTwo = TestDataUtility.createTestApplicant(false);
        applicantTwo.Opportunity__c = opfv2.Id;
       applicantTwo.Applicant_Type__c='Co-borrower';
        applicantTwo.Insurance_consent_sent_on__c = System.now();
        applicantTwo.Insurance_Consent_Received__c = true;
        insert applicantTwo;
        
        List<Applicant__c> apList = new List<Applicant__c>();
        apList.add(applicantTwo);
            
             string Labelll =system.Label.Insurance_for_borrower;
            
        IND_InsuranceConsentOTP.createInsuranceFormPdf(getDoc.id,Labelll,opfv2.id); 
            
        PageReference testPage = Page.Ind_ApplicationForm; 
        Test.setCurrentPage(testPage);
        testPage.getParameters().put('Id', String.valueOf(applicantTwo.Id)); 
        Test.StartTest();
        ApexPages.StandardController sc = new  ApexPages.StandardController(applicantTwo);     
        IND_InsuranceConsentOTP ext = new IND_InsuranceConsentOTP();
        ext.getlinkExpired();
        PageReference pageRef = new PageReference('/apex/InsuranceConsentThanksMessage');
        pageRef= ext.acceptandRender();
        
        //ext.Records = apList;
        Test.StopTest();  
        
    }
        catch (exception e){  
        }
        }
    

    
    
    @isTest  
    public static void renderasPdfcontrollerTestThree()
    {
        Opportunity opfv1 = new Opportunity();
       opfv1.StageName = 'Credit Processing';
       opfv1.CloseDate = Date.newInstance(2021, 1, 11);
       opfv1.Name = 'testone';
       opfv1.Vehicle_Type__c = system.label.New;
       insert opfv1;
        
        Applicant__c applicantTree = new Applicant__c();
        applicantTree.Opportunity__c = opfv1.Id;
        applicantTree.Contact_number__c = '9743514830';
        applicantTree.Applicant_Type__c = 'Borrower';
        applicantTree.Who_will_repay_the_loan__c = 'Borrower';
        applicantTree.Insurance_Consent_Received__c = true;
        applicantTree.Insurance_Consent_OTP_Time__c=Date.newInstance(2021, 1, 11);
        applicantTree.Insurance_Consent_OTP__c='2345';
        insert applicantTree;
                
        List<Documents__c> dcList = new List<Documents__c>();
        Documents__c dfks2 = new Documents__c();
        dfks2.Applicant__c = applicantTree.Id;
        dfks2.Opportunity_Relation__c = opfv1.Id;
        dfks2.KYC_name__c = 'Aadhar';
        dfks2.Document_Side__c ='Back';
        dfks2.Aadhar_Source__c = 'ScanAadhar';
        dfks2.Name = 'Aadhar';
        dfks2.Document_Type__c = '36';
      //  dfks2.Current_Residential_Address_Proof__c = true;
        dfks2.Permanent_Residential_Address_Proof__c = true;
        dfks2.Proof_of_Identity_POI__c = true;
     //   dfks2.Passport_No__c = 'A22570';
        insert dfks2;
        dcList.add(dfks2);
     
        
     //   Applicant__c applicant =[select id,name,Application_Form_SMS_Sent__c from Applicant__c];
        applicantTree.Application_Form_SMS_Sent__c = datetime.newInstance(2014, 9, 15, 12, 30, 0);
        update applicantTree;
        
        List<Applicant__c> apList = new List<Applicant__c>();
        apList.add(applicantTree);
            
        PageReference testPage = Page.Ind_ApplicationForm; 
        Test.setCurrentPage(testPage);
        testPage.getParameters().put('Id', String.valueOf(applicantTree.Id));
        
        Vehicle_Detail__c vgd1 = new Vehicle_Detail__c();
        vgd1.Loan_Application__c = opfv1.Id;
        vgd1.Base_Price__c = 100000.00;
        vgd1.Ben_Code__c = 'testveh';
        vgd1.Product__c = system.label.TwoWheeler;
        vgd1.Vehicle_type__c = system.label.new;
        insert vgd1; 
        

        
        InsuranceDetails__c ins = new InsuranceDetails__c();
        ins.Name = 'iName';
        ins.Loan_Application__c = opfv1.Id;
        ins.Total_insurance_payable__c = 10000;
        ins.Applicant__c = applicantTree.id;
        insert ins;
        
        Test.StartTest();
         if(applicantTree.Insurance_Consent_OTP_Time__c!=null)
         {
                Long consentSentOnDate = applicantTree.Insurance_Consent_OTP_Time__c.getTime();
           Long currentDateTime = DateTime.now().getTime();
                 Long difference = (currentDateTime-consentSentOnDate)/60000;                
            if(difference > 4320){                
                system.debug('it is '+true);
            }
             else
             {
                  system.debug('it is '+true); 
             }
         }
        string currentRecordurl ='1234';
        if(currentRecordurl == applicantTree.Insurance_Consent_OTP__c){
                    system.debug('update link '+false);
           
                }
                else if (currentRecordurl != applicantTree.Insurance_Consent_OTP__c){
                    system.debug('New link '+false);
                    
                }
      
        
        ApexPages.StandardController sc = new  ApexPages.StandardController(applicantTree);   
        try{
        IND_InsuranceConsentOTP ext = new IND_InsuranceConsentOTP();
        ext.getlinkExpired();
        ext.acceptandRender();
       
            }catch(Exception e){
            System.debug('e '+e.getMessage());
        }
        Test.StopTest();
    }
    
    @isTest
      public static void renderasPdfcontrollerTestFour()
    {
        
        try{
            
        
        Opportunity opfv1 = new Opportunity();
       opfv1.StageName = 'Credit Processing';
       opfv1.CloseDate = Date.newInstance(2021, 1, 11);
       opfv1.Name = 'testone';
       opfv1.Vehicle_Type__c = system.label.New;
       insert opfv1;
        
        Applicant__c applicantFor = new Applicant__c();
        applicantFor.Opportunity__c = opfv1.Id;
        applicantFor.Contact_number__c = '9743514830';
        applicantFor.Applicant_Type__c = 'Co-borrower';
        applicantFor.Who_will_repay_the_loan__c = 'Co-borrower';
        applicantFor.Insurance_Consent_Received__c = true;
        applicantFor.Insurance_Consent_OTP_Time__c=Date.newInstance(2021, 1, 11);
        applicantFor.Insurance_Consent_OTP__c='2345';
        insert applicantFor;
                
        List<Documents__c> dcList = new List<Documents__c>();
        Documents__c dfks2 = new Documents__c();
        dfks2.Applicant__c = applicantFor.Id;
        dfks2.Opportunity_Relation__c = opfv1.Id;
        dfks2.KYC_name__c = 'Aadhar';
        dfks2.Document_Side__c ='Back';
        dfks2.Aadhar_Source__c = 'ScanAadhar';
        dfks2.Name = 'Aadhar';
        dfks2.Document_Type__c = 'Driving Licence';
      //  dfks2.Current_Residential_Address_Proof__c = true;
        dfks2.Permanent_Residential_Address_Proof__c = true;
        dfks2.Proof_of_Identity_POI__c = true;
     //   dfks2.Passport_No__c = 'A22570';
        insert dfks2;
        dcList.add(dfks2);
     
        
     //   Applicant__c applicant =[select id,name,Application_Form_SMS_Sent__c from Applicant__c];
        applicantFor.Application_Form_SMS_Sent__c = datetime.newInstance(2014, 9, 15, 12, 30, 0);
        update applicantFor;
        
        List<Applicant__c> apList = new List<Applicant__c>();
        apList.add(applicantFor);
            
        PageReference testPage = Page.Ind_ApplicationForm; 
        Test.setCurrentPage(testPage);
        testPage.getParameters().put('Id', String.valueOf(applicantFor.Id));
        
        Vehicle_Detail__c vgd1 = new Vehicle_Detail__c();
        vgd1.Loan_Application__c = opfv1.Id;
        vgd1.Base_Price__c = 100000.00;
        vgd1.Ben_Code__c = 'testveh';
        vgd1.Product__c = system.label.TwoWheeler;
        vgd1.Vehicle_type__c = system.label.new;
        insert vgd1; 
        

        
        InsuranceDetails__c ins = new InsuranceDetails__c();
        ins.Name = 'iName';
        ins.Loan_Application__c = opfv1.Id;
        ins.Total_insurance_payable__c = 10000;
        ins.Applicant__c = applicantFor.id;
        insert ins;
        
        Test.StartTest();
         if(applicantFor.Insurance_Consent_OTP_Time__c!=null)
         {
                Long consentSentOnDate = applicantFor.Insurance_Consent_OTP_Time__c.getTime();
           Long currentDateTime = DateTime.now().getTime();
                 Long difference = (currentDateTime-consentSentOnDate)/60000;                
            if(difference > 4320){                
                system.debug('it is '+true);
            }
             else
             {
                  system.debug('it is '+true); 
             }
         }
        string currentRecordurl ='1234';
        if(currentRecordurl == applicantFor.Insurance_Consent_OTP__c){
                    system.debug('update link '+false);
           
                }
                else if (currentRecordurl != applicantFor.Insurance_Consent_OTP__c){
                    system.debug('New link '+false);
                    
                }
        
         if(applicantFor.Applicant_Type__c == 'Borrower')
         {
             Id DocID = GenericUploadController.createOtherDocument(system.Label.Insurance_for_borrower,vgd1.Id,applicantFor.id , applicantFor.Opportunity__c);
             //createInsuranceFormBorrowerPdf(DocID);
         }
          else
          {
              system.debug('ttt');
          }
      
        
        ApexPages.StandardController sc = new  ApexPages.StandardController(applicantFor);   
        try{
        IND_InsuranceConsentOTP ext = new IND_InsuranceConsentOTP();
        ext.getlinkExpired();
        ext.acceptandRender();
       
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
      public static void renderasPdfcontrollerTestFive()
    {
        
        try{
            
        
        Opportunity opfv1 = new Opportunity();
       opfv1.StageName = 'Credit Processing';
       opfv1.CloseDate = Date.newInstance(2021, 1, 11);
       opfv1.Name = 'testone';
       opfv1.Vehicle_Type__c = system.label.New;
       insert opfv1;
        
        Applicant__c applicantFor = new Applicant__c();
        applicantFor.Opportunity__c = opfv1.Id;
        applicantFor.Contact_number__c = '9743514830';
        applicantFor.Applicant_Type__c = 'Co-borrower';
        applicantFor.Who_will_repay_the_loan__c = 'Co-borrower';
        applicantFor.Insurance_Consent_Received__c = true;
        applicantFor.Insurance_Consent_OTP_Time__c=Date.newInstance(2021, 1, 11);
        applicantFor.Insurance_Consent_OTP__c='2345';
        insert applicantFor;
                
        List<Documents__c> dcList = new List<Documents__c>();
        Documents__c dfks2 = new Documents__c();
        dfks2.Applicant__c = applicantFor.Id;
        dfks2.Opportunity_Relation__c = opfv1.Id;
        dfks2.KYC_name__c = 'Aadhar';
        dfks2.Document_Side__c ='Back';
        dfks2.Aadhar_Source__c = 'ScanAadhar';
        dfks2.Name = 'Aadhar';
        dfks2.Document_Type__c = 'Driving Licence';
      //  dfks2.Current_Residential_Address_Proof__c = true;
        dfks2.Permanent_Residential_Address_Proof__c = true;
        dfks2.Proof_of_Identity_POI__c = true;
     //   dfks2.Passport_No__c = 'A22570';
        insert dfks2;
        dcList.add(dfks2);
     
        
     //   Applicant__c applicant =[select id,name,Application_Form_SMS_Sent__c from Applicant__c];
        applicantFor.Application_Form_SMS_Sent__c = datetime.newInstance(2014, 9, 15, 12, 30, 0);
        update applicantFor;
        
        List<Applicant__c> apList = new List<Applicant__c>();
        apList.add(applicantFor);
            
        PageReference testPage = Page.Ind_ApplicationForm; 
        Test.setCurrentPage(testPage);
        testPage.getParameters().put('Id', String.valueOf(applicantFor.Id));
        
        Vehicle_Detail__c vgd1 = new Vehicle_Detail__c();
        vgd1.Loan_Application__c = opfv1.Id;
        vgd1.Base_Price__c = 100000.00;
        vgd1.Ben_Code__c = 'testveh';
        vgd1.Product__c = system.label.TwoWheeler;
        vgd1.Vehicle_type__c = system.label.new;
        insert vgd1; 
        

        
        InsuranceDetails__c ins = new InsuranceDetails__c();
        ins.Name = 'iName';
        ins.Loan_Application__c = opfv1.Id;
        ins.Total_insurance_payable__c = 10000;
        ins.Applicant__c = applicantFor.id;
        insert ins;
        
        Test.StartTest();
         if(applicantFor.Insurance_Consent_OTP_Time__c!=null)
         {
                Long consentSentOnDate = applicantFor.Insurance_Consent_OTP_Time__c.getTime();
           Long currentDateTime = DateTime.now().getTime();
                 Long difference = (currentDateTime-consentSentOnDate)/60000;
             difference=4578;
            if(difference > 4320){                
                system.debug('it is '+true);
            }
             else
             {
                  string currentRecordurl ='1234';
        if(currentRecordurl == applicantFor.Insurance_Consent_OTP__c){
                    system.debug('update link '+false);
           
                }
                else if (currentRecordurl != applicantFor.Insurance_Consent_OTP__c){
                    system.debug('New link '+false);
                    
                }
        
             }
         }
        string currentRecordurl ='1234';
        if(currentRecordurl == applicantFor.Insurance_Consent_OTP__c){
                    system.debug('update link '+false);
           
                }
                else if (currentRecordurl != applicantFor.Insurance_Consent_OTP__c){
                    system.debug('New link '+false);
                    
                }
        
         if(applicantFor.Applicant_Type__c == 'Borrower')
         {
             Id DocID = GenericUploadController.createOtherDocument(system.Label.Insurance_for_borrower,vgd1.Id,applicantFor.id , applicantFor.Opportunity__c);
             //createInsuranceFormBorrowerPdf(DocID);
         }
          else
          {
              system.debug('ttt');
          }
      
        
        ApexPages.StandardController sc = new  ApexPages.StandardController(applicantFor);   
        try{
            
             //IND_InsuranceConsentOTP.createInsuranceFormCoBorrowerPdf(getDoc.id); 
            
        IND_InsuranceConsentOTP ext = new IND_InsuranceConsentOTP();
        ext.getlinkExpired();
        ext.acceptandRender();
       
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