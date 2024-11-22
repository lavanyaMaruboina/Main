@isTest
public  class Ind_ExistingEMICtrlTest {
    @isTest
    public static void getAPIEligibityCountTest(){
        try{
                Opportunity opga1 = new Opportunity();
                opga1.StageName = 'Qualification';
                opga1.CloseDate = Date.newInstance(2021, 1, 11);
                opga1.Name = 'testone';
                opga1.isOfflineApplication__c = true;
                insert opga1;
                
                Applicant__c apga1 = new Applicant__c();
                apga1.Opportunity__c = opga1.Id;
                apga1.Contact_number__c = '9743514830';
                apga1.Applicant_Type__c = 'Borrower';
                insert apga1;
            
               Retry_Count__c rcga1 = new Retry_Count__c();
               rcga1.Loan_Application_Id__c = opga1.Id;
               rcga1.Service_Name__c = 'FinalTermApi';
               rcga1.User_Id__c = UserInfo.getUserId();
               insert rcga1;
            
               Test.startTest();
                    Ind_ExistingEMICtrl.getAPIEligibityCount(apga1.Id);
                    Ind_ExistingEMICtrl.getAPIEligibityCount('test');
               Test.stopTest();
            
            
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
     @isTest
    public static void getAPIEligibityCountTest1(){
        try{
                Opportunity opga1 = new Opportunity();
                opga1.StageName = 'Qualification';
                opga1.CloseDate = Date.newInstance(2021, 1, 11);
                opga1.Name = 'testone';
                insert opga1;
                
                Applicant__c apga2 = new Applicant__c();
                apga2.Opportunity__c = opga1.Id;
                apga2.Contact_number__c = '9743514830';
                apga2.Applicant_Type__c = 'Borrower';
                insert apga2;
            
               Retry_Count__c rcga2 = new Retry_Count__c();
               rcga2.Loan_Application_Id__c = opga1.Id;
               rcga2.Service_Name__c = 'RUNEMIEngine';
               rcga2.User_Id__c = UserInfo.getUserId();
               insert rcga2;
            
               Test.startTest();
                    Ind_ExistingEMICtrl.getAPIEligibityCount(apga2.Id);
               Test.stopTest();
            
            
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void updateApplicantOpportunityTest(){
        
                Opportunity opua2 = new Opportunity();
                opua2.StageName = 'Qualification';
                opua2.CloseDate = Date.newInstance(2021, 1, 11);
                opua2.Name = 'testone';
                insert opua2;
                
                Applicant__c apua2 = new Applicant__c();
                apua2.Opportunity__c = opua2.Id;
                apua2.Contact_number__c = '9743514830';
                apua2.Applicant_Type__c = 'Borrower';
                apua2.Income_Ca__c = 'SAL';
                insert apua2;
        
                Income_Details__c in1 = TestDataUtility.createTestIncomeDetails(false);
                in1.Applicant__c = apua2.id;
                in1.Salaried_Self_employed__c = 'Salaried';
                in1.Office_State__c = 'MAHARASHTRA';
                insert in1;
        
                Geo_State_Masters__c gm2 = new Geo_State_Masters__c();
                gm2.NeSL_State_Code__c = 'test';
                gm2.OwnerId = UserInfo.getUserId();
                gm2.Pincode_Starting_Max__c = 524;
                gm2.Pincode__c = 315;
                gm2.Name = in1.Office_State__c;
                gm2.State_Code__c = '01';
                insert gm2;
        
                Test.startTest();
                   //  Ind_ExistingEMICtrl.updateApplicantOpportunity(apua2.Id,opua2.Id);
                Test.stopTest();
    }
    
    @isTest
    public static void updateApplicantOpportunityTest1(){
        
                Opportunity opua2 = new Opportunity();
                opua2.StageName = 'Qualification';
                opua2.CloseDate = Date.newInstance(2021, 1, 11);
                opua2.Name = 'testone';
                insert opua2;
                
                Applicant__c apua2 = new Applicant__c();
                apua2.Opportunity__c = opua2.Id;
                apua2.Contact_number__c = '9743514830';
                apua2.Applicant_Type__c = 'Borrower';
                apua2.Income_Ca__c = 'SEP';
                insert apua2;
        
                Income_Details__c in1 = TestDataUtility.createTestIncomeDetails(false);
                in1.Applicant__c = apua2.id;
                in1.Salaried_Self_employed__c = 'Self employed';
                in1.Office_State__c = 'MAHARASHTRA';
                insert in1;
        
                Geo_State_Masters__c gm2 = new Geo_State_Masters__c();
                gm2.NeSL_State_Code__c = 'test';
                gm2.OwnerId = UserInfo.getUserId();
                gm2.Pincode_Starting_Max__c = 524;
                gm2.Pincode__c = 315;
                gm2.Name = in1.Office_State__c;
                gm2.State_Code__c = '01';
                insert gm2;
        
                Test.startTest();
                    // Ind_ExistingEMICtrl.updateApplicantOpportunity(apua2.Id,opua2.Id);
                    // Ind_ExistingEMICtrl.updateApplicantOpportunity(null,null);
                Test.stopTest();
    }
    
    @isTest
    public static void updateRetryCountTest(){
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
            
               Retry_Count__c rcga2 = new Retry_Count__c();
               rcga2.Loan_Application_Id__c = opp.Id;
               rcga2.Service_Name__c = 'RUNEMIEngine';
               rcga2.User_Id__c = UserInfo.getUserId();
               insert rcga2;
            
               Test.startTest();
                    Ind_ExistingEMICtrl.updateRetryCount(applicant.Id,opp.Id);
               Test.stopTest();
            
                 
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
     @isTest
    public static void updateRetryCountTest11(){
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
            
               Retry_Count__c rcga2 = new Retry_Count__c();
               rcga2.Loan_Application_Id__c = opp.Id;
               rcga2.Applicant__c = applicant.Id;
               rcga2.Service_Name__c = 'RUNEMIEngine';
               rcga2.User_Id__c = UserInfo.getUserId();
               rcga2.Module__c = 'Existing EMI';
               rcga2.Count__c = 50;
               insert rcga2;
            
               Test.startTest();
                    Ind_ExistingEMICtrl.updateRetryCount(applicant.Id,opp.Id);
               Test.stopTest();
            
                 
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void updateRetryCountTest12(){
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
            
               Retry_Count__c rcga2 = new Retry_Count__c();
               rcga2.Loan_Application_Id__c = opp.Id;
               rcga2.Applicant__c = applicant.Id;
               rcga2.Service_Name__c = 'RUNEMIEngine';
               rcga2.User_Id__c = UserInfo.getUserId();
               rcga2.Module__c = 'Existing EMI';
               rcga2.Count__c = 0;
               insert rcga2;
            
               Test.startTest();
                    Ind_ExistingEMICtrl.updateRetryCount(applicant.Id,opp.Id);
               Test.stopTest();
            
                 
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
     @isTest
    public static void updateRetryCountTest1(){
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
            
               Retry_Count__c rcga2 = new Retry_Count__c();
               rcga2.Loan_Application_Id__c = opp.Id;
               rcga2.Service_Name__c = 'FinalTermApi';
               rcga2.User_Id__c = UserInfo.getUserId();
               insert rcga2;
            
               Test.startTest();
                    Ind_ExistingEMICtrl.updateRetryCount(applicant.Id,opp.Id);
                    Ind_ExistingEMICtrl.updateRetryCount('test','test');
               Test.stopTest();
            
                 
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
       
    }
    
    @isTest
    public static void retryCountUpdateTest(){
        try{
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            
            Applicant__c app1 = TestDataUtility.createTestApplicantForSMS(false);
            app1.Opportunity__c = opp.Id;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert app1;
            }
            
               Retry_Count__c rcga3 = new Retry_Count__c();
               rcga3.Loan_Application_Id__c = opp.Id;
               rcga3.Service_Name__c = 'FinalTermApi';
               rcga3.User_Id__c = UserInfo.getUserId();
               insert rcga3;
                
                Test.startTest();
                     Ind_ExistingEMICtrl.retryCountUpdate(2,app1.Id);
                Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
     @isTest
    public static void retryCountUpdateTest1(){
        try{
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            
            Applicant__c app1 = TestDataUtility.createTestApplicantForSMS(false);
            app1.Opportunity__c = opp.Id;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert app1;
            }
            
               Retry_Count__c rcga3 = new Retry_Count__c();
               rcga3.Loan_Application_Id__c = opp.Id;
               rcga3.Service_Name__c = 'RUNEMIEngine';
               rcga3.User_Id__c = UserInfo.getUserId();
               insert rcga3;
                
                Test.startTest();
                     Ind_ExistingEMICtrl.retryCountUpdate(2,app1.Id);
                     Ind_ExistingEMICtrl.retryCountUpdate(2,'test');
                Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
     @isTest
    public static void retryCountUpdateTest2(){
        try{
            Opportunity opp1 = TestDataUtility.createTestOpportunity(false);
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp1;
            }
            Test.startTest();
                 Ind_ExistingEMICtrl.retryCountUpdate(2,opp1.Id);
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void getEMIExecutedValueTest(){
        try{
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            
            Applicant__c app1 = TestDataUtility.createTestApplicantForSMS(false);
            app1.Opportunity__c = opp.Id;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert app1;
            }
            
            Test.startTest();
                //  Ind_ExistingEMICtrl.getEMIExecutedValue(app1.Id);
                //  Ind_ExistingEMICtrl.getEMIExecutedValue(null);
            Test.stopTest();
            
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void checkForCoborrowerTest(){
        try{
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            
            Applicant__c app1 = TestDataUtility.createTestApplicantForSMS(false);
            app1.Opportunity__c = opp.Id;
            app1.Applicant_Type__c = 'Borrower';
            app1.Income_Detail_Captured__c = true;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert app1;
            }
            
            Test.startTest();
                //  Ind_ExistingEMICtrl.checkForCoborrower(opp.Id);
            Test.stopTest();
            
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
     @isTest
    public static void checkForCoborrowerTest1(){
        try{
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            
            Applicant__c app1 = TestDataUtility.createTestApplicantForSMS(false);
            app1.Opportunity__c = opp.Id;
            app1.Applicant_Type__c = 'Borrower';
            app1.Income_Detail_Captured__c = false;
            app1.Income_source_available__c = true;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert app1;
            }
            
            Test.startTest();
                //  Ind_ExistingEMICtrl.checkForCoborrower(opp.Id);
                //  Ind_ExistingEMICtrl.checkForCoborrower('test');
            Test.stopTest();
            
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
     @isTest
    public static void checkForCoborrowerTest2(){
        try{
            Opportunity opp1 = TestDataUtility.createTestOpportunity(false);
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp1;
            }
            
            Test.startTest();
                //  Ind_ExistingEMICtrl.checkForCoborrower(null);
            Test.stopTest();
            
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void getApplicantTypeTest(){
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
               //   Ind_ExistingEMICtrl.getApplicantType(opp.Id);
            Test.stopTest();
            
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
     @isTest
    public static void getApplicantTypeTest1(){
        try{
             Opportunity opp = TestDataUtility.createTestOpportunity(false);
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            
            Applicant__c app1 = TestDataUtility.createTestApplicantForSMS(false);
            app1.Opportunity__c = opp.Id;
            app1.Applicant_Type__c = 'Borrower';
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert app1;
            }
            
            Test.startTest();
                 // Ind_ExistingEMICtrl.getApplicantType(opp.Id);
            Test.stopTest();
            
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void saveEMIDetails1Test(){
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
            
            Existing_EMI__c em2 = new Existing_EMI__c();
            em2.Applicant_Id__c = app1.Id;
            em2.EMI__c = 10000.00;
            em2.Loan_Type__c = 'personal';
            em2.Lower_EMI_Limit__c = 20000.00;
            em2.Outstanding_Amount__c = 30000.00;
            em2.Upper_EMI_Limit__c = 400000.00;
            insert em2;
            
            Ind_ExistingEMICtrl.ExistingEMIWrapper ew1 = new Ind_ExistingEMICtrl.ExistingEMIWrapper();
             ew1.Id = em2.Id;
            ew1.Loan_Type = 'personal';
            ew1.Outstanding_Amount = '10000';
            ew1.upper_LimitEMI = '100000';
            ew1.lower_LimitEMI = '500000';
            ew1.emi = '300000';
            ew1.Sequential_Number = 'test123';
            
            Existing_EMI__c em1 = new Existing_EMI__c();
            em1.Applicant_Id__c = app1.Id;
            em1.EMI__c = Integer.valueOf(ew1.emi);
            em1.Loan_Type__c = ew1.Loan_Type;
            em1.Lower_EMI_Limit__c = Integer.valueOf(ew1.lower_LimitEMI);
            em1.Outstanding_Amount__c = Integer.valueOf(ew1.Outstanding_Amount);
            em1.Upper_EMI_Limit__c = Integer.valueOf(ew1.upper_LimitEMI);
            insert em1;
            
            Test.startTest();
                Ind_ExistingEMICtrl.saveEMIDetails1(Json.serialize(ew1),app1.Id);
            Test.stopTest();
            
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void updateJourneyStatusTest(){
        try{
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            opp.Journey_Status__c = 'Non STP';
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
                //  Ind_ExistingEMICtrl.updateJourneyStatus(app1.Id);
            Test.stopTest();
            
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void checkRetryCountTest(){
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
        
               Retry_Count__c rcga4 = new Retry_Count__c();
               rcga4.Loan_Application_Id__c = opp.Id;
               rcga4.Service_Name__c = 'RUNEMIEngine';
               rcga4.User_Id__c = UserInfo.getUserId();
               insert rcga4;
        
            Test.startTest();
               //  Ind_ExistingEMICtrl.checkRetryCount(app1.Id,opp.Id);
            Test.stopTest();
    }
    
    @isTest
    public static void loadExistingEMIDataTest(){
        try{
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            opp.Product_Type__c = 'Passenger Vehicles';
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            
            Applicant__c app1 = TestDataUtility.createTestApplicantForSMS(false);
            app1.Opportunity__c = opp.Id;
            app1.Applicant_Type__c = 'Co-borrower';
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert app1;
            }
            
            Existing_EMI__c esm1 = new Existing_EMI__c();
            esm1.Applicant_Id__c = app1.Id;
            insert esm1;
            
            Documents__c dt2 = new Documents__c();
                 dt2.Applicant__c = app1.Id;
                 dt2.Opportunity_Relation__c = opp.Id;
                 dt2.Document_Type__c = 'Customer Bank Statement';
                 dt2.Document_Side__c ='Back';
                 dt2.Aadhar_Source__c = 'ScanAadhar'; 
                 insert dt2;
            
            Test.startTest();
                  Ind_ExistingEMICtrl.loadExistingEMIData(opp.Id,app1.Id);
            Test.stopTest();
            
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
     @isTest
    public static void loadExistingEMIDataTest1(){
        try{
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            opp.Product_Type__c = 'Passenger Vehicles';
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            
            Applicant__c app1 = TestDataUtility.createTestApplicantForSMS(false);
            app1.Opportunity__c = opp.Id;
            app1.Applicant_Type__c = 'Co-borrower';
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert app1;
            }
            
            Existing_EMI__c esm1 = new Existing_EMI__c();
            esm1.Applicant_Id__c = app1.Id;
            insert esm1;
            
            Documents__c dt2 = new Documents__c();
                 dt2.Applicant__c = app1.Id;
                 dt2.Opportunity_Relation__c = opp.Id;
                 dt2.Document_Type__c = 'Customer Bank Statement';
                 dt2.Document_Side__c ='Back';
                 dt2.Aadhar_Source__c = 'ScanAadhar'; 
                 insert dt2;
            
               Retry_Count__c rc2 = new Retry_Count__c();
               rc2.Loan_Application_Id__c = opp.Id;
               rc2.Applicant__c = app1.Id;
               rc2.Service_Name__c = 'RUNEMIEngine';
               rc2.User_Id__c = UserInfo.getUserId();
               rc2.Count__c = 7;
               insert rc2;
            
            Test.startTest();
                  Ind_ExistingEMICtrl.loadExistingEMIData(opp.Id,app1.Id);
                  Ind_ExistingEMICtrl.loadExistingEMIData('test','test');
            Test.stopTest();
            
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void getBankStatementDOcumentTest(){
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
            
                 Documents__c dt2 = new Documents__c();
                 dt2.Applicant__c = app1.Id;
                 dt2.Opportunity_Relation__c = opp.Id;
                 dt2.Document_Type__c = 'Aadhaar';
                 dt2.Document_Side__c ='Back';
                 dt2.Aadhar_Source__c = 'ScanAadhar'; 
                 insert dt2;
            
                 Test.startTest();
                     //  Ind_ExistingEMICtrl.getBankStatementDOcument(dt2.Document_Type__c,app1.Id);
                 Test.stopTest();
            
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void updateEMIExecutedTest(){
        try{
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            
            Applicant__c app1 = TestDataUtility.createTestApplicantForSMS(false);
            app1.Opportunity__c = opp.Id;
            app1.Applicant_Type__c = 'Co-borrower';
            app1.Run_Emi_Executed__c = 'No';
            app1.ScoreCard_Description__c = 'test';
            app1.Scorecard_Decision__c = 'sample';
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert app1;
            }
            
            Test.startTest();
               //  Ind_ExistingEMICtrl.updateEMIExecuted(app1.Id,app1.Run_Emi_Executed__c,true,app1.ScoreCard_Description__c,app1.Scorecard_Decision__c);
               //  Ind_ExistingEMICtrl.updateEMIExecuted(app1.Id,app1.Run_Emi_Executed__c,false,app1.ScoreCard_Description__c,app1.Scorecard_Decision__c);
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void getExistingEMISubmittedValueTest(){
        try{
             Opportunity opp = TestDataUtility.createTestOpportunity(false);
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            
            Applicant__c app1 = TestDataUtility.createTestApplicantForSMS(false);
            app1.Opportunity__c = opp.Id;
            app1.Applicant_Type__c = 'Co-borrower';
            app1.Income_source_available__c = true;
            app1.In_Active_Applicant__c = false;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert app1;
            }
            
            Test.startTest();
                Ind_ExistingEMICtrl.getExistingEMISubmittedValue(opp.Id);
                Ind_ExistingEMICtrl.getExistingEMISubmittedValue('test');
            Test.stopTest();
            
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
     @isTest
    public static void getExistingEMISubmittedValueTest1(){
        try{
             Opportunity opp1 = TestDataUtility.createTestOpportunity(false);
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp1;
            }
            
             Applicant__c app1 = TestDataUtility.createTestApplicantForSMS(false);
            app1.Opportunity__c = opp1.Id;
            app1.Applicant_Type__c = 'Co-borrower';
            app1.Income_source_available__c = false;
            app1.In_Active_Applicant__c = true;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert app1;
            }
            
           Test.startTest();
                Ind_ExistingEMICtrl.getExistingEMISubmittedValue(opp1.Id);
            Test.stopTest();
            
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void getBankStatementDocumentTest1(){
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
            
                 Documents__c dt2 = new Documents__c();
                 dt2.Applicant__c = app1.Id;
                 dt2.Opportunity_Relation__c = opp.Id;
                 dt2.Document_Type__c = 'Aadhaar';
                 dt2.Document_Side__c ='Back';
                 dt2.Aadhar_Source__c = 'ScanAadhar'; 
                 insert dt2;
            
                 Test.startTest();
                      Ind_ExistingEMICtrl.getBankStatementDocument(dt2.Document_Type__c,app1.Id);
                 Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
     @isTest
    public static void getBankStatementDocumentTest2(){
        try{
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            
            Applicant__c app2 = TestDataUtility.createTestApplicantForSMS(false);
            app2.Opportunity__c = opp.Id;
            app2.Applicant_Type__c = 'Co-borrower';
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert app2;
            }
            
                 Test.startTest();
                      Ind_ExistingEMICtrl.getBankStatementDocument('aadhar',app2.Id);
                 Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void validateBankStatementUploadForCoBorrowerTest(){
        try{
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            
            Applicant__c app1 = TestDataUtility.createTestApplicantForSMS(false);
            app1.Opportunity__c = opp.Id;
            app1.Applicant_Type__c = 'Co-borrower';
            app1.Income_source_available__c = false;
            app1.In_Active_Applicant__c = false;
            app1.Do_you_have_a_bank_account__c = true;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert app1;
            }
            
             Documents__c dt2 = new Documents__c();
             dt2.Applicant__c = app1.Id;
             dt2.Opportunity_Relation__c = opp.Id;
             dt2.Document_Type__c = 'Customer Bank Statement';
             dt2.Document_Side__c ='Back';
             dt2.Aadhar_Source__c = 'ScanAadhar'; 
             insert dt2;
            
            Blob beforeblob=Blob.valueOf('Unit Test Attachment Body');

                 ContentVersion cv = new ContentVersion();
                 cv.title = 'test content trigger';      
                 cv.PathOnClient ='test';           
                 cv.VersionData =beforeblob;          
                 insert cv;   
        
                 ContentVersion testContent = [SELECT id, ContentDocumentId FROM ContentVersion where Id = :cv.Id];

        
                 ContentDocumentLink contentlink = new ContentDocumentLink();
                 contentlink.ShareType = 'V';
                 contentlink.LinkedEntityId = dt2.Id; 
                 contentlink.ContentDocumentId = testcontent.ContentDocumentId;
                 contentlink.Visibility = 'AllUsers'; 
                 insert contentlink;
            
             Test.startTest();
                   Ind_ExistingEMICtrl.validateBankStatementUploadForCoBorrower(opp.Id);
                   Ind_ExistingEMICtrl.validateBankStatementUploadForCoBorrower('test');
                   Ind_ExistingEMICtrl.validateBankStatementUploadForCoBorrower(null);
             Test.stopTest();
            
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void validateExistingEMISubmitActionTest(){
        try{
                Opportunity opga1 = new Opportunity();
                opga1.StageName = 'Qualification';
                opga1.CloseDate = Date.newInstance(2021, 1, 11);
                opga1.Name = 'testone';
                opga1.Product_Type__c = 'Passenger Vehicles';
                insert opga1;
                
                Applicant__c apga1 = new Applicant__c();
                apga1.Opportunity__c = opga1.Id;
                apga1.Contact_number__c = '9743514830';
                apga1.Applicant_Type__c = 'Borrower';
                insert apga1;
            
            Test.startTest();
                 Ind_ExistingEMICtrl.validateExistingEMISubmitAction(apga1.Id);
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void validateExistingEMISubmitActionTest1(){
        try{
                Opportunity opga2 = new Opportunity();
                opga2.StageName = 'Qualification';
                opga2.CloseDate = Date.newInstance(2021, 1, 11);
                opga2.Name = 'testone';
                opga2.Product_Type__c = 'Passenger Vehicles';
                insert opga2;
                
                
            Test.startTest();
                 Ind_ExistingEMICtrl.validateExistingEMISubmitAction(opga2.Id);
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void validateExistingEMISubmitActionTest2(){
        try{
                Opportunity opga2 = new Opportunity();
                opga2.StageName = 'Qualification';
                opga2.CloseDate = Date.newInstance(2021, 1, 11);
                opga2.Name = 'testone';
                opga2.Product_Type__c = 'Passenger Vehicles';
                insert opga2;
            
                Applicant__c apga1 = new Applicant__c();
                apga1.Opportunity__c = opga2.Id;
                apga1.Contact_number__c = '9743514830';
                apga1.Applicant_Type__c = 'Borrower';
              //  apga1.Is_RUN_EMI_Assessed__c = false;
                insert apga1;
            
               Retry_Count__c rct1 = new Retry_Count__c();
               rct1.Loan_Application_Id__c = opga2.Id;
               rct1.Applicant__c = apga1.Id;
               rct1.Service_Name__c = 'RUNEMIEngine';
               rct1.User_Id__c = UserInfo.getUserId();
               rct1.Count__c = 1;
               insert rct1;
            
               Retry_Count__c rct2 = new Retry_Count__c();
               rct2.Loan_Application_Id__c = opga2.Id;
               rct2.Applicant__c = apga1.Id;
               rct2.Service_Name__c = 'RUNEMIEngine';
               rct2.User_Id__c = UserInfo.getUserId();
               rct2.Count__c = 2;
               insert rct2;
            
            /*   Existing_EMI__c em2 = new Existing_EMI__c();
            em2.Applicant_Id__c = apga1.Id;
            em2.EMI__c = null;
            em2.Loan_Type__c = 'personal';
            em2.Lower_EMI_Limit__c = 20000.00;
            em2.Outstanding_Amount__c = 30000.00;
            em2.Upper_EMI_Limit__c = 400000.00;
            insert em2; */
                
            Test.startTest();
                 Ind_ExistingEMICtrl.validateExistingEMISubmitAction(opga2.Id);
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
     @isTest
    public static void validateExistingEMISubmitActionTest3(){
        try{
                Opportunity opga1 = new Opportunity();
                opga1.StageName = 'Qualification';
                opga1.CloseDate = Date.newInstance(2021, 1, 11);
                opga1.Name = 'testone';
                opga1.Product_Type__c = 'Passenger Vehicles';
                insert opga1;
                
                Applicant__c apga1 = new Applicant__c();
                apga1.Opportunity__c = opga1.Id;
                apga1.Contact_number__c = '9743514830';
                apga1.Applicant_Type__c = 'Borrower';
                apga1.Is_RUN_EMI_Assessed__c = true;
                apga1.Do_you_have_a_bank_account__c = true;
                insert apga1;
            
                Existing_EMI__c em2 = new Existing_EMI__c();
                em2.Applicant_Id__c = apga1.Id;
                em2.EMI__c = null;
                em2.Loan_Type__c = 'personal';
                em2.Lower_EMI_Limit__c = 20000.00;
                em2.Outstanding_Amount__c = 30000.00;
                em2.Upper_EMI_Limit__c = 400000.00;
                insert em2;
            
            Test.startTest();
                 Ind_ExistingEMICtrl.validateExistingEMISubmitAction(apga1.Id);
                 Ind_ExistingEMICtrl.validateExistingEMISubmitAction('test');
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }

    @isTest 
    public static void validateExistingEMISubmitActionTWTest1(){
        try{
                Opportunity opga1 = new Opportunity();
                opga1.StageName = 'Qualification';
                opga1.CloseDate = Date.newInstance(2021, 1, 11);
                opga1.Name = 'testone';
                opga1.Product_Type__c = 'Two Wheeler';
                insert opga1;
                
                Applicant__c apga1 = new Applicant__c();
                apga1.Opportunity__c = opga1.Id;
                apga1.Contact_number__c = '9743514830';
                apga1.Applicant_Type__c = 'Borrower';
                apga1.Is_RUN_EMI_Assessed__c = false;
                apga1.Do_you_have_a_bank_account__c = true;
                insert apga1;
            
            Retry_Count__c rc = new Retry_Count__c();
            rc.Count__c = 1;
            rc.Service_Name__c='RUNEMIEngine';
            rc.Applicant__c=apga1.Id;
            rc.Loan_Application_Id__c = opga1.Id;
            insert rc;
            
                Existing_EMI__c em2 = new Existing_EMI__c();
                em2.Applicant_Id__c = apga1.Id;
                em2.EMI__c = null;
                em2.Loan_Type__c = 'personal';
                em2.Lower_EMI_Limit__c = 20000.00;
                em2.Outstanding_Amount__c = 30000.00;
                em2.Upper_EMI_Limit__c = 400000.00;
                insert em2;
            
            Test.startTest();
                 Ind_ExistingEMICtrl.validateExistingEMISubmitActionTw(apga1.Id);
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
     @isTest 
    public static void validateExistingEMISubmitActionTWTest3(){
        try{
                Opportunity opga1 = new Opportunity();
                opga1.StageName = 'Qualification';
                opga1.CloseDate = Date.newInstance(2021, 1, 11);
                opga1.Name = 'testone';
                opga1.Product_Type__c = 'Two Wheeler';
                insert opga1;
                
                Applicant__c apga1 = new Applicant__c();
                apga1.Opportunity__c = opga1.Id;
                apga1.Contact_number__c = '9743514830';
                apga1.Applicant_Type__c = 'Borrower';
                apga1.Is_RUN_EMI_Assessed__c = true;
                apga1.Do_you_have_a_bank_account__c = true;
                insert apga1;
            
            Applicant__c apga2 = new Applicant__c();
                apga2.Opportunity__c = opga1.Id;
                apga2.Contact_number__c = '9743514830';
                apga2.Applicant_Type__c = 'Borrower';
                apga2.Is_RUN_EMI_Assessed__c = true;
                apga2.Do_you_have_a_bank_account__c = true;
            apga2.In_Active_Applicant__c=true;
                insert apga2;
            
            Retry_Count__c rc = new Retry_Count__c();
            rc.Count__c = 1;
            rc.Service_Name__c='RUNEMIEngine';
            rc.Applicant__c=apga1.Id;
            rc.Loan_Application_Id__c = opga1.Id;
            insert rc;
            
                Existing_EMI__c em2 = new Existing_EMI__c();
                em2.Applicant_Id__c = apga1.Id;
                em2.EMI__c = null;
                em2.Loan_Type__c = 'personal';
                em2.Lower_EMI_Limit__c = 20000.00;
                em2.Outstanding_Amount__c = 30000.00;
                em2.Upper_EMI_Limit__c = 400000.00;
                insert em2;
            
            Test.startTest();
                   Ind_ExistingEMICtrl.validateExistingEMISubmitActionTw(apga1.Id);
            Ind_ExistingEMICtrl.validateExistingEMISubmitActionTw(apga2.Id);
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest 
    public static void validateExistingEMISubmitActionTWTest2(){
        try{
                Opportunity opga1 = new Opportunity();
                opga1.StageName = 'Qualification';
                opga1.CloseDate = Date.newInstance(2021, 1, 11);
                opga1.Name = 'testone';
                opga1.Product_Type__c = 'Two Wheeler';
                insert opga1;
                
                Applicant__c apga1 = new Applicant__c();
                apga1.Opportunity__c = opga1.Id;
                apga1.Contact_number__c = '9743514830';
                apga1.Applicant_Type__c = 'Borrower';
                apga1.Is_RUN_EMI_Assessed__c = false;
                apga1.Do_you_have_a_bank_account__c = true;
                insert apga1;
            
                Existing_EMI__c em2 = new Existing_EMI__c();
                em2.Applicant_Id__c = apga1.Id;
                em2.EMI__c = null;
                em2.Loan_Type__c = 'personal';
                em2.Lower_EMI_Limit__c = 20000.00;
                em2.Outstanding_Amount__c = 30000.00;
                em2.Upper_EMI_Limit__c = 400000.00;
                insert em2;
            
            Test.startTest();
                 Ind_ExistingEMICtrl.validateExistingEMISubmitActionTw(apga1.Id);
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
     @isTest 
    public static void validateFoirTest1(){
        try{
                Opportunity opga1 = new Opportunity();
                opga1.StageName = 'Qualification';
                opga1.CloseDate = Date.newInstance(2021, 1, 11);
                opga1.Name = 'testone';
                opga1.Product_Type__c = 'Two Wheeler';
                insert opga1;
            
                Applicant__c apga1 = new Applicant__c();
                apga1.Opportunity__c = opga1.Id;
                apga1.Contact_number__c = '9743514830';
                apga1.Applicant_Type__c = 'Borrower';
                apga1.FOIR_Check__c = false;
                apga1.Do_you_have_a_bank_account__c = true;
                insert apga1;
            
            Applicant__c apga2 = new Applicant__c();
                apga2.Opportunity__c = opga1.Id;
                apga2.Contact_number__c = '9743514830';
                apga2.Applicant_Type__c = 'Co-borrower';
                apga2.FOIR_Check__c = false;
                apga2.Do_you_have_a_bank_account__c = true;
            apga2.In_Active_Applicant__c=false;
                insert apga2;
            
 
            Test.startTest();
                   Ind_ExistingEMICtrl.validateFoir(opga1.Id);
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest 
    public static void validateFoirTest2(){
        try{
                Opportunity opga1 = new Opportunity();
                opga1.StageName = 'Qualification';
                opga1.CloseDate = Date.newInstance(2021, 1, 11);
                opga1.Name = 'testone';
                opga1.Product_Type__c = 'Two Wheeler';
                insert opga1;
            
           
            
            Applicant__c apga3 = new Applicant__c();
                apga3.Opportunity__c = opga1.Id;
                apga3.Contact_number__c = '9743514830';
                apga3.Applicant_Type__c = 'Borrower';
                apga3.Is_RUN_EMI_Assessed__c = true;
                apga3.Do_you_have_a_bank_account__c = true;
            apga3.In_Active_Applicant__c=true;
                insert apga3;
 
            Test.startTest();
                   Ind_ExistingEMICtrl.validateFoir(opga1.Id);
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest 
    public static void calculateFoirTest1(){
        try{
                Opportunity opga1 = new Opportunity();
                opga1.StageName = 'Qualification';
                opga1.CloseDate = Date.newInstance(2021, 1, 11);
                opga1.Name = 'testone';
                opga1.Product_Type__c = 'Two Wheeler';
                insert opga1;
            
                Applicant__c apga1 = new Applicant__c();
                apga1.Opportunity__c = opga1.Id;
                apga1.Contact_number__c = '9743514830';
                apga1.Applicant_Type__c = 'Borrower';
                apga1.FOIR_Check__c = false;
                apga1.Do_you_have_a_bank_account__c = true;
                insert apga1;
            
	Existing_EMI__c em2 = new Existing_EMI__c();
                em2.Applicant_Id__c = apga1.Id;
                em2.EMI__c = 1;
                em2.Loan_Type__c = 'personal';
                em2.Lower_EMI_Limit__c = 20000.00;
                em2.Outstanding_Amount__c = 30000.00;
                em2.Upper_EMI_Limit__c = 400000.00;
                insert em2;
            
            Income_Details__c idd = new Income_Details__c();
            idd.Applicant__c = apga1.Id;
            idd.Income__c = 1;
            insert idd;
 
            Test.startTest();
                   Ind_ExistingEMICtrl.calculateFoir(apga1.Id, 0, 0,0);
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest 
    public static void calculateFoirTest2(){
        try{
                Opportunity opga1 = new Opportunity();
                opga1.StageName = 'Qualification';
                opga1.CloseDate = Date.newInstance(2021, 1, 11);
                opga1.Name = 'testone';
                opga1.Product_Type__c = 'Two Wheeler';
                insert opga1;
            
                Applicant__c apga1 = new Applicant__c();
                apga1.Opportunity__c = opga1.Id;
                apga1.Contact_number__c = '9743514830';
                apga1.Applicant_Type__c = 'Borrower';
                apga1.FOIR_Check__c = false;
                apga1.Do_you_have_a_bank_account__c = true;
                insert apga1;
            
	Existing_EMI__c em2 = new Existing_EMI__c();
                em2.Applicant_Id__c = apga1.Id;
                em2.EMI__c = 1;
                em2.Loan_Type__c = 'personal';
                em2.Lower_EMI_Limit__c = 20000.00;
                em2.Outstanding_Amount__c = 30000.00;
                em2.Upper_EMI_Limit__c = 400000.00;
                insert em2;
            
           
 
            Test.startTest();
                   Ind_ExistingEMICtrl.calculateFoir(apga1.Id, 0, 0,0);
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
     @isTest 
    public static void calculateFoirInFinalTermsTest1(){
        try{
                Opportunity opga1 = new Opportunity();
                opga1.StageName = 'Qualification';
                opga1.CloseDate = Date.newInstance(2021, 1, 11);
                opga1.Name = 'testone';
                opga1.Product_Type__c = 'Two Wheeler';
                insert opga1;
            
            Final_Term__c ft = new Final_Term__c();
            ft.Loan_Application__c = opga1.Id;
            insert ft;
            
                Applicant__c apga1 = new Applicant__c();
                apga1.Opportunity__c = opga1.Id;
                apga1.Contact_number__c = '9743514830';
                apga1.Applicant_Type__c = 'Borrower';
                apga1.FOIR_Check__c = false;
                apga1.Do_you_have_a_bank_account__c = true;
                insert apga1;
            
            Applicant__c apga2 = new Applicant__c();
                apga2.Opportunity__c = opga1.Id;
                apga2.Contact_number__c = '9743514830';
                apga2.Applicant_Type__c = 'Co-borrower';
                apga2.FOIR_Check__c = false;
                apga2.Do_you_have_a_bank_account__c = true;
                insert apga2;
            
	Existing_EMI__c em2 = new Existing_EMI__c();
                em2.Applicant_Id__c = apga1.Id;
                em2.EMI__c = 1;
                em2.Loan_Type__c = 'personal';
                em2.Lower_EMI_Limit__c = 20000.00;
                em2.Outstanding_Amount__c = 30000.00;
                em2.Upper_EMI_Limit__c = 400000.00;
                insert em2;
            
            Existing_EMI__c em = new Existing_EMI__c();
                em.Applicant_Id__c = apga2.Id;
                em.EMI__c = 1;
                em.Loan_Type__c = 'personal';
                em.Lower_EMI_Limit__c = 20000.00;
                em.Outstanding_Amount__c = 30000.00;
                em.Upper_EMI_Limit__c = 400000.00;
                insert em;
            
            Income_Details__c idd = new Income_Details__c();
            idd.Applicant__c = apga1.Id;
            idd.Income__c = 100;
            insert idd;
            
            Income_Details__c idd2 = new Income_Details__c();
            idd2.Applicant__c = apga2.Id;
            idd2.Income__c = 100;
            insert idd2;
            
            Test.startTest();
                   Ind_ExistingEMICtrl.calculateFoirInFinalTerms(opga1.Id);
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
 }