/*------------------------------------------------------------
Author:        Santhosh Mothe
Company:       Persistent Systems
Description:   This class contains for subscriber platform event's tirgger helper methods
Inputs:        None 
Test Class:    IntegrationEngineTest 
History
Date            Author              Comments
-------------------------------------------------------------
1-10-2021      Santhosh Mothe      Created
------------------------------------------------------------*/
public  with sharing class UpdateTargetAPIObjectHelper extends TriggerHandler{
    
    //Global Variable for to be used for Casting the Sobject details
    List<Integration_Log__c> newIntegrationLogList;
    List<Integration_Log__c> oldIntegrationLogList;
    Map<Id,Integration_Log__c> newIntegrationLogMap;
    Map<Id,Integration_Log__c> oldIntegrationLogMap;
    public UpdateTargetAPIObjectHelper(){
        newIntegrationLogList = (List<Integration_Log__c>)Trigger.new;
        oldIntegrationLogList = (List<Integration_Log__c>)Trigger.old;
        newIntegrationLogMap = (MAP<Id,Integration_Log__c>)Trigger.newMap;
        oldIntegrationLogMap = (MAP<Id,Integration_Log__c>)Trigger.oldMap;
    }
    
    public override void afterInsert() {
        List<Attachment> documentList = new List<Attachment>();
        String loanApplicationId = '';
        try{
           
            for(Integration_Log__c ilog: newIntegrationLogList){
                system.debug('from trigger ilog.id '+ilog.id);
                if(!String.isBlank(ilog.RequestExt__c) && ilog.isSync__c){
                    
                    Attachment reqExt = new Attachment(); 
                    reqExt.Name = 'Request extension file';
                    reqExt.ParentId = ilog.id;
                    reqExt.Body = Blob.valueOf(ilog.RequestExt__c);
                    reqExt.ContentType = 'txt';
                    loanApplicationId = ilog.Loan_Application__c;
                    documentList.add(reqExt);
                    
                    Attachment req = new Attachment(); 
                    req.Name = 'Request file';
                    req.ParentId = ilog.id;
                    req.Body = Blob.valueOf(ilog.Original_request__c );
                    req.ContentType = 'txt';
                    documentList.add(req);
                }
                
                 if(!String.isBlank(ilog.ResponseExt__c) && ilog.isSync__c){
                    
                    Attachment reqExt = new Attachment(); 
                    reqExt.Name = 'Response extension file';
                    reqExt.ParentId = ilog.id;
                    reqExt.Body = Blob.valueOf(ilog.ResponseExt__c);
                    reqExt.ContentType = 'txt';
                     loanApplicationId = ilog.Loan_Application__c;
                    documentList.add(reqExt);
                    
                    Attachment req = new Attachment(); 
                    req.Name = 'Response file';
                    req.ParentId = ilog.id;
                    req.Body = Blob.valueOf(ilog.Original_response__c);
                    req.ContentType = 'txt';
                    documentList.add(req);
                }
            }
            if(Schema.sObjectType.Attachment.isCreateable() && documentList.size()>=1){
                insert documentList;
            }
            
        }Catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('UpdateTargetAPIObjectHelper', 'afterUpdate', 'Trigger', e, loanApplicationId);
            
        }        
    }
    public override void afterUpdate() {
        String loanApplicationId = '';
        String serviceName = '';
        Map<String, String> applicantIdResponseMap = new Map<String, String>();
        Map<String, String> selfieIdResponseMap = new Map<String, String>();
        Map<String, String> perfioIdResponseMap = new Map<String, String>();
        try{
            for(Integration_Log__c ilog: newIntegrationLogList){
                system.debug('inside for loop');
                if(ilog.Service_Name__c == System.Label.DocumentReport){
                    system.debug('orginal response:'+ilog.Original_response__c);
                    applicantIdResponseMap.put(ilog.targetRecordId__c, ilog.Original_response__c);
                    loanApplicationId = ilog.Loan_Application__c;
                }
                else if(ilog.Service_Name__c == System.Label.Selfie_Report){
                    system.debug('Selfie orginal response:'+ilog.Original_response__c);
                    selfieIdResponseMap.put(ilog.targetRecordId__c, ilog.Original_response__c);
                    loanApplicationId = ilog.Loan_Application__c;
                }
                else if(ilog.Service_Name__c == System.Label.GSTStatus ||
                        ilog.Service_Name__c == System.Label.ITRStatus ||
                        ilog.Service_Name__c == System.Label.Perfios_BS_Transaction_Status ||
                       ilog.Service_Name__c == System.Label.ScanUploadRetrieveReport ||
                       ilog.Service_Name__c == System.Label.ITR_Scan_upload_retrieve_report){
                    perfioIdResponseMap.put(ilog.targetRecordId__c, ilog.Original_response__c);
                    loanApplicationId = ilog.Loan_Application__c;
					serviceName = ilog.Service_Name__c;
                }
            }
            if(!applicantIdResponseMap.isEmpty()){
                updateApplicantDocReportResponse(applicantIdResponseMap);
            }else if(!selfieIdResponseMap.isEmpty()){
                updateSelfieReportResponse(selfieIdResponseMap);
            }else if(!perfioIdResponseMap.isEmpty()){
                updatePerfioResponse(perfioIdResponseMap, serviceName);
            }
        }Catch(Exception e){
            ErrorLoggerUtil.logErrorEvent('UpdateTargetAPIObjectHelper', 'afterUpdate', 'Trigger', e, loanApplicationId);
            
        }        
    }

    /*
* @Method:      updateApplicantDocReportResponse
* @Created by:  Santhosh Mothe
* @Description: Method to process the repose to put in document
* @Param:       Map - ApplicantIdDocIdResponseMap
* @Return:      void
*/
    public void updateApplicantDocReportResponse(Map<String, String> applicantIdDocIdResponseMap){
        
      system.debug('*********************************updateApplicantResponse***********************************************');
        DocAuthRawResponse apiResponse;
        List<String> apiResponseList = new List<String>();

        Map<string, Object> rawResponseappliantId = new Map<string, Object>();
        
        if(!applicantIdDocIdResponseMap.isEmpty()){
            for(String appIdDocId : applicantIdDocIdResponseMap.keySet()){
                
                String str = applicantIdDocIdResponseMap.get(appIdDocId);
                system.debug('response pushed from PE :'+str);
                Map<String, object> serialzedJsonMap = (Map<String, object>)JSON.deserializeUntyped(str);  
                Map<String, Object> responseData = (Map<String, Object>) serialzedJsonMap.get('ResponseData');

                if(responseData == null){
                    break;
                }
               
                Map<String, Object> fields = (Map<String, Object>) responseData.get('Fields');
                Map<String, Object> applicants = (Map<String, Object>) fields.get('Applicants');
               
                Map<String, Object> applicant = (Map<String, Object>) applicants.get('Applicant');
                
                Map<String, Object> services = (Map<String, Object>) applicant.get('Services');
                
                List<Object> serviceList = (List<Object>) services.get('Service');
               
                Map<String, Object> service = (Map<String, Object>) serviceList.get(0);
                Map<String, Object> operations = (Map<String, Object>) service.get('Operations');
                
                List<Object> operationList = (List<Object>) operations.get('Operation');
                
                Map<String, Object> operation = (Map<String, Object>) operationList.get(0);
                
                Map<String, Object> data = (Map<String, Object>) operation.get('Data');
                Map<String, Object> resp = (Map<String, Object>) data.get('Response');
                
                String rawResponse = (String)resp.get('RawResponse'); 
                if(!String.isBlank(rawResponse)){
                    rawResponse = rawResponse.replaceAll('[\\s]', '');
                    rawResponseappliantId.put(appIdDocId.right(18), rawResponse);
                    apiResponseList.add(rawResponse);
                }
                
            }
        }
		
        Set<String> docIdList = new Set<String>();
        List<Documents__c> updateDocsList = new List<Documents__c>();
        
		if(!rawResponseappliantId.isEmpty()){
            docIdList = rawResponseappliantId.keySet();
        
        for(Documents__c doc:[Select id, Raw_Response__c, Applicant__r.id from Documents__c where id in :docIdList]){
            doc.Raw_Response__c = String.valueOf(rawResponseappliantId.get(doc.id)) ;
            
            boolean docAuthPass = false;
            for(String apiResp : apiResponseList){

                Map<String, object> serialzedJsonMap = (Map<String, object>)JSON.deserializeUntyped(apiResp);
                    List<Object> reportsList = (List<Object>) serialzedJsonMap.get('reports');

                    Map<String, Object> reports = (Map<String, Object>) reportsList.get(0);
                    String result = (String) reports.get('result');
                    String sub_result = (String) reports.get('sub_result');

                    if(result == 'clear'){
                        system.debug('PASS');
                        docAuthPass = true;
                    } else if(result == 'consider' && sub_result == 'caution'){
                        Map<String, Object> breakdown = (Map<String, Object>) reports.get('breakdown');
                        Map<String, Object> image_integrity = (Map<String, Object>) breakdown.get('image_integrity');
                        String image_integrity_result = (String) image_integrity.get('result');
                        if(image_integrity_result == 'clear'){
                            system.debug('PASS');
                            docAuthPass = true;
                        }
                    } else {
                        system.debug('FAIL');//false
                    }
                
                doc.DocAuth_Passed__c  = docAuthPass;
                updateDocsList.add(doc);
            }
			}
		}
        
         if(!updateDocsList.isEmpty() && Schema.sObjectType.Documents__c.isUpdateable()){
            update updateDocsList;
        }  
    }
    
    public void updateSelfieReportResponse(Map<String, String> selfieIdResponseMap){
        system.debug('*********************************updateSelfieReportResponse***********************************************');
        SelfieReportRawReponse apiResponse;
        List<SelfieReportRawReponse> apiResponseList = new List<SelfieReportRawReponse>();
        Map<string, Object> rawResponseappliantId = new Map<string, Object>();
        
		if(!selfieIdResponseMap.isEmpty()){
            for(String appIdDocId : selfieIdResponseMap.keySet()){
                
                // string str = '{"RequestId":"03102021204513966","ResponseData":{"Status":"Success","ResponseInfo":{"ApplicationId":22546137,"SolutionSetInstanceId":"cb894105-318c-4c0c-b5da-71b66366624b"},"Fields":{"Applicants":{"Applicant":{"ApplicantFirstName":"Karthi","ApplicantMiddleName":"","ApplicantLastName":"M","Services":{"Service":[{"Id":"","Name":"DocumentAuthentication","Operations":{"Operation":[{"Id":"","Name":"DocumentReport","Params":{"Param":[{"Name":"DocumentCheckId","Value":"ab579ec7-81d7-49ca-8fe7-f4764c87b957"},{"Name":"DocumentCheckId","Value":"ab579ec7-81d7-49ca-8fe7-f4764c87b957"}]},"Data":{"Response":{"RawResponse":"{\"reports\":[{\"created_at\":\"2021-10-03T14:11:07Z\",\"documents\":[{\"id\":\"5f1fdef3-083a-4229-bb89-176c79fbb725\"}],\"href\":\"/v2/checks/ab579ec7-81d7-49ca-8fe7-f4764c87b957/reports/3c35eb2a-6759-44a2-ad4d-18155d8daeae\",\"id\":\"3c35eb2a-6759-44a2-ad4d-18155d8daeae\",\"name\":\"document\",\"properties\":{\"first_name\":\"KARTHI\",\"last_name\":\"M\",\"issuing_country\":\"IND\",\"document_numbers\":[{\"type\":\"document_number\",\"value\":\"BYOPK0288D\"}],\"document_type\":\"tax_id\",\"date_of_birth\":\"1988-03-27\"},\"result\":\"consider\",\"status\":\"complete\",\"sub_result\":\"caution\",\"variant\":\"standard\",\"breakdown\":{\"data_comparison\":{\"result\":null,\"breakdown\":{\"date_of_expiry\":{\"result\":null,\"properties\":{}},\"issuing_country\":{\"result\":null,\"properties\":{}},\"document_type\":{\"result\":null,\"properties\":{}},\"document_numbers\":{\"result\":null,\"properties\":{}},\"gender\":{\"result\":null,\"properties\":{}},\"date_of_birth\":{\"result\":null,\"properties\":{}},\"last_name\":{\"result\":null,\"properties\":{}},\"first_name\":{\"result\":null,\"properties\":{}}}},\"data_consistency\":{\"result\":null,\"breakdown\":{\"date_of_expiry\":{\"result\":null,\"properties\":{}},\"document_type\":{\"result\":null,\"properties\":{}},\"nationality\":{\"result\":null,\"properties\":{}},\"issuing_country\":{\"result\":null,\"properties\":{}},\"document_numbers\":{\"result\":null,\"properties\":{}},\"gender\":{\"result\":null,\"properties\":{}},\"date_of_birth\":{\"result\":null,\"properties\":{}},\"last_name\":{\"result\":null,\"properties\":{}},\"first_name\":{\"result\":null,\"properties\":{}}}},\"data_validation\":{\"result\":\"clear\",\"breakdown\":{\"document_expiration\":{\"result\":null,\"properties\":{}},\"gender\":{\"result\":null,\"properties\":{}},\"document_numbers\":{\"result\":\"clear\",\"properties\":{\"document_number\":\"clear\"}},\"expiry_date\":{\"result\":null,\"properties\":{}},\"date_of_birth\":{\"result\":\"clear\",\"properties\":{}},\"mrz\":{\"result\":null,\"properties\":{}}}},\"compromised_document\":{\"result\":\"clear\"},\"image_integrity\":{\"result\":\"consider\",\"breakdown\":{\"conclusive_document_quality\":{\"result\":\"consider\",\"properties\":{\"missing_back\":\"clear\",\"digital_document\":\"clear\",\"punctured_document\":\"clear\",\"corner_removed\":\"clear\",\"watermarks_digital_text_overlay\":\"clear\",\"abnormal_document_features\":\"clear\",\"obscured_security_features\":\"consider\",\"obscured_data_points\":\"clear\"}},\"colour_picture\":{\"result\":\"clear\",\"properties\":{}},\"supported_document\":{\"result\":\"clear\",\"properties\":{}},\"image_quality\":{\"result\":\"clear\",\"properties\":{}}}},\"age_validation\":{\"result\":\"clear\",\"breakdown\":{\"minimum_accepted_age\":{\"result\":\"clear\",\"properties\":{}}}},\"police_record\":{\"result\":null},\"visual_authenticity\":{\"result\":\"clear\",\"breakdown\":{\"other\":{\"result\":\"clear\",\"properties\":{}},\"digital_tampering\":{\"result\":null,\"properties\":{}},\"fonts\":{\"result\":null,\"properties\":{}},\"security_features\":{\"result\":null,\"properties\":{}},\"template\":{\"result\":null,\"properties\":{}},\"picture_face_integrity\":{\"result\":null,\"properties\":{}},\"face_detection\":{\"result\":\"clear\",\"properties\":{}},\"original_document_present\":{\"result\":\"clear\",\"properties\":{\"scan\":\"clear\",\"document_on_printed_paper\":\"clear\",\"screenshot\":\"clear\",\"photo_of_screen\":\"clear\"}}}}}}]}"}},"Status":"Pass"}]},"Status":"Pass"}]},"ApplicantIdentifier":"c17f1c3d-00f4-4cd2-b28a-50b541ebd85e"}},"ApplicationData":{"Services":{"Service":{"Id":"","Name":"DocumentAuthentication","Skip":"N","Consent":"true","EnableSimulation":"False"}}},"Decision":"Pass","ApplicationId":"22546137"}}}';
                String str = selfieIdResponseMap.get(appIdDocId);
                
                Map<String, object> serialzedJsonMap = (Map<String, object>)JSON.deserializeUntyped(str);  
                Map<String, Object> responseData = (Map<String, Object>) serialzedJsonMap.get('ResponseData');

                if(responseData == null){
                    break;
                }
                
                Map<String, Object> fields = (Map<String, Object>) responseData.get('Fields');
                Map<String, Object> applicants = (Map<String, Object>) fields.get('Applicants');
                
                Map<String, Object> applicant = (Map<String, Object>) applicants.get('Applicant');
                
                Map<String, Object> services = (Map<String, Object>) applicant.get('Services');
                
                List<Object> serviceList = (List<Object>) services.get('Service');
                
                Map<String, Object> service = (Map<String, Object>) serviceList.get(0);
                Map<String, Object> operations = (Map<String, Object>) service.get('Operations');
                
                List<Object> operationList = (List<Object>) operations.get('Operation');

                if(!operationList.isEmpty()){
                    break;
                }
                
                Map<String, Object> operation = (Map<String, Object>) operationList.get(0);

                if(operation == null){
                    break;
                }
                
                Map<String, Object> data = (Map<String, Object>) operation.get('Data');

                if(data == null){
                    break;
                }

                Map<String, Object> resp = (Map<String, Object>) data.get('Response');

                if(resp == null){
                    break;
                }
                
                rawResponseappliantId.put(appIdDocId.right(18), resp.get('RawResponse'));
                
                apiResponse = (SelfieReportRawReponse) IntegrationUtilities.parseJSONResponse((String)resp.get('RawResponse'), 'SelfieReportRawReponse'); 
                apiResponseList.add(apiResponse);
                
            }
        }
        
        Set<String> docIdList = new Set<String>();
        List<Documents__c> updateDocsList = new List<Documents__c>();
        
		if(!rawResponseappliantId.isEmpty()){
        docIdList = rawResponseappliantId.keySet();
        
        system.debug('docIdList---:'+docIdList);        
        
        
        for(Documents__c doc:[Select id, Raw_Response_for_Selfie_Report__c, Applicant__r.id from Documents__c where id in :docIdList WITH SECURITY_ENFORCED]){
            doc.Raw_Response_for_Selfie_Report__c = String.valueOf(rawResponseappliantId.get(doc.id)) ;
            
            boolean selfieReportPass = false;
            
            for(SelfieReportRawReponse apiResp : apiResponseList){
               
                for(SelfieReportRawReponse.Reports report: apiResp.reports )
                {
                    
                    system.debug('report.result---------:'+report.result);
                    if(report.result=='clear'){
                        system.debug('inside result clear');
                        selfieReportPass=true;
                        
                    }
                    
                }
                doc.Selfie_report_Pass__c   = selfieReportPass;
                updateDocsList.add(doc);
            }
        }
    }
        
        if(!updateDocsList.isEmpty() && Schema.sObjectType.Documents__c.isUpdateable()){
            update updateDocsList;
        }
        
        
    }
    
    // @Method:	updatePerfioResponse
    // @Created by:	Bhushan Charde
    // @Description:This will update the Perfios related data
    // @Param: Map	
    public void updatePerfioResponse(Map<String, String> perfioIdResponseMap, String serviceName){
        system.debug('updatePerfioResponse '+perfioIdResponseMap);
        List<Income_Details__c> incomeList = new List<Income_Details__c>();
        if(!perfioIdResponseMap.isEmpty()){
            
            for(String id : perfioIdResponseMap.keySet()){
                
                String responseStr = perfioIdResponseMap.get(id);
                String searalizedJson = JSON.serializePretty(JSON.deserializeUntyped(responseStr));
                PerfiosStatusAPIResponse apiResponse = (PerfiosStatusAPIResponse) IntegrationUtilities.parseJSONResponse(searalizedJson, 'PerfiosStatusAPIResponse');
                system.debug('updatePerfioResponse apiResponse  '+apiResponse);
                String clientTxnId = apiResponse.clientTransactionId;
                List<Income_Details__c> incomeDtlList = [Select Id, Client_Transaction_Id__c 
                                                         FROM Income_Details__c
                                                         WHERE Id =: id 
                                                         AND Client_Transaction_Id__c =:clientTxnId WITH SECURITY_ENFORCED];
                
                for(Income_Details__c incomeDtl : incomeDtlList){
                    incomeDtl.API_Transaction_Status__c = apiResponse.status;
                    incomeDtl.Perfios_Transaction_Id__c = apiResponse.perfiosTransactionId;
                    incomeList.add(incomeDtl);
                }
                 
                //code for calling report API
                if(apiResponse.status == 'COMPLETED' && serviceName.equalsIgnoreCase(System.Label.ScanUploadRetrieveReport)){
                     doScanUploadJsonRetrieveReport(id, apiResponse.perfiosTransactionId, serviceName, clientTxnId); 
                     doScanUploadXlsxRetrieveReport(id, apiResponse.perfiosTransactionId, serviceName, clientTxnId);
                }
                else if(apiResponse.status == 'COMPLETED' && serviceName.equalsIgnoreCase(System.Label.ITR_Scan_upload_retrieve_report)){
                     doITRScanUploadJsonRetrieveReport(id, apiResponse.perfiosTransactionId, serviceName, clientTxnId); 
                     doITRScanUploadXlsxRetrieveReport(id, apiResponse.perfiosTransactionId, serviceName, clientTxnId);
                }
              	else if(apiResponse.status == 'COMPLETED' && (serviceName.equalsIgnoreCase(System.Label.GSTStatus) || serviceName.equalsIgnoreCase(System.Label.ITRStatus) || serviceName.equalsIgnoreCase(System.Label.Perfios_BS_Transaction_Status))){
                   perfiosXlsxReportAPI(id, apiResponse.perfiosTransactionId, serviceName, clientTxnId);
                   perfiosJsonReportAPI(id, apiResponse.perfiosTransactionId, serviceName, clientTxnId); 
                }
            }
            update incomeList;           
        }
    }
	
	// @Method:	perfiosXlsxReportAPI
    // @Created by:	Bhushan Charde
    // @Description:This will update the Perfios Reports related data
    // @Param: String, String
    @future (callout=true)
    public static void perfiosXlsxReportAPI(String targetObjId, String perfiosId, String serviceName, String clientTxnId){
		system.debug('perfiosXlsxReportAPI inside-- '+targetObjId+' pid '+perfiosId+' serviceName '+serviceName);   
		String servivceNameforReportAPI = '';      
        if(String.isBlank(targetObjId)){
            throw new IND_Exception(System.Label.Retry);
        }
        
        Integration_Configuration__mdt apiConfiguration;
        
        if(serviceName.contains('GST')){
            apiConfiguration = IntegrationUtilities.getAPIConfiguration(System.Label.GSTReport);
			servivceNameforReportAPI = System.Label.GSTReport;
        } else if(serviceName.contains('ITR')) {
            apiConfiguration = IntegrationUtilities.getAPIConfiguration(System.Label.ITRReport);
			servivceNameforReportAPI = System.Label.ITRReport;
        } else {
            apiConfiguration = IntegrationUtilities.getAPIConfiguration(System.Label.Perfios_BS_Report);
			servivceNameforReportAPI = System.Label.Perfios_BS_Report;
        }
        
        Integer timeout = Integer.valueOf(apiConfiguration.Timeout__c);
        Security_Setting__mdt metadataApi = Security_Setting__mdt.getInstance(System.Label.IBMMasterKey);
        
        
        if(!apiConfiguration.IsActive_Integration__c){
            throw new IND_Exception(System.Label.ServiceDown);
        }
			
        String loanAppId;
        String requestBody;
        String encryptedRequest;
        String elapseTime;
        try{
            
            String methodType = apiConfiguration.Rest_Method__c.trim();
            String endpoint ='callout:Indus_API'+apiConfiguration.Endpoint_URL__c.trim();
            Long startTime = DateTime.now().getTime();
			Income_Details__c app = [SELECT Id, Applicant__r.Opportunity__c, Capture_ITR_Method__c, Capture_GST_Method__c FROM Income_Details__c WHERE Id=:targetObjId WITH SECURITY_ENFORCED];
            Opportunity opty = [SELECT Id, Lead_number__c FROM Opportunity WHERE Id=: app.Applicant__r.Opportunity__c WITH SECURITY_ENFORCED];
            ParentAPIRequest req;
            loanAppId = opty.Id;
            
            if(serviceName.contains('GST')){
               req = new IND_PerfiosGSTReportRequest(app, opty, perfiosId, System.Label.ReportFormat_XLSX); 
            } else if(serviceName.contains('ITR')) {
               req = new IND_PerfiosITRReportRequest(app, opty, perfiosId, System.Label.ReportFormat_XLSX); 
            } else {
               req = new IND_PerfiosBSReportRequest(app, perfiosId, clientTxnId, System.Label.ReportFormat_XLSX); 
            }
            
		    requestBody = req.convertToJSON();
		    encryptedRequest = IntegrationUtilities.getEncryptedRequest(requestBody, System.Label.privateKey, System.Label.ivkey);  
            String JdataRequest = '"JData":';                    
            encryptedRequest ='{'+JdataRequest + '"'+encryptedRequest+'"'+'}';
			
			
            HttpRequest httpRequest = new HttpRequest();
            httpRequest.setMethod(methodType);
            httpRequest.setEndpoint(endpoint);
            httpRequest.setHeader(IntegrationConstants.CONTENT_TYPE , IntegrationConstants.CONTENT_TYPE_JSON);
            httpRequest.setHeader('IBL-Client-Id', metadataApi?.Client_Id__c);
        	httpRequest.setHeader('IBL-Client-Secret', metadataApi?.Client_Secret__c);
			httpRequest.setbody(encryptedRequest);
            
            Http http = new Http();
            HttpResponse response = http.send(httpRequest);
            
            Long endTime = DateTime.now().getTime();
            elapseTime = String.valueOf((double)(endTime - startTime)/1000);
            
			List<Attachment> documentList = new List<Attachment>();
            
            if(response != null && response.getStatusCode() == 200){
                
                	ContentVersion conVer = new ContentVersion();
                    conVer.ContentLocation = 'S';
                    conVer.PathOnClient = perfiosId + '.xlsx';
                    conVer.Title = 'Perfios Report - '+perfiosId;
                    conVer.VersionData = response.getBodyAsBlob();
                    insert conVer; 
                    
                	Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:conVer.Id].ContentDocumentId;
                    
                    ContentDocumentLink conDocLink = New ContentDocumentLink();
                    conDocLink.LinkedEntityId = targetObjId;
                    conDocLink.ContentDocumentId = conDoc;
                    conDocLink.shareType = 'V';
                    insert conDocLink;
                } 
            IntegrationUtilities.createIntegrationLogger(requestBody, encryptedRequest, '', '', servivceNameforReportAPI, elapseTime, loanAppId, System.Label.Success);
            
        } catch(Exception ex){
            IntegrationUtilities.createIntegrationLogger(requestBody, encryptedRequest, '', '', servivceNameforReportAPI, elapseTime, loanAppId, System.Label.Failure);
            ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'perfiosXlsxReportAPI', System.Label.Apex, ex,loanAppId);
            throw new IND_Exception(ex.getMessage());
        }
    }
    
    // @Method:	perfiosJsonReportAPI
    // @Created by:	Bhushan Charde
    // @Description:This will update the Perfios Reports related data
    // @Param: String, String
    @future (callout=true)
    public static void perfiosJsonReportAPI(String targetObjId, String perfiosId, String serviceName, String clientTxnId){
		system.debug('perfiosJsonReportAPI inside-- '+targetObjId+' pid '+perfiosId+' serviceName '+serviceName);        
        if(String.isBlank(targetObjId)){
            throw new IND_Exception(System.Label.Retry);
        }
        String servivceNameforReportAPI='';
        Integration_Configuration__mdt apiConfiguration;
        
        if(serviceName.contains(System.Label.GSTStatus)){
            apiConfiguration = IntegrationUtilities.getAPIConfiguration(System.Label.GSTReport);
			servivceNameforReportAPI = System.Label.GSTReport;
        } else if(serviceName.contains(System.Label.ITRStatus)) {
            apiConfiguration = IntegrationUtilities.getAPIConfiguration(System.Label.ITRReport);
			servivceNameforReportAPI = System.Label.ITRReport;
        } else {
            apiConfiguration = IntegrationUtilities.getAPIConfiguration(System.Label.Perfios_BS_Report);
			servivceNameforReportAPI = System.Label.Perfios_BS_Report;
        }
        
        Integer timeout = Integer.valueOf(apiConfiguration.Timeout__c);
        Security_Setting__mdt metadataApi = Security_Setting__mdt.getInstance(System.Label.IBMMasterKey);
        
        
        if(!apiConfiguration.IsActive_Integration__c){
            throw new IND_Exception(System.Label.ServiceDown);
        }
		String loanAppId;
        String requestBody;
        String encryptedRequest;
        String elapseTime;
        try{
            
            String methodType = apiConfiguration.Rest_Method__c.trim();
            String endpoint ='callout:Indus_API'+apiConfiguration.Endpoint_URL__c.trim();
            Long startTime = DateTime.now().getTime();
			Income_Details__c income = [SELECT Id, Applicant__r.Opportunity__c, Capture_ITR_Method__c, Capture_GST_Method__c, Is_Self_Employed__c, Is_Salaried__c, Income_from_Perfios__c FROM Income_Details__c WHERE Id=:targetObjId WITH SECURITY_ENFORCED];
            Opportunity opty = [SELECT Id, Lead_number__c FROM Opportunity WHERE Id=: income.Applicant__r.Opportunity__c WITH SECURITY_ENFORCED];
            ParentAPIRequest req;
            loanAppId = opty.Id;
            
            if(serviceName.contains('GST')){
               req = new IND_PerfiosGSTReportRequest(income, opty, perfiosId, System.Label.ReportFormat_JSON); 
            } else if(serviceName.contains('ITR')) {
               req = new IND_PerfiosITRReportRequest(income, opty, perfiosId, System.Label.ReportFormat_JSON); 
            } else {
               req = new IND_PerfiosBSReportRequest(income, perfiosId, clientTxnId, System.Label.ReportFormat_JSON); 
            }
            
			requestBody = req.convertToJSON();
            system.debug('perfiosReportAPI Original Request -- '+requestBody);
			encryptedRequest = IntegrationUtilities.getEncryptedRequest(requestBody, System.Label.privateKey, System.Label.ivkey);  
            String JdataRequest = '"JData":';                    
            encryptedRequest ='{'+JdataRequest + '"'+encryptedRequest+'"'+'}';
			
            HttpRequest httpRequest = new HttpRequest();
            httpRequest.setMethod(methodType);
            httpRequest.setEndpoint(endpoint);
            httpRequest.setHeader(IntegrationConstants.CONTENT_TYPE , IntegrationConstants.CONTENT_TYPE_JSON);
            httpRequest.setHeader('IBL-Client-Id', metadataApi?.Client_Id__c);
        	httpRequest.setHeader('IBL-Client-Secret', metadataApi?.Client_Secret__c);
			httpRequest.setbody(encryptedRequest);
            
            Http http = new Http();
            HttpResponse response = http.send(httpRequest);
            
            system.debug('perfiosJsonReportAPI getBody -- '+response.getStatusCode());
            
            Long endTime = DateTime.now().getTime();
            elapseTime = String.valueOf((endTime - startTime)/1000);
            String responseBody= '';
            
            system.debug('response.getBody()= '+response.getBody());
            if(response != null && response.getStatusCode() == 200){
                responseBody = response.getBody();     
                responseBody = responseBody.substring(10, responseBody.length()-2);
                String decryptedResponse = IntegrationUtilities.getDecryptedResponse(responseBody,System.Label.privateKey,System.Label.ivkey);
                    
                system.debug('perfiosJsonReportAPI response 200 -- '+decryptedResponse);
                double avgSalary=0.0;
                if(servivceNameforReportAPI.contains(System.Label.Perfios_BS_Report) && income.Is_Salaried__c == true){
                    Map<String, object> serialzedJsonMap = (Map<String, object>)JSON.deserializeUntyped(decryptedResponse);
                    List<Object> ObjList = (List<Object>) serialzedJsonMap.get('SAL_Avg_Salary');
                    Map<String, Object> objMap = (Map<String, Object>) ObjList.get(0);
                    if(String.isNotBlank((String)objMap.get('avgSalary'))){
                        avgSalary = double.valueOf(objMap.get('avgSalary'));
						if(avgSalary>0){
                            avgSalary = 12 * avgSalary;
                        }
                    }
                } else if(servivceNameforReportAPI.contains(System.Label.Perfios_BS_Report) && income.Is_Self_Employed__c == true){
                    Map<String, object> serialzedJsonMap = (Map<String, object>)JSON.deserializeUntyped(decryptedResponse);
                    Map<String, Object> ObjList =(Map<String, object>) serialzedJsonMap.get('SEP_Avg_Salary');
                    Map<String, Object> objMap = (Map<String, Object>) ObjList.get('summaryInfo');
                    if(String.isNotBlank((String)objMap.get('totalAvgBal'))){
                        avgSalary = double.valueOf(objMap.get('totalAvgBal'));
                    }
                    
                } else if(servivceNameforReportAPI.contains(System.Label.GSTReport)){
                    Map<String, object> serialzedJsonMap = (Map<String, object>)JSON.deserializeUntyped(decryptedResponse);
                    List<Object> ObjList = (List<Object>) serialzedJsonMap.get('customGstrTotalRevenueList');
                    
                    for(Object ob : ObjList){
                        Map<String, object> objNode = (Map<String, object>)ob;
                        string returnPeriod = (string)objNode.get('returnPeriod');
                        if(returnPeriod.contains('Average revenue for last 6 month')){
                            if(String.isNotBlank((String)objNode.get('revenue'))){
                                avgSalary = double.valueOf(objNode.get('revenue'));
                            }
                        }
                    }
                } else if(servivceNameforReportAPI.contains(System.Label.ITRReport)){
                    Map<String, object> serialzedJsonMap = (Map<String, object>)JSON.deserializeUntyped(decryptedResponse);
                    
                    ITRWrapper itrWrapper = (ITRWrapper)IntegrationUtilities.parseJSONResponse(decryptedResponse,'ITRWrapper');
                    
                    //code for form26AS
					ITRWrapper.Form26ASDetails form26Obj = itrWrapper?.form26ASDetails;
                    if(form26Obj != null && form26Obj.gstr3bTurnoverDetailsList[0]?.taxableTurnover != null){
                        avgSalary = double.valueOf(form26Obj.gstr3bTurnoverDetailsList[0]?.taxableTurnover);
                    }

                    //code for ITR
                     List<ITRWrapper.Itr> itrObjList = itrWrapper?.itr;
                    if(itrObjList != null && !itrObjList.isEmpty()){
                        for (integer i=0;i<itrObjList.size();i++){
                            if(itrObjList[i]?.totalIncome != null){
                                avgSalary = avgSalary + double.valueOf(itrObjList[i]?.totalIncome);
                            }
                        }
                    }

                    //code for ITRV
                     List<ITRWrapper.Itrv> itrvObjList = itrWrapper?.itrv;
                    if(itrvObjList != null && !itrvObjList.isEmpty()){
                        for (integer i=0;i<itrvObjList.size();i++){
                            if(itrvObjList[i]?.totalIncome != null){
                                avgSalary = avgSalary + double.valueOf(itrvObjList[i]?.totalIncome);
                            }
                        }
                    }
                }
                
                income.Income_from_Perfios__c = Decimal.valueOf(avgSalary).setScale(2);
                update income;
            } 
            IntegrationUtilities.createIntegrationLogger(requestBody, encryptedRequest, IntegrationUtilities.getPlainTextForLog(response.getBody()), response.getBody(), servivceNameforReportAPI, elapseTime, loanAppId, System.Label.Success);
            
        } catch(Exception ex){
            IntegrationUtilities.createIntegrationLogger(requestBody, encryptedRequest, '', '', servivceNameforReportAPI, elapseTime, loanAppId, System.Label.Failure);
            ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'perfiosJsonReportAPI', System.Label.Apex, ex,loanAppId);
            throw new IND_Exception(ex.getMessage());
        }
    }
	
	   /*
* @Method:      doScanUploadRetrieveReport
* @Created by:  Aman Mundhada
* @Description: IND_ScanUploadRetrieveReport API
* @Param:       String,String,String,String
*/
    @future (callout=true)
    public static void doScanUploadJsonRetrieveReport(String targetObjId, String perfiosId, String serviceName, String clientTxnId){
        String apiResponse = '';
        String responseBody = '';
        String loanAppId;
        String loanApplicationRef;
        String elapseTime;
        HttpRequest request;
        try{
           
            //Provide API-wise Integration Name to Custom Metadata Configs
            Integration_Configuration__mdt apiConfiguration = IntegrationUtilities.getAPIConfiguration(System.Label.ScanUploadRetrieveReport);
            Integer timeout = Integer.valueOf(apiConfiguration.Timeout__c);         
			Income_Details__c income = [SELECT Id, Applicant__r.Opportunity__c, Capture_ITR_Method__c, Capture_GST_Method__c, Is_Self_Employed__c, Is_Salaried__c, Income_from_Perfios__c, primary_income_source__c FROM Income_Details__c WHERE Id=:targetObjId WITH SECURITY_ENFORCED];
            Opportunity opty = [SELECT Id, Lead_number__c, Sanction_Status__c, STP_Failure_Reasons__c FROM Opportunity WHERE Id=: income.Applicant__r.Opportunity__c WITH SECURITY_ENFORCED];
            loanAppId = opty.Id;          

            if(perfiosId==null || String.isBlank(perfiosId)){
                throw new IND_Exception(System.Label.PerfiosTransactionIdError);
            }
            IND_ScanUploadRetrieveReportRequest scanUploadRetrieveReportRequest = IND_ScanUploadRetrieveReportService.getScanUploadRetrieveReportRequest();
            CalloutProcessor processor= new CalloutProcessor(System.Label.ScanUploadRetrieveReport, scanUploadRetrieveReportRequest);
            request = processor.createHttpRequest();
            request.setEndpoint(request.getEndpoint()+perfiosId+'&&reportFormat=json');
            request.setTimeout(12000);
            Long startTime = DateTime.now().getTime();  
            Http http = new Http();
            HttpResponse response = http.send(request);
            
            Long endTime = DateTime.now().getTime();
            elapseTime = String.valueOf((Double)(endTime - startTime)/1000);

            if(response != null && response.getStatusCode() == 200){
                responseBody = response.getBody();                        
                responseBody = responseBody.substring(10, responseBody.length()-2);                        
                String decryptedResponse = IntegrationUtilities.getDecryptedResponse(responseBody,System.Label.privateKey,System.Label.ivkey);
                double avgSalary=0.0;
                if(income.Is_Salaried__c == true){
                    Map<String, object> serialzedJsonMap = (Map<String, object>)JSON.deserializeUntyped(decryptedResponse);
                    List<Object> ObjList = (List<Object>) serialzedJsonMap.get('SAL_Avg_Salary');
                    Map<String, Object> objMap = (Map<String, Object>) ObjList.get(0);
                    if(String.isNotBlank((String)objMap.get('avgSalary'))){
                        avgSalary = double.valueOf(objMap.get('avgSalary'));
                        if(avgSalary>0){
                            avgSalary = 12 * avgSalary;
                        }
                    }
                } else if( income.Is_Self_Employed__c == true){
                    Map<String, object> serialzedJsonMap = (Map<String, object>)JSON.deserializeUntyped(decryptedResponse);
                    Map<String, Object> ObjList =(Map<String, object>) serialzedJsonMap.get('SEP_Avg_Salary');
                    Map<String, Object> objMap = (Map<String, Object>) ObjList.get('summaryInfo');
                    if(String.isNotBlank((String)objMap.get('totalAvgBal'))){
                        avgSalary = double.valueOf(objMap.get('totalAvgBal'));
                    }
                    
                }
                
                income.Income_from_Perfios__c = Decimal.valueOf(avgSalary).setScale(2);
                update income;
				
				 // STP Logic : IND-3996
                if(avgSalary<=0 && income.primary_income_source__c){
                    opty.Sanction_Status__c = 'Non-STP';
                    opty.STP_Failure_Reasons__c = 'Perfios output NOT available';
                    update opty; 
                }
               IntegrationUtilities.createIntegrationLogger(request.getBody(), IntegrationUtilities.getPlainTextForLog(request.getBody()), IntegrationUtilities.getPlainTextForLog(response.getBody()), response.getBody(), System.Label.ScanUploadRetrieveReport, elapseTime,loanAppId,System.Label.Success);
                  
             }    
 
        } catch(Exception ex) {
            IntegrationUtilities.createIntegrationLogger(request.getBody(), IntegrationUtilities.getPlainTextForLog(request.getBody()), '', '', System.Label.ScanUploadRetrieveReport, elapseTime,loanAppId, System.Label.Failure);
            ErrorLoggerUtil.logErrorEvent('UpdateTargetAPIObjectHelper', 'doScanUploadJsonRetrieveReport', System.Label.Apex, ex,loanAppId);
            throw new IND_Exception(ex.getMessage());
        }
    }
    
     /*
* @Method:      doScanUploadXlsxRetrieveReport
* @Created by:  Aman Mundhada
* @Description: Continuation for IND_ScanUploadRetrieveReport API
* @Param:       String,String,String,String
*/
    @future(callout=true)
    public static void doScanUploadXlsxRetrieveReport(String targetObjId, String perfiosId, String serviceName, String clientTxnId){
        String apiResponse = '';
        String responseBody = '';
        String loanAppId;
        String loanApplicationRef;
        String elapseTime;
        HttpRequest request;
        try{
           
            //Provide API-wise Integration Name to Custom Metadata Configs
            Integration_Configuration__mdt apiConfiguration = IntegrationUtilities.getAPIConfiguration(System.Label.ScanUploadRetrieveReport);
            Integer timeout = Integer.valueOf(apiConfiguration.Timeout__c);           
			Income_Details__c app = [SELECT Id, Applicant__r.Opportunity__c, Capture_ITR_Method__c, Capture_GST_Method__c FROM Income_Details__c WHERE Id=:targetObjId WITH SECURITY_ENFORCED];
            Opportunity opty = [SELECT Id, Lead_number__c FROM Opportunity WHERE Id=: app.Applicant__r.Opportunity__c WITH SECURITY_ENFORCED];
            loanAppId = opty.Id;
            if(perfiosId==null || String.isBlank(perfiosId)){
                throw new IND_Exception(System.Label.PerfiosTransactionIdError);
            }
            IND_ScanUploadRetrieveReportRequest scanUploadRetrieveReportRequest = IND_ScanUploadRetrieveReportService.getScanUploadRetrieveReportRequest();
            CalloutProcessor processor= new CalloutProcessor(System.Label.ScanUploadRetrieveReport, scanUploadRetrieveReportRequest);
            request = processor.createHttpRequest();
            request.setEndpoint(request.getEndpoint()+perfiosId+'&&reportFormat=xlsx');
            request.setTimeout(12000);
            Long startTime = DateTime.now().getTime();  
            Http http = new Http();
            HttpResponse response = http.send(request);
            
            Long endTime = DateTime.now().getTime();
            elapseTime = String.valueOf((Double)(endTime - startTime)/1000);

                if(response != null && response.getStatusCode() == 200){
                    system.debug('perfiosReportAPI response 200 -- ');
                
                    ContentVersion conVer = new ContentVersion();
                    conVer.ContentLocation = 'S';
                    conVer.PathOnClient = perfiosId + '.xlsx';
                    conVer.Title = 'Perfios Report - '+perfiosId;
                    conVer.VersionData = response.getBodyAsBlob();
                    insert conVer; 
                    
                    Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:conVer.Id].ContentDocumentId;
                    
                    ContentDocumentLink conDocLink = New ContentDocumentLink();
                    conDocLink.LinkedEntityId = targetObjId;
                    conDocLink.ContentDocumentId = conDoc;
                    conDocLink.shareType = 'V';
                    insert conDocLink;
                    IntegrationUtilities.createIntegrationLogger(perfiosId, '', '', '', serviceName, elapseTime, loanAppId, System.Label.Success);
                }         
 
        } catch(Exception ex) {
            IntegrationUtilities.createIntegrationLogger(request.getBody(), IntegrationUtilities.getPlainTextForLog(request.getBody()), '', '', System.Label.ScanUploadRetrieveReport, elapseTime,loanAppId, System.Label.Failure);
            ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'doScanUploadXlsxRetrieveReport', System.Label.Apex, ex,loanAppId);
            throw ex;
        }
    }
    
    /*
* @Method:      doITRScanUploadJsonRetrieveReport
* @Created by:  Aman Mundhada
* @Description: IND_ITRScanUploadRetrieveReport API
* @Param:       String,String,String,String
*/
    @future(callout=true)
    public static void doITRScanUploadJsonRetrieveReport(String targetObjId, String perfiosId, String serviceName, String clientTxnId){
        String apiResponse = '';
        String responseBody = '';
        String loanAppId;
        String loanApplicationRef;
        String elapseTime;
        HttpRequest request;
        try{
           
            //Provide API-wise Integration Name to Custom Metadata Configs
            Integration_Configuration__mdt apiConfiguration = IntegrationUtilities.getAPIConfiguration(System.Label.ITR_Scan_upload_retrieve_report);
            Integer timeout = Integer.valueOf(apiConfiguration.Timeout__c);           
            Income_Details__c income = [SELECT Id, Applicant__r.Opportunity__c, Capture_ITR_Method__c, Capture_GST_Method__c, Is_Self_Employed__c, Is_Salaried__c, Income_from_Perfios__c, primary_income_source__c FROM Income_Details__c WHERE Id=:targetObjId WITH SECURITY_ENFORCED];
            Opportunity opty = [SELECT Id, Lead_number__c, Sanction_Status__c, STP_Failure_Reasons__c FROM Opportunity WHERE Id=: income.Applicant__r.Opportunity__c WITH SECURITY_ENFORCED];
            loanAppId = opty.Id;   
            if(perfiosId==null || String.isBlank(perfiosId)){
                throw new IND_Exception(System.Label.PerfiosTransactionIdError);
            }
            IND_ITRScanUploadRetrieveReportRequest scanUploadRetrieveReportRequest = IND_ITRScanUploadRetrieveReportService.getITRScanUploadRetrieveReportRequest();
            CalloutProcessor processor= new CalloutProcessor(System.Label.ITR_Scan_upload_retrieve_report, scanUploadRetrieveReportRequest);
            request = processor.createHttpRequest();
            request.setEndpoint(request.getEndpoint()+perfiosId+'&&reportType=json');
            request.setTimeout(timeout);
            Long startTime = DateTime.now().getTime();  
            Http http = new Http();
            HttpResponse response = http.send(request);
            
            Long endTime = DateTime.now().getTime();
            elapseTime = String.valueOf((Double)(endTime - startTime)/1000);


            if(response != null && response.getStatusCode() == 200){
                responseBody = response.getBody();                        
                responseBody = responseBody.substring(10, responseBody.length()-2);                        
                String decryptedResponse = IntegrationUtilities.getDecryptedResponse(responseBody,System.Label.privateKey,System.Label.ivkey);

 					double avgSalary=0.0;
 					Map<String, object> serialzedJsonMap = (Map<String, object>)JSON.deserializeUntyped(decryptedResponse);
                    
                    ITRWrapper itrWrapper = (ITRWrapper)IntegrationUtilities.parseJSONResponse(decryptedResponse,'ITRWrapper');
                    
                    //code for form26AS
					ITRWrapper.Form26ASDetails form26Obj = itrWrapper?.form26ASDetails;
                    if(form26Obj != null && form26Obj.gstr3bTurnoverDetailsList[0]?.taxableTurnover != null){
                        avgSalary = double.valueOf(form26Obj.gstr3bTurnoverDetailsList[0]?.taxableTurnover);
                    }

                    //code for ITR
                    List<ITRWrapper.Itr> itrObjList = itrWrapper?.itr;
                    if(itrObjList != null && !itrObjList.isEmpty()){
                        for (integer i=0;i<itrObjList.size();i++){
                            if(itrObjList[i]?.totalIncome != null){
                                avgSalary = avgSalary + double.valueOf(itrObjList[i]?.totalIncome);
                            }
                        }
                    }

                    //code for ITRV
                    List<ITRWrapper.Itrv> itrvObjList = itrWrapper?.itrv;
                    if(itrvObjList != null && !itrvObjList.isEmpty()){
                        for (integer i=0;i<itrvObjList.size();i++){
                            if(itrvObjList[i]?.totalIncome != null){
                                avgSalary = avgSalary + double.valueOf(itrvObjList[i]?.totalIncome);
                            }
                        }
                    }
                income.Income_from_Perfios__c = avgSalary;
                update income;
				
				// STP Logic : IND-3996
                if(avgSalary<=0 && income.primary_income_source__c){
                    opty.Sanction_Status__c = 'Non-STP';
                    opty.STP_Failure_Reasons__c = 'Perfios output NOT available';
                    update opty; 
                }
				
               IntegrationUtilities.createIntegrationLogger(request.getBody(), IntegrationUtilities.getPlainTextForLog(request.getBody()), IntegrationUtilities.getPlainTextForLog(response.getBody()), response.getBody(), serviceName, elapseTime,loanAppId,System.Label.Success);
            }                 
    }
       catch(Exception ex) {
            IntegrationUtilities.createIntegrationLogger(request.getBody(), IntegrationUtilities.getPlainTextForLog(request.getBody()), '', '', serviceName, elapseTime,loanAppId, System.Label.Failure);
            ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'doITRScanUploadRetrieveReport', System.Label.Apex, ex,loanAppId);
            throw new IND_Exception(ex.getMessage());
        }
    }
    
     /*
* @Method:      doITRScanUploadXlsxRetrieveReport
* @Created by:  Aman Mundhada
* @Description: Continuation for IND_ScanUploadITRRetrieveReport API
* @Param:       String,String,String,String
*/
    @future(callout=true)
    public static void doITRScanUploadXlsxRetrieveReport(String targetObjId, String perfiosId, String serviceName, String clientTxnId){
        String apiResponse = '';
        String responseBody = '';
        String loanAppId;
        String loanApplicationRef;
        String elapseTime;
        HttpRequest request;
        try{

            //Provide API-wise Integration Name to Custom Metadata Configs
            Integration_Configuration__mdt apiConfiguration = IntegrationUtilities.getAPIConfiguration(System.Label.ITR_Scan_upload_retrieve_report);
            Integer timeout = Integer.valueOf(apiConfiguration.Timeout__c);           
            Income_Details__c income = [SELECT Id, Applicant__r.Opportunity__c, Capture_ITR_Method__c, Capture_GST_Method__c, Is_Self_Employed__c, Is_Salaried__c, Income_from_Perfios__c FROM Income_Details__c WHERE Id=:targetObjId WITH SECURITY_ENFORCED];
            Opportunity opty = [SELECT Id, Lead_number__c FROM Opportunity WHERE Id=: income.Applicant__r.Opportunity__c WITH SECURITY_ENFORCED];
            loanAppId = opty.Id;  
            if(perfiosId==null || String.isBlank(perfiosId)){
                throw new IND_Exception(System.Label.PerfiosTransactionIdError);
            }
            IND_ITRScanUploadRetrieveReportRequest scanUploadRetrieveReportRequest = IND_ITRScanUploadRetrieveReportService.getITRScanUploadRetrieveReportRequest();
            CalloutProcessor processor= new CalloutProcessor(System.Label.ITR_Scan_upload_retrieve_report, scanUploadRetrieveReportRequest);
            request = processor.createHttpRequest();
            request.setEndpoint(request.getEndpoint()+perfiosId+'&&reportType=xlsx');
            request.setTimeout(timeout);
            Long startTime = DateTime.now().getTime();  
            Http http = new Http();
            HttpResponse response = http.send(request);
            
            Long endTime = DateTime.now().getTime();
            elapseTime = String.valueOf((Double)(endTime - startTime)/1000);

                if(response != null && response.getStatusCode() == 200){
                    system.debug('perfiosReportAPI response 200 -- ');
                
                    ContentVersion conVer = new ContentVersion();
                    conVer.ContentLocation = 'S';
                    conVer.PathOnClient = perfiosId + '.xlsx';
                    conVer.Title = 'Perfios Report - '+perfiosId;
                    conVer.VersionData = response.getBodyAsBlob();
                    insert conVer; 
                    
                    Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:conVer.Id].ContentDocumentId;
                    
                    ContentDocumentLink conDocLink = New ContentDocumentLink();
                    conDocLink.LinkedEntityId = targetObjId; 
                    conDocLink.ContentDocumentId = conDoc;
                    conDocLink.shareType = 'V';
                    insert conDocLink;
                } 
        } catch(Exception ex) {
            IntegrationUtilities.createIntegrationLogger(request.getBody(), IntegrationUtilities.getPlainTextForLog(request.getBody()), '', '', serviceName, elapseTime,loanAppId, System.Label.Failure);
            ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'doITRScanUploadXlsxRetrieveReport', System.Label.Apex, ex,loanAppId);
            throw ex;
        }
    }

}