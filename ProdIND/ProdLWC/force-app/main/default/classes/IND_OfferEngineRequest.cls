/*------------------------------------------------------------
Author: Satyam More
Company: Persistent Systems
Description: This class is wrapper class for the Offer Engine request
Test Class: 
History
Date            Author              Comments
------------------------------------------------------------- 
28-12-2021    Satyam More            Created
------------------------------------------------------------*/

public class IND_OfferEngineRequest extends ParentAPIRequest {
    //request paramaters for PAN Verification request 
    public String Lead_Id {get;set;}
    public String Maker_Id {get;set;}
    public String Product {get;set;}
    public String VehicleType {get;set;}
    public String CallType {get;set;}
    public String Advance_EMI_Flag {get;set;}
    public String Threshold_Net_IRR {get;set;}
    public String LTV {get;set;}
    public String Finance_Amount {get;set;}
    public String Tenure {get;set;}
    public String LTV_Based_On {get;set;}
    public String CRM_IRR_Requested {get;set;}
    public String Monthly_Income {get;set;}
    public String Existing_EMI {get;set;}
    public String Ex_Showroom_Price {get;set;}
    public String ORP {get;set;}
    public String Funded_Insurance {get;set;}
    public String Net_IRR_Requested {get;set;}
    public String Imputed_IRR_Requested {get;set;}   
    public String OfferEMI {get;set;}//CISP-2408 
    public PayOuts PayOuts {get;set;}
    public PayIns PayIns {get;set;}
    public OfferDetails OfferDetails {get;set;}
    public String loanDealDate {get;set;}
    public String installmentPattern {get;set;}
    public String firstEMIdate {get;set;}
    public String secondEMIdate {get;set;}
    public String rentObligation {get;set;}
    public String otherObligation {get;set;}
    public List<AmortizationSchedule> amortizationSchedule {get;set;}
    public String purposeOfPurchase {get;set;}
    public class AmortizationSchedule {
        public String emiDueDate{get;set;}
        public String installmentNumber{get;set;}
        public String installmentAmount{get;set;}
        public String openingPrincipal{get;set;}
        public String pricipalComponent{get;set;}
        public String interestComponent{get;set;}
        public String closingPrincipal{get;set;}
    }

    
    public class PayIns {
        public String Doc_Charges {get;set;}
        public String Service_Charges {get;set;}
        public String Mfr_Exp_Reimbursement_Amount {get;set;}
        public String Dealer_Exp_Reimbursement_Amount {get;set;}
    }
    
    public class PayOuts {
        public String Provision_Cost {get;set;}
        public String Dlr_Incentive_Amt_Main {get;set;}
        public String Dlr_Incentive_Amt_Sub {get;set;}
        public String Mfr_Incentive_Amount {get;set;}
        public String Referrer_Incentive {get;set;}
        public String Gift_Amt {get;set;}
        public String DSM_Incentive1 {get;set;}
        public String DSM_Incentive2 {get;set;}
        public String Covid_Ins_Prem {get;set;}
    }
    
    public class OfferDetails {
        public String offerLoanAmount {get;set;}
        public String offerTenure {get;set;}
        public String offerIrr {get;set;}
        public String OfferEMI {get;set;}//INDI-4682
    }
    
    //constructor
    // @Method:      IND_OfferEngineRequest
    // @Created by:  Satyam More
    // @Description: Contructor to initialize the details
    // @Param:       Object Request Wrapper
    // @Return:      ''
    
