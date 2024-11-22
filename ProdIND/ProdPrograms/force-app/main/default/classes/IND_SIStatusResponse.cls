/*------------------------------------------------------------
Author:        Bondiga Thilak
Company:       Persistent Systems
Description:   This class is wrapper class for the SIStatus API response 
Test Class:     
History
Date            Author              Comments
-------------------------------------------------------------
01-02-2021      Bondiga Thilak      Created 
------------------------------------------------------------*/
public class IND_SIStatusResponse extends ParentAPIResponse {
    public class Response {
		public String status{get;set;}
		public String respDesc{get;set;}
		public List<Content> content{get;set;}
	}

	public Response response{get;set;}

	public class Content {
		public String Deal_No{get;set;}
		public String Status{get;set;}
	}
}