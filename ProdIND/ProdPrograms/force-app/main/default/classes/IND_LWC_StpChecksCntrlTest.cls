@isTest
public class IND_LWC_StpChecksCntrlTest {
    @isTest
    public static void stpChecksTest1(){
        try{
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            
            Applicant__c app1 = TestDataUtility.createTestApplicantForSMS(false);
            app1.Applicant_Type__c = 'Borrower';
            app1.Opportunity__c = opp.Id;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert app1;
            }
            
            Customer_Code__c cc1 = new Customer_Code__c();
            cc1.Loan_Application__c = opp.Id;
            cc1.Applicant__c = app1.Id;
            cc1.CustomerCodeExtId__c = 'CU3761425';
            cc1.Name = 'test';
            cc1.Flag__c = 'R';
            insert cc1;
            
            Exposure__c ex1 = new Exposure__c();
            ex1.Loan_Application__c = opp.Id;
            ex1.Type__c = 'Borrower Exposure';
            ex1.Status_Flag__c = 'L';
            insert ex1;
            
            Test.startTest();
            IND_LWC_StpChecksCntrl.stpChecks(opp.Id);
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void stpChecksTest2(){
        try{
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            opp.Loan_amount__c = '2000000';
            opp.Product_Type__c = 'Passenger Vehicles';
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            
            Applicant__c app1 = TestDataUtility.createTestApplicantForSMS(false);
            app1.Applicant_Type__c = 'Borrower';
            app1.Opportunity__c = opp.Id;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert app1;
            }
            
            Customer_Code__c cc1 = new Customer_Code__c();
            cc1.Loan_Application__c = opp.Id;
            cc1.Applicant__c = app1.Id;
            cc1.CustomerCodeExtId__c = 'CU3761425';
            cc1.Name = 'test';
            cc1.Flag__c = 'R';
            insert cc1;
            
            Exposure__c ex1 = new Exposure__c();
            ex1.Loan_Application__c = opp.Id;
            ex1.Type__c = 'Borrower Exposure';
            //  ex1.Status_Flag__c = null;
            ex1.SOH__c = 1000000;
            insert ex1;
            
            Test.startTest();
            IND_LWC_StpChecksCntrl.stpChecks(opp.Id);
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void stpChecksTest3(){
        try{
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            
            Applicant__c app1 = TestDataUtility.createTestApplicantForSMS(false);
            app1.Applicant_Type__c = 'Borrower';
            app1.Opportunity__c = opp.Id;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert app1;
            }
            
            Documents__c dt2 = new Documents__c();
            dt2.Applicant__c = app1.Id;
            dt2.Opportunity_Relation__c = opp.Id;
            dt2.Document_Type__c = System.Label.AadhaarCard;
            dt2.Document_Side__c ='Back';
            dt2.Aadhar_Source__c = 'ScanAadhar'; 
            dt2.RecordTypeId = Schema.SObjectType.Documents__c.getRecordTypeInfosByName().get('KYC Document').getRecordTypeId();
            dt2.Permanent_Residential_Address_Proof__c = true;
            insert dt2;
            
            Test.startTest();
            IND_LWC_StpChecksCntrl.stpChecks(opp.Id);
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void stpChecksTest4(){
        try{
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            
            Applicant__c app1 = TestDataUtility.createTestApplicantForSMS(false);
            app1.Applicant_Type__c = 'Borrower';
            app1.Opportunity__c = opp.Id;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert app1;
            }
            
            Documents__c dt2 = new Documents__c();
            dt2.Applicant__c = app1.Id;
            dt2.Opportunity_Relation__c = opp.Id;
            dt2.Document_Type__c = System.Label.AadhaarCard;
            dt2.Document_Side__c ='Back';
            dt2.Aadhar_Source__c = 'ScanAadhar'; 
            dt2.RecordTypeId = Schema.SObjectType.Documents__c.getRecordTypeInfosByName().get('KYC Document').getRecordTypeId();
            dt2.Permanent_Residential_Address_Proof__c = false;
            insert dt2;
            
            Test.startTest();
            IND_LWC_StpChecksCntrl.stpChecks(opp.Id);
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void stpChecksTest5(){
        try{
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            opp.Vehicle_Type__c = 'used';
            opp.On_Road_price__c = 250000;
            opp.On_Road_price_carwale__c = 225000;
            opp.Ex_showroom_price__c = 200000;
            opp.Ex_showroom_price_carwale__c = 100000;
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            
            Applicant__c app1 = TestDataUtility.createTestApplicantForSMS(false);
            app1.Applicant_Type__c = 'Borrower';
            app1.Opportunity__c = opp.Id;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert app1;
            }
            
            Vehicle_Detail__c vgd2 = new Vehicle_Detail__c();
            vgd2.Loan_Application__c = opp.Id;
            vgd2.Base_Price__c = 100000.00;
            vgd2.Ben_Code__c = 'testveh';
            vgd2.Vehicle_type__c = 'New';
            vgd2.Ins_Expiry_date__c = Date.newInstance(2022, 11, 26);
            vgd2.Insurance_expiring_within_60_days__c = true;
            vgd2.Insurance_type__c = 'Third Party';
            insert vgd2;
            
            Test.startTest();
            IND_LWC_StpChecksCntrl.stpChecks(opp.Id);
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void stpChecksTest6(){
        try{
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            
            Applicant__c app1 = TestDataUtility.createTestApplicantForSMS(false);
            app1.Applicant_Type__c = 'Borrower';
            app1.Opportunity__c = opp.Id;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert app1;
            }
            
            Final_Term__c ftd2 = new Final_Term__c();
            ftd2.CRM_IRR__c = 120;
            ftd2.Loan_Application__c = opp.Id;
            ftd2.Holiday_period__c='30';
            ftd2.EMI_Amount__c= 10000;
            ftd2.LtvEngine_Ltv__c = null;
            insert ftd2;
            
            Test.startTest();
            IND_LWC_StpChecksCntrl.stpChecks(opp.Id);
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void stpChecksTest7(){
        try{
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            opp.Total_Funded_premium_amount__c = 100000.00;
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            
            Applicant__c app1 = TestDataUtility.createTestApplicantForSMS(false);
            app1.Applicant_Type__c = 'Borrower';
            app1.Opportunity__c = opp.Id;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert app1;
            }
            
            Final_Term__c ftd2 = new Final_Term__c();
            ftd2.CRM_IRR__c = 120;
            ftd2.Loan_Application__c = opp.Id;
            ftd2.Holiday_period__c='30';
            ftd2.EMI_Amount__c= 10000;
            ftd2.LtvEngine_Ltv__c = 1000;
            //   ftd2.IsRequiredCRMIRRChanged__c = true;
            insert ftd2;
            
            Test.startTest();
            IND_LWC_StpChecksCntrl.stpChecks(opp.Id);
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void stpChecksTest8(){
        try{
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            opp.Total_Funded_premium_amount__c = 100000.00;
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            
            Applicant__c app1 = TestDataUtility.createTestApplicantForSMS(false);
            app1.Applicant_Type__c = 'Borrower';
            app1.Opportunity__c = opp.Id;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert app1;
            }
            
            Final_Term__c ftd2 = new Final_Term__c();
            ftd2.CRM_IRR__c = 120;
            ftd2.Loan_Application__c = opp.Id;
            ftd2.Holiday_period__c='30';
            ftd2.EMI_Amount__c= 10000;
            ftd2.OfferengineMinLoanAmount__c = 100000;
            ftd2.Loan_Amount__c = '50000';
            ftd2.OfferengineMaxLoanAmount__c = 30000;
            insert ftd2;
            
            Test.startTest();
            IND_LWC_StpChecksCntrl.stpChecks(opp.Id);
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void stpChecksTest9(){
        try{
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            opp.Total_Funded_premium_amount__c = 100000.00;
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            
            Applicant__c app1 = TestDataUtility.createTestApplicantForSMS(false);
            app1.Applicant_Type__c = 'Borrower';
            app1.Opportunity__c = opp.Id;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert app1;
            }
            
            Final_Term__c ftd2 = new Final_Term__c();
            ftd2.CRM_IRR__c = 120;
            ftd2.Loan_Application__c = opp.Id;
            ftd2.Holiday_period__c='30';
            ftd2.EMI_Amount__c= 10000;
            ftd2.OfferengineMinTenure__c = 70000.00;
            ftd2.Tenure__c = '50000';
            ftd2.OfferengineMaxTenure__c = 40000;
            insert ftd2;
            
            Test.startTest();
            IND_LWC_StpChecksCntrl.stpChecks(opp.Id);
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void stpChecksTest10(){
        try{
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            opp.On_Road_price__c = 10;
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            
            Applicant__c app1 = TestDataUtility.createTestApplicantForSMS(false);
            app1.Applicant_Type__c = 'Borrower';
            app1.Opportunity__c = opp.Id;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert app1;
            }
            
            Final_Term__c ftd2 = new Final_Term__c();
            ftd2.CRM_IRR__c = 120;
            ftd2.Loan_Application__c = opp.Id;
            ftd2.Holiday_period__c='30';
            ftd2.Loan_Amount__c = '1000000';
            ftd2.LtvEngine_Ltv__c = 10000;
            insert ftd2;
            
            Test.startTest();
            IND_LWC_StpChecksCntrl.stpChecks(opp.Id);
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void stpChecksTest11(){
        try{
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            opp.Loan_amount__c = '200000';
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            
            Applicant__c app1 = TestDataUtility.createTestApplicantForSMS(false);
            app1.Applicant_Type__c = 'Borrower';
            app1.Opportunity__c = opp.Id;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert app1;
            }
            
            Final_Term__c ftd3 = new Final_Term__c();
            ftd3.CRM_IRR__c = 120;
            ftd3.Loan_Application__c = opp.Id;
            ftd3.Holiday_period__c='30';
            ftd3.Loan_Amount__c = '1000000';
            ftd3.LtvEngine_Ltv__c = 1000;
            insert ftd3;
            
            Vehicle_Detail__c vgd2 = new Vehicle_Detail__c();
            vgd2.Loan_Application__c = opp.Id;
            vgd2.Base_Price__c = 100;
            vgd2.Ben_Code__c = 'testveh';
            vgd2.Insurance_declared_value__c = 100000;
            insert vgd2; 
            
            Test.startTest();
            IND_LWC_StpChecksCntrl.stpChecks(opp.Id);
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void stpChecksTest12(){
        try{
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            opp.Loan_amount__c = '200000';
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            
            Applicant__c app1 = TestDataUtility.createTestApplicantForSMS(false);
            app1.Applicant_Type__c = 'Borrower';
            app1.Opportunity__c = opp.Id;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert app1;
            }
            
            Income_Details__c inc1 = new Income_Details__c();
            inc1.Applicant__c = app1.id;
            inc1.Primary_Income_Source__c = true;
            inc1.Income_Source_Status__c = 'NIP';
            insert inc1;
            
            Final_Term__c ftd3 = new Final_Term__c();
            ftd3.CRM_IRR__c = 120;
            ftd3.Loan_Application__c = opp.Id;
            ftd3.Holiday_period__c='30';
            ftd3.Loan_Amount__c = '1000000';
            ftd3.LtvEngine_Ltv__c = 1000;
            insert ftd3;
            
            Vehicle_Detail__c vgd2 = new Vehicle_Detail__c();
            vgd2.Loan_Application__c = opp.Id;
            vgd2.Base_Price__c = 100;
            vgd2.Ben_Code__c = 'testveh';
            vgd2.Insurance_declared_value__c = 100;
            vgd2.OEM_Dealer__c = true;
            insert vgd2; 
            
            Retry_Count__c rcga2 = new Retry_Count__c();
            rcga2.Loan_Application_Id__c = opp.Id;
            rcga2.Service_Name__c = 'FinalTermApi';
            rcga2.User_Id__c = UserInfo.getUserId();
            rcga2.IsAPIFailed__c = true;
            insert rcga2;
            
            Test.startTest();
            IND_LWC_StpChecksCntrl.stpChecks(opp.Id);
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void stpChecksTest121(){
        try{
            Opportunity opp3 = TestDataUtility.createTestOpportunity(false);
            opp3.Loan_amount__c = '200000';
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp3;
            }
            
            Applicant__c app1 = TestDataUtility.createTestApplicantForSMS(false);
            app1.Applicant_Type__c = 'Borrower';
            app1.Opportunity__c = opp3.Id;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert app1;
            }
            
            Income_Details__c inc1 = new Income_Details__c();
            inc1.Applicant__c = app1.id;
            inc1.Primary_Income_Source__c = true;
            inc1.Income_Source_Status__c = 'NIP';
            insert inc1;
            
            Final_Term__c ftd3 = new Final_Term__c();
            ftd3.CRM_IRR__c = 120;
            ftd3.Loan_Application__c = opp3.Id;
            ftd3.Holiday_period__c='30';
            ftd3.Loan_Amount__c = '1000000';
            ftd3.LtvEngine_Ltv__c = 1000;
            insert ftd3;
            
            Vehicle_Detail__c vgd2 = new Vehicle_Detail__c();
            vgd2.Loan_Application__c = opp3.Id;
            vgd2.Base_Price__c = 100;
            vgd2.Ben_Code__c = 'testveh';
            vgd2.Insurance_declared_value__c = 100;
            vgd2.OEM_Dealer__c = true;
            insert vgd2; 
            
            Retry_Count__c rcga3 = new Retry_Count__c();
            rcga3.Loan_Application_Id__c = opp3.Id;
            rcga3.Service_Name__c = 'OfferScreenApiCount';
            rcga3.User_Id__c = UserInfo.getUserId();
            rcga3.IsAPIFailed__c = true;
            insert rcga3;
            
            Test.startTest();
            IND_LWC_StpChecksCntrl.stpChecks(opp3.Id);
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void stpChecksTest13(){
        try{
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            opp.Loan_amount__c = '200000';
            opp.Product_Type__c = 'Passenger Vehicles';
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            
            opp.Sanction_Status__c = 'STP';
            update opp;
            
            Applicant__c app1 = TestDataUtility.createTestApplicantForSMS(false);
            app1.Applicant_Type__c = 'Borrower';
            app1.Opportunity__c = opp.Id;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert app1;
            }
            
            Income_Details__c inc1 = new Income_Details__c();
            inc1.Applicant__c = app1.id;
            //   inc1.Primary_Income_Source__c = true;
            inc1.Income_Source_Status__c = 'NIP';
            insert inc1;
            
            Final_Term__c ftd3 = new Final_Term__c();
            ftd3.CRM_IRR__c = 120;
            ftd3.Loan_Application__c = opp.Id;
            ftd3.Holiday_period__c='30';
            ftd3.Loan_Amount__c = '1000000';
            ftd3.LtvEngine_Ltv__c = 1000;
            insert ftd3;
            
            Vehicle_Detail__c vgd2 = new Vehicle_Detail__c();
            vgd2.Loan_Application__c = opp.Id;
            vgd2.Base_Price__c = 100;
            vgd2.Ben_Code__c = 'testveh';
            vgd2.Insurance_declared_value__c = 100;
            vgd2.OEM_Dealer__c = true;
            insert vgd2; 
            
            Retry_Count__c rcga2 = new Retry_Count__c();
            rcga2.Loan_Application_Id__c = opp.Id;
            rcga2.Service_Name__c = 'FinalTermApi';
            rcga2.User_Id__c = UserInfo.getUserId();
            rcga2.IsAPIFailed__c = true;
            insert rcga2;
            
            Customer_Dedupe_Response__c cdr3 = new Customer_Dedupe_Response__c();
            cdr3.Applicant__c = app1.Id;
            cdr3.CIC_No__c = '545667';
            cdr3.CIN_No__c = '34455';
            cdr3.Customer_Code__c = 'test123';
            cdr3.SF_Cust_Dedupe__c = null;
            cdr3.PG_Cust_Dedupe__c = null;
            cdr3.Is_Journey_Skipped__c = false;
            cdr3.External_Dedupe_Status__c = 'P';
            cdr3.Customer_Status_Flag__c = 'F';
            //   cdr2.Response__c = '{"response":{"status":"SUCCESS","respDesc":"IxsightEnquiry","content":[{"Data":{"ExternalDedupeResponse":{"DEDUPE_STATUS":"M","DtCFDCUSTBAS":[{"SOURCE_CIC_NO":"2022268275545880078","MATCH_ECIF":"3095268","MATCHED_CUSTOMER_NAME":"S DEIVARAJ","MATCHED_CUSTOMER_CODE":"CU0503174","MATCHED_SOURCE":"CFD","MATCHED_SCORE":"100","MATCHED_CRITERIA":"VOTERID100","CONFIDENCE_LEVEL":"1"}],"DtRECENTLEAD":[{"SOURCE_CIC_NO":"2022268275545880078","MATCHED_CIC_NO":"991102194599513090","MATCHED_LEAD_NAME":"DEIVARAJ S","MATCHED_LEAD_DATE":"12/15/2021 13:55:28","MATCHED_SCORE":"100","MATCHED_CRITERIA":"PAN100"}],"CustomerValidate":[{"CustomerCodeVal":"CU0503174","CustomerMaster":[{"Customer_Name":"S DEIVARAJ","Customer_Type":"10","Date_of_Birth":"27-06-1986 00:00:00","PAN_GIR_Number":"","Passport_Number":"","Voter_ID_Number":"CKK1913391","Driving_License_Number":"","Aadhaar_No":""}],"CustomerStatus":[{"Cross_Dedupe_Match_Id":"3095268","Active_Flag":"Z"}],"Dealstatus":[{"Deal_No":"TTU05950H","Status_Flag":"Z"}],"NPA":[],"Restructure":[{"Deal_Restructured":"No"}],"Gecl":[{"Deal_No":"TTU05950H","Status_Flag":"Z"}],"ARC":[],"PanAlert":[],"CINAlert":[],"BeneficiaryAlert":{"Ben_code":null,"Beneficiary":null,"Status_Flag":null,"PAN_No":null}}]},"InternalDedupeResponse":[{"CustomerMaster":[{"CIC_No":"CU0503174","Matched_Customer_Code":"CU0503174","Rule_Matching_Fields":"VOTERID","Current_Parameter_Value":"CKK1913391","Matched_Parameter_Value":"CKK1913391","Matched_Score":"100","Rule_Field_Weightage":"100","Matched_Source":"CFD","Active_Flag":"Z","Dedupe_Super_Match":"Y","Dedupe_Super_Match_Score":"100","Rule_Id":"VOTERID100","Type":"C","PEP_Remarks":"","Customer_Name":null,"Customer_Type":null,"Date_of_Birth":null,"PAN_GIR_Number":null,"Passport_Number":null,"Voter_ID_Number":null,"Driving_License_Number":null,"Aadhaar_No":null},{"CIC_No":"CW3782547","Matched_Customer_Code":"CW3782547","Rule_Matching_Fields":"PAN","Current_Parameter_Value":"DMSPD9630N","Matched_Parameter_Value":"DMSPD9630N","Matched_Score":"100","Rule_Field_Weightage":"100","Matched_Source":"CFD","Active_Flag":"Y","Dedupe_Super_Match":"Y","Dedupe_Super_Match_Score":"100","Rule_Id":"PAN100","Type":"C","PEP_Remarks":"","Customer_Name":null,"Customer_Type":null,"Date_of_Birth":null,"PAN_GIR_Number":null,"Passport_Number":null,"Voter_ID_Number":null,"Driving_License_Number":null,"Aadhaar_No":null},{"CIC_No":"CW3782547","Matched_Customer_Code":"CW3782547","Rule_Matching_Fields":"VOTERID","Current_Parameter_Value":"CKK1913391","Matched_Parameter_Value":"CKK1913391","Matched_Score":"100","Rule_Field_Weightage":"100","Matched_Source":"CFD","Active_Flag":"Y","Dedupe_Super_Match":"Y","Dedupe_Super_Match_Score":"100","Rule_Id":"VOTERID100","Type":"C","PEP_Remarks":"","Customer_Name":null,"Customer_Type":null,"Date_of_Birth":null,"PAN_GIR_Number":null,"Passport_Number":null,"Voter_ID_Number":null,"Driving_License_Number":null,"Aadhaar_No":null},{"CIC_No":"CW4970396","Matched_Customer_Code":"CW4970396","Rule_Matching_Fields":"AADHAAR_NO","Current_Parameter_Value":"671940628725","Matched_Parameter_Value":"671940628725","Matched_Score":"100","Rule_Field_Weightage":"100","Matched_Source":"CFD","Active_Flag":"Y","Dedupe_Super_Match":"Y","Dedupe_Super_Match_Score":"100","Rule_Id":"ADHAR100","Type":"C","PEP_Remarks":"","Customer_Name":null,"Customer_Type":null,"Date_of_Birth":null,"PAN_GIR_Number":null,"Passport_Number":null,"Voter_ID_Number":null,"Driving_License_Number":null,"Aadhaar_No":null}],"CustomerValidate":[{"CustomerCodeVal":"CU0503174","CustomerMaster":[{"CIC_No":null,"Matched_Customer_Code":null,"Rule_Matching_Fields":null,"Current_Parameter_Value":null,"Matched_Parameter_Value":null,"Matched_Score":null,"Rule_Field_Weightage":null,"Matched_Source":null,"Active_Flag":null,"Dedupe_Super_Match":null,"Dedupe_Super_Match_Score":null,"Rule_Id":null,"Type":null,"PEP_Remarks":null,"Customer_Name":"S DEIVARAJ","Customer_Type":"10","Date_of_Birth":"27-06-1986 00:00:00","PAN_GIR_Number":"","Passport_Number":"","Voter_ID_Number":"CKK1913391","Driving_License_Number":"","Aadhaar_No":""}],"CustomerStatus":[{"Cross_Dedupe_Match_Id":"3095268","Active_Flag":"Z"}],"Dealstatus":[{"Deal_No":"TTU05950H","Status_Flag":"Z"}],"NPA":[],"Restructure":[{"Deal_Restructured":"Yes"}],"Gecl":[],"ARC":[],"PanAlert":[],"CINAlert":[],"BeneficiaryAlert":{"Ben_code":null,"Beneficiary":null,"Status_Flag":null,"PAN_No":null}},{"CustomerCodeVal":"CW3782547","CustomerMaster":[{"CIC_No":null,"Matched_Customer_Code":null,"Rule_Matching_Fields":null,"Current_Parameter_Value":null,"Matched_Parameter_Value":null,"Matched_Score":null,"Rule_Field_Weightage":null,"Matched_Source":null,"Active_Flag":null,"Dedupe_Super_Match":null,"Dedupe_Super_Match_Score":null,"Rule_Id":null,"Type":null,"PEP_Remarks":null,"Customer_Name":"DEIVARAJ","Customer_Type":"10","Date_of_Birth":"27-06-1984 00:00:00","PAN_GIR_Number":"DMSPD9630N","Passport_Number":"","Voter_ID_Number":"CKK1913391","Driving_License_Number":"","Aadhaar_No":"916901617335"}],"CustomerStatus":[{"Cross_Dedupe_Match_Id":"59675453","Active_Flag":"Y"}],"Dealstatus":[{"Deal_No":"TNU05150H","Status_Flag":"Z"},{"Deal_No":"TTU01390S","Status_Flag":"L"}],"NPA":[],"Restructure":[{"Deal_Restructured":"Yes"}],"Gecl":[],"ARC":[],"PanAlert":[],"CINAlert":[],"BeneficiaryAlert":{"Ben_code":null,"Beneficiary":null,"Status_Flag":null,"PAN_No":null}},{"CustomerCodeVal":"CW3782547","CustomerMaster":[{"CIC_No":null,"Matched_Customer_Code":null,"Rule_Matching_Fields":null,"Current_Parameter_Value":null,"Matched_Parameter_Value":null,"Matched_Score":null,"Rule_Field_Weightage":null,"Matched_Source":null,"Active_Flag":null,"Dedupe_Super_Match":null,"Dedupe_Super_Match_Score":null,"Rule_Id":null,"Type":null,"PEP_Remarks":null,"Customer_Name":"DEIVARAJ","Customer_Type":"10","Date_of_Birth":"27-06-1984 00:00:00","PAN_GIR_Number":"DMSPD9630N","Passport_Number":"","Voter_ID_Number":"CKK1913391","Driving_License_Number":"","Aadhaar_No":"916901617335"}],"CustomerStatus":[{"Cross_Dedupe_Match_Id":"59675453","Active_Flag":"Y"}],"Dealstatus":[{"Deal_No":"TNU05150H","Status_Flag":"Z"},{"Deal_No":"TTU01390S","Status_Flag":"L"}],"NPA":[],"Restructure":[{"Deal_Restructured":"Yes"}],"Gecl":[],"ARC":[],"PanAlert":[],"CINAlert":[],"BeneficiaryAlert":{"Ben_code":null,"Beneficiary":null,"Status_Flag":null,"PAN_No":null}},{"CustomerCodeVal":"CW4970396","CustomerMaster":[{"CIC_No":null,"Matched_Customer_Code":null,"Rule_Matching_Fields":null,"Current_Parameter_Value":null,"Matched_Parameter_Value":null,"Matched_Score":null,"Rule_Field_Weightage":null,"Matched_Source":null,"Active_Flag":null,"Dedupe_Super_Match":null,"Dedupe_Super_Match_Score":null,"Rule_Id":null,"Type":null,"PEP_Remarks":null,"Customer_Name":"NAGALAXMI","Customer_Type":"10","Date_of_Birth":"25-03-1981 00:00:00","PAN_GIR_Number":"COMPN4828K","Passport_Number":"","Voter_ID_Number":"","Driving_License_Number":"","Aadhaar_No":"671940628725"}],"CustomerStatus":[{"Cross_Dedupe_Match_Id":"70765909","Active_Flag":"Y"}],"Dealstatus":[],"NPA":[],"Restructure":[{"Deal_Restructured":"Yes"}],"Gecl":[],"ARC":[],"PanAlert":[],"CINAlert":[],"BeneficiaryAlert":{"Ben_code":null,"Beneficiary":null,"Status_Flag":null,"PAN_No":null}}]}]},"ErrorDesc":""}]}}';
            insert cdr3;
            
            Test.startTest();
            IND_LWC_StpChecksCntrl.stpChecks(opp.Id);
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void stpChecksTest14(){
        try{
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            opp.Loan_amount__c = '200000';
            opp.Product_Type__c = 'Passenger Vehicles';
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            
            opp.Sanction_Status__c = 'STP';
            update opp;
            
            Applicant__c app1 = TestDataUtility.createTestApplicantForSMS(false);
            app1.Applicant_Type__c = System.Label.CoBorrower;
            app1.In_Active_Applicant__c = true;
            app1.Opportunity__c = opp.Id;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert app1;
            }
            
            Income_Details__c inc1 = new Income_Details__c();
            inc1.Applicant__c = app1.id;
            //   inc1.Primary_Income_Source__c = true;
            inc1.Income_Source_Status__c = 'NIP';
            insert inc1;
            
            Final_Term__c ftd3 = new Final_Term__c();
            ftd3.CRM_IRR__c = 120;
            ftd3.Loan_Application__c = opp.Id;
            ftd3.Holiday_period__c='30';
            ftd3.Loan_Amount__c = '1000000';
            ftd3.LtvEngine_Ltv__c = 1000;
            ftd3.IsRequiredCRMIRRChanged__c = true;
            ftd3.OfferengineMaxLoanAmount__c = 90000;
            insert ftd3;
            
            Vehicle_Detail__c vgd2 = new Vehicle_Detail__c();
            vgd2.Loan_Application__c = opp.Id;
            vgd2.Base_Price__c = 100;
            vgd2.Ben_Code__c = 'testveh';
            vgd2.Insurance_declared_value__c = 100;
            vgd2.OEM_Dealer__c = true;
            vgd2.Model__c = 'Two wheeler';
            //  vgd2.Ins_Expiry_date__c = Date.newInstance(2021, 2, 23);
            //  vgd2.Vehicle_type__c = System.Label.used;
            insert vgd2; 
            
            Product2 prd1 = new Product2();
            prd1.Asset_Category__c = 'te';
            prd1.Name = vgd2.Model__c;
            prd1.Type__c = 'Model';
            prd1.External_Reference_Id__c = '58568568';
            insert prd1;
            
            Retry_Count__c rcga2 = new Retry_Count__c();
            rcga2.Loan_Application_Id__c = opp.Id;
            rcga2.Service_Name__c = 'FinalTermApi';
            rcga2.User_Id__c = UserInfo.getUserId();
            rcga2.IsAPIFailed__c = true;
            insert rcga2;
            
            Customer_Dedupe_Response__c cdr3 = new Customer_Dedupe_Response__c();
            cdr3.Applicant__c = app1.Id;
            cdr3.CIC_No__c = '545667';
            cdr3.CIN_No__c = '34455';
            cdr3.Customer_Code__c = 'test123';
            cdr3.SF_Cust_Dedupe__c = null;
            cdr3.PG_Cust_Dedupe__c = null;
            cdr3.Is_Journey_Skipped__c = false;
            cdr3.External_Dedupe_Status__c = 'P';
            cdr3.Customer_Status_Flag__c = 'F';
            //   cdr2.Response__c = '{"response":{"status":"SUCCESS","respDesc":"IxsightEnquiry","content":[{"Data":{"ExternalDedupeResponse":{"DEDUPE_STATUS":"M","DtCFDCUSTBAS":[{"SOURCE_CIC_NO":"2022268275545880078","MATCH_ECIF":"3095268","MATCHED_CUSTOMER_NAME":"S DEIVARAJ","MATCHED_CUSTOMER_CODE":"CU0503174","MATCHED_SOURCE":"CFD","MATCHED_SCORE":"100","MATCHED_CRITERIA":"VOTERID100","CONFIDENCE_LEVEL":"1"}],"DtRECENTLEAD":[{"SOURCE_CIC_NO":"2022268275545880078","MATCHED_CIC_NO":"991102194599513090","MATCHED_LEAD_NAME":"DEIVARAJ S","MATCHED_LEAD_DATE":"12/15/2021 13:55:28","MATCHED_SCORE":"100","MATCHED_CRITERIA":"PAN100"}],"CustomerValidate":[{"CustomerCodeVal":"CU0503174","CustomerMaster":[{"Customer_Name":"S DEIVARAJ","Customer_Type":"10","Date_of_Birth":"27-06-1986 00:00:00","PAN_GIR_Number":"","Passport_Number":"","Voter_ID_Number":"CKK1913391","Driving_License_Number":"","Aadhaar_No":""}],"CustomerStatus":[{"Cross_Dedupe_Match_Id":"3095268","Active_Flag":"Z"}],"Dealstatus":[{"Deal_No":"TTU05950H","Status_Flag":"Z"}],"NPA":[],"Restructure":[{"Deal_Restructured":"No"}],"Gecl":[{"Deal_No":"TTU05950H","Status_Flag":"Z"}],"ARC":[],"PanAlert":[],"CINAlert":[],"BeneficiaryAlert":{"Ben_code":null,"Beneficiary":null,"Status_Flag":null,"PAN_No":null}}]},"InternalDedupeResponse":[{"CustomerMaster":[{"CIC_No":"CU0503174","Matched_Customer_Code":"CU0503174","Rule_Matching_Fields":"VOTERID","Current_Parameter_Value":"CKK1913391","Matched_Parameter_Value":"CKK1913391","Matched_Score":"100","Rule_Field_Weightage":"100","Matched_Source":"CFD","Active_Flag":"Z","Dedupe_Super_Match":"Y","Dedupe_Super_Match_Score":"100","Rule_Id":"VOTERID100","Type":"C","PEP_Remarks":"","Customer_Name":null,"Customer_Type":null,"Date_of_Birth":null,"PAN_GIR_Number":null,"Passport_Number":null,"Voter_ID_Number":null,"Driving_License_Number":null,"Aadhaar_No":null},{"CIC_No":"CW3782547","Matched_Customer_Code":"CW3782547","Rule_Matching_Fields":"PAN","Current_Parameter_Value":"DMSPD9630N","Matched_Parameter_Value":"DMSPD9630N","Matched_Score":"100","Rule_Field_Weightage":"100","Matched_Source":"CFD","Active_Flag":"Y","Dedupe_Super_Match":"Y","Dedupe_Super_Match_Score":"100","Rule_Id":"PAN100","Type":"C","PEP_Remarks":"","Customer_Name":null,"Customer_Type":null,"Date_of_Birth":null,"PAN_GIR_Number":null,"Passport_Number":null,"Voter_ID_Number":null,"Driving_License_Number":null,"Aadhaar_No":null},{"CIC_No":"CW3782547","Matched_Customer_Code":"CW3782547","Rule_Matching_Fields":"VOTERID","Current_Parameter_Value":"CKK1913391","Matched_Parameter_Value":"CKK1913391","Matched_Score":"100","Rule_Field_Weightage":"100","Matched_Source":"CFD","Active_Flag":"Y","Dedupe_Super_Match":"Y","Dedupe_Super_Match_Score":"100","Rule_Id":"VOTERID100","Type":"C","PEP_Remarks":"","Customer_Name":null,"Customer_Type":null,"Date_of_Birth":null,"PAN_GIR_Number":null,"Passport_Number":null,"Voter_ID_Number":null,"Driving_License_Number":null,"Aadhaar_No":null},{"CIC_No":"CW4970396","Matched_Customer_Code":"CW4970396","Rule_Matching_Fields":"AADHAAR_NO","Current_Parameter_Value":"671940628725","Matched_Parameter_Value":"671940628725","Matched_Score":"100","Rule_Field_Weightage":"100","Matched_Source":"CFD","Active_Flag":"Y","Dedupe_Super_Match":"Y","Dedupe_Super_Match_Score":"100","Rule_Id":"ADHAR100","Type":"C","PEP_Remarks":"","Customer_Name":null,"Customer_Type":null,"Date_of_Birth":null,"PAN_GIR_Number":null,"Passport_Number":null,"Voter_ID_Number":null,"Driving_License_Number":null,"Aadhaar_No":null}],"CustomerValidate":[{"CustomerCodeVal":"CU0503174","CustomerMaster":[{"CIC_No":null,"Matched_Customer_Code":null,"Rule_Matching_Fields":null,"Current_Parameter_Value":null,"Matched_Parameter_Value":null,"Matched_Score":null,"Rule_Field_Weightage":null,"Matched_Source":null,"Active_Flag":null,"Dedupe_Super_Match":null,"Dedupe_Super_Match_Score":null,"Rule_Id":null,"Type":null,"PEP_Remarks":null,"Customer_Name":"S DEIVARAJ","Customer_Type":"10","Date_of_Birth":"27-06-1986 00:00:00","PAN_GIR_Number":"","Passport_Number":"","Voter_ID_Number":"CKK1913391","Driving_License_Number":"","Aadhaar_No":""}],"CustomerStatus":[{"Cross_Dedupe_Match_Id":"3095268","Active_Flag":"Z"}],"Dealstatus":[{"Deal_No":"TTU05950H","Status_Flag":"Z"}],"NPA":[],"Restructure":[{"Deal_Restructured":"Yes"}],"Gecl":[],"ARC":[],"PanAlert":[],"CINAlert":[],"BeneficiaryAlert":{"Ben_code":null,"Beneficiary":null,"Status_Flag":null,"PAN_No":null}},{"CustomerCodeVal":"CW3782547","CustomerMaster":[{"CIC_No":null,"Matched_Customer_Code":null,"Rule_Matching_Fields":null,"Current_Parameter_Value":null,"Matched_Parameter_Value":null,"Matched_Score":null,"Rule_Field_Weightage":null,"Matched_Source":null,"Active_Flag":null,"Dedupe_Super_Match":null,"Dedupe_Super_Match_Score":null,"Rule_Id":null,"Type":null,"PEP_Remarks":null,"Customer_Name":"DEIVARAJ","Customer_Type":"10","Date_of_Birth":"27-06-1984 00:00:00","PAN_GIR_Number":"DMSPD9630N","Passport_Number":"","Voter_ID_Number":"CKK1913391","Driving_License_Number":"","Aadhaar_No":"916901617335"}],"CustomerStatus":[{"Cross_Dedupe_Match_Id":"59675453","Active_Flag":"Y"}],"Dealstatus":[{"Deal_No":"TNU05150H","Status_Flag":"Z"},{"Deal_No":"TTU01390S","Status_Flag":"L"}],"NPA":[],"Restructure":[{"Deal_Restructured":"Yes"}],"Gecl":[],"ARC":[],"PanAlert":[],"CINAlert":[],"BeneficiaryAlert":{"Ben_code":null,"Beneficiary":null,"Status_Flag":null,"PAN_No":null}},{"CustomerCodeVal":"CW3782547","CustomerMaster":[{"CIC_No":null,"Matched_Customer_Code":null,"Rule_Matching_Fields":null,"Current_Parameter_Value":null,"Matched_Parameter_Value":null,"Matched_Score":null,"Rule_Field_Weightage":null,"Matched_Source":null,"Active_Flag":null,"Dedupe_Super_Match":null,"Dedupe_Super_Match_Score":null,"Rule_Id":null,"Type":null,"PEP_Remarks":null,"Customer_Name":"DEIVARAJ","Customer_Type":"10","Date_of_Birth":"27-06-1984 00:00:00","PAN_GIR_Number":"DMSPD9630N","Passport_Number":"","Voter_ID_Number":"CKK1913391","Driving_License_Number":"","Aadhaar_No":"916901617335"}],"CustomerStatus":[{"Cross_Dedupe_Match_Id":"59675453","Active_Flag":"Y"}],"Dealstatus":[{"Deal_No":"TNU05150H","Status_Flag":"Z"},{"Deal_No":"TTU01390S","Status_Flag":"L"}],"NPA":[],"Restructure":[{"Deal_Restructured":"Yes"}],"Gecl":[],"ARC":[],"PanAlert":[],"CINAlert":[],"BeneficiaryAlert":{"Ben_code":null,"Beneficiary":null,"Status_Flag":null,"PAN_No":null}},{"CustomerCodeVal":"CW4970396","CustomerMaster":[{"CIC_No":null,"Matched_Customer_Code":null,"Rule_Matching_Fields":null,"Current_Parameter_Value":null,"Matched_Parameter_Value":null,"Matched_Score":null,"Rule_Field_Weightage":null,"Matched_Source":null,"Active_Flag":null,"Dedupe_Super_Match":null,"Dedupe_Super_Match_Score":null,"Rule_Id":null,"Type":null,"PEP_Remarks":null,"Customer_Name":"NAGALAXMI","Customer_Type":"10","Date_of_Birth":"25-03-1981 00:00:00","PAN_GIR_Number":"COMPN4828K","Passport_Number":"","Voter_ID_Number":"","Driving_License_Number":"","Aadhaar_No":"671940628725"}],"CustomerStatus":[{"Cross_Dedupe_Match_Id":"70765909","Active_Flag":"Y"}],"Dealstatus":[],"NPA":[],"Restructure":[{"Deal_Restructured":"Yes"}],"Gecl":[],"ARC":[],"PanAlert":[],"CINAlert":[],"BeneficiaryAlert":{"Ben_code":null,"Beneficiary":null,"Status_Flag":null,"PAN_No":null}}]}]},"ErrorDesc":""}]}}';
            insert cdr3;
            
            Test.startTest();
            IND_LWC_StpChecksCntrl.stpChecks(opp.Id);
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void stpChecksTest15(){
        try{
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            opp.Loan_amount__c = '200000';
            //   opp.Product_Type__c = 'Passenger Vehicles';
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            
            opp.Sanction_Status__c = 'STP';
            update opp;
            
            Applicant__c app1 = new Applicant__c();
            app1.Applicant_Type__c = System.Label.Borrower;
            app1.In_Active_Applicant__c = false;
            app1.Bureau_Pull_Match__c = false;
            app1.Check_Eligibility_Match__c = false;
            app1.Opportunity__c = opp.Id;
            app1.Contact_number__c = '9999999999';
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert app1;
            }
            
            Income_Details__c inc1 = new Income_Details__c();
            inc1.Applicant__c = app1.id;
            inc1.Primary_Income_Source__c = true;
            inc1.Income_Source_Status__c = 'NIP';
            insert inc1;
            
            /*    Final_Term__c ftd3 = new Final_Term__c();
ftd3.CRM_IRR__c = 120;
ftd3.Loan_Application__c = opp.Id;
ftd3.Holiday_period__c='30';
ftd3.Loan_Amount__c = '1000000';
ftd3.LtvEngine_Ltv__c = 1000;
ftd3.IsRequiredCRMIRRChanged__c = true;
insert ftd3;

Vehicle_Detail__c vgd2 = new Vehicle_Detail__c();
vgd2.Loan_Application__c = opp.Id;
vgd2.Base_Price__c = 100;
vgd2.Ben_Code__c = 'testveh';
vgd2.Insurance_declared_value__c = 100;
vgd2.OEM_Dealer__c = true;
vgd2.Model__c = 'Two wheeler';
//  vgd2.Ins_Expiry_date__c = Date.newInstance(2021, 2, 23);
//  vgd2.Vehicle_type__c = System.Label.used;
insert vgd2; 

Retry_Count__c rcga2 = new Retry_Count__c();
rcga2.Loan_Application_Id__c = opp.Id;
rcga2.Service_Name__c = 'FinalTermApi';
rcga2.User_Id__c = UserInfo.getUserId();
rcga2.IsAPIFailed__c = true;
insert rcga2; */
            
            Customer_Dedupe_Response__c cdr3 = new Customer_Dedupe_Response__c();
            cdr3.Applicant__c = app1.Id;
            cdr3.CIC_No__c = '545667';
            cdr3.CIN_No__c = '34455';
            cdr3.Customer_Code__c = 'test123';
            cdr3.SF_Cust_Dedupe__c = null;
            cdr3.PG_Cust_Dedupe__c = null;
            cdr3.Is_Journey_Skipped__c = false;
            cdr3.External_Dedupe_Status__c = 'P';
            //   cdr3.Customer_Status_Flag__c = 'F';
            //   cdr2.Response__c = '{"response":{"status":"SUCCESS","respDesc":"IxsightEnquiry","content":[{"Data":{"ExternalDedupeResponse":{"DEDUPE_STATUS":"M","DtCFDCUSTBAS":[{"SOURCE_CIC_NO":"2022268275545880078","MATCH_ECIF":"3095268","MATCHED_CUSTOMER_NAME":"S DEIVARAJ","MATCHED_CUSTOMER_CODE":"CU0503174","MATCHED_SOURCE":"CFD","MATCHED_SCORE":"100","MATCHED_CRITERIA":"VOTERID100","CONFIDENCE_LEVEL":"1"}],"DtRECENTLEAD":[{"SOURCE_CIC_NO":"2022268275545880078","MATCHED_CIC_NO":"991102194599513090","MATCHED_LEAD_NAME":"DEIVARAJ S","MATCHED_LEAD_DATE":"12/15/2021 13:55:28","MATCHED_SCORE":"100","MATCHED_CRITERIA":"PAN100"}],"CustomerValidate":[{"CustomerCodeVal":"CU0503174","CustomerMaster":[{"Customer_Name":"S DEIVARAJ","Customer_Type":"10","Date_of_Birth":"27-06-1986 00:00:00","PAN_GIR_Number":"","Passport_Number":"","Voter_ID_Number":"CKK1913391","Driving_License_Number":"","Aadhaar_No":""}],"CustomerStatus":[{"Cross_Dedupe_Match_Id":"3095268","Active_Flag":"Z"}],"Dealstatus":[{"Deal_No":"TTU05950H","Status_Flag":"Z"}],"NPA":[],"Restructure":[{"Deal_Restructured":"No"}],"Gecl":[{"Deal_No":"TTU05950H","Status_Flag":"Z"}],"ARC":[],"PanAlert":[],"CINAlert":[],"BeneficiaryAlert":{"Ben_code":null,"Beneficiary":null,"Status_Flag":null,"PAN_No":null}}]},"InternalDedupeResponse":[{"CustomerMaster":[{"CIC_No":"CU0503174","Matched_Customer_Code":"CU0503174","Rule_Matching_Fields":"VOTERID","Current_Parameter_Value":"CKK1913391","Matched_Parameter_Value":"CKK1913391","Matched_Score":"100","Rule_Field_Weightage":"100","Matched_Source":"CFD","Active_Flag":"Z","Dedupe_Super_Match":"Y","Dedupe_Super_Match_Score":"100","Rule_Id":"VOTERID100","Type":"C","PEP_Remarks":"","Customer_Name":null,"Customer_Type":null,"Date_of_Birth":null,"PAN_GIR_Number":null,"Passport_Number":null,"Voter_ID_Number":null,"Driving_License_Number":null,"Aadhaar_No":null},{"CIC_No":"CW3782547","Matched_Customer_Code":"CW3782547","Rule_Matching_Fields":"PAN","Current_Parameter_Value":"DMSPD9630N","Matched_Parameter_Value":"DMSPD9630N","Matched_Score":"100","Rule_Field_Weightage":"100","Matched_Source":"CFD","Active_Flag":"Y","Dedupe_Super_Match":"Y","Dedupe_Super_Match_Score":"100","Rule_Id":"PAN100","Type":"C","PEP_Remarks":"","Customer_Name":null,"Customer_Type":null,"Date_of_Birth":null,"PAN_GIR_Number":null,"Passport_Number":null,"Voter_ID_Number":null,"Driving_License_Number":null,"Aadhaar_No":null},{"CIC_No":"CW3782547","Matched_Customer_Code":"CW3782547","Rule_Matching_Fields":"VOTERID","Current_Parameter_Value":"CKK1913391","Matched_Parameter_Value":"CKK1913391","Matched_Score":"100","Rule_Field_Weightage":"100","Matched_Source":"CFD","Active_Flag":"Y","Dedupe_Super_Match":"Y","Dedupe_Super_Match_Score":"100","Rule_Id":"VOTERID100","Type":"C","PEP_Remarks":"","Customer_Name":null,"Customer_Type":null,"Date_of_Birth":null,"PAN_GIR_Number":null,"Passport_Number":null,"Voter_ID_Number":null,"Driving_License_Number":null,"Aadhaar_No":null},{"CIC_No":"CW4970396","Matched_Customer_Code":"CW4970396","Rule_Matching_Fields":"AADHAAR_NO","Current_Parameter_Value":"671940628725","Matched_Parameter_Value":"671940628725","Matched_Score":"100","Rule_Field_Weightage":"100","Matched_Source":"CFD","Active_Flag":"Y","Dedupe_Super_Match":"Y","Dedupe_Super_Match_Score":"100","Rule_Id":"ADHAR100","Type":"C","PEP_Remarks":"","Customer_Name":null,"Customer_Type":null,"Date_of_Birth":null,"PAN_GIR_Number":null,"Passport_Number":null,"Voter_ID_Number":null,"Driving_License_Number":null,"Aadhaar_No":null}],"CustomerValidate":[{"CustomerCodeVal":"CU0503174","CustomerMaster":[{"CIC_No":null,"Matched_Customer_Code":null,"Rule_Matching_Fields":null,"Current_Parameter_Value":null,"Matched_Parameter_Value":null,"Matched_Score":null,"Rule_Field_Weightage":null,"Matched_Source":null,"Active_Flag":null,"Dedupe_Super_Match":null,"Dedupe_Super_Match_Score":null,"Rule_Id":null,"Type":null,"PEP_Remarks":null,"Customer_Name":"S DEIVARAJ","Customer_Type":"10","Date_of_Birth":"27-06-1986 00:00:00","PAN_GIR_Number":"","Passport_Number":"","Voter_ID_Number":"CKK1913391","Driving_License_Number":"","Aadhaar_No":""}],"CustomerStatus":[{"Cross_Dedupe_Match_Id":"3095268","Active_Flag":"Z"}],"Dealstatus":[{"Deal_No":"TTU05950H","Status_Flag":"Z"}],"NPA":[],"Restructure":[{"Deal_Restructured":"Yes"}],"Gecl":[],"ARC":[],"PanAlert":[],"CINAlert":[],"BeneficiaryAlert":{"Ben_code":null,"Beneficiary":null,"Status_Flag":null,"PAN_No":null}},{"CustomerCodeVal":"CW3782547","CustomerMaster":[{"CIC_No":null,"Matched_Customer_Code":null,"Rule_Matching_Fields":null,"Current_Parameter_Value":null,"Matched_Parameter_Value":null,"Matched_Score":null,"Rule_Field_Weightage":null,"Matched_Source":null,"Active_Flag":null,"Dedupe_Super_Match":null,"Dedupe_Super_Match_Score":null,"Rule_Id":null,"Type":null,"PEP_Remarks":null,"Customer_Name":"DEIVARAJ","Customer_Type":"10","Date_of_Birth":"27-06-1984 00:00:00","PAN_GIR_Number":"DMSPD9630N","Passport_Number":"","Voter_ID_Number":"CKK1913391","Driving_License_Number":"","Aadhaar_No":"916901617335"}],"CustomerStatus":[{"Cross_Dedupe_Match_Id":"59675453","Active_Flag":"Y"}],"Dealstatus":[{"Deal_No":"TNU05150H","Status_Flag":"Z"},{"Deal_No":"TTU01390S","Status_Flag":"L"}],"NPA":[],"Restructure":[{"Deal_Restructured":"Yes"}],"Gecl":[],"ARC":[],"PanAlert":[],"CINAlert":[],"BeneficiaryAlert":{"Ben_code":null,"Beneficiary":null,"Status_Flag":null,"PAN_No":null}},{"CustomerCodeVal":"CW3782547","CustomerMaster":[{"CIC_No":null,"Matched_Customer_Code":null,"Rule_Matching_Fields":null,"Current_Parameter_Value":null,"Matched_Parameter_Value":null,"Matched_Score":null,"Rule_Field_Weightage":null,"Matched_Source":null,"Active_Flag":null,"Dedupe_Super_Match":null,"Dedupe_Super_Match_Score":null,"Rule_Id":null,"Type":null,"PEP_Remarks":null,"Customer_Name":"DEIVARAJ","Customer_Type":"10","Date_of_Birth":"27-06-1984 00:00:00","PAN_GIR_Number":"DMSPD9630N","Passport_Number":"","Voter_ID_Number":"CKK1913391","Driving_License_Number":"","Aadhaar_No":"916901617335"}],"CustomerStatus":[{"Cross_Dedupe_Match_Id":"59675453","Active_Flag":"Y"}],"Dealstatus":[{"Deal_No":"TNU05150H","Status_Flag":"Z"},{"Deal_No":"TTU01390S","Status_Flag":"L"}],"NPA":[],"Restructure":[{"Deal_Restructured":"Yes"}],"Gecl":[],"ARC":[],"PanAlert":[],"CINAlert":[],"BeneficiaryAlert":{"Ben_code":null,"Beneficiary":null,"Status_Flag":null,"PAN_No":null}},{"CustomerCodeVal":"CW4970396","CustomerMaster":[{"CIC_No":null,"Matched_Customer_Code":null,"Rule_Matching_Fields":null,"Current_Parameter_Value":null,"Matched_Parameter_Value":null,"Matched_Score":null,"Rule_Field_Weightage":null,"Matched_Source":null,"Active_Flag":null,"Dedupe_Super_Match":null,"Dedupe_Super_Match_Score":null,"Rule_Id":null,"Type":null,"PEP_Remarks":null,"Customer_Name":"NAGALAXMI","Customer_Type":"10","Date_of_Birth":"25-03-1981 00:00:00","PAN_GIR_Number":"COMPN4828K","Passport_Number":"","Voter_ID_Number":"","Driving_License_Number":"","Aadhaar_No":"671940628725"}],"CustomerStatus":[{"Cross_Dedupe_Match_Id":"70765909","Active_Flag":"Y"}],"Dealstatus":[],"NPA":[],"Restructure":[{"Deal_Restructured":"Yes"}],"Gecl":[],"ARC":[],"PanAlert":[],"CINAlert":[],"BeneficiaryAlert":{"Ben_code":null,"Beneficiary":null,"Status_Flag":null,"PAN_No":null}}]}]},"ErrorDesc":""}]}}';
            insert cdr3; 
            
            Test.startTest();
            IND_LWC_StpChecksCntrl.stpChecks(opp.Id);
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void stpVerifyTest(){
        try{
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            opp.Sanction_Status__c = 'Non-STP';
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            
            Test.startTest();
            IND_LWC_StpChecksCntrl.stpVerify(opp.Id);
            IND_LWC_StpChecksCntrl.stpVerify('test');
            Test.stopTest();
            
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void stpChecksTest16(){
        try{
            Opportunity opga1 = new Opportunity();
            opga1.StageName = 'Qualification';
            opga1.CloseDate = Date.newInstance(2021, 1, 11);
            opga1.Name = 'testone';
            opga1.Vehicle_Sub_Category__c = 'URS';
            opga1.Vehicle_Type__c = 'Used';
            opga1.Product_Type__c = System.Label.PassengerVehicles;
            //opga1.Total_Funded_Premium__c = 300000;
            opga1.Loan_amount__c = '500000';
            insert opga1;
            
            Applicant__c apga1 = new Applicant__c();
            apga1.Opportunity__c = opga1.Id;
            apga1.Contact_number__c = '9743514830';
            apga1.Applicant_Type__c = 'Borrower';
            insert apga1;
            
            Test.startTest();
            IND_LWC_StpChecksCntrl.stpChecks(opga1.Id);
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void stpChecksTest17(){
        try{
            Opportunity opga1 = new Opportunity();
            opga1.StageName = 'Qualification';
            opga1.CloseDate = Date.newInstance(2021, 1, 11);
            opga1.Name = 'testone';
            opga1.Vehicle_Sub_Category__c = 'URS';
            opga1.Vehicle_Type__c = 'Used';
            opga1.Product_Type__c = System.Label.TwoWheeler;
            insert opga1;
            
            Applicant__c apga1 = new Applicant__c();
            apga1.Opportunity__c = opga1.Id;
            apga1.Contact_number__c = '9743514830';
            apga1.Applicant_Type__c = 'Borrower';
            insert apga1;
            
            Test.startTest();
            IND_LWC_StpChecksCntrl.stpChecks(opga1.Id);
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void stpChecksTest18(){
        try{
            Opportunity opga1 = new Opportunity();
            opga1.StageName = 'Qualification';
            opga1.CloseDate = Date.newInstance(2021, 1, 11);
            opga1.Name = 'testone';
            opga1.Vehicle_Sub_Category__c = 'UIM';
            opga1.Vehicle_Type__c = 'Used';
            opga1.Product_Type__c = System.Label.PassengerVehicles;
            opga1.Loan_amount__c = '600000';
            insert opga1;
            
            Applicant__c apga1 = new Applicant__c();
            apga1.Opportunity__c = opga1.Id;
            apga1.Contact_number__c = '9743514830';
            apga1.Applicant_Type__c = 'Borrower';
            insert apga1;
            
            Income_details__c incomeDetails =  new Income_details__c();
            incomeDetails.Income_Source_Status__c = 'NIP';
            incomeDetails.Applicant__c = apga1.id;
            incomeDetails.Name = 'test';
            incomeDetails.Primary_Income_Source__c = true;
            insert incomeDetails;
            
            Vehicle_Detail__c vgd2 = new Vehicle_Detail__c();
            vgd2.Loan_Application__c = opga1.Id;
            vgd2.Base_Price__c = 100;
            vgd2.Ben_Code__c = 'testveh';
            vgd2.Insurance_declared_value__c = 100;
            vgd2.Model__c = 'Two wheeler';
            vgd2.Ins_Expiry_date__c = Date.newInstance(2021, 2, 23);
            //  vgd2.Vehicle_type__c = System.Label.used;
            insert vgd2; 
            
            Final_Term__c ftd3 = new Final_Term__c();
            ftd3.CRM_IRR__c = 120;
            ftd3.Loan_Application__c = opga1.Id;
            ftd3.Holiday_period__c='30';
            ftd3.Loan_Amount__c = '1000000';
            ftd3.LtvEngine_Ltv__c = 1000;
            ftd3.Scheme_Bank_offers__c = 'test';
            insert ftd3;
            
            Test.startTest();
            IND_LWC_StpChecksCntrl.stpChecks(opga1.Id);
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void stpChecksTest28(){
        try{
            Opportunity opga1 = new Opportunity();
            opga1.StageName = 'Qualification';
            opga1.CloseDate = Date.newInstance(2021, 1, 11);
            opga1.Name = 'testone';
            opga1.Vehicle_Sub_Category__c = 'UIM';
            opga1.Vehicle_Type__c = 'Used';
            opga1.Product_Type__c = System.Label.PassengerVehicles;
            opga1.Loan_amount__c = '600000';
            insert opga1;
            
            Integration_Log__c inteLog = new Integration_Log__c();
            inteLog.Loan_Application__c = opga1.Id;
            inteLog.Service_Name__c = 'Fico Deviations';
            inteLog.Status__c = 'Success';
            insert inteLog;
            
            Applicant__c apga1 = new Applicant__c();
            apga1.Opportunity__c = opga1.Id;
            apga1.Contact_number__c = '9743514830';
            apga1.Applicant_Type__c = 'Borrower';
            insert apga1;
            
            Income_details__c incomeDetails =  new Income_details__c();
            incomeDetails.Income_Source_Status__c = 'SEP-Not Verified';
            incomeDetails.Applicant__c = apga1.id;
            incomeDetails.Name = 'test';
            incomeDetails.Primary_Income_Source__c = true;
            insert incomeDetails;
            
            ContentVersion contentVersion = new ContentVersion(
                Title = 'Penguins',
                PathOnClient = 'Penguins.jpg',
                VersionData = Blob.valueOf('Test Content'),
                IsMajorVersion = true
            );
            insert contentVersion;    
            List<ContentDocument> documents = [
                SELECT Id, Title, LatestPublishedVersionId 
                FROM ContentDocument
            ];
            
            //create ContentDocumentLink  record 
            ContentDocumentLink cdl = New ContentDocumentLink();
            cdl.LinkedEntityId = incomeDetails.id;
            cdl.ContentDocumentId = documents[0].Id;
            cdl.shareType = 'V';
            insert cdl;
            
            Vehicle_Detail__c vgd2 = new Vehicle_Detail__c();
            vgd2.Loan_Application__c = opga1.Id;
            vgd2.Base_Price__c = 100;
            vgd2.Ben_Code__c = 'testveh';
            vgd2.Insurance_declared_value__c = 100;
            vgd2.Model__c = 'Two wheeler';
            vgd2.Ins_Expiry_date__c = Date.newInstance(2021, 2, 23);
            //  vgd2.Vehicle_type__c = System.Label.used;
            insert vgd2; 
            
            Final_Term__c ftd3 = new Final_Term__c();
            ftd3.CRM_IRR__c = 120;
            ftd3.Loan_Application__c = opga1.Id;
            ftd3.Holiday_period__c='30';
            ftd3.Loan_Amount__c = '1000000';
            ftd3.LtvEngine_Ltv__c = 1000;
            ftd3.Scheme_Bank_offers__c = 'test';
            insert ftd3;
            
            Test.startTest();
            IND_LWC_StpChecksCntrl.stpChecks(opga1.Id);
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void stpChecksTest38(){
        try{
            Opportunity opga1 = new Opportunity();
            opga1.StageName = 'Qualification';
            opga1.CloseDate = Date.newInstance(2021, 1, 11);
            opga1.Name = 'testone';
            opga1.Vehicle_Sub_Category__c = 'UIM';
            opga1.Vehicle_Type__c = 'Used';
            opga1.Product_Type__c = System.Label.PassengerVehicles;
            opga1.Loan_amount__c = '600000';
            insert opga1;
            
            Integration_Log__c inteLog = new Integration_Log__c();
            inteLog.Loan_Application__c = opga1.Id;
            inteLog.Service_Name__c = 'Fico Deviations';
            inteLog.Status__c = 'Failure';
            insert inteLog;
            
            Applicant__c apga1 = new Applicant__c();
            apga1.Opportunity__c = opga1.Id;
            apga1.Contact_number__c = '9743514830';
            apga1.Applicant_Type__c = 'Borrower';
            insert apga1;
            
            Income_details__c incomeDetails =  new Income_details__c();
            incomeDetails.Income_Source_Status__c = 'SEP-Not Verified';
            incomeDetails.Applicant__c = apga1.id;
            incomeDetails.Name = 'test';
            incomeDetails.Primary_Income_Source__c = true;
            insert incomeDetails;
            
            ContentVersion contentVersion = new ContentVersion(
                Title = 'Penguins',
                PathOnClient = 'Penguins.jpg',
                VersionData = Blob.valueOf('Test Content'),
                IsMajorVersion = true
            );
            insert contentVersion;    
            List<ContentDocument> documents = [
                SELECT Id, Title, LatestPublishedVersionId 
                FROM ContentDocument
            ];
            
            //create ContentDocumentLink  record 
            ContentDocumentLink cdl = New ContentDocumentLink();
            cdl.LinkedEntityId = incomeDetails.id;
            cdl.ContentDocumentId = documents[0].Id;
            cdl.shareType = 'V';
            insert cdl;
            
            Vehicle_Detail__c vgd2 = new Vehicle_Detail__c();
            vgd2.Loan_Application__c = opga1.Id;
            vgd2.Base_Price__c = 100;
            vgd2.Ben_Code__c = 'testveh';
            vgd2.Insurance_declared_value__c = 100;
            vgd2.Model__c = 'Two wheeler';
            vgd2.Ins_Expiry_date__c = Date.newInstance(2021, 2, 23);
            //  vgd2.Vehicle_type__c = System.Label.used;
            insert vgd2; 
            
            Final_Term__c ftd3 = new Final_Term__c();
            ftd3.CRM_IRR__c = 120;
            ftd3.Loan_Application__c = opga1.Id;
            ftd3.Holiday_period__c='30';
            ftd3.Loan_Amount__c = '1000000';
            ftd3.LtvEngine_Ltv__c = 1000;
            ftd3.Scheme_Bank_offers__c = 'test';
            insert ftd3;
            
            Test.startTest();
            IND_LWC_StpChecksCntrl.stpChecks(opga1.Id);
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void stpChecksTest19(){
        try{
            Opportunity opga1 = new Opportunity();
            opga1.StageName = 'Qualification';
            opga1.CloseDate = Date.newInstance(2021, 1, 11);
            opga1.Name = 'testone';
            opga1.Vehicle_Sub_Category__c = 'UIM';
            opga1.Vehicle_Type__c = 'Used';
            opga1.Product_Type__c = System.Label.used;
            opga1.Loan_amount__c = '600000';
            insert opga1;
            
            Applicant__c apga1 = new Applicant__c();
            apga1.Opportunity__c = opga1.Id;
            apga1.Contact_number__c = '9743514830';
            apga1.Applicant_Type__c = 'Borrower';
            insert apga1;
            
            Vehicle_Detail__c vgd2 = new Vehicle_Detail__c();
            vgd2.Loan_Application__c = opga1.Id;
            vgd2.Base_Price__c = 100;
            vgd2.Ben_Code__c = 'testveh';
            vgd2.Insurance_declared_value__c = 100;
            vgd2.Model__c = 'Two wheeler';
            vgd2.Ins_Expiry_date__c = Date.newInstance(2021, 2, 23);
            //  vgd2.Vehicle_type__c = System.Label.used;
            insert vgd2; 
            
            Final_Term__c ftd3 = new Final_Term__c();
            ftd3.CRM_IRR__c = 120;
            ftd3.Loan_Application__c = opga1.Id;
            ftd3.Holiday_period__c='30';
            ftd3.Loan_Amount__c = '1000000';
            ftd3.LtvEngine_Ltv__c = null;
            insert ftd3;
            
            Test.startTest();
            IND_LWC_StpChecksCntrl.stpChecks(opga1.Id);
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void stpChecksTest20(){
        try{
            Opportunity opga1 = new Opportunity();
            opga1.StageName = 'Qualification';
            opga1.CloseDate = Date.newInstance(2021, 1, 11);
            opga1.Name = 'testone';
            opga1.Vehicle_Type__c = System.Label.new;
            opga1.Loan_amount__c = '600000';
            insert opga1;
            
            Applicant__c apga1 = new Applicant__c();
            apga1.Opportunity__c = opga1.Id;
            apga1.Contact_number__c = '9743514830';
            apga1.Applicant_Type__c = 'Borrower';
            insert apga1;
            
            Final_Term__c ftd3 = new Final_Term__c();
            ftd3.CRM_IRR__c = 120;
            ftd3.Loan_Application__c = opga1.Id;
            ftd3.Holiday_period__c='30';
            ftd3.LtvEngine_Ltv__c = 10000;
            insert ftd3;
            
            
            
            Test.startTest();
            IND_LWC_StpChecksCntrl.stpChecks(opga1.Id);
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void stpChecksTest21(){
        try{
            Opportunity opga1 = new Opportunity();
            opga1.StageName = 'Qualification';
            opga1.CloseDate = Date.newInstance(2021, 1, 11);
            opga1.Name = 'testone';
            //    opga1.Vehicle_Type__c = System.Label.new;
            //    opga1.Loan_amount__c = '600000';
            insert opga1;
            
            Applicant__c apga1 = new Applicant__c();
            apga1.Opportunity__c = opga1.Id;
            apga1.Contact_number__c = '9743514830';
            apga1.Applicant_Type__c = 'Borrower';
            apga1.Current_Address_Not_Present__c = true;
            insert apga1;
            
            Final_Term__c ftd3 = new Final_Term__c();
            ftd3.CRM_IRR__c = 120;
            ftd3.Loan_Application__c = opga1.Id;
            ftd3.Holiday_period__c='30';
            ftd3.IsRequiredCRMIRRChanged__c = false;
            insert ftd3;
            
            Test.startTest();
            IND_LWC_StpChecksCntrl.stpChecks(opga1.Id);
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void stpChecksTest22(){
        try{
            Opportunity opga1 = new Opportunity();
            opga1.StageName = 'Qualification';
            opga1.CloseDate = Date.newInstance(2021, 1, 11);
            opga1.Name = 'testone';
            opga1.Product_Type__c = System.Label.PassengerVehicles;
            insert opga1;
            
            Applicant__c apga1 = new Applicant__c();
            apga1.Opportunity__c = opga1.Id;
            apga1.Contact_number__c = '9743514830';
            apga1.Applicant_Type__c = 'Borrower';
            apga1.Bureau_Pull_Match__c = false;
            insert apga1;
            
            Final_Term__c ftd3 = new Final_Term__c();
            ftd3.CRM_IRR__c = 120;
            ftd3.Loan_Application__c = opga1.Id;
            ftd3.Holiday_period__c='30';
            insert ftd3;
            
            Income_Details__c inc1 = new Income_Details__c();
            inc1.Applicant__c = apga1.id;
            inc1.Income_Source_Status__c = 'SEP';
            insert inc1;
            
            Test.startTest();
            IND_LWC_StpChecksCntrl.stpChecks(opga1.Id);
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void stpChecksTest23(){
        try{
            Opportunity opga1 = new Opportunity();
            opga1.StageName = 'Qualification';
            opga1.CloseDate = Date.newInstance(2021, 1, 11);
            opga1.Name = 'testone';
            opga1.Product_Type__c = System.Label.PassengerVehicles;
            insert opga1;
            
            Applicant__c apga1 = new Applicant__c();
            apga1.Opportunity__c = opga1.Id;
            apga1.Contact_number__c = '9743514830';
            apga1.Applicant_Type__c = 'Borrower';
            apga1.Bureau_Pull_Match__c = false;
            apga1.In_Active_Applicant__c = false;
            insert apga1;
            
            
            Income_Details__c inc1 = new Income_Details__c();
            inc1.Applicant__c = apga1.id;
            inc1.Income_Source_Status__c = 'NIP';
            inc1.Primary_Income_Source__c = true;
            insert inc1;
            
            Customer_Dedupe_Response__c cdr4 = new Customer_Dedupe_Response__c();
            cdr4.Applicant__c = apga1.Id;
            cdr4.CIC_No__c = '545667';
            cdr4.CIN_No__c = '34455';
            cdr4.SF_Cust_Dedupe__c = null;
            cdr4.PG_Cust_Dedupe__c = null;
            cdr4.Is_Journey_Skipped__c = false;
            //   cdr2.Response__c = '{"response":{"status":"SUCCESS","respDesc":"IxsightEnquiry","content":[{"Data":{"ExternalDedupeResponse":{"DEDUPE_STATUS":"M","DtCFDCUSTBAS":[{"SOURCE_CIC_NO":"2022268275545880078","MATCH_ECIF":"3095268","MATCHED_CUSTOMER_NAME":"S DEIVARAJ","MATCHED_CUSTOMER_CODE":"CU0503174","MATCHED_SOURCE":"CFD","MATCHED_SCORE":"100","MATCHED_CRITERIA":"VOTERID100","CONFIDENCE_LEVEL":"1"}],"DtRECENTLEAD":[{"SOURCE_CIC_NO":"2022268275545880078","MATCHED_CIC_NO":"991102194599513090","MATCHED_LEAD_NAME":"DEIVARAJ S","MATCHED_LEAD_DATE":"12/15/2021 13:55:28","MATCHED_SCORE":"100","MATCHED_CRITERIA":"PAN100"}],"CustomerValidate":[{"CustomerCodeVal":"CU0503174","CustomerMaster":[{"Customer_Name":"S DEIVARAJ","Customer_Type":"10","Date_of_Birth":"27-06-1986 00:00:00","PAN_GIR_Number":"","Passport_Number":"","Voter_ID_Number":"CKK1913391","Driving_License_Number":"","Aadhaar_No":""}],"CustomerStatus":[{"Cross_Dedupe_Match_Id":"3095268","Active_Flag":"Z"}],"Dealstatus":[{"Deal_No":"TTU05950H","Status_Flag":"Z"}],"NPA":[],"Restructure":[{"Deal_Restructured":"No"}],"Gecl":[{"Deal_No":"TTU05950H","Status_Flag":"Z"}],"ARC":[],"PanAlert":[],"CINAlert":[],"BeneficiaryAlert":{"Ben_code":null,"Beneficiary":null,"Status_Flag":null,"PAN_No":null}}]},"InternalDedupeResponse":[{"CustomerMaster":[{"CIC_No":"CU0503174","Matched_Customer_Code":"CU0503174","Rule_Matching_Fields":"VOTERID","Current_Parameter_Value":"CKK1913391","Matched_Parameter_Value":"CKK1913391","Matched_Score":"100","Rule_Field_Weightage":"100","Matched_Source":"CFD","Active_Flag":"Z","Dedupe_Super_Match":"Y","Dedupe_Super_Match_Score":"100","Rule_Id":"VOTERID100","Type":"C","PEP_Remarks":"","Customer_Name":null,"Customer_Type":null,"Date_of_Birth":null,"PAN_GIR_Number":null,"Passport_Number":null,"Voter_ID_Number":null,"Driving_License_Number":null,"Aadhaar_No":null},{"CIC_No":"CW3782547","Matched_Customer_Code":"CW3782547","Rule_Matching_Fields":"PAN","Current_Parameter_Value":"DMSPD9630N","Matched_Parameter_Value":"DMSPD9630N","Matched_Score":"100","Rule_Field_Weightage":"100","Matched_Source":"CFD","Active_Flag":"Y","Dedupe_Super_Match":"Y","Dedupe_Super_Match_Score":"100","Rule_Id":"PAN100","Type":"C","PEP_Remarks":"","Customer_Name":null,"Customer_Type":null,"Date_of_Birth":null,"PAN_GIR_Number":null,"Passport_Number":null,"Voter_ID_Number":null,"Driving_License_Number":null,"Aadhaar_No":null},{"CIC_No":"CW3782547","Matched_Customer_Code":"CW3782547","Rule_Matching_Fields":"VOTERID","Current_Parameter_Value":"CKK1913391","Matched_Parameter_Value":"CKK1913391","Matched_Score":"100","Rule_Field_Weightage":"100","Matched_Source":"CFD","Active_Flag":"Y","Dedupe_Super_Match":"Y","Dedupe_Super_Match_Score":"100","Rule_Id":"VOTERID100","Type":"C","PEP_Remarks":"","Customer_Name":null,"Customer_Type":null,"Date_of_Birth":null,"PAN_GIR_Number":null,"Passport_Number":null,"Voter_ID_Number":null,"Driving_License_Number":null,"Aadhaar_No":null},{"CIC_No":"CW4970396","Matched_Customer_Code":"CW4970396","Rule_Matching_Fields":"AADHAAR_NO","Current_Parameter_Value":"671940628725","Matched_Parameter_Value":"671940628725","Matched_Score":"100","Rule_Field_Weightage":"100","Matched_Source":"CFD","Active_Flag":"Y","Dedupe_Super_Match":"Y","Dedupe_Super_Match_Score":"100","Rule_Id":"ADHAR100","Type":"C","PEP_Remarks":"","Customer_Name":null,"Customer_Type":null,"Date_of_Birth":null,"PAN_GIR_Number":null,"Passport_Number":null,"Voter_ID_Number":null,"Driving_License_Number":null,"Aadhaar_No":null}],"CustomerValidate":[{"CustomerCodeVal":"CU0503174","CustomerMaster":[{"CIC_No":null,"Matched_Customer_Code":null,"Rule_Matching_Fields":null,"Current_Parameter_Value":null,"Matched_Parameter_Value":null,"Matched_Score":null,"Rule_Field_Weightage":null,"Matched_Source":null,"Active_Flag":null,"Dedupe_Super_Match":null,"Dedupe_Super_Match_Score":null,"Rule_Id":null,"Type":null,"PEP_Remarks":null,"Customer_Name":"S DEIVARAJ","Customer_Type":"10","Date_of_Birth":"27-06-1986 00:00:00","PAN_GIR_Number":"","Passport_Number":"","Voter_ID_Number":"CKK1913391","Driving_License_Number":"","Aadhaar_No":""}],"CustomerStatus":[{"Cross_Dedupe_Match_Id":"3095268","Active_Flag":"Z"}],"Dealstatus":[{"Deal_No":"TTU05950H","Status_Flag":"Z"}],"NPA":[],"Restructure":[{"Deal_Restructured":"Yes"}],"Gecl":[],"ARC":[],"PanAlert":[],"CINAlert":[],"BeneficiaryAlert":{"Ben_code":null,"Beneficiary":null,"Status_Flag":null,"PAN_No":null}},{"CustomerCodeVal":"CW3782547","CustomerMaster":[{"CIC_No":null,"Matched_Customer_Code":null,"Rule_Matching_Fields":null,"Current_Parameter_Value":null,"Matched_Parameter_Value":null,"Matched_Score":null,"Rule_Field_Weightage":null,"Matched_Source":null,"Active_Flag":null,"Dedupe_Super_Match":null,"Dedupe_Super_Match_Score":null,"Rule_Id":null,"Type":null,"PEP_Remarks":null,"Customer_Name":"DEIVARAJ","Customer_Type":"10","Date_of_Birth":"27-06-1984 00:00:00","PAN_GIR_Number":"DMSPD9630N","Passport_Number":"","Voter_ID_Number":"CKK1913391","Driving_License_Number":"","Aadhaar_No":"916901617335"}],"CustomerStatus":[{"Cross_Dedupe_Match_Id":"59675453","Active_Flag":"Y"}],"Dealstatus":[{"Deal_No":"TNU05150H","Status_Flag":"Z"},{"Deal_No":"TTU01390S","Status_Flag":"L"}],"NPA":[],"Restructure":[{"Deal_Restructured":"Yes"}],"Gecl":[],"ARC":[],"PanAlert":[],"CINAlert":[],"BeneficiaryAlert":{"Ben_code":null,"Beneficiary":null,"Status_Flag":null,"PAN_No":null}},{"CustomerCodeVal":"CW3782547","CustomerMaster":[{"CIC_No":null,"Matched_Customer_Code":null,"Rule_Matching_Fields":null,"Current_Parameter_Value":null,"Matched_Parameter_Value":null,"Matched_Score":null,"Rule_Field_Weightage":null,"Matched_Source":null,"Active_Flag":null,"Dedupe_Super_Match":null,"Dedupe_Super_Match_Score":null,"Rule_Id":null,"Type":null,"PEP_Remarks":null,"Customer_Name":"DEIVARAJ","Customer_Type":"10","Date_of_Birth":"27-06-1984 00:00:00","PAN_GIR_Number":"DMSPD9630N","Passport_Number":"","Voter_ID_Number":"CKK1913391","Driving_License_Number":"","Aadhaar_No":"916901617335"}],"CustomerStatus":[{"Cross_Dedupe_Match_Id":"59675453","Active_Flag":"Y"}],"Dealstatus":[{"Deal_No":"TNU05150H","Status_Flag":"Z"},{"Deal_No":"TTU01390S","Status_Flag":"L"}],"NPA":[],"Restructure":[{"Deal_Restructured":"Yes"}],"Gecl":[],"ARC":[],"PanAlert":[],"CINAlert":[],"BeneficiaryAlert":{"Ben_code":null,"Beneficiary":null,"Status_Flag":null,"PAN_No":null}},{"CustomerCodeVal":"CW4970396","CustomerMaster":[{"CIC_No":null,"Matched_Customer_Code":null,"Rule_Matching_Fields":null,"Current_Parameter_Value":null,"Matched_Parameter_Value":null,"Matched_Score":null,"Rule_Field_Weightage":null,"Matched_Source":null,"Active_Flag":null,"Dedupe_Super_Match":null,"Dedupe_Super_Match_Score":null,"Rule_Id":null,"Type":null,"PEP_Remarks":null,"Customer_Name":"NAGALAXMI","Customer_Type":"10","Date_of_Birth":"25-03-1981 00:00:00","PAN_GIR_Number":"COMPN4828K","Passport_Number":"","Voter_ID_Number":"","Driving_License_Number":"","Aadhaar_No":"671940628725"}],"CustomerStatus":[{"Cross_Dedupe_Match_Id":"70765909","Active_Flag":"Y"}],"Dealstatus":[],"NPA":[],"Restructure":[{"Deal_Restructured":"Yes"}],"Gecl":[],"ARC":[],"PanAlert":[],"CINAlert":[],"BeneficiaryAlert":{"Ben_code":null,"Beneficiary":null,"Status_Flag":null,"PAN_No":null}}]}]},"ErrorDesc":""}]}}';
            insert cdr4;
            
            Test.startTest();
            IND_LWC_StpChecksCntrl.stpChecks(opga1.Id);
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    
    @isTest
    public static void stpChecksTest24(){
        try{
            Opportunity opsc2 = new Opportunity();
            opsc2.StageName = 'Qualification';
            opsc2.CloseDate = Date.newInstance(2022, 1, 11);
            opsc2.Name = 'testone';
            opsc2.Vehicle_Type__c = 'Used';
            opsc2.Product_Type__c = 'Two Wheeler';
            opsc2.Product_Type__c = 'Passenger Vehicles';
            opsc2.Loan_amount__c = '6000000';
            opsc2.Vehicle_Sub_Category__c = 'UIM';
            opsc2.Vehicle_Details_Retry_Attempt__c=1;
            insert opsc2;
            Applicant__c apsc2 = new Applicant__c();
            apsc2.Opportunity__c = opsc2.Id;
            apsc2.Contact_number__c = '9743514830';
            apsc2.Applicant_Type__c = 'Borrower';
            insert apsc2;
            
            Customer_Code__c cust = new Customer_Code__c();
            cust.Name='newcust';
            cust.Loan_Application__c = opsc2.Id;
            insert cust;
            
            Exposure__c exp2 = new Exposure__c();
            exp2.Name = 'newexpo';
            exp2.Type__c = 'Borrower Exposure';
            exp2.Status_Flag__c = 'G';
            exp2.SOH__c = 100000;
            exp2.Loan_Application__c = opsc2.Id;
            insert exp2;
            
            Test.startTest();
            IND_LWC_StpChecksCntrl.stpChecks(opsc2.Id);
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void stpChecksTest25(){
        try{
            Opportunity opga1 = new Opportunity();
            opga1.StageName = 'Qualification';
            opga1.CloseDate = Date.newInstance(2021, 1, 11);
            opga1.Name = 'testone';
            opga1.Vehicle_Sub_Category__c = 'UIM';
            opga1.Vehicle_Type__c = 'Used';
            opga1.Product_Type__c = System.Label.used;
            opga1.Loan_amount__c = '600000';
            insert opga1;
            
            Applicant__c apga1 = new Applicant__c();
            apga1.Opportunity__c = opga1.Id;
            apga1.Contact_number__c = '9743514830';
            apga1.Applicant_Type__c = 'Borrower';
            insert apga1;
            
            Vehicle_Detail__c vgd2 = new Vehicle_Detail__c();
            vgd2.Loan_Application__c = opga1.Id;
            vgd2.Base_Price__c = 100;
            vgd2.Ben_Code__c = 'testveh';
            vgd2.Insurance_declared_value__c = 100;
            vgd2.Model__c = 'Two wheeler';
            vgd2.Ins_Expiry_date__c = Date.newInstance(2021, 2, 23);
            //  vgd2.Vehicle_type__c = System.Label.used;
            insert vgd2; 
            
            Final_Term__c ftd3 = new Final_Term__c();
            ftd3.CRM_IRR__c = 120;
            ftd3.Loan_Application__c = opga1.Id;
            ftd3.Holiday_period__c='30';
            ftd3.Loan_Amount__c = '1000000';
            ftd3.LtvEngine_Ltv__c = 1000;
            ftd3.Scheme_Bank_offers__c = 'test';
            ftd3.IsRequiredCRMIRRChanged__c=true;
            insert ftd3;
            
            Test.startTest();
            IND_LWC_StpChecksCntrl.stpChecks(opga1.Id);
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void stpChecksTest26(){
        try{
            Opportunity opga1 = new Opportunity();
            opga1.StageName = 'Qualification';
            opga1.CloseDate = Date.newInstance(2021, 1, 11);
            opga1.Name = 'testone';
            opga1.Vehicle_Sub_Category__c = 'UIM';
            opga1.Vehicle_Type__c = 'New';
            opga1.Product_Type__c = System.Label.new;
            opga1.Loan_amount__c = '600000';
            opga1.On_Road_price__c=400000;
            insert opga1;
            
            Applicant__c apga1 = new Applicant__c();
            apga1.Opportunity__c = opga1.Id;
            apga1.Contact_number__c = '9743514830';
            apga1.Applicant_Type__c = 'Borrower';
            insert apga1;
            
            Vehicle_Detail__c vgd2 = new Vehicle_Detail__c();
            vgd2.Loan_Application__c = opga1.Id;
            vgd2.Base_Price__c = 100;
            vgd2.Ben_Code__c = 'testveh';
            vgd2.Insurance_declared_value__c = 100;
            vgd2.Model__c = 'Two wheeler';
            vgd2.Ins_Expiry_date__c = Date.newInstance(2021, 2, 23);
            //  vgd2.Vehicle_type__c = System.Label.used;
            insert vgd2; 
            
            Final_Term__c ftd3 = new Final_Term__c();
            ftd3.CRM_IRR__c = 120;
            ftd3.Loan_Application__c = opga1.Id;
            ftd3.Holiday_period__c='30';
            ftd3.Loan_Amount__c = '1000000';
            ftd3.LtvEngine_Ltv__c = 1000;
            ftd3.Scheme_Bank_offers__c = 'test';
            ftd3.LtvEngine_Ltv__c = null;
            
            insert ftd3;
            
            Test.startTest();
            IND_LWC_StpChecksCntrl.stpChecks(opga1.Id);
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    @isTest
    public static void stpChecksTest27(){
        try{
            Opportunity opga1 = new Opportunity();
            opga1.StageName = 'Qualification';
            opga1.CloseDate = Date.newInstance(2021, 1, 11);
            opga1.Name = 'testone';
            opga1.Vehicle_Sub_Category__c = 'UIM';
            opga1.Vehicle_Type__c = 'Used';
            opga1.Product_Type__c = System.Label.used;
            opga1.Loan_amount__c = '6000000';
            opga1.Funded__c=true;
            
            insert opga1;
            
            Applicant__c apga1 = new Applicant__c();
            apga1.Opportunity__c = opga1.Id;
            apga1.Contact_number__c = '9743514830';
            apga1.Applicant_Type__c = 'Borrower';
            insert apga1;
            
            Vehicle_Detail__c vgd2 = new Vehicle_Detail__c();
            vgd2.Loan_Application__c = opga1.Id;
            vgd2.Base_Price__c = 100;
            vgd2.Ben_Code__c = 'testveh';
            vgd2.Insurance_declared_value__c = 1;
            vgd2.Model__c = 'Two wheeler';
            vgd2.Ins_Expiry_date__c = Date.newInstance(2021, 2, 23);
            //vgd2.OEM_Dealer__c='abc';
            vgd2.Insurance_declared_value__c=1;
            
            insert vgd2; 
            
            Final_Term__c ftd3 = new Final_Term__c();
            ftd3.CRM_IRR__c = 120;
            ftd3.Loan_Application__c = opga1.Id;
            ftd3.Holiday_period__c='30';
            ftd3.Loan_Amount__c = '100000';
            ftd3.LtvEngine_Ltv__c = 1000;
            ftd3.Scheme_Bank_offers__c = 'test';
            ftd3.OfferengineMinLoanAmount__c=10000;
            ftd3.OfferengineMaxLoanAmount__c=10000;
            ftd3.OfferengineMinTenure__c=10000;
            ftd3.OfferengineMaxTenure__c=10000;
            ftd3.Tenure__c='1000';
            
            
            
            insert ftd3;
            System.debug('loan amount='+ decimal.valueOf(opga1.Loan_amount__c));
            System.debug('insurance value ='+(vgd2.Insurance_declared_value__c/100)*140);
            Test.startTest();
            IND_LWC_StpChecksCntrl.stpChecks(opga1.Id);
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    
    
}