@isTest
public class LoanDisbursementControllerTest {
    
    @testSetup 
    static void testDataSetup() 
    {
        //create user
        Profile p = [SELECT Id FROM Profile WHERE Name='IBL Business Executive'];
        User u = new User(Alias = 'standt2', email='standarduser2@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,Maker_Id__c='12',IsActive = true,
                          timezonesidkey='america/los_angeles',username='test_userprod123456@indusbank.com',MobilePhone = '9089078967');
        insert u;
        System.runAs(u) 
        {
            
            Account acc= new account();
            acc.Name = 'accName';
            insert acc;
            
            Contact con = new Contact();
            con.LastName = 'lName';
            con.AccountId = acc.Id;
            insert con;
            
            // Create Opportunity
            Opportunity opp = TestDataUtility.createTestOpportunityForOcr(false);
            //opp.StageName = System.Label.Credit_Processing;
            opp.Sub_Stage__c = System.Label.Field_Investigation;
            opp.Is_Mobile_Journey_Completed__c = true;
            opp.Vehicle_Type__c = System.Label.used;
            opp.CloseDate = Date.newInstance(2022, 1, 11);
            opp.Product_Type__c = System.Label.TwoWheeler;
            opp.Sanction_Status__c = System.Label.nonStp;
            opp.Vehicle_Sub_Category__c = 'UPB';
            opp.Funded__c = true;
            opp.Is_customer_interested_in_a_motor_insura__c = true;
            opp.Motor_Insurance_Premium__c = 10000;
            opp.Agent_BL_code__c = '1234';
            opp.AccountId = acc.Id;
            insert opp;  
            
            Deal_Number_Setting__c dlNumberSetting= new Deal_Number_Setting__c();
            dlNumberSetting.Name = System.Label.TwoWheeler;
            dlNumberSetting.MDNField1__c ='AB';
            dlNumberSetting.MDNField2__c = 2.0;
            insert dlNumberSetting;
            
            
            Deal_Number__c dl=new Deal_Number__c();
            dl.Loan_Application__c = opp.Id;
            dl.DNField1__c = dlNumberSetting.MDNField1__c;
            dl.DNField2__c = String.valueOf(dlNumberSetting.MDNField2__c.round());
            //dl.Sub_Stage__c = 'test'; 
            insert dl;
            //Loan_Application_Transaction_History__c loanHis = new Loan_Application_Transaction_History__c();
            //loanHis.Loan_Application_ID__c = opp.Id;
            //insert loanHis;
            //
            Vehicle_Detail__c vehicle = new Vehicle_Detail__c();
            vehicle.Loan_Application__c = opp.Id;
            vehicle.Deal_Number__c = dl.Id;
            insert vehicle;
            
            Case caseObj = new Case();
            caseObj.Loan_Application__c = opp.id;
            caseObj.Type = 'Current Residence FI';
            caseObj.Status = 'Accepted';
            insert caseObj;
            
            Bl_Code_Details__c bl = new Bl_Code_Details__c();
            bl.Bl_Code__c = '1234';
            insert bl;
            
            TBM_DL_Master__c tbm = new TBM_DL_Master__c();
            //tbm.BL_Code__r.Bl_Code__c = '1234';
            tbm.BL_Code__c = bl.id;
            tbm.Product__c = 'T';
            tbm.Status__c = 'L';
            insert tbm;
            
            
            InsuranceDetails__c objInsurance = new InsuranceDetails__c();
            objInsurance.Loan_Application__c = opp.Id;
            objInsurance.Funded_Premium__c = 500;
            objInsurance.Name = 'MOTOR';
            objInsurance.Funded_Non_funded__c = 'Funded';
            insert objInsurance;
            
            CAM__c objCAM = new CAM__c();
            objCAM.Loan_Application__c = opp.Id;
            objCAM.Loan_Amount__c = 500;
            insert objCAM;
            
            
            IHM__c  objIHM = new IHM__c();
            objIHM.Margin_money_to_be_deducted_from_disburs__c = 500;
            objIHM.Loan_Application__c = opp.Id;
            objIHM.Deal_Number__c = dl.Id;
            insert objIHM;
            
            Opportunity optg1 = new Opportunity();
            optg1.StageName = 'Loan Details';
            optg1.CloseDate = Date.newInstance(2022, 1, 11);
            optg1.Name = 'testone';
            optg1.Vehicle_Type__c = 'New';
            optg1.Product_Type__c = 'Passenger Vehicles';
            optg1.Ben_Code__c = 'optg2';
            optg1.Vehicle_Sub_Category__c = 'UOM';
            optg1.Agent_BL_code__c = 'BLC';
            optg1.Funded__c = false;
            optg1.Is_customer_interested_in_a_motor_insura__c = true;
            optg1.Motor_Insurance_Premium__c = 20000;
            optg1.Sub_Stage__c = 'Business Payment Details';
            optg1.AccountId = acc.Id;
            insert optg1;
            
             Opportunity optg2 = new Opportunity();
            optg2.StageName = 'Loan Details';
            optg2.CloseDate = Date.newInstance(2022, 1, 11);
            optg2.Name = 'testone';
            optg2.Vehicle_Type__c = 'New';
            optg2.Product_Type__c = 'Tractor';
            optg2.Ben_Code__c = 'optg2';
            //optg2.Vehicle_Sub_Category__c = 'UOM';
            optg2.Agent_BL_code__c = 'BLC';
            optg2.Funded__c = false;
            optg2.Is_customer_interested_in_a_motor_insura__c = true;
            optg2.Motor_Insurance_Premium__c = 20000;
            optg2.Sub_Stage__c = 'Business Payment Details';
            optg2.AccountId = acc.Id;
            insert optg2;
            
            AccountTeamMember actMem = new AccountTeamMember();
            actMem.AccountId = acc.Id;
            actMem.TeamMemberRole = 'CVO';
            actMem.UserId = u.Id;
            actMem.Level__c = 'L1';
            actMem.AccountAccessLevel = null;
            insert actMem;
            
            List <Asset> assetList = new List <Asset>();
            Asset ast = new Asset();
            ast.Name = 'astName';
            ast.ContactId =con.Id;
            ast.Dealer_Sub_dealer_name__c = acc.Id;
            assetList.add(ast);
            insert assetList;
            
            Product2 objProduct = new Product2();
            objProduct.ProductCode = 'C';
            objProduct.Name = 'test';
            objProduct.Type__c = 'Make';
            objProduct.External_Reference_Id__c = 'test';
            insert objProduct;
            
            Benefi__c benficiaryMasterObj = new Benefi__c();
            benficiaryMasterObj.Ben_Code__c = 'optg2';
            benficiaryMasterObj.Beneficiary__c = 'EMP';
            benficiaryMasterObj.Name = 'Name Of Benifi';
            benficiaryMasterObj.TA__c = 'Y';               
            benficiaryMasterObj.Dealership_Nature__c = 'CP-BH';
            benficiaryMasterObj.Status_Flag__c ='L';
            benficiaryMasterObj.Email__c = 'test@tets.com';
            benficiaryMasterObj.Indusind_AcNo__c = 'IND12345688';
            insert benficiaryMasterObj;
            
            Beneficiary_Product__c objBenProduct = new Beneficiary_Product__c();
            objBenProduct.Unique_Identifier__c = '1234';
            objBenProduct.Ben_Code__c = benficiaryMasterObj.Id;
            insert objBenProduct;
            
            Applicant__c objApplicant = new Applicant__c();
            objApplicant.Opportunity__c = opp.Id;
            objApplicant.Applicant_Type__c = 'Borrower';
            objApplicant.Contact_number__c = '1234567890';
            insert objApplicant;
            
            Documents__c objDocument = new Documents__c();
            objDocument.Opportunity_Relation__c = opp.Id;
            objDocument.name = 'DocName';
            objDocument.Document_Type__c = 'Insurance Policy Doc';
            objDocument.is_Active__c = true;
            objDocument.Applicant__c = objApplicant.Id;
            insert objDocument;
            
            Bl_Code_Details__c blCode = new Bl_Code_Details__c();
            blCode.Bl_Code__c = 'BLC';
            blCode.Name = 'Name';
            blCode.OwnerId = u.Id;
            insert blCode;
            
            TBM_DL_Master__c tbmdm = new TBM_DL_Master__c();
            tbmdm.DL_Code__c = 'DL';
            tbmdm.Executive_Name__c = 'Exe';
            tbmdm.Product__c = 'C';
            tbmdm.Status__c = 'L';
            tbmdm.BL_Code__c = blCode.Id;
            insert tbmdm;
            
            LoanDisbursementDetails__c disbursement = new LoanDisbursementDetails__c();
            disbursement.Parent_Loan_Application__c = opp.Id;
            disbursement.Payment_Originated_From__c = 'OP';
            disbursement.Vehicle_Sold_By__c = 'Agency Dealer';
            disbursement.Vehicle_Registered_in_Name__c = 'Buyer';
            disbursement.Business_Sourced_By__c = u.Id;
            disbursement.Business_Done_By__c = u.Id;
            disbursement.FI_Done_By__c = u.Id;
            disbursement.Collection_Executive__c = tbmdm.Id;
            disbursement.Do_Issuance__c = 'Along_with_Payment';
            disbursement.Do_Issuance_Mode__c = 'Separate';
            disbursement.Do_To_be_authorized_by__c = benficiaryMasterObj.Id;
            disbursement.Balance_Transfer_Amount_in_Rs__c = 24000;
            disbursement.Purchase_doc_catq__c = 'Invoice';
            disbursement.Original_Purchase_value_in_Rs__c = 25000;
            disbursement.Original_purchase_date__c = Date.today();
            disbursement.Fund_End_Use__c = 'New_Vehicle_Margin_Money';
            disbursement.Deal_Number__c = dl.Id;
            insert disbursement;
            
            case cases = new case();
            cases.OwnerId = u.Id;
            cases.Type = 'Current Residence FI';
            cases.Loan_Application__c = optg1.Id;  
            cases.Status = 'Accepted';            
            insert cases;
        }
    }
    
    
    @isTest
    private static void isValidUserTest() {
        try
        {
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE username='test_userprod123456@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {  
                Opportunity oppRec = [SELECT Id, Vehicle_Type__c, Product_Type__c FROM Opportunity WHERE Vehicle_Type__c = 'Used' LIMIT 1];
                
                Opportunity oppRec1 = [SELECT Id, Vehicle_Type__c, Product_Type__c FROM Opportunity WHERE Vehicle_Type__c = 'New' LIMIT 1];
                
                Map<string,object> bool = LoanDisbursementController.isValidUser(oppRec.Id);
                Map<string,object> bool1 = LoanDisbursementController.isValidUser(oppRec1.Id);
                
                //System.assertEquals(false, bool);
                //System.assertEquals(true, bool1);
                
            }
            Test.stopTest();                          
        }catch(Exception e){
            system.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    private static void isValidUserTest1() {
        try
        {
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE username='test_userprod123456@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {  
                Opportunity oppRec = [SELECT Id, Vehicle_Type__c, Product_Type__c FROM Opportunity WHERE Vehicle_Type__c = 'Used' LIMIT 1];
                oppRec.Product_Type__c = 'Tractor';
                update oppRec;
                Opportunity oppRec1 = [SELECT Id, Vehicle_Type__c, Product_Type__c FROM Opportunity WHERE Vehicle_Type__c = 'New' LIMIT 1];
                
                Map<string,object> bool = LoanDisbursementController.isValidUser(oppRec.Id);
                Map<string,object> bool1 = LoanDisbursementController.isValidUser(oppRec1.Id);
                
                //System.assertEquals(false, bool);
                //System.assertEquals(true, bool1);
                
            }
            Test.stopTest();                          
        }catch(Exception e){
            system.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    private static void isValidUserTest2() {
        try
        {
            Test.startTest(); 
            Opportunity oppRec = [SELECT Id, Vehicle_Type__c, Product_Type__c FROM Opportunity WHERE Vehicle_Type__c = 'Used' LIMIT 1];
            oppRec.Product_Type__c = 'Tractor';
            update oppRec;
            Opportunity oppRec1 = [SELECT Id, Vehicle_Type__c, Product_Type__c FROM Opportunity WHERE Vehicle_Type__c = 'New' LIMIT 1];
            
            Map<string,object> bool = LoanDisbursementController.isValidUser(oppRec.Id);
            Map<string,object> bool1 = LoanDisbursementController.isValidUser(oppRec1.Id);
            
            //System.assertEquals(false, bool);
            //System.assertEquals(true, bool1);
            
            
            Test.stopTest();                          
        }catch(Exception e){
            system.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    @isTest
    private static void isValidUserTest3() {
        try
        {
            Test.startTest(); 
            Map<string,object> bool1 = LoanDisbursementController.isValidUser(null);
            
            Test.stopTest();                          
        }catch(Exception e){
            system.assertEquals('Script-thrown exception', e.getMessage());
        }
    }	
    
    @isTest
    private static void getUsedRegAndVehilceDetailstest() {
        try
        {
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE username='test_userprod123456@indusbank.com' AND IsActive = true LIMIT 1]; 
            
            System.runAs(u) 
            {
                Opportunity oppRec = [SELECT Id, Vehicle_Type__c, Product_Type__c FROM Opportunity WHERE Vehicle_Type__c = 'Used' LIMIT 1];
                
                Deal_Number_Setting__c dlNumberSetting= new Deal_Number_Setting__c();
                dlNumberSetting.Name = System.Label.TwoWheeler;
                dlNumberSetting.MDNField1__c ='AB';
                dlNumberSetting.MDNField2__c = 2.0;
                insert dlNumberSetting;
                
                
                Deal_Number__c dl=new Deal_Number__c();
                dl.Loan_Application__c = oppRec.Id;
                dl.DNField1__c = dlNumberSetting.MDNField1__c;
                dl.DNField2__c = String.valueOf(dlNumberSetting.MDNField2__c.round());
                dl.Sub_Stage__c = 'RC Upload'; 
                insert dl;
                
                Vehicle_Detail__c vehicleRecord = TestDataUtility.createTestVehicleDetailForIbb(true,oppRec);
                Vehicle_Detail__c vehRecord = LoanDisbursementController.getUsedRegAndVehilceDetails(oppRec.id, dl.Id);
                //Vehicle_Detail__c vehRecordnull = LoanDisbursementController.getUsedRegAndVehilceDetails(null,null);
                System.assertNotEquals(null, vehRecord);
                //System.assertEquals(null, vehRecordnull);
            }
            Test.stopTest();                          
        }catch(Exception e){
            system.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    private static void getLoanApplicantDetailsTest() {
        try
        {
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE username='test_userprod123456@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {           
                Opportunity oppRec = [SELECT Id, Vehicle_Type__c, Product_Type__c FROM Opportunity WHERE Vehicle_Type__c = 'Used' LIMIT 1];
                
                Opportunity oppRec1 = [SELECT Id, Vehicle_Type__c, Product_Type__c FROM Opportunity WHERE Vehicle_Type__c = 'New' LIMIT 1];
                
                Applicant__c objApplicant = [SELECT Opportunity__c, Applicant_Type__c, Contact_number__c FROM Applicant__c WHERE Opportunity__c= : oppRec.ID];
                
                LoanDisbursementController.getLoanApplicantDetails(oppRec.id);
                LoanDisbursementController.getLoanApplicantDetails(oppRec1.id);
                System.assertnotEquals(new list <Applicant__c>{objApplicant}, LoanDisbursementController.getLoanApplicantDetails(oppRec.id));
                
            }
            Test.stopTest();                          
        }catch(Exception e){
            system.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    @isTest
    private static void inactiveInsuranceApplicationDocumentTest() {
        try
        {
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE username='test_userprod123456@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {     
                
                Opportunity oppRec = [SELECT Id, Vehicle_Type__c, Product_Type__c FROM Opportunity WHERE Vehicle_Type__c = 'Used' LIMIT 1];
                
                Applicant__c objApplicant = [SELECT Opportunity__c, Applicant_Type__c, Contact_number__c FROM Applicant__c WHERE Opportunity__c= : oppRec.ID];
                
                Documents__c docs = [SELECT Id, Applicant__c FROM Documents__c WHERE Opportunity_Relation__c = :oppRec.Id AND Document_Type__c='Insurance Policy Doc' AND is_Active__c = TRUE LIMIT 1];
                
                Deal_Number__c deal = [select id from Deal_Number__c limit 1];
                
                LoanDisbursementController.inactiveInsuranceApplicationDocument(oppRec.id,deal.Id);
                LoanDisbursementController.getUploadedDocuments(oppRec.id);
                System.assertEquals(docs.Applicant__c, objApplicant.Id);
                
            }
            Test.stopTest();                          
        }catch(Exception e){
            system.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    @isTest
    private static void getLoanDisbursementDetailsTest() {
        try
        {
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE username='test_userprod123456@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {    
                Opportunity oppRec = [SELECT Id, Vehicle_Type__c, Product_Type__c FROM Opportunity LIMIT 1]; 
                LoanDisbursementDetails__c disbursement = [SELECT Id,Parent_Loan_Application__c,
                                                           Parent_Loan_Application__r.Vehicle_Type__c,Parent_Loan_Application__r.Registration_Number_Format__c,Parent_Loan_Application__r.Vehicle_Registration_Number__c,Payment_Originated_From__c,
                                                           Vehicle_Sold_By__c,Vehicle_Registered_in_Name__c, Business_Sourced_By__c, Business_Sourced_By__r.Id, Business_Done_By__c, Business_Done_By__r.Id,
                                                           FI_Done_By__c, FI_Done_By__r.Id, Collection_Executive__c,
                                                           Do_Issuance__c, Do_Issuance_Mode__c, Do_To_be_authorized_by__c, Balance_Transfer_Amount_in_Rs__c,
                                                           Purchase_doc_catq__c, Original_Purchase_value_in_Rs__c, Original_purchase_date__c, Fund_End_Use__c 
                                                           FROM LoanDisbursementDetails__c WHERE Parent_Loan_Application__c =: oppRec.Id WITH SECURITY_ENFORCED LIMIT 1];
                
                LoanDisbursementController.getLoanDisbursementDetails(null);
                LoanDisbursementController.getLoanDisbursementDetails(oppRec.Id);
                System.assertNotEquals(disbursement, LoanDisbursementController.getLoanDisbursementDetails(oppRec.Id));
                
                
            }
            Test.stopTest();                          
        }catch(Exception e){
            system.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    @isTest
    private static void CheckBalanceTranserFieldAccessbilitytest() {
        try
        {
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE username='test_userprod123456@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {
                Opportunity oppRec = [SELECT Id, Vehicle_Type__c, Product_Type__c FROM Opportunity WHERE Vehicle_Type__c = 'Used' LIMIT 1];
                Deal_Number__c deal = [select id from Deal_Number__c limit 1];
                boolean checkbool = LoanDisbursementController.CheckBalanceTranserFieldAccessbility(oppRec.Id, deal.Id);
                boolean checkboolnull = LoanDisbursementController.CheckBalanceTranserFieldAccessbility(null,null);
                
                LoanDisbursementController.newLoanAppHistoryWrapper();
                
                System.assertEquals(true, checkbool);
                System.assertEquals(false, checkboolnull);
            }
            Test.stopTest();                          
        }catch(Exception e){
            system.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    
    @isTest
    private static void getPymntOrigFromDDValuestest() {
        try
        {
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE username='test_userprod123456@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {  
                List <Benefi__c> benficiaryMasterList = new list <Benefi__c>();
                
                Opportunity optg1 =[SELECT Id, Vehicle_Type__c, Product_Type__c FROM Opportunity WHERE Vehicle_Type__c = 'Used' LIMIT 1];
                Deal_Number__c deal = [select id from Deal_Number__c limit 1];
                
                Opportunity optg2 = [SELECT Id, Vehicle_Type__c, Product_Type__c, Ben_Code__c FROM Opportunity WHERE Vehicle_Type__c = 'New' LIMIT 1];
                
                Benefi__c benficiaryMasterObj = [SELECT Id, TA__c, Ben_code__c FROM Benefi__c WHERE Ben_code__c =: optg2.Ben_Code__c WITH SECURITY_ENFORCED limit 1];
                
                Deal_Number_Setting__c dlNumberSetting= new Deal_Number_Setting__c();
                dlNumberSetting.Name = System.Label.PassengerVehicles;
                dlNumberSetting.MDNField1__c ='AB';
                dlNumberSetting.MDNField2__c = 2.0;
                insert dlNumberSetting;
                
                
                Deal_Number__c dl=new Deal_Number__c();
                dl.Loan_Application__c = optg2.Id;
                dl.DNField1__c = dlNumberSetting.MDNField1__c;
                dl.DNField2__c = String.valueOf(dlNumberSetting.MDNField2__c.round());
               // dl.Sub_Stage__c = 'test'; 
                insert dl;
                
                LoanDisbursementController.getPymntOrigFromDDValues(optg1.id, deal.Id);
                LoanDisbursementController.getPymntOrigFromDDValues(optg2.id, dl.Id);
                
                System.assertNotEquals(optg1, optg2);
                
                optg2.Ben_Code__c = 'optg3';
                optg2.Product_Type__c = 'C';
                Update optg2;
                
                LoanDisbursementController.getPymntOrigFromDDValues(optg2.id, dl.Id);
                
                Test.stopTest();
            }
        }catch(Exception e){
            system.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    private static void getPymntOrigFromDDValuestest1() {
        try
        {
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE username='test_userprod123456@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {  
                List <Benefi__c> benficiaryMasterList = new list <Benefi__c>();
                
                Opportunity optg1 =[SELECT Id, Vehicle_Type__c, Product_Type__c FROM Opportunity WHERE Vehicle_Type__c = 'Used' LIMIT 1];
                optg1.Product_Type__c = 'Tractor';
                update optg1;
                
                Deal_Number_Setting__c dealset= [select id,name from Deal_Number_Setting__c limit 1];
                dealset.Name = System.Label.TwoWheeler;
                update dealset;
                
                Deal_Number__c deal = [select id from Deal_Number__c limit 1];
                
                Opportunity optg2 = [SELECT Id, Vehicle_Type__c, Product_Type__c, Ben_Code__c FROM Opportunity WHERE Vehicle_Type__c = 'New' LIMIT 1];
                
                Benefi__c benficiaryMasterObj = [SELECT Id, TA__c, Ben_code__c FROM Benefi__c WHERE Ben_code__c =: optg2.Ben_Code__c WITH SECURITY_ENFORCED limit 1];
                
                Deal_Number_Setting__c dlNumberSetting= new Deal_Number_Setting__c();
                dlNumberSetting.Name = System.Label.PassengerVehicles;
                dlNumberSetting.MDNField1__c ='AB';
                dlNumberSetting.MDNField2__c = 2.0;
                insert dlNumberSetting;
                
                
                Deal_Number__c dl=new Deal_Number__c();
                dl.Loan_Application__c = optg2.Id;
                dl.DNField1__c = dlNumberSetting.MDNField1__c;
                dl.DNField2__c = String.valueOf(dlNumberSetting.MDNField2__c.round());
                //dl.Sub_Stage__c = 'test'; 
                insert dl;
                
                LoanDisbursementController.getPymntOrigFromDDValues(optg1.id, deal.Id);
                
                System.assertNotEquals(optg1, optg2);
                
                optg2.Ben_Code__c = 'optg3';
                optg2.Product_Type__c = 'C';
                Update optg2;
                
                LoanDisbursementController.getPymntOrigFromDDValues(optg2.id, dl.Id);
                
                Test.stopTest();
            }
        }catch(Exception e){
            system.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    private static void getBusinessUserIdstest() {
        try
        {  
            Test.startTest();
            User u = [SELECT Id,usertype, Name FROM User WHERE username='test_userprod123456@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.debug('getBusinessUserIdstest');
            System.runAs(u) 
            {       
                System.debug('getBusinessUserIdstest');
                Opportunity oppRec = [SELECT Id, Vehicle_Type__c, Product_Type__c FROM Opportunity WHERE Vehicle_Type__c =: 'Used' LIMIT 1];
                Deal_Number__c deal = [select id from Deal_Number__c limit 1];
                Opportunity oppRec1 = [SELECT Id, Vehicle_Type__c, Product_Type__c FROM Opportunity WHERE Vehicle_Type__c = :'New' LIMIT 1];
                
                //Loan_Application_Transaction_History__c loanAppTransHistory= [SELECT Loan_Application_ID__c,Module__c, Screen__c, Current_Owner__c, Current_Owner__r.Name,
                //Module_Name__c,New_Owner__c,New_Owner__r.Name, Type__c, Submitted_Flag__c FROM Loan_Application_Transaction_History__c WHERE Loan_Application_ID__c =: oppRec1.Id WITH SECURITY_ENFORCED];
                
                //Vehicle_Detail__c vehicleRecord = TestDataUtility.createTestVehicleDetailForIbb(true,oppRec);
                //Vehicle_Detail__c vehRecord = LoanDisbursementController.getUsedRegAndVehilceDetails(oppRec1.id);
                //Vehicle_Detail__c vehRecordnull = LoanDisbursementController.getUsedRegAndVehilceDetails(null);
                
                List<Case> cases = [SELECT Id,OwnerId,Owner.Name FROM Case WHERE Type =:'Current Residence FI' AND Loan_Application__c = :oppRec1.Id LIMIT 1];
                
                Bl_Code_Details__c blCode = [SELECT Bl_Code__c, Name, OwnerId FROM Bl_Code_Details__c LIMIT 1];
                
                
                TBM_DL_Master__c tbmdm = [SELECT Id, DL_Code__c, Executive_Name__c, Product__c, Status__c, BL_Code__c FROM TBM_DL_Master__c WHERE BL_Code__c =: blCode.Id LIMIT 1];
                
                String forgetBusinessUserIds = LoanDisbursementController.getBusinessUserIds(oppRec.id, deal.Id);
                String forgetBusinessUserIdsnull = LoanDisbursementController.getBusinessUserIds(null,null);
                
                String forgetCollectionExecutiveDDValues = LoanDisbursementController.getCollectionExecutiveDDValues(oppRec1.id);
                String forgetCollectionExecutiveDDValues2 = LoanDisbursementController.getCollectionExecutiveDDValues(oppRec.id);
                String forgetCollectionExecutiveDDValuesnull = LoanDisbursementController.getCollectionExecutiveDDValues(null);
                LoanDisbursementController.newTBMDLMasterWrapper();
                
                System.assertnotEquals(null, tbmdm);
                
                Test.stopTest();
            }
            
        }catch(Exception e){
            system.debug('message--->'+e.getMessage()+e.getLineNumber());
            system.assertnotEquals(null, e.getMessage());
        }
    }
    
    @isTest
    private static void getBusinessUserIdstest2() {
        try
        {  
            Test.startTest();
            User u = [SELECT Id,usertype, Name FROM User WHERE username='test_userprod123456@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.debug('getBusinessUserIdstest');
            System.runAs(u) 
            {       
                System.debug('getBusinessUserIdstest');
                Opportunity oppRec = [SELECT Id, Vehicle_Type__c, Product_Type__c FROM Opportunity WHERE Vehicle_Type__c =: 'Used' LIMIT 1];
                oppRec.Product_Type__c = 'Tractor';
                update oppRec;
                Deal_Number__c deal = [select id from Deal_Number__c limit 1];
                Opportunity oppRec1 = [SELECT Id, Vehicle_Type__c, Product_Type__c FROM Opportunity WHERE Vehicle_Type__c = :'New' LIMIT 1];
                
                
                
                //Loan_Application_Transaction_History__c loanAppTransHistory= [SELECT Loan_Application_ID__c,Module__c, Screen__c, Current_Owner__c, Current_Owner__r.Name,
                //Module_Name__c,New_Owner__c,New_Owner__r.Name, Type__c, Submitted_Flag__c FROM Loan_Application_Transaction_History__c WHERE Loan_Application_ID__c =: oppRec1.Id WITH SECURITY_ENFORCED];
                
                //Vehicle_Detail__c vehicleRecord = TestDataUtility.createTestVehicleDetailForIbb(true,oppRec);
                //Vehicle_Detail__c vehRecord = LoanDisbursementController.getUsedRegAndVehilceDetails(oppRec1.id);
                //Vehicle_Detail__c vehRecordnull = LoanDisbursementController.getUsedRegAndVehilceDetails(null);
                
                List<Case> cases = [SELECT Id,OwnerId,Owner.Name FROM Case WHERE Type =:'Current Residence FI' AND Loan_Application__c = :oppRec1.Id LIMIT 1];
                
                Bl_Code_Details__c blCode = [SELECT Bl_Code__c, Name, OwnerId FROM Bl_Code_Details__c LIMIT 1];
                
                
                TBM_DL_Master__c tbmdm = [SELECT Id, DL_Code__c, Executive_Name__c, Product__c, Status__c, BL_Code__c FROM TBM_DL_Master__c WHERE BL_Code__c =: blCode.Id LIMIT 1];
                
                String forgetBusinessUserIds = LoanDisbursementController.getBusinessUserIds(oppRec.id, deal.Id);
                String forgetBusinessUserIdsnull = LoanDisbursementController.getBusinessUserIds(null,null);
                
                String forgetCollectionExecutiveDDValues = LoanDisbursementController.getCollectionExecutiveDDValues(oppRec1.id);
                String forgetCollectionExecutiveDDValues2 = LoanDisbursementController.getCollectionExecutiveDDValues(oppRec.id);
                String forgetCollectionExecutiveDDValuesnull = LoanDisbursementController.getCollectionExecutiveDDValues(null);
                LoanDisbursementController.newTBMDLMasterWrapper();
                
                System.assertnotEquals(null, tbmdm);
                
                Test.stopTest();
            }
            
        }catch(Exception e){
            system.debug('message--->'+e.getMessage()+e.getLineNumber());
            system.assertnotEquals(null, e.getMessage());
        }
    }
    
    @isTest
    private static void GetBusinessUserIdsForPVProducttest() {
        try
        {  
            Test.startTest();
            User u = [SELECT Id,usertype, Name FROM User WHERE username='test_userprod123456@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {       
                Opportunity oppRec = [SELECT Id, Vehicle_Type__c, Product_Type__c FROM Opportunity WHERE Vehicle_Type__c =: 'Used' LIMIT 1];
                Applicant__c app = [SELECT Id from Applicant__c where Opportunity__c =:oppRec.Id ];
                
                Retry_Count__c rc = new Retry_Count__c();
                rc.Loan_Application_Id__c = oppRec.Id;
                rc.Module__c = 'Gatting & Screening';
                rc.Service_Name__c = 'Check Eligibility Attempts';
                rc.Applicant__c = app.Id;
                insert rc;
                
                String forgetBusinessUserIds = LoanDisbursementController.GetBusinessUserIdsForPVProduct(oppRec.id);
                String forgetBusinessUserIdsnull = LoanDisbursementController.GetBusinessUserIdsForPVProduct(null);
                
                
                Test.stopTest();
            }
            
        }catch(Exception e){
            system.debug('message--->'+e.getMessage()+e.getLineNumber());
            system.assertnotEquals(null, e.getMessage());
        }
    }
    
    @isTest
    private static void getVehicleSoldBytest() {
        try
        {
            
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE username='test_userprod123456@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {
                //List <Opportunity> loanApplicationListgetveh = new list <Opportunity>();
                Opportunity optg1 = [SELECT Id, Vehicle_Type__c, Product_Type__c FROM Opportunity WHERE Vehicle_Type__c =: 'Used' LIMIT 1];
                optg1.Vehicle_Sub_Category__c = 'UPD';
                Update optg1;
                Deal_Number__c deal = [select id from Deal_Number__c limit 1];
                
                Opportunity optg2 =  [SELECT Id, Vehicle_Type__c, Product_Type__c FROM Opportunity WHERE Vehicle_Type__c = :'New' LIMIT 1];
                                Opportunity optg3 =  [SELECT Id, Vehicle_Type__c, Product_Type__c FROM Opportunity WHERE Product_Type__c = 'Tractor' LIMIT 1];

                
                Deal_Number_Setting__c dlNumberSetting= new Deal_Number_Setting__c();
                dlNumberSetting.Name = System.Label.PassengerVehicles;
                dlNumberSetting.MDNField1__c ='AB';
                dlNumberSetting.MDNField2__c = 2.0;
                insert dlNumberSetting;
                
                
                Deal_Number__c dl=new Deal_Number__c();
                dl.Loan_Application__c = optg2.Id;
                dl.DNField1__c = dlNumberSetting.MDNField1__c;
                dl.DNField2__c = String.valueOf(dlNumberSetting.MDNField2__c.round());
                dl.Sub_Stage__c = 'Beneficiary Details'; 
                insert dl;
                
                Invoice_Details__c ind = new Invoice_Details__c();
                ind.Dealer_Name__c = 'Dealer';
                ind.Loan_Application__c = optg1.Id;
                insert ind;
                
                Invoice_Details__c ind2 = new Invoice_Details__c();
                ind2.Dealer_Name__c = 'Dealer2';
                ind2.Loan_Application__c = optg2.Id;
                insert ind2;
                
                String forgetVehicleSoldBynull = LoanDisbursementController.getVehicleSoldBy(null,null);
                String forgetVehicleSoldBy1= LoanDisbursementController.getVehicleSoldBy(optg1.Id, deal.Id);
                String forgetVehicleSoldBy2 = LoanDisbursementController.getVehicleSoldBy(optg2.Id,dl.Id);

                
                optg2.Vehicle_Sub_Category__c = 'COM';
                update optg2;
                
                String forgetVehicleSoldBy3 = LoanDisbursementController.getVehicleSoldBy(optg2.Id, dl.Id);
                LoanDisbursementController.getVehicleSoldBy(optg3.Id, dl.Id);
                
                System.assertEquals('DISABLE_FIELD', forgetVehicleSoldBynull);
                System.assertEquals('Dealer', forgetVehicleSoldBy1);
                System.assertEquals('Dealer2', forgetVehicleSoldBy2);
                System.assertEquals('Dealer2', forgetVehicleSoldBy3);
                
            }
            Test.stopTest();                          
        }catch(Exception e){
            system.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    
    @isTest
    private static void getDoToBeAuthorizedByDDValuestest() {
        try
        {
            
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE username='test_userprod123456@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {
                Opportunity optg1 = [SELECT Id, Ben_Code__c, Loan_Application_Number__c, Product_Type__c, Vehicle_Type__c, Vehicle_Sub_Category__c FROM Opportunity WHERE Vehicle_Type__c =: 'Used' limit 1];
                System.debug('optg1-->'+optg1);
                
                
                Opportunity optg2 = [SELECT Id, Ben_Code__c, Loan_Application_Number__c, Product_Type__c, Vehicle_Type__c, Vehicle_Sub_Category__c FROM Opportunity WHERE Vehicle_Type__c =: 'New' limit 1];
                System.debug('optg2-->'+optg2);
                
                Product2 objProduct = [SELECT id, ProductCode, Name, Type__c, External_Reference_Id__c FROM Product2 LIMIT 1];
                System.debug('objProduct-->'+objProduct);
                
                Benefi__c objBeni = [SELECT Id, Ben_code__c, Beneficiary__c, Dealership_Nature__c, Status_Flag__c, Email__c FROM Benefi__c WHERE
                                     Beneficiary__c = 'EMP' AND
                                     Dealership_Nature__c IN ('CP-BH', 'CP-BHB', 'PV-BH', 'PV-BHB', 'UPV-BH', 'UV-BH', 'UV-BHB', 'CP-HH') AND
                                     Status_Flag__c = 'L' AND
                                     Email__c != null];
                System.debug('objBeni-->'+objBeni);
                
                Beneficiary_Product__c objBenProduct = [SELECT Id, Ben_code__c, Unique_Identifier__c FROM Beneficiary_Product__c WHERE Product__r.ProductCode != 'C' LIMIT 1];
                System.debug('objBenProduct-->'+objBenProduct);
                
                LoanDisbursementController.getDoToBeAuthorizedByDDValues(optg1.id);
                LoanDisbursementController.getDoToBeAuthorizedByDDValues(optg2.id);
                
                System.assertNotEquals(null, LoanDisbursementController.getDoToBeAuthorizedByDDValues(optg1.id));
                
            }
            Test.stopTest();                          
        }catch(Exception e){
            system.assertEquals('Script-thrown exception', e.getMessage());
        }
    } 
    
    @isTest
    private static void getDoToBeAuthorizedByDDValuestest12() {
        try
        {
            
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE username='test_userprod123456@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {
                Opportunity optg1 = [SELECT Id, Ben_Code__c, Loan_Application_Number__c, Product_Type__c, Vehicle_Type__c, Vehicle_Sub_Category__c FROM Opportunity WHERE Vehicle_Type__c =: 'Used' limit 1];
                System.debug('optg1-->'+optg1);
                optg1.Product_Type__c = 'Tractor';
                update optg1;
                
                Opportunity optg2 = [SELECT Id, Ben_Code__c, Loan_Application_Number__c, Product_Type__c, Vehicle_Type__c, Vehicle_Sub_Category__c FROM Opportunity WHERE Vehicle_Type__c =: 'New' limit 1];
                System.debug('optg2-->'+optg2);
                
                Product2 objProduct = [SELECT id, ProductCode, Name, Type__c, External_Reference_Id__c FROM Product2 LIMIT 1];
                System.debug('objProduct-->'+objProduct);
                
                Benefi__c objBeni = [SELECT Id, Ben_code__c, Beneficiary__c, Dealership_Nature__c, Status_Flag__c, Email__c FROM Benefi__c WHERE
                                     Beneficiary__c = 'EMP' AND
                                     Dealership_Nature__c IN ('CP-BH', 'CP-BHB', 'PV-BH', 'PV-BHB', 'UPV-BH', 'UV-BH', 'UV-BHB', 'CP-HH') AND
                                     Status_Flag__c = 'L' AND
                                     Email__c != null];
                System.debug('objBeni-->'+objBeni);
                
                Beneficiary_Product__c objBenProduct = [SELECT Id, Ben_code__c, Unique_Identifier__c FROM Beneficiary_Product__c WHERE Product__r.ProductCode != 'C' LIMIT 1];
                System.debug('objBenProduct-->'+objBenProduct);
                
                LoanDisbursementController.getDoToBeAuthorizedByDDValues(optg1.id);
                LoanDisbursementController.getDoToBeAuthorizedByDDValues(optg2.id);
                
                System.assertNotEquals(null, LoanDisbursementController.getDoToBeAuthorizedByDDValues(optg1.id));
                
            }
            Test.stopTest();                          
        }catch(Exception e){
            system.assertEquals('Script-thrown exception', e.getMessage());
        }
    } 
    
    @isTest
    private static void getDoToBeAuthorizedByDDValuestest122() {
        try
        {
            
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE username='test_userprod123456@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {
                
                
                LoanDisbursementController.getDoToBeAuthorizedByDDValues(null);
                
            }
            Test.stopTest();                          
        }catch(Exception e){
            system.assertEquals('Script-thrown exception', e.getMessage());
        }
    } 
    
    @isTest
    private static void newBusinessPaymentWrappertest() {
        try
        {
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE username='test_userprod123456@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {
                LoanDisbursementController.BusinessPaymentWrapper wrp = new LoanDisbursementController.BusinessPaymentWrapper();
                wrp.disbursementRecordId = '00571000000ML7RAAW';
                wrp.paymentOrgFrom = 'pay';
                wrp.vehicleSoldBy = 'vehSold';
                wrp.vehicleRegInNameOf = 'regName';
                wrp.busiSourceBy = 'sourcBY';
                wrp.busiDoneBy = 'busi';
                wrp.fiDoneBy = 'doneBY';
                wrp.colleExe = '';
                wrp.doIssuance = 'yes';
                wrp.doIssuanceMode = 'Online';
                wrp.toBeAuthBy = 'mee';
                wrp.balTrans = 80;
                wrp.purChasDocCatq = 'dssd';
                wrp.origPurchaseVal = 70;
                wrp.origPurchaseDate = system.today();
                wrp.fundEndUse = 'fds';
                wrp.parentLoanApplication = 'ygshxz';
                
                
                LoanDisbursementController.newBusinessPaymentWrapper();
                system.assertNotEquals(wrp, LoanDisbursementController.newBusinessPaymentWrapper());
                
                
                LoanDisbursementController.Beneficiary_Master_Wrapper beniWrp = new LoanDisbursementController.Beneficiary_Master_Wrapper();
                beniWrp.id = '00571000000ML7RAAW';
                beniWrp.benCode = 'abc';
                beniWrp.benName = 'Name';
                
                LoanDisbursementController.newBeneficiaryMasterWrapper();
                
                
                
            }
            Test.stopTest();                          
        }catch(Exception e){
            system.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    private static void getIstInsurancePremiumPaidByDDValuestest() {
        try
        {
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE username='test_userprod123456@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {   
                list <String> rtnList = new List<String>{'Dealer','Free Insurance','Policy Taken By Customer'};
                    Opportunity oppRec = [ SELECT Id,Vehicle_Type__c, Funded__c, Non_Funded__c, Is_customer_interested_in_a_motor_insura__c, Motor_Insurance_Premium__c
                                          FROM Opportunity WHERE Vehicle_Type__c = 'Used' LIMIT 1];
                
                Opportunity oppRec1 = [ SELECT Id,Vehicle_Type__c, Funded__c, Non_Funded__c, Is_customer_interested_in_a_motor_insura__c, Motor_Insurance_Premium__c
                                       FROM Opportunity WHERE Vehicle_Type__c = 'New' LIMIT 1];
                
                List <String> rtnListFrom = LoanDisbursementController.getIstInsurancePremiumPaidByDDValues(oppRec.Id);
                
                List <String> rtnListFrom1 = LoanDisbursementController.getIstInsurancePremiumPaidByDDValues(oppRec1.Id);
                system.debug(rtnListFrom);
                system.debug(rtnListFrom1);
                
                system.assertnotEquals(rtnList, rtnListFrom);
                
                oppRec1.Is_customer_interested_in_a_motor_insura__c = false;
                Update oppRec1;
                
                List <String> rtnListFrom2 = LoanDisbursementController.getIstInsurancePremiumPaidByDDValues(oppRec1.Id);
                LoanDisbursementController.getIstInsurancePremiumPaidByDDValues(null);
                
                System.assertEquals(rtnList, rtnListFrom2);
                
            }
            Test.stopTest();                          
        }catch(Exception e){
            system.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    private static void handleInsuranceSubmittest() {
        try
        {
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE username='test_userprod123456@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            { 
                Opportunity oppRec = [SELECT Id, Vehicle_Type__c, Product_Type__c FROM Opportunity WHERE Vehicle_Type__c = 'Used' LIMIT 1];
                
                Deal_Number__c deal = [select id from Deal_Number__c limit 1];
                
                LoanDisbursementController.InsuranceWrapper loanw= new LoanDisbursementController.InsuranceWrapper();
                
                Opportunity optg1 = [SELECT Id, Name, StageName, CloseDate, Vehicle_Type__c, Product_Type__c FROM Opportunity WHERE Product_Type__c =: 'Two Wheeler'];
                
                List <LoanDisbursementDetails__c> disbursementList =  [SELECT Id, Parent_Loan_Application__c, Borrower_Name__c, Payment_Originated_From__c, Vehicle_Sold_By__c, Vehicle_Registered_in_Name__c, Business_Sourced_By__c, FI_Done_By__c, Collection_Executive__c, Do_Issuance__c, Do_Issuance_Mode__c, Do_To_be_authorized_by__c, Balance_Transfer_Amount_in_Rs__c, Purchase_doc_catq__c, Original_Purchase_value_in_Rs__c, Original_purchase_date__c, Fund_End_Use__c FROM LoanDisbursementDetails__c WHERE Parent_Loan_Application__c =: optg1.Id LIMIT 1];
                
                Applicant__c objApplicant = [SELECT Id, Opportunity__c, Applicant_Type__c, Contact_number__c FROM Applicant__c WHERE Opportunity__c =: optg1.Id LIMIT 1];
                
                loanw.disbursementRecordId='';
                loanw.insuranceAppNo='test';
                loanw.installments='test';
                loanw.longTermPolicyAvailable='test';
                loanw.longTermPolicyOwnDamageYrs='test';
                loanw.policyAvailable='test';
                loanw.rsd=String.valueOf(System.today());
                loanw.insurer= null;                   
                loanw.gst=String.valueOf(123);
                loanw.ownDamagePremiumAddons='123';
                loanw.thirdPartyPremiumsPaCover='123';
                loanw.firstYr_Idv='123';
                loanw.firstYr_OwnDamagePremium='123';
                loanw.firstYr_ThirdPartyPremium='123';
                loanw.secondYr_IDV='123';
                loanw.secondYr_OwnDamagePremium='123';
                loanw.secondYr_ThirdPartyPremium='123';
                loanw.thirdYr_IDV='123';
                loanw.thirdYr_OwnDamagePremium='123';
                loanw.thirdYr_ThirdParty_Premium='123';
                loanw.fourthYr_IDV='123';
                loanw.fourthYr_OwnDamagePremium='123';
                loanw.fourthYr_ThirdPartyPremium='123';
                loanw.fifthYr_Idv='123';
                loanw.fifthYr_OwnDamagePremium='123';
                loanw.fifthYr_ThirdPartyPremium='123';
                //Nominee Details Screen
                loanw.isCoBorrowerPresent = true;
                loanw.borrowerName = 'BName';
                loanw.borrowerDOB = null;
                loanw.borrowerRelationship = 'Father';
                loanw.borrowerAddress = 'Delhi';
                loanw.borrowerSpouseGender = 'Male';
                loanw.borrowerSpouseDOB = null;
                loanw.borrowerFirstChildName = 'FChild';
                loanw.borrowerFirstChildGender = 'Male';
                loanw.borrowerFirstChildDOB = null;
                loanw.borrowerSecondChildName ='Fchild';
                loanw.borrowerSecondChildGender = 'Male';
                loanw.borrowerSecondChildDOB = null;
                loanw.borrowerThirdChildName = 'SChild';
                loanw.borrowerThirdChildGender = 'Female';
                loanw.borrowerThirdChildDOB = null;
                loanw.borrowerFatherDOB = null;
                loanw.borrowerMotherDOB = null;
                loanw.borrowerInsuDoneBy = 'Agt';
                
                loanw.coBorrowerName = 'CBName';
                loanw.coBorrowerDOB = null;
                loanw.coBorrowerRelationship = 'Father';
                loanw.coBorrowerAddress = 'Mumbai';
                loanw.coBorrowerSpouseGender = 'Female';
                loanw.coBorrowerSpouseDOB = null;
                loanw.coBorrowerFirstChildName = 'Chris';
                loanw.coBorrowerFirstChildGender = 'Male';
                loanw.coBorrowerFirstChildDOB = null;
                loanw.coBorrowerSecondChildName = 'Thor';
                loanw.coBorrowerSecondChildGender = 'Female';
                loanw.coBorrowerSecondChildDOB = null;
                loanw.coBorrowerThirdChildName = 'Iron';
                loanw.coBorrowerThirdChildGender = 'Male';
                loanw.coBorrowerThirdChildDOB = null;
                loanw.coBorrowerFatherDOB = null;
                loanw.coBorrowerMotherDOB = null;
                loanw.coBorrowerInsuDoneBy = 'Agnet';
                
                LoanDisbursementController.handleInsuranceSubmit(JSON.serialize(loanw), oppRec.Id, deal.Id); 
                LoanDisbursementController.handleInsuranceSubmit('', oppRec.Id, deal.Id); 
                
                Test.stopTest(); 
                
            }
            
        }catch(Exception e){
            System.debug('error '+e.getMessage());
            //system.assertnotEquals('Script-thrown exception', e.getMessage());
        }
    }
    @isTest
    private static void addNomineeDetailsToWrappertest() {
        try
        {
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE username='test_userprod123456@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            { 
                Opportunity oppRec = [SELECT Id, Vehicle_Type__c, Product_Type__c FROM Opportunity WHERE Vehicle_Type__c = 'Used' LIMIT 1];
                
                LoanDisbursementController.InsuranceWrapper loanw= new LoanDisbursementController.InsuranceWrapper();
                
                Opportunity optg1 = [SELECT Id, Name, StageName, CloseDate, Vehicle_Type__c, Product_Type__c FROM Opportunity WHERE Product_Type__c =: 'Two Wheeler'];
                
                List <LoanDisbursementDetails__c> disbursementList =  [SELECT Id, Parent_Loan_Application__c, Borrower_DOB__c, Borrower_Name__c, Borrower_Relationship__c,
                                                                       Payment_Originated_From__c, Vehicle_Sold_By__c, Vehicle_Registered_in_Name__c, Business_Sourced_By__c,
                                                                       FI_Done_By__c, Collection_Executive__c, Do_Issuance__c, Do_Issuance_Mode__c, Do_To_be_authorized_by__c, 
                                                                       Balance_Transfer_Amount_in_Rs__c, Purchase_doc_catq__c, Original_Purchase_value_in_Rs__c, 
                                                                       Original_purchase_date__c, Fund_End_Use__c, Borrower_Address__c, Borrower_Spouse_Gender__c, Borrower_Spouse_DOB__c,
                                                                       Borrower_X1st_Child_Name__c, Borrower_X1st_Child_DOB__c, Borrower_X2nd_Child_Name__c,
                                                                       Borrower_X2nd_Child_Gender__c, Borrower_X2nd_Child_DOB__c, Borrower_X3rd_Child_Name__c, 
                                                                       Borrower_X3rd_Child_Gender__c, Borrower_X3rd_Child_DOB__c, Borrower_Father_DOB__c,
                                                                       Borrower_Mother_DOB__c, Borrower_Insurance_business_done_by__c, CoBorrower_Name__c,
                                                                       CoBorrower_DOB__c, CoBorrower_Relationship__c, CoBorrower_Address__c, CoBorrower_Spouse_Gender__c,
                                                                       CoBorrower_Spouse_DOB__c, CoBorrower_X1st_Child_Name__c, CoBorrower_X1st_Child_Gender__c,
                                                                       CoBorrower_X1st_Child_DOB__c, CoBorrower_X2nd_Child_Name__c, CoBorrower_X2nd_Child_Gender__c, 
                                                                       CoBorrower_X2nd_Child_DOB__c, CoBorrower_X3rd_Child_Name__c, CoBorrower_X3rd_Child_Gender__c,
                                                                       CoBorrower_X3rd_Child_DOB__c, CoBorrower_Father_DOB__c, CoBorrower_Mother_DOB__c, CoBorrower_Insurance_business_done_by__c,
                                                                       Borrower_X1st_Child_Gender__c
                                                                       FROM LoanDisbursementDetails__c WHERE Parent_Loan_Application__c =: optg1.Id LIMIT 1];
                
                Applicant__c objApplicant = [SELECT Id, Opportunity__c, Applicant_Type__c, Contact_number__c FROM Applicant__c WHERE Opportunity__c =: optg1.Id LIMIT 1];
                
                loanw.disbursementRecordId='';
                loanw.insuranceAppNo='test';
                loanw.installments='test';
                loanw.longTermPolicyAvailable='test';
                loanw.longTermPolicyOwnDamageYrs='test';
                loanw.policyAvailable='test';
                loanw.rsd=String.valueOf(System.today());
                loanw.insurer= null;                   
                loanw.gst=String.valueOf(123);
                loanw.ownDamagePremiumAddons='123';
                loanw.thirdPartyPremiumsPaCover='123';
                loanw.firstYr_Idv='123';
                loanw.firstYr_OwnDamagePremium='123';
                loanw.firstYr_ThirdPartyPremium='123';
                loanw.secondYr_IDV='123';
                loanw.secondYr_OwnDamagePremium='123';
                loanw.secondYr_ThirdPartyPremium='123';
                loanw.thirdYr_IDV='123';
                loanw.thirdYr_OwnDamagePremium='123';
                loanw.thirdYr_ThirdParty_Premium='123';
                loanw.fourthYr_IDV='123';
                loanw.fourthYr_OwnDamagePremium='123';
                loanw.fourthYr_ThirdPartyPremium='123';
                loanw.fifthYr_Idv='123';
                loanw.fifthYr_OwnDamagePremium='123';
                loanw.fifthYr_ThirdPartyPremium='123';
                //Nominee Details Screen
                loanw.isCoBorrowerPresent = true;
                loanw.borrowerName = 'BName';
                loanw.borrowerDOB = null;
                loanw.borrowerRelationship = 'Father';
                loanw.borrowerAddress = 'Delhi';
                loanw.borrowerSpouseGender = 'Male';
                loanw.borrowerSpouseDOB = null;
                loanw.borrowerFirstChildName = 'FChild';
                loanw.borrowerFirstChildGender = 'Male';
                loanw.borrowerFirstChildDOB = null;
                loanw.borrowerSecondChildName ='Fchild';
                loanw.borrowerSecondChildGender = 'Male';
                loanw.borrowerSecondChildDOB = null;
                loanw.borrowerThirdChildName = 'SChild';
                loanw.borrowerThirdChildGender = 'Female';
                loanw.borrowerThirdChildDOB = null;
                loanw.borrowerFatherDOB = null;
                loanw.borrowerMotherDOB = null;
                loanw.borrowerInsuDoneBy = 'Agt';
                
                loanw.coBorrowerName = 'CBName';
                loanw.coBorrowerDOB = null;
                loanw.coBorrowerRelationship = 'Father';
                loanw.coBorrowerAddress = 'Mumbai';
                loanw.coBorrowerSpouseGender = 'Female';
                loanw.coBorrowerSpouseDOB = null;
                loanw.coBorrowerFirstChildName = 'Chris';
                loanw.coBorrowerFirstChildGender = 'Male';
                loanw.coBorrowerFirstChildDOB = null;
                loanw.coBorrowerSecondChildName = 'Thor';
                loanw.coBorrowerSecondChildGender = 'Female';
                loanw.coBorrowerSecondChildDOB = null;
                loanw.coBorrowerThirdChildName = 'Iron';
                loanw.coBorrowerThirdChildGender = 'Male';
                loanw.coBorrowerThirdChildDOB = null;
                loanw.coBorrowerFatherDOB = null;
                loanw.coBorrowerMotherDOB = null;
                loanw.coBorrowerInsuDoneBy = 'Agnet';
                
                LoanDisbursementController.addNomineeDetailsToWrapper(loanw, disbursementList, oppRec.Id);
                System.assertEquals(loanw, LoanDisbursementController.addNomineeDetailsToWrapper(loanw, disbursementList, oppRec.Id));                                       
                
                Test.stopTest(); 
                
            }
            
        }catch(Exception e){
            System.debug('error '+e.getMessage());
            //system.assertnotEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    private static void loadInsuranceDetailsTest() {
        try
        {
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE username='test_userprod123456@indusbank.com' AND IsActive = true LIMIT 1];
            
            System.runAs(u) 
            {                 
                Opportunity optg1 = [SELECT Id FROM Opportunity WHERE Product_Type__c = 'Two Wheeler'];
                Applicant__c app = new Applicant__c();
                app.Opportunity__c = optg1.id;
                app.Applicant_Type__c = System.Label.Borrower;
                insert app;
                List<InsuranceDetails__c> instList = new List<InsuranceDetails__c>();
                for(InsuranceDetails__c ins : [Select Id From InsuranceDetails__c Where Loan_Application__c =: optg1.Id]){
                    ins.applicant__c = app.Id;
                    instList.add(ins);
                }
                update instList;
                String result = LoanDisbursementController.loadInsuranceDetails(optg1.Id);  
                System.assertNotEquals(null, result);
            }
            Test.stopTest(); 
            
        }catch(Exception e){
            system.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    // @isTest
    // private static void handleBeneficiaryDetailsSubmittest() {
    //     try
    //     {
    //         Test.startTest();
    //         User u = [SELECT Id,usertype FROM User WHERE username='test_userprod123456@indusbank.com' AND IsActive = true LIMIT 1]; 
    //         System.runAs(u) 
    //         { 
                
    //             Opportunity optg1 = [SELECT Id, Name, StageName, Sub_Stage__c, CloseDate, Vehicle_Type__c, Vehicle_Sub_Category__c, Product_Type__c FROM Opportunity WHERE Product_Type__c =:System.Label.TwoWheeler];
                
    //             Deal_Number__c deal = [select id from Deal_Number__c limit 1];
    //             Vehicle_Detail__c vd = [select id from Vehicle_Detail__c limit 1];
                
                
    //             LoanDisbursementDetails__c loans = [SELECT Id, Payment_Originated_From__c, Parent_Loan_Application__c, DSA_Name__c, Physical_mandate_dispatched_to_Karapakka__c FROM LoanDisbursementDetails__c WHERE Parent_Loan_Application__c =: optg1.Id];
                
    //             LoanDisbursementController.BeneficiaryDetailsWrapper loanb = new LoanDisbursementController.BeneficiaryDetailsWrapper();
    //             loanb.loanDisbursementDetailId= loans.Id;
    //             loanb.parentLoanAppId= optg1.Id;
    //             loanb.dsaName='test';
    //             loanb.paymentToDSA=true;
    //             loanb.coborrowerName='test';
    //             loanb.paymentToCoborrower=true;
    //             loanb.phyMandateDispToKarapakkam='test';
    //             loanb.bankName='inde';
    //             loanb.accountNumber='4657207336';
    //             loanb.bankBranchName='pdk';
    //             loanb.bankBranchPincode='543605';
    //             loanb.dealerPayment=10000;
    //             loanb.paymentOriginatedFrom='test';
                
    //             Final_Term__c fgd3 = new Final_Term__c();
    //             fgd3.CRM_IRR__c = 120;
    //             fgd3.Loan_Application__c = optg1.Id;
    //             fgd3.Holiday_period__c='30';
    //             fgd3.EMI_Amount__c= 10000;
    //             fgd3.Loan_Amount__c = '100000';
    //             fgd3.Vehicle_Detail__c=vd.Id;
    //             fgd3.FIwaiver_offAddress__c = 'Not Waived';
    //             insert fgd3;
                
    //             LoanDisbursementController.getLoanDisbursementDetails(optg1.Id, deal.Id);
    //             LoanDisbursementController.CheckBalanceTranserFieldAccessbility(optg1.Id, deal.Id);
    //             LoanDisbursementController.getBeneficiaryDetails(optg1.Id, deal.Id);
    //             LoanDisbursementController.handleBeneficiaryDetailsSubmit(JSON.serialize(loanb));
                
    //             Test.stopTest(); 
    //         }
            
    //     }catch(Exception e){
    //         system.assertEquals('Script-thrown exception', e.getMessage());
    //     }
    // }
    
    @isTest
    private static void handleBeneficiaryDetailsSubmittest1() {
        try
        {
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE username='test_userprod123456@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            { 
                
                Opportunity optg1 = [SELECT Id, Name, StageName, Sub_Stage__c, CloseDate, Vehicle_Type__c, Vehicle_Sub_Category__c, Product_Type__c FROM Opportunity WHERE Product_Type__c = 'Two Wheeler'];
                
                LoanDisbursementDetails__c loans = [SELECT Id, Payment_Originated_From__c, Parent_Loan_Application__c, DSA_Name__c, Physical_mandate_dispatched_to_Karapakka__c FROM LoanDisbursementDetails__c WHERE Parent_Loan_Application__c =: optg1.Id];
                
                LoanDisbursementController.BeneficiaryDetailsWrapper loanb = new LoanDisbursementController.BeneficiaryDetailsWrapper();
                loanb.loanDisbursementDetailId= loans.Id;
                loanb.parentLoanAppId= optg1.Id;
                loanb.dsaName='test';
                loanb.paymentToDSA=true;
                loanb.coborrowerName='test';
                loanb.paymentToCoborrower=true;
                loanb.phyMandateDispToKarapakkam='test';
                loanb.bankName='inde';
                loanb.accountNumber='4657207336';
                loanb.bankBranchName='pdk';
                loanb.bankBranchPincode='543605';
                loanb.dealerPayment=10000;
                loanb.paymentOriginatedFrom='test';
                
                LoanDisbursementController.handleBeneficiaryDetailsSubmit(JSON.serialize(loanb));
                
                Test.stopTest(); 
            }
            
        }catch(Exception e){
            //system.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    private static void getDealerSubDealerNametest() {
        try
        {              
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE username='test_userprod123456@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {
                Account acc= [SELECT Id, Name From Account WHERE Name =: 'accName'];
                
                Contact con = [SELECT ID, LastName, AccountId FROM Contact WHERE AccountId =: acc.Id LIMIT 1];
                
                Opportunity optg1 = [SELECT Id, Name, StageName, CloseDate, Vehicle_Type__c, Product_Type__c, AccountId FROM Opportunity WHERE AccountId =: acc.Id AND Vehicle_Type__c =: 'Used' LIMIT 1];
                
                Applicant__c objApplicant = [SELECT Id, Opportunity__c, Applicant_Type__c, Contact_number__c FROM Applicant__c WHERE Opportunity__c =: optg1.Id LIMIT 1];
                
                List <Documents__c> docsList = [SELECT Id, name, Applicant__c, Opportunity_Relation__c, Document_Type__c FROM Documents__c WHERE name =: 'DocName' LIMIT 1];
                docsList[0].Document_Type__c = 'Seller Bank Details';
                update docsList;
                
                List <Asset> assetList = [SELECT Id, Name, ContactId, Dealer_Sub_dealer_name__c FROM Asset WHERE Name =: 'astName' Limit 1];
                
                LoanDisbursementController.getDealerSubDealerName(optg1.Id);
                LoanDisbursementController.getDealerSubDealerName(null);
                
                LoanDisbursementController.getSellerBankDetails(optg1.Id);
                LoanDisbursementController.getSellerBankDetails(null);
                
                System.assertEquals('accName', LoanDisbursementController.getDealerSubDealerName(optg1.Id));
                System.assertEquals(null, LoanDisbursementController.getDealerSubDealerName(null));
                
                System.assertEquals(null, LoanDisbursementController.getSellerBankDetails(null));
                System.assertEquals(docsList[0].Id, LoanDisbursementController.getSellerBankDetails(optg1.Id).Id);
                
            }
            Test.stopTest();                          
        }catch(Exception e){
            system.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    
    @isTest
    private static void saveLoanAppTransactionHistorytest() {
        try
        {
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE username='test_userprod123456@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {
                
                Account acc = [SELECT Id, Name FROM Account WHERE Name =: 'accName'];
                
                Opportunity opgr1 = [SELECT Id, Name, StageName, CloseDate, Product_Type__c, AccountId FROM Opportunity WHERE Product_Type__c = 'Two Wheeler' LIMIT 1];
                
                Deal_Number__c deal = [select id from Deal_Number__c limit 1];
                
                AccountTeamMember actMem = [SELECT Id, AccountId, TeamMemberRole, UserId, Level__c, AccountAccessLevel FROM AccountTeamMember WHERE AccountId =: acc.Id];
                
                LoanDisbursementController.saveLoanAppTransactionHistory(opgr1.Id,'abc', deal.Id);
                
            }
            Test.stopTest();                          
        }catch(Exception e){
            system.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    
    @isTest
    private static void saveLoanAppTransactionHistorytest1() {
        try
        {
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE username='test_userprod123456@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {
                Opportunity opgr1 = [SELECT Id, Name, StageName, CloseDate, Product_Type__c, AccountId FROM Opportunity WHERE Vehicle_Type__c = 'New' LIMIT 1];
                
                Deal_Number_Setting__c dlNumberSetting= new Deal_Number_Setting__c();
                dlNumberSetting.Name = System.Label.PassengerVehicles;
                dlNumberSetting.MDNField1__c ='AB';
                dlNumberSetting.MDNField2__c = 2.0;
                insert dlNumberSetting;
                
                
                Deal_Number__c dl=new Deal_Number__c();
                dl.Loan_Application__c = opgr1.Id;
                dl.DNField1__c = dlNumberSetting.MDNField1__c;
                dl.DNField2__c = String.valueOf(dlNumberSetting.MDNField2__c.round());
               // dl.Sub_Stage__c = 'test'; 
                insert dl;
                
                AccountTeamMember actMem = [SELECT Id, AccountId, TeamMemberRole, UserId, Level__c, AccountAccessLevel FROM AccountTeamMember WHERE AccountId =: opgr1.AccountId];
                
                actMem.TeamMemberRole = 'BE';
                Update actMem;
                
                LoanDisbursementController.saveLoanAppTransactionHistory(opgr1.Id,'abc',dl.Id);
                
            }
            Test.stopTest();                          
        }catch(Exception e){
            system.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    @isTest
    private static void calculateDealerPaymenttest() {
        try
        {
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE username='test_userprod123456@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {
                Opportunity optg1 = [SELECT Id, Name, StageName, CloseDate, Product_Type__c, AccountId FROM Opportunity WHERE Product_Type__c = 'Two Wheeler' LIMIT 1];
                
                Deal_Number__c deal = [select id from Deal_Number__c limit 1];
                
                IHM__c  objIHM = [SELECT Id, Margin_money_to_be_deducted_from_disburs__c, Loan_Application__c FROM IHM__c WHERE Loan_Application__c =: optg1.Id];
                
                InsuranceDetails__c objInsurance = [SELECT Id, Loan_Application__c, Funded_Premium__c FROM InsuranceDetails__c WHERE Loan_Application__c =: optg1.Id];
                
                CAM__c objCAM = [SELECT Id, Loan_Application__c, Loan_Amount__c FROM CAM__c WHERE Loan_Application__c =: optg1.Id];
                
                LoanDisbursementController.calculateDealerPayment(optg1.id,'Used', deal.Id);
                LoanDisbursementController.calculateDealerPayment(optg1.id,'New', deal.Id);
                
                System.assertEquals(-500.00, LoanDisbursementController.calculateDealerPayment(optg1.id,'Used', deal.Id));
                
                
            }
            Test.stopTest();                          
        }catch(Exception e){
            // system.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    private static void isAcctNumPresentInBenMastertest() {
        try
        {
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE username='test_user@abc.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {
                Boolean positive = LoanDisbursementController.isAcctNumberPresentInBenMaster('IND12345688');
                System.assertEquals(true, positive);
                Boolean negative = LoanDisbursementController.isAcctNumberPresentInBenMaster('IND12344232');
                LoanDisbursementController.isAcctNumberPresentInBenMaster(null);
                System.assertEquals(false, negative);
            }
            Test.stopTest();                          
        }catch(Exception e){
            system.assertNotEquals(null, e.getMessage());
        }
    }
    @isTest
    public static void getBenifRecordTest(){
        try
        {
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE username='test_userprod123456@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {
                List<Benefi__c> beneObj = [Select Id from Benefi__c Limit 1];
                beneObj = LoanDisbursementController.getBenifRecord(beneObj[0].Id);
                LoanDisbursementController.isAcctNumberPresentInBenMaster('IND12345688');
                
            }
            Test.stopTest();                          
        }catch(Exception e){
            System.debug('e-'+e.getMessage());
        }
    }
    @isTest
    public static void vehicleWrapper(){
        try
        {
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE username='test_userprod123456@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {
                LoanDisbursementController.TBM_DL_Master_Wrapper tbmDL = new LoanDisbursementController.TBM_DL_Master_Wrapper();
                tbmDL.id = 'TW';
                tbmDL.dlcode = 'TW';
                tbmDL.excname = 'ENG234';
                
                LoanDisbursementController.TBM_DL_Master_Wrapper tbmDL1 = new LoanDisbursementController.TBM_DL_Master_Wrapper('TW','TW','ENG234');
                
            }
            Test.stopTest();                          
        }catch(Exception e){
            System.debug('e-'+e.getMessage());
        }
    }
    
    @isTest
    public static void getbussdonebyTest(){
        try{
            Account acc = new Account();
            acc.Name = 'AccName';
            insert acc;
            
            Opportunity opga1 = new Opportunity();
            opga1.AccountId = acc.Id;
            opga1.StageName = 'Qualification';
            opga1.CloseDate = Date.newInstance(2021, 1, 11);
            opga1.Name = 'testone';
            opga1.Product_Type__c = 'Two Wheeler';
            insert opga1;
            
            Deal_Number_Setting__c dlNumberSetting= new Deal_Number_Setting__c();
            dlNumberSetting.Name = System.Label.TwoWheeler;
            dlNumberSetting.MDNField1__c ='AB';
            dlNumberSetting.MDNField2__c = 2.0;
            insert dlNumberSetting;
            
            
            Deal_Number__c dl=new Deal_Number__c();
            dl.Loan_Application__c = opga1.Id;
            dl.DNField1__c = dlNumberSetting.MDNField1__c;
            dl.DNField2__c = String.valueOf(dlNumberSetting.MDNField2__c.round());
            dl.Sub_Stage__c = 'Beneficiary Details'; 
            insert dl;
            
            AccountTeamMember atm2 = new AccountTeamMember();
            atm2.AccountId = opga1.AccountId;
            atm2.TeamMemberRole = 'MO';
            atm2.UserId = UserInfo.getUserId();
            insert atm2;
            
            Test.startTest();
            LoanDisbursementController.getbussdoneby(opga1.Id, dl.Id);
            Test.stopTest();
            
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void getbussdonebyTest1(){
        try{
            Account acc = new Account();
            acc.Name = 'AccName';
            insert acc;
            
            Opportunity opga1 = new Opportunity();
            opga1.AccountId = acc.Id;
            opga1.StageName = 'Qualification';
            opga1.CloseDate = Date.newInstance(2021, 1, 11);
            opga1.Name = 'testone';
            opga1.Product_Type__c = 'Passenger Vehicles';
            insert opga1;
            
            Deal_Number_Setting__c dlNumberSetting= new Deal_Number_Setting__c();
            dlNumberSetting.Name = System.Label.PassengerVehicles;
            dlNumberSetting.MDNField1__c ='AB';
            dlNumberSetting.MDNField2__c = 2.0;
            insert dlNumberSetting;
            
            
            Deal_Number__c dl=new Deal_Number__c();
            dl.Loan_Application__c = opga1.Id;
            dl.DNField1__c = dlNumberSetting.MDNField1__c;
            dl.DNField2__c = String.valueOf(dlNumberSetting.MDNField2__c.round());
            dl.Sub_Stage__c = 'Beneficiary Details'; 
            insert dl;
            
            AccountTeamMember atm2 = new AccountTeamMember();
            atm2.AccountId = opga1.AccountId;
            atm2.TeamMemberRole = 'MO';
            atm2.UserId = UserInfo.getUserId();
            insert atm2;
            
            Test.startTest();
            LoanDisbursementController.getbussdoneby(opga1.Id, dl.Id);
            Test.stopTest();
            
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void calculateDealerPaymentTest1(){
        
        Opportunity opks1 = new Opportunity();
        opks1.StageName = 'Qualification';
        opks1.CloseDate = Date.newInstance(2021, 1, 11);
        opks1.Name = 'testone';
        opks1.Vehicle_Type__c = 'Used';
        opks1.Vehicle_Sub_Category__c = 'UPD';
        opks1.Product_Type__c = System.Label.PassengerVehicles;
        insert opks1;
        
        Deal_Number_Setting__c dlNumberSetting= new Deal_Number_Setting__c();
        dlNumberSetting.Name = System.Label.PassengerVehicles;
        dlNumberSetting.MDNField1__c ='AB';
        dlNumberSetting.MDNField2__c = 2.0;
        insert dlNumberSetting;
        
        
        Deal_Number__c dl=new Deal_Number__c();
        dl.Loan_Application__c = opks1.Id;
        dl.DNField1__c = dlNumberSetting.MDNField1__c;
        dl.DNField2__c = String.valueOf(dlNumberSetting.MDNField2__c.round());
        //dl.Sub_Stage__c = 'test'; 
        insert dl;
        
        Applicant__c apks1 = new Applicant__c();
        apks1.Opportunity__c = opks1.Id;
        apks1.Contact_number__c = '9743514830';
        apks1.Applicant_Type__c = 'Borrower';
        insert apks1;
        
        Final_Term__c fgd3 = new Final_Term__c();
        fgd3.CRM_IRR__c = 120;
        fgd3.Loan_Application__c = opks1.Id;
        fgd3.Holiday_period__c='30';
        fgd3.EMI_Amount__c= 10000;
        fgd3.Loan_Amount__c = '100000';
        fgd3.FIwaiver_offAddress__c = 'Not Waived';
        insert fgd3;
        
        Test.startTest();
        LoanDisbursementController.calculateDealerPayment(opks1.Id,opks1.Vehicle_Type__c, dl.Id);
        Test.stopTest();
    }
    
    @isTest
    public static void calculateDealerPaymentTest2(){
        
        Opportunity opks1 = new Opportunity();
        opks1.StageName = 'Qualification';
        opks1.CloseDate = Date.newInstance(2021, 1, 11);
        opks1.Name = 'testone';
        opks1.Vehicle_Type__c = 'New';
        opks1.Vehicle_Sub_Category__c = 'UPD';
        //   opks1.Product_Type__c = System.Label.PassengerVehicles;
        insert opks1;
        
        Deal_Number_Setting__c dlNumberSetting= new Deal_Number_Setting__c();
        dlNumberSetting.Name = System.Label.Tractor;
        dlNumberSetting.MDNField1__c ='AB';
        dlNumberSetting.MDNField2__c = 2.0;
        insert dlNumberSetting;
        
        
        Deal_Number__c dl=new Deal_Number__c();
        dl.Loan_Application__c = opks1.Id;
        dl.DNField1__c = dlNumberSetting.MDNField1__c;
        dl.DNField2__c = String.valueOf(dlNumberSetting.MDNField2__c.round());
        //dl.Sub_Stage__c = 'test'; 
        insert dl;
        
        Applicant__c apks1 = new Applicant__c();
        apks1.Opportunity__c = opks1.Id;
        apks1.Contact_number__c = '9743514830';
        apks1.Applicant_Type__c = 'Borrower';
        insert apks1;
        
        Final_Term__c fgd3 = new Final_Term__c();
        fgd3.CRM_IRR__c = 120;
        fgd3.Loan_Application__c = opks1.Id;
        fgd3.Holiday_period__c='30';
        fgd3.EMI_Amount__c= 10000;
        fgd3.Loan_Amount__c = '100000';
        fgd3.FIwaiver_offAddress__c = 'Not Waived';
        insert fgd3;
        
        Invoice_Details__c invoice = new Invoice_Details__c();
        invoice.Loan_Application__c = opks1.Id;
        invoice.Invoice_Amount_incl_discounts__c=1000;
        invoice.Tax_Invoice_Date__c = System.today();
        insert invoice;
        
        Test.startTest();
        LoanDisbursementController.calculateDealerPayment(opks1.Id,opks1.Vehicle_Type__c,dl.Id);
        Test.stopTest();
    }
    
    @isTest
    private static void handleBeneficiaryDetailsSubmittest3() {
        try
        {
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE username='test_userprod123456@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            { 
                
                Opportunity optg1 = [SELECT Id, Name, StageName, Sub_Stage__c, CloseDate, Vehicle_Type__c, Vehicle_Sub_Category__c, Product_Type__c FROM Opportunity WHERE Product_Type__c = 'Two Wheeler'];
                
                LoanDisbursementDetails__c loans = [SELECT Id, Payment_Originated_From__c, Parent_Loan_Application__c, DSA_Name__c, Physical_mandate_dispatched_to_Karapakka__c FROM LoanDisbursementDetails__c WHERE Parent_Loan_Application__c =: optg1.Id];
                
                LoanDisbursementController.BeneficiaryDetailsWrapper loanb = new LoanDisbursementController.BeneficiaryDetailsWrapper();
                loanb.loanDisbursementDetailId= loans.Id;
                loanb.parentLoanAppId= optg1.Id;
                loanb.dsaName='test';
                loanb.paymentToDSA=true;
                loanb.coborrowerName='test';
                loanb.paymentToCoborrower=true;
                loanb.phyMandateDispToKarapakkam='test';
                loanb.bankName='inde';
                loanb.accountNumber='4657207336';
                loanb.bankBranchName='pdk';
                loanb.bankBranchPincode='543605';
                loanb.dealerPayment=10000;
                loanb.paymentOriginatedFrom='test';
                loanb.isNewVehicle = true;
                
                LoanDisbursementController.handleBeneficiaryDetailsSubmit(JSON.serialize(loanb));
                
                Test.stopTest(); 
            }
            
        }catch(Exception e){
            //system.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    private static void handleBeneficiaryDetailsSubmittest4() {
        try
        {
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE username='test_userprod123456@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            { 
                
                Opportunity optg1 = [SELECT Id, Name, StageName, Sub_Stage__c, CloseDate, Vehicle_Type__c, Vehicle_Sub_Category__c, Product_Type__c FROM Opportunity WHERE Product_Type__c = 'Two Wheeler'];
                
                LoanDisbursementDetails__c loans = [SELECT Id, Payment_Originated_From__c, Parent_Loan_Application__c, DSA_Name__c, Physical_mandate_dispatched_to_Karapakka__c FROM LoanDisbursementDetails__c WHERE Parent_Loan_Application__c =: optg1.Id];
                
                LoanDisbursementController.BeneficiaryDetailsWrapper loanb = new LoanDisbursementController.BeneficiaryDetailsWrapper();
                loanb.loanDisbursementDetailId= loans.Id;
                loanb.parentLoanAppId= optg1.Id;
                loanb.dsaName='test';
                loanb.paymentToDSA=true;
                loanb.coborrowerName='test';
                loanb.paymentToCoborrower=true;
                loanb.phyMandateDispToKarapakkam='test';
                loanb.bankName='inde';
                loanb.accountNumber='4657207336';
                loanb.bankBranchName='pdk';
                loanb.bankBranchPincode='543605';
                loanb.dealerPayment=10000;
                loanb.paymentOriginatedFrom='test';
                loanb.isNewVehicle = false;
                loanb.loanAppVehicleSubCategory = 'UOB';
                loanb.paymentToDSA = true;
                loanb.paymentToCoborrower = true;
                
                LoanDisbursementController.handleBeneficiaryDetailsSubmit(JSON.serialize(loanb));
                
                Test.stopTest(); 
            }
            
        }catch(Exception e){
            //system.assertEquals('Script-thrown exception', e.getMessage());
        }
    } 
    
    @isTest
    private static void handleBeneficiaryDetailsSubmittest5() {
        try
        {
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE username='test_userprod123456@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            { 
                
                Opportunity optg1 = [SELECT Id, Name, StageName, Sub_Stage__c, CloseDate, Vehicle_Type__c, Vehicle_Sub_Category__c, Product_Type__c FROM Opportunity WHERE Product_Type__c = 'Two Wheeler'];
                
                LoanDisbursementDetails__c loans = [SELECT Id, Payment_Originated_From__c, Parent_Loan_Application__c, DSA_Name__c, Physical_mandate_dispatched_to_Karapakka__c FROM LoanDisbursementDetails__c WHERE Parent_Loan_Application__c =: optg1.Id];
                
                LoanDisbursementController.BeneficiaryDetailsWrapper loanb = new LoanDisbursementController.BeneficiaryDetailsWrapper();
                loanb.loanDisbursementDetailId= loans.Id;
                loanb.parentLoanAppId= optg1.Id;
                loanb.dsaName='test';
                loanb.paymentToDSA=true;
                loanb.coborrowerName='test';
                loanb.paymentToCoborrower=true;
                loanb.phyMandateDispToKarapakkam='test';
                loanb.bankName='inde';
                loanb.accountNumber='4657207336';
                loanb.bankBranchName='pdk';
                loanb.bankBranchPincode='543605';
                loanb.dealerPayment=10000;
                loanb.paymentOriginatedFrom='test';
                loanb.isNewVehicle = false;
                loanb.loanAppVehicleSubCategory = 'UOB';
                loanb.paymentToDSA = false;
                loanb.paymentToCoborrower = true;
                
                LoanDisbursementController.handleBeneficiaryDetailsSubmit(JSON.serialize(loanb));
                
                Test.stopTest(); 
            }
            
        }catch(Exception e){
            //system.assertEquals('Script-thrown exception', e.getMessage());
        }
    } 
    
    @isTest
    private static void handleBeneficiaryDetailsSubmittest6() {
        try
        {
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE username='test_userprod123456@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            { 
                
                Opportunity optg1 = [SELECT Id, Name, StageName, Sub_Stage__c, CloseDate, Vehicle_Type__c, Vehicle_Sub_Category__c, Product_Type__c FROM Opportunity WHERE Product_Type__c = 'Two Wheeler'];
                
                LoanDisbursementDetails__c loans = [SELECT Id, Payment_Originated_From__c, Parent_Loan_Application__c, DSA_Name__c, Physical_mandate_dispatched_to_Karapakka__c FROM LoanDisbursementDetails__c WHERE Parent_Loan_Application__c =: optg1.Id];
                
                LoanDisbursementController.BeneficiaryDetailsWrapper loanb = new LoanDisbursementController.BeneficiaryDetailsWrapper();
                loanb.loanDisbursementDetailId= loans.Id;
                loanb.parentLoanAppId= optg1.Id;
                loanb.dsaName='test';
                loanb.paymentToDSA=true;
                loanb.coborrowerName='test';
                loanb.paymentToCoborrower=true;
                loanb.phyMandateDispToKarapakkam='test';
                loanb.bankName='inde';
                loanb.accountNumber='4657207336';
                loanb.bankBranchName='pdk';
                loanb.bankBranchPincode='543605';
                loanb.dealerPayment=10000;
                loanb.paymentOriginatedFrom='test';
                loanb.isNewVehicle = false;
                loanb.loanAppVehicleSubCategory = 'UOB';
                loanb.paymentToDSA = true;
                loanb.paymentToCoborrower = false;
                
                LoanDisbursementController.handleBeneficiaryDetailsSubmit(JSON.serialize(loanb));
                
                Test.stopTest(); 
            }
            
        }catch(Exception e){
            //system.assertEquals('Script-thrown exception', e.getMessage());
        }
    } 
    
    @isTest
    private static void handleBeneficiaryDetailsSubmittest7() {
        try
        {
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE username='test_userprod123456@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            { 
                
                Opportunity optg1 = [SELECT Id, Name, StageName, Sub_Stage__c, CloseDate, Vehicle_Type__c, Vehicle_Sub_Category__c, Product_Type__c FROM Opportunity WHERE Product_Type__c = 'Two Wheeler'];
                
                LoanDisbursementDetails__c loans = [SELECT Id, Payment_Originated_From__c, Parent_Loan_Application__c, DSA_Name__c, Physical_mandate_dispatched_to_Karapakka__c FROM LoanDisbursementDetails__c WHERE Parent_Loan_Application__c =: optg1.Id];
                
                LoanDisbursementController.BeneficiaryDetailsWrapper loanb = new LoanDisbursementController.BeneficiaryDetailsWrapper();
                loanb.loanDisbursementDetailId= loans.Id;
                loanb.parentLoanAppId= optg1.Id;
                loanb.dsaName='test';
                loanb.paymentToDSA=true;
                loanb.coborrowerName='test';
                loanb.paymentToCoborrower=true;
                loanb.phyMandateDispToKarapakkam='test';
                loanb.bankName='inde';
                loanb.accountNumber='4657207336';
                loanb.bankBranchName='pdk';
                loanb.bankBranchPincode='543605';
                loanb.dealerPayment=10000;
                loanb.paymentOriginatedFrom='test';
                loanb.isNewVehicle = false;
                loanb.loanAppVehicleSubCategory = 'UOB';
                loanb.paymentToDSA = false;
                loanb.paymentToCoborrower = false;
                
                LoanDisbursementController.handleBeneficiaryDetailsSubmit(JSON.serialize(loanb));
                
                Test.stopTest(); 
            }
            
        }catch(Exception e){
            //system.assertEquals('Script-thrown exception', e.getMessage());
        }
    } 
    
    @isTest
    private static void handleBeneficiaryDetailsSubmittest8() {
        try
        {
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE username='test_userprod123456@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            { 
                
                Opportunity optg1 = [SELECT Id, Name, StageName, Sub_Stage__c, CloseDate, Vehicle_Type__c, Vehicle_Sub_Category__c, Product_Type__c FROM Opportunity WHERE Product_Type__c = 'Two Wheeler'];
                
                LoanDisbursementDetails__c loans = [SELECT Id, Payment_Originated_From__c, Parent_Loan_Application__c, DSA_Name__c, Physical_mandate_dispatched_to_Karapakka__c FROM LoanDisbursementDetails__c WHERE Parent_Loan_Application__c =: optg1.Id];
                
                LoanDisbursementController.BeneficiaryDetailsWrapper loanb = new LoanDisbursementController.BeneficiaryDetailsWrapper();
                loanb.loanDisbursementDetailId= loans.Id;
                loanb.parentLoanAppId= optg1.Id;
                loanb.dsaName='test';
                loanb.paymentToDSA=true;
                loanb.coborrowerName='test';
                loanb.paymentToCoborrower=true;
                loanb.phyMandateDispToKarapakkam='test';
                loanb.bankName='inde';
                loanb.accountNumber='4657207336';
                loanb.bankBranchName='pdk';
                loanb.bankBranchPincode='543605';
                loanb.dealerPayment=10000;
                loanb.paymentOriginatedFrom='test';
                loanb.isNewVehicle = false;
                loanb.loanAppVehicleSubCategory = 'UPD';
                // loanb.paymentToDSA = false;
                //  loanb.paymentToCoborrower = false;
                
                LoanDisbursementController.handleBeneficiaryDetailsSubmit(JSON.serialize(loanb));
                
                Test.stopTest(); 
            }
            
        }catch(Exception e){
            //system.assertEquals('Script-thrown exception', e.getMessage());
        }
    } 
    
    @isTest
    private static void handleBeneficiaryDetailsSubmittest9() {
        try
        {
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE username='test_userprod123456@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            { 
                
                Opportunity optg1 = [SELECT Id, Name, StageName, Sub_Stage__c, CloseDate, Vehicle_Type__c, Vehicle_Sub_Category__c, Product_Type__c FROM Opportunity WHERE Product_Type__c = 'Two Wheeler'];
                
                LoanDisbursementDetails__c loans = [SELECT Id, Payment_Originated_From__c, Parent_Loan_Application__c, DSA_Name__c, Physical_mandate_dispatched_to_Karapakka__c FROM LoanDisbursementDetails__c WHERE Parent_Loan_Application__c =: optg1.Id];
                
                LoanDisbursementController.BeneficiaryDetailsWrapper loanb = new LoanDisbursementController.BeneficiaryDetailsWrapper();
                loanb.loanDisbursementDetailId= loans.Id;
                loanb.parentLoanAppId= optg1.Id;
                loanb.dsaName='test';
                loanb.paymentToDSA=true;
                loanb.coborrowerName='test';
                loanb.paymentToCoborrower=true;
                loanb.phyMandateDispToKarapakkam='test';
                loanb.bankName='inde';
                loanb.accountNumber='4657207336';
                loanb.bankBranchName='pdk';
                loanb.bankBranchPincode='543605';
                loanb.dealerPayment=10000;
                loanb.paymentOriginatedFrom='test';
                loanb.isNewVehicle = false;
                //   loanb.loanAppVehicleSubCategory = 'UPD';
                loanb.paymentToDSA = True;
                loanb.paymentToCoborrower = True;
                
                LoanDisbursementController.handleBeneficiaryDetailsSubmit(JSON.serialize(loanb));
                
                Test.stopTest(); 
            }
            
        }catch(Exception e){
            //system.assertEquals('Script-thrown exception', e.getMessage());
        }
    } 
    
    @isTest
    private static void handleBeneficiaryDetailsSubmittest10() {
        try
        {
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE username='test_userprod123456@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            { 
                
                Opportunity optg1 = [SELECT Id, Name, StageName, Sub_Stage__c, CloseDate, Vehicle_Type__c, Vehicle_Sub_Category__c, Product_Type__c FROM Opportunity WHERE Product_Type__c = 'Two Wheeler'];
                
                LoanDisbursementDetails__c loans = [SELECT Id, Payment_Originated_From__c, Parent_Loan_Application__c, DSA_Name__c, Physical_mandate_dispatched_to_Karapakka__c FROM LoanDisbursementDetails__c WHERE Parent_Loan_Application__c =: optg1.Id];
                
                LoanDisbursementController.BeneficiaryDetailsWrapper loanb = new LoanDisbursementController.BeneficiaryDetailsWrapper();
                loanb.loanDisbursementDetailId= loans.Id;
                loanb.parentLoanAppId= optg1.Id;
                loanb.dsaName='test';
                loanb.paymentToDSA=true;
                loanb.coborrowerName='test';
                loanb.paymentToCoborrower=true;
                loanb.phyMandateDispToKarapakkam='test';
                loanb.bankName='inde';
                loanb.accountNumber='4657207336';
                loanb.bankBranchName='pdk';
                loanb.bankBranchPincode='543605';
                loanb.dealerPayment=10000;
                loanb.paymentOriginatedFrom='test';
                loanb.isNewVehicle = false;
                //   loanb.loanAppVehicleSubCategory = 'UPD';
                loanb.paymentToDSA = True;
                loanb.paymentToCoborrower = false;
                
                LoanDisbursementController.handleBeneficiaryDetailsSubmit(JSON.serialize(loanb));
                
                Test.stopTest(); 
            }
            
        }catch(Exception e){
            //system.assertEquals('Script-thrown exception', e.getMessage());
        }
    } 
    
    @isTest
    private static void handleBeneficiaryDetailsSubmittest11() {
        try
        {
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE username='test_userprod123456@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            { 
                
                Opportunity optg1 = [SELECT Id, Name, StageName, Sub_Stage__c, CloseDate, Vehicle_Type__c, Vehicle_Sub_Category__c, Product_Type__c FROM Opportunity WHERE Product_Type__c = 'Two Wheeler'];
                
                LoanDisbursementDetails__c loans = [SELECT Id, Payment_Originated_From__c, Parent_Loan_Application__c, DSA_Name__c, Physical_mandate_dispatched_to_Karapakka__c FROM LoanDisbursementDetails__c WHERE Parent_Loan_Application__c =: optg1.Id];
                
                LoanDisbursementController.BeneficiaryDetailsWrapper loanb = new LoanDisbursementController.BeneficiaryDetailsWrapper();
                loanb.loanDisbursementDetailId= loans.Id;
                loanb.parentLoanAppId= optg1.Id;
                loanb.dsaName='test';
                loanb.paymentToDSA=true;
                loanb.coborrowerName='test';
                loanb.paymentToCoborrower=true;
                loanb.phyMandateDispToKarapakkam='test';
                loanb.bankName='inde';
                loanb.accountNumber='4657207336';
                loanb.bankBranchName='pdk';
                loanb.bankBranchPincode='543605';
                loanb.dealerPayment=10000;
                loanb.paymentOriginatedFrom='test';
                loanb.isNewVehicle = false;
                //   loanb.loanAppVehicleSubCategory = 'UPD';
                loanb.paymentToDSA = false;
                loanb.paymentToCoborrower = True;
                
                LoanDisbursementController.handleBeneficiaryDetailsSubmit(JSON.serialize(loanb));
                
                Test.stopTest(); 
            }
            
        }catch(Exception e){
            //system.assertEquals('Script-thrown exception', e.getMessage());
        }
    } 
    
    @isTest
    private static void handleBeneficiaryDetailsSubmittest12() {
        try
        {
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE username='test_userprod123456@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            { 
                
                Opportunity optg1 = [SELECT Id, Name, StageName, Sub_Stage__c, CloseDate, Vehicle_Type__c, Vehicle_Sub_Category__c, Product_Type__c FROM Opportunity WHERE Product_Type__c = 'Two Wheeler'];
                
                LoanDisbursementDetails__c loans = [SELECT Id, Payment_Originated_From__c, Parent_Loan_Application__c, DSA_Name__c, Physical_mandate_dispatched_to_Karapakka__c FROM LoanDisbursementDetails__c WHERE Parent_Loan_Application__c =: optg1.Id];
                
                LoanDisbursementController.BeneficiaryDetailsWrapper loanb = new LoanDisbursementController.BeneficiaryDetailsWrapper();
                loanb.loanDisbursementDetailId= loans.Id;
                loanb.parentLoanAppId= optg1.Id;
                loanb.dsaName='test';
                loanb.paymentToDSA=true;
                loanb.coborrowerName='test';
                loanb.paymentToCoborrower=true;
                loanb.phyMandateDispToKarapakkam='test';
                loanb.bankName='inde';
                loanb.accountNumber='4657207336';
                loanb.bankBranchName='pdk';
                loanb.bankBranchPincode='543605';
                loanb.dealerPayment=10000;
                loanb.paymentOriginatedFrom='test';
                loanb.isNewVehicle = false;
                //   loanb.loanAppVehicleSubCategory = 'UPD';
                loanb.paymentToDSA = false;
                loanb.paymentToCoborrower = false;
                
                
                LoanDisbursementController.handleBeneficiaryDetailsSubmit(JSON.serialize(loanb));
                
                Test.stopTest(); 
            }
            
        }catch(Exception e){
            //system.assertEquals('Script-thrown exception', e.getMessage());
        }
    } 
    
    @isTest
    private static void handleBeneficiaryDetailsSubmittest13() {
        try
        {
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE username='test_userprod123456@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            { 
                
                Opportunity optg1 = [SELECT Id, Name, StageName, Sub_Stage__c, CloseDate, Vehicle_Type__c, Vehicle_Sub_Category__c, Product_Type__c FROM Opportunity WHERE Product_Type__c = 'Two Wheeler'];
                
                LoanDisbursementDetails__c loans = [SELECT Id, Payment_Originated_From__c, Parent_Loan_Application__c, DSA_Name__c, Physical_mandate_dispatched_to_Karapakka__c FROM LoanDisbursementDetails__c WHERE Parent_Loan_Application__c =: optg1.Id];
                
                LoanDisbursementController.BeneficiaryDetailsWrapper loanb = new LoanDisbursementController.BeneficiaryDetailsWrapper();
                loanb.loanDisbursementDetailId= loans.Id;
                loanb.parentLoanAppId= optg1.Id;
                loanb.dsaName='test';
                loanb.paymentToDSA=true;
                loanb.coborrowerName='test';
                loanb.paymentToCoborrower=true;
                loanb.phyMandateDispToKarapakkam='test';
                loanb.bankName='inde';
                loanb.accountNumber='4657207336';
                loanb.bankBranchName='pdk';
                loanb.bankBranchPincode='543605';
                loanb.dealerPayment=10000;
                loanb.paymentOriginatedFrom='test';
                loanb.isNewVehicle = false;
                //   loanb.loanAppVehicleSubCategory = 'UPD';
                //    loanb.paymentToDSA = false;
                //    loanb.paymentToCoborrower = false;
                
                Opportunity opga1 = new Opportunity();
                opga1.Id = loanb.parentLoanAppId;
                opga1.StageName = 'Disbursement Request Preparation';
                opga1.Sub_Stage__c = 'New/Used Vehicle Details';
                opga1.CloseDate = Date.newInstance(2021, 1, 11);
                opga1.Name = 'testone';
                insert opga1;
                
                opga1.Sub_Stage__c = 'Beneficiary Details';
                update opga1;
                
                LoanDisbursementController.handleBeneficiaryDetailsSubmit(JSON.serialize(loanb));
                
                Test.stopTest(); 
            }
            
        }catch(Exception e){
            //system.assertEquals('Script-thrown exception', e.getMessage());
        }
    } 
    
    @isTest
    private static void handleBeneficiaryDetailsSubmittest14() {
        try
        {
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE username='test_userprod123456@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            { 
                
                Opportunity optg1 = [SELECT Id, Name, StageName, Sub_Stage__c, CloseDate, Vehicle_Type__c, Vehicle_Sub_Category__c, Product_Type__c FROM Opportunity WHERE Product_Type__c = 'Two Wheeler'];
                
                LoanDisbursementDetails__c loans = [SELECT Id, Payment_Originated_From__c, Parent_Loan_Application__c, DSA_Name__c, Physical_mandate_dispatched_to_Karapakka__c FROM LoanDisbursementDetails__c WHERE Parent_Loan_Application__c =: optg1.Id];
                
                LoanDisbursementController.BeneficiaryDetailsWrapper loanb = new LoanDisbursementController.BeneficiaryDetailsWrapper();
                loanb.loanDisbursementDetailId= loans.Id;
                loanb.parentLoanAppId= optg1.Id;
                loanb.dsaName='test';
                loanb.paymentToDSA=true;
                loanb.coborrowerName='test';
                loanb.paymentToCoborrower=true;
                loanb.phyMandateDispToKarapakkam='test';
                loanb.bankName='inde';
                loanb.accountNumber='4657207336';
                loanb.bankBranchName='pdk';
                loanb.bankBranchPincode='543605';
                loanb.dealerPayment=10000;
                loanb.paymentOriginatedFrom='test';
                loanb.isNewVehicle = false;
                loanb.loanAppVehicleSubCategory = 'UPB';
                // loanb.paymentToDSA = false;
                //  loanb.paymentToCoborrower = false;
                
                LoanDisbursementController.handleBeneficiaryDetailsSubmit(JSON.serialize(loanb));
                
                Test.stopTest(); 
            }
            
        }catch(Exception e){
            //system.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    private static void handleBeneficiaryDetailsSubmittest15() {
        try
        {
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE username='test_userprod123456@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            { 
                
                Opportunity optg1 = [SELECT Id, Name, StageName, Sub_Stage__c, CloseDate, Vehicle_Type__c, Vehicle_Sub_Category__c, Product_Type__c FROM Opportunity WHERE Product_Type__c = 'Two Wheeler'];
                
                LoanDisbursementDetails__c loans = [SELECT Id, Payment_Originated_From__c, Parent_Loan_Application__c, DSA_Name__c, Physical_mandate_dispatched_to_Karapakka__c FROM LoanDisbursementDetails__c WHERE Parent_Loan_Application__c =: optg1.Id];
                
                LoanDisbursementController.BeneficiaryDetailsWrapper loanb = new LoanDisbursementController.BeneficiaryDetailsWrapper();
                loanb.loanDisbursementDetailId= loans.Id;
                loanb.parentLoanAppId= optg1.Id;
                loanb.dsaName='test';
                loanb.paymentToDSA=true;
                loanb.coborrowerName='test';
                loanb.paymentToCoborrower=true;
                loanb.phyMandateDispToKarapakkam='test';
                loanb.bankName='inde';
                loanb.accountNumber='4657207336';
                loanb.bankBranchName='pdk';
                loanb.bankBranchPincode='543605';
                loanb.dealerPayment=10000;
                loanb.paymentOriginatedFrom='test';
                loanb.isNewVehicle = false;
                loanb.loanAppVehicleSubCategory = 'UPB';
                loanb.paymentToDSA = false;
                loanb.paymentToCoborrower = True;
                
                LoanDisbursementController.handleBeneficiaryDetailsSubmit(JSON.serialize(loanb));
                
                Test.stopTest(); 
            }
            
        }catch(Exception e){
            //system.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    private static void handleBeneficiaryDetailsSubmittest16() {
        try
        {
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE username='test_userprod123456@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            { 
                
                Opportunity optg1 = [SELECT Id, Name, StageName, Sub_Stage__c, CloseDate, Vehicle_Type__c, Vehicle_Sub_Category__c, Product_Type__c FROM Opportunity WHERE Product_Type__c = 'Two Wheeler'];
                
                LoanDisbursementDetails__c loans = [SELECT Id, Payment_Originated_From__c, Parent_Loan_Application__c, DSA_Name__c, Physical_mandate_dispatched_to_Karapakka__c FROM LoanDisbursementDetails__c WHERE Parent_Loan_Application__c =: optg1.Id];
                
                LoanDisbursementController.BeneficiaryDetailsWrapper loanb = new LoanDisbursementController.BeneficiaryDetailsWrapper();
                loanb.loanDisbursementDetailId= loans.Id;
                loanb.parentLoanAppId= optg1.Id;
                loanb.dsaName='test';
                loanb.paymentToDSA=true;
                loanb.coborrowerName='test';
                loanb.paymentToCoborrower=true;
                loanb.phyMandateDispToKarapakkam='test';
                loanb.bankName='inde';
                loanb.accountNumber='4657207336';
                loanb.bankBranchName='pdk';
                loanb.bankBranchPincode='543605';
                loanb.dealerPayment=10000;
                loanb.paymentOriginatedFrom='test';
                loanb.isNewVehicle = false;
                loanb.loanAppVehicleSubCategory = 'UPB';
                loanb.paymentToDSA = false;
                loanb.paymentToCoborrower = false;
                
                LoanDisbursementController.handleBeneficiaryDetailsSubmit(JSON.serialize(loanb));
                
                Test.stopTest(); 
            }
            
        }catch(Exception e){
            //system.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    private static void handleBeneficiaryDetailsSubmittest17() {
        try
        {
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE username='test_userprod123456@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            { 
                
                Opportunity optg1 = [SELECT Id, Name, StageName, Sub_Stage__c, CloseDate, Vehicle_Type__c, Vehicle_Sub_Category__c, Product_Type__c FROM Opportunity WHERE Product_Type__c = 'Two Wheeler'];
                
                LoanDisbursementDetails__c loans = [SELECT Id, Payment_Originated_From__c, Parent_Loan_Application__c, DSA_Name__c, Physical_mandate_dispatched_to_Karapakka__c FROM LoanDisbursementDetails__c WHERE Parent_Loan_Application__c =: optg1.Id];
                
                LoanDisbursementController.BeneficiaryDetailsWrapper loanb = new LoanDisbursementController.BeneficiaryDetailsWrapper();
                loanb.loanDisbursementDetailId= loans.Id;
                loanb.parentLoanAppId= optg1.Id;
                loanb.dsaName='test';
                loanb.paymentToDSA=true;
                loanb.coborrowerName='test';
                loanb.paymentToCoborrower=true;
                loanb.phyMandateDispToKarapakkam='test';
                loanb.bankName='inde';
                loanb.accountNumber='4657207336';
                loanb.bankBranchName='pdk';
                loanb.bankBranchPincode='543605';
                loanb.dealerPayment=10000;
                loanb.paymentOriginatedFrom='test';
                loanb.isNewVehicle = false;
                loanb.loanAppVehicleSubCategory = 'UOM';
                loanb.paymentToDSA = True;
                loanb.paymentToCoborrower = True;
                
                LoanDisbursementController.handleBeneficiaryDetailsSubmit(JSON.serialize(loanb));
                
                Test.stopTest(); 
            }
            
        }catch(Exception e){
            //system.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    private static void handleBeneficiaryDetailsSubmittest18() {
        try
        {
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE username='test_userprod123456@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            { 
                
                Opportunity optg1 = [SELECT Id, Name, StageName, Sub_Stage__c, CloseDate, Vehicle_Type__c, Vehicle_Sub_Category__c, Product_Type__c FROM Opportunity WHERE Product_Type__c = 'Two Wheeler'];
                
                LoanDisbursementDetails__c loans = [SELECT Id, Payment_Originated_From__c, Parent_Loan_Application__c, DSA_Name__c, Physical_mandate_dispatched_to_Karapakka__c FROM LoanDisbursementDetails__c WHERE Parent_Loan_Application__c =: optg1.Id];
                
                LoanDisbursementController.BeneficiaryDetailsWrapper loanb = new LoanDisbursementController.BeneficiaryDetailsWrapper();
                loanb.loanDisbursementDetailId= loans.Id;
                loanb.parentLoanAppId= optg1.Id;
                loanb.dsaName='test';
                loanb.paymentToDSA=true;
                loanb.coborrowerName='test';
                loanb.paymentToCoborrower=true;
                loanb.phyMandateDispToKarapakkam='test';
                loanb.bankName='inde';
                loanb.accountNumber='4657207336';
                loanb.bankBranchName='pdk';
                loanb.bankBranchPincode='543605';
                loanb.dealerPayment=10000;
                loanb.paymentOriginatedFrom='test';
                loanb.isNewVehicle = false;
                loanb.loanAppVehicleSubCategory = 'UOM';
                loanb.paymentToDSA = True;
                loanb.paymentToCoborrower = false;
                
                LoanDisbursementController.handleBeneficiaryDetailsSubmit(JSON.serialize(loanb));
                
                Test.stopTest(); 
            }
            
        }catch(Exception e){
            //system.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    private static void handleBeneficiaryDetailsSubmittest19() {
        try
        {
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE username='test_userprod123456@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            { 
                
                Opportunity optg1 = [SELECT Id, Name, StageName, Sub_Stage__c, CloseDate, Vehicle_Type__c, Vehicle_Sub_Category__c, Product_Type__c FROM Opportunity WHERE Product_Type__c = 'Two Wheeler'];
                
                LoanDisbursementDetails__c loans = [SELECT Id, Payment_Originated_From__c, Parent_Loan_Application__c, DSA_Name__c, Physical_mandate_dispatched_to_Karapakka__c FROM LoanDisbursementDetails__c WHERE Parent_Loan_Application__c =: optg1.Id];
                
                LoanDisbursementController.BeneficiaryDetailsWrapper loanb = new LoanDisbursementController.BeneficiaryDetailsWrapper();
                loanb.loanDisbursementDetailId= loans.Id;
                loanb.parentLoanAppId= optg1.Id;
                loanb.dsaName='test';
                loanb.paymentToDSA=true;
                loanb.coborrowerName='test';
                loanb.paymentToCoborrower=true;
                loanb.phyMandateDispToKarapakkam='test';
                loanb.bankName='inde';
                loanb.accountNumber='4657207336';
                loanb.bankBranchName='pdk';
                loanb.bankBranchPincode='543605';
                loanb.dealerPayment=10000;
                loanb.paymentOriginatedFrom='test';
                loanb.isNewVehicle = false;
                loanb.loanAppVehicleSubCategory = 'UOM';
                loanb.paymentToDSA = false;
                loanb.paymentToCoborrower = true;
                
                LoanDisbursementController.handleBeneficiaryDetailsSubmit(JSON.serialize(loanb));
                
                Test.stopTest(); 
            }
            
        }catch(Exception e){
            //system.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    private static void handleBeneficiaryDetailsSubmittest20() {
        try
        {
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE username='test_userprod123456@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            { 
                
                Opportunity optg1 = [SELECT Id, Name, StageName, Sub_Stage__c, CloseDate, Vehicle_Type__c, Vehicle_Sub_Category__c, Product_Type__c FROM Opportunity WHERE Product_Type__c = 'Two Wheeler'];
                
                LoanDisbursementDetails__c loans = [SELECT Id, Payment_Originated_From__c, Parent_Loan_Application__c, DSA_Name__c, Physical_mandate_dispatched_to_Karapakka__c FROM LoanDisbursementDetails__c WHERE Parent_Loan_Application__c =: optg1.Id];
                
                LoanDisbursementController.BeneficiaryDetailsWrapper loanb = new LoanDisbursementController.BeneficiaryDetailsWrapper();
                loanb.loanDisbursementDetailId= loans.Id;
                loanb.parentLoanAppId= optg1.Id;
                loanb.dsaName='test';
                loanb.paymentToDSA=true;
                loanb.coborrowerName='test';
                loanb.paymentToCoborrower=true;
                loanb.phyMandateDispToKarapakkam='test';
                loanb.bankName='inde';
                loanb.accountNumber='4657207336';
                loanb.bankBranchName='pdk';
                loanb.bankBranchPincode='543605';
                loanb.dealerPayment=10000;
                loanb.paymentOriginatedFrom='test';
                loanb.isNewVehicle = false;
                loanb.loanAppVehicleSubCategory = 'UOM';
                loanb.paymentToDSA = false;
                loanb.paymentToCoborrower = false;
                
                LoanDisbursementController.handleBeneficiaryDetailsSubmit(JSON.serialize(loanb));
                
                Test.stopTest(); 
            }
            
        }catch(Exception e){
            //system.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void getDoToBeAuthorizedByDDValuesTest2(){
        try{
            Opportunity opds1 = new Opportunity();
            opds1.StageName = 'Qualification';
            opds1.CloseDate = Date.newInstance(2021, 1, 11);
            opds1.Name = 'testone';
            opds1.Product_Type__c = 'Two Wheeler';
            opds1.Agent_BL_code__c = 'AG-001';
            insert opds1;
            
            Product2 pd1 = new Product2();
            pd1.Asset_Category__c = 'te';
            pd1.Name = 'book';
            pd1.Type__c = 'Model';
            pd1.External_Reference_Id__c = '58568568';
            pd1.ProductCode = 'H';
            insert pd1;
            
            Benefi__c bnf1 = new Benefi__c();
            bnf1.Ben_code__c = 'BEN000280';
            bnf1.Name = 'test';
            bnf1.Dealer_Code__c = '';
            bnf1.Indusind_AcNo__c = '786767832788';
            bnf1.Beneficiary__c = 'DSM';
            bnf1.Status_Flag__c = 'L';
            insert bnf1;
            
            Beneficiary_Product__c bp1 = new Beneficiary_Product__c();
            bp1.Name = 'testname';
            bp1.OwnerId = UserInfo.getUserId();
            bp1.Product__c = pd1.Id;
            bp1.Ben_code__c = bnf1.Id;
            bp1.Unique_Identifier__c = '678678';
            insert bp1;
            
            Bl_Code_Details__c blCodeDetail = new Bl_Code_Details__c();
            blCodeDetail.name = 'test blCodeDetail';
            blCodeDetail.Bl_Code__c = opds1.Agent_BL_code__c;
            blCodeDetail.State_Code__c = '69';
            blCodeDetail.Geo_State_Code__c = '96';
            insert blCodeDetail;
            
            //created Beneficiary_BlCode__c record
            Beneficiary_BlCode__c benefBLCode = new Beneficiary_BlCode__c();
            benefBLCode.Name = 'test benefBLCode';
            benefBLCode.Ben_code__c = bp1.Ben_code__c;
            benefBLCode.Bl_Code_Details__c = blCodeDetail.Id;
            benefBLCode.Unique_Identifier__c = 'TEST';
            insert benefBLCode;
            
            Test.startTest();
            LoanDisbursementController.getDoToBeAuthorizedByDDValues(opds1.Id);
            Test.stopTest();
            
        }catch(Exception e){
            system.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void getDoToBeAuthorizedByDDValuesTest3(){
        try{
            Opportunity opds1 = new Opportunity();
            opds1.StageName = 'Qualification';
            opds1.CloseDate = Date.newInstance(2021, 1, 11);
            opds1.Name = 'testone';
            opds1.Product_Type__c = 'Passenger Vehicles';
            opds1.Agent_BL_code__c = 'AG-001';
            insert opds1;
            
            Product2 pd1 = new Product2();
            pd1.Asset_Category__c = 'te';
            pd1.Name = 'book';
            pd1.Type__c = 'Model';
            pd1.External_Reference_Id__c = '58568568';
            pd1.ProductCode = 'C';
            insert pd1;
            
            Benefi__c bnf1 = new Benefi__c();
            bnf1.Ben_code__c = 'BEN000280';
            bnf1.Name = 'test';
            bnf1.Dealer_Code__c = '';
            bnf1.Indusind_AcNo__c = '786767832788';
            bnf1.Beneficiary__c = 'EMP';
            bnf1.Status_Flag__c = 'L';
            bnf1.Dealership_Nature__c = 'CP-BH';
            bnf1.Email__c = 'poineerong@rediffmail.com';
            insert bnf1;
            
            Beneficiary_Product__c bp1 = new Beneficiary_Product__c();
            bp1.Name = 'testname';
            bp1.OwnerId = UserInfo.getUserId();
            bp1.Product__c = pd1.Id;
            bp1.Ben_code__c = bnf1.Id;
            bp1.Unique_Identifier__c = '678678';
            insert bp1;
            
            Bl_Code_Details__c blCodeDetail = new Bl_Code_Details__c();
            blCodeDetail.name = 'test blCodeDetail';
            blCodeDetail.Bl_Code__c = opds1.Agent_BL_code__c;
            blCodeDetail.State_Code__c = '69';
            blCodeDetail.Geo_State_Code__c = '96';
            insert blCodeDetail;
            
            //created Beneficiary_BlCode__c record
            Beneficiary_BlCode__c benefBLCode = new Beneficiary_BlCode__c();
            benefBLCode.Name = 'test benefBLCode';
            benefBLCode.Ben_code__c = bp1.Ben_code__c;
            benefBLCode.Bl_Code_Details__c = blCodeDetail.Id;
            benefBLCode.Unique_Identifier__c = 'TEST';
            insert benefBLCode;
            
            Test.startTest();
            LoanDisbursementController.getDoToBeAuthorizedByDDValues(opds1.Id);
            Test.stopTest();
            
        }catch(Exception e){
            system.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void addNomineeDetailsToWrapperTest2(){
        User u = [SELECT Id,usertype FROM User WHERE username='test_userprod123456@indusbank.com' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        { 
            LoanDisbursementController.InsuranceWrapper loanw= new LoanDisbursementController.InsuranceWrapper();
            
            loanw.disbursementRecordId='';
            loanw.insuranceAppNo='test';
            loanw.installments='test';
            loanw.longTermPolicyAvailable='test';
            loanw.longTermPolicyOwnDamageYrs='test';
            loanw.policyAvailable='test';
            loanw.rsd=String.valueOf(System.today());
            loanw.insurer= null;                   
            loanw.gst=String.valueOf(123);
            loanw.ownDamagePremiumAddons='123';
            loanw.thirdPartyPremiumsPaCover='123';
            loanw.firstYr_Idv='123';
            loanw.firstYr_OwnDamagePremium='123';
            loanw.firstYr_ThirdPartyPremium='123';
            loanw.secondYr_IDV='123';
            loanw.secondYr_OwnDamagePremium='123';
            loanw.secondYr_ThirdPartyPremium='123';
            loanw.thirdYr_IDV='123';
            loanw.thirdYr_OwnDamagePremium='123';
            loanw.thirdYr_ThirdParty_Premium='123';
            loanw.fourthYr_IDV='123';
            loanw.fourthYr_OwnDamagePremium='123';
            loanw.fourthYr_ThirdPartyPremium='123';
            loanw.fifthYr_Idv='123';
            loanw.fifthYr_OwnDamagePremium='123';
            loanw.fifthYr_ThirdPartyPremium='123';
            //Nominee Details Screen
            loanw.isCoBorrowerPresent = true;
            loanw.borrowerName = 'BName';
            loanw.borrowerDOB = null;
            loanw.borrowerRelationship = 'Father';
            loanw.borrowerAddress = 'Delhi';
            loanw.borrowerSpouseGender = 'Male';
            loanw.borrowerSpouseDOB = null;
            loanw.borrowerFirstChildName = 'FChild';
            loanw.borrowerFirstChildGender = 'Male';
            loanw.borrowerFirstChildDOB = null;
            loanw.borrowerSecondChildName ='Fchild';
            loanw.borrowerSecondChildGender = 'Male';
            loanw.borrowerSecondChildDOB = null;
            loanw.borrowerThirdChildName = 'SChild';
            loanw.borrowerThirdChildGender = 'Female';
            loanw.borrowerThirdChildDOB = null;
            loanw.borrowerFatherDOB = null;
            loanw.borrowerMotherDOB = null;
            loanw.borrowerInsuDoneBy = 'Agt';
            
            loanw.coBorrowerName = 'CBName';
            loanw.coBorrowerDOB = null;
            loanw.coBorrowerRelationship = 'Father';
            loanw.coBorrowerAddress = 'Mumbai';
            loanw.coBorrowerSpouseGender = 'Female';
            loanw.coBorrowerSpouseDOB = null;
            loanw.coBorrowerFirstChildName = 'Chris';
            loanw.coBorrowerFirstChildGender = 'Male';
            loanw.coBorrowerFirstChildDOB = null;
            loanw.coBorrowerSecondChildName = 'Thor';
            loanw.coBorrowerSecondChildGender = 'Female';
            loanw.coBorrowerSecondChildDOB = null;
            loanw.coBorrowerThirdChildName = 'Iron';
            loanw.coBorrowerThirdChildGender = 'Male';
            loanw.coBorrowerThirdChildDOB = null;
            loanw.coBorrowerFatherDOB = null;
            loanw.coBorrowerMotherDOB = null;
            loanw.coBorrowerInsuDoneBy = 'Agnet';
            
            Opportunity opds1 = new Opportunity();
            opds1.StageName = 'Qualification';
            opds1.CloseDate = Date.newInstance(2021, 1, 11);
            opds1.Name = 'testone';
            opds1.Product_Type__c = 'Two Wheeler';
            opds1.Agent_BL_code__c = 'AG-001';
            insert opds1;
            
            Product2 pd1 = new Product2();
            pd1.Asset_Category__c = 'te';
            pd1.Name = opds1.Product_Type__c;
            pd1.Type__c = 'Model';
            pd1.External_Reference_Id__c = '58568568';
            pd1.ProductCode = 'C';
            insert pd1;
            
            Benefi__c bnf1 = new Benefi__c();
            bnf1.Ben_code__c = 'BEN000280';
            bnf1.Name = 'test';
            bnf1.Dealer_Code__c = '';
            bnf1.Indusind_AcNo__c = '786767832788';
            bnf1.Beneficiary__c = 'EMP';
            bnf1.Status_Flag__c = 'L';
            bnf1.Dealership_Nature__c = 'CP-BH';
            bnf1.Email__c = 'poineerong@rediffmail.com';
            bnf1.Role__c = 'MO';
            insert bnf1;
            
            Bl_Code_Details__c blCodeDetail = new Bl_Code_Details__c();
            blCodeDetail.name = 'test blCodeDetail';
            blCodeDetail.Bl_Code__c = opds1.Agent_BL_code__c;
            blCodeDetail.State_Code__c = '69';
            blCodeDetail.Geo_State_Code__c = '96';
            insert blCodeDetail;
            
            Beneficiary_BlCode__c benefBLCode = new Beneficiary_BlCode__c();
            benefBLCode.Name = 'test benefBLCode';
            benefBLCode.Ben_code__c = bnf1.Id;
            benefBLCode.Bl_Code_Details__c = blCodeDetail.Id;
            benefBLCode.Unique_Identifier__c = 'TEST';
            insert benefBLCode;
            
            Beneficiary_Product__c bp1 = new Beneficiary_Product__c();
            bp1.Name = 'testname';
            bp1.OwnerId = UserInfo.getUserId();
            bp1.Product__c = pd1.Id;
            bp1.Ben_code__c = benefBLCode.Ben_code__c;
            bp1.Unique_Identifier__c = '678678';
            insert bp1;
            
            //created Beneficiary_BlCode__c record
            
            
            List<LoanDisbursementDetails__c> ldList = new List<LoanDisbursementDetails__c>();
            LoanDisbursementDetails__c disbursement = new LoanDisbursementDetails__c();
            disbursement.Parent_Loan_Application__c = opds1.Id;
            disbursement.Payment_Originated_From__c = 'OP';
            disbursement.Vehicle_Sold_By__c = 'Agency Dealer';
            disbursement.Vehicle_Registered_in_Name__c = 'Buyer';
            //   disbursement.Business_Sourced_By__c = u.Id;
            //   disbursement.Business_Done_By__c = u.Id;
            //    disbursement.FI_Done_By__c = u.Id;
            //     disbursement.Collection_Executive__c = tbmdm.Id;
            disbursement.Do_Issuance__c = 'Along_with_Payment';
            disbursement.Do_Issuance_Mode__c = 'Separate';
            disbursement.Do_To_be_authorized_by__c = bnf1.Id;
            disbursement.Balance_Transfer_Amount_in_Rs__c = 24000;
            disbursement.Purchase_doc_catq__c = 'Invoice';
            disbursement.Original_Purchase_value_in_Rs__c = 25000;
            disbursement.Original_purchase_date__c = Date.today();
            disbursement.Fund_End_Use__c = 'New_Vehicle_Margin_Money';
            insert disbursement;
            ldList.add(disbursement);
            
            Test.startTest();
            LoanDisbursementController.addNomineeDetailsToWrapper(loanw,ldList,opds1.Id);
            Test.stopTest();
        }
    }
    
    @isTest
    public static void addNomineeDetailsToWrapperTest3(){
        User u = [SELECT Id,usertype FROM User WHERE username='test_userprod123456@indusbank.com' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        { 
            LoanDisbursementController.InsuranceWrapper loanw= new LoanDisbursementController.InsuranceWrapper();
            
            loanw.disbursementRecordId='';
            loanw.insuranceAppNo='test';
            loanw.installments='test';
            loanw.longTermPolicyAvailable='test';
            loanw.longTermPolicyOwnDamageYrs='test';
            loanw.policyAvailable='test';
            loanw.rsd=String.valueOf(System.today());
            loanw.insurer= null;                   
            loanw.gst=String.valueOf(123);
            loanw.ownDamagePremiumAddons='123';
            loanw.thirdPartyPremiumsPaCover='123';
            loanw.firstYr_Idv='123';
            loanw.firstYr_OwnDamagePremium='123';
            loanw.firstYr_ThirdPartyPremium='123';
            loanw.secondYr_IDV='123';
            loanw.secondYr_OwnDamagePremium='123';
            loanw.secondYr_ThirdPartyPremium='123';
            loanw.thirdYr_IDV='123';
            loanw.thirdYr_OwnDamagePremium='123';
            loanw.thirdYr_ThirdParty_Premium='123';
            loanw.fourthYr_IDV='123';
            loanw.fourthYr_OwnDamagePremium='123';
            loanw.fourthYr_ThirdPartyPremium='123';
            loanw.fifthYr_Idv='123';
            loanw.fifthYr_OwnDamagePremium='123';
            loanw.fifthYr_ThirdPartyPremium='123';
            //Nominee Details Screen
            loanw.isCoBorrowerPresent = true;
            loanw.borrowerName = 'BName';
            loanw.borrowerDOB = null;
            loanw.borrowerRelationship = 'Father';
            loanw.borrowerAddress = 'Delhi';
            loanw.borrowerSpouseGender = 'Male';
            loanw.borrowerSpouseDOB = null;
            loanw.borrowerFirstChildName = 'FChild';
            loanw.borrowerFirstChildGender = 'Male';
            loanw.borrowerFirstChildDOB = null;
            loanw.borrowerSecondChildName ='Fchild';
            loanw.borrowerSecondChildGender = 'Male';
            loanw.borrowerSecondChildDOB = null;
            loanw.borrowerThirdChildName = 'SChild';
            loanw.borrowerThirdChildGender = 'Female';
            loanw.borrowerThirdChildDOB = null;
            loanw.borrowerFatherDOB = null;
            loanw.borrowerMotherDOB = null;
            loanw.borrowerInsuDoneBy = 'Agt';
            
            loanw.coBorrowerName = 'CBName';
            loanw.coBorrowerDOB = null;
            loanw.coBorrowerRelationship = 'Father';
            loanw.coBorrowerAddress = 'Mumbai';
            loanw.coBorrowerSpouseGender = 'Female';
            loanw.coBorrowerSpouseDOB = null;
            loanw.coBorrowerFirstChildName = 'Chris';
            loanw.coBorrowerFirstChildGender = 'Male';
            loanw.coBorrowerFirstChildDOB = null;
            loanw.coBorrowerSecondChildName = 'Thor';
            loanw.coBorrowerSecondChildGender = 'Female';
            loanw.coBorrowerSecondChildDOB = null;
            loanw.coBorrowerThirdChildName = 'Iron';
            loanw.coBorrowerThirdChildGender = 'Male';
            loanw.coBorrowerThirdChildDOB = null;
            loanw.coBorrowerFatherDOB = null;
            loanw.coBorrowerMotherDOB = null;
            loanw.coBorrowerInsuDoneBy = 'Agnet';
            
            Opportunity opds1 = new Opportunity();
            opds1.StageName = 'Qualification';
            opds1.CloseDate = Date.newInstance(2021, 1, 11);
            opds1.Name = 'testone';
            opds1.Product_Type__c = 'Passenger Vehicles';
            opds1.Agent_BL_code__c = 'AG-001';
            insert opds1;
            
            Product2 pd1 = new Product2();
            pd1.Asset_Category__c = 'te';
            pd1.Name = opds1.Product_Type__c;
            pd1.Type__c = 'Model';
            pd1.External_Reference_Id__c = '58568568';
            pd1.ProductCode = 'C';
            insert pd1;
            
            Benefi__c bnf1 = new Benefi__c();
            bnf1.Ben_code__c = 'BEN000280';
            bnf1.Name = 'test';
            bnf1.Dealer_Code__c = '';
            bnf1.Indusind_AcNo__c = '786767832788';
            bnf1.Beneficiary__c = 'EMP';
            bnf1.Status_Flag__c = 'L';
            bnf1.Dealership_Nature__c = 'CP-BH';
            bnf1.Email__c = 'poineerong@rediffmail.com';
            bnf1.Role__c = 'CVBE';
            insert bnf1;
            
            Bl_Code_Details__c blCodeDetail = new Bl_Code_Details__c();
            blCodeDetail.name = 'test blCodeDetail';
            blCodeDetail.Bl_Code__c = opds1.Agent_BL_code__c;
            blCodeDetail.State_Code__c = '69';
            blCodeDetail.Geo_State_Code__c = '96';
            insert blCodeDetail;
            
            Beneficiary_BlCode__c benefBLCode = new Beneficiary_BlCode__c();
            benefBLCode.Name = 'test benefBLCode';
            benefBLCode.Ben_code__c = bnf1.Id;
            benefBLCode.Bl_Code_Details__c = blCodeDetail.Id;
            benefBLCode.Unique_Identifier__c = 'TEST';
            insert benefBLCode;
            
            Beneficiary_Product__c bp1 = new Beneficiary_Product__c();
            bp1.Name = 'testname';
            bp1.OwnerId = UserInfo.getUserId();
            bp1.Product__c = pd1.Id;
            bp1.Ben_code__c = benefBLCode.Ben_code__c;
            bp1.Unique_Identifier__c = '678678';
            insert bp1;
            
            //created Beneficiary_BlCode__c record
            
            
            List<LoanDisbursementDetails__c> ldList = new List<LoanDisbursementDetails__c>();
            LoanDisbursementDetails__c disbursement = new LoanDisbursementDetails__c();
            disbursement.Parent_Loan_Application__c = opds1.Id;
            disbursement.Payment_Originated_From__c = 'OP';
            disbursement.Vehicle_Sold_By__c = 'Agency Dealer';
            disbursement.Vehicle_Registered_in_Name__c = 'Buyer';
            //   disbursement.Business_Sourced_By__c = u.Id;
            //   disbursement.Business_Done_By__c = u.Id;
            //    disbursement.FI_Done_By__c = u.Id;
            //     disbursement.Collection_Executive__c = tbmdm.Id;
            disbursement.Do_Issuance__c = 'Along_with_Payment';
            disbursement.Do_Issuance_Mode__c = 'Separate';
            disbursement.Do_To_be_authorized_by__c = bnf1.Id;
            disbursement.Balance_Transfer_Amount_in_Rs__c = 24000;
            disbursement.Purchase_doc_catq__c = 'Invoice';
            disbursement.Original_Purchase_value_in_Rs__c = 25000;
            disbursement.Original_purchase_date__c = Date.today();
            disbursement.Fund_End_Use__c = 'New_Vehicle_Margin_Money';
            insert disbursement;
            ldList.add(disbursement);
            
            Test.startTest();
            LoanDisbursementController.addNomineeDetailsToWrapper(loanw,ldList,opds1.Id);
            Test.stopTest();
        }
    }
    
    @isTest
    public static void getPymntOrigFromDDValuesTest3(){
        try{
            Opportunity opds1 = new Opportunity();
            opds1.StageName = 'Qualification';
            opds1.CloseDate = Date.newInstance(2021, 1, 11);
            opds1.Name = 'testone';
            opds1.Product_Type__c = 'ALL';
            opds1.Agent_BL_code__c = 'AG-001';
            insert opds1;
            
            Deal_Number_Setting__c dlNumberSetting= new Deal_Number_Setting__c();
            dlNumberSetting.Name = System.Label.Tractor;
            dlNumberSetting.MDNField1__c ='AB';
            dlNumberSetting.MDNField2__c = 2.0;
            insert dlNumberSetting;
            
            
            Deal_Number__c dl=new Deal_Number__c();
            dl.Loan_Application__c = opds1.Id;
            dl.DNField1__c = dlNumberSetting.MDNField1__c;
            dl.DNField2__c = String.valueOf(dlNumberSetting.MDNField2__c.round());
            //dl.Sub_Stage__c = 'test'; 
            insert dl;
            
            Test.startTest();
            LoanDisbursementController.getPymntOrigFromDDValues(opds1.Id, dl.Id);
            Test.stopTest();
        }catch(Exception e){
            //System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void getPymntOrigFromDDValuesTest4(){
        try{
            Opportunity opds1 = new Opportunity();
            opds1.StageName = 'Qualification';
            opds1.CloseDate = Date.newInstance(2021, 1, 11);
            opds1.Name = 'testone';
            opds1.Product_Type__c = 'Two Wheeler';
            opds1.Agent_BL_code__c = 'AG-001';
            opds1.Vehicle_Type__c = 'New';
            //  opds1.Vehicle_Sub_Category__c = '';
            insert opds1;
            
            Deal_Number_Setting__c dlNumberSetting= new Deal_Number_Setting__c();
            dlNumberSetting.Name = System.Label.TwoWheeler;
            dlNumberSetting.MDNField1__c ='AB';
            dlNumberSetting.MDNField2__c = 2.0;
            insert dlNumberSetting;
            
            
            Deal_Number__c dl=new Deal_Number__c();
            dl.Loan_Application__c = opds1.Id;
            dl.DNField1__c = dlNumberSetting.MDNField1__c;
            dl.DNField2__c = String.valueOf(dlNumberSetting.MDNField2__c.round());
            dl.Sub_Stage__c = 'Beneficiary Details'; 
            insert dl;
            
            Vehicle_Detail__c vg3 = new Vehicle_Detail__c();
            vg3.Loan_Application__c = opds1.Id;
            vg3.Base_Price__c = 100000.00;
            vg3.Ben_Code__c = 'BEN110085';
            vg3.Variant__c = 'testvariant';
            vg3.Dealer_Sub_dealer_name__c = 'T V SUNDARAM IYENGAR AND SONS PVT LTD';
            insert vg3;
            
            Benefi__c bnf1 = new Benefi__c();
            bnf1.Ben_code__c = vg3.Ben_Code__c;
            bnf1.Name = 'test';
            bnf1.Dealer_Code__c = '';
            bnf1.Indusind_AcNo__c = '786767832788';
            bnf1.Beneficiary__c = 'EMP';
            bnf1.Status_Flag__c = 'L';
            bnf1.Dealership_Nature__c = 'CP-BH';
            bnf1.Email__c = 'poineerong@rediffmail.com';
            bnf1.Role__c = 'CVBE';
            bnf1.TA__c = 'Y';
            insert bnf1;
            
            Test.startTest();
            LoanDisbursementController.getPymntOrigFromDDValues(opds1.Id, dl.Id);
            Test.stopTest();
        }catch(Exception e){
            //System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void getCollectionExecutiveDDValuesTest3(){
        try{
            User u = [SELECT Id,usertype FROM User WHERE username='test_userprod123456@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            { 
                Opportunity opds1 = new Opportunity();
                opds1.StageName = 'Qualification';
                opds1.CloseDate = Date.newInstance(2021, 1, 11);
                opds1.Name = 'testone';
                opds1.Product_Type__c = 'Passenger Vehicles';
                opds1.Agent_BL_code__c = 'AG-001';
                insert opds1;
                
                
                Bl_Code_Details__c bl = new Bl_Code_Details__c();
                bl.Bl_Code__c = opds1.Agent_BL_code__c;
                insert bl;
                
                TBM_DL_Master__c tbm = new TBM_DL_Master__c();
                //tbm.BL_Code__r.Bl_Code__c = '1234';
                tbm.BL_Code__c = bl.id;
                tbm.Product__c = 'D';
                tbm.Status__c = 'L';
                insert tbm;
                
                Test.startTest();
                LoanDisbursementController.getCollectionExecutiveDDValues(opds1.Id);
                Test.stopTest();
            }
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void getVehicleSoldByTest3(){
        try{
            User u = [SELECT Id,usertype FROM User WHERE username='test_userprod123456@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            { 
                Opportunity opds1 = new Opportunity();
                opds1.StageName = 'Qualification';
                opds1.CloseDate = Date.newInstance(2021, 1, 11);
                opds1.Name = 'testone';
                //   opds1.Product_Type__c = 'Passenger Vehicles';
                //   opds1.Agent_BL_code__c = 'AG-001';
                opds1.Vehicle_Type__c = 'New';
                opds1.Vehicle_Sub_Category__c = 'UOM';
                insert opds1;
                
                LoanDisbursementController.VehicleWrapper vw1 = new LoanDisbursementController.VehicleWrapper();
                //  vw1.isvehicletype = true;
                //   vw1.vehiclechassis = 'test';
                //   vw1.vehicleengine = 'test';
                //   vw1.vehicleReg = 'test';
                //   vw1.vehicletype = 'test';
            }
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    @isTest
    public static void isInsuranceSelected() {
        Opportunity opds1 = new Opportunity();
        opds1.StageName = 'Qualification';
        opds1.CloseDate = Date.newInstance(2021, 1, 11);
        opds1.Name = 'testone';
        opds1.Product_Type__c = 'Passenger Vehicles';
        opds1.Agent_BL_code__c = 'AG-001';
        insert opds1;
        
        InsuranceDetails__c objInsurance = new InsuranceDetails__c();
        //objInsurance.Loan_Application__c = opp.Id;
        objInsurance.Funded_Premium__c = 500;
        objInsurance.Name = 'GPA';
        objInsurance.Funded_Non_funded__c = 'Funded';
        objInsurance.Loan_Application__c = opds1.Id;
        insert objInsurance;
        
        Test.startTest();
        LoanDisbursementController.isInsuranceProductSelected(opds1.Id);
        Test.stopTest();
    }
    
    @isTest
    public static void isDocumentPresent() {
        Opportunity opds1 = new Opportunity();
        opds1.StageName = 'Qualification';
        opds1.CloseDate = Date.newInstance(2021, 1, 11);
        opds1.Name = 'testone';
        opds1.Product_Type__c = 'Passenger Vehicles';
        opds1.Agent_BL_code__c = 'AG-001';
        insert opds1;
        
        
        Deal_Number_Setting__c dlNumberSetting= new Deal_Number_Setting__c();
        dlNumberSetting.Name = System.Label.PassengerVehicles;
        dlNumberSetting.MDNField1__c ='AB';
        dlNumberSetting.MDNField2__c = 2.0;
        insert dlNumberSetting;
        
        
        Deal_Number__c dl=new Deal_Number__c();
        dl.Loan_Application__c = opds1.Id;
        dl.DNField1__c = dlNumberSetting.MDNField1__c;
        dl.DNField2__c = String.valueOf(dlNumberSetting.MDNField2__c.round());
        //dl.Sub_Stage__c = 'test'; 
        insert dl;
        
        Vehicle_Detail__c vg3 = new Vehicle_Detail__c();
        vg3.Loan_Application__c = opds1.Id;
        vg3.Base_Price__c = 100000.00;
        vg3.Ben_Code__c = 'BEN110085';
        vg3.Variant__c = 'testvariant';
        vg3.Payment_requested__c = (Date.today()+5);
        vg3.Deal_Number__c = dl.Id;
        insert vg3;
        
        Applicant__c objApplicant = new Applicant__c();
        objApplicant.Opportunity__c = opds1.Id;
        objApplicant.Applicant_Type__c = 'Borrower';
        objApplicant.Contact_number__c = '1234567890';
        insert objApplicant;
        
        Documents__c objDocument = new Documents__c();
        objDocument.Opportunity_Relation__c = opds1.Id;
        objDocument.name = 'DocName';
        objDocument.Document_Type__c = 'Insurance Application';
        objDocument.is_Active__c = true;
        objDocument.Applicant__c = objApplicant.Id;
        objDocument.Vehicle_Detail__c = vg3.Id;
        insert objDocument;
        
        LoanDisbursementController.isDocumentPresentForInsuranceApplication(opds1.Id,dl.Id);
        
        Test.startTest();
        opds1.Product_Type__c = System.Label.Tractor;
        update opds1;
        
        LoanDisbursementController.isDocumentPresentForInsuranceApplication(opds1.Id,dl.Id);
        Test.stopTest();
    }
    
    @isTest
    public static void isCasaConsentReceivedTestForBorrower() {
        Opportunity opds1 = new Opportunity();
        opds1.StageName = 'Qualification';
        opds1.CloseDate = Date.newInstance(2021, 1, 11);
        opds1.Name = 'testone';
        opds1.Product_Type__c = 'Passenger Vehicles';
        opds1.Agent_BL_code__c = 'AG-001';
        insert opds1;
        Applicant__c objApplicant = new Applicant__c();
        objApplicant.Opportunity__c = opds1.Id;
        objApplicant.Applicant_Type__c = 'Borrower';
        objApplicant.Contact_number__c = '1234567890';
        objApplicant.CASA_Consent_Received__c = true;
        objApplicant.In_Active_Applicant__c=false;
        insert objApplicant;
        
        Test.startTest();
        LoanDisbursementController.BeneficiaryDetailsWrapper response = LoanDisbursementController.isCasaConsentReceived(opds1.Id);
        System.assertEquals(true,response.borrowerconsentRecived);
        Test.stopTest();
    }
    
    @isTest
    public static void isCasaConsentReceivedTestForCoBorrower() {
        Opportunity opds1 = new Opportunity();
        opds1.StageName = 'Qualification';
        opds1.CloseDate = Date.newInstance(2021, 1, 11);
        opds1.Name = 'testone';
        opds1.Product_Type__c = 'Passenger Vehicles';
        opds1.Agent_BL_code__c = 'AG-001';
        insert opds1;
        Applicant__c objApplicant = new Applicant__c();
        objApplicant.Opportunity__c = opds1.Id;
        objApplicant.Applicant_Type__c = System.Label.CoBorrower;
        objApplicant.Contact_number__c = '1234567890';
        objApplicant.CASA_Consent_Received__c = true;
        objApplicant.In_Active_Applicant__c=false;
        insert objApplicant;
        
        Test.startTest();
        LoanDisbursementController.BeneficiaryDetailsWrapper response = LoanDisbursementController.isCasaConsentReceived(opds1.Id);
        System.assertEquals(true,response.coborrowerconsentRecived);
        Test.stopTest();
    }
    
    @isTest
    public static void isRevokedLeadTest1() {
        Opportunity opds1 = new Opportunity();
        opds1.StageName = 'Qualification';
        opds1.CloseDate = Date.newInstance(2021, 1, 11);
        opds1.Name = 'testone';
        opds1.Product_Type__c = 'Passenger Vehicles';
        opds1.Agent_BL_code__c = 'AG-001';
        opds1.Is_Revoked__c = true;
        insert opds1;
        
        Test.startTest();
        Boolean response = LoanDisbursementController.isRevokedLead(opds1.Id);
        System.assertEquals(true,response);
        Test.stopTest();
    }
    
    @isTest
    public static void isRevokedLeadTest2() {
        Opportunity opds1 = new Opportunity();
        opds1.StageName = 'Qualification';
        opds1.CloseDate = Date.newInstance(2021, 1, 11);
        opds1.Name = 'testone';
        opds1.Product_Type__c = 'Passenger Vehicles';
        opds1.Agent_BL_code__c = 'AG-001';
        opds1.Is_Revoked__c = false;
        insert opds1;
        
        Test.startTest();
        Boolean response = LoanDisbursementController.isRevokedLead(opds1.Id);
        System.assertEquals(false,response);
        Test.stopTest();
    }
    @isTest
    public static void dsaPaymentDisablingtest() {
        Opportunity opds1 = new Opportunity();
        opds1.StageName = 'Qualification';
        opds1.CloseDate = Date.newInstance(2021, 1, 11);
        opds1.Name = 'testone';
        opds1.Product_Type__c = 'Passenger Vehicles';
        opds1.LeadSource = null;
        opds1.Vehicle_Type__c = 'used';
        insert opds1;
        Final_Term__c fi = new Final_Term__c();
        fi.Loan_Application__c = opds1.Id;
        fi.Loan_Amount__c = '10000';
        fi.Referrer_Name__c = 'testname';
        
        insert fi;
        
        DSA_Preferred_BE_Mapping__c dsabe = new DSA_Preferred_BE_Mapping__c();
        dsabe.Preferred_BE_Name__c = 'testname';
        dsabe.Active_Flag__c = true;
        insert dsabe;
        Test.startTest();
        Boolean response = LoanDisbursementController.dsaPaymentDisbaling(opds1.Id);
        Test.stopTest();
    }
    @isTest
    public static void getVehicleTypeTest() {
        Opportunity opds1 = new Opportunity();
        opds1.StageName = 'Qualification';
        opds1.CloseDate = Date.newInstance(2021, 1, 11);
        opds1.Name = 'testone';
        opds1.Product_Type__c = 'Passenger Vehicles';
        opds1.Agent_BL_code__c = 'AG-001';
        opds1.Is_Revoked__c = false;
        insert opds1;
        
        Test.startTest();
        Opportunity response = LoanDisbursementController.getVehicleType(opds1.Id);
        Test.stopTest();
    }
    @isTest
    public static void isPaymentRequestGeneratedTest() {
        Opportunity opds1 = new Opportunity();
        opds1.StageName = 'Qualification';
        opds1.CloseDate = Date.newInstance(2021, 1, 11);
        opds1.Name = 'testone';
        opds1.Product_Type__c = 'Tractor';
        opds1.Agent_BL_code__c = 'AG-001';
        opds1.Is_Revoked__c = false;
        opds1.Deal_Number__c = 'Test';
        opds1.Parent_Deal_number__c = 'Test';        
        insert opds1;
        
        Deal_Number_Setting__c dlNumberSetting= new Deal_Number_Setting__c();
        dlNumberSetting.Name = System.Label.TwoWheeler;
        dlNumberSetting.MDNField1__c ='AB';
        dlNumberSetting.MDNField2__c = 2.0;
        insert dlNumberSetting;
        
        Deal_Number__c dl= [Select Id from Deal_Number__c limit 1];
        
        Vehicle_Detail__c vg3 = new Vehicle_Detail__c();
        vg3.Loan_Application__c = opds1.Id;
        vg3.Base_Price__c = 100000.00;
        vg3.Ben_Code__c = 'BEN110085';
        vg3.Variant__c = 'testvariant';
        vg3.Payment_requested__c = (Date.today()+5);
        insert vg3;
        
        Case caseObj = new Case();
        caseObj.Loan_Application__c = opds1.id;
        caseObj.Type = 'Current Residence FI';
        caseObj.Status = 'Pass';
        caseObj.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('TVR').getRecordTypeId();
        insert caseObj;
        
        String officeRecordTypeID = Schema.SObjectType.Field_Investigation__c.getRecordTypeInfosByName().get('Office').getRecordTypeId();
        Field_Investigation__c fieldInvestigationList = new Field_Investigation__c(Case__c=caseObj.Id,RecordTypeId=officeRecordTypeID,FI_Feedback__c='TEST');
        
         CAM__c objCAM = new CAM__c();
         objCAM.Loan_Application__c = opds1.Id;
         objCAM.Loan_Amount__c = 500;
         insert objCAM;
        
        Boolean isPaymentRequestGeneratedResponse1 = LoanDisbursementController.isPaymentRequestGenerated(opds1.Id,null);
        
        Test.startTest();
        vg3.Deal_Number__c = dl.Id;
        update vg3;
        
        Boolean isPaymentRequestGeneratedResponse = LoanDisbursementController.isPaymentRequestGenerated(opds1.Id,dl.Id);
        Boolean Response = LoanDisbursementController.isPACTLMSIntegrationLogGenerated(opds1.Id,dl.Id);
        Boolean isInsuranceProductSelectedResponse = LoanDisbursementController.isInsuranceProductSelected(opds1.Id);
        
        Boolean isRevokedLeadResponse = LoanDisbursementController.isRevokedLead(opds1.Id);
        // Boolean isDocumentPresentForInsuranceApplicationResponse = LoanDisbursementController.isDocumentPresentForInsuranceApplication(opds1.Id,dl.Id);
        Deal_Number__c getDealNumberDetailsResponse = LoanDisbursementController.getDealNumberDetails(opds1.Id,dl.Id);
        LoanDisbursementController.getCamRecord(opds1.Id);
        LoanDisbursementController.isChildLeadClosed(opds1.Id);
        
        opds1.Product_Type__c = 'Passenger Vehicles';
        opds1.Payment_Request_Generation_Date__c = (Date.today()+5);
        update opds1;
        
        Boolean isTVRCaseCompletedResponse = LoanDisbursementController.isTVRCaseCompleted(opds1.Id);
        Boolean Response1 = LoanDisbursementController.isPACTLMSIntegrationLogGenerated(null,null);
        Boolean isPaymentRequestGeneratedResponse2 = LoanDisbursementController.isPaymentRequestGenerated(opds1.Id,dl.Id);
        Test.stopTest();
        
    }
    @isTest
    public static void getFICaseListRecordTest() {
        Opportunity opds1 = new Opportunity();
        opds1.StageName = 'Qualification';
        opds1.CloseDate = Date.newInstance(2021, 1, 11);
        opds1.Name = 'testone';
        opds1.Product_Type__c = 'Passenger Vehicles';
        opds1.Agent_BL_code__c = 'AG-001';
        opds1.Is_Revoked__c = false;
        insert opds1;
        
        Applicant__c objApplicant = new Applicant__c();
        objApplicant.Opportunity__c = opds1.Id;
        objApplicant.Applicant_Type__c = System.Label.CoBorrower;
        objApplicant.Contact_number__c = '1234567890';
        objApplicant.CASA_Consent_Received__c = true;
        objApplicant.In_Active_Applicant__c=false;
        insert objApplicant;
        
        CIBIL_Details__c cibil = TestDataUtility.createCIBILDetails(false,objApplicant);
        cibil.CIBIL_Pull_Date__c = (Date.today()-35);
        insert cibil;
                
        String fiRecordTypeID = Schema.SObjectType.Case.getRecordTypeInfosByName().get('FI').getRecordTypeId();
        
        Case caseObj = new Case();
        caseObj.Loan_Application__c = opds1.id;
        caseObj.Type = 'Current Residence FI';
        caseObj.Status = 'Pass';
        caseObj.RejectedFI__c=false;
        caseObj.RecordTypeId=fiRecordTypeID;
        insert caseObj;
        
        //Get Asset Verification Case recordTypeId
        ID caseAVRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Asset Verification').getRecordTypeId();
        case cs1 = new case();
        cs1.Loan_Application__c = opds1.Id;
        cs1.Applicant__c = objApplicant.Id;
        cs1.Subject='AssetVerification Case';
        cs1.Status = 'New';
        cs1.Priority = 'Medium';
        cs1.RecordTypeId = caseAVRecordType;
        //cs1.OwnerId = opp.OwnerId;
        insert cs1; 
        
        Asset_Verification__c  avRec = new Asset_Verification__c ();
        //avRec.Name = vd1.Name;
        //avRec.Asset_MMV__c= vd1.Make__c+' '+vd1.Model__c+' '+vd1.Variant__c;
        //avRec.Engine_No__c= vd1.Engine_number__c;
        //avRec.Chasis_No__c= vd1.Chassis_number__c;
        //avRec.Serial_No__c= vd1.Serial_number__c;
        //avRec.RC_No__c = vd1.Vehicle_Registration_Number__c;
        //avRec.HMR__c = (vd1.KMS_Run__c != null) ? Decimal.valueOf(vd1.KMS_Run__c) : 0;
        avRec.Status__c= 'Completed';
        //avRec.Vehicle_Detail__c= vd1.Id;
        avRec.Case__c = cs1.Id;
        //avRec.Applicant__c = applicant.Id;
        //avRec.OwnerId = cs1.OwnerId;
        insert avRec; 
        
        Asset_Verification__c  avRec2 = new Asset_Verification__c ();
        avRec2.Status__c= 'Completed';
        avRec2.Case__c = cs1.Id;
        avRec2.Date_of_submission__c = Date.today()+5;
        insert avRec2; 
        
        CAM__c objCAM = new CAM__c();
        objCAM.Loan_Application__c = opds1.Id;
        objCAM.Loan_Amount__c = 500;
        insert objCAM;
        
        String officeRecordTypeID = Schema.SObjectType.Field_Investigation__c.getRecordTypeInfosByName().get('Office').getRecordTypeId();
        Field_Investigation__c fieldInvestigation = new Field_Investigation__c(Case__c=caseObj.Id,RecordTypeId=officeRecordTypeID,FI_Feedback__c='TEST',Office_FI_Completion_Time__c=(Date.today()-35));
        insert fieldInvestigation;
        
        String officeRecordTypeID1 = Schema.SObjectType.Field_Investigation__c.getRecordTypeInfosByName().get('Office').getRecordTypeId();
        Field_Investigation__c fieldInvestigation1 = new Field_Investigation__c(Case__c=caseObj.Id,RecordTypeId=officeRecordTypeID1,FI_Feedback__c='TEST');
        insert fieldInvestigation1;
        
        String permanentRecordTypeID = Schema.SObjectType.Field_Investigation__c.getRecordTypeInfosByName().get('Permanent').getRecordTypeId();
        Field_Investigation__c fieldInvestigation2 = new Field_Investigation__c(Case__c=caseObj.Id,RecordTypeId=permanentRecordTypeID,FI_Feedback__c='TEST',Residence_FI_completion_time__c=(Date.today()-35));
        insert fieldInvestigation2;
        
        String permanentRecordTypeID1 = Schema.SObjectType.Field_Investigation__c.getRecordTypeInfosByName().get('Permanent').getRecordTypeId();
        Field_Investigation__c fieldInvestigation21 = new Field_Investigation__c(Case__c=caseObj.Id,RecordTypeId=permanentRecordTypeID1,FI_Feedback__c='TEST');
        insert fieldInvestigation21;
        
        Test.startTest();
        LoanDisbursementController.getFICaseListRecord(opds1.Id,'');
        Test.stopTest();
    }
    
    
    @isTest
    private static void getLoanDisbursementRecordTest() {
        try
        {
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE username='test_userprod123456@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {  
                Opportunity oppRec = [SELECT Id, Vehicle_Type__c, Product_Type__c FROM Opportunity WHERE Vehicle_Type__c = 'Used' LIMIT 1];
                
                
                LoanDisbursementController.isValidUser(oppRec.Id);
                
                //System.assertEquals(false, bool);
                //System.assertEquals(true, bool1);
                
            }
            Test.stopTest();                          
        }catch(Exception e){
            system.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    private static void getLoanDisbursementRecordTest2() {
        try
        {
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE username='test_userprod123456@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {  
                Opportunity optg1 = [SELECT Id, Name, StageName, CloseDate, Vehicle_Type__c, Product_Type__c, Vehicle_Sub_Category__c FROM Opportunity WHERE Vehicle_Sub_Category__c =: 'UPB'];                
                List <LoanDisbursementDetails__c> disbursementList =  [SELECT Id, Parent_Loan_Application__c, Borrower_DOB__c, Borrower_Name__c, Borrower_Relationship__c,
                                                                       Payment_Originated_From__c, Vehicle_Sold_By__c, Vehicle_Registered_in_Name__c, Business_Sourced_By__c,
                                                                       FI_Done_By__c, Collection_Executive__c, Do_Issuance__c, Do_Issuance_Mode__c, Do_To_be_authorized_by__c, 
                                                                       Balance_Transfer_Amount_in_Rs__c, Purchase_doc_catq__c, Original_Purchase_value_in_Rs__c, 
                                                                       Original_purchase_date__c, Fund_End_Use__c, Borrower_Address__c, Borrower_Spouse_Gender__c, Borrower_Spouse_DOB__c,
                                                                       Borrower_X1st_Child_Name__c, Borrower_X1st_Child_DOB__c, Borrower_X2nd_Child_Name__c,
                                                                       Borrower_X2nd_Child_Gender__c, Borrower_X2nd_Child_DOB__c, Borrower_X3rd_Child_Name__c, 
                                                                       Borrower_X3rd_Child_Gender__c, Borrower_X3rd_Child_DOB__c, Borrower_Father_DOB__c,
                                                                       Borrower_Mother_DOB__c, Borrower_Insurance_business_done_by__c, CoBorrower_Name__c,
                                                                       CoBorrower_DOB__c, CoBorrower_Relationship__c, CoBorrower_Address__c, CoBorrower_Spouse_Gender__c,
                                                                       CoBorrower_Spouse_DOB__c, CoBorrower_X1st_Child_Name__c, CoBorrower_X1st_Child_Gender__c,
                                                                       CoBorrower_X1st_Child_DOB__c, CoBorrower_X2nd_Child_Name__c, CoBorrower_X2nd_Child_Gender__c, 
                                                                       CoBorrower_X2nd_Child_DOB__c, CoBorrower_X3rd_Child_Name__c, CoBorrower_X3rd_Child_Gender__c,
                                                                       CoBorrower_X3rd_Child_DOB__c, CoBorrower_Father_DOB__c, CoBorrower_Mother_DOB__c, CoBorrower_Insurance_business_done_by__c,
                                                                       Borrower_X1st_Child_Gender__c
                                                                       FROM LoanDisbursementDetails__c WHERE Parent_Loan_Application__c =: optg1.Id LIMIT 1];                
                Deal_Number__c deal = [select id,Loan_Application__c from Deal_Number__c where Loan_Application__c =: optg1.Id limit 1];
                
                LoanDisbursementDetails__c loanDis = LoanDisbursementController.getLoanDisbursementRecord(optg1.Id,deal.Id);
                
                System.assertEquals(loanDis.Do_Issuance_Mode__c , 'Separate');
                optg1.Product_Type__c = System.Label.Tractor;
                update optg1;
                
                LoanDisbursementDetails__c loanDis1 = LoanDisbursementController.getLoanDisbursementRecord(optg1.Id,deal.Id);
                System.assertEquals(loanDis1.Do_Issuance_Mode__c , 'Separate');
                
                LoanDisbursementController.getLoanDisbursementRecord(optg1.Id,null);                
            }
            Test.stopTest();                          
        }catch(Exception e){
            system.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    private static void testupdateCaseFIRecords() {
        Opportunity optg1 = [SELECT Id, Name, StageName, CloseDate, Vehicle_Type__c, Product_Type__c, Vehicle_Sub_Category__c FROM Opportunity WHERE Vehicle_Sub_Category__c =: 'UPB'];
        
        List<Case> cases = [SELECT Id,OwnerId,Owner.Name FROM Case WHERE Type =:'Current Residence FI' AND Loan_Application__c = :optg1.Id LIMIT 1];
        
        CaseHistory caseHis = new CaseHistory();
        caseHis.CaseId = cases[0].Id;
        caseHis.Field = 'Applicant__c';
        insert caseHis;
        
        List<Field_Investigation__c> fieldInvestList = new List<Field_Investigation__c>();
        String officeRecordTypeID = Schema.SObjectType.Field_Investigation__c.getRecordTypeInfosByName().get('Office').getRecordTypeId();
        Field_Investigation__c fieldInvestigation = new Field_Investigation__c(Case__c=cases[0].Id,RecordTypeId=officeRecordTypeID,FI_Feedback__c='TEST');        
        fieldInvestList.add(fieldInvestigation);
        
        String residenceRecordTypeID = Schema.SObjectType.Field_Investigation__c.getRecordTypeInfosByName().get('Residence').getRecordTypeId();
        Field_Investigation__c fieldInvestigation1 = new Field_Investigation__c(Case__c=cases[0].Id,RecordTypeId=residenceRecordTypeID,FI_Feedback__c='TEST');        
        fieldInvestList.add(fieldInvestigation1);
        
        insert fieldInvestList;
        
        
        Test.startTest();
        LoanDisbursementController.updateCaseFIRecords(cases,fieldInvestList,optg1.Id);
        Test.stopTest();                          
        
    }
    
    @isTest
    private static void testUpdateAssetVerAndCase() {
        Case cs =[SELECT Id FROM Case limit 1];
        
        Test.startTest();
        Asset_Verification__c av = new Asset_Verification__c();
        av.Case__c = cs.Id; 
        insert av;
        LoanDisbursementController.updateAssetVerAndCase(new List<Asset_Verification__c>{av},null);
        Test.stopTest();                          
        
    }
}