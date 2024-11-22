/*------------------------------------------------------------
Author: Satyam More
Company: Persistent Systems
Description: This class is wrapper class for the Offer Engine response
Test Class: 
History
Date            Author              Comments
------------------------------------------------------------- 
28-12-2021    Satyam More            Created
------------------------------------------------------------*/

public class IND_OfferEngineResponse  extends ParentAPIResponse {
	public String Min_Loan_Amt_Slider{get;set;}
	public String Max_Loan_Amt_Slider{get;set;}
	public String Loan_Amt{get;set;}
	public String Min_Tenure_Slider{get;set;}
	public String Max_Tenure_Slider{get;set;}
	public String Tenure{get;set;}
	public String EMI{get;set;}
	public String CRM_IRR{get;set;}
	public String Net_Pay_Ins{get;set;}
	public String Net_Pay_Outs{get;set;}
	public String Gross_IRR_Offered{get;set;}
	public String Net_IRR_Offered{get;set;}
	public String Stop_Journey_Flag{get;set;}
    public String Final_CRM_IRR{get;set;}
    public String Final_Gross_IRR{get;set;}
    public String Imputed_IRR_Offered{get;set;}
    public String Final_Net_IRR{get;set;}
	public string TableCode {get;set;}//CISP-16547
	public string Interest_VersionNo {get;set;}//CISP-16547
	public string DR_PenalInterest {get;set;}//CISP-16547
	public string mclrRate {get;set;} //CISP-16547
	public String agreementAmount {get;set;}
	public String loanDealDate {get;set;}
    public String installmentPattern {get;set;}
    public String firstEMIdate {get;set;}
    public String secondEMIdate {get;set;}
    public List<AmortizationSchedule> amortizationSchedule {get;set;}

    public class AmortizationSchedule {
        public String emiDueDate{get;set;}
        public String installmentNumber{get;set;}
        public String installmentAmount{get;set;}
        public String openingPrincipal{get;set;}
        public String pricipalComponent{get;set;}
        public String interestComponent{get;set;}
        public String closingPrincipal{get;set;}
    }
}