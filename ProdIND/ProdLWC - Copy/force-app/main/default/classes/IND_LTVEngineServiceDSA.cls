public class IND_LTVEngineServiceDSA { 
    public static IND_LTVEngineRequestDSA getLTVEngineRequest(Opportunity opp, String loanAppId, RequestWrapper requestWrapper) {
        try {
            IND_LTVEngineRequestDSA ltvengineRequest = new IND_LTVEngineRequestDSA(opp, requestWrapper);
            return ltvengineRequest;
        } catch (Exception ex) {
            ErrorLoggerUtil.logErrorEvent('IND_LTVEngineServiceDSA', 'getLTVEngineRequest', System.Label.Apex, ex, loanAppId);
            throw new IND_Exception(ex.getMessage());
        }
    }
}