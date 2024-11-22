@isTest
public class IND_DSAControllerTest {
    @TestSetup
    static void setupTestData() {
        UserRole role = TestDataUtility.createUserRole(true, 'test', 'role');
        User us = TestDataUtility.createUserForVoterId(true, role);
        Opportunity opp;
        Applicant__c app;
        Documents__c doc;
        ContentVersion con;
        Contact communityContact;
        Profile_Master__c  profileMaster;

        system.runAs(us){
        	opp = TestDataUtility.createTestOpportunity(true);
            app = TestDataUtility.createTestApplicantService(true, opp);
            doc = TestDataUtility.createTestAadhaarDocs(true, app, opp);
            con = TestDataUtility.createContentVersionforOcrFront('header', true, doc);
            doc.Name = 'Aadhaar';
        	update doc;
            profileMaster = new Profile_Master__c(Name = 'Profile Master', Code__c = 'abcd1234abcd123');
            insert profileMaster;
            insert new Income_Details__c(Name= 'Test',Applicant__c = app.Id, Income__c =1000000, Profile__c= profileMaster.Id);
            insert new Customer_Dedupe_Response__c(Response__c = '{"response":{"status":"SUCCESS","respDesc":"IxsightEnquiry","content":[{"Data":{"ExternalDedupeResponse":{"DEDUPE_STATUS":"N","DtCFDCUSTBAS":null,"DtRECENTLEAD":[{"SOURCE_CIC_NO":"2022071906054114415","MATCHED_CIC_NO":"3004202211490893926","MATCHED_LEAD_NAME":"MILAN VERMA Verma","MATCHED_LEAD_DATE":"2022-04-30T11:49:27+05:30","MATCHED_SCORE":"100","MATCHED_CRITERIA":"PAN100"},{"SOURCE_CIC_NO":"2022071906054114415","MATCHED_CIC_NO":"3004202211490893926","MATCHED_LEAD_NAME":"MILAN VERMA Verma","MATCHED_LEAD_DATE":"2022-04-30T11:49:27+05:30","MATCHED_SCORE":"100","MATCHED_CRITERIA":"PAN100"},{"SOURCE_CIC_NO":"2022071906054114415","MATCHED_CIC_NO":"3004202211490893926","MATCHED_LEAD_NAME":"MILAN VERMA Verma","MATCHED_LEAD_DATE":"2022-04-30T11:49:27+05:30","MATCHED_SCORE":"100","MATCHED_CRITERIA":"PAN100"},{"SOURCE_CIC_NO":"2022071906054114415","MATCHED_CIC_NO":"3004202211490893926","MATCHED_LEAD_NAME":"MILAN VERMA Verma","MATCHED_LEAD_DATE":"2022-04-30T11:49:27+05:30","MATCHED_SCORE":"100","MATCHED_CRITERIA":"PAN100"},{"SOURCE_CIC_NO":"2022071906054114415","MATCHED_CIC_NO":"3004202211490893926","MATCHED_LEAD_NAME":"MILAN VERMA Verma","MATCHED_LEAD_DATE":"2022-04-30T11:49:27+05:30","MATCHED_SCORE":"100","MATCHED_CRITERIA":"PAN100"},{"SOURCE_CIC_NO":"2022071906054114415","MATCHED_CIC_NO":"3004202211490893926","MATCHED_LEAD_NAME":"MILAN VERMA Verma","MATCHED_LEAD_DATE":"2022-04-30T11:49:27+05:30","MATCHED_SCORE":"100","MATCHED_CRITERIA":"PAN100"},{"SOURCE_CIC_NO":"2022071906054114415","MATCHED_CIC_NO":"3004202211490893926","MATCHED_LEAD_NAME":"MILAN VERMA Verma","MATCHED_LEAD_DATE":"2022-04-30T11:49:27+05:30","MATCHED_SCORE":"100","MATCHED_CRITERIA":"PAN100"},{"SOURCE_CIC_NO":"2022071906054114415","MATCHED_CIC_NO":"3004202211490893926","MATCHED_LEAD_NAME":"MILAN VERMA Verma","MATCHED_LEAD_DATE":"2022-04-30T11:49:27+05:30","MATCHED_SCORE":"100","MATCHED_CRITERIA":"PAN100"},{"SOURCE_CIC_NO":"2022071906054114415","MATCHED_CIC_NO":"3004202211490893926","MATCHED_LEAD_NAME":"MILAN VERMA Verma","MATCHED_LEAD_DATE":"2022-04-30T11:49:27+05:30","MATCHED_SCORE":"100","MATCHED_CRITERIA":"PAN100"},{"SOURCE_CIC_NO":"2022071906054114415","MATCHED_CIC_NO":"3004202211490893926","MATCHED_LEAD_NAME":"MILAN VERMA Verma","MATCHED_LEAD_DATE":"2022-04-30T11:49:27+05:30","MATCHED_SCORE":"100","MATCHED_CRITERIA":"PAN100"},{"SOURCE_CIC_NO":"2022071906054114415","MATCHED_CIC_NO":"3004202211490893926","MATCHED_LEAD_NAME":"MILAN VERMA Verma","MATCHED_LEAD_DATE":"2022-04-30T11:49:27+05:30","MATCHED_SCORE":"100","MATCHED_CRITERIA":"PAN100"},{"SOURCE_CIC_NO":"2022071906054114415","MATCHED_CIC_NO":"3004202211490893926","MATCHED_LEAD_NAME":"MILAN VERMA Verma","MATCHED_LEAD_DATE":"2022-04-30T11:49:27+05:30","MATCHED_SCORE":"100","MATCHED_CRITERIA":"PAN100"},{"SOURCE_CIC_NO":"2022071906054114415","MATCHED_CIC_NO":"3004202211490893926","MATCHED_LEAD_NAME":"MILAN VERMA Verma","MATCHED_LEAD_DATE":"2022-04-30T11:49:27+05:30","MATCHED_SCORE":"100","MATCHED_CRITERIA":"PAN100"},{"SOURCE_CIC_NO":"2022071906054114415","MATCHED_CIC_NO":"3004202211490893926","MATCHED_LEAD_NAME":"MILAN VERMA Verma","MATCHED_LEAD_DATE":"2022-04-30T11:49:27+05:30","MATCHED_SCORE":"100","MATCHED_CRITERIA":"PAN100"},{"SOURCE_CIC_NO":"2022071906054114415","MATCHED_CIC_NO":"3004202211490893926","MATCHED_LEAD_NAME":"MILAN VERMA Verma","MATCHED_LEAD_DATE":"2022-04-30T11:49:27+05:30","MATCHED_SCORE":"100","MATCHED_CRITERIA":"PAN100"},{"SOURCE_CIC_NO":"2022071906054114415","MATCHED_CIC_NO":"3004202211490893926","MATCHED_LEAD_NAME":"MILAN VERMA Verma","MATCHED_LEAD_DATE":"2022-04-30T11:49:27+05:30","MATCHED_SCORE":"100","MATCHED_CRITERIA":"PAN100"}],"CustomerValidate":null},"InternalDedupeResponse":[{"CustomerMaster":[{"CIC_No":"CW1719108","Matched_Customer_Code":"CW1719108","Rule_Matching_Fields":"PAN","Current_Parameter_Value":"AATPV2055K","Matched_Parameter_Value":"AATPV2055K","Matched_Score":"100","Rule_Field_Weightage":"100","Matched_Source":"CFD","Active_Flag":"Y","Dedupe_Super_Match":"Y","Dedupe_Super_Match_Score":"100","Rule_Id":"PAN100","Type":"C","PEP_Remarks":"","Customer_Name":null,"Customer_Type":null,"Date_of_Birth":null,"PAN_GIR_Number":null,"Passport_Number":null,"Voter_ID_Number":null,"Driving_License_Number":null,"Aadhaar_No":null}],"CustomerValidate":[{"CustomerCodeVal":"CW1719108","CustomerMaster":[{"CIC_No":null,"Matched_Customer_Code":null,"Rule_Matching_Fields":null,"Current_Parameter_Value":null,"Matched_Parameter_Value":null,"Matched_Score":null,"Rule_Field_Weightage":null,"Matched_Source":null,"Active_Flag":null,"Dedupe_Super_Match":null,"Dedupe_Super_Match_Score":null,"Rule_Id":null,"Type":null,"PEP_Remarks":null,"Customer_Name":"MILAN VERMA","Customer_Type":"10","Date_of_Birth":"26-01-1968 00:00:00","PAN_GIR_Number":"AATPV2055K","Passport_Number":"","Voter_ID_Number":"","Driving_License_Number":"","Aadhaar_No":"400899451521"}],"CustomerStatus":[{"Cross_Dedupe_Match_Id":"39573483","Active_Flag":"Y"}],"Dealstatus":[{"Deal_No":"IRD00176C","Status_Flag":"L"},{"Deal_No":"IRD00209C","Status_Flag":"L"}],"NPA":[{"REFERENCE_NO":"IRD00176C","NPATYPE":"Sub Standard"},{"REFERENCE_NO":"IRD00209C","NPATYPE":"Sub Standard"}],"Restructure":[],"Gecl":[],"ARC":[],"PanAlert":[],"CINAlert":[],"BeneficiaryAlert":{"Ben_code":null,"Beneficiary":null,"Status_Flag":null,"PAN_No":null}}]}]},"ErrorDesc":""}]}}', Applicant__c = app.Id);
            Account communityAccount = new Account(Name = 'test Account Community 1234');
        	insert communityAccount;
        	communityContact = new Contact(FirstName = 'Test', LastName = 'Test', Email = 'test@testing.com', Phone = '0000000000', AccountId = communityAccount.Id);
        	insert communityContact;
            system.debug('con : '+con);
        }
        Profile dsaProfile = [Select Id from Profile where Name = 'DSA Community User'];
        User user = new User(alias = 'test123', email='test123@noemail.com', emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',localesidkey='en_US', profileid = dsaProfile.Id, country='United States', IsActive =true, ContactId = communityContact.Id, timezonesidkey='America/Los_Angeles', username='testerCommunity123DSA@noemail.com.DSAtestuser', Phone= '1000000001', MobilePhone= '1000000001');
        insert user;
    }

    @isTest
    static void test_initializeNewLeadData() {
        try {
            Test.startTest();
            IND_DSAController.DSA_NewLeadWrapper wrapper = IND_DSAController.initializeNewLeadData();
            Test.stopTest();
            System.assert(
                wrapper != null,
                'initializeNewLeadData returned null'
            );
            System.assert(
                wrapper.opp.Id != null,
                'initializeNewLeadData opp creation failed'
            );
        } catch (Exception e) {
            System.assert(
                false,
                e.getMessage() +
                ' ' +
                e.getStackTraceString()
            );
        }
    }
    /**
    @isTest
    private static void testgetWSControllerInstance(){
        IND_DSAController.DSA_WSController result = IND_DSAController.getWSControllerInstance();
    }*/

    @isTest
    private static void testuploadDocumentCntrl(){
        Boolean exceptionOccurred = false;
        try{
            Opportunity opp = [select Id from Opportunity where Name= 'Opportunity' limit 1];
        	Applicant__c app = [select Id from Applicant__c where Opportunity__c =: opp.Id];
            User us = [select Id from User where Email = 'testuser000@amamama.com'];
            ContentVersion con = TestDataUtility.createContentVersion('header', true);
        	String res = IND_DSAController.uploadDocumentCntrl('Aadhaar',opp.Id,app.Id,true,con.Id,us.Id);
       	 } catch (Exception e) {
            exceptionOccurred = true;
        }
        System.assert(exceptionOccurred, 'An Exception was not thrown');
    }
  
    
    @isTest
    private static void testdeleteDocAndFile(){
        Boolean exceptionOccurred = false;
        Opportunity opp = [select Id from Opportunity where Name= 'Opportunity' limit 1];
        Applicant__c app = [select Id from Applicant__c where Opportunity__c =: opp.Id];
        Documents__c doc = [select Id from Documents__c where Applicant__c =: app.id AND Opportunity_Relation__c =: opp.Id];
        try{
            Test.startTest();
			IND_DSAController.deleteDocAndFile(doc.Id, true);
        	Test.stopTest();
            IND_DSAController.deleteDocAndFile('1123445678', true);
        } catch (Exception e) {
            exceptionOccurred = true;
        }
        System.assert(exceptionOccurred, 'An Exception was not thrown');

    }

    @isTest
    private static void testdeleteContentDocument(){
        Opportunity opp = [select Id from Opportunity where Name= 'Opportunity' limit 1];
        Applicant__c app = [select Id from Applicant__c where Opportunity__c =: opp.Id];
        User us = [select Id from User where Email = 'testuser000@amamama.com'];
        //try{
            Test.startTest();
			IND_DSAController.deleteContentDocument(opp.Id, app.Id, 'Aadhaar', us.Id);
			IND_DSAController.deleteContentDocument(app.Id, opp.Id, 'Aadhaar', us.Id);
        	Test.stopTest();
            //IND_DSAController.deleteContentDocument('1123445678', '1123445678', 'Aadhaar', us.Id);
       /* } catch (Exception e) {
            exceptionOccurred = true;
        }
        System.assert(exceptionOccurred, 'An Exception was not thrown');*/
    }

    @isTest
    private static void testcreatedocument(){
        Boolean exceptionOccurred = false;
        Opportunity opp = [select Id from Opportunity where Name= 'Opportunity' limit 1];
        Applicant__c app = [select Id from Applicant__c where Opportunity__c =: opp.Id];
        try{
            Test.startTest();
			Id result = IND_DSAController.createdocument('Aadhaar', opp.Id, app.Id, true, '012710000002SrRAAU');
        	Test.stopTest();
            Id result1 = IND_DSAController.createdocument('Aadhaar', '1123445678', app.Id, true, '1123445678');
        } catch (Exception e) {
            exceptionOccurred = true;
        }
        System.assert(exceptionOccurred, 'An Exception was not thrown');
    }

    @isTest
    private static void testcreateContentDocumentLink(){
        Opportunity opp = [select Id from Opportunity where Name= 'Opportunity' limit 1];
        Applicant__c app = [select Id from Applicant__c where Opportunity__c =: opp.Id];
        Documents__c doc = [select Id from Documents__c where Applicant__c =: app.id AND Opportunity_Relation__c =: opp.Id];
        ContentVersion con = TestDataUtility.createContentVersion('header', true);
        ContentVersion con2 = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id =: con.Id LIMIT 1];
        Test.startTest();
		Id result = IND_DSAController.createContentDocumentLink(doc.Id, con2.ContentDocumentId, 'V');
        Test.stopTest();
    }