    public IND_OfferEngineRequest(RequestWrapper requestWrapper,List<Final_Term__c> finalTerm){

        List<Vehicle_Detail__c> VehicleDtlList = [SELECT id, Base_Prices__c, Loan_Application__r.Total_Funded_Premium__c, Loan_Application__r.LeadSource,Purpose_of_Purchase__c
                                                  FROM Vehicle_Detail__c 
                                                  WHERE Loan_Application__c =: requestWrapper.loanApplicationId 
                                                  WITH SECURITY_ENFORCED];
        List<Applicant__c> appList = [SELECT Id,Other_Obligation__c,Rental_Expense__c,Applicant_type__c FROM Applicant__c WHERE Opportunity__c  =: requestWrapper.loanApplicationId AND In_Active_Applicant__c =false WITH SECURITY_ENFORCED];
        this.PayOuts = new PayOuts();
        this.PayIns = new PayIns();
        this.OfferDetails = new OfferDetails();           
        this.Lead_Id=  requestWrapper.leadId==null?'':requestWrapper.leadId+'_'+requestWrapper.borrowerApplicantNumber; 
        this.Maker_Id = IntegrationUtilities.getMakerId();
        if (!VehicleDtlList.isEmpty()) {
          this.purposeOfPurchase = VehicleDtlList[0].Purpose_of_Purchase__c;
        } else {
          this.purposeOfPurchase = '';  
         } 
        this.Product = requestWrapper.product == 'Passenger Vehicles'?'PV' : requestWrapper.product == 'Two Wheeler'?'TW' :'' ;   
        this.VehicleType = requestWrapper.vehicleType == 'New'?'N' : requestWrapper.vehicleType == 'Used' ?'U' : requestWrapper.vehicleType == 'Refinance' ?'R' : '';
        this.installmentPattern = finalTerm[0].Installment_Type__c;
        this.rentObligation='';
        this.otherObligation='';
        this.firstEMIdate = finalTerm[0].First_EMI_Date__c!=null ? String.valueOf(finalTerm[0].First_EMI_Date__c) : '';
        this.secondEMIdate = finalTerm[0].Second_EMI_Date__c!=null ? String.valueOf(finalTerm[0].Second_EMI_Date__c) : '';
        if(requestWrapper.stageName == 'Disbursement Request Preparation' || requestWrapper.stageName == 'Post Sanction Checks and Documentation'){ // CISP-20786
            this.loanDealDate = finalTerm[0].Loan_Deal_Date__c!=null ? String.valueOf(finalTerm[0].Loan_Deal_Date__c) : '';
        }else{
            this.loanDealDate = String.valueOf(Date.Today());
        }
        List<AmortizationSchedule> amortizationScheduleList = new List<AmortizationSchedule>();
        if(this.Product == 'PV' && finalTerm[0].Installment_Type__c == 'Structured'){
            List<Integer> monthlyEMIs = StruturedEMICal.calculateMonthlyEMI(requestWrapper.loanApplicationId,null);
            if(monthlyEMIs.size()>0){
                System.debug('from method'+ monthlyEMIs);
                Date repaymentDate = Date.today();
                Integer monitoriumDaysValue = finalTerm[0].Holiday_period__c != null ? Integer.valueof(finalTerm[0].Holiday_period__c) : 0; 
                repaymentDate = repaymentDate.addDays(monitoriumDaysValue);
                List<InstallmentScheduleController.RepaymentWrapper> calcList = InstallmentScheduleController.structuredEMIRepaymentSchedule(monthlyEMIs, Integer.valueOf(finalTerm[0].Loan_Amount__c)+VehicleDtlList[0].Loan_Application__r.Total_Funded_Premium__c,String.valueOf(finalTerm[0].CRM_IRR__c), finalTerm[0].Loan_Deal_Date__c==null? Date.Today(): finalTerm[0].Loan_Deal_Date__c, Integer.valueOf(finalTerm[0].Tenure__c), 0, '1', finalTerm[0].First_EMI_Date__c,finalTerm[0].Second_EMI_Date__c,finalTerm[0].Advance_EMI__c,requestWrapper.loanApplicationId);
                for (InstallmentScheduleController.RepaymentWrapper repayWrapper: calcList) {
                    AmortizationSchedule amortizationScheduleRec = new AmortizationSchedule();
                    amortizationScheduleRec.emiDueDate = String.valueOf(repayWrapper.dueDate);
                    amortizationScheduleRec.installmentNumber = String.valueOf(repayWrapper.instalmentNo);
                    amortizationScheduleRec.installmentAmount = String.valueOf(repayWrapper.instalmentAmount);
                    amortizationScheduleRec.openingPrincipal = String.valueOf(repayWrapper.openingPrinciple);
                    amortizationScheduleRec.interestComponent = String.valueOf(repayWrapper.interestComp);
                    amortizationScheduleRec.pricipalComponent = String.valueOf(repayWrapper.principalComp);
                    amortizationScheduleRec.closingPrincipal = String.valueOf(repayWrapper.closingPrinciple);
                    amortizationScheduleList.add(amortizationScheduleRec);
                }
            }
        }
        this.amortizationSchedule = amortizationScheduleList;
        // start CISP-2415
        Boolean passOfferEmi = false;// CISP-2408
        if(requestWrapper.currentScreen=='Offer' || requestWrapper.currentScreen=='Eligibility engine' || requestWrapper.currentScreen=='Final terms'){
            if(this.VehicleType =='N'){
                this.CallType = 'OFFER';       
            }
            else if(this.VehicleType =='U'){
                this.CallType = 'OFFER_U';
            }
            else if(this.VehicleType =='R'){
                this.CallType = 'OFFER_R';       
            }
        }// start CISP-2415
        else if(requestWrapper.currentScreen=='Final Offer' || requestWrapper.currentScreen=='Offer screen changed'){
            if(this.Product=='PV'){
              this.CallType = 'Input_Net_IRR';   
            }
            else if(this.Product=='TW'){
              this.CallType = 'Input_Imputed_IRR';   
              passOfferEmi = true;// CISP-2408
            }
                  
        }
        else if(requestWrapper.currentScreen=='CAM and Approval Log'){
            this.CallType = 'Input_CRM_IRR';
            this.Advance_EMI_Flag = finalTerm[0].Advance_EMI__c==false?'No':'Yes';
            Decimal totalFundedInsurancePremium = VehicleDtlList[0].Loan_Application__r.Total_Funded_Premium__c != null ? VehicleDtlList[0].Loan_Application__r.Total_Funded_Premium__c : 0;
            Decimal financeAmount = Decimal.valueOf(finalTerm[0].Loan_Amount__c);
            if(String.isNotBlank(requestWrapper.loanAmountChanged)){
                this.Finance_Amount = requestWrapper.loanAmountChanged;
            }else{
                this.Finance_Amount = finalTerm[0].Loan_Amount__c != null ? String.valueOf(financeAmount + totalFundedInsurancePremium) : '';
            }
            this.Tenure = finalTerm[0].Tenure__c != null ? finalTerm[0].Tenure__c : '';
            if (this.Product == 'TW') {   
                this.Imputed_IRR_Requested = finalTerm.size() > 0 ? String.valueOf(finalTerm[0].Inputted_IRR__c) :'';
            } else if(this.Product == 'PV'){
                this.Net_IRR_Requested = finalTerm.size() > 0 ? finalTerm[0].Net_IRR_Decimal__c != null ? String.valueOf(finalTerm[0].Net_IRR_Decimal__c) : String.valueOf(finalTerm[0].Net_IRR__c) :'';   
            }
            // CISP-124
            if(requestWrapper.provisionAmount != null  && requestWrapper.provisionAmount != ''){
                this.PayOuts.Provision_Cost = requestWrapper.provisionAmount;
            }else{
                this.PayOuts.Provision_Cost = finalTerm[0].Provisional_Channel_Cost__c==null?'':finalTerm[0].Provisional_Channel_Cost__c;
            }
            // CISP-124
            this.PayOuts.Dlr_Incentive_Amt_Main = finalTerm[0].Dealer_incentive_amount_main_dealer__c==null?'':finalTerm[0].Dealer_incentive_amount_main_dealer__c;
            this.PayOuts.Dlr_Incentive_Amt_Sub = finalTerm[0].Dealer_incentive_amount_sub_dealer__c==null?'':finalTerm[0].Dealer_incentive_amount_sub_dealer__c;
            this.PayOuts.Mfr_Incentive_Amount = finalTerm[0].Mfr_incentive__c==null?'':finalTerm[0].Mfr_incentive__c;
            this.PayOuts.Referrer_Incentive = finalTerm[0].Rreferrer_Incentive__c==null?'':finalTerm[0].Rreferrer_Incentive__c;
            this.PayOuts.Gift_Amt = finalTerm[0].Gift_through_dealer_amount__c==null?'':finalTerm[0].Gift_through_dealer_amount__c;
            this.PayOuts.DSM_Incentive1 = finalTerm[0].DSM_Incentive1__c==null?'':finalTerm[0].DSM_Incentive1__c;
            this.PayOuts.DSM_Incentive2 = finalTerm[0].DSM_Incentive2__c==null?'':finalTerm[0].DSM_Incentive2__c;
            this.PayOuts.Covid_Ins_Prem = '';
            this.PayIns.Doc_Charges = finalTerm[0].Documentation_charges__c==null?'':finalTerm[0].Documentation_charges__c;
            this.PayIns.Service_Charges =  finalTerm[0].Service_charges__c==null?'':finalTerm[0].Service_charges__c;
            this.PayIns.Mfr_Exp_Reimbursement_Amount = finalTerm[0].Mfr_Exp_Reimburse_Amt__c==null?'':finalTerm[0].Mfr_Exp_Reimburse_Amt__c;
            this.PayIns.Dealer_Exp_Reimbursement_Amount = finalTerm[0].Dlr_Exp_Reimburse_Amt__c==null?'':finalTerm[0].Dlr_Exp_Reimburse_Amt__c;
            this.OfferDetails.offerLoanAmount = '';
            this.OfferDetails.offerTenure = '';
            this.OfferDetails.offerIrr = '';
        }
        else {
            this.CallType = '';   
        }

        if(this.Product == 'TW' && requestWrapper.offerEMI !=null && passOfferEmi == false){ //Start CISP-2361 // CISP-2408
            this.OfferDetails.OfferEMI = requestWrapper.offerEMI;
        }
        else{
            this.OfferDetails.OfferEMI = '';
        } //End CISP-2361
        
        //calltype 1 product PV
        if (this.Product == 'PV' && this.CallType == 'OFFER' ){
            Decimal rentObligationDec = 0;
            Decimal otherObligationDec = 0;
            for(Applicant__c app : appList){
                rentObligationDec = app.Rental_Expense__c!=null ?  rentObligationDec+app.Rental_Expense__c.setScale(0) : rentObligationDec+0;
                otherObligationDec = app.Other_Obligation__c!=null ?  otherObligationDec+app.Other_Obligation__c.setScale(0) : otherObligationDec+0;
            }
            this.rentObligation=String.valueOf(rentObligationDec);
            this.otherObligation=String.valueOf(otherObligationDec);
            if(requestWrapper.advanceEmiFlag!=null){
                 this.Advance_EMI_Flag=requestWrapper.advanceEmiFlag;
            }
            else{
                this.Advance_EMI_Flag = finalTerm[0].Advance_EMI__c==false?'No':'Yes';
            } 
            this.Threshold_Net_IRR = requestWrapper.thresholdNetIRR == null ? String.valueOf(finalTerm[0].PricingEngine_thresholdNetrr__c) : requestWrapper.thresholdNetIRR;
            this.LTV = finalTerm[0].LtvEngine_Ltv__c==null?'':String.valueOf(finalTerm[0].LtvEngine_Ltv__c);
                if(requestWrapper.loanAmountChanged!=null){
                this.Finance_Amount =String.valueOf((Integer.valueOf(requestWrapper.loanAmountChanged))+ Integer.valueOf(requestWrapper.sumOfFundedInsurance));
            }
            else{
                this.Finance_Amount =finalTerm[0].Loan_Amount__c==null?String.valueOf((Integer.valueOf(requestWrapper.loanAmount))+ Integer.valueOf(requestWrapper.sumOfFundedInsurance))
                :String.valueOf((Integer.valueOf(finalTerm[0].Loan_Amount__c))+ Integer.valueOf(requestWrapper.sumOfFundedInsurance));
            }
            //we implement the if condition because when we move from offer screen to final term by clicking Pay PayOut,
            //than we need fetch value from final term Object (which we change in Offer Screen).
            if(finalTerm[0].Tenure__c !=null){
                this.Tenure =requestWrapper.tenureChanged==null? finalTerm[0].Tenure__c:requestWrapper.tenureChanged;
            }
            else{
                this.Tenure =requestWrapper.tenureChanged==null? requestWrapper.tenure:requestWrapper.tenureChanged; 
            }
            //we implement the if condition because when we move from offer screen to final term by clicking Pay PayOut,
            //than we need fetch value from final term Object (which we change in Offer Screen).
            if(finalTerm[0].Required_CRM_IRR__c !=null){
                if (this.Product == 'TW') {//Start CISP-2364
                    this.CRM_IRR_Requested = finalTerm[0].Required_CRM_IRR__c;
                } else {
                    this.CRM_IRR_Requested = requestWrapper.crmIrrChanged==null?finalTerm[0].Required_CRM_IRR__c:requestWrapper.crmIrrChanged;
                }//End CISP-2364
            }
            else{
                this.CRM_IRR_Requested = requestWrapper.crmIrrChanged==null?requestWrapper.crmIrrRequested:requestWrapper.crmIrrChanged;
            }
            this.LTV_Based_On =requestWrapper.fundingOnExShowroom=='true'?'Ex-showroom price':requestWrapper.fundingOnORP=='true'?'Onroad price':'';
            this.Monthly_Income= requestWrapper.income==null?'':requestWrapper.income;
            this.Existing_EMI = requestWrapper.emi==null?'':requestWrapper.emi;
            this.Ex_Showroom_Price = requestWrapper.exShowroomPrice==null?'':requestWrapper.exShowroomPrice;
            this.ORP =requestWrapper.onRoadPrice==null?'':requestWrapper.onRoadPrice;
            this.Funded_Insurance = requestWrapper.sumOfFundedInsurance;
            
            this.PayIns.Doc_Charges = finalTerm[0].Documentation_charges__c==null?'':finalTerm[0].Documentation_charges__c;
            this.PayIns.Service_Charges =  finalTerm[0].Service_charges__c==null?'':finalTerm[0].Service_charges__c;
            this.PayIns.Mfr_Exp_Reimbursement_Amount =  finalTerm[0].Mfr_Exp_Reimburse_Amt__c==null?'':finalTerm[0].Mfr_Exp_Reimburse_Amt__c;
            this.PayIns.Dealer_Exp_Reimbursement_Amount =  finalTerm[0].Dlr_Exp_Reimburse_Amt__c==null?'':finalTerm[0].Dlr_Exp_Reimburse_Amt__c;
            
            // CISP-124
            if(requestWrapper.provisionAmount != null  && requestWrapper.provisionAmount != ''){
                this.PayOuts.Provision_Cost = requestWrapper.provisionAmount;
            }else{
                this.PayOuts.Provision_Cost = finalTerm[0].Provisional_Channel_Cost__c==null?'':finalTerm[0].Provisional_Channel_Cost__c;
            }
            // CISP-124
            this.PayOuts.Dlr_Incentive_Amt_Main = finalTerm[0].Dealer_incentive_amount_main_dealer__c==null?'':finalTerm[0].Dealer_incentive_amount_main_dealer__c;
            this.PayOuts.Dlr_Incentive_Amt_Sub = finalTerm[0].Dealer_incentive_amount_sub_dealer__c==null?'':finalTerm[0].Dealer_incentive_amount_sub_dealer__c;
            this.PayOuts.Mfr_Incentive_Amount = finalTerm[0].Mfr_incentive__c==null?'':finalTerm[0].Mfr_incentive__c;
            this.PayOuts.Referrer_Incentive = finalTerm[0].Rreferrer_Incentive__c==null?'':finalTerm[0].Rreferrer_Incentive__c;
            this.PayOuts.Gift_Amt = finalTerm[0].Gift_through_dealer_amount__c==null?'':finalTerm[0].Gift_through_dealer_amount__c;
            this.PayOuts.DSM_Incentive1 = finalTerm[0].DSM_Incentive1__c==null?'':finalTerm[0].DSM_Incentive1__c;
            this.PayOuts.DSM_Incentive2 = finalTerm[0].DSM_Incentive2__c==null?'':finalTerm[0].DSM_Incentive2__c;
            this.PayOuts.Covid_Ins_Prem = '';
            //if(Integer.valueOf(this.Finance_Amount) <= Integer.valueOf(finalTerm[0].OfferengineMaxLoanAmount__c)  && 
               //Integer.valueOf(this.Finance_Amount) >= Integer.valueOf(finalTerm[0].OfferengineMinLoanAmount__c) &&
               //requestWrapper.currentScreen=='Final terms' && !finalTerm[0].isNavigate__c){   
                   //this.OfferDetails.offerLoanAmount ='';
                   //this.OfferDetails.offerTenure= '';   
                  //this.OfferDetails.offerIrr ='';     
              // }
           // else{Commented this code regarding for this ticket CISP-6058
            if(requestWrapper.loanAmountChanged!=null){
                this.OfferDetails.offerLoanAmount = String.valueOf((Integer.valueOf(requestWrapper.loanAmountChanged))+ Integer.valueOf(requestWrapper.sumOfFundedInsurance));
            }
            else{
                this.OfferDetails.offerLoanAmount =finalTerm[0].Loan_Amount__c!=null?String.valueOf((Integer.valueOf(finalTerm[0].Loan_Amount__c)+ Integer.valueOf(requestWrapper.sumOfFundedInsurance))):'';
            }
            if(finalTerm[0].Tenure__c !=null){
                this.OfferDetails.offerTenure =requestWrapper.tenureChanged==null? finalTerm[0].Tenure__c:requestWrapper.tenureChanged;
            }
            else{
                this.OfferDetails.offerTenure ='';
                }
             if(finalTerm[0].Required_CRM_IRR__c !=null){
                this.OfferDetails.offerIrr = requestWrapper.crmIrrChanged==null?finalTerm[0].Required_CRM_IRR__c:requestWrapper.crmIrrChanged;
            }
            else{
                this.OfferDetails.offerIrr = '';
            }
            //}
            this.Net_IRR_Requested='';
            this.Imputed_IRR_Requested='';
        } 
        else 
            //calltype 4 product PV
            if (this.Product == 'PV' && this.CallType == 'OFFER_U' ){    
                Decimal rentObligationDec = 0;
                Decimal otherObligationDec = 0;
                for(Applicant__c app : appList){
                    rentObligationDec = app.Rental_Expense__c!=null ?  rentObligationDec+app.Rental_Expense__c.setScale(0) : rentObligationDec+0;
                    otherObligationDec = app.Other_Obligation__c!=null ?  otherObligationDec+app.Other_Obligation__c.setScale(0) : otherObligationDec+0;
                }
                this.rentObligation=String.valueOf(rentObligationDec);
                this.otherObligation=String.valueOf(otherObligationDec);    
                if(requestWrapper.advanceEmiFlag!=null){
                    this.Advance_EMI_Flag=requestWrapper.advanceEmiFlag;
                }
                else{
                    this.Advance_EMI_Flag = finalTerm[0].Advance_EMI__c==false?'No':'Yes';
                } 
                this.Threshold_Net_IRR = requestWrapper.thresholdNetIRR == null ? String.valueOf(finalTerm[0].PricingEngine_thresholdNetrr__c) : requestWrapper.thresholdNetIRR;
                this.LTV = finalTerm[0].LtvEngine_Ltv__c==null?'':String.valueOf(finalTerm[0].LtvEngine_Ltv__c);
                if(requestWrapper.loanAmountChanged!=null){
                    this.Finance_Amount =String.valueOf((Integer.valueOf(requestWrapper.loanAmountChanged))+ Integer.valueOf(requestWrapper.sumOfFundedInsurance));
                }
                else{
                    this.Finance_Amount =finalTerm[0].Loan_Amount__c==null?String.valueOf((Integer.valueOf(requestWrapper.loanAmount))+ Integer.valueOf(requestWrapper.sumOfFundedInsurance))
                        :String.valueOf((Integer.valueOf(finalTerm[0].Loan_Amount__c))+ Integer.valueOf(requestWrapper.sumOfFundedInsurance));
                }
                //we implement the if condition because when we move from offer screen to final term by clicking Pay PayOut,
                //than we need fetch value from final term Object (which we change in Offer Screen).
                if(finalTerm[0].Tenure__c !=null){
                    this.Tenure =requestWrapper.tenureChanged==null? finalTerm[0].Tenure__c:requestWrapper.tenureChanged;
                }
                else{
                    this.Tenure =requestWrapper.tenureChanged==null? requestWrapper.tenure:requestWrapper.tenureChanged; 
                }
                //we implement the if condition because when we move from offer screen to final term by clicking Pay PayOut,
                //than we need fetch value from final term Object (which we change in Offer Screen).
                if(finalTerm[0].Required_CRM_IRR__c !=null){
                    if (this.Product == 'TW') {//Start CISP-2364
                        this.CRM_IRR_Requested = finalTerm[0].Required_CRM_IRR__c;
                    } else {
                        this.CRM_IRR_Requested = requestWrapper.crmIrrChanged==null?finalTerm[0].Required_CRM_IRR__c:requestWrapper.crmIrrChanged;
                    }//End CISP-2364
                }
                else{
                    this.CRM_IRR_Requested = requestWrapper.crmIrrChanged==null?requestWrapper.crmIrrRequested:requestWrapper.crmIrrChanged;
                }
                this.LTV_Based_On ='Ex-showroom price';
                this.Monthly_Income= requestWrapper.income==null?'':requestWrapper.income;
                this.Existing_EMI = requestWrapper.emi==null?'':requestWrapper.emi;
                this.ORP =requestWrapper.onRoadPrice==null?'':requestWrapper.onRoadPrice;
                this.PayIns.Doc_Charges = finalTerm[0].Documentation_charges__c==null?'':finalTerm[0].Documentation_charges__c;
                this.PayIns.Service_Charges =  finalTerm[0].Service_charges__c==null?'':finalTerm[0].Service_charges__c;
                this.PayIns.Mfr_Exp_Reimbursement_Amount =  finalTerm[0].Mfr_Exp_Reimburse_Amt__c==null?'':finalTerm[0].Mfr_Exp_Reimburse_Amt__c;
                this.PayIns.Dealer_Exp_Reimbursement_Amount =  finalTerm[0].Dlr_Exp_Reimburse_Amt__c==null?'':finalTerm[0].Dlr_Exp_Reimburse_Amt__c;
                
                // CISP-124
                if(requestWrapper.provisionAmount != null  && requestWrapper.provisionAmount != ''){
                    this.PayOuts.Provision_Cost = requestWrapper.provisionAmount;
                }else{
                    this.PayOuts.Provision_Cost = finalTerm[0].Provisional_Channel_Cost__c==null?'':finalTerm[0].Provisional_Channel_Cost__c;
                }
                // CISP-124
                this.PayOuts.Dlr_Incentive_Amt_Main = finalTerm[0].Dealer_incentive_amount_main_dealer__c==null?'':finalTerm[0].Dealer_incentive_amount_main_dealer__c;
                this.PayOuts.Dlr_Incentive_Amt_Sub = finalTerm[0].Dealer_incentive_amount_sub_dealer__c==null?'':finalTerm[0].Dealer_incentive_amount_sub_dealer__c;
                this.PayOuts.Mfr_Incentive_Amount = finalTerm[0].Mfr_incentive__c==null?'':finalTerm[0].Mfr_incentive__c;
                this.PayOuts.Referrer_Incentive = finalTerm[0].Rreferrer_Incentive__c==null?'':finalTerm[0].Rreferrer_Incentive__c;
                this.PayOuts.Gift_Amt = finalTerm[0].Gift_through_dealer_amount__c==null?'':finalTerm[0].Gift_through_dealer_amount__c;
                this.PayOuts.DSM_Incentive1 = finalTerm[0].DSM_Incentive1__c==null?'':finalTerm[0].DSM_Incentive1__c;
                this.PayOuts.DSM_Incentive2 = finalTerm[0].DSM_Incentive2__c==null?'':finalTerm[0].DSM_Incentive2__c;
                this.PayOuts.Covid_Ins_Prem = '';
                //if(Integer.valueOf(this.Finance_Amount) <= Integer.valueOf(finalTerm[0].OfferengineMaxLoanAmount__c)  && 
        //Integer.valueOf(this.Finance_Amount) >= Integer.valueOf(finalTerm[0].OfferengineMinLoanAmount__c) &&
                   //requestWrapper.currentScreen=='Final terms' && !finalTerm[0].isNavigate__c){   
                   //this.OfferDetails.offerLoanAmount ='';
                   //this.OfferDetails.offerTenure= '';   
                   //this.OfferDetails.offerIrr ='';     
              // }
        //else{
                if(requestWrapper.loanAmountChanged!=null){
                    this.OfferDetails.offerLoanAmount = String.valueOf((Integer.valueOf(requestWrapper.loanAmountChanged))+ Integer.valueOf(requestWrapper.sumOfFundedInsurance));
                }
                else{
                    this.OfferDetails.offerLoanAmount =finalTerm[0].Loan_Amount__c!=null?String.valueOf((Integer.valueOf(finalTerm[0].Loan_Amount__c)+ Integer.valueOf(requestWrapper.sumOfFundedInsurance))):'';
                }
                if(finalTerm[0].Tenure__c !=null){
                    this.OfferDetails.offerTenure =requestWrapper.tenureChanged==null? finalTerm[0].Tenure__c:requestWrapper.tenureChanged;
                }
                else{
                    this.OfferDetails.offerTenure ='';
                }
                if(finalTerm[0].Required_CRM_IRR__c !=null){
                    this.OfferDetails.offerIrr = requestWrapper.crmIrrChanged==null?finalTerm[0].Required_CRM_IRR__c:requestWrapper.crmIrrChanged;
                }
                else{
                    this.OfferDetails.offerIrr = '';
                }
                //}
                this.Net_IRR_Requested='';
                this.Imputed_IRR_Requested='';
                this.Ex_Showroom_Price = VehicleDtlList[0].Base_Prices__c == null? '' : String.valueOf(VehicleDtlList[0].Base_Prices__c);
            } 
            else // start CISP-2415
            //calltype 4 product PV
            if (this.Product == 'PV' && this.CallType == 'OFFER_R' ){     
                Decimal rentObligationDec = 0;
                Decimal otherObligationDec = 0;
                for(Applicant__c app : appList){
                    rentObligationDec = app.Rental_Expense__c!=null ?  rentObligationDec+app.Rental_Expense__c.setScale(0) : rentObligationDec+0;
                    otherObligationDec = app.Other_Obligation__c!=null ?  otherObligationDec+app.Other_Obligation__c.setScale(0) : otherObligationDec+0;
                }
                this.rentObligation=String.valueOf(rentObligationDec);
                this.otherObligation=String.valueOf(otherObligationDec);         
                if(requestWrapper.advanceEmiFlag!=null){
                    this.Advance_EMI_Flag=requestWrapper.advanceEmiFlag;
                }
                else{
                    this.Advance_EMI_Flag = finalTerm[0].Advance_EMI__c==false?'No':'Yes';
                } 
                this.Threshold_Net_IRR = requestWrapper.thresholdNetIRR == null ? String.valueOf(finalTerm[0].PricingEngine_thresholdNetrr__c) : requestWrapper.thresholdNetIRR;
                this.LTV = finalTerm[0].LtvEngine_Ltv__c==null?'':String.valueOf(finalTerm[0].LtvEngine_Ltv__c);
                if(requestWrapper.loanAmountChanged!=null){
                    this.Finance_Amount =String.valueOf((Integer.valueOf(requestWrapper.loanAmountChanged))+ Integer.valueOf(requestWrapper.sumOfFundedInsurance));
                }
                else{
                    this.Finance_Amount =finalTerm[0].Loan_Amount__c==null?String.valueOf((Integer.valueOf(requestWrapper.loanAmount))+ Integer.valueOf(requestWrapper.sumOfFundedInsurance))
                        :String.valueOf((Integer.valueOf(finalTerm[0].Loan_Amount__c))+ Integer.valueOf(requestWrapper.sumOfFundedInsurance));
                }
                //we implement the if condition because when we move from offer screen to final term by clicking Pay PayOut,
                //than we need fetch value from final term Object (which we change in Offer Screen).
                if(finalTerm[0].Tenure__c !=null){
                    this.Tenure =requestWrapper.tenureChanged==null? finalTerm[0].Tenure__c:requestWrapper.tenureChanged;
                }
                else{
                    this.Tenure =requestWrapper.tenureChanged==null? requestWrapper.tenure:requestWrapper.tenureChanged; 
                }
                //we implement the if condition because when we move from offer screen to final term by clicking Pay PayOut,
                //than we need fetch value from final term Object (which we change in Offer Screen).
                if(finalTerm[0].Required_CRM_IRR__c !=null){
                    this.CRM_IRR_Requested = finalTerm[0].Required_CRM_IRR__c;
                }
                else{
                    this.CRM_IRR_Requested = requestWrapper.crmIrrChanged==null?requestWrapper.crmIrrRequested:requestWrapper.crmIrrChanged;
                }
                this.LTV_Based_On ='Ex-showroom price';
                this.Monthly_Income= requestWrapper.income==null?'':requestWrapper.income;
                this.Existing_EMI = requestWrapper.emi==null?'':requestWrapper.emi;
                this.ORP =requestWrapper.onRoadPrice==null?'':requestWrapper.onRoadPrice;
                this.PayIns.Doc_Charges = finalTerm[0].Documentation_charges__c==null?'':finalTerm[0].Documentation_charges__c;
                this.PayIns.Service_Charges =  finalTerm[0].Service_charges__c==null?'':finalTerm[0].Service_charges__c;
                this.PayIns.Mfr_Exp_Reimbursement_Amount =  finalTerm[0].Mfr_Exp_Reimburse_Amt__c==null?'':finalTerm[0].Mfr_Exp_Reimburse_Amt__c;
                this.PayIns.Dealer_Exp_Reimbursement_Amount =  finalTerm[0].Dlr_Exp_Reimburse_Amt__c==null?'':finalTerm[0].Dlr_Exp_Reimburse_Amt__c;
                
                this.PayOuts.Provision_Cost = finalTerm[0].Provisional_Channel_Cost__c==null?'':finalTerm[0].Provisional_Channel_Cost__c;
                this.PayOuts.Dlr_Incentive_Amt_Main = finalTerm[0].Dealer_incentive_amount_main_dealer__c==null?'':finalTerm[0].Dealer_incentive_amount_main_dealer__c;
                this.PayOuts.Dlr_Incentive_Amt_Sub = finalTerm[0].Dealer_incentive_amount_sub_dealer__c==null?'':finalTerm[0].Dealer_incentive_amount_sub_dealer__c;
                this.PayOuts.Mfr_Incentive_Amount = finalTerm[0].Mfr_incentive__c==null?'':finalTerm[0].Mfr_incentive__c;
                this.PayOuts.Referrer_Incentive = finalTerm[0].Rreferrer_Incentive__c==null?'':finalTerm[0].Rreferrer_Incentive__c;
                this.PayOuts.Gift_Amt = finalTerm[0].Gift_through_dealer_amount__c==null?'':finalTerm[0].Gift_through_dealer_amount__c;
                this.PayOuts.DSM_Incentive1 = finalTerm[0].DSM_Incentive1__c==null?'':finalTerm[0].DSM_Incentive1__c;
                this.PayOuts.DSM_Incentive2 = finalTerm[0].DSM_Incentive2__c==null?'':finalTerm[0].DSM_Incentive2__c;
                this.PayOuts.Covid_Ins_Prem = '';
                //if(Integer.valueOf(this.Finance_Amount) <= Integer.valueOf(finalTerm[0].OfferengineMaxLoanAmount__c)  && 
				//Integer.valueOf(this.Finance_Amount) >= Integer.valueOf(finalTerm[0].OfferengineMinLoanAmount__c) &&
                  // requestWrapper.currentScreen=='Final terms' && !finalTerm[0].isNavigate__c){	 
                  // this.OfferDetails.offerLoanAmount ='';
                  // this.OfferDetails.offerTenure= '';   
                   //this.OfferDetails.offerIrr =''; 		
               //}
				//else{
                if(requestWrapper.loanAmountChanged!=null){
                    this.OfferDetails.offerLoanAmount = String.valueOf((Integer.valueOf(requestWrapper.loanAmountChanged))+ Integer.valueOf(requestWrapper.sumOfFundedInsurance));
                }
                else{
                    this.OfferDetails.offerLoanAmount =finalTerm[0].Loan_Amount__c!=null?String.valueOf((Integer.valueOf(finalTerm[0].Loan_Amount__c)+ Integer.valueOf(requestWrapper.sumOfFundedInsurance))):'';
                }
                if(finalTerm[0].Tenure__c !=null){
                    this.OfferDetails.offerTenure =requestWrapper.tenureChanged==null? finalTerm[0].Tenure__c:requestWrapper.tenureChanged;
                }
                else{
                    this.OfferDetails.offerTenure ='';
                }
                if(finalTerm[0].Required_CRM_IRR__c !=null){
                    this.OfferDetails.offerIrr = requestWrapper.crmIrrChanged==null?finalTerm[0].Required_CRM_IRR__c:requestWrapper.crmIrrChanged;
                }
                else{
                    this.OfferDetails.offerIrr = '';
                }
                //}
                this.Net_IRR_Requested='';
                this.Imputed_IRR_Requested='';
                this.Ex_Showroom_Price = VehicleDtlList[0].Base_Prices__c == null? '' : String.valueOf(VehicleDtlList[0].Base_Prices__c);
            } // End CISP-2415        
        else 
            //calltype 2 product PV
            if (this.Product == 'PV' && this.CallType == 'Input_Net_IRR' ){
                if(requestWrapper.currentScreen=='Offer screen changed'){
                     this.Finance_Amount =String.valueOf((Integer.valueOf(requestWrapper.loanAmountChanged))+ Integer.valueOf(requestWrapper.sumOfFundedInsurance));
                     this.Tenure=requestWrapper.tenureChanged;
                     this.CRM_IRR_Requested=requestWrapper.crmIrrChanged;
                      this.OfferDetails.offerLoanAmount ='';
                     this.OfferDetails.offerTenure= '';   
                     this.OfferDetails.offerIrr =''; 
                }
                else{
                    if(String.isNotBlank(requestWrapper.loanAmountChanged)){
                        this.Finance_Amount = requestWrapper.loanAmountChanged;
                    }else{
                    this.Finance_Amount =finalTerm[0].Loan_Amount__c==null?String.valueOf((Integer.valueOf(requestWrapper.loanAmount)+ Integer.valueOf(requestWrapper.sumOfFundedInsurance)))
                        :String.valueOf((Integer.valueOf(finalTerm[0].Loan_Amount__c)+ Integer.valueOf(requestWrapper.sumOfFundedInsurance)));
                    }
                    this.Tenure = finalTerm[0].Tenure__c==null?requestWrapper.tenure:finalTerm[0].Tenure__c;   
                    this.CRM_IRR_Requested = finalTerm[0].Required_CRM_IRR__c==null?requestWrapper.crmIrrRequested: String.valueOf(finalTerm[0].Required_CRM_IRR__c); 
                    this.OfferDetails.offerLoanAmount ='';
                    this.OfferDetails.offerTenure= '';   
                    this.OfferDetails.offerIrr =''; 
                }
                if(requestWrapper.advanceEmiFlag!=null){
                    this.Advance_EMI_Flag=requestWrapper.advanceEmiFlag;
                }
                else{
                    this.Advance_EMI_Flag = finalTerm[0].Advance_EMI__c==false?'No':'Yes';
                } 
               this.PayIns.Doc_Charges = finalTerm[0].Documentation_charges__c==null?'':finalTerm[0].Documentation_charges__c;
                this.PayIns.Service_Charges =  finalTerm[0].Service_charges__c==null?'':finalTerm[0].Service_charges__c;
                this.PayIns.Mfr_Exp_Reimbursement_Amount =  finalTerm[0].Mfr_Exp_Reimburse_Amt__c==null?'':finalTerm[0].Mfr_Exp_Reimburse_Amt__c;
                this.PayIns.Dealer_Exp_Reimbursement_Amount =  finalTerm[0].Dlr_Exp_Reimburse_Amt__c==null?'':finalTerm[0].Dlr_Exp_Reimburse_Amt__c;
                
                // CISP-124
                if(requestWrapper.provisionAmount != null  && requestWrapper.provisionAmount != ''){
                    this.PayOuts.Provision_Cost = requestWrapper.provisionAmount;
                }else{
                    this.PayOuts.Provision_Cost = finalTerm[0].Provisional_Channel_Cost__c==null?'':finalTerm[0].Provisional_Channel_Cost__c;
                }
                // CISP-124
                this.PayOuts.Dlr_Incentive_Amt_Main = finalTerm[0].Dealer_incentive_amount_main_dealer__c==null?'':finalTerm[0].Dealer_incentive_amount_main_dealer__c;
                this.PayOuts.Dlr_Incentive_Amt_Sub = finalTerm[0].Dealer_incentive_amount_sub_dealer__c==null?'':finalTerm[0].Dealer_incentive_amount_sub_dealer__c;
                this.PayOuts.Mfr_Incentive_Amount = finalTerm[0].Mfr_incentive__c==null?'':finalTerm[0].Mfr_incentive__c;
                this.PayOuts.Referrer_Incentive = finalTerm[0].Rreferrer_Incentive__c==null?'':finalTerm[0].Rreferrer_Incentive__c;
                this.PayOuts.Gift_Amt = finalTerm[0].Gift_through_dealer_amount__c==null?'':finalTerm[0].Gift_through_dealer_amount__c;
                this.PayOuts.DSM_Incentive1 = finalTerm[0].DSM_Incentive1__c==null?'':finalTerm[0].DSM_Incentive1__c;
                this.PayOuts.DSM_Incentive2 = finalTerm[0].DSM_Incentive2__c==null?'':finalTerm[0].DSM_Incentive2__c;
                this.PayOuts.Covid_Ins_Prem = '';
                this.Imputed_IRR_Requested='';
                
            }   
        
        else 
            //calltype 4 product TW
            if (this.Product == 'TW' && this.CallType == 'OFFER_U' ){              
                if(requestWrapper.advanceEmiFlag!=null){
                    this.Advance_EMI_Flag=requestWrapper.advanceEmiFlag;
                }
                else{
                    this.Advance_EMI_Flag = finalTerm[0].Advance_EMI__c==false?'No':'Yes';
                } 
                this.Threshold_Net_IRR = requestWrapper.thresholdNetIRR == null ? String.valueOf(finalTerm[0].PricingEngine_thresholdNetrr__c) : requestWrapper.thresholdNetIRR;
                this.LTV = finalTerm[0].LtvEngine_Ltv__c==null?'':String.valueOf(finalTerm[0].LtvEngine_Ltv__c);
                if(requestWrapper.loanAmountChanged!=null){
                    this.Finance_Amount =String.valueOf((Integer.valueOf(requestWrapper.loanAmountChanged))+ Integer.valueOf(requestWrapper.sumOfFundedInsurance));
                }
                else{
                    this.Finance_Amount =finalTerm[0].Loan_Amount__c==null?String.valueOf((Integer.valueOf(requestWrapper.loanAmount))+ Integer.valueOf(requestWrapper.sumOfFundedInsurance))
                        :String.valueOf((Integer.valueOf(finalTerm[0].Loan_Amount__c))+ Integer.valueOf(requestWrapper.sumOfFundedInsurance));
                }
                //we implement the if condition because when we move from offer screen to final term by clicking Pay PayOut,
                //than we need fetch value from final term Object (which we change in Offer Screen).
                if(finalTerm[0].Tenure__c !=null){
                    this.Tenure =requestWrapper.tenureChanged==null? finalTerm[0].Tenure__c:requestWrapper.tenureChanged;
                }
                else{
                    this.Tenure =requestWrapper.tenureChanged==null? requestWrapper.tenure:requestWrapper.tenureChanged; 
                }
                //we implement the if condition because when we move from offer screen to final term by clicking Pay PayOut,
                //than we need fetch value from final term Object (which we change in Offer Screen).
                if(finalTerm[0].Required_CRM_IRR__c !=null){
                    if (this.Product == 'TW') {//Start CISP-2364
                        this.CRM_IRR_Requested = finalTerm[0].Required_CRM_IRR__c;
                    } else {
                        this.CRM_IRR_Requested = requestWrapper.crmIrrChanged==null?finalTerm[0].Required_CRM_IRR__c:requestWrapper.crmIrrChanged;
                    }//End CISP-2364
                }
                else{
                    this.CRM_IRR_Requested = requestWrapper.crmIrrChanged==null?requestWrapper.crmIrrRequested:requestWrapper.crmIrrChanged;
                }
                this.LTV_Based_On ='Ex-showroom price';
                this.Monthly_Income= requestWrapper.income==null?'':requestWrapper.income;
                this.Existing_EMI = requestWrapper.emi==null?'':requestWrapper.emi;
                this.Ex_Showroom_Price = VehicleDtlList[0].Base_Prices__c == null? '' : String.valueOf(VehicleDtlList[0].Base_Prices__c);
                this.ORP =requestWrapper.onRoadPrice==null?'':requestWrapper.onRoadPrice;
                this.Funded_Insurance = requestWrapper.sumOfFundedInsurance;
                
                this.PayIns.Doc_Charges = finalTerm[0].Documentation_charges__c==null?'':finalTerm[0].Documentation_charges__c;
                this.PayIns.Service_Charges =  finalTerm[0].Service_charges__c==null?'':finalTerm[0].Service_charges__c;
                this.PayIns.Mfr_Exp_Reimbursement_Amount =  finalTerm[0].Mfr_Exp_Reimburse_Amt__c==null?'':finalTerm[0].Mfr_Exp_Reimburse_Amt__c;
                this.PayIns.Dealer_Exp_Reimbursement_Amount =  finalTerm[0].Dlr_Exp_Reimburse_Amt__c==null?'':finalTerm[0].Dlr_Exp_Reimburse_Amt__c;
                
                // CISP-124
                if(requestWrapper.provisionAmount != null  && requestWrapper.provisionAmount != ''){
                    this.PayOuts.Provision_Cost = requestWrapper.provisionAmount;
                }else{
                    this.PayOuts.Provision_Cost = finalTerm[0].Provisional_Channel_Cost__c==null?'':finalTerm[0].Provisional_Channel_Cost__c;
                }
                // CISP-124
                this.PayOuts.Dlr_Incentive_Amt_Main = finalTerm[0].Dealer_incentive_amount_main_dealer__c==null?'':finalTerm[0].Dealer_incentive_amount_main_dealer__c;
                this.PayOuts.Dlr_Incentive_Amt_Sub = finalTerm[0].Dealer_incentive_amount_sub_dealer__c==null?'':finalTerm[0].Dealer_incentive_amount_sub_dealer__c;
                this.PayOuts.Mfr_Incentive_Amount = finalTerm[0].Mfr_incentive__c==null?'':finalTerm[0].Mfr_incentive__c;
                this.PayOuts.Referrer_Incentive = finalTerm[0].Rreferrer_Incentive__c==null?'':finalTerm[0].Rreferrer_Incentive__c;
                this.PayOuts.Gift_Amt = finalTerm[0].Gift_through_dealer_amount__c==null?'':finalTerm[0].Gift_through_dealer_amount__c;
                this.PayOuts.DSM_Incentive1 = finalTerm[0].DSM_Incentive1__c==null?'':finalTerm[0].DSM_Incentive1__c;
                this.PayOuts.DSM_Incentive2 = finalTerm[0].DSM_Incentive2__c==null?'':finalTerm[0].DSM_Incentive2__c;
                this.PayOuts.Covid_Ins_Prem = '';
                // if(Integer.valueOf(this.Finance_Amount) <= Integer.valueOf(finalTerm[0].OfferengineMaxLoanAmount__c)  && 
                // Integer.valueOf(this.Finance_Amount) >= Integer.valueOf(finalTerm[0].OfferengineMinLoanAmount__c) &&
                //    requestWrapper.currentScreen=='Final terms' && !finalTerm[0].isNavigate__c){   
                //    this.OfferDetails.offerLoanAmount ='';
                //    this.OfferDetails.offerTenure= '';   
                //    this.OfferDetails.offerIrr ='';     
                // }
                // else{  //Commented this code regarding for this ticket CISP-2837
                if(requestWrapper.loanAmountChanged!=null){
                    this.OfferDetails.offerLoanAmount = String.valueOf((Integer.valueOf(requestWrapper.loanAmountChanged))+ Integer.valueOf(requestWrapper.sumOfFundedInsurance));
                }
                else{
                    this.OfferDetails.offerLoanAmount =finalTerm[0].Loan_Amount__c!=null?String.valueOf((Integer.valueOf(finalTerm[0].Loan_Amount__c)+ Integer.valueOf(requestWrapper.sumOfFundedInsurance))):'';
                }
                if(finalTerm[0].Tenure__c !=null){
                    this.OfferDetails.offerTenure =requestWrapper.tenureChanged==null? finalTerm[0].Tenure__c:requestWrapper.tenureChanged;
                }
                else{
                    this.OfferDetails.offerTenure =''; 
                }
                if(finalTerm[0].Required_CRM_IRR__c !=null){
                    this.OfferDetails.offerIrr = requestWrapper.crmIrrChanged==null?finalTerm[0].Required_CRM_IRR__c:requestWrapper.crmIrrChanged;
                }
                else{
                    this.OfferDetails.offerIrr = '';
                }
                // }
                this.Net_IRR_Requested='';
                this.Imputed_IRR_Requested='';
            } 
        
            else // start CISP-2415
            //calltype 4 product TW
            if (this.Product == 'TW' && this.CallType == 'OFFER_R' ){              
                if(requestWrapper.advanceEmiFlag!=null){
                    this.Advance_EMI_Flag=requestWrapper.advanceEmiFlag;
                }
                else{
                    this.Advance_EMI_Flag = finalTerm[0].Advance_EMI__c==false?'No':'Yes';
                } 
                this.Threshold_Net_IRR = requestWrapper.thresholdNetIRR == null ? String.valueOf(finalTerm[0].PricingEngine_thresholdNetrr__c) : requestWrapper.thresholdNetIRR;
                this.LTV = finalTerm[0].LtvEngine_Ltv__c==null?'':String.valueOf(finalTerm[0].LtvEngine_Ltv__c);
                if(requestWrapper.loanAmountChanged!=null){
                    this.Finance_Amount =String.valueOf((Integer.valueOf(requestWrapper.loanAmountChanged))+ Integer.valueOf(requestWrapper.sumOfFundedInsurance));
                }
                else{
                    this.Finance_Amount =finalTerm[0].Loan_Amount__c==null?String.valueOf((Integer.valueOf(requestWrapper.loanAmount))+ Integer.valueOf(requestWrapper.sumOfFundedInsurance))
                        :String.valueOf((Integer.valueOf(finalTerm[0].Loan_Amount__c))+ Integer.valueOf(requestWrapper.sumOfFundedInsurance));
                }
                //we implement the if condition because when we move from offer screen to final term by clicking Pay PayOut,
                //than we need fetch value from final term Object (which we change in Offer Screen).
                if(finalTerm[0].Tenure__c !=null){
                    this.Tenure =requestWrapper.tenureChanged==null? finalTerm[0].Tenure__c:requestWrapper.tenureChanged;
                }
                else{
                    this.Tenure =requestWrapper.tenureChanged==null? requestWrapper.tenure:requestWrapper.tenureChanged; 
                }
                //we implement the if condition because when we move from offer screen to final term by clicking Pay PayOut,
                //than we need fetch value from final term Object (which we change in Offer Screen).
                if(finalTerm[0].Required_CRM_IRR__c !=null){
                    this.CRM_IRR_Requested = finalTerm[0].Required_CRM_IRR__c;
                }
                else{
                    this.CRM_IRR_Requested = requestWrapper.crmIrrChanged==null?requestWrapper.crmIrrRequested:requestWrapper.crmIrrChanged;
                }
                this.LTV_Based_On ='Ex-showroom price';
              	this.Monthly_Income= requestWrapper.income==null?'':requestWrapper.income;
                this.Existing_EMI = requestWrapper.emi==null?'':requestWrapper.emi;
                this.Ex_Showroom_Price = VehicleDtlList[0].Base_Prices__c == null? '' : String.valueOf(VehicleDtlList[0].Base_Prices__c);
                this.ORP =requestWrapper.onRoadPrice==null?'':requestWrapper.onRoadPrice;
                this.Funded_Insurance = requestWrapper.sumOfFundedInsurance;
                
                this.PayIns.Doc_Charges = finalTerm[0].Documentation_charges__c==null?'':finalTerm[0].Documentation_charges__c;
                this.PayIns.Service_Charges =  finalTerm[0].Service_charges__c==null?'':finalTerm[0].Service_charges__c;
                this.PayIns.Mfr_Exp_Reimbursement_Amount =  finalTerm[0].Mfr_Exp_Reimburse_Amt__c==null?'':finalTerm[0].Mfr_Exp_Reimburse_Amt__c;
                this.PayIns.Dealer_Exp_Reimbursement_Amount =  finalTerm[0].Dlr_Exp_Reimburse_Amt__c==null?'':finalTerm[0].Dlr_Exp_Reimburse_Amt__c;
                
                this.PayOuts.Provision_Cost = finalTerm[0].Provisional_Channel_Cost__c==null?'':finalTerm[0].Provisional_Channel_Cost__c;
                this.PayOuts.Dlr_Incentive_Amt_Main = finalTerm[0].Dealer_incentive_amount_main_dealer__c==null?'':finalTerm[0].Dealer_incentive_amount_main_dealer__c;
                this.PayOuts.Dlr_Incentive_Amt_Sub = finalTerm[0].Dealer_incentive_amount_sub_dealer__c==null?'':finalTerm[0].Dealer_incentive_amount_sub_dealer__c;
                this.PayOuts.Mfr_Incentive_Amount = finalTerm[0].Mfr_incentive__c==null?'':finalTerm[0].Mfr_incentive__c;
                this.PayOuts.Referrer_Incentive = finalTerm[0].Rreferrer_Incentive__c==null?'':finalTerm[0].Rreferrer_Incentive__c;
                this.PayOuts.Gift_Amt = finalTerm[0].Gift_through_dealer_amount__c==null?'':finalTerm[0].Gift_through_dealer_amount__c;
                this.PayOuts.DSM_Incentive1 = finalTerm[0].DSM_Incentive1__c==null?'':finalTerm[0].DSM_Incentive1__c;
                this.PayOuts.DSM_Incentive2 = finalTerm[0].DSM_Incentive2__c==null?'':finalTerm[0].DSM_Incentive2__c;
                this.PayOuts.Covid_Ins_Prem = '';
                // if(Integer.valueOf(this.Finance_Amount) <= Integer.valueOf(finalTerm[0].OfferengineMaxLoanAmount__c)  && 
                // Integer.valueOf(this.Finance_Amount) >= Integer.valueOf(finalTerm[0].OfferengineMinLoanAmount__c) &&
                //    requestWrapper.currentScreen=='Final terms' && !finalTerm[0].isNavigate__c){	 
                //    this.OfferDetails.offerLoanAmount ='';
                //    this.OfferDetails.offerTenure= '';   
                //    this.OfferDetails.offerIrr =''; 		
                // }
                // else{ //Commented this code regarding for this ticket CISP-2837
                if(requestWrapper.loanAmountChanged!=null){
                    this.OfferDetails.offerLoanAmount = String.valueOf((Integer.valueOf(requestWrapper.loanAmountChanged))+ Integer.valueOf(requestWrapper.sumOfFundedInsurance));
                }
                else{
                    this.OfferDetails.offerLoanAmount =finalTerm[0].Loan_Amount__c!=null?String.valueOf((Integer.valueOf(finalTerm[0].Loan_Amount__c)+ Integer.valueOf(requestWrapper.sumOfFundedInsurance))):'';
                }
                if(finalTerm[0].Tenure__c !=null){
                    this.OfferDetails.offerTenure =requestWrapper.tenureChanged==null? finalTerm[0].Tenure__c:requestWrapper.tenureChanged;
                }
                else{
                    this.OfferDetails.offerTenure =''; 
                }
                if(finalTerm[0].Required_CRM_IRR__c !=null){
                    this.OfferDetails.offerIrr = requestWrapper.crmIrrChanged==null?finalTerm[0].Required_CRM_IRR__c:requestWrapper.crmIrrChanged;
                }
                else{
                    this.OfferDetails.offerIrr = '';
                }
                // }
                this.Net_IRR_Requested='';
                this.Imputed_IRR_Requested='';
            } // End CISP-2415
        
        else 
            //calltype 1 product TW
            if (this.Product == 'TW' && this.CallType == 'OFFER' ){              
                if(requestWrapper.advanceEmiFlag!=null){
                    this.Advance_EMI_Flag=requestWrapper.advanceEmiFlag;
                }
                else{
                    this.Advance_EMI_Flag = finalTerm[0].Advance_EMI__c==false?'No':'Yes';
                } 
                //this.Threshold_Net_IRR = finalTerm[0].PricingEngine_thresholdNetrr__c==null?'':String.valueOf(finalTerm[0].PricingEngine_thresholdNetrr__c);
                this.Threshold_Net_IRR = requestWrapper.thresholdNetIRR == null ? String.valueOf(finalTerm[0].PricingEngine_thresholdNetrr__c) : requestWrapper.thresholdNetIRR;
                this.LTV = finalTerm[0].LtvEngine_Ltv__c==null?'':String.valueOf(finalTerm[0].LtvEngine_Ltv__c);
                if(requestWrapper.loanAmountChanged!=null){
                    this.Finance_Amount =String.valueOf((Integer.valueOf(requestWrapper.loanAmountChanged))+ Integer.valueOf(requestWrapper.sumOfFundedInsurance));
                }
                else{
                    this.Finance_Amount =finalTerm[0].Loan_Amount__c==null?String.valueOf((Integer.valueOf(requestWrapper.loanAmount))+ Integer.valueOf(requestWrapper.sumOfFundedInsurance))
                        :String.valueOf((Integer.valueOf(finalTerm[0].Loan_Amount__c))+ Integer.valueOf(requestWrapper.sumOfFundedInsurance));
                }
                //we implement the if condition because when we move from offer screen to final term by clicking Pay PayOut,
                //than we need fetch value from final term Object (which we change in Offer Screen).
                if(finalTerm[0].Tenure__c !=null){
                    this.Tenure =requestWrapper.tenureChanged==null? finalTerm[0].Tenure__c:requestWrapper.tenureChanged;
                }
                else{
                    this.Tenure =requestWrapper.tenureChanged==null? requestWrapper.tenure:requestWrapper.tenureChanged; 
                }
                //we implement the if condition because when we move from offer screen to final term by clicking Pay PayOut,
                //than we need fetch value from final term Object (which we change in Offer Screen).
                if(finalTerm[0].Required_CRM_IRR__c !=null){
                    if (this.Product == 'TW') {//Start CISP-2364
                        this.CRM_IRR_Requested = finalTerm[0].Required_CRM_IRR__c;
                    } else {
                        this.CRM_IRR_Requested = requestWrapper.crmIrrChanged==null?finalTerm[0].Required_CRM_IRR__c:requestWrapper.crmIrrChanged;
                    }//End CISP-2364
                }
                else{
                    this.CRM_IRR_Requested = requestWrapper.crmIrrChanged==null?requestWrapper.crmIrrRequested:requestWrapper.crmIrrChanged;
                }
                this.LTV_Based_On =requestWrapper.fundingOnExShowroom=='true'?'Ex-showroom price':requestWrapper.fundingOnORP=='true'?'Onroad price':'';
              this.Monthly_Income= requestWrapper.income==null?'':requestWrapper.income;
                this.Existing_EMI = requestWrapper.emi==null?'':requestWrapper.emi;
                this.Ex_Showroom_Price = requestWrapper.exShowroomPrice==null?'':requestWrapper.exShowroomPrice;
                this.ORP =requestWrapper.onRoadPrice==null?'':requestWrapper.onRoadPrice;
                this.Funded_Insurance = requestWrapper.sumOfFundedInsurance;
                
                this.PayIns.Doc_Charges = finalTerm[0].Documentation_charges__c==null?'':finalTerm[0].Documentation_charges__c;
                this.PayIns.Service_Charges =  finalTerm[0].Service_charges__c==null?'':finalTerm[0].Service_charges__c;
                this.PayIns.Mfr_Exp_Reimbursement_Amount =  finalTerm[0].Mfr_Exp_Reimburse_Amt__c==null?'':finalTerm[0].Mfr_Exp_Reimburse_Amt__c;
                this.PayIns.Dealer_Exp_Reimbursement_Amount =  finalTerm[0].Dlr_Exp_Reimburse_Amt__c==null?'':finalTerm[0].Dlr_Exp_Reimburse_Amt__c;
                
                // CISP-124
                if(requestWrapper.provisionAmount != null  && requestWrapper.provisionAmount != ''){
                    this.PayOuts.Provision_Cost = requestWrapper.provisionAmount;
                }else{
                    this.PayOuts.Provision_Cost = finalTerm[0].Provisional_Channel_Cost__c==null?'':finalTerm[0].Provisional_Channel_Cost__c;
                }
                // CISP-124
                this.PayOuts.Dlr_Incentive_Amt_Main = finalTerm[0].Dealer_incentive_amount_main_dealer__c==null?'':finalTerm[0].Dealer_incentive_amount_main_dealer__c;
                this.PayOuts.Dlr_Incentive_Amt_Sub = finalTerm[0].Dealer_incentive_amount_sub_dealer__c==null?'':finalTerm[0].Dealer_incentive_amount_sub_dealer__c;
                this.PayOuts.Mfr_Incentive_Amount = finalTerm[0].Mfr_incentive__c==null?'':finalTerm[0].Mfr_incentive__c;
                this.PayOuts.Referrer_Incentive = finalTerm[0].Rreferrer_Incentive__c==null?'':finalTerm[0].Rreferrer_Incentive__c;
                this.PayOuts.Gift_Amt = finalTerm[0].Gift_through_dealer_amount__c==null?'':finalTerm[0].Gift_through_dealer_amount__c;
                this.PayOuts.DSM_Incentive1 = finalTerm[0].DSM_Incentive1__c==null?'':finalTerm[0].DSM_Incentive1__c;
                this.PayOuts.DSM_Incentive2 = finalTerm[0].DSM_Incentive2__c==null?'':finalTerm[0].DSM_Incentive2__c;
                this.PayOuts.Covid_Ins_Prem = '';
        // if(Integer.valueOf(this.Finance_Amount) <= Integer.valueOf(finalTerm[0].OfferengineMaxLoanAmount__c)  && 
        // Integer.valueOf(this.Finance_Amount) >= Integer.valueOf(finalTerm[0].OfferengineMinLoanAmount__c) &&
        //            requestWrapper.currentScreen=='Final terms' && !finalTerm[0].isNavigate__c){   
        //            this.OfferDetails.offerLoanAmount ='';
        //            this.OfferDetails.offerTenure= '';   
        //            this.OfferDetails.offerIrr ='';     
        //         }
        // else{ //Commented this code regarding for this ticket CISP-2837
                if(requestWrapper.loanAmountChanged!=null){
                    this.OfferDetails.offerLoanAmount = String.valueOf((Integer.valueOf(requestWrapper.loanAmountChanged))+ Integer.valueOf(requestWrapper.sumOfFundedInsurance));
                }
                else{
                    this.OfferDetails.offerLoanAmount =finalTerm[0].Loan_Amount__c!=null?String.valueOf((Integer.valueOf(finalTerm[0].Loan_Amount__c)+ Integer.valueOf(requestWrapper.sumOfFundedInsurance))):'';
                }
                if(finalTerm[0].Tenure__c !=null){
                    this.OfferDetails.offerTenure =requestWrapper.tenureChanged==null? finalTerm[0].Tenure__c:requestWrapper.tenureChanged;
                }
                else{
                    this.OfferDetails.offerTenure =''; 
                }
                if(finalTerm[0].Required_CRM_IRR__c !=null){
                    this.OfferDetails.offerIrr = requestWrapper.crmIrrChanged==null?finalTerm[0].Required_CRM_IRR__c:requestWrapper.crmIrrChanged;
                }
                else{
                    this.OfferDetails.offerIrr = '';
                }
                // }
                this.Net_IRR_Requested='';
                this.Imputed_IRR_Requested='';
            } 
        
        
        else 
            //calltype 2 product TW
            if (this.Product == 'TW' && this.CallType == 'Input_Imputed_IRR' ){
                if(requestWrapper.currentScreen=='Offer screen changed'){
                     this.Finance_Amount =String.valueOf((Integer.valueOf(requestWrapper.loanAmountChanged))+ Integer.valueOf(requestWrapper.sumOfFundedInsurance));
                     this.Tenure=requestWrapper.tenureChanged;
                     this.CRM_IRR_Requested=requestWrapper.crmIrrChanged;
                     this.OfferDetails.offerLoanAmount ='';
                     this.OfferDetails.offerTenure= '';   
                     this.OfferDetails.offerIrr =''; 
                }
                else{
                    this.Finance_Amount =finalTerm[0].Loan_Amount__c==null?String.valueOf((Integer.valueOf(requestWrapper.loanAmount)+ Integer.valueOf(requestWrapper.sumOfFundedInsurance)))
                        :String.valueOf((Integer.valueOf(finalTerm[0].Loan_Amount__c)+ Integer.valueOf(requestWrapper.sumOfFundedInsurance)));
                    this.Tenure = finalTerm[0].Tenure__c==null?requestWrapper.tenure:finalTerm[0].Tenure__c;   
                    this.CRM_IRR_Requested = finalTerm[0].Required_CRM_IRR__c==null?requestWrapper.crmIrrRequested: String.valueOf(finalTerm[0].Required_CRM_IRR__c); 
                    this.OfferDetails.offerLoanAmount = '';
                  this.OfferDetails.offerTenure ='';
                  this.OfferDetails.offerIrr ='';
                }
                if(requestWrapper.advanceEmiFlag!=null){
                    this.Advance_EMI_Flag=requestWrapper.advanceEmiFlag;
                }
                else{
                    this.Advance_EMI_Flag = finalTerm[0].Advance_EMI__c==false?'No':'Yes';
                } 
                if (passOfferEmi==true && requestWrapper.offerEMI!=null) {//Start CISP-2408
                    this.OfferEMI = requestWrapper.offerEMI;
                }else{
                    this.OfferEMI = '';
                }//End CISP-2408
                this.PayIns.Doc_Charges = finalTerm[0].Documentation_charges__c==null?'':finalTerm[0].Documentation_charges__c;
                this.PayIns.Service_Charges =  finalTerm[0].Service_charges__c==null?'':finalTerm[0].Service_charges__c;
                this.PayIns.Mfr_Exp_Reimbursement_Amount =  finalTerm[0].Mfr_Exp_Reimburse_Amt__c==null?'':finalTerm[0].Mfr_Exp_Reimburse_Amt__c;
                this.PayIns.Dealer_Exp_Reimbursement_Amount =  finalTerm[0].Dlr_Exp_Reimburse_Amt__c==null?'':finalTerm[0].Dlr_Exp_Reimburse_Amt__c;
                
                // CISP-124
                if(requestWrapper.provisionAmount != null  && requestWrapper.provisionAmount != ''){
                    this.PayOuts.Provision_Cost = requestWrapper.provisionAmount;
                }else{
                    this.PayOuts.Provision_Cost = finalTerm[0].Provisional_Channel_Cost__c==null?'':finalTerm[0].Provisional_Channel_Cost__c;
                }
                // CISP-124
                this.PayOuts.Dlr_Incentive_Amt_Main = finalTerm[0].Dealer_incentive_amount_main_dealer__c==null?'':finalTerm[0].Dealer_incentive_amount_main_dealer__c;
                this.PayOuts.Dlr_Incentive_Amt_Sub = finalTerm[0].Dealer_incentive_amount_sub_dealer__c==null?'':finalTerm[0].Dealer_incentive_amount_sub_dealer__c;
                this.PayOuts.Mfr_Incentive_Amount = finalTerm[0].Mfr_incentive__c==null?'':finalTerm[0].Mfr_incentive__c;
                this.PayOuts.Referrer_Incentive = finalTerm[0].Rreferrer_Incentive__c==null?'':finalTerm[0].Rreferrer_Incentive__c;
                this.PayOuts.Gift_Amt = finalTerm[0].Gift_through_dealer_amount__c==null?'':finalTerm[0].Gift_through_dealer_amount__c;
                this.PayOuts.DSM_Incentive1 = finalTerm[0].DSM_Incentive1__c==null?'':finalTerm[0].DSM_Incentive1__c;
                this.PayOuts.DSM_Incentive2 = finalTerm[0].DSM_Incentive2__c==null?'':finalTerm[0].DSM_Incentive2__c;
                this.PayOuts.Covid_Ins_Prem = '';
          
            }            
        if (requestWrapper.currentScreen != 'CAM and Approval Log') {
            validate(System.Label.OfferEngine);
        }
        if(VehicleDtlList.size()>0 && VehicleDtlList[0].Loan_Application__r.LeadSource=='OLA'){//OLA-139
            this.Tenure=requestWrapper.tenureChanged;
        }
    }
    
    
    
