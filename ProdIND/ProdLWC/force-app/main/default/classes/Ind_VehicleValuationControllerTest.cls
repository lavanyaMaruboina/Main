@isTest
public class Ind_VehicleValuationControllerTest {
    
    @isTest
    public static void getVehicleValuationDetailsTest(){
        try{
            Opportunity opgv2 = new Opportunity();
            opgv2.StageName = 'Qualification';
            opgv2.CloseDate = Date.newInstance(2021, 1, 11);
            opgv2.Name = 'testone';
            opgv2.Loan_amount__c = '100000';
            opgv2.Product_Type__c = 'Two Wheeler';
            opgv2.Vehicle_Sub_Category__c = 'testtwo';
            opgv2.Vehicle_Type__c = 'testmotor';
            opgv2.Required_Tenure__c = 8;
            insert opgv2;
            
            Applicant__c apgv2 = new Applicant__c();
            apgv2.Opportunity__c = opgv2.Id;
            apgv2.Contact_number__c = '9743514830';
            apgv2.Applicant_Type__c = 'Borrower';
            insert apgv2;
            
            Vehicle_Detail__c vg2 = new Vehicle_Detail__c();
            vg2.Loan_Application__c = opgv2.Id;
            vg2.Base_Price__c = 100000.00;
            vg2.Ben_Code__c = 'testveh';
            insert vg2; 
            
            Documents__c dsd2 = new Documents__c();
            dsd2.Vehicle_Detail__c = vg2.Id;
            dsd2.Applicant__c = apgv2.Id;
            dsd2.Opportunity_Relation__c = opgv2.Id;
            dsd2.Document_Type__c = 'Vehicle Image';
            dsd2.Document_Side__c ='Back';
            dsd2.Aadhar_Source__c = 'ScanAadhar';
            dsd2.Name = 'Vehicle Image';
            insert dsd2;
            
            Test.startTest();
            String result = Ind_VehicleValuationController.getVehicleValuationDetails(opgv2.Id,vg2.Id);
            System.assert(String.isNotBlank(result));
            result = Ind_VehicleValuationController.getVehicleValuationDetails(null,null);
            System.assert(String.isBlank(result));
            Test.stopTest();            
        }catch(Exception e){
            system.Debug('Here error: '+ e);
        }
    }
    
     @isTest
    public static void getVehicleValuationDetailsTest2(){
        try{
            Opportunity opgv2 = new Opportunity();
            opgv2.StageName = 'Qualification';
            opgv2.CloseDate = Date.newInstance(2021, 1, 11);
            opgv2.Name = 'testone';
            opgv2.Loan_amount__c = '100000';
            opgv2.Product_Type__c = 'Two Wheeler';
            opgv2.Vehicle_Sub_Category__c = 'testtwo';
            opgv2.Vehicle_Type__c = 'testmotor';
            opgv2.Required_Tenure__c = 8;
            insert opgv2;
            
            Applicant__c apgv2 = new Applicant__c();
            apgv2.Opportunity__c = opgv2.Id;
            apgv2.Contact_number__c = '9743514830';
            apgv2.Applicant_Type__c = 'Borrower';
            insert apgv2;
            
            Vehicle_Detail__c vg2 = new Vehicle_Detail__c();
            vg2.Loan_Application__c = opgv2.Id;
            vg2.Base_Price__c = 100000.00;
            vg2.Ben_Code__c = 'testveh';
            insert vg2; 
            
            Documents__c dsd2 = new Documents__c();
            dsd2.Vehicle_Detail__c = vg2.Id;
            dsd2.Applicant__c = apgv2.Id;
            dsd2.Opportunity_Relation__c = opgv2.Id;
            dsd2.Document_Type__c = 'Vehicle RC Copy';
            dsd2.Document_Side__c ='Back';
            dsd2.Aadhar_Source__c = 'ScanAadhar';
            dsd2.Name = 'Vehicle RC Copy';
            insert dsd2;
            
            Test.startTest();
            String result = Ind_VehicleValuationController.getVehicleValuationDetails(opgv2.Id,vg2.Id);
            System.assert(String.isNotBlank(result));
            result = Ind_VehicleValuationController.getVehicleValuationDetails(null,null);
            System.assert(String.isBlank(result));
            Test.stopTest();            
        }catch(Exception e){
            system.Debug('Here error: '+ e);
        }
    }
    
