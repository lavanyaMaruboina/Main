@isTest
public class IND_GeoCoderAPIResponse_Test {
		@isTest
    public static void verifyIND_GeoCoderAPIResponse(){
        IND_GeoCoderAPIResponse.Address_components objectcomponent = new IND_GeoCoderAPIResponse.Address_components();
        objectcomponent.long_name='';
        objectcomponent.short_name='';
        System.assertEquals( objectcomponent.types,null);
        
         IND_GeoCoderAPIResponse.Geometry objectGeometry = new IND_GeoCoderAPIResponse.Geometry();
        	System.assertEquals(objectGeometry.location, null);
        	System.assertEquals(objectGeometry.location_type, null);
        	System.assertEquals(objectGeometry.viewport, null);
    
      
        IND_GeoCoderAPIResponse.Plus_code objectPlus_code = new IND_GeoCoderAPIResponse.Plus_code();
        objectPlus_code.compound_code='';
        objectPlus_code.global_code='';
   		System.assertEquals(objectPlus_code.global_code, '');
        
        IND_GeoCoderAPIResponse.Results objectResults = new IND_GeoCoderAPIResponse.Results();
        	System.assertEquals(objectResults.address_components, null);
        	System.assertEquals(objectResults.formatted_address, null);
        	System.assertEquals(objectResults.plus_code, null);
        	System.assertEquals(objectResults.partial_match, null);
        	System.assertEquals(objectResults.place_id, null);
        	System.assertEquals(objectResults.types, null);
        	System.assertEquals(objectResults.geometry, null);
        
         IND_GeoCoderAPIResponse.Viewport objectViewport = new IND_GeoCoderAPIResponse.Viewport();
        	System.assertEquals(objectViewport.northeast, null);
        	System.assertEquals(objectViewport.southwest, null);
	
        IND_GeoCoderAPIResponse.Location objectLocation = new IND_GeoCoderAPIResponse.Location();
        objectLocation.lat=1.0;  
        objectLocation.lng=2.0;
        
        IND_GeoCoderAPIResponse object1 = new IND_GeoCoderAPIResponse();
           	System.assertEquals(object1.results, null);
        	System.assertEquals(object1.status, null);
            
        
         
    }
}