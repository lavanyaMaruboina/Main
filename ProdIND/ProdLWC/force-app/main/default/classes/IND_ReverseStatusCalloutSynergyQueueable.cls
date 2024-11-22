public class IND_ReverseStatusCalloutSynergyQueueable implements Queueable, Database.AllowsCallouts {
    Public String loanAppId;
    Public String status;

    public IND_ReverseStatusCalloutSynergyQueueable(String loanAppId,String status){
        this.loanAppId = loanAppId;
        this.status = status;
    }
    Public void execute(QueueableContext context) { 
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        HttpResponse response = new HttpResponse();
        String responseBody ='';   
        String returnStr ='';    
        String elapseTime = ''; 
        try{   
            Integration_Configuration__mdt apiConfiguration = IntegrationUtilities.getAPIConfiguration('Reverse Status CRMNEXT');
            if(apiConfiguration != null){
                if(!apiConfiguration.IsActive_Integration__c){
                    ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'Reverse Status CRMNEXT', System.Label.Apex, new AuraHandledException('Integration is not Active'));
                    throw new AuraHandledException('Integration is not Active');       
                }
                String methodType = apiConfiguration.Rest_Method__c.trim();
                //String endpoint ='callout:Indus_API'+apiConfiguration.Endpoint_URL__c.trim();
                String endpoint ='https://indusapiuat.indusind.com/indusapi-np/uat/cfdlos/Update_Reverse_Status_CRMNEXT';
            
                SynergyReverseStatusRequest requestWrapper = new SynergyReverseStatusRequest();
                List<Opportunity> oppList = [SELECT Id, Lead_number__c,StageName,Loan_amount__c,Enquiry__r.Lead_Reference_ID__c FROM Opportunity WHERE Id = :loanAppId];
                
                if (!oppList.isEmpty()) {
                    Opportunity opportunity = oppList[0];
                    
                    LeadReverseStatus leadReverseStatus = new LeadReverseStatus();
                    leadReverseStatus.Talisma_Id = opportunity.Enquiry__r.Lead_Reference_ID__c != null ? opportunity.Enquiry__r.Lead_Reference_ID__c : ''; 
                    leadReverseStatus.AssignTo = '1';
                    leadReverseStatus.Reference_Number_Lead = opportunity.Lead_number__c != null ? opportunity.Lead_number__c : '';
                    leadReverseStatus.Amount_Lead = opportunity.Loan_amount__c != null ? Decimal.valueOf(opportunity.Loan_amount__c) : null;
                    leadReverseStatus.Reverse_Feed_status_Lead = opportunity.StageName != null ? opportunity.StageName : '';
                    leadReverseStatus.Rejection_Reason_Lead = '';
                    if(status == 'Withdrawn'){
                        leadReverseStatus.Reverse_Feed_status_Lead = 'Drop';
                    }
                    if(status == 'Sanctioned'){
                        leadReverseStatus.Reverse_Feed_status_Lead = 'Converted';
                    }
                    if(status == 'Rejected'){
                        leadReverseStatus.Reverse_Feed_status_Lead = 'Drop';
                        LeadReverseStatus.Rejection_Reason_Lead = 'Rejected post login';
                    }
                    if(status == 'L1Completed'){
                        leadReverseStatus.Reverse_Feed_status_Lead = 'Work in progress';
                    }


                    requestWrapper.Lead_Reverse_Status = leadReverseStatus;
                }

            System.debug('++++berRequest '+requestWrapper);
            String requestBody = JSON.serialize(requestWrapper);
            system.debug('++++requestBody '+requestBody);
            //String requestBody = '{ "Lead_Reverse_Status": { "Talisma_Id": "12121221", "AssignTo": "1", "Reference_Number_Lead": "", "Amount_Lead": "100", "Reverse_Feed_status_Lead": "Not Interested", "Rejection_Reason_Lead": "Not Interested" } }';

            String encryptedRequestBody = IntegrationUtilities.getEncryptedRequest(requestBody,System.Label.privateKey,System.Label.ivkey);  
            Map<String, String> requestData = new Map<String, String>();
            requestData.put('JData', encryptedRequestBody);
            String requestBodyJSON = JSON.serialize(requestData);
            system.debug('++++body '+requestBodyJSON); 
            Long startTime = DateTime.now().getTime();
            
            request.setEndpoint(endpoint);
            
            request.setHeader('IBL-Client-Id',System.Label.IBM_Client_ID);
            request.setHeader('IBL-Client-Secret',System.Label.IBM_Client_Secret);

            request.setHeader('Content-Type', 'application/json');
            request.setMethod(methodType);
            request.setBody(requestBodyJSON);
            system.debug('++++request '+request);
            
            response = http.send(request); 
            Long endTime = DateTime.now().getTime();
            elapseTime = String.valueOf((Double)(endTime - startTime)/1000);
            System.debug('++++ getStatusCode' +response.getStatusCode()+'+getStatus ' +response.getStatus()+'+getBody ' +response.getBody());
            if (response.getStatusCode() == 200) {
                responseBody = response.getBody();
                System.debug('++++ responseBody1 ' +responseBody);
                responseBody = responseBody.substring(10, responseBody.length()-2);
                String decryptedResponse = IntegrationUtilities.getDecryptedResponse(responseBody,System.Label.privateKey,System.Label.ivkey);
                System.debug('++++ decryptedResponse ' +decryptedResponse);
                String searalizedJson = JSON.serializePretty(JSON.deserializeUntyped(decryptedResponse));
                System.debug('++++ searalizedJson ' +searalizedJson);
                returnStr = searalizedJson;

                IntegrationUtilities.createIntegrationLogger(requestBody, requestBodyJSON, returnStr, response.getBody(), 'Reverse Status CRMNEXT', elapseTime, loanAppId, System.Label.Success);
            }
            else{
                System.debug('++++ not 200 response.getStatusCode() ' +response.getStatusCode());
                String errString = '[Status Code = '+ response.getStatusCode() +' ] Response-->'+IntegrationUtilities.getPlainTextForLog(response.getBody());
                IntegrationUtilities.createIntegrationLogger(requestBody, requestBodyJSON, errString, response.getBody(),'Reverse Status CRMNEXT', elapseTime, loanAppId, System.Label.Failure);  
            }   
            }    
        }catch(Exception ex){
            ErrorLoggerUtil.logErrorEvent('IND_ReverseStatusCalloutSynergyQueueable', 'execute', System.Label.Apex, ex,loanAppId);
        }
    }

    class SynergyReverseStatusRequest{
        public LeadReverseStatus Lead_Reverse_Status{get;set;}
    }
    
    
    public class LeadReverseStatus {
        public String Talisma_Id { get; set; }
        public String AssignTo { get; set; }
        public String Reference_Number_Lead { get; set; }
        public Decimal Amount_Lead { get; set; }
        public String Reverse_Feed_status_Lead { get; set; }
        public String Rejection_Reason_Lead { get; set; }
        }



}