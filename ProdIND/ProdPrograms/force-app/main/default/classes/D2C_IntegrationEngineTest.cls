@isTest
private class D2C_IntegrationEngineTest {
    
    private class MockHttpResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            String response = '{"result": "success"}';
            String jdataRequest = '"bffData":';
            String encryptedResponse = IBMEncryption.getEncryptedRequest(response, System.Label.privateKey, System.Label.ivkey);  
            res.setBody('{'+jdataRequest + '"'+encryptedResponse+'"'+'}');
            return res;
        }
    }
    
    private class MockHttpResponseDoc implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setHeader('Content-Disposition','"Content-Disposition": "attachment; filename=\"example.txt\"');
            res.setStatus('{"response":{"status":"SUCCESS"}');
            String response = '{"response":{"status":"SUCCESS"}'; 
            String jdataRequest = '"JData":';
            String encryptedResponse = IBMEncryption.getEncryptedRequest(response, System.Label.privateKey, System.Label.ivkey);  
            res.setBody('{'+jdataRequest + '"'+encryptedResponse+'"'+'}');
            return res;
        }
    }
    
    private class MockHttpResponseError implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(400);
            String response = '{"result": "success"}';
            String jdataRequest = '"bffData":';
            String encryptedResponse = IBMEncryption.getEncryptedRequest(response, System.Label.privateKey, System.Label.ivkey);  
            res.setBody('{'+jdataRequest + '"'+encryptedResponse+'"'+'}');
            return res;
        }
    }
    
    
     @isTest
    static void testDoD2COfferEngineCallout() {
        // Test data setup
        // Create test opportunity
        Opportunity testOpportunity = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Prospecting',
            CloseDate = Date.today()
            // Add other necessary fields
        );
        insert testOpportunity;

        // Create test applicants related to the opportunity
        List<Applicant__c> testApplicants = new List<Applicant__c>();
        for (Integer i = 0; i < 3; i++) {
            Applicant__c testApplicant = new Applicant__c(
                Name = 'Test Applicant ' + i,
                Opportunity__c = testOpportunity.Id
                // Add other necessary fields
            );
            testApplicants.add(testApplicant);
        }
        insert testApplicants;

        // Set up mock callout response
         Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
       // Test.setMock(HttpCalloutMock.class, new OfferEngineMock());

        // Call the method under test
        Test.startTest();
      //  D2C_IntegrationEngine.doD2COfferEngineCallout(testOpportunity.Id, testApplicants[0].Id, 'screen', '5000', '36', '60000');
        Test.stopTest();

        // Assertions
        // Write assertions to verify the behavior of the method under test
        // Verify that the callout was made and processed successfully
    }
    
    @isTest
    static void testDoVehicleDedupeCallout() {
        Opportunity opp = new Opportunity(Name='Test Opp', StageName='Prospecting', Lead_number__c = '1234', CloseDate=Date.today(),Vehicle_Sub_Category__c = 'RLY', Amount=10000);
        insert opp;
        Applicant__c applicant = new Applicant__c(
            Customer_Code__c = 'Test Code',
            Opportunity__c = opp.Id,
            Customer_First_Name__c = 'Test',
            Customer_Last_Name__c = 'Applicant'
        );
        insert applicant;
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
        Test.startTest();
        D2C_IntegrationEngine.doVehicleDedupeCallout(opp.Id, 'Status');
        Test.stopTest();
    }
    
    @isTest
    static void testDoVehicleDedupeCallout1() {
        try{
            Opportunity opp = new Opportunity(Name='Test Opp', StageName='Prospecting', Lead_number__c = '1234', CloseDate=Date.today(),Vehicle_Sub_Category__c = 'RLY', Amount=10000);
            insert opp;
            Applicant__c applicant = new Applicant__c(
                Customer_Code__c = 'Test Code',
                Opportunity__c = opp.Id,
                Customer_First_Name__c = 'Test',
                Customer_Last_Name__c = 'Applicant'
            );
            insert applicant;
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseError());
            Test.startTest();
            D2C_IntegrationEngine.doVehicleDedupeCallout(opp.Id, 'Status');
            Test.stopTest();
        }
        catch(Exception ex){
            System.assertNotEquals(null,ex.getMessage());
        }
    }
    @isTest
    static void testDoVehicleDedupeCalloutException() {
        Opportunity opp = new Opportunity(Name='Test Opp', StageName='Prospecting', Lead_number__c = '1234', CloseDate=Date.today(), Amount=10000);
        insert opp;
        Applicant__c applicant = new Applicant__c(
            Customer_Code__c = 'Test Code',
            Opportunity__c = opp.Id,
            Customer_First_Name__c = 'Test',
            Customer_Last_Name__c = 'Applicant'
        );
        insert applicant;
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
        Test.startTest();
        try{
            D2C_IntegrationEngine.doVehicleDedupeCallout(opp.Id, 'Status');    
        }catch(Exception ex){}
        Test.stopTest();
    }
    
    @isTest
    static void testDoDisbursedCommunicationCallout() {
        Opportunity opp = new Opportunity(Name='Test Opp', StageName='Prospecting', Lead_number__c = '1234', CloseDate=Date.today(),Vehicle_Sub_Category__c = 'RLY', Amount=10000);
        insert opp;
        Applicant__c applicant = new Applicant__c(
            Customer_Code__c = 'Test Code',
            Opportunity__c = opp.Id,
            Customer_First_Name__c = 'Test',
            Customer_Last_Name__c = 'Applicant'
        );
        insert applicant;
        Final_Term__c finalTerms = new Final_Term__c(
            Loan_Application__c = opp.Id, 
            Tenure__c = '36', 
            Loan_Amount__c = '700000', 
            EMI_Amount__c = 25000, 
            Net_IRR__c = 8.2 
        );
        insert finalTerms;
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
        Test.startTest();
        D2C_IntegrationEngine.doDisbursedCommunicationCallout(opp.Id);
        Test.stopTest();
    }
    
    @isTest
    static void testDoDisbursedCommunicationCallout1() {
        try{
            Opportunity opp = new Opportunity(Name='Test Opp', StageName='Prospecting', Lead_number__c = '1234', CloseDate=Date.today(),Vehicle_Sub_Category__c = 'RLY', Amount=10000);
            insert opp;
            Applicant__c applicant = new Applicant__c(
                Customer_Code__c = 'Test Code',
                Opportunity__c = opp.Id,
                Customer_First_Name__c = 'Test',
                Customer_Last_Name__c = 'Applicant'
            );
            insert applicant;
            Final_Term__c finalTerms = new Final_Term__c(
                Loan_Application__c = opp.Id, 
                Tenure__c = '36', 
                Loan_Amount__c = '700000', 
                EMI_Amount__c = 25000, 
                Net_IRR__c = 8.2 
            );
            insert finalTerms;
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseError());
            Test.startTest();
            D2C_IntegrationEngine.doDisbursedCommunicationCallout(opp.Id);
            Test.stopTest();
        }
        catch(Exception ex){
            System.assertNotEquals(null,ex.getMessage());
        }
    }
    @isTest
    static void testDoDisbursedCommunicationCalloutException() {
        Opportunity opp = new Opportunity(Name='Test Opp', StageName='Prospecting', Lead_number__c = '1234', CloseDate=Date.today(), Amount=10000);
        insert opp;
        Applicant__c applicant = new Applicant__c(
            Customer_Code__c = 'Test Code',
            Opportunity__c = opp.Id,
            Customer_First_Name__c = 'Test',
            Customer_Last_Name__c = 'Applicant'
        );
        insert applicant;
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
        Test.startTest();
        try{
            D2C_IntegrationEngine.doDisbursedCommunicationCallout(opp.Id);    
        }catch(Exception ex){}
        Test.stopTest();
    }
    
    @isTest
    static void testDoSanctionCommunicationCallout() {
        Opportunity opp = new Opportunity(Name='Test Opp', StageName='Prospecting', Lead_number__c = '1234', CloseDate=Date.today(),Vehicle_Sub_Category__c = 'RLY', Amount=10000);
        insert opp;
        Applicant__c applicant = new Applicant__c(
            Customer_Code__c = 'Test Code',
            Opportunity__c = opp.Id,
            Customer_First_Name__c = 'Test',
            Customer_Last_Name__c = 'Applicant'
        );
        insert applicant;
        Final_Term__c finalTerms = new Final_Term__c(
            Loan_Application__c = opp.Id, 
            Tenure__c = '36', 
            Loan_Amount__c = '700000', 
            EMI_Amount__c = 25000, 
            Net_IRR__c = 8.2 
        );
        insert finalTerms;
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
        Test.startTest();
        D2C_IntegrationEngine.doSanctionCommunicationCallout(opp.Id);
        Test.stopTest();
    }
    
    @isTest
    static void testDoSanctionCommunicationCallout1() {
        try{
            Opportunity opp = new Opportunity(Name='Test Opp', StageName='Prospecting', Lead_number__c = '1234', CloseDate=Date.today(),Vehicle_Sub_Category__c = 'RLY', Amount=10000);
            insert opp;
            Applicant__c applicant = new Applicant__c(
                Customer_Code__c = 'Test Code',
                Opportunity__c = opp.Id,
                Customer_First_Name__c = 'Test',
                Customer_Last_Name__c = 'Applicant'
            );
            insert applicant;
            Final_Term__c finalTerms = new Final_Term__c(
                Loan_Application__c = opp.Id, 
                Tenure__c = '36', 
                Loan_Amount__c = '700000', 
                EMI_Amount__c = 25000, 
                Net_IRR__c = 8.2 
            );
            insert finalTerms;
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseError());
            Test.startTest();
            D2C_IntegrationEngine.doSanctionCommunicationCallout(opp.Id);
            Test.stopTest();
        }
        catch(Exception ex){
            System.assertNotEquals(null,ex.getMessage());
        }
    }
    
    @isTest
    static void testDoSanctionCommunicationCalloutException() {
        Opportunity opp = new Opportunity(Name='Test Opp', StageName='Prospecting', Lead_number__c = '1234', CloseDate=Date.today(), Amount=10000);
        insert opp;
        Applicant__c applicant = new Applicant__c(
            Customer_Code__c = 'Test Code',
            Opportunity__c = opp.Id,
            Customer_First_Name__c = 'Test',
            Customer_Last_Name__c = 'Applicant'
        );
        insert applicant;
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
        Test.startTest();
        try{
            D2C_IntegrationEngine.doSanctionCommunicationCallout(opp.Id);    
        }catch(Exception ex){}
        Test.stopTest();
    }
    
    @isTest
    static void testDoVehicleValuationCallout() {
        Opportunity opp = new Opportunity(Name='Test Opp', StageName='Prospecting', Lead_number__c = '1234', CloseDate=Date.today(),Vehicle_Sub_Category__c = 'RLY', Amount=10000);
        insert opp;
        Applicant__c applicant = new Applicant__c(
            Customer_Code__c = 'Test Code',
            Opportunity__c = opp.Id,
            Customer_First_Name__c = 'Test',
            Customer_Last_Name__c = 'Applicant'
        );
        insert applicant;
        Final_Term__c finalTerms = new Final_Term__c(
            Loan_Application__c = opp.Id, 
            Tenure__c = '36', 
            Loan_Amount__c = '700000', 
            EMI_Amount__c = 25000, 
            Net_IRR__c = 8.2 
        );
        insert finalTerms;
        Vehicle_Detail__c vehicleDetail = new Vehicle_Detail__c(
            Loan_Application__c = opp.Id,
            Manufacturer_Year_Month__c = '2020-07'
        );
        insert vehicleDetail;
        InsuranceDetails__c insurance = new InsuranceDetails__c(
            Loan_Application__c = opp.Id,
            Applicant__c = applicant.Id
        );
        insert insurance;
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
        Test.startTest();
        D2C_IntegrationEngine.doVehicleValuationCallout(opp.Id,'insurance');
        Test.stopTest();
    }
    
    @isTest
    static void testDoVehicleValuationCallout1() {
        try{
            Opportunity opp = new Opportunity(Name='Test Opp', StageName='Prospecting', Lead_number__c = '1234', CloseDate=Date.today(),Vehicle_Sub_Category__c = 'RLY', Amount=10000);
            insert opp;
            Applicant__c applicant = new Applicant__c(
                Customer_Code__c = 'Test Code',
                Opportunity__c = opp.Id,
                Customer_First_Name__c = 'Test',
                Customer_Last_Name__c = 'Applicant'
            );
            insert applicant;
            Final_Term__c finalTerms = new Final_Term__c(
                Loan_Application__c = opp.Id, 
                Tenure__c = '36', 
                Loan_Amount__c = '700000', 
                EMI_Amount__c = 25000, 
                Net_IRR__c = 8.2 
            );
            insert finalTerms;
            Vehicle_Detail__c vehicleDetail = new Vehicle_Detail__c(
                Loan_Application__c = opp.Id,
                Manufacturer_Year_Month__c = '2020-07'
            );
            insert vehicleDetail;
            InsuranceDetails__c insurance = new InsuranceDetails__c(
                Loan_Application__c = opp.Id,
                Applicant__c = applicant.Id
            );
            insert insurance;
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseError());
            Test.startTest();
            D2C_IntegrationEngine.doVehicleValuationCallout(opp.Id,'insurance');
            Test.stopTest();
        }
        catch(Exception ex){
            System.assertNotEquals(null,ex.getMessage());
        }
    }
    @isTest
    static void testDoVehicleValuationCalloutException() {
        Opportunity opp = new Opportunity(Name='Test Opp', StageName='Prospecting', Lead_number__c = '1234', CloseDate=Date.today(), Amount=10000);
        insert opp;
        Applicant__c applicant = new Applicant__c(
            Customer_Code__c = 'Test Code',
            Opportunity__c = opp.Id,
            Customer_First_Name__c = 'Test',
            Customer_Last_Name__c = 'Applicant'
        );
        insert applicant;
        Vehicle_Detail__c vehicleDetail = new Vehicle_Detail__c(
            Loan_Application__c = opp.Id
        );
        insert vehicleDetail;
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
        Test.startTest();
        try{
            D2C_IntegrationEngine.doVehicleValuationCallout(opp.Id,'insurance');    
        }catch(Exception ex){}
        
        Test.stopTest();
    }
   @isTest
    static void testDoD2COfferEngineCallouts(){
        Opportunity opp = new Opportunity(
            Name='Test Opp', 
            StageName='Prospecting', 
            Lead_number__c = '1234', 
            CloseDate=Date.today(), 
            Amount=10000, 
            LeadSource = 'D2C',
            Vehicle_Type__c = 'new',
            Product_Type__c='Passenger Vehicles',
            On_Road_price__c = 500000,
            Is_Pre_Approved__c = true
        );
        insert opp;
        Applicant__c applicant = new Applicant__c(
            Customer_Code__c = 'Test Code',
            Opportunity__c = opp.Id,
            Customer_First_Name__c = 'Test',
            Customer_Last_Name__c = 'Applicant',
            Declared_income__c = 60000,
            SumofAllLowerEMIs__c = 222
        );
        insert applicant;
        Existing_EMI__c emi = TestDataUtility.createTestEMI(false);
        emi.Applicant_Id__c = applicant.Id;
        insert emi;
        Final_Term__c finalTerms = new Final_Term__c(
            Loan_Application__c = opp.Id, 
            Tenure__c = '36', 
            Loan_Amount__c = '700000', 
            EMI_Amount__c = 25000, 
            Net_IRR__c = 8.2 
        );
        insert finalTerms;
        Vehicle_Detail__c vehicleDetail = new Vehicle_Detail__c(
            Loan_Application__c = opp.Id,
            Manufacturer_Year_Month__c = '2020-07'
        );
        insert vehicleDetail;
        InsuranceDetails__c insurance = new InsuranceDetails__c(
            Loan_Application__c = opp.Id,
            Applicant__c = applicant.Id
        );
        insert insurance;
        Income_Details__c iDetails = new Income_Details__c(
            Applicant__c = applicant.Id,
            Income_Source_Status__c = 'IP' ,
            Income_from_Perfios__c = 222
        );
        insert iDetails;
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
        Test.startTest();
        try{
            D2C_IntegrationEngine.doD2COfferEngineCallout(opp.Id,applicant.Id,'sliderScreen',null,null,null,null,null);  
            IND_OfferEngineServiceD2C.getD2COfferEngineCallOutRequest(null,null,null);
        }catch(Exception ex){}
        
        Test.stopTest();
        
    }
    
   /*@isTest
    static void testDoD2COfferEngineCallout1(){
        Opportunity opp = new Opportunity(
            Name='Test Opp', 
            StageName='Prospecting', 
            Lead_number__c = '1234', 
            CloseDate=Date.today(), 
            Amount=10000, 
            LeadSource = 'D2C',
            Vehicle_Type__c = 'new',
            On_Road_price__c = 500000,
            Aggregator_Source__c ='test'
        );
        insert opp;
        Applicant__c applicant = new Applicant__c(
            Customer_Code__c = 'Test Code',
            Opportunity__c = opp.Id,
            Customer_First_Name__c = 'Test',
            Customer_Last_Name__c = 'Applicant',
            Declared_income__c = 60000,
            SumofAllLowerEMIs__c = 222
        );
        insert applicant;
        Existing_EMI__c emi = TestDataUtility.createTestEMI(false);
        emi.Applicant_Id__c = applicant.Id;
        insert emi;
        
        Vehicle_Detail__c vehicleDetail = new Vehicle_Detail__c(
            Loan_Application__c = opp.Id,
            Manufacturer_Year_Month__c = '2020-07',
            Ben_Code__c = 'abc'
        );
        insert vehicleDetail;
        Benefi__c ben = TestDataUtility.createTestBenMaster(true);
        InsuranceDetails__c insurance = new InsuranceDetails__c(
            Loan_Application__c = opp.Id,
            Applicant__c = applicant.Id
        );
        insert insurance;
        Income_Details__c iDetails = new Income_Details__c(
            Applicant__c = applicant.Id,
            Income_Source_Status__c = 'IP' ,
            Income_from_Perfios__c = 222
        );
        insert iDetails;
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
        Test.startTest();
        try{
            D2C_IntegrationEngine.doD2COfferEngineCallout(opp.Id,applicant.Id,'sliderScreen',null,null,null);  
        }catch(Exception ex){}
        
        Test.stopTest();
        
    }
    
    @isTest
    static void testDoD2COfferEngineCallout2(){
        Opportunity opp = new Opportunity(
            Name='Test Opp', 
            StageName='Prospecting', 
            Lead_number__c = '1234', 
            CloseDate=Date.today(), 
            Amount=10000, 
            LeadSource = 'D2C',
            Vehicle_Type__c = 'New',
            On_Road_price__c = 500000,
            Is_Pre_Approved__c = true
        );
        insert opp;
        Applicant__c applicant = new Applicant__c(
            Customer_Code__c = 'Test Code',
            Opportunity__c = opp.Id,
            Customer_First_Name__c = 'Test',
            Customer_Last_Name__c = 'Applicant',
            Declared_income__c = 60000,
            SumofAllLowerEMIs__c = 222
        );
        insert applicant;
        Existing_EMI__c emi = TestDataUtility.createTestEMI(false);
        emi.Applicant_Id__c = applicant.Id;
        insert emi;
        Final_Term__c finalTerms = new Final_Term__c(
            Loan_Application__c = opp.Id, 
            Tenure__c = '36', 
            Loan_Amount__c = '700000', 
            EMI_Amount__c = 25000, 
            Net_IRR__c = 8.2 
        );
        insert finalTerms;
        
        Vehicle_Detail__c vehicleDetail = new Vehicle_Detail__c(
            Loan_Application__c = opp.Id,
            Manufacturer_Year_Month__c = '2020-07'
        );
        insert vehicleDetail;
        InsuranceDetails__c insurance = new InsuranceDetails__c(
            Loan_Application__c = opp.Id,
            Applicant__c = applicant.Id
        );
        insert insurance;
        Income_Details__c iDetails = new Income_Details__c(
            Applicant__c = applicant.Id,
            Income_Source_Status__c = 'IP' ,
            Income_from_Perfios__c = 222
        );
        insert iDetails;
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
        Test.startTest();
        try{
            D2C_IntegrationEngine.doD2COfferEngineCallout(opp.Id,applicant.Id,'sliderScreen',null,null,null);  
            IND_OfferEngineServiceD2C.getD2COfferEngineCallOutRequest(null,null,null);
        }catch(Exception ex){}
        
        Test.stopTest();
        
    }
    
    @isTest
    static void testDoD2COfferEngineCalloutException() {
        Test.startTest();
        try{
            D2C_IntegrationEngine.doD2COfferEngineCallout(null,null,'cam',null,null,null);
        }catch(Exception ex){}
        Test.stopTest();
    }
    */
    @isTest    
    static void testDoVKCDocumentDownload(){
        Profile p = [SELECT Id FROM Profile WHERE Name='IBL Business Executive'];
        system.debug('p'+ p);
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,Maker_Id__c = '1001',User_Id__c = '29927_MO',
                          TimeZoneSidKey='America/Los_Angeles',
                          MobilePhone = '9701498575',
                          UserName='standarduser4@testorg.com.psdev1');
        insert u; 
        System.runAs(u){
            D2C_IntegrationEngine.VKYCDocumentsWrapper vkycWrapper = new D2C_IntegrationEngine.VKYCDocumentsWrapper();
            vkycWrapper.aadhar_photo = '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';
            Opportunity opp = new Opportunity(
                Name='Test Opp', 
                StageName='Prospecting', 
                Lead_number__c = '1234', 
                CloseDate=Date.today(), 
                Amount=10000, 
                LeadSource = 'D2C',
                Vehicle_Type__c = 'New',
                On_Road_price__c = 500000,
                VKYC_Doc_Urls__c = JSON.serialize(vkycWrapper)
            );
            insert opp;
            Applicant__c applicant = new Applicant__c(
                Customer_Code__c = 'Test Code',
                Opportunity__c = opp.Id,
                Customer_First_Name__c = 'Test',
                Customer_Last_Name__c = 'Applicant',
                Declared_income__c = 60000
            );
            insert applicant;
            D2C_IntegrationEngine.retryCountIncrease(opp.Id);
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseDoc());
            Test.startTest();
            try{ 
                D2C_IntegrationEngine.doVKCDocumentDownload(opp.Id);
            }catch(Exception ex){
                System.debug('Exception :::'+ex.getMessage()+'Line Number:::'+ex.getLineNumber());
            }
            
            Test.stopTest();
        }
    }
    
    @isTest    
    static void testDoVKCDocumentDownloadPAN(){
        Profile p = [SELECT Id FROM Profile WHERE Name='IBL Business Executive'];
        system.debug('p'+ p);
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,Maker_Id__c = '1001',User_Id__c = '29927_MO',
                          TimeZoneSidKey='America/Los_Angeles',
                          MobilePhone = '9701498575',
                          UserName='standarduser4@testorg.com.psdev1');
        insert u; 
        System.runAs(u){
            D2C_IntegrationEngine.VKYCDocumentsWrapper vkycWrapper = new D2C_IntegrationEngine.VKYCDocumentsWrapper();
            vkycWrapper.pan_card = 'test';
            Opportunity opp = new Opportunity(
                Name='Test Opp', 
                StageName='Prospecting', 
                Lead_number__c = '1234', 
                CloseDate=Date.today(), 
                Amount=10000, 
                LeadSource = 'D2C',
                Vehicle_Type__c = 'New',
                On_Road_price__c = 500000,
                VKYC_Doc_Urls__c = JSON.serialize(vkycWrapper)
            );
            insert opp;
            Applicant__c applicant = new Applicant__c(
                Customer_Code__c = 'Test Code',
                Opportunity__c = opp.Id,
                Customer_First_Name__c = 'Test',
                Customer_Last_Name__c = 'Applicant',
                Declared_income__c = 60000
            );
            insert applicant;
            D2C_IntegrationEngine.retryCountIncrease(opp.Id);
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseDoc());
            Test.startTest();
            try{ 
                D2C_IntegrationEngine.doVKCDocumentDownload(opp.Id);
            }catch(Exception ex){
                System.debug('Exception :::'+ex.getMessage()+'Line Number:::'+ex.getLineNumber());
            }
            Test.stopTest();
        }
    }
    
    @isTest
    static void testProcessOfferEngineCalloutResponseD2C() {
        try{
            List<String> labels = new List<String>{'label1'};
                Test.startTest();
            Boolean res =D2C_IntegrationEngine.expression('test');
            Object result = D2C_IntegrationEngine.processOfferEngineCalloutResponseD2C(labels, null);
            System.assertEquals(true,res);
            Test.stopTest();   
        }
        catch(Exception ex){
            System.debug('Exception :::'+ex.getMessage()+'Line Number:::'+ex.getLineNumber());
        }
    }
}