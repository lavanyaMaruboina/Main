/**
* @description       : This Test Method is basically designed for capturing Income Details of the applicant.
* @author            : Devanshu Gupta
* @group             : 
* @created on		 : 22-11-2021
* @last modified on  : 22-11-2021
* @last modified by  : Devanshu Gupta
* @Version 		  	 : 1.0
**/
@isTest
public class Ind_IncomeDetailsCtrlTest {
    @isTest
    public static void getInputsForIncomeDetailsTest(){
    try{
        Opportunity opp1 = TestDataUtility.createTestOpportunity(false);
        insert opp1;
        
        Applicant__c app1 = TestDataUtility.createTestApplicant(false);
        app1.Opportunity__c= opp1.Id;
        app1.Applicant_Type__c = System.Label.Borrower;
        insert app1;
        
        Documents__c dfk1 = new Documents__c();
        dfk1.Applicant__c = app1.Id;
        dfk1.Opportunity_Relation__c = opp1.Id;
        dfk1.KYC_name__c = 'Aadhar';
        dfk1.Aadhar_Source__c = 'ScanAadhar';
        dfk1.Name = 'Aadhar';
        dfk1.Document_Type__c = 'Aadhaar';
        insert dfk1;
        
        Test.startTest();
              Ind_IncomeDetailsCtrl.getInputsForIncomeDetails(opp1.Id,app1.Applicant_Type__c,app1.Id);
        Test.stopTest();
        
    }catch(Exception e){
          //System.assertEquals('Script-thrown exception', e.getMessage());
    }
    }
    
    @isTest
    public static void getInputsForIncomeDetailsTest1(){
    try{
        Opportunity opp1 = TestDataUtility.createTestOpportunity(false);
        insert opp1;
        
        Applicant__c app1 = TestDataUtility.createTestApplicant(false);
        app1.Opportunity__c= opp1.Id;
        app1.Applicant_Type__c = System.Label.Borrower;
        insert app1;
        
        Documents__c dfk1 = new Documents__c();
        dfk1.Applicant__c = app1.Id;
        dfk1.Opportunity_Relation__c = opp1.Id;
        dfk1.KYC_name__c = 'Aadhar';
        dfk1.Aadhar_Source__c = 'ScanAadhar';
        dfk1.Name = 'Aadhar';
        dfk1.Document_Type__c = 'PAN';
        insert dfk1;
        
        Test.startTest();
              Ind_IncomeDetailsCtrl.getInputsForIncomeDetails(opp1.Id,app1.Applicant_Type__c,app1.Id);
        Test.stopTest();
        
    }catch(Exception e){
          System.assertEquals('Script-thrown exception', e.getMessage());
    }
    }
    
    @isTest
    public static void getInputsForIncomeDetailsTest2(){
    try{
        Opportunity opp1 = TestDataUtility.createTestOpportunity(false);
        insert opp1;
        
        Applicant__c app1 = TestDataUtility.createTestApplicant(false);
        app1.Opportunity__c= opp1.Id;
        app1.Applicant_Type__c = System.Label.Borrower;
        insert app1;
        
        Documents__c dfk1 = new Documents__c();
        dfk1.Applicant__c = app1.Id;
        dfk1.Opportunity_Relation__c = opp1.Id;
        dfk1.KYC_name__c = 'Aadhar';
        dfk1.Aadhar_Source__c = 'ScanAadhar';
        dfk1.Name = 'Aadhar';
        dfk1.Document_Type__c = 'PAN';
        insert dfk1;
        
        Income_Details__c inc1 = TestDataUtility.createTestIncomeDetails(false);
        inc1.Applicant__c = app1.id;
        insert inc1;
        
        Test.startTest();
              Ind_IncomeDetailsCtrl.getInputsForIncomeDetails(opp1.Id,app1.Applicant_Type__c,app1.Id);
        Test.stopTest();
        
    }catch(Exception e){
          System.assertEquals('Script-thrown exception', e.getMessage());
    }
    }
    
      @isTest
    public static void getInputsForIncomeDetailsTest3(){
    try{
        Opportunity opp1 = TestDataUtility.createTestOpportunity(false);
        insert opp1;
        
        Applicant__c app1 = TestDataUtility.createTestApplicant(false);
        app1.Opportunity__c= opp1.Id;
        app1.Applicant_Type__c = System.Label.Borrower;
        insert app1;
        
        Documents__c dfk1 = new Documents__c();
        dfk1.Applicant__c = app1.Id;
        dfk1.Opportunity_Relation__c = opp1.Id;
        dfk1.KYC_name__c = 'Aadhar';
        dfk1.Aadhar_Source__c = 'ScanAadhar';
        dfk1.Name = 'Aadhar';
        dfk1.Document_Type__c = 'PAN';
        insert dfk1;
        
        Income_Details__c inc1 = TestDataUtility.createTestIncomeDetails(false);
        inc1.Applicant__c = app1.id;
        insert inc1;
        
        Test.startTest();
              Ind_IncomeDetailsCtrl.getInputsForIncomeDetails(opp1.Id,app1.Applicant_Type__c,app1.Id);
        Test.stopTest();
        
    }catch(Exception e){
          System.assertEquals('Script-thrown exception', e.getMessage());
    }
    }  @isTest
    public static void getInputsForIncomeDetailsTest4(){
    try{
        Opportunity opp2 = TestDataUtility.createTestOpportunity(false);
        insert opp2;
        
        Test.startTest();
              Ind_IncomeDetailsCtrl.getInputsForIncomeDetails('test1','test','test2');
        Test.stopTest();
        
    }catch(Exception e){
          System.assertEquals('Script-thrown exception', e.getMessage());
    }
    }
    
    
    
