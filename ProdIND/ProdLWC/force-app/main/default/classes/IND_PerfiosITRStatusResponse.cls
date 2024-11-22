/*------------------------------------------------------------
Author:        Bhushan Charde
Company:       Persistent Systems
Description:   This class is wrapper class for the Perfios ITR Status API response 
Test Class:     
History
Date            Author              Comments
-------------------------------------------------------------
12-27-2021      Bhushan Charde      Created
------------------------------------------------------------*/
public class IND_PerfiosITRStatusResponse extends ParentAPIResponse {
	
    public string perfiosTransactionId;
    public string clientTransactionId;
    public string status;
    public string error_code;
    public string error_message;
}