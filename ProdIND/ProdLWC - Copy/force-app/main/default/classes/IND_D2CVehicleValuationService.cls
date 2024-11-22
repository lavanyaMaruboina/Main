public  class IND_D2CVehicleValuationService {
    public static IND_D2CVehicleValuationRequst getValuationRequest(String loanAppId) {
        try {
            IND_D2CVehicleValuationRequst valuationRequest = new IND_D2CVehicleValuationRequst(loanAppId);
            return valuationRequest;
        } catch (Exception ex) {
           // ErrorLoggerUtil.logErrorEvent('IND_D2CVehicleDedupeService', 'getVehicleDedupe', System.Label.Apex, ex, loanAppId);
            throw new IND_Exception(ex.getMessage());
        }
    }
}