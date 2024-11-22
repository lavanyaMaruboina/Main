/*------------------------------------------------------------
Author: Santhosh Mothe
Company: Persistent Systems
Description: This class is wrapper class for the cibil match  Request
Test Class: 
History
Date            Author              Comments
------------------------------------------------------------- 
16-12-2021    Santhosh Mothe            Created
------------------------------------------------------------*/

public class IND_CibilMatchRequest extends ParentAPIRequest {
    //request paramaters for Document Report request
    public String Maker_Id{get;set;}
    public String appId{get;set;}
    
    //constructor
    public IND_CibilMatchRequest(Applicant__c app){
        if( app != null){
            this.Maker_Id ='100001';
            this.appId = app.Id;
            //fetching details from Applicant Object
        }
        validate(System.Label.DocumentReport);
    }
    
    
    
    //Method to validate the request data
    public override boolean validate(String serviceName){
        List<String> errorMessageList = new List<String>();
        if(String.isBlank(this.Maker_Id)){
            ErrorLoggerUtil.logErrorEvent('IND_CibilMatchRequest', 'validate', System.Label.Apex, new AuraHandledException(System.Label.MakerId));
            throw new AuraHandledException(System.Label.MakerId);
        }
        if(String.isBlank(this.appId)){
            ErrorLoggerUtil.logErrorEvent('IND_CibilMatchRequest', 'validate', System.Label.Apex, new AuraHandledException(System.Label.AppId));
            throw new AuraHandledException(System.Label.AppId);
        }
        
        return true;
    }
    
}