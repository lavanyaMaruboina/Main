@isTest
public class DSA_WSControllerTest {
    @TestSetup
    static void setupTestData() {
        UserRole role = TestDataUtility.createUserRole(true, 'test', 'role');
        User us = TestDataUtility.createUserForVoterId(true, role);
        Profile businessProfile = [Select Id from Profile where Name = 'IBL Business Executive'];
        User businessUser = new User(alias = 'testUser', email='testingBusinessUser007@noemail.com', emailencodingkey='UTF-8',
                                     lastname='Testing', languagelocalekey='en_US',localesidkey='en_US', profileid = businessProfile.Id,
                                     country='United States', IsActive =true, timezonesidkey='America/Los_Angeles',
                                     username='testingBusinessUser007@noemail.com.DSAtestuser', Phone= '1000000001', MobilePhone= '1000000001', EmployeeNumber = 'R15928');
        insert businessUser;
        User businessUser2 = new User(alias = 'testUser', email='testingBusinessUser008@noemail.com', emailencodingkey='UTF-8',
                                     lastname='Testing', languagelocalekey='en_US',localesidkey='en_US', profileid = businessProfile.Id,
                                     country='United States', IsActive =true, timezonesidkey='America/Los_Angeles',
                                     username='testingBusinessUser008@noemail.com.DSAtestuser', Phone= '1000000001', MobilePhone= '1000000001', EmployeeNumber = 'R15929');
        insert businessUser2;
        Opportunity opp;
        Applicant__c app;
        Documents__c doc;
        ContentVersion con;
        Contact communityContact;
        Profile_Master__c  profileMaster;
        Account communityAccount;
        system.runAs(us){
            opp = TestDataUtility.createTestOpportunity(true);
            app = TestDataUtility.createTestApplicantForDSA(true, opp);
            doc = TestDataUtility.createTestAadhaarDocs(true, app, opp);
            con = TestDataUtility.createContentVersionforOcrFront('header', true, doc);
            doc.Name = 'Aadhaar';
            update doc;
            profileMaster = new Profile_Master__c(Name = 'Profile Master', Code__c = 'abcd1234abcd123');
            insert profileMaster;
            insert new Income_Details__c(Name= 'Test',Applicant__c = app.Id, Income__c =1000000, Profile__c= profileMaster.Id);
            insert new Customer_Dedupe_Response__c(Response__c = '{"response":{"status":"SUCCESS","respDesc":"IxsightEnquiry","content":[{"Data":{"ExternalDedupeResponse":{"DEDUPE_STATUS":"N","DtCFDCUSTBAS":null,"DtRECENTLEAD":[{"SOURCE_CIC_NO":"2022071906054114415","MATCHED_CIC_NO":"3004202211490893926","MATCHED_LEAD_NAME":"MILAN VERMA Verma","MATCHED_LEAD_DATE":"2022-04-30T11:49:27+05:30","MATCHED_SCORE":"100","MATCHED_CRITERIA":"PAN100"},{"SOURCE_CIC_NO":"2022071906054114415","MATCHED_CIC_NO":"3004202211490893926","MATCHED_LEAD_NAME":"MILAN VERMA Verma","MATCHED_LEAD_DATE":"2022-04-30T11:49:27+05:30","MATCHED_SCORE":"100","MATCHED_CRITERIA":"PAN100"},{"SOURCE_CIC_NO":"2022071906054114415","MATCHED_CIC_NO":"3004202211490893926","MATCHED_LEAD_NAME":"MILAN VERMA Verma","MATCHED_LEAD_DATE":"2022-04-30T11:49:27+05:30","MATCHED_SCORE":"100","MATCHED_CRITERIA":"PAN100"},{"SOURCE_CIC_NO":"2022071906054114415","MATCHED_CIC_NO":"3004202211490893926","MATCHED_LEAD_NAME":"MILAN VERMA Verma","MATCHED_LEAD_DATE":"2022-04-30T11:49:27+05:30","MATCHED_SCORE":"100","MATCHED_CRITERIA":"PAN100"},{"SOURCE_CIC_NO":"2022071906054114415","MATCHED_CIC_NO":"3004202211490893926","MATCHED_LEAD_NAME":"MILAN VERMA Verma","MATCHED_LEAD_DATE":"2022-04-30T11:49:27+05:30","MATCHED_SCORE":"100","MATCHED_CRITERIA":"PAN100"},{"SOURCE_CIC_NO":"2022071906054114415","MATCHED_CIC_NO":"3004202211490893926","MATCHED_LEAD_NAME":"MILAN VERMA Verma","MATCHED_LEAD_DATE":"2022-04-30T11:49:27+05:30","MATCHED_SCORE":"100","MATCHED_CRITERIA":"PAN100"},{"SOURCE_CIC_NO":"2022071906054114415","MATCHED_CIC_NO":"3004202211490893926","MATCHED_LEAD_NAME":"MILAN VERMA Verma","MATCHED_LEAD_DATE":"2022-04-30T11:49:27+05:30","MATCHED_SCORE":"100","MATCHED_CRITERIA":"PAN100"},{"SOURCE_CIC_NO":"2022071906054114415","MATCHED_CIC_NO":"3004202211490893926","MATCHED_LEAD_NAME":"MILAN VERMA Verma","MATCHED_LEAD_DATE":"2022-04-30T11:49:27+05:30","MATCHED_SCORE":"100","MATCHED_CRITERIA":"PAN100"},{"SOURCE_CIC_NO":"2022071906054114415","MATCHED_CIC_NO":"3004202211490893926","MATCHED_LEAD_NAME":"MILAN VERMA Verma","MATCHED_LEAD_DATE":"2022-04-30T11:49:27+05:30","MATCHED_SCORE":"100","MATCHED_CRITERIA":"PAN100"},{"SOURCE_CIC_NO":"2022071906054114415","MATCHED_CIC_NO":"3004202211490893926","MATCHED_LEAD_NAME":"MILAN VERMA Verma","MATCHED_LEAD_DATE":"2022-04-30T11:49:27+05:30","MATCHED_SCORE":"100","MATCHED_CRITERIA":"PAN100"},{"SOURCE_CIC_NO":"2022071906054114415","MATCHED_CIC_NO":"3004202211490893926","MATCHED_LEAD_NAME":"MILAN VERMA Verma","MATCHED_LEAD_DATE":"2022-04-30T11:49:27+05:30","MATCHED_SCORE":"100","MATCHED_CRITERIA":"PAN100"},{"SOURCE_CIC_NO":"2022071906054114415","MATCHED_CIC_NO":"3004202211490893926","MATCHED_LEAD_NAME":"MILAN VERMA Verma","MATCHED_LEAD_DATE":"2022-04-30T11:49:27+05:30","MATCHED_SCORE":"100","MATCHED_CRITERIA":"PAN100"},{"SOURCE_CIC_NO":"2022071906054114415","MATCHED_CIC_NO":"3004202211490893926","MATCHED_LEAD_NAME":"MILAN VERMA Verma","MATCHED_LEAD_DATE":"2022-04-30T11:49:27+05:30","MATCHED_SCORE":"100","MATCHED_CRITERIA":"PAN100"},{"SOURCE_CIC_NO":"2022071906054114415","MATCHED_CIC_NO":"3004202211490893926","MATCHED_LEAD_NAME":"MILAN VERMA Verma","MATCHED_LEAD_DATE":"2022-04-30T11:49:27+05:30","MATCHED_SCORE":"100","MATCHED_CRITERIA":"PAN100"},{"SOURCE_CIC_NO":"2022071906054114415","MATCHED_CIC_NO":"3004202211490893926","MATCHED_LEAD_NAME":"MILAN VERMA Verma","MATCHED_LEAD_DATE":"2022-04-30T11:49:27+05:30","MATCHED_SCORE":"100","MATCHED_CRITERIA":"PAN100"},{"SOURCE_CIC_NO":"2022071906054114415","MATCHED_CIC_NO":"3004202211490893926","MATCHED_LEAD_NAME":"MILAN VERMA Verma","MATCHED_LEAD_DATE":"2022-04-30T11:49:27+05:30","MATCHED_SCORE":"100","MATCHED_CRITERIA":"PAN100"}],"CustomerValidate":null},"InternalDedupeResponse":[{"CustomerMaster":[{"CIC_No":"CW1719108","Matched_Customer_Code":"CW1719108","Rule_Matching_Fields":"PAN","Current_Parameter_Value":"AATPV2055K","Matched_Parameter_Value":"AATPV2055K","Matched_Score":"100","Rule_Field_Weightage":"100","Matched_Source":"CFD","Active_Flag":"Y","Dedupe_Super_Match":"Y","Dedupe_Super_Match_Score":"100","Rule_Id":"PAN100","Type":"C","PEP_Remarks":"","Customer_Name":null,"Customer_Type":null,"Date_of_Birth":null,"PAN_GIR_Number":null,"Passport_Number":null,"Voter_ID_Number":null,"Driving_License_Number":null,"Aadhaar_No":null}],"CustomerValidate":[{"CustomerCodeVal":"CW1719108","CustomerMaster":[{"CIC_No":null,"Matched_Customer_Code":null,"Rule_Matching_Fields":null,"Current_Parameter_Value":null,"Matched_Parameter_Value":null,"Matched_Score":null,"Rule_Field_Weightage":null,"Matched_Source":null,"Active_Flag":null,"Dedupe_Super_Match":null,"Dedupe_Super_Match_Score":null,"Rule_Id":null,"Type":null,"PEP_Remarks":null,"Customer_Name":"MILAN VERMA","Customer_Type":"10","Date_of_Birth":"26-01-1968 00:00:00","PAN_GIR_Number":"AATPV2055K","Passport_Number":"","Voter_ID_Number":"","Driving_License_Number":"","Aadhaar_No":"400899451521"}],"CustomerStatus":[{"Cross_Dedupe_Match_Id":"39573483","Active_Flag":"Y"}],"Dealstatus":[{"Deal_No":"IRD00176C","Status_Flag":"L"},{"Deal_No":"IRD00209C","Status_Flag":"L"}],"NPA":[{"REFERENCE_NO":"IRD00176C","NPATYPE":"Sub Standard"},{"REFERENCE_NO":"IRD00209C","NPATYPE":"Sub Standard"}],"Restructure":[],"Gecl":[],"ARC":[],"PanAlert":[],"CINAlert":[],"BeneficiaryAlert":{"Ben_code":null,"Beneficiary":null,"Status_Flag":null,"PAN_No":null}}]}]},"ErrorDesc":""}]}}', Applicant__c = app.Id);
            communityAccount = new Account(Name = 'test Account Community 1234', BranchBLCode__c = 'AAL');
            insert communityAccount;
            communityContact = new Contact(FirstName = 'Test', LastName = 'Test', Email = 'test@testing.com', Phone = '0000000000', AccountId = communityAccount.Id);
            insert communityContact;
            system.debug('con : '+con);
            insert new DSA_Preferred_BE_Mapping__c(Ben_code__c = 'BEN096897', Name = 'a1WFf0000001p8X', Ben_name__c = 'TestLastName', Email_ID__c = 'test123@noemail.com',
                                                   Phone_No__c = '1000000001', Preferred_BE_Name__c = 'Testing', Emp_Id__c = 'R15928', Active_Flag__c = true);
        }
        Profile dsaProfile = [Select Id from Profile where Name = 'DSA Community User'];
        User user = new User(alias = 'test123', email='test123@noemail.com', emailencodingkey='UTF-8', lastname='TestLastName', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = dsaProfile.Id, country='United States', IsActive =true, ContactId = communityContact.Id, EmployeeNumber = 'BEN096897',
                             timezonesidkey='America/Los_Angeles', username='testerCommunity123DSA@noemail.com.DSAtestuser', Phone= '1000000001', MobilePhone= '1000000001');
        insert user;
        System.runAs(us) {
            insert new AccountTeamMember(AccountId = communityAccount.Id, UserId = businessUser.Id);
            insert new AccountTeamMember(AccountId = communityAccount.Id, UserId = businessUser2.Id);
            Benefi__c benCode = new Benefi__c(Ben_code__c = 'BEN096897', Status_Flag__c = 'L');
            insert benCode;
            Bl_Code_Details__c blCodeDetails = new Bl_Code_Details__c(Bl_Code__c = 'AAL');
            insert blCodeDetails;
            Beneficiary_BlCode__c beneblCode = new Beneficiary_BlCode__c(Ben_code__c = benCode.Id, Bl_Code_Details__c = blCodeDetails.Id, Unique_Identifier__c = 'ABC');
            insert beneblCode;
            BE_Master__c beMaster = new BE_Master__c();
            beMaster.Pin_Code__c = 302018;
            beMaster.BL_Code__c = 'AAL';
            beMaster.Employee_Id__c = businessUser2.EmployeeNumber;
            beMaster.Name = 'NANDLAL';
            beMaster.State__c = 'HARYANA';
            beMaster.Product_Type__c = 'Passenger Vehicles';
            insert beMaster;
            Final_Term__c ft = new Final_Term__c();
            ft.OfferengineMinLoanAmount__c = 10000;
            ft.Advance_EMI__c = true;
            ft.Loan_Application__c = opp.Id;
            ft.OfferengineMaxLoanAmount__c = 10000;
            ft.Loan_Amount__c = '10000';
            ft.Net_IRR__c = 10000;
            ft.EMI_Amount__c = 1000;
            ft.Inputted_IRR__c = 77;
            insert ft;

        }
    }

