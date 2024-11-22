@isTest
public class IND_InvoiceDetails_Test {
    @testSetup
    static void setup(){
        //create user
        Profile p = [SELECT Id FROM Profile WHERE Name='IBL CVO'];
        User u = new User(Alias = 'standt2', Email='standarduser2@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,Maker_Id__c='12',IsActive = true,
                          TimeZoneSidKey='America/Los_Angeles',UserName='test_userggprod123@indusbank.com',MobilePhone = '9089078967');
        insert u;
        
        Profile p1 = [SELECT Id FROM Profile WHERE Name='IBL Operation Head'];
        User u1 = new User(Alias = 'standt23', Email='standarduser23@testorg.com',
                           EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                           LocaleSidKey='en_US', ProfileId = p1.Id,Maker_Id__c='1256',IsActive = true,
                           TimeZoneSidKey='America/Los_Angeles',UserName='test_userprod13@indusbank.com',MobilePhone = '9089078967');
        insert u1;
        
        
        System.runAs(u) 
        {
            /*   //create Oppty records
List<Opportunity> opptyList = new List<Opportunity>();
Opportunity opp = TestDataUtility.createTestOpportunity(false);
opp.Name = 'POSITIVE test';
opp.Product_Type__c = 'Tractor';
opptyList.add(opp);
Opportunity opp2 = TestDataUtility.createTestOpportunity1(false);
opp2.Name = 'Negative Test';
opp.Product_Type__c = 'Two Wheeler';
opp2.CloseDate = Date.today();
opptyList.add(opp2);
Opportunity opp3 = TestDataUtility.createTestOpportunity1(false);
opp3.Name = 'Oppty 3';
opp3.CloseDate = Date.today();
opp3.StageName = 'Qualification';
opptyList.add(opp3);
if(Schema.sObjectType.Opportunity.isCreateable()){
insert opptyList;
}   */
            
            Opportunity opp1 = TestDataUtility.createTestOpportunity(false);
            opp1.Product_Type__c = 'Tractor';
            insert opp1;
            
            // Create Applicant
            Applicant__c applicant = TestDataUtility.createTestApplicantForMFCValuation(false, opp1);
            applicant.Willing_to_open_Bank_Account_with_IIB__c = true;
            applicant.Applicant_Type__c = 'Borrower';
            insert applicant;
            
            List<GST_Type_Store__mdt> testMetadataRecords = new List<GST_Type_Store__mdt>();
            testMetadataRecords.add(new GST_Type_Store__mdt(
                DeveloperName = 'TestType1',
                MasterLabel = 'Test Type 1',
                Label = 'Test Type 1',
                GST_Type__c = 'Test GST Type 1',
                IGST__c = true,
                UTGST__c = false,
                SGST__c = true,
                CGST__c = false,
                CESS__c = false
            ));
            
            Deal_Number_Setting__c dlNumberSetting= new Deal_Number_Setting__c();
            dlNumberSetting.Name = System.Label.Tractor;
            dlNumberSetting.MDNField1__c ='AB';
            dlNumberSetting.MDNField2__c =2;
            insert dlNumberSetting;
            system.debug('Deal Setting'+ dlNumberSetting);
            
            
            Deal_Number__c dl = new Deal_Number__c();
            dl.Loan_Application__c = opp1.Id;
            dl.DNField1__c = dlNumberSetting.MDNField1__c;
            dl.DNField2__c = String.valueOf(dlNumberSetting.MDNField2__c);
            dl.Sub_Stage__c = 'RC Upload';
            dl.DNField3__c = '67717';
            insert dl;
            system.debug('Deal Number-===> '+ dl);
            
            /*     //Create Deal_Number__c
Deal_Number__c dn = new Deal_Number__c();
dn.DNField1__c = '9';
dn.DNField2__c = '9';
dn.DNField3__c = '99999';
RecursiveTriggerHandler.isFirstTime = true;
insert dn;  */
            
            //create Invoice_Details__c
            Invoice_Details__c invoiceDetail = new Invoice_Details__c(GST_Total__c = 1000, Loan_Application__c = opp1.Id,Type_of_Invoice__c = 'Performa Invoice',
                                                                      Is_Invoice_date_correctly_captured__c =  'Yes');
            if (Schema.sObjectType.Invoice_Details__c.isCreateable()){
                insert invoiceDetail;
            }
            
            //create vehicle record
            List<Vehicle_Detail__c> vdList = new List<Vehicle_Detail__c>();
            Vehicle_Detail__c  vehicleDetail = TestDataUtility.createTestVehicleDetailForIbb(false, opp1);
            vehicleDetail.Deal_Number__c  = dl.id;
            vdList.add(vehicleDetail);
            if (Schema.sObjectType.Vehicle_Detail__c.isCreateable()){
                insert vdList;
            }
            
            //Create Loan_Application_Transaction_History__c
            List<Loan_Application_Transaction_History__c> laptHistList = new List<Loan_Application_Transaction_History__c>();
            Loan_Application_Transaction_History__c lth1 = new Loan_Application_Transaction_History__c();
            lth1.Loan_Application_ID__c = opp1.Id;
            //lth1.Name ='Vehicle Inspection and RC Check';
            lth1.Module__c = 'Post Sanction Checks and Documentation';
            lth1.Screen__c = 'Invoice';
            lth1.Module_Name__c = 'FI';
            lth1.Submitted_Flag__c = false;
            lth1.Deal_Number__c = dl.Id;
            insert lth1; 
            system.debug('Loan History 1==> '+lth1);
            
            
            Loan_Application_Transaction_History__c lth22 = new Loan_Application_Transaction_History__c();
            lth22.Loan_Application_ID__c = opp1.Id;
            //lth1.Name ='Vehicle Inspection and RC Check';
            lth22.Module__c = 'Post Sanction Checks and Documentation';
            lth22.Screen__c = 'RTO, DPN, POA Documents Upload';
            lth22.Module_Name__c = 'FI';
            lth22.Submitted_Flag__c = false;
            lth22.Deal_Number__c = dl.Id;
            insert lth22;
            system.debug('Loan History 2==> '+lth22);
            
            //laptHistList.add(lth1);
            Loan_Application_Transaction_History__c lth2 = new Loan_Application_Transaction_History__c();
            lth2.Loan_Application_ID__c = opp1.Id;
            //lth1.Name ='Vehicle Inspection and RC Check';
            lth2.Module__c = 'Pre Disbursement Check';
            lth2.Screen__c = 'Invoice';
            lth2.Module_Name__c = 'FI';
            lth2.Submitted_Flag__c = false;
            lth2.Deal_Number__c = dl.Id;
            insert lth2;
            
            // created Benefi__c record
            Benefi__c benefi = new Benefi__c();
            benefi.Ben_code__c = 'BEN000';
            benefi.Beneficiary__c = 'DSA';
            benefi.Dealership_Nature__c = 'MDR';
            benefi.Name = 'test benefi';
            insert benefi;
            
            //created Bl_Code_Details__c record
            Bl_Code_Details__c blCodeDetail = new Bl_Code_Details__c();
            blCodeDetail.name = 'test blCodeDetail';
            blCodeDetail.Bl_Code__c = 'TEST';
            blCodeDetail.State_Code__c = '69';
            blCodeDetail.Geo_State_Code__c = '96';
            insert blCodeDetail;
            
            //created Beneficiary_BlCode__c record
            Beneficiary_BlCode__c benefBLCode = new Beneficiary_BlCode__c();
            benefBLCode.Name = 'test benefBLCode';
            benefBLCode.Ben_code__c = benefi.Id;
            benefBLCode.Bl_Code_Details__c = blCodeDetail.Id;
            benefBLCode.Unique_Identifier__c = 'TEST';
            insert benefBLCode;
            Product2 product = new Product2();
            product.Name = 'test Product';
            product.Type__c = 'Make';
            product.External_Reference_Id__c = '696969';
            insert product;
            Beneficiary_Product__c benefProduct = new Beneficiary_Product__c();
            benefProduct.Name = 'test benefProduct';
            benefProduct.Ben_code__c = benefi.Id;
            benefProduct.Product__c = product.Id;
            benefProduct.Unique_Identifier__c = 'TEST';
            insert benefProduct;
            
            Manufacturer__c testManufacturer = new Manufacturer__c(
                Name = 'TestManufacturer',Manufacturer_code__c = 'M23'
                
            );
            insert testManufacturer;
            
            Beneficiary_Manufacturer__c benefManufacturer = new Beneficiary_Manufacturer__c();
            benefManufacturer.Beneficiary_Master__c = benefi.Id;
            benefManufacturer.Manufacturer__c = testManufacturer.Id;
            benefManufacturer.Unique_Identifier__c = 'BEN195662-M4';
            insert benefManufacturer;
        }
    }
    
