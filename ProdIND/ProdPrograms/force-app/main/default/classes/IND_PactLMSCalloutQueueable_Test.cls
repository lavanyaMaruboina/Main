/*------------------------------------------------------------
Author:        Sushil B
Company:       Manureva Solutions
Description:   Test class for IND_PactLMSCalloutQueueable.
Inputs:        None 
Test Classes:    
History
Date            Author              Comments
-------------------------------------------------------------
1-07-2022      Sushil B       Created
------------------------------------------------------------*/
@isTest
public class IND_PactLMSCalloutQueueable_Test implements HttpCalloutMock { 
    
 public HTTPResponse respond(HTTPRequest request) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"JData":"bmvHXB5/b59ltoDPA8dwPKjM9zW1GwK5fvqA5/8G5niBMRDutmgxxKuKRdocLOppcx7lZS4q1+ywCWRX68DBE6j685Q5CUnILU/Iyr4O7C1QU/Qn5judBaLL8WzmfM9F+l4eheWPW1D9Z9Fw31JWLYLBlbaJRAhWLDptolMrNms="}');            
        res.setStatusCode(400);
        return res;
    }
    
    
    @testSetup
    public static void setupData(){
        //create user 
        Profile p = [SELECT Id FROM Profile WHERE Name='IBL Business Executive'];
        User u = new User(Alias = 'standt2', email='standarduser2@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,Maker_Id__c='12',IsActive = true,
                          timezonesidkey='america/los_angeles',username='test_userprod123Prod@indusbank.com',MobilePhone = '9089078967');
        insert u;
        System.runAs(u) 
        {
            Opportunity opp = TestDataUtility.createTestOpportunity(false);
            opp.RTO_Road_Tax_New__c = 13;
            opp.Vehicle_Type__c ='New';
            //opp.Funding_on_ORP__c = true;
            opp.Product_Type__c ='Tractor';
            if(Schema.sObjectType.Opportunity.isCreateable())
                insert opp;
            
            Deal_Number__c dl= TestDataUtility.createDealNumber(false, opp);
            if(Schema.sObjectType.Deal_Number__c.isCreateable())
                insert dl;
            
            Loan_Application_Transaction_History__c loanAppHis = new Loan_Application_Transaction_History__c(Screen__c = 'RTO, DPN, POA Documents Upload',
                                                                                                             Module__c = 'Post Sanction Checks and Documentation', Submitted_Flag__c = false,
                                                                                                             Loan_Application_ID__c = opp.Id);
            insert loanAppHis;
            
            IHM__c ihmObj = new IHM__c();
            ihmObj.Loan_Application__c = opp.Id;
            ihmObj.Total_amount_to_be_paid_by_customer_G__c = 2000;
            
            insert ihmObj;
            Applicant__c objApplicant = new Applicant__c();
            objApplicant.Opportunity__c = opp.Id;
            objApplicant.Applicant_Type__c = 'Borrower';
            objApplicant.Contact_number__c = '1234567890';
            if(Schema.sObjectType.Applicant__c.isCreateable())
                insert objApplicant;
            
            Documents__c objDocument = new Documents__c();
            objDocument.Opportunity_Relation__c = opp.Id;
            objDocument.name = 'DocName';
            objDocument.Document_Type__c = 'Insurance Policy Doc';
            objDocument.is_Active__c = true;
            objDocument.Applicant__c = objApplicant.Id;
            if(Schema.sObjectType.Documents__c.isCreateable())
                insert objDocument;
            
            Bl_Code_Details__c blCode = new Bl_Code_Details__c();
            blCode.Bl_Code__c = 'BLC';
            blCode.Name = 'Name';
            blCode.OwnerId = u.Id;
            insert blCode;
            
            TBM_DL_Master__c tbmdm = new TBM_DL_Master__c();
            tbmdm.DL_Code__c = 'DL';
            tbmdm.Executive_Name__c = 'Exe';
            tbmdm.Product__c = 'C';
            tbmdm.Status__c = 'L';
            tbmdm.BL_Code__c = blCode.Id;
            insert tbmdm;
            
            Benefi__c benficiaryMasterObj = new Benefi__c();
            benficiaryMasterObj.Ben_Code__c = 'optg2';
            benficiaryMasterObj.Beneficiary__c = 'EMP';
            benficiaryMasterObj.Name = 'Name Of Benifi';
            benficiaryMasterObj.TA__c = 'Y';               
            benficiaryMasterObj.Dealership_Nature__c = 'CP-BH';
            benficiaryMasterObj.Status_Flag__c ='L';
            benficiaryMasterObj.Email__c = 'test@tets.com';
            insert benficiaryMasterObj;
            
            LoanDisbursementDetails__c disbursement = new LoanDisbursementDetails__c();
            disbursement.Parent_Loan_Application__c = opp.Id;
            disbursement.Payment_Originated_From__c = 'OP';
            disbursement.Vehicle_Sold_By__c = 'Agency Dealer';
            disbursement.Vehicle_Registered_in_Name__c = 'Buyer';
            disbursement.Business_Sourced_By__c = u.Id;
            disbursement.Business_Done_By__c = u.Id;
            disbursement.FI_Done_By__c = u.Id;
            disbursement.Collection_Executive__c = tbmdm.Id;
            disbursement.Do_Issuance__c = 'Along_with_Payment';
            disbursement.Do_Issuance_Mode__c = 'Separate';
            disbursement.Do_To_be_authorized_by__c = benficiaryMasterObj.Id;
            disbursement.Balance_Transfer_Amount_in_Rs__c = 24000;
            disbursement.Purchase_doc_catq__c = 'Invoice';
            disbursement.Original_Purchase_value_in_Rs__c = 25000;
            disbursement.Original_purchase_date__c = Date.today();
            disbursement.Fund_End_Use__c = 'New_Vehicle_Margin_Money';
            disbursement.FirstYr_Own_Damage_Premium__c = 12;
            disbursement.SecondYr_Own_Damage_Premium__c = 13;
            disbursement.ThirdYr_Own_Damage_Premium__c = 14;
            disbursement.FourthYr_Own_Damage_Premium__c = 15;
            disbursement.FifthYr_Own_Damage_Premium__c = 16;
            disbursement.FirstYr_Third_Party_Premium__c = 12;
            disbursement.SecondYr_Third_Party_Premium__c = 13;
            disbursement.ThirdYr_Third_Party_Premium__c = 14;
            disbursement.FourthYr_Third_Party_Premium__c = 15;
            disbursement.FifthYr_Third_Party_Premium__c = 16;
            if(Schema.sObjectType.LoanDisbursementDetails__c.isCreateable())
                insert disbursement;
            
            Invoice_Details__c invoiceDetails = new Invoice_Details__c();
            invoiceDetails.Loan_Application__c = opp.Id;
            invoiceDetails.Invoice_Amount_incl_discounts__c = 90;
            insert invoiceDetails;
            
            Final_Term__c fgd3 = new Final_Term__c();
            fgd3.CRM_IRR__c = 120;
            fgd3.Loan_Application__c = opp.Id;
            fgd3.Holiday_period__c='30';
            fgd3.EMI_Amount__c= 10000;
            fgd3.Loan_Amount__c = '1500';
            fgd3.FIwaiver_offAddress__c = 'Not Waived';
            fgd3.Tenure__c = '15';
            fgd3.Service_charges__c = '20';
            fgd3.Due_date_shift_charges__c = '22';
            fgd3.Documentation_charges__c = '25';
            fgd3.Verification_charges__c = '30';
            fgd3.Trade_certificate__c='35';
            insert fgd3;
            
            InsuranceDetails__c insuDetail = new InsuranceDetails__c();
            insuDetail.Applicant__c = objApplicant.id;
            insuDetail.Funded_Premium__c=400.00;
            insuDetail.Loan_Application__c = opp.id;
            insuDetail.Funded_Non_funded__c = 'Funded';
            insuDetail.Name = 'MOTOR';
            insuDetail.Amount__c = 1000;
            insert insuDetail;
            
            InsuranceMaster__c inMstr = new InsuranceMaster__c();
            inMstr.Name ='Cholamandalam MS General Insurance Company Ltd.';
            inMstr.Insurance_Company_Code__c = '45';
            insert inMstr;
            
            Insurance_Premium_details__c inprDetails = new Insurance_Premium_details__c();
            inprDetails.Ins_Product__c = 'GPA';
            inprDetails.Insurance_Plan_Code__c = 'GAP_1Y';
            inprDetails.Premium__c=78600.88;   
            inprDetails.Disable_Funding__c = 'Funded';
            inprDetails.Sum_Insured__c = 767.98;
            inprDetails.Period__c =12;
            inprDetails.External_id__c = '29';
            inprDetails.Insurance_Master__c = inMstr.Id;
            insert inprDetails;
            
            //Create Structered_EMI__c records
            List<Structered_EMI__c> semiList = new List<Structered_EMI__c>();
            Structered_EMI__c semi = new Structered_EMI__c();
            semi.From_Month__c = 1;
            semi.To_Month__c = 9;
            semi.EMI_Amount__c = 45000;
            semi.Number_of_Installments__c = 9;
            semi.Loan_Application__c = opp.Id;
            semiList.add(semi);
            Structered_EMI__c semi2 = new Structered_EMI__c();
            semi2.From_Month__c = 5;
            semi2.To_Month__c = 9;
            semi2.EMI_Amount__c = 50000;
            semi2.Number_of_Installments__c = 4;
            semi2.Loan_Application__c = opp.Id;
            semiList.add(semi2);
            insert semiList;
        }
    }
    //OLA Changes done in related class
    //OLA-170 Changes done here
    @isTest
    public static void doPactLmsCallout_Test(){
        Test.startTest();
        try{
            String loanAppId = [Select Id From Opportunity LIMIT 1].Id;
            
            Vehicle_Detail__c vehicleDetail = new Vehicle_Detail__c(Dealer_Sub_dealer_name__c = 'abc',
                                                                    Loan_Application__c = loanAppId,
                                                                    Executive_Contact_Number__c='8989898989', 
                                                                    Executive_name__c='ABC',
                                                                    Product__c = '',
                                                                    Insurance_expiring_within_60_days__c=true,
                                                                    City__c='Aadityana',
                                                                    Manufacturer_Year_Month__c = '2019-09',
                                                                    Variant_Code__c = 'SWIFTVDI6',
                                                                    Eligible_Tenure__c = 30,                                                               
                                                                    Eligible_Loan_Amount__c = 500000);
            insert vehicleDetail;
            
            String dealId=[Select Id From Deal_Number__c Limit 1 ].Id;
            
            Test.setMock(HttpCalloutMock.class, new PactLmsCalloutTestMock());
            Id pactLmsJobId = System.enqueueJob(new IND_PactLMSCalloutQueueable(loanAppId,dealId));
            Test.stopTest();
            Opportunity loanAppRec = [Select Id, Payment_Request_Generation_Date__c From Opportunity Where Id =:loanAppId LIMIT 1];
            System.assertNotEquals(null, pactLmsJobId);
            
        }catch(Exception e){
            System.debug('Exception ' + e.getMessage());
        }
        
    }
    
    @isTest
    public static void doPactLmsCallout_Negative(){
        try{
            Test.startTest();
            String loanAppId = [Select Id From Opportunity LIMIT 1].Id;
            Vehicle_Detail__c vehicleDetail = new Vehicle_Detail__c(Dealer_Sub_dealer_name__c = 'abc',
                                                                    Loan_Application__c = loanAppId,
                                                                    Executive_Contact_Number__c='8989898989', 
                                                                    Executive_name__c='ABC',
                                                                    Product__c = '',
                                                                    Insurance_expiring_within_60_days__c=true,
                                                                    City__c='Aadityana',
                                                                    Manufacturer_Year_Month__c = '2019-09',
                                                                    Variant_Code__c = 'SWIFTVDI6',
                                                                    Eligible_Tenure__c = 30,                                                               
                                                                    Eligible_Loan_Amount__c = 500000);
            insert vehicleDetail;
            
            String dealId=[Select Id From Deal_Number__c Limit 1 ].Id;
            
            Test.setMock(HttpCalloutMock.class, new PactLmsCalloutFailureTestMock());
            Id pactLmsJobId = System.enqueueJob(new IND_PactLMSCalloutQueueable(loanAppId,dealId));
            Test.stopTest();
            Opportunity loanAppRec = [Select Id, Payment_Request_Generation_Date__c From Opportunity Where Id =:loanAppId LIMIT 1];
            System.assertNotEquals(null, pactLmsJobId);
            System.assertNotEquals(system.now(), loanAppRec.Payment_Request_Generation_Date__c);
                        
            System.enqueueJob(new IND_PactLMSCalloutQueueable(loanAppId,dealId));
            
        } catch(Exception ex){
            System.assertNotEquals(null, ex.getMessage());
        }
    }
    //OLA-124 Changes Done
    
    @isTest
    public static void doPactLmsCallout_Negative2(){
        User u = [SELECT Id,usertype FROM User WHERE username='test_userprod123Prod@indusbank.com' AND IsActive = true LIMIT 1]; 
        System.runAs(u) 
        {	
            try{
                Test.startTest();
                IND_PactLmsService.getPactLmsCallOutRequest('iuweiusdfg','dfsdf');
                Test.stopTest();
            } catch(Exception ex){
                System.assert(ex.getMessage().contains('List has no rows for assignment to SObject'));
            }
        }
    }
    
    
    
    @isTest
    public static void getPactLmsCallOutRequestTest(){
        try{
            
            //  Opportunity opp = new Opportunity(StageName = 'Qualification',CloseDate = Date.newInstance(2021, 1, 11),Name = 'testone', Deal_Number__c = 'TUT06226H', Vehicle_Type__c = 'New',Product_Type__c ='Tractor');
            // insert opp;
            Test.setMock(HttpCalloutMock.class, new PactLmsCalloutTestMock());
            
            Opportunity opp= [Select Id, Name, StageName, CloseDate,leadsource, Deal_Number__c, vehicle_Type__c,Product_type__c from Opportunity limit 1];
            opp.Product_Type__c='Passenger Vehicles';
            update opp;
            
            
            Applicant__c app = new Applicant__c(Opportunity__c = opp.Id, Applicant_Type__c = 'Co-borrower');
            insert app;
            
            Deal_Number__c dealRec=[Select Id, Loan_Application__c,Sub_Stage__c, DNField1__c,DNField2__c From Deal_Number__c Limit 1 ];
            
            LoanDisbursementDetails__c loanDisRec = new LoanDisbursementDetails__c(Parent_Loan_Application__c = opp.Id, 
                                                                                   Payment_to_co_borrower__c = true, 
                                                                                   FirstYr_Own_Damage_Premium__c = 457354,
                                                                                   SecondYr_Own_Damage_Premium__c = 557354,
                                                                                   ThirdYr_Own_Damage_Premium__c = 986546,
                                                                                   FourthYr_Own_Damage_Premium__c = 232449,
                                                                                   FifthYr_Own_Damage_Premium__c = 643575,
                                                                                   FirstYr_Third_Party_Premium__c = 3256671,
                                                                                   SecondYr_Third_Party_Premium__c = 246576,
                                                                                   ThirdYr_Third_Party_Premium__c = 316516,
                                                                                   FourthYr_Third_Party_Premium__c = 434164,
                                                                                   FifthYr_Third_Party_Premium__c = 663642,
                                                                                   Adjustment_Deal_Number1__c = '5275',
                                                                                   Adjustment_Amount1__c = 63457, 
                                                                                   Adjustment_Deal_Number2__c = '57572',
                                                                                   Adjustment_Amount2__c = 56633,
                                                                                   Adjustment_Deal_Number3__c = '45757',
                                                                                   Adjustment_Amount3__c = 67575,
                                                                                   Adjustment_Deal_Number4__c = '57573',
                                                                                   Adjustment_Amount4__c = 74573,
                                                                                   Adjustment_Deal_Number5__c = '75375',
                                                                                   Adjustment_Amount5__c = 74672,
                                                                                   Adjustment_Deal_Number6__c = '58746',
                                                                                   Adjustment_Amount6__c = 46572,
                                                                                   Adjustment_Deal_Number7__c = '75735',
                                                                                   Adjustment_Amount7__c = 66768,
                                                                                   Adjustment_Deal_Number8__c = '54757',
                                                                                   Adjustment_Amount8__c = 54673,
                                                                                   Deal_Number__c = dealRec.Id);
            insert loanDisRec;
            
            Deal_Number_Setting__c dlNumberSetting= new Deal_Number_Setting__c(Name = System.Label.Tractor, MDNField1__c = 'AB', MDNField2__c = 2);
            insert dlNumberSetting;
            
            
            // Deal_Number__c dealRec = new Deal_Number__c(Loan_Application__c = opp.Id, Sub_Stage__c = 'test', DNField1__c = dlNumberSetting.MDNField1__c, DNField2__c = String.valueOf(dlNumberSetting.MDNField2__c));
            //  insert dealRec;
            
            
            Vehicle_Detail__c vehicleDetail = new Vehicle_Detail__c(Dealer_Sub_dealer_name__c = 'abc',
                                                                    Loan_Application__c = opp.Id,
                                                                    Deal_Number__c =  dealRec.Id,         
                                                                    Executive_Contact_Number__c='8989898989', 
                                                                    Executive_name__c='ABC',
                                                                    Product__c = '',
                                                                    Insurance_expiring_within_60_days__c=true,
                                                                    City__c='Aadityana',
                                                                    Manufacturer_Year_Month__c = '2019-09',
                                                                    Variant_Code__c = 'SWIFTVDI6',
                                                                    Eligible_Tenure__c = 30,                                                               
                                                                    Eligible_Loan_Amount__c = 500000);
            insert vehicleDetail;
            
            Final_Term__c finalTerm = new Final_Term__c(Vehicle_Detail__c=vehicleDetail.Id, Loan_Amount__c = '1000000', 
                                                        Tenure__c = '60', Net_IRR__c = 7, EMI_Amount__c = 10000, 
                                                        Holiday_period__c = '30', Installment_Type__c = 'Structured',
                                                        Service_charges__c = '3266', Due_date_shift_charges__c = '6536',
                                                        Documentation_charges__c = '3466', Verification_charges__c = '6733',
                                                        Trade_certificate__c = '6372', Loan_Application__c = opp.Id);
            insert finalTerm;
            
            IHM__c ihmRec = new IHM__c(Loan_Application__c = opp.Id, Deal_Number__c = dealRec.Id, 
                                       Total_amount_to_be_paid_by_customer_G__c = 78799, 
                                       Margin_money_to_be_deducted_from_disburs__c = 6478,
                                       SA_account_opening_charges__c = 1000);
            insert ihmRec;
            
            Loan_Agreement__c loanAgrRec = new Loan_Agreement__c(Loan_Application__c = opp.Id, Deal_Number__c = dealRec.Id,
                                                                 Agreement_Booklet_Num__c = '3562');
            insert loanAgrRec;
            
            
            
            Documents__c doc1 = TestDataUtility.createTestDocumentITR(false, app, opp);
            doc1.Vehicle_Detail__c = vehicleDetail.Id;
            doc1.Opportunity_Relation__c = opp.Id;
            doc1.Is_Document_Eligible__c='No';
            doc1.Is_active__c = true;
            doc1.Document_Type__c = 'Chassis Number uploaded during verification';
            doc1.Additional_Document__c = true;
            insert doc1;                
            
            ContentVersion contentVersion = new ContentVersion(
                Title          = 'testfname',
                PathOnClient   = 'Pic.jpg',
                VersionData    = Blob.valueOf('Test Content'),
                IsMajorVersion = true);
            insert contentVersion; 
            
            
            
            List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
            
            //create ContentDocumentLink  record
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.LinkedEntityId = doc1.Id;
            cdl.ContentDocumentId = documents[0].Id;
            cdl.ShareType = 'V';
            cdl.Visibility = 'AllUsers';
            insert cdl;
            
            Loan_Application_Transaction_History__c loanAppHis = new Loan_Application_Transaction_History__c(Name = System.Label.IHM,
                                                                                                             Deal_Number__c = dealRec.Id,
                                                                                                             Screen__c = 'RTO, DPN, POA Documents Upload',
                                                                                                             Module__c = System.Label.Post_Sanction_Checks_and_Documentation,
                                                                                                             Submitted_Flag__c = true,
                                                                                                             Loan_Application_ID__c = opp.Id);
            insert loanAppHis;
            
            //   IND_PactLmsService.getPactLmsCallOutRequest(opp.Id,dealRec.ID);
            
            Test.startTest();  
            System.enqueueJob(new IND_PactLMSCalloutQueueable(opp.Id,dealRec.ID));
            Test.stopTest();
                       
            
        }catch(Exception e){
            System.debug('Exception is -> '+e.getMessage());
            
        }
    }
    
    @isTest
    public static void getPactLmsCallOutRequestTest12(){
        try{
            
            //  Opportunity opp = new Opportunity(StageName = 'Qualification',CloseDate = Date.newInstance(2021, 1, 11),Name = 'testone', Deal_Number__c = 'TUT06226H', Vehicle_Type__c = 'New',Product_Type__c ='Tractor');
            // insert opp;
            Test.setMock(HttpCalloutMock.class, new PactLmsCalloutTestMock());
            
            Opportunity opp= [Select Id, Name, StageName, CloseDate, Deal_Number__c, vehicle_Type__c,Product_type__c from Opportunity limit 1];
            opp.Product_Type__c='Tractor';
            update opp;
            
            
            Applicant__c app = new Applicant__c(Opportunity__c = opp.Id, Applicant_Type__c = 'Co-borrower');
            insert app;
            
            LoanDisbursementDetails__c loanDisRec = new LoanDisbursementDetails__c(Parent_Loan_Application__c = opp.Id, 
                                                                                   Payment_to_co_borrower__c = true, 
                                                                                   FirstYr_Own_Damage_Premium__c = 457354,
                                                                                   SecondYr_Own_Damage_Premium__c = 557354,
                                                                                   ThirdYr_Own_Damage_Premium__c = 986546,
                                                                                   FourthYr_Own_Damage_Premium__c = 232449,
                                                                                   FifthYr_Own_Damage_Premium__c = 643575,
                                                                                   FirstYr_Third_Party_Premium__c = 3256671,
                                                                                   SecondYr_Third_Party_Premium__c = 246576,
                                                                                   ThirdYr_Third_Party_Premium__c = 316516,
                                                                                   FourthYr_Third_Party_Premium__c = 434164,
                                                                                   FifthYr_Third_Party_Premium__c = 663642,
                                                                                   Adjustment_Deal_Number1__c = '5275',
                                                                                   Adjustment_Amount1__c = 63457, 
                                                                                   Adjustment_Deal_Number2__c = '57572',
                                                                                   Adjustment_Amount2__c = 56633,
                                                                                   Adjustment_Deal_Number3__c = '45757',
                                                                                   Adjustment_Amount3__c = 67575,
                                                                                   Adjustment_Deal_Number4__c = '57573',
                                                                                   Adjustment_Amount4__c = 74573,
                                                                                   Adjustment_Deal_Number5__c = '75375',
                                                                                   Adjustment_Amount5__c = 74672,
                                                                                   Adjustment_Deal_Number6__c = '58746',
                                                                                   Adjustment_Amount6__c = 46572,
                                                                                   Adjustment_Deal_Number7__c = '75735',
                                                                                   Adjustment_Amount7__c = 66768,
                                                                                   Adjustment_Deal_Number8__c = '54757',
                                                                                   Adjustment_Amount8__c = 54673);
            insert loanDisRec;
            
            Deal_Number_Setting__c dlNumberSetting= new Deal_Number_Setting__c(Name = System.Label.Tractor, MDNField1__c = 'AB', MDNField2__c = 2);
            insert dlNumberSetting;
            
            
            // Deal_Number__c dealRec = new Deal_Number__c(Loan_Application__c = opp.Id, Sub_Stage__c = 'test', DNField1__c = dlNumberSetting.MDNField1__c, DNField2__c = String.valueOf(dlNumberSetting.MDNField2__c));
            //  insert dealRec;
            Deal_Number__c dealRec=[Select Id, Loan_Application__c,Sub_Stage__c, DNField1__c,DNField2__c From Deal_Number__c Limit 1 ];
            
            Vehicle_Detail__c vehicleDetail = new Vehicle_Detail__c(Dealer_Sub_dealer_name__c = 'abc',
                                                                    Loan_Application__c = opp.Id,
                                                                    Deal_Number__c =  dealRec.Id,         
                                                                    Executive_Contact_Number__c='8989898989', 
                                                                    Executive_name__c='ABC',
                                                                    Product__c = '',
                                                                    Insurance_expiring_within_60_days__c=true,
                                                                    City__c='Aadityana',
                                                                    Manufacturer_Year_Month__c = '2019-09',
                                                                    Variant_Code__c = 'SWIFTVDI6',
                                                                    Eligible_Tenure__c = 30,                                                               
                                                                    Eligible_Loan_Amount__c = 500000);
            insert vehicleDetail;
            
            Final_Term__c finalTerm = new Final_Term__c(Vehicle_Detail__c=vehicleDetail.Id, Loan_Amount__c = '1000000', 
                                                        Tenure__c = '60', Net_IRR__c = 7, EMI_Amount__c = 10000, 
                                                        Holiday_period__c = '30', Installment_Type__c = 'Structured',
                                                        Service_charges__c = '3266', Due_date_shift_charges__c = '6536',
                                                        Documentation_charges__c = '3466', Verification_charges__c = '6733',
                                                        Trade_certificate__c = '6372', Loan_Application__c = opp.Id);
            insert finalTerm;
            
            IHM__c ihmRec = new IHM__c(Loan_Application__c = opp.Id, Deal_Number__c = dealRec.Id, 
                                       Total_amount_to_be_paid_by_customer_G__c = 78799, 
                                       Margin_money_to_be_deducted_from_disburs__c = 6478,
                                       SA_account_opening_charges__c = 1000);
            insert ihmRec;
            
            Loan_Agreement__c loanAgrRec = new Loan_Agreement__c(Loan_Application__c = opp.Id, Deal_Number__c = dealRec.Id,
                                                                 Agreement_Booklet_Num__c = '3562');
            insert loanAgrRec;
            
            
            
            Documents__c doc1 = TestDataUtility.createTestDocumentITR(false, app, opp);
            doc1.Vehicle_Detail__c = vehicleDetail.Id;
            doc1.Opportunity_Relation__c = opp.Id;
            doc1.Is_Document_Eligible__c='No';
            doc1.Is_active__c = true;
            doc1.Document_Type__c = 'Chassis Number uploaded during verification';
            doc1.Additional_Document__c = true;
            insert doc1;                
            
            ContentVersion contentVersion = new ContentVersion(
                Title          = 'testfname',
                PathOnClient   = 'Pic.jpg',
                VersionData    = Blob.valueOf('Test Content'),
                IsMajorVersion = true);
            insert contentVersion; 
            
            
            
            List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
            
            //create ContentDocumentLink  record
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.LinkedEntityId = doc1.Id;
            cdl.ContentDocumentId = documents[0].Id;
            cdl.ShareType = 'V';
            cdl.Visibility = 'AllUsers';
            insert cdl;
            
            Loan_Application_Transaction_History__c loanAppHis = new Loan_Application_Transaction_History__c(Name = System.Label.IHM,
                                                                                                             Deal_Number__c = dealRec.Id,
                                                                                                             Screen__c = 'RTO, DPN, POA Documents Upload',
                                                                                                             Module__c = System.Label.Post_Sanction_Checks_and_Documentation,
                                                                                                             Submitted_Flag__c = true,
                                                                                                             Loan_Application_ID__c = opp.Id);
            insert loanAppHis;
            
            //   IND_PactLmsService.getPactLmsCallOutRequest(opp.Id,dealRec.ID);
            Test.startTest();  
            System.enqueueJob(new IND_PactLMSCalloutQueueable(opp.Id,dealRec.ID));
            Test.stopTest();
            
            Test.setMock(HttpCalloutMock.class, new IND_PactLMSCalloutQueueable_Test());
            System.enqueueJob(new IND_PactLMSCalloutQueueable(opp.Id,dealRec.ID));
            
            Test.setMock(HttpCalloutMock.class, new IND_PactLMSCalloutQueueable_Test());
            System.enqueueJob(new IND_PactLMSCalloutQueueable(null,dealRec.ID));
            
        }catch(Exception e){
            System.debug('Exception is -> '+e.getMessage());
            
        }
    }
    
    @isTest
    public static void getPactLmsCallOutRequestTest13(){
        try{
            
            //  Opportunity opp = new Opportunity(StageName = 'Qualification',CloseDate = Date.newInstance(2021, 1, 11),Name = 'testone', Deal_Number__c = 'TUT06226H', Vehicle_Type__c = 'New',Product_Type__c ='Tractor');
            // insert opp;
            Test.setMock(HttpCalloutMock.class, new PactLmsCalloutFailureTestMock());
            
            Opportunity opp= [Select Id, Name, StageName, CloseDate, Deal_Number__c,LeadSource, vehicle_Type__c,Product_type__c from Opportunity limit 1];
            opp.Product_Type__c='Tractor';
            update opp;
            
            
            Applicant__c app = new Applicant__c(Opportunity__c = opp.Id, Applicant_Type__c = 'Co-borrower');
            insert app;
            
            LoanDisbursementDetails__c loanDisRec = new LoanDisbursementDetails__c(Parent_Loan_Application__c = opp.Id, 
                                                                                   Payment_to_co_borrower__c = true, 
                                                                                   FirstYr_Own_Damage_Premium__c = 457354,
                                                                                   SecondYr_Own_Damage_Premium__c = 557354,
                                                                                   ThirdYr_Own_Damage_Premium__c = 986546,
                                                                                   FourthYr_Own_Damage_Premium__c = 232449,
                                                                                   FifthYr_Own_Damage_Premium__c = 643575,
                                                                                   FirstYr_Third_Party_Premium__c = 3256671,
                                                                                   SecondYr_Third_Party_Premium__c = 246576,
                                                                                   ThirdYr_Third_Party_Premium__c = 316516,
                                                                                   FourthYr_Third_Party_Premium__c = 434164,
                                                                                   FifthYr_Third_Party_Premium__c = 663642,
                                                                                   Adjustment_Deal_Number1__c = '5275',
                                                                                   Adjustment_Amount1__c = 63457, 
                                                                                   Adjustment_Deal_Number2__c = '57572',
                                                                                   Adjustment_Amount2__c = 56633,
                                                                                   Adjustment_Deal_Number3__c = '45757',
                                                                                   Adjustment_Amount3__c = 67575,
                                                                                   Adjustment_Deal_Number4__c = '57573',
                                                                                   Adjustment_Amount4__c = 74573,
                                                                                   Adjustment_Deal_Number5__c = '75375',
                                                                                   Adjustment_Amount5__c = 74672,
                                                                                   Adjustment_Deal_Number6__c = '58746',
                                                                                   Adjustment_Amount6__c = 46572,
                                                                                   Adjustment_Deal_Number7__c = '75735',
                                                                                   Adjustment_Amount7__c = 66768,
                                                                                   Adjustment_Deal_Number8__c = '54757',
                                                                                   Adjustment_Amount8__c = 54673);
            insert loanDisRec;
            
            Deal_Number_Setting__c dlNumberSetting= new Deal_Number_Setting__c(Name = System.Label.Tractor, MDNField1__c = 'AB', MDNField2__c = 2);
            insert dlNumberSetting;
            
            
            // Deal_Number__c dealRec = new Deal_Number__c(Loan_Application__c = opp.Id, Sub_Stage__c = 'test', DNField1__c = dlNumberSetting.MDNField1__c, DNField2__c = String.valueOf(dlNumberSetting.MDNField2__c));
            //  insert dealRec;
            Deal_Number__c dealRec=[Select Id, Loan_Application__c,Sub_Stage__c, DNField1__c,DNField2__c From Deal_Number__c Limit 1 ];
            
            Vehicle_Detail__c vehicleDetail = new Vehicle_Detail__c(Dealer_Sub_dealer_name__c = 'abc',
                                                                    Loan_Application__c = opp.Id,
                                                                    Deal_Number__c =  dealRec.Id,         
                                                                    Executive_Contact_Number__c='8989898989', 
                                                                    Executive_name__c='ABC',
                                                                    Product__c = '',
                                                                    Insurance_expiring_within_60_days__c=true,
                                                                    City__c='Aadityana',
                                                                    Manufacturer_Year_Month__c = '2019-09',
                                                                    Variant_Code__c = 'SWIFTVDI6',
                                                                    Eligible_Tenure__c = 30,                                                               
                                                                    Eligible_Loan_Amount__c = 500000);
            insert vehicleDetail;
            
            Final_Term__c finalTerm = new Final_Term__c(Vehicle_Detail__c=vehicleDetail.Id, Loan_Amount__c = '1000000', 
                                                        Tenure__c = '60', Net_IRR__c = 7, EMI_Amount__c = 10000, 
                                                        Holiday_period__c = '30', Installment_Type__c = 'Structured',
                                                        Service_charges__c = '3266', Due_date_shift_charges__c = '6536',
                                                        Documentation_charges__c = '3466', Verification_charges__c = '6733',
                                                        Trade_certificate__c = '6372', Loan_Application__c = opp.Id);
            insert finalTerm;
            
            IHM__c ihmRec = new IHM__c(Loan_Application__c = opp.Id, Deal_Number__c = dealRec.Id, 
                                       Total_amount_to_be_paid_by_customer_G__c = 78799, 
                                       Margin_money_to_be_deducted_from_disburs__c = 6478,
                                       SA_account_opening_charges__c = 1000);
            insert ihmRec;
            
            Loan_Agreement__c loanAgrRec = new Loan_Agreement__c(Loan_Application__c = opp.Id, Deal_Number__c = dealRec.Id,
                                                                 Agreement_Booklet_Num__c = '3562');
            insert loanAgrRec;
            
            
            
            Documents__c doc1 = TestDataUtility.createTestDocumentITR(false, app, opp);
            doc1.Vehicle_Detail__c = vehicleDetail.Id;
            doc1.Opportunity_Relation__c = opp.Id;
            doc1.Is_Document_Eligible__c='No';
            doc1.Is_active__c = true;
            doc1.Document_Type__c = 'Chassis Number uploaded during verification';
            doc1.Additional_Document__c = true;
            insert doc1;                
            
            ContentVersion contentVersion = new ContentVersion(
                Title          = 'testfname',
                PathOnClient   = 'Pic.jpg',
                VersionData    = Blob.valueOf('Test Content'),
                IsMajorVersion = true);
            insert contentVersion; 
            
            
            
            List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
            
            //create ContentDocumentLink  record
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.LinkedEntityId = doc1.Id;
            cdl.ContentDocumentId = documents[0].Id;
            cdl.ShareType = 'V';
            cdl.Visibility = 'AllUsers';
            insert cdl;
            
            Loan_Application_Transaction_History__c loanAppHis = new Loan_Application_Transaction_History__c(Name = System.Label.IHM,
                                                                                                             Deal_Number__c = dealRec.Id,
                                                                                                             Screen__c = 'RTO, DPN, POA Documents Upload',
                                                                                                             Module__c = System.Label.Post_Sanction_Checks_and_Documentation,
                                                                                                             Submitted_Flag__c = true,
                                                                                                             Loan_Application_ID__c = opp.Id);
            insert loanAppHis;
            
            //   IND_PactLmsService.getPactLmsCallOutRequest(opp.Id,dealRec.ID);
            Test.startTest();  
            System.enqueueJob(new IND_PactLMSCalloutQueueable(opp.Id,dealRec.ID));
            Test.stopTest();
            
            Test.setMock(HttpCalloutMock.class, new IND_PactLMSCalloutQueueable_Test());
            System.enqueueJob(new IND_PactLMSCalloutQueueable(opp.Id,dealRec.ID));  
            
        }catch(Exception e){
            System.debug('Exception is -> '+e.getMessage());
            
        }
    }
}