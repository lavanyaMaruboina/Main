/*------------------------------------------------------------
Author: Satyam More
Company: Persistent Systems
Description: This class is wrapper class for the Pact Lms Response
Test Class: 
History
Date            Author              Comments
------------------------------------------------------------- 
19-01-2022    Satyam More            Created
------------------------------------------------------------*/

public class IND_PactLmsResponse extends ParentAPIResponse {
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