    @isTest
    static void test_initializeNewLeadData() {
        try {
            Test.startTest();
            DSA_WSController wsController = new DSA_WSController();
            List<Geo_State_Masters__c> states = wsController.getStateCityMaster();
            Test.stopTest();
        } catch (Exception e) {}
    }

    @isTest
    static void testGetBEDetails() {
        Opportunity opp = [select Id from Opportunity where Name= 'Opportunity' limit 1];
        Applicant__c app = [select Id from Applicant__c where Opportunity__c =: opp.Id];
        User us = [select Id from User where Email = 'test123@noemail.com'];
        Test.startTest();
        DSA_WSController wsController = new DSA_WSController();
        Map<Id,String>  beDetails = wsController.GetBEDetails(us.Id, app.Id);
        Test.stopTest();
    }

    @isTest
    static void testGetBEDetailsException() {
        try {
            Opportunity opp = [select Id from Opportunity where Name= 'Opportunity' limit 1];
            Applicant__c app = [select Id from Applicant__c where Opportunity__c =: opp.Id];
            User us = [select Id from User where Email = 'test123@noemail.com'];
            Test.startTest();
            DSA_WSController wsController = new DSA_WSController();
            Map<Id,String>  beDetails = wsController.GetBEDetails(app.Id, us.Id);
            Test.stopTest();
        } catch (Exception e) {}
    }

