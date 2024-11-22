/*------------------------------------------------------------
Author:        Bondiga Thilak
Company:       Persistent Systems
Description:   This class is wrapper class for the RCLimitCheck API response 
Test Class:     
History
Date            Author              Comments
-------------------------------------------------------------
01-28-2022      Bondiga Thilak      Created
------------------------------------------------------------*/
public class IND_RCLimitCheckResponse extends ParentAPIResponse {
    public class Response {
		public String status{get;set;}
		public String respDesc{get;set;}
		public List<Content> content{get;set;}
	}

	public Response response{get;set;}

	public class Content {
		public String No_Of_Proposals_Available{get;set;}
		public String Available_Disbursal_Amount{get;set;}
		public String Pending_Flag{get;set;}
		public String Payment_To_DSA_Flag{get;set;}
		public String RC_Limit_Cleared_Flag{get;set;}
	}

}