    @isTest
    public static void getVehicleValuationDetailsTest1(){
        try{
            Opportunity opgv3 = new Opportunity();
            opgv3.StageName = 'Qualification';
            opgv3.CloseDate = Date.newInstance(2021, 1, 11);
            opgv3.Name = 'testone';
            opgv3.Loan_amount__c = '100000';
            opgv3.Product_Type__c = 'Two Wheeler';
            opgv3.Vehicle_Sub_Category__c = 'testtwo';
            opgv3.Vehicle_Type__c = 'testmotor';
            opgv3.Required_Tenure__c = 8;
            insert opgv3;
            
            Vehicle_Detail__c vg2 = new Vehicle_Detail__c();
            vg2.Loan_Application__c = opgv3.Id;
            vg2.Base_Price__c = 100000.00;
            vg2.Ben_Code__c = 'testveh';
            insert vg2;
            
            Test.startTest();
            String result = Ind_VehicleValuationController.getVehicleValuationDetails(opgv3.Id,vg2.Id);
            System.assert(String.isNotBlank(result));
            Test.stopTest();
            
        }catch(Exception e){
            system.Debug('Here error: '+ e);
        }
    }
    
    @isTest
    public static void checkVehicleDocumentsDetailsTest(){
        try{
            Opportunity opcv1 = new Opportunity();
            opcv1.StageName = 'Qualification';
            opcv1.CloseDate = Date.newInstance(2021, 1, 11);
            opcv1.Name = 'testone';
            opcv1.Loan_amount__c = '100000';
            opcv1.Product_Type__c = 'Two Wheeler';
            opcv1.Vehicle_Sub_Category__c = 'testtwo';
            opcv1.Vehicle_Type__c = 'testmotor';
            opcv1.Required_Tenure__c = 8;
            insert opcv1;
            
            Applicant__c apcv2 = new Applicant__c();
            apcv2.Opportunity__c = opcv1.Id;
            apcv2.Contact_number__c = '9743514830';
            apcv2.Applicant_Type__c = 'Borrower';
            insert apcv2;
            
            Vehicle_Detail__c vc2 = new Vehicle_Detail__c();
            vc2.Loan_Application__c = opcv1.Id;
            vc2.Base_Price__c = 100000.00;
            vc2.Ben_Code__c = 'testveh';
            insert vc2; 
            
            Documents__c dscv2 = new Documents__c();
            dscv2.Vehicle_Detail__c = vc2.Id;
            dscv2.Applicant__c = apcv2.Id;
            dscv2.Opportunity_Relation__c = opcv1.Id;
            dscv2.Document_Type__c = 'RC Document';
            dscv2.Document_Side__c ='Back';
            dscv2.Aadhar_Source__c = 'ScanAadhar';
            dscv2.Is_Photocopy__c = true;
            insert dscv2;
            
            
            Test.startTest();
            String result = Ind_VehicleValuationController.checkVehicleDocumentsDetails(opcv1.Id);
            System.assert(String.isNotBlank(result));
            
            result = Ind_VehicleValuationController.checkVehicleDocumentsDetails(null);
            System.assert(String.isBlank(result));
            Test.stopTest();
            
        }catch(Exception e){
            system.Debug('Here error: '+ e);
        }
    }
    
