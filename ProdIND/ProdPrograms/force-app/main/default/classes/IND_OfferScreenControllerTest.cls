/*------------------------------------------------------------
Author:        Aditya
Company:       Persistent
Description:   This is Test class for IND_OfferScreenController.apxc
Test Class: 
Date:          2/23/2022
History
Date            Author              Comments
-------------------------------------------------------------

------------------------------------------------------------*/

@isTest 
public class IND_OfferScreenControllerTest {
    
    @testSetup
    static void CreateTestData(){
        //create user
        Profile p = [SELECT Id FROM Profile WHERE Name='IBL CVO'];
        User u = new User(Alias = 'standt2', Email='standarduser3@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,Maker_Id__c='12',IsActive = true,
                          TimeZoneSidKey='America/Los_Angeles',UserName='test_userprod23@indusbank1.com',MobilePhone = '9089078967');
        insert u;
        System.runAs(u) 
        {
            //create Oppty records
            List<Opportunity> opptyList = new List<Opportunity>();
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            opp.Name = 'VDR Test';
            opp.Product_Type__c = 'Tractor';
            opptyList.add(opp);
            if(Schema.sObjectType.Opportunity.isCreateable()){
                insert opptyList;
            }
           	Final_Term__c FT = TestDataUtility.createfinalTerm(true, opptyList[0]);
            //create Deal_Number__c record
            Deal_Number__c createDealNumber = TestDataUtility.createDealNumber(true,opptyList[0]);
            
            //create Vehicle_Detail__c record
            List<Vehicle_Detail__c> vdList = new List<Vehicle_Detail__c>();
            Vehicle_Detail__c  vehicleDetail = TestDataUtility.createTestVehicleDetailForIbb(false, opptyList[0]);
            vehicleDetail.Deal_Number__c=createDealNumber.Id;
            vdList.add(vehicleDetail);
            if (Schema.sObjectType.Vehicle_Detail__c.isCreateable()){
                insert vdList;
            }
            
        }
    }
    
    @isTest
    static void loadOfferScreenData_test(){
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        
        Vehicle_Detail__c vg2 = new Vehicle_Detail__c();
        vg2.Loan_Application__c = opp.Id;
        vg2.Base_Price__c = 100000.00;
        vg2.Ben_Code__c = 'testveh';
        vg2.Variant__c = 'testvariant';
        vg2.Vehicle_Category__c = 'L';
        insert vg2;
        
        Final_Term__c ft = new Final_Term__c();
        ft.Vehicle_Detail__c = vg2.Id;
        ft.CRM_IRR__c = 120;
        ft.Loan_Application__c = opp.Id;
        ft.Tenure__c= '9';
        ft.Advance_EMI__c= true;
        ft.Loan_Amount__c='100000';
        ft.Required_CRM_IRR__c='N/A';
        ft.OfferengineMaxLoanAmount__c= 1000000 ;
        ft.OfferengineMinLoanAmount__c= 100000;
        ft.OfferengineMaxTenure__c=24 ;
        ft.OfferengineMinTenure__c=9 ;
        ft.Advance_EMI__c= true;
        ft.Holiday_period__c='30';
        ft.EMI_Amount__c= 10000;
        insert ft;
        
        ROI_Master__c rm1 = new ROI_Master__c();
        rm1.Description__c = System.Label.ROI;
        rm1.Vehicle_Category__c = vg2.Vehicle_Category__c;
        rm1.External_Id__c = '78437';
        rm1.Description__c = 'CRM_IRR';
        rm1.Product_Segment__c = 'TWO_WHEELER';
        rm1.Tenure_Max__c = 12;
        rm1.Tenure_Min__c = 11;
        insert rm1;
        
        IND_OfferScreenController.LoadOfferScreenDataWrapper obj = new IND_OfferScreenController.LoadOfferScreenDataWrapper();
        
        test.startTest();
        try{
            IND_OfferScreenController.loadOfferScreenData(opp.id,vg2.Id);    
        }catch(exception e){
            system.debug(e.getMessage());
        }       
        IND_OfferScreenController.roiMasterForGrossIRR(opp.id,'Two Wheeler','ESCOOTER','New');
        test.stopTest();  
    }
    
