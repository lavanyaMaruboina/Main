/*------------------------------------------------------------
Author:        Bharath moka
Company:       Persistent Systems
Description:   This class is wrapper class for the Perfios IHM RECEIPT response 
Test Class:     
History
Date            Author              Comments
-------------------------------------------------------------
12-29-2021      Bharath moka      Created
------------------------------------------------------------*/

public class IND_IHMReceiptResponse extends ParentAPIResponse {    
	public class Response {
        public String status{get;set;}
		public String respDesc{get;set;}
		public List<String> content{get;set;}
	}

	public Response response{get;set;}
}