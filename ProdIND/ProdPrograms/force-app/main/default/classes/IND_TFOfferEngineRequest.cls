public class IND_TFOfferEngineRequest {
    
    public String Channel; //TRACTOR
    public String VehicleType; //N
    public String Threshold_Net_IRR; //11.5
    public String Tenure; //60
    public String Product; // T
    public String loanDealDate; //2013-09-14
    public String installmentPattern; //Equated
    public String InstallmentFrequency; //MONTHLY
    public String firstEMIdate; //2013-08-14
    public String secondEMIdate; //2013-10-07
    public String moratoriumDays; 
    public String ORP; //674948
    public Object OfferEMI;
    public String offerRunCount;
    public String irr;

    public List<AmortizationSchedule> amortizationSchedule;
    public PayOuts PayOuts;
    public PayIns PayIns;
    public OfferDetails OfferDetails;

    public class AmortizationSchedule {
        public String emiDueDate; //2013-10-07
        public String installmentNumber; //10
        public String installmentAmount; //500.1 
        public String openingPrincipal; //100.2
        public String pricipalComponent; //12
        public String interestComponent; //34.12
        public String closingPrincipal; //355.23
    }

    public class PayOuts {
        public String Referrer_Incentive;
        public String Provision_Cost; //0
        public String Mfr_Incentive_Amount; //0
        public String Gift_Amt; //0
        public String DSM_Incentive2;
        public String DSM_Incentive1; //1500
        public String Dlr_Incentive_Amt_Sub;
        public String Dlr_Incentive_Amt_Main; //13200
        public String Covid_Ins_Prem; //Blank
    }
    
    public class PayIns {
        public String Service_Charges; //2500
        public String Mfr_Exp_Reimbursement_Amount;
        public String Doc_Charges; //4000
        public String Dealer_Exp_Reimbursement_Amount;
        /*public String ORP; //674948
        public Object OfferEMI;*/
    }
    
    public class OfferDetails {
        public String offerTenure; //60
        public String offerLoanAmount; //660000
        public String offerIrr; //10.62
        public String OfferEMI;
    }
        public String Net_IRR_Requested;
        public String Monthly_Income; //1350000
        public String Maker_Id; //128266
        public String LTV_Based_On; //Ex-showroom price
        public String LTV; //65
        public String Lead_Id; //L06112307965_Ba048n00000AZ25J
        public String Imputed_IRR_Requested;
        public String Funded_Insurance; //Blank
        public String Finance_Amount; //660000
        public String Existing_EMI; //0
        public String Ex_Showroom_Price; //674948
        public String CRM_IRR_Requested; //10.62
        public String CallType;  //OFFER
        public String Advance_EMI_Flag; //No
    
    public IND_TFOfferEngineRequest(String loanAppId, String vehicleId, String screenName, RequestWrapper requestWrapper){

        String installMentType = '';
		String installMentFrequency ='';
        String advanceFlag = '';
        Decimal loanAmt;
        Integer orpValueInvoice;
        Integer orpValueDLP;
        Integer orpValue;
        String frequency = '';
        Date repaymentDate = Date.today();
        Decimal loanAmtPlusTotalFundedAmt;
        
        //Get Current Loan Application Record
		Opportunity loanAppRec = [Select Id, Name, Lead_number__c, StageName, Sub_Stage__c, Product_Type__c, Vehicle_Type__c, Requested_loan_amount__c, 
                                    Customer_Type__c From Opportunity Where Id =: loanAppId Limit 1];
        System.debug('+++Offer Eng loanAppRec '+loanAppRec);

        //Get Final Term Record
        List<Final_Term__c> finalTermList = [SELECT Id, First_EMI_Date__c,Second_EMI_Date__c, Holiday_period__c, PricingEngine_thresholdNetrr__c, Structured_L1_Call__c, Tenure__c, Installment_Type__c, Installment_Frequency__c, Rreferrer_Incentive__c, Required_CRM_IRR__c, 
                                            Provisional_Channel_Cost__c, Mfr_incentive__c, Gift_through_dealer_amount__c, DSM_Incentive1__c, DSM_Incentive2__c, Dealer_incentive_amount_main_dealer__c, 
                                            Dealer_incentive_amount_sub_dealer__c, Service_charges__c, Mfr_Exp_Reimburse_Amt__c, Documentation_charges__c, Dlr_Exp_Reimburse_Amt__c, EMI_Amount__c, 
                                            Loan_Amount__c, CRM_IRR__c, LtvEngine_Ltv__c, Inputted_IRR__c, Advance_EMI__c, Loan_Deal_Date__c, Net_Income__c FROM Final_Term__c Where Vehicle_Detail__c =: vehicleId LIMIT 1];
        System.debug('+++Offer Eng finalTermList '+finalTermList);

        //Get all Applicants of current Loan Application
		List<Applicant__c> applicantList = [SELECT Id,CreatedDate, Contact_number__c,Opportunity__r.Lead_number__c,Customer_First_Name__c,Customer_Last_Name__c,Loan_Amount__c,
                                            Current_Same_As_Permanent__c,Is_Existing_Customer__c,Applicant_Type__c,Name, applicant_number__c, Date_of_Birth__c, Declared_income__c,
                                            (Select Id, Name, is_Active__c, Loan_Type__c, EMI__c, Applicant_Id__c From Existing_EMIs__r Where Applicant_Id__r.Applicant_Type__c = 'Borrower') FROM Applicant__c WHERE Opportunity__c =: loanAppId AND In_Active_Applicant__c =false ORDER BY CreatedDate ASC];
        System.debug('+++Offer Eng applicantList '+applicantList);

        //Get all Vehicle Details record of current Loan Application
		List<Vehicle_Detail__c> vehicleDetailList = [SELECT Id, Repayment_Frequency__c, Valuation_price__c,Insurance_declared_value__c, Grid_value__c, Name, Variant_Code__c, Vehicle_type__c, Total_Funded_Amount__c, Deal_Number__c, Invoice_Price__c, Loan_tenure__c, Loan_Amount__c, What_is_thePrice_of_TractorHarvester__c, Required_CRM_IRR__c,Required_Tenure__c From Vehicle_Detail__c where Id =: vehicleId LIMIT 1];
        System.debug('+++Offer Eng vehicleDetailList '+vehicleDetailList);

        List<Documents__c> docLst = [SELECT Id,Proof_of_Identity_POI__c, Proof_of_Address_POA__c, KYC_DOB__c, PAN_No__c, Applicant__c ,KYC_City__c,KYC_Pin_Code__c,KYC_State__c,Addresss_Type__c,Document_Type__c,
                                                KYC_Address_Line_1__c, KYC_Address_Line_2__c, KYC_District__c FROM Documents__c 
                                                WHERE Applicant__c IN (SELECT Id FROM Applicant__c WHERE Opportunity__c =:loanAppId AND Applicant_Type__c = 'Borrower') AND Proof_of_Address_POA__c = true];

        String cfdStateCode = Utilities.getCFDStateCode([SELECT Id,Agent_BL_code__c FROM Opportunity WHERE Id =: loanAppId LIMIT 1].Agent_BL_code__c, 'T');
        List<TBM_Product_Variant_dt__c> dlpMasterList = [SELECT Id, State_Code__c, Product_Variant_Code__c,Dealer_Landed_Price__c, Segment_Grade__c,Unique_State_Code__c FROM TBM_Product_Variant_dt__c Where State_Code__c =: cfdStateCode];
		Map<String,Decimal> dlpMasterMAP = new Map<String,Decimal>();
        
        for(TBM_Product_Variant_dt__c dlpMasterRec: dlpMasterList){
            if(!dlpMasterMAP.containsKey(dlpMasterRec.Product_Variant_Code__c)){
                dlpMasterMAP.put(dlpMasterRec.Product_Variant_Code__c,dlpMasterRec.Dealer_Landed_Price__c);
            }
        }

        Channel = loanAppRec.Product_Type__c.toUppercase();
        VehicleType = loanAppRec.Vehicle_Type__c == 'New' ? 'N': loanAppRec.Vehicle_Type__c == 'Used' ? 'U': loanAppRec.Vehicle_Type__c == 'Refinance' ? 'R' : '';
        Product = loanAppRec.Product_Type__c == 'Tractor' ? 'T' : '';
        
        if(!finalTermList.isEmpty()){

            if(String.isNotBlank(requestWrapper.crmIrrRequested)){
                Threshold_Net_IRR = requestWrapper.crmIrrRequested;
            }else{
                if(loanAppRec.Customer_Type__c == 'Non-Individual'){
                    Threshold_Net_IRR = finalTermList[0].Required_CRM_IRR__c != null ? String.valueOf(finalTermList[0].Required_CRM_IRR__c) : vehicleDetailList[0].Required_CRM_IRR__c != null ? String.valueOf(vehicleDetailList[0].Required_CRM_IRR__c) : '';
                }else if (loanAppRec.Customer_Type__c == 'Individual'){
                    if((loanAppRec.StageName == 'Final Terms')  || (screenName == 'Final Terms')){
                        Threshold_Net_IRR = finalTermList[0].PricingEngine_thresholdNetrr__c != null ? String.valueOf(finalTermList[0].PricingEngine_thresholdNetrr__c) : vehicleDetailList[0].Required_CRM_IRR__c != null ? String.valueOf(vehicleDetailList[0].Required_CRM_IRR__c) : '';
                    }else{
                        Threshold_Net_IRR = finalTermList[0].Required_CRM_IRR__c != null ? String.valueOf(finalTermList[0].Required_CRM_IRR__c) : vehicleDetailList[0].Required_CRM_IRR__c != null ? String.valueOf(vehicleDetailList[0].Required_CRM_IRR__c) : '';
                    }
                }
            }
            irr = String.valueOf(finalTermList[0].Required_CRM_IRR__c);
            Tenure = vehicleDetailList[0].Required_Tenure__c != null ? String.valueOf(vehicleDetailList[0].Required_Tenure__c) : '';
            //loanDealDate = String.valueOf(Date.today());
            installMentType = installmentPattern = finalTermList[0].Installment_Type__c != null ? String.valueOf(finalTermList[0].Installment_Type__c) : '';
            //installmentPattern = installmentPattern == 'Structured' && (loanAppRec.StageName == 'Final Terms' || loanAppRec.StageName == 'Offer Screen') ? 'Equated' : 'Structured';
            if((installMentType == 'Structured' ) && (((loanAppRec.StageName == 'Final Terms' || loanAppRec.StageName == 'Offer Screen' || loanAppRec.StageName == 'Insurance Details' || screenName == 'Insurance Details') && finalTermList[0].Structured_L1_Call__c == false)) || screenName == 'Income Change' || screenName == 'Income Offer' || screenName == 'CAM and Approval Log'){
                installmentPattern = 'Equated';
            }
            installMentFrequency =  this.InstallmentFrequency = finalTermList[0].Installment_Frequency__c != null ? finalTermList[0].Installment_Frequency__c : vehicleDetailList[0].Repayment_Frequency__c != null ? String.valueOf(vehicleDetailList[0].Repayment_Frequency__c) : '';
            
            frequency = installmentFrequency != null && installmentFrequency == 'Monthly' ? frequency = '1' : installmentFrequency == 'bi-monthly' ? frequency = '2' : installmentFrequency == 'Quarterly' ? frequency = '3' : installmentFrequency == 'Half yearly' ? frequency = '6' : '1';
            
            loanDealDate = finalTermList[0].Loan_Deal_Date__c != null ? String.valueOf(finalTermList[0].Loan_Deal_Date__c) : '';
            firstEMIdate = finalTermList[0].First_EMI_Date__c != null ? String.valueOf(finalTermList[0].First_EMI_Date__c) : '';
            secondEMIdate = finalTermList[0].Second_EMI_Date__c != null ? String.valueOf(finalTermList[0].Second_EMI_Date__c) : '';
            
            moratoriumDays = finalTermList!=null && finalTermList.size()>0 ? String.valueOf(finalTermList[0].Holiday_period__c) : '';
            
            PayOuts payOutRec = new PayOuts();
            payOutRec.Referrer_Incentive = finalTermList[0].Rreferrer_Incentive__c != null ? String.valueOf(finalTermList[0].Rreferrer_Incentive__c) : '';
            payOutRec.Provision_Cost = finalTermList[0].Provisional_Channel_Cost__c != null ? String.valueOf(finalTermList[0].Provisional_Channel_Cost__c) : '';
            payOutRec.Mfr_Incentive_Amount = finalTermList[0].Mfr_incentive__c != null ? String.valueOf(finalTermList[0].Mfr_incentive__c) : '';
            payOutRec.Gift_Amt = finalTermList[0].Gift_through_dealer_amount__c != null ? String.valueOf(finalTermList[0].Gift_through_dealer_amount__c) : '';
            payOutRec.DSM_Incentive2 = finalTermList[0].DSM_Incentive2__c != null ? String.valueOf(finalTermList[0].DSM_Incentive2__c) : '';
            payOutRec.DSM_Incentive1 = finalTermList[0].DSM_Incentive1__c != null ? String.valueOf(finalTermList[0].DSM_Incentive1__c) : '';
            payOutRec.Dlr_Incentive_Amt_Sub = finalTermList[0].Dealer_incentive_amount_sub_dealer__c != null ? String.valueOf(finalTermList[0].Dealer_incentive_amount_sub_dealer__c) : '';
            payOutRec.Dlr_Incentive_Amt_Main = finalTermList[0].Dealer_incentive_amount_main_dealer__c != null ? String.valueOf(finalTermList[0].Dealer_incentive_amount_main_dealer__c) : '';
            payOutRec.Covid_Ins_Prem = '';
            payOuts = payOutRec;

            PayIns payInsRec = new PayIns();
            payInsRec.Service_Charges = finalTermList[0].Service_charges__c != null ? String.valueOf(finalTermList[0].Service_charges__c) : '';
            payInsRec.Mfr_Exp_Reimbursement_Amount = finalTermList[0].Mfr_Exp_Reimburse_Amt__c != null ? String.valueOf(finalTermList[0].Mfr_Exp_Reimburse_Amt__c) : '';
            payInsRec.Doc_Charges = finalTermList[0].Documentation_charges__c != null ? String.valueOf(finalTermList[0].Documentation_charges__c) : '';
            payInsRec.Dealer_Exp_Reimbursement_Amount = finalTermList[0].Dlr_Exp_Reimburse_Amt__c != null ? String.valueOf(finalTermList[0].Dlr_Exp_Reimburse_Amt__c) : '';
            payIns = payInsRec;

            if(loanAppRec.Vehicle_Type__c == 'New'){
                orpValueInvoice = vehicleDetailList[0].Invoice_Price__c != null ? Integer.valueOf(vehicleDetailList[0].Invoice_Price__c) : 0;
                orpValueDLP = (dlpMasterMAP != null && vehicleDetailList[0].Variant_Code__c != null && dlpMasterMAP.containsKey(vehicleDetailList[0].Variant_Code__c)) ? Integer.valueOf(dlpMasterMAP.get(vehicleDetailList[0].Variant_Code__c)) : 0;
                Integer minOrpValue = 999999999; // Set initial max to the maximum possible integer value
                if (orpValueInvoice > 0) minOrpValue = Math.min(minOrpValue, orpValueInvoice);
                if (orpValueDLP > 0) minOrpValue = Math.min(minOrpValue, orpValueDLP);
                orpValue = minOrpValue;
            }else{
                Decimal valuationPriceDecimal = vehicleDetailList[0].Valuation_price__c != null ? (vehicleDetailList[0].Valuation_price__c).setScale(0) : 0.0;
                Decimal insuranceDeclaredDecimal = vehicleDetailList[0].Insurance_declared_value__c != null ? (vehicleDetailList[0].Insurance_declared_value__c).setScale(0) : 0.0;
                Decimal gridValueDecimal = vehicleDetailList[0].Grid_value__c != null ? (vehicleDetailList[0].Grid_value__c).setScale(0): 0.0;
                System.debug('+++++DECIMAL valuationPriceDecimal '+valuationPriceDecimal+' insuranceDeclaredDecimal '+insuranceDeclaredDecimal+' gridValueDecimal '+gridValueDecimal);
                Decimal minOrpValueUR = 999999999;
                if (valuationPriceDecimal > 0) minOrpValueUR = Math.min(minOrpValueUR, valuationPriceDecimal);
                if (insuranceDeclaredDecimal > 0) minOrpValueUR = Math.min(minOrpValueUR, insuranceDeclaredDecimal);
                if (gridValueDecimal > 0) minOrpValueUR = Math.min(minOrpValueUR, gridValueDecimal);

                orpValue = minOrpValueUR.intValue();
                System.debug('+++++orpValue ' + orpValue);
            }
            
            ORP = String.valueOf(orpValue); 
            OfferEMI = finalTermList[0].EMI_Amount__c != null ? String.valueOf(finalTermList[0].EMI_Amount__c) : '';

            OfferDetails offerDetailRec = new OfferDetails();
            offerDetailRec.offerTenure = '';
            loanAmt = finalTermList[0].Loan_Amount__c != null ? Integer.valueOf(finalTermList[0].Loan_Amount__c) : vehicleDetailList[0].Loan_Amount__c != null ? Integer.valueOf(vehicleDetailList[0].Loan_Amount__c) : 0;
            Decimal TotalFundedAmt = vehicleDetailList[0].Total_Funded_Amount__c != null ? Integer.valueOf(vehicleDetailList[0].Total_Funded_Amount__c) : 0;
            loanAmtPlusTotalFundedAmt = loanAmt + TotalFundedAmt;
            offerDetailRec.offerLoanAmount = '';
            offerDetailRec.offerIrr = '';
            offerDetailRec.OfferEMI = '';
            offerDetails = offerDetailRec;

            Net_IRR_Requested = '';
            Decimal loanAmount = finalTermList[0].Loan_Amount__c != null ? Integer.valueOf(finalTermList[0].Loan_Amount__c) : vehicleDetailList[0].Loan_Amount__c != null ? vehicleDetailList[0].Loan_Amount__c : 0;
            
            if(loanAppRec.Customer_Type__c == 'Non-Individual'){
                if(loanAppRec.Vehicle_Type__c == 'New'){
                    //LTV = vehicleDetailList[0].Invoice_Price__c != null && loanAmount != null && vehicleDetailList[0].Invoice_Price__c != 0 ? String.valueOf((loanAmount / Integer.valueOf(vehicleDetailList[0].Invoice_Price__c)*100).setScale(0)) : '';
                    LTV = orpValue != null && loanAmount != null && orpValue != 0 ? String.valueOf(((loanAmount / orpValue)*100).setScale(0)) : '';//SFTRAC-1394
                }else{
                    Decimal valuationPriceDecimal = vehicleDetailList[0].Valuation_price__c != null ? (vehicleDetailList[0].Valuation_price__c).setScale(0) : 0.0;
                    Decimal insuranceDeclaredDecimal = vehicleDetailList[0].Insurance_declared_value__c != null ? (vehicleDetailList[0].Insurance_declared_value__c).setScale(0) : 0.0;
                    Decimal gridValueDecimal = vehicleDetailList[0].Grid_value__c != null ? (vehicleDetailList[0].Grid_value__c).setScale(0): 0.0;
                    System.debug('+++++DECIMAL valuationPriceDecimal LTV '+valuationPriceDecimal+' insuranceDeclaredDecimal '+insuranceDeclaredDecimal+' gridValueDecimal '+gridValueDecimal);
                    Decimal minvalueUR = 999999999;
                    if (valuationPriceDecimal > 0) minvalueUR = Math.min(minvalueUR, valuationPriceDecimal);
                    if (insuranceDeclaredDecimal > 0) minvalueUR = Math.min(minvalueUR, insuranceDeclaredDecimal);
                    if (gridValueDecimal > 0) minvalueUR = Math.min(minvalueUR, gridValueDecimal);
                    LTV = loanAmount != null ? String.valueOf((loanAmount / Integer.valueOf(minvalueUR)*100).setScale(0)) : '';
                }
                
            }else if (loanAppRec.Customer_Type__c == 'Individual'){
                LTV = finalTermList[0].LtvEngine_Ltv__c != null ? String.valueOf(finalTermList[0].LtvEngine_Ltv__c) : '';
            }
            
            Imputed_IRR_Requested = '';         
            CRM_IRR_Requested = '';
            advanceFlag = finalTermList[0].Advance_EMI__c != null ? String.valueOf(finalTermList[0].Advance_EMI__c) : '';
            Advance_EMI_Flag = advanceFlag == 'false' ? 'No' : 'Yes';
        }

        List<Structered_EMI__c> structuredRecList = [SELECT Id, Name, EMI_Amount__c, From_Month__c, Number_of_Installments__c, To_Month__c, Deal_Number__c, 
                                                    Loan_Application__c FROM Structered_EMI__c Where Loan_Application__c =:loanAppId AND Deal_Number__c =: vehicleDetailList[0].Deal_Number__c];
        
        Integer monitoriumDaysValue = finalTermList[0].Holiday_period__c != null ? Integer.valueof(finalTermList[0].Holiday_period__c) : 0; 
        repaymentDate = repaymentDate.addDays(monitoriumDaysValue);
        repaymentDate = (repaymentDate.day() >= 15) ? Date.newInstance(repaymentDate.year(), repaymentDate.month(), 15) : Date.newInstance(repaymentDate.year(), repaymentDate.month(), 7);
        List<AmortizationSchedule> amortizationScheduleList = new List<AmortizationSchedule>(); //Aakash to update Mapping
        //Below lines will run only for Installment Type = Structured
        List<Integer> monthlyEMIs = StruturedEMICal.calculateMonthlyEMI(loanAppId,vehicleId);
        
        if(installmentPattern == 'Structured' && ((loanAppRec.StageName != 'Final Terms' && loanAppRec.StageName != 'Offer Screen' && finalTermList[0].Structured_L1_Call__c == true) || (screenName == 'EMI Details')  || (screenName == 'Disbursement Request Preparation'))){
            if(monthlyEMIs.size()>0){
                List<EMI_CalculatorController.RepaymentWrapper> calcList = EMI_CalculatorController.gradedRepaymentSchedule(monthlyEMIs, Integer.valueOf(loanAmtPlusTotalFundedAmt),irr, finalTermList[0].Loan_Deal_Date__c, Integer.valueOf((finalTermList[0].Tenure__c != null && finalTermList[0].Tenure__c != '0') ? String.valueOf(finalTermList[0].Tenure__c) : vehicleDetailList[0].Loan_tenure__c != null ? String.valueOf(vehicleDetailList[0].Loan_tenure__c) : ''), 0, frequency, repaymentDate, finalTermList[0].Second_EMI_Date__c);
                for(Integer i = 0; i < calcList.size(); i++){
                    EMI_CalculatorController.RepaymentWrapper repayWrapper = calcList[i];
                     //for (EMI_CalculatorController.RepaymentWrapper repayWrapper: calcList) {
                    AmortizationSchedule amortizationScheduleRec = new AmortizationSchedule();
                    amortizationScheduleRec.emiDueDate = String.valueOf(repayWrapper.dueDate); //Aakash CHECK with Ganesh
                    amortizationScheduleRec.installmentNumber = String.valueOf(repayWrapper.instalmentNo);
                    amortizationScheduleRec.installmentAmount = String.valueOf(repayWrapper.instalmentAmount);
                    //amortizationScheduleRec.installmentAmount = String.valueOf(monthlyEMIs[i]);
                    amortizationScheduleRec.openingPrincipal = String.valueOf(repayWrapper.openingPrinciple);
                    amortizationScheduleRec.interestComponent = String.valueOf(repayWrapper.interestComp); // Aakash check logic in sheet and update (Client's ROI/Customer Rate / 365 ) * (loanDealDate - Due Month[From_Month__c]) * irrValue
                    amortizationScheduleRec.pricipalComponent = String.valueOf(repayWrapper.principalComp); // Aakash check logic in sheet and update ** amortizationScheduleRec.installmentAmount - amortizationScheduleRec.interestComponent**
                    amortizationScheduleRec.closingPrincipal = String.valueOf(repayWrapper.closingPrinciple);// Aakash check logic in sheet and update ** amortizationScheduleRec.openingPrincipal - amortizationScheduleRec.pricipalComponent **
                    amortizationScheduleList.add(amortizationScheduleRec);
                }
            }
        }
        amortizationSchedule = amortizationScheduleList;


        Maker_Id = '';
        LTV_Based_On = '';
        Funded_Insurance = ''; //Send blank
        Ex_Showroom_Price = '';  //Send blank

        if((loanAppRec.StageName == 'Final Terms') || (screenName == 'Final Terms')){
            CallType = 'OFFER';
            offerRunCount = '0';
            Finance_Amount = '';
        }else if((loanAppRec.StageName == 'Offer Screen')  || (screenName == 'Offer Screen')){
            CallType = 'OFFER';
            offerRunCount = '1';
            Finance_Amount = String.valueOf(loanAmt);
        }else if ((loanAppRec.StageName == 'Insurance Details')  || (screenName == 'Insurance Details')){
            CallType = 'INSURANCE';
            offerRunCount = '';
            Finance_Amount = String.valueOf(loanAmtPlusTotalFundedAmt);
        }else if((loanAppRec.StageName == 'Credit Processing' && loanAppRec.Sub_Stage__c == 'Final Terms') || (screenName == 'Final Terms')){
            CallType = 'OFFER';
            offerRunCount = '0';
            Finance_Amount = '';
            //Finance_Amount = String.valueOf(loanAmt);
        }else if((screenName == 'Income Change')){
            CallType = 'OFFER';
            offerRunCount = '0';
            Finance_Amount = '';
            /*if(String.isNotBlank(requestWrapper.loanAmount)){
                Finance_Amount = requestWrapper.loanAmount;
            }else{
                Finance_Amount = String.valueOf(loanAmtPlusTotalFundedAmt);
            }*/
        }else if((screenName == 'Income Offer')){
            CallType = 'OFFER';
            offerRunCount = '1';
            if(String.isNotBlank(requestWrapper.loanAmount)){
                Finance_Amount = requestWrapper.loanAmount;
            }else{
                Finance_Amount = String.valueOf(loanAmtPlusTotalFundedAmt);
            }
        }else if((loanAppRec.StageName == 'Credit Processing' && loanAppRec.Sub_Stage__c == 'CAM and Approval Log') || (screenName == 'CAM and Approval Log')){
            CallType = 'CAM';
            offerRunCount = '';
            Finance_Amount = String.valueOf(loanAmtPlusTotalFundedAmt);
        }else if(screenName == 'CIBIL'){
            CallType = 'CAM';
            offerRunCount = '';
            Finance_Amount = String.valueOf(loanAmtPlusTotalFundedAmt);
        }else if(screenName == 'EMI Details'){
            CallType = 'INSURANCE';
            offerRunCount = '';
            Finance_Amount = String.valueOf(loanAmtPlusTotalFundedAmt);
        }else if((screenName == 'Disbursement Request Preparation')){   //SFTRAC-1896 start
            CallType = 'CAM';
            offerRunCount = '';
            Finance_Amount = String.valueOf(loanAmtPlusTotalFundedAmt);
        }//SFTRAC-1896 end
        //Applicant related value assignment to Request body
        Decimal totalApplicantsDeclaredIncome = 0;
        String borrowerApplicantNumber = '';
        Decimal existingEMI = 0;
        for(Applicant__c appRec: applicantList){
            totalApplicantsDeclaredIncome += appRec.Declared_income__c != null ? appRec.Declared_income__c : 0;
            if(appRec.Applicant_Type__c == 'Borrower' && loanAppRec.Customer_Type__c == 'Individual'){
                borrowerApplicantNumber =  String.valueOf(appRec.applicant_number__c) ;
            }else if(appRec.Applicant_Type__c == 'Beneficiary' && loanAppRec.Customer_Type__c == 'Non-Individual' && borrowerApplicantNumber == ''){
                borrowerApplicantNumber =  String.valueOf(appRec.applicant_number__c) ;
            }
            for(Existing_EMI__c emiRec: appRec.Existing_EMIs__r){
                existingEMI += emiRec.EMI__c != null ? emiRec.EMI__c : 0;
            }
        }

        if(loanAppRec.Customer_Type__c == 'Non-Individual'){
            Monthly_Income = String.valueOf(totalApplicantsDeclaredIncome); 
        }else if (loanAppRec.Customer_Type__c == 'Individual'){
            Monthly_Income = finalTermList[0].Net_Income__c != null ? String.valueOf(finalTermList[0].Net_Income__c) : '';
        }

        Lead_Id = loanAppRec.Lead_number__c+'_'+borrowerApplicantNumber;
        Existing_EMI = String.valueOf(existingEMI); 
    }
    
}