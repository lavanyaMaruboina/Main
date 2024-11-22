public with sharing class ScanUploadDocumentQueuable implements Queueable, Database.AllowsCallouts{

    public string scanDocumentUploadString;
    public ScanUploadDocumentQueuable(string uploadString) {
        this.scanDocumentUploadString = uploadString;

    }

    public void execute(QueueableContext context) {
        String apiResponse = '';
        String responseBody = '';
        String loanAppId;
        String loanApplicationRef;
        String elapseTime;
        String encryptedRequest='/';
        String institutionIdPerfios='';
        IND_ScanDocumentUploadResponse scanDocumentUploadResponse;
        
        HttpRequest request;
        try{
            if(String.isBlank(this.scanDocumentUploadString)){
                throw new IND_Exception(System.Label.Retry);
            }
            Integration_Configuration__mdt apiConfiguration = IntegrationUtilities.getAPIConfiguration(System.Label.ScanDocumentUpload);
            Integer timeout = Integer.valueOf(apiConfiguration.Timeout__c);           
            RequestWrapper requestWrapper = (RequestWrapper)IntegrationUtilities.parseJSONRequest(this.scanDocumentUploadString,'RequestWrapper');
            loanAppId = requestWrapper.loanApplicationId;
            loanApplicationRef= requestWrapper.loanApplicationId;
            List<ContentVersion> bankStatements = IntegrationEngine.getAttachedContentVersions(requestWrapper.contentId);
            if(bankStatements.isEmpty()){
                throw new IND_Exception('Bank Statement not found');
            }
            String extension = bankStatements[0].FileExtension;
            String filename='';
            blob docblob;
                filename= bankStatements[0].Title+'.'+bankStatements[0].FileExtension;
                docblob = bankStatements[0].versionData;  
            String contentType = ScanUploadHttpBodyPart.GetContentType();
            String form64='';
            form64 += ScanUploadHttpBodyPart.WriteBoundary();
            form64 += ScanUploadHttpBodyPart.WriteBlobBodyParameter('file', EncodingUtil.base64Encode(docblob),filename);      
            blob formBlob = EncodingUtil.base64Decode(form64);
            form64= null; //To prevent heap size limit error
            string contentLength = string.valueOf(formBlob.size());
            Map<String,String> requestHeaderMap = Utilities.getHeaders(); 
            //  Compose the http request
            request = new HttpRequest();
            request.setBodyAsBlob(formBlob);
            request.setHeader('Connection', 'keep-alive');
            request.setHeader('Content-Length', contentLength);
            request.setHeader('Content-Type', contentType);
            request.setMethod('POST');
            request.setTimeout(timeout);
            request.setEndpoint('callout:Indus_API'+apiConfiguration.Endpoint_URL__c.trim()+requestWrapper.perfiosTransactionId);
            request.setHeader('IBL-Client-Id', requestHeaderMap.get('IBL-Client-Id'));
            request.setHeader('IBL-Client-Secret', requestHeaderMap.get('IBL-Client-Secret'));          
            Long startTime = DateTime.now().getTime();  
            Http http = new Http();        
            HttpResponse response = http.send(request);
            Long endTime = DateTime.now().getTime();
            elapseTime = String.valueOf((Double)(endTime - startTime)/1000);
            
            if(response != null){
                if(response.getStatusCode()==200){
                    responseBody = response.getBody();
                    responseBody = responseBody.substring(10, responseBody.length()-2);                        
                    String decryptedResponse = IntegrationUtilities.getDecryptedResponse(responseBody,System.Label.privateKey,System.Label.ivkey);
                    String searalizedJson = JSON.serializePretty(JSON.deserializeUntyped(decryptedResponse));   
                    scanDocumentUploadResponse = (IND_ScanDocumentUploadResponse)IntegrationUtilities.parseJSONResponse(searalizedJson,'IND_ScanDocumentUploadResponse');
					List<Bank_Masters__c>  bankMasters =[Select perfios_bank_code__c from bank_masters__c where Name=:requestWrapper.bankName WITH SECURITY_ENFORCED Limit 1];
                    if(!bankMasters.isEmpty()){   
  					institutionIdPerfios = String.valueOf(bankMasters[0].perfios_bank_code__c);
                        if(institutionIdPerfios!=null){
                            institutionIdPerfios = institutionIdPerfios.replace(',','');
                        }
                        else{
                            institutionIdPerfios='';
                        }
            		} 
                    String scanUploadProcessString = '{"perfiosTransactionId": "'+requestWrapper.perfiosTransactionId+'","institutionId":"'+institutionIdPerfios+'","password":"'+requestWrapper.password+'","fileId": "'+scanDocumentUploadResponse.file.fileId+'","loanApplicationId":"'+requestWrapper.loanApplicationId+'","incomeDetailId":"'+requestWrapper.incomeDetailId+'"}';
                    Map<String,String> scanUploadResponse = new Map<String,String>();
                    //System.enqueueJob(new doScanUploadProcessQueueable(scanUploadProcessString));
                    IntegrationEngine.doScanUploadProcess(scanUploadProcessString);
                   /* scanUploadResponse=(Map<String,String>)doScanUploadProcess(scanUploadProcessString);*/
                    IntegrationUtilities.createIntegrationLogger(request.getBody(), encryptedRequest, IntegrationUtilities.getPlainTextForLog(response.getBody()), response.getBody(), System.Label.ScanDocumentUpload, elapseTime,loanAppId,System.Label.Success);
                    //return scanUploadResponse;
                } else {
                    String errString = '[Status Code = '+ response.getStatusCode() +' ] Response-->'+IntegrationUtilities.getPlainTextForLog(response.getBody());
                    responseBody = response.getBody();                        
					responseBody = responseBody.substring(10, responseBody.length()-2);                        
					String decryptedResponse = IntegrationUtilities.getDecryptedResponse(responseBody,System.Label.privateKey,System.Label.ivkey);
					apiResponse = JSON.serializePretty(JSON.deserializeUntyped(decryptedResponse));
                    IntegrationUtilities.createIntegrationLogger(request.getBody(), encryptedRequest, IntegrationUtilities.getPlainTextForLog(response.getBody()), response.getBody(), System.Label.ScanDocumentUpload, elapseTime,loanAppId,System.Label.Failure);
                    ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'doBankStatementScanDocumentUpload', System.Label.Apex, new IND_Exception(errString), loanAppId);
                    throw new IND_Exception(apiResponse);
                }     
            }
            else {
                IntegrationUtilities.createIntegrationLogger(request.getBody(), encryptedRequest, '', '', System.Label.ScanDocumentUpload, elapseTime,loanAppId,System.Label.Failure);
                ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'doBankStatementScanDocumentUpload', System.Label.Apex, new IND_Exception(), loanAppId);
                throw new IND_Exception(System.Label.NoResponse);
            }           
            
        } catch(Exception ex) {
			ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'doBankStatementScanDocumentUpload', System.Label.Apex, ex,loanAppId);
            throw ex;
        }
    }
}