/**
* @author Sanketkumar
* @company Persistent Systems
* @description A  Test class for the  Customer Dedupe functionality class
* Inputs: None
* History:
*/
@isTest
public class Ind_CustomerDedupCtrlTest {
    
    @testSetup 
    static void testDataSetup() 
    {
        //create user
        Profile p = [SELECT Id FROM Profile WHERE Name='IBL Business Executive'];
        User u = new User(Alias = 'standt2', Email='standarduser2@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,Maker_Id__c='12',IsActive = true,
                          TimeZoneSidKey='America/Los_Angeles',UserName='test_userprod123@indusbank.com.uat',
                          MobilePhone='8234567890');
        insert u;
        Profile p1 = [SELECT Id FROM Profile WHERE Name='CMU'];
         User u1 = new User(Alias = 'standt2', Email='standarduser12@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p1.Id,Maker_Id__c='12',IsActive = true,
                          TimeZoneSidKey='America/Los_Angeles',UserName='test_userprod1123@indusbank.com.uat',
                          MobilePhone='8234567890');
        insert u1;
        System.runAs(u1) 
        {
            
            Account acc = new Account();
            acc.Name = 'test account';
            acc.State__c = 'MAHARASHTRA';
            acc.Phone = '+914335225';
            insert acc;
            
            List<Opportunity> oppList = new List<Opportunity>();
            Opportunity opp = TestDataUtility.createTestOpportunityForOcr(false); 
            opp.Sub_Stage__c = System.Label.Field_Investigation;
            opp.Is_Mobile_Journey_Completed__c = true;
            opp.Vehicle_Type__c = System.Label.used;
            opp.Product_Type__c = System.Label.PassengerVehicles;
            opp.Sanction_Status__c = System.Label.nonStp;  
            opp.Agent_BL_code__c = 'AHZ';
            opp.Deal_Number__c = null; 
            opp.AccountId = acc.Id;
            opp.Required_ROI__c = 9;
            opp.EMI_Amount__c = 10000;  
            opp.Agreement_Amount__c = 450000;
            opp.Documentation_Charges__c = '2000';
            opp.Applicant_Name__c = 'test';
            oppList.add(opp);  
            
            insert oppList;
            
            List<Applicant__c> applicantList = new List<Applicant__c>();
            Applicant__c applicant1 = TestDataUtility.createTestApplicatnt1(false);
            applicant1.Name = 'testapplicant1';
            applicant1.Father_s_name__c = 'fsfdsf';
            applicant1.Opportunity__c = oppList[0].Id;
            applicant1.Who_will_repay_the_loan__c = 'Borrower';
            applicant1.Scorecard_Decision__c = 'Light Red';
            applicant1.Contact_Number__c = '+9123456789';
            applicant1.Applicant_Type__c = 'Borrower';
            applicant1.Email_Id_2__c = 'test2@abc.com';
            applicant1.Email_Id_1__c = 'test1@abc.com';
            applicant1.Email_Id__c = 'test@abc.com';
            applicantList.add(applicant1);
            
            Applicant__c applicant2 = TestDataUtility.createTestApplicatnt1(false);
            applicant2.Name = 'testapplicant1';
            applicant2.Father_s_name__c = 'fsfdsf';
            applicant2.Opportunity__c = oppList[0].Id;
            applicant2.Scorecard_Decision__c = 'Light Red';
            applicant2.Contact_Number__c = '+9123456789';
            applicant2.Applicant_Type__c = System.Label.CoBorrower;
            applicant2.Email_Id_2__c = 'test2@abc.com';
            applicant2.Email_Id_1__c = 'test1@abc.com';
            applicant2.Email_Id__c = 'test@abc.com';
            applicantList.add(applicant2);
            
            INSERT applicantList;     
            
            Customer_Dedupe_Response__c customerDedupe1 = new Customer_Dedupe_Response__c();
            customerDedupe1.Applicant__c = applicantList[0].Id;
            insert customerDedupe1;
        }
    }
    @isTest
    public static void validateCustomerCodeTest(){
        
        try{
            Opportunity opvc1 = new Opportunity();
            opvc1.StageName = 'Qualification';
            opvc1.CloseDate = Date.newInstance(2021, 1, 11);
            opvc1.Name = 'testone';
            opvc1.Product_Type__c = 'Tractor';
            insert opvc1;
            
            
            
            Applicant__c apvc1 = new Applicant__c();
            apvc1.Opportunity__c = opvc1.Id;
            apvc1.Contact_number__c = '9743514830';
            apvc1.Applicant_Type__c = 'Borrower';
            insert apvc1;
            
            
            Ind_CustomerDedupCtrl.CustomerDetailsParser cdp1 = new Ind_CustomerDedupCtrl.CustomerDetailsParser();
            cdp1.Aadhaar_No = '987623415643';
            cdp1.CustomerCodeVal = 'CU0503174';
            cdp1.Customer_Name = 'test';
            cdp1.Customer_Type = 'tetstype';
            cdp1.Date_of_Birth = '23061994';
            cdp1.Driving_License_Number = '324556644';
            cdp1.PAN_GIR_Number = 'BSDRT7629K';
            cdp1.Passport_Number = '34567';
            cdp1.Voter_ID_Number = '567388336';
            cdp1.Rule_Matching_Fields = '567388336';
            cdp1.Matched_Score = '567388336';
            cdp1.Matched_Source = 'PAN';
            cdp1.Matched_Parameter_Value = '100';
            
            
            Ind_CustomerDedupCtrl.ReturnMessageWrapper returnMsgWrapper = new Ind_CustomerDedupCtrl.ReturnMessageWrapper();
            returnMsgWrapper.isSuccess = true;
            returnMsgWrapper.message = 'Success';
            returnMsgWrapper.cloneLoanApplicationId = 'test';
            returnMsgWrapper.cloneBorrowerApplicantId = 'tetstype';
            returnMsgWrapper.cloneCoBorrowerApplicantId = '23061994';
            
            //  cdp1.parse(Json.serialize(cdp1));
            Customer_Dedupe_Response__c cdr1 = new Customer_Dedupe_Response__c();
            cdr1.Applicant__c = apvc1.Id;
            cdr1.CIC_No__c = '545667';
            cdr1.CIN_No__c = '34455';
            cdr1.Response__c = '{"response":{"status":"SUCCESS","respDesc":"IxsightEnquiry","content":[{"Data":{"ExternalDedupeResponse":{"DEDUPE_STATUS":"M","DtCFDCUSTBAS":[{"SOURCE_CIC_NO":"2022268275545880078","MATCH_ECIF":"3095268","MATCHED_CUSTOMER_NAME":"S DEIVARAJ","MATCHED_CUSTOMER_CODE":"CU0503174","MATCHED_SOURCE":"CFD","MATCHED_SCORE":"100","MATCHED_CRITERIA":"VOTERID100","CONFIDENCE_LEVEL":"1"}],"DtRECENTLEAD":[{"SOURCE_CIC_NO":"2022268275545880078","MATCHED_CIC_NO":"991102194599513090","MATCHED_LEAD_NAME":"DEIVARAJ S","MATCHED_LEAD_DATE":"12/15/2021 13:55:28","MATCHED_SCORE":"100","MATCHED_CRITERIA":"PAN100"}],"CustomerValidate":[{"CustomerCodeVal":"CU0503174","CustomerMaster":[{"Customer_Name":"S DEIVARAJ","Customer_Type":"10","Date_of_Birth":"27-06-1986 00:00:00","PAN_GIR_Number":"","Passport_Number":"","Voter_ID_Number":"CKK1913391","Driving_License_Number":"","Aadhaar_No":""}],"CustomerStatus":[{"Cross_Dedupe_Match_Id":"3095268","Active_Flag":"F"}],"Dealstatus":[{"Deal_No":"TTU05950H","Status_Flag":"Z"}],"NPA":[],"Restructure":[{"Deal_Restructured":"No"}],"Gecl":[{"Deal_No":"TTU05950H","Status_Flag":"Z"}],"ARC":[],"PanAlert":[],"CINAlert":[],"BeneficiaryAlert":{"Ben_code":null,"Beneficiary":null,"Status_Flag":null,"PAN_No":null}}]},"InternalDedupeResponse":[{"CustomerMaster":[{"CIC_No":"CU0503174","Matched_Customer_Code":"CU0503174","Rule_Matching_Fields":"VOTERID","Current_Parameter_Value":"CKK1913391","Matched_Parameter_Value":"CKK1913391","Matched_Score":"100","Rule_Field_Weightage":"100","Matched_Source":"CFD","Active_Flag":"Z","Dedupe_Super_Match":"Y","Dedupe_Super_Match_Score":"100","Rule_Id":"VOTERID100","Type":"C","PEP_Remarks":"","Customer_Name":null,"Customer_Type":null,"Date_of_Birth":null,"PAN_GIR_Number":null,"Passport_Number":null,"Voter_ID_Number":null,"Driving_License_Number":null,"Aadhaar_No":null},{"CIC_No":"CW3782547","Matched_Customer_Code":"CW3782547","Rule_Matching_Fields":"PAN","Current_Parameter_Value":"DMSPD9630N","Matched_Parameter_Value":"DMSPD9630N","Matched_Score":"100","Rule_Field_Weightage":"100","Matched_Source":"CFD","Active_Flag":"Y","Dedupe_Super_Match":"Y","Dedupe_Super_Match_Score":"100","Rule_Id":"PAN100","Type":"C","PEP_Remarks":"","Customer_Name":null,"Customer_Type":null,"Date_of_Birth":null,"PAN_GIR_Number":null,"Passport_Number":null,"Voter_ID_Number":null,"Driving_License_Number":null,"Aadhaar_No":null},{"CIC_No":"CW3782547","Matched_Customer_Code":"CW3782547","Rule_Matching_Fields":"VOTERID","Current_Parameter_Value":"CKK1913391","Matched_Parameter_Value":"CKK1913391","Matched_Score":"100","Rule_Field_Weightage":"100","Matched_Source":"CFD","Active_Flag":"Y","Dedupe_Super_Match":"Y","Dedupe_Super_Match_Score":"100","Rule_Id":"VOTERID100","Type":"C","PEP_Remarks":"","Customer_Name":null,"Customer_Type":null,"Date_of_Birth":null,"PAN_GIR_Number":null,"Passport_Number":null,"Voter_ID_Number":null,"Driving_License_Number":null,"Aadhaar_No":null},{"CIC_No":"CW4970396","Matched_Customer_Code":"CW4970396","Rule_Matching_Fields":"AADHAAR_NO","Current_Parameter_Value":"671940628725","Matched_Parameter_Value":"671940628725","Matched_Score":"100","Rule_Field_Weightage":"100","Matched_Source":"CFD","Active_Flag":"Y","Dedupe_Super_Match":"Y","Dedupe_Super_Match_Score":"100","Rule_Id":"ADHAR100","Type":"C","PEP_Remarks":"","Customer_Name":null,"Customer_Type":null,"Date_of_Birth":null,"PAN_GIR_Number":null,"Passport_Number":null,"Voter_ID_Number":null,"Driving_License_Number":null,"Aadhaar_No":null}],"CustomerValidate":[{"CustomerCodeVal":"CU0503174","CustomerMaster":[{"CIC_No":null,"Matched_Customer_Code":null,"Rule_Matching_Fields":null,"Current_Parameter_Value":null,"Matched_Parameter_Value":null,"Matched_Score":null,"Rule_Field_Weightage":null,"Matched_Source":null,"Active_Flag":null,"Dedupe_Super_Match":null,"Dedupe_Super_Match_Score":null,"Rule_Id":null,"Type":null,"PEP_Remarks":null,"Customer_Name":"S DEIVARAJ","Customer_Type":"10","Date_of_Birth":"27-06-1986 00:00:00","PAN_GIR_Number":"","Passport_Number":"","Voter_ID_Number":"CKK1913391","Driving_License_Number":"","Aadhaar_No":""}],"CustomerStatus":[{"Cross_Dedupe_Match_Id":"3095268","Active_Flag":"Z"}],"Dealstatus":[{"Deal_No":"TTU05950H","Status_Flag":"Z"}],"NPA":[],"Restructure":[{"Deal_Restructured":"Yes"}],"Gecl":[],"ARC":[],"PanAlert":[],"CINAlert":[],"BeneficiaryAlert":{"Ben_code":null,"Beneficiary":null,"Status_Flag":null,"PAN_No":null}},{"CustomerCodeVal":"CW3782547","CustomerMaster":[{"CIC_No":null,"Matched_Customer_Code":null,"Rule_Matching_Fields":null,"Current_Parameter_Value":null,"Matched_Parameter_Value":null,"Matched_Score":null,"Rule_Field_Weightage":null,"Matched_Source":null,"Active_Flag":null,"Dedupe_Super_Match":null,"Dedupe_Super_Match_Score":null,"Rule_Id":null,"Type":null,"PEP_Remarks":null,"Customer_Name":"DEIVARAJ","Customer_Type":"10","Date_of_Birth":"27-06-1984 00:00:00","PAN_GIR_Number":"DMSPD9630N","Passport_Number":"","Voter_ID_Number":"CKK1913391","Driving_License_Number":"","Aadhaar_No":"916901617335"}],"CustomerStatus":[{"Cross_Dedupe_Match_Id":"59675453","Active_Flag":"Y"}],"Dealstatus":[{"Deal_No":"TNU05150H","Status_Flag":"Z"},{"Deal_No":"TTU01390S","Status_Flag":"L"}],"NPA":[],"Restructure":[{"Deal_Restructured":"Yes"}],"Gecl":[],"ARC":[],"PanAlert":[],"CINAlert":[],"BeneficiaryAlert":{"Ben_code":null,"Beneficiary":null,"Status_Flag":null,"PAN_No":null}},{"CustomerCodeVal":"CW3782547","CustomerMaster":[{"CIC_No":null,"Matched_Customer_Code":null,"Rule_Matching_Fields":null,"Current_Parameter_Value":null,"Matched_Parameter_Value":null,"Matched_Score":null,"Rule_Field_Weightage":null,"Matched_Source":null,"Active_Flag":null,"Dedupe_Super_Match":null,"Dedupe_Super_Match_Score":null,"Rule_Id":null,"Type":null,"PEP_Remarks":null,"Customer_Name":"DEIVARAJ","Customer_Type":"10","Date_of_Birth":"27-06-1984 00:00:00","PAN_GIR_Number":"DMSPD9630N","Passport_Number":"","Voter_ID_Number":"CKK1913391","Driving_License_Number":"","Aadhaar_No":"916901617335"}],"CustomerStatus":[{"Cross_Dedupe_Match_Id":"59675453","Active_Flag":"Y"}],"Dealstatus":[{"Deal_No":"TNU05150H","Status_Flag":"Z"},{"Deal_No":"TTU01390S","Status_Flag":"L"}],"NPA":[],"Restructure":[{"Deal_Restructured":"Yes"}],"Gecl":[],"ARC":[],"PanAlert":[],"CINAlert":[],"BeneficiaryAlert":{"Ben_code":null,"Beneficiary":null,"Status_Flag":null,"PAN_No":null}},{"CustomerCodeVal":"CW4970396","CustomerMaster":[{"CIC_No":null,"Matched_Customer_Code":null,"Rule_Matching_Fields":null,"Current_Parameter_Value":null,"Matched_Parameter_Value":null,"Matched_Score":null,"Rule_Field_Weightage":null,"Matched_Source":null,"Active_Flag":null,"Dedupe_Super_Match":null,"Dedupe_Super_Match_Score":null,"Rule_Id":null,"Type":null,"PEP_Remarks":null,"Customer_Name":"NAGALAXMI","Customer_Type":"10","Date_of_Birth":"25-03-1981 00:00:00","PAN_GIR_Number":"COMPN4828K","Passport_Number":"","Voter_ID_Number":"","Driving_License_Number":"","Aadhaar_No":"671940628725"}],"CustomerStatus":[{"Cross_Dedupe_Match_Id":"70765909","Active_Flag":"Y"}],"Dealstatus":[],"NPA":[],"Restructure":[{"Deal_Restructured":"Yes"}],"Gecl":[],"ARC":[],"PanAlert":[],"CINAlert":[],"BeneficiaryAlert":{"Ben_code":null,"Beneficiary":null,"Status_Flag":null,"PAN_No":null}}]}]},"ErrorDesc":""}]}}';
            insert cdr1;
            
            
            
            //cdp1.parse(Json.serialize(cdp1));
            ///   String sSelectedCustCode = cdp1.CustomerCodeVal;
            
            Set<String> ciSet = new Set<String>();
            ciSet.add('test');
            
            
            
            
            
            Ind_CustomerDedupCtrl.DedupeResponseWrapper drw1 = new Ind_CustomerDedupCtrl.DedupeResponseWrapper();
            drw1.SFCustomerDedupeFlag = 2.0;
            drw1.PGCustomerDedupeFlag = 3.0;
            drw1.externalDedupeAPIMaxAttempts = 5;
            //    drw1.cicNoSet = ciSet;
            drw1.isValid = true;
       //   drw1.isJourneySkipped = true;
     //     drw1.journeySkipReason = 'testone';
       //   drw1.journeyStopReason = 'testsolve';
            drw1.customerDedupeResponseObjId = 'testcust';
            drw1.message = 'tetsmsg';
            drw1.applicantType = 'testapp';
            drw1.leadNumber = 'tets123';
            drw1.customerName = 'testcust';
            drw1.customerCode = 'test123';
            drw1.invalidCustomerCode = 'testinvalid';
            drw1.response = 'testresponse';
            
            
            
            Test.startTest();
            Ind_CustomerDedupCtrl.validateCustomerCode(apvc1.Id,opvc1.Id, JSON.serialize(cdp1),'Co-borrower');
            Test.stopTest();
             User u1 = [SELECT Id,Email FROM user WHERE Email='standarduser12@testorg.com'];
            System.runAs(u1){
                Ind_CustomerDedupCtrl.validateCustomerCode(apvc1.Id,opvc1.Id, JSON.serialize(cdp1),'Co-borrower');
            }
            
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }

	@isTest
    public static void validateCustomerCodeTest1(){
        
        try{
            Opportunity opvc1 = new Opportunity();
            opvc1.StageName = 'Qualification';
            opvc1.CloseDate = Date.newInstance(2021, 1, 11);
            opvc1.Name = 'testone';
            insert opvc1;
            
            
            
            Applicant__c apvc1 = new Applicant__c();
            apvc1.Opportunity__c = opvc1.Id;
            apvc1.Contact_number__c = '9743514830';
            apvc1.Applicant_Type__c = 'Borrower';
            insert apvc1;
            
            
            Ind_CustomerDedupCtrl.CustomerDetailsParser cdp1 = new Ind_CustomerDedupCtrl.CustomerDetailsParser();
            cdp1.Aadhaar_No = '987623415643';
            cdp1.CustomerCodeVal = 'CU0503174';
            cdp1.Customer_Name = 'test';
            cdp1.Customer_Type = 'tetstype';
            cdp1.Date_of_Birth = '23061994';
            cdp1.Driving_License_Number = '324556644';
            cdp1.PAN_GIR_Number = 'BSDRT7629K';
            cdp1.Passport_Number = '34567';
            cdp1.Voter_ID_Number = '567388336';
            cdp1.Rule_Matching_Fields = '567388336';
            cdp1.Matched_Score = '567388336';
            cdp1.Matched_Source = 'PAN';
            cdp1.Matched_Parameter_Value = '100';
            
            
            Ind_CustomerDedupCtrl.ReturnMessageWrapper returnMsgWrapper = new Ind_CustomerDedupCtrl.ReturnMessageWrapper();
            returnMsgWrapper.isSuccess = true;
            returnMsgWrapper.message = 'Success';
            returnMsgWrapper.cloneLoanApplicationId = 'test';
            returnMsgWrapper.cloneBorrowerApplicantId = 'tetstype';
            returnMsgWrapper.cloneCoBorrowerApplicantId = '23061994';
            
            //  cdp1.parse(Json.serialize(cdp1));
            Customer_Dedupe_Response__c cdr1 = new Customer_Dedupe_Response__c();
            cdr1.Applicant__c = apvc1.Id;
            cdr1.CIC_No__c = '545667';
            cdr1.CIN_No__c = '34455';
            cdr1.Response__c = '{"response":{"status":"SUCCESS","respDesc":"IxsightEnquiry","content":[{"Data":{"ExternalDedupeResponse":{"DEDUPE_STATUS":"M","DtCFDCUSTBAS":[{"SOURCE_CIC_NO":"2022268275545880078","MATCH_ECIF":"3095268","MATCHED_CUSTOMER_NAME":"S DEIVARAJ","MATCHED_CUSTOMER_CODE":"CU0503174","MATCHED_SOURCE":"CFD","MATCHED_SCORE":"100","MATCHED_CRITERIA":"VOTERID100","CONFIDENCE_LEVEL":"1"}],"DtRECENTLEAD":[{"SOURCE_CIC_NO":"2022268275545880078","MATCHED_CIC_NO":"991102194599513090","MATCHED_LEAD_NAME":"DEIVARAJ S","MATCHED_LEAD_DATE":"12/15/2021 13:55:28","MATCHED_SCORE":"100","MATCHED_CRITERIA":"PAN100"}],"CustomerValidate":[{"CustomerCodeVal":"CU0503174","CustomerMaster":[{"Customer_Name":"S DEIVARAJ","Customer_Type":"10","Date_of_Birth":"27-06-1986 00:00:00","PAN_GIR_Number":"","Passport_Number":"","Voter_ID_Number":"CKK1913391","Driving_License_Number":"","Aadhaar_No":""}],"CustomerStatus":[{"Cross_Dedupe_Match_Id":"3095268","Active_Flag":"Z"}],"Dealstatus":[{"Deal_No":"TTU05950H","Status_Flag":"R"}],"NPA":[],"Restructure":[{"Deal_Restructured":"No"}],"Gecl":[{"Deal_No":"TTU05950H","Status_Flag":"Z"}],"ARC":[],"PanAlert":[],"CINAlert":[],"BeneficiaryAlert":{"Ben_code":null,"Beneficiary":null,"Status_Flag":null,"PAN_No":null}}]},"InternalDedupeResponse":[{"CustomerMaster":[{"CIC_No":"CU0503174","Matched_Customer_Code":"CU0503174","Rule_Matching_Fields":"VOTERID","Current_Parameter_Value":"CKK1913391","Matched_Parameter_Value":"CKK1913391","Matched_Score":"100","Rule_Field_Weightage":"100","Matched_Source":"CFD","Active_Flag":"Z","Dedupe_Super_Match":"Y","Dedupe_Super_Match_Score":"100","Rule_Id":"VOTERID100","Type":"C","PEP_Remarks":"","Customer_Name":null,"Customer_Type":null,"Date_of_Birth":null,"PAN_GIR_Number":null,"Passport_Number":null,"Voter_ID_Number":null,"Driving_License_Number":null,"Aadhaar_No":null},{"CIC_No":"CW3782547","Matched_Customer_Code":"CW3782547","Rule_Matching_Fields":"PAN","Current_Parameter_Value":"DMSPD9630N","Matched_Parameter_Value":"DMSPD9630N","Matched_Score":"100","Rule_Field_Weightage":"100","Matched_Source":"CFD","Active_Flag":"Y","Dedupe_Super_Match":"Y","Dedupe_Super_Match_Score":"100","Rule_Id":"PAN100","Type":"C","PEP_Remarks":"","Customer_Name":null,"Customer_Type":null,"Date_of_Birth":null,"PAN_GIR_Number":null,"Passport_Number":null,"Voter_ID_Number":null,"Driving_License_Number":null,"Aadhaar_No":null},{"CIC_No":"CW3782547","Matched_Customer_Code":"CW3782547","Rule_Matching_Fields":"VOTERID","Current_Parameter_Value":"CKK1913391","Matched_Parameter_Value":"CKK1913391","Matched_Score":"100","Rule_Field_Weightage":"100","Matched_Source":"CFD","Active_Flag":"Y","Dedupe_Super_Match":"Y","Dedupe_Super_Match_Score":"100","Rule_Id":"VOTERID100","Type":"C","PEP_Remarks":"","Customer_Name":null,"Customer_Type":null,"Date_of_Birth":null,"PAN_GIR_Number":null,"Passport_Number":null,"Voter_ID_Number":null,"Driving_License_Number":null,"Aadhaar_No":null},{"CIC_No":"CW4970396","Matched_Customer_Code":"CW4970396","Rule_Matching_Fields":"AADHAAR_NO","Current_Parameter_Value":"671940628725","Matched_Parameter_Value":"671940628725","Matched_Score":"100","Rule_Field_Weightage":"100","Matched_Source":"CFD","Active_Flag":"Y","Dedupe_Super_Match":"Y","Dedupe_Super_Match_Score":"100","Rule_Id":"ADHAR100","Type":"C","PEP_Remarks":"","Customer_Name":null,"Customer_Type":null,"Date_of_Birth":null,"PAN_GIR_Number":null,"Passport_Number":null,"Voter_ID_Number":null,"Driving_License_Number":null,"Aadhaar_No":null}],"CustomerValidate":[{"CustomerCodeVal":"CU0503174","CustomerMaster":[{"CIC_No":null,"Matched_Customer_Code":null,"Rule_Matching_Fields":null,"Current_Parameter_Value":null,"Matched_Parameter_Value":null,"Matched_Score":null,"Rule_Field_Weightage":null,"Matched_Source":null,"Active_Flag":null,"Dedupe_Super_Match":null,"Dedupe_Super_Match_Score":null,"Rule_Id":null,"Type":null,"PEP_Remarks":null,"Customer_Name":"S DEIVARAJ","Customer_Type":"10","Date_of_Birth":"27-06-1986 00:00:00","PAN_GIR_Number":"","Passport_Number":"","Voter_ID_Number":"CKK1913391","Driving_License_Number":"","Aadhaar_No":""}],"CustomerStatus":[{"Cross_Dedupe_Match_Id":"3095268","Active_Flag":"Z"}],"Dealstatus":[{"Deal_No":"TTU05950H","Status_Flag":"Z"}],"NPA":[],"Restructure":[{"Deal_Restructured":"Yes"}],"Gecl":[],"ARC":[],"PanAlert":[],"CINAlert":[],"BeneficiaryAlert":{"Ben_code":null,"Beneficiary":null,"Status_Flag":null,"PAN_No":null}},{"CustomerCodeVal":"CW3782547","CustomerMaster":[{"CIC_No":null,"Matched_Customer_Code":null,"Rule_Matching_Fields":null,"Current_Parameter_Value":null,"Matched_Parameter_Value":null,"Matched_Score":null,"Rule_Field_Weightage":null,"Matched_Source":null,"Active_Flag":null,"Dedupe_Super_Match":null,"Dedupe_Super_Match_Score":null,"Rule_Id":null,"Type":null,"PEP_Remarks":null,"Customer_Name":"DEIVARAJ","Customer_Type":"10","Date_of_Birth":"27-06-1984 00:00:00","PAN_GIR_Number":"DMSPD9630N","Passport_Number":"","Voter_ID_Number":"CKK1913391","Driving_License_Number":"","Aadhaar_No":"916901617335"}],"CustomerStatus":[{"Cross_Dedupe_Match_Id":"59675453","Active_Flag":"Y"}],"Dealstatus":[{"Deal_No":"TNU05150H","Status_Flag":"Z"},{"Deal_No":"TTU01390S","Status_Flag":"L"}],"NPA":[],"Restructure":[{"Deal_Restructured":"Yes"}],"Gecl":[],"ARC":[],"PanAlert":[],"CINAlert":[],"BeneficiaryAlert":{"Ben_code":null,"Beneficiary":null,"Status_Flag":null,"PAN_No":null}},{"CustomerCodeVal":"CW3782547","CustomerMaster":[{"CIC_No":null,"Matched_Customer_Code":null,"Rule_Matching_Fields":null,"Current_Parameter_Value":null,"Matched_Parameter_Value":null,"Matched_Score":null,"Rule_Field_Weightage":null,"Matched_Source":null,"Active_Flag":null,"Dedupe_Super_Match":null,"Dedupe_Super_Match_Score":null,"Rule_Id":null,"Type":null,"PEP_Remarks":null,"Customer_Name":"DEIVARAJ","Customer_Type":"10","Date_of_Birth":"27-06-1984 00:00:00","PAN_GIR_Number":"DMSPD9630N","Passport_Number":"","Voter_ID_Number":"CKK1913391","Driving_License_Number":"","Aadhaar_No":"916901617335"}],"CustomerStatus":[{"Cross_Dedupe_Match_Id":"59675453","Active_Flag":"Y"}],"Dealstatus":[{"Deal_No":"TNU05150H","Status_Flag":"Z"},{"Deal_No":"TTU01390S","Status_Flag":"L"}],"NPA":[],"Restructure":[{"Deal_Restructured":"Yes"}],"Gecl":[],"ARC":[],"PanAlert":[],"CINAlert":[],"BeneficiaryAlert":{"Ben_code":null,"Beneficiary":null,"Status_Flag":null,"PAN_No":null}},{"CustomerCodeVal":"CW4970396","CustomerMaster":[{"CIC_No":null,"Matched_Customer_Code":null,"Rule_Matching_Fields":null,"Current_Parameter_Value":null,"Matched_Parameter_Value":null,"Matched_Score":null,"Rule_Field_Weightage":null,"Matched_Source":null,"Active_Flag":null,"Dedupe_Super_Match":null,"Dedupe_Super_Match_Score":null,"Rule_Id":null,"Type":null,"PEP_Remarks":null,"Customer_Name":"NAGALAXMI","Customer_Type":"10","Date_of_Birth":"25-03-1981 00:00:00","PAN_GIR_Number":"COMPN4828K","Passport_Number":"","Voter_ID_Number":"","Driving_License_Number":"","Aadhaar_No":"671940628725"}],"CustomerStatus":[{"Cross_Dedupe_Match_Id":"70765909","Active_Flag":"Y"}],"Dealstatus":[],"NPA":[],"Restructure":[{"Deal_Restructured":"Yes"}],"Gecl":[],"ARC":[],"PanAlert":[],"CINAlert":[],"BeneficiaryAlert":{"Ben_code":null,"Beneficiary":null,"Status_Flag":null,"PAN_No":null}}]}]},"ErrorDesc":""}]}}';
            insert cdr1;
            
            
            
            //cdp1.parse(Json.serialize(cdp1));
            ///   String sSelectedCustCode = cdp1.CustomerCodeVal;
            
            Set<String> ciSet = new Set<String>();
            ciSet.add('test');
            
            
            
            
            
            Ind_CustomerDedupCtrl.DedupeResponseWrapper drw1 = new Ind_CustomerDedupCtrl.DedupeResponseWrapper();
            drw1.SFCustomerDedupeFlag = 2.0;
            drw1.PGCustomerDedupeFlag = 3.0;
            drw1.externalDedupeAPIMaxAttempts = 5;
            //    drw1.cicNoSet = ciSet;
            drw1.isValid = true;
            //   drw1.isJourneySkipped = true;
            //     drw1.journeySkipReason = 'testone';
            //   drw1.journeyStopReason = 'testsolve';
            drw1.customerDedupeResponseObjId = 'testcust';
            drw1.message = 'tetsmsg';
            drw1.applicantType = 'testapp';
            drw1.leadNumber = 'tets123';
            drw1.customerName = 'testcust';
            drw1.customerCode = 'test123';
            drw1.invalidCustomerCode = 'testinvalid';
            drw1.response = 'testresponse';
            
            
            
            Test.startTest();
            Ind_CustomerDedupCtrl.validateCustomerCode(apvc1.Id,opvc1.Id, JSON.serialize(cdp1),'Co-borrower');
            Test.stopTest();
            
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }

	@isTest
	public static void validateCustomerCodeTest2(){
        
        try{
            Opportunity opvc1 = new Opportunity();
            opvc1.StageName = 'Qualification';
            opvc1.CloseDate = Date.newInstance(2021, 1, 11);
            opvc1.Name = 'testone';
            insert opvc1;
            
            
            
            Applicant__c apvc1 = new Applicant__c();
            apvc1.Opportunity__c = opvc1.Id;
            apvc1.Contact_number__c = '9743514830';
            apvc1.Applicant_Type__c = 'Borrower';
            insert apvc1;
            
            
            Ind_CustomerDedupCtrl.CustomerDetailsParser cdp1 = new Ind_CustomerDedupCtrl.CustomerDetailsParser();
            cdp1.Aadhaar_No = '987623415643';
            cdp1.CustomerCodeVal = 'CU0503174';
            cdp1.Customer_Name = 'test';
            cdp1.Customer_Type = 'tetstype';
            cdp1.Date_of_Birth = '23061994';
            cdp1.Driving_License_Number = '324556644';
            cdp1.PAN_GIR_Number = 'BSDRT7629K';
            cdp1.Passport_Number = '34567';
            cdp1.Voter_ID_Number = '567388336';
            cdp1.Rule_Matching_Fields = '567388336';
            cdp1.Matched_Score = '567388336';
            cdp1.Matched_Source = 'PAN';
            cdp1.Matched_Parameter_Value = '100';
            
            
            Ind_CustomerDedupCtrl.ReturnMessageWrapper returnMsgWrapper = new Ind_CustomerDedupCtrl.ReturnMessageWrapper();
            returnMsgWrapper.isSuccess = true;
            returnMsgWrapper.message = 'Success';
            returnMsgWrapper.cloneLoanApplicationId = 'test';
            returnMsgWrapper.cloneBorrowerApplicantId = 'tetstype';
            returnMsgWrapper.cloneCoBorrowerApplicantId = '23061994';
            
            //  cdp1.parse(Json.serialize(cdp1));
            Customer_Dedupe_Response__c cdr1 = new Customer_Dedupe_Response__c();
            cdr1.Applicant__c = apvc1.Id;
            cdr1.CIC_No__c = '545667';
            cdr1.CIN_No__c = '34455';
            cdr1.Response__c = '{"response":{"status":"SUCCESS","respDesc":"IxsightEnquiry","content":[{"Data":{"ExternalDedupeResponse":{"DEDUPE_STATUS":"M","DtCFDCUSTBAS":[{"SOURCE_CIC_NO":"2022268275545880078","MATCH_ECIF":"3095268","MATCHED_CUSTOMER_NAME":"S DEIVARAJ","MATCHED_CUSTOMER_CODE":"CU0503174","MATCHED_SOURCE":"CFD","MATCHED_SCORE":"100","MATCHED_CRITERIA":"VOTERID100","CONFIDENCE_LEVEL":"1"}],"DtRECENTLEAD":[{"SOURCE_CIC_NO":"2022268275545880078","MATCHED_CIC_NO":"991102194599513090","MATCHED_LEAD_NAME":"DEIVARAJ S","MATCHED_LEAD_DATE":"12/15/2021 13:55:28","MATCHED_SCORE":"100","MATCHED_CRITERIA":"PAN100"}],"CustomerValidate":[{"CustomerCodeVal":"CU0503174","CustomerMaster":[{"Customer_Name":"S DEIVARAJ","Customer_Type":"10","Date_of_Birth":"27-06-1986 00:00:00","PAN_GIR_Number":"","Passport_Number":"","Voter_ID_Number":"CKK1913391","Driving_License_Number":"","Aadhaar_No":""}],"CustomerStatus":[{"Cross_Dedupe_Match_Id":"3095268","Active_Flag":"Z"}],"Dealstatus":[],"NPA":[{"NPATYPE":"Doubtful 1"}],"Restructure":[{"Deal_Restructured":"No"}],"Gecl":[{"Deal_No":"TTU05950H","Status_Flag":"Z"}],"ARC":[],"PanAlert":[],"CINAlert":[],"BeneficiaryAlert":{"Ben_code":null,"Beneficiary":null,"Status_Flag":null,"PAN_No":null}}]},"InternalDedupeResponse":[{"CustomerMaster":[{"CIC_No":"CU0503174","Matched_Customer_Code":"CU0503174","Rule_Matching_Fields":"VOTERID","Current_Parameter_Value":"CKK1913391","Matched_Parameter_Value":"CKK1913391","Matched_Score":"100","Rule_Field_Weightage":"100","Matched_Source":"CFD","Active_Flag":"Z","Dedupe_Super_Match":"Y","Dedupe_Super_Match_Score":"100","Rule_Id":"VOTERID100","Type":"C","PEP_Remarks":"","Customer_Name":null,"Customer_Type":null,"Date_of_Birth":null,"PAN_GIR_Number":null,"Passport_Number":null,"Voter_ID_Number":null,"Driving_License_Number":null,"Aadhaar_No":null},{"CIC_No":"CW3782547","Matched_Customer_Code":"CW3782547","Rule_Matching_Fields":"PAN","Current_Parameter_Value":"DMSPD9630N","Matched_Parameter_Value":"DMSPD9630N","Matched_Score":"100","Rule_Field_Weightage":"100","Matched_Source":"CFD","Active_Flag":"Y","Dedupe_Super_Match":"Y","Dedupe_Super_Match_Score":"100","Rule_Id":"PAN100","Type":"C","PEP_Remarks":"","Customer_Name":null,"Customer_Type":null,"Date_of_Birth":null,"PAN_GIR_Number":null,"Passport_Number":null,"Voter_ID_Number":null,"Driving_License_Number":null,"Aadhaar_No":null},{"CIC_No":"CW3782547","Matched_Customer_Code":"CW3782547","Rule_Matching_Fields":"VOTERID","Current_Parameter_Value":"CKK1913391","Matched_Parameter_Value":"CKK1913391","Matched_Score":"100","Rule_Field_Weightage":"100","Matched_Source":"CFD","Active_Flag":"Y","Dedupe_Super_Match":"Y","Dedupe_Super_Match_Score":"100","Rule_Id":"VOTERID100","Type":"C","PEP_Remarks":"","Customer_Name":null,"Customer_Type":null,"Date_of_Birth":null,"PAN_GIR_Number":null,"Passport_Number":null,"Voter_ID_Number":null,"Driving_License_Number":null,"Aadhaar_No":null},{"CIC_No":"CW4970396","Matched_Customer_Code":"CW4970396","Rule_Matching_Fields":"AADHAAR_NO","Current_Parameter_Value":"671940628725","Matched_Parameter_Value":"671940628725","Matched_Score":"100","Rule_Field_Weightage":"100","Matched_Source":"CFD","Active_Flag":"Y","Dedupe_Super_Match":"Y","Dedupe_Super_Match_Score":"100","Rule_Id":"ADHAR100","Type":"C","PEP_Remarks":"","Customer_Name":null,"Customer_Type":null,"Date_of_Birth":null,"PAN_GIR_Number":null,"Passport_Number":null,"Voter_ID_Number":null,"Driving_License_Number":null,"Aadhaar_No":null}],"CustomerValidate":[{"CustomerCodeVal":"CU0503174","CustomerMaster":[{"CIC_No":null,"Matched_Customer_Code":null,"Rule_Matching_Fields":null,"Current_Parameter_Value":null,"Matched_Parameter_Value":null,"Matched_Score":null,"Rule_Field_Weightage":null,"Matched_Source":null,"Active_Flag":null,"Dedupe_Super_Match":null,"Dedupe_Super_Match_Score":null,"Rule_Id":null,"Type":null,"PEP_Remarks":null,"Customer_Name":"S DEIVARAJ","Customer_Type":"10","Date_of_Birth":"27-06-1986 00:00:00","PAN_GIR_Number":"","Passport_Number":"","Voter_ID_Number":"CKK1913391","Driving_License_Number":"","Aadhaar_No":""}],"CustomerStatus":[{"Cross_Dedupe_Match_Id":"3095268","Active_Flag":"Z"}],"Dealstatus":[{"Deal_No":"TTU05950H","Status_Flag":"Z"}],"NPA":[],"Restructure":[{"Deal_Restructured":"Yes"}],"Gecl":[],"ARC":[],"PanAlert":[],"CINAlert":[],"BeneficiaryAlert":{"Ben_code":null,"Beneficiary":null,"Status_Flag":null,"PAN_No":null}},{"CustomerCodeVal":"CW3782547","CustomerMaster":[{"CIC_No":null,"Matched_Customer_Code":null,"Rule_Matching_Fields":null,"Current_Parameter_Value":null,"Matched_Parameter_Value":null,"Matched_Score":null,"Rule_Field_Weightage":null,"Matched_Source":null,"Active_Flag":null,"Dedupe_Super_Match":null,"Dedupe_Super_Match_Score":null,"Rule_Id":null,"Type":null,"PEP_Remarks":null,"Customer_Name":"DEIVARAJ","Customer_Type":"10","Date_of_Birth":"27-06-1984 00:00:00","PAN_GIR_Number":"DMSPD9630N","Passport_Number":"","Voter_ID_Number":"CKK1913391","Driving_License_Number":"","Aadhaar_No":"916901617335"}],"CustomerStatus":[{"Cross_Dedupe_Match_Id":"59675453","Active_Flag":"Y"}],"Dealstatus":[{"Deal_No":"TNU05150H","Status_Flag":"Z"},{"Deal_No":"TTU01390S","Status_Flag":"L"}],"NPA":[],"Restructure":[{"Deal_Restructured":"Yes"}],"Gecl":[],"ARC":[],"PanAlert":[],"CINAlert":[],"BeneficiaryAlert":{"Ben_code":null,"Beneficiary":null,"Status_Flag":null,"PAN_No":null}},{"CustomerCodeVal":"CW3782547","CustomerMaster":[{"CIC_No":null,"Matched_Customer_Code":null,"Rule_Matching_Fields":null,"Current_Parameter_Value":null,"Matched_Parameter_Value":null,"Matched_Score":null,"Rule_Field_Weightage":null,"Matched_Source":null,"Active_Flag":null,"Dedupe_Super_Match":null,"Dedupe_Super_Match_Score":null,"Rule_Id":null,"Type":null,"PEP_Remarks":null,"Customer_Name":"DEIVARAJ","Customer_Type":"10","Date_of_Birth":"27-06-1984 00:00:00","PAN_GIR_Number":"DMSPD9630N","Passport_Number":"","Voter_ID_Number":"CKK1913391","Driving_License_Number":"","Aadhaar_No":"916901617335"}],"CustomerStatus":[{"Cross_Dedupe_Match_Id":"59675453","Active_Flag":"Y"}],"Dealstatus":[{"Deal_No":"TNU05150H","Status_Flag":"Z"},{"Deal_No":"TTU01390S","Status_Flag":"L"}],"NPA":[],"Restructure":[{"Deal_Restructured":"Yes"}],"Gecl":[],"ARC":[],"PanAlert":[],"CINAlert":[],"BeneficiaryAlert":{"Ben_code":null,"Beneficiary":null,"Status_Flag":null,"PAN_No":null}},{"CustomerCodeVal":"CW4970396","CustomerMaster":[{"CIC_No":null,"Matched_Customer_Code":null,"Rule_Matching_Fields":null,"Current_Parameter_Value":null,"Matched_Parameter_Value":null,"Matched_Score":null,"Rule_Field_Weightage":null,"Matched_Source":null,"Active_Flag":null,"Dedupe_Super_Match":null,"Dedupe_Super_Match_Score":null,"Rule_Id":null,"Type":null,"PEP_Remarks":null,"Customer_Name":"NAGALAXMI","Customer_Type":"10","Date_of_Birth":"25-03-1981 00:00:00","PAN_GIR_Number":"COMPN4828K","Passport_Number":"","Voter_ID_Number":"","Driving_License_Number":"","Aadhaar_No":"671940628725"}],"CustomerStatus":[{"Cross_Dedupe_Match_Id":"70765909","Active_Flag":"Y"}],"Dealstatus":[],"NPA":[],"Restructure":[{"Deal_Restructured":"Yes"}],"Gecl":[],"ARC":[],"PanAlert":[],"CINAlert":[],"BeneficiaryAlert":{"Ben_code":null,"Beneficiary":null,"Status_Flag":null,"PAN_No":null}}]}]},"ErrorDesc":""}]}}';
            insert cdr1;
            
            
            
            //cdp1.parse(Json.serialize(cdp1));
            ///   String sSelectedCustCode = cdp1.CustomerCodeVal;
            
            Set<String> ciSet = new Set<String>();
            ciSet.add('test');
            
            
            
            
            
            Ind_CustomerDedupCtrl.DedupeResponseWrapper drw1 = new Ind_CustomerDedupCtrl.DedupeResponseWrapper();
            drw1.SFCustomerDedupeFlag = 2.0;
            drw1.PGCustomerDedupeFlag = 3.0;
            drw1.externalDedupeAPIMaxAttempts = 5;
            //    drw1.cicNoSet = ciSet;
            drw1.isValid = true;
       //   drw1.isJourneySkipped = true;
     //     drw1.journeySkipReason = 'testone';
       //   drw1.journeyStopReason = 'testsolve';
            drw1.customerDedupeResponseObjId = 'testcust';
            drw1.message = 'tetsmsg';
            drw1.applicantType = 'testapp';
            drw1.leadNumber = 'tets123';
            drw1.customerName = 'testcust';
            drw1.customerCode = 'test123';
            drw1.invalidCustomerCode = 'testinvalid';
            drw1.response = 'testresponse';
            
            
            
            Test.startTest();
            Ind_CustomerDedupCtrl.validateCustomerCode(apvc1.Id,opvc1.Id, JSON.serialize(cdp1),'Co-borrower');
            Test.stopTest();
            
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }    
    
    @isTest
    public static void validateCustomerCodeTest3(){
        
        try{
            Opportunity opvc1 = new Opportunity();
            opvc1.StageName = 'Qualification';
            opvc1.CloseDate = Date.newInstance(2021, 1, 11);
            opvc1.Name = 'testone';
            insert opvc1;
            
            
            
            Applicant__c apvc1 = new Applicant__c();
            apvc1.Opportunity__c = opvc1.Id;
            apvc1.Contact_number__c = '9743514830';
            apvc1.Applicant_Type__c = 'Borrower';
            insert apvc1;
            
            
            Ind_CustomerDedupCtrl.CustomerDetailsParser cdp1 = new Ind_CustomerDedupCtrl.CustomerDetailsParser();
            cdp1.Aadhaar_No = '987623415643';
            cdp1.CustomerCodeVal = 'CU0503174';
            cdp1.Customer_Name = 'test';
            cdp1.Customer_Type = 'tetstype';
            cdp1.Date_of_Birth = '23061994';
            cdp1.Driving_License_Number = '324556644';
            cdp1.PAN_GIR_Number = 'BSDRT7629K';
            cdp1.Passport_Number = '34567';
            cdp1.Voter_ID_Number = '567388336';
            cdp1.Rule_Matching_Fields = '567388336';
            cdp1.Matched_Score = '567388336';
            cdp1.Matched_Source = 'PAN';
            cdp1.Matched_Parameter_Value = '100';
            
            
            Ind_CustomerDedupCtrl.ReturnMessageWrapper returnMsgWrapper = new Ind_CustomerDedupCtrl.ReturnMessageWrapper();
            returnMsgWrapper.isSuccess = true;
            returnMsgWrapper.message = 'Success';
            returnMsgWrapper.cloneLoanApplicationId = 'test';
            returnMsgWrapper.cloneBorrowerApplicantId = 'tetstype';
            returnMsgWrapper.cloneCoBorrowerApplicantId = '23061994';
            
            //  cdp1.parse(Json.serialize(cdp1));
            Customer_Dedupe_Response__c cdr1 = new Customer_Dedupe_Response__c();
            cdr1.Applicant__c = apvc1.Id;
            cdr1.CIC_No__c = '545667';
            cdr1.CIN_No__c = '34455';
            cdr1.Response__c = '{"response":{"status":"SUCCESS","respDesc":"IxsightEnquiry","content":[{"Data":{"ExternalDedupeResponse":{"DEDUPE_STATUS":"M","DtCFDCUSTBAS":[{"SOURCE_CIC_NO":"2022268275545880078","MATCH_ECIF":"3095268","MATCHED_CUSTOMER_NAME":"S DEIVARAJ","MATCHED_CUSTOMER_CODE":"CU0503174","MATCHED_SOURCE":"CFD","MATCHED_SCORE":"100","MATCHED_CRITERIA":"VOTERID100","CONFIDENCE_LEVEL":"1"}],"DtRECENTLEAD":[{"SOURCE_CIC_NO":"2022268275545880078","MATCHED_CIC_NO":"991102194599513090","MATCHED_LEAD_NAME":"DEIVARAJ S","MATCHED_LEAD_DATE":"12/15/2021 13:55:28","MATCHED_SCORE":"100","MATCHED_CRITERIA":"PAN100"}],"CustomerValidate":[{"CustomerCodeVal":"CU0503174","CustomerMaster":[{"Customer_Name":"S DEIVARAJ","Customer_Type":"10","Date_of_Birth":"27-06-1986 00:00:00","PAN_GIR_Number":"","Passport_Number":"","Voter_ID_Number":"CKK1913391","Driving_License_Number":"","Aadhaar_No":""}],"CustomerStatus":[{"Cross_Dedupe_Match_Id":"3095268","Active_Flag":"Z"}],"Dealstatus":[],"NPA":[],"Restructure":[{"Deal_Restructured":"Yes"}],"Gecl":[{"Deal_No":"TTU05950H","Status_Flag":"Z"}],"ARC":[],"PanAlert":[],"CINAlert":[],"BeneficiaryAlert":{"Ben_code":null,"Beneficiary":null,"Status_Flag":null,"PAN_No":null}}]},"InternalDedupeResponse":[{"CustomerMaster":[{"CIC_No":"CU0503174","Matched_Customer_Code":"CU0503174","Rule_Matching_Fields":"VOTERID","Current_Parameter_Value":"CKK1913391","Matched_Parameter_Value":"CKK1913391","Matched_Score":"100","Rule_Field_Weightage":"100","Matched_Source":"CFD","Active_Flag":"Z","Dedupe_Super_Match":"Y","Dedupe_Super_Match_Score":"100","Rule_Id":"VOTERID100","Type":"C","PEP_Remarks":"","Customer_Name":null,"Customer_Type":null,"Date_of_Birth":null,"PAN_GIR_Number":null,"Passport_Number":null,"Voter_ID_Number":null,"Driving_License_Number":null,"Aadhaar_No":null},{"CIC_No":"CW3782547","Matched_Customer_Code":"CW3782547","Rule_Matching_Fields":"PAN","Current_Parameter_Value":"DMSPD9630N","Matched_Parameter_Value":"DMSPD9630N","Matched_Score":"100","Rule_Field_Weightage":"100","Matched_Source":"CFD","Active_Flag":"Y","Dedupe_Super_Match":"Y","Dedupe_Super_Match_Score":"100","Rule_Id":"PAN100","Type":"C","PEP_Remarks":"","Customer_Name":null,"Customer_Type":null,"Date_of_Birth":null,"PAN_GIR_Number":null,"Passport_Number":null,"Voter_ID_Number":null,"Driving_License_Number":null,"Aadhaar_No":null},{"CIC_No":"CW3782547","Matched_Customer_Code":"CW3782547","Rule_Matching_Fields":"VOTERID","Current_Parameter_Value":"CKK1913391","Matched_Parameter_Value":"CKK1913391","Matched_Score":"100","Rule_Field_Weightage":"100","Matched_Source":"CFD","Active_Flag":"Y","Dedupe_Super_Match":"Y","Dedupe_Super_Match_Score":"100","Rule_Id":"VOTERID100","Type":"C","PEP_Remarks":"","Customer_Name":null,"Customer_Type":null,"Date_of_Birth":null,"PAN_GIR_Number":null,"Passport_Number":null,"Voter_ID_Number":null,"Driving_License_Number":null,"Aadhaar_No":null},{"CIC_No":"CW4970396","Matched_Customer_Code":"CW4970396","Rule_Matching_Fields":"AADHAAR_NO","Current_Parameter_Value":"671940628725","Matched_Parameter_Value":"671940628725","Matched_Score":"100","Rule_Field_Weightage":"100","Matched_Source":"CFD","Active_Flag":"Y","Dedupe_Super_Match":"Y","Dedupe_Super_Match_Score":"100","Rule_Id":"ADHAR100","Type":"C","PEP_Remarks":"","Customer_Name":null,"Customer_Type":null,"Date_of_Birth":null,"PAN_GIR_Number":null,"Passport_Number":null,"Voter_ID_Number":null,"Driving_License_Number":null,"Aadhaar_No":null}],"CustomerValidate":[{"CustomerCodeVal":"CU0503174","CustomerMaster":[{"CIC_No":null,"Matched_Customer_Code":null,"Rule_Matching_Fields":null,"Current_Parameter_Value":null,"Matched_Parameter_Value":null,"Matched_Score":null,"Rule_Field_Weightage":null,"Matched_Source":null,"Active_Flag":null,"Dedupe_Super_Match":null,"Dedupe_Super_Match_Score":null,"Rule_Id":null,"Type":null,"PEP_Remarks":null,"Customer_Name":"S DEIVARAJ","Customer_Type":"10","Date_of_Birth":"27-06-1986 00:00:00","PAN_GIR_Number":"","Passport_Number":"","Voter_ID_Number":"CKK1913391","Driving_License_Number":"","Aadhaar_No":""}],"CustomerStatus":[{"Cross_Dedupe_Match_Id":"3095268","Active_Flag":"Z"}],"Dealstatus":[{"Deal_No":"TTU05950H","Status_Flag":"Z"}],"NPA":[],"Restructure":[{"Deal_Restructured":"Yes"}],"Gecl":[],"ARC":[],"PanAlert":[],"CINAlert":[],"BeneficiaryAlert":{"Ben_code":null,"Beneficiary":null,"Status_Flag":null,"PAN_No":null}},{"CustomerCodeVal":"CW3782547","CustomerMaster":[{"CIC_No":null,"Matched_Customer_Code":null,"Rule_Matching_Fields":null,"Current_Parameter_Value":null,"Matched_Parameter_Value":null,"Matched_Score":null,"Rule_Field_Weightage":null,"Matched_Source":null,"Active_Flag":null,"Dedupe_Super_Match":null,"Dedupe_Super_Match_Score":null,"Rule_Id":null,"Type":null,"PEP_Remarks":null,"Customer_Name":"DEIVARAJ","Customer_Type":"10","Date_of_Birth":"27-06-1984 00:00:00","PAN_GIR_Number":"DMSPD9630N","Passport_Number":"","Voter_ID_Number":"CKK1913391","Driving_License_Number":"","Aadhaar_No":"916901617335"}],"CustomerStatus":[{"Cross_Dedupe_Match_Id":"59675453","Active_Flag":"Y"}],"Dealstatus":[{"Deal_No":"TNU05150H","Status_Flag":"Z"},{"Deal_No":"TTU01390S","Status_Flag":"L"}],"NPA":[],"Restructure":[{"Deal_Restructured":"Yes"}],"Gecl":[],"ARC":[],"PanAlert":[],"CINAlert":[],"BeneficiaryAlert":{"Ben_code":null,"Beneficiary":null,"Status_Flag":null,"PAN_No":null}},{"CustomerCodeVal":"CW3782547","CustomerMaster":[{"CIC_No":null,"Matched_Customer_Code":null,"Rule_Matching_Fields":null,"Current_Parameter_Value":null,"Matched_Parameter_Value":null,"Matched_Score":null,"Rule_Field_Weightage":null,"Matched_Source":null,"Active_Flag":null,"Dedupe_Super_Match":null,"Dedupe_Super_Match_Score":null,"Rule_Id":null,"Type":null,"PEP_Remarks":null,"Customer_Name":"DEIVARAJ","Customer_Type":"10","Date_of_Birth":"27-06-1984 00:00:00","PAN_GIR_Number":"DMSPD9630N","Passport_Number":"","Voter_ID_Number":"CKK1913391","Driving_License_Number":"","Aadhaar_No":"916901617335"}],"CustomerStatus":[{"Cross_Dedupe_Match_Id":"59675453","Active_Flag":"Y"}],"Dealstatus":[{"Deal_No":"TNU05150H","Status_Flag":"Z"},{"Deal_No":"TTU01390S","Status_Flag":"L"}],"NPA":[],"Restructure":[{"Deal_Restructured":"Yes"}],"Gecl":[],"ARC":[],"PanAlert":[],"CINAlert":[],"BeneficiaryAlert":{"Ben_code":null,"Beneficiary":null,"Status_Flag":null,"PAN_No":null}},{"CustomerCodeVal":"CW4970396","CustomerMaster":[{"CIC_No":null,"Matched_Customer_Code":null,"Rule_Matching_Fields":null,"Current_Parameter_Value":null,"Matched_Parameter_Value":null,"Matched_Score":null,"Rule_Field_Weightage":null,"Matched_Source":null,"Active_Flag":null,"Dedupe_Super_Match":null,"Dedupe_Super_Match_Score":null,"Rule_Id":null,"Type":null,"PEP_Remarks":null,"Customer_Name":"NAGALAXMI","Customer_Type":"10","Date_of_Birth":"25-03-1981 00:00:00","PAN_GIR_Number":"COMPN4828K","Passport_Number":"","Voter_ID_Number":"","Driving_License_Number":"","Aadhaar_No":"671940628725"}],"CustomerStatus":[{"Cross_Dedupe_Match_Id":"70765909","Active_Flag":"Y"}],"Dealstatus":[],"NPA":[],"Restructure":[{"Deal_Restructured":"Yes"}],"Gecl":[],"ARC":[],"PanAlert":[],"CINAlert":[],"BeneficiaryAlert":{"Ben_code":null,"Beneficiary":null,"Status_Flag":null,"PAN_No":null}}]}]},"ErrorDesc":""}]}}';
            insert cdr1;
            
            
            
            //cdp1.parse(Json.serialize(cdp1));
            ///   String sSelectedCustCode = cdp1.CustomerCodeVal;
            
            Set<String> ciSet = new Set<String>();
            ciSet.add('test');
            
            
            
            
            
            Ind_CustomerDedupCtrl.DedupeResponseWrapper drw1 = new Ind_CustomerDedupCtrl.DedupeResponseWrapper();
            drw1.SFCustomerDedupeFlag = 2.0;
            drw1.PGCustomerDedupeFlag = 3.0;
            drw1.externalDedupeAPIMaxAttempts = 5;
            //    drw1.cicNoSet = ciSet;
            drw1.isValid = true;
       //   drw1.isJourneySkipped = true;
     //     drw1.journeySkipReason = 'testone';
       //   drw1.journeyStopReason = 'testsolve';
            drw1.customerDedupeResponseObjId = 'testcust';
            drw1.message = 'tetsmsg';
            drw1.applicantType = 'testapp';
            drw1.leadNumber = 'tets123';
            drw1.customerName = 'testcust';
            drw1.customerCode = 'test123';
            drw1.invalidCustomerCode = 'testinvalid';
            drw1.response = 'testresponse';
            
            
            
            Test.startTest();
            Ind_CustomerDedupCtrl.validateCustomerCode(apvc1.Id,opvc1.Id, JSON.serialize(cdp1),'Borrower');
            Test.stopTest();
            
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void validateCustomerCodeTest4(){
        
        try{
            Opportunity opvc1 = new Opportunity();
            opvc1.StageName = 'Qualification';
            opvc1.CloseDate = Date.newInstance(2021, 1, 11);
            opvc1.Name = 'testone';
            insert opvc1;
            
            
            
            Applicant__c apvc1 = new Applicant__c();
            apvc1.Opportunity__c = opvc1.Id;
            apvc1.Contact_number__c = '9743514830';
            apvc1.Applicant_Type__c = 'Borrower';
            insert apvc1;
            
            
            Ind_CustomerDedupCtrl.CustomerDetailsParser cdp1 = new Ind_CustomerDedupCtrl.CustomerDetailsParser();
            cdp1.Aadhaar_No = '987623415643';
            cdp1.CustomerCodeVal = 'CU0503174';
            cdp1.Customer_Name = 'test';
            cdp1.Customer_Type = 'tetstype';
            cdp1.Date_of_Birth = '23061994';
            cdp1.Driving_License_Number = '324556644';
            cdp1.PAN_GIR_Number = 'BSDRT7629K';
            cdp1.Passport_Number = '34567';
            cdp1.Voter_ID_Number = '567388336';
            cdp1.Rule_Matching_Fields = '567388336';
            cdp1.Matched_Score = '567388336';
            cdp1.Matched_Source = 'PAN';
            cdp1.Matched_Parameter_Value = '100';
            
            
            Ind_CustomerDedupCtrl.ReturnMessageWrapper returnMsgWrapper = new Ind_CustomerDedupCtrl.ReturnMessageWrapper();
            returnMsgWrapper.isSuccess = true;
            returnMsgWrapper.message = 'Success';
            returnMsgWrapper.cloneLoanApplicationId = 'test';
            returnMsgWrapper.cloneBorrowerApplicantId = 'tetstype';
            returnMsgWrapper.cloneCoBorrowerApplicantId = '23061994';
            
            //  cdp1.parse(Json.serialize(cdp1));
            Customer_Dedupe_Response__c cdr1 = new Customer_Dedupe_Response__c();
            cdr1.Applicant__c = apvc1.Id;
            cdr1.CIC_No__c = '545667';
            cdr1.CIN_No__c = '34455';
            cdr1.Response__c = '{"response":{"status":"SUCCESS","respDesc":"IxsightEnquiry","content":[{"Data":{"ExternalDedupeResponse":{"DEDUPE_STATUS":"M","DtCFDCUSTBAS":[{"SOURCE_CIC_NO":"2022268275545880078","MATCH_ECIF":"3095268","MATCHED_CUSTOMER_NAME":"S DEIVARAJ","MATCHED_CUSTOMER_CODE":"CU0503174","MATCHED_SOURCE":"CFD","MATCHED_SCORE":"100","MATCHED_CRITERIA":"VOTERID100","CONFIDENCE_LEVEL":"1"}],"DtRECENTLEAD":[{"SOURCE_CIC_NO":"2022268275545880078","MATCHED_CIC_NO":"991102194599513090","MATCHED_LEAD_NAME":"DEIVARAJ S","MATCHED_LEAD_DATE":"12/15/2021 13:55:28","MATCHED_SCORE":"100","MATCHED_CRITERIA":"PAN100"}],"CustomerValidate":[{"CustomerCodeVal":"CU0503174","CustomerMaster":[{"Customer_Name":"S DEIVARAJ","Customer_Type":"10","Date_of_Birth":"27-06-1986 00:00:00","PAN_GIR_Number":"","Passport_Number":"","Voter_ID_Number":"CKK1913391","Driving_License_Number":"","Aadhaar_No":""}],"CustomerStatus":[{"Cross_Dedupe_Match_Id":"3095268","Active_Flag":"Z"}],"Dealstatus":[],"NPA":[],"Restructure":[{"Deal_Restructured":"No"}],"Gecl":[],"ARC":[],"PanAlert":[],"CINAlert":[],"BeneficiaryAlert":{"Ben_code":null,"Beneficiary":null,"Status_Flag":null,"PAN_No":null}}]},"InternalDedupeResponse":[{"CustomerMaster":[{"CIC_No":"CU0503174","Matched_Customer_Code":"CU0503174","Rule_Matching_Fields":"VOTERID","Current_Parameter_Value":"CKK1913391","Matched_Parameter_Value":"CKK1913391","Matched_Score":"100","Rule_Field_Weightage":"100","Matched_Source":"CFD","Active_Flag":"Z","Dedupe_Super_Match":"Y","Dedupe_Super_Match_Score":"100","Rule_Id":"VOTERID100","Type":"C","PEP_Remarks":"","Customer_Name":null,"Customer_Type":null,"Date_of_Birth":null,"PAN_GIR_Number":null,"Passport_Number":null,"Voter_ID_Number":null,"Driving_License_Number":null,"Aadhaar_No":null},{"CIC_No":"CW3782547","Matched_Customer_Code":"CW3782547","Rule_Matching_Fields":"PAN","Current_Parameter_Value":"DMSPD9630N","Matched_Parameter_Value":"DMSPD9630N","Matched_Score":"100","Rule_Field_Weightage":"100","Matched_Source":"CFD","Active_Flag":"Y","Dedupe_Super_Match":"Y","Dedupe_Super_Match_Score":"100","Rule_Id":"PAN100","Type":"C","PEP_Remarks":"","Customer_Name":null,"Customer_Type":null,"Date_of_Birth":null,"PAN_GIR_Number":null,"Passport_Number":null,"Voter_ID_Number":null,"Driving_License_Number":null,"Aadhaar_No":null},{"CIC_No":"CW3782547","Matched_Customer_Code":"CW3782547","Rule_Matching_Fields":"VOTERID","Current_Parameter_Value":"CKK1913391","Matched_Parameter_Value":"CKK1913391","Matched_Score":"100","Rule_Field_Weightage":"100","Matched_Source":"CFD","Active_Flag":"Y","Dedupe_Super_Match":"Y","Dedupe_Super_Match_Score":"100","Rule_Id":"VOTERID100","Type":"C","PEP_Remarks":"","Customer_Name":null,"Customer_Type":null,"Date_of_Birth":null,"PAN_GIR_Number":null,"Passport_Number":null,"Voter_ID_Number":null,"Driving_License_Number":null,"Aadhaar_No":null},{"CIC_No":"CW4970396","Matched_Customer_Code":"CW4970396","Rule_Matching_Fields":"AADHAAR_NO","Current_Parameter_Value":"671940628725","Matched_Parameter_Value":"671940628725","Matched_Score":"100","Rule_Field_Weightage":"100","Matched_Source":"CFD","Active_Flag":"Y","Dedupe_Super_Match":"Y","Dedupe_Super_Match_Score":"100","Rule_Id":"ADHAR100","Type":"C","PEP_Remarks":"","Customer_Name":null,"Customer_Type":null,"Date_of_Birth":null,"PAN_GIR_Number":null,"Passport_Number":null,"Voter_ID_Number":null,"Driving_License_Number":null,"Aadhaar_No":null}],"CustomerValidate":[{"CustomerCodeVal":"CU0503174","CustomerMaster":[{"CIC_No":null,"Matched_Customer_Code":null,"Rule_Matching_Fields":null,"Current_Parameter_Value":null,"Matched_Parameter_Value":null,"Matched_Score":null,"Rule_Field_Weightage":null,"Matched_Source":null,"Active_Flag":null,"Dedupe_Super_Match":null,"Dedupe_Super_Match_Score":null,"Rule_Id":null,"Type":null,"PEP_Remarks":null,"Customer_Name":"S DEIVARAJ","Customer_Type":"10","Date_of_Birth":"27-06-1986 00:00:00","PAN_GIR_Number":"","Passport_Number":"","Voter_ID_Number":"CKK1913391","Driving_License_Number":"","Aadhaar_No":""}],"CustomerStatus":[{"Cross_Dedupe_Match_Id":"3095268","Active_Flag":"Z"}],"Dealstatus":[{"Deal_No":"TTU05950H","Status_Flag":"Z"}],"NPA":[],"Restructure":[{"Deal_Restructured":"Yes"}],"Gecl":[],"ARC":[],"PanAlert":[],"CINAlert":[],"BeneficiaryAlert":{"Ben_code":null,"Beneficiary":null,"Status_Flag":null,"PAN_No":null}},{"CustomerCodeVal":"CW3782547","CustomerMaster":[{"CIC_No":null,"Matched_Customer_Code":null,"Rule_Matching_Fields":null,"Current_Parameter_Value":null,"Matched_Parameter_Value":null,"Matched_Score":null,"Rule_Field_Weightage":null,"Matched_Source":null,"Active_Flag":null,"Dedupe_Super_Match":null,"Dedupe_Super_Match_Score":null,"Rule_Id":null,"Type":null,"PEP_Remarks":null,"Customer_Name":"DEIVARAJ","Customer_Type":"10","Date_of_Birth":"27-06-1984 00:00:00","PAN_GIR_Number":"DMSPD9630N","Passport_Number":"","Voter_ID_Number":"CKK1913391","Driving_License_Number":"","Aadhaar_No":"916901617335"}],"CustomerStatus":[{"Cross_Dedupe_Match_Id":"59675453","Active_Flag":"Y"}],"Dealstatus":[{"Deal_No":"TNU05150H","Status_Flag":"Z"},{"Deal_No":"TTU01390S","Status_Flag":"L"}],"NPA":[],"Restructure":[{"Deal_Restructured":"Yes"}],"Gecl":[],"ARC":[],"PanAlert":[],"CINAlert":[],"BeneficiaryAlert":{"Ben_code":null,"Beneficiary":null,"Status_Flag":null,"PAN_No":null}},{"CustomerCodeVal":"CW3782547","CustomerMaster":[{"CIC_No":null,"Matched_Customer_Code":null,"Rule_Matching_Fields":null,"Current_Parameter_Value":null,"Matched_Parameter_Value":null,"Matched_Score":null,"Rule_Field_Weightage":null,"Matched_Source":null,"Active_Flag":null,"Dedupe_Super_Match":null,"Dedupe_Super_Match_Score":null,"Rule_Id":null,"Type":null,"PEP_Remarks":null,"Customer_Name":"DEIVARAJ","Customer_Type":"10","Date_of_Birth":"27-06-1984 00:00:00","PAN_GIR_Number":"DMSPD9630N","Passport_Number":"","Voter_ID_Number":"CKK1913391","Driving_License_Number":"","Aadhaar_No":"916901617335"}],"CustomerStatus":[{"Cross_Dedupe_Match_Id":"59675453","Active_Flag":"Y"}],"Dealstatus":[{"Deal_No":"TNU05150H","Status_Flag":"Z"},{"Deal_No":"TTU01390S","Status_Flag":"L"}],"NPA":[],"Restructure":[{"Deal_Restructured":"Yes"}],"Gecl":[],"ARC":[],"PanAlert":[],"CINAlert":[],"BeneficiaryAlert":{"Ben_code":null,"Beneficiary":null,"Status_Flag":null,"PAN_No":null}},{"CustomerCodeVal":"CW4970396","CustomerMaster":[{"CIC_No":null,"Matched_Customer_Code":null,"Rule_Matching_Fields":null,"Current_Parameter_Value":null,"Matched_Parameter_Value":null,"Matched_Score":null,"Rule_Field_Weightage":null,"Matched_Source":null,"Active_Flag":null,"Dedupe_Super_Match":null,"Dedupe_Super_Match_Score":null,"Rule_Id":null,"Type":null,"PEP_Remarks":null,"Customer_Name":"NAGALAXMI","Customer_Type":"10","Date_of_Birth":"25-03-1981 00:00:00","PAN_GIR_Number":"COMPN4828K","Passport_Number":"","Voter_ID_Number":"","Driving_License_Number":"","Aadhaar_No":"671940628725"}],"CustomerStatus":[{"Cross_Dedupe_Match_Id":"70765909","Active_Flag":"Y"}],"Dealstatus":[],"NPA":[],"Restructure":[{"Deal_Restructured":"Yes"}],"Gecl":[],"ARC":[],"PanAlert":[],"CINAlert":[],"BeneficiaryAlert":{"Ben_code":null,"Beneficiary":null,"Status_Flag":null,"PAN_No":null}}]}]},"ErrorDesc":""}]}}';
            insert cdr1;
            
            
            
            //cdp1.parse(Json.serialize(cdp1));
            ///   String sSelectedCustCode = cdp1.CustomerCodeVal;
            
            Set<String> ciSet = new Set<String>();
            ciSet.add('test');
            
            
            
            
            
            Ind_CustomerDedupCtrl.DedupeResponseWrapper drw1 = new Ind_CustomerDedupCtrl.DedupeResponseWrapper();
            drw1.SFCustomerDedupeFlag = 2.0;
            drw1.PGCustomerDedupeFlag = 3.0;
            drw1.externalDedupeAPIMaxAttempts = 5;
            //    drw1.cicNoSet = ciSet;
            drw1.isValid = true;
            //   drw1.isJourneySkipped = true;
            //     drw1.journeySkipReason = 'testone';
            //   drw1.journeyStopReason = 'testsolve';
            drw1.customerDedupeResponseObjId = 'testcust';
            drw1.message = 'tetsmsg';
            drw1.applicantType = 'testapp';
            drw1.leadNumber = 'tets123';
            drw1.customerName = 'testcust';
            drw1.customerCode = 'test123';
            drw1.invalidCustomerCode = 'testinvalid';
            drw1.response = 'testresponse';
            
            
            
            Test.startTest();
            Ind_CustomerDedupCtrl.validateCustomerCode(apvc1.Id,opvc1.Id, JSON.serialize(cdp1),'Co-borrower');
            Test.stopTest();
            
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void validateCustomerCodeTest5(){
        
        try{
            Opportunity opvc1 = new Opportunity();
            opvc1.StageName = 'Qualification';
            opvc1.CloseDate = Date.newInstance(2021, 1, 11);
            opvc1.Name = 'testone';
            insert opvc1;
            
            
            
            Applicant__c apvc1 = new Applicant__c();
            apvc1.Opportunity__c = opvc1.Id;
            apvc1.Contact_number__c = '9743514830';
            apvc1.Applicant_Type__c = 'Borrower';
            insert apvc1;
            
            
            Ind_CustomerDedupCtrl.CustomerDetailsParser cdp1 = new Ind_CustomerDedupCtrl.CustomerDetailsParser();
            cdp1.Aadhaar_No = '987623415643';
            cdp1.CustomerCodeVal = 'CU0503174';
            cdp1.Customer_Name = 'test';
            cdp1.Customer_Type = 'tetstype';
            cdp1.Date_of_Birth = '23061994';
            cdp1.Driving_License_Number = '324556644';
            cdp1.PAN_GIR_Number = 'BSDRT7629K';
            cdp1.Passport_Number = '34567';
            cdp1.Voter_ID_Number = '567388336';
            cdp1.Rule_Matching_Fields = '567388336';
            cdp1.Matched_Score = '567388336';
            cdp1.Matched_Source = 'PAN';
            cdp1.Matched_Parameter_Value = '100';
            
            
            Ind_CustomerDedupCtrl.ReturnMessageWrapper returnMsgWrapper = new Ind_CustomerDedupCtrl.ReturnMessageWrapper();
            returnMsgWrapper.isSuccess = true;
            returnMsgWrapper.message = 'Success';
            returnMsgWrapper.cloneLoanApplicationId = 'test';
            returnMsgWrapper.cloneBorrowerApplicantId = 'tetstype';
            returnMsgWrapper.cloneCoBorrowerApplicantId = '23061994';
            
            //  cdp1.parse(Json.serialize(cdp1));
            Customer_Dedupe_Response__c cdr1 = new Customer_Dedupe_Response__c();
            cdr1.Applicant__c = apvc1.Id;
            cdr1.CIC_No__c = '545667';
            cdr1.CIN_No__c = '34455';
            cdr1.Response__c = '{"response":{"status":"SUCCESS","respDesc":"IxsightEnquiry","content":[{"Data":{"ExternalDedupeResponse":{"DEDUPE_STATUS":"M","DtCFDCUSTBAS":[{"SOURCE_CIC_NO":"2022268275545880078","MATCH_ECIF":"3095268","MATCHED_CUSTOMER_NAME":"S DEIVARAJ","MATCHED_CUSTOMER_CODE":"CU0503174","MATCHED_SOURCE":"CFD","MATCHED_SCORE":"100","MATCHED_CRITERIA":"VOTERID100","CONFIDENCE_LEVEL":"1"}],"DtRECENTLEAD":[{"SOURCE_CIC_NO":"2022268275545880078","MATCHED_CIC_NO":"991102194599513090","MATCHED_LEAD_NAME":"DEIVARAJ S","MATCHED_LEAD_DATE":"12/15/2021 13:55:28","MATCHED_SCORE":"100","MATCHED_CRITERIA":"PAN100"}],"CustomerValidate":[{"CustomerCodeVal":"CU0503174","CustomerMaster":[{"Customer_Name":"S DEIVARAJ","Customer_Type":"10","Date_of_Birth":"27-06-1986 00:00:00","PAN_GIR_Number":"","Passport_Number":"","Voter_ID_Number":"CKK1913391","Driving_License_Number":"","Aadhaar_No":""}],"CustomerStatus":[{"Cross_Dedupe_Match_Id":"3095268","Active_Flag":"Z"}],"Dealstatus":[],"NPA":[],"Restructure":[{"Deal_Restructured":"No"}],"Gecl":[{"Deal_No":"TTU05950H","Status_Flag":"Z"}],"ARC":[],"PanAlert":[],"CINAlert":[],"BeneficiaryAlert":{"Ben_code":null,"Beneficiary":null,"Status_Flag":null,"PAN_No":null}}]},"InternalDedupeResponse":[{"CustomerMaster":[{"CIC_No":"CU0503174","Matched_Customer_Code":"CU0503174","Rule_Matching_Fields":"VOTERID","Current_Parameter_Value":"CKK1913391","Matched_Parameter_Value":"CKK1913391","Matched_Score":"100","Rule_Field_Weightage":"100","Matched_Source":"CFD","Active_Flag":"Z","Dedupe_Super_Match":"Y","Dedupe_Super_Match_Score":"100","Rule_Id":"VOTERID100","Type":"C","PEP_Remarks":"","Customer_Name":null,"Customer_Type":null,"Date_of_Birth":null,"PAN_GIR_Number":null,"Passport_Number":null,"Voter_ID_Number":null,"Driving_License_Number":null,"Aadhaar_No":null},{"CIC_No":"CW3782547","Matched_Customer_Code":"CW3782547","Rule_Matching_Fields":"PAN","Current_Parameter_Value":"DMSPD9630N","Matched_Parameter_Value":"DMSPD9630N","Matched_Score":"100","Rule_Field_Weightage":"100","Matched_Source":"CFD","Active_Flag":"Y","Dedupe_Super_Match":"Y","Dedupe_Super_Match_Score":"100","Rule_Id":"PAN100","Type":"C","PEP_Remarks":"","Customer_Name":null,"Customer_Type":null,"Date_of_Birth":null,"PAN_GIR_Number":null,"Passport_Number":null,"Voter_ID_Number":null,"Driving_License_Number":null,"Aadhaar_No":null},{"CIC_No":"CW3782547","Matched_Customer_Code":"CW3782547","Rule_Matching_Fields":"VOTERID","Current_Parameter_Value":"CKK1913391","Matched_Parameter_Value":"CKK1913391","Matched_Score":"100","Rule_Field_Weightage":"100","Matched_Source":"CFD","Active_Flag":"Y","Dedupe_Super_Match":"Y","Dedupe_Super_Match_Score":"100","Rule_Id":"VOTERID100","Type":"C","PEP_Remarks":"","Customer_Name":null,"Customer_Type":null,"Date_of_Birth":null,"PAN_GIR_Number":null,"Passport_Number":null,"Voter_ID_Number":null,"Driving_License_Number":null,"Aadhaar_No":null},{"CIC_No":"CW4970396","Matched_Customer_Code":"CW4970396","Rule_Matching_Fields":"AADHAAR_NO","Current_Parameter_Value":"671940628725","Matched_Parameter_Value":"671940628725","Matched_Score":"100","Rule_Field_Weightage":"100","Matched_Source":"CFD","Active_Flag":"Y","Dedupe_Super_Match":"Y","Dedupe_Super_Match_Score":"100","Rule_Id":"ADHAR100","Type":"C","PEP_Remarks":"","Customer_Name":null,"Customer_Type":null,"Date_of_Birth":null,"PAN_GIR_Number":null,"Passport_Number":null,"Voter_ID_Number":null,"Driving_License_Number":null,"Aadhaar_No":null}],"CustomerValidate":[{"CustomerCodeVal":"CU0503174","CustomerMaster":[{"CIC_No":null,"Matched_Customer_Code":null,"Rule_Matching_Fields":null,"Current_Parameter_Value":null,"Matched_Parameter_Value":null,"Matched_Score":null,"Rule_Field_Weightage":null,"Matched_Source":null,"Active_Flag":null,"Dedupe_Super_Match":null,"Dedupe_Super_Match_Score":null,"Rule_Id":null,"Type":null,"PEP_Remarks":null,"Customer_Name":"S DEIVARAJ","Customer_Type":"10","Date_of_Birth":"27-06-1986 00:00:00","PAN_GIR_Number":"","Passport_Number":"","Voter_ID_Number":"CKK1913391","Driving_License_Number":"","Aadhaar_No":""}],"CustomerStatus":[{"Cross_Dedupe_Match_Id":"3095268","Active_Flag":"Z"}],"Dealstatus":[{"Deal_No":"TTU05950H","Status_Flag":"Z"}],"NPA":[],"Restructure":[{"Deal_Restructured":"Yes"}],"Gecl":[],"ARC":[],"PanAlert":[],"CINAlert":[],"BeneficiaryAlert":{"Ben_code":null,"Beneficiary":null,"Status_Flag":null,"PAN_No":null}},{"CustomerCodeVal":"CW3782547","CustomerMaster":[{"CIC_No":null,"Matched_Customer_Code":null,"Rule_Matching_Fields":null,"Current_Parameter_Value":null,"Matched_Parameter_Value":null,"Matched_Score":null,"Rule_Field_Weightage":null,"Matched_Source":null,"Active_Flag":null,"Dedupe_Super_Match":null,"Dedupe_Super_Match_Score":null,"Rule_Id":null,"Type":null,"PEP_Remarks":null,"Customer_Name":"DEIVARAJ","Customer_Type":"10","Date_of_Birth":"27-06-1984 00:00:00","PAN_GIR_Number":"DMSPD9630N","Passport_Number":"","Voter_ID_Number":"CKK1913391","Driving_License_Number":"","Aadhaar_No":"916901617335"}],"CustomerStatus":[{"Cross_Dedupe_Match_Id":"59675453","Active_Flag":"Y"}],"Dealstatus":[{"Deal_No":"TNU05150H","Status_Flag":"Z"},{"Deal_No":"TTU01390S","Status_Flag":"L"}],"NPA":[],"Restructure":[{"Deal_Restructured":"Yes"}],"Gecl":[],"ARC":[],"PanAlert":[],"CINAlert":[],"BeneficiaryAlert":{"Ben_code":null,"Beneficiary":null,"Status_Flag":null,"PAN_No":null}},{"CustomerCodeVal":"CW3782547","CustomerMaster":[{"CIC_No":null,"Matched_Customer_Code":null,"Rule_Matching_Fields":null,"Current_Parameter_Value":null,"Matched_Parameter_Value":null,"Matched_Score":null,"Rule_Field_Weightage":null,"Matched_Source":null,"Active_Flag":null,"Dedupe_Super_Match":null,"Dedupe_Super_Match_Score":null,"Rule_Id":null,"Type":null,"PEP_Remarks":null,"Customer_Name":"DEIVARAJ","Customer_Type":"10","Date_of_Birth":"27-06-1984 00:00:00","PAN_GIR_Number":"DMSPD9630N","Passport_Number":"","Voter_ID_Number":"CKK1913391","Driving_License_Number":"","Aadhaar_No":"916901617335"}],"CustomerStatus":[{"Cross_Dedupe_Match_Id":"59675453","Active_Flag":"Y"}],"Dealstatus":[{"Deal_No":"TNU05150H","Status_Flag":"Z"},{"Deal_No":"TTU01390S","Status_Flag":"L"}],"NPA":[],"Restructure":[{"Deal_Restructured":"Yes"}],"Gecl":[],"ARC":[],"PanAlert":[],"CINAlert":[],"BeneficiaryAlert":{"Ben_code":null,"Beneficiary":null,"Status_Flag":null,"PAN_No":null}},{"CustomerCodeVal":"CW4970396","CustomerMaster":[{"CIC_No":null,"Matched_Customer_Code":null,"Rule_Matching_Fields":null,"Current_Parameter_Value":null,"Matched_Parameter_Value":null,"Matched_Score":null,"Rule_Field_Weightage":null,"Matched_Source":null,"Active_Flag":null,"Dedupe_Super_Match":null,"Dedupe_Super_Match_Score":null,"Rule_Id":null,"Type":null,"PEP_Remarks":null,"Customer_Name":"NAGALAXMI","Customer_Type":"10","Date_of_Birth":"25-03-1981 00:00:00","PAN_GIR_Number":"COMPN4828K","Passport_Number":"","Voter_ID_Number":"","Driving_License_Number":"","Aadhaar_No":"671940628725"}],"CustomerStatus":[{"Cross_Dedupe_Match_Id":"70765909","Active_Flag":"Y"}],"Dealstatus":[],"NPA":[],"Restructure":[{"Deal_Restructured":"Yes"}],"Gecl":[],"ARC":[],"PanAlert":[],"CINAlert":[],"BeneficiaryAlert":{"Ben_code":null,"Beneficiary":null,"Status_Flag":null,"PAN_No":null}}]}]},"ErrorDesc":""}]}}';
            insert cdr1;
            
            
            
            //cdp1.parse(Json.serialize(cdp1));
            ///   String sSelectedCustCode = cdp1.CustomerCodeVal;
            
            Set<String> ciSet = new Set<String>();
            ciSet.add('test');
            
            
            
            
            
            Ind_CustomerDedupCtrl.DedupeResponseWrapper drw1 = new Ind_CustomerDedupCtrl.DedupeResponseWrapper();
            drw1.SFCustomerDedupeFlag = 2.0;
            drw1.PGCustomerDedupeFlag = 3.0;
            drw1.externalDedupeAPIMaxAttempts = 5;
            //    drw1.cicNoSet = ciSet;
            drw1.isValid = true;
       //   drw1.isJourneySkipped = true;
     //     drw1.journeySkipReason = 'testone';
       //   drw1.journeyStopReason = 'testsolve';
            drw1.customerDedupeResponseObjId = 'testcust';
            drw1.message = 'tetsmsg';
            drw1.applicantType = 'testapp';
            drw1.leadNumber = 'tets123';
            drw1.customerName = 'testcust';
            drw1.customerCode = 'test123';
            drw1.invalidCustomerCode = 'testinvalid';
            drw1.response = 'testresponse';
            
            
            
            Test.startTest();
            Ind_CustomerDedupCtrl.validateCustomerCode(apvc1.Id,opvc1.Id, JSON.serialize(cdp1),'Borrower');
            Test.stopTest();
            
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
     @isTest
    public static void validateCustomerCodeTest6(){
        
        try{
            Opportunity opvc1 = new Opportunity();
            opvc1.StageName = 'Qualification';
            opvc1.CloseDate = Date.newInstance(2021, 1, 11);
            opvc1.Name = 'testone';
            insert opvc1;
            
            
            
            Applicant__c apvc1 = new Applicant__c();
            apvc1.Opportunity__c = opvc1.Id;
            apvc1.Contact_number__c = '9743514830';
            apvc1.Applicant_Type__c = 'Borrower';
            insert apvc1;
            
            
            Ind_CustomerDedupCtrl.CustomerDetailsParser cdp1 = new Ind_CustomerDedupCtrl.CustomerDetailsParser();
            cdp1.Aadhaar_No = '987623415643';
            cdp1.CustomerCodeVal = 'CU0503174';
            cdp1.Customer_Name = 'test';
            cdp1.Customer_Type = 'tetstype';
            cdp1.Date_of_Birth = '23061994';
            cdp1.Driving_License_Number = '324556644';
            cdp1.PAN_GIR_Number = 'BSDRT7629K';
            cdp1.Passport_Number = '34567';
            cdp1.Voter_ID_Number = '567388336';
            cdp1.Rule_Matching_Fields = '567388336';
            cdp1.Matched_Score = '567388336';
            cdp1.Matched_Source = 'PAN';
            cdp1.Matched_Parameter_Value = '100';
            
            
            Ind_CustomerDedupCtrl.ReturnMessageWrapper returnMsgWrapper = new Ind_CustomerDedupCtrl.ReturnMessageWrapper();
            returnMsgWrapper.isSuccess = true;
            returnMsgWrapper.message = 'Success';
            returnMsgWrapper.cloneLoanApplicationId = 'test';
            returnMsgWrapper.cloneBorrowerApplicantId = 'tetstype';
            returnMsgWrapper.cloneCoBorrowerApplicantId = '23061994';
            
            //  cdp1.parse(Json.serialize(cdp1));
            Customer_Dedupe_Response__c cdr1 = new Customer_Dedupe_Response__c();
            cdr1.Applicant__c = apvc1.Id;
            cdr1.CIC_No__c = '545667';
            cdr1.CIN_No__c = '34455';
            cdr1.Response__c = '{"response":{"status":"SUCCESS","respDesc":"IxsightEnquiry","content":[{"Data":{"ExternalDedupeResponse":{"DEDUPE_STATUS":"M","DtCFDCUSTBAS":[{"SOURCE_CIC_NO":"2022268275545880078","MATCH_ECIF":"3095268","MATCHED_CUSTOMER_NAME":"S DEIVARAJ","MATCHED_CUSTOMER_CODE":"CU0503174","MATCHED_SOURCE":"CFD","MATCHED_SCORE":"100","MATCHED_CRITERIA":"VOTERID100","CONFIDENCE_LEVEL":"1"}],"DtRECENTLEAD":[{"SOURCE_CIC_NO":"2022268275545880078","MATCHED_CIC_NO":"991102194599513090","MATCHED_LEAD_NAME":"DEIVARAJ S","MATCHED_LEAD_DATE":"12/15/2021 13:55:28","MATCHED_SCORE":"100","MATCHED_CRITERIA":"PAN100"}],"CustomerValidate":[{"CustomerCodeVal":"CU0503174","CustomerMaster":[{"Customer_Name":"S DEIVARAJ","Customer_Type":"10","Date_of_Birth":"27-06-1986 00:00:00","PAN_GIR_Number":"","Passport_Number":"","Voter_ID_Number":"CKK1913391","Driving_License_Number":"","Aadhaar_No":""}],"CustomerStatus":[{"Cross_Dedupe_Match_Id":"3095268","Active_Flag":"Z"}],"Dealstatus":[],"NPA":[],"Restructure":[{"Deal_Restructured":"No"}],"Gecl":[],"ARC":[],"PanAlert":[{"PAN":"COMPN4828K","Customer_Name":"Testing","Listing":"test","Remarks":"test","Source_Report_Date":"test"}],"CINAlert":[],"BeneficiaryAlert":{"Ben_code":null,"Beneficiary":null,"Status_Flag":null,"PAN_No":null}}]},"InternalDedupeResponse":[{"CustomerMaster":[{"CIC_No":"CU0503174","Matched_Customer_Code":"CU0503174","Rule_Matching_Fields":"VOTERID","Current_Parameter_Value":"CKK1913391","Matched_Parameter_Value":"CKK1913391","Matched_Score":"100","Rule_Field_Weightage":"100","Matched_Source":"CFD","Active_Flag":"Z","Dedupe_Super_Match":"Y","Dedupe_Super_Match_Score":"100","Rule_Id":"VOTERID100","Type":"C","PEP_Remarks":"","Customer_Name":null,"Customer_Type":null,"Date_of_Birth":null,"PAN_GIR_Number":null,"Passport_Number":null,"Voter_ID_Number":null,"Driving_License_Number":null,"Aadhaar_No":null},{"CIC_No":"CW3782547","Matched_Customer_Code":"CW3782547","Rule_Matching_Fields":"PAN","Current_Parameter_Value":"DMSPD9630N","Matched_Parameter_Value":"DMSPD9630N","Matched_Score":"100","Rule_Field_Weightage":"100","Matched_Source":"CFD","Active_Flag":"Y","Dedupe_Super_Match":"Y","Dedupe_Super_Match_Score":"100","Rule_Id":"PAN100","Type":"C","PEP_Remarks":"","Customer_Name":null,"Customer_Type":null,"Date_of_Birth":null,"PAN_GIR_Number":null,"Passport_Number":null,"Voter_ID_Number":null,"Driving_License_Number":null,"Aadhaar_No":null},{"CIC_No":"CW3782547","Matched_Customer_Code":"CW3782547","Rule_Matching_Fields":"VOTERID","Current_Parameter_Value":"CKK1913391","Matched_Parameter_Value":"CKK1913391","Matched_Score":"100","Rule_Field_Weightage":"100","Matched_Source":"CFD","Active_Flag":"Y","Dedupe_Super_Match":"Y","Dedupe_Super_Match_Score":"100","Rule_Id":"VOTERID100","Type":"C","PEP_Remarks":"","Customer_Name":null,"Customer_Type":null,"Date_of_Birth":null,"PAN_GIR_Number":null,"Passport_Number":null,"Voter_ID_Number":null,"Driving_License_Number":null,"Aadhaar_No":null},{"CIC_No":"CW4970396","Matched_Customer_Code":"CW4970396","Rule_Matching_Fields":"AADHAAR_NO","Current_Parameter_Value":"671940628725","Matched_Parameter_Value":"671940628725","Matched_Score":"100","Rule_Field_Weightage":"100","Matched_Source":"CFD","Active_Flag":"Y","Dedupe_Super_Match":"Y","Dedupe_Super_Match_Score":"100","Rule_Id":"ADHAR100","Type":"C","PEP_Remarks":"","Customer_Name":null,"Customer_Type":null,"Date_of_Birth":null,"PAN_GIR_Number":null,"Passport_Number":null,"Voter_ID_Number":null,"Driving_License_Number":null,"Aadhaar_No":null}],"CustomerValidate":[{"CustomerCodeVal":"CU0503174","CustomerMaster":[{"CIC_No":null,"Matched_Customer_Code":null,"Rule_Matching_Fields":null,"Current_Parameter_Value":null,"Matched_Parameter_Value":null,"Matched_Score":null,"Rule_Field_Weightage":null,"Matched_Source":null,"Active_Flag":null,"Dedupe_Super_Match":null,"Dedupe_Super_Match_Score":null,"Rule_Id":null,"Type":null,"PEP_Remarks":null,"Customer_Name":"S DEIVARAJ","Customer_Type":"10","Date_of_Birth":"27-06-1986 00:00:00","PAN_GIR_Number":"","Passport_Number":"","Voter_ID_Number":"CKK1913391","Driving_License_Number":"","Aadhaar_No":""}],"CustomerStatus":[{"Cross_Dedupe_Match_Id":"3095268","Active_Flag":"Z"}],"Dealstatus":[{"Deal_No":"TTU05950H","Status_Flag":"Z"}],"NPA":[],"Restructure":[{"Deal_Restructureds":"No"}],"Gecl":[],"ARC":[],"PanAlert":[{"PAN":"123"}],"CINAlert":[],"BeneficiaryAlert":{"Ben_code":null,"Beneficiary":null,"Status_Flag":null,"PAN_No":null}},{"CustomerCodeVal":"CW3782547","CustomerMaster":[{"CIC_No":null,"Matched_Customer_Code":null,"Rule_Matching_Fields":null,"Current_Parameter_Value":null,"Matched_Parameter_Value":null,"Matched_Score":null,"Rule_Field_Weightage":null,"Matched_Source":null,"Active_Flag":null,"Dedupe_Super_Match":null,"Dedupe_Super_Match_Score":null,"Rule_Id":null,"Type":null,"PEP_Remarks":null,"Customer_Name":"DEIVARAJ","Customer_Type":"10","Date_of_Birth":"27-06-1984 00:00:00","PAN_GIR_Number":"DMSPD9630N","Passport_Number":"","Voter_ID_Number":"CKK1913391","Driving_License_Number":"","Aadhaar_No":"916901617335"}],"CustomerStatus":[{"Cross_Dedupe_Match_Id":"59675453","Active_Flag":"Y"}],"Dealstatus":[{"Deal_No":"TNU05150H","Status_Flag":"Z"},{"Deal_No":"TTU01390S","Status_Flag":"L"}],"NPA":[],"Restructure":[{"Deal_Restructured":"Yes"}],"Gecl":[],"ARC":[],"PanAlert":[],"CINAlert":[],"BeneficiaryAlert":{"Ben_code":null,"Beneficiary":null,"Status_Flag":null,"PAN_No":null}},{"CustomerCodeVal":"CW3782547","CustomerMaster":[{"CIC_No":null,"Matched_Customer_Code":null,"Rule_Matching_Fields":null,"Current_Parameter_Value":null,"Matched_Parameter_Value":null,"Matched_Score":null,"Rule_Field_Weightage":null,"Matched_Source":null,"Active_Flag":null,"Dedupe_Super_Match":null,"Dedupe_Super_Match_Score":null,"Rule_Id":null,"Type":null,"PEP_Remarks":null,"Customer_Name":"DEIVARAJ","Customer_Type":"10","Date_of_Birth":"27-06-1984 00:00:00","PAN_GIR_Number":"DMSPD9630N","Passport_Number":"","Voter_ID_Number":"CKK1913391","Driving_License_Number":"","Aadhaar_No":"916901617335"}],"CustomerStatus":[{"Cross_Dedupe_Match_Id":"59675453","Active_Flag":"Y"}],"Dealstatus":[{"Deal_No":"TNU05150H","Status_Flag":"Z"},{"Deal_No":"TTU01390S","Status_Flag":"L"}],"NPA":[],"Restructure":[{"Deal_Restructured":"Yes"}],"Gecl":[],"ARC":[],"PanAlert":[],"CINAlert":[],"BeneficiaryAlert":{"Ben_code":null,"Beneficiary":null,"Status_Flag":null,"PAN_No":null}},{"CustomerCodeVal":"CW4970396","CustomerMaster":[{"CIC_No":null,"Matched_Customer_Code":null,"Rule_Matching_Fields":null,"Current_Parameter_Value":null,"Matched_Parameter_Value":null,"Matched_Score":null,"Rule_Field_Weightage":null,"Matched_Source":null,"Active_Flag":null,"Dedupe_Super_Match":null,"Dedupe_Super_Match_Score":null,"Rule_Id":null,"Type":null,"PEP_Remarks":null,"Customer_Name":"NAGALAXMI","Customer_Type":"10","Date_of_Birth":"25-03-1981 00:00:00","PAN_GIR_Number":"COMPN4828K","Passport_Number":"","Voter_ID_Number":"","Driving_License_Number":"","Aadhaar_No":"671940628725"}],"CustomerStatus":[{"Cross_Dedupe_Match_Id":"70765909","Active_Flag":"Y"}],"Dealstatus":[],"NPA":[],"Restructure":[{"Deal_Restructured":"Yes"}],"Gecl":[],"ARC":[],"PanAlert":[],"CINAlert":[],"BeneficiaryAlert":{"Ben_code":null,"Beneficiary":null,"Status_Flag":null,"PAN_No":null}}]}]},"ErrorDesc":""}]}}';
            insert cdr1;
            
            
            
            //cdp1.parse(Json.serialize(cdp1));
            ///   String sSelectedCustCode = cdp1.CustomerCodeVal;
            
            Set<String> ciSet = new Set<String>();
            ciSet.add('test');
            
            
            
            
            
            Ind_CustomerDedupCtrl.DedupeResponseWrapper drw1 = new Ind_CustomerDedupCtrl.DedupeResponseWrapper();
            drw1.SFCustomerDedupeFlag = 2.0;
            drw1.PGCustomerDedupeFlag = 3.0;
            drw1.externalDedupeAPIMaxAttempts = 5;
            //    drw1.cicNoSet = ciSet;
            drw1.isValid = true;
            //   drw1.isJourneySkipped = true;
            //     drw1.journeySkipReason = 'testone';
            //   drw1.journeyStopReason = 'testsolve';
            drw1.customerDedupeResponseObjId = 'testcust';
            drw1.message = 'tetsmsg';
            drw1.applicantType = 'testapp';
            drw1.leadNumber = 'tets123';
            drw1.customerName = 'testcust';
            drw1.customerCode = 'test123';
            drw1.invalidCustomerCode = 'testinvalid';
            drw1.response = 'testresponse';
            
            
            
            Test.startTest();
            Ind_CustomerDedupCtrl.validateCustomerCode(apvc1.Id,opvc1.Id, JSON.serialize(cdp1),'Co-borrower');
            Test.stopTest();
            
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }

    @isTest
    public static void validateCustomerCodeTest7(){
        
        try{
            Opportunity opvc1 = new Opportunity();
            opvc1.StageName = 'Qualification';
            opvc1.CloseDate = Date.newInstance(2021, 1, 11);
            opvc1.Name = 'testone';
            insert opvc1;
            
            
            
            Applicant__c apvc1 = new Applicant__c();
            apvc1.Opportunity__c = opvc1.Id;
            apvc1.Contact_number__c = '9743514830';
            apvc1.Applicant_Type__c = 'Borrower';
            insert apvc1;
            
            
            Ind_CustomerDedupCtrl.CustomerDetailsParser cdp1 = new Ind_CustomerDedupCtrl.CustomerDetailsParser();
            cdp1.Aadhaar_No = '987623415643';
            cdp1.CustomerCodeVal = 'CU0503174';
            cdp1.Customer_Name = 'test';
            cdp1.Customer_Type = 'tetstype';
            cdp1.Date_of_Birth = '23061994';
            cdp1.Driving_License_Number = '324556644';
            cdp1.PAN_GIR_Number = 'BSDRT7629K';
            cdp1.Passport_Number = '34567';
            cdp1.Voter_ID_Number = '567388336';
            cdp1.Rule_Matching_Fields = '567388336';
            cdp1.Matched_Score = '567388336';
            cdp1.Matched_Source = 'PAN';
            cdp1.Matched_Parameter_Value = '100';
            
            
            Ind_CustomerDedupCtrl.ReturnMessageWrapper returnMsgWrapper = new Ind_CustomerDedupCtrl.ReturnMessageWrapper();
            returnMsgWrapper.isSuccess = true;
            returnMsgWrapper.message = 'Success';
            returnMsgWrapper.cloneLoanApplicationId = 'test';
            returnMsgWrapper.cloneBorrowerApplicantId = 'tetstype';
            returnMsgWrapper.cloneCoBorrowerApplicantId = '23061994';
            
            //  cdp1.parse(Json.serialize(cdp1));
            Customer_Dedupe_Response__c cdr1 = new Customer_Dedupe_Response__c();
            cdr1.Applicant__c = apvc1.Id;
            cdr1.CIC_No__c = '545667';
            cdr1.CIN_No__c = '34455';
            cdr1.Response__c = '{"response":{"status":"SUCCESS","respDesc":"IxsightEnquiry","content":[{"Data":{"ExternalDedupeResponse":{"DEDUPE_STATUS":"M","DtCFDCUSTBAS":[{"SOURCE_CIC_NO":"2022268275545880078","MATCH_ECIF":"3095268","MATCHED_CUSTOMER_NAME":"S DEIVARAJ","MATCHED_CUSTOMER_CODE":"CU0503174","MATCHED_SOURCE":"CFD","MATCHED_SCORE":"100","MATCHED_CRITERIA":"VOTERID100","CONFIDENCE_LEVEL":"1"}],"DtRECENTLEAD":[{"SOURCE_CIC_NO":"2022268275545880078","MATCHED_CIC_NO":"991102194599513090","MATCHED_LEAD_NAME":"DEIVARAJ S","MATCHED_LEAD_DATE":"12/15/2021 13:55:28","MATCHED_SCORE":"100","MATCHED_CRITERIA":"PAN100"}],"CustomerValidate":[{"CustomerCodeVal":"CU0503174","CustomerMaster":[{"Customer_Name":"S DEIVARAJ","Customer_Type":"10","Date_of_Birth":"27-06-1986 00:00:00","PAN_GIR_Number":"","Passport_Number":"","Voter_ID_Number":"CKK1913391","Driving_License_Number":"","Aadhaar_No":""}],"CustomerStatus":[{"Cross_Dedupe_Match_Id":"3095268","Active_Flag":"Z"}],"Dealstatus":[],"NPA":[],"Restructure":[{"Deal_Restructured":"No"}],"Gecl":[],"ARC":[],"PanAlert":[],"CINAlert":[{"PAN": "COMPN4828K","Customer_Name": "Testing","Listing": "test","Remarks": "test","Source_Report_Date": "test"}],"BeneficiaryAlert":{"Ben_code":null,"Beneficiary":null,"Status_Flag":null,"PAN_No":null}}]},"InternalDedupeResponse":[{"CustomerMaster":[{"CIC_No":"CU0503174","Matched_Customer_Code":"CU0503174","Rule_Matching_Fields":"VOTERID","Current_Parameter_Value":"CKK1913391","Matched_Parameter_Value":"CKK1913391","Matched_Score":"100","Rule_Field_Weightage":"100","Matched_Source":"CFD","Active_Flag":"Z","Dedupe_Super_Match":"Y","Dedupe_Super_Match_Score":"100","Rule_Id":"VOTERID100","Type":"C","PEP_Remarks":"","Customer_Name":null,"Customer_Type":null,"Date_of_Birth":null,"PAN_GIR_Number":null,"Passport_Number":null,"Voter_ID_Number":null,"Driving_License_Number":null,"Aadhaar_No":null},{"CIC_No":"CW3782547","Matched_Customer_Code":"CW3782547","Rule_Matching_Fields":"PAN","Current_Parameter_Value":"DMSPD9630N","Matched_Parameter_Value":"DMSPD9630N","Matched_Score":"100","Rule_Field_Weightage":"100","Matched_Source":"CFD","Active_Flag":"Y","Dedupe_Super_Match":"Y","Dedupe_Super_Match_Score":"100","Rule_Id":"PAN100","Type":"C","PEP_Remarks":"","Customer_Name":null,"Customer_Type":null,"Date_of_Birth":null,"PAN_GIR_Number":null,"Passport_Number":null,"Voter_ID_Number":null,"Driving_License_Number":null,"Aadhaar_No":null},{"CIC_No":"CW3782547","Matched_Customer_Code":"CW3782547","Rule_Matching_Fields":"VOTERID","Current_Parameter_Value":"CKK1913391","Matched_Parameter_Value":"CKK1913391","Matched_Score":"100","Rule_Field_Weightage":"100","Matched_Source":"CFD","Active_Flag":"Y","Dedupe_Super_Match":"Y","Dedupe_Super_Match_Score":"100","Rule_Id":"VOTERID100","Type":"C","PEP_Remarks":"","Customer_Name":null,"Customer_Type":null,"Date_of_Birth":null,"PAN_GIR_Number":null,"Passport_Number":null,"Voter_ID_Number":null,"Driving_License_Number":null,"Aadhaar_No":null},{"CIC_No":"CW4970396","Matched_Customer_Code":"CW4970396","Rule_Matching_Fields":"AADHAAR_NO","Current_Parameter_Value":"671940628725","Matched_Parameter_Value":"671940628725","Matched_Score":"100","Rule_Field_Weightage":"100","Matched_Source":"CFD","Active_Flag":"Y","Dedupe_Super_Match":"Y","Dedupe_Super_Match_Score":"100","Rule_Id":"ADHAR100","Type":"C","PEP_Remarks":"","Customer_Name":null,"Customer_Type":null,"Date_of_Birth":null,"PAN_GIR_Number":null,"Passport_Number":null,"Voter_ID_Number":null,"Driving_License_Number":null,"Aadhaar_No":null}],"CustomerValidate":[{"CustomerCodeVal":"CU0503174","CustomerMaster":[{"CIC_No":null,"Matched_Customer_Code":null,"Rule_Matching_Fields":null,"Current_Parameter_Value":null,"Matched_Parameter_Value":null,"Matched_Score":null,"Rule_Field_Weightage":null,"Matched_Source":null,"Active_Flag":null,"Dedupe_Super_Match":null,"Dedupe_Super_Match_Score":null,"Rule_Id":null,"Type":null,"PEP_Remarks":null,"Customer_Name":"S DEIVARAJ","Customer_Type":"10","Date_of_Birth":"27-06-1986 00:00:00","PAN_GIR_Number":"","Passport_Number":"","Voter_ID_Number":"CKK1913391","Driving_License_Number":"","Aadhaar_No":""}],"CustomerStatus":[{"Cross_Dedupe_Match_Id":"3095268","Active_Flag":"Z"}],"Dealstatus":[{"Deal_No":"TTU05950H","Status_Flag":"Z"}],"NPA":[],"Restructure":[{"Deal_Restructureds":"No"}],"Gecl":[],"ARC":[],"PanAlert":[],"CINAlert":[],"BeneficiaryAlert":{"Ben_code":null,"Beneficiary":null,"Status_Flag":null,"PAN_No":null}},{"CustomerCodeVal":"CW3782547","CustomerMaster":[{"CIC_No":null,"Matched_Customer_Code":null,"Rule_Matching_Fields":null,"Current_Parameter_Value":null,"Matched_Parameter_Value":null,"Matched_Score":null,"Rule_Field_Weightage":null,"Matched_Source":null,"Active_Flag":null,"Dedupe_Super_Match":null,"Dedupe_Super_Match_Score":null,"Rule_Id":null,"Type":null,"PEP_Remarks":null,"Customer_Name":"DEIVARAJ","Customer_Type":"10","Date_of_Birth":"27-06-1984 00:00:00","PAN_GIR_Number":"DMSPD9630N","Passport_Number":"","Voter_ID_Number":"CKK1913391","Driving_License_Number":"","Aadhaar_No":"916901617335"}],"CustomerStatus":[{"Cross_Dedupe_Match_Id":"59675453","Active_Flag":"Y"}],"Dealstatus":[{"Deal_No":"TNU05150H","Status_Flag":"Z"},{"Deal_No":"TTU01390S","Status_Flag":"L"}],"NPA":[],"Restructure":[{"Deal_Restructured":"Yes"}],"Gecl":[],"ARC":[],"PanAlert":[],"CINAlert":[],"BeneficiaryAlert":{"Ben_code":null,"Beneficiary":null,"Status_Flag":null,"PAN_No":null}},{"CustomerCodeVal":"CW3782547","CustomerMaster":[{"CIC_No":null,"Matched_Customer_Code":null,"Rule_Matching_Fields":null,"Current_Parameter_Value":null,"Matched_Parameter_Value":null,"Matched_Score":null,"Rule_Field_Weightage":null,"Matched_Source":null,"Active_Flag":null,"Dedupe_Super_Match":null,"Dedupe_Super_Match_Score":null,"Rule_Id":null,"Type":null,"PEP_Remarks":null,"Customer_Name":"DEIVARAJ","Customer_Type":"10","Date_of_Birth":"27-06-1984 00:00:00","PAN_GIR_Number":"DMSPD9630N","Passport_Number":"","Voter_ID_Number":"CKK1913391","Driving_License_Number":"","Aadhaar_No":"916901617335"}],"CustomerStatus":[{"Cross_Dedupe_Match_Id":"59675453","Active_Flag":"Y"}],"Dealstatus":[{"Deal_No":"TNU05150H","Status_Flag":"Z"},{"Deal_No":"TTU01390S","Status_Flag":"L"}],"NPA":[],"Restructure":[{"Deal_Restructured":"Yes"}],"Gecl":[],"ARC":[],"PanAlert":[],"CINAlert":[],"BeneficiaryAlert":{"Ben_code":null,"Beneficiary":null,"Status_Flag":null,"PAN_No":null}},{"CustomerCodeVal":"CW4970396","CustomerMaster":[{"CIC_No":null,"Matched_Customer_Code":null,"Rule_Matching_Fields":null,"Current_Parameter_Value":null,"Matched_Parameter_Value":null,"Matched_Score":null,"Rule_Field_Weightage":null,"Matched_Source":null,"Active_Flag":null,"Dedupe_Super_Match":null,"Dedupe_Super_Match_Score":null,"Rule_Id":null,"Type":null,"PEP_Remarks":null,"Customer_Name":"NAGALAXMI","Customer_Type":"10","Date_of_Birth":"25-03-1981 00:00:00","PAN_GIR_Number":"COMPN4828K","Passport_Number":"","Voter_ID_Number":"","Driving_License_Number":"","Aadhaar_No":"671940628725"}],"CustomerStatus":[{"Cross_Dedupe_Match_Id":"70765909","Active_Flag":"Y"}],"Dealstatus":[],"NPA":[],"Restructure":[{"Deal_Restructured":"Yes"}],"Gecl":[],"ARC":[],"PanAlert":[],"CINAlert":[],"BeneficiaryAlert":{"Ben_code":null,"Beneficiary":null,"Status_Flag":null,"PAN_No":null}}]}]},"ErrorDesc":""}]}}';
            insert cdr1;
            
            
            
            //cdp1.parse(Json.serialize(cdp1));
            ///   String sSelectedCustCode = cdp1.CustomerCodeVal;
            
            Set<String> ciSet = new Set<String>();
            ciSet.add('test');
            
            
            
            
            
            Ind_CustomerDedupCtrl.DedupeResponseWrapper drw1 = new Ind_CustomerDedupCtrl.DedupeResponseWrapper();
            drw1.SFCustomerDedupeFlag = 2.0;
            drw1.PGCustomerDedupeFlag = 3.0;
            drw1.externalDedupeAPIMaxAttempts = 5;
            //    drw1.cicNoSet = ciSet;
            drw1.isValid = true;
            //   drw1.isJourneySkipped = true;
            //     drw1.journeySkipReason = 'testone';
            //   drw1.journeyStopReason = 'testsolve';
            drw1.customerDedupeResponseObjId = 'testcust';
            drw1.message = 'tetsmsg';
            drw1.applicantType = 'testapp';
            drw1.leadNumber = 'tets123';
            drw1.customerName = 'testcust';
            drw1.customerCode = 'test123';
            drw1.invalidCustomerCode = 'testinvalid';
            drw1.response = 'testresponse';
            
            
            
            Test.startTest();
            Ind_CustomerDedupCtrl.validateCustomerCode(apvc1.Id,opvc1.Id, JSON.serialize(cdp1),'Co-borrower');
            Test.stopTest();
            
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }

    @isTest
    public static void validateCustomerCodeTest8(){
        
        try{
            Opportunity opvc1 = new Opportunity();
            opvc1.StageName = 'Qualification';
            opvc1.CloseDate = Date.newInstance(2021, 1, 11);
            opvc1.Name = 'testone';
            insert opvc1;
            
            
            
            Applicant__c apvc1 = new Applicant__c();
            apvc1.Opportunity__c = opvc1.Id;
            apvc1.Contact_number__c = '9743514830';
            apvc1.Applicant_Type__c = 'Borrower';
            insert apvc1;
            
            
            Ind_CustomerDedupCtrl.CustomerDetailsParser cdp1 = new Ind_CustomerDedupCtrl.CustomerDetailsParser();
            cdp1.Aadhaar_No = '987623415643';
            cdp1.CustomerCodeVal = 'CU0503174';
            cdp1.Customer_Name = 'test';
            cdp1.Customer_Type = 'tetstype';
            cdp1.Date_of_Birth = '23061994';
            cdp1.Driving_License_Number = '324556644';
            cdp1.PAN_GIR_Number = 'BSDRT7629K';
            cdp1.Passport_Number = '34567';
            cdp1.Voter_ID_Number = '567388336';
            cdp1.Rule_Matching_Fields = '567388336';
            cdp1.Matched_Score = '567388336';
            cdp1.Matched_Source = 'PAN';
            cdp1.Matched_Parameter_Value = '100';
            
            
            Ind_CustomerDedupCtrl.ReturnMessageWrapper returnMsgWrapper = new Ind_CustomerDedupCtrl.ReturnMessageWrapper();
            returnMsgWrapper.isSuccess = true;
            returnMsgWrapper.message = 'Success';
            returnMsgWrapper.cloneLoanApplicationId = 'test';
            returnMsgWrapper.cloneBorrowerApplicantId = 'tetstype';
            returnMsgWrapper.cloneCoBorrowerApplicantId = '23061994';
            
            //  cdp1.parse(Json.serialize(cdp1));
            Customer_Dedupe_Response__c cdr1 = new Customer_Dedupe_Response__c();
            cdr1.Applicant__c = apvc1.Id;
            cdr1.CIC_No__c = '545667';
            cdr1.CIN_No__c = '34455';
            cdr1.Response__c = '{"response":{"status":"SUCCESS","respDesc":"IxsightEnquiry","content":[{"Data":{"ExternalDedupeResponse":{"DEDUPE_STATUS":"M","DtCFDCUSTBAS":[{"SOURCE_CIC_NO":"2022268275545880078","MATCH_ECIF":"3095268","MATCHED_CUSTOMER_NAME":"S DEIVARAJ","MATCHED_CUSTOMER_CODE":"CU0503174","MATCHED_SOURCE":"CFD","MATCHED_SCORE":"100","MATCHED_CRITERIA":"VOTERID100","CONFIDENCE_LEVEL":"1"}],"DtRECENTLEAD":[{"SOURCE_CIC_NO":"2022268275545880078","MATCHED_CIC_NO":"991102194599513090","MATCHED_LEAD_NAME":"DEIVARAJ S","MATCHED_LEAD_DATE":"12/15/2021 13:55:28","MATCHED_SCORE":"100","MATCHED_CRITERIA":"PAN100"}],"CustomerValidate":[{"CustomerCodeVal":"CU0503174","CustomerMaster":[{"Customer_Name":"S DEIVARAJ","Customer_Type":"10","Date_of_Birth":"27-06-1986 00:00:00","PAN_GIR_Number":"","Passport_Number":"","Voter_ID_Number":"CKK1913391","Driving_License_Number":"","Aadhaar_No":""}],"CustomerStatus":[{"Cross_Dedupe_Match_Id":"3095268","Active_Flag":"Z"}],"Dealstatus":[],"NPA":[],"Restructure":[{"Deal_Restructured":"No"}],"Gecl":[],"ARC":[{"Deal_No": "A1H99999","ARC_Reference_No": "Testing","ARC_Buyer_Name": "test","ARC_Sale_Date": "test"}],"PanAlert":[],"CINAlert":[],"BeneficiaryAlert":{"Ben_code":null,"Beneficiary":null,"Status_Flag":null,"PAN_No":null}}]},"InternalDedupeResponse":[{"CustomerMaster":[{"CIC_No":"CU0503174","Matched_Customer_Code":"CU0503174","Rule_Matching_Fields":"VOTERID","Current_Parameter_Value":"CKK1913391","Matched_Parameter_Value":"CKK1913391","Matched_Score":"100","Rule_Field_Weightage":"100","Matched_Source":"CFD","Active_Flag":"Z","Dedupe_Super_Match":"Y","Dedupe_Super_Match_Score":"100","Rule_Id":"VOTERID100","Type":"C","PEP_Remarks":"","Customer_Name":null,"Customer_Type":null,"Date_of_Birth":null,"PAN_GIR_Number":null,"Passport_Number":null,"Voter_ID_Number":null,"Driving_License_Number":null,"Aadhaar_No":null},{"CIC_No":"CW3782547","Matched_Customer_Code":"CW3782547","Rule_Matching_Fields":"PAN","Current_Parameter_Value":"DMSPD9630N","Matched_Parameter_Value":"DMSPD9630N","Matched_Score":"100","Rule_Field_Weightage":"100","Matched_Source":"CFD","Active_Flag":"Y","Dedupe_Super_Match":"Y","Dedupe_Super_Match_Score":"100","Rule_Id":"PAN100","Type":"C","PEP_Remarks":"","Customer_Name":null,"Customer_Type":null,"Date_of_Birth":null,"PAN_GIR_Number":null,"Passport_Number":null,"Voter_ID_Number":null,"Driving_License_Number":null,"Aadhaar_No":null},{"CIC_No":"CW3782547","Matched_Customer_Code":"CW3782547","Rule_Matching_Fields":"VOTERID","Current_Parameter_Value":"CKK1913391","Matched_Parameter_Value":"CKK1913391","Matched_Score":"100","Rule_Field_Weightage":"100","Matched_Source":"CFD","Active_Flag":"Y","Dedupe_Super_Match":"Y","Dedupe_Super_Match_Score":"100","Rule_Id":"VOTERID100","Type":"C","PEP_Remarks":"","Customer_Name":null,"Customer_Type":null,"Date_of_Birth":null,"PAN_GIR_Number":null,"Passport_Number":null,"Voter_ID_Number":null,"Driving_License_Number":null,"Aadhaar_No":null},{"CIC_No":"CW4970396","Matched_Customer_Code":"CW4970396","Rule_Matching_Fields":"AADHAAR_NO","Current_Parameter_Value":"671940628725","Matched_Parameter_Value":"671940628725","Matched_Score":"100","Rule_Field_Weightage":"100","Matched_Source":"CFD","Active_Flag":"Y","Dedupe_Super_Match":"Y","Dedupe_Super_Match_Score":"100","Rule_Id":"ADHAR100","Type":"C","PEP_Remarks":"","Customer_Name":null,"Customer_Type":null,"Date_of_Birth":null,"PAN_GIR_Number":null,"Passport_Number":null,"Voter_ID_Number":null,"Driving_License_Number":null,"Aadhaar_No":null}],"CustomerValidate":[{"CustomerCodeVal":"CU0503174","CustomerMaster":[{"CIC_No":null,"Matched_Customer_Code":null,"Rule_Matching_Fields":null,"Current_Parameter_Value":null,"Matched_Parameter_Value":null,"Matched_Score":null,"Rule_Field_Weightage":null,"Matched_Source":null,"Active_Flag":null,"Dedupe_Super_Match":null,"Dedupe_Super_Match_Score":null,"Rule_Id":null,"Type":null,"PEP_Remarks":null,"Customer_Name":"S DEIVARAJ","Customer_Type":"10","Date_of_Birth":"27-06-1986 00:00:00","PAN_GIR_Number":"","Passport_Number":"","Voter_ID_Number":"CKK1913391","Driving_License_Number":"","Aadhaar_No":""}],"CustomerStatus":[{"Cross_Dedupe_Match_Id":"3095268","Active_Flag":"Z"}],"Dealstatus":[{"Deal_No":"TTU05950H","Status_Flag":"Z"}],"NPA":[],"Restructure":[{"Deal_Restructureds":"No"}],"Gecl":[],"ARC":[],"PanAlert":[],"CINAlert":[],"BeneficiaryAlert":{"Ben_code":null,"Beneficiary":null,"Status_Flag":null,"PAN_No":null}},{"CustomerCodeVal":"CW3782547","CustomerMaster":[{"CIC_No":null,"Matched_Customer_Code":null,"Rule_Matching_Fields":null,"Current_Parameter_Value":null,"Matched_Parameter_Value":null,"Matched_Score":null,"Rule_Field_Weightage":null,"Matched_Source":null,"Active_Flag":null,"Dedupe_Super_Match":null,"Dedupe_Super_Match_Score":null,"Rule_Id":null,"Type":null,"PEP_Remarks":null,"Customer_Name":"DEIVARAJ","Customer_Type":"10","Date_of_Birth":"27-06-1984 00:00:00","PAN_GIR_Number":"DMSPD9630N","Passport_Number":"","Voter_ID_Number":"CKK1913391","Driving_License_Number":"","Aadhaar_No":"916901617335"}],"CustomerStatus":[{"Cross_Dedupe_Match_Id":"59675453","Active_Flag":"Y"}],"Dealstatus":[{"Deal_No":"TNU05150H","Status_Flag":"Z"},{"Deal_No":"TTU01390S","Status_Flag":"L"}],"NPA":[],"Restructure":[{"Deal_Restructured":"Yes"}],"Gecl":[],"ARC":[],"PanAlert":[],"CINAlert":[],"BeneficiaryAlert":{"Ben_code":null,"Beneficiary":null,"Status_Flag":null,"PAN_No":null}},{"CustomerCodeVal":"CW3782547","CustomerMaster":[{"CIC_No":null,"Matched_Customer_Code":null,"Rule_Matching_Fields":null,"Current_Parameter_Value":null,"Matched_Parameter_Value":null,"Matched_Score":null,"Rule_Field_Weightage":null,"Matched_Source":null,"Active_Flag":null,"Dedupe_Super_Match":null,"Dedupe_Super_Match_Score":null,"Rule_Id":null,"Type":null,"PEP_Remarks":null,"Customer_Name":"DEIVARAJ","Customer_Type":"10","Date_of_Birth":"27-06-1984 00:00:00","PAN_GIR_Number":"DMSPD9630N","Passport_Number":"","Voter_ID_Number":"CKK1913391","Driving_License_Number":"","Aadhaar_No":"916901617335"}],"CustomerStatus":[{"Cross_Dedupe_Match_Id":"59675453","Active_Flag":"Y"}],"Dealstatus":[{"Deal_No":"TNU05150H","Status_Flag":"Z"},{"Deal_No":"TTU01390S","Status_Flag":"L"}],"NPA":[],"Restructure":[{"Deal_Restructured":"Yes"}],"Gecl":[],"ARC":[],"PanAlert":[],"CINAlert":[],"BeneficiaryAlert":{"Ben_code":null,"Beneficiary":null,"Status_Flag":null,"PAN_No":null}},{"CustomerCodeVal":"CW4970396","CustomerMaster":[{"CIC_No":null,"Matched_Customer_Code":null,"Rule_Matching_Fields":null,"Current_Parameter_Value":null,"Matched_Parameter_Value":null,"Matched_Score":null,"Rule_Field_Weightage":null,"Matched_Source":null,"Active_Flag":null,"Dedupe_Super_Match":null,"Dedupe_Super_Match_Score":null,"Rule_Id":null,"Type":null,"PEP_Remarks":null,"Customer_Name":"NAGALAXMI","Customer_Type":"10","Date_of_Birth":"25-03-1981 00:00:00","PAN_GIR_Number":"COMPN4828K","Passport_Number":"","Voter_ID_Number":"","Driving_License_Number":"","Aadhaar_No":"671940628725"}],"CustomerStatus":[{"Cross_Dedupe_Match_Id":"70765909","Active_Flag":"Y"}],"Dealstatus":[],"NPA":[],"Restructure":[{"Deal_Restructured":"Yes"}],"Gecl":[],"ARC":[],"PanAlert":[],"CINAlert":[],"BeneficiaryAlert":{"Ben_code":null,"Beneficiary":null,"Status_Flag":null,"PAN_No":null}}]}]},"ErrorDesc":""}]}}';
            insert cdr1;
            
            
            
            //cdp1.parse(Json.serialize(cdp1));
            ///   String sSelectedCustCode = cdp1.CustomerCodeVal;
            
            Set<String> ciSet = new Set<String>();
            ciSet.add('test');
            
            
            
            
            
            Ind_CustomerDedupCtrl.DedupeResponseWrapper drw1 = new Ind_CustomerDedupCtrl.DedupeResponseWrapper();
            drw1.SFCustomerDedupeFlag = 2.0;
            drw1.PGCustomerDedupeFlag = 3.0;
            drw1.externalDedupeAPIMaxAttempts = 5;
            //    drw1.cicNoSet = ciSet;
            drw1.isValid = true;
            //   drw1.isJourneySkipped = true;
            //     drw1.journeySkipReason = 'testone';
            //   drw1.journeyStopReason = 'testsolve';
            drw1.customerDedupeResponseObjId = 'testcust';
            drw1.message = 'tetsmsg';
            drw1.applicantType = 'testapp';
            drw1.leadNumber = 'tets123';
            drw1.customerName = 'testcust';
            drw1.customerCode = 'test123';
            drw1.invalidCustomerCode = 'testinvalid';
            drw1.response = 'testresponse';
            
            
            
            Test.startTest();
            Ind_CustomerDedupCtrl.validateCustomerCode(apvc1.Id,opvc1.Id, JSON.serialize(cdp1),'Co-borrower');
            Test.stopTest();
            
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }

    @isTest
    public static void validateCustomerCodeTest9(){
        
        try{
            Opportunity opvc1 = new Opportunity();
            opvc1.StageName = 'Qualification';
            opvc1.CloseDate = Date.newInstance(2021, 1, 11);
            opvc1.Vehicle_Type__c='Refinance';
            opvc1.Name = 'testone';
            insert opvc1;
            
            
            
            Applicant__c apvc1 = new Applicant__c();
            apvc1.Opportunity__c = opvc1.Id;
            apvc1.Contact_number__c = '9743514830';
            apvc1.Applicant_Type__c = 'Borrower';
            insert apvc1;
            
            
            Ind_CustomerDedupCtrl.CustomerDetailsParser cdp1 = new Ind_CustomerDedupCtrl.CustomerDetailsParser();
            cdp1.Aadhaar_No = '987623415643';
            cdp1.CustomerCodeVal = 'CU0503174';
            cdp1.Customer_Name = 'test';
            cdp1.Customer_Type = 'tetstype';
            cdp1.Date_of_Birth = '23061994';
            cdp1.Driving_License_Number = '324556644';
            cdp1.PAN_GIR_Number = 'BSDRT7629K';
            cdp1.Passport_Number = '34567';
            cdp1.Voter_ID_Number = '567388336';
            cdp1.Rule_Matching_Fields = '567388336';
            cdp1.Matched_Score = '567388336';
            cdp1.Matched_Source = 'PAN';
            cdp1.Matched_Parameter_Value = '100';
            
            
            Ind_CustomerDedupCtrl.ReturnMessageWrapper returnMsgWrapper = new Ind_CustomerDedupCtrl.ReturnMessageWrapper();
            returnMsgWrapper.isSuccess = true;
            returnMsgWrapper.message = 'Success';
            returnMsgWrapper.cloneLoanApplicationId = 'test';
            returnMsgWrapper.cloneBorrowerApplicantId = 'tetstype';
            returnMsgWrapper.cloneCoBorrowerApplicantId = '23061994';
            
            //  cdp1.parse(Json.serialize(cdp1));
            Customer_Dedupe_Response__c cdr1 = new Customer_Dedupe_Response__c();
            cdr1.Applicant__c = apvc1.Id;
            cdr1.CIC_No__c = '545667';
            cdr1.CIN_No__c = '34455';
            cdr1.Response__c ='{"response":{"status":"SUCCESS","respDesc":"IxsightEnquiry","content":[{"Data":{"ExternalDedupeResponse":{"DEDUPE_STATUS":"M","DtCFDCUSTBAS":[{"SOURCE_CIC_NO":"2022268275545880078","MATCH_ECIF":"3095268","MATCHED_CUSTOMER_NAME":"S DEIVARAJ","MATCHED_CUSTOMER_CODE":"CU0503174","MATCHED_SOURCE":"CFD","MATCHED_SCORE":"100","MATCHED_CRITERIA":"VOTERID100","CONFIDENCE_LEVEL":"1"}],"DtRECENTLEAD":[{"SOURCE_CIC_NO":"2022268275545880078","MATCHED_CIC_NO":"991102194599513090","MATCHED_LEAD_NAME":"DEIVARAJ S","MATCHED_LEAD_DATE":"12/15/2021 13:55:28","MATCHED_SCORE":"100","MATCHED_CRITERIA":"PAN100"}],"CustomerValidate":[{"CustomerCodeVal":"CU0503174","CustomerMaster":[{"Customer_Name":"S DEIVARAJ","Customer_Type":"10","Date_of_Birth":"27-06-1986 00:00:00","PAN_GIR_Number":"","Passport_Number":"","Voter_ID_Number":"CKK1913391","Driving_License_Number":"","Aadhaar_No":""}],"CustomerStatus":[{"Cross_Dedupe_Match_Id":"3095268","Active_Flag":"Z"}],"Dealstatus":[],"NPA":[],"Restructure":[{"Deal_Restructured":"No"}],"Gecl":[{"Deal_No": "A1H99999","Status_Flag": "Y"}],"ARC":[],"PanAlert":[],"CINAlert":[],"BeneficiaryAlert":{"Ben_code":null,"Beneficiary":null,"Status_Flag":null,"PAN_No":null}}]},"InternalDedupeResponse":[{"CustomerMaster":[{"CIC_No":"CU0503174","Matched_Customer_Code":"CU0503174","Rule_Matching_Fields":"VOTERID","Current_Parameter_Value":"CKK1913391","Matched_Parameter_Value":"CKK1913391","Matched_Score":"100","Rule_Field_Weightage":"100","Matched_Source":"CFD","Active_Flag":"Z","Dedupe_Super_Match":"Y","Dedupe_Super_Match_Score":"100","Rule_Id":"VOTERID100","Type":"C","PEP_Remarks":"","Customer_Name":null,"Customer_Type":null,"Date_of_Birth":null,"PAN_GIR_Number":null,"Passport_Number":null,"Voter_ID_Number":null,"Driving_License_Number":null,"Aadhaar_No":null},{"CIC_No":"CW3782547","Matched_Customer_Code":"CW3782547","Rule_Matching_Fields":"PAN","Current_Parameter_Value":"DMSPD9630N","Matched_Parameter_Value":"DMSPD9630N","Matched_Score":"100","Rule_Field_Weightage":"100","Matched_Source":"CFD","Active_Flag":"Y","Dedupe_Super_Match":"Y","Dedupe_Super_Match_Score":"100","Rule_Id":"PAN100","Type":"C","PEP_Remarks":"","Customer_Name":null,"Customer_Type":null,"Date_of_Birth":null,"PAN_GIR_Number":null,"Passport_Number":null,"Voter_ID_Number":null,"Driving_License_Number":null,"Aadhaar_No":null},{"CIC_No":"CW3782547","Matched_Customer_Code":"CW3782547","Rule_Matching_Fields":"VOTERID","Current_Parameter_Value":"CKK1913391","Matched_Parameter_Value":"CKK1913391","Matched_Score":"100","Rule_Field_Weightage":"100","Matched_Source":"CFD","Active_Flag":"Y","Dedupe_Super_Match":"Y","Dedupe_Super_Match_Score":"100","Rule_Id":"VOTERID100","Type":"C","PEP_Remarks":"","Customer_Name":null,"Customer_Type":null,"Date_of_Birth":null,"PAN_GIR_Number":null,"Passport_Number":null,"Voter_ID_Number":null,"Driving_License_Number":null,"Aadhaar_No":null},{"CIC_No":"CW4970396","Matched_Customer_Code":"CW4970396","Rule_Matching_Fields":"AADHAAR_NO","Current_Parameter_Value":"671940628725","Matched_Parameter_Value":"671940628725","Matched_Score":"100","Rule_Field_Weightage":"100","Matched_Source":"CFD","Active_Flag":"Y","Dedupe_Super_Match":"Y","Dedupe_Super_Match_Score":"100","Rule_Id":"ADHAR100","Type":"C","PEP_Remarks":"","Customer_Name":null,"Customer_Type":null,"Date_of_Birth":null,"PAN_GIR_Number":null,"Passport_Number":null,"Voter_ID_Number":null,"Driving_License_Number":null,"Aadhaar_No":null}],"CustomerValidate":[{"CustomerCodeVal":"CU0503174","CustomerMaster":[{"CIC_No":null,"Matched_Customer_Code":null,"Rule_Matching_Fields":null,"Current_Parameter_Value":null,"Matched_Parameter_Value":null,"Matched_Score":null,"Rule_Field_Weightage":null,"Matched_Source":null,"Active_Flag":null,"Dedupe_Super_Match":null,"Dedupe_Super_Match_Score":null,"Rule_Id":null,"Type":null,"PEP_Remarks":null,"Customer_Name":"S DEIVARAJ","Customer_Type":"10","Date_of_Birth":"27-06-1986 00:00:00","PAN_GIR_Number":"","Passport_Number":"","Voter_ID_Number":"CKK1913391","Driving_License_Number":"","Aadhaar_No":""}],"CustomerStatus":[{"Cross_Dedupe_Match_Id":"3095268","Active_Flag":"Z"}],"Dealstatus":[{"Deal_No":"TTU05950H","Status_Flag":"Z"}],"NPA":[],"Restructure":[{"Deal_Restructureds":"No"}],"Gecl":[],"ARC":[],"PanAlert":[],"CINAlert":[],"BeneficiaryAlert":{"Ben_code":null,"Beneficiary":null,"Status_Flag":null,"PAN_No":null}},{"CustomerCodeVal":"CW3782547","CustomerMaster":[{"CIC_No":null,"Matched_Customer_Code":null,"Rule_Matching_Fields":null,"Current_Parameter_Value":null,"Matched_Parameter_Value":null,"Matched_Score":null,"Rule_Field_Weightage":null,"Matched_Source":null,"Active_Flag":null,"Dedupe_Super_Match":null,"Dedupe_Super_Match_Score":null,"Rule_Id":null,"Type":null,"PEP_Remarks":null,"Customer_Name":"DEIVARAJ","Customer_Type":"10","Date_of_Birth":"27-06-1984 00:00:00","PAN_GIR_Number":"DMSPD9630N","Passport_Number":"","Voter_ID_Number":"CKK1913391","Driving_License_Number":"","Aadhaar_No":"916901617335"}],"CustomerStatus":[{"Cross_Dedupe_Match_Id":"59675453","Active_Flag":"Y"}],"Dealstatus":[{"Deal_No":"TNU05150H","Status_Flag":"Z"},{"Deal_No":"TTU01390S","Status_Flag":"L"}],"NPA":[],"Restructure":[{"Deal_Restructured":"Yes"}],"Gecl":[],"ARC":[],"PanAlert":[],"CINAlert":[],"BeneficiaryAlert":{"Ben_code":null,"Beneficiary":null,"Status_Flag":null,"PAN_No":null}},{"CustomerCodeVal":"CW3782547","CustomerMaster":[{"CIC_No":null,"Matched_Customer_Code":null,"Rule_Matching_Fields":null,"Current_Parameter_Value":null,"Matched_Parameter_Value":null,"Matched_Score":null,"Rule_Field_Weightage":null,"Matched_Source":null,"Active_Flag":null,"Dedupe_Super_Match":null,"Dedupe_Super_Match_Score":null,"Rule_Id":null,"Type":null,"PEP_Remarks":null,"Customer_Name":"DEIVARAJ","Customer_Type":"10","Date_of_Birth":"27-06-1984 00:00:00","PAN_GIR_Number":"DMSPD9630N","Passport_Number":"","Voter_ID_Number":"CKK1913391","Driving_License_Number":"","Aadhaar_No":"916901617335"}],"CustomerStatus":[{"Cross_Dedupe_Match_Id":"59675453","Active_Flag":"Y"}],"Dealstatus":[{"Deal_No":"TNU05150H","Status_Flag":"Z"},{"Deal_No":"TTU01390S","Status_Flag":"L"}],"NPA":[],"Restructure":[{"Deal_Restructured":"Yes"}],"Gecl":[],"ARC":[],"PanAlert":[],"CINAlert":[],"BeneficiaryAlert":{"Ben_code":null,"Beneficiary":null,"Status_Flag":null,"PAN_No":null}},{"CustomerCodeVal":"CW4970396","CustomerMaster":[{"CIC_No":null,"Matched_Customer_Code":null,"Rule_Matching_Fields":null,"Current_Parameter_Value":null,"Matched_Parameter_Value":null,"Matched_Score":null,"Rule_Field_Weightage":null,"Matched_Source":null,"Active_Flag":null,"Dedupe_Super_Match":null,"Dedupe_Super_Match_Score":null,"Rule_Id":null,"Type":null,"PEP_Remarks":null,"Customer_Name":"NAGALAXMI","Customer_Type":"10","Date_of_Birth":"25-03-1981 00:00:00","PAN_GIR_Number":"COMPN4828K","Passport_Number":"","Voter_ID_Number":"","Driving_License_Number":"","Aadhaar_No":"671940628725"}],"CustomerStatus":[{"Cross_Dedupe_Match_Id":"70765909","Active_Flag":"Y"}],"Dealstatus":[],"NPA":[],"Restructure":[{"Deal_Restructured":"Yes"}],"Gecl":[],"ARC":[],"PanAlert":[],"CINAlert":[],"BeneficiaryAlert":{"Ben_code":null,"Beneficiary":null,"Status_Flag":null,"PAN_No":null}}]}]},"ErrorDesc":""}]}}';
            insert cdr1;
            
            
            
            //cdp1.parse(Json.serialize(cdp1));
            ///   String sSelectedCustCode = cdp1.CustomerCodeVal;
            
            Set<String> ciSet = new Set<String>();
            ciSet.add('test');
            
            
            
            
            
            Ind_CustomerDedupCtrl.DedupeResponseWrapper drw1 = new Ind_CustomerDedupCtrl.DedupeResponseWrapper();
            drw1.SFCustomerDedupeFlag = 2.0;
            drw1.PGCustomerDedupeFlag = 3.0;
            drw1.externalDedupeAPIMaxAttempts = 5;
            //    drw1.cicNoSet = ciSet;
            drw1.isValid = true;
            //   drw1.isJourneySkipped = true;
            //     drw1.journeySkipReason = 'testone';
            //   drw1.journeyStopReason = 'testsolve';
            drw1.customerDedupeResponseObjId = 'testcust';
            drw1.message = 'tetsmsg';
            drw1.applicantType = 'testapp';
            drw1.leadNumber = 'tets123';
            drw1.customerName = 'testcust';
            drw1.customerCode = 'test123';
            drw1.invalidCustomerCode = 'testinvalid';
            drw1.response = 'testresponse';
            
            
            
            Test.startTest();
            Ind_CustomerDedupCtrl.validateCustomerCode(apvc1.Id,opvc1.Id, JSON.serialize(cdp1),'Co-borrower');
            Test.stopTest();
            
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }

    @isTest
    public static void validateCustomerCodeTest10(){
        
        try{
            Opportunity opvc1 = new Opportunity();
            opvc1.StageName = 'Qualification';
            opvc1.CloseDate = Date.newInstance(2021, 1, 11);
            opvc1.Vehicle_Type__c='Refinance';
            opvc1.Name = 'testone';
            insert opvc1;
            
            
            
            Applicant__c apvc1 = new Applicant__c();
            apvc1.Opportunity__c = opvc1.Id;
            apvc1.Contact_number__c = '9743514830';
            apvc1.Applicant_Type__c = 'Borrower';
            apvc1.Name = 'Test';
            insert apvc1;
            
            
            Ind_CustomerDedupCtrl.CustomerDetailsParser cdp1 = new Ind_CustomerDedupCtrl.CustomerDetailsParser();
            cdp1.Aadhaar_No = '987623415643';
            cdp1.CustomerCodeVal = 'CU0503174';
            cdp1.Customer_Name = 'test';
            cdp1.Customer_Type = 'tetstype';
            cdp1.Date_of_Birth = '23061994';
            cdp1.Driving_License_Number = '324556644';
            cdp1.PAN_GIR_Number = 'BSDRT7629K';
            cdp1.Passport_Number = '34567';
            cdp1.Voter_ID_Number = '567388336';
            cdp1.Rule_Matching_Fields = '567388336';
            cdp1.Matched_Score = '567388336';
            cdp1.Matched_Source = 'PAN';
            cdp1.Matched_Parameter_Value = '100';
            
            
            Ind_CustomerDedupCtrl.ReturnMessageWrapper returnMsgWrapper = new Ind_CustomerDedupCtrl.ReturnMessageWrapper();
            returnMsgWrapper.isSuccess = true;
            returnMsgWrapper.message = 'Success';
            returnMsgWrapper.cloneLoanApplicationId = 'test';
            returnMsgWrapper.cloneBorrowerApplicantId = 'tetstype';
            returnMsgWrapper.cloneCoBorrowerApplicantId = '23061994';
            
            //  cdp1.parse(Json.serialize(cdp1));
            Customer_Dedupe_Response__c cdr1 = new Customer_Dedupe_Response__c();
            cdr1.Applicant__c = apvc1.Id;
            cdr1.CIC_No__c = '545667';
            cdr1.CIN_No__c = '34455';
            cdr1.Response__c ='{"response":{"status":"SUCCESS","respDesc":"IxsightEnquiry","content":[{"Data":{"ExternalDedupeResponse":{"DEDUPE_STATUS":"M","DtCFDCUSTBAS":[{"SOURCE_CIC_NO":"2022268275545880078","MATCH_ECIF":"3095268","MATCHED_CUSTOMER_NAME":"S DEIVARAJ","MATCHED_CUSTOMER_CODE":"CU0503174","MATCHED_SOURCE":"CFD","MATCHED_SCORE":"100","MATCHED_CRITERIA":"VOTERID100","CONFIDENCE_LEVEL":"1"}],"DtRECENTLEAD":[{"SOURCE_CIC_NO":"2022268275545880078","MATCHED_CIC_NO":"991102194599513090","MATCHED_LEAD_NAME":"DEIVARAJ S","MATCHED_LEAD_DATE":"12/15/2021 13:55:28","MATCHED_SCORE":"100","MATCHED_CRITERIA":"PAN100"}],"CustomerValidate":[{"CustomerCodeVal":"CU0503174","CustomerMaster":[{"Customer_Name":"S DEIVARAJ","Customer_Type":"10","Date_of_Birth":"27-06-1986 00:00:00","PAN_GIR_Number":"","Passport_Number":"","Voter_ID_Number":"CKK1913391","Driving_License_Number":"","Aadhaar_No":""}],"CustomerStatus":[{"Cross_Dedupe_Match_Id":"3095268","Active_Flag":"Z"}],"Dealstatus":[],"NPA":[],"Restructure":[{"Deal_Restructured":"No"}],"Gecl":[],"ARC":[],"PanAlert":[],"CINAlert":[],"BeneficiaryAlert":{"Ben_code":"TVTVVGH","Beneficiary":"YGVHSN","Status_Flag":"Y","PAN_No":"CAJPC1967P"}}]},"InternalDedupeResponse":[{"CustomerMaster":[{"CIC_No":"CU0503174","Matched_Customer_Code":"CU0503174","Rule_Matching_Fields":"VOTERID","Current_Parameter_Value":"CKK1913391","Matched_Parameter_Value":"CKK1913391","Matched_Score":"100","Rule_Field_Weightage":"100","Matched_Source":"CFD","Active_Flag":"Z","Dedupe_Super_Match":"Y","Dedupe_Super_Match_Score":"100","Rule_Id":"VOTERID100","Type":"C","PEP_Remarks":"","Customer_Name":null,"Customer_Type":null,"Date_of_Birth":null,"PAN_GIR_Number":null,"Passport_Number":null,"Voter_ID_Number":null,"Driving_License_Number":null,"Aadhaar_No":null},{"CIC_No":"CW3782547","Matched_Customer_Code":"CW3782547","Rule_Matching_Fields":"PAN","Current_Parameter_Value":"DMSPD9630N","Matched_Parameter_Value":"DMSPD9630N","Matched_Score":"100","Rule_Field_Weightage":"100","Matched_Source":"CFD","Active_Flag":"Y","Dedupe_Super_Match":"Y","Dedupe_Super_Match_Score":"100","Rule_Id":"PAN100","Type":"C","PEP_Remarks":"","Customer_Name":null,"Customer_Type":null,"Date_of_Birth":null,"PAN_GIR_Number":null,"Passport_Number":null,"Voter_ID_Number":null,"Driving_License_Number":null,"Aadhaar_No":null},{"CIC_No":"CW3782547","Matched_Customer_Code":"CW3782547","Rule_Matching_Fields":"VOTERID","Current_Parameter_Value":"CKK1913391","Matched_Parameter_Value":"CKK1913391","Matched_Score":"100","Rule_Field_Weightage":"100","Matched_Source":"CFD","Active_Flag":"Y","Dedupe_Super_Match":"Y","Dedupe_Super_Match_Score":"100","Rule_Id":"VOTERID100","Type":"C","PEP_Remarks":"","Customer_Name":null,"Customer_Type":null,"Date_of_Birth":null,"PAN_GIR_Number":null,"Passport_Number":null,"Voter_ID_Number":null,"Driving_License_Number":null,"Aadhaar_No":null},{"CIC_No":"CW4970396","Matched_Customer_Code":"CW4970396","Rule_Matching_Fields":"AADHAAR_NO","Current_Parameter_Value":"671940628725","Matched_Parameter_Value":"671940628725","Matched_Score":"100","Rule_Field_Weightage":"100","Matched_Source":"CFD","Active_Flag":"Y","Dedupe_Super_Match":"Y","Dedupe_Super_Match_Score":"100","Rule_Id":"ADHAR100","Type":"C","PEP_Remarks":"","Customer_Name":null,"Customer_Type":null,"Date_of_Birth":null,"PAN_GIR_Number":null,"Passport_Number":null,"Voter_ID_Number":null,"Driving_License_Number":null,"Aadhaar_No":null}],"CustomerValidate":[{"CustomerCodeVal":"CU0503174","CustomerMaster":[{"CIC_No":null,"Matched_Customer_Code":null,"Rule_Matching_Fields":null,"Current_Parameter_Value":null,"Matched_Parameter_Value":null,"Matched_Score":null,"Rule_Field_Weightage":null,"Matched_Source":null,"Active_Flag":null,"Dedupe_Super_Match":null,"Dedupe_Super_Match_Score":null,"Rule_Id":null,"Type":null,"PEP_Remarks":null,"Customer_Name":"S DEIVARAJ","Customer_Type":"10","Date_of_Birth":"27-06-1986 00:00:00","PAN_GIR_Number":"","Passport_Number":"","Voter_ID_Number":"CKK1913391","Driving_License_Number":"","Aadhaar_No":""}],"CustomerStatus":[{"Cross_Dedupe_Match_Id":"3095268","Active_Flag":"Z"}],"Dealstatus":[{"Deal_No":"TTU05950H","Status_Flag":"Z"}],"NPA":[],"Restructure":[{"Deal_Restructureds":"No"}],"Gecl":[],"ARC":[],"PanAlert":[],"CINAlert":[],"BeneficiaryAlert":{"Ben_code":null,"Beneficiary":null,"Status_Flag":null,"PAN_No":null}},{"CustomerCodeVal":"CW3782547","CustomerMaster":[{"CIC_No":null,"Matched_Customer_Code":null,"Rule_Matching_Fields":null,"Current_Parameter_Value":null,"Matched_Parameter_Value":null,"Matched_Score":null,"Rule_Field_Weightage":null,"Matched_Source":null,"Active_Flag":null,"Dedupe_Super_Match":null,"Dedupe_Super_Match_Score":null,"Rule_Id":null,"Type":null,"PEP_Remarks":null,"Customer_Name":"DEIVARAJ","Customer_Type":"10","Date_of_Birth":"27-06-1984 00:00:00","PAN_GIR_Number":"DMSPD9630N","Passport_Number":"","Voter_ID_Number":"CKK1913391","Driving_License_Number":"","Aadhaar_No":"916901617335"}],"CustomerStatus":[{"Cross_Dedupe_Match_Id":"59675453","Active_Flag":"Y"}],"Dealstatus":[{"Deal_No":"TNU05150H","Status_Flag":"Z"},{"Deal_No":"TTU01390S","Status_Flag":"L"}],"NPA":[],"Restructure":[{"Deal_Restructured":"Yes"}],"Gecl":[],"ARC":[],"PanAlert":[],"CINAlert":[],"BeneficiaryAlert":{"Ben_code":null,"Beneficiary":null,"Status_Flag":null,"PAN_No":null}},{"CustomerCodeVal":"CW3782547","CustomerMaster":[{"CIC_No":null,"Matched_Customer_Code":null,"Rule_Matching_Fields":null,"Current_Parameter_Value":null,"Matched_Parameter_Value":null,"Matched_Score":null,"Rule_Field_Weightage":null,"Matched_Source":null,"Active_Flag":null,"Dedupe_Super_Match":null,"Dedupe_Super_Match_Score":null,"Rule_Id":null,"Type":null,"PEP_Remarks":null,"Customer_Name":"DEIVARAJ","Customer_Type":"10","Date_of_Birth":"27-06-1984 00:00:00","PAN_GIR_Number":"DMSPD9630N","Passport_Number":"","Voter_ID_Number":"CKK1913391","Driving_License_Number":"","Aadhaar_No":"916901617335"}],"CustomerStatus":[{"Cross_Dedupe_Match_Id":"59675453","Active_Flag":"Y"}],"Dealstatus":[{"Deal_No":"TNU05150H","Status_Flag":"Z"},{"Deal_No":"TTU01390S","Status_Flag":"L"}],"NPA":[],"Restructure":[{"Deal_Restructured":"Yes"}],"Gecl":[],"ARC":[],"PanAlert":[],"CINAlert":[],"BeneficiaryAlert":{"Ben_code":null,"Beneficiary":null,"Status_Flag":null,"PAN_No":null}},{"CustomerCodeVal":"CW4970396","CustomerMaster":[{"CIC_No":null,"Matched_Customer_Code":null,"Rule_Matching_Fields":null,"Current_Parameter_Value":null,"Matched_Parameter_Value":null,"Matched_Score":null,"Rule_Field_Weightage":null,"Matched_Source":null,"Active_Flag":null,"Dedupe_Super_Match":null,"Dedupe_Super_Match_Score":null,"Rule_Id":null,"Type":null,"PEP_Remarks":null,"Customer_Name":"NAGALAXMI","Customer_Type":"10","Date_of_Birth":"25-03-1981 00:00:00","PAN_GIR_Number":"COMPN4828K","Passport_Number":"","Voter_ID_Number":"","Driving_License_Number":"","Aadhaar_No":"671940628725"}],"CustomerStatus":[{"Cross_Dedupe_Match_Id":"70765909","Active_Flag":"Y"}],"Dealstatus":[],"NPA":[],"Restructure":[{"Deal_Restructured":"Yes"}],"Gecl":[],"ARC":[],"PanAlert":[],"CINAlert":[],"BeneficiaryAlert":{"Ben_code":null,"Beneficiary":null,"Status_Flag":null,"PAN_No":null}}]}]},"ErrorDesc":""}]}}';
            insert cdr1;
            
            
            
            //cdp1.parse(Json.serialize(cdp1));
            ///   String sSelectedCustCode = cdp1.CustomerCodeVal;
            
            Set<String> ciSet = new Set<String>();
            ciSet.add('test');
            
            
            
            
            
            Ind_CustomerDedupCtrl.DedupeResponseWrapper drw1 = new Ind_CustomerDedupCtrl.DedupeResponseWrapper();
            drw1.SFCustomerDedupeFlag = 2.0;
            drw1.PGCustomerDedupeFlag = 3.0;
            drw1.externalDedupeAPIMaxAttempts = 5;
            //    drw1.cicNoSet = ciSet;
            drw1.isValid = true;
            //   drw1.isJourneySkipped = true;
            //     drw1.journeySkipReason = 'testone';
            //   drw1.journeyStopReason = 'testsolve';
            drw1.customerDedupeResponseObjId = 'testcust';
            drw1.message = 'tetsmsg';
            drw1.applicantType = 'testapp';
            drw1.leadNumber = 'tets123';
            drw1.customerName = 'testcust';
            drw1.customerCode = 'test123';
            drw1.invalidCustomerCode = 'testinvalid';
            drw1.response = 'testresponse';
            
            
            
            Test.startTest();
            Ind_CustomerDedupCtrl.validateCustomerCode(apvc1.Id,opvc1.Id, JSON.serialize(cdp1),'Co-borrower');
            //Ind_CustomerDedupCtrl.getApplicantName(apvc1.Id);
            Test.stopTest();
            
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }

    @isTest
    public static void getCustomerDedupeDetailsTest(){
        try{
            Opportunity opvc1 = new Opportunity();
            opvc1.StageName = 'Qualification';
            opvc1.CloseDate = Date.newInstance(2021, 1, 11);
            opvc1.Name = 'testone';
            insert opvc1;
            
            Applicant__c apvc1 = new Applicant__c();
            apvc1.Opportunity__c = opvc1.Id;
            apvc1.Contact_number__c = '9743514830';
            apvc1.Applicant_Type__c = 'Borrower';
            insert apvc1;
            
            Customer_Dedupe_Response__c cdr1 = new Customer_Dedupe_Response__c();
            cdr1.Applicant__c = apvc1.Id;
            cdr1.CIC_No__c = '545667';
            cdr1.CIN_No__c = '34455';
            insert cdr1;
            
            Test.startTest();
            Ind_CustomerDedupCtrl.getCustomerDedupeDetails(apvc1.Id);
            Test.stopTest();
            try{
                Ind_CustomerDedupCtrl.getCustomerDedupeDetails(null); 
            }catch(Exception e){}
            
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void validateDedupeCustomerCodeInSFTest(){
        try{
            Opportunity opvc1 = new Opportunity();
            opvc1.StageName = 'Loan Initiation';
            opvc1.Product_Type__c = system.label.TwoWheeler;
            opvc1.CloseDate = Date.newInstance(2021, 1, 11);
            opvc1.Name = 'testone';
            insert opvc1;
            
            Applicant__c apvc1 = new Applicant__c();
            apvc1.Opportunity__c = opvc1.Id;
            apvc1.Contact_number__c = '9743514830';
            apvc1.Applicant_Type__c = 'Borrower';
            insert apvc1;
            
            Customer_Dedupe_Response__c cdr1 = new Customer_Dedupe_Response__c();
            cdr1.Applicant__c = apvc1.Id;
            cdr1.CIC_No__c = '991102194599513090';
            cdr1.CIN_No__c = '34455';
            insert cdr1;
            
            // List<Customer_Dedup_Response_Parser.cls_CustomerValidate[]> dedupeValidateDataList = new List<Customer_Dedup_Response_Parser.cls_CustomerValidate[]>();
            //  dedupeValidateDataList.add((validateData[0].CustomerCodeVal));
            
            
            Ind_CustomerDedupCtrl.DedupeResponseWrapper drw1 = new Ind_CustomerDedupCtrl.DedupeResponseWrapper();
            drw1.SFCustomerDedupeFlag = 2.0;
            drw1.PGCustomerDedupeFlag = 3.0;
            drw1.externalDedupeAPIMaxAttempts = 5;
            //    drw1.cicNoSet = ciSet;
            drw1.isValid = true;
       //     drw1.isJourneySkipped = true;
       //     drw1.journeySkipReason = 'testone';
       //     drw1.journeyStopReason = 'testsolve';
            drw1.customerDedupeResponseObjId = 'testcust';
            drw1.message = 'tetsmsg';
            drw1.applicantType = 'testapp';
            drw1.leadNumber = 'tets123';
            drw1.customerName = 'testcust';
            drw1.customerCode = 'test123';
            drw1.invalidCustomerCode = 'testinvalid';
            drw1.response = 'testresponse';
           	String response =  '{"response":{"content":[{"ErrorDesc":"","Data":{"InternalDedupeResponse":[{"CustomerValidate":[{"BeneficiaryAlert":{"PAN_No":null,"Status_Flag":null,"Beneficiary":null,"Ben_code":null},"CINAlert":[],"PanAlert":[],"ARC":[],"Gecl":[],"Restructure":[],"NPA":[],"Dealstatus":[],"CustomerStatus":[{"Active_Flag":"Y","Cross_Dedupe_Match_Id":"12063415"}],"CustomerMaster":[{"Aadhaar_No":"3724","Driving_License_Number":"","Voter_ID_Number":"","Passport_Number":"","PAN_GIR_Number":"BGHPK2819K","Date_of_Birth":"18-07-1962 00:00:00","Customer_Type":"10","Customer_Name":"RAKESH  ","PEP_Remarks":null,"Type":null,"Rule_Id":null,"Dedupe_Super_Match_Score":null,"Dedupe_Super_Match":null,"Active_Flag":null,"Matched_Source":null,"Rule_Field_Weightage":null,"Matched_Score":null,"Matched_Parameter_Value":null,"Current_Parameter_Value":null,"Rule_Matching_Fields":null,"Matched_Customer_Code":null,"CIC_No":null}],"CustomerCodeVal":"CW6585027"},{"BeneficiaryAlert":{"PAN_No":null,"Status_Flag":null,"Beneficiary":null,"Ben_code":null},"CINAlert":[],"PanAlert":[],"ARC":[],"Gecl":[],"Restructure":[],"NPA":[],"Dealstatus":[],"CustomerStatus":[{"Active_Flag":"Z","Cross_Dedupe_Match_Id":"12063415"}],"CustomerMaster":[{"Aadhaar_No":"3724","Driving_License_Number":"","Voter_ID_Number":"","Passport_Number":"","PAN_GIR_Number":"BGHPK2819K","Date_of_Birth":"18-07-1962 00:00:00","Customer_Type":"10","Customer_Name":"RAKESH ","PEP_Remarks":null,"Type":null,"Rule_Id":null,"Dedupe_Super_Match_Score":null,"Dedupe_Super_Match":null,"Active_Flag":null,"Matched_Source":null,"Rule_Field_Weightage":null,"Matched_Score":null,"Matched_Parameter_Value":null,"Current_Parameter_Value":null,"Rule_Matching_Fields":null,"Matched_Customer_Code":null,"CIC_No":null}],"CustomerCodeVal":"CW6585689"}],"CustomerMaster":[{"Aadhaar_No":null,"Driving_License_Number":null,"Voter_ID_Number":null,"Passport_Number":null,"PAN_GIR_Number":null,"Date_of_Birth":null,"Customer_Type":null,"Customer_Name":null,"PEP_Remarks":"","Type":"C","Rule_Id":"PAN100","Dedupe_Super_Match_Score":"100","Dedupe_Super_Match":"Y","Active_Flag":"Y","Matched_Source":"CFD","Rule_Field_Weightage":"100","Matched_Score":"100","Matched_Parameter_Value":"BGHPK2819K","Current_Parameter_Value":"BGHPK2819K","Rule_Matching_Fields":"PAN","Matched_Customer_Code":"CW6585027","CIC_No":"CW6585027"},{"Aadhaar_No":null,"Driving_License_Number":null,"Voter_ID_Number":null,"Passport_Number":null,"PAN_GIR_Number":null,"Date_of_Birth":null,"Customer_Type":null,"Customer_Name":null,"PEP_Remarks":"","Type":"C","Rule_Id":"PAN100","Dedupe_Super_Match_Score":"100","Dedupe_Super_Match":"Y","Active_Flag":"Z","Matched_Source":"CFD","Rule_Field_Weightage":"100","Matched_Score":"100","Matched_Parameter_Value":"BGHPK2819K","Current_Parameter_Value":"BGHPK2819K","Rule_Matching_Fields":"PAN","Matched_Customer_Code":"CW6585689","CIC_No":"CW6585689"}]}],"ExternalDedupeResponse":{"CustomerValidate":null,"DtRECENTLEAD":null,"DtCFDCUSTBAS":null,"DEDUPE_STATUS":"P"},"NonCFD_NPA":{"NPATYPE":"Doubtful 1"}}}],"respDesc":"IxsightEnquiry","status":"SUCCESS"}}';
            Test.startTest();
            Ind_CustomerDedupCtrl.validateDedupeCustomerCodeInSF(apvc1.Id,'1234',response);
            Test.stopTest();
        }catch(Exception e){
            System.debug('Script-thrown exception'+ e.getMessage());
        }
    }
    
    @isTest
    public static void validateDedupeCustomerCodeInSFTest1(){
        try{
            Opportunity opvc1 = new Opportunity();
            opvc1.StageName = 'Loan Initiation';
            opvc1.Product_Type__c = system.label.TwoWheeler;
            opvc1.CloseDate = Date.newInstance(2021, 1, 11);
            opvc1.Name = 'testone';
            insert opvc1;
            
            Applicant__c apvc1 = new Applicant__c();
            apvc1.Opportunity__c = opvc1.Id;
            apvc1.Contact_number__c = '9743514830';
            apvc1.Applicant_Type__c = 'Borrower';
            insert apvc1;
            
            Customer_Dedupe_Response__c cdr1 = new Customer_Dedupe_Response__c();
            cdr1.Applicant__c = apvc1.Id;
            cdr1.CIC_No__c = '2023040407101165913';
            cdr1.CIN_No__c = '34455';
            insert cdr1;
            
            Opportunity opvc2 = new Opportunity();
            opvc2.StageName = 'Loan Initiation';
            opvc2.Product_Type__c = system.label.TwoWheeler;
            opvc2.CloseDate = Date.newInstance(2021, 1, 11);
            opvc2.Name = 'testone';
            insert opvc2;
            
            Applicant__c apvc2 = new Applicant__c();
            apvc2.Opportunity__c = opvc2.Id;
            apvc2.Contact_number__c = '9743514830';
            apvc2.Applicant_Type__c = 'Borrower';
            insert apvc2;
            
            Ind_CustomerDedupCtrl.DedupeResponseWrapper drw1 = new Ind_CustomerDedupCtrl.DedupeResponseWrapper();
            drw1.SFCustomerDedupeFlag = 2.0;
            drw1.PGCustomerDedupeFlag = 3.0;
            drw1.externalDedupeAPIMaxAttempts = 5;
            //    drw1.cicNoSet = ciSet;
            drw1.isValid = true;
        //    drw1.isJourneySkipped = true;
        //    drw1.journeySkipReason = 'testone';
        //    drw1.journeyStopReason = 'testsolve';
            drw1.customerDedupeResponseObjId = 'testcust';
            drw1.message = 'tetsmsg';
            drw1.applicantType = 'testapp';
            drw1.leadNumber = 'tets123';
            drw1.customerName = 'testcust';
            drw1.customerCode = 'test123';
            drw1.invalidCustomerCode = 'testinvalid';
            drw1.response = 'testresponse';
            String response = '{"response":{"content":[{"ErrorDesc":"","Data":{"InternalDedupeResponse":[{"CustomerValidate":[{"BeneficiaryAlert":{"PAN_No":null,"Status_Flag":null,"Beneficiary":null,"Ben_code":null},"CINAlert":[],"PanAlert":[],"ARC":[],"Gecl":[],"Restructure":[],"NPA":[],"Dealstatus":[],"CustomerStatus":[{"Active_Flag":"Z","Cross_Dedupe_Match_Id":"73479182"}],"CustomerMaster":[{"Aadhaar_No":"3147","Driving_License_Number":"","Voter_ID_Number":"","Passport_Number":"","PAN_GIR_Number":"AHBPG3241R","Date_of_Birth":"08-07-1976 00:00:00","Customer_Type":"10","Customer_Name":"NAVEEN KUMAR","PEP_Remarks":null,"Type":null,"Rule_Id":null,"Dedupe_Super_Match_Score":null,"Dedupe_Super_Match":null,"Active_Flag":null,"Matched_Source":null,"Rule_Field_Weightage":null,"Matched_Score":null,"Matched_Parameter_Value":null,"Current_Parameter_Value":null,"Rule_Matching_Fields":null,"Matched_Customer_Code":null,"CIC_No":null}],"CustomerCodeVal":"CW5396633"}],"CustomerMaster":[{"Aadhaar_No":null,"Driving_License_Number":null,"Voter_ID_Number":null,"Passport_Number":null,"PAN_GIR_Number":null,"Date_of_Birth":null,"Customer_Type":null,"Customer_Name":null,"PEP_Remarks":"","Type":"C","Rule_Id":"PAN100","Dedupe_Super_Match_Score":"100","Dedupe_Super_Match":"Y","Active_Flag":"Z","Matched_Source":"CFD","Rule_Field_Weightage":"100","Matched_Score":"100","Matched_Parameter_Value":"AHBPG3241R","Current_Parameter_Value":"AHBPG3241R","Rule_Matching_Fields":"PAN","Matched_Customer_Code":"CW5396633","CIC_No":"CW5396633"}]}],"ExternalDedupeResponse":{"CustomerValidate":null,"DtRECENTLEAD":[{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-04T12:40:13+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023040407101165913","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-04T12:47:30+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023040407172854360","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-04T12:50:51+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023040407204813709","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-04T13:01:40+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023040407313913044","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-04T13:09:03+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023040407390065676","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-04T13:15:04+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023040407450137974","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-04T13:21:34+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023040407513214790","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-04T13:24:21+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023040407542017471","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-04T13:31:26+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023040408012578634","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-04T13:33:09+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023040408030811916","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-04T14:22:12+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023040408521047297","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-04T14:26:58+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023040408565610838","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-04T14:32:07+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023040409020587040","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-04T14:36:37+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023040409063517559","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-04T14:54:19+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023040409241732115","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-04T14:56:25+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023040409262312904","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-04T14:57:22+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023040409272021046","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-04T15:00:23+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023040409302240135","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-04T16:16:33+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023040410463119429","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-09T16:22:19+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023040910521417075","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-09T16:24:21+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023040910542012500","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-09T16:27:25+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023040910572344393","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-09T16:31:49+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023040911014878770","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-09T17:04:53+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023040911344916731","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-18T16:00:15+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023041810301363056","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-19T12:02:50+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023041906324816407","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-19T12:11:40+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023041906413914050","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-19T15:21:05+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023041909510284867","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-19T15:45:46+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023041910154253658","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-20T15:34:59+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023042010045720859","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-20T15:37:18+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023042010071614788","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-20T15:45:05+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023042010150210004","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-24T19:19:53+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023042413495132175","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-25T11:16:57+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023042505462682211","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-25T11:17:44+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023042505471836168","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-25T11:27:13+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023042505571149286","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-25T12:13:44+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023042506434295294","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-25T13:05:58+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023042507355610128","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-25T13:07:33+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023042507373114531","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-25T13:18:47+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023042507484414823","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-25T13:22:33+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023042507523117187","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-25T15:15:25+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023042509452313124","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-26T07:21:20+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023042601510912800","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-26T07:27:59+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023042601575772000","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-26T07:29:11+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023042601590910741","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-26T07:36:32+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023042602062584145","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-26T15:37:14+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023042610071291319","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-26T15:39:38+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023042610093687618","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-26T15:41:15+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023042610111310260","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-05-01T11:43:51+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023050106134775813","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-05-01T11:54:49+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023050106241562107","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-05-01T12:01:43+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023050106314134773","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-05-01T12:06:09+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023050106360788857","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-05-01T16:14:50+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023050110444819434","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-05-01T18:02:34+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023050112320415293","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-05-01T18:07:16+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023050112371412663","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-05-01T18:26:51+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023050112564912313","SOURCE_CIC_NO":"2023050311252051820"}],"DtCFDCUSTBAS":null,"DEDUPE_STATUS":"N"}}}],"respDesc":"IxsightEnquiry","status":"SUCCESS"}}';
            Test.startTest();
           	Ind_CustomerDedupCtrl.validateDedupeCustomerCodeInSF(apvc2.Id,'1234',response);
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    } 
     @isTest
    public static void validateDedupeCustomerCodeInSFTest2(){
        try{
            Opportunity opvc1 = new Opportunity();
            opvc1.StageName = 'Loan Initiation';
            opvc1.Product_Type__c = System.Label.PassengerVehicles;
            opvc1.CloseDate = Date.newInstance(2021, 1, 11);
            opvc1.Name = 'testone';
            insert opvc1;
            
            Applicant__c apvc1 = new Applicant__c();
            apvc1.Opportunity__c = opvc1.Id;
            apvc1.Contact_number__c = '9743514830';
            apvc1.Applicant_Type__c = 'Borrower';
            insert apvc1;
            
            Customer_Dedupe_Response__c cdr1 = new Customer_Dedupe_Response__c();
            cdr1.Applicant__c = apvc1.Id;
            cdr1.CIC_No__c = '2023040407101165913';
            cdr1.CIN_No__c = '34455';
            insert cdr1;
            
             Opportunity opvc2 = new Opportunity();
            opvc2.StageName = 'Loan Initiation';
            opvc2.Product_Type__c = system.label.PassengerVehicles;
            opvc2.CloseDate = Date.newInstance(2021, 1, 11);
            opvc2.Name = 'testone';
            insert opvc2;
            
            Applicant__c apvc2 = new Applicant__c();
            apvc2.Opportunity__c = opvc2.Id;
            apvc2.Contact_number__c = '9743514830';
            apvc2.Applicant_Type__c = 'Borrower';
            insert apvc2;
            
            Ind_CustomerDedupCtrl.DedupeResponseWrapper drw1 = new Ind_CustomerDedupCtrl.DedupeResponseWrapper();
            drw1.SFCustomerDedupeFlag = 2.0;
            drw1.PGCustomerDedupeFlag = 3.0;
            drw1.externalDedupeAPIMaxAttempts = 5;
            //    drw1.cicNoSet = ciSet;
            drw1.isValid = true;
        //    drw1.isJourneySkipped = true;
        //    drw1.journeySkipReason = 'testone';
        //    drw1.journeyStopReason = 'testsolve';
            drw1.customerDedupeResponseObjId = 'testcust';
            drw1.message = 'tetsmsg';
            drw1.applicantType = 'testapp';
            drw1.leadNumber = 'tets123';
            drw1.customerName = 'testcust';
            drw1.customerCode = 'test123';
            drw1.invalidCustomerCode = 'testinvalid';
            drw1.response = 'testresponse';
            String response = '{"response":{"content":[{"ErrorDesc":"","Data":{"InternalDedupeResponse":[{"CustomerValidate":[{"BeneficiaryAlert":{"PAN_No":null,"Status_Flag":null,"Beneficiary":null,"Ben_code":null},"CINAlert":[],"PanAlert":[],"ARC":[],"Gecl":[],"Restructure":[],"NPA":[],"Dealstatus":[],"CustomerStatus":[{"Active_Flag":"Z","Cross_Dedupe_Match_Id":"73479182"}],"CustomerMaster":[{"Aadhaar_No":"3147","Driving_License_Number":"","Voter_ID_Number":"","Passport_Number":"","PAN_GIR_Number":"AHBPG3241R","Date_of_Birth":"08-07-1976 00:00:00","Customer_Type":"10","Customer_Name":"NAVEEN KUMAR","PEP_Remarks":null,"Type":null,"Rule_Id":null,"Dedupe_Super_Match_Score":null,"Dedupe_Super_Match":null,"Active_Flag":null,"Matched_Source":null,"Rule_Field_Weightage":null,"Matched_Score":null,"Matched_Parameter_Value":null,"Current_Parameter_Value":null,"Rule_Matching_Fields":null,"Matched_Customer_Code":null,"CIC_No":null}],"CustomerCodeVal":"CW5396633"}],"CustomerMaster":[{"Aadhaar_No":null,"Driving_License_Number":null,"Voter_ID_Number":null,"Passport_Number":null,"PAN_GIR_Number":null,"Date_of_Birth":null,"Customer_Type":null,"Customer_Name":null,"PEP_Remarks":"","Type":"C","Rule_Id":"PAN100","Dedupe_Super_Match_Score":"100","Dedupe_Super_Match":"Y","Active_Flag":"Z","Matched_Source":"CFD","Rule_Field_Weightage":"100","Matched_Score":"100","Matched_Parameter_Value":"AHBPG3241R","Current_Parameter_Value":"AHBPG3241R","Rule_Matching_Fields":"PAN","Matched_Customer_Code":"CW5396633","CIC_No":"CW5396633"}]}],"ExternalDedupeResponse":{"CustomerValidate":null,"DtRECENTLEAD":[{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-04T12:40:13+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023040407101165913","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-04T12:47:30+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023040407172854360","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-04T12:50:51+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023040407204813709","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-04T13:01:40+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023040407313913044","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-04T13:09:03+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023040407390065676","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-04T13:15:04+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023040407450137974","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-04T13:21:34+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023040407513214790","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-04T13:24:21+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023040407542017471","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-04T13:31:26+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023040408012578634","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-04T13:33:09+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023040408030811916","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-04T14:22:12+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023040408521047297","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-04T14:26:58+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023040408565610838","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-04T14:32:07+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023040409020587040","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-04T14:36:37+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023040409063517559","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-04T14:54:19+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023040409241732115","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-04T14:56:25+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023040409262312904","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-04T14:57:22+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023040409272021046","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-04T15:00:23+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023040409302240135","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-04T16:16:33+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023040410463119429","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-09T16:22:19+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023040910521417075","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-09T16:24:21+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023040910542012500","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-09T16:27:25+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023040910572344393","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-09T16:31:49+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023040911014878770","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-09T17:04:53+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023040911344916731","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-18T16:00:15+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023041810301363056","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-19T12:02:50+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023041906324816407","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-19T12:11:40+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023041906413914050","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-19T15:21:05+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023041909510284867","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-19T15:45:46+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023041910154253658","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-20T15:34:59+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023042010045720859","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-20T15:37:18+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023042010071614788","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-20T15:45:05+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023042010150210004","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-24T19:19:53+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023042413495132175","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-25T11:16:57+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023042505462682211","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-25T11:17:44+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023042505471836168","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-25T11:27:13+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023042505571149286","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-25T12:13:44+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023042506434295294","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-25T13:05:58+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023042507355610128","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-25T13:07:33+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023042507373114531","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-25T13:18:47+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023042507484414823","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-25T13:22:33+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023042507523117187","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-25T15:15:25+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023042509452313124","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-26T07:21:20+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023042601510912800","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-26T07:27:59+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023042601575772000","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-26T07:29:11+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023042601590910741","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-26T07:36:32+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023042602062584145","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-26T15:37:14+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023042610071291319","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-26T15:39:38+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023042610093687618","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-26T15:41:15+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023042610111310260","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-05-01T11:43:51+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023050106134775813","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-05-01T11:54:49+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023050106241562107","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-05-01T12:01:43+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023050106314134773","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-05-01T12:06:09+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023050106360788857","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-05-01T16:14:50+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023050110444819434","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-05-01T18:02:34+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023050112320415293","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-05-01T18:07:16+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023050112371412663","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-05-01T18:26:51+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023050112564912313","SOURCE_CIC_NO":"2023050311252051820"}],"DtCFDCUSTBAS":null,"DEDUPE_STATUS":"N"}}}],"respDesc":"IxsightEnquiry","status":"SUCCESS"}}';
            Test.startTest();
           	Ind_CustomerDedupCtrl.validateDedupeCustomerCodeInSF(apvc2.Id,'1234',response);
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    } 
    @isTest
    public static void validateDedupeCustomerCodeInSFTest3(){
        try{
            Opportunity opvc1 = new Opportunity();
            opvc1.StageName = 'Loan Initiation';
            opvc1.Product_Type__c = system.label.TwoWheeler;
            opvc1.CloseDate = Date.newInstance(2021, 1, 11);
            opvc1.Name = 'testone';
            insert opvc1;
            
            Applicant__c apvc1 = new Applicant__c();
            apvc1.Opportunity__c = opvc1.Id;
            apvc1.Contact_number__c = '9743514830';
            apvc1.Applicant_Type__c = 'Borrower';
            insert apvc1;
            
            Customer_Dedupe_Response__c cdr1 = new Customer_Dedupe_Response__c();
            cdr1.Applicant__c = apvc1.Id;
            cdr1.CIC_No__c = '2023040407101165913';
            cdr1.CIN_No__c = '34455';
            insert cdr1;
            
            Ind_CustomerDedupCtrl.DedupeResponseWrapper drw1 = new Ind_CustomerDedupCtrl.DedupeResponseWrapper();
            drw1.SFCustomerDedupeFlag = 2.0;
            drw1.PGCustomerDedupeFlag = 3.0;
            drw1.externalDedupeAPIMaxAttempts = 5;
            //    drw1.cicNoSet = ciSet;
            drw1.isValid = true;
        //    drw1.isJourneySkipped = true;
        //    drw1.journeySkipReason = 'testone';
        //    drw1.journeyStopReason = 'testsolve';
            drw1.customerDedupeResponseObjId = 'testcust';
            drw1.message = 'tetsmsg';
            drw1.applicantType = 'testapp';
            drw1.leadNumber = 'tets123';
            drw1.customerName = 'testcust';
            drw1.customerCode = 'test123';
            drw1.invalidCustomerCode = 'testinvalid';
            drw1.response = 'testresponse';
            String response = '{"response":{"content":[{"ErrorDesc":"","Data":{"InternalDedupeResponse":[{"CustomerValidate":[{"BeneficiaryAlert":{"PAN_No":"12467888","Status_Flag":null,"Beneficiary":null,"Ben_code":null},"CINAlert":[],"PanAlert":[],"ARC":[],"Gecl":[],"Restructure":[],"NPA":[],"Dealstatus":[],"CustomerStatus":[{"Active_Flag":"Z","Cross_Dedupe_Match_Id":"73479182"}],"CustomerMaster":[{"Aadhaar_No":"3147","Driving_License_Number":"","Voter_ID_Number":"","Passport_Number":"","PAN_GIR_Number":"AHBPG3241R","Date_of_Birth":"08-07-1976 00:00:00","Customer_Type":"10","Customer_Name":"NAVEEN KUMAR","PEP_Remarks":null,"Type":null,"Rule_Id":null,"Dedupe_Super_Match_Score":null,"Dedupe_Super_Match":null,"Active_Flag":null,"Matched_Source":null,"Rule_Field_Weightage":null,"Matched_Score":null,"Matched_Parameter_Value":null,"Current_Parameter_Value":null,"Rule_Matching_Fields":null,"Matched_Customer_Code":null,"CIC_No":null}],"CustomerCodeVal":null}],"CustomerMaster":[{"Aadhaar_No":null,"Driving_License_Number":null,"Voter_ID_Number":null,"Passport_Number":null,"PAN_GIR_Number":null,"Date_of_Birth":null,"Customer_Type":null,"Customer_Name":null,"PEP_Remarks":"","Type":"C","Rule_Id":"PAN100","Dedupe_Super_Match_Score":"100","Dedupe_Super_Match":"Y","Active_Flag":"Z","Matched_Source":"CFD","Rule_Field_Weightage":"100","Matched_Score":"100","Matched_Parameter_Value":"AHBPG3241R","Current_Parameter_Value":"AHBPG3241R","Rule_Matching_Fields":"PAN","Matched_Customer_Code":"CW5396633","CIC_No":"CW5396633"}]}],"ExternalDedupeResponse":{"CustomerValidate":null,"DtRECENTLEAD":[{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-04T12:40:13+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023040407101165913","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-04T12:47:30+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023040407172854360","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-04T12:50:51+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023040407204813709","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-04T13:01:40+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023040407313913044","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-04T13:09:03+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023040407390065676","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-04T13:15:04+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023040407450137974","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-04T13:21:34+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023040407513214790","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-04T13:24:21+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023040407542017471","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-04T13:31:26+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023040408012578634","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-04T13:33:09+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023040408030811916","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-04T14:22:12+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023040408521047297","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-04T14:26:58+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023040408565610838","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-04T14:32:07+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023040409020587040","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-04T14:36:37+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023040409063517559","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-04T14:54:19+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023040409241732115","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-04T14:56:25+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023040409262312904","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-04T14:57:22+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023040409272021046","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-04T15:00:23+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023040409302240135","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-04T16:16:33+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023040410463119429","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-09T16:22:19+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023040910521417075","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-09T16:24:21+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023040910542012500","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-09T16:27:25+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023040910572344393","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-09T16:31:49+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023040911014878770","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-09T17:04:53+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023040911344916731","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-18T16:00:15+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023041810301363056","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-19T12:02:50+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023041906324816407","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-19T12:11:40+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023041906413914050","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-19T15:21:05+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023041909510284867","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-19T15:45:46+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023041910154253658","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-20T15:34:59+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023042010045720859","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-20T15:37:18+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023042010071614788","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-20T15:45:05+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023042010150210004","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-24T19:19:53+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023042413495132175","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-25T11:16:57+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023042505462682211","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-25T11:17:44+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023042505471836168","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-25T11:27:13+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023042505571149286","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-25T12:13:44+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023042506434295294","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-25T13:05:58+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023042507355610128","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-25T13:07:33+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023042507373114531","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-25T13:18:47+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023042507484414823","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-25T13:22:33+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023042507523117187","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-25T15:15:25+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023042509452313124","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-26T07:21:20+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023042601510912800","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-26T07:27:59+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023042601575772000","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-26T07:29:11+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023042601590910741","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-26T07:36:32+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023042602062584145","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-26T15:37:14+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023042610071291319","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-26T15:39:38+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023042610093687618","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-26T15:41:15+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023042610111310260","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-05-01T11:43:51+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023050106134775813","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-05-01T11:54:49+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023050106241562107","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-05-01T12:01:43+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023050106314134773","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-05-01T12:06:09+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023050106360788857","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-05-01T16:14:50+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023050110444819434","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-05-01T18:02:34+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023050112320415293","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-05-01T18:07:16+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023050112371412663","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-05-01T18:26:51+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023050112564912313","SOURCE_CIC_NO":"2023050311252051820"}],"DtCFDCUSTBAS":null,"DEDUPE_STATUS":"N"}}}],"respDesc":"IxsightEnquiry","status":"SUCCESS"}}';
            Test.startTest();
           	Ind_CustomerDedupCtrl.validateDedupeCustomerCodeInSF(apvc1.Id,'1234',response);
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void validateDedupeCustomerCodeInSFTest4(){
        try{
            Opportunity opvc1 = new Opportunity();
            opvc1.StageName = 'Loan Initiation';
            opvc1.Product_Type__c = system.label.TwoWheeler;
            opvc1.CloseDate = Date.newInstance(2021, 1, 11);
            opvc1.Name = 'testone';
            insert opvc1;
            
            Applicant__c apvc1 = new Applicant__c();
            apvc1.Opportunity__c = opvc1.Id;
            apvc1.Contact_number__c = '9743514830';
            apvc1.Applicant_Type__c = 'Borrower';
            insert apvc1;
            
            Customer_Dedupe_Response__c cdr1 = new Customer_Dedupe_Response__c();
            cdr1.Applicant__c = apvc1.Id;
            cdr1.CIC_No__c = '2023040407101165913';
            cdr1.CIN_No__c = '34455';
            insert cdr1;
            
            Ind_CustomerDedupCtrl.DedupeResponseWrapper drw1 = new Ind_CustomerDedupCtrl.DedupeResponseWrapper();
            drw1.SFCustomerDedupeFlag = 2.0;
            drw1.PGCustomerDedupeFlag = 3.0;
            drw1.externalDedupeAPIMaxAttempts = 5;
            //    drw1.cicNoSet = ciSet;
            drw1.isValid = true;
        //    drw1.isJourneySkipped = true;
        //    drw1.journeySkipReason = 'testone';
        //    drw1.journeyStopReason = 'testsolve';
            drw1.customerDedupeResponseObjId = 'testcust';
            drw1.message = 'tetsmsg';
            drw1.applicantType = 'testapp';
            drw1.leadNumber = 'tets123';
            drw1.customerName = 'testcust';
            drw1.customerCode = 'test123';
            drw1.invalidCustomerCode = 'testinvalid';
            drw1.response = 'testresponse';
            Test.startTest();
           	Ind_CustomerDedupCtrl.validateDedupeCustomerCodeInSF(null,'1234',null);
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    @isTest
    public static void validateDedupeCustomerCodeInSFTest5(){
        try{
            User u = [Select Id from user where username = 'test_userprod1123@indusbank.com.uat' limit 1];
            Opportunity opvc1 = new Opportunity();
            opvc1.StageName = 'Loan Initiation';
            opvc1.Product_Type__c = System.Label.PassengerVehicles;
            opvc1.CloseDate = Date.newInstance(2021, 1, 11);
            opvc1.Name = 'testone';
            insert opvc1;
            
            Applicant__c apvc1 = new Applicant__c();
            apvc1.Opportunity__c = opvc1.Id;
            apvc1.Contact_number__c = '9743514830';
            apvc1.Applicant_Type__c = 'Borrower';
            insert apvc1;
            
            Customer_Dedupe_Response__c cdr1 = new Customer_Dedupe_Response__c();
            cdr1.Applicant__c = apvc1.Id;
            cdr1.CIC_No__c = '2023040407101165913';
            cdr1.CIN_No__c = '34455';
            insert cdr1;
            
            Ind_CustomerDedupCtrl.DedupeResponseWrapper drw1 = new Ind_CustomerDedupCtrl.DedupeResponseWrapper();
            drw1.SFCustomerDedupeFlag = 2.0;
            drw1.PGCustomerDedupeFlag = 3.0;
            drw1.externalDedupeAPIMaxAttempts = 5;
            //    drw1.cicNoSet = ciSet;
            drw1.isValid = true;
        //    drw1.isJourneySkipped = true;
        //    drw1.journeySkipReason = 'testone';
        //    drw1.journeyStopReason = 'testsolve';
            drw1.customerDedupeResponseObjId = 'testcust';
            drw1.message = 'tetsmsg';
            drw1.applicantType = 'testapp';
            drw1.leadNumber = 'tets123';
            drw1.customerName = 'testcust';
            drw1.customerCode = 'test123';
            drw1.invalidCustomerCode = 'testinvalid';
            drw1.response = 'testresponse';
            String response = '{"response":{"content":[{"ErrorDesc":"","Data":{"InternalDedupeResponse":[{"CustomerValidate":[{"BeneficiaryAlert":{"PAN_No":null,"Status_Flag":null,"Beneficiary":null,"Ben_code":null},"CINAlert":[],"PanAlert":[],"ARC":[],"Gecl":[],"Restructure":[],"NPA":[],"Dealstatus":[],"CustomerStatus":[{"Active_Flag":"Z","Cross_Dedupe_Match_Id":"73479182"}],"CustomerMaster":[{"Aadhaar_No":"3147","Driving_License_Number":"","Voter_ID_Number":"","Passport_Number":"","PAN_GIR_Number":"AHBPG3241R","Date_of_Birth":"08-07-1976 00:00:00","Customer_Type":"10","Customer_Name":"NAVEEN KUMAR","PEP_Remarks":null,"Type":null,"Rule_Id":null,"Dedupe_Super_Match_Score":null,"Dedupe_Super_Match":null,"Active_Flag":null,"Matched_Source":null,"Rule_Field_Weightage":null,"Matched_Score":null,"Matched_Parameter_Value":null,"Current_Parameter_Value":null,"Rule_Matching_Fields":null,"Matched_Customer_Code":null,"CIC_No":null}],"CustomerCodeVal":"CW5396633"}],"CustomerMaster":[{"Aadhaar_No":null,"Driving_License_Number":null,"Voter_ID_Number":null,"Passport_Number":null,"PAN_GIR_Number":null,"Date_of_Birth":null,"Customer_Type":null,"Customer_Name":null,"PEP_Remarks":"","Type":"C","Rule_Id":"PAN100","Dedupe_Super_Match_Score":"100","Dedupe_Super_Match":"Y","Active_Flag":"Z","Matched_Source":"CFD","Rule_Field_Weightage":"100","Matched_Score":"100","Matched_Parameter_Value":"AHBPG3241R","Current_Parameter_Value":"AHBPG3241R","Rule_Matching_Fields":"PAN","Matched_Customer_Code":"CW5396633","CIC_No":"CW5396633"}]}],"ExternalDedupeResponse":{"CustomerValidate":null,"DtRECENTLEAD":[{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-04T12:40:13+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023040407101165913","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-04T12:47:30+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023040407172854360","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-04T12:50:51+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023040407204813709","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-04T13:01:40+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023040407313913044","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-04T13:09:03+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023040407390065676","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-04T13:15:04+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023040407450137974","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-04T13:21:34+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023040407513214790","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-04T13:24:21+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023040407542017471","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-04T13:31:26+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023040408012578634","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-04T13:33:09+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023040408030811916","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-04T14:22:12+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023040408521047297","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-04T14:26:58+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023040408565610838","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-04T14:32:07+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023040409020587040","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-04T14:36:37+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023040409063517559","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-04T14:54:19+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023040409241732115","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-04T14:56:25+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023040409262312904","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-04T14:57:22+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023040409272021046","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-04T15:00:23+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023040409302240135","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-04T16:16:33+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023040410463119429","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-09T16:22:19+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023040910521417075","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-09T16:24:21+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023040910542012500","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-09T16:27:25+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023040910572344393","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-09T16:31:49+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023040911014878770","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-09T17:04:53+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023040911344916731","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-18T16:00:15+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023041810301363056","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-19T12:02:50+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023041906324816407","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-19T12:11:40+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023041906413914050","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-19T15:21:05+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023041909510284867","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-19T15:45:46+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023041910154253658","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-20T15:34:59+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023042010045720859","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-20T15:37:18+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023042010071614788","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-20T15:45:05+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023042010150210004","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-24T19:19:53+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023042413495132175","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-25T11:16:57+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023042505462682211","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-25T11:17:44+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023042505471836168","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-25T11:27:13+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023042505571149286","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-25T12:13:44+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023042506434295294","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-25T13:05:58+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023042507355610128","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-25T13:07:33+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023042507373114531","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-25T13:18:47+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023042507484414823","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-25T13:22:33+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023042507523117187","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-25T15:15:25+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023042509452313124","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-26T07:21:20+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023042601510912800","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-26T07:27:59+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023042601575772000","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-26T07:29:11+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023042601590910741","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-26T07:36:32+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023042602062584145","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-26T15:37:14+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023042610071291319","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-26T15:39:38+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023042610093687618","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-04-26T15:41:15+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023042610111310260","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-05-01T11:43:51+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023050106134775813","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-05-01T11:54:49+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023050106241562107","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-05-01T12:01:43+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023050106314134773","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-05-01T12:06:09+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023050106360788857","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-05-01T16:14:50+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023050110444819434","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-05-01T18:02:34+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023050112320415293","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-05-01T18:07:16+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023050112371412663","SOURCE_CIC_NO":"2023050311252051820"},{"MATCHED_CRITERIA":"PAN100","MATCHED_SCORE":"100","MATCHED_LEAD_DATE":"2023-05-01T18:26:51+05:30","MATCHED_LEAD_NAME":"Naveen Kumar G","MATCHED_CIC_NO":"2023050112564912313","SOURCE_CIC_NO":"2023050311252051820"}],"DtCFDCUSTBAS":null,"DEDUPE_STATUS":"N"}}}],"respDesc":"IxsightEnquiry","status":"SUCCESS"}}';
            System.runAs(u){
                
                Ind_CustomerDedupCtrl.validateDedupeCustomerCodeInSF(apvc1.Id,'1234',response);
                
            }
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
     
    @isTest
    public static void dedupeSubmitByCMUTest(){
        try{
            String loanApplicationId = [Select id,Lead_Number__c From Opportunity LIMIT 1].Id;
            Ind_CustomerDedupCtrl.dedupeSubmitByCMU(loanApplicationId);
        }
        catch(Exception e){
            System.debug('exception --' + e);
        }
    }
    @isTest
    public static void inactivateCoBorrowerForPurgingTest(){
        try{
            String applicantId = [Select id From Applicant__c LIMIT 1].Id;
            Ind_CustomerDedupCtrl.inactivateCoBorrowerForPurging(applicantId);
        }
        catch(Exception e){
            System.debug('exception --' + e);
        }
    }
     @isTest
    public static void saveInvalidCustomerCodeTest(){
        try{
            String applicantId = [Select id From Applicant__c LIMIT 1].Id;
            Ind_CustomerDedupCtrl.saveInvalidCustomerCode(applicantId,'C100234561',true);
            Ind_CustomerDedupCtrl.getApplicantName(applicantId);
        }
        catch(Exception e){
            System.debug('exception --' + e);
        }
    }
    @isTest
    public static void saveInvalidCustomerCodeTest1(){
        try{
            String applicantId = [Select id From Applicant__c LIMIT 1].Id;
            Ind_CustomerDedupCtrl.saveInvalidCustomerCode(applicantId,'C100234561',false);
        }
        catch(Exception e){
            System.debug('exception --' + e);
        }
    }
    
    @isTest
    public static void validateRecentLeadCheckTest1(){
        try{
            String loanApplicationNo =[Select id,Lead_Number__c From Opportunity LIMIT 1].Lead_Number__c;
            Ind_CustomerDedupCtrl.validateRecentLeadCheck(loanApplicationNo);
        }
        catch(Exception e){
            System.debug('exception --' + e);
        }
    }
    @isTest
    public static void validateRecentLeadCheckTest2(){
        try{
            Opportunity oppRecord =[Select id,Lead_Number__c,Product_Type__c,StageName From Opportunity LIMIT 1];
            oppRecord.Product_Type__c = system.label.TwoWheeler;
            oppRecord.StageName = 'Credit Processing';
            update oppRecord;
            Ind_CustomerDedupCtrl.validateRecentLeadCheck(oppRecord.Lead_Number__c);
        }
        catch(Exception e){
            System.debug('exception --' + e);
        }
    }
    @isTest
    public static void validateRecentLeadCheckTest3(){
        try{
            Opportunity oppRecord =[Select id,Lead_Number__c,Product_Type__c,StageName From Opportunity LIMIT 1];
            oppRecord.Product_Type__c = system.label.TwoWheeler;
            oppRecord.StageName = 'Loan Initiation';
            update oppRecord;
            Ind_CustomerDedupCtrl.validateRecentLeadCheck(oppRecord.Lead_Number__c);
        }
        catch(Exception e){
            System.debug('exception --' + e);
        }
    }
    
      @isTest
    public static void checkLeadvalidateByCMUTest(){
        try{
            String loanApplicationId =[Select id,Lead_Number__c From Opportunity LIMIT 1].Id;
            Ind_CustomerDedupCtrl.checkLeadvalidateByCMU(loanApplicationId);
        }
        catch(Exception e){
            System.debug('exception --' + e);
        }
    }
}