/*------------------------------------------------------------
Author:        Bhushan Charde
Company:       Persistent Systems
Description:   This class is wrapper class for the Perfios GST Status API response 
Test Class:     
History
Date            Author              Comments
-------------------------------------------------------------
12-27-2021      Bhushan Charde      Created
------------------------------------------------------------*/
public class IND_PerfiosGSTStatusResponse extends ParentAPIResponse {
    
    public string perfiosTransactionId{get;set;}
    public string clientTransactionId{get;set;}
    public string error_code{get;set;}
    public string error_message{get;set;}
	public string status{get;set;}    
}