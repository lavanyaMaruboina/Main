/*------------------------------------------------------------
Author: Aman Mundhada
Company: Persistent Systems
Description: This class is wrapper class Error response for the IBB API
Test Class:
History
Date            Author              Comments
------------------------------------------------------------- 
02-05-2021    Aman Mundhada            Created
------------------------------------------------------------*/
public class ScanUploadErrorResponse extends ParentAPIResponse {
    
    public Error error;

	public class Error {
		public String message;
		public String code;
	}

}