    @isTest
    public static void checkVehicleDocumentsDetailsTest1(){
        try{
            Opportunity opcv1 = new Opportunity();
            opcv1.StageName = 'Qualification';
            opcv1.CloseDate = Date.newInstance(2021, 1, 11);
            opcv1.Name = 'testone';
            opcv1.Loan_amount__c = '100000';
            opcv1.Product_Type__c = 'Two Wheeler';
            opcv1.Vehicle_Sub_Category__c = 'testtwo';
            opcv1.Vehicle_Type__c = 'testmotor';
            opcv1.Required_Tenure__c = 8;
            insert opcv1;
            
            Applicant__c apcv2 = new Applicant__c();
            apcv2.Opportunity__c = opcv1.Id;
            apcv2.Contact_number__c = '9743514830'; 
            apcv2.Applicant_Type__c = 'Borrower';
            insert apcv2;
            
            Vehicle_Detail__c vc2 = new Vehicle_Detail__c();
            vc2.Loan_Application__c = opcv1.Id;
            vc2.Base_Price__c = 100000.00;
            vc2.Ben_Code__c = 'testveh';
            insert vc2; 
            
            Documents__c dscv2 = new Documents__c();
            dscv2.Vehicle_Detail__c = vc2.Id;
            dscv2.Applicant__c = apcv2.Id;
            dscv2.Opportunity_Relation__c = opcv1.Id;
            dscv2.Document_Type__c = 'Vehicle Insurance Policy';
            dscv2.Document_Side__c ='Back';
            dscv2.Aadhar_Source__c = 'ScanAadhar';
            dscv2.Is_Photocopy__c = true;
            insert dscv2;
            
            
            Test.startTest();
            String result = Ind_VehicleValuationController.checkVehicleDocumentsDetails(opcv1.Id);
            System.assert(String.isNotBlank(result));
            Test.stopTest();
            
        }catch(Exception e){
            system.Debug('Here error: '+ e);
        }
    }
    
    @isTest
    public static void checkVehicleDocumentsDetailsTest2(){
        try{
            Opportunity opd3 = new Opportunity();
            opd3.StageName = 'Qualification';
            opd3.CloseDate = Date.newInstance(2021, 1, 11);
            opd3.Name = 'testone';
            opd3.Loan_amount__c = '100000';
            opd3.Product_Type__c = 'Two Wheeler';
            opd3.Vehicle_Sub_Category__c = 'testtwo';
            opd3.Vehicle_Type__c = 'testmotor';
            opd3.Required_Tenure__c = 8;
            insert opd3;
            
            Test.startTest();
            String result = Ind_VehicleValuationController.checkVehicleDocumentsDetails(opd3.Id);
            System.assert(String.isNotBlank(result));
            Test.stopTest();
            
        }catch(Exception e){
            system.Debug('Here error: '+ e);
        }
    }
    
    @isTest
    public static void checkIBBAPIAttemptsTest(){
        try{
            Opportunity opcv1 = new Opportunity();
            opcv1.StageName = 'Qualification';
            opcv1.CloseDate = Date.newInstance(2021, 1, 11);
            opcv1.Name = 'testone';
            opcv1.Loan_amount__c = '100000';
            opcv1.Product_Type__c = 'Two Wheeler';
            opcv1.Vehicle_Sub_Category__c = 'testtwo';
            opcv1.Vehicle_Type__c = 'testmotor';
            opcv1.Required_Tenure__c = 8;
            insert opcv1;
            
            Applicant__c apcv2 = new Applicant__c();
            apcv2.Opportunity__c = opcv1.Id;
            apcv2.Contact_number__c = '9743514830';
            apcv2.Applicant_Type__c = 'Borrower';
            insert apcv2;
            
            Vehicle_Detail__c vc2 = new Vehicle_Detail__c();
            vc2.Loan_Application__c = opcv1.Id;
            vc2.Base_Price__c = 100000.00;
            vc2.Ben_Code__c = 'testveh';
            vc2.IBB_Internal_API_Attempts__c = 5;
            insert vc2; 
            
            Test.startTest();
            String result = Ind_VehicleValuationController.checkIBBAPIAttempts(opcv1.Id);
            System.assert(String.isNotBlank(result));
            result = Ind_VehicleValuationController.checkIBBAPIAttempts(null);
            System.assert(String.isBlank(result));
            Test.stopTest();
            
        }catch(Exception e){
            system.Debug('Here error: '+ e);
        }
    }
    
