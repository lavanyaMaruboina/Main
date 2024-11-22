public with sharing class IntegrationEngine_Helper {

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
                                First_Name__c, Last_Name__c, Father_Name__c, KYC_DOB__c, Address__c,KYC_Address_Line_1__c,KYC_Address_Line_2__c, KYC_City__c, KYC_District__c, KYC_State__c, KYC_Pin_Code__c, 
                                Mobile_Number__c, Aadhaar_Enrollment_Number__c,
                                PAN_Acknowledgement_Number__c, Estimated_Annual_Income__c,
                                Age__c, Gender__c, Amount_of_Transaction__c,Document_Type__c
                         FROM Documents__r WHERE Document_Type__c = 'Form 60' LIMIT 1) FROM Applicant__c WHERE id =: applicantId AND In_Active_Applicant__c = FALSE]; 
    
                         List<User> userList = [SELECT Id, User_Id__c FROM User WHERE Id IN (SELECT CreatedById FROM Opportunity WHERE Id = :loanAppId)];
    
    
                requestWrapper.Customer_Code = (!eqList.isEmpty() && String.isNotBlank(eqList[0].Customer_Code__c)) ? eqList[0].Customer_Code__c : '';
                requestWrapper.Maker_Id =(!userList.isEmpty() && String.isNotBlank(userList[0].User_Id__c)) ? userList[0].User_Id__c.substringBefore('_') : ''; 
                
        if (!eqList.isEmpty() && eqList[0].Documents__r.size() > 0) {
        Documents__c document = eqList[0].Documents__r[0];
        requestWrapper.Document_Type = document.Document_Type__c != null ? document.Document_Type__c : '';
        requestWrapper.First_Name = document.First_Name__c != null ? document.First_Name__c : '';
        requestWrapper.Last_Name = document.Last_Name__c != null ? document.Last_Name__c : '';
        requestWrapper.Father_Name = document.Father_Name__c != null ? document.Father_Name__c : '';
        requestWrapper.DOB = document.KYC_DOB__c != null ? document.KYC_DOB__c : null;
        requestWrapper.Address_Line_1 = (document.KYC_Address_Line_1__c != null) ? document.KYC_Address_Line_1__c : (document.Address__c != null ? document.Address__c : ''); 
        requestWrapper.Address_Line_2 = (document.KYC_Address_Line_2__c != null) ? document.KYC_Address_Line_2__c : (document.Address__c != null ? document.Address__c : ''); 
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
    
    /* @Method:     Service API
    * @Created by:  Raghav J.
    * @Description: Method to call Service API for Synergy flow
    * @Param:       String - loanAppId
    * @Return:      return a string based on Response
    */
    @AuraEnabled(continuation=true)
    public static String serviceAPI(string loanAppId){ 

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        HttpResponse response = new HttpResponse();
        String responseBody ='';   
        String returnStr ='';    
        String elapseTime = ''; 
        try{   
            Integration_Configuration__mdt apiConfiguration = IntegrationUtilities.getAPIConfiguration(System.Label.Service_Enquiry);

            if(apiConfiguration != null){
                if(!apiConfiguration.IsActive_Integration__c){
                    ErrorLoggerUtil.logErrorEvent('IntegrationEngine', System.Label.Service_Enquiry, System.Label.Apex, new AuraHandledException('Integration is not Active'));
                    throw new AuraHandledException('Integration is not Active');       
                }
                String methodType = apiConfiguration.Rest_Method__c.trim();
                String endpoint ='callout:Indus_API'+apiConfiguration.Endpoint_URL__c.trim();
            
                ServiceAPIRequest requestWrapper = new ServiceAPIRequest();
                List<Enquiry__c> eqList = [SELECT id,Name,Referred_to_Branch__c,Journey_Type__c,Loan_amount__c,Customer_code__c,  Mobile_Number_2__c, CIF_ID__c, Enquiry_Status__c, Remarks__c,Campaign_Type__c, Deal_No__c, Lead_Reference_ID__c,Customer_Name__c,Mobile_Number_1__c,Email__c,Product__c,Product_category__c, PAN_no__c,Source__c   FROM Enquiry__c 
                WHERE Id = : loanAppId];

                String currentUserId = UserInfo.getUserId();
                User currentUser = [SELECT Id, User_Id__c FROM User WHERE Id = :currentUserId LIMIT 1];
                if (currentUser != null ){
                    //Added by Rajasekar as part of CISP-21691 - Starts
                    if(currentUser.User_Id__c != null && !currentUser.User_Id__c.isNumeric()){
                        List<String> UserIdSplittedList = currentUser.User_Id__c.split('_');
                        for(String str:UserIdSplittedList){
                            if(str.isNumeric()){
                                requestWrapper.agentId = str;
                            }
                        }
                    }else if(currentUser.User_Id__c != null && currentUser.User_Id__c.isNumeric()){
                        requestWrapper.agentId = currentUser.User_Id__c;
                    }
                    //Added by Rajasekar as part of CISP-21691 - Ends
                    requestWrapper.Bl_Code = ''; 
                }
        
                if(!eqList.isEmpty()){
                    Enquiry__c enquiry = eqList[0];
                    requestWrapper.EnquiryNumber = enquiry.Name != null ? enquiry.Name : '';
                    requestWrapper.LeadId = enquiry.Lead_Reference_ID__c != null ? enquiry.Lead_Reference_ID__c : '';
                    requestWrapper.LoanAmount = enquiry.Loan_amount__c != null ? enquiry.Loan_amount__c : null;
                    requestWrapper.Customer_Code = enquiry.Customer_code__c != null ? enquiry.Customer_code__c : '';
                    requestWrapper.Customer_Name = enquiry.Customer_Name__c != null ? enquiry.Customer_Name__c : '';
                    requestWrapper.Mobile_No = enquiry.Mobile_Number_1__c != null ? enquiry.Mobile_Number_1__c : '';
                    requestWrapper.Mobile_No_2 = enquiry.Mobile_Number_2__c != null ? enquiry.Mobile_Number_2__c : '';
                    requestWrapper.Cif_Id = enquiry.CIF_ID__c != null ? enquiry.CIF_ID__c : '';
                    requestWrapper.Email = enquiry.Email__c != null ? enquiry.Email__c : '';
                    requestWrapper.Product = enquiry.Product__c != null ? enquiry.Product__c : '';
                    requestWrapper.ProductCategory = enquiry.Product_category__c != null ? enquiry.Product_category__c : '';
                    requestWrapper.Pan_Number = enquiry.PAN_no__c != null ? enquiry.PAN_no__c : '';
                    requestWrapper.Source = enquiry.Source__c != null ? enquiry.Source__c : '';
                    requestWrapper.ReferredToBranch = enquiry.Referred_to_Branch__c != null ? enquiry.Referred_to_Branch__c : '';
                    requestWrapper.Enquiry_Status = enquiry.Enquiry_Status__c != null ? enquiry.Enquiry_Status__c : '';
                    requestWrapper.EnquiryStatusCategory = '';//need to check
                    requestWrapper.Comments = enquiry.Remarks__c != null ? enquiry.Remarks__c : '';
                    requestWrapper.Enquiry_Flow = '';
                    requestWrapper.Campaign_Type = enquiry.Campaign_Type__c != null ? enquiry.Campaign_Type__c : '';
                    requestWrapper.Deal_Number = enquiry.Deal_No__c != null ? enquiry.Deal_No__c : '';
            
                }

                System.debug('++++berRequest '+requestWrapper);
                String requestBody = JSON.serialize(requestWrapper);
                system.debug('++++requestBody '+requestBody);
                //String requestBody = '{ "EnquiryNumber": "EQ0656160", "LeadId": "78913472", "agentId": "120503", "LoanAmount": "900000.00", "Customer_Code": "", "Customer_Name": "Lokesh kalahasthi", "Mobile_No": "9573076777", "Mobile_No_2": "", "Cif_Id": "", "Source": "CRMNEXT", "Deal_Number": "", "Product": "", "ProductCategory": "NEW", "ReferredToBranch": "TIRUPATI, ANDHRA PRADESH", "Bl_Code": "ANT", "Campaign_Type": "", "Email": "", "Pan_Number": "", "Enquiry_Status": "Not Interested", "EnquiryStatusCategory": "", "Comments": "LastModified By:Paturu Rajesh LastModified On:21-03-2024 1:14:22 PM new car loan urgent", "Enquiry_Flow": "" }';


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

                    Service_API_ResponseParser serviceResponse = new Service_API_ResponseParser();
                    serviceResponse = Service_API_ResponseParser.parse(searalizedJson);
                    Service_API_ResponseParser.Response jsonResponse = serviceResponse.response;
                    String respDesc = jsonResponse.respDesc;
                    String status = jsonResponse.status;
                    System.debug('++++cRIFFAPICall jsonResponse ' +jsonResponse);

                    if(status == 'SUCCESS'){
                        IntegrationUtilities.createIntegrationLogger(requestBody, requestBodyJSON, returnStr, response.getBody(), System.Label.Service_Enquiry, elapseTime, loanAppId, System.Label.Success);
                        returnStr = 'Success';
                    }
                    else{
                        IntegrationUtilities.createIntegrationLogger(requestBody, requestBodyJSON, returnStr, response.getBody(),System.Label.Service_Enquiry , elapseTime, loanAppId, System.Label.Failure);
                        returnStr = 'Error';
                    }
                }
                else {
                    System.debug('++++ not 200 response.getStatusCode() ' +response.getStatusCode());
                    returnStr = 'Error';
                    String errString = '[Status Code = '+ response.getStatusCode() +' ] Response-->'+IntegrationUtilities.getPlainTextForLog(response.getBody());
                    IntegrationUtilities.createIntegrationLogger(requestBody, requestBodyJSON, errString, response.getBody(), System.Label.Service_Enquiry, elapseTime, loanAppId, System.Label.Failure);     
                    } 
            }}
        catch (Exception ex) {
            ErrorLoggerUtil.logErrorEvent('IntegrationEngine', System.Label.Service_Enquiry, System.Label.Apex, ex,loanAppId);
            System.debug('Error '+ex.getMessage() +' at line '+ex.getLineNumber());
            throw new IND_Exception(ex.getMessage() + 'Stack : '+ex.getStackTraceString()); 
        }
        return returnStr; //Add response string 
    }

    /* @Method:     Update_Reverse_Status_CRMNEXT
    * @Created by:  Raghav J.
    * @Description: Method to call Reverse status for Synergy flow
    * @Param:       String - loanAppId
    * @Return:      return a string based on Response
    */
    @AuraEnabled(continuation=true)
    public static String synergyReverseStatus(string loanAppId){ 

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        HttpResponse response = new HttpResponse();
        String responseBody ='';   
        String returnStr ='';    
        String elapseTime = ''; 
        try{   
            Integration_Configuration__mdt apiConfiguration = IntegrationUtilities.getAPIConfiguration(System.Label.Reverse_Status_CRMNEXT);

            if(apiConfiguration != null){
                if(!apiConfiguration.IsActive_Integration__c){
                    ErrorLoggerUtil.logErrorEvent('IntegrationEngine', System.Label.Reverse_Status_CRMNEXT, System.Label.Apex, new AuraHandledException('Integration is not Active'));
                    throw new AuraHandledException('Integration is not Active');       
                }
                String methodType = apiConfiguration.Rest_Method__c.trim();
                String endpoint ='callout:Indus_API'+apiConfiguration.Endpoint_URL__c.trim();
                
                SynergyReverseStatusRequest requestWrapper = new SynergyReverseStatusRequest();


                if (loanAppId.startsWith('006')) { // Assuming Opportunity ID starts with '006'
                    List<Opportunity> oppList = [SELECT Id, Lead_number__c,StageName,Loan_amount__c FROM Opportunity WHERE Id = :loanAppId];
                    
                    if (!oppList.isEmpty()) {
                        Opportunity opportunity = oppList[0];
                        
                        LeadReverseStatus leadReverseStatus = new LeadReverseStatus();
                        leadReverseStatus.Talisma_Id = '123'; // it requires an id so what to send here and only number    
                        leadReverseStatus.AssignTo = '1';
                        leadReverseStatus.Reference_Number_Lead = opportunity.Lead_number__c != null ? opportunity.Lead_number__c : '';
                        leadReverseStatus.Amount_Lead = opportunity.Loan_amount__c != null ? Decimal.valueOf(opportunity.Loan_amount__c) : null;
                        leadReverseStatus.Reverse_Feed_status_Lead = opportunity.StageName != null ? opportunity.StageName : ''; //update according to where its called
                        leadReverseStatus.Rejection_Reason_Lead = '';

                        requestWrapper.Lead_Reverse_Status = leadReverseStatus;
                    }
                } else {
                    List<Enquiry__c> eqList = [SELECT id,Loan_amount__c, Enquiry_Status__c,Reason__c,  Lead_Reference_ID__c FROM Enquiry__c 
                    WHERE Id = : loanAppId];
        
                    if(!eqList.isEmpty()){
                        Enquiry__c enquiry = eqList[0];
        
                        LeadReverseStatus leadReverseStatus = new LeadReverseStatus();
                        leadReverseStatus.Talisma_Id = enquiry.Lead_Reference_ID__c != null ? enquiry.Lead_Reference_ID__c : '';    
                        leadReverseStatus.AssignTo = '1';
                        leadReverseStatus.Reference_Number_Lead = '';
                        leadReverseStatus.Amount_Lead = enquiry.Loan_amount__c != null ? enquiry.Loan_amount__c : null;
                        leadReverseStatus.Reverse_Feed_status_Lead = enquiry.Enquiry_Status__c != null ? enquiry.Enquiry_Status__c : '';
                        leadReverseStatus.Rejection_Reason_Lead = enquiry.Reason__c != null ? enquiry.Reason__c : '';
        
        
                        requestWrapper.Lead_Reverse_Status = leadReverseStatus;
                    }

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

                    ReverseStatusCRMNEXT_ResponseParser serviceResponse = new ReverseStatusCRMNEXT_ResponseParser();
                    serviceResponse = ReverseStatusCRMNEXT_ResponseParser.parse(searalizedJson);
                    ReverseStatusCRMNEXT_ResponseParser.Response jsonResponse = serviceResponse.response;
                    String respDesc = jsonResponse.respDesc;
                    String status = jsonResponse.status;
                    System.debug('++++cRIFFAPICall jsonResponse ' +jsonResponse);

                    if(status == 'SUCCESS'){
                        
                        IntegrationUtilities.createIntegrationLogger(requestBody, requestBodyJSON, returnStr, response.getBody(), System.Label.Reverse_Status_CRMNEXT, elapseTime, loanAppId, System.Label.Success);
                        returnStr = 'Success';
                    }
                    else{
                        IntegrationUtilities.createIntegrationLogger(requestBody, requestBodyJSON, returnStr, response.getBody(), System.Label.Reverse_Status_CRMNEXT, elapseTime, loanAppId, System.Label.Failure);
                        returnStr = 'Error';
                    }
                }
                else {
                    System.debug('++++ not 200 response.getStatusCode() ' +response.getStatusCode());
                    returnStr = 'Error';
                    String errString = '[Status Code = '+ response.getStatusCode() +' ] Response-->'+IntegrationUtilities.getPlainTextForLog(response.getBody());
                    IntegrationUtilities.createIntegrationLogger(requestBody, requestBodyJSON, errString, response.getBody(),System.Label.Reverse_Status_CRMNEXT, elapseTime, loanAppId, System.Label.Failure);     
                    } 
            }}
        catch (Exception ex) {
            ErrorLoggerUtil.logErrorEvent('IntegrationEngine', System.Label.Reverse_Status_CRMNEXT, System.Label.Apex, ex,loanAppId);
            System.debug('Error '+ex.getMessage() +' at line '+ex.getLineNumber());
            throw new IND_Exception(ex.getMessage() + 'Stack : '+ex.getStackTraceString()); 
        }
        return returnStr; //Add response string 
    }

    class SynergyReverseStatusRequest{
        public LeadReverseStatus Lead_Reverse_Status{get;set;}
    }

    public class LeadReverseStatus {
        public String Talisma_Id { get; set; }
        public String AssignTo { get; set; }
        public String Reference_Number_Lead { get; set; }
        public Decimal Amount_Lead { get; set; } // Assuming this is a Decimal field
        public String Reverse_Feed_status_Lead { get; set; }
        public String Rejection_Reason_Lead { get; set; }
    }

    @InvocableMethod(label = 'CRMNEXT Reverse Status API')
    public static void doSynergyReverseStatusCallout(List<FlowInputs> loanAppId){
        List<opportunity> optylist=[select id,stagename,LeadSource from opportunity where id=:loanAppId[0].LoanId limit 1];
        List<Key_Fact_Statement__c> keyfactList = [SELECT id,Keyfact_Consent_Not_Accepted__c,Keyfact_Consent_Need_Clarification__c,Keyfact_Consent_Accepted__c,Keyfact_Consent_Received_Time__c FROM Key_Fact_Statement__c WHERE id=:loanAppId[0].keyfactId WITH SECURITY_ENFORCED limit 1];
        if((optylist.size()>0) && (optylist[0].LeadSource == 'Synergy')){
            try{
                System.enqueueJob(new IND_ReverseStatusCalloutSynergyQueueable(loanAppId[0].LoanId,loanAppId[0].status));
            } catch(Exception ex) {
                ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'doSynergyReverseStatusCallout', System.Label.Apex, ex,optylist[0].id);
                throw ex;
            }   
        }
        if((keyfactList.size()>0) && (keyfactList[0].Keyfact_Consent_Not_Accepted__c == true || keyfactList[0].Keyfact_Consent_Need_Clarification__c == true || keyfactList[0].Keyfact_Consent_Accepted__c == true ) && keyfactList[0].Keyfact_Consent_Received_Time__c != null){
            try{
                System.enqueueJob(new IND_ReverseStatusCalloutKFSQueueable(loanAppId[0].keyfactId,loanAppId[0].status));
            } catch(Exception ex) {
                ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'doSynergyReverseStatusCallout', System.Label.Apex, ex,keyfactList[0].id);
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
        public String keyfactId;

    }

    /*
    * @Method:      Doc Auth API
    * @Created by:  Raghav J.
    * @Description: Method to call Doc Auth API for Aadhaar Verify
    * @Param:       String - applicantId , String documentId
    * @Return:      return a string based on Response
    */
    @AuraEnabled(continuation=true)
    public static String DemoAuthAPI(string applicantId, string documentId,string loanApplicationId){ 
    
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        HttpResponse response = new HttpResponse();
        String responseBody ='';   
        String returnStr ='';    
        String elapseTime = ''; 
        Long startTime;
        String requestBody = '';
        String encryptedRequestBody = '';
        try{   
            Integration_Configuration__mdt apiConfiguration = IntegrationUtilities.getAPIConfiguration('DemoAuth');
            if(apiConfiguration != null){
                if(!apiConfiguration.IsActive_Integration__c){
                    ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'DemoAuth', System.Label.Apex, new AuraHandledException('Integration is not Active'));
                    throw new AuraHandledException('Integration is not Active');       
                }
                String methodType = apiConfiguration.Rest_Method__c.trim();
                String endpoint =apiConfiguration.Endpoint_URL__c;
            
                DemoAuthRequestWrapper requestWrapper = new DemoAuthRequestWrapper();
                List<Documents__c> docList = [select id,Loan_applicarion_ID__c,KYC_name__c,Gender__c,KYC_DOB__c,Applicant__r.Contact_number__c,KYC_Pin_Code__c,KYC_No__c from Documents__c where Document_Type__c = 'Aadhaar' AND id = : documentId];
    
                if (!docList.isEmpty()) {
                    Documents__c document = docList[0];
                    requestWrapper.request.header.requestUUID = String.valueOf(System.currentTimeMillis()) + String.valueOf(Math.round(Math.random() * 1000000));
                    requestWrapper.request.header.channelId = 'CSF'; //default
                    requestWrapper.request.header.applicationId = document.Loan_applicarion_ID__c != null ? document.Loan_applicarion_ID__c : '';
    
                    requestWrapper.request.body.demoAuthRequest.pi.name = document.KYC_name__c != null ? document.KYC_name__c : '';
                    requestWrapper.request.body.demoAuthRequest.pi.gender = document.Gender__c != null ? (document.Gender__c == 'Male' ? 'M' : (document.Gender__c == 'Female' ? 'F' : '')) : '';
                    requestWrapper.request.body.demoAuthRequest.pi.dob = document.KYC_DOB__c != null ? String.valueOf(document.KYC_DOB__c) : '';
                    requestWrapper.request.body.demoAuthRequest.pi.phone = document.Applicant__r.Contact_number__c != null ? document.Applicant__r.Contact_number__c : '';
            
                    requestWrapper.request.body.demoAuthRequest.pa.postalCode = document.KYC_Pin_Code__c != null ? document.KYC_Pin_Code__c : '';
            
                    requestWrapper.request.body.demoAuthRequest.uid = IntegrationUtilities.getDecryptedResponse(document.KYC_No__c,System.Label.privateKey,System.Label.ivkey);
    
                }
                requestBody = JSON.serialize(requestWrapper);
                //String requestBody = '{ "request": { "header": { "requestUUID": "1234", "channelId": "CSF" }, "body": { "demoAuthRequest": { "pi": { "name": "Raghav", "gender": "M", "dob": "2000-01-13", "phone": "9138420233" }, "pa": { "postalCode": "132041" }, "uid": "428420284324" } } } }';
                system.debug('++++requestBody '+requestBody);
    
                encryptedRequestBody = IntegrationUtilities.getEncryptedRequest(requestBody,System.Label.privateKey,System.Label.ivkey);  
                Map<String, String> requestData = new Map<String, String>();
                requestData.put('JData', encryptedRequestBody);
                String requestBodyJSON = JSON.serialize(requestData);
                system.debug('++++body '+requestBodyJSON); 
                
                startTime = DateTime.now().getTime();
                
                request.setEndpoint(endpoint);
                request.setHeader(System.Label.X_IBM_Client_Id,System.Label.IBM_Client_ID);
                request.setHeader(System.Label.X_IBM_Client_Secret,System.Label.IBM_Client_Secret);
                request.setHeader('Content-Type', 'application/json');
                request.setMethod('POST');
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
    
                    DemoAuth_ResponseParser serviceResponse = new DemoAuth_ResponseParser();
                    serviceResponse = DemoAuth_ResponseParser.parse(searalizedJson);
                    DemoAuth_ResponseParser.Response jsonResponse = serviceResponse.response;
                    String status = jsonResponse.header.status;
                    String responseMsg = jsonResponse.body.demoAuthResponse.ResponseMsg;
                    String responseCode = jsonResponse.body.demoAuthResponse.ResponseCode;
                    //if(status == 'SUCCESS'){
                        if(responseCode == '00'){
                        
                        IntegrationUtilities.createIntegrationLogger(requestBody, requestBodyJSON, returnStr, response.getBody(), 'DemoAuth', elapseTime, loanApplicationId, System.Label.Success);
                        returnStr = 'Success';
                    }
                                    //else if(responseMsg.contains('NOT MATCH')){
                                    else if(responseCode == 'U1'){
                        IntegrationUtilities.createIntegrationLogger(requestBody, requestBodyJSON, returnStr, response.getBody(), 'DemoAuth', elapseTime, loanApplicationId, System.Label.Failure);
                        returnStr = 'Rejected';
                    }
                    else{
                        IntegrationUtilities.createIntegrationLogger(requestBody, requestBodyJSON, returnStr, response.getBody(), 'DemoAuth', elapseTime, loanApplicationId, System.Label.Failure);
                        returnStr = 'Error';
                    }
                } else {
                    System.debug('++++ not 200 response.getStatusCode() ' +response.getStatusCode());
                    returnStr = 'Error';
                    system.debug('inside else');
                    System.debug('status code is '+response.getStatusCode());
                    //System.debug('status code is '+IntegrationUtilities.getPlainTextForLog(response.getBody()));
                    //String errString = '[Status Code = '+ response.getStatusCode() +' ] Response-->'+IntegrationUtilities.getPlainTextForLog(response.getBody());
                   
                    IntegrationUtilities.createIntegrationLogger(requestBody,requestBodyJSON, response.getBody(), response.getBody(), 'DemoAuth', elapseTime, loanApplicationId, System.Label.Success);
                } 
            }
        } catch (Exception ex) {
            Long endTime = DateTime.now().getTime();
            elapseTime = String.valueOf((Double)(endTime - startTime)/1000);
            IntegrationUtilities.createIntegrationLogger(requestBody, encryptedRequestBody, '', '', 'DemoAuth', elapseTime,loanApplicationId,System.Label.Failure);
            ErrorLoggerUtil.logErrorEvent('IntegrationEngine', 'DemoAuth', System.Label.Apex, ex,loanApplicationId);
            System.debug('Error '+ex.getMessage() +' at line '+ex.getLineNumber());
            throw new IND_Exception(ex.getMessage() + 'Stack : '+ex.getStackTraceString()); 
        }
        return returnStr; //Add response string 
    }
    
    class DemoAuthRequestWrapper{
        public Request request { get; set; }
        public DemoAuthRequestWrapper() {
            this.request = new Request();
        }
    }
    public class Request {
        public Header header { get; set; }
        public Body body { get; set; }
        public Request() {
            this.header = new Header();
            this.body = new Body();
        }
    }
    
    public class Header {
        public String requestUUID { get; set; }
        public String channelId { get; set; }
        public String applicationId { get; set; }
    }
    
    public class Body {
        public DemoAuthRequest demoAuthRequest { get; set; }
        public Body() {
            this.demoAuthRequest = new DemoAuthRequest();
        }
    }
    
    public class DemoAuthRequest {
        public Pi pi { get; set; }
        public Pa pa { get; set; }
        public String uid { get; set; }
        public DemoAuthRequest() {
            this.pi = new Pi();
            this.pa = new Pa();
        }
    }
    
    public class Pi {
        public String name { get; set; }
        public String gender { get; set; }
        public String dob { get; set; }
        public String phone { get; set; }
    }
    
    public class Pa {
        public String postalCode { get; set; }
    }
    
    class ServiceAPIRequest{
        public String EnquiryNumber { get; set; }
        public String LeadId { get; set; }
        public String agentId { get; set; }
        public Decimal LoanAmount { get; set; }
        public String Customer_Code { get; set; }
        public String Customer_Name { get; set; }
        public String Mobile_No { get; set; }
        public String Mobile_No_2 { get; set; }
        public String Cif_Id { get; set; }
        public String Source { get; set; }
        public String Deal_Number { get; set; }
        public String Product { get; set; }
        public String ProductCategory { get; set; }
        public String ReferredToBranch { get; set; }
        public String Bl_Code { get; set; }
        public String Campaign_Type { get; set; }
        public String Email { get; set; }
        public String Pan_Number { get; set; }
        public String Enquiry_Status { get; set; }
        public String EnquiryStatusCategory { get; set; }
        public String Comments { get; set; }
        public String Enquiry_Flow { get; set; }
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
}