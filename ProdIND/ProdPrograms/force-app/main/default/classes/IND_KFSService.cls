public with sharing class IND_KFSService {
   public static IND_KFSAPIRequest getKFSCallout(Opportunity oppId, String loanAppId, String dealId){
        try{
            IND_KFSAPIRequest request = new IND_KFSAPIRequest(oppId,dealId);
            return request;
        }
        catch(Exception ex){
            ErrorLoggerUtil.logErrorEvent('IND_KFSService', 'getKFSCallout', System.Label.Apex, ex,loanAppId);
            throw new IND_Exception(ex.getMessage());   
        }
    }
    
    public static IND_KFSAPIRequest getKFSCalloutProCredit(RequestWrapper requestWrapper){
        try{
            IND_KFSAPIRequest request = new IND_KFSAPIRequest(requestWrapper);
            return request;
        }
        catch(Exception ex){
            //ErrorLoggerUtil.logErrorEvent('IND_KFSService', 'getKFSCallout', System.Label.Apex, ex,loanAppId);
            ErrorLoggerUtil.logErrorEventProCreditDeal('IND_KFSService', 'getKFSCalloutProCredit', System.Label.Apex, ex,requestWrapper.pcdId);
            throw new IND_Exception(ex.getMessage());   
        }
    }

    public static IND_KFSAPIRequest getKFSCalloutMultiAsset(String dealNo, Boolean fromProcredit, String processingRecordId){
        try{
            IND_KFSAPIRequest request = new IND_KFSAPIRequest(dealNo,fromProcredit,processingRecordId);
            return request;
        }
        catch(Exception ex){
            throw new IND_Exception(ex.getMessage());   
        }
    }
}