    @isTest
    private static void testgetDocumentDetails(){
		Opportunity opp = [select Id from Opportunity where Name= 'Opportunity' limit 1];
        Applicant__c app = [select Id from Applicant__c where Opportunity__c =: opp.Id];
        Test.startTest();
		String result = IND_DSAController.getDocumentDetails(app.Id, opp.Id, 'Aadhaar');
		String result2 = IND_DSAController.getDocumentDetails(opp.Id, app.Id, 'Aadhaar');
        Test.stopTest();

    }

    @isTest
    private static void testgetContentVersion(){
        Opportunity opp = [select Id from Opportunity where Name= 'Opportunity' limit 1];
        Applicant__c app = [select Id from Applicant__c where Opportunity__c =: opp.Id];
        Test.startTest();
		List<ContentVersion> result = IND_DSAController.getContentVersion(opp.Id, app.Id, 'Aadhaar');
        Test.stopTest();
    }

    @isTest
    private static void testgetDcoumentRecords(){
        Opportunity opp = [select Id from Opportunity where Name= 'Opportunity' limit 1];
        Applicant__c app = [select Id from Applicant__c where Opportunity__c =: opp.Id];
        Test.startTest();
		String result = IND_DSAController.getDcoumentRecords(opp.Id, app.Id);
        Test.stopTest();
    }

