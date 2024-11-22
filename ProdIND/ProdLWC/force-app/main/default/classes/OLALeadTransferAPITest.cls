@IsTest
public class OLALeadTransferAPITest {
    
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
    //By Suresh / Sriram
    @TestSetup
    static void setupTestData()
    {
        System_Configuration__c sysConfig = new System_Configuration__c();
        sysConfig.Name = 'System Configuration';
        sysConfig.Eligible_Roles_for_BE_Assignment__c = 'BE,CS';
        sysConfig.Eligible_Roles_for_CS_Assignment__c = 'CS,MA';
        sysConfig.Eligible_Roles_for_MA_Assignment__c = 'MA,MO';
        sysConfig.Eligible_Roles_for_MO_Assignment__c = 'BE,CS,MA,MO';
        sysConfig.Application_Date__c = System.today();
        insert sysConfig;
        
        Account communityAccount = new Account(Name = 'Test KHT_TW_N', BranchBLCode__c = 'KHT');
        insert communityAccount;
        
        Profile businessProfile = [Select Id from Profile where Name = 'IBL Business Executive TW'];
        
        User businessUser = new User(alias = 'testUser', email='testingBusinessUser007@noemail.com', emailencodingkey='UTF-8',
                                     lastname='Testing', languagelocalekey='en_US',localesidkey='en_US', profileid = businessProfile.Id,
                                     country='United States', IsActive =true, timezonesidkey='America/Los_Angeles',
                                     username='testingBusinessUser007@noemail.com.DSAtestuser', Phone= '1000000001', MobilePhone= '1000000001', EmployeeNumber = 'R15928');
        insert businessUser;
        
        D2C_BE_Master__c DECBeMaster = new D2C_BE_Master__c(Pin_Code__c = 754123, BL_Code__c = 'KHT', Vehicle_Type__c = 'New', Product_Type__c = 'Two Wheeler');
        insert DECBeMaster;
        
        }
    
    
    
