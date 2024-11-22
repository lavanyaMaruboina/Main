@isTest
private class IND_LWC_ExposureAnalysisTest {
    
    @testSetup static void testDataMethod() {
        
        Opportunity opp = new Opportunity();
        opp.Name = 'opName';
        opp.Applicant_Name__c = 'test';
        opp.Approval_Status__c = 'Pending';
        opp.StageName = 'Qualification';
        opp.CloseDate = System.today();
        opp.Loan_amount__c = '120000';
        opp.Sub_Stage__c = 'CIBIL';
        insert opp;
        
        List<Applicant__c> lstApl = new List<Applicant__c>();
        for(Integer i=0;i<1;i++) {
            lstApl.add(new Applicant__c(Name = 'apName'+i,
                                        Opportunity__c = opp.Id,
                                        Customer_Code__c = 'CU010104',
                                        Contact_number__c = '9988776655',Total_Insurance_Payable__c = 10000,Invalid_Customer_Code__c=''));
        }
        insert lstApl;

        Customer_Dedupe_Response__c customerDedupe = new Customer_Dedupe_Response__c();
            customerDedupe.Applicant__c = lstApl[0].Id;
            customerDedupe.IND_isNewCustomer__c = false;
            insert customerDedupe;
        
        List<Customer_Code__c> listOfCustCode = new List<Customer_Code__c>();
        for(Integer i=0;i<5;i++) {
            listOfCustCode.add(new Customer_Code__c(Loan_Application__c = opp.Id,Cheque_Return_Count__c = 2,Name = 'CU010104'+i));
        }
        insert listOfCustCode;
        
        /*
Customer_Code__c cco = new Customer_Code__c();
cco.Name = 'ccName';
cco.Loan_Application__c = opp.Id;
cco.Cheque_Return_Count__c = 2;
cco.Name = 'CU010104';
insert cco;
*/
        
        InsuranceDetails__c ins = new InsuranceDetails__c();
        ins.Name = 'iName';
        ins.Loan_Application__c = opp.Id;
        ins.Total_insurance_payable__c = 10000;
        insert ins;
        
        List<Exposure__c> lstExp = new List<Exposure__c>();
        for(Integer i=0;i<5;i++) {
            lstExp.add(new Exposure__c(Name = 'expName'+i,
                                       Loan_Application__c = opp.id,
                                       Applicant__c = lstApl[0].id,
                                       //Customer_Code__c = cco.Id,
                                       Finance_Amt__c = 20000,
                                       Sanctioned_Amt__c = 50000,
                                       Exposure_Type__c = 'Existing',
                                       Type__c = 'Borrower Exposure',
                                       Deal_Stage__c = 'something',
                                       Deal_No__c = 'something1',
                                       Deal_Date__c = system.today()-30,
                                       Product__c = 'a',
                                       Product_Variant_Name__c = 'test',
                                       Used__c = 'Y',
                                       Status_Flag__c = 'N',
                                       Over_Due__c = 1200,
                                       AD__c = 3,
                                       PD__c = 2,
                                       Current_Demand__c = 15,
                                       Mor1__c = 'Yes',
                                       Mor2__c = 'Yes',
                                       SOH__c = 10992));
        }
        insert lstExp;
        
        Lien_Detail__c lien = new Lien_Detail__c();
        lien.Deal_No__c = lstExp[0].Id;
        lien.Name = 'testlien';
        //lien.Applicant__c = lstApl[0].Id;
        insert lien;        
    }
    