    @isTest
    static void testDsaToBEAssignment() {
        Opportunity opp = [select Id from Opportunity where Name= 'Opportunity' limit 1];
        User us = [select Id from User where Email = 'testingBusinessUser007@noemail.com'];
        Test.startTest();
        try{
        DSA_WSController wsController = new DSA_WSController();
        String abc = wsController.dsaToBEAssignment(opp.Id, us.Id);
         wsController.dsaToBEAssignment(null,null);
        }  
        catch(Exception ex){
            system.assertEquals(ex.getMessage(),'Script-thrown exception');
        }
        Test.stopTest();
    }

    @isTest
    static void testGetLoanByRecordId() {
        Opportunity opp = [select Id from Opportunity where Name= 'Opportunity' limit 1];
        Test.startTest();
        DSA_WSController wsController = new DSA_WSController();
        IND_DSAController.DSA_NewLeadWrapper abc = wsController.getLoanByRecordId(opp.Id);
        Test.stopTest();
    }

    @isTest
    static void testGetLoanByRecordIdException() {
        try {
            Test.startTest();
            DSA_WSController wsController = new DSA_WSController();
            IND_DSAController.DSA_NewLeadWrapper abc = wsController.getLoanByRecordId(null);
            Test.stopTest();
        } catch (Exception e) {}
    }

