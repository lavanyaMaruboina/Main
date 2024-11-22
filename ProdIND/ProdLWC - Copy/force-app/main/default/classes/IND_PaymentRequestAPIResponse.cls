/*------------------------------------------------------------
Author: Neeraj Mehethrajkar
Company: Salesforce
Description: This class is wrapper class for the Payment Request API Response. //SFTRAC-241
Test Class: 
History
Date            Author              Comments
------------------------------------------------------------- 
29-11-2023    Neeraj Mehethrajkar    Created
------------------------------------------------------------*/
public with sharing class IND_PaymentRequestAPIResponse extends ParentAPIResponse {
    public class Response {
		public String status;
		public String respDesc;
		public List<Content> content;
	}

	public Response response;

	public class Content {
		public String CreationStatus;
	}
}