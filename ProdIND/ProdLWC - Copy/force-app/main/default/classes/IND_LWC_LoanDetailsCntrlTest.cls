@isTest(seeAllData = false)
private class IND_LWC_LoanDetailsCntrlTest
{
    
    /***********************************************************************************************************************
* @Method Name - IND_LWC_LoanDetailsCntlTest
* @Created by: Raj Gupta
* @description: IND_LWC_LoanDetailsCntlTest to test insert IND_LWC_LoanDetailsCntl class
***********************************************************************************************************************/
    @testSetup
    public static void setup(){
        Vehicle_Detail__c  vehiclobject = TestDataUtility.createTestVehicleDetail(true);  
        
        Retry_Count__c rc = new Retry_Count__c(Loan_Application_Id__c = vehiclobject.Loan_Application__c,Service_Name__c =System.Label.carwaleapi,Count__c = 5);
        insert rc;
    }
    
    
    @isTest
    private static void checkRetryExhaustedSuccessTest() 
    {
        try{
            Vehicle_Detail__c  vehiclobject = [select Id,Loan_Application__c from Vehicle_Detail__c];
            Test.startTest();
            String response=IND_LWC_LoanDetailsCntrl.checkRetryExhausted(vehiclobject.Loan_Application__c);
            Test.stopTest();
            //System.assertEquals('{"message":"Success"}',response);
        }
        Catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        } 
        
    }
    
    @isTest
    private static void checkRetryExhaustedTest() 
    {
        try{
            Vehicle_Detail__c  vehiclobject = [select Id,Loan_Application__c from Vehicle_Detail__c]; 
            Retry_Count__c retryCount = [select Count__c from Retry_Count__c];
            retryCount.Count__c = 4;
            update retryCount;
            Test.startTest();
            String response=IND_LWC_LoanDetailsCntrl.checkRetryExhausted(vehiclobject.Loan_Application__c);
            Test.stopTest();
            //  System.assertEquals('{"message":"Retry attempts are exhausted."}',response);
        }
        Catch(Exception e){
            //   System.assertEquals('Script-thrown exception', e.getMessage());
        } 
        
    }    
    
    @isTest
    private static void checkRetryExhaustedTest2() 
    {
        try{
            
            Opportunity op1 = new Opportunity(Name='EMITest',StageName='Income Details',DSM_Name1__c='test1',DSM_Name2__c='test2',CloseDate=System.today());
            insert op1;
            Opportunity op2 = new Opportunity(Name='EMITest2',StageName='Income Details',DSM_Name1__c='test1',DSM_Name2__c='test2',CloseDate=System.today());
            insert op2;
            String ot='';
            
            Vehicle_Detail__c vc2 = new Vehicle_Detail__c();
            vc2.Loan_Application__c = op1.Id;
            vc2.Base_Price__c = 100000.00;
            vc2.Ben_Code__c = 'testveh';
            insert vc2; 
            
            List<Retry_Count__c> rcList1 = new List<Retry_Count__c>();
            Retry_Count__c rc1 = new Retry_Count__c();
            rc1.Loan_Application_Id__c = op1.Id;
            rc1.Service_Name__c = System.Label.carwaleapi;
            rc1.User_Id__c = UserInfo.getUserId();
            rc1.Count__c = 5;
            insert rc1;
            rcList1.add(rc1);
            
            Test.startTest();
            IND_LWC_LoanDetailsCntrl.checkRetryExhausted(op1.Id);
            IND_LWC_LoanDetailsCntrl.getVehicleDetails(op1.Id);
            // IND_LWC_LoanDetailsCntrl.getVehicleDetails(op2.Id);
            // IND_LWC_LoanDetailsCntrl.getVehicleDetails(ot);
            Test.stopTest();
            // System.assertEquals('{"message":"Retry attempts are exhausted."}',response);
        }
        Catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        } 
        
    }  
    
    @isTest
    private static void checkCibilflagTest(){
        Opportunity op1 = new Opportunity(Name='EMITest',StageName='Credit Processing',Sub_Stage__c='Income',DSM_Name1__c='test1',DSM_Name2__c='test2',CloseDate=System.today());
        insert op1;
        Applicant__c app = new Applicant__c();
        app.Applicant_Type__c = 'Borrower';
        app.Opportunity__c=op1.Id;
        insert app;
        CIBIL_Details__c cd = new CIBIL_Details__c();
        // cd.L2flag__c=true;
        cd.Applicant__c=app.id;
        Final_Term__c ft = new Final_Term__c();
        ft.Loan_Application__c=op1.id;
        // ft.Is_Rerun_Offer_Engine__c=true;
        insert ft;
        insert cd;
        String ot='';
        Test.startTest();
        // IND_LWC_LoanDetailsCntrl.checkCibilflag(op1.Id);
        // IND_LWC_LoanDetailsCntrl.checkCibilflag(ot);
        Test.stopTest();
    }  
    
    @isTest
    private static void checkRetryExhaustedTest3() 
    {
        try{
            
            Opportunity op1 = new Opportunity(Name='EMITest',StageName='Income Details',DSM_Name1__c='test1',DSM_Name2__c='test2',CloseDate=System.today());
            insert op1;
            
            Vehicle_Detail__c vc2 = new Vehicle_Detail__c();
            vc2.Loan_Application__c = op1.Id;
            vc2.Base_Price__c = 100000.00;
            vc2.Ben_Code__c = 'testveh';
            insert vc2; 
            
            List<Retry_Count__c> rcList1 = new List<Retry_Count__c>();
            Retry_Count__c rc1 = new Retry_Count__c();
            rc1.Loan_Application_Id__c = op1.Id;
            rc1.Service_Name__c = System.Label.carwaleapi;
            rc1.User_Id__c = UserInfo.getUserId();
            rc1.Count__c = 0;
            insert rc1;
            rcList1.add(rc1);
            
            Test.startTest();
            IND_LWC_LoanDetailsCntrl.checkRetryExhausted(op1.Id);
            Test.stopTest();
            // System.assertEquals('{"message":"Retry attempts are exhausted."}',response);
        }
        Catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        } 
        
    }    
    
    @isTest
    private static void checkRetryExhaustedNUllTest() 
    {
        try{
            Vehicle_Detail__c  vehiclobject = [select Id,Loan_Application__c from Vehicle_Detail__c];
            Test.startTest();
            String response=IND_LWC_LoanDetailsCntrl.checkRetryExhausted(null);
            Test.stopTest();
            System.assertEquals('{"message":null}',response);
        }
        Catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        } 
        
    }   
    
    @isTest
    private static void getDetailsforLoanTest() 
    {
        try{
            Vehicle_Detail__c  vehiclobject = [select Id,Loan_Application__c from Vehicle_Detail__c];  
            Test.startTest();
            //IND_LWC_LoanDetailsCntrl.LoanDetailWrapper loan = new IND_LWC_LoanDetailsCntrl.LoanDetailWrapper();
            //loan =  IND_LWC_LoanDetailsCntrl.getDetailsforLoan(vehiclobject.Loan_Application__c);
            //String serializedResponse = JSON.serialize(loan);
            Test.stopTest();
            //System.assertEquals('{"rtoRoadtax":null,"onRoadPrice":null,"message":"Failure","exshowroomPrice":null}',serializedResponse);
        }
        Catch(Exception e)
        {
            System.assertEquals('Script-thrown exception', e.getMessage());
        } 
        
    } 
    
    @isTest
    private static void getDetailsforLoanNUllTest() 
    {
        try{
            Vehicle_Detail__c  vehiclobject = [select Id,Loan_Application__c from Vehicle_Detail__c];
            Test.startTest();
            //IND_LWC_LoanDetailsCntrl.LoanDetailWrapper loan = new IND_LWC_LoanDetailsCntrl.LoanDetailWrapper();
            //loan = IND_LWC_LoanDetailsCntrl.getDetailsforLoan(null);
            Test.stopTest();
            //System.assertEquals(null,loan);
        }
        Catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        } 
        
    }   
    
    @isTest(SeeAllData=false)
    private static void calculatePricesTest() 
    {
        try{  
            Test.startTest();
            String detail = '{"exShowroomPriceCarwaledetail":200000,"basicPricedetail":"432","discountOnBasicPriceDetail":"42","gstAmountdetail":"42","flagtocheckFundingdetail":true,"flagtocheckCsddetail":false,"insurancePremiumDeatil":"78","otherChargesDetail":"42","rtoRoadTaxDetail":3000}';
            String response = IND_LWC_LoanDetailsCntrl.calculatePrices(detail);
            Test.stopTest();
            System.assertEquals('{"onRoadPriceTwo":203078.0,"onRoadPriceOne":3552.0,"journeyStatus":"NON-STP","finalPrice":3552.0,"exShowroomPriceTwo":199958.0,"exShowroomPriceOne":432.0}',response);
        }
        Catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        } 
        
    } 
    
    @isTest
    private static void calculatePricesFalseTest() 
    {
        try{   
            Test.startTest();
            String detail = '{"exShowroomPriceCarwaledetail":200000,"basicPricedetail":"400","discountOnBasicPriceDetail":"20","gstAmountdetail":"400","flagtocheckFundingdetail":false,"flagtocheckCsddetail":true,"insurancePremiumDeatil":"40","otherChargesDetail":"50","rtoRoadTaxDetail":3000}';
            String response = IND_LWC_LoanDetailsCntrl.calculatePrices(detail);
            Test.stopTest();
            System.assertEquals('{"onRoadPriceTwo":203070.0,"onRoadPriceOne":3870.0,"journeyStatus":null,"finalPrice":780.0,"exShowroomPriceTwo":199980.0,"exShowroomPriceOne":780.0}',response);
        }
        Catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        } 
        
    } 
    
    /*  @isTest
public static void getLoanDetailsTest(){
try{
Opportunity opgl1 = new Opportunity();
opgl1.StageName = 'Qualification';
opgl1.CloseDate = Date.newInstance(2021, 1, 11);
opgl1.Name = 'testone';
insert opgl1;

Test.startTest();
IND_LWC_LoanDetailsCntrl.getLoanDetails(opgl1.Id);
Test.stopTest();
}catch(Exception e){
System.assertEquals('Script-thrown exception', e.getMessage());
}

} */
    
    @isTest
    public static void fetchLoanDetailsTest(){
        try{    
            List<Opportunity> opfList = new List<Opportunity>();
            Opportunity opfd1 = new Opportunity();
            opfd1.StageName = 'Qualification';
            opfd1.CloseDate = Date.newInstance(2021, 1, 11);
            opfd1.Name = 'testone';
            opfd1.Vehicle_Type__c = 'New';
            opfd1.Product_Type__c = 'Two Wheeler';
            insert opfd1;
            opfList.add(opfd1);
            
            List<Applicant__c> appfList = new List<Applicant__c>();
            Applicant__c apsd1 = new Applicant__c();
            apsd1.Opportunity__c = opfList[0].Id;
            apsd1.Contact_number__c = '9743514830';
            apsd1.Applicant_Type__c = 'Borrower';
            insert apsd1;
            appfList.add(apsd1); 
            
            Vehicle_Detail__c vg2 = new Vehicle_Detail__c();
            vg2.Loan_Application__c = opfd1.Id;
            vg2.Base_Price__c = 100000.00;
            vg2.Ben_Code__c = 'testveh';
            vg2.Variant__c = 'testvariant';
            insert vg2; 
            
            Product2 pd1 = new Product2();
            pd1.Name = vg2.Variant__c;
            pd1.Asset_Category__c = 'pd';
            //pd1.Capacity_1__c = 'tsp1';
            //   pd1.Capacity_2__c = 'tsp2';
            pd1.Type__c = 'Make';
            pd1.External_Reference_Id__c = '58568568';
            insert pd1;
            
            vehicleCategoryCode__mdt vehicleCategoryCodes = new vehicleCategoryCode__mdt();
            vehicleCategoryCodes.vehicleType__c = opfd1.Vehicle_Type__c;
            vehicleCategoryCodes.productType__c = opfd1.Product_Type__c;
            vehicleCategoryCodes.vehicleCategoryCode__c = 'N';
            
            List<ROI_Master__c> rmList = new List<ROI_Master__c>();
            ROI_Master__c rm1 = new ROI_Master__c();
            rm1.Description__c = System.Label.ROI;
            rm1.Vehicle_Category__c = vehicleCategoryCodes.vehicleCategoryCode__c;
            rm1.Product_Segment__c = 'TWO_WHEELER';
            rm1.External_Id__c = '78437';
            rm1.Max_Value__c = 1000;
            rm1.Min_Value__c = 5000;
            insert rm1;
            rmList.add(rm1); 
            
            List<Documents__c> docList = new List<Documents__c>();
            Documents__c dsd1 = new Documents__c();
            dsd1.Applicant__c = appfList[0].Id;
            dsd1.Opportunity_Relation__c = opfList[0].Id;
            //dsd1.Document_Type__c = 'Aadhaar';
            dsd1.KYC_City__c = 'Salem';
            dsd1.Proof_of_Address_POA__c = true;
            dsd1.RecordTypeId = Schema.SObjectType.Documents__c.getRecordTypeInfosByName().get('KYC Document').getRecordTypeId();
            insert dsd1;
            docList.add(dsd1);
            
            IND_LWC_LoanDetailsCntrl.LoanDetailResponseWrapper lw1 = new IND_LWC_LoanDetailsCntrl.LoanDetailResponseWrapper();
            lw1.maxValue = rm1.Max_Value__c;
            lw1.minValue = rm1.Min_Value__c;
            
            Test.startTest();
            IND_LWC_LoanDetailsCntrl.fetchLoanDetails(opfd1.Id);
            Test.stopTest();
        }catch(Exception e){
            //System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    @isTest
    public static void fetchLoanDetailsTest2(){
        try{    
            List<Opportunity> opfList = new List<Opportunity>();
            Opportunity opfd1 = new Opportunity();
            opfd1.StageName = 'Qualification';
            opfd1.CloseDate = Date.newInstance(2021, 1, 11);
            opfd1.Name = 'testone';
            opfd1.Vehicle_Type__c = 'New';
            opfd1.Product_Type__c = 'Tractor';
            insert opfd1;
            opfList.add(opfd1);
            
            List<Applicant__c> appfList = new List<Applicant__c>();
            Applicant__c apsd1 = new Applicant__c();
            apsd1.Opportunity__c = opfList[0].Id;
            apsd1.Contact_number__c = '9743514830';
            apsd1.Applicant_Type__c = 'Borrower';
            insert apsd1;
            appfList.add(apsd1); 
            
            Vehicle_Detail__c vg2 = new Vehicle_Detail__c();
            vg2.Loan_Application__c = opfd1.Id;
            vg2.Base_Price__c = 100000.00;
            vg2.Ben_Code__c = 'testveh';
            vg2.Variant__c = 'testvariant';
            insert vg2; 
            
            Product2 pd1 = new Product2();
            pd1.Name = vg2.Variant__c;
            pd1.Asset_Category__c = 'pd';
            //pd1.Capacity_1__c = 'tsp1';
            //   pd1.Capacity_2__c = 'tsp2';
            pd1.Type__c = 'Make';
            pd1.External_Reference_Id__c = '58568568';
            insert pd1;
            
            vehicleCategoryCode__mdt vehicleCategoryCodes = new vehicleCategoryCode__mdt();
            vehicleCategoryCodes.vehicleType__c = opfd1.Vehicle_Type__c;
            vehicleCategoryCodes.productType__c = opfd1.Product_Type__c;
            vehicleCategoryCodes.vehicleCategoryCode__c = 'N';
            
            List<ROI_Master__c> rmList = new List<ROI_Master__c>();
            ROI_Master__c rm1 = new ROI_Master__c();
            rm1.Description__c = System.Label.ROI;
            rm1.Vehicle_Category__c = vehicleCategoryCodes.vehicleCategoryCode__c;
            rm1.Product_Segment__c = 'TWO_WHEELER';
            rm1.External_Id__c = '78437';
            rm1.Max_Value__c = 1000;
            rm1.Min_Value__c = 5000;
            insert rm1;
            rmList.add(rm1); 
            
            List<Documents__c> docList = new List<Documents__c>();
            Documents__c dsd1 = new Documents__c();
            dsd1.Applicant__c = appfList[0].Id;
            dsd1.Opportunity_Relation__c = opfList[0].Id;
            //dsd1.Document_Type__c = 'Aadhaar';
            dsd1.KYC_City__c = 'Salem';
            dsd1.Proof_of_Address_POA__c = true;
            dsd1.RecordTypeId = Schema.SObjectType.Documents__c.getRecordTypeInfosByName().get('KYC Document').getRecordTypeId();
            insert dsd1;
            docList.add(dsd1);
            
            IND_LWC_LoanDetailsCntrl.LoanDetailResponseWrapper lw1 = new IND_LWC_LoanDetailsCntrl.LoanDetailResponseWrapper();
            lw1.maxValue = rm1.Max_Value__c;
            lw1.minValue = rm1.Min_Value__c;
            
            Test.startTest();
            IND_LWC_LoanDetailsCntrl.fetchLoanDetails(opfd1.Id);
            Test.stopTest();
        }catch(Exception e){
            //System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    @isTest
    public static void fetchLoanDetailsTest11(){
        try{    
            List<Opportunity> opfList = new List<Opportunity>();
            Opportunity opfd1 = new Opportunity();
            opfd1.StageName = 'Qualification';
            opfd1.CloseDate = Date.newInstance(2021, 1, 11);
            opfd1.Name = 'testone';
            opfd1.Vehicle_Type__c = 'New';
            opfd1.Product_Type__c = 'Passenger Vehicles';
            insert opfd1;
            opfList.add(opfd1);
            
            List<Applicant__c> appfList = new List<Applicant__c>();
            Applicant__c apsd1 = new Applicant__c();
            apsd1.Opportunity__c = opfList[0].Id;
            apsd1.Contact_number__c = '9743514830';
            apsd1.Applicant_Type__c = 'Borrower';
            insert apsd1;
            appfList.add(apsd1); 
            
            Vehicle_Detail__c vg2 = new Vehicle_Detail__c();
            vg2.Loan_Application__c = opfd1.Id;
            vg2.Base_Price__c = 100000.00;
            vg2.Ben_Code__c = 'testveh';
            vg2.Variant__c = 'testvariant';
            insert vg2; 
            
            Product2 pd1 = new Product2();
            pd1.Name = vg2.Variant__c;
            pd1.Asset_Category__c = 'pd';
            //pd1.Capacity_1__c = 'tsp1';
            //   pd1.Capacity_2__c = 'tsp2';
            pd1.Type__c = 'Make';
            pd1.External_Reference_Id__c = '58568568';
            insert pd1;
            
            vehicleCategoryCode__mdt vehicleCategoryCodes = new vehicleCategoryCode__mdt();
            vehicleCategoryCodes.vehicleType__c = opfd1.Vehicle_Type__c;
            vehicleCategoryCodes.productType__c = opfd1.Product_Type__c;
            vehicleCategoryCodes.vehicleCategoryCode__c = 'N';
            
            List<ROI_Master__c> rmList = new List<ROI_Master__c>();
            ROI_Master__c rm1 = new ROI_Master__c();
            rm1.Description__c = System.Label.ROI;
            rm1.Vehicle_Category__c = vehicleCategoryCodes.vehicleCategoryCode__c;
            rm1.Product_Segment__c = 'TWO_WHEELER';
            rm1.External_Id__c = '78437';
            rm1.Max_Value__c = 1000;
            rm1.Min_Value__c = 5000;
            insert rm1;
            rmList.add(rm1); 
            
            List<Documents__c> docList = new List<Documents__c>();
            Documents__c dsd1 = new Documents__c();
            dsd1.Applicant__c = appfList[0].Id;
            dsd1.Opportunity_Relation__c = opfList[0].Id;
            //dsd1.Document_Type__c = 'Aadhaar';
            dsd1.KYC_City__c = 'Salem';
            dsd1.Proof_of_Address_POA__c = true;
            dsd1.RecordTypeId = Schema.SObjectType.Documents__c.getRecordTypeInfosByName().get('KYC Document').getRecordTypeId();
            insert dsd1;
            docList.add(dsd1);
            
            IND_LWC_LoanDetailsCntrl.LoanDetailResponseWrapper lw1 = new IND_LWC_LoanDetailsCntrl.LoanDetailResponseWrapper();
            lw1.maxValue = rm1.Max_Value__c;
            lw1.minValue = rm1.Min_Value__c;
            
            Test.startTest();
            IND_LWC_LoanDetailsCntrl.fetchLoanDetails(opfd1.Id);
            Test.stopTest();
        }catch(Exception e){
            // System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void fetchLoanDetailsTest1(){
        try{    
            List<Opportunity> opfList = new List<Opportunity>();
            Opportunity opfd1 = new Opportunity();
            opfd1.StageName = 'Qualification';
            opfd1.CloseDate = Date.newInstance(2021, 1, 11);
            opfd1.Name = 'testone';
            opfd1.Vehicle_Type__c = 'New';
            opfd1.Product_Type__c = 'Two Wheeler';
            insert opfd1;
            opfList.add(opfd1);
            
            List<Applicant__c> appfList = new List<Applicant__c>();
            Applicant__c apsd1 = new Applicant__c();
            apsd1.Opportunity__c = opfList[0].Id;
            apsd1.Contact_number__c = '9743514830';
            apsd1.Applicant_Type__c = 'Borrower';
            insert apsd1;
            appfList.add(apsd1); 
            
            Retry_Count__c rc1 = new Retry_Count__c();
            rc1.Loan_Application_Id__c = opfd1.Id;
            rc1.Service_Name__c = System.Label.carwaleapi;
            rc1.User_Id__c = UserInfo.getUserId();
            rc1.Count__c = 7;
            insert rc1;
            
            /*   Vehicle_Detail__c vg2 = new Vehicle_Detail__c();
vg2.Loan_Application__c = opfd1.Id;
vg2.Base_Price__c = 100000.00;
vg2.Ben_Code__c = 'testveh';
vg2.Variant__c = 'testvariant';
insert vg2;  

Product2 pd1 = new Product2();
pd1.Name = vg2.Variant__c;
pd1.Asset_Category__c = 'pd';
//pd1.Capacity_1__c = 'tsp1';
//   pd1.Capacity_2__c = 'tsp2';
pd1.Type__c = 'Make';
pd1.External_Reference_Id__c = '58568568';
insert pd1; */
            
            vehicleCategoryCode__mdt vehicleCategoryCodes = new vehicleCategoryCode__mdt();
            vehicleCategoryCodes.vehicleType__c = opfd1.Vehicle_Type__c;
            vehicleCategoryCodes.productType__c = opfd1.Product_Type__c;
            vehicleCategoryCodes.vehicleCategoryCode__c = 'N';
            
            List<ROI_Master__c> rmList = new List<ROI_Master__c>();
            ROI_Master__c rm1 = new ROI_Master__c();
            rm1.Description__c = System.Label.ROI;
            rm1.Vehicle_Category__c = vehicleCategoryCodes.vehicleCategoryCode__c;
            rm1.External_Id__c = '78437';
            insert rm1;
            rmList.add(rm1); 
            
            List<Documents__c> docList = new List<Documents__c>();
            Documents__c dsd1 = new Documents__c();
            dsd1.Applicant__c = appfList[0].Id;
            dsd1.Opportunity_Relation__c = opfList[0].Id;
            //dsd1.Document_Type__c = 'Aadhaar';
            dsd1.KYC_City__c = 'Salem';
            dsd1.Proof_of_Address_POA__c = true;
            dsd1.RecordTypeId = Schema.SObjectType.Documents__c.getRecordTypeInfosByName().get('KYC Document').getRecordTypeId();
            insert dsd1;
            docList.add(dsd1);
            
            City_State_Master__c csm1 = new City_State_Master__c();
            csm1.Name = dsd1.KYC_City__c;
            csm1.City_Code__c = 'PORT BLAIR';
            csm1.Carwale_ID__c = 296;
            insert csm1;
            
            Test.startTest();
            IND_LWC_LoanDetailsCntrl.fetchLoanDetails(opfd1.Id);
            IND_LWC_LoanDetailsCntrl.fetchLoanDetails('test');
            IND_LWC_LoanDetailsCntrl.fetchLoanDetails(null);
            Test.stopTest();
        }catch(Exception e){
            // System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void getVehicleTypeTest(){
        Opportunity opgl1 = new Opportunity();
        opgl1.StageName = 'Qualification';
        opgl1.CloseDate = Date.newInstance(2021, 1, 11);
        opgl1.Name = 'testone';
        insert opgl1;
        
        Test.startTest();
        IND_LWC_LoanDetailsCntrl.getVehicleType(opgl1.Id);
        Test.stopTest();
    }
    
    @isTest
    public static void updateApplicantSubStageTest(){
        try{
            Opportunity opga1 = new Opportunity();
            opga1.StageName = 'Qualification';
            opga1.CloseDate = Date.newInstance(2021, 1, 11);
            opga1.Name = 'testone';
            opga1.Customer_Type__c = 'Individual';
            opga1.Product_Type__c = System.Label.Tractor;
            insert opga1;
            
            Applicant__c apga1 = new Applicant__c();
            apga1.Opportunity__c = opga1.Id;
            apga1.Contact_number__c = '9743514830';
            apga1.Applicant_Type__c = 'Borrower';
            apga1.In_Active_Applicant__c = false;
            insert apga1;
            
            Test.startTest();
            IND_LWC_LoanDetailsCntrl.updateApplicantSubStage(opga1.Id);
            IND_LWC_LoanDetailsCntrl.updateApplicantSubStage('test');
            Test.stopTest();
            
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    @isTest
    public static void getVehicleDetailsTestException(){
        try{
            
            Test.startTest();
            IND_LWC_LoanDetailsCntrl.getVehicleDetails('$@312');
            Test.stopTest();
        }
        catch(Exception e){
            System.assertEquals('Vehicle Details not available.', e.getMessage());
        }
    }
    @isTest
    public static void updateApplicantSubStageTestElsePart(){
        try{
            Opportunity opga1 = new Opportunity();
            opga1.StageName = 'Qualification';
            opga1.CloseDate = Date.newInstance(2021, 1, 11);
            opga1.Name = 'testone';
            insert opga1;
            
            Applicant__c apga1 = new Applicant__c();
            apga1.Opportunity__c = opga1.Id;
            apga1.Contact_number__c = '9743514830';
            apga1.Applicant_Type__c = 'Borrower';
            apga1.In_Active_Applicant__c = false;
            insert apga1;
            
            Test.startTest();
            IND_LWC_LoanDetailsCntrl.updateApplicantSubStage(opga1.Id);
            IND_LWC_LoanDetailsCntrl.updateApplicantSubStage('test');
            Test.stopTest();
            
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    public static void saveVehicleDetailsForTractorTest(){
        try{
            Opportunity opga1 = new Opportunity();
            opga1.StageName = 'Qualification';
            opga1.CloseDate = Date.newInstance(2021, 1, 11);
            opga1.Name = 'testone';
            insert opga1;
            
            Applicant__c apga1 = new Applicant__c();
            apga1.Opportunity__c = opga1.Id;
            apga1.Contact_number__c = '9743514830';
            apga1.Applicant_Type__c = 'Borrower';
            apga1.In_Active_Applicant__c = false;
            insert apga1;
            
            Vehicle_Detail__c vg2 = new Vehicle_Detail__c();
            vg2.Loan_Application__c = opga1.Id;
            vg2.Base_Price__c = 100000.00;
            vg2.Ben_Code__c = 'testveh';
            vg2.Variant__c = 'testvariant';
            insert vg2; 
            
            
            IND_LWC_LoanDetailsCntrl.vehicleDetailsWrapper vehicleWrapper = new IND_LWC_LoanDetailsCntrl.vehicleDetailsWrapper();
            vehicleWrapper.recordId = vg2.id;
            vehicleWrapper.requiredLoanAmount = 1200;
            vehicleWrapper.requiredTenure = 120;
            vehicleWrapper.requiredCRMIRRTW = 3400;
            vehicleWrapper.isCustomerInterested = true;
            vehicleWrapper.funded = true;
            vehicleWrapper.nonFunded = false;
            vehicleWrapper.firstYrInsurancePremium = 12;
            vehicleWrapper.gstAmount = 120;
            vehicleWrapper.invoicePrice = 100;
            vehicleWrapper.basicPrice = 230;
            vehicleWrapper.costOfBody = 780;
            vehicleWrapper.costOfChassis = 12;
            
            List<IND_LWC_LoanDetailsCntrl.vehicleDetailsWrapper> vehicleWrapperList = new List<IND_LWC_LoanDetailsCntrl.vehicleDetailsWrapper >();
            vehicleWrapperList.add(vehicleWrapper);
            Test.startTest();
            IND_LWC_LoanDetailsCntrl.saveVehicleDetailsForTractor(JSON.serialize(vehicleWrapperList));
            
            Test.stopTest();
            
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    
    
}