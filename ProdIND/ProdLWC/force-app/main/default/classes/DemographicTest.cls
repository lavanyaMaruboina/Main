@isTest(seeAllData = false)
private class DemographicTest { 
    
    /***********************************************************************************************************************
    * @Method Name - testdocDemographicDetails
    * @Created by: Nidhi Dhote
    * @description: testdocDemographicDetails to test insert Demographics details
    ***********************************************************************************************************************/
	/*
        @isTest
    	private static void testdocDemographicDetailsForAdditionalDetails() {
        Opportunity oppObj = TestDataUtility.createTestOpportunity(false);
        insert oppObj;
        Applicant__c applicantObj = TestDataUtility.createTestApplicant(false);
        applicantObj.Opportunity__c= oppObj.Id;
        applicantObj.Applicant_Type__c = System.Label.Borrower;
        insert applicantObj;
        Ind_Demographic.DemographicWrapper addressData =  new Ind_Demographic.DemographicWrapper();
        addressData.preferredAddressForCommunication = 'Home';
        addressData.ofFamilyMembersResidingWithYou = '4';
        addressData.residenceCountry = 'India';
        addressData.whoWillPayTheLoan = 'Borrower';
        addressData.maritalStatus = 'Single';
        addressData.communicationLang = 'Hindi';
        addressData.customerQualification = 'MBBS';
        addressData.spouseName = 'debdwb';
         addressData.applicantId = applicantObj.id;
		addressData.fatherName = 'wodje';
        addressData.motherName = 'mjdsj';
        addressData.emailId = 'jjd@gmail.com';
        addressData.contactNumber = '9879887777';
        String documentId = Ind_Demographic.docDemographicDetails(JSON.serialize(addressData));
        
          List<Applicant__c> docCurrent = [SELECT ID FROM Applicant__c WHERE ID =:documentId];
          System.assertEquals(docCurrent.size() == 1, true);
    }
    */

//--start Method    
    @isTest
    public static void saveAdditionalDetailsTest1(){
        try{
            Account acc = new Account();
            acc.Name = 'Test Acc';
            insert acc;
            
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            opp.AccountId = acc.Id;
            opp.Product_Type__c = System.Label.Tractor;
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            
            Applicant__c applicant = TestDataUtility.createTestApplicantForSMS(false);
            applicant.Opportunity__c = opp.Id;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert applicant;
            }
            
            Documents__c doc11 = TestDataUtility.createTestKYCDocs(false,applicant,opp);
            doc11.Document_Type__c = System.Label.Address_Declaration;
            doc11.KYC_Address_Line_1__c = 'test';
            insert doc11;
            
            Ind_Demographic.DemographicWrapper dw1 = new Ind_Demographic.DemographicWrapper();
            dw1.applicantId = applicant.Id;
            dw1.preferredAddressForCommunication = 'lineone';
            dw1.ofFamilyMembersResidingWithYou = 'yes';
            dw1.residenceCountry = 'India';
            dw1.whoWillPayTheLoan = 'test';
            dw1.maritalStatus = 'SINGP';
            dw1.communicationLang = 'english';
            dw1.customerQualification = 'b.tech';
            dw1.emailId = 'test@gmail.com';
            dw1.spouseName = 'test';
            dw1.fatherName = 'testfather';
            dw1.motherName = 'testmother';
            dw1.contactNumber = '9743514830';
            dw1.relationshipWithBorrower = 'friend';
            dw1.SubmitSuccessfullCheckbox = true;
            dw1.isCustomerNRI = true;
            
            
            Test.startTest();
                Ind_Demographic.saveAdditionalDetails(Json.serialize(dw1));  
            List<Applicant__c> applicantList = [select Id,Opportunity__c,Opportunity__r.OwnerId, Opportunity__r.Name, Opportunity__r.AccountId, Opportunity__r.Product_Type__c, Applicant_Type__c,Applicant__c.Name from Applicant__c where Id =: dw1.applicantId WITH SECURITY_ENFORCED limit 1];
            system.debug('ApplicantList In Test Class ==>'+applicantList);
            
            	opp.Customer_Type__c = 'Non-Individual';
            	update opp;
            
            	dw1.coborrowerResideBorrower = false;
            
            	applicant.Applicant_Type__c = System.Label.Borrower;
            	update applicant;
            
            	Ind_Demographic.saveAdditionalDetails(Json.serialize(dw1));	
            Test.stopTest();
            
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }  
    // End Method---
    
        @isTest
    	private static void testException() {
            try{
    	Opportunity oppObj = TestDataUtility.createTestOpportunity(false);
        insert oppObj;
        Applicant__c applicantObj = TestDataUtility.createTestApplicant(false);
        applicantObj.Opportunity__c= oppObj.Id;
        applicantObj.Applicant_Type__c = System.Label.Borrower;
        insert applicantObj;
        Ind_Demographic.DemographicWrapper addressData =  new Ind_Demographic.DemographicWrapper();
        addressData.preferredAddressForCommunication = 'Home';
        addressData.contactNumber = '9743514830';
        Test.startTest();
           //  String documentId = Ind_Demographic.docDemographicDetails(JSON.serialize(addressData));
        Test.stopTest();
            }
            Catch(Exception e){
                System.assertEquals('Script-thrown exception', e.getMessage());
            }
    }
    
    
    
