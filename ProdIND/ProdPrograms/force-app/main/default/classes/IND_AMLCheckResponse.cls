/*------------------------------------------------------------
Author: Vaishnavi Gadewar
Company: Persistent Systems
Description: This class is wrapper class for the AML Check Response
Test Class: IND_AMLCheckService_Test
History
Date            Author              Comments
------------------------------------------------------------- 
28-12-2021    Vaishnavi Gadewar         Created
13-1-2022     Satyam More				Modified
15-3-2022   Santhosh Mothe			Modifiled data type for score from Integer
23-3-2022   Santhosh Mothe			added params as per v6 document
------------------------------------------------------------*/

public class IND_AMLCheckResponse extends ParentAPIResponse{

	public class Status {
		public String status{get;set;}
		public String errorDetails{get;set;}
	}

	public class Fields {
		public Double score{get;set;}
		public String name{get;set;}
		public String value{get;set;}
		public String queryValue{get;set;}
	}

	public WlMatch WlMatch{get;set;}

	public class WlMatch {
		public Status status{get;set;}
		public MatchedResults matchedResults{get;set;}
	}

	public class MatchedRecords {
		public String id{get;set;}
		public String score{get;set;}
		public String listName{get;set;}
        public String address{get;set;}
		public String description{get;set;}
		public String DateOfBirth{get;set;}
		public Boolean partialKycFlag{get;set;}
		public String city{get;set;}
		public List<Fields> fields{get;set;}
	}

	public class MatchedResults {
		public Integer total{get;set;}
		public String maxScore{get;set;}
		public List<MatchedRecords> matchedRecords{get;set;}
	}
	
}