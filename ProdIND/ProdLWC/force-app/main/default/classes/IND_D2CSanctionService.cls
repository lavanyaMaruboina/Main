public  class IND_D2CSanctionService {
    public static IND_D2CSanctionRequest getSanctionRequest(String loanAppId) {
        try {
            IND_D2CSanctionRequest sanctionRequest = new IND_D2CSanctionRequest(loanAppId);
            return sanctionRequest;
        } catch (Exception ex) {
           // ErrorLoggerUtil.logErrorEvent('IND_D2CVehicleDedupeService', 'getVehicleDedupe', System.Label.Apex, ex, loanAppId);
            throw new IND_Exception(ex.getMessage());
        }
    }
}