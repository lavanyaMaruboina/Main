/*------------------------------------------------------------
Author:        Sushil B
Company:       Manureva Solutions
Description:   This class makes API callout for Payment Request.
Inputs:        None 
Test Classes:    
History
Date            Author              Comments
-------------------------------------------------------------
21-06-2022      Sushil B       Created
------------------------------------------------------------*/
public class IND_PactLMSCalloutQueueable implements Queueable, Database.AllowsCallouts {
    public String loanAppId;
    public String dealId;
    public IND_PactLMSCalloutQueueable(String loanAppId, String dealId){
        this.loanAppId = loanAppId;
        this.dealId = dealId;
    } 
    public void execute(QueueableContext context) {
        IND_PactLmsResponse apiResponse;
        String requestForIntegrationLog = '';
        String plainRequest = '';
        Long endTime;
        Long startTime;
        String elapseTime = '';
        String serviceName = System.Label.PactLms;
        HttpResponse response;
        try{
            //Provide API-wise Integration Name to Custom Metadata Configs
            Integration_Configuration__mdt apiConfiguration = IntegrationUtilities.getAPIConfiguration(System.Label.PactLms);
            //if stubs checked in Integration_Configuration then stubs will return
            if(apiConfiguration.IsStub_Required__c != null && apiConfiguration.IsStub_Required__c){
                String stubData = IntegrationUtilities.getStubResponse(System.Label.PactLms);
                stubData = stubData == null ? System.Label.EmptyStubs : stubData;
            }
            
            IND_PactLmsRequest pactLmsRequest = IND_PactLmsService.getPactLmsCallOutRequest(loanAppId,dealId);
            CalloutProcessor processor= new CalloutProcessor(System.Label.PactLms, pactLmsRequest);
            HttpRequest request = processor.createHttpRequest();
            requestForIntegrationLog = request.getBody();
            plainRequest = IntegrationUtilities.getPlainTextForLog(request.getBody());
            Http http = new Http();
            startTime = DateTime.now().getTime();
            response = http.send(request);
            endTime = DateTime.now().getTime();
            elapseTime = String.valueOf((Double)(endTime - startTime)/1000);
            if(response != null && response.getStatusCode() == 200){
                apiResponse = (IND_PactLmsResponse)processor.getHttpResponse(response, serviceName);
                //if request generation was successful,
                //then update the date on Loan_Application(Opportunity)
                // D2C Change
                Opportunity opp = [Select Id, LeadSource FROM Opportunity WHERE Id =:loanAppId];
                if(opp.LeadSource == 'D2C'){
                    D2C_IntegrationEngine.doDisbursedCommunicationCallout(loanAppId);
                }
                // CISP - 4770 - START
                List<Opportunity> loan = new List<Opportunity>([SELECT Id,OwnerId,Product_Type__c,Name FROM Opportunity WHERE id = :loanAppId WITH SECURITY_ENFORCED LIMIT 1]);
                Map<String,Loan_Application_Transaction_History__c> loanHistoryMap = new Map<String,Loan_Application_Transaction_History__c>();
                for(Loan_Application_Transaction_History__c loanHistoryObj : [SELECT Id, Module__c, Screen__c, Submitted_Flag__c, Loan_Application_ID__c ,New_Owner__c,Current_Owner__c
                                                                              FROM Loan_Application_Transaction_History__c 
                                                                              where Loan_Application_ID__c  =: loanAppId
                                                                              and Module__c = 'Post Sanction Checks and Documentation' WITH SECURITY_ENFORCED]){
                                                                                  loanHistoryMap.put(loanHistoryObj.Screen__c, loanHistoryObj);                                                         
                                                                              }
                if(loan.size()>0){
                    String ownerId;
                    if(loan[0].Product_Type__c =='Passenger Vehicles' && loanHistoryMap.containsKey('RTO, DPN, POA Documents Upload')){
                        ownerId=loanHistoryMap.get('RTO, DPN, POA Documents Upload')?.Current_Owner__c;
                        if(ownerId!=null)
                            loan[0].OwnerId=ownerId;
                        Set<String> recepients = new Set<String>{ownerId};
                            String message = 'Payment request is triggered for lead : ' + loan[0].Name;
                        AdditionalDocumentsClass.notifyUsers(recepients,loanAppId,message);
                        
                    }
                }
                if(loan[0].Product_Type__c != System.Label.Tractor){
                    loan[0].Payment_Request_Generation_Date__c = system.now();
                    update loan;
                }
                // CISP-4770 - END
                if(apiResponse!=null){
                    if(String.isNotBlank(dealId)){
                        IntegrationUtilities.createIntegrationLogger(IntegrationUtilities.getPlainTextForLog(request.getBody()), request.getBody(), IntegrationUtilities.getPlainTextForLog(response.getBody()), response.getBody(), serviceName, elapseTime,loanAppId,System.Label.Success,dealId);
                    }else{
                        IntegrationUtilities.createIntegrationLogger(IntegrationUtilities.getPlainTextForLog(request.getBody()), request.getBody(), IntegrationUtilities.getPlainTextForLog(response.getBody()), response.getBody(), serviceName, elapseTime,loanAppId,System.Label.Success);
                    }
                    if (loan[0].Product_Type__c  == 'Tractor') { //SFTRAC-241
                        System.enqueueJob(new IND_PaymentRequestAPICalloutQueueable(loanAppId, dealId));
                    }
                } else {
                    if(String.isNotBlank(dealId)){
                        IntegrationUtilities.createIntegrationLogger(IntegrationUtilities.getPlainTextForLog(request.getBody()), request.getBody(), IntegrationUtilities.getPlainTextForLog(response.getBody()), response.getBody(), serviceName, elapseTime,loanAppId,System.Label.Failure,dealId);
                    }else{
                        IntegrationUtilities.createIntegrationLogger(IntegrationUtilities.getPlainTextForLog(request.getBody()), request.getBody(), IntegrationUtilities.getPlainTextForLog(response.getBody()), response.getBody(), serviceName, elapseTime,loanAppId,System.Label.Failure);
                    }
                    throw new IND_Exception(System.Label.NoResponse);                
                }
            }
            else {
                String errString = '[Status Code = '+ response.getStatusCode() +' ] Response-->'+IntegrationUtilities.getPlainTextForLog(response.getBody());
                ErrorLoggerUtil.logErrorEvent('HTTP Callout', 'getHttpResponse', System.Label.Apex, new IND_Exception(errString), loanAppId);
                if(String.isNotBlank(dealId)){
                    IntegrationUtilities.createIntegrationLogger(IntegrationUtilities.getPlainTextForLog(request.getBody()), request.getBody(), errString, response.getBody(), serviceName, elapseTime, loanAppId, System.Label.Failure,dealId);
                }else{
                    IntegrationUtilities.createIntegrationLogger(IntegrationUtilities.getPlainTextForLog(request.getBody()), request.getBody(), errString, response.getBody(), serviceName, elapseTime, loanAppId, System.Label.Failure);
                }
                throw new IND_Exception(System.Label.NoResponse);
            }
        } catch(CalloutException e) {
            ErrorLoggerUtil.logErrorEvent('IND_PactLMSCalloutQueueable', 'execute', System.Label.Apex, e,loanAppId);
            if(String.isBlank(dealId)){
                IntegrationUtilities.createIntegrationLogger(plainRequest, requestForIntegrationLog, '', '', serviceName, elapseTime,loanAppId,System.Label.Failure);}else if(e.getMessage() != System.Label.NoResponse){
                    IntegrationUtilities.createIntegrationLogger(plainRequest, requestForIntegrationLog, '', '', serviceName, elapseTime,loanAppId,System.Label.Failure,dealId);
                }
            throw e;
        } catch(Exception ex){
            if(String.isBlank(dealId)){
                IntegrationUtilities.createIntegrationLogger(plainRequest, requestForIntegrationLog, 'Status Code -->' + response.getStatusCode(), 'Status Code -->' + response.getStatusCode(), serviceName, elapseTime,loanAppId,System.Label.Failure);}else if(ex.getMessage() != System.Label.NoResponse){
                    IntegrationUtilities.createIntegrationLogger(plainRequest, requestForIntegrationLog, '', '', serviceName, elapseTime,loanAppId,System.Label.Failure,dealId);
                }
            ErrorLoggerUtil.logErrorEvent('IND_PactLMSCalloutQueueable', 'execute', System.Label.Apex, ex,loanAppId);
            throw ex;
        }
    }
}