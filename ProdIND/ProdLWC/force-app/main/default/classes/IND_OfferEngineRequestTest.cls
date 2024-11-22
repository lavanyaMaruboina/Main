@isTest
public class IND_OfferEngineRequestTest {
    
    
    @isTest
    public static void verifyIND_OfferEngineRequest(){
        Opportunity opc1 = new Opportunity();
        opc1.StageName = 'Qualification';
        opc1.Sub_Stage__c = 'User Details';
        opc1.CloseDate = Date.newInstance(2021, 1, 11);
        opc1.Name = 'testone';
        insert opc1;
        Vehicle_Detail__c vehObj = new Vehicle_Detail__c(Loan_Application__c =  opc1.Id, Valuation_price__c = 10000,Grid_value__c = 2000, Selling_Price__c = 5000);
        insert vehObj;
        
        List<Applicant__c> lstApl = new List<Applicant__c>();
        for(Integer i=0;i<1;i++) {
            lstApl.add(new Applicant__c(Name = 'apName'+i,
                                        Opportunity__c = opc1.Id,
                                        Applicant_Type__c = 'Borrower',
                                        Check_Eligibility_Match__c = True,
                                        Contact_number__c = '9988776655',
                                        Scorecard_Decision__c='Test',
                                        ScoreCard_Description__c='Test'));
        }
        insert lstApl;
        
        CIBIL_Details__c cbd1 = new CIBIL_Details__c();
        cbd1.Applicant__c = lstApl[0].Id;
        cbd1.CIC_No__c = 'testcbd';
        insert cbd1;
        
        Final_Term__c ft1 = new Final_Term__c();
        ft1.Loan_Application__c = opc1.Id;
        ft1.Tenure__c = '5';
        ft1.LtvEngine_Ltv__c = 50;
        ft1.PricingEngine_thresholdNetrr__c = 5;
        ft1.Loan_Amount__c = '50000';
        ft1.Required_CRM_IRR__c = '100';
        insert ft1;  
        
        
        RequestWrapper reqWrapper = new RequestWrapper();
        reqWrapper.leadId = 'L0001';
        reqWrapper.panNumber = 'VGPTT2019A';
        reqWrapper.firstName = 'John';
        reqWrapper.lastName = 'Smith';
        reqWrapper.currentScreen ='Offer'; 
        reqWrapper.product = 'Passenger Vehicles';
        reqWrapper.vehicleType = 'Used';
        reqWrapper.loanAmount = '1000';
        reqWrapper.sumOfFundedInsurance ='10000'; 
        reqWrapper.fundingOnExShowroom = 'true';
        reqWrapper.crmIrrRequested = '50';
        reqWrapper.income = '10000';
        reqWrapper.loanApplicationId = opc1.Id;
        reqWrapper.emi = '1000';
        reqWrapper.exShowroomPrice ='10000'; 
        reqWrapper.onRoadPrice = '8000';
        reqWrapper.tenure = '5';
        reqWrapper.sumOfFundedInsurance = '10000';
        reqWrapper.loanAmountChanged = '1000';
        reqWrapper.tenureChanged = '7';
        IND_OfferEngineRequest result = new IND_OfferEngineRequest(reqWrapper, new List<Final_Term__c>{ft1});
        Boolean isValid = result.validate(System.Label.OfferEngine);
        System.assert(isValid);
        
        Map<String,String> resultHeadersMap = result.getHttpRequestHeaders();
        System.assert(!resultHeadersMap.isEmpty()); 
    }  
    
