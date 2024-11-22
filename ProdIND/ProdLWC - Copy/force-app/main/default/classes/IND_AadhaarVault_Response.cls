/*------------------------------------------------------------
Author:        Rohan Saxena
Company:       Salesforce
Description:   This class is Response class for AadhaarVault API
Test Class:    
History
Date            Author              Comments 
-------------------------------------------------------------
28-02-2023      Rohan Saxena         Created 
------------------------------------------------------------*/
public with sharing class IND_AadhaarVault_Response extends ParentAPIResponse {  
   public class Response {
       public String status{get;set;}
		public String respDesc{get;set;}
		public List<Content> content{get;set;}
	}

	public Response response{get;set;}

	public class Content {
		public String Status{get;set;}
		public String Message{get;set;}
		public String UID_Token_No{get;set;}
		public String Vault_Reference_No{get;set;}
	}

}