    @isTest
    static void loadOfferScreenData_test1(){
        Opportunity opp =TestDataUtility.createTestOpportunity4(true);
        
        Vehicle_Detail__c vg2 = new Vehicle_Detail__c();
        vg2.Loan_Application__c = opp.Id;
        vg2.Base_Price__c = 100000.00;
        vg2.Ben_Code__c = 'testveh';
        vg2.Variant__c = 'testvariant';
        vg2.Vehicle_Category__c = 'L';
        insert vg2;
        
        Final_Term__c ft = new Final_Term__c();
        ft.Vehicle_Detail__c = vg2.Id;
        ft.CRM_IRR__c = 120;
        ft.Loan_Application__c = opp.Id;
        ft.Tenure__c= '9';
        ft.Advance_EMI__c= true;
        ft.Loan_Amount__c='100000';
        ft.Required_CRM_IRR__c='N/A';
        ft.OfferengineMaxLoanAmount__c= 1000000 ;
        ft.OfferengineMinLoanAmount__c= 100000;
        ft.OfferengineMaxTenure__c=24 ;
        ft.OfferengineMinTenure__c=9 ;
        ft.Advance_EMI__c= true;
        ft.Holiday_period__c='30';
        ft.EMI_Amount__c= 10000;
        insert ft;
        
        ROI_Master__c rm1 = new ROI_Master__c();
        rm1.Description__c = System.Label.ROI;
        rm1.Vehicle_Category__c = vg2.Vehicle_Category__c;
        rm1.External_Id__c = '78437';
        rm1.Description__c = 'CRM_IRR';
        rm1.Product_Segment__c = 'TWO_WHEELER';
        rm1.Tenure_Max__c = 12;
        rm1.Tenure_Min__c = 11;
        insert rm1;
        
        IND_OfferScreenController.LoadOfferScreenDataWrapper obj = new IND_OfferScreenController.LoadOfferScreenDataWrapper();
        
        test.startTest();
        try{
            IND_OfferScreenController.loadOfferScreenData(opp.id,vg2.Id);    
        }catch(exception e){
            system.debug(e.getMessage());
        }       
        test.stopTest();  
    }
    
    
    @isTest
    static void getOfferScreenData_test(){
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        test.startTest();
        IND_OfferScreenController.getOfferScreenData(opp.Id);
        try{
            IND_OfferScreenController.getOfferScreenData('');
            IND_OfferScreenController.getOfferScreenData(null);
        }catch(exception e){
            system.debug(e.getMessage());  
        }
        test.stopTest();
    }
    
    /* @isTest
static void checkRetryExhausted_test(){
Retry_Count__c rc =   TestDataUtility.createTestRetryCount(false);
rc.Service_Name__c = 'OfferScreenApiCount';
insert rc;
IND_OfferScreenController.FinalTermApiWrapper obj = new IND_OfferScreenController.FinalTermApiWrapper();
Opportunity opp = TestDataUtility.createTestOpportunity(true);
Retry_Count__c rcone = [select id,Loan_Application_Id__c from Retry_Count__c where id= :rc.id limit 1 ];
test.startTest();
IND_OfferScreenController.checkRetryExhausted(null);
try{
IND_OfferScreenController.checkRetryExhausted(rcone.Loan_Application_Id__c);  
IND_OfferScreenController.checkRetryExhausted(null);    
}catch(exception e){
system.debug(e.getMessage());
}
test.stopTest();
}*/
    