    @isTest
    public static void verifyIND_OfferEngineRequestforCAMComponent(){
        Opportunity opc1 = new Opportunity();
        opc1.StageName = 'Qualification';
        opc1.Sub_Stage__c = 'User Details';
        opc1.CloseDate = Date.newInstance(2021, 1, 11);
        opc1.Name = 'testone';
        insert opc1;
        
        Vehicle_Detail__c vehObj = new Vehicle_Detail__c(Loan_Application__c =  opc1.Id, Valuation_price__c = 10000,Grid_value__c = 2000, Selling_Price__c = 5000);
        insert vehObj;
        
        List<Applicant__c> lstApl = new List<Applicant__c>();
        for(Integer i=0;i<1;i++) {
            lstApl.add(new Applicant__c(Name = 'apName'+i,
                                        Opportunity__c = opc1.Id,
                                        Applicant_Type__c = 'Borrower',
                                        Check_Eligibility_Match__c = True,
                                        Contact_number__c = '9988776655',
                                        Scorecard_Decision__c='Test',
                                        ScoreCard_Description__c='Test'));
        }
        insert lstApl;
        
        CIBIL_Details__c cbd1 = new CIBIL_Details__c();
        cbd1.Applicant__c = lstApl[0].Id;
        cbd1.CIC_No__c = 'testcbd';
        insert cbd1;
        
        Final_Term__c ft1 = new Final_Term__c();
        ft1.Loan_Application__c = opc1.Id;
        ft1.Tenure__c = '5';
        ft1.LtvEngine_Ltv__c = 50;
        ft1.PricingEngine_thresholdNetrr__c = 5;
        ft1.Loan_Amount__c = '50000';
        ft1.Required_CRM_IRR__c = '100';
        insert ft1;  
        
        
        RequestWrapper reqWrapper = new RequestWrapper();
        reqWrapper.leadId = 'L0001';
        reqWrapper.panNumber = 'VGPTT2019A';
        reqWrapper.firstName = 'John';
        reqWrapper.lastName = 'Smith';
        reqWrapper.currentScreen ='CAM and Approval Log';
        reqWrapper.product = 'Passenger Vehicles';
        reqWrapper.vehicleType = 'Used';
        reqWrapper.loanAmount = '1000';
        reqWrapper.sumOfFundedInsurance ='10000'; 
        reqWrapper.fundingOnExShowroom = 'true';
        reqWrapper.crmIrrRequested = '50';
        reqWrapper.income = '10000';
        reqWrapper.loanApplicationId = opc1.Id;
        reqWrapper.emi = '1000';
        reqWrapper.exShowroomPrice ='10000'; 
        reqWrapper.onRoadPrice = '8000';
        reqWrapper.tenure = '5';
        reqWrapper.sumOfFundedInsurance = '10000';
        reqWrapper.loanAmountChanged = '1000';
        reqWrapper.tenureChanged = '7';
        IND_OfferEngineRequest result = new IND_OfferEngineRequest(reqWrapper, new List<Final_Term__c>{ft1});
        Map<String,String> resultHeadersMap = result.getHttpRequestHeaders();
        System.assert(!resultHeadersMap.isEmpty()); 
    } 
    
