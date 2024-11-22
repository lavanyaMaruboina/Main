/*------------------------------------------------------------
Author:        Bhushan Charde
Company:       Persistent Systems
Description:   This class is wrapper class for the Perfios GST Online API response 
Test Class:     
History
Date            Author              Comments
-------------------------------------------------------------
12-19-2021      Bhushan Charde      Created
------------------------------------------------------------*/
public class IND_PerfiosGSTOnlineResponse extends ParentAPIResponse {
	public String expires{get;set;}
    public String generateLinkId{get;set;}
    public String clientTransactionId{get;set;}
	public String url{get;set;}
    public String transactionId{get;set;}
    public String success{get;set;}
}