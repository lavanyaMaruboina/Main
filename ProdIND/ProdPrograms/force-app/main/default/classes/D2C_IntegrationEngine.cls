public with sharing class D2C_IntegrationEngine {
	
    @AuraEnabled
    public static void doVehicleDedupeCallout(String loanId, String status){
        String apiResponse;
        String requestForIntegrationLog = '';
        String plainRequest = '';
        Long endTime;
        Long startTime;
        String elapseTime = '';
        String serviceName = System.Label.D2CVehicleDedupe;
        try {
            //Provide API-wise Integration Name to Custom Metadata Configs
            Integration_Configuration__mdt apiConfiguration = IntegrationUtilities.getAPIConfiguration(System.Label.D2CVehicleDedupe);
            Integer timeout = Integer.valueOf(apiConfiguration.Timeout__c);
			RequestWrapper req= new RequestWrapper();
            system.Debug('apiConfiguration'+apiConfiguration);
            //Modified by Rohan for new DSA API
            IND_D2CVehicleDedupeRequest VehicleDedupeRequestDetails = IND_D2CVehicleDedupeService.getVehicleDedupe(loanId, status);
            CalloutProcessor process = new CalloutProcessor(System.Label.D2CVehicleDedupe, VehicleDedupeRequestDetails);
            HttpRequest request = process.createHttpRequest();
            request.setTimeout(60000);
            requestForIntegrationLog = request.getBody();
            plainRequest = IBMEncryption.getPlainTextForLog(request.getBody());
            Http http = new Http();
            startTime = DateTime.now().getTime();
            HttpResponse response = http.send(request);
            endTime = DateTime.now().getTime();
            elapseTime = String.valueOf((Double)(endTime - startTime)/1000);
            System.debug('Debugg - '+response.getStatusCode());
            if(response != null && (response.getStatusCode() == 200 || response.getStatusCode() == 500)){
                apiResponse = IBMEncryption.getPlainTextForLog(response.getBody());
                if(apiResponse!=null){
                    IntegrationUtilities.createIntegrationLogger(plainRequest, request.getBody(), apiResponse, response.getBody(), serviceName, elapseTime,loanId,System.Label.Success);
                    
                } else {
                    IntegrationUtilities.createIntegrationLogger(plainRequest, request.getBody(), apiResponse, response.getBody(), serviceName, elapseTime,loanId,System.Label.Failure);
                    throw new IND_Exception(System.Label.NoResponse);                
                }
            }
            else {
                String errString = '[Status Code = '+ response.getStatusCode() +' ] Response-->'+IBMEncryption.getPlainTextForLog(response.getBody());
                ErrorLoggerUtil.logErrorEvent('HTTP Callout', 'getHttpResponse', System.Label.Apex, new IND_Exception(errString), loanId);
                IntegrationUtilities.createIntegrationLogger(IBMEncryption.getPlainTextForLog(request.getBody()), request.getBody(), errString, response.getBody(), serviceName, elapseTime, loanId, System.Label.Failure);
                throw new IND_Exception(System.Label.NoResponse);
            }
            
        } catch (Exception ex) {
            ErrorLoggerUtil.logErrorEvent('D2CIntegrationEngine', 'doVehicleDedupeCallout', System.Label.Apex, ex, loanId);
            throw ex;
        }
    }
    
    @AuraEnabled
    public static void doSanctionCommunicationCallout(String loanAppId){
        String apiResponse;
        String requestForIntegrationLog = '';
        String plainRequest = '';
        Long endTime;
        Long startTime;
        String elapseTime = '';
        String serviceName = System.Label.D2CSanction;
        try{
            //Provide API-wise Integration Name to Custom Metadata Configs
            Integration_Configuration__mdt apiConfiguration = IntegrationUtilities.getAPIConfiguration(System.Label.D2CSanction);
            //if stubs checked in Integration_Configuration then stubs will return
            if(apiConfiguration.IsStub_Required__c != null && apiConfiguration.IsStub_Required__c){
                String stubData = IntegrationUtilities.getStubResponse(System.Label.D2CSanction);
                stubData = stubData == null ? System.Label.EmptyStubs : stubData;
            }
          
            IND_D2CSanctionRequest sanctionRequest = IND_D2CSanctionService.getSanctionRequest(loanAppId);
            CalloutProcessor processor= new CalloutProcessor(System.Label.D2CSanction, sanctionRequest);
            HttpRequest request = processor.createHttpRequest();
            request.setTimeout(60000);
            requestForIntegrationLog = request.getBody();
            plainRequest = IBMEncryption.getPlainTextForLog(request.getBody());
            Http http = new Http();
            startTime = DateTime.now().getTime();
            HttpResponse response = http.send(request);
            endTime = DateTime.now().getTime();
            elapseTime = String.valueOf((Double)(endTime - startTime)/1000);
            System.debug('Sacntion Response -- '+response);
            if(response != null && (response.getStatusCode() == 200 || response.getStatusCode() == 500)){
                apiResponse = IBMEncryption.getPlainTextForLog(response.getBody());
                if(apiResponse!=null){
                    IntegrationUtilities.createIntegrationLogger(plainRequest, request.getBody(), apiResponse, response.getBody(), serviceName, elapseTime,loanAppId,System.Label.Success);
                    
                } else {
                    IntegrationUtilities.createIntegrationLogger(plainRequest, request.getBody(), apiResponse, response.getBody(), serviceName, elapseTime,loanAppId,System.Label.Failure);
                    throw new IND_Exception(System.Label.NoResponse);                
                }
            }
            else {
                String errString = '[Status Code = '+ response.getStatusCode() +' ] Response-->'+IBMEncryption.getPlainTextForLog(response.getBody());
                ErrorLoggerUtil.logErrorEvent('HTTP Callout', 'getHttpResponse', System.Label.Apex, new IND_Exception(errString), loanAppId);
                IntegrationUtilities.createIntegrationLogger(IBMEncryption.getPlainTextForLog(request.getBody()), request.getBody(), errString, response.getBody(), serviceName, elapseTime, loanAppId, System.Label.Failure);
                throw new IND_Exception(System.Label.NoResponse);
            }
        } catch(Exception ex){
            ErrorLoggerUtil.logErrorEvent('D2C_IntegrationEngine', 'execute', System.Label.Apex, ex,loanAppId);
            throw ex;
        }
    }

    @AuraEnabled
    public static void doDisbursedCommunicationCallout(String loanAppId){
        String apiResponse;
        String requestForIntegrationLog = '';
        String plainRequest = '';
        Long endTime;
        Long startTime;
        String elapseTime = '';
        String serviceName = System.Label.D2CDisbursement;
        try{
            //Provide API-wise Integration Name to Custom Metadata Configs
            Integration_Configuration__mdt apiConfiguration = IntegrationUtilities.getAPIConfiguration(System.Label.D2CDisbursement);
            //if stubs checked in Integration_Configuration then stubs will return
            if(apiConfiguration.IsStub_Required__c != null && apiConfiguration.IsStub_Required__c){
                String stubData = IntegrationUtilities.getStubResponse(System.Label.D2CDisbursement);
                stubData = stubData == null ? System.Label.EmptyStubs : stubData;
            }
          
            IND_D2CDisbursementRequest disbursedRequest = IND_D2CDisbursementService.getDisbursementRequest(loanAppId);
            CalloutProcessor processor= new CalloutProcessor(System.Label.D2CDisbursement, disbursedRequest);
            HttpRequest request = processor.createHttpRequest();
            request.setTimeout(60000);
            requestForIntegrationLog = request.getBody();
            plainRequest = IBMEncryption.getPlainTextForLog(request.getBody());
            Http http = new Http();
            startTime = DateTime.now().getTime();
            HttpResponse response = http.send(request);
            endTime = DateTime.now().getTime();
            elapseTime = String.valueOf((Double)(endTime - startTime)/1000);
            System.debug('Sacntion Response -- '+response);
            if(response != null && (response.getStatusCode() == 200 || response.getStatusCode() == 500)){
                apiResponse = IBMEncryption.getPlainTextForLog(response.getBody());
                if(apiResponse!=null){
                    IntegrationUtilities.createIntegrationLogger(plainRequest, request.getBody(), apiResponse, response.getBody(), serviceName, elapseTime,loanAppId,System.Label.Success);
                    
                } else {
                    IntegrationUtilities.createIntegrationLogger(plainRequest, request.getBody(), apiResponse, response.getBody(), serviceName, elapseTime,loanAppId,System.Label.Failure);
                    throw new IND_Exception(System.Label.NoResponse);                
                }
            }
            else {
                String errString = '[Status Code = '+ response.getStatusCode() +' ] Response-->'+IBMEncryption.getPlainTextForLog(response.getBody());
                ErrorLoggerUtil.logErrorEvent('HTTP Callout', 'getHttpResponse', System.Label.Apex, new IND_Exception(errString), loanAppId);
                IntegrationUtilities.createIntegrationLogger(IBMEncryption.getPlainTextForLog(request.getBody()), request.getBody(), errString, response.getBody(), serviceName, elapseTime, loanAppId, System.Label.Failure);
                throw new IND_Exception(System.Label.NoResponse);
            }
        } catch(Exception ex){
            ErrorLoggerUtil.logErrorEvent('D2C_IntegrationEngine', 'execute', System.Label.Apex, ex,loanAppId);
            throw ex;
        }
    }

    @AuraEnabled
    public static void doVehicleValuationCallout(String loanAppId, String screen){
        String apiResponse;
        String requestForIntegrationLog = '';
        String plainRequest = '';
        Long endTime;
        Long startTime;
        String elapseTime = '';
        String serviceName = System.Label.D2CVehicleValuation;
        try{
            Date currentDate =Date.today();
            Date dateAfterSixtyDays = currentDate.addDays(60);
            Opportunity oppObj=[ SELECT Id,Lead_number__c,Product_Type__c, Vehicle_Type__c,Vehicle_Sub_Category__c, Parent_Deal_number__c,Vehicle_Registration_Number__c, StageName, LastStageName__c                                 
                                FROM Opportunity WHERE Id =: loanAppId WITH SECURITY_ENFORCED limit 1];
            
            List<Vehicle_Detail__c> vehicleRecord = [ SELECT Id,Insurer_name__c,Insurance_number__c,Insurance_type__c, Insurance_declared_value__c,Ins_Issuance_date__c,Ins_Expiry_date__c, Insurance_expiring_within_60_days__c
                                                    FROM Vehicle_Detail__c WHERE Loan_Application__c=:loanAppId WITH SECURITY_ENFORCED limit 1];
            if(vehicleRecord!= null && !vehicleRecord.isEmpty()) {
                //Check Expiry date is within 60 days
                Date expiryDate = Date.valueOf(vehicleRecord[0].Ins_Expiry_date__c);
                if(vehicleRecord[0].Insurance_expiring_within_60_days__c == true && screen != 'insurance') {
                    return;
                }

            }    
            //Provide API-wise Integration Name to Custom Metadata Configs
            Integration_Configuration__mdt apiConfiguration = IntegrationUtilities.getAPIConfiguration(System.Label.D2CVehicleValuation);
            //if stubs checked in Integration_Configuration then stubs will return
            if(apiConfiguration.IsStub_Required__c != null && apiConfiguration.IsStub_Required__c){
                String stubData = IntegrationUtilities.getStubResponse(System.Label.D2CVehicleValuation);
                stubData = stubData == null ? System.Label.EmptyStubs : stubData;
            }
          
            IND_D2CVehicleValuationRequst valuationRequest = IND_D2CVehicleValuationService.getValuationRequest(loanAppId);
            CalloutProcessor processor= new CalloutProcessor(System.Label.D2CVehicleValuation, valuationRequest);
            HttpRequest request = processor.createHttpRequest();
            request.setTimeout(60000);
            requestForIntegrationLog = request.getBody();
            plainRequest = IBMEncryption.getPlainTextForLog(request.getBody());
            Http http = new Http();
            startTime = DateTime.now().getTime();
            HttpResponse response = http.send(request);
            endTime = DateTime.now().getTime();
            elapseTime = String.valueOf((Double)(endTime - startTime)/1000);
            System.debug('Sacntion Response -- '+response);
            if(response != null && (response.getStatusCode() == 200 || response.getStatusCode() == 500)){
                apiResponse = IBMEncryption.getPlainTextForLog(response.getBody());
                if(apiResponse!=null){
                    IntegrationUtilities.createIntegrationLogger(plainRequest, request.getBody(), apiResponse, response.getBody(), serviceName, elapseTime,loanAppId,System.Label.Success);
                    
                } else {
                    IntegrationUtilities.createIntegrationLogger(plainRequest, request.getBody(), apiResponse, response.getBody(), serviceName, elapseTime,loanAppId,System.Label.Failure);
                    throw new IND_Exception(System.Label.NoResponse);                
                }
            }
            else {
                String errString = '[Status Code = '+ response.getStatusCode() +' ] Response-->'+IBMEncryption.getPlainTextForLog(response.getBody());
                ErrorLoggerUtil.logErrorEvent('HTTP Callout', 'getHttpResponse', System.Label.Apex, new IND_Exception(errString), loanAppId);
                IntegrationUtilities.createIntegrationLogger(IBMEncryption.getPlainTextForLog(request.getBody()), request.getBody(), errString, response.getBody(), serviceName, elapseTime, loanAppId, System.Label.Failure);
                throw new IND_Exception(System.Label.NoResponse);
            }
        } catch(Exception ex){
            ErrorLoggerUtil.logErrorEvent('D2C_IntegrationEngine', 'execute', System.Label.Apex, ex,loanAppId);
            throw ex;
        }
    }


    @AuraEnabled
    public static String doVKCDocumentDownload(String loanId){
        String serviceName = 'VKYC Document Download';
        Integration_Configuration__mdt apiConfiguration = IntegrationUtilities.getAPIConfiguration(serviceName);
        Integer timeout = Integer.valueOf(apiConfiguration.Timeout__c);
        HttpResponse response;
        List<VKYCResponses> responses = new List<VKYCResponses>();
        String elapseTime;
        Boolean retryExhausted = checkRetryExhausted(loanId);
        
        if(!apiConfiguration.IsActive_Integration__c){
            throw new IND_Exception(System.Label.ServiceDown);
        }
        try{
            Opportunity loanApplication = [SELECT Id, VKYC_Doc_Urls__c, VKYC_Doc_Downloaded__c FROM Opportunity WHERE Id =: loanId];
            if(loanApplication.VKYC_Doc_Downloaded__c==true){
                return 'downloaded';
            }
            if(String.isBlank(loanApplication.VKYC_Doc_Urls__c)){
                return 'urlMissing';
            }
            if(retryExhausted){
                return 'retryExhausted';
            }
            Applicant__c applicant = [SELECT Id FROM Applicant__c WHERE Opportunity__c =: loanId];
            VKYCDocumentsWrapper urls = (VKYCDocumentsWrapper)JSON.deserialize(loanApplication.VKYC_Doc_Urls__c, VKYCDocumentsWrapper.class);
            if(String.isNotBlank(urls.aadhar_photo)){
                docCallout('Aadhaar', urls.aadhar_photo, apiConfiguration, responses);
            }
            if(String.isNotBlank(urls.customer_image)){
                docCallout('Customer Image', urls.customer_image, apiConfiguration, responses);
            }
            if(String.isNotBlank(urls.customer_signature)){
                docCallout('Signature', urls.customer_signature, apiConfiguration, responses);
            }
            if(String.isNotBlank(urls.pan_card)){
                docCallout('PAN', urls.pan_card, apiConfiguration, responses);
            }
            if(!responses.isEmpty()){
                for(VKYCResponses resp : responses){
                    processVKYCResponse(resp.response, loanId, resp.docType, applicant.Id);
                }
            }
            loanApplication.VKYC_Doc_Downloaded__c = true;
            update loanApplication;
            retryCountIncrease(loanId);
            return 'success';
            
        } catch(Exception ex){
            if(response != null){
                IntegrationUtilities.createIntegrationLogger('', '', String.join(response.getHeaderKeys(),'||')+'\n'+response.getStatusCode()+'::'+response.getBody(), '', serviceName, elapseTime);
            }
            ErrorLoggerUtil.logErrorEvent('D2C_IntegrationEngine', 'doVKCDocumentDownload', System.Label.Apex, ex,'');
            throw new IND_Exception(ex.getMessage());
            
        }
    }

    public static void docCallout(String docType, String docId, Integration_Configuration__mdt apiConfiguration, List<VKYCResponses> responses){
        String serviceName = 'VKYC Document Download';
        String methodType = apiConfiguration.Rest_Method__c.trim();
        String endpoint = 'callout:VKYC'+apiConfiguration.Endpoint_URL__c.trim();
        endpoint = endpoint.replace('{docid}', docId.substringAfter('download/'));
        // 9a7f4c871ece42a9af73d35c92a825fe1667981201786
        Long startTime = DateTime.now().getTime();
        
        HttpRequest httpRequest = new HttpRequest();
        httpRequest.setMethod(methodType);
        httpRequest.setEndpoint(endpoint);
        httpRequest.setTimeout(Integer.valueOf(apiConfiguration.Timeout__c));
        
        Security_Setting__mdt metadataApi = Security_Setting__mdt.getInstance('VKYC'); 
        httpRequest.setHeader('apiKey', metadataApi.Private_Key__c);
        httpRequest.setHeader('Content-Type', 'application/json');
        httpRequest.setHeader('client-id', metadataApi.Client_Id__c);
        String timestamp = String.valueOf(System.currentTimeMillis());
        // httpRequest.setHeader('signature', 'U9t7zrUpO/27XUKBDbWykOLvKsKuQJe23GJo8KYyQGA=');//getSignature(metadataApi.Private_Key__c+':'+System.currentTimeMillis(), metadataApi.Client_Secret__c));
        // httpRequest.setHeader('timestamp', '1656915731953');//String.valueOf(System.currentTimeMillis()));
        httpRequest.setHeader('signature', getSignature(metadataApi.Private_Key__c+':'+timestamp, metadataApi.Client_Secret__c));
        httpRequest.setHeader('timestamp', timestamp);
        System.debug('signature'+getSignature(metadataApi.Private_Key__c+':'+System.currentTimeMillis(), metadataApi.Client_Secret__c));
        System.debug('timestamp'+String.valueOf(System.currentTimeMillis()));
        httpRequest.setHeader('x-request-id', String.valueOf(System.currentTimeMillis()));
        
        
        Http http = new Http();
        HttpResponse response = http.send(httpRequest);
        
        Long endTime = DateTime.now().getTime();
        String elapseTime = String.valueOf((Double)(endTime - startTime)/1000);
        
        String responseBody;
        if(response != null){
            VKYCResponses vResponse = new VKYCResponses();
            vResponse.response = response;
            vResponse.docType = docType;
            responses.add(vResponse);
            //processVKYCResponse(response, loanId);
            IntegrationUtilities.createIntegrationLogger('', '', response.getBody(), '', serviceName, elapseTime);
        }
        else {
            IntegrationUtilities.createIntegrationLogger('', '', '', '', '', elapseTime);
            throw new IND_Exception(System.Label.NoResponse);
        }
    }

    public static String getSignature(String data, String secret){
        Blob mac = Crypto.generateMac('hmacSHA256',Blob.valueOf(data),Blob.valueOf(secret));
        String signature = EncodingUtil.base64Encode(mac);
        return signature;
    }

    public static void processVKYCResponse(HttpResponse response, String linkedId, String docType, String applicantId){
        String contentDisposition = response.getHeader('Content-Disposition');
        String fileName = contentDisposition?.substring(contentDisposition.indexOf('"')+1, contentDisposition.lastIndexOf('"'));
        String contentType = response.getHeader('Content-Type');
        
        ContentVersion cv = new ContentVersion();
        cv.Title = fileName;
        cv.PathOnClient = fileName;
        cv.VersionData = response.getBodyAsBlob();
        cv.IsMajorVersion = true;
        if(Schema.SObjectType.ContentVersion.isCreateable()){
            insert cv;
        }

        //Get Content Documents
        Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;
        

        //Create Custom Document Record
        Documents__c doc = new Documents__c();
        if(docType == 'PAN'){
            doc = [SELECT Id FROM Documents__c WHERE Opportunity_Relation__c =:linkedId and Document_Type__c = 'PAN' LIMIT 1];
        }else if(docType == 'Customer Image'){
            doc = [SELECT Id FROM Documents__c WHERE Opportunity_Relation__c =:linkedId and (Name = 'Aadhaar' or Document_Type__c = 'Aadhaar') LIMIT 1];
        }else{
            Id recordTypeId = Schema.SObjectType.Documents__c.getRecordTypeInfosByName().get('Other Documents').getRecordTypeId();
            doc.Applicant__c = applicantId;
            doc.Opportunity_Relation__c = linkedId;
            doc.Document_Type__c = docType;
            doc.Name = 'V-KYC '+docType;
            doc.Is_Active__c = true;
            doc.RecordTypeId = recordTypeId;
            insert doc;
        }
        


        //Create ContentDocumentLink 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = doc.Id;
        cdl.ContentDocumentId = conDocId;
        cdl.shareType = 'V';
        if(Schema.SObjectType.ContentDocumentLink.isCreateable()){
            insert cdl;
        }
    }
    
    /*
    * @Method Name: checkRetryExhausted
    * @Created by:  Raman Raj Saxena
    * @description: To check whether it reached to retry limit.
    * @Param:       String - loanApplicationId
    */
    @AuraEnabled
    public static Boolean checkRetryExhausted(String loanApplicationId) {
        try {
        if (loanApplicationId != null) {
            List<Retry_Count__c> retryCountList = [SELECT Id, Count__c FROM Retry_Count__c WHERE Loan_Application_Id__c = :loanApplicationId AND Service_Name__c = :System.Label.VKYC AND User_Id__c =: UserInfo.getUserId() WITH SECURITY_ENFORCED];
            if (!retryCountList.isEmpty()) {
            System_Constant_custom_metadata__mdt metadata = System_Constant_custom_metadata__mdt.getInstance(System.Label.VKYC);
            if (retryCountList[0].Count__c >= metadata.Number_Of_Attempts__c) {
                return true;
            }
            }
        }
        return false;
        } catch (Exception e) {
        ErrorLoggerUtil.logErrorEvent('D2C_IntegrationEngine', 'checkRetryExhausted', System.Label.Apex, e);
        throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }
        /*
    * @Method Name: retryCountIncrease
    * @Created by:  Raman Raj Saxena
    * @description: To store retry count details.
    * @Param:       String - Loan Application Id
    */
    @AuraEnabled
    public static Boolean retryCountIncrease(String loanApplicationId) {
        try {
            if (loanApplicationId != null) {
                List<Opportunity> loanApplications = [SELECT Id, Name, StageName FROM Opportunity WHERE Id = :loanApplicationId WITH SECURITY_ENFORCED LIMIT 1];
                List<Retry_Count__c> retryCountList = [SELECT Id, Count__c FROM Retry_Count__c WHERE Loan_Application_Id__c = :loanApplicationId AND Service_Name__c = :System.Label.VKYC AND User_Id__c =: UserInfo.getUserId() LIMIT 1];
                if (!retryCountList.isEmpty()) {
                    System_Constant_custom_metadata__mdt metadata = System_Constant_custom_metadata__mdt.getInstance(System.Label.VKYC);
                    retryCountList[0].Count__c = retryCountList[0].Count__c == null ? 0 : retryCountList[0].Count__c;
                    if (retryCountList[0].Count__c < metadata.Number_Of_Attempts__c) {
                        retryCountList[0].Count__c += 1;
                        if (Schema.sObjectType.Retry_Count__c.isUpdateable()) {
                            update retryCountList;
                        }else {
                            throw new AuraHandledException(System.label.Retrycountnotinserted);
                        }
                        if (retryCountList[0].Count__c >= metadata.Number_Of_Attempts__c) {
                            return true;
                        }
                    }
                } else {
                    Retry_Count__c retryCount = new Retry_Count__c();
                    retryCount.Loan_Application_Id__c = loanApplicationId;
                    retryCount.Service_Name__c = System.Label.VKYC;
                    retryCount.Module__c = loanApplications[0].StageName;
                    retryCount.User_Id__c = UserInfo.getUserId();
                    retryCount.Count__c = 1;
                    if (Schema.sObjectType.Retry_Count__c.isCreateable()) {
                        insert retryCount;
                    } else {
                        throw new AuraHandledException(System.label.Retrycountnotinserted);
                    }
                }
            }
            return false;
        } catch (Exception e) {
            ErrorLoggerUtil.logErrorEvent('D2C_IntegrationEngine', 'retryCountIncrease', System.Label.Apex, e);
            throw new AuraHandledException(System.Label.ExceptionMessage);
        }
    }

    /*
     * @Method:      doD2COfferEngineCallout
     * @Created by:  Raman Raj Saxena
     * @Description: Continuation for D2C Offer Engine API
     * @Param:       String -
     * @Return:      Object - continuation
     */

     @AuraEnabled(continuation=true)
     public static Object doD2COfferEngineCallout(String loanId, String applicantId, String fromScreen, String sliderLoanAmount, String sliderTenure, String incomePerMonth, Boolean breachCRMIRR, String minCRMIRR) {
         Continuation con;
         Integer Income;
         Integer CoborrowerIncome;
         Integer BorrowerIncome;
         String Coborrower;
         try {
            List<Applicant__c> lstApplicant = [
                SELECT
                    Id,
                    Applicant_Type__c,
                    In_Active_Applicant__c,
                    applicant_number__c,
                    Scorecard_Decision__c,
                    Declared_income__c,
                    SumofAllLowerEMIs__c,
                    Opportunity__r.Basic_Price__c,
                    Opportunity__r.Lead_Number__c,
                    Opportunity__r.Product_Type__c,
                    Opportunity__r.Vehicle_Type__c,
                    Opportunity__r.LeadSource,
                    Opportunity__r.On_Road_price__c,
                    Opportunity__r.On_Road_price_carwale__c,
                    Opportunity__r.Is_Pre_Approved__c,
                    Opportunity__r.Aggregator_Source__c,
                    Opportunity__r.OwnHouseflag__c
                FROM Applicant__c
                WHERE Opportunity__r.id = :loanId AND In_Active_Applicant__c = FALSE
                WITH SECURITY_ENFORCED
            ];
            RequestWrapper requestWrapper = new RequestWrapper();
            
            Vehicle_Detail__c vehicleDetails = null;
            List<Product2> products = new List<Product2>();
            List<Benefi__c> dealers = new List<Benefi__c> ();
             
            vehicleDetails = [SELECT Valuation_price__c, Make_Code__c, Model_Code__c, Variant_Code__c, Loan_Application__r.Product_Type__c, Ben_Code__c FROM Vehicle_Detail__c WHERE Loan_Application__c =: loanId LIMIT 1];
            products = [SELECT Id ,
                Manufacturer_code__c FROM Product2 WHERE Variant_Code__c != null AND Product_Type__c = 'TWO WHEELER' 
                AND make__c =: vehicleDetails.Make_Code__c AND model__c =: vehicleDetails.Model_Code__c AND Variant_Code__c =: vehicleDetails.Variant_Code__c ];
            dealers = [Select id, Grade__c from Benefi__c where Ben_code__c =: vehicleDetails.Ben_Code__c];
             
            List<Final_Term__c> objFinalTerms = [SELECT id,Dealer_incentive_amount_main_dealer__c, LtvEngine_Ltv__c, Net_Pay_Ins__c, Net_Pay_Outs__c, PricingEngine_thresholdNetrr__c, Loan_amount__c,IO_Tenure__c,IO_Loan_Amount__c, CRM_IRR__c, Loan_Application__r.Loan_amount__c, Loan_Application__r.Total_Funded_Premium__c, Tenure__c, Inputted_IRR__c, Net_IRR__c,Dealer_incentive_amount_sub_dealer__c,Installment_Type__c,First_EMI_Date__c,Second_EMI_Date__c FROM Final_Term__c WHERE Loan_Application__c = :loanId LIMIT 1]; /*Added Dealer_incentive_amount_main_dealer__c  in QUERY for CISP-10066*/
                 
            for (Applicant__c applicant : lstApplicant) {
                 
                requestWrapper.leadId = applicant.Opportunity__r.Lead_Number__c;
                requestWrapper.OwnHouseFlag = applicant.Opportunity__r.OwnHouseflag__c;
                requestWrapper.borrowerApplicantNumber = applicant.applicant_number__c;
                requestWrapper.product = applicant.Opportunity__r.Product_Type__c;
                requestWrapper.vehicleType = applicant.Opportunity__r.Vehicle_Type__c;
                requestWrapper.scoreCardDecision = applicant.Scorecard_Decision__c;
                BorrowerIncome = (Integer) (applicant.Declared_income__c / 12);
                requestWrapper.isPACustomer = applicant.Opportunity__r.Is_Pre_Approved__c;
                applicantId = applicantId == null ? applicant.Id : applicantId;
                requestWrapper.ORPQuotationPrice = String.valueOf(applicant.Opportunity__r.On_Road_price__c.round(System.RoundingMode.DOWN));
                if(applicant.Opportunity__r.Vehicle_Type__c.toLowerCase() != 'new'){
                    requestWrapper.ORPQuotationPrice = String.valueOf(vehicleDetails.Valuation_price__c.round(System.RoundingMode.DOWN));
                }
                /* CISP-10066 Start */
                if(objFinalTerms.size() > 0 && (objFinalTerms[0].Dealer_incentive_amount_main_dealer__c == '0' || String.isEmpty(objFinalTerms[0].Dealer_incentive_amount_main_dealer__c)) && applicant.Opportunity__r.Product_Type__c == 'Passenger Vehicles'){
                    requestWrapper.DealerCategory = 'NoPayout';
                }
                /* CISP-10066 End */
                else if(objFinalTerms.size() > 0 && (objFinalTerms[0].Dealer_incentive_amount_sub_dealer__c == '0' || String.isEmpty(objFinalTerms[0].Dealer_incentive_amount_sub_dealer__c)) && applicant.Opportunity__r.Product_Type__c != 'Passenger Vehicles' && applicant.Opportunity__r.LeadSource != 'Hero'){ // Added else if and exclusion for PV : CISP-10066 CISH-95
                    requestWrapper.DealerCategory = 'NoPayout';
                }else{
                    if(vehicleDetails.Ben_Code__c != null) {
                        if(dealers.size() > 0) {
                            requestWrapper.DealerCategory = String.isNotBlank(dealers[0].Grade__c) ? dealers[0].Grade__c : 'Others';
                        }
                    }
                    if(String.isNotBlank(applicant.Opportunity__r.Aggregator_Source__c)){
                        requestWrapper.DealerCategory = 'MFC';
                    }else if(requestWrapper.isPACustomer == true){
                        requestWrapper.DealerCategory = 'PA';
                    }else if(String.isBlank(requestWrapper.DealerCategory)){
                        requestWrapper.DealerCategory = 'Others';
                    }
                }
                if(String.isNotBlank(vehicleDetails.Make_Code__c) && String.isNotBlank(vehicleDetails.Model_Code__c) 
                && String.isNotBlank(vehicleDetails.Variant_Code__c) && vehicleDetails.Loan_Application__r.Product_Type__c ==  'Two Wheeler') {
                    
                    if(products.size() > 0) {   
                        requestWrapper.Manufacture_Code = products[0].Manufacturer_code__c;
                    }   
                }
                requestWrapper.Channel = String.isNotBlank(applicant.Opportunity__r.Aggregator_Source__c) ? 'Aggregator' : applicant.Opportunity__r.LeadSource == 'Hero' ? 'Hero' : 'IndusMobile';//CISH-85
             }
             if (BorrowerIncome != null && CoborrowerIncome != null) {
                 Income = BorrowerIncome + CoborrowerIncome;
             } else if (BorrowerIncome != null && CoborrowerIncome == null) {
                 Income = BorrowerIncome;
             } else if (BorrowerIncome == null && CoborrowerIncome != null) {
                 Income = CoborrowerIncome;
             }
 
            requestWrapper.income = String.valueOf(Income);
            if (objFinalTerms.size() != 0) {
                requestWrapper.EngineBankIrr = String.valueOf(objFinalTerms[0].PricingEngine_thresholdNetrr__c);
                requestWrapper.EngineLTV = String.valueOf(objFinalTerms[0].LtvEngine_Ltv__c);
                Decimal finAmount = String.isNotEmpty(objFinalTerms[0].Loan_amount__c) ? Decimal.valueOf(objFinalTerms[0].Loan_amount__c)+objFinalTerms[0].Loan_Application__r.Total_Funded_Premium__c : objFinalTerms[0].Loan_Application__r.Total_Funded_Premium__c;
                requestWrapper.finAmount = String.valueOf(finAmount);
                requestWrapper.RequiredTenureFinalOffer = String.isNotEmpty(objFinalTerms[0].Tenure__c) ? String.valueOf(objFinalTerms[0].Tenure__c):'';
                requestWrapper.RequiredLoanAmountFinalOffer = String.isNotEmpty(objFinalTerms[0].Loan_amount__c) ? String.valueOf(objFinalTerms[0].Loan_amount__c):'';
                requestWrapper.Funded_Insurance = objFinalTerms[0].Loan_Application__r.Total_Funded_Premium__c != null ? String.valueOf(objFinalTerms[0].Loan_Application__r.Total_Funded_Premium__c):'';
                requestWrapper.DisplayLoanAmount = String.isNotEmpty(objFinalTerms[0].Loan_amount__c) ? String.valueOf(objFinalTerms[0].Loan_amount__c):'';
                requestWrapper.DisplayCrmIrr = objFinalTerms[0].CRM_IRR__c != null ? String.valueOf(objFinalTerms[0].CRM_IRR__c):'';
                requestWrapper.DisplayTenure = String.isNotEmpty(objFinalTerms[0].Tenure__c) ? String.valueOf(objFinalTerms[0].Tenure__c):'';
                requestWrapper.DisplayImputedIrr = objFinalTerms[0].Inputted_IRR__c != null ? String.valueOf(objFinalTerms[0].Inputted_IRR__c):'';
                requestWrapper.NetIrr = objFinalTerms[0].Net_IRR__c != null ? String.valueOf(objFinalTerms[0].Net_IRR__c):'';
                requestWrapper.NetPayIns = String.isNotEmpty(objFinalTerms[0].Net_Pay_Ins__c) ? String.valueOf(objFinalTerms[0].Net_Pay_Ins__c):'';
                requestWrapper.NetPayOuts = String.isNotEmpty(objFinalTerms[0].Net_Pay_Outs__c) ? String.valueOf(objFinalTerms[0].Net_Pay_Outs__c):'';
                requestWrapper.installmentType = String.isNotEmpty(objFinalTerms[0].Installment_Type__c) ? objFinalTerms[0].Installment_Type__c:'';
                requestWrapper.firstEMIDate = objFinalTerms[0].First_EMI_Date__c != null ? String.valueOf(objFinalTerms[0].First_EMI_Date__c):'';
                requestWrapper.secondEMIDate = objFinalTerms[0].Second_EMI_Date__c != null ? String.valueOf(objFinalTerms[0].Second_EMI_Date__c):'';

            }else{
                requestWrapper.EngineBankIrr = '';
                requestWrapper.EngineLTV = '';
            }
            if(requestWrapper.isPACustomer){
                requestWrapper.RequiredTenureFinalOffer = String.isNotBlank(objFinalTerms[0].IO_Tenure__c) != null? String.valueOf(objFinalTerms[0].IO_Tenure__c):'';
                requestWrapper.RequiredLoanAmountFinalOffer = String.isNotBlank(objFinalTerms[0].IO_Loan_Amount__c) != null ? String.valueOf(objFinalTerms[0].IO_Loan_Amount__c):'';
            }
            if(fromScreen == 'cam'){
                requestWrapper.finAmount = sliderLoanAmount;
            }

            //CISP-20443 Start
            if(lstApplicant[0].opportunity__r.LeadSource == 'D2C' && lstApplicant[0].opportunity__r.Product_Type__c == System.Label.PassengerVehicles && String.isNotBlank(fromScreen) && fromScreen == 'payin_payout'){
                Decimal finFinalValue = String.isNotEmpty(objFinalTerms[0].Loan_amount__c) ? Decimal.valueOf(objFinalTerms[0].Loan_amount__c) : 0;
                requestWrapper.finAmount = String.valueOf(finFinalValue);
            }
            //CISP-20443 End

            List<Income_Details__c> incomeDetails = [SELECT Id, Applicant__c, ABB_Method__c, Income_from_Perfios__c, Average_Bank_Balance__c FROM Income_Details__c WHERE Applicant__c =: applicantId AND Income_Source_Status__c = 'IP'];
            List<Field_Investigation__c> officeFIs = [SELECT id, Monthly_Income_as_per_FI_Visit__c, Income_as_per_FI_Visit__c, Case__r.Loan_Application__r.Product_Type__c from Field_Investigation__c WHERE Case__r.Type = 'Office FI' AND Case__r.Loan_Application__c =:loanId];
            if(incomeDetails.size() != 0){
                requestWrapper.AbbFlag = String.isNotBlank(incomeDetails[0].ABB_Method__c)?'Y':'N';
                requestWrapper.AbbValue = incomeDetails[0].Average_Bank_Balance__c != null && String.isNotBlank(incomeDetails[0].ABB_Method__c)?String.valueOf(incomeDetails[0].Average_Bank_Balance__c):'';
                if(incomeDetails[0].Income_from_Perfios__c != null && (Integer)incomeDetails[0].Income_from_Perfios__c != 0){
                    requestWrapper.income = String.valueOf((Integer)incomeDetails[0].Income_from_Perfios__c);
                }
            }
            //CFDI-1162
            if(incomeDetails.size() == 0 || incomeDetails[0].Income_from_Perfios__c == null || (Integer)incomeDetails[0].Income_from_Perfios__c == 0){
                if(officeFIs != null && !officeFIs.isEmpty() && officeFIs[0].Case__r.Loan_Application__r.Product_Type__c == 'Passenger Vehicles' && officeFIs[0].Monthly_Income_as_per_FI_Visit__c !=null){
                    requestWrapper.income = String.valueOf((Integer)officeFIs[0].Monthly_Income_as_per_FI_Visit__c);
                }
            }
            
            if(fromScreen == 'sliderScreen'){
                requestWrapper.SliderLoanAmount = sliderLoanAmount;
                requestWrapper.SliderTenure = sliderTenure;
            }
             //As per clarification by Maitreye on 9/9/22 requestWrapper.emi = max(sum(Lower_EMI_Limit__c), EMI__c)
             Double existingEMI = 0;
             for (Existing_EMI__c objEMI : [SELECT EMI__c, Lower_EMI_Limit__c FROM Existing_EMI__c WHERE Applicant_Id__c = :applicantId ORDER BY CreatedDate DESC]) {
                 if (objEMI.EMI__c != null && existingEMI == 0) {
                     existingEMI = objEMI.EMI__c;
                 }
             }
             lstApplicant[0].SumofAllLowerEMIs__c = lstApplicant[0].SumofAllLowerEMIs__c == null? 0:lstApplicant[0].SumofAllLowerEMIs__c;
             if (Math.max(existingEMI, lstApplicant[0].SumofAllLowerEMIs__c) != 0) {
                 requestWrapper.emi = String.valueOf(Math.max(existingEMI, lstApplicant[0].SumofAllLowerEMIs__c));
             } else {
                 requestWrapper.emi = '';
             }
 
             Integration_Configuration__mdt apiConfiguration = IntegrationUtilities.getAPIConfiguration('Offer Engine DSA');
             Integer timeout = Integer.valueOf(apiConfiguration.Timeout__c);
             IND_OfferEngineRequestD2C offerEngineRequestD2C;
             if(breachCRMIRR!= NULL && breachCRMIRR){ //CISP-20180
                offerEngineRequestD2C = IND_OfferEngineServiceD2C.getD2COfferEngineCallOutRequest(requestWrapper, loanId, fromScreen, minCRMIRR);
             }else{
                offerEngineRequestD2C = IND_OfferEngineServiceD2C.getD2COfferEngineCallOutRequest(requestWrapper, loanId, fromScreen);
             }
             System.debug('Final Request'+offerEngineRequestD2C);
             CalloutProcessor processor = new CalloutProcessor('Offer Engine DSA', offerEngineRequestD2C);
             HttpRequest request = processor.createHttpRequest();
             Long startTime = DateTime.now().getTime();
             Carrier carrier = new carrier();
             carrier.setServiceName('Offer Engine DSA');
             carrier.setProcessor(processor);
             carrier.setRequest(IntegrationUtilities.getPlainTextForLog(request.getBody()));
             System.debug('Final Request2'+IntegrationUtilities.getPlainTextForLog(request.getBody()));
             carrier.setEncryptedRequest(request.getBody());
             carrier.setStartTime(startTime);
             carrier.setLoanApplicationId(loanId);
             //Add callout request to continuation
             con = new Continuation(timeout);
             con.continuationMethod = 'processOfferEngineCalloutResponseD2C';
             con.state = carrier;
             con.addHttpRequest(request);
         } catch (Exception ex) {
             ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'doDSAOfferEngineCallout', System.Label.Apex, ex, loanId);
             throw ex;
         }
         return con;
     }
 
     /*
      * @Method:      processOfferEngineCalloutResponseD2C
      * @Created by:  Raman Raj Saxena
      * @Description: Callback method to return Response for D2C Offer Engine API
      * @Param:       Collection - labels
      * @Param:       Object - state
      * @Return:      Object - response
      */
     @AuraEnabled
     public static Object processOfferEngineCalloutResponseD2C(List<String> labels, Object state) {
         IND_OfferEngineResponseDSA apiResponse;
         String request = '';
         String encryptedRequest = '';
         String serviceName = '';
         String loanAppId = '';
         HttpResponse response;
         String elapseTime = '';
         String responseBody = '';
         try {
             Carrier carrier = (Carrier) state;
             request = carrier.getRequest();
             encryptedRequest = carrier.getEncryptedRequest();
             serviceName = carrier.getServiceName();
             Long startTime = carrier.getStartTime();
             CalloutProcessor processor = carrier.getProcessor();
             response = Continuation.getResponse(labels[0]);
             Long endTime = DateTime.now().getTime();
             elapseTime = String.valueOf((Double) (endTime - startTime) / 1000);
             loanAppId = carrier.getLoanApplicationId();

             if (response != null && response.getStatusCode() == 200) {
                 apiResponse = (IND_OfferEngineResponseDSA) processor.getHttpResponse(response, serviceName);
                 System.debug('Final Response'+apiResponse);
                 if (apiResponse != null) {
                     IntegrationUtilities.createIntegrationLogger(
                         request,
                         encryptedRequest,
                         IntegrationUtilities.getPlainTextForLog(response.getBody()),
                         response.getBody(),
                         serviceName + 'D2C',
                         elapseTime,
                         loanAppId,
                         System.Label.Success
                     );
                     return JSON.serialize(apiResponse);
                 } else {
                     IntegrationUtilities.createIntegrationLogger(
                         request,
                         encryptedRequest,
                         IntegrationUtilities.getPlainTextForLog(response.getBody()),
                         response.getBody(),
                         serviceName + 'D2C',
                         elapseTime,
                         loanAppId,
                         System.Label.Failure
                     );
                     throw new IND_Exception(System.Label.NoResponse);
                 }
             } else {
                 String errString = '[Status Code = ' + response.getStatusCode() + ' ] Response-->' + IntegrationUtilities.getPlainTextForLog(response.getBody());
                 IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, errString, response.getBody(), serviceName + 'D2C', elapseTime, loanAppId, System.Label.Failure);
                 ErrorLoggerUtil.logErrorEvent('CalloutProcessor', 'getHttpResponse', System.Label.Apex, new IND_Exception(errString), loanAppId);
                 throw new IND_Exception(System.Label.NoResponse);
             }
         } catch (Exception ex) {
             IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, '', '', serviceName + 'D2C', elapseTime, loanAppId, System.Label.Failure);
             ErrorLoggerUtil.logErrorEvent('D2C_IntegrationEngine', 'processOfferEngineCalloutResponseD2A', System.Label.Apex, ex, loanAppId);
             throw new IND_Exception(ex.getMessage());
         }
     }
 
     /* All API Method Should be added above this class
      * @Class:      Carrier
      * @Created by:  Bhushan Charde
      * @Description: This is a helper class used to transport object/fields to callback method from continuation block
      */
     public class Carrier {
         public transient string request;
         public transient string encryptedRequest;
         public transient String serviceName;
         public transient CalloutProcessor processor;
         public transient Long startTime;
         public transient String loanApplicationId;
         public transient List<Object> tempObject;
 
         Carrier() {
         }
 
         Carrier(String serviceName, CalloutProcessor processor, String encryptRequest, Long startTime, String loanAppId, String plainRequest) {
             this.serviceName = serviceName;
             this.processor = processor;
             this.encryptedRequest = encryptRequest;
             this.startTime = startTime;
             this.loanApplicationId = loanAppId;
             this.request = plainRequest;
         }
 
         void setTempObject(List<Object> tempObject) {
             this.tempObject = tempObject;
         }
         public List<Object> getTempObject() {
             return tempObject;
         }
 
         void setRequest(String request) {
             this.request = request;
         }
         public String getRequest() {
             return request;
         }
         void setEncryptedRequest(String encryptedRequest) {
             this.encryptedRequest = encryptedRequest;
         }
         public String getEncryptedRequest() {
             return encryptedRequest;
         }
         void setProcessor(CalloutProcessor processor) {
             this.processor = processor;
         }
         public CalloutProcessor getProcessor() {
             return processor;
         }
         void setServiceName(String serviceName) {
             this.serviceName = serviceName;
         }
         public String getServiceName() {
             return serviceName;
         }
         void setStartTime(Long startTime) {
             this.startTime = startTime;
         }
         public Long getStartTime() {
             return startTime;
         }
         void setLoanApplicationId(String loanApplicationId) {
             this.loanApplicationId = loanApplicationId;
         }
         public String getLoanApplicationId() {
             return loanApplicationId;
         }
     }
 
     @AuraEnabled
     public static Boolean expression(String valuepassedin) {
         return true;
     }

    public class VKYCDocumentsWrapper{
        public String aadhar_photo;
        public String pan_card;
        public String customer_signature;
        public String customer_image;
    }

    public class VKYCResponses{
        HttpResponse response;
        String docType;
    }
}