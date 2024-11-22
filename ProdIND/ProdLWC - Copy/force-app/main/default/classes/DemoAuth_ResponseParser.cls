/**
* @Name         ReverseStatusCRMNEXT_ResponseParser
* @Author       Raghav J
* @Company      Salesforce
* @Description  This class is to parse Service API Response. 
*/
public class DemoAuth_ResponseParser {
    public class Response {
        public Body body;
        public Header header;
    }

    public class Body {
        public DemoAuthResponse demoAuthResponse;
    }

    public class DemoAuthResponse {
        public String ResponseMsg;
        public String ResponseCode;
    }

    public class Header {
        public String status;
        public String channelId;
        public String requestUUID;
    }

    public Response response;
    public static DemoAuth_ResponseParser parse(String json) {
		return (DemoAuth_ResponseParser) System.JSON.deserialize(json, DemoAuth_ResponseParser.class);
	}
}