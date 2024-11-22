public class IND_GatingScreeningServiceDSA {

    public static IND_GatingScreeningRequestDSA getGatingScreeningCallOutRequest(RequestWrapper requestWrapper) {
        try {
            IND_GatingScreeningRequestDSA gatingScreeningRequest = new IND_GatingScreeningRequestDSA(requestWrapper);
            return gatingScreeningRequest; 
        } catch (Exception ex) {
            ErrorLoggerUtil.logErrorEvent('IND_GatingScreeningServiceDSA', 'getGatingScreeningCallOutRequest', System.Label.Apex, ex);
            throw new IND_Exception(ex.getMessage());
        }
    }
}