    @isTest
    public static void saveIncomeDetailsPositiveTest() { 
        try{
    Opportunity oppObj = TestDataUtility.createTestOpportunity(false);
        insert oppObj;
        Applicant__c applicantObj = TestDataUtility.createTestApplicant(false);
        applicantObj.Opportunity__c= oppObj.Id;
        applicantObj.Applicant_Type__c = System.Label.Borrower;
        insert applicantObj;
            
        
        Income_Details__c incomeObj = TestDataUtility.createTestIncomeDetails(false);
        incomeObj.Applicant__c = applicantObj.id;
        insert incomeObj;
        
        Ind_IncomeDetailsCtrl.IncomeDetailWrapper incomeWrapper = new Ind_IncomeDetailsCtrl.IncomeDetailWrapper();
        incomeWrapper.Id = incomeObj.Id;
        incomeWrapper.Income = 10000.00;
        incomeWrapper.yearOfRegisteration = '2021';
        incomeWrapper.name = 'Test income';
        incomeWrapper.applicantId = applicantObj.id;
        incomeWrapper.areaOfRegistration = 'pune';
        incomeWrapper.bsrOccupation = 'doctor';
        incomeWrapper.gstMetghod = 'Online via link';
        incomeWrapper.incomeMethod = '';
        incomeWrapper.itrMethod = '';
        incomeWrapper.isFileGST = false;
        incomeWrapper.isFileITR = true;
        incomeWrapper.employeeBussinessName = '';
        incomeWrapper.gstNumber = '';
        incomeWrapper.isIncomeSouce = false;
        incomeWrapper.isICAI = false;
        incomeWrapper.isICWAI = false;
        incomeWrapper.isIncomeCreatedInBank = false;
        incomeWrapper.isMCI = false;
        incomeWrapper.isSalaried = false;
        incomeWrapper.isSelfEmployed = false;
        incomeWrapper.isCurrentResidenceCumOffice = false;
        incomeWrapper.legal = '';
        incomeWrapper.nameOfRecipientBank = '';
        incomeWrapper.noOfLoanTakenInPast = '';
        incomeWrapper.uniqueRegistrationNumber = '';
        incomeWrapper.profile = 'Sales';
        incomeWrapper.totalYearsEmploymentBusiness = '5';
        incomeWrapper.currentYearsEmploymentBusiness = '3';
        incomeWrapper.passwordForPdfProtectedStatement = 'test123';
        incomeWrapper.assessmentYear = '1994';
        incomeWrapper.documentType = 'pdf';
        incomeWrapper.bankAccountNumber = '32453218769';
        incomeWrapper.documentReportGenInitiated = true;
         incomeWrapper.incomeSource = 'ITR';   
        incomeWrapper.incomeLastYear = '20000';
        incomeWrapper.iTRLastYearDate = String.valueOf(System.today());
        List<Ind_IncomeDetailsCtrl.IncomeDetailWrapper> incomeWrapperlist = new List<Ind_IncomeDetailsCtrl.IncomeDetailWrapper>();
        incomeWrapperlist.add(incomeWrapper);
       // User userTest = TestDataUtility.createIBCounterStaffUser(true);
      //  system.runAs(userTest){
        Test.startTest();
          Map<String, String> id1 = Ind_IncomeDetailsCtrl.saveIncomeDetails(JSON.serialize(incomeWrapperlist),applicantObj.id, 'true');
          system.assertEquals(id1, Ind_IncomeDetailsCtrl.saveIncomeDetails(JSON.serialize(incomeWrapperlist),applicantObj.id, 'true'));
            Test.stopTest();
        //}
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
            Test.stopTest();
        }
        
        
    }
    
