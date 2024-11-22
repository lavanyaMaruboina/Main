public class IND_OfferEngineServiceDSA {
    public static IND_OfferEngineRequestDSA getDSAOfferEngineCallOutRequest(RequestWrapper requestWrapper, String loadAppId) {
        try { 
            IND_OfferEngineRequestDSA offerEngineRequestDSA = new IND_OfferEngineRequestDSA(requestWrapper);
            return offerEngineRequestDSA;
        } catch (Exception ex) {
            ErrorLoggerUtil.logErrorEvent('IND_OfferEngineServiceDSA', 'getDSAfferEngineCallOutRequest', System.Label.Apex, ex, loadAppId);
            throw new IND_Exception(ex.getMessage());
        }
    }
}