    //Method to get the HTTP request header data
    // @Method:      getHttpRequestHeaders
    // @Created by:  Satyam More
    // @Description: Method to get the HTTP request header data
    // @Param:       ''
    // @Return:      Header required to callout the service.
    
    public override Map<String,String> getHttpRequestHeaders(){
        //Map to store HTTP request header data
        Map<String,String> requestHeaderMap = new Map<String,String>();
        requestHeaderMap.put(IntegrationConstants.CONTENT_TYPE , IntegrationConstants.CONTENT_TYPE_JSON);
        requestHeaderMap.put('IBL-Client-Id', System.Label.IBM_Client_ID);
        requestHeaderMap.put('IBL-Client-Secret', System.Label.IBM_Client_Secret);
        return requestHeaderMap;
    }
    
    //Method to validate the request data
    // @Method:      getHttpRequestHeaders
    // @Created by:  Satyam More
    // @Description: Method to validate the required input details
    // @Param:       Service name
    // @Return:      True - If all the validations are passed.
    
    public override boolean validate(String serviceName){
        if(String.isBlank(this.Lead_Id)){
            throw new IND_Exception(System.Label.LeadId);
        }
        if(String.isBlank(this.CallType)){
            throw new IND_Exception(System.Label.CallType);            
        }
        if(String.isBlank(this.Maker_ID)){
            throw new IND_Exception(System.Label.MakerId);    
        }
        if(String.isBlank(this.Product)){
            throw new IND_Exception(System.Label.ProductError);    
        }
        if(String.isBlank(this.VehicleType)){
            throw new IND_Exception(System.Label.VehicleType);    
        }
        if(String.isBlank(this.Advance_EMI_Flag)){
            throw new IND_Exception(System.Label.AdvanceEMIFlag);    
        }
        if((!( this.Product == 'PV' && this.CallType == 'Input_Net_IRR')) && (!( this.Product == 'TW' && this.CallType == 'Input_Imputed_IRR'))){
            if(String.isBlank(this.LTV)){
                throw new IND_Exception(System.Label.LTV);    
            }
        }
        
        if(String.isBlank(this.Finance_Amount)){
            throw new IND_Exception(System.Label.FinanceAmount);    
        }
        if(String.isBlank(this.Tenure)){
            throw new IND_Exception(System.Label.Tenure);    
        }
        
        if ((!( this.Product == 'PV' && this.CallType == 'Input_Net_IRR'))
            && (!( this.Product == 'TW' && this.CallType == 'Input_Imputed_IRR'))){
                if(String.isBlank(this.LTV_Based_On)){
                    throw new IND_Exception(System.Label.LTV_Based_On);    
                }
            }
        
        if(String.isBlank(this.CRM_IRR_Requested)){
            throw new IND_Exception(System.Label.CRM_IRR_Requested);    
        }
        
        if ((!( this.Product == 'PV' && this.CallType == 'Input_Net_IRR'))
            && (!( this.Product == 'TW' && this.CallType == 'Input_Imputed_IRR'))){
                if(String.isBlank(this.Monthly_Income)){
                    throw new IND_Exception(System.Label.incomeAmountMandatory);    
                }
            }
        if ((!( this.Product == 'PV' && this.CallType == 'Input_Net_IRR'))
            && (!( this.Product == 'TW' && this.CallType == 'Input_Imputed_IRR'))){
                if(String.isBlank(this.Existing_EMI)){
                    throw new IND_Exception(System.Label.ExistingEMI);    
                }
            }
        if ((!( this.Product == 'PV' && this.CallType == 'Input_Net_IRR'))
            && (!( this.Product == 'TW' && this.CallType == 'Input_Imputed_IRR'))){
                if(String.isBlank(this.Ex_Showroom_Price)){
                    throw new IND_Exception(System.Label.ExShowroomPrice);    
                }
            }
        
        return true;
    }
    
}