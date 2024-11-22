/*------------------------------------------------------------
Author: Aman Mundhada
Company: Persistent Systems
Description: This class is wrapper class Error response for the Scan Upload Initiate API
Test Class:
History
Date            Author              Comments
------------------------------------------------------------- 
19-05-2021    Aman Mundhada            Created
------------------------------------------------------------*/
public class ScanInitiateBSResponse extends ParentAPIResponse {
   public TransactionInitiate transactionInitiate;

	public class TransactionInitiate {
		public String perfiosTransactionId;
	}
}