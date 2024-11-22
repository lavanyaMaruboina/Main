public with sharing class IND_CustomerDedupeStatusAPIService {
    public static IND_ExternalDedupeStatusAPIRequest getExternalDedupeStatusCallout(Customer_Dedupe_Response__c cdr, String loanAppId){
        try{
            IND_ExternalDedupeStatusAPIRequest request = new IND_ExternalDedupeStatusAPIRequest(cdr,loanAppId);
            return request;
        }
        catch(Exception ex){
            ErrorLoggerUtil.logErrorEvent('IND_CustomerDedupeStatusAPIService', 'getExternalDedupeStatusCallout', System.Label.Apex, ex,loanAppId);
            throw new IND_Exception(ex.getMessage());   
        }
    }
}