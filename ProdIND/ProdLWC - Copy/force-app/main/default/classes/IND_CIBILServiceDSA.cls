public class IND_CIBILServiceDSA {
   
    public static IND_CIBILRequestDSA getcibilCallout(Applicant__c app, List<Documents__c> docs, String loanAppId, List<CIBIL_Details__c> cibilDetails, String customer_Code){
        try
        {
            IND_CIBILRequestDSA request = new IND_CIBILRequestDSA(app,docs,loanAppId,cibilDetails, customer_Code);            
            return request;
        }
        catch(Exception ex){
            ErrorLoggerUtil.logErrorEvent('IND_CIBILService', 'getcibilCallout', System.Label.Apex, ex,loanAppId);
            throw new IND_Exception(ex.getMessage());          
        }  
    }

}