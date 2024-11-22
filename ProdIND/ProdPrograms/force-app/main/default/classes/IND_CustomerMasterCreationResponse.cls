/*------------------------------------------------------------
Author:        Kranthi makkena
Company:       Persistent Systems
Description:   This class is wrapper class for the Customer Master Creation API response 
Test Class:     
History
Date            Author              Comments
-------------------------------------------------------------
12-28-2021      Kranthi makkena      Created
------------------------------------------------------------*/
public class IND_CustomerMasterCreationResponse extends ParentAPIResponse { 
    public class Response {
		public String status{get;set;}
		public String respDesc{get;set;}
		public List<Content> content{get;set;}
	}

	public Response response{get;set;}

	public class Content {
		public final String CreationStatus{get;set;}
		public final String Customer_Code{get;set;}
	} 
}