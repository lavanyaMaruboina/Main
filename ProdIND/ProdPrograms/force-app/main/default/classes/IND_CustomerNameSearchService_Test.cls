@isTest(SeeAllData=false)
public class IND_CustomerNameSearchService_Test {
	
    // @Method:		TestServiceMetthod
    // @Created by:	Bhushan Charde
    // @Description:Test setup method to create the test data for IND_CustomerNameSearchService classs
    // @Param:		''	
    // @Return: 	'' 
    @isTest
    public static void testCustomerNameSearchService(){
        try{
            
          	Opportunity opp = TestDataUtility.createTestOpportunity(false);
           if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            
            Applicant__c applicant = TestDataUtility.createTestApplicantForSMS(false);
            applicant.Opportunity__c=opp.Id;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert applicant;
            }
            
           // String dlCallOutRequest = '{"dealNumber":"AHX13408C","customerCode":""}';
            //Continuation con = (Continuation)IntegrationEngine.doCustomerNameSearchCallout(dlCallOutRequest);
            // Create a mock response
        	HttpResponse response = new HttpResponse();
            String body = '{"JData":"bmvHXB5/b59ltoDPA8dwPKjM9zW1GwK5fvqA5/8G5niTO0HGpEWrGII4BTYnRVljMuanWQLLw2a9s1GUqQAgEB6RyxSo1Hhk2ihJXxR0IjSFIiXxm5GNV13Yo2w/AJyWgqEfGKRcXPEePTQsHU35W5tzWsoCaCLSWmIM5dfi4idGGrWuO6vKKtBdNu9gprUC"}';
            response.setBody(body);
            response.setStatusCode(200);
            
			String continuationLabel = IntegrationEngine.continuationLabel;
 		    List<String> labels = new List<String>{continuationLabel};
            Object continuationState= IntegrationEngine.continuationState;   
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
            String callOutResponse = (String)IntegrationEngine.processCustomerNameSearchResponse(labels, IntegrationEngine.continuationState);
            Test.stopTest();
            String responseExpected ='{"body":null,"response":{"status":"SUCCESS","respDesc":"Customer Name Search","content":[{"Flag":null,"Description":null,"Customer_Name":"MANOHAR","Customer_Code":"CU3761425"}]}}';
            //String responseExpected ='{"body":null,"response":{"status":"SUCCESS","respDesc":"Customer Name Search","content":[{"Customer_Name":"MANOHAR","Customer_Code":"CU3761425"}]}}';
            System.assertEquals(responseExpected, callOutResponse);
        } catch(Exception ex){
            System.assertEquals(ex.getMessage(), 'Null label');
        }
    }