    @isTest
    public static void checkIBBAPIAttemptsTest1(){
        try{
            Opportunity opcv1 = new Opportunity();
            opcv1.StageName = 'Qualification';
            opcv1.CloseDate = Date.newInstance(2021, 1, 11);
            opcv1.Name = 'testone';
            opcv1.Loan_amount__c = '100000';
            opcv1.Product_Type__c = 'Two Wheeler';
            opcv1.Vehicle_Sub_Category__c = 'testtwo';
            opcv1.Vehicle_Type__c = 'testmotor';
            opcv1.Required_Tenure__c = 8;
            insert opcv1;
            
            Applicant__c apcv2 = new Applicant__c();
            apcv2.Opportunity__c = opcv1.Id;
            apcv2.Contact_number__c = '9743514830';
            apcv2.Applicant_Type__c = 'Borrower';
            insert apcv2;
            
            Vehicle_Detail__c vc2 = new Vehicle_Detail__c();
            vc2.Loan_Application__c = opcv1.Id;
            vc2.Base_Price__c = 100000.00;
            vc2.Ben_Code__c = 'testveh';
            vc2.IBB_Internal_API_Attempts__c = null;
            insert vc2; 
            
            Test.startTest();
            String result =    Ind_VehicleValuationController.checkIBBAPIAttempts(opcv1.Id);
            System.assert(String.isNotBlank(result));
            Test.stopTest();
            
        }catch(Exception e){
            system.Debug('Here error: '+ e);
        }
    }
    
    @isTest
    public static void checkIBBAPIAttemptsTest2(){
        try{
            Opportunity opcv3 = new Opportunity();
            opcv3.StageName = 'Qualification';
            opcv3.CloseDate = Date.newInstance(2021, 1, 11);
            opcv3.Name = 'testone';
            opcv3.Loan_amount__c = '100000';
            opcv3.Product_Type__c = 'Two Wheeler';
            opcv3.Vehicle_Sub_Category__c = 'testtwo';
            opcv3.Vehicle_Type__c = 'testmotor';
            opcv3.Required_Tenure__c = 8;
            insert opcv3;
            
            Test.startTest();
            String result = Ind_VehicleValuationController.checkIBBAPIAttempts(opcv3.Id);
            System.assert(String.isNotBlank(result));
            Test.stopTest();
            
        }catch(Exception e){
            system.Debug('Here error: '+ e);
        }
    }
    
    @isTest
    public static void getPicklistValuesForValuerTest(){
        Test.startTest();
        List<Beneficiary_Category__c>  lstResults = Ind_VehicleValuationController.getPicklistValuesForValuer();
        System.assert(lstResults.isEmpty());
        Test.stopTest();
    }
    
    @isTest
    public static void setOEMFlagTest(){
        try{
            Opportunity opcv1 = new Opportunity();
            opcv1.StageName = 'Qualification';
            opcv1.CloseDate = Date.newInstance(2021, 1, 11);
            opcv1.Name = 'testone';
            opcv1.Loan_amount__c = '100000';
            opcv1.Product_Type__c = 'Two Wheeler';
            opcv1.Vehicle_Sub_Category__c = 'testtwo';
            opcv1.Vehicle_Type__c = 'testmotor';
            opcv1.Required_Tenure__c = 8;
            insert opcv1;
            
            Applicant__c apcv2 = new Applicant__c();
            apcv2.Opportunity__c = opcv1.Id;
            apcv2.Contact_number__c = '9743514830';
            apcv2.Applicant_Type__c = 'Borrower';
            insert apcv2;
            
            Vehicle_Detail__c vc2 = new Vehicle_Detail__c();
            vc2.Loan_Application__c = opcv1.Id;
            vc2.Base_Price__c = 100000.00;
            vc2.Ben_Code__c = 'testveh';
            vc2.IBB_Internal_API_Attempts__c = null;
            vc2.Dealer_Sub_dealer_name__c = 'testsubdealer';
            vc2.OEM_Dealer__c = true;
            insert vc2; 
            
            Benefi__c bn1 = new Benefi__c();
            bn1.Ben_code__c = 'AGCCAR010';
            bn1.Name = 'M.G BROTHERS AUTOMOBILIES PVT LTD';
            bn1.Beneficiary__c = 'DLR';
            bn1.Dealer_Code__c = 'testres';
            bn1.Status_Flag__c = 'L';
            insert bn1;
            
            Manufacturer__c mf1 = new Manufacturer__c();
            mf1.Name = 'sampres';
            mf1.Manufacturer_code__c = 'U01';
            mf1.OwnerId = UserInfo.getUserId();
            insert mf1;            
            
            Beneficiary_Manufacturer__c bm1 = new Beneficiary_Manufacturer__c();
            bm1.Beneficiary_Master__c = bn1.Id;
            bm1.Manufacturer__c = mf1.Id;
            bm1.Name = 'sampres';
            bm1.Unique_Identifier__c = 'BEN201552-M31';
            bm1.OwnerId = UserInfo.getUserId();
            insert bm1;
            
            
            Test.startTest();
            Boolean result = Ind_VehicleValuationController.setOEMFlag(opcv1.Id,bn1.Ben_code__c,vc2.Id);
            Boolean result1 = Ind_VehicleValuationController.setOEMFlag(opcv1.Id,'BEN10101',vc2.Id);
         //   System.assert(result == false);
            Test.stopTest();
            
        }catch(Exception e){
            system.Debug('Here error: '+ e);
        }
    }
    
