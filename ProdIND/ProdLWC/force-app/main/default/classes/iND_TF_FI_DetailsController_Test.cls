@isTest
public class iND_TF_FI_DetailsController_Test {
    @testSetup static void createFIData() {
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u = new User(Alias = 'standt2', Email='standarduser2@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,Maker_Id__c='12',IsActive = true,
                          TimeZoneSidKey='America/Los_Angeles',UserName='test_userprod123@indusbank.com.uat',MobilePhone = '9089078967');
        insert u;
        System.runAs(u) 
        {
            Opportunity opp = TestDataUtility.createTestLoanApplication(true);        
            opp.Sub_Stage__c = System.Label.Field_Investigation;
            opp.Is_Mobile_Journey_Completed__c = true;
            opp.Vehicle_Type__c = System.Label.used;
            opp.Product_Type__c = System.Label.TwoWheeler;
            opp.Sanction_Status__c = System.Label.nonStp;
            
            update opp;
            
            Applicant__c applicant = TestDataUtility.createTestApplicantService(true,opp);
            applicant.In_Active_Applicant__c = false;
            applicant.Would_you_like_to_open_a_bank_account__c = true;
            update applicant;
            Id caseFIRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('FI').getRecordTypeId();
            Case cse = TestDataUtility.createTestCase(true,opp,applicant);
            cse.RecordTypeId = caseFIRecordTypeId;
            update cse;
            Field_Investigation__c fi = TestDataUtility.createTestFieldInvestigation(true,cse);
            fi.Total_Agri_Expenses_for_Proposed_Harvest__c = 10;
            fi.Total_Agri_Expenses_for_Existing_Tractor__c = 10;
            fi.Total_Agri_Expenses_for_Proposed_Tractor__c = 10;
            fi.Total_Agri_Income_for_Existing_Harvester__c = 10;
            fi.Total_Agri_Income_for_Proposed_Harvester__c = 10;
            fi.Total_Agri_Income_for_Existing_Tractor__c = 10;
            fi.Total_Agri_Income_for_Proposed_Tractor__c = 10; 
            fi.Total_Agri_Net_Income_for_Existing_Harve__c = 10;
            fi.Total_Agri_Net_Income_for_Proposed_Harve__c = 10;
            fi.Total_Agri_Net_Income_for_Existing_Tract__c = 10;
            fi.Total_Agri_Net_Income_for_Proposed_Tract__c =10;
            fi.Total_Agri_Comm_Expenses_Exist_Harvest__c = 10;
            fi.Total_Agri_Comm_Expen_Proposed_Harvest__c =10;
            fi.Total_Agri_Comm_Expense_Existing_Tractor__c = 10; 
            fi.Total_Agri_Comm_Expense_Proposed_Tractor__c = 10; 
            fi.Total_Agri_Comm_Income_Existing_Harvest__c = 10;
            fi.Total_Agri_Comm_Income_Proposed_Harvest__c = 10;
            fi.Total_Agri_Comm_Income_Existing_Tractor__c = 10; 
            fi.Total_Agri_Comm_Income_Proposed_Tractor__c = 10;
            fi.Total_Agri_Com_NetIncome_Existing_Harves__c = 10; 
            fi.Total_Agri_Com_NetIncome_Proposed_Harves__c = 10; 
            fi.Total_Agri_Comm_NetIncome_Existing_Tract__c = 10; 
            fi.Total_Agri_Com_NetIncome_Proposed_Tract__c = 10;
            update fi;
        }
    }
    
