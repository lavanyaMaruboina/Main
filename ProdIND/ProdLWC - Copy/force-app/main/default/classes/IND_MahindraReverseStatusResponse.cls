/*------------------------------------------------------------
Author: Chaynnitt Agarwal 
Company: Salesforce 
Description: This class is wrapper class for the Reverse Status Response for Mahindra
History
Date            Author                    Comments
------------------------------------------------------------- 
10-05-2024     Chaynnitt Agarwal           Created
------------------------------------------------------------*/

public with sharing class IND_MahindraReverseStatusResponse extends ParentAPIResponse{
		public String status{get;set;}
		public String message{get;set;}
        public String updated_status{get;set;}
        public String enquiry_id{get;set;}
}