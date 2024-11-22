/*------------------------------------------------------------
Author:        Neeraj Mehethrajkar
Company:       Salesforce
Description:   This class makes API callout for Payment Request for Tractor. //SFTRAC-241
Inputs:        None 
Test Classes:    
History
Date            Author                    Comments
-------------------------------------------------------------
29-11-2023      Neeraj Mehethrajkar       Created
------------------------------------------------------------*/
public with sharing class IND_PaymentRequestAPICalloutQueueable implements Queueable, Database.AllowsCallouts{
    public String loanAppId;
    public String dealId;
    public IND_PaymentRequestAPICalloutQueueable(String loanAppId, String dealId) {
        this.loanAppId = loanAppId;
        this.dealId = dealId;
    }

    public void execute(QueueableContext context) {
        IND_PaymentRequestAPIResponse apiResponse;
        String requestForIntegrationLog = '';
        String plainRequest = '';
        Long endTime;
        Long startTime;
        String elapseTime = '';
        String serviceName = System.Label.Payment_Request_For_Tractor;
        HttpResponse response;
        try{
            //Provide API-wise Integration Name to Custom Metadata Configs
            Integration_Configuration__mdt apiConfiguration = IntegrationUtilities.getAPIConfiguration(System.Label.Payment_Request_For_Tractor);
            //if stubs checked in Integration_Configuration then stubs will return
            if(apiConfiguration.IsStub_Required__c != null && apiConfiguration.IsStub_Required__c){
                String stubData = IntegrationUtilities.getStubResponse(System.Label.Payment_Request_For_Tractor);
                stubData = stubData == null ? System.Label.EmptyStubs : stubData;
            }
          
            IND_PaymentRequestApiRequest PaymentAPIRequest = IND_PaymentRequestApiService.getPaymentRequestCallOutRequest(loanAppId, dealId);
            CalloutProcessor processor= new CalloutProcessor(System.Label.Payment_Request_For_Tractor, PaymentAPIRequest);
            HttpRequest request = processor.createHttpRequest();
            requestForIntegrationLog = request.getBody();
            plainRequest = IntegrationUtilities.getPlainTextForLog(request.getBody());
            Http http = new Http();
            startTime = DateTime.now().getTime();
            response = http.send(request);
            endTime = DateTime.now().getTime();
            elapseTime = String.valueOf((Double)(endTime - startTime)/1000);
            if(response != null && response.getStatusCode() == 200){
                apiResponse = (IND_PaymentRequestAPIResponse)processor.getHttpResponse(response, serviceName);
                List<Vehicle_Detail__c> vehicleList = new List<Vehicle_Detail__c>([Select Id from Vehicle_Detail__c Where Deal_Number__c =: dealId LIMIT 1]);
                if(vehicleList.size() > 0){
                    vehicleList[0].Payment_requested__c = System.today();
                    update vehicleList[0];
                    if([Select Id From Vehicle_Detail__c Where Loan_Application__c =: loanAppId AND Approval_Status__c = 'Approved' AND Payment_requested__c = null].size() == 0){
                        Opportunity oppObj = new Opportunity();
                        oppObj.Id = loanAppId;
                        oppObj.Payment_Request_Generation_Date__c = system.now();
                        update oppObj;
                    }
                }
                if(apiResponse!=null){
                    IntegrationUtilities.createIntegrationLogger(IntegrationUtilities.getPlainTextForLog(request.getBody()), request.getBody(), IntegrationUtilities.getPlainTextForLog(response.getBody()), response.getBody(), serviceName, elapseTime,loanAppId,System.Label.Success,dealId);
                    
                } else {
                    IntegrationUtilities.createIntegrationLogger(IntegrationUtilities.getPlainTextForLog(request.getBody()), request.getBody(), IntegrationUtilities.getPlainTextForLog(response.getBody()), response.getBody(), serviceName, elapseTime,loanAppId,System.Label.Failure,dealId);
                    throw new IND_Exception(System.Label.NoResponse);                
                }
            }
            else {
                String errString = '[Status Code = '+ response.getStatusCode() +' ] Response-->'+IntegrationUtilities.getPlainTextForLog(response.getBody());
                ErrorLoggerUtil.logErrorEvent('HTTP Callout', 'getHttpResponse', System.Label.Apex, new IND_Exception(errString), loanAppId);
                IntegrationUtilities.createIntegrationLogger(IntegrationUtilities.getPlainTextForLog(request.getBody()), request.getBody(), errString, response.getBody(), serviceName, elapseTime, loanAppId, System.Label.Failure,dealId);
                throw new IND_Exception(System.Label.NoResponse);
            }
        } catch(CalloutException e) {
            if(e.getMessage() != System.Label.NoResponse){
                String errString = 'Error ' + e.getMessage();
                IntegrationUtilities.createIntegrationLogger(plainRequest, plainRequest, errString, requestForIntegrationLog, serviceName, elapseTime, loanAppId, System.Label.Failure,dealId);
            }
            ErrorLoggerUtil.logErrorEvent('IND_PaymentRequestAPICalloutQueueable', 'execute', System.Label.Apex, e,loanAppId);
            throw e;
        } catch(Exception ex){
            if(ex.getMessage() != System.Label.NoResponse){
                String errString = 'Error ' + ex.getMessage();
                IntegrationUtilities.createIntegrationLogger(plainRequest, plainRequest, errString, requestForIntegrationLog, serviceName, elapseTime, loanAppId, System.Label.Failure,dealId);
            }
            ErrorLoggerUtil.logErrorEvent('IND_PaymentRequestAPICalloutQueueable', 'execute', System.Label.Apex, ex,loanAppId);
            throw ex;
        }
    }
}