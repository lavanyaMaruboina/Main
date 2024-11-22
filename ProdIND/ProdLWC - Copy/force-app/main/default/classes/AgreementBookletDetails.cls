/*------------------------------------------------------------
Author:        Daksh Mandowara
Class Name:    AgreementBookletDetails
Description:   Wrapper clas to store agreement booklet details API  response.
------------------------------------------------------------*/
public class AgreementBookletDetails {

	public class Response {
		public String status;
		public String respDesc;
		public List<Content> content;
	}

	public class Content {
		public String Stamp_S_No;
		public String Stamp_On;
		public String Stamp_Printed_Location_Blcode;
		public String Stamp_Printed_Location_BlName;
		public String Stamp_Type;
		public String Stamp_Value;
		public String Stamped_For;
		public String Stamp_Towards;
	}

	public Response response;

	/*@Method:      parse
    * @Created by:  Daksh Mandowara
    * @Description: to parse the API respone to the object
    * @Param:       String - json
    * @Return:      Object -  AgreementBookletDetails*/
	public static AgreementBookletDetails parse(String json) {
		return (AgreementBookletDetails) System.JSON.deserialize(json, AgreementBookletDetails.class);
	}
}