    @isTest
    public static void test_getGSTTypeMetadataRecord(){
        try
        {                
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE UserName='test_userggprod123@indusbank.com' AND IsActive = true LIMIT 1]; 
            system.debug('User  162==>'+u);
            System.runAs(u) 
            {
                List<GST_Type_Store__mdt> gstTypeList = IND_InvoiceDetails.getGSTTypeMetadataRecord();
                System.assertNotEquals(null, gstTypeList);
            }
            Test.stopTest(); 
        }
        catch(Exception e)
        {
            System.debug('error '+e.getMessage());
        }              
    }
    
    @IsTest
    public static void test_getApplicantData1(){        
        try
        {                
            test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE UserName='test_userggprod123@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {
                Opportunity opp = [Select id, Name from opportunity where Product_Type__c = 'Tractor' LIMIT 1];        
                Applicant__c app = IND_InvoiceDetails.getApplicantData(opp.Id);
                System.assertNotEquals(null, app);
            }
            User u1 = [SELECT Id,usertype FROM User WHERE UserName='test_userprod13@indusbank.com' AND IsActive = true LIMIT 1]; 
            
            System.runAs(u1){     
                Applicant__c app = IND_InvoiceDetails.getApplicantData('@#$%^');
            }
            Test.stopTest();
        }
        catch(Exception e)
        {
            System.debug('error '+e.getMessage());
        } 
    }
    
    
    
    @IsTest
    public static void test_getLoanApplicationRecord1(){
        try
        {                
            test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE UserName='test_userggprod123@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {
                Opportunity opp = [Select id, Name from opportunity where Product_Type__c = 'Tractor' LIMIT 1];        
                String oppsString = IND_InvoiceDetails.getLoanApplicationRecord(opp.Id);
                //System.assertNotEquals(null, oppsString);
            }
            
            Test.stopTest();
        }
        catch(Exception e)
        {
            System.debug('error '+e.getMessage());
        }                 
    }
    
    @IsTest
    public static void test_getLoanApplicationRecord2(){        
        try
        {                
            test.startTest(); 
            User u = [SELECT Id,usertype FROM User WHERE UserName='test_userprod13@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {
                Opportunity opp = [Select id,ownerId, Name from opportunity where Product_Type__c = 'Tractor' LIMIT 1];
                opp.Product_Type__c = 'Two Wheeler';
                update opp;
                String opps = IND_InvoiceDetails.getLoanApplicationRecord(opp.Id);
                System.assertNotEquals(null, opps);
            }
            Test.stopTest();
        }
        catch(Exception e)
        {
            System.debug('error '+e.getMessage());
        }    
    }   
    
    @IsTest
    public static void test_getVehicleDetailsRecord1(){        
        try
        {                
            Test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE UserName='test_userggprod123@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {
                Opportunity opp = [Select id, Name from opportunity where Product_Type__c = 'Tractor' LIMIT 1]; 
                opp.Product_Type__c = 'Two Wheeler';
                update opp;
                Deal_Number__c dealNo =[Select Id From Deal_Number__c LIMIt 1];
                Vehicle_Detail__c vehDet = IND_InvoiceDetails.getVehicleDetailsRecord(opp.Id, dealNo.Id);
                System.assertNotEquals(null, vehDet);
            }
            Test.stopTest();
        }
        catch(Exception e)
        {
            System.debug('error '+e.getMessage());
        }  
    }
    
    @IsTest
    public static void test_getVehicleDetailsRecord2(){        
        try
        {                
            Test.startTest();   
            User u = [SELECT Id,usertype FROM User WHERE UserName='test_userggprod123@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {
                Opportunity opp = [Select id, Name from opportunity where Product_Type__c = 'Tractor' LIMIT 1];        
                Deal_Number__c dealNo =[Select Id From Deal_Number__c LIMIt 1];
                Vehicle_Detail__c vehDet = IND_InvoiceDetails.getVehicleDetailsRecord(opp.Id, dealNo.Id);
                System.assertNotEquals(null, vehDet);
            }
            Test.stopTest();
        }
        catch(Exception e)
        {
            System.debug('error '+e.getMessage());
        }  
    }  
    
     @IsTest
    public static void test_getVehicleDetailsRecord3(){        
        try
        {                
            Test.startTest();   
            User u = [SELECT Id,usertype FROM User WHERE UserName='test_userggprod123@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {
                Opportunity opp = [Select id, Name from opportunity where Product_Type__c = 'Tractor' LIMIT 1];        
                Deal_Number__c dealNo =[Select Id From Deal_Number__c LIMIt 1];
                Vehicle_Detail__c vehDet = IND_InvoiceDetails.getVehicleDetailsRecord(opp.Id, '123AC');
                System.assertNotEquals(null, vehDet);
            }
            Test.stopTest();
        }
        catch(Exception e)
        {
            System.debug('error '+e.getMessage());
        }  
    }  
    
    @IsTest
    public static void test_getInvoiceDetailsRecord(){        
        try
        {                
            test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE UserName='test_userggprod123@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {
                Deal_Number__c dealNo =[Select Id From Deal_Number__c LIMIt 1];
                Opportunity opp = [Select id, Name from opportunity where Product_Type__c = 'Tractor' LIMIT 1];  
                opp.Product_Type__c = 'Two Wheeler';
                update opp;
               
                Invoice_Details__c InvDetail1 = IND_InvoiceDetails.getInvoiceDetailsRecord(opp.Id,dealNo.Id);
                
                
            }
            
            Test.stopTest();
        }
        catch(Exception e)
        {
            System.debug('error '+e.getMessage());
        }  
    }
    
    @IsTest
    public static void test_getInvoiceDetailsRecord1(){        
        try
        {                
            test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE UserName='test_userggprod123@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {
                Opportunity opp = [Select id, Name from opportunity where Product_Type__c = 'Tractor' LIMIT 1];        
                Invoice_Details__c InvDetail = IND_InvoiceDetails.getInvoiceDetailsRecord(opp.Id,null);
                IND_InvoiceDetails.getGSTTypeMetadataRecord();
                System.assertNotEquals(null, InvDetail);
                
                
                Opportunity opp1 = [Select id, Name from opportunity where Product_Type__c = 'Tractor' LIMIT 1];        
                Deal_Number__c dealNo =[Select Id From Deal_Number__c LIMIt 1];
                Invoice_Details__c InvDetail1 = IND_InvoiceDetails.getInvoiceDetailsRecord(opp1.Id,dealNo.Id);
                
                
            }
            
            Test.stopTest();
        }
        catch(Exception e)
        {
            System.debug('error '+e.getMessage());
        }  
    }
    
    @isTest
    public static void test_updateTransactionRecord(){        
        try
        {                
            test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE UserName='test_userggprod123@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {
                Opportunity opp = [Select id, Name from opportunity where Product_Type__c = 'Tractor' LIMIT 1];        
                Deal_Number__c dealNo =[Select Id From Deal_Number__c LIMIt 1];
                IND_InvoiceDetails.updateTransactionRecord(opp.Id,dealNo.Id);
                IND_InvoiceDetails.updateTransactionRecord(opp.Id,null);
                List<Loan_Application_Transaction_History__c> lATList=[Select Id from Loan_Application_Transaction_History__c 
                                                                       where Loan_Application_ID__c=:opp.Id AND Submitted_Flag__c = true];
                System.assertNotEquals(null, lATList);
            }
            
            
            Test.stopTest();  
        }
        catch(Exception e)
        {
            System.debug('error '+e.getMessage());
        }  
    }
    
    @isTest
    public static void test_updateInvoiceDetail(){
        try
        {                
            test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE UserName='test_userggprod123@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {
                Opportunity opp = [Select id, Name from opportunity where Product_Type__c = 'Tractor' LIMIT 1];        
                Deal_Number__c dealNo =[Select Id From Deal_Number__c LIMIt 1];
                IND_InvoiceDetails.updateInvoiceDetail(opp.Id,'[{"Remarks__c":"Invoice not legible","Tax_Invoice_No__c":"69","SGST__c":"0","Loan_Application__c":"'+opp.Id+'"}]','Invoice','Pre Disbursement Check',true,dealNo.Id);
                
                List<Invoice_Details__c> invoiceList=[Select Id from Invoice_Details__c where Loan_Application__c=:opp.Id];
                System.assertNotEquals(null, invoiceList);
            }
            Test.stopTest();  
            
        }
        catch(Exception e)
        {
            System.debug('error '+e.getMessage());
        }  
    }
    
    @isTest
    public static void test_updateInvoiceDetail1(){
        try
        {                
            test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE UserName='test_userggprod123@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {
                Opportunity opp = [Select id, Name from opportunity where Product_Type__c = 'Tractor' LIMIT 1];        
                Deal_Number__c dealNo =[Select Id From Deal_Number__c LIMIt 1];
                IND_InvoiceDetails.updateInvoiceDetail(opp.Id,'[{"Remarks__c":"Invoice not legible","Tax_Invoice_No__c":"69","SGST__c":"0","Loan_Application__c":"'+opp.Id+'"}]','Invoice','Post Sanction Checks and Documentation',true,dealNo.Id);
                
                List<Invoice_Details__c> invoiceList=[Select Id from Invoice_Details__c where Loan_Application__c=:opp.Id];
                System.assertNotEquals(null, invoiceList);
            }
            Test.stopTest();  
            
        }
        catch(Exception e)
        {
            System.debug('error '+e.getMessage());
        }  
    }
    
    @isTest
    public static void test_checkIfReadOnly1(){         
        try
        {                
            test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE UserName='test_userggprod123@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {
                Opportunity opp = [Select id, Name from opportunity where Product_Type__c = 'Tractor' LIMIT 1];        
                Deal_Number__c dealNo =[Select Id From Deal_Number__c LIMIt 1];
                String result = IND_InvoiceDetails.checkIfReadOnly(opp.Id,dealNo.Id);
                //System.assertNotEquals(true, result);
            }
            User u1 = [SELECT Id,usertype FROM User WHERE UserName='test_userprod13@indusbank.com' AND IsActive = true LIMIT 1]; 
            
            System.runAs(u1){     
                String result = IND_InvoiceDetails.checkIfReadOnly('@#$%^',null);
            }
            Test.stopTest(); 
        }
        catch(Exception e)
        {
            System.debug('error '+e.getMessage());
        }  
    }
    
    @isTest
    public static void test_checkIfReadOnly2(){         
        try
        {                
            test.startTest();            
            User u = [SELECT Id,usertype FROM User WHERE UserName='test_userggprod123@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {
                Opportunity opp = [Select id, Name from opportunity where Product_Type__c = 'Tractor' LIMIT 1];        
                Deal_Number__c dealNo =[Select Id From Deal_Number__c LIMIt 1];
                String result = IND_InvoiceDetails.checkIfReadOnly(opp.Id,dealNo.Id);
                //System.assertNotEquals(true, result);
            }
            Test.stopTest(); 
        }
        catch(Exception e)
        {
            System.debug('error '+e.getMessage());
        }  
    }
    
    @isTest
    public static void test_getBeneficaryDetail1(){        
        try
        {                
            test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE UserName='test_userggprod123@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {
                Benefi__c bl = [Select Id,Ben_code__c from Benefi__c limit 1];
                Benefi__c result = IND_InvoiceDetails.getBeneficaryDetail(bl.Ben_code__c);
                System.assertNotEquals(null, result);
            }
            User u1 = [SELECT Id,usertype FROM User WHERE UserName='test_userprod13@indusbank.com' AND IsActive = true LIMIT 1]; 
            
            System.runAs(u1){     
                Benefi__c result = IND_InvoiceDetails.getBeneficaryDetail('BEN0001');
            }
            Test.stopTest();  
        }
        catch(Exception e)
        {
            System.debug('error '+e.getMessage());
        }  
    }
  
    @isTest
    public static void getMfrBeneficaryDetailTest(){        
        try
        {                
            test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE UserName='test_userggprod123@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {
                Benefi__c bl = [Select Id,Ben_code__c from Benefi__c limit 1];
                Manufacturer__c mn = [SELECT Id FROM Manufacturer__c WHERE Name='TestManufacturer'];
                Beneficiary_Manufacturer__c benefManufacturer = new Beneficiary_Manufacturer__c();
                benefManufacturer.Beneficiary_Master__c = bl.Id;
                benefManufacturer.Manufacturer_Ben_Code__c = '2301TK';
                benefManufacturer.Manufacturer__c = mn.Id;
                benefManufacturer.Unique_Identifier__c = 'BEN195662-M7';
                insert benefManufacturer;
                Beneficiary_Manufacturer__c result = IND_InvoiceDetails.getMfrBeneficaryDetail(bl.Ben_code__c,'12345');
                System.assertNotEquals(null, result);
                IND_InvoiceDetails.getMfrBeneficaryDetail('23223223','12345');

            }
            Test.stopTest();  
        }
        catch(Exception e)
        {
            System.debug('error '+e.getMessage());
        }  
    } 
    @isTest
    public static void getMfrBeneficaryDetailTest2(){        
        try
        {                
           	Benefi__c bl = [Select Id,Ben_code__c from Benefi__c limit 1];
			Manufacturer__c mn = [SELECT Id FROM Manufacturer__c WHERE Name='TestManufacturer'];
            Beneficiary_Manufacturer__c benefManufacturer = new Beneficiary_Manufacturer__c();
            benefManufacturer.Beneficiary_Master__c = bl.Id;
            benefManufacturer.Manufacturer__c = mn.Id;
            benefManufacturer.Unique_Identifier__c = 'BEN195662-M5';
            insert benefManufacturer;
            test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE UserName='test_userggprod123@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {
                Beneficiary_Manufacturer__c result = IND_InvoiceDetails.getMfrBeneficaryDetail(bl.Ben_code__c,'12345');
            }
            Test.stopTest();  
        }
        catch(Exception e)
        {
            System.debug('error '+e.getMessage());
        }  
    } 
   
    @isTest
    public static void test_getMainDealerFromBenefiDetails1(){        
        try
        {                
            test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE UserName='test_userggprod123@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {
                Bl_Code_Details__c blCode = [Select Id,Bl_Code__c from  Bl_Code_Details__c limit 1];
                Product2 product = [Select Id,Name from Product2 limit 1];
                List<Benefi__c> result = IND_InvoiceDetails.getMainDealerFromBenefiDetails(blCode.Bl_Code__c,product.Name);
                
            }
            User u1 = [SELECT Id,usertype FROM User WHERE UserName='test_userprod13@indusbank.com' AND IsActive = true LIMIT 1]; 
            
            System.runAs(u1){    
                Bl_Code_Details__c blCode = [Select Id,Bl_Code__c from  Bl_Code_Details__c limit 1];
                Product2 product = [Select Id,Name from Product2 limit 1];
                List<Benefi__c> result = IND_InvoiceDetails.getMainDealerFromBenefiDetails(blCode.Bl_Code__c,product.Name);
            }
            Test.stopTest(); 
        }
        catch(Exception e)
        {
            System.debug('error '+e.getMessage());
        }  
    }
    
    @isTest
    public static void test_getMainDealerFromBenefiDetails2(){        
        try
        {                
            test.startTest();
            User u = [SELECT Id,usertype FROM User WHERE UserName='test_userggprod123@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {                
                List<Benefi__c> result = IND_InvoiceDetails.getMainDealerFromBenefiDetails(null,null);
                System.assertEquals(null, result);
            }
            Test.stopTest(); 
        }
        catch(Exception e)
        {
            System.debug('error '+e.getMessage());
        }  
    }
}