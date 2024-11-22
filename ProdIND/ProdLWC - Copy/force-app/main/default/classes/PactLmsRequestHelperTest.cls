@isTest
public class PactLmsRequestHelperTest { 
     @isTest
    public static void setBenCodemethodTest(){ 
        Opportunity opp = new Opportunity();
                opp.StageName = 'Qualification'; 
                opp.CloseDate = Date.newInstance(2021, 1, 11);
                opp.Name = 'testone';
                opp.Product_Type__c = 'Two Wheeler';
                opp.Agent_BL_code__c = 'AG-001';
                insert opp;
            
         LoanDisbursementDetails__c disbursement = new LoanDisbursementDetails__c();
            disbursement.Parent_Loan_Application__c = opp.Id;
            disbursement.Payment_Originated_From__c = 'OP';
            disbursement.Vehicle_Sold_By__c = 'Agency Dealer';
            disbursement.Vehicle_Registered_in_Name__c = 'Buyer';
            disbursement.Do_Issuance__c = 'Along_with_Payment';
            disbursement.Do_Issuance_Mode__c = 'Separate';
            disbursement.Balance_Transfer_Amount_in_Rs__c = 24000;
            disbursement.Purchase_doc_catq__c = 'Invoice';
            disbursement.Original_Purchase_value_in_Rs__c = 25000;
            disbursement.Original_purchase_date__c = Date.today();
            disbursement.Fund_End_Use__c = 'New_Vehicle_Margin_Money';
            disbursement.Beneficiary_1__c = 'Test';
            disbursement.Bank_Ben_Code__c = 'Test';
            disbursement.Beneficiary_1_Amount__c = 131252314;
            insert disbursement;
        
            Applicant__c app = new Applicant__c();
        	app.Name = 'Test';
            app.Opportunity__c = opp.Id;
            app.Contact_number__c = '9743514830';
            app.Applicant_Type__c = 'Borrower';
            insert app;
            
            Final_Term__c ftm = new Final_Term__c();
            ftm.CRM_IRR__c = 120;
            ftm.Loan_Application__c = opp.Id;
            ftm.Holiday_period__c='30';
        	ftm.Referrer_Ben_Code__c = 'Test';
        	ftm.Referrer_Name__c ='Test';
            ftm.EMI_Amount__c= 10000;
            ftm.FIwaiver_offAddress__c = 'Not Waived';
            insert ftm;
        
             Vehicle_Detail__c vhd = new Vehicle_Detail__c();
             vhd.Loan_Application__c = opp.Id;
                 vhd.Base_Price__c = 100000.00;
                 vhd.Ben_Code__c = 'BEN110085';
                 vhd.Variant__c = 'testvariant';
                 vhd.Dealer_Sub_dealer_name__c = 'T V SUNDARAM IYENGAR AND SONS PVT LTD';
                 insert vhd;
       
        //Utilities u = new Utilities();
       // PactRequestHelper pch=new PactRequestHelper();
        PactLmsRequestHelper.ObjPRBList obprbList = new PactLmsRequestHelper.ObjPRBList();
        PactLmsRequestHelper.setBenCodeBenName(obprbList, 'DSA', ftm, vhd, disbursement,'Test',app,app );
        PactLmsRequestHelper.setBenCodeBenName(obprbList, 'Borrower', ftm, vhd, disbursement,'Test',app,app );
        PactLmsRequestHelper.setBenCodeBenName(obprbList, 'Coborrower', ftm, vhd, disbursement,'Test',app,app );
        PactLmsRequestHelper.setBenCodeBenName(obprbList, 'Bank', ftm, vhd, disbursement,'Test',app,app );
        PactLmsRequestHelper.setBenCodeBenName(obprbList, 'Seller', ftm, vhd, disbursement,'Test',app,app );
        PactLmsRequestHelper.setBenCodeBenName(obprbList, 'Dealer', ftm, vhd, disbursement,'Test',app,app );
        PactLmsRequestHelper.setBenCodeBenName(obprbList, 'MDR', ftm, vhd, disbursement,'Test',app,app );
    } //OLA-107 extra Changes done in related class
    @isTest
    public static void BeneficiaryTest1(){ 
         Opportunity opp1 = new Opportunity();
                opp1.StageName = 'Qualification';
                opp1.CloseDate = Date.newInstance(2021, 1, 11);
                opp1.Name = 'testone';
                opp1.Product_Type__c = 'Two Wheeler';
                opp1.Agent_BL_code__c = 'AG-001';
                insert opp1;
        List<Opportunity> opprtunitydetail =new List<Opportunity>();
             opprtunitydetail.add(opp1);
         LoanDisbursementDetails__c disbursement = new LoanDisbursementDetails__c();
            disbursement.Parent_Loan_Application__c = opp1.Id;
            disbursement.Payment_Originated_From__c = 'OP';
            disbursement.Vehicle_Sold_By__c = 'Agency Dealer';
            disbursement.Vehicle_Registered_in_Name__c = 'Buyer';
            disbursement.Do_Issuance__c = 'Along_with_Payment';
            disbursement.Do_Issuance_Mode__c = 'Separate';
            disbursement.Balance_Transfer_Amount_in_Rs__c = 24000;
            disbursement.Purchase_doc_catq__c = 'Invoice';
            disbursement.Original_Purchase_value_in_Rs__c = 25000;
            disbursement.Original_purchase_date__c = Date.today();
            disbursement.Fund_End_Use__c = 'New_Vehicle_Margin_Money';
            disbursement.Beneficiary_1__c = 'Test';
            disbursement.Bank_Ben_Code__c = 'Test';
            disbursement.Beneficiary_1_Amount__c = 131252314;
            insert disbursement;
        List<LoanDisbursementDetails__c> disburDetails = new List<LoanDisbursementDetails__c>();
           disburDetails.add(disbursement);
        Applicant__c app1 = new Applicant__c();
        	app1.Name = 'Test';
            app1.Opportunity__c = opp1.Id;
            app1.Contact_number__c = '9743514830';
            app1.Applicant_Type__c = 'Borrower';
            insert app1;
           List<Applicant__c> applicantdetails= new List<Applicant__c>();
               applicantdetails.add(app1);
            Final_Term__c ftm1 = new Final_Term__c();
            ftm1.CRM_IRR__c = 120;
            ftm1.Loan_Application__c = opp1.Id;
            ftm1.Holiday_period__c='30';
        	ftm1.Referrer_Ben_Code__c = 'Test';
        	ftm1.Referrer_Name__c ='Test';
            ftm1.EMI_Amount__c= 10000;
            ftm1.FIwaiver_offAddress__c = 'Not Waived';
            insert ftm1;
        List<Final_Term__c> ftmdetails = new List<Final_Term__c>();
          ftmdetails.add(ftm1);
             Vehicle_Detail__c vhd1 = new Vehicle_Detail__c();
             vhd1.Loan_Application__c = opp1.Id;
                 vhd1.Base_Price__c = 100000.00;
                 vhd1.Ben_Code__c = 'BEN110085';
                 vhd1.Variant__c = 'testvariant';
                 vhd1.Dealer_Sub_dealer_name__c = 'T V SUNDARAM IYENGAR AND SONS PVT LTD';
                 insert vhd1;
         List<Vehicle_Detail__c> vehdetails=new List<Vehicle_Detail__c>();
           vehdetails.add(vhd1);
        Invoice_Details__c invoice1 = new Invoice_Details__c();
            invoice1.Loan_Application__c = opp1.Id;
            invoice1.Invoice_Amount_incl_discounts__c = 90;
            insert invoice1;
        List<Invoice_Details__c> invoicedetailsss=new List<Invoice_Details__c>();
          invoicedetailsss.add(invoice1);
            
        test.startTest();
         PactLmsRequestHelper pact=new PactLmsRequestHelper(opp1.Id,opp1,vehdetails,disburDetails,applicantdetails,ftmdetails,invoicedetailsss,app1,app1,'dealnum');
        test.stopTest();
        
    }
     @isTest
    public static void BeneficiaryTest2(){ 
        Opportunity opp2 = new Opportunity();
                opp2.StageName = 'Qualification';
                opp2.CloseDate = Date.newInstance(2021, 1, 11);
                opp2.Name = 'testone';
                opp2.Product_Type__c = 'Two Wheeler';
                opp2.Agent_BL_code__c = 'AG-001';
                insert opp2;
        List<Opportunity> opprtunitydetail =new List<Opportunity>();
             opprtunitydetail.add(opp2);
         LoanDisbursementDetails__c disbursement = new LoanDisbursementDetails__c();
            disbursement.Parent_Loan_Application__c = opp2.Id;
            disbursement.Payment_Originated_From__c = 'OP';
            disbursement.Vehicle_Sold_By__c = 'Agency Dealer';
            disbursement.Vehicle_Registered_in_Name__c = 'Buyer';
            disbursement.Do_Issuance__c = 'Along_with_Payment';
            disbursement.Do_Issuance_Mode__c = 'Separate';
            disbursement.Balance_Transfer_Amount_in_Rs__c = 24000;
            disbursement.Purchase_doc_catq__c = 'Invoice';
            disbursement.Original_Purchase_value_in_Rs__c = 25000;
            disbursement.Original_purchase_date__c = Date.today();
            disbursement.Fund_End_Use__c = 'New_Vehicle_Margin_Money';
            disbursement.Beneficiary_2__c = 'Test';
            disbursement.Bank_Ben_Code__c = 'Test';
            disbursement.Beneficiary_2_Amount__c = 131252314;
            insert disbursement;
        List<LoanDisbursementDetails__c> disburDetails = new List<LoanDisbursementDetails__c>();
           disburDetails.add(disbursement);
        Applicant__c app2 = new Applicant__c();
        	app2.Name = 'Test';
            app2.Opportunity__c = opp2.Id;
            app2.Contact_number__c = '9743514830';
            app2.Applicant_Type__c = 'Borrower';
            insert app2;
           List<Applicant__c> applicantdetails= new List<Applicant__c>();
               applicantdetails.add(app2);
            Final_Term__c ftm2 = new Final_Term__c();
            ftm2.CRM_IRR__c = 120;
            ftm2.Loan_Application__c = opp2.Id;
            ftm2.Holiday_period__c='30';
        	ftm2.Referrer_Ben_Code__c = 'Test';
        	ftm2.Referrer_Name__c ='Test';
            ftm2.EMI_Amount__c= 10000;
            ftm2.FIwaiver_offAddress__c = 'Not Waived';
            insert ftm2;
        List<Final_Term__c> ftmdetails = new List<Final_Term__c>();
          ftmdetails.add(ftm2);
             Vehicle_Detail__c vhd2 = new Vehicle_Detail__c();
             vhd2.Loan_Application__c = opp2.Id;
                 vhd2.Base_Price__c = 100000.00;
                 vhd2.Ben_Code__c = 'BEN110085';
                 vhd2.Variant__c = 'testvariant';
                 vhd2.Dealer_Sub_dealer_name__c = 'T V SUNDARAM IYENGAR AND SONS PVT LTD';
                 insert vhd2;
         List<Vehicle_Detail__c> vehdetails=new List<Vehicle_Detail__c>();
           vehdetails.add(vhd2);
        Invoice_Details__c invoice2 = new Invoice_Details__c();
            invoice2.Loan_Application__c = opp2.Id;
            invoice2.Invoice_Amount_incl_discounts__c = 90;
            insert invoice2;
        List<Invoice_Details__c> invoicedetailsss=new List<Invoice_Details__c>();
          invoicedetailsss.add(invoice2);
            
        test.startTest();
         PactLmsRequestHelper pact=new PactLmsRequestHelper(opp2.Id,opp2,vehdetails,disburDetails,applicantdetails,ftmdetails,invoicedetailsss,app2,app2,'dealnum');
        test.stopTest();
        
    }
    @isTest
    public static void BeneficiaryTest3(){ 
        Opportunity opp3 = new Opportunity();
                opp3.StageName = 'Qualification';
                opp3.CloseDate = Date.newInstance(2021, 1, 11);
                opp3.Name = 'testone';
                opp3.Product_Type__c = 'Two Wheeler';
                opp3.Agent_BL_code__c = 'AG-001';
                insert opp3;
        List<Opportunity> opprtunitydetail =new List<Opportunity>();
             opprtunitydetail.add(opp3);
         LoanDisbursementDetails__c disbursement = new LoanDisbursementDetails__c();
            disbursement.Parent_Loan_Application__c = opp3.Id;
            disbursement.Payment_Originated_From__c = 'OP';
            disbursement.Vehicle_Sold_By__c = 'Agency Dealer';
            disbursement.Vehicle_Registered_in_Name__c = 'Buyer';
            disbursement.Do_Issuance__c = 'Along_with_Payment';
            disbursement.Do_Issuance_Mode__c = 'Separate';
            disbursement.Balance_Transfer_Amount_in_Rs__c = 24000;
            disbursement.Purchase_doc_catq__c = 'Invoice';
            disbursement.Original_Purchase_value_in_Rs__c = 25000;
            disbursement.Original_purchase_date__c = Date.today();
            disbursement.Fund_End_Use__c = 'New_Vehicle_Margin_Money';
            disbursement.Beneficiary_3__c = 'Test';
            disbursement.Bank_Ben_Code__c = 'Test';
            disbursement.Beneficiary_3_Amount__c = 131252314;
            insert disbursement;
        List<LoanDisbursementDetails__c> disburDetails = new List<LoanDisbursementDetails__c>();
           disburDetails.add(disbursement);
        Applicant__c app3 = new Applicant__c();
        	app3.Name = 'Test';
            app3.Opportunity__c = opp3.Id;
            app3.Contact_number__c = '9743514830';
            app3.Applicant_Type__c = 'Borrower';
            insert app3;
           List<Applicant__c> applicantdetails= new List<Applicant__c>();
               applicantdetails.add(app3);
            Final_Term__c ftm3 = new Final_Term__c();
            ftm3.CRM_IRR__c = 120;
            ftm3.Loan_Application__c = opp3.Id;
            ftm3.Holiday_period__c='30';
        	ftm3.Referrer_Ben_Code__c = 'Test';
        	ftm3.Referrer_Name__c ='Test';
            ftm3.EMI_Amount__c= 10000;
            ftm3.FIwaiver_offAddress__c = 'Not Waived';
            insert ftm3;
        List<Final_Term__c> ftmdetails = new List<Final_Term__c>();
          ftmdetails.add(ftm3);
             Vehicle_Detail__c vhd3 = new Vehicle_Detail__c();
             vhd3.Loan_Application__c = opp3.Id;
                 vhd3.Base_Price__c = 100000.00;
                 vhd3.Ben_Code__c = 'BEN110085';
                 vhd3.Variant__c = 'testvariant';
                 vhd3.Dealer_Sub_dealer_name__c = 'T V SUNDARAM IYENGAR AND SONS PVT LTD';
                 insert vhd3;
         List<Vehicle_Detail__c> vehdetails=new List<Vehicle_Detail__c>();
           vehdetails.add(vhd3);
        Invoice_Details__c invoice3 = new Invoice_Details__c();
            invoice3.Loan_Application__c = opp3.Id;
            invoice3.Invoice_Amount_incl_discounts__c = 90;
            insert invoice3;
        List<Invoice_Details__c> invoicedetailsss=new List<Invoice_Details__c>();
          invoicedetailsss.add(invoice3);
        

        test.startTest();
         PactLmsRequestHelper pact=new PactLmsRequestHelper(opp3.Id,opp3,vehdetails,disburDetails,applicantdetails,ftmdetails,invoicedetailsss,app3,app3,'dealNumid');
        
         PactLmsRequestHelper.getMainDealerBenCode(invoicedetailsss, opp3); 
         opp3.LeadSource = 'OLA';
         PactLmsRequestHelper.getMainDealerBenCode(invoicedetailsss, opp3); 
         opp3.LeadSource = 'D2C';
         PactLmsRequestHelper.getMainDealerBenCode(invoicedetailsss, opp3); 
        
         PactLmsRequestHelper.getDealNumber(opp3, 'dealNumid', false);
        test.stopTest();
        
        
    }
}