    @isTest
    private static void getDemographicDetailsPositiveTest() {
        try{
        Opportunity oppObj = TestDataUtility.createTestOpportunity(false);
        insert oppObj;
        Applicant__c applicantObj = TestDataUtility.createTestApplicant(false);
        applicantObj.Opportunity__c= oppObj.Id;
        applicantObj.Applicant_Type__c = System.Label.Borrower;
        insert applicantObj;
        
        Documents__c backDoc = TestDataUtility.createTestKYCDocs(false, applicantObj, oppObj);
        backDoc.Is_Back__c = true;
        backDoc.Document_Type__c = System.Label.PanCards;
        backDoc.Document_Side__c ='Back';
        backDoc.Current_Residential_Address_Proof__c = true;
        backDoc.Content_Document_Count__c = 1;
        insert backDoc;
                
        Documents__c pan = TestDataUtility.createTestKYCDocs(false, applicantObj, oppObj);
        pan.Is_Back__c = true;
        pan.Document_Type__c = System.Label.VoterIdCard;
        pan.Document_Side__c ='Back';
        pan.Permanent_Residential_Address_Proof__c = true;
        pan.Content_Document_Count__c = 1;
        insert pan;
            
        Test.startTest();
        Map<String, Object> mapData = Ind_CustomerAdditionalDetailsCtrl.getAddress(oppObj.Id, System.Label.Borrower, applicantObj.Id);
        Documents__c docObjcurent = mapData.containsKey('currentAddress') ? (Documents__c) mapData.get('currentAddress') : new Documents__c(Current_Residential_Address_Proof__c=true);
        Documents__c docObjcurentPerma = mapData.containsKey('permanentAddress') ? (Documents__c) mapData.get('permanentAddress') : new Documents__c(Permanent_Residential_Address_Proof__c=true);
        Boolean isApplicant = mapData.containsKey('isApplicantPresent') ? (Boolean) mapData.get('isApplicantPresent') : true;
        String applicationNumber = mapData.containsKey('Application_number__c') ? (String) mapData.get('Application_number__c') : '';
        System.assertEquals(docObjcurent.Current_Residential_Address_Proof__c, true);
        System.assertEquals(docObjcurentPerma.Permanent_Residential_Address_Proof__c, true);
        System.assertEquals(isApplicant, true); 
        Test.stopTest();
            
        }
        Catch(Exception e){
                System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    private static void getDemographicDetailsNegativeTest() {
        try{
        Opportunity oppObj = TestDataUtility.createTestOpportunity(false);
        insert oppObj;
            
        Test.startTest();
        Map<String, Object> mapData = Ind_Demographic.getDemographicDetails(null, System.Label.Borrower,null);
        Boolean isApplicant = (Boolean) mapData.get('isApplicantPresent');
        System.assertEquals(isApplicant, false);
        Test.stopTest();
        }
        Catch(Exception e){
                System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }  
    
     @isTest
    private static void getApplicantDetailsPositiveTest() {
        Opportunity oppObj = TestDataUtility.createTestOpportunity(false);
        insert oppObj;
        Applicant__c applicantObj = TestDataUtility.createTestApplicant(false);
        applicantObj.Opportunity__c= oppObj.Id;
        applicantObj.Applicant_Type__c = System.Label.Borrower;
        applicantObj.Income_source_available__c = true;
        insert applicantObj;
        Test.startTest();
        List<Applicant__c> incomeDetails = Ind_Demographic.getApplicantDetails(oppObj.Id);
        System.assertEquals(true, incomeDetails[0].Income_source_available__c);
        Test.stopTest();
    	}  
     @isTest
    private static void getApplicantDetailsNegativeTest() {
        Opportunity oppObj = TestDataUtility.createTestOpportunity(false);
        insert oppObj;
        Applicant__c applicantObj = TestDataUtility.createTestApplicant(false);
        applicantObj.Opportunity__c= oppObj.Id;
        applicantObj.Applicant_Type__c = System.Label.Borrower;
        applicantObj.Income_source_available__c = false;
        insert applicantObj;
        Test.startTest();
        List<Applicant__c> incomeDetails = Ind_Demographic.getApplicantDetails(oppObj.Id);
        System.assertEquals(false, incomeDetails[0].Income_source_available__c);
        Test.stopTest();
    	}  
    
    @isTest
    public static void getDemographicDetailsTest(){
        
                Opportunity opgd1 = new Opportunity();
                opgd1.StageName = 'Qualification';
                opgd1.CloseDate = Date.newInstance(2021, 1, 11);
                opgd1.Name = 'testone';
                insert opgd1;
                
                Applicant__c apgd1 = new Applicant__c();
                apgd1.Opportunity__c = opgd1.Id;
                apgd1.Contact_number__c = '9743514830';
                apgd1.Applicant_Type__c = 'Borrower';
                insert apgd1;
        
                Test.startTest();
                     Ind_Demographic.getDemographicDetails(opgd1.Id,apgd1.Applicant_Type__c, apgd1.Id);
                Test.stopTest();
    }
    
    @isTest
    public static void getcoborrowerSubmitedTest(){
           Opportunity opp1 = TestDataUtility.createTestOpportunity(false);
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp1;
            }
            
             Applicant__c app1 = TestDataUtility.createTestApplicantForSMS(false);
            app1.Opportunity__c = opp1.Id;
            app1.Applicant_Type__c = 'Co-borrower';
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert app1;
            }
        
           Test.startTest();
              //    Ind_Demographic.getcoborrowerSubmited(app1.Applicant_Type__c,opp1.Id);
           Test.stopTest();
        
    }
    
    @isTest
    public static void getAdditionalDetailsSubmittedValueTest(){
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
            
            Test.startTest();
                  Ind_Demographic.getAdditionalDetailsSubmittedValue(opp.Id);
            Test.stopTest();
        }catch(Exception e){
             System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
     @isTest
    public static void getAdditionalDetailsSubmittedValueTest1(){
        try{
            Opportunity opp1 = TestDataUtility.createTestOpportunity(false);
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp1;
            }
            
            Test.startTest();
                  Ind_Demographic.getAdditionalDetailsSubmittedValue(opp1.Id);
                  Ind_Demographic.getAdditionalDetailsSubmittedValue(null);
            Test.stopTest();
        }catch(Exception e){
             System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
 /*   @isTest
    public static void saveAdditionalDetailsTest(){
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
            
            Ind_Demographic.DemographicWrapper dw1 = new Ind_Demographic.DemographicWrapper();
            dw1.applicantId = applicant.Id;
            dw1.preferredAddressForCommunication = 'lineone';
            dw1.ofFamilyMembersResidingWithYou = 'yes';
            dw1.residenceCountry = 'India';
            dw1.whoWillPayTheLoan = 'test';
            dw1.maritalStatus = 'single';
            dw1.communicationLang = 'english';
            dw1.customerQualification = 'b.tech';
            dw1.emailId = 'test@gmail.com';
            dw1.spouseName = 'test';
            dw1.fatherName = 'testfather';
            dw1.motherName = 'testmother';
            dw1.contactNumber = '9743514830';
            dw1.relationshipWithBorrower = 'friend';
            dw1.SubmitSuccessfullCheckbox = true;
            
            Test.startTest();
                 Ind_Demographic.saveAdditionalDetails(Json.serialize(dw1));
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
*/
   @isTest
    public static void creareFICaseSaveAdditionalDetailsTest(){
        try{
            Account acc = new Account();
            acc.Name = 'Test Acc';
            insert acc;
            
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            opp.AccountId =acc.Id;
            opp.Product_Type__c = System.Label.Tractor;
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            
            Applicant__c applicant = TestDataUtility.createTestApplicantForSMS(false);
            applicant.Applicant_Type__c= 'Borrower';
            applicant.Opportunity__c = opp.Id;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert applicant;
            }
            String appName = 'Sameer';
            Applicant__c app =[Select Id, Spouse_Name__c From Applicant__c Where Spouse_Name__c=:appName];
            app.Spouse_Name__c = 'FI TestName';
            update app;

            Ind_Demographic.DemographicWrapper dw1 = new Ind_Demographic.DemographicWrapper();
            dw1.applicantId = app.Id;
            dw1.preferredAddressForCommunication = 'lineone';
            dw1.ofFamilyMembersResidingWithYou = 'yes';
            dw1.residenceCountry = 'India';
            dw1.whoWillPayTheLoan = 'test';
            dw1.maritalStatus = 'MARRIED';
            dw1.communicationLang = 'english';
            dw1.customerQualification = 'b.tech';
            dw1.emailId = 'test@gmail.com';
            dw1.spouseName = 'test';
            dw1.fatherName = 'testfather';
            dw1.motherName = 'testmother';
            dw1.contactNumber = '9743514830';
            dw1.relationshipWithBorrower = 'friend';
            dw1.SubmitSuccessfullCheckbox = true;
            dw1.isCustomerNRI = true;
                  
            Test.startTest();
            //try {
                // Call the saveAdditionalDetails method
                
                Ind_Demographic.saveAdditionalDetails(Json.serialize(dw1));
                System.debug('app.Id==>>>'+app.Id);
                Test.stopTest();

                // Verify the creation of a Case and Field_Investigation__c record
                Case testCase = [SELECT Id FROM Case WHERE Applicant__c = :app.Id];
                System.debug('testCase==>>>'+testCase);
                System.assertNotEquals(null, testCase, 'Case record should be created');
    
                Field_Investigation__c testFieldInvestigation = [SELECT Id FROM Field_Investigation__c WHERE Case__c = :testCase.Id];
                System.debug('testFieldInvestigation==>>>'+testFieldInvestigation);
                System.assertNotEquals(null, testFieldInvestigation, 'Field_Investigation__c record should be created');
            /* } catch (Exception e) {
                //System.assert(false, 'An exception was thrown: ' + e.getMessage());
            } */


        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    
    @isTest
    public static void testMethod1(){
        try{
            Opportunity opp = TestDataUtility.createTestOpportunityForEligibleMaster(true);
            
            Applicant__c app = TestDataUtility.createTestApplicantForDSA(false,opp);
            app.Do_you_have_a_bank_account_with_IBL__c = true;
            app.Nominee_address__c = 'test';
            app.Beneficiary_Office_Address_Line_1__c = 'test';
            app.Beneficiary_Office_City__c = 'test';
            app.Beneficiary_Office_State__c = 'test';
            app.Beneficiary_Office_District__c = 'test';
            app.Beneficiary_Office_Pincode__c = '302018';
            insert app;
            List<String> beneficiaryIds = new List<String>();
            beneficiaryIds.add(app.Id);
            
            Customer_Dedupe_Response__c cusDedupeRes1 = TestDataUtility.createCustomerDedupeResponse(true,app);
            cusDedupeRes1.IND_isNewCustomer__c = true;
            update cusDedupeRes1;
            
            Documents__c doc = TestDataUtility.createTestPPDocs(true,app,opp);
                  
            Test.startTest();
                
                List<Applicant__c> app1 = Ind_Demographic.getAllApplicantList(opp.Id);
            	System.assertEquals(app1[0].Applicant_Type__c,'Borrower');
            
            	Documents__c doc1 = Ind_Demographic.getBorrowerOfficeAddress(opp.Id);
            	System.assertEquals(doc1.KYC_City__c,'Mumbai');
            
            	Boolean flag = Ind_Demographic.isOpenBankAccountWithIBL(app.Id);
            	System.assertEquals(flag,true);
            
            	Boolean flag1 = Ind_Demographic.isNewApplicant(app.Id);
            	System.assertEquals(true,flag1);
            
            	Applicant__c app2 = Ind_Demographic.getApplicantDetailWhoWillRepayTheLaon(app.Id);
            	System.assertEquals(app2.Nominee_address__c,'test');
            
            	app.Applicant_Type__c ='Beneficiary';
            	update app;
            
            	Map<String,Object> result = Ind_Demographic.getApplicantMap(opp.Id);
            	List<String> strList = (List<String>)result.get('beneficiaryId');
            	String beneficiaryId;
            	for(String str : strList){
                	beneficiaryId = str;
            	}
            	System.assertEquals(beneficiaryId,app.Id);
            
            	List<Applicant__c> appList = Ind_Demographic.getBeneOfficeAddress(app.Id);
            	System.assertEquals(appList[0].Beneficiary_Office_Address_Line_1__c,'test');
            
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void documentValidationTest1(){
        try{
            Opportunity opp = TestDataUtility.createTestOpportunityForEligibleMaster(true);
            
            Applicant__c app = TestDataUtility.createTestApplicantForDSA(true,opp);
            
            Documents__c doc = TestDataUtility.createTestKYCDocs(true,app,opp);
                  
            Test.startTest();
                
                String errorMsg1 = Ind_Demographic.documentValidation(app.Id,'Proprietorship',false);
            	System.assertEquals('Please upload any 2 of these documents- GST,MSME REGISTRATION CERTIFICATE,UDYAM REGISTRATION CERTIFICATE,REGISTRATION CERTIFICATE (ANY),SHOPS & ESTABLISHMENT CERTIFICATE,TAX/SERVICE TAX/PROFESSIONAL TAX AUTH,FACTORY REGISTRATION CERTIFICATE,CERTIFICATE ISSUED BY STATE/CENTRAL/LOCAL AUTHORITIES,TRADE LICENCE,IMPORT & EXPORT CERTIFICATE',errorMsg1);
            
            	Documents__c doc4 = TestDataUtility.createTestKYCDocs(false,app,opp);
            	doc4.Document_Type__c = 'REGISTRATION CERTIFICATE - OTHERS';
            	insert doc4;
            
            	Documents__c doc5 = TestDataUtility.createTestKYCDocs(false,app,opp);
            	doc5.Document_Type__c = 'SHOPS AND ESTABLISHMENT CERTIFICATE';
            	insert doc5;
            	
				/*String errorMsg2 = Ind_Demographic.documentValidation(app.Id,'Proprietorship',false);
            	System.assertEquals('Please upload Utlity bill in the name of company document',errorMsg2);*/
            
            	Documents__c doc1 = TestDataUtility.createTestKYCDocs(false,app,opp);
            	doc1.Document_Type__c = 'Utility bill in the name of company';
            	insert doc1;
            
            	String errorMsg3 = Ind_Demographic.documentValidation(app.Id,'Proprietorship',false);
            	System.assertEquals('Please upload PAN Document',errorMsg3);
            
            //=====================================================
            
            	List<Documents__c> docList = [Select Id,Document_Type__c From Documents__c Where Applicant__c =: app.Id and Document_Type__c IN('REGISTRATION CERTIFICATE - OTHERS','SHOPS AND ESTABLISHMENT CERTIFICATE','Utility bill in the name of company')];
            	delete docList;
            
            	String errorMsg4 = Ind_Demographic.documentValidation(app.Id,'Partnership',false);
            	System.assertEquals('Please upload any of these documents- GST,MSME REGISTRATION CERTIFICATE,UDYAM REGISTRATION CERTIFICATE,REGISTRATION CERTIFICATE (ANY),SHOPS & ESTABLISHMENT CERTIFICATE,TAX/SERVICE TAX/PROFESSIONAL TAX AUTH,FACTORY REGISTRATION CERTIFICATE,CERTIFICATE ISSUED BY STATE/CENTRAL/LOCAL AUTHORITIES,TRADE LICENCE,IMPORT & EXPORT CERTIFICATE',errorMsg4);
            
            	Documents__c doc6 = TestDataUtility.createTestKYCDocs(false,app,opp);
            	doc6.Document_Type__c = 'SHOPS AND ESTABLISHMENT CERTIFICATE';
            	insert doc6;
            	
				/*String errorMsg5 = Ind_Demographic.documentValidation(app.Id,'Partnership',false);
            	System.assertEquals('Please upload Utlity bill in the name of company document',errorMsg5);*/
            
            	Documents__c doc7 = TestDataUtility.createTestKYCDocs(false,app,opp);
            	doc7.Document_Type__c = 'Utility bill in the name of company';
            	insert doc7;
            
            	String errorMsg6 = Ind_Demographic.documentValidation(app.Id,'Partnership',false);
            	System.assertEquals('Please upload Partnership Deed Document',errorMsg6);
            
            	Documents__c doc8 = TestDataUtility.createTestKYCDocs(false,app,opp);
            	doc8.Document_Type__c = 'PARTNERSHIP DEED';
            	insert doc8;
            
            	String errorMsg7 = Ind_Demographic.documentValidation(app.Id,'Partnership',false);
            	System.assertEquals('Please upload PAN Document',errorMsg7);
            
            	Documents__c doc9 = TestDataUtility.createTestKYCDocs(false,app,opp);
            	doc9.Document_Type__c = 'PAN';
            	insert doc9;
            
            	String errorMsg8 = Ind_Demographic.documentValidation(app.Id,'Partnership',false);
            	System.assertEquals('Please upload List of Partners Document',errorMsg8);
            
            	Documents__c doc10 = TestDataUtility.createTestKYCDocs(false,app,opp);
            	doc10.Document_Type__c = 'List of Partners';
            	insert doc10;
            
            	String errorMsg9 = Ind_Demographic.documentValidation(app.Id,'Partnership',false);
            	System.assertEquals('Please upload PARTNERSHIP REGISTRATION CERT/PARTNERSHIP LETTER Document',errorMsg9);
            
            	Documents__c doc11 = TestDataUtility.createTestKYCDocs(false,app,opp);
            	doc11.Document_Type__c = 'PARTNERSHIP REGISTRATION CERT';
            	insert doc11;
            
            	String errorMsg10 = Ind_Demographic.documentValidation(app.Id,'Partnership',false);
            	System.assertEquals('Please upload Beneficial Ownership Declaration Document',errorMsg10);
            
            //=====================================================
            
            	List<Documents__c> docList1 = [Select Id,Document_Type__c From Documents__c Where Applicant__c =: app.Id and Document_Type__c IN('REGISTRATION CERTIFICATE - OTHERS','SHOPS AND ESTABLISHMENT CERTIFICATE','Utility bill in the name of company','PAN')];
            	delete docList1;
            
            	String errorMsg11 = Ind_Demographic.documentValidation(app.Id,'Public Ltd',false);
            	System.assertEquals('Please upload any of these documents- GST,MSME REGISTRATION CERTIFICATE,UDYAM REGISTRATION CERTIFICATE,REGISTRATION CERTIFICATE (ANY),SHOPS & ESTABLISHMENT CERTIFICATE,TAX/SERVICE TAX/PROFESSIONAL TAX AUTH,FACTORY REGISTRATION CERTIFICATE,CERTIFICATE ISSUED BY STATE/CENTRAL/LOCAL AUTHORITIES,TRADE LICENCE,IMPORT & EXPORT CERTIFICATE',errorMsg11);
            
            	Documents__c doc12 = TestDataUtility.createTestKYCDocs(false,app,opp);
            	doc12.Document_Type__c = 'SHOPS AND ESTABLISHMENT CERTIFICATE';
            	insert doc12;
            	
				/*String errorMsg12 = Ind_Demographic.documentValidation(app.Id,'Public Ltd',false);
            	System.assertEquals('Please upload Utlity bill in the name of company document',errorMsg12);*/
            
            	Documents__c doc71 = TestDataUtility.createTestKYCDocs(false,app,opp);
            	doc71.Document_Type__c = 'Utility bill in the name of company';
            	insert doc71;
            
            	String errorMsg61 = Ind_Demographic.documentValidation(app.Id,'Public Ltd',false);
            	System.assertEquals('Please upload PAN Document',errorMsg61);
            
            	Documents__c doc81 = TestDataUtility.createTestKYCDocs(false,app,opp);
            	doc81.Document_Type__c = 'PAN';
            	insert doc81;
            
            	String errorMsg71 = Ind_Demographic.documentValidation(app.Id,'Public Ltd',false);
            	System.assertEquals('Please upload CERTIFICATE OF INCORPORATION Document',errorMsg71);
            
            	Documents__c doc91 = TestDataUtility.createTestKYCDocs(false,app,opp);
            	doc91.Document_Type__c = 'CERTIFICATE OF INCORPORATION';
            	insert doc91;
            
            	String errorMsg81 = Ind_Demographic.documentValidation(app.Id,'Public Ltd',false);
            	System.assertEquals('Please upload MEMORANDUM OF ASSOCIATION Document',errorMsg81);
            
            	Documents__c doc101 = TestDataUtility.createTestKYCDocs(false,app,opp);
            	doc101.Document_Type__c = 'MEMORANDUM OF ASSOCIATION';
            	insert doc101;
            
            	String errorMsg91 = Ind_Demographic.documentValidation(app.Id,'Public Ltd',false);
            	System.assertEquals('Please upload ARTICLES OF ASSOCIATION Document',errorMsg91);
            
            	Documents__c doc111 = TestDataUtility.createTestKYCDocs(false,app,opp);
            	doc111.Document_Type__c = 'ARTICLES OF ASSOCIATION';
            	insert doc111;
            
            	String errorMsg101 = Ind_Demographic.documentValidation(app.Id,'Public Ltd',false);
            	System.assertEquals('Please upload Board Resolution Document',errorMsg101);
            
            	Documents__c doc112 = TestDataUtility.createTestKYCDocs(false,app,opp);
            	doc112.Document_Type__c = 'Board Resolution';
            	insert doc112;
            
            	String errorMsg102 = Ind_Demographic.documentValidation(app.Id,'Public Ltd',false);
            	System.assertEquals('Please upload List of Directors Document',errorMsg102);
            
            	Documents__c doc113 = TestDataUtility.createTestKYCDocs(false,app,opp);
            	doc113.Document_Type__c = 'List of Directors';
            	insert doc113;
            
            	String errorMsg103 = Ind_Demographic.documentValidation(app.Id,'Public Ltd',false);
            	System.assertEquals('Please upload Beneficial Ownership Declaration Document',errorMsg103);
            
            //=====================================================
            
            	List<Documents__c> docList2 = [Select Id,Document_Type__c From Documents__c Where Applicant__c =: app.Id and Document_Type__c IN('REGISTRATION CERTIFICATE - OTHERS','SHOPS AND ESTABLISHMENT CERTIFICATE','Utility bill in the name of company','PAN','CERTIFICATE OF INCORPORATION','Board Resolution','PARTNERSHIP REGISTRATION CERT','List of Partners')];
            	delete docList2;
            
            	String errorMsg311 = Ind_Demographic.documentValidation(app.Id,'Limited Liability Partnership',false);
            	System.assertEquals('Please upload any of these documents- GST,MSME REGISTRATION CERTIFICATE,UDYAM REGISTRATION CERTIFICATE,REGISTRATION CERTIFICATE (ANY),SHOPS & ESTABLISHMENT CERTIFICATE,TAX/SERVICE TAX/PROFESSIONAL TAX AUTH,FACTORY REGISTRATION CERTIFICATE,CERTIFICATE ISSUED BY STATE/CENTRAL/LOCAL AUTHORITIES,TRADE LICENCE,IMPORT & EXPORT CERTIFICATE',errorMsg311);
            
            	Documents__c doc31 = TestDataUtility.createTestKYCDocs(false,app,opp);
            	doc31.Document_Type__c = 'SHOPS AND ESTABLISHMENT CERTIFICATE';
            	insert doc31;
            	
				/*String errorMsg31 = Ind_Demographic.documentValidation(app.Id,'Limited Liability Partnership',false);
            	System.assertEquals('Please upload Utlity bill in the name of company document',errorMsg31);*/
            
            	Documents__c doc32 = TestDataUtility.createTestKYCDocs(false,app,opp);
            	doc32.Document_Type__c = 'Utility bill in the name of company';
            	insert doc32;
            
            	String errorMsg32 = Ind_Demographic.documentValidation(app.Id,'Limited Liability Partnership',false);
            	System.assertEquals('Please upload PAN Document',errorMsg32);
            
            	Documents__c doc33 = TestDataUtility.createTestKYCDocs(false,app,opp);
            	doc33.Document_Type__c = 'PAN';
            	insert doc33;
            
            	String errorMsg33 = Ind_Demographic.documentValidation(app.Id,'Limited Liability Partnership',false);
            	System.assertEquals('Please upload CERTIFICATE OF INCORPORATION Document',errorMsg33);
            
            	Documents__c doc34 = TestDataUtility.createTestKYCDocs(false,app,opp);
            	doc34.Document_Type__c = 'CERTIFICATE OF INCORPORATION';
            	insert doc34;
            
            	String errorMsg34 = Ind_Demographic.documentValidation(app.Id,'Limited Liability Partnership',false);
            	System.assertEquals('Please upload LLP Agreement Document',errorMsg34);
            
            	Documents__c doc35 = TestDataUtility.createTestKYCDocs(false,app,opp);
            	doc35.Document_Type__c = 'LLP Agreement';
            	insert doc35;
            
            	String errorMsg35 = Ind_Demographic.documentValidation(app.Id,'Limited Liability Partnership',false);
            	System.assertEquals('Please upload Board Resolution/Partnership letter',errorMsg35);
            
            	Documents__c doc36a = TestDataUtility.createTestKYCDocs(false,app,opp);
            	doc36a.Document_Type__c = 'PARTNERSHIP REGISTRATION CERT';
            	insert doc36a;
           		Documents__c doc36b = TestDataUtility.createTestKYCDocs(false,app,opp);
            	doc36b.Document_Type__c = 'Board Resolution';
            	insert doc36b;
            
            	String errorMsg36 = Ind_Demographic.documentValidation(app.Id,'Limited Liability Partnership',false);
            	System.assertEquals('Please upload List of Partners Document',errorMsg36);
            
            	Documents__c doc37 = TestDataUtility.createTestKYCDocs(false,app,opp);
            	doc37.Document_Type__c = 'List of Partners';
            	insert doc37;
            
            	String errorMsg37 = Ind_Demographic.documentValidation(app.Id,'Limited Liability Partnership',false);
            	System.assertEquals('Please upload Beneficial Ownership Declaration Document',errorMsg37);
            
            //=====================================================
            
            	List<Documents__c> docList3 = [Select Id,Document_Type__c From Documents__c Where Applicant__c =: app.Id and Document_Type__c IN('REGISTRATION CERTIFICATE - OTHERS','SHOPS AND ESTABLISHMENT CERTIFICATE','Utility bill in the name of company','PAN','CERTIFICATE OF INCORPORATION','Board Resolution','PARTNERSHIP REGISTRATION CERT','List of Partners')];
            	delete docList3;
            
            	String errorMsg41 = Ind_Demographic.documentValidation(app.Id,'Trust',false);
            	System.assertEquals('Please upload PAN Document',errorMsg41);
            
            	Documents__c doc42 = TestDataUtility.createTestKYCDocs(false,app,opp);
            	doc42.Document_Type__c = 'PAN';
            	insert doc42;
            
            	String errorMsg42 = Ind_Demographic.documentValidation(app.Id,'Trust',false);
            	System.assertEquals('Please upload REGISTRATION CERTIFICATE (ANY) Document',errorMsg42);
            
            	Documents__c doc43 = TestDataUtility.createTestKYCDocs(false,app,opp);
            	doc43.Document_Type__c = 'REGISTRATION CERTIFICATE - OTHERS';
            	insert doc43;
            	
				String errorMsg43 = Ind_Demographic.documentValidation(app.Id,'Trust',false);
            	System.assertEquals('Please upload Board Resolution Document',errorMsg43);
            
            	Documents__c doc44 = TestDataUtility.createTestKYCDocs(false,app,opp);
            	doc44.Document_Type__c = 'Board Resolution';
            	insert doc44;
            
            	/*String errorMsg44 = Ind_Demographic.documentValidation(app.Id,'Trust',false);
            	System.assertEquals('Please upload Utlity bill in the name of company document',errorMsg44);*/
            
            	Documents__c doc45 = TestDataUtility.createTestKYCDocs(false,app,opp);
            	doc45.Document_Type__c = 'Utility bill in the name of company';
            	insert doc45;
            
            	String errorMsg45 = Ind_Demographic.documentValidation(app.Id,'Trust',false);
            	System.assertEquals('Please upload List of Trustees/Office Bearers Document',errorMsg45);
            
            	Documents__c doc46 = TestDataUtility.createTestKYCDocs(false,app,opp);
            	doc46.Document_Type__c = 'List of Trustees/Office Bearers';
            	insert doc46;
            
            	String errorMsg46 = Ind_Demographic.documentValidation(app.Id,'Trust',false);
            	System.assertEquals('Please upload Beneficial Ownership Declaration Document',errorMsg46);
            
            	Documents__c doc47 = TestDataUtility.createTestKYCDocs(false,app,opp);
            	doc47.Document_Type__c = 'Beneficial Ownership Declaration';
            	insert doc47;
            
            	String errorMsg47 = Ind_Demographic.documentValidation(app.Id,'Trust',false);
            	System.assertEquals('Please upload Trust Deed/Bye law document',errorMsg47);
            	
            //=====================================================
            
            	List<Documents__c> docList4 = [Select Id,Document_Type__c From Documents__c Where Applicant__c =: app.Id and Document_Type__c IN('REGISTRATION CERTIFICATE - OTHERS','SHOPS AND ESTABLISHMENT CERTIFICATE','Utility bill in the name of company','PAN','CERTIFICATE OF INCORPORATION','Board Resolution','PARTNERSHIP REGISTRATION CERT','List of Partners')];
            	delete docList4;
            
            	String errorMsg51 = Ind_Demographic.documentValidation(app.Id,'HUF',false);
            	System.assertEquals('Please upload any of these documents- GST,MSME REGISTRATION CERTIFICATE,UDYAM REGISTRATION CERTIFICATE,REGISTRATION CERTIFICATE (ANY),SHOPS & ESTABLISHMENT CERTIFICATE,TAX/SERVICE TAX/PROFESSIONAL TAX AUTH,FACTORY REGISTRATION CERTIFICATE,CERTIFICATE ISSUED BY STATE/CENTRAL/LOCAL AUTHORITIES,TRADE LICENCE,IMPORT & EXPORT CERTIFICATE',errorMsg51);            	
            
            	Documents__c doc52 = TestDataUtility.createTestKYCDocs(false,app,opp);
            	doc52.Document_Type__c = 'SHOPS AND ESTABLISHMENT CERTIFICATE';
            	insert doc52;
            	
				String errorMsg52 = Ind_Demographic.documentValidation(app.Id,'HUF',false);
            	System.assertEquals('Please upload PAN Document',errorMsg52);
            
            	Documents__c doc53 = TestDataUtility.createTestKYCDocs(false,app,opp);
            	doc53.Document_Type__c = 'PAN';
            	insert doc53;
            	
				String errorMsg53 = Ind_Demographic.documentValidation(app.Id,'HUF',false);
            	System.assertEquals('Please upload List of Co-Percenters Document',errorMsg53);
            
            	Documents__c doc54 = TestDataUtility.createTestKYCDocs(false,app,opp);
            	doc54.Document_Type__c = 'List of Co-Percenters';
            	insert doc54;
            
            	/*String errorMsg54 = Ind_Demographic.documentValidation(app.Id,'HUF',false);
            	System.assertEquals('Please upload Utlity bill in the name of company document',errorMsg54);*/
            
            //=====================================================
            
            	String errorMsg611 = Ind_Demographic.documentValidation(null,null,null);
            	//System.assertEquals('Please upload PAN Document',errorMsg611);
            
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
        
    }
    @isTest
    public static void saveAdditionalDetailsTestForNonInd(){
        try{
            Account acc = new Account();
            acc.Name = 'Test Acc';
            insert acc;
            
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            opp.AccountId = acc.Id;
            opp.Product_Type__c = System.Label.Tractor;
            opp.Customer_Type__c = 'Non-Individual';
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            
            Applicant__c applicant = TestDataUtility.createTestApplicantForSMS(false);
            applicant.Opportunity__c = opp.Id;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert applicant;
            }
            
            Documents__c doc11 = TestDataUtility.createTestKYCDocs(false,applicant,opp);
            doc11.Document_Type__c = System.Label.Address_Declaration;
            doc11.KYC_Address_Line_1__c = 'test';
            insert doc11;
            
            Ind_Demographic.DemographicWrapper dw1 = new Ind_Demographic.DemographicWrapper();
            dw1.applicantId = applicant.Id;
            dw1.preferredAddressForCommunication = 'lineone';
            dw1.ofFamilyMembersResidingWithYou = 'yes';
            dw1.residenceCountry = 'India';
            dw1.whoWillPayTheLoan = 'test';
            dw1.maritalStatus = 'SINGP';
            dw1.communicationLang = 'english';
            dw1.customerQualification = 'b.tech';
            dw1.emailId = 'test@gmail.com';
            dw1.spouseName = 'test';
            dw1.fatherName = 'testfather';
            dw1.motherName = 'testmother';
            dw1.contactNumber = '9743514830';
            dw1.relationshipWithBorrower = 'friend';
            dw1.SubmitSuccessfullCheckbox = true;
            dw1.isCustomerNRI = true;
            
            
            Test.startTest();
                Ind_Demographic.saveAdditionalDetails(Json.serialize(dw1));  
            Test.stopTest();
            
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    } 
    @isTest
    public static void getRiskBandStatusValueTest(){
        try{
            Account acc = new Account();
            acc.Name = 'Test Acc';
            insert acc;
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            opp.AccountId = acc.Id;
            opp.Product_Type__c = System.Label.Tractor;
            opp.Customer_Type__c = 'Non-Individual';
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            
            Applicant__c applicant = TestDataUtility.createTestApplicantForSMS(false);
            applicant.Opportunity__c = opp.Id;
            applicant.Scorecard_Decision__c = 'Red';
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert applicant;
            }
            Retry_Count__c reObj = new Retry_Count__c();
            reObj.Loan_Application_Id__c = opp.Id;
            reObj.Service_Name__c = 'Risk Band';
            reObj.Applicant__c = applicant.Id;
            reObj.Count__c =1;
            insert reObj;
            
            Test.startTest();
                Ind_Demographic.getRiskBandStatusValue(opp.Id); 
            	Ind_Demographic.getApplicant(opp.Id);
            	Ind_Demographic.checkRetryExhausted(opp.Id,'Risk Band',applicant.Id);
            	reObj.Count__c = 0;
            	update reObj;
            Ind_Demographic.checkRetryExhausted(opp.Id,'Risk Band',applicant.Id);
            	delete reObj;
            Ind_Demographic.checkRetryExhausted(opp.Id,'Risk Band',applicant.Id);
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    } 
        
    
 }