@isTest
public class IHMPageControllerTest 
{
    @testSetup 
    static void testDataSetup() 
    {
        //create user
        Profile p = [SELECT Id FROM Profile WHERE Name='IBL CVO'];
        User u = new User(Alias = 'standt2', Email='standarduser2@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,Maker_Id__c='12',IsActive = true,
                          TimeZoneSidKey='America/Los_Angeles',UserName='test_userprod12321@indusbank.com',MobilePhone = '9089078967');
        insert u;
        System.runAs(u) 
        {
            // Create Opportunity
            Opportunity opp = TestDataUtility.createTestOpportunityForOcr(false);
            //opp.StageName = System.Label.Credit_Processing;
            opp.Sub_Stage__c = System.Label.Field_Investigation;
            opp.StageName = 'Post Sanction Checks and Documentation';
            opp.Is_Mobile_Journey_Completed__c = true;
            opp.Vehicle_Type__c = System.Label.used;
            opp.Product_Type__c = System.Label.TwoWheeler;
            opp.Sanction_Status__c = System.Label.nonStp;
            insert opp; 
            
            //Create Deal_Number_Setting__c
            Deal_Number_Setting__c dlNumberSetting= new Deal_Number_Setting__c();
            dlNumberSetting.Name = System.Label.TwoWheeler;
            dlNumberSetting.MDNField1__c ='AB';
            dlNumberSetting.MDNField2__c =2;
            insert dlNumberSetting;
            system.debug('Deal Setting'+ dlNumberSetting);
            
            //create Deal_Number__c
            Deal_Number__c dl = new Deal_Number__c();
            dl.Loan_Application__c = opp.Id;
            dl.DNField1__c = dlNumberSetting.MDNField1__c;
            dl.DNField2__c = String.valueOf(dlNumberSetting.MDNField2__c);
            dl.Sub_Stage__c = 'RC Upload';
            insert dl;
            
            //IHM Insert
            IHM__c ihmObj = new IHM__c();
            ihmObj.Loan_Application__c = opp.Id;
            ihmObj.Total_amount_customer_paid_to_bank_E__c = 234;
            insert ihmObj;
            
            // Create Applicant__c
            Applicant__c applicant = TestDataUtility.createTestApplicantForMFCValuation(false, opp);
            applicant.Willing_to_open_Bank_Account_with_IIB__c = true;
            applicant.Applicant_Type__c = 'Borrower';
            applicant.Customer_Qualification__c = 'B1';
            applicant.Marital_status__c = 'MARR';
            insert applicant;
            
            //create Vehicle_Detail__c record            
            Vehicle_Detail__c  vehicleDetail = TestDataUtility.createTestVehicleDetailForIbb(false, opp);
            vehicleDetail.Deal_Number__c = dl.Id;
            if (Schema.sObjectType.Vehicle_Detail__c.isCreateable()){
                insert vehicleDetail;
            }
            
            //Create Invoice Details 
            Invoice_Details__c invoice = new Invoice_Details__c();
            invoice.Loan_Application__c = opp.Id;
            invoice.Invoice_Amount_incl_discounts__c=1000;
            insert invoice;
            
            //Create Final Term
            Final_Term__c ft = new Final_Term__c();
            ft.Loan_Application__c = opp.Id;
            ft.Loan_Amount__c='100000';
            insert ft;    
            
            // Create Document
            Documents__c doc1 = TestDataUtility.createTestKYCDocsForOcrFront(false, applicant, opp);
            doc1.Document_Type__c = System.Label.AadhaarCard;
            doc1.Addresss_Type__c = System.Label.Document_Office_Address_Type;
            doc1.Is_Active__c = true;
            doc1.Name = 'IHM Receipt';
            doc1.Aadhar_Source__c = 'OTP';
            insert doc1;
            
            //Create content version
            ContentVersion contentVersion = new ContentVersion(
                Title          = 'testfname',
                PathOnClient   = 'Pic.jpg',
                VersionData    = Blob.valueOf('Test Content'),
                IsMajorVersion = true);
            insert contentVersion; 
            List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
            
            //create ContentDocumentLink  record
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.LinkedEntityId = opp.Id;
            cdl.ContentDocumentId = documents[0].Id;
            cdl.ShareType = 'V';
            cdl.Visibility = 'AllUsers';
            insert cdl;
            
            //Create Retry Count
            Retry_Count__c retryCount = new Retry_Count__c(Count__c = 3, Loan_Application_Id__c = opp.Id, 
                                                           Service_Name__c = 'Retry_Count', Applicant__c = applicant.Id, Applicant_Type__c = 'Borrower',
                                                           User_Id__c = UserInfo.getUserId(), Module__c = 'Test Module');         
            insert retryCount;
            
            //Create Loan Application Transaction History
            Loan_Application_Transaction_History__c loanAppHis = new Loan_Application_Transaction_History__c(//Name = System.Label.Repayment_Mandate, 
                                                                                                             Screen__c = System.Label.Repayment_Mandate,
                                                                                                             Module__c = 'Post Sanction Checks and Documentation',
                                                                                                             Submitted_Flag__c = false,
                                                                                                             Loan_Application_ID__c = opp.Id);
            insert loanAppHis;
            
            // Create Loan agreement        
            Loan_Agreement__c la = new Loan_Agreement__c(e_agreement_Agreement_Signed_For_Borrowe__c = 'Yes', 
                                                         Loan_Application__c = opp.Id);
            insert la;
        }
    }
    
