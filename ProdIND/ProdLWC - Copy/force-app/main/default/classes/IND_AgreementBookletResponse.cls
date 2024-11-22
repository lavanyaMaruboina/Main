/*-------------------------------------------------------------
Author:        Bondiga Thilak
Company:       Persistent Systems
Description:   This class is wrapper class for the Agreement Booklet API response 
Test Class:     
History
Date            Author              Comments
-------------------------------------------------------------
12-22-2021      Bondiga Thilak      Created
------------------------------------------------------------*/
public class IND_AgreementBookletResponse extends ParentAPIResponse { 
   

    
	public class Response {
		public String status{get;set;}
		public String respDesc{get;set;}
		public List<Content> content{get;set;}
        //public String content{get;set;}
	}

	public Response response{get;set;}

	public class Content {
		public String Stamp_S_No{get;set;}
		public String Stamp_On{get;set;}
		public String Stamp_Printed_Location_Blcode{get;set;}
		public String Stamp_Printed_Location_BlName{get;set;}
		public String Stamp_Type{get;set;}
		public String Stamp_Value{get;set;}
		public String Stamped_For{get;set;}
		public String Stamp_Towards{get;set;}
	} 
}