    @isTest
    public static void setOEMFlagTest1(){
        try{
            Opportunity opcv2 = new Opportunity();
            opcv2.StageName = 'Qualification';
            opcv2.CloseDate = Date.newInstance(2021, 1, 11);
            opcv2.Name = 'testone';
            opcv2.Loan_amount__c = '100000';
            opcv2.Product_Type__c = 'Two Wheeler';
            opcv2.Vehicle_Sub_Category__c = 'testtwo';
            opcv2.Vehicle_Type__c = 'testmotor';
            opcv2.Required_Tenure__c = 8;
            insert opcv2;
            
            Vehicle_Detail__c vc2 = new Vehicle_Detail__c();
            vc2.Loan_Application__c = opcv2.Id;
            vc2.Base_Price__c = 100000.00;
            vc2.Ben_Code__c = 'testveh';
            vc2.IBB_Internal_API_Attempts__c = null;
            vc2.Dealer_Sub_dealer_name__c = 'testsubdealer';
            vc2.OEM_Dealer__c = true;
            insert vc2;
            
            Test.startTest();
            Boolean result = Ind_VehicleValuationController.setOEMFlag(opcv2.Id,'BEN10101',vc2.Id);
        //    System.assert(result);
            Test.stopTest();
            
        }catch(Exception e){
            system.Debug('Here error: '+ e);
        }
    }
    
