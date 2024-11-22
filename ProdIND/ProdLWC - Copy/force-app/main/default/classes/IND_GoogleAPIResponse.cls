public with sharing class IND_GoogleAPIResponse {
    public GoogleAPIResult[] results{get;set;}
    public String status{get;set;}

    public class GoogleAPIResult {
        public AddressComponent[] address_components{get;set;}
        public String formatted_address{get;set;}
        public GoogleGeometry geometry{get;set;}
        public boolean partial_match{get;set;}
        public String place_id{get;set;}
        public String[] types{get;set;}
    }

    public class AddressComponent {
        public String long_name{get;set;}
        public String short_name{get;set;}
        public String[] types{get;set;}
    }

    public class GoogleGeometry {
        public GeoLocation location{get;set;}
        public String location_type{get;set;}
        public GeoViewPort viewport{get;set;}
    }

    public class GeoLocation {
        public double lat{get;set;}
        public double lng{get;set;}
    }

    public class GeoViewPort{
        public GeoLocation northeast{get;set;}
        public GeoLocation southwest{get;set;}
    }

}