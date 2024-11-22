/*------------------------------------------------------------
Author:        Manish Baldota
Company:       Persistent
Description:   This class is wrapper class for Perfios Bank Account Statement API
Test Class:     
History
Date            Author              Comments
-------------------------------------------------------------
12-21-2021      Manish Baldota      Created
------------------------------------------------------------*/
public class IND_PerfiosBSTransactionStatusResponse extends ParentAPIResponse{
	public String ClientTransactionId{get;set;}	//15122021192049869
	public String perfiosTransactionId{get;set;}	//747P1639576361433
	public String Status{get;set;}	//success
	public String error_message{get;set;}	//E_NO_ERROR
	public String error_code{get;set;}	//200
	public String files_Availabilty{get;set;}	//available
	public String Reason{get;set;}	//
}