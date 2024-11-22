/**
* @Name         ReverseStatusCRMNEXT_ResponseParser
* @Author       Raghav J
* @Company      Salesforce
* @Description  This class is to parse Service API Response. 
*/
public class ReverseStatusCRMNEXT_ResponseParser {
    public class Response {
		public List<Content> content;
		public String respDesc;
		public String status;
	}

	public Response response;

    public class Content {
	}

    public static ReverseStatusCRMNEXT_ResponseParser parse(String json) {
		return (ReverseStatusCRMNEXT_ResponseParser) System.JSON.deserialize(json, ReverseStatusCRMNEXT_ResponseParser.class);
	}
    
}