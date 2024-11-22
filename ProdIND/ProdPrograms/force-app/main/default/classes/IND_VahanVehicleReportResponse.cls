/*------------------------------------------------------------
Author: Satyam More
Company: Persistent Systems
Description: This class is wrapper class for the Vahan Vehicle Report response
Test Class: 
History
Date            Author              Comments
------------------------------------------------------------- 
04-01-2022    Satyam More            Created
------------------------------------------------------------*/

public class IND_VahanVehicleReportResponse extends ParentAPIResponse{

    public Response response;
    public class Response {
		public String status;
		public String respDesc;
		public List<Content> content;
	}


	public class Content {
		public String Deal_No;
		public String Registration_No;
		public String Engine_No;
		public String Vehicle_Class;
		public String Chassis_No;
		public String Purchase_Date;
		public String Fitness_Upto;
		public String Registration_Date;
		public String Dealer;
		public String Body_Type;
		public String Owner_Sr_No;
		public String Manufacturer;
		public String Maker_Model;
		public String Seating_Capacity;
		public String Standing_Capacity;
		public String Wt_Laden;
		public String Gross_Vehicle_Weight;
		public String Fuel;
		public String Cubic_Capacity;
		public String Wheel_Base;
		public String Pan_Gir;
		public String No_Of_Cylinders;
		public String HorsePower;
		public String Color;
		public String Sale_Amount;
		public String Owner_Name;
		public String Father_name;
		public String Present_Address1;
		public String Present_Address2;
		public String Present_Address3;
		public String Present_Address4;
		public String Insurance_Number;
		public String Insurer_Name;
		public String Ins_Issuance_Date;
		public String Ins_Expiry_Date;
		public String Owner_Contact_Number;
		public String Vehicle_Place_of_Valuation;
		public String Financier_Name; //SFTRAC-2028
	}

    public static IND_VahanVehicleReportResponse parse(String json) {
		return (IND_VahanVehicleReportResponse) System.JSON.deserialize(json, IND_VahanVehicleReportResponse.class);
	}
    
    
}