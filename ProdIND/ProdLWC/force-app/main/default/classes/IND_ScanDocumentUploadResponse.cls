/*------------------------------------------------------------
Author: Aman Mundhada
Company: Persistent Systems
Description: This class is wrapper class Error response for the IBB API
Test Class:
History
Date            Author              Comments
------------------------------------------------------------- 
05-04-2021    Aman Mundhada            Created
------------------------------------------------------------*/
public class IND_ScanDocumentUploadResponse extends ParentAPIResponse {
   public cls_file file;
   public class cls_file {
		public String fileId;
	}
}