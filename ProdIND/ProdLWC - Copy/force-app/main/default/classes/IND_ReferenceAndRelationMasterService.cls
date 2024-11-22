public class IND_ReferenceAndRelationMasterService {
public static IND_ReferenceAndRelationMasterRequest getReferenceAndRelationMasterRequest(String loanAppId, String vehicleId){
        try{
           IND_ReferenceAndRelationMasterRequest referenceRequest = new IND_ReferenceAndRelationMasterRequest(loanAppId,vehicleId);
            return referenceRequest;
        }
        catch(Exception ex){
            ErrorLoggerUtil.logErrorEvent('IND_ReferenceAndRelationMasterService', 'getReferenceAndRelationMasterRequest', System.Label.Apex, ex,loanAppId);
            throw new IND_Exception(ex.getMessage());   
        }
    }
}