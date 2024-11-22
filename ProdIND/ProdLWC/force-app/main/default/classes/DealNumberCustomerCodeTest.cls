@isTest
public class DealNumberCustomerCodeTest {
    @isTest
    public static void dnField1IncrementTest(){
        try{
            
            Test.startTest();
            DealNumberCustomerCode.dnField1Increment('testttttttttttttt');
            DealNumberCustomerCode.dnField1Increment(null);
            DealNumberCustomerCode.dnField1Increment('ASBVCFGHNMKLOPOIUYNHGBVFTASCVFGTREWSADCVBNMJIKLOPMNBVGTFCDRESAZXDERFVBGTYHNMJUIKLOIUNHBGTRFDASER');
            Test.stopTest();
            
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void dealNumberGenerationTest(){
        try{
            Opportunity opga1 = new Opportunity();
            opga1.StageName = 'Qualification';
            opga1.CloseDate = Date.newInstance(2021, 1, 11);
            opga1.Name = 'testone';
            insert opga1;
            
          /*  Deal_Number__c dm1 = new Deal_Number__c();
            dm1.Loan_Application__c = opga1.Id;
            dm1.DNField3__c = '99999'; 
            insert dm1;*/
            Deal_Number_Setting__c dlNumberSetting= new Deal_Number_Setting__c();
            dlNumberSetting.Name = System.Label.TwoWheeler;
            dlNumberSetting.MDNField1__c ='AB';
            dlNumberSetting.MDNField2__c = 2.0;
            insert dlNumberSetting;
            
            Deal_Number__c dl=new Deal_Number__c();
            dl.Loan_Application__c = opga1.Id;
            dl.DNField1__c = dlNumberSetting.MDNField1__c;
            dl.DNField2__c = String.valueOf(dlNumberSetting.MDNField2__c.round());
            dl.Sub_Stage__c = 'Payment Request'; 
            insert dl;
            
            Test.startTest();
            DealNumberCustomerCode.dealNumberGeneration(opga1.Id,'');
            DealNumberCustomerCode.dealNumberGeneration('test','');
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void updateMetaDataTest(){
        try{
            Map<String, String> fieldMap = new Map<String, String>();
            fieldMap.put('MDNField2__c', '9');
            
            Test.startTest();
            DealNumberCustomerCode.updateMetaData(fieldMap);
            DealNumberCustomerCode.updateMetaData(null);
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    } 
    
    @isTest
    public static void getLoanApplicantDetailsTest(){
        try{
            Opportunity opga1 = new Opportunity();
            opga1.StageName = 'Qualification';
            opga1.CloseDate = Date.newInstance(2021, 1, 11);
            opga1.Name = 'testone';
            insert opga1;
            
            Applicant__c apga1 = new Applicant__c();
            apga1.Opportunity__c = opga1.Id;
            apga1.Contact_number__c = '9743514830';
            apga1.Applicant_Type__c = 'Borrower';
            apga1.In_Active_Applicant__c = false;
            insert apga1;
            
            Documents__c dt2 = new Documents__c();
            dt2.Applicant__c = apga1.Id;
            dt2.Opportunity_Relation__c = opga1.Id;
            dt2.Document_Type__c = 'Customer Bank Statement';
            dt2.Document_Side__c ='Back';
            dt2.Aadhar_Source__c = 'ScanAadhar';
            dt2.Proof_of_Address_POA__c = true;
            dt2.KYC_State__c = 'AP';
            insert dt2;
            
            Customer_Dedupe_Response__c cdr4 = new Customer_Dedupe_Response__c();
            cdr4.Applicant__c = apga1.Id;
            cdr4.CIC_No__c = '545667';
            cdr4.CIN_No__c = '34455';
            //   cdr2.Response__c = '{"response":{"status":"SUCCESS","respDesc":"IxsightEnquiry","content":[{"Data":{"ExternalDedupeResponse":{"DEDUPE_STATUS":"M","DtCFDCUSTBAS":[{"SOURCE_CIC_NO":"2022268275545880078","MATCH_ECIF":"3095268","MATCHED_CUSTOMER_NAME":"S DEIVARAJ","MATCHED_CUSTOMER_CODE":"CU0503174","MATCHED_SOURCE":"CFD","MATCHED_SCORE":"100","MATCHED_CRITERIA":"VOTERID100","CONFIDENCE_LEVEL":"1"}],"DtRECENTLEAD":[{"SOURCE_CIC_NO":"2022268275545880078","MATCHED_CIC_NO":"991102194599513090","MATCHED_LEAD_NAME":"DEIVARAJ S","MATCHED_LEAD_DATE":"12/15/2021 13:55:28","MATCHED_SCORE":"100","MATCHED_CRITERIA":"PAN100"}],"CustomerValidate":[{"CustomerCodeVal":"CU0503174","CustomerMaster":[{"Customer_Name":"S DEIVARAJ","Customer_Type":"10","Date_of_Birth":"27-06-1986 00:00:00","PAN_GIR_Number":"","Passport_Number":"","Voter_ID_Number":"CKK1913391","Driving_License_Number":"","Aadhaar_No":""}],"CustomerStatus":[{"Cross_Dedupe_Match_Id":"3095268","Active_Flag":"Z"}],"Dealstatus":[{"Deal_No":"TTU05950H","Status_Flag":"Z"}],"NPA":[],"Restructure":[{"Deal_Restructured":"No"}],"Gecl":[{"Deal_No":"TTU05950H","Status_Flag":"Z"}],"ARC":[],"PanAlert":[],"CINAlert":[],"BeneficiaryAlert":{"Ben_code":null,"Beneficiary":null,"Status_Flag":null,"PAN_No":null}}]},"InternalDedupeResponse":[{"CustomerMaster":[{"CIC_No":"CU0503174","Matched_Customer_Code":"CU0503174","Rule_Matching_Fields":"VOTERID","Current_Parameter_Value":"CKK1913391","Matched_Parameter_Value":"CKK1913391","Matched_Score":"100","Rule_Field_Weightage":"100","Matched_Source":"CFD","Active_Flag":"Z","Dedupe_Super_Match":"Y","Dedupe_Super_Match_Score":"100","Rule_Id":"VOTERID100","Type":"C","PEP_Remarks":"","Customer_Name":null,"Customer_Type":null,"Date_of_Birth":null,"PAN_GIR_Number":null,"Passport_Number":null,"Voter_ID_Number":null,"Driving_License_Number":null,"Aadhaar_No":null},{"CIC_No":"CW3782547","Matched_Customer_Code":"CW3782547","Rule_Matching_Fields":"PAN","Current_Parameter_Value":"DMSPD9630N","Matched_Parameter_Value":"DMSPD9630N","Matched_Score":"100","Rule_Field_Weightage":"100","Matched_Source":"CFD","Active_Flag":"Y","Dedupe_Super_Match":"Y","Dedupe_Super_Match_Score":"100","Rule_Id":"PAN100","Type":"C","PEP_Remarks":"","Customer_Name":null,"Customer_Type":null,"Date_of_Birth":null,"PAN_GIR_Number":null,"Passport_Number":null,"Voter_ID_Number":null,"Driving_License_Number":null,"Aadhaar_No":null},{"CIC_No":"CW3782547","Matched_Customer_Code":"CW3782547","Rule_Matching_Fields":"VOTERID","Current_Parameter_Value":"CKK1913391","Matched_Parameter_Value":"CKK1913391","Matched_Score":"100","Rule_Field_Weightage":"100","Matched_Source":"CFD","Active_Flag":"Y","Dedupe_Super_Match":"Y","Dedupe_Super_Match_Score":"100","Rule_Id":"VOTERID100","Type":"C","PEP_Remarks":"","Customer_Name":null,"Customer_Type":null,"Date_of_Birth":null,"PAN_GIR_Number":null,"Passport_Number":null,"Voter_ID_Number":null,"Driving_License_Number":null,"Aadhaar_No":null},{"CIC_No":"CW4970396","Matched_Customer_Code":"CW4970396","Rule_Matching_Fields":"AADHAAR_NO","Current_Parameter_Value":"671940628725","Matched_Parameter_Value":"671940628725","Matched_Score":"100","Rule_Field_Weightage":"100","Matched_Source":"CFD","Active_Flag":"Y","Dedupe_Super_Match":"Y","Dedupe_Super_Match_Score":"100","Rule_Id":"ADHAR100","Type":"C","PEP_Remarks":"","Customer_Name":null,"Customer_Type":null,"Date_of_Birth":null,"PAN_GIR_Number":null,"Passport_Number":null,"Voter_ID_Number":null,"Driving_License_Number":null,"Aadhaar_No":null}],"CustomerValidate":[{"CustomerCodeVal":"CU0503174","CustomerMaster":[{"CIC_No":null,"Matched_Customer_Code":null,"Rule_Matching_Fields":null,"Current_Parameter_Value":null,"Matched_Parameter_Value":null,"Matched_Score":null,"Rule_Field_Weightage":null,"Matched_Source":null,"Active_Flag":null,"Dedupe_Super_Match":null,"Dedupe_Super_Match_Score":null,"Rule_Id":null,"Type":null,"PEP_Remarks":null,"Customer_Name":"S DEIVARAJ","Customer_Type":"10","Date_of_Birth":"27-06-1986 00:00:00","PAN_GIR_Number":"","Passport_Number":"","Voter_ID_Number":"CKK1913391","Driving_License_Number":"","Aadhaar_No":""}],"CustomerStatus":[{"Cross_Dedupe_Match_Id":"3095268","Active_Flag":"Z"}],"Dealstatus":[{"Deal_No":"TTU05950H","Status_Flag":"Z"}],"NPA":[],"Restructure":[{"Deal_Restructured":"Yes"}],"Gecl":[],"ARC":[],"PanAlert":[],"CINAlert":[],"BeneficiaryAlert":{"Ben_code":null,"Beneficiary":null,"Status_Flag":null,"PAN_No":null}},{"CustomerCodeVal":"CW3782547","CustomerMaster":[{"CIC_No":null,"Matched_Customer_Code":null,"Rule_Matching_Fields":null,"Current_Parameter_Value":null,"Matched_Parameter_Value":null,"Matched_Score":null,"Rule_Field_Weightage":null,"Matched_Source":null,"Active_Flag":null,"Dedupe_Super_Match":null,"Dedupe_Super_Match_Score":null,"Rule_Id":null,"Type":null,"PEP_Remarks":null,"Customer_Name":"DEIVARAJ","Customer_Type":"10","Date_of_Birth":"27-06-1984 00:00:00","PAN_GIR_Number":"DMSPD9630N","Passport_Number":"","Voter_ID_Number":"CKK1913391","Driving_License_Number":"","Aadhaar_No":"916901617335"}],"CustomerStatus":[{"Cross_Dedupe_Match_Id":"59675453","Active_Flag":"Y"}],"Dealstatus":[{"Deal_No":"TNU05150H","Status_Flag":"Z"},{"Deal_No":"TTU01390S","Status_Flag":"L"}],"NPA":[],"Restructure":[{"Deal_Restructured":"Yes"}],"Gecl":[],"ARC":[],"PanAlert":[],"CINAlert":[],"BeneficiaryAlert":{"Ben_code":null,"Beneficiary":null,"Status_Flag":null,"PAN_No":null}},{"CustomerCodeVal":"CW3782547","CustomerMaster":[{"CIC_No":null,"Matched_Customer_Code":null,"Rule_Matching_Fields":null,"Current_Parameter_Value":null,"Matched_Parameter_Value":null,"Matched_Score":null,"Rule_Field_Weightage":null,"Matched_Source":null,"Active_Flag":null,"Dedupe_Super_Match":null,"Dedupe_Super_Match_Score":null,"Rule_Id":null,"Type":null,"PEP_Remarks":null,"Customer_Name":"DEIVARAJ","Customer_Type":"10","Date_of_Birth":"27-06-1984 00:00:00","PAN_GIR_Number":"DMSPD9630N","Passport_Number":"","Voter_ID_Number":"CKK1913391","Driving_License_Number":"","Aadhaar_No":"916901617335"}],"CustomerStatus":[{"Cross_Dedupe_Match_Id":"59675453","Active_Flag":"Y"}],"Dealstatus":[{"Deal_No":"TNU05150H","Status_Flag":"Z"},{"Deal_No":"TTU01390S","Status_Flag":"L"}],"NPA":[],"Restructure":[{"Deal_Restructured":"Yes"}],"Gecl":[],"ARC":[],"PanAlert":[],"CINAlert":[],"BeneficiaryAlert":{"Ben_code":null,"Beneficiary":null,"Status_Flag":null,"PAN_No":null}},{"CustomerCodeVal":"CW4970396","CustomerMaster":[{"CIC_No":null,"Matched_Customer_Code":null,"Rule_Matching_Fields":null,"Current_Parameter_Value":null,"Matched_Parameter_Value":null,"Matched_Score":null,"Rule_Field_Weightage":null,"Matched_Source":null,"Active_Flag":null,"Dedupe_Super_Match":null,"Dedupe_Super_Match_Score":null,"Rule_Id":null,"Type":null,"PEP_Remarks":null,"Customer_Name":"NAGALAXMI","Customer_Type":"10","Date_of_Birth":"25-03-1981 00:00:00","PAN_GIR_Number":"COMPN4828K","Passport_Number":"","Voter_ID_Number":"","Driving_License_Number":"","Aadhaar_No":"671940628725"}],"CustomerStatus":[{"Cross_Dedupe_Match_Id":"70765909","Active_Flag":"Y"}],"Dealstatus":[],"NPA":[],"Restructure":[{"Deal_Restructured":"Yes"}],"Gecl":[],"ARC":[],"PanAlert":[],"CINAlert":[],"BeneficiaryAlert":{"Ben_code":null,"Beneficiary":null,"Status_Flag":null,"PAN_No":null}}]}]},"ErrorDesc":""}]}}';
            insert cdr4;
            
            Test.startTest();
            DealNumberCustomerCode.getLoanApplicantDetails(opga1.Id);
            DealNumberCustomerCode.getLoanApplicantDetails('test');
            DealNumberCustomerCode.getLoanApplicantDetails(null);
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void updateApplicantCustomerCodeTest(){
        try{
            Opportunity opga1 = new Opportunity();
            opga1.StageName = 'Qualification';
            opga1.CloseDate = Date.newInstance(2021, 1, 11);
            opga1.Name = 'testone';
            insert opga1;
            
            Applicant__c apga1 = new Applicant__c();
            apga1.Opportunity__c = opga1.Id;
            apga1.Contact_number__c = '9743514830';
            apga1.Applicant_Type__c = 'Borrower';
            apga1.Customer_Code__c = 'CW3893704';
            apga1.Religion__c = '1';
            apga1.Caste__c = '2';
            insert apga1;
            
            Documents__c dt2 = new Documents__c();
            dt2.Applicant__c = apga1.Id;
            dt2.Opportunity_Relation__c = opga1.Id;
            dt2.Document_Type__c = 'Customer Bank Statement';
            dt2.Document_Side__c ='Back';
            dt2.Aadhar_Source__c = 'ScanAadhar';
            dt2.Proof_of_Address_POA__c = true;
            dt2.KYC_State__c = 'AP';
            dt2.KYC_District__c = 'SPSR NELLORE';
            insert dt2;
            
            Test.startTest();//CISP-4263
            DealNumberCustomerCode.updateApplicantCustomerCode(opga1.Id,apga1.Id,apga1.Customer_Code__c,apga1.Religion__c,apga1.Caste__c,dt2.KYC_District__c,dt2.Id,true,false);
            
            DealNumberCustomerCode.updateApplicantCustomerCode(null,null,null,null,null,null,null,null,null);
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void getDistrictOptionsTest(){
        try{
            Geo_State_Masters__c gm1 = new Geo_State_Masters__c();
            gm1.NeSL_State_Code__c = 'test';
            gm1.OwnerId = UserInfo.getUserId();
            gm1.Pincode_Starting_Max__c = 524;
            gm1.Pincode__c = 315;
            gm1.Name = 'allur';
            gm1.State_Code__c = '01';
            insert gm1;
            
            District_Master__c dm1 = new District_Master__c();
            dm1.Name = 'nellore';
            dm1.District_Code__c = 74;
            dm1.OwnerId = Userinfo.getUserId();
            dm1.Geo_State_Master__c = gm1.Id;
            insert dm1;
            
            Test.startTest();
            DealNumberCustomerCode.getDistrictOptions(gm1.Name);
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void UpdateDealCustomerTest(){
        try{
            Opportunity opga1 = new Opportunity();
            opga1.StageName = 'Post Sanction Checks and Documentation';
            opga1.CloseDate = Date.newInstance(2021, 1, 11);
            opga1.Name = 'testone';
            opga1.Vehicle_Type__c = 'Used';
            opga1.Product_Type__c = System.Label.TwoWheeler;
            opga1.Sanction_Status__c = 'Non-STP';
            insert opga1;
            
            Loan_Application_Transaction_History__c lth1 = new Loan_Application_Transaction_History__c();
            lth1.Loan_Application_ID__c = opga1.Id;
            lth1.Module_Name__c = 'FI';
            lth1.Assignment_status__c = 'Accepted';
            //    lth1.New_Owner__c = UserInfo.getUserId();
            //    lth1.RecordTypeId = Schema.SObjectType.Loan_Application_Transaction_History__c.getRecordTypeInfosByName().get('Lead Assignment').getRecordTypeId();
            insert lth1;
            
            Deal_Number_Setting__c dlNumberSetting= new Deal_Number_Setting__c();
            dlNumberSetting.Name = System.Label.TwoWheeler;
            dlNumberSetting.MDNField1__c ='AB';
            dlNumberSetting.MDNField2__c = 2.0;
            insert dlNumberSetting;
            
            Deal_Number__c dl=new Deal_Number__c();
            dl.Loan_Application__c = opga1.Id;
            dl.DNField1__c = dlNumberSetting.MDNField1__c;
            dl.DNField2__c = String.valueOf(dlNumberSetting.MDNField2__c.round());
            dl.Sub_Stage__c = 'Payment Request'; 
            insert dl;
            
            Test.startTest();
            DealNumberCustomerCode.UpdateDealCustomer(opga1.Id);
            DealNumberCustomerCode.UpdateDealCustomer('test');
            Test.stopTest();
            
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    
     @isTest
    public static void UpdateDealCustomerTest1(){
        try{
            Opportunity opga1 = new Opportunity();
            opga1.StageName = 'Post Sanction Checks and Documentation';
            opga1.CloseDate = Date.newInstance(2021, 1, 11);
            opga1.Name = 'testone';
            opga1.Vehicle_Type__c = 'Used';
            opga1.Product_Type__c = System.Label.Tractor;
            opga1.Sanction_Status__c = 'Non-STP';
            insert opga1;
            
            Loan_Application_Transaction_History__c lth1 = new Loan_Application_Transaction_History__c();
            lth1.Loan_Application_ID__c = opga1.Id;
            lth1.Module_Name__c = 'FI';
            lth1.Assignment_status__c = 'Accepted';
            //    lth1.New_Owner__c = UserInfo.getUserId();
            //    lth1.RecordTypeId = Schema.SObjectType.Loan_Application_Transaction_History__c.getRecordTypeInfosByName().get('Lead Assignment').getRecordTypeId();
            insert lth1;
            
            Deal_Number_Setting__c dlNumberSetting= new Deal_Number_Setting__c();
            dlNumberSetting.Name = System.Label.Tractor;
            dlNumberSetting.MDNField1__c ='AB';
            dlNumberSetting.MDNField2__c = 2.0;
            insert dlNumberSetting;
            
            Deal_Number__c dl=new Deal_Number__c();
            dl.Loan_Application__c = opga1.Id;
            dl.DNField1__c = dlNumberSetting.MDNField1__c;
            dl.DNField2__c = String.valueOf(dlNumberSetting.MDNField2__c.round());
            dl.Sub_Stage__c = 'Payment Request'; 
            insert dl;
            
            Test.startTest();
            DealNumberCustomerCode.UpdateDealCustomer(opga1.Id);
            DealNumberCustomerCode.UpdateDealCustomer('test');
            Test.stopTest();
            
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    @isTest
    public static void getLoanApplicationTransactionHistoryRecTest(){
        try{
            Opportunity opga1 = new Opportunity();
            opga1.StageName = 'Post Sanction Checks and Documentation';
            opga1.CloseDate = Date.newInstance(2021, 1, 11);
            opga1.Name = 'testone';
            opga1.Vehicle_Type__c = 'Used';
            opga1.Product_Type__c = 'Two Wheeler';
            opga1.Sanction_Status__c = 'Non-STP';
            insert opga1;
            
            Applicant__c apga1 = new Applicant__c();
            apga1.Opportunity__c = opga1.Id;
            apga1.Contact_number__c = '9743514830';
            apga1.Applicant_Type__c = 'Borrower';
            apga1.In_Active_Applicant__c = false;
            apga1.Who_will_repay_the_loan__c = 'Borrower';
            apga1.Scorecard_Decision__c = 'Orange';
            insert apga1;
            
            Webapp_Tab_Settings__mdt wt1 = new Webapp_Tab_Settings__mdt();
            wt1.Sub_Stage__c = 'RTO';
            
            Final_Term__c ft = new Final_Term__c();
            ft.Loan_Application__c = opga1.Id;
            ft.Loan_Amount__c='100000';
            ft.Installment_Type__c = 'Structured';
            insert ft;  
            
            Loan_Application_Transaction_History__c lth2 = new Loan_Application_Transaction_History__c();
            lth2.Module__c = wt1.Stage__c;
            lth2.Module_Name__c = wt1.Stage__c;
            lth2.Screen__c = wt1.Sub_Stage__c;
            lth2.Submitted_Flag__c = false;
            insert lth2;
            
            Deal_Number_Setting__c dlNumberSetting= new Deal_Number_Setting__c();
            dlNumberSetting.Name = System.Label.TwoWheeler;
            dlNumberSetting.MDNField1__c ='AB';
            dlNumberSetting.MDNField2__c = 2.0;
            insert dlNumberSetting;
            
            Deal_Number__c dl=new Deal_Number__c();
            dl.Loan_Application__c = opga1.Id;
            dl.DNField1__c = dlNumberSetting.MDNField1__c;
            dl.DNField2__c = String.valueOf(dlNumberSetting.MDNField2__c.round());
            dl.Sub_Stage__c = 'test'; 
            insert dl;
            
            Case cs = TestDataUtility.createTestCase(true,opga1,apga1);
            Vehicle_Detail__c vd = TestDataUtility.createTestVehicleDetail(true);
            Test.startTest();
            DealNumberCustomerCode.getLoanApplicationTransactionHistoryRec(opga1.Id,wt1,dl.Id,null,new List<Final_Term__c>{ft});
            DealNumberCustomerCode.getProductType(opga1.Id);
            DealNumberCustomerCode.getCoborrowerGrtDetails(apga1.Id);
            DealNumberCustomerCode.getAssetDetails(opga1.Id);
            DealNumberCustomerCode.getOppIdFromCase(cs.Id);
            DealNumberCustomerCode.getCRFlag(opga1.Id);
            DealNumberCustomerCode.updateCRFlag(opga1.Id);
            DealNumberCustomerCode.updateAssetDealNumber(vd.Id,dl.Id);
            Test.stopTest();
        }
        catch(Exception e){
            
        } 
    }
    
    @isTest
    public static void getLoanApplicationTransactionHistoryRecTest1(){
        Opportunity opga1 = new Opportunity();
        opga1.StageName = 'Post Sanction Checks and Documentation';
        opga1.CloseDate = Date.newInstance(2021, 1, 11);
        opga1.Name = 'testone';
        opga1.Vehicle_Type__c = 'Used';
        opga1.Product_Type__c = 'Two Wheeler';
        opga1.Sanction_Status__c = 'Non-STP';
        insert opga1;
        
        Webapp_Tab_Settings__mdt wt1 = new Webapp_Tab_Settings__mdt();
        wt1.Sub_Stage__c = 'Vehicle Inspection and RC Check';
        wt1.Vehicle_Category__c = 'New';
        
        Final_Term__c ft = new Final_Term__c();
        ft.Loan_Application__c = opga1.Id;
        ft.Loan_Amount__c='100000';
        ft.Installment_Type__c = 'Structured';
        insert ft;  
        
        Loan_Application_Transaction_History__c lth2 = new Loan_Application_Transaction_History__c();
        lth2.Module__c = wt1.Stage__c;
        lth2.Module_Name__c = wt1.Stage__c;
        lth2.Screen__c = wt1.Sub_Stage__c;
        lth2.Submitted_Flag__c = false;
        insert lth2;
        
        Deal_Number_Setting__c dlNumberSetting= new Deal_Number_Setting__c();
        dlNumberSetting.Name = System.Label.TwoWheeler;
        dlNumberSetting.MDNField1__c ='AB';
        dlNumberSetting.MDNField2__c = 2.0;
        insert dlNumberSetting;
        
        Deal_Number__c dl=new Deal_Number__c();
        dl.Loan_Application__c = opga1.Id;
        dl.DNField1__c = dlNumberSetting.MDNField1__c;
        dl.DNField2__c = String.valueOf(dlNumberSetting.MDNField2__c.round());
        dl.Sub_Stage__c = 'RC Upload'; 
        insert dl;
        
        Test.startTest();
        DealNumberCustomerCode.getLoanApplicationTransactionHistoryRec(opga1.Id,wt1,dl.Id,null,new List<Final_Term__c>{ft});
        DealNumberCustomerCode.dealNumberGeneration(opga1.Id,'');
        
        Test.stopTest();
        
    }
    
    @IsTest
    public static void getNomineeDetailsTest() {
        Opportunity testOpportunity = new Opportunity(Name='test', StageName='closed Won', CloseDate=Date.newInstance(2021, 1, 11), 
                                                      Product_Type__c = 'Passenger Vehicles', Sanction_Status__c = 'Non-STP',Vehicle_Type__c = 'Used');
        insert testOpportunity;
        
        Applicant__c testApplicant = new Applicant__c(Opportunity__c = testOpportunity.Id,Who_will_repay_the_loan__c = 'Borrower', In_Active_Applicant__c = false, Would_you_like_to_open_a_bank_account__c = true, Applicant_Type__c = 'Borrower');
        insert testApplicant;
        Id tvrRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('TVR').getRecordTypeId();
        Case casedata = new Case( Subject = 'test', RecordTypeId = tvrRecordTypeId, Loan_Application__c = testOpportunity.Id);
        insert casedata;
        Finacle_City__c	 finacledata= new Finacle_City__c ();
        finacledata.Name='test';
        finacledata.City_Code__c='131006';	
        insert finacledata;
        Geo_State_Masters__c geostateData = new Geo_State_Masters__c ();
        geostateData.Name='test_State';
        geostateData.State_Code__c='1310';
        geostateData.Pincode_Starting_Max__c =546; 
        geostateData.Pincode__c =546;
        insert geostateData;
        TeleVerification__c verificationdata = new TeleVerification__c(Case__c = casedata.Id,Finacle_City__c =finacledata.Id, Applicant__c = testApplicant.Id, Permanent_Address_Finacle_City__c=finacledata.Id,
                                                                       Office_Address_Finacle_City__c=finacledata.Id);
        insert verificationdata;
        
        CASA_Bank_Form__c testCasaBankForm = new CASA_Bank_Form__c(Applicant__c = testApplicant.Id, Loan_Application__c =testOpportunity.Id,Saving_Account_opened_for__c='Borrower',Nominee_name__c='Test',Nominee_address__c = 'Test Address', Nominee_available__c= true, Finacle_City__c = finacledata.Id, Nominee_DOB__c=Date.today(),Nominee_pin_code__c=546754,Geo_State_Master__c = geostateData.Id, Relationship_with_borrower__c='Brother');
        insert testCasaBankForm;
        Test.startTest();
        DealNumberCustomerCode.getNomineeDetails(testOpportunity.Id);
        test.stopTest();
    }
    @isTest
    public static void getNomineeDetailsTest1() {
        Opportunity testOpportunity = new Opportunity(Name='test', StageName='closed Won', CloseDate=Date.newInstance(2021, 1, 11), 
                                                      Product_Type__c = 'Passenger Vehicles', Sanction_Status__c = 'Non-STP',Vehicle_Type__c = 'Used');
        insert testOpportunity;
        Test.startTest();
        DealNumberCustomerCode.getNomineeDetails(testOpportunity.Id);
        DealNumberCustomerCode.getNomineeDetails(null);
        test.stopTest();
    }
    
    @IsTest
    public static void updateNomineeDetailsTest() {
        Opportunity testOpportunity = new Opportunity(Name='test', StageName='closed Won', CloseDate=Date.newInstance(2021, 1, 11), 
                                                      Product_Type__c = 'Passenger Vehicles', Sanction_Status__c = 'Non-STP',Vehicle_Type__c = 'Used');
        insert testOpportunity;
        
        Applicant__c testApplicant = new Applicant__c(Opportunity__c = testOpportunity.Id,Who_will_repay_the_loan__c = 'Borrower', In_Active_Applicant__c = false, Would_you_like_to_open_a_bank_account__c = true, Applicant_Type__c = 'Borrower');
        insert testApplicant;
        Id tvrRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('TVR').getRecordTypeId();
        Case casedata = new Case( Subject = 'test', RecordTypeId = tvrRecordTypeId, Loan_Application__c = testOpportunity.Id);
        insert casedata;
        Finacle_City__c	 finacledata= new Finacle_City__c ();
        finacledata.Name='test';
        finacledata.City_Code__c='131006';	
        insert finacledata;
        Geo_State_Masters__c geostateData = new Geo_State_Masters__c ();
        geostateData.Name='test_State';
        geostateData.State_Code__c='1310';
        geostateData.Pincode_Starting_Max__c =546; 
        geostateData.Pincode__c =546;
        insert geostateData;
        TeleVerification__c verificationdata = new TeleVerification__c(Case__c = casedata.Id, Applicant__c = testApplicant.Id);
        insert verificationdata;
        
        CASA_Bank_Form__c testCasaBankForm = new CASA_Bank_Form__c(Applicant__c = testApplicant.Id, Loan_Application__c =testOpportunity.Id);
        insert testCasaBankForm;
        
        DealNumberCustomerCode.NomineeWrapper wrapperObj = new DealNumberCustomerCode.NomineeWrapper();
        wrapperObj.applicantId = testApplicant.Id;
        wrapperObj.applicantType = 'Borrower';
        wrapperObj.tvrId = verificationdata.Id;
        wrapperObj.casabankId = null;
        wrapperObj.nomineeSAAccountOpenedFor = 'Borrower';
        wrapperObj.nomineeSAAccountOpening = '4642662';
        wrapperObj.nomineeAvailable = true;
        wrapperObj.nomineeName = 'Test';
        wrapperObj.nomineeAddress = 'Test Address';
        wrapperObj.nomineeDOB = Date.today();
        wrapperObj.nomineePinCode = '546754';
        wrapperObj.nomineeCity = finacledata.Name;
        wrapperObj.nomineeCityId = finacledata.Id;
        wrapperObj.nomineeState = geostateData.Name;
        wrapperObj.nomineeStateId = geostateData.Id;
        wrapperObj.nomineeRelationshipBorrower = 'Brother';
        wrapperObj.residenceCityFinacle = finacledata.Name;
        wrapperObj.residenceCityFinacleId = finacledata.Id;
        wrapperObj.permanentFinacle = finacledata.Name;
        wrapperObj.permanentFinacleId = finacledata.Id;
        wrapperObj.officeCityFinacle = finacledata.Name;
        wrapperObj.officeCityFinacleId = finacledata.Id;
        Test.startTest();
        DealNumberCustomerCode.updateNomineeDetails(testOpportunity.Id, wrapperObj);
        test.stopTest();
    }
    @isTest
    public static void updateReferenceAndRelationFieldOnOppTest(){
                 Opportunity opga1 = new Opportunity();
                opga1.StageName = 'Post Sanction Checks and Documentation';
                opga1.CloseDate = Date.newInstance(2021, 1, 11);
                opga1.Name = 'testone';
                opga1.Vehicle_Type__c = 'Used';
                opga1.Product_Type__c = 'Two Wheeler';
                opga1.Sanction_Status__c = 'Non-STP';
                insert opga1;
                Test.startTest();
                     DealNumberCustomerCode.updateReferenceAndRelationFieldOnOpp(opga1.Id);
                Test.stopTest();
             
    }
    @isTest
    public static void getOppIdFromCaseTest(){
        Opportunity opga1 = new Opportunity();
        opga1.StageName = 'Post Sanction Checks and Documentation';
        opga1.CloseDate = Date.newInstance(2021, 1, 11);
        opga1.Name = 'testone';
        opga1.Vehicle_Type__c = 'Used';
        opga1.Product_Type__c = 'Two Wheeler';
        opga1.Sanction_Status__c = 'Non-STP';
        insert opga1;
        Applicant__c apga1 = new Applicant__c();
        apga1.Opportunity__c = opga1.Id;
        apga1.Contact_number__c = '9743514830';
        apga1.Applicant_Type__c = 'Borrower';
        apga1.In_Active_Applicant__c = false;
        apga1.Who_will_repay_the_loan__c = 'Borrower';
        apga1.Scorecard_Decision__c = 'Orange';
       	apga1.Saved_Customer_Relation__c = true;
        insert apga1;
        Vehicle_Detail__c vhObj = new Vehicle_Detail__c();
        vhObj.Loan_Application__c = opga1.Id;
        vhObj.Approval_Status__c = 'Approved';
        insert vhObj;
        Deal_Number_Setting__c dlNumberSetting= new Deal_Number_Setting__c();
            dlNumberSetting.Name = System.Label.TwoWheeler;
            dlNumberSetting.MDNField1__c ='AB';
            dlNumberSetting.MDNField2__c = 2.0;
            insert dlNumberSetting;
            
            
            Deal_Number__c dl=new Deal_Number__c();
            dl.Loan_Application__c = opga1.Id;
            dl.DNField1__c = dlNumberSetting.MDNField1__c;
            dl.DNField2__c = String.valueOf(dlNumberSetting.MDNField2__c.round());
            
            insert dl;
        Deal_Number__c d1 = [SELECT ID, Deal_Number__c from Deal_Number__c where Id =:dl.ID];
        System.debug('d1--' + d1);
        Case cs = TestDataUtility.createTestCase(true,opga1,apga1);
        Test.startTest();
        DealNumberCustomerCode.getOppIdFromCase(cs.Id);
        DealNumberCustomerCode.getProductType(opga1.Id);
        DealNumberCustomerCode.getCoborrowerGrtDetails(opga1.Id);
        DealNumberCustomerCode.getAssetDetails(opga1.Id);
       	DealNumberCustomerCode.getCRFlag(opga1.Id);
       DealNumberCustomerCode.updateCRFlag(opga1.Id);
        DealNumberCustomerCode.updateAssetDealNumber(vhObj.Id,d1.Deal_Number__c);
        Test.stopTest();
        
    }
}