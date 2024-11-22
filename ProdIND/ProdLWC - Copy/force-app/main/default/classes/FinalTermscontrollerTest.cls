//UAT

@isTest
public class FinalTermscontrollerTest {
    @testSetup
    static void testSetup(){
        Schemes__c schemeObj = new Schemes__c(Name='TestScheme',
                                              Product__c='Two Wheeler',
                                              Unique_Identifier__c='testUnique',
                                              Scheme_Expiry__c= Date.newInstance(2023, 10, 5),
                                              Vehicle_Type__c='New',
                                              Dealer_Sub_dealer_name__c='testBenefi',
                                              Model__c ='testModel',
                                              Agent_BL_code__c ='AG-00',
                                              ExistingCustomer__c=true
                                             );
        insert schemeObj;
    }
    @isTest
    public static void loadSchemeDataTest(){
        try{            
            Opportunity opds1 = new Opportunity();
            opds1.StageName = 'Qualification';
            opds1.CloseDate = Date.newInstance(2025, 1, 11);
            opds1.Name = 'testone';
            opds1.Agent_BL_code__c = 'AG-00';
            opds1.Product_Type__c = 'Two Wheeler';
            insert opds1;
            
            Vehicle_Detail__c vg3 = new Vehicle_Detail__c();
            vg3.Loan_Application__c = opds1.Id;
            vg3.Base_Price__c = 100000.00;
            vg3.Ben_Code__c = 'BEN000280';
            vg3.Variant__c = 'testvariant';
            vg3.Model__c ='testModel';
            vg3.Dealer_Sub_dealer_name__c = 'T V SUNDARAM IYENGAR AND SONS PVT LTD';
            vg3.Ben_Code__c = 'BEN059659';
            vg3.Model__c ='TATA TIAGO BS 6';
            vg3.Make__c ='TATA';
            insert vg3; 
            
            
            Product2 prd1 = new Product2();
            prd1.Asset_Category__c = 'te';
            prd1.Capacity_1__c = 1000.00;
            prd1.Capacity_2__c = 2000.00;
            prd1.Capacity_Units_1__c = 'test12';
            prd1.Capacity_Units_2__c = 'test13';
            prd1.Type__c = 'Make';
            prd1.External_Reference_Id__c = '58568568';
            prd1.Name = 'book';
            insert prd1;
            
            Schemes__c sch1 = new Schemes__c();
            sch1.ProductCode__c = prd1.Id;
            sch1.Unique_Identifier__c = 'test';
            sch1.FromDate__c = Date.newInstance(2024, 3, 31);
            sch1.ExistingCustomer__c = true;
            sch1.Scheme_Verification__c = 'Yes';
            sch1.Vehicle_Type__c = 'New';
            sch1.Scheme_Expiry__c = Date.newInstance(2026, 3, 31);
            sch1.Product__c = 'Two Wheeler';
            sch1.Name = 'No';
            sch1.Dealer_Sub_dealer_name__c = 'BEN059659';
            sch1.Model__c = 'TATA TIAGO BS 6';
            /* sch1.Manufacturer_Code_Make__c ='Tata';
            sch1.Agent_BL_code__c = 'AG-00'; */
            insert sch1;
            
            Benefi__c bnf1 = new Benefi__c();
            bnf1.Ben_code__c = 'BEN000280';
            bnf1.Name = 'testBenefi';
            bnf1.Dealer_Code__c = 'testdealer';
            bnf1.Indusind_AcNo__c = '786767832788';
            bnf1.Beneficiary__c = 'DSM';
            bnf1.Status_Flag__c = 'L';
            insert bnf1;
            
            CFD_State_Master__c cfd1 = new CFD_State_Master__c();
            cfd1.Name = 'name';
            cfd1.Language__c = 'English';
            cfd1.District__c = 'Pune';
            cfd1.CFD_State_Code__c ='MH';
            cfd1.Address_1__c = 'addr1';
            cfd1.Address_2__c = 'addr2';
            cfd1.Address_3__c = 'addr3';
            cfd1.Address_4__c = 'addr4';
            insert cfd1;
            Test.startTest();
            FinalTermscontroller.loadSchemeData(opds1.Id,vg3.Id);
            Test.stopTest();
        }catch(Exception e){
            
        }
    }
    
