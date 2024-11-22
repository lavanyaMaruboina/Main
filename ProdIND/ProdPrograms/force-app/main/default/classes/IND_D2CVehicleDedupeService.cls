public  class IND_D2CVehicleDedupeService {
    public static IND_D2CVehicleDedupeRequest getVehicleDedupe(String loanId, String status) {
        try {
            IND_D2CVehicleDedupeRequest VehicleDedupeRequest = new IND_D2CVehicleDedupeRequest(loanId, status);
            return VehicleDedupeRequest;
        } catch (Exception ex) {
           // ErrorLoggerUtil.logErrorEvent('IND_D2CVehicleDedupeService', 'getVehicleDedupe', System.Label.Apex, ex, loanAppId);
            throw new IND_Exception(ex.getMessage());
        }
    }
}