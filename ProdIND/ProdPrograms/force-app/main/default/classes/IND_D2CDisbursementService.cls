public  class IND_D2CDisbursementService {
    public static IND_D2CDisbursementRequest getDisbursementRequest(String loanAppId) {
        try {
            IND_D2CDisbursementRequest disbursementRequest = new IND_D2CDisbursementRequest(loanAppId);
            return disbursementRequest;
        } catch (Exception ex) {
           // ErrorLoggerUtil.logErrorEvent('IND_D2CVehicleDedupeService', 'getVehicleDedupe', System.Label.Apex, ex, loanAppId);
            throw new IND_Exception(ex.getMessage());
        }
    }
}