    @isTest
    private static void testcreateCoborrowerScreening(){
        Opportunity opp = [select Id from Opportunity where Name= 'Opportunity' limit 1];
        Applicant__c app = [select Id from Applicant__c where Opportunity__c =: opp.Id];
        Test.startTest();
        try {
            IND_DSAController.createCoborrowerScreening(opp.Id, app.Id, '1000000');
		    IND_DSAController.createCoborrowerScreening(app.Id, opp.Id, '1000000');
        } catch (Exception e) {
            System.debug('error');
        }
        Test.stopTest();
    }

    /*@isTest
    private static void testgetLoanByRecordId(){
        Opportunity opp = [select Id from Opportunity where Name= 'Opportunity' limit 1];
        Test.startTest();
		IND_DSAController.DSA_NewLeadWrapper res = IND_DSAController.getLoanByRecordId(opp.Id);
        Test.stopTest();
    }*/

    @isTest
    private static void testsaveLead(){
        Opportunity opp = [select Id from Opportunity where Name= 'Opportunity' limit 1];
        Test.startTest();
		IND_DSAController.DSA_NewLeadWrapper res = IND_DSAController.getLoanByRecordId(opp.Id);
        String param = JSON.serialize(res);
        String result = IND_DSAController.saveLead(param);
        Test.stopTest();

    }

