/**
* @Name         CRIFF_APICall_ResponseParser
* @Author       Aakash Jaiswar
* @Company      Salesforce
* @Description  This class contains is to parse CRIFF Response.

* Test Class:   
*/
public class CRIFF_APICall_ResponseParser {
    
    public class Response {
		public List<Content> content;
		public String respDesc;
		public String status;
	}

	public Response response;

	public class Content {
		public String ErrorDescription;
		public String ErrorCode;
		public String ReportId;
		public String RequestDate;
		public String UniqueRefNo;
	}

	
	public static CRIFF_APICall_ResponseParser parse(String json) {
		return (CRIFF_APICall_ResponseParser) System.JSON.deserialize(json, CRIFF_APICall_ResponseParser.class);
	}

}