    //In This Method we Request The SampleBody and check. 
    static testmethod void leadTransferReuestTest(){
        BE_Master__c beMasterRec = new BE_Master__c(Pin_Code__c = 754123, BL_Code__c='AHH', Vehicle_Type__c='New', Product_Type__c='Two Wheeler');
        insert beMasterRec;
        System_Configuration__c sysConfig = new System_Configuration__c();
        sysConfig.Name = 'System Configuration';
        sysConfig.Eligible_Roles_for_BE_Assignment__c = 'BE,CS';
        sysConfig.Eligible_Roles_for_CS_Assignment__c = 'CS,MA';
        sysConfig.Eligible_Roles_for_MA_Assignment__c = 'MA,MO';
        sysConfig.Eligible_Roles_for_MO_Assignment__c = 'BE,CS,MA,MO';
        sysConfig.Application_Date__c = System.today();
        insert sysConfig; 
        Test.startTest();
        string olaleadjson='{\"applicationNumber\":\"12343\",\"name\":null,\"dob\":\"1996-01-01\",\"phone\":\"123456781\",\"pan\":\"apisd21973\",\"emailId\":\"ABC@gmail.com\",\"maritalStatus\":\"UNMAR\",\"profile\":\"COAL MINING\",\"category\":\"Salaried\",\"currentAddressPincode\":\"754123\",\"make\":\"Test Make\",\"model\":\"Test Model\",\"variant\":\"Test Variant\",\"vehiclePrice\":\"123\",\"chargerPrice\":\"123\",\"insurancePrice\":\"123\",\"handlingCharges\":\"123\",\"helmet\":\"123\",\"fameSubsidy\":\"123\",\"performanceUpgrade\":\"123\",\"cgst\":\"123\",\"sgst\":\"123\",\"igst\":\"123\",\"rtoRoadTax\":\"123\",\"iblORP\":\"123456\",\"loanAmount\":\"1234512345\",\"crmIRR\":\"11\",\"tenure\":\"11\",\"emi\":\"1212\",\"documentationCharge\":\"10\",\"processingCharge\":\"11\",\"stampDuty\":\"\",\"downpayment\":\"123123\",\"leadSource\":"OLA"}';
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = '/services/apexrest/v1/leadTransferAPI/';
        system.debug('request.requestURI---' + request.requestURI);
        request.httpMethod = 'Post';
        request.requestBody = Blob.valueof(IntegrationUtilities.getEncryptedRequest(olaleadjson,System.Label.privateKey,System.Label.ivkey));
        request.addHeader('Content-Type', 'application/json');
        RestContext.request = request;
        RestContext.response =response;
        OLALeadTransferAPI.uploadLeadDetails();
        Test.stopTest();
    }
    // In This Method We Passing The ApplicationNumber value is 'null'.
     static testmethod void leadTransferApplicationNumberCheck(){
        Test.startTest();
        string olaleadjson='{\"applicationNumber\":null,\"name\":\"John Doe\",\"dob\":\"1996-01-01\",\"phone\":\"123456781\",\"pan\":\"apisd21973\",\"emailId\":\"ABC@gmail.com\",\"maritalStatus\":\"UNMAR\",\"profile\":\"COAL MINING\",\"category\":\"Salaried\",\"currentAddressPincode\":\"754123\",\"make\":\"Test Make\",\"model\":\"Test Model\",\"variant\":\"Test Variant\",\"vehiclePrice\":\"123\",\"chargerPrice\":\"123\",\"insurancePrice\":\"123\",\"handlingCharges\":\"123\",\"helmet\":\"123\",\"fameSubsidy\":\"123\",\"performanceUpgrade\":\"123\",\"cgst\":\"123\",\"sgst\":\"123\",\"igst\":\"123\",\"rtoRoadTax\":\"123\",\"iblORP\":\"123456\",\"loanAmount\":\"1234512345\",\"crmIRR\":\"11\",\"tenure\":\"11\",\"emi\":\"1212\",\"documentationCharge\":\"\",\"processingCharge\":\"\",\"stampDuty\":\"\",\"downpayment\":\"123123\",\"leadSource\":"OLA"}';
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = '/services/apexrest/v1/leadTransferAPI/';
        system.debug('request.requestURI---' + request.requestURI);
        request.httpMethod = 'Post';
        request.requestBody = Blob.valueof(IntegrationUtilities.getEncryptedRequest(olaleadjson,System.Label.privateKey,System.Label.ivkey));
        request.addHeader('Content-Type', 'application/json');
        RestContext.request = request;
        RestContext.response =response;
        OLALeadTransferAPI.uploadLeadDetails();
        Test.stopTest();
    }
   // In This Method We Passing The name value is 'null'.
    static testmethod void leadTransferNameCheck(){
        Test.startTest();
        string olaleadjson='{\"applicationNumber\":\"12343\",\"name\":null,\"dob\":\"1996-01-01\",\"phone\":\"123456781\",\"pan\":\"apisd21973\",\"emailId\":\"ABC@gmail.com\",\"maritalStatus\":\"UNMAR\",\"profile\":\"COAL MINING\",\"category\":\"Salaried\",\"currentAddressPincode\":\"754123\",\"make\":\"Test Make\",\"model\":\"Test Model\",\"variant\":\"Test Variant\",\"vehiclePrice\":\"123\",\"chargerPrice\":\"123\",\"insurancePrice\":\"123\",\"handlingCharges\":\"123\",\"helmet\":\"123\",\"fameSubsidy\":\"123\",\"performanceUpgrade\":\"123\",\"cgst\":\"123\",\"sgst\":\"123\",\"igst\":\"123\",\"rtoRoadTax\":\"123\",\"iblORP\":\"123456\",\"loanAmount\":\"1234512345\",\"crmIRR\":\"11\",\"tenure\":\"11\",\"emi\":\"1212\",\"documentationCharge\":\"\",\"processingCharge\":\"\",\"stampDuty\":\"\",\"downpayment\":\"123123\",\"leadSource\":"OLA"}';
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = '/services/apexrest/v1/leadTransferAPI/';
        system.debug('request.requestURI---' + request.requestURI);
        request.httpMethod = 'Post';
        request.requestBody = Blob.valueof(IntegrationUtilities.getEncryptedRequest(olaleadjson,System.Label.privateKey,System.Label.ivkey));
        request.addHeader('Content-Type', 'application/json');
        RestContext.request = request;
        RestContext.response =response;
        OLALeadTransferAPI.uploadLeadDetails();
        Test.stopTest();
    }
    // In This Method We Passing The DOb value is 'null'.
     static testmethod void leadTransferDobCheck(){
        Test.startTest();
        string olaleadjson='{\"applicationNumber\":\"12343\",\"name\":\"John Doe\",\"dob\":null,\"phone\":\"123456781\",\"pan\":\"apisd21973\",\"emailId\":\"ABC@gmail.com\",\"maritalStatus\":\"UNMAR\",\"profile\":\"COAL MINING\",\"category\":\"Salaried\",\"currentAddressPincode\":\"754123\",\"make\":\"Test Make\",\"model\":\"Test Model\",\"variant\":\"Test Variant\",\"vehiclePrice\":\"123\",\"chargerPrice\":\"123\",\"insurancePrice\":\"123\",\"handlingCharges\":\"123\",\"helmet\":\"123\",\"fameSubsidy\":\"123\",\"performanceUpgrade\":\"123\",\"cgst\":\"123\",\"sgst\":\"123\",\"igst\":\"123\",\"rtoRoadTax\":\"123\",\"iblORP\":\"123456\",\"loanAmount\":\"1234512345\",\"crmIRR\":\"11\",\"tenure\":\"11\",\"emi\":\"1212\",\"documentationCharge\":\"\",\"processingCharge\":\"\",\"stampDuty\":\"\",\"downpayment\":\"123123\",\"leadSource\":"OLA"}';
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = '/services/apexrest/v1/leadTransferAPI/';
        system.debug('request.requestURI---' + request.requestURI);
        request.httpMethod = 'Post';
        request.requestBody = Blob.valueof(IntegrationUtilities.getEncryptedRequest(olaleadjson,System.Label.privateKey,System.Label.ivkey));
        request.addHeader('Content-Type', 'application/json');
        RestContext.request = request;
        RestContext.response =response;
        OLALeadTransferAPI.uploadLeadDetails();
        Test.stopTest();
    }
    // In This Method We Passing The Phone value is 'null'.
     static testmethod void leadTransferPhoneCheck(){
        Test.startTest();
        string olaleadjson='{\"applicationNumber\":\"12343\",\"name\":\"John Doe\",\"dob\":\"1996-01-01\",\"phone\":null,\"pan\":\"apisd21973\",\"emailId\":\"ABC@gmail.com\",\"maritalStatus\":\"UNMAR\",\"profile\":\"COAL MINING\",\"category\":\"Salaried\",\"currentAddressPincode\":\"754123\",\"make\":\"Test Make\",\"model\":\"Test Model\",\"variant\":\"Test Variant\",\"vehiclePrice\":\"123\",\"chargerPrice\":\"123\",\"insurancePrice\":\"123\",\"handlingCharges\":\"123\",\"helmet\":\"123\",\"fameSubsidy\":\"123\",\"performanceUpgrade\":\"123\",\"cgst\":\"123\",\"sgst\":\"123\",\"igst\":\"123\",\"rtoRoadTax\":\"123\",\"iblORP\":\"123456\",\"loanAmount\":\"1234512345\",\"crmIRR\":\"11\",\"tenure\":\"11\",\"emi\":\"1212\",\"documentationCharge\":\"\",\"processingCharge\":\"\",\"stampDuty\":\"\",\"downpayment\":\"123123\",\"leadSource\":"OLA"}';
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = '/services/apexrest/v1/leadTransferAPI/';
        system.debug('request.requestURI---' + request.requestURI);
        request.httpMethod = 'Post';
        request.requestBody = Blob.valueof(IntegrationUtilities.getEncryptedRequest(olaleadjson,System.Label.privateKey,System.Label.ivkey));
        request.addHeader('Content-Type', 'application/json');
        RestContext.request = request;
        RestContext.response =response;
        OLALeadTransferAPI.uploadLeadDetails();
        Test.stopTest();
    }
    // In This Method We Passing The Pan value is 'null'.
 static testmethod void leadTransferPanCheck(){
        Test.startTest();
        string olaleadjson='{\"applicationNumber\":\"12343\",\"name\":\"John Doe\",\"dob\":\"1996-01-01\",\"phone\":\"123456781\",\"pan\":null,\"emailId\":\"ABC@gmail.com\",\"maritalStatus\":\"UNMAR\",\"profile\":\"COAL MINING\",\"category\":\"Salaried\",\"currentAddressPincode\":\"754123\",\"make\":\"Test Make\",\"model\":\"Test Model\",\"variant\":\"Test Variant\",\"vehiclePrice\":\"123\",\"chargerPrice\":\"123\",\"insurancePrice\":\"123\",\"handlingCharges\":\"123\",\"helmet\":\"123\",\"fameSubsidy\":\"123\",\"performanceUpgrade\":\"123\",\"cgst\":\"123\",\"sgst\":\"123\",\"igst\":\"123\",\"rtoRoadTax\":\"123\",\"iblORP\":\"123456\",\"loanAmount\":\"1234512345\",\"crmIRR\":\"11\",\"tenure\":\"11\",\"emi\":\"1212\",\"documentationCharge\":\"\",\"processingCharge\":\"\",\"stampDuty\":\"\",\"downpayment\":\"123123\",\"leadSource\":"OLA"}';
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = '/services/apexrest/v1/leadTransferAPI/';
        system.debug('request.requestURI---' + request.requestURI);
        request.httpMethod = 'Post';
        request.requestBody = Blob.valueof(IntegrationUtilities.getEncryptedRequest(olaleadjson,System.Label.privateKey,System.Label.ivkey));
        request.addHeader('Content-Type', 'application/json');
        RestContext.request = request;
        RestContext.response =response;
        OLALeadTransferAPI.uploadLeadDetails();
        Test.stopTest();
    }
    // In This Method We Passing The Email value is 'null'.
     static testmethod void leadTransferEmailIdCheck(){
        Test.startTest();
        string olaleadjson='{\"applicationNumber\":\"12343\",\"name\":\"John Doe\",\"dob\":\"1996-01-01\",\"phone\":\"123456781\",\"pan\":\"apisd21973\",\"emailId\":null,\"maritalStatus\":\"UNMAR\",\"profile\":\"COAL MINING\",\"category\":\"Salaried\",\"currentAddressPincode\":\"754123\",\"make\":\"Test Make\",\"model\":\"Test Model\",\"variant\":\"Test Variant\",\"vehiclePrice\":\"123\",\"chargerPrice\":\"123\",\"insurancePrice\":\"123\",\"handlingCharges\":\"123\",\"helmet\":\"123\",\"fameSubsidy\":\"123\",\"performanceUpgrade\":\"123\",\"cgst\":\"123\",\"sgst\":\"123\",\"igst\":\"123\",\"rtoRoadTax\":\"123\",\"iblORP\":\"123456\",\"loanAmount\":\"1234512345\",\"crmIRR\":\"11\",\"tenure\":\"11\",\"emi\":\"1212\",\"documentationCharge\":\"\",\"processingCharge\":\"\",\"stampDuty\":\"\",\"downpayment\":\"123123\",\"leadSource\":"OLA"}';
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = '/services/apexrest/v1/leadTransferAPI/';
        system.debug('request.requestURI---' + request.requestURI);
        request.httpMethod = 'Post';
        request.requestBody = Blob.valueof(IntegrationUtilities.getEncryptedRequest(olaleadjson,System.Label.privateKey,System.Label.ivkey));
        request.addHeader('Content-Type', 'application/json');
        RestContext.request = request;
        RestContext.response =response;
        OLALeadTransferAPI.uploadLeadDetails();
        Test.stopTest();
    }
    // In This Method We Passing The MariatalStatus value is 'null'.
     static testmethod void leadTransferMaritalStatusCheck(){
        Test.startTest();
        string olaleadjson='{\"applicationNumber\":\"12343\",\"name\":\"John Doe\",\"dob\":\"1996-01-01\",\"phone\":\"123456781\",\"pan\":\"apisd21973\",\"emailId\":\"ABC@gmail.com\",\"maritalStatus\":null,\"profile\":\"COAL MINING\",\"category\":\"Salaried\",\"currentAddressPincode\":\"754123\",\"make\":\"Test Make\",\"model\":\"Test Model\",\"variant\":\"Test Variant\",\"vehiclePrice\":\"123\",\"chargerPrice\":\"123\",\"insurancePrice\":\"123\",\"handlingCharges\":\"123\",\"helmet\":\"123\",\"fameSubsidy\":\"123\",\"performanceUpgrade\":\"123\",\"cgst\":\"123\",\"sgst\":\"123\",\"igst\":\"123\",\"rtoRoadTax\":\"123\",\"iblORP\":\"123456\",\"loanAmount\":\"1234512345\",\"crmIRR\":\"11\",\"tenure\":\"11\",\"emi\":\"1212\",\"documentationCharge\":\"\",\"processingCharge\":\"\",\"stampDuty\":\"\",\"downpayment\":\"123123\",\"leadSource\":"OLA"}';
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = '/services/apexrest/v1/leadTransferAPI/';
        system.debug('request.requestURI---' + request.requestURI);
        request.httpMethod = 'Post';
        request.requestBody = Blob.valueof(IntegrationUtilities.getEncryptedRequest(olaleadjson,System.Label.privateKey,System.Label.ivkey));
        request.addHeader('Content-Type', 'application/json');
        RestContext.request = request;
        RestContext.response =response;
        OLALeadTransferAPI.uploadLeadDetails();
        Test.stopTest();
    }
    // In This Method We Passing The Profile value is 'null'.
     static testmethod void leadTransferProfileCheck(){
        Test.startTest();
        string olaleadjson='{\"applicationNumber\":\"12343\",\"name\":\"John Doe\",\"dob\":\"1996-01-01\",\"phone\":\"123456781\",\"pan\":\"apisd21973\",\"emailId\":\"ABC@gmail.com\",\"maritalStatus\":\"UNMAR\",\"profile\":null,\"category\":\"Salaried\",\"currentAddressPincode\":\"754123\",\"make\":\"Test Make\",\"model\":\"Test Model\",\"variant\":\"Test Variant\",\"vehiclePrice\":\"123\",\"chargerPrice\":\"123\",\"insurancePrice\":\"123\",\"handlingCharges\":\"123\",\"helmet\":\"123\",\"fameSubsidy\":\"123\",\"performanceUpgrade\":\"123\",\"cgst\":\"123\",\"sgst\":\"123\",\"igst\":\"123\",\"rtoRoadTax\":\"123\",\"iblORP\":\"123456\",\"loanAmount\":\"1234512345\",\"crmIRR\":\"11\",\"tenure\":\"11\",\"emi\":\"1212\",\"documentationCharge\":\"\",\"processingCharge\":\"\",\"stampDuty\":\"\",\"downpayment\":\"123123\",\"leadSource\":"OLA"}';
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = '/services/apexrest/v1/leadTransferAPI/';
        system.debug('request.requestURI---' + request.requestURI);
        request.httpMethod = 'Post';
        request.requestBody = Blob.valueof(IntegrationUtilities.getEncryptedRequest(olaleadjson,System.Label.privateKey,System.Label.ivkey));
        request.addHeader('Content-Type', 'application/json');
        RestContext.request = request;
        RestContext.response =response;
        OLALeadTransferAPI.uploadLeadDetails();
        Test.stopTest();
    }
    // In This Method We Passing The Category value is 'null'.
     static testmethod void leadTransferCategoryCheck(){
        Test.startTest();
        string olaleadjson='{\"applicationNumber\":\"12343\",\"name\":\"John Doe\",\"dob\":\"1996-01-01\",\"phone\":\"123456781\",\"pan\":\"apisd21973\",\"emailId\":\"ABC@gmail.com\",\"maritalStatus\":\"UNMAR\",\"profile\":\"COAL MINING\",\"category\":null,\"currentAddressPincode\":\"754123\",\"make\":\"Test Make\",\"model\":\"Test Model\",\"variant\":\"Test Variant\",\"vehiclePrice\":\"123\",\"chargerPrice\":\"123\",\"insurancePrice\":\"123\",\"handlingCharges\":\"123\",\"helmet\":\"123\",\"fameSubsidy\":\"123\",\"performanceUpgrade\":\"123\",\"cgst\":\"123\",\"sgst\":\"123\",\"igst\":\"123\",\"rtoRoadTax\":\"123\",\"iblORP\":\"123456\",\"loanAmount\":\"1234512345\",\"crmIRR\":\"11\",\"tenure\":\"11\",\"emi\":\"1212\",\"documentationCharge\":\"\",\"processingCharge\":\"\",\"stampDuty\":\"\",\"downpayment\":\"123123\",\"leadSource\":"OLA"}';
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = '/services/apexrest/v1/leadTransferAPI/';
        system.debug('request.requestURI---' + request.requestURI);
        request.httpMethod = 'Post';
        request.requestBody = Blob.valueof(IntegrationUtilities.getEncryptedRequest(olaleadjson,System.Label.privateKey,System.Label.ivkey));
        request.addHeader('Content-Type', 'application/json');
        RestContext.request = request;
        RestContext.response =response;
        OLALeadTransferAPI.uploadLeadDetails();
        Test.stopTest();
    }
    // In This Method We Passing The CurrentAddressPinCode value is 'null'.
     static testmethod void leadTransferCurrentAddressPinCodeCheck(){
        Test.startTest();
        string olaleadjson='{\"applicationNumber\":\"12343\",\"name\":\"John Doe\",\"dob\":\"1996-01-01\",\"phone\":\"123456781\",\"pan\":\"apisd21973\",\"emailId\":\"ABC@gmail.com\",\"maritalStatus\":\"UNMAR\",\"profile\":\"COAL MINING\",\"category\":\"Salaried\",\"currentAddressPincode\":null,\"make\":\"Test Make\",\"model\":\"Test Model\",\"variant\":\"Test Variant\",\"vehiclePrice\":\"123\",\"chargerPrice\":\"123\",\"insurancePrice\":\"123\",\"handlingCharges\":\"123\",\"helmet\":\"123\",\"fameSubsidy\":\"123\",\"performanceUpgrade\":\"123\",\"cgst\":\"123\",\"sgst\":\"123\",\"igst\":\"123\",\"rtoRoadTax\":\"123\",\"iblORP\":\"123456\",\"loanAmount\":\"1234512345\",\"crmIRR\":\"11\",\"tenure\":\"11\",\"emi\":\"1212\",\"documentationCharge\":\"\",\"processingCharge\":\"\",\"stampDuty\":\"\",\"downpayment\":\"123123\",\"leadSource\":"OLA"}';
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = '/services/apexrest/v1/leadTransferAPI/';
        system.debug('request.requestURI---' + request.requestURI);
        request.httpMethod = 'Post';
        request.requestBody = Blob.valueof(IntegrationUtilities.getEncryptedRequest(olaleadjson,System.Label.privateKey,System.Label.ivkey));
        request.addHeader('Content-Type', 'application/json');
        RestContext.request = request;
        RestContext.response =response;
        OLALeadTransferAPI.uploadLeadDetails();
        Test.stopTest();
    }
    // In This Method We Passing The Make value is 'null'.
     static testmethod void leadTransferMakeCheck(){
        Test.startTest();
        string olaleadjson='{\"applicationNumber\":\"12343\",\"name\":\"John Doe\",\"dob\":\"1996-01-01\",\"phone\":\"123456781\",\"pan\":\"apisd21973\",\"emailId\":\"ABC@gmail.com\",\"maritalStatus\":\"UNMAR\",\"profile\":\"COAL MINING\",\"category\":\"Salaried\",\"currentAddressPincode\":\"754123\",\"make\":null,\"model\":\"Test Model\",\"variant\":\"Test Variant\",\"vehiclePrice\":\"123\",\"chargerPrice\":\"123\",\"insurancePrice\":\"123\",\"handlingCharges\":\"123\",\"helmet\":\"123\",\"fameSubsidy\":\"123\",\"performanceUpgrade\":\"123\",\"cgst\":\"123\",\"sgst\":\"123\",\"igst\":\"123\",\"rtoRoadTax\":\"123\",\"iblORP\":\"123456\",\"loanAmount\":\"1234512345\",\"crmIRR\":\"11\",\"tenure\":\"11\",\"emi\":\"1212\",\"documentationCharge\":\"\",\"processingCharge\":\"\",\"stampDuty\":\"\",\"downpayment\":\"123123\",\"leadSource\":"OLA"}';
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = '/services/apexrest/v1/leadTransferAPI/';
        system.debug('request.requestURI---' + request.requestURI);
        request.httpMethod = 'Post';
        request.requestBody = Blob.valueof(IntegrationUtilities.getEncryptedRequest(olaleadjson,System.Label.privateKey,System.Label.ivkey));
        request.addHeader('Content-Type', 'application/json');
        RestContext.request = request;
        RestContext.response =response;
        OLALeadTransferAPI.uploadLeadDetails();
        Test.stopTest();
    }
    // In This Method We Passing The Model value is 'null'.
     static testmethod void leadTransferModelCheck(){
        Test.startTest();
        string olaleadjson='{\"applicationNumber\":\"12343\",\"name\":\"John Doe\",\"dob\":\"1996-01-01\",\"phone\":\"123456781\",\"pan\":\"apisd21973\",\"emailId\":\"ABC@gmail.com\",\"maritalStatus\":\"UNMAR\",\"profile\":\"COAL MINING\",\"category\":\"Salaried\",\"currentAddressPincode\":\"754123\",\"make\":\"Test Make\",\"model\":null,\"variant\":\"Test Variant\",\"vehiclePrice\":\"123\",\"chargerPrice\":\"123\",\"insurancePrice\":\"123\",\"handlingCharges\":\"123\",\"helmet\":\"123\",\"fameSubsidy\":\"123\",\"performanceUpgrade\":\"123\",\"cgst\":\"123\",\"sgst\":\"123\",\"igst\":\"123\",\"rtoRoadTax\":\"123\",\"iblORP\":\"123456\",\"loanAmount\":\"1234512345\",\"crmIRR\":\"11\",\"tenure\":\"11\",\"emi\":\"1212\",\"documentationCharge\":\"\",\"processingCharge\":\"\",\"stampDuty\":\"\",\"downpayment\":\"123123\",\"leadSource\":"OLA"}';
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = '/services/apexrest/v1/leadTransferAPI/';
        system.debug('request.requestURI---' + request.requestURI);
        request.httpMethod = 'Post';
        request.requestBody = Blob.valueof(IntegrationUtilities.getEncryptedRequest(olaleadjson,System.Label.privateKey,System.Label.ivkey));
        request.addHeader('Content-Type', 'application/json');
        RestContext.request = request;
        RestContext.response =response;
        OLALeadTransferAPI.uploadLeadDetails();
        Test.stopTest();
    }
    // In This Method We Passing The Variant value is 'null'.
     static testmethod void leadTransferVariantCheck(){
        Test.startTest();
        string olaleadjson='{\"applicationNumber\":\"12343\",\"name\":\"John Doe\",\"dob\":\"1996-01-01\",\"phone\":\"123456781\",\"pan\":\"apisd21973\",\"emailId\":\"ABC@gmail.com\",\"maritalStatus\":\"UNMAR\",\"profile\":\"COAL MINING\",\"category\":\"Salaried\",\"currentAddressPincode\":\"754123\",\"make\":\"Test Make\",\"model\":\"Test Model\",\"variant\":null,\"vehiclePrice\":\"123\",\"chargerPrice\":\"123\",\"insurancePrice\":\"123\",\"handlingCharges\":\"123\",\"helmet\":\"123\",\"fameSubsidy\":\"123\",\"performanceUpgrade\":\"123\",\"cgst\":\"123\",\"sgst\":\"123\",\"igst\":\"123\",\"rtoRoadTax\":\"123\",\"iblORP\":\"123456\",\"loanAmount\":\"1234512345\",\"crmIRR\":\"11\",\"tenure\":\"11\",\"emi\":\"1212\",\"documentationCharge\":\"\",\"processingCharge\":\"\",\"stampDuty\":\"\",\"downpayment\":\"123123\",\"leadSource\":"OLA"}';
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = '/services/apexrest/v1/leadTransferAPI/';
        system.debug('request.requestURI---' + request.requestURI);
        request.httpMethod = 'Post';
        request.requestBody = Blob.valueof(IntegrationUtilities.getEncryptedRequest(olaleadjson,System.Label.privateKey,System.Label.ivkey));
        request.addHeader('Content-Type', 'application/json');
        RestContext.request = request;
        RestContext.response =response;
        OLALeadTransferAPI.uploadLeadDetails();
        Test.stopTest();
    }
    // In This Method We Passing The Vehicle value is 'null'.
     static testmethod void leadTransferVehiclePriceCheck(){
        Test.startTest();
        string olaleadjson='{\"applicationNumber\":\"12343\",\"name\":\"John Doe\",\"dob\":\"1996-01-01\",\"phone\":\"123456781\",\"pan\":\"apisd21973\",\"emailId\":\"ABC@gmail.com\",\"maritalStatus\":\"UNMAR\",\"profile\":\"COAL MINING\",\"category\":\"Salaried\",\"currentAddressPincode\":\"754123\",\"make\":\"Test Make\",\"model\":\"Test Model\",\"variant\":\"Test Variant\",\"vehiclePrice\":null,\"chargerPrice\":\"123\",\"insurancePrice\":null,\"handlingCharges\":\"123\",\"helmet\":\"123\",\"fameSubsidy\":\"123\",\"performanceUpgrade\":\"123\",\"cgst\":\"123\",\"sgst\":\"123\",\"igst\":\"123\",\"rtoRoadTax\":\"123\",\"iblORP\":\"123456\",\"loanAmount\":\"1234512345\",\"crmIRR\":\"11\",\"tenure\":\"11\",\"emi\":\"1212\",\"documentationCharge\":\"\",\"processingCharge\":\"\",\"stampDuty\":\"\",\"downpayment\":\"123123\",\"leadSource\":"OLA"}';
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = '/services/apexrest/v1/leadTransferAPI/';
        system.debug('request.requestURI---' + request.requestURI);
        request.httpMethod = 'Post';
        request.requestBody = Blob.valueof(IntegrationUtilities.getEncryptedRequest(olaleadjson,System.Label.privateKey,System.Label.ivkey));
        request.addHeader('Content-Type', 'application/json');
        RestContext.request = request;
        RestContext.response =response;
        OLALeadTransferAPI.uploadLeadDetails();
        Test.stopTest();
    }
    // In This Method We Passing The ChargePriceCheck value is 'null'.
     static testmethod void leadTransferChargePriceCheck(){
        Test.startTest();
        string olaleadjson='{\"applicationNumber\":\"12343\",\"name\":\"John Doe\",\"dob\":\"1996-01-01\",\"phone\":\"123456781\",\"pan\":\"apisd21973\",\"emailId\":\"ABC@gmail.com\",\"maritalStatus\":\"UNMAR\",\"profile\":\"COAL MINING\",\"category\":\"Salaried\",\"currentAddressPincode\":\"754123\",\"make\":\"Test Make\",\"model\":\"Test Model\",\"variant\":\"Test Variant\",\"vehiclePrice\":\"123\",\"chargerPrice\":null,\"insurancePrice\":\"123\",\"handlingCharges\":\"123\",\"helmet\":\"123\",\"fameSubsidy\":\"123\",\"performanceUpgrade\":\"123\",\"cgst\":\"123\",\"sgst\":\"123\",\"igst\":\"123\",\"rtoRoadTax\":\"123\",\"iblORP\":\"123456\",\"loanAmount\":\"1234512345\",\"crmIRR\":\"11\",\"tenure\":\"11\",\"emi\":\"1212\",\"documentationCharge\":\"\",\"processingCharge\":\"\",\"stampDuty\":\"\",\"downpayment\":\"123123\",\"leadSource\":"OLA"}';
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = '/services/apexrest/v1/leadTransferAPI/';
        system.debug('request.requestURI---' + request.requestURI);
        request.httpMethod = 'Post';
        request.requestBody = Blob.valueof(IntegrationUtilities.getEncryptedRequest(olaleadjson,System.Label.privateKey,System.Label.ivkey));
        request.addHeader('Content-Type', 'application/json');
        RestContext.request = request;
        RestContext.response =response;
        OLALeadTransferAPI.uploadLeadDetails();
        Test.stopTest();
    }
    // In This Method We Passing The InsurancePrice value is 'null'.
     static testmethod void leadTransferInsurancePriceCheck(){
        Test.startTest();
        string olaleadjson='{\"applicationNumber\":\"12343\",\"name\":\"John Doe\",\"dob\":\"1996-01-01\",\"phone\":\"123456781\",\"pan\":\"apisd21973\",\"emailId\":\"ABC@gmail.com\",\"maritalStatus\":\"UNMAR\",\"profile\":\"COAL MINING\",\"category\":\"Salaried\",\"currentAddressPincode\":\"754123\",\"make\":\"Test Make\",\"model\":\"Test Model\",\"variant\":\"Test Variant\",\"vehiclePrice\":\"123\",\"chargerPrice\":\"123\",\"insurancePrice\":null,\"handlingCharges\":\"123\",\"helmet\":\"123\",\"fameSubsidy\":\"123\",\"performanceUpgrade\":\"123\",\"cgst\":\"123\",\"sgst\":\"123\",\"igst\":\"123\",\"rtoRoadTax\":\"123\",\"iblORP\":\"123456\",\"loanAmount\":\"1234512345\",\"crmIRR\":\"11\",\"tenure\":\"11\",\"emi\":\"1212\",\"documentationCharge\":\"\",\"processingCharge\":\"\",\"stampDuty\":\"\",\"downpayment\":\"123123\",\"leadSource\":"OLA"}';
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = '/services/apexrest/v1/leadTransferAPI/';
        system.debug('request.requestURI---' + request.requestURI);
        request.httpMethod = 'Post';
        request.requestBody = Blob.valueof(IntegrationUtilities.getEncryptedRequest(olaleadjson,System.Label.privateKey,System.Label.ivkey));
        request.addHeader('Content-Type', 'application/json');
        RestContext.request = request;
        RestContext.response =response;
        OLALeadTransferAPI.uploadLeadDetails();
        Test.stopTest();
    }
    // In This Method We Passing The HandlingChararges value is 'null'.
     static testmethod void leadTransferHandlingChargesCheck(){
        Test.startTest();
        string olaleadjson='{\"applicationNumber\":\"12343\",\"name\":\"John Doe\",\"dob\":\"1996-01-01\",\"phone\":\"123456781\",\"pan\":\"apisd21973\",\"emailId\":\"ABC@gmail.com\",\"maritalStatus\":\"UNMAR\",\"profile\":\"COAL MINING\",\"category\":\"Salaried\",\"currentAddressPincode\":\"754123\",\"make\":\"Test Make\",\"model\":\"Test Model\",\"variant\":\"Test Variant\",\"vehiclePrice\":\"123\",\"chargerPrice\":\"123\",\"insurancePrice\":\"123\",\"handlingCharges\":null,\"helmet\":\"123\",\"fameSubsidy\":\"123\",\"performanceUpgrade\":\"123\",\"cgst\":\"123\",\"sgst\":\"123\",\"igst\":\"123\",\"rtoRoadTax\":\"123\",\"iblORP\":\"123456\",\"loanAmount\":\"1234512345\",\"crmIRR\":\"11\",\"tenure\":\"11\",\"emi\":\"1212\",\"documentationCharge\":\"\",\"processingCharge\":\"\",\"stampDuty\":\"\",\"downpayment\":\"123123\",\"leadSource\":"OLA"}';
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = '/services/apexrest/v1/leadTransferAPI/';
        system.debug('request.requestURI---' + request.requestURI);
        request.httpMethod = 'Post';
        request.requestBody = Blob.valueof(IntegrationUtilities.getEncryptedRequest(olaleadjson,System.Label.privateKey,System.Label.ivkey));
        request.addHeader('Content-Type', 'application/json');
        RestContext.request = request;
        RestContext.response =response;
        OLALeadTransferAPI.uploadLeadDetails();
        Test.stopTest();
    }
    // In This Method We Passing The Famesubsidy value is 'null'.
    static testmethod void leadTransferFamesubsidy(){
        Test.startTest();
        string olaleadjson='{\"applicationNumber\":\"12343\",\"name\":\"John Doe\",\"dob\":\"1996-01-01\",\"phone\":\"123456781\",\"pan\":\"apisd21973\",\"emailId\":\"ABC@gmail.com\",\"maritalStatus\":\"UNMAR\",\"profile\":\"COAL MINING\",\"category\":\"Salaried\",\"currentAddressPincode\":\"754123\",\"make\":\"Test Make\",\"model\":\"Test Model\",\"variant\":\"Test Variant\",\"vehiclePrice\":\"123\",\"chargerPrice\":\"123\",\"insurancePrice\":\"123\",\"handlingCharges\":\"123\",\"helmet\":\"123\",\"fameSubsidy\":null,\"performanceUpgrade\":\"123\",\"cgst\":\"123\",\"sgst\":\"123\",\"igst\":\"123\",\"rtoRoadTax\":\"123\",\"iblORP\":\"123456\",\"loanAmount\":\"1234512345\",\"crmIRR\":\"11\",\"tenure\":\"11\",\"emi\":\"1212\",\"documentationCharge\":\"\",\"processingCharge\":\"\",\"stampDuty\":\"\",\"downpayment\":\"123123\",\"leadSource\":"OLA"}';
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = '/services/apexrest/v1/leadTransferAPI/';
        system.debug('request.requestURI---' + request.requestURI);
        request.httpMethod = 'Post';
        request.requestBody = Blob.valueof(IntegrationUtilities.getEncryptedRequest(olaleadjson,System.Label.privateKey,System.Label.ivkey));
        request.addHeader('Content-Type', 'application/json');
        RestContext.request = request;
        RestContext.response =response;
        OLALeadTransferAPI.uploadLeadDetails();
        Test.stopTest();
    }
    //OLA-107 Changes done in related class
    //Here Helmet datatype is Decimal But we Passed Text. 
    /* static testmethod void leadTransferHelmetValueWrongPass(){
        Test.startTest();
        string olaleadjson='{\"applicationNumber\":\"12343\",\"name\":\"John Doe\",\"dob\":\"1996-01-01\",\"phone\":\"123456781\",\"pan\":\"apisd21973\",\"emailId\":\"ABC@gmail.com\",\"maritalStatus\":\"UNMAR\",\"profile\":\"COAL MINING\",\"category\":\"Salaried\",\"currentAddressPincode\":\"754123\",\"make\":\"Test Make\",\"model\":\"Test Model\",\"variant\":\"Test Variant\",\"vehiclePrice\":\"123\",\"chargerPrice\":\"123\",\"insurancePrice\":\"123\",\"handlingCharges\":\"123\",\"helmet\":\"nshjs\",\"fameSubsidy\":\"123\",\"performanceUpgrade\":\"123\",\"cgst\":\"123\",\"sgst\":\"123\",\"igst\":\"123\",\"rtoRoadTax\":\"123\",\"iblORP\":\"123456\",\"loanAmount\":\"1234512345\",\"crmIRR\":\"11\",\"tenure\":\"11\",\"emi\":\"1212\",\"documentationCharge\":\"\",\"processingCharge\":\"\",\"stampDuty\":\"\",\"downpayment\":\"123123\",\"leadSource\":"OLA"}';
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = '/services/apexrest/v1/leadTransferAPI/';
        system.debug('request.requestURI---' + request.requestURI);
        request.httpMethod = 'Post';
        request.requestBody = Blob.valueof(olaleadjson);
        request.addHeader('Content-Type', 'application/json');
        RestContext.request = request;
        RestContext.response =response;
        OLALeadTransferAPI.uploadLeadDetails();
        Test.stopTest();
    }*/
    