	@isTest
    private static void testgetRetryCount(){
        Opportunity opp = [select Id from Opportunity where Name= 'Opportunity' limit 1];
        Test.startTest();
		String res = IND_DSAController.getRetryCount(opp.Id, 'Borrower', 'Count__c','Retry_Count');
        Test.stopTest();
    }

    /*@isTest
    private static void testcreateCoBorrower(){
        Opportunity opp = [select Id from Opportunity where Name= 'Opportunity' limit 1];
        Applicant__c app = [select Id from Applicant__c where Opportunity__c =: opp.Id];
        List<String> fields = new List<String>{'1000000','SAL','ADVOCATE','10000000','10000'};
        Test.startTest();
		//String coBorrId = IND_DSAController.createCoBorrower(app.Id, fields);
        Test.stopTest();
    }*/

    @isTest
    private static void testsaveAssetDetails(){
        Opportunity opp = [select Id from Opportunity where Name= 'Opportunity' limit 1];
        Applicant__c app = [select Id from Applicant__c where Opportunity__c =: opp.Id];
        List<String> fields = new List<String>{'TATA','M&M KUV100','M&M KUV100 NXT K8 DIESEL','10000000','500000','TATA','TATA','P7'};
        Vehicle_Detail__c vd = TestDataUtility.createTestVehicleDetailForIbb(true,opp);
        Test.startTest();
		IND_DSAController.saveAssetDetails(app.Id, vd.Id, fields);
        Test.stopTest();
    }


