/*------------------------------------------------------------
Author: Rohan Saxena
Company: Salesforce
Description: This class is wrapper class for the DSA Offer Engine response 
Test Class: 
History
Date            Author              Comments
------------------------------------------------------------- 
06-09-2022    Rohan Saxena           Created
------------------------------------------------------------*/
public class IND_OfferEngineResponseDSA extends ParentAPIResponse{
    
    public String requestTime {get;set;} 
    public String responseTime {get;set;} 
    public Integer executionTimeInMS {get;set;} 
    public String version {get;set;} 
    public String callType {get;set;} 
    public Integer applicationHitCount {get;set;} 
    public String transactionID {get;set;} 
    public Application application {get;set;} 
    public Object responseStatus {get;set;} 
    public Object error {get;set;} 
    
    
    public class OfferEngineDecision {
        public Double minLoanAmt {get;set;} 
        public Double maxLoanAmt {get;set;} 
        public Double minLoanAmtSlider {get;set;} 
        public Double maxLoanAmtSlider {get;set;} 
        public Double displayLoanAmt {get;set;} 
        public Double minTenure {get;set;} 
        public Double maxTenure {get;set;} 
        public Double minTenureSlider {get;set;} 
        public Double maxTenureSlider {get;set;} 
        public Double displayTenure {get;set;} 
        public Double displayEMI {get;set;} 
        public Double displayCrmIrr {get;set;} 
        public Double netPayIns {get;set;} 
        public Double netPayOuts {get;set;} 
        public Double displayImputedIrr {get;set;} 
        public Double netIrr {get;set;} 
        public Double grossIrr {get;set;} 
        public Boolean stopJourneyFlag {get;set;} 
        public Double bankCrmIrr {get;set;} 
        public Double averageCrmIrr {get;set;}
        public String agreementAmount {get;set;}
        public List<AmortizationSchedule> amortizationSchedule {get;set;}
        
    }
    
    public class OfferEngineDetails {
        public OfferEngineDecision offerEngineDecision {get;set;} 
        public payins payins {get;set;} 
        public payouts payouts {get;set;}
        public String loanDealDate {get;set;}
        public String installmentPattern {get;set;}
        public String firstEMIdate {get;set;}
        public String secondEMIdate {get;set;}
    }

    public class payins {
        public Double serviceCharges {get;set;} 
        public Double docCharges {get;set;}
    }

    public class payouts {
        public Double provisionCost {get;set;} 
        public Double dlrIncentiveAmtMain {get;set;}
        public Double mfrIncentiveAmt {get;set;}
    }
    
    
    public class Application {
        public OfferEngineDetails offerEngineDetails {get;set;} 
        public String tableCode {get;set;}
        public LoanDetails loanDetails{get;set;}
        public string interestVersionNo{get;set;}
        public Double drPenalInterest{get;set;}
    }
    public class LoanDetails{
        public string purposeOfPurchase {get;set;} 
        public Double irr {get;set;} 
        public Double offerEMI {get;set;} 
        public Double mclrRate {get;set;} 
        public Double tenure {get;set;} 
        public Double loanAmount {get;set;} 
        public Double bankingExposureAmount {get;set;} 
        public Double downPayment {get;set;} 
        public Double serviceCharge {get;set;} 
        public Double documentCharge {get;set;} 
    }  
    
    public class AmortizationSchedule {
        public String emiDueDate{get;set;}
        public Double installmentNumber{get;set;}
        public Double installmentAmount{get;set;}
        public Double openingPrincipal{get;set;}
        public Double pricipalComponent{get;set;}
        public Double interestComponent{get;set;}
        public Double closingPrincipal{get;set;}
    }
}