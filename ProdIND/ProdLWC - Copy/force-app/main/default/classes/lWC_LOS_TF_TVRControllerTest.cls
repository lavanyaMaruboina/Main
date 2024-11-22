/*
* @Author   : Chaynnitt Agarwal
* Version   : Initial
* Date      : 31-10-2023
* Description:  This class is a test class to create test data.
* Test Class Name : lWC_LOS_TF_TVRControllerTest 
*/

@isTest
public class lWC_LOS_TF_TVRControllerTest {
    
    @testSetup
    public static void setup(){
        Opportunity opp = TestDataUtility.createTestOpportunity(false);
        opp.Name = 'VDR Test';
        opp.StageName='Post Sanction Checks and Documentation';
        opp.Product_Type__c='Tractor';
        opp.Loan_amount__c = '1200';
        opp.Required_Tenure__c = 23;
        insert opp;
        
        Applicant__c applicant = TestDataUtility.createTestApplicantService(true,opp);
        applicant.In_Active_Applicant__c = false;
        applicant.Would_you_like_to_open_a_bank_account__c = true;
        applicant.Contact_number__c = '9100344423';
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
        
        Repayments__c rep = new Repayments__c();
        rep.Frequency__c = 'Monthly';
        rep.Loan_Application__c = opp.id;
        rep.Is_Netbanking_available_with_customer__c = 'Yes';
        insert rep;
        
        Invoice_Details__c inv = new Invoice_Details__c();
        inv.Invoice_Amount_incl_discount__c = 'yes';
        inv.Loan_Application__c = opp.id;
        insert inv;
        
        Vehicle_Detail__c veh = new Vehicle_Detail__c();
        veh.Make__c = 'Make 1';
        veh.Model__c = 'Model 1';
        veh.Loan_Application__c = opp.id;
        insert veh;
        
        Documents__c  doc = new Documents__c();
        doc.KYC_Address_Line_1__c = 'TEST Line 1';
        doc.KYC_Address_Line_2__c = 'TEST Line 1';
        doc.KYC_City__c = 'TEST Line 1';
        doc.KYC_Pin_Code__c = 'TEST Line 1';
        doc.KYC_State__c = 'TEST Line 1';
        doc.KYC_District__c = 'TEST Line 1';
        doc.Permanent_Residential_Address_Proof__c = true;
        doc.Current_Residential_Address_Proof__c = true;
        doc.Applicant__c = applicant.id;
        doc.Opportunity_Relation__c = opp.id;
        insert doc;
    }
    
    @isTest public static void testgetFieldsValue(){
        Id TVFFIRecordTypeId = Schema.SObjectType.TeleVerification__c.getRecordTypeInfosByName().get('Pre-Sanction').getRecordTypeId();
        Applicant__c app = [SELECT Id,Opportunity__c FROM Applicant__c LIMIT 1];
        Opportunity lon = [SELECT Id FROM Opportunity LIMIT 1];
        Field_Investigation__c fi = [SELECT Id FROM Field_Investigation__c LIMIT 1];
        Case cs = [SELECT Id FROM Case Limit 1];
        TeleVerification__c tele = new TeleVerification__c();
        //tele.Loan_Application__c = lon.id;
        tele.Applicant__c = app.id;
        tele.Field_Investigation__c = fi.id;
        tele.Case__c = cs.id;
        tele.TVR_Status__c = 'Positive';
        tele.RecordTypeId = TVFFIRecordTypeId;
        insert tele;
        
        Test.startTest();
        lWC_LOS_TF_TVRController.getFieldsValue(tele.id);
        lWC_LOS_TF_TVRController.getCoApplicantList(tele.id);
        Test.stopTest();
    }
    
    
    @isTest public static void testgetAssetList(){
        lWC_LOS_TF_TVRController.CoApplicantWrapper coApp = new lWC_LOS_TF_TVRController.CoApplicantWrapper('test','test','test');
        lWC_LOS_TF_TVRController.AssetWrapper assetwrp = new lWC_LOS_TF_TVRController.AssetWrapper('test','test',1.0,'test','test',2.2,'test','test');
        Id TVFFIRecordTypeId = Schema.SObjectType.TeleVerification__c.getRecordTypeInfosByName().get('Pre-Sanction').getRecordTypeId();
        Applicant__c app = [SELECT Id FROM Applicant__c LIMIT 1];
        Opportunity lon = [SELECT Id FROM Opportunity LIMIT 1];
        Field_Investigation__c fi = [SELECT Id FROM Field_Investigation__c LIMIT 1];
        Case cs = [SELECT Id FROM Case Limit 1];
        
        TeleVerification__c tele = new TeleVerification__c();
        tele.Loan_Application__c = lon.id;
        tele.Applicant__c = app.id;
        tele.Field_Investigation__c = fi.id;
        tele.Case__c = cs.id;
        tele.TVR_Status__c = 'Positive';
        tele.RecordTypeId = TVFFIRecordTypeId;
        insert tele;
        
        Test.startTest();
        lWC_LOS_TF_TVRController.getAssetList(tele.id);
        Test.stopTest();
        //lWC_LOS_TF_TVRController.getAssetList(null);
    }
    
