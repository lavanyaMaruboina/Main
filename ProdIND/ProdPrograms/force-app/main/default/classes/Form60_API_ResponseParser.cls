/** 
* @Name         Form60_API_ResponseParser 
* @Author       Raghav J
* @Company      Salesforce
* @Description  This class contains is to parse Form 60 Response. 
*/
public class Form60_API_ResponseParser {
    public class Response {
		public List<Content> content;
		public String respDesc;
		public String status;
	}

	public Response response;

    public class Content {
	}

    public static Form60_API_ResponseParser parse(String json) {
		return (Form60_API_ResponseParser) System.JSON.deserialize(json, Form60_API_ResponseParser.class);
	}
}