//System.Label.Retry ,    
    // @Method:		TestServiceMetthod
    // @Created by:	Bhushan Charde
    // @Description:Test setup method to create the test data for IND_CustomerNameSearchService classs
    // @Param:		''	
    // @Return: 	'' 
     @isTest
    public static void testCustomerNameSearchService3(){
        try{
            
          	Opportunity opp = TestDataUtility.createTestOpportunity(false);
           if (Schema.sObjectType.Opportunity.isCreateable()){
                insert opp;
            }
            
            Applicant__c applicant = TestDataUtility.createTestApplicantForSMS(false);
            applicant.Opportunity__c=opp.Id;
            if (Schema.sObjectType.Applicant__c.isCreateable()){
                insert applicant;
            }
            
            String dlCallOutRequest = '{"dealNumber":"","customerCode":""}';
            //Continuation con = (Continuation)IntegrationEngine.doCustomerNameSearchCallout(dlCallOutRequest);
            // Create a mock response
        	HttpResponse response = new HttpResponse();
            String body = '{"JData":"bmvHXB5/b59ltoDPA8dwPKjM9zW1GwK5fvqA5/8G5niTO0HGpEWrGII4BTYnRVljMuanWQLLw2a9s1GUqQAgEB6RyxSo1Hhk2ihJXxR0IjSFIiXxm5GNV13Yo2w/AJyWgqEfGKRcXPEePTQsHU35W5tzWsoCaCLSWmIM5dfi4idGGrWuO6vKKtBdNu9gprUC"}';
            response.setBody(body);
            response.setStatusCode(500);
            
			String continuationLabel = IntegrationEngine.continuationLabel;
 		    List<String> labels = new List<String>{continuationLabel};
            Object continuationState= IntegrationEngine.continuationState;   
            Test.startTest();
            Test.setContinuationResponse(continuationLabel, response);
            String callOutResponse = (String)IntegrationEngine.processCustomerNameSearchResponse(labels, IntegrationEngine.continuationState);
            Test.stopTest();
            //String responseExpected ='{"response":{"status":"SUCCESS","respDesc":"Customer Name Search","content":[{"Customer_Code":"CU3761425","Customer_Name":"MANOHAR"}]}}';
            String responseExpected ='{"body":null,"response":{"status":"SUCCESS","respDesc":"Customer Name Search","content":[{"Customer_Name":"MANOHAR","Customer_Code":"CU3761425"}]}}';
            System.assertEquals(responseExpected, callOutResponse, 'SUCCESS');
        } catch(Exception ex){
            System.assertEquals(ex.getMessage(),'Null label','Null label');
        }
    }
    
    
 /*    @isTest
    public static void testIND_CustomerNameSearchResponse(){
        
        IND_CustomerNameSearchResponse customerNameSearchResponse = new IND_CustomerNameSearchResponse();
        IND_CustomerNameSearchResponse.Response response = new IND_CustomerNameSearchResponse.Response();
        response.status = '200';
        response.respDesc = 'Test';
        IND_CustomerNameSearchResponse.Content content = new IND_CustomerNameSearchResponse.Content();
        content.Description = 'Test';
        content.Flag = 'Test';
       
        content.Customer_Code = 'Test';
        content.Customer_Name = 'Test';
        response.content = new List<IND_CustomerNameSearchResponse.Content>{content};
        customerNameSearchResponse.response = response;
        System.assertEquals(customerNameSearchResponse.response.status, '200');
    } */
    
    @isTest
    private static void verifyRequestWrapper(){
        Opportunity opp = TestDataUtility.createTestOpportunity(true);
        Applicant__c applicant = TestDataUtility.createTestApplicantForSMS(false);
        applicant.Opportunity__c=opp.Id;
        insert applicant;
        
        RequestWrapper requestWrapperObj =new RequestWrapper();
        requestWrapperObj.applicantId = String.valueOf(applicant.Id);
        requestWrapperObj.panNumber = 'ADIPS1045P';
        requestWrapperObj.firstName = 'TestFirstName';
        requestWrapperObj.lastName = 'TestLastName';
        requestWrapperObj.dlNumber = 'DLDAP28102993';
        requestWrapperObj.dateOfBirth = '26/June/1982';
        requestWrapperObj.dealNumber = '28102993';
        requestWrapperObj.customerCode = 'ADIPS1045P';
        requestWrapperObj.telephoneNumber = '1234567890'; 
        IND_CustomerNameSearchRequest searchRequest = new IND_CustomerNameSearchRequest(requestWrapperObj, opp.Id);
        
        Map<String,String> requestHeaderMap = searchRequest.getHttpRequestHeaders();
        System.assert(requestHeaderMap != null, 'request headers should not be blank');
        
        try{
            searchRequest = IND_CustomerNameSearchService.getCustomerNameSearchRequest(requestWrapperObj, opp.Id);
            System.debug('searchRequest ==>'+searchRequest);  
        }catch(Exception pEx){
            System.debug('pEx ==>'+pEx);
        }
        
    }
    
    @isTest
    private static void verifyRequestWrapperNegative(){
        Opportunity opp = TestDataUtility.createTestOpportunity(true);
        Applicant__c applicant = TestDataUtility.createTestApplicantForSMS(false);
        applicant.Opportunity__c=opp.Id;
        insert applicant;
        
        RequestWrapper requestWrapperObj =new RequestWrapper();
        requestWrapperObj.applicantId = String.valueOf(applicant.Id);
        requestWrapperObj.panNumber = 'ADIPS1045P';
        requestWrapperObj.firstName = 'TestFirstName';
        requestWrapperObj.lastName = 'TestLastName';
        requestWrapperObj.dlNumber = 'DLDAP28102993';
        requestWrapperObj.dateOfBirth = '26/June/1982';
        //requestWrapperObj.dealNumber = '28102993';
        //requestWrapperObj.customerCode = 'ADIPS1045P';
        requestWrapperObj.telephoneNumber = '1234567890'; 
        
        try{
            IND_CustomerNameSearchRequest searchRequest = IND_CustomerNameSearchService.getCustomerNameSearchRequest(requestWrapperObj, opp.Id);
            System.debug('searchRequest ==>'+searchRequest);  
        }catch(Exception pEx){
            System.debug('pEx ==>'+pEx);
        }
        
    }
    
    
}