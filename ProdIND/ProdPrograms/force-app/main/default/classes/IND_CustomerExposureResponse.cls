/*------------------------------------------------------------
Author:        Bondiga Thilak
Company:       Persistent Systems
Description:   This class is wrapper class for the Customer Exposure API response 
Test Class:     
History
Date            Author              Comments
-------------------------------------------------------------
12-22-2021      Bondiga Thilak      Created
------------------------------------------------------------*/
public class IND_CustomerExposureResponse extends ParentAPIResponse {
    public class Family_Exposure {
		public final List<RS1> RS1{get;set;}
		public final List<RS2> RS2{get;set;}
	}

	public class RS1_Z {
	}

	public class Lien {
		public final List<Table> Table{get;set;}
	}
	public class RS2 {
		public final String Customer{get;set;}
		public final String Customer_Relation{get;set;}
	}

	public class Response {
		public final String status{get;set;}
		public final String respDesc{get;set;}
		public final List<Content> content{get;set;}
	}

	public class RS1 {
		public final String Deal_No{get;set;}
		public final String Product{get;set;}
		public final String used{get;set;}
		public final Double Finance_Amt{get;set;}
		public final String Deal_Date{get;set;}
		public final String Status_Flag{get;set;}
		public final Integer Write_Off{get;set;}
		public final Integer Waiver{get;set;}
		public final Double Over_Due{get;set;}
		public final Double DPD{get;set;}
		public final Integer Peak_Delay{get;set;}
		public final Integer Average_Delay{get;set;}
		public final Double SOH{get;set;}
		public final Double Deal_Ageing{get;set;}
		public final String Deal_Stage{get;set;}
		public final Double Guaranteed_SOH{get;set;}
		public final Double Guaranteed_OD{get;set;}
		public final String Product_Variant_Name{get;set;}
		public final Double Agreement_Amt{get;set;}
		public final String Manufacture_Date{get;set;}
		public final Double AD{get;set;}
		public final Integer PD{get;set;}
		public final String IBLSeasoning{get;set;}
		public final Double Amt_Paid{get;set;}
		public final String RCNo{get;set;}
	}

	

	public class Table {
		public final String Deal_No{get;set;}
		public final String Lien_No{get;set;}
		public final String Lien_Type{get;set;}
		public final String Source_Deal_No{get;set;}
		public final String Lien_Marking_Period{get;set;}
		public final String Lien_Maker_Date{get;set;}
		public final String Lien_Request_By{get;set;}
		public final String Lien_Marking_Reason{get;set;}
	}

	public Response response{get;set;}

	public class Content {
		public final String Customer_Code{get;set;}
		public final List<Customer_Exposure> Customer_Exposure{get;set;}
		public final Family_Exposure Family_Exposure{get;set;}
		public final List<Lien> Lien{get;set;}
		public final ChequeDetails ChequeDetails{get;set;}
	}

	public class ChequeDetails {
		public final Integer ChequeReturnCount{get;set;}
		public final String Min_Deal_Date{get;set;}
	}

	public class Customer_Exposure {
		public final String Deal_No{get;set;}
		public final String Product{get;set;}
		public final String used{get;set;}
		public final Double Finance_Amt{get;set;}
		public final String Deal_Date{get;set;}
		public final String Status_Flag{get;set;}
		public final Integer Write_Off{get;set;}
		public final Integer Waiver{get;set;}
		public final Double Over_Due{get;set;}
		public final Double DPD{get;set;}
		public final Integer Peak_Delay{get;set;}
		public final Integer Average_Delay{get;set;}
		public final Double SOH{get;set;}
		public final Double Deal_Ageing{get;set;}
		public final String Deal_Stage{get;set;}
		public final Double Guaranteed_SOH{get;set;}
		public final Double Guaranteed_OD{get;set;}
		public final String Product_Variant_Name{get;set;}
		public final Double Sanctioned_Amt{get;set;}
		public final String Mor1{get;set;}
		public final String Mor2{get;set;}
		public final Double AD{get;set;}
		public final Integer PD{get;set;}
		public final String IBLSeasoning{get;set;}
		public final Double Current_Demand{get;set;}
		public final String RCNo{get;set;}
	}

	public class Family_Exposure_Z {
		public final List<RS1_Z> RS1{get;set;}
		public final List<RS2> RS2{get;set;}
	}
}