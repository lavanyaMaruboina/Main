/*------------------------------------------------------------
Author:        Prathik
Company:       Persistent Systems
Description:   This class is wrapper class for the FicoDeviationRequest API request
Apex Class : IND_FicoDeviationRequest for API FicoDeviationRequest
Test Class:    
History
Date            Author              Comments
-------------------------------------------------------------
12-28-2021      Prathik             Created
03-07-2021      Bhushan Charde      Modified - Change in request
------------------------------------------------------------*/
public class IND_FicoDeviationRequest extends ParentAPIRequest {
    
    public final string purposeOfPurchase {get;set;}
    public final String Proposal_Based_On {get;set;}
    public final String Product {get;set;}
    public final String VehicleType {get;set;}
    public final String segment {get;set;}
    public final String Maker_Id {get;set;}
    public final String LTV {get;set;}
    public final String CRM_IRR {get;set;}
    public final String Tenure {get;set;}
    public final String LoanAmount {get;set;}
    public  String ORP {get;set;}//CISP-2516
    public final String ValuationPrice {get;set;}
    public final String IDVPrice {get;set;}
    public final String No_Of_Ownership {get;set;}
    public final String Month_Of_Manufacture {get;set;}
    public final String Year_Of_Manufacture {get;set;}
    public String Directorclause {get;set;} //CISP-20554
    public final String Total_Exposure {get;set;}
    public final String AgeOfVehicleLoanMaturity {get;set;}
    public final String lienFlag {get;set;}
    public String Threshold_Net_IRR {get;set;}
    public final String Bl_Code {get;set;}
    public final String SubProduct {get;set;}
    public final String Type_Of_Dealer {get;set;}
    public final String Banking_Exposure {get;set;}
    public List<ApplicationDetails> ApplicationDetails {get;set;}
    public final String Engine_Irr_Offered {get;set;}
    public final String Moratorium_Days {get;set;}
    public  String LTV_Based_On {get;set;}//Start CISP-2491,CISP-2516
    public  String basicPrice {get;set;}
    public  String discount {get;set;}
    public  String documentCharge {get;set;} //CISP-3785
    public  String roadTax {get;set;}
    public  String serviceCharge {get;set;} //CISP-3785
    public  String firstYearInsurancePremium {get;set;}
    public  String otherCharges {get;set;}
    public  String gstAmount {get;set;}
    public  String Advance_EMI_Flag {get;set;}
    public  String Ex_Showroom_Price {get;set;}
    public  String OfferEMI {get;set;}//End CISP-2491,CISP-2516
    public  String dSABenficiaryCode {get;set;}
    public  String dealerBenficiaryCode {get;set;}
    public  String totalPayouts {get;set;}
    public  String Overall_Remarks {get;set;}
    public  String valuerCategory {get;set;}
    public  String Foir{get;set;}//CISP-12592
    public String Channel { get; set; } // D2C change
    
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
        public final String customerType {get;set;}
        public List<Exposure_Dealwise> Exposure_Dealwise {get;set;}
    }
    
    public class Exposure_Dealwise {
        public final String CustomerCode {get;set;}
        public final String dealNumber {get;set;}
        public final String dealDate {get;set;}
        public final String statusFlag {get;set;}
        public final String product {get;set;}
        public final String cfdExposureAmount {get;set;}
        public final String IBL_Seasoning {get;set;}
    }
    
    
    // @Method:      IND_FicoDeviationRequest
    // @Created by:  Prathik
    // @Description: Contructor to initialize the details
    // @Param:       Object applicant Record
    // @Return:      ''
    public IND_FicoDeviationRequest(String loanAppId, Opportunity opty){ 
        if(loanAppId == null && Test.isRunningTest()){
            throw new IND_Exception(System.label.LoanApplicationNOTNULL);
        }   
        try {
            Opportunity optyObj = [SELECT FOIR__c,Basic_Price__c,Funding_on_Ex_Showroom__c,Ex_showroom_price__c,Advance_EMI__c,RTO_Road_Tax_New__c,RTO_Road_Tax__c,X1st_yr_Insurance_Premium__c,Other_charges__c,GST_Amount__c,Discount_on_Basic_Price__c,Total_Funded_Premium__c, leadsource, Aggregator_Source__c FROM Opportunity WHERE Id=:opty.Id WITH SECURITY_ENFORCED]; //CISP-2516 //CISP-2491// D2C change- added leadsource, aggregator source field
            Boolean isCoborrowerRelationMatch = false;//CISP-7987
            List<String> relationWithBorrowerList = new List<String>{'BROTHER - IN LAW' , 'BROTHER - INCLUDING STEP BROTHER' , 'DAUGHTER - INCLUDING STEP DAUGHTER' , 'FATHER' , 'GRANDDAUGHTER' , 'GRANDSON' , 'HUSBAND', 'HUSBAND OF GRANDDAUGHTER',
            'HUSBAND OF SISTER' , 'MATERNAL GRANDFATHER' ,'MATERNAL GRANDMOTHER' , 'MEMBER OF HINDU UNDIVIDED FAMILY' , 'MOTHER -INCLUDING STEP MOTHER' , 'PATERNAL GRANDFATHER',
            'PATERNAL GRANDMOTHER', 'SISTER - IN LAW', 'SISTER - INCLUDING STEP SISTER' , 'SON - INCLUDING STEP SON', 'SON WIFE' , 'WIFE' , 'WIFE OF BROTHER' , 'WIFE OF GRANDSON'};//CISP-7987

            List<Applicant__c> appList = [SELECT Account__c,Applicant_Type__c,Bank_Account_No__c,Contact_number__c,Customer_Code__c,
                                          Gender__c,Id,Marital_status__c,Opportunity__c,Profile__c,Scorecard_Decision__c,Income_Ca__c,PAN_CIN_Match__c,
                                          Register_for_WhatsApp_Banking__c, Is_Email_Valid__c, applicant_number__c, Who_will_repay_the_loan__c,
                                          Relationship_with_borrower__c,Customer_Category__c,Is_Borrower_Relative_Of_Director__c, Is_Borrower_Relative_Of_Senior_Officer__c, Is_CoBorrower_Relative_Of_Director__c, Is_CoBorrower_Relative_Of_Senior_Officer__c
                                          FROM Applicant__c WHERE Opportunity__c =: opty.Id AND In_Active_Applicant__c = false WITH SECURITY_ENFORCED];
            List<Vehicle_Detail__c> vehicleDetailList = new List<Vehicle_Detail__c>();        
            vehicleDetailList = [SELECT Manufacturer_Year_Month__c,Product_Segment__c,Insurance_declared_value__c,Valuation_price__c,Number_of_ownerships__c,OEM_Dealer__c, Model__c,Product__c,Base_Prices__c,Ben_Code__c,Overall_Remarks__c,Valuer_category__c,Purpose_of_Purchase__c
                                 FROM Vehicle_Detail__c 
                                 WHERE Loan_Application__c = : opty.Id WITH SECURITY_ENFORCED]; 
            Vehicle_Detail__c vehicleObj = vehicleDetailList.size() > 0 ? vehicleDetailList[0] : new Vehicle_Detail__c();
            List<Final_Term__c> finalTermObj =  [SELECT CRM_IRR__c,PricingEngine_thresholdNetrr__c,LtvEngine_Ltv__c,Net_IRR__c,Threshold_CRM_IRR__c,Loan_Amount__c,Tenure__c,Inputted_IRR__c,Schemes__c,Schemes__r.Low_IRR_Scheme__c,Schemes__r.Imputed_IRR_for_Low_IRR_Scheme__c,Advance_EMI__c,EMI_Amount__c,Documentation_charges__c,Service_charges__c,Referrer_Ben_Code__c,Gift_through_dealer_amount__c,Mfr_Incentive__c,DSM_Incentive1__c,DSM_Incentive2__c,Dealer_incentive_amount_main_dealer__c,Provisional_Channel_Cost__c,Dealer_incentive_amount_sub_dealer__c,Rreferrer_Incentive__c FROM Final_Term__c 
                                                 WHERE Loan_Application__c = : opty.Id WITH SECURITY_ENFORCED];// CISP-2491 //CISP-3785

            List <Product2> prodList = [SELECT Asset_Category__c,Name 
                                        FROM Product2 
                                        WHERE Name =: vehicleObj.Model__c WITH SECURITY_ENFORCED];
            List<Applicant__c> proposalList = [SELECT Who_will_repay_the_loan__c
                                               FROM Applicant__c WHERE Opportunity__c =: opty.Id 
                                               AND Who_will_repay_the_loan__c != null AND In_Active_Applicant__c = false WITH SECURITY_ENFORCED];       
            FicoRequestWrapper requestWrapperObj = IND_FicoDeviationRequest.getRequestDetails(opty.Id);
            if(requestWrapperObj!=null){
                this.Total_Exposure = requestWrapperObj.totalExposure;
                this.AgeOfVehicleLoanMaturity = requestWrapperObj.ageOfVehicleLoanMaturity;
                this.lienFlag = requestWrapperObj.lienFlag;
                this.Banking_Exposure = requestWrapperObj.totalBankExposure;
            }
            List<Exposure__c> expoList;
            //D2C Change
            if(optyObj.LeadSource == 'D2C') {
                this.Channel =  'IndusMobile';
            }
            if(String.isNotBlank(optyObj.Aggregator_Source__c)) {
                this.Channel =  'Aggregator';
            }
            this.Foir = optyObj.FOIR__c!=null ? String.valueOf((optyObj.FOIR__c/appList.size()).setScale(2)) : '0';
            this.Proposal_Based_On = proposalList.isEmpty() == true ? '' : proposalList[0].Who_will_repay_the_loan__c == 'Borrower' ? 'Borrower' : 'Co Borrower';
            this.Product= opty.Product_Type__c != null && opty.Product_Type__c == 'Two Wheeler' ?'H': opty.Product_Type__c == 'Passenger Vehicles' ?'C' :'';
            this.VehicleType= opty.Vehicle_Type__c == 'New'?'N' : opty.Vehicle_Type__c == 'Used' ?'U' : opty.Vehicle_Type__c == 'Refinance' ?'R' : '';
            this.Maker_Id= IntegrationUtilities.getMakerId();
            this.LTV= finalTermObj.size()>0?finalTermObj[0].LtvEngine_Ltv__c == null ?'' : String.valueOf(finalTermObj[0]?.LtvEngine_Ltv__c):'';
            this.CRM_IRR = finalTermObj.size()>0 ? finalTermObj[0].CRM_IRR__c == null ?'' : String.valueOf(finalTermObj[0]?.CRM_IRR__c) : '';
            this.Tenure= finalTermObj[0].Tenure__c == null ?'' : String.valueOf(finalTermObj[0].Tenure__c);
            this.LoanAmount= finalTermObj[0].Loan_Amount__c == null ? '' : String.valueOf((Decimal.valueOf(finalTermObj[0].Loan_Amount__c)) + optyObj.Total_Funded_Premium__c);//CISP-2491
            this.ORP= opty.On_Road_price__c == null ?'' : String.valueOf(opty.On_Road_price__c );
            this.purposeOfPurchase= vehicleObj?.Purpose_of_Purchase__c == null?'' : String.valueOf(vehicleObj?.Purpose_of_Purchase__c); //commercial pv flow
            this.ValuationPrice= vehicleObj.Valuation_price__c == null ?'' : String.valueOf(vehicleObj.Valuation_price__c);
            this.IDVPrice= vehicleObj.Insurance_declared_value__c ==null ?'' :String.valueOf(vehicleObj.Insurance_declared_value__c);
            this.No_Of_Ownership= vehicleObj?.Number_of_ownerships__c == null?'' : String.valueOf(vehicleObj?.Number_of_ownerships__c);
            this.segment= vehicleObj?.Product_Segment__c == null?'' : vehicleObj.Product_Segment__c=='ESCOOTER' ?'ESCOOTER':'';
            this.Month_Of_Manufacture= vehicleObj?.Manufacturer_Year_Month__c==null?'':vehicleObj?.Manufacturer_Year_Month__c.substringAfter('-');
            this.Year_Of_Manufacture= vehicleObj?.Manufacturer_Year_Month__c==null?'':vehicleObj?.Manufacturer_Year_Month__c.substringBefore('-');
             this.Threshold_Net_IRR= finalTermObj.size()>0?finalTermObj[0].PricingEngine_thresholdNetrr__c ==null?'':String.valueOf(finalTermObj[0]?.PricingEngine_thresholdNetrr__c):'';
             if (opty.Product_Type__c != null && opty.Product_Type__c == 'Two Wheeler' && finalTermObj.size()>0 && finalTermObj[0].Schemes__c != null && finalTermObj[0].Schemes__r.Low_IRR_Scheme__c !=null && finalTermObj[0].Schemes__r.Low_IRR_Scheme__c == 'Yes' && finalTermObj[0].Schemes__r.Imputed_IRR_for_Low_IRR_Scheme__c != null && finalTermObj[0].Schemes__r.Imputed_IRR_for_Low_IRR_Scheme__c != 0) {
                this.Threshold_Net_IRR = String.valueOf(finalTermObj[0].Schemes__r.Imputed_IRR_for_Low_IRR_Scheme__c);
            }//CISP-12300
            this.Bl_Code= opty.Agent_BL_code__c == null ?'' : opty.Agent_BL_code__c;
            this.SubProduct= prodList.isEmpty() == true ? '' : String.valueOf(prodList[0].Asset_Category__c);
            this.Type_Of_Dealer= vehicleObj.OEM_Dealer__c !=null && vehicleObj.OEM_Dealer__c == true ?'OEM' : vehicleObj.OEM_Dealer__c == false ?'NON OEM' :'';
            this.Overall_Remarks  = vehicleObj.Overall_Remarks__c == null ?'' :vehicleObj.Overall_Remarks__c;
            this.valuerCategory = vehicleObj.Valuer_category__c == null ? '' : vehicleObj.Valuer_category__c == 'Empanelled' ? 'EM' : vehicleObj.Valuer_category__c == 'MFC' ? 'FC' : '';
            if(finalTermObj.size()>0 && opty.Product_Type__c != null){
                if (opty.Product_Type__c == 'Two Wheeler' && finalTermObj[0].Inputted_IRR__c !=null) {
                    this.Engine_Irr_Offered=String.valueOf(finalTermObj[0].Inputted_IRR__c);
                }else if(opty.Product_Type__c == 'Passenger Vehicles' && finalTermObj[0].Net_IRR__c !=null) {
                    this.Engine_Irr_Offered=String.valueOf(finalTermObj[0].Net_IRR__c);
                }else {
                    this.Engine_Irr_Offered= '';
                }
            }else {
                this.Engine_Irr_Offered= '';
            }
            this.Moratorium_Days = requestWrapperObj!=null ? requestWrapperObj.moratoriumDays : '';  
            if(opty.Funding_on_ORP__c == true){//Start CISP-2491
                this.LTV_Based_On = 'Onroad price';//2491
                this.ORP = opty.On_Road_price__c != null ? String.valueOf(opty.On_Road_price__c) : '';
                this.Ex_Showroom_Price = '';
            }
            else if(optyObj.Funding_on_Ex_Showroom__c == true){// Start CISP-2516
                this.LTV_Based_On = 'Ex-showroom price';//2491
                this.ORP = '';
                this.Ex_Showroom_Price = optyObj.Ex_showroom_price__c != null ? String.valueOf(optyObj.Ex_showroom_price__c) : '';
            }
            this.discount = optyObj.Discount_on_Basic_Price__c != null ? String.valueOf(optyObj.Discount_on_Basic_Price__c) : '';
            if(opty.Product_Type__c == 'Passenger Vehicles'){this.documentCharge = finalTermObj[0].Documentation_charges__c!=null  ? finalTermObj[0].Documentation_charges__c : '';
            this.serviceCharge= finalTermObj[0].Service_charges__c	!=null? finalTermObj[0].Service_charges__c : '';}//CISP-3875
            String roadTax = '';
            if(opty.Product_Type__c == 'Two Wheeler'){
                roadTax = optyObj.RTO_Road_Tax_New__c != null ? String.valueOf(optyObj.RTO_Road_Tax_New__c) : '';
            }else if(opty.Product_Type__c == 'Passenger Vehicles'){
               // List<Retry_Count__c> retryCounList = new List<Retry_Count__c>([Select Id from Retry_Count__c WHERE Loan_Application_Id__c =: optyObj.Id AND Service_Name__c = 'CarwaleApi' AND Count__c >= 3 AND IsAPIFailed__c = true]);
               // if(retryCounList.size() > 0){
                    roadTax = optyObj.RTO_Road_Tax_New__c != null ? String.valueOf(optyObj.RTO_Road_Tax_New__c) : '';
               // }else{
                 //   roadTax = optyObj.RTO_Road_Tax__c != null ? String.valueOf(optyObj.RTO_Road_Tax__c) : '';
              // }
           // }else{
              //  roadTax = optyObj.RTO_Road_Tax_New__c != null ? String.valueOf(optyObj.RTO_Road_Tax_New__c) : '';
            }
            this.roadTax = roadTax;
            this.Advance_EMI_Flag = finalTermObj[0].Advance_EMI__c ? 'Yes' : 'No';
            this.firstYearInsurancePremium = optyObj.X1st_yr_Insurance_Premium__c !=null ? String.valueOf(optyObj.X1st_yr_Insurance_Premium__c): '';
            this.otherCharges = optyObj.Other_charges__c != null ? String.valueOf(optyObj.Other_charges__c) : '';
            this.gstAmount = optyObj.GST_Amount__c != null ? String.valueOf(optyObj.GST_Amount__c) : '';// End CISP-2516
            this.basicPrice = optyObj.Basic_Price__c != null ? String.valueOf(optyObj.Basic_Price__c) : '';
            this.OfferEMI = finalTermObj[0].EMI_Amount__c != null ? String.valueOf(finalTermObj[0].EMI_Amount__c) : '';//End CISP-2491
            this.dSABenficiaryCode = finalTermObj[0].Referrer_Ben_Code__c != null ? finalTermObj[0].Referrer_Ben_Code__c : '';
            this.dealerBenficiaryCode = vehicleObj.Ben_Code__c != null ? vehicleObj.Ben_Code__c : '';
            Decimal totalPayOutAmount = 0;
            if(finalTermObj.size() > 0){
                totalPayOutAmount += finalTermObj[0].Gift_through_Dealer_Amount__c != null ? Decimal.valueOf(finalTermObj[0].Gift_through_Dealer_Amount__c) : 0;
                totalPayOutAmount += finalTermObj[0].Mfr_Incentive__c != null ? Decimal.valueOf(finalTermObj[0].Mfr_Incentive__c) : 0;
                totalPayOutAmount += finalTermObj[0].DSM_Incentive1__c != null ? Decimal.valueOf(finalTermObj[0].DSM_Incentive1__c) : 0;
                totalPayOutAmount += finalTermObj[0].DSM_Incentive2__c != null ? Decimal.valueOf(finalTermObj[0].DSM_Incentive2__c) : 0;
                totalPayOutAmount += finalTermObj[0].Dealer_incentive_amount_main_dealer__c != null ? Decimal.valueOf(finalTermObj[0].Dealer_incentive_amount_main_dealer__c) : 0; 
                if(opty.Product_Type__c == 'Two Wheeler'){
                    totalPayOutAmount += finalTermObj[0].Provisional_Channel_Cost__c != null ? Decimal.valueOf(finalTermObj[0].Provisional_Channel_Cost__c) : 0;
                    totalPayOutAmount += finalTermObj[0].Dealer_incentive_amount_sub_dealer__c != null ? Decimal.valueOf(finalTermObj[0].Dealer_incentive_amount_sub_dealer__c) : 0;
                }
                if(opty.Product_Type__c == 'Passenger Vehicles'){
                    totalPayOutAmount += finalTermObj[0].Rreferrer_Incentive__c != null ? Decimal.valueOf(finalTermObj[0].Rreferrer_Incentive__c) : 0;
                }
            }
            this.totalPayouts = String.valueOf(totalPayOutAmount);
            ApplicationDetails = new List<ApplicationDetails>();
            List<Exposure_Dealwise> exposureDealwise ;
            ApplicationDetails appDtl;
            Exposure_Dealwise expoDlwiseDtl;
            List<Customer_Dedupe_Response__c> borrowerCDRList = [SELECT Customer_Code__c FROM Customer_Dedupe_Response__c WHERE Applicant__c IN: appList AND Applicant__r.Applicant_Type__c = 'Borrower' AND Applicant__r.In_Active_Applicant__c = false WITH SECURITY_ENFORCED];
            List<Customer_Dedupe_Response__c> coBorrowerCDRList = [SELECT Customer_Code__c FROM Customer_Dedupe_Response__c WHERE Applicant__c IN: appList AND Applicant__r.Applicant_Type__c = 'Co-borrower' AND Applicant__r.In_Active_Applicant__c = false WITH SECURITY_ENFORCED];
            expoList = [SELECT Applicant__c,Customer_Code__c,Customer_Code__r.name,Deal_Date__c,Deal_No__c,Product__c,Sanctioned_Amt__c,Status_Flag__c,IB_Seasoning__c 
                        FROM Exposure__c WHERE Applicant__c IN :appList WITH SECURITY_ENFORCED];    
            for(Applicant__c app : appList){
                exposureDealwise =new List<Exposure_Dealwise>();
                appDtl = new ApplicationDetails();
                appDtl.ApplicantType= app.Applicant_Type__c == 'Borrower' ? 'Borrower' : 'Co Borrower';
                appDtl.Lead_Id= opty.Lead_number__c + '_'+ app.applicant_number__c;
                appDtl.ApplicationId= app.Id;
                if (app.Applicant_Type__c == 'Borrower') {
                    appDtl.CustomerCode= borrowerCDRList.size() > 0 && borrowerCDRList[0].Customer_Code__c != null ? borrowerCDRList[0].Customer_Code__c : '';
                } else {
                    appDtl.CustomerCode= coBorrowerCDRList.size() > 0 && coBorrowerCDRList[0].Customer_Code__c != null ? coBorrowerCDRList[0].Customer_Code__c : '';
                }
                //CISP-7987
                if(app.Applicant_Type__c == 'Co-borrower'){
                    if(relationWithBorrowerList.contains(app.Relationship_with_borrower__c)){
                        isCoborrowerRelationMatch = true;
                    }
                }//CISP-7987
                appDtl.MobileNumber= app.Contact_number__c == null ?'' : app.Contact_number__c;
                appDtl.State = requestWrapperObj!=null && requestWrapperObj.stateMap!=null && requestWrapperObj.stateMap.containsKey(app.Id) ? requestWrapperObj.stateMap.get(app.Id) : '';
                appDtl.Country = requestWrapperObj!=null ? requestWrapperObj.country : '';       
                 appDtl.customerType =  'Individual';    
                this.Directorclause = this.Directorclause != null ? this.Directorclause == 'Y' ? 'Y' : ((app.Is_Borrower_Relative_Of_Director__c != null && app.Is_Borrower_Relative_Of_Director__c == 'Yes') || (app.Is_Borrower_Relative_Of_Senior_Officer__c != null && app.Is_Borrower_Relative_Of_Senior_Officer__c == 'Yes') || (app.Is_CoBorrower_Relative_Of_Director__c != null && app.Is_CoBorrower_Relative_Of_Director__c == 'Yes') || (app.Is_CoBorrower_Relative_Of_Senior_Officer__c != null && app.Is_CoBorrower_Relative_Of_Senior_Officer__c == 'Yes')) ? 'Y' : 'N' : ((app.Is_Borrower_Relative_Of_Director__c != null && app.Is_Borrower_Relative_Of_Director__c == 'Yes') || (app.Is_Borrower_Relative_Of_Senior_Officer__c != null && app.Is_Borrower_Relative_Of_Senior_Officer__c == 'Yes') || (app.Is_CoBorrower_Relative_Of_Director__c != null && app.Is_CoBorrower_Relative_Of_Director__c == 'Yes') || (app.Is_CoBorrower_Relative_Of_Senior_Officer__c != null && app.Is_CoBorrower_Relative_Of_Senior_Officer__c == 'Yes')) ? 'Y' : 'N';     
                List<Income_Details__c> incomeBorrowerList = new List<Income_Details__c>();
                incomeBorrowerList = [SELECT id,Profile__r.Code__c,Profile__r.Category__c FROM Income_Details__c WHERE Applicant__c = :app.Id AND Profile__c != null WITH SECURITY_ENFORCED LIMIT 1000];            
                if(incomeBorrowerList.size()>0){
                    appDtl.Profile = incomeBorrowerList[0].Profile__r.Code__c;
                    appDtl.Category = incomeBorrowerList[0].Profile__r.Category__c;
                } else {
                    List<Profile_Master__c> pm = [SELECT Id,Name,Code__c,Category__c FROM Profile_Master__c WHERE Name=:app.Profile__c WITH SECURITY_ENFORCED LIMIT 1];
                    if(pm.size()>0){
                        appDtl.Profile=pm[0].Code__c;
                        appDtl.Category=pm[0].Category__c;
                    }
                }           
                appDtl.SubProfile='';
                appDtl.MaritalStatus= app?.Marital_status__c ==null?'':String.valueOf(app?.Marital_status__c);
                appDtl.Gender= app.Gender__c != null && app.Gender__c == 'FEMALE'?'1': app.Gender__c == 'MALE'?'2' : app.Gender__c == 'TRANSGENDER'?'3': '';
                appDtl.DateOfBirth = requestWrapperObj!=null && requestWrapperObj.dateOfBirthMap!=null && requestWrapperObj.dateOfBirthMap.containsKey(app.Id) ? requestWrapperObj.dateOfBirthMap.get(app.Id) : '';
                appDtl.Is_WhatApp_Available= app.Register_for_WhatsApp_Banking__c !=null && app.Register_for_WhatsApp_Banking__c == true ?'Y' : app.Register_for_WhatsApp_Banking__c == false ?'N' :'';
                appDtl.Is_Email_Available= app.Is_Email_Valid__c !=null && app.Is_Email_Valid__c == true  ? 'Y' : app.Is_Email_Valid__c == false ?'N' :'';
                String scoreCardDecision = app.Scorecard_Decision__c;
                if ((!String.IsBlank(scoreCardDecision)) && scoreCardDecision!=null && scoreCardDecision.equalsIgnoreCase('Dark Green')){
                    appDtl.RiskBand = '01';
                }
                else if ((!String.IsBlank(scoreCardDecision)) && scoreCardDecision!=null && scoreCardDecision.equalsIgnoreCase('Light Green')){
                    appDtl.RiskBand = '02';
                }
                else if ((!String.IsBlank(scoreCardDecision)) && scoreCardDecision!=null && scoreCardDecision.equalsIgnoreCase('Yellow')){
                    appDtl.RiskBand = '03';
                }
                else if ((!String.IsBlank(scoreCardDecision)) && scoreCardDecision!=null && scoreCardDecision.equalsIgnoreCase('Orange')){
                    appDtl.RiskBand = '04';
                }
                else if ((!String.IsBlank(scoreCardDecision)) && scoreCardDecision!=null && scoreCardDecision.equalsIgnoreCase('Red')){
                    appDtl.RiskBand = '05';
                }
                else{
                    appDtl.RiskBand='';
                }
                appDtl.PAN_CIN_Alert_Flag = appDtl.PAN_CIN_Alert_Flag!=null && app.PAN_CIN_Match__c == true ? 'Y' : 'N';            
                if(!expoList.isEmpty()){
                    for(Exposure__c expo : expoList){
                        if (expo.Applicant__c == app.Id) {
                            if(app.Applicant_Type__c == 'Borrower' || (app.Applicant_Type__c == 'Co-borrower' && isCoborrowerRelationMatch == true)){
                                expoDlwiseDtl = new Exposure_Dealwise();
                                if (app.Applicant_Type__c == 'Borrower') {
                                    expoDlwiseDtl.CustomerCode= borrowerCDRList.size() > 0 && borrowerCDRList[0].Customer_Code__c != null ? borrowerCDRList[0].Customer_Code__c : '';
                                } else {
                                    expoDlwiseDtl.CustomerCode= coBorrowerCDRList.size() > 0 && coBorrowerCDRList[0].Customer_Code__c != null ? coBorrowerCDRList[0].Customer_Code__c : '';
                                }
                                expoDlwiseDtl.dealNumber= expo?.Deal_No__c == null?'':String.valueOf(expo?.Deal_No__c);
                                expoDlwiseDtl.dealDate= expo?.Deal_Date__c == null?'':String.valueOf(Date.valueOf(expo.Deal_Date__c));
                                expoDlwiseDtl.statusFlag= expo?.Status_Flag__c == null?'' : expo?.Status_Flag__c;
                                expoDlwiseDtl.product= expo?.Product__c == null ?'' : expo?.Product__c;
                                expoDlwiseDtl.cfdExposureAmount= expo?.Sanctioned_Amt__c == null ?'0' : String.valueOf(expo?.Sanctioned_Amt__c);
                                expoDlwiseDtl.IBL_Seasoning = expo?.IB_Seasoning__c == null ? '' : String.valueOf(expo?.IB_Seasoning__c);
                                exposureDealwise.add(expoDlwiseDtl);
                            }
                        }
                    }
                    appDtl.Exposure_Dealwise=exposureDealwise;
                    this.ApplicationDetails.add(appDtl);
                }
                else{	
                    expoDlwiseDtl = new Exposure_Dealwise();
                    appDtl.Exposure_Dealwise=exposureDealwise;
                    this.ApplicationDetails.add(appDtl);
                } 
            }
        } catch(Exception e) {
            ErrorLoggerUtil.logErrorEvent('IND_FicoDeviationRequest', 'Constructor', e.getTypeName(), e, loanAppId);
        }
    }    
    
    /**********************************************
* @Commented By:  Rajat Jaiswal
* @UserStory:  Feature 8.2.17,8.2.18 - Deviation Management
* @Purpose: This method is used to provide more data to construct the FICO API.
***********************************************/
    public static FicoRequestWrapper getRequestDetails(String loanAppId){
        try {
            if(loanAppId != null){
                FicoRequestWrapper requestWrapperObj = new FicoRequestWrapper();
                List<Exposure__c> expList = new List<Exposure__c>();
                expList = [SELECT id,Current_Exposure__c,Current_Demand__c,Sanctioned_Amt__c,Applicant__c,Applicant__r.Applicant_Type__c,SOH__c,Type__c From Exposure__c WHERE Loan_Application__c =:loanAppId WITH SECURITY_ENFORCED LIMIT 1000];
                List<Final_Term__c> finaltermsList = new List<Final_Term__c>();
                finaltermsList = [select id,Holiday_period__c,Tenure__c,Loan_Amount__c FROM Final_Term__c WHERE Loan_Application__c =:loanAppId AND Holiday_period__c!=null WITH SECURITY_ENFORCED  LIMIT 1];
                List<Vehicle_Detail__c> vehicleList = new List<Vehicle_Detail__c>();
                vehicleList = [SELECT id,Lien_in_favor_of__c,Manufacturer_Year_Month__c FROM Vehicle_Detail__c WHERE Loan_Application__c = :loanAppId  WITH SECURITY_ENFORCED LIMIT 1];
                requestWrapperObj.moratoriumDays = finaltermsList!=null && finaltermsList.size()>0 ? String.valueOf(finaltermsList[0].Holiday_period__c) : '';
                String vehicleYear = vehicleList.size()>0 && vehicleList[0].Manufacturer_Year_Month__c != null ? vehicleList[0].Manufacturer_Year_Month__c.substringBefore('-') : null;
                String vehicleMonth = vehicleList.size()>0 && vehicleList[0].Manufacturer_Year_Month__c != null ? vehicleList[0].Manufacturer_Year_Month__c.substringAfter('-') : null;
                if(vehicleYear!=null){
                    Decimal finalTenure = finaltermsList.size() > 0 && finaltermsList[0].Tenure__c != null ? (Decimal.valueOf(finaltermsList[0].Tenure__c)/12): 0;
                    Decimal vehicleYearDecimal = vehicleYear != null ? System.today().Year() - Integer.valueOf(vehicleYear) : 0;
                    Decimal vehicleMonthDecimal = vehicleMonth != null ? (System.today().month() - Decimal.valueOf(vehicleMonth))/12 : 0;
                    Decimal actualVehicleAge = (finalTenure + vehicleYearDecimal+ vehicleMonthDecimal).setScale(1);
                    requestWrapperObj.ageOfVehicleLoanMaturity = String.valueOf(actualVehicleAge);    
                }
                else {
                    requestWrapperObj.ageOfVehicleLoanMaturity = '';
                }
                Decimal existingBorrowerExposureAmount = 0;
                Decimal bankExposureAmount = 0;
                Decimal existingCoBorrowerExposureAmount=0;
                Decimal existingOtherExposureAmount=0;
                Decimal currentExposureAmount=0;
                Decimal totalExposureAmount=0;
                List<Lien_Detail__c> lienRecordList = new List<Lien_Detail__c>();
                if(expList.size()>0){
                    Set<ID> expIdSet = new Set<ID>();
                    for (Exposure__c expObj : expList) {
                        if(expObj.Type__c  == System.Label.Borrower_Exposure){ 
                            existingBorrowerExposureAmount =expObj.SOH__c !=null ? existingBorrowerExposureAmount + (Decimal)expObj.SOH__c:existingBorrowerExposureAmount;
                            // currentExposureAmount = existingBorrowerExposureAmount;
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
                currentExposureAmount = finaltermsList.size() > 0 && finaltermsList[0].Loan_amount__c != null ? Decimal.valueOf(finaltermsList[0].Loan_amount__c) : 0;
                for(Applicant__c applicantRecord : [SELECT Id, Name,Applicant_Type__c, Total_Insurance_Payable__c,Cheque_Return_Count__c,Relationship_Since__c From Applicant__c 
                                                    Where Opportunity__c =:loanAppId and In_Active_Applicant__c =false])
                {
                    currentExposureAmount += applicantRecord.Total_Insurance_Payable__c !=null ? (Decimal)applicantRecord.Total_Insurance_Payable__c : 0;
                }
                //CISP-15712 start
                Boolean isCoborrowerRelationMatch = false;
                List<String> relationWithBorrowerList = new List<String>{'BROTHER - IN LAW' , 'BROTHER - INCLUDING STEP BROTHER' , 'DAUGHTER - INCLUDING STEP DAUGHTER' , 'FATHER' , 'GRANDDAUGHTER' , 'GRANDSON' , 'HUSBAND', 'HUSBAND OF GRANDDAUGHTER',
                'HUSBAND OF SISTER' , 'MATERNAL GRANDFATHER' ,'MATERNAL GRANDMOTHER' , 'MEMBER OF HINDU UNDIVIDED FAMILY' , 'MOTHER -INCLUDING STEP MOTHER' , 'PATERNAL GRANDFATHER',
                'PATERNAL GRANDMOTHER', 'SISTER - IN LAW', 'SISTER - INCLUDING STEP SISTER' , 'SON - INCLUDING STEP SON', 'SON WIFE' , 'WIFE' , 'WIFE OF BROTHER' , 'WIFE OF GRANDSON'};
                for(Applicant__c applicantRecord : [SELECT Id,Relationship_with_borrower__c,Applicant_Type__c
                                                From Applicant__c                                                
                                                Where Opportunity__c =:loanAppId and In_Active_Applicant__c =false WITH SECURITY_ENFORCED])
                {
                    //CISP-7987
                    if(applicantRecord.Applicant_Type__c == 'Co-borrower'){
                        if(relationWithBorrowerList.contains(applicantRecord.Relationship_with_borrower__c)){
                            isCoborrowerRelationMatch = true;
                        }
                    }
                }
                if(isCoborrowerRelationMatch == false){
                    existingCoBorrowerExposureAmount = 0;//CISP-7987
                } //CISP-15712 end
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
            ErrorLoggerUtil.logErrorEvent('IND_FicoDeviationRequest', 'getRequestDetails', e.getTypeName(), e, loanAppId);
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
        public string moratoriumDays;
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