    @isTest
    public static void verifyIND_OfferEngineRequest1(){
        Opportunity opc1 = new Opportunity();
        opc1.StageName = 'Qualification';
        opc1.Sub_Stage__c = 'User Details';
        opc1.CloseDate = Date.newInstance(2021, 1, 11);
        opc1.Name = 'testone';
        insert opc1;
        
        List<Applicant__c> lstApl = new List<Applicant__c>();
        for(Integer i=0;i<1;i++) {
            lstApl.add(new Applicant__c(Name = 'apName'+i,
                                        Opportunity__c = opc1.Id,
                                        Applicant_Type__c = 'Borrower',
                                        Check_Eligibility_Match__c = True,
                                        Contact_number__c = '9988776655',
                                        Scorecard_Decision__c='Test',
                                        ScoreCard_Description__c='Test'));
        }
        insert lstApl;
        
        CIBIL_Details__c cbd1 = new CIBIL_Details__c();
        cbd1.Applicant__c = lstApl[0].Id;
        cbd1.CIC_No__c = 'testcbd';
        insert cbd1;
        
        Final_Term__c ft1 = new Final_Term__c();
        ft1.Loan_Application__c = opc1.Id;
        ft1.Tenure__c = '5';
        ft1.LtvEngine_Ltv__c = 50;
        ft1.PricingEngine_thresholdNetrr__c = 5;
        ft1.Loan_Amount__c = '50000';
        ft1.Required_CRM_IRR__c = '100';
        insert ft1;  
        
        
        RequestWrapper reqWrapper = new RequestWrapper();
        reqWrapper.leadId = 'L0001';
        reqWrapper.panNumber = 'VGPTT2019A';
        reqWrapper.firstName = 'John';
        reqWrapper.lastName = 'Smith';
        reqWrapper.currentScreen ='Offer'; 
        reqWrapper.product = 'Passenger Vehicles';
        reqWrapper.vehicleType = 'New';
        reqWrapper.loanAmount = '1000';
        reqWrapper.sumOfFundedInsurance ='10000'; 
        reqWrapper.fundingOnExShowroom = 'true';
        reqWrapper.crmIrrRequested = '50';
        reqWrapper.income = '10000';
        reqWrapper.loanAmountChanged = '1000';
        reqWrapper.emi = '1000';
        reqWrapper.exShowroomPrice ='10000'; 
        reqWrapper.onRoadPrice = '8000';
        reqWrapper.tenure = '5';
        reqWrapper.sumOfFundedInsurance = '10000';
        reqWrapper.tenureChanged = '7';
        IND_OfferEngineRequest result = new IND_OfferEngineRequest(reqWrapper, new List<Final_Term__c>{ft1});
        Boolean isValid = result.validate(System.Label.OfferEngine);
        System.assert(isValid);
        
        Map<String,String> resultHeadersMap = result.getHttpRequestHeaders();
        System.assert(!resultHeadersMap.isEmpty()); 
    }  
    
    
    @isTest
    public static void verifyIND_OfferEngineRequest2(){
        Opportunity opc1 = new Opportunity();
        opc1.StageName = 'Qualification';
        opc1.Sub_Stage__c = 'User Details';
        opc1.CloseDate = Date.newInstance(2021, 1, 11);
        opc1.Name = 'testone';
        insert opc1;
        
        List<Applicant__c> lstApl = new List<Applicant__c>();
        for(Integer i=0;i<1;i++) {
            lstApl.add(new Applicant__c(Name = 'apName'+i,
                                        Opportunity__c = opc1.Id,
                                        Applicant_Type__c = 'Borrower',
                                        Check_Eligibility_Match__c = True,
                                        Contact_number__c = '9988776655',
                                        Scorecard_Decision__c='Test',
                                        ScoreCard_Description__c='Test'));
        }
        insert lstApl;
        
        CIBIL_Details__c cbd1 = new CIBIL_Details__c();
        cbd1.Applicant__c = lstApl[0].Id;
        cbd1.CIC_No__c = 'testcbd';
        insert cbd1;
        
        Final_Term__c ft1 = new Final_Term__c();
        ft1.Loan_Application__c = opc1.Id;
        ft1.Tenure__c = '5';
        ft1.LtvEngine_Ltv__c = 50;
        ft1.PricingEngine_thresholdNetrr__c = 5;
        ft1.Loan_Amount__c = '50000';
        ft1.Required_CRM_IRR__c = '100';
        insert ft1;  
        
        
        RequestWrapper reqWrapper = new RequestWrapper();
        reqWrapper.leadId = 'L0001';
        reqWrapper.panNumber = 'VGPTT2019A';
        reqWrapper.firstName = 'John';
        reqWrapper.lastName = 'Smith';
        reqWrapper.currentScreen ='Final Offer';
        reqWrapper.product = 'Passenger Vehicles';
        reqWrapper.vehicleType = 'New';
        reqWrapper.loanAmount = '1000';
        reqWrapper.sumOfFundedInsurance ='10000'; 
        reqWrapper.fundingOnExShowroom = 'true';
        reqWrapper.crmIrrRequested = '50';
        reqWrapper.income = '10000';
        reqWrapper.loanAmountChanged = '1000';
        reqWrapper.emi = '1000';
        reqWrapper.exShowroomPrice ='10000'; 
        reqWrapper.onRoadPrice = '8000';
        reqWrapper.tenure = '5';
        reqWrapper.sumOfFundedInsurance = '10000';
        reqWrapper.tenureChanged = '7';
        IND_OfferEngineRequest result = new IND_OfferEngineRequest(reqWrapper, new List<Final_Term__c>{ft1});
        Boolean isValid = result.validate(System.Label.OfferEngine);
        System.assert(isValid);
        
        Map<String,String> resultHeadersMap = result.getHttpRequestHeaders();
        System.assert(!resultHeadersMap.isEmpty()); 
    } 
    
