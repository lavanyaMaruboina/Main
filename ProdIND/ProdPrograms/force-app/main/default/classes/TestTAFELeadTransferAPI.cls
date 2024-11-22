@isTest
private class TestTAFELeadTransferAPI {
    
    private class MockHttpResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            String response = '{"response":{"status":"SUCCESS","respDesc":"SMS has been sent successfully.","content":[{"Transaction_Id":" 5000000000000000000-30000000000000000\\n"}]}}';
            //String jdataRequest = '"bffData":';
            String encryptedResponse = IntegrationUtilities.getEncryptedRequest(response, System.Label.privateKey, System.Label.ivkey);  
            //String encryptedResponse = IntegrationUtilities.getEncryptedRequest(response,System.Label.privateKey,System.Label.ivkey); 
            String jdataRequest = '"JData":';
            res.setBody('{'+jdataRequest+'"'+encryptedResponse+'}');
            return res;
        }
    }
    @isTest
    static void testUploadLeadDetails() {
        System_Configuration__c sysConfig = new System_Configuration__c();
        sysConfig.Name = 'System Configuration';
        sysConfig.Eligible_Roles_for_BE_Assignment__c = 'BE,CS';
        sysConfig.Eligible_Roles_for_CS_Assignment__c = 'CS,MA';
        sysConfig.Eligible_Roles_for_MA_Assignment__c = 'MA,MO';
        sysConfig.Eligible_Roles_for_MO_Assignment__c = 'BE,CS,MA,MO';
        sysConfig.Application_Date__c = System.today();
        insert sysConfig;
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
  
        RestRequest req = new RestRequest();
        RestResponse response = new RestResponse();
        req.requestURI = '/services/apexrest/v1/tafeleadTransferAPI/';
        req.httpMethod = 'POST';
		req.addHeader('Content-Type', 'application/json');
        
        String requestBody = '{ "dealerPincode": 600034, "applicationNumber": "TF19062400001", "name": "Pawan shani", "currentAddressPincode": "754123", "make": "TAFETRACT", "model": "MF241ULTRA HDPDS325.1GB MSPTO PS1104HP42", "variant": "MF241ULTRA HDPDS325.1GB MSPTO PS1104HP42", "vehiclePrice": 600000, "chargerPrice": 0, "insurancePrice": 0, "handlingCharges": 0, "helmet": 0, "fameSubsidy": 0, "performanceUpgrade": 0, "cgst": 0, "sgst": 0, "igst": 0, "rtoRoadTax": 0, "iblORP": 0, "loanAmount": "505000", "crmIRR": 18, "tenure": 24, "emi": 14000, "documentationCharge": "", "processingCharge": "", "stampDuty": "", "downpayment": 0, "leadSource": "TAFE", "dealerCode": "BEN072075", "dealerName": "", "applicantDetails": [ { "dob": "2000-01-01", "phone": "9867739179", "pan": "ENEPS2667E", "emailId": "abc@gmail.com", "maritalStatus": "UNMAR", "profile": "", "category": "", "typeOfApplicant": "Borrower", "name": "Pawan Sahani" } ] }';
       	String encryptedRequestBody = IntegrationUtilities.getEncryptedRequest(requestBody,System.Label.privateKey,System.Label.ivkey);  
        Map<String, String> requestData = new Map<String, String>();
        requestData.put('JData', encryptedRequestBody);
        String requestBodyJSON = JSON.serialize(requestData);
        req.requestBody = Blob.valueOf(requestBodyJSON);
        RestContext.request = req;
		RestContext.response =response;
        
        Test.startTest();
        TAFELeadTransferAPI.uploadLeadDetails();
        Test.stopTest();

        // Validate the response
        RestResponse res = RestContext.response;
        System.assertEquals(201, res.statusCode);
    }
    
    @isTest
    static void testUploadLeadNameCheck1() {
        System_Configuration__c sysConfig = new System_Configuration__c();
        sysConfig.Name = 'System Configuration';
        sysConfig.Eligible_Roles_for_BE_Assignment__c = 'BE,CS';
        sysConfig.Eligible_Roles_for_CS_Assignment__c = 'CS,MA';
        sysConfig.Eligible_Roles_for_MA_Assignment__c = 'MA,MO';
        sysConfig.Eligible_Roles_for_MO_Assignment__c = 'BE,CS,MA,MO';
        sysConfig.Application_Date__c = System.today();
        insert sysConfig;
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
  
        RestRequest req = new RestRequest();
        RestResponse response = new RestResponse();
        req.requestURI = '/services/apexrest/v1/tafeleadTransferAPI/';
        req.httpMethod = 'POST';
		req.addHeader('Content-Type', 'application/json');
        
        String requestBody = '{ "dealerPincode": 600034, "applicationNumber": "TF19062400001", "name": "Pawan shani TEST2", "currentAddressPincode": "754123", "make": "TAFETRACT", "model": "MF241ULTRA HDPDS325.1GB MSPTO PS1104HP42", "variant": "MF241ULTRA HDPDS325.1GB MSPTO PS1104HP42", "vehiclePrice": 600000, "chargerPrice": 0, "insurancePrice": 0, "handlingCharges": 0, "helmet": 0, "fameSubsidy": 0, "performanceUpgrade": 0, "cgst": 0, "sgst": 0, "igst": 0, "rtoRoadTax": 0, "iblORP": 0, "loanAmount": "505000", "crmIRR": 18, "tenure": 24, "emi": 14000, "documentationCharge": "", "processingCharge": "", "stampDuty": "", "downpayment": 0, "leadSource": "TAFE", "dealerCode": "BEN072075", "dealerName": "", "applicantDetails": [ { "dob": "2000-01-01", "phone": "9867739179", "pan": "ENEPS2667E", "emailId": "abc@gmail.com", "maritalStatus": "UNMAR", "profile": "", "category": "", "typeOfApplicant": "Borrower", "name": "Pawan Sahani" } ] }';
       	String encryptedRequestBody = IntegrationUtilities.getEncryptedRequest(requestBody,System.Label.privateKey,System.Label.ivkey);  
        Map<String, String> requestData = new Map<String, String>();
        requestData.put('JData', encryptedRequestBody);
        String requestBodyJSON = JSON.serialize(requestData);
        req.requestBody = Blob.valueOf(requestBodyJSON);
        RestContext.request = req;
		RestContext.response =response;
        
        Test.startTest();
        TAFELeadTransferAPI.uploadLeadDetails();
        Test.stopTest();

        // Validate the response
        RestResponse res = RestContext.response;
        System.assertEquals(201, res.statusCode);
    }
    
    @isTest
    static void testUploadLeadNameCheck2() {
        System_Configuration__c sysConfig = new System_Configuration__c();
        sysConfig.Name = 'System Configuration';
        sysConfig.Eligible_Roles_for_BE_Assignment__c = 'BE,CS';
        sysConfig.Eligible_Roles_for_CS_Assignment__c = 'CS,MA';
        sysConfig.Eligible_Roles_for_MA_Assignment__c = 'MA,MO';
        sysConfig.Eligible_Roles_for_MO_Assignment__c = 'BE,CS,MA,MO';
        sysConfig.Application_Date__c = System.today();
        insert sysConfig;
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
  
        RestRequest req = new RestRequest();
        RestResponse response = new RestResponse();
        req.requestURI = '/services/apexrest/v1/tafeleadTransferAPI/';
        req.httpMethod = 'POST';
		req.addHeader('Content-Type', 'application/json');
        
        String requestBody = '{ "dealerPincode": 600034, "applicationNumber": "TF19062400001", "name": "Pawan", "currentAddressPincode": "754123", "make": "TAFETRACT", "model": "MF241ULTRA HDPDS325.1GB MSPTO PS1104HP42", "variant": "MF241ULTRA HDPDS325.1GB MSPTO PS1104HP42", "vehiclePrice": 600000, "chargerPrice": 0, "insurancePrice": 0, "handlingCharges": 0, "helmet": 0, "fameSubsidy": 0, "performanceUpgrade": 0, "cgst": 0, "sgst": 0, "igst": 0, "rtoRoadTax": 0, "iblORP": 0, "loanAmount": "505000", "crmIRR": 18, "tenure": 24, "emi": 14000, "documentationCharge": "", "processingCharge": "", "stampDuty": "", "downpayment": 0, "leadSource": "TAFE", "dealerCode": "BEN072075", "dealerName": "", "applicantDetails": [ { "dob": "2000-01-01", "phone": "9867739179", "pan": "ENEPS2667E", "emailId": "abc@gmail.com", "maritalStatus": "UNMAR", "profile": "", "category": "", "typeOfApplicant": "Borrower", "name": "Pawan Sahani" } ] }';
       	String encryptedRequestBody = IntegrationUtilities.getEncryptedRequest(requestBody,System.Label.privateKey,System.Label.ivkey);  
        Map<String, String> requestData = new Map<String, String>();
        requestData.put('JData', encryptedRequestBody);
        String requestBodyJSON = JSON.serialize(requestData);
        req.requestBody = Blob.valueOf(requestBodyJSON);
        RestContext.request = req;
		RestContext.response =response;
        
        Test.startTest();
        TAFELeadTransferAPI.uploadLeadDetails();
        Test.stopTest();

        // Validate the response
        RestResponse res = RestContext.response;
        System.assertEquals(201, res.statusCode);
    }
    
    @isTest
    static void testUploadLeadNameCheck3() {
        System_Configuration__c sysConfig = new System_Configuration__c();
        sysConfig.Name = 'System Configuration';
        sysConfig.Eligible_Roles_for_BE_Assignment__c = 'BE,CS';
        sysConfig.Eligible_Roles_for_CS_Assignment__c = 'CS,MA';
        sysConfig.Eligible_Roles_for_MA_Assignment__c = 'MA,MO';
        sysConfig.Eligible_Roles_for_MO_Assignment__c = 'BE,CS,MA,MO';
        sysConfig.Application_Date__c = System.today();
        insert sysConfig;
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
  
        RestRequest req = new RestRequest();
        RestResponse response = new RestResponse();
        req.requestURI = '/services/apexrest/v1/tafeleadTransferAPI/';
        req.httpMethod = 'POST';
		req.addHeader('Content-Type', 'application/json');
        
        String requestBody = '{ "dealerPincode": 600034, "applicationNumber": "TF19062400001", "name": "Pawan shani TEST 2", "currentAddressPincode": "754123", "make": "TAFETRACT", "model": "MF241ULTRA HDPDS325.1GB MSPTO PS1104HP42", "variant": "MF241ULTRA HDPDS325.1GB MSPTO PS1104HP42", "vehiclePrice": 600000, "chargerPrice": 0, "insurancePrice": 0, "handlingCharges": 0, "helmet": 0, "fameSubsidy": 0, "performanceUpgrade": 0, "cgst": 0, "sgst": 0, "igst": 0, "rtoRoadTax": 0, "iblORP": 0, "loanAmount": "505000", "crmIRR": 18, "tenure": 24, "emi": 14000, "documentationCharge": "", "processingCharge": "", "stampDuty": "", "downpayment": 0, "leadSource": "TAFE", "dealerCode": "BEN072075", "dealerName": "", "applicantDetails": [ { "dob": "2000-01-01", "phone": "9867739179", "pan": "ENEPS2667E", "emailId": "abc@gmail.com", "maritalStatus": "UNMAR", "profile": "", "category": "", "typeOfApplicant": "Borrower", "name": "Pawan Sahani" } ] }';
       	String encryptedRequestBody = IntegrationUtilities.getEncryptedRequest(requestBody,System.Label.privateKey,System.Label.ivkey);  
        Map<String, String> requestData = new Map<String, String>();
        requestData.put('JData', encryptedRequestBody);
        String requestBodyJSON = JSON.serialize(requestData);
        req.requestBody = Blob.valueOf(requestBodyJSON);
        RestContext.request = req;
		RestContext.response =response;
        
        Test.startTest();
        TAFELeadTransferAPI.uploadLeadDetails();
        Test.stopTest();

        // Validate the response
        RestResponse res = RestContext.response;
        System.assertEquals(201, res.statusCode);
    }
    
    @isTest
    static void testUploadLeadNameCheck4() {
        System_Configuration__c sysConfig = new System_Configuration__c();
        sysConfig.Name = 'System Configuration';
        sysConfig.Eligible_Roles_for_BE_Assignment__c = 'BE,CS';
        sysConfig.Eligible_Roles_for_CS_Assignment__c = 'CS,MA';
        sysConfig.Eligible_Roles_for_MA_Assignment__c = 'MA,MO';
        sysConfig.Eligible_Roles_for_MO_Assignment__c = 'BE,CS,MA,MO';
        sysConfig.Application_Date__c = System.today();
        insert sysConfig;
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
  
        RestRequest req = new RestRequest();
        RestResponse response = new RestResponse();
        req.requestURI = '/services/apexrest/v1/tafeleadTransferAPI/';
        req.httpMethod = 'POST';
		req.addHeader('Content-Type', 'application/json');
        
        String requestBody = '{ "dealerPincode": 600034, "applicationNumber": "TF19062400001", "name": null, "currentAddressPincode": "754123", "make": "TAFETRACT", "model": "MF241ULTRA HDPDS325.1GB MSPTO PS1104HP42", "variant": "MF241ULTRA HDPDS325.1GB MSPTO PS1104HP42", "vehiclePrice": 600000, "chargerPrice": 0, "insurancePrice": 0, "handlingCharges": 0, "helmet": 0, "fameSubsidy": 0, "performanceUpgrade": 0, "cgst": 0, "sgst": 0, "igst": 0, "rtoRoadTax": 0, "iblORP": 0, "loanAmount": "505000", "crmIRR": 18, "tenure": 24, "emi": 14000, "documentationCharge": "", "processingCharge": "", "stampDuty": "", "downpayment": 0, "leadSource": "TAFE", "dealerCode": "BEN072075", "dealerName": "", "applicantDetails": [ { "dob": "2000-01-01", "phone": "9867739179", "pan": "ENEPS2667E", "emailId": "abc@gmail.com", "maritalStatus": "UNMAR", "profile": "", "category": "", "typeOfApplicant": "Borrower", "name": "Pawan Sahani" } ] }';
       	String encryptedRequestBody = IntegrationUtilities.getEncryptedRequest(requestBody,System.Label.privateKey,System.Label.ivkey);  
        Map<String, String> requestData = new Map<String, String>();
        requestData.put('JData', encryptedRequestBody);
        String requestBodyJSON = JSON.serialize(requestData);
        req.requestBody = Blob.valueOf(requestBodyJSON);
        RestContext.request = req;
		RestContext.response =response;
        
        Test.startTest();
        TAFELeadTransferAPI.uploadLeadDetails();
        Test.stopTest();
    }
    
    @isTest
    static void testapplicationNumberCheck() {
        System_Configuration__c sysConfig = new System_Configuration__c();
        sysConfig.Name = 'System Configuration';
        sysConfig.Eligible_Roles_for_BE_Assignment__c = 'BE,CS';
        sysConfig.Eligible_Roles_for_CS_Assignment__c = 'CS,MA';
        sysConfig.Eligible_Roles_for_MA_Assignment__c = 'MA,MO';
        sysConfig.Eligible_Roles_for_MO_Assignment__c = 'BE,CS,MA,MO';
        sysConfig.Application_Date__c = System.today();
        insert sysConfig;
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
  
        RestRequest req = new RestRequest();
        RestResponse response = new RestResponse();
        req.requestURI = '/services/apexrest/v1/tafeleadTransferAPI/';
        req.httpMethod = 'POST';
		req.addHeader('Content-Type', 'application/json');
        
        String requestBody = '{ "dealerPincode": 600034, "applicationNumber": null, "name": "Pawan shani TEST2", "currentAddressPincode": "754123", "make": "TAFETRACT", "model": "MF241ULTRA HDPDS325.1GB MSPTO PS1104HP42", "variant": "MF241ULTRA HDPDS325.1GB MSPTO PS1104HP42", "vehiclePrice": 600000, "chargerPrice": 0, "insurancePrice": 0, "handlingCharges": 0, "helmet": 0, "fameSubsidy": 0, "performanceUpgrade": 0, "cgst": 0, "sgst": 0, "igst": 0, "rtoRoadTax": 0, "iblORP": 0, "loanAmount": "505000", "crmIRR": 18, "tenure": 24, "emi": 14000, "documentationCharge": "", "processingCharge": "", "stampDuty": "", "downpayment": 0, "leadSource": "TAFE", "dealerCode": "BEN072075", "dealerName": "", "applicantDetails": [ { "dob": "2000-01-01", "phone": "9867739179", "pan": "ENEPS2667E", "emailId": "abc@gmail.com", "maritalStatus": "UNMAR", "profile": "", "category": "", "typeOfApplicant": "Borrower", "name": "Pawan Sahani" } ] }';
       	String encryptedRequestBody = IntegrationUtilities.getEncryptedRequest(requestBody,System.Label.privateKey,System.Label.ivkey);  
        Map<String, String> requestData = new Map<String, String>();
        requestData.put('JData', encryptedRequestBody);
        String requestBodyJSON = JSON.serialize(requestData);
        req.requestBody = Blob.valueOf(requestBodyJSON);
        RestContext.request = req;
		RestContext.response =response;
        
        Test.startTest();
        TAFELeadTransferAPI.uploadLeadDetails();
        Test.stopTest();
    }
    
    @isTest
    static void testcurrentAddressPincodeCheck() {
        System_Configuration__c sysConfig = new System_Configuration__c();
        sysConfig.Name = 'System Configuration';
        sysConfig.Eligible_Roles_for_BE_Assignment__c = 'BE,CS';
        sysConfig.Eligible_Roles_for_CS_Assignment__c = 'CS,MA';
        sysConfig.Eligible_Roles_for_MA_Assignment__c = 'MA,MO';
        sysConfig.Eligible_Roles_for_MO_Assignment__c = 'BE,CS,MA,MO';
        sysConfig.Application_Date__c = System.today();
        insert sysConfig;
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
  
        RestRequest req = new RestRequest();
        RestResponse response = new RestResponse();
        req.requestURI = '/services/apexrest/v1/tafeleadTransferAPI/';
        req.httpMethod = 'POST';
		req.addHeader('Content-Type', 'application/json');
        
        String requestBody = '{ "dealerPincode": 600034, "applicationNumber": "TF19062400001", "name": "Pawan shani TEST2", "currentAddressPincode": null, "make": "TAFETRACT", "model": "MF241ULTRA HDPDS325.1GB MSPTO PS1104HP42", "variant": "MF241ULTRA HDPDS325.1GB MSPTO PS1104HP42", "vehiclePrice": 600000, "chargerPrice": 0, "insurancePrice": 0, "handlingCharges": 0, "helmet": 0, "fameSubsidy": 0, "performanceUpgrade": 0, "cgst": 0, "sgst": 0, "igst": 0, "rtoRoadTax": 0, "iblORP": 0, "loanAmount": "505000", "crmIRR": 18, "tenure": 24, "emi": 14000, "documentationCharge": "", "processingCharge": "", "stampDuty": "", "downpayment": 0, "leadSource": "TAFE", "dealerCode": "BEN072075", "dealerName": "", "applicantDetails": [ { "dob": "2000-01-01", "phone": "9867739179", "pan": "ENEPS2667E", "emailId": "abc@gmail.com", "maritalStatus": "UNMAR", "profile": "", "category": "", "typeOfApplicant": "Borrower", "name": "Pawan Sahani" } ] }';
       	String encryptedRequestBody = IntegrationUtilities.getEncryptedRequest(requestBody,System.Label.privateKey,System.Label.ivkey);  
        Map<String, String> requestData = new Map<String, String>();
        requestData.put('JData', encryptedRequestBody);
        String requestBodyJSON = JSON.serialize(requestData);
        req.requestBody = Blob.valueOf(requestBodyJSON);
        RestContext.request = req;
		RestContext.response =response;
        
        Test.startTest();
        TAFELeadTransferAPI.uploadLeadDetails();
        Test.stopTest();
    }
    
    @isTest
    static void testhelmetCheck() {
        System_Configuration__c sysConfig = new System_Configuration__c();
        sysConfig.Name = 'System Configuration';
        sysConfig.Eligible_Roles_for_BE_Assignment__c = 'BE,CS';
        sysConfig.Eligible_Roles_for_CS_Assignment__c = 'CS,MA';
        sysConfig.Eligible_Roles_for_MA_Assignment__c = 'MA,MO';
        sysConfig.Eligible_Roles_for_MO_Assignment__c = 'BE,CS,MA,MO';
        sysConfig.Application_Date__c = System.today();
        insert sysConfig;
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
  
        RestRequest req = new RestRequest();
        RestResponse response = new RestResponse();
        req.requestURI = '/services/apexrest/v1/tafeleadTransferAPI/';
        req.httpMethod = 'POST';
		req.addHeader('Content-Type', 'application/json');
        
        String requestBody = '{ "dealerPincode": 600034, "applicationNumber": "TF19062400001", "name": "Pawan shani", "currentAddressPincode": "754123", "make": "TAFETRACT", "model": "MF241ULTRA HDPDS325.1GB MSPTO PS1104HP42", "variant": "MF241ULTRA HDPDS325.1GB MSPTO PS1104HP42", "vehiclePrice": 600000, "chargerPrice": 0, "insurancePrice": 0, "handlingCharges": 0, "helmet": null, "fameSubsidy": 0, "performanceUpgrade": 0, "cgst": 0, "sgst": 0, "igst": 0, "rtoRoadTax": 0, "iblORP": 0, "loanAmount": "505000", "crmIRR": 18, "tenure": 24, "emi": 14000, "documentationCharge": "", "processingCharge": "", "stampDuty": "", "downpayment": 0, "leadSource": "TAFE", "dealerCode": "BEN072075", "dealerName": "", "applicantDetails": [ { "dob": "2000-01-01", "phone": "9867739179", "pan": "ENEPS2667E", "emailId": "abc@gmail.com", "maritalStatus": "UNMAR", "profile": "", "category": "", "typeOfApplicant": "Borrower", "name": "Pawan Sahani" } ] }';
       	String encryptedRequestBody = IntegrationUtilities.getEncryptedRequest(requestBody,System.Label.privateKey,System.Label.ivkey);  
        Map<String, String> requestData = new Map<String, String>();
        requestData.put('JData', encryptedRequestBody);
        String requestBodyJSON = JSON.serialize(requestData);
        req.requestBody = Blob.valueOf(requestBodyJSON);
        RestContext.request = req;
		RestContext.response =response;
        
        Test.startTest();
        TAFELeadTransferAPI.uploadLeadDetails();
        Test.stopTest();
    }
    
    @isTest
    static void testfameSubsidyCheck() {
        System_Configuration__c sysConfig = new System_Configuration__c();
        sysConfig.Name = 'System Configuration';
        sysConfig.Eligible_Roles_for_BE_Assignment__c = 'BE,CS';
        sysConfig.Eligible_Roles_for_CS_Assignment__c = 'CS,MA';
        sysConfig.Eligible_Roles_for_MA_Assignment__c = 'MA,MO';
        sysConfig.Eligible_Roles_for_MO_Assignment__c = 'BE,CS,MA,MO';
        sysConfig.Application_Date__c = System.today();
        insert sysConfig;
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
  
        RestRequest req = new RestRequest();
        RestResponse response = new RestResponse();
        req.requestURI = '/services/apexrest/v1/tafeleadTransferAPI/';
        req.httpMethod = 'POST';
		req.addHeader('Content-Type', 'application/json');
        
        String requestBody = '{ "dealerPincode": 600034, "applicationNumber": "TF19062400001", "name": "Pawan shani", "currentAddressPincode": "754123", "make": "TAFETRACT", "model": "MF241ULTRA HDPDS325.1GB MSPTO PS1104HP42", "variant": "MF241ULTRA HDPDS325.1GB MSPTO PS1104HP42", "vehiclePrice": 600000, "chargerPrice": 0, "insurancePrice": 0, "handlingCharges": 0, "helmet": 0, "fameSubsidy": null, "performanceUpgrade": 0, "cgst": 0, "sgst": 0, "igst": 0, "rtoRoadTax": 0, "iblORP": 0, "loanAmount": "505000", "crmIRR": 18, "tenure": 24, "emi": 14000, "documentationCharge": "", "processingCharge": "", "stampDuty": "", "downpayment": 0, "leadSource": "TAFE", "dealerCode": "BEN072075", "dealerName": "", "applicantDetails": [ { "dob": "2000-01-01", "phone": "9867739179", "pan": "ENEPS2667E", "emailId": "abc@gmail.com", "maritalStatus": "UNMAR", "profile": "", "category": "", "typeOfApplicant": "Borrower", "name": "Pawan Sahani" } ] }';
       	String encryptedRequestBody = IntegrationUtilities.getEncryptedRequest(requestBody,System.Label.privateKey,System.Label.ivkey);  
        Map<String, String> requestData = new Map<String, String>();
        requestData.put('JData', encryptedRequestBody);
        String requestBodyJSON = JSON.serialize(requestData);
        req.requestBody = Blob.valueOf(requestBodyJSON);
        RestContext.request = req;
		RestContext.response =response;
        
        Test.startTest();
        TAFELeadTransferAPI.uploadLeadDetails();
        Test.stopTest();
    }
}