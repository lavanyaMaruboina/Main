@isTest
public class CalloutProcessorTest {
    
    private class MockHttpResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            String response = '{"result": "success"}';
            String jdataRequest = '"JData":';
            String encryptedResponse = IBMEncryption.getEncryptedRequest(response, System.Label.privateKey, System.Label.ivkey);  
            res.setBody('{'+jdataRequest + '"'+encryptedResponse+'"'+'}');
            return res;
        }
    }
    
    @testSetup
    static void testData(){
        Opportunity opp = TestDataUtility.createTestOpportunity(false);
        opp.Product_Type__c = System.Label.Tractor;
        insert opp;
        Applicant__c applicant = TestDataUtility.createTestApplicantForCIBIL(true, opp);
        Deal_Number_Setting__c dlNumberSetting= new Deal_Number_Setting__c();
        dlNumberSetting.Name = System.Label.Tractor;
        dlNumberSetting.MDNField1__c ='AB';
        dlNumberSetting.MDNField2__c = 2.0;
        insert dlNumberSetting;
        
        Deal_Number__c dealNumber=new Deal_Number__c();
        dealNumber.Loan_Application__c = opp.Id;
        dealNumber.Sub_Stage__c = 'RC Upload';
        insert dealNumber;
    }
    @isTest
    static void testCreateHttpRequestForReverseStatus() {
        Opportunity opp = [SELECT Id,Lead_number__c,Product_Type__c,Parent_Deal_number__c FROM Opportunity LIMIT 1];
        Deal_Number__c dealNumber = [SELECT Id FROM Deal_Number__c LIMIT 1];
        
        IND_DealEligibleRefinanceRequest dealEligibleRequest = IND_DealEligibleRefinanceService.getDealEligibleRefinance(opp,dealNumber.Id);
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());       
        Test.startTest();
        CalloutProcessor obj= new CalloutProcessor(System.Label.DealEligibleRefinanceAPI,dealEligibleRequest);
        obj.serviceName = 'UIDAI OTP';
        HttpRequest req = obj.createHttpRequestForReverseStatus();
        HttpRequest req1 = obj.createHttpRequest();
        System.assertNotEquals(null,req);
        Test.stopTest();
    }
    
    @isTest
    static void testCreateHttpRequest() {
        Opportunity opp = [SELECT Id,Lead_number__c,Product_Type__c,Parent_Deal_number__c FROM Opportunity LIMIT 1];
        Deal_Number__c dealNumber = [SELECT Id FROM Deal_Number__c LIMIT 1];
        
        IND_DealEligibleRefinanceRequest dealEligibleRequest = IND_DealEligibleRefinanceService.getDealEligibleRefinance(opp,dealNumber.Id);
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());       
        Test.startTest();
        CalloutProcessor obj= new CalloutProcessor(System.Label.DealEligibleRefinanceAPI,dealEligibleRequest);
        obj.serviceName = system.label.Membership;
        HttpRequest req = obj.createHttpRequest();
        System.assertNotEquals(null,req);
        Test.stopTest();
    }
    
    @isTest
    static void testCreateHttpRequest1() {
        Opportunity opp = [SELECT Id,Lead_number__c,Product_Type__c,Parent_Deal_number__c FROM Opportunity LIMIT 1];
        Deal_Number__c dealNumber = [SELECT Id FROM Deal_Number__c LIMIT 1];
        
        IND_DealEligibleRefinanceRequest dealEligibleRequest = IND_DealEligibleRefinanceService.getDealEligibleRefinance(opp,dealNumber.Id);
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());       
        Test.startTest();
        CalloutProcessor obj= new CalloutProcessor(System.Label.DealEligibleRefinanceAPI,dealEligibleRequest);
        obj.serviceName = System.Label.D2CVehicleValuation;
        HttpRequest req = obj.createHttpRequest();
        System.assertNotEquals(null,req);
        Test.stopTest();
    }
    
    @isTest
    static void testCreateHttpRequest2() {
        Opportunity opp = [SELECT Id,Lead_number__c,Product_Type__c,Parent_Deal_number__c FROM Opportunity LIMIT 1];
        Deal_Number__c dealNumber = [SELECT Id FROM Deal_Number__c LIMIT 1];
        
        IND_DealEligibleRefinanceRequest dealEligibleRequest = IND_DealEligibleRefinanceService.getDealEligibleRefinance(opp,dealNumber.Id);
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());       
        Test.startTest();
        CalloutProcessor obj= new CalloutProcessor(System.Label.DealEligibleRefinanceAPI,dealEligibleRequest);
        obj.serviceName = System.Label.Payment_Request_For_Tractor;
        HttpRequest req = obj.createHttpRequest(); 
        HttpRequest req1 = obj.createHttpRequestForAadhaarVaultApi();
        System.assertNotEquals(null,req);
        Test.stopTest();
    }    
    
    @isTest
    static void testGetHttpResponseForAll(){ 
        try{
            Opportunity loanApp = [SELECT Id,Lead_number__c FROM Opportunity];
            Applicant__c applicant = [SELECT Id,Opportunity__r.Parent_Deal_number__c,Opportunity__r.Deal_number__c FROM Applicant__c ];
            Continuation con = (Continuation)IntegrationEngine.doNeSLAgreementStatusCallout(applicant.Id,loanApp.Id);
            Map<String, HttpRequest> requests = con.getRequests();
            
            HttpResponse response = new HttpResponse();
            response.setBody('JData":"4jSxLhM7jTK4VPvES1SWnJ+cKI3O+yFsaEutijpuT+g=');            
            response.setStatusCode(200);
            
            String continuationLabel = IntegrationEngine.continuationLabel;
            String membershipResponse = '';
            List<String> labels = new List<String>{continuationLabel};
                Object continuationState= IntegrationEngine.continuationState;   
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
            IntegrationEngine.processUidaiBiometricResponse(labels, continuationState);
            Test.stopTest(); 
        }
        catch(Exception ex){
            
        }
    }
}