/*------------------------------------------------------------
Author:        Divya Jawale
Company:       Persistent Systems
Description:   This class contains methods related to Lead Generation -API callout.
Inputs:        None 
Test Classes:    IND_SMSService_Test, IND_CIBILService_Test,IND_UidaiOTPService_Test,
				 IND_VehicleDedupeService_Test,IND_UidaiOTPVerifyService_Test,
				 IND_InternalDedupeService_Test,IND_CibilOcrBackUploadService_Test,
				 IND_CibilOcrFrontUploadService_Test
History
Date            Author              Comments
-------------------------------------------------------------
1-10-2021      Divya Jawale       Created
1-10-2021      Divya Jawale       IND-356 OTP Consent and Verification -Added getEncryptedRequest and getDecryptedResponse method
11-12-2021     Bhushan Charde     Modified - Incorporated Continuation Framework and Stub Response Logic
21-04-2022     Daksh Mandowara    Modified - Added method for Disbusement
------------------------------------------------------------*/
public with sharing class IntegrationEngine {
    
    //variable refers to the async service name
    public static String serviceName{get;set;}
    //variable refers to the async ParentAPIRequest
    public static ParentAPIRequest parentAPIRequest{get;set;}
    
    // Test variable used for holding a reference to the Continuation Request
    @TestVisible
    public static String continuationLabel;
    
    // Test variable used for holding the value of the Continuation.state attribute
    @TestVisible
    public static Object continuationState;
    
    public static String loanApplicationRef;
    
    /*
* @Method:      doSmsGatewayCallout
* @Created by:  Divya Jawale 
* @Description: Method to return Response for SMS Getway API
* @Param:       String - Applicant Id
* @Return:      String - response
*/
    @AuraEnabled(continuation=true)
    public static Object doSmsGatewayCallout(String smsRequestString){
        Continuation con;
        String loanAppId;
        try{
           
            if(String.isBlank(smsRequestString)){
                throw new IND_Exception(System.Label.Retry);
            }
            //Provide API-wise Integration Name to Custom Metadata Configs
            Integration_Configuration__mdt apiConfiguration = IntegrationUtilities.getAPIConfiguration(System.Label.SMSGateway);
            
            //if stubs checked in Integration_Configuration then stubs will return 
            if(apiConfiguration.IsStub_Required__c != null && apiConfiguration.IsStub_Required__c){  
                String stubData = IntegrationUtilities.getStubResponse(System.Label.SMSGateway);
                return stubData == null ? System.Label.EmptyStubs : stubData;
            }
            
            Integer timeout = Integer.valueOf(apiConfiguration.Timeout__c);
            RequestWrapper requestWrapper = (RequestWrapper)IntegrationUtilities.parseJSONRequest(smsRequestString,'RequestWrapper');
            List<Applicant__c> app = [SELECT Id,applicant_number__c,Contact_number__c, Whatsapp_number__c, OTP_for_borrower__c,Opportunity__r.Lead_number__c, Insurance_Consent_OTP__c, Application_Consent_OTP__c,Opportunity__r.LeadSource FROM Applicant__c WHERE Id=:requestWrapper.applicantId WITH SECURITY_ENFORCED Limit 1];//CISP-2879
            User selecteduser;
             if(app[0].Opportunity__r.LeadSource == 'D2C' && requestWrapper.flag.equals('LTS')){
                selecteduser = [select id,MobilePhone,name from user where Id=:requestWrapper.selectedUser];//CISP-6945 
             } 
            if(app.isEmpty()){
                throw new IND_Exception(System.Label.Applicantdatamissing);
            } else {
                for(Applicant__c applicant:app){
                    requestWrapper.leadId= applicant.Opportunity__r.Lead_Number__c + '_' + applicant.applicant_number__c;//CISP-2879
                    if(applicant.Opportunity__r.LeadSource == 'D2C' && requestWrapper.flag.equals('LTS')){//CISP-6945
                        requestWrapper.contactNumber= selecteduser.MobilePhone;  
                    }else{
                    requestWrapper.contactNumber= applicant.Contact_number__c;
                    }//CISP-6945
                    requestWrapper.otpForBorrower= applicant.OTP_for_borrower__c;
                    if(requestWrapper.flag.equals('AML')){
                        requestWrapper.otpForBorrower= '';
                    }
                    if(applicant.Opportunity__r.LeadSource == 'D2C' && requestWrapper.flag.equals('LTS')){//CISP-6945
                        requestWrapper.contactNumber= selecteduser.MobilePhone;  
                    }else{
                    requestWrapper.whatsappNo = applicant.Whatsapp_number__c;
                     }//CISP-6945
					requestWrapper.otpForInsConsent = applicant.Insurance_Consent_OTP__c;
                    requestWrapper.otpForAppSignConsent = applicant.Application_Consent_OTP__c;
                }
            }
            
            loanAppId = requestWrapper.loanApplicationId;
            loanApplicationRef= requestWrapper.loanApplicationId;
            IND_SMSRequest smsRequest = IND_SMSService.getSmsCallOutRequest(requestWrapper); 
            CalloutProcessor processor = new CalloutProcessor(System.Label.SMSGateway, smsRequest);
            HttpRequest request = processor.createHttpRequest();
        
            Long startTime = DateTime.now().getTime();
            
            Carrier carrier = new carrier(System.Label.SMSGateway, processor, request.getBody(), startTime, loanAppId,
                                          IntegrationUtilities.getPlainTextForLog(request.getBody()));
                       
            //Add callout request to continuation
            con = new Continuation(timeout);        
            con.continuationMethod='processSMSGatewayResponse';
            con.state=carrier;
            con.addHttpRequest(request);
            
            if(Test.isRunningTest()) {
               continuationLabel = con.addHttpRequest(request);
               continuationState = carrier; 
            }             
        } catch(Exception ex) {
            ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'doSmsGatewayCallout', System.Label.Apex, ex, loanAppId);
            throw ex;
        }
        return con;
    }
    
    /*
* @Method:      doReverseStatus
* @Created by:  Vishal Gadhave & Parimal Shinde
* @Description: Reverse status is sent from SF after relevant stages are completed
* @Param:       String - Application_No
* @Return:      void
*/
    @InvocableMethod(label = 'Call the API and send the Reverse Status')
    public static void doReverseStatusCallout(List<FlowInputs> loanAppId){
        List<opportunity> optylist=[select id,stagename,LeadSource from opportunity where Lead_number__c=:loanAppId[0].LoanId limit 1];
        if((optylist.size()>0) && ((optylist[0].LeadSource == 'OLA') || (optylist[0].LeadSource == 'Hero'))){//CISH-17
            try{
                System.enqueueJob(new IND_ReverseStatusCalloutOLAQueueable(loanAppId[0].LoanId,loanAppId[0].status));
            } catch(Exception ex) {
                ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'doReverseStatusCallout', System.Label.Apex, ex,optylist[0].id);
                throw ex;
            }   
        }else if((optylist.size()>0) && ((optylist[0].LeadSource == 'TAFE'))){  //SFTRAC-532 Start
            try{
                System.enqueueJob(new IND_ReverseStatusCalloutTAFEQueueable(loanAppId[0].LoanId,loanAppId[0].status, loanAppId[0].dealNumber));
            } catch(Exception ex) {
                ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'doReverseStatusCallout', System.Label.Apex, ex,optylist[0].id);
                throw ex;
            }//SFTRAC-532 end
        }else{
            try{
                loanApplicationRef= loanAppId[0].LoanId;
                Id ReverseStatusQueuejobID = System.enqueueJob(new IND_ReverseStatusCalloutQueueable( loanApplicationRef,loanAppId[0].status,loanAppId[0].code));
            } catch(Exception ex) {
                ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'doReverseStatusCallout', System.Label.Apex, ex,loanAppId[0].LoanId);
                throw ex;
            }
        }
    }
    
    public class FlowInputs{
    
        @InvocableVariable
        public String LoanId;
        
        @InvocableVariable
        public String status;
        
        @InvocableVariable
        public String code;      
        
        @InvocableVariable
        public String dealNumber; //SFTRAC-1916
    }
    
    /*
* @Method:      processSMSGatewayResponse
* @Created by:  Divya Jawale 
* @Description: Method to return Response for SMS Getway API
* @Param:       Collection - labels
* @Param:       Object - state
* @Return:      Object - response 
*/
    @AuraEnabled(cacheable=true)
    public static Object processSMSGatewayResponse(List<String> labels, Object state){
        IND_SMSResponse apiResponse;
        String request='';
        String encryptedRequest='';
        String serviceName='';
        String data='';
        HttpResponse response;
        String elapseTime='';
        String loanAppId='';
        try{
            Carrier carrier = (Carrier)state;
            request = carrier.getRequest();
            encryptedRequest = carrier.getEncryptedRequest();
            serviceName = carrier.getServiceName();
            Long startTime = carrier.getStartTime();
            
            CalloutProcessor processor = carrier.getProcessor();
            response = Continuation.getResponse(labels[0]);
            Long endTime = DateTime.now().getTime();
            elapseTime = String.valueOf((Double)(endTime - startTime)/1000);
            loanAppId = carrier.getLoanApplicationId();
            if(response != null && response.getStatusCode() == 200) {
                apiResponse = (IND_SMSResponse)processor.getHttpResponse(response, serviceName);
                    if(apiResponse != null && apiResponse.response.status == 'SUCCESS'){
                        data= apiResponse.response.status;
                        IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, IntegrationUtilities.getPlainTextForLog(response.getBody()), response.getBody(), serviceName, elapseTime, loanAppId, System.Label.Success);
                    } else {
                        data= 'FAIL';
                        IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, '', '', serviceName, elapseTime, loanAppId, System.Label.Failure);
                    }                  
            } else {
                String errString = '[Status Code = '+ response.getStatusCode() +' ] Response-->'+IntegrationUtilities.getPlainTextForLog(response.getBody());
                IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, errString, response.getBody(), serviceName, elapseTime, loanAppId, System.Label.Failure);
                ErrorLoggerUtil.logErrorEvent('CalloutProcessor', 'getHttpResponse', System.Label.Apex, new IND_Exception(errString), loanAppId);
                data = System.Label.NoResponse;
            } 
            
        } catch (Exception ex){
            IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, '', '', serviceName, elapseTime, loanAppId, System.Label.Failure);
            ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'processResponseSMS', System.Label.Apex, ex, loanAppId);
            throw new IND_Exception(ex.getMessage());
        }
        return data;
    }
          /*
* @Method:      doSmsGatewayAPI  */
@AuraEnabled(cacheable=true)
public static String doSmsGatewayAPI(String smsRequestString){
    
    if(String.isBlank(smsRequestString)){
        throw new IND_Exception(System.Label.Retry);
    }
    
    Integration_Configuration__mdt apiConfiguration = IntegrationUtilities.getAPIConfiguration(System.Label.SMSGateway);
    Integer timeout = Integer.valueOf(apiConfiguration.Timeout__c);
    
    
    //if stubs checked in Integration_Configuration then stubs will return
    if(apiConfiguration.IsStub_Required__c != null && apiConfiguration.IsStub_Required__c){
        String stubData = IntegrationUtilities.getStubResponse(System.Label.SMSGateway);
        return stubData == null ? System.Label.EmptyStubs : stubData;
    }
    
    if(!apiConfiguration.IsActive_Integration__c){
        throw new IND_Exception(System.Label.ServiceDown);
    }
    
    String resp = '';
    String serviceName = System.Label.SMSGateway; // Gaurav : Changes for the Service Name.
    String loanAppId;
    String loanApplicationRef;
    String elapseTime;
    HttpRequest request;
    try{
    
        RequestWrapper requestWrapper = (RequestWrapper)IntegrationUtilities.parseJSONRequest(smsRequestString,'RequestWrapper');
        List<Applicant__c> app = [SELECT Id,applicant_number__c,Contact_number__c, Whatsapp_number__c, OTP_for_borrower__c, Application_Consent_OTP__c, Opportunity__r.Lead_number__c,Opportunity__r.Owner.Name,Opportunity__r.Owner.MobilePhone,CASA_Consent_OTP__c FROM Applicant__c WHERE Id=:requestWrapper.applicantId WITH SECURITY_ENFORCED Limit 1];//CISP-2879  // Added LeadNumber, OwnerName and OwnerMobile for OLA-204  
      
        if(app.isEmpty()){
            throw new IND_Exception(System.Label.Applicantdatamissing);
        } else {
            for(Applicant__c applicant:app){
                requestWrapper.leadId= applicant.Opportunity__r.Lead_Number__c + '_' + applicant.applicant_number__c;//CISP-2879
                requestWrapper.contactNumber= applicant.Contact_number__c;
                 /*OLA-204 Start*/
                if(requestWrapper.flag.equals('cutomer_intimation')){
                    requestWrapper.leadName = applicant.Opportunity__r.Lead_number__c;
                    requestWrapper.leadOwnerName = applicant.Opportunity__r.Owner.Name;
                    requestWrapper.leadOwnerContact = applicant.Opportunity__r.Owner.MobilePhone;
                }
                /*OLA-204 End*/
				if(requestWrapper.flag.equals('LAS')){
					requestWrapper.otpForAppSignConsent= applicant.Application_Consent_OTP__c;
				}else if(requestWrapper.flag.equals('CASA')){
                        requestWrapper.otpForCasaConsent= applicant.CASA_Consent_OTP__c;
                }else{
					requestWrapper.otpForBorrower= applicant.OTP_for_borrower__c;
				} 
                requestWrapper.whatsappNo = applicant.Whatsapp_number__c;
            }
        }
        
        loanAppId = requestWrapper.loanApplicationId;
        loanApplicationRef= requestWrapper.loanApplicationId;
        IND_SMSRequest smsRequest = IND_SMSService.getSmsCallOutRequest(requestWrapper); 
        CalloutProcessor processor = new CalloutProcessor(System.Label.SMSGateway, smsRequest);
        request = processor.createHttpRequest();
        request.setTimeout(12000);
        
        Long startTime = DateTime.now().getTime();
        
        Http http = new Http();
        HttpResponse response = http.send(request);
        
        Long endTime = DateTime.now().getTime();
        elapseTime = String.valueOf((Double)(endTime - startTime)/1000);
        
            if(response != null && response.getStatusCode() == 200){
                IND_SMSResponse apiResponse = (IND_SMSResponse)processor.getHttpResponse(response, System.Label.SMSGateway);
                system.debug('The SMS API response is '+apiResponse.response.status);
                if(apiResponse != null && apiResponse.response.status == 'SUCCESS'){
                    resp = apiResponse.response.status;
                    IntegrationUtilities.createIntegrationLogger(IntegrationUtilities.getPlainTextForLog(request.getBody()), request.getBody(), IntegrationUtilities.getPlainTextForLog(response.getBody()), response.getBody(), serviceName, elapseTime, loanAppId, System.Label.Success);
                } else {
                    resp = 'FAIL';
                    IntegrationUtilities.createIntegrationLogger(IntegrationUtilities.getPlainTextForLog(request.getBody()), request.getBody(), IntegrationUtilities.getPlainTextForLog(response.getBody()), response.getBody(), serviceName, elapseTime, loanAppId, System.Label.Failure);
                }    
            } else {
                resp = 'FAIL';
                IntegrationUtilities.createIntegrationLogger(IntegrationUtilities.getPlainTextForLog(request.getBody()), request.getBody(), IntegrationUtilities.getPlainTextForLog(response.getBody()), response.getBody(), serviceName, elapseTime, loanAppId, System.Label.Failure);
                String errString = '[Status Code = '+ response.getStatusCode() +' ] Response-->'+IntegrationUtilities.getPlainTextForLog(response.getBody());
                ErrorLoggerUtil.logErrorEvent('CalloutProcessor', 'getHttpResponse', System.Label.Apex, new IND_Exception(errString), loanAppId);
            }               
    } catch(Exception ex){
        IntegrationUtilities.createIntegrationLogger(IntegrationUtilities.getPlainTextForLog(request.getBody()), request.getBody(), '', '', serviceName, elapseTime, loanAppId, System.Label.Failure);
        ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'doSmsGatewayAPI', System.Label.Apex, ex,loanAppId);
        throw new IND_Exception(ex.getMessage());
    }
    
    return resp;
}   
    
    /*
* @Method:      doCIBILReportCallout
* @Created by:  Divya Jawale 
* @Description: Method to return Response for CIBIL Request Response API
* @Param:       String - Applicant Id
* @Return:      String - response
*/
@AuraEnabled(continuation=true cacheable=true)
public static Object doCIBILReportCallout(String cibilRequestString){
    Continuation con;
    String loanAppId;
	String customer_Code;
    String dealId = '';
    try{
        if(String.isBlank(cibilRequestString)){
            throw new IND_Exception(System.Label.Retry);
        }
        //Provide API-wise Integration Name to Custom Metadata Configs
        Integration_Configuration__mdt apiConfiguration = IntegrationUtilities.getAPIConfiguration(System.Label.GetCIBILReportAPI);
        Integer timeout = Integer.valueOf(apiConfiguration.Timeout__c);
        
        //if stubs checked in Integration_Configuration then stubs will return 
        if(apiConfiguration.IsStub_Required__c != null && apiConfiguration.IsStub_Required__c){  
            String stubData = IntegrationUtilities.getStubResponse(System.Label.GetCIBILReportAPI);
            return stubData == null ? System.Label.EmptyStubs : stubData;  
        }
        
        RequestWrapper requestWrapper = (RequestWrapper)IntegrationUtilities.parseJSONRequest(cibilRequestString,'RequestWrapper');
        dealId = requestWrapper.dealId;
        Applicant__c app = [SELECT Id,Contact_number__c,Opportunity__r.Lead_number__c,Opportunity__r.Agent_BL_code__c,Customer_First_Name__c,Opportunity__r.Loan_amount__c,
                                Customer_Last_Name__c,Loan_Amount__c,Current_Same_As_Permanent__c,Is_Existing_Customer__c,Applicant_Type__c,Name,
                                Opportunity__r.Product_Type__c,Father_s_name__c,Mother_s_name__c,Spouse_Name__c,Email_Id__c, 
                                Opportunity__r.account.name, applicant_number__c
                            FROM Applicant__c WHERE Id=:requestwrapper.applicantId WITH SECURITY_ENFORCED];
        List<Documents__c> docs = [SELECT Id,Document_Type__c,KYC_DOB__c,Gender__c,KYC_Address_Line_1__c,KYC_Address_Line_2__c,KYC_City__c,
                                   KYC_State__c,KYC_Pin_Code__c,Salutation__c,PAN_No__c,Passport_No__c,KYC_No__c,KYC_name__c,Proof_of_Identity_POI__c,recordtype.name  FROM Documents__c WHERE Applicant__c=:requestwrapper.applicantId AND Is_Active__c = true WITH SECURITY_ENFORCED];
        List<CIBIL_Details__c> cibilDetails = [Select Id,Name,Applicant__c,CIBIL_Report_URl__c,Equifax_Report_URl__c 
                                               FROM CIBIL_Details__c 
                                               WHERE Applicant__c=:requestwrapper.applicantId WITH SECURITY_ENFORCED Limit 1];
        
		List<Customer_dedupe_response__c> custDedupe=[Select Customer_Code__c from customer_dedupe_response__c where applicant__c=:requestWrapper.applicantId  WITH SECURITY_ENFORCED Limit 1];
        if(!custDedupe.isEmpty()){
                for(Customer_dedupe_response__c cust:custDedupe){        
                    customer_Code= cust.Customer_Code__c != null ? cust.Customer_Code__c : '';
                }    
		}
		else {
			customer_Code='';
		}
		
        loanAppId = requestWrapper.loanApplicationId;
        loanApplicationRef= requestWrapper.loanApplicationId;
        IND_CIBILRequest cibilreportRequest = IND_CIBILService.getcibilCallout(app,docs,loanAppId,cibilDetails, customer_Code, requestWrapper.cicNo);
        CalloutProcessor processor= new CalloutProcessor(System.Label.GetCIBILReportAPI, cibilreportRequest);
        HttpRequest request = processor.createHttpRequest();
        Long startTime = DateTime.now().getTime();
        List<Object> objList = new List<Object>();
        objList.add(app);
        Carrier carrier = new carrier();
        carrier.setServiceName(System.Label.GetCIBILReportAPI);
        carrier.setProcessor(processor);
        carrier.setRequest(IntegrationUtilities.getPlainTextForLog(request.getBody()));
        carrier.setEncryptedRequest(request.getBody());
        carrier.setStartTime(startTime);
        carrier.setLoanApplicationId(loanAppId); 
        carrier.setTempObject(objList);
        
        //Add callout request to continuation
        con = new Continuation(timeout);        
        con.continuationMethod='processCIBILReportResponse';
        con.state=carrier;
        con.addHttpRequest(request);
        
        if(Test.isRunningTest()) {
            continuationLabel = con.addHttpRequest(request);
            continuationState = carrier; 
        }  
    } catch(Exception ex) {
        ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'doCIBILReportCallout', System.Label.Apex, ex,loanAppId);
        throw ex;
    }
    return con;
}

/*
* @Method:      processCIBILReportResponse
* @Created by:  Divya Jawale
* @Description: Method to return Response for CIBIL Report API
* @Param:       Collection - labels
* @Param:       Object - state
* @Return:      Object - response
*/
@AuraEnabled(cacheable=true)
public static Object processCIBILReportResponse(List<String> labels, Object state){
    IND_CIBILResponse apiResponse;
    String request='';
    String encryptedRequest='';
    String serviceName='';
    String data='';
    HttpResponse response;
    String elapseTime='';
    List<Object> objList;
    String loanAppId='';
    
    try{
        Carrier carrier = (Carrier)state;
        request = carrier.getRequest();
        encryptedRequest = carrier.getEncryptedRequest();
        serviceName = carrier.getServiceName();
        Long startTime = carrier.getStartTime();
        objList = carrier.getTempObject();
        CalloutProcessor processor = carrier.getProcessor();
        response = Continuation.getResponse(labels[0]);
        Long endTime = DateTime.now().getTime();
        elapseTime = String.valueOf((Double)(endTime - startTime)/1000);
        loanAppId = carrier.getLoanApplicationId();
        if(response != null && (response.getStatusCode() == 200)){
            apiResponse = (IND_CIBILResponse)processor.getHttpResponse(response, serviceName);
            if(apiResponse!= null){
                IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, IntegrationUtilities.getPlainTextForLog(response.getBody()), response.getBody(), serviceName, elapseTime,loanAppId,System.Label.Success);
                data = JSON.serialize(apiResponse);
            }else {
                IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, '', '', serviceName, elapseTime,loanAppId,System.Label.Failure);
                throw new IND_Exception(System.Label.NoResponse);                
            }
        }
        else if(response != null && response.getStatusCode() == 400){
            
            String responseBody= '';
            String decryptedResponse='';
            Integration_Configuration__mdt apiConfiguration = IntegrationUtilities.getAPIConfiguration(serviceName);   
            responseBody = response.getBody();     
            responseBody = responseBody.substring(10, responseBody.length()-2);
            decryptedResponse = IntegrationUtilities.getDecryptedResponse(responseBody,System.Label.privateKey,System.Label.ivkey);
            
            String searalizedJson = JSON.serializePretty(JSON.deserializeUntyped(decryptedResponse));
            apiResponse = (IND_CIBILResponse)IntegrationUtilities.parseJSONResponse(searalizedJson, apiConfiguration.Response_wrapper__c);     
            if(apiResponse!= null){
                IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, IntegrationUtilities.getPlainTextForLog(response.getBody()), response.getBody(), serviceName, elapseTime,loanAppId,System.Label.Success);
                data = JSON.serialize(apiResponse);
            }else {
                IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, '', '', serviceName, elapseTime,loanAppId,System.Label.Failure);
                throw new IND_Exception(System.Label.NoResponse);                
            }
        }
        else {
            String errString = '[Status Code = '+ response.getStatusCode() +' ] Response-->'+IntegrationUtilities.getPlainTextForLog(response.getBody());
            IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, errString, response.getBody(), serviceName, elapseTime, loanAppId, System.Label.Failure);
            ErrorLoggerUtil.logErrorEvent('CalloutProcessor', 'getHttpResponse', System.Label.Apex, new IND_Exception(errString), loanAppId);
            throw new IND_Exception(System.Label.NoResponse);
        } 
    } catch (Exception ex){
        
        IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, '', '', serviceName, elapseTime,loanAppId,System.Label.Failure);
        ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'processCIBILReportResponse', System.Label.Apex, ex,loanAppId);
        throw new IND_Exception(ex.getMessage());
    }
    return data;
}
    
    /*
* @Method:      doUidaiOTPCallout
* @Created by:  Bhushan Charde
* @Description: Method to return Response for UIDAI OTP API
* @Param:       String - Applicant Id
* @Return:      String - reponse
*/
    @AuraEnabled(continuation=true cacheable=true)
    public static Object doUidaiOTPCallout(String kycUidaiRequestString){
        Continuation con;
        String loanAppId;
        try{
            if(String.isBlank(kycUidaiRequestString)){
                throw new IND_Exception(System.Label.Retry);
            }
            //Provide API-wise Integration Name to Custom Metadata Configs
            Integration_Configuration__mdt apiConfiguration = IntegrationUtilities.getAPIConfiguration(System.Label.UIDAIOTPAPI);
            
            //if stubs checked in Integration_Configuration then stubs will return 
            if(apiConfiguration.IsStub_Required__c != null && apiConfiguration.IsStub_Required__c){  
                String stubData = IntegrationUtilities.getStubResponse(System.Label.UIDAIOTPAPI);
                return stubData == null ? System.Label.EmptyStubs : stubData;  
            }
                       
            Integer timeout = Integer.valueOf(apiConfiguration.Timeout__c);
            RequestWrapper requestWrapper = (RequestWrapper)IntegrationUtilities.parseJSONRequest(kycUidaiRequestString,'RequestWrapper');
            List<Applicant__c> app = [SELECT Id,Opportunity__r.Lead_number__c FROM Applicant__c WHERE Id=:requestWrapper.applicantId WITH SECURITY_ENFORCED Limit 1];
            
            if(app.isEmpty()){
				throw new IND_Exception(System.Label.Applicantdatamissing);
            }else {
                for(Applicant__c applicant:app){
                    requestWrapper.leadId= applicant.Opportunity__r.Lead_Number__c;
                }
            }
            loanAppId = requestWrapper.loanApplicationId;
            loanApplicationRef= requestWrapper.loanApplicationId;
            IND_UidaiOTPRequest uidaiOtprequest = IND_UidaiOTPService.getUidaiOtpRequest(requestWrapper);
            CalloutProcessor processor= new CalloutProcessor(System.Label.UIDAIOTPAPI, uidaiOtprequest);
            HttpRequest request = processor.createHttpRequest();
            Long startTime = DateTime.now().getTime();
            
            Carrier carrier = new carrier();
            carrier.setServiceName(System.Label.UIDAIOTPAPI);
            carrier.setProcessor(processor);
            carrier.setRequest(IntegrationUtilities.getPlainTextForLog(request.getBody()));
            carrier.setEncryptedRequest(request.getBody());
            carrier.setStartTime(startTime);
            carrier.setLoanApplicationId(loanAppId);
            //Add callout request to continuation
            con = new Continuation(timeout);        
            con.continuationMethod='processUidaiOtpResponse';
            con.state=carrier;
            con.addHttpRequest(request);
            
            if(Test.isRunningTest()) {
               continuationLabel = con.addHttpRequest(request);
               continuationState = carrier; 
            }  
        } catch(Exception ex) {
            ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'doUidaiOTPCallout', System.Label.Apex, ex,loanAppId);
            throw ex;
        }
        return con;
    }
    
    /*
* @Method:      processUidaiOtpResponse
* @Created by:  Bhushan Charde 
* @Description: Method to return Response for UIDAI OTP API
* @Param:       Collection - labels
* @Param:       Object - state
* @Return:      Object - response
*/
    @AuraEnabled(cacheable=true)
    public static Object processUidaiOtpResponse(List<String> labels, Object state){
        String apiResponse;
        String request='';
        String encryptedRequest='';
        String serviceName='';
        String loanAppId='';
        String data='';
        HttpResponse response;
        String elapseTime='';
        
        try{
            Carrier carrier = (Carrier)state;
            request = carrier.getRequest();
            encryptedRequest = carrier.getEncryptedRequest();
            serviceName = carrier.getServiceName();
            Long startTime = carrier.getStartTime();
            
            CalloutProcessor processor = carrier.getProcessor();
            response = Continuation.getResponse(labels[0]);
            Long endTime = DateTime.now().getTime();
            elapseTime = String.valueOf((Double)(endTime - startTime)/1000);
            loanAppId = carrier.getLoanApplicationId();
            if(response != null && response.getStatusCode() == 200){
                apiResponse = processor.getHttpResponseForAll(response, serviceName);
                if(apiResponse !=null){
                    IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, IntegrationUtilities.getPlainTextForLog(response.getBody()), response.getBody(), serviceName, elapseTime,loanAppId,System.Label.Success);
                    data = JSON.serialize(apiResponse);
                } else {
                    IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, '', '', serviceName, elapseTime,loanAppId,System.Label.Failure);
                    throw new IND_Exception(System.Label.NoResponse);
                }
            } else {
                IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, '', response.getBody(), serviceName, elapseTime, loanAppId,System.Label.Failure);
                String errString = '[Status Code = '+ response.getStatusCode() +' ] Response-->'+IntegrationUtilities.getPlainTextForLog(response.getBody());
                ErrorLoggerUtil.logErrorEvent('CalloutProcessor', 'getHttpResponse', System.Label.Apex, new IND_Exception(errString), loanAppId);
                throw new IND_Exception(System.Label.NoResponse);
            }
            
        } catch (Exception ex){
            IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, '', '', serviceName, elapseTime,loanAppId,System.Label.Failure);
            ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'processUidaiOtpResponse', System.Label.Apex, ex,loanAppId);
            throw new IND_Exception(ex.getMessage());
        }
        return data;
    }
    
    /*
* @Method:      doUidaiOTPVerifyCallout
* @Created by:  Bhushan Charde
* @Description: Method to return Response for UIDAI OTP Verify API
* @Param:       String - Applicant Id
* @Return:      String - response
*/
    @AuraEnabled(continuation=true cacheable=true)
    public static Object doUidaiOTPVerifyCallout(String kycUidaiRequestString){
        Continuation con;
        String loanAppId;
        try{
            if(String.isBlank(kycUidaiRequestString)){
                throw new IND_Exception(System.Label.Retry);
            }
            //Provide API-wise Integration Name to Custom Metadata Configs
            Integration_Configuration__mdt apiConfiguration = IntegrationUtilities.getAPIConfiguration(System.Label.UIDAIOTPVERIFY);
            
            //if stubs checked in Integration_Configuration then stubs will return 
            if(apiConfiguration.IsStub_Required__c != null && apiConfiguration.IsStub_Required__c){  
                String stubData = IntegrationUtilities.getStubResponse(System.Label.UIDAIOTPVERIFY);
                return stubData == null ? System.Label.EmptyStubs : stubData;  
            }
            
            Integer timeout = Integer.valueOf(apiConfiguration.Timeout__c);
            
            RequestWrapper requestWrapper = (RequestWrapper)IntegrationUtilities.parseJSONRequest(kycUidaiRequestString,'RequestWrapper');
            List<Applicant__c> app = [SELECT Opportunity__r.Lead_Number__c FROM Applicant__c WHERE ID=:requestWrapper.applicantId WITH SECURITY_ENFORCED];
            
            if(app.isEmpty()){
                throw new IND_Exception(System.Label.Applicantdatamissing);
            }else {
                for(Applicant__c applicant:app){
                    requestWrapper.leadId= applicant.Opportunity__r.Lead_Number__c;
                }
            }
            
            loanAppId = requestWrapper.loanApplicationId;
            loanApplicationRef= requestWrapper.loanApplicationId;
            
            IND_UidaiOTPVerifyRequest uidaiOtpVerifyrequest = IND_UidaiOTPVerifyService.getUidaiOtpVerifyRequest(requestWrapper);
            CalloutProcessor processor= new CalloutProcessor(System.Label.UIDAIOTPVERIFY, uidaiOtpVerifyrequest);
            HttpRequest request = processor.createHttpRequest();
            Long startTime = DateTime.now().getTime();
            
            Carrier carrier = new carrier();
            carrier.setServiceName(System.Label.UIDAIOTPVERIFY);
            carrier.setProcessor(processor);
            carrier.setRequest(IntegrationUtilities.getPlainTextForLog(request.getBody()));
            carrier.setEncryptedRequest(request.getBody());
            carrier.setStartTime(startTime);
            carrier.setLoanApplicationId(loanAppId);    
            //Add callout request to continuation
            con = new Continuation(timeout);        
            con.continuationMethod='processUidaiOtpVerifyResponse';
            con.state=carrier;
            con.addHttpRequest(request);
            
            if(Test.isRunningTest()) {
               continuationLabel = con.addHttpRequest(request);
               continuationState = carrier; 
            }  
        } catch(Exception ex) {
            ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'doUidaiOTPVerifyCallout', System.Label.Apex, ex,loanAppId);
            throw ex;
        }
        return con;
    }
    
    /*
* @Method:      processUidaiOtpVerifyResponse
* @Created by:  Bhushan Charde 
* @Description: Method to return Response for UIDAI OTP Verify API
* @Param:       Collection - labels
* @Param:       Object - state
* @Return:      Object - response
*/
    @AuraEnabled(cacheable=true)
    public static Object processUidaiOtpVerifyResponse(List<String> labels, Object state){
        String apiResponse;
        String request='';
        String encryptedRequest='';
        String serviceName='';
        String loanAppId='';
        String data='';
        HttpResponse response;
        String elapseTime='';
        
        try{
            Carrier carrier = (Carrier)state;
            request = carrier.getRequest();
            encryptedRequest = carrier.getEncryptedRequest();
            serviceName = carrier.getServiceName();
            Long startTime = carrier.getStartTime();
            
            CalloutProcessor processor = carrier.getProcessor();
            response = Continuation.getResponse(labels[0]);
            Long endTime = DateTime.now().getTime();
            elapseTime = String.valueOf((Double)(endTime - startTime)/1000);
            loanAppId = carrier.getLoanApplicationId();
            if(response != null && response.getStatusCode() == 200){
                apiResponse = processor.getHttpResponseForAll(response, serviceName);
                if(apiResponse !=null){
                    IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, IntegrationUtilities.getPlainTextForLog(response.getBody()), response.getBody(), serviceName, elapseTime,loanAppId,System.Label.Success);
                    data = JSON.serialize(apiResponse);
                } else {
                    IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, '', '', serviceName, elapseTime,loanAppId,System.Label.Failure);
                    throw new IND_Exception(System.Label.NoResponse);
                }
            } else {
                IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, '', response.getBody(), serviceName, elapseTime, loanAppId,System.Label.Failure);
                String errString = '[Status Code = '+ response.getStatusCode() +' ] Response-->'+IntegrationUtilities.getPlainTextForLog(response.getBody());
                ErrorLoggerUtil.logErrorEvent('CalloutProcessor', 'getHttpResponse', System.Label.Apex, new IND_Exception(errString), loanAppId);
                throw new IND_Exception(System.Label.NoResponse);
            }
        } catch (Exception ex){
            IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, '', '', serviceName, elapseTime,loanAppId,System.Label.Failure);
            ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'processUidaiOtpResponse', System.Label.Apex, ex,loanAppId);
            throw new IND_Exception(ex.getMessage());
        }
        return data;
    }
    
    
    /*
* @Method:      doVehicleDedupeCallout
* @Created by:  Satyam More
* @Description: Continuation for Vehicle Dedupe API
* @Param:       String - vehicleDedupe
* @Return:      Object - continuation
*/
    
    @AuraEnabled(continuation=true cacheable=true)
    public static Object doVehicleDedupeCallout(String vehicleDedupe){
        Continuation con;
        String loanAppId;
        try{
            if(String.isBlank(vehicleDedupe)){
                throw new IND_Exception(System.Label.Retry);
            }
            //Provide API-wise Integration Name to Custom Metadata Configs
            Integration_Configuration__mdt apiConfiguration = IntegrationUtilities.getAPIConfiguration(System.Label.Vehicle_Dedupe);
            
            //if stubs checked in Integration_Configuration then stubs will return 
            if(apiConfiguration.IsStub_Required__c != null && apiConfiguration.IsStub_Required__c){  
                String stubData = IntegrationUtilities.getStubResponse(System.Label.Vehicle_Dedupe);
                return stubData == null ? System.Label.EmptyStubs : stubData;  
            }
            
            Integer timeout = Integer.valueOf(apiConfiguration.Timeout__c);
            RequestWrapper requestWrapper = (RequestWrapper)IntegrationUtilities.parseJSONRequest(vehicleDedupe,'RequestWrapper');
            
            loanAppId = requestWrapper.loanApplicationId;
            loanApplicationRef= requestWrapper.loanApplicationId;
            List<Opportunity> currentLoanApplication = [SELECT Id, leadSource, Vehicle_Type__c FROM Opportunity WHERE Id =: loanAppId ];
            if(currentLoanApplication.size() > 0 && currentLoanApplication[0].leadsource == 'D2C') {
                requestwrapper.category = currentLoanApplication[0].Vehicle_Type__c == 'Used' ? 'U' : (currentLoanApplication[0].Vehicle_Type__c == 'Refinance' ? 'R' : requestwrapper.category); 
            }
            IND_VehicleDedupeRequest vehiclededupeRequest = IND_VehicleDedupeService.getVehicleDedupeCallOutRequest(requestWrapper);
            CalloutProcessor processor= new CalloutProcessor(System.Label.Vehicle_Dedupe, vehiclededupeRequest);
            HttpRequest request = processor.createHttpRequest();
            Long startTime = DateTime.now().getTime();
            Carrier carrier = new carrier();
            carrier.setServiceName(System.Label.Vehicle_Dedupe);
            carrier.setProcessor(processor);
            carrier.setRequest(IntegrationUtilities.getPlainTextForLog(request.getBody()));
            carrier.setEncryptedRequest(request.getBody());
            carrier.setStartTime(startTime);  
            carrier.setLoanApplicationId(loanAppId);
            //Add callout request to continuation
            con = new Continuation(timeout);        
            con.continuationMethod='processVehicleDedupeCallOutResponse';
            con.state=carrier;
            con.addHttpRequest(request);
            
            if(Test.isRunningTest()) {
               continuationLabel = con.addHttpRequest(request);
               continuationState = carrier; 
            }  
        } catch(Exception ex) {
            ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'doVehicleDedupeCallout', System.Label.Apex, ex, loanAppId);
            throw ex;
        }
        return con;
    }
    
    
    /*
* @Method:      processVehicleDedupeCallOutResponse
* @Created by:  Satyam More 
* @Description: Callback method to return Response for Vehicle Dedupe API
* @Param:       Collection - labels
* @Param:       Object - state
* @Return:      Object - response
*/
    @AuraEnabled(cacheable=true)
    public static Object processVehicleDedupeCallOutResponse(List<String> labels, Object state){
        IND_VehicleDedupeResponse apiResponse;
        String request='';
        String encryptedRequest='';
        String serviceName='';
        String loanAppId='';
        String data='';
        HttpResponse response;
        String elapseTime='';        
        try{            
            Carrier carrier = (Carrier)state;
            request = carrier.getRequest();
            encryptedRequest = carrier.getEncryptedRequest();
            serviceName = carrier.getServiceName();
            Long startTime = carrier.getStartTime();            
            CalloutProcessor processor = carrier.getProcessor();
            response = Continuation.getResponse(labels[0]);
            Long endTime = DateTime.now().getTime();
            elapseTime = String.valueOf((Double)(endTime - startTime)/1000);
            loanAppId = carrier.getLoanApplicationId();
            if(response != null && response.getStatusCode() == 200){
                apiResponse = (IND_VehicleDedupeResponse)processor.getHttpResponse(response, serviceName);
                
                if(apiResponse!=null){
                    IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, IntegrationUtilities.getPlainTextForLog(response.getBody()), response.getBody(), serviceName, elapseTime,loanAppId,System.Label.Success);
                    return JSON.serialize(apiResponse);
                } else {
                    IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, IntegrationUtilities.getPlainTextForLog(response.getBody()), response.getBody(), serviceName, elapseTime,loanAppId,System.Label.Failure);
                    throw new IND_Exception(System.Label.NoResponse);                
                }
            }
            else {
                String errString = '[Status Code = '+ response.getStatusCode() +' ] Response-->'+IntegrationUtilities.getPlainTextForLog(response.getBody());
                IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, errString, response.getBody(), serviceName, elapseTime, loanAppId, System.Label.Failure);
                ErrorLoggerUtil.logErrorEvent('CalloutProcessor', 'getHttpResponse', System.Label.Apex, new IND_Exception(errString), loanAppId);
                throw new IND_Exception(System.Label.NoResponse);
            } 
        } catch (Exception ex){
            IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, '', '', serviceName, elapseTime,loanAppId,System.Label.Failure);
            ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'processVehicleDedupeCallOutResponse', System.Label.Apex, ex,loanAppId);
            throw new IND_Exception(ex.getMessage());
        }
    }
    /*
* @Method:      doExternalDedupeCallout
* @Created by:  Divya Jawale 
* @Description: Method to return Response for External Customer Dedupe API
* @Param:       Id - Applicant Id
* @Return:      String - response
*/
    @AuraEnabled(continuation=true cacheable=false)
    public static Object doExternalDedupeCallout(String externalDedupeRequestString){
        Continuation con;
        String loanAppId;
        try{
            if(String.isBlank(externalDedupeRequestString)){
                throw new IND_Exception(System.Label.Retry);
            }
            //Provide API-wise Integration Name to Custom Metadata Configs
            Integration_Configuration__mdt apiConfiguration = IntegrationUtilities.getAPIConfiguration(System.Label.ExternalCustomerDedupeAPI);
            Integer timeout = Integer.valueOf(apiConfiguration.Timeout__c);
            if(apiConfiguration.IsStub_Required__c != null && apiConfiguration.IsStub_Required__c){  
                 String stubData = IntegrationUtilities.getStubResponse(System.Label.ExternalCustomerDedupeAPI);
                return stubData == null ? System.Label.EmptyStubs : stubData;  
            }
            RequestWrapper requestWrapper = (RequestWrapper)IntegrationUtilities.parseJSONRequest(externalDedupeRequestString,'RequestWrapper');
            Applicant__c app = [SELECT Id,Applicant_Type__c,applicant_number__c,Opportunity__r.Lead_number__c,
                                Opportunity__r.Customer_Code__c,Customer_First_Name__c,Customer_Last_Name__c,Contact_number__c,PAN_No__c,
                                Passport_No__c,Driving_License_No__c,Voter_ID_No__c,Aadhar_No__c,Father_s_name__c,Mother_s_name__c,Spouse_Name__c, Opportunity__r.Product_Type__c,Whatsapp_number__c
                                FROM Applicant__c WHERE ID=:requestwrapper.applicantId WITH SECURITY_ENFORCED]; //CISP-2879 added applicant_number__c
            List<Documents__c> docs = [SELECT Id,IND_Aadhaar_Vault_Token_ID__c,KYC_name__c,Document_Type__c,KYC_DOB__c,Gender__c,KYC_Address_Line_1__c,KYC_Address_Line_2__c,KYC_City__c,KYC_District__c,PAN_No__c,KYC_No__c,Passport_No__c,
                                       KYC_State__c,KYC_Pin_Code__c, Aadhaar_Enrollment_Number__c,Salutation__c FROM Documents__c WHERE Applicant__c=:requestWrapper.applicantId and recordtype.name='KYC Document' WITH SECURITY_ENFORCED];
            
            loanAppId = requestWrapper.loanApplicationId;
            loanApplicationRef= requestWrapper.loanApplicationId;
            IND_ExternalCustomerDedupeAPIRequest externalDedupeRequest = IND_ExternalCustomerDedupeAPIService.getExternalDedupeCallout(app,docs,loanAppId);
            CalloutProcessor processor= new CalloutProcessor(System.Label.ExternalCustomerDedupeAPI, externalDedupeRequest);
            HttpRequest request = processor.createHttpRequest();
            Long startTime = DateTime.now().getTime();
            List<Object> objList = new List<Object>();
            objList.add(app);
            Carrier carrier = new carrier();
            carrier.setServiceName(System.Label.ExternalCustomerDedupeAPI);
            carrier.setProcessor(processor);
            carrier.setRequest(IntegrationUtilities.getPlainTextForLog(request.getBody()));
            carrier.setEncryptedRequest(request.getBody());
            carrier.setStartTime(startTime);
            carrier.setLoanApplicationId(loanAppId);     
            carrier.setTempObject(objList);
            
            //Add callout request to continuation
            con = new Continuation(timeout);        
            con.continuationMethod='processExternalDedupeResponse';
            con.state=carrier;
            con.addHttpRequest(request);
            
            if(Test.isRunningTest()) {
               continuationLabel = con.addHttpRequest(request);
               continuationState = carrier; 
            }  
        } catch(Exception ex) {
            ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'doExternalDedupeCallout', System.Label.Apex, ex,loanAppId);
            throw ex;
        }
        return con;
    }
    
    /*
* @Method:      processExternalDedupeResponse
* @Created by:  Divya Jawale
* @Description: Method to return Response for Deal Eligible Refinance API
* @Param:       Collection - labels
* @Param:       Object - state
* @Return:      Object - response
*/
    @AuraEnabled(cacheable=false)
    public static Object processExternalDedupeResponse(List<String> labels, Object state){
        String apiResponse;
        String request=''; 
        String responseBody='';
        String encryptedRequest='';
        String serviceName='';
        String loanAppId='';
        String data='';
        HttpResponse response;
        String elapseTime='';
        List<Object> objList;        
        try{
            Carrier carrier = (Carrier)state;
            request = carrier.getRequest();
            encryptedRequest = carrier.getEncryptedRequest();
            serviceName = carrier.getServiceName();
            Long startTime = carrier.getStartTime();
            objList = carrier.getTempObject();
            CalloutProcessor processor = carrier.getProcessor();
            response = Continuation.getResponse(labels[0]);
            Long endTime = DateTime.now().getTime();
            elapseTime = String.valueOf((Double)(endTime - startTime)/1000);
            loanAppId = carrier.getLoanApplicationId();
            Map <String,String> dedupeResponse;
            String status = System.Label.Failure;
            if(response != null){ 
                if(response.getStatusCode()==200){
                  status=System.Label.Success;  
                  responseBody = response.getBody(); 
                  system.debug('The Response Body '+ response);
                  responseBody = responseBody.substring(10, responseBody.length()-2); 
                  Map <String,Object> jsonRequestMap =(Map <String,Object>) JSON.deserializeUntyped(request);
                  String cicNo =(String)jsonRequestMap.get('CIC_No');             
                  String decryptedResponse = IntegrationUtilities.getDecryptedResponse(responseBody,System.Label.privateKey,System.Label.ivkey);
                  apiResponse = JSON.serializePretty(JSON.deserializeUntyped(decryptedResponse));
                  IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, IntegrationUtilities.getPlainTextForLog(response.getBody()), response.getBody(), serviceName, elapseTime,loanAppId,status);
                  dedupeResponse = new Map<String,String>();
                  dedupeResponse.put('cicNo', cicNo);
                  dedupeResponse.put('Response', apiResponse);
                  return dedupeResponse;
                }else{
                    IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, IntegrationUtilities.getPlainTextForLog(response.getBody()), response.getBody(), serviceName, elapseTime,loanAppId,System.Label.Failure);
                 //   ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'processExternalDedupeResponse', System.Label.Apex, '',loanAppId);
                    throw new IND_Exception(System.Label.NoResponse);
                }
            }
            else {
                IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, IntegrationUtilities.getPlainTextForLog(response.getBody()), response.getBody(), serviceName, elapseTime,loanAppId,status);
                throw new IND_Exception(System.Label.NoResponse);
            } 
        } catch (Exception ex){
            
            IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, IntegrationUtilities.getPlainTextForLog(response.getBody()), response.getBody(), serviceName, elapseTime,loanAppId,System.Label.Failure);
            ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'processExternalDedupeResponse', System.Label.Apex, ex,loanAppId);
            throw new IND_Exception(ex.getMessage());
        }
    }
    
     /*
* @Method:      doPANCallout
* @Created by:  Satyam More
* @Description: Continuation for Pan Verification API
* @Param:       String - kycPanDetailRequest
* @Return:      Object - response
*/
    
@AuraEnabled(continuation=true cacheable=true)
public static Object doPANCallout(String kycPanDetailRequest){
    Continuation con;
    String loanAppId;
    try{
        if(String.isBlank(kycPanDetailRequest)){
            throw new IND_Exception(System.Label.Retry);
        }
        //Provide API-wise Integration Name to Custom Metadata Configs
        Integration_Configuration__mdt apiConfiguration = IntegrationUtilities.getAPIConfiguration(System.Label.PANVerificationAPI);
        Integer timeout = Integer.valueOf(apiConfiguration.Timeout__c);
        
        //if stubs checked in Integration_Configuration then stubs will return 
        if(apiConfiguration.IsStub_Required__c != null && apiConfiguration.IsStub_Required__c){  
            String stubData = IntegrationUtilities.getStubResponse(System.Label.PANVerificationAPI);
            return stubData == null ? System.Label.EmptyStubs : stubData;  
        }
        
        RequestWrapper requestWrapper = (RequestWrapper)IntegrationUtilities.parseJSONRequest(kycPanDetailRequest,'RequestWrapper');
        List<Applicant__c> app = [SELECT Opportunity__r.Lead_number__c,applicant_number__c FROM Applicant__c WHERE Id=:requestWrapper.applicantId WITH SECURITY_ENFORCED Limit 1];//CISP-2879
        if(!app.isEmpty()){
            for(Applicant__c applicant:app){
                requestWrapper.leadId= applicant.Opportunity__r.Lead_Number__c + '_' + applicant.applicant_number__c; //CISP-2879
            }
        }
        else{   
            throw new IND_Exception(System.Label.ApplicantDataMissing);
        }
        loanAppId = requestWrapper.loanApplicationId;
        loanApplicationRef= requestWrapper.loanApplicationId;
        IND_PanVerificationRequest panRequest = IND_PanVerificationService.getPANVerificationCallOutRequest(requestWrapper);
        
        CalloutProcessor processor= new CalloutProcessor(System.Label.PANVerificationAPI, panRequest);
        HttpRequest request = processor.createHttpRequest();
        Long startTime = DateTime.now().getTime();
        
        Carrier carrier = new carrier();
        carrier.setServiceName(System.Label.PANVerificationAPI);
        carrier.setProcessor(processor);
        carrier.setRequest(IntegrationUtilities.getPlainTextForLog(request.getBody()));
        carrier.setEncryptedRequest(request.getBody());
        carrier.setStartTime(startTime);   
        carrier.setLoanApplicationId(loanAppId);
        //Add callout request to continuation
        con = new Continuation(timeout);        
        con.continuationMethod='processPANVerficationResponse';
        con.state=carrier;
        con.addHttpRequest(request);
        
        if(Test.isRunningTest()) {
           continuationLabel = con.addHttpRequest(request);
           continuationState = carrier; 
        }  
    } catch(Exception ex) {
        ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'doPANCallout', System.Label.Apex, ex,loanAppId);
        throw ex;
    }
    return con;
}

/*
* @Method:      processPANVerficationResponse
* @Created by:  Satyam More 
* @Description: Method to return Response for SMS Getway API
* @Param:       Collection - labels
* @Param:       Object - state
* @Return:      Object - response
*/
@AuraEnabled(cacheable=true)
public static Object processPANVerficationResponse(List<String> labels, Object state){
    System.debug('callback()====');
    IND_PanVerificationResponse apiResponse;
    String request='';
    String encryptedRequest='';
    String serviceName='';
    String loanAppId='';
    String data='';
    HttpResponse response;
    String elapseTime='';
    
    try{
        Carrier carrier = (Carrier)state;
        request = carrier.getRequest();
        encryptedRequest = carrier.getEncryptedRequest();
        serviceName = carrier.getServiceName();
        Long startTime = carrier.getStartTime();
        
        CalloutProcessor processor = carrier.getProcessor();
        response = Continuation.getResponse(labels[0]);
        
        Long endTime = DateTime.now().getTime();
        elapseTime = String.valueOf((Double)(endTime - startTime)/1000);
        loanAppId = carrier.getLoanApplicationId();
        if(response != null && response.getStatusCode() == 200){
         apiResponse = (IND_PanVerificationResponse)processor.getHttpResponse(response, serviceName);
            if(apiResponse!=null){ 
                IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, IntegrationUtilities.getPlainTextForLog(response.getBody()), response.getBody(), serviceName, elapseTime,loanAppId,System.Label.Success);
                return  JSON.serialize(apiResponse);
            }
            else {
                IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, IntegrationUtilities.getPlainTextForLog(response.getBody()), response.getBody(), serviceName, elapseTime,loanAppId,System.Label.Failure);
                throw new IND_Exception(System.Label.NoResponse);                
            }
        }
        else {
            String errString = '[Status Code = '+ response.getStatusCode() +' ] Response-->'+IntegrationUtilities.getPlainTextForLog(response.getBody());
            IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, errString, response.getBody(), serviceName, elapseTime, loanAppId, System.Label.Failure);
            ErrorLoggerUtil.logErrorEvent('CalloutProcessor', 'getHttpResponse', System.Label.Apex, new IND_Exception(errString), loanAppId);
            throw new IND_Exception(System.Label.NoResponse);
        } 
    } catch (Exception ex){
        IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, '', '', serviceName, elapseTime,loanAppId, System.Label.Failure);
        ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'processPANVerficationResponse', System.Label.Apex, ex,loanAppId);
        throw new IND_Exception(ex.getMessage());
    }
    
}
    
     /*
* @Method:      doPPCallout
* @Created by:  Aman Mundhada
* @Description: Continuation for Golden-Source Passport API
* @Param:       String - kycFieldsPassportIdString
* @Return:      Object - continuation
*/
@AuraEnabled(continuation=true cacheable=true)
public static Object doPPCallout(String kycFieldsPassportIdString){
    Continuation con;
    String loanAppId;
    try{
        if(String.isBlank(kycFieldsPassportIdString)){
            throw new IND_Exception(System.Label.Retry);
        }         
        //Provide API-wise Integration Name to Custom Metadata Configs
        Integration_Configuration__mdt apiConfiguration = IntegrationUtilities.getAPIConfiguration(System.Label.PassportAPI);
        Integer timeout = Integer.valueOf(apiConfiguration.Timeout__c);
        
        //if stubs checked in Integration_Configuration then stubs will return 
        if(apiConfiguration.IsStub_Required__c != null && apiConfiguration.IsStub_Required__c){  
            String stubData = IntegrationUtilities.getStubResponse(System.Label.PassportAPI);
            return stubData == null ? System.Label.EmptyStubs : stubData;  
        }
        
        RequestWrapper requestWrapper = (RequestWrapper)IntegrationUtilities.parseJSONRequest(kycFieldsPassportIdString,'RequestWrapper');
        List<Applicant__c> app = [SELECT Opportunity__r.Lead_Number__c FROM Applicant__c WHERE ID=:requestWrapper.applicantId WITH SECURITY_ENFORCED Limit 1];
        if(!app.isEmpty()){
            for(Applicant__c applicant:app){
                requestWrapper.leadId= applicant.Opportunity__r.Lead_Number__c;
            }
        }
        else{
            throw new IND_Exception(System.Label.Applicantdatamissing);
        }
        loanAppId = requestWrapper.loanApplicationId;
        loanApplicationRef= requestWrapper.loanApplicationId;
        IND_PassportRequest ppRequest = IND_PassportService.getPPCallOutRequest(requestWrapper);
        CalloutProcessor processor= new CalloutProcessor(System.Label.PassportAPI, ppRequest);
        HttpRequest request = processor.createHttpRequest();
        Long startTime = DateTime.now().getTime();
        Carrier carrier = new carrier();
        carrier.setServiceName(System.Label.PassportAPI);
        carrier.setProcessor(processor);
        carrier.setRequest(IntegrationUtilities.getPlainTextForLog(request.getBody()));
        carrier.setEncryptedRequest(request.getBody());
        carrier.setStartTime(startTime);            
        carrier.setLoanApplicationId(loanAppId);
        //Add callout request to continuation
        con = new Continuation(timeout);        
        con.continuationMethod='processPPCallOutResponse';
        con.state=carrier;
        con.addHttpRequest(request);
        
        if(Test.isRunningTest()) {
           continuationLabel = con.addHttpRequest(request);
           continuationState = carrier; 
        }  
    } catch(Exception ex) {
        ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'doPPCallout', System.Label.Apex, ex,loanAppId);
        throw ex;
    }
    return con;
}


/*
* @Method:      processPPCallOutResponse
* @Created by:  Aman Mundhada 
* @Description: Callback method to return Response for Golden Source-Passport API
* @Param:       Collection - labels
* @Param:       Object - state
* @Return:      Object - response
*/
@AuraEnabled(cacheable=true)
public static Object processPPCallOutResponse(List<String> labels, Object state){
    IND_PassportResponse apiResponse;
    String request='';
    String encryptedRequest='';
    String serviceName='';
    String loanAppId='';
    HttpResponse response;
    String elapseTime='';        
    try{            
        Carrier carrier = (Carrier)state;
        request = carrier.getRequest();
        encryptedRequest = carrier.getEncryptedRequest();
        serviceName = carrier.getServiceName();
        Long startTime = carrier.getStartTime();            
        CalloutProcessor processor = carrier.getProcessor();
        response = Continuation.getResponse(labels[0]);
        Long endTime = DateTime.now().getTime();
        elapseTime = String.valueOf((Double)(endTime - startTime)/1000);
        loanAppId = carrier.getLoanApplicationId();
        if(response != null && response.getStatusCode() == 200){
            apiResponse = (IND_PassportResponse)processor.getHttpResponse(response, serviceName);
           if(apiResponse!=null){
                IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, IntegrationUtilities.getPlainTextForLog(response.getBody()), response.getBody(), serviceName, elapseTime,loanAppId,System.Label.Success);
                return JSON.serialize(apiResponse);
            } else {
                IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, IntegrationUtilities.getPlainTextForLog(response.getBody()), response.getBody(), serviceName, elapseTime,loanAppId,System.Label.Failure);
                throw new IND_Exception(System.Label.NoResponse);                
            }
        }    
        else {
            String errString = '[Status Code = '+ response.getStatusCode() +' ] Response-->'+IntegrationUtilities.getPlainTextForLog(response.getBody());
            IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, errString, response.getBody(), serviceName, elapseTime, loanAppId, System.Label.Failure);
            ErrorLoggerUtil.logErrorEvent('CalloutProcessor', 'getHttpResponse', System.Label.Apex, new IND_Exception(errString), loanAppId);
            throw new IND_Exception(System.Label.NoResponse);
        } 
    } catch (Exception ex){
        IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, '', '', serviceName, elapseTime,loanAppId,System.Label.Failure);
        ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'processPPCallOutResponse', System.Label.Apex, ex,loanAppId);
        throw new IND_Exception(ex.getMessage());
    }
}
    
    
    /*
* @Method:      doDLCallout
* @Created by:  Aman Mundhada
* @Description: Continuation for Golden-Source Driving Licence API
* @Param:       String - kycDlDetailRequest
* @Return:      Object - continuation
*/
@AuraEnabled(continuation=true cacheable=true)
public static Object doDLCallout(String kycDlDetailRequest){
    Continuation con;
    String loanAppId;
    try{
        if(String.isBlank(kycDlDetailRequest)){
            throw new IND_Exception(System.Label.Retry);
        }
        //Provide API-wise Integration Name to Custom Metadata Configs
        Integration_Configuration__mdt apiConfiguration = IntegrationUtilities.getAPIConfiguration(System.Label.Driving_License);
        Integer timeout = Integer.valueOf(apiConfiguration.Timeout__c); 
        
        //if stubs checked in Integration_Configuration then stubs will return 
        if(apiConfiguration.IsStub_Required__c != null && apiConfiguration.IsStub_Required__c){  
            String stubData = IntegrationUtilities.getStubResponse(System.Label.Driving_License);
            return stubData == null ? System.Label.EmptyStubs : stubData;  
        }
        
        RequestWrapper requestWrapper = (RequestWrapper)IntegrationUtilities.parseJSONRequest(kycDlDetailRequest,'RequestWrapper');
        List<Applicant__c> app = [SELECT Opportunity__r.Lead_Number__c FROM Applicant__c WHERE ID=:requestWrapper.applicantId WITH SECURITY_ENFORCED Limit 1];          
        if(!app.isEmpty()){
            for(Applicant__c applicant:app){
                requestWrapper.leadId= applicant.Opportunity__r.Lead_Number__c;
            }
        }
        else{   
            throw new IND_Exception(System.Label.ApplicantDataMissing);
        }
        loanAppId = requestWrapper.loanApplicationId;
        loanApplicationRef= requestWrapper.loanApplicationId;
        IND_DrivingLicenseRequest dlRequest = IND_DrivingLicenseService.getDlCallOutRequest(requestWrapper);
        CalloutProcessor processor= new CalloutProcessor(System.Label.Driving_License, dlRequest);
        HttpRequest request = processor.createHttpRequest();
        Long startTime = DateTime.now().getTime();            
        Carrier carrier = new carrier();
        carrier.setServiceName(System.Label.Driving_License);
        carrier.setProcessor(processor);
        carrier.setRequest(IntegrationUtilities.getPlainTextForLog(request.getBody()));
        carrier.setEncryptedRequest(request.getBody());
        carrier.setStartTime(startTime);
        carrier.setLoanApplicationId(loanAppId);         
        //Add callout request to continuation
        con = new Continuation(timeout);        
        con.continuationMethod='processDLCallOutResponse';
        con.state=carrier;
        con.addHttpRequest(request);
        
        if(Test.isRunningTest()) {
           continuationLabel = con.addHttpRequest(request);
           continuationState = carrier; 
        }  
    } catch(Exception ex) {
        ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'doDLCallout', System.Label.Apex, ex, loanAppId);
        throw ex;
    }
    return con;
}


/*
* @Method:      processDLCallOutResponse
* @Created by:  Aman Mundhada 
* @Description: Method to return Response for Golden Source-Driving License API
* @Param:       Collection - labels
* @Param:       Object - state
* @Return:      Object - response
*/
@AuraEnabled(cacheable=true)
public static Object processDLCallOutResponse(List<String> labels, Object state){
    IND_DrivingLicenseResponse apiResponse;
    String request='';
    String encryptedRequest='';
    String serviceName='';
    String loanAppId='';
    HttpResponse response;
    String elapseTime='';
    try{
        Carrier carrier = (Carrier)state;
        request = carrier.getRequest();
        encryptedRequest = carrier.getEncryptedRequest();
        serviceName = carrier.getServiceName();
        Long startTime = carrier.getStartTime();           
        CalloutProcessor processor = carrier.getProcessor();
        response = Continuation.getResponse(labels[0]);
        Long endTime = DateTime.now().getTime();
        elapseTime = String.valueOf((Double)(endTime - startTime)/1000);
        loanAppId = carrier.getLoanApplicationId();
        if(response != null && response.getStatusCode() == 200){               
            apiResponse = (IND_DrivingLicenseResponse)processor.getHttpResponse(response, serviceName);               
            if(apiResponse!=null){
                IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, IntegrationUtilities.getPlainTextForLog(response.getBody()), response.getBody(), serviceName, elapseTime, loanAppId,System.Label.Success);
                return JSON.serialize(apiResponse);
            } else {
                IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, IntegrationUtilities.getPlainTextForLog(response.getBody()), response.getBody(), serviceName, elapseTime, loanAppId,System.Label.Failure);
                throw new IND_Exception(System.Label.NoResponse);                
            }
        }
        else {
            String errString = '[Status Code = '+ response.getStatusCode() +' ] Response-->'+IntegrationUtilities.getPlainTextForLog(response.getBody());
            IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, errString, response.getBody(), serviceName, elapseTime, loanAppId, System.Label.Failure);
            ErrorLoggerUtil.logErrorEvent('CalloutProcessor', 'getHttpResponse', System.Label.Apex, new IND_Exception(errString), loanAppId);
            throw new IND_Exception(System.Label.NoResponse);
        } 
    } catch (Exception ex){
        IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, '', '', serviceName, elapseTime, loanAppId, System.Label.Failure);
        ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'processDLCallOutResponse', System.Label.Apex, ex, loanAppId);
        throw new IND_Exception(ex.getMessage());
    }
}
    
    /*
* @Method:      doDocAuthCreateApplicantCallout
* @Created by:  Satyam More 
* @Description: Method to return Response for Doc Auth Create Applicant API
* @Param:       String - Applicant Id
* @Return:      String - response
*/
    
    @AuraEnabled(continuation=true cacheable=true)
    public static Object doDocAuthCreateApplicantCallout(String applicantId,String loanAppId){
        Continuation con;
        try{
            if(String.isBlank(applicantId)){
                throw new IND_Exception(System.Label.Retry);
            }
            //Provide API-wise Integration Name to Custom Metadata Configs
            Integration_Configuration__mdt apiConfiguration = IntegrationUtilities.getAPIConfiguration(System.Label.CreateApplicant);
            Integer timeout = Integer.valueOf(apiConfiguration.Timeout__c);
            
            //if stubs checked in Integration_Configuration then stubs will return 
            if(apiConfiguration.IsStub_Required__c != null && apiConfiguration.IsStub_Required__c){  
                String stubData = IntegrationUtilities.getStubResponse(System.Label.CreateApplicant);
                return stubData == null ? System.Label.EmptyStubs : stubData;  
            }
            
            Applicant__c app = [SELECT Id, applicant_number__c,Opportunity__r.Lead_Number__c, Customer_First_Name__c, Customer_Last_Name__c,Opportunity__r.Customer_Type__c,Opportunity__r.Product_Type__c,Applicant_Type__c FROM Applicant__c WHERE ID=:applicantId WITH SECURITY_ENFORCED Limit 1];//CISP-2879
            
            loanApplicationRef= loanAppId;
            IND_DocAuthCreateApplicantRequest docAuthCreateApplicantRequest = IND_DocAuthCreateApplicantService.getDocAuthCreateApplicantCallOutRequest(app,loanAppId);
            CalloutProcessor processor= new CalloutProcessor(System.Label.CreateApplicant, docAuthCreateApplicantRequest);
            HttpRequest request = processor.createHttpRequest();
            Long startTime = DateTime.now().getTime();
            List<Object> objList = new List<Object>();
            objList.add(app);
            Carrier carrier = new carrier();
            carrier.setServiceName(System.Label.CreateApplicant);
            carrier.setProcessor(processor);
            carrier.setRequest(IntegrationUtilities.getPlainTextForLog(request.getBody()));
            carrier.setEncryptedRequest(request.getBody());
            carrier.setStartTime(startTime);
            carrier.setLoanApplicationId(loanAppId);
            carrier.setTempObject(objList);
            
            //Add callout request to continuation
            con = new Continuation(timeout);        
            con.continuationMethod='processDocAuthCreateApplicantResponse';
            con.state=carrier;
            con.addHttpRequest(request);
            
            if(Test.isRunningTest()) {
               continuationLabel = con.addHttpRequest(request);
               continuationState = carrier; 
            }  
        } catch(Exception ex) {
            ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'doDocAuthCreateApplicantCallout', System.Label.Apex, ex, loanAppId);
            throw ex;
        }
        return con;
    }
    
    /*
* @Method:      processDocAuthCreateApplicantResponse
* @Created by:  Satyam More 
* @Description: Method to return Response for Doc Auth Create Applicant API
* @Param:       Collection - labels
* @Param:       Object - state
* @Return:      Object - response
*/
    @AuraEnabled(cacheable=false)
    public static Object processDocAuthCreateApplicantResponse(List<String> labels, Object state){
        IND_DocAuthCreateApplicantResponse apiResponse;
        String request='';
        String encryptedRequest='';
        String serviceName='';
        String loanAppId='';
        String data='';
        HttpResponse response;
        String elapseTime='';
        List<Object> objList;
        
        try{
            Carrier carrier = (Carrier)state;
            request = carrier.getRequest();
            encryptedRequest = carrier.getEncryptedRequest();
            serviceName = carrier.getServiceName();
            Long startTime = carrier.getStartTime();
            objList = carrier.getTempObject();
            CalloutProcessor processor = carrier.getProcessor();
            response = Continuation.getResponse(labels[0]);
            Long endTime = DateTime.now().getTime();
            elapseTime = String.valueOf((Double)(endTime - startTime)/1000);
            loanAppId = carrier.getLoanApplicationId();
            
            if(response != null){
                Applicant__c app = (Applicant__c)objList.get(0);
                apiResponse = (IND_DocAuthCreateApplicantResponse)processor.getHttpResponse(response, serviceName);
                
                if(apiResponse.ResponseData != null && apiResponse.ResponseData.status == 'SUCCESS'){
                    //data = apiResponse.response.status;
                    List<Sobject> objectsToUpdate = new List<Sobject>();
                    if(apiResponse.ResponseData.Fields!=null){
                        app.DocAuth_Application_Id__c = apiResponse.ResponseData.Fields.ApplicationId;
                        //objectsToUpdate.add(app);
                        // update app;
                    }
                    data = JSON.serialize(apiResponse);
                    IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, IntegrationUtilities.getPlainTextForLog(response.getBody()), response.getBody(), serviceName, elapseTime, loanAppId, System.Label.Success);
                }
                else {
                    IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, '', '', serviceName, elapseTime, loanAppId, System.Label.Failure);
                    throw new IND_Exception(System.Label.NoResponse);                
                }
            }
            else {
                String errString = '[Status Code = '+ response.getStatusCode() +' ] Response-->'+IntegrationUtilities.getPlainTextForLog(response.getBody());
                IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, errString, response.getBody(), serviceName, elapseTime, loanAppId, System.Label.Failure);
                ErrorLoggerUtil.logErrorEvent('CalloutProcessor', 'getHttpResponse', System.Label.Apex, new IND_Exception(errString), loanAppId);
                throw new IND_Exception(System.Label.NoResponse);
            } 
        } catch (Exception ex){
            IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, '', '', serviceName, elapseTime,loanAppId, System.Label.Failure);
            ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'processDocAuthCreateApplicantResponse', System.Label.Apex, ex,loanAppId);
            throw new IND_Exception(ex.getMessage());
        }
        return data;
    }
    
    
   /*
* @Method:      doValidateRecentLeadCallout
* @Created by:  Divya Jawale 
* @Description: Method to return Response for Validate Recent Lead API
* @Param:       String - Applicant Id
* @Return:      String - reponse
*/
    @AuraEnabled(continuation=true cacheable=true)
    public static Object doValidateRecentLeadCallout(String sCICNo,String sLeadNo,String loanApplicationId,String applicantId){  
        Continuation con;
        
        try{
            //Provide API-wise Integration Name to Custom Metadata Configs
            Integration_Configuration__mdt apiConfiguration = IntegrationUtilities.getAPIConfiguration(System.Label.ValidateRecentLead);
            Integer timeout = Integer.valueOf(apiConfiguration.Timeout__c);
            
            //if stubs checked in Integration_Configuration then stubs will return 
            if(apiConfiguration.IsStub_Required__c != null && apiConfiguration.IsStub_Required__c){  
                String stubData = IntegrationUtilities.getStubResponse(System.Label.ValidateRecentLead);
                return stubData == null ? System.Label.EmptyStubs : stubData;  
            }
            
            loanApplicationRef= loanApplicationId;
            List<Applicant__c> appList = [Select Id ,applicant_number__c from Applicant__c where Id =: applicantId limit 1];
            if(!appList.isEmpty()){
                sLeadNo = sLeadNo + '_' + appList[0].applicant_number__c;
            }
            IND_ValidateRecentLeadRequest validateRecentLeadRequest = IND_ValidateRecentLeadService.getValidateRecentLeadRequest(sCICNo, sLeadNo,loanApplicationId);
            CalloutProcessor processor= new CalloutProcessor(System.Label.ValidateRecentLead, validateRecentLeadRequest);
            HttpRequest request = processor.createHttpRequest();
            Long startTime = DateTime.now().getTime();
            
            Carrier carrier = new carrier();
            carrier.setServiceName(System.Label.ValidateRecentLead);
            carrier.setProcessor(processor);
            carrier.setRequest(IntegrationUtilities.getPlainTextForLog(request.getBody()));
            carrier.setEncryptedRequest(request.getBody());
            carrier.setStartTime(startTime);   
            carrier.setLoanApplicationId(loanApplicationId); 
            
            //Add callout request to continuation
            con = new Continuation(timeout);        
            con.continuationMethod='processValidateRecentLeadResponse';
            con.state=carrier;
            con.addHttpRequest(request);
            
            if(Test.isRunningTest()) {
               continuationLabel = con.addHttpRequest(request);
               continuationState = carrier; 
            }  
            
        }
        catch(Exception ex){
            ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'doValidateRecentLeadCallout', System.Label.Apex, ex,loanApplicationId);
            throw new IND_Exception(ex.getMessage());
        }
        return con;
    } 
    
    /*
* @Method:      processValidateRecentLeadResponse
* @Created by:  Divya Jawale 
* @Description: Method to return Response for Validate Recent Lead API
* @Param:       Collection - labels
* @Param:       Object - state
* @Return:      Object - response
*/
    @AuraEnabled(cacheable=true)
    public static Object processValidateRecentLeadResponse(List<String> labels, Object state){
        
        IND_ValidateRecentLeadResponse apiResponse;
        String request='';
        String encryptedRequest='';
        String serviceName='';
        String loanAppId='';
        String data='';
        HttpResponse response;
        String elapseTime='';
        
        try{
            Carrier carrier = (Carrier)state;
            request = carrier.getRequest();
            encryptedRequest = carrier.getEncryptedRequest();
            serviceName = carrier.getServiceName();
            Long startTime = carrier.getStartTime();
            
            CalloutProcessor processor = carrier.getProcessor();
            response = Continuation.getResponse(labels[0]);
            Long endTime = DateTime.now().getTime();
            elapseTime = String.valueOf((Double)(endTime - startTime)/1000);
            loanAppId = carrier.getLoanApplicationId();
            
            if(response != null && response.getStatusCode() == 200){
                apiResponse = (IND_ValidateRecentLeadResponse)processor.getHttpResponse(response, serviceName);
                if(apiResponse !=null){
                    IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, IntegrationUtilities.getPlainTextForLog(response.getBody()), response.getBody(), serviceName, elapseTime,loanAppId,System.Label.Success);
                    data =  JSON.serialize(apiResponse);
                }else {
                    IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, IntegrationUtilities.getPlainTextForLog(response.getBody()), response.getBody(), serviceName, elapseTime,loanAppId,System.Label.Failure);
                    throw new IND_Exception(System.Label.NoResponse);                 
                }
            }
            else {
                String errString = '[Status Code = '+ response.getStatusCode() +' ] Response-->'+IntegrationUtilities.getPlainTextForLog(response.getBody());
                IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, errString, response.getBody(), serviceName, elapseTime, loanAppId, System.Label.Failure);
                ErrorLoggerUtil.logErrorEvent('CalloutProcessor', 'getHttpResponse', System.Label.Apex, new IND_Exception(errString), loanAppId);
                throw new IND_Exception(System.Label.NoResponse);
            } 
            
        } catch (Exception ex){
            IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, '', '', serviceName, elapseTime,loanAppId,System.Label.Failure);
            ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'processValidateRecentLeadResponse', System.Label.Apex, ex,loanAppId);
            throw new IND_Exception(ex.getMessage());
        }
        return data;
    }
    
    
    /*
* @Method:      doEMAILCHECKCallout
* @Created by:  Satyam More
* @Description: Continuation for Email Check API
* @Param:       String - emailVerifyRequest
* @Return:      Object - continuation
*/
    
@AuraEnabled(continuation=true)
public static Object doEMAILCHECKCallout(String emailVerifyRequest){
    Continuation con;
    String loanAppId;
    try{
        if(String.isBlank(emailVerifyRequest)){
            throw new IND_Exception(System.Label.Retry);
        }
        //Provide API-wise Integration Name to Custom Metadata Configs
        Integration_Configuration__mdt apiConfiguration = IntegrationUtilities.getAPIConfiguration(System.Label.EmailCheck);
        Integer timeout = Integer.valueOf(apiConfiguration.Timeout__c);
        
        //if stubs checked in Integration_Configuration then stubs will return 
        if(apiConfiguration.IsStub_Required__c != null && apiConfiguration.IsStub_Required__c){  
            String stubData = IntegrationUtilities.getStubResponse(System.Label.EmailCheck);
            return stubData == null ? System.Label.EmptyStubs : stubData;  
        }
        
        RequestWrapper requestWrapper = (RequestWrapper)IntegrationUtilities.parseJSONRequest(emailVerifyRequest,'RequestWrapper');
        loanAppId = requestWrapper.loanApplicationId;
        loanApplicationRef= requestWrapper.loanApplicationId; 
        IND_EmailCheckRequest emailCheckRequest = IND_EmailCheckService.getEmailCheckCallOutRequest(requestWrapper,loanAppId);
        CalloutProcessor processor= new CalloutProcessor(System.Label.EmailCheck, emailCheckRequest);
        HttpRequest request = processor.createHttpRequest();
        Long startTime = DateTime.now().getTime();
        
        Carrier carrier = new carrier();
        carrier.setServiceName(System.Label.EmailCheck);
        carrier.setProcessor(processor);
        carrier.setRequest(IntegrationUtilities.getPlainTextForLog(request.getBody()));
        carrier.setEncryptedRequest(request.getBody());
        carrier.setStartTime(startTime);   
        carrier.setLoanApplicationId(loanAppId);
        //Add callout request to continuation
        con = new Continuation(timeout);        
        con.continuationMethod='processEmailCheckResponse';
        con.state=carrier;
        con.addHttpRequest(request);
        
        if(Test.isRunningTest()) {
           continuationLabel = con.addHttpRequest(request);
           continuationState = carrier; 
        }  
    } catch(Exception ex) {
        ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'doEMAILCHECKCallout', System.Label.Apex, ex,loanAppId);
        throw ex;
    }
    return con;
}

/*
* @Method:      processEmailCheckResponseResponse
* @Created by:  Satyam More 
* @Description: Method to return Response for Email Check API
* @Param:       Collection - labels
* @Param:       Object - state
* @Return:      Object - response
*/
@AuraEnabled
public static Object processEmailCheckResponse(List<String> labels, Object state){
    IND_EmailCheckResponse apiResponse;
    String request='';
    String encryptedRequest='';
    String serviceName='';
    String loanAppId='';
    String data='';
    HttpResponse response;
    String elapseTime='';
    
    try{
        Carrier carrier = (Carrier)state;
        request = carrier.getRequest();
        encryptedRequest = carrier.getEncryptedRequest();
        serviceName = carrier.getServiceName();
        Long startTime = carrier.getStartTime();
        
        CalloutProcessor processor = carrier.getProcessor();
        response = Continuation.getResponse(labels[0]);
        
        Long endTime = DateTime.now().getTime();
        elapseTime = String.valueOf((Double)(endTime - startTime)/1000);
        loanAppId = carrier.getLoanApplicationId();
        
        if(response != null && response.getStatusCode() == 200){
            apiResponse = (IND_EmailCheckResponse)processor.getHttpResponse(response, serviceName);
            if(apiResponse!=null){
                IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, IntegrationUtilities.getPlainTextForLog(response.getBody()), response.getBody(), serviceName, elapseTime,loanAppId,System.Label.Success);
                return JSON.serialize(apiResponse);
            }
            else {
                IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, IntegrationUtilities.getPlainTextForLog(response.getBody()), response.getBody(), serviceName, elapseTime,loanAppId,System.Label.Failure);
                throw new IND_Exception(System.Label.NoResponse);                
            }
        }
        else {
            String errString = '[Status Code = '+ response.getStatusCode() +' ] Response-->'+IntegrationUtilities.getPlainTextForLog(response.getBody());
            IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, errString, response.getBody(), serviceName, elapseTime, loanAppId, System.Label.Failure);
            ErrorLoggerUtil.logErrorEvent('CalloutProcessor', 'getHttpResponse', System.Label.Apex, new IND_Exception(errString), loanAppId);
            throw new IND_Exception(System.Label.NoResponse);
        } 
    } catch (Exception ex){
        IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, '', '', serviceName, elapseTime,loanAppId,System.Label.Failure);
        ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'processEmailCheckResponse', System.Label.Apex, ex,loanAppId);
        throw new IND_Exception(ex.getMessage());
    }
}
    
    /*
* @Method:      doVoterIdCallout
* @Created by:  Aman Mundhada
* @Description: Continuation for Golden-Source Voter Id API
* @Param:       String - kycFieldsVoterIdString
* @Return:      Object - continuation
*/
@AuraEnabled(continuation=true cacheable=true)
public static Object doVoterIdCallout(String kycFieldsVoterIdString){
    Continuation con;
    String loanAppId;
    try{
        if(String.isBlank(kycFieldsVoterIdString)){
            throw new IND_Exception(System.Label.Retry);
        }
        //Provide API-wise Integration Name to Custom Metadata Configs
        Integration_Configuration__mdt apiConfiguration = IntegrationUtilities.getAPIConfiguration(System.Label.VoterIdAPI);           
        Integer timeout = Integer.valueOf(apiConfiguration.Timeout__c);  
        
        //if stubs checked in Integration_Configuration then stubs will return 
        if(apiConfiguration.IsStub_Required__c != null && apiConfiguration.IsStub_Required__c){  
            String stubData = IntegrationUtilities.getStubResponse(System.Label.VoterIdAPI);
            return stubData == null ? System.Label.EmptyStubs : stubData;  
        }
        
        RequestWrapper requestWrapper = (RequestWrapper)IntegrationUtilities.parseJSONRequest(kycFieldsVoterIdString,'RequestWrapper');
        List<Applicant__c> app = [SELECT Opportunity__r.Lead_Number__c,Contact_number__c FROM Applicant__c WHERE ID=:requestWrapper.applicantId WITH SECURITY_ENFORCED Limit 1];         
        if(!app.isEmpty()){
            for(Applicant__c applicant:app){
                requestWrapper.leadId= applicant.Opportunity__r.Lead_Number__c;
                requestWrapper.telephoneNumber=applicant.Contact_number__c;
            }
        }
        else{
            throw new IND_Exception(System.Label.Applicantdatamissing);
        }
        loanAppId = requestWrapper.loanApplicationId;
        loanApplicationRef= requestWrapper.loanApplicationId;
        IND_VoterIdRequest voterIdRequest = IND_VoterIdService.getVoterIdCallOutRequest(requestWrapper);
        CalloutProcessor processor= new CalloutProcessor(System.Label.VoterIdAPI, voterIdRequest);
        HttpRequest request = processor.createHttpRequest();
        Long startTime = DateTime.now().getTime();            
        Carrier carrier = new carrier();
        carrier.setServiceName(System.Label.VoterIdAPI);
        carrier.setProcessor(processor);
        carrier.setRequest(IntegrationUtilities.getPlainTextForLog(request.getBody()));
        carrier.setEncryptedRequest(request.getBody());
        carrier.setStartTime(startTime);            
        carrier.setLoanApplicationId(loanAppId);
        //Add callout request to continuation
        con = new Continuation(timeout);        
        con.continuationMethod='processVoterIdCallOutResponse';
        con.state=carrier;
        con.addHttpRequest(request);
        
        if(Test.isRunningTest()) {
           continuationLabel = con.addHttpRequest(request);
           continuationState = carrier; 
        }  
    } catch(Exception ex) {
        ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'doVoterIdCallout', System.Label.Apex, ex,loanAppId);
        throw ex;
    }
    return con;
}


/*
* @Method:      processVoterIdCallOutResponse
* @Created by:  Aman Mundhada 
* @Description: Method to return Response for Golden Source-Passport API
* @Param:       Collection - labels
* @Param:       Object - state
* @Return:      Object - response
*/
@AuraEnabled(cacheable=true)
public static Object processVoterIdCallOutResponse(List<String> labels, Object state){
    IND_VoterIdResponse apiResponse;
    String request='';
    String encryptedRequest='';
    String serviceName='';
    String loanAppId='';
    HttpResponse response;
    String elapseTime='';       
    try{
        Carrier carrier = (Carrier)state;
        request = carrier.getRequest();
        encryptedRequest = carrier.getEncryptedRequest();
        serviceName = carrier.getServiceName();
        Long startTime = carrier.getStartTime();            
        CalloutProcessor processor = carrier.getProcessor();
        response = Continuation.getResponse(labels[0]);
        Long endTime = DateTime.now().getTime();
        elapseTime = String.valueOf((Double)(endTime - startTime)/1000);
        loanAppId = carrier.getLoanApplicationId();
        if(response != null && response.getStatusCode() == 200){             
            apiResponse = (IND_VoterIdResponse)processor.getHttpResponse(response, serviceName);             
            if(apiResponse!=null){
                IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, IntegrationUtilities.getPlainTextForLog(response.getBody()), response.getBody(), serviceName, elapseTime,loanAppId,System.Label.Success);
                return JSON.serialize(apiResponse);
            }
            else {
                IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, IntegrationUtilities.getPlainTextForLog(response.getBody()), response.getBody(), serviceName, elapseTime,loanAppId,System.Label.Failure);
                throw new IND_Exception(System.Label.NoResponse);   
            } 
        }else {
            String errString = '[Status Code = '+ response.getStatusCode() +' ] Response-->'+IntegrationUtilities.getPlainTextForLog(response.getBody());
            IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, errString, response.getBody(), serviceName, elapseTime, loanAppId, System.Label.Failure);
            ErrorLoggerUtil.logErrorEvent('CalloutProcessor', 'getHttpResponse', System.Label.Apex, new IND_Exception(errString), loanAppId);
            throw new IND_Exception(System.Label.NoResponse);
        } 
        
    } catch (Exception ex){
        IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, '', '', serviceName, elapseTime,loanAppId,System.Label.Failure);
        ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'processVoterIdCallOutResponse', System.Label.Apex, ex,loanAppId);
        throw new IND_Exception(ex.getMessage());
    }
}
    
    
     /*
* @Method:      doImageUploadCallout
* @Created by:  Divya Jawale 
* @Description: Method to return Response for Document Upload API
* @Param:       String - Document Id
* @Return:      String - response
*/
@AuraEnabled(continuation=true cacheable=true)
public static Object doImageUploadCallout(String documentId, String imageType,String loanAppId){
    Continuation con;
    try{
        if(String.isBlank(documentId) || String.isBlank(imageType) ){
            throw new IND_Exception(System.Label.Retry);
        }
        //Provide API-wise Integration Name to Custom Metadata Configs
        Integration_Configuration__mdt apiConfiguration = IntegrationUtilities.getAPIConfiguration(System.Label.ImageAPI);
        Integer timeout = Integer.valueOf(apiConfiguration.Timeout__c);
        
        //if stubs checked in Integration_Configuration then stubs will return 
        if(apiConfiguration.IsStub_Required__c != null && apiConfiguration.IsStub_Required__c){  
            String stubData = IntegrationUtilities.getStubResponse(System.Label.ImageAPI);
            return stubData == null ? System.Label.EmptyStubs : stubData;  
        }
        
        // Request
        loanApplicationRef= loanAppId;        
        IND_ImageUploadAPIRequest documentRequest = IND_ImageUploadAPIService.getImageUploadAPIRequestRequest(documentId,imageType,loanAppId); 
        CalloutProcessor processor = new CalloutProcessor(System.Label.ImageAPI, documentRequest);
        
        HttpRequest request = processor.createHttpRequest();
        Long startTime = DateTime.now().getTime();
        Carrier carrier = new carrier();
        carrier.setServiceName(System.Label.ImageAPI);
        carrier.setProcessor(processor);
        carrier.setRequest(IntegrationUtilities.getPlainTextForLog(request.getBody()));
        carrier.setEncryptedRequest(request.getBody());
        carrier.setStartTime(startTime);
        carrier.setLoanApplicationId(loanAppId);
        
        //Add callout request to continuation
        con = new Continuation(timeout);        
        con.continuationMethod='processImageUploadResponse';
        con.state=carrier;
        con.addHttpRequest(request);
        
        if(Test.isRunningTest()) {
           continuationLabel = con.addHttpRequest(request);
           continuationState = carrier; 
        }  
    } catch(Exception ex) {
        ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'doImageUploadCallout', System.Label.Apex, ex,loanAppId);
        throw ex;
    }
    return con;
}


/*
* @Method:      processImageUploadResponse
* @Created by:  Divya Jawale 
* @Description: Method to return Response for Document Upload API
* @Param:       Collection - labels
* @Param:       Object - state
* @Return:      Object - response
*/
@AuraEnabled(cacheable=false)
public static Object processImageUploadResponse(List<String> labels, Object state){
    String apiResponse;
    String request='';
    String encryptedRequest='';
    String serviceName='';
    String loanAppId='';
    String data='';
    HttpResponse response;
    String elapseTime='';
    try{
        Carrier carrier = (Carrier)state;
        request = carrier.getRequest();
        encryptedRequest = carrier.getEncryptedRequest();
        serviceName = carrier.getServiceName();
        Long startTime = carrier.getStartTime();
        CalloutProcessor processor = carrier.getProcessor();
        response = Continuation.getResponse(labels[0]);
        Long endTime = DateTime.now().getTime();
        elapseTime = String.valueOf((Double)(endTime - startTime)/1000);
        loanAppId = carrier.getLoanApplicationId();
        String resTempBody = response.getBody();
        if(response != null && response.getBody() != ''){
            apiResponse = processor.getHttpResponseForAll(response, serviceName);
            if(apiResponse!=null){
                data = apiResponse;
                IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, IntegrationUtilities.getPlainTextForLog(response.getBody()), response.getBody(), serviceName, elapseTime, loanAppId, System.Label.Success);
            }
            else{
                IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, '', '', serviceName, elapseTime, loanAppId, System.Label.Failure);
                throw new IND_Exception(System.Label.NoResponse);
            }           
        }
        else{
             String errString = '[Status Code = '+ response.getStatusCode() +' ] Response-->'+IntegrationUtilities.getPlainTextForLog(response.getBody());
            IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, errString, response.getBody(), serviceName, elapseTime, loanAppId, System.Label.Failure);
            ErrorLoggerUtil.logErrorEvent('CalloutProcessor', 'getHttpResponse', System.Label.Apex, new IND_Exception(errString), loanAppId);
            throw new IND_Exception(System.Label.NoResponse);
        }
    } catch (Exception ex){
        IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, '', '', serviceName, elapseTime,loanAppId, System.Label.Failure);
        ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'processImageUploadResponse', System.Label.Apex, ex,loanAppId);
        throw new IND_Exception(ex.getMessage());
    }
    return data;
}
    
    
    /*
* @Method:      doCibilOcrFrontUploadCallout
* @Created by:  Satyam More
* @Description: Method to return Response for Cibil Ocr Front Upload API
* @Param:       String - Document Id
* @Return:      String - response
*/ 
    
    @AuraEnabled(continuation=true)
    public static Object doCibilOcrFrontUploadCallout(String documentId, String contentDocumentId,String loanAppId){
        Continuation con;
        try{
            if(String.isBlank(documentId)){
                throw new IND_Exception(System.Label.Retry);
            }
            //Provide API-wise Integration Name to Custom Metadata Configs
            Integration_Configuration__mdt apiConfiguration = IntegrationUtilities.getAPIConfiguration(System.Label.OCRFront);
            Integer timeout = Integer.valueOf(apiConfiguration.Timeout__c);
            
            //if stubs checked in Integration_Configuration then stubs will return 
            if(apiConfiguration.IsStub_Required__c != null && apiConfiguration.IsStub_Required__c){  
                String stubData = IntegrationUtilities.getStubResponse(System.Label.OCRFront);
                return stubData == null ? System.Label.EmptyStubs : stubData;  
            }
            
            //if stubs checked in Integration_Configuration then stubs will return 
            if(apiConfiguration.IsStub_Required__c != null && apiConfiguration.IsStub_Required__c){  
                String stubData = IntegrationUtilities.getStubResponse(System.Label.OCRFront);
                return stubData == null ? System.Label.EmptyStubs : stubData;  
            }
            
            Documents__c docs = [SELECT Id, Document_Type__c, Opportunity_Relation__r.Lead_Number__c,Applicant__r.applicant_number__c FROM Documents__c WHERE Id=:documentId WITH SECURITY_ENFORCED];//CISP-2879
            loanApplicationRef= loanAppId;
            IND_CibilOcrFrontUploadRequest ocrfuRequest = IND_CibilOcrFrontUploadService.getCibilOcrFrontUploadCallOutRequest(docs,contentDocumentId,loanAppId);
            CalloutProcessor processor= new CalloutProcessor(System.Label.OCRFront, ocrfuRequest);
            HttpRequest request = processor.createHttpRequest();
            system.debug('request size in ocr is : '+request.getBody().length());
            Long startTime = DateTime.now().getTime();
            System.debug('continuation()====request'+request);
            Carrier carrier = new carrier();
            carrier.setServiceName(System.Label.OCRFront);
            carrier.setProcessor(processor);
            System.debug('request.getBody() ' + request.getBody());
            System.debug('IntegrationUtilities.getPlainTextForLog(request.getBody()) ' + IntegrationUtilities.getPlainTextForLog(request.getBody()));
            carrier.setRequest(IntegrationUtilities.getPlainTextForLog(request.getBody()));
            carrier.setEncryptedRequest(request.getBody());
            carrier.setStartTime(startTime);   
            carrier.setLoanApplicationId(loanAppId);
            System.debug('continuation()====3');
            //Add callout request to continuation
            con = new Continuation(timeout);        
            con.continuationMethod='processCibilOcrFrontUploadResponse';
            con.state=carrier;
            con.addHttpRequest(request);
            
            if(Test.isRunningTest()) {
               continuationLabel = con.addHttpRequest(request);
               continuationState = carrier; 
            }  
        } catch(Exception ex) {
            ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'doCibilOcrFrontUploadCallout', System.Label.Apex, ex,loanAppId);
            throw ex;
        }
        return con;
    }
    
    /*
* @Method:      processCibilOcrFrontUploadResponse
* @Created by:  Satyam More 
* @Description: Method to return Response for Cibil Ocr Front Upload API
* @Param:       Collection - labels
* @Param:       Object - state
* @Return:      Object - response
*/
@AuraEnabled
public static Object processCibilOcrFrontUploadResponse(List<String> labels, Object state){
    System.debug('callback()====');
    IND_CibilOcrFrontUploadResponse apiResponse;
    String request='';
    String encryptedRequest='';
    String serviceName='';
    String loanAppId='';
    String data='';
    HttpResponse response;
    String elapseTime='';
    
    try{
        Carrier carrier = (Carrier)state;
        request = carrier.getRequest();
        encryptedRequest = carrier.getEncryptedRequest();
        serviceName = carrier.getServiceName();
        Long startTime = carrier.getStartTime();
        
        CalloutProcessor processor = carrier.getProcessor();
        response = Continuation.getResponse(labels[0]);
        
        Long endTime = DateTime.now().getTime();
        elapseTime = String.valueOf((Double)(endTime - startTime)/1000);
        
        system.debug('response.getbody'+response.getbody());
        loanAppId = carrier.getLoanApplicationId();
        if(response != null && response.getStatusCode() == 200){
            apiResponse = (IND_CibilOcrFrontUploadResponse)processor.getHttpResponse(response, serviceName);
            System.debug('callback() apiResponse()===='+apiResponse);
            if(apiResponse!=null){ 
                IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, IntegrationUtilities.getPlainTextForLog(response.getBody()), response.getBody(), serviceName, elapseTime,loanAppId,System.Label.Success);
                return  JSON.serialize(apiResponse);
            }
            else {
               IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, IntegrationUtilities.getPlainTextForLog(response.getBody()), response.getBody(), serviceName, elapseTime,loanAppId,System.Label.Failure);
                throw new IND_Exception(System.Label.NoResponse);                
            }
        }
        else {
            System.debug('encryptedRequest '+ encryptedRequest);
            System.debug('request '+ request);
            String errString = '[Status Code = '+ response.getStatusCode() +' ] Response-->'+(response.getBody() != null ? IntegrationUtilities.getPlainTextForLog(response.getBody()) : '');
            IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, errString, response.getBody(), serviceName, elapseTime, loanAppId, System.Label.Failure);
            ErrorLoggerUtil.logErrorEvent('CalloutProcessor', 'getHttpResponse', System.Label.Apex, new IND_Exception(errString), loanAppId);
            //throw new IND_Exception(System.Label.NoResponse);
            return null;
        } 
    } catch (Exception ex){
        IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, '', '', serviceName, elapseTime,loanAppId,System.Label.Failure);
        ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'processCibilOcrFrontUploadResponse', System.Label.Apex, ex,loanAppId);
        //throw new IND_Exception(ex.getMessage());
        return null;
    }
}

/*
* @Method:      doCibilOcrBackUploadCallout
* @Created by:  Satyam More
* @Description: Method to return Response for Cibil Ocr Back Upload API
* @Param:       String - Document Id
* @Return:      String - response
*/  

@AuraEnabled(continuation=true)
public static Object doCibilOcrBackUploadCallout(String documentId, String contentDocumentId,String loanAppId){
    Continuation con;
    try{
        if(String.isBlank(documentId)){
            throw new IND_Exception(System.Label.Retry);
        }
        //Provide API-wise Integration Name to Custom Metadata Configs
        Integration_Configuration__mdt apiConfiguration = IntegrationUtilities.getAPIConfiguration(System.Label.OCRBack);
        Integer timeout = Integer.valueOf(apiConfiguration.Timeout__c);
        
        //if stubs checked in Integration_Configuration then stubs will return 
        if(apiConfiguration.IsStub_Required__c != null && apiConfiguration.IsStub_Required__c){  
            String stubData = IntegrationUtilities.getStubResponse(System.Label.OCRBack);
            return stubData == null ? System.Label.EmptyStubs : stubData;  
        }
        
        Documents__c docs = [SELECT Id, Document_Type__c, Opportunity_Relation__r.Lead_Number__c,Applicant__r.applicant_number__c FROM Documents__c WHERE Id=:documentId WITH SECURITY_ENFORCED];//CISP-2879
        loanApplicationRef= loanAppId;
        IND_CibilOcrBackUploadRequest ocrbuRequest = IND_CibilOcrBackUploadService.getCibilOcrBackUploadCallOutRequest(docs, contentDocumentId,loanAppId);
        CalloutProcessor processor= new CalloutProcessor(System.Label.OCRBack, ocrbuRequest);
        HttpRequest request = processor.createHttpRequest();
        Long startTime = DateTime.now().getTime();
        System.debug('continuation()====request'+request);
        Carrier carrier = new carrier();
        carrier.setServiceName(System.Label.OCRBack);
        carrier.setProcessor(processor);
        carrier.setRequest(IntegrationUtilities.getPlainTextForLog(request.getBody()));
        carrier.setEncryptedRequest(request.getBody());
        carrier.setStartTime(startTime); 
        carrier.setLoanApplicationId(loanAppId);
        System.debug('continuation()====3');
        //Add callout request to continuation
        con = new Continuation(timeout);        
        con.continuationMethod='processCibilOcrBackUploadResponse';
        con.state=carrier;
        con.addHttpRequest(request);
        
        if(Test.isRunningTest()) {
           continuationLabel = con.addHttpRequest(request);
           continuationState = carrier; 
        }  
    } catch(Exception ex) {
        ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'doOCRbuCallout', System.Label.Apex, ex,loanAppId);
        throw ex;
    }
    return con;
}

/*
* @Method:      processCibilOcrBackUploadResponse
* @Created by:  Satyam More 
* @Description: Method to return Response for Cibil Ocr Back Upload API
* @Param:       Collection - labels
* @Param:       Object - state
* @Return:      Object - response
*/
@AuraEnabled
public static Object processCibilOcrBackUploadResponse(List<String> labels, Object state){
    System.debug('callback()====');
    IND_CibilOcrBackUploadResponse apiResponse;
    String request='';
    String encryptedRequest='';
    String serviceName='';
    String loanAppId='';
    String data='';
    HttpResponse response;
    String elapseTime='';
    
    try{
        Carrier carrier = (Carrier)state;
        request = carrier.getRequest();
        encryptedRequest = carrier.getEncryptedRequest();
        serviceName = carrier.getServiceName();
        Long startTime = carrier.getStartTime();
        
        CalloutProcessor processor = carrier.getProcessor();
        response = Continuation.getResponse(labels[0]);
        
        Long endTime = DateTime.now().getTime();
        elapseTime = String.valueOf((Double)(endTime - startTime)/1000);
        loanAppId = carrier.getLoanApplicationId();
        
        if(response != null && response.getStatusCode() == 200){
            apiResponse = (IND_CibilOcrBackUploadResponse)processor.getHttpResponse(response, serviceName);
                            
            System.debug('callback() apiResponse()===='+apiResponse);
            if(apiResponse!=null){ 
                IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, IntegrationUtilities.getPlainTextForLog(response.getBody()), response.getBody(), serviceName, elapseTime,loanAppId,System.Label.Success);
                return  JSON.serialize(apiResponse);
            }
            else {
                IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, IntegrationUtilities.getPlainTextForLog(response.getBody()), response.getBody(), serviceName, elapseTime,loanAppId,System.Label.Failure);
                throw new IND_Exception(System.Label.NoResponse);               
            }
        }
        else {
            String errString = '[Status Code = '+ response.getStatusCode() +' ] Response-->'+ (response.getBody() != null ? IntegrationUtilities.getPlainTextForLog(response.getBody()) : '');
            IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, errString, response.getBody(), serviceName, elapseTime, loanAppId, System.Label.Failure);
            ErrorLoggerUtil.logErrorEvent('CalloutProcessor', 'getHttpResponse', System.Label.Apex, new IND_Exception(errString), loanAppId);
            //throw new IND_Exception(System.Label.NoResponse);
            return null;
        } 
    } catch (Exception ex){
        IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, '', '', serviceName, elapseTime, loanAppId,System.Label.Failure);
        ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'processCibilOcrBackUploadResponse', System.Label.Apex, ex, loanAppId);
        //throw new IND_Exception(ex.getMessage());
        return null;
    }
}
    
    /*
* @Method:      doDocAuthReportAsyncCallout
* @Created by:  Santhosh Mothe 
* @Description: Method to return Response Report in Async
* @Param:       String  - applicantId
*/
    @AuraEnabled
    public static void doDocAuthReportAsyncCallout(String applicantId, String documentId, String loanApplicationId){
        
        loanApplicationRef = loanApplicationId;
        IND_DocAuthDocumentReportRequest drRequest = new IND_DocAuthDocumentReportRequest(applicantId);
        IntegrationEngine.parentAPIRequest = drRequest;
        IntegrationEngine.serviceName = System.Label.DocumentReport;
        //system.debug('serviceName----------:'+serviceName);
        Integration_Configuration__mdt apiConfiguration = IntegrationUtilities.getAPIConfiguration(serviceName);
        
        try{
            
            //Applicant__c app = [SELECT Id FROM Applicant__c WHERE ID=:applicantId WITH SECURITY_ENFORCED];
            
            if(apiConfiguration != null){
                if(!apiConfiguration.IsActive_Integration__c){
                    ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'doDocAuthReportAsyncCallout', System.Label.Apex, new AuraHandledException('Integration is not Active'));
                    throw new AuraHandledException('Integration is not Active');       
                }
                if(apiConfiguration.isSync__c){
                    ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'doDocAuthReportAsyncCallout', System.Label.Apex, new AuraHandledException('Integration is not Async API'));
                    throw new AuraHandledException('Integration is not Async API');       
                }
                
                String requestBody = '';
                String body = '';
                requestBody = parentAPIRequest.convertToJSON();
                String encryptedRequest = IntegrationUtilities.getEncryptedRequest(requestBody,System.Label.privateKey,System.Label.ivkey);  
                String jdataRequest = '"JData":';                    
                body='{'+jdataRequest + '"'+encryptedRequest+'"'+'}';
                
                System.debug('Request Generated is '+requestBody); 
                System.debug('Request Generated this.body '+body); 
                system.debug('body length'+body.length());
                String req = '';
                String reqExt = '';
                if(body.length() <= 131072){
                    req = body;
                    system.debug('published from low payload');
                    IntegrationUtilities.publishLowPayload(req, serviceName, requestBody, applicantId+documentId, documentId);
                    
                }
                else if(body.length() > 131072 && body.length()<=262144){
                    req = body.substring(0, 131072);
                    reqExt = body.substring(131072,body.length());
                    IntegrationUtilities.publishHighPayload(req, reqExt, serviceName, requestBody, applicantId+documentId, documentId);
                    system.debug('published from high payload');
                }
                else{
                    ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'doDocAuthReportAsyncCallout', System.Label.Apex, new AuraHandledException('Request string length is too long'), loanApplicationRef);
                    
                }

                
            }
            
        }
        catch(Exception ex){
            System.debug('IntegrationEngine process() Exception-->'+ex.getMessage() +
                         ' Exception line number-->'+ ex.getLineNumber()+ 
                         ' Stack Tracer-->'+ ex.getLineNumber());
            ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'doDocAuthReportAsyncCallout', System.Label.Apex, ex, loanApplicationRef);
            throw new AuraHandledException(ex.getMessage());
        }
        
        
    }
    
    /*
* @Method:      doSelfieReportAsyncCallout
* @Created by:  Santhosh Mothe 
* @Description: Method to return Response Report in Async
* @Param:       String  - applicantId
*/
    @AuraEnabled
    public static void doSelfieReportAsyncCallout(String applicantId, String documentId, String loanApplicationId){
        
        loanApplicationRef = loanApplicationId;
        IND_SelfieReportRequest drRequest = new IND_SelfieReportRequest(applicantId);
        IntegrationEngine.parentAPIRequest = drRequest;
        IntegrationEngine.serviceName = System.Label.Selfie_Report;
        
        Integration_Configuration__mdt apiConfiguration = IntegrationUtilities.getAPIConfiguration(serviceName);
        
        //if stubs checked in Integration_Configuration then stubs will return 
        if(apiConfiguration.IsStub_Required__c != null && apiConfiguration.IsStub_Required__c){  
            String stubData = IntegrationUtilities.getStubResponse(System.Label.Selfie_Report);
            //return stubData == null ? System.Label.EmptyStubs : stubData;  
        }
        
        try{
            
            
            if(apiConfiguration != null){
                if(!apiConfiguration.IsActive_Integration__c){
                    ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'doSelfieReportAsyncCallout', System.Label.Apex, new AuraHandledException('Integration is not Active'));
                    throw new AuraHandledException('Integration is not Active');       
                }
                if(apiConfiguration.isSync__c){
                    ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'doSelfieReportAsyncCallout', System.Label.Apex, new AuraHandledException('Integration is not Async API'));
                    throw new AuraHandledException('Integration is not Async API');       
                }
                
                String requestBody = '';
                String body = '';
                requestBody = parentAPIRequest.convertToJSON();
                String encryptedRequest = IntegrationUtilities.getEncryptedRequest(requestBody,System.Label.privateKey,System.Label.ivkey);  
                String jdataRequest = '"JData":';                    
                body='{'+jdataRequest + '"'+encryptedRequest+'"'+'}';
                
                System.debug('Request Generated is '+requestBody); 
                System.debug('Request Generated this.body '+body); 
                system.debug('body length'+body.length());
                String req = '';
                String reqExt = '';
                if(body.length() <= 131072){
                    req = body;
                    system.debug('published from low payload');
                    IntegrationUtilities.publishLowPayload(req, serviceName, requestBody, applicantId+documentId, documentId);
                    
                }
                else if(body.length() > 131072 && body.length()<=262144){
                    req = body.substring(0, 131072);
                    reqExt = body.substring(131072,body.length());
                    IntegrationUtilities.publishHighPayload(req, reqExt, serviceName, requestBody, applicantId+documentId, documentId);
                    system.debug('published from high payload');
                }
                else{
                    ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'doSelfieReportAsyncCallout', System.Label.Apex, new AuraHandledException('Request string length is too long'), loanApplicationRef);
                    
                }

                
            }
            
        }
        catch(Exception ex){
            System.debug('IntegrationEngine process() Exception-->'+ex.getMessage() +
                         ' Exception line number-->'+ ex.getLineNumber()+ 
                         ' Stack Tracer-->'+ ex.getLineNumber());
            ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'doSelfieReportAsyncCallout', System.Label.Apex, ex, loanApplicationRef);
            throw new AuraHandledException(ex.getMessage());
        }
        
        
    }
    
    /*
* @Method:      doVahanVehicleReportCallout
* @Created by:  Satyam More
* @Description: Continuation for Vahan Vehicle Report API
* @Param:       String - 
* @Return:      Object - continuation
*/
    
    @AuraEnabled(continuation=true cacheable=true)
    public static Object doVahanVehicleReportCallout(String vahanVehicleReport){
        Continuation con;
        String loanAppId;
        try{
            if(String.isBlank(vahanVehicleReport)){
                throw new IND_Exception(System.Label.Retry);
            }
            //Provide API-wise Integration Name to Custom Metadata Configs
            Integration_Configuration__mdt apiConfiguration = IntegrationUtilities.getAPIConfiguration(System.Label.VahanReport);
            Integer timeout = Integer.valueOf(apiConfiguration.Timeout__c);
            
            //if stubs checked in Integration_Configuration then stubs will return 
            if(apiConfiguration.IsStub_Required__c != null && apiConfiguration.IsStub_Required__c){  
                String stubData = IntegrationUtilities.getStubResponse(System.Label.VahanReport);
                return stubData == null ? System.Label.EmptyStubs : stubData;  
            }
            
            RequestWrapper requestWrapper = (RequestWrapper)IntegrationUtilities.parseJSONRequest(vahanVehicleReport,'RequestWrapper');
            loanAppId = requestWrapper.loanApplicationId;
            loanApplicationRef= requestWrapper.loanApplicationId;
            Applicant__c app = [SELECT Id,applicant_number__c FROM Applicant__c WHERE Opportunity__c =: loanAppId WITH SECURITY_ENFORCED limit 1];//CISP-2879
            requestWrapper.leadId = requestWrapper.leadId + '_' + app.applicant_number__c;//CISP-2879
            IND_VahanVehicleReportRequest vahanVehicleReportRequest = IND_VahanVehicleReportService.getVahanVehicleReportCallOutRequest(requestWrapper,loanAppId);
            
            CalloutProcessor processor= new CalloutProcessor(System.Label.VahanReport, vahanVehicleReportRequest);
            HttpRequest request = processor.createHttpRequest();
            Long startTime = DateTime.now().getTime();
            Carrier carrier = new carrier();
            carrier.setServiceName(System.Label.VahanReport);
            carrier.setProcessor(processor);
            carrier.setRequest(IntegrationUtilities.getPlainTextForLog(request.getBody()));
            carrier.setEncryptedRequest(request.getBody());
            carrier.setStartTime(startTime);  
            carrier.setLoanApplicationId(loanAppId);
            //Add callout request to continuation
            con = new Continuation(timeout);        
            con.continuationMethod='processVahanVehicleReportResponse';
            con.state=carrier;
            con.addHttpRequest(request);
            
            if(Test.isRunningTest()) {
               continuationLabel = con.addHttpRequest(request);
               continuationState = carrier; 
            }  
        } catch(Exception ex) {
            ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'doVahanVehicleReportCallout', System.Label.Apex, ex,loanAppId);
            throw ex;
        }
        return con;
    }
    
    
    /*
* @Method:      processVahanVehicleReportResponse
* @Created by:  Satyam More 
* @Description: Callback method to return Response for Run Emi Engine API
* @Param:       Collection - labels
* @Param:       Object - state
* @Return:      Object - response
*/
    @AuraEnabled(cacheable=true)
    public static Object processVahanVehicleReportResponse(List<String> labels, Object state){
        IND_VahanVehicleReportResponse apiResponse;
        String request='';
        String encryptedRequest='';
        String serviceName='';
        String loanAppId='';
        HttpResponse response;
        String elapseTime='';        
        try{            
            Carrier carrier = (Carrier)state;
            request = carrier.getRequest();
            encryptedRequest = carrier.getEncryptedRequest();
            serviceName = carrier.getServiceName();
            Long startTime = carrier.getStartTime();            
            CalloutProcessor processor = carrier.getProcessor();
            response = Continuation.getResponse(labels[0]);
            Long endTime = DateTime.now().getTime();
            elapseTime = String.valueOf((Double)(endTime - startTime)/1000);
            loanAppId = carrier.getLoanApplicationId();
            
            if(response != null && response.getStatusCode() == 200){
                apiResponse = (IND_VahanVehicleReportResponse)processor.getHttpResponse(response, serviceName);
                if(apiResponse!=null){
                    IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, IntegrationUtilities.getPlainTextForLog(response.getBody()), response.getBody(), serviceName, elapseTime,loanAppId,System.Label.Success);
                    return JSON.serialize(apiResponse);
                } else {
                    IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, IntegrationUtilities.getPlainTextForLog(response.getBody()), response.getBody(), serviceName, elapseTime,loanAppId,System.Label.Failure);
                    throw new IND_Exception(System.Label.NoResponse);                
                }
            }
            else {
                String errString = '[Status Code = '+ response.getStatusCode() +' ] Response-->'+IntegrationUtilities.getPlainTextForLog(response.getBody());
                IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, errString, response.getBody(), serviceName, elapseTime, loanAppId, System.Label.Failure);
                ErrorLoggerUtil.logErrorEvent('CalloutProcessor', 'getHttpResponse', System.Label.Apex, new IND_Exception(errString), loanAppId);
                throw new IND_Exception(System.Label.NoResponse);
            } 
        } catch (Exception ex){
            IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, '', '', serviceName, elapseTime,loanAppId,System.Label.Failure);
            ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'processVahanVehicleReportResponse', System.Label.Apex, ex,loanAppId);
            throw new IND_Exception(ex.getMessage());
        }
    }
    
   /*
* @Method:      doGatingScreeningCheckEligibilityCallout
* @Created by:  Aman Mundhada
* @Description: Continuation for Gating Screening-Check Eligibility 
* @Param:       String - checkEligibilityString
* @Return:      Object - continuation
*/
    @AuraEnabled(continuation=true cacheable=true)
    public static Object doGatingScreeningCheckEligibilityCallout(String checkEligibilityString){
        Continuation con;
        String loanAppId='';
        try{
            if(String.isBlank(checkEligibilityString)){
                throw new IND_Exception(System.Label.Retry);
            }
            //Provide API-wise Integration Name to Custom Metadata Configs
            Integration_Configuration__mdt apiConfiguration = IntegrationUtilities.getAPIConfiguration(System.Label.IblBre);
            Integer timeout = Integer.valueOf(apiConfiguration.Timeout__c); 
            
            //if stubs checked in Integration_Configuration then stubs will return 
            if(apiConfiguration.IsStub_Required__c != null && apiConfiguration.IsStub_Required__c){  
                String stubData = IntegrationUtilities.getStubResponse(System.Label.IblBre);
                return stubData == null ? System.Label.EmptyStubs : stubData;  
            }
            
            RequestWrapper requestWrapper = (RequestWrapper)IntegrationUtilities.parseJSONRequest(checkEligibilityString,'RequestWrapper');
            loanAppId = requestWrapper.loanApplicationId;
            loanApplicationRef= requestWrapper.loanApplicationId;
            List<Applicant__c> app = [SELECT Opportunity__r.Lead_Number__c , Declared_income__c, applicant_number__c, Opportunity__r.Loan_Amount__c FROM Applicant__c WHERE ID=:requestWrapper.applicantId WITH SECURITY_ENFORCED Limit 1];
            if(!app.isEmpty()){
                for(Applicant__c applicant:app){
                    requestWrapper.leadId=applicant.Opportunity__r.Lead_Number__c;
                    requestWrapper.income= String.valueOf(applicant.Declared_income__c);
                    requestWrapper.borrowerApplicantNumber = applicant.applicant_number__c;
                    requestWrapper.loanAmount = applicant.Opportunity__r.Loan_Amount__c;
                }
            }
            else{
                throw new IND_Exception(System.Label.Applicantdatamissing);
            }
            
            List<Documents__c> docs=[SELECT PAN_No__c FROM Documents__c WHERE Applicant__c=:requestWrapper.applicantId and Document_Type__c=:System.Label.PanCards and KYC_DOB__c!=null WITH SECURITY_ENFORCED];
            if(!docs.isEmpty()){
                for(Documents__c doc:docs){
                    if(String.isBlank(doc.PAN_No__c)){
                        throw new IND_Exception(System.Label.PAN_Number);
                    }
                    else{
                        String decrypt = IntegrationUtilities.getDecryptedResponse(doc.PAN_No__c,System.Label.privateKey,System.Label.ivkey);//CISP-3038
                        requestWrapper.panNumber= decrypt; //CISP-3038, removed doc.PAN_No__c
                    }
                }
            }
            else{
                List<Documents__c> docForm60 = [SELECT id FROM Documents__c where Document_Type__c='Form 60' and Applicant__c=:requestWrapper.applicantId WITH SECURITY_ENFORCED limit 1];
                
                if(!docForm60.isEmpty()){
                    requestWrapper.borrowerForm60Present ='true';	
                }
                else{
                    throw new IND_Exception('PAN or Form 60 not found');
                }
            }
            //CISP-4027
            List<Documents__c> docWithDate=[SELECT kyc_dob__c FROM documents__c WHERE recordtype.name = 'KYC Document' AND Applicant__c=:requestWrapper.applicantId AND Proof_of_Identity_POI__c=true AND Is_Active__c =true WITH SECURITY_ENFORCED limit 1];
            if(!docWithDate.isEmpty()){
                requestWrapper.dOB = docWithDate[0].kyc_dob__c;
            }
            else{
                throw new IND_Exception(System.Label.DateOfBirth);
            }
            //CISP-4027
            System.debug('The Applicant ID in Integration ENgine IS  ---> '+requestWrapper.applicantId);
            List<Customer_dedupe_response__c> custDedupe=[Select cin_no__c from customer_dedupe_response__c where applicant__c=:requestWrapper.applicantId  WITH SECURITY_ENFORCED Limit 1];
            if(!custDedupe.isEmpty()){
                for(Customer_dedupe_response__c cust:custDedupe){
                    //System.debug('The cust.CIN_No__c is ---> '+cust.CIN_No__c);
                    if(String.isNotBlank(cust.CIN_No__c) || cust.CIN_No__c!=null){
                        requestWrapper.cinNo=cust.CIN_No__c;
                    }
                }    
            }
            else{
                requestWrapper.cinNo = '';
            }
            //CISP-2583-START
            Opportunity oppObj = [Select id, Parent_Loan_Application__c,Revoked_Applicant_Count__c From Opportunity Where Id =: requestWrapper.loanApplicationId WITH SECURITY_ENFORCED];
            Integer revokedApplicantCount = 0;
            if(oppObj.Parent_Loan_Application__c != null){
                revokedApplicantCount = Integer.valueof(oppObj.Revoked_Applicant_Count__c);
            }
            Integer coApplicantCount = [select count() from Applicant__c where Applicant_Type__c='Co-borrower' and Applicant__c.Opportunity__c=:requestWrapper.loanApplicationId WITH SECURITY_ENFORCED];
            requestWrapper.noOfCoborrowers=  String.valueOf(coApplicantCount + revokedApplicantCount);
            //CISP-2583-END
            if(Integer.valueOf(requestWrapper.noOfCoborrowers) > 0){
                String appId;
                List<Applicant__c> coBorrowerApplicant = [Select Id,Declared_income__c, applicant_number__c from Applicant__c where Applicant_Type__c='Co-borrower' and Applicant__c.Opportunity__c=:requestWrapper.loanApplicationId and In_Active_Applicant__c=false WITH SECURITY_ENFORCED limit 1];
                
                if(!coBorrowerApplicant.isEmpty()){
                    requestWrapper.noOfActiveCoborrowers='1';
                    for(Applicant__c coBorrowerApp:coBorrowerApplicant){
                        appId=coBorrowerApp.Id;
                        requestWrapper.coBorrowerIncome=String.valueOf(coBorrowerApp.Declared_income__c);
                        requestWrapper.coBorrowerApplicantNumber = coBorrowerApp.applicant_number__c;
                    }
                    List<Documents__c> coBorrowerDocs=[SELECT KYC_DOB__c,PAN_No__c FROM Documents__c WHERE Applicant__c=:appId and Document_Type__c=:System.Label.PanCards and KYC_DOB__c!=null WITH SECURITY_ENFORCED limit 1];
                    
                    if(!coBorrowerDocs.isEmpty()){
                        for(Documents__c doc:coBorrowerDocs){
                            if(String.isBlank(doc.PAN_No__c)){
                                throw new IND_Exception(System.Label.PAN_Number);
                            }
                            else{
                                String decrypt = IntegrationUtilities.getDecryptedResponse(doc.PAN_No__c,System.Label.privateKey,System.Label.ivkey);//CISP-3038
                                requestWrapper.coBorrowerPanNumber=decrypt;//CISP-3038, removed doc.PAN_No__c
                            }
                        }
                    }
                    else{
                        List<Documents__c> docForm60 = [SELECT id FROM Documents__c where Document_Type__c='Form 60' and Applicant__c=:appId WITH SECURITY_ENFORCED limit 1];
                        
                        if(!docForm60.isEmpty()){
                            requestWrapper.coBorrowerForm60Present ='true';
                        }
                        else{
                            throw new IND_Exception('PAN or Form 60 not found');
                        }
                    }
                    //CISP-4027
                    List<Documents__c> CobdocWithDate=[SELECT kyc_dob__c FROM documents__c WHERE recordtype.name = 'KYC Document' AND Applicant__c=:appId AND Proof_of_Identity_POI__c=true AND Is_Active__c =true WITH SECURITY_ENFORCED limit 1];
                    if(!docWithDate.isEmpty()){
                        requestWrapper.coBorrowerDob = CobdocWithDate[0].kyc_dob__c;
                    }
                    else{
                        throw new IND_Exception(System.Label.DateOfBirth);
                    }
                    //CISP-4027
                    
                    List<Customer_dedupe_response__c> coBorrowerCustDedupe=[Select cin_no__c from customer_dedupe_response__c where applicant__c=:appId  WITH SECURITY_ENFORCED Limit 1];
                    if(!custDedupe.isEmpty()){
                        for(Customer_dedupe_response__c cust:coBorrowerCustDedupe){
                            if(String.isNotBlank(cust.CIN_No__c) || cust.CIN_No__c!=null){
                                requestWrapper.coBorrowerCinNo=cust.CIN_No__c;
                            }                    
                        }    
                    }
                    else{
                        requestWrapper.coBorrowerCinNo = '';
                    }    
                }   
            }
            
            List<Opportunity> opp = [SELECT Vehicle_Type__c,Parent_Deal_number__c FROM Opportunity WHERE ID=:requestWrapper.loanApplicationId WITH SECURITY_ENFORCED Limit 1]; //INDI-4709 Added Parent_Deal_number__c field in the query. 
            if(!opp.isEmpty()){ 
                for(Opportunity opportunity:opp){
                    if(String.isBlank(opportunity.Vehicle_Type__c) || opportunity.Vehicle_Type__c==null ){
                        throw new IND_Exception(System.Label.VehicleType);
                    }
                    else {
                        requestWrapper.vehicleType = opportunity.Vehicle_Type__c;
                    }
                    requestWrapper.parentDealNo = opportunity.Parent_Deal_number__c; // INDI-4709
                }
            } 
            else {
                throw new IND_Exception(System.Label.VehicleType);
            }
            
            IND_GatingScreeningRequest gatingScreeningRequest = IND_GatingScreeningService.getGatingScreeningCallOutRequest(requestWrapper);
            CalloutProcessor processor= new CalloutProcessor(System.Label.IblBre, gatingScreeningRequest);
            HttpRequest request = processor.createHttpRequest();
            Long startTime = DateTime.now().getTime();
            Carrier carrier = new carrier();
            carrier.setServiceName(System.Label.IblBre);
            carrier.setProcessor(processor);
            carrier.setRequest(IntegrationUtilities.getPlainTextForLog(request.getBody()));
            carrier.setEncryptedRequest(request.getBody());
            carrier.setStartTime(startTime);  
            carrier.setLoanApplicationId(loanAppId);
            //Add callout request to continuation
            con = new Continuation(timeout);        
            con.continuationMethod='processGatingScreeningCallOutResponse';
            con.state=carrier;
            con.addHttpRequest(request);
            
            if(Test.isRunningTest()) {
                continuationLabel = con.addHttpRequest(request);
                continuationState = carrier; 
            }  
        } catch(Exception ex) {
            ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'doGatingScreeningCheckEligibilityCallout', System.Label.Apex, ex,loanAppId);
            throw ex;
        }
        return con;
    }
    
    
    /*
* @Method:      processGatingScreeningCallOutResponse
* @Created by:  Aman Mundhada 
* @Description: Method to return Response for Gating Screening-Check Eligibility
* @Param:       Collection - labels
* @Param:       Object - state
* @Return:      Object - response
*/
    @AuraEnabled(cacheable=true)
    public static Object processGatingScreeningCallOutResponse(List<String> labels, Object state){
        IND_GatingScreeningResponse apiResponse;
        String request='';
        String encryptedRequest='';
        String serviceName='';
        String loanAppId='';
        String data='';
        HttpResponse response;
        String elapseTime=''; 
        try{     
            Carrier carrier = (Carrier)state;
            request = carrier.getRequest();
            encryptedRequest = carrier.getEncryptedRequest();
            serviceName = carrier.getServiceName();
            Long startTime = carrier.getStartTime();            
            CalloutProcessor processor = carrier.getProcessor();
            response = Continuation.getResponse(labels[0]);
            Long endTime = DateTime.now().getTime();
            elapseTime = String.valueOf((Double)(endTime - startTime)/1000); 
            loanAppId = carrier.getLoanApplicationId();
            if(response != null && response.getStatusCode() == 200){
                apiResponse = (IND_GatingScreeningResponse)processor.getHttpResponse(response, serviceName);
                if(apiResponse!=null){
                    IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, IntegrationUtilities.getPlainTextForLog(response.getBody()), response.getBody(), serviceName, elapseTime,loanAppId,System.Label.Success);
                    return JSON.serialize(apiResponse);
                } else {
                    IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, IntegrationUtilities.getPlainTextForLog(response.getBody()), response.getBody(), serviceName, elapseTime,loanAppId,System.Label.Failure);
                    throw new IND_Exception(System.Label.NoResponse);                
                }
            }    
            else {
                String errString = '[Status Code = '+ response.getStatusCode() +' ] Response-->'+IntegrationUtilities.getPlainTextForLog(response.getBody());
                IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, errString, response.getBody(), serviceName, elapseTime, loanAppId, System.Label.Failure);
                ErrorLoggerUtil.logErrorEvent('CalloutProcessor', 'getHttpResponse', System.Label.Apex, new IND_Exception(errString), loanAppId);
                throw new IND_Exception(System.Label.NoResponse);
            } 
        } catch (Exception ex){
            // IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, '', '', serviceName, elapseTime,loanAppId,System.Label.Failure);
            ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'processGatingScreeningCallOutResponse', System.Label.Apex, ex,loanAppId);
            throw new IND_Exception(ex.getMessage());
        }
    }
    
    
    
    // @Method:      doMembershipCallout
    // @Created by:  Manish Baldota 
    // @Description: This method is being used to call the Membership API using continuation
    // @Param:       String - applicantId
    // @Param:       Stirng - membershipType
    // @Return:      ''
    
    @AuraEnabled(continuation=true cacheable=true)
    public static Object doMembershipCallout(String applicantId,String inputJSONString,String loanAppId){
        Continuation con;
        try{
            //Provide API-wise Integration Name to Custom Metadata Configs
            Integration_Configuration__mdt apiConfiguration = IntegrationUtilities.getAPIConfiguration(System.Label.Membership);
            Integer timeout = Integer.valueOf(apiConfiguration.Timeout__c);
            
            //if stubs checked in Integration_Configuration then stubs will return 
            if(apiConfiguration.IsStub_Required__c != null && apiConfiguration.IsStub_Required__c){  
                String stubData = IntegrationUtilities.getStubResponse(System.Label.Membership);
                return stubData == null ? System.Label.EmptyStubs : stubData;  
            }
            
            Applicant__c app = [SELECT Id,Opportunity__r.Lead_number__c 
                                FROM Applicant__c 
                                WHERE Id=:applicantId WITH SECURITY_ENFORCED];       
            loanApplicationRef= loanAppId;
            //Creating Request
            IND_MembershipRequest membershipRequestDetails = IND_MembershipService.getMembershipCallOutRequest(app,inputJSONString,loanAppId);
            CalloutProcessor process = new CalloutProcessor(System.Label.Membership, membershipRequestDetails);
            HttpRequest request = process.createHttpRequest();             
            Long startTime = DateTime.now().getTime();            
            Carrier carrier = new carrier();
            carrier.setServiceName(System.Label.Membership);
            carrier.setProcessor(process);
            carrier.setRequest(IntegrationUtilities.getPlainTextForLog(request.getBody()));
            carrier.setEncryptedRequest(request.getBody());
            carrier.setStartTime(startTime);    
            carrier.setLoanApplicationId(loanAppId);
            //Add callout request to continuation
            con = new Continuation(timeout);        
            con.continuationMethod='processMembershipAPIResponse';
            con.state=carrier;
            con.addHttpRequest(request);
            
            if(Test.isRunningTest()) {
               continuationLabel = con.addHttpRequest(request);
               continuationState = carrier; 
            }  
        } catch(Exception ex) {
            ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'doMembershipCallout', System.Label.Apex, ex,loanAppId);
            throw new IND_Exception(ex.getMessage());
        }
        return con;
    }
    
    // @Method:      processMembershipAPIResponse
    // @Created by:  Manish Baldota 
    // @Description: This method is being used to handle the response from continuation and return the response to calling processes
    // @Param:       Collection - labels
    // @Param:       Object - state
    // @Return:      Object - response
    
    @AuraEnabled(cacheable=true)
    public static Object processMembershipAPIResponse(List<String> labels, Object state){
        IND_MembershipResponse apiResponse;
        String request='';
        String loanAppId='';
        String encryptedRequest='';
        String serviceName='';
        String data;
        HttpResponse response;
        String elapseTime='';        
        try{
            Carrier carrier = (Carrier)state;
            request = carrier.getRequest();
            encryptedRequest = carrier.getEncryptedRequest();
            serviceName = carrier.getServiceName();
            Long startTime = carrier.getStartTime();            
            CalloutProcessor processor = carrier.getProcessor();
            response = Continuation.getResponse(labels[0]);
            Long endTime = DateTime.now().getTime();
            elapseTime = String.valueOf((Double)(endTime - startTime)/1000); 
            loanAppId = carrier.getLoanApplicationId();
            
            if(response != null && response.getStatusCode() == 200) {
                apiResponse = (IND_MembershipResponse)processor.getHttpResponse(response, serviceName);
                if(apiResponse !=null){
                    data = JSON.serialize(apiResponse);
                     IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, IntegrationUtilities.getPlainTextForLog(response.getBody()), response.getBody(), serviceName, elapseTime, loanAppId, System.Label.Success);
                } else {
                        IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, '', '', serviceName, elapseTime, loanAppId, System.Label.Failure);
                throw new IND_Exception(System.Label.NoResponse);    
                }
                
            } else {
                String errString = '[Status Code = '+ response.getStatusCode() +' ] Response-->'+IntegrationUtilities.getPlainTextForLog(response.getBody());
                IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, errString, response.getBody(), serviceName, elapseTime, loanAppId, System.Label.Failure);
                ErrorLoggerUtil.logErrorEvent('CalloutProcessor', 'getHttpResponse', System.Label.Apex, new IND_Exception(errString), loanAppId);
                throw new IND_Exception(System.Label.NoResponse);
            }             
        } catch (Exception ex){
            IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, '', '', serviceName, elapseTime,loanAppId,System.Label.Failure);
            ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'processMembershipAPIResponse', System.Label.Apex, ex,loanAppId);
            throw new IND_Exception(ex.getMessage());
        }
        return data;
    }
    
    /*
* @Method:      doMFCValuationCallout
* @Created by:  Divya Jawale 
* @Description: Method to return Response for MFC Valuation API
* @Param:       String - Applicant Id
* @Return:      String - response
*/
    @AuraEnabled(continuation=true cacheable=true)
    public static Object doMFCValuationCallout(String mfcValuationString){
        Continuation con;
        String loanAppId;
        try{
            if(String.isBlank(mfcValuationString)){
                throw new IND_Exception(System.Label.Retry);
            }
            //Provide API-wise Integration Name to Custom Metadata Configs
            Integration_Configuration__mdt apiConfiguration = IntegrationUtilities.getAPIConfiguration(System.Label.MFCValuationAPI);
            Integer timeout = Integer.valueOf(apiConfiguration.Timeout__c);
            
            //if stubs checked in Integration_Configuration then stubs will return 
            if(apiConfiguration.IsStub_Required__c != null && apiConfiguration.IsStub_Required__c){  
                String stubData = IntegrationUtilities.getStubResponse(System.Label.MFCValuationAPI);
                return stubData == null ? System.Label.EmptyStubs : stubData;  
            }
            
            RequestWrapper requestWrapper = (RequestWrapper)IntegrationUtilities.parseJSONRequest(mfcValuationString,'RequestWrapper');
            Opportunity opp = [SELECT Id,Parent_Deal_number__c,Lead_Number__c FROM Opportunity WHERE Id=:requestWrapper.loanApplicationId WITH SECURITY_ENFORCED];
           
            loanAppId = requestWrapper.loanApplicationId;
            loanApplicationRef= requestWrapper.loanApplicationId;
            IND_MFCValuationRequest mfcValuationRequest = IND_MFCValuationService.getMFCValuationRequestCallout(requestWrapper);
            CalloutProcessor processor= new CalloutProcessor(System.Label.MFCValuationAPI, mfcValuationRequest);
            HttpRequest request = processor.createHttpRequest();
            Long startTime = DateTime.now().getTime();
            List<Object> objList = new List<Object>();
            objList.add(opp);
            Carrier carrier = new carrier();
            carrier.setServiceName(System.Label.MFCValuationAPI);
            carrier.setProcessor(processor);
            carrier.setRequest(IntegrationUtilities.getPlainTextForLog(request.getBody()));
            carrier.setEncryptedRequest(request.getBody());
            carrier.setStartTime(startTime);
            carrier.setLoanApplicationId(loanAppId); 
            carrier.setTempObject(objList);
            
            //Add callout request to continuation
            con = new Continuation(timeout);        
            con.continuationMethod='processMFCValuationResponse';
            con.state=carrier;
            con.addHttpRequest(request);
            
            if(Test.isRunningTest()) {
               continuationLabel = con.addHttpRequest(request);
               continuationState = carrier; 
            }  
        } catch(Exception ex) {
            ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'doMFCValuationCallout', System.Label.Apex, ex,loanAppId);
            throw ex;
        }
        return con;
    }
    
    /*
* @Method:      processMFCValuationResponse
* @Created by:  Divya Jawale
* @Description: Method to return Response for MFC Valuation API
* @Param:       Collection - labels
* @Param:       Object - state
* @Return:      Object - response
*/
    @AuraEnabled(cacheable=true)
    public static Object processMFCValuationResponse(List<String> labels, Object state){
        IND_MFCValuationResponse apiResponse;
        String request='';
        String encryptedRequest='';
        String serviceName='';
        String data='';
        HttpResponse response;
        String elapseTime='';
        List<Object> objList;
        String loanAppId='';
        
        try{
            Carrier carrier = (Carrier)state;
            request = carrier.getRequest();
            encryptedRequest = carrier.getEncryptedRequest();
            serviceName = carrier.getServiceName();
            Long startTime = carrier.getStartTime();
            objList = carrier.getTempObject();
            CalloutProcessor processor = carrier.getProcessor();
            response = Continuation.getResponse(labels[0]);
            Long endTime = DateTime.now().getTime();
            elapseTime = String.valueOf((Double)(endTime - startTime)/1000);
            loanAppId = carrier.getLoanApplicationId();
            
            if(response != null && response.getStatusCode() == 200){
                apiResponse = (IND_MFCValuationResponse)processor.getHttpResponse(response, serviceName);
                if(apiResponse!=null){
                    data = JSON.serialize(apiResponse);
                    IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, IntegrationUtilities.getPlainTextForLog(response.getBody()), response.getBody(), serviceName, elapseTime, loanAppId, System.Label.Success);
                }
                else{
                    IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, '', '', serviceName, elapseTime, loanAppId, System.Label.Failure);
                    throw new IND_Exception(System.Label.NoResponse); 
                }   
            }  else{
                String errString = '[Status Code = '+ response.getStatusCode() +' ] Response-->'+IntegrationUtilities.getPlainTextForLog(response.getBody());
                IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, errString, response.getBody(), serviceName, elapseTime, loanAppId, System.Label.Failure);
                ErrorLoggerUtil.logErrorEvent('CalloutProcessor', 'getHttpResponse', System.Label.Apex, new IND_Exception(errString), loanAppId);
                throw new IND_Exception(IntegrationUtilities.getPlainTextForLog(response.getBody())); 
            }
        }
        catch (Exception ex){
            
            IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, '', '', serviceName, elapseTime,loanAppId,System.Label.Failure);
            ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'processMFCValuationResponse', System.Label.Apex, ex,loanAppId);
            throw new IND_Exception(ex.getMessage());
        }
        return data;
    }
    
    /*
* @Method:      doMFCFetchValuationReportCallout
* @Created by:  Divya Jawale 
* @Description: Method to return Response for MFC Fetch Valuation Report API
* @Param:       String - mfcValuationReportRequestString
* @Return:      String - response
*/
    @AuraEnabled(continuation=true cacheable=true)
    public static Object doMFCFetchValuationReportCallout(String mfcValuationReportRequestString){
        Continuation con;
        String loanAppId;
        try{
            if(String.isBlank(mfcValuationReportRequestString)){
                throw new IND_Exception(System.Label.Retry);
            }
            //Provide API-wise Integration Name to Custom Metadata Configs
            Integration_Configuration__mdt apiConfiguration = IntegrationUtilities.getAPIConfiguration(System.Label.MFCFetchValuationReportAPI);
            Integer timeout = Integer.valueOf(apiConfiguration.Timeout__c);
            
            //if stubs checked in Integration_Configuration then stubs will return 
            if(apiConfiguration.IsStub_Required__c != null && apiConfiguration.IsStub_Required__c){  
                String stubData = IntegrationUtilities.getStubResponse(System.Label.MFCFetchValuationReportAPI);
                return stubData == null ? System.Label.EmptyStubs : stubData;  
            }
            
            RequestWrapper requestWrapper = (RequestWrapper)IntegrationUtilities.parseJSONRequest(mfcValuationReportRequestString,'RequestWrapper');
            loanAppId = requestWrapper.loanApplicationId;
            loanApplicationRef= requestWrapper.loanApplicationId;
            IND_MFCFetchValuationReportRequest mfcValuationReportRequest = IND_MFCFetchValuationReportService.getMFCFetchValuationReportRequest(requestWrapper);
            CalloutProcessor processor= new CalloutProcessor(System.Label.MFCFetchValuationReportAPI, mfcValuationReportRequest);
            HttpRequest request = processor.createHttpRequest();
            Long startTime = DateTime.now().getTime();
            List<Object> objList = new List<Object>();
            
            Carrier carrier = new carrier();
            carrier.setServiceName(System.Label.MFCFetchValuationReportAPI);
            carrier.setProcessor(processor);
            carrier.setRequest(IntegrationUtilities.getPlainTextForLog(request.getBody()));
            carrier.setEncryptedRequest(request.getBody());
            carrier.setStartTime(startTime);
            carrier.setLoanApplicationId(loanAppId);
            carrier.setTempObject(objList);
            
            //Add callout request to continuation
            con = new Continuation(timeout);        
            con.continuationMethod='processMFCFetchValuationReportResponse';
            con.state=carrier;
            con.addHttpRequest(request);
            
            if(Test.isRunningTest()) {
               continuationLabel = con.addHttpRequest(request);
               continuationState = carrier; 
            }  
        } catch(Exception ex) {
            ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'doMFCFetchValuationReportCallout', System.Label.Apex, ex,loanAppId);
            throw ex;
        }
        return con;
    }
    
    /*
* @Method:      processMFCFetchValuationReportResponse
* @Created by:  Divya Jawale
* @Description: Method to return Response for  MFC Fetch Valuation Report API
* @Param:       Collection - labels
* @Param:       Object - state
* @Return:      Object - response
*/
    @AuraEnabled
    public static Object processMFCFetchValuationReportResponse(List<String> labels, Object state){
        
        IND_MFCFetchValuationReportResponse apiResponse;
        String request='';
        String encryptedRequest='';
        String serviceName='';
        String loanAppId='';
        String data='';
        HttpResponse response;
        String elapseTime='';
        List<Object> objList;
        
        try{
            Carrier carrier = (Carrier)state;
            request = carrier.getRequest();
            encryptedRequest = carrier.getEncryptedRequest();
            serviceName = carrier.getServiceName();
            Long startTime = carrier.getStartTime();
            objList = carrier.getTempObject();
            CalloutProcessor processor = carrier.getProcessor();
            response = Continuation.getResponse(labels[0]);
            Long endTime = DateTime.now().getTime();
            elapseTime = String.valueOf((Double)(endTime - startTime)/1000);
            loanAppId = carrier.getLoanApplicationId();
            
            if(response != null && response.getStatusCode() == 200){
                apiResponse = (IND_MFCFetchValuationReportResponse)processor.getHttpResponse(response, serviceName);
                if(apiResponse!=null){
                    data = JSON.serialize(apiResponse);
                    IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, IntegrationUtilities.getPlainTextForLog(response.getBody()), response.getBody(), serviceName, elapseTime, loanAppId, System.Label.Success);
                }
                else{
                    IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, IntegrationUtilities.getPlainTextForLog(response.getBody()), response.getBody(), serviceName, elapseTime,loanAppId,System.Label.Failure);
                    throw new IND_Exception(System.Label.NoResponse);
                }   
            }  else{
                String errString = '[Status Code = '+ response.getStatusCode() +' ] Response-->'+IntegrationUtilities.getPlainTextForLog(response.getBody());
                IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, errString, response.getBody(), serviceName, elapseTime, loanAppId, System.Label.Failure);
                ErrorLoggerUtil.logErrorEvent('CalloutProcessor', 'getHttpResponse', System.Label.Apex, new IND_Exception(errString), loanAppId);
                throw new IND_Exception(System.Label.NoResponse); 
            }
        }
        catch (Exception ex){
            
            IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, '', '', serviceName, elapseTime,loanAppId,System.Label.Failure);
            ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'processMFCFetchValuationReportResponse', System.Label.Apex, ex,loanAppId);
            throw new IND_Exception(ex.getMessage());
        }
        return data;
    }
    
    
  /*
* @Method:      doIbbMasterCallout
* @Created by:  Aman Mundhada
* @Description: Continuation for IBB Master API
* @Param:       String - varientCode
* @Param:       String - YOM
* @Return:      Object - continuation
*/   
    @AuraEnabled(continuation=true cacheable=true)
    public static Object doIbbMasterCallout(String ibbRequestString){
        Continuation con;
        String loanAppId='';
        try{
            if(String.isBlank(ibbRequestString)){
                 throw new IND_Exception(System.Label.Retry);
            } 

            //Provide API-wise Integration Name to Custom Metadata Configs
            Integration_Configuration__mdt apiConfiguration = IntegrationUtilities.getAPIConfiguration(System.Label.IBBMaster); 
            Integer timeout = Integer.valueOf(apiConfiguration.Timeout__c);
            
            //if stubs checked in Integration_Configuration then stubs will return 
            if(apiConfiguration.IsStub_Required__c != null && apiConfiguration.IsStub_Required__c){  
                String stubData = IntegrationUtilities.getStubResponse(System.Label.IBBMaster);
                return stubData == null ? System.Label.EmptyStubs : stubData;  
            }
            
            RequestWrapper requestWrapper = (RequestWrapper)IntegrationUtilities.parseJSONRequest(ibbRequestString,'RequestWrapper');
             List<Vehicle_Detail__c> vehicleDetails = [Select Variant__c,Variant_Code__c,Manufacturer_Year_Month__c,Number_of_ownerships__c,Loan_Application__r.Lead_Number__c from Vehicle_Detail__c where id=:requestWrapper.vehicleId WITH SECURITY_ENFORCED Limit 1];      //CISP-3555    
            if(!vehicleDetails.isEmpty()){
                for(Vehicle_Detail__c vehicle:vehicleDetails){             
                    String yearMonth = vehicle.Manufacturer_Year_Month__c;
                    if(yearMonth!=null){
                    String[] yearMonthArray = yearMonth.split('-');
                    requestWrapper.year = yearMonthArray[0];
                    requestWrapper.month = yearMonthArray[1];  
                   }
                	 requestWrapper.owner=vehicle.Number_of_ownerships__c;
                     requestWrapper.applicationNo=vehicle.Loan_Application__r.Lead_Number__c;
                      
                    
                   Opportunity opp = [SELECT Id,Product_Type__c,Agent_BL_code__c
                                       FROM Opportunity WHERE ID=:requestWrapper.loanApplicationId WITH SECURITY_ENFORCED]; 
                    
                    String productType= opp.Product_Type__c == 'Two Wheeler'?'H' : opp.Product_Type__c == 'Passenger Vehicles' ?'C' : opp.Product_Type__c == 'Tractor'?'T' : '' ;
                    
                    List<BankBranchDetails__c> stateList = [SELECT State_Code__c FROM BankBranchDetails__c WHERE Bl_Code_Details__r.Bl_Code__c =:opp.Agent_BL_code__c AND Product__c=:productType WITH SECURITY_ENFORCED LIMIT 1];
                        if(stateList.isEmpty()){
                            requestWrapper.stateCode = '';
                        } 
                    else {
                        requestWrapper.stateCode = stateList[0].State_Code__c ;
                    }  
                     List<Product2> product2 =  [Select variant_code__c from Product2 where Variant_Code__c =:vehicle.Variant_Code__c  and type__c = 'variant' WITH SECURITY_ENFORCED Limit 1];  //CISP-3555                  
                    if(!product2.isEmpty()){                       
                      requestWrapper.variant=product2[0].variant_code__c;                        
                    }
                    else{
                        throw new IND_Exception('Variant not found in product');				  
                    }
                    
                    
                } 
            }
            else{   
                throw new IND_Exception(System.Label.VehicleDetailsMissing);
            }
            IND_IbbMasterRequest iBBMasterRequest = IND_IbbMasterService.getIbbMasterCallOutRequest(requestWrapper);
            CalloutProcessor processor= new CalloutProcessor(System.Label.IBBMaster, iBBMasterRequest);
            loanAppId = requestWrapper.loanApplicationId;
            loanApplicationRef= requestWrapper.loanApplicationId;
            HttpRequest request = processor.createHttpRequest();
            Long startTime = DateTime.now().getTime();            
            Carrier carrier = new carrier();
            carrier.setServiceName(System.Label.IBBMaster);
            carrier.setProcessor(processor);
            carrier.setRequest(IntegrationUtilities.getPlainTextForLog(request.getBody()));
            carrier.setEncryptedRequest(request.getBody());
            carrier.setStartTime(startTime);
            carrier.setLoanApplicationId(loanAppId);
            //Add callout request to continuation
            con = new Continuation(timeout);        
            con.continuationMethod='processIbbMasterCallOutResponse';
            con.state=carrier;
            con.addHttpRequest(request);
            
            if(Test.isRunningTest()) {
               continuationLabel = con.addHttpRequest(request);
               continuationState = carrier; 
            }  
        } catch(Exception ex) {
            ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'doIbbMasterCallout', System.Label.Apex, ex,loanAppId);
            throw ex;
        }
        return con;
    }
    
    
    /*
* @Method:      processIbbMasterCallOutResponse
* @Created by:  Aman Mundhada 
* @Description: Method to return Response for IBB Master
* @Param:       Collection - labels
* @Param:       Object - state
* @Return:      Object - response
*/
    @AuraEnabled(cacheable=true)
    public static Object processIbbMasterCallOutResponse(List<String> labels, Object state){
        IND_IbbMasterResponse apiResponse;
		IBBErrorResponse errResponse;
        String loanAppId='';
        String responseBody='';
        String request='';
        String encryptedRequest='';
        String serviceName='';
        String data='';
        HttpResponse response;
        String elapseTime='';  
        try{
            Carrier carrier = (Carrier)state;
            request = carrier.getRequest();
            encryptedRequest = carrier.getEncryptedRequest();
            serviceName = carrier.getServiceName();
            Long startTime = carrier.getStartTime();            
            CalloutProcessor processor = carrier.getProcessor();
            response = Continuation.getResponse(labels[0]);
            loanAppId = carrier.getLoanApplicationId();
            Long endTime = DateTime.now().getTime();
            elapseTime = String.valueOf((Double)(endTime - startTime)/1000);
            if(response != null && response.getStatusCode() == 200){
                apiResponse = (IND_IbbMasterResponse)processor.getHttpResponse(response, serviceName);
                if(apiResponse!=null){
                    IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, IntegrationUtilities.getPlainTextForLog(response.getBody()), response.getBody(), serviceName, elapseTime,loanAppId,System.Label.Success);
                    return JSON.serialize(apiResponse);
                }
                else {
                    IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, IntegrationUtilities.getPlainTextForLog(response.getBody()), response.getBody(), serviceName, elapseTime,loanAppId,System.Label.Failure);
                    throw new IND_Exception(System.Label.NoResponse);     
                } 
            }else {
                responseBody = response.getBody();                        
                responseBody = responseBody.substring(10, responseBody.length()-2);                        
                String decryptedResponse = IntegrationUtilities.getDecryptedResponse(responseBody,System.Label.privateKey,System.Label.ivkey);
                String searalizedJson = JSON.serializePretty(JSON.deserializeUntyped(decryptedResponse));   
                errResponse = (IBBErrorResponse)IntegrationUtilities.parseJSONResponse(searalizedJson,'IBBErrorResponse');
                IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, IntegrationUtilities.getPlainTextForLog(response.getBody()), response.getBody(), serviceName, elapseTime,loanAppId,System.Label.Failure);
				ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'processIbbMasterCallOutResponse', System.Label.Apex, new IND_Exception(JSON.serialize(errResponse)), loanAppId);
                throw new IND_Exception(errResponse.message);
            }  
            
        } catch (Exception ex){
            IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, '', '', serviceName, elapseTime,loanAppId,System.Label.Failure);
            ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'IND_IbbMasterResponse', System.Label.Apex, ex,loanAppId);
            throw new IND_Exception(ex.getMessage());
        }
    }
    
    @AuraEnabled
public static Map<String,String> doKFSCallout(string kfsRequestString){ 
    Map<String,String> returnStr = new Map<String,String>(); 
    String loanAppId ='';
    Boolean fromProCredit = false;
    String requestForIntegrationLog = '';
    String plainRequest = '';
    Long endTime;
    Long startTime;
    String elapseTime = '';
    String serviceName = '';
    String uniqueid = '';
    String dealId = '';
    String KFSSmsType = '';
    String prodType = '';
    Map<String,String> kfsResponse;
    IND_KFSResponse apiResponse;
    String status = System.Label.Failure;
    List<KFS_Applicant__c> kfsApplicantList = new List<KFS_Applicant__c>();
    List<KFS_Instalment_Schedule__c> kfsInstallmentList = new List<KFS_Instalment_Schedule__c>();
    String pcdId;
    IND_KFSResponse parsedResponse = null;
    String coBorrowerCustomerCode = '';
            String coBorrowerId = '';
            String borrowerCustomerCode = '';
            String borrowerId = '';
            String productType='';
            Boolean finalTermsAvailable = false;

    List<IND_KFSResponse.ApplicantDetails> applicantdetails = new List<IND_KFSResponse.ApplicantDetails>();
    List<IND_KFSResponse.VehicleDetails> vehicleDetails = new List<IND_KFSResponse.VehicleDetails>();
    List<IND_KFSResponse.FinalTerms> finalTerms = new List<IND_KFSResponse.FinalTerms>();
    List<IND_KFSResponse.InstalmentSchedule> installmentSchedule = new List<IND_KFSResponse.InstalmentSchedule>();
    List<IND_KFSResponse.MMVDetails> mmvDetails = new List<IND_KFSResponse.MMVDetails>();
    List<IND_KFSResponse.AddressDetails> addressDetails = new List<IND_KFSResponse.AddressDetails>();
    List<IND_KFSResponse.GSTDetails> gstDetails = new List<IND_KFSResponse.GSTDetails>();
    RequestWrapper requestWrapper = (RequestWrapper)IntegrationUtilities.parseJSONRequest(kfsRequestString,'RequestWrapper');
        pcdId = requestWrapper.pcdId;
        loanAppId = requestWrapper.loanApplicationId;
        fromProCredit = requestWrapper.fromProCredit;
        uniqueid = requestWrapper.Unique_Id;
        dealId = requestWrapper.dealId;
        KFSSmsType = requestWrapper.KFSSmsType;

    try{
        
        IND_KFSAPIRequest kfsStatusRequest;
        if(fromProCredit){
            kfsStatusRequest = IND_KFSService.getKFSCalloutProCredit(requestWrapper);
        }else{
            Opportunity opp = [SELECT Id,Product_Type__c,Deal_Number__c FROM Opportunity WHERE Id=:loanAppId];
            productType= opp.Product_Type__c ;
           kfsStatusRequest = IND_KFSService.getKFSCallout(opp,loanAppId,dealId);
        } 
        //IND_KFSAPIRequest kfsStatusRequest = IND_KFSService.getKFSCalloutProCredit(requestWrapper);
        CalloutProcessor processor= new CalloutProcessor('KfsStatementQueueable', kfsStatusRequest);
        HttpRequest request = processor.createHttpRequest();
        requestForIntegrationLog = request.getBody();
        System.debug('Request body..'+requestForIntegrationLog);
        plainRequest = IntegrationUtilities.getPlainTextForLog(request.getBody());
        Http http = new Http();
        startTime = DateTime.now().getTime();
        HttpResponse response = http.send(request);
        System.debug('KFS-response: '+response);
        endTime = DateTime.now().getTime();
        elapseTime = String.valueOf((Double)(endTime - startTime)/1000);
        System.debug('resp code is::'+response.getStatusCode());
        if(response != null && response.getStatusCode() == 200){
            status=System.Label.Success;
            apiResponse = (IND_KFSResponse)processor.getHttpResponse(response, 'KfsStatementQueueable');
           // if(apiResponse?.Lead_No != null){
            applicantdetails = apiResponse?.ApplicantDetails;
            vehicleDetails = apiResponse?.VehicleDetails;
            finalTerms = apiResponse?.FinalTerms;
            installmentSchedule = apiResponse?.InstalmentSchedule;
            mmvDetails = apiResponse?.MMVDetails;
            addressDetails = apiResponse?.AddressDetails;
            gstDetails = apiResponse?.GSTDetails;

            if(finalTerms.size() > 0){
                finalTermsAvailable = true;
                for(integer i=0; i< finalTerms.size() ; i++){
                    prodType = finalTerms[i]?.Product;
            }}
            
            if(finalTermsAvailable){
            Key_Fact_Statement__c kfsparent = new Key_Fact_Statement__c();
            kfsparent.Lead_Number__c = apiResponse.Lead_No;
            kfsparent.Deal_Number__c = apiResponse.Deal_No;
            kfsparent.KFS_Type__c = KFSSmsType;
            kfsparent.Dealer_Sub_dealer_name__c = apiResponse.Sub_Dealer;
            if(fromProCredit){
                ProCredit_Deals__c pcd = [SELECT Maker_Id__c FROM ProCredit_Deals__c WHERE Id=: pcdId LIMIT 1];
                kfsparent.Maker_Id__c = pcd.Maker_Id__c;
                kfsparent.Keyfact_Consent_OTP__c = uniqueid;
                kfsparent.ProCredit_Deal__c = pcdId;
            }else{
                kfsparent.Maker_Id__c = IntegrationUtilities.getMakerId();
                kfsparent.Keyfact_Consent_OTP__c	= String.valueOf(Math.floor(Math.random() * 10000).intValue());
                kfsparent.Loan_Application__c = loanAppId;
                kfsparent.Unique_Id__c = IntegrationUtilities.getCicNo();
                kfsparent.Product__c = prodType;
                kfsparent.Product_Type__c = prodType;
            }

            insert kfsparent;
            Key_Fact_Statement__c kfs = new Key_Fact_Statement__c();
            kfs.Key_Fact_Statement__c = kfsparent.Id;
            kfs.Lead_Number__c = apiResponse.Lead_No;
            kfs.Deal_Number__c = apiResponse.Deal_No;
            kfs.Dealer_Sub_dealer_name__c = apiResponse.Sub_Dealer;
            insert kfs;
            if(applicantdetails.size() > 0){
                for(integer i=0; i< applicantdetails.size() ; i++){
                    KFS_Applicant__c newKfsApp = new KFS_Applicant__c();
                    newKfsApp.Key_Fact_Statement__c = kfs.Id;
                    newKfsApp.Customer_Type__c = applicantdetails[i]?.Customer_Type;
                    newKfsApp.Applicant_Type__c = applicantdetails[i]?.ApplicantType;
                    newKfsApp.Customer_Name__c = applicantdetails[i]?.Customer_Name;
                    newKfsApp.Customer_Code__c = applicantdetails[i]?.Customer_Code;
                    newKfsApp.Passport_Number__c = applicantdetails[i]?.Passport_Number;
                    newKfsApp.PAN_GIR_Number__c = applicantdetails[i]?.PAN_GIR_Number;
                    newKfsApp.Voter_ID_Number__c = applicantdetails[i]?.Voter_ID_Number;
                    newKfsApp.Salutation__c = applicantdetails[i]?.Customer_Salutation;
                    newKfsApp.Passport_Expiry_Date__c = applicantdetails[i]?.Passport_Expiry_Date;
                    newKfsApp.Date_of_Birth__c = applicantdetails[i]?.Date_of_Birth;
                    newKfsApp.Driving_License_Number__c = applicantdetails[i]?.Driving_License_Number;
                    newKfsApp.Driving_License_Expiry_Date__c = applicantdetails[i]?.Driving_License_Expiry_Date;
                    newKfsApp.Aadhaar_Number__c = applicantdetails[i]?.Aadhaar_No;
                    newKfsApp.Form60__c = applicantdetails[i]?.FORM60;
                    newKfsApp.SurName__c = applicantdetails[i]?.SurName;
                    newKfsApp.Regn_Incorp_Date__c = applicantdetails[i]?.Regn_Incorp_Date;
                    newKfsApp.UCIC__c = applicantdetails[i]?.UCIC;
                    newKfsApp.CKYC_ID__c = applicantdetails[i]?.CKYC_ID;
                    insert newKfsApp; //ApplicantType
                    if(newKfsApp.Applicant_Type__c.toLowerCase() == 'BORROWER'.toLowerCase()){
                        borrowerId = newKfsApp.Id;
                        borrowerCustomerCode = applicantdetails[i]?.Customer_Code;
                    }else{
                        coBorrowerId = newKfsApp.Id;
                        coBorrowerCustomerCode = applicantdetails[i]?.Customer_Code;
                    }
                    //kfsApplicantList.add(newKfsApp);
                }
            }
          /*  if(kfsApplicantList.size() > 0){
                insert kfsApplicantList;
            }
            */

            if(addressDetails.size() > 0 && borrowerId != null && borrowerId != ''){
                KFS_Applicant__c kfsa = new KFS_Applicant__c(Id=borrowerId);

                for(integer i=0; i< addressDetails.size() ; i++){
                    if(addressDetails[i].Communication_Address_Flag != null && addressDetails[i].Communication_Address_Flag != '' && addressDetails[i].Customer_Code == borrowerCustomerCode){
                        kfsa.Communication_Address_Flag__c = addressDetails[i]?.Communication_Address_Flag;
                        kfsa.Mobile_Number__c = addressDetails[i]?.Mobile_Number;
                    }
                    if(addressDetails[i].Customer_Code == borrowerCustomerCode && addressDetails[i].Address_Flag == 'O'){
                        kfsa.Office_Address_Line_1__c = addressDetails[i]?.Address_Line_1;
                        kfsa.Office_Address_Line_3__c = addressDetails[i]?.Address_Line_3;
                        kfsa.Office_Address_Line_2__c = addressDetails[i]?.Address_Line_2;
                        kfsa.Office_Address_Line_4__c = addressDetails[i]?.Address_Line_4;
                        kfsa.Office_State__c = addressDetails[i]?.State;
                        kfsa.Office_District__c = addressDetails[i]?.District;
                        kfsa.Office_Pin_code__c = addressDetails[i]?.Pin_code;
                        kfsa.Office_City__c = addressDetails[i]?.City;
                        kfsa.Office_Mobile_Number__c = addressDetails[i]?.Mobile_Number;
                        kfsa.Office_Address_Flag__c = addressDetails[i]?.Address_Flag;
                       // kfsa.Communication_Address_Flag__c = addressDetails[i]?.City;
                    }else if(addressDetails[i].Customer_Code == borrowerCustomerCode && addressDetails[i].Address_Flag == 'P'){
                        kfsa.Permanent_Address_Line_1__c = addressDetails[i]?.Address_Line_1;
                        kfsa.Permanent_Address_Line_3__c = addressDetails[i]?.Address_Line_3;
                        kfsa.Permanent_Address_Line_2__c = addressDetails[i]?.Address_Line_2;
                        kfsa.Permanent_Address_Line_4__c = addressDetails[i]?.Address_Line_4;
                        kfsa.Permanent_State__c = addressDetails[i]?.State;
                        kfsa.Permanent_District__c = addressDetails[i]?.District;
                        kfsa.Permanent_Pin_code__c = addressDetails[i]?.Pin_code;
                        kfsa.Permanent_City__c = addressDetails[i]?.City;
                        //kfsa.Mobile_Number__c = addressDetails[i]?.Mobile_Number;
                        kfsa.Permanent_Address_Flag__c = addressDetails[i]?.Address_Flag;
                    }else if(addressDetails[i].Customer_Code == borrowerCustomerCode && addressDetails[i].Address_Flag == 'R'){
                        kfsa.Residential_Address_Line_1__c = addressDetails[i]?.Address_Line_1;
                        kfsa.Residential_Address_Line_3__c = addressDetails[i]?.Address_Line_3;
                        kfsa.Residential_Address_Line_2__c = addressDetails[i]?.Address_Line_2;
                        kfsa.Residential_Address_Line_4__c = addressDetails[i]?.Address_Line_4;
                        kfsa.Residential_State__c = addressDetails[i]?.State;
                        kfsa.Residential_District__c = addressDetails[i]?.District;
                        kfsa.Residential_Pin_code__c = addressDetails[i]?.Pin_code;
                        kfsa.Residential_City__c = addressDetails[i]?.City;
                        kfsa.Residential_Mobile_Number__c = addressDetails[i]?.Mobile_Number;
                        kfsa.Residential_Address_Flag__c = addressDetails[i]?.Address_Flag;
                    }
                }
                update kfsa;
            }

            if(addressDetails.size() > 0 && coBorrowerId != null && coBorrowerId != ''){
                KFS_Applicant__c kfsacb = new KFS_Applicant__c(Id=coBorrowerId);

                for(integer i=0; i< addressDetails.size() ; i++){
                    if(addressDetails[i].Communication_Address_Flag != null && addressDetails[i].Communication_Address_Flag != '' && addressDetails[i].Customer_Code == coBorrowerCustomerCode){
                        kfsacb.Communication_Address_Flag__c = addressDetails[i]?.Communication_Address_Flag;
                        kfsacb.Mobile_Number__c = addressDetails[i]?.Mobile_Number;
                    }
                    if(addressDetails[i].Customer_Code == coBorrowerCustomerCode && addressDetails[i].Address_Flag == 'O'){
                        kfsacb.Office_Address_Line_1__c = addressDetails[i]?.Address_Line_1;
                        kfsacb.Office_Address_Line_3__c = addressDetails[i]?.Address_Line_3;
                        kfsacb.Office_Address_Line_2__c = addressDetails[i]?.Address_Line_2;
                        kfsacb.Office_Address_Line_4__c = addressDetails[i]?.Address_Line_4;
                        kfsacb.Office_State__c = addressDetails[i]?.State;
                        kfsacb.Office_District__c = addressDetails[i]?.District;
                        kfsacb.Office_Pin_code__c = addressDetails[i]?.Pin_code;
                        kfsacb.Office_City__c = addressDetails[i]?.City;
                        kfsacb.Office_Mobile_Number__c = addressDetails[i]?.Mobile_Number;
                        kfsacb.Office_Address_Flag__c = addressDetails[i]?.Address_Flag;
                       // kfsa.Communication_Address_Flag__c = addressDetails[i]?.City;
                    }else if(addressDetails[i].Customer_Code == coBorrowerCustomerCode && addressDetails[i].Address_Flag == 'P'){
                        kfsacb.Permanent_Address_Line_1__c = addressDetails[i]?.Address_Line_1;
                        kfsacb.Permanent_Address_Line_3__c = addressDetails[i]?.Address_Line_3;
                        kfsacb.Permanent_Address_Line_2__c = addressDetails[i]?.Address_Line_2;
                        kfsacb.Permanent_Address_Line_4__c = addressDetails[i]?.Address_Line_4;
                        kfsacb.Permanent_State__c = addressDetails[i]?.State;
                        kfsacb.Permanent_District__c = addressDetails[i]?.District;
                        kfsacb.Permanent_Pin_code__c = addressDetails[i]?.Pin_code;
                        kfsacb.Permanent_City__c = addressDetails[i]?.City;
                        //kfsacb.Mobile_Number__c = addressDetails[i]?.Mobile_Number;
                        kfsacb.Permanent_Address_Flag__c = addressDetails[i]?.Address_Flag;
                    }else if(addressDetails[i].Customer_Code == coBorrowerCustomerCode && addressDetails[i].Address_Flag == 'R'){
                        kfsacb.Residential_Address_Line_1__c = addressDetails[i]?.Address_Line_1;
                        kfsacb.Residential_Address_Line_3__c = addressDetails[i]?.Address_Line_3;
                        kfsacb.Residential_Address_Line_2__c = addressDetails[i]?.Address_Line_2;
                        kfsacb.Residential_Address_Line_4__c = addressDetails[i]?.Address_Line_4;
                        kfsacb.Residential_State__c = addressDetails[i]?.State;
                        kfsacb.Residential_District__c = addressDetails[i]?.District;
                        kfsacb.Residential_Pin_code__c = addressDetails[i]?.Pin_code;
                        kfsacb.Residential_City__c = addressDetails[i]?.City;
                        kfsacb.Residential_Mobile_Number__c = addressDetails[i]?.Mobile_Number;
                        kfsacb.Residential_Address_Flag__c = addressDetails[i]?.Address_Flag;
                    }
                }
                update kfsacb;
            }
            

            if(vehicleDetails.size() > 0){
                for(integer i=0; i< vehicleDetails.size() ; i++){
                    Key_Fact_Statement__c kfsv = new Key_Fact_Statement__c(Id=kfs.Id);
                    kfsv.Engine_Number__c = vehicleDetails[i]?.Engine_No;
                    kfsv.Chassis_number__c = vehicleDetails[i]?.Chassis_no;
                    kfsv.Vehicle_Registration_number__c = vehicleDetails[i]?.Vehicle_Reg_No;
                    
                    String vp = vehicleDetails[i]?.Valuation_Charges;
                        kfsv.Valuation_price__c = vp==null || String.isBlank(vp) ? 0:Decimal.valueOf(vp) ;

                    kfsv.Insurance_Combo_Fund_Type__c =  vehicleDetails[i]?.Combo_Fund_Type;
                        kfsv.Insurance_Combo_Fund_Type_G__c = vehicleDetails[i]?.Combo_Fund_Type_G;

                        String cp = vehicleDetails[i]?.Combo_Premium;
                        kfsv.Insurance_Combo_Premium__c = cp==null || String.isBlank(cp) ? 0:Decimal.valueOf(cp) ;

                        String cpg = vehicleDetails[i]?.Combo_Premium_G;
                        kfsv.Insurance_Combo_Premium_G__c = cpg==null || String.isBlank(cpg) ?0: Decimal.valueOf(cpg);

                        kfsv.Insurance_Combo_Product__c = vehicleDetails[i]?.Combo_Product;
                        kfsv.Insurance_Combo_Product_G__c =  vehicleDetails[i]?.Combo_Product_G;
                        kfsv.Insurance_Flexi_Fund_Type__c = vehicleDetails[i]?.Flexi_Fund_Type;
                        kfsv.Insurance_Flexi_Fund_Type_G__c = vehicleDetails[i]?.Flexi_Fund_Type_G;

                        String fp = vehicleDetails[i]?.Flexi_Prm;
                        kfsv.Insurance_Flexi_Premium__c = fp==null || String.isBlank(fp) ?0: Decimal.valueOf(fp) ;

                        String fpg = vehicleDetails[i]?.Flexi_Prm_G;
                        kfsv.Insurance_Flexi_Premium_G__c = fpg==null || String.isBlank(fpg) ?0: Decimal.valueOf(fpg) ;

                        String gpa = vehicleDetails[i]?.GPA_Premium;
                        kfsv.Insurance_GPA_Premium__c = gpa==null || String.isBlank(gpa)?0: Decimal.valueOf(gpa) ;

                        String gpag = vehicleDetails[i]?.GPA_Premium_G;
                        kfsv.Insurance_GPA_Premium_G__c = gpag==null || String.isBlank(gpag)?0: Decimal.valueOf(gpag) ;

                        
                        kfsv.Insurance_GPA_Type__c = vehicleDetails[i]?.GPA_Type;
                        kfsv.Insurance_GPA_Type_G__c = vehicleDetails[i]?.GPA_Type_G;
                        kfsv.Insurance_Health_Fund_Type__c = vehicleDetails[i]?.Health_Fund_Type;
                        kfsv.Insurance_Health_Fund_Type_G__c =  vehicleDetails[i]?.Health_Fund_Type_G;

                        String ihp = vehicleDetails[i]?.Health_Premium;
                        kfsv.Insurance_Health_Premium__c = ihp==null || String.isBlank(ihp)? 0:Decimal.valueOf(ihp) ;

                        String ihpg = vehicleDetails[i]?.Health_Premium_G;
                        kfsv.Insurance_Health_Premium_G__c = ihpg==null || String.isBlank(ihpg) ? 0:Decimal.valueOf(ihpg) ;

                
                        kfsv.Insurance_LI_Fund_Type__c = vehicleDetails[i]?.LI_Fund_Type;
                        kfsv.Insurance_LI_Fund_Type_G__c = vehicleDetails[i]?.LI_Fund_Type_G;


                        String ilp = vehicleDetails[i]?.LI_Prm;
                        kfsv.Insurance_LI_Premium__c = ilp==null || String.isBlank(ilp) ? 0 : Decimal.valueOf(ilp);

                        String ilpg = vehicleDetails[i]?.LI_Prm_G;
                        kfsv.Insurance_LI_Premium_G__c = ilpg==null || String.isBlank(ilpg)  ? 0 : Decimal.valueOf(ilpg);

                        kfsv.Insurance_Motor_Fund_Type__c = vehicleDetails[i]?.Motor_Fund_Type;

                        String ip = vehicleDetails[i]?.Ins_Premium;
                        kfsv.Insurance_Premium__c = ip==null || String.isBlank(ip)  ? 0 : Decimal.valueOf(ip) ;

                        String ipi = vehicleDetails[i]?.Ins_Prm_I;
                        kfsv.Insurance_Premium_I__c = ipi==null || String.isBlank(ipi) ? 0 : Decimal.valueOf(ipi);

                       /* String ippi = vehicleDetails[i]?.Ins_Prm_Paid_I;
                        kfsv.Insurance_Premium_Paid_I__c = ippi==null || String.isBlank(ippi) ? 0 : Decimal.valueOf(ippi);
                        */
                        kfsv.Insurance_Premium_Paid_I__c = vehicleDetails[i]?.Ins_Prm_Paid_I;
                        String srp = vehicleDetails[i]?.Subh_Raksha_Prm;
                        kfsv.Insurance_Subh_Raksha_Premium__c = srp==null || String.isBlank(srp) ? 0 : Decimal.valueOf(srp);

                        String srpg = vehicleDetails[i]?.Subh_Raksha_Prm_G;
                        kfsv.Insurance_Subh_Raksha_Premium_G__c = srpg==null || String.isBlank(srpg) ? 0 : Decimal.valueOf(srpg) ;
                        kfsv.Insurance_Tata_Emi_Fund_Type__c = vehicleDetails[i]?.TATA_EMI_Fund_Type;
                        String itep = vehicleDetails[i]?.TATA_EMI_Premium;
                        kfsv.Insurance_Tata_Emi_Premium__c = itep==null || String.isBlank(itep) ? 0 : Decimal.valueOf(itep);
                        kfsv.Installment_Pattern_Type__c = vehicleDetails[i]?.Install_Pattern_Type;
                    update kfsv;
                }
            }

            Decimal totalC = 0.0;
                Decimal totalB = 0.0;

                Key_Fact_Statement__c kf = [SELECT Id,Total_Insurance_Funded_By_Customer__c,Total_Insurance_Funded_By_Bank__c,Insurance_GPA_Type__c,Insurance_GPA_Premium__c,Insurance_Combo_Fund_Type__c,Insurance_Combo_Premium__c,
                Insurance_Combo_Fund_Type_G__c,Insurance_Combo_Premium_G__c,Insurance_Flexi_Fund_Type__c,Insurance_Flexi_Premium__c,
                Insurance_Flexi_Fund_Type_G__c,Insurance_Flexi_Premium_G__c,
                Insurance_GPA_Type_G__c,Insurance_GPA_Premium_G__c,
                Insurance_Health_Fund_Type__c,Insurance_Health_Premium__c,
                Insurance_Health_Fund_Type_G__c,Insurance_Health_Premium_G__c,
                Insurance_LI_Fund_Type__c, Insurance_LI_Premium__c,
                Insurance_LI_Fund_Type_G__c, Insurance_LI_Premium_G__c,
                Insurance_Tata_Emi_Fund_Type__c, Insurance_Tata_Emi_Premium__c,
                Insurance_Motor_Fund_Type__c,Insurance_Premium_Paid_I__c, Insurance_Premium_I__c FROM Key_Fact_Statement__c WHERE Id=:kfs.Id];

                totalC = kf.Insurance_GPA_Type__c == 'C' ? totalC+kf.Insurance_GPA_Premium__c : totalC;
                totalB = kf.Insurance_GPA_Type__c == 'B' ? totalB+kf.Insurance_GPA_Premium__c : totalB;

               if(productType=='Two Wheeler'){
                totalC = kf.Insurance_Combo_Fund_Type__c == 'C' ? totalC+kf.Insurance_Combo_Premium__c : totalC;
                totalB = kf.Insurance_Combo_Fund_Type__c == 'B' ? totalB+kf.Insurance_Combo_Premium__c : totalB;
                
                totalC = kf.Insurance_Combo_Fund_Type_G__c == 'C' ? totalC+kf.Insurance_Combo_Premium_G__c : totalC;
                totalB = kf.Insurance_Combo_Fund_Type_G__c == 'B' ? totalB+kf.Insurance_Combo_Premium_G__c : totalB;
                }
                totalC = kf.Insurance_Flexi_Fund_Type__c == 'C' ? totalC+kf.Insurance_Flexi_Premium__c : totalC;
                totalB = kf.Insurance_Flexi_Fund_Type__c == 'B' ? totalB+kf.Insurance_Flexi_Premium__c : totalB;

                totalC = kf.Insurance_Flexi_Fund_Type_G__c == 'C' ? totalC+kf.Insurance_Flexi_Premium_G__c : totalC;
                totalB = kf.Insurance_Flexi_Fund_Type_G__c == 'B' ? totalB+kf.Insurance_Flexi_Premium_G__c : totalB;

                totalC = kf.Insurance_GPA_Type_G__c == 'C' ? totalC+kf.Insurance_GPA_Premium_G__c : totalC;
                totalB = kf.Insurance_GPA_Type_G__c == 'B' ? totalB+kf.Insurance_GPA_Premium_G__c : totalB;

                totalC = kf.Insurance_Health_Fund_Type__c == 'C' ? totalC+kf.Insurance_Health_Premium__c : totalC;
                totalB = kf.Insurance_Health_Fund_Type__c == 'B' ? totalB+kf.Insurance_Health_Premium__c : totalB;

                totalC = kf.Insurance_Health_Fund_Type_G__c == 'C' ? totalC+kf.Insurance_Health_Premium_G__c : totalC;
                totalB = kf.Insurance_Health_Fund_Type_G__c == 'B' ? totalB+kf.Insurance_Health_Premium_G__c : totalB;

                totalC = kf.Insurance_LI_Fund_Type__c == 'C' ? totalC+kf.Insurance_LI_Premium__c : totalC;
                totalB = kf.Insurance_LI_Fund_Type__c == 'B' ? totalB+kf.Insurance_LI_Premium__c : totalB;

                totalC = kf.Insurance_LI_Fund_Type_G__c == 'C' ? totalC+kf.Insurance_LI_Premium_G__c : totalC;
                totalB = kf.Insurance_LI_Fund_Type_G__c == 'B' ? totalB+kf.Insurance_LI_Premium_G__c : totalB;

                totalC = kf.Insurance_Tata_Emi_Fund_Type__c == 'C' ? totalC+kf.Insurance_Tata_Emi_Premium__c : totalC;
                totalB = kf.Insurance_Tata_Emi_Fund_Type__c == 'B' ? totalB+kf.Insurance_Tata_Emi_Premium__c : totalB;

                totalC = kf.Insurance_Motor_Fund_Type__c == 'C' && kf.Insurance_Premium_Paid_I__c == 'C' ? totalC+kf.Insurance_Premium_I__c :totalC;
                totalB = kf.Insurance_Motor_Fund_Type__c == 'B' && kf.Insurance_Premium_Paid_I__c == 'B' ? totalB+kf.Insurance_Premium_I__c :totalB;
            

                kf.Total_Insurance_Funded_By_Customer__c = totalC;
                kf.Total_Insurance_Funded_By_Bank__c = totalB;

                update kf;

            if(finalTerms.size() > 0){
                for(integer i=0; i< finalTerms.size() ; i++){
                    Key_Fact_Statement__c kfsf = new Key_Fact_Statement__c(Id=kfs.Id);
                    String loanAmount = finalTerms[i]?.Fin_Amt;
                        kfsf.Loan_Amount__c = loanAmount==null || String.isBlank(loanAmount) ? 0 : Decimal.valueOf(loanAmount);
                
                    String loanAmountChassis = finalTerms[i]?.Fin_Amt_Chasis;
                    kfsf.Loan_Amount_Chassis__c = loanAmountChassis == null || String.isBlank(loanAmountChassis) ? 0 : Decimal.valueOf(loanAmountChassis);
                    String ihmComputed = finalTerms[i]?.IHM_Computed;
                    kfsf.IHM_Computed__c = ihmComputed == null || String.isBlank(ihmComputed) ? 0 : Decimal.valueOf(ihmComputed);

                    kfsf.BL_Name__c = finalTerms[i]?.Bl_Name;
                    kfsf.BL_Code__c = finalTerms[i]?.Bl_Code;
                    kfsf.Sold_By_Dealer_Name__c = finalTerms[i]?.Sold_By_Dealer_Name;
                    kfsf.Effetive_From_Date__c = finalTerms[i]?.Eff_from_date;

                    kfsf.Gross_IRR__c = finalTerms[i]?.Gross_IRR;
                    kfsf.Deal_Period__c = finalTerms[i]?.Deal_Period;
                    kfsf.Moratorium__c = finalTerms[i]?.Moratorium;
                    kfsf.Advance_EMI_Number__c = finalTerms[i]?.Advance_EMI_Nos;
                    String crmIrr = finalTerms[i]?.CRM_IRR;
                    kfsf.CRM_IRR__c = crmIrr==null ||  String.isBlank(crmIrr)? 0 :Decimal.valueOf(crmIrr) ;
                    kfsf.First_EMI_Date__c = finalTerms[i]?.First_EMI_Date;
                    kfsf.Second_EMI_Date__c = finalTerms[i]?.Second_EMI_Date;
                    kfsf.Gross_LTV__c = finalTerms[i]?.Gross_LTV;
                    kfsf.Vehicle_Category__c = finalTerms[i]?.Vehicle_Category;
                    kfsf.Vehicle_Sub_Category__c = finalTerms[i]?.Vehicle_Sub_Category;
                    kfsf.Product__c = finalTerms[i]?.Product;
                    kfsf.Mfg_Year__c = finalTerms[i]?.Mfg_Year;
                    kfsf.Service_Charges__c = finalTerms[i]?.Service_Charges;
                    
                    String docChargs = finalTerms[i]?.Doc_Charges;
                        kfsf.Document_Charges__c = docChargs==null || String.isBlank(docChargs) ? 0 : Decimal.valueOf(docChargs);

                        String stampChargs = finalTerms[i]?.Stamping_Charges;
                        kfsf.Stamping_Charges__c = stampChargs==null || String.isBlank(stampChargs) ? 0 : Decimal.valueOf(stampChargs);

                        String totalIntrstAmnt = finalTerms[i]?.Finance_Charges;
                        kfsf.Total_Interest_Amount__c = totalIntrstAmnt==null || String.isBlank(totalIntrstAmnt) ? 0 : Decimal.valueOf(totalIntrstAmnt);

                        String totatAmntPaidBorr = finalTerms[i]?.Agreement_Value;
                        kfsf.Total_Amount_Paid_By_Borrower__c = totatAmntPaidBorr==null || String.isBlank(totatAmntPaidBorr) ? 0 : Decimal.valueOf(totatAmntPaidBorr);

                        String netDisbAmnt = finalTerms[i]?.Net_Disburse_Amt;
                        kfsf.Net_Disburse_Amount__c = netDisbAmnt==null || String.isBlank(netDisbAmnt) ? 0 : Decimal.valueOf(netDisbAmnt);
                        
                        String netDisbAmntApr = finalTerms[i]?.Net_Disburse_Amt_Apr;
                        kfsf.Net_Disbursement_APR__c = netDisbAmntApr==null || String.isBlank(netDisbAmntApr) ? 0 : Decimal.valueOf(netDisbAmntApr);
						
				kfsf.Deal_Date__c = finalTerms[i]?.Deal_Date;

                   // kfsf.APR__c = String.ValueOf(Decimal.ValueOf(finalTerms[i]?.APR)?.setScale(4));

                     String apr = finalTerms[i]?.APR;
                        kfsf.APR__c = apr==null || String.isBlank(apr) ? 0 : Decimal.valueOf(apr).setScale(4);
                      
                    kfsf.MCLR__c = finalTerms[i]?.MCLR;
                    kfsf.Type_Of_Instalments__c = finalTerms[i]?.Periodicity;
                    kfsf.Instalment_Numbers__c = finalTerms[i]?.Instalment_Nos;
                   String invoiceAmount = finalTerms[i]?.Invoice_Amt;
                    kfsf.Invoice_Amount__c = invoiceAmount==null || String.isBlank(invoiceAmount) ? 0 : Decimal.valueOf(invoiceAmount); 

                        //kfsf.Invoice_Amount__c = finalTerms[i]?.Invoice_Amt;
                    update kfsf;
                }
            }

            if(installmentSchedule.size() > 0){
                for(integer i=0; i< installmentSchedule.size() ; i++){
                    KFS_Instalment_Schedule__c kfsIns = new KFS_Instalment_Schedule__c();
                    kfsIns.Key_Fact_Statement__c = kfs.Id;
                    
                    String rdAmnt = installmentSchedule[i]?.RD_Amount;
                    kfsIns.RD_Amount__c = rdAmnt==null || String.isBlank(rdAmnt) ? 0 : Decimal.valueOf(rdAmnt);
                   
                    String cmbAmnt = installmentSchedule[i]?.Combo_Amt;
                    kfsIns.Combo_Amount__c = cmbAmnt==null || String.isBlank(cmbAmnt) ? 0 : Decimal.valueOf(cmbAmnt);

                    kfsIns.Instal_Date__c = installmentSchedule[i]?.Instal_Date;

                    String posbChrgs = installmentSchedule[i]?.POSB_Charges;
                    kfsIns.POSB_Charges__c = posbChrgs==null || String.isBlank(posbChrgs) ? 0 : Decimal.valueOf(posbChrgs);

                    String hospCashAmnt = installmentSchedule[i]?.Hospital_Cash_Amt;
                    kfsIns.Hospital_Cash_Amount__c = hospCashAmnt==null || String.isBlank(hospCashAmnt) ? 0 : Decimal.valueOf(hospCashAmnt);
                    
                    String healthAmnt = installmentSchedule[i]?.Health_Amt;
                    kfsIns.Health_Amount__c = healthAmnt==null || String.isBlank(healthAmnt) ? 0 : Decimal.valueOf(healthAmnt);

                    String emiAmnt = installmentSchedule[i]?.EMI;
                    kfsIns.EMI_Amount__c = emiAmnt==null || String.isBlank(emiAmnt) ? 0 : Decimal.valueOf(emiAmnt);

                    String insurAmnt = installmentSchedule[i]?.Insur_Amt;
                    kfsIns.Insur_Amount__c = insurAmnt==null || String.isBlank(insurAmnt) ? 0 : Decimal.valueOf(insurAmnt);

                    String installAmnt = installmentSchedule[i]?.Instal_Amt;
                    kfsIns.Instal_Amount__c = installAmnt==null || String.isBlank(installAmnt) ? 0 : Decimal.valueOf(installAmnt);

                    String balance = installmentSchedule[i]?.Balance;
                        kfsIns.Balance__c = balance==null || String.isBlank(balance) ? 0 : Decimal.valueOf(balance);

                        String interest = installmentSchedule[i]?.Interest;
                        kfsIns.Interest__c = interest==null || String.isBlank(interest) ? 0 : Decimal.valueOf(interest);

                        String principal = installmentSchedule[i]?.Principal;
                        kfsIns.Principal__c = principal==null || String.isBlank(principal) ? 0 : Decimal.valueOf(principal);

                    kfsIns.Instal_Number__c = installmentSchedule[i]?.Instal_Nos;
                    kfsIns.To_Month__c = installmentSchedule[i]?.To_No;
                    kfsIns.From_Month__c = installmentSchedule[i]?.From_No;
                    kfsIns.Deal_Number__c = installmentSchedule[i]?.Deal_No;
                    kfsInstallmentList.add(kfsIns);
                }
            }
            if(kfsInstallmentList.size() > 0){
                insert kfsInstallmentList;
            }

            if(mmvDetails.size() > 0){
                for(integer i=0; i< mmvDetails.size() ; i++){
                    Key_Fact_Statement__c kfsm = new Key_Fact_Statement__c(Id=kfs.Id);
                    kfsm.Varient_Code__c = mmvDetails[i]?.Product_Varient_code;
                    kfsm.Variant__c = mmvDetails[i]?.Product_Variant_Name;
                    kfsm.Product_Code__c = mmvDetails[i]?.Product_Code;
                    kfsm.Model__c = mmvDetails[i]?.Product_Name;
                    kfsm.Make__c = mmvDetails[i]?.Make;
                    kfsm.Beneficiary_Code__c = mmvDetails[i]?.Beneficiary_Code;
                    update kfsm;
                }
            }

            if(gstDetails.size() > 0){
                Key_Fact_Statement__c kfsg = new Key_Fact_Statement__c(Id=kfs.Id);
                for(integer i=0; i< gstDetails.size() ; i++){
                    if(gstDetails[i].Nature !=null && gstDetails[i].Nature !='' && gstDetails[i].Nature == 'SERV_CHRGS'){
                        String serGstVal = gstDetails[i].GST_Value;
                        kfsg.Service_Charges_Gst_Value__c = serGstVal==null || String.isBlank(serGstVal) ? 0 : Decimal.valueOf(serGstVal);
                        String serWthoutGstVal = gstDetails[i].Document_Value;
                        kfsg.Service_Charges_Without_Gst__c = serWthoutGstVal==null || String.isBlank(serWthoutGstVal) ? 0 : Decimal.valueOf(serWthoutGstVal);
                        kfsg.GST_Number__c = gstDetails[i].GST_Number;
                    }else if(gstDetails[i].Nature !=null && gstDetails[i].Nature !='' && gstDetails[i].Nature == 'DOC_CHRGS'){
                        String serGstVal = gstDetails[i].GST_Value;
                        kfsg.Document_Charges_Gst_Value__c = serGstVal==null || String.isBlank(serGstVal) ? 0 : Decimal.valueOf(serGstVal);
                        String serWthoutGstVal = gstDetails[i].Document_Value;
                        kfsg.Document_Charges_Without_Gst__c = serWthoutGstVal==null || String.isBlank(serWthoutGstVal) ? 0 : Decimal.valueOf(serWthoutGstVal);
                        kfsg.GST_Number__c = gstDetails[i].GST_Number;
                    }
                }
                update kfsg;
            }

            Key_Fact_Statement__c kfssms = [SELECT Id,Keyfact_Consent_OTP__c,Keyfact_Form_SMS_Sent__c FROM Key_Fact_Statement__c WHERE Id=:kfsparent.Id];
            KFS_Applicant__c kfsapp = [SELECT Id,Applicant_Type__c,Mobile_Number__c,Office_Mobile_Number__c,Residential_Mobile_Number__c FROM KFS_Applicant__c WHERE Key_Fact_Statement__c=:kfs.Id AND Applicant_Type__c='BORROWER'] ;
            String mobileNumber = kfsapp.Mobile_Number__c != null ? kfsapp.Mobile_Number__c : kfsapp.Office_Mobile_Number__c != null ? kfsapp.Office_Mobile_Number__c : kfsapp.Residential_Mobile_Number__c != null ? kfsapp.Residential_Mobile_Number__c : '';
            returnStr.put('status','SUCCESS');
           
           String app_str = smsWrapper(kfssms,pcdId, fromProCredit,loanAppId, mobileNumber,KFSSmsType);
            returnStr.put('app_str',app_str);
            }else{
            returnStr.put('status','FINALTERMS NOT AVAILABLE');
        }
            IntegrationEngine.createIntegrationLogs(fromProCredit, pcdId, plainRequest, requestForIntegrationLog, IntegrationUtilities.getPlainTextForLog(response.getBody()), response.getBody(), 'Key Fact Statement', elapseTime,loanAppId,status);
            
    }
        else {
            String errString = '[Status Code = '+ response.getStatusCode() +' ] Response-->'+IntegrationUtilities.getPlainTextForLog(response.getBody());
            if(!fromProCredit){
                IntegrationUtilities.createIntegrationLogger(plainRequest, requestForIntegrationLog, errString, response.getBody(), 'KeyFactStatement', elapseTime, loanAppId, System.Label.Failure);
                ErrorLoggerUtil.logErrorEvent('CalloutProcessor', 'getHttpResponse', System.Label.Apex, new IND_Exception(errString), loanAppId);
            }else{
                IntegrationUtilities.createIntegrationLogger(plainRequest, requestForIntegrationLog, errString, response.getBody(), 'ProCredit_KFS', elapseTime, pcdId, System.Label.Failure);
                ErrorLoggerUtil.logErrorEventProCreditDeal('CalloutProcessor', 'getHttpResponse', System.Label.Apex, new IND_Exception(errString) ,pcdId);
            }
            throw new IND_Exception(System.Label.NoResponse);
        }
    } catch(Exception ex){
        if(!fromProCredit){
            IntegrationUtilities.createIntegrationLogger(plainRequest, requestForIntegrationLog, '', '', 'KeyFactStatement', elapseTime,loanAppId, System.Label.Failure);
            ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'processKFSResponse', System.Label.Apex, ex,loanAppId);
        }else{
            IntegrationUtilities.createIntegrationLogger(plainRequest, requestForIntegrationLog, '', '', 'ProCredit_KFS', elapseTime,pcdId, System.Label.Failure);
            ErrorLoggerUtil.logErrorEventProCreditDeal('IntegrationEngine', 'processKFSResponse', System.Label.Apex, ex ,pcdId);
        }
        throw new IND_Exception(ex.getMessage());
    }
    return returnStr; //Add response string 
}




      @future
      public static void createIntegrationLogs(Boolean fromProCredit, String pcdId, String request, String encryptedRequest,String response, String encryptedResponse,String serviceName, String elapseTime, String loanApplicationId, String status) {
        if(!fromProCredit){
            IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, response, encryptedResponse, 'Key Fact Statement', elapseTime,loanApplicationId,status);
        }else{
            IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, response, encryptedResponse, 'ProCredit_KFS', elapseTime,pcdId,status);
        }
      }

      public static String smsWrapper(Key_Fact_Statement__c kfs, String pcdId, Boolean fromProCredit, String loanAppId, String mobileNumber, String KFSSmsType){
        Wrapperclass obj = new Wrapperclass(kfs, pcdId, fromProCredit, loanAppId, mobileNumber,KFSSmsType);
        String smsStr = JSON.serialize(obj);
        return smsStr;
      }
    
      public class Wrapperclass{
        public string flag;
        public string kfsId;
        public string kfsOtp;
        public string pcdId;
        public Boolean fromProCredit;
        public string loanApplicationId;
        public string mobileNumber;
        public string KFSSmsType;
    
        public Wrapperclass(Key_Fact_Statement__c kfs, String pcdId, Boolean fromProCredit, String loanAppId, String mobileNumber,String KFSSmsType){
          this.flag = System.Label.KFS_Flag;
          this.kfsId = kfs.Id;
          this.kfsOtp = kfs.Keyfact_Consent_OTP__c;
          this.pcdId = pcdId;
          this.fromProCredit = fromProCredit;
          this.loanApplicationId = loanAppId;
          this.mobileNumber = mobileNumber;
          this.KFSSmsType = KFSSmsType;
        }
      }

@AuraEnabled
public static Map<String,String> doKFSSmsGatewayAPI(String smsRequestString){
    
    if(String.isBlank(smsRequestString)){
        throw new IND_Exception(System.Label.Retry);
    }
    Map<String,String> resp = new Map<String,String>();
    Integration_Configuration__mdt apiConfiguration = IntegrationUtilities.getAPIConfiguration(System.Label.SMSGateway);
    Integer timeout = Integer.valueOf(apiConfiguration.Timeout__c);
    
    
    //if stubs checked in Integration_Configuration then stubs will return
    if(apiConfiguration.IsStub_Required__c != null && apiConfiguration.IsStub_Required__c){
        String stubData = IntegrationUtilities.getStubResponse(System.Label.SMSGateway);
        //return stubData == null ? System.Label.EmptyStubs : stubData;
    }
    
    if(!apiConfiguration.IsActive_Integration__c){
        throw new IND_Exception(System.Label.ServiceDown);
    }
    
    //String resp = '';
    String serviceName = System.Label.SMSGateway  ; // Gaurav : Changes for the Service Name.
    String elapseTime;
    String pcdId = '';
    Boolean fromproCredit = false;
    String loanAppId = '';
    String flag;
    String dealId;
    String KFSSmsType ;
    HttpRequest request;
    try{
        RequestWrapper requestWrapper = (RequestWrapper)IntegrationUtilities.parseJSONRequest(smsRequestString,'RequestWrapper');
        loanAppId = requestWrapper.loanApplicationId;
        pcdId = requestWrapper.pcdId;
        fromproCredit = requestWrapper.fromProCredit;
        flag = requestWrapper.flag;
        dealId = requestWrapper.dealId;
        KFSSmsType = requestWrapper.KFSSmsType;
        if(!fromproCredit){
           // requestWrapper.leadId = applicant.Opportunity__r.Lead_Number__c + '_' + applicant.applicant_number__c;
           requestWrapper.leadId = loanAppId;
        }else{
            requestWrapper.leadId = pcdId;
        }
        
        IND_SMSRequest smsRequest = IND_SMSService.getSmsCallOutRequest(requestWrapper); 
        String url = Consent_Url_Setting__mdt.getInstance('KFS_Consent').Consent_Url__c;
        String returnUrl = String.format(url,  new List<Object>{requestWrapper.kfsId, requestWrapper.kfsOtp});

        CalloutProcessor processor = new CalloutProcessor(System.Label.SMSGateway, smsRequest);
        request = processor.createHttpRequest();
        request.setTimeout(12000);
        
        Long startTime = DateTime.now().getTime();
       String requestfortesting = returnUrl;
       resp.put('status','SUCCESS'); 
       resp.put('requestfortesting',requestfortesting);
       if(KFSSmsType == 'Physical'){
        Key_Fact_Statement__c kfssms = [SELECT Id,Keyfact_Form_SMS_Sent__c FROM Key_Fact_Statement__c WHERE Id=:requestWrapper.kfsId];
        kfssms.Keyfact_Form_SMS_Sent__c = datetime.now();
        update kfssms;
       } 
       /* Key_Fact_Statement__c kfssms = [SELECT Id,Keyfact_Form_SMS_Sent__c FROM Key_Fact_Statement__c WHERE Id=:requestWrapper.kfsId];
    kfssms.Keyfact_Form_SMS_Sent__c = datetime.now();
    update kfssms;
   if( !fromProCredit){
    Opportunity loanAppRec = [SELECT Id,Product_Type__c FROM Opportunity WHERE Id = :loanAppId LIMIT 1];
                           if(loanAppRec.Product_Type__c == System.Label.Tractor && String.isNotBlank(dealId)){
                               Deal_Number__c dealObj = new Deal_Number__c();
                               dealObj.Id = dealId;
                               dealObj.Sub_Stage__c = 'Key Fact Statement';
                               update dealObj;
                           }else if(loanAppRec.Product_Type__c != System.Label.Tractor){
                               Opportunity loanApp = new Opportunity();
                               loanApp.Id = loanAppId;
                               loanApp.Sub_Stage__c = 'Key Fact Statement';
                               update loanApp;
                           }

     }
    */
    if(KFSSmsType == 'Digital'){
        Http http = new Http();
        HttpResponse response = http.send(request);
        
        Long endTime = DateTime.now().getTime();
        elapseTime = String.valueOf((Double)(endTime - startTime)/1000);
        
            if(response != null && response.getStatusCode() == 200){
                IND_SMSResponse apiResponse = (IND_SMSResponse)processor.getHttpResponse(response, System.Label.SMSGateway);
                system.debug('The SMS API response is '+apiResponse.response.status);
                if(apiResponse != null && apiResponse.response.status == 'SUCCESS' && flag == 'KFS'){
                    //resp = apiResponse.response.status;
                    Key_Fact_Statement__c kfssms = [SELECT Id,Keyfact_Form_SMS_Sent__c FROM Key_Fact_Statement__c WHERE Id=:requestWrapper.kfsId];
                    kfssms.Keyfact_Form_SMS_Sent__c = datetime.now();
                    update kfssms;
                    System.debug('pcdId__'+pcdId);
                    if( !fromProCredit){
                        if(String.isNotBlank(loanAppId)){
                           Opportunity loanAppRec = [SELECT Id,Product_Type__c FROM Opportunity WHERE Id = :loanAppId LIMIT 1];
                           if(loanAppRec.Product_Type__c == System.Label.Tractor && String.isNotBlank(dealId)){
                               Deal_Number__c dealObj = new Deal_Number__c();
                               dealObj.Id = dealId;
                               dealObj.Sub_Stage__c = 'Key Fact Statement';
                               update dealObj;
                           }else if(loanAppRec.Product_Type__c != System.Label.Tractor){
                               Opportunity loanApp = new Opportunity();
                               loanApp.Id = loanAppId;
                               loanApp.Sub_Stage__c = 'Key Fact Statement';
                               update loanApp;
                           }
                       }
                   }
                    if(!fromproCredit){
                        IntegrationUtilities.createIntegrationLogger(IntegrationUtilities.getPlainTextForLog(request.getBody()), request.getBody(), IntegrationUtilities.getPlainTextForLog(response.getBody()), response.getBody(), serviceName, elapseTime, loanAppId, System.Label.Success);
                    }else{
                        IntegrationUtilities.createIntegrationLogger(IntegrationUtilities.getPlainTextForLog(request.getBody()), request.getBody(), IntegrationUtilities.getPlainTextForLog(response.getBody()), response.getBody(), 'ProCredit_SMS', elapseTime, pcdId, System.Label.Success);
                    }
                    resp.put('status','SUCCESS'); 
                }else if(apiResponse != null && apiResponse.response.status == 'SUCCESS' && (flag == 'ASC' || flag == 'NASC')){
                    //resp = apiResponse.response.status;
                    if(!fromproCredit){
                        IntegrationUtilities.createIntegrationLogger(IntegrationUtilities.getPlainTextForLog(request.getBody()), request.getBody(), IntegrationUtilities.getPlainTextForLog(response.getBody()), response.getBody(), serviceName, elapseTime, loanAppId, System.Label.Success);
                    }else{
                        IntegrationUtilities.createIntegrationLogger(IntegrationUtilities.getPlainTextForLog(request.getBody()), request.getBody(), IntegrationUtilities.getPlainTextForLog(response.getBody()), response.getBody(), 'ProCredit_SMS', elapseTime, pcdId, System.Label.Success);
                    }
                } /*else {
                    resp.put('status','FAIL'); //= 'FAIL';
                    if(!fromproCredit){
                        IntegrationUtilities.createIntegrationLogger(IntegrationUtilities.getPlainTextForLog(request.getBody()), request.getBody(), IntegrationUtilities.getPlainTextForLog(response.getBody()), response.getBody(), serviceName, elapseTime, loanAppId, System.Label.Failure);
                    }else{
                        IntegrationUtilities.createIntegrationLogger(IntegrationUtilities.getPlainTextForLog(request.getBody()), request.getBody(), IntegrationUtilities.getPlainTextForLog(response.getBody()), response.getBody(), 'ProCredit_SMS', elapseTime, pcdId, System.Label.Failure);
                    } 
                }    */
            } else {
                resp.put('status','FAIL');
                String errString = '[Status Code = '+ response.getStatusCode() +' ] Response-->'+IntegrationUtilities.getPlainTextForLog(response.getBody());
                if(!fromproCredit){
                IntegrationUtilities.createIntegrationLogger(IntegrationUtilities.getPlainTextForLog(request.getBody()), request.getBody(), IntegrationUtilities.getPlainTextForLog(response.getBody()), response.getBody(), serviceName, elapseTime, loanAppId, System.Label.Failure);
                ErrorLoggerUtil.logErrorEvent('CalloutProcessor', 'getHttpResponse', System.Label.Apex, new IND_Exception(errString), loanAppId);
                }else{
                IntegrationUtilities.createIntegrationLogger(IntegrationUtilities.getPlainTextForLog(request.getBody()), request.getBody(), IntegrationUtilities.getPlainTextForLog(response.getBody()), response.getBody(), 'ProCredit_SMS', elapseTime,pcdId, System.Label.Failure);
                ErrorLoggerUtil.logErrorEventProCreditDeal('CalloutProcessor', 'getHttpResponse', System.Label.Apex, new IND_Exception(errString) ,pcdId);
                ProCredit_Deals__c pcd = [SELECT Id,Error_Message__c FROM ProCredit_Deals__c WHERE Id=:pcdId];
                pcd.Error_Message__c =  errString;
                update pcd;
                }
            }
        }
    } catch(Exception ex){
        if(!fromproCredit){
            IntegrationUtilities.createIntegrationLogger(IntegrationUtilities.getPlainTextForLog(request.getBody()), request.getBody(), '', '', serviceName, elapseTime, loanAppId, System.Label.Failure);
            ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'doSmsGatewayAPI', System.Label.Apex, ex,loanAppId);
        }else{
            IntegrationUtilities.createIntegrationLogger(IntegrationUtilities.getPlainTextForLog(request.getBody()), request.getBody(), '', '', 'ProCredit_SMS', elapseTime, pcdId, System.Label.Failure);
            ErrorLoggerUtil.logErrorEventProCreditDeal('IntegrationEngine', 'doSmsGatewayAPI', System.Label.Apex, ex,pcdId);
            Exception errorObject = new IND_Exception(ex.getMessage());
             ProCredit_Deals__c pcd = [SELECT Id,Error_Message__c FROM ProCredit_Deals__c WHERE Id=:pcdId];
                pcd.Error_Message__c =  errorObject.getMessage();
                update pcd;
        }
        throw new IND_Exception(ex.getMessage());
    }
    return resp;
}


    /*
* @Method:      doGSTOnlineCallout
* @Created by:  Bhushan Charde 
* @Description: This method is being used to call the Perfios GST Online using continuation
* @Param:       String - applicantId
* @Return:      ''
*/
    @AuraEnabled(continuation=true cacheable=true)
    public static Object doGSTOnlineCallout(String incomeDetailString){
        Continuation con;
        String loanAppId;
        try{
            if(String.isBlank(incomeDetailString)){
                throw new IND_Exception(System.Label.Retry);
            }
            //Provide API-wise Integration Name to Custom Metadata Configs
            Integration_Configuration__mdt apiConfiguration = IntegrationUtilities.getAPIConfiguration(System.Label.GSTOnline);
            Integer timeout = Integer.valueOf(apiConfiguration.Timeout__c);
            
            //if stubs checked in Integration_Configuration then stubs will return 
            if(apiConfiguration.IsStub_Required__c != null && apiConfiguration.IsStub_Required__c){  
                String stubData = IntegrationUtilities.getStubResponse(System.Label.GSTOnline);
                return stubData == null ? System.Label.EmptyStubs : stubData;  
            }
            
            RequestWrapper requestWrapper = (RequestWrapper)IntegrationUtilities.parseJSONRequest(incomeDetailString,'RequestWrapper');
            //List<Applicant__c> app = [SELECT Id, Contact_number__c, Opportunity__r.Lead_number__c FROM Applicant__c WHERE Id=:requestWrapper.applicantId WITH SECURITY_ENFORCED Limit 1];
            //SF - 268 review comment
            List<Applicant__c> app = [SELECT Id, Contact_number__c, Opportunity__r.Lead_number__c FROM Applicant__c WHERE Id=:requestWrapper.applicantId and In_Active_Applicant__c = false WITH SECURITY_ENFORCED Limit 1];

            List<Income_Details__c> income = [SELECT Id, GST_No__c FROM Income_Details__c WHERE Id=:requestWrapper.incomeDtlId WITH SECURITY_ENFORCED Limit 1];
            
            if(app.isEmpty() || income.isEmpty()){
                throw new IND_Exception(System.Label.Applicantdatamissing);
            } else {
                
                for(Applicant__c applicant:app){
                    requestWrapper.leadId= applicant.Opportunity__r.Lead_Number__c;
                    requestWrapper.contactNumber= applicant.Contact_number__c;
                }
                for(Income_Details__c incomeDtl:income){
                    requestWrapper.GstNumber= incomeDtl.GST_No__c;
                }
            }
            
            loanAppId = requestWrapper.loanApplicationId;
            loanApplicationRef= requestWrapper.loanApplicationId;
            
            IND_PerfiosGSTOnlineRequest gstRequestDetails = IND_PerfiosGSTOnlineService.getPerfiosGSTOnlineRequest(requestWrapper); 
            CalloutProcessor process = new CalloutProcessor(System.Label.GSTOnline, gstRequestDetails);
            HttpRequest request = process.createHttpRequest();  
            
            Long startTime = DateTime.now().getTime();
            
            Carrier carrier = new carrier();
            carrier.setServiceName(System.Label.GSTOnline);
            carrier.setProcessor(process);
            carrier.setRequest(IntegrationUtilities.getPlainTextForLog(request.getBody()));
            carrier.setEncryptedRequest(request.getBody());
            carrier.setStartTime(startTime);
            carrier.setLoanApplicationId(loanAppId);  
            
            //Add callout request to continuation
            con = new Continuation(timeout);        
            con.continuationMethod='processGSTOnlineAPIResponse';
            con.state=carrier;
            con.addHttpRequest(request);
            
            if(Test.isRunningTest()) {
               continuationLabel = con.addHttpRequest(request);
               continuationState = carrier; 
            }  
        } catch(Exception ex) {
            ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'doGSTOnlineCallout', System.Label.Apex, ex, loanAppId);
            throw ex;
        }
        return con;
    }
    
    /*
* @Method:      processGSTOnlineAPIResponse
* @Created by:  Bhushan Charde 
* @Description: This method is being used to handle the response from continuation and return the response to calling processes
* @Param:       Collection - labels
* @Param:       Object - state
* @Return:      Object - response
*/
    @AuraEnabled(cacheable=true)
    public static Object processGSTOnlineAPIResponse(List<String> labels, Object state){
        IND_PerfiosGSTOnlineResponse apiResponse;
        String request='';
        String encryptedRequest='';
        String serviceName='';
        String data;
        HttpResponse response;
        String elapseTime='';
        String loanAppId='';
        try{
            Carrier carrier = (Carrier)state;
            request = carrier.getRequest();
            encryptedRequest = carrier.getEncryptedRequest();
            serviceName = carrier.getServiceName();
            Long startTime = carrier.getStartTime();
            loanAppId = carrier.getLoanApplicationId();
            
            CalloutProcessor processor = carrier.getProcessor();
            response = Continuation.getResponse(labels[0]);
            Long endTime = DateTime.now().getTime();
            elapseTime = String.valueOf((Double)(endTime - startTime)/1000);
            
            if(response != null && response.getStatusCode() == 200) {
                apiResponse = (IND_PerfiosGSTOnlineResponse)processor.getHttpResponse(response, serviceName);
                if(apiResponse != null){
                    data = JSON.serialize(apiResponse);
                    IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, IntegrationUtilities.getPlainTextForLog(response.getBody()), response.getBody(), serviceName, elapseTime, loanAppId,System.Label.Success);
                } else {
                    IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, '', '', serviceName, elapseTime, loanAppId,System.Label.Failure);
                    throw new IND_Exception(System.Label.NoResponse);
                }
                
            } else {
                IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, '', response.getBody(), serviceName, elapseTime, loanAppId,System.Label.Failure);
                String errString = '[Status Code = '+ response.getStatusCode() +' ] Response-->'+IntegrationUtilities.getPlainTextForLog(response.getBody());
                ErrorLoggerUtil.logErrorEvent('CalloutProcessor', 'getHttpResponse', System.Label.Apex, new IND_Exception(errString), loanAppId);
                throw new IND_Exception(System.Label.NoResponse);
            } 
            
        } catch (Exception ex){
            IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, '', '', serviceName, elapseTime, loanAppId,System.Label.Failure);
            ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'processGSTOnlineAPIResponse', System.Label.Apex, ex, loanAppId);
            throw new IND_Exception(ex.getMessage());
        }
        return data;
    }
    
    
    /*
* @Method:      doVahanVehicleValuationCallout
* @Created by:  Satyam More 
* @Description: Method to return Response for Vahan Vehicle Valuation API
* @Param:       String - Applicant Id
* @Return:      String - response
*/
    @AuraEnabled(continuation=true cacheable=true)
    public static Object doVahanVehicleValuationCallout(String vahanVehicleValuation){
        Continuation con;
        String loanAppId;
        try{
            if(String.isBlank(vahanVehicleValuation)){
                throw new IND_Exception(System.Label.Retry);
            }
            //Provide API-wise Integration Name to Custom Metadata Configs
            Integration_Configuration__mdt apiConfiguration = IntegrationUtilities.getAPIConfiguration(System.Label.VahanVehicleValuationAPI);
            Integer timeout = Integer.valueOf(apiConfiguration.Timeout__c);
            
            //if stubs checked in Integration_Configuration then stubs will return 
            if(apiConfiguration.IsStub_Required__c != null && apiConfiguration.IsStub_Required__c){  
                String stubData = IntegrationUtilities.getStubResponse(System.Label.VahanVehicleValuationAPI);
                return stubData == null ? System.Label.EmptyStubs : stubData;  
            }
            
            RequestWrapper requestWrapper = (RequestWrapper)IntegrationUtilities.parseJSONRequest(vahanVehicleValuation,'RequestWrapper');
            loanAppId = requestWrapper.loanApplicationId;
            loanApplicationRef= requestWrapper.loanApplicationId;
            IND_VahanVehicleValuationRequest vahanVehicleValuationRequest = IND_VahanVehicleValuationService.getVahanVehicleValuationCallOutRequest(requestWrapper,loanAppId);
            CalloutProcessor processor= new CalloutProcessor(System.Label.VahanVehicleValuationAPI, vahanVehicleValuationRequest);
            HttpRequest request = processor.createHttpRequest();
            
            Long startTime = DateTime.now().getTime();
            
            Carrier carrier = new carrier();
            carrier.setServiceName(System.Label.VahanVehicleValuationAPI);
            carrier.setProcessor(processor);
            carrier.setRequest(IntegrationUtilities.getPlainTextForLog(request.getBody()));
            carrier.setEncryptedRequest(request.getBody());
            carrier.setStartTime(startTime);
            carrier.setLoanApplicationId(loanAppId);
            
            //Add callout request to continuation
            con = new Continuation(timeout);        
            con.continuationMethod='processVahanVehicleValuationResponse';
            con.state=carrier;
            con.addHttpRequest(request);
            
            if(Test.isRunningTest()) {
               continuationLabel = con.addHttpRequest(request);
               continuationState = carrier; 
            }  
        } catch(Exception ex) {
            ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'doVahanVehicleValuationCallout', System.Label.Apex, ex,loanAppId);
            throw ex;
        }
        return con;
    }
    
    /*
* @Method:      processVahanVehicleValuationResponse
* @Created by:  Satyam More
* @Description: Method to return Response for Vahan Vehicle Valuation API
* @Param:       Collection - labels
* @Param:       Object - state
* @Return:      Object - response
*/
    @AuraEnabled(cacheable=true)
    public static Object processVahanVehicleValuationResponse(List<String> labels, Object state){
        IND_VahanVehicleValuationResponse apiResponse;
        String request='';
        String encryptedRequest='';
        String serviceName='';
        String loanAppId='';
        String data='';
        HttpResponse response;
        String elapseTime='';
        
        try{
            Carrier carrier = (Carrier)state;
            request = carrier.getRequest();
            encryptedRequest = carrier.getEncryptedRequest();
            serviceName = carrier.getServiceName();
            Long startTime = carrier.getStartTime();
            
            CalloutProcessor processor = carrier.getProcessor();
            response = Continuation.getResponse(labels[0]);
            Long endTime = DateTime.now().getTime();
            elapseTime = String.valueOf((Double)(endTime - startTime)/1000);
            loanAppId = carrier.getLoanApplicationId();
            
            if(response != null && response.getStatusCode() == 200){
                apiResponse = (IND_VahanVehicleValuationResponse)processor.getHttpResponse(response, serviceName);
                if(apiResponse != null){
                    IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, IntegrationUtilities.getPlainTextForLog(response.getBody()), response.getBody(), serviceName, elapseTime,loanAppId,System.Label.Success);
                    return JSON.serialize(apiResponse);
                }
                else {
                    IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, IntegrationUtilities.getPlainTextForLog(response.getBody()), response.getBody(), serviceName, elapseTime,loanAppId,System.Label.Failure);
                    throw new IND_Exception(System.Label.NoResponse);               
                }
            }
            else {
                String errString = '[Status Code = '+ response.getStatusCode() +' ] Response-->'+IntegrationUtilities.getPlainTextForLog(response.getBody());
                IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, errString, response.getBody(), serviceName, elapseTime, loanAppId, System.Label.Failure);
                ErrorLoggerUtil.logErrorEvent('CalloutProcessor', 'getHttpResponse', System.Label.Apex, new IND_Exception(errString), loanAppId);
                throw new IND_Exception(System.Label.NoResponse);
            } 
        } catch (Exception ex){
            IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, '', '', serviceName, elapseTime,loanAppId,System.Label.Failure);
            ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'processVahanVehicleValuationResponse', System.Label.Apex, ex,loanAppId);
            throw new IND_Exception(ex.getMessage());
        }
    }
    /*
* @Method:      doEPFOAuthCallout
* @Created by:  Divya Jawale 
* @Description: Method to return Response for EPFO Auth API
* @Param:       Id - Applicant Id , String uanNumber
* @Return:      String - response
*/
@AuraEnabled(continuation=true cacheable=true)
public static Object doEPFOAuthCallout(Id applicantId,String uanNumber,String loanAppId){
    Continuation con;
    try{
        if(String.isBlank(applicantId)){
            throw new IND_Exception(System.Label.Retry);
        }
        //Provide API-wise Integration Name to Custom Metadata Configs
        Integration_Configuration__mdt apiConfiguration = IntegrationUtilities.getAPIConfiguration(System.Label.EPFOAuthAPI);
        Integer timeout = Integer.valueOf(apiConfiguration.Timeout__c);
        
        //if stubs checked in Integration_Configuration then stubs will return 
        if(apiConfiguration.IsStub_Required__c != null && apiConfiguration.IsStub_Required__c){  
            String stubData = IntegrationUtilities.getStubResponse(System.Label.EPFOAuthAPI);
            return stubData == null ? System.Label.EmptyStubs : stubData;  
        }
        
        Applicant__c app = [SELECT Id, applicant_number__c,Opportunity__r.Lead_Number__c, Contact_number__c FROM Applicant__c WHERE ID=:applicantId WITH SECURITY_ENFORCED];//CISP-2879
        loanApplicationRef= loanAppId;
        IND_EPFOAuthRequest epfoAuthRequest = IND_EPFOAuthService.getEPFOAuthCallOut(app,uanNumber,loanAppId);
        CalloutProcessor processor= new CalloutProcessor(System.Label.EPFOAuthAPI, epfoAuthRequest);
        HttpRequest request = processor.createHttpRequest();
        Long startTime = DateTime.now().getTime();
        List<Object> objList = new List<Object>();
        objList.add(app);
        Carrier carrier = new carrier();
        carrier.setServiceName(System.Label.EPFOAuthAPI);
        carrier.setProcessor(processor);
        carrier.setRequest(IntegrationUtilities.getPlainTextForLog(request.getBody()));
        carrier.setEncryptedRequest(request.getBody());
        carrier.setStartTime(startTime);
        carrier.setLoanApplicationId(loanAppId);
        carrier.setTempObject(objList);
        
        //Add callout request to continuation
        con = new Continuation(timeout);        
        con.continuationMethod='processEPFOAuthResponse';
        con.state=carrier;
        con.addHttpRequest(request);
        
        if(Test.isRunningTest()) {
           continuationLabel = con.addHttpRequest(request);
           continuationState = carrier; 
        }  
    } catch(Exception ex) {
        ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'doEPFOAuthCallout', System.Label.Apex, ex,loanAppId);
        throw ex;
    }
    return con;
}

/*
* @Method:      processEPFOAuthResponse
* @Created by:  Divya Jawale
* @Description: Method to return Response for FPFO Auth API
* @Param:       Collection - labels
* @Param:       Object - state
* @Return:      Object - response
*/
@AuraEnabled(cacheable=true)
public static Object processEPFOAuthResponse(List<String> labels, Object state){
    IND_EPFOAuthResponse apiResponse;
    String request='';
    String encryptedRequest='';
    String serviceName='';
    String data='';
    String loanAppId='';
    HttpResponse response;
    String elapseTime='';
    List<Object> objList;
    
    try{
        Carrier carrier = (Carrier)state;
        request = carrier.getRequest();
        encryptedRequest = carrier.getEncryptedRequest();
        serviceName = carrier.getServiceName();
        Long startTime = carrier.getStartTime();
        objList = carrier.getTempObject();
        CalloutProcessor processor = carrier.getProcessor();
        response = Continuation.getResponse(labels[0]);
        Long endTime = DateTime.now().getTime();
        elapseTime = String.valueOf((Double)(endTime - startTime)/1000);
        loanAppId = carrier.getLoanApplicationId();
        if(response != null && response.getBody() != ''){
            Applicant__c app = (Applicant__c)objList.get(0);
            apiResponse = (IND_EPFOAuthResponse)processor.getHttpResponse(response, serviceName);
            
            if(apiResponse != null){
                data = JSON.serialize(apiResponse);
                IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, IntegrationUtilities.getPlainTextForLog(response.getBody()), response.getBody(), serviceName, elapseTime,loanAppId,System.Label.Success);
            }else{
                IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, IntegrationUtilities.getPlainTextForLog(response.getBody()), response.getBody(), serviceName, elapseTime,loanAppId,System.Label.Failure);
                throw new IND_Exception(System.Label.NoResponse);
            } 
        }
        else{
            String errString = '[Status Code = '+ response.getStatusCode() +' ] Response-->'+IntegrationUtilities.getPlainTextForLog(response.getBody());
            IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, errString, response.getBody(), serviceName, elapseTime, loanAppId, System.Label.Failure);
            ErrorLoggerUtil.logErrorEvent('CalloutProcessor', 'getHttpResponse', System.Label.Apex, new IND_Exception(errString), loanAppId);
            throw new IND_Exception(System.Label.NoResponse);
        }
    } catch (Exception ex){
        
        IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, '', '', serviceName, elapseTime,loanAppId,System.Label.Failure);
        ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'processEPFOAuthResponse', System.Label.Apex, ex);
        throw new IND_Exception(ex.getMessage());
    }
    return data;
}
    
    /*
* @Method:      doEPFUANLookupCallout
* @Created by:  Divya Jawale 
* @Description: Method to return Response for EPF UAN Lookup API
* @Param:       String - Applicant Id
* @Return:      String - response
*/
@AuraEnabled(continuation=true cacheable=true)
public static Object doEPFUANLookupCallout(Id applicantId,String loanAppId){
    Continuation con;
    try{
        if(String.isBlank(applicantId)){
            throw new IND_Exception(System.Label.Retry);
        }
        //Provide API-wise Integration Name to Custom Metadata Configs
        Integration_Configuration__mdt apiConfiguration = IntegrationUtilities.getAPIConfiguration(System.Label.EPFUANLookupAPI);
        Integer timeout = Integer.valueOf(apiConfiguration.Timeout__c);
        
        //if stubs checked in Integration_Configuration then stubs will return 
        if(apiConfiguration.IsStub_Required__c != null && apiConfiguration.IsStub_Required__c){  
            String stubData = IntegrationUtilities.getStubResponse(System.Label.EPFUANLookupAPI);
            return stubData == null ? System.Label.EmptyStubs : stubData;  
        }
        
        //Applicant__c app = [SELECT Id, Opportunity__r.Lead_Number__c, Contact_number__c FROM Applicant__c WHERE ID=:applicantId WITH SECURITY_ENFORCED];
        //SF - 266 Review comment
        Applicant__c app = [SELECT Id,applicant_number__c ,Opportunity__r.Lead_Number__c, Contact_number__c FROM Applicant__c WHERE ID=:applicantId and In_Active_Applicant__c = false WITH SECURITY_ENFORCED];//CISP-2879
        loanApplicationRef= loanAppId;
        IND_EPFUANLookupRequest epfoUANLookupRequest = IND_EPFUANLookupService.getEPFUANLookupCallOutRequest(app,loanAppId);
        CalloutProcessor processor= new CalloutProcessor(System.Label.EPFUANLookupAPI, epfoUANLookupRequest);
        HttpRequest request = processor.createHttpRequest();
        Long startTime = DateTime.now().getTime();
        List<Object> objList = new List<Object>();
        objList.add(app);
        Carrier carrier = new carrier();
        carrier.setServiceName(System.Label.EPFUANLookupAPI);
        carrier.setProcessor(processor);
        carrier.setRequest(IntegrationUtilities.getPlainTextForLog(request.getBody()));
        carrier.setEncryptedRequest(request.getBody());
        carrier.setStartTime(startTime);
        carrier.setLoanApplicationId(loanAppId);
        carrier.setTempObject(objList);
        
        //Add callout request to continuation
        con = new Continuation(timeout);        
        con.continuationMethod='processEPFUANLookupResponse';
        con.state=carrier;
        con.addHttpRequest(request);
        
        if(Test.isRunningTest()) {
           continuationLabel = con.addHttpRequest(request);
           continuationState = carrier; 
        }  
    } catch(Exception ex) {
        ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'doEPFUANLookupCallout', System.Label.Apex, ex,loanAppId);
        throw ex;
    }
    return con;
}

/*
* @Method:      processEPFUANLookupResponse
* @Created by:  Divya Jawale
* @Description: Method to return Response for EPF UAN Lookup API
* @Param:       Collection - labels
* @Param:       Object - state
* @Return:      Object - response
*/
@AuraEnabled(cacheable=true)
public static Object processEPFUANLookupResponse(List<String> labels, Object state){
    IND_EPFUANLookupResponse apiResponse;
    String request='';
    String encryptedRequest='';
    String serviceName='';
    String data='';
    String loanAppId='';
    HttpResponse response;
    String elapseTime='';
    List<Object> objList;
    
    try{
        Carrier carrier = (Carrier)state;
        request = carrier.getRequest();
        encryptedRequest = carrier.getEncryptedRequest();
        serviceName = carrier.getServiceName();
        Long startTime = carrier.getStartTime();
        objList = carrier.getTempObject();
        CalloutProcessor processor = carrier.getProcessor();
        response = Continuation.getResponse(labels[0]);
        Long endTime = DateTime.now().getTime();
        elapseTime = String.valueOf((Double)(endTime - startTime)/1000);
        loanAppId = carrier.getLoanApplicationId();
        
        if(response != null && response.getBody() != ''){
            apiResponse = (IND_EPFUANLookupResponse)processor.getHttpResponse(response, serviceName);
            if(apiResponse != null){
                IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, IntegrationUtilities.getPlainTextForLog(response.getBody()), response.getBody(), serviceName, elapseTime,loanAppId,System.Label.Success);
                data = JSON.serialize(apiResponse);
            }else{
                IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, IntegrationUtilities.getPlainTextForLog(response.getBody()), response.getBody(), serviceName, elapseTime,loanAppId,System.Label.Failure);
                throw new IND_Exception(System.Label.NoResponse);
            } 
        }
        else{
            String errString = '[Status Code = '+ response.getStatusCode() +' ] Response-->'+IntegrationUtilities.getPlainTextForLog(response.getBody());
            IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, errString, response.getBody(), serviceName, elapseTime, loanAppId, System.Label.Failure);
            ErrorLoggerUtil.logErrorEvent('CalloutProcessor', 'getHttpResponse', System.Label.Apex, new IND_Exception(errString), loanAppId);
            throw new IND_Exception(System.Label.NoResponse);
        }
    } catch (Exception ex){
        
        IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, '', '', serviceName, elapseTime,loanAppId,System.Label.Failure);
        ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'processEPFUANLookupResponse', System.Label.Apex, ex);
        throw new IND_Exception(ex.getMessage());
    }
    return data;
}
    
    /*
* @Method:      doCarwalePricesCallout
* @Created by:  Satyam More 
* @Description: Method to return Response for Carwale Prices API
* @Param:       String - CarwalePrices
* @Return:      String - response
*/
   @AuraEnabled(continuation=true cacheable=true)
    public static Object doCarwalePricesCallout(String CarwalePrices,String productType){ //CISP-654
        system.debug('doCarwalePricesCallout call--' + productType);
        Continuation con;
        String loanAppId;
        try{
            if(String.isBlank(CarwalePrices)){
                throw new IND_Exception(System.Label.Retry);
            }
            //Provide API-wise Integration Name to Custom Metadata Configs
            Integration_Configuration__mdt apiConfiguration = new Integration_Configuration__mdt();
            if(productType == 'Two Wheeler'){
                system.debug('productType--' + productType);
                apiConfiguration = IntegrationUtilities.getAPIConfiguration(System.Label.BikeWale_Prices);
            }
            else{
                apiConfiguration = IntegrationUtilities.getAPIConfiguration(System.Label.CarWalePrices);
            }
            
            Integer timeout = Integer.valueOf(apiConfiguration.Timeout__c);
            
            //if stubs checked in Integration_Configuration then stubs will return 
            if(apiConfiguration.IsStub_Required__c != null && apiConfiguration.IsStub_Required__c){  
                String stubData = '';
                if(productType == 'Two Wheeler'){
                    IntegrationUtilities.getStubResponse(System.Label.BikeWale_Prices);
                }
                else{
                    IntegrationUtilities.getStubResponse(System.Label.CarWalePrices);
                }
                
                return stubData == null ? System.Label.EmptyStubs : stubData;  
            }
            
            RequestWrapper requestWrapper = (RequestWrapper)IntegrationUtilities.parseJSONRequest(CarwalePrices,'RequestWrapper');
            loanAppId = requestWrapper.loanApplicationId;
            Applicant__c app = [SELECT Id,applicant_number__c FROM Applicant__c WHERE Opportunity__c =: loanAppId AND Applicant_Type__c =: System.Label.Borrower AND In_Active_Applicant__c = false WITH SECURITY_ENFORCED LIMIT 1];//CISP-2879
            requestWrapper.leadId = requestWrapper.leadId + '_' + app.applicant_number__c;//CISP-2879
            loanApplicationRef= requestWrapper.loanApplicationId;
            IND_CarwalePricesRequest carwalePricesRequest = IND_CarwalePricesService.getCarwalePricesCallOutRequest(requestWrapper,loanAppId);
            CalloutProcessor processor;
            if(productType == 'Two Wheeler'){
                processor= new CalloutProcessor(System.Label.BikeWale_Prices, carwalePricesRequest); 
            }else{
                 processor= new CalloutProcessor(System.Label.CarWalePrices, carwalePricesRequest);
            }
            HttpRequest request = new HttpRequest() ;
            if(productType == 'Two Wheeler'){
               request = processor.createHttpRequestForReverseStatus();
            }else{
               request = processor.createHttpRequest();
            }
            
            Long startTime = DateTime.now().getTime();
            
            Carrier carrier = new carrier();
            if(productType == 'Two Wheeler'){
                carrier.setServiceName(System.Label.BikeWale_Prices);
            }else{
                carrier.setServiceName(System.Label.CarWalePrices);
            }
            
            carrier.setProcessor(processor);
            carrier.setRequest(IntegrationUtilities.getPlainTextForLog(request.getBody()));
            carrier.setEncryptedRequest(request.getBody());
            carrier.setStartTime(startTime);
            carrier.setLoanApplicationId(loanAppId);
            
            //Add callout request to continuation
            con = new Continuation(timeout);   
            if(productType == 'Two Wheeler'){
                system.debug('in Continuation');
                con.continuationMethod='processBikewalePricesResponse';
            }
            else{
                con.continuationMethod='processCarwalePricesResponse';
            }
            
            con.state=carrier;
            con.addHttpRequest(request);
            
            if(Test.isRunningTest()) {
               continuationLabel = con.addHttpRequest(request);
               continuationState = carrier; 
            }  
        } catch(Exception ex) {
            ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'doCarwalePricesCallout', System.Label.Apex, ex,loanAppId);
            throw ex;
        }
        return con;
    }
    
    //CISP-654
    /*
* @Method:      processBikewalePricesResponse
* @Created by:  Poonam
* @Description: Method to return Response for Bikewale Prices API
* @Param:       Collection - labels
* @Param:       Object - state
* @Return:      Object - response
*/
    @AuraEnabled(cacheable=true)
    public static Object processBikewalePricesResponse(List<String> labels, Object state){
        system.debug('inside processBikewalePricesResponse');
        IND_BikewalePricesResponse apiResponse;
        String request='';
        String encryptedRequest='';
        String serviceName='';
        String loanAppId='';
        String data='';
        HttpResponse response;
        String elapseTime='';
        
        
        try{
            Carrier carrier = (Carrier)state;
            request = carrier.getRequest();
            encryptedRequest = carrier.getEncryptedRequest();
            serviceName = carrier.getServiceName();
            Long startTime = carrier.getStartTime();
            CalloutProcessor processor = carrier.getProcessor();
            response = Continuation.getResponse(labels[0]);
            system.debug('response ***' + response);
            Long endTime = DateTime.now().getTime();
            elapseTime = String.valueOf((Double)(endTime - startTime)/1000);
            loanAppId = carrier.getLoanApplicationId();
            if(response != null && response.getStatusCode() == 200){
                system.debug('response ---' + response);
                
                apiResponse = (IND_BikewalePricesResponse)processor.getHttpResponse(response, serviceName);
                if(apiResponse != null){
                    IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, IntegrationUtilities.getPlainTextForLog(response.getBody()), response.getBody(), serviceName, elapseTime,loanAppId,System.Label.Success);
                    return JSON.serialize(apiResponse);
                }
                else {
                    IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, IntegrationUtilities.getPlainTextForLog(response.getBody()), response.getBody(), serviceName, elapseTime,loanAppId,System.Label.Failure);
                    throw new IND_Exception(System.Label.NoResponse);                
                }
            }
            else {
                String errString = '[Status Code = '+ response.getStatusCode() +' ] Response-->'+IntegrationUtilities.getPlainTextForLog(response.getBody());
                IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, errString, response.getBody(), serviceName, elapseTime, loanAppId, System.Label.Failure);
                ErrorLoggerUtil.logErrorEvent('CalloutProcessor', 'getHttpResponse', System.Label.Apex, new IND_Exception(errString), loanAppId);
                throw new IND_Exception(System.Label.NoResponse);
            } 
        } catch (Exception ex){
            system.debug('exception line at '+ex.getLineNumber()+'message:'+ex.getMessage()+'stact:'+ex.getStackTraceString());
            IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, '', '', serviceName, elapseTime,loanAppId,System.Label.Failure);
            ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'IND_BikewalePricesResponse', System.Label.Apex, ex,loanAppId);
            throw new IND_Exception(ex.getMessage());
        }
    }//CISP-654
    
    /*
* @Method:      processCarwalePricesResponse
* @Created by:  Satyam More
* @Description: Method to return Response for CarWale Prices API
* @Param:       Collection - labels
* @Param:       Object - state
* @Return:      Object - response
*/
    @AuraEnabled(cacheable=true)
    public static Object processCarwalePricesResponse(List<String> labels, Object state){
        IND_CarwalePricesResponse apiResponse;
        String request='';
        String encryptedRequest='';
        String serviceName='';
        String loanAppId='';
        String data='';
        HttpResponse response;
        String elapseTime='';
        
        
        try{
            Carrier carrier = (Carrier)state;
            request = carrier.getRequest();
            encryptedRequest = carrier.getEncryptedRequest();
            serviceName = carrier.getServiceName();
            Long startTime = carrier.getStartTime();
            CalloutProcessor processor = carrier.getProcessor();
            response = Continuation.getResponse(labels[0]);
            Long endTime = DateTime.now().getTime();
            elapseTime = String.valueOf((Double)(endTime - startTime)/1000);
            loanAppId = carrier.getLoanApplicationId();
            if(response != null && response.getStatusCode() == 200){
                apiResponse = (IND_CarwalePricesResponse)processor.getHttpResponse(response, serviceName);
                if(apiResponse != null){
                    IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, IntegrationUtilities.getPlainTextForLog(response.getBody()), response.getBody(), serviceName, elapseTime,loanAppId,System.Label.Success);
                    return JSON.serialize(apiResponse);
                }
                else {
                    IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, IntegrationUtilities.getPlainTextForLog(response.getBody()), response.getBody(), serviceName, elapseTime,loanAppId,System.Label.Failure);
                    throw new IND_Exception(System.Label.NoResponse);                
                }
            }
            else {
                String errString = '[Status Code = '+ response.getStatusCode() +' ] Response-->'+IntegrationUtilities.getPlainTextForLog(response.getBody());
                IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, errString, response.getBody(), serviceName, elapseTime, loanAppId, System.Label.Failure);
                ErrorLoggerUtil.logErrorEvent('CalloutProcessor', 'getHttpResponse', System.Label.Apex, new IND_Exception(errString), loanAppId);
                throw new IND_Exception(System.Label.NoResponse);
            } 
        } catch (Exception ex){
            system.debug('exception line at '+ex.getLineNumber()+'message:'+ex.getMessage()+'stact:'+ex.getStackTraceString());
            IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, '', '', serviceName, elapseTime,loanAppId,System.Label.Failure);
            ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'processCarwalePricesResponse', System.Label.Apex, ex,loanAppId);
            throw new IND_Exception(ex.getMessage());
        }
    }
    
    /*
* @Method:      doDealEligibleRefinanceCallout
* @Created by:  Divya Jawale 
* @Description: Method to return Response for Deal Eligible Refinance API
* @Param:       String - Applicant Id
* @Return:      String - response
*/
    @AuraEnabled(continuation=true)
    public static Object doDealEligibleRefinanceCallout(Id opportunityId, String dealNumber){
        Continuation con;
		String loanAppId;
        try{
            if(String.isBlank(opportunityId)){
                throw new IND_Exception(System.Label.Retry);
            }
            //Provide API-wise Integration Name to Custom Metadata Configs
            Integration_Configuration__mdt apiConfiguration = IntegrationUtilities.getAPIConfiguration(System.Label.DealEligibleRefinanceAPI);
            Integer timeout = Integer.valueOf(apiConfiguration.Timeout__c);
            Opportunity opp = [SELECT Id,Parent_Deal_number__c,Lead_Number__c,Product_Type__c FROM Opportunity WHERE ID=:opportunityId WITH SECURITY_ENFORCED];
            loanApplicationRef= opportunityId;
			loanAppId = opportunityId;
			IND_DealEligibleRefinanceRequest dealEligibleRequest = IND_DealEligibleRefinanceService.getDealEligibleRefinance(opp,dealNumber);
            CalloutProcessor processor= new CalloutProcessor(System.Label.DealEligibleRefinanceAPI, dealEligibleRequest);
            HttpRequest request = processor.createHttpRequest();
            Long startTime = DateTime.now().getTime();
            List<Object> objList = new List<Object>();
            objList.add(opp);
            Carrier carrier = new carrier();
            carrier.setServiceName(System.Label.DealEligibleRefinanceAPI);
            carrier.setProcessor(processor);
            carrier.setRequest(IntegrationUtilities.getPlainTextForLog(request.getBody()));
            carrier.setEncryptedRequest(request.getBody());
            carrier.setStartTime(startTime);
            carrier.setTempObject(objList);
			carrier.setLoanApplicationId(loanAppId);
            
            //Add callout request to continuation
            con = new Continuation(timeout);        
            con.continuationMethod='processDealEligibleRefinanceResponse';
            con.state=carrier;
            con.addHttpRequest(request);
            
            if(Test.isRunningTest()) {
               continuationLabel = con.addHttpRequest(request);
               continuationState = carrier; 
            }  
        } catch(Exception ex) {
            ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'doDealEligibleRefinanceCallout', System.Label.Apex, ex);
            throw ex;
        }
        return con;
    }
    
    /*
* @Method:      processDealEligibleRefinanceResponse
* @Created by:  Divya Jawale
* @Description: Method to return Response for Deal Eligible Refinance API
* @Param:       Collection - labels
* @Param:       Object - state
* @Return:      Object - response
*/
    @AuraEnabled
    public static Object processDealEligibleRefinanceResponse(List<String> labels, Object state){
        IND_DealEligibleRefinanceResponse apiResponse;
        String request='';
        String encryptedRequest='';
        String serviceName='';
        String data='';
        HttpResponse response;
        String elapseTime='';
        List<Object> objList;
		String loanAppId='';
        
        try{
            Carrier carrier = (Carrier)state;
            request = carrier.getRequest();
            encryptedRequest = carrier.getEncryptedRequest();
            serviceName = carrier.getServiceName();
            Long startTime = carrier.getStartTime();
            objList = carrier.getTempObject();
            CalloutProcessor processor = carrier.getProcessor();
            response = Continuation.getResponse(labels[0]);
            Long endTime = DateTime.now().getTime();
            elapseTime = String.valueOf((endTime - startTime)/1000);
			loanAppId = carrier.getLoanApplicationId();
            
            if(response != null && response.getBody() != ''){
                apiResponse = (IND_DealEligibleRefinanceResponse)processor.getHttpResponse(response, serviceName);
                if(apiResponse != null){
                     IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, IntegrationUtilities.getPlainTextForLog(response.getBody()), response.getBody(), serviceName, elapseTime, loanAppId, System.Label.Success);
                    data = JSON.serialize(apiResponse);
                }else{
                    throw new IND_Exception(System.Label.NoResponse);    
                } 
            }
            else{
                      
                throw new IND_Exception(System.Label.NoResponse);    
            }
        } catch (Exception ex){
            
            IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, '', '', serviceName, elapseTime, loanAppId, System.Label.Failure); 
            ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'processDealEligibleRefinanceResponse', System.Label.Apex, ex, loanAppId);
            throw new IND_Exception(ex.getMessage());
        }
        return data;
    }
    
    /*
* @Method:      doRunEmiEngineCallout
* @Created by:  Satyam More
* @Description: Continuation for Run Emi Engine API
* @Param:       String - 
* @Return:      Object - continuation
*/
    
@AuraEnabled(continuation=true cacheable=true)
public static Object doRunEmiEngineCallout(String runEmiEngine){
    Continuation con;
    String loanAppId;
    try{
        if(String.isBlank(runEmiEngine)){
            throw new IND_Exception(System.Label.Retry);
        }
        //Provide API-wise Integration Name to Custom Metadata Configs
        Integration_Configuration__mdt apiConfiguration = IntegrationUtilities.getAPIConfiguration(System.Label.RunEMIEngine);
        Integer timeout = Integer.valueOf(apiConfiguration.Timeout__c);

        //if stubs checked in Integration_Configuration then stubs will return 
        if(apiConfiguration.IsStub_Required__c != null && apiConfiguration.IsStub_Required__c){  
            String stubData = IntegrationUtilities.getStubResponse(System.Label.RunEMIEngine);
            return stubData == null ? System.Label.EmptyStubs : stubData;  
        }        
        RequestWrapper requestWrapper = (RequestWrapper)IntegrationUtilities.parseJSONRequest(runEmiEngine,'RequestWrapper');
        loanAppId = requestWrapper.loanApplicationId;
        loanApplicationRef= requestWrapper.loanApplicationId;
		List<Applicant__c> app = [SELECT applicant_number__c, Applicant_Type__c,opportunity__r.Lead_Number__c   ,opportunity__r.Parent_Deal_number__c // CISP-112 -- Added opportunity__r.Parent_Deal_number__c field in the query.
                                      FROM Applicant__c 
                                      WHERE id =: requestWrapper.applicantId 
                                      and 
 									  In_Active_Applicant__c=false WITH SECURITY_ENFORCED limit 1];
		if(!app.isEmpty()){
			for(Applicant__c applicant:app){
				requestWrapper.applicantNumber = applicant.applicant_number__c;
				requestWrapper.LeadId=applicant.opportunity__r.Lead_Number__c;
				requestWrapper.parentDealNo=applicant.opportunity__r.Parent_Deal_number__c; // CISP-112
			}
		}
		else{
			throw new IND_Exception(System.Label.Applicantdatamissing);
		}
		List<CIBIL_Details__c> cibilDetails = [Select CIC_No__c 
											   FROM CIBIL_Details__c 
											   WHERE Applicant__c=:requestwrapper.applicantId WITH SECURITY_ENFORCED Limit 1];
		
		if(!cibilDetails.isEmpty()){
			requestWrapper.cicNo = cibilDetails[0].CIC_No__c;
		}
        IND_RunEmiEngineRequest runEmiEngineRequest = IND_RunEmiEngineService.getRunEmiEngineCallOutRequest(requestWrapper,loanAppId);
        CalloutProcessor processor= new CalloutProcessor(System.Label.RunEMIEngine, runEmiEngineRequest);
        HttpRequest request = processor.createHttpRequest();
        Long startTime = DateTime.now().getTime();
        Carrier carrier = new carrier();
        carrier.setServiceName(System.Label.RunEMIEngine);
        carrier.setProcessor(processor);
        carrier.setRequest(IntegrationUtilities.getPlainTextForLog(request.getBody()));
        carrier.setEncryptedRequest(request.getBody());
        carrier.setStartTime(startTime); 
        carrier.setLoanApplicationId(loanAppId);
        //Add callout request to continuation
        con = new Continuation(timeout);        
        con.continuationMethod='processRunEmiEngineCalloutResponse';
        con.state=carrier;
        con.addHttpRequest(request);
        
        if(Test.isRunningTest()) {
           continuationLabel = con.addHttpRequest(request);
           continuationState = carrier; 
        }  
    } catch(Exception ex) {
        ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'doRunEmiEngineCallout', System.Label.Apex, ex,loanAppId);
        throw ex;
    }
    return con;
}


/*
* @Method:      processRunEmiEngineCalloutResponse
* @Created by:  Aman Mundhada 
* @Description: Callback method to return Response for Run Emi Engine API
* @Param:       Collection - labels
* @Param:       Object - state
* @Return:      Object - response
*/
@AuraEnabled(cacheable=true)
public static Object processRunEmiEngineCalloutResponse(List<String> labels, Object state){
    IND_RunEmiEngineResponse apiResponse;
    String request='';
    String encryptedRequest='';
    String serviceName='';
    String loanAppId='';
    HttpResponse response;
    String elapseTime='';        
    try{            
        Carrier carrier = (Carrier)state;
        request = carrier.getRequest();
        encryptedRequest = carrier.getEncryptedRequest();
        serviceName = carrier.getServiceName();
        Long startTime = carrier.getStartTime();            
        CalloutProcessor processor = carrier.getProcessor();
        response = Continuation.getResponse(labels[0]);
        Long endTime = DateTime.now().getTime();
        elapseTime = String.valueOf((Double)(endTime - startTime)/1000);
        loanAppId = carrier.getLoanApplicationId();
        
        if(response != null && response.getStatusCode() == 200){
            apiResponse = (IND_RunEmiEngineResponse)processor.getHttpResponse(response, serviceName);     
            if(apiResponse!=null){
                IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, IntegrationUtilities.getPlainTextForLog(response.getBody()), response.getBody(), serviceName, elapseTime,loanAppId,System.Label.Success);
                return JSON.serialize(apiResponse);
            } else {
                IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, IntegrationUtilities.getPlainTextForLog(response.getBody()), response.getBody(), serviceName, elapseTime,loanAppId,System.Label.Failure);
                throw new IND_Exception(System.Label.NoResponse);                
            }
        }
        else {
            String errString = '[Status Code = '+ response.getStatusCode() +' ] Response-->'+IntegrationUtilities.getPlainTextForLog(response.getBody());
            IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, errString, response.getBody(), serviceName, elapseTime, loanAppId, System.Label.Failure);
            ErrorLoggerUtil.logErrorEvent('CalloutProcessor', 'getHttpResponse', System.Label.Apex, new IND_Exception(errString), loanAppId);
            throw new IND_Exception(System.Label.NoResponse);
        } 
    } catch (Exception ex){
        IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, '', '', serviceName, elapseTime,loanAppId,System.Label.Failure);
        ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'processRunEmiEngineCalloutResponse', System.Label.Apex, ex,loanAppId);
        throw new IND_Exception(ex.getMessage());
    }
}
      
    // @Method:      doPerfiosGenerateLinkCallout
    // @Created by:  Manish Baldota 
    // @Description: This method is being used to call the Membership API using continuation
    // @Param:       String - applicantId
    // @Param:       Stirng - incomeDetailsId
    // @Param:       Stirng - loanApplicationId
    // @Return:      ''
    
    @AuraEnabled(continuation=true cacheable=true)
    public static Object doPerfiosGenerateLinkCallout(String incomeDetailString,string executivemobileno){ //CISP 2973: Added executivemobileno as a parameter 
        system.debug('incomeDetailString -- '+incomeDetailString);
        Continuation con;
        String loanAppId;
        try{
            //Provide API-wise Integration Name to Custom Metadata Configs
            Integration_Configuration__mdt apiConfiguration = IntegrationUtilities.getAPIConfiguration(System.Label.PerfiosBSGenerateLink);
            Integer timeout = Integer.valueOf(apiConfiguration.Timeout__c);
            
            //if stubs checked in Integration_Configuration then stubs will return 
            if(apiConfiguration.IsStub_Required__c != null && apiConfiguration.IsStub_Required__c){  
                String stubData = IntegrationUtilities.getStubResponse(System.Label.PerfiosBSGenerateLink);
                return stubData == null ? System.Label.EmptyStubs : stubData;  
            }
            
            if(String.isBlank(incomeDetailString)){
                throw new IND_Exception(System.Label.Retry);
            }
             system.debug('incomeDetailString 2-- ');
            RequestWrapper requestWrapper = (RequestWrapper)IntegrationUtilities.parseJSONRequest(incomeDetailString,'RequestWrapper');
            List<Income_Details__c> incomeDetails = [SELECT Id,Capture_Income_Method__c,Applicant__r.Contact_number__c,
                                                Applicant__r.Opportunity__r.Lead_number__c,Applicant__r.Opportunity__r.Loan_amount__c,
                                                Applicant__r.Opportunity__r.Required_Tenure__c,Applicant__r.Email_Id__c,
                                                From_Month__c,To_Month__c,Employer_Business_Name__c,Is_Salaried__c,Is_Self_Employed__c,Applicant__r.applicant_number__c
                                                FROM Income_Details__c WHERE Id=:requestWrapper.incomeDetailId WITH SECURITY_ENFORCED];//CISP-2879
            
            if(incomeDetails.isEmpty() && incomeDetails.isEmpty()){
				throw new IND_Exception(System.Label.Applicantdatamissing);
            } else {
                for(Income_Details__c income:incomeDetails){
                    requestWrapper.incomeDetails= income;
                }
            }
             system.debug('incomeDetailString 3-- ');
            loanAppId = requestWrapper.loanApplicationId;
            loanApplicationRef= requestWrapper.loanApplicationId;
            //Creating Request
            IND_PerfiosBSGenerateLinkRequest requestDetails = IND_PerfiosBSGenerateLinkService.getCallOutRequest(requestWrapper, executivemobileno );  //CISP 2973: Added executivemobileno as a parameter 
            CalloutProcessor process = new CalloutProcessor(System.Label.PerfiosBSGenerateLink, requestDetails);
            HttpRequest request = process.createHttpRequest();  
            
            Long startTime = DateTime.now().getTime();
            
            Carrier carrier = new carrier();
            carrier.setServiceName(System.Label.PerfiosBSGenerateLink);
            carrier.setProcessor(process);
            carrier.setRequest(IntegrationUtilities.getPlainTextForLog(request.getBody()));
            carrier.setEncryptedRequest(request.getBody());
            carrier.setStartTime(startTime);
            carrier.setLoanApplicationId(loanAppId);  
            
            //Add callout request to continuation
            con = new Continuation(timeout);        
            con.continuationMethod='processPerfiosGenerateLinkAPIResponse';
            con.state=carrier;
            con.addHttpRequest(request);
            
            if(Test.isRunningTest()) {
               continuationLabel = con.addHttpRequest(request);
               continuationState = carrier; 
            }  
        } catch(Exception ex) {
            ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'doPerfiosGenerateLinkCallout', System.Label.Apex, ex, loanAppId);
            throw new AuraHandledException(ex.getMessage());
        }
        return con;
    }
    
    // @Method:      processPerfiosGenerateLinkAPIResponse
    // @Created by:  Manish Baldota 
    // @Description: This method is being used to handle the response from continuation and return the response to calling processes
    // @Param:       Collection - labels
    // @Param:       Object - state
    // @Return:      Object - response
    
    @AuraEnabled(cacheable=true)
    public static Object processPerfiosGenerateLinkAPIResponse(List<String> labels, Object state){
        IND_PerfiosBSGenerateLinkResponse apiResponse;
        String request='';
        String encryptedRequest='';
        String serviceName='';
        String data;
        HttpResponse response;
        String elapseTime='';
        String loanAppId;
        try{
            Carrier carrier = (Carrier)state;
            request = carrier.getRequest();
            encryptedRequest = carrier.getEncryptedRequest();
            serviceName = carrier.getServiceName();
            Long startTime = carrier.getStartTime();
            loanAppId = carrier.getLoanApplicationId();
            
            CalloutProcessor processor = carrier.getProcessor();
            response = Continuation.getResponse(labels[0]);
            Long endTime = DateTime.now().getTime();
            elapseTime = String.valueOf((Double)(endTime - startTime)/1000);
            
            if(response != null && response.getStatusCode() == 200) {
                system.debug('Response =>'+response);
                apiResponse = (IND_PerfiosBSGenerateLinkResponse)processor.getHttpResponse(response, serviceName);
                if(apiResponse !=null){
                    data = JSON.serialize(apiResponse);
                    IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, IntegrationUtilities.getPlainTextForLog(response.getBody()), response.getBody(), serviceName, elapseTime, loanAppId, System.Label.Success);
                } else {
                    IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, IntegrationUtilities.getPlainTextForLog(response.getBody()), response.getBody(), serviceName, elapseTime,loanAppId,System.Label.Failure);
                    throw new IND_Exception(System.Label.NoResponse);                
                }
                
                
            } else {
                String errString = '[Status Code = '+ response.getStatusCode() +' ] Response-->'+IntegrationUtilities.getPlainTextForLog(response.getBody());
                IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, errString, response.getBody(), serviceName, elapseTime, loanAppId, System.Label.Failure);
                ErrorLoggerUtil.logErrorEvent('CalloutProcessor', 'getHttpResponse', System.Label.Apex, new IND_Exception(errString), loanAppId);
                throw new IND_Exception(System.Label.NoResponse);
            } 
            
        } catch (Exception ex){
            IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, '', '', serviceName, elapseTime, loanAppId);
            ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'processPerfiosGenerateLinkAPIResponse', System.Label.Apex, ex, loanAppId);
            throw new AuraHandledException(ex.getMessage());
        }
        return data;
    }
    
    /*
* @Method:      doITROnlineCallout
* @Created by:  Bhushan Charde 
* @Description: This method is being used to call the Perfios GST Online using continuation
* @Param:       String - applicantId
* @Return:      ''
*/
    @AuraEnabled(continuation=true cacheable=true)
    public static Object doITROnlineCallout(String incomeDetailString){
        Continuation con;
        String loanAppId='';
        try{
            if(String.isBlank(incomeDetailString)){
                throw new IND_Exception(System.Label.Retry);
            }
            //Provide API-wise Integration Name to Custom Metadata Configs
            Integration_Configuration__mdt apiConfiguration = IntegrationUtilities.getAPIConfiguration(System.Label.ITROnline);
            Integer timeout = Integer.valueOf(apiConfiguration.Timeout__c);
            
            //if stubs checked in Integration_Configuration then stubs will return 
            if(apiConfiguration.IsStub_Required__c != null && apiConfiguration.IsStub_Required__c){  
                String stubData = IntegrationUtilities.getStubResponse(System.Label.ITROnline);
                return stubData == null ? System.Label.EmptyStubs : stubData;  
            }
            
            RequestWrapper requestWrapper = (RequestWrapper)IntegrationUtilities.parseJSONRequest(incomeDetailString,'RequestWrapper');
            List<Applicant__c> app = [SELECT Id, Contact_number__c,Opportunity__r.Lead_number__c FROM Applicant__c WHERE Id=:requestWrapper.applicantId and In_Active_Applicant__c = false WITH SECURITY_ENFORCED Limit 1];
            List<Documents__c> doc = [SELECT Id, KYC_DOB__c, PAN_No__c FROM Documents__c WHERE Applicant__c=:requestWrapper.applicantId  and Document_Type__c=:System.Label.PanCards WITH SECURITY_ENFORCED Limit 1];
            
            if(app.isEmpty() || doc.isEmpty()){
                throw new IND_Exception(System.Label.Applicantdatamissing);
            } else {
                for(Applicant__c applicant:app){
                    requestWrapper.leadId= applicant.Opportunity__r.Lead_Number__c;
                    requestWrapper.contactNumber= applicant.Contact_number__c;
                }
                for(Documents__c docId :doc){
                    String decrypt = IntegrationUtilities.getDecryptedResponse(docId.PAN_No__c,System.Label.privateKey,System.Label.ivkey);//CISP-3038
                    requestWrapper.panNumber= decrypt;//CISP-3038, removed docId.PAN_No__c
                    requestWrapper.kycDOB= docId.KYC_DOB__c;
                }
            }
            
            loanAppId = requestWrapper.loanApplicationId;
            loanApplicationRef= requestWrapper.loanApplicationId;
            
            IND_PerfiosITROnlineRequest itrRequestDetails = IND_PerfiosITROnlineService.getPerfiosITROnlineRequest(requestWrapper); 
            CalloutProcessor process = new CalloutProcessor(System.Label.ITROnline, itrRequestDetails);
            HttpRequest request = process.createHttpRequest();  
            
            Long startTime = DateTime.now().getTime();
            
            Carrier carrier = new carrier();
            carrier.setServiceName(System.Label.ITROnline);
            carrier.setProcessor(process);
            carrier.setRequest(IntegrationUtilities.getPlainTextForLog(request.getBody()));
            carrier.setEncryptedRequest(request.getBody());
            carrier.setStartTime(startTime);
            carrier.setLoanApplicationId(loanAppId);  
            
            //Add callout request to continuation
            con = new Continuation(timeout);        
            con.continuationMethod='processITROnlineAPIResponse';
            con.state = carrier;
            con.addHttpRequest(request);
            
            if(Test.isRunningTest()) {
               continuationLabel = con.addHttpRequest(request);
               continuationState = carrier; 
            }  
        } catch(Exception ex) {
            ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'doITROnlineCallout', System.Label.Apex, ex, loanAppId);
            throw ex;
        }
        return con;
    }
    
    /*
* @Method:      processITROnlineAPIResponse
* @Created by:  Bhushan Charde 
* @Description: This method is being used to handle the response from continuation and return the response to calling processes
* @Param:       Collection - labels
* @Param:       Object - state
* @Return:      Object - response
*/
    @AuraEnabled(cacheable=true)
    public static Object processITROnlineAPIResponse(List<String> labels, Object state){
        IND_PerfiosITROnlineResponse apiResponse;
        String request='';
        String encryptedRequest='';
        String serviceName='';
        String data;
        HttpResponse response;
        String elapseTime='';
        String loanAppId='';
        
        try{
            Carrier carrier = (Carrier)state;
            request = carrier.getRequest();
            encryptedRequest = carrier.getEncryptedRequest();
            serviceName = carrier.getServiceName();
            Long startTime = carrier.getStartTime();
            loanAppId = carrier.getLoanApplicationId();
            
            CalloutProcessor processor = carrier.getProcessor();
            response = Continuation.getResponse(labels[0]);
            Long endTime = DateTime.now().getTime();
            elapseTime = String.valueOf((Double)(endTime - startTime)/1000);
            
            if(response != null && response.getStatusCode() == 200) {
                apiResponse = (IND_PerfiosITROnlineResponse)processor.getHttpResponse(response, serviceName);
                if(apiResponse !=null){
                    data = JSON.serialize(apiResponse);
                    IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, IntegrationUtilities.getPlainTextForLog(response.getBody()), response.getBody(), serviceName, elapseTime, loanAppId, System.Label.Success);
                } else {
                    IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, IntegrationUtilities.getPlainTextForLog(response.getBody()), response.getBody(), serviceName, elapseTime,loanAppId,System.Label.Failure);
                    throw new IND_Exception(System.Label.NoResponse);
                }
                
            } else {
                String errString = '[Status Code = '+ response.getStatusCode() +' ] Response-->'+IntegrationUtilities.getPlainTextForLog(response.getBody());
                IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, errString, response.getBody(), serviceName, elapseTime, loanAppId, System.Label.Failure);
                ErrorLoggerUtil.logErrorEvent('CalloutProcessor', 'getHttpResponse', System.Label.Apex, new IND_Exception(errString), loanAppId);
                throw new IND_Exception(System.Label.NoResponse);
            } 
            
        } catch (Exception ex){
            IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, '', '', serviceName, elapseTime, loanAppId,System.Label.Failure);
            ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'processITROnlineAPIResponse', System.Label.Apex, ex, loanAppId);
            throw new IND_Exception(ex.getMessage());
        }
        return data;
    }
    
    /*
* @Method:      doCustomerExposureCallout
* @Created by:  Bondiga Thilak 
* @Description: This method is being used to call the Customer Exposure API using continuation
* @Param:       String - applicantId
* @Return:      ''
*/
    @AuraEnabled(continuation=true cacheable=true)
    //public static Object doCustomerExposureCallout(String applicantId,String loanAppId){
     public static Object doCustomerExposureCallout(List<String> lstCustCodes,String loanAppId){
        Continuation con;
        try{
           // if(String.isBlank(applicantId)){
            if(lstCustCodes.isEmpty()){
                throw new IND_Exception(System.Label.Retry);
            }
            system.debug('::doCustomerExposureCallout method is invoked.');
            //Provide API-wise Integration Name to Custom Metadata Configs
            Integration_Configuration__mdt apiConfiguration = IntegrationUtilities.getAPIConfiguration(System.Label.CustomerExposure);
            Integer timeout = Integer.valueOf(apiConfiguration.Timeout__c);

            
            //if stubs checked in Integration_Configuration then stubs will return 
            if(apiConfiguration.IsStub_Required__c != null && apiConfiguration.IsStub_Required__c){  
                String stubData = IntegrationUtilities.getStubResponse(System.Label.CustomerExposure);
                return stubData == null ? System.Label.EmptyStubs : stubData;  			
                
            }
            
            
          //  Applicant__c app = [SELECT Id,Opportunity__r.Customer_Deal_No__c,Opportunity__r.Lead_number__c FROM Applicant__c WHERE Id=:applicantId WITH SECURITY_ENFORCED Limit 1]; 
            
            loanApplicationRef= loanAppId;
            IND_CustomerExposureRequest customerExposureRequestDetails = IND_CustomerExposureService.getCustomerExposureRequest(lstCustCodes,loanAppId); 
            system.debug('::CustomerExposureRequestDetails '+customerExposureRequestDetails);
            CalloutProcessor process = new CalloutProcessor(System.Label.CustomerExposure, customerExposureRequestDetails);
            HttpRequest request = process.createHttpRequest();  
            
            Long startTime = DateTime.now().getTime();
            
            Carrier carrier = new carrier();
            carrier.setServiceName(System.Label.CustomerExposure);
            carrier.setProcessor(process);
            carrier.setRequest(IntegrationUtilities.getPlainTextForLog(request.getBody()));
            carrier.setEncryptedRequest(request.getBody());
            carrier.setStartTime(startTime);
            carrier.setLoanApplicationId(loanAppId);
            //Add callout request to continuation
            con = new Continuation(timeout);        
            con.continuationMethod='processCustomerExposureAPIResponse';
            con.state=carrier;
            con.addHttpRequest(request);
            
            if(Test.isRunningTest()) {
               continuationLabel = con.addHttpRequest(request);
               continuationState = carrier; 
            }  
        } catch(Exception ex) {
            ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'doCustomerExposureCallout', System.Label.Apex, ex,loanAppId);
            throw ex;
        }
        return con;
    }
    
    /*
* @Method:      processCustomerExposureAPIResponse
* @Created by:  Bondiga Thilak 
* @Description: This method is being used to handle the response from continuation and return the response to calling processes
* @Param:       Collection - labels
* @Param:       Object - state
* @Return:      Object - response
*/
    @AuraEnabled(cacheable=true)
    public static Object processCustomerExposureAPIResponse(List<String> labels, Object state){
        System.debug('::Inside the Customer Exposure callback');
        IND_CustomerExposureResponse apiResponse;
        String request='';
        String encryptedRequest='';
        String serviceName='';
        String data;
		 String loanAppId='';
        HttpResponse response;
        String elapseTime='';
        
        try{
            Carrier carrier = (Carrier)state;
            request = carrier.getRequest();
            encryptedRequest = carrier.getEncryptedRequest();
            serviceName = carrier.getServiceName();
            Long startTime = carrier.getStartTime();
            CalloutProcessor processor = carrier.getProcessor();
            response = Continuation.getResponse(labels[0]);
            Long endTime = DateTime.now().getTime();
            elapseTime = String.valueOf((Double)(endTime - startTime)/1000);
            loanAppId = carrier.getLoanApplicationId();
            if(response != null && response.getStatusCode() == 200){               
                apiResponse = (IND_CustomerExposureResponse)processor.getHttpResponse(response, serviceName);    
                if(apiResponse!=null){
                    IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, IntegrationUtilities.getPlainTextForLog(response.getBody()), response.getBody(), serviceName, elapseTime,loanAppId,System.Label.Success);
                    return JSON.serialize(apiResponse);
                    
                } else {
                    IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, IntegrationUtilities.getPlainTextForLog(response.getBody()), response.getBody(), serviceName, elapseTime,loanAppId,System.Label.Failure);
                    throw new IND_Exception(System.Label.NoResponse);                
                }
            }
            else {
                String errString = '[Status Code = '+ response.getStatusCode() +' ] Response-->'+IntegrationUtilities.getPlainTextForLog(response.getBody());
                IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, errString, response.getBody(), serviceName, elapseTime, loanAppId, System.Label.Failure);
                ErrorLoggerUtil.logErrorEvent('CalloutProcessor', 'getHttpResponse', System.Label.Apex, new IND_Exception(errString), loanAppId);
                throw new IND_Exception(System.Label.NoResponse);
            } 
        } catch (Exception ex){
            IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, '', '', serviceName, elapseTime,loanAppId,System.Label.Failure);
            ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'processCustomerExposureAPIResponse', System.Label.Apex, ex,loanAppId);
            throw new IND_Exception(ex.getMessage());
        }
    }
    
    
    /*
* @Method:      doDealMasterCallout
* @Created by:  Bondiga Thilak 
* @Description: This method is being used to call the Perfios Deal Master API using continuation
* @Param:       String - applicantId
* @Return:      ''
*/
    @AuraEnabled(continuation=true cacheable=true)
    public static Object doDealMasterCallout(String applicantId,String loanAppId){
        Continuation con;
        try{
            system.debug('::doDealMasterCallout method is invoked.');
            //Provide API-wise Integration Name to Custom Metadata Configs
            Integration_Configuration__mdt apiConfiguration = IntegrationUtilities.getAPIConfiguration(System.Label.DealMaster);
            Integer timeout = Integer.valueOf(apiConfiguration.Timeout__c);

            //if stubs checked in Integration_Configuration then stubs will return 
            if(apiConfiguration.IsStub_Required__c != null && apiConfiguration.IsStub_Required__c){  
                String stubData = IntegrationUtilities.getStubResponse(System.Label.DealMaster);
                return stubData == null ? System.Label.EmptyStubs : stubData;  
            }
            Applicant__c app = [SELECT Id,Opportunity__r.Parent_Deal_number__c,Opportunity__r.Lead_number__c FROM Applicant__c WHERE Id=:applicantId WITH SECURITY_ENFORCED];
            
            loanApplicationRef= loanAppId;
            IND_DealMasterRequest DealMasterRequestDetails = IND_DealMasterService.getDealMasterRequest(app,loanAppId); 
            system.debug('::DealMasterRequestDetails '+DealMasterRequestDetails);
            CalloutProcessor process = new CalloutProcessor(System.Label.DealMaster, DealMasterRequestDetails);
            HttpRequest request = process.createHttpRequest();  
            
            Long startTime = DateTime.now().getTime();
            
            Carrier carrier = new carrier();
            carrier.setServiceName(System.Label.DealMaster);
            carrier.setProcessor(process);
            carrier.setRequest(IntegrationUtilities.getPlainTextForLog(request.getBody()));
            carrier.setEncryptedRequest(request.getBody());
            carrier.setStartTime(startTime);
            carrier.setLoanApplicationId(loanAppId);
            
            //Add callout request to continuation
            con = new Continuation(timeout);        
            con.continuationMethod='processDealMasterAPIResponse';
            con.state=carrier;
            con.addHttpRequest(request);
            
            if(Test.isRunningTest()) {
               continuationLabel = con.addHttpRequest(request);
               continuationState = carrier; 
            }  
            
        } catch(Exception ex) {
            ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'doDealMasterCallout', System.Label.Apex, ex,loanAppId);
            throw ex;
        }
        return con;
    }
/*
* @Method:      doDealMasterCalloutForCustomerName
* @Created by:  Daksh Mandowara 
* @Description: This method is being used to call the Perfios Deal Master API using continuation
* @Param:       String - Deal Number & String - Loan Application Id
* @Return:      ''
*/
@AuraEnabled(continuation=true cacheable=true)
public static Object doDealMasterCalloutForCustomerName(String dealNumber,String loanAppId){
    Continuation con;
    try{
        system.debug('::doDealMasterCalloutForCustomerName method is invoked.');
        //Provide API-wise Integration Name to Custom Metadata Configs
        Integration_Configuration__mdt apiConfiguration = IntegrationUtilities.getAPIConfiguration(System.Label.DealMaster);
        Integer timeout = Integer.valueOf(apiConfiguration.Timeout__c);

        //if stubs checked in Integration_Configuration then stubs will return 
        if(apiConfiguration.IsStub_Required__c != null && apiConfiguration.IsStub_Required__c){  
            String stubData = IntegrationUtilities.getStubResponse(System.Label.DealMaster);
            return stubData == null ? System.Label.EmptyStubs : stubData;  
        }
        Opportunity loanApp = [SELECT Id,Lead_number__c FROM Opportunity WHERE Id=:loanAppId WITH SECURITY_ENFORCED];
        
        loanApplicationRef= loanAppId;
        IND_DealMasterRequest DealMasterRequestDetails = IND_DealMasterService.getDealMasterRequest(dealNumber,loanApp.Lead_number__c,loanAppId); 
        system.debug('::DealMasterRequestDetails '+DealMasterRequestDetails);
        CalloutProcessor process = new CalloutProcessor(System.Label.DealMaster, DealMasterRequestDetails);
        HttpRequest request = process.createHttpRequest();  
        
        Long startTime = DateTime.now().getTime();
        
        Carrier carrier = new carrier();
        carrier.setServiceName(System.Label.DealMaster);
        carrier.setProcessor(process);
        carrier.setRequest(IntegrationUtilities.getPlainTextForLog(request.getBody()));
        carrier.setEncryptedRequest(request.getBody());
        carrier.setStartTime(startTime);
        carrier.setLoanApplicationId(loanAppId);
        
        //Add callout request to continuation
        con = new Continuation(timeout);        
        con.continuationMethod='processDealMasterAPIResponse';
        con.state=carrier;
        con.addHttpRequest(request);
        
        if(Test.isRunningTest()) {
           continuationLabel = con.addHttpRequest(request);
           continuationState = carrier; 
        }  
    } catch(Exception ex) {
        ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'doDealMasterCalloutForCustomerName', System.Label.Apex, ex,loanAppId);
        throw ex;
    }
    return con;
}
    
    /*
* @Method:      processDealMasterAPIResponse
* @Created by:  Bondiga Thilak 
* @Description: This method is being used to handle the response from continuation and return the response to calling processes
* @Param:       Collection - labels
* @Param:       Object - state
* @Return:      Object - response
*/
    @AuraEnabled(cacheable=true)
    public static Object processDealMasterAPIResponse(List<String> labels, Object state){
        System.debug('::Inside the Deal Master callback');
        IND_DealMasterResponse apiResponse;
        String request='';
        String encryptedRequest='';
        String serviceName='';
         String loanAppId='';
        String data;
        HttpResponse response;
        String elapseTime='';
        
        try{
            Carrier carrier = (Carrier)state;
            request = carrier.getRequest();
            encryptedRequest = carrier.getEncryptedRequest();
            serviceName = carrier.getServiceName();
            Long startTime = carrier.getStartTime();
            
            CalloutProcessor processor = carrier.getProcessor();
            response = Continuation.getResponse(labels[0]);
            Long endTime = DateTime.now().getTime();
            elapseTime = String.valueOf((Double)(endTime - startTime)/1000);
            loanAppId = carrier.getLoanApplicationId();
            
            if(response != null) {
                system.debug('::Inside the response method');
                apiResponse = (IND_DealMasterResponse)processor.getHttpResponse(response, serviceName);
                if(apiResponse != null){
                    data = JSON.serialize(apiResponse);
                    system.debug('data::'+data);
                    IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, IntegrationUtilities.getPlainTextForLog(response.getBody()), response.getBody(), serviceName,elapseTime,loanAppId,System.Label.Success);
                } else {
                    IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, IntegrationUtilities.getPlainTextForLog(response.getBody()), response.getBody(), serviceName, elapseTime,loanAppId,System.Label.Failure);
                    throw new IND_Exception(System.Label.NoResponse);
                }
                
            } else {
                String errString = '[Status Code = '+ response.getStatusCode() +' ] Response-->'+IntegrationUtilities.getPlainTextForLog(response.getBody());
                IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, errString, response.getBody(), serviceName, elapseTime, loanAppId, System.Label.Failure);
                ErrorLoggerUtil.logErrorEvent('CalloutProcessor', 'getHttpResponse', System.Label.Apex, new IND_Exception(errString), loanAppId);
                throw new IND_Exception(System.Label.NoResponse);
            } 
            
        } catch (Exception ex){
            System.debug('callback()====catch');
            IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, '', '', serviceName, elapseTime,loanAppId,System.Label.Failure);
            ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'processDealMasterAPIResponse', System.Label.Apex, ex,loanAppId);
            throw new AuraHandledException(ex.getMessage());
        }
        return data;
    }
    
          /*
* @Method:      doLTVEngineCallout
* @Created by:  Bondiga Thilak 
* @Description: This method is being used to call the Perfios LTV Engine API using continuation
* @Param:       String - applicantId
* @Return:      ''
*/
    @AuraEnabled(continuation=true cacheable=true)
    public static Object doLTVEngineCallout(String applicantId,String loanAppId){
        Continuation con;
        try{
            //Provide API-wise Integration Name to Custom Metadata Configs
            Integration_Configuration__mdt apiConfiguration = IntegrationUtilities.getAPIConfiguration(System.Label.LTVEngine);
            Integer timeout = Integer.valueOf(apiConfiguration.Timeout__c); 
            RequestWrapper requestWrapper = new RequestWrapper();
            
            //if stubs checked in Integration_Configuration then stubs will return 
            if(apiConfiguration.IsStub_Required__c != null && apiConfiguration.IsStub_Required__c){  
                String stubData = IntegrationUtilities.getStubResponse(System.Label.LTVEngine);
                return stubData == null ? System.Label.EmptyStubs : stubData;  
            }
              
              loanApplicationRef= loanAppId;
              List<Applicant__c> appList = [SELECT Id, Who_will_repay_the_loan__c,Applicant_Type__c 
                                          FROM Applicant__c 
                                          WHERE Opportunity__r.id =:loanAppId WITH SECURITY_ENFORCED];
             List<Applicant__c> appListWithScoreCard = new List<Applicant__c>(); 
             String whoWillRepayTheLoan = '';
             
            for(Applicant__c applicant : appList){
                if(applicant.Applicant_Type__c.equals('Borrower')){
                    whoWillRepayTheLoan = applicant.Who_will_repay_the_loan__c;
                }
            }
            
            if(whoWillRepayTheLoan == null || String.isBlank(whoWillRepayTheLoan)){
            throw new IND_Exception('Who will repay the loan field is required.');
        	}
			
             for(Applicant__c applicant : appList){
              
              List<Applicant__c> applicantWithScorecard=[SELECT Scorecard_Decision__c,applicant_number__c,Applicant_Type__c, Id
                                          FROM Applicant__c 
                                          WHERE Applicant_Type__c=:whoWillRepayTheLoan AND 
                                          Opportunity__r.id =:loanAppId AND In_Active_Applicant__c=false AND Id=:applicant.Id WITH SECURITY_ENFORCED];
                 if(!applicantWithScorecard.isEmpty()){
                     for(Applicant__c applicantScoreCard : applicantWithScorecard){
                          appListWithScoreCard.add(applicantScoreCard);
                     }
                 }
             }
           for(Applicant__c applicant : appListWithScoreCard){
                if(!String.isBlank(applicant.Scorecard_Decision__c) ){
                    requestWrapper.scoreCardDecision=applicant.Scorecard_Decision__c;
                }
                 if(!String.isBlank(applicant.applicant_number__c) ){
                    requestWrapper.applicantNumber=applicant.applicant_number__c;
                }  
                 if(!String.isBlank(applicant.Applicant_Type__c) ){
                    requestWrapper.proposalBasedOn=applicant.Applicant_Type__c;
                }
				if(!String.isBlank(applicant.id) ){
                    requestWrapper.applicantId=applicant.id;
                }
            }
            Opportunity opp = [SELECT Id,Customer_Deal_No__c,Lead_number__c,Product_Type__c,Category__c,
                                Vehicle_Type__c, Agent_BL_code__c, Geo_State_Master__r.State_Code__c 
                                FROM Opportunity WHERE ID=:loanAppId WITH SECURITY_ENFORCED];
            List<Vehicle_Detail__c> vehicleDetails = [Select Model__c,Model_Code__c from Vehicle_Detail__c where Loan_Application__c =:loanAppId WITH SECURITY_ENFORCED Limit 1];   //CISP-3555       
            if(!vehicleDetails.isEmpty()){
                for(Vehicle_Detail__c vehicle:vehicleDetails){                    
                    List<Product2> product2 =  [Select asset_category__c from product2 where Model_Code__c=:vehicle.Model_Code__c  WITH SECURITY_ENFORCED Limit 1];  //CISP-3555                  
                    if(!product2.isEmpty()){                       
                      requestWrapper.subProduct=product2[0].asset_category__c;                        
                    }
                    else{
                        throw new IND_Exception('Asset category not found in product');				  
                    }
                }
            } 

            IND_LTVEngineRequest LTVEngineRequestDetails = IND_LTVEngineService.getLTVEngineRequest(opp,loanAppId,requestWrapper); 
            CalloutProcessor process = new CalloutProcessor(System.Label.LTVEngine, LTVEngineRequestDetails);
            HttpRequest request = process.createHttpRequest();  
            
            Long startTime = DateTime.now().getTime();
            
            Carrier carrier = new carrier();
            carrier.setServiceName(System.Label.LTVEngine);
            carrier.setProcessor(process);
            carrier.setRequest(IntegrationUtilities.getPlainTextForLog(request.getBody()));
            carrier.setEncryptedRequest(request.getBody());
            carrier.setStartTime(startTime);
            carrier.setLoanApplicationId(loanAppId);
            //Add callout request to continuation
            con = new Continuation(timeout);        
            con.continuationMethod='processLTVEngineAPIResponse';
            con.state=carrier;
            con.addHttpRequest(request);
            
            if(Test.isRunningTest()) {
               continuationLabel = con.addHttpRequest(request);
               continuationState = carrier; 
            }  
        } catch(Exception ex) {
            ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'doLTVEngineCallout', System.Label.Apex, ex,loanAppId);
            throw ex;
        }
        return con;
    }
    
    /*
* @Method:      processLTVEngineAPIResponse
* @Created by:  Bondiga Thilak 
* @Description: This method is being used to handle the response from continuation and return the response to calling processes
* @Param:       Collection - labels
* @Param:       Object - state
* @Return:      Object - response
*/
    @AuraEnabled(cacheable=true)
    public static Object processLTVEngineAPIResponse(List<String> labels, Object state){
        IND_LTVEngineResponse apiResponse;
        String request='';
        String responseBody='';
        String encryptedRequest='';
        String serviceName='';
        String loanAppId='';
        HttpResponse response;
        String elapseTime='';
        
        try{
            Carrier carrier = (Carrier)state;
            request = carrier.getRequest();
            encryptedRequest = carrier.getEncryptedRequest();
            serviceName = carrier.getServiceName();
            Long startTime = carrier.getStartTime();
            
            CalloutProcessor processor = carrier.getProcessor();
            response = Continuation.getResponse(labels[0]);
            Long endTime = DateTime.now().getTime();
            elapseTime = String.valueOf((Double)(endTime - startTime)/1000);
            loanAppId = carrier.getLoanApplicationId();
              if(response != null && response.getStatusCode() == 200){
                apiResponse = (IND_LTVEngineResponse)processor.getHttpResponse(response, serviceName);     
                if(apiResponse!=null){
                    IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, IntegrationUtilities.getPlainTextForLog(response.getBody()), response.getBody(), serviceName, elapseTime,loanAppId,System.Label.Success);
                    return JSON.serialize(apiResponse);
                } else {
                    IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, IntegrationUtilities.getPlainTextForLog(response.getBody()), response.getBody(), serviceName, elapseTime,loanAppId,System.Label.Failure);
                    throw new IND_Exception(System.Label.NoResponse);                
                }
            }
            else {
                String errString = '[Status Code = '+ response.getStatusCode() +' ] Response-->'+IntegrationUtilities.getPlainTextForLog(response.getBody());
                IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, errString, response.getBody(), serviceName, elapseTime, loanAppId, System.Label.Failure);
                ErrorLoggerUtil.logErrorEvent('CalloutProcessor', 'getHttpResponse', System.Label.Apex, new IND_Exception(errString), loanAppId);
                throw new IND_Exception(System.Label.NoResponse);
            } 
            
        } catch (Exception ex){
            IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, '', '', serviceName, elapseTime,loanAppId,System.Label.Failure);
            ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'processLTVEngineAPIResponse', System.Label.Apex, ex,loanAppId);
            throw new IND_Exception(ex.getMessage());
        }
    }
    
    
    /*
* @Method:      doPricingEngineCallout
* @Created by:  Bondiga Thilak 
* @Description: This method is being used to call the Perfios Pricing Engine API using continuation
* @Param:       String - applicantId
* @Return:      ''
*/
    @AuraEnabled(continuation=true cacheable=true)
    public static Object doPricingEngineCallout(String applicantId, String loanAppId){
        Continuation con;
        try{
            //Provide API-wise Integration Name to Custom Metadata Configs
            Integration_Configuration__mdt apiConfiguration = IntegrationUtilities.getAPIConfiguration(System.Label.PricingEngine);
            Integer timeout = Integer.valueOf(apiConfiguration.Timeout__c);
			RequestWrapper requestWrapper = new RequestWrapper();

            //if stubs checked in Integration_Configuration then stubs will return 
            if(apiConfiguration.IsStub_Required__c != null && apiConfiguration.IsStub_Required__c){  
                String stubData = IntegrationUtilities.getStubResponse(System.Label.PricingEngine);
                return stubData == null ? System.Label.EmptyStubs : stubData;  
            }
            
              loanApplicationRef= loanAppId;  
               List<Applicant__c> appList = [SELECT Id, Who_will_repay_the_loan__c, Applicant_Type__c
                                          FROM Applicant__c 
                                          WHERE Opportunity__r.id =:loanAppId WITH SECURITY_ENFORCED];
             List<Applicant__c> appListWithScoreCard = new List<Applicant__c>(); 
			 String whoWillRepayTheLoan = '';
			 
			 for(Applicant__c applicant : appList){
                if(applicant.Applicant_Type__c.equals('Borrower')){
                    whoWillRepayTheLoan = applicant.Who_will_repay_the_loan__c;
                }
            }
			
			if(whoWillRepayTheLoan == null || String.isBlank(whoWillRepayTheLoan)){
				throw new IND_Exception('Who will repay the loan field is required.');
            }
             
             for(Applicant__c applicant : appList){
              
              List<Applicant__c> applicantWithScorecard=[SELECT Scorecard_Decision__c,applicant_number__c,Applicant_Type__c, Id 
                                          FROM Applicant__c 
                                          WHERE Applicant_Type__c=:whoWillRepayTheLoan AND 
                                          Opportunity__r.id =:loanAppId AND In_Active_Applicant__c=false AND Id=:applicant.Id WITH SECURITY_ENFORCED];
               if(!applicantWithScorecard.isEmpty()){
                     for(Applicant__c applicantScoreCard : applicantWithScorecard){
                          appListWithScoreCard.add(applicantScoreCard);
                     }
                 }
             }
            String scoreCardDecision;
           for(Applicant__c applicant : appListWithScoreCard){
                if(!String.isBlank(applicant.Scorecard_Decision__c) ){
                    requestWrapper.scoreCardDecision=applicant.Scorecard_Decision__c;
                }
                 if(!String.isBlank(applicant.applicant_number__c) ){
                    requestWrapper.applicantNumber=applicant.applicant_number__c;
                }  
                 if(!String.isBlank(applicant.Applicant_Type__c) ){
                    requestWrapper.proposalBasedOn=applicant.Applicant_Type__c;
                }
				if(!String.isBlank(applicant.id) ){
                    requestWrapper.applicantId=applicant.id;
                }
            }
            Opportunity opp = [SELECT Id,Customer_Deal_No__c,Lead_number__c,Product_Type__c,Category__c,
                                Vehicle_Type__c, Agent_BL_code__c, Geo_State_Master__r.State_Code__c 
                                FROM Opportunity WHERE ID=:loanAppId WITH SECURITY_ENFORCED];

            IND_PricingEngineRequest pricingEngineRequestDetails = IND_PricingEngineService.getPricingEngineRequest(opp,loanAppId,requestWrapper); 
            CalloutProcessor process = new CalloutProcessor(System.Label.PricingEngine, pricingEngineRequestDetails);
            HttpRequest request = process.createHttpRequest();  
            
            Long startTime = DateTime.now().getTime();
            
            Carrier carrier = new carrier();
            carrier.setServiceName(System.Label.PricingEngine);
            carrier.setProcessor(process);
            carrier.setRequest(IntegrationUtilities.getPlainTextForLog(request.getBody()));
            carrier.setEncryptedRequest(request.getBody());
            carrier.setStartTime(startTime);
            carrier.setLoanApplicationId(loanAppId);
            //Add callout request to continuation
            con = new Continuation(timeout);        
            con.continuationMethod='processPricingEngineAPIResponse';
            con.state=carrier;
            con.addHttpRequest(request);
            
            if(Test.isRunningTest()) {
               continuationLabel = con.addHttpRequest(request);
               continuationState = carrier; 
            }  
        } catch(Exception ex) {
            ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'doPricingEngineCallout', System.Label.Apex, ex,loanAppId);
            throw ex;
        }
        return con;
    }
    
    /*
* @Method:      processPricingEngineAPIResponse
* @Created by:  Bondiga Thilak 
* @Description: This method is being used to handle the response from continuation and return the response to calling processes
* @Param:       Collection - labels
* @Param:       Object - state
* @Return:      Object - response
*/
    @AuraEnabled(cacheable=true)
    public static Object processPricingEngineAPIResponse(List<String> labels, Object state){
        IND_PricingEngineResponse apiResponse;
        String responseBody='';
        String request='';
        String encryptedRequest='';
        String serviceName='';
        String loanAppId = '';
        String data;
        HttpResponse response;
        String elapseTime='';
        
        try{
            Carrier carrier = (Carrier)state;
            request = carrier.getRequest();
            encryptedRequest = carrier.getEncryptedRequest();
            serviceName = carrier.getServiceName();
            Long startTime = carrier.getStartTime();
            
            CalloutProcessor processor = carrier.getProcessor();
            response = Continuation.getResponse(labels[0]);
            Long endTime = DateTime.now().getTime();
            elapseTime = String.valueOf((Double)(endTime - startTime)/1000);
             loanAppId = carrier.getLoanApplicationId();
             if(response != null && response.getStatusCode() == 200){
                apiResponse = (IND_PricingEngineResponse)processor.getHttpResponse(response, serviceName);     
                if(apiResponse!=null){
                    IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, IntegrationUtilities.getPlainTextForLog(response.getBody()), response.getBody(), serviceName, elapseTime,loanAppId,System.Label.Success);
                    return JSON.serialize(apiResponse);
                } else {
                    IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, IntegrationUtilities.getPlainTextForLog(response.getBody()), response.getBody(), serviceName, elapseTime,loanAppId,System.Label.Failure);
                    throw new IND_Exception(System.Label.NoResponse);                
                }
            }
            else {
                String errString = '[Status Code = '+ response.getStatusCode() +' ] Response-->'+IntegrationUtilities.getPlainTextForLog(response.getBody());
                IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, errString, response.getBody(), serviceName, elapseTime, loanAppId, System.Label.Failure);
                ErrorLoggerUtil.logErrorEvent('CalloutProcessor', 'getHttpResponse', System.Label.Apex, new IND_Exception(errString), loanAppId);
                throw new IND_Exception(System.Label.NoResponse);
            } 
            
        } catch (Exception ex){
            IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, '', '', serviceName, elapseTime,loanAppId, System.Label.Failure);
            ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'processPricingEngineAPIResponse', System.Label.Apex, ex,loanAppId);
            throw new IND_Exception(ex.getMessage());
        }
    }
	
    /*
* @Method:      doCAMPortfolioCallout
* @Created by:  Bondiga Thilak 
* @Description: This method is being used to call the Perfios CAM Portfolio API using continuation
* @Param:       String - applicantId
* @Return:      ''
*/
    @AuraEnabled(continuation=true cacheable=true)
    public static Object doCAMPortfolioCallout(String applicantId,String loanAppId){
        Continuation con;
        try{
            system.debug('::doCAMPortfolioCallout method is invoked.');
            //Provide API-wise Integration Name to Custom Metadata Configs
            Integration_Configuration__mdt apiConfiguration = IntegrationUtilities.getAPIConfiguration(System.Label.CAMPortfolio);
            Integer timeout = Integer.valueOf(apiConfiguration.Timeout__c);

            
            //if stubs checked in Integration_Configuration then stubs will return 
            if(apiConfiguration.IsStub_Required__c != null && apiConfiguration.IsStub_Required__c){  
                String stubData = IntegrationUtilities.getStubResponse(System.Label.CAMPortfolio);
                return stubData == null ? System.Label.EmptyStubs : stubData;  
            }

            Applicant__c app = [SELECT Id,applicant_number__c,Opportunity__r.Lead_number__c,Opportunity__r.Product_Type__c FROM Applicant__c WHERE Id=:applicantId WITH SECURITY_ENFORCED];
            loanApplicationRef= loanAppId;
            
            IND_CAMPortfolioRequest CAMPortfolioRequestDetails = IND_CAMPortfolioService.getCAMPortfolioRequest(app,loanAppId); 
            system.debug('::CAMPortfolioRequestDetails '+CAMPortfolioRequestDetails);
            CalloutProcessor process = new CalloutProcessor(System.Label.CAMPortfolio, CAMPortfolioRequestDetails);
            HttpRequest request = process.createHttpRequest();  
            
            Long startTime = DateTime.now().getTime();
            
            Carrier carrier = new carrier();
            carrier.setServiceName(System.Label.CAMPortfolio);
            carrier.setProcessor(process);
            carrier.setRequest(IntegrationUtilities.getPlainTextForLog(request.getBody()));
            carrier.setEncryptedRequest(request.getBody());
            carrier.setStartTime(startTime);
            carrier.setLoanApplicationId(loanAppId);
            //Add callout request to continuation
            con = new Continuation(timeout);        
            con.continuationMethod='processCAMPortfolioAPIResponse';
            con.state=carrier;
            con.addHttpRequest(request);
            
            if(Test.isRunningTest()) {
               continuationLabel = con.addHttpRequest(request);
               continuationState = carrier; 
            }  
        } catch(Exception ex) {
            ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'doCAMPortfolioCallout', System.Label.Apex, ex,loanAppId);
            throw ex;
        }
        return con;
    }
    
    /*
* @Method:      processCAMPortfolioAPIResponse
* @Created by:  Bondiga Thilak 
* @Description: This method is being used to handle the response from continuation and return the response to calling processes
* @Param:       Collection - labels
* @Param:       Object - state
* @Return:      Object - response
*/
    @AuraEnabled(cacheable=true)
    public static Object processCAMPortfolioAPIResponse(List<String> labels, Object state){
        System.debug('::Inside the CAM Portfolio callback');
        IND_CAMPortfolioResponse apiResponse;
        String request='';
        String encryptedRequest='';
        String serviceName='';
        String data;
        HttpResponse response;
        String elapseTime='';
        String loanAppId='';
        
        try{
            Carrier carrier = (Carrier)state;
            request = carrier.getRequest();
            encryptedRequest = carrier.getEncryptedRequest();
            serviceName = carrier.getServiceName();
            Long startTime = carrier.getStartTime();
            
            CalloutProcessor processor = carrier.getProcessor();
            response = Continuation.getResponse(labels[0]);
            Long endTime = DateTime.now().getTime();
            elapseTime = String.valueOf((Double)(endTime - startTime)/1000);
            loanAppId = carrier.getLoanApplicationId();            
            if(response != null && response.getStatusCode() == 200) {
                system.debug('::Inside the response method');
                apiResponse = (IND_CAMPortfolioResponse)processor.getHttpResponse(response, serviceName);
                if(apiResponse != null ){
                    data = JSON.serialize(apiResponse);
                    system.debug('data::'+data);
                    IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, IntegrationUtilities.getPlainTextForLog(response.getBody()), response.getBody(), serviceName, elapseTime,loanAppId,System.Label.Success);
                } else {
                    IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, '', '', serviceName, elapseTime,loanAppId, System.Label.Failure);
                    throw new IND_Exception(System.Label.NoResponse);
                }
                
            } else {
                String errString = '[Status Code = '+ response.getStatusCode() +' ] Response-->'+IntegrationUtilities.getPlainTextForLog(response.getBody());
                IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, errString, response.getBody(), serviceName, elapseTime, loanAppId, System.Label.Failure);
                ErrorLoggerUtil.logErrorEvent('CalloutProcessor', 'getHttpResponse', System.Label.Apex, new IND_Exception(errString), loanAppId);
                throw new IND_Exception(System.Label.NoResponse);
            } 
            
        } catch (Exception ex){
            System.debug('callback()====catch');
            IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, '', '', serviceName, elapseTime,loanAppId, System.Label.Failure);
            ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'processCAMPortfolioAPIResponse', System.Label.Apex, ex, loanAppId);
            throw new AuraHandledException(ex.getMessage());
        }
        return data;
    }
    
     /*
* @Method:      doRegistrationJourneyCallout
* @Created by:  Bhushan Charde
* @Description: This method is being used to call the Perfios GST Report using continuation
* @Param:       String - applicantId
* @Return:      ''
*/
    @AuraEnabled(continuation=true)
    public static Object doRegistrationJourneyCallout(String applicantId ,String loanAppId, String dealId){
        Continuation con;
        try{
            system.debug('::doRegistrationJourneyCallout method is invoked.');
            //Provide API-wise Integration Name to Custom Metadata Configs
            Integration_Configuration__mdt apiConfiguration = IntegrationUtilities.getAPIConfiguration(System.Label.RegistrationJourney);
            Integer timeout = Integer.valueOf(apiConfiguration.Timeout__c);
            
            //if stubs checked in Integration_Configuration then stubs will return 
            if(apiConfiguration.IsStub_Required__c != null && apiConfiguration.IsStub_Required__c){  
                String stubData = IntegrationUtilities.getStubResponse(System.Label.RegistrationJourney);
                return stubData == null ? System.Label.EmptyStubs : stubData;  
            }
            
            Applicant__c app = [SELECT Id,Customer_Code__c,Opportunity__r.Lead_number__c,Contact_number__c,Email_Id__c FROM Applicant__c WHERE Id=:applicantId WITH SECURITY_ENFORCED];
            loanApplicationRef= loanAppId;

            IND_ENACHRegistrationJourneyRequest journeyRequestDetails = IND_ENACHRegistrationJourneyService.getRegiJourneyCallOutRequest(app, loanAppId,dealId); 
            system.debug('::journeyRequestDetails '+journeyRequestDetails);
            CalloutProcessor process = new CalloutProcessor(System.Label.RegistrationJourney, journeyRequestDetails);
            HttpRequest request = process.createHttpRequest();  
            
            Long startTime = DateTime.now().getTime();
            
            Carrier carrier = new carrier();
            carrier.setServiceName(System.Label.RegistrationJourney);
            carrier.setProcessor(process);
            carrier.setRequest(IntegrationUtilities.getPlainTextForLog(request.getBody()));
            carrier.setEncryptedRequest(request.getBody());
            carrier.setStartTime(startTime);
            
            //Add callout request to continuation
            con = new Continuation(timeout);        
            con.continuationMethod='processRegistrationJourneyAPIResponse';
            con.state = carrier;
            carrier.setLoanApplicationId(loanAppId);

            con.addHttpRequest(request);
            
            if(Test.isRunningTest()) {
               continuationLabel = con.addHttpRequest(request);
               continuationState = carrier; 
            }  
        } catch(Exception ex) {
            ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'doRegistrationJourneyCallout', System.Label.Apex, ex, loanAppId);
            throw ex;
        }
        return con;
    }
    
    /*
* @Method:      processRegistrationJourneyAPIResponse
* @Created by:  Bhushan Charde 
* @Description: This method is being used to handle the response from continuation and return the response to calling processes
* @Param:       Collection - labels
* @Param:       Object - state
* @Return:      Object - response
*/
    @AuraEnabled
    public static Object processRegistrationJourneyAPIResponse(List<String> labels, Object state){
        System.debug('::Inside the processRegistrationJourneyAPIResponse callback');
        IND_ENACHRegistrationJourneyResponse apiResponse;
        String request='';
        String encryptedRequest='';
        String serviceName='';
        String data;
        HttpResponse response;
        String elapseTime='';
         String loanAppId='';

        try{
            Carrier carrier = (Carrier)state;
            request = carrier.getRequest();
            encryptedRequest = carrier.getEncryptedRequest();
            serviceName = carrier.getServiceName();
            Long startTime = carrier.getStartTime();
            
            CalloutProcessor processor = carrier.getProcessor();
            response = Continuation.getResponse(labels[0]);
            Long endTime = DateTime.now().getTime();
            elapseTime = String.valueOf((Double)(endTime - startTime)/1000);
             loanAppId = carrier.getLoanApplicationId();

            if(response != null && response.getStatusCode() == 200){
                system.debug('::Inside the response method');
                apiResponse = (IND_ENACHRegistrationJourneyResponse)processor.getHttpResponse(response, serviceName);
                if(apiResponse !=null){
                    data = JSON.serialize(apiResponse);
                    IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, IntegrationUtilities.getPlainTextForLog(response.getBody()), response.getBody(), serviceName, elapseTime, loanAppId, System.Label.Success);
                }else{
                    throw new IND_Exception(System.Label.NoResponse);
                }
            } else {
                throw new IND_Exception(System.Label.NoResponse);
            } 
            
        } catch (Exception ex){
            System.debug('callback()====catch');
			IntegrationUtilities.createIntegrationLogger(request,encryptedRequest, '' , response.getBody(), serviceName, elapseTime, loanAppId, System.Label.Failure);
            ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'processRegistrationJourneyAPIResponse', System.Label.Apex, ex, loanAppId);
            throw new IND_Exception(System.Label.NoResponse);
        }
        return data;
    } 
    

    
    /*
* @Method:      processRegistrationStatusAPIResponse
* @Created by:  Bhushan Charde 
* @Description: This method is being used to handle the response from continuation and return the response to calling processes
* @Param:       Collection - labels
* @Param:       Object - state
* @Return:      Object - response
*/
    @AuraEnabled(cacheable=true)
    public static Object processRegistrationStatusAPIResponse(List<String> labels, Object state){
        System.debug('::Inside the processRegistrationStatusAPIResponse callback');
        IND_ENACHRegistrationStatusResponse apiResponse;
        String request='';
        String encryptedRequest='';
        String serviceName='';
        String data;
        HttpResponse response;
        String elapseTime='';
        
        try{
            Carrier carrier = (Carrier)state;
            request = carrier.getRequest();
            encryptedRequest = carrier.getEncryptedRequest();
            serviceName = carrier.getServiceName();
            Long startTime = carrier.getStartTime();
            
            CalloutProcessor processor = carrier.getProcessor();
            response = Continuation.getResponse(labels[0]);
            Long endTime = DateTime.now().getTime();
            elapseTime = String.valueOf((endTime - startTime)/1000);
            
            if(response != null) {
                system.debug('::Inside the response method');
                apiResponse = (IND_ENACHRegistrationStatusResponse)processor.getHttpResponse(response, serviceName);
                if(apiResponse !=null){
                    data = JSON.serialize(apiResponse);
                    IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, IntegrationUtilities.getPlainTextForLog(response.getBody()), response.getBody(), serviceName, elapseTime);
                }
                
                
            } else {
                IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, '', '', serviceName, elapseTime);
                throw new AuraHandledException(System.Label.NoResponse);
            } 
            
        } catch (Exception ex){
            System.debug('callback()====catch');
            IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, '', '', serviceName, elapseTime);
            ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'processRegistrationStatusAPIResponse', System.Label.Apex, ex);
            throw new AuraHandledException(ex.getMessage());
        }
        return data;
    }
    
    
    /*
* @Method:      doAPDPendingCallout
* @Created by:  Bondiga Thilak 
* @Description: This method is being used to call the Perfios APD Pending API using continuation
* @Param:       String - applicantId
* @Return:      ''
*/
    @AuraEnabled(continuation=true cacheable=true)
    public static Object doAPDPendingCallout(String applicantId,String loanAppId){
        Continuation con;
        try{
            system.debug('::doAPDPendingCallout method is invoked.');
            //Provide API-wise Integration Name to Custom Metadata Configs
            Integration_Configuration__mdt apiConfiguration = IntegrationUtilities.getAPIConfiguration(System.Label.APDPending);
            Integer timeout = Integer.valueOf(apiConfiguration.Timeout__c);

            
            //if stubs checked in Integration_Configuration then stubs will return 
            if(apiConfiguration.IsStub_Required__c != null && apiConfiguration.IsStub_Required__c){  
                String stubData = IntegrationUtilities.getStubResponse(System.Label.APDPending);
                return stubData == null ? System.Label.EmptyStubs : stubData;  
            }

            Applicant__c app = [SELECT Id,Opportunity__r.Parent_Deal_number__c,Opportunity__r.Lead_number__c,applicant_number__c FROM Applicant__c WHERE Id=:applicantId WITH SECURITY_ENFORCED];
            loanApplicationRef= loanAppId;
            
            IND_APDPendingRequest APDPendingRequestDetails = IND_APDPendingService.getAPDPendingRequest(app,loanAppId); 
            system.debug('::APDPendingRequestDetails '+APDPendingRequestDetails);
            CalloutProcessor process = new CalloutProcessor(System.Label.APDPending, APDPendingRequestDetails);
            HttpRequest request = process.createHttpRequest();  
            
            Long startTime = DateTime.now().getTime();
            
            Carrier carrier = new carrier();
            carrier.setServiceName(System.Label.APDPending);
            carrier.setProcessor(process);
            carrier.setRequest(IntegrationUtilities.getPlainTextForLog(request.getBody()));
            carrier.setEncryptedRequest(request.getBody());
            carrier.setStartTime(startTime);
            carrier.setLoanApplicationId(loanAppId);
            
            //Add callout request to continuation
            con = new Continuation(timeout);        
            con.continuationMethod='processAPDPendingAPIResponse';
            con.state=carrier;
            con.addHttpRequest(request);
            
            if(Test.isRunningTest()) {
               continuationLabel = con.addHttpRequest(request);
               continuationState = carrier; 
            }  
        } catch(Exception ex) {
            ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'doAPDPendingCallout', System.Label.Apex,  ex, loanAppId);
            throw ex;
        }
        return con;
    }
    
    /*
* @Method:      processAPDPendingAPIResponse
* @Created by:  Bondiga Thilak 
* @Description: This method is being used to handle the response from continuation and return the response to calling processes
* @Param:       Collection - labels
* @Param:       Object - state
* @Return:      Object - response
*/
    @AuraEnabled(cacheable=true)
    public static Object processAPDPendingAPIResponse(List<String> labels, Object state){
        System.debug('::Inside the APD Pending callback');
        IND_APDPendingResponse apiResponse;
        String request='';
        String encryptedRequest='';
        String serviceName='';
        String data;
         String loanAppId='';
        HttpResponse response;
        String elapseTime='';
        
        try{
            Carrier carrier = (Carrier)state;
            request = carrier.getRequest();
            encryptedRequest = carrier.getEncryptedRequest();
            serviceName = carrier.getServiceName();
            Long startTime = carrier.getStartTime();
            
            CalloutProcessor processor = carrier.getProcessor();
            response = Continuation.getResponse(labels[0]);
            Long endTime = DateTime.now().getTime();
            elapseTime = String.valueOf((Double)(endTime - startTime)/1000);
            loanAppId = carrier.getLoanApplicationId();
            if(response != null && response.getStatusCode() == 200) {
                system.debug('::Inside the response method');
                apiResponse = (IND_APDPendingResponse)processor.getHttpResponse(response, serviceName);
                if(apiResponse != null){
                    data = JSON.serialize(apiResponse);
                    system.debug('data::'+data);
                    IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, IntegrationUtilities.getPlainTextForLog(response.getBody()), response.getBody(), serviceName, elapseTime,loanAppId,System.Label.Success);
                } else {
                    IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, '', '', serviceName, elapseTime,loanAppId,System.Label.Failure);
                    throw new IND_Exception(System.Label.NoResponse);
                }
                
            } else {
                String errString = '[Status Code = '+ response.getStatusCode() +' ] Response-->'+IntegrationUtilities.getPlainTextForLog(response.getBody());
                IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, errString, response.getBody(), serviceName, elapseTime, loanAppId, System.Label.Failure);
                ErrorLoggerUtil.logErrorEvent('CalloutProcessor', 'getHttpResponse', System.Label.Apex, new IND_Exception(errString), loanAppId);
                throw new IND_Exception(System.Label.NoResponse);
            } 
            
        } catch (Exception ex){
            System.debug('callback()====catch');
            IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, '', '', serviceName, elapseTime,loanAppId,System.Label.Failure);
            ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'processAPDPendingAPIResponse', System.Label.Apex, ex,loanAppId);
            throw new AuraHandledException(ex.getMessage());
        }
        return data;
    }
    
    /*
* @Method:      IHMReceiptCallout
* @Created by:  Bharath Moka
* @Description: Method to return Response for IHM Receipt API
* @Param:       String - Applicant Id
* @Return:      String - response
*/
    @AuraEnabled(continuation=true cacheable=true)
    public static Object doIHMReceiptCallout(String applicantId,String loanAppId, String dealId){
        Continuation con;
        try{
            //Provide API-wise Integration Name to Custom Metadata Configs
            Integration_Configuration__mdt apiConfiguration = IntegrationUtilities.getAPIConfiguration(System.Label.IHMReceipt);
            Integer timeout = Integer.valueOf(apiConfiguration.Timeout__c);
            
            System.debug('continuation block()====');
            Applicant__c app = [SELECT Opportunity__r.Deal_Number__c, Opportunity__r.Product_Type__c FROM Applicant__c WHERE Id=:applicantId WITH SECURITY_ENFORCED];
            IND_IHMReceiptRequest iHMReceiptRequest = IND_IHMReceiptService.getIHMReceiptRequest(app,loanAppId,dealId);
            CalloutProcessor processor= new CalloutProcessor(System.Label.IHMReceipt, iHMReceiptRequest);
            HttpRequest request = processor.createHttpRequest();
            
            Long startTime = DateTime.now().getTime();
            
            Carrier carrier = new carrier();
            carrier.setServiceName(System.Label.IHMReceipt);
            carrier.setProcessor(processor);
            carrier.setRequest(IntegrationUtilities.getPlainTextForLog(request.getBody()));
            carrier.setEncryptedRequest(request.getBody());
            carrier.setStartTime(startTime);
            carrier.setLoanApplicationId(loanAppId);
            
            //Add callout request to continuation
            con = new Continuation(timeout);        
            con.continuationMethod='processIHMReceiptResponse';
            con.state=carrier;
            con.addHttpRequest(request);
            
            if(Test.isRunningTest()) {
               continuationLabel = con.addHttpRequest(request);
               continuationState = carrier; 
            }  
        } catch(Exception ex) {
            ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'doIHMReceiptCallout', System.Label.Apex, ex,loanAppId);
            throw ex;
        }
        return con;
    }
    
    /*
* @Method:      processIHMReceiptResponse
* @Created by:  Bharath Moka
* @Description: Method to return Response for IHM Receipt API
* @Param:       Collection - labels
* @Param:       Object - state
* @Return:      Object - response
*/
    @AuraEnabled(cacheable=true)
    public static Object processIHMReceiptResponse(List<String> labels, Object state){
        System.debug('callback()====');
        IND_IHMReceiptResponse apiResponse;
        String request='';
        String encryptedRequest='';
        String serviceName='';
        String data='';
        String loanAppId='';
        HttpResponse response;
        String elapseTime='';
        
        try{
            Carrier carrier = (Carrier)state;
            request = carrier.getRequest();
            encryptedRequest = carrier.getEncryptedRequest();
            serviceName = carrier.getServiceName();
            Long startTime = carrier.getStartTime();
            
            CalloutProcessor processor = carrier.getProcessor();
            response = Continuation.getResponse(labels[0]);
            System.debug('callback()====response'+response);
            Long endTime = DateTime.now().getTime();
            elapseTime = String.valueOf((Double)(endTime - startTime)/1000);
            loanAppId = carrier.getLoanApplicationId();
            
            if(response != null && response.getStatusCode() == 200){
                System.debug('callback()====if'+response);
                apiResponse = (IND_IHMReceiptResponse)processor.getHttpResponse(response, serviceName);
                if(apiResponse != null){
                    data =  JSON.serialize(apiResponse);
                    IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, IntegrationUtilities.getPlainTextForLog(response.getBody()), response.getBody(), serviceName, elapseTime,loanAppId,System.Label.Success);
                }
                else {
                    throw new IND_Exception(System.Label.NoResponse); 
                } 
            } else {
                throw new IND_Exception(System.Label.NoResponse);
            }
            
        } catch (Exception ex){
            IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, '', '', serviceName, elapseTime,loanAppId,System.Label.Failure);
            ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'processResponseIHMReceipt', System.Label.Apex, ex,loanAppId);
            throw new IND_Exception(ex.getMessage());
        }
        return data;
    }
    
     /*
* @Method:      doFicoDeviationCallout
* @Created by:  Prathik
* @Description: This method is being used to call the FicoDeviation using continuation
* @Param:       String - applicantId
* @Return:      ''
*/
    @AuraEnabled(continuation=true)
    public static Object doFicoDeviationCallout(String loanAppId, String flag){
        Continuation con;
        try{
            
            //Provide API-wise Integration Name to Custom Metadata Configs
            Integration_Configuration__mdt apiConfiguration = IntegrationUtilities.getAPIConfiguration(System.Label.Fico_Deviations);
            Integer timeout = Integer.valueOf(apiConfiguration.Timeout__c);

            //if stubs checked in Integration_Configuration then stubs will return 
            if(apiConfiguration.IsStub_Required__c != null && apiConfiguration.IsStub_Required__c){  
                String stubData = IntegrationUtilities.getStubResponse(System.Label.Fico_Deviations);
                return stubData == null ? System.Label.EmptyStubs : stubData;  
            }
            
            Opportunity opty = [SELECT Agent_BL_code__c,Contact_number__c,Funding_on_ORP__c,Gender__c,Insurance_declared_value__c,
                                Lead_number__c,Loan_amount__c,Net_IRR__c,Product_Type__c,Required_Tenure__c,Valuation_price__c,
                                Geo_State_Master__r.State_Code__c,Vehicle_Sub_Category__c,On_Road_price__c,Funding_on_Ex_Showroom__c,
                                Ex_showroom_price__c,Advance_EMI__c,RTO_Road_Tax_New__c,RTO_Road_Tax__c,X1st_yr_Insurance_Premium__c,Other_charges__c,
                                GST_Amount__c,Discount_on_Basic_Price__c,
                                Vehicle_Type__c FROM Opportunity WHERE Id=:loanAppId WITH SECURITY_ENFORCED];
            loanApplicationRef= loanAppId;
            IND_FicoDeviationRequest  ficDevRequestDetails = IND_FicoDeviationService.getFicoDeviationRequest(loanAppId, opty); 
            CalloutProcessor process = new CalloutProcessor(System.Label.Fico_Deviations, ficDevRequestDetails);
            HttpRequest request = process.createHttpRequest();  
            Long startTime = DateTime.now().getTime();
            List<Object> objList = new List<Object>();
            objList.add(flag);
            
            Carrier carrier = new carrier();
            carrier.setServiceName(System.Label.Fico_Deviations);
            carrier.setProcessor(process);
            carrier.setRequest(IntegrationUtilities.getPlainTextForLog(request.getBody()));
            carrier.setEncryptedRequest(request.getBody());
            carrier.setStartTime(startTime);
            carrier.setLoanApplicationId(loanApplicationRef);
            carrier.setTempObject(objList);
            
            //Add callout request to continuation
            con = new Continuation(timeout);        
            con.continuationMethod='processFicoDeviationAPIResponse';
            con.state = carrier;
            con.addHttpRequest(request);
            if(Test.isRunningTest()) {
               continuationLabel = con.addHttpRequest(request);
               continuationState = carrier; 
            }  
        } catch(Exception ex) {
            ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'doFicoDeviationCallout', System.Label.Apex, ex,loanApplicationRef);
            throw ex;
        }
        return con;
    }
    
    
    
    /*
* @Method:      processFicoDeviationAPIResponse
* @Created by:  Prathik
* @Description: This method is being used to handle the response from continuation and return the response to calling processes
* @Param:       Collection - labels
* @Param:       Object - state
* @Return:      Object - response
*/
    @AuraEnabled
    public static Object processFicoDeviationAPIResponse(List<String> labels, Object state){
        String apiResponse;
        String request='';
        String encryptedRequest='';
        String loanAppId='';
        String serviceName='';
        String data;
        HttpResponse response;
        String elapseTime='';
        List<Object> objList;
        
        try{
            Carrier carrier = (Carrier)state;
            request = carrier.getRequest();
            encryptedRequest = carrier.getEncryptedRequest();
            serviceName = carrier.getServiceName();
            Long startTime = carrier.getStartTime();
            objList = carrier.getTempObject();
            
            CalloutProcessor processor = carrier.getProcessor();
            response = Continuation.getResponse(labels[0]);
            Long endTime = DateTime.now().getTime();
            elapseTime = String.valueOf((Double)(endTime - startTime)/1000);
            loanAppId = carrier.getLoanApplicationId();
            String flag = (String)objList.get(0);
            if(response != null && response.getStatusCode() == 200) {
                
                apiResponse = (String)processor.getHttpResponseForAll(response, serviceName);
                if(apiResponse !=null){
                    if(flag.equals('NSTP')){
                        Map<String, object> serialzedJsonMap = (Map<String, object>)JSON.deserializeUntyped(apiResponse);
                        Map<String, Object> objMap =(Map<String, object>) serialzedJsonMap.get('Borrower');
                        List<Object> devObjList = (List<Object>) objMap.get('Deviations');
                        if(devObjList.size() >=1){
                          data = 'Fail';  
                        } else {
                          data = 'Pass';  
                        }
                    } else {
                        data = JSON.serialize(apiResponse);
                    }
                    
                    IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, IntegrationUtilities.getPlainTextForLog(response.getBody()), response.getBody(), serviceName, elapseTime,loanAppId,System.Label.Success);
                } else {
                    IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, IntegrationUtilities.getPlainTextForLog(response.getBody()), response.getBody(), serviceName, elapseTime,loanAppId,System.Label.Failure);
                    throw new IND_Exception(System.Label.FicoDeviationNoResponse);                
                }
            } else {
                String errString = '[Status Code = '+ response.getStatusCode() +' ] Response-->'+IntegrationUtilities.getPlainTextForLog(response.getBody());
                IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, errString, response.getBody(), serviceName, elapseTime, loanAppId, System.Label.Failure);
                throw new IND_Exception(System.Label.NoResponse);
            } 
            
        } catch (Exception ex){
            System.debug('callback()====catch' + ex.getMessage() + ' at ' + ex.getLineNumber());
            ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'processFicoDeviationAPIResponse', System.Label.Apex, ex,loanAppId);
            throw new IND_Exception(ex.getMessage());
        }
        return data;
    }
    
      
  
    /*
* @Method:      doOfferEngineCallout
* @Created by:  Satyam More
* @Description: Continuation for Offer Engine API
* @Param:       String - 
* @Return:      Object - continuation
*/
    
    @AuraEnabled(continuation=true cacheable=true)
    public static Object doOfferEngineCallout(String offerEngineRequestString){
        Continuation con;
        String loanAppId='';
        Carrier carrier = new carrier();
        try{
            //Provide API-wise Integration Name to Custom Metadata Configs
            Integration_Configuration__mdt apiConfiguration = IntegrationUtilities.getAPIConfiguration(System.Label.OfferEngine);
            Integer timeout = Integer.valueOf(apiConfiguration.Timeout__c);
            
            //if stubs checked in Integration_Configuration then stubs will return 
            if(apiConfiguration.IsStub_Required__c != null && apiConfiguration.IsStub_Required__c){  
                String stubData = IntegrationUtilities.getStubResponse(System.Label.OfferEngine);
                return stubData == null ? System.Label.EmptyStubs : stubData;  
            }
            
            RequestWrapper requestWrapper = (RequestWrapper)IntegrationUtilities.parseJSONRequest(offerEngineRequestString,'RequestWrapper');
            loanApplicationRef= requestWrapper.loanApplicationId;
            loanAppId=requestWrapper.loanApplicationId;
            List<Opportunity> opp = [SELECT Contact_number__c ,Vehicle_Type__c,Required_Tenure__c,Loan_amount__c,Funding_on_Ex_Showroom__c,Funding_on_ORP__c,Product_Type__c,Lead_number__c,Required_ROI__c,Ex_showroom_price__c,On_Road_price__c,LeadSource FROM Opportunity WHERE ID=:requestWrapper.loanApplicationId WITH SECURITY_ENFORCED Limit 1];//OLA-139
            if(!opp.isEmpty()){ 
                for(Opportunity opportunity:opp){
                    requestWrapper.vehicleType = opportunity.Vehicle_Type__c;
                    requestWrapper.leadId =  String.valueOf(opportunity.Lead_number__c);
                    requestWrapper.product = String.valueOf(opportunity.Product_Type__c);
                    requestWrapper.crmIrrRequested =String.valueOf(opportunity.Required_ROI__c);
                    requestWrapper.exShowroomPrice =String.valueOf(opportunity.Ex_showroom_price__c);
                    requestWrapper.onRoadPrice = String.valueOf(opportunity.On_Road_price__c);  
                    requestWrapper.contactNumber = opportunity.Contact_number__c;
                    requestWrapper.loanAmount = opportunity.Loan_amount__c;
                    requestWrapper.fundingOnExShowroom=String.valueOf(opportunity.Funding_on_Ex_Showroom__c);
                    requestWrapper.fundingOnORP=String.valueOf(opportunity.Funding_on_ORP__c);
                    if(opportunity.LeadSource=='OLA'){//OLA-139
                        requestWrapper.tenureChanged=String.valueOf(opportunity.Required_Tenure__c+1);
                        requestWrapper.tenure=requestWrapper.tenureChanged;
                    } else {
                        requestWrapper.tenure=String.valueOf(opportunity.Required_Tenure__c);
                    }
                }
            } 
            
            
            List<Final_Term__c> finalTerm = [SELECT Advance_EMI__c ,PricingEngine_thresholdNetrr__c,LtvEngine_Ltv__c,Provisional_Channel_Cost__c,Dealer_incentive_amount_main_dealer__c,
                                             Dealer_incentive_amount_sub_dealer__c,Mfr_incentive__c,Rreferrer_Incentive__c,Gift_through_dealer_amount__c,
                                             DSM_Incentive1__c,DSM_Incentive2__c,Documentation_charges__c,Service_charges__c,Mfr_Exp_Reimburse_Amt__c,
                                             Dlr_Exp_Reimburse_Amt__c,Net_IRR__c,Net_IRR_Decimal__c,Loan_Amount__c,Tenure__c,CRM_IRR__c, Required_CRM_IRR__c, Inputted_IRR__c,OfferengineMaxLoanAmount__c,OfferengineMinLoanAmount__c,isNavigate__c, Installment_Type__c,First_EMI_Date__c,Second_EMI_Date__c,Loan_Deal_Date__c,Holiday_period__c FROM Final_Term__c WHERE Loan_Application__c=:requestWrapper.loanApplicationId WITH SECURITY_ENFORCED Limit 1];
            if(finalTerm.isEmpty()){ 
                throw new IND_Exception('Final terms details required');             
            }
            List <InsuranceDetails__c> insuranceDetails = [SELECT Id, amount__c FROM InsuranceDetails__c where Funded_Non_funded__c = 'Funded' and applicant__r.applicant_type__c = 'borrower' and Loan_Application__r.id =:requestWrapper.loanApplicationId WITH SECURITY_ENFORCED];
            Decimal sumOfFundedInsurance=0;
            if(!insuranceDetails.isEmpty()){ 
                for(InsuranceDetails__c insuranceDetail:insuranceDetails){
                    sumOfFundedInsurance +=insuranceDetail.amount__c;
                }
            }              
            requestWrapper.sumOfFundedInsurance= String.valueOf((Integer)sumOfFundedInsurance);
            List<Applicant__c> appList = [SELECT Id,Applicant_Type__c,In_Active_Applicant__c,Declared_income__c,Applicant_number__c FROM Applicant__c 
                                          WHERE Opportunity__r.id =:loanAppId WITH SECURITY_ENFORCED];
            Integer income=0 ; 
            Decimal emi=0 ; 
            Integer borrIncome=0;
            Integer coBorrIncome=0;
            Decimal borrEMI=0;
            Decimal coBorrEMI=0;
            
				for(Applicant__c applicant : appList){
                
                if(applicant.Applicant_Type__c.equals('Co-borrower') && applicant.In_Active_Applicant__c==false){
                    
                    List<Income_Details__c> incomeDetails = [SELECT Id,Income_from_Perfios__c,Is_Salaried__c,Do_You_File_ITR__c,Do_You_File_GST__c,Income__c FROM Income_Details__c WHERE Primary_Income_Source__c=true AND Applicant__r.Id =: applicant.Id WITH SECURITY_ENFORCED limit 1];
                    
                    List<Existing_EMI__c> emiDetails = [SELECT Id,EMI__c FROM Existing_EMI__c WHERE Applicant_Id__c =: applicant.Id WITH SECURITY_ENFORCED];
                    if(!incomeDetails.isEmpty()){
                        for(Income_Details__c incomeDetail :incomeDetails){
                            
                            if(incomeDetail.Income_from_Perfios__c!=null && (Integer)incomeDetail.Income_from_Perfios__c!=0 ){
                                if(incomeDetail.Is_Salaried__c){
                                    coBorrIncome=(Integer)incomeDetail.Income_from_Perfios__c;
                                }
                                else if((incomeDetail.Is_Salaried__c==false)  && (incomeDetail.Do_You_File_ITR__c==true)){
                                    
                                    coBorrIncome=(Integer)incomeDetail.Income_from_Perfios__c;
                                }
                                
                                else if((incomeDetail.Is_Salaried__c==false) && incomeDetail.Do_You_File_GST__c==true){
                                    
                                    coBorrIncome=(Integer)incomeDetail.Income_from_Perfios__c *12;
                                }
                            }
                            else {  
                                coBorrIncome =(Integer)incomeDetail.Income__c; 
                            }
                        }
                    }
                    
                    for(Existing_EMI__c emiDetail :emiDetails ){
                        
                        if(emiDetail.EMI__c!=null){
                            
                            coBorrEMI =  coBorrEMI + emiDetail.EMI__c;
                        }
                        
                    }
                    
                }
                
                else 
                    if(applicant.Applicant_Type__c.equals('Borrower')){
                        requestWrapper.borrowerApplicantNumber=applicant.Applicant_number__c;
                        List<Income_Details__c> incomeDetails = [SELECT Id,Income_from_Perfios__c,Is_Salaried__c,Do_You_File_ITR__c,Do_You_File_GST__c,Income__c FROM Income_Details__c WHERE Primary_Income_Source__c=true AND Applicant__r.Id =: applicant.Id WITH SECURITY_ENFORCED limit 1];
                        List<Existing_EMI__c> emiDetails = [SELECT Id,EMI__c FROM Existing_EMI__c WHERE Applicant_Id__c =: applicant.Id WITH SECURITY_ENFORCED];
						if(!incomeDetails.isEmpty()){   
                            for(Income_Details__c incomeDetail :incomeDetails){
                                
                                if(incomeDetail.Income_from_Perfios__c!=null && (Integer)incomeDetail.Income_from_Perfios__c!=0){
                                    if(incomeDetail.Is_Salaried__c){
                                        borrIncome=(Integer)incomeDetail.Income_from_Perfios__c;
                                    }
                                    else if((!incomeDetail.Is_Salaried__c) && incomeDetail.Do_You_File_ITR__c==true){
                                        
                                        borrIncome=(Integer)incomeDetail.Income_from_Perfios__c;
                                    }
                                    
                                    else if((!incomeDetail.Is_Salaried__c) && incomeDetail.Do_You_File_GST__c==true){
                                        
                                        borrIncome=(Integer)incomeDetail.Income_from_Perfios__c *12;
                                    }
                                }
                                else {  
                                    borrIncome =(Integer)incomeDetail.Income__c; 
                                }
                            }   
                        }
                        
                        for(Existing_EMI__c emiDetail :emiDetails ){
                            
                            if(emiDetail.EMI__c!=null){
                                
                                borrEMI =  borrEMI + emiDetail.EMI__c;
                            }
                            
                        }           
                    }
            }          

            if(borrIncome!=null && coBorrIncome !=null){
                income =  borrIncome + coBorrIncome;
            }
            else if(borrIncome!=null && coBorrIncome==null){
                income =  borrIncome;
            }
            else if(coBorrIncome!=null && borrIncome==null){
                income =  coBorrIncome;
            }
            
            if(borrEMI!=null && coBorrEMI!=null){
                emi = borrEMI+coBorrEMI;
            } 
            else if(borrEMI!=null && coBorrEMI==null){
                emi = borrEMI;
            }
            else if(coBorrEMI!=null && borrEMI==null){
                emi = coBorrEMI;
            }

            requestWrapper.emi=String.valueOf(emi);
            requestWrapper.income=String.valueOf(income);

            IND_OfferEngineRequest offerEngineRequest = IND_OfferEngineService.getOfferEngineCallOutRequest(requestWrapper,finalTerm,loanAppId);
            CalloutProcessor processor= new CalloutProcessor(System.Label.OfferEngine, offerEngineRequest);
            HttpRequest request = processor.createHttpRequest();
            Long startTime = DateTime.now().getTime();
            carrier.setServiceName(System.Label.OfferEngine);
            carrier.setProcessor(processor);
            carrier.setRequest(IntegrationUtilities.getPlainTextForLog(request.getBody()));
            carrier.setEncryptedRequest(request.getBody());
            carrier.setStartTime(startTime);
            carrier.setLoanApplicationId(loanAppId);            
            //Add callout request to continuation
            con = new Continuation(timeout);        
            con.continuationMethod='processOfferEngineCalloutResponse';
            con.state=carrier;
            con.addHttpRequest(request);
            
            if(Test.isRunningTest()) {
                continuationLabel = con.addHttpRequest(request);
                continuationState = carrier; 
            }  
        } catch(Exception ex) {
            ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'doOfferEngineCallout', System.Label.Apex, ex, loanAppId);
            throw ex;
        }
        return con;
    }
    
    
    /*
* @Method:      processOfferEngineCalloutResponse
* @Created by:  Satyam More 
* @Description: Callback method to return Response for Offer Engine API
* @Param:       Collection - labels
* @Param:       Object - state
* @Return:      Object - response
*/
    @AuraEnabled
    public static Object processOfferEngineCalloutResponse(List<String> labels, Object state){
        IND_OfferEngineResponse apiResponse;
        String request='';
        String encryptedRequest='';
        String serviceName='';
        String loanAppId='';
        HttpResponse response;
        String elapseTime='';  
        String responseBody='';
        try{            
            Carrier carrier = (Carrier)state;
            request = carrier.getRequest();
            encryptedRequest = carrier.getEncryptedRequest();
            serviceName = carrier.getServiceName();
            Long startTime = carrier.getStartTime();            
            CalloutProcessor processor = carrier.getProcessor();
            response = Continuation.getResponse(labels[0]);
            Long endTime = DateTime.now().getTime();
            elapseTime = String.valueOf((Double)(endTime - startTime)/1000);
            loanAppId = carrier.getLoanApplicationId();
            if(response != null && response.getStatusCode() == 200){
                apiResponse = (IND_OfferEngineResponse)processor.getHttpResponse(response, serviceName);     
                if(apiResponse!=null){
                    IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, IntegrationUtilities.getPlainTextForLog(response.getBody()), response.getBody(), serviceName, elapseTime,loanAppId,System.Label.Success);
                    return JSON.serialize(apiResponse);
                } else {
                    IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, IntegrationUtilities.getPlainTextForLog(response.getBody()), response.getBody(), serviceName, elapseTime,loanAppId,System.Label.Failure);
                    throw new IND_Exception(System.Label.NoResponse);                
                }
            }
            else {
                String errString = '[Status Code = '+ response.getStatusCode() +' ] Response-->'+IntegrationUtilities.getPlainTextForLog(response.getBody());
                IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, errString, response.getBody(), serviceName, elapseTime, loanAppId, System.Label.Failure);
                ErrorLoggerUtil.logErrorEvent('CalloutProcessor', 'getHttpResponse', System.Label.Apex, new IND_Exception(errString), loanAppId);
                throw new IND_Exception(System.Label.NoResponse);
            } 
        } catch (Exception ex){
            IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, response + '', '', serviceName, elapseTime, loanAppId,System.Label.Failure);
            ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'processOfferEngineCalloutResponse', System.Label.Apex, ex, loanAppId);
            throw new IND_Exception(ex.getMessage());
        }
    }
    
    /*
* @Method:      doCSRVahanFIwaiverCallout
* @Created by:  Chowdesha N
* @Description: This method is being used to call the CSRVahanFIwaiver API using continuation
* @Param:       String - applicantId
* @Return:      ''
*/
    @AuraEnabled(continuation=true cacheable=true)
    public static Object doCSRVahanFIwaiverCallout(String fiWaiverString){
        Continuation con;
        try{
            //Provide API-wise Integration Name to Custom Metadata Configs
            Integration_Configuration__mdt apiConfiguration = IntegrationUtilities.getAPIConfiguration(System.Label.CSRVahanFIwaiver);
            Integer timeout = Integer.valueOf(apiConfiguration.Timeout__c);

            //if stubs checked in Integration_Configuration then stubs will return 
            if(apiConfiguration.IsStub_Required__c != null && apiConfiguration.IsStub_Required__c){  
                String stubData = IntegrationUtilities.getStubResponse(System.Label.CSRVahanFIwaiver);
                return stubData == null ? System.Label.EmptyStubs : stubData;  
            }
            RequestWrapper requestWrapper = (RequestWrapper)IntegrationUtilities.parseJSONRequest(fiWaiverString,'RequestWrapper');
            
            List<Applicant__c> appList = [SELECT Id, Opportunity__r.Lead_number__c,Opportunity__r.Vehicle_Type__c, Opportunity__r.Product_Type__c, 
                                          Scorecard_Decision__c, Applicant_Type__c , applicant_number__c, Current_Address_Not_Present__c
                                          FROM Applicant__c 
                                          WHERE Opportunity__r.id =:requestWrapper.loanApplicationId AND In_Active_Applicant__c = false WITH SECURITY_ENFORCED];
            
            if(appList.isEmpty()){
                throw new IND_Exception(System.Label.Applicantdatamissing);
            }
            requestWrapper.borrowerNIP='N';
            requestWrapper.coBorrowerNIP='N';
            requestWrapper.borrowerPresentAddress='N';
            requestWrapper.coBorrowerPresentAddress='N';
            
            for(Applicant__c applicant : appList){
                List<Income_Details__c> incomeDetails = [SELECT Id FROM Income_Details__c WHERE Income_Source_Status__c ='NIP' AND Primary_Income_Source__c=true AND Applicant__r.Id =: applicant.Id WITH SECURITY_ENFORCED];
                
                if(!incomeDetails.isEmpty() && applicant.Applicant_Type__c=='Borrower'){
                   requestWrapper.borrowerNIP='Y';
                }
                else if(!incomeDetails.isEmpty() && applicant.Applicant_Type__c=='Co-borrower'){
                   requestWrapper.coBorrowerNIP='Y';
                }
                else if(incomeDetails.isEmpty() && applicant.Applicant_Type__c=='Borrower'){
                   requestWrapper.borrowerNIP='N';
                }
                else if(incomeDetails.isEmpty() && applicant.Applicant_Type__c=='Co-borrower'){
                   requestWrapper.coBorrowerNIP='N';
                }
                
                if(applicant.Current_Address_Not_Present__c==false && (applicant.Applicant_Type__c=='Borrower' || applicant.Applicant_Type__c=='Co-borrower')){
                    requestWrapper.borrowerPresentAddress='Y';
                    requestWrapper.coBorrowerPresentAddress='Y';
                } 
            }
            
            loanApplicationRef= requestWrapper.loanApplicationId;
            
            IND_CSRVahanFIwaiverRequest CSRVahanFIwaiverRequestDetails = IND_CSRVahanFIwaiverService.getCSRVahanFIwaiverRequest(requestWrapper,appList); 
            CalloutProcessor process = new CalloutProcessor(System.Label.CSRVahanFIwaiver, CSRVahanFIwaiverRequestDetails);
            HttpRequest request = process.createHttpRequest();  
            
            Long startTime = DateTime.now().getTime();
            
            Carrier carrier = new carrier();
            carrier.setServiceName(System.Label.CSRVahanFIwaiver);
            carrier.setProcessor(process);
            carrier.setRequest(IntegrationUtilities.getPlainTextForLog(request.getBody()));
            carrier.setEncryptedRequest(request.getBody());
            carrier.setStartTime(startTime);
            carrier.setLoanApplicationId(requestWrapper.loanApplicationId);
            //Add callout request to continuation
            con = new Continuation(timeout);        
            con.continuationMethod='processCSRVahanFIwaiverAPIResponse';
            con.state=carrier;
            con.addHttpRequest(request);
            
            if(Test.isRunningTest()) {
               continuationLabel = con.addHttpRequest(request);
               continuationState = carrier; 
            }  
        } catch(Exception ex) {
            ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'CSRVahanFIwaiverCallout', System.Label.Apex, ex,loanApplicationRef);
            throw ex;
        }
        return con;
    }
    
    /*
* @Method:      processCSRVahanFIwaiverAPIResponse
* @Created by:  Chowdesha N
* @Description: This method is being used to handle the response from continuation and return the response to calling processes
* @Param:       Collection - labels
* @Param:       Object - state
* @Return:      Object - response
*/
    @AuraEnabled(cacheable=true)
    public static Object processCSRVahanFIwaiverAPIResponse(List<String> labels, Object state){
        Ind_CSRVahanFIwaiverResponse apiResponse;
        String responseBody='';
        String request='';
        String encryptedRequest='';
        String serviceName='';
        String loanAppId = ''; 
        HttpResponse response;
        String elapseTime='';
        
        try{
            Carrier carrier = (Carrier)state;
            request = carrier.getRequest();
            encryptedRequest = carrier.getEncryptedRequest();
            serviceName = carrier.getServiceName();
            Long startTime = carrier.getStartTime();
            
            CalloutProcessor processor = carrier.getProcessor();
            response = Continuation.getResponse(labels[0]);
            Long endTime = DateTime.now().getTime();
            elapseTime = String.valueOf((Double)(endTime - startTime)/1000);
            loanAppId = carrier.getLoanApplicationId();
            if(response != null && response.getStatusCode() == 200){
                apiResponse = (Ind_CSRVahanFIwaiverResponse)processor.getHttpResponse(response, serviceName);     
                if(apiResponse!=null){
                    IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, IntegrationUtilities.getPlainTextForLog(response.getBody()), response.getBody(), serviceName, elapseTime,loanAppId,System.Label.Success);
                    return JSON.serialize(apiResponse);
                } else {
                    IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, IntegrationUtilities.getPlainTextForLog(response.getBody()), response.getBody(), serviceName, elapseTime,loanAppId,System.Label.Failure);
                    throw new IND_Exception(System.Label.NoResponse);                
                }
            }
            else {
                String errString = '[Status Code = '+ response.getStatusCode() +' ] Response-->'+IntegrationUtilities.getPlainTextForLog(response.getBody());
                IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, errString, response.getBody(), serviceName, elapseTime, loanAppId, System.Label.Failure);
                ErrorLoggerUtil.logErrorEvent('CalloutProcessor', 'getHttpResponse', System.Label.Apex, new IND_Exception(errString), loanAppId);
                throw new IND_Exception(System.Label.NoResponse);
            } 
            
        } catch (Exception ex){
            IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, '', '', serviceName, elapseTime,loanAppId,System.Label.Failure);
            ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'processCSRVahanFIwaiverAPIResponse', System.Label.Apex, ex,loanAppId);
            throw new IND_Exception(ex.getMessage());
        }
    }
    
   /*
* @Method:      doDMSUploadCallout
* @Created by:  Yugandhar
* @Description: This method is being used to call the DMSUpload API using continuation
* @Param:       String - applicantId
* @Return:      ''
*/
    @AuraEnabled(continuation=true cacheable=true)
    public static Object doDMSUploadCallout(String loanAppId,String documentType, String dealId){
        Continuation con;
        try{
            system.debug('::doDMSUploadCallout method is invoked.');
            //Provide API-wise Integration Name to Custom Metadata Configs
            Integration_Configuration__mdt apiConfiguration = IntegrationUtilities.getAPIConfiguration(System.Label.DMSUpload);
            
            //if stubs checked in Integration_Configuration then stubs will return 
            if(apiConfiguration.IsStub_Required__c != null && apiConfiguration.IsStub_Required__c){  
                String stubData = IntegrationUtilities.getStubResponse(System.Label.DMSUpload);
                return stubData == null ? System.Label.EmptyStubs : stubData;
            }
            Integer timeout = Integer.valueOf(apiConfiguration.Timeout__c);
            
            loanApplicationRef= loanAppId;
            IND_DMSUploadRequest dmsUploadRequest = IND_DMSUploadService.getDMSUploadRequest(loanAppId,documentType, dealId); 
            system.debug('::dmsUploadRequest '+dmsUploadRequest);
            CalloutProcessor process = new CalloutProcessor(System.Label.DMSUpload, dmsUploadRequest);
            HttpRequest request = process.createHttpRequest();  
            
            Long startTime = DateTime.now().getTime();
            
            Carrier carrier = new carrier();
            carrier.setServiceName(System.Label.DMSUpload);
            carrier.setProcessor(process);
            carrier.setRequest(IntegrationUtilities.getPlainTextForLog(request.getBody()));
            carrier.setEncryptedRequest(request.getBody());
            carrier.setStartTime(startTime);
            carrier.setLoanApplicationId(loanAppId);
            
            //Add callout request to continuation
            con = new Continuation(timeout);        
            con.continuationMethod='processDMSCalloutAPIResponse';
            con.state=carrier;
            con.addHttpRequest(request);
            
            if(Test.isRunningTest()) {
               continuationLabel = con.addHttpRequest(request);
               continuationState = carrier; 
            }  
        } catch(Exception ex) {
            ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'DMSUploadCallout', System.Label.Apex, ex,loanAppId);
            throw ex;
        }
        return con;
    }
    
    /*
* @Method:      processDMSCalloutAPIResponse
* @Created by:  Yugandhar
* @Description: This method is being used to handle the response from continuation and return the response to calling processes
* @Param:       Collection - labels
* @Param:       Object - state
* @Return:      Object - response
*/
    @AuraEnabled(cacheable=true)
    public static Object processDMSCalloutAPIResponse(List<String> labels, Object state){
        System.debug('::Inside the DMSUpload callback');
        IND_DMSUploadResponse apiResponse;
        String request='';
        String encryptedRequest='';
        String serviceName='';
        String data;
        String loanAppId='';
        HttpResponse response;
        String elapseTime='';
        
        try{
            Carrier carrier = (Carrier)state;
            request = carrier.getRequest();
            encryptedRequest = carrier.getEncryptedRequest();
            serviceName = carrier.getServiceName();
            Long startTime = carrier.getStartTime();
            
            CalloutProcessor processor = carrier.getProcessor();
            response = Continuation.getResponse(labels[0]);
            Long endTime = DateTime.now().getTime();
            elapseTime = String.valueOf((Double)(endTime - startTime)/1000);
            loanAppId = carrier.getLoanApplicationId();
            
            if(response != null && response.getStatusCode() == 200) {
                system.debug('::Inside the response method');
                apiResponse = (IND_DMSUploadResponse)processor.getHttpResponse(response, serviceName);
                if(apiResponse != null){
                    data = JSON.serialize(apiResponse);
                    system.debug('data::'+data);
                    IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, IntegrationUtilities.getPlainTextForLog(response.getBody()), response.getBody(), serviceName, elapseTime,loanAppId,System.Label.Success);
                } else {
                    IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, IntegrationUtilities.getPlainTextForLog(response.getBody()), response.getBody(), serviceName, elapseTime,loanAppId,System.Label.Failure);
                    throw new IND_Exception(System.Label.NoResponse); 
                }
                
            } else {
                String errString = '[Status Code = '+ response.getStatusCode() +' ] Response-->'+IntegrationUtilities.getPlainTextForLog(response.getBody());
                IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, errString, response.getBody(), serviceName, elapseTime, loanAppId, System.Label.Failure);
                ErrorLoggerUtil.logErrorEvent('CalloutProcessor', 'getHttpResponse', System.Label.Apex, new IND_Exception(errString), loanAppId);
                throw new IND_Exception(System.Label.NoResponse);
            } 
            
        } catch (Exception ex){
            System.debug('callback()====catch');
            IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, '', '', serviceName, elapseTime,loanAppId,System.Label.Failure);
            ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'processDMSCalloutAPIResponse', System.Label.Apex, ex,loanAppId);
            throw new IND_Exception(ex.getMessage());
            //throw new AuraHandledException(ex.getMessage());
        }
        return data;
    }
    
    /*
* @Method:      doAMLCheckCallout
* @Created by:  Vaishnavi Gadewar 
* @Description: Method to return Response for AML Check
* @Param:       String - Applicant Id
* @Return:      String - response
*/
    @AuraEnabled(continuation=true cacheable=true)
    public static Object doAMLCheckCallout(String applicantId,String loanAppId){
        Continuation con;
        try{
            system.debug('::doAMLCheckCallout method is invoked.');
            //Provide API-wise Integration Name to Custom Metadata Configs
            Integration_Configuration__mdt apiConfiguration = IntegrationUtilities.getAPIConfiguration(System.Label.AMLCheck);
            Integer timeout = Integer.valueOf(apiConfiguration.Timeout__c);

            //if stubs checked in Integration_Configuration then stubs will return 
            if(apiConfiguration.IsStub_Required__c != null && apiConfiguration.IsStub_Required__c){  
                String stubData = IntegrationUtilities.getStubResponse(System.Label.AMLCheck);
                return stubData == null ? System.Label.EmptyStubs : stubData;  
            }

            Applicant__c app = new Applicant__c();
            List<Opportunity> oppList = new List<Opportunity>([Select id, Product_Type__c, Date_of_Incorporation__c, Customer_Type__c From Opportunity Where Id=: loanAppId LIMIT 1]);
            if(oppList.size() > 0 && oppList[0].Product_Type__c == System.Label.Tractor && oppList[0].Customer_Type__c == 'Non-Individual'){
                app = [SELECT Id,Opportunity__r.Date_of_Incorporation__c, DocAuth_Application_Id__c,Applicant_Number__c,Name,Opportunity__r.Lead_number__c,Opportunity__r.Customer_Type__c,Opportunity__r.Product_Type__c,Applicant_Type__c,(SELECT Id,Proof_of_Address_POA__c,Proof_of_Identity_POI__c, KYC_DOB__c, KYC_City__c,Document_Type__c FROM Documents__r LIMIT 1000) FROM Applicant__c WHERE Id=:applicantId WITH SECURITY_ENFORCED];
            }else{
                app = [SELECT Id,DocAuth_Application_Id__c,Applicant_Number__c,Name,Opportunity__r.Lead_number__c,Opportunity__r.Customer_Type__c,Opportunity__r.Product_Type__c,Applicant_Type__c,(SELECT Id,Proof_of_Address_POA__c,Proof_of_Identity_POI__c, KYC_DOB__c, KYC_City__c,Document_Type__c FROM Documents__r WHERE KYC_DOB__c != NULL AND KYC_City__c != NULL AND (Proof_of_Address_POA__c = true OR Proof_of_Identity_POI__c = true)) FROM Applicant__c WHERE Id=:applicantId WITH SECURITY_ENFORCED];
            }
            
            loanApplicationRef= loanAppId;
            IND_AMLCheckRequest AMLCheckRequest = IND_AMLCheckService.getAMLCheckRequest(app,loanAppId);
            
            CalloutProcessor process = new CalloutProcessor(System.Label.AMLCheck, AMLCheckRequest);
            HttpRequest request = process.createHttpRequest();  
            
            Long startTime = DateTime.now().getTime();
            
            Carrier carrier = new carrier();
            carrier.setServiceName(System.Label.AMLCheck);
            carrier.setProcessor(process);
            carrier.setRequest(IntegrationUtilities.getPlainTextForLog(request.getBody()));
            carrier.setEncryptedRequest(request.getBody());
            carrier.setStartTime(startTime);
            carrier.setLoanApplicationId(loanAppId);
            
            //Add callout request to continuation
            con = new Continuation(timeout);        
            con.continuationMethod='processAMLCheckAPIResponse';
            con.state=carrier;
            con.addHttpRequest(request);
            
            if(Test.isRunningTest()) {
               continuationLabel = con.addHttpRequest(request);
               continuationState = carrier; 
            }  
        } catch(Exception ex) {
            ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'doAMLCheckCallout', System.Label.Apex, ex);
            throw ex;
        }
        return con;
    }
    
    
    /*
* @Method:      AMLCheckResponse
* @Created by:  Vaishnavi Gadewar
* @Description: Method to return Response for AML Check
* @Param:       Collection - labels
* @Param:       Object - state
* @Return:      Object - response
*/
    @AuraEnabled(cacheable=true)
    public static Object processAMLCheckAPIResponse(List<String> labels, Object state){
        System.debug('callback()====');
        IND_AMLCheckResponse apiResponse;
        String request='';
        String encryptedRequest='';
        String serviceName='';
        String data='';
        HttpResponse response;
        String elapseTime='';
        String loanAppId = '';
        
        try{
            Carrier carrier = (Carrier)state;
            request = carrier.getRequest();
            encryptedRequest = carrier.getEncryptedRequest();
            serviceName = carrier.getServiceName();
            Long startTime = carrier.getStartTime();
            
            CalloutProcessor processor = carrier.getProcessor();
            response = Continuation.getResponse(labels[0]);
            System.debug('callback()====response'+response);
            Long endTime = DateTime.now().getTime();
            elapseTime = String.valueOf((Double)(endTime - startTime)/1000);
            loanAppId = carrier.getLoanApplicationId();
            if(response != null && response.getStatusCode() == 200){
                System.debug('callback()====if'+response);
                apiResponse = (IND_AMLCheckResponse)processor.getHttpResponse(response, serviceName);
                System.debug('callback() apiResponse()===='+apiResponse);
                if(apiResponse != null){
                    IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, IntegrationUtilities.getPlainTextForLog(response.getBody()), response.getBody(), serviceName, elapseTime, loanAppId,System.Label.Success);
                    return JSON.serialize(apiResponse);
                }
                else {
                    IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, IntegrationUtilities.getPlainTextForLog(response.getBody()), response.getBody(), serviceName, elapseTime, loanAppId,System.Label.Failure);
                    throw new IND_Exception('No response found');
                } 
            }
            //IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, IntegrationUtilities.getPlainTextForLog(response.getBody()), response.getBody(), serviceName, elapseTime, loanAppId);
        else {
                String errString = '[Status Code = '+ response.getStatusCode() +' ] Response-->'+IntegrationUtilities.getPlainTextForLog(response.getBody());
                IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, errString, response.getBody(), serviceName, elapseTime, loanAppId, System.Label.Failure);
                ErrorLoggerUtil.logErrorEvent('CalloutProcessor', 'getHttpResponse', System.Label.Apex, new IND_Exception(errString), loanAppId);
                throw new IND_Exception(System.Label.NoResponse);
            } 
        } catch (Exception ex){
            ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'processAMLCheckAPIResponse', System.Label.Apex, ex, loanAppId);
            throw new IND_Exception(ex.getMessage());
        }
        
    }
    

/*
* @Method:      doBREscoreCardCallout
* @Created by:  Bondiga Thilak 
* @Description: This method is being used to call the BREscoreCard API using continuation
* @Param:       String - applicantId
* @Return:      ''
*/
    @AuraEnabled(continuation=true cacheable=true)
    public static Object doBREscoreCardCallout(String applicantId, String loanAppId){
        Continuation con;
        try{
            if(String.isBlank(applicantId)){
                throw new IND_Exception(System.Label.Retry); 
            }
            //Provide API-wise Integration Name to Custom Metadata Configs
            Integration_Configuration__mdt apiConfiguration = IntegrationUtilities.getAPIConfiguration(System.Label.BREscorecardAPI);
            Integer timeout = Integer.valueOf(apiConfiguration.Timeout__c);
            loanApplicationRef= loanAppId;

            //if stubs checked in Integration_Configuration then stubs will return 
            if(apiConfiguration.IsStub_Required__c != null && apiConfiguration.IsStub_Required__c){  
                String stubData = IntegrationUtilities.getStubResponse(System.Label.BREscorecardAPI);
                return stubData == null ? System.Label.EmptyStubs : stubData;  
            }
            
            Applicant__c app = [SELECT Id,Opportunity__r.Customer_Deal_No__c,Opportunity__r.Lead_number__c,Opportunity__r.Product_Type__c,Opportunity__r.Vehicle_Type__c,Opportunity__r.Contact_number__c,Applicant_Type__c,Gender__c,Income_Ca__c,Marital_status__c,Opportunity__r.Geo_State_Master__r.State_Code__c,Residence_country__c,Profile__c,Contact_number__c, applicant_number__c, Opportunity__r.Agent_BL_code__c FROM Applicant__c WHERE Id=:applicantId WITH SECURITY_ENFORCED Limit 1];
			Documents__c doc;
			 List<Documents__c> docWithDate=[Select kyc_dob__c from documents__c where recordtype.name = 'KYC Document' and Applicant__c=:applicantId and Proof_of_Identity_POI__c=true AND Is_Active__c =true WITH SECURITY_ENFORCED limit 1];//CISP-3089
			 doc= new Documents__c();
			if(!docWithDate.isEmpty()){
                doc.KYC_DOB__c = docWithDate[0].kyc_dob__c;
            }
            else{
                throw new IND_Exception(System.Label.DateOfBirth);
            }   
            /**Commented by Rajasekar as part of CISP-23240 - Starts	
			List<Documents__c> docWithPin=[Select KYC_Pin_Code__c from documents__c where recordtype.name = 'KYC Document' and Applicant__c=:applicantId and Current_Residential_Address_Proof__c=true AND Is_Active__c =true WITH SECURITY_ENFORCED limit 1];//CISP-23348
			if(!docWithPin.isEmpty()){
			   doc.KYC_Pin_Code__c = docWithPin[0].KYC_Pin_Code__c;
			}
			else{
				throw new IND_Exception('Pincode is Missing');
			} //Commented by Rajasekar as part of CISP-23240 - Ends**/
			//Added by Rajasekar as part of CISP-23240 - Starts			
			for(Documents__c docWithPin:[SELECT Id,KYC_Pin_Code__c FROM documents__c WHERE Recordtype.name = 'KYC Document' AND Applicant__c=:applicantId AND Current_Residential_Address_Proof__c=true AND Is_Active__c =true WITH SECURITY_ENFORCED]){
				if(docWithPin.KYC_Pin_Code__c != null){
					doc.KYC_Pin_Code__c = docWithPin.KYC_Pin_Code__c;
				}
			}
			if(doc.KYC_Pin_Code__c == '' || doc.KYC_Pin_Code__c == null){
				throw new IND_Exception('Pincode is Missing');
			}
			//Added by Rajasekar as part of CISP-23240 - Ends
            IND_BREscoreCardRequest BREscoreCardRequestDetails = IND_BREscoreCardService.getBREscoreCardRequest(app,doc,loanAppId); 
            CalloutProcessor process = new CalloutProcessor(System.Label.BREscorecardAPI, BREscoreCardRequestDetails);
            HttpRequest request = process.createHttpRequest();  
            
            Long startTime = DateTime.now().getTime();
            
            Carrier carrier = new carrier();
            carrier.setServiceName(System.Label.BREscorecardAPI);
            carrier.setProcessor(process);
            carrier.setRequest(IntegrationUtilities.getPlainTextForLog(request.getBody()));
            carrier.setEncryptedRequest(request.getBody());
            carrier.setStartTime(startTime);
            carrier.setLoanApplicationId(loanAppId);
            //Add callout request to continuation
            con = new Continuation(timeout);        
            con.continuationMethod='processBREscoreCardAPIResponse';
            con.state=carrier;
            con.addHttpRequest(request);
            
            if(Test.isRunningTest()) {
               continuationLabel = con.addHttpRequest(request);
               continuationState = carrier; 
            }  
        } catch(Exception ex) {
            ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'doBREscoreCardCallout', System.Label.Apex, ex,loanAppId);
            throw ex;
        }
        return con;
    }
    
    /*
* @Method:      processBREscoreCardAPIResponse
* @Created by:  Bondiga Thilak 
* @Description: This method is being used to handle the response from continuation and return the response to calling processes
* @Param:       Collection - labels
* @Param:       Object - state
* @Return:      Object - response
*/
    @AuraEnabled(cacheable=true)
    public static Object processBREscoreCardAPIResponse(List<String> labels, Object state){
        IND_BREscoreCardResponse apiResponse;
        String request='';
        String encryptedRequest='';
        String serviceName='';
        String data;
        String loanAppId='';
        HttpResponse response;
        String elapseTime='';
        
        try{
            Carrier carrier = (Carrier)state;
            request = carrier.getRequest();
            encryptedRequest = carrier.getEncryptedRequest();
            serviceName = carrier.getServiceName();
            Long startTime = carrier.getStartTime();
            CalloutProcessor processor = carrier.getProcessor();
            response = Continuation.getResponse(labels[0]);
            Long endTime = DateTime.now().getTime();
            elapseTime = String.valueOf((Double)(endTime - startTime)/1000);
            loanAppId = carrier.getLoanApplicationId();
            
            if(response != null && response.getStatusCode() == 200){               
                apiResponse = (IND_BREscoreCardResponse)processor.getHttpResponse(response, serviceName);               
                
                if(apiResponse!=null){
                    IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, IntegrationUtilities.getPlainTextForLog(response.getBody()), response.getBody(), serviceName, elapseTime,loanAppId,System.Label.Success);
                    return JSON.serialize(apiResponse);
                } else {
                    IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, IntegrationUtilities.getPlainTextForLog(response.getBody()), response.getBody(), serviceName, elapseTime,loanAppId,System.Label.Failure);
                    throw new IND_Exception(System.Label.NoResponse);                
                }
            }
            else {
                String errString = '[Status Code = '+ response.getStatusCode() +' ] Response-->'+IntegrationUtilities.getPlainTextForLog(response.getBody());
                IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, errString, response.getBody(), serviceName, elapseTime, loanAppId, System.Label.Failure);
                ErrorLoggerUtil.logErrorEvent('CalloutProcessor', 'getHttpResponse', System.Label.Apex, new IND_Exception(errString), loanAppId);
                throw new IND_Exception(System.Label.NoResponse);
            } 
        } catch (Exception ex){
            IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, '', '', serviceName, elapseTime,loanAppId,System.Label.Failure);
            ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'processBREscoreCardAPIResponse', System.Label.Apex, ex,loanAppId);
            throw new IND_Exception(ex.getMessage());
        }
    }
    
    
    /*
* @Method:      doCustomerMasterCreationCallout
* @Created by:  Kranthi Makkena
* @Description: Method to return Response for CustomerMasterCreation API
* @Param:       String - Applicant Id
* @Return:      String - response
*/
    
    
@AuraEnabled(continuation=true cacheable=true)
public static Object doCustomerMasterCreationCallout(String applicantId, String loanAppId, String religion, String caste,String district){
    Continuation con;
    try{
        system.debug('::doCustomerMasterCreationCallout method is invoked.');
        //Provide API-wise Integration Name to Custom Metadata Configs
        Integration_Configuration__mdt apiConfiguration = IntegrationUtilities.getAPIConfiguration(System.Label.CustomerMasterCreation);
        Integer timeout = Integer.valueOf(apiConfiguration.Timeout__c);

        //if stubs checked in Integration_Configuration then stubs will return 
        if(apiConfiguration.IsStub_Required__c != null && apiConfiguration.IsStub_Required__c){  
            String stubData = IntegrationUtilities.getStubResponse(System.Label.CustomerMasterCreation);
            return stubData == null ? System.Label.EmptyStubs : stubData;  
        }
        Applicant__c app = [SELECT Id,Contact_number__c,OTP_for_borrower__c,Opportunity__r.Lead_number__c,applicant_number__c,Preferred_address_for_communication__c,
                            Customer_Code__c,Name,Gender__c,Profile__c,Communication_language__c,Opportunity__r.Product_Type__c,Opportunity__r.Customer_Type__c,Opportunity__r.Id,
                            Customer_Qualification__c,Father_s_name__c,Mother_s_name__c,Spouse_Name__c,Email_Id__c,Application_Consent_SMS_Sent_Time__c,
                            Aadhar_No__c,Voter_ID_No__c,Driving_License_No__c,Customer_Last_Name__c,Opportunity__r.CreatedById,Applicant_Type__c,Opportunity__r.Profile__c,
                            Opportunity__r.OwnerId,Legal_Entity_Identifier__c,Opportunity__r.Agent_BL_code__c,Is_Address_Declaration__c,
                            Marital_status__c,Opportunity__r.Contact_number__c,Whatsapp_number__c, Opportunity__r.Whatsapp_number__c, Opportunity__r.Is_Pre_Approved__c, Opportunity__r.LeadSource,opportunity__r.VKYC_Doc_Downloaded__c,opportunity__r.VKYC_Doc_Urls__c,opportunity__r.VKYC_status__c,Beneficiary_Office_Address_Line_1__c,Beneficiary_Office_Address_Line_2__c,Beneficiary_Office_City__c,Beneficiary_Office_State__c,Beneficiary_Office_Pincode__c,Beneficiary_Office_District__c,opportunity__r.Entity_Code__c,(SELECT Id,Customer_Code__c,CIN_No__c from Customer_Dedupe_Response__r)
                            FROM Applicant__c WHERE Id=:applicantId WITH SECURITY_ENFORCED];//CISP-3338 , added Product_Type__c in query
        
        loanApplicationRef= loanAppId;
        IND_CustomerMasterCreationRequest CustomerMasterCreationRequestDetails = IND_CustomerMasterCreationService.getCustomerMasterCreationRequest(app,loanAppId,religion,caste,district); 
        system.debug('::CustomerMasterCreationRequestDetails '+CustomerMasterCreationRequestDetails);
        CalloutProcessor process = new CalloutProcessor(System.Label.CustomerMasterCreation, CustomerMasterCreationRequestDetails);
        HttpRequest request = process.createHttpRequest();  
        
        Long startTime = DateTime.now().getTime();
        
        Carrier carrier = new carrier();
        carrier.setServiceName(System.Label.CustomerMasterCreation);
        carrier.setProcessor(process);
        carrier.setRequest(IntegrationUtilities.getPlainTextForLog(request.getBody()));
        carrier.setEncryptedRequest(request.getBody());
        carrier.setStartTime(startTime);
        carrier.setLoanApplicationId(loanAppId);
        //Add callout request to continuation
        con = new Continuation(timeout);        
        con.continuationMethod='processCustomerMasterCreationAPIResponse';
        con.state=carrier;
        con.addHttpRequest(request);
        
        if(Test.isRunningTest()) {
           continuationLabel = con.addHttpRequest(request);
           continuationState = carrier; 
        }  
    } catch(Exception ex) {
        ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'doCustomerMasterCreationCallout', System.Label.Apex, ex, loanAppId);
        throw ex;
    }
    system.debug('our con result'+con);
    return con;
}
    
    /*
* @Method:      processCustomerMasterCreationAPIResponse
* @Created by:  Kranthi makkena 
* @Description: This method is being used to handle the response from continuation and return the response to calling processes
* @Param:       Collection - labels
* @Param:       Object - state
* @Return:      Object - response
*/
    @AuraEnabled(cacheable=true)
    public static Object processCustomerMasterCreationAPIResponse(List<String> labels, Object state){
        System.debug('::Inside the Customer Master Creation callback');
        IND_CustomerMasterCreationResponse apiResponse;
        String request='';
        String encryptedRequest='';
        String serviceName='';
        String data;
        String loanAppId='';
        HttpResponse response;
        String elapseTime='';
        
        try{
            Carrier carrier = (Carrier)state;
            request = carrier.getRequest();
            system.debug('***request'+request);
            encryptedRequest = carrier.getEncryptedRequest();
            system.debug('***encryptedRequest'+encryptedRequest);
            serviceName = carrier.getServiceName();
            Long startTime = carrier.getStartTime();
            
            CalloutProcessor processor = carrier.getProcessor();
            response = Continuation.getResponse(labels[0]);
            Long endTime = DateTime.now().getTime();
            elapseTime = String.valueOf((Double)(endTime - startTime)/1000);
            loanAppId = carrier.getLoanApplicationId();
            if(response != null && response.getStatusCode() == 200) {
                system.debug('::Inside the response method');
                apiResponse = (IND_CustomerMasterCreationResponse)processor.getHttpResponse(response, serviceName);
                if(apiResponse != null){
                    data = JSON.serialize(apiResponse);
                    system.debug('data::'+data);
                    IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, IntegrationUtilities.getPlainTextForLog(response.getBody()), response.getBody(), serviceName, elapseTime,loanAppId,System.Label.Success);
                } else {
                    IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, IntegrationUtilities.getPlainTextForLog(response.getBody()), response.getBody(), serviceName, elapseTime,loanAppId,System.Label.Failure);
                    throw new IND_Exception(System.Label.NoResponse); 
                }
                
            } else {
                String errString = '[Status Code = ' + response.getStatusCode() + ' ] Response-->' + IntegrationUtilities.getPlainTextForLog(response.getBody());
                IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, errString, response.getBody(), serviceName, elapseTime, loanAppId, System.Label.Failure);
                ErrorLoggerUtil.logErrorEvent('CalloutProcessor', 'getHttpResponse', System.Label.Apex, new IND_Exception(errString), loanAppId);
                String errorMessage;
                try {
                if (response.getBody() != null) {
                    Map<String, Object> parsedJson = (Map<String, Object>) JSON.deserializeUntyped(IntegrationUtilities.getPlainTextForLog(response.getBody()));
                    if (parsedJson.containsKey('response')) {
                        Map<String, Object> responseMap = (Map<String, Object>) parsedJson.get('response');
                        if (responseMap != null && responseMap.containsKey('respDesc')) {
                            String respDesc = (String) responseMap.get('respDesc');
                            Map<String, Object> respDescMap = (Map<String, Object>) JSON.deserializeUntyped(respDesc);
                            if (respDescMap != null && respDescMap.containsKey('FIBusinessException')) {
                                List<Object> businessExceptions = (List<Object>) respDescMap.get('FIBusinessException');                   
                                List<String> errorDescs = new List<String>();
                                for (Object exceptionObj : businessExceptions) {
                                    Map<String, Object> exceptionMap = (Map<String, Object>) exceptionObj;
                                    String errorDesc = (String) exceptionMap.get('ErrorDesc');
                                    if (errorDesc != null) {
                                        errorDescs.add(errorDesc);
                                    }
                                }
                                errorMessage = ' Error Descriptions: ' + String.join(errorDescs, ', ');
                            } else {
                                errorMessage = ' No Response found';
                            }
                        } else {
                            errorMessage = ' Invalid response format';
                        }
                    } else {
                        errorMessage = ' Invalid response format';
                    }
                } else {
                    errorMessage = ' No Response found';
                }
            } catch (Exception e) {
                    errorMessage = 'Failed to parse error details: ' + e.getMessage();
                }
                throw new IND_Exception(errorMessage);
            }
        } catch (Exception ex){
            System.debug('callback()====catch');
            IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, '', response.getBody(), serviceName, elapseTime,loanAppId,System.Label.Failure);
            ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'processCustomerMasterCreationAPIResponse', System.Label.Apex, ex,loanAppId);
            throw new IND_Exception(ex.getMessage());
        }
        return data;
    }
    
    /*
* @Method:      doCustomerMasterUpdationCallout
* @Created by:  Rohan Saxena
* @Description: Method to do callout CustomerMasterUpdation API to update customer code
* @Param:       String - Applicant Id
* @Return:      String - response
*/
    
    
@AuraEnabled(continuation=true cacheable=true)
public static Object doCustomerMasterUpdationCallout(String applicantId, String loanAppId, String religion, String caste,String district){
    Continuation con;
    try{
        //Provide API-wise Integration Name to Custom Metadata Configs
        Integration_Configuration__mdt apiConfiguration = IntegrationUtilities.getAPIConfiguration(System.Label.CustomerMasterUpdation);
        Integer timeout = Integer.valueOf(apiConfiguration.Timeout__c);

        //if stubs checked in Integration_Configuration then stubs will return 
        if(apiConfiguration.IsStub_Required__c != null && apiConfiguration.IsStub_Required__c){  
            String stubData = IntegrationUtilities.getStubResponse(System.Label.CustomerMasterUpdation);
            return stubData == null ? System.Label.EmptyStubs : stubData;  
        }
        Applicant__c app = [SELECT Id,Contact_number__c,OTP_for_borrower__c,Opportunity__r.Lead_number__c,applicant_number__c,Preferred_address_for_communication__c,
                            Customer_Code__c,Name,Gender__c,Profile__c,Communication_language__c,Opportunity__r.Product_Type__c,Opportunity__r.Customer_Type__c,Opportunity__r.Id,
                            Customer_Qualification__c,Father_s_name__c,Mother_s_name__c,Spouse_Name__c,Email_Id__c,Application_Consent_SMS_Sent_Time__c,
                            Aadhar_No__c,Voter_ID_No__c,Driving_License_No__c,Customer_Last_Name__c,Opportunity__r.CreatedById,Applicant_Type__c,
                            Opportunity__r.OwnerId,Legal_Entity_Identifier__c,Opportunity__r.Agent_BL_code__c,Is_Address_Declaration__c,Opportunity__r.Profile__c,
                            Marital_status__c,Opportunity__r.Contact_number__c,Whatsapp_number__c, Opportunity__r.Whatsapp_number__c, Opportunity__r.Is_Pre_Approved__c, Opportunity__r.LeadSource,opportunity__r.VKYC_Doc_Downloaded__c,opportunity__r.VKYC_Doc_Urls__c,opportunity__r.VKYC_status__c,Beneficiary_Office_Address_Line_1__c,Beneficiary_Office_Address_Line_2__c,Beneficiary_Office_City__c,Beneficiary_Office_State__c,Beneficiary_Office_Pincode__c,Beneficiary_Office_District__c,Opportunity__r.Entity_Code__c,(SELECT Id,Customer_Code__c,CIN_No__c from Customer_Dedupe_Response__r)
                            FROM Applicant__c WHERE Id=:applicantId WITH SECURITY_ENFORCED];//CISP-3338 , added Product_Type__c in query
        
        loanApplicationRef= loanAppId;
        if(app.Customer_Code__c != null) { //CISP-3799
        IND_CustomerMasterCreationRequest CustomerMasterCreationRequestDetails = IND_CustomerMasterCreationService.getCustomerMasterCreationRequest(app,loanAppId,religion,caste,district); 
        CalloutProcessor process = new CalloutProcessor(System.Label.CustomerMasterUpdation, CustomerMasterCreationRequestDetails);
        HttpRequest request = process.createHttpRequest();  
        
        Long startTime = DateTime.now().getTime();
        
        Carrier carrier = new carrier();
        carrier.setServiceName(System.Label.CustomerMasterUpdation);
        carrier.setProcessor(process);
        carrier.setRequest(IntegrationUtilities.getPlainTextForLog(request.getBody()));
        carrier.setEncryptedRequest(request.getBody());
        carrier.setStartTime(startTime);
        carrier.setLoanApplicationId(loanAppId);
        //Add callout request to continuation
        con = new Continuation(timeout);        
        con.continuationMethod='processCustomerMasterUpdationAPIResponse';
        con.state=carrier;
        con.addHttpRequest(request);
        
        if(Test.isRunningTest()) {
           continuationLabel = con.addHttpRequest(request);
           continuationState = carrier; 
        }  
    } //CISP-3799
    } catch(Exception ex) {
        ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'doCustomerMasterUpdationCallout', System.Label.Apex, ex, loanAppId);
        throw ex;
    }
    system.debug('our con result'+con);
    return con;
}
    
    /*
* @Method:      processCustomerMasterUpdationAPIResponse
* @Created by:  Rohan Saxena
* @Description: This method is being used to handle the response from continuation and return the response to calling processes
* @Param:       Collection - labels
* @Param:       Object - state
* @Return:      Object - response
*/
    @AuraEnabled(cacheable=true)
    public static Object processCustomerMasterUpdationAPIResponse(List<String> labels, Object state){
        System.debug('::Inside the Customer Master Updation callback');
        IND_CustomerMasterCreationResponse apiResponse;
        String request='';
        String encryptedRequest='';
        String serviceName='';
        String data;
        String loanAppId='';
        HttpResponse response;
        String elapseTime='';
        
        try{
            Carrier carrier = (Carrier)state;
            request = carrier.getRequest();
            system.debug('***request'+request);
            encryptedRequest = carrier.getEncryptedRequest();
            system.debug('***encryptedRequest'+encryptedRequest);
            serviceName = carrier.getServiceName();
            Long startTime = carrier.getStartTime();
            
            CalloutProcessor processor = carrier.getProcessor();
            response = Continuation.getResponse(labels[0]);
            Long endTime = DateTime.now().getTime();
            elapseTime = String.valueOf((Double)(endTime - startTime)/1000);
            loanAppId = carrier.getLoanApplicationId();
            if(response != null && response.getStatusCode() == 200) {
                system.debug('::Inside the response method');
                apiResponse = (IND_CustomerMasterCreationResponse)processor.getHttpResponse(response, serviceName);
                if(apiResponse != null){
                    data = JSON.serialize(apiResponse);
                    system.debug('data::'+data);
                    IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, IntegrationUtilities.getPlainTextForLog(response.getBody()), response.getBody(), serviceName, elapseTime,loanAppId,System.Label.Success);
                } else {
                    IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, IntegrationUtilities.getPlainTextForLog(response.getBody()), response.getBody(), serviceName, elapseTime,loanAppId,System.Label.Failure);
                    throw new IND_Exception(System.Label.NoResponse); 
                }
                
            } else {
                String errString = '[Status Code = '+ response.getStatusCode() +' ] Response-->'+IntegrationUtilities.getPlainTextForLog(response.getBody());
                IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, errString, response.getBody(), serviceName, elapseTime, loanAppId, System.Label.Failure);
                ErrorLoggerUtil.logErrorEvent('CalloutProcessor', 'getHttpResponse', System.Label.Apex, new IND_Exception(errString), loanAppId);
                throw new IND_Exception(System.Label.NoResponse);
            } 
            
        } catch (Exception ex){
            System.debug('callback()====catch');
            IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, '', response.getBody(), serviceName, elapseTime,loanAppId,System.Label.Failure);
            ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'processCustomerMasterCreationAPIResponse', System.Label.Apex, ex,loanAppId);
            throw new IND_Exception(ex.getMessage());
        }
        return data;
    }

   /*
* @Method:      doStampingDetailsCallout
* @Created by:  Bondiga Thilak 
* @Description: This method is being used to call the  Stamping Details API using continuation
* @Param:       String - applicantId
* @Return:      ''
*/
    @AuraEnabled(continuation=true cacheable=true)
    public static Object doStampingDetailsCallout(String applicantId,String loanAppId,String geoStateCode, String dealId){
        Continuation con;
        try{
            system.debug('::doStampingDetailsCallout method is invoked.');
            //Provide API-wise Integration Name to Custom Metadata Configs
            Integration_Configuration__mdt apiConfiguration = IntegrationUtilities.getAPIConfiguration(System.Label.StampingDetails);
            Integer timeout = Integer.valueOf(apiConfiguration.Timeout__c);
            if(apiConfiguration.IsStub_Required__c != null && apiConfiguration.IsStub_Required__c){  
                // Get stub details here to return response to LWC method.
                String stubData = IntegrationUtilities.getStubResponse(System.Label.StampingDetails);
                return stubData == null ? System.Label.EmptyStubs : stubData;  
            }
            Opportunity opp = [SELECT Id,Deal_Number__c,Product_Type__c,Lead_number__c,Finance_Amount__c FROM Opportunity WHERE Id=:loanAppId WITH SECURITY_ENFORCED];
             loanApplicationRef= loanAppId;
             
            IND_StampingDetailsRequest StampingDetailsRequestDetails = IND_StampingDetailsService.getStampingDetailsRequest(null,opp,geoStateCode, dealId); 
            system.debug('::StampingDetailsRequestDetails '+StampingDetailsRequestDetails);
            CalloutProcessor process = new CalloutProcessor(System.Label.StampingDetails, StampingDetailsRequestDetails);
            HttpRequest request = process.createHttpRequest();  
            
            Long startTime = DateTime.now().getTime();
            
            Carrier carrier = new carrier();
            carrier.setServiceName(System.Label.StampingDetails);
            carrier.setProcessor(process);
            carrier.setRequest(IntegrationUtilities.getPlainTextForLog(request.getBody()));
            carrier.setEncryptedRequest(request.getBody());
            carrier.setStartTime(startTime);
            carrier.setLoanApplicationId(loanAppId);
            //Add callout request to continuation
            con = new Continuation(timeout);        
            con.continuationMethod='processStampingDetailsAPIResponse';
            con.state=carrier;
            con.addHttpRequest(request);
            
            if(Test.isRunningTest()) {
               continuationLabel = con.addHttpRequest(request);
               continuationState = carrier; 
            }  
        } catch(Exception ex) {
            ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'doStampingDetailsCallout', System.Label.Apex, ex,loanAppId);
            throw ex;
        }
        return con;
    }
    
    /*
* @Method:      processStampingDetailsAPIResponse
* @Created by:  Bondiga Thilak 
* @Description: This method is being used to handle the response from continuation and return the response to calling processes
* @Param:       Collection - labels
* @Param:       Object - state
* @Return:      Object - response
*/
    @AuraEnabled(cacheable=true)
    public static Object processStampingDetailsAPIResponse(List<String> labels, Object state){
        System.debug('::Inside the Stamping Details callback');
        IND_StampingDetailsResponse apiResponse;
        String request='';
        String encryptedRequest='';
        String serviceName='';
        String loanAppId = '';
        String data;
        HttpResponse response;
        String elapseTime='';
        
        try{
            Carrier carrier = (Carrier)state;
            request = carrier.getRequest();
            encryptedRequest = carrier.getEncryptedRequest();
            serviceName = carrier.getServiceName();
            Long startTime = carrier.getStartTime();
            
            CalloutProcessor processor = carrier.getProcessor();
            response = Continuation.getResponse(labels[0]);
            Long endTime = DateTime.now().getTime();
            elapseTime = String.valueOf((Double)(endTime - startTime)/1000);
            loanAppId = carrier.getLoanApplicationId();
            if(response != null && response.getStatusCode() == 200) {
                system.debug('::Inside the response method');
                apiResponse = (IND_StampingDetailsResponse)processor.getHttpResponse(response, serviceName);
                if(apiResponse != null){
                    data = JSON.serialize(apiResponse);
                    system.debug('data::'+data);
                    IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, IntegrationUtilities.getPlainTextForLog(response.getBody()), response.getBody(), serviceName, elapseTime,loanAppId, System.Label.Success);
                } else {
                    IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, '', '', serviceName, elapseTime,loanAppId,System.Label.Failure);
                    throw new IND_Exception(System.Label.NoResponse);
                }
                
            } else {
                String errString = '[Status Code = '+ response.getStatusCode() +' ] Response-->'+IntegrationUtilities.getPlainTextForLog(response.getBody());
                IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, errString, response.getBody(), serviceName, elapseTime, loanAppId, System.Label.Failure);
                ErrorLoggerUtil.logErrorEvent('CalloutProcessor', 'getHttpResponse', System.Label.Apex, new IND_Exception(errString), loanAppId);
                throw new IND_Exception(System.Label.NoResponse);
            } 
            
        } catch (Exception ex){
            System.debug('callback()====catch');
            IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, '', '', serviceName, elapseTime,loanAppId,System.Label.Failure);
            ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'processStampingDetailsAPIResponse', System.Label.Apex, ex,loanAppId);
            throw new IND_Exception(ex.getMessage());
        }
        return data;
    }
    
    /*
* @Method:      doNeSLAgreementStatusCallout
* @Created by:  Bondiga Thilak 
* @Description: This method is being used to call the NeSL Agreement Status API using continuation
* @Param:       String - applicantId,loanAppId
* @Return:      ''
*/
    @AuraEnabled(continuation=true cacheable=true)
    public static Object doNeSLAgreementStatusCallout(String applicantId,String loanAppId){
        Continuation con;
        try{
            system.debug('::doNeSLAgreementStatusCallout method is invoked.');
            //Provide API-wise Integration Name to Custom Metadata Configs
            Integration_Configuration__mdt apiConfiguration = IntegrationUtilities.getAPIConfiguration(System.Label.NeSLAgreementStatus);
            Integer timeout = Integer.valueOf(apiConfiguration.Timeout__c);
            if(apiConfiguration.IsStub_Required__c != null && apiConfiguration.IsStub_Required__c){  
                // Get stub details here to return response to LWC method.
                String stubData = IntegrationUtilities.getStubResponse(System.Label.NeSLAgreementStatus);
                return stubData == null ? System.Label.EmptyStubs : stubData;  
            }
            Applicant__c app = [SELECT Id,Opportunity__r.Parent_Deal_number__c,Opportunity__r.Deal_number__c FROM Applicant__c WHERE Id=:applicantId WITH SECURITY_ENFORCED];
            
            loanApplicationRef= loanAppId;
            IND_NeSLAgreementStatusRequest neSLAgreementStatusRequestDetails = IND_NeSLAgreementStatusService.getNeSLAgreementStatusRequest(app,loanAppId); 
            system.debug('::neSLAgreementStatusRequestDetails '+neSLAgreementStatusRequestDetails);
            CalloutProcessor process = new CalloutProcessor(System.Label.NeSLAgreementStatus, neSLAgreementStatusRequestDetails);
            HttpRequest request = process.createHttpRequest();  
            
            Long startTime = DateTime.now().getTime();
            
            Carrier carrier = new carrier();
            carrier.setServiceName(System.Label.NeSLAgreementStatus);
            carrier.setProcessor(process);
            carrier.setRequest(IntegrationUtilities.getPlainTextForLog(request.getBody()));
            carrier.setEncryptedRequest(request.getBody());
            carrier.setStartTime(startTime);
            carrier.setLoanApplicationId(loanAppId);
            //Add callout request to continuation
            con = new Continuation(timeout);        
            con.continuationMethod='processNeSLAgreementStatusAPIResponse';
            con.state=carrier;
            con.addHttpRequest(request);
            
            if(Test.isRunningTest()) {
               continuationLabel = con.addHttpRequest(request);
               continuationState = carrier; 
            }  
        } catch(Exception ex) {
            ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'doNeSLAgreementStatusCallout', System.Label.Apex, ex,loanAppId);
            throw ex;
        }
        return con;
    }
    
    /*
* @Method:      processNeSLAgreementStatusAPIResponse
* @Created by:  Bondiga Thilak 
* @Description: This method is being used to handle the response from continuation and return the response to calling processes
* @Param:       Collection - labels
* @Param:       Object - state
* @Return:      Object - response
*/
    @AuraEnabled(cacheable=true)
    public static Object processNeSLAgreementStatusAPIResponse(List<String> labels, Object state){
        System.debug('::Inside the NeSL Agreement Status callback');
        IND_NeSLAgreementStatusResponse apiResponse;
        String request='';
        String encryptedRequest='';
        String loanAppId='';
        String serviceName='';
        String data;
        HttpResponse response;
        String elapseTime='';
        
        try{
            Carrier carrier = (Carrier)state;
            request = carrier.getRequest();
            encryptedRequest = carrier.getEncryptedRequest();
            serviceName = carrier.getServiceName();
            Long startTime = carrier.getStartTime();
            
            CalloutProcessor processor = carrier.getProcessor();
            response = Continuation.getResponse(labels[0]);
            Long endTime = DateTime.now().getTime();
            elapseTime = String.valueOf((Double)(endTime - startTime)/1000);
            loanAppId = carrier.getLoanApplicationId();
            if(response != null && response.getStatusCode() == 200) {
                system.debug('::Inside the response method');
                apiResponse = (IND_NeSLAgreementStatusResponse)processor.getHttpResponse(response, serviceName);
                if(apiResponse != null){
                    data = JSON.serialize(apiResponse);
                    system.debug('data::'+data);
                    IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, IntegrationUtilities.getPlainTextForLog(response.getBody()), response.getBody(), serviceName, elapseTime,loanAppId, System.Label.Success);
                } else {
                    throw new IND_Exception(System.Label.NoResponse);
                }
                
            } else {
                throw new IND_Exception(System.Label.NoResponse);
            } 
            
        } catch (Exception ex){
            System.debug('callback()====catch');
            IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, '', '', serviceName, elapseTime,loanAppId,System.Label.Failure);
            ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'processNeSLAgreementStatusAPIResponse', System.Label.Apex, ex,loanAppId);
            throw new AuraHandledException(ex.getMessage());
        }
        return data;
    }
    
    
    /*
* @Method:      doNeSLEAgreementCallout
* @Created by:  Bondiga Thilak 
* @Description: This method is being used to call the NeSL EAgreement API using continuation
* @Param:       String - applicantId,loanAppId
* @Return:      ''
*/
    @AuraEnabled(continuation=true cacheable=true)
    public static Object doNeSLEAgreementCallout(String applicantId,String loanAppId){
        Continuation con;
        try{
            system.debug('::doNeSLEAgreementCallout method is invoked.');
            //Provide API-wise Integration Name to Custom Metadata Configs
            Integration_Configuration__mdt apiConfiguration = IntegrationUtilities.getAPIConfiguration(System.Label.NeSLEAgreement);
            Integer timeout = Integer.valueOf(apiConfiguration.Timeout__c);
            if(apiConfiguration.IsStub_Required__c != null && apiConfiguration.IsStub_Required__c){  
                // Get stub details here to return response to LWC method.
                String stubData = IntegrationUtilities.getStubResponse(System.Label.NeSLEAgreement);
                return stubData == null ? System.Label.EmptyStubs : stubData;
            }
            Applicant__c app = [SELECT Id,Opportunity__r.Parent_Deal_number__c FROM Applicant__c WHERE Id=:applicantId WITH SECURITY_ENFORCED];
            
            loanApplicationRef= loanAppId;            
            IND_NeSLEAgreementRequest NeSLEAgreementRequestDetails = IND_NeSLEAgreementService.getNeSLEAgreementRequest(app,loanAppId); 
            system.debug('::NeSLEAgreementRequestDetails '+NeSLEAgreementRequestDetails);
            CalloutProcessor process = new CalloutProcessor(System.Label.NeSLEAgreement, NeSLEAgreementRequestDetails);
            HttpRequest request = process.createHttpRequest();  
            
            Long startTime = DateTime.now().getTime();
            
            Carrier carrier = new carrier();
            carrier.setServiceName(System.Label.NeSLEAgreement);
            carrier.setProcessor(process);
            carrier.setRequest(IntegrationUtilities.getPlainTextForLog(request.getBody()));
            carrier.setEncryptedRequest(request.getBody());
            carrier.setStartTime(startTime);
            carrier.setLoanApplicationId(loanAppId);
            //Add callout request to continuation
            con = new Continuation(timeout);        
            con.continuationMethod='processNeSLEAgreementAPIResponse';
            con.state=carrier;
            con.addHttpRequest(request);
            
            if(Test.isRunningTest()) {
               continuationLabel = con.addHttpRequest(request);
               continuationState = carrier; 
            }  
        } catch(Exception ex) {
            ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'doNeSLEAgreementCallout', System.Label.Apex, ex,loanAppId);
            throw ex;
        }
        return con;
    }
    
    /*
* @Method:      processNeSLEAgreementAPIResponse
* @Created by:  Bondiga Thilak 
* @Description: This method is being used to handle the response from continuation and return the response to calling processes
* @Param:       Collection - labels
* @Param:       Object - state
* @Return:      Object - response
*/
    @AuraEnabled(cacheable=true)
    public static Object processNeSLEAgreementAPIResponse(List<String> labels, Object state){
        System.debug('::Inside the NeSL EAgreement callback');
        IND_NeSLEAgreementResponse apiResponse;
        String request='';
        String encryptedRequest='';
        String serviceName='';
        String loanAppId = '';
        String data;
        HttpResponse response;
        String elapseTime='';
        
        try{
            Carrier carrier = (Carrier)state;
            request = carrier.getRequest();
            encryptedRequest = carrier.getEncryptedRequest();
            serviceName = carrier.getServiceName();
            Long startTime = carrier.getStartTime();
            
            CalloutProcessor processor = carrier.getProcessor();
            response = Continuation.getResponse(labels[0]);
            Long endTime = DateTime.now().getTime();
            elapseTime = String.valueOf((Double)(endTime - startTime)/1000);
            loanAppId = carrier.getLoanApplicationId();
            if(response != null && response.getStatusCode() == 200) {
                system.debug('::Inside the response method');
                apiResponse = (IND_NeSLEAgreementResponse)processor.getHttpResponse(response, serviceName);
                if(apiResponse != null){
                    data = JSON.serialize(apiResponse);
                    system.debug('data::'+data);
                    IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, IntegrationUtilities.getPlainTextForLog(response.getBody()), response.getBody(), serviceName, elapseTime,loanAppId, System.Label.Success);
                } else {
                    IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, '', '', serviceName, elapseTime,loanAppId, System.Label.Failure);
                throw new IND_Exception(System.Label.NoResponse);
                }
                
            } else {
                String errString = '[Status Code = '+ response.getStatusCode() +' ] Response-->'+IntegrationUtilities.getPlainTextForLog(response.getBody());
                IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, errString, response.getBody(), serviceName, elapseTime, loanAppId, System.Label.Failure);
                ErrorLoggerUtil.logErrorEvent('CalloutProcessor', 'getHttpResponse', System.Label.Apex, new IND_Exception(errString), loanAppId);
                throw new IND_Exception(System.Label.NoResponse);
            } 
            
        } catch (Exception ex){
            System.debug('callback()====catch');
            IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, '', '', serviceName, elapseTime,loanAppId, System.Label.Failure);
            ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'processNeSLEAgreementAPIResponse', System.Label.Apex, ex,loanAppId);
            throw new AuraHandledException(ex.getMessage());
        }
        return data;
    }
    
  /*
* @Method:      doAgreementBookletCallout
* @Created by:  Bondiga Thilak 
* @Description: This method is being used to call the Agreement Booklet API using continuation
* @Param:       String - applicantId,loanAppId
* @Return:      ''
*/
    @AuraEnabled(continuation=true cacheable=true)
    public static Object doAgreementBookletCallout(String agreementBookletNo, String applicantId,String loanAppId,String dealId){
        Continuation con;
        try{
        
            system.debug('::doAgreementBookletCallout method is invoked.');
            //Provide API-wise Integration Name to Custom Metadata Configs
            Integration_Configuration__mdt apiConfiguration = IntegrationUtilities.getAPIConfiguration(System.Label.AgreementBooklet);
            Integer timeout = Integer.valueOf(apiConfiguration.Timeout__c);
            if(apiConfiguration.IsStub_Required__c != null && apiConfiguration.IsStub_Required__c){  
                // Get stub details here to return response to LWC method.
                String stubData = IntegrationUtilities.getStubResponse(System.Label.AgreementBooklet);
                return stubData == null ? System.Label.EmptyStubs : stubData;  
            }
            Applicant__c app = [SELECT Id, Opportunity__r.Deal_Number__c, Opportunity__r.Lead_number__c, Opportunity__r.Product_Type__c, Opportunity__r.Agent_BL_code__c 
                    FROM Applicant__c WHERE Id=:applicantId WITH SECURITY_ENFORCED];
            
             loanApplicationRef= loanAppId;
            IND_AgreementBookletRequest AgreementBookletRequestDetails = IND_AgreementBookletService.getAgreementBookletRequest(agreementBookletNo, app,loanAppId,dealId); 
            system.debug('::AgreementBookletRequestDetails '+AgreementBookletRequestDetails);
            CalloutProcessor process = new CalloutProcessor(System.Label.AgreementBooklet, AgreementBookletRequestDetails);
            HttpRequest request = process.createHttpRequest();  
            
            system.debug('== Agreement Booklet Request Body '+ IntegrationUtilities.getPlainTextForLog(request.getBody()) );
            
            Long startTime = DateTime.now().getTime();
            
            Carrier carrier = new carrier();
            carrier.setServiceName(System.Label.AgreementBooklet);
            carrier.setProcessor(process);
            carrier.setRequest(IntegrationUtilities.getPlainTextForLog(request.getBody()));
            carrier.setEncryptedRequest(request.getBody());
            carrier.setStartTime(startTime);
            carrier.setLoanApplicationId(loanAppId);
            //Add callout request to continuation
            con = new Continuation(timeout);        
            con.continuationMethod='processAgreementBookletAPIResponse';
            con.state=carrier;
            con.addHttpRequest(request);
            
            if(Test.isRunningTest()) {
               continuationLabel = con.addHttpRequest(request);
               continuationState = carrier; 
            }
        } catch(Exception ex) {
            ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'doAgreementBookletCallout', System.Label.Apex, ex,loanAppId);
            throw ex;
        }
        return con;
    }
    
    /*
* @Method:      processAgreementBookletAPIResponse
* @Created by:  Bondiga Thilak 
* @Description: This method is being used to handle the response from continuation and return the response to calling processes
* @Param:       Collection - labels
* @Param:       Object - state
* @Return:      Object - response
*/
    @AuraEnabled(cacheable=true)
    public static Object processAgreementBookletAPIResponse(List<String> labels, Object state){
        System.debug('::Inside the Agreement Booklet callback');
        IND_AgreementBookletResponse apiResponse;
        String request='';
        String encryptedRequest='';
        String serviceName='';
        String data;
        String loanAppId = '';
        HttpResponse response;
        String elapseTime='';
        
        try{
            Carrier carrier = (Carrier)state;
            request = carrier.getRequest();
            encryptedRequest = carrier.getEncryptedRequest();
            serviceName = carrier.getServiceName();
            Long startTime = carrier.getStartTime();
            
            CalloutProcessor processor = carrier.getProcessor();
            response = Continuation.getResponse(labels[0]);
            Long endTime = DateTime.now().getTime();
            elapseTime = String.valueOf((Double)(endTime - startTime)/1000);
             loanAppId = carrier.getLoanApplicationId();
            if(response != null && response.getStatusCode() == 200) {
                system.debug('::Inside the response method');
                apiResponse = (IND_AgreementBookletResponse)processor.getHttpResponse(response, serviceName);
                if(apiResponse != null){
                    data = JSON.serialize(apiResponse);
                    system.debug('== data::'+data);
                    IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, IntegrationUtilities.getPlainTextForLog(response.getBody()), response.getBody(), serviceName, elapseTime,loanAppId,System.Label.Success);
                } else {
                    IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, '', '', serviceName, elapseTime,loanAppId,System.Label.Failure);
                    throw new IND_Exception(System.Label.NoResponse);
                }
                
            } else {
                String errString = '[Status Code = '+ response.getStatusCode() +' ] Response-->'+IntegrationUtilities.getPlainTextForLog(response.getBody());
                IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, errString, response.getBody(), serviceName, elapseTime, loanAppId, System.Label.Failure);
                ErrorLoggerUtil.logErrorEvent('CalloutProcessor', 'getHttpResponse', System.Label.Apex, new IND_Exception(errString), loanAppId);
                throw new IND_Exception(System.Label.NoResponse);
            } 
            
        } catch (Exception ex){
            System.debug('callback()====catch');
            IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, '', '', serviceName, elapseTime,loanAppId,System.Label.Failure);
            ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'processAgreementBookletAPIResponse', System.Label.Apex, ex,loanAppId);
            throw new IND_Exception(ex.getMessage());
        }
        return data;
    }
    
    
    /*
* @Method:      doInitiateNESLCallout
* @Created by:  Yugandhar
* @Description: This method is being used to call the Initiate NESL EAgreement API using continuation
* @Param:       String - applicantId,loanAppId
* @Return:      ''
*/
    @AuraEnabled(continuation=true cacheable=true)
    public static Object doInitiateNESLCallout(String applicantId,String loanAppId,String initiationMethod, String dealId){
        Continuation con;
        try{
            system.debug('::doInitiateNESLCallout method is invoked.');
            //Provide API-wise Integration Name to Custom Metadata Configs
            Integration_Configuration__mdt apiConfiguration = IntegrationUtilities.getAPIConfiguration(System.Label.InitiateNeSL);
            Integer timeout = Integer.valueOf(apiConfiguration.Timeout__c);
            
            Applicant__c app = [SELECT Id,Contact_number__c,Name,OTP_for_borrower__c,Opportunity__r.Lead_number__c FROM Applicant__c WHERE Id=:applicantId WITH SECURITY_ENFORCED];
            IND_InitiateNeSLEAgreementRequest initiateNeSLRequest = IND_InitiateNeSLEAgreementService.getInitiateNeSLEAgreementRequest(app,loanAppId,initiationMethod,dealId);
            system.debug('::initiateNeSLRequest '+initiateNeSLRequest);
            CalloutProcessor process = new CalloutProcessor(System.Label.initiateNeSL, initiateNeSLRequest);
            HttpRequest request = process.createHttpRequest();  
            
            Long startTime = DateTime.now().getTime();
            
            Carrier carrier = new carrier();
            carrier.setServiceName(System.Label.InitiateNeSL);
            carrier.setProcessor(process);
            carrier.setRequest(IntegrationUtilities.getPlainTextForLog(request.getBody()));
            carrier.setEncryptedRequest(request.getBody());
            carrier.setStartTime(startTime);
            carrier.setLoanApplicationId(loanAppId);
            //Add callout request to continuation
            con = new Continuation(timeout);        
            con.continuationMethod='processInitiateNESLCalloutAPIResponse';
            con.state=carrier;
            con.addHttpRequest(request);
            
            if(Test.isRunningTest()) {
               continuationLabel = con.addHttpRequest(request);
               continuationState = carrier; 
            }  
        } catch(Exception ex) {
            ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'doInitiateNESLCallout', System.Label.Apex, ex,loanAppId);
            throw ex;
        }
        return con;
    }
    
        /*
* @Method:      processInitiateNESLCalloutAPIResponse
* @Created by:  Yugandhar
* @Description: This method is being used to handle the response from continuation and return the response to calling processes
* @Param:       Collection - labels
* @Param:       Object - state
* @Return:      Object - response
*/
    @AuraEnabled(cacheable=true)
    public static Object processInitiateNESLCalloutAPIResponse(List<String> labels, Object state){
        System.debug('::Inside the InitiateNeSL callback');
        IND_InitiateNeSLEAgreementResponse apiResponse;
        String request='';
        String encryptedRequest='';
        String serviceName='';
        String data;
         String loanAppId='';
        HttpResponse response;
        String elapseTime='';
        
        try{
            Carrier carrier = (Carrier)state;
            request = carrier.getRequest();
            encryptedRequest = carrier.getEncryptedRequest();
            serviceName = carrier.getServiceName();
            Long startTime = carrier.getStartTime();
            
            CalloutProcessor processor = carrier.getProcessor();
            response = Continuation.getResponse(labels[0]);
            Long endTime = DateTime.now().getTime();
            elapseTime = String.valueOf((Double)(endTime - startTime)/1000);
            loanAppId = carrier.getLoanApplicationId();
            System.debug('response.getStatusCode() --> ' + response.getStatusCode());
            System.debug('response --> ' + response);
            if(response != null && response.getStatusCode() == 200) {
                system.debug('::Inside the response method');
                apiResponse = (IND_InitiateNeSLEAgreementResponse)processor.getHttpResponse(response, serviceName);
                if(apiResponse != null){
                    data = JSON.serialize(apiResponse);
                    system.debug('data::'+data);
                    IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, IntegrationUtilities.getPlainTextForLog(response.getBody()), response.getBody(), serviceName, elapseTime, loanAppId, System.Label.Success);
                } else {
                    throw new IND_Exception(System.Label.NoResponse); 
                }
                
            } else {
                throw new IND_Exception(System.Label.NoResponse);
            }
            
        } catch (Exception ex){
            System.debug('callback()====catch');
            IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, IntegrationUtilities.getPlainTextForLog(response.getBody()), '', serviceName, elapseTime,loanAppId,System.Label.Failure);
            ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'processInitiateNESLCalloutAPIResponse', System.Label.Apex, ex,loanAppId);
            throw new IND_Exception(ex.getMessage());
        }
        return data;
    }
    
    /*
* @Method:      doEmailServiceCallout
* @Created by:  Satyam More
* @Description: Continuation for Email Service API
* @Param:       String - emailService
* @Return:      Object - continuation
*/
    
    @AuraEnabled(continuation=true cacheable=true)
    public static Object doEmailServiceCallout(String emailService){
        Continuation con;
        String loanAppId;
        try{
            if(String.isBlank(emailService)){
                throw new IND_Exception(System.Label.Retry);
            }
            //Provide API-wise Integration Name to Custom Metadata Configs
            Integration_Configuration__mdt apiConfiguration = IntegrationUtilities.getAPIConfiguration(System.Label.EmailService);
            Integer timeout = Integer.valueOf(apiConfiguration.Timeout__c);

            RequestWrapper requestWrapper = (RequestWrapper)IntegrationUtilities.parseJSONRequest(emailService,'RequestWrapper');
            loanAppId = requestWrapper.loanApplicationId;
            //Applicant__c app = [SELECT Opportunity__r.Lead_Number__c FROM Applicant__c WHERE ID=:requestWrapper.applicantId WITH SECURITY_ENFORCED];
            //requestWrapper.leadId=app.Opportunity__r.Lead_Number__c;
            IND_EmailServiceRequest emailServiceRequest = IND_EmailServiceService.getEmailServiceCallOutRequest(requestWrapper);
            CalloutProcessor processor= new CalloutProcessor(System.Label.EmailService, emailServiceRequest);
            HttpRequest request = processor.createHttpRequest();
            Long startTime = DateTime.now().getTime();
            Carrier carrier = new carrier();
            carrier.setServiceName(System.Label.EmailService);
            carrier.setProcessor(processor);
            carrier.setRequest(IntegrationUtilities.getPlainTextForLog(request.getBody()));
            carrier.setEncryptedRequest(request.getBody());
            carrier.setStartTime(startTime);     
            carrier.setLoanApplicationId(loanAppId);
            //Add callout request to continuation
            con = new Continuation(timeout);        
            con.continuationMethod='processEmailServiceResponse';
            con.state=carrier;
            con.addHttpRequest(request);
            
            if(Test.isRunningTest()) {
               continuationLabel = con.addHttpRequest(request);
               continuationState = carrier; 
            }  
        } catch(Exception ex) {
            ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'doEmailServiceCallout', System.Label.Apex, ex,loanAppId);
            throw ex;
        }
        return con;
    }
    /*
    * @Method:      doEmailServiceCalloutwithoutContinuation
    * @Created by:  Gaurav Rawat
    * @Description:  Email Service API without continuation
    * @Param:       String - emailService
    * @Return:      String - Response
    */
    @AuraEnabled(cacheable = true)
    public static string doEmailServiceCalloutwithoutContinuation(String emailService){
        String loanAppId;
        String elapseTime;
        String resp;
        String serviceName = System.Label.EmailService;
        HttpRequest request;
        IND_EmailServiceResponse apiResponse;

        try{
            if(String.isBlank(emailService)){
                throw new IND_Exception(System.Label.Retry);
            }
            //Provide API-wise Integration Name to Custom Metadata Configs
            Integration_Configuration__mdt apiConfiguration = IntegrationUtilities.getAPIConfiguration(System.Label.EmailService);
            Integer timeout = Integer.valueOf(apiConfiguration.Timeout__c);

            // if stubs checked in Integration_Configuration then stubs will return 
            if(apiConfiguration.IsStub_Required__c != null && apiConfiguration.IsStub_Required__c){  
                String stubData = IntegrationUtilities.getStubResponse(System.Label.EmailService);
                return stubData == null ? System.Label.EmptyStubs : stubData;  
            }
            system.debug('emailService-->'+emailService);
            RequestWrapper requestWrapper = (RequestWrapper)IntegrationUtilities.parseJSONRequest(emailService,'RequestWrapper');
            loanAppId = requestWrapper.loanApplicationId;
            loanApplicationRef= requestWrapper.loanApplicationId;
        
            IND_EmailServiceRequest emailServiceRequest = IND_EmailServiceService.getEmailServiceCallOutRequest(requestWrapper);
            CalloutProcessor processor= new CalloutProcessor(System.Label.EmailService, emailServiceRequest);
            request = processor.createHttpRequest();
            request.setTimeout(12000);
            Long startTime = DateTime.now().getTime();
            Http http = new Http();
            HttpResponse response = http.send(request);
            system.debug('response::'+response);
            Long endTime = DateTime.now().getTime();
            elapseTime = String.valueOf((Double)(endTime - startTime)/1000);
            
            if(response != null && response.getStatusCode() == 200) {
                system.debug('::Inside the response method');
                apiResponse = (IND_EmailServiceResponse)processor.getHttpResponse(response, System.Label.EmailService);
                if(apiResponse != null){
                    resp = apiResponse.response.status;
                    system.debug('data::'+resp);
                    IntegrationUtilities.createIntegrationLogger(IntegrationUtilities.getPlainTextForLog(request.getBody()),request.getBody(), IntegrationUtilities.getPlainTextForLog(response.getBody()), response.getBody(), serviceName, elapseTime, loanAppId, System.Label.Success);
                } else {
                    throw new IND_Exception(System.Label.NoResponse); 
                }
                
            } else {
                throw new IND_Exception(System.Label.NoResponse);
            }
                
            
        } catch(Exception ex) {
            IntegrationUtilities.createIntegrationLogger(IntegrationUtilities.getPlainTextForLog(request.getBody()),request.getBody(), '', '', serviceName, elapseTime, loanAppId, System.Label.Failure);
            ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'doEmailServiceCallout', System.Label.Apex, ex,loanAppId);
        }
        return resp; 

    }
    
    /*
* @Method:      processEmailServiceResponse
* @Created by:  Satyam More 
* @Description: Callback method to return Response for Email Service API
* @Param:       Collection - labels
* @Param:       Object - state
* @Return:      Object - response
*/
    @AuraEnabled(cacheable=true)
    public static Object processEmailServiceResponse(List<String> labels, Object state){
        IND_EmailServiceResponse apiResponse;
        String request='';
        String encryptedRequest='';
        String serviceName='';
        HttpResponse response;
        String elapseTime='';        
        String loanAppId='';
        try{            
            Carrier carrier = (Carrier)state;
            request = carrier.getRequest();
            encryptedRequest = carrier.getEncryptedRequest();
            serviceName = carrier.getServiceName();
            Long startTime = carrier.getStartTime();            
            CalloutProcessor processor = carrier.getProcessor();
            response = Continuation.getResponse(labels[0]);
            Long endTime = DateTime.now().getTime();
            elapseTime = String.valueOf((Double)(endTime - startTime)/1000);
            loanAppId = carrier.getLoanApplicationId();
            
            if(response != null && response.getStatusCode() == 200){
                apiResponse = (IND_EmailServiceResponse)processor.getHttpResponse(response, serviceName);
                //IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, IntegrationUtilities.getPlainTextForLog(response.getBody()), response.getBody(), serviceName, elapseTime);
                if(apiResponse!=null){
                    IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, IntegrationUtilities.getPlainTextForLog(response.getBody()), response.getBody(), serviceName, elapseTime, loanAppId, System.Label.Success);
                    return JSON.serialize(apiResponse);
                } else {
                    IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, IntegrationUtilities.getPlainTextForLog(response.getBody()), response.getBody(), serviceName, elapseTime,loanAppId,System.Label.Failure);
                    throw new IND_Exception(System.Label.NoResponse);                
                }
            }
            else {
                String errString = '[Status Code = '+ response.getStatusCode() +' ] Response-->'+IntegrationUtilities.getPlainTextForLog(response.getBody());
                IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, errString, response.getBody(), serviceName, elapseTime, loanAppId, System.Label.Failure);
                ErrorLoggerUtil.logErrorEvent('CalloutProcessor', 'getHttpResponse', System.Label.Apex, new IND_Exception(errString), loanAppId);
                throw new IND_Exception(System.Label.NoResponse);
            } 
        } catch (Exception ex){
            IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, '', '', serviceName, elapseTime,loanAppId,System.Label.Failure);
            ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'processEmailServiceResponse', System.Label.Apex, ex,loanAppId);
            throw new IND_Exception(ex.getMessage());
        }
    }

    /*
    * @Method:      doCrosscore
    * @Created by:  Gaurav Rawat
    * @Description:  Crosscore api callout
    * @Param:       String - loanApplicationId,applicantId
    * @Return:      String - Response
    */
    @AuraEnabled
    public static string doCrosscore(String loanApplicationId, List<String> beneficiaryId, String batchIndex){
        String elapseTime;
        String resp;
        HttpRequest request;
        try{
            Integration_Configuration__mdt apiConfiguration = IntegrationUtilities.getAPIConfiguration(System.Label.Crosscore);
            Integer timeout = Integer.valueOf(apiConfiguration.Timeout__c);

            if(apiConfiguration == null || apiConfiguration.IsActive_Integration__c == false){  
                throw new IND_Exception(System.Label.ServiceDown);
            }
            request = new HttpRequest();

            IND_CrosscoreRequest corsscoreRequest = IND_CrosscoreService.getCrosscoreCallOutRequest(loanApplicationId ,beneficiaryId, batchIndex);

            String requestBody = JSON.serialize(corsscoreRequest);
            requestBody = requestBody.replace('"number1":', '"number":');

            Blob mac = Crypto.generateMac('HmacSHA256', Blob.valueOf(requestBody), Blob.valueOf(System.Label.CrosscoreHMACID));
            String signature = EncodingUtil.base64Encode(mac);

            request.setEndpoint(apiConfiguration.Endpoint_URL__c.trim());
            request.setMethod(apiConfiguration.Rest_Method__c);
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('hmac-signature', signature);
            request.setBody(requestBody);
            request.setTimeout(Integer.valueOf(apiConfiguration.Timeout__c));

            Http http = new Http();
            HttpResponse response = http.send(request);

            Long startTime = DateTime.now().getTime();
            Long endTime = DateTime.now().getTime();
            elapseTime = String.valueOf((Double)(endTime - startTime)/1000);

            System.debug('response.getBody() :: ' + response.getBody());
            if(response != null && response.getStatusCode() == 200) {
                resp = response.getBody();
                IntegrationUtilities.createIntegrationLogger(request.getBody(),request.getBody(), response.getBody(), response.getBody(), System.Label.Crosscore, elapseTime, loanApplicationId, System.Label.Success);
            } else {
                throw new IND_Exception(System.Label.NoResponse);
            }   
        } catch(Exception ex) {
            IntegrationUtilities.createIntegrationLogger(request.getBody(),request.getBody(), '', '', System.Label.Crosscore, elapseTime, loanApplicationId, System.Label.Failure);
            ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'doEmailServiceCallout', System.Label.Apex, ex,loanApplicationId);
        }
        return resp;
    }


    /*
* @Method:      doUidaiBiometricCallout
* @Created by:  Satyam More
* @Description: Method to return Response for UIDAI OTP Verify API
* @Param:       String - Applicant Id
* @Return:      String - response
*/
    @AuraEnabled(continuation=true cacheable=true)
    public static Object doUidaiBiometricCallout(String applicantId,String loanAppId, String randomNo){
        Continuation con;
        try{
            //Provide API-wise Integration Name to Custom Metadata Configs
            Integration_Configuration__mdt apiConfiguration = IntegrationUtilities.getAPIConfiguration(System.Label.UIDAIBiometric);
            Integer timeout = Integer.valueOf(apiConfiguration.Timeout__c);
            if(apiConfiguration.IsStub_Required__c != null && apiConfiguration.IsStub_Required__c){  
                 String stubData = IntegrationUtilities.getStubResponse(System.Label.UIDAIBiometric);
                return stubData == null ? System.Label.EmptyStubs : stubData;  		
                
            }
            
            //Documents__c docs = [SELECT Id, Aadhaar_Enrollment_Number__c FROM Documents__c WHERE Applicant__c=:applicantId WITH SECURITY_ENFORCED limit 1];
            Applicant__c app = [SELECT Id,PID_Block__c,Aadhar_No__c FROM Applicant__c WHERE Id=:applicantId WITH SECURITY_ENFORCED];
            loanApplicationRef= loanAppId;
            IND_UidaiBiometricRequest uidaiBiometricrequest = IND_UidaiBiometricService.getUidaiBiometricRequest(app,loanAppId);
            CalloutProcessor processor= new CalloutProcessor(System.Label.UIDAIBiometric, uidaiBiometricrequest);
            HttpRequest request = processor.createHttpRequest();
            system.debug('continution request '+request);
            Long startTime = DateTime.now().getTime();
            
            Carrier carrier = new carrier();
            carrier.setServiceName(System.Label.UIDAIBiometric);
            carrier.setProcessor(processor);
            carrier.setRequest(IntegrationUtilities.getPlainTextForLog(request.getBody()));
            carrier.setEncryptedRequest(request.getBody());
            carrier.setStartTime(startTime);
            carrier.setLoanApplicationId(loanAppId);
            //Add callout request to continuation
            con = new Continuation(timeout);        
            con.continuationMethod='processUidaiBiometricResponse';
            con.state=carrier;
            con.addHttpRequest(request);
            
            if(Test.isRunningTest()) {
               continuationLabel = con.addHttpRequest(request);
               continuationState = carrier; 
            }  
        } catch(Exception ex) {
            ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'doUidaiBiometricCallout', System.Label.Apex, ex,loanAppId);
            throw ex;
        }
        return con;
    }
    
    /*
* @Method:      processUidaiBiometricResponse
* @Created by:  Satyam More 
* @Description: Method to return Response for UIDAI Biometric API
* @Param:       Collection - labels
* @Param:       Object - state
* @Return:      Object - response
*/
    @AuraEnabled(cacheable=true)
    public static Object processUidaiBiometricResponse(List<String> labels, Object state){
        System.debug('callback()====');
        String apiResponse;
        String request='';
        String encryptedRequest='';
        String serviceName='';
        String loanAppId='';
        String data='';
        HttpResponse response;
        String elapseTime='';
        
        try{
            Carrier carrier = (Carrier)state;
            request = carrier.getRequest();
            encryptedRequest = carrier.getEncryptedRequest();
            serviceName = carrier.getServiceName();
            Long startTime = carrier.getStartTime();
            
            CalloutProcessor processor = carrier.getProcessor();
            response = Continuation.getResponse(labels[0]);
            system.debug('callback response '+response);
            Long endTime = DateTime.now().getTime();
            elapseTime = String.valueOf((endTime - startTime)/1000);
            loanAppId = carrier.getLoanApplicationId();
            if(response != null){
                apiResponse = processor.getHttpResponseForAll(response, serviceName);
                System.debug('callback() apiResponse()===='+apiResponse);
                if(apiResponse !=null){
                    IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, IntegrationUtilities.getPlainTextForLog(response.getBody()), response.getBody(), serviceName, elapseTime,loanAppId, System.Label.Success);
                    data = JSON.serialize(apiResponse);
                } else {
                    throw new AuraHandledException(System.Label.NoResponse);
                }
            } else {
               
                throw new AuraHandledException(System.Label.NoResponse);
            }
        } catch (Exception ex){
            IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, '', '', serviceName, elapseTime,loanAppId, System.Label.Failure);
            ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'processUidaiBiometricResponse', System.Label.Apex, ex,loanAppId);
            throw new AuraHandledException(ex.getMessage());
        }
        return data;
    }
    
    
     /*
* @Method:      doTextMatchCallout
* @Created by:  Satyam More
* @Description: Continuation for Text Match API
* @Param:       String - 
* @Return:      Object - continuation
*/

@AuraEnabled(continuation=true cacheable=true)
public static Object doTextMatchCallout(String textMatch){
    Continuation con;
    String loanAppId;
    try{
        if(String.isBlank(textMatch)){
            throw new IND_Exception(System.Label.Retry);
        }
        //Provide API-wise Integration Name to Custom Metadata Configs
        Integration_Configuration__mdt apiConfiguration = IntegrationUtilities.getAPIConfiguration(System.Label.TextMatch);
        Integer timeout = Integer.valueOf(apiConfiguration.Timeout__c);
        
        //if stubs checked in Integration_Configuration then stubs will return 
        if(apiConfiguration.IsStub_Required__c != null && apiConfiguration.IsStub_Required__c){  
            String stubData = IntegrationUtilities.getStubResponse(System.Label.TextMatch);
            return stubData == null ? System.Label.EmptyStubs : stubData;  
        }
        
        RequestWrapper requestWrapper = (RequestWrapper)IntegrationUtilities.parseJSONRequest(textMatch,'RequestWrapper');
        loanAppId = requestWrapper.loanApplicationId;
        Applicant__c app = [SELECT Id,applicant_number__c FROM Applicant__c WHERE Opportunity__c =: loanAppId WITH SECURITY_ENFORCED LIMIT 1];//CISP-2879

        requestWrapper.leadId = requestWrapper.leadId + '_' + app.applicant_number__c; //CISP-2879
        loanApplicationRef= requestWrapper.loanApplicationId;
        IND_TextMatchRequest textMatchRequest = IND_TextMatchService.getTextMatchCallOutRequest(requestWrapper);
        CalloutProcessor processor= new CalloutProcessor(System.Label.TextMatch, textMatchRequest);
        HttpRequest request = processor.createHttpRequest();
        Long startTime = DateTime.now().getTime();
        Carrier carrier = new carrier();
        carrier.setServiceName(System.Label.TextMatch);
        carrier.setProcessor(processor);
        carrier.setRequest(IntegrationUtilities.getPlainTextForLog(request.getBody()));
        carrier.setEncryptedRequest(request.getBody());
        carrier.setStartTime(startTime);            
        carrier.setLoanApplicationId(loanAppId);     
        //Add callout request to continuation
        con = new Continuation(timeout);        
        con.continuationMethod='processTextMatchResponse';
        con.state=carrier;
        con.addHttpRequest(request);
        
        if(Test.isRunningTest()) {
           continuationLabel = con.addHttpRequest(request);
           continuationState = carrier; 
        }  
    } catch(Exception ex) {
        ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'doTextMatchCallout', System.Label.Apex, ex,loanAppId);
        throw ex;
    }
    return con;
}


/*
* @Method:      processTextMatchResponse
* @Created by:  Satyam More 
* @Description: Callback method to return Response for Run Emi Engine API
* @Param:       Collection - labels
* @Param:       Object - state
* @Return:      Object - response
*/
@AuraEnabled(cacheable=true)
public static Object processTextMatchResponse(List<String> labels, Object state){
    IND_TextMatchResponse apiResponse;
    String request='';
    String encryptedRequest='';
    String serviceName='';
    String loanAppId='';
    HttpResponse response;
    String elapseTime='';        
    try{            
        Carrier carrier = (Carrier)state;
        request = carrier.getRequest();
        encryptedRequest = carrier.getEncryptedRequest();
        serviceName = carrier.getServiceName();
        Long startTime = carrier.getStartTime();            
        CalloutProcessor processor = carrier.getProcessor();
        response = Continuation.getResponse(labels[0]);
        Long endTime = DateTime.now().getTime();
        elapseTime = String.valueOf((Double)(endTime - startTime)/1000);
        loanAppId = carrier.getLoanApplicationId();
        if(response != null && response.getStatusCode() == 200){
            apiResponse = (IND_TextMatchResponse)processor.getHttpResponse(response, serviceName);
            if(apiResponse!=null){
                IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, IntegrationUtilities.getPlainTextForLog(response.getBody()), response.getBody(), serviceName, elapseTime,loanAppId,System.Label.Success);
                return JSON.serialize(apiResponse);
            } else {
                IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, IntegrationUtilities.getPlainTextForLog(response.getBody()), response.getBody(), serviceName, elapseTime,loanAppId,System.Label.Failure);
                throw new IND_Exception(System.Label.NoResponse);                
            }
        }
        else {
            String errString = '[Status Code = '+ response.getStatusCode() +' ] Response-->'+IntegrationUtilities.getPlainTextForLog(response.getBody());
            IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, errString, response.getBody(), serviceName, elapseTime, loanAppId, System.Label.Failure);
            ErrorLoggerUtil.logErrorEvent('CalloutProcessor', 'getHttpResponse', System.Label.Apex, new IND_Exception(errString), loanAppId);
            throw new IND_Exception(System.Label.NoResponse);
        } 
    } catch (Exception ex){
        IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, '', '', serviceName, elapseTime,loanAppId, System.Label.Failure);
        ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'processTextMatchResponse', System.Label.Apex, ex,loanAppId);
        throw new IND_Exception(ex.getMessage());
    }
}
    
    
    /*
* @Method:      doCustomerNameSearchCallout
* @Created by:  Bhushan Charde
* @Description: Method to return Response for Customer Name Search API
* @Param:       String - Applicant Id
* @Return:      String - response
*/
    @AuraEnabled(continuation=true cacheable=true)
    public static Object doCustomerNameSearchCallout(String customerNameSearchString, String loanAppId){
        Continuation con;
        try{
            if(String.isBlank(customerNameSearchString)){
                throw new IND_Exception(System.Label.Retry);
            }
            //Provide API-wise Integration Name to Custom Metadata Configs
            Integration_Configuration__mdt apiConfiguration = IntegrationUtilities.getAPIConfiguration(System.Label.CustomerNameSearch);
            Integer timeout = Integer.valueOf(apiConfiguration.Timeout__c);
            
            //if stubs checked in Integration_Configuration then stubs will return 
            if(apiConfiguration.IsStub_Required__c != null && apiConfiguration.IsStub_Required__c){  
                String stubData = IntegrationUtilities.getStubResponse(System.Label.CustomerNameSearch);
                return stubData == null ? System.Label.EmptyStubs : stubData;  
            }
            
            RequestWrapper requestWrapper = (RequestWrapper)IntegrationUtilities.parseJSONRequest(customerNameSearchString,'RequestWrapper');
            loanAppId = requestWrapper.loanApplicationId;
            loanApplicationRef= requestWrapper.loanApplicationId;
            IND_CustomerNameSearchRequest searchRequest = IND_CustomerNameSearchService.getCustomerNameSearchRequest(requestWrapper, loanAppId); 
            
            CalloutProcessor processor = new CalloutProcessor(System.Label.CustomerNameSearch, searchRequest);
            HttpRequest request = processor.createHttpRequest();
            
            Long startTime = DateTime.now().getTime();
            
            Carrier carrier = new carrier();
            carrier.setServiceName(System.Label.CustomerNameSearch);
            carrier.setProcessor(processor);
            carrier.setRequest(IntegrationUtilities.getPlainTextForLog(request.getBody()));
            carrier.setEncryptedRequest(request.getBody());
            carrier.setStartTime(startTime);
            
            //Add callout request to continuation
            con = new Continuation(timeout);        
            con.continuationMethod='processCustomerNameSearchResponse';
            con.state=carrier;
            carrier.setLoanApplicationId(loanAppId);
            con.addHttpRequest(request);
            
            if(Test.isRunningTest()) {
               continuationLabel = con.addHttpRequest(request);
               continuationState = carrier; 
            }  
        } catch(Exception ex) {
            ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'doCustomerNameSearchCallout', System.Label.Apex, ex, loanAppId);
            throw ex;
        }
        return con;
    }
    
    /*
* @Method:      processCustomerNameSearchResponse
* @Created by:  Bhushan Charde
* @Description: Method to return Response for Customer Name Search API
* @Param:       Collection - labels
* @Param:       Object - state
* @Return:      Object - response
*/
    @AuraEnabled(cacheable=true)
    public static Object processCustomerNameSearchResponse(List<String> labels, Object state){
        IND_CustomerNameSearchResponse apiResponse;
        String request='';
        String encryptedRequest='';
        String serviceName='';
        String data='';
        String loanAppId = '';
        HttpResponse response;
        String elapseTime='';
        
        try{
            Carrier carrier = (Carrier)state;
            request = carrier.getRequest();
            loanAppId = carrier.getLoanApplicationId();
            encryptedRequest = carrier.getEncryptedRequest();
            serviceName = carrier.getServiceName();
            Long startTime = carrier.getStartTime();
            
            CalloutProcessor processor = carrier.getProcessor();
            response = Continuation.getResponse(labels[0]);
            Long endTime = DateTime.now().getTime();
            elapseTime = String.valueOf((Double)(endTime - startTime)/1000);
            
            if(response != null && response.getStatusCode() == 200) {
                apiResponse = (IND_CustomerNameSearchResponse)processor.getHttpResponse(response, serviceName);
                if(apiResponse != null){
                    data = JSON.serialize(apiResponse);
                    IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, IntegrationUtilities.getPlainTextForLog(response.getBody()), response.getBody(), serviceName, elapseTime, loanAppId,System.Label.Success);
                    
                } else {
                    IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, '', '', serviceName, elapseTime, loanAppId, System.Label.Failure);
                    throw new IND_Exception(System.Label.NoResponse);
                }
            } else {
                String errString = '[Status Code = '+ response.getStatusCode() +' ] Response-->'+IntegrationUtilities.getPlainTextForLog(response.getBody());
                IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, errString, response.getBody(), serviceName, elapseTime, loanAppId, System.Label.Failure);
                ErrorLoggerUtil.logErrorEvent('CalloutProcessor', 'getHttpResponse', System.Label.Apex, new IND_Exception(errString), loanAppId);
                throw new IND_Exception(System.Label.NoResponse);
            } 
            
        } catch (Exception ex){
            IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, '', '', serviceName, elapseTime, loanAppId, System.Label.Failure);
            ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'processCustomerNameSearchResponse', System.Label.Apex, ex, loanAppId);
            throw new IND_Exception(ex.getMessage());
        }
        return data;
    }
    

/*
* @Method:      doInsurancePremiumCallout
* @Created by:  Bondiga Thilak 
* @Description: This method is being used to call the Perfios LTV Engine API using continuation
* @Param:       String - applicantId
* @Return:      ''
*/
    @AuraEnabled(continuation=true cacheable=true)
    public static Object doInsurancePremiumCallout(String applicantId, String Ins_Product, String Plan_Code,String loanAppId){
        return doInsurancePremiumCallout(applicantId, Ins_Product, Plan_Code, loanAppId, '');
    }

    @AuraEnabled(continuation=true cacheable=true)
    public static Object doInsurancePremiumCallout(String applicantId, String Ins_Product, String Plan_Code,String loanAppId, String assetId){
        Continuation con;
        try{
            if(String.isBlank(applicantId)){
                throw new IND_Exception(System.Label.Retry);
            }

            //Provide API-wise Integration Name to Custom Metadata Configs
            Integration_Configuration__mdt apiConfiguration = IntegrationUtilities.getAPIConfiguration(System.Label.Insurance_Premium);
            Integer timeout = Integer.valueOf(apiConfiguration.Timeout__c);
            
            //if stubs checked in Integration_Configuration then stubs will return 
            if(apiConfiguration.IsStub_Required__c != null && apiConfiguration.IsStub_Required__c){  
                String stubData = IntegrationUtilities.getStubResponse(System.Label.Insurance_Premium);
                return stubData == null ? System.Label.EmptyStubs : stubData;  
            }
            
            Applicant__c app = [SELECT Id,Opportunity__r.Application_number__c,Opportunity__r.Age__c,Gender__c,Opportunity__r.Required_Tenure__c, Opportunity__r.Loan_amount__c,Opportunity__r.Vehicle_type__c, Opportunity__r.Product_Type__c FROM Applicant__c WHERE Id=:applicantId WITH SECURITY_ENFORCED];

            loanApplicationRef= loanAppId;
            IND_InsurancePremiumRequest insurancePremiumRequestDetails = IND_InsurancePremiumService.getInsurancePremiumRequest(app,Ins_Product,Plan_Code,loanAppId,assetId); 
            CalloutProcessor process = new CalloutProcessor(System.Label.Insurance_Premium, insurancePremiumRequestDetails);
            HttpRequest request = process.createHttpRequest();  
            
            Long startTime = DateTime.now().getTime();
            
            Carrier carrier = new carrier();
            carrier.setServiceName(System.Label.Insurance_Premium);
            carrier.setProcessor(process);
            carrier.setRequest(IntegrationUtilities.getPlainTextForLog(request.getBody()));
            carrier.setEncryptedRequest(request.getBody());
            carrier.setStartTime(startTime);
            carrier.setLoanApplicationId(loanAppId);
            
            //Add callout request to continuation
            con = new Continuation(timeout);        
            con.continuationMethod='processInsurancePremiumAPIResponse';
            con.state=carrier;
            con.addHttpRequest(request);
            
            if(Test.isRunningTest()) {
               continuationLabel = con.addHttpRequest(request);
               continuationState = carrier; 
            }  
        } catch(Exception ex) {
            ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'doInsurancePremiumCallout', System.Label.Apex, ex, loanAppId);
            throw ex;
        }
        return con;
    }
    
    /*
* @Method:      processInsurancePremiumAPIResponse
* @Created by:  Bondiga Thilak 
* @Description: This method is being used to handle the response from continuation and return the response to calling processes
* @Param:       Collection - labels
* @Param:       Object - state
* @Return:      Object - response
*/
    @AuraEnabled(cacheable=true)
    public static Object processInsurancePremiumAPIResponse(List<String> labels, Object state){
        IND_InsurancePremiumResponse apiResponse;
        String request='';
        String encryptedRequest='';
        String serviceName='';
        String data;
        String loanAppId='';
        HttpResponse response;
        String elapseTime='';
        
        try{
            Carrier carrier = (Carrier)state;
            request = carrier.getRequest();
            encryptedRequest = carrier.getEncryptedRequest();
            serviceName = carrier.getServiceName();
            Long startTime = carrier.getStartTime();
            
            CalloutProcessor processor = carrier.getProcessor();
            response = Continuation.getResponse(labels[0]);
            Long endTime = DateTime.now().getTime();
            elapseTime = String.valueOf((Double)(endTime - startTime)/1000);
            loanAppId = carrier.getLoanApplicationId();
            if(response != null && response.getStatusCode() == 200){               
                apiResponse = (IND_InsurancePremiumResponse)processor.getHttpResponse(response, serviceName);               
                if(apiResponse!=null){
                    IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, IntegrationUtilities.getPlainTextForLog(response.getBody()), response.getBody(), serviceName, elapseTime,loanAppId,System.Label.Success);
                    return JSON.serialize(apiResponse);
                } else {
                    IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, IntegrationUtilities.getPlainTextForLog(response.getBody()), response.getBody(), serviceName, elapseTime,loanAppId,System.Label.Failure);
                    throw new IND_Exception(System.Label.NoResponse);   
                }
            }
            else {
                String errString = '[Status Code = '+ response.getStatusCode() +' ] Response-->'+IntegrationUtilities.getPlainTextForLog(response.getBody());
                IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, errString, response.getBody(), serviceName, elapseTime, loanAppId, System.Label.Failure);
                ErrorLoggerUtil.logErrorEvent('CalloutProcessor', 'getHttpResponse', System.Label.Apex, new IND_Exception(errString), loanAppId);
                throw new IND_Exception(System.Label.NoResponse);
            } 
        } catch (Exception ex){
            IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, '', '', serviceName, elapseTime,loanAppId,System.Label.Failure);
            ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'processInsurancePremiumAPIResponse', System.Label.Apex, ex,loanAppId);
            throw new IND_Exception(ex.getMessage());
        }
    }
     
 
 
        /*
* @Method:      doInsuranceRecommendationCallout
* @Created by:  Divya Jawale
* @Description: Continuation for Insurance Recommendation API
* @Param:       String - insuranceRecommendationString
* @Return:      Object - continuation
*/
    @AuraEnabled(continuation=true cacheable=true)
    public static Object doInsuranceRecommendationCallout(String insuranceRecommendationString){
        Continuation con;
        String loanAppId ;
        try{
         if(String.isBlank(insuranceRecommendationString)){
                throw new IND_Exception(System.Label.Retry);
            }
            //Provide API-wise Integration Name to Custom Metadata Configs
            Integration_Configuration__mdt apiConfiguration = IntegrationUtilities.getAPIConfiguration(System.Label.Insurance_Recommendation);
            Integer timeout = Integer.valueOf(apiConfiguration.Timeout__c);   
            RequestWrapper requestWrapper = (RequestWrapper)IntegrationUtilities.parseJSONRequest(insuranceRecommendationString,'RequestWrapper');
            loanAppId = requestWrapper.loanApplicationId;
            if(String.isNotBlank(loanAppId)){ //D2C change
            	Opportunity oppRecord = [SELECT Id, LeadSource FROM Opportunity WHERE Id =:loanAppId LIMIT 1];
            	requestWrapper.D2C = oppRecord.LeadSource == 'D2C'? 'Y':'N';    
            }else{
                requestWrapper.D2C = 'N';    
            }
            loanApplicationRef= requestWrapper.loanApplicationId;
            //if stubs checked in Integration_Configuration then stubs will return 
            if(apiConfiguration.IsStub_Required__c != null && apiConfiguration.IsStub_Required__c){  
                String stubData = IntegrationUtilities.getStubResponse(System.Label.Insurance_Recommendation);
                return stubData == null ? System.Label.EmptyStubs : stubData;  
            }
            
            //RequestWrapper requestWrapper = (RequestWrapper)IntegrationUtilities.parseJSONRequest(insuranceRecommendationString,'RequestWrapper');
            //  Applicant__c app = [SELECT Opportunity__r.Lead_Number__c FROM Applicant__c WHERE ID=:requestWrapper.applicantId WITH SECURITY_ENFORCED];
            //  requestWrapper.leadId= app.Opportunity__r.Lead_Number__c;
            IND_InsuranceRecommendationRequest insuranceRecommendationRequest = IND_InsuranceRecommendationService.getInsuranceRecommendationCallout(requestWrapper);
            CalloutProcessor processor= new CalloutProcessor(System.Label.Insurance_Recommendation, insuranceRecommendationRequest);
            HttpRequest request = processor.createHttpRequest();
            
            // request.setEndpoint(request.getEndpoint()+requestWrapper.perfiosTransactionId);
            Long startTime = DateTime.now().getTime();            
            Carrier carrier = new carrier();
            carrier.setServiceName(System.Label.Insurance_Recommendation);
            carrier.setProcessor(processor);
            carrier.setRequest(IntegrationUtilities.getPlainTextForLog(request.getBody()));
            carrier.setEncryptedRequest(request.getBody());
            carrier.setStartTime(startTime);  
            //Add callout request to continuation
            con = new Continuation(timeout);        
            con.continuationMethod='processInsuranceRecommendationResponse';
            con.state=carrier;
            carrier.setLoanApplicationId(loanAppId);    
            con.addHttpRequest(request);
            
            if(Test.isRunningTest()) {
               continuationLabel = con.addHttpRequest(request);
               continuationState = carrier; 
            }  
        } catch(Exception ex) {
            ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'doInsuranceRecommendationCallout', System.Label.Apex, ex,loanAppId);
            throw ex;
        }
        return con;
    }
    
    /*
* @Method:      processInsuranceRecommendationResponse
* @Created by:  Divya Jawale
* @Description: Method to return Response for Insurance Recommendation
* @Param:       Collection - labels
* @Param:       Object - state
* @Return:      Object - response
*/
    @AuraEnabled(cacheable=true)
    public static Object processInsuranceRecommendationResponse(List<String> labels, Object state){
        IND_InsuranceRecommendationResponse apiResponse;
        String request='';
        String encryptedRequest='';
        String serviceName='';
        HttpResponse response;
        String elapseTime='';   
        String loanAppId='';
        try{
            Carrier carrier = (Carrier)state;
            request = carrier.getRequest();
            encryptedRequest = carrier.getEncryptedRequest();
            serviceName = carrier.getServiceName();
            Long startTime = carrier.getStartTime();            
            CalloutProcessor processor = carrier.getProcessor();
            response = Continuation.getResponse(labels[0]);
            Long endTime = DateTime.now().getTime();
            elapseTime = String.valueOf((Double)(endTime - startTime)/1000);
            loanAppId = carrier.getLoanApplicationId();
            if(response != null && response.getStatusCode() == 200){             
                apiResponse = (IND_InsuranceRecommendationResponse)processor.getHttpResponse(response, serviceName);              
                if(apiResponse!=null){
                    IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, IntegrationUtilities.getPlainTextForLog(response.getBody()), response.getBody(), serviceName, elapseTime,loanAppId,System.Label.Success);
                    return JSON.serialize(apiResponse);
                }
                else {
                    IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, IntegrationUtilities.getPlainTextForLog(response.getBody()), response.getBody(), serviceName, elapseTime,loanAppId,System.Label.Failure);
                    throw new IND_Exception(System.Label.NoResponse);     
                } 
            }else {
                String errString = '[Status Code = '+ response.getStatusCode() +' ] Response-->'+IntegrationUtilities.getPlainTextForLog(response.getBody());
                IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, errString, response.getBody(), serviceName, elapseTime, loanAppId, System.Label.Failure);
                ErrorLoggerUtil.logErrorEvent('CalloutProcessor', 'getHttpResponse', System.Label.Apex, new IND_Exception(errString), loanAppId);
                throw new IND_Exception(System.Label.NoResponse);
            } 
            
        } catch (Exception ex){
            IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, String.valueof(response.getBody()), '', serviceName, elapseTime, loanAppId,System.Label.Failure);
            ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'processInsuranceRecommendationResponse', System.Label.Apex, ex, loanAppId);
            throw new IND_Exception(ex.getMessage());
        }
    }
    
    /*
* @Method:      doPactLmsCallout
* @Created by:  Satyam More
* @Description: Continuation for Pack Lms API
* @Param:       String - 
* @Return:      Void
*/

    @AuraEnabled
    public static void doPactLmsCallout(String loanAppId, String dealId){
        try{
            loanApplicationRef= loanAppId;
            Id pactLMSQueuejobID = System.enqueueJob(new IND_PactLMSCalloutQueueable(loanAppId,dealId));
            if(pactLMSQueuejobID != null){
                if(String.isNotBlank(loanAppId)){
                    Opportunity loanAppRec = [SELECT Id,Product_Type__c FROM Opportunity WHERE Id = :loanAppId LIMIT 1];
                    if(loanAppRec.Product_Type__c == System.Label.Tractor && String.isNotBlank(dealId)){
                        Deal_Number__c dealObj = new Deal_Number__c();
                        dealObj.Id = dealId;
                        dealObj.Sub_Stage__c = 'Beneficiary Details';
                        update dealObj;
                    }else if(loanAppRec.Product_Type__c != System.Label.Tractor){
                        Opportunity loanApp = new Opportunity();
                        loanApp.Id = loanAppId;
                        loanApp.Sub_Stage__c = 'Beneficiary Details';
                        update loanApp;
                    }
                }
            }
        } catch(Exception ex) {
            ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'doPactLmsCallout', System.Label.Apex, ex,loanAppId);
            throw ex;
        }
    }
    
    
    /*
* @Method:      doRCLimitCheckCallout
* @Created by:  Bondiga Thilak 
* @Description: This method is being used to call the RCLimitCheck API using continuation
* @Param:       String - applicantId
* @Return:      ''
*/
    @AuraEnabled(continuation=true cacheable=true)
    public static Object doRCLimitCheckCallout(String applicantId,String loanAppId, String dealId){
        Continuation con;
        try{
			if(String.isBlank(applicantId)){
                throw new IND_Exception(System.Label.Retry);
            }
            system.debug('::doRCLimitCheckCallout method is invoked.');
            //Provide API-wise Integration Name to Custom Metadata Configs
            Integration_Configuration__mdt apiConfiguration = IntegrationUtilities.getAPIConfiguration(System.Label.RCLimitCheck);
            Integer timeout = Integer.valueOf(apiConfiguration.Timeout__c);
            if(apiConfiguration.IsStub_Required__c != null && apiConfiguration.IsStub_Required__c){  
                String stubData = IntegrationUtilities.getStubResponse(System.Label.RCLimitCheck);
                return stubData == null ? System.Label.EmptyStubs : stubData;  
            }

            Applicant__c app = [SELECT Id,Opportunity__r.Application_number__c,	Opportunity__r.Finance_Amount__c FROM Applicant__c WHERE Id=:applicantId WITH SECURITY_ENFORCED Limit 1];
            loanApplicationRef= loanAppId;
			
            
            IND_RCLimitCheckRequest RCLimitCheckRequestDetails = IND_RCLimitCheckService.getRCLimitCheckRequestPerDeal(app,loanAppId,dealId); 
            system.debug('::RCLimitCheckRequestDetails '+RCLimitCheckRequestDetails);
            CalloutProcessor process = new CalloutProcessor(System.Label.RCLimitCheck, RCLimitCheckRequestDetails);
            HttpRequest request = process.createHttpRequest();  
            
            Long startTime = DateTime.now().getTime();
            
            Carrier carrier = new carrier();
            carrier.setServiceName(System.Label.RCLimitCheck);
            carrier.setProcessor(process);
            carrier.setRequest(IntegrationUtilities.getPlainTextForLog(request.getBody()));
            carrier.setEncryptedRequest(request.getBody());
            carrier.setStartTime(startTime);
            carrier.setLoanApplicationId(loanAppId);
            //Add callout request to continuation
            con = new Continuation(timeout);        
            con.continuationMethod='processRCLimitCheckAPIResponse';
            con.state=carrier;
            con.addHttpRequest(request);
            continuationLabel = con.addHttpRequest(request);
            continuationState = carrier;
        } catch(Exception ex) {
            ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'doRCLimitCheckCallout', System.Label.Apex, ex,loanAppId);
            throw ex;
        }
        return con;
    }
    
    /*
* @Method:      processRCLimitCheckAPIResponse
* @Created by:  Bondiga Thilak 
* @Description: This method is being used to handle the response from continuation and return the response to calling processes
* @Param:       Collection - labels
* @Param:       Object - state
* @Return:      Object - response
*/
    @AuraEnabled
    public static Object processRCLimitCheckAPIResponse(List<String> labels, Object state){
        System.debug('::Inside the RCLimitCheck callback');
        IND_RCLimitCheckResponse apiResponse;
        String request='';
        String encryptedRequest='';
        String serviceName='';
        String data;
        HttpResponse response;
        String elapseTime='';
        String loanAppId='';
        String serviceNameForDealerOrDSA = '';
        try{
            Carrier carrier = (Carrier)state;
            request = carrier.getRequest();
            encryptedRequest = carrier.getEncryptedRequest();
            serviceName = carrier.getServiceName();
            serviceNameForDealerOrDSA = carrier.getServiceNameForDealerOrDSA();
            Long startTime = carrier.getStartTime();
            CalloutProcessor processor = carrier.getProcessor();
            response = Continuation.getResponse(labels[0]);
            Long endTime = DateTime.now().getTime();
            elapseTime = String.valueOf((endTime - startTime)/1000);
            loanAppId = carrier.getLoanApplicationId();

            if(response != null){               
                apiResponse = (IND_RCLimitCheckResponse)processor.getHttpResponse(response, serviceName); 
                if(serviceNameForDealerOrDSA != ''){
                    IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, IntegrationUtilities.getPlainTextForLog(response.getBody()), response.getBody(), serviceNameForDealerOrDSA, elapseTime,loanAppId);
                } else {          
                    IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, IntegrationUtilities.getPlainTextForLog(response.getBody()), response.getBody(), serviceName, elapseTime,loanAppId);
                }
                if(apiResponse!=null){
                    return JSON.serialize(apiResponse);
                } else {
                    throw new IND_Exception(System.Label.NoResponse);                
                }
            }
            else {
                if(serviceNameForDealerOrDSA != ''){
                    IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, '', '', serviceNameForDealerOrDSA, elapseTime,loanAppId);
                }else{
                IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, '', '', serviceName, elapseTime,loanAppId);
                }
                throw new IND_Exception(System.Label.NoResponse);
            } 
        } catch (Exception ex){
            if(serviceNameForDealerOrDSA != ''){
                IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, '', '', serviceNameForDealerOrDSA, elapseTime,loanAppId);
            }else{
            IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, '', '', serviceName, elapseTime,loanAppId);
            }
            ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'processRCLimitCheckAPIResponse', System.Label.Apex, ex,loanAppId);
            throw new IND_Exception(ex.getMessage());
        }
    }
    
    @AuraEnabled(continuation=true)
    public static Object doRCLimitCheckCalloutForDSAOrDealer(String applicantId,String loanAppId,String callType, String dealId){
        Continuation con;
        try{
			if(String.isBlank(applicantId)){
                throw new IND_Exception(System.Label.Retry);
            }
            system.debug('::doRCLimitCheckCallout method is invoked.');
            //Provide API-wise Integration Name to Custom Metadata Configs
            Integration_Configuration__mdt apiConfiguration = IntegrationUtilities.getAPIConfiguration(System.Label.RCLimitCheck);
            Integer timeout = Integer.valueOf(apiConfiguration.Timeout__c);
            if(apiConfiguration.IsStub_Required__c != null && apiConfiguration.IsStub_Required__c){  
                String stubData = IntegrationUtilities.getStubResponse(System.Label.RCLimitCheck);
                return stubData == null ? System.Label.EmptyStubs : stubData;  
            }

            Applicant__c app = [SELECT Id,Opportunity__r.Application_number__c,	Opportunity__r.Finance_Amount__c FROM Applicant__c WHERE Id=:applicantId WITH SECURITY_ENFORCED Limit 1];
            loanApplicationRef= loanAppId;
			
            
            IND_RCLimitCheckRequest RCLimitCheckRequestDetails = IND_RCLimitCheckService.getRCLimitCheckRequest(app,loanAppId,callType,dealId); 
            system.debug('::RCLimitCheckRequestDetails '+RCLimitCheckRequestDetails);
            CalloutProcessor process = new CalloutProcessor(System.Label.RCLimitCheck, RCLimitCheckRequestDetails);
            HttpRequest request = process.createHttpRequest();  
            
            Long startTime = DateTime.now().getTime();
            
            Carrier carrier = new carrier();
            carrier.setServiceName(System.Label.RCLimitCheck);
            if(callType == 'Dealer'){
                carrier.setServiceNameForDealerOrDSA('RC limit check (for Dealer)');
            }else{
                carrier.setServiceNameForDealerOrDSA('RC limit check (for DSA)');
            }
            carrier.setProcessor(process);
            carrier.setRequest(IntegrationUtilities.getPlainTextForLog(request.getBody()));
            carrier.setEncryptedRequest(request.getBody());
            carrier.setStartTime(startTime);
            carrier.setLoanApplicationId(loanAppId);
            //Add callout request to continuation
            con = new Continuation(timeout);        
            con.continuationMethod='processRCLimitCheckAPIResponse';
            con.state=carrier;
            con.addHttpRequest(request);
            continuationLabel = con.addHttpRequest(request);
            continuationState = carrier;
        } catch(Exception ex) {
            ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'doRCLimitCheckCalloutForDSAOrDealer', System.Label.Apex, ex,loanAppId);
            throw ex;
        }
        return con;
    }

    
    
    /*
* @Method:      doSSOCallout
* @Created by:  Santhosh Mothe
* @Description: Continuation for SSO API
* @Param:       String - 
* @Return:      Object - continuation
*/
    public static Object doSSOCallout(String username, String password){
        Continuation con;
        try{
            //Provide API-wise Integration Name to Custom Metadata Configs
            Integration_Configuration__mdt apiConfiguration = IntegrationUtilities.getAPIConfiguration(System.Label.SSO);
            Integer timeout = Integer.valueOf(apiConfiguration.Timeout__c);
            
            Ind_DelegateAuthRequest drRequest = new Ind_DelegateAuthRequest(username, password);
            //IntegrationEngine.parentAPIRequest = drRequest;
            //IntegrationEngine.serviceName = System.Label.SSO;
            //system.debug('serviceName----------:'+serviceName);
            
            CalloutProcessor processor= new CalloutProcessor(System.Label.SSO, drRequest);
            HttpRequest request = processor.createHttpRequest();
            Long startTime = DateTime.now().getTime();
            Carrier carrier = new carrier();
            carrier.setServiceName(System.Label.SSO);
            carrier.setProcessor(processor);
            carrier.setRequest(IntegrationUtilities.getPlainTextForLog(request.getBody()));
            carrier.setEncryptedRequest(request.getBody());
            carrier.setStartTime(startTime);            
            //Add callout request to continuation
            con = new Continuation(timeout);        
            con.continuationMethod='processSSOResponse';
            con.state=carrier;
            con.addHttpRequest(request);
            //Test class code
            continuationLabel = con.addHttpRequest(request);
            continuationState = carrier;
        } catch(Exception ex) {
            ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'doSSOCallout', System.Label.Apex, ex);
            throw ex;
        }
        return con;
    }
    
    public static Object processSSOResponse(List<String> labels, Object state){
        IND_PactLmsResponse apiResponse;
        String request='';
        String encryptedRequest='';
        String serviceName='';
        HttpResponse response;
        String elapseTime='';        
        try{            
            Carrier carrier = (Carrier)state;
            request = carrier.getRequest();
            encryptedRequest = carrier.getEncryptedRequest();
            serviceName = carrier.getServiceName();
            Long startTime = carrier.getStartTime();            
            CalloutProcessor processor = carrier.getProcessor();
            response = Continuation.getResponse(labels[0]);
            Long endTime = DateTime.now().getTime();
            elapseTime = String.valueOf((endTime - startTime)/1000);
            
            if(response != null){
                apiResponse = (IND_PactLmsResponse)processor.getHttpResponse(response, serviceName);
                IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, IntegrationUtilities.getPlainTextForLog(response.getBody()), response.getBody(), serviceName, elapseTime);
                if(apiResponse!=null){
                    return JSON.serialize(apiResponse);
                } else {
                    throw new AuraHandledException(System.Label.NoResponse);                
                }
            }    
            else {
                IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, '', '', serviceName, elapseTime);
                throw new AuraHandledException(System.Label.NoResponse);
            } 
        } catch (Exception ex){
            IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, '', '', serviceName, elapseTime);
            ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'processPactLmsResponse', System.Label.Apex, ex);
            throw new AuraHandledException(ex.getMessage());
        }
    }       
    
    
    
    /*
* @Method:      doGSTTransactionStatusAsyncCallout
* @Created by:  Bhushan Charde 
* @Description: Method to return GST Transaction Status in Async
* @Param:       String  - clientTransactionId
* @Param:       String  - loanApplicationId
* @Param:       String  - incomeDtlId
*/
    @AuraEnabled
    public static void doGSTTransactionStatusAsyncCallout(String clientTransactionId, String loanApplicationId, String incomeDtlId){
        
        loanApplicationRef = loanApplicationId;
        IND_PerfiosGSTStatusRequest statusRequest = new IND_PerfiosGSTStatusRequest(clientTransactionId);
        IntegrationEngine.parentAPIRequest = statusRequest;
        IntegrationEngine.serviceName = System.Label.GSTStatus;
        //system.debug('serviceName----------:'+serviceName);
        Integration_Configuration__mdt apiConfiguration = IntegrationUtilities.getAPIConfiguration(serviceName);
        
        try{
            
            if(apiConfiguration != null){
                if(!apiConfiguration.IsActive_Integration__c){
                    ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'doGSTTransactionStatusAsyncCallout', System.Label.Apex, new IND_Exception('Integration is not Active'));
                    throw new IND_Exception('Integration is not Active');       
                }
                if(apiConfiguration.isSync__c){
                    ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'doGSTTransactionStatusAsyncCallout', System.Label.Apex, new IND_Exception('Integration is not Async API'));
                    throw new IND_Exception('Integration is not Async API');       
                }
                
                String requestBody = '';
                String body = '';
                requestBody = parentAPIRequest.convertToJSON();
                String encryptedRequest = IntegrationUtilities.getEncryptedRequest(requestBody,System.Label.privateKey,System.Label.ivkey);  
                String jdataRequest = '"JData":';                    
                body='{'+jdataRequest + '"'+encryptedRequest+'"'+'}';
                
                String req = '';
                String reqExt = '';
                if(body.length() <= 131072){
                    req = body;
                    system.debug('published from low payload');
                    IntegrationUtilities.publishLowPayload(req, serviceName, requestBody, incomeDtlId,'');
                    
                }
                else if(body.length() > 131072 && body.length()<=262144){
                    req = body.substring(0, 131072);
                    reqExt = body.substring(131072,body.length());
                    IntegrationUtilities.publishHighPayload(req, reqExt, serviceName, requestBody, incomeDtlId,'');                  
                }
                else{
                    ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'doGSTTransactionStatusAsyncCallout', System.Label.Apex, new IND_Exception('Request string length is too long'), loanApplicationRef);
                    
                }
                
            }
            
        }
        catch(Exception ex){
            System.debug('IntegrationEngine process() Exception-->'+ex.getMessage() +
                         ' Exception line number-->'+ ex.getLineNumber()+ 
                         ' Stack Tracer-->'+ ex.getLineNumber());
            ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'doGSTTransactionStatusAsyncCallout', System.Label.Apex, ex, loanApplicationRef);
            throw new IND_Exception(ex.getMessage());
        }       
    }
    
    /*
* @Method:      doITRTransactionStatusAsyncCallout
* @Created by:  Bhushan Charde 
* @Description: Method to return ITR Transaction Status in Async
* @Param:       String  - clientTransactionId
* @Param:       String  - loanApplicationId
* @Param:       String  - incomeDtlId
*/
    @AuraEnabled
    public static void doITRTransactionStatusAsyncCallout(String clientTransactionId, String loanApplicationId, String incomeDtlId,String uploadType){
        
        loanApplicationRef = loanApplicationId;
        IND_PerfiosITRStatusRequest statusRequest = new IND_PerfiosITRStatusRequest(clientTransactionId);
        IntegrationEngine.parentAPIRequest = statusRequest;
        if(uploadType.equalsIgnoreCase('scanUpload')){
            IntegrationEngine.serviceName = System.Label.ITR_Scan_upload_retrieve_report;
        }
        else{
            IntegrationEngine.serviceName = System.Label.ITRStatus;
        } 
        Integration_Configuration__mdt apiConfiguration = IntegrationUtilities.getAPIConfiguration(serviceName);
        
        try{
            
            if(apiConfiguration != null){
                if(!apiConfiguration.IsActive_Integration__c){
                    ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'doITRTransactionStatusAsyncCallout', System.Label.Apex, new IND_Exception('Integration is not Active'));
                    throw new IND_Exception('Integration is not Active');       
                }
                if(apiConfiguration.isSync__c){
                    ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'doITRTransactionStatusAsyncCallout', System.Label.Apex, new IND_Exception('Integration is not Async API'));
                    throw new IND_Exception('Integration is not Async API');       
                }
                
                String requestBody = '';
                String body = '';
                requestBody = parentAPIRequest.convertToJSON();
                String encryptedRequest = IntegrationUtilities.getEncryptedRequest(requestBody,System.Label.privateKey,System.Label.ivkey);  
                String jdataRequest = '"JData":';                    
                body='{'+jdataRequest + '"'+encryptedRequest+'"'+'}';
                
                String req = '';
                String reqExt = '';
                if(body.length() <= 131072){
                    req = body;
                    system.debug('published from low payload');
                    IntegrationUtilities.publishLowPayload(req, serviceName, requestBody, incomeDtlId,'');
                    
                }
                else if(body.length() > 131072 && body.length()<=262144){
                    req = body.substring(0, 131072);
                    reqExt = body.substring(131072,body.length());
                    IntegrationUtilities.publishHighPayload(req, reqExt, serviceName, requestBody, incomeDtlId,'');                  
                }
                else{
                    ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'doITRTransactionStatusAsyncCallout', System.Label.Apex, new IND_Exception('Request string length is too long'), loanApplicationRef);
                    
                }
                
            }
            
        }
        catch(Exception ex){
            System.debug('IntegrationEngine process() Exception-->'+ex.getMessage() +
                         ' Exception line number-->'+ ex.getLineNumber()+ 
                         ' Stack Tracer-->'+ ex.getLineNumber());
            ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'doITRTransactionStatusAsyncCallout', System.Label.Apex, ex, loanApplicationRef);
            throw new IND_Exception(ex.getMessage());
        }
        
        
    }
    
    /*
* @Method:      doBSTransactionStatusAsyncCallout
* @Created by:  Bhushan Charde 
* @Description: Method to return Response Report in Async
* @Param:       String  - applicantId
*/
    @AuraEnabled
    public static void doBSTransactionStatusAsyncCallout(String clientTransactionId, String loanApplicationId, String incomeDtlId,String uploadType){
        
        loanApplicationRef = loanApplicationId;
        IND_PerfiosBSTransactionStatusRequest statusRequest = new IND_PerfiosBSTransactionStatusRequest(clientTransactionId);
        IntegrationEngine.parentAPIRequest = statusRequest;
         if(uploadType.equalsIgnoreCase('scanUpload')){
            IntegrationEngine.serviceName = System.Label.ScanUploadRetrieveReport;
        }
        else{
            IntegrationEngine.serviceName = System.Label.Perfios_BS_Transaction_Status;
        } 

        Integration_Configuration__mdt apiConfiguration = IntegrationUtilities.getAPIConfiguration(serviceName);
        
        try{
            
            //Applicant__c app = [SELECT Id FROM Applicant__c WHERE ID=:applicantId WITH SECURITY_ENFORCED];
            
            if(apiConfiguration != null){
                if(!apiConfiguration.IsActive_Integration__c){
                    ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'doBSTransactionStatusAsyncCallout', System.Label.Apex, new IND_Exception('Integration is not Active'));
                    throw new IND_Exception('Integration is not Active');       
                }
                if(apiConfiguration.isSync__c){
                    ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'doBSTransactionStatusAsyncCallout', System.Label.Apex, new IND_Exception('Integration is not Async API'));
                    throw new IND_Exception('Integration is not Async API');       
                }
                
                String requestBody = '';
                String body = '';
                requestBody = parentAPIRequest.convertToJSON();
                String encryptedRequest = IntegrationUtilities.getEncryptedRequest(requestBody,System.Label.privateKey,System.Label.ivkey);  
                String jdataRequest = '"JData":';                    
                body='{'+jdataRequest + '"'+encryptedRequest+'"'+'}';
                
                String req = '';
                String reqExt = '';
                if(body.length() <= 131072){
                    req = body;
                    system.debug('published from low payload');
                    IntegrationUtilities.publishLowPayload(req, serviceName, requestBody, incomeDtlId,'');
                    
                }
                else if(body.length() > 131072 && body.length()<=262144){
                    req = body.substring(0, 131072);
                    reqExt = body.substring(131072,body.length());
                    IntegrationUtilities.publishHighPayload(req, reqExt, serviceName, requestBody, incomeDtlId,'');                  
                }
                else{
                    ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'doBSTransactionStatusAsyncCallout', System.Label.Apex, new IND_Exception('Request string length is too long'), loanApplicationRef);
                    
                }

                
            }
            
        }
        catch(Exception ex){
            System.debug('IntegrationEngine process() Exception-->'+ex.getMessage() +
                         ' Exception line number-->'+ ex.getLineNumber()+ 
                         ' Stack Tracer-->'+ ex.getLineNumber());
            ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'doBSTransactionStatusAsyncCallout', System.Label.Apex, ex, loanApplicationRef);
            throw new AuraHandledException(ex.getMessage());
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
        public transient String serviceNameForDealerOrDSA;
        
        Carrier(){}
        
        Carrier(String serviceName, CalloutProcessor processor, String encryptRequest, Long startTime, String loanAppId, String plainRequest){
            this.serviceName = serviceName;
            this.processor = processor;
            this.encryptedRequest = encryptRequest;
            this.startTime = startTime;
            this.loanApplicationId = loanAppId;
            this.request = plainRequest;
        }
        
        void setTempObject(List<Object> tempObject){
            this.tempObject = tempObject;
        }
        public List<Object> getTempObject(){
            return tempObject;
        }
        
        void setRequest(String request){
            this.request = request;
        }
        public String getRequest(){
            return request;
        }        
        void setEncryptedRequest(String encryptedRequest){
            this.encryptedRequest = encryptedRequest;
        }        
        public String getEncryptedRequest(){
            return encryptedRequest;
        }
        void setProcessor(CalloutProcessor processor){
            this.processor = processor;
        }       
        public CalloutProcessor getProcessor(){
            return processor;
        }       
        void setServiceName(String serviceName){
            this.serviceName = serviceName;
        }        
        public String getServiceName(){
            return serviceName;
        }
        void setServiceNameForDealerOrDSA(String serviceNameForDealerOrDSA){
            this.serviceNameForDealerOrDSA = serviceNameForDealerOrDSA;
        }        
        public String getServiceNameForDealerOrDSA(){
            return serviceNameForDealerOrDSA;
        }
        void setStartTime(Long startTime){
            this.startTime = startTime;
        }
        public Long getStartTime(){
            return startTime;
        } 
        void setLoanApplicationId(String loanApplicationId){
            this.loanApplicationId = loanApplicationId;
        }
        public String getLoanApplicationId(){
            return loanApplicationId;
        }
    }

	  /*
* @Method:      doScanUploadInitiate
* @Created by:  Aman Mundhada
* @Description: Continuation for IND_ScanUploadInitiate API
* @Param:       String - scanUploadInitiateString
* @Return:      Object - continuation
*/
	@AuraEnabled(cacheable=true)
    public static Object doScanUploadInitiate(String scanUploadInitiateString){
        String apiResponse = '';
        String responseBody = '';
        String loanAppId;
        String loanApplicationRef;
        String elapseTime; 
        HttpRequest request;
        ScanInitiateBSResponse scanInitiateResponse;
        try{
            if(String.isBlank(scanUploadInitiateString)){
                 throw new IND_Exception(System.Label.Retry);
            } 
            //Provide API-wise Integration Name to Custom Metadata Configs
            Integration_Configuration__mdt apiConfiguration = IntegrationUtilities.getAPIConfiguration(System.Label.ScanUploadInitiate);
            Integer timeout = Integer.valueOf(apiConfiguration.Timeout__c);           
            RequestWrapper requestWrapper = (RequestWrapper)IntegrationUtilities.parseJSONRequest(scanUploadInitiateString,'RequestWrapper');
            loanAppId = requestWrapper.loanApplicationId;
            loanApplicationRef= requestWrapper.loanApplicationId; 
            List<Opportunity> opp = [SELECT Lead_number__c ,Required_Tenure__c,Loan_amount__c FROM Opportunity WHERE ID=:requestWrapper.loanApplicationId WITH SECURITY_ENFORCED Limit 1];
            
            if(!opp.isEmpty()){ 
                for(Opportunity opportunity:opp){
                    requestWrapper.leadId =  String.valueOf(opportunity.Lead_number__c);                
                    requestWrapper.loanAmount = opportunity.Loan_amount__c;
                    requestWrapper.tenure=String.valueOf(opportunity.Required_Tenure__c);
                }
            } 
			
            IND_ScanUploadInitiateRequest scanUploadInitiateRequest = IND_ScanUploadInitiateService.getScanUploadInitiate(requestWrapper);
            CalloutProcessor processor= new CalloutProcessor(System.Label.ScanUploadInitiate, scanUploadInitiateRequest);
            request = processor.createHttpRequest();
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
                decryptedResponse = decryptedResponse.replace('transaction','transactionInitiate');
                apiResponse = JSON.serializePretty(JSON.deserializeUntyped(decryptedResponse));
                scanInitiateResponse = (ScanInitiateBSResponse)IntegrationUtilities.parseJSONResponse(apiResponse,'ScanInitiateBSResponse');
                String scanDocumentUploadString ='{"perfiosTransactionId":"'+scanInitiateResponse.transactionInitiate.perfiosTransactionId+'","loanApplicationId":"'+requestWrapper.loanApplicationId+'","contentId":"'+requestWrapper.contentId+'","bankName":"'+requestWrapper.bankName+'","incomeDetailId":"'+requestWrapper.incomeDetailId+'"}';
                IntegrationUtilities.createIntegrationLogger(request.getBody(), IntegrationUtilities.getPlainTextForLog(request.getBody()), IntegrationUtilities.getPlainTextForLog(response.getBody()), response.getBody(), System.Label.ScanUploadInitiate, elapseTime,loanAppId,System.Label.Success);
                Map<String,String> scanUploadResponse=new Map<String,String>();
                scanUploadResponse.put('perfiosTransactionId',scanInitiateResponse.transactionInitiate.perfiosTransactionId);
                //scanUploadResponse=(Map<String,String>)doBankStatementScanDocumentUpload(scanDocumentUploadString);
                System.enqueueJob(new ScanUploadDocumentQueuable(scanDocumentUploadString));
                return scanUploadResponse;
            }
            else {
                String errString = '[Status Code = '+ response.getStatusCode() +' ] Response-->'+IntegrationUtilities.getPlainTextForLog(response.getBody());
                responseBody = response.getBody();                        
				responseBody = responseBody.substring(10, responseBody.length()-2);                        
				String decryptedResponse = IntegrationUtilities.getDecryptedResponse(responseBody,System.Label.privateKey,System.Label.ivkey);
				apiResponse = JSON.serializePretty(JSON.deserializeUntyped(decryptedResponse));
                IntegrationUtilities.createIntegrationLogger(request.getBody(), IntegrationUtilities.getPlainTextForLog(request.getBody()), errString, response.getBody(), System.Label.ScanUploadInitiate, elapseTime, loanAppId, System.Label.Failure);
                ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'doScanUploadInitiate', System.Label.Apex, new IND_Exception(errString), loanAppId);
                throw new IND_Exception(apiResponse);
            }      
           }
            else {
                IntegrationUtilities.createIntegrationLogger(request.getBody(), IntegrationUtilities.getPlainTextForLog(request.getBody()), '', '', System.Label.ScanUploadInitiate, elapseTime,loanAppId,System.Label.Failure);
                ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'doScanUploadInitiate', System.Label.Apex, new IND_Exception(), loanAppId);
                throw new IND_Exception(System.Label.NoResponse);
            }           
 
        } catch(Exception ex) {
			ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'doScanUploadInitiate', System.Label.Apex, ex,loanAppId);
            throw ex;
        }
    }
    
    /*
* @Method:      doBankStatementScanDocumentUpload
* @Created by:  Aman Mundhada
* @Description: Continuation for IND_ScanUploadDocument API
* @Param:       String - scanUploadDocumentString
* @Return:      Object - String
*/
    @AuraEnabled(cacheable=true)
    public static Object doBankStatementScanDocumentUpload(String scanDocumentUploadString){
        String apiResponse = '';
        String responseBody = '';
        String loanAppId;
        String loanApplicationRef;
        String elapseTime;
        String encryptedRequest='';
        String institutionIdPerfios='';
        IND_ScanDocumentUploadResponse scanDocumentUploadResponse;
        
        HttpRequest request;
        try{
            if(String.isBlank(scanDocumentUploadString)){
                throw new IND_Exception(System.Label.Retry);
            }
            Integration_Configuration__mdt apiConfiguration = IntegrationUtilities.getAPIConfiguration(System.Label.ScanDocumentUpload);
            Integer timeout = Integer.valueOf(apiConfiguration.Timeout__c);           
            RequestWrapper requestWrapper = (RequestWrapper)IntegrationUtilities.parseJSONRequest(scanDocumentUploadString,'RequestWrapper');
            loanAppId = requestWrapper.loanApplicationId;
            loanApplicationRef= requestWrapper.loanApplicationId;
            List<ContentVersion> bankStatements = getAttachedContentVersions(requestWrapper.contentId);
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
                    scanUploadResponse=(Map<String,String>)doScanUploadProcess(scanUploadProcessString);
                    IntegrationUtilities.createIntegrationLogger(request.getBody(), encryptedRequest, IntegrationUtilities.getPlainTextForLog(response.getBody()), response.getBody(), System.Label.ScanDocumentUpload, elapseTime,loanAppId,System.Label.Success);
                    return scanUploadResponse;
                }
                else {
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
    
    /*
* @Method:      doScanUploadProcess
* @Created by:  Aman Mundhada
* @Description: Continuation for IND_ScanUploadProcess API
* @Param:       String - scanUploadProcessString
* @Return:      Object - continuation
*/
	@AuraEnabled(cacheable=true)
    public static Object doScanUploadProcess(String scanUploadProcessString){
        String apiResponse = '';
        String responseBody = '';
        String loanAppId;
        String loanApplicationRef;
        String elapseTime;
        HttpRequest request;
        Map<String,String> scanUploadResponse;
        try{
            if(String.isBlank(scanUploadProcessString)){
                 throw new IND_Exception(System.Label.Retry);
            } 
            //Provide API-wise Integration Name to Custom Metadata Configs
            Integration_Configuration__mdt apiConfiguration = IntegrationUtilities.getAPIConfiguration(System.Label.ScanUploadProcess);
            Integer timeout = Integer.valueOf(apiConfiguration.Timeout__c);           
            RequestWrapper requestWrapper = (RequestWrapper)IntegrationUtilities.parseJSONRequest(scanUploadProcessString,'RequestWrapper');
            loanAppId = requestWrapper.loanApplicationId;
            loanApplicationRef= requestWrapper.loanApplicationId; 
            IND_ScanUploadProcessRequest scanUploadProcessRequest = IND_ScanUploadProcessService.getScanUploadProcess(requestWrapper);
            CalloutProcessor processor= new CalloutProcessor(System.Label.ScanUploadProcess, scanUploadProcessRequest);
            request = processor.createHttpRequest();
			 if(requestWrapper.perfiosTransactionId==null || String.isBlank(requestWrapper.perfiosTransactionId)){
                throw new IND_Exception(System.Label.PerfiosTransactionIdError);
            }
            request.setEndpoint(request.getEndpoint()+requestWrapper.perfiosTransactionId);
            Long startTime = DateTime.now().getTime();  
            Http http = new Http();
            HttpResponse response = http.send(request);
            
            Long endTime = DateTime.now().getTime();
            elapseTime = String.valueOf((Double)(endTime - startTime)/1000);

            if(response != null){
            if(response.getStatusCode()==202){
                responseBody = response.getBody();                        
                responseBody = responseBody.substring(10, responseBody.length()-2);                        
                String decryptedResponse = IntegrationUtilities.getDecryptedResponse(responseBody,System.Label.privateKey,System.Label.ivkey);
                apiResponse = JSON.serializePretty(JSON.deserializeUntyped(decryptedResponse));
                IntegrationUtilities.createIntegrationLogger(request.getBody(), IntegrationUtilities.getPlainTextForLog(request.getBody()), IntegrationUtilities.getPlainTextForLog(response.getBody()), response.getBody(), System.Label.ScanUploadProcess, elapseTime,loanAppId,System.Label.Success);                     
                String scanUploadReportGenerationString ='{"perfiosTransactionId":"'+requestWrapper.perfiosTransactionId+'","loanApplicationId":"'+requestWrapper.loanApplicationId+'"}';
     			scanUploadResponse = new Map<String,String>();
                scanUploadResponse.put('perfiosTransactionId', requestWrapper.perfiosTransactionId);
                scanUploadResponse.put('Response', apiResponse);
                return scanUploadResponse;
            }
            else {
                String errString = '[Status Code = '+ response.getStatusCode() +' ] Response-->'+IntegrationUtilities.getPlainTextForLog(response.getBody());
                responseBody = response.getBody();                        
				responseBody = responseBody.substring(10, responseBody.length()-2);                        
				String decryptedResponse = IntegrationUtilities.getDecryptedResponse(responseBody,System.Label.privateKey,System.Label.ivkey);
				apiResponse = JSON.serializePretty(JSON.deserializeUntyped(decryptedResponse));
                IntegrationUtilities.createIntegrationLogger(request.getBody(), IntegrationUtilities.getPlainTextForLog(request.getBody()), errString, response.getBody(), System.Label.ScanUploadProcess, elapseTime, loanAppId, System.Label.Failure);
                ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'doScanUploadProcess', System.Label.Apex, new IND_Exception(errString), loanAppId);
                throw new IND_Exception(apiResponse);
            }      
           }
            else {
                IntegrationUtilities.createIntegrationLogger(request.getBody(), IntegrationUtilities.getPlainTextForLog(request.getBody()), '', '', System.Label.ScanUploadProcess, elapseTime,loanAppId,System.Label.Failure);
                ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'doScanUploadProcess', System.Label.Apex, new IND_Exception(), loanAppId);
                throw new IND_Exception(System.Label.NoResponse);
            }           
 
        } catch(Exception ex) {
			ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'doScanUploadProcess', System.Label.Apex, ex,loanAppId);
            throw ex;
        }
    }
    
       /*
* @Method:      doScanUploadReportGeneration
* @Created by:  Aman Mundhada
* @Description: Continuation for IND_ScanUploadReportGeneration API
* @Param:       String - scanUploadReportGenerationString
* @Return:      Object - continuation
*/
	@AuraEnabled(cacheable=true)
    public static Object doScanUploadReportGeneration(String scanUploadReportGenerationString){
        String apiResponse = '';
        String responseBody = '';
        String loanAppId;
        String loanApplicationRef;
        String elapseTime;
        HttpRequest request;
        try{
            if(String.isBlank(scanUploadReportGenerationString)){
                 throw new IND_Exception(System.Label.Retry);
            } 
            //Provide API-wise Integration Name to Custom Metadata Configs
            Integration_Configuration__mdt apiConfiguration = IntegrationUtilities.getAPIConfiguration(System.Label.ScanUploadReportGeneration);
            Integer timeout = Integer.valueOf(apiConfiguration.Timeout__c);           
            RequestWrapper requestWrapper = (RequestWrapper)IntegrationUtilities.parseJSONRequest(scanUploadReportGenerationString,'RequestWrapper');
            loanAppId = requestWrapper.loanApplicationId;
            loanApplicationRef= requestWrapper.loanApplicationId; 
             IND_ScanUploadReportGenerationRequest scanUploadReportGenerationRequest = IND_ScanUploadReportGenerationService.getScanUploadReportGenerationRequest(requestWrapper);
            CalloutProcessor processor= new CalloutProcessor(System.Label.ScanUploadReportGeneration, scanUploadReportGenerationRequest);
            request = processor.createHttpRequest();
			 if(requestWrapper.perfiosTransactionId==null || String.isBlank(requestWrapper.perfiosTransactionId)){
                throw new IND_Exception(System.Label.PerfiosTransactionIdError);
            }
            request.setEndpoint(request.getEndpoint()+requestWrapper.perfiosTransactionId);
            Long startTime = DateTime.now().getTime();  
            Http http = new Http();
            HttpResponse response = http.send(request);
            
            Long endTime = DateTime.now().getTime();
            elapseTime = String.valueOf((Double)(endTime - startTime)/1000);

            if(response != null){
            if(response.getStatusCode()==202){
                responseBody = response.getBody();                        
                responseBody = responseBody.substring(10, responseBody.length()-2);                        
                String decryptedResponse = IntegrationUtilities.getDecryptedResponse(responseBody,System.Label.privateKey,System.Label.ivkey);
                apiResponse = JSON.serializePretty(JSON.deserializeUntyped(decryptedResponse));
                IntegrationUtilities.createIntegrationLogger(request.getBody(), IntegrationUtilities.getPlainTextForLog(request.getBody()), IntegrationUtilities.getPlainTextForLog(response.getBody()), response.getBody(), System.Label.ScanUploadReportGeneration, elapseTime,loanAppId,System.Label.Success);
                return apiResponse; 
            }
            else {
                String errString = '[Status Code = '+ response.getStatusCode() +' ] Response-->'+IntegrationUtilities.getPlainTextForLog(response.getBody());
                responseBody = response.getBody();                        
                responseBody = responseBody.substring(10, responseBody.length()-2);                        
                String decryptedResponse = IntegrationUtilities.getDecryptedResponse(responseBody,System.Label.privateKey,System.Label.ivkey);
                apiResponse = JSON.serializePretty(JSON.deserializeUntyped(decryptedResponse));
                IntegrationUtilities.createIntegrationLogger(request.getBody(), IntegrationUtilities.getPlainTextForLog(request.getBody()), errString, response.getBody(), System.Label.ScanUploadReportGeneration, elapseTime, loanAppId, System.Label.Failure);
                ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'doScanUploadReportGeneration', System.Label.Apex, new IND_Exception(errString), loanAppId);
                throw new IND_Exception(apiResponse);
            }      
           }
            else {
                IntegrationUtilities.createIntegrationLogger(request.getBody(), IntegrationUtilities.getPlainTextForLog(request.getBody()), '', '', System.Label.ScanUploadReportGeneration, elapseTime,loanAppId,System.Label.Failure);
                ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'doScanUploadReportGeneration', System.Label.Apex, new IND_Exception(), loanAppId);
                throw new IND_Exception(System.Label.NoResponse);
            }           
 
        } catch(Exception ex) {
			ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'doScanUploadReportGeneration', System.Label.Apex, ex,loanAppId);
            throw ex;
        }
    }
    
		  /*
* @Method:      doITRScanUploadInitiate
* @Created by:  Satyam More
* @Description: Continuation for IND_ITRScanUploadInitiate API
* @Param:       String - itsScanUploadInitiateString
* @Return:      Object - continuation
*/
	@AuraEnabled(cacheable=true)
    public static Object doITRScanUploadInitiate(String applicantId,String contentDocumentId, String loanAppId,String documentType){
        String apiResponse = '';
        String responseBody = '';
        String loanApplicationRef;
        String elapseTime; 
        HttpRequest request;
        IND_ITRScanUploadInitiateResponse itrScanUploadInitiateResponse;
        try{
            if((String.isBlank(applicantId)) || (String.isBlank(loanAppId))){
                 throw new IND_Exception(System.Label.Retry);
            } 
            //Provide API-wise Integration Name to Custom Metadata Configs
            Integration_Configuration__mdt apiConfiguration = IntegrationUtilities.getAPIConfiguration(System.Label.ITRScanUploadInitiate);
            Integer timeout = Integer.valueOf(apiConfiguration.Timeout__c);           
            loanApplicationRef= loanAppId; 
			Applicant__c app = [SELECT Opportunity__r.Lead_Number__c, PAN_No__c FROM Applicant__c WHERE ID=:applicantId WITH SECURITY_ENFORCED];
            List<Documents__c> docs=[SELECT PAN_No__c FROM Documents__c WHERE Applicant__c=:applicantId and Document_Type__c=:System.Label.PanCards WITH SECURITY_ENFORCED];
            String panNo;
            if(!docs.isEmpty()){
                for(Documents__c doc:docs){
                    if(String.isBlank(doc.PAN_No__c)){
                        throw new IND_Exception(System.Label.PAN_Number);
                    }
                    else{
                       String decrypt = IntegrationUtilities.getDecryptedResponse(doc.PAN_No__c,System.Label.privateKey,System.Label.ivkey);//CISP-3038
                       panNo= decrypt;//CISP-3038,removed doc.PAN_No__c
                    }
                }
            }
            IND_ITRScanUploadInitiateRequest itrScanUploadInitiateRequest = IND_ITRScanUploadInitiateService.getITRScanUploadInitiate(app,loanAppId,panNo);
            CalloutProcessor processor= new CalloutProcessor(System.Label.ITRScanUploadInitiate, itrScanUploadInitiateRequest);
			request = processor.createHttpRequest();
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
                decryptedResponse = decryptedResponse.replace('transaction','transactionInitiate');
                apiResponse = JSON.serializePretty(JSON.deserializeUntyped(decryptedResponse));
                itrScanUploadInitiateResponse = (IND_ITRScanUploadInitiateResponse)IntegrationUtilities.parseJSONResponse(apiResponse,'IND_ITRScanUploadInitiateResponse');
                IntegrationUtilities.createIntegrationLogger(request.getBody(), IntegrationUtilities.getPlainTextForLog(request.getBody()), IntegrationUtilities.getPlainTextForLog(response.getBody()), response.getBody(), System.Label.ITRScanUploadInitiate, elapseTime,loanAppId,System.Label.Success);
				return  doITRScanDocumentUpload(documentType,contentDocumentId,itrScanUploadInitiateResponse.transactionInitiateId, loanAppId);
            }
            else {
                String errString = '[Status Code = '+ response.getStatusCode() +' ] Response-->'+IntegrationUtilities.getPlainTextForLog(response.getBody());
                apiResponse = JSON.serializePretty(JSON.deserializeUntyped(IntegrationUtilities.getPlainTextForLog(response.getBody())));
                IntegrationUtilities.createIntegrationLogger(request.getBody(), IntegrationUtilities.getPlainTextForLog(request.getBody()), errString, response.getBody(), System.Label.ITRScanUploadInitiate, elapseTime, loanAppId, System.Label.Failure);
                ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'doITRScanUploadInitiate', System.Label.Apex, new IND_Exception(errString), loanAppId);
                throw new IND_Exception(apiResponse);
            }      
           }
            else {
                IntegrationUtilities.createIntegrationLogger(request.getBody(), IntegrationUtilities.getPlainTextForLog(request.getBody()), '', '', System.Label.ITRScanUploadInitiate, elapseTime,loanAppId,System.Label.Failure);
                ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'doITRScanUploadInitiate', System.Label.Apex, new IND_Exception(), loanAppId);
                throw new IND_Exception(System.Label.NoResponse);
            }           
 
        } catch(Exception ex) {
			ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'doITRScanUploadInitiate', System.Label.Apex, ex,loanAppId);
            throw ex;
        }
    }
    
    /*
* @Method:      doITRScanDocumentUpload
* @Created by:  Aman Mundhada
* @Description: Continuation for IND_ScanUploadDocument API
* @Param:       String - scanUploadDocumentString
* @Return:      Object - String
*/
    @AuraEnabled(cacheable=true)
    public static Object doITRScanDocumentUpload(String documentType, String contentDocumentId,String perfiosTransactionId, String loanAppId){
        String apiResponse = '';
        String responseBody = '';
        String loanApplicationRef;
        String elapseTime;
        String encryptedRequest='';
        HttpRequest httpRequest ;
        try{

            Integration_Configuration__mdt apiConfiguration = IntegrationUtilities.getAPIConfiguration(System.Label.ITRScanDocumentUpload);
             if(apiConfiguration.IsStub_Required__c != null && apiConfiguration.IsStub_Required__c){  
                String stubData = IntegrationUtilities.getStubResponse(System.Label.ITRScanDocumentUpload);
                return stubData == null ? System.Label.EmptyStubs : stubData;
            }
			Integer timeout = Integer.valueOf(apiConfiguration.Timeout__c);           
            loanApplicationRef= loanAppId;
            if(perfiosTransactionId==null || String.isBlank(perfiosTransactionId)){
                throw new IND_Exception(System.Label.PerfiosTransactionIdError);
            }
			Map<String,String> requestHeaderMap = Utilities.getHeaders();
            List<ContentVersion> bankStatements = getAttachedContentVersions(contentDocumentId);
             if(bankStatements.isEmpty()){
                throw new IND_Exception('ITR Statement not found');
            }
            String extension = bankStatements[0].FileExtension;
            String filename='';
            blob docblob;            
            filename= bankStatements[0].Title+'.'+bankStatements[0].FileExtension;
            docblob = bankStatements[0].versionData;              
            String form64='';
            form64 += ScanUploadHttpBodyPart.WriteBodyParameter('documentType',documentType);
            form64 += ScanUploadHttpBodyPart.WriteBlobBodyParameter('file', EncodingUtil.base64Encode(docblob),filename);
            blob formBlob = EncodingUtil.base64Decode(form64);
            string contentLength = string.valueOf(formBlob.size());
            string contentType = ScanUploadHttpBodyPart.GetContentType();   
            system.debug('apiConfiguration.Endpoint_URL__c===' + apiConfiguration.Endpoint_URL__c); 
            //  Compose the http request
            httpRequest = new HttpRequest();
            httpRequest.setBodyAsBlob(formBlob);
            httpRequest.setHeader('Connection', 'keep-alive');
            httpRequest.setHeader('Content-Length', contentLength);
            httpRequest.setHeader('Content-Type', contentType);
            httpRequest.setHeader('Accept', 'application/json');    
            httpRequest.setMethod('POST');
            //httpRequest.setEndpoint(apiConfiguration.Endpoint_URL__c.trim()+perfiosTransactionId);
            httpRequest.setHeader('IBL-Client-Id', requestHeaderMap.get('IBL-Client-Id'));
            httpRequest.setHeader('IBL-Client-Secret', requestHeaderMap.get('IBL-Client-Secret'));
            httpRequest.setEndpoint('callout:Indus_API'+apiConfiguration.Endpoint_URL__c.trim()+perfiosTransactionId);
            Http http = new Http(); 
            HttpResponse response = http.send(httpRequest);	
            Long endTime = DateTime.now().getTime();
            Long startTime = DateTime.now().getTime(); 
            elapseTime = String.valueOf((Double)(endTime - startTime)/1000);
            if(response != null){
                if(response.getStatusCode()==200){
                    responseBody = response.getBody();
                    responseBody = responseBody.substring(10, responseBody.length()-2);                        
                    String decryptedResponse = IntegrationUtilities.getDecryptedResponse(responseBody,System.Label.privateKey,System.Label.ivkey);
                    String searalizedJson = JSON.serializePretty(JSON.deserializeUntyped(decryptedResponse));  
					IntegrationUtilities.createIntegrationLogger(httpRequest.getBody(), encryptedRequest, IntegrationUtilities.getPlainTextForLog(response.getBody()), response.getBody(), System.Label.ITRScanDocumentUpload, elapseTime,loanAppId,System.Label.Success);
                    return searalizedJson;
                }
                else {
                    String errString = '[Status Code = '+ response.getStatusCode() +' ] Response-->'+IntegrationUtilities.getPlainTextForLog(response.getBody());
                    apiResponse = JSON.serializePretty(JSON.deserializeUntyped(IntegrationUtilities.getPlainTextForLog(response.getBody())));
                    IntegrationUtilities.createIntegrationLogger(httpRequest.getBody(), encryptedRequest, IntegrationUtilities.getPlainTextForLog(response.getBody()), response.getBody(), System.Label.ITRScanDocumentUpload, elapseTime,loanAppId,System.Label.Failure);
                    ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'doITRScanDocumentUpload', System.Label.Apex, new IND_Exception(errString), loanAppId);
                    throw new IND_Exception(apiResponse);
                }     
            }
            else { 
                IntegrationUtilities.createIntegrationLogger(httpRequest.getBody(), encryptedRequest, '', '', System.Label.ITRScanDocumentUpload, elapseTime,loanAppId,System.Label.Failure);
                ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'doITRScanDocumentUpload', System.Label.Apex, new IND_Exception(), loanAppId);
                throw new IND_Exception(System.Label.NoResponse);
            }           
            
        } catch(Exception ex) {
			ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'doITRScanDocumentUpload', System.Label.Apex, ex,loanAppId);
            throw ex;
        }
    }

 /*
* @Method:      doITRScanUploadCompleteTransaction
* @Created by:  Aman Mundhada
* @Description: Continuation for IND_ScanUploadReportGeneration API
* @Param:       String - itrScanUploadCompleteTransactionString
* @Return:      Object - continuation
*/
	@AuraEnabled(cacheable=true)
    public static Object doITRScanUploadCompleteTransaction(String itrScanUploadCompleteTransactionString){
        String apiResponse = '';
        String responseBody = '';
        String loanAppId;
        String loanApplicationRef;
        String elapseTime;
        HttpRequest request;
        try{
            if(String.isBlank(itrScanUploadCompleteTransactionString)){
                 throw new IND_Exception(System.Label.Retry);
            } 
            //Provide API-wise Integration Name to Custom Metadata Configs
            Integration_Configuration__mdt apiConfiguration = IntegrationUtilities.getAPIConfiguration(System.Label.ITRScanUploadCompleteTransaction);
            Integer timeout = Integer.valueOf(apiConfiguration.Timeout__c);           
            RequestWrapper requestWrapper = (RequestWrapper)IntegrationUtilities.parseJSONRequest(itrScanUploadCompleteTransactionString,'RequestWrapper');
            loanAppId = requestWrapper.loanApplicationId;
            loanApplicationRef= requestWrapper.loanApplicationId; 
            IND_ITRSUCompleteTransactionRequest itrScanUploadCompleteTransactionRequest = IND_ITRSUCompleteTransactionService.getITRSUCompleteTransactionRequest(loanAppId);
            CalloutProcessor processor= new CalloutProcessor(System.Label.ITRScanUploadCompleteTransaction, itrScanUploadCompleteTransactionRequest);
            request = processor.createHttpRequest();
			 if(requestWrapper.perfiosTransactionId==null || String.isBlank(requestWrapper.perfiosTransactionId)){
                throw new IND_Exception(System.Label.PerfiosTransactionIdError);
            }
            request.setEndpoint(request.getEndpoint()+requestWrapper.perfiosTransactionId);
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
                apiResponse = JSON.serializePretty(JSON.deserializeUntyped(decryptedResponse));
                IntegrationUtilities.createIntegrationLogger(request.getBody(), IntegrationUtilities.getPlainTextForLog(request.getBody()), IntegrationUtilities.getPlainTextForLog(response.getBody()), response.getBody(), System.Label.ITRScanUploadCompleteTransaction, elapseTime,loanAppId,System.Label.Success);
                return apiResponse; 
            }
            else {
                String errString = '[Status Code = '+ response.getStatusCode() +' ] Response-->'+IntegrationUtilities.getPlainTextForLog(response.getBody());
                apiResponse = JSON.serializePretty(JSON.deserializeUntyped(IntegrationUtilities.getPlainTextForLog(response.getBody())));
                IntegrationUtilities.createIntegrationLogger(request.getBody(), IntegrationUtilities.getPlainTextForLog(request.getBody()), errString, response.getBody(), System.Label.ITRScanUploadCompleteTransaction, elapseTime, loanAppId, System.Label.Failure);
                ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'doITRScanUploadCompleteTransaction', System.Label.Apex, new IND_Exception(errString), loanAppId);
                throw new IND_Exception(apiResponse);
            }      
           }
            else {
                IntegrationUtilities.createIntegrationLogger(request.getBody(), IntegrationUtilities.getPlainTextForLog(request.getBody()), '', '', System.Label.ITRScanUploadCompleteTransaction, elapseTime,loanAppId,System.Label.Failure);
                ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'doITRScanUploadCompleteTransaction', System.Label.Apex, new IND_Exception(), loanAppId);
                throw new IND_Exception(System.Label.NoResponse);
            }           
 
        } catch(Exception ex) {
			ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'doITRScanUploadCompleteTransaction', System.Label.Apex, ex,loanAppId);
            throw ex;
        }
    }
    
     public static List<ContentVersion> getAttachedContentVersions(Id contentId){
       
        List<ContentVersion> contentVersions = [SELECT Id, Title, versionData,FileExtension,ContentSize
                                                FROM ContentVersion 
                                                WHERE ContentDocumentId =:contentId WITH SECURITY_ENFORCED
                                               ];
        return contentVersions;
    }
    
    /*
* @Method:      doEnachRegistrationStatusAsyncCallout
* @Created by:  Bhushan Charde 
* @modified by: Kruthi Nadig, 8/7/22
* @Description: Method to return ENACH Registration Status in Async
* @Param:       String  - statusCheckString
* @Param:       String  - loanApplicationId
*/
@AuraEnabled
public static void doEnachRegistrationStatusAsyncCallout(String statusCheckString, String loanApplicationId){
    
    //String incomeDtlId = loanApplicationId;// some id required, will be sorted at UI handshake activity
    loanApplicationRef = loanApplicationId;
    RequestWrapper requestWrapper = (RequestWrapper)IntegrationUtilities.parseJSONRequest(statusCheckString,'RequestWrapper');
    IND_ENACHRegistrationStatusRequest statusRequest = new IND_ENACHRegistrationStatusRequest(requestWrapper);
    IntegrationEngine.parentAPIRequest = statusRequest;
    IntegrationEngine.serviceName = System.Label.RegistrationStatus;
    Integration_Configuration__mdt apiConfiguration = IntegrationUtilities.getAPIConfiguration(serviceName);
    //if stubs checked in Integration_Configuration then stubs will return 
        if(apiConfiguration.IsStub_Required__c != null && apiConfiguration.IsStub_Required__c){  
            String stubData = IntegrationUtilities.getStubResponse(System.Label.RegistrationStatus);
            //return stubData == null ? System.Label.EmptyStubs : stubData;
        }
    try{
        
        if(apiConfiguration != null){
            if(!apiConfiguration.IsActive_Integration__c){
                ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'doEnachRegistrationStatusAsyncCallout', System.Label.Apex, new IND_Exception('Integration is not Active'));
                throw new IND_Exception('Integration is not Active');       
            }
            if(apiConfiguration.isSync__c){
                ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'doEnachRegistrationStatusAsyncCallout', System.Label.Apex, new IND_Exception('Integration is not Async API'));
                throw new IND_Exception('Integration is not Async API');       
            }
            
            String requestBody = '';
            String body = '';
            requestBody = parentAPIRequest.convertToJSON();
            System.debug('request..'+requestBody);
            String encryptedRequest = IntegrationUtilities.getEncryptedRequest(requestBody,System.Label.privateKey,System.Label.ivkey);  
            System.debug('encryptedRequest..'+encryptedRequest);
            String jdataRequest = '"JData":';                    
            body='{'+jdataRequest + '"'+encryptedRequest+'"'+'}';
            
            String req = '';
            String reqExt = '';
            if(body.length() <= 131072){
                req = body;
                system.debug('published from low payload');
                IntegrationUtilities.publishLowPayload(req, serviceName, requestBody, loanApplicationRef,'');
                
            }
            else if(body.length() > 131072 && body.length()<=262144){
                req = body.substring(0, 131072);
                reqExt = body.substring(131072,body.length());
                IntegrationUtilities.publishHighPayload(req, reqExt, serviceName, requestBody, loanApplicationRef,'');                  
            }
            else{
                ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'doEnachRegistrationStatusAsyncCallout', System.Label.Apex, new IND_Exception('Request string length is too long'), loanApplicationRef);
                
            }
            
        }
        
    }
    catch(Exception ex){
        System.debug('IntegrationEngine process() Exception-->'+ex.getMessage() +
                     ' Exception line number-->'+ ex.getLineNumber()+ 
                     ' Stack Tracer-->'+ ex.getLineNumber());
        ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'doEnachRegistrationStatusAsyncCallout', System.Label.Apex, ex, loanApplicationRef);
        throw new IND_Exception(ex.getMessage());
    }      
}


/*
* @Method:      doSIStatusAsyncCallout
* @Created by:  Bhushan Charde 
* @modified by: Kruthi Nadig, 8/7/22
* @Description: Method to return Standing Instruction Status in Async
* @Param:       String  - statusCheckString
* @Param:       String  - loanApplicationId
*/
@AuraEnabled
public static void doSIStatusAsyncCallout(String statusCheckString, String loanApplicationId){
    
    //String incomeDtlId = '';// some id required, will be sorted at UI handshake activity
    loanApplicationRef = loanApplicationId;
    RequestWrapper requestWrapper = (RequestWrapper)IntegrationUtilities.parseJSONRequest(statusCheckString,'RequestWrapper');
    IND_SIStatusRequest statusRequest = new IND_SIStatusRequest(requestWrapper);
    IntegrationEngine.parentAPIRequest = statusRequest;
    IntegrationEngine.serviceName = System.Label.SIStatus;
    Integration_Configuration__mdt apiConfiguration = IntegrationUtilities.getAPIConfiguration(serviceName);
    //if stubs checked in Integration_Configuration then stubs will return 
        if(apiConfiguration.IsStub_Required__c != null && apiConfiguration.IsStub_Required__c){  
            String stubData = IntegrationUtilities.getStubResponse(System.Label.SIStatus);
           // return stubData == null ? System.Label.EmptyStubs : stubData;
        }
    try{
        
        if(apiConfiguration != null){
            if(!apiConfiguration.IsActive_Integration__c){
                ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'doSIStatusAsyncCallout', System.Label.Apex, new IND_Exception('Integration is not Active'));
                throw new IND_Exception('Integration is not Active');       
            }
            if(apiConfiguration.isSync__c){
                ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'doSIStatusAsyncCallout', System.Label.Apex, new IND_Exception('Integration is not Async API'));
                throw new IND_Exception('Integration is not Async API');       
            }
            
            String requestBody = '';
            String body = '';
            requestBody = parentAPIRequest.convertToJSON();
            String encryptedRequest = IntegrationUtilities.getEncryptedRequest(requestBody,System.Label.privateKey,System.Label.ivkey);  
            String jdataRequest = '"JData":';                    
            body='{'+jdataRequest + '"'+encryptedRequest+'"'+'}';
            
            String req = '';
            String reqExt = '';
            if(body.length() <= 131072){
                req = body;
                system.debug('published from low payload');
                IntegrationUtilities.publishLowPayload(req, serviceName, requestBody, loanApplicationRef,'');
                
            }
            else if(body.length() > 131072 && body.length()<=262144){
                req = body.substring(0, 131072);
                reqExt = body.substring(131072,body.length());
                IntegrationUtilities.publishHighPayload(req, reqExt, serviceName, requestBody, loanApplicationRef,'');                  
            }
            else{
                ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'doSIStatusAsyncCallout', System.Label.Apex, new IND_Exception('Request string length is too long'), loanApplicationRef);
                
            }
            
        }
        
    }
    catch(Exception ex){
        System.debug('IntegrationEngine process() Exception-->'+ex.getMessage() +
                     ' Exception line number-->'+ ex.getLineNumber()+ 
                     ' Stack Tracer-->'+ ex.getLineNumber());
        ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'doITRTransactionStatusAsyncCallout', System.Label.Apex, ex, loanApplicationRef);
        throw new IND_Exception(ex.getMessage());
    }      
}

//******************Code changes directly made on SIT for the M3*************************
  
// added by siva_atla for M4 validation
@AuraEnabled
    public static Map<String, String> doGeoCoderAPI(String fiId, String loanApplicationId){
        
        IND_GeoCoderAPIResponse apiResponse = null;
        String address;
        /*if(String.isBlank(address)){
            throw new IND_Exception(System.Label.Retry);
        }*/
        
        Field_Investigation__c fInvestigation = [SELECT Id, Name, Address_Line_1__c, Address_Line_2__c, Pin_Code__c, State__c, City__c FROM Field_Investigation__c where id =: fiId WITH SECURITY_ENFORCED];
        address = fInvestigation.Address_Line_1__c.trim().replace('#','').replace(' ', '+')+','+fInvestigation.Address_Line_2__c.trim().replace('#','').replace(' ', '+')+','+fInvestigation.City__c.trim().replace(' ', '+')+','+fInvestigation.State__c.trim().replace(' ', '+')+','+fInvestigation.Pin_Code__c;
        Integration_Configuration__mdt apiConfiguration = IntegrationUtilities.getAPIConfiguration(System.Label.GeoCoder);
        Integer timeout = Integer.valueOf(apiConfiguration.Timeout__c);
        
        
        //if stubs checked in Integration_Configuration then stubs will return
        /*if(apiConfiguration.IsStub_Required__c != null && apiConfiguration.IsStub_Required__c){
            String stubData = IntegrationUtilities.getStubResponse(System.Label.GeoCoder);
            return stubData == null ? System.Label.EmptyStubs : stubData;
        }*/
        
        if(!apiConfiguration.IsActive_Integration__c){
            throw new IND_Exception(System.Label.ServiceDown);
        }
        String resp = '';
        String endpoint ='callout:Google_API'+apiConfiguration.Endpoint_URL__c.trim();
		address = address.replace('\\', '/');
        endpoint = endpoint + address +'&key='+ apiConfiguration.Encryption_Key__c + '&callback';
		
        Long startTime = DateTime.now().getTime();
        String elapseTime='';
        Map<String, String> latLongMap = new Map<String, String>();
        try{
            
            String methodType = apiConfiguration.Rest_Method__c.trim();
            HttpRequest httpRequest = new HttpRequest();
            httpRequest.setMethod(methodType);
            httpRequest.setEndpoint(endpoint);
            
            Http http = new Http();
            HttpResponse response = http.send(httpRequest);
            
            Long endTime = DateTime.now().getTime();
            elapseTime = String.valueOf((Double)(endTime - startTime)/1000);
            
            String responseBody;
            
            
            if(response != null) {
                if(response.getStatusCode() == 200){
                    resp = response.getBody();
                    IntegrationUtilities.createIntegrationLogger(endpoint, '', resp, '', System.Label.GeoCoder, elapseTime, loanApplicationId,System.Label.Success);
                    
                    String searalizedJson = JSON.serializePretty(JSON.deserializeUntyped(resp));
                    
                    system.debug('searalizedJson:'+searalizedJson);
                    apiResponse = (IND_GeoCoderAPIResponse)IntegrationUtilities.parseJSONResponse(searalizedJson, 'IND_GeoCoderAPIResponse'); 
                    if(apiResponse.status == 'OK'){
                        system.debug('location is is:'+apiResponse.results[0].geometry.location.lat);
                        latLongMap.put('lat',String.valueOf(apiResponse.results[0].geometry.location.lat));
                        latLongMap.put('lng',String.valueOf(apiResponse.results[0].geometry.location.lng));
                        // CISP-2701 OR CISP-3099-START
                        if(apiResponse.results[0].geometry.location.lat != null){
                            Decimal lat = (Decimal)apiResponse.results[0].geometry.location.lat;
                            fInvestigation.KYC_Location__Latitude__s = lat;
                        }
                        if(apiResponse.results[0].geometry.location.lng != null){
                            Decimal lng = (Decimal)apiResponse.results[0].geometry.location.lng;
                            fInvestigation.KYC_Location__Longitude__s = lng;
                        }
                        // CISP-2701 OR CISP-3099-END
                        update fInvestigation;
                    }else{
                        latLongMap.put('lat','0.0');
                        latLongMap.put('lng','0.0');
                    }
                    
                } else {
                    resp= response.getBody();
                }               
            }
        } catch(Exception ex){
            IntegrationUtilities.createIntegrationLogger(endpoint, '', resp, '', System.Label.GeoCoder, elapseTime, loanApplicationId,System.Label.Failure);
            ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'doGeoCoderAPI', System.Label.Apex, ex,loanApplicationId);
            throw new IND_Exception(ex.getMessage());
        }
        
        return latLongMap;
    }
// added by siva_atla for M4 validation
 @AuraEnabled
    public static String doGenerateTokenAPI(){
        
        Integration_Configuration__mdt apiConfiguration = IntegrationUtilities.getAPIConfiguration(System.Label.Web_Session_Token);
        Integer timeout = Integer.valueOf(apiConfiguration.Timeout__c);
        
        if(!apiConfiguration.IsActive_Integration__c){
            throw new IND_Exception(System.Label.ServiceDown);
        }
        String resp = '';
       IND_WebSessionAuthorizeTokenResponse apiResponse=null;
        try{
            
            String methodType = apiConfiguration.Rest_Method__c.trim();
            String endpoint ='callout:Indus_API'+apiConfiguration.Endpoint_URL__c.trim();
            
            Long startTime = DateTime.now().getTime();
            
            HttpRequest httpRequest = new HttpRequest();
            httpRequest.setMethod(methodType);
            httpRequest.setEndpoint(endpoint);
            
            Security_Setting__mdt metadataApi = Security_Setting__mdt.getInstance(System.Label.IBMMasterKey); 
            httpRequest.setHeader(System.Label.X_IBM_Client_Id, metadataApi?.Client_Id__c);
            httpRequest.setHeader(System.Label.X_IBM_Client_Secret, metadataApi?.Client_Secret__c);
            
            httpRequest.setHeader('Content-Type', 'application/json');
            
            //hr.setBody(body);
            Http http = new Http();
            System.debug('Request ---' +httpRequest.getbody());
            HttpResponse response = http.send(httpRequest);
            
            Long endTime = DateTime.now().getTime();
            String elapseTime = String.valueOf((Double)(endTime - startTime)/1000);
            
            String responseBody;
            
            /*if(response != null) {
                if(response.getStatusCode() == 200){
                    resp = response.getBody();
                    IntegrationUtilities.createIntegrationLogger(endpoint, '', resp, '', System.Label.Web_Session_Token, elapseTime,'');
                } else {
                    resp= response.getBody();
                }               
            }*/
            System.debug('Response ---' +response);
            if(response != null){                             
                responseBody = response.getBody();                        
                responseBody = responseBody.substring(10, responseBody.length()-2);                        
                String decryptedResponse = IntegrationUtilities.getDecryptedResponse(responseBody,System.Label.privateKey,System.Label.ivkey);
                String searalizedJson = JSON.serializePretty(JSON.deserializeUntyped(decryptedResponse));
                IntegrationUtilities.createIntegrationLogger('', '', IntegrationUtilities.getPlainTextForLog(response.getBody()), response.getBody(), serviceName, elapseTime);
                system.debug('searalizedJson:'+searalizedJson);
                
                
                
                apiResponse = (IND_WebSessionAuthorizeTokenResponse)IntegrationUtilities.parseJSONResponse(searalizedJson, 'IND_WebSessionAuthorizeTokenResponse'); 
                system.debug('sesssion id is:'+apiResponse.SessionId);
                
                return apiResponse.SessionId;
            }
            else {
                IntegrationUtilities.createIntegrationLogger('', '', '', '', '', elapseTime);
                throw new IND_Exception(System.Label.NoResponse);
            }
        } catch(Exception ex){
            ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'doGenerateTokenAPI', System.Label.Apex, ex,'');
            throw new IND_Exception(ex.getMessage());
        }
        //system.debug('resp is -------------:'+resp);
        //return resp;
        //return apiResponse;
    }
	
	@AuraEnabled(cacheable=true)
    public static Object doUidaiOTPVerifyCallout2(String kycUidaiRequestString){
        String apiResponse = '';
        String responseBody = '';
        String loanAppId;
        String loanApplicationRef;
        String elapseTime; 
        HttpRequest request;
        String searalizedJson='';
		String data='';
        String decryptedResponse='';
        try{
            if(String.isBlank(kycUidaiRequestString)){
                 throw new IND_Exception(System.Label.Retry);
            } 
            //Provide API-wise Integration Name to Custom Metadata Configs
            Integration_Configuration__mdt apiConfiguration = IntegrationUtilities.getAPIConfiguration(System.Label.UIDAIOTPVERIFY);
			
            Integer timeout = Integer.valueOf(apiConfiguration.Timeout__c);           
            RequestWrapper requestWrapper = (RequestWrapper)IntegrationUtilities.parseJSONRequest(kycUidaiRequestString,'RequestWrapper');
            
            
			List<Applicant__c> app = [SELECT Opportunity__r.Lead_Number__c FROM Applicant__c WHERE ID=:requestWrapper.applicantId WITH SECURITY_ENFORCED];
            
            if(app.isEmpty()){
                throw new IND_Exception(System.Label.Applicantdatamissing);
            }else {
                for(Applicant__c applicant:app){
                    requestWrapper.leadId= applicant.Opportunity__r.Lead_Number__c;
                }
            }
			loanAppId = requestWrapper.loanApplicationId;
            loanApplicationRef= requestWrapper.loanApplicationId;
			
            IND_UidaiOTPVerifyRequest uidaiOtpVerifyrequest = IND_UidaiOTPVerifyService.getUidaiOtpVerifyRequest(requestWrapper);
            CalloutProcessor processor= new CalloutProcessor(System.Label.UIDAIOTPVERIFY, uidaiOtpVerifyrequest);
            request = processor.createHttpRequest();
            request.setTimeout(120000);
            Long startTime = DateTime.now().getTime();  
            Http http = new Http();
           
            HttpResponse response = http.send(request);
            Long endTime = DateTime.now().getTime();
            elapseTime = String.valueOf((Double)(endTime - startTime)/1000);

            if(response != null){
            if(response.getStatusCode()==200){
                responseBody = response.getBody();                        
                responseBody = responseBody.substring(10, responseBody.length()-2);                        
                decryptedResponse = IntegrationUtilities.getDecryptedResponse(responseBody,System.Label.privateKey,System.Label.ivkey);
                
                Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(decryptedResponse);
                Map<String, Object> m2 = (Map<String, Object>) m.get('response');
                List<Object> m3 = (List<Object>) m2.get('content');
                String str = (String)m3.get(0);
                String str2 = str.replace('\\','-');
                String str3 = str2.replace('&',' ');
                searalizedJson = XMLParser.xmlToJson(str3);
                //String str = '{"kycResponse": {"TransactionInfo": {"Pan": "6071890510925076003", "Proc_Code": "130000", "Transm_Date_time": "0701042956", "Stan": "890313", "Local_Trans_Time": "095956", "Local_date": "0701", "AcqId": "200031", "RRN": "218209890313", "ResponseCode": "00", "ResponseMsg": "Approved", "CA_Tid": "register", "CA_ID": "IBLA76232I02361", "CA_TA": "IBL HOUSE ANDHERI      MUMBAI       MHIN"}, "UidData": {"tkn": "01000733Ys/CuSO71Ml6vZQ7+wrP7VX5ns3yAIWbpQrFMjHUn/Ag8VA9lm2SOSkDWC0TVFvu", "txn": "UKC:802249", "uid": "510925076003", "dob": "30-03-1989", "gender": "M", "name": "Bhushan Rambhau Charde", "email": "null", "phone": "null", "dist": "Nagpur", "house": "null", "lm": "Plot No 53 gajanan nagar Behind Ba by Wing School", "co": "null", "subdist": "null", "po": "null", "loc": "Shivam lay Out Umred Road", "pc": "440034", "state": "Maharashtra", "street": "null", "vtc": "Hudkeshwar khurd.", "Pht": "/9j/4AAQSkZJRgABAgAAAQABAAD/2wBDAAgGBgcGBQgHBwcJCQgKDBQNDAsLDBkSEw8UHRofHh0aHBwgJC4nICIsIxwcKDcpLDAxNDQ0Hyc5PTgyPC4zNDL/2wBDAQkJCQwLDBgNDRgyIRwhMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjL/wAARCADIAKADASIAAhEBAxEB/8QAHwAAAQUBAQEBAQEAAAAAAAAAAAECAwQFBgcICQoL/8QAtRAAAgEDAwIEAwUFBAQAAAF9AQIDAAQRBRIhMUEGE1FhByJxFDKBkaEII0KxwRVS0fAkM2JyggkKFhcYGRolJicoKSo0NTY3ODk6Q0RFRkdISUpTVFVWV1hZWmNkZWZnaGlqc3R1dnd4eXqDhIWGh4iJipKTlJWWl5iZmqKjpKWmp6ipqrKztLW2t7i5usLDxMXGx8jJytLT1NXW19jZ2uHi4+Tl5ufo6erx8vP09fb3+Pn6/8QAHwEAAwEBAQEBAQEBAQAAAAAAAAECAwQFBgcICQoL/8QAtREAAgECBAQDBAcFBAQAAQJ3AAECAxEEBSExBhJBUQdhcRMiMoEIFEKRobHBCSMzUvAVYnLRChYkNOEl8RcYGRomJygpKjU2Nzg5OkNERUZHSElKU1RVVldYWVpjZGVmZ2hpanN0dXZ3eHl6goOEhYaHiImKkpOUlZaXmJmaoqOkpaanqKmqsrO0tba3uLm6wsPExcbHyMnK0tPU1dbX2Nna4uPk5ebn6Onq8vP09fb3+Pn6/9oADAMBAAIRAxEAPwDpWUjkGnBuAcU15MZAFIJNwIoEWFZcA5qUSZ4YDB9Kz1ZlPFTJK+RkcUhEk6IwypFZ0nBNaEq4XcMEGs+YkH29KBlWQiqxcA1JdTRQRNJK4RAMkselc1d+JbRTiHMpzjPQUAdIsnPWr1vcAYBNcIPEkhKlYd2ewNPn8TXFuVIQJ6gmi6FZnpsM/vVpX71weheK4b+UQynZIOh9a6uG73AFCCPXNAjYVwRwKUt05qlHMxH3gDU4YkDJyKALBIZOOoqDblsHC+9ICFP3uKRyW5XBPvQArW6MOGG6qMsWwkHtVoLJ16GkmhMnzZAb1oAzWBp6BcDNJKxUlWG0+lRJJg96YFiRQRmowvPFTuDUDLg56UDEBINOOfWotrE8H8KeC4PIoAmRjtKtXL+IPE9hou5HcST4yI16/j6VX8ZeK30WAWloyi8lX739xfX615FPcSTylpHZ2Y5JY8mgZtax4nvNXkO87Iv4UXoBWXHdtGQcbiO2apF/mpFkOc0hmyuqSIQ2fm9KHu5ZCZD+8mboSeBWTvOSc5Jp6yyA4TjtQBbhubuwuln3AOpzwe9XV8QX09x5iXDxyZ4KtjFZUkMpj3Nnmoo1eOQEDPNK4WPS9A8cXkDiLVCZkPRsfN/9evSLC9hvrdZraVXRhnAPSvBJLoNEj9B+v1q/pXiG80ibzbWZkB6r1U/hQmJx7HvQz3FIwPY4rnvDHiP+3bcs6Kkijna2Qf8ACujyaokg8yRD941IsgI560ske4ZxVdg4HHBFAEs8CzpkY3VkyRMkm0jFXxKQeTj8aWSIXCA4O4d6AGM2RUDjmpWGahckGkNkDMVbrTjchYyTwRSSKcVh+I9TXSdGnuWxvK7Iwe7Hgf4/hTGeXeKtSOpeIbqUNmNW2J9B/k/nWEX5pZZPnY9Se9JGhPJ5pXHYQIS2alEe3nFSKnNPI4qblcoxYi31q7bWoLjj6mo4lPGO/StizhyVAzknniobKSCe2XyI4wvzd+KrGzSFge59ula88TNL8oyAKVLGS5RhlRIAcKe9JDsc9doMBlGAfvAVTBMeFz8ua2Lu2ZCVdSpHUEc1nGMSZQfeHT3q0yWi9o+tXWlXaz2spVh17j8R3r23w34hg1/TRcxjZKh2yxk52t/UGvnxg0Zrq/AuuvpmtxxGTEV0RGwY8Z/h+nPGfeqREke5rJ27GggN7iqsEwmjDAH0I7qfQ1YVhxmmQROg5GBkVAWkX7jcf3TV9kVh0qCSHDZH5CgCk3GcGo2YFRzzSyHBNRGQHg4pjGu3Bry74hav9pvU0+Jv3dtzJg9XI6fgP516VM5Ctjk4OAK8J1ac3GpXkhJ+aVj+tA0UFBd6tpFimWce6TpVx8J1qHqWiML7U/yywzim+aBzilW8A420tSlYv20QADYrVh8tGDqxB6kHtWLFdbhwuBVoSHg9qzZokjUW5Al3jn1qxPcxhVkhBDDkEdjWBJMU6Hk1E2r3EIKooI9xQDsjcu5lvo9+As4GDn+KuemQrLuxhh1FSR6zMxO6Mc+i1YjnhuDiWMhj3FVqiHZmdOu5d4FUg+xgQSDngg4Irde1CgqrblPSsK4XZKwI6E1UGTJHuHgzW5NU0W2uZsNLnyJyO7D7r/UjGfr7V1udoz19q8p+E1w5n1G33EoVSQLjgEEg/nkf9816rEc9s1dzJkyyqV6YpCxPQg0m30AphLKeOKBGXJkiqrZB9KtvlutV5RmmUys7kc5H1rxTxFafYddvLcD5RISuP7p5H6EV7NKvtjFeW+O49niEHsYUPPfqP6UgWhkaYn7t279BTpI8sSeTU+mLtsy3HJNRTthj6e1SzSI1UUnFDQoO36Uk0Mn2JZkfnPKqegqfTUtpZJxNIxiCZDk4OfpU20uO6IN5jHGMVLDKZXCAcmoJgEZlQll7HFaegQq+oRb/AO9SehafRFO4Zo32kc+9Q8cZ610Xim0VL5nRMc8gVhQCPDmVCSVIX0BoWonoS20ayuAGQH/aYCpJU8o4ZcH1ByKzoYQzxR7drbss7HjFaN55SuEgJZT1xTcV0EmS2jFpAmay9Wj8u9Ix15q/ZlllT61Hr8eLmNx0ZaI7ilsdr8JYip1SQcgiNevT73+P6V6d8yHivMfhQ3yakmTn92f/AEKvTULY/TNaGLJI58cEmldj2NN2c5xUnl56ZzQBlPwxx0qCQ81JKSDkH8KgZw4waEUytMR615x8QogL+ymGdzxsp/4Cc/8Asxr0Gc4Nec+J9XttVgEMcTZikykhPXsadwSMq0+WwUeuab5R5zyc1NANtrGPRaaX5rJs0iiv5DFuvFO8kIASfwqTOe9IfXNTdl2RA67mHr2Fb+gRLHOryYGDk5rHTbGGlY9P0qe21BeSrg/SlK9tCo2vc7PxNaQTSB7dxIjICGXkZx0rjPs+1mUj8KtjXngYKZBt/ump52t5yk8OQSPnX+tRG63KcU9jMFortjJFbtjoUDhWZ8mi1jgLgsoOfWrYuFtiCq8DsKJSfQlIbNo8MZLIm0/zrB8QQ5gifA+UkGt5tV8w/MazNUTz7NgACcgjiim3fUU1ob/wvtjDa3t2QxEjrGFx/dGSf/Hv0r0hGdgCqbT/ALRrzbwlq8drcW+jwo2zYzb2PJbqfw6/lXoUUhZBXSnc5pRaepZP2g9ZAPoM0BN3DSM/1pgkI704MWOV70xFGTDc96rOCKtblZeaglUetCKMy6IWNmyOATXkMoADE85Nev3cQkieMnAZSK8juE8q4eJ/vIxBqZlw6okRs2y49KgdsZxTrYHy3U9ulMcc4pMadgWTFSoQRVVuDTlchcd6Vh8wXBypRh8pqC3gWPJRiKlOWPJpyhcEbuaaQX1Imto5G3vuZq6XQLAzRNLIQFX5UGetY8KIxALcdzW3aXq2qKoIK9sVMthq5YuE8hsdqz5bo9jVu7uEnTcCM+1Y8jEMeKlIpsl8/cRVsyEw4zyeBmsuPrjFaiRholY5+XnHrVWSIbLWmiC31ixuIZCT5gSQEYwTx/WvULV8jk815rpOnSfbN9wNo81cc/xbq9BtXKYx19adPW4qvQ11UtyBx70hQ5wGIFJFKXqQnC5rUxsZgIHQ0kgyMg1D2zQ0uFOVNBRXn5FeX63aGHU7oSJyZCykdwea9NlbJ4NYuraMmpbWLFHXjIHUUmrocXZnB25HllO61BKuGrp7zR47KwIjyzq25mPU1zcmMmpsVe5UkB4qN5Ngyaml+7VcYJ5FFguOjV5cHIUe9XFsXblZl+mKrGVVGec05b4LkbWNLXoUmupuWHhv7VbyPJq9lbsqkqkm4lj6cA4rKura6spSuRIufvIcg1EL7eMAsKkS7ZBwxIpaobceg+C7wQr5APWpn+bkZIqkxDnPep0YhQKLE3JI1O4ccVp7mSDcqFgvLewzyazozhhzXWaBAGieQjIPy0JXBtLUk0eM3F5ExufMRHzGB29c12SLtIrIsbK2tp/NjgRWPcCt1MMuexqoR5SJy5iWN+hFWVbzB71SXKtirCNg8VZBSJwM1EzZHr9KfIM1VJx060yiKUc5FQkg/eJGOmKnb5u9QOpHJFAiC5hWWF0J3BhjBrzi+ha3uXjbgqcV6Q7HOF6/SuP8TQBbhJCBuccke1KSGjnGwRVRxg4q2etROvNTsMhCk09Igx5pOlOV+vFA7DhEDTzA3bmmhj1qwtx8uGFJjSIBEwYZqyuRTNwZuBxUignHvS3B2HxZMoA6n0r0TS7b7PaJCQQ6jLg+p5rl/DmnLcX4Z1DCNd+CMg+ma7i3jiE7KhIfAypz0GQD+lUtCJE8aYq3AxU4J496YE9akC4HSrJLBHGRTo2zwetNjbjB5FOIO7cKAM5izZ61CBk81KWI7VEclumKBjJAM9cfWonIY4UZPvUzp6kVFJEu3IJBpgV3hZvvcD2rnfFcQ+wRv/Ej4/Aj/wCtW7KzoCN3H1rlfE1+qottwSxBJPak9gW5yruQaiMnrUj81Ey+1Z3NLBvFLuFRlMHinLGTQFh4anq35UwwsPWgJg0h2LCSDirUTgc4qiq47VOhPSi4rHa+DRukun9Ao/n/AIV2SIM57/SvN/D+rHTNQSNj+5l4cfyNemiMrjcMcAj6HmrjqiJLUfjAHNPAFMA6VIuOKokevrU6gFMVCtSr+lAGG0+wNVb7SM5NRNHK/AGKBZsQCxphcHu1HIzVOe4eU4ANXvska9eaR0VFOAM0XSGYsiOxwR1rlfFcDR3EcnYiu9S3LSB5B7qK5zxXYmfTiVGSnzj8OtF7oS0ZxanIFP25FQxGraAGueWh0orleaegwalkj9KcicUrjFbDKMdaj2Cp9vFIY8jilcLESrk4FWIYjupUjAPSpxwpxkGlzAkQhc3S88g8GvbvA1xb+JNJW1vfkuYQI1kU8j0P0Pp9a8PuJPLCv3DA16H4SuZNO1e1mhzsmxuAOCR6/UHn862pu6sY1FZnoF/oMunEGaVRGThZCp2n8ecH61W+wTlNyBXH+wwNegq8N5aDeqyJIg3IwyORyMVgzeFYRIzW00kanopbOKpStuRbscw0TxnEiMp9xSqa6L+ydQg4WfeB2YUw6ezcSWyE+oBB/SnddxWZw+VPQjHtTMg96oniLnqf600rh1HSr9n5hctSuq8FgKakRb526dhUdsnmO+7kK2PxxWhsBHrUNWGioV5JrPvIBLb4xn2rZdAqnIxiqIAZAD/eqoIUjyjUrB9Ov2iPKN8yH1B/zimxNiu58T6V52nSTJGrSQAkZHRe/wDLP4VwK8EGsakdTaDui6PmFPRecVHG2cVYU96yZqAAox6CjNO79KloYAZwKkAGMUiIWPAJq7badLM3IIHvSbGkY9+uIeM8mvRLdjaw6UQCJI4FJC9+T/SuP16x+z2sZHqRmu8WN5nspIkD77fheuSOCP0rWi9LmNVHfaVrf2myjBKpIvHynj6/QjBrftrw5KzSsc4I4GB/jXnlgpEPmwkgdx9OSD+Gf1rYufFOlaamy7uwsqY+Vcs3PsK6LJrUw1R1Wo3UljEJoozJH/Fhvu//AFqoxa4Z4d8SKWHVd54/Sudj+JdhGhSOyuZVPAzgD9e1Ostb03UL4yWSvbs/D2suMg+owcEdvyqVBXsx36nJPwFHbNR5Jl2gZOMD8aKK6OhBet49qBep6mrHmRxjLOq4GcE0UVzPc0Rn3uq2kMLATK7Z5C1ytz4juGYwwRLHjkM3JzRRWkdEJl7Q9Ykv5Xt7wLvYfKccZ965HW9LOl6rLAFIiJ3xf7p6D8On4UUVFVF03ZlNRhqnByKKKwN0OC96eOSFooqRm9pliHI3V0EdusajpgUUVhJ6l7GV4i06e9swltEz7TuYgfcHqa6jT7eRrG0jjyk8Z3RnPVuOB/ntRRXTS0gmc9V+9Y27OeTyZLycQwjeNzH5SHU85HbnP6155ewJNqF3JGP3Uk8jR+yliVH5YoorWBky1ploZ3+xtIoLHMLv2f8Auk+h6fXHvWjpMc8esQxlCkquVZWGCM8EUUVp0JP/2Q=="}}}';
                // Map<String, Object> parsedJson = (Map<String, Object>) JSON.deserializeUntyped(searalizedJson);
                // Map<String, Object> kycResponse = (Map<String, Object>) parsedJson.get('kycResponse');
                // Map<String, Object> UidData = (Map<String, Object>) kycResponse.get('UidData');
                // if(UidData != null && UidData.containsKey('Pht')){
                //     String base64Imag = (String)UidData.get('Pht');
                //     String tknStr = (String)UidData.get('tkn');
                //     if(!String.isBlank(base64Imag)){
                //         IntegrationUtilities.saveImagetoSF(base64Imag, requestWrapper.documentId, tknStr);
                //     }
                // }
                IntegrationUtilities.createIntegrationLogger( IntegrationUtilities.getPlainTextForLog(request.getBody()), request.getBody(),IntegrationUtilities.getPlainTextForLog(response.getBody()), response.getBody(), System.Label.UIDAIOTPVERIFY, elapseTime,loanAppId,System.Label.Success);
                return data = JSON.serialize(searalizedJson);
            }
            else {
                String errString = '[Status Code = '+ response.getStatusCode() +' ] Response-->'+IntegrationUtilities.getPlainTextForLog(response.getBody());
                responseBody = response.getBody();                        
				responseBody = responseBody.substring(10, responseBody.length()-2);                        
				decryptedResponse = IntegrationUtilities.getDecryptedResponse(responseBody,System.Label.privateKey,System.Label.ivkey);
				apiResponse = JSON.serializePretty(JSON.deserializeUntyped(decryptedResponse));
                IntegrationUtilities.createIntegrationLogger(IntegrationUtilities.getPlainTextForLog(request.getBody()), request.getBody(), errString, response.getBody(), System.Label.UIDAIOTPVERIFY, elapseTime, loanAppId, System.Label.Failure);
                ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'doUidaiOTPVerifyCallout', System.Label.Apex, new IND_Exception(errString), loanAppId);
                throw new IND_Exception(apiResponse);
            }      
           }
            else {
                IntegrationUtilities.createIntegrationLogger(IntegrationUtilities.getPlainTextForLog(request.getBody()),request.getBody(),  '', '', System.Label.UIDAIOTPVERIFY, elapseTime,loanAppId,System.Label.Failure);
                ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'doUidaiOTPVerifyCallout', System.Label.Apex, new IND_Exception(), loanAppId);
                throw new IND_Exception(System.Label.NoResponse);
            }           
 
        } catch(Exception ex) {
            IntegrationUtilities.createIntegrationLogger(IntegrationUtilities.getPlainTextForLog(request.getBody()),request.getBody(),  decryptedResponse, responseBody, System.Label.UIDAIOTPVERIFY, elapseTime,loanAppId,System.Label.Failure);
			ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'doUidaiOTPVerifyCallout', System.Label.Apex, ex,loanAppId);
            throw ex;
        }
    }
    
   @AuraEnabled(continuation=true cacheable=true)
public static Object doAadhaarVaultAPICallout(String leadId, String AadhaarNo, String applicantId){ 
    Continuation con;
    String loanAppId;
	String customer_Code;
    try{
        if(String.isBlank(leadId)){
            throw new IND_Exception(System.Label.Retry);
        }
        //Provide API-wise Integration Name to Custom Metadata Configs
        Integration_Configuration__mdt apiConfiguration = IntegrationUtilities.getAPIConfiguration(System.Label.GetCIBILReportAPI);
        Integer timeout = Integer.valueOf(apiConfiguration.Timeout__c);
        
        //if stubs checked in Integration_Configuration then stubs will return 
        if(apiConfiguration.IsStub_Required__c != null && apiConfiguration.IsStub_Required__c){  
            String stubData = IntegrationUtilities.getStubResponse(System.Label.AadhaarVault);
            return stubData == null ? System.Label.EmptyStubs : stubData;  
        }
        
        List<Applicant__c> appList = [Select Id, Opportunity__r.Lead_Number__c,applicant_number__c from Applicant__c where Opportunity__c =: leadId AND Id =: applicantId Limit 1];
        String docNo= '';
        if(appList.size()>0){
            docNo = applist[0].Opportunity__r.Lead_Number__c + '_' + applist[0].applicant_number__c;
        }
        
        IND_AadhaarVault_Request aadhaarVaultRequest = IND_AadhaarVault_Service.getAadhaarVault(docNo,AadhaarNo);
        CalloutProcessor processor= new CalloutProcessor(System.Label.AadhaarVault, aadhaarVaultRequest);
        HttpRequest request = processor.createHttpRequestForAadhaarVaultApi();
        Long startTime = DateTime.now().getTime();
        
        Carrier carrier = new carrier();
        carrier.setServiceName(System.Label.AadhaarVault);
        carrier.setProcessor(processor);
        carrier.setRequest(IntegrationUtilities.getPlainTextForLog(request.getBody()));
        carrier.setEncryptedRequest(request.getBody());
        carrier.setStartTime(startTime);
        carrier.setLoanApplicationId(leadId);
        
        //Add callout request to continuation
        con = new Continuation(timeout);        
        con.continuationMethod='processAadhaarVaultAPIResponse';
        con.state=carrier;
        con.addHttpRequest(request);
        
        if(Test.isRunningTest()) {
            continuationLabel = con.addHttpRequest(request);
            continuationState = carrier; 
        }  
    } catch(Exception ex) {
        ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'doAadhaarVaultAPICallout', System.Label.Apex, ex,loanAppId);
        throw ex;
    }
    return con;
}

/*
* @Method:      processAadhaarVaultAPIResponse
* @Created by:  Divya Jawale
* @Description: Method to return Response for CIBIL Report API
* @Param:       Collection - labels
* @Param:       Object - state
* @Return:      Object - response
*/
@AuraEnabled(cacheable=true)
public static Object processAadhaarVaultAPIResponse(List<String> labels, Object state){
    system.debug('processAadhaarVaultAPIResponse');
    IND_AadhaarVault_Response apiResponse;
    String request='';
    String encryptedRequest='';
    String serviceName='';
    String data='';
    HttpResponse response;
    String elapseTime='';
    List<Object> objList;
    String loanAppId='';
    
    try{
        Carrier carrier = (Carrier)state;
        request = carrier.getRequest();
        encryptedRequest = carrier.getEncryptedRequest();
        serviceName = carrier.getServiceName();
        Long startTime = carrier.getStartTime();
        //objList = carrier.getTempObject();
        CalloutProcessor processor = carrier.getProcessor();
        response = Continuation.getResponse(labels[0]);
        Long endTime = DateTime.now().getTime();
        elapseTime = String.valueOf((Double)(endTime - startTime)/1000);
        loanAppId = carrier.getLoanApplicationId();
        if(response != null && (response.getStatusCode() == 200)){
            apiResponse = (IND_AadhaarVault_Response)processor.getHttpResponse(response, serviceName);
            system.debug('apiresponse ----' + apiresponse);
            if(apiResponse!= null){
                IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, IntegrationUtilities.getPlainTextForLog(response.getBody()), response.getBody(), serviceName, elapseTime,loanAppId,System.Label.Success);
                data = JSON.serialize(apiResponse);
                system.debug('apiresponse data  ----' + data);
            }else {
                IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, IntegrationUtilities.getPlainTextForLog(response.getBody()), response.getBody(), serviceName, elapseTime,loanAppId,System.Label.Failure);
                throw new IND_Exception(System.Label.NoResponse);                
            }
        }
        else {
            String errString = '[Status Code = '+ response.getStatusCode() +' ] Response-->'+IntegrationUtilities.getPlainTextForLog(response.getBody());
            IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, errString, response.getBody(), serviceName, elapseTime, loanAppId, System.Label.Failure);
            ErrorLoggerUtil.logErrorEvent('CalloutProcessor', 'getHttpResponse', System.Label.Apex, new IND_Exception(errString), loanAppId);
            throw new IND_Exception(System.Label.NoResponse);
        } 
    } catch (Exception ex){
        String errString = '[Status Code = '+ response.getStatusCode() +' ] Response-->'+IntegrationUtilities.getPlainTextForLog(response.getBody());
        // IntegrationUtilities.createIntegrationLogger(request, encryptedRequest,'' ,'' , serviceName, elapseTime,loanAppId,System.Label.Failure);
        ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'processAadhaarVaultAPIResponse', System.Label.Apex, ex,loanAppId);
        throw new IND_Exception(ex.getMessage());
    }
    return data;
}
    
//******************Code changes directly made on SIT for the M3*************************

//******************Code modified on SIT directly for Selfie Report Async Callout**********/

/*
* @Method:      doWeightedIRRCallout
* @Created by:  Rajat Jaiswal 
* @Description: This method is being used to call the Weighted IRR API using continuation
* @Param:       String - applicantId
* @Return:      ''
*/
@AuraEnabled(continuation=true cacheable=true)
public static Object doWeightedIRRCallout(String loanAppId){
    Continuation con;
    try{
        system.debug('::doWeightedIRRCallout method is invoked.');
        //Provide API-wise Integration Name to Custom Metadata Configs
        Integration_Configuration__mdt apiConfiguration = IntegrationUtilities.getAPIConfiguration(System.Label.WeightedIRR);
        Integer timeout = Integer.valueOf(apiConfiguration.Timeout__c);
        
        //if stubs checked in Integration_Configuration then stubs will return 
        if(apiConfiguration.IsStub_Required__c != null && apiConfiguration.IsStub_Required__c){  
            String stubData = IntegrationUtilities.getStubResponse(System.Label.WeightedIRR);
            return stubData == null ? System.Label.EmptyStubs : stubData;  
        }
        // Applicant__c app = [SELECT Id,Opportunity__r.Parent_Deal_number__c,Opportunity__r.Lead_number__c FROM Applicant__c WHERE Id=:applicantId WITH SECURITY_ENFORCED];
        loanApplicationRef= loanAppId;
        User userDetails = [SELECT Id, EmployeeNumber FROM User WHERE Id =: UserInfo.getUserId() LIMIT 1];
        String empId = userDetails!=null && userDetails.EmployeeNumber!= null ? userDetails.EmployeeNumber : '';
        IND_WeightedIRRRequest WeightedIRRRequestDetails = IND_WeightedIRRService.getWeightedIRRRequest(empId, loanAppId); 
        system.debug('::WeightedIRRRequestDetails '+WeightedIRRRequestDetails);
        CalloutProcessor process = new CalloutProcessor(System.Label.WeightedIRR, WeightedIRRRequestDetails);
        HttpRequest request = process.createHttpRequest();  
        
        Long startTime = DateTime.now().getTime();
        
        Carrier carrier = new carrier();
        carrier.setServiceName(System.Label.WeightedIRR);
        carrier.setProcessor(process);
        carrier.setRequest(IntegrationUtilities.getPlainTextForLog(request.getBody()));
        carrier.setEncryptedRequest(request.getBody());
        carrier.setStartTime(startTime);
        carrier.setLoanApplicationId(loanAppId);
        
        //Add callout request to continuation
        con = new Continuation(timeout);        
        con.continuationMethod='processWeightedIRRAPIResponse';
        con.state=carrier;
        con.addHttpRequest(request);
        
        if(Test.isRunningTest()) {
           continuationLabel = con.addHttpRequest(request);
           continuationState = carrier; 
        }  
    } catch(Exception ex) {
        ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'doWeightedIRRCallout', System.Label.Apex,  ex, loanAppId);
        throw ex;
    }
    return con;
}
/*
* @Method:      processWeightedIRRAPIResponse
* @Created by:  Rajat Jaiswal
* @Description: This method is being used to handle the response from continuation and return the response to calling processes
* @Param:       Collection - labels
* @Param:       Object - state
* @Return:      Object - response
*/
@AuraEnabled(cacheable=true)
public static Object processWeightedIRRAPIResponse(List<String> labels, Object state){
    System.debug('::Inside the Weighted IRR callback');
    IND_WeightedIRRResponse apiResponse;
    String request='';
    String encryptedRequest='';
    String serviceName='';
    String data;
     String loanAppId='';
    HttpResponse response;
    String elapseTime='';
    
    try{
        Carrier carrier = (Carrier)state;
        request = carrier.getRequest();
        encryptedRequest = carrier.getEncryptedRequest();
        serviceName = carrier.getServiceName();
        Long startTime = carrier.getStartTime();
        
        CalloutProcessor processor = carrier.getProcessor();
        response = Continuation.getResponse(labels[0]);
        Long endTime = DateTime.now().getTime();
        elapseTime = String.valueOf((Double)(endTime - startTime)/1000);
        loanAppId = carrier.getLoanApplicationId();
        if(response != null && response.getStatusCode() == 200) {
            system.debug('::Inside the response method');
            apiResponse = (IND_WeightedIRRResponse)processor.getHttpResponse(response, serviceName);
            if(apiResponse != null){
                data = JSON.serialize(apiResponse);
                system.debug('data::'+data);
                IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, IntegrationUtilities.getPlainTextForLog(response.getBody()), response.getBody(), serviceName, elapseTime,loanAppId,System.Label.Success);
            } else {
                IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, '', '', serviceName, elapseTime,loanAppId,System.Label.Failure);
                throw new IND_Exception(System.Label.NoResponse);
            }
            
        } else {
            String errString = '[Status Code = '+ response.getStatusCode() +' ] Response-->'+IntegrationUtilities.getPlainTextForLog(response.getBody());
            IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, errString, response.getBody(), serviceName, elapseTime, loanAppId, System.Label.Failure);
            ErrorLoggerUtil.logErrorEvent('CalloutProcessor', 'getHttpResponse', System.Label.Apex, new IND_Exception(errString), loanAppId);
            throw new IND_Exception(System.Label.NoResponse);
        } 
        
    } catch (Exception ex){
        System.debug('callback()====catch');
        IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, '', '', serviceName, elapseTime,loanAppId,System.Label.Failure);
        ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'processWeightedIRRAPIResponse', System.Label.Apex, ex,loanAppId);
        throw new IND_Exception(ex.getMessage());
    }
    return data;
}
    /*
* @Method:      doProductivityCallout
* @Created by:  Rajat Jaiswal 
* @Description: This method is being used to call the Productivity API using continuation
* @Param:       String - applicantId
* @Return:      ''
*/
@AuraEnabled(continuation=true cacheable=true)
public static Object doProductivityCallout(String loanAppId){
    Continuation con;
    try{
        system.debug('::doProductivityCallout method is invoked.');
        //Provide API-wise Integration Name to Custom Metadata Configs
        Integration_Configuration__mdt apiConfiguration = IntegrationUtilities.getAPIConfiguration(System.Label.Productivity);
        Integer timeout = Integer.valueOf(apiConfiguration.Timeout__c);
        
        //if stubs checked in Integration_Configuration then stubs will return 
        if(apiConfiguration.IsStub_Required__c != null && apiConfiguration.IsStub_Required__c){  
            String stubData = IntegrationUtilities.getStubResponse(System.Label.Productivity);
            return stubData == null ? System.Label.EmptyStubs : stubData;  
        }
        loanApplicationRef= loanAppId;
        User userDetails = [SELECT Id, EmployeeNumber FROM User WHERE Id =: UserInfo.getUserId() LIMIT 1];
        String empId = userDetails!=null && userDetails.EmployeeNumber!= null ? userDetails.EmployeeNumber : '';
        IND_ProductivityRequest ProductivityRequestDetails = IND_ProductivityService.getProductivityRequest(empId, loanAppId); 
        system.debug('::ProductivityRequestDetails '+ProductivityRequestDetails);
        CalloutProcessor process = new CalloutProcessor(System.Label.Productivity, ProductivityRequestDetails);
        HttpRequest request = process.createHttpRequest();  
        
        Long startTime = DateTime.now().getTime();
        
        Carrier carrier = new carrier();
        carrier.setServiceName(System.Label.Productivity);
        carrier.setProcessor(process);
        carrier.setRequest(IntegrationUtilities.getPlainTextForLog(request.getBody()));
        carrier.setEncryptedRequest(request.getBody());
        carrier.setStartTime(startTime);
        carrier.setLoanApplicationId(loanAppId);
        
        //Add callout request to continuation
        con = new Continuation(timeout);        
        con.continuationMethod='processProductivityAPIResponse';
        con.state=carrier;
        con.addHttpRequest(request);
        
        if(Test.isRunningTest()) {
           continuationLabel = con.addHttpRequest(request);
           continuationState = carrier; 
        }  
    } catch(Exception ex) {
        ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'doProductivityCallout', System.Label.Apex,  ex, loanAppId);
        throw ex;
    }
    return con;
}
/*
* @Method:      processProductivityAPIResponse
* @Created by:  Rajat Jaiswal
* @Description: This method is being used to handle the response from continuation and return the response to calling processes
* @Param:       Collection - labels
* @Param:       Object - state
* @Return:      Object - response
*/
@AuraEnabled(cacheable=true)
public static Object processProductivityAPIResponse(List<String> labels, Object state){
    System.debug('::Inside the Weighted IRR callback');
    IND_ProductivityResponse apiResponse;
    String request='';
    String encryptedRequest='';
    String serviceName='';
    String data;
     String loanAppId='';
    HttpResponse response;
    String elapseTime='';
    
    try{
        Carrier carrier = (Carrier)state;
        request = carrier.getRequest();
        encryptedRequest = carrier.getEncryptedRequest();
        serviceName = carrier.getServiceName();
        Long startTime = carrier.getStartTime();
        
        CalloutProcessor processor = carrier.getProcessor();
        response = Continuation.getResponse(labels[0]);
        Long endTime = DateTime.now().getTime();
        elapseTime = String.valueOf((Double)(endTime - startTime)/1000);
        loanAppId = carrier.getLoanApplicationId();
        if(response != null && response.getStatusCode() == 200) {
            system.debug('::Inside the response method');
            apiResponse = (IND_ProductivityResponse)processor.getHttpResponse(response, serviceName);
            if(apiResponse != null){
                data = JSON.serialize(apiResponse);
                system.debug('data::'+data);
                IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, IntegrationUtilities.getPlainTextForLog(response.getBody()), response.getBody(), serviceName, elapseTime,loanAppId,System.Label.Success);
            } else {
                IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, '', '', serviceName, elapseTime,loanAppId,System.Label.Failure);
                throw new IND_Exception(System.Label.NoResponse);
            }
            
        } else {
            String errString = '[Status Code = '+ response.getStatusCode() +' ] Response-->'+IntegrationUtilities.getPlainTextForLog(response.getBody());
            IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, errString, response.getBody(), serviceName, elapseTime, loanAppId, System.Label.Failure);
            ErrorLoggerUtil.logErrorEvent('CalloutProcessor', 'getHttpResponse', System.Label.Apex, new IND_Exception(errString), loanAppId);
            throw new IND_Exception(System.Label.NoResponse);
        } 
        
    } catch (Exception ex){
        System.debug('callback()====catch');
        IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, '', '', serviceName, elapseTime,loanAppId,System.Label.Failure);
        ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'processProductivityAPIResponse', System.Label.Apex, ex,loanAppId);
        throw new IND_Exception(ex.getMessage());
    }
    return data;
}

/*
* @Method:      doPincodeBasedSearchCallout
* @Created by:  Utkarsh Maurya
* @Description: Method to callout pincode based search API
* @Param:       String - pincode
* @Param:       String - loanAppId
* @Param:       String - applicantId
* @Return:      Object - response
*/
@AuraEnabled(continuation=true)
public static String doPincodeBasedSearchCallout(String pincode , String loanAppId , String applicantId){
    PincodeBasedSearchResponse responseWrapper = new PincodeBasedSearchResponse(); 
    try {
        Integration_Configuration__mdt apiConfiguration = IntegrationUtilities.getAPIConfiguration(System.Label.GetPincodeBaseSearch);
        if(apiConfiguration != null){
            if(!apiConfiguration.IsActive_Integration__c){
                ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'getPincodeBasedSearchSFTractor', System.Label.Apex, new AuraHandledException('Integration is not Active'));
                throw new AuraHandledException('Integration is not Active');       
            }
            String methodType = apiConfiguration.Rest_Method__c.trim();
            String endpoint ='callout:Indus_API'+apiConfiguration.Endpoint_URL__c.trim();
            String requestToEncrypt = '{"Pincode":"'+pincode+'"}';
            String encryptedRequest = IntegrationUtilities.getEncryptedRequest(requestToEncrypt,System.Label.privateKey,System.Label.ivkey);
            
            HttpRequest httpRequest = new HttpRequest();
            httpRequest.setMethod(methodType);
            httpRequest.setEndpoint(endpoint);
            httpRequest.setHeader('IBL-Client-Id',System.Label.IBM_Client_ID);
            httpRequest.setHeader('IBL-Client-Secret',System.Label.IBM_Client_Secret);
            httpRequest.setHeader('Content-Type', 'application/json');
            httpRequest.setHeader('Accept', 'application/json');
            httpRequest.setBody('{"JData": "'+encryptedRequest+'"}');
            httpRequest.setTimeout(120000);
            Http http = new Http();
            HttpResponse response = http.send(httpRequest);
            Map<String , Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            String responseBody = (String) responseMap.get('JData');
            String decryptedResponse = IntegrationUtilities.getDecryptedResponse(responseBody,System.Label.privateKey,System.Label.ivkey);
            System.debug('decryptedResponse ' +decryptedResponse);
            Map<String , Object> decryptedResponseMap = (Map<String, Object>) JSON.deserializeUntyped(decryptedResponse);
            if(((Map<String , Object>)decryptedResponseMap.get('response')).get('content') != ''){
                responseWrapper = (PincodeBasedSearchResponse) JSON.deserialize(JSON.serialize(decryptedResponseMap.get('response')), PincodeBasedSearchResponse.class);
                System.debug('decrypted Response '+responseWrapper);
    
                if(responseWrapper.status == 'SUCCESS' && responseWrapper.content.size()>0){
                    IntegrationUtilities.createIntegrationLogger(requestToEncrypt, encryptedRequest, IntegrationUtilities.getPlainTextForLog(response.getBody()), response.getBody(), 'Pincode Search', '',loanAppId,System.Label.Success);
                   IntegrationEngine.createReferenceCustomers(responseWrapper, loanAppId, applicantId);
                    return 'SUCCESS';
                }
                else{
                    IntegrationUtilities.createIntegrationLogger(requestToEncrypt, encryptedRequest, IntegrationUtilities.getPlainTextForLog(response.getBody()), response.getBody(), 'Pincode Search', '',loanAppId,System.Label.Failure);
                    return responseWrapper.respDesc;
                }
            }
            else{
                IntegrationUtilities.createIntegrationLogger(requestToEncrypt, encryptedRequest, IntegrationUtilities.getPlainTextForLog(response.getBody()), response.getBody(), 'Pincode Search', '',loanAppId,System.Label.Failure);
                return 'Incorrect Pincode';
            }
        }
        return null;
    } catch (Exception ex) {
        ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'doPincodeBasedSearchCallout', System.Label.Apex, ex,loanAppId);
        System.debug('Error '+ex.getMessage() +' at line '+ex.getLineNumber());
        throw new IND_Exception(ex.getMessage());   
    }
}
/*
* @Method:      createReferenceCustomers
* @Created by:  Utkarsh Maurya
* @Description: To create customer reference record and relate with applicant
* @Param:       Object - responseWrapper
* @Param:       String - loanAppId
* @Param:       String - applicantId
* @Return:      Object - response
*/
public static void createReferenceCustomers(PincodeBasedSearchResponse responseWrapper , String loanAppId , String applicantId){
    List<Customer_Reference__c> customerReferenceList = new List<Customer_Reference__c>();
    for(PincodeBasedSearchResponse.CustomerInfo content : responseWrapper.content){
        Customer_Reference__c custRef = new Customer_Reference__c();
        custRef.Name = content.Customer_Name;
        custRef.Surname__c = content.SurName;
        custRef.Customer_Code__c = content.Customer_Code;
        custRef.Phone__c = content.Mobile_Number;
        custRef.Product__c = content.Product;
        custRef.State__c = content.State;
        custRef.District__c = content.District;
        custRef.City__c = content.City;
        custRef.AddressFlag__c = content.Address_Flag;
        custRef.AddressLine1__c = content.Address_Line_1;
        custRef.AddressLine2__c = content.Address_Line_2;
        custRef.AddressLine3__c = content.Address_Line_3;
        custRef.AddressLine4__c = content.Address_Line_4;
        custRef.Landmark__c = content.Landmark;
        custRef.Exposure__c = content.Exposure;
        custRef.Loan_Application__c = loanAppId;
        custRef.Maker_Date__c = content.Maker_Date;
        custRef.Applicant__c = applicantId;
        customerReferenceList.add(custRef);
    }
    insert customerReferenceList;
}
@AuraEnabled(continuation=true)
public static Object doReferenceAndRelationAPICallout(String leadId,String vehicleId){
    
    Continuation con;
    String loanAppId;
	String customer_Code;
    try{
        if(String.isBlank(leadId)){
            throw new IND_Exception(System.Label.Retry);
        }
        //Provide API-wise Integration Name to Custom Metadata Configs
        Integration_Configuration__mdt apiConfiguration = IntegrationUtilities.getAPIConfiguration(System.Label.Reference_And_Relation_Master_Creation);
        Integer timeout = Integer.valueOf(apiConfiguration.Timeout__c);
        
        //if stubs checked in Integration_Configuration then stubs will return 
        if(apiConfiguration.IsStub_Required__c != null && apiConfiguration.IsStub_Required__c){  
            String stubData = IntegrationUtilities.getStubResponse(System.Label.Reference_And_Relation_Master_Creation);
            return stubData == null ? System.Label.EmptyStubs : stubData;  
        }
        
        IND_ReferenceAndRelationMasterRequest referenceAndRealtionRequest = IND_ReferenceAndRelationMasterService.getReferenceAndRelationMasterRequest(leadId,vehicleId);
        CalloutProcessor processor= new CalloutProcessor(System.Label.Reference_And_Relation_Master_Creation, referenceAndRealtionRequest);
        HttpRequest request = processor.createHttpRequest();
        system.debug('Resquest--' + request);
        Long startTime = DateTime.now().getTime();
        
        Carrier carrier = new carrier();
        carrier.setServiceName(System.Label.Reference_And_Relation_Master_Creation);
        carrier.setProcessor(processor);
        carrier.setRequest(IntegrationUtilities.getPlainTextForLog(request.getBody()));
        carrier.setEncryptedRequest(request.getBody());
        carrier.setStartTime(startTime);
        carrier.setLoanApplicationId(leadId);
        
        //Add callout request to continuation
        con = new Continuation(timeout);        
        con.continuationMethod='processReferenceAndRelationAPIResponse';
        con.state=carrier;
        con.addHttpRequest(request);
        
        if(Test.isRunningTest()) {
            continuationLabel = con.addHttpRequest(request);
            continuationState = carrier; 
        }  
    } catch(Exception ex) {
        ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'doReferenceAndRelationAPICallout', System.Label.Apex, ex,leadId);
        throw ex;
    }
    return con;
}
@AuraEnabled
public static Object processReferenceAndRelationAPIResponse(List<String> labels, Object state){
    system.debug('processReferenceAndRelationAPIResponse');
    IND_ReferenceAndRelationMasterResponse apiResponse;
    String request='';
    String encryptedRequest='';
    String serviceName='';
    String data='';
    HttpResponse response;
    String elapseTime='';
    List<Object> objList;
    String loanAppId='';
    
    try{
        Carrier carrier = (Carrier)state;
        request = carrier.getRequest();
        encryptedRequest = carrier.getEncryptedRequest();
        serviceName = carrier.getServiceName();
        Long startTime = carrier.getStartTime();
        //objList = carrier.getTempObject();
        CalloutProcessor processor = carrier.getProcessor();
        response = Continuation.getResponse(labels[0]);
        Long endTime = DateTime.now().getTime();
        elapseTime = String.valueOf((Double)(endTime - startTime)/1000);
        loanAppId = carrier.getLoanApplicationId();
        if(response != null && (response.getStatusCode() == 200)){
            apiResponse = (IND_ReferenceAndRelationMasterResponse)processor.getHttpResponse(response, serviceName);
            system.debug('apiresponse ----' + apiresponse);
            if(apiResponse!= null){
                IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, IntegrationUtilities.getPlainTextForLog(response.getBody()), response.getBody(), serviceName, elapseTime,loanAppId,System.Label.Success);
                data = JSON.serialize(apiResponse);
                system.debug('apiresponse data  ----' + data);
            }else {
                IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, IntegrationUtilities.getPlainTextForLog(response.getBody()), response.getBody(), serviceName, elapseTime,loanAppId,System.Label.Failure);
                throw new IND_Exception(System.Label.NoResponse);                
            }
        }
        else {
            String errString = '[Status Code = '+ response.getStatusCode() +' ] Response-->'+IntegrationUtilities.getPlainTextForLog(response.getBody());
            IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, errString, response.getBody(), serviceName, elapseTime, loanAppId, System.Label.Failure);
            ErrorLoggerUtil.logErrorEvent('CalloutProcessor', 'getHttpResponse', System.Label.Apex, new IND_Exception(errString), loanAppId);
            throw new IND_Exception(System.Label.NoResponse);
        } 
    } catch (Exception ex){
        String errString = '[Status Code = '+ response.getStatusCode() +' ] Response-->'+IntegrationUtilities.getPlainTextForLog(response.getBody());
        IntegrationUtilities.createIntegrationLogger(request, encryptedRequest,'' ,'' , serviceName, elapseTime,loanAppId,System.Label.Failure);
        ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'processReferenceAndRelationAPIResponse', System.Label.Apex, ex,loanAppId);
        throw new IND_Exception(ex.getMessage());
    }
    return data;
}
    /*
    * @Method:      doPennyDropAPICallout
    * @Created by:  Utkarsh Maurya
    * @Description: Method to callout penny drop API
    * @Param:       String - Request body
    * @Return:      wrapper - PennyDropAPIResponse
    */
    @AuraEnabled
    public static PennyDropAPIResponse doPennyDropAPICallout(String requestBody, String loanAppId){
        PennyDropAPIResponse responseWrapper = new PennyDropAPIResponse(); 
        try {
            if(!String.isBlank(requestBody)){
                Map<String, Object> requestBodyMap = (Map<String, Object>) JSON.deserializeUntyped(requestBody);

                Integration_Configuration__mdt apiConfiguration = IntegrationUtilities.getAPIConfiguration(System.Label.PennyDropAPI);
                if(apiConfiguration != null){

                    if(!apiConfiguration.IsActive_Integration__c){
                        ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'doPennyDropAPICallout', System.Label.Apex, new AuraHandledException('Integration is not Active'));
                        throw new AuraHandledException('Integration is not Active');       
                    }
                    if(apiConfiguration.isSync__c){
                        ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'doPennyDropAPICallout', System.Label.Apex, new IND_Exception('Integration is not Async API'));
                        throw new IND_Exception('Integration is not Async API');       
                    }

                    String methodType = apiConfiguration.Rest_Method__c.trim();
                    String endpoint = 'callout:Indus_API' + apiConfiguration.Endpoint_URL__c.trim();
                    String setTimeout = String.valueOf(apiConfiguration.Timeout__c);

                    JSONGenerator gen = JSON.createGenerator(true);
                    gen.writeStartObject();
                    gen.writeStringField('BeneficiaryName', (String)requestBodyMap.get('BeneficiaryName') !=null ? (String)requestBodyMap.get('BeneficiaryName') : '');
                    gen.writeStringField('CreditAccountNumber', (String)requestBodyMap.get('CreditAccountNumber') !=null ? (String)requestBodyMap.get('CreditAccountNumber') : '');
                    gen.writeStringField('BeneficiaryBankIFSCCode', (String)requestBodyMap.get('BeneficiaryBankIFSCCode') !=null ? (String)requestBodyMap.get('BeneficiaryBankIFSCCode') : '');
                    gen.writeStringField('BeneficiaryMobileNumber', (String)requestBodyMap.get('BeneficiaryMobileNumber') != null ? (String)requestBodyMap.get('BeneficiaryMobileNumber') : '');
                    gen.writeStringField('EmailID', (String)requestBodyMap.get('EmailID') != null ? (String)requestBodyMap.get('EmailID') : '');
                    gen.writeStringField('CustomerCode', (String)requestBodyMap.get('CustomerCode') != null ? (String)requestBodyMap.get('CustomerCode') : '');
                    gen.writeStringField('DealNo', (String)requestBodyMap.get('DealNo') != null ? (String)requestBodyMap.get('DealNo') : '');
                    gen.writeStringField('MakerId', (String)requestBodyMap.get('MakerId') != null ? (String)requestBodyMap.get('MakerId') : '');
                    gen.writeEndObject();
                    String requestJSON = gen.getAsString(); 
                    String encryptedRequest = IntegrationUtilities.getEncryptedRequest(gen.getAsString(), System.Label.privateKey, System.Label.ivkey);

                    HttpRequest httpRequest = new HttpRequest();
                    Long startTime = DateTime.now().getTime();
                    httpRequest.setMethod(methodType);
                    httpRequest.setEndpoint(endpoint);
                    httpRequest.setTimeout((String.isNotBlank(setTimeout) && !String.isEmpty(setTimeout)) ? Integer.valueOf(setTimeout) : 120000);
                    httpRequest.setHeader('IBL-Client-Id', System.Label.IBM_Client_ID);
                    httpRequest.setHeader('IBL-Client-Secret', System.Label.IBM_Client_Secret);
                    httpRequest.setHeader('Content-Type', 'application/json');
                    httpRequest.setBody('{"JData": "'+encryptedRequest+'"}');
                    Http http = new Http();
                    HttpResponse response = http.send(httpRequest);
                    Long endTime = DateTime.now().getTime();
                    String elapseTime = String.valueOf((Double)(endTime - startTime)/1000);
                    Map<String , Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());

                    String responseBody = (String) responseMap.get('JData');

                    String decryptedResponse = IntegrationUtilities.getDecryptedResponse(responseBody, System.Label.privateKey, System.Label.ivkey);

                    Map<String , Object> decryptedResponseMap = (Map<String, Object>) JSON.deserializeUntyped(decryptedResponse);
                    if(response.getStatusCode() == 200){
                        IntegrationUtilities.createIntegrationLogger(requestJSON, encryptedRequest, decryptedResponse, responseBody, System.Label.PennyDropAPI, elapseTime, loanAppId, System.Label.Success);
                        } 
                    else 
                        {
                         IntegrationUtilities.createIntegrationLogger(requestJSON, encryptedRequest, '', '', System.Label.PennyDropAPI, elapseTime, loanAppId, System.Label.Failure);
                        }
                    if(((Map<String , Object>)decryptedResponseMap.get('response')).get('content') != ''){
                        responseWrapper = (PennyDropAPIResponse) JSON.deserialize(JSON.serialize(decryptedResponseMap.get('response')), PennyDropAPIResponse.class);
                        
                        return responseWrapper;
                    }
                    else{
                        responseWrapper.errorMessage = 'Invalid Response';
                        return responseWrapper;
                    }
                }
                return responseWrapper;
            } 
            return responseWrapper;
        } catch (Exception ex) {
            ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'doPincodeBasedSearchCallout', System.Label.Apex, ex, loanAppId);
            throw new IND_Exception(ex.getMessage());   
        }
    }

    public class PennyDropAPIResponse {
        @auraEnabled 
        public string status{get;set;}
        @auraEnabled 
        public string respDesc{get;set;}
        @auraEnabled 
        public List<Content> content{get;set;}
        @AuraEnabled
        public string errorMessage{get;set;}
    }

    public class Content {
        @auraEnabled 
		public String IBLRefNo{get;set;}
        @auraEnabled 
		public String CustomerRefNo{get;set;}
        @auraEnabled 
		public String Amount{get;set;}
        @auraEnabled 
		public String StatusCode{get;set;}
        @auraEnabled 
		public String StatusDesc{get;set;}
        @auraEnabled 
		public String UTRNo{get;set;}
        @auraEnabled 
		public String BeneficiaryName{get;set;}
        @auraEnabled 
		public String TranType{get;set;}
	}

    /*//SFTRAC-31 Starts
* @Method:      doTractorVehicleDedupeCallout
* @Created by:  Aakash J.
* @Description: Method to call Vehicle Dedupe API for Tractor Dedupe function
* @Param:       String - Vehicle detail engine_No, chassis_No, serial_No, subType, loanAppId, vehicleType
* @Return:      return a string based on Response
*/
    
@AuraEnabled(continuation=true)
    public static String doTractorVehicleDedupeCallout(String engine_No , String chassis_No, String serial_No, String subType, 
                                                       String loanAppId, String vehicleType ){
        String requestBody ='';  
        String requestBodyJSON = ''; 
        String elapseTime = '';                                             
        try { 
            String serviceName = 'Tractor Vehicle Dedupe';
            
            Opportunity loanApplicationRec = [Select Id, StageName, Sub_Stage__c, View_Application_Sub_Stages__c, 
                                              Deviation_Required__c From Opportunity Where Id =: loanAppId];
            system.debug('++++loanApplicationRec '+loanApplicationRec);
            system.debug('++++engine_No '+engine_No+'++++chassis_No '+chassis_No+'++++serial_No '+serial_No+'++++subType '+subType+'++++loanAppId '+loanAppId);
            String returnString = '';
            String uniqueServiceName = engine_No+'-'+chassis_No+'-'+serial_No+'-'+subType;
            System.debug('doTractorVehicleDedupeCallout uniqueServiceName : '+uniqueServiceName);
            Integration_Configuration__mdt apiConfiguration = IntegrationUtilities.getAPIConfiguration('Tractor Vehicle Dedupe'); //Create custom label for this
            if(apiConfiguration != null){
                Http http = new Http();
                HttpRequest request = new HttpRequest();
                HttpResponse response = new HttpResponse();
                
                if(!apiConfiguration.IsActive_Integration__c){
                    ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'doTractorVehicleDedupeCallout', System.Label.Apex, new AuraHandledException('Integration is not Active'));
                    throw new AuraHandledException('Integration is not Active');       
                }
                String methodType = apiConfiguration.Rest_Method__c.trim();
                //String endpoint =apiConfiguration.Endpoint_URL__c;
                String endpoint ='callout:Indus_API'+apiConfiguration.Endpoint_URL__c.trim();
                //String requestBody ='';
                requestBody = '{"Engine_No": "'+engine_No+'",';
                if(subType == 'Implements'){
                    requestBody += '"Serial_No": "'+serial_No+'"}';
                }else{
                	requestBody += '"Chassis_No": "'+chassis_No+'"}';   	
                }
                system.debug('++++requestBody '+requestBody);
                String encryptedRequestBody = IntegrationUtilities.getEncryptedRequest(requestBody,System.Label.privateKey,System.Label.ivkey); 
                Map<String, String> requestData = new Map<String, String>();
                requestData.put('JData', encryptedRequestBody);
                //String requestBodyJSON = JSON.serialize(requestData);
                requestBodyJSON = JSON.serialize(requestData);
                system.debug('++++requestBodyJSON '+requestBodyJSON);
                Long startTime = DateTime.now().getTime();
                request.setMethod(methodType);
                request.setEndpoint(endpoint);
                request.setHeader('IBL-Client-Id',System.Label.IBM_Client_ID);
                request.setHeader('IBL-Client-Secret',System.Label.IBM_Client_Secret);
                request.setHeader('Content-Type', 'application/json');
                request.setBody(requestBodyJSON);
                
                response = http.send(request); 
                Long endTime = DateTime.now().getTime();
                elapseTime = String.valueOf((Double)(endTime - startTime)/1000);
                System.debug('++++ getStatusCode' +response.getStatusCode()+'+getStatus ' +response.getStatus()+'+getBody ' +response.getBody());
                String responseBody = response.getBody();
                responseBody = responseBody.substring(10, responseBody.length()-2);
                String decryptedResponse = IntegrationUtilities.getDecryptedResponse(responseBody,System.Label.privateKey,System.Label.ivkey);
                System.debug('++++ decryptedResponse ' +decryptedResponse); 
                
                Map<String , Object> decryptedResponseMap = (Map<String, Object>) JSON.deserializeUntyped(decryptedResponse);
                
                if (response.getStatusCode() == 200) {
                    Integer isAssetFound = Integer.valueOf((String)((Map<String, Object>)((List<Object>)((Map<String, Object>)decryptedResponseMap.get('response')).get('content'))[0]).get('IsAssetFound'));
                    System.debug('++++ isAssetFound ' +isAssetFound);
                    if(isAssetFound >= 1){
                        System.debug('++++ isAssetFound ');
                        
                        if(loanApplicationRec.StageName =='Credit Processing' && 
                           loanApplicationRec.Sub_Stage__c =='View Application Details' && 
                           loanApplicationRec.View_Application_Sub_Stages__c =='Lead/KYC Details' && 
                           loanApplicationRec.StageName != 'Journey Stop' && vehicleType == 'New'){
                               loanApplicationRec.StageName = 'Journey Stop'; 
                               update loanApplicationRec;
                               returnString = 'journeystop';
                           }else{
                               returnString = 'yes';
                           }
                        if(vehicleType == 'Used' || vehicleType == 'Refinance' && loanApplicationRec.Deviation_Required__c == false){
                            loanApplicationRec.Deviation_Required__c = true;
                            update loanApplicationRec;
                        }
                    }else if(isAssetFound == 0){
                        System.debug('++++ isAssetFound not ');
                        returnString = 'no';
                    }

                    if(response != null && response.getStatus() == 'OK'){
                        //data= 'Success';
                        IntegrationUtilities.createIntegrationLogger(requestBody, requestBodyJSON, IntegrationUtilities.getPlainTextForLog(response.getBody()), response.getBody(), serviceName, elapseTime, loanAppId, System.Label.Success);
                    } else {
                        //data= 'FAIL';
                        IntegrationUtilities.createIntegrationLogger(requestBody, requestBodyJSON, '', '', serviceName, elapseTime, loanAppId, System.Label.Failure);
                    }

                }else if(response.getStatusCode() == 400) {
                    
                    String retryCountStr = lWC_LOS_TractorVehicleDedupeCntrl.updateVehicleDedupeRetryCount(uniqueServiceName, loanAppId);
                    System.debug('++++ retryCountStr '+retryCountStr);
                    if(retryCountStr != System.Label.Retry_Exhausted){
                        returnString = 'retry';
                    }else{
                        returnString = System.Label.Retry_Exhausted;
                    }
                String errString = '[Status Code = '+ response.getStatusCode() +' ] Response-->'+IntegrationUtilities.getPlainTextForLog(response.getBody());
                IntegrationUtilities.createIntegrationLogger(requestBody, requestBodyJSON, errString, response.getBody(), serviceName, elapseTime, loanAppId, System.Label.Failure);
                }         
            }
            return returnString;
        }catch (Exception ex) {
            IntegrationUtilities.createIntegrationLogger(requestBody, requestBodyJSON, '', '', serviceName, elapseTime, loanAppId, System.Label.Failure);
            ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'doTractorVehicleDedupeCallout', System.Label.Apex, ex);
            System.debug('Error '+ex.getMessage() +' at line '+ex.getLineNumber());
            throw new IND_Exception(ex.getMessage());   
        }
    }    
/*
* @Method:      cRIFFAPICall
* @Created by:  Aakash J.
* @Description: Method to call CRIFF API for Tractor Dedupe function
* @Param:       String - Vehicle detail
* @Return:      return a string based on Response
*/
    @AuraEnabled
    public static String cRIFFAPICall(string loanAppId, string applicantId){
        system.debug('++++ cRIFFAPICall loanAppId '+loanAppId +' applicantId '+applicantId);
        String requestBody ='';  
        String requestBodyJSON = ''; 
        String elapseTime = '';
        String returnStr ='';
        
        try{
            String serviceName = 'CRIFF Report API';
            String pANNumberStr ='';
            String cINNumberStr ='';
            String aDDRESSLINE ='';
            String localityStr ='';
            String cityStr ='';
            String stateStr ='';
            String pinStr ='';
            String loanType ='';
            String entityType ='';
            String classOfActivity ='';

            Integration_Configuration__mdt apiConfiguration = IntegrationUtilities.getAPIConfiguration('CRIFF Report API');
            if(apiConfiguration != null){
                if(!apiConfiguration.IsActive_Integration__c){
                    ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'CRIFF Report API', System.Label.Apex, new AuraHandledException('Integration is not Active'));
                    throw new AuraHandledException('Integration is not Active');       
                }
                Applicant__c app = [SELECT Id,Contact_number__c,CIC_No__c,Opportunity__r.Lead_number__c,Opportunity__r.Agent_BL_code__c,Customer_First_Name__c,Opportunity__r.Loan_amount__c,
                                Customer_Last_Name__c,Loan_Amount__c,Current_Same_As_Permanent__c,Is_Existing_Customer__c,Applicant_Type__c,Name,
                                Opportunity__r.Product_Type__c,Father_s_name__c,Mother_s_name__c,Spouse_Name__c,Email_Id__c, Opportunity__r.Name,
                                Opportunity__r.Class_of_Activity__c, Opportunity__r.Loan_Type__c,  Opportunity__r.Entity_Type__c,
                                Opportunity__r.account.name, applicant_number__c, Opportunity__r.Entity_Code__c FROM Applicant__c WHERE Id=:applicantId AND Applicant_Type__c ='Borrower' WITH SECURITY_ENFORCED LIMIT 1];

                List<TBM_CRIF_Class_of_Activity__c> masterClassofActivityList = [SELECT Id, Name, Code__c, Value__c FROM TBM_CRIF_Class_of_Activity__c];
                //List<TBM_CRIF_Loan_Type__c> masterLoanTypeList = [SELECT Id, Name, Loan_Code__c, Loan_Type__c FROM TBM_CRIF_Loan_Type__c];

                for(TBM_CRIF_Class_of_Activity__c masterCOARec: masterClassofActivityList){
                    if(String.isBlank(loanType) && masterCOARec.Value__c.toUppercase() == app.Opportunity__r.Class_of_Activity__c.toUppercase()){ 
                        classOfActivity = String.valueOf(masterCOARec.Code__c);
                    }
                }

                /*for(TBM_CRIF_Loan_Type__c masterLTRec: masterLoanTypeList){
                    if(String.isBlank(loanType) && masterLTRec.Loan_Type__c.toUppercase() == app.Opportunity__r.Loan_Type__c.toUppercase() ){ 
                        loanType = masterLTRec.Loan_Code__c;
                    }
}*/
                if(String.isBlank(loanType)){
                    loanType = app.Opportunity__r.Loan_Type__c;
                }
                if(String.isBlank(entityType)){
                    entityType = app.Opportunity__r.Entity_Type__c;
                }
                
                List<Documents__c> docs = [SELECT Id,Document_Type__c,KYC_DOB__c,Gender__c,KYC_Address_Line_1__c,KYC_Address_Line_2__c,KYC_City__c,
                                KYC_State__c,KYC_Pin_Code__c,Salutation__c,PAN_No__c,Passport_No__c,KYC_No__c,KYC_name__c,Proof_of_Identity_POI__c,recordtype.name , CIN_No__c //SFTRAC-458  
                                FROM Documents__c WHERE Applicant__c=:applicantId AND Is_Active__c = true WITH SECURITY_ENFORCED];
                
                for(Documents__c doc:docs){
                    
                        if((doc.Document_Type__c == System.Label.PanCard && String.isBlank(pANNumberStr))){
                            pANNumberStr =  doc.PAN_No__c != null ? IntegrationUtilities.getDecryptedResponse(doc.PAN_No__c,System.Label.privateKey,System.Label.ivkey) : '';
                        }

                    if( (doc.Document_Type__c == System.Label.GST_CERT) || (entityType == 'Business Entities Created by Statute' || entityType == 'Proprietorship')){  
                        
                        if(String.isBlank(aDDRESSLINE)){ 
                            aDDRESSLINE = doc.KYC_Address_Line_1__c != null ? doc.KYC_Address_Line_1__c.toUppercase() : '' ;
                            aDDRESSLINE += doc.KYC_Address_Line_2__c != null ? doc.KYC_Address_Line_2__c.toUppercase() :'' ;
                        }
    
                        if(String.isBlank(cityStr)){   
                            cityStr = doc.KYC_City__c != null ? doc.KYC_City__c:'';
                            localityStr = cityStr;
                        }
                        if(String.isBlank(stateStr)){ 
                            stateStr = doc.KYC_State__c != null ? doc.KYC_State__c :'';
                        }
                        if(String.isBlank(pinStr)){  
                            pinStr = doc.KYC_Pin_Code__c != null ? doc.KYC_Pin_Code__c :'';
                        }
                    }
                    if(doc.Document_Type__c==System.Label.CIN_CERT){
                        cINNumberStr = doc.CIN_No__c != null ? IntegrationUtilities.getDecryptedResponse(doc.CIN_No__c,System.Label.privateKey,System.Label.ivkey) : '';
                    }
                }

                List<Geo_State_Masters__c> stateList = [SELECT Id,Name, NeSL_State_Code__c, State_Code__c  FROM Geo_State_Masters__c WHERE Name=:stateStr LIMIT 1];
				String stateCode = stateList.size() != 0 ? stateList[0].NeSL_State_Code__c : '';

                Http http = new Http();
                HttpRequest request = new HttpRequest();
                HttpResponse response = new HttpResponse();

                String methodType = apiConfiguration.Rest_Method__c.trim();
                //String endpoint =apiConfiguration.Endpoint_URL__c;
                String endpoint ='callout:Indus_API'+apiConfiguration.Endpoint_URL__c.trim();   //Change Aakash
                String responseBody ='';
                String uniqueRefNo ='';
                //String requestBody =''; requestBody = '{"Engine_No":"'+engine_No+'"}'; IntegrationUtilities.getCicNo(); IND_CIBILRequest U50403MP2018PTC046511

                requestBody = '{"Application_Id": "'+app.Opportunity__r.Name+'",';
                requestBody += '"Login_userid": "'+IntegrationUtilities.getMakerId()+'",';
                requestBody += '"CIC_No": "'+IntegrationUtilities.getCicNo()+'",';
                requestBody += '"BORROWERNAME": "'+app.Name+'",';
                requestBody += '"BORROWERSHORTNAME": "'+app.Name+'",';
                requestBody += '"LEGALCONSTITUTION": "'+app.Opportunity__r.Entity_Code__c+'",';//SFTRAC-65 added in later stage
                requestBody += '"PAN": "'+pANNumberStr+'",';
                requestBody += '"CIN":  "'+cINNumberStr+'",';
                requestBody += '"CLASSOFACTIVITY1": "'+classOfActivity+'",';
                requestBody += '"ADDRESSLINE": "'+aDDRESSLINE+'",';
                requestBody += '"LOCALITY": "'+localityStr+'",';
                requestBody += '"CITY": "'+cityStr+'",';
                requestBody += '"STATE": "'+stateCode+'",';
                //requestBody += '"STATE": "TN",'; 
                requestBody += '"PIN": "'+pinStr+'",';
                requestBody += '"Customer_Id": "",';
                requestBody += '"STD_1": "",';
                requestBody += '"Phone_1": "'+app.Contact_number__c+'",'; 
                requestBody += '"Loan_Type": "'+loanType+'",';
                requestBody += '"Loan_Amount": "'+app.Opportunity__r.Loan_amount__c+'",';  
                requestBody += '"DUNS": "",';
                requestBody += '"State_Name": "'+stateStr+'",';
                requestBody += '"Source": "Salesforce"}';
                system.debug('++++requestBody '+requestBody);
                String encryptedRequestBody = IntegrationUtilities.getEncryptedRequest(requestBody,System.Label.privateKey,System.Label.ivkey);  
                Map<String, String> requestData = new Map<String, String>();
                requestData.put('JData', encryptedRequestBody);
                //String requestBodyJSON = JSON.serialize(requestData);
                requestBodyJSON = JSON.serialize(requestData);
                system.debug('++++requestBodyJSON '+requestBodyJSON);  

                Long startTime = DateTime.now().getTime();
                //String requestBody ='{"JData": "wQqumuOQgQP0Y53FIBa5QyBzQwK9+v0QarLsXBDZ7bftSFakfMsj+3u/pwu7UvU/BycqBjsGAVxurCYzIes7abv77AK9geUYTp0hnE94LUx99WSisQYww6CsKiN/luM+3cWAAGVff6ieWCvEpROBXQIGcK8Br2y8Z9HzS0TkySCSDV3rZFZ70CS/5SNNAXKvare2yfIIvcadNulIKtlcUDJlLjPVgNbCJmjOC3VxwAsYoWu+siuXpLui74d7J+9NYl/VaGv+F0KBYp6PSu8qJ1zLVWE/M8GX7zhnL2IQVpaJtMSeYl2oDa/id1PL352otE43NMgQ6WMAy2Zf30QOluqPku3OmKhCvdI8QOrUCN5/NLR1RT4j/p6LxEHZnX3qqZYCs+eSoMqbcvogzVNrwKZIAE52FlOZddJCSe3A7UwHNhwJavtZopXkSBpQSpIPZSjGnUjUl42BhT+9N5jg34XOJYn6HJX4WMWtRFB4DbXYHXtRMo+AOLtVXS3QPFAPdm6dvHtkuGjDH85sIwyqbCtQjixrnC6zAw1b1iXWBli6bccOm/1eLI+PNfyiIvD83xOPMWAaHeR415ByAu5iI/Zldv2TFGc8D65NIpJmV1V40YUTLxzsBxTtn/KUJay0x4sTvnNPVaZQcmiE5wOnpBc2e36oE9PYy60aHXAoTQ61z1hAZRSzXA7PLLdDEvVxGLHeY+D9SGq/I8s3SeTXP3mmM+NlJbJbofS1hnAcWTkaWVyc2G+sWm6lUBAzoy2sI8ff2Tug/MzLeG1S89iOT+MVN4BdE6NFdGyynRClRw+E17HvwJKU8+sQk91W9DPT1FgcrGHC0nLpJpwXV+kOBXPxdDmqj2RJGaGX+R4LAfMd1pluHISun/VvZREn+IuRkQAOXSSwt4LxX0r6aIXBeA=="}';
                system.debug('++++ cRIFFAPICall requestBody '+requestBody);
                //request.setEndpoint('https://indusapiuat.indusind.com/indusapi-np/uat/cfd/cibil_tu_report/CRIFReportGeneration/V1');
                request.setMethod(methodType);
                request.setEndpoint(endpoint);
                request.setHeader('IBL-Client-Id',System.Label.IBM_Client_ID);
                request.setHeader('IBL-Client-Secret',System.Label.IBM_Client_Secret);
                request.setHeader('Content-Type', 'application/json');
                //request.setMethod('POST');
                request.setBody(requestBodyJSON);
                request.setTimeout(120000);
                system.debug('++++ cRIFFAPICall request '+request);
                        
                    response = http.send(request); 
                    Long endTime = DateTime.now().getTime();
                    elapseTime = String.valueOf((Double)(endTime - startTime)/1000);
                    System.debug('++++cRIFFAPICall getStatusCode' +response.getStatusCode()+'+getStatus ' +response.getStatus()+'+getBody ' +response.getBody());
                    if (response.getStatusCode() == 200) {
                        responseBody = response.getBody();
                        System.debug('++++cRIFFAPICall responseBody1 ' +responseBody);
                        responseBody = responseBody.substring(10, responseBody.length()-2);
                        String decryptedResponse = IntegrationUtilities.getDecryptedResponse(responseBody,System.Label.privateKey,System.Label.ivkey);
                        System.debug('++++cRIFFAPICall decryptedResponse ' +decryptedResponse);
                        String searalizedJson = JSON.serializePretty(JSON.deserializeUntyped(decryptedResponse));
                        System.debug('++++cRIFFAPICall searalizedJson ' +searalizedJson);
                        responseBody = searalizedJson;
                        CRIFF_APICall_ResponseParser criffResponse = new CRIFF_APICall_ResponseParser();
                        criffResponse = CRIFF_APICall_ResponseParser.parse(searalizedJson);
                        CRIFF_APICall_ResponseParser.Response jsonResponse = criffResponse.response;
                        String respDesc = jsonResponse.respDesc;
                        String status = jsonResponse.status;
                        System.debug('++++cRIFFAPICall jsonResponse ' +jsonResponse);
                        CRIFF_APICall_ResponseParser.Content content = jsonResponse.content[0];
                        System.debug('++++cRIFFAPICall content ' +content);
                        String errorDescription = content.ErrorDescription;
                        String errorCode = content.ErrorCode;
                        String reportId = content.ReportId;
                        String requestDate = content.RequestDate;
                        uniqueRefNo = content.UniqueRefNo;
                        System.debug('++++cRIFFAPICall errorDescription ' +errorDescription+' errorCode '+errorCode);
                        if (UniqueRefNo != null && requestDate !=null && errorDescription == null && errorCode == null){
                            if(status == 'SUCCESS'){
                                //data= 'Success';
                                System.debug('++++cRIFFAPICall reportId ' +reportId+'requestDate '+requestDate +'uniqueRefNo '+uniqueRefNo);
                                IntegrationUtilities.createIntegrationLogger(requestBody, requestBodyJSON, IntegrationUtilities.getPlainTextForLog(response.getBody()), response.getBody(), serviceName, elapseTime, loanAppId, System.Label.Success);
                                app.CIC_No__c = uniqueRefNo;
                                update app;
                                getCRIFReport(uniqueRefNo,loanAppId,applicantId);
                                returnStr = 'Success';
                            }
                        }else{
                            IntegrationUtilities.createIntegrationLogger(requestBody, requestBodyJSON, IntegrationUtilities.getPlainTextForLog(response.getBody()), response.getBody(), serviceName, elapseTime, loanAppId, System.Label.Failure);
                            returnStr = 'Error';
                            //throw new AuraHandledException(errorDescription);
                        }
                    } else {
                        System.debug('++++ not 200 response.getStatusCode() ' +response.getStatusCode());
                        returnStr = 'Error';
                        String errString = '[Status Code = '+ response.getStatusCode() +' ] Response-->'+IntegrationUtilities.getPlainTextForLog(response.getBody());
                        IntegrationUtilities.createIntegrationLogger(requestBody, requestBodyJSON, errString, response.getBody(), serviceName, elapseTime, loanAppId, System.Label.Failure);
                        //return 'API callout failed with status code: ' + res.getStatusCode();
                    } 
            }
        } catch (Exception e) {
            IntegrationUtilities.createIntegrationLogger(requestBody, requestBodyJSON, '', '', serviceName, elapseTime, loanAppId, System.Label.Failure);
            System.debug('++++cRIFFAPICall EX ' +e.getMessage()+e.getStackTraceString());
            throw new AuraHandledException(e.getMessage());
        }
        return returnStr;
    }

/*
* @Method:      getCRIFReport
* @Created by:  Aakash J.
* @Description: Method to call get CRIF Report API for Tractor Dedupe function
* @Param:       String - uniqueRefNo
* @Return:      return a string based on Response
*/
    public static void getCRIFReport(String uniqueRefNo, String loanApplicationId, String applicantId){

        loanApplicationRef = loanApplicationId;
        //loanApplicationRef = loanAppId;
        String requestBody = '';
        String body = '';
        IntegrationEngine.serviceName = System.Label.GetCRIFReport;
        //String serviceName = 'GetCRIFReport';

        requestBody = '{"CICNo": "'+uniqueRefNo+'"}';
        system.debug('++++requestBody '+requestBody); 
        String encryptedRequestBody = IntegrationUtilities.getEncryptedRequest(requestBody,System.Label.privateKey,System.Label.ivkey);  
        Map<String, String> requestData = new Map<String, String>();
        requestData.put('JData', encryptedRequestBody);
        body = JSON.serialize(requestData);
        system.debug('++++body '+body); 

        String req = '';
        String reqExt = '';
        if(body.length() <= 131072){
            req = body;
            system.debug('++++++++published from low payload++++++++++++');
            system.debug('++++req '+req+' ++++serviceName '+serviceName+' ++++requestBody '+requestBody+' ++++loanApplicationRef '+loanApplicationRef+' applicantId '+applicantId);
            IntegrationUtilities.publishLowPayload(req, serviceName, requestBody, applicantId,'');
        }
        else if(body.length() > 131072 && body.length()<=262144){
            system.debug('++++++++published from High payload++++++++++++');
            req = body.substring(0, 131072);
            reqExt = body.substring(131072,body.length());
            IntegrationUtilities.publishHighPayload(req, reqExt, serviceName, requestBody, applicantId,'');                  
        }
        else{
            ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'doSIStatusAsyncCallout', System.Label.Apex, new IND_Exception('Request string length is too long'), loanApplicationRef);
        }
    }
    /*
* @Method:      CombineBRE API
* @Created by:  Aakash J.
* @Description: Method to call CombineBRE API for Tractor function
* @Param:       String - loanAppId
* @Return:      return a string based on Response
*/
@AuraEnabled
public static String combinedBRE(string loanAppId, String vehicleId){

    Http http = new Http();
    HttpRequest request = new HttpRequest();
    HttpResponse response = new HttpResponse();
    String responseBody ='';   
    String returnStr ='';    
    String elapseTime = ''; 
    try{   
        //String requestBody ='{"JData": "gHaUjrbJndsXKlvMQaMoFr2FRvuyVHb7QEAyMN8lFkugz22WuFtHWrGl8OGC/dNTrTm2sLgu7jLLWgH/1bkqdhvS60R7kcPjDP1q5avikP95DBKnXL563Iedy929fI5ApBPmx6n64t7TSa0Syk++62aiJvDXL/GM5Az3OOILnCGL6/Pd2q5jCZFfVFyHOpG8EDOEdv8ylnY3pv+BdMT8qTl1w6FpgsiR4aPhlxUkyPwoXQ+9S8UGSL3SLVS8HTXPVLg7u2K7IvUvMII+8pAwTyQatsO8WFCrDeY5Rr3Mnm9uNu/LHFZ596JGHmo/XU1rhqsJHJ9kk7X/DeGEOuFIZprTmnXqwKcgCQATy07gZ9WewdmTy4VwKh2npKxCdTcJvnHLJxqGAnx1Owmk1CRp2v3LDci5/hQ+TqMmDixEm/8IF+inlubJCxRG9k0Ims/6yGlbLvEr5szv6PTsZYLTvh6EJceGCkYsepc4o3DXFJizo2uHWYUdQ5HqNdfwRMcwYTgIA4F1CzQQuwdoweJN8YgtJ4bfeQVHqBiYgoJ9dUQHdSp8M/PsG85vPIvtc17Aer9ftBgVxd2vUCJSa41tXxc5ZkzGPg7AjZU6C8wG+X19nt0OERmjC/JTS5EmKPEaug6dSn/uSA/AIBrielIgB9RP2Yc6x6oe9Tefy4zd5ezY1bK1WYlyruuEUUSju1eg58aaTteIRvn6qstGpAPqFCQa3qdRp3eyODnjVT6r98hbKl6hC5z29U3XMIRrWqfJJ6b8JBtwsDlmLexlqH/bTTXaWS8ChX9GRuRLxwr86OrsWCjTl1arh6440R29qjWEBfxtxfaEzQbaXEjlKWAUgwWSm6x+vF8IIXFtBnn8ra6n/5KUqPCY43cXrwUZWvJNvmqpkzRH6EPap5PXR6vZYmAL/Hpop1n/oZ49Qt+uOblILYSwkcoCzg+QTJLXaQgF2F5a2PLlrJ1S2nRRrQ2QkNxMkJTK+2RyLmxHs3lBX6mDFrD/nuBgm5A4Lmh8IMXXsI1E6Fn78NgAAXRfbZ5MLjMG2vyMhgq6+Ue4Z/zQVJ3GHyob2M05efvUAgWMbPeb5cfLLh+6WuzBFUE74blL0HBxhKmJCGE36z5PV+gGBFxaa987dJpYQy98Gv5kLnonyJ5HbbYvnhs0qfpQJQR0vAC6yyxbtr3VRhs2ijfQtsjrmQBdywftSgVjHVjaAGvvdr0OaoP4KBXWNCL+/9rCPd0SoGkIzeQ7VYzWL7wxnO/GA1DDtaw+grXYrTfQWrreQk8t/2tnDlLPq8s/MASati5KeyGjNGjmH+rWNnRg1jKOsEP9AAkrCVSk3sf7W03QiUMi0+fJM+m6nNeJ4gQ32lUx3GeoSb0neslJDl0Dx58tC6Nc6SsLBim89NKt+CRBFjfrNCHqIL2DPgtgwIeKahIZV4lswjeRiggIFYAC5DwvLL1gA2K0llQumHco4pZwlvinYyK26ySuOxJTLuPQXN3MeoiCnZfpJvp16WXZCN4l/SFi8JjCqFm7VTZF/3UQmCXro04m0vN/zGBr8xZNlqJKC1USrZxTvVwO0Fnw2ca66Z9DVuxzbk0T8J6hyLt1yYsXPsKhxe92mCbm4FcT8o/KFEHd0RtH+f4648WA9ZvWIbIgVpeyk7T0h2TOJiAd9FD6osOpJr2UmeZFiRicxkjuB63Ds2NKsakLvvOmsgSN5RCt6lox+NlQIlb2TYoPFCw8dyrabNriZ1bk5lrBQakZiKZCUeqrP8eGM3W4v6nK8CFV3JQ8MdNsMH0azcqjRORw5Fj36BV70XhVW6Tj3LrRUacvYvrlq6KWPU6HOFpT6i/Ol2YdnZ6GDbn7XYa06w7MclB29cbKpyDyusoWYxPsQfbKhFEbJuYpvNLIOr4mnFi6BnWZWP1OA34vwqbXWibO53TvGi+u9vXXgO3zDhWqiA2yWtweT00qLY5KVPG8zguuyEFrAT2IrFGMHWN8Us24mELcBN+t8qU6s3ubEQFVjovsHB4FNCAYt5rqdeyPshoigu82/4t4htUqbWF47YHhYnUGChKAUSQYA7nVnAW0QyZZxQkTvnbADKy71OsVtsCw2s0y2OJf3Cj5VTHRPZFuLld/oi6WDkGS1tJ7N26FZgl24Y8ZwZBaa7yjlN/EdAJIMZ4lO99y0VUgVM3LS0A6rQaYBCkfIeGeJYHjDO+gZApUttQJ81snocZRisu6jBkeA/rrRlnqv8P+qHjKWpM4wdw9vUip2cCntw3Hg+vmLs+OKkJixigINdsntEUozpMWDDjMkVyFcYF5ft5lLXL76Pc/hP6jSYnE8bzT4TVpuNWWRuSmiDHMvg/nCfVcl/Tm/tvSsX40nAljzCJANZrCWGfUZWB3aT2JAQ70+IgKsD1IrKdGVVwBeB9aOD7fSc8JkWmWaxSoX60W21hzmjZNmEe29T82HRqtkek5ySABe4O2NkOSG4TcCSllEYGzv7mj5Ep/WCKrJal0vnd8SyhSt2A9adLeGCboa7ZER71+IOElBqHmrYHqNnZiK4EtoDJIjAAm9TQwhVi/qL7XNCm+fVrK93158mrs+LIFb1BDBpBDDWPMGidj3332TMYxbqCeNHbRYXY9WRWDFPltosyt/ZUjodchTXu2LmzEweXwf+7pAdae3XjB3nocw/iW8ab9dpzhQanqTK3VT3Li0SvdZFi6m2m1Co79JUUtap0JUZR82aRHhP2yPr3hvlhLe48H7CqTMnVvn5HGJuwd/OtYw6Mj9Sf3PN115I2GKNq3QjVd4U9htmWqVNorzdvSxci/GG5nxajQz6B4uZ2WIik53NqSmYKb8qSjaFOuNwt7GytOwpFEZbwyvYnl5PNmtNBNQIptlM7c5V+s5cNlpS0uZ6Au7l9wRHEsCtKyEN5sht5aXvxbltsse9tNKzATb3bK0BBaDmYbNA2nWdJcdKFaOL7w7aeJd1OJJwq8708D6t2U0n9m3ZFUqPlemvfzzgJoNOtJhxm8u0RAa/1m1Ch2dhVA940TqKLS5zTeDxC202LblXG3flHMeBbN7I+dXTPQ7FkaTZO38jrybbP0g2RwTVFDI7xv5j9LIhMDluHYSZFIzuuhGYdUeUpWTccXUxgQZ1xR/A//MP7mntdB3nJoPgzHY97U9IdzBws2e5+iFGIjYGVlJwIxZ8CSAS8LKsAQrpnd9APPYxnTQzj7Z18mQm39CQD0/m2o31dxqrrg7hxpkrSEfAaCQlUFv96HSmb03Ryc8BoupbM7sqvo4Ptx3QFnHZYS+Zrt3/N/xNLPUYlF0W+HfFMH2Wb61GhFskmkF1QOO21UYbnB7CVkg3g9cW2kk8bS6LUOJMuQhx8H51wbDutW4Gx2vdT6606AMyXrB9+6aMCb0oMOL2LEczNr+skaw6+qnzG7+D4FZjEuvnC585PHxMFI8CoiGu4M0LrZ1ash+ca7w1NdX5Lua+HMZ/cp3oWFN09FL0o6n+FXMkdhqff0cZhvKAfRejUt3VOMc7Sm7VMXC2N1W4ysSZK0/ifCikQlq526fbr+ZW5CDP6E/9AwwzGw9yBbgR7ULBVieC091mwlef8y8BWQmZe0C1hvjyBEhG3rywu/mpM7BlqbAtfK26Dw7tqJFDgeueq8/9VpZuSyT0/HOlwjyqT5KQnpMbyV+7g8cL/8ehz0lFG1sJfTvPT5841ru/gr2pxiCT/cdLNcX6sG/OcJwQRPJEySDuGx7ywjhRMMuu5GXpektYWS1pzVy5ikDyhhIsZxiDhHf0YGTDgqOV+GnQ76p9kRum2LJuXdn80Kk51EzsqBayMw+ZILj7zFxaCPPGGXQvhYd2QL2IyIziizfTwtnC+fS/RIyxEW4LEo3B6LMpU3qxmbR+P/Z37z4HPp6J9dnSy29X2r/ab+xArN8Ev9g74yoQpJjSBVpfrZEol3JXxfIQ9GVxuI7DtglWEal31EJsKaIZ14XNPkwhubTOSt7m/qrK7b1tUyT2419lY32bE3hgg0bLkHhBdjbye1eqCHhBpPmLJgLmUifRQNsB2QUR5Y2mu687Ixzkp3b8h89fNrSFT2qQqpfDtLqzR+xPtoY71aCkCQbjMDE2r00ZuXm3QhVdGPov5Hzlu5DeEx5mvkaHy5OkRk3G5rtAu82WsG4F89SfQwqVAZLCUJb39V/BjUnKd30W7zXGXdpgVukyyNMIJEGQ44Qc0DxOU4UrQm/j92paswTPq3V2JvwGrsH58QOEeNGhSnGOSU1wqSzOnGrAw09hL98vaDLyMO5WwjmRMSVmLjkx+KUsDU0rCCGnS9syAzrNpaI0PwN4znSZ82m3eG2fvKxomDlrjQ74LJyt0Jzzz3jLfiX6bYeqNBSzaR5sxpmWaxSwSalh+Q8yJYcsYRYgw+va3Izv+gyspb3mXwaami2uB11+1wKo9uv+E3MEqmcjHi4pGqsmIv7UP0/tXmnjJSQEXyueWIOmZkUHh3+MpV4S70Zkt3viDXOD1bxWYIz21vLonp/f47SWJUaWPiEQ6xRM0UXB7cUyyHjZnUBFp8ZfvRRfB8KoEJtmNpU7NzBkH8+sEHoXJKG9QOYtJtgbAy7CQEMg4z0nXbBRUHyc0edTlKSEX0FBbwKfKEStWD0rgDf5VtKpDiW5C6Dq74+qUYwA/nCsHWlKZgn4zwGOPZdfhZMOud/FSBxbHdDDLE16BVFENc2MPOlBiRG3+RvhDw59xpAIskUDleeaPi+p4nyilBlRGK0wHEBRdKuGS1/Oi9f19MWUoA1ln3+iR+qvwURLyVUEfDdveTO6aRvfjg+ssXzlHY/tuUI3PPZKkUjRGIB1Pl0dVx6qOk0E7JvJx5A/AhZqYHpkY81moAOyD8XeWH1yeLnmJGMCzpE7NtYguPp8s7DqkruWi6llzN0yzGPMa76bozucSjFXJpvRZ1lYbQe1lhQPwSkYS+CjAFmVd+qvCSO78qCSr9lXMR6lAsGuD2OhNsds0DzJLblcHTg8a6tO1dCTDWwG7GO9Xn+u0xle2jqYqcx9mjuNPtaC+3IB8Pa7MgyIylRKJTlXbazrWfksIm+EMLIJcfEcRQaEzDVArg8WGc62j07Kh+NNKf+h+H0gbWwQk+3kLRk7YxwBCDqwzzGiJFc3K9NHMOHVpb+S6/gmb9z+dSh+b7QeAL+m2T32CDKwcPCGtfXPAqz/ivpdu8QW6IDYhtJNWhO9A4+gO6e42mgpwUEgas5ke8QEp8i/hN5xbGgAYCnOpmJ941O8mST5qtBiSwcUPBKLL9XcR13QgoKK393kpnDj0ieabTKknJl9TxtlbnNZ473/7TYS3U+/CFSvipeWJB3MctzK4ICFPviqILIYVX+qpYjKpPuPI/r5coPqaeONDVJiQJ6hj/FoJa8XRVQbTgkEAZsqon6LAUPoO+LAKI6/tXapOL0bdbx/GtudvnjblGpQSYYuHkS9B0dVGj73f59Ijf4sXBrKnhJJYhqqFF08OgSoxuiOkcQmL4ug2Sch9jn5uwWDsEWVrZQPPShn8UT5Zzr/Vs4ylgM8cbSar9k+6iLD6VjvxZcBS04RpA+NJrstZabYw7KPJB9+V1E44dbuQrltVER/MXpxmx1ayN91IhMpfn1GxWPRp2x+fC/vB8LlQHMIjBB9htoRVhcMXKdrGuW1Em6zPCufVCYOnN26kSC6yzjqxdUibc8Oa4AVGeh3v9RpGuM4R7iq+ftrrOGK3Wh4QWQt8z8Chcf993pCID4cFlPk4mD/K+xKzlf4P854J0SIG78D+mCxVFS7czTkaPXTn22TlXBDI40NGSAFrq3J6nBDfgN92prUbmPRDt/lrVkiNEUfmyQhD+eopSvem1Jotzx3pAOo+CCG8jaq6TGS+CkIZ+aPBOYsbFO6EvOz8g3t4uVjuGr44hnnrLMwZwfL9pp5saP4fnbFZb6sYT3Yyg9rXZZdlsdhtUbWYYt/eZ1gDCv8iwCvJWiSgFbB/qQkhOLPZIWCrYwoouHIR62/TiMm6xPyzrziicrHttz+auv/gmDiI1rze/UHOO9UR8/2pWNbuEj3UefpNUFHzT1f91GvZxPAjA9qRDKmao7SxuPlvIGTh33tXkSTpED8BFD9X/CdaOsfkJveCL+IxhRkdVzDxF0M3b1cWAWC/rii06zDDdmPsPyGjfM/n7bRBW7MyKcNcFx+a0NulX6boifbNqcOKoz1c9XocLNTQyGmJZZy7Ox5hOspcR0kVBcGt1bg9rtsgNJcDKyC9hCRdOmYNh8bSJLOh+Z0h2b582EHKEAv+PvD+JlRJvs//VHc2Hr07lCtlRJkdzG1zpItlmk9NHwcAs7FF33GGR1ib3z6wFzpTwYQ3cTCxvvdBjSpiN5koFjCNzF+0VUOFRekXiu+qOichKssquK93LQPS74PAOWvhHJm8Tw1oYTrlx7wlznc3lBHxzRE5T6cCL7OPnDEBH6pPzeP+EsLZm7wjMTs05Xi2Ko7Kqiv9+ElskdJOl7wzDlFznLv7RdBS+8e2mt5J9IY2WJU+EljNvCZwOkOqNX6D5KQOg2FduDVo0ebddt/0yK5DMHZ4PzZve+Ib38K/xDmACw3YlCq0dl0IjfarHbUu0c+hHt7Fv26/orKPwgzpbV5+bTkmOhRWH1QjQFCrpepix4v0k++6zm+WfKK1BcdWaumlIjq0Djd2hkW7a4PRdJW7NKNb/bW2m/9Cb+a9OFYXI3yz3XLKeml4kpm8lQpei7X3hv8T9NdISpwf944uWvm6ITsK6qLixMNliw5wr9Rf6Qh4O4yY28xF9vwFwzY8Cl7Jg39ZeBGiFG3IeJHQO40RIcVWpJfmJFLXUWeTjV/yM5oDBQinP7vvyZK24IsUoOWp3aNq9HesIDIBCm6pRezNWPgPSPY8KunlTmnygZ8lopFFwZDrIitckJCyo42kIdb+aPosL3wQH0exE2XbDp0lK4DU1VbSgYKKmYwtoh/VETgF9ksaVDexWg0X7KaExXnzBaUWvESMgVHVScGRPNd3OHAVX4mCzyjMfqtOj+Xl85IUXunL678a95Ly7veVujmRM6CzVXb0EpzKNR97U+FHnnZlH/Eit0+W7X7oRDI6dQOhmFAeEsSZDs/TmGqxArcCV2AZ+SgoAvhQgKStrrFcCLss1uI9ZNNNgnybjRI9EEOW/epqFAwOTrIwg4pTKP2hd7Mo5SxXA4NafUhLqTjgH+C1NzTVK34huopT79yjqmAoIjX5LxQJ3DbRFwjSxYpcrV39I8r5Hw14PqfoN/Pw9BTv4JOwXnknHD4LpfQXifYYhvJHWv/1/ordxrc+knhsbwGECW4B7lshnutky78zo23tqyQGSibI4gb3xV38p3s6WyjtfGdOZXrOX/uqvLhtqofgnyNhQw+o1sLs+DfzcBxy+T0H/b25pQr+rKvvX2EH4xWDcpDdeCDLNaZMIq/qBIvin1xG6kMlyJo7gbfi7a1jRHUwPRCpsLPM2lRRGBSTQi6y+b/eoc/yoh7kvMn95GnuRtQR8niQz+HHRANAdn8UON7GDHuPDjq5pvNeNS7szOAxUNLDXAW0KojBkeq9tUeI9Ti454FYrIgWxLhH4Qwrin1daB1pruuV8qA9m1Af95Vs/lElzwfL3a716ARSNlpUaiCPWD8n93S6Pq9d4XK12ooASlnYLpzNbdbTKhlAm6X0pme1PV8+efADkaKCC7Am0z+aeS1mqMl4Z6cfDAZaXPv8rN7NJFar8zqP8pUViKQAUvMvCDOV6CrScLcrP9jMnBgV9JfUnwHlLsVapF21Zbj82I/zToU8w/IcWB+2Hljrreb2zzGVl1+WrFroo9eWuUu34Nzhh7cW78BDizm4mGB6CComgl92TPwgJP2H+f05/SyIez5zW7bURbM7AXaajcSM/TnauFnkglN0aCUWusCFS8W94XTwZXaom2jp3kL3hF4NNjsx0Tl5gzYogatQ79jyivH7x5vshSvC19R4DFoO692oGchuwYvnIcrEkVHfTrC0megdh7/egUJr7H07K1IBAm/QUpxnn3xXzG2W5rBMiILMtdRYcXYnMbh98txu2Gy+qo0OntyRBuMX61tVnFJ5x3SIBa5VZsh/AmagxwEinx+TLKlE/rNXes+lVQTXzN/OT1DYS1LIFe8vMQFw8a4vKBVYWiZUTawrrwDkREeZudgZOeekf0qbfTrOGV6RjZEnniBlyYhZyArzyYYTjJvNxdyxWE3ULr/Oi3d+skvKe0TjElwDf+ANAwRrI6d7PbJ7K6sO6LTg2kdbruZGHthY8WGR579yt9wUdeTXPlP/iIHzYo67iCUIkY14wtoWD7NhGMAU1L+cKQaxtKY5chdGTJ7rOxm/UET3WiGoz2BYVTQz5P4Fl+MwyL4CYMht5wL9L+PRTRn7TuvWyOD2dT0SCMSWXNT9uJakU49mH2Ztk/887m9WQTiu6OVjVYInNTvIZY4jOt4B6JQe+ZiOmJ7y7xyCRT7aDFicDDPlnYZ87UUHQW23fUETWg6hC8a3DDcYjIQGfYtyPDO9VPePgi+T7PPsTC813IkoHRAKi/ECwd+lutN1HFJsCVm7rJd7aHADflnQnJwXyqL12M2vOCtMtg4m+HetguaRyfUaWqPy1yO82YmM/7DuoebWkhnILFns5mEGVSJtTsZWOuzg3bFOWzFjxiTvQuHDUihj+ycJn88hNVe/5yHUucuqPjYd2s95B2Icl4rOw+C1gH66dsHZN51X5SHUZmmtnE5gkiyMlyhj/i0w37pfgqjsBCF4lkjBDOG6aPWg01JL/89pK4BSf/wedREm3aPsei26OHpaz1xgIysYo2VZ2/N/PQFqCLzN9uDHVCG1XXLOFdjKpve5oyr8omnCGAPqdgq6jVbPPq4JO8m3b0TIWbh1qtGDJ4QNJKwWYBN3aUkFZ6DB07Wwzc3bFPAnEG6eHdVX0KB0GTZOZKipNBCOQ/GbDu4jN3YkoNd7vOuig0D3XlRH9crcSUIl/1hcNlSdjjUzJMIG5uwp93e7kZYlkb7oRQbT0xoqaMt15qsncJYK8IyRSEtQz1f8hvKMfuRWR7QdAbzXaEBEEPvmbcZE7G7qGrTTo1Khclf3zUAxfj8bfOPiQey1+T7g8FyZOqXhAx+hpFDiU79MqC4H5VXtNL1ENCyxzR8qaPoKDxUmdUSY4r23OILetB3FknI5B6TbO478KzXU/Ui3+zqqHxrmFlZuCLa7+mh2lhuQx8lAr5x8mS1rEDoyCuacZ9fquW2mwcVLz5b9lEmYPfmDqb2qXjnY8JpdO90iywJdRx2XZ6xF8o7is7TNrvtIa/8XR20cynoLELfOmRDgFu75ZN33pSFFlnSXNXAEvFbto2oL0H7SQ4cfgljdYtXNLaO3L6IzuV5Ds//GUQK6EKThpe0k="}';
        Integration_Configuration__mdt apiConfiguration = IntegrationUtilities.getAPIConfiguration('Combine BRE');
        if(apiConfiguration != null){
            if(!apiConfiguration.IsActive_Integration__c){
                ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'Combine BRE', System.Label.Apex, new AuraHandledException('Integration is not Active'));
                throw new AuraHandledException('Integration is not Active');       
            }
            String methodType = apiConfiguration.Rest_Method__c.trim();
            //String endpoint =apiConfiguration.Endpoint_URL__c;
            String endpoint ='callout:Indus_API'+apiConfiguration.Endpoint_URL__c.trim();   //Change Aakash
            IND_CombinedBERRequest berRequest = IND_CombinedBERService.getCombinedBreRequest(loanAppId, vehicleId);
            System.debug('++++berRequest '+berRequest);
            String requestBody = JSON.serialize(berRequest);
            system.debug('++++requestBody '+requestBody);

            String encryptedRequestBody = IntegrationUtilities.getEncryptedRequest(requestBody,System.Label.privateKey,System.Label.ivkey);  
            Map<String, String> requestData = new Map<String, String>();
            requestData.put('JData', encryptedRequestBody);
            String requestBodyJSON = JSON.serialize(requestData);
            system.debug('++++body '+requestBodyJSON); 
            Long startTime = DateTime.now().getTime();
            //request.setEndpoint('https://indusapiuat.indusind.com/indusapi-np/uat/cfd/fico/bre-decision/BRE_Engine_Trac');
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
                IntegrationUtilities.createIntegrationLogger(requestBody,requestBodyJSON, returnStr, response.getBody(), 'CombineBRE', elapseTime, loanAppId, System.Label.Success);
            } else {
                System.debug('++++ not 200 response.getStatusCode() ' +response.getStatusCode());
                returnStr = 'Error';
                String errString = '[Status Code = '+ response.getStatusCode() +' ] Response-->'+IntegrationUtilities.getPlainTextForLog(response.getBody());
                IntegrationUtilities.createIntegrationLogger(requestBody,requestBodyJSON, errString, response.getBody(), 'CombineBRE', elapseTime, loanAppId, System.Label.Failure);
            } 
        }
    } catch (Exception ex) {
        ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'combinedBRE', System.Label.Apex, ex,loanAppId);
        System.debug('Error '+ex.getMessage() +' at line '+ex.getLineNumber());
        throw new IND_Exception(ex.getMessage() + 'Stack : '+ex.getStackTraceString()); 
    }
    return returnStr; //Add response string 
}
/*
* @Method:      Tractor offerEngine API
* @Created by:  Aakash J.
* @Description: Method to call offerEngine API for Tractor function
* @Param:       String - loanAppId
* @Return:      return a string based on Response
*/
@AuraEnabled
public static String tractorOfferEngine(string loanAppId, string vehicleId,String screenName,String requestWrapperStr){
    Http http = new Http();
    HttpRequest request = new HttpRequest();
    HttpResponse response = new HttpResponse();
    String responseBody ='';
    String returnStr ='';    
    String elapseTime = '';        
    
    try{ 
        Integration_Configuration__mdt apiConfiguration = IntegrationUtilities.getAPIConfiguration('TF Offer Engine');
        if(apiConfiguration != null){
            if(!apiConfiguration.IsActive_Integration__c){
                ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'TF Offer Engine', System.Label.Apex, new AuraHandledException('Integration is not Active'));
                throw new AuraHandledException('Integration is not Active');       
            }
            RequestWrapper requestWrapper = new RequestWrapper();
            if(String.isNotBlank(requestWrapperStr)){
                requestWrapper = (RequestWrapper)IntegrationUtilities.parseJSONRequest(requestWrapperStr,'RequestWrapper');
            }
            String methodType = apiConfiguration.Rest_Method__c.trim();
            //String endpoint =apiConfiguration.Endpoint_URL__c;
            String endpoint ='callout:Indus_API'+apiConfiguration.Endpoint_URL__c.trim();   //Change Aakash
            IND_TFOfferEngineRequest offerEngineReq = new IND_TFOfferEngineRequest(loanAppId,vehicleId,screenName,requestWrapper);
            System.debug('++++offerEngineReq '+offerEngineReq);
            String requestBody = JSON.serialize(offerEngineReq);
            system.debug('++++requestBody '+requestBody);
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
            request.setTimeout(120000);
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
                if(offerEngineReq.installmentPattern == 'Structured'){
                IntegrationUtilities.createIntegrationLoggerTFoffer(requestBody,requestBodyJSON, returnStr, response.getBody(), 'TF Offer Engine', elapseTime, loanAppId, System.Label.Success,vehicleId);
                    } else {
                        IntegrationUtilities.createIntegrationLogger(requestBody,requestBodyJSON, returnStr, response.getBody(), 'TF Offer Engine', elapseTime, loanAppId, System.Label.Success); 
                    }            
            } else {
                System.debug('++++ not 200 response.getStatusCode() ' +response.getStatusCode());
                returnStr = 'Error';
                String errString = '[Status Code = '+ response.getStatusCode() +' ] Response-->'+IntegrationUtilities.getPlainTextForLog(response.getBody());
                IntegrationUtilities.createIntegrationLoggerTFoffer(requestBody,requestBodyJSON, errString, response.getBody(), 'TF Offer Engine', elapseTime, loanAppId, System.Label.Failure,vehicleId);
            } 
        }
    } catch (Exception ex) {
        ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'TF Offer Engine', System.Label.Apex, ex,loanAppId);
        System.debug('Error '+ex.getMessage() +' at line '+ex.getLineNumber());
        throw new IND_Exception(ex.getMessage() + 'Stack : '+ex.getStackTraceString()); 
    }
    return returnStr;
}

    /*
* @Method:      doSchemeValidationCallout
* @Created by:  Sahil 
* @Description: Method to callout check Scheme validation
* @Param:       String - loanAppId
* @Return:      Object - response
*/
    
    @AuraEnabled(continuation=true)
    public static String doSchemeValidationCallout(String loanApplicationId,String vehicleId){
        String requestBody ='';  
        String requestBodyJSON = ''; 
        String elapseTime = '';
        String returnStr ='';
        
        SchemeValidationWrapper request = new SchemeValidationWrapper();
        
        try {
        
            List<Final_Term__c> finalTermLstVerifiedScheme = new List<Final_Term__c>();
            finalTermLstVerifiedScheme = [SELECT id, Schemes__r.Scheme_Verification__c
                            FROM Final_Term__c WHERE Loan_Application__c =:loanApplicationId and Vehicle_Detail__c =:vehicleId AND Schemes__r.Scheme_Verification__c ='Yes'  WITH SECURITY_ENFORCED];

            if(finalTermLstVerifiedScheme.isEmpty()){
                return 'No'; // Return If Sceheme Schemes__r.Scheme_Verification__c is not Yes then we dont want to do callout
            }

            Opportunity opp = [SELECT Id,Lead_number__c,Product_Type__c,Vehicle_Type__c,Loan_amount__c,Requested_loan_amount__c FROM Opportunity WHERE Id =: loanApplicationId WITH SECURITY_ENFORCED Limit 1];

            List<Applicant__c> app = [SELECT Id,applicant_number__c,Opportunity__r.Lead_number__c,Gender__c,Pincode_Ref_1__c,City_Ref_1__c,Applicant_Type__c,Profile__c,Declared_income__c,Date_of_Birth__c,Category__c,Marital_status__c
                                     FROM Applicant__c WHERE Opportunity__c =: loanApplicationId AND Applicant_Type__c != 'Beneficiary' AND In_Active_Applicant__c = false WITH SECURITY_ENFORCED];
            
            List<CIBIL_Details__c> cibilList = new List<CIBIL_Details__c>();

            cibilList = [SELECT Id,Score__c,Applicant__c FROM CIBIL_Details__c WHERE Applicant__c IN (SELECT Id FROM Applicant__c WHERE Opportunity__c =:loanApplicationId ) WITH SECURITY_ENFORCED];
            Map<Id, CIBIL_Details__c> applicantCibilMap = new Map<Id, CIBIL_Details__c>();

            for (CIBIL_Details__c cibilRecord : cibilList) {
                applicantCibilMap.put(cibilRecord.Applicant__c, cibilRecord);
            }

            Map<Id,List<Documents__c>> applicantDocumentsMap = new Map<Id,List<Documents__c>>();
            List<Documents__c> docLst = [SELECT Id, Proof_of_Identity_POI__c, KYC_DOB__c, PAN_No__c, Applicant__c,Applicant__r.Applicant_Type__c,KYC_City__c,KYC_Pin_Code__c,KYC_State__c FROM Documents__c WHERE Applicant__c IN (SELECT Id FROM Applicant__c WHERE Opportunity__c =:loanApplicationId ) WITH SECURITY_ENFORCED ];
            for(Documents__c doc: docLst){
                List<Documents__c> newDocLst = new List<Documents__c>();
                if(applicantDocumentsMap.containsKey(doc.Applicant__c)){
                    newDocLst = applicantDocumentsMap.get(doc.Applicant__c);
                    newDocLst.add(doc);
                    applicantDocumentsMap.put(doc.Applicant__c,newDocLst);
                }else{
                    newDocLst.add(doc);
                    applicantDocumentsMap.put(doc.Applicant__c,newDocLst);
                }
            }
                
            List<Vehicle_Detail__c> vehicledetails = new List<Vehicle_Detail__c>();
            vehicledetails = [SELECT Id, Make__c, Model__c,Variant_Code__c,Make_Code__c,Vehicle_SubType__c,Vehicle_Category__c,X1st_yr_Insurance_Premium__c,Ben_Code__c,Required_Tenure__c,Valuation_price__c,Invoice_Price__c,Base_Prices__c,GST_Amount__c,Loan_Amount__c,Funded__c, Non_Funded__c,Model_Code__c,Cost_of_the_Chassis__c,Cost_of_the_body__c,KMS_Run__c,Required_CRM_IRR__c,How_much_margin_amount_paid_to_dealer__c,Loan_Tenure__c FROM Vehicle_Detail__c WHERE Id =: vehicleId WITH SECURITY_ENFORCED LIMIT 1];                
            
            List<Product2> prdLst2 = new List<Product2>();
            List<Benefi__c> benCode = new List<Benefi__c>();
            String cfdStateCode = Utilities.getCFDStateCode([SELECT Id,Agent_BL_code__c FROM Opportunity WHERE Id =: loanApplicationId LIMIT 1].Agent_BL_code__c, 'T');
            List<TBM_Product_Variant_dt__c> dlpMasterList = new List<TBM_Product_Variant_dt__c>();
            if(String.isNotBlank(cfdStateCode) && vehicledetails.size() > 0){
                dlpMasterList = [SELECT Id, Segment_Grade__c FROM TBM_Product_Variant_dt__c Where State_Code__c =: cfdStateCode  AND Product_Variant_Code__c =: vehicledetails[0].Variant_Code__c LIMIT 1];
            }

            if(!vehicledetails.isEmpty() && vehicledetails[0].Model_Code__c != null) {
                prdLst2 = [SELECT Manufacturer__r.Manufacturer_code__c  from Product2 where Model_Code__c = :vehicledetails[0].Model_Code__c WITH SECURITY_ENFORCED LIMIT 1];
            }
            if(!vehicledetails.isEmpty() && vehicledetails[0].Ben_Code__c != null) {
                benCode = [SELECT id,Dealer_Code__c FROM Benefi__c where Ben_code__c  =:vehicledetails[0].Ben_Code__c Limit 1];
            }

            List<Final_Term__c> finalTermLst = new List<Final_Term__c>();
            finalTermLst = [SELECT id,Loan_Application__c,Documentation_charges__c,Service_charges__c,Mfr_Exp_Reimburse_Amt__c,Dlr_Exp_Reimburse_Amt__c,Provisional_Channel_Cost__c,Gift_through_dealer_amount__c,DSM_Incentive1__c,
                            DSM_Incentive2__c ,Dealer_incentive_amount_main_dealer__c,Dealer_incentive_amount_sub_dealer__c,Mfr_incentive__c,Rreferrer_Incentive__c,Schemes__r.SubProduct__c,
                            Funding_for_Chassis__c,Funding_for_Body__c,Installment_Frequency__c,Schemes__r.RiskBand__c,Holiday_period__c,Schemes__r.Scheme_Code__c, Schemes__r.Name,Calculated_Invoice_Amount__c
                            FROM Final_Term__c WHERE Loan_Application__c =:loanApplicationId and Vehicle_Detail__c =:vehicleId WITH SECURITY_ENFORCED];

            List<Field_Investigation__c> fiRecordLst = [SELECT Id,Case__r.Applicant__c,Case__r.Applicant__r.Applicant_Type__c, (SELECT Id, Survey_No__c, Land_holding_In_acres__c, Ownership_Type__c, Land_holder_Name__c, Type__c, Approximate_value_of_Agri_Land__c FROM Loan_Holding_Details__r)
            FROM Field_Investigation__c  WHERE Case__r.Loan_Application__c =:loanApplicationId AND Case__r.RecordType.Name='FI' AND RecordType.Name='Residence' WITH SECURITY_ENFORCED];
            
            Map<Id, List<Field_Investigation__c>> applicantFieldInvestigationsMap = new Map<Id, List<Field_Investigation__c>>();
            if(!fiRecordLst.isEmpty()){
                for (Field_Investigation__c fieldInvestigation : fiRecordLst) {
                    Id applicantId = fieldInvestigation.Case__r.Applicant__c;
                    
                    if (!applicantFieldInvestigationsMap.containsKey(applicantId)) {
                        applicantFieldInvestigationsMap.put(applicantId, new List<Field_Investigation__c>());
                    }
                    
                    applicantFieldInvestigationsMap.get(applicantId).add(fieldInvestigation);
                }
            }
            Integer landValue = 0;
            Integer agriLandacres = 0 ;

            Integration_Configuration__mdt apiConfiguration = IntegrationUtilities.getAPIConfiguration('SchemeValidation');
            if(apiConfiguration != null){
                
                if(!apiConfiguration.IsActive_Integration__c){
                    ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'doSchemeValidationCallout', System.Label.Apex, new AuraHandledException('Integration is not Active'));
                    throw new AuraHandledException('doSchemeValidationCallout Integration is not Active');       
                }
                
                String methodType = apiConfiguration.Rest_Method__c.trim();
                String endpoint ='callout:Indus_API'+apiConfiguration.Endpoint_URL__c.trim();
                
                request.Call_Type = 'Scheme_Validation';
                request.Channel = 'TRACTOR';
                request.LoanAmount = vehicledetails[0].Loan_amount__c!=null?String.valueOf(vehicledetails[0].Loan_amount__c):''; // CHECK WITH GAURAV

                request.RequestedLoanAmount = vehicledetails[0].Loan_amount__c!=null?String.valueOf(vehicledetails[0].Loan_amount__c):''; // CHECK WITH GAURAV opp.Requested_loan_amount__c!=null?opp.Requested_loan_amount__c:'';
                request.Tenure = vehicledetails[0].Loan_Tenure__c!=null?String.valueof(vehicledetails[0].Loan_Tenure__c):'';
                request.RepaymentFrequency = !finalTermLst.isEmpty() && finalTermLst[0].Installment_Frequency__c!=null?finalTermLst[0].Installment_Frequency__c:'';
                request.RiskBand = !finalTermLst.isEmpty() && finalTermLst[0].Schemes__r.RiskBand__c!=null?finalTermLst[0].Schemes__r.RiskBand__c:'';
                request.Product = opp.Product_Type__c == 'Two Wheeler'?'H' : opp.Product_Type__c == 'Passenger Vehicles' ?'C' : opp.Product_Type__c == 'Tractor'?'T' : '' ;
                request.purchasePrice = vehicledetails[0].Invoice_Price__c!=null?String.valueof(vehicledetails[0].Invoice_Price__c):''; // Duplicate same as Onroadquotationprice
                request.Idvvalue = ''; // Blank Not applicable
                request.hmr = vehicledetails[0].KMS_Run__c!=null?String.valueof(vehicledetails[0].KMS_Run__c):'';
                
                String fundedunfunded;
                if(vehicledetails[0].Funded__c == true || vehicledetails[0].Non_Funded__c == true) {
                    fundedunfunded = 'true';
                } else {
                    fundedunfunded = 'false';
                }

                request.fundedUnfunded = fundedunfunded; // Need to check with gaurav
                request.financeAmtChasis = vehicledetails[0].Cost_of_the_Chassis__c!=null?String.valueof(vehicledetails[0].Cost_of_the_Chassis__c):'';
                request.financeAmtBody = vehicledetails[0].Cost_of_the_body__c!=null?String.valueof(vehicledetails[0].Cost_of_the_body__c):'';
                request.assetBasedScore = ''; // Blank Not applicable
                request.assetBasedCategory = dlpMasterList.size() > 0 && String.isNotBlank(dlpMasterList[0].Segment_Grade__c) ? dlpMasterList[0].Segment_Grade__c: '';
                request.Fundedinsurance = ''; // Blank Not applicable
                request.Valuationprice = vehicledetails[0].Valuation_price__c!=null?String.valueof(vehicledetails[0].Valuation_price__c):'';

                Double loanAmount = (vehicledetails[0].Loan_amount__c != null) ? Double.valueOf(vehicledetails[0].Loan_amount__c) : 0.0;
                Double purchasePrice = (vehicledetails[0].Invoice_Price__c != null) ? Double.valueOf(vehicledetails[0].Invoice_Price__c) : 0.0;
                Double ltv = (purchasePrice != 0.0) ? loanAmount / purchasePrice : 0.0;

                request.ltv = String.valueOf(ltv);
                request.irr = vehicledetails[0].Required_CRM_IRR__c!=null?String.valueof(vehicledetails[0].Required_CRM_IRR__c):'';
                request.Typeofdealer = ''; // Blank Not applicable
                request.variantCode = vehicledetails[0].Variant_Code__c!=null?vehicledetails[0].Variant_Code__c:'';
                request.variantName = vehicledetails[0].Make_Code__c!=null?vehicledetails[0].Make_Code__c:'';
                request.Firstyearinsurancepremium = vehicledetails[0].X1st_yr_Insurance_Premium__c!=null?String.valueof(vehicledetails[0].X1st_yr_Insurance_Premium__c):'';
                request.Discount = '';// Blank Not applicable
                request.Invoiceamount = !finalTermLst.isEmpty() && finalTermLst[0].Calculated_Invoice_Amount__c!=null?String.valueof(finalTermLst[0].Calculated_Invoice_Amount__c):'';
                request.Manufacturecode = !prdLst2.isEmpty() && prdLst2[0].Manufacturer__r.Manufacturer_code__c!=null?prdLst2[0].Manufacturer__r.Manufacturer_code__c:''; // Need to check with gaurav
                request.Subproduct = !finalTermLst.isEmpty() && finalTermLst[0].Schemes__r.SubProduct__c!=null?finalTermLst[0].Schemes__r.SubProduct__c:'';
                request.Onroadquotationprice = vehicledetails[0].Invoice_Price__c!=null?String.valueof(vehicledetails[0].Invoice_Price__c):''; 
                request.Segment = vehicledetails[0].Vehicle_SubType__c!=null?String.valueof(vehicledetails[0].Vehicle_SubType__c):''; 
                request.Dealercategory =  !benCode.isEmpty() && benCode[0].Dealer_Code__c!=null?benCode[0].Dealer_Code__c:''; 
                request.marginAmount = vehicledetails[0].How_much_margin_amount_paid_to_dealer__c!=null?String.valueof(vehicledetails[0].How_much_margin_amount_paid_to_dealer__c):''; 
                request.AgeOfVehicleLoanMaturity = ''; // Blank Not applicable
                request.Gstamount = vehicledetails[0].GST_Amount__c!=null?String.valueof(vehicledetails[0].GST_Amount__c):'';
                request.Vehicletype = opp.Vehicle_Type__c!=null?opp.Vehicle_Type__c:'';
                request.Baseprice = vehicledetails[0].Base_Prices__c!=null?String.valueof(vehicledetails[0].Base_Prices__c):'';
                request.DocCharges = !finalTermLst.isEmpty() && finalTermLst[0].Documentation_charges__c!=null?finalTermLst[0].Documentation_charges__c:'';
                request.ServiceCharges = !finalTermLst.isEmpty() && finalTermLst[0].Service_charges__c!=null?finalTermLst[0].Service_charges__c:'';
                request.MfrExpReimbursementAmt = !finalTermLst.isEmpty() && finalTermLst[0].Mfr_Exp_Reimburse_Amt__c!=null?finalTermLst[0].Mfr_Exp_Reimburse_Amt__c:'';
                request.DealerExpenseReimbursementAmt = !finalTermLst.isEmpty() && finalTermLst[0].Dlr_Exp_Reimburse_Amt__c!=null?finalTermLst[0].Dlr_Exp_Reimburse_Amt__c:'';
                request.ProvisionCost = !finalTermLst.isEmpty() && finalTermLst[0].Provisional_Channel_Cost__c!=null?finalTermLst[0].Provisional_Channel_Cost__c:'';
                request.DlrIncentiveAmt = !finalTermLst.isEmpty() && finalTermLst[0].Dealer_incentive_amount_main_dealer__c!=null?finalTermLst[0].Dealer_incentive_amount_main_dealer__c:''; // Duplicate same mapping with 
                request.GiftAmt = !finalTermLst.isEmpty() && finalTermLst[0].Gift_through_dealer_amount__c!=null?finalTermLst[0].Gift_through_dealer_amount__c:'';
                request.DsmIncentive1 = !finalTermLst.isEmpty() && finalTermLst[0].DSM_Incentive1__c!=null?finalTermLst[0].DSM_Incentive1__c:'';
                request.DsmIncentive2 = !finalTermLst.isEmpty() && finalTermLst[0].DSM_Incentive2__c!=null?finalTermLst[0].DSM_Incentive2__c:'';
                request.DlrIncentiveAmtMain = !finalTermLst.isEmpty() && finalTermLst[0].Dealer_incentive_amount_main_dealer__c!=null?finalTermLst[0].Dealer_incentive_amount_main_dealer__c:'';
                request.DlrIncentiveAmtSub = !finalTermLst.isEmpty() && finalTermLst[0].Dealer_incentive_amount_sub_dealer__c!=null?finalTermLst[0].Dealer_incentive_amount_sub_dealer__c:'';
                request.MfrIncentiveAmt = !finalTermLst.isEmpty() && finalTermLst[0].Mfr_incentive__c!=null?finalTermLst[0].Mfr_incentive__c:'';
                request.ReferrerIncentive = !finalTermLst.isEmpty() && finalTermLst[0].Rreferrer_Incentive__c!=null?finalTermLst[0].Rreferrer_Incentive__c:'';
                request.MoratoriumDays = !finalTermLst.isEmpty() && finalTermLst[0].Holiday_period__c!=null? Integer.valueOf(finalTermLst[0].Holiday_period__c):null;

                request.Applicant = new List<ApplicantSchemeValidation>();
                if(app.isEmpty()){
                    throw new IND_Exception(System.Label.Applicantdatamissing);
                } else {
                    for(Applicant__c applicant:app){
                        ApplicantSchemeValidation applicant1 = new ApplicantSchemeValidation();
                        applicant1.MaritalStatus = applicant.Marital_status__c!=null?applicant.Marital_status__c:'';
                        applicant1.Category = applicant.Category__c!=null?applicant.Category__c:'';
                        applicant1.DeclaredIncome = applicant.Declared_income__c!=null?String.valueof(applicant.Declared_income__c):'';
                        applicant1.Profile = applicant.Profile__c!=null?applicant.Profile__c:'';
                        applicant1.ApplicantType = applicant.Applicant_Type__c!=null?applicant.Applicant_Type__c:'';

                        if(applicantFieldInvestigationsMap.containsKey(applicant.Id)){
                            List<Field_Investigation__c> fiRecord = applicantFieldInvestigationsMap.get(applicant.Id);
                            for (Land_Holding_Detail__c landHolding : fiRecord[0].Loan_Holding_Details__r) {
                                agriLandacres += landHolding.Land_holding_In_acres__c!=null?Integer.valueOf(landHolding.Land_holding_In_acres__c):0;
                                landValue += landHolding.Approximate_value_of_Agri_Land__c!=null?Integer.valueOf(landHolding.Approximate_value_of_Agri_Land__c):0;
                                applicant1.AgriLandAcres = agriLandacres!=null?String.valueof(agriLandacres):'';
                                applicant1.Landvalue = landValue!=null?String.valueof(landValue):'';
                            }
                        }else{ // Passing empty string in request for applicants who dont have data. 
                            applicant1.AgriLandAcres = '';
                            applicant1.Landvalue = '';
                        }
                        

                        applicant1.Riskband = !finalTermLst.isEmpty() && finalTermLst[0].Schemes__r.RiskBand__c!=null?finalTermLst[0].Schemes__r.RiskBand__c:'';
                        applicant1.Gender = applicant.Gender__c!=null?applicant.Gender__c:'';
                        applicant1.Lead_Id = applicant.Opportunity__r.Lead_Number__c + '_' + applicant.applicant_number__c;

                        if(applicantCibilMap.containsKey(applicant.Id)){
                            CIBIL_Details__c cibilRecord = applicantCibilMap.get(applicant.Id);
                            applicant1.Score = cibilRecord.Score__c;
                        }
                        if(applicantDocumentsMap.containsKey(applicant.Id)){
                            for(Documents__c doc: applicantDocumentsMap.get(applicant.Id)){
                                if(doc.Proof_of_Identity_POI__c == true){
                                    applicant1.DateOfBirth = doc.KYC_DOB__c!=null ? String.valueOf(doc.KYC_DOB__c):'';
                                    applicant1.State = doc.KYC_State__c!=null ?doc.KYC_State__c:'';
                                    applicant1.City = doc.KYC_City__c!=null ?doc.KYC_City__c:'';
                                    applicant1.Pincode = doc.KYC_Pin_Code__c!=null ?doc.KYC_Pin_Code__c:'';
                                }
                            }
                        }
                        else{ // Passing empty string in request for applicants who dont have data. 
                            applicant1.DateOfBirth = '';
                            applicant1.State = '';
                            applicant1.City = '';
                            applicant1.Pincode ='';
                        }
                        request.Applicant.add(applicant1);
                    }
                }
                request.SchemeValidation = new List<SchemeValidation>();
                for(Final_Term__c ft : finalTermLst){ 
                    SchemeValidation schemeValidation1 = new SchemeValidation();
                    schemeValidation1.SchemeName = ft.Schemes__r.Name;
                    schemeValidation1.SchemeCode = ft.Schemes__r.Scheme_Code__c;
                    request.SchemeValidation.add(schemeValidation1);
                }
                
                
                String requestToEncrypt = JSON.serialize(request);
                system.debug('++requestToEncrypt'+requestToEncrypt);
                String encryptedRequest = IntegrationUtilities.getEncryptedRequest(requestToEncrypt,System.Label.privateKey,System.Label.ivkey);
                //For testing purpose
                //encryptedRequest = 'SBgxjbq3ZEvrRdbajtCS/ulN0O7DizGqA08xB7LxH4LVhU+tweS1sj0hsBy6/8Fwv0/x8 MpCfOrHMp25aWBnVY0iBMKftH1oFbjN+IL9zYYkn9nCtIRQJu4f1XZZ6VpFdjpBZG5CmUka+nbz8kc318sw FAnxeNCGKgQOC9l16dfeSoQBhZZODOoHR1J0/+kK6NS40ltxJVK+Ghw85L5ZMTA6GqhOv0fc7Ra+rmQLeR0 VGpU/99SJx6m+cGYaiUggwCa/mJUJiXSBOldcMWwQ/1H8zzQ47/jQBgL78KScZiRyk0Ku2tJ37tgbnTnLdR ZXgIw5ebjf8iV+B8qnlPZ7+C0ph+o/RNd4EVuYN3i31lO+WxaTIAfHltAw49PgjRAOEhXNxtpd+3kcn3IR9 /pOIBBpPB+4EsFZn4RIIhVF/XW+wQg2w565bIbEsIu11VH7qu1fQ1KmKep8Ytv7v+cfL6WSQkuGCWH/XHyw hmxWCN4Z46l0Ixwzcti9gqBIhaChtv2ULMnALeuZwy1AD8oCULkxi18DGzSLo1SmY37jBjAyjWEjdmdkB8w ZVTqaUhkYwVfSEk66pbzSJQ4uzcJdLUwPF1CDc+qtfMLoMKfi2edKX/lM3AUII+aRkZl5Lsk64CGR1aqwy+ LGmrQNbzqXaa18egfwtjHzoWt0QsdtvlXxSs8YqklWC6FbP/31jyy726SRoG8V+qiEAHH/ga3osy5+DQRmJ l7CA9yJN2EgKRgTWsK0y4KAoc0BjvLYIpuoCf6a0cakA3+BuOUIWmptrPFehKOScQIC749JFuPooUGC0Zh1 LObk+9tShTTXPYKlQS2VDWZuAvIN+WwUJwrMEniGvGL4EdS39gme/PaqsfOi0ds6cPHBQYVGXK4ga1aWZa5 /tQtbEOSo4VdMmzzkHvv0oTR6rKbaJ/J+BGwblarikt2oaGe18vbeCWy/GdZYfotkxeVTA0/oLV3DThhGy0 ld9n6IXH0HBWazQMyNQLXbljILar3KGqmczS9gmM6QJoMGBNOUjCxMfNO+WEBFj2TG5xh/XIw2D1T0OtO7I 2MV7PN89ahUOfpyYc50HaYbtaQKAW8ExIe3dfmvX/tidu4TvLwS9uM/fAvnVKzOSqChulRUiu6XSTn+JPqd 7PmvHuOlAf+B5ZNMB9LtObFNf6voT4voscL4gJ9npcL/ABCCLY80SGQxCDU0rUlS15khM6fFHS0W/xcV09C 3aTZezS4IhwjA0k39+Mps2FHTV9RfgyJO90lrCv2E739Nc1TkG4IlHmZ3FEHJiU1CV2Y+65a5nhrCJkDR/Z mveOTY7ELtw9mx2UZbD3qMsFW79oj8aJei0+G+d4lrGc6Ij999o4FuiPOYfuUTMES+ej/ks5k+4YKgpPlke U778wIbCj1rPG1ZEx6bEr0+4rf2v5cB11S+9lgKAWJC4XIi+GgmmjQNZ+tevAfWOL8BzWO+NuHw+e0G5c+K EX2u6jy+QH8RqZz6a2rtViFaO+SuEMDUn6H16UvaYPdEgLBuqXuNN3z7fTD6iERgJZv2RB2sRS3ugeaO+Pw YRKwyRfW0qfPqdN21Ne244TkkBow/VPSFSjc/Gy4PLRBaD+3BEMDjq1xRdII+GgsJM1xohdBqlNSnVwvCcw Ao9fJJh+q1ZOejR2KvAGL5D38o+0kAmeuaQIK0Nyddv50OdUeyyEvDjzbSaJhR+TXYoF14FS5P8SIbBkVrz +tYo3I5U/zvJaBtDZ/F41YxS6EVh1XsRkp+xq/4OIJhzQoiU1rXx0sqlwjvxeBdBSVcR9EgruFy4C35rQtz AI6LDLHndXBCo9OdfSqKdmKGCcVdkNbaxveMe2fLh3K8Ep7LPwH9WbJ3J4U+Xv1wQqEHkXtHibvine5AdpN bpgAMxHmeykGmsmcXKOAE/mHD8uCHE7ooyDlTYTBzPH+VS7z00Re0K9kKWMks5EGbod4TIG58XstBVo4LwP 2144SYMJ2UQV9C2ANc9bmagboz27u7rN/IPer9FVizEB37V5mHU7n8LWZ4h0i1MDtXeXFErpSJWgveL9CEu TIBaRzLC7sPyMrqBq5c0LgPVtxFuTA3F0N0mSkJCFXLD8gsarwpfbyNX8SHgRmZCOdLTIS+3Bh5LKStEORI G3PRGwwUOVF6qVn4b+n3OZJ/KQldSARrv2CpViPRzWSN6d+NPFchLi2/+7ghjdv9hW1H3LmLLSbK7wEiiaX wGGpF/efVnUxLQ8nerIElcpismwlGm0saBOOC3XVQCsQ0T7S0P3HsJ5Qv+QWitGul/rtubqhLCrM7Iufiqf 4YvtF3K2oImP2paZDp1hVuVC/GP6TrIeQygqI78hZZ75xOU0Wwo8rXi5gFRlJ4VcyKPa2nNf8lsxNv2HvZR /m4wjM1M25NO7YkfWTiX+yoY8JIVnQDlxeTO4gK2H0PRfrzu3OdBkk4963qOqP7oE3V+SkQ4/1jmIFvYM9d SnUhX9El2fZcnFdzEZS8mqKaY9yr7XyMMvcFfN7GNE6KPg5nHiL7ju8U77KMmz6SKnFaARfwMgy6J3+dzyW I9RQScVsvuSVUaDMXm4xbXb7bdGCRYcb7Ro0H9MjDZnI8jWy7MZiQ2VUQrukbQxRgVypHU+5o9nsEBsYRcy iUqbAe51pOVZEnj6rFD1CJma7EzvFYeTOB7CfVhS2affFaG5ErTB2H2uemZbaYbgQnYTz9rXCV50aQq3HhY ZxjYWA26DKhc0V/PMGx/pGY700roZ6Yw6XayyQBO8WWS6B+K0XquJZY6QIW03kEeetRTVc=';
                Http http = new Http();
                HttpRequest httpRequest = new HttpRequest();
                HttpResponse response = new HttpResponse();
                Long startTime = DateTime.now().getTime();
                httpRequest.setMethod(methodType);
                httpRequest.setEndpoint(endpoint);
                httpRequest.setHeader('IBL-Client-Id',System.Label.IBM_Client_ID);
                httpRequest.setHeader('IBL-Client-Secret',System.Label.IBM_Client_Secret);
                httpRequest.setHeader('Content-Type', 'application/json');
                httpRequest.setBody('{"JData": "'+encryptedRequest+'"}');
                
                response = http.send(httpRequest); 
                Long endTime = DateTime.now().getTime();
                elapseTime = String.valueOf((Double)(endTime - startTime)/1000);
                String responseBody ='';
                System.debug('++++schemevalidation getStatusCode' +response.getStatusCode()+'+getStatus ' +response.getStatus()+'+getBody ' +response.getBody());
                if (response.getStatusCode() == 200) {
                    responseBody = response.getBody();
                    responseBody = responseBody.substring(10, responseBody.length()-2);
                    String decryptedResponse = IntegrationUtilities.getDecryptedResponse(responseBody,System.Label.privateKey,System.Label.ivkey);
                    System.debug('++++ decryptedResponse ' +decryptedResponse);
                    String searalizedJson = JSON.serializePretty(JSON.deserializeUntyped(decryptedResponse));
                    System.debug('++++ searalizedJson ' +searalizedJson);
                    returnStr = searalizedJson;
                    IntegrationUtilities.createIntegrationLogger(requestToEncrypt,encryptedRequest, returnStr, response.getBody(), 'SchemeValidation', elapseTime, loanApplicationId, System.Label.Failure);
                }
                else {
                    System.debug('++++ not 200 response.getStatusCode() ' +response.getStatusCode());
                    returnStr = 'Error';
                    String errString = '[Status Code = '+ response.getStatusCode() +' ] Response-->'+IntegrationUtilities.getPlainTextForLog(response.getBody());
                    IntegrationUtilities.createIntegrationLogger(requestToEncrypt,encryptedRequest, errString, response.getBody(), 'SchemeValidation', elapseTime, loanApplicationId, System.Label.Failure);
                }
            }
        } catch (Exception ex) {
            ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'doSchemeValidationCallout', System.Label.Apex, ex,loanApplicationId);
            System.debug('Error '+ex.getMessage() +' at line '+ex.getLineNumber());
            throw new IND_Exception(ex.getMessage() + 'Stack : '+ex.getStackTraceString());   
        }
        return returnStr;
    }
    class SchemeValidationWrapper {
        public String Channel;
        public String Call_Type;
        public String LoanAmount;
        public List<SchemeValidation> SchemeValidation;
        public String RequestedLoanAmount;
        public String Tenure;
        public String RepaymentFrequency;
        public String RiskBand;
        public String Product;
        public String purchasePrice;
        public String Idvvalue;
        public String hmr;
        public String fundedUnfunded;
        public String financeAmtChasis;
        public String financeAmtBody;
        public String assetBasedScore;
        public String assetBasedCategory;
        public String Fundedinsurance;
        public String Valuationprice;
        public String Typeofdealer;
        public String ltv;
        public String irr;
        public String variantCode;
        public String variantName;
        public String Firstyearinsurancepremium;
        public String Discount;
        public String Invoiceamount;
        public String Manufacturecode;
        public String Subproduct;
        public String Onroadquotationprice;
        public String Segment;
        public String Dealercategory;
        public String marginAmount;
        public String AgeOfVehicleLoanMaturity;
        public String Gstamount;
        public String Vehicletype;
        public String Baseprice;
        public List<ApplicantSchemeValidation> Applicant;
        public String DocCharges;
        public String ServiceCharges;
        public String MfrExpReimbursementAmt;
        public String DealerExpenseReimbursementAmt;
        public String ProvisionCost;
        public String DlrIncentiveAmt;
        public String GiftAmt;
        public String DsmIncentive1;
        public String DsmIncentive2;
        public String DlrIncentiveAmtMain;
        public String DlrIncentiveAmtSub;
        public String MfrIncentiveAmt;
        public String ReferrerIncentive;
        public Integer MoratoriumDays;	
    }
    public class SchemeValidation {	
        public String SchemeName;
        public String SchemeCode;
    }	
    
    public class ApplicantSchemeValidation {	
        public String MaritalStatus;
        public String Category;
        public String DateOfBirth;
        public String DeclaredIncome;
        public String Profile;
        public String ApplicantType;
        public String State;
        public String City;
        public String Pincode;
        public String AgriLandAcres;
        public String Landvalue;
        public String Riskband;
        public String Score;
        public String Gender;
        public String Lead_Id;
    } 
    /* @Method:      Form 60 API 
* @Created by:  Raghav J.
* @Description: Method to call Handshake API for Synergy flow
* @Param:       String - loanAppId
* @Return:      return a string based on Response
*/
@AuraEnabled(continuation=true)
public static String form60API(string loanAppId,string applicantId){ 

    Http http = new Http();
    HttpRequest request = new HttpRequest();
    HttpResponse response = new HttpResponse();
    String responseBody ='';   
    String returnStr ='';    
    String elapseTime = ''; 
    try{   
        Integration_Configuration__mdt apiConfiguration = IntegrationUtilities.getAPIConfiguration('Form60');
        if(apiConfiguration != null){
            if(!apiConfiguration.IsActive_Integration__c){
                ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'Form60', System.Label.Apex, new AuraHandledException('Integration is not Active'));
                throw new AuraHandledException('Integration is not Active');       
            }
            String methodType = apiConfiguration.Rest_Method__c.trim();
            String endpoint ='callout:Indus_API'+apiConfiguration.Endpoint_URL__c.trim();
        
            Form60Request requestWrapper = new Form60Request();
            List<Applicant__c> eqList = [
                SELECT Id, Customer_Code__c, Opportunity__r.LeadSource, Applicant_Type__c,
                    (SELECT Id, 
                            First_Name__c, Last_Name__c, Father_Name__c, KYC_DOB__c, Address__c, KYC_City__c, KYC_District__c, KYC_State__c, KYC_Pin_Code__c,
                            Mobile_Number__c, Aadhaar_Enrollment_Number__c,
                            PAN_Acknowledgement_Number__c, Estimated_Annual_Income__c,
                            Age__c, Gender__c, Amount_of_Transaction__c,Document_Type__c
                     FROM Documents__r WHERE Document_Type__c = 'Form 60' LIMIT 1) FROM Applicant__c WHERE id =: applicantId AND In_Active_Applicant__c = FALSE];

            requestWrapper.Customer_Code = (!eqList.isEmpty() && String.isNotBlank(eqList[0].Customer_Code__c)) ? eqList[0].Customer_Code__c : '';
            
    if (!eqList.isEmpty() && eqList[0].Documents__r.size() > 0) {
    Documents__c document = eqList[0].Documents__r[0];
    requestWrapper.Document_Type = document.Document_Type__c != null ? document.Document_Type__c : '';
    requestWrapper.First_Name = document.First_Name__c != null ? document.First_Name__c : '';
    requestWrapper.Last_Name = document.Last_Name__c != null ? document.Last_Name__c : '';
    requestWrapper.Father_Name = document.Father_Name__c != null ? document.Father_Name__c : '';
    requestWrapper.DOB = document.KYC_DOB__c != null ? document.KYC_DOB__c : null;
    requestWrapper.Address_Line_1 = document.Address__c != null ? document.Address__c : '';
    requestWrapper.Address_Line_2 = document.Address__c != null ? document.Address__c : '';
    requestWrapper.City = document.KYC_City__c != null ? document.KYC_City__c : '';
    requestWrapper.District = document.KYC_District__c != null ? document.KYC_District__c : '';
    requestWrapper.State = document.KYC_State__c != null ? document.KYC_State__c : '';
    requestWrapper.Pin_Code = document.KYC_Pin_Code__c != null ? document.KYC_Pin_Code__c : '';
    requestWrapper.Mobile_Number = document.Mobile_Number__c != null ? document.Mobile_Number__c : '';
    requestWrapper.PAN_Acknowledgement_Number = document.PAN_Acknowledgement_Number__c != null? document.PAN_Acknowledgement_Number__c: '';
    requestWrapper.Estimated_Annual_Income = document.Estimated_Annual_Income__c != null? document.Estimated_Annual_Income__c: null;
    requestWrapper.Age = document.Age__c != null ? document.Age__c : null;
    requestWrapper.Gender = document.Gender__c != null ? document.Gender__c : '';
    requestWrapper.Amount_of_Transaction = document.Amount_of_Transaction__c != null? document.Amount_of_Transaction__c : null; 
    requestWrapper.Maker_Id = document.First_Name__c != null ? document.First_Name__c : '';
    requestWrapper.Aadhar_Number_Or_Enrollment_Number = document.Aadhaar_Enrollment_Number__c != null ? IntegrationUtilities.getDecryptedResponse(document.Aadhaar_Enrollment_Number__c,System.Label.privateKey,System.Label.ivkey): '';
    } else {System.debug('No documents found for the applicant.');}

            System.debug('++++berRequest '+requestWrapper);
            String requestBody = JSON.serialize(requestWrapper);
            system.debug('++++requestBody '+requestBody);

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

                Form60_API_ResponseParser form60Response = new Form60_API_ResponseParser();
                form60Response = Form60_API_ResponseParser.parse(searalizedJson);
                Form60_API_ResponseParser.Response jsonResponse = form60Response.response;
                String respDesc = jsonResponse.respDesc;
                String status = jsonResponse.status;
                System.debug('++++cRIFFAPICall jsonResponse ' +jsonResponse);

                if(status == 'SUCCESS'){
                    IntegrationUtilities.createIntegrationLogger(requestBody, requestBodyJSON, returnStr, response.getBody(), 'Form60', elapseTime, loanAppId, System.Label.Success);
                    returnStr = 'Success';
                }
                else{
                    IntegrationUtilities.createIntegrationLogger(requestBody, requestBodyJSON, '', '', 'Form60', elapseTime, loanAppId, System.Label.Failure);
                    returnStr = 'Error';
                }
            }
             else {
                System.debug('++++ not 200 response.getStatusCode() ' +response.getStatusCode());
                returnStr = 'Error';
                String errString = '[Status Code = '+ response.getStatusCode() +' ] Response-->'+IntegrationUtilities.getPlainTextForLog(response.getBody());
                IntegrationUtilities.createIntegrationLogger(requestBody, requestBodyJSON, errString, response.getBody(), 'Form60', elapseTime, loanAppId, System.Label.Failure);     
                } 
        }}
     catch (Exception ex) {
        ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'Form60', System.Label.Apex, ex,loanAppId);
        System.debug('Error '+ex.getMessage() +' at line '+ex.getLineNumber());
        throw new IND_Exception(ex.getMessage() + 'Stack : '+ex.getStackTraceString()); 
    }
    return returnStr; //Add response string 
}

class Form60Request{
    public string Customer_Code{get;set;}
    public String Document_Type { get; set; }
    public String First_Name { get; set; }
    public String Last_Name { get; set; }
    public String Father_Name { get; set; }
    public Date DOB { get; set; }
    public String Address_Line_1 { get; set; }
    public String Address_Line_2 { get; set; }
    public String City { get; set; }
    public String District { get; set; }
    public String State { get; set; }
    public String Pin_Code { get; set; }
    public String Mobile_Number { get; set; }
    public String Aadhar_Number_Or_Enrollment_Number { get; set; } 
    public String PAN_Acknowledgement_Number { get; set; }
    public Decimal Estimated_Annual_Income { get; set; }
    public Decimal Age { get; set; }
    public String Gender { get; set; }
    public Decimal Amount_of_Transaction { get; set; }
    public String Maker_Id { get; set; }
} 
    /*
    * @Method:      doFicoDeviationCalloutTractor
    * @Created by:  Gaurav
    * @Description: This method is being used to call the FicoDeviation using continuation
    * @Param:       String - applicantId,flag
    * @Return:      ''
    */
    @AuraEnabled(continuation=true)
    public static Object doFicoDeviationCalloutTractor(String loanAppId, String flag){
        Continuation con;
        try{
            
            //Provide API-wise Integration Name to Custom Metadata Configs
            Integration_Configuration__mdt apiConfiguration = IntegrationUtilities.getAPIConfiguration(System.Label.Fico_Deviations);
            Integer timeout = Integer.valueOf(apiConfiguration.Timeout__c);

            //if stubs checked in Integration_Configuration then stubs will return 
            if(apiConfiguration.IsStub_Required__c != null && apiConfiguration.IsStub_Required__c){  
                String stubData = IntegrationUtilities.getStubResponse(System.Label.Fico_Deviations);
                return stubData == null ? System.Label.EmptyStubs : stubData;  
            }
            
            Opportunity opty = [SELECT Agent_BL_code__c,Contact_number__c,Funding_on_ORP__c,Gender__c,Insurance_declared_value__c,Lead_number__c,Loan_amount__c,Net_IRR__c,Product_Type__c,Required_Tenure__c,Valuation_price__c,Geo_State_Master__r.State_Code__c,Vehicle_Sub_Category__c,On_Road_price__c,Funding_on_Ex_Showroom__c,Ex_showroom_price__c,Advance_EMI__c,RTO_Road_Tax_New__c,RTO_Road_Tax__c,X1st_yr_Insurance_Premium__c,Other_charges__c,GST_Amount__c,Discount_on_Basic_Price__c,Vehicle_Type__c FROM Opportunity WHERE Id=:loanAppId WITH SECURITY_ENFORCED];
            loanApplicationRef= loanAppId;
            IND_FicoDeviationRequestTractor  ficDevRequestDetails = IND_FicoDeviationServiceTractor.getFicoDeviationRequest(loanAppId, opty); 
            CalloutProcessor process = new CalloutProcessor(System.Label.Fico_Deviations, ficDevRequestDetails);
            HttpRequest request = process.createHttpRequest();  
            Long startTime = DateTime.now().getTime();
            List<Object> objList = new List<Object>();
            objList.add(flag);
            
            Carrier carrier = new carrier();
            carrier.setServiceName(System.Label.Fico_Deviations);
            carrier.setProcessor(process);
            carrier.setRequest(IntegrationUtilities.getPlainTextForLog(request.getBody()));
            carrier.setEncryptedRequest(request.getBody());
            carrier.setStartTime(startTime);
            carrier.setLoanApplicationId(loanApplicationRef);
            carrier.setTempObject(objList);
            
            //Add callout request to continuation
            con = new Continuation(timeout);        
            con.continuationMethod='processFicoDeviationAPIResponseTractor';
            con.state = carrier;
            con.addHttpRequest(request);
            if(Test.isRunningTest()) {
            continuationLabel = con.addHttpRequest(request);
            continuationState = carrier; 
            }  
        } catch(Exception ex) {
            ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'doFicoDeviationCallout', System.Label.Apex, ex,loanApplicationRef);
            throw ex;
        }
        return con;
    }
    /*
    * @Method:      processFicoDeviationAPIResponseTractor
    * @Created by:  Gaurav
    * @Description: This method is being used to handle the response from continuation and return the response to calling processes
    * @Param:       Collection - labels
    * @Param:       Object - state
    * @Return:      Object - response
    */
    @AuraEnabled
    public static Object processFicoDeviationAPIResponseTractor(List<String> labels, Object state){
        String apiResponse;
        String request='';
        String encryptedRequest='';
        String loanAppId='';
        String serviceName='';
        String data;
        HttpResponse response;
        String elapseTime='';
        List<Object> objList;
        
        try{
            Carrier carrier = (Carrier)state;
            request = carrier.getRequest();
            encryptedRequest = carrier.getEncryptedRequest();
            serviceName = carrier.getServiceName();
            Long startTime = carrier.getStartTime();
            objList = carrier.getTempObject();
            
            CalloutProcessor processor = carrier.getProcessor();
            response = Continuation.getResponse(labels[0]);
            Long endTime = DateTime.now().getTime();
            elapseTime = String.valueOf((Double)(endTime - startTime)/1000);
            loanAppId = carrier.getLoanApplicationId();
            String flag = (String)objList.get(0);
            if(response != null && response.getStatusCode() == 200) {
                
                apiResponse = (String)processor.getHttpResponseForAll(response, serviceName);
                if(apiResponse !=null){
                    if(flag.equals('NSTP')){
                        Map<String, object> serialzedJsonMap = (Map<String, object>)JSON.deserializeUntyped(apiResponse);
                        Map<String, Object> objMap =(Map<String, object>) serialzedJsonMap.get('Borrower');
                        List<Object> devObjList = (List<Object>) objMap.get('Deviations');
                        if(devObjList.size() >=1){
                        data = 'Fail';  
                        } else {
                        data = 'Pass';  
                        }
                    } else {
                        data = JSON.serialize(apiResponse);
                    }
                    
                    IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, IntegrationUtilities.getPlainTextForLog(response.getBody()), response.getBody(), 'Fico Deviations Tractor', elapseTime,loanAppId,System.Label.Success);
                } else {
                    IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, IntegrationUtilities.getPlainTextForLog(response.getBody()), response.getBody(), 'Fico Deviations Tractor', elapseTime,loanAppId,System.Label.Failure);
                    throw new IND_Exception(System.Label.FicoDeviationNoResponse);                
                }
            } else {
                String errString = '[Status Code = '+ response.getStatusCode() +' ] Response-->'+IntegrationUtilities.getPlainTextForLog(response.getBody());
                IntegrationUtilities.createIntegrationLogger(request, encryptedRequest, errString, response.getBody(), 'Fico Deviations Tractor', elapseTime, loanAppId, System.Label.Failure);
                throw new IND_Exception(System.Label.NoResponse);
            } 
            
        } catch (Exception ex){
            System.debug('callback()====catch' + ex.getMessage() + ' at ' + ex.getLineNumber());
            ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'processFicoDeviationAPIResponse', System.Label.Apex, ex,loanAppId);
            throw new IND_Exception(ex.getMessage());
        }
        return data;
    }

    /*
* @Method:      doTractorGatingScreeningCheckEligibilityCallout
* @Created by:  Chaynnitt Agarwal
* @Description: Method to callout check eligibility search API
* @Param:       String - loanAppId
* @Return:      Object - response
*/
@AuraEnabled(continuation=true)
public static String doTractorGatingScreeningCheckEligibilityCallout(String loanApplicationId){
    // PincodeBasedSearchResponse responseWrapper = new PincodeBasedSearchResponse(); 
    TractorCheckEligibityRequest requestWrapper = new TractorCheckEligibityRequest();
    try {
        Integration_Configuration__mdt apiConfiguration = IntegrationUtilities.getAPIConfiguration(System.Label.Tractor_Check_Eligibility_API_Name);
        if(apiConfiguration != null){
            if(!apiConfiguration.IsActive_Integration__c){
                ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'doTractorGatingScreeningCheckEligibilityCallout', System.Label.Apex, new AuraHandledException('Integration is not Active'));
                throw new AuraHandledException('doTractorGatingScreeningCheckEligibilityCallout Integration is not Active');       
            }
            String methodType = apiConfiguration.Rest_Method__c.trim();
            String endpoint ='callout:Indus_API'+apiConfiguration.Endpoint_URL__c.trim();
            requestWrapper.Channel = System.Label.Tractor;
            List<Opportunity> oppLst = [SELECT 
                                        Id, Product_Type__c, Vehicle_Type__c, Loan_amount__c 
                                        FROM Opportunity
                                        WHERE Id =:loanApplicationId 
                                        WITH SECURITY_ENFORCED ];
            requestWrapper.Product = oppLst[0].Product_Type__c == System.Label.Tractor ? 'T':'';
            requestWrapper.Vehicle_Type = oppLst[0].Vehicle_Type__c;
            requestWrapper.Loan_Amount = oppLst[0].Loan_amount__c;
            requestWrapper.Maker_Id = IntegrationUtilities.getMakerId();
            List<Applicant__c> appLst = [SELECT Id, Applicant_Type__c, Opportunity__r.Name, Declared_income__c
                                            FROM Applicant__c
                                            WHERE Opportunity__c =: loanApplicationId AND Applicant_Type__c != 'Beneficiary' AND In_Active_Applicant__c = false
                                            WITH SECURITY_ENFORCED
                                            ORDER BY CreatedDate ASC];
            Map<Id,List<Documents__c>> applicantDocumentsMap = new Map<Id,List<Documents__c>>();
            Integer coborrowerCount = 0;
            Integer guarantorCount = 0;
            for(Applicant__c app: appLst){
                if(app.Applicant_Type__c == System.Label.CoBorrower){
                    coborrowerCount++;
                }else if(app.Applicant_Type__c == System.Label.Guarantor){
                    guarantorCount++;
                }
            }
            
            requestWrapper.Noof_Coborrowers = String.valueOf(coborrowerCount);
            requestWrapper.Noof_Guarantors = String.valueOf(guarantorCount);
            List<Documents__c> docLst = [SELECT Id, Proof_of_Identity_POI__c, KYC_DOB__c, PAN_No__c,Document_Type__c, Applicant__c 
                                            FROM Documents__c 
                                            WHERE Applicant__c IN (SELECT Id FROM Applicant__c WHERE Opportunity__c =:loanApplicationId ) AND Is_Active__c = true
                                            WITH SECURITY_ENFORCED ];
            for(Documents__c doc: docLst){
                List<Documents__c> newDocLst = new List<Documents__c>();
                if(applicantDocumentsMap.containsKey(doc.Applicant__c)){
                    newDocLst = applicantDocumentsMap.get(doc.Applicant__c);
                    newDocLst.add(doc);
                    applicantDocumentsMap.put(doc.Applicant__c,newDocLst);
                }else{
                    newDocLst.add(doc);
                    applicantDocumentsMap.put(doc.Applicant__c,newDocLst);
                }
            }
            List<ApplicantWrapper> applicantWrapper = new List<ApplicantWrapper>();
            for(Applicant__c app: appLst){
                ApplicantWrapper newAppWrap = new ApplicantWrapper();
                newAppWrap.ApplicantType = String.valueOf(app.Applicant_Type__c);
                String applicantId = String.valueOf(app.Id);
                String code = app.Applicant_Type__c == System.Label.Borrower ? 'B': 'C';
                String leadName = String.valueOf(app.Opportunity__r.Name);
                newAppWrap.Lead_Id = leadName+'_'+code+applicantId.substring(0,15);
                newAppWrap.Income = String.valueOf(app.Declared_income__c);
                newAppWrap.Customer_CIN = '';
                if(applicantDocumentsMap.containsKey(app.Id)){
                    for(Documents__c doc: applicantDocumentsMap.get(app.Id)){
                        if(doc.Proof_of_Identity_POI__c == true){
                            newAppWrap.Date_of_Birth = String.valueOf(doc.KYC_DOB__c);
                        }
                        if(String.isNotBlank(doc.PAN_No__c) && doc.Document_Type__c == Label.PanCards){
                            String decrypt = IntegrationUtilities.getDecryptedResponse(doc.PAN_No__c,System.Label.privateKey,System.Label.ivkey);
                            newAppWrap.Customer_PAN = decrypt;
                        }
                    }
                }
                applicantWrapper.add(newAppWrap);
            }
            requestWrapper.Applicant = applicantWrapper;
            String requestToEncrypt = JSON.serialize(requestWrapper);
            System.debug('Gating API Request Generated >> '+requestToEncrypt);
            String encryptedRequest = IntegrationUtilities.getEncryptedRequest(requestToEncrypt,System.Label.privateKey,System.Label.ivkey);
            System.debug('Gating API Encrypted Request Generated >> '+encryptedRequest);
            //For testing purpose
            //encryptedRequest = 'Jl4PH7iC6IoonMUZ6mwOQoZW3QieH0n+Y4//Sznwiq8HUME6K63b/pD+JGrOQmuA+h+Ta81FinN0rzGZvUTIn7KJ2GTARCK8n8EJzJ2O5NH0ipmrXAa2qpnK9Wg0nl9F/Jb49NGXep8SLeQm0h+q8Ki9uT8mrthDyBzIe7jCBh7vq7m4BdczGraz+YtXRw/uWAeUaUCtMV9xOYcaP4xWSGQCSHKg08cATVuup3KinoMyeZiuIVjNOoYVy/RaYriNLQqag/2VmPnTQtQZf9dxe0LqXVdObuOeWNHcgByl6iYp/dOsSaZRhqcAKkyzNLzhj5i8T9CGoA6OsTss0HInnK6qPz5OIH9ueXUFb6raVHlWpeskj3xj2JTYMsLJQ9lyaRW98BzQ23cQ8wUUv8caN0ULXuJfFA6D5oBaihd4K+SmMrRTOqitv0JO/PM7W3j+bgqp4IezYo2ITIFgR32n4VdNTO6/9jCD/RANj2nbxfl2YKijBexFnoJOwq20xdrqCu7HAm3/LoJrUrGjnMeViDLNvxyCfGLV1cz76fGxQROChfM671LatZ6tKeEXyc8xRbx1Axp4r72QEiKwaYiGMm+PFh0P01cWmWVWkvpGtk51JsXbadYrdJlFjigbC+dZNTVZsemDnA+NhdYEXtHGN8mR+fGQbuCGrOz4MC6Mp9mruRFL31EcID/wlb5OIF92KKb9GvjfcslgiOYjKZ9Zt9LA6vDKfv2cDkRo6rFb9uVHUut+uiOga+yFXfFqTc0Ailj5WgtfrBZruAHQB00t1I+jW7NqhZgcf7l44JqmKE0szjHsW4cnBKU5qmsHpjY+BEOPMu9hM3/uplT24EM+NcwrnfuuGKUG6icPvWCkLXJWoJqvy8ZYwXvAOYmk3IJxtRrHFmTavMOyzAkpWPJPenyEwmX8X3quGWoVdCk6BfsP46JtEO5YDmNcZUkLPg9y';
            HttpRequest httpRequest = new HttpRequest();
            httpRequest.setMethod(methodType);
            httpRequest.setEndpoint(endpoint);
            httpRequest.setHeader('IBL-Client-Id',System.Label.IBM_Client_ID);
            httpRequest.setHeader('IBL-Client-Secret',System.Label.IBM_Client_Secret);
            httpRequest.setHeader('Content-Type', 'application/json');
            httpRequest.setBody('{"JData": "'+encryptedRequest+'"}');
            httpRequest.setTimeout(120000);
            Http http = new Http();
            HttpResponse response = http.send(httpRequest);
            Map<String , Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());

            Long startTime = DateTime.now().getTime();
            Long endTime = DateTime.now().getTime();
            String elapseTime = String.valueOf((Double)(endTime - startTime)/1000);


            String responseBody = (String) responseMap.get('JData');
            String decryptedResponse = IntegrationUtilities.getDecryptedResponse(responseBody,System.Label.privateKey,System.Label.ivkey);
            System.debug('decryptedResponse ' +decryptedResponse);
            Map<String , Object> decryptedResponseMap = (Map<String, Object>) JSON.deserializeUntyped(decryptedResponse);
            if(response.getStatusCode() == 200){
                
                Map<String , Object> applicationMap = new Map<String, Object>();
                Map<String , Object> applicationDecisionMap = new Map<String, Object>();
                if(decryptedResponseMap.containsKey('application')){
                    applicationMap = (Map<String, Object>) decryptedResponseMap.get('application');
                    if(applicationMap.containsKey('applicationDecision')){
                        applicationDecisionMap = (Map<String, Object>) applicationMap.get('applicationDecision');
                        System.debug('$$$ Final result : \n'+JSON.serialize(applicationDecisionMap));
                    }
                }
                IntegrationUtilities.createIntegrationLogger(requestToEncrypt, encryptedRequest, decryptedResponse, responseBody, System.Label.Tractor_Check_Eligibility_API_Name, elapseTime, loanApplicationId, System.Label.Success);

                return JSON.serialize(applicationDecisionMap);
            }
            else{
                IntegrationUtilities.createIntegrationLogger(requestToEncrypt, encryptedRequest, decryptedResponse, responseBody, System.Label.Tractor_Check_Eligibility_API_Name, elapseTime, loanApplicationId, System.Label.Success);
                System.debug('>>> ERROR <<< \n'+ ((Map<String, Object>)decryptedResponseMap.get('response')).get('respDesc') );
                throw new IND_Exception('Response received for Gating & Screening API : '+((Map<String, Object>)decryptedResponseMap.get('response')).get('respDesc'));            }
        }
        return null;
    } catch (Exception ex) {
        ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'doTractorGatingScreeningCheckEligibilityCallout', System.Label.Apex, ex,loanApplicationId);
        System.debug('Error '+ex.getMessage() +' at line '+ex.getLineNumber());
        throw new IND_Exception(ex.getMessage());   
    }
}
class TractorCheckEligibityRequest{
    public String Product{get;set;}
    public String Vehicle_Type{get;set;}
    public String Noof_Coborrowers{get;set;}
    public String Maker_Id{get;set;}
    public String Loan_Amount{get;set;}
    public String Channel{get;set;}
    public String Noof_Guarantors{get;set;}
    public List<ApplicantWrapper> Applicant{get;set;}
    public TractorCheckEligibityRequest(){
        this.Product = '';
        this.Vehicle_Type = '';
        this.Noof_Coborrowers = '';
        this.Maker_Id = '';
        this.Loan_Amount = '';
        this.Channel = '';
        this.Noof_Guarantors = '';
        this.Applicant = null;
    }
}
class ApplicantWrapper{
    public String ApplicantType{get;set;}
    public String parentDealNo{get;set;}
    public String Lead_Id{get;set;}
    public String Income{get;set;}
    public String Date_of_Birth{get;set;}
    public String Customer_PAN{get;set;}
    public String Customer_CIN{get;set;}
    public ApplicantWrapper(){
        this.ApplicantType = '';
        this.parentDealNo = '';
        this.Lead_Id = '';
        this.Income = '';
        this.Date_of_Birth = '';
        this.Customer_PAN = '';
        this.Customer_CIN = '';
    }
}
 /*
* @Method:      saveCustomerRelationDetails
* @Created by:  Santhosh Guhan 
* @Description: Method to save Customer Relation Details for Non-Individual Tractor loans
* @Param:       String - borrCusCode,loanapp,
* @Return:      String - response
*/
@AuraEnabled
public static String saveCustomerRelationDetails(String borrCusCode, String loanapp){
    saveCustomerRelationRequest requestWrapper = new saveCustomerRelationRequest();
    try{
        Integration_Configuration__mdt apiConfiguration = IntegrationUtilities.getAPIConfiguration('Save Customer Relation');
        Integer timeout = Integer.valueOf(apiConfiguration.Timeout__c);
        List<Applicant__c> appList = [Select Id,Customer_Code__c,Relationship_with_borrower__c,Relationship_with_Entity__c,Beneficial_Owner_Category__c,Relationship_Type__c,ShareHolding__c,POA_Holder__c from Applicant__c where Opportunity__c =: loanapp and Applicant_Type__c = 'Beneficiary' and In_Active_Applicant__c = false WITH SECURITY_ENFORCED];
        String borrCustomerCode = borrCusCode;
        
        if(!apiConfiguration.IsActive_Integration__c){
                ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'saveCustomerRelationDetails', System.Label.Apex, new AuraHandledException('Integration is not Active'));
                throw new AuraHandledException('Integration is not Active');       
            }
        String elapseTime='';
        String methodType = apiConfiguration.Rest_Method__c.trim();
        String endpoint ='callout:Indus_API' + apiConfiguration.Endpoint_URL__c.trim();
        List<BeneApplicantWrapper> applicantWrapper = new List<BeneApplicantWrapper>();
        integer count = 0;
        String makerId = IntegrationUtilities.getMakerId();
        for(Applicant__c app: appList){
                BeneApplicantWrapper newAppWrap = new BeneApplicantWrapper();
                newAppWrap.Customer_Code = borrCustomerCode;
                newAppWrap.Relation_Customer_Code = app.Customer_Code__c;
                newAppWrap.SlNo = ++count;
                if(app.Beneficial_Owner_Category__c == 'Beneficial Owner' || app.Beneficial_Owner_Category__c == 'Beneficial Owner cum Co-borrower'){
                newAppWrap.Beneficial_Owner_Category = 'O';
                }else if(app.Beneficial_Owner_Category__c == 'Controlling Person'){
                newAppWrap.Beneficial_Owner_Category = 'C';
                }else if(app.Beneficial_Owner_Category__c == 'Authorised Signatory'){
                newAppWrap.Beneficial_Owner_Category = 'S';
                }
                newAppWrap.Relationship = app.Relationship_with_Entity__c;
                newAppWrap.Relation_Type = app.Relationship_Type__c;
                newAppWrap.Status = 'IND';
                newAppWrap.Control_Percent = app.ShareHolding__c;
                if(app.Beneficial_Owner_Category__c == 'Authorised Signatory'){
                newAppWrap.Authorised_Signatory_YN ='Y';
                } else {
                newAppWrap.Authorised_Signatory_YN ='N';
                }
                if(app.Beneficial_Owner_Category__c == 'Beneficial Owner'){
                newAppWrap.Beneficial_Owner_YN ='Y';
                }else {
                newAppWrap.Beneficial_Owner_YN ='N';
                }
                newAppWrap.Beneficial_Owner_YN ='';
                if(app.POA_Holder__c == true){
                newAppWrap.POA_Holder_YN = 'Y';
                }else{
                newAppWrap.POA_Holder_YN = 'N';
                }
                newAppWrap.Maker_ID = makerId;
                applicantWrapper.add(newAppWrap);
            }
            requestWrapper.CustomerRelation = applicantWrapper;
            system.debug('requestwrapper----'+requestWrapper);
            String requestEncrypt = JSON.serialize(requestWrapper);
            system.debug('requestwrapperEncrypt----'+requestEncrypt);
            String encryptedRequest = IntegrationUtilities.getEncryptedRequest(requestEncrypt,System.Label.privateKey,System.Label.ivkey);
            system.debug('requestwrapperEncrypted----'+encryptedRequest);
            Http http = new Http();
            HttpRequest httpRequest = new HttpRequest();
            httpRequest.setMethod(methodType);
            httpRequest.setEndpoint(endpoint);
            httpRequest.setHeader('IBL-Client-Id',System.Label.IBM_Client_ID);
            httpRequest.setHeader('IBL-Client-Secret',System.Label.IBM_Client_Secret);
            httpRequest.setHeader('Content-Type', 'application/json');
            httpRequest.setBody('{"JData": "'+encryptedRequest+'"}');
            HttpResponse response = new HttpResponse();
            Long startTime = DateTime.now().getTime();
            response = http.send(httpRequest);
            Long endTime = DateTime.now().getTime();
            elapseTime = String.valueOf((Double)(endTime - startTime)/1000);
            Map<String , Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            String responseBody = (String) responseMap.get('JData');
            System.debug('encryptedResponse ' +responseBody);
            String decryptedResponse = IntegrationUtilities.getDecryptedResponse(responseBody,System.Label.privateKey,System.Label.ivkey);
            System.debug('decryptedResponse ' +decryptedResponse);
            Map<String , Object> decryptedResponseMap = (Map<String, Object>) JSON.deserializeUntyped(decryptedResponse);
            system.debug('statuscode-----'+response.getStatusCode());
            if(response.getStatusCode() == 200){
                IntegrationUtilities.createIntegrationLogger(requestEncrypt, encryptedRequest, IntegrationUtilities.getPlainTextForLog(response.getBody()), response.getBody(), 'Save Customer Relation', elapseTime, loanapp, System.Label.Success);
                return 'success';
            } else{
                IntegrationUtilities.createIntegrationLogger(requestEncrypt, encryptedRequest, decryptedResponse, '', 'Save Customer Relation', elapseTime, loanapp, System.Label.Failure);
                return 'failure';
            }
    } catch(Exception ex) {
        ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'saveCustomerRelationDetails', System.Label.Apex, ex,loanapp);
    throw ex;
}
}
class saveCustomerRelationRequest{
    public List<BeneApplicantWrapper> CustomerRelation{get;set;}
    public saveCustomerRelationRequest(){
    this.CustomerRelation = null;
    }
}
class BeneApplicantWrapper{
    public String Customer_Code{get;set;}
    public String Relation_Customer_Code{get;set;}
    public Integer SlNo{get;set;}
    public String Beneficial_Owner_Category{get;set;}
    public String Relationship{get;set;}
    public String Relation_Type{get;set;}
    public String Status{get;set;}
    public Decimal Control_Percent{get;set;}
    public String Authorised_Signatory_YN{get;set;}
    public String Beneficial_Owner_YN{get;set;}
    public String POA_Holder_YN{get;set;}
    public String Maker_ID{get;set;}
    public BeneApplicantWrapper(){
        this.Customer_Code = '';
        this.Relation_Customer_Code = '';
        this.SlNo = null;
        this.Beneficial_Owner_Category = '';
        this.Relationship = '';
        this.Relation_Type = '';
        this.Status = '';
        this.Control_Percent = null;
        this.Authorised_Signatory_YN = '';
        this.Beneficial_Owner_YN = '';
        this.POA_Holder_YN = '';
        this.Maker_ID = '';
    }
}
}