    //By Suresh / Sriram
    static testmethod void leadTransferAllFieldCheckTest(){
        Test.startTest();
        
        //UserRole role = TestDataUtility.createUserRole(true, 'test', 'role');
        //User us = TestDataUtility.createUserForVoterId(true, role);
        
        
        User u = [SELECT Id, Name FROM User WHERE username = 'testingBusinessUser007@noemail.com.DSAtestuser'];
        Account communityAccount = [SELECT Id, Name, BranchBLCode__c FROM Account WHERE Name = 'Test KHT_TW_N' LIMIT 1];
        insert new AccountTeamMember(AccountId = communityAccount.Id, UserId = u.Id, TeamMemberRole = 'BE');
        
        /*System_Configuration__c sysConfig = new System_Configuration__c();
        sysConfig.Name = 'System Configuration';
        sysConfig.Eligible_Roles_for_BE_Assignment__c = 'BE,CS';
        sysConfig.Eligible_Roles_for_CS_Assignment__c = 'CS,MA';
        sysConfig.Eligible_Roles_for_MA_Assignment__c = 'MA,MO';
        sysConfig.Eligible_Roles_for_MO_Assignment__c = 'BE,CS,MA,MO';
        sysConfig.Application_Date__c = System.today();
        insert sysConfig;*/
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
        
        string olaleadjson='{\"applicationNumber\":\"12343\",\"name\":\"John Doe\",\"dob\":\"1996-01-01\",\"phone\":\"123456781\",\"pan\":\"apisd21973\",\"emailId\":\"ABC@gmail.com\",\"maritalStatus\":\"UNMAR\",\"profile\":\"COAL MINING\",\"category\":\"Salaried\",\"currentAddressPincode\":\"754123\",\"make\":\"Test Make\",\"model\":\"Test Model\",\"variant\":\"Test Variant\",\"vehiclePrice\":\"123\",\"chargerPrice\":\"123\",\"insurancePrice\":\"123\",\"handlingCharges\":\"123\",\"helmet\":\"123\",\"fameSubsidy\":\"123\",\"performanceUpgrade\":\"123\",\"cgst\":\"123\",\"sgst\":\"123\",\"igst\":\"123\",\"rtoRoadTax\":\"123\",\"iblORP\":\"123456\",\"loanAmount\":\"1234512345\",\"crmIRR\":\"11\",\"tenure\":\"11\",\"emi\":\"1212\",\"documentationCharge\":\"50\",\"processingCharge\":\"100\",\"stampDuty\":\"100\",\"downpayment\":\"123123\",\"leadSource\":\"OLA\"}';
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = '/services/apexrest/v1/leadTransferAPI/';
        system.debug('request.requestURI---' + request.requestURI);
        request.httpMethod = 'Post';
        request.requestBody = Blob.valueof(IntegrationUtilities.getEncryptedRequest(olaleadjson,System.Label.privateKey,System.Label.ivkey));
        request.addHeader('Content-Type', 'application/json');
        RestContext.request = request;
        RestContext.response =response;
        /*System_Configuration__c seqNumber = new System_Configuration__c();
        seqNumber.Name = 'System Configuration';
        seqNumber.Application_Sequence_No__c = 39.0;
        seqNumber.Application_Date__c = System.today();
        seqNumber.Eligible_Roles_for_BE_Assignment__c = 'BE,CS';
        seqNumber.Eligible_Roles_for_CS_Assignment__c = 'CS,MA';
        seqNumber.Eligible_Roles_for_MA_Assignment__c = 'MA,MO';
        seqNumber.Eligible_Roles_for_MO_Assignment__c = 'BE,CS,MA,MO';
        insert seqNumber;*/
        OLALeadTransferAPI.uploadLeadDetails();
        Test.stopTest();
    }
}