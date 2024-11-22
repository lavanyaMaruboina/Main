/*------------------------------------------------------------
Author:        Bondiga Thilak
Company:       Persistent Systems
Description:   This class is wrapper class for the CAM Portfolio API response 
Test Class:     
History
Date            Author              Comments
-------------------------------------------------------------
12-22-2021      Bondiga Thilak      Created
-------------------------------------------------------------*/
public class IND_CAMPortfolioResponse extends ParentAPIResponse {
   public class Response {
		public String status{get;set;}
		public String respDesc{get;set;}
		public List<Content> content{get;set;}
	}

	public Response response{get;set;}

	public class DPD_DT {
		public final String Deal_No{get;set;}
		public final String Curr_Month{get;set;}
		public final String Advance{get;set;}
		public final String OverDue{get;set;}
		public final String SOH{get;set;}
		public final String One_Month{get;set;}
		public final String Two_Month{get;set;}
		public final String Three_Month{get;set;}
		public final String Four_Month{get;set;}
		public final String Five_Month{get;set;}
		public final String Six_Month{get;set;}
		public final String Seven_12Month{get;set;}
		public final String Above_12Month{get;set;}
		public final String OD_Category{get;set;}
		public final String Ageing{get;set;}
		public final String DPD{get;set;}
		public final String Status_Flag{get;set;}
		public final String Deal_Date{get;set;}
	}

	public class Content {
		public final List<PANA_DT> PANA_DT{get;set;}
		public final List<DPD_DT> DPD_DT{get;set;}
		public final List<CIBIL_Dt> CIBIL_Dt{get;set;}
		public final List<Non_IBL_Exposure> Non_IBL_Exposure{get;set;}
		public final List<CIBIL_Suit_Filed> CIBIL_Suit_Filed{get;set;}
	}

	public class PANA_DT {
        public final String Segment{get;set;}
		public final String Name{get;set;}
		public final String Year{get;set;}
		public final String Tot_Deals{get;set;}
		public final String Adv_Nos{get;set;}
		public final String Adv_Amt{get;set;}
		public final String NoDue_Nos{get;set;}
		public final String NoDue_LOS{get;set;}
		public final String STD1_Nos{get;set;}
		public final String STD1_LOS{get;set;}
		public final String STD2_Nos{get;set;}
		public final String STD2_LOS{get;set;}
		public final String STD3_Nos{get;set;}
		public final String STD3_LOS{get;set;}
		public final String NPA1_Nos{get;set;}
		public final String NPA1_LOS{get;set;}
		public final String NPA2_Nos{get;set;}
		public final String NPA2_LOS{get;set;}
		public final String NPA3_Nos{get;set;}
		public final String NPA3_LOS{get;set;}
		public final String NPAA_Nos{get;set;}
		public final String NPAA_LOS{get;set;}
		public final String Tot_Nos{get;set;}
		public final String Tot_LOS{get;set;}
	}
	public class CIBIL_Dt {
		public final String CIC_No{get;set;}
		public final String Account_Segment_Tag{get;set;}
		public final String Reporting_Member_ShortName{get;set;}
		public final String Account_Number{get;set;}
		public final String Account_Type{get;set;}
		public final String Owenership_Indicator{get;set;}
		public final String DateOpened_Or_Disbursed{get;set;}
		public final String Date_Of_Last_Payment{get;set;}
		public final String Date_Closed{get;set;}
		public final String Date_Reported{get;set;}
		public final String HighCredit_Or_SanctionedAmount{get;set;}
		public final String CurrentBalance{get;set;}
		public final String AmountOverdue{get;set;}
		public final String Payment_History1{get;set;}
		public final String Payment_History2{get;set;}
		public final String Payment_History_StartDate{get;set;}
		public final String Payment_History_EndDate{get;set;}
		public final String SuitFiledOrWilfulDefault{get;set;}
        public final String WrittenOffAndSettled{get;set;}
		public final String ValueOfCollateral{get;set;}
		public final String TypeOfCollateral{get;set;}
		public final String CreditLimit{get;set;}
		public final String CashLimit{get;set;}
		public final String RateOfInterest{get;set;}
		public final String RepaymentTenure{get;set;}
		public final String EmiAmount{get;set;}
		public final String PaymentFrequency{get;set;}
		public final String ActualPaymentAmount{get;set;}
		public final String WrittenoffAmountTotal{get;set;}
		public final String WrittenoffAmountPrincipal{get;set;}
		public final String SettlementAmount{get;set;}
	}
	public class Non_IBL_Exposure {
        public final String Application_No{get;set;}
		public final String CIC_No{get;set;}
		public final String Account_Type{get;set;}
		public final String Account_Type_Desc{get;set;}
		public final String Ownership{get;set;}
		public final String OpenDate{get;set;}
		public final String LastPaymentDate{get;set;}
		public final String HighCredit{get;set;}
		public final String CurrentBalance{get;set;}
		public final String AmountOverdue{get;set;}
		public final String WrittenoffAmountTotal{get;set;}
		public final String ReasonforOverdue{get;set;}
		public final String FinancierCode{get;set;}
		public final String FinanicerName{get;set;}
		public final String Maker_Id{get;set;}
		public final String Maker_Date{get;set;}
		public final String Expousure_Flag{get;set;}
		public final String Customer{get;set;}
	}

	public class CIBIL_Suit_Filed {
        public final String Application_No {get;set;} 
		public final String Entity_Type {get;set;} 
		public final String Type {get;set;} 
		public final String CIC_No {get;set;} 
		public final String Score {get;set;} 
		public final String HighCredit_Or_SanctionedAmount {get;set;} 
		public final String Current_Balance {get;set;} 
		public final String RecentDate {get;set;} 
		public final String OldestDate {get;set;} 
		public final String Amount_Overdue {get;set;} 
		public final String CibilDecision {get;set;} 
		public final String Month_Overdue {get;set;} 
		public final String NoOfEnLtSixMon {get;set;} 
		public final String WrittenoffAmountTotal {get;set;} 
		public final String SuitFiledOrWilfulDefault {get;set;} 
		public final String CRIFScore_Desc {get;set;} 
	}
}