@isTest
public class IND_GoogleAPIResponseTest {

    @isTest
    public static void verifyIND_GoogleAPIResponse(){
        IND_GoogleAPIResponse.GoogleAPIResult resGoogleAPIResult =new IND_GoogleAPIResponse.GoogleAPIResult();
        System.assertEquals(resGoogleAPIResult.address_components,null );
         System.assertEquals(resGoogleAPIResult.formatted_address,null );
         System.assertEquals(resGoogleAPIResult.geometry,null );
         System.assertEquals(resGoogleAPIResult.partial_match,null );
         System.assertEquals(resGoogleAPIResult.place_id,null );
         System.assertEquals(resGoogleAPIResult.types,null );
        
        IND_GoogleAPIResponse.AddressComponent resAddressComponent =new IND_GoogleAPIResponse.AddressComponent();
        System.assertEquals(resAddressComponent.long_name,null );
         System.assertEquals(resAddressComponent.short_name,null );
        System.assertEquals(resAddressComponent.types,null );
        
        IND_GoogleAPIResponse.GoogleGeometry resGoogleGeometry =new IND_GoogleAPIResponse.GoogleGeometry();
        System.assertEquals(resGoogleGeometry.location,null );
         System.assertEquals(resGoogleGeometry.location_type,null );
        System.assertEquals(resGoogleGeometry.viewport,null );
        
        IND_GoogleAPIResponse.GeoLocation resGeoLocation =new IND_GoogleAPIResponse.GeoLocation();
        System.assertEquals(resGeoLocation.lat,null );
         System.assertEquals(resGeoLocation.lng,null );
        
        IND_GoogleAPIResponse.GeoViewPort resGeoViewPort =new IND_GoogleAPIResponse.GeoViewPort();
        System.assertEquals(resGeoViewPort.northeast,null);
         System.assertEquals(resGeoViewPort.southwest,null);
        
        IND_GoogleAPIResponse res =new IND_GoogleAPIResponse();
        System.assertEquals(res.results,null);
         System.assertEquals(res.status,null);
    }
}