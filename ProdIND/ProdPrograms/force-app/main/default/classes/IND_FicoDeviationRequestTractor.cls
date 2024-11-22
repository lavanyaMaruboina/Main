/*------------------------------------------------------------
Author:        Gaurav Rawat
Company: 
Description:   This class is wrapper class for the FicoDeviationRequest API request
Apex Class : IND_FicoDeviationRequestTractor for API FicoDeviationRequest
Test Class:    
History
Date            Author              Comments
-------------------------------------------------------------
12-28-2021      Gaurav Rawat             Created
------------------------------------------------------------*/
public class IND_FicoDeviationRequestTractor extends ParentAPIRequest {
    
    public final String Proposal_Based_On {get;set;}
    public final String Product {get;set;}
    public final String VehicleType {get;set;}
    public final String Maker_Id {get;set;}
    public final String LTV {get;set;}
    public final String CRM_IRR {get;set;}
    public final String Tenure {get;set;}
    public final String LoanAmount {get;set;}
    public  String ORP {get;set;}
    public final String ValuationPrice {get;set;}
    public final String IDVPrice {get;set;}
    public final String No_Of_Ownership {get;set;}
    public final String Month_Of_Manufacture {get;set;}
    public final String Year_Of_Manufacture {get;set;}
    public final String Total_Exposure {get;set;}
    public final String AgeOfVehicleLoanMaturity {get;set;}
    public final String lienFlag {get;set;}
    public String Threshold_Net_IRR {get;set;}
    public final String Bl_Code {get;set;}
    public final String SubProduct {get;set;}
    public final String Type_Of_Dealer {get;set;}
    public final String Banking_Exposure {get;set;}
    public final String Engine_Irr_Offered {get;set;}
    public final String Moratorium_Days {get;set;}
    public  String LTV_Based_On {get;set;}
    public  String basicPrice {get;set;}
    public  String discount {get;set;}
    public  String documentCharge {get;set;}
    public  String roadTax {get;set;}
    public  String serviceCharge {get;set;}
    public  String firstYearInsurancePremium {get;set;}
    public  String otherCharges {get;set;}
    public  String gstAmount {get;set;}
    public  String Advance_EMI_Flag {get;set;}
    public  String Ex_Showroom_Price {get;set;}
    public  String OfferEMI {get;set;}
    public String Channel { get; set; }
    public String invoiceAmount { get; set; }
    public String dSABenficiaryCode { get; set; }
    public String dealerBenficiaryCode { get; set; }
    public String totalPayouts { get; set; }

    public List<ApplicationDetails> ApplicationDetails {get;set;}
    public List<AssetLoanDetails> assetLoanDetails {get;set;}

    
    public class ApplicationDetails {
        public final String ApplicantType {get;set;}
        public final String Lead_Id {get;set;}
        public final String ApplicationId {get;set;}
        public final String CustomerCode {get;set;}
        public final String MobileNumber {get;set;}
        public final String State {get;set;}
        public final String Country {get;set;}
        public final String Profile {get;set;}
        public final String SubProfile {get;set;}
        public final String MaritalStatus {get;set;}
        public final String Category {get;set;}
        public final String Gender {get;set;}
        public final String DateOfBirth {get;set;}
        public final String Is_WhatApp_Available {get;set;}
        public final String Is_Email_Available {get;set;}
        public final String RiskBand {get;set;}
        public final String PAN_CIN_Alert_Flag {get;set;}
        public final String agriLandAcres {get;set;}
        public final String landHoldingType {get;set;}
        public final String isIlliteratePerson {get;set;}
        public final String distanceFromGuarantor {get;set;}
        public final String distanceFromBE {get;set;}
        public final String typeOfBuyer {get;set;}
        public final String ExistingCustomer {get;set;}
        public final String pastRepaymentTrack {get;set;}
        public final String installmentToIncomeRatio {get;set;}

        public List<AddressDetail> AddressDetail {get;set;}

        public List<Exposure_Dealwise> Exposure_Dealwise {get;set;}
    }

    public class AssetLoanDetails{
        public String insuranceExpiryDate { get; set; }
        public String assetBasedCategory { get; set; }
        public String assetSegment { get; set; }
        public String hmr { get; set; }
        public String AssetAge { get; set; }
        public String requestedloanamount { get; set; }
        public String requestedTenure { get; set; }
        public String repaymentFrequency { get; set; }
        public String moratoriumAvailed { get; set; }
        public String financeAmtChasis { get; set; }
        public String financeAmtBody { get; set; }
        public String assetBasedScore { get; set; }
        public String riskBand { get; set; }
        public String ltv { get; set; }
        public String irr { get; set; }