    @isTest public static void testKCCAndOtherLoanInformation(){
        Field_Investigation__c fi = [SELECT Id from Field_Investigation__c limit 1];
        list<iND_TF_FI_DetailsController.KccAndOtherLoanInformationWrapper>  kccWrapperList = new list<iND_TF_FI_DetailsController.KccAndOtherLoanInformationWrapper>();
        iND_TF_FI_DetailsController.KccAndOtherLoanInformationWrapper kccWrapper = new iND_TF_FI_DetailsController.KccAndOtherLoanInformationWrapper();
        kccWrapper.isValid = true;
        kccWrapper.isDatabase = false;
        kccWrapper.Loan_Type = 'KCC';
        kccWrapper.Loan_Stakeholders = 'Borrower';
        kccWrapper.Loan_number = '1234R';
        kccWrapper.LOAN_AMOUNT = '20000';
        kccWrapper.BANK_NAME = 'Test';
        kccWrapper.Loan_Start_Date = '2023-08-01';
        kccWrapper.EMI_Amount = '2000';
        kccWrapper.Last_EMI_Paid_Date = '2023-08-01';
        kccWrapper.Total_Remarks_by_FI_Agent = 'test';
        kccWrapper.Model_Details = 'test';
        kccWrapper.id = '1';
        kccWrapperList.add(kccWrapper);
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            iND_TF_FI_DetailsController.saveKCCAndOtherLoanDetails(kccWrapperList,fi.Id);
            iND_TF_FI_DetailsController.getKCCOtherLoanInformationRecords(fi.Id);
        }
        
    }
    
    @isTest public static void testexistingTractorLoanInformation(){
        Field_Investigation__c fi = [SELECT Id from Field_Investigation__c limit 1];
        list<iND_TF_FI_DetailsController.existingTractorLoanInformationWrapper>  existingTractorLoanWrapperList = new list<iND_TF_FI_DetailsController.existingTractorLoanInformationWrapper>();
        iND_TF_FI_DetailsController.existingTractorLoanInformationWrapper existingTractorLoanWrapper = new iND_TF_FI_DetailsController.existingTractorLoanInformationWrapper();
        existingTractorLoanWrapper.isValid = true;
        existingTractorLoanWrapper.isDatabase = false;
        existingTractorLoanWrapper.Loan_Type = 'Tractor';
        existingTractorLoanWrapper.Loan_Stakeholders = 'Wife';
        existingTractorLoanWrapper.Loan_number = '1234R';
        existingTractorLoanWrapper.LOAN_AMOUNT = '20000';
        existingTractorLoanWrapper.BANK_NAME = 'Test';
        existingTractorLoanWrapper.Loan_Start_Date = '2023-08-01';
        existingTractorLoanWrapper.EMI_Amount = '2000';
        existingTractorLoanWrapper.Last_EMI_Paid_Date = '2023-08-01';
        existingTractorLoanWrapper.Total_Remarks_by_FI_Agent = 'test';
        existingTractorLoanWrapper.Model_Details = 'test';
        existingTractorLoanWrapper.Loan_Free = 'No';
        existingTractorLoanWrapper.id = '1';
        existingTractorLoanWrapperList.add(existingTractorLoanWrapper);
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            iND_TF_FI_DetailsController.saveExistingLoanDetails(existingTractorLoanWrapperList,fi.Id);
            iND_TF_FI_DetailsController.getExistingLoanDetails(fi.Id);
        }
        
    }
    
    @isTest public static void testviabilityForExistingTractorLoanInformation(){
        Field_Investigation__c fi = [SELECT Id from Field_Investigation__c limit 1];
        list<iND_TF_FI_DetailsController.saveViabilityExistingTractorInformationWrapper>  viabilityLoanWrapperList = new list<iND_TF_FI_DetailsController.saveViabilityExistingTractorInformationWrapper>();
        iND_TF_FI_DetailsController.saveViabilityExistingTractorInformationWrapper viabilityLoanWrapper = new iND_TF_FI_DetailsController.saveViabilityExistingTractorInformationWrapper();
        viabilityLoanWrapper.isValid = true;
        viabilityLoanWrapper.isDatabase = false;
        viabilityLoanWrapper.Usage_Type = '';
        viabilityLoanWrapper.id = '1';
        viabilityLoanWrapper.Diesal_counsumption_hr = '4';
        viabilityLoanWrapper.Diesal_Rate_Hr = '88';
        viabilityLoanWrapper.Existing_Proposed = 'Proposed';
        viabilityLoanWrapper.Expenses = '100';
        viabilityLoanWrapper.Net_Income = '2000';
        viabilityLoanWrapper.Nos_of_Hours_run_in_year = '10';
        viabilityLoanWrapper.Per_Hour_Rate = '500';
        viabilityLoanWrapper.Total_Income = '5000';
        viabilityLoanWrapper.Tractor_Harvester = 'Tractor';
        viabilityLoanWrapperList.add(viabilityLoanWrapper);
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            iND_TF_FI_DetailsController.saveViabilityExistingTractorDetails(viabilityLoanWrapperList,fi.Id);
            iND_TF_FI_DetailsController.getViabilityExistingTractorInformation(fi.Id);
        }
        
    }
    
    @isTest public static void testgetCurrentResidenceAddress(){
        Applicant__c applicant = [SELECT Id from Applicant__c];
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            iND_TF_FI_DetailsController.getCurrentResidenceAddress(applicant.Id);
            iND_TF_FI_DetailsController.getPermanentResidenceAddress(applicant.Id);
        }
    }
    
    @isTest public static void testexpenseInvestment(){
        Field_Investigation__c fi = [SELECT Id from Field_Investigation__c limit 1];
        list<iND_TF_FI_DetailsController.ExpenseAndInvestmentWrapper>  recordsLst = new list<iND_TF_FI_DetailsController.ExpenseAndInvestmentWrapper>();
        iND_TF_FI_DetailsController.ExpenseAndInvestmentWrapper rec = new iND_TF_FI_DetailsController.ExpenseAndInvestmentWrapper();
        rec.isValid = true;
        rec.isDatabase = false;
        rec.Type = 'Expense';
        rec.ExpenseType= 'Approx Medical Expenses';
        rec.Amount = 12;
        
        recordsLst.add(rec);
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            iND_TF_FI_DetailsController.saveExpenseInvestmentDetails(recordsLst,fi.Id);
            iND_TF_FI_DetailsController.getExpenseInvestmentDetail(fi.Id);
        }
        
    }
    
    @isTest public static void testVehicleDetailsRecord(){
        Opportunity op = [SELECT Id from Opportunity limit 1];
        Vehicle_Detail__c vehicleDetailObject = new Vehicle_Detail__c(Loan_Application__c=op.Id ,Product__c ='H');
        Insert vehicleDetailObject;
        
        list<iND_TF_FI_DetailsController.loaninformationWrapper>  recordsLst = new list<iND_TF_FI_DetailsController.loaninformationWrapper>();
        iND_TF_FI_DetailsController.loaninformationWrapper rec = new iND_TF_FI_DetailsController.loaninformationWrapper();
        rec.purchasePrice = '12';
        rec.marginAmountToDealer = '21';
        rec.emiConveyed = 12;
        rec.loanTenure= 24;
        rec.Id = vehicleDetailObject.id;       
        
        recordsLst.add(rec);
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            iND_TF_FI_DetailsController.updateVehicleRecord(recordsLst,op.Id);
            iND_TF_FI_DetailsController.getVehicleDetailsRecord(op.Id);
        }
        
    }
    
    @isTest public static void testsaveCattleInformation(){
        Field_Investigation__c fi = [SELECT Id from Field_Investigation__c limit 1];
        list<iND_TF_FI_DetailsController.CattleInformationWrapper>  recordsLst = new list<iND_TF_FI_DetailsController.CattleInformationWrapper>();
        iND_TF_FI_DetailsController.CattleInformationWrapper rec = new iND_TF_FI_DetailsController.CattleInformationWrapper();
        rec.Nos_of_Cattle = 5;
        rec.Cattle_Name = 'BULL';
        rec.isValid = true;
        rec.isDatabase = false;
        
        recordsLst.add(rec);
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            iND_TF_FI_DetailsController.saveCattleInformation(recordsLst,fi.Id);
            iND_TF_FI_DetailsController.getCattleInformation(fi.Id);
        }
        
    }
    
    @isTest public static void testgetLocationAll(){
        
        Geo_State_Masters__c state = new Geo_State_Masters__c();
        state.Name = 'State Name';
        state.Pincode_Starting_Max__c = 66;
        state.Pincode__c = 53;
        state.State_Code__c = '33';
        insert state;
        
        District_Master__c district = new District_Master__c();
        district.Name = 'district Name';
        district.Geo_State_Master__c = state.id;
        district.District_Code__c = 23;
        insert district;
        
        Taluka_Master__c taluqa = new Taluka_Master__c();
        taluqa.Name = 'Test';
        taluqa.Per_Acre_Cost__c = 100;
        taluqa.State__c = state.id;
        taluqa.District__c = district.id;
        insert taluqa;
        
        Test.startTest();
        iND_TF_FI_DetailsController.getTaluqaMaster('State Name', 'district Name');
        iND_TF_FI_DetailsController.getAllDistrict();
        iND_TF_FI_DetailsController.getDistrictMasterByState('State Name');
        iND_TF_FI_DetailsController.getStateMaster();
        Test.stopTest();
        
    }
    
    @isTest public static void testFetchNonAgriInfo(){
        Field_Investigation__c fi = [SELECT Id FROM Field_Investigation__c Limit 1];
        Category_Master__c cm = new Category_Master__c();
        cm.Category__c = 'Test Cat 1';
        cm.Sub_category__c = 'Test Sub cat 1';
        cm.Income__c = 12;
        insert cm;
        
        Non_Agri_Income__c agriRec = new Non_Agri_Income__c();
        agriRec.Utilization__c = '65';
        agriRec.Total_Income__c = 250;
        agriRec.Category_Master__c = cm.Id;
        agriRec.Field_Investigation__c = fi.Id;
        insert agriRec;
        
        Test.startTest();
        iND_TF_FI_DetailsController.fetchNonAgriInfo(fi.Id);
        iND_TF_FI_DetailsController.fetchCategoryMaster();
        Test.stopTest();
    }
    
    /*   @isTest public static void saveNonAgriIncomeInformation(){
iND_TF_FI_DetailsController.NonAgriIncomeWrapper wrap = new iND_TF_FI_DetailsController.NonAgriIncomeWrapper();

Field_Investigation__c fi = [SELECT Id FROM Field_Investigation__c Limit 1];

Category_Master__c cm = new Category_Master__c();
cm.Category__c = 'Test Cat 1';
cm.Sub_category__c = 'Test Sub cat 1';
cm.Income__c = 12;
insert cm;

wrap.id = '1';
wrap.Utilization = '65';
wrap.Total_Income = String.valueOf(230);
wrap.isValid = true;
wrap.isDatabase = false;
wrap.Category = String.valueOf(cm.Id);
wrap.Category_Value = 'Test Cat 1';
wrap.Sub_Category = 'Test Sub cat 1';
wrap.Income = String.valueOf(23);

List<iND_TF_FI_DetailsController.NonAgriIncomeWrapper> wrapLst = new List<iND_TF_FI_DetailsController.NonAgriIncomeWrapper>();
wrapLst.add(wrap);

Test.startTest();
iND_TF_FI_DetailsController.saveNonAgriIncomeInformation(wrapLst,fi.id);
Test.stopTest();

}
*/
    
    @isTest public static void testgetCropInformation(){
        Field_Investigation__c fi = [SELECT Id FROM Field_Investigation__c Limit 1];
         Crop_Detail__c cd = new Crop_Detail__c();
        cd.Field_Investigation__c = fi.id;
        cd.Crop_Cultivated_Year__c = 'Last Year';
		insert cd;
        Test.startTest();
        iND_TF_FI_DetailsController.getCropInformation(fi.id, 'Last Year');
        Test.stopTest();
    }
    
    @isTest public static void testfetchCropMaster(){
        try{
        Field_Investigation__c fi = [SELECT Id FROM Field_Investigation__c Limit 1];
        
        Geo_State_Masters__c state = new Geo_State_Masters__c();
        state.Name = 'State Name';
        state.Pincode_Starting_Max__c = 66;
        state.Pincode__c = 53;
        state.State_Code__c = '33';
        insert state;
        
        District_Master__c district = new District_Master__c();
        district.Name = 'district Name';
        district.Geo_State_Master__c = state.id;
        district.District_Code__c = 23;
        insert district;
        
        Crop_Master__c cm = new Crop_Master__c();
        cm.Name = 'Test';
        cm.Location__c = district.id;
        insert cm;
        Test.startTest();
        iND_TF_FI_DetailsController.fetchCropMaster(district.id);
        iND_TF_FI_DetailsController.CropDetailWrapper obj = new iND_TF_FI_DetailsController.CropDetailWrapper();
        obj.Crop_Grown_in_acre = '2';
        obj.Crop_Master = cm.Id;
        obj.District_Master = district.id;
        obj.isDatabase = false;
        obj.isValid = true;
        obj.Crop_Type = 'Test';
        obj.Net_Income = '500000';
        obj.Land_Survey_No = '54';
        iND_TF_FI_DetailsController.saveCropInformation(new  List<iND_TF_FI_DetailsController.CropDetailWrapper>{obj},(String) fi.Id, 'Last Year');
        Test.stopTest();
        }
        catch(Exception e){
            
        }
    }
    
    @isTest public static void testsaveLandHoldingDetails(){
        Field_Investigation__c fi = [SELECT Id from Field_Investigation__c limit 1];
        list<iND_TF_FI_DetailsController.LandHoldingDetailWrapper>  recordsLst = new list<iND_TF_FI_DetailsController.LandHoldingDetailWrapper>();
        iND_TF_FI_DetailsController.LandHoldingDetailWrapper rec = new iND_TF_FI_DetailsController.LandHoldingDetailWrapper();
        rec.isValid = true;
        rec.isDatabase = false;
        rec.Land_holder_Name = 'sdsdsd'; 
        rec.Type = 'Borrower';
        rec.Land_holding_Type = 'Agri Commercial';
        //rec.State_Master = 'Rajasthan';
        //rec.Ownership_Type = 'Individual';
        rec.Since_How_long_are_they_doing_Agricultu = '33';
        rec.Land_holding_In_acres = '23';
        recordsLst.add(rec);
        User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod123@indusbank.com.uat' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {
            iND_TF_FI_DetailsController.saveLandHoldingDetails(recordsLst,fi.Id);
            iND_TF_FI_DetailsController.getLandHoldingDetails(fi.Id);
        }
        
    }
    
    @isTest public static void testgetDistrictMasterByPOA(){
        Field_Investigation__c fi = [SELECT Id, Case__r.Loan_Application__c, Case__r.Applicant__c  from Field_Investigation__c limit 1];
        Documents__c doc = new Documents__c();
        doc.Opportunity_Relation__c = fi.Case__r.Loan_Application__c;
        doc.Proof_of_Address_POA__c = true;
        doc.KYC_State__c = 'TAMIL NADU';
        doc.Applicant__c = fi.Case__r.Applicant__c;
        insert doc;
        Geo_State_Masters__c state = new Geo_State_Masters__c();
        state.Name = 'TAMIL NADU';
        state.Pincode_Starting_Max__c = 66;
        state.Pincode__c = 53;
        state.State_Code__c = '33';
        insert state;
        Test.startTest();
        iND_TF_FI_DetailsController.getDistrictMasterByPOA(fi.Id,true);
        Test.stopTest();
        
    }
    
    @isTest public static void testGetWorkOrderDetails(){
        Field_Investigation__c fi = [SELECT Id FROM Field_Investigation__c Limit 1];
        Work_Order_Details__c wo = new Work_Order_Details__c();
        wo.Field_Investigation__c = fi.Id;
        insert wo;
        Test.startTest();
        iND_TF_FI_DetailsController.getWorkOrderDetails(fi.id);
        Test.stopTest();
    }
    
    
    @isTest public static void testGetFleetDetails(){
        Field_Investigation__c fi = [SELECT Id FROM Field_Investigation__c Limit 1];
        Fleet_Details__c fd = new Fleet_Details__c();
        fd.Field_Investigation__c = fi.Id;
        insert fd;
        Test.startTest();
        iND_TF_FI_DetailsController.getFleetDetails(fi.id);
        Test.stopTest();
    }
    
    @isTest public static void testGetFIRecord(){
        Case cse = [SELECT Id FROM Case Limit 1];
        
        Test.startTest();
        iND_TF_FI_DetailsController.getFIRecord(cse.id);
        Test.stopTest();
    }
    
    @isTest public static void testGetLandSurveyNo(){
        Field_Investigation__c fi = [SELECT Id FROM Field_Investigation__c Limit 1];
        Land_Holding_Detail__c lhd = new Land_Holding_Detail__c();
        lhd.Field_Investigation__c = fi.Id;
        insert lhd;
        
        Test.startTest();
        iND_TF_FI_DetailsController.getSubSchemeValue(fi.id);
        iND_TF_FI_DetailsController.getFieldInvestigationKycLocation(fi.id);
        iND_TF_FI_DetailsController.getLandSurveyNo(fi.id);
        Test.stopTest();
    }
    
    @isTest public static void testSaveFleetDetails(){
        Field_Investigation__c fi = [SELECT Id FROM Field_Investigation__c Limit 1];
        
        List<iND_TF_FI_DetailsController.FleetWrapper> flWrapList = new List<iND_TF_FI_DetailsController.FleetWrapper>();
        iND_TF_FI_DetailsController.FleetWrapper flWrap = new iND_TF_FI_DetailsController.FleetWrapper();
        flWrap.isValid = true;
        flWrap.isDatabase = false;
        flWrapList.add(flWrap);
        Test.startTest();
        iND_TF_FI_DetailsController.saveFleetDetails(flWrapList,fi.id);
        Test.stopTest();
    }

   @isTest public static void testsaveWorkOrderDetails(){
        Field_Investigation__c fi = [SELECT Id FROM Field_Investigation__c Limit 1];
        
        List<iND_TF_FI_DetailsController.WorkOrderWrapper> workOrderWrapList = new List<iND_TF_FI_DetailsController.WorkOrderWrapper>();
        iND_TF_FI_DetailsController.WorkOrderWrapper woWrap = new iND_TF_FI_DetailsController.WorkOrderWrapper();
        woWrap.isValid = true;
        woWrap.isDatabase = false;
        workOrderWrapList.add(woWrap);
        Test.startTest();
        iND_TF_FI_DetailsController.saveWorkOrderDetails(workOrderWrapList,fi.id);
        Test.stopTest();
    }    
    
     
    
}