    @isTest
    public static void updateAPICounterAndAccesibilityTest(){
        try{
        Opportunity oppObj = TestDataUtility.createTestOpportunity(false);
        insert oppObj;
            
        Applicant__c applicantObj = TestDataUtility.createTestApplicant(false);
        applicantObj.Opportunity__c= oppObj.Id;
        applicantObj.Applicant_Type__c = System.Label.Borrower;
        insert applicantObj;
            
        
        Income_Details__c incomeObj = TestDataUtility.createTestIncomeDetails(false);
        incomeObj.Applicant__c = applicantObj.id;
        incomeObj.GST_API_Count__c = 1;
        incomeObj.Is_GST_Assessed__c = true;
        incomeObj.ITR_API_Count__c = 1;
        incomeObj.Is_ITR_Assessed__c = true;
        incomeObj.Bank_details_API_Count__c = 1;
        incomeObj.set_is_Bank_Details_Assessed__c = true;
        insert incomeObj;
            
        Test.startTest();
             Ind_IncomeDetailsCtrl.updateAPICounterAndAccesibility(incomeObj.Id,System.Label.GST,1,incomeObj.Is_GST_Assessed__c);
             Ind_IncomeDetailsCtrl.updateAPICounterAndAccesibility(incomeObj.Id,System.Label.ITR,1,incomeObj.Is_ITR_Assessed__c);
             Ind_IncomeDetailsCtrl.updateAPICounterAndAccesibility(incomeObj.Id,System.Label.BANK_STATEMENT,1,incomeObj.set_is_Bank_Details_Assessed__c);
             Ind_IncomeDetailsCtrl.updateAPICounterAndAccesibility(incomeObj.Id,'GSTUpload',1,incomeObj.set_is_Bank_Details_Assessed__c);
             Ind_IncomeDetailsCtrl.updateAPICounterAndAccesibility(incomeObj.Id,'ITRUpload',1,incomeObj.set_is_Bank_Details_Assessed__c);
             Ind_IncomeDetailsCtrl.updateAPICounterAndAccesibility(incomeObj.Id,'BSUpload',1,incomeObj.set_is_Bank_Details_Assessed__c);
             Ind_IncomeDetailsCtrl.updateAPICounterAndAccesibility('test','test',1,true);
        Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void getProfileTest(){
        try{
            Profile_Master__c pm1 = new Profile_Master__c();
            pm1.Category__c = 'SAL';
            pm1.Code__c = '115';
            pm1.OwnerId = UserInfo.getUserId();
            pm1.Name = 'test';
            insert pm1;
            
            Test.startTest();
                  Ind_IncomeDetailsCtrl.getProfile(pm1.Category__c);
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void getProfileTest1(){
        try{
            Profile_Master__c pm1 = new Profile_Master__c();
            pm1.Category__c = 'NE';
            pm1.Code__c = '115';
            pm1.OwnerId = UserInfo.getUserId();
            pm1.Name = 'test';
            insert pm1;
            
            Test.startTest();
                  Ind_IncomeDetailsCtrl.getProfile(pm1.Category__c);
                  Ind_IncomeDetailsCtrl.getProfile(null);
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void getAssessmentYearTest(){
        try{
            Ind_IncomeDetailsCtrl.getAssessmentYear('1994');
            Ind_IncomeDetailsCtrl.getAssessmentYear(null);
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
        
    }
    
    @isTest
    public static void getAPIEligibilityTest(){
        try{
        Opportunity oppObj = TestDataUtility.createTestOpportunity(false);
        insert oppObj;
            
        Applicant__c applicantObj = TestDataUtility.createTestApplicant(false);
        applicantObj.Opportunity__c= oppObj.Id;
        applicantObj.Applicant_Type__c = System.Label.Borrower;
        insert applicantObj;
            
        
        Income_Details__c incomeObj = TestDataUtility.createTestIncomeDetails(false);
        incomeObj.Applicant__c = applicantObj.id;
        insert incomeObj;
            
        Ind_IncomeDetailsCtrl.IncomeEligibilityWrapper ew1 = new Ind_IncomeDetailsCtrl.IncomeEligibilityWrapper();
        ew1.incomeDetailId = incomeObj.Id;
        ew1.applicantId = applicantObj.id;
        ew1.gstNumber = '29ABCDE1234F1ZW';
        ew1.accountNumber = '8743214567';
        ew1.apiType = System.Label.GST;
            
        Income_Details__c inc2 = TestDataUtility.createTestIncomeDetails(false);
     //   inc2.Id = ew1.incomeDetailId;
        inc2.Applicant__c = ew1.applicantId;
        inc2.GST_No__c = ew1.gstNumber;
        inc2.Is_GST_Assessed__c = false;
        //inc2.GST_API_Count__c = null;
        insert inc2;
            
        Test.startTest();
               Ind_IncomeDetailsCtrl.getAPIEligibility(json.serialize(ew1));
        Test.stopTest();
            
            
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
     @isTest
    public static void getAPIEligibilityTest11(){
        try{
        Opportunity oppObj = TestDataUtility.createTestOpportunity(false);
        insert oppObj;
            
        Applicant__c applicantObj = TestDataUtility.createTestApplicant(false);
        applicantObj.Opportunity__c= oppObj.Id;
        applicantObj.Applicant_Type__c = System.Label.Borrower;
        insert applicantObj;
            
        
        Income_Details__c incomeObj = TestDataUtility.createTestIncomeDetails(false);
        incomeObj.Applicant__c = applicantObj.id;
        insert incomeObj;
            
        Ind_IncomeDetailsCtrl.IncomeEligibilityWrapper ew1 = new Ind_IncomeDetailsCtrl.IncomeEligibilityWrapper();
        ew1.incomeDetailId = incomeObj.Id;
        ew1.applicantId = applicantObj.id;
        ew1.gstNumber = '';
        ew1.accountNumber = '8743214567';
        ew1.apiType = System.Label.GST;
            
        Income_Details__c inc2 = TestDataUtility.createTestIncomeDetails(false);
     //   inc2.Id = ew1.incomeDetailId;
        inc2.Applicant__c = ew1.applicantId;
        inc2.GST_No__c = ew1.gstNumber;
        inc2.Is_GST_Assessed__c = false;
        //inc2.GST_API_Count__c = null;
        insert inc2;
            
        Test.startTest();
               Ind_IncomeDetailsCtrl.getAPIEligibility(json.serialize(ew1));
        Test.stopTest();
            
            
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void getAPIEligibilityTest1(){
        try{
        Opportunity oppObj = TestDataUtility.createTestOpportunity(false);
        insert oppObj;
            
        Applicant__c applicantObj = TestDataUtility.createTestApplicant(false);
        applicantObj.Opportunity__c= oppObj.Id;
        applicantObj.Applicant_Type__c = System.Label.Borrower;
        insert applicantObj;
            
        
        Income_Details__c incomeObj = TestDataUtility.createTestIncomeDetails(false);
        incomeObj.Applicant__c = applicantObj.id;
        insert incomeObj;
            
        Ind_IncomeDetailsCtrl.IncomeEligibilityWrapper ew1 = new Ind_IncomeDetailsCtrl.IncomeEligibilityWrapper();
        ew1.incomeDetailId = incomeObj.Id;
        ew1.applicantId = applicantObj.id;
        ew1.gstNumber = '29ABCDE1234F1ZW';
        ew1.accountNumber = '8743214567';
        ew1.apiType = System.Label.GST;
            
        Income_Details__c inc2 = TestDataUtility.createTestIncomeDetails(false);
     //   inc2.Id = ew1.incomeDetailId;
        inc2.Applicant__c = ew1.applicantId;
        inc2.GST_No__c = ew1.gstNumber;
        inc2.Is_GST_Assessed__c = true;
        //inc2.GST_API_Count__c = null;
        insert inc2;
            
        Test.startTest();
               Ind_IncomeDetailsCtrl.getAPIEligibility(json.serialize(ew1));
        Test.stopTest();
            
            
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void getAPIEligibilityTest2(){
        try{
        Opportunity oppObj = TestDataUtility.createTestOpportunity(false);
        insert oppObj;
            
        Applicant__c applicantObj = TestDataUtility.createTestApplicant(false);
        applicantObj.Opportunity__c= oppObj.Id;
        applicantObj.Applicant_Type__c = System.Label.Borrower;
        insert applicantObj;
            
        Income_Details__c incomeObj = TestDataUtility.createTestIncomeDetails(false);
        incomeObj.Applicant__c = applicantObj.id;
        insert incomeObj;
            
        Ind_IncomeDetailsCtrl.IncomeEligibilityWrapper ew1 = new Ind_IncomeDetailsCtrl.IncomeEligibilityWrapper();
        ew1.incomeDetailId = incomeObj.Id;
        ew1.applicantId = applicantObj.id;
        ew1.gstNumber = '29ABCDE1234F1ZW';
        ew1.accountNumber = '8743214567';
        ew1.apiType = System.Label.ITR;
            
        Income_Details__c inc2 = TestDataUtility.createTestIncomeDetails(false);
     //   inc2.Id = ew1.incomeDetailId;
        inc2.Applicant__c = ew1.applicantId;
        inc2.GST_No__c = ew1.gstNumber;
        insert inc2;
            
        Test.startTest();
               Ind_IncomeDetailsCtrl.getAPIEligibility(json.serialize(ew1));
        Test.stopTest();
            
            
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void getAPIEligibilityTest3(){
        try{
        Opportunity oppObj = TestDataUtility.createTestOpportunity(false);
        insert oppObj;
            
        Applicant__c applicantObj = TestDataUtility.createTestApplicant(false);
        applicantObj.Opportunity__c= oppObj.Id;
        applicantObj.Applicant_Type__c = System.Label.Borrower;
        insert applicantObj;
            
        Income_Details__c incomeObj = TestDataUtility.createTestIncomeDetails(false);
        incomeObj.Applicant__c = applicantObj.id;
        insert incomeObj;
            
        Ind_IncomeDetailsCtrl.IncomeEligibilityWrapper ew1 = new Ind_IncomeDetailsCtrl.IncomeEligibilityWrapper();
        ew1.incomeDetailId = incomeObj.Id;
        ew1.applicantId = applicantObj.id;
        ew1.gstNumber = '29ABCDE1234F1ZW';
        ew1.accountNumber = '8743214567';
        ew1.apiType = System.Label.ITR;
            
        Income_Details__c inc2 = TestDataUtility.createTestIncomeDetails(false);
     //   inc2.Id = ew1.incomeDetailId;
        inc2.Applicant__c = ew1.applicantId;
        inc2.GST_No__c = ew1.gstNumber;
        inc2.Is_ITR_Assessed__c = true;
        insert inc2;
            
        Test.startTest();
               Ind_IncomeDetailsCtrl.getAPIEligibility(json.serialize(ew1));
        Test.stopTest();
            
            
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
     @isTest
    public static void getAPIEligibilityTest4(){
        try{
        Opportunity oppObj = TestDataUtility.createTestOpportunity(false);
        insert oppObj;
            
        Applicant__c applicantObj = TestDataUtility.createTestApplicant(false);
        applicantObj.Opportunity__c= oppObj.Id;
        applicantObj.Applicant_Type__c = System.Label.Borrower;
        insert applicantObj;
            
        Income_Details__c incomeObj = TestDataUtility.createTestIncomeDetails(false);
        incomeObj.Applicant__c = applicantObj.id;
        insert incomeObj;
            
        Ind_IncomeDetailsCtrl.IncomeEligibilityWrapper ew1 = new Ind_IncomeDetailsCtrl.IncomeEligibilityWrapper();
        ew1.incomeDetailId = incomeObj.Id;
        ew1.applicantId = applicantObj.id;
        ew1.gstNumber = '29ABCDE1234F1ZW';
        ew1.accountNumber = '8743214567';
        ew1.apiType = System.Label.ITR;
            
        Income_Details__c inc2 = TestDataUtility.createTestIncomeDetails(false);
     //   inc2.Id = ew1.incomeDetailId;
        inc2.Applicant__c = ew1.applicantId;
        inc2.GST_No__c = ew1.gstNumber;
        inc2.Is_ITR_Assessed__c = false;
        insert inc2;
            
        Test.startTest();
               Ind_IncomeDetailsCtrl.getAPIEligibility(json.serialize(ew1));
        Test.stopTest();
            
            
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
     @isTest
    public static void getAPIEligibilityTest5(){
        try{
        Opportunity oppObj = TestDataUtility.createTestOpportunity(false);
        insert oppObj;
            
        Applicant__c applicantObj = TestDataUtility.createTestApplicant(false);
        applicantObj.Opportunity__c= oppObj.Id;
        applicantObj.Applicant_Type__c = System.Label.Borrower;
        insert applicantObj;
            
        Income_Details__c incomeObj = TestDataUtility.createTestIncomeDetails(false);
        incomeObj.Applicant__c = applicantObj.id;
        insert incomeObj;
            
        Ind_IncomeDetailsCtrl.IncomeEligibilityWrapper ew1 = new Ind_IncomeDetailsCtrl.IncomeEligibilityWrapper();
        ew1.incomeDetailId = incomeObj.Id;
        ew1.applicantId = applicantObj.id;
        ew1.gstNumber = '29ABCDE1234F1ZW';
        ew1.accountNumber = '8743214567';
        ew1.apiType = System.Label.BANK_STATEMENT;
            
        Income_Details__c inc2 = TestDataUtility.createTestIncomeDetails(false);
     //   inc2.Id = ew1.incomeDetailId;
        inc2.Applicant__c = ew1.applicantId;
        inc2.GST_No__c = ew1.gstNumber;
        insert inc2;
            
        Test.startTest();
               Ind_IncomeDetailsCtrl.getAPIEligibility(json.serialize(ew1));
        Test.stopTest();
            
            
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
     @isTest
    public static void getAPIEligibilityTest6(){
        try{
        Opportunity oppObj = TestDataUtility.createTestOpportunity(false);
        insert oppObj;
            
        Applicant__c applicantObj = TestDataUtility.createTestApplicant(false);
        applicantObj.Opportunity__c= oppObj.Id;
        applicantObj.Applicant_Type__c = System.Label.Borrower;
        insert applicantObj;
            
        Income_Details__c incomeObj = TestDataUtility.createTestIncomeDetails(false);
        incomeObj.Applicant__c = applicantObj.id;
        insert incomeObj;
            
        Ind_IncomeDetailsCtrl.IncomeEligibilityWrapper ew1 = new Ind_IncomeDetailsCtrl.IncomeEligibilityWrapper();
        ew1.incomeDetailId = incomeObj.Id;
        ew1.applicantId = applicantObj.id;
        ew1.gstNumber = '29ABCDE1234F1ZW';
        ew1.accountNumber = '8743214567';
        ew1.apiType = System.Label.BANK_STATEMENT;
            
        Income_Details__c inc2 = TestDataUtility.createTestIncomeDetails(false);
     //   inc2.Id = ew1.incomeDetailId;
        inc2.Applicant__c = ew1.applicantId;
        inc2.GST_No__c = ew1.gstNumber;
        inc2.set_is_Bank_Details_Assessed__c = true;
        insert inc2;
            
        Test.startTest();
               Ind_IncomeDetailsCtrl.getAPIEligibility(json.serialize(ew1));
        Test.stopTest();
            
            
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }

     @isTest
    public static void getAPIEligibilityTest7(){
        try{
        Opportunity oppObj = TestDataUtility.createTestOpportunity(false);
        insert oppObj;
            
        Applicant__c applicantObj = TestDataUtility.createTestApplicant(false);
        applicantObj.Opportunity__c= oppObj.Id;
        applicantObj.Applicant_Type__c = System.Label.Borrower;
        insert applicantObj;
            
        Income_Details__c incomeObj = TestDataUtility.createTestIncomeDetails(false);
        incomeObj.Applicant__c = applicantObj.id;
        insert incomeObj;
            
        Ind_IncomeDetailsCtrl.IncomeEligibilityWrapper ew1 = new Ind_IncomeDetailsCtrl.IncomeEligibilityWrapper();
        ew1.incomeDetailId = incomeObj.Id;
        ew1.applicantId = applicantObj.id;
        ew1.gstNumber = '29ABCDE1234F1ZW';
        ew1.accountNumber = '8743214567';
        ew1.apiType = System.Label.BANK_STATEMENT;
            
        Income_Details__c inc2 = TestDataUtility.createTestIncomeDetails(false);
     //   inc2.Id = ew1.incomeDetailId;
        inc2.Applicant__c = ew1.applicantId;
        inc2.GST_No__c = ew1.gstNumber;
        inc2.set_is_Bank_Details_Assessed__c = false;
        insert inc2;
            
        Test.startTest();
               Ind_IncomeDetailsCtrl.getAPIEligibility(json.serialize(ew1));
               Ind_IncomeDetailsCtrl.getAPIEligibility('test');
        Test.stopTest();
            
            
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
     @isTest
    public static void getAPIEligibilityTest8(){
        try{
        Opportunity oppObj = TestDataUtility.createTestOpportunity(false);
        insert oppObj;
            
        Applicant__c applicantObj = TestDataUtility.createTestApplicant(false);
        applicantObj.Opportunity__c= oppObj.Id;
        applicantObj.Applicant_Type__c = System.Label.Borrower;
        insert applicantObj;
            
        Income_Details__c incomeObj = TestDataUtility.createTestIncomeDetails(false);
        incomeObj.Applicant__c = applicantObj.id;
        insert incomeObj;
            
        Ind_IncomeDetailsCtrl.IncomeEligibilityWrapper ew1 = new Ind_IncomeDetailsCtrl.IncomeEligibilityWrapper();
        ew1.incomeDetailId = incomeObj.Id;
        ew1.applicantId = applicantObj.id;
        ew1.gstNumber = '29ABCDE1234F1ZW';
        ew1.accountNumber = '8743214567';
        ew1.apiType = 'ITRUpload';
            
        Income_Details__c inc2 = TestDataUtility.createTestIncomeDetails(false);
     //   inc2.Id = ew1.incomeDetailId;
        inc2.Applicant__c = ew1.applicantId;
        inc2.GST_No__c = ew1.gstNumber;
        inc2.set_is_Bank_Details_Assessed__c = false;
        insert inc2;
            
        Test.startTest();
               Ind_IncomeDetailsCtrl.getAPIEligibility(json.serialize(ew1));
               Ind_IncomeDetailsCtrl.getAPIEligibility('test');
        Test.stopTest();
            
            
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void getAPIEligibilityTest9(){
        try{
        Opportunity oppObj = TestDataUtility.createTestOpportunity(false);
        insert oppObj;
            
        Applicant__c applicantObj = TestDataUtility.createTestApplicant(false);
        applicantObj.Opportunity__c= oppObj.Id;
        applicantObj.Applicant_Type__c = System.Label.Borrower;
        insert applicantObj;
            
        Income_Details__c incomeObj = TestDataUtility.createTestIncomeDetails(false);
        incomeObj.Applicant__c = applicantObj.id;
        insert incomeObj;
            
        Ind_IncomeDetailsCtrl.IncomeEligibilityWrapper ew1 = new Ind_IncomeDetailsCtrl.IncomeEligibilityWrapper();
        ew1.incomeDetailId = incomeObj.Id;
        ew1.applicantId = applicantObj.id;
        ew1.gstNumber = '29ABCDE1234F1ZW';
        ew1.accountNumber = '8743214567';
        ew1.apiType = 'BSUpload';
            
        Income_Details__c inc2 = TestDataUtility.createTestIncomeDetails(false);
     //   inc2.Id = ew1.incomeDetailId;
        inc2.Applicant__c = ew1.applicantId;
        inc2.GST_No__c = ew1.gstNumber;
        inc2.set_is_Bank_Details_Assessed__c = false;
        insert inc2;
            
        Test.startTest();
               Ind_IncomeDetailsCtrl.getAPIEligibility(json.serialize(ew1));
               Ind_IncomeDetailsCtrl.getAPIEligibility('test');
        Test.stopTest();
            
            
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void getAPIEligibilityTest10(){
        try{
        Opportunity oppObj = TestDataUtility.createTestOpportunity(false);
        insert oppObj;
            
        Applicant__c applicantObj = TestDataUtility.createTestApplicant(false);
        applicantObj.Opportunity__c= oppObj.Id;
        applicantObj.Applicant_Type__c = System.Label.Borrower;
        insert applicantObj;
            
        Income_Details__c incomeObj = TestDataUtility.createTestIncomeDetails(false);
        incomeObj.Applicant__c = applicantObj.id;
        insert incomeObj;
            
        Ind_IncomeDetailsCtrl.IncomeEligibilityWrapper ew1 = new Ind_IncomeDetailsCtrl.IncomeEligibilityWrapper();
        ew1.incomeDetailId = incomeObj.Id;
        ew1.applicantId = applicantObj.id;
        ew1.gstNumber = '29ABCDE1234F1ZW';
        ew1.accountNumber = '8743214567';
        ew1.apiType = 'BSScanUpload';
            
        Income_Details__c inc2 = TestDataUtility.createTestIncomeDetails(false);
     //   inc2.Id = ew1.incomeDetailId;
        inc2.Applicant__c = ew1.applicantId;
        inc2.GST_No__c = ew1.gstNumber;
        inc2.set_is_Bank_Details_Assessed__c = false;
        insert inc2;
            
        Test.startTest();
               Ind_IncomeDetailsCtrl.getAPIEligibility(json.serialize(ew1));
               Ind_IncomeDetailsCtrl.getAPIEligibility('test');
        Test.stopTest();
            
            
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
     @isTest
    public static void getAPIEligibilityTest12(){
        try{
        Opportunity oppObj = TestDataUtility.createTestOpportunity(false);
        insert oppObj;
            
        Applicant__c applicantObj = TestDataUtility.createTestApplicant(false);
        applicantObj.Opportunity__c= oppObj.Id;
        applicantObj.Applicant_Type__c = System.Label.Borrower;
        insert applicantObj;
            
        Income_Details__c incomeObj = TestDataUtility.createTestIncomeDetails(false);
        incomeObj.Applicant__c = applicantObj.id;
        incomeObj.ScanUpload_BS_Api_Count__c = 3;
      //  incomeObj.ScanUpload_ITR_Api_Count__c = 2;  
        insert incomeObj;
            
        Ind_IncomeDetailsCtrl.IncomeEligibilityWrapper ew1 = new Ind_IncomeDetailsCtrl.IncomeEligibilityWrapper();
        ew1.incomeDetailId = incomeObj.Id;
        ew1.applicantId = applicantObj.id;
        ew1.gstNumber = '29ABCDE1234F1ZW';
        ew1.accountNumber = '8743214567';
        ew1.apiType = 'BSScanUpload';
            
        Income_Details__c inc2 = TestDataUtility.createTestIncomeDetails(false);
      //  inc2.Id = ew1.incomeDetailId;
        inc2.Applicant__c = ew1.applicantId;
        inc2.GST_No__c = ew1.gstNumber;
        inc2.set_is_Bank_Details_Assessed__c = false;
        insert inc2;
            
        Test.startTest();
               Ind_IncomeDetailsCtrl.getAPIEligibility(json.serialize(ew1));
               Ind_IncomeDetailsCtrl.getAPIEligibility('test');
        Test.stopTest();
            
            
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void getAPIEligibilityTest13(){
        try{
        Opportunity oppObj = TestDataUtility.createTestOpportunity(false);
        insert oppObj;
            
        Applicant__c applicantObj = TestDataUtility.createTestApplicant(false);
        applicantObj.Opportunity__c= oppObj.Id;
        applicantObj.Applicant_Type__c = System.Label.Borrower;
        insert applicantObj;
            
        Income_Details__c incomeObj = TestDataUtility.createTestIncomeDetails(false);
        incomeObj.Applicant__c = applicantObj.id;
        incomeObj.ScanUpload_BS_Api_Count__c = 3;
      //  incomeObj.ScanUpload_ITR_Api_Count__c = 2;  
        insert incomeObj;
            
        Ind_IncomeDetailsCtrl.IncomeEligibilityWrapper ew1 = new Ind_IncomeDetailsCtrl.IncomeEligibilityWrapper();
        ew1.incomeDetailId = incomeObj.Id;
        ew1.applicantId = applicantObj.id;
        ew1.gstNumber = '29ABCDE1234F1ZW';
        ew1.accountNumber = '8743214567';
        ew1.apiType = 'GSTUpload';
            
        Income_Details__c inc2 = TestDataUtility.createTestIncomeDetails(false);
      //  inc2.Id = ew1.incomeDetailId;
        inc2.Applicant__c = ew1.applicantId;
        inc2.GST_No__c = ew1.gstNumber;
        inc2.set_is_Bank_Details_Assessed__c = false;
        insert inc2;
            
        Test.startTest();
               Ind_IncomeDetailsCtrl.getAPIEligibility(json.serialize(ew1));
               Ind_IncomeDetailsCtrl.getAPIEligibility('test');
        Test.stopTest();
            
            
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void getAPIEligibilityTest14(){
        try{
        Opportunity oppObj = TestDataUtility.createTestOpportunity(false);
        insert oppObj;
            
        Applicant__c applicantObj = TestDataUtility.createTestApplicant(false);
        applicantObj.Opportunity__c= oppObj.Id;
        applicantObj.Applicant_Type__c = System.Label.Borrower;
        insert applicantObj;
            
        Income_Details__c incomeObj = TestDataUtility.createTestIncomeDetails(false);
        incomeObj.Applicant__c = applicantObj.id;
        incomeObj.ScanUpload_BS_Api_Count__c = 1;
      //  incomeObj.ScanUpload_ITR_Api_Count__c = 2;  
        insert incomeObj;
            
        Ind_IncomeDetailsCtrl.IncomeEligibilityWrapper ew1 = new Ind_IncomeDetailsCtrl.IncomeEligibilityWrapper();
        ew1.incomeDetailId = incomeObj.Id;
        ew1.applicantId = applicantObj.id;
        ew1.gstNumber = '29ABCDE1234F1ZW';
        ew1.accountNumber = '8743214567';
        ew1.apiType = 'BSScanUpload';
            
        Income_Details__c inc2 = TestDataUtility.createTestIncomeDetails(false);
      //  inc2.Id = ew1.incomeDetailId;
        inc2.Applicant__c = ew1.applicantId;
        inc2.GST_No__c = ew1.gstNumber;
        inc2.set_is_Bank_Details_Assessed__c = false;
        insert inc2;
            
        Test.startTest();
               Ind_IncomeDetailsCtrl.getAPIEligibility(json.serialize(ew1));
               Ind_IncomeDetailsCtrl.getAPIEligibility('test');
        Test.stopTest();
            
            
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
   /* @isTest
    public static void getAPIEligibilityTest15(){
        try{
        Opportunity oppObj = TestDataUtility.createTestOpportunity(false);
        insert oppObj;
            
        Applicant__c applicantObj = TestDataUtility.createTestApplicant(false);
        applicantObj.Opportunity__c= oppObj.Id;
        applicantObj.Applicant_Type__c = System.Label.Borrower;
        insert applicantObj;
            
        Income_Details__c incomeObj = TestDataUtility.createTestIncomeDetails(false);
        incomeObj.Applicant__c = applicantObj.id;
        incomeObj.ScanUpload_BS_Api_Count__c = 1;
      //  incomeObj.ScanUpload_ITR_Api_Count__c = 2;  
        insert incomeObj;
            
        Ind_IncomeDetailsCtrl.IncomeEligibilityWrapper ew1 = new Ind_IncomeDetailsCtrl.IncomeEligibilityWrapper();
        ew1.incomeDetailId = incomeObj.Id;
        ew1.applicantId = applicantObj.id;
        ew1.gstNumber = '29ABCDE1234F1ZW';
        ew1.accountNumber = '8743214567';
        ew1.apiType = 'BSScanUpload';
            
        Income_Details__c inc2 = TestDataUtility.createTestIncomeDetails(false);
     //   inc2.Id = ew1.incomeDetailId;
        inc2.Applicant__c = ew1.applicantId;
        inc2.GST_No__c = ew1.gstNumber;
        inc2.set_is_Bank_Details_Assessed__c = false;
        update inc2;
            
        Test.startTest();
               Ind_IncomeDetailsCtrl.getAPIEligibility(json.serialize(ew1));
               Ind_IncomeDetailsCtrl.getAPIEligibility('test');
        Test.stopTest();
            
            
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    } */
    
    
    @isTest
    public static void checkBankIncomeDetailsTest(){
        try{
            Opportunity oppObj = TestDataUtility.createTestOpportunity(false);
            insert oppObj;
            
        Applicant__c applicantObj = TestDataUtility.createTestApplicant(false);
        applicantObj.Opportunity__c= oppObj.Id;
        applicantObj.Applicant_Type__c = System.Label.Borrower;
        insert applicantObj;
            
                Bank_Masters__c bm1 = new Bank_Masters__c();
                bm1.Bank_Code__c = 3919;
                bm1.Name = 'test';
                bm1.OwnerId = UserInfo.getUserId();
                insert bm1;
            
        Income_Details__c incomeObj = TestDataUtility.createTestIncomeDetails(false);
        incomeObj.Applicant__c = applicantObj.id;
        incomeObj.Name_of_Recipient_Banks__c = bm1.Id;
        incomeObj.Bank_Account_Number__c = '45321678523';
        incomeObj.Name = 'SBI';
        insert incomeObj;
            
         Test.startTest();
              Ind_IncomeDetailsCtrl.checkBankIncomeDetails(applicantObj.id,incomeObj.Name,incomeObj.Bank_Account_Number__c);
              Ind_IncomeDetailsCtrl.checkBankIncomeDetails(applicantObj.id,bm1.Name,incomeObj.Bank_Account_Number__c);
              Ind_IncomeDetailsCtrl.checkBankIncomeDetails(null,null,null);
         Test.stopTest();
            
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void checkBankIncomeDetailsTest1(){
        try{
            Opportunity oppObj = TestDataUtility.createTestOpportunity(false);
            insert oppObj;
            
        Applicant__c applicantObj = TestDataUtility.createTestApplicant(false);
        applicantObj.Opportunity__c= oppObj.Id;
        applicantObj.Applicant_Type__c = System.Label.Borrower;
        insert applicantObj;
            
                Bank_Masters__c bm1 = new Bank_Masters__c();
                bm1.Bank_Code__c = 3919;
                bm1.Name = 'test';
                bm1.OwnerId = UserInfo.getUserId();
                insert bm1;
            
        Income_Details__c incomeObj = TestDataUtility.createTestIncomeDetails(false);
        incomeObj.Applicant__c = applicantObj.id;
        incomeObj.Name_of_Recipient_Banks__c = bm1.Id;
        incomeObj.Bank_Account_Number__c = '45321678523';
        incomeObj.Name = 'SBI';
        incomeObj.Is_Income_Credited_In_Bank_Account__c = true;
        insert incomeObj;
            
         Test.startTest();
              Ind_IncomeDetailsCtrl.checkBankIncomeDetails(applicantObj.id,incomeObj.Name,incomeObj.Bank_Account_Number__c);
              Ind_IncomeDetailsCtrl.checkBankIncomeDetails(applicantObj.id,bm1.Name,incomeObj.Bank_Account_Number__c);
              Ind_IncomeDetailsCtrl.checkBankIncomeDetails(null,null,null);
         Test.stopTest();
            
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void fetchDocumentTest(){
        try{
            Opportunity oppObj = TestDataUtility.createTestOpportunity(false);
            insert oppObj;
            
            Vehicle_Detail__c vd1 = new Vehicle_Detail__c();
            vd1.Loan_Application__c = oppObj.Id;
            vd1.Is_RC_Limit_Check_correctly_captured__c='No';
            insert vd1;
            
        Applicant__c applicantObj = TestDataUtility.createTestApplicant(false);
        applicantObj.Opportunity__c= oppObj.Id;
        applicantObj.Applicant_Type__c = System.Label.Borrower;
        insert applicantObj;
            
                 Documents__c dfks1 = new Documents__c();
                 dfks1.Applicant__c = applicantObj.Id;
                 dfks1.Opportunity_Relation__c = oppObj.Id;
                 dfks1.Document_Type__c = 'Bank Statement';
                 dfks1.Document_Side__c ='Back';
                 dfks1.Aadhar_Source__c = 'ScanAadhar';
                 insert dfks1;
            
                  Test.startTest();
                       Ind_IncomeDetailsCtrl.fetchDocument(applicantObj.Id,dfks1.Document_Type__c,vd1.Id);
                       Ind_IncomeDetailsCtrl.fetchDocument('test','test','test1');
                       Ind_IncomeDetailsCtrl.fetchDocument(null,null,null);
                  Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }

      @isTest
    public static void fetchDocumentTest1(){
        try{
            Opportunity oppObj = TestDataUtility.createTestOpportunity(false);
            insert oppObj;
            
            Vehicle_Detail__c vd1 = new Vehicle_Detail__c();
            vd1.Loan_Application__c = oppObj.Id;
            vd1.Is_RC_Limit_Check_correctly_captured__c='No';
            insert vd1;
            
            Ind_IncomeDetailsCtrl.OppWrapper ow1 = new Ind_IncomeDetailsCtrl.OppWrapper();
            ow1.productType = 'book';
            ow1.lastStage = 'test';
            ow1.currentStageName = 'testcurrent';
            ow1.leadNumber = 'test123';
            
                  Test.startTest();
                       Ind_IncomeDetailsCtrl.fetchDocument(oppObj.Id,'test',vd1.Id);
                       Ind_IncomeDetailsCtrl.fetchDocument(null,'test',null);
                   Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }

     @isTest
    public static void deleteIncomeDetailsTest(){
        try{
            Opportunity oppObj = TestDataUtility.createTestOpportunity(false);
            insert oppObj;
            
            Applicant__c applicantObj = TestDataUtility.createTestApplicant(false);
            applicantObj.Opportunity__c= oppObj.Id;
            applicantObj.Applicant_Type__c = System.Label.Borrower;
            insert applicantObj;
            
            Income_Details__c incomeObj = TestDataUtility.createTestIncomeDetails(false);
            incomeObj.Applicant__c = applicantObj.id;
            insert incomeObj;
            
            Test.startTest();
                  Ind_IncomeDetailsCtrl.deleteIncomeDetails(incomeObj.Id);
                  Ind_IncomeDetailsCtrl.deleteIncomeDetails('test');
            Test.stopTest();
            
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void checkImageExistTest(){
        try{
        Opportunity opp1 = TestDataUtility.createTestOpportunity(false);
        insert opp1;
        
        Applicant__c app1 = TestDataUtility.createTestApplicant(false);
        app1.Opportunity__c= opp1.Id;
        app1.Applicant_Type__c = System.Label.Borrower;
        insert app1;
        
        Documents__c dfk1 = new Documents__c();
        dfk1.Applicant__c = app1.Id;
        dfk1.Opportunity_Relation__c = opp1.Id;
        dfk1.KYC_name__c = 'Aadhar';
        dfk1.Aadhar_Source__c = 'ScanAadhar';
        dfk1.Name = 'Customer Bank Statement';
        dfk1.Document_Type__c = 'Aadhaar';
        insert dfk1;
        
        Test.startTest();
              Ind_IncomeDetailsCtrl.checkImageExist(app1.Id,dfk1.Name);
              Ind_IncomeDetailsCtrl.checkImageExist('test','aadhar');
              Ind_IncomeDetailsCtrl.checkImageExist(null,null);
        Test.stopTest();
            
        }catch(Exception e){
            //System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void getContentDocumentIdTest(){
        try{
            Opportunity opks1 = new Opportunity();
                opks1.StageName = 'Qualification';
                opks1.CloseDate = Date.newInstance(2021, 1, 11);
                opks1.Name = 'testone';
                insert opks1;
                
                Applicant__c apks1 = new Applicant__c();
                apks1.Opportunity__c = opks1.Id;
                apks1.Contact_number__c = '9743514830';
                apks1.Applicant_Type__c = 'Borrower';
                insert apks1;
                
                 Documents__c dfks1 = new Documents__c();
                 dfks1.Applicant__c = apks1.Id;
                 dfks1.Opportunity_Relation__c = opks1.Id;
                 dfks1.KYC_name__c = 'Aadhar';
                 dfks1.Document_Side__c ='Back';
                 dfks1.Aadhar_Source__c = 'ScanAadhar';
                 dfks1.Name = 'Aadhar';
                 dfks1.Document_Type__c = 'Passport';
                 insert dfks1;
                
                 ContentVersion cvn1 = new ContentVersion();
                 cvn1.PathOnClient = 'testpath1';
                 cvn1.Title = 'testtitle1';
                 cvn1.VersionData = Blob.valueOf('Test Content');
                 cvn1.Document_Side_fileupload__c = 'Selfie';
                 insert cvn1;
                
                 ContentVersion testcd1 = [SELECT id, ContentDocumentId FROM ContentVersion where Id = :cvn1.Id];
                
                 ContentDocumentLink cdlink1 = new ContentDocumentLink();
                 cdlink1.Visibility = 'AllUsers';
                 cdlink1.ShareType = 'V';
                 cdlink1.LinkedEntityId = dfks1.Id;
                 cdlink1.ContentDocumentId = testcd1.ContentDocumentId;
                 insert cdlink1; 
            
                 Test.startTest();
                      Ind_IncomeDetailsCtrl.getContentDocumentId(dfks1.Id);
                      Ind_IncomeDetailsCtrl.getContentDocumentId(null);
                 Test.stopTest();
             
        }catch(Exception e){
            //System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
     @isTest
    public static void getContentDocumentIdTest1(){
        try{
            Opportunity opks1 = new Opportunity();
                opks1.StageName = 'Qualification';
                opks1.CloseDate = Date.newInstance(2021, 1, 11);
                opks1.Name = 'testone';
                insert opks1;
                
                Applicant__c apks1 = new Applicant__c();
                apks1.Opportunity__c = opks1.Id;
                apks1.Contact_number__c = '9743514830';
                apks1.Applicant_Type__c = 'Borrower';
                insert apks1;
                
                 Documents__c dfks2 = new Documents__c();
                 dfks2.Applicant__c = apks1.Id;
                 dfks2.Opportunity_Relation__c = opks1.Id;
                 dfks2.KYC_name__c = 'Aadhar';
                 dfks2.Document_Side__c ='Back';
                 dfks2.Aadhar_Source__c = 'ScanAadhar';
                 dfks2.Name = 'Aadhar';
                 dfks2.Document_Type__c = 'Passport';
                 insert dfks2;
                
                 
            
                 Test.startTest();
                      Ind_IncomeDetailsCtrl.getContentDocumentId(dfks2.Id);
                 Test.stopTest();
             
        }catch(Exception e){
            //System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void getValidationInputsTest(){
        try{
            Opportunity oppObj = TestDataUtility.createTestOpportunity(false);
            insert oppObj;
            
            Applicant__c applicantObj = TestDataUtility.createTestApplicant(false);
            applicantObj.Opportunity__c= oppObj.Id;
            applicantObj.Applicant_Type__c = System.Label.Borrower;
            insert applicantObj;
            
            Income_Details__c incomeObj = TestDataUtility.createTestIncomeDetails(false);
            incomeObj.Applicant__c = applicantObj.id;
            insert incomeObj;
            
            Test.startTest();
                    Ind_IncomeDetailsCtrl.getValidationInputs(applicantObj.id);
                    Ind_IncomeDetailsCtrl.getValidationInputs('test');
                    Ind_IncomeDetailsCtrl.getValidationInputs(null);
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
     @isTest
    public static void getValidationInputsTest1(){
        try{
            Opportunity oppObj = TestDataUtility.createTestOpportunity(false);
            insert oppObj;
            
            Applicant__c applicantObj = TestDataUtility.createTestApplicant(false);
            applicantObj.Opportunity__c= oppObj.Id;
            applicantObj.Applicant_Type__c = System.Label.Borrower;
            insert applicantObj;
            
            Test.startTest();
                    Ind_IncomeDetailsCtrl.getValidationInputs(applicantObj.id);
                    Ind_IncomeDetailsCtrl.getValidationInputs('test');
                    Ind_IncomeDetailsCtrl.getValidationInputs(null);
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }

    @isTest
    public static void mapProfileToIncomeDetailsOfNEApplicantTest(){
    try{
        Opportunity opp1 = TestDataUtility.createTestOpportunity(false);
        insert opp1;
        
        Applicant__c app1 = TestDataUtility.createTestApplicant(false);
        app1.Opportunity__c= opp1.Id;
        app1.Applicant_Type__c = System.Label.Borrower;
        insert app1;
        
        Documents__c dfk1 = new Documents__c();
        dfk1.Applicant__c = app1.Id;
        dfk1.Opportunity_Relation__c = opp1.Id;
        dfk1.KYC_name__c = 'Aadhar';
        dfk1.Aadhar_Source__c = 'ScanAadhar';
        dfk1.Name = 'Aadhar';
        dfk1.Document_Type__c = 'PAN';
        insert dfk1;
        
        Income_Details__c inc1 = TestDataUtility.createTestIncomeDetails(false);
        inc1.Applicant__c = app1.id;
        insert inc1;
        
        Profile_Master__c pM = new Profile_Master__c(Name = 'STUDENT', code__c = '12');
        insert pM;
        
        Test.startTest();
              Ind_IncomeDetailsCtrl.mapProfileToIncomeDetailsOfNEApplicant(app1.Id, 'STUDENT');
              Ind_IncomeDetailsCtrl.mapProfileToIncomeDetailsOfNEApplicant(app1.Id, 'NOPROFILE');
              Delete inc1;
              Ind_IncomeDetailsCtrl.mapProfileToIncomeDetailsOfNEApplicant(app1.Id, 'STUDENT');
        Test.stopTest();
        
    }catch(Exception e){
          System.assertEquals('Script-thrown exception', e.getMessage());
    }
    }
    @isTest
    public static void saveIncomeDetailsPositiveTest1() { 
        try{
    Opportunity oppObj = TestDataUtility.createTestOpportunity(false);
        insert oppObj;
        Applicant__c applicantObj = TestDataUtility.createTestApplicant(false);
        applicantObj.Opportunity__c= oppObj.Id;
        applicantObj.Applicant_Type__c = System.Label.Borrower;
        insert applicantObj;
            
        
        Income_Details__c incomeObj = TestDataUtility.createTestIncomeDetails(false);
        incomeObj.Applicant__c = applicantObj.id;
        insert incomeObj;
        
        Ind_IncomeDetailsCtrl.IncomeDetailWrapper incomeWrapper = new Ind_IncomeDetailsCtrl.IncomeDetailWrapper();
        incomeWrapper.Id = incomeObj.Id;
        incomeWrapper.Income = 10000.00;
        incomeWrapper.yearOfRegisteration = '2021';
        incomeWrapper.name = 'Test income';
        incomeWrapper.applicantId = applicantObj.id;
        incomeWrapper.totalIncome = '10000';
            incomeWrapper.totalExpense = '100';
            incomeWrapper.pBT = '100';
            incomeWrapper.pAT = '100';
            incomeWrapper.cashProfit = '200';
            incomeWrapper.shareholderFunds = '300';
            incomeWrapper.incomeSource = 'Financials';   
        incomeWrapper.incomeLastYear = '20000';
        incomeWrapper.iTRLastYearDate = String.valueOf(System.today());
        List<Ind_IncomeDetailsCtrl.IncomeDetailWrapper> incomeWrapperlist = new List<Ind_IncomeDetailsCtrl.IncomeDetailWrapper>();
        incomeWrapperlist.add(incomeWrapper);
     
        Test.startTest();
          Map<String, String> id1 = Ind_IncomeDetailsCtrl.saveIncomeDetails(JSON.serialize(incomeWrapperlist),applicantObj.id, 'true');
          system.assertEquals(id1, Ind_IncomeDetailsCtrl.saveIncomeDetails(JSON.serialize(incomeWrapperlist),applicantObj.id, 'true'));
            
            Test.stopTest();
        //}
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
            Test.stopTest();
        }
    }
    @isTest
    public static void saveIncomeDetailsPositiveTest2() { 
        try{
    Opportunity oppObj = TestDataUtility.createTestOpportunity(false);
        insert oppObj;
        Applicant__c applicantObj = TestDataUtility.createTestApplicant(false);
        applicantObj.Opportunity__c= oppObj.Id;
        applicantObj.Applicant_Type__c = System.Label.Borrower;
        insert applicantObj;
            
        
        Income_Details__c incomeObj = TestDataUtility.createTestIncomeDetails(false);
        incomeObj.Applicant__c = applicantObj.id;
        insert incomeObj;
        
        Ind_IncomeDetailsCtrl.IncomeDetailWrapper incomeWrapper = new Ind_IncomeDetailsCtrl.IncomeDetailWrapper();
        incomeWrapper.Id = incomeObj.Id;
        incomeWrapper.Income = 10000.00;
        incomeWrapper.yearOfRegisteration = '2021';
        incomeWrapper.name = 'Test income';
        incomeWrapper.applicantId = applicantObj.id;
        incomeWrapper.totalIncome = '10000';
            incomeWrapper.totalExpense = '100';
            incomeWrapper.pBT = '100';
            incomeWrapper.pAT = '100';
            incomeWrapper.cashProfit = '200';
            incomeWrapper.shareholderFunds = '300';
            incomeWrapper.incomeSource = 'Financials';   
        incomeWrapper.incomeLastYear = '20000';
        incomeWrapper.iTRLastYearDate = String.valueOf(System.today());
        List<Ind_IncomeDetailsCtrl.IncomeDetailWrapper> incomeWrapperlist = new List<Ind_IncomeDetailsCtrl.IncomeDetailWrapper>();
        incomeWrapperlist.add(incomeWrapper);
     
        Test.startTest();
          Ind_IncomeDetailsCtrl.saveIncomeDetails(JSON.serialize(incomeWrapperlist),applicantObj.id, 'false');  
            Test.stopTest();
        //}
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
            Test.stopTest();
        }
    }
     @isTest
    public static void getValidationInputsTestOthers(){
        try{
            Opportunity oppObj = TestDataUtility.createTestOpportunity(false);
            insert oppObj;
            
            Applicant__c applicantObj = TestDataUtility.createTestApplicant(false);
            applicantObj.Opportunity__c= oppObj.Id;
            applicantObj.Applicant_Type__c = System.Label.Borrower;
            insert applicantObj;
            
            Income_Details__c incomeObj = TestDataUtility.createTestIncomeDetails(false);
            incomeObj.Applicant__c = applicantObj.id;
            insert incomeObj;
             Vehicle_Detail__c veObj = new Vehicle_Detail__c();
            veObj.Loan_Application__c = oppObj.Id;
            insert veObj;
            Documents__c dsdt1 = new Documents__c();
            dsdt1.Applicant__c = applicantObj.Id;
            dsdt1.Opportunity_Relation__c = oppObj.Id;
            dsdt1.Document_Type__c = 'RC Copy';
            dsdt1.Document_Side__c ='Back';
            dsdt1.Aadhar_Source__c = 'ScanAadhar'; 
            dsdt1.Vehicle_Detail__c = veObj.ID;
            insert dsdt1;
           
            Test.startTest();
                    Ind_IncomeDetailsCtrl.incomeLegalEntityPicklist();
                    Ind_IncomeDetailsCtrl.updateProfileNameOfApplicant(applicantObj.Id,'CMU');
            		Ind_IncomeDetailsCtrl.getCustomerProfileForNE();
            		Ind_IncomeDetailsCtrl.fetchDocumentTractorVehicle(applicantObj.Id,'RC Copy',veObj.Id);
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
 
}