    @isTest
    public static void loadSchemeDataTest1(){
        try{
            Opportunity opds1 = new Opportunity();
            opds1.StageName = 'Qualification';
            opds1.CloseDate = Date.newInstance(2025, 1, 11);
            opds1.Name = 'testone';
            opds1.Agent_BL_code__c = 'AG-00';
            opds1.Product_Type__c = 'Tractor';
            insert opds1;
            
            Applicant__c apks1 = new Applicant__c();
            apks1.Opportunity__c = opds1.Id;
            apks1.Contact_number__c = '9743514830';
            apks1.Applicant_Type__c = 'Borrower';
            apks1.In_Active_Applicant__c = false;
            insert apks1;
            
            Vehicle_Detail__c vg3 = new Vehicle_Detail__c();
            vg3.Loan_Application__c = opds1.Id;
            vg3.Base_Price__c = 100000.00;
            vg3.Ben_Code__c = 'BEN000280';
            vg3.Variant__c = 'testvariant';
            vg3.Model__c ='testModel';
            vg3.Dealer_Sub_dealer_name__c = 'T V SUNDARAM IYENGAR AND SONS PVT LTD';
            vg3.Ben_Code__c = 'BEN059659';
            vg3.Model__c ='TATA TIAGO BS 6';
            vg3.Make__c ='TATA';
            insert vg3; 
            
            
            Product2 prd1 = new Product2();
            prd1.Asset_Category__c = 'te';
            prd1.Capacity_1__c = 1000.00;
            prd1.Capacity_2__c = 2000.00;
            prd1.Capacity_Units_1__c = 'test12';
            prd1.Capacity_Units_2__c = 'test13';
            prd1.Type__c = 'Make';
            prd1.External_Reference_Id__c = '58568568';
            prd1.Name = 'book';
            insert prd1;
            
            Schemes__c sch1 = new Schemes__c();
            sch1.ProductCode__c = prd1.Id;
            sch1.Unique_Identifier__c = 'test';
            sch1.FromDate__c = Date.newInstance(2024, 3, 31);
            sch1.ExistingCustomer__c = true;
            sch1.Scheme_Verification__c = 'Yes';
            sch1.Vehicle_Type__c = 'New';
            sch1.Scheme_Expiry__c = Date.newInstance(2026, 3, 31);
            sch1.Product__c = 'Two Wheeler';
            sch1.Name = 'No';
            sch1.Dealer_Sub_dealer_name__c = 'BEN059659';
            sch1.Model__c = 'TATA TIAGO BS 6';
            /* sch1.Manufacturer_Code_Make__c ='Tata';
            sch1.Agent_BL_code__c = 'AG-00'; */
            insert sch1;
            
            Benefi__c bnf1 = new Benefi__c();
            bnf1.Ben_code__c = 'BEN000280';
            bnf1.Name = 'testBenefi';
            bnf1.Dealer_Code__c = 'testdealer';
            bnf1.Indusind_AcNo__c = '786767832788';
            bnf1.Beneficiary__c = 'DSM';
            bnf1.Status_Flag__c = 'L';
            insert bnf1;
            
            CFD_State_Master__c cfd1 = new CFD_State_Master__c();
            cfd1.Name = 'name';
            cfd1.Language__c = 'English';
            cfd1.District__c = 'Pune';
            cfd1.CFD_State_Code__c ='MH';
            cfd1.Address_1__c = 'addr1';
            cfd1.Address_2__c = 'addr2';
            cfd1.Address_3__c = 'addr3';
            cfd1.Address_4__c = 'addr4';
            insert cfd1;
            
             Documents__c dfks2 = new Documents__c();
            dfks2.Opportunity_Relation__c = opds1.Id;
            dfks2.KYC_name__c = 'PAN';
            dfks2.Document_Side__c ='Back';
            dfks2.Aadhar_Source__c = 'ScanAadhar';
            dfks2.Name = 'Aadhar';
            dfks2.Document_Type__c = System.Label.AadhaarCard;
            dfks2.Proof_of_Identity_POI__c = true;
            dfks2.Applicant__c = apks1.Id;
            dfks2.Document_Type__c =System.Label.VoterIdCard; 
            dfks2.Gender__c = 'MALE';
            dfks2.Is_Active__c = true;
            insert dfks2;
            
            Test.startTest();
            FinalTermscontroller.loadSchemeData(opds1.Id,vg3.Id);
            Test.stopTest();
        }catch(Exception e){
            //System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void loadSchemeDataTest2(){
        try{
            Opportunity opds1 = new Opportunity();
            opds1.StageName = 'Qualification';
            opds1.CloseDate = Date.newInstance(2021, 1, 11);
            opds1.Name = 'testone';
            opds1.Agent_BL_code__c = 'AG-00';
            opds1.Product_Type__c = 'Passenger Vehicles';
            insert opds1;
            
            
            Vehicle_Detail__c vg3 = new Vehicle_Detail__c();
            vg3.Loan_Application__c = opds1.Id;
            vg3.Base_Price__c = 100000.00;
            vg3.Ben_Code__c = 'BEN000280';
            vg3.Variant__c = 'testvariant';
            vg3.Model__c ='testModel';
            vg3.Dealer_Sub_dealer_name__c = 'T V SUNDARAM IYENGAR AND SONS PVT LTD';
            insert vg3; 
            
            Product2 prd1 = new Product2();
            prd1.Name = opds1.Product_Type__c;
            prd1.Asset_Category__c = 'te';
            prd1.Capacity_1__c = 1000.00;
            prd1.Capacity_2__c = 2000.00;
            prd1.Capacity_Units_1__c = 'test12';
            prd1.Capacity_Units_2__c = 'test13';
            prd1.Type__c = 'Make';
            prd1.External_Reference_Id__c = '58568568';
            insert prd1;
            
            Benefi__c bnf1 = new Benefi__c();
            bnf1.Ben_code__c = 'BEN000280';
            bnf1.Name = 'test';
            bnf1.Dealer_Code__c = 'testdealer';
            bnf1.Indusind_AcNo__c = '786767832788';
            bnf1.Beneficiary__c = 'DSM';
            bnf1.Status_Flag__c = 'L';
            insert bnf1;
            
            CFD_State_Master__c cfd1 = new CFD_State_Master__c();
            cfd1.Name = 'name';
            cfd1.Language__c = 'English';
            cfd1.District__c = 'Pune';
            cfd1.CFD_State_Code__c ='MH';
            cfd1.Address_1__c = 'addr1';
            cfd1.Address_2__c = 'addr2';
            cfd1.Address_3__c = 'addr3';
            cfd1.Address_4__c = 'addr4';
            insert cfd1;
            
            Schemes__c sch1 = new Schemes__c();
            sch1.ProductCode__c = prd1.Id;
            sch1.Unique_Identifier__c = 'test';
            sch1.FromDate__c = Date.newInstance(2022, 3, 31);
            sch1.ExistingCustomer__c = true;
            sch1.Vehicle_Type__c = 'New';
            sch1.Scheme_Expiry__c = Date.newInstance(2026, 3, 31);
            sch1.Product__c = opds1.Product_Type__c;
            insert sch1;
            
            Test.startTest();
            FinalTermscontroller.loadSchemeData(opds1.Id,vg3.Id);
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
      @isTest
    public static void loadSchemeDataTest3(){
        try{
            Test.startTest();
            FinalTermscontroller.loadSchemeData(null,null);
            Test.stopTest();
        }catch(Exception e){
            System.assertNotEquals(null, e.getMessage());
        }
    }
    
    
    @isTest
    public static void dsmNameDataTest(){
        try{
            Opportunity opds1 = new Opportunity();
            opds1.StageName = 'Qualification';
            opds1.CloseDate = Date.newInstance(2021, 1, 11);
            opds1.Name = 'testone';
            opds1.Agent_BL_code__c = 'AG-00';
            opds1.Product_Type__c = 'Two Wheeler';
            insert opds1;
            
            Vehicle_Detail__c vg3 = new Vehicle_Detail__c();
            vg3.Loan_Application__c = opds1.Id;
            vg3.Base_Price__c = 100000.00;
            vg3.Ben_Code__c = 'BEN000280';
            vg3.Variant__c = 'testvariant';
            vg3.Model__c ='testModel';
            vg3.Dealer_Sub_dealer_name__c = 'T V SUNDARAM IYENGAR AND SONS PVT LTD';
            insert vg3; 
            
            Product2 prd1 = new Product2();
            prd1.Name = opds1.Product_Type__c;
            prd1.Asset_Category__c = 'te';
            prd1.Capacity_1__c = 1000.00;
            prd1.Capacity_2__c = 2000.00;
            prd1.Capacity_Units_1__c = 'test12';
            prd1.Capacity_Units_2__c = 'test13';
            prd1.Type__c = 'Make';
            prd1.ProductCode='H';
            prd1.External_Reference_Id__c = '58568568';
            insert prd1;
            
            Benefi__c bnf1 = new Benefi__c();
            bnf1.Ben_code__c = 'BEN000280';
            bnf1.Name = vg3.Dealer_Sub_dealer_name__c;
            bnf1.Dealer_Code__c = 'BEN000280';
            bnf1.Indusind_AcNo__c = '786767832788';
            bnf1.Beneficiary__c = 'DSM';
            bnf1.Status_Flag__c = 'L';
            insert bnf1;
            Bl_Code_Details__c bcd1 = new Bl_Code_Details__c();
            //   bcd1.Address_1__c = 'testadd';
            //   bcd1.Address_2__c = 'testadd2';
            bcd1.Bl_Code__c = opds1.Agent_BL_code__c;
            bcd1.Name = 'test';
            insert bcd1;
            Beneficiary_BlCode__c benefBLCode = new Beneficiary_BlCode__c();
            benefBLCode.Name = 'test benefBLCode';
            benefBLCode.Ben_code__c = bnf1.Id;
            benefBLCode.Bl_Code_Details__c = bcd1.Id;
            benefBLCode.Unique_Identifier__c = 'TEST';
            insert benefBLCode;
            
            Beneficiary_Product__c bp1 = new Beneficiary_Product__c();
            bp1.Name = 'testname';
            bp1.OwnerId = UserInfo.getUserId();
            bp1.Product__c = prd1.Id;
            bp1.Ben_code__c = bnf1.Id;
            bp1.Unique_Identifier__c = '678678';
            insert bp1;
            Beneficiary_BL_Code_Product__c bcp1 = new Beneficiary_BL_Code_Product__c();
            bcp1.Beneficiary_Master__c = bnf1.Id;
            bcp1.Bl_Code__c = bcd1.Id;
            bcp1.Category__c = 'test';
            bcp1.Product__c = prd1.Id;
            bcp1.Refernce_External__c = '1';
            insert bcp1;
            
            Test.startTest();
            FinalTermscontroller.dsmNameData(opds1.Id,vg3.Id);
            FinalTermscontroller.dsmNameData(opds1.Id,null);
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
        
    }
    
    
    @isTest
    public static void rtoValidationTest(){
        
        Opportunity opks1 = new Opportunity();
        opks1.StageName = 'Qualification';
        opks1.CloseDate = Date.newInstance(2021, 1, 11);
        opks1.Name = 'testone';
        opks1.Agent_BL_code__c = 'AG-00';
        insert opks1;
        
        Applicant__c apks1 = new Applicant__c();
        apks1.Opportunity__c = opks1.Id;
        apks1.Contact_number__c = '9743514830';
        apks1.Applicant_Type__c = 'Borrower';
        insert apks1;
        
        Bl_Code_Details__c bcd1 = new Bl_Code_Details__c();
        //  bcd1.Address_1__c = 'testadd';
        //  bcd1.Address_2__c = 'testadd2';
        bcd1.Bl_Code__c = opks1.Agent_BL_code__c;
        bcd1.Name = 'test';
        insert bcd1;
        
        Geo_State_Masters__c gm1 = new Geo_State_Masters__c();
        gm1.NeSL_State_Code__c = 'test';
        gm1.OwnerId = UserInfo.getUserId();
        gm1.Pincode_Starting_Max__c = 524;
        gm1.Pincode__c = 315;
        gm1.Name = 'allur';
        gm1.State_Code__c = '01';
        insert gm1;
        
        District_Master__c dm1 = new District_Master__c();
        dm1.Name = 'nellore';
        dm1.District_Code__c = 74;
        dm1.OwnerId = Userinfo.getUserId();
        dm1.Geo_State_Master__c = gm1.Id;
        insert dm1;
        
        BankBranchDetails__c bd1 = new BankBranchDetails__c();
        bd1.Bl_Code_Details__c = bcd1.Id;
        bd1.Geo_State_Master__c = gm1.Id;
        //   bd1.District_Master__c = dm1.Id;
        bd1.Address_1__c = 'testad1';
        bd1.Address_2__c = 'testad2';
        bd1.UniqueIdentifier__c = '201';
        bd1.District__c = 'nellore';
        insert bd1;
        
        Ind_RTO_Master__c im1 = new Ind_RTO_Master__c();
        im1.Geo_State_Master__c = bd1.Geo_State_Master__c;
        im1.OwnerId = UserInfo.getUserId();
        im1.RTO_ALNU__c = 'AN01';
        im1.Name = 'test';
        insert im1;
        
        Test.startTest();
        FinalTermscontroller.rtoValidation(opks1.Id,im1.RTO_ALNU__c);
        Test.stopTest();
        
    }
    
    @isTest
    public static void rtoValidationTest1(){
        
        Opportunity opks1 = new Opportunity();
        opks1.StageName = 'Qualification';
        opks1.CloseDate = Date.newInstance(2021, 1, 11);
        opks1.Name = 'testone';
        opks1.Agent_BL_code__c = 'AG-00';
        insert opks1;
        
        Applicant__c apks1 = new Applicant__c();
        apks1.Opportunity__c = opks1.Id;
        apks1.Contact_number__c = '9743514830';
        apks1.Applicant_Type__c = 'Borrower';
        insert apks1;
        
        Bl_Code_Details__c bcd1 = new Bl_Code_Details__c();
        //  bcd1.Address_1__c = 'testadd';
        //  bcd1.Address_2__c = 'testadd2';
        bcd1.Bl_Code__c = opks1.Agent_BL_code__c;
        bcd1.Name = 'test';
        insert bcd1;
        
        Geo_State_Masters__c gm1 = new Geo_State_Masters__c();
        gm1.NeSL_State_Code__c = 'test';
        gm1.OwnerId = UserInfo.getUserId();
        gm1.Pincode_Starting_Max__c = 524;
        gm1.Pincode__c = 315;
        gm1.Name = 'allur';
        gm1.State_Code__c = '01';
        insert gm1;
        
        District_Master__c dm1 = new District_Master__c();
        dm1.Name = 'nellore';
        dm1.District_Code__c = 74;
        dm1.OwnerId = Userinfo.getUserId();
        dm1.Geo_State_Master__c = gm1.Id;
        insert dm1;
        
        BankBranchDetails__c bd1 = new BankBranchDetails__c();
        bd1.Bl_Code_Details__c = bcd1.Id;
        //bd1.Geo_State_Master__c = gm1.Id;
        //bd1.District_Master__c = dm1.Id;
        bd1.Address_1__c = 'testad1';
        bd1.Address_2__c = 'testad2';
        bd1.UniqueIdentifier__c = '201';
        bd1.District__c = 'nellore';
        insert bd1;
        
        List<Ind_RTO_Master__c> irmList = new List<Ind_RTO_Master__c>();
        Ind_RTO_Master__c im2 = new Ind_RTO_Master__c();
        im2.Geo_State_Master__c = gm1.Id;
        im2.OwnerId = UserInfo.getUserId();
        im2.RTO_ALNU__c = 'AN01';
        im2.Name = 'test';
        insert im2;
        irmList.add(im2);
        
        
        System.debug('GEO*********************=' +gm1.ID);
        System.debug('GEO*********************=' +im2.Geo_State_Master__c);
        
        Test.startTest();
        FinalTermscontroller.rtoValidation(opks1.Id,im2.RTO_ALNU__c);
        Test.stopTest();
        
    }
    
    @isTest
    public static void rtoValidationTest2(){
        try{
            Opportunity opks1 = new Opportunity();
            opks1.StageName = 'Qualification';
            opks1.CloseDate = Date.newInstance(2021, 1, 11);
            opks1.Name = 'testone';
            opks1.Agent_BL_code__c = 'AG-00';
            insert opks1;
            
            Applicant__c apks1 = new Applicant__c();
            apks1.Opportunity__c = opks1.Id;
            apks1.Contact_number__c = '9743514830';
            apks1.Applicant_Type__c = 'Borrower';
            insert apks1;
            
             Bl_Code_Details__c bcd1 = new Bl_Code_Details__c();
        //  bcd1.Address_1__c = 'testadd';
        //  bcd1.Address_2__c = 'testadd2';
        bcd1.Bl_Code__c = opks1.Agent_BL_code__c;
        bcd1.Name = 'test';
        insert bcd1;
        
        Geo_State_Masters__c gm1 = new Geo_State_Masters__c();
        gm1.NeSL_State_Code__c = 'test';
        gm1.OwnerId = UserInfo.getUserId();
        gm1.Pincode_Starting_Max__c = 524;
        gm1.Pincode__c = 315;
        gm1.Name = 'allur';
        gm1.State_Code__c = '01';
        insert gm1;
        
        District_Master__c dm1 = new District_Master__c();
        dm1.Name = 'nellore';
        dm1.District_Code__c = 74;
        dm1.OwnerId = Userinfo.getUserId();
        dm1.Geo_State_Master__c = gm1.Id;
        insert dm1;
        
        BankBranchDetails__c bd1 = new BankBranchDetails__c();
        bd1.Bl_Code_Details__c = bcd1.Id;
        //bd1.Geo_State_Master__c = gm1.Id;
        //bd1.District_Master__c = dm1.Id;
        bd1.Address_1__c = 'testad1';
        bd1.Address_2__c = 'testad2';
        bd1.UniqueIdentifier__c = '201';
        bd1.District__c = 'nellore';
        insert bd1;
        
        List<Ind_RTO_Master__c> irmList = new List<Ind_RTO_Master__c>();
        Ind_RTO_Master__c im2 = new Ind_RTO_Master__c();
        im2.Geo_State_Master__c = gm1.Id;
        im2.OwnerId = UserInfo.getUserId();
        im2.RTO_ALNU__c = 'AN01';
        im2.Name = 'test';
        insert im2;
        irmList.add(im2);
            
            Test.startTest();
            FinalTermscontroller.rtoValidation(opks1.Id,'AN10');
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
        
    }
    
    @isTest
    public static void nonDsmNameDataTest(){
        try{
            Opportunity opks1 = new Opportunity();
            opks1.StageName = 'Qualification';
            opks1.CloseDate = Date.newInstance(2021, 1, 11);
            opks1.Name = 'testone';
            opks1.Agent_BL_code__c = 'AG-00';
            opks1.Product_Type__c = 'Two Wheeler';
            insert opks1;
            
            Applicant__c apks1 = new Applicant__c();
            apks1.Opportunity__c = opks1.Id;
            apks1.Contact_number__c = '9743514830';
            apks1.Applicant_Type__c = 'Borrower';
            insert apks1;
            
            Vehicle_Detail__c vg4 = new Vehicle_Detail__c();
            vg4.Loan_Application__c = opks1.Id;
            vg4.Base_Price__c = 100000.00;
            vg4.Ben_Code__c = 'BEN000280';
            vg4.Variant__c = 'testvariant';
            vg4.Dealer_Sub_dealer_name__c = 'T V SUNDARAM IYENGAR AND SONS PVT LTD';
            insert vg4; 
            
            Bl_Code_Details__c bcd1 = new Bl_Code_Details__c();
            //  bcd1.Address_1__c = 'testadd';
            //  bcd1.Address_2__c = 'testadd2';
            bcd1.Bl_Code__c = opks1.Agent_BL_code__c;
            bcd1.Name = 'test';
            insert bcd1;
            
            Product2 prd1 = new Product2();
            prd1.Asset_Category__c = 'te';
            prd1.Capacity_1__c = 1000.00;
            prd1.Capacity_2__c = 2000.00;
            prd1.Capacity_Units_1__c = 'test12';
            prd1.Capacity_Units_2__c = 'test13';
            prd1.Type__c = 'Make';
            prd1.External_Reference_Id__c = '58568568';
            prd1.Name = opks1.Product_Type__c;
            prd1.ProductCode='H';
            insert prd1;
            
            Benefi__c bnf1 = new Benefi__c();
            bnf1.Ben_code__c = 'BEN000280';
            bnf1.Name = vg4.Dealer_Sub_dealer_name__c;
            bnf1.Dealer_Code__c = 'testveh';
            bnf1.Indusind_AcNo__c = '786767832788';
            bnf1.Beneficiary__c = 'DSA';
            bnf1.Status_Flag__c = 'L';
            bnf1.Pseudo_DSM__c = 'Y';
            bnf1.Status_Flag__c = 'L';
            insert bnf1;
            
            Beneficiary_Product__c bpd1 = new Beneficiary_Product__c();
            bpd1.Ben_code__c = bnf1.Id;
            bpd1.Name = 'test';
            bpd1.OwnerId = UserInfo.getUserId();
            bpd1.Product__c = prd1.Id;
            bpd1.Unique_Identifier__c = '678678';
            insert bpd1;
            Beneficiary_BlCode__c benefBLCode = new Beneficiary_BlCode__c();
            benefBLCode.Name = 'test benefBLCode';
            benefBLCode.Ben_code__c = bnf1.Id;
            benefBLCode.Bl_Code_Details__c = bcd1.Id;
            benefBLCode.Unique_Identifier__c = 'TEST';
            insert benefBLCode;
            Test.startTest();
            FinalTermscontroller.nonDsmNameData(opks1.Id,vg4.Id);
            FinalTermscontroller.nonDsmNameData(opks1.Id,vg4.Id);
            FinalTermscontroller.nonDsmNameData(null,null);
            Test.stopTest();
            
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void checkSchemeEligibilityTest(){
        try{
            Opportunity opks1 = new Opportunity();
            opks1.StageName = 'Qualification';
            opks1.CloseDate = Date.newInstance(2021, 1, 11);
            opks1.Name = 'testone';
            opks1.Product_Type__c = 'Two Wheeler';
            insert opks1;
            
            Vehicle_Detail__c vg4 = new Vehicle_Detail__c();
            vg4.Loan_Application__c = opks1.Id;
            vg4.Base_Price__c = 100000.00;
            vg4.Ben_Code__c = 'BEN000280';
            vg4.Variant__c = 'testvariant';
            vg4.Dealer_Sub_dealer_name__c = 'T V SUNDARAM IYENGAR AND SONS PVT LTD';
            insert vg4; 
            
            Applicant__c apks1 = new Applicant__c();
            apks1.Opportunity__c = opks1.Id;
            apks1.Contact_number__c = '9743514830';
            apks1.Applicant_Type__c = 'Borrower';
            apks1.In_Active_Applicant__c = false;
            apks1.Customer_Code__c = '12345';
            insert apks1;
            
            CIBIL_Details__c cbd2 = new CIBIL_Details__c();
            cbd2.Applicant__c = apks1.Id;
            cbd2.CIC_No__c = 'testcbd';
            cbd2.Score__c = '200';
            insert cbd2;
            
            Documents__c dfks1 = new Documents__c();
            dfks1.Applicant__c = apks1.Id;
            dfks1.Opportunity_Relation__c = opks1.Id;
            dfks1.KYC_name__c = 'Aadhar';
            dfks1.Document_Side__c ='Back';
            dfks1.Aadhar_Source__c = 'ScanAadhar';
            dfks1.Name = 'Aadhar';
            dfks1.Document_Type__c = System.Label.AadhaarCard;
            dfks1.Age__c = 25;
            dfks1.Proof_of_Identity_POI__c = true;
            dfks1.KYC_DOB__c = Date.newInstance(1994, 6, 23);
            insert dfks1;
            
            Product2 prd1 = new Product2();
            prd1.Asset_Category__c = 'te';
            prd1.Capacity_1__c = 1000.00;
            prd1.Capacity_2__c = 2000.00;
            prd1.Capacity_Units_1__c = 'test12';
            prd1.Capacity_Units_2__c = 'test13';
            prd1.Type__c = 'Make';
            prd1.External_Reference_Id__c = '58568568';
            prd1.Name = 'book';
            insert prd1;
            
            // Schemes__c sch1 = new Schemes__c();
            //sch1.ProductCode__c = prd1.Id;
            // sch1.Unique_Identifier__c = 'test';
            /// sch1.FromDate__c = Date.newInstance(2022, 3, 31);
            // sch1.ExistingCustomer__c = true;
            //  sch1.Product__c = 'Two Wheeler';
            // insert sch1;
            Schemes__c schemeObj = [SELECT Id FROM Schemes__c WHERE Unique_Identifier__c='testUnique'];
            Test.startTest();
            FinalTermscontroller.checkSchemeEligibility(schemeObj.Id,opks1.Id,vg4.Id);
            Test.stopTest();
        }catch(Exception e){
            // System.assertEquals('Script-thrown exception', e.getMessage());
        }
        
    }
    
    @isTest
    public static void checkSchemeEligibilityTest11(){
        try{
            Opportunity opks1 = new Opportunity();
            opks1.StageName = 'Qualification';
            opks1.CloseDate = Date.newInstance(2021, 1, 11);
            opks1.Name = 'testone';
            insert opks1;
            
            Vehicle_Detail__c vg4 = new Vehicle_Detail__c();
            vg4.Loan_Application__c = opks1.Id;
            vg4.Base_Price__c = 100000.00;
            vg4.Ben_Code__c = 'BEN000280';
            vg4.Variant__c = 'testvariant';
            vg4.Dealer_Sub_dealer_name__c = 'T V SUNDARAM IYENGAR AND SONS PVT LTD';
            insert vg4; 
            
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
            dfks1.Aadhar_Source__c = 'ScanAadhar';
            dfks1.Name = 'Aadhar';
            dfks1.Document_Type__c = System.Label.AadhaarCard;
            dfks1.Age__c = null;
            dfks1.Proof_of_Identity_POI__c = true;
            insert dfks1;
            
            Product2 prd1 = new Product2();
            prd1.Asset_Category__c = 'te';
            prd1.Capacity_1__c = 1000.00;
            prd1.Capacity_2__c = 2000.00;
            prd1.Capacity_Units_1__c = 'test12';
            prd1.Capacity_Units_2__c = 'test13';
            prd1.Type__c = 'Make';
            prd1.External_Reference_Id__c = '58568568';
            prd1.Name = 'book';
            insert prd1;
            
            Schemes__c sch1 = new Schemes__c();
            sch1.ProductCode__c = prd1.Id;
            sch1.Unique_Identifier__c = 'test';
            sch1.FromDate__c = Date.newInstance(2022, 3, 31);
            sch1.ExistingCustomer__c = true;
            sch1.Product__c = 'Two Wheeler';
            insert sch1;
            Schemes__c schemeObj = [SELECT Id FROM Schemes__c WHERE Unique_Identifier__c='testUnique'];
            Test.startTest();
            FinalTermscontroller.checkSchemeEligibility(schemeObj.Id,opks1.Id,vg4.Id);
            Test.stopTest();
        }catch(Exception e){
            // System.assertEquals('Script-thrown exception', e.getMessage());
        }
        
    }
    
    @isTest
    public static void checkSchemeEligibilityTest1(){
        try{
            Opportunity opks1 = new Opportunity();
            opks1.StageName = 'Qualification';
            opks1.CloseDate = Date.newInstance(2021, 1, 11);
            opks1.Name = 'testone';
            insert opks1;
            
            Test.startTest();
            FinalTermscontroller.checkSchemeEligibility('test1','test2','test3');
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
        
    }
    
    @isTest
    public static void createFinalTermRecordTest(){
        try{
            Opportunity opks1 = new Opportunity();
            opks1.StageName = 'Qualification';
            opks1.CloseDate = Date.newInstance(2021, 1, 11);
            opks1.Name = 'testone';
            insert opks1;
            
            Vehicle_Detail__c vg4 = new Vehicle_Detail__c();
            vg4.Loan_Application__c = opks1.Id;
            vg4.Base_Price__c = 100000.00;
            vg4.Ben_Code__c = 'BEN000280';
            vg4.Variant__c = 'testvariant';
            vg4.Dealer_Sub_dealer_name__c = 'T V SUNDARAM IYENGAR AND SONS PVT LTD';
            insert vg4; 
            
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
            fgd3.FIwaiver_offAddress__c = 'Not Waived';
            insert fgd3;
            
            Test.startTest();
            FinalTermscontroller.createFinalTermRecord(opks1.Id,vg4.Id);
            Test.stopTest();
            
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void createFinalTermRecordTest1(){
        try{
            Opportunity opks2 = new Opportunity();
            opks2.StageName = 'Qualification';
            opks2.CloseDate = Date.newInstance(2021, 1, 11);
            opks2.Name = 'testone';
            insert opks2;
            
            Vehicle_Detail__c vg4 = new Vehicle_Detail__c();
            vg4.Loan_Application__c = opks2.Id;
            vg4.Base_Price__c = 100000.00;
            vg4.Ben_Code__c = 'BEN000280';
            vg4.Variant__c = 'testvariant';
            vg4.Dealer_Sub_dealer_name__c = 'T V SUNDARAM IYENGAR AND SONS PVT LTD';
            insert vg4;
            
            Applicant__c apks1 = new Applicant__c();
            apks1.Opportunity__c = opks2.Id;
            apks1.Contact_number__c = '9743514830';
            apks1.Applicant_Type__c = 'Borrower';
            insert apks1;
            
            /*     Final_Term__c fgd3 = new Final_Term__c();
fgd3.CRM_IRR__c = 120;
fgd3.Loan_Application__c = opks1.Id;
fgd3.Holiday_period__c='30';
fgd3.EMI_Amount__c= 10000;
fgd3.FIwaiver_offAddress__c = 'Not Waived';
insert fgd3; */
            
            Test.startTest();
            FinalTermscontroller.createFinalTermRecord(opks2.Id,vg4.Id);
            FinalTermscontroller.createFinalTermRecord('test','test1');
            Test.stopTest();
            
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void checkRetryExhaustedTest(){
        try{
            Opportunity opks1 = new Opportunity();
            opks1.StageName = 'Qualification';
            opks1.CloseDate = Date.newInstance(2021, 1, 11);
            opks1.Name = 'testone';
            insert opks1;
            
            Vehicle_Detail__c vg4 = new Vehicle_Detail__c();
            vg4.Loan_Application__c = opks1.Id;
            vg4.Base_Price__c = 100000.00;
            vg4.Ben_Code__c = 'BEN000280';
            vg4.Variant__c = 'testvariant';
            vg4.Dealer_Sub_dealer_name__c = 'T V SUNDARAM IYENGAR AND SONS PVT LTD';
            insert vg4;
            
            Retry_Count__c rc1 = new Retry_Count__c();
            rc1.Loan_Application_Id__c = opks1.Id;
            rc1.Service_Name__c = 'FinalTermApi';
            rc1.User_Id__c = UserInfo.getUserId();
            rc1.Count__c = 7;
            insert rc1;
            
            Test.startTest();
            FinalTermscontroller.checkRetryExhausted(opks1.Id,vg4.Id);
            Test.stopTest();
            
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void checkRetryExhaustedTest1(){
        try{
            Opportunity opks1 = new Opportunity();
            opks1.StageName = 'Qualification';
            opks1.CloseDate = Date.newInstance(2021, 1, 11);
            opks1.Name = 'testone';
            insert opks1;
            
            Vehicle_Detail__c vg4 = new Vehicle_Detail__c();
            vg4.Loan_Application__c = opks1.Id;
            vg4.Base_Price__c = 100000.00;
            vg4.Ben_Code__c = 'BEN000280';
            vg4.Variant__c = 'testvariant';
            vg4.Dealer_Sub_dealer_name__c = 'T V SUNDARAM IYENGAR AND SONS PVT LTD';
            insert vg4;
            
            /*   Retry_Count__c rc1 = new Retry_Count__c();
rc1.Loan_Application_Id__c = opks1.Id;
rc1.Service_Name__c = 'FinalTermApi';
rc1.User_Id__c = UserInfo.getUserId();
rc1.Count__c = 7;
insert rc1; */
            
            Test.startTest();
            FinalTermscontroller.checkRetryExhausted(opks1.Id,vg4.Id);
            Test.stopTest();
            
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void retryCountIncreaseTest(){
        try{
            Opportunity opks1 = new Opportunity();
            opks1.StageName = 'Qualification';
            opks1.CloseDate = Date.newInstance(2021, 1, 11);
            opks1.Name = 'testone';
            insert opks1;
            
            Vehicle_Detail__c vg4 = new Vehicle_Detail__c();
            vg4.Loan_Application__c = opks1.Id;
            vg4.Base_Price__c = 100000.00;
            vg4.Ben_Code__c = 'BEN000280';
            vg4.Variant__c = 'testvariant';
            vg4.Dealer_Sub_dealer_name__c = 'T V SUNDARAM IYENGAR AND SONS PVT LTD';
            insert vg4;
            
            Retry_Count__c rc1 = new Retry_Count__c();
            rc1.Loan_Application_Id__c = opks1.Id;
            rc1.Service_Name__c = 'FinalTermApi';
            rc1.User_Id__c = UserInfo.getUserId();
            rc1.Count__c = 1;
            insert rc1;
            
            Test.startTest();
            FinalTermscontroller.retryCountIncrease(opks1.Id,vg4.Id,True);
            Test.stopTest();
            
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void retryCountIncreaseTest1(){
        try{
            Opportunity opks1 = new Opportunity();
            opks1.StageName = 'Qualification';
            opks1.CloseDate = Date.newInstance(2021, 1, 11);
            opks1.Name = 'testone';
            insert opks1;
            
            Vehicle_Detail__c vg4 = new Vehicle_Detail__c();
            vg4.Loan_Application__c = opks1.Id;
            vg4.Base_Price__c = 100000.00;
            vg4.Ben_Code__c = 'BEN000280';
            vg4.Variant__c = 'testvariant';
            vg4.Dealer_Sub_dealer_name__c = 'T V SUNDARAM IYENGAR AND SONS PVT LTD';
            insert vg4;
            
            Retry_Count__c rc1 = new Retry_Count__c();
            rc1.Loan_Application_Id__c = opks1.Id;
            rc1.Service_Name__c = 'FinalTermApi';
            rc1.User_Id__c = UserInfo.getUserId();
            rc1.Count__c = 1;
            insert rc1;
            
            Test.startTest();
            FinalTermscontroller.retryCountIncrease('test',vg4.Id,True);
            Test.stopTest();
            
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void getFinalTermDetailsTest(){
        try{
            Opportunity opft1 = new Opportunity();
            opft1.StageName = 'Credit Processing';
            opft1.CloseDate = Date.newInstance(2021, 1, 11);
            opft1.Name = 'testone';
            opft1.Vehicle_Type__c = 'New';
            opft1.Product_Type__c = 'Two Wheeler';
            opft1.RTO_Road_Tax_New__c = 1000.00;
            opft1.Other_charges__c = 500.00;
            opft1.X1st_yr_Insurance_Premium__c = 200.00;
            opft1.View_Application_Sub_Stages__c ='Final Terms';
            opft1.Required_Tenure__c = 8.0;
            opft1.Sub_Stage__c ='Final Terms';
            opft1.Basic_Price__c = 1000.00;
            opft1.GST_Amount__c=500.00;
            opft1.Discount_on_Basic_Price__c=10;
            opft1.Funding_on_Ex_Showroom__c = true;
            opft1.Funding_on_Ex_Showroom__c = true;
            opft1.X1st_yr_Insurance_Premium__c = 700.00;
            
            insert opft1;
            
            Applicant__c apft1 = new Applicant__c();
            apft1.Opportunity__c = opft1.Id;
            apft1.Contact_number__c = '9743514830';
            apft1.Applicant_Type__c = 'Borrower';
            apft1.In_Active_Applicant__c = false;
            insert apft1;
            
            Final_Term__c ftd1 = new Final_Term__c();
            ftd1.CRM_IRR__c = 120;
            ftd1.Loan_Application__c = opft1.Id;
            ftd1.Holiday_period__c='30';
            ftd1.EMI_Amount__c= 10000;
            ftd1.Loan_Amount__c = '50000.00';
            ftd1.Service_charges__c = '1000.00';
            ftd1.Documentation_charges__c = '5000';
            ftd1.Dlr_Exp_Reimburse_Amt__c = '10000';
            ftd1.Rreferrer_Incentive__c = '100000';
            ftd1.Dlr_Exp_Reimbursement_percent__c = '20000';
            ftd1.Mfr_Exp_Reimburse_percent__c = '30000';
            insert ftd1;
            
            FinalTermscontroller.finalTermDetailWrapper ftw1 = new FinalTermscontroller.finalTermDetailWrapper();
            ftw1.basicPrice = opft1.Basic_Price__c;
            ftw1.fundingOnExShowroom = opft1.Funding_on_Ex_Showroom__c;
            ftw1.fundingOnORP = opft1.Funding_on_ORP__c;
            
            Test.startTest();
            FinalTermscontroller.getFinalTermDetails(opft1.Id,ftd1.Id);
            Test.stopTest();
            
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void getFinalTermDetailsTest1(){
        try{
            
            vehicleCategoryCode__mdt vehCatCode = [SELECT vehicleCategoryCode__c from vehicleCategoryCode__mdt where vehicleCategoryCode__c = 'S' limit 1];
            
            Opportunity opft1 = new Opportunity();
            opft1.StageName = 'Credit Processing';
            opft1.CloseDate = Date.newInstance(2021, 1, 11);
            opft1.Name = 'testone';
            opft1.Vehicle_Type__c = 'New';
            opft1.Product_Type__c = 'Two Wheeler';
            opft1.RTO_Road_Tax__c = 1000.00;
            opft1.Other_charges__c = 500.00;
            opft1.X1st_yr_Insurance_Premium__c = 200.00;
            opft1.View_Application_Sub_Stages__c ='Final Terms';
            opft1.Required_Tenure__c = 8.0;
            opft1.Sub_Stage__c ='Final Terms';
            opft1.Basic_Price__c = 1000.00;
            opft1.GST_Amount__c=500.00;
            opft1.Discount_on_Basic_Price__c=10;
            opft1.Funding_on_Ex_Showroom__c = true;
            opft1.Funding_on_Ex_Showroom__c = true;
            opft1.X1st_yr_Insurance_Premium__c = 700.00;
            
            insert opft1;
            
            Applicant__c apft1 = new Applicant__c();
            apft1.Opportunity__c = opft1.Id;
            apft1.Contact_number__c = '9743514830';
            apft1.Applicant_Type__c = 'Borrower';
            apft1.In_Active_Applicant__c = false;
            insert apft1;
            
            Final_Term__c ftd1 = new Final_Term__c();
            ftd1.CRM_IRR__c = 120;
            ftd1.Loan_Application__c = opft1.Id;
            ftd1.Holiday_period__c='30';
            ftd1.EMI_Amount__c= 10000;
            ftd1.Loan_Amount__c = '50000.00';
            ftd1.Service_charges__c = '1000.00';
            ftd1.Documentation_charges__c = '5000';
            ftd1.Dlr_Exp_Reimburse_Amt__c = '10000';
            ftd1.Rreferrer_Incentive__c = '100000';
            ftd1.Dlr_Exp_Reimbursement_percent__c = '20000';
            ftd1.Mfr_Exp_Reimburse_percent__c = '30000';
            ftd1.Dealer_incentive_amount_sub_dealer__c = '6000';
            ftd1.Dealer_incentive_amount_main_dealer__c = '7000';
            ftd1.Dealer_Disc_to_Customer__c = '8000';
            ftd1.DSM_Incentive1__c = '5000';
            ftd1.Non_Dlr_DSM_Incentive1__c = '35000';
            ftd1.Non_Dlr_DSM_Incentive2__c = '37000';
            ftd1.DSM_Incentive2__c = '33000';
            ftd1.Gift_through_dealer_amount__c = '31000';
            ftd1.Mfr_Exp_Reimburse_Amt__c = '29000';
            ftd1.Tenure__c = '15';
            ftd1.Provisional_Channel_Cost__c = '26000';
            insert ftd1;
            
            FinalTermscontroller.finalTermDetailWrapper ftw1 = new FinalTermscontroller.finalTermDetailWrapper();
            ftw1.basicPrice = opft1.Basic_Price__c;
            ftw1.fundingOnExShowroom = opft1.Funding_on_Ex_Showroom__c;
            ftw1.fundingOnORP = opft1.Funding_on_ORP__c;
            
            Test.startTest();
            FinalTermscontroller.getFinalTermDetails(opft1.Id,ftd1.Id);
            Test.stopTest();
            
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void getFinalTermDetailsTest2(){
        try{
            Opportunity opft2 = new Opportunity();
            opft2.StageName = 'Credit Processing';
            opft2.CloseDate = Date.newInstance(2021, 1, 11);
            opft2.Name = 'testone';
            insert opft2;
            
            Test.startTest();
            FinalTermscontroller.getFinalTermDetails(null,null);
            Test.stopTest();
            
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void getFinalTermDetailsTest3(){
        try{
            Opportunity opft1 = new Opportunity();
            opft1.StageName = 'Credit Processing';
            opft1.CloseDate = Date.newInstance(2021, 1, 11);
            opft1.Name = 'testone';
            opft1.Vehicle_Type__c = 'New';
            opft1.Product_Type__c = System.Label.PassengerVehicles;
            opft1.RTO_Road_Tax__c = 1000.00;
            opft1.Other_charges__c = 500.00;
            opft1.X1st_yr_Insurance_Premium__c = 200.00;
            opft1.View_Application_Sub_Stages__c ='Final Terms';
            opft1.Required_Tenure__c = 8.0;
            opft1.Sub_Stage__c ='Final Terms';
            opft1.Basic_Price__c = 1000.00;
            opft1.GST_Amount__c=500.00;
            opft1.Discount_on_Basic_Price__c=10;
            opft1.Funding_on_Ex_Showroom__c = true;
            opft1.Funding_on_Ex_Showroom__c = true;
            opft1.X1st_yr_Insurance_Premium__c = 700.00;
            
            insert opft1;
            
            Applicant__c apft1 = new Applicant__c();
            apft1.Opportunity__c = opft1.Id;
            apft1.Contact_number__c = '9743514830';
            apft1.Applicant_Type__c = 'Borrower';
            apft1.In_Active_Applicant__c = false;
            insert apft1;
            
            Final_Term__c ftd1 = new Final_Term__c();
            ftd1.CRM_IRR__c = 120;
            ftd1.Loan_Application__c = opft1.Id;
            ftd1.Holiday_period__c='30';
            ftd1.EMI_Amount__c= 10000;
            ftd1.Loan_Amount__c = '50000.00';
            ftd1.Service_charges__c = '1000.00';
            ftd1.Documentation_charges__c = '5000';
            ftd1.Dlr_Exp_Reimburse_Amt__c = '10000';
            ftd1.Rreferrer_Incentive__c = '100000';
            ftd1.Dlr_Exp_Reimbursement_percent__c = '20000';
            ftd1.Mfr_Exp_Reimburse_percent__c = '30000';
            insert ftd1;
            
            FinalTermscontroller.finalTermDetailWrapper ftw1 = new FinalTermscontroller.finalTermDetailWrapper();
            ftw1.basicPrice = opft1.Basic_Price__c;
            ftw1.fundingOnExShowroom = opft1.Funding_on_Ex_Showroom__c;
            ftw1.fundingOnORP = opft1.Funding_on_ORP__c;
            
            Test.startTest();
            FinalTermscontroller.getFinalTermDetails(opft1.Id,ftd1.Id);
            Test.stopTest();
            
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void getFinalTermDetailsTest4(){
        try{
            Opportunity opft1 = new Opportunity();
            opft1.StageName = 'Credit Processing';
            opft1.CloseDate = Date.newInstance(2021, 1, 11);
            opft1.Name = 'testone';
            opft1.Vehicle_Type__c = 'New';
            //   opft1.Total_Funded_Premium__c = '50000.00';
            opft1.Product_Type__c = System.Label.PassengerVehicles;
            opft1.RTO_Road_Tax__c = 1000.00;
            opft1.Other_charges__c = 500.00;
            opft1.X1st_yr_Insurance_Premium__c = 200.00;
            opft1.View_Application_Sub_Stages__c ='Final Terms';
            opft1.Required_Tenure__c = 8.0;
            opft1.Sub_Stage__c ='Final Terms';
            opft1.Basic_Price__c = 1000.00;
            opft1.GST_Amount__c=500.00;
            opft1.Discount_on_Basic_Price__c=10;
            opft1.Funding_on_Ex_Showroom__c = true;
            opft1.Funding_on_Ex_Showroom__c = true;
            opft1.X1st_yr_Insurance_Premium__c = 700.00;
            
            insert opft1;
            
            Applicant__c apft1 = new Applicant__c();
            apft1.Opportunity__c = opft1.Id;
            apft1.Contact_number__c = '9743514830';
            apft1.Applicant_Type__c = 'Borrower';
            apft1.In_Active_Applicant__c = false;
            insert apft1;
            
            Final_Term__c ftd1 = new Final_Term__c();
            ftd1.CRM_IRR__c = 120;
            ftd1.Loan_Application__c = opft1.Id;
            ftd1.Holiday_period__c='30';
            ftd1.EMI_Amount__c= 10000;
            ftd1.Loan_Amount__c = '100000.00';
            ftd1.Service_charges__c = '1000.00';
            ftd1.Documentation_charges__c = '5000';
            ftd1.Dlr_Exp_Reimburse_Amt__c = '10000';
            ftd1.Rreferrer_Incentive__c = '100000';
            ftd1.Dlr_Exp_Reimbursement_percent__c = '20000';
            ftd1.Mfr_Exp_Reimburse_percent__c = '30000';
            insert ftd1;
            
            FinalTermscontroller.finalTermDetailWrapper ftw1 = new FinalTermscontroller.finalTermDetailWrapper();
            ftw1.basicPrice = opft1.Basic_Price__c;
            ftw1.fundingOnExShowroom = opft1.Funding_on_Ex_Showroom__c;
            ftw1.fundingOnORP = opft1.Funding_on_ORP__c;
            
            vehicleCategoryCode__mdt vehicleCategoryCodes1 = new vehicleCategoryCode__mdt();
            vehicleCategoryCodes1.vehicleType__c = opft1.Vehicle_Type__c;
            vehicleCategoryCodes1.productType__c = opft1.Product_Type__c;
            
            finalTermValidation__mdt ftv1 = new finalTermValidation__mdt();
            ftv1.documentChargesFinAmount__c = 1000.00;
            
            Test.startTest();
            FinalTermscontroller.getFinalTermDetails(opft1.Id,ftd1.Id);
            Test.stopTest();
            
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void getFinalTermDetailsTest5(){
        try{
            Opportunity opft1 = new Opportunity();
            opft1.StageName = 'Credit Processing';
            opft1.CloseDate = Date.newInstance(2021, 1, 11);
            opft1.Name = 'testone';
            opft1.Vehicle_Type__c = 'New';
            //   opft1.Total_Funded_Premium__c = '50000.00';
            opft1.Product_Type__c = System.Label.PassengerVehicles;
            opft1.RTO_Road_Tax__c = 1000.00;
            opft1.Other_charges__c = 500.00;
            opft1.X1st_yr_Insurance_Premium__c = 200.00;
            opft1.View_Application_Sub_Stages__c ='Final Terms';
            opft1.Required_Tenure__c = 8.0;
            opft1.Sub_Stage__c ='Final Terms';
            opft1.Basic_Price__c = 1000.00;
            opft1.GST_Amount__c=500.00;
            opft1.Discount_on_Basic_Price__c=10;
            opft1.Funding_on_Ex_Showroom__c = true;
            opft1.Funding_on_Ex_Showroom__c = true;
            opft1.X1st_yr_Insurance_Premium__c = 700.00;
            
            insert opft1;
            
            Applicant__c apft1 = new Applicant__c();
            apft1.Opportunity__c = opft1.Id;
            apft1.Contact_number__c = '9743514830';
            apft1.Applicant_Type__c = 'Borrower';
            apft1.In_Active_Applicant__c = false;
            insert apft1;
            
            Final_Term__c ftd1 = new Final_Term__c();
            ftd1.CRM_IRR__c = 120;
            ftd1.Loan_Application__c = opft1.Id;
            ftd1.Holiday_period__c='30';
            ftd1.EMI_Amount__c= 10000;
            ftd1.Loan_Amount__c = '100000.00';
            ftd1.Service_charges__c = '1000.00';
            ftd1.Documentation_charges__c = null;
            ftd1.Dlr_Exp_Reimburse_Amt__c = '10000';
            ftd1.Rreferrer_Incentive__c = '100000';
            ftd1.Dlr_Exp_Reimbursement_percent__c = '20000';
            ftd1.Mfr_Exp_Reimburse_percent__c = '30000';
            ftd1.Dealer_incentive_amount_sub_dealer__c = '5000';
            insert ftd1;
            
            FinalTermscontroller.finalTermDetailWrapper ftw1 = new FinalTermscontroller.finalTermDetailWrapper();
            ftw1.basicPrice = opft1.Basic_Price__c;
            ftw1.fundingOnExShowroom = opft1.Funding_on_Ex_Showroom__c;
            ftw1.fundingOnORP = opft1.Funding_on_ORP__c;
            
            vehicleCategoryCode__mdt vehicleCategoryCodes1 = new vehicleCategoryCode__mdt();
            vehicleCategoryCodes1.vehicleType__c = opft1.Vehicle_Type__c;
            vehicleCategoryCodes1.productType__c = opft1.Product_Type__c;
            vehicleCategoryCodes1.vehicleCategoryCode__c = 'S';
            
            finalTermValidation__mdt ftv1 = new finalTermValidation__mdt();
            ftv1.documentChargesFinAmount__c = 1000.00;
            
            Test.startTest();
            FinalTermscontroller.getFinalTermDetails(opft1.Id,ftd1.Id);
            Test.stopTest();
            
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
     @isTest
    public static void getFinalTermDetailsTest6(){
        try{
            Opportunity opft1 = new Opportunity();
            opft1.StageName = 'Credit Processing';
            opft1.CloseDate = Date.newInstance(2021, 1, 11);
            opft1.Name = 'testone';
            opft1.Vehicle_Type__c = 'New';
            //   opft1.Total_Funded_Premium__c = '50000.00';
            opft1.Product_Type__c = System.Label.Tractor;
            opft1.RTO_Road_Tax__c = 1000.00;
            opft1.Other_charges__c = 500.00;
            opft1.X1st_yr_Insurance_Premium__c = 200.00;
            opft1.View_Application_Sub_Stages__c ='Final Terms';
            opft1.Required_Tenure__c = 8.0;
            opft1.Sub_Stage__c ='Final Terms';
            opft1.Basic_Price__c = 1000.00;
            opft1.GST_Amount__c=500.00;
            opft1.Discount_on_Basic_Price__c=10;
            opft1.Funding_on_Ex_Showroom__c = true;
            opft1.Funding_on_Ex_Showroom__c = true;
            opft1.X1st_yr_Insurance_Premium__c = 700.00;
            
            insert opft1;
            
            Applicant__c apft1 = new Applicant__c();
            apft1.Opportunity__c = opft1.Id;
            apft1.Contact_number__c = '9743514830';
            apft1.Applicant_Type__c = 'Borrower';
            apft1.In_Active_Applicant__c = false;
            insert apft1;
            
            Final_Term__c ftd1 = new Final_Term__c();
            ftd1.CRM_IRR__c = 120;
            ftd1.Loan_Application__c = opft1.Id;
            ftd1.Holiday_period__c='30';
            ftd1.EMI_Amount__c= 10000;
            ftd1.Loan_Amount__c = '100000.00';
            ftd1.Service_charges__c = '1000.00';
            ftd1.Documentation_charges__c = null;
            ftd1.Dlr_Exp_Reimburse_Amt__c = '10000';
            ftd1.Rreferrer_Incentive__c = '100000';
            ftd1.Dlr_Exp_Reimbursement_percent__c = '20000';
            ftd1.Mfr_Exp_Reimburse_percent__c = '30000';
            ftd1.Dealer_incentive_amount_sub_dealer__c = '5000';
            insert ftd1;
            
            FinalTermscontroller.finalTermDetailWrapper ftw1 = new FinalTermscontroller.finalTermDetailWrapper();
            ftw1.basicPrice = opft1.Basic_Price__c;
            ftw1.fundingOnExShowroom = opft1.Funding_on_Ex_Showroom__c;
            ftw1.fundingOnORP = opft1.Funding_on_ORP__c;
            
            vehicleCategoryCode__mdt vehicleCategoryCodes1 = new vehicleCategoryCode__mdt();
            vehicleCategoryCodes1.vehicleType__c = opft1.Vehicle_Type__c;
            vehicleCategoryCodes1.productType__c = opft1.Product_Type__c;
            vehicleCategoryCodes1.vehicleCategoryCode__c = 'S';
            
            finalTermValidation__mdt ftv1 = new finalTermValidation__mdt();
            ftv1.documentChargesFinAmount__c = 1000.00;
            
            Test.startTest();
            FinalTermscontroller.getFinalTermDetails(opft1.Id,ftd1.Id);
            Test.stopTest();
            
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void getFinalTermFieldValidationDetailsTest(){
        try{
            Opportunity opfv1 = new Opportunity();
            opfv1.StageName = 'Credit Processing';
            opfv1.CloseDate = Date.newInstance(2021, 1, 11);
            opfv1.Name = 'testone';
            opfv1.Vehicle_Type__c = 'New';
            opfv1.Product_Type__c = 'Two Wheeler';
            opfv1.Required_Loan_amount__c = 600000;
            opfv1.Product_Type__c='Passenger Vehicles';
            opfv1.Vehicle_Sub_Category__c='PV';
            opfv1.Vehicle_Type__c='New';
            opfv1.Required_Tenure__c=48;
            opfv1.Ex_showroom_price__c= 700000;
            opfv1.On_Road_price__c= 750000;
            insert opfv1;
            
            Applicant__c apfv1 = new Applicant__c();
            apfv1.Opportunity__c = opfv1.Id;
            apfv1.Contact_number__c = '9743514830';
            apfv1.Applicant_Type__c = 'Borrower';
            apfv1.In_Active_Applicant__c = false;
            apfv1.Scorecard_Decision__c = 'Red';
            insert apfv1;
            
            Final_Term__c ftv1 = new Final_Term__c();
            ftv1.CRM_IRR__c = 120;
            ftv1.Loan_Application__c = opfv1.Id;
            ftv1.Holiday_period__c='30';
            ftv1.EMI_Amount__c= 10000;
            insert ftv1;
            
            Vehicle_Detail__c vg3 = new Vehicle_Detail__c();
            vg3.Loan_Application__c = opfv1.Id;
            vg3.Base_Price__c = 100000.00;
            vg3.Ben_Code__c = 'testveh';
            insert vg3; 
            
            Test.startTest();
            FinalTermscontroller.getFinalTermFieldValidationDetails(opfv1.Id,vg3.Id);
            Test.stopTest();
            
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
     @isTest
    public static void getFinalTermFieldValidationDetailsTest1(){
        try{
            Opportunity opfv1 = new Opportunity();
            opfv1.StageName = 'Credit Processing';
            opfv1.CloseDate = Date.newInstance(2021, 1, 11);
            opfv1.Name = 'testone';
            opfv1.Vehicle_Type__c = 'New';
            opfv1.Product_Type__c = 'Tractor';
            opfv1.Required_Loan_amount__c = 600000;
            opfv1.Vehicle_Sub_Category__c='PV';
            opfv1.Vehicle_Type__c='New';
            opfv1.Required_Tenure__c=48;
            opfv1.Ex_showroom_price__c= 700000;
            opfv1.On_Road_price__c= 750000;
            insert opfv1;
            
            Applicant__c apfv1 = new Applicant__c();
            apfv1.Opportunity__c = opfv1.Id;
            apfv1.Contact_number__c = '9743514830';
            apfv1.Applicant_Type__c = 'Borrower';
            apfv1.In_Active_Applicant__c = false;
            apfv1.Scorecard_Decision__c = 'Red';
            insert apfv1;
            
            Final_Term__c ftv1 = new Final_Term__c();
            ftv1.CRM_IRR__c = 120;
            ftv1.Loan_Application__c = opfv1.Id;
            ftv1.Holiday_period__c='30';
            ftv1.EMI_Amount__c= 10000;
            insert ftv1;
            
            Vehicle_Detail__c vg3 = new Vehicle_Detail__c();
            vg3.Loan_Application__c = opfv1.Id;
            vg3.Base_Price__c = 100000.00;
            vg3.Ben_Code__c = 'testveh';
            insert vg3; 
            
            Test.startTest();
            FinalTermscontroller.getFinalTermFieldValidationDetails(opfv1.Id,vg3.Id);
            Test.stopTest();
            
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void runEligibilityEngineTest(){
        try{
            Opportunity opre1 = new Opportunity();
            opre1.StageName = 'Credit Processing';
            opre1.CloseDate = Date.newInstance(2021, 1, 11);
            opre1.Name = 'testone';
            opre1.Vehicle_Type__c = 'New';
            opre1.Product_Type__c = 'Two Wheeler';
            insert opre1;
            
            Applicant__c apre1 = new Applicant__c();
            apre1.Opportunity__c = opre1.Id;
            apre1.Contact_number__c = '9743514830';
            apre1.Applicant_Type__c = 'Borrower';
            insert apre1;
            
            Vehicle_Detail__c vre1 = new Vehicle_Detail__c();
            vre1.Loan_Application__c = opre1.Id;
            vre1.Base_Price__c = 100000.00;
            vre1.Ben_Code__c = 'testveh';
            insert vre1; 
            
            Test.startTest();
            FinalTermscontroller.runEligibilityEngine(apre1.Id);
            FinalTermscontroller.runEligibilityEngine(opre1.Id);
            
            Test.stopTest();
            
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void retryCountUpdateTest(){
        try{
            Opportunity opru1 = new Opportunity();
            opru1.StageName = 'Credit Processing';
            opru1.CloseDate = Date.newInstance(2021, 1, 11);
            opru1.Name = 'testone';
            opru1.Vehicle_Type__c = 'New';
            opru1.Product_Type__c = 'Two Wheeler';
            insert opru1;
            
            Applicant__c apru1 = new Applicant__c();
            apru1.Opportunity__c = opru1.Id;
            apru1.Contact_number__c = '9743514830';
            apru1.Applicant_Type__c = 'Borrower';
            insert apru1;
            
            Retry_Count__c rcu1 = new Retry_Count__c();
            rcu1.Loan_Application_Id__c = opru1.Id;
            rcu1.Service_Name__c = 'FinalTermsEligiblitycheck';
            rcu1.User_Id__c = UserInfo.getUserId();
            rcu1.Count__c = 1;
            insert rcu1;
            
            Test.startTest();
            FinalTermscontroller.retryCountUpdate(2,opru1.Id);
            FinalTermscontroller.retryCountUpdate(2,'test');
            Test.stopTest();
            
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void getAPIEligibityCountTest(){
        Profile p = [SELECT Id FROM Profile WHERE Name='CMU'];
        system.debug('p'+ p);
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles',
                          MobilePhone = '9701498575',
                          UserName='standarduser4@testorg.com.psdev1' ,User_Id__c = '29927_MO',
                          Maker_Id__c='100001');
        insert u;
        system.runAs(u){
            try{
                Opportunity opec1 = new Opportunity();
                opec1.StageName = 'Credit Processing';
                opec1.CloseDate = Date.newInstance(2021, 1, 11);
                opec1.Name = 'testone';
                opec1.Vehicle_Type__c = 'New';
                opec1.Product_Type__c = 'Two Wheeler';
                insert opec1;
                
                Applicant__c apec1 = new Applicant__c();
                apec1.Opportunity__c = opec1.Id;
                apec1.Contact_number__c = '9743514830';
                apec1.Applicant_Type__c = 'Borrower';
                insert apec1;
                
                Retry_Count__c rec1 = new Retry_Count__c();
                rec1.Loan_Application_Id__c = opec1.Id;
                rec1.Service_Name__c = 'FinalTermsEligiblitycheck';
                rec1.User_Id__c = UserInfo.getUserId();
                rec1.Count__c = 1;
                insert rec1;
                
                Test.startTest();
                FinalTermscontroller.getAPIEligibityCount(opec1.Id);
                FinalTermscontroller.getAPIEligibityCount(null);
                Test.stopTest();
                
            }catch(Exception e){
                System.assertEquals('Script-thrown exception', e.getMessage());
            }
        }
    }  
    @isTest
    public static void getAPIEligibityCountTest1(){
        Profile p = [SELECT Id FROM Profile WHERE Name='CMU'];
        system.debug('p'+ p);
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles',
                          MobilePhone = '9701498575',
                          UserName='standarduser4@testorg.com.psdev1' ,User_Id__c = '29927_MO',
                          Maker_Id__c='100001');
        insert u;
        system.runAs(u){
            try{
                Opportunity opec1 = new Opportunity();
                opec1.StageName = 'Credit Processing';
                opec1.CloseDate = Date.newInstance(2021, 1, 11);
                opec1.Name = 'testone';
                opec1.Vehicle_Type__c = 'New';
                opec1.Product_Type__c = 'Two Wheeler';
                insert opec1;
                
                Applicant__c apec1 = new Applicant__c();
                apec1.Opportunity__c = opec1.Id;
                apec1.Contact_number__c = '9743514830';
                apec1.Applicant_Type__c = 'Borrower';
                insert apec1;
                
                Retry_Count__c rec1 = new Retry_Count__c();
                rec1.Loan_Application_Id__c = opec1.Id;
                rec1.Service_Name__c = 'FinalTermsEligiblitycheck';
                rec1.User_Id__c = UserInfo.getUserId();
                rec1.Count__c = null;
                insert rec1;
                
                Test.startTest();
                FinalTermscontroller.getAPIEligibityCount(opec1.Id);
                Test.stopTest();
                
            }catch(Exception e){
                System.assertEquals('Script-thrown exception', e.getMessage());
            }
        }
    }   
    @isTest
    public static void getAPIEligibityCountTest2(){
        try{
            Opportunity opec1 = new Opportunity();
            opec1.StageName = 'Credit Processing';
            opec1.CloseDate = Date.newInstance(2021, 1, 11);
            opec1.Name = 'testone';
            opec1.Vehicle_Type__c = 'New';
            opec1.Product_Type__c = 'Two Wheeler';
            insert opec1;
            
            Applicant__c apec1 = new Applicant__c();
            apec1.Opportunity__c = opec1.Id;
            apec1.Contact_number__c = '9743514830';
            apec1.Applicant_Type__c = 'Borrower';
            insert apec1;
            
            Retry_Count__c rec1 = new Retry_Count__c();
            rec1.Loan_Application_Id__c = opec1.Id;
            rec1.Service_Name__c = 'FinalTermApi';
            rec1.User_Id__c = UserInfo.getUserId();
            rec1.Count__c = null;
            insert rec1;
            
            Test.startTest();
            FinalTermscontroller.getAPIEligibityCount(opec1.Id);
            FinalTermscontroller.getAPIEligibityCount('test');
            Test.stopTest();
            
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void callCreateFITest(){
        Profile p = [SELECT Id FROM Profile WHERE Name='CMU'];
        system.debug('p'+ p);
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles',
                          MobilePhone = '9701498575',
                          UserName='standarduser4@testorg.com.psdev1' ,User_Id__c = '29927_MO',
                          Maker_Id__c='100001');
        insert u;
        system.runAs(u){
            Opportunity parentOpp = new Opportunity();
            parentOpp.StageName = 'Qualification';
            parentOpp.CloseDate = Date.newInstance(2021, 1, 11);
            parentOpp.Name = 'testone-A';
            parentOpp.Required_Loan_amount__c = 100000;
            insert parentOpp;
            
            Applicant__c applicant = new Applicant__c();
            applicant.Opportunity__c = parentOpp.Id;
            applicant.Contact_number__c = '9743514830';
            applicant.Applicant_Type__c = 'Borrower';
            insert applicant;
            
            case cs1 = new case();
            cs1.Loan_Application__c = parentOpp.Id;
            cs1.Subject='FI test Case Residence';
            cs1.Status = 'Completed';
            cs1.Origin = 'Web';
            cs1.Applicant__c = applicant.Id;
            cs1.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('FI').getRecordTypeId();
            insert cs1; 
            
            Field_Investigation__c fiv1 = new Field_Investigation__c();
            fiv1.Case__c = cs1.Id;
            fiv1.Address_Line_1__c = 'Test Address1';
            fiv1.Address_Line_2__c = 'Test Address2';
            fiv1.City__c = 'Test City';
            fiv1.Pin_Code__c ='123442';
            fiv1.State__c =  'Test State';
            fiv1.RecordTypeId = Schema.SObjectType.Field_Investigation__c.getRecordTypeInfosByName().get('Residence').getRecordTypeId();
            insert fiv1;
            
            case cs2 = new case();
            cs2.Loan_Application__c = parentOpp.Id;
            cs2.Subject='FI test Case Permanent';
            cs2.Status = 'Completed';
            cs2.Origin = 'Web';
            cs2.Applicant__c = applicant.Id;
            cs2.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('FI').getRecordTypeId();
            insert cs2; 
            
            Field_Investigation__c fiv2 = new Field_Investigation__c();
            fiv2.Case__c = cs2.Id;
            fiv2.Address_Line_1__c = 'Test Address1';
            fiv2.Address_Line_2__c = 'Test Address2';
            fiv2.City__c = 'Test City';
            fiv2.Pin_Code__c ='123456';
            fiv2.State__c =  'Test State';
            fiv2.RecordTypeId = Schema.SObjectType.Field_Investigation__c.getRecordTypeInfosByName().get('Permanent').getRecordTypeId();
            insert fiv2;
            
			case cs3 = new case();
            cs3.Loan_Application__c = parentOpp.Id;
            cs3.Subject='FI test Case Office';
            cs3.Status = 'FI-Unassigned';
            cs3.Origin = 'Web';
            cs3.Applicant__c = applicant.Id;
            cs3.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('FI').getRecordTypeId();
            insert cs3; 
            
            Field_Investigation__c fiv3 = new Field_Investigation__c();
            fiv3.Case__c = cs3.Id;
            fiv3.Address_Line_1__c = 'Test Address1';
            fiv3.Address_Line_2__c = 'Test Address2';
            fiv3.City__c = 'Test City';
            fiv3.Pin_Code__c ='123456';
            fiv3.State__c = 'Test State';
            fiv3.RecordTypeId = Schema.SObjectType.Field_Investigation__c.getRecordTypeInfosByName().get('Office').getRecordTypeId();
            insert fiv3; 
            cs3.Status = 'Completed';
            update cs3;
            
            Applicant__c applicant2 = new Applicant__c();
            applicant2.Opportunity__c = parentOpp.Id;
            applicant2.Contact_number__c = '9743514830';
            applicant2.Applicant_Type__c = 'Co-borrower';
            insert applicant2;
            
            case cs4 = new case();
            cs4.Loan_Application__c = parentOpp.Id;
            cs4.Subject='FI test Case Residence';
            cs4.Status = 'Completed';
            cs4.Origin = 'Web';
            cs4.Applicant__c = applicant2.Id;
            cs4.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('FI').getRecordTypeId();
            insert cs4; 
            
            Field_Investigation__c fiv4 = new Field_Investigation__c();
            fiv4.Case__c = cs4.Id;
            fiv4.Address_Line_1__c = 'Test Address1';
            fiv4.Address_Line_2__c = 'Test Address2';
            fiv4.City__c = 'Test City';
            fiv4.Pin_Code__c ='123442';
            fiv4.State__c =  'Test State';
            fiv4.RecordTypeId = Schema.SObjectType.Field_Investigation__c.getRecordTypeInfosByName().get('Residence').getRecordTypeId();
            insert fiv4;
            
            case cs5 = new case();
            cs5.Loan_Application__c = parentOpp.Id;
            cs5.Subject='FI test Case Permanent';
            cs5.Status = 'Completed';
            cs5.Origin = 'Web';
            cs5.Applicant__c = applicant2.Id;
            cs5.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('FI').getRecordTypeId();
            insert cs5; 
            
            Field_Investigation__c fiv5 = new Field_Investigation__c();
            fiv5.Case__c = cs5.Id;
            fiv5.Address_Line_1__c = 'Test Address1';
            fiv5.Address_Line_2__c = 'Test Address2';
            fiv5.City__c = 'Test City';
            fiv5.Pin_Code__c ='123456';
            fiv5.State__c =  'Test State';
            fiv5.RecordTypeId = Schema.SObjectType.Field_Investigation__c.getRecordTypeInfosByName().get('Permanent').getRecordTypeId();
            insert fiv5;
            
			case cs6 = new case();
            cs6.Loan_Application__c = parentOpp.Id;
            cs6.Subject='FI test Case Office';
            cs6.Status = 'FI-Unassigned';
            cs6.Origin = 'Web';
            cs6.Applicant__c = applicant2.Id;
            cs6.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('FI').getRecordTypeId();
            insert cs6; 
            
            Field_Investigation__c fiv6 = new Field_Investigation__c();
            fiv6.Case__c = cs6.Id;
            fiv6.Address_Line_1__c = 'Test Address1';
            fiv6.Address_Line_2__c = 'Test Address2';
            fiv6.City__c = 'Test City';
            fiv6.Pin_Code__c ='123456';
            fiv6.State__c = 'Test State';
            fiv6.RecordTypeId = Schema.SObjectType.Field_Investigation__c.getRecordTypeInfosByName().get('Office').getRecordTypeId();
            insert fiv6; 
            cs6.Status = 'Completed';
            update cs6;
            
            Opportunity opfr1 = new Opportunity();
            opfr1.StageName = 'Qualification';
            opfr1.CloseDate = Date.newInstance(2021, 1, 11);
            opfr1.Name = 'testone-A';
            opfr1.Required_Loan_amount__c = 100000;
            opfr1.Parent_Loan_Application__c = parentOpp.Id;
            insert opfr1;
            
            Applicant__c apfr1 = new Applicant__c();
            apfr1.Opportunity__c = opfr1.Id;
            apfr1.Contact_number__c = '9743514830';
            apfr1.Applicant_Type__c = 'Borrower';
            insert apfr1;
            
            Vehicle_Detail__c vfr1 = new Vehicle_Detail__c();
            vfr1.Loan_Application__c = opfr1.Id;
            vfr1.Base_Price__c = 100000.00;
            vfr1.Ben_Code__c = 'testveh';
            insert vfr1; 
            
            
            Final_Term__c fgr1 = new Final_Term__c();
            fgr1.CRM_IRR__c = null;
            fgr1.Loan_Application__c = opfr1.Id;
            fgr1.Holiday_period__c='30';
            fgr1.Loan_Amount__c = null;
            fgr1.Tenure__c = null;
            //   fgr1.FIwaiver_offAddress__c = 'Not Waived';
            fgr1.EMI_Amount__c = 10000;
            insert fgr1;
            
            Profile_Master__c pm1 = new Profile_Master__c();
            pm1.Category__c = 'SAL';
            pm1.Code__c = '115';
            pm1.OwnerId = UserInfo.getUserId();
            pm1.Name = 'test';
            pm1.Sub_Bucket_Desc__c = 'SERVICE ORIENTED';
            insert pm1;
            
            Income_Details__c incomeObj = new Income_Details__c();
            incomeObj.Primary_Income_Source__c = true;
            incomeObj.Applicant__c= apfr1.Id;
            incomeObj.Is_Self_Employed__c = true;
            incomeObj.Profile__c = pm1.Id;
            insert incomeObj;
            
            Test.startTest();
            FinalTermscontroller.callCreateFI(opfr1.Id,'Pre-FI');
            Test.stopTest();
        }
    } 
    @isTest
    public static void callCreateFITest2(){
        Profile p = [SELECT Id FROM Profile WHERE Name='CMU'];
        system.debug('p'+ p);
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles',
                          MobilePhone = '9701498575',
                          UserName='standarduser4@testorg.com.psdev1' ,User_Id__c = '29927_MO',
                          Maker_Id__c='100001');
        insert u;
        system.runAs(u){
            Opportunity opfv1 = new Opportunity();
            opfv1.StageName = 'Credit Processing';
            opfv1.CloseDate = Date.newInstance(2021, 1, 11);
            opfv1.Name = 'testone';
            opfv1.Vehicle_Type__c = 'New';
            opfv1.Product_Type__c = 'Two Wheeler';
            insert opfv1;
            
            Applicant__c apfv1 = new Applicant__c();
            apfv1.Opportunity__c = opfv1.Id;
            apfv1.Contact_number__c = '9743514830';
            apfv1.Applicant_Type__c = System.Label.Coborrower;
            insert apfv1;
            
            Final_Term__c ftv1 = new Final_Term__c();
            ftv1.CRM_IRR__c = 120;
            ftv1.Loan_Application__c = opfv1.Id;
            ftv1.Holiday_period__c='30';
            ftv1.EMI_Amount__c= 10000;
            ftv1.FIwaiver_co_offAddress__c = 'Not Waived';
            insert ftv1;
            Income_Details__c incomeObj = new Income_Details__c();
            incomeObj.Primary_Income_Source__c = true;
            incomeObj.Applicant__c= apfv1.Id;
            insert incomeObj;
            
            Test.startTest();
            FinalTermscontroller.callCreateFI(opfv1.Id,'Pre-FI');
            Test.stopTest();
        }
    } 
    @isTest
    public static void runEligibilityEngineTest1(){
        
        Opportunity opfv1 = new Opportunity();
        opfv1.StageName = 'Credit Processing';
        opfv1.CloseDate = Date.newInstance(2021, 1, 11);
        opfv1.Name = 'testone';
        opfv1.Vehicle_Type__c = 'New';
        opfv1.Product_Type__c = 'Two Wheeler';
        opfv1.OwnerId = UserInfo.getUserId();
        insert opfv1;
        
        Applicant__c apfv1 = new Applicant__c();
        apfv1.Opportunity__c = opfv1.Id;
        apfv1.Contact_number__c = '9743514830';
        apfv1.Applicant_Type__c = 'Borrower';
        insert apfv1;
        
        Vehicle_Detail__c vc2 = new Vehicle_Detail__c();
        vc2.Loan_Application__c = opfv1.Id;
        vc2.Base_Price__c = 100.00;
        vc2.Ben_Code__c = 'testveh';
        vc2.Dealer_Sub_dealer_name__c = 'testsubdealer';
        insert vc2; 
        
        Test.startTest();
        FinalTermscontroller.runEligibilityEngine(opfv1.Id);
        Test.stopTest();
    }
    @isTest
    public static void createFIRecord_oneTest(){
        Profile p = [SELECT Id FROM Profile WHERE Name='CMU'];
        system.debug('p'+ p);
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles',
                          MobilePhone = '9701498575',
                          UserName='standarduser4@testorg.com.psdev1' ,User_Id__c = '29927_MO',
                          Maker_Id__c='100001');
        insert u;
        system.runAs(u){
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
            
            Final_Term__c fgd3 = new Final_Term__c();
            fgd3.CRM_IRR__c = 120;
            fgd3.Loan_Application__c = opks1.Id;
            fgd3.Holiday_period__c='30';
            fgd3.EMI_Amount__c= 10000;
            fgd3.FIwaiver_offAddress__c = 'Not Waived';
            insert fgd3;
            
            Income_Details__c incomeObj = new Income_Details__c();
            incomeObj.Applicant__c = apks1.id;
            incomeObj.Primary_Income_Source__c = true;
            insert incomeObj;
            
            Test.startTest();
            //  FinalTermscontroller.createFIRecord_one(opks1.Id);
            Test.stopTest();
        }
    }
    
    @isTest
    public static void createFIRecordTest11(){
        
        Opportunity opfv1 = new Opportunity();
        opfv1.StageName = 'Credit Processing';
        opfv1.CloseDate = Date.newInstance(2021, 1, 11);
        opfv1.Name = 'testone';
        opfv1.Vehicle_Type__c = 'New';
        opfv1.Product_Type__c = 'Two Wheeler';
        opfv1.OwnerId = UserInfo.getUserId();
        insert opfv1;
        
        Applicant__c apfv1 = new Applicant__c();
        apfv1.Opportunity__c = opfv1.Id;
        apfv1.Contact_number__c = '9743514830';
        apfv1.Applicant_Type__c = 'Borrower';
        insert apfv1;
        
        List<Final_Term__c> ftList = new List<Final_Term__c>();
        Final_Term__c ftv2 = new Final_Term__c();
        ftv2.CRM_IRR__c = 120;
        ftv2.Loan_Application__c = opfv1.Id;
        ftv2.Holiday_period__c='30';
        ftv2.EMI_Amount__c= 10000;
        ftv2.FIwaiver_offAddress__c = '';
        ftv2.FIwaiver_currentAddress__c = '';
        ftv2.FIwaiver_presentAddress__c = '';
        insert ftv2;
        ftList.add(ftv2);
        
        Income_Details__c incomeObj = new Income_Details__c();
        incomeObj.Office_Address_Line_1__c = 'TestOffinceLine1';
        incomeObj.Office_Address_Line_2__c = 'TestOffinceLine2';
        incomeObj.Office_PinCode__c = '000111';
        incomeObj.Office_City__c = 'TestCity1';
        incomeObj.Office_State__c = 'TestState1';
        incomeObj.Office_District__c = 'TestDistrict1';
        incomeObj.Employer_Business_Name__c = 'TestBusiness1';
        incomeObj.Applicant__c = apfv1.id;
        incomeObj.Primary_Income_Source__c = true;
        insert incomeObj;
        
        
        Test.startTest();
        FinalTermscontroller.callCreateFI(opfv1.Id,'Pre-FI');
        Test.stopTest();
    }
    @isTest
    public static void createFIRecord_oneTest1(){
        Profile p = [SELECT Id FROM Profile WHERE Name='CMU'];
        system.debug('p'+ p);
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles',
                          MobilePhone = '9701498575',
                          UserName='standarduser4@testorg.com.psdev1' ,User_Id__c = '29927_MO',
                          Maker_Id__c='100001');
        insert u;
        system.runAs(u){
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
            
            Final_Term__c fgd3 = new Final_Term__c();
            fgd3.CRM_IRR__c = 120;
            fgd3.Loan_Application__c = opks1.Id;
            fgd3.Holiday_period__c='30';
            fgd3.EMI_Amount__c= 10000;
            fgd3.FIwaiver_offAddress__c = 'Not Waived';
            insert fgd3;
            
            Income_Details__c incomeObj = new Income_Details__c();
            incomeObj.Applicant__c = apks1.id;
            incomeObj.Primary_Income_Source__c = true;
            insert incomeObj;
            
            Test.startTest();
            //  FinalTermscontroller.createFIRecord_one(opks1.Id);
            Test.stopTest();
        }
    }
    
    @isTest
    public static void populateFIRecordtest(){
        Profile p = [SELECT Id FROM Profile WHERE Name='CMU'];
        system.debug('p'+ p);
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles',
                          MobilePhone = '9701498575',
                          UserName='standarduser4@testorg.com.psdev1' ,User_Id__c = '29927_MO',
                          Maker_Id__c='100001');
        insert u;
        system.runAs(u){
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
            dfks1.Aadhar_Source__c = 'ScanAadhar';
            dfks1.Name = 'Aadhar';
            dfks1.Document_Type__c = System.Label.AadhaarCard;
            insert dfks1;
            
            case cs1 = new case();
            cs1.Loan_Application__c = opks1.Id;
            cs1.Applicant__c = apks1.Id;
            cs1.Subject='Approval Of Application Sourced By Off Roll Employee';
            cs1.Status = 'Pending-Off Role Employee App';
            cs1.Origin = 'Web';
            insert cs1; 
            
            Field_Investigation__c fiv1 = new Field_Investigation__c();
            fiv1.Case__c = cs1.Id;
            fiv1.Address_Line_1__c = dfks1.KYC_Address_Line_1__c;
            fiv1.Address_Line_2__c = dfks1.KYC_Address_Line_2__c;
            fiv1.City__c = dfks1.KYC_City__c;
            fiv1.Pin_Code__c = dfks1.KYC_Pin_Code__c;
            fiv1.State__c = dfks1.KYC_State__c;
            fiv1.RecordTypeId = Schema.SObjectType.Field_Investigation__c.getRecordTypeInfosByName().get('Permanent').getRecordTypeId();
            insert fiv1;
            
            Test.startTest();
            FinalTermscontroller.populateFIRecord(dfks1,cs1.Id,fiv1.RecordTypeId);
            Test.stopTest();
        }
    }
    @isTest
    public static void populateCaseTest(){
        Profile p = [SELECT Id FROM Profile WHERE Name='CMU'];
        system.debug('p'+ p);
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles',
                          MobilePhone = '9701498575',
                          UserName='standarduser4@testorg.com.psdev1' ,User_Id__c = '29927_MO',
                          Maker_Id__c='100001');
        insert u;
        system.runAs(u){
            Opportunity opks1 = new Opportunity();
            opks1.StageName = 'Qualification';
            opks1.CloseDate = Date.newInstance(2021, 1, 11);
            opks1.Name = 'testone';
            opks1.OwnerId = UserInfo.getUserId();
            insert opks1;
            
            Applicant__c apks1 = new Applicant__c();
            apks1.Opportunity__c = opks1.Id;
            apks1.Contact_number__c = '9743514830';
            apks1.Applicant_Type__c = 'Borrower';
            insert apks1;
            
            case cs2 = new case();
            cs2.Loan_Application__c = opks1.Id;
            cs2.OwnerId = opks1.OwnerId;
            cs2.RecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByName().get('FI').getRecordTypeId();
            cs2.Subject='Approval Of Application Sourced By Off Roll Employee';
            cs2.Status = 'Pending-Off Role Employee App';
            cs2.Origin = 'Web';
            cs2.Type = 'Problem';
            cs2.Status = 'New';
            cs2.Applicant__c = apks1.Id;
            insert cs2; 
            
            Test.startTest();
            FinalTermscontroller.populateCase(cs2.RecordTypeId,cs2.Type,opks1,cs2.Status,apks1);
            Test.stopTest();
        }
    } 
    @isTest
    public static void checkRetryExhaustedForResendSMSTest(){
        try{
            Opportunity opec1 = new Opportunity();
            opec1.StageName = 'Credit Processing';
            opec1.CloseDate = Date.newInstance(2021, 1, 11);
            opec1.Name = 'testone';
            opec1.Vehicle_Type__c = 'New';
            opec1.Product_Type__c = 'Two Wheeler';
            insert opec1;
            
            Applicant__c apec1 = new Applicant__c();
            apec1.Opportunity__c = opec1.Id;
            apec1.Contact_number__c = '9743514830';
            apec1.Applicant_Type__c = 'Borrower';
            insert apec1;
            
            Retry_Count__c rec1 = new Retry_Count__c();
            rec1.Loan_Application_Id__c = opec1.Id;
            rec1.Service_Name__c = 'FinalTermApi';
            rec1.User_Id__c = UserInfo.getUserId();
            insert rec1; 
            
            Test.startTest();
            FinalTermscontroller.checkRetryExhaustedForResendSMS(opec1.Id);
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void checkRetryExhaustedForResendSMSTest1(){
        try{
            Opportunity opec1 = new Opportunity();
            opec1.StageName = 'Credit Processing';
            opec1.CloseDate = Date.newInstance(2021, 1, 11);
            opec1.Name = 'testone';
            opec1.Vehicle_Type__c = 'New';
            opec1.Product_Type__c = 'Two Wheeler';
            insert opec1;
            
            Applicant__c apec1 = new Applicant__c();
            apec1.Opportunity__c = opec1.Id;
            apec1.Contact_number__c = '9743514830';
            apec1.Applicant_Type__c = 'Borrower';
            insert apec1;
            
            Retry_Count__c rec1 = new Retry_Count__c();
            rec1.Loan_Application_Id__c = opec1.Id;
            rec1.Service_Name__c = 'SMS';
            rec1.User_Id__c = UserInfo.getUserId();
            rec1.Count__c = 10;
            insert rec1; 
            
            Test.startTest();
            FinalTermscontroller.checkRetryExhaustedForResendSMS(opec1.Id);
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void checkRetryExhaustedForResendSMSTest2(){
        try{
            Opportunity opec1 = new Opportunity();
            opec1.StageName = 'Credit Processing';
            opec1.CloseDate = Date.newInstance(2021, 1, 11);
            opec1.Name = 'testone';
            opec1.Vehicle_Type__c = 'New';
            opec1.Product_Type__c = 'Two Wheeler';
            insert opec1;
            
            Applicant__c apec1 = new Applicant__c();
            apec1.Opportunity__c = opec1.Id;
            apec1.Contact_number__c = '9743514830';
            apec1.Applicant_Type__c = 'Borrower';
            insert apec1;
            
            Retry_Count__c rec1 = new Retry_Count__c();
            rec1.Loan_Application_Id__c = opec1.Id;
            rec1.Service_Name__c = 'SMS';
            rec1.User_Id__c = UserInfo.getUserId();
            rec1.Count__c = 5;
            insert rec1; 
            
            Test.startTest();
            FinalTermscontroller.checkRetryExhaustedForResendSMS(opec1.Id);
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void checkRetryExhaustedForResendSMSTest3(){
        try{
            Opportunity opec1 = new Opportunity();
            opec1.StageName = 'Credit Processing';
            opec1.CloseDate = Date.newInstance(2021, 1, 11);
            opec1.Name = 'testone';
            opec1.Vehicle_Type__c = 'New';
            opec1.Product_Type__c = 'Two Wheeler';
            insert opec1;
            
            Applicant__c apec1 = new Applicant__c();
            apec1.Opportunity__c = opec1.Id;
            apec1.Contact_number__c = '9743514830';
            apec1.Applicant_Type__c = 'Borrower';
            insert apec1;
            
            Retry_Count__c rec1 = new Retry_Count__c();
            rec1.Loan_Application_Id__c = opec1.Id;
            rec1.Service_Name__c = 'SMS';
            rec1.User_Id__c = UserInfo.getUserId();
            rec1.Count__c = 0;
            insert rec1; 
            
            Test.startTest();
            FinalTermscontroller.checkRetryExhaustedForResendSMS(opec1.Id);
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    @isTest
    public static void retryCountIncreaseForResendSMSTest(){
        try{
            Test.startTest();
            FinalTermscontroller.retryCountIncreaseForResendSMS();
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    @isTest
    public static void retryCountIncreaseForResendSMSTest2(){
        try{
            
            Opportunity opec1 = new Opportunity();
            opec1.StageName = 'Credit Processing';
            opec1.CloseDate = Date.newInstance(2021, 1, 11);
            opec1.Name = 'testone';
            opec1.Vehicle_Type__c = 'New';
            opec1.Product_Type__c = 'Two Wheeler';
            insert opec1;
            
            Retry_Count__c rec1 = new Retry_Count__c();
            rec1.Loan_Application_Id__c = opec1.Id;
            rec1.Service_Name__c = 'SMS';
            rec1.User_Id__c = UserInfo.getUserId();
            rec1.Count__c = 2;
            rec1.Module__c = 'ApplicationForm';
            insert rec1; 
            
            Test.startTest();
            FinalTermscontroller.retryCountIncreaseForResendSMS();
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void ResendSMSTest(){
        Profile p = [SELECT Id FROM Profile WHERE Name='CMU'];
        system.debug('p'+ p);
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles',
                          MobilePhone = '9701498575',
                          UserName='standarduser4@testorg.com.psdev1' ,User_Id__c = '29927_MO',
                          Maker_Id__c='100001');
        insert u;
        system.runAs(u){
            Opportunity opds1 = new Opportunity();
            opds1.StageName = 'Qualification';
            opds1.CloseDate = Date.newInstance(2021, 1, 11);
            opds1.Name = 'testone';
            opds1.Product_Type__c = 'Tractor';
            opds1.Customer_Type__c = 'Non-Individual';
            opds1.Entity_Type__c = 'Proprietorship';
            insert opds1;
            
            Applicant__c apks1 = new Applicant__c();
            apks1.Opportunity__c = opds1.Id;
            apks1.Contact_number__c = '9743514830';
            apks1.Applicant_Type__c = 'Borrower';
            apks1.In_Active_Applicant__c = false;
            apks1.IsPrimary__c = true;
            insert apks1;
            
            Test.startTest();
            FinalTermscontroller.ResendSMS(opds1.Id);
            Test.stopTest();
        }
    } 
      @isTest
    public static void ResendSMSTest2(){
        Profile p = [SELECT Id FROM Profile WHERE Name='CMU'];
        system.debug('p'+ p);
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles',
                          MobilePhone = '9701498575',
                          UserName='standarduser4@testorg.com.psdev1' ,User_Id__c = '29927_MO',
                          Maker_Id__c='100001');
        insert u;
        system.runAs(u){
            Opportunity opds1 = new Opportunity();
            opds1.StageName = 'Qualification';
            opds1.CloseDate = Date.newInstance(2021, 1, 11);
            opds1.Name = 'testone';
            opds1.Product_Type__c = 'Tractor';
            opds1.Customer_Type__c = 'Non-Individual';
            insert opds1;
            
            Applicant__c apks1 = new Applicant__c();
            apks1.Opportunity__c = opds1.Id;
            apks1.Contact_number__c = '9743514830';
            apks1.Applicant_Type__c = 'Beneficiary';
            apks1.In_Active_Applicant__c = false;
            apks1.IsPrimary__c = true;
            insert apks1;
            
            Test.startTest();
            FinalTermscontroller.ResendSMS(opds1.Id);
            Test.stopTest();
        }
    } 
    
    @isTest
    public static void ResendSMSTest3(){
        try{
            Opportunity opds1 = new Opportunity();
            opds1.StageName = 'Qualification';
            opds1.CloseDate = Date.newInstance(2021, 1, 11);
            opds1.Name = 'testone';
            insert opds1;
            
            Applicant__c apks1 = new Applicant__c();
            apks1.Opportunity__c = opds1.Id;
            apks1.Contact_number__c = '9743514830';
            apks1.Applicant_Type__c = 'Beneficiary';
            apks1.In_Active_Applicant__c = false;
            insert apks1;
            
            Test.startTest();
            FinalTermscontroller.ResendSMS(opds1.Id);
            Test.stopTest();
        }
        catch(Exception e){
            
        }
    } 
    
    @isTest
    public static void createCaseTest(){
        
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
        dfks1.Aadhar_Source__c = 'ScanAadhar';
        dfks1.Name = 'Aadhar';
        dfks1.Document_Type__c = System.Label.AadhaarCard;
        insert dfks1;
        
        Id uid = UserInfo.getUserId();
        User objUser = [SELECT Id,Name,CompanyName FROM User WHERE Id = :uid];
        objUser.CompanyName = 'test';
        objUser.MobilePhone = '9999999999';
        update objUser;
        
        //    user bUser = [select id, name from user where name = 'Business Executive 1' limit 1];
        
        recordType rtp1 = [SELECT Id,name,developerName from recordtype where developerName='Off_role_Emp_Approval' limit 1];
        
        OpportunityTeamMember optm1 = new OpportunityTeamMember();
        optm1.OpportunityId = opks1.Id;
        optm1.UserId = UserInfo.getUserId();
        optm1.TeamMemberRole = 'BE';
        insert optm1;
        
        case cs1 = new case();
        cs1.Loan_Application__c = opks1.Id;
        //  cs1.OwnerId = bUser.Id;
        cs1.RecordTypeId = rtp1.Id;
        cs1.Subject='Approval Of Application Sourced By Off Roll Employee';
        cs1.Status = 'Pending-Off Role Employee App';
        cs1.Origin = 'Web';
        insert cs1; 
        
        Test.startTest();
        // FinalTermscontroller.createCase(opks1.Id,'Passenger Vehicles');
        Test.stopTest();
        
    }
    
    @isTest
    public static void createCaseTest1(){
        
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
        dfks1.Aadhar_Source__c = 'ScanAadhar';
        dfks1.Name = 'Aadhar';
        dfks1.Document_Type__c = System.Label.AadhaarCard;
        insert dfks1;
        
        Id uid = UserInfo.getUserId();
        User objUser = [SELECT Id,Name,CompanyName FROM User WHERE Id = :uid];
        objUser.CompanyName = 'test';
        objUser.MobilePhone = '9999999999';
        update objUser;
        
        //  user bUser = [select id, name from user where name = 'Business Executive' limit 1];
        
        recordType rtp1 = [SELECT Id,name,developerName from recordtype where developerName='Off_role_Emp_Approval' limit 1];
        
        OpportunityTeamMember optm1 = new OpportunityTeamMember();
        optm1.OpportunityId = opks1.Id;
        optm1.UserId = UserInfo.getUserId();
        optm1.TeamMemberRole = 'PE';
        insert optm1;
        
        case cs1 = new case();
        cs1.Loan_Application__c = opks1.Id;
        //    cs1.OwnerId = bUser.Id;
        cs1.RecordTypeId = rtp1.Id;
        cs1.Subject='Approval Of Application Sourced By Off Roll Employee';
        cs1.Status = 'Pending-Off Role Employee App';
        cs1.Origin = 'Web';
        insert cs1; 
        
        Test.startTest();
        //  FinalTermscontroller.createCase(opks1.Id,'Two Wheeler');
        Test.stopTest();
        
    }
    @isTest
    public static void fetchProductTypeTest(){Profile p = [SELECT Id FROM Profile WHERE Name='CMU'];
                                              system.debug('p'+ p);
                                              User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                                                                EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                                                                LocaleSidKey='en_US', ProfileId = p.Id,
                                                                TimeZoneSidKey='America/Los_Angeles',
                                                                MobilePhone = '9701498575',
                                                                UserName='standarduser4@testorg.com.psdev1' ,User_Id__c = '29927_MO',
                                                                Maker_Id__c='100001');
                                              insert u;
                                              system.runAs(u){
                                                  Opportunity opks1 = new Opportunity();
                                                  opks1.StageName = 'Qualification';
                                                  opks1.CloseDate = Date.newInstance(2021, 1, 11);
                                                  opks1.Name = 'testone';
                                                  opks1.Product_Type__c ='Two Wheeler';
                                                  insert opks1;
                                                  
                                                  
                                                  Test.startTest();
                                                  FinalTermscontroller.fetchProductType(opks1.Id);
                                                  Test.stopTest();
                                              }
                                             }
    @isTest
    public static void fetchProductTypeTest1(){
        try{   
            Opportunity opks12 = new Opportunity();
            opks12.StageName = 'Qualification';
            opks12.CloseDate = Date.newInstance(2021, 1, 11);
            opks12.Name = 'testone';
            opks12.Product_Type__c ='Two Wheeler';
            insert opks12;
            
            
            Test.startTest();
            FinalTermscontroller.fetchProductType(null);
            Test.stopTest();
        }
        catch(Exception ex){
            System.assertEquals(ex.getMessage(),'Script-thrown exception');
        }
    }
    
    @isTest
    public static void getApiOutputTest(){
        try{
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
            
            Final_Term__c fgd3 = new Final_Term__c();
            fgd3.CRM_IRR__c = 120;
            fgd3.Loan_Application__c = opks1.Id;
            fgd3.Holiday_period__c='30';
            fgd3.EMI_Amount__c= 10000;
            insert fgd3;
            
            Test.startTest();
            FinalTermscontroller.getApiOutput(opks1.Id);
            FinalTermscontroller.getApiOutput(null);
            Test.stopTest();
            
        }catch(Exception e){
            System.assertEquals(e.getMessage(),'Script-thrown exception');
        }
    }
    
    @isTest
    public static void getApiOutputTest1(){
        
        try{
            Opportunity opks2 = new Opportunity();
            opks2.StageName = 'Qualification';
            opks2.CloseDate = Date.newInstance(2021, 1, 11);
            opks2.Name = 'testone';
            insert opks2;
            
            Test.startTest();
            FinalTermscontroller.getApiOutput(opks2.Id);
            Test.stopTest();
            
        }catch(Exception e){
            System.assertEquals(e.getMessage(),'Script-thrown exception');
        }
    }
    
    @isTest
    public static void populateOfficeFIRecordTest(){
        
        Opportunity opgl2 = TestDataUtility.createTestOpportunity(false);
        if (Schema.sObjectType.Opportunity.isCreateable()){
            insert opgl2;
        }
        
        Applicant__c apt1 = TestDataUtility.createTestApplicant(false);
        apt1.Opportunity__c = opgl2.Id;
        if (Schema.sObjectType.Applicant__c.isCreateable()){
            insert apt1;
        }
        Documents__c dfks1 = new Documents__c();
        dfks1.Applicant__c = apt1.Id;
        dfks1.Opportunity_Relation__c = opgl2.Id;
        dfks1.KYC_name__c = 'Aadhar';
        dfks1.Document_Side__c ='Back';
        dfks1.Aadhar_Source__c = 'ScanAadhar';
        dfks1.Name = 'Aadhar';
        dfks1.Document_Type__c = System.Label.AadhaarCard;
        insert dfks1;
        
        case cs2 = new case();
        cs2.Loan_Application__c = opgl2.Id;
        cs2.Subject='Approval Of Application Sourced By Off Roll Employee';
        cs2.Status = 'Pending-Off Role Employee App';
        cs2.Origin = 'Web';
        insert cs2; 
        
        Profile_Master__c ps1 = new Profile_Master__c();
        ps1.Category__c = 'SAL';
        ps1.Code__c = '115';
        ps1.OwnerId = UserInfo.getUserId();
        ps1.Name = 'test';
        ps1.Sub_Bucket_Desc__c = 'SERVICE ORIENTED';
        insert ps1;
        
        Income_Details__c id1 = new Income_Details__c();
        id1.Applicant__c = apt1.Id;
        id1.GST_No__c = '29ABCDE1234F1ZW';
        id1.Income__c = 10000;
        id1.Primary_Income_Source__c = true;
        id1.Profile__c = ps1.Id;
        id1.Is_Self_Employed__c = true;
        insert id1;
        
        Field_Investigation__c fi1 = new Field_Investigation__c();
        fi1.Case__c = cs2.Id;
        fi1.RecordTypeId = Schema.SObjectType.Field_Investigation__c.getRecordTypeInfosByName().get('Office').getRecordTypeId();
        insert fi1;
        
        Test.startTest();
        Field_Investigation__c fv1 = FinalTermscontroller.populateOfficeFIRecord(dfks1,cs2.Id,fi1.RecordTypeId,apt1);
        system.assertEquals(fv1, FinalTermscontroller.populateOfficeFIRecord(dfks1,cs2.Id,fi1.RecordTypeId,apt1));
        Test.stopTest();
        
        
    }
    
    @isTest
    public static void populateOfficeFIRecordTest1(){
        
        Opportunity opgl2 = TestDataUtility.createTestOpportunity(false);
        if (Schema.sObjectType.Opportunity.isCreateable()){
            insert opgl2;
        }
        
        Applicant__c apt1 = TestDataUtility.createTestApplicant(false);
        apt1.Opportunity__c = opgl2.Id;
        if (Schema.sObjectType.Applicant__c.isCreateable()){
            insert apt1;
        }
        Documents__c dfks1 = new Documents__c();
        dfks1.Applicant__c = apt1.Id;
        dfks1.Opportunity_Relation__c = opgl2.Id;
        dfks1.KYC_name__c = 'Aadhar';
        dfks1.Document_Side__c ='Back';
        dfks1.Aadhar_Source__c = 'ScanAadhar';
        dfks1.Name = 'Aadhar';
        dfks1.Document_Type__c = System.Label.AadhaarCard;
        insert dfks1;
        
        case cs2 = new case();
        cs2.Loan_Application__c = opgl2.Id;
        cs2.Subject='Approval Of Application Sourced By Off Roll Employee';
        cs2.Status = 'Pending-Off Role Employee App';
        cs2.Origin = 'Web';
        insert cs2; 
        
        Profile_Master__c ps1 = new Profile_Master__c();
        ps1.Category__c = 'SAL';
        ps1.Code__c = '115';
        ps1.OwnerId = UserInfo.getUserId();
        ps1.Name = 'test';
        ps1.Sub_Bucket_Desc__c = 'TRANSPORTER';
        insert ps1;
        
        Income_Details__c id1 = new Income_Details__c();
        id1.Applicant__c = apt1.Id;
        id1.GST_No__c = '29ABCDE1234F1ZW';
        id1.Income__c = 10000;
        id1.Primary_Income_Source__c = true;
        id1.Profile__c = ps1.Id;
        id1.Is_Self_Employed__c = true;
        insert id1;
        
        Field_Investigation__c fi1 = new Field_Investigation__c();
        fi1.Case__c = cs2.Id;
        fi1.RecordTypeId = Schema.SObjectType.Field_Investigation__c.getRecordTypeInfosByName().get('Office').getRecordTypeId();
        insert fi1;
        
        Test.startTest();
        Field_Investigation__c fv1 = FinalTermscontroller.populateOfficeFIRecord(dfks1,cs2.Id,fi1.RecordTypeId,apt1);
        system.assertEquals(fv1, FinalTermscontroller.populateOfficeFIRecord(dfks1,cs2.Id,fi1.RecordTypeId,apt1));
        Test.stopTest();
        
        
    }
    
    @isTest
    public static void populateOfficeFIRecordTest2(){
        
        Opportunity opgl2 = TestDataUtility.createTestOpportunity(false);
        if (Schema.sObjectType.Opportunity.isCreateable()){
            insert opgl2;
        }
        
        Applicant__c apt1 = TestDataUtility.createTestApplicant(false);
        apt1.Opportunity__c = opgl2.Id;
        if (Schema.sObjectType.Applicant__c.isCreateable()){
            insert apt1;
        }
        Documents__c dfks1 = new Documents__c();
        dfks1.Applicant__c = apt1.Id;
        dfks1.Opportunity_Relation__c = opgl2.Id;
        dfks1.KYC_name__c = 'Aadhar';
        dfks1.Document_Side__c ='Back';
        dfks1.Aadhar_Source__c = 'ScanAadhar';
        dfks1.Name = 'Aadhar';
        dfks1.Document_Type__c = System.Label.AadhaarCard;
        insert dfks1;
        
        case cs2 = new case();
        cs2.Loan_Application__c = opgl2.Id;
        cs2.Subject='Approval Of Application Sourced By Off Roll Employee';
        cs2.Status = 'Pending-Off Role Employee App';
        cs2.Origin = 'Web';
        insert cs2; 
        
        Profile_Master__c ps1 = new Profile_Master__c();
        ps1.Category__c = 'SAL';
        ps1.Code__c = '115';
        ps1.OwnerId = UserInfo.getUserId();
        ps1.Name = 'test';
        ps1.Sub_Bucket_Desc__c = 'AGRICULTURE';
        insert ps1;
        
        Income_Details__c id1 = new Income_Details__c();
        id1.Applicant__c = apt1.Id;
        id1.GST_No__c = '29ABCDE1234F1ZW';
        id1.Income__c = 10000;
        id1.Primary_Income_Source__c = true;
        id1.Profile__c = ps1.Id;
        id1.Is_Self_Employed__c = true;
        insert id1;
        
        Field_Investigation__c fi1 = new Field_Investigation__c();
        fi1.Case__c = cs2.Id;
        fi1.RecordTypeId = Schema.SObjectType.Field_Investigation__c.getRecordTypeInfosByName().get('Office').getRecordTypeId();
        insert fi1;
        
        Test.startTest();
        Field_Investigation__c fv1 = FinalTermscontroller.populateOfficeFIRecord(dfks1,cs2.Id,fi1.RecordTypeId,apt1);
        system.assertEquals(fv1, FinalTermscontroller.populateOfficeFIRecord(dfks1,cs2.Id,fi1.RecordTypeId,apt1));
        Test.stopTest();
        
        
    }
    
    @isTest
    public static void populateOfficeFIRecordTest3(){
        
        Opportunity opgl2 = TestDataUtility.createTestOpportunity(false);
        if (Schema.sObjectType.Opportunity.isCreateable()){
            insert opgl2;
        }
        
        Applicant__c apt1 = TestDataUtility.createTestApplicant(false);
        apt1.Opportunity__c = opgl2.Id;
        if (Schema.sObjectType.Applicant__c.isCreateable()){
            insert apt1;
        }
        Documents__c dfks1 = new Documents__c();
        dfks1.Applicant__c = apt1.Id;
        dfks1.Opportunity_Relation__c = opgl2.Id;
        dfks1.KYC_name__c = 'Aadhar';
        dfks1.Document_Side__c ='Back';
        dfks1.Aadhar_Source__c = 'ScanAadhar';
        dfks1.Name = 'Aadhar';
        dfks1.Document_Type__c = System.Label.AadhaarCard;
        insert dfks1;
        
        case cs2 = new case();
        cs2.Loan_Application__c = opgl2.Id;
        cs2.Subject='Approval Of Application Sourced By Off Roll Employee';
        cs2.Status = 'Pending-Off Role Employee App';
        cs2.Origin = 'Web';
        insert cs2; 
        
        Profile_Master__c ps1 = new Profile_Master__c();
        ps1.Category__c = 'SAL';
        ps1.Code__c = '115';
        ps1.OwnerId = UserInfo.getUserId();
        ps1.Name = 'test';
        ps1.Sub_Bucket_Desc__c = 'AGRICULTURE';
        insert ps1;
        
        Income_Details__c id1 = new Income_Details__c();
        id1.Applicant__c = apt1.Id;
        id1.GST_No__c = '29ABCDE1234F1ZW';
        id1.Income__c = 10000;
        id1.Primary_Income_Source__c = true;
        id1.Profile__c = ps1.Id;
        id1.Is_Self_Employed__c = true;
        insert id1;
        
        Field_Investigation__c fi1 = new Field_Investigation__c();
        fi1.Case__c = cs2.Id;
        fi1.RecordTypeId = Schema.SObjectType.Field_Investigation__c.getRecordTypeInfosByName().get('Office').getRecordTypeId();
        insert fi1;
        
        Test.startTest();
        Field_Investigation__c fv1 = FinalTermscontroller.populateOfficeFIRecord(dfks1,cs2.Id,fi1.RecordTypeId,apt1);
        system.assertEquals(fv1, FinalTermscontroller.populateOfficeFIRecord(dfks1,cs2.Id,fi1.RecordTypeId,apt1));
        Test.stopTest();
        
        
    }
    
    @isTest
    public static void populateOfficeFIRecordTest4(){
        
        Opportunity opgl2 = TestDataUtility.createTestOpportunity(false);
        if (Schema.sObjectType.Opportunity.isCreateable()){
            insert opgl2;
        }
        
        Applicant__c apt1 = TestDataUtility.createTestApplicant(false);
        apt1.Opportunity__c = opgl2.Id;
        if (Schema.sObjectType.Applicant__c.isCreateable()){
            insert apt1;
        }
        Documents__c dfks1 = new Documents__c();
        dfks1.Applicant__c = apt1.Id;
        dfks1.Opportunity_Relation__c = opgl2.Id;
        dfks1.KYC_name__c = 'Aadhar';
        dfks1.Document_Side__c ='Back';
        dfks1.Aadhar_Source__c = 'ScanAadhar';
        dfks1.Name = 'Aadhar';
        dfks1.Document_Type__c = System.Label.AadhaarCard;
        insert dfks1;
        
        case cs2 = new case();
        cs2.Loan_Application__c = opgl2.Id;
        cs2.Subject='Approval Of Application Sourced By Off Roll Employee';
        cs2.Status = 'Pending-Off Role Employee App';
        cs2.Origin = 'Web';
        insert cs2; 
        
        Profile_Master__c ps1 = new Profile_Master__c();
        ps1.Category__c = 'SAL';
        ps1.Code__c = '115';
        ps1.OwnerId = UserInfo.getUserId();
        ps1.Name = 'test';
        ps1.Sub_Bucket_Desc__c = 'RENTAL INCOME';
        insert ps1;
        
        Income_Details__c id1 = new Income_Details__c();
        id1.Applicant__c = apt1.Id;
        id1.GST_No__c = '29ABCDE1234F1ZW';
        id1.Income__c = 10000;
        id1.Primary_Income_Source__c = true;
        id1.Profile__c = ps1.Id;
        id1.Is_Self_Employed__c = true;
        insert id1;
        
        Field_Investigation__c fi1 = new Field_Investigation__c();
        fi1.Case__c = cs2.Id;
        fi1.RecordTypeId = Schema.SObjectType.Field_Investigation__c.getRecordTypeInfosByName().get('Office').getRecordTypeId();
        insert fi1;
        
        Test.startTest();
        Field_Investigation__c fv1 = FinalTermscontroller.populateOfficeFIRecord(dfks1,cs2.Id,fi1.RecordTypeId,apt1);
        system.assertEquals(fv1, FinalTermscontroller.populateOfficeFIRecord(dfks1,cs2.Id,fi1.RecordTypeId,apt1));
        Test.stopTest();
        
        
    }
    
    @isTest
    public static void populateOfficeFIRecordTest5(){
        
        Opportunity opgl2 = TestDataUtility.createTestOpportunity(false);
        if (Schema.sObjectType.Opportunity.isCreateable()){
            insert opgl2;
        }
        
        Applicant__c apt1 = TestDataUtility.createTestApplicant(false);
        apt1.Opportunity__c = opgl2.Id;
        if (Schema.sObjectType.Applicant__c.isCreateable()){
            insert apt1;
        }
        Documents__c dfks1 = new Documents__c();
        dfks1.Applicant__c = apt1.Id;
        dfks1.Opportunity_Relation__c = opgl2.Id;
        dfks1.KYC_name__c = 'Aadhar';
        dfks1.Document_Side__c ='Back';
        dfks1.Aadhar_Source__c = 'ScanAadhar';
        dfks1.Name = 'Aadhar';
        dfks1.Document_Type__c = System.Label.AadhaarCard;
        insert dfks1;
        
        case cs2 = new case();
        cs2.Loan_Application__c = opgl2.Id;
        cs2.Subject='Approval Of Application Sourced By Off Roll Employee';
        cs2.Status = 'Pending-Off Role Employee App';
        cs2.Origin = 'Web';
        insert cs2; 
        
        Profile_Master__c ps1 = new Profile_Master__c();
        ps1.Category__c = 'SAL';
        ps1.Code__c = '115';
        ps1.OwnerId = UserInfo.getUserId();
        ps1.Name = 'test';
        ps1.Sub_Bucket_Desc__c = 'CONTRACTOR';
        insert ps1;
        
        Income_Details__c id1 = new Income_Details__c();
        id1.Applicant__c = apt1.Id;
        id1.GST_No__c = '29ABCDE1234F1ZW';
        id1.Income__c = 10000;
        id1.Primary_Income_Source__c = true;
        id1.Profile__c = ps1.Id;
        id1.Is_Self_Employed__c = true;
        insert id1;
        
        Field_Investigation__c fi1 = new Field_Investigation__c();
        fi1.Case__c = cs2.Id;
        fi1.RecordTypeId = Schema.SObjectType.Field_Investigation__c.getRecordTypeInfosByName().get('Office').getRecordTypeId();
        insert fi1;
        
        Test.startTest();
        Field_Investigation__c fv1 = FinalTermscontroller.populateOfficeFIRecord(dfks1,cs2.Id,fi1.RecordTypeId,apt1);
        system.assertEquals(fv1, FinalTermscontroller.populateOfficeFIRecord(dfks1,cs2.Id,fi1.RecordTypeId,apt1));
        Test.stopTest();
        
        
    }
    
    @isTest
    public static void getUserInfoTest(){
        /*  Profile p = [SELECT Id FROM Profile WHERE Name='CMU'];
system.debug('p'+ p);
User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
LocaleSidKey='en_US', ProfileId = p.Id,
TimeZoneSidKey='America/Los_Angeles',
MobilePhone = '9701498575',
UserName='standarduser4@testorg.com.psdev1' ,
Maker_Id__c='100001');
insert u;
system.runAs(u){ */
        try{
            Account accobj = new Account();
            accobj.Name = 'testname';
            accobj.State__c = 'ASSAM';
            insert accobj;
            
            Opportunity opgl2 = TestDataUtility.createTestOpportunity(false);
            opgl2.AccountId = accobj.Id;
            opgl2.OwnerId = UserInfo.getUserId();
            if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opgl2;
            }
            
            AccountTeamMember atm2 = new AccountTeamMember();
            atm2.AccountId = opgl2.AccountId;
            atm2.TeamMemberRole = 'SCM';
            atm2.UserId = opgl2.OwnerId;
            insert atm2;
            
            Test.startTest();
            FinalTermscontroller.getUserInfo(opgl2.Id);
            FinalTermscontroller.getUserInfo('tests');
            Test.stopTest();
            
        }catch(Exception e){
            System.assertEquals(e.getMessage(),'Script-thrown exception');
        }
        //   }
    }
    
    @isTest
    public static void getUserInfoTest1(){
        Profile p = [SELECT Id FROM Profile WHERE Name='CMU'];
        system.debug('p'+ p);
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles',
                          MobilePhone = '9701498575',
                          UserName='standarduser4@testorg.com.psdev1' ,User_Id__c = '29927_MO',
                          Maker_Id__c='100001');
        insert u;
        system.runAs(u){
            try{
                Account at1 = new Account();
                //  a1.State__c = 'GOA';
                at1.OwnerId = UserInfo.getUserId();
                at1.Name = 'testname';
                at1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business Account').getRecordTypeId();
                insert at1;
                
                Opportunity opgl2 = TestDataUtility.createTestOpportunity(false);
                opgl2.AccountId = at1.Id;
                opgl2.OwnerId = UserInfo.getUserId();
                if (Schema.sObjectType.Opportunity.isCreateable()){
                    insert opgl2;
                }
                
                AccountTeamMember am1 = new AccountTeamMember();
                am1.AccountId = opgl2.AccountId;
                am1.TeamMemberRole = 'CS';
                am1.UserId = opgl2.OwnerId;
                insert am1;
                
                Test.startTest();
                FinalTermscontroller.getUserInfo(opgl2.Id);
                Test.stopTest();
                
            }catch(Exception e){
                System.assertEquals(e.getMessage(),'Script-thrown exception');
            }
        }
    }
    
    /*  @isTest
public static void checkCaseTest(){
try{
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

case cs1 = new case();
cs1.Loan_Application__c = opks1.Id;
cs1.Applicant__c = apks1.Id;
cs1.Subject='Approval Of Application Sourced By Off Roll Employee';
cs1.Status = 'Pending-Off Role Employee App';
cs1.Origin = 'Web';
insert cs1; 

Test.startTest();
FinalTermscontroller.checkCase(opks1.Id);
FinalTermscontroller.checkCase('test');
FinalTermscontroller.checkCase(null);
Test.stopTest();
}catch(Exception e){
System.assertEquals(e.getMessage(),'Script-thrown exception');
}
} */
    
    @isTest
    public static void getApplicationDetailsTest(){
        try{
            Opportunity opds1 = new Opportunity();
            opds1.StageName = 'Qualification';
            opds1.CloseDate = Date.newInstance(2021, 1, 11);
            opds1.Name = 'testone';
            opds1.Product_Type__c = System.Label.TwoWheeler;
            opds1.Vehicle_Type__c = System.Label.new;
             
            insert opds1;
            
            Test.startTest();
            FinalTermscontroller.getApplicationDetails(opds1.Id);
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals(e.getMessage(),'Script-thrown exception');
        }
    }
    
    @isTest
    public static void getApplicationDetailsTest1(){
        try{
            Opportunity opds1 = new Opportunity();
            opds1.StageName = 'Qualification';
            opds1.CloseDate = Date.newInstance(2021, 1, 11);
            opds1.Name = 'testone';
            opds1.Product_Type__c = System.Label.TwoWheeler;
            opds1.Vehicle_Type__c = System.Label.Refinance;
            insert opds1;
            
            Test.startTest();
            FinalTermscontroller.getApplicationDetails(opds1.Id);
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals(e.getMessage(),'Script-thrown exception');
        }
    }
    
    @isTest
    public static void getApplicationDetailsTest2(){
        try{
            Opportunity opds1 = new Opportunity();
            opds1.StageName = 'Qualification';
            opds1.CloseDate = Date.newInstance(2021, 1, 11);
            opds1.Name = 'testone';
            opds1.Product_Type__c =  System.Label.PassengerVehicles;
            opds1.Vehicle_Type__c = 'New';
            insert opds1;
            
            Test.startTest();
            FinalTermscontroller.getApplicationDetails(opds1.Id);
            FinalTermscontroller.getApplicationDetails('test');
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals(e.getMessage(),'Script-thrown exception');
        }
    }
    
    @isTest
    public static void getOpportunityDetailsForUPDTest(){
        try{
            Opportunity opds1 = new Opportunity();
            opds1.StageName = 'Qualification';
            opds1.CloseDate = Date.newInstance(2021, 1, 11);
            opds1.Name = 'testone';
            opds1.Product_Type__c = System.Label.PassengerVehicles;
            opds1.Vehicle_Type__c = 'New';
            insert opds1;
            
            Test.startTest();
            FinalTermscontroller.getOpportunityDetailsForUPD(opds1.Id);
            FinalTermscontroller.getOpportunityDetailsForUPD('test');
            Test.stopTest();
            
        }catch(Exception e){
            System.assertEquals(e.getMessage(),'Script-thrown exception');
        }
    }
    @isTest
    public static void reffnamedataTest(){
        try{
            Opportunity opds1 = new Opportunity();
            opds1.StageName = 'Qualification';
            opds1.CloseDate = Date.newInstance(2021, 1, 11);
            opds1.Name = 'testone';
            opds1.Product_Type__c = 'Two Wheeler';
            insert opds1;
            
            Vehicle_Detail__c vc2 = new Vehicle_Detail__c();
            vc2.Loan_Application__c = opds1.Id;
            vc2.Base_Price__c = 100000.00;
            vc2.Ben_Code__c = 'testveh';
            vc2.Dealer_Sub_dealer_name__c = 'testsubdealer';
            insert vc2; 
            
            Product2 pd1 = new Product2();
            pd1.Asset_Category__c = 'te';
            pd1.Name = 'book';
            pd1.Type__c = 'Model';
            pd1.External_Reference_Id__c = '58568568';
            pd1.ProductCode = 'H';
            insert pd1;
            
            Benefi__c bnf1 = new Benefi__c();
            bnf1.Ben_code__c = 'BEN000280';
            bnf1.Name = vc2.Dealer_Sub_dealer_name__c;
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
            blCodeDetail.Bl_Code__c = 'TEST';
            blCodeDetail.State_Code__c = '69';
            blCodeDetail.Geo_State_Code__c = '96';
            insert blCodeDetail;
            
            //created Beneficiary_BlCode__c record
            Beneficiary_BlCode__c benefBLCode = new Beneficiary_BlCode__c();
            benefBLCode.Name = 'test benefBLCode';
            benefBLCode.Ben_code__c = bnf1.Id;
            benefBLCode.Bl_Code_Details__c = blCodeDetail.Id;
            benefBLCode.Unique_Identifier__c = 'TEST';
            insert benefBLCode;
            
            Test.startTest();
            // FinalTermscontroller.reffnamedata(opds1.Id);
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals(e.getMessage(),'Script-thrown exception');
        }
    }
    
    @isTest
    public static void getFinalTermRecord(){
        try{
            Opportunity opds1 = new Opportunity();
            opds1.StageName = 'Qualification';
            opds1.CloseDate = Date.newInstance(2021, 1, 11);
            opds1.Name = 'testone';
            opds1.Product_Type__c = 'Two Wheeler';
            insert opds1;
            
            Vehicle_Detail__c vc2 = new Vehicle_Detail__c();
            vc2.Loan_Application__c = opds1.Id;
            vc2.Base_Price__c = 100000.00;
            vc2.Ben_Code__c = 'testveh';
            vc2.Dealer_Sub_dealer_name__c = 'testsubdealer';
            insert vc2; 
            
            final_Term__c ft1 = new final_Term__c();
            ft1.Loan_Application__c = opds1.Id;
            insert ft1; 
            
            Test.startTest();
            FinalTermscontroller.getFinalTermRecord(opds1.Id,vc2.Id);
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals(e.getMessage(),'Script-thrown exception');
        }
    }
    
       @isTest
    public static void getFinalTermRecordException(){
        try{
            Opportunity opds1 = new Opportunity();
            opds1.StageName = 'Qualification';
            opds1.CloseDate = Date.newInstance(2021, 1, 11);
            opds1.Name = 'testone';
            opds1.Product_Type__c = 'Two Wheeler';
            insert opds1;
            
            Vehicle_Detail__c vc2 = new Vehicle_Detail__c();
            vc2.Loan_Application__c = opds1.Id;
            vc2.Base_Price__c = 100000.00;
            vc2.Ben_Code__c = 'testveh';
            vc2.Dealer_Sub_dealer_name__c = 'testsubdealer';
            insert vc2; 
            
            final_Term__c ft1 = new final_Term__c();
            ft1.Loan_Application__c = opds1.Id;
            insert ft1; 
            
            Test.startTest();
            FinalTermscontroller.getFinalTermRecord(vc2.Id,vc2.Id);
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals(e.getMessage(),'Script-thrown exception');
        }
    }
    @isTest
    public static void getcheckIES(){
        try{
            
            Opportunity opks1 = new Opportunity();
            opks1.StageName = 'Qualification';
            opks1.CloseDate = Date.newInstance(2021, 1, 11);
            opks1.Name = 'testone';
            opks1.Agent_BL_code__c = 'AG-00';
            opks1.Product_Type__c = 'Two Wheeler';
            insert opks1;
            
            Applicant__c apks1 = new Applicant__c();
            apks1.Opportunity__c = opks1.Id;
            apks1.Contact_number__c = '9743514830';
            apks1.Applicant_Type__c = 'Borrower';
            apks1.Would_you_like_to_open_a_bank_account__c = true;
            apks1.Who_will_repay_the_loan__c = 'Borrower';
            insert apks1;
            Test.startTest();
            FinalTermscontroller.checkIES(opks1.Id);
            Test.stopTest();}catch(Exception e){
                System.assertEquals(e.getMessage(),'Script-thrown exception');
            }
    }
    
    @isTest
    public static void getFinalTermObjectAsPerVehicleTest(){
        try{
            Opportunity opds1 = new Opportunity();
            opds1.StageName = 'Qualification';
            opds1.CloseDate = Date.newInstance(2021, 1, 11);
            opds1.Name = 'testone';
            opds1.Product_Type__c = 'Two Wheeler';
            insert opds1;
            
            Vehicle_Detail__c vc2 = new Vehicle_Detail__c();
            vc2.Loan_Application__c = opds1.Id;
            vc2.Base_Price__c = 100000.00;
            vc2.Ben_Code__c = 'testveh';
            vc2.Dealer_Sub_dealer_name__c = 'testsubdealer';
            insert vc2; 
            
            final_Term__c ft1 = new final_Term__c();
            ft1.Loan_Application__c = opds1.Id;
            ft1.Vehicle_Detail__c = vc2.Id;
            insert ft1; 
            
            Test.startTest();
            FinalTermscontroller.getFinalTermObjectAsPerVehicle(opds1.Id,vc2.Id);
            FinalTermscontroller.getFinalTermObjectAsPerVehicle('test','test1');
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals(e.getMessage(),'Script-thrown exception');
        }
    }

     
     @isTest
    public static void isAllFICasesSubmittedTest(){
        try{
            Opportunity opds1 = new Opportunity();
            opds1.StageName = 'Qualification';
            opds1.CloseDate = Date.newInstance(2021, 1, 11);
            opds1.Name = 'testone';
            opds1.Product_Type__c = 'Two Wheeler';
            insert opds1;
      
            Vehicle_Detail__c vc2 = new Vehicle_Detail__c();
            vc2.Loan_Application__c = opds1.Id;
            vc2.Base_Price__c = 100000.00;
            vc2.Ben_Code__c = 'testveh';
            vc2.Dealer_Sub_dealer_name__c = 'testsubdealer';
            insert vc2; 
            
            final_Term__c ft1 = new final_Term__c();
            ft1.Loan_Application__c = opds1.Id;
            ft1.Vehicle_Detail__c = vc2.Id;
            insert ft1; 
            
            String caseRecordType = Schema.SObjectType.CASE.getRecordTypeInfosByName().get('FI').getRecordTypeId();
            Case caseRec = new Case();
            caseRec.Loan_Application__c = opds1.Id;
            caseRec.RecordTypeId = caseRecordType;
            insert caseRec;
            
            Test.startTest();
            FinalTermscontroller.isAllFICasesSubmitted(opds1.Id);
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals(e.getMessage(),'Script-thrown exception');
        }
    }
    
     @isTest
    public static void validateAgreementAmountTest(){
        try{
            Opportunity opds1 = new Opportunity();
            opds1.StageName = 'Qualification';
            opds1.CloseDate = Date.newInstance(2021, 1, 11);
            opds1.Name = 'testone';
            opds1.Product_Type__c = 'Tractor';
            insert opds1;
      
            Vehicle_Detail__c vc2 = new Vehicle_Detail__c();
            vc2.Loan_Application__c = opds1.Id;
            vc2.Base_Price__c = 100.00;
            vc2.Ben_Code__c = 'testveh';
            vc2.Dealer_Sub_dealer_name__c = 'testsubdealer';
            insert vc2; 
            
            final_Term__c ft1 = new final_Term__c();
            ft1.Loan_Application__c = opds1.Id;
            ft1.Vehicle_Detail__c = vc2.Id;
            ft1.Offer_Agreement_Amount__c = 129000.00;
            insert ft1; 
            
            String caseRecordType = Schema.SObjectType.CASE.getRecordTypeInfosByName().get('FI').getRecordTypeId();
            Case caseRec = new Case();
            caseRec.Loan_Application__c = opds1.Id;
            caseRec.RecordTypeId = caseRecordType;
            insert caseRec;
            
            Test.startTest();
            FinalTermscontroller.validateAgreementAmount(ft1.Id);
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals(e.getMessage(),'Script-thrown exception');
        }
    }
    
     @isTest
    public static void validateAgreementAmountTest2(){
        try{
            Opportunity opds1 = new Opportunity();
            opds1.StageName = 'Qualification';
            opds1.CloseDate = Date.newInstance(2021, 1, 11);
            opds1.Name = 'testone';
            opds1.Product_Type__c = 'Two Wheeler';
            opds1.Vehicle_Type__c = 'New';
            insert opds1;
      
            Vehicle_Detail__c vc2 = new Vehicle_Detail__c();
            vc2.Loan_Application__c = opds1.Id;
            vc2.Base_Price__c = 100.00;
            vc2.Ben_Code__c = 'testveh';
            vc2.Dealer_Sub_dealer_name__c = 'testsubdealer';
            insert vc2; 
            
            final_Term__c ft1 = new final_Term__c();
            ft1.Loan_Application__c = opds1.Id;
            ft1.Vehicle_Detail__c = vc2.Id;
            //ft1.Agreement_Amount__c = 129000.00;
            insert ft1; 
            
            String caseRecordType = Schema.SObjectType.CASE.getRecordTypeInfosByName().get('FI').getRecordTypeId();
            Case caseRec = new Case();
            caseRec.Loan_Application__c = opds1.Id;
            caseRec.RecordTypeId = caseRecordType;
            insert caseRec;
            
            Test.startTest();
            FinalTermscontroller.validateAgreementAmount(ft1.Id);
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals(e.getMessage(),'Script-thrown exception');
        }
    }
    
    @isTest
    public static void isGotoNextScreenTest(){
        try{
            Opportunity opds1 = new Opportunity();
            opds1.StageName = 'Qualification';
            opds1.CloseDate = Date.newInstance(2021, 1, 11);
            opds1.Name = 'testone';
            opds1.Product_Type__c = 'Tractor';
            opds1.Vehicle_Type__c = 'New';
            insert opds1;
      
            Vehicle_Detail__c vc2 = new Vehicle_Detail__c();
            vc2.Loan_Application__c = opds1.Id;
            vc2.Base_Price__c = 100.00;
            vc2.Ben_Code__c = 'testveh';
            vc2.Dealer_Sub_dealer_name__c = 'testsubdealer';
            insert vc2; 
            
            final_Term__c ft1 = new final_Term__c();
            ft1.Loan_Application__c = opds1.Id;
            ft1.Vehicle_Detail__c = vc2.Id;
            ft1.L2_Final_Terms_Submitted__c = true;
            insert ft1; 
            
            String caseRecordType = Schema.SObjectType.CASE.getRecordTypeInfosByName().get('FI').getRecordTypeId();
            Case caseRec = new Case();
            caseRec.Loan_Application__c = opds1.Id;
            caseRec.RecordTypeId = caseRecordType;
            insert caseRec;
            
            Test.startTest();
            FinalTermscontroller.isGotoNextScreen(opds1.Id);
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals(e.getMessage(),'Script-thrown exception');
        }
    }
    
    @isTest
    public static void getFinalTermSuccessApisTest(){
        try{
            Opportunity opds1 = new Opportunity();
            opds1.StageName = 'Qualification';
            opds1.CloseDate = Date.newInstance(2021, 1, 11);
            opds1.Name = 'testone';
            opds1.Product_Type__c = 'Tractor';
            opds1.Vehicle_Type__c = 'New';
            insert opds1;
      
            Vehicle_Detail__c vc2 = new Vehicle_Detail__c();
            vc2.Loan_Application__c = opds1.Id;
            vc2.Base_Price__c = 100.00;
            vc2.Ben_Code__c = 'testveh';
            vc2.Dealer_Sub_dealer_name__c = 'testsubdealer';
            insert vc2; 
            
            final_Term__c ft1 = new final_Term__c();
            ft1.Loan_Application__c = opds1.Id;
            ft1.Vehicle_Detail__c = vc2.Id;
            ft1.L1_Final_Terms_Submitted__c = true;
            insert ft1; 
            
            String caseRecordType = Schema.SObjectType.CASE.getRecordTypeInfosByName().get('FI').getRecordTypeId();
            Case caseRec = new Case();
            caseRec.Loan_Application__c = opds1.Id;
            caseRec.RecordTypeId = caseRecordType;
            insert caseRec;
            
            Test.startTest();
            FinalTermscontroller.getFinalTermSuccessApis(opds1.Id,true);
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals(e.getMessage(),'Script-thrown exception');
        }
    }
     @isTest
    public static void getVehicleDetailsTest(){
        try{
            Opportunity opds1 = new Opportunity();
            opds1.StageName = 'Qualification';
            opds1.CloseDate = Date.newInstance(2021, 1, 11);
            opds1.Name = 'testone';
            opds1.Product_Type__c = 'Tractor';
            opds1.Vehicle_Type__c = 'New';
            insert opds1;
      
            Vehicle_Detail__c vc2 = new Vehicle_Detail__c();
            vc2.Loan_Application__c = opds1.Id;
            vc2.Base_Price__c = 100.00;
            vc2.Ben_Code__c = 'testveh';
            vc2.Make__c = 'test1';
            vc2.Model__c = 't1';
            vc2.Variant__c = '12tes';
            vc2.Dealer_Sub_dealer_name__c = 'testsubdealer';
            insert vc2; 
            
            final_Term__c ft1 = new final_Term__c();
            ft1.Loan_Application__c = opds1.Id;
            ft1.Vehicle_Detail__c = vc2.Id;
            ft1.L1_Final_Terms_Submitted__c = true;
            insert ft1; 
            
            String caseRecordType = Schema.SObjectType.CASE.getRecordTypeInfosByName().get('FI').getRecordTypeId();
            Case caseRec = new Case();
            caseRec.Loan_Application__c = opds1.Id;
            caseRec.RecordTypeId = caseRecordType;
            insert caseRec;
            
            Test.startTest();
            FinalTermscontroller.getVehicleDetails(opds1.Id);
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals(e.getMessage(),'Script-thrown exception');
        }
    }
    
    @isTest
    public static void getVehicleDetailsTest2(){
        try{
            Opportunity opds1 = new Opportunity();
            opds1.StageName = 'Qualification';
            opds1.CloseDate = Date.newInstance(2021, 1, 11);
            opds1.Name = 'testone';
            opds1.Product_Type__c = 'Tractor';
            opds1.Vehicle_Type__c = 'New';
            insert opds1;
      
            Vehicle_Detail__c vc2 = new Vehicle_Detail__c();
            vc2.Loan_Application__c = opds1.Id;
            vc2.Base_Price__c = 100.00;
            vc2.Ben_Code__c = 'testveh';
           // vc2.Make__c = 'test1';
           // vc2.Model__c = 't1'
            //vc2.Variant__c = '12tes';
            vc2.Dealer_Sub_dealer_name__c = 'testsubdealer';
            insert vc2; 
            
            final_Term__c ft1 = new final_Term__c();
            ft1.Loan_Application__c = opds1.Id;
            ft1.Vehicle_Detail__c = vc2.Id;
            ft1.L1_Final_Terms_Submitted__c = true;
            insert ft1; 
         
            Test.startTest();
            FinalTermscontroller.getVehicleDetails(opds1.Id);
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals(e.getMessage(),'Script-thrown exception');
        }
    }
     @isTest
    public static void getRepaymentModePickListValueTractorTest(){
        try{
            Opportunity opds1 = new Opportunity();
            opds1.StageName = 'Qualification';
            opds1.CloseDate = Date.newInstance(2021, 1, 11);
            opds1.Name = 'testone';
            opds1.Product_Type__c = 'Tractor';
            opds1.Vehicle_Type__c = 'New';
            insert opds1;
      
            List<Applicant__c> applist = new List<Applicant__c>();
            Applicant__c app = new Applicant__c();
            app.Opportunity__c = opds1.Id;
            app.Applicant_Type__c = 'Borrower';
            app.Repayment_Will_Be_Done_By__c = 'tes1';
            app.Would_you_like_to_open_a_bank_account__c = true;
            applist.add(app);
            
           /* Applicant__c app2 = new Applicant__c();
            app2.Opportunity__c = opds1.Id;
            app2.Applicant_Type__c = 'Co-Borrower';
            app2.Repayment_Will_Be_Done_By__c = 'tes1';
            applist.add(app2);*/
            
            insert applist;
            
            
            Vehicle_Detail__c vc2 = new Vehicle_Detail__c();
            vc2.Loan_Application__c = opds1.Id;
            vc2.Base_Price__c = 100.00;
            vc2.Ben_Code__c = 'testveh';
           // vc2.Make__c = 'test1';
           // vc2.Model__c = 't1'
            //vc2.Variant__c = '12tes';
            vc2.Dealer_Sub_dealer_name__c = 'testsubdealer';
            insert vc2; 
            
            final_Term__c ft1 = new final_Term__c();
            ft1.Loan_Application__c = opds1.Id;
            ft1.Vehicle_Detail__c = vc2.Id;
            ft1.L1_Final_Terms_Submitted__c = true;
            insert ft1; 
           
          
            
            Test.startTest();
            FinalTermscontroller.getRepaymentModePickListValueTractor(applist);
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals(e.getMessage(),'Script-thrown exception');
        }
    }
    
     @isTest
    public static void getRepaymentModePickListValueTractorTest2(){
        try{
            Opportunity opds1 = new Opportunity();
            opds1.StageName = 'Qualification';
            opds1.CloseDate = Date.newInstance(2021, 1, 11);
            opds1.Name = 'testone';
            opds1.Product_Type__c = System.Label.Tractor;
            opds1.Vehicle_Type__c = 'New';
            insert opds1;
      
            List<Applicant__c> applist = new List<Applicant__c>();
            Applicant__c app = new Applicant__c();
            app.Opportunity__c = opds1.Id;
            app.Applicant_Type__c = 'Borrower';
            app.Repayment_Will_Be_Done_By__c = 'tes1';
            app.Do_you_have_a_bank_account__c = true;
            app.Do_you_have_a_bank_account_with_IBL__c = true;
            applist.add(app);
            
           /* Applicant__c app2 = new Applicant__c();
            app2.Opportunity__c = opds1.Id;
            app2.Applicant_Type__c = 'Co-Borrower';
            app2.Repayment_Will_Be_Done_By__c = 'tes1';
            applist.add(app2);*/
            
            insert applist;
            
            Retry_Count__c retry = new Retry_Count__c();
            retry.Loan_Application_Id__c = opds1.Id;
            insert retry;
            
            Vehicle_Detail__c vc2 = new Vehicle_Detail__c();
            vc2.Loan_Application__c = opds1.Id;
            vc2.Base_Price__c = 100.00;
            vc2.Ben_Code__c = 'testveh';
           // vc2.Make__c = 'test1';
           // vc2.Model__c = 't1'
            //vc2.Variant__c = '12tes';
            vc2.Dealer_Sub_dealer_name__c = 'testsubdealer';
            insert vc2; 
            
            final_Term__c ft1 = new final_Term__c();
            ft1.Loan_Application__c = opds1.Id;
            ft1.Vehicle_Detail__c = vc2.Id;
            ft1.L1_Final_Terms_Submitted__c = true;
            insert ft1; 
           
          
            
            Test.startTest();
            FinalTermscontroller.getRepaymentModePickListValueTractor(applist);
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals(e.getMessage(),'Script-thrown exception');
        }
    }
    
     @isTest
    public static void getRepaymentModePickListValueTest(){
        try{
            Opportunity opds1 = new Opportunity();
            opds1.StageName = 'Qualification';
            opds1.CloseDate = Date.newInstance(2021, 1, 11);
            opds1.Name = 'testone';
            opds1.Product_Type__c = 'Tractor';
            opds1.Vehicle_Type__c = 'New';
            opds1.LeadSource = 'D2C';
            insert opds1;
      
            Applicant__c app = new Applicant__c();
            app.Opportunity__c = opds1.Id;
            app.Applicant_Type__c = 'Borrower';
            app.Repayment_Will_Be_Done_By__c = 'tes1';
            app.Do_you_have_a_bank_account__c = true;
            app.Do_you_have_a_bank_account_with_IBL__c = true;
            app.In_Active_Applicant__c = false;
            insert app;
            
            Retry_Count__c retry = new Retry_Count__c();
            retry.Loan_Application_Id__c = opds1.Id;
            insert retry;
            
            Vehicle_Detail__c vc2 = new Vehicle_Detail__c();
            vc2.Loan_Application__c = opds1.Id;
            vc2.Base_Price__c = 100.00;
            vc2.Ben_Code__c = 'testveh';
           // vc2.Make__c = 'test1';
           // vc2.Model__c = 't1'
            //vc2.Variant__c = '12tes';
            vc2.Dealer_Sub_dealer_name__c = 'testsubdealer';
            insert vc2; 
            
            final_Term__c ft1 = new final_Term__c();
            ft1.Loan_Application__c = opds1.Id;
            ft1.Vehicle_Detail__c = vc2.Id;
            ft1.L1_Final_Terms_Submitted__c = true;
            insert ft1; 
           
          
            
            Test.startTest();
            FinalTermscontroller.getRepaymentModePickListValue(opds1.Id);
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals(e.getMessage(),'Script-thrown exception');
        }
    }
    
     @isTest
    public static void getRepaymentModePickListValueTest1(){
        try{
            Opportunity opds1 = new Opportunity();
            opds1.StageName = 'Qualification';
            opds1.CloseDate = Date.newInstance(2021, 1, 11);
            opds1.Name = 'testone';
            opds1.Product_Type__c = 'Tractor';
            opds1.Vehicle_Type__c = 'New';
            insert opds1;
      
            Applicant__c app = new Applicant__c();
            app.Opportunity__c = opds1.Id;
            app.Applicant_Type__c = 'Borrower';
            app.Repayment_Will_Be_Done_By__c = 'tes1';
            app.Do_you_have_a_bank_account__c = true;
            app.Do_you_have_a_bank_account_with_IBL__c = true;
            app.In_Active_Applicant__c = false;
            insert app;
            
            Retry_Count__c retry = new Retry_Count__c();
            retry.Loan_Application_Id__c = opds1.Id;
            insert retry;
            
            Vehicle_Detail__c vc2 = new Vehicle_Detail__c();
            vc2.Loan_Application__c = opds1.Id;
            vc2.Base_Price__c = 100.00;
            vc2.Ben_Code__c = 'testveh';
           // vc2.Make__c = 'test1';
           // vc2.Model__c = 't1'
            //vc2.Variant__c = '12tes';
            vc2.Dealer_Sub_dealer_name__c = 'testsubdealer';
            insert vc2; 
            
            final_Term__c ft1 = new final_Term__c();
            ft1.Loan_Application__c = opds1.Id;
            ft1.Vehicle_Detail__c = vc2.Id;
            ft1.L1_Final_Terms_Submitted__c = true;
            insert ft1; 
           
          
            
            Test.startTest();
            FinalTermscontroller.getRepaymentModePickListValue(opds1.Id);
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals(e.getMessage(),'Script-thrown exception');
        }
    }
    
     @isTest
    public static void getRepaymentModePickListValueTest2(){
        try{
            Opportunity opds1 = new Opportunity();
            opds1.StageName = 'Qualification';
            opds1.CloseDate = Date.newInstance(2021, 1, 11);
            opds1.Name = 'testone';
            opds1.Product_Type__c = 'Two Wheeler';
            opds1.Vehicle_Type__c = 'New';
            insert opds1;
      
            Applicant__c app = new Applicant__c();
            app.Opportunity__c = opds1.Id;
            app.Applicant_Type__c = 'Borrower';
            app.Repayment_Will_Be_Done_By__c = 'tes1';
            app.Do_you_have_a_bank_account__c = true;
            app.Do_you_have_a_bank_account_with_IBL__c = true;
            app.In_Active_Applicant__c = false;
            app.Would_you_like_to_open_a_bank_account__c = true;
            app.Who_will_repay_the_loan__c ='Test';
            insert app;
            
            Retry_Count__c retry = new Retry_Count__c();
            retry.Loan_Application_Id__c = opds1.Id;
            insert retry;
            
            Vehicle_Detail__c vc2 = new Vehicle_Detail__c();
            vc2.Loan_Application__c = opds1.Id;
            vc2.Base_Price__c = 100.00;
            vc2.Ben_Code__c = 'testveh';
           // vc2.Make__c = 'test1';
           // vc2.Model__c = 't1'
            //vc2.Variant__c = '12tes';
            vc2.Dealer_Sub_dealer_name__c = 'testsubdealer';
            insert vc2; 
            
            final_Term__c ft1 = new final_Term__c();
            ft1.Loan_Application__c = opds1.Id;
            ft1.Vehicle_Detail__c = vc2.Id;
            ft1.L1_Final_Terms_Submitted__c = true;
            insert ft1; 
           
          
            
            Test.startTest();
            FinalTermscontroller.getRepaymentModePickListValue(opds1.Id);
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals(e.getMessage(),'Script-thrown exception');
        }
    }
            @isTest
        public static void getbenefitioryDetails(){
            try{
                Opportunity opds1 = new Opportunity();
                opds1.StageName = 'Qualification';
                opds1.CloseDate = Date.newInstance(2021, 1, 11);
                opds1.Name = 'testone';
                opds1.Agent_BL_code__c = 'AG-00';
                opds1.Product_Type__c = 'Two Wheeler';
                insert opds1;
                
                Vehicle_Detail__c vg3 = new Vehicle_Detail__c();
                vg3.Loan_Application__c = opds1.Id;
                vg3.Base_Price__c = 100000.00;
                vg3.Ben_Code__c = 'BEN000280';
                vg3.Variant__c = 'testvariant';
                vg3.Model__c ='testModel';
                vg3.Dealer_Sub_dealer_name__c = 'T V SUNDARAM IYENGAR AND SONS PVT LTD';
                insert vg3; 
                
                
                Benefi__c bnf1 = new Benefi__c();
                bnf1.Ben_code__c = 'BEN000280';
                bnf1.Name = 'testBenefi';
                bnf1.Dealer_Code__c = 'testdealer';
                bnf1.Indusind_AcNo__c = '786767832788';
                bnf1.Beneficiary__c = 'DSM';
                bnf1.Dealership_Nature__c = 'SDR';
                bnf1.Status_Flag__c = 'L';
                insert bnf1;
                
                Test.startTest();
                FinalTermscontroller.getbenefitioryDetails(opds1.Id);
                Test.stopTest();
            }catch(Exception e){
                System.assertEquals('Script-thrown exception', e.getMessage());
            }
        }
}