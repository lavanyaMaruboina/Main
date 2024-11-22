/*------------------------------------------------------------
Author: Satyam More
Company: Persistent Systems
Description: This class is wrapper class for the Vahan Vehicle Valuation response
Test Class: 
History
Date            Author              Comments
------------------------------------------------------------- 
20-12-2021    Satyam More            Created
------------------------------------------------------------*/

public class IND_VahanVehicleValuationResponse extends ParentAPIResponse {
	public Response response;
    public class Response {
		public String status;
		public String respDesc;
		public List <String> content;
	}	
    
    
    public static IND_VahanVehicleValuationResponse parse(String json) {
		return (IND_VahanVehicleValuationResponse) System.JSON.deserialize(json, IND_VahanVehicleValuationResponse.class);
	}
}