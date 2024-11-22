/*
* @Author	: Sharad Kathane
* Version 	: Initial
* Date		: 08-10-2021	
* Description:  Base class for all all HTTP API response. This class will be extended by by all the API reponse class
* 				 common functionality required by response classes should be added in this class
*/
public virtual class ParentAPIResponse {
    public sObject body{get;set;}
}