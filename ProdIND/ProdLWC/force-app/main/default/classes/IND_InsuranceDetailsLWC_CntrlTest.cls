@isTest(SeeAllData=false)
public class IND_InsuranceDetailsLWC_CntrlTest {
    
  /*  @testSetup static void setup() {
        Account testAccount = TestDataUtility.createTestAccount(true);
        
        Opportunity opp = TestDataUtility.createTestOpportunity(false);
        opp.AccountId = testAccount.Id;
        opp.Is_customer_interested_in_a_motor_insura__c = true;
        insert opp;
        
        Vehicle_Detail__c vech = new Vehicle_Detail__c();
    //    vech.Name ='Test';
        vech.Loan_Application__c = opp.Id;
        insert vech;
        
        Applicant__c applicant = TestDataUtility.createTestApplicant(false);
        applicant.Opportunity__c= opp.Id;
        applicant.Applicant_Type__c='Borrower';
        insert applicant;
        
        InsuranceDetails__c insuDetail = new InsuranceDetails__c();
        insuDetail.Applicant__c = applicant.id;
        insuDetail.Funded_Premium__c=400.00;
        insuDetail.Loan_Application__c = opp.id;
        insuDetail.Funded_Non_funded__c = 'Funded';
        insuDetail.Name = 'MOTOR';
        insert insuDetail;
        
        InsuranceMaster__c inMstr = new InsuranceMaster__c();
        inMstr.Name ='Cholamandalam MS General Insurance Company Ltd.';
        inMstr.Insurance_Company_Code__c = '45';
        insert inMstr;
        
        Insurance_Premium_details__c inprDetails = new Insurance_Premium_details__c();
        inprDetails.Ins_Product__c = 'GPA';
        inprDetails.Insurance_Plan_Code__c = 'GAP_1Y';
        inprDetails.Premium__c=78600.88;   
        inprDetails.Disable_Funding__c = 'Funded';
        inprDetails.Sum_Insured__c = 767.98;
        inprDetails.Period__c =12;
        inprDetails.External_id__c = '29';
        inprDetails.Insurance_Master__c = inMstr.Id;
        insert inprDetails;
    }
    
    @isTest
    public static void existInsuranceDetailsMethodTest(){
        Applicant__c applicant = [select Id,Opportunity__c from Applicant__c where Name=: 'test' WITH SECURITY_ENFORCED limit 1];
        User userTest = TestDataUtility.createIBCounterStaffUser(true);
            
        system.runAs(userTest){ 
        Test.startTest();
		IND_InsuranceDetailsLWC_controller.existInsuranceDetailsMethod(applicant.Opportunity__c,applicant.id);
        Test.stopTest();
        }
    }
    
    @isTest
    public static void enableCheckboxTest(){
        Applicant__c applicant = [select Id,Opportunity__c from Applicant__c where Name=: 'test' WITH SECURITY_ENFORCED limit 1];
        Test.startTest();
        IND_InsuranceDetailsLWC_controller.enableCheckbox(applicant.id);
        Test.stopTest();
    }
    
    @isTest
    public static void getMotorInsurancePreimumTest(){
        Insurance_Premium_details__c insuranceMster= [SELECT id, Ins_Product__c, Insurance_Plan_Code__c,
                                                      Premium__c, Disable_Funding__c, Sum_Insured__c
                                                      FROM Insurance_Premium_details__c
                                                      WHERE Insurance_Master__r.Name = 'Cholamandalam MS General Insurance Company Ltd.'];
        Test.startTest();
     //   IND_InsuranceDetailsLWC_controller.getMotorInsurancePreimum(insuranceMster.Ins_Product__c,insuranceMster.Insurance_Plan_Code__c);
        Test.stopTest();
    }
    
    @isTest
    public static void callInuranceRecAPITest(){
        
                Opportunity optg1 = new Opportunity();
                optg1.StageName = 'Qualification';
                optg1.CloseDate = Date.newInstance(2021, 1, 11);
                optg1.Name = 'testone';
                insert optg1;
                
                Applicant__c apt1 = new Applicant__c();
                apt1.Opportunity__c = optg1.Id;
                apt1.Contact_number__c = '9743514830';
                apt1.Applicant_Type__c = 'Borrower';
                insert apt1;
        
        Test.startTest();
           //  IND_InsuranceDetailsLWC_controller.callInuranceRecAPI(apt1.Applicant_Type__c,optg1.Id);
        Test.stopTest();
    }
    
    @isTest
    public static void getInsuranceDetailsFromMasterTest(){
        Applicant__c applicant = [select Id,Opportunity__c,Applicant_Type__c from Applicant__c where Name=: 'test' WITH SECURITY_ENFORCED limit 1];
        try{
        Test.startTest();
        IND_InsuranceDetailsLWC_controller.getInsuranceDetailsFromMaster();
        Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void sendInsuranceConsentTest(){
        Applicant__c applicant = [select Id,Opportunity__c,Applicant_Type__c from Applicant__c where Name=: 'test' WITH SECURITY_ENFORCED limit 1];
        Test.startTest();
        IND_InsuranceDetailsLWC_controller.sendInsuranceConsent(applicant.Opportunity__c,applicant.Applicant_Type__c);
        Test.stopTest();
    }
    
    @isTest
    public static void getMotorInsuranceFromLoanDetailsTest(){
        Applicant__c applicant = [select Id,Opportunity__c,Applicant_Type__c from Applicant__c where Name=: 'test' WITH SECURITY_ENFORCED limit 1];
        Test.startTest();
        IND_InsuranceDetailsLWC_controller.getMotorInsuranceFromLoanDetails(applicant.Opportunity__c);
        Test.stopTest();
    }
    
    @isTest
    public static void isCustomerrequestedinMotorinsuranceTest(){
        Applicant__c applicant = [select Id,Opportunity__c,Applicant_Type__c from Applicant__c where Name=: 'test' WITH SECURITY_ENFORCED limit 1];
        Test.startTest();
        IND_InsuranceDetailsLWC_controller.isCustomerrequestedinMotorinsurance(applicant.Opportunity__c);
        Test.stopTest();
    }
    
    @isTest
    public static void getMotorVechileDetailsTest(){
        Applicant__c applicant = [select Id,Opportunity__c,Applicant_Type__c from Applicant__c where Name=: 'test' WITH SECURITY_ENFORCED limit 1];
        Test.startTest();
        IND_InsuranceDetailsLWC_controller.getMotorVechileDetails(applicant.Id);
        Test.stopTest();
    }
  
    /*
    @isTest
    public static void testGetInsuranceDetailsFromMaster(){
        Test.startTest();
        IND_InsuranceDetailsLWC_controller.GetInsuranceDetailsFromMaster();
        IND_InsuranceDetailsLWC_controller.isPremimumAmountResponseAPI1();
        Test.stopTest();
    }
    
    @isTest
    public static void testloadInsuranceDetails(){
        Applicant__c applicant = [select Id from Applicant__c where Name=: 'test' WITH SECURITY_ENFORCED limit 1];
        Test.startTest();
       // IND_InsuranceDetailsLWC_controller.InsurancePremiumAPIResponseWrapper insurObj =  IND_InsuranceDetailsLWC_controller.getMotorInsuranceFromLoanDetails(applicant.Id,'brrower');
       // Map<string,List<IND_InsuranceRecommendationAPIController.Ins_Product>> insurObj1 =  IND_InsuranceDetailsLWC_controller.loadInsuranceDetails(applicant.Id,'brrower');

        //System.assertNotEquals(null, insurObj);
        Test.stopTest();
    }
    

    @isTest
    public static void testGetInsurancePremium(){
        try{
           	Applicant__c applicant = [select Id from Applicant__c where Name=: 'test' WITH SECURITY_ENFORCED limit 1];
            Test.startTest();
           // String response = IND_InsuranceDetailsLWC_controller.getInsurancePremium('plan','insurance product',applicant.id);
           // String responseForNullValues = IND_InsuranceDetailsLWC_controller.getInsurancePremium(null,null,null);
            Test.stopTest();
            //System.assertNotEquals(null, response);
           // System.assertEquals(null, responseForNullValues);
        }Catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void testGetApplicantId(){
        try{
			Opportunity opp = [SELECT Id FROM Opportunity WHERE Name = 'Opportunity'];
            Test.startTest();
            String response = IND_InsuranceDetailsLWC_controller.getApplicantId(opp.id,'Borrower');
            String responseForNullValues = IND_InsuranceDetailsLWC_controller.getApplicantId(null,'Borrower');
            Test.stopTest();
            System.assertNotEquals(null, response);
            System.assertEquals(null, responseForNullValues);
        }Catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void testGetFundingAvailibility(){
        try{
			Opportunity opp = [SELECT Id FROM Opportunity WHERE Name = 'Opportunity'];
            opp.Ex_showroom_price__c = 100000;
            opp.On_Road_price__c = 100000;
            opp.Required_Loan_amount__c = 50000;
            opp.Vehicle_Type__c = 'Used';
            opp.Vehicle_Sub_Category__c = 'URS';
            opp.Funding_on_Ex_Showroom__c= true;
            opp.Funding_on_ORP__c = false;
            update opp;
            
            Vehicle_Detail__c vehObj = [SELECT Id FROM Vehicle_Detail__c WHERE Name = 'Test'];
            vehObj.Base_Price__c = 2000000;
            vehObj.Eligible_Loan_Amount__c = 1500000;
            update vehObj;
            
            IND_InsuranceDetailsLWC_controller.GetFundingAvailabiltyRequestWrapper reqWrapper = new IND_InsuranceDetailsLWC_controller.GetFundingAvailabiltyRequestWrapper();
            reqWrapper.loanApplicationId = opp.Id;
            
            IND_InsuranceDetailsLWC_controller.InsuranceWrapper healthInsuranceObj = new IND_InsuranceDetailsLWC_controller.InsuranceWrapper();
            healthInsuranceObj.selectedProduct = 'Health Insurance'; 
            healthInsuranceObj.selectedPlan = 'PPD_2L_3Y111';
            healthInsuranceObj.isFunded = true;
            healthInsuranceObj.premium = 12082.00;
            
            IND_InsuranceDetailsLWC_controller.InsuranceWrapper gpaInsuranceObj = new IND_InsuranceDetailsLWC_controller.InsuranceWrapper();
            gpaInsuranceObj.selectedProduct = 'Health Insurance'; 
            gpaInsuranceObj.selectedPlan = 'PPD_2L_3Y';
            gpaInsuranceObj.isFunded = true;
            gpaInsuranceObj.premium = 1208.00;
            
            IND_InsuranceDetailsLWC_controller.InsuranceWrapper comboInsuranceObj = new IND_InsuranceDetailsLWC_controller.InsuranceWrapper();
            comboInsuranceObj.selectedProduct = 'Health Insurance'; 
            comboInsuranceObj.selectedPlan = 'PPD_2L_3Y';
            comboInsuranceObj.isFunded = true;
            comboInsuranceObj.premium = 1208.00;
            
            IND_InsuranceDetailsLWC_controller.InsuranceWrapper motorInsuranceObj = new IND_InsuranceDetailsLWC_controller.InsuranceWrapper();
            motorInsuranceObj.selectedProduct = 'Health Insurance'; 
            //motorInsuranceObj.selectedPlan = 'PPD_2L_3Y';
            motorInsuranceObj.isFunded = true;
            motorInsuranceObj.premium = 1208.00;
            
            reqWrapper.healthInsurance = healthInsuranceObj;
            reqWrapper.gpaInsurance = gpaInsuranceObj;
            reqWrapper.comboInsurance = healthInsuranceObj;
            reqWrapper.motorInsurance = gpaInsuranceObj;
                
            Test.startTest();
            String response = IND_InsuranceDetailsLWC_controller.getFundingAvailibility(JSON.serialize(reqWrapper));           
            Test.stopTest();
            System.assertNotEquals(null, response);
          
        }Catch(Exception e){
         //   System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    
    @isTest 
    public static void testSubmitInsuranceDetails(){
         try{
			Opportunity opp = [SELECT Id FROM Opportunity WHERE Name = 'Opportunity'];
            Applicant__c applicant = [select Id from Applicant__c where Name=: 'test' WITH SECURITY_ENFORCED limit 1];
            
            IND_InsuranceDetailsLWC_controller.SubmitInsuranceRequestWrapper reqWrapper = new IND_InsuranceDetailsLWC_controller.SubmitInsuranceRequestWrapper();
            
            IND_InsuranceDetailsLWC_controller.InsuranceWrapper healthInsuranceObj = new IND_InsuranceDetailsLWC_controller.InsuranceWrapper();
            healthInsuranceObj.selectedProduct = 'Health Insurance'; 
            healthInsuranceObj.selectedPlan = 'PPD_2L_3Y111';
            healthInsuranceObj.isFunded = true;
            healthInsuranceObj.premium = 12082.00;
            
            IND_InsuranceDetailsLWC_controller.InsuranceWrapper gpaInsuranceObj = new IND_InsuranceDetailsLWC_controller.InsuranceWrapper();
            gpaInsuranceObj.selectedProduct = 'Health Insurance'; 
            gpaInsuranceObj.selectedPlan = 'PPD_2L_3Y';
            gpaInsuranceObj.isFunded = true;
            gpaInsuranceObj.premium = 1208.00;
            
            IND_InsuranceDetailsLWC_controller.InsuranceWrapper comboInsuranceObj = new IND_InsuranceDetailsLWC_controller.InsuranceWrapper();
            comboInsuranceObj.selectedProduct = 'Health Insurance'; 
            comboInsuranceObj.selectedPlan = 'PPD_2L_3Y';
            comboInsuranceObj.isFunded = true;
            comboInsuranceObj.premium = 1208.00;
            
            IND_InsuranceDetailsLWC_controller.InsuranceWrapper motorInsuranceObj = new IND_InsuranceDetailsLWC_controller.InsuranceWrapper();
            motorInsuranceObj.selectedProduct = 'Health Insurance'; 
            motorInsuranceObj.selectedPlan = 'PPD_2L_3Y';
            motorInsuranceObj.isFunded = true;
            motorInsuranceObj.premium = 1208.00;
            
            reqWrapper.healthInsurance = healthInsuranceObj;
            reqWrapper.gpaInsurance = gpaInsuranceObj;
            reqWrapper.comboInsurance = healthInsuranceObj;
            reqWrapper.motorInsurance = gpaInsuranceObj;
            reqWrapper.loanApplicationId = opp.Id;
            reqWrapper.applicantId = applicant.id;
            reqWrapper.ltvWithInsurance = '0.24';
			reqWrapper.ltvWithoutInsurance = '0.33';
            reqWrapper.totalInsurancePayable = 50000.00;
            reqWrapper.proposalLtv = 50000.00;
      //      reqWrapper.applicantType = 'Borrower';
                
            Test.startTest();
            String response = IND_InsuranceDetailsLWC_controller.submitInsuranceDetails(JSON.serialize(reqWrapper));           
            Test.stopTest();
            System.assertNotEquals(null, response);
          
        }Catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }         
    }*/
}