    @isTest
    public static void getRecordDetailsTest(){
        try{
                Opportunity opp = [select id from Opportunity where Name = 'opName'];
                Test.startTest();
                      IND_LWC_ExposureAnalysis.getRecordDetails(opp.Id);
                Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest static void exposureMethod1(){
        Opportunity opp = [select id from Opportunity where Name = 'opName'];
        Applicant__c apl = [select id from Applicant__c where Name = 'apName0' limit 1];
        apl.Applicant_Type__c = 'Borrower';
        apl.Cheque_Return_Count__c = 3;
        apl.Relationship_Since__c = system.today()-30;
        apl.Total_Insurance_Payable__c = 150000;
        update apl;
        Exposure__c exp = [select id,Type__c from Exposure__c where Name = 'expName0' limit 1];
        exp.Type__c  = 'Bank Exposure';
        update exp;
        
        List<string> lcc = new List<string>{'CU010104','CU010105'};
            Customer_Code__c cc = [select id from Customer_Code__c where Loan_Application__c =: opp.Id limit 1];
        //cc.Applicant__c = apl.id;
        cc.IsExposureTriggered__c = false;
        update cc;
        
        Final_Term__c ftd2 = new Final_Term__c();
            ftd2.CRM_IRR__c = 120;
            ftd2.Loan_Application__c = opp.Id;
            ftd2.Holiday_period__c='30';
            ftd2.EMI_Amount__c= 10000;
            ftd2.LtvEngine_Ltv__c = null;
            insert ftd2;
        
        test.startTest();
        IND_LWC_ExposureAnalysis.getExposureDetails(opp.id);
        IND_LWC_ExposureAnalysis.getLienDetails(exp.id);
        IND_LWC_ExposureAnalysis.getCustomerCodeDetails(opp.id);
        IND_LWC_ExposureAnalysis.checkCustomerCodeDetails(opp.id, 'CU010104');
        IND_LWC_ExposureAnalysis.checkCustomerCodeDetails(null,null);
        IND_LWC_ExposureAnalysis.getCustomerCodesExpAPI(opp.id);
        IND_LWC_ExposureAnalysis.allCostCodeTrgExpAPI(opp.id);
        IND_LWC_ExposureAnalysis.deletecustCodes(cc.id);
        IND_LWC_ExposureAnalysis.updateCustomerCode(lcc);
        test.stopTest();
    }  
    
    @isTest static void testGetExposureDetailsType1(){
        try{
            Opportunity opp = [select id from Opportunity where Name = 'opName'];
            test.startTest();
            Exposure__c exp = [select id,Type__c from Exposure__c where Name = 'expName0' limit 1];
            exp.Type__c  = 'Bank Exposure';
            update exp;
            IND_LWC_ExposureAnalysis.getExposureDetails(opp.id);
            test.stopTest();
        }catch(Exception ex){
            System.assertEquals('Script-thrown exception',ex.getMessage());
        }
    }
    
    @isTest static void testGetExposureDetailsType2(){
        try{
            Opportunity opp = [select id from Opportunity where Name = 'opName'];
            test.startTest();
            Exposure__c exp = [select id,Type__c from Exposure__c where Name = 'expName0' limit 1];
            exp.Type__c  = 'Co-Borrower Exposure';
            update exp;
            IND_LWC_ExposureAnalysis.getExposureDetails(opp.id);
            test.stopTest();
        }catch(Exception ex){
            System.assertEquals('Script-thrown exception',ex.getMessage());
        }
    }
    
    @isTest static void testGetExposureDetailsType3(){
        try{
            Opportunity opp = [select id from Opportunity where Name = 'opName'];
            test.startTest();
            Exposure__c exp = [select id,Type__c from Exposure__c where Name = 'expName0' limit 1];
            exp.Type__c  = 'Additional Customer';
            update exp;
            IND_LWC_ExposureAnalysis.getExposureDetails(opp.id);
            test.stopTest();
        }catch(Exception ex){
            System.assertEquals('Script-thrown exception',ex.getMessage());
        }
    }
    
    @isTest static void testGetBankExposureDetails(){
        Opportunity opp = [select id from Opportunity where Name = 'opName'];
        Exposure__c exp = [select id from Exposure__c where Name = 'expName2' limit 1];
        exp.Type__c = 'Bank Exposure';        
        update exp;
        test.startTest();
        IND_LWC_ExposureAnalysis.getBankExposureDetails(opp.id);
        test.stopTest();
    }
    
    
    @isTest static void testGetOpptyStage(){
        try{
            Opportunity opp = [select id from Opportunity where Name = 'opName'];
            test.startTest();
            IND_LWC_ExposureAnalysis.getOpptyStage(opp.id);
            IND_LWC_ExposureAnalysis.getOpptyStage('exception');
            test.stopTest();
        }catch(Exception ex){
            System.assertEquals('Script-thrown exception',ex.getMessage());
        }
    }
    
    
    @isTest static void testGetFamilyExposureDetails(){
        Opportunity opp = [select id from Opportunity where Name = 'opName'];
        Exposure__c exp = [select id from Exposure__c where Name = 'expName3' limit 1];
        exp.Type__c = 'Family Exposure'; 
        update exp;
        test.startTest();
        IND_LWC_ExposureAnalysis.getFamilyExposureDetails(opp.id);
        test.stopTest();
    }  
    
    @isTest static void testGetExpRecordsType1(){
        Opportunity opp = [select id from Opportunity where Name = 'opName'];
        
        test.startTest();
        IND_LWC_ExposureAnalysis.getExpRecords(opp.id);
        test.stopTest();
    }
    
    @isTest static void testGetExpRecordsType2(){
        Opportunity opp = [select id from Opportunity where Name = 'opName'];
        Exposure__c exp = [select id,Type__c from Exposure__c where Name = 'expName0' limit 1];
        exp.Type__c  = 'Co-Borrower Exposure';
        update exp;
        test.startTest();
        IND_LWC_ExposureAnalysis.getExpRecords(opp.id);
        test.stopTest();
    }
    
    @isTest static void testGetExpRecordsType3(){
        Opportunity opp = [select id from Opportunity where Name = 'opName'];
        Exposure__c exp = [select id,Type__c from Exposure__c where Name = 'expName0' limit 1];
        exp.Type__c  = 'Additional Customer';
        update exp;
        test.startTest();
        IND_LWC_ExposureAnalysis.getExpRecords(opp.id);
        test.stopTest();
    }
    
    @isTest static void testGetExpRecordsType4(){
        try{
        Opportunity opp = TestDataUtility.createTestOpportunity(false);
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            
            Applicant__c applicant = TestDataUtility.createTestApplicantForSMS(false);
            applicant.Opportunity__c = opp.Id;
            applicant.Applicant_Type__c = system.label.Borrower;
            applicant.Cheque_Return_Count__c = 5;
            applicant.Relationship_Since__c = Date.newInstance(2015, 11,11);
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert applicant;
            }
            
            Customer_Code__c cust2 = new Customer_Code__c();
            cust2.Name = 'test';
            cust2.Loan_Application__c = opp.Id;
            insert cust2;
            
            Exposure__c e1 = new Exposure__c();
            e1.Applicant__c = applicant.Id;
            e1.Loan_Application__c = opp.Id;
            e1.Customer_Code__c = cust2.Id;
            e1.Type__c = system.Label.Bank_Exposure;
            insert e1;
            
             Final_Term__c ftd2 = new Final_Term__c();
            ftd2.CRM_IRR__c = 120;
            ftd2.Loan_Application__c = opp.Id;
            ftd2.Holiday_period__c='30';
            ftd2.EMI_Amount__c= 10000;
            ftd2.LtvEngine_Ltv__c = null;
            insert ftd2;
            
            Lien_Detail__c ld1 = new Lien_Detail__c();
            ld1.Deal_No__c = e1.Id;
            insert ld1;
            
        test.startTest();
        IND_LWC_ExposureAnalysis.getExpRecords(opp.id);
        test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void deletecustCodesTest(){
        try{
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            
            Applicant__c applicant = TestDataUtility.createTestApplicantForSMS(false);
            applicant.Opportunity__c = opp.Id;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert applicant;
            }
            
            Customer_Code__c cust2 = new Customer_Code__c();
            cust2.Name = 'test';
            cust2.Loan_Application__c = opp.Id;
            insert cust2;
            
            Exposure__c e1 = new Exposure__c();
            e1.Applicant__c = applicant.Id;
            e1.Loan_Application__c = opp.Id;
            e1.Customer_Code__c = cust2.Id;
            insert e1;
            
            Lien_Detail__c ld1 = new Lien_Detail__c();
            ld1.Deal_No__c = e1.Id;
            insert ld1;
            
            Test.startTest();
                 IND_LWC_ExposureAnalysis.deletecustCodes(cust2.Id);
            Test.stopTest();
            
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void getFamilyExpCustCodesTest(){
        
               Opportunity opga1 = new Opportunity();
                opga1.StageName = 'Qualification';
                opga1.CloseDate = Date.newInstance(2021, 1, 11);
                opga1.Name = 'testone';
                insert opga1;
        
                Applicant__c applicant = new Applicant__c();
                applicant.Opportunity__c = opga1.Id;
                applicant.Contact_number__c = '9743514830';
                applicant.Applicant_Type__c = 'Borrower';
                applicant.Customer_Code__c = 'test123';
                applicant.Name = 'res456';
                insert applicant;
            
            Customer_Code__c cust2 = new Customer_Code__c();
            cust2.Name = 'test';
            cust2.Loan_Application__c = opga1.Id;
            cust2.Customer_Name__c = 'test';
            cust2.Applicant__c = applicant.Id;
            insert cust2;
            
            Exposure__c e1 = new Exposure__c();
            e1.Applicant__c = applicant.Id;
            e1.Loan_Application__c = opga1.Id;
            e1.Customer_Code__c = cust2.Id;
            e1.Type__c = system.label.Family_Exposure;
            insert e1;
        
        Test.startTest();
               IND_LWC_ExposureAnalysis.getFamilyExpCustCodes(opga1.Id);
        Test.stopTest();
        
      
    }
    
    @isTest
    public static void getAdditionalExposureDetailsTest(){
        try{
            Opportunity opga1 = new Opportunity();
                opga1.StageName = 'Qualification';
                opga1.CloseDate = Date.newInstance(2021, 1, 11);
                opga1.Name = 'testone';
                insert opga1;
        
                Applicant__c applicant = new Applicant__c();
                applicant.Opportunity__c = opga1.Id;
                applicant.Contact_number__c = '9743514830';
                applicant.Applicant_Type__c = 'Borrower';
                applicant.Customer_Code__c = 'test123';
                applicant.Name = 'res456';
                insert applicant;
            
            Customer_Code__c cust2 = new Customer_Code__c();
            cust2.Name = 'test';
            cust2.Loan_Application__c = opga1.Id;
            cust2.Customer_Name__c = 'result';
            cust2.Applicant__c = applicant.Id;
            insert cust2;
            
            Exposure__c e1 = new Exposure__c();
            e1.Applicant__c = applicant.Id;
            e1.Loan_Application__c = opga1.Id;
            e1.Customer_Code__c = cust2.Id;
            e1.Type__c = system.label.Additional_Customer;
            insert e1;
            
            Test.startTest();
                 IND_LWC_ExposureAnalysis.getAdditionalExposureDetails(opga1.Id);
            e1.Customer_Code__c = null;
            update e1;
                 IND_LWC_ExposureAnalysis.getAdditionalExposureDetails(opga1.Id);
            	IND_LWC_ExposureAnalysis.getFamilyExpCustCodes(opga1.Id);
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void getAdditionalExposureDetailsTest1(){
        try{
            Opportunity opga1 = new Opportunity();
                opga1.StageName = 'Qualification';
                opga1.CloseDate = Date.newInstance(2021, 1, 11);
                opga1.Name = 'testone';
                insert opga1;
        
                Applicant__c applicant = new Applicant__c();
                applicant.Opportunity__c = opga1.Id;
                applicant.Contact_number__c = '9743514830';
                applicant.Applicant_Type__c = 'Borrower';
                applicant.Customer_Code__c = 'test123';
                applicant.Name = 'res456';
                insert applicant;
            
            Customer_Code__c cust2 = new Customer_Code__c();
            cust2.Name = 'test';
            cust2.Loan_Application__c = opga1.Id;
            cust2.Customer_Name__c = 'result';
            cust2.Applicant__c = applicant.Id;
            insert cust2;
            
            List<Exposure__c> exList = new List<Exposure__c>();
            Exposure__c e1 = new Exposure__c();
            e1.Applicant__c = applicant.Id;
            e1.Loan_Application__c = opga1.Id;
            e1.Customer_Code__c = cust2.Id;
            e1.Type__c = system.label.Additional_Customer;
            insert e1;
            
            string k1 = cust2.Name+'-' + Cust2.Customer_Name__c;
            exList.add(e1);
            
            
            
            Test.startTest();
                 IND_LWC_ExposureAnalysis.getAdditionalExposureDetails(opga1.Id);
                 IND_LWC_ExposureAnalysis.getAdditionalExposureDetails(null);
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void getOpptyStageCAMTest(){
          Profile p = [SELECT Id FROM Profile WHERE Name='IBL CVO'];
        User u = new User(Alias = 'standt2', Email='standarduser2@testorg.com',MobilePhone = '9999999999',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,Maker_Id__c='12',IsActive = true,
                          TimeZoneSidKey='America/Los_Angeles',UserName='test_userprod1123@indusbank.com');
        insert u;
        System.runAs(u) 
        {       
          Opportunity opga1 = new Opportunity();
          opga1.StageName = 'Qualification';
          opga1.CloseDate = Date.newInstance(2021, 1, 11);
          opga1.Name = 'testone';
          insert opga1;
            
            Applicant__c applicant = TestDataUtility.createTestApplicantForSMS(false);
            applicant.Opportunity__c = opga1.Id;
            applicant.Applicant_Type__c  = null;
            applicant.Scorecard_Decision__c = 'Red';
            applicant.Applicant_Type__c = 'Co-borrower';
            insert applicant;
            
            CAM__c cam1 = new CAM__c();
            cam1.Loan_Application__c = opga1.Id;
            cam1.BE_CVO_Remark__c = 'testbe';
            cam1.Conditional_Approval__c = 'testapprov';
            cam1.Proposal_Status__c = 'testproposal';
            cam1.CCC_Exposure_Editable__c = true;
            insert cam1;
        
            Test.startTest();
                  IND_LWC_ExposureAnalysis.getOpptyStageCAM(opga1.Id);
            IND_LWC_ExposureAnalysis.getApplicantInfo(opga1.Id);
            Test.stopTest();
        }
    }
    
    @isTest//Enhancement for INDI-3470
    public static void updateTotalExposureAmountTest1(){
        try{
            Opportunity opga1 = new Opportunity();
                opga1.StageName = 'Qualification';
                opga1.CloseDate = Date.newInstance(2021, 1, 11);
                opga1.Name = 'testone';
            	opga1.Current_Exposure_Amt__c = 780;
            	opga1.Existing_Borrowers_Exposure_Amt__c = 178;
            	opga1.Existing_Co_Borrowers_Exposure_Amt__c = 578;
            	opga1.Existing_Others_Exposure_Amt__c = 278;
            	opga1.Total_Bank_Exposure__c = 478;
            	opga1.Total_Exposures_Amount__c = 478;
                insert opga1;
            	IND_LWC_ExposureAnalysis.ExposureWrapper exposureWrapperData = new IND_LWC_ExposureAnalysis.ExposureWrapper();
            	exposureWrapperData.currentExposureAmount = 102;
           		exposureWrapperData.existingBorrowerExposureAmount =105;
                exposureWrapperData.existingCoBorrowerExposureAmount =1540;
                exposureWrapperData.existingOtherExposureAmount =1231;
                exposureWrapperData.bankExposureAmount =1243;
                exposureWrapperData.totalExposureAmount =9782;
            Test.startTest();
                IND_LWC_ExposureAnalysis.updateTotalExposureAmount(opga1.Id, exposureWrapperData);
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
 }