    @isTest
    public static void getIHMDetailsTest(){
        try
        {
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod12321@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {
                Opportunity oppRec = [SELECT Id, Vehicle_Type__c, Product_Type__c FROM Opportunity WHERE Vehicle_Type__c = 'Used' LIMIT 1]; 
                oppRec.StageName = System.label.Pre_Disbursement_Check;
                update oppRec;
                Deal_Number__c dealId = [select id from Deal_Number__c where Loan_Application__c =: oppRec.Id limit 1];
                
                Loan_Application_Transaction_History__c loanAppHis = [Select Id, Submitted_Flag__c, Name, Screen__c, Module__c
                                                                      From Loan_Application_Transaction_History__c Where 
                                                                      Loan_Application_ID__c =: oppRec.Id LIMIT 1];
                // loanAppHis.Name = System.Label.Pre_Disbursement_Check;
                loanAppHis.Screen__c = System.Label.IHM;
                loanAppHis.Module__c = System.Label.Pre_Disbursement_Check;
                loanAppHis.Deal_Number__c = dealId.Id;
                update loanAppHis; 
                
                IHMPageController.IHMWrapper resultWrapper = IHMPageController.getIHMDetails(oppRec.Id, dealId.Id);
                System.assertNotEquals(null, resultWrapper);
                
                oppRec.Product_Type__c = 'Tractor';
                update oppRec;
                
                IHMPageController.IHMWrapper resultWrapper1 = IHMPageController.getIHMDetails(oppRec.Id, dealId.Id);
                System.assertNotEquals(null, resultWrapper1);
            }
            Test.stopTest();                          
        }catch(Exception e){
            system.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void getIHMDetailsTest1(){
        try
        {
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod12321@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {
                Opportunity oppRec = [SELECT Id, Vehicle_Type__c, Product_Type__c FROM Opportunity WHERE Vehicle_Type__c = 'Used' LIMIT 1]; 
                oppRec.StageName = System.label.Post_Sanction_Checks_and_Documentation;
                update oppRec;
                Deal_Number__c dealId = [select id from Deal_Number__c where Loan_Application__c =: oppRec.Id limit 1];
                
                Loan_Application_Transaction_History__c loanAppHis = [Select Id, Submitted_Flag__c, Name, Screen__c, Module__c
                                                                      From Loan_Application_Transaction_History__c Where 
                                                                      Loan_Application_ID__c =: oppRec.Id LIMIT 1];
                // loanAppHis.Name = System.Label.Post_Sanction_Checks_and_Documentation;
                loanAppHis.Screen__c = System.Label.IHM;
                loanAppHis.Module__c = System.Label.Post_Sanction_Checks_and_Documentation;
                loanAppHis.Submitted_Flag__c = false;
                loanAppHis.Deal_Number__c = dealId.Id;
                update loanAppHis; 
                
                IHMPageController.IHMWrapper resultWrapper = IHMPageController.getIHMDetails(oppRec.Id, dealId.Id);
                System.assertNotEquals(null, resultWrapper);
            }
            Test.stopTest();                          
        }catch(Exception e){
            system.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void getIHMDetailsTest2(){
        try
        {
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod12321@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {
                Opportunity oppRec = [SELECT Id, Vehicle_Type__c, Product_Type__c FROM Opportunity WHERE Vehicle_Type__c = 'Used' LIMIT 1]; 
                oppRec.StageName = System.Label.Pre_Disbursement_Check;
                update oppRec;
                Deal_Number__c dealId = [select id from Deal_Number__c where Loan_Application__c =: oppRec.Id limit 1];

                Loan_Application_Transaction_History__c loanAppHis = [Select Id, Submitted_Flag__c, Name, Screen__c, Module__c
                                                                      From Loan_Application_Transaction_History__c Where 
                                                                      Loan_Application_ID__c =: oppRec.Id LIMIT 1];
                // loanAppHis.Name = System.Label.Pre_Disbursement_Check;
                loanAppHis.Screen__c = System.Label.IHM;
                loanAppHis.Module__c = System.Label.Post_Sanction_Checks_and_Documentation;
                loanAppHis.Submitted_Flag__c = false;
                loanAppHis.Deal_Number__c = dealId.Id;
                update loanAppHis; 
                
                IHMPageController.IHMWrapper resultWrapper = IHMPageController.getIHMDetails(oppRec.Id, dealId.Id);
                //System.assertNotEquals(null, resultWrapper);
            }
            Test.stopTest();                          
        }catch(Exception e){
            system.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void documentFilesTest(){
        try
        {
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod12321@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {
                Opportunity oppRec = [SELECT Id, Vehicle_Type__c, Product_Type__c FROM Opportunity WHERE Vehicle_Type__c = 'Used' LIMIT 1];     
                Deal_Number__c dealId = [select id from Deal_Number__c where Loan_Application__c =: oppRec.Id limit 1];
                
                List<Documents__c> docList = IHMPageController.documentFiles(oppRec.Id, dealId.Id);
                System.assertNotEquals(null, docList);
                
                oppRec.Product_Type__c = 'Tractor';
                update oppRec;
                
                List<Documents__c> docList1 = IHMPageController.documentFiles(oppRec.Id, dealId.Id);
                
            }
            Test.stopTest();                          
        }catch(Exception e){
            system.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void insertDocumentTest(){
        try
        {            
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod12321@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {
                Opportunity oppRec = [Select id From Opportunity LIMIT 1];
                Documents__c docRec = [Select Id,Applicant__r.Applicant_Type__c,Document_Type__c,KYC_State__c,KYC_Pin_Code__c,KYC_District__c,KYC_City__c,KYC_Address_Line_2__c,
                                       KYC_Address_Line_1__c,Current_Residential_Address_Proof__c,Permanent_Residential_Address_Proof__c from Documents__c
                                       where Document_Type__c =: System.Label.AadhaarCard LIMIT 1];
                Deal_Number__c dealId = [select id from Deal_Number__c where Loan_Application__c =: oppRec.Id limit 1];
                
                IHMPageController.insertDocument(JSON.serialize(docRec), oppRec.Id, dealId.Id);
                
                oppRec.Product_Type__c = 'Tractor';
                update oppRec;
                
                IHMPageController.insertDocument(JSON.serialize(docRec), oppRec.Id, dealId.Id);

            }
            Test.stopTest();
        }catch(Exception e){
            system.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void deleteDocumentTest(){
        try
        {            
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod12321@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {
                Opportunity oppRec = [Select id From Opportunity LIMIT 1];
                Documents__c docRec = [SELECT Id FROM Documents__c
                                       WHERE Document_Type__c =: System.Label.AadhaarCard LIMIT 1];
                Deal_Number__c dealId = [select id from Deal_Number__c where Loan_Application__c =: oppRec.Id limit 1];
                
                Boolean result = IHMPageController.deleteDocument(docRec.Id,oppRec.Id, dealId.Id);
                system.assertEquals(true, result);
                
                oppRec.Product_Type__c = 'Tractor';
                update oppRec;
                
                Boolean result1 = IHMPageController.deleteDocument(docRec.Id,oppRec.Id, dealId.Id);
                system.assertEquals(true, result1);
            }
            Test.stopTest();
        }catch(Exception e){
            system.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void validateScreenVisiblityTest1(){
        try{
            
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod12321@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {
                Opportunity oppRec = [SELECT Id, Vehicle_Type__c, Product_Type__c FROM Opportunity WHERE Vehicle_Type__c = 'Used' LIMIT 1]; 
                Deal_Number__c dealId = [select id from Deal_Number__c where Loan_Application__c =: oppRec.Id limit 1];

                IHMPageController.ValidateWrapper resultWrapper = IHMPageController.validateScreenVisiblity(oppRec.Id, dealId.Id);
                system.assertNotEquals(null, resultWrapper);
            }
            Test.stopTest();
        }catch(Exception e){
            system.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void validateScreenVisiblityTest2(){
        try{
            
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod12321@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {
                Opportunity oppRec = [SELECT Id, stageName FROM Opportunity WHERE Vehicle_Type__c = 'Used' LIMIT 1];      
                oppRec.stageName = 'Pre Disbursement Check';
                update oppRec;
                
                Deal_Number__c dealId = [select id from Deal_Number__c where Loan_Application__c =: oppRec.Id limit 1];

                Loan_Application_Transaction_History__c loanAppHis = [Select Id, Submitted_Flag__c, Name, Screen__c, Module__c
                                                                      From Loan_Application_Transaction_History__c Where 
                                                                      Loan_Application_ID__c =: oppRec.Id LIMIT 1];
                // loanAppHis.Name = 'RTO, DPN, POA Documents Upload';
                loanAppHis.Screen__c = 'RTO, DPN, POA Documents Upload';
                loanAppHis.Module__c = 'Pre Disbursement Check';
                loanAppHis.Deal_Number__c = dealId.Id;
                update loanAppHis; 
                
                IHMPageController.ValidateWrapper resultWrapper = IHMPageController.validateScreenVisiblity(oppRec.Id, dealId.Id);
                system.assertNotEquals(null, resultWrapper);
            }
            Test.stopTest();
        }catch(Exception e){
            system.assertEquals('Script-thrown exception', e.getMessage());
            system.debug('line--'+e.getLineNumber());
        }
    }
    
    @isTest
    public static void checkIfReadOnlyTest(){
        try{            
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod12321@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {
                Opportunity oppRec = [SELECT Id, stageName FROM Opportunity WHERE Vehicle_Type__c = 'Used' LIMIT 1]; 
                Loan_Application_Transaction_History__c loanAppHis = [Select Id, Submitted_Flag__c, Name, Screen__c, Module__c
                                                                      From Loan_Application_Transaction_History__c Where 
                                                                      Loan_Application_ID__c =: oppRec.Id LIMIT 1];
                Deal_Number__c dealId = [select id from Deal_Number__c where Loan_Application__c =: oppRec.Id limit 1];
                // loanAppHis.Name = 'IHM';
                loanAppHis.Screen__c = 'IHM';
                loanAppHis.Module__c = 'Post Sanction Checks and Documentation';
                loanAppHis.Deal_Number__c = dealId.Id;
                update loanAppHis;
                IHMPageController.ReadOnlyWrapper readOnlyWrapper = new IHMPageController.ReadOnlyWrapper();
                readOnlyWrapper = (IHMPageController.ReadOnlyWrapper)IHMPageController.checkIfReadOnly(oppRec.Id, dealId.Id);  
                system.assertEquals(loanAppHis.Submitted_Flag__c, readOnlyWrapper.readOnly);
            }
            Test.stopTest();
        }catch(Exception e){
            system.assertEquals('Script-thrown exception', e.getMessage());
            
        }
    }
    
    @isTest
    public static void submitIHMRecordTest(){
        try{            
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod12321@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {
                Opportunity oppRec = [SELECT Id, stageName FROM Opportunity WHERE Vehicle_Type__c = 'Used' LIMIT 1]; 
                Loan_Application_Transaction_History__c loanAppHis = [Select Id, Submitted_Flag__c, Name, Screen__c, Module__c
                                                                      From Loan_Application_Transaction_History__c Where 
                                                                      Loan_Application_ID__c =: oppRec.Id LIMIT 1];
                Deal_Number__c dealId = [select id from Deal_Number__c where Loan_Application__c =: oppRec.Id limit 1];
                // loanAppHis.Name = 'IHM';
                loanAppHis.Screen__c = 'IHM';
                loanAppHis.Module__c = 'Post Sanction Checks and Documentation';
                loanAppHis.Deal_Number__c = dealId.Id;
                update loanAppHis; 
                Boolean result = IHMPageController.submitIHMRecord(oppRec.Id, dealId.Id);
                system.assertEquals(true, result);
            }
            Test.stopTest();
        }catch(Exception e){
            system.assertEquals('Script-thrown exception', e.getMessage());
        }
    }    
    
    @isTest
    public static void updateLoanAppHistoryTest(){
        try{            
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod12321@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {
                Opportunity oppRec = [SELECT Id, stageName FROM Opportunity WHERE Vehicle_Type__c = 'Used' LIMIT 1]; 
                Deal_Number__c dealId = [select id from Deal_Number__c where Loan_Application__c =: oppRec.Id limit 1];

                Loan_Application_Transaction_History__c loanAppHis = [Select Id, Submitted_Flag__c, Name, Screen__c, Module__c, Deal_Number__c
                                                                      From Loan_Application_Transaction_History__c Where 
                                                                      Loan_Application_ID__c =: oppRec.Id LIMIT 1];
                // loanAppHis.Name = 'IHM';
                loanAppHis.Screen__c = 'IHM';
                loanAppHis.Module__c = 'Post Sanction Checks and Documentation';
                loanAppHis.Deal_Number__c = dealId.Id;
                update loanAppHis; 
                
                Boolean result = IHMPageController.updateLoanAppHistory(oppRec.Id, dealId.Id);
                system.assertEquals(true, result);
            }
            Test.stopTest();
        }catch(Exception e){
            system.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void loanApplicationRelatedTest(){
        try{            
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod12321@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {
                Opportunity oppRec = [SELECT Id, stageName FROM Opportunity WHERE Vehicle_Type__c = 'Used' LIMIT 1]; 
                oppRec.Product_Type__c = System.Label.PassengerVehicles;
                Update oppRec;
                
                Deal_Number__c dealId = [select id from Deal_Number__c where Loan_Application__c =: oppRec.Id limit 1];
                
                List<Vehicle_Detail__c> vehList = new List<Vehicle_Detail__c>();
                for(Vehicle_Detail__c vehicle : [Select id ,Valuer_category__c From Vehicle_Detail__c Where Loan_Application__c = : oppRec.Id WITH SECURITY_ENFORCED LIMIT 1]){
                    vehicle.Valuer_category__c = System.Label.MFC;
                    vehList.add(vehicle);
                }
                
                update vehList;
                
                IHMPageController.RelatedIdWrapper resultWrppaer = (IHMPageController.RelatedIdWrapper)IHMPageController.loanApplicationRelated(oppRec.Id,'post-sanction', dealId.Id);
                system.assertNotEquals(null, resultWrppaer);
                List<IHM__c> ihmList = new List<IHM__c>([Select Id From IHM__c Where Loan_Application__c =:oppRec.Id LIMIT 1]);
                delete ihmList;
				IHMPageController.RelatedIdWrapper resultWrppaer1 = (IHMPageController.RelatedIdWrapper)IHMPageController.loanApplicationRelated(oppRec.Id,'post-sanction', dealId.Id);

            }
            Test.stopTest();
        }catch(Exception e){
            system.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void loanApplicationRelatedTest1(){
        try{            
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod12321@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {
                Opportunity oppRec = [SELECT Id, stageName FROM Opportunity WHERE Vehicle_Type__c = 'Used' LIMIT 1]; 
                oppRec.Product_Type__c = System.Label.PassengerVehicles;
                Update oppRec;
                
                Deal_Number__c dealId = [select id from Deal_Number__c where Loan_Application__c =: oppRec.Id limit 1];
                
                List<Vehicle_Detail__c> vehList = new List<Vehicle_Detail__c>();
                for(Vehicle_Detail__c vehicle : [Select id ,Valuer_category__c From Vehicle_Detail__c Where Loan_Application__c = : oppRec.Id WITH SECURITY_ENFORCED LIMIT 1]){
                    vehicle.Valuer_category__c = System.Label.Empanelled;
                    vehList.add(vehicle);
                }
                
                update vehList;
                
                IHMPageController.RelatedIdWrapper resultWrppaer = (IHMPageController.RelatedIdWrapper)IHMPageController.loanApplicationRelated(oppRec.Id,'post-sanction',dealId.Id);
                system.assertNotEquals(null, resultWrppaer);
                List<IHM__c> ihmList = new List<IHM__c>([Select Id From IHM__c Where Loan_Application__c =:oppRec.Id LIMIT 1]);
                delete ihmList;
				IHMPageController.RelatedIdWrapper resultWrppaer1 = (IHMPageController.RelatedIdWrapper)IHMPageController.loanApplicationRelated(oppRec.Id,'post-sanction', dealId.Id);

            }
            Test.stopTest();
        }catch(Exception e){
            system.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void loanApplicationRelatedTest2(){
        try{            
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod12321@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {
                Opportunity oppRec = [SELECT Id, stageName FROM Opportunity WHERE Vehicle_Type__c = 'Used' LIMIT 1]; 
                oppRec.Product_Type__c = System.Label.TwoWheeler;
                Update oppRec;
				
                Deal_Number__c dealId = [select id from Deal_Number__c where Loan_Application__c =: oppRec.Id limit 1];
                
                List<Vehicle_Detail__c> vehList = new List<Vehicle_Detail__c>();
                for(Vehicle_Detail__c vehicle : [Select id ,Valuer_category__c From Vehicle_Detail__c Where Loan_Application__c = : oppRec.Id WITH SECURITY_ENFORCED LIMIT 1]){
                    vehicle.Valuer_category__c = System.Label.Empanelled;
                    vehList.add(vehicle);
                }
                
                update vehList;
                
                IHMPageController.RelatedIdWrapper resultWrppaer = (IHMPageController.RelatedIdWrapper)IHMPageController.loanApplicationRelated(oppRec.Id,'post-sanction',dealId.Id);
                system.assertNotEquals(null, resultWrppaer);
                List<IHM__c> ihmList = new List<IHM__c>([Select Id From IHM__c Where Loan_Application__c =:oppRec.Id LIMIT 1]);
                delete ihmList;
				IHMPageController.RelatedIdWrapper resultWrppaer1 = (IHMPageController.RelatedIdWrapper)IHMPageController.loanApplicationRelated(oppRec.Id,'post-sanction',dealId.Id);

            }
            Test.stopTest();
        }catch(Exception e){
            system.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void getDocumentFilesTest(){
        try{            
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod12321@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {
                Opportunity opks1 = new Opportunity();
                opks1.StageName = 'Qualification';
                opks1.CloseDate = Date.newInstance(2021, 1, 11);
                opks1.Name = 'testone';
                insert opks1;
                
                Applicant__c apks1 = new Applicant__c();
                apks1.Opportunity__c = opks1.Id;
                apks1.Contact_number__c = '9743514830';
                apks1.Applicant_Type__c = 'Borrower';
                insert apks1;
                
                 Documents__c dfks1 = new Documents__c();
                 dfks1.Applicant__c = apks1.Id;
                 dfks1.Opportunity_Relation__c = opks1.Id;
                 dfks1.KYC_name__c = 'Aadhar';
                 dfks1.Document_Side__c ='Back';
             //    dfks1.Aadhar_Source__c = 'ScanAadhar';
                 dfks1.Name = 'Aadhar';
                 dfks1.Proof_of_Identity_POI__c = true;
                 dfks1.Document_Type__c = System.Label.PassportCard;
                 insert dfks1;
                
                 ContentVersion cvn1 = new ContentVersion();
                 cvn1.PathOnClient = 'testpath1';
                 cvn1.Title = 'testtitle1';
                 cvn1.VersionData = Blob.valueOf('Test Content');
                 cvn1.Document_Side_fileupload__c = 'Front';
                 insert cvn1;
                
                 ContentVersion testcd1 = [SELECT id, ContentDocumentId FROM ContentVersion where Id = :cvn1.Id];
                
                 ContentDocumentLink cdlink1 = new ContentDocumentLink();
                 cdlink1.Visibility = 'AllUsers';
                 cdlink1.ShareType = 'V';
                 cdlink1.LinkedEntityId = dfks1.Id;
                 cdlink1.ContentDocumentId = testcd1.ContentDocumentId;
                 insert cdlink1;   
                
                 IHMPageController.getDocumentFiles(cdlink1.LinkedEntityId,opks1.Id);
            }
            Test.stopTest();
        }catch(Exception e){
            system.assertEquals('Script-thrown exception', e.getMessage());
        }
    } 

    @isTest
    public static void getIHMDocumentsAmountSumTest(){
        try{            
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod12321@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {
                Opportunity opks1 = new Opportunity();
                opks1.StageName = 'Qualification';
                opks1.CloseDate = Date.newInstance(2021, 1, 11);
                opks1.Name = 'testone';
                insert opks1;

                Applicant__c apks1 = new Applicant__c();
                apks1.Opportunity__c = opks1.Id;
                apks1.Contact_number__c = '9743514830';
                apks1.Applicant_Type__c = 'Borrower';
                insert apks1;
                
                Documents__c dfks1 = new Documents__c();
                dfks1.Applicant__c = apks1.Id;
                dfks1.Opportunity_Relation__c = opks1.Id;
                dfks1.Name = 'IHM Receipt';
                dfks1.Is_Active__c = True;
                dfks1.Proof_of_Identity_POI__c = true;
                dfks1.Document_Type__c = 'IHM Receipt';
                dfks1.IHM_amount_as_per_receipt__c = 1000;
                insert dfks1; 
            	
                Deal_Number__c dealId = [select id from Deal_Number__c limit 1];
                dealId.Loan_Application__c = opks1.Id;
				update dealId;
                
                IHMPageController.getIHMDocumentsAmountSum(opks1.Id, dealId.Id);
            }
            Test.stopTest();
        }catch(Exception e){
            system.assertEquals('Script-thrown exception', e.getMessage());
        }
    } 
    
    @isTest
    public static void checkIfReadOnlyTest1(){
        try{
                Opportunity opks1 = new Opportunity();
                opks1.StageName = System.Label.Pre_Disbursement_Check;
                opks1.CloseDate = Date.newInstance(2021, 1, 11);
                opks1.Name = 'testone';
                opks1.OwnerId = UserInfo.getUserId();
                insert opks1;
            
            Deal_Number__c dealId = [select id from Deal_Number__c limit 1];
            dealId.Loan_Application__c = opks1.Id;
            update dealId;
            
                Loan_Application_Transaction_History__c lth1 = new Loan_Application_Transaction_History__c();
              //  lth1.Name = 'test';
                lth1.Loan_Application_ID__c = opks1.Id;
                lth1.Module_Name__c = 'FI';
            lth1.Deal_Number__c = dealId.Id;
                lth1.New_Owner__c = UserInfo.getUserId();
                lth1.Type__c = 'Module';
                lth1.Screen__c = System.Label.IHM;
                insert lth1;
            

             
                Test.startTest();
                      IHMPageController.checkIfReadOnly(opks1.Id,dealId.Id);
                Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void validateScreenVisiblityTest3(){
        try{
                Opportunity opks1 = new Opportunity();
                opks1.StageName = System.Label.Post_Sanction_Checks_and_Documentation;
                opks1.CloseDate = Date.newInstance(2021, 1, 11);
                opks1.Name = 'testone';
                insert opks1;
            
            Deal_Number__c dealId = [select id from Deal_Number__c limit 1];
            dealId.Loan_Application__c = opks1.Id;
            update dealId;
            
                Loan_Application_Transaction_History__c lth1 = new Loan_Application_Transaction_History__c();
                lth1.Loan_Application_ID__c = opks1.Id;
                lth1.Module_Name__c = opks1.StageName;
            lth1.Deal_Number__c = dealId.Id;
               // lth1.Assignment_status__c = 'Accepted';
                lth1.Screen__c = System.Label.Invoice;
                lth1.Submitted_Flag__c = false;
             //   lth1.RecordTypeId = Schema.SObjectType.Loan_Application_Transaction_History__c.getRecordTypeInfosByName().get('Lead Assignment').getRecordTypeId();
                insert lth1;
            
            
            
                Test.startTest();
                     IHMPageController.validateScreenVisiblity(opks1.Id, dealId.Id);
                Test.stopTest();
            
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void validateScreenVisiblityTest4(){
        try{
                Opportunity opks1 = new Opportunity();
                opks1.StageName = System.Label.Post_Sanction_Checks_and_Documentation;
                opks1.CloseDate = Date.newInstance(2021, 1, 11);
                opks1.Name = 'testone';
                opks1.Product_Type__c = System.Label.PassengerVehicles;
                opks1.Vehicle_Type__c = System.Label.used;
                insert opks1;
            
            Deal_Number__c dealId = [select id from Deal_Number__c limit 1];
            dealId.Loan_Application__c = opks1.Id;
            update dealId;
            
                Test.startTest();
                     IHMPageController.validateScreenVisiblity(opks1.Id, dealId.Id);
                Test.stopTest();
            
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    
}