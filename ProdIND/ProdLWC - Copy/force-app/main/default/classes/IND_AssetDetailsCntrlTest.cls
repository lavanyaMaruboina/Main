/**
* @author       Neha Gosavi
* @company      Persistent Systems
* @description  A Test class for IND_AssetDetailsCntrl class
* Inputs: None
* History:
*/
@isTest(seeAllData = false)
public with sharing class IND_AssetDetailsCntrlTest {
    @isTest
    public static void loadAssetDetailsDataTest1(){
        try{
            Opportunity opgf2 = new Opportunity();
            opgf2.StageName = 'Qualification';
           // opgf2.Product_Type__c = 'Tractor';
            opgf2.CloseDate = Date.newInstance(2021, 1, 11);
            opgf2.Name = 'testone';
            insert opgf2;
            
            Applicant__c apgf2 = new Applicant__c();
            apgf2.Opportunity__c = opgf2.Id;
            apgf2.Contact_number__c = '9743514830';
            apgf2.Applicant_Type__c = 'Borrower';
            insert apgf2;
            
          /*  Vehicle_Detail__c vgf2 = new Vehicle_Detail__c();
            vgf2.Loan_Application__c = opgf2.Id;
            vgf2.Base_Price__c = 100000.00;
            vgf2.Ben_Code__c = 'testveh';
            insert vgf2;*/
            
            Test.startTest();
            IND_AssetDetailsCntrl.loadAssetDetailsData(opgf2.Id);
            Test.stopTest();
        }catch(Exception e){
            system.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void loadAssetDetailsDataTest2(){
        try{
            Opportunity opgf2 = new Opportunity();
            opgf2.StageName = 'Qualification';
            opgf2.Product_Type__c = 'Tractor';
            opgf2.CloseDate = Date.newInstance(2021, 1, 11);
            opgf2.Name = 'testone';
            insert opgf2;
            
            Applicant__c apgf2 = new Applicant__c();
            apgf2.Opportunity__c = opgf2.Id;
            apgf2.Contact_number__c = '9743514830';
            apgf2.Applicant_Type__c = 'Borrower';
            insert apgf2;
            
          /*  Vehicle_Detail__c vgf2 = new Vehicle_Detail__c();
            vgf2.Loan_Application__c = opgf2.Id;
            vgf2.Base_Price__c = 100000.00;
            vgf2.Ben_Code__c = 'testveh';
            insert vgf2;*/
            
            Test.startTest();
            IND_AssetDetailsCntrl.loadAssetDetailsData(opgf2.Id);
            Test.stopTest();
        }catch(Exception e){
            system.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void loadAssetDetailsDataTest(){
        try{
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            opp.Name = 'VDR Test';
            opp.StageName='Post Sanction Checks and Documentation';
            //opp.Product_Type__c='Tractor';
            opp.CVO_Accepts_SPDC_Documents__c = 'No';
            insert opp;
            
            Applicant__c applicant1 = TestDataUtility.createTestApplicatnt1(false);
            applicant1.Opportunity__c = opp.Id;
            applicant1.Applicant_Type__c='Borrower';
            applicant1.Who_will_repay_the_loan__c = 'Borrower';
            applicant1.Scorecard_Decision__c = 'Light Red';
            
            insert applicant1;
            
            Vehicle_Detail__c  vehicleDetail = TestDataUtility.createTestVehicleDetailForIbb(false, opp);
            vehicleDetail.Is_RC_Limit_Check_correctly_captured__c='No';
            vehicleDetail.Loan_Application__c = opp.Id;
            // vehicleDetail.Deal_Number__c=dl.Id;
            insert vehicleDetail;    
  
            Test.startTest();
            IND_AssetDetailsCntrl.loadAssetDetailsData(opp.Id);
            Test.stopTest();
            
        }catch(Exception e){
            System.assertEquals(e.getMessage(),'Script-thrown exception');
        }
    }
      
    @isTest
    public static void loadAssetDetailsDataTractorTest(){
        try{
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            opp.Name = 'VDR Test';
            opp.StageName='Post Sanction Checks and Documentation';
            opp.Product_Type__c='Tractor';
            opp.CVO_Accepts_SPDC_Documents__c = 'No';
            insert opp;
            
            Applicant__c applicant1 = TestDataUtility.createTestApplicatnt1(false);
            applicant1.Opportunity__c = opp.Id;
            applicant1.Applicant_Type__c='Borrower';
            applicant1.Who_will_repay_the_loan__c = 'Borrower';
            applicant1.Scorecard_Decision__c = 'Light Red';
            
            insert applicant1;
            
            Vehicle_Detail__c  vehicleDetail = TestDataUtility.createTestVehicleDetailForIbb(false, opp);
            vehicleDetail.Is_RC_Limit_Check_correctly_captured__c='No';
            vehicleDetail.Loan_Application__c = opp.Id;
            // vehicleDetail.Deal_Number__c=dl.Id;
            insert vehicleDetail;                
            Test.startTest();
            IND_AssetDetailsCntrl.loadAssetDetailsData(opp.Id);
            Test.stopTest();
            
        }catch(Exception e){
            //String error= e.getMessage()+ ' line Number is '+e.getLineNumber();
            //system.assertEquals('Script-thrown exception', error);
            System.assertEquals(e.getMessage(),'Script-thrown exception');
        }
    }
    
    @isTest
    public static void getDelayTimeTest(){
        try{
            Test.startTest();
            IND_AssetDetailsCntrl.getDelayTime();
            Test.stopTest();
        }catch(Exception e){
            system.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void getDealerSubDealerDetailsTest(){
        try{
            
            IND_AssetDetailsCntrl.AssetDetailsWrapper adw1 = new IND_AssetDetailsCntrl.AssetDetailsWrapper();
            adw1.vaahanAPIRetryCount = 2.0;
            adw1.dealMasterAPIRetryCount = 3.0;
            
            Set<String> makeSet = new Set<String>();
            makeSet.add('testone');
            makeSet.add('testtwo');
            
            Map<String,Set<String>> modelMap = new Map<String,Set<String>>();
            modelMap.put('test',makeSet);
            
            IND_AssetDetailsCntrl.MMVDataWrapper mdw1 = new IND_AssetDetailsCntrl.MMVDataWrapper();
            mdw1.make_mmv = makeSet;
            mdw1.model_mmv = modelMap;
            mdw1.variant_mmv = modelMap;
            
            
            Product2 pd1 = new Product2();
            pd1.Asset_Category__c = 'te';
            pd1.Name = 'book';
            pd1.Type__c = 'Model';
            pd1.External_Reference_Id__c = '58568568';
            insert pd1;
            
            Beneficiary_Product__c bp1 = new Beneficiary_Product__c();
            bp1.Name = 'testname';
            bp1.OwnerId = UserInfo.getUserId();
            bp1.Product__c = pd1.Id;
            bp1.Unique_Identifier__c = '678678';
            insert bp1;
            
            Opportunity oppObj = new Opportunity();
            oppObj.StageName = 'Qualification';
            oppObj.CloseDate = Date.newInstance(2021, 1, 11);
            oppObj.Name = 'testone';
            insert oppObj;
            
            Test.startTest();
            IND_AssetDetailsCntrl.getDealerSubDealerDetails('book',pd1.Name, oppObj.Id);
            IND_AssetDetailsCntrl.getDealerSubDealerDetails('book','test', oppObj.Id);
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void getMakeListTest(){
        try{
            Product2 pd2 = new Product2();
            pd2.Asset_Category__c = 'te';
            pd2.Capacity_1__c = 1000.00;
            pd2.Capacity_2__c = 1000.00;
            pd2.Name = 'book';
            pd2.Type__c = 'Make';
            pd2.External_Reference_Id__c = '58568568';
           // pd2.Product_Type__c='Two Wheeler';
            pd2.IsActive=true;
            insert pd2;
            
            Test.startTest();
            IND_AssetDetailsCntrl.getMakeList('PASSENGER VEHICLES','New',null);
            IND_AssetDetailsCntrl.getMakeList('PASSENGER VEHICLES','Used',null);
            IND_AssetDetailsCntrl.getMakeList('Two Wheeler','New','OLA');
            IND_AssetDetailsCntrl.getMakeList(Null,'New','OLA');
            IND_AssetDetailsCntrl.getMakeList(Null,'Used',null);


            // System.debug('makeList ----> '+makeList);    
            // System.Assert(makeList.isEmpty());
            Test.stopTest();
        }catch(Exception e){
            
        }
    }
    
    @isTest
    public static void getMakeListTest1(){
        try{
            Product2 pd2 = new Product2();
            pd2.Asset_Category__c = 'te';
            pd2.Capacity_1__c = 1000.00;
            pd2.Capacity_2__c = 1000.00;
            pd2.Name = 'book';
            pd2.Type__c = 'Make';
            pd2.External_Reference_Id__c = '58568568';
            insert pd2;
            
            Test.startTest();
            IND_AssetDetailsCntrl.getMakeList(pd2.Name,'123','OLA');
            IND_AssetDetailsCntrl.getMakeList(pd2.Name,'NEW',null);
            //System.debug('makeList ----> '+makeList);    
            // System.Assert(makeList.isEmpty());
            Test.stopTest();
        }catch(Exception e){
            // system.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void getRelatedModelListTest(){
        try{
            Segment__c seg = new Segment__c();
            seg.segment_code__c = 'MOPEDS';
            seg.Name = 'Test';
            insert seg;
            
            /*Product2 pp = new Product2();
pp.Asset_Category__c = 'te';
pp.Name = 'HONDACAR';
pp.Type__c = 'variant';
pp.IsActive = true;
pp.Make_Code__c = 'HONDACAR';
pp.Name = 'HONDACAR';
pp.Segment__c =seg.Id;
insert pp;*/
            
            Product2 pdr1 = new Product2();
            pdr1.Asset_Category__c = 'te';
            pdr1.Name = 'HONDACAR';
            pdr1.Type__c = 'variant';
            pdr1.IsActive = true;
            // pdr1.Parent_Product__c = pp.Id;
            pdr1.Emission_Norms__c ='BS6';
            pdr1.Segment__c = seg.Id;
            pdr1.External_Reference_Id__c = '58568789';
            insert pdr1;
            
            /* Product2 pdr2 = new Product2();
pdr2.Parent_Product__c = pdr1.Id;
pdr2.Asset_Category__c = 'te';
pdr2.Name = 'HONDA CITY';
pdr2.Type__c = 'Model';
pdr2.External_Reference_Id__c = '58568568';
insert pdr2;
*/     
            Test.startTest();
            IND_AssetDetailsCntrl.getRelatedModelList(pdr1.Name,'New','TW');
            IND_AssetDetailsCntrl.getRelatedModelList(pdr1.Name,'New','PV');
            IND_AssetDetailsCntrl.getRelatedModelList(null,'old','PV');
            IND_AssetDetailsCntrl.getRelatedModelList('OLA','New','TW');
            Test.stopTest();
            
        }catch(Exception e){
            //  system.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void getrelatedModelTestOla(){
        try{
            Segment__c segOla = new Segment__c();
            segOla.segment_code__c = 'ESCOOTER';
            segOla.Name = 'Test';
            insert segOla;
            
            Product2 olaPd1 = new Product2();
            olaPd1.Asset_Category__c = 'te';
            olaPd1.Name = 'OLA';
            olaPd1.Make_Code__c = 'OLA';
            olaPd1.Type__c = 'model';
            olaPd1.IsActive = true;
            // olaPd1.Parent_Product__c = pp.Id;
            olaPd1.Emission_Norms__c ='EV1';
            olaPd1.Segment__c = segOla.Id;
            olaPd1.External_Reference_Id__c = '58568789';
            insert olaPd1;
            
            Product2 olaPd2 = new Product2();
            olaPd2.Asset_Category__c = 'te';
            olaPd2.Name = 'OLA S1';
            olaPd2.Type__c = 'variant';
            olaPd2.IsActive = true;
            olaPd2.Parent_Product__c = olaPd1.Id;
            olaPd2.Emission_Norms__c ='EV1';
            olaPd2.External_Reference_Id__c = '58568788';
            insert olaPd2;
            
            Test.startTest();  
            IND_AssetDetailsCntrl.getRelatedModelList('OLA','New','TW');
            Test.stopTest();
        }catch(Exception e){
            //  system.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void getPicklistValuesTest(){
        try{
            
            //    IND_AssetDetailsCntrl.PicklistDataWrapper pdw1 = new IND_AssetDetailsCntrl.PicklistDataWrapper();
            //     pdw1.label = 'testone';
            //     pdw1.value = 'testval';
            
            List<String> picklistFieldList = new List<String> {'Purpose_of_purchase__c', 'Vehicle_registered_in_the_name_of__c', 'Usage_Type__c', 'Lien_in_favor_of__c', 'RC_retention_applicable__c', 'Number_of_ownerships__c'};
                IND_AssetDetailsCntrl.getPicklistValues('Vehicle_Detail__c',picklistFieldList);
            
        }Catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }  
    }
    
    @isTest
    public static void getRelatedVariantListTest(){
        try{
            Product2 pdv1 = new Product2();
            pdv1.Asset_Category__c = 'te';
            pdv1.Name = 'HONDACAR';
            pdv1.Type__c = 'Variant';
            pdv1.External_Reference_Id__c = '58568789';
            insert pdv1;    
            
            Product2 pdv2 = new Product2();
            pdv2.Parent_Product__c = pdv1.Id;
            pdv2.Asset_Category__c = 'te';
            pdv2.Name = 'HONDA CITY';
            pdv2.Type__c = 'Variant';
            pdv2.External_Reference_Id__c = '58568568';
            insert pdv2;
            
            Test.startTest();
            IND_AssetDetailsCntrl.getRelatedVariantList(pdv1.Name,'NEW');
            IND_AssetDetailsCntrl.getRelatedVariantList(pdv1.Name,'Used');
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void changeStageTest(){
        Account acc=new Account();
        acc.Name='testacc';
        insert acc;
        
        Opportunity opgd1 = new Opportunity();
        opgd1.StageName = 'Qualification';
        opgd1.CloseDate = Date.newInstance(2021, 1, 11);
        opgd1.Name = 'testone';
        opgd1.AccountId=acc.Id;
        insert opgd1;
        Test.startTest();
        IND_AssetDetailsCntrl.changeStage(opgd1.StageName ,opgd1.id);
        Test.stopTest();
    }
    
    @isTest
    public static void changeStageTest1(){
        Account acc=new Account();
        acc.Name='testacc';
        insert acc;
        
        Opportunity opgd1 = new Opportunity();
        opgd1.StageName = 'Qualification';
        opgd1.CloseDate = Date.newInstance(2021, 1, 11);
        opgd1.Name = 'testone';
        opgd1.AccountId=acc.Id;
        insert opgd1;
        
        try{
            IND_AssetDetailsCntrl.changeStage(opgd1.id,'Qualification');    
        }catch(Exception e){}
        
    }
    
    @isTest
    public static void validateDVehicleCategoryTest(){
        try{
            Product2 pd3 = new Product2();
            pd3.Asset_Category__c = 'te';
            pd3.Capacity_1__c = 1000.00;
            pd3.Capacity_2__c = 1000.00;
            pd3.Name = 'book';
            pd3.Type__c = 'Make';
            pd3.External_Reference_Id__c = '58568568';
            pd3.Asset_Category__c = 'D';
            insert pd3;
            
            Test.startTest();
            IND_AssetDetailsCntrl.validateDVehicleCategory(pd3.Name);
            IND_AssetDetailsCntrl.validateDVehicleCategory(null);
            Test.stopTest();
            
        }catch(Exception e){
            system.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void getMMVNameBasedOnCodeTest(){
        try{
            Product2 pdbc1 = new Product2();
            pdbc1.Asset_Category__c = 'A';
            pdbc1.Name = 'pen';
            pdbc1.Type__c = 'make';
            pdbc1.External_Reference_Id__c = 'Prod00000001';
            pdbc1.Make_Code__c = 'ALNISSAN';
            insert pdbc1;
            
            Product2 pdbc2 = new Product2();
            pdbc2.Asset_Category__c = 'D';
            pdbc2.Name = 'test';
            pdbc2.Model_Code__c = 'P665';
            pdbc2.Type__c = 'model';
            pdbc2.External_Reference_Id__c = '2';
            insert pdbc2;
            
            Product2 pdbc3 = new Product2();
            pdbc3.Asset_Category__c = 'B';
            pdbc3.Name = 'book';
            pdbc3.Variant_Code__c = 'HOND_CRV2';
            pdbc3.Type__c = 'variant';
            pdbc3.External_Reference_Id__c = '3';
            insert pdbc3;
            
            Test.startTest();
            IND_AssetDetailsCntrl.getMMVNameBasedOnCode(pdbc1.Make_Code__c,pdbc2.Model_Code__c,pdbc3.Variant_Code__c);
            // IND_AssetDetailsCntrl.getMMVNameBasedOnCode('test','test','test');
            Test.stopTest();
            
        }catch(Exception e){
            system.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void checkRCLimitBasedOnBencodeTest(){
        try{
            DSA_RC_Limit__c dsaObj = new DSA_RC_Limit__c();
            dsaObj.Max_Limit__c = 1;
            dsaObj.Ben_Code__c = 'DSA001234';
            insert dsaObj;
            
            Test.startTest();
            IND_AssetDetailsCntrl.checkRCLimitBasedOnBencode('DSA001234');
            
        }catch(Exception e){
            system.assertEquals('Script-thrown exception', e.getMessage());
        }
    } 
    
    /*@isTest
public static void createRecordUsingApexTest(){
try{
Opportunity opgf2 = new Opportunity();
opgf2.StageName = 'Qualification';
opgf2.CloseDate = Date.newInstance(2021, 1, 11);
opgf2.Name = 'testone';
insert opgf2;
Test.startTest();

IND_AssetDetailsCntrl.createRecordUsingApex('Vehicle_Detail__c','Loan_Application__c',opgf2.Id);

}catch(Exception e){
system.assertEquals('Script-thrown exception', e.getMessage());
}
} */
    @isTest
    public static void createRecordUsingApexTest1(){
        try{
            Opportunity opgf2 = new Opportunity();
            opgf2.StageName = 'Qualification';
            opgf2.CloseDate = Date.newInstance(2021, 1, 11);
            opgf2.Name = 'testone';
            insert opgf2;
            Test.startTest();
            Vehicle_Detail__c vehObj= new Vehicle_Detail__c();
            vehObj.Loan_Number__c = opgf2.Id;
            vehObj.Loan_Application__c = opgf2.Id;
            system.debug('vehObj'+vehObj);
            String jsonStr = JSON.serialize(vehObj);
            system.debug('vehObjjsonStr'+jsonStr);
            IND_AssetDetailsCntrl.createRecordUsingApex('Vehicle_Detail__c',jsonStr,opgf2.Id);
            
        }catch(Exception e){
            system.assertEquals('Script-thrown exception', e.getMessage());
        }
    } 
    
    @isTest
    public static void updateVehicleRecordsTest(){
        try{
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            opp.Name = 'VDR Test';
            opp.StageName='Post Sanction Checks and Documentation';
            //opp.Product_Type__c='Tractor';
            opp.CVO_Accepts_SPDC_Documents__c = 'No';
            insert opp;
            
            Applicant__c applicant1 = TestDataUtility.createTestApplicatnt1(false);
            applicant1.Opportunity__c = opp.Id;
            applicant1.Applicant_Type__c='Borrower';
            applicant1.Who_will_repay_the_loan__c = 'Borrower';
            applicant1.Scorecard_Decision__c = 'Light Red';
            
            insert applicant1;
            
            Vehicle_Detail__c  vehicleDetail = TestDataUtility.createTestVehicleDetailForIbb(false, opp);
            vehicleDetail.Is_RC_Limit_Check_correctly_captured__c='No';
            vehicleDetail.Loan_Application__c = opp.Id;
            // vehicleDetail.Deal_Number__c=dl.Id;
            insert vehicleDetail;   
            String vehicleDetailstr = JSON.serialize(vehicleDetail);
  
            Test.startTest();
            IND_AssetDetailsCntrl.updateVehicleRecords(vehicleDetailstr,opp.Id);
            Test.stopTest();
            
        }catch(Exception e){
            System.assertEquals(e.getMessage(),'Script-thrown exception');
        }
    }
      
    
}