    @isTest
    private static void testgetProducts(){
        Test.startTest();
        List<Product2> res = IND_DSAController.getProducts('Make', 'Honda');
        List<Product2> res1 = IND_DSAController.getProducts('Model', 'Honda');
        Test.stopTest();
    }
    @isTest
    private static void testgetAssetFieldValues(){
        //List<String> res1 = IND_DSAController.getAssetFieldValues('TATA','M&M KUV100');
        //List<String> res2 = IND_DSAController.getAssetFieldValues('TATA',null);
    }

    @isTest
    private static void testgetStateCityMaster(){
        Test.startTest();
        List<Geo_State_Masters__c> res = IND_DSAController.getStateCityMaster();
        Test.stopTest();
    }

    @isTest
    private static void testgetProfile(){
        Test.startTest();
        List<Profile_Master__c> res = IND_DSAController.getProfile('SEP');
        List<Profile_Master__c> res1 = IND_DSAController.getProfile('SAL');
        List<Profile_Master__c> res2 = IND_DSAController.getProfile('SENP');
        List<Profile_Master__c> res3 = IND_DSAController.getProfile('TEST');
        Test.stopTest();
    }

    @isTest
    private static void testassignToBE(){
        try{
        	Opportunity opp = [select Id from Opportunity where Name= 'Opportunity' limit 1];
            User communityUser = [select Id from User where username='testerCommunity123DSA@noemail.com.DSAtestuser'];
            Test.startTest();
        	String res = IND_DSAController.assignToBE(opp.Id, communityUser.Id);
            Test.stopTest();
        } catch (Exception e) {
            System.assertequals('Script-thrown exception', e.getMessage());
        }
    }

