/*------------------------------------------------------------
Author: Sharad Kathane
Company: Persistent Systems
Description: This class is wrapper class for the Vehicle Dedupe Response
Test Class: 
History
Date            Author              Comments
------------------------------------------------------------- 
27-10-2021    Sharad Kathane            Created
------------------------------------------------------------*/

public class IND_VehicleDedupeResponse extends ParentAPIResponse{
    //public String Message;
    //public String Flag;
    //public String Description;

    public Response response;
    public class Response {
		public String status;
		public String respDesc;
		public List<Content> content;
	}

	public class Content {
		public final String Description;
		public final String NOC_Number_as_per_DB;
		public final String Proceed_Flag;
	}
    
    
     public static IND_VehicleDedupeResponse parse(String json) {
		return (IND_VehicleDedupeResponse) System.JSON.deserialize(json, IND_VehicleDedupeResponse.class);
	}
}