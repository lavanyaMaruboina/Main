public class distanceCalculation {
    public static Decimal calculateDistance(Decimal lat1, Decimal lon1, Decimal lat2, Decimal lon2) {
        Decimal earthRadius = 6371; // Earth's radius in kilometers
        Decimal lat1Radians = lat1 * Math.PI / 180.0;
        Decimal lon1Radians = lon1 * Math.PI / 180.0;
        Decimal lat2Radians = lat2 * Math.PI / 180.0;
        Decimal lon2Radians = lon2 * Math.PI / 180.0;

        Decimal dlat = lat2Radians - lat1Radians;
        Decimal dlon = lon2Radians - lon1Radians;

        Decimal a = Math.sin(dlat/2) * Math.sin(dlat/2) + Math.cos(lat1Radians) * Math.cos(lat2Radians) * Math.sin(dlon/2) * Math.sin(dlon/2);
        Decimal c = 2 * Math.asin(Math.sqrt(a));
        Decimal distance = earthRadius * c;

        return distance;
    }
}