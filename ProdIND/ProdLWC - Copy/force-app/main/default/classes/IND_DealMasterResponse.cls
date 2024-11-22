/*------------------------------------------------------------
Author:        Bondiga Thilak
Company:       Persistent Systems
Description:   This class is wrapper class for the Deal Master API response 
Test Class:     
History
Date            Author              Comments
-------------------------------------------------------------
12-22-2021      Bondiga Thilak      Created
01-31-2022      Bondiga Thilak      modified 
------------------------------------------------------------*/
public class IND_DealMasterResponse extends ParentAPIResponse {
    
    public class Response {
		public String status{get;set;}
		public String respDesc{get;set;}
		public List<Content> content{get;set;}
	}

	public Response response{get;set;}

	public class Content {
		public String DealNumber{get;set;}
		public String DealNoExists{get;set;}
		public String StatusFlag{get;set;}
		public String Engine_Number{get;set;}
		public String Chassis_Number{get;set;}
		public String Make{get;set;}
		public String Model{get;set;}
		public String Variant{get;set;}
		public String Manufacture_Year_Month{get;set;}
		public String Owner_Name{get;set;}
		public String No_of_Ownership{get;set;}
		public String Insurance_Number{get;set;}
		public String Insurer_Name{get;set;}
		public String Ins_Issuance_Date{get;set;}
		public String Ins_Expiry_Date{get;set;}
		public String Owner_Contact_Number{get;set;}
		public String Vehicle_Place_of_Valuation{get;set;}
	}
}