    @isTest
    static void testGetRCLimitData() {
       
        Test.startTest();
         User u =[Select Id,Username, EmployeeNumber From User Where Username='testingBusinessUser007@noemail.com.DSAtestuser' Limit 1];
         System.runAs(u){
             MIS_RC_Limit_TopSheet__c mrl= new MIS_RC_Limit_TopSheet__c();
             mrl.Max_Limit__c=1; 
             mrl.Max_Amount__c=1;
             mrl.Max_Days__c=1;
             mrl.RC_Pending__c=1;
             mrl.Fin_Amt__c=1;
             insert mrl;
             
        DSA_WSController wsController = new DSA_WSController();
        Map<String, String> abc = wsController.getRCLimitData();
         }
        Test.stopTest();
        
    }
    
    
        @isTest
    static void testGetRCLimitDataNegative() {
       
        Test.startTest();
          try{
        DSA_WSController wsController = new DSA_WSController();
        Map<String, String> abc = wsController.getRCLimitData();
                }
        catch(Exception ex){
            system.assertEquals(ex.getMessage(),'Script-thrown exception');
        }
        Test.stopTest();
        
    }
     @isTest
    static void testDeleteCoBorrower() {
       
        Test.startTest();
        try{
      Applicant__c app= [Select Id From Applicant__c Limit 1];
        DSA_WSController.deleteCoBorrower(app.Id);
        app.Name='test2';
        app.Applicant_Type__c='Co-borrower';
        update app;
          DSA_WSController.deleteCoBorrower(app.Id);
         DSA_WSController.deleteCoBorrower(null);
        }
        catch(Exception ex){
            system.assertEquals(ex.getMessage(),'Script-thrown exception');
        }
        
        Test.stopTest();
        
    }
    
}