    @isTest
    private static void testvalidateCustomerCode(){
        try{
        	Opportunity opp = [select Id from Opportunity where Name= 'Opportunity' limit 1];
            Applicant__c app = [select Id from Applicant__c where Opportunity__c =: opp.Id];
            Test.startTest();
        	String res = IND_DSAController.validateCustomerCode(app.Id, true);
            String res2 = IND_DSAController.validateCustomerCode(app.Id, false);
            String res3 = IND_DSAController.validateCustomerCode(opp.Id, true);
            Test.stopTest();
            
        } catch (Exception e) {
            System.assertequals('Script-thrown exception', e.getMessage());
        }
    }

    @isTest
    private static void testgetRCLimitData(){
        try{
            Test.startTest();
            Map<String, String> res = IND_DSAController.getRCLimitData();
            Test.stopTest();
        }catch (Exception e) {
            System.assertequals('Script-thrown exception', e.getMessage());
        }
    }

    @isTest
    private static void testcreateCoBorrower(){
        try{
            Opportunity opp = [select Id from Opportunity where Name= 'Opportunity' limit 1];
            Applicant__c app = [select Id from Applicant__c where Opportunity__c =: opp.Id];
            Documents__c doc = [select Id from Documents__c where Applicant__c =: app.id AND Opportunity_Relation__c =: opp.Id];
            List<string> fields = new List<String>{'Earning','SEP','ADVOCATE','1000000','10000'};
            Test.startTest();
            String result = IND_DSAController.createCoBorrower(app.Id, null, fields);
            String result1 = IND_DSAController.createCoBorrower(null, app.Id, fields);
            Test.stopTest();
        }catch (Exception e) {
            System.assertequals('Script-thrown exception', e.getMessage());
        }
    }

    @isTest
    private static void testGetApplicantDetails(){
        User us = [select Id from User where Email = 'testuser000@amamama.com' limit 1];
        system.runAs(us){
        Opportunity opp = [select Id from Opportunity where Name= 'Opportunity' limit 1];
        Test.startTest();
        List<Applicant__c> applicants = IND_DSAController.getApplicantDetails(opp.Id);
        Test.stopTest();
        }
    }

    @isTest
    private static void testGetBEDetails(){
        Opportunity opp = [select Id from Opportunity where Name= 'Opportunity' limit 1];
        Applicant__c app = [select Id from Applicant__c where Opportunity__c =: opp.Id];
        User us = [select Id from User where Email = 'testuser000@amamama.com'];
        Test.startTest();
        try {
            Map<Id,String> beDetails = IND_DSAController.GetBEDetails(us.Id, app.Id);
        } catch (Exception e) {
            System.assertequals('Script-thrown exception', e.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    private static void testGetIncomeDetailsByRecordId(){
        Opportunity opp = [select Id from Opportunity where Name= 'Opportunity' limit 1];
        Test.startTest();
        List<Applicant__c> applicants = IND_DSAController.getIncomeDetailsByRecordId(opp.Id);
        Test.stopTest();
    }

    @isTest
    private static void testGetAssetDetailsByRecordId(){
        Opportunity opp = [select Id from Opportunity where Name= 'Opportunity' limit 1];
        Test.startTest();
        Opportunity opportunity = IND_DSAController.getAssetDetailsByRecordId(opp.Id);
        Test.stopTest();
    }

    @isTest
    private static void testGetOfferDetailsByRecordId(){
        Opportunity opp = [select Id from Opportunity where Name= 'Opportunity' limit 1];
        Test.startTest();
        Opportunity opportunity = IND_DSAController.getOfferDetailsByRecordId(opp.Id);
        Test.stopTest();
    }

    @isTest
    private static void testGetDocumentdetailsByRecordId(){
        Opportunity opp = [select Id from Opportunity where Name= 'Opportunity' limit 1];
        Test.startTest();
        Documents__c doc = IND_DSAController.getDocumentdetailsByRecordId(opp.Id);
        Test.stopTest();
    }

    @isTest
    private static void testSendEmailToBE(){
        Test.startTest();
        IND_DSAController.sendEmailToBE('test@testing.com', 'testName', 'LeadName');
        Test.stopTest();
    }
}