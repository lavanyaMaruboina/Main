public class IND_PricingEngineServiceDSA {
    public static IND_PricingEngineRequestDSA getPricingEngineRequest(Opportunity opp, String loanAppId, RequestWrapper requestWrapper) {
        try {
            IND_PricingEngineRequestDSA pricingEngineRequest = new IND_PricingEngineRequestDSA(opp, loanAppId, requestWrapper); //only validation and setting headers 
            return pricingEngineRequest;
        } catch (Exception ex) {
            ErrorLoggerUtil.logErrorEvent('IND_PricingEngineServiceDSA', 'getPricingEngineRequest', System.Label.Apex, ex, loanAppId);
            throw new IND_Exception(ex.getMessage());
        }
    }
}