    @isTest public static void testgetCurrentResidenceAddress(){
        Id TVFFIRecordTypeId = Schema.SObjectType.TeleVerification__c.getRecordTypeInfosByName().get('Pre-Sanction').getRecordTypeId();
        Applicant__c app = [SELECT Id FROM Applicant__c LIMIT 1];
        Opportunity lon = [SELECT Id FROM Opportunity LIMIT 1];
        Field_Investigation__c fi = [SELECT Id FROM Field_Investigation__c LIMIT 1];
        Case cs = [SELECT Id FROM Case Limit 1];
        
        TeleVerification__c tele = new TeleVerification__c();
        tele.Loan_Application__c = lon.id;
        tele.Applicant__c = app.id;
        tele.Field_Investigation__c = fi.id;
        tele.Case__c = cs.id;
        tele.TVR_Status__c = 'Positive';
        tele.RecordTypeId = TVFFIRecordTypeId;
        insert tele;
        
        Test.startTest();
        lWC_LOS_TF_TVRController.getCurrentResidenceAddress(tele.id);
        Test.stopTest();
    } 
    
    @isTest public static void testResidenceAddress(){
        Id TVFFIRecordTypeId = Schema.SObjectType.TeleVerification__c.getRecordTypeInfosByName().get('Pre-Sanction').getRecordTypeId();
        Applicant__c app = [SELECT Id FROM Applicant__c LIMIT 1];
        Opportunity lon = [SELECT Id FROM Opportunity LIMIT 1];
        Field_Investigation__c fi = [SELECT Id FROM Field_Investigation__c LIMIT 1];
        Case cs = [SELECT Id FROM Case Limit 1];
        
        TeleVerification__c tele = new TeleVerification__c();
        tele.Loan_Application__c = lon.id;
        tele.Applicant__c = app.id;
        tele.Field_Investigation__c = fi.id;
        tele.Case__c = cs.id;
        tele.TVR_Status__c = 'Positive';
        tele.RecordTypeId = TVFFIRecordTypeId;
        insert tele;
        
        Test.startTest();
        lWC_LOS_TF_TVRController.getResidenceAddress(tele.id,'current');
        lWC_LOS_TF_TVRController.getResidenceAddress(tele.id,'permanent');
        Test.stopTest();
    } 
    
    
    @isTest public static void testsaveTVR(){
        Id TVFFIRecordTypeId = Schema.SObjectType.TeleVerification__c.getRecordTypeInfosByName().get('Pre-Sanction').getRecordTypeId();
        lWC_LOS_TF_TVRController.TVRList wrap1 = new lWC_LOS_TF_TVRController.TVRList();
        wrap1.name = 'Contact_number';
        wrap1.value = 'Pending';
        lWC_LOS_TF_TVRController.TVRList wrap2 = new lWC_LOS_TF_TVRController.TVRList();
        wrap2.name = 'Name';
        wrap2.value = 'Pending';
        lWC_LOS_TF_TVRController.TVRList wrap3 = new lWC_LOS_TF_TVRController.TVRList();
        wrap3.name = 'Loan_amount';
        wrap3.value = 'Pending';
        lWC_LOS_TF_TVRController.TVRList wrap4 = new lWC_LOS_TF_TVRController.TVRList();
        wrap4.name = 'Required_Tenure';
        wrap4.value = 'Pending';
        lWC_LOS_TF_TVRController.TVRList wrap5 = new lWC_LOS_TF_TVRController.TVRList();
        wrap5.name = 'Frequency';
        wrap5.value = 'Pending';
        lWC_LOS_TF_TVRController.TVRList wrap6 = new lWC_LOS_TF_TVRController.TVRList();
        wrap6.name = 'Coordinates_Verified';
        wrap6.value = 'Pending';
        lWC_LOS_TF_TVRController.TVRList wrap7 = new lWC_LOS_TF_TVRController.TVRList();
        wrap7.name = 'viability_of_proposed_TractorHarvester';
        wrap7.value = 'Pending';
        lWC_LOS_TF_TVRController.TVRList wrap8 = new lWC_LOS_TF_TVRController.TVRList();
        wrap8.name = 'Asset_Details';
        wrap8.value = 'Pending';
        lWC_LOS_TF_TVRController.TVRList wrap9 = new lWC_LOS_TF_TVRController.TVRList();
        wrap9.name = 'Invoice_Amount_incl_discount';
        wrap9.value = 'Pending';
        lWC_LOS_TF_TVRController.TVRList wrap10 = new lWC_LOS_TF_TVRController.TVRList();
        wrap10.name = 'Margin_Money_Paid_by';
        wrap10.value = 'Pending';
        lWC_LOS_TF_TVRController.TVRList wrap11 = new lWC_LOS_TF_TVRController.TVRList();
        wrap11.name = 'TVR_Observation';
        wrap11.value = 'Pending';
        lWC_LOS_TF_TVRController.TVRList wrap12 = new lWC_LOS_TF_TVRController.TVRList();
        wrap12.name = 'TVR_Status';
        wrap12.value = 'Positive';
        lWC_LOS_TF_TVRController.TVRList wrap13 = new lWC_LOS_TF_TVRController.TVRList();
        wrap13.name = 'applicant_number';
        wrap13.value = 'Verified';
        lWC_LOS_TF_TVRController.TVRList wrap14 = new lWC_LOS_TF_TVRController.TVRList();
        wrap14.name = 'CoApplicant_Details';
        wrap14.value = 'Verified';
        lWC_LOS_TF_TVRController.TVRList wrap15 = new lWC_LOS_TF_TVRController.TVRList();
        wrap15.name = 'Current_Address';
        wrap15.value = 'Verified';
        lWC_LOS_TF_TVRController.TVRList wrap16 = new lWC_LOS_TF_TVRController.TVRList();
        wrap16.name = 'permanent_Address';
        wrap16.value = 'Verified';
        lWC_LOS_TF_TVRController.TVRList wrap17 = new lWC_LOS_TF_TVRController.TVRList();
        wrap17.name = 'Margin_Money_Paid';
        wrap17.value = 'True';
        List<lWC_LOS_TF_TVRController.TVRList> lst = new List<lWC_LOS_TF_TVRController.TVRList>();
        lst.add(wrap1);
        lst.add(wrap2);
        lst.add(wrap3);
        lst.add(wrap4);
        lst.add(wrap5);
        lst.add(wrap6);
        lst.add(wrap7);
        lst.add(wrap8);
        lst.add(wrap9);
        lst.add(wrap10);
        lst.add(wrap11);
        lst.add(wrap12);
        lst.add(wrap13);
        lst.add(wrap14);
        lst.add(wrap15);
        lst.add(wrap16);
        lst.add(wrap17);
        Applicant__c app = [SELECT Id FROM Applicant__c LIMIT 1];
        Opportunity lon = [SELECT Id FROM Opportunity LIMIT 1];
        Field_Investigation__c fi = [SELECT Id FROM Field_Investigation__c LIMIT 1];
        Case cs = [SELECT Id FROM Case Limit 1];
        TeleVerification__c tele = new TeleVerification__c();
        tele.Loan_Application__c = lon.id;
        tele.Applicant__c = app.id;
        tele.Field_Investigation__c = fi.id;
        tele.Case__c = cs.id;
        tele.TVR_Status__c = 'Positive';
        tele.RecordTypeId = TVFFIRecordTypeId;
        insert tele;
        
        Test.startTest();
        lWC_LOS_TF_TVRController.saveTVR(lst,tele.id);
        Test.stopTest();
    }
    
}