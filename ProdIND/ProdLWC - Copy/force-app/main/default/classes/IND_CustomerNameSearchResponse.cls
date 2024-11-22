/*------------------------------------------------------------
Author:        Bhushan Charde
Company:       Persistent Systems
Description:   This class is wrapper class for the Customer Name Search response 
Test Class:    IND_CustomerNameSearchService_Test 
History
Date            Author              Comments
-------------------------------------------------------------
12-01-2022      Bhushan Charde      Created
------------------------------------------------------------*/
public class IND_CustomerNameSearchResponse extends ParentAPIResponse {
    
    public Response response{get;set;}
	public class Response {
		public final String status{get;set;}
		public final String respDesc{get;set;}
		public List<Content> content{get;set;}
	}

	public class Content {
		public final String Customer_Code{get;set;}
		public final String Customer_Name{get;set;}
        public final String Flag{get;set;}
        public final String Description{get;set;}
	}
}