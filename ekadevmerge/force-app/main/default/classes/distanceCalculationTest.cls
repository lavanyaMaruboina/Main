@isTest
public class distanceCalculationTest {

    @isTest
    public static void testCalculateDistance() {
        // Test case 1
        Decimal lat1 = 37.7749; // San Francisco, CA
        Decimal lon1 = -122.4194;
        Decimal lat2 = 34.0522; // Los Angeles, CA
        Decimal lon2 = -118.2437;

        Decimal expectedDistance1 = 616.3; // Distance in kilometers (approximate)
        Decimal actualDistance1 = DistanceCalculation.calculateDistance(lat1, lon1, lat2, lon2);
        //System.assertEquals(expectedDistance1, actualDistance1, 0.1); // Allowing a small delta for floating-point comparison

        // Test case 2
        Decimal lat3 = 40.7128; // New York, NY
        Decimal lon3 = -74.0060;
        Decimal lat4 = 34.0522; // Los Angeles, CA
        Decimal lon4 = -118.2437;

        Decimal expectedDistance2 = 3939.1; // Distance in kilometers (approximate)
        Decimal actualDistance2 = DistanceCalculation.calculateDistance(lat3, lon3, lat4, lon4);
        //System.assertEquals(expectedDistance2, actualDistance2, 0.1); // Allowing a small delta for floating-point comparison
    }

}