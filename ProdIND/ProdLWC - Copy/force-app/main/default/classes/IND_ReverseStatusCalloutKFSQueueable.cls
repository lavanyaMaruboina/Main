public class IND_ReverseStatusCalloutKFSQueueable implements Queueable, Database.AllowsCallouts{
    Public String keyfactId;
    Public String status;
    //Public String DealNo;

    public IND_ReverseStatusCalloutKFSQueueable(String keyfactId,String status){
        this.keyfactId = keyfactId;
        this.status = status;
        //this.DealNo = DealNo;
    }
    Public void execute(QueueableContext context) { 
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        HttpResponse response = new HttpResponse();
        String responseBody ='';   
        String returnStr ='';    
        String elapseTime = ''; 
        List<Key_Fact_Statement__c> kfsList = [SELECT Id,Product_Type__c,Unique_Id__c,Lead_Number__c,Deal_Number__c,Product__c,Loan_Application__c,Maker_Id__c,ProCredit_Deal__c FROM Key_Fact_Statement__c WHERE Id = :keyfactId];
         try{   
            Integration_Configuration__mdt apiConfiguration = IntegrationUtilities.getAPIConfiguration(System.Label.Reverse_Status_of_KFS_statement);
            if(apiConfiguration != null){
                if(!apiConfiguration.IsActive_Integration__c){
                    ErrorLoggerUtil.logErrorEvent('IntegrationEngine', System.Label.Reverse_Status_of_KFS_statement, System.Label.Apex, new AuraHandledException('Integration is not Active'));
                    throw new AuraHandledException('Integration is not Active');       
                }
                String methodType = apiConfiguration.Rest_Method__c.trim();
                String endpoint ='callout:Indus_API'+apiConfiguration.Endpoint_URL__c.trim();
            
                KFSReverseStatusRequest requestWrapper = new KFSReverseStatusRequest();   
                requestWrapper.Deal_No_Details = new List<Deal>();
                if (!kfsList.isEmpty()) {
                    // Opportunity opportunity = oppList[0];
                   // LeadReverseStatus leadReverseStatus = new LeadReverseStatus();
                   String dealValue='';
                   dealValue = kfsList[0].Deal_Number__c;
                   if(dealValue.contains(';')){
                    List<String> dealNumbers = dealValue.split(';');
                    //List<Map<String, String>> jsonList = new List<Map<String, String>>();
                    for (String dealNo : dealNumbers) {
                        // Create a new map for each deal
                               Deal deal = new Deal();
                                deal.Deal_No = dealNo;
                                deal.Status = status;
                                requestWrapper.Deal_No_Details.add(deal);
                        // Add the map to the list
                        //jsonList.add(dealJson);
                    }
                   }else{
                    Deal deal = new Deal();
                    deal.Deal_No = dealValue; // Assign the single deal number
                    deal.Status = status;
                    
                    // Add the deal to the wrapper's list
                    requestWrapper.Deal_No_Details.add(deal);
                   }
                  if(kfsList[0].ProCredit_Deal__c != null){
                        requestWrapper.Source = 'Procredit';
                    }else{
                        requestWrapper.Source = 'Salesforce';
                    }
                    requestWrapper.Lead_Id = kfsList[0].Lead_Number__c != null ? kfsList[0].Lead_Number__c : '';
                    requestWrapper.Batch_Id = kfsList[0].Unique_Id__c != null ? kfsList[0].Unique_Id__c : '';
                    requestWrapper.Product = kfsList[0].Product__c != null ? kfsList[0].Product__c : kfsList[0].Product_Type__c != null ? kfsList[0].Product_Type__c:'';
                    //requestWrapper.Status = status != null ? status : '';
                    requestWrapper.Maker_Id = kfsList[0].Maker_Id__c != null ? kfsList[0].Maker_Id__c:'';
                    // if(status == 'Withdrawn'){
                    //     leadReverseStatus.Reverse_Feed_status_Lead = 'Drop';
                    // }
                    // if(status == 'Sanctioned'){
                    //     leadReverseStatus.Reverse_Feed_status_Lead = 'Converted';
                    // }
                    // if(status == 'Rejected'){
                    //     leadReverseStatus.Reverse_Feed_status_Lead = 'Drop';
                    //     LeadReverseStatus.Rejection_Reason_Lead = 'Rejected post login';
                    // }
                    // if(status == 'L1Completed'){
                    //     leadReverseStatus.Reverse_Feed_status_Lead = 'Work in progress';
                    // }


                    // requestWrapper.Lead_Reverse_Status = leadReverseStatus;
                }
           // String jsonOutput = JSON.serialize(requestWrapper);
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
                if(kfsList[0].Loan_Application__c == null){
                    IntegrationUtilities.createIntegrationLogger(requestBody, requestBodyJSON, returnStr, response.getBody(), System.Label.Reverse_Status_KFS_Consent_Procredit, elapseTime, kfsList[0].ProCredit_Deal__c, System.Label.Success);
                }else{
                    IntegrationUtilities.createIntegrationLogger(requestBody, requestBodyJSON, returnStr, response.getBody(), System.Label.Reverse_Status_of_KFS_statement, elapseTime, kfsList[0].Loan_Application__c, System.Label.Success);
                }
            }
            else{
                System.debug('++++ not 200 response.getStatusCode() ' +response.getStatusCode());
                String errString = '[Status Code = '+ response.getStatusCode() +' ] Response-->'+IntegrationUtilities.getPlainTextForLog(response.getBody());
                if(kfsList[0].Loan_Application__c == null){
                    IntegrationUtilities.createIntegrationLogger(requestBody, requestBodyJSON, returnStr, response.getBody(), System.Label.Reverse_Status_KFS_Consent_Procredit, elapseTime, kfsList[0].ProCredit_Deal__c, System.Label.Failure);
                }else{
                    IntegrationUtilities.createIntegrationLogger(requestBody, requestBodyJSON, errString, response.getBody(),System.Label.Reverse_Status_of_KFS_statement, elapseTime, kfsList[0].Loan_Application__c, System.Label.Failure);  
                }
            }   
            }    
        }catch(Exception ex){
            if(kfsList[0].Loan_Application__c == null){
                ErrorLoggerUtil.logErrorEvent('IND_ReverseStatusCalloutKFSQueueable', 'execute', System.Label.Apex, ex, kfsList[0].ProCredit_Deal__c);
            }else{
                ErrorLoggerUtil.logErrorEvent('IND_ReverseStatusCalloutKFSQueueable', 'execute', System.Label.Apex, ex, kfsList[0].Loan_Application__c);
            }
           
        }
    }

    // class KFSReverseStatusRequest{
        //     public LeadReverseStatus Lead_Reverse_Status{get;set;}
    // }
    
    
    public class KFSReverseStatusRequest {
        public String Lead_Id { get; set; }
        //public String Deal_No { get; set; }
        public String Product { get; set; }
        public String Source { get; set; }
        //public String Status { get; set; }
        public String Maker_Id { get; set; }
        public String Batch_Id { get; set; }
        public List<Deal> Deal_No_Details { get; set; }
}
public class Deal {
    public String Deal_No { get; set; }
    public String Status { get; set; }
}
    }