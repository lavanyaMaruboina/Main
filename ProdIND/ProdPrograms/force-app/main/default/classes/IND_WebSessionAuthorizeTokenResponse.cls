/*------------------------------------------------------------
Author: Santhosh Mothe
Company: Persistent Systems
Description: This class is wrapper class for the web session authorize token for cibil and equifax
Test Class: 
History
Date            Author              Comments
------------------------------------------------------------- 
15-03-2022    Santhosh Mothe            Created
------------------------------------------------------------*/
public class IND_WebSessionAuthorizeTokenResponse extends ParentAPIResponse{
	public String SessionId{get;set;}
	public String Cibil_Report_Url{get;set;}
}