/*------------------------------------------------------------
Author: Satyam More
Company: Persistent Systems
Description: This class is wrapper class for the CarWale Prices response
Test Class: IND_CarwalePricesService_Test
History
Date            Author              Comments
------------------------------------------------------------- 
21-12-2021    Satyam More            Created
------------------------------------------------------------*/

public class IND_CarwalePricesResponse extends ParentAPIResponse{
public class Response {
		public String status{get;set;}
		public String respDesc{get;set;}
		public List<Content> content{get;set;}
	}

	public Response response{get;set;}

	public class Content {
		public Boolean isMetallic{get;set;}
		public List<PricesList> pricesList{get;set;}
		public Integer nearByCityId{get;set;}
		public String nearByCityName{get;set;}
	}

	public class PricesList {
		public Integer value{get;set;}
		public Integer type{get;set;}
		public Integer id{get;set;}
		public String name{get;set;}
	}

}