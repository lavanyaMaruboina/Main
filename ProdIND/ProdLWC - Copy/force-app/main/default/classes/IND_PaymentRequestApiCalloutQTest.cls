/*------------------------------------------------------------
Author:        Neeraj Mehethrajkar
Company:       Salesforce
Description:   This is testclass for IND_PaymentRequestApiCalloutQueueable. //SFTRAC-241
Inputs:        None 
Test Classes:    
History
Date            Author                    Comments
-------------------------------------------------------------
29-11-2023      Neeraj Mehethrajkar       Created
------------------------------------------------------------*/
@isTest
public class IND_PaymentRequestApiCalloutQTest {
    
    @isTest
    public static void getPaymentRequestCallOutRequestTest(){
        try{
            Opportunity opp = TestDataUtility.createTestLoanApplication(false);
            opp.Product_Type__c = 'Tractor';
            insert opp;
            Applicant__c app = TestDataUtility.createTestApplicant(false);
            app.Applicant_Type__c = 'Borrower';
            app.Opportunity__c = opp.Id;
            app.PACS_Member__c = 'Y';
            app.PACS_Name__c = 'test';
            insert app;
            
            Income_Details__c incD = new Income_Details__c();
            incD.Saral_date__c = System.today();
            incD.Tax_Return_Filed__c = 'Y';
            incD.Applicant__c = app.Id;
            insert incD;
            
            Deal_Number_Setting__c dlNumberSetting= new Deal_Number_Setting__c(Name = System.Label.Tractor, MDNField1__c = 'AB', MDNField2__c = 2);
            insert dlNumberSetting;    
            Deal_Number__c dl = new Deal_Number__c();
            dl.Loan_Application__c = opp.Id;
            dl.DNField1__c = 't1';
            dl.DNField2__c = '2';
            dl.Sub_Stage__c = 'test';
            insert dl;  
            
            Vehicle_Detail__c vd = new Vehicle_Detail__c();
            vd.Loan_Application__c = opp.Id;
            vd.Deal_Number__c = dl.Id;
            vd.Vehicle_Delivered__c = 'yes';
            vd.Vehicle_Registration_number__c = 'csa';
            vd.Manufacturer_Year_Month__c = '2003-03';
            vd.Make_Code__c = 'xz'; 
            vd.Product__c = 'mahindra tractor';
            vd.Variant_Code__c = 'x1';
            vd.KMS_Run__c = '0';
            vd.Serial_number__c = 'xcv1';
            insert vd;
            
            Case cs = TestDataUtility.createCaseByRecordType(false, 'FI');
            cs.Loan_Application__c = opp.Id;
            cs.Applicant__c = app.Id;
            cs.Type ='Current Residence FI';
            
            insert cs;
            
            Field_Investigation__c fi = TestDataUtility.createTestFieldInvestigation(false, cs);
            fi.Relationship__c = '';
            fi.Area__c = '123';
            fi.Pin_Code__c = '600066';
            fi.Land_Irrigation_source__c = 'test';
            fi.Type_of_Crop__c = 'test';
            fi.Yield_Per_Acre_monthly__c = 1234;
            fi.IS_CUSTOMER_HAVING_IMPLEMENT__c = 'Yes';
            fi.Agri_Commercial__c = 'Yes';
            fi.Since_how_long_in_Agri_commercial__c = '4';
            fi.Sub_Scheme_Type__c = '0.1-2 acre';
            fi.Scheme_Type__c = 'FTU';
            insert fi;
            Land_Holding_Detail__c lh = new Land_Holding_Detail__c();
            lh.Field_Investigation__c = fi.Id;
            lh.Survey_No__c = 'A123';
            lh.Land_holding_In_acres__c = 12;
            lh.Ownership_Type__c = 'Individual';
            lh.Land_holder_Name__c = 'test';
            lh.Type__c = 'Borrower';
            lh.Approximate_value_of_Agri_Land__c = 12345;
            insert lh;
            
            Crop_Master__c cm = new Crop_Master__c();
            cm.Yield_Acre__c = 123;
            cm.Sold_Price__c = 1234;
            insert cm;
            
            Crop_Detail__c cd = new Crop_Detail__c();
            cd.Crop_Type__c = 'Kharif';
            cd.Net_Income__c = 1234;
            cd.Crop_Master__c = cm.Id;
            cd.Land_Survey_No__c = 'A123';
            cd.Field_Investigation__c = fi.Id;
            insert cd;
            
            Documents__c doc = TestDataUtility.createTestDLDocs1(false, app, opp);
            doc.Taluka__c = 'test';
            doc.Village__c = 'test';
            doc.KYC_Pin_Code__c = '600006'; 
            doc.Permanent_Residential_Address_Proof__c = true;
            doc.Current_Residential_Address_Proof__c = true;
            insert doc;
            
            Invoice_Details__c invD = new Invoice_Details__c();
            invD.Invoice_Number__c = 'testInV1234';
            invD.Invoice_Date__c = System.today();
            invD.Loan_Application__c = opp.Id;
            insert invD;
            
            
            Manufacturer__c mf = new Manufacturer__c();
            mf.Manufacturer_code__c = 'xz';
            insert mf;
            
            Product2 parentpd = TestDataUtility.createTestProduct2(false);
            parentpd.Manufacturer__c = mf.Id;
            insert parentpd;
            
            Product2 pd = TestDataUtility.createTestProduct2(false);
            pd.Parent_Product__c = parentpd.Id;
            pd.External_Reference_Id__c = '58568569';
            pd.Name = 'PASSENGER VEHICLES1';
            pd.Make_Code__c = 'xz';
            insert pd;
            
            
            test.startTest();
            Test.setMock(HttpCalloutMock.class, new IND_PaymentRequestAPIMock());
            System.enqueueJob(new IND_PaymentRequestAPICalloutQueueable(opp.Id , dl.Id));
            test.stopTest();
        }
        catch(Exception ex){
            //System.assert(ex.getMessage().contains('No Response Found'));
            
        }
        
        
    }
    @isTest
    public static void getPaymentRequestCallOutRequestTest2(){
        try{
            Opportunity opp = TestDataUtility.createTestLoanApplication(false);
            opp.Product_Type__c = 'Tractor';
            insert opp;
            Applicant__c app = TestDataUtility.createTestApplicant(false);
            app.Applicant_Type__c = 'Borrower';
            app.Opportunity__c = opp.Id;
            app.PACS_Member__c = 'Y';
            app.PACS_Name__c = 'test';
            insert app;
            
            Income_Details__c incD = new Income_Details__c();
            incD.Saral_date__c = System.today();
            incD.Tax_Return_Filed__c = 'Y';
            incD.Applicant__c = app.Id;
            insert incD;
            
            Deal_Number_Setting__c dlNumberSetting= new Deal_Number_Setting__c(Name = System.Label.Tractor, MDNField1__c = 'AB', MDNField2__c = 2);
            insert dlNumberSetting;    
            Deal_Number__c dl = new Deal_Number__c();
            dl.Loan_Application__c = opp.Id;
            dl.DNField1__c = 't1';
            dl.DNField2__c = '2';
            dl.Sub_Stage__c = 'test';
            insert dl;  
            
            Vehicle_Detail__c vd = new Vehicle_Detail__c();
            vd.Loan_Application__c = opp.Id;
            vd.Deal_Number__c = dl.Id;
            vd.Vehicle_Delivered__c = 'yes';
            vd.Vehicle_Registration_number__c = 'csa';
            vd.Manufacturer_Year_Month__c = '2003-03';
            vd.Make_Code__c = 'xz'; 
            vd.Product__c = 'mahindra tractor';
            vd.Variant_Code__c = 'x1';
            vd.KMS_Run__c = '0';
            vd.Serial_number__c = 'xcv1';
            insert vd;
            
            Case cs = TestDataUtility.createCaseByRecordType(false, 'FI');
            cs.Loan_Application__c = opp.Id;
            cs.Applicant__c = app.Id;
            cs.Type ='Current Residence FI';
            
            insert cs;
            
            Field_Investigation__c fi = TestDataUtility.createTestFieldInvestigation(false, cs);
            fi.Relationship__c = '';
            fi.Area__c = '123';
            fi.Pin_Code__c = '600066';
            fi.Land_Irrigation_source__c = 'test';
            fi.Type_of_Crop__c = 'test';
            fi.Yield_Per_Acre_monthly__c = 1234;
            fi.IS_CUSTOMER_HAVING_IMPLEMENT__c = 'Yes';
            fi.Agri_Commercial__c = 'Yes';
            fi.Since_how_long_in_Agri_commercial__c = '4';
            fi.Sub_Scheme_Type__c = '0.1-2 acre';
            fi.Scheme_Type__c = 'FTU';
            insert fi;
            Land_Holding_Detail__c lh = new Land_Holding_Detail__c();
            lh.Field_Investigation__c = fi.Id;
            lh.Survey_No__c = 'A123';
            lh.Land_holding_In_acres__c = 12;
            lh.Ownership_Type__c = 'Individual';
            lh.Land_holder_Name__c = 'test';
            lh.Type__c = 'Borrower';
            lh.Approximate_value_of_Agri_Land__c = 12345;
            insert lh;
            
            Crop_Master__c cm = new Crop_Master__c();
            cm.Yield_Acre__c = 123;
            cm.Sold_Price__c = 1234;
            insert cm;
            
            Crop_Detail__c cd = new Crop_Detail__c();
            cd.Crop_Type__c = 'Kharif';
            cd.Net_Income__c = 1234;
            cd.Crop_Master__c = cm.Id;
            cd.Land_Survey_No__c = 'A123';
            cd.Field_Investigation__c = fi.Id;
            insert cd;
            
            Documents__c doc = TestDataUtility.createTestDLDocs1(false, app, opp);
            doc.Taluka__c = 'test';
            doc.Village__c = 'test';
            doc.KYC_Pin_Code__c = '600006'; 
            doc.Permanent_Residential_Address_Proof__c = true;
            doc.Current_Residential_Address_Proof__c = true;
            insert doc;
            
            Invoice_Details__c invD = new Invoice_Details__c();
            invD.Invoice_Number__c = 'testInV1234';
            invD.Invoice_Date__c = System.today();
            invD.Loan_Application__c = opp.Id;
            insert invD;
            
            
            Manufacturer__c mf = new Manufacturer__c();
            mf.Manufacturer_code__c = 'xz';
            insert mf;
            
            Product2 parentpd = TestDataUtility.createTestProduct2(false);
            parentpd.Manufacturer__c = mf.Id;
            insert parentpd;
            
            Product2 pd = TestDataUtility.createTestProduct2(false);
            pd.Parent_Product__c = parentpd.Id;
            pd.External_Reference_Id__c = '58568569';
            pd.Name = 'PASSENGER VEHICLES1';
            pd.Make_Code__c = 'xz';
            insert pd;
            
            
            test.startTest();
            Test.setMock(HttpCalloutMock.class, new IND_PaymentRequestAPIMock2());
            
            System.enqueueJob(new IND_PaymentRequestAPICalloutQueueable(opp.Id , dl.Id));
            System.enqueueJob(new IND_PaymentRequestAPICalloutQueueable(null , null));
            test.stopTest();
        }
        catch(Exception ex){
            //System.assert(ex.getMessage().contains('No Response Found'));
            
        }
        
    }
    @isTest
    public static void getPaymentRequestCallOutRequestTest_Negative1(){
        try{
            
            User u = [SELECT Id,usertype FROM User WHERE username='test_userprod123Prod@indusbank.com' AND IsActive = true LIMIT 1]; 
            System.runAs(u) 
            {	
                Test.startTest();
                System.enqueueJob(new IND_PaymentRequestAPICalloutQueueable('iuweiusdfg','dfsdf'));
                Test.stopTest();
            } 
        }
        catch(Exception ex){
            System.assert(ex.getMessage().contains('List has no rows for assignment to SObject'));
        }
    }
}