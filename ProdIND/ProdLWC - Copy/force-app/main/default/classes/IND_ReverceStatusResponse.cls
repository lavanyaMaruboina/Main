/*------------------------------------------------------------
Author: Parimal Shinde & Vishal gadhave 
Company: Nanostuffs 
Description: This class is wrapper class for the Reverse Status Response
Test Class: 
History
Date            Author                                    Comments
------------------------------------------------------------- 
15-09-2022     Parimal Shinde & Vishal gadhave             Created
------------------------------------------------------------*/

public with sharing class IND_ReverceStatusResponse extends ParentAPIResponse
{
    public response response;
	public class response {
		public String status{get;set;}
		public String respDesc{get;set;}
		public content[] content{get;set;}
	}
	public class content {
		public String status{get;set;}
		public String message{get;set;}
		public String updated_status{get;set;}
		public String enquiry_id{get;set;}
		public String unique_id{get;set;}
        public String success{get;set;}
		public error_message error_message{get;set;}
        public List<errors> errors{get;set;}
	}
	public class error_message {
	}
    public class errors{
		public String errorCode{get;set;}
		public String errorMessage{get;set;}
	}
}