/*------------------------------------------------------------
Author: Aman Mundhada
Company: Persistent Systems
Description: This class is wrapper class response for the ITR Scan Upload Initiate API
Test Class:
History
Date            Author              Comments
------------------------------------------------------------- 
19-05-2021    Aman Mundhada            Created
------------------------------------------------------------*/
public class IND_ITRScanUploadInitiateResponse extends ParentAPIResponse{

    public String clientTransactionId;
	public String transactionInitiateId;
	public String success;
}