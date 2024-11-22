/*------------------------------------------------------------
Author:        Bondiga Thilak
Company:       Persistent Systems
Description:   This class is wrapper class for the NeSL Agreement Status API response 
Test Class:     
History
Date            Author              Comments
-------------------------------------------------------------
12-22-2021      Bondiga Thilak      Created
------------------------------------------------------------*/
public class IND_NeSLAgreementStatusResponse extends ParentAPIResponse {
    
	public class Response {
		public String status;
		public String respDesc;
		public List<Content> content;
	}

	public Response response;

	public class Content {
		public String Status_Code;
		public String Status_Description;
		public String Esign_Link;
	}

    
}