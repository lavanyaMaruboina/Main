/*------------------------------------------------------------
Author:        Parimal Shinde & Vishal Gadhave
Company:       Nanostuffs Technologies
Description:   This class makes API callout for Reverse Status Request.
Inputs:        None 
Test Classes:    
History
Date            Author             					 Comments
-------------------------------------------------------------
15-09-2022      Parimal Shinde & Vishal Gadhave       Created
------------------------------------------------------------*/

public class IND_ReverseStatusCalloutQueueable implements Queueable, Database.AllowsCallouts {
    public Id loanAppId;
    public String status;
    public String code;
    
    public IND_ReverseStatusCalloutQueueable(Id loanAppId,String status,String code){
        this.loanAppId = loanAppId;
        this.status = status;
        this.code = code;
    }
    public void execute(QueueableContext context) {
        IND_ReverceStatusResponse apiResponse;
        IND_MahindraReverseStatusResponse apiMahindraResponse; //CISP-21374
        String requestForIntegrationLog = '';
        String plainRequest = '';
        Long endTime;
        Long startTime;
        String elapseTime = '';
        String serviceName = ''; //CISP-21374
        try{
            //CISP-21374 Start
            Opportunity opp = [SELECT Id, LeadSource FROM Opportunity WHERE Id =:loanAppId WITH SECURITY_ENFORCED];
            if(opp.LeadSource == System.Label.Mahindra_Custom_Lead_API_Value || opp.LeadSource == System.Label.Mahindra_PreA_Lead_API_Value){
                serviceName = System.Label.Mahindra_Service_Config_Name;
            }else{
                serviceName = System.Label.Reverse_Status;
            }
            //CISP-21374 End
            ParentAPIRequest ReverseRequest = IND_ReverseStatusService.getReverseStatusCallOutRequest(loanAppId, status, code); //CISP-21374 Datatype update
            system.debug('reverse API: '+ReverseRequest);
            
            CalloutProcessor processor= new CalloutProcessor(serviceName, ReverseRequest);
            HttpRequest request = processor.createHttpRequestForReverseStatus();
            requestForIntegrationLog = request.getBody();
            System.debug('Request body..'+requestForIntegrationLog);
            plainRequest = IntegrationUtilities.getPlainTextForLog(request.getBody());
            Http http = new Http();
            startTime = DateTime.now().getTime();
            HttpResponse response = http.send(request);
            System.debug('MSIL-response: '+response);
            endTime = DateTime.now().getTime();
            elapseTime = String.valueOf((Double)(endTime - startTime)/1000);
            System.debug('resp code is::'+response.getStatusCode());
            if(response != null && response.getStatusCode() == 200) {
                //CISP-21374 Start
                if(opp.LeadSource == System.Label.Mahindra_Custom_Lead_API_Value || opp.LeadSource == System.Label.Mahindra_PreA_Lead_API_Value){
                    apiMahindraResponse = (IND_MahindraReverseStatusResponse)processor.getHttpResponse(response, serviceName);
                }else{
                //CISP-21374 End
                    apiResponse = (IND_ReverceStatusResponse)processor.getHttpResponse(response, serviceName);
                }
        		System.debug('apiResponse is: '+apiResponse);
                System.debug('apiMahindraResponse is: '+apiMahindraResponse);
                //CISP-21374 Start
                if(apiMahindraResponse!= null && (opp.LeadSource == System.Label.Mahindra_Custom_Lead_API_Value || opp.LeadSource == System.Label.Mahindra_PreA_Lead_API_Value)){
                    Mahindra_Application_Status__c mahindra = new Mahindra_Application_Status__c();
                    IND_MahindraReverseStatusResponse reverseResponse = new IND_MahindraReverseStatusResponse();
                    reverseResponse = apiMahindraResponse;
                    System.debug('reverseResponse is: '+reverseResponse);
                    mahindra.Loan_Application__c = String.valueOf(loanAppId);
                    mahindra.Reverse_Lead_Source__c = opp.LeadSource;
                    mahindra.Updated_Status__c = String.valueOf(reverseResponse.updated_status);
                    mahindra.Message__c = reverseResponse.message;
                    mahindra.Enquiry_Id__c = reverseResponse.enquiry_id;
                    if(Schema.sObjectType.Mahindra_Application_Status__c.isCreateable()) {
                        Insert mahindra;
                    }
                    List<MSIL_Reverse_Status_Code__mdt> appStatusMtd = [Select Status_Name__c from MSIL_Reverse_Status_Code__mdt where Status_Code__c =:code];
                    List<Opportunity> opps = [Select Id,Lead_number__c,Msil_Latest_Status__c from Opportunity where Id=: loanAppId WITH SECURITY_ENFORCED Limit 1];
                    If(opps.size() > 0 && !opps.isEmpty())
                    {
                        opps[0].Msil_Latest_Status__c = appStatusMtd.size() > 0 ? appStatusMtd[0].Status_Name__c : '';
                    }
                    if(Schema.sObjectType.Opportunity.isUpdateable()) {
                        Update opps;
                    }
                    IntegrationUtilities.createIntegrationLogger(IntegrationUtilities.getPlainTextForLog(request.getBody()), request.getBody(), IntegrationUtilities.getPlainTextForLog(response.getBody()), response.getBody(), serviceName, elapseTime,loanAppId,System.Label.Success);                 
                }else if(apiResponse!=null){
                //CISP-21374 End
                    MSIL_Application_Status__c MSIL = new MSIL_Application_Status__c();
                    String IModuleNo, ImoduleVar;
                    IND_ReverceStatusResponse.response reverseResponse = new IND_ReverceStatusResponse.response();
                    reverseResponse = apiResponse.response;
                    System.debug('reverseResponse is: '+reverseResponse);
                    Boolean isSuccess = false;
                    String errorMsg = '';
                    if(reverseResponse.status != null && reverseResponse.status == 'SUCCESS')
                    {
                        list<IND_ReverceStatusResponse.content> ContentOfAPI = new list<IND_ReverceStatusResponse.content>();
                        ContentOfAPI = reverseResponse.content;
                        for(IND_ReverceStatusResponse.content contentRecord : ContentOfAPI )
                        {
                            if(contentRecord.success.toLowerCase()=='True'.toLowerCase()){
                                IModuleNo = contentRecord.unique_id;
                                MSIL.IModule_No__c =  IModuleNo;
                                isSuccess = true;
                                break;
                            }else{
                                isSuccess = false;
                                errorMsg = contentRecord?.errors[0]?.errorMessage;
                                break;
                            }
                        }
                        if(isSuccess){
                        List<Opportunity> opps = [Select Id,Lead_number__c,Msil_Latest_Status__c from Opportunity where Id=: loanAppId WITH SECURITY_ENFORCED Limit 1];
                        If(opps.size() > 0 && !opps.isEmpty())
                        {
                            MSIL.MSIL_Lead_No__c = opps[0].Lead_number__c;
                            MSIL.Loan_Application__c = opps[0].Id;
                            List<MSIL_Reverse_Status_Code__mdt> appStatusMtd = [Select Status_Name__c from MSIL_Reverse_Status_Code__mdt where Status_Code__c =:code];
                            opps[0].Msil_Latest_Status__c = appStatusMtd.size() > 0 ? appStatusMtd[0].Status_Name__c : '';
                            if(Schema.sObjectType.MSIL_Application_Status__c.isCreateable()) {
                                Insert MSIL;
                            }
                            if(Schema.sObjectType.Opportunity.isUpdateable()) {
                                Update opps;
                            }
                        }
                        IntegrationUtilities.createIntegrationLogger(IntegrationUtilities.getPlainTextForLog(request.getBody()), request.getBody(), IntegrationUtilities.getPlainTextForLog(response.getBody()), response.getBody(), serviceName, elapseTime,loanAppId,System.Label.Success); 
                      }else{
                        IntegrationUtilities.createIntegrationLogger(IntegrationUtilities.getPlainTextForLog(request.getBody()), request.getBody(), errorMsg, response.getBody(), serviceName, elapseTime,loanAppId,System.Label.Success); 
                      }
                    }else{
                        IntegrationUtilities.createIntegrationLogger(IntegrationUtilities.getPlainTextForLog(request.getBody()),request.getBody() , 'FAILURE', response.getBody(), serviceName, elapseTime, loanAppId, System.Label.Failure);
                    }                  
                }else {
                    IntegrationUtilities.createIntegrationLogger(IntegrationUtilities.getPlainTextForLog(request.getBody()), request.getBody(), IntegrationUtilities.getPlainTextForLog(response.getBody()), response.getBody(), serviceName, elapseTime,loanAppId,System.Label.Failure);
                    throw new IND_Exception(System.Label.NoResponse);              
                }
            }
            else {
                String errString = '[Status Code = '+ response.getStatusCode() +' ] Response-->'+IntegrationUtilities.getPlainTextForLog(response.getBody());
                IntegrationUtilities.createIntegrationLogger(IntegrationUtilities.getPlainTextForLog(request.getBody()),request.getBody() , errString, response.getBody(), serviceName, elapseTime, loanAppId, System.Label.Failure);
                ErrorLoggerUtil.logErrorEvent('HTTP Callout', 'getHttpResponse', System.Label.Apex, new IND_Exception(errString), loanAppId);
                throw new IND_Exception(System.Label.NoResponse);
            }
        } catch(Exception ex){
            system.debug('entered in catch of reverse status because status was not 200');
            ErrorLoggerUtil.logErrorEvent('IND_ReverseStatusCalloutQueueable', 'execute', System.Label.Apex, ex,loanAppId);
            throw ex;
        }
    }
}