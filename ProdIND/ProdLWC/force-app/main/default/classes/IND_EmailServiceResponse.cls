/*------------------------------------------------------------
Author: Satyam More
Company: Persistent Systems
Description: This class is wrapper class for the Email Service response
Test Class: 
History
Date            Author              Comments
------------------------------------------------------------- 
03-01-2022    Satyam More            Created
------------------------------------------------------------*/

public class IND_EmailServiceResponse extends ParentAPIResponse {
 
    public Response response;
    public class Response {
		public String status{get;set;}
		public String respDesc{get;set;}
		public List<String> content{get;set;}
	}  
}