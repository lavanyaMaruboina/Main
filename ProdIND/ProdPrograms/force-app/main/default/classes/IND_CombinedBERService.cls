public class IND_CombinedBERService {
    public Static IND_CombinedBERRequest getCombinedBreRequest(String loanAppId, String vehicleId){
        try{
            IND_CombinedBERRequest request = new IND_CombinedBERRequest(loanAppId,vehicleId);
            return request;
        }
        catch(Exception ex){
            system.debug('test---'+ex);
            system.debug('test---'+ex.getMessage());
            ErrorLoggerUtil.logErrorEvent('IND_CombinedBERService', 'getCombinedBreRequest', System.Label.Apex, ex, loanAppId);
            throw new IND_Exception(ex.getMessage());   
        }
    }
}