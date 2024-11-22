public class IND_OfferEngineServiceD2C {
    public static IND_OfferEngineRequestD2C getD2COfferEngineCallOutRequest(RequestWrapper requestWrapper, String loadAppId, String fromScreen) {
        try { 
            IND_OfferEngineRequestD2C offerEngineRequestD2C = new IND_OfferEngineRequestD2C(requestWrapper,fromScreen);
            return offerEngineRequestD2C;
        } catch (Exception ex) {
            ErrorLoggerUtil.logErrorEvent('IND_OfferEngineServiceD2C', 'getD2CfferEngineCallOutRequest', System.Label.Apex, ex, loadAppId);
            throw new IND_Exception(ex.getMessage());
        }
    }

    //CISP-20180 Start
    public static IND_OfferEngineRequestD2C getD2COfferEngineCallOutRequest(RequestWrapper requestWrapper, String loadAppId, String fromScreen, String minCRMIRR) {
        try { 
            IND_OfferEngineRequestD2C offerEngineRequestD2C = new IND_OfferEngineRequestD2C(requestWrapper,fromScreen, minCRMIRR);
            return offerEngineRequestD2C;
        } catch (Exception ex) {
            ErrorLoggerUtil.logErrorEvent('IND_OfferEngineServiceD2C', 'getD2CfferEngineCallOutRequest', System.Label.Apex, ex, loadAppId);
            throw new IND_Exception(ex.getMessage());
        }
    }
    //CISP-20180 End
}