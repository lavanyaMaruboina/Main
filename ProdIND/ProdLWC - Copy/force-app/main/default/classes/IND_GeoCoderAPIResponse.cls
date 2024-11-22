/*------------------------------------------------------------
Author:        Santhosh Mothe
Company:       Persistent Systems
Description:   This class contains methods to process request and response for google callout.
Inputs:        None 
Test Class:     
History
Date            Author              Comments
-------------------------------------------------------------
16-03-2022      Santhosh Mothe       Created
------------------------------------------------------------*/
public class IND_GeoCoderAPIResponse extends ParentAPIResponse {
	
    
    public class Address_components {
        public String long_name{get;set;}
		public String short_name{get;set;}
		public List<String> types{get;set;}
	}

	public class Geometry {
		public Location location{get;set;}
		public String location_type{get;set;}
		public Viewport viewport{get;set;}
	}

	public class Plus_code {
		public String compound_code{get;set;}
		public String global_code{get;set;}
	}

	public List<Results> results{get;set;}
	public String status{get;set;}

	public class Results {
		public List<Address_components> address_components{get;set;}
		public String formatted_address{get;set;}
		public Geometry geometry{get;set;}
		public Boolean partial_match{get;set;}
		public String place_id{get;set;}
		public Plus_code plus_code{get;set;}
		public List<String> types{get;set;}
	}

	public class Viewport {
		public Location northeast{get;set;}
		public Location southwest{get;set;}
	}

	public class Location {
		public Double lat{get;set;}
		public Double lng{get;set;}
	}
	
}