    @isTest
    public static void checkRetryExhausted_test(){
        try{
            Opportunity opgr1 = new Opportunity();
            opgr1.StageName = 'Proposal';
            opgr1.CloseDate = Date.newInstance(2021, 1, 11);
            opgr1.Name = 'testone';
            insert opgr1;
            Test.startTest();
            IND_OfferScreenController.checkRetryExhausted(opgr1.id);
            Test.stopTest();
        }catch(Exception e){
            system.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void checkRetryExhausted_test1(){
        try{
            Opportunity opgr1 = new Opportunity();
            opgr1.StageName = 'Proposal';
            opgr1.CloseDate = Date.newInstance(2021, 1, 11); 
            opgr1.Name = 'testone';
            insert opgr1;
            
            Retry_Count__c rc1 = new Retry_Count__c();
            rc1.Loan_Application_Id__c = opgr1.Id;
            rc1.Service_Name__c =  'OfferScreenApiCount';
            rc1.User_Id__c = UserInfo.getUserId();
            rc1.Count__c = 7;
            insert rc1;
            Test.startTest();
            IND_OfferScreenController.checkRetryExhausted(opgr1.id);
            Test.stopTest();
        }catch(Exception e){
            system.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void updateRetryCount_Test(){
        try{
            Opportunity opgr1 = new Opportunity();
            opgr1.StageName = 'Proposal';
            opgr1.CloseDate = Date.newInstance(2021, 1, 11);
            opgr1.Name = 'testone';
            insert opgr1;
            
            Retry_Count__c rc1 = new Retry_Count__c();
            rc1.Loan_Application_Id__c = opgr1.Id;
            rc1.Service_Name__c = 'FinalTermApi';
            rc1.User_Id__c = UserInfo.getUserId();
            rc1.Count__c = 7;
            insert rc1;
            
            Test.startTest();
            IND_OfferScreenController.updateRetryCount(opgr1.id);
            Test.stopTest();
        }catch(Exception e){
            system.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    
    @isTest
    static void retryCountIncrease_test(){
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        Retry_Count__c rc =   New Retry_Count__c();
        rc.Service_Name__c = 'OfferScreenApiCount';
        rc.Loan_Application_Id__c = opp.Id;
        rc.Count__c = 0;
        insert rc;
        test.startTest();
        Retry_Count__c rcone = [select id,Loan_Application_Id__c from Retry_Count__c where id= :rc.id limit 1 ];
        IND_OfferScreenController.retryCountIncrease(rcone.Loan_Application_Id__c);
        try{
            IND_OfferScreenController.retryCountIncrease('');    
        }catch(exception e){
            system.debug(e.getMessage());
        }        
        test.stopTest();
    }  
    
    @isTest
    static void getVechicleDetails_test(){
        Vehicle_Detail__c vc =  TestDataUtility.createTestVehicleDetailForDealEligible1(true);
        Vehicle_Detail__c vcone = [select id,name,Loan_Application__c from Vehicle_Detail__c where id = :vc.Id];
        IND_OfferScreenController.getVechicleDetails(vcone.Loan_Application__c,vcone.Id);
    }
    
    @isTest
    static void getVechicleDetails_test1(){
		Opportunity opp = [SELECT Id FROM Opportunity WHERE Name = 'VDR Test' LIMIT 1];        
        List<Vehicle_Detail__c> vdList = [SELECT Id FROM Vehicle_Detail__c WHERE Loan_Application__c =:opp.Id LIMIT 1];
        IND_OfferScreenController.getVechicleDetails(opp.Id,vdList[0].Id);
    }
    
    @isTest
    public static void checkL1OfferScreenSubmittedTest(){
        try{
            Opportunity opp = [SELECT Id FROM Opportunity WHERE Name = 'VDR Test' LIMIT 1];        
            List<Vehicle_Detail__c> vdList = [SELECT Id FROM Vehicle_Detail__c WHERE Loan_Application__c =:opp.Id LIMIT 1];
            Test.startTest();
            IND_OfferScreenController.checkL1OfferScreenSubmitted(opp.Id,vdList[0].Id);
            Test.stopTest();
        }
        catch(Exception ex){
            
        }
    }
    
    @isTest
    public static void checkL1OfferScreenSubmittedTest1(){
        try{
            Opportunity opp = [SELECT Id FROM Opportunity WHERE Name = 'VDR Test' LIMIT 1];        
            Test.startTest();
            IND_OfferScreenController.checkL1OfferScreenSubmitted(opp.Id,null);
            Test.stopTest();
        }
        catch(Exception ex){
            
        }
    }
    
    @isTest
    public static void getVehicleRecordsTest(){
        try{
            Opportunity opp = [SELECT Id FROM Opportunity WHERE Name = 'VDR Test' LIMIT 1];        
            Test.startTest();
            IND_OfferScreenController.getVehicleRecords(opp.Id);
            Test.stopTest();
        } 
        catch(Exception ex){
            
        }
    }
    
    @isTest
    public static void loadSelectedSchemeDataTest(){
        try{   
            Test.startTest();
            Schemes__c schemeObject = new Schemes__c( Name= 'Platform launch',DocCharges__c=15,ServiceCharges__c=20, FromDate__c=System.today().addMonths(-1), ExistingCustomer__c=true);
            insert schemeObject;
            Schemes__c sc1=IND_OfferScreenController.loadSelectedSchemeData(schemeObject.Id);
            Test.stopTest();
        } 
        catch(Exception ex){
            
        }
    }

    @isTest
    public static void roiMasterTest(){
        try{
            Opportunity opgr1 = new Opportunity();
            opgr1.StageName = 'Proposal';
            opgr1.CloseDate = Date.newInstance(2021, 1, 11);
            opgr1.Name = 'testone';
            insert opgr1;
            
            Product2 prd2 = new Product2();
            prd2.Asset_Category__c = 'te';
            prd2.Name = 'book';
            prd2.Type__c = 'Model';
            prd2.External_Reference_Id__c = '58568568';
            prd2.ProductCode = 'C';
            insert prd2;
            
            ROI_Master__c rm2 = new ROI_Master__c();
            rm2.Vehicle_Category__c = 'N';
            rm2.External_Id__c = '78437';
            rm2.Description__c = 'CRM_IRR';
            rm2.Product_Segment__c = 'TWO_WHEELER';
            rm2.Tenure_Max__c = 12;
            rm2.Tenure_Min__c = 7;
            rm2.Product__c = prd2.Id;
            insert rm2;
            
            Test.startTest();
            IND_OfferScreenController.roiMaster(opgr1.Id,'Passenger Vehicles',10,'New');
            IND_OfferScreenController.roiMaster(opgr1.Id,'Two Wheeler',10,'Used');
            IND_OfferScreenController.roiMaster(opgr1.Id,'Two Wheeler',10,'Refinance');
            IND_OfferScreenController.roiMaster('','',5,'');
            Test.stopTest();
            
        }catch(Exception e){
            system.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void roiMasterForImputedIRRTest(){
        try{
            Opportunity opgr1 = new Opportunity();
            opgr1.StageName = 'Proposal';
            opgr1.CloseDate = Date.newInstance(2021, 1, 11);
            opgr1.Name = 'testone';
            insert opgr1;
            
            Product2 prd2 = new Product2();
            prd2.Asset_Category__c = 'te';
            prd2.Name = 'book';
            prd2.Type__c = 'Model';
            prd2.External_Reference_Id__c = '58568568';
            prd2.ProductCode = 'H';
            insert prd2;
            
            ROI_Master__c rm2 = new ROI_Master__c();
            rm2.Vehicle_Category__c = 'N';
            rm2.External_Id__c = '78437';
            rm2.Description__c = 'IMPUTED_IRR';
            rm2.Product_Segment__c = 'TWO_WHEELER';
            rm2.Tenure_Max__c = 12;
            rm2.Tenure_Min__c = 7;
            rm2.Product__c = prd2.Id;
            insert rm2;
            
            Test.startTest();
            IND_OfferScreenController.roiMasterForImputedIRR(opgr1.Id,'Two Wheeler',10,'New');
            IND_OfferScreenController.roiMasterForImputedIRR(null,'Two Wheeler',10,'New');
            Test.stopTest();
            
        }catch(Exception e){
            system.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void roiMasterForImputedIRRTest1(){
        try{
            Opportunity opgr1 = new Opportunity();
            opgr1.StageName = 'Proposal';
            opgr1.CloseDate = Date.newInstance(2021, 1, 11);
            opgr1.Name = 'testone';
            insert opgr1;
            
            Product2 prd2 = new Product2();
            prd2.Asset_Category__c = 'te';
            prd2.Name = 'book';
            prd2.Type__c = 'Model';
            prd2.External_Reference_Id__c = '58568568';
            prd2.ProductCode = 'C';
            insert prd2;
            
            ROI_Master__c rm2 = new ROI_Master__c();
            rm2.Vehicle_Category__c = 'N';
            rm2.External_Id__c = '78437';
            rm2.Description__c = 'CRM_IRR';
            rm2.Tenure_Max__c = 12;
            rm2.Tenure_Min__c = 7;
            rm2.Product__c = prd2.Id;
            rm2.Max_value__c = 18;
            insert rm2;
            
            MCLR_Master__c mcl1 = new MCLR_Master__c();
            mcl1.Period__c = 15;
            mcl1.Flag__c = 'L';
            mcl1.Nature__c = 'FXD';
            mcl1.Rate_Type__c = 'MCLR';
            mcl1.MCLR__c = 9;
            mcl1.Sl_No__c = 189;
            mcl1.Unique_Id__c = '1234hjh';
            mcl1.Eff_from_date__c = system.today();
            insert mcl1;
            
            Test.startTest();
            IND_OfferScreenController.roiMasterForImputedIRR(opgr1.Id,'Passenger Vehicles',10,'Used');
            Test.stopTest();
            
        }catch(Exception e){
            system.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
     @isTest
    public static void roiMasterForImputedIRRTest2(){
        try{
            Opportunity opgr1 = new Opportunity();
            opgr1.StageName = 'Proposal';
            opgr1.CloseDate = Date.newInstance(2021, 1, 11);
            opgr1.Name = 'testone';
            insert opgr1;
            
            Product2 prd2 = new Product2();
            prd2.Asset_Category__c = 'te';
            prd2.Name = 'book';
            prd2.Type__c = 'Model';
            prd2.External_Reference_Id__c = '58568568';
            prd2.ProductCode = 'C';
            insert prd2;
            
            ROI_Master__c rm2 = new ROI_Master__c();
            rm2.Vehicle_Category__c = 'N';
            rm2.External_Id__c = '78437';
            rm2.Description__c = 'CRM_IRR';
            rm2.Tenure_Max__c = 12;
            rm2.Tenure_Min__c = 7;
            rm2.Product__c = prd2.Id;
            rm2.Max_value__c = 18;
            insert rm2;
            
            MCLR_Master__c mcl1 = new MCLR_Master__c();
            mcl1.Period__c = 15;
            mcl1.Flag__c = 'L';
            mcl1.Nature__c = 'FXD';
            mcl1.Rate_Type__c = 'MCLR';
            mcl1.MCLR__c = 9;
            mcl1.Sl_No__c = 189;
            mcl1.Unique_Id__c = '1234hjh';
            mcl1.Eff_from_date__c = system.today();
            insert mcl1;
            
            Test.startTest();
            IND_OfferScreenController.roiMasterForImputedIRR(opgr1.Id,'Passenger Vehicles',0,'Refinance');
            Test.stopTest();
            
        }catch(Exception e){
            system.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
     @isTest
    public static void roiMasterForImputedIRRTest3(){
        try{
            Opportunity opgr1 = new Opportunity();
            opgr1.StageName = 'Proposal';
            opgr1.CloseDate = Date.newInstance(2021, 1, 11);
            opgr1.Name = 'testone';
            insert opgr1;
            
            Product2 prd2 = new Product2();
            prd2.Asset_Category__c = 'te';
            prd2.Name = 'book';
            prd2.Type__c = 'Model';
            prd2.External_Reference_Id__c = '58568568';
            prd2.ProductCode = 'C';
            insert prd2;
            
            ROI_Master__c rm2 = new ROI_Master__c();
            rm2.Vehicle_Category__c = 'N';
            rm2.External_Id__c = '78437';
            rm2.Description__c = 'CRM_IRR';
            rm2.Tenure_Max__c = 12;
            rm2.Tenure_Min__c = 7;
            rm2.Product__c = prd2.Id;
            rm2.Max_value__c = 18;
            insert rm2;
            
            MCLR_Master__c mcl1 = new MCLR_Master__c();
            mcl1.Period__c = 15;
            mcl1.Flag__c = 'L';
            mcl1.Nature__c = 'FXD';
            mcl1.Rate_Type__c = 'MCLR';
            mcl1.MCLR__c = 9;
            mcl1.Sl_No__c = 189;
            mcl1.Unique_Id__c = '1234hjh';
            mcl1.Eff_from_date__c = system.today();
            insert mcl1;
            
            Test.startTest();
            IND_OfferScreenController.roiMasterForImputedIRR(opgr1.Id,'Passenger Vehicles',10,'New','CRM_IRR');
            Test.stopTest();
            
        }catch(Exception e){
            system.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
     @isTest
    public static void roiMasterForImputedIRRTest4(){
        try{
            Opportunity opgr1 = new Opportunity();
            opgr1.StageName = 'Proposal';
            opgr1.CloseDate = Date.newInstance(2021, 1, 11);
            opgr1.Name = 'testone';
            insert opgr1;
            
            Product2 prd2 = new Product2();
            prd2.Asset_Category__c = 'te';
            prd2.Name = 'book';
            prd2.Type__c = 'Model';
            prd2.External_Reference_Id__c = '58568568';
            prd2.ProductCode = 'C';
            insert prd2;
            
            ROI_Master__c rm2 = new ROI_Master__c();
            rm2.Vehicle_Category__c = 'N';
            rm2.External_Id__c = '78437';
            rm2.Description__c = 'CRM_IRR';
            rm2.Tenure_Max__c = 12;
            rm2.Tenure_Min__c = 7;
            rm2.Product__c = prd2.Id;
            rm2.Max_value__c = 18;
            insert rm2;
            
            MCLR_Master__c mcl1 = new MCLR_Master__c();
            mcl1.Period__c = 15;
            mcl1.Flag__c = 'L';
            mcl1.Nature__c = 'FXD';
            mcl1.Rate_Type__c = 'MCLR';
            mcl1.MCLR__c = 9;
            mcl1.Sl_No__c = 189;
            mcl1.Unique_Id__c = '1234hjh';
            mcl1.Eff_from_date__c = system.today();
            insert mcl1;
            
            Test.startTest();
            IND_OfferScreenController.roiMasterForImputedIRR(opgr1.Id,'Passenger Vehicles',0,'Refinance','CRM_IRR');
            Test.stopTest();
            
        }catch(Exception e){
            system.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
     @isTest
    public static void roiMasterForImputedIRRTest5(){
        try{
            Opportunity opgr1 = new Opportunity();
            opgr1.StageName = 'Proposal';
            opgr1.CloseDate = Date.newInstance(2021, 1, 11);
            opgr1.Name = 'testone';
            insert opgr1;
            
            Product2 prd2 = new Product2();
            prd2.Asset_Category__c = 'te';
            prd2.Name = 'book';
            prd2.Type__c = 'Model';
            prd2.External_Reference_Id__c = '58568568';
            prd2.ProductCode = 'C';
            insert prd2;
            
            ROI_Master__c rm2 = new ROI_Master__c();
            rm2.Vehicle_Category__c = 'N';
            rm2.External_Id__c = '78437';
            rm2.Description__c = 'CRM_IRR';
            rm2.Tenure_Max__c = 12;
            rm2.Tenure_Min__c = 7;
            rm2.Product__c = prd2.Id;
            rm2.Max_value__c = 18;
            insert rm2;
            
            MCLR_Master__c mcl1 = new MCLR_Master__c();
            mcl1.Period__c = 15;
            mcl1.Flag__c = 'L';
            mcl1.Nature__c = 'FXD';
            mcl1.Rate_Type__c = 'MCLR';
            mcl1.MCLR__c = 9;
            mcl1.Sl_No__c = 189;
            mcl1.Unique_Id__c = '1234hjh';
            mcl1.Eff_from_date__c = system.today();
            insert mcl1;
            
            Test.startTest();
            IND_OfferScreenController.roiMasterForImputedIRR(opgr1.Id,'Two Wheeler',10,'Used','CRM_IRR');
            Test.stopTest();
            
        }catch(Exception e){
            system.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void getPurchaseprice_test(){
        try{
            Opportunity opgr1 = new Opportunity();
            opgr1.StageName = 'Proposal';
            opgr1.CloseDate = Date.newInstance(2021, 1, 11);
            opgr1.Name = 'testone';
            opgr1.Vehicle_Type__c = 'New';
            insert opgr1;
            Opportunity opgr2 = new Opportunity();
            opgr2.StageName = 'Proposal';
            opgr2.CloseDate = Date.newInstance(2021, 1, 11);
            opgr2.Name = 'testone';
            insert opgr2;
            Vehicle_Detail__c vc =  TestDataUtility.createTestVehicleDetailForDealEligible1(true);
            Vehicle_Detail__c vcone = [select id,name,Loan_Application__c from Vehicle_Detail__c where id = :vc.Id];
            Test.startTest();
            IND_OfferScreenController.getPurchaseprice(opgr1.Id, vcone.Id);
            IND_OfferScreenController.getPurchaseprice(opgr2.Id, vcone.Id);
            Test.stopTest();
            
        }catch(Exception e){
            system.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
     @isTest
    public static void getStructedEMI_test(){
        try{
            Opportunity opgr1 = new Opportunity();
            opgr1.StageName = 'Proposal';
            opgr1.CloseDate = Date.newInstance(2021, 1, 11);
            opgr1.Name = 'testone';
            opgr1.Vehicle_Type__c = 'New';
            insert opgr1;

            Vehicle_Detail__c vc =  TestDataUtility.createTestVehicleDetailForDealEligible1(true);
            Vehicle_Detail__c vcone = [select id,name,Loan_Application__c from Vehicle_Detail__c where id = :vc.Id];
            
               //Create Structered_EMI__c records
            List<Structered_EMI__c> semiList = new List<Structered_EMI__c>();
            Structered_EMI__c semi = new Structered_EMI__c();
            semi.From_Month__c = 1;
            semi.To_Month__c = 9;
            semi.EMI_Amount__c = 45000;
            semi.Number_of_Installments__c = 9;
            semi.Loan_Application__c = opgr1.Id;
            semi.Vehicle_Detail__c = vcone.Id;
            semiList.add(semi);

            if(Schema.sObjectType.Structered_EMI__c.isCreateable()){
                insert semiList;
            }
            
            Test.startTest();
            IND_OfferScreenController.getStructedEMI(opgr1.Id, vcone.Id);
            Test.stopTest();
            
        }catch(Exception e){
            system.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    @isTest
    public static void loadSelectedSchemeData_test(){
        try{
            Product2 prd1 = new Product2();
            prd1.Name = 'TestPro';
            prd1.Asset_Category__c = 'te';
            prd1.Capacity_1__c = 1000.00;
            prd1.Capacity_2__c = 2000.00;
            prd1.Capacity_Units_1__c = 'test12';
            prd1.Capacity_Units_2__c = 'test13';
            prd1.Type__c = 'Make';
            prd1.External_Reference_Id__c = '58568568';
            insert prd1;
            
            Schemes__c sch1 = new Schemes__c();
            sch1.Customer_Type__c = 'New';
            sch1.ProductCode__c = prd1.Id;
            sch1.Unique_Identifier__c = 'test';
            sch1.FromDate__c = Date.newInstance(2022, 3, 31);
            sch1.ExistingCustomer__c = true;
            sch1.Vehicle_Type__c = 'New';
            sch1.Scheme_Expiry__c = Date.newInstance(2026, 3, 31);
            sch1.Product__c = 'Two Wheeler';
            insert sch1;
            
            Test.startTest();
            Schemes__c schemereturnData = IND_OfferScreenController.loadSelectedSchemeData(sch1.Id);
            Assert.isTrue(schemereturnData != null);
            
            Test.stopTest();
            
        }catch(Exception e){
            system.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
   @isTest
    public static void getTransactionRecord_test(){
        try{
            Opportunity opgr1 = new Opportunity();
            opgr1.StageName = 'Proposal';
            opgr1.CloseDate = Date.newInstance(2021, 1, 11);
            opgr1.Name = 'testone';
            opgr1.Vehicle_Type__c = 'New';
            opgr1.Product_Type__c = 'Two Wheeler';
            insert opgr1;
            
            Deal_Number_Setting__c dlNumberSetting= new Deal_Number_Setting__c();
            dlNumberSetting.Name = 'Two Wheeler';
            dlNumberSetting.MDNField1__c ='AB';
            dlNumberSetting.MDNField2__c = 2.0;
            insert dlNumberSetting;
            
            Deal_Number__c dlNum = new Deal_Number__c();
           // dlNum.Sub_Stage__c = 'tst';
            dlNum.Loan_Application__c = opgr1.Id;
            insert dlNum;
            
            Loan_Application_Transaction_History__c lath = new Loan_Application_Transaction_History__c();
            lath.Name = 'Structured EMI';
            lath.Loan_Application_ID__c = opgr1.Id;      
            lath.Deal_Number__c = dlNum.Id;
            lath.Module__c = 'Post Sanction Checks and Documentation';
            insert lath;
            
            Test.startTest();
            IND_OfferScreenController.getTransactionRecord(opgr1.Id, dlNum.Id);
            IND_OfferScreenController.updateTransactionRecord(opgr1.Id, dlNum.Id);
            IND_OfferScreenController.updateTransactionRecord('test1','test');
            IND_OfferScreenController.updateTransactionRecord(null,null);
            Test.stopTest();
            
            
        }catch(Exception e){
            system.assertEquals('Script-thrown exception', e.getMessage());
        }
    }

    @isTest
    public static void emiRepaymentSchedule_test(){
            Test.startTest();
            IND_OfferScreenController.emiRepaymentSchedule(1000.2, '2000', system.today(), 5, 20, '2', system.today(), system.today(),true);
        IND_OfferScreenController.emiRepaymentSchedule(1000.2, '2000', system.today(), 5, 20, '1', system.today(), system.today(),true);
            Test.stopTest();
    } 
    @isTest
    public static void roiMasterTractor(){
        try{
            Opportunity opgr1 = new Opportunity();
            opgr1.StageName = 'Proposal';
            opgr1.Vehicle_Type__c = 'New';
            opgr1.CloseDate = Date.newInstance(2021, 1, 11);
            opgr1.Name = 'testone';
            insert opgr1;
            
            Product2 prd2 = new Product2();
            prd2.Asset_Category__c = 'te';
            prd2.Name = 'book';
            prd2.Type__c = 'Model';
            prd2.External_Reference_Id__c = '58568568';
            prd2.ProductCode = 'T';
            insert prd2;
            
            ROI_Master__c rm2 = new ROI_Master__c();
            rm2.Vehicle_Category__c = 'N';
            rm2.External_Id__c = '78437';
            rm2.Description__c = 'CRM_IRR';
            rm2.Tenure_Max__c = 12;
            rm2.Tenure_Min__c = 7;
            rm2.Product__c = prd2.Id;
            rm2.Max_value__c = 18;
            insert rm2;
            

            Test.startTest();
            IND_OfferScreenController.roiMasterTractor(opgr1.Id);
            Test.stopTest();
            
        }catch(Exception e){
            system.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    @isTest
    public static void roiMasterTractorTest2(){
        try{
            Opportunity opgr1 = new Opportunity();
            opgr1.StageName = 'Proposal';
            opgr1.Vehicle_Type__c = 'Used';
            opgr1.CloseDate = Date.newInstance(2021, 1, 11);
            opgr1.Name = 'testone';
            insert opgr1;
            
            Product2 prd2 = new Product2();
            prd2.Asset_Category__c = 'te';
            prd2.Name = 'book';
            prd2.Type__c = 'Model';
            prd2.External_Reference_Id__c = '58568568';
            prd2.ProductCode = 'T';
            insert prd2;
            
            ROI_Master__c rm2 = new ROI_Master__c();
            rm2.Vehicle_Category__c = 'N';
            rm2.External_Id__c = '78437';
            rm2.Description__c = 'GROSS_IRR';
            rm2.Tenure_Max__c = 12;
            rm2.Tenure_Min__c = 7;
            rm2.Product__c = prd2.Id;
            rm2.Max_value__c = 18;
            insert rm2;
            

            Test.startTest();
            IND_OfferScreenController.roiMasterTractor(opgr1.Id);
            Test.stopTest();
            
        }catch(Exception e){
            system.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    @isTest
    public static void roiMasterTractorTest3(){
        try{
            Opportunity opgr1 = new Opportunity();
            opgr1.StageName = 'Proposal';
            opgr1.Vehicle_Type__c = 'Refinance';
            opgr1.CloseDate = Date.newInstance(2021, 1, 11);
            opgr1.Name = 'testone';
            insert opgr1;
            
            Product2 prd2 = new Product2();
            prd2.Asset_Category__c = 'te';
            prd2.Name = 'book';
            prd2.Type__c = 'Model';
            prd2.External_Reference_Id__c = '58568568';
            prd2.ProductCode = 'T';
            insert prd2;
            
            ROI_Master__c rm2 = new ROI_Master__c();
            rm2.Vehicle_Category__c = 'N';
            rm2.External_Id__c = '78437';
            rm2.Description__c = 'TENURE';
            rm2.Tenure_Max__c = 12;
            rm2.Tenure_Min__c = 7;
            rm2.Product__c = prd2.Id;
            rm2.Max_value__c = 18;
            insert rm2;
            

            Test.startTest();
            IND_OfferScreenController.roiMasterTractor(opgr1.Id);
            Test.stopTest();
            
        }catch(Exception e){
            system.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    @isTest
    public static void getOfferResponseTest(){
        try{
            Opportunity opgr1 = new Opportunity();
            opgr1.StageName = 'Proposal';
            opgr1.Vehicle_Type__c = 'Used';
            opgr1.CloseDate = Date.newInstance(2021, 1, 11);
            opgr1.Name = 'testone';
            insert opgr1;
            
            
            Vehicle_Detail__c vg2 = new Vehicle_Detail__c();
            vg2.Loan_Application__c = opgr1.Id;
            vg2.Base_Price__c = 100000.00;
            vg2.Ben_Code__c = 'testveh';
            vg2.Variant__c = 'testvariant';
            vg2.Vehicle_Category__c = 'L';
            insert vg2;
            
            Integration_Log__c inteLog = new Integration_Log__c();
            inteLog.Loan_Application__c =  opgr1.Id;
            inteLog.Service_Name__c = 'TF Offer Engine';
            inteLog.ReferenceId__c = vg2.Id;
            inteLog.Original_response__c = 'Please refer related list for response file';
            insert inteLog;
       
            Test.startTest();
            IND_OfferScreenController.getOfferResponse(opgr1.Id,vg2.Id);
            Test.stopTest();
            
        }catch(Exception e){
            system.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    @isTest
    public static void getOfferResponseTest2(){
        try{
            Opportunity opgr1 = new Opportunity();
            opgr1.StageName = 'Proposal';
            opgr1.Vehicle_Type__c = 'Refinance';
            opgr1.CloseDate = Date.newInstance(2021, 1, 11);
            opgr1.Name = 'testone';
            insert opgr1;
            Applicant__c apga1 = new Applicant__c();
            apga1.Opportunity__c = opgr1.Id;
            apga1.Contact_number__c = '9743514830';
            apga1.Applicant_Type__c = 'Borrower';
            insert apga1;
            
            Vehicle_Detail__c vg2 = new Vehicle_Detail__c();
            vg2.Loan_Application__c = opgr1.Id;
            vg2.Base_Price__c = 100000.00;
            vg2.Ben_Code__c = 'testveh';
            vg2.Variant__c = 'testvariant';
            vg2.Vehicle_Category__c = 'L';
            insert vg2;
            
            Integration_Log__c inteLog = new Integration_Log__c();
            inteLog.Loan_Application__c =  opgr1.Id;
            inteLog.Service_Name__c = 'TF Offer Engine';
            inteLog.ReferenceId__c = vg2.Id;
            insert inteLog;
            
            Documents__c dfu1 = new Documents__c();
            dfu1.Applicant__c = apga1.Id;
            dfu1.Opportunity_Relation__c = opgr1.Id;
            dfu1.Vehicle_Detail__c = vg2.Id;
            dfu1.is_Active__c = false;
            dfu1.Document_Type__c = System.Label.AadhaarCard;
            dfu1.Document_Side__c ='Back';
            dfu1.Aadhar_Source__c = 'ScanAadhar';
            dfu1.Front_Upload_Attempts__c = 5;
            insert dfu1;
            
             ContentVersion contentVersion1 = new ContentVersion(
                Title          = 'testfname',
                PathOnClient   = 'Pic.jpg',
                VersionData    = Blob.valueOf('Test Content'),
                IsMajorVersion = true);
            insert contentVersion1; 
            List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
            
            //create ContentDocumentLink  record
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.LinkedEntityId = inteLog.Id;
            cdl.ContentDocumentId = documents[0].Id;
            cdl.ShareType = 'V';
            cdl.Visibility = 'AllUsers';
            insert cdl;
       
            Test.startTest();
            IND_OfferScreenController.getOfferResponse(opgr1.Id,vg2.Id);
            Test.stopTest();
            
        }catch(Exception e){
            system.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
}