    @isTest
    public static void verifyIND_OfferEngineRequest3(){
        Opportunity opc1 = new Opportunity();
        opc1.StageName = 'Qualification';
        opc1.Sub_Stage__c = 'User Details';
        opc1.CloseDate = Date.newInstance(2021, 1, 11);
        opc1.Name = 'testone';
        insert opc1;
        
        List<Applicant__c> lstApl = new List<Applicant__c>();
        for(Integer i=0;i<1;i++) {
            lstApl.add(new Applicant__c(Name = 'apName'+i,
                                        Opportunity__c = opc1.Id,
                                        Applicant_Type__c = 'Borrower',
                                        Check_Eligibility_Match__c = True,
                                        Contact_number__c = '9988776655',
                                        Scorecard_Decision__c='Test',
                                        ScoreCard_Description__c='Test'));
        }
        insert lstApl;
        
        CIBIL_Details__c cbd1 = new CIBIL_Details__c();
        cbd1.Applicant__c = lstApl[0].Id;
        cbd1.CIC_No__c = 'testcbd';
        insert cbd1;
        
        Final_Term__c ft1 = new Final_Term__c();
        ft1.Loan_Application__c = opc1.Id;
        ft1.Tenure__c = '5';
        ft1.LtvEngine_Ltv__c = 50;
        ft1.PricingEngine_thresholdNetrr__c = 5;
        ft1.Loan_Amount__c = '50000';
        ft1.Required_CRM_IRR__c = '100';
        insert ft1;  
        
        
        RequestWrapper reqWrapper = new RequestWrapper();
        reqWrapper.leadId = 'L0001';
        reqWrapper.panNumber = 'VGPTT2019A';
        reqWrapper.firstName = 'John';
        reqWrapper.lastName = 'Smith';
        reqWrapper.currentScreen ='Final Offer';
        reqWrapper.product = 'Two Wheeler';
        reqWrapper.vehicleType = 'New';
        reqWrapper.loanAmount = '1000';
        reqWrapper.sumOfFundedInsurance ='10000'; 
        reqWrapper.fundingOnExShowroom = 'true';
        reqWrapper.crmIrrRequested = '50';
        reqWrapper.income = '10000';
        reqWrapper.loanAmountChanged = '1000';
        reqWrapper.emi = '1000';
        reqWrapper.exShowroomPrice ='10000'; 
        reqWrapper.onRoadPrice = '8000';
        reqWrapper.tenure = '5';
        reqWrapper.sumOfFundedInsurance = '10000';
        reqWrapper.tenureChanged = '7';
        IND_OfferEngineRequest result = new IND_OfferEngineRequest(reqWrapper, new List<Final_Term__c>{ft1});
        Boolean isValid = result.validate(System.Label.OfferEngine);
        System.assert(isValid);
        
        Map<String,String> resultHeadersMap = result.getHttpRequestHeaders();
        System.assert(!resultHeadersMap.isEmpty()); 
    } 
    
    
    @isTest
    public static void verifyIND_OfferEngineRequest4(){
        Opportunity opc1 = new Opportunity();
        opc1.StageName = 'Qualification';
        opc1.Sub_Stage__c = 'User Details';
        opc1.CloseDate = Date.newInstance(2021, 1, 11);
        opc1.Name = 'testone';
        insert opc1;
        
        List<Applicant__c> lstApl = new List<Applicant__c>();
        for(Integer i=0;i<1;i++) {
            lstApl.add(new Applicant__c(Name = 'apName'+i,
                                        Opportunity__c = opc1.Id,
                                        Applicant_Type__c = 'Borrower',
                                        Check_Eligibility_Match__c = True,
                                        Contact_number__c = '9988776655',
                                        Scorecard_Decision__c='Test',
                                        ScoreCard_Description__c='Test'));
        }
        insert lstApl;
        
        CIBIL_Details__c cbd1 = new CIBIL_Details__c();
        cbd1.Applicant__c = lstApl[0].Id;
        cbd1.CIC_No__c = 'testcbd';
        insert cbd1;
        
        Final_Term__c ft1 = new Final_Term__c();
        ft1.Loan_Application__c = opc1.Id;
        ft1.Tenure__c = '5';
        ft1.LtvEngine_Ltv__c = 50;
        ft1.PricingEngine_thresholdNetrr__c = 5;
        ft1.Loan_Amount__c = '50000';
        ft1.Required_CRM_IRR__c = '100';
        insert ft1;  
        
        
        RequestWrapper reqWrapper = new RequestWrapper();
        reqWrapper.leadId = 'L0001';
        reqWrapper.panNumber = 'VGPTT2019A';
        reqWrapper.firstName = 'John';
        reqWrapper.lastName = 'Smith';
        reqWrapper.currentScreen ='Offer';
        reqWrapper.product = 'Two Wheeler';
        reqWrapper.vehicleType = 'New';
        reqWrapper.loanAmount = '1000';
        reqWrapper.sumOfFundedInsurance ='10000'; 
        reqWrapper.fundingOnExShowroom = 'true';
        reqWrapper.crmIrrRequested = '50';
        reqWrapper.income = '10000';
        reqWrapper.loanAmountChanged = '1000';
        reqWrapper.emi = '1000';
        reqWrapper.exShowroomPrice ='10000'; 
        reqWrapper.onRoadPrice = '8000';
        reqWrapper.tenure = '5';
        reqWrapper.sumOfFundedInsurance = '10000';
        reqWrapper.tenureChanged = '7';
        IND_OfferEngineRequest result = new IND_OfferEngineRequest(reqWrapper, new List<Final_Term__c>{ft1});
        Boolean isValid = result.validate(System.Label.OfferEngine);
        System.assert(isValid);
        
        Map<String,String> resultHeadersMap = result.getHttpRequestHeaders();
        System.assert(!resultHeadersMap.isEmpty()); 
    } 
    
    
    @isTest
    public static void verifyIND_OfferEngineRequest5(){
        Opportunity opc1 = new Opportunity();
        opc1.StageName = 'Qualification';
        opc1.Sub_Stage__c = 'User Details';
        opc1.CloseDate = Date.newInstance(2021, 1, 11);
        opc1.Name = 'testone';
        insert opc1;
        
        Vehicle_Detail__c vehObj = new Vehicle_Detail__c(Loan_Application__c =  opc1.Id, Valuation_price__c = 10000,Grid_value__c = 2000, Selling_Price__c = 5000);
        insert vehObj;
        
        List<Applicant__c> lstApl = new List<Applicant__c>();
        for(Integer i=0;i<1;i++) {
            lstApl.add(new Applicant__c(Name = 'apName'+i,
                                        Opportunity__c = opc1.Id,
                                        Applicant_Type__c = 'Borrower',
                                        Check_Eligibility_Match__c = True,
                                        Contact_number__c = '9988776655',
                                        Scorecard_Decision__c='Test',
                                        ScoreCard_Description__c='Test'));
        }
        insert lstApl;
        
        CIBIL_Details__c cbd1 = new CIBIL_Details__c();
        cbd1.Applicant__c = lstApl[0].Id;
        cbd1.CIC_No__c = 'testcbd';
        insert cbd1;
        
        Final_Term__c ft1 = new Final_Term__c();
        ft1.Loan_Application__c = opc1.Id;
        ft1.Tenure__c = '5';
        ft1.LtvEngine_Ltv__c = 50;
        ft1.PricingEngine_thresholdNetrr__c = 5;
        ft1.Loan_Amount__c = '50000';
        ft1.Required_CRM_IRR__c = '100';
        insert ft1;  
        
        
        RequestWrapper reqWrapper = new RequestWrapper();
        reqWrapper.leadId = 'L0001';
        reqWrapper.panNumber = 'VGPTT2019A';
        reqWrapper.firstName = 'John';
        reqWrapper.lastName = 'Smith';
        reqWrapper.currentScreen ='Offer';
        reqWrapper.product = 'Two Wheeler';
        reqWrapper.vehicleType = 'Used';
        reqWrapper.loanAmount = '1000';
        reqWrapper.sumOfFundedInsurance ='10000'; 
        reqWrapper.fundingOnExShowroom = 'true';
        reqWrapper.crmIrrRequested = '50';
        reqWrapper.income = '10000';
        reqWrapper.loanApplicationId = opc1.Id;
        reqWrapper.emi = '1000';
        reqWrapper.exShowroomPrice ='10000'; 
        reqWrapper.onRoadPrice = '8000';
        reqWrapper.tenure = '5';
        reqWrapper.sumOfFundedInsurance = '10000';
        reqWrapper.loanAmountChanged = '1000';
        reqWrapper.tenureChanged = '7';
        IND_OfferEngineRequest result = new IND_OfferEngineRequest(reqWrapper, new List<Final_Term__c>{ft1});
        Boolean isValid = result.validate(System.Label.OfferEngine);
        System.assert(isValid);
        
        Map<String,String> resultHeadersMap = result.getHttpRequestHeaders();
        System.assert(!resultHeadersMap.isEmpty()); 
    } 
    @isTest
    public static void verifyIND_OfferEngineRequest6(){
        Opportunity opc1 = new Opportunity();
        opc1.StageName = 'Qualification';
        opc1.Sub_Stage__c = 'User Details';
        opc1.CloseDate = Date.newInstance(2021, 1, 11);
        opc1.Name = 'testone';
        insert opc1;
        
        Vehicle_Detail__c vehObj = new Vehicle_Detail__c(Loan_Application__c =  opc1.Id, Valuation_price__c = 10000,Grid_value__c = 2000, Selling_Price__c = 5000);
        insert vehObj;
        
        List<Applicant__c> lstApl = new List<Applicant__c>();
        for(Integer i=0;i<1;i++) {
            lstApl.add(new Applicant__c(Name = 'apName'+i,
                                        Opportunity__c = opc1.Id,
                                        Applicant_Type__c = 'Borrower',
                                        Check_Eligibility_Match__c = True,
                                        Contact_number__c = '9988776655',
                                        Scorecard_Decision__c='Test',
                                        ScoreCard_Description__c='Test'));
        }
        insert lstApl;
        
        CIBIL_Details__c cbd1 = new CIBIL_Details__c();
        cbd1.Applicant__c = lstApl[0].Id;
        cbd1.CIC_No__c = 'testcbd';
        insert cbd1;
        
        Final_Term__c ft1 = new Final_Term__c();
        ft1.Loan_Application__c = opc1.Id;
        ft1.Tenure__c = '5';
        ft1.LtvEngine_Ltv__c = 50;
        ft1.PricingEngine_thresholdNetrr__c = 5;
        ft1.Loan_Amount__c = '50000';
        ft1.Required_CRM_IRR__c = '100';
        insert ft1;  
        
        
        RequestWrapper reqWrapper = new RequestWrapper();
        reqWrapper.leadId = 'L0001';
        reqWrapper.panNumber = 'VGPTT2019A';
        reqWrapper.firstName = 'John';
        reqWrapper.lastName = 'Smith';
        reqWrapper.currentScreen ='Offer';
        reqWrapper.product = 'Two Wheeler';
        reqWrapper.vehicleType = 'Refinance';
        reqWrapper.loanAmount = '1000';
        reqWrapper.sumOfFundedInsurance ='10000'; 
        reqWrapper.fundingOnExShowroom = 'true';
        reqWrapper.crmIrrRequested = '50';
        reqWrapper.income = '10000';
        reqWrapper.loanApplicationId = opc1.Id;
        reqWrapper.emi = '1000';
        reqWrapper.exShowroomPrice ='10000'; 
        reqWrapper.onRoadPrice = '8000';
        reqWrapper.tenure = '5';
        reqWrapper.sumOfFundedInsurance = '10000';
        reqWrapper.loanAmountChanged = '1000';
        reqWrapper.tenureChanged = '7';
        IND_OfferEngineRequest result = new IND_OfferEngineRequest(reqWrapper, new List<Final_Term__c>{ft1});
        Boolean isValid = result.validate(System.Label.OfferEngine);
        System.assert(isValid);
        
        Map<String,String> resultHeadersMap = result.getHttpRequestHeaders();
        System.assert(!resultHeadersMap.isEmpty()); 
    }
    @isTest
    public static void verifyIND_OfferEngineRequest7(){
        Opportunity opc1 = new Opportunity();
        opc1.StageName = 'Qualification';
        opc1.Sub_Stage__c = 'User Details';
        opc1.CloseDate = Date.newInstance(2021, 1, 11);
        opc1.Name = 'testone';
        insert opc1;
        
        Vehicle_Detail__c vehObj = new Vehicle_Detail__c(Loan_Application__c =  opc1.Id, Valuation_price__c = 10000,Grid_value__c = 2000, Selling_Price__c = 5000);
        insert vehObj;
        
        List<Applicant__c> lstApl = new List<Applicant__c>();
        for(Integer i=0;i<1;i++) {
            lstApl.add(new Applicant__c(Name = 'apName'+i,
                                        Opportunity__c = opc1.Id,
                                        Applicant_Type__c = 'Borrower',
                                        Check_Eligibility_Match__c = True,
                                        Contact_number__c = '9988776655',
                                        Scorecard_Decision__c='Test',
                                        ScoreCard_Description__c='Test'));
        }
        insert lstApl;
        
        CIBIL_Details__c cbd1 = new CIBIL_Details__c();
        cbd1.Applicant__c = lstApl[0].Id;
        cbd1.CIC_No__c = 'testcbd';
        insert cbd1;
        
        Final_Term__c ft1 = new Final_Term__c();
        ft1.Loan_Application__c = opc1.Id;
        ft1.Tenure__c = '5';
        ft1.LtvEngine_Ltv__c = 50;
        ft1.PricingEngine_thresholdNetrr__c = 5;
        ft1.Loan_Amount__c = '50000';
        ft1.Required_CRM_IRR__c = '100';
        insert ft1;  
        
        
        RequestWrapper reqWrapper = new RequestWrapper();
        reqWrapper.leadId = 'L0001';
        reqWrapper.panNumber = 'VGPTT2019A';
        reqWrapper.firstName = 'John';
        reqWrapper.lastName = 'Smith';
        reqWrapper.currentScreen ='Offer';
        reqWrapper.product = 'Passenger Vehicles';
        reqWrapper.vehicleType = 'Refinance';
        reqWrapper.loanAmount = '1000';
        reqWrapper.sumOfFundedInsurance ='10000'; 
        reqWrapper.fundingOnExShowroom = 'true';
        reqWrapper.crmIrrRequested = '50';
        reqWrapper.income = '10000';
        reqWrapper.loanApplicationId = opc1.Id;
        reqWrapper.emi = '1000';
        reqWrapper.exShowroomPrice ='10000'; 
        reqWrapper.onRoadPrice = '8000';
        reqWrapper.tenure = '5';
        reqWrapper.sumOfFundedInsurance = '10000';
        reqWrapper.loanAmountChanged = '1000';
        reqWrapper.tenureChanged = '7';
        IND_OfferEngineRequest result = new IND_OfferEngineRequest(reqWrapper, new List<Final_Term__c>{ft1});
        Boolean isValid = result.validate(System.Label.OfferEngine);
        System.assert(isValid);
        
        Map<String,String> resultHeadersMap = result.getHttpRequestHeaders();
        System.assert(!resultHeadersMap.isEmpty()); 
    }
}