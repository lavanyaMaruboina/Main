/**
* @Name         lWC_LOS_TractorVehicleDedupeCntrl
* @Author       Aakash J
* @Company      Salesforce
* @Description  This class contains all methods related to Tractor Invoice Detail Screen
* Inputs:       None
* Test Class:   
* History:
*/
public class lWC_LOS_TractorVehicleDedupeCntrl {
    
    @AuraEnabled(continuation=true)
    public static string updateVehicleDedupeRetryCount(String uniqueServiceName,String loanAppId){
        try{
            System.debug('uniqueServiceName : '+uniqueServiceName);
            if(loanAppId != null ) {
                Retry_Count__c retryCount = new Retry_Count__c();
                List<Retry_Count__c> retryCountList = new List<Retry_Count__c>();
                retryCountList = [select Loan_Application_Id__c from Retry_Count__c where Loan_Application_Id__c =: loanAppId AND Service_Name__c =:uniqueServiceName AND Module__c = 'Vehicle Dedupe API' WITH SECURITY_ENFORCED];
                System.debug('retryCountList Vehicle Dedupe::'+retryCountList);
                if(retryCountList.isEmpty()) {
                    retryCount.Loan_Application_Id__c = loanAppId;
                    retryCount.Service_Name__c = uniqueServiceName;
                    retryCount.Count__c = 1;
                    if(Schema.sObjectType.Retry_Count__c.isCreateable()) {
                        insert retryCount;
                    }
                    return 'Success';
                } else {
                    System_Constant_custom_metadata__mdt metadata = System_Constant_custom_metadata__mdt.getInstance('Retry_Count'); 
                    //If number of attempts are greater than predefined number of attempts.
                    Retry_Count__c  count = [Select Count__c from Retry_Count__c WhERE Loan_Application_Id__c =: loanAppId AND Service_Name__c =:uniqueServiceName WITH SECURITY_ENFORCED limit 1];
                    
                    if(count.Count__c >= metadata.Number_Of_Attempts__c){
                        count.Count__c += 1;
                        if (Schema.sObjectType.Retry_Count__c.isUpdateable()){
                            update count;
                        }
                        String serializedResponse =  System.Label.Retry_Exhausted;
                    	return serializedResponse;
                        //return System.Label.Retry_Exhausted;
                    }
                    //If number of attempts are Less than predefined number of attempts.
                    else{
                        count.Count__c += 1;
                        if (Schema.sObjectType.Retry_Count__c.isUpdateable()){
                            update count;
                        }                    
                        return 'Success';
                    }
                }
            }
            return 'Failure';    
        } catch(Exception e) {
            ErrorLoggerUtil.logErrorEvent('lWC_LOS_TractorVehicleDedupeCntrl' ,'updateRetryCount', System.Label.Apex, e);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }
}