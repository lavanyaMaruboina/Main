public class IND_BREscoreCardServiceDSA {
    public static IND_BREscoreCardRequestDSA getBREscoreCardRequest(Applicant__c app, Documents__c doc, String loanAppId) {
        try {
            IND_BREscoreCardRequestDSA brescoreCardRequest = new IND_BREscoreCardRequestDSA(app, doc, loanAppId);
            return brescoreCardRequest; 
        } catch (Exception ex) {
            ErrorLoggerUtil.logErrorEvent('IND_BREscoreCardServiceDSA', 'getBREscoreCardRequest', System.Label.Apex, ex, loanAppId);
            throw new IND_Exception(ex.getMessage());
        }
    }
}