public class IND_CibilMatchService {
/*
* @Method:      drAsyncCallout
* @Created by:  Santhosh Mothe
* @Description: This method will process the Document Report API
* @Param:       Object - Applicant Object 
*/
   
    
    public static void cibilMatchAsyncCallout(Applicant__c app){
        try
        {
            IND_CibilMatchRequest cibilMatchRequest = new IND_CibilMatchRequest(app);
            CalloutProcessor processor = new CalloutProcessor(System.Label.Cibil_Match,cibilMatchRequest);
            //processor.processAsync();
            
        }
        catch(Exception ex){
            ErrorLoggerUtil.logErrorEvent('IND_CibilMatchService', 'cibilMatchAsyncCallout', System.Label.Apex, ex);
            throw new AuraHandledException(ex.getMessage());
        }  
    }
}