        public List<InsuranceDetails> insuranceDetails {get;set;}
        public String serviceCharge { get; set; }
    }
    
    public class InsuranceDetails {
        public String insuranceType { get; set; }
        public String insurancePremium { get; set; }
    }
    public class AddressDetail {
        public String addressType { get; set; }
        public String fiDistance { get; set; }
        public String stabilityOfResidence { get; set; }
        public String residenceType { get; set; }
    }
    public class Exposure_Dealwise {
    }
    
    
    // @Method:      IND_FicoDeviationRequest
    // @Created by:  Prathik
    // @Description: Contructor to initialize the details
    // @Param:       Object applicant Record
    // @Return:      ''
    public IND_FicoDeviationRequestTractor(String loanAppId, Opportunity opty){ 
        if(loanAppId == null && Test.isRunningTest()){
            throw new IND_Exception(System.label.LoanApplicationNOTNULL);
        } 
        try {
            Map<String,String> dlpMasterMap = new Map<String,String>();
            String cfdStateCode = Utilities.getCFDStateCode([SELECT Id,Agent_BL_code__c FROM Opportunity WHERE Id =: loanAppId LIMIT 1].Agent_BL_code__c, 'T');
            if(String.isNotBlank(cfdStateCode)){
                List<Vehicle_Detail__c> vehicleList = [SELECT Variant_Code__c FROM Vehicle_Detail__c WHERE Loan_Application__c  =: opty.Id LIMIT 10];
                Set<String> variantSet = new  Set<String>();
                for (Vehicle_Detail__c vehicleObj : vehicleList) {
                    variantSet.add(vehicleObj.Variant_Code__c);
                }
                if(variantSet.size() > 0){
                    for (TBM_Product_Variant_dt__c tbmProductVariant : [SELECT Id, Segment_Grade__c,Product_Variant_Code__c FROM TBM_Product_Variant_dt__c Where State_Code__c =: cfdStateCode  AND Product_Variant_Code__c IN :variantSet ]) {
                        if(!dlpMasterMap.containsKey(tbmProductVariant.Product_Variant_Code__c)){
                            dlpMasterMap.put(tbmProductVariant.Product_Variant_Code__c,tbmProductVariant.Segment_Grade__c);
                        }
                    }
                }
            }
            List<Final_Term__c> finalTermList = new List<Final_Term__c>([SELECT Id,Tenure__c,Holiday_period__c,Funding_for_Chassis__c,Funding_for_Body__c,Fi_Score_Band__c,PricingEngine_thresholdNetrr__c,Installment_To_Income_Ratio__c,Required_CRM_IRR__c,Fi_Score__c,Vehicle_Detail__r.Ins_Expiry_date__c,Vehicle_Detail__r.Vehicle_Category__c,Vehicle_Detail__r.Vehicle_SubType__c,Vehicle_Detail__r.KMS_Run__c,Vehicle_Detail__r.Manufacturer_Year_Month__c,Vehicle_Detail__c,Vehicle_Detail__r.Invoice_Price__c,Installment_Frequency__c,Vehicle_Detail__r.Variant_Code__c,Loan_Application__c,Vehicle_Detail__r.Total_Funded_Amount__c,Loan_Application__r.isTopUpLoan__c,Vehicle_Detail__r.Grid_value__c,Vehicle_Detail__r.Insurance_declared_value__c,Vehicle_Detail__r.Valuation_price__c,Loan_Application__r.Vehicle_Type__c,Is_Loan_Amount_Change_From_CAM__c,Calculated_Net_LTV__c,Loan_Amount__c,Service_Charges__c  FROM Final_Term__c WHERE Loan_Application__c = : opty.Id WITH SECURITY_ENFORCED]);

            this.Year_Of_Manufacture = '';

            this.VehicleType= opty.Vehicle_Type__c == 'New' ? 'N' : opty.Vehicle_Type__c == 'Used' ? 'U' : opty.Vehicle_Type__c == 'Refinance' ?'R' : '';

            this.ValuationPrice = '';
            this.Type_Of_Dealer = '';
            
            Decimal currentExposureAmount = 0;
            for (Final_Term__c finalObj : finalTermList) {
                if(finalObj.Loan_amount__c  != null){
                    currentExposureAmount += Decimal.valueOf(finalObj.Loan_amount__c);
                }
            }

            FicoRequestWrapper requestWrapperObj = IND_FicoDeviationRequestTractor.getRequestDetails(opty.Id,currentExposureAmount);
            if(requestWrapperObj != null){
                this.Total_Exposure = requestWrapperObj.totalExposure;
            }else{
                this.Total_Exposure = '';
            }
            
            this.Threshold_Net_IRR = '';
            this.Tenure = '';
            this.SubProduct = '';
            this.serviceCharge = '';
            this.roadTax = '';

            List<Applicant__c> proposalList = [SELECT Who_will_repay_the_loan__c FROM Applicant__c WHERE Opportunity__c =: opty.Id AND Who_will_repay_the_loan__c != null AND In_Active_Applicant__c = false WITH SECURITY_ENFORCED]; 
            this.Proposal_Based_On = proposalList.isEmpty() == true ? '' : proposalList[0].Who_will_repay_the_loan__c == 'Borrower' ? 'Borrower' : 'Co Borrower';

            this.Product = 'T';
            this.otherCharges = '';
            this.ORP = '';
            this.OfferEMI = '';
            this.No_Of_Ownership = '';
            this.Moratorium_Days = '';
            this.Month_Of_Manufacture = '';
            this.Maker_Id= IntegrationUtilities.getMakerId();
            this.LTV_Based_On = '';
            this.LTV = '';
            this.LoanAmount = '';

            if(requestWrapperObj != null){
                this.lienFlag = requestWrapperObj.lienFlag;
            }else{
                this.lienFlag = '';
            }

            this.invoiceAmount = '';
            this.IDVPrice = '';
            this.gstAmount = '';
            this.firstYearInsurancePremium = '';
            this.Ex_Showroom_Price = '';
            this.Engine_Irr_Offered = '';
            this.documentCharge = '';
            this.discount = '';
            this.CRM_IRR = '';
            this.Channel = 'TRACTOR';
            this.Bl_Code= opty.Agent_BL_code__c == null ?'' : opty.Agent_BL_code__c;
            this.basicPrice = '';

            if(requestWrapperObj != null){
                this.Banking_Exposure = requestWrapperObj.totalBankExposure;
            }else{
                this.Banking_Exposure = '';
            }

            this.dSABenficiaryCode = '';
            this.dealerBenficiaryCode = '';
            this.totalPayouts = '';
            this.AgeOfVehicleLoanMaturity = '';

            this.Advance_EMI_Flag = '';

            Map<Id,List<InsuranceDetails__c>> insMap = new Map<Id,List<InsuranceDetails__c>>();
            for (InsuranceDetails__c ins : [Select id,Vehicle_Detail__c,Name,Amount__c from InsuranceDetails__c WHERE Loan_Application__c =: opty.Id WITH SECURITY_ENFORCED LIMIT 1000]) {
                if(insMap.containsKey(ins.Vehicle_Detail__c)){
                    List<InsuranceDetails__c> insList = insMap.get(ins.Vehicle_Detail__c);
                    insList.add(ins);
                    insMap.put(ins.Vehicle_Detail__c,insList);
                }else{
                    insMap.put(ins.Vehicle_Detail__c,new List<InsuranceDetails__c>{ins});
                }
            }
            Map<Id,Asset_Verification__c>  assetMap = new Map<Id, Asset_Verification__c>();
            for (Asset_Verification__c assetVer : [SELECT Id,HMR__c,Vehicle_Detail__c FROM Asset_Verification__c where Case__r.Loan_Application__c =: loanAppId]) {
                if(!assetMap.containsKey(assetVer.Vehicle_Detail__c)){
                    assetMap.put(assetVer.Vehicle_Detail__c,assetVer);
                }
            }

            List<AssetLoanDetails> assetLoanDetailList = new List<AssetLoanDetails>();
            Map<String, Decimal> dlpVariantMap = ViewCamController.getDLPVariant(finalTermList);
            List<Exposure__c> expoList = [SELECT Id, SOH__c, Type__c FROM Exposure__c WHERE Loan_Application__c = :opty.Id AND Type__c = 'Borrower Exposure' LIMIT 1];
            for(Final_Term__c finalTermObj : finalTermList){
                Decimal minInvDlp = dlpVariantMap.containsKey(finalTermObj.Vehicle_Detail__r.Variant_Code__c) ? dlpVariantMap.get(finalTermObj.Vehicle_Detail__r.Variant_Code__c) : 0;
                ViewCamController.GrossNetLTVWrapper resultWrapperObj = ViewCamController.getGrossNetLTVTractor(finalTermObj, expoList, minInvDlp);
                AssetLoanDetails assetLoanDetail = new AssetLoanDetails();
                assetLoanDetail.insuranceExpiryDate = finalTermObj.Vehicle_Detail__r.Ins_Expiry_date__c != null ? (finalTermObj.Vehicle_Detail__r.Ins_Expiry_date__c + '').split(' ')[0] : '';
                assetLoanDetail.assetBasedCategory = dlpMasterMap.containsKey(finalTermObj.Vehicle_Detail__r.Variant_Code__c) ? dlpMasterMap.get(finalTermObj.Vehicle_Detail__r.Variant_Code__c) : '';
                assetLoanDetail.assetSegment = finalTermObj.Vehicle_Detail__r.Vehicle_SubType__c != null ? finalTermObj.Vehicle_Detail__r.Vehicle_SubType__c : '';
                if(assetMap.containsKey(finalTermObj.Vehicle_Detail__c)){
                    assetLoanDetail.hmr = assetMap.get(finalTermObj.Vehicle_Detail__c).HMR__c != null ? String.valueof((Integer)assetMap.get(finalTermObj.Vehicle_Detail__c).HMR__c) : '';
                }else{
                    assetLoanDetail.hmr = '';
                }
                
                String vehicleYear = (finalTermObj.Vehicle_Detail__c != null && finalTermObj.Vehicle_Detail__r.Manufacturer_Year_Month__c != null) ? finalTermObj.Vehicle_Detail__r.Manufacturer_Year_Month__c.substringBefore('-') : null;
                String vehicleMonth = (finalTermObj.Vehicle_Detail__c != null && finalTermObj.Vehicle_Detail__r.Manufacturer_Year_Month__c != null) ? finalTermObj.Vehicle_Detail__r.Manufacturer_Year_Month__c.substringAfter('-') : null;
                if(vehicleYear != null){
                    Decimal vehicleYearDecimal = vehicleYear != null ? System.today().Year() - Integer.valueOf(vehicleYear) : 0;
                    Decimal vehicleMonthDecimal = vehicleMonth != null ? (System.today().month() - Decimal.valueOf(vehicleMonth))/12 : 0;
                    Decimal actualVehicleAge = (vehicleYearDecimal + vehicleMonthDecimal).setScale(1);
                    assetLoanDetail.AssetAge = String.valueOf(actualVehicleAge);    
                }
                else {
                    assetLoanDetail.AssetAge = '0';
                }
                assetLoanDetail.requestedloanamount = finalTermObj.Loan_Amount__c != null ? finalTermObj.Loan_Amount__c : '';
                assetLoanDetail.requestedTenure = finalTermObj.Tenure__c != null ? finalTermObj.Tenure__c : '';
                assetLoanDetail.repaymentFrequency = String.isNotBlank(finalTermObj.Installment_Frequency__c) ? finalTermObj.Installment_Frequency__c : '';
                assetLoanDetail.moratoriumAvailed = finalTermObj.Holiday_period__c != null ? finalTermObj.Holiday_period__c : '';
                assetLoanDetail.financeAmtChasis = finalTermObj.Funding_for_Chassis__c != null ? finalTermObj.Funding_for_Chassis__c + '' : '';
                assetLoanDetail.financeAmtBody = finalTermObj.Funding_for_Body__c != null ? finalTermObj.Funding_for_Body__c + '' : '';
                assetLoanDetail.assetBasedScore = finalTermObj.Fi_Score__c != null ? finalTermObj.Fi_Score__c : '';
                assetLoanDetail.riskBand = finalTermObj.Fi_Score_Band__c != null ? finalTermObj.Fi_Score_Band__c : '';
                Integer loanAmount = (finalTermObj.Loan_Amount__c != null) ? Integer.valueof(finalTermObj.Loan_Amount__c) : 0;
                Decimal purchasePrice = (finalTermObj.Vehicle_Detail__r.Invoice_Price__c != null) ? Integer.valueof(finalTermObj.Vehicle_Detail__r.Invoice_Price__c) : 0;
                // String ltv = '';
                // if(loanAmount != 0 && purchasePrice != 0){
                //     ltv = ((loanAmount/purchasePrice)*100).setScale(2).toString();
                // }
                // assetLoanDetail.ltv = ltv;
                assetLoanDetail.irr = finalTermObj.Required_CRM_IRR__c != null ? finalTermObj.Required_CRM_IRR__c + '' : '';
                assetLoanDetail.ltv = (finalTermObj.Calculated_Net_LTV__c == null || finalTermObj.Is_Loan_Amount_Change_From_CAM__c) ? resultWrapperObj.ltvWithoutInsurance : String.valueOf(finalTermObj.Calculated_Net_LTV__c);
                List<InsuranceDetails> insuranceDetails = new List<InsuranceDetails>();
                if(insMap.containsKey(finalTermObj.Vehicle_Detail__c)){
                    for(InsuranceDetails__c ins : insMap.get(finalTermObj.Vehicle_Detail__c)){
                        InsuranceDetails insuranceDetailObj = new InsuranceDetails();
                        insuranceDetailObj.insuranceType = ins.Name == null ? '' : ins.Name;
                        insuranceDetailObj.insurancePremium = ins.Amount__c + '';
                        insuranceDetails.add(insuranceDetailObj);
                    }
                }

                assetLoanDetail.insuranceDetails = insuranceDetails;
                String serviceCharge = '';
                if(finalTermObj.Loan_Amount__c != null && finalTermObj.Service_Charges__c != null){
                    serviceCharge = (((Decimal.valueof(finalTermObj.Service_Charges__c)/Decimal.valueof(finalTermObj.Loan_Amount__c))*100).setScale(2)) + '';
                }
                assetLoanDetail.serviceCharge = serviceCharge;
                assetLoanDetailList.add(assetLoanDetail);
            }

            this.assetLoanDetails = assetLoanDetailList;

            Map<Id,Field_Investigation__c> fiMap = new Map<Id,Field_Investigation__c>();
            Field_Investigation__c guarantorFI = new Field_Investigation__c();
            Field_Investigation__c borrowerFI = new Field_Investigation__c();
            for (Field_Investigation__c fiObj : [Select id,Coordinates_Distance__c,KYC_Location__c,Distance_from_Borrower_to_Co_borrower__c,Distance_from_Branch_to_customer__c,Case__r.Applicant__c,Case__r.Applicant__r.Applicant_Type__c,Scheme_Type__c,Sub_Scheme_Type__c,Case__r.Type,(SELECT ID,Land_holding_In_acres__c FROM Loan_Holding_Details__r) from Field_Investigation__c where Case__r.Loan_Application__c =: opty.Id AND Case__r.RecordType.Name = 'FI' AND Case__r.Type = 'Current Residence FI' LIMIT 100]) {
                if(!fiMap.containsKey(fiObj.Case__r.Applicant__c)){
                    fiMap.put(fiObj.Case__r.Applicant__c,fiObj);
                }
                if(fiObj.Case__r.Applicant__r.Applicant_Type__c == System.Label.Guarantor){
                    guarantorFI = fiObj;
                }
                if(fiObj.Case__r.Applicant__r.Applicant_Type__c == System.Label.Borrower){
                    borrowerFI = fiObj;
                }
            }

            List<ApplicationDetails> applicationDetailList = new List<ApplicationDetails>();
            for(Applicant__c app : [SELECT Account__c,Applicant_Type__c,Bank_Account_No__c,Contact_number__c,Customer_Code__c,Gender__c,Id,Marital_status__c,Opportunity__c,Profile__c,Scorecard_Decision__c,Income_Ca__c,PAN_CIN_Match__c,Register_for_WhatsApp_Banking__c, Is_Email_Valid__c, applicant_number__c, Who_will_repay_the_loan__c,Literacy__c,(SELECT id,Profile__c,Profile__r.Code__c,Profile__r.Category__c FROM Income_Details__r WHERE Profile__c != null),(SELECT id,Customer_Code__c,IND_isNewCustomer__c  FROM Customer_Dedupe_Response__r),(SELECT id,Document_Type__c,Permanent_Residential_Address_Proof__c,Current_Residential_Address_Proof__c FROM Documents__r WHERE Document_Type__c != null AND (Current_Residential_Address_Proof__c = true OR Permanent_Residential_Address_Proof__c = true) LIMIT 5) FROM Applicant__c WHERE Opportunity__c =: opty.Id AND In_Active_Applicant__c = false]){
                ApplicationDetails appDtl = new ApplicationDetails();
                appDtl.SubProfile = '';
                appDtl.State = requestWrapperObj !=null && requestWrapperObj.stateMap != null && requestWrapperObj.stateMap.containsKey(app.Id) ? requestWrapperObj.stateMap.get(app.Id) : '';
                appDtl.RiskBand = '';

                if(app.Income_Details__r != null && app.Income_Details__r.size() > 0){
                    appDtl.Profile = app.Income_Details__r[0].Profile__c != null ? app.Income_Details__r[0].Profile__r.Code__c : '';
                }

                appDtl.PAN_CIN_Alert_Flag = app.PAN_CIN_Match__c == true ? 'Y' : 'N';
                appDtl.MobileNumber = app.Contact_number__c == null ?'' : app.Contact_number__c;
                appDtl.MaritalStatus = app.Marital_status__c == null ? '' : String.valueOf(app.Marital_status__c);
                appDtl.Lead_Id = opty.Lead_number__c + '_'+ app.applicant_number__c;
                appDtl.Is_WhatApp_Available= app.Register_for_WhatsApp_Banking__c !=null && app.Register_for_WhatsApp_Banking__c == true ? 'Y' : app.Register_for_WhatsApp_Banking__c == false ? 'N' : '';
                appDtl.Is_Email_Available = app.Is_Email_Valid__c != null && app.Is_Email_Valid__c == true  ? 'Y' : app.Is_Email_Valid__c == false ? 'N' : '';
                appDtl.Gender = app.Gender__c != null && app.Gender__c == 'FEMALE'? '1': app.Gender__c == 'MALE' ? '2' : app.Gender__c == 'TRANSGENDER' ? '3' : '';
                appDtl.DateOfBirth = requestWrapperObj != null && requestWrapperObj.dateOfBirthMap != null && requestWrapperObj.dateOfBirthMap.containsKey(app.Id) ? requestWrapperObj.dateOfBirthMap.get(app.Id) : '';

                if(app.Customer_Dedupe_Response__r != null && app.Customer_Dedupe_Response__r.size() > 0){
                    appDtl.CustomerCode = app.Customer_Dedupe_Response__r[0].Customer_Code__c != null ? app.Customer_Dedupe_Response__r[0].Customer_Code__c : app.Customer_Code__c != null ? app.Customer_Code__c : '';
                }else{
                    appDtl.CustomerCode = app.Customer_Code__c != null ? app.Customer_Code__c : '';
                }

                appDtl.Country = requestWrapperObj!=null ? requestWrapperObj.country : '';           

                if(app.Income_Details__r != null && app.Income_Details__r.size() > 0){
                    appDtl.Category = app.Income_Details__r[0].Profile__c != null ? app.Income_Details__r[0].Profile__r.Category__c : '';
                }
                appDtl.ApplicationId = app.Id;
                appDtl.ApplicantType = app.Applicant_Type__c != null ? app.Applicant_Type__c.replace('-',' ') : '';

                Decimal agriLandAces = 0;
                if(fiMap.containsKey(app.Id) && fiMap.get(app.Id).Loan_Holding_Details__r.size() > 0){
                    for (Land_Holding_Detail__c landHoldingObj : fiMap.get(app.Id).Loan_Holding_Details__r) {
                        if(landHoldingObj.Land_holding_In_acres__c != null){
                            agriLandAces += landHoldingObj.Land_holding_In_acres__c;
                        }
                    }
                }
                appDtl.agriLandAcres = String.valueof(agriLandAces);
                if(fiMap.containsKey(app.Id) && fiMap.get(app.Id).Sub_Scheme_Type__c != null){
                    appDtl.landHoldingType = fiMap.get(app.Id).Sub_Scheme_Type__c;
                }else{
                    appDtl.landHoldingType = '';
                }
                appDtl.isIlliteratePerson = app.Literacy__c == 'Literate' ? 'FALSE' : 'TRUE';
                if(borrowerFI != null && borrowerFI.KYC_Location__c != null && guarantorFI != null && guarantorFI.KYC_Location__c != null){
                    String dist = (Integer)((Location.getDistance(borrowerFI.KYC_Location__c, guarantorFI.KYC_Location__c, 'km'))) + '';
                    appDtl.distanceFromGuarantor = dist;
                }else{
                    appDtl.distanceFromGuarantor = '';
                }
                appDtl.distanceFromBE = fiMap.containsKey(app.Id) ? fiMap.get(app.Id).Distance_from_Branch_to_customer__c : '';
                appDtl.typeOfBuyer = fiMap.containsKey(app.Id) ? fiMap.get(app.Id).Scheme_Type__c == 'FTU' ? '0' : fiMap.get(app.Id).Scheme_Type__c == 'REPEAT BUYER' ? '1' : '' : '';
                if(app.Customer_Dedupe_Response__r != null && app.Customer_Dedupe_Response__r.size() > 0){
                    appDtl.ExistingCustomer = app.Customer_Dedupe_Response__r[0].IND_isNewCustomer__c == true ? 'Y' : 'N';
                }else{
                    appDtl.ExistingCustomer = 'N';
                }
                appDtl.pastRepaymentTrack = '';
                appDtl.installmentToIncomeRatio = finalTermList.size() > 0 && finalTermList[0].Installment_To_Income_Ratio__c != null ? (Integer)((finalTermList[0].Installment_To_Income_Ratio__c).setScale(2) * 100) + '' : '';
                
                List<AddressDetail> addressDetailList = new List<AddressDetail>();
                for(Documents__c document : app.Documents__r){
                    AddressDetail addressDetailObj = new AddressDetail();
                    addressDetailObj.addressType = document.Current_Residential_Address_Proof__c == true ? 'C' : document.Permanent_Residential_Address_Proof__c == true ? 'P' : '';
                    // addressDetailObj.fiDistance = '5';
                    addressDetailObj.fiDistance = fiMap.containsKey(app.Id) ? fiMap.get(app.Id).Coordinates_Distance__c == null ? '':String.valueOf(fiMap.get(app.Id).Coordinates_Distance__c) : ''; //SFTRAC-1810
                    addressDetailObj.stabilityOfResidence = '5';
                    addressDetailObj.residenceType = 'Owned';
                    addressDetailList.add(addressDetailObj);
                }
                appDtl.AddressDetail = addressDetailList;
                appDtl.Exposure_Dealwise = new List<Exposure_Dealwise>();
                applicationDetailList.add(appDtl); 
            }
            this.ApplicationDetails = applicationDetailList;
        } catch(Exception e) {
            ErrorLoggerUtil.logErrorEvent('IND_FicoDeviationRequestTractor', 'Constructor', e.getTypeName(), e, loanAppId);
        }
    }    
    public static FicoRequestWrapper getRequestDetails(String loanAppId,Decimal currentExposureAmount){
        try {
            if(loanAppId != null){
                FicoRequestWrapper requestWrapperObj = new FicoRequestWrapper();
                List<Exposure__c> expList = new List<Exposure__c>();
                expList = [SELECT id,Current_Exposure__c,Current_Demand__c,Sanctioned_Amt__c,Applicant__c,Applicant__r.Applicant_Type__c,SOH__c,Type__c From Exposure__c WHERE Loan_Application__c =:loanAppId WITH SECURITY_ENFORCED LIMIT 1000];
                
                Decimal existingBorrowerExposureAmount = 0;
                Decimal bankExposureAmount = 0;
                Decimal existingCoBorrowerExposureAmount=0;
                Decimal existingOtherExposureAmount=0;
                Decimal totalExposureAmount=0;
                List<Lien_Detail__c> lienRecordList = new List<Lien_Detail__c>();
                if(expList.size()>0){
                    Set<ID> expIdSet = new Set<ID>();
                    for (Exposure__c expObj : expList) {
                        if(expObj.Type__c  == System.Label.Borrower_Exposure){ 
                            existingBorrowerExposureAmount =expObj.SOH__c !=null ? existingBorrowerExposureAmount + (Decimal)expObj.SOH__c:existingBorrowerExposureAmount;
                            expIdSet.add(expObj.Id);
                        }
                        if(expObj.Type__c  == System.Label.Co_Borrower_Exposure){
                            existingCoBorrowerExposureAmount = expObj.SOH__c !=null ? existingCoBorrowerExposureAmount + (Decimal)expObj.SOH__c:existingCoBorrowerExposureAmount;
                            expIdSet.add(expObj.Id);
                        }
                        if(expObj.Type__c  == System.Label.Additional_Customer){
                            existingOtherExposureAmount = expObj.SOH__c !=null ? existingOtherExposureAmount + (Decimal)expObj.SOH__c:existingOtherExposureAmount;
                        }
                        if(expObj.Type__c  == System.Label.Bank_Exposure){
                            bankExposureAmount = expObj.Sanctioned_Amt__c !=null ? bankExposureAmount + (Decimal)expObj.Sanctioned_Amt__c : bankExposureAmount;
                        }
                    }   
                    if (expIdSet!=null) {
                        lienRecordList = [SELECT Id, Name, Lien_Type__c, Lien_Maker_Date__c, Lien_Marking_Period__c, Deal_No__c, Deal_No__r.Name, Lien_Request_By__c, Lien_Marking_Reason__c FROM Lien_Detail__c WHERE Deal_No__c IN:expIdSet WITH SECURITY_ENFORCED LIMIT 1000]; 
                    }
                }
                for(Applicant__c applicantRecord : [SELECT Id, Name,Applicant_Type__c, Total_Insurance_Payable__c,Cheque_Return_Count__c,Relationship_Since__c From Applicant__c 
                                                    Where Opportunity__c =:loanAppId and In_Active_Applicant__c =false])
                {
                    currentExposureAmount += applicantRecord.Total_Insurance_Payable__c !=null ? (Decimal)applicantRecord.Total_Insurance_Payable__c : 0;
                }

                totalExposureAmount = existingBorrowerExposureAmount +existingCoBorrowerExposureAmount+bankExposureAmount+existingOtherExposureAmount+currentExposureAmount;
                requestWrapperObj.totalExposure = totalExposureAmount!=0?String.valueOf(totalExposureAmount):'';
                requestWrapperObj.totalBankExposure = bankExposureAmount != 0 ? String.valueOf(bankExposureAmount) : '';
                
                Map<Id,String> dateOfBirthMap = new Map<Id,String>();
                Map<Id,String> stateMap = new Map<Id,String>();
                List<Documents__c> documentList = [select ID,Document_Type__c, Proof_of_Address_POA__c,Proof_of_Identity_POI__c, KYC_State__c,KYC_DOB__c,Name,Applicant__c,Age__c,Applicant__r.Applicant_Type__c from Documents__c Where Opportunity_Relation__c = :loanAppId AND ((Proof_of_Identity_POI__c = true AND KYC_DOB__c!=null) OR (Proof_of_Address_POA__c = true AND KYC_State__c!=null))  WITH SECURITY_ENFORCED Limit 100];
                for (Documents__c docObj : documentList) {
                    if(docObj.Proof_of_Identity_POI__c){
                        dateOfBirthMap.put(docObj.Applicant__c,String.valueOf(docObj.KYC_DOB__c));
                    }
                    if(docObj.Proof_of_Address_POA__c){
                        stateMap.put(docObj.Applicant__c,String.valueOf(docObj.KYC_State__c));
                    }
                }
                requestWrapperObj.dateOfBirthMap = dateOfBirthMap;
                requestWrapperObj.stateMap = stateMap;
                requestWrapperObj.lienFlag = lienRecordList.size()>0 ? 'Y' : 'N';
                requestWrapperObj.country = 'India';
                return  requestWrapperObj;
            }
            return null;
        } catch(Exception e) {
            ErrorLoggerUtil.logErrorEvent('IND_FicoDeviationRequestTractor', 'getRequestDetails', e.getTypeName(), e, loanAppId);
            return null;
        }
    }
    
    
    public Class FicoRequestWrapper{
        public String totalExposure;
        public String totalBankExposure;
        public Map<Id,String> dateOfBirthMap;
        public Map<Id,String> stateMap;
        public string ageOfVehicleLoanMaturity;
        public string lienFlag;
        public string country;
    }
    
    // @Method:      getHttpRequestHeaders
    // @Created by:  Prathik
    // @Description: Method to get the HTTP request header data
    // @Param:       ''
    // @Return:      Header required to callout the service.
    public override Map<String,String> getHttpRequestHeaders(){    
        Map<String,String> requestHeaderMap = Utilities.getHeaders();
        return requestHeaderMap;
    }
    
    // @Method:      validate
    // @Created by:  Prathik
    // @Description: Method to validate the required input details
    // @Param:       Service name
    // @Return:      True - If all the validations are passed.
    
    public override boolean validate(String serviceName){        
        return true;
    }
}