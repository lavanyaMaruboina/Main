/**
* @Name         Service_API_ResponseParser
* @Author       Raghav J
* @Company      Salesforce
* @Description  This class is to parse Service API Response. 
*/
public class Service_API_ResponseParser {
    public class Response {
		public List<String> content;
		public String respDesc;
		public String status;
	}

	public Response response;

    public class Content {
	}

    public static Service_API_ResponseParser parse(String json) {
		return (Service_API_ResponseParser) System.JSON.deserialize(json, Service_API_ResponseParser.class);
	}
}