    @isTest
    public static void fetchGridValueTest(){
        try{
                Product2 prd1 = new Product2();
                prd1.Asset_Category__c = 'te';
                prd1.Capacity_1__c = 1000.00;
                prd1.Capacity_2__c = 2000.00;
                prd1.Capacity_Units_1__c = 'test12';
                prd1.Capacity_Units_2__c = 'test13';
                prd1.Type__c = 'Variant';
                prd1.External_Reference_Id__c = '58568568';
                prd1.Name = 'test';
                insert prd1;
            
                Test.startTest();
                      Ind_VehicleValuationController.fetchGridValue(1,prd1.Name);
                      Ind_VehicleValuationController.fetchGridValue(2,prd1.Name);
                      Ind_VehicleValuationController.fetchGridValue(3,prd1.Name);
                      Ind_VehicleValuationController.fetchGridValue(4,prd1.Name);
                      Ind_VehicleValuationController.fetchGridValue(5,prd1.Name);
                      Ind_VehicleValuationController.fetchGridValue(6,prd1.Name);
                      Ind_VehicleValuationController.fetchGridValue(7,prd1.Name);
                      Ind_VehicleValuationController.fetchGridValue(8,prd1.Name);
                      Ind_VehicleValuationController.fetchGridValue(9,prd1.Name);
                      Ind_VehicleValuationController.fetchGridValue(10,prd1.Name);
                      Ind_VehicleValuationController.fetchGridValue(11,prd1.Name);
                      Ind_VehicleValuationController.fetchGridValue(12,prd1.Name);
                      Ind_VehicleValuationController.fetchGridValue(0,prd1.Name);
                      Ind_VehicleValuationController.fetchGridValue(0,null);
                      Ind_VehicleValuationController.fetchGridValue(null,null);
                Test.stopTest();
            
        }catch(Exception e){
             System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void getMFCCityStateDetailsTest1(){
        try{
               MFC_State_Master__c ms1 = new MFC_State_Master__c();
               ms1.State_Code__c = '1';
               insert ms1;
            
                MFC_City_Master__c mf1 = new MFC_City_Master__c();
                mf1.City_Code__c = '1';
                mf1.Name = 'test';
                insert mf1;
            
                Test.startTest();
                    Ind_VehicleValuationController.getMFCCityStateDetails(ms1.Id,mf1.Id);
                    Ind_VehicleValuationController.getMFCCityStateDetails(null,null);
                    Ind_VehicleValuationController.getMFCCityStateDetails('test','test');
                Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
        
    }
        @isTest
        public static void testgetVehicleValuationDetailsForTractor(){
 
            Opportunity opgv2 = new Opportunity();
            opgv2.StageName = 'Qualification';
            opgv2.CloseDate = Date.newInstance(2021, 1, 11);
            opgv2.Name = 'testone';
            opgv2.Loan_amount__c = '100000';
            opgv2.Product_Type__c = 'Tractor';
            opgv2.Vehicle_Sub_Category__c = 'testtwo';
            opgv2.Vehicle_Type__c = 'testmotor';
            opgv2.Required_Tenure__c = 8;
            insert opgv2;
            
            Applicant__c apgv2 = new Applicant__c();
            apgv2.Opportunity__c = opgv2.Id;
            apgv2.Contact_number__c = '9743514830';
            apgv2.Applicant_Type__c = 'Borrower';
            insert apgv2;
            
            Vehicle_Detail__c vg2 = new Vehicle_Detail__c();
            vg2.Loan_Application__c = opgv2.Id;
            vg2.Base_Price__c = 100000.00;
            vg2.Ben_Code__c = 'testveh';
            insert vg2; 
            
            Documents__c dsd2 = new Documents__c();
            dsd2.Vehicle_Detail__c = vg2.Id;
            dsd2.Applicant__c = apgv2.Id;
            dsd2.Opportunity_Relation__c = opgv2.Id;
            dsd2.Document_Type__c = 'Vehicle Image';
            dsd2.Document_Side__c ='Back';
            dsd2.Aadhar_Source__c = 'ScanAadhar';
            dsd2.Name = 'Vehicle Image';
            insert dsd2;
            
            Test.startTest();
            String result = Ind_VehicleValuationController.getVehicleValuationDetailsForTractor(opgv2.Id,vg2.Id); 
            //System.assert(String.isNotBlank(result));
            result = Ind_VehicleValuationController.getVehicleValuationDetailsForTractor(null,null);
            //System.assert(String.isBlank(result));
            Ind_VehicleValuationController.getMFCUniqueResponse('1234567891');
            Ind_VehicleValuationController.saveMFCResponseRecord('1234567891','test');
            Ind_VehicleValuationController.getParentLeadNumber('1234567891');
            Test.stopTest();            
    }
    
     @isTest
    public static void fetchGridValueForTractorTest(){
        
            Opportunity opgv2 = new Opportunity();
            opgv2.StageName = 'Qualification';
            opgv2.CloseDate = Date.newInstance(2021, 1, 11);
            opgv2.Name = 'testone';
            opgv2.Loan_amount__c = '100000';
            opgv2.Product_Type__c = 'Tractor';
            opgv2.Vehicle_Sub_Category__c = 'testtwo';
            opgv2.Vehicle_Type__c = 'testmotor';
            opgv2.Required_Tenure__c = 8;
            opgv2.Agent_BL_code__c = 'A2';
            insert opgv2;
            
                Product2 prd1 = new Product2();
                prd1.Asset_Category__c = 'te';
                prd1.Capacity_1__c = 1000.00;
                prd1.Capacity_2__c = 2000.00;
                prd1.Capacity_Units_1__c = 'test12';
                prd1.Capacity_Units_2__c = 'test13';
                prd1.Type__c = 'Variant';
                prd1.External_Reference_Id__c = '58568568';
                prd1.Name = 'test';
            
                insert prd1;
        
        TBM_Business_Location_Dt__c  businessLocationList =new TBM_Business_Location_Dt__c();
        businessLocationList.State_Code__c='S';
        businessLocationList.Product__c='T';
        businessLocationList.Bl_Code__c='A2';
        businessLocationList.BL_Name__c='test';
        insert businessLocationList;
            
        list<TBM_Product_Variant_dt__c>TbmProductVariantlist =  new list<TBM_Product_Variant_dt__c>();
        
        TBM_Product_Variant_dt__c tbm= new TBM_Product_Variant_dt__c();
        tbm.Product_Variant_Code__c='test1';
        tbm.State_Code__c='S';
        tbm.Market_Value_1year__c = 10000;
        TbmProductVariantlist.add(tbm);

        insert TbmProductVariantlist;
        
        Test.startTest();
        	Ind_VehicleValuationController.fetchGridValueForTractor(opgv2.id,1,TbmProductVariantlist[0].Product_Variant_Code__c);
            Ind_VehicleValuationController.fetchGridValueForTractor(opgv2.id,2,TbmProductVariantlist[0].Product_Variant_Code__c);
            Ind_VehicleValuationController.fetchGridValueForTractor(opgv2.id,3,TbmProductVariantlist[0].Product_Variant_Code__c);
            Ind_VehicleValuationController.fetchGridValueForTractor(opgv2.id,4,TbmProductVariantlist[0].Product_Variant_Code__c);
            Ind_VehicleValuationController.fetchGridValueForTractor(opgv2.id,5,TbmProductVariantlist[0].Product_Variant_Code__c);
            Ind_VehicleValuationController.fetchGridValueForTractor(opgv2.id,6,TbmProductVariantlist[0].Product_Variant_Code__c);
            Ind_VehicleValuationController.fetchGridValueForTractor(opgv2.id,7,TbmProductVariantlist[0].Product_Variant_Code__c);
            Ind_VehicleValuationController.fetchGridValueForTractor(opgv2.id,8,TbmProductVariantlist[0].Product_Variant_Code__c);
            Ind_VehicleValuationController.fetchGridValueForTractor(opgv2.id,9,TbmProductVariantlist[0].Product_Variant_Code__c);
            Ind_VehicleValuationController.fetchGridValueForTractor(opgv2.id,10,TbmProductVariantlist[0].Product_Variant_Code__c);
            Ind_VehicleValuationController.fetchGridValueForTractor(opgv2.id,11,TbmProductVariantlist[0].Product_Variant_Code__c);
         	Ind_VehicleValuationController.fetchGridValueForTractor(opgv2.id,12,TbmProductVariantlist[0].Product_Variant_Code__c);
        	Ind_VehicleValuationController.fetchGridValueForTractor(opgv2.id,13,TbmProductVariantlist[0].Product_Variant_Code__c);
        	Ind_VehicleValuationController.fetchGridValueForTractor(opgv2.id,14,TbmProductVariantlist[0].Product_Variant_Code__c);
        	Ind_VehicleValuationController.fetchGridValueForTractor(opgv2.id,15,TbmProductVariantlist[0].Product_Variant_Code__c);
        	Ind_VehicleValuationController.fetchGridValueForTractor(opgv2.id,16,TbmProductVariantlist[0].Product_Variant_Code__c);
            Ind_VehicleValuationController.fetchGridValueForTractor(opgv2.id,17,TbmProductVariantlist[0].Product_Variant_Code__c);
        	Ind_VehicleValuationController.fetchGridValueForTractor(opgv2.id,18,TbmProductVariantlist[0].Product_Variant_Code__c);
        	Ind_VehicleValuationController.fetchGridValueForTractor(opgv2.id,19,TbmProductVariantlist[0].Product_Variant_Code__c);
        	Ind_VehicleValuationController.fetchGridValueForTractor(opgv2.id,20,TbmProductVariantlist[0].Product_Variant_Code__c);
        	Ind_VehicleValuationController.fetchGridValueForTractor(opgv2.id,0,TbmProductVariantlist[0].